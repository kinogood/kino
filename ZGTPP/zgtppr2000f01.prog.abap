*&---------------------------------------------------------------------*
*& Include          ZGTPPR2000F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form set_selection_period
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_selection_period .

  IF s_date[] IS NOT INITIAL.
    READ TABLE s_date INDEX 1.
  ENDIF.

  REFRESH s_date[].
  s_date-sign = 'I'.
  s_date-option = 'BT'.


  IF s_date-low IS INITIAL.
    CALL FUNCTION '/BEV4/PLPS__ADD_MONTH_TO_DATE'
      EXPORTING
        months  = '-6'
        olddate = sy-datum
      IMPORTING
        newdate = s_date-low.
  ENDIF.

  IF s_date-high IS INITIAL.
    CALL FUNCTION '/BEV4/PLPS__ADD_MONTH_TO_DATE'
      EXPORTING
        months  = '6'
        olddate = sy-datum
      IMPORTING
        newdate = s_date-high.
  ENDIF.
  APPEND s_date.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_parameter_description
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_parameter_description .

* SPG
  IF NOT p_spgcd IS INITIAL.
    CLEAR zppt0107.
    SELECT SINGLE descr INTO p_descr
             FROM zppt0107
            WHERE spgcd EQ p_spgcd.
  ELSE.
    CLEAR p_descr.
  ENDIF.

* 플랜트명
  IF NOT p_werks IS INITIAL.
    CLEAR t001w.
    SELECT SINGLE name1 INTO p_name1
             FROM t001w
            WHERE werks EQ p_werks.
  ELSE.
    CLEAR p_name1.
  ENDIF.

* 납품처
  IF NOT p_kunnr IS INITIAL.
    CLEAR kna1.
    SELECT SINGLE name1 INTO p_name2
             FROM kna1
            WHERE werks EQ p_kunnr.
  ELSE.
    CLEAR p_name2.
  ENDIF.

* 자재번호
*  IF NOT P_MATNR IS INITIAL.
*    P_MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = P_MATNR ).
*  ELSE.
*    CLEAR P_MAKTX.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_first_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_first_screen .

  LOOP AT SCREEN.
    IF screen-group1 = 'M1'.
      screen-input = 0.
      screen-intensified = 1.
      MODIFY SCREEN.
    ENDIF.
    IF screen-group1 = 'M2'.
      screen-input = 0.
      screen-intensified = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_proc .

  REFRESH : gt_sum_quan, gt_main_disp.

  PERFORM get_main_data TABLES gt_main_disp gt_sum_quan.

  PERFORM set_main_display.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MAIN_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_main_data  TABLES  pt_main   STRUCTURE gs_main_disp
                                             pt_sum_quan STRUCTURE gs_sum_quan.

  DATA : lv_dispo TYPE marc-dispo.
  DATA : lv_status TYPE char10.
  RANGES : lt_kunnr FOR kna1-kunnr.
  DATA : BEGIN OF ls_aufnr_status,
           aufnr  TYPE aufk-aufnr,
           status TYPE char10,
         END OF ls_aufnr_status.
  DATA : lt_aufnr_status LIKE TABLE OF ls_aufnr_status.
  DATA : lv_tabix TYPE i.
  DATA : BEGIN OF ls_chk_2010,
           ordnr TYPE zgtppt2010-ordnr,
           posnr TYPE  zgtppt2010-posnr,
         END OF ls_chk_2010.
  DATA : lt_chk_2010 LIKE TABLE OF ls_chk_2010.

  lv_dispo = p_spgcd && '%'. "

  IF p_kunnr IS NOT INITIAL.
    APPEND INITIAL LINE TO lt_kunnr ASSIGNING FIELD-SYMBOL(<ls_kunnr>).
    <ls_kunnr>-sign = 'I'.
    <ls_kunnr>-option = 'EQ'.
    <ls_kunnr>-low = p_kunnr.
  ENDIF.

  SELECT k~vbeln, p~posnr, k~kunnr, p~matnr, p~vrkme, p~meins,
             p~kwmeng AS kwmeng2, "판매단위 수량
             p~klmeng AS kwmeng,  " 기준단위 수량
             p~lprio,
             c~dispo, kna1~name1, a~edatu, p~cuobj, k~vbtyp
    FROM vbep AS a
    INNER JOIN  vbak AS k
                           ON k~vbeln   = a~vbeln
    INNER JOIN vbap AS p
                           ON p~vbeln = a~vbeln
                          AND p~posnr = a~posnr
    INNER JOIN marc AS c
                           ON c~matnr = p~matnr
    INNER JOIN kna1 AS kna1
                           ON kna1~kunnr = k~kunnr
 WHERE a~edatu IN @s_date
      AND a~vbeln IN @s_vbeln
      AND k~vbtyp IN ( 'B', 'C', 'I' )
      AND concat( concat( a~vbeln, a~posnr ), a~etenr ) IN
                            ( SELECT concat( concat( vbeln, posnr ), MAX( etenr ) )
                                FROM vbep
                              WHERE vbeln  = a~vbeln
                                 AND posnr   = a~posnr
                                 AND ( wmeng    NE 0 OR bmeng NE 0 )
                        GROUP BY vbeln, posnr )
      AND concat( p~vbeln, p~posnr ) NOT IN
       ( SELECT  concat( vbeln, posnr )
            FROM vbep
          WHERE vbeln = a~vbeln
              AND posnr   = a~posnr
              AND  ettyp = 'CN'
              AND edatu  = ( SELECT MAX( edatu ) AS edatu
                                FROM vbep
                            WHERE vbeln = a~vbeln
                                AND posnr   = a~posnr
                       GROUP BY vbeln, posnr ) )
        AND p~abgru IS INITIAL
        AND p~matnr IN @s_matnr
        AND c~werks = @p_werks
        AND c~dispo LIKE @lv_dispo
        AND kna1~kunnr IN @lt_kunnr
        INTO  TABLE @DATA(lt_main).

  CHECK lt_main IS NOT INITIAL.
*  추출한 주문 번호로 생산 계획 및 생산 오더 조회
  DATA(lt_chk_order) = lt_main[].

  SORT lt_chk_order BY vbeln posnr.
  DELETE ADJACENT DUPLICATES FROM lt_chk_order COMPARING vbeln posnr.
  IF lt_chk_order[] IS NOT INITIAL.
    SELECT kdauf, kdpos, plnum, gsmng, avmng
      FROM plaf
      INTO TABLE @DATA(lt_plaf)
      FOR ALL ENTRIES IN @lt_chk_order
    WHERE kdauf   = @lt_chk_order-vbeln
        AND kdpos  = @lt_chk_order-posnr
        AND auffx      = 'X'.

*  생산오더 상태값 조회를 위해 마스터테이블 조회
* 생산 오더 상태 삭제(DLFL/TECO/CLSD) 제외
    SELECT kdauf, kdpos, aufnr, posnr, psmng, wemng, psamg
      FROM afpo
      INTO TABLE @DATA(lt_afpo)
      FOR ALL ENTRIES IN @lt_chk_order
    WHERE kdauf   = @lt_chk_order-vbeln
        AND kdpos  = @lt_chk_order-posnr.

* 수량 계산을 위해 기존 생성된 조장구성표 오더 조회
    LOOP AT lt_chk_order INTO DATA(ls_chk_order).
      APPEND INITIAL LINE TO lt_chk_2010 ASSIGNING FIELD-SYMBOL(<ls_chk_2010>).
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = ls_chk_order-vbeln
        IMPORTING
          output = ls_chk_order-vbeln.
      <ls_chk_2010>-ordnr = ls_chk_order-vbeln.
      <ls_chk_2010>-posnr = ls_chk_order-posnr.
    ENDLOOP.

    SELECT * FROM zgtppt2010
      INTO TABLE @DATA(lt_2010)
     FOR ALL ENTRIES IN @lt_chk_2010
     WHERE dmord = @lt_chk_2010-ordnr
       AND dmline = @lt_chk_2010-posnr
       AND dmordty = 'SO'.

  ENDIF.

  DATA(lt_chk_afpo) = lt_afpo[].
  SORT lt_chk_afpo BY aufnr posnr.
  DELETE ADJACENT DUPLICATES FROM lt_chk_afpo COMPARING aufnr posnr.

  IF lt_chk_afpo[] IS NOT INITIAL.
* 생산이력
*  생산 수량: MSEG-BWART = '102' 이면 * -1, SUM(MSEG-MENGE - AFPO-PSAMG)
    SELECT a~aufnr, a~aufps, a~bwart, a~menge, b~psamg
      FROM mseg AS a
         INNER JOIN @lt_chk_afpo AS b
                                              ON a~aufnr = b~aufnr
                                             AND a~aufps = b~posnr
         WHERE a~bwart IN ('101', '102')
         INTO TABLE @DATA(lt_mseg).
  ENDIF.

  DATA : BEGIN OF ls_sum_mseg,
           aufnr LIKE mseg-aufnr,
           aufps LIKE mseg-aufps,
           menge LIKE mseg-menge,
         END OF ls_sum_mseg.
  DATA : lt_sum_mseg LIKE TABLE OF ls_sum_mseg.

  LOOP AT lt_mseg INTO DATA(ls_mseg).
    CLEAR ls_sum_mseg.
    ls_sum_mseg-aufnr = ls_mseg-aufnr.
    ls_sum_mseg-aufps = ls_mseg-aufps.

    READ TABLE lt_2010 INTO DATA(ls_2010) WITH KEY ordnr = ls_mseg-aufnr
                                                                  posnr+2(4) = ls_mseg-aufps
                                                                  ordty = 'PRD'.
    IF sy-subrc EQ 0.
      CASE ls_mseg-bwart.
        WHEN '101'.
          ls_sum_mseg-menge = ls_mseg-menge - ls_mseg-psamg.
          IF ls_sum_mseg-menge NE 0.
            ls_sum_mseg-menge = ls_sum_mseg-menge - ( ls_2010-qlength + ls_2010-adlength ) .
          ENDIF.
        WHEN '102'.
          ls_sum_mseg-menge = ls_mseg-menge - ls_mseg-psamg.
          IF ls_sum_mseg-menge NE 0.
            ls_sum_mseg-menge = ( ls_sum_mseg-menge - ( ls_2010-qlength + ls_2010-adlength ) ) * -1.
          ENDIF.
      ENDCASE.
    ELSE.
      CASE ls_mseg-bwart.
        WHEN '101'.
          ls_sum_mseg-menge = ls_mseg-menge - ls_mseg-psamg.
        WHEN '102'.
          ls_sum_mseg-menge = ( ls_mseg-menge - ls_mseg-psamg ) * -1.
      ENDCASE.
    ENDIF.

    COLLECT ls_sum_mseg INTO lt_sum_mseg.
  ENDLOOP.

  REFRESH pt_sum_quan[].

* 계획오더 수량
  LOOP AT lt_plaf INTO DATA(ls_plaf).
    CLEAR gs_sum_quan.
    gs_sum_quan-vbeln = ls_plaf-kdauf.
    gs_sum_quan-posnr = ls_plaf-kdpos.
    READ TABLE lt_2010 INTO ls_2010 WITH KEY ordnr = ls_plaf-plnum
                                                                  ordty = 'PLN'.
    IF sy-subrc EQ 0. " 조장구성표에 오더 존재하면 조장구성표의 추가여장 빼준다.
      gs_sum_quan-gsmng = ls_plaf-gsmng - ( ls_2010-qlength + ls_2010-adlength ).
    ELSE.
      gs_sum_quan-gsmng = ls_plaf-gsmng - ls_plaf-avmng.
    ENDIF.
    COLLECT  gs_sum_quan INTO pt_sum_quan .
  ENDLOOP.

* 생산오더 잔량
  LOOP AT lt_afpo ASSIGNING FIELD-SYMBOL(<ls_afpo>).

*  상태값조회후 삭제 상태 제외
    READ TABLE lt_aufnr_status INTO ls_aufnr_status WITH KEY aufnr = <ls_afpo>-aufnr BINARY SEARCH.
    lv_tabix = sy-tabix.
    IF sy-subrc EQ 0.
    ELSE.
      CLEAR lv_status.
      PERFORM get_status USING <ls_afpo>-aufnr
                            CHANGING lv_status.

      ls_aufnr_status-aufnr = <ls_afpo>-aufnr.
      ls_aufnr_status-status = lv_status.
      INSERT ls_aufnr_status INTO lt_aufnr_status INDEX lv_tabix.

    ENDIF.

    IF ls_aufnr_status-status = 'DEL'.

    ELSE.

      CLEAR gs_sum_quan.
      gs_sum_quan-vbeln = <ls_afpo>-kdauf.
      gs_sum_quan-posnr = <ls_afpo>-kdpos.
      gs_sum_quan-psmng = <ls_afpo>-psmng - <ls_afpo>-wemng.
      IF gs_sum_quan-psmng NE 0. " 계산후 수량이 0 이라면 스크랩수량 제외 없음
        READ TABLE lt_2010 INTO ls_2010 WITH KEY ordnr = <ls_afpo>-aufnr
                                                                      posnr+2(4) = <ls_afpo>-posnr
                                                                      ordty = 'PRD'.
        IF sy-subrc EQ 0.
          gs_sum_quan-psmng = gs_sum_quan-psmng - <ls_afpo>-psamg - ( ls_2010-qlength + ls_2010-adlength ).
        ELSE.
          gs_sum_quan-psmng = gs_sum_quan-psmng - <ls_afpo>-psamg.
        ENDIF.
      ENDIF.
      COLLECT  gs_sum_quan INTO pt_sum_quan .
    ENDIF.


    READ TABLE lt_sum_mseg INTO ls_sum_mseg WITH KEY aufnr = <ls_afpo>-aufnr
                                                                    aufps = <ls_afpo>-posnr.
    IF sy-subrc EQ 0.
*  생산이력
      CLEAR gs_sum_quan.
      gs_sum_quan-vbeln = <ls_afpo>-kdauf.
      gs_sum_quan-posnr = <ls_afpo>-kdpos.
      IF ls_aufnr_status-status NE 'DEL'. "2026.08.14.zlsgpp5.
        gs_sum_quan-inventory = ls_sum_mseg-menge.
      ENDIF.
      COLLECT  gs_sum_quan INTO pt_sum_quan .
    ENDIF.

  ENDLOOP.

  SORT lt_main BY vbeln posnr.
  DATA : lv_inlength TYPE zgtppt2000-inlength.
  DATA : lv_infactor TYPE zgtppt2000-infactor.

  LOOP AT lt_main INTO DATA(ls_main).
    IF ls_main-kwmeng = 0.
      CLEAR : lv_inlength, lv_infactor.
*조장(기본단위)
*조장수
      zgtpp_cl_common=>get_cha_millca(
        EXPORTING
          iv_cuobj      = ls_main-cuobj                 " 구성
        IMPORTING
          ev_zgteindlen = lv_inlength
          ev_zgtefactor = lv_infactor  ).

      ls_main-kwmeng = lv_inlength * lv_infactor.

    ENDIF.


    READ TABLE pt_sum_quan ASSIGNING FIELD-SYMBOL(<ls_data>) WITH KEY vbeln = ls_main-vbeln
                                                                                                           posnr =  ls_main-posnr.
    IF sy-subrc EQ 0.
*    판매 오더 요구 부족량 계산
*    판매 오더 품목 수량 - (계획 오더 수량+ 생산 오더 잔량) - 판매오더 재고
      <ls_data>-short_order = ls_main-kwmeng - ( <ls_data>-gsmng + <ls_data>-psmng ) - <ls_data>-inventory.

    ELSE.
      APPEND INITIAL LINE TO pt_sum_quan ASSIGNING <ls_data>.
      <ls_data>-vbeln = ls_main-vbeln.
      <ls_data>-posnr =  ls_main-posnr.

      <ls_data>-short_order = ls_main-kwmeng - ( <ls_data>-gsmng + <ls_data>-psmng ) - <ls_data>-inventory.
    ENDIF.
  ENDLOOP.

  MOVE-CORRESPONDING lt_main[] TO pt_main[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_status
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_ORDER>_STATUS
*&---------------------------------------------------------------------*
FORM get_status  USING    pv_aufnr
                 CHANGING pv_status.

  DATA  : lv_sttxt LIKE rc65d-sttxt,
          lv_index LIKE sy-index,
          lt_tj02t LIKE tj02t OCCURS 0 WITH HEADER LINE,
          lv_objnr LIKE aufk-objnr,
          lv_text  LIKE zpps300-text.

  RANGES: lr_status      FOR rc65d-status.

  CALL FUNCTION 'Z_PP_RETURN_ORDER_STATUS'
    EXPORTING
      im_aufnr        = pv_aufnr
    TABLES
      et_sttxt        = lt_tj02t
    EXCEPTIONS
      no_selection    = 1
      not_found_objnr = 2
      OTHERS          = 3.

  REFRESH: lr_status.
  CLEAR: lr_status, lv_index.
  LOOP AT lt_tj02t.
    MOVE: 'I'                    TO lr_status-sign,
          'EQ'                   TO lr_status-option,
          lt_tj02t-txt04         TO lr_status-low.
    APPEND lr_status.       CLEAR lr_status.
  ENDLOOP.

  LOOP AT lt_tj02t.
    CASE lt_tj02t-txt04.
      WHEN 'TECO' OR 'DLFL' OR 'CLSD' OR 'VCAL'.
        pv_status = 'DEL'.
      WHEN OTHERS.

    ENDCASE.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MAIN_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_main_display .

  SORT gt_sum_quan BY vbeln posnr.

  LOOP AT gt_main_disp ASSIGNING FIELD-SYMBOL(<ls_main>).
*    범주
    CASE <ls_main>-vbtyp.
      WHEN 'C' OR 'I'.
        <ls_main>-gcatg = '판매오더'.
      WHEN 'B'.
        <ls_main>-gcatg = '견적'.
    ENDCASE.
*    소요량 요소 : 판매오더/품목번호/우선순위
    CONCATENATE <ls_main>-vbeln <ls_main>-posnr <ls_main>-lprio
                  INTO <ls_main>-req_factor SEPARATED BY '/'.
*조장(기본단위)
*조장수
    zgtpp_cl_common=>get_cha_millca(
      EXPORTING
        iv_cuobj      = <ls_main>-cuobj                 " 구성
      IMPORTING
        ev_zgteindlen = <ls_main>-zgteindlen
        ev_zgtefactor = <ls_main>-zgtefactor  ).

* 부족량
    READ TABLE gt_sum_quan INTO DATA(ls_sum) WITH KEY vbeln = <ls_main>-vbeln
                                                                         posnr = <ls_main>-posnr
                                                                         BINARY SEARCH.
    IF sy-subrc EQ 0.
      IF ls_sum-short_order > 0.
        <ls_main>-short_order = ls_sum-short_order * -1.

      ELSE.
        <ls_main>-short_order = 0.
      ENDIF.
    ENDIF.

    <ls_main>-short_order2 = <ls_main>-kwmeng * -1.

* 제품내역
    <ls_main>-maktx = zgtpp_cl_common=>get_maktx( iv_matnr = <ls_main>-matnr ).
*   특성
    <ls_main>-char = icon_characteristics_act.
* 소요량 - 처리
    <ls_main>-kwmeng2 = <ls_main>-kwmeng2 * -1.

    IF <ls_main>-short_order = 0.
      DELETE gt_main_disp.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form toolbar_pros
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM toolbar_pros  USING    po_sender
                          po_object TYPE REF TO cl_alv_event_toolbar_set
                          r_interactive.

  CASE po_sender.
    WHEN go_grid_0100.
*      IF GT_ITEM_DISP[] IS INITIAL.
      PERFORM set_toolbar TABLES po_object->mt_toolbar
                           USING : '' '' '' '' '3',            "구분자
                                      'OPEN' icon_alv_collapse '' '개별 조장 분해'(i01) 0 .
*      ELSE.
*        PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
*                             USING : '' '' '' '' '3',            "구분자
*                                       'CLOSE' ICON_ALV_COLLAPSE '' '개별 조장 분해' 0 .
*
*
*      ENDIF.


    WHEN go_grid_0101.
      PERFORM set_toolbar TABLES po_object->mt_toolbar
                           USING : '' '' '' '' '3',            "구분자
                                      'INSERT' icon_create ' 신규 조장 구성표 생성'(i02) '신규 조장 구성표 생성'(i02) 0 ,
                                      'APPEND' icon_create_text ' 기존 조장 구성표에 추가'(i03) '기존 조장 구성표에 추가'(i03) 0 ,
                                      '' '' '' '' '3'.            "구분자
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> PO_OBJECT_>MT_TOOLBAR
*&---------------------------------------------------------------------*
FORM set_toolbar  TABLES  pt_toolbar STRUCTURE stb_button
               USING    pv_function
                           pv_icon
                           pv_text
                           pv_quickinfo
                           pv_butn_type.

  DATA : ls_toolbar  TYPE stb_button.

  CLEAR ls_toolbar.
  ls_toolbar-function  = pv_function.
  ls_toolbar-icon      = pv_icon.
  IF pv_text IS NOT INITIAL.
    CONCATENATE pv_text '　'  INTO ls_toolbar-text.
  ENDIF.
  ls_toolbar-quickinfo = pv_quickinfo.
  ls_toolbar-butn_type = pv_butn_type.
  APPEND ls_toolbar TO pt_toolbar.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_pros
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM user_command_pros  USING   po_sender  TYPE REF TO cl_gui_alv_grid
                                 pv_ucomm.

  DATA : lt_row TYPE lvc_t_row.
  DATA : ls_row TYPE lvc_s_row.
  DATA : lv_eindlen LIKE vbap-kwmeng. "부족량 계산
  DATA : lt_2000 TYPE TABLE OF zgtppt2000.
  DATA : lt_item LIKE TABLE OF gs_item_disp.
  DATA : ls_item LIKE gs_item_disp.
  DATA : lv_chk_err.

  CALL METHOD po_sender->get_selected_rows
    IMPORTING
      et_index_rows = lt_row.

  DELETE lt_row WHERE index = 0. " 서브토탈 제외

*  커맨드입력시 라인 선택확인
  CASE pv_ucomm.
    WHEN 'OPEN' OR 'INSERT' OR 'APPEND'..
      IF lt_row[] IS INITIAL.
        CASE po_sender.
          WHEN go_grid_0100.
            MESSAGE s003 DISPLAY LIKE 'E' WITH '선택된 판매오더 품목이 없습니다'(m01).
          WHEN go_grid_0101.
            MESSAGE s003 DISPLAY LIKE 'E' WITH '선택된 판매오더 품목이 없습니다'(m01).
        ENDCASE.
        RETURN.
      ENDIF.
  ENDCASE.

  CASE po_sender.
    WHEN go_grid_0100.
      CASE pv_ucomm.
        WHEN 'OPEN'.
          REFRESH gt_item_disp.
          LOOP AT lt_row INTO ls_row.
            READ TABLE gt_main_disp INTO gs_main_disp INDEX ls_row-index.
            lv_eindlen = gs_main_disp-short_order.
            WHILE lv_eindlen < 0.
              CLEAR ls_item.
              MOVE-CORRESPONDING  gs_main_disp TO ls_item.
              lv_eindlen = lv_eindlen + ls_item-zgteindlen.
              APPEND ls_item TO gt_item_disp.
            ENDWHILE.
          ENDLOOP.

          DATA(lt_dup_chk) = gt_item_disp.
          SORT lt_dup_chk BY matnr.
          DELETE ADJACENT DUPLICATES FROM lt_dup_chk COMPARING matnr.
          IF lines( lt_dup_chk ) > 1.
            MESSAGE s000 DISPLAY LIKE 'E' WITH '조장구성표 생성은 동일한 제품으로만 구성 할 수 있습니다'(m02).
            RETURN.
          ENDIF.


          IF gt_item_disp[] IS INITIAL.
            MESSAGE s000 DISPLAY LIKE 'E' WITH '판매오더 부족 수량이 없어 조장구성표를 생성할 수 없습니다'(m03).
            RETURN.
          ENDIF.

          PERFORM refresh_grid_0101.
      ENDCASE.
    WHEN go_grid_0101.

      DELETE lt_row WHERE rowtype IS NOT INITIAL.
      CASE pv_ucomm.
        WHEN 'INSERT'.
          LOOP AT lt_row INTO ls_row.
            READ TABLE gt_item_disp INTO gs_item_disp INDEX ls_row-index.
            APPEND gs_item_disp TO lt_item.
          ENDLOOP.
          CLEAR lv_chk_err.
          PERFORM make_save_zgtppt2000 TABLES lt_item lt_2000
                                                             USING 'N' gv_grpnr
                                                        CHANGING lv_chk_err.

          IF lv_chk_err IS NOT INITIAL.
            RETURN.
          ENDIF.

          PERFORM save_data_zgtppt2000 TABLES lt_2000
                                                             USING 'N' gv_grpnr
                                                        CHANGING lv_chk_err.

          IF lv_chk_err IS NOT INITIAL.
            RETURN.
          ENDIF.

          go_grid_0101->set_selected_rows( ).

        WHEN 'APPEND'.
          CLEAR gv_grpnr.
          CALL SCREEN 0200 STARTING AT 10 5 ENDING AT 76 7.
          IF gv_grpnr IS INITIAL.
            RETURN.
          ENDIF.
          LOOP AT lt_row INTO ls_row.
            READ TABLE gt_item_disp INTO gs_item_disp INDEX ls_row-index.
            APPEND gs_item_disp TO lt_item.
          ENDLOOP.
          CLEAR lv_chk_err.
          PERFORM make_save_zgtppt2000 TABLES lt_item lt_2000
                                                             USING '' gv_grpnr
                                                        CHANGING lv_chk_err.

          IF lv_chk_err IS NOT INITIAL.
            RETURN.
          ENDIF.
          PERFORM save_data_zgtppt2000 TABLES lt_2000
                                                             USING '' gv_grpnr
                                                        CHANGING lv_chk_err.

          IF lv_chk_err IS NOT INITIAL.
            RETURN.
          ENDIF.

          go_grid_0101->set_selected_rows( ).

      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM double_click  USING    p_sender TYPE REF TO cl_gui_alv_grid
                            p_row TYPE lvc_s_row
                            p_column TYPE lvc_s_col.

  FIELD-SYMBOLS <ls_data> TYPE any.
  FIELD-SYMBOLS <lv_field> TYPE any.

  CHECK p_row-index > 0.

  CASE p_sender.
    WHEN go_grid_0100.
      READ TABLE gt_main_disp ASSIGNING <ls_data> INDEX p_row-index.
    WHEN go_grid_0101.
      READ TABLE gt_item_disp ASSIGNING <ls_data> INDEX p_row-index.
  ENDCASE.

  CASE p_column-fieldname.
    WHEN 'VBELN' OR 'POSNR'.
      ASSIGN COMPONENT 'VBELN' OF STRUCTURE <ls_data> TO <lv_field>.
      SET PARAMETER ID 'AUN' FIELD <lv_field>.
      CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
    WHEN 'CHAR'.
      ASSIGN COMPONENT 'CUOBJ' OF STRUCTURE <ls_data> TO <lv_field>.
      PERFORM display_popup_charactics USING <lv_field>.
    WHEN 'MATNR'.
      ASSIGN COMPONENT p_column-fieldname OF STRUCTURE <ls_data> TO <lv_field>.
      SET PARAMETER ID 'WRK' FIELD p_werks.
      SET PARAMETER ID 'MXX' FIELD 'K'.
      SET PARAMETER ID 'MAT' FIELD <lv_field>..
      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_object_grid_0100 .

*  CREATE OBJECT GO_CONTAINER
*    EXPORTING
*      container_name = 'CONTAINER'.

  CREATE OBJECT go_docking_container
    EXPORTING
      repid                       = sy-repid
      dynnr                       = sy-dynnr
      extension                   = 10000
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5.
*화면 분할
  CREATE OBJECT go_splitter
    EXPORTING
      parent  = go_docking_container
      rows    = 2
      columns = 1.

  go_splitter->set_row_height(
    EXPORTING
      id                =    1              " Row ID
      height            =    45 ).             " Height

* top 컨테이너
  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_contain_0100.
* bottom 컨테이너
  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_contain_0101.


  CREATE OBJECT go_grid_0100
    EXPORTING
      i_parent      = go_contain_0100
      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM event_handler_register  USING    po_grid TYPE REF TO cl_gui_alv_grid.

  IF go_event_handler IS NOT BOUND.
    CREATE OBJECT go_event_handler.
  ENDIF.

*// Event Handler ##
  SET HANDLER go_event_handler->handle_toolbar               FOR po_grid.
  SET HANDLER go_event_handler->handle_user_command          FOR po_grid.
  SET HANDLER go_event_handler->handle_double_click          FOR po_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_grid_0100 .

  CLEAR gs_layout_0100.
  gs_layout_0100-cwidth_opt = abap_true.
  gs_layout_0100-no_rowins = abap_true.
  gs_layout_0100-sel_mode   = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0100 .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR2000TOP'
      i_internal_tabname     = 'GS_MAIN_DISP'
    CHANGING
      ct_fieldcat            = lt_fcat_slis
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat_slis
    IMPORTING
      et_fieldcat_lvc = gt_fieldcat_0100[]
    TABLES
      it_data         = gt_main_disp
    EXCEPTIONS
      OTHERS          = 1.

  APPEND INITIAL LINE TO gt_fieldcat_0100 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
  <ls_fcat>-fieldname = 'REQ_FACTOR'.
  <ls_fcat>-reptext = '소요량 요소'(f16).
  <ls_fcat>-col_pos = 2.
  <ls_fcat>-datatype = 'CHAR'.
  <ls_fcat>-dd_outlen = '50'.
  <ls_fcat>-just = 'C'.
  <ls_fcat>-key = abap_true.

  LOOP AT gt_fieldcat_0100 ASSIGNING <ls_fcat>.
    CASE   <ls_fcat>-fieldname.
      WHEN 'GCATG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '범주'(f01).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'C'.
      WHEN 'ZGTEINDLEN'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '조장(기본단위)'(f02).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'R'.
      WHEN 'ZGTEFACTOR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '조장수'(f03).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'R'.
      WHEN 'SHORT_ORDER'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '부족량'(f04).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'R'.
      WHEN 'EDATU'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '소요일'(f05).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'C'.
      WHEN 'MAKTX'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '제품내역'(f06).
        <ls_fcat>-just = 'L'.
      WHEN 'KWMENG'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'KWMENG2'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '소요량'(f07).
        <ls_fcat>-just = 'R'.
      WHEN 'VRKME'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '판매단위'(f17).
        <ls_fcat>-just = 'C'.
      WHEN 'MEINS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '기본단위'(f08).
        <ls_fcat>-just = 'C'.
        <ls_fcat>-key = abap_true.
      WHEN 'CHAR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '특성'(f09).
        <ls_fcat>-just = 'C'.
        <ls_fcat>-icon = 'X'.
        CLEAR <ls_fcat>-key.
      WHEN 'VBELN'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '오더번호'(f10).
        <ls_fcat>-just = 'C'.
        CLEAR <ls_fcat>-key.
      WHEN 'POSNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '품목번호'(f11).
        <ls_fcat>-just = 'C'.
        CLEAR <ls_fcat>-key.
      WHEN 'MATNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '제품코드'(f12).
        <ls_fcat>-just = 'C'.
        CLEAR <ls_fcat>-key.
      WHEN 'LPRIO'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '우선순위'(f13).
        <ls_fcat>-just = 'C'.
      WHEN 'KUNNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '목적지/공급처'(f14).
        <ls_fcat>-just = 'C'.
      WHEN 'NAME1'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '목적지 내역'(f15).
        <ls_fcat>-just = 'L'.
      WHEN 'DISPO' OR 'CUOBJ' OR 'VBTYP' OR 'SHORT_ORDER2'.
        <ls_fcat>-tech = abap_true.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_of_toolbar_grid_0100 .

  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0100
        USING : cl_gui_alv_grid=>mc_fc_loc_undo,
                cl_gui_alv_grid=>mc_fc_auf,
                cl_gui_alv_grid=>mc_fc_check,
                cl_gui_alv_grid=>mc_fc_loc_paste,
                cl_gui_alv_grid=>mc_fc_loc_copy,
                cl_gui_alv_grid=>mc_fc_average,
                cl_gui_alv_grid=>mc_fc_graph,
                cl_gui_alv_grid=>mc_fc_info,
                cl_gui_alv_grid=>mc_fc_loc_copy_row,
                cl_gui_alv_grid=>mc_fc_loc_cut,
                cl_gui_alv_grid=>mc_fc_loc_delete_row,
                cl_gui_alv_grid=>mc_fc_loc_insert_row,
                cl_gui_alv_grid=>mc_fc_loc_append_row,
                cl_gui_alv_grid=>mc_fc_loc_paste,
                cl_gui_alv_grid=>mc_fc_loc_paste_new_row,
                cl_gui_alv_grid=>mc_fc_refresh.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*       text
*-----------------------------------------------------------------------
**
FORM add_exclude_toolbar_button  TABLES   p_table
                                 USING    p_value.
  DATA: l_exclude TYPE ui_func.
  l_exclude = p_value.
  APPEND l_exclude TO p_table.
ENDFORM.                    " add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0100_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_grid_0100_display .

  CALL METHOD go_grid_0100->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0100
      it_toolbar_excluding = gt_exclude_0100
    CHANGING
      it_outtab            = gt_main_disp
      it_fieldcatalog      = gt_fieldcat_0100.

  IF line_exists( gt_main_disp[ zgteindlen = 0 ]  ).
    CALL FUNCTION 'POPUP_DISPLAY_MESSAGE'
      EXPORTING
        msgid = 'ZGTPP00'
        msgty = 'I'
        msgno = '000'
        msgv1 = '조장(기본단위)가 조회되지 않은 판매오더가 존재합니다.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_grid_0101 .

  IF go_grid_0101 IS NOT BOUND.
    PERFORM set_object_grid_0101.
    PERFORM event_handler_register USING go_grid_0101.
    PERFORM set_layout_grid_0101.
    PERFORM set_fieldcat_grid_0101.
    PERFORM exclude_of_toolbar_grid_0101.
*    PERFORM SET_SORTTAB_GRID_0101.
    PERFORM call_grid_0101_display.
  ELSE.
    PERFORM refresh_grid USING go_grid_0101.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_object_grid_0101 .

* bottom 컨테이너
  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_contain_0101.

  CREATE OBJECT go_grid_0101
    EXPORTING
      i_parent      = go_contain_0101
      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_grid_0101 .

  gs_layout_0101-cwidth_opt = abap_true.
  gs_layout_0101-no_rowins = abap_true.
  gs_layout_0101-sel_mode   = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0101 .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR2000TOP'
      i_internal_tabname     = 'GS_ITEM_DISP'
    CHANGING
      ct_fieldcat            = lt_fcat_slis
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat_slis
    IMPORTING
      et_fieldcat_lvc = gt_fieldcat_0101[]
    TABLES
      it_data         = gt_item_disp
    EXCEPTIONS
      OTHERS          = 1.

  APPEND INITIAL LINE TO gt_fieldcat_0101 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
  <ls_fcat>-fieldname = 'REQ_FACTOR'.
  <ls_fcat>-reptext = '소요량 요소'(f16).
  <ls_fcat>-col_pos = 2.
  <ls_fcat>-datatype = 'CHAR'.
  <ls_fcat>-dd_outlen = '50'.
  <ls_fcat>-just = 'C'.
  <ls_fcat>-key = abap_true.

  LOOP AT gt_fieldcat_0101 ASSIGNING <ls_fcat>.
    CASE   <ls_fcat>-fieldname.
      WHEN 'GCATG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '범주'(f01).
        <ls_fcat>-just = 'C'.
      WHEN 'ZGTEINDLEN'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '조장(기본단위)'(f02).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'R'.
        <ls_fcat>-do_sum = 'X'.
      WHEN 'SHORT_ORDER'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '부족량'(f04).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'R'.
      WHEN 'EDATU'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '소요일'(f05).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'C'.
      WHEN 'MAKTX'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '제품내역'(f06).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'L'.
      WHEN 'KWMENG'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'KWMENG2'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '소요량'(f07).
        <ls_fcat>-just = 'R'.
      WHEN 'MEINS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '기본단위'(f08).
        <ls_fcat>-just = 'C'.
      WHEN 'CHAR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '특성'(f09).
        <ls_fcat>-just = 'C'.
        <ls_fcat>-icon = 'X'.
        CLEAR <ls_fcat>-key.
      WHEN 'VBELN'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '오더번호'(f10).
        <ls_fcat>-just = 'C'.
        CLEAR <ls_fcat>-key.
      WHEN 'POSNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '품목번호'(f11).
        <ls_fcat>-just = 'C'.
        CLEAR <ls_fcat>-key.
      WHEN 'MATNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '제품코드'(f12).
        <ls_fcat>-just = 'C'.
        CLEAR <ls_fcat>-key.
      WHEN 'LPRIO'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '우선순위'(f13).
        <ls_fcat>-just = 'C'.
      WHEN 'KUNNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '목적지/공급처'(f14).
        <ls_fcat>-just = 'C'.
      WHEN 'NAME1'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '목적지 내역'(f15).
        <ls_fcat>-just = 'L'.
      WHEN 'DISPO' OR 'CUOBJ' OR 'SHORT_ORDER2'.
        <ls_fcat>-tech = abap_true.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_of_toolbar_grid_0101 .

  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0101
        USING : cl_gui_alv_grid=>mc_fc_loc_undo,
                cl_gui_alv_grid=>mc_fc_auf,
                cl_gui_alv_grid=>mc_fc_check,
                cl_gui_alv_grid=>mc_fc_loc_copy,
                cl_gui_alv_grid=>mc_fc_loc_paste,
                cl_gui_alv_grid=>mc_fc_average,
                cl_gui_alv_grid=>mc_fc_graph,
                cl_gui_alv_grid=>mc_fc_info,
                cl_gui_alv_grid=>mc_fc_loc_copy_row,
                cl_gui_alv_grid=>mc_fc_loc_cut,
                cl_gui_alv_grid=>mc_fc_loc_delete_row,
                cl_gui_alv_grid=>mc_fc_loc_insert_row,
                cl_gui_alv_grid=>mc_fc_loc_append_row,
                cl_gui_alv_grid=>mc_fc_loc_paste,
                cl_gui_alv_grid=>mc_fc_loc_paste_new_row,
                cl_gui_alv_grid=>mc_fc_refresh.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0101_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_grid_0101_display .

  CALL METHOD go_grid_0101->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0101
      it_toolbar_excluding = gt_exclude_0101
    CHANGING
      it_outtab            = gt_item_disp
      it_sort              = gt_sort_0101
      it_fieldcatalog      = gt_fieldcat_0101.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_sorttab_grid_0101 .

  REFRESH gt_sort_0101.

  PERFORM set_sort_tab TABLES gt_sort_0101
                            USING : 1 'VBELN' 'X' '' 'X',
                                       2 'POSNR' 'X' '' 'X'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_sort_tab
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SORT_0100
*&      --> P_1
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_sort_tab  TABLES   pt_sorttab STRUCTURE lvc_s_sort
                   USING    pv_pos
                               pv_fieldname
                               pv_up
                               pv_down
                               pv_subtot.

  DATA : ls_sort TYPE lvc_s_sort.
  ls_sort-spos = pv_pos.
  ls_sort-fieldname = pv_fieldname.
  ls_sort-up = pv_up.
  ls_sort-down = pv_down.
  ls_sort-subtot =  pv_subtot.
  APPEND ls_sort TO pt_sorttab.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0101
*&---------------------------------------------------------------------*
FORM refresh_grid  USING    po_grid TYPE REF TO cl_gui_alv_grid.

  DATA: ls_scroll   TYPE lvc_s_stbl.

  ls_scroll-row = 'X'.
  ls_scroll-col = 'X'.

  CALL METHOD po_grid->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = ls_scroll.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_POPUP_CHARACTICS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LV_FIELD>
*&---------------------------------------------------------------------*
FORM display_popup_charactics  USING    pv_cuobj TYPE cuobj_va.

  DATA : ls_incl_bild TYPE incl_bild.
* 초기화
  CALL FUNCTION 'CUD0_CONFIGURATION_INITIALIZER'.

  CALL FUNCTION 'VC_I_DISPLAY_CONFIGURATION'
    EXPORTING
      instance           = pv_cuobj
      include_screen     = ls_incl_bild
*     APPLICATION        = ' '
*     MATNR_APPL         =
*     WERKS_APPL         =
*     BESKZ_APPL         =
*     SOBSL_APPL         =
*     NO_STRUC           = 'X'
*     NO_RESULT          = 'X'
*     NO_MASTERD         = 'X'
*     NO_PRICE           = 'X'
*     NO_TYPEM           = 'X'
*     IV_INVALID_POSSIBLE       = ' '
      iv_no_value_check  = ' X'
*     EFFECTIVITY        = ' '
    EXCEPTIONS
      instance_not_found = 1
      internal_error     = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.

  ENDIF.
  .


ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_save_ZGTPPT2000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM make_save_zgtppt2000  TABLES pt_item STRUCTURE gs_item_disp
                                                        pt_2000 STRUCTURE zgtppt2000
                                                USING pv_gubun
                                                         pv_grpnr TYPE zgtegrpnr
                                           CHANGING pv_chk_err.

  DATA : ls_2000 TYPE zgtppt2000.
  DATA : lv_index TYPE i.
  DATA : lt_sum LIKE TABLE OF gs_sum_quan.
  DATA : lt_chk_2000 TYPE TABLE OF zgtppt2000.
  DATA : lt_old_2000 TYPE TABLE OF zgtppt2000.
  DATA : lv_sum TYPE p LENGTH 13 DECIMALS 3.
  DATA : lv_chk_factor TYPE zgtppt2000-infactor.
  DATA : lv_old_factor TYPE zgtppt2000-infactor.

  REFRESH pt_2000[].

  LOOP AT pt_item INTO DATA(ls_item).
    CLEAR ls_2000.
    READ TABLE pt_2000 INTO ls_2000 WITH KEY ordno = ls_item-vbeln
                                                               posnr = ls_item-posnr
                                                               BINARY SEARCH.
    IF sy-subrc EQ 0. " 이미 어팬드 처리건 조장수만 더해준다
      ls_2000-infactor = ls_2000-infactor + 1.
      MODIFY pt_2000 FROM ls_2000 INDEX sy-tabix TRANSPORTING infactor .
    ELSE.
      lv_index = sy-tabix.
      ls_2000-ordno   = ls_item-vbeln.
      ls_2000-posnr   = ls_item-posnr.
      ls_2000-linno   = '0001'.
      ls_2000-erdat = sy-datum.
      ls_2000-werks = p_werks.
      ls_2000-spgcd = p_spgcd.
      ls_2000-matnr = ls_item-matnr.
      ls_2000-maktx = ls_item-maktx.
      ls_2000-kunnr = ls_item-kunnr.
      ls_2000-inlength = ls_item-zgteindlen.
      ls_2000-infactor = ls_2000-infactor + 1.
      ls_2000-edatu = ls_item-edatu.
      ls_2000-wmeng = ls_item-kwmeng.
      ls_2000-meins = ls_item-meins.
      ls_2000-zstatus = abap_false.
      ls_2000-gcatg = ls_item-gcatg.
      ls_2000-ernam = sy-uname.
      ls_2000-aedat = sy-datum.
      ls_2000-aenam  = sy-uname.
      INSERT ls_2000 INTO pt_2000 INDEX lv_index.
    ENDIF.
  ENDLOOP.

  PERFORM get_hist_data_2000 TABLES pt_2000 lt_chk_2000.

  LOOP AT pt_2000 INTO ls_2000.
    CLEAR lv_old_factor.
    READ TABLE gt_main_disp INTO DATA(ls_main) WITH KEY vbeln = ls_2000-ordno
                                                                                 posnr = ls_2000-posnr.

    READ TABLE lt_chk_2000 TRANSPORTING NO FIELDS WITH KEY ordno = ls_2000-ordno
                                                                                    posnr = ls_2000-posnr.
    IF sy-subrc EQ 0.
      LOOP AT lt_chk_2000 INTO DATA(ls_old) FROM sy-tabix.
        IF NOT ( ls_old-ordno = ls_2000-ordno AND  ls_old-posnr = ls_2000-posnr ).
          EXIT.
        ENDIF.

        IF ls_old-wmeng NE ls_main-kwmeng.
          MESSAGE s000 DISPLAY LIKE 'E' WITH ls_main-vbeln '판매오더 소요량이 변경되었습니다. '(m04) '업데이트 하십시오. 기존 소요량 - '(m05) ls_old-wmeng.
          pv_chk_err = abap_true.
          EXIT.
        ENDIF.

        IF ls_old-inlength NE ls_main-zgteindlen.
          MESSAGE s000 DISPLAY LIKE 'E' WITH ls_main-vbeln '판매오더 개별조장이 변경되었습니다. '(m06) '업데이트 하십시오. 기존 개별조장 - '(m07) ls_old-inlength.
          pv_chk_err = abap_true.
          EXIT.
        ENDIF.

        lv_old_factor = lv_old_factor + ls_old-infactor. "  기존에 저장된 누적 조장합

      ENDLOOP.

      IF pv_chk_err IS NOT INITIAL.
        EXIT.
      ENDIF.

      CLEAR lv_sum.
      CLEAR lv_chk_factor.

      DO.
        lv_chk_factor = lv_chk_factor + 1.
        CLEAR lv_sum.
        lv_sum = ls_main-short_order2 + ( lv_chk_factor * ls_2000-inlength ).

        IF lv_sum >= 0.
          EXIT.
        ENDIF.
      ENDDO.

      lv_chk_factor = lv_chk_factor - lv_old_factor - ls_2000-infactor.
      IF lv_chk_factor < 0 .
        MESSAGE s000 DISPLAY LIKE 'E' WITH ls_main-vbeln '에 대한 조장구성표에 등록된 조장 합이 소요량보다 큽니다.'(m08).
        pv_chk_err = abap_true.
        EXIT.
      ENDIF.

    ENDIF.
  ENDLOOP.


  CHECK pv_gubun NE 'N'.
* validation check
  PERFORM get_old_2000_data TABLES lt_old_2000
                                               USING pv_grpnr.
  DELETE lt_old_2000 WHERE zstatus <> ''.
  IF sy-subrc EQ 0.
    MESSAGE s000 DISPLAY LIKE 'E' WITH pv_grpnr '처리된 내역이 있어 추가할 수 없습니다.'(m09).
    pv_chk_err = abap_true.
    EXIT.
  ENDIF.

* 기존에 조장구성표에 저장된 오더, 품목일 경우 조장수에 더해준다.
  LOOP AT pt_2000 ASSIGNING FIELD-SYMBOL(<ls_2000>).
    READ TABLE lt_old_2000 INTO ls_old WITH KEY ordno = <ls_2000>-ordno
                                                                       posnr = <ls_2000>-posnr.
    IF sy-subrc EQ 0.
      <ls_2000>-infactor = <ls_2000>-infactor + ls_old-infactor.
      <ls_2000>-ernam  = ls_old-ernam.
      <ls_2000>-erdat  = ls_old-erdat.
    ENDIF.

  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_OLD_2000_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_OLD_2000
*&      --> SORT
*&      --> LT_MAIN
*&      --> BY
*&      --> VBELN
*&      --> POSNR
*&---------------------------------------------------------------------*
FORM get_old_2000_data  TABLES   pt_old STRUCTURE zgtppt2000
                                          USING   pv_grpnr TYPE zgtppt2000-grpnr.

  SELECT * FROM zgtppt2000
    INTO CORRESPONDING FIELDS OF TABLE pt_old
   WHERE grpnr = pv_grpnr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA_ZGTPPT2000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2000
*&      --> P_
*&      --> GV_GRPNR
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM save_data_zgtppt2000  TABLES pt_2000 STRUCTURE zgtppt2000
                                                USING pv_gubun
                                                         pv_grpnr TYPE zgtegrpnr
                                           CHANGING pv_chk_err.

  DATA : lv_grpnr TYPE zgtegrpnr.
  DATA : lv_nr     LIKE  inri-nrrangenr,
         lv_number TYPE c LENGTH 5.

  CASE pv_gubun.
    WHEN 'N'. " 신규 조장 구성표 번호 생성
      lv_nr = p_spgcd.
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr             = lv_nr
          object                  = 'ZSPG'
        IMPORTING
          number                  = lv_number
        EXCEPTIONS
          interval_not_found      = 1
          number_range_not_intern = 2
          object_not_found        = 3
          quantity_is_0           = 4
          quantity_is_not_1       = 5
          interval_overflow       = 6
          buffer_overflow         = 7
          OTHERS                  = 8.
      IF sy-subrc <> 0.
        MESSAGE s000 DISPLAY LIKE 'E' WITH 'SPG는 마스터에 없습니다.'(m10) ' 조장구성표를 생성할 수 없습니다.'(m11).
        pv_chk_err = abap_true.
        RETURN.
      ENDIF.
      lv_grpnr = p_spgcd && sy-datum+0(4) && sy-datum+4(2) && lv_number.

    WHEN OTHERS.
      lv_grpnr = pv_grpnr.

  ENDCASE.

  LOOP AT pt_2000 ASSIGNING FIELD-SYMBOL(<ls_2000>).
    <ls_2000>-grpnr = lv_grpnr.
  ENDLOOP.

  IF pt_2000[] IS NOT INITIAL.
    MODIFY zgtppt2000 FROM TABLE pt_2000.
    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
      MESSAGE s000 WITH lv_grpnr '생성 되었습니다.'(m12).
    ELSE.
      ROLLBACK WORK.
      MESSAGE s000 DISPLAY LIKE 'E' WITH '조장 구성표 생성중 오류 발생하였습니다.!'(m13).
      pv_chk_err = abap_true.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  F4HELP_GV_GRPNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4help_gv_grpnr INPUT.

  DATA: BEGIN OF lt_zgtppt2000 OCCURS 0,
          grpnr TYPE zgtppt2000-grpnr,
          erdat TYPE zgtppt2000-erdat,
          matnr TYPE zgtppt2000-matnr,
        END   OF lt_zgtppt2000.

  DATA : lt_return_tab TYPE TABLE OF ddshretval.

  SELECT grpnr    erdat    matnr
    INTO CORRESPONDING FIELDS OF TABLE lt_zgtppt2000
    FROM zgtppt2000
   WHERE spgcd = p_spgcd.

  SORT lt_zgtppt2000 BY grpnr.
  DELETE ADJACENT DUPLICATES FROM lt_zgtppt2000 COMPARING grpnr.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield     = 'GRPNR'
      dynpprog     = sy-cprog
      dynpnr       = sy-dynnr
      window_title = '조장 구성표 번호 선택'(m14)
      value_org    = 'S'
    TABLES
      value_tab    = lt_zgtppt2000
      return_tab   = lt_return_tab.

  READ TABLE lt_return_tab INTO DATA(ls_return_tab) INDEX 1.

  gv_grpnr = ls_return_tab-fieldval.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form GET_HIST_DATA_2000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_2000
*&      --> LT_CHK_2000
*&---------------------------------------------------------------------*
FORM get_hist_data_2000  TABLES   pt_2000 STRUCTURE zgtppt2000
                                  pt_chk_2000 STRUCTURE zgtppt2000.

  DATA(lt_chk_data) = pt_2000[].

  SORT lt_chk_data BY ordno posnr.
  DELETE ADJACENT DUPLICATES FROM lt_chk_data COMPARING ordno posnr.

  IF lt_chk_data[] IS NOT INITIAL.
    SELECT * FROM zgtppt2000
      INTO CORRESPONDING FIELDS OF TABLE pt_chk_2000
      FOR ALL ENTRIES IN lt_chk_data
     WHERE ordno = lt_chk_data-ordno
        AND posnr = lt_chk_data-posnr
        AND gcatg = '판매오더'
        AND zstatus = abap_false.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_VALIDATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM chk_validation .

  IF s_matnr[] IS INITIAL AND s_vbeln[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '자재나 판매오더 중 하나는 입력해야 합니다..'(m15).
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
