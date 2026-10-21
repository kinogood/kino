*&---------------------------------------------------------------------*
*& Include          ZGTPPR2020F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_PARAMETER_DESCRIPTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_parameter_description .

* SPG
  IF NOT p_spgcd IS INITIAL.
    SELECT SINGLE descr INTO p_descr
             FROM zppt0107
            WHERE spgcd EQ p_spgcd.
  ELSE.
    CLEAR p_descr.
  ENDIF.

* 플랜트명
  IF NOT p_werks IS INITIAL.
    SELECT SINGLE name1 INTO p_name1
             FROM t001w
            WHERE werks EQ p_werks.
  ELSE.
    CLEAR p_name1.
  ENDIF.

* 플랜트명
  IF NOT p_gongcd IS INITIAL.
    SELECT SINGLE gong_nm INTO p_gongnm
             FROM zedt0011
            WHERE gong_cd EQ p_gongcd.
  ELSE.
    CLEAR p_gongnm.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_FIRST_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_first_screen .

  LOOP AT SCREEN.
    CASE abap_true.
      WHEN p_disp.

        IF screen-group1 = 'M1'.
          screen-input = 0.
          screen-intensified = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group1 = 'M2'.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group1 = 'S2'.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.

      WHEN p_plan.
        CASE screen-name.
          WHEN 'P_GONGCD'.
            screen-required = 2.
            MODIFY SCREEN.
        ENDCASE.

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

        IF screen-group1 = 'S1'.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.


    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SELECTION_PERIOD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_selection_period .

  IF s_gstrp[] IS NOT INITIAL.
    READ TABLE s_gstrp INDEX 1.
  ENDIF.

  REFRESH s_gstrp[].
  s_gstrp-sign = 'I'.
  s_gstrp-option = 'BT'.


  IF s_gstrp-low IS INITIAL.
    s_gstrp-low = sy-datum.
  ENDIF.

  IF s_gstrp-high IS INITIAL.
    CALL FUNCTION '/BEV4/PLPS__ADD_MONTH_TO_DATE'
      EXPORTING
        months  = '1'
        olddate = sy-datum
      IMPORTING
        newdate = s_gstrp-high.
  ENDIF.
  APPEND s_gstrp.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  PERFORM get_main_data.

  CASE abap_true.
    WHEN p_disp. " 스케줄조회
      PERFORM make_schedule_table.
      PERFORM set_order_schedule.
    WHEN p_plan. " 일정수립
      PERFORM make_schedule_table.
      PERFORM set_order_schedule.
      PERFORM make_order_info.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MAIN_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_main_data .

  DATA : lt_gong_cd TYPE RANGE OF zedt0011-gong_cd.
  DATA : lv_dispo TYPE marc-dispo.
  DATA : lt_aufnr TYPE RANGE OF aufnr.
  DATA : lt_date TYPE RANGE OF sy-datum.

* 조회조건 상세 설정
* 공정코드 조회 레인지테이블로 통일
  CASE abap_true.
    WHEN p_plan.
      IF p_gongcd IS NOT INITIAL.
        APPEND INITIAL LINE TO lt_gong_cd ASSIGNING FIELD-SYMBOL(<ls_gong_cd>).
        <ls_gong_cd>-sign = 'I'.
        FIND ALL OCCURRENCES OF '*' IN p_gongcd MATCH COUNT FINAL(lv_cnt).
        IF lv_cnt > 0.
          <ls_gong_cd>-option = 'CP'.
        ELSE.
          <ls_gong_cd>-option = 'EQ'.
        ENDIF.
        <ls_gong_cd>-low = p_gongcd.
      ENDIF.
    WHEN p_disp.
      lt_gong_cd[] = s_gongcd[].

  ENDCASE.

* 출력을 위한 공정 대상 조회
  SELECT a~*, c~ktext
     FROM zgtppt2060 AS a
    INNER JOIN crhd  AS b
                           ON b~arbpl = a~arbpl
                          AND b~werks = a~werks
   INNER JOIN crtx   AS c
                           ON c~objid = b~objid
                          AND c~objty = b~objty
   WHERE a~werks = @p_werks
       AND a~spgcd = @p_spgcd
       AND a~gong_cd IN @lt_gong_cd
       AND c~spras = @sy-langu
       AND c~objty = 'A'
    INTO TABLE @gt_gong_cd.

  SORT gt_gong_cd BY seq.
  DELETE ADJACENT DUPLICATES FROM gt_gong_cd COMPARING seq.

* SPG 테이블 조회용 필드로 변경
  lv_dispo = p_spgcd && '%'. "

* 세부오더 내역데이터 조회
  CASE abap_true.
    WHEN p_plan.
*     상세 조회조건 입력시 날짜 구간 조회 아님
      lt_date = s_gstrp[].
      IF s_aufnr[] IS NOT INITIAL OR
        s_kdauf[] IS NOT INITIAL OR
        s_grpnr[] IS NOT INITIAL.
        REFRESH lt_date.
      ENDIF.

      SELECT * FROM zgtcvordsyval
         INTO CORRESPONDING FIELDS OF TABLE gt_main
        WHERE werks EQ   p_werks
             AND dispo  LIKE lv_dispo
             AND pdcaproccode IN lt_gong_cd
             AND gstrp IN lt_date
             AND aufnr IN s_aufnr
             AND auart IN s_auart
*             AND KDAUF IN S_KDAUF
             AND matnr IN s_matnr.

    WHEN p_disp.
      SELECT * FROM zgtcvordsyval
         INTO CORRESPONDING FIELDS OF TABLE gt_main
        WHERE werks EQ   p_werks
             AND dispo  LIKE lv_dispo
             AND pdcaproccode IN lt_gong_cd
             AND gstrp IN s_gstrp.

  ENDCASE.

  SORT gt_main BY aufnr posnr.
  DELETE ADJACENT DUPLICATES FROM gt_main COMPARING aufnr posnr.

* plan 모드일시 오더 상태조회후 스케줄링 가능한 오더만 보여준다.
* 조회모드는 DLFL, CLSD, TECO 제외
  PERFORM catch_available_order TABLES gt_main.

  lt_aufnr = VALUE #( FOR lw_main IN gt_main WHERE ( aufnr IS NOT INITIAL )
                              ( sign = 'I' option = 'EQ' low = lw_main-aufnr ) ).
  SORT lt_aufnr BY low.
  DELETE ADJACENT DUPLICATES FROM lt_aufnr COMPARING low.

* 공정체인 조회하여
  IF lt_aufnr[] IS NOT INITIAL.
    SELECT * FROM zgtppt2010
        INTO TABLE gt_2010
     WHERE gong_cd IN lt_gong_cd
         AND ordnr IN lt_aufnr.
  ENDIF.
* 스케줄 수정 모드시 조정구성번호 조회조건에 있으면
* - 오더 조회 대상에서 공정코드 오더 외 제외
  IF p_plan = abap_true AND s_grpnr[] IS NOT INITIAL.
    DELETE gt_2010 WHERE grpnr NOT IN s_grpnr.
    LOOP AT gt_main ASSIGNING FIELD-SYMBOL(<ls_main>).
      READ TABLE gt_2010 TRANSPORTING NO FIELDS WITH KEY ordnr = <ls_main>-aufnr.
      IF sy-subrc NE 0.
        DELETE gt_main.
      ENDIF.
    ENDLOOP.
  ENDIF.

  DATA(lt_2010_chk) = gt_2010.
  SORT lt_2010_chk BY grpnr.
  DELETE ADJACENT DUPLICATES FROM lt_2010_chk COMPARING grpnr.

  IF lt_2010_chk IS NOT INITIAL.
    SELECT * FROM zgtppt2000
        INTO TABLE gt_2000
        FOR ALL ENTRIES IN lt_2010_chk
     WHERE grpnr = lt_2010_chk-grpnr
         AND erdat IN s_erdat.

    IF s_kdauf[] IS NOT INITIAL.
      DELETE gt_2000 WHERE ordno NOT IN s_kdauf.
    ENDIF.

  ENDIF.

* 스케줄 수정 모드시 조정표 작성일 조회조건에 있으면
* - 오더 조회 대상에서 해당 조건 확인하여 제외
  IF p_plan = abap_true AND s_erdat[] IS NOT INITIAL.
    LOOP AT gt_2010 ASSIGNING FIELD-SYMBOL(<ls_2010>).
      READ TABLE gt_2000 TRANSPORTING NO FIELDS WITH KEY grpnr = <ls_2010>-grpnr.
      IF sy-subrc NE 0.
        DELETE gt_2010.
      ENDIF.
    ENDLOOP.

    LOOP AT gt_main ASSIGNING <ls_main>.
      READ TABLE gt_2010 TRANSPORTING NO FIELDS WITH KEY ordnr = <ls_main>-aufnr.
      IF sy-subrc NE 0.
        DELETE gt_main.
      ENDIF.
    ENDLOOP.
  ENDIF.


* 설비조회
  REFRESH lt_aufnr.
  lt_aufnr = VALUE #( FOR lw_main IN gt_main WHERE ( aufnr IS NOT INITIAL )
                              ( sign = 'I' option = 'EQ' low = lw_main-aufnr ) ).

  SELECT
   a~aufnr, f~ktext, e~arbpl
   FROM afko         AS a
   INNER JOIN afvc   AS b
                           ON b~aufpl = a~aufpl
   INNER JOIN crhd  AS e
                           ON e~objid = b~arbid
   INNER JOIN crtx   AS f
                           ON f~objid = e~objid
                          AND f~objty = e~objty
   WHERE a~aufnr IN @lt_aufnr
       AND b~aplfl = '000000'
       AND b~rueck <> '0000000000'
       AND  f~spras = @sy-langu
       AND  f~objty = 'A'
      INTO CORRESPONDING FIELDS OF TABLE @gt_disp_arbpl.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ORDER_SCHEDULE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_order_schedule .

  DATA : lt_data LIKE TABLE OF gs_begin_schedule.
  DATA : lt_data2 LIKE TABLE OF gs_begin_schedule.
  DATA : ls_data_merge LIKE gs_begin_schedule.
  DATA : lv_gamng_c TYPE char20.
  DATA : lv_cal_date TYPE sy-datum.
  DATA : lv_idx TYPE sy-tabix.
  DATA : lv_chk_merge.
  DATA : lv_chk.
  DATA : ls_jojang LIKE gs_jojang.
  DATA : lv_ertim TYPE sy-uzeit.
  DATA : lv_erdat TYPE sy-datum.

  LOOP AT gt_main INTO DATA(ls_main). " WHERE AUFNR IN GT_AUFNR.
    READ TABLE lt_data TRANSPORTING NO FIELDS WITH KEY aufnr = ls_main-aufnr.
*    IF SY-SUBRC EQ 0. " 이미 저장된 라인은 추가하지 않음
*      CONTINUE.
*    ENDIF.

    APPEND INITIAL LINE TO lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).
*    설비정보
    READ TABLE gt_disp_arbpl INTO DATA(ls_arbpl) WITH KEY aufnr = ls_main-aufnr.
    IF sy-subrc EQ 0.
      <ls_data>-arbpl = ls_arbpl-arbpl.
      <ls_data>-ktext = ls_arbpl-ktext.
    ENDIF.
*  생산오더 번호
    <ls_data>-aufnr = ls_main-aufnr.
*  조장 구성표 번호 - 조장구성표 없으면 빈값
    CASE p_werks.
      WHEN '1802'.
        READ TABLE gt_2010 INTO DATA(ls_2010) WITH KEY ordnr = ls_main-aufnr.
        IF sy-subrc EQ 0.
          CONCATENATE ls_2010-pjt_cd ls_2010-lotno INTO <ls_data>-order_c SEPARATED BY space.
        ENDIF.
      WHEN OTHERS.
        READ TABLE gt_2010 INTO ls_2010 WITH KEY ordnr = ls_main-aufnr.
        IF sy-subrc EQ 0.
          <ls_data>-order_c = ls_2010-grpnr.

        ENDIF.
    ENDCASE.

    CASE p_werks.
      WHEN '1802'.
        READ TABLE gt_2010 INTO ls_2010 WITH KEY ordnr = ls_main-aufnr.
        IF sy-subrc EQ 0.
          CLEAR ls_jojang.
          ls_jojang-jojang = ls_2010-inlength.
          ls_jojang-num_jojang = ls_2010-infactor.
          APPEND ls_jojang TO <ls_data>-jojang.
        ELSE.
*   조장 구성
          PERFORM conv_int_to_char USING ls_main-millcalength
                                          CHANGING lv_gamng_c.
          CLEAR ls_jojang.
          ls_jojang-jojang = lv_gamng_c.
          PERFORM conv_int_to_char USING ls_main-millcafactor
                                          CHANGING lv_gamng_c.

          ls_jojang-jojang = ls_jojang-jojang && 'X' && lv_gamng_c.

          ls_jojang-num_jojang = 1.
          APPEND ls_jojang TO <ls_data>-jojang.

        ENDIF.
      WHEN OTHERS.
*   조장 구성
        PERFORM conv_int_to_char USING ls_main-millcalength
                                        CHANGING lv_gamng_c.
        CLEAR ls_jojang.
        ls_jojang-jojang = lv_gamng_c.
        PERFORM conv_int_to_char USING ls_main-millcafactor
                                        CHANGING lv_gamng_c.

        ls_jojang-jojang = ls_jojang-jojang && 'X' && lv_gamng_c.

        ls_jojang-num_jojang = 1.
        APPEND ls_jojang TO <ls_data>-jojang.
    ENDCASE.
*  시작일시(yyyymmddhhmmss)

    IF ls_main-gsuzp = '240000'.
      lv_erdat = ls_main-gstrp + 1.
      lv_ertim = '000001'.
    ELSE.
      lv_erdat = ls_main-gstrp.
      lv_ertim = ls_main-gsuzp + 1.
    ENDIF.
    <ls_data>-from = lv_erdat && lv_ertim.

*  종료일시(yyyymmddhhmmss)
    IF ls_main-gluzp = '000000'. " 종료시간이 000000의 경우
      CLEAR lv_cal_date.
      lv_cal_date = ls_main-gltrp + 1.
      <ls_data>-to = lv_cal_date && '000000'. " 정렬을 위해 마지막 시간으로 점해둔다.
    ELSE.
      <ls_data>-to = ls_main-gltrp && ls_main-gluzp.
    ENDIF.

  ENDLOOP.

  SORT lt_data BY arbpl ktext order_c from.

  lt_data2 = VALUE #( FOR wa_main IN lt_data WHERE ( order_c IS NOT INITIAL ) ( CORRESPONDING #( wa_main ) ) ).
  DELETE lt_data WHERE order_c IS NOT INITIAL.

  IF s_kdauf[] IS NOT INITIAL.
    REFRESH lt_data.
  ENDIF.

*  최종 스케줄 라인 머지
  REFRESH gt_begin_schedule.
  CLEAR ls_data_merge.

  LOOP AT lt_data2 INTO DATA(ls_data).
    CLEAR : lv_chk_merge, lv_chk.
    lv_idx = sy-tabix.
    IF lv_idx = 1.
      MOVE-CORRESPONDING ls_data TO ls_data_merge.
      IF lines( lt_data2 ) = 1. " 최종라인이 1이라면 바로 종료
        PERFORM set_line CHANGING ls_data_merge.
        EXIT.
      ELSE.
        CONTINUE.
      ENDIF.
    ENDIF.

* 같은 속성(조장구성표, 오더) 끼리는 서로 머지 가능
    IF ls_data-order_c IS NOT INITIAL AND
       ls_data-order_c = ls_data_merge-order_c AND " 같은 조장구성표
      ls_data-arbpl = ls_data_merge-arbpl.
      lv_chk_merge = abap_true.
    ENDIF.

    IF ls_data-order_c IS INITIAL AND
      ls_data_merge-order_c IS INITIAL AND " 오더대상 서로 비교
      ls_data-arbpl = ls_data_merge-arbpl.
      lv_chk_merge = abap_true.
    ENDIF.

    IF lv_chk_merge IS NOT INITIAL. " 병합 가능한 대상인지 확인
      PERFORM merge_line USING ls_data CHANGING ls_data_merge lv_chk.
      IF lv_chk IS INITIAL.
*    비교대상 라인 업데이트
        PERFORM set_line CHANGING ls_data_merge.
        CLEAR ls_data_merge.
        MOVE-CORRESPONDING ls_data TO ls_data_merge.
      ENDIF.

    ELSE.
*    비교대상 라인 업데이트
      PERFORM set_line CHANGING ls_data_merge.
      CLEAR ls_data_merge.
      MOVE-CORRESPONDING ls_data TO ls_data_merge.
    ENDIF.


    IF lv_idx = lines( lt_data2 ). " 최종라인일시 업데이트 기능
      PERFORM set_line CHANGING ls_data_merge.
    ENDIF.

  ENDLOOP.


  LOOP AT lt_data INTO ls_data.
    CLEAR : lv_chk_merge, lv_chk.
    lv_idx = sy-tabix.
    IF lv_idx = 1.
      MOVE-CORRESPONDING ls_data TO ls_data_merge.
      IF lines( lt_data ) = 1. " 최종라인이 1이라면 바로 종료
        PERFORM set_line CHANGING ls_data_merge.
        EXIT.
      ELSE.
        CONTINUE.
      ENDIF.
    ENDIF.

* 같은 속성(조장구성표, 오더) 끼리는 서로 머지 가능
    IF ls_data-order_c IS NOT INITIAL AND
       ls_data-order_c = ls_data_merge-order_c AND " 같은 조장구성표
      ls_data-arbpl = ls_data_merge-arbpl.

      lv_chk_merge = abap_true.
    ENDIF.

    IF ls_data-order_c IS INITIAL AND
      ls_data_merge-order_c IS INITIAL AND " 오더대상 서로 비교
      ls_data-arbpl = ls_data_merge-arbpl.
      lv_chk_merge = abap_true.
    ENDIF.

    IF lv_chk_merge IS NOT INITIAL. " 병합 가능한 대상인지 확인
      PERFORM merge_line USING ls_data CHANGING ls_data_merge lv_chk.
      IF lv_chk IS INITIAL.
*    비교대상 라인 업데이트
        PERFORM set_line CHANGING ls_data_merge.
        CLEAR ls_data_merge.
        MOVE-CORRESPONDING ls_data TO ls_data_merge.
      ENDIF.

    ELSE.
*    비교대상 라인 업데이트
      PERFORM set_line CHANGING ls_data_merge.
      CLEAR ls_data_merge.
      MOVE-CORRESPONDING ls_data TO ls_data_merge.
    ENDIF.


    IF lv_idx = lines( lt_data ). " 최종라인일시 업데이트 기능
      PERFORM set_line CHANGING ls_data_merge.
    ENDIF.

  ENDLOOP.

  DELETE gt_begin_schedule WHERE fieldname IS INITIAL.
  LOOP AT gt_begin_schedule ASSIGNING FIELD-SYMBOL(<ls_schedule>).
    IF <ls_schedule>-chk_dup IS NOT INITIAL.
      <ls_schedule>-order_c = '**Dup**' && <ls_schedule>-order_c.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CATCH_AVAILABLE_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MAIN
*&---------------------------------------------------------------------*
FORM catch_available_order  TABLES   pt_main STRUCTURE zgtcvordsyval.

  DATA : lt_tj02t LIKE tj02t OCCURS 0 WITH HEADER LINE.
  DATA : lv_stcd TYPE zordstcd.
  DATA : lv_objnr TYPE jest-objnr.
  DATA : lv_user_line TYPE bsvx-sttxt.


  LOOP AT pt_main.
*    상태값 조회
    CLEAR lv_stcd.
    REFRESH lt_tj02t.
    CALL FUNCTION 'Z_PP_RETURN_ORDER_STATUS'
      EXPORTING
        im_aufnr        = pt_main-aufnr
      IMPORTING
        ex_ostcd        = lv_stcd
      TABLES
        et_sttxt        = lt_tj02t
      EXCEPTIONS
        no_selection    = 1
        not_found_objnr = 2
        OTHERS          = 3.

    CASE lv_stcd.
      WHEN 'E' OR 'Z'.
        DELETE pt_main.
        CONTINUE.
*      WHEN 'D' OR 'G' OR 'F'. " OR 'C'.
*        IF P_PLAN = ABAP_TRUE. " 일정수립 모드시 생성중인 오더는 제외
*          DELETE PT_MAIN.
*          CONTINUE.
*        ENDIF.
      WHEN OTHERS.
    ENDCASE.

*    유저스테이터스 조회 - 전부 보여주게 바꿈 20250219
*    CLEAR : LV_OBJNR, LV_USER_LINE.
*    LV_OBJNR = 'OR' && PT_MAIN-AUFNR.
*    CALL FUNCTION 'STATUS_TEXT_EDIT'
*      EXPORTING
*        FLG_USER_STAT    = 'X'
*        OBJNR            = LV_OBJNR
*        ONLY_ACTIVE      = 'X'
*        SPRAS            = SY-LANGU
*      IMPORTING
*        USER_LINE        = LV_USER_LINE
*      EXCEPTIONS
*        OBJECT_NOT_FOUND = 1
*        OTHERS           = 2.
*
*    FIND ALL OCCURRENCES OF 'PAYO' IN LV_USER_LINE MATCH COUNT FINAL(LV_LINE).
*    IF LV_LINE > 0.
*      DELETE PT_MAIN.
*      CONTINUE.
*    ENDIF.


  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_SCHEDULE_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_schedule_table .

  DATA : lv_col_pos TYPE i.
  DATA : ls_fcat TYPE lvc_s_fcat.
  DATA : lv_date TYPE sy-datum.
  DATA : lv_num(2) TYPE n.
  DATA : lv_fieldname TYPE fieldname.

  DEFINE __set_fieldcat.
    CLEAR ls_fcat.
    ls_fcat-fieldname = &1.
    ls_fcat-reptext = ls_fcat-coltext = ls_fcat-tooltip = &2.
    ADD 1 TO lv_col_pos.
    ls_fcat-col_pos = lv_col_pos.
    ls_fcat-datatype = &3.
    ls_fcat-dd_outlen = &4.
    ls_fcat-outputlen = &5.
    ls_fcat-just = &6.
    APPEND ls_fcat TO gt_fieldcat_set_merge.
  END-OF-DEFINITION.

  REFRESH gt_fieldcat_set_merge.

  __set_fieldcat : 'KTEXT' 'KTEXT' 'CHAR' '40' '20' 'L'.
  READ TABLE gt_fieldcat_set_merge ASSIGNING FIELD-SYMBOL(<ls_fcat>) WITH KEY fieldname = 'KTEXT'.
  <ls_fcat>-key = abap_true.
*  __SET_FIELDCAT : 'TEMP' 'TEMP' 'CHAR' '40' '20' 'L'.
*  READ TABLE GT_FIELDCAT_SET_MERGE ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'TEMP'.
*  <LS_FCAT>-NO_OUT = ABAP_TRUE.

  lv_date = s_gstrp-low - 1.
  DO.
    IF lv_date > s_gstrp-high.
      EXIT.
    ENDIF.

    CLEAR lv_num.
    DO.
      ADD 1 TO lv_num.
      IF lv_num > 4.
        EXIT.
      ENDIF.

      lv_fieldname = lv_date && '_' && lv_num.
      __set_fieldcat : lv_fieldname lv_fieldname 'CHAR' '100' '4' 'L'.
    ENDDO.

    lv_date = lv_date + 1.
  ENDDO.

* 인터널테이블 생성
  FREE gt_set_schedule.

  cl_alv_table_create=>create_dynamic_table(
    EXPORTING
*      I_STYLE_TABLE       = ABAP_TRUE
      it_fieldcatalog           = gt_fieldcat_set_merge                " Field Catalog
    IMPORTING
      ep_table                  = gt_set_schedule                 " Pointer to Dynamic Data Table
    EXCEPTIONS
      generate_subpool_dir_full = 1                " At Most 36 Subroutine Pools Can Be Generated Temporarily
      OTHERS                    = 2
  ).
  IF sy-subrc <> 0.
  ENDIF.

  ASSIGN gt_set_schedule->* TO <gt_set_schedule>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form TOOLBAR_PROS
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
    WHEN go_grid_0200.

      PERFORM set_toolbar TABLES po_object->mt_toolbar
                           USING : ' ' ' ' ' ' ' ' 3,
                                      'MARKING' icon_checkbox '체크'(i01) '체크'(i01) 0,
                                      'ALLSEL' icon_select_all '전체선택'(i02) '전체선택'(i02) 0,
                                      'DESEL' icon_deselect_all '선택해제'(i03) '선택해제'(i03) 0,
                                      ' ' ' ' ' ' ' ' 3,
                                      'CR_ORDER' icon_create '생산오더 생성'(i04) '생산오더 생성'(i04) 0,
                                      'CR_SI_ORDER' icon_create '시작업오더 생성'(i12) '시작업오더 생성'(i12) 0,
                                      'CR_RP_ORDER' icon_create '재생산오더 생성'(i13) '재생산오더 생성'(i13) 0,
                                      'DEL_ORDER' icon_delete '오더 삭제'(i05) '오더 삭제'(i05) 0.

    WHEN go_grid_0300.
      PERFORM set_toolbar TABLES po_object->mt_toolbar
                                 USING : ' ' ' ' ' ' ' ' 3,
                                            'MARKING' icon_checkbox '체크'(i01) '체크'(i01) 0,
                                            'ALLSEL' icon_select_all '전체선택'(i02) '전체선택'(i02) 0,
                                            'DESEL' icon_deselect_all '선택해제'(i03) '선택해제'(i03) 0,
                                            ' ' ' ' ' ' ' ' 3,
                                            'RELEASE' icon_release '생산오더 릴리즈'(i06) '생산오더 릴리즈'(i06) 0,
                                            ' ' ' ' ' ' ' ' 3,
                                            'CHG_BATCH' icon_tools '설비변경'(i07) '설비변경'(i07) 0,
                                            'CHG_PLAN_FR' icon_date '일정변경(시작일)'(i08) '일정변경(시작일)'(i08) 0,
                                            'CHG_PLAN_TO' icon_date '일정변경(종료일)'(i09) '일정변경(종료일)'(i09) 0,
                                            'SHIFT_PLAN' icon_set_state '일정 Shift'(i10) '일정 Shift'(i10) 0,
                                            ' ' ' ' ' ' ' ' 3,
                                            'REFRESH' icon_toggle_display_change '수정사항 적용'(i11) '수정사항 적용'(i11) 0.
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
    CONCATENATE ' '  pv_text ' '  INTO ls_toolbar-text SEPARATED BY space.
  ENDIF.
  ls_toolbar-quickinfo = pv_quickinfo.
  ls_toolbar-butn_type = pv_butn_type.
  APPEND ls_toolbar TO pt_toolbar.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND_PROS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM user_command_pros  USING   po_sender  TYPE REF TO cl_gui_alv_grid
                                 pv_ucomm.

  CASE po_sender.
    WHEN go_grid_0200.
      CASE pv_ucomm.
        WHEN 'CR_ORDER'.
          PERFORM create_prd_order USING pv_ucomm.
        WHEN 'CR_SI_ORDER'.
          PERFORM create_prd_order USING pv_ucomm.
        WHEN 'CR_RP_ORDER'. "2026.07.22.zlsgpp5.SRM2607-09012.
          PERFORM create_prd_order USING pv_ucomm.
        WHEN 'DEL_ORDER'.
          PERFORM delete_prd_order.
        WHEN 'ALLSEL'.
          PERFORM process_allselect USING go_grid_0200.
        WHEN 'DESEL'.
          PERFORM process_deselect USING go_grid_0200.
        WHEN 'MARKING'.
          PERFORM process_marking.

      ENDCASE.
    WHEN go_grid_0300.
      CASE pv_ucomm.
        WHEN 'CHG_BATCH'.
          PERFORM change_batch.
        WHEN 'CHG_PLAN_FR'.
          PERFORM change_plan USING 'FR'.
        WHEN 'CHG_PLAN_TO'.
          PERFORM change_plan USING 'TO'.
        WHEN 'SHIFT_PLAN'.
          PERFORM shift_plan.
        WHEN 'REFRESH'.
          PERFORM save_and_refresh.
        WHEN 'RELEASE'.
          PERFORM release_prd_order.
        WHEN 'ALLSEL'.
          PERFORM process_allselect_300 USING go_grid_0300.
        WHEN 'DESEL'.
          PERFORM process_deselect_300 USING go_grid_0300.
        WHEN 'MARKING'.
          PERFORM process_marking_0300.
      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> ER_DATA_CHANGED
*&      --> E_ONF4
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM data_changed  USING   p_sender  TYPE REF TO cl_gui_alv_grid
                                po_data_changed TYPE REF TO
                                          cl_alv_changed_data_protocol
                                pe_onf4
                                pe_ucomm.

  DATA: ls_mod_cells TYPE lvc_s_modi.
  DATA : lv_call_func.
  DATA : lv_chk_err.
  DATA : lv_ktext TYPE crtx-ktext.
  DATA : lv_time TYPE sy-uzeit.
  DATA : lv_time_hhmm TYPE atim.

  DEFINE __set_err_msg.
    lv_chk_err = abap_true.
    po_data_changed->add_protocol_entry(
        i_msgid     = 'ZGTPP00'                 " Message ID
        i_msgty     = 'E'                 " Message Type
        i_msgno     =  '03'                " Message No.
        i_msgv1     =  &1                " Message Variable1
        i_fieldname =  &2                " Field Name
        i_row_id    =  ls_mod_cells-row_id ).                " RowID
  END-OF-DEFINITION.

  DEFINE __modi_cell.
    po_data_changed->modify_cell(
      i_row_id     = &1                 " Row ID
      i_fieldname = &2                 " Field Name
      i_value       = &3 ).               " Value
  END-OF-DEFINITION.

  CASE p_sender.
    WHEN go_grid_0200 OR go_grid_0410.
      LOOP AT po_data_changed->mt_good_cells INTO ls_mod_cells.
        CASE ls_mod_cells-fieldname.
          WHEN 'CHECK'.
            gv_chk_line = ls_mod_cells-row_id.
            gv_chk_value = ls_mod_cells-value.
            lv_call_func = abap_true.
        ENDCASE.
      ENDLOOP.
    WHEN go_grid_0300.
      LOOP AT po_data_changed->mt_good_cells INTO ls_mod_cells.
        CASE ls_mod_cells-fieldname.
          WHEN 'ARBPL'.
            READ TABLE gt_detail INTO DATA(ls_chk_detail) INDEX ls_mod_cells-row_id.

            PERFORM check_arbpl USING ls_mod_cells-value ls_chk_detail-matnr CHANGING lv_ktext lv_chk_err.
            IF lv_chk_err IS INITIAL.
              __modi_cell ls_mod_cells-row_id 'KTEXT' lv_ktext.
              __modi_cell ls_mod_cells-row_id 'CHG_ARBPL' 'X'.
              __modi_cell ls_mod_cells-row_id 'STATUS'  icon_change .
            ELSE.
              __set_err_msg '유효하지 않은 설비입니다.' ls_mod_cells-fieldname.
              __modi_cell ls_mod_cells-row_id 'STATUS' icon_led_red.
            ENDIF.
          WHEN 'GSTRP'.
            __modi_cell ls_mod_cells-row_id 'CHG_PLAN' 'X'.
            __modi_cell ls_mod_cells-row_id 'STATUS'  icon_change .
          WHEN 'GSUZP_HHMM'.
            IF ls_mod_cells-error IS INITIAL.
              CLEAR lv_time.
              CALL FUNCTION 'CONVERSION_EXIT_HH_MM_INPUT'
                EXPORTING
                  input        = ls_mod_cells-value
                IMPORTING
                  output       = lv_time_hhmm
                EXCEPTIONS
                  time_invalid = 1
                  OTHERS       = 2.
              IF sy-subrc <> 0.
* Implement suitable error handling here
              ENDIF.

              lv_time = lv_time_hhmm && '00'.
              __modi_cell ls_mod_cells-row_id 'GSUZP' lv_time.
              __modi_cell ls_mod_cells-row_id 'CHG_PLAN' 'X'.
              __modi_cell ls_mod_cells-row_id 'STATUS'  icon_change .
            ENDIF.
          WHEN 'GLTRP'.
            __modi_cell ls_mod_cells-row_id 'CHG_PLAN' 'X'.
            __modi_cell ls_mod_cells-row_id 'STATUS'  icon_change .
          WHEN 'GLUZP_HHMM'.
            IF ls_mod_cells-error IS INITIAL.
              CLEAR lv_time.
              CALL FUNCTION 'CONVERSION_EXIT_HH_MM_INPUT'
                EXPORTING
                  input        = ls_mod_cells-value
                IMPORTING
                  output       = lv_time_hhmm
                EXCEPTIONS
                  time_invalid = 1
                  OTHERS       = 2.
              IF sy-subrc <> 0.
* Implement suitable error handling here
              ENDIF.

              lv_time = lv_time_hhmm && '00'.
              __modi_cell ls_mod_cells-row_id 'GLUZP' lv_time.
              __modi_cell ls_mod_cells-row_id 'CHG_PLAN' 'X'.
              __modi_cell ls_mod_cells-row_id 'STATUS'  icon_change .
            ENDIF.
          WHEN 'ZZPRIORITY'.
            __modi_cell ls_mod_cells-row_id 'CHG_PIROTY' 'X'.
            __modi_cell ls_mod_cells-row_id 'STATUS'  icon_change .
        ENDCASE.
      ENDLOOP.
  ENDCASE.

  IF lv_chk_err IS NOT INITIAL.
    po_data_changed->display_protocol( ).
  ELSE.

    IF lv_call_func IS NOT INITIAL.
      CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
        EXPORTING
          functioncode           = 'SETCHECK'              " Function code
        EXCEPTIONS
          function_not_supported = 1                " Not supported on this front end platform
          OTHERS                 = 2.
      IF sy-subrc <> 0.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM alv_top_of_page  USING    po_sender TYPE REF TO cl_gui_alv_grid
                               pv_dyndoc_id  TYPE REF TO  cl_dd_document.

  CASE po_sender.
    WHEN go_grid_0200.
      PERFORM set_title_0200 CHANGING pv_dyndoc_id.
    WHEN go_grid_0300.
      PERFORM set_title_0300 CHANGING pv_dyndoc_id.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM double_click  USING p_sender TYPE REF TO cl_gui_alv_grid
                            p_row TYPE lvc_s_row
                            p_column TYPE lvc_s_col.

  CASE p_sender.
    WHEN go_grid_0200.
      READ TABLE gt_grpnr INTO DATA(ls_grpnr) INDEX p_row-index.
      CASE p_column-fieldname.
        WHEN 'ORDNO_C'.
          IF ls_grpnr-gcatg = '판매오더'.
            SET PARAMETER ID 'AUN' FIELD ls_grpnr-ordno.
            CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
          ELSE.
            SET PARAMETER ID 'ANR' FIELD ls_grpnr-ordno.
            CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
          ENDIF.
        WHEN 'MATNR'.
          SET PARAMETER ID 'WRK' FIELD p_werks.
          SET PARAMETER ID 'MXX' FIELD 'K'.
          SET PARAMETER ID 'MAT' FIELD ls_grpnr-matnr..
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
      ENDCASE.
    WHEN go_grid_0300.
      READ TABLE gt_detail INTO DATA(ls_detail) INDEX p_row-index.
      CASE p_column-fieldname.
        WHEN 'ORDNO'.
          SET PARAMETER ID 'ANR' FIELD ls_detail-ordno.
          CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
        WHEN 'MATNR' .
          SET PARAMETER ID 'WRK' FIELD p_werks.
          SET PARAMETER ID 'MXX' FIELD 'K'.
          SET PARAMETER ID 'MAT' FIELD ls_detail-matnr..
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
        WHEN 'MATNR_SO' .
          SET PARAMETER ID 'WRK' FIELD p_werks.
          SET PARAMETER ID 'MXX' FIELD 'K'.
          SET PARAMETER ID 'MAT' FIELD ls_detail-matnr_so..
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
      ENDCASE.
  ENDCASE.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONV_INT_TO_CHAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MAIN_MILLCALENGTH
*&      <-- LV_INLENGTH_C
*&---------------------------------------------------------------------*
FORM conv_int_to_char  USING    pv_numc
                       CHANGING pv_char.

  DATA : lv_num_i TYPE i.
  DATA : lv_num_c(20).

  lv_num_i = pv_numc + 0.

  lv_num_c = lv_num_i.
  CONDENSE lv_num_c.
  pv_char = lv_num_c.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LS_DATA_MERGE
*&---------------------------------------------------------------------*
FORM set_line  CHANGING ps_data LIKE gs_begin_schedule.

  DATA : lv_string TYPE string.
  DATA : lv_num_c(12) TYPE c.
  DATA : lv_date TYPE sy-datum.
  DATA : lv_date_new TYPE sy-datum.
  DATA : lv_time TYPE sy-uzeit.
  DATA : lv_time_new TYPE sy-uzeit.
  DATA : lv_fieldname TYPE fieldname.
  DATA : lv_num(2) TYPE n.
  DATA : ls_split_line LIKE gs_begin_schedule.
  DATA : lv_maktx TYPE maktx.


  IF ps_data-order_c IS INITIAL. "ORDER_C 값이 없으면 오더단위
    ps_data-order_c = ps_data-aufnr.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ps_data-order_c
      IMPORTING
        output = ps_data-order_c.

    CLEAR lv_string.
    IF ps_data-num NE 0.
      lv_num_c = ps_data-num.
      CONDENSE lv_num_c.
      CONCATENATE ps_data-order_c '외' lv_num_c INTO ps_data-order_c SEPARATED BY space.
    ENDIF.
  ELSE.
    READ TABLE gt_2000 INTO DATA(ls_2000) WITH KEY grpnr = ps_data-order_c.
    CLEAR lv_maktx.
    lv_maktx = zgtpp_cl_common=>get_maktx( iv_matnr = ls_2000-matnr ).
    ps_data-order_c = lv_maktx && '(' && ps_data-order_c && ')'.
  ENDIF.


  LOOP AT ps_data-jojang INTO DATA(ls_jojang).
    IF ps_data-jojang_c IS NOT INITIAL.
      CONCATENATE ps_data-jojang_c ',' INTO ps_data-jojang_c.
    ENDIF.

    CLEAR lv_string.
    CLEAR lv_num_c.
    lv_num_c = ls_jojang-num_jojang.
    CONDENSE lv_num_c.
    CONCATENATE ls_jojang-jojang '(' lv_num_c ')' INTO lv_string.
    CONCATENATE ps_data-jojang_c lv_string INTO ps_data-jojang_c SEPARATED BY space.
  ENDLOOP.


* 선행 입력된 오더에 대해 체크
  LOOP AT gt_begin_schedule ASSIGNING FIELD-SYMBOL(<ls_schedule>) WHERE arbpl = ps_data-arbpl.
    "생산시작일이 비교대상 이전일시
    IF ps_data-from <= <ls_schedule>-from.
*    생산종료일이 비교대상 시작일 이전이라면 머지대상 아님
      IF ps_data-to < <ls_schedule>-from.

*    생산종료일이 비교대상 시작일과 종료일 사이라면 생상종료일을 비교대상 이전 시간대로 변경
      ELSEIF ps_data-to BETWEEN <ls_schedule>-from AND <ls_schedule>-to.

        PERFORM set_date_with_gubun USING '1' <ls_schedule>-from CHANGING ps_data-to.
*      이전 시간대로 변경된 데이터가 시작일 이전인지 확인 시작일 이전일시 업데이트 없음
        IF ps_data-from >= ps_data-to.
          <ls_schedule>-chk_dup = abap_true.
          RETURN.
        ENDIF.
*    생산종료일이 비교대상 종료일 보다 크면 이전기록 삭제후 현재오더로 변경
      ELSEIF ps_data-to > <ls_schedule>-to.
        DELETE gt_begin_schedule.
        CONTINUE.
      ENDIF.
    ENDIF.


    "생산시작일이 비교대상 시작일과 종료일 사이라면
    IF ps_data-to BETWEEN <ls_schedule>-from AND <ls_schedule>-to.
*    생산종료일이 비교대상 시작일과 종료일 사이라면 스케줄 업데이트 없음
      IF ps_data-to BETWEEN <ls_schedule>-from AND <ls_schedule>-to.
        <ls_schedule>-chk_dup = abap_true.
        RETURN.
*    생산종료일이 비교대상 종료일 보다 크면 시작일 변경
      ELSEIF ps_data-to > <ls_schedule>-to.
        PERFORM set_date_with_gubun USING '2' <ls_schedule>-to CHANGING ps_data-from.
      ENDIF.
    ENDIF.
  ENDLOOP.

*  from line
  CLEAR : lv_fieldname, lv_date, lv_time.
  lv_date = ps_data-from+0(8).
  lv_time = ps_data-from+8(6).
  IF lv_time BETWEEN '000000' AND '060000'.
    lv_num = 1.
  ELSEIF lv_time BETWEEN '060000' AND '120000'.
    lv_num = 2.
  ELSEIF lv_time BETWEEN '120000' AND '180000'.
    lv_num = 3.
  ELSEIF lv_time BETWEEN '180000' AND '240000'.
    lv_num = 4.
  ENDIF.
  CONCATENATE lv_date '_' lv_num INTO lv_fieldname.

  READ TABLE gt_fieldcat_set_merge TRANSPORTING NO FIELDS WITH KEY fieldname = lv_fieldname.
  IF sy-subrc EQ 0.
    ps_data-fromline = sy-tabix.
    ps_data-fieldname = lv_fieldname.
  ENDIF.

*  to line
  CLEAR : lv_fieldname, lv_date, lv_time.
  lv_date = ps_data-to+0(8).
  lv_time = ps_data-to+8(6).

  IF lv_date > s_gstrp-high.
    lv_date = s_gstrp-high.
  ENDIF.

  IF lv_time = '000000'.
    lv_date = lv_date - 1.
    lv_num = 4.
  ELSEIF lv_time BETWEEN '000001' AND '060000'.
    lv_num = 1.
  ELSEIF lv_time BETWEEN '060000' AND '120000'.
    lv_num = 2.
  ELSEIF lv_time BETWEEN '120000' AND '180000'.
    lv_num = 3.
  ELSEIF lv_time BETWEEN '180000' AND '240000'.
    lv_num = 4.
  ENDIF.

  CONCATENATE lv_date '_' lv_num INTO lv_fieldname.
  READ TABLE gt_fieldcat_set_merge TRANSPORTING NO FIELDS WITH KEY fieldname = lv_fieldname.
  IF sy-subrc EQ 0.
    ps_data-toline = sy-tabix.
  ENDIF.

  APPEND ps_data TO gt_begin_schedule.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form merge_line
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_DATA
*&      <-- LS_DATA_MERGE
*&---------------------------------------------------------------------*
FORM merge_line  USING   ps_data LIKE gs_begin_schedule
                      CHANGING   ps_merge LIKE gs_begin_schedule
                                      pv_chk.

  CLEAR pv_chk.
  "생산시작일이 비교대상 이전일시
  IF ps_data-from <= ps_merge-from.
*    생산종료일이 비교대상 시작일 이전이라면 머지대상 아님
    IF ps_data-to < ps_merge-from.

*    생산종료일이 비교대상 시작일과 종료일 사이라면 생산시작일을 더 이전으로 변경
    ELSEIF ps_data-to BETWEEN ps_merge-from AND ps_merge-to.
      ps_merge-from = ps_data-from.
      pv_chk = abap_true.
*    생산종료일이 비교대상 종료일 보다 크면 시작일과 종료일 동시 변경
    ELSEIF ps_data-to > ps_merge-to.
      ps_merge-from = ps_data-from.
      ps_merge-to = ps_data-to.
      pv_chk = abap_true.
    ENDIF.
  ENDIF.


  "생산시작일이 비교대상 시작일과 종료일 사이라면
  IF ps_data-to BETWEEN ps_merge-from AND ps_merge-to.
*    생산종료일이 비교대상 시작일과 종료일 사이라면 머지는 되나 날짜변경없음
    IF ps_data-to BETWEEN ps_merge-from AND ps_merge-to.
      pv_chk = abap_true.
*    생산종료일이 비교대상 종료일 보다 크면 종료일 변경
    ELSEIF ps_data-to > ps_merge-to.
      ps_merge-to = ps_data-to.
      pv_chk = abap_true.
    ENDIF.
  ENDIF.

  IF pv_chk IS NOT INITIAL.
    IF ps_merge-order_c IS INITIAL. " 오더 대상일경우 수량만 add
      ADD 1 TO ps_merge-num.
    ENDIF.

    READ TABLE ps_data-jojang INTO DATA(ls_jojang) INDEX 1.
    READ TABLE ps_merge-jojang ASSIGNING FIELD-SYMBOL(<ls_jojang>) WITH KEY jojang = ls_jojang-jojang.
    IF sy-subrc EQ 0.
      ADD 1 TO <ls_jojang>-num_jojang.
    ELSE.
      APPEND INITIAL LINE TO ps_merge-jojang ASSIGNING <ls_jojang>.
      MOVE-CORRESPONDING ls_jojang TO <ls_jojang>.
    ENDIF.

  ENDIF.


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


  CREATE OBJECT go_contain_merge
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

  CREATE OBJECT go_grid_merge
    EXPORTING
      i_parent = go_contain_merge.
*      I_APPL_EVENTS = ABAP_TRUE.

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

  CLEAR gs_layout_merge.
  gs_layout_merge-stylefname = 'CELL'.
  gs_layout_merge-no_headers = 'X'.
  gs_layout_merge-cwidth_opt = ' '.
  gs_layout_merge-no_toolbar = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0100_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_grid_0100_display .

  PERFORM make_disp_grid_0100.

  CALL METHOD go_grid_merge->set_table_for_first_display
    EXPORTING
*     IS_VARIANT      = GS_VARIANT_MERGE
      is_layout       = gs_layout_merge
    CHANGING
      it_fieldcatalog = gt_fieldcat_set_merge
      it_outtab       = <gt_set_schedule>.

  go_grid_merge->set_ready_for_input( 1 ).
*  CALL METHOD GO_GRID_MERGE->Z_LVC_TABLE_FILL
*    EXPORTING
*      LASTLINE = LINES( <GT_SET_SCHEDULE> ).

  PERFORM set_merge USING go_grid_merge.
  go_grid_merge->z_display( ).

  go_grid_merge->z_set_fixed_col_row(
    col = 1
    row = 1
  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DISP_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_disp_grid_0100 .

*  TITLE
  REFRESH <gt_set_schedule>.
  PERFORM make_title.

*  body
  PERFORM make_body.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_TITLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_title .

  DATA : lv_idx TYPE i.
  DATA : lv_idx2 TYPE i.
  DATA : lv_pre_date TYPE sy-datum.
  DATA : lv_date TYPE sy-datum.
  DATA : lt_attr TYPE TABLE OF casdayattr.
  DATA : lv_text(100).
  DATA : lv_daytext(10).
  DATA : BEGIN OF ls_style_seq,
           index  TYPE i,
           style  TYPE lvc_style,
           style2 TYPE lvc_style,
         END OF ls_style_seq.
  DATA : lt_style_seq LIKE TABLE OF ls_style_seq.
  DATA : lv_style TYPE lvc_style.
  DATA : lv_style2 TYPE lvc_style.

  lv_style = alv_style_font_bold + alv_style_align_center_center + alv_style_color_int_heading.
  lv_style2 = alv_style_font_bold + alv_style_align_center_center + alv_style_color_inv_negative.

  FIELD-SYMBOLS : <lv_value> TYPE any.

  DEFINE __set_merge_tab.
    CLEAR gs_col_merge.
    gs_col_merge-col_id = &1.
    gs_col_merge-outputlen = &2.
    APPEND gs_col_merge TO gt_col_merge.
  END-OF-DEFINITION.

  DEFINE __set_style.
    CLEAR ls_style_seq.
    ls_style_seq-index = &1.
    ls_style_seq-style = &2.
    ls_style_seq-style2 = &3.
    APPEND ls_style_seq TO lt_style_seq.
  END-OF-DEFINITION.

  REFRESH gt_tab_merge.
  REFRESH gt_col_merge.

  lv_pre_date = s_gstrp-low - 1.
* 요일 찾아오는 펑션
  CALL FUNCTION 'DAY_ATTRIBUTES_GET'
    EXPORTING
      factory_calendar           = 'LG'
      holiday_calendar           = 'LS'
      date_from                  = lv_pre_date
      date_to                    = s_gstrp-high
      language                   = sy-langu
    TABLES
      day_attributes             = lt_attr
    EXCEPTIONS
      factory_calendar_not_found = 1
      holiday_calendar_not_found = 2
      date_has_invalid_format    = 3
      date_inconsistency         = 4
      OTHERS                     = 5.
  IF sy-subrc <> 0.
  ENDIF.

  APPEND INITIAL LINE TO <gt_set_schedule> ASSIGNING FIELD-SYMBOL(<ls_schedule>).
* 설비
  lv_idx = 1.
  IF <lv_value> IS ASSIGNED. UNASSIGN <lv_value>. ENDIF.
  ASSIGN COMPONENT lv_idx OF STRUCTURE <ls_schedule> TO <lv_value>.
  IF <lv_value> IS ASSIGNED.
    <lv_value> = '설비'.
  ENDIF.

  __set_style lv_idx lv_style ' '.

  lv_idx = 2.

  LOOP AT lt_attr INTO DATA(ls_attr).
    CLEAR : lv_text, lv_daytext.
    lv_text = ls_attr-date+0(4) && '-' && ls_attr-date+4(2) && '-' && ls_attr-date+6(2).
    lv_daytext = '(' && ls_attr-weekday_s && ')'.
    CONCATENATE lv_text lv_daytext INTO lv_text SEPARATED BY space.
    IF ls_attr-freeday IS NOT INITIAL.
      lv_text = '*' && lv_text.
    ENDIF.

* 날짜입력
    IF <lv_value> IS ASSIGNED. UNASSIGN <lv_value>. ENDIF.
    ASSIGN COMPONENT lv_idx OF STRUCTURE <ls_schedule> TO <lv_value>.
    IF <lv_value> IS ASSIGNED.
      <lv_value> = lv_text.
    ENDIF.

    lv_idx2 = lv_idx + 3.
    __set_merge_tab lv_idx lv_idx2.
    IF ls_attr-freeday IS NOT INITIAL.
      __set_style lv_idx lv_style2 ' '.
    ELSE.
      __set_style lv_idx lv_style ' '.
    ENDIF.
    lv_idx = lv_idx + 4.
  ENDLOOP.

  APPEND INITIAL LINE TO gt_tab_merge ASSIGNING FIELD-SYMBOL(<ls_tab_merge>).
  <ls_tab_merge>-col_id = 1.
  <ls_tab_merge>-merge_horiz = gt_col_merge.
  <ls_tab_merge>-style = lt_style_seq.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_BODY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_body .

  DATA : ls_201_01 TYPE REF TO data. " 아이템 2줄로 추가를 위해 아이템 필드 2개 구성
  DATA : ls_201_02 TYPE REF TO data. " 아이템 2줄로 추가를 위해 아이템 필드 2개 구성
  DATA : lv_idx_line01 TYPE i.
  DATA : lv_idx_line02 TYPE i.
  DATA : lv_line01_merge LIKE gs_tab_merge.
  DATA : lv_line02_merge LIKE gs_tab_merge.
  DATA : lv_style TYPE lvc_style.
  DATA : lv_style2 TYPE lvc_style.

  DATA : BEGIN OF ls_style_seq,
           index  TYPE i,
           style  TYPE lvc_style,
           style2 TYPE lvc_style,
         END OF ls_style_seq.
  DATA : lt_style_seq LIKE TABLE OF ls_style_seq.

  FIELD-SYMBOLS : <ls_line01> TYPE any, " 1번라인
                  <ls_line02> TYPE any. " 2번 라인

  FIELD-SYMBOLS : <lv_value01> TYPE any, " 1번 필드 밸류
                  <lv_value02> TYPE any. " 2번 필드밸슈

  DEFINE __set_field_of_line.
    IF <lv_value01> IS ASSIGNED. UNASSIGN <lv_value01>. ENDIF.
    ASSIGN COMPONENT &1 OF STRUCTURE <ls_line01> TO <lv_value01>.
    IF <lv_value02> IS ASSIGNED. UNASSIGN <lv_value02>. ENDIF.
    ASSIGN COMPONENT &1 OF STRUCTURE <ls_line02> TO <lv_value02>.
  END-OF-DEFINITION.

  DEFINE __set_merge_tab.
    CLEAR gs_col_merge.
    gs_col_merge-col_id = &1.
    gs_col_merge-outputlen = &2.
    APPEND gs_col_merge TO gt_col_merge.
  END-OF-DEFINITION.

  DEFINE __set_style.
    CLEAR ls_style_seq.
    ls_style_seq-index = &1.
    ls_style_seq-style = &2.
    ls_style_seq-style2 = &3.
    APPEND ls_style_seq TO lt_style_seq.
  END-OF-DEFINITION.

  CREATE DATA ls_201_01 LIKE LINE OF <gt_set_schedule>.
  CREATE DATA ls_201_02 LIKE LINE OF <gt_set_schedule>.
  ASSIGN ls_201_01->* TO <ls_line01>.
  ASSIGN ls_201_02->* TO <ls_line02>.
* 스타일 세팅 초록색  + 왼쪽 정렬
  lv_style = alv_style_align_left_center + alv_style_color_int_positive.
  lv_style2 = alv_style_align_center_center.

* 초기 인덱스값 세팅
  lv_idx_line01 = 2.
  lv_idx_line02 = 3.

  LOOP AT gt_gong_cd INTO DATA(ls_gong_cd). "정렬기준테이블
    READ TABLE gt_disp_arbpl INTO gs_disp_arbpl WITH KEY arbpl = ls_gong_cd-arbpl.
*    IF P_PLAN NE ABAP_TRUE AND SY-SUBRC NE 0.
*      CONTINUE.
*    ENDIF.

    CLEAR : <ls_line01>, <ls_line02>.
    CLEAR : lv_line01_merge, lv_line02_merge.
    REFRESH lt_style_seq.
*  장비명
    __set_field_of_line 'KTEXT'.
    <lv_value01> = ls_gong_cd-ktext.
*  칼럼 1 병합 세팅
    REFRESH gt_col_merge.
    __set_merge_tab 1 2.

    __set_style 1 lv_style2 ''.
    APPEND LINES OF lt_style_seq TO lv_line01_merge-style.

    lv_line01_merge-col_id = lv_idx_line01.
    lv_line01_merge-merge_vert = gt_col_merge.

*  스케줄 세팅
    REFRESH gt_col_merge.
    REFRESH lt_style_seq.
    LOOP AT gt_begin_schedule INTO DATA(ls_schedule) WHERE ktext = ls_gong_cd-ktext.
      __set_field_of_line ls_schedule-fieldname.
      <lv_value01> = ls_schedule-order_c.
      <lv_value02> = ls_schedule-jojang_c.

*   병합 세팅
      IF ls_schedule-fromline NE ls_schedule-toline.
        __set_merge_tab ls_schedule-fromline ls_schedule-toline.
      ENDIF.
* 스타일 세팅(초록)
      __set_style ls_schedule-fromline lv_style ''.
    ENDLOOP.

    APPEND <ls_line01> TO <gt_set_schedule>.
    APPEND <ls_line02> TO <gt_set_schedule>.

    SORT gt_col_merge BY col_id.
    SORT lt_style_seq BY index.
*  1번라인 머지세팅
    lv_line01_merge-merge_horiz = gt_col_merge.
    APPEND LINES OF lt_style_seq TO lv_line01_merge-style.
    APPEND lv_line01_merge TO gt_tab_merge.

*  2번라인 머지세팅
    lv_line02_merge-col_id = lv_idx_line02.
    lv_line02_merge-merge_horiz = gt_col_merge.
    lv_line02_merge-style = lt_style_seq.
    APPEND lv_line02_merge TO gt_tab_merge.


    ADD 2 TO  : lv_idx_line01, lv_idx_line02.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATE_WITH_GUBUN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_1
*&      --> LS_SCHEDULE_FROM
*&      <-- PS_DATA_TO
*&---------------------------------------------------------------------*
FORM set_date_with_gubun  USING  pv_gubun
                                                     pv_orign_date
                                      CHANGING  pv_change_date.

  DATA : lv_date TYPE sy-datum.
  DATA : lv_date_new TYPE sy-datum.
  DATA : lv_time TYPE sy-uzeit.
  DATA : lv_time_new TYPE sy-uzeit.

  CASE pv_gubun.
    WHEN '1'. " 대상시간 다음 순번 시간대 찾기
      CLEAR : lv_date, lv_time.
      lv_date = pv_orign_date+0(8).
      lv_time = pv_orign_date+8(6).
      IF lv_time BETWEEN '000000' AND '060000'.
        lv_date_new = lv_date - 1.
        lv_time_new = '240000'.
      ELSEIF lv_time BETWEEN '060000' AND '120000'.
        lv_date_new = lv_date.
        lv_time_new = '055959'.
      ELSEIF lv_time BETWEEN '120000' AND '180000'.
        lv_date_new = lv_date.
        lv_time_new = '115959'.
      ELSEIF lv_time BETWEEN '180000' AND '240000'.
        lv_date_new = lv_date.
        lv_time_new = '175959'.
      ENDIF.

      pv_change_date = lv_date_new && lv_time_new.

    WHEN '2'. " 대상시간 이전 순번 시간대 찾기

      CLEAR : lv_date, lv_time.
      lv_date = pv_orign_date+0(8).
      lv_time = pv_orign_date+8(6).
      IF lv_time BETWEEN '000000' AND '060000'.
        lv_date_new = lv_date.
        lv_time_new = '060001'.
      ELSEIF lv_time BETWEEN '060000' AND '120000'.
        lv_date_new = lv_date.
        lv_time_new = '120001'.
      ELSEIF lv_time BETWEEN '120000' AND '180000'.
        lv_date_new = lv_date.
        lv_time_new = '180001'.
      ELSEIF lv_time BETWEEN '180000' AND '240000'.
        lv_date_new = lv_date + 1.
        lv_time_new = '000001'.
      ENDIF.

      pv_change_date = lv_date_new && lv_time_new.

  ENDCASE.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MERGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_merge USING po_grid TYPE REF TO zcl_gui_alv_grid.

  LOOP AT gt_tab_merge ASSIGNING FIELD-SYMBOL(<ls_tab_merge>).

* 세로열 병합
    IF <ls_tab_merge>-merge_vert[] IS NOT INITIAL.
      CALL METHOD po_grid->z_set_merge_vert
        EXPORTING
          row           = <ls_tab_merge>-col_id
        CHANGING
          tab_col_merge = <ls_tab_merge>-merge_vert.
    ENDIF.

* 가로열 병합
    IF <ls_tab_merge>-merge_horiz[] IS NOT INITIAL.
      CALL METHOD po_grid->z_set_merge_horiz
        EXPORTING
          row           = <ls_tab_merge>-col_id
        CHANGING
          tab_col_merge = <ls_tab_merge>-merge_horiz.
    ENDIF.

* 각 셀별 속성값 세팅
    LOOP AT <ls_tab_merge>-style ASSIGNING FIELD-SYMBOL(<ls_style>).
      CALL METHOD po_grid->z_set_cell_style
        EXPORTING
          row    = <ls_tab_merge>-col_id
          col    = <ls_style>-index
          style  = <ls_style>-style
          style2 = <ls_style>-style2.
    ENDLOOP.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_table .

  DATA: ls_scroll   TYPE lvc_s_stbl.

  ls_scroll-row = 'X'.
  ls_scroll-col = 'X'.

  CALL METHOD go_grid_merge->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = ls_scroll.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_ORDER_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_order_info .

* 조장의 연결을 위한 체인 테이블 조회
  DATA : lt_2010 TYPE TABLE OF zgtppt2010.
  DATA : ls_2010_check TYPE zgtppt2010.
  DATA : ls_grpnr LIKE gs_grpnr.
  DATA : lv_chk_err.
  DATA : lv_tabix TYPE i.
  DATA : lv_vbeln TYPE vbap-vbeln.
  DATA : lv_posnr TYPE vbap-posnr.

* 조장의 연결을 위한 체인 테이블 조회
  DATA(lt_chk_grpnr) = gt_2000.
  SORT lt_chk_grpnr BY grpnr.
  DELETE ADJACENT DUPLICATES FROM lt_chk_grpnr COMPARING grpnr.
  IF lt_chk_grpnr IS NOT INITIAL.
    SELECT * FROM zgtppt2010
      INTO TABLE lt_2010
       FOR ALL ENTRIES IN lt_chk_grpnr
     WHERE grpnr = lt_chk_grpnr-grpnr.
  ENDIF.

  REFRESH gt_grpnr.

  CASE p_werks.
    WHEN '1802'.
      LOOP AT gt_2010 INTO DATA(ls_2010).
        READ TABLE lt_2010 INTO DATA(ls_chk_2010) WITH KEY grpnr = ls_2010-grpnr
                                                                                      dmordty = 'SO'.
        IF sy-subrc EQ 0.
          READ TABLE gt_grpnr TRANSPORTING NO FIELDS WITH KEY grpnr = ls_chk_2010-grpnr
                                                                                           ordno = ls_chk_2010-dmord
                                                                                           posnr = ls_chk_2010-dmline
                                                                                           BINARY SEARCH.
          IF sy-subrc NE 0.
            CLEAR lv_tabix.
            lv_tabix = sy-tabix.
            READ TABLE gt_2000 INTO DATA(ls_2000) WITH KEY grpnr = ls_chk_2010-grpnr
                                                                                   ordno = ls_chk_2010-dmord
                                                                                    posnr = ls_chk_2010-dmline.
            IF sy-subrc EQ 0 .
              CLEAR ls_grpnr.
              MOVE-CORRESPONDING   ls_2000 TO ls_grpnr.
              CLEAR : lv_vbeln, lv_posnr.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ls_2000-ordno
                IMPORTING
                  output = lv_vbeln.

              lv_posnr = ls_2000-posnr + 0.

              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                EXPORTING
                  input  = ls_2000-ordno
                IMPORTING
                  output = ls_grpnr-ordno_c.
              ls_grpnr-ordno_c = ls_grpnr-ordno_c && '/' && ls_grpnr-posnr.



              SELECT SINGLE a~vbeln, a~kunnr, a~vbtyp, b~posnr, b~matnr
                FROM vbak AS a
                 INNER JOIN vbap AS b ON b~vbeln = a~vbeln
               WHERE a~vbeln =  @lv_vbeln
                  AND b~posnr = @lv_posnr
                INTO @DATA(ls_vbak).

              CASE ls_vbak-vbtyp.
                WHEN 'C'.
                  ls_grpnr-gcatg = '판매오더'.
                WHEN 'B'.
                  ls_grpnr-gcatg = '견적'.
              ENDCASE.

              ls_grpnr-matnr = ls_vbak-matnr.
              ls_grpnr-maktx = zgtpp_cl_common=>get_maktx( iv_matnr = ls_vbak-matnr ).
              ls_grpnr-kunnr = ls_vbak-kunnr.
              ls_grpnr-name1 = zgtpp_cl_common=>get_bp_name( iv_kunnr = ls_vbak-kunnr ).

              INSERT ls_grpnr INTO gt_grpnr INDEX lv_tabix.
              CLEAR ls_vbak.
            ENDIF.
          ELSE.
            CONTINUE.
          ENDIF.
        ENDIF.

      ENDLOOP.

    WHEN OTHERS.

      LOOP AT gt_2010 INTO ls_2010.
* 해당 조장구성표의 오더번호 찾아가기
        CLEAR : ls_2010_check, lv_chk_err.
        MOVE-CORRESPONDING ls_2010 TO ls_2010_check.
        DO.
          IF ls_2010_check-dmordty = 'SO'.
            EXIT.
          ELSE.
            READ TABLE lt_2010 INTO ls_chk_2010 WITH KEY ordnr = ls_2010_check-dmord
                                                                                 posnr = ls_2010_check-dmline
                                                                                 ordty = ls_2010_check-dmordty.
            IF sy-subrc EQ 0.
              MOVE-CORRESPONDING ls_chk_2010 TO ls_2010_check.
            ELSE.
              READ TABLE lt_2010 INTO ls_chk_2010 WITH KEY reord = ls_2010_check-ordnr
                                                                                   reline = ls_2010_check-posnr
                                                                                   reordty = ls_2010_check-ordty.
              IF sy-subrc EQ 0.
                MOVE-CORRESPONDING ls_chk_2010 TO ls_2010_check.
              ELSE.
                lv_chk_err = abap_true.
                EXIT.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDDO.

        IF lv_chk_err IS NOT INITIAL.
          CONTINUE.
        ELSE.
          READ TABLE gt_grpnr TRANSPORTING NO FIELDS WITH KEY grpnr = ls_2010_check-grpnr
                                                                                          ordno = ls_2010_check-dmord
                                                                                          posnr = ls_2010_check-dmline
                                                                                          BINARY SEARCH.
          IF sy-subrc NE 0.
            CLEAR lv_tabix.
            lv_tabix = sy-tabix.
            READ TABLE gt_2000 INTO ls_2000 WITH KEY grpnr = ls_2010_check-grpnr
                                                                           ordno = ls_2010_check-dmord
                                                                           posnr = ls_2010_check-dmline.
            IF sy-subrc EQ 0 .
              CLEAR ls_grpnr.
              MOVE-CORRESPONDING   ls_2000 TO ls_grpnr.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                EXPORTING
                  input  = ls_2000-ordno
                IMPORTING
                  output = ls_grpnr-ordno_c.
              ls_grpnr-ordno_c = ls_grpnr-ordno_c && '/' && ls_grpnr-posnr.
              ls_grpnr-maktx = zgtpp_cl_common=>get_maktx( iv_matnr = ls_grpnr-matnr ).
              ls_grpnr-name1 = zgtpp_cl_common=>get_bp_name( iv_kunnr = ls_grpnr-kunnr ).

              INSERT ls_grpnr INTO gt_grpnr INDEX lv_tabix.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
  ENDCASE.
* 추가 오더 정보 어팬드
  CHECK s_kdauf[] IS INITIAL.

  LOOP AT gt_main INTO DATA(ls_main).
    READ TABLE gt_2010 TRANSPORTING NO FIELDS WITH KEY ordnr = ls_main-aufnr.
    IF sy-subrc EQ 0. " 조장 구성표 대상은 위에서 이미 처리 완료
      CONTINUE.
    ENDIF.

    READ TABLE gt_grpnr TRANSPORTING NO FIELDS  WITH KEY ordno = ls_main-aufnr.
    IF sy-subrc EQ 0.
      CONTINUE.
    ENDIF.

    APPEND INITIAL LINE TO gt_grpnr ASSIGNING FIELD-SYMBOL(<ls_grpnr>).
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ls_main-aufnr
      IMPORTING
        output = <ls_grpnr>-ordno_c.

    CONCATENATE '##' ls_main-auart INTO <ls_grpnr>-grpnr.

    CONCATENATE <ls_grpnr>-grpnr <ls_grpnr>-ordno_c INTO <ls_grpnr>-grpnr SEPARATED BY space.
    <ls_grpnr>-erdat = ls_main-erdat.
    <ls_grpnr>-gcatg = '생산오더'.
    <ls_grpnr>-ordno = ls_main-aufnr.
    <ls_grpnr>-posnr = 1.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = <ls_grpnr>-ordno
      IMPORTING
        output = <ls_grpnr>-ordno_c.
    <ls_grpnr>-ordno_c = <ls_grpnr>-ordno_c && '/' && <ls_grpnr>-posnr.
    <ls_grpnr>-matnr = ls_main-matnr.
    <ls_grpnr>-maktx = zgtpp_cl_common=>get_maktx( iv_matnr = ls_main-matnr ).
    <ls_grpnr>-wmeng = ls_main-psmng + ls_main-psamg.
    <ls_grpnr>-inlength = ls_main-millcalength.
    <ls_grpnr>-infactor = ls_main-millcafactor.
    <ls_grpnr>-meins = ls_main-meins.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_object_grid_0200 .

  CREATE OBJECT go_contain_docking_0200
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
  CREATE OBJECT go_splitter_0200
    EXPORTING
      parent  = go_contain_docking_0200
      rows    = 4
      columns = 1.

  go_splitter_0200->set_row_height(
    EXPORTING
      id                =    1              " Row ID
      height            =    6 ).             " Height

  go_splitter_0200->set_row_height(
    EXPORTING
      id                =    2              " Row ID
      height            =    40 ).             " Height

  go_splitter_0200->set_row_height(
    EXPORTING
      id                =    3              " Row ID
      height            =    40 ).             " Height

* top 컨테이너(Title)
  CALL METHOD go_splitter_0200->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_contain_top_0200.
* top 컨테이너(Grid)
  CALL METHOD go_splitter_0200->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_contain_0200.

  CALL METHOD go_splitter_0200->get_container
    EXPORTING
      row       = 3
      column    = 1
    RECEIVING
      container = go_contain_0300.

* bottom 컨테이너
  CALL METHOD go_splitter_0200->get_container
    EXPORTING
      row       = 4
      column    = 1
    RECEIVING
      container = go_contain_0201.


  CREATE OBJECT go_grid_0200
    EXPORTING
      i_parent      = go_contain_0200
      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0200
*&---------------------------------------------------------------------*
FORM event_handler_register  USING    po_grid TYPE REF TO cl_gui_alv_grid.

  IF go_event_handler IS NOT BOUND.
    CREATE OBJECT go_event_handler.
  ENDIF.

  CASE po_grid.
    WHEN go_grid_0200.
      SET HANDLER go_event_handler->handle_toolbar               FOR po_grid.
      SET HANDLER go_event_handler->handle_double_click               FOR po_grid.
      SET HANDLER go_event_handler->handle_user_command          FOR po_grid.
      SET HANDLER go_event_handler->handle_top_of_page          FOR po_grid.
      SET HANDLER go_event_handler->handle_data_changed          FOR po_grid.
*    WHEN GO_GRID_0300.
*      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
*      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK               FOR PO_GRID.
*      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
**      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOP_OF_PAGE          FOR PO_GRID.
*      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.
*      SET HANDLER GO_EVENT_HANDLER->HANDLE_ON_F4          FOR PO_GRID.
    WHEN go_grid_0410.
      SET HANDLER go_event_handler->handle_data_changed          FOR po_grid.
    WHEN go_grid_0440.
      SET HANDLER go_event_handler->handle_double_click          FOR po_grid.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0200
*&---------------------------------------------------------------------*
FORM event_handler_register_300  USING    po_grid TYPE REF TO lcl_alv_grid.

  IF go_event_handler IS NOT BOUND.
    CREATE OBJECT go_event_handler.
  ENDIF.

  CASE po_grid.
    WHEN go_grid_0300.
      SET HANDLER go_event_handler->handle_toolbar               FOR po_grid.
      SET HANDLER go_event_handler->handle_double_click               FOR po_grid.
      SET HANDLER go_event_handler->handle_user_command          FOR po_grid.
*      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOP_OF_PAGE          FOR PO_GRID.
      SET HANDLER go_event_handler->handle_data_changed          FOR po_grid.
      SET HANDLER go_event_handler->handle_on_f4          FOR po_grid.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_grid_0200 .

  CLEAR gs_layout_0200.
  gs_layout_0200-cwidth_opt = abap_true.
  gs_layout_0200-no_rowins = abap_true.
  gs_layout_0200-sel_mode   = 'D'.
  gs_layout_0200-no_rowmark   = 'X'.
  gs_layout_0200-stylefname   = 'CELLTAB'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0200 .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR2020TOP'
      i_internal_tabname     = 'GS_GRPNR'
    CHANGING
      ct_fieldcat            = lt_fcat_slis
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  REFRESH gt_fieldcat_0200.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat_slis
    IMPORTING
      et_fieldcat_lvc = gt_fieldcat_0200[]
    TABLES
      it_data         = gt_grpnr
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE gt_fieldcat_0200 ASSIGNING FIELD-SYMBOL(<ls_fcat>) WITH KEY fieldname = 'CHECK'.
  IF sy-subrc EQ 0.
  ELSE.
    APPEND INITIAL LINE TO gt_fieldcat_0200 ASSIGNING <ls_fcat>.
  ENDIF.
  <ls_fcat>-fieldname = 'CHECK'.
  <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '체크'(f01).
  <ls_fcat>-col_pos = 1.
  <ls_fcat>-datatype = 'CHAR'.
  <ls_fcat>-dd_outlen = '1'.
  <ls_fcat>-checkbox = 'X'.
  <ls_fcat>-edit = abap_true.
  <ls_fcat>-just = 'C'.

  READ TABLE gt_fieldcat_0200 ASSIGNING <ls_fcat> WITH KEY fieldname = 'GRPNR'.
  IF sy-subrc EQ 0.
  ELSE.
    APPEND INITIAL LINE TO gt_fieldcat_0200 ASSIGNING <ls_fcat>.
  ENDIF.
  <ls_fcat>-fieldname = 'GRPNR'.
  <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '조장표번호'(f02).
  <ls_fcat>-col_pos = 2.
  <ls_fcat>-datatype = 'CHAR'.
  <ls_fcat>-dd_outlen = '20'.
  <ls_fcat>-just = 'C'.

  APPEND INITIAL LINE TO gt_fieldcat_0200 ASSIGNING <ls_fcat>.
  <ls_fcat>-fieldname = 'ORDNO_C'.
  <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '오더번호'(f03).
  <ls_fcat>-col_pos = 8.
  <ls_fcat>-datatype = 'CHAR'.
  <ls_fcat>-dd_outlen = '30'.
  <ls_fcat>-just = 'C'.


  LOOP AT gt_fieldcat_0200 ASSIGNING <ls_fcat>.
    CASE   <ls_fcat>-fieldname.
      WHEN 'GRPNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '조장표번호'(f02).
        <ls_fcat>-just = 'C'.
      WHEN 'ERDAT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '작성일'(f04).
        <ls_fcat>-just = 'C'.
      WHEN 'GCATG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '범주'(f05).
        <ls_fcat>-just = 'C'.
      WHEN 'MATNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '제품'(f06).
        <ls_fcat>-just = 'C'.
      WHEN 'ORDNO'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'POSNR'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'LINNO'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'MAKTX'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '제품내역'(f07).
        <ls_fcat>-just = 'L'.
      WHEN 'KUNNR'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'NAME1'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '납품처'(f08).
        <ls_fcat>-just = 'L'.
      WHEN 'EDATU'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '납품요청일'(f09).
        <ls_fcat>-just = 'C'.
      WHEN 'WMENG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '총수량'(f10).
        <ls_fcat>-just = 'R'.
      WHEN 'INLENGTH'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '조장'(f11).
        <ls_fcat>-just = 'R'.
      WHEN 'MEINS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '단위'(f12).
        <ls_fcat>-just = 'C'.
      WHEN 'INFACTOR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '조장수'(f13).
        <ls_fcat>-just = 'R'.
        <ls_fcat>-decimals_o = '0'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_of_toolbar_grid_0200 .

  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0200
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
*& Form CALL_GRID_0200_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_grid_0200_display .

  CALL METHOD go_grid_0200->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0200
      it_toolbar_excluding = gt_exclude_0200
    CHANGING
      it_outtab            = gt_grpnr
*     IT_SORT              = GT_SORT_0200
      it_fieldcatalog      = gt_fieldcat_0200.

* 인풋이벤트 추가
  CALL METHOD go_grid_0200->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CALL METHOD go_grid_0200->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  IF go_dd_docu_0200 IS BOUND.
    CALL METHOD go_dd_docu_0200->initialize_document.
  ELSE.
    CREATE OBJECT go_dd_docu_0200
      EXPORTING
        style = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
  ENDIF.

  CALL METHOD go_grid_0200->list_processing_events
    EXPORTING
      i_event_name = 'TOP_OF_PAGE'
      i_dyndoc_id  = go_dd_docu_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PV_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM set_title_0200  CHANGING pv_dyndoc_id  TYPE REF TO  cl_dd_document.

  DATA : lv_text(255) TYPE c.
  DATA : lv_frdate_c(10).
  DATA : lv_todate_c(10).

* 공정
  IF p_gongcd IS INITIAL OR p_gongcd = '*'.
    CONCATENATE '공정 :' 'ALL' INTO lv_text SEPARATED BY space.
  ELSE.

    SELECT SINGLE gong_nm INTO p_gongnm
             FROM zedt0011
            WHERE gong_cd EQ p_gongcd.

    lv_text = p_gongnm && '(' && p_gongcd && ')'.
    CONCATENATE '공정 :' lv_text INTO lv_text SEPARATED BY space.
  ENDIF.

  "텍스트 추가
  CALL METHOD pv_dyndoc_id->add_text
    EXPORTING
      text         = lv_text
      sap_fontsize = '20'.

  CALL METHOD pv_dyndoc_id->new_line.

* 생산시작일
  CLEAR lv_text.
  lv_frdate_c = s_gstrp-low+0(4) && '.' && s_gstrp-low+4(2) && '.' && s_gstrp-low+6(2).
  lv_todate_c = s_gstrp-high+0(4) && '.' && s_gstrp-high+4(2) && '.' && s_gstrp-high+6(2).

  CONCATENATE '생산 시작일 :' lv_frdate_c '~' lv_todate_c INTO lv_text SEPARATED BY space.

  "텍스트 추가
  CALL METHOD pv_dyndoc_id->add_text
    EXPORTING
      text         = lv_text
      sap_fontsize = '20'.

  CALL METHOD pv_dyndoc_id->new_line.

  "위쪽에 추가한 텍스트 출력
  CALL METHOD go_dd_docu_0200->display_document
    EXPORTING
      parent = go_contain_top_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_object_grid_0201 .

  CREATE OBJECT go_grid_merge_201
    EXPORTING
      i_parent = go_contain_0201.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_grid_0201 .

  CLEAR gs_layout_merge.
  gs_layout_merge-stylefname = 'CELL'.
  gs_layout_merge-no_headers = 'X'.
  gs_layout_merge-cwidth_opt = ' '.
  gs_layout_merge-no_toolbar = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0201_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_grid_0201_display .

  PERFORM make_disp_grid_0100.

  CALL METHOD go_grid_merge_201->set_table_for_first_display
    EXPORTING
*     IS_VARIANT      = GS_VARIANT_MERGE
      is_layout       = gs_layout_merge
    CHANGING
      it_fieldcatalog = gt_fieldcat_set_merge
      it_outtab       = <gt_set_schedule>.

  go_grid_merge_201->set_ready_for_input( 1 ).
*  CALL METHOD GO_GRID_MERGE->Z_LVC_TABLE_FILL
*    EXPORTING
*      LASTLINE = LINES( <GT_SET_SCHEDULE> ).


  PERFORM set_merge USING go_grid_merge_201.
  go_grid_merge_201->z_display( ).

  go_grid_merge_201->z_set_fixed_col_row(
    col = 1
    row = 1
  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_screen .

  CASE abap_true.
    WHEN p_disp. " 스케줄조회
      CALL SCREEN '0100'.
    WHEN p_plan. " 일정수립
      CALL SCREEN '0200'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE gv_ok_code2.
    WHEN 'EXIT' OR 'CANC'.
*     종료
      CALL METHOD go_contain_docking_0200->free.
      FREE : go_contain_docking_0200, go_grid_0200, go_grid_merge_201.
      IF go_grid_0300 IS BOUND.
        FREE go_grid_0300.
      ENDIF.

      CALL METHOD cl_gui_cfw=>flush.
      LEAVE TO SCREEN 0.
    WHEN 'SETCHECK'.
      PERFORM set_check_box_grid_0200.
    WHEN 'DETAIL'.
      PERFORM disp_detail.
      IF gt_detail[] IS NOT INITIAL.
        gv_mode_detail = abap_true.
      ENDIF.
      gv_chk_use_backup = abap_true.
    WHEN 'BACKWARD'.
      CLEAR gv_mode_detail.
      MOVE-CORRESPONDING gt_detail TO gt_detail_backup.
    WHEN 'BACK'.
      IF gv_mode_detail IS INITIAL.
*     종료
        CALL METHOD go_contain_docking_0200->free.
        FREE : go_contain_docking_0200, go_grid_0200, go_grid_merge_201.
        IF go_grid_0300 IS BOUND.
          FREE go_grid_0300.
        ENDIF.

        CALL METHOD cl_gui_cfw=>flush.
        LEAVE TO SCREEN 0.

      ELSE.
        MOVE-CORRESPONDING gt_detail TO gt_detail_backup.
        CLEAR gv_mode_detail.
      ENDIF.
    WHEN 'SAVE'.
      PERFORM save_and_refresh.
    WHEN 'MARKING'.
      IF gv_mode_detail IS NOT INITIAL.
        PERFORM process_marking_0300.
      ELSE.
        PERFORM process_marking.
      ENDIF.
    WHEN 'ALLSEL'.
      IF gv_mode_detail IS NOT INITIAL.
        PERFORM process_allselect_300 USING go_grid_0300.
      ELSE.
        PERFORM process_allselect USING go_grid_0200.
      ENDIF.
    WHEN 'DESEL'.
      IF gv_mode_detail IS NOT INITIAL.
        PERFORM process_deselect_300 USING go_grid_0300.
      ELSE.
        PERFORM process_deselect USING go_grid_0200.
      ENDIF.
    WHEN 'CHANGE'.
      go_grid_0300->check_changed_data( ).

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_cell_attribute_grid_0200 .

  DATA : lt_celltab TYPE lvc_t_styl.
  DATA : ls_celltab TYPE lvc_s_styl.

  LOOP AT gt_grpnr ASSIGNING FIELD-SYMBOL(<ls_main_disp>).
    REFRESH lt_celltab.

    LOOP AT gt_fieldcat_0200 INTO DATA(ls_fieldcat).
      CASE ls_fieldcat-fieldname.
        WHEN 'GRPNR'.
*       key 색깔지정
          CLEAR ls_celltab.
          ls_celltab-fieldname = ls_fieldcat-fieldname.
          ls_celltab-style = alv_style_color_int_key.
          INSERT ls_celltab INTO TABLE lt_celltab.
      ENDCASE.
    ENDLOOP.
    <ls_main_disp>-celltab = lt_celltab.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHECK_BOX_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_check_box_grid_0200 .

  CLEAR gv_chk_use_backup.

  READ TABLE gt_grpnr ASSIGNING FIELD-SYMBOL(<ls_grpnr>) INDEX gv_chk_line.
  <ls_grpnr>-check = gv_chk_value.

  PERFORM refresh_grid USING go_grid_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM refresh_grid  USING    po_grid TYPE REF TO cl_gui_alv_grid..

  DATA: ls_scroll   TYPE lvc_s_stbl.

  ls_scroll-row = 'X'.
  ls_scroll-col = 'X'.


  CALL METHOD po_grid->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = ls_scroll.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM refresh_grid_300  USING    po_grid TYPE REF TO lcl_alv_grid..

  DATA: ls_scroll   TYPE lvc_s_stbl.

  ls_scroll-row = 'X'.
  ls_scroll-col = 'X'.


  CALL METHOD po_grid->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = ls_scroll.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_DETAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM disp_detail .

  DATA : lt_2010 TYPE TABLE OF zgtppt2010.
  DATA : ls_2010_check TYPE zgtppt2010.
  DATA : lv_chk_err.

  IF gv_chk_use_backup IS NOT INITIAL.
    MOVE-CORRESPONDING gt_detail_backup TO gt_detail.
    RETURN.
  ENDIF.

  PERFORM get_main_data.

  REFRESH gt_detail.

* 조장의 연결을 위한 체인 테이블 조회
  DATA(lt_chk_grpnr) = gt_2000.
  SORT lt_chk_grpnr BY grpnr.
  DELETE ADJACENT DUPLICATES FROM lt_chk_grpnr COMPARING grpnr.
  IF lt_chk_grpnr IS NOT INITIAL.
    SELECT * FROM zgtppt2010
      INTO TABLE lt_2010
       FOR ALL ENTRIES IN lt_chk_grpnr
     WHERE grpnr = lt_chk_grpnr-grpnr.
  ENDIF.



  LOOP AT gt_grpnr INTO DATA(ls_grpnr) WHERE check = abap_true.
    CASE ls_grpnr-gcatg.
      WHEN '판매오더' OR '견적'.
        CASE p_werks.
          WHEN '1802'.
            LOOP AT gt_2010 INTO DATA(ls_2010) WHERE grpnr = ls_grpnr-grpnr.

              APPEND INITIAL LINE TO gt_detail ASSIGNING FIELD-SYMBOL(<ls_detail>).
              <ls_detail>-grpnr = ls_grpnr-grpnr.
              <ls_detail>-ordno = ls_2010-ordnr.
              <ls_detail>-posnr = ls_2010-posnr.
              PERFORM set_status USING <ls_detail>-ordno CHANGING <ls_detail>-ordstat.

              READ TABLE gt_main INTO DATA(ls_main) WITH KEY aufnr = ls_2010-ordnr
                                                                           posnr = ls_2010-posnr+2(4).
              <ls_detail>-psmng = ls_main-psmng.
              <ls_detail>-amein = ls_main-meins.

              <ls_detail>-matnr = ls_main-matnr.
              <ls_detail>-maktx = zgtpp_cl_common=>get_maktx( iv_matnr = <ls_detail>-matnr ).
              READ TABLE gt_disp_arbpl INTO DATA(ls_arbpl) WITH KEY aufnr = ls_main-aufnr.
              <ls_detail>-arbpl = ls_arbpl-arbpl.
              <ls_detail>-ktext = ls_arbpl-ktext.
              <ls_detail>-gstrp = ls_main-gstrp.
              <ls_detail>-gsuzp = ls_main-gsuzp.
              <ls_detail>-gltrp = ls_main-gltrp.
              <ls_detail>-gluzp = ls_main-gluzp.
              <ls_detail>-gsuzp_hhmm = ls_main-gsuzp+0(4).
              <ls_detail>-gluzp_hhmm = ls_main-gluzp+0(4).
              <ls_detail>-zzpriority = ls_main-zzpriority.
              <ls_detail>-inlength = ls_2010-inlength.
              <ls_detail>-qlength = ls_2010-qlength.
              <ls_detail>-clength = ls_2010-clength.
              <ls_detail>-adlength = ls_2010-adlength.
              <ls_detail>-infactor = ls_2010-infactor.
              <ls_detail>-matnr_so = ls_grpnr-matnr.
              <ls_detail>-maktx_so = ls_grpnr-maktx.

            ENDLOOP.

          WHEN OTHERS.
            LOOP AT gt_2010 INTO ls_2010 WHERE grpnr = ls_grpnr-grpnr.
* 해당 조장구성표의 오더번호 찾아가기
              CLEAR : ls_2010_check, lv_chk_err.
              MOVE-CORRESPONDING ls_2010 TO ls_2010_check.
              DO.
                IF ls_2010_check-dmordty = 'SO'.
                  EXIT.
                ELSE.
                  READ TABLE lt_2010 INTO DATA(ls_chk_2010) WITH KEY ordnr = ls_2010_check-dmord
                                                                                                posnr = ls_2010_check-dmline
                                                                                                ordty = ls_2010_check-dmordty.
                  IF sy-subrc EQ 0.
                    MOVE-CORRESPONDING ls_chk_2010 TO ls_2010_check.
                  ELSE.
                    READ TABLE lt_2010 INTO ls_chk_2010 WITH KEY reord = ls_2010_check-ordnr
                                                                                         reline = ls_2010_check-posnr
                                                                                         reordty = ls_2010_check-ordty.
                    IF sy-subrc EQ 0.
                      MOVE-CORRESPONDING ls_chk_2010 TO ls_2010_check.
                    ELSE.
                      lv_chk_err = abap_true.
                      EXIT.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDDO.

              IF lv_chk_err IS NOT INITIAL.
                CONTINUE.
              ELSE.
                IF ls_grpnr-ordno = ls_2010_check-dmord AND
                  ls_grpnr-posnr = ls_2010_check-dmline.

                  APPEND INITIAL LINE TO gt_detail ASSIGNING <ls_detail>.
                  <ls_detail>-grpnr = ls_grpnr-grpnr.
                  <ls_detail>-ordno = ls_2010-ordnr.
                  <ls_detail>-posnr = ls_2010-posnr.
                  PERFORM set_status USING <ls_detail>-ordno CHANGING <ls_detail>-ordstat.

                  READ TABLE gt_main INTO ls_main WITH KEY aufnr = ls_2010-ordnr
                                                                               posnr = ls_2010-posnr+2(4).
                  <ls_detail>-psmng = ls_main-psmng.
                  <ls_detail>-amein = ls_main-meins.

                  <ls_detail>-matnr = ls_main-matnr.
                  <ls_detail>-maktx = zgtpp_cl_common=>get_maktx( iv_matnr = <ls_detail>-matnr ).
                  READ TABLE gt_disp_arbpl INTO ls_arbpl WITH KEY aufnr = ls_main-aufnr.
                  <ls_detail>-arbpl = ls_arbpl-arbpl.
                  <ls_detail>-ktext = ls_arbpl-ktext.
                  <ls_detail>-gstrp = ls_main-gstrp.
                  <ls_detail>-gsuzp = ls_main-gsuzp.
                  <ls_detail>-gltrp = ls_main-gltrp.
                  <ls_detail>-gluzp = ls_main-gluzp.
                  <ls_detail>-gsuzp_hhmm = ls_main-gsuzp+0(4).
                  <ls_detail>-gluzp_hhmm = ls_main-gluzp+0(4).
                  <ls_detail>-zzpriority = ls_main-zzpriority.
                  <ls_detail>-inlength = ls_2010-inlength.
                  <ls_detail>-qlength = ls_2010-qlength.
                  <ls_detail>-clength = ls_2010-clength.
                  <ls_detail>-adlength = ls_2010-adlength.
                  <ls_detail>-infactor = ls_2010-infactor.
                  <ls_detail>-matnr_so = ls_grpnr-matnr.
                  <ls_detail>-maktx_so = ls_grpnr-maktx.
                ENDIF.
              ENDIF.
            ENDLOOP.
        ENDCASE.
      WHEN OTHERS.
        READ TABLE gt_main INTO ls_main WITH KEY aufnr = ls_grpnr-ordno
                                                                    posnr = ls_grpnr-posnr+2(4).
        IF sy-subrc EQ 0.
          APPEND INITIAL LINE TO gt_detail ASSIGNING <ls_detail>.
          <ls_detail>-grpnr = ls_grpnr-grpnr.
          <ls_detail>-ordno = ls_grpnr-ordno.
          PERFORM set_status USING <ls_detail>-ordno CHANGING <ls_detail>-ordstat.
          <ls_detail>-posnr = ls_main-posnr.
          <ls_detail>-matnr = ls_grpnr-matnr.
          <ls_detail>-maktx = ls_grpnr-maktx.
          <ls_detail>-psmng = ls_main-psmng.
          <ls_detail>-amein = ls_main-meins.
          READ TABLE gt_disp_arbpl INTO ls_arbpl WITH KEY aufnr = ls_main-aufnr.
          <ls_detail>-arbpl = ls_arbpl-arbpl.
          <ls_detail>-ktext = ls_arbpl-ktext.
          <ls_detail>-gstrp = ls_main-gstrp.
          <ls_detail>-gsuzp = ls_main-gsuzp.
          <ls_detail>-gltrp = ls_main-gltrp.
          <ls_detail>-gluzp = ls_main-gluzp.
          <ls_detail>-gsuzp_hhmm = ls_main-gsuzp+0(4).
          <ls_detail>-gluzp_hhmm = ls_main-gluzp+0(4).
          <ls_detail>-zzpriority = ls_main-zzpriority.
          <ls_detail>-inlength = ls_main-millcalength + 0.
          <ls_detail>-infactor = ls_main-millcafactor + 0.

        ENDIF.
    ENDCASE.
  ENDLOOP.

  REFRESH gt_aufnr.
  SORT gt_detail BY ordno posnr.
  DELETE ADJACENT DUPLICATES FROM gt_detail COMPARING ordno posnr.

  gt_aufnr = VALUE #( FOR lw_detail IN gt_detail WHERE ( ordno IS NOT INITIAL ) ( sign = 'I' option = 'EQ' low = lw_detail-ordno ) ).
  SORT gt_aufnr BY low.
  DELETE ADJACENT DUPLICATES FROM gt_aufnr COMPARING low.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_object_grid_0300 .

**  CREATE OBJECT GO_CONTAIN_DOCKING_0300
**    EXPORTING
**      REPID                       = SY-REPID
**      DYNNR                       = SY-DYNNR
**      EXTENSION                   = 10000
**    EXCEPTIONS
**      CNTL_ERROR                  = 1
**      CNTL_SYSTEM_ERROR           = 2
**      CREATE_ERROR                = 3
**      LIFETIME_ERROR              = 4
**      LIFETIME_DYNPRO_DYNPRO_LINK = 5.
***화면 분할
**  CREATE OBJECT GO_SPLITTER_0300
**    EXPORTING
**      PARENT  = GO_CONTAIN_DOCKING_0300
**      ROWS    = 3
**      COLUMNS = 1.
**
**  GO_SPLITTER_0300->SET_ROW_HEIGHT(
**    EXPORTING
**      ID                =    1              " Row ID
**      HEIGHT            =    5 ).             " Height
**
**  GO_SPLITTER_0300->SET_ROW_HEIGHT(
**    EXPORTING
**      ID                =    2              " Row ID
**      HEIGHT            =    25 ).             " Height
**
*** top 컨테이너(Title)
**  CALL METHOD GO_SPLITTER_0300->GET_CONTAINER
**    EXPORTING
**      ROW       = 1
**      COLUMN    = 1
**    RECEIVING
**      CONTAINER = GO_CONTAIN_TOP_0300.
*** top 컨테이너(Grid)
**  CALL METHOD GO_SPLITTER_0300->GET_CONTAINER
**    EXPORTING
**      ROW       = 2
**      COLUMN    = 1
**    RECEIVING
**      CONTAINER = GO_CONTAIN_0300.
*** bottom 컨테이너
**  CALL METHOD GO_SPLITTER_0300->GET_CONTAINER
**    EXPORTING
**      ROW       = 3
**      COLUMN    = 1
**    RECEIVING
**      CONTAINER = GO_CONTAIN_0301.


  CREATE OBJECT go_grid_0300
    EXPORTING
      i_parent      = go_contain_0300
      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_grid_0300 .

  CLEAR gs_layout_0300.
  gs_layout_0300-cwidth_opt = abap_true.
  gs_layout_0300-no_rowins = abap_true.
  gs_layout_0300-sel_mode   = 'D'.
  gs_layout_0300-no_rowmark   = 'X'.
  gs_layout_0300-stylefname   = 'CELLTAB'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0300 .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR2020TOP'
      i_internal_tabname     = 'GS_DETAIL'
    CHANGING
      ct_fieldcat            = lt_fcat_slis
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  REFRESH gt_fieldcat_0300.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat_slis
    IMPORTING
      et_fieldcat_lvc = gt_fieldcat_0300[]
    TABLES
      it_data         = gt_detail
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE gt_fieldcat_0300 ASSIGNING FIELD-SYMBOL(<ls_fcat>) WITH KEY fieldname = 'CHECK'.
  IF sy-subrc EQ 0.
  ELSE.
    APPEND INITIAL LINE TO gt_fieldcat_0300 ASSIGNING <ls_fcat>.
  ENDIF.
  <ls_fcat>-fieldname = 'CHECK'.
  <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '체크'(f01).
  <ls_fcat>-col_pos = 1.
  <ls_fcat>-datatype = 'CHAR'.
  <ls_fcat>-dd_outlen = '1'.
  <ls_fcat>-checkbox = 'X'.
  <ls_fcat>-edit = abap_true.
  <ls_fcat>-just = 'C'.

  READ TABLE gt_fieldcat_0300 ASSIGNING <ls_fcat> WITH KEY fieldname = 'GRPNR'.
  IF sy-subrc EQ 0.
  ELSE.
    APPEND INITIAL LINE TO gt_fieldcat_0300 ASSIGNING <ls_fcat>.
  ENDIF.
  <ls_fcat>-fieldname = 'GRPNR'.
  <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '조장표번호'(f02).
  <ls_fcat>-col_pos = 3.
  <ls_fcat>-datatype = 'CHAR'.
  <ls_fcat>-dd_outlen = '20'.
  <ls_fcat>-just = 'C'.

  READ TABLE gt_fieldcat_0300 ASSIGNING <ls_fcat> WITH KEY fieldname = 'ORDSTAT'.
  IF sy-subrc EQ 0.
  ELSE.
    APPEND INITIAL LINE TO gt_fieldcat_0300 ASSIGNING <ls_fcat>.
  ENDIF.
  <ls_fcat>-fieldname = 'ORDSTAT'.
  <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '오더 상태'(f14).
  <ls_fcat>-col_pos = 6.
  <ls_fcat>-datatype = 'CHAR'.
  <ls_fcat>-dd_outlen = '20'.
  <ls_fcat>-just = 'C'.

  READ TABLE gt_fieldcat_0300 ASSIGNING <ls_fcat> WITH KEY fieldname = 'CHG_ARBPL'.
  IF sy-subrc EQ 0.
  ELSE.
    APPEND INITIAL LINE TO gt_fieldcat_0300 ASSIGNING <ls_fcat>.
  ENDIF.
  <ls_fcat>-fieldname = 'CHG_ARBPL'.
  <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = 'CHG_ARBPL'.
  <ls_fcat>-col_pos = 100.
  <ls_fcat>-datatype = 'CHAR'.
  <ls_fcat>-dd_outlen = '1'.
  <ls_fcat>-no_out = 'X'.

  READ TABLE gt_fieldcat_0300 ASSIGNING <ls_fcat> WITH KEY fieldname = 'CHG_PIROTY'.
  IF sy-subrc EQ 0.
  ELSE.
    APPEND INITIAL LINE TO gt_fieldcat_0300 ASSIGNING <ls_fcat>.
  ENDIF.
  <ls_fcat>-fieldname = 'CHG_PIROTY'.
  <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = 'CHG_PIROTY'.
  <ls_fcat>-col_pos = 101.
  <ls_fcat>-datatype = 'CHAR'.
  <ls_fcat>-dd_outlen = '1'.
  <ls_fcat>-no_out = 'X'.

  READ TABLE gt_fieldcat_0300 ASSIGNING <ls_fcat> WITH KEY fieldname = 'CHG_PLAN'.
  IF sy-subrc EQ 0.
  ELSE.
    APPEND INITIAL LINE TO gt_fieldcat_0300 ASSIGNING <ls_fcat>.
  ENDIF.
  <ls_fcat>-fieldname = 'CHG_PLAN'.
  <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = 'CHG_PLAN'.
  <ls_fcat>-col_pos = 102.
  <ls_fcat>-datatype = 'CHAR'.
  <ls_fcat>-dd_outlen = '1'.
  <ls_fcat>-no_out = 'X'.

  LOOP AT gt_fieldcat_0300 ASSIGNING <ls_fcat>.
    CASE   <ls_fcat>-fieldname.
      WHEN 'STATUS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '상태'(f15).
        <ls_fcat>-just = 'C'.
        <ls_fcat>-icon = 'X'.
      WHEN 'GRPNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '조장표번호'(f02).
        <ls_fcat>-just = 'C'.
      WHEN 'MATNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '자재코드'(f16).
        <ls_fcat>-just = 'C'.
      WHEN 'ORDNO'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '생산오더'(f17).
        <ls_fcat>-just = 'C'.
      WHEN 'POSNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '오더품목'(f18).
        <ls_fcat>-just = 'C'.
      WHEN 'MAKTX'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '자재내역'(f19).
        <ls_fcat>-just = 'L'.
      WHEN 'PSMNG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '오더수량'(f20).
        <ls_fcat>-just = 'R'.
      WHEN 'INLENGTH'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '조장'(f11).
        <ls_fcat>-just = 'R'.
      WHEN 'AMEIN'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '단위'(f12).
        <ls_fcat>-just = 'C'.
      WHEN 'ARBPL'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '설비'(f21).
        <ls_fcat>-just = 'C'.
        <ls_fcat>-edit = 'X'.
        <ls_fcat>-f4availabl = 'X'.
      WHEN 'KTEXT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '설비명'(f22).
        <ls_fcat>-just = 'L'.
      WHEN 'GSTRP'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '시작일'(f23).
        <ls_fcat>-just = 'C'.
        <ls_fcat>-edit = 'X'.
      WHEN 'GSUZP_HHMM'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '시작시간'(f24).
        <ls_fcat>-just = 'C'.
        <ls_fcat>-edit = 'X'.
      WHEN 'GLTRP'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '종료일'(f25).
        <ls_fcat>-just = 'C'.
        <ls_fcat>-edit = 'X'.
      WHEN 'GLUZP_HHMM'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '종료시간'(f26).
        <ls_fcat>-just = 'C'.
        <ls_fcat>-edit = 'X'.
      WHEN 'ZZPRIORITY'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '우선순위'(f27).
        <ls_fcat>-just = 'C'.
        <ls_fcat>-edit = 'X'.
      WHEN 'QLENGTH'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '검사여장'(f28).
        <ls_fcat>-just = 'R'.
      WHEN 'ADLENGTH'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '추가여장'(f29).
        <ls_fcat>-just = 'R'.
      WHEN 'CLENGTH'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '연결여장'(f30).
        <ls_fcat>-just = 'R'.
      WHEN 'INFACTOR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '조장수'(f13).
        <ls_fcat>-just = 'R'.
      WHEN 'MATNR_SO'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '완제품 자재'(f31).
        <ls_fcat>-just = 'C'.
      WHEN 'MAKTX_SO'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '완제품 자재내역'(f32).
        <ls_fcat>-just = 'L'.

      WHEN 'GSUZP' OR 'GLUZP'.
        <ls_fcat>-no_out = abap_true.

    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_cell_attribute_grid_0300 .

  DATA : lt_celltab TYPE lvc_t_styl.
  DATA : ls_celltab TYPE lvc_s_styl.
  DATA : lt_detail LIKE gt_detail.
  DATA : lt_tj02t LIKE tj02t OCCURS 0 WITH HEADER LINE.
  DATA : lv_stcd TYPE zordstcd.


  LOOP AT gt_detail ASSIGNING FIELD-SYMBOL(<ls_main_disp>).
    REFRESH lt_celltab.

    LOOP AT gt_fieldcat_0300 INTO DATA(ls_fieldcat).
      CASE ls_fieldcat-fieldname.
        WHEN 'GRPNR' OR 'ORDNO' OR 'POSNR' OR 'MATNR' OR 'ORDSTAT'.
*       key 색깔지정
          CLEAR ls_celltab.
          ls_celltab-fieldname = ls_fieldcat-fieldname.
          ls_celltab-style = alv_style_color_int_key.
          INSERT ls_celltab INTO TABLE lt_celltab.
        WHEN 'ARBPL' OR 'GSTRP' OR 'GSUZP_HHMM' OR 'GLTRP' OR 'GLUZP_HHMM' OR 'ZZPRIORITY'.
          IF <ls_main_disp>-ordstat = '작업완료'.
            CLEAR ls_celltab.
            ls_celltab-fieldname = ls_fieldcat-fieldname.
            ls_celltab-style = alv_style_disabled.
            INSERT ls_celltab INTO TABLE lt_celltab.
            CONTINUE.
          ENDIF.
          REFRESH lt_detail.
          lt_detail = VALUE #( FOR ws_detail IN gt_detail WHERE ( ordno = <ls_main_disp>-ordno ) ( CORRESPONDING  #( ws_detail ) ) ).
          IF lines( lt_detail ) > 1 AND <ls_main_disp>-posnr > 1.
            CLEAR ls_celltab.
            ls_celltab-fieldname = ls_fieldcat-fieldname.
            ls_celltab-style = alv_style_disabled.
            INSERT ls_celltab INTO TABLE lt_celltab.
            CONTINUE.
          ENDIF.

          IF ls_fieldcat-fieldname = 'ARBPL' AND <ls_main_disp>-ordstat = '작업중'.
            CLEAR ls_celltab.
            ls_celltab-fieldname = ls_fieldcat-fieldname.
            ls_celltab-style = alv_style_disabled.
            INSERT ls_celltab INTO TABLE lt_celltab.
            CONTINUE.
          ENDIF.

      ENDCASE.
    ENDLOOP.
    <ls_main_disp>-celltab = lt_celltab.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_of_toolbar_grid_0300 .

  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0300
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
*& Form CALL_GRID_0300_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_grid_0300_display .

  CALL METHOD go_grid_0300->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0300
      it_toolbar_excluding = gt_exclude_0300
    CHANGING
      it_outtab            = gt_detail
*     IT_SORT              = GT_SORT_0200
      it_fieldcatalog      = gt_fieldcat_0300.

* 인풋이벤트 추가
  CALL METHOD go_grid_0300->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CALL METHOD go_grid_0300->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

*  IF GO_DD_DOCU_0300 IS BOUND.
*    CALL METHOD GO_DD_DOCU_0300->INITIALIZE_DOCUMENT.
*  ELSE.
*    CREATE OBJECT GO_DD_DOCU_0300
*      EXPORTING
*        STYLE = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
*  ENDIF.
*
*  CALL METHOD GO_GRID_0300->LIST_PROCESSING_EVENTS
*    EXPORTING
*      I_EVENT_NAME = 'TOP_OF_PAGE'
*      I_DYNDOC_ID  = GO_DD_DOCU_0300.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0301
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_object_grid_0301 .

  CREATE OBJECT go_grid_merge_301
    EXPORTING
      i_parent = go_contain_0301.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0301
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_grid_0301 .

  CLEAR gs_layout_merge.
  gs_layout_merge-stylefname = 'CELL'.
  gs_layout_merge-no_headers = 'X'.
  gs_layout_merge-cwidth_opt = ' '.
  gs_layout_merge-no_toolbar = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0301_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_grid_0301_display .

  PERFORM make_disp_grid_0100.

  CALL METHOD go_grid_merge_301->set_table_for_first_display
    EXPORTING
*     IS_VARIANT      = GS_VARIANT_MERGE
      is_layout       = gs_layout_merge
    CHANGING
      it_fieldcatalog = gt_fieldcat_set_merge
      it_outtab       = <gt_set_schedule>.

  go_grid_merge_301->set_ready_for_input( 1 ).
*  CALL METHOD GO_GRID_MERGE->Z_LVC_TABLE_FILL
*    EXPORTING
*      LASTLINE = LINES( <GT_SET_SCHEDULE> ).


  PERFORM set_merge USING go_grid_merge_301.
  go_grid_merge_301->z_display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHECK_BOX_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_check_box_grid_0300 .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PV_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM set_title_0300  CHANGING pv_dyndoc_id  TYPE REF TO  cl_dd_document.

  DATA : lv_text(255) TYPE c.
  DATA : lv_frdate_c(10).
  DATA : lv_todate_c(10).

* 공정
  IF p_gongcd IS INITIAL OR p_gongcd = '*'.
    CONCATENATE '공정 :' 'ALL' INTO lv_text SEPARATED BY space.
  ELSE.

    SELECT SINGLE gong_nm INTO p_gongnm
             FROM zedt0011
            WHERE gong_cd EQ p_gongcd.

    lv_text = p_gongnm && '(' && p_gongcd && ')'.
    CONCATENATE '공정 :' lv_text INTO lv_text SEPARATED BY space.
  ENDIF.

  "텍스트 추가
  CALL METHOD pv_dyndoc_id->add_text
    EXPORTING
      text         = lv_text
      sap_fontsize = '20'.

  CALL METHOD pv_dyndoc_id->new_line.

* 생산시작일
  CLEAR lv_text.
  lv_frdate_c = s_gstrp-low+0(4) && '.' && s_gstrp-low+4(2) && '.' && s_gstrp-low+6(2).
  lv_todate_c = s_gstrp-high+0(4) && '.' && s_gstrp-high+4(2) && '.' && s_gstrp-high+6(2).

  CONCATENATE '생산 시작일 :' lv_frdate_c '~' lv_todate_c INTO lv_text SEPARATED BY space.

  "텍스트 추가
  CALL METHOD pv_dyndoc_id->add_text
    EXPORTING
      text         = lv_text
      sap_fontsize = '20'.

  CALL METHOD pv_dyndoc_id->new_line.

  "위쪽에 추가한 텍스트 출력
  CALL METHOD go_dd_docu_0300->display_document
    EXPORTING
      parent = go_contain_top_0300.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_F4_FIELD_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_f4_field_grid_0300 .

  DATA : lt_f4 TYPE lvc_t_f4,
         ls_f4 TYPE lvc_s_f4.

  CLEAR : lt_f4.

  ls_f4-fieldname = 'ARBPL'.  "F4적용 필드
  ls_f4-register  = 'X'.        "이 부분을 X해줘야 사용할 수 있음
  ls_f4-getbefore = ''.         "F4하기 전에 데이터 체인지 이벤트를 먼저 탐
  ls_f4-chngeafter = ''.         "F4에서 값 선택 후 데이터 체인지 이벤트 탐

  APPEND ls_f4 TO lt_f4.



  CALL METHOD go_grid_0300->register_f4_for_fields
    EXPORTING
      it_f4 = lt_f4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_ONF4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_FIELDNAME
*&      --> E_FIELDVALUE
*&      --> ES_ROW_NO
*&      --> ER_EVENT_DATA
*&      --> ET_BAD_CELLS
*&      --> E_DISPLAY
*&---------------------------------------------------------------------*
FORM alv_onf4  USING    po_sender TYPE REF TO cl_gui_alv_grid
                        pv_fieldname TYPE lvc_fname
                        pv_fieldvalue TYPE lvc_value
                        ps_row_no  TYPE lvc_s_roid
                        pr_event_data TYPE REF TO cl_alv_event_data
                        pt_bad_cells TYPE lvc_t_modi
                        pv_display TYPE char01.

  FIELD-SYMBOLS : <lt_data> TYPE table.
  FIELD-SYMBOLS : <lv_value> TYPE any.


  CASE po_sender.
    WHEN go_grid_0300.
      PERFORM f4_arbpl USING pv_fieldname
                               CHANGING pv_fieldvalue.

      pr_event_data->m_event_handled = 'X'.   "스탠다드 F4는 무시
      IF pv_fieldvalue IS INITIAL.
        RETURN.
      ENDIF.

      ASSIGN pr_event_data->m_data->* TO <lt_data>.
      APPEND INITIAL LINE TO <lt_data> ASSIGNING FIELD-SYMBOL(<fs_f4>).
      IF <lv_value> IS ASSIGNED. UNASSIGN <lv_value>. ENDIF.
      ASSIGN COMPONENT 'ROW_ID' OF STRUCTURE <fs_f4> TO <lv_value>.
      IF <lv_value> IS ASSIGNED.
        <lv_value> = ps_row_no-row_id.
      ENDIF.
      IF <lv_value> IS ASSIGNED. UNASSIGN <lv_value>. ENDIF.
      ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE <fs_f4> TO <lv_value>.
      IF <lv_value> IS ASSIGNED.
        <lv_value> = pv_fieldname.
      ENDIF.
      IF <lv_value> IS ASSIGNED. UNASSIGN <lv_value>. ENDIF.
      ASSIGN COMPONENT 'VALUE' OF STRUCTURE <fs_f4> TO <lv_value>.
      IF <lv_value> IS ASSIGNED.
        <lv_value> = pv_fieldvalue.
      ENDIF.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_ARBPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_FIELDNAME
*&      <-- PV_FIELDVALUE
*&---------------------------------------------------------------------*
FORM f4_arbpl  USING    pv_fieldname TYPE lvc_fname
               CHANGING pv_fieldvalue TYPE lvc_value.

  DATA : BEGIN OF ls_table,
           gong_cd TYPE zgtppt2060-gong_cd,
           arbpl   TYPE zgtppt2060-arbpl,
           ktext   TYPE crtx-ktext,
         END OF ls_table.
  DATA : lt_table LIKE TABLE OF ls_table.
  DATA : lv_fieldname TYPE  lvc_fname.

  DATA : lt_return_tab TYPE TABLE OF ddshretval,
         ls_return_tab LIKE LINE OF lt_return_tab.

  LOOP AT gt_gong_cd INTO gs_gong_cd WHERE gong_cd = p_gongcd.
    APPEND INITIAL LINE TO lt_table ASSIGNING FIELD-SYMBOL(<ls_table>).
    <ls_table>-gong_cd = gs_gong_cd-gong_cd.
    <ls_table>-arbpl = gs_gong_cd-arbpl.
    <ls_table>-ktext = gs_gong_cd-ktext.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      retfield        = pv_fieldname
*     DYNPPROG        = SY-CPROG                 "현재 프로그램명->ZTER0010
*     DYNPNR          = SY-DYNNR                 "현재 화면번호->0100
      dynprofield     = 'ARBPL'           "F4누른 필드->DEPT_CD
      value_org       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      window_title    = '설비조회'   "Search Help 타이틀
      display         = 'F'
    TABLES
      value_tab       = lt_table                  "부서코드, 부서명 가져온 인터널 테이블
      return_tab      = lt_return_tab            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  READ TABLE lt_return_tab INTO ls_return_tab INDEX 1.
  pv_fieldvalue = ls_return_tab-fieldval.   "F4에서 선택한 값을 다시 넣어줌

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ARBPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM check_arbpl     USING pv_arbpl
                                         pv_matnr TYPE matnr
                           CHANGING pv_ktext
                                         pv_chk_err.

  SELECT a~arbpl
    FROM mapl AS m
    INNER JOIN plpo AS b
                           ON b~plnnr = m~plnnr
                          AND b~plnty = m~plnty
    INNER JOIN crhd AS a
                          ON a~objid = b~arbid
    WHERE m~matnr = @pv_matnr
         AND m~werks = @p_werks
         AND a~objty = 'A'
         AND m~plnty = 'N'
         AND a~arbpl = @pv_arbpl
        INTO TABLE @DATA(lt_chk_arbpl).

  IF sy-subrc EQ 0.
    CLEAR gs_gong_cd.
    READ TABLE gt_gong_cd INTO gs_gong_cd WITH KEY gong_cd = p_gongcd
                                                                                 arbpl = pv_arbpl.
    IF sy-subrc EQ 0.
      pv_ktext = gs_gong_cd-ktext.
    ELSE.
      CLEAR pv_ktext.
      pv_chk_err = abap_true.
    ENDIF.
  ELSE.
    CLEAR pv_ktext.
    pv_chk_err = abap_true.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_PRD_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_prd_order USING pv_command.

  DATA : lv_seq_c(12).
  CLEAR gs_make_order.
  gs_make_order-werks = p_werks.
  IF p_gongnm IS INITIAL.
    SELECT SINGLE gong_nm INTO p_gongnm
             FROM zedt0011
            WHERE gong_cd EQ p_gongcd.
    gs_make_order-gong_nm = p_gongnm && '(' && p_gongcd && ')'.
  ELSE.
    gs_make_order-gong_nm = p_gongnm && '(' && p_gongcd && ')'.
  ENDIF.

  gs_make_order-gmein = 'M'.
  gs_make_order-gluzp = '240000'.
  gs_make_order-seq = 1.

  CLEAR gv_chk_create.
  CLEAR gv_create_command.
  gv_create_command = pv_command.
  CALL SCREEN '0400' STARTING AT 5 5 ENDING AT 76 17.
  IF gv_chk_create = 'E'. " 메시지처리후 종료
    MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-e09.
  ELSEIF gv_chk_create = 'S'. "리프레쉬루 성공메시지처리
    WAIT UP TO '0.5' SECONDS.
    PERFORM refresh_screen_200.
    lv_seq_c = gs_make_order-seq.
    CONDENSE lv_seq_c.
    MESSAGE s006  WITH TEXT-e10 lv_seq_c TEXT-e11.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  F4HELP_MATNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4help_matnr INPUT.

  DATA : BEGIN OF ls_matnr,
           matnr TYPE matnr,
           maktx TYPE maktx,
         END OF ls_matnr.
  DATA : lt_matnr LIKE TABLE OF ls_matnr.

  DATA : lt_return_tab TYPE TABLE OF ddshretval,
         ls_return_tab LIKE LINE OF lt_return_tab.

  SELECT matnr maktx
     FROM zgtcvmstval
       INTO CORRESPONDING FIELDS OF TABLE lt_matnr
     WHERE werks = p_werks
       AND pdcaproccode = p_gongcd
       AND mmsta = space.

  SORT lt_matnr BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_matnr COMPARING matnr.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      retfield        = 'MATNR'
*     DYNPPROG        = SY-CPROG                 "현재 프로그램명->ZTER0010
*     DYNPNR          = SY-DYNNR                 "현재 화면번호->0100
      dynprofield     = 'GS_MAKE_ORDER-MATNR'           "F4누른 필드->DEPT_CD
      value_org       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      window_title    = '자재코드 조회'   "Search Help 타이틀
      display         = 'F'
    TABLES
      value_tab       = lt_matnr                  "부서코드, 부서명 가져온 인터널 테이블
      return_tab      = lt_return_tab            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  READ TABLE lt_return_tab INTO ls_return_tab INDEX 1.
  IF sy-subrc EQ 0.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input        = ls_return_tab-fieldval
      IMPORTING
        output       = gs_make_order-matnr
      EXCEPTIONS
        length_error = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    READ TABLE lt_matnr INTO ls_matnr WITH KEY matnr = gs_make_order-matnr.
    gs_make_order-maktx = ls_matnr-maktx.

    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        functioncode           = 'ENTE'              " Function code
      EXCEPTIONS
        function_not_supported = 1                " Not supported on this front end platform
        OTHERS                 = 2.

  ENDIF.



ENDMODULE.
*&---------------------------------------------------------------------*
*& Form CHECK_AND_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_and_create .

  DATA : lv_message(100).
  DATA : lv_chk_err.
*  필드 빈값 체크
  CLEAR lv_message.
  PERFORM screen_400_chk_init CHANGING lv_message.
  IF lv_message IS NOT INITIAL.
    MESSAGE i003 WITH lv_message.
    RETURN.
  ENDIF.

  PERFORM screen_400_chk_validation  CHANGING lv_message.
  IF lv_message IS NOT INITIAL.
    MESSAGE i003 WITH lv_message.
    RETURN.
  ENDIF.

  PERFORM create_orders CHANGING lv_chk_err.
  IF lv_chk_err IS NOT INITIAL.
    gv_chk_create = 'E'. " 실패
  ELSE.
    gv_chk_create = 'S'. " 성공
  ENDIF.
  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form screen_400_chk_init
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_MESSAGE
*&---------------------------------------------------------------------*
FORM screen_400_chk_init  CHANGING pv_message.

  IF gs_make_order-matnr IS INITIAL.
    pv_message = TEXT-e01.
  ENDIF.

  IF gs_make_order-gamng IS INITIAL OR gs_make_order-gamng = 0.
    pv_message = TEXT-e02.
  ENDIF.


  IF gs_make_order-gstrp IS INITIAL OR gs_make_order-gstrp = '00000000'.
    pv_message = TEXT-e03.
  ENDIF.

  IF gs_make_order-gltrp IS INITIAL OR gs_make_order-gltrp = '00000000'.
    pv_message = TEXT-e04.
  ENDIF.

  IF gs_make_order-inlength IS INITIAL OR gs_make_order-inlength = 0.
    pv_message = TEXT-e05.
  ENDIF.

  IF gs_make_order-infactor IS INITIAL OR gs_make_order-infactor = 0.
    pv_message = TEXT-e06.
  ENDIF.

  IF gs_make_order-seq IS INITIAL OR gs_make_order-seq = 0.
    pv_message = TEXT-e17.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCREEN_400_chk_validation
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_MESSAGE
*&---------------------------------------------------------------------*
FORM screen_400_chk_validation  CHANGING pv_message.

  DATA : lv_frdate(14).
  DATA : lv_todate(14).
  DATA : lv_total TYPE afko-gamng.

* 생산자재
  SELECT * FROM zgtcvmstval
       INTO TABLE @DATA(lt_matnr)
     WHERE werks = @p_werks
       AND pdcaproccode = @p_gongcd
       AND matnr = @gs_make_order-matnr
       AND mmsta = @space.
  IF sy-subrc NE 0.
    pv_message = TEXT-e07.
    RETURN.
  ENDIF.

  lv_total = ( gs_make_order-inlength * gs_make_order-infactor ) + gs_make_order-qlength .
  IF lv_total NE gs_make_order-gamng.
    pv_message = TEXT-e18.
    RETURN.
  ENDIF.

  lv_frdate = gs_make_order-gstrp && gs_make_order-gsuzp.
  lv_todate = gs_make_order-gltrp && gs_make_order-gluzp.

  IF lv_frdate >= lv_todate.
    pv_message = TEXT-e08.
    RETURN.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ORDERS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM create_orders  CHANGING pv_chk_err.

  DATA : lt_prd_orders TYPE tb_bapi_order_key.
  DATA : ls_order TYPE bapi_pp_order_create.
  DATA: ls_return TYPE bapiret2.
  DATA : lv_order_number TYPE bapi_order_key-order_number.

  DO gs_make_order-seq TIMES.
    CLEAR : ls_order, ls_return, lv_order_number.
*  오더 생성
    ls_order-material = gs_make_order-matnr.
    ls_order-plant = p_werks.
    IF gv_create_command = 'CR_ORDER'.
      ls_order-order_type = 'PP01'.
    ELSEIF gv_create_command = 'CR_SI_ORDER'.
      ls_order-order_type = 'PL01'.
      ls_order-order_priority = '6'.
*   2026.07.22.zlsgpp5.SRM2607-09012.재생산오더 생성 기능추가.
*     우선순위는 ZPPT0000-keyid:APRIO 값 참고.
    ELSEIF gv_create_command = 'CR_RP_ORDER'.
      ls_order-order_type = 'RP01'.
      ls_order-order_priority = '9'.
    ENDIF.
    ls_order-basic_start_date = gs_make_order-gstrp.
    ls_order-basic_start_time = gs_make_order-gsuzp.
    ls_order-basic_end_date = gs_make_order-gltrp.
    ls_order-basic_end_time = gs_make_order-gluzp.
    ls_order-quantity = gs_make_order-gamng.
    ls_order-basic_scheduling_type = '7'.

    CALL FUNCTION 'BAPI_PRODORD_CREATE'
      EXPORTING
        orderdata    = ls_order
      IMPORTING
        return       = ls_return
        order_number = lv_order_number.

    IF ls_return-type NE 'E'.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.

*      커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
      DO .
        SELECT SINGLE aufnr, posnr
          FROM afpo
         WHERE aufnr = @lv_order_number
          INTO @DATA(ls_afpo).
        IF sy-subrc EQ 0.
          EXIT.
        ELSE.
          WAIT UP TO '0.5' SECONDS.
        ENDIF.
      ENDDO.

      PERFORM chang_bdc_jojang USING lv_order_number pv_chk_err.
      IF pv_chk_err = abap_true.
        PERFORM rollback_ordes TABLES lt_prd_orders.
        RETURN.
      ENDIF.

      APPEND INITIAL LINE TO lt_prd_orders ASSIGNING FIELD-SYMBOL(<ls_order>).
      <ls_order>-order_number =  lv_order_number.
    ELSE.
      PERFORM rollback_ordes TABLES lt_prd_orders.
      pv_chk_err = abap_true.
      RETURN.
    ENDIF.

  ENDDO.

  DATA : lt_zpptc002 TYPE TABLE OF zpptc002.
  LOOP AT lt_prd_orders INTO DATA(ls_prd_orders).
    APPEND INITIAL LINE TO lt_zpptc002 ASSIGNING FIELD-SYMBOL(<ls_save_data>).
    <ls_save_data>-aufnr = ls_prd_orders-order_number.
    <ls_save_data>-posnr = '0001'.
    <ls_save_data>-psamg = gs_make_order-qlength.
  ENDLOOP.

  IF lt_zpptc002[] IS NOT INITIAL.
    MODIFY zpptc002 FROM TABLE lt_zpptc002.
    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANG_BDC_JOJANG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM chang_bdc_jojang  USING  pv_aufnr
                                                 pv_chk_err.

  DATA : lv_inlength TYPE i.
  DATA : lv_inlength_c(10) TYPE c.
  DATA : lv_infactor TYPE i.
  DATA : lv_infactor_c(10) TYPE c.
  REFRESH : gt_bdcdata, gt_messtab.

  lv_inlength = gs_make_order-inlength.
  lv_inlength_c = lv_inlength.
  CONDENSE lv_inlength_c.

  lv_infactor = gs_make_order-infactor.
  lv_infactor_c = lv_infactor.
  CONDENSE lv_infactor_c.

  __setting_bdc_params.

  __bdc_dynpro 'SAPLCOKO1' '0110'.
  __bdc_field : 'CAUFVD-AUFNR' pv_aufnr,
                      'R62CLORD-FLG_OVIEW'  'X',
                      'BDC_OKCODE' '=ENTK'.

  __bdc_dynpro 'SAPLCOKO1' '0115'.
  __bdc_field : 'BDC_OKCODE' '=KOTA'. " 빠른입력화면으로 전환


  __bdc_dynpro 'SAPLCOKO1' '0115'.
  __bdc_field :  'BDC_OKCODE' '=MILL_BT_SEL_ALL'.

  __bdc_dynpro 'SAPLCOKO1' '0115'.
  __bdc_field :  'BDC_OKCODE' '=MILL_BT_CONFIG'.

  __bdc_dynpro 'SAPLCOKO1' '0115'.
  __bdc_field :  'BDC_OKCODE' '=MILL_BT_CONFIG'.

  __bdc_dynpro 'SAPLCEI0' '0109'.
  __bdc_field : 'RCTMS-MNAME(01)' '조장(기본단위)',
                      'RCTMS-MNAME(02)' '조장수',
                      'RCTMS-MNAME(03)' '전선_공정코드',
                      'RCTMS-MWERT(01)' lv_inlength_c,
                      'RCTMS-MWERT(02)' lv_infactor_c,
                      'RCTMS-MWERT(03)' p_gongcd,
                      'BDC_OKCODE' '=BACK'.


  __bdc_dynpro 'SAPLCOKO1' '0115'.
  __bdc_field : 'BDC_OKCODE' '=BU'.

  __bdc_transaction 'CO02'.
  LOOP AT gt_messtab INTO DATA(ls_messtab) WHERE msgtyp = 'A'
                                                         OR msgtyp = 'E'
                                                         OR msgtyp = 'X'.
    pv_chk_err = 'E'.
    RETURN.
  ENDLOOP.

  COMMIT WORK AND  WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ROLLBACK_ORDES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_PRD_ORDERS
*&---------------------------------------------------------------------*
FORM rollback_ordes  TABLES   pt_prd_orders STRUCTURE bapi_order_key.

  DATA : ls_return2 TYPE bapiret2.
  DATA : lt_detail_return TYPE bapi_order_return_tt.

  CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
    IMPORTING
      return        = ls_return2
    TABLES
      orders        = pt_prd_orders[]
      detail_return = lt_detail_return.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_SCREEN_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_screen_200 .

  PERFORM get_main_data.
  PERFORM set_order_schedule.
  PERFORM make_order_info.

  PERFORM set_cell_attribute_grid_0200 .
  PERFORM refresh_grid USING go_grid_0200.
  PERFORM refresh_grid_merge USING go_grid_merge_201.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID_MERGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_MERGE_201
*&---------------------------------------------------------------------*
FORM refresh_grid_merge  USING    po_grid_merge TYPE REF TO zcl_gui_alv_grid.

  DATA: ls_scroll   TYPE lvc_s_stbl.

  ls_scroll-row = 'X'.
  ls_scroll-col = 'X'.

  PERFORM make_disp_grid_0100.

  CALL METHOD po_grid_merge->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = ls_scroll.

  po_grid_merge->set_ready_for_input( 1 ).

  PERFORM set_merge USING po_grid_merge.
  po_grid_merge->z_display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_BATCH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM change_batch .

  DATA : lv_chk_err.
  DATA : lv_chk_err01.
  DATA : lv_ktext TYPE crtx-ktext.

  READ TABLE gt_detail TRANSPORTING NO FIELDS WITH KEY check = abap_true.
  IF sy-subrc NE 0.
    MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-e12.
    RETURN.
  ENDIF.

  READ TABLE gt_detail TRANSPORTING NO FIELDS WITH KEY check = abap_true
                                                                                    ordstat = '작업완료'.
  IF sy-subrc EQ 0.
    MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-e25.
    RETURN.
  ENDIF.

  READ TABLE gt_detail TRANSPORTING NO FIELDS WITH KEY check = abap_true
                                                                                    ordstat = '작업중'.
  IF sy-subrc EQ 0.
    MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-e24.
    RETURN.
  ENDIF.

  REFRESH gt_disp_300_arbpl.
  LOOP AT gt_gong_cd INTO gs_gong_cd.
    APPEND INITIAL LINE TO gt_disp_300_arbpl ASSIGNING FIELD-SYMBOL(<ls_arbpl>).
    <ls_arbpl>-ktext = gs_gong_cd-ktext.
    <ls_arbpl>-arbpl = gs_gong_cd-arbpl.
  ENDLOOP.

* 변경설비 선택화면
  CALL SCREEN '0410' STARTING AT 10 5 ENDING AT 90 15.

  REFRESH gt_mt_modi.

  IF gs_disp_300_arbpl IS NOT INITIAL.
    LOOP AT gt_detail ASSIGNING FIELD-SYMBOL(<ls_detail>) WHERE check = abap_true.
      CLEAR lv_chk_err.
      PERFORM check_arbpl USING gs_disp_300_arbpl-arbpl <ls_detail>-matnr CHANGING  lv_ktext lv_chk_err.
      IF lv_chk_err IS NOT INITIAL.
        lv_chk_err01 = abap_true.
        <ls_detail>-status =  icon_led_red .

      ELSE.
        <ls_detail>-status =  icon_change .
        <ls_detail>-ktext = gs_disp_300_arbpl-ktext.
        <ls_detail>-arbpl = gs_disp_300_arbpl-arbpl.
        <ls_detail>-chg_arbpl = abap_true.
      ENDIF.

    ENDLOOP.

    PERFORM refresh_grid_300 USING go_grid_0300.
    IF lv_chk_err01 IS NOT INITIAL.
      MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-e26.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0410
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_object_grid_0410 .

  CREATE OBJECT go_contain_0410
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

  CREATE OBJECT go_grid_0410
    EXPORTING
      i_parent      = go_contain_0410
      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0410
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_grid_0410 .

  gs_layout_0410-cwidth_opt = abap_true.
  gs_layout_0410-no_rowins = abap_true.
  gs_layout_0410-no_rowmark   = 'X'.
  gs_layout_0410-sel_mode   = 'C'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0410
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0410 .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR2020TOP'
      i_internal_tabname     = 'GS_DISP_300_ARBPL'
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
      et_fieldcat_lvc = gt_fieldcat_0410[]
    TABLES
      it_data         = gt_disp_300_arbpl
    EXCEPTIONS
      OTHERS          = 1.

  IF NOT line_exists( gt_fieldcat_0410[ fieldname = 'CHECK'] ).
    APPEND INITIAL LINE TO gt_fieldcat_0410 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    <ls_fcat>-fieldname = 'CHECK'.
    <ls_fcat>-datatype = 'CHAR'.
    <ls_fcat>-dd_outlen = '1'.
    <ls_fcat>-outputlen = '1'.
    <ls_fcat>-checkbox = abap_true.
  ENDIF.

  LOOP AT gt_fieldcat_0410 ASSIGNING <ls_fcat>.
    CASE   <ls_fcat>-fieldname.
      WHEN 'CHECK'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '선택'(f33).
        <ls_fcat>-edit = abap_true.
        <ls_fcat>-just = 'C'.
        <ls_fcat>-col_pos = 1.
      WHEN 'KTEXT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '작업장명'(f34).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'L'.
        <ls_fcat>-col_pos = 2.
      WHEN 'ARBPL'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '작업장'(f35).
        <ls_fcat>-just = 'C'.
        <ls_fcat>-col_pos = 3.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0410
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_of_toolbar_grid_0410 .

  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0410
        USING : cl_gui_alv_grid=>mc_fc_excl_all.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0410_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_grid_0410_display .

  CALL METHOD go_grid_0410->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0410
      it_toolbar_excluding = gt_exclude_0410
    CHANGING
      it_outtab            = gt_disp_300_arbpl
      it_fieldcatalog      = gt_fieldcat_0410.

* 인풋이벤트 추가
  CALL METHOD go_grid_0410->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CALL METHOD go_grid_0410->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0410  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0410 INPUT.

  CASE gv_ok_code5.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     종료
      CALL METHOD go_contain_0410->free.
      FREE : go_contain_0410, go_grid_0410.
      CALL METHOD cl_gui_cfw=>flush.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      CLEAR gv_dupl_chk.
      LOOP AT gt_disp_300_arbpl INTO DATA(ls_disp_arbpl) WHERE check = abap_true.
        ADD 1 TO gv_dupl_chk.
      ENDLOOP.

      IF gv_dupl_chk > 1.
        MESSAGE i003 DISPLAY LIKE 'E' WITH '하나의 작업장만 선택해 주세요.'(e22).
        RETURN.
      ENDIF.


      CLEAR gs_disp_arbpl.
      READ TABLE gt_disp_300_arbpl INTO gs_disp_300_arbpl WITH KEY check = abap_true.
      IF sy-subrc EQ 0.
*     종료
        CALL METHOD go_contain_0410->free.
        FREE : go_contain_0410, go_grid_0410.
        CALL METHOD cl_gui_cfw=>flush.
        LEAVE TO SCREEN 0.
      ELSE.
        MESSAGE i003 DISPLAY LIKE 'E' WITH '변경할 작업장을 선택해주세요.'(e23).
        RETURN.
      ENDIF.
    WHEN 'SETCHECK'.
      PERFORM set_checkbox.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_CHECKBOX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_checkbox .

  LOOP AT gt_disp_300_arbpl ASSIGNING FIELD-SYMBOL(<ls_disp_arbpl>).
    CLEAR <ls_disp_arbpl>-check.
  ENDLOOP.

  READ TABLE gt_disp_300_arbpl ASSIGNING <ls_disp_arbpl> INDEX gv_chk_line.
  <ls_disp_arbpl>-check = gv_chk_value.

  PERFORM refresh_grid USING go_grid_0410.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM change_plan USING pv_gubun.

  DATA : lt_detail LIKE TABLE OF gs_detail.
  DATA : lt_detail_chk LIKE TABLE OF gs_detail.
  DATA : lv_seconds TYPE i.

  READ TABLE gt_detail TRANSPORTING NO FIELDS WITH KEY check = abap_true.
  IF sy-subrc NE 0.
    MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-e13.
    RETURN.
  ENDIF.

  READ TABLE gt_detail TRANSPORTING NO FIELDS WITH KEY check = abap_true
                                                                                    ordstat = '작업완료'.
  IF sy-subrc EQ 0.
    MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-e25.
    RETURN.
  ENDIF.


  CLEAR gs_make_order.
  CLEAR gv_chk_create.
  gv_gubun = pv_gubun.

  gs_make_order-gluzp = '240000'.

  CALL SCREEN '0420' STARTING AT 5 5 ENDING AT 52 9.

  IF gv_chk_create IS INITIAL.
    RETURN.
  ELSE.

    IF gv_gubun = 'FR'.
      lt_detail_chk =   VALUE  #( FOR ws_detail IN gt_detail WHERE ( check = abap_true )
                                            ( CORRESPONDING #( ws_detail ) ) ).
      SORT lt_detail_chk BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_detail_chk COMPARING matnr.

      LOOP AT lt_detail_chk ASSIGNING FIELD-SYMBOL(<ls_detail_chk>).
        CLEAR lv_seconds.
        REFRESH lt_detail.
        lt_detail =   VALUE  #( FOR ws_detail IN gt_detail WHERE ( check = abap_true
                                                                                      AND   matnr  = <ls_detail_chk>-matnr )
                                       ( CORRESPONDING #( ws_detail ) ) ).
        LOOP AT lt_detail INTO DATA(ls_detail).
          PERFORM cal_end_date USING ls_detail CHANGING lv_seconds .
        ENDLOOP.

        PERFORM set_date USING lv_seconds CHANGING <ls_detail_chk> .

      ENDLOOP.
    ENDIF.

    LOOP AT gt_detail ASSIGNING FIELD-SYMBOL(<ls_detail>) WHERE check = abap_true.
      CASE gv_gubun.
        WHEN 'FR'.
          READ TABLE lt_detail_chk INTO DATA(ls_detail_chk) WITH KEY matnr = <ls_detail>-matnr.
          IF sy-subrc EQ 0.
            MOVE : ls_detail_chk-gstrp TO <ls_detail>-gstrp,
                       ls_detail_chk-gsuzp TO <ls_detail>-gsuzp,
                       ls_detail_chk-gltrp TO <ls_detail>-gltrp,
                       ls_detail_chk-gluzp TO <ls_detail>-gluzp,
                       ls_detail_chk-gsuzp_hhmm TO <ls_detail>-gsuzp_hhmm,
                       ls_detail_chk-gluzp_hhmm TO <ls_detail>-gluzp_hhmm.
          ENDIF.

        WHEN 'TO'.
          MOVE : gs_make_order-gltrp TO <ls_detail>-gltrp,
                     gs_make_order-gluzp TO <ls_detail>-gluzp.
          <ls_detail>-gluzp_hhmm = gs_make_order-gluzp+0(4).

      ENDCASE.

      <ls_detail>-status =  icon_change .
      <ls_detail>-chg_plan = abap_true.
    ENDLOOP.
    PERFORM refresh_grid_300 USING go_grid_0300.
    .
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0420  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0420 INPUT.

  CLEAR gv_ok_code6.
  gv_ok_code6 = sy-ucomm.

  CASE gv_ok_code6.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      PERFORM check_0420.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form CHECK_0420
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_0420 .

  DATA : lv_frdate(14).
  DATA : lv_todate(14).

  lv_todate = gs_make_order-gltrp && gs_make_order-gluzp.
  IF gv_gubun = 'TO'.
    LOOP AT gt_detail ASSIGNING FIELD-SYMBOL(<ls_detail>) WHERE check = abap_true.
      lv_frdate = <ls_detail>-gstrp && <ls_detail>-gsuzp.
      IF lv_frdate > lv_todate.
        MESSAGE i003 DISPLAY LIKE 'I' WITH TEXT-e08.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  gv_chk_create = 'S'. " 성공

  LEAVE TO SCREEN 0.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SHIFT_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM shift_plan .

  READ TABLE gt_detail TRANSPORTING NO FIELDS WITH KEY check = abap_true.
  IF sy-subrc NE 0.
    MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-e13.
    RETURN.
  ENDIF.

  READ TABLE gt_detail TRANSPORTING NO FIELDS WITH KEY check = abap_true
                                                                                    ordstat = '작업완료'.
  IF sy-subrc EQ 0.
    MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-e25.
    RETURN.
  ENDIF.

  CLEAR gv_chk_create.
  CLEAR : gs_shift_plan-date, gs_shift_plan-time.
  gs_shift_plan-back = abap_true.
  CALL SCREEN '0430' STARTING AT 5 5 ENDING AT 48 10.

  IF gv_chk_create IS INITIAL.
    RETURN.
  ELSE.

    LOOP AT gt_detail ASSIGNING FIELD-SYMBOL(<ls_detail>) WHERE check = abap_true.
      PERFORM cal_date CHANGING <ls_detail>.
      <ls_detail>-status =  icon_change .
      <ls_detail>-chg_plan = abap_true.

    ENDLOOP.
    PERFORM refresh_grid_300 USING go_grid_0300.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0430 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0430 OUTPUT.
  SET PF-STATUS '0430'.
  SET TITLEBAR '0430'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form CHECK_0430
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_0430 .

  IF ( gs_shift_plan-date IS INITIAL OR gs_shift_plan-date = '00000000' ) AND
    ( gs_shift_plan-time IS INITIAL OR gs_shift_plan-time = '000000' ).
    MESSAGE i003 WITH TEXT-e14.
    RETURN.
  ENDIF.

  gv_chk_create = 'S'. " 성공

  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form cal_date
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_DETAIL>
*&---------------------------------------------------------------------*
FORM cal_date  CHANGING ps_detail LIKE gs_detail.

  DATA : lv_second_date TYPE i.
  DATA : lv_second_time TYPE i.
  DATA : lv_second TYPE i.
  DATA : lv_direction TYPE tstr_direction.

  lv_second_date = gs_shift_plan-date * 86400.
  lv_second_time = gs_shift_plan-time * 3600.
  lv_second = lv_second_date + lv_second_time.
  CASE abap_true.
    WHEN gs_shift_plan-up.
      lv_direction = '-'.
    WHEN gs_shift_plan-back.
      lv_direction = '+'.
  ENDCASE.


  CALL FUNCTION 'TSTR_CALC_TIME'
    EXPORTING
      iv_begin_datelocal_req   = ps_detail-gstrp
      iv_begin_timelocal_req   = ps_detail-gsuzp
      iv_duration_integer      = lv_second
      iv_direction             = lv_direction
    IMPORTING
      ev_end_datelocal         = ps_detail-gstrp
      ev_end_timelocal         = ps_detail-gsuzp
    EXCEPTIONS
      fatal_error              = 1
      time_invalid             = 2
      time_missing             = 3
      tstream_not_loadable     = 4
      tstream_generation_error = 5
      parameter_error          = 6
      unspecified_error        = 7
      OTHERS                   = 8.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


  CALL FUNCTION 'TSTR_CALC_TIME'
    EXPORTING
      iv_begin_datelocal_req   = ps_detail-gltrp
      iv_begin_timelocal_req   = ps_detail-gluzp
      iv_duration_integer      = lv_second
      iv_direction             = lv_direction
    IMPORTING
      ev_end_datelocal         = ps_detail-gltrp
      ev_end_timelocal         = ps_detail-gluzp
    EXCEPTIONS
      fatal_error              = 1
      time_invalid             = 2
      time_missing             = 3
      tstream_not_loadable     = 4
      tstream_generation_error = 5
      parameter_error          = 6
      unspecified_error        = 7
      OTHERS                   = 8.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  ps_detail-gsuzp_hhmm = ps_detail-gsuzp+0(4).
  ps_detail-gluzp_hhmm = ps_detail-gluzp+0(4).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_screen .

  IF gv_mode_detail IS INITIAL.
    go_splitter_0200->set_row_height(
      EXPORTING
        id                =    2              " Row ID
        height            =    60 ).             " Height

    go_splitter_0200->set_row_height(
      EXPORTING
        id                =    3              " Row ID
        height            =    0 ).             " Height

  ELSE.
    go_splitter_0200->set_row_height(
      EXPORTING
        id                =    2              " Row ID
        height            =    0 ).             " Height

    go_splitter_0200->set_row_height(
      EXPORTING
        id                =    3              " Row ID
        height            =    60 ).             " Height

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_AND_REFRESH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_and_refresh .

  DATA : lv_chk_err.

  DATA : lt_save_tab LIKE gt_detail.

*  변경사항 확인
  IF NOT ( line_exists( gt_detail[ chg_arbpl = abap_true ] ) OR
           line_exists( gt_detail[ chg_piroty = abap_true ] ) OR
           line_exists( gt_detail[ chg_plan = abap_true ] ) ).
    MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-e14.
    RETURN.
  ENDIF.

  CLEAR gv_answer.
  PERFORM popup_to_confirm_step USING 'N'
    ' '
    '수정사항이 적용됩니다. 계속 진행 하시겠습니까?'
    '저장확인'.
  IF gv_answer NE 'J'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-tex.
    RETURN.
  ENDIF.

  CLEAR gv_chk_use_backup.

  CLEAR lv_chk_err.
  DATA : lv_number TYPE bapi_order_key-order_number.
  DATA : ls_orderdata TYPE bapi_pp_order_change.
  DATA : ls_orderdatax TYPE bapi_pp_order_changex.
  DATA : ls_return TYPE bapiret2.

  lt_save_tab = VALUE #( FOR lw_detail IN gt_detail WHERE ( chg_plan = abap_true ) ( CORRESPONDING #( lw_detail ) ) ).
  SORT lt_save_tab BY ordno.
  DELETE ADJACENT DUPLICATES FROM lt_save_tab COMPARING ordno.
* 일정변경 진행
  LOOP AT  lt_save_tab INTO gs_detail.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = gs_detail-ordno
      IMPORTING
        output = lv_number.

    ls_orderdata-basic_start_date = gs_detail-gstrp.
    ls_orderdata-basic_start_time = gs_detail-gsuzp.
    ls_orderdata-basic_end_date = gs_detail-gltrp.
    ls_orderdata-basic_end_time = gs_detail-gluzp.
    ls_orderdata-basic_scheduling_type = '7'.
    ls_orderdatax-basic_start_date = 'X'.
*    LS_ORDERDATAX-BASIC_START_TIME = 'X'.
    ls_orderdatax-basic_end_date = 'X'.
*    LS_ORDERDATAX-BASIC_END_TIME = 'X'.
    ls_orderdatax-basic_scheduling_type = 'X'.

    CALL FUNCTION 'BAPI_PRODORD_CHANGE'
      EXPORTING
        number     = lv_number
        orderdata  = ls_orderdata
        orderdatax = ls_orderdatax
      IMPORTING
        return     = ls_return.

    IF ls_return-type NE 'E'.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.

      IF p_gongcd = 'INS'.
        PERFORM set_dry_schedul USING lv_number gs_detail-posnr CHANGING lv_chk_err.
        IF lv_chk_err = abap_true.
          RETURN.
        ENDIF.

      ENDIF.
    ELSE.
      MESSAGE s006 DISPLAY LIKE 'E' WITH TEXT-e10 lv_number TEXT-e15.
      RETURN.
    ENDIF.
  ENDLOOP.

  WAIT UP TO 1 SECONDS.

* 설비변경
  REFRESH lt_save_tab.
  lt_save_tab = VALUE #( FOR lw_detail IN gt_detail WHERE ( chg_arbpl = abap_true ) ( CORRESPONDING #( lw_detail ) ) ).
  SORT lt_save_tab BY ordno.
  DELETE ADJACENT DUPLICATES FROM lt_save_tab COMPARING ordno.

  LOOP AT  lt_save_tab INTO gs_detail.
    PERFORM bdc_chg_batch USING gs_detail CHANGING lv_chk_err.
    IF lv_chk_err IS NOT INITIAL.
      MESSAGE s006 DISPLAY LIKE 'E' WITH TEXT-e10 lv_number TEXT-e15.
      RETURN.
    ENDIF.
  ENDLOOP.

* 우선순위 변경
  REFRESH lt_save_tab.
  lt_save_tab = VALUE #( FOR lw_detail IN gt_detail WHERE ( chg_piroty = abap_true ) ( CORRESPONDING #( lw_detail ) ) ).
  SORT lt_save_tab BY ordno.
  DELETE ADJACENT DUPLICATES FROM lt_save_tab COMPARING ordno.

  LOOP AT  lt_save_tab INTO gs_detail.
    PERFORM bdc_chg_piroty USING gs_detail CHANGING lv_chk_err.
    IF lv_chk_err IS NOT INITIAL.
      MESSAGE s006 DISPLAY LIKE 'E' WITH TEXT-e10 lv_number TEXT-e15.
      RETURN.
    ENDIF.
  ENDLOOP.

  WAIT UP TO 1 SECONDS.

  PERFORM refresh_screen_300.
  MESSAGE s003 WITH TEXT-e19.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form popup_to_confirm_step
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM popup_to_confirm_step  USING lp_opt
                                  lp_text1
                                  lp_text2
                                  lp_title.
  CLEAR gv_answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption  = lp_opt
      textline1      = lp_text1
      textline2      = lp_text2
      titel          = lp_title
      cancel_display = ''
    IMPORTING
      answer         = gv_answer.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_CHG_BATCH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DETAIL
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM bdc_chg_batch  USING    ps_detail STRUCTURE gs_detail
                            CHANGING pv_chk_err.

  DATA : lv_order_number TYPE aufnr.
  DATA : lt_operation  TYPE cose_t_operation.
  DATA : ls_result TYPE bapiret2.

  SELECT SINGLE a~arbpl, b~bmsch, b~vgw01, b~vge01, b~vgw02, b~vge02,
                     b~vgw03, b~vge03, b~vgw04, b~vge04 ,
                     b~vgw05, b~vge05, b~vgw06, b~vge06
    FROM mapl AS m
    INNER JOIN plpo AS b
                           ON b~plnnr = m~plnnr
                          AND b~plnty = m~plnty
    INNER JOIN crhd AS a
                          ON a~objid = b~arbid
    WHERE m~matnr = @ps_detail-matnr
         AND m~werks = @p_werks
         AND m~plnty = 'N'
         AND a~objty = 'A'
         AND a~arbpl = @ps_detail-arbpl
        INTO @DATA(ls_set_batch).

  CHECK sy-subrc EQ 0.

  lv_order_number = ps_detail-ordno.
  APPEND INITIAL LINE TO lt_operation ASSIGNING FIELD-SYMBOL(<ls_operation>).
  <ls_operation>-operation = '0010'.
* 설비
  <ls_operation>-work_center = ps_detail-arbpl.
  <ls_operation>-work_center_x = 'X'.
* 기준수량
  <ls_operation>-base_quantity = ls_set_batch-bmsch.
  <ls_operation>-base_quantity_x = 'X'.
* 가동준비
  <ls_operation>-standard_value_01 = ls_set_batch-vgw01.
  <ls_operation>-standard_value_01_unit = ls_set_batch-vge01.
  <ls_operation>-standard_value_01_x = 'X'.
  <ls_operation>-standard_value_01_unit_x = 'X'.
* 기계
  <ls_operation>-standard_value_02 = ls_set_batch-vgw02.
  <ls_operation>-standard_value_02_unit = ls_set_batch-vge02.
  <ls_operation>-standard_value_02_x = 'X'.
  <ls_operation>-standard_value_02_unit_x = 'X'.
* 제조지원
  <ls_operation>-standard_value_03 = ls_set_batch-vgw03.
  <ls_operation>-standard_value_03_unit = ls_set_batch-vge03.
  <ls_operation>-standard_value_03_x = 'X'.
  <ls_operation>-standard_value_03_unit_x = 'X'.
* 제조직접
  <ls_operation>-standard_value_04 = ls_set_batch-vgw04.
  <ls_operation>-standard_value_04_unit = ls_set_batch-vge04.
  <ls_operation>-standard_value_04_x = 'X'.
  <ls_operation>-standard_value_04_unit_x = 'X'.
* 배부간접
  <ls_operation>-standard_value_05 = ls_set_batch-vgw05.
  <ls_operation>-standard_value_05_unit = ls_set_batch-vge05.
  <ls_operation>-standard_value_05_x = 'X'.
  <ls_operation>-standard_value_05_unit_x = 'X'.
* 노무
  <ls_operation>-standard_value_06 = ls_set_batch-vgw06.
  <ls_operation>-standard_value_06_unit = ls_set_batch-vge06.
  <ls_operation>-standard_value_06_x = 'X'.
  <ls_operation>-standard_value_06_unit_x = 'X'.


  CALL FUNCTION 'CO_SE_PRODORD_CHANGE'
    EXPORTING
      iv_order_number = lv_order_number
      it_operation    = lt_operation
      iv_commit       = 'X'
    IMPORTING
      es_return       = ls_result.

  IF ls_result-type NE ' '.
    pv_chk_err = abap_true.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_CHG_PIROTY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DETAIL
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM bdc_chg_piroty  USING    ps_detail STRUCTURE gs_detail
                            CHANGING pv_chk_err.

  REFRESH : gt_bdcdata, gt_messtab.

  __setting_bdc_params.

  __bdc_dynpro 'SAPLCOKO1' '0110'.
  __bdc_field : 'CAUFVD-AUFNR' ps_detail-ordno,
                      'R62CLORD-FLG_OVIEW'  'X',
                      'BDC_OKCODE' '=ENTK'.

  __bdc_dynpro 'SAPLCOKO1' '0115'.
  __bdc_field : 'BDC_OKCODE' '=+COI'. "

  __bdc_dynpro 'SAPLCOKO1' '0115'.
  __bdc_field : 'BDC_OKCODE' '=BU',
                      'GV_ZZPRIORITY' ps_detail-zzpriority.

  __bdc_transaction 'CO02'.
  LOOP AT gt_messtab INTO DATA(ls_messtab) WHERE msgtyp = 'A'
                                                         OR msgtyp = 'E'
                                                         OR msgtyp = 'X'.
    pv_chk_err = 'E'.
    RETURN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_SCREEN_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_screen_300 .

  PERFORM disp_detail.
  PERFORM set_order_schedule.

  PERFORM set_cell_attribute_grid_0300 .
  PERFORM refresh_grid_300 USING go_grid_0300.
  PERFORM refresh_grid_merge USING go_grid_merge_201.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INPUT_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM input_check .

  IF p_plan = abap_true.
    IF p_gongcd IS INITIAL.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '필수 필드 "공정"에 입력하십시오.'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_button
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_button .

  CLEAR gv_dyntxt.
  gv_dyntxt-icon_id = icon_table_settings.
  gv_dyntxt-text = '작업장관리'.
  gv_dyntxt-quickinfo = '작업장관리'.
  sscrfields-functxt_01 = gv_dyntxt.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_MAINTAIN_VIEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_maintain_view .

  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      action                       = 'U'
*     CORR_NUMBER                  = '          '
*     GENERATE_MAINT_TOOL_IF_MISSING       = ' '
*     SHOW_SELECTION_POPUP         = ' '
      view_name                    = 'ZGTPPT2060'
*     NO_WARNING_FOR_CLIENTINDEP   = ' '
*     RFC_DESTINATION_FOR_UPGRADE  = ' '
*     CLIENT_FOR_UPGRADE           = ' '
*     VARIANT_FOR_SELECTION        = ' '
      complex_selconds_used        = 'X'
*     CHECK_DDIC_MAINFLAG          = ' '
*     SUPPRESS_WA_POPUP            = ' '
*   TABLES
*     DBA_SELLIST                  =
*     EXCL_CUA_FUNCT               =
    EXCEPTIONS
      client_reference             = 1
      foreign_lock                 = 2
      invalid_action               = 3
      no_clientindependent_auth    = 4
      no_database_function         = 5
      no_editor_function           = 6
      no_show_auth                 = 7
      no_tvdir_entry               = 8
      no_upd_auth                  = 9
      only_show_allowed            = 10
      system_failure               = 11
      unknown_field_in_dba_sellist = 12
      view_not_found               = 13
      maintenance_prohibited       = 14
      OTHERS                       = 15.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_DETAIL>_ORDNO
*&      <-- <LS_DETAIL>_ORDSTAT
*&---------------------------------------------------------------------*
FORM set_status  USING    pv_ordno TYPE aufnr
                 CHANGING pv_ordno_stat.

  DATA : lt_tj02t LIKE tj02t OCCURS 0 WITH HEADER LINE.
  DATA : lv_stcd TYPE zordstcd.
  DATA : lv_objnr TYPE jest-objnr.
  DATA : lv_user_line TYPE bsvx-sttxt.

*    상태값 조회
  CALL FUNCTION 'Z_PP_RETURN_ORDER_STATUS'
    EXPORTING
      im_aufnr        = pv_ordno
    IMPORTING
      ex_ostcd        = lv_stcd
    TABLES
      et_sttxt        = lt_tj02t
    EXCEPTIONS
      no_selection    = 1
      not_found_objnr = 2
      OTHERS          = 3.

  CASE lv_stcd.
    WHEN 'A'.
      pv_ordno_stat = '생성'.
    WHEN 'B'.
      pv_ordno_stat = '릴리즈'.
    WHEN 'C'.
      pv_ordno_stat = '작업중'.
    WHEN 'D' OR 'G' OR 'F'.
      pv_ordno_stat = '작업완료'.
  ENDCASE.

  CASE lv_stcd.
    WHEN 'A' OR 'B'. "작업 준비단계에 PAYO 확인
*      유저스테이터스 조회
      CLEAR : lv_objnr, lv_user_line.
      lv_objnr = 'OR' && pv_ordno.
      CALL FUNCTION 'STATUS_TEXT_EDIT'
        EXPORTING
          flg_user_stat    = 'X'
          objnr            = lv_objnr
          only_active      = 'X'
          spras            = sy-langu
        IMPORTING
          user_line        = lv_user_line
        EXCEPTIONS
          object_not_found = 1
          OTHERS           = 2.

      FIND ALL OCCURRENCES OF 'PAYO' IN lv_user_line MATCH COUNT FINAL(lv_line).
      IF lv_line > 0.
        pv_ordno_stat = '작업중'.
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_PRD_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_prd_order .

  DATA : lt_orders TYPE TABLE OF bapi_order_key.
  DATA : lt_detail_return TYPE bapi_order_return_tt.
  DATA : ls_return TYPE bapiret2.
  DATA : lv_seq_c(12).

  IF NOT line_exists( gt_grpnr[ check = 'X' ] ).
    MESSAGE s003 DISPLAY LIKE 'E' WITH '선택된 오더가 없습니다.'.
    RETURN.
  ENDIF.

  LOOP AT gt_grpnr INTO gs_grpnr WHERE check = abap_true.
    IF gs_grpnr-gcatg = '생산오더'.
      APPEND INITIAL LINE TO lt_orders ASSIGNING FIELD-SYMBOL(<ls_orders>).
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = gs_grpnr-ordno
        IMPORTING
          output = <ls_orders>-order_number.
    ENDIF.
  ENDLOOP.

  IF lt_orders[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '삭제할 수 있는 오더가 없습니다.'.
    RETURN.
  ENDIF.


  CLEAR gv_answer.
  PERFORM popup_to_confirm_step USING 'N'
    ' '
    '선택된 오더가 삭제 됩니다. 계속 진행 하시겠습니까?'
    '삭제확인'.
  IF gv_answer NE 'J'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
    IMPORTING
      return        = ls_return
    TABLES
      orders        = lt_orders
      detail_return = lt_detail_return.

  IF ls_return-type = 'E'.
    REFRESH gt_del_disp.
    LOOP AT lt_detail_return INTO DATA(ls_detail_return).
      APPEND INITIAL LINE TO gt_del_disp ASSIGNING FIELD-SYMBOL(<ls_del_disp>).
      CASE ls_detail_return-type.
        WHEN 'S'.
          <ls_del_disp>-status = icon_led_green.
        WHEN 'W'.
          <ls_del_disp>-status = icon_led_yellow.
        WHEN 'E'.
          <ls_del_disp>-status = icon_led_red.
      ENDCASE.

      <ls_del_disp>-ordnr = ls_detail_return-order_number.
      <ls_del_disp>-ordty = 'PRD'.
      <ls_del_disp>-message = ls_detail_return-message.
    ENDLOOP.
    CALL SCREEN '0440' STARTING AT 10 5 ENDING AT 90 9.
  ENDIF.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = abap_true.

  WAIT UP TO '0.5' SECONDS.

  PERFORM refresh_screen_200.
  lv_seq_c = lines( lt_orders ).
  CONDENSE lv_seq_c.
  MESSAGE s006  WITH TEXT-e10 lv_seq_c TEXT-e20.


ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0440 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0440 OUTPUT.
  SET PF-STATUS '0440'.
  SET TITLEBAR '0440'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0440 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_alv_0440 OUTPUT.
  IF go_grid_0440 IS NOT BOUND.
    PERFORM set_object_grid_0440.
    PERFORM event_handler_register USING go_grid_0440.
    PERFORM set_layout_grid_0440.
    PERFORM set_fieldcat_grid_0440.
    PERFORM exclude_of_toolbar_grid_0440.
    PERFORM call_grid_0440_display.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0440
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_object_grid_0440 .

  CREATE OBJECT go_contain_0440
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

  CREATE OBJECT go_grid_0440
    EXPORTING
      i_parent      = go_contain_0440
      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0440
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_grid_0440 .

  CLEAR gs_layout_0440.
  gs_layout_0440-cwidth_opt = abap_true.
  gs_layout_0440-no_rowins = abap_true.
  gs_layout_0440-no_rowmark   = 'X'.
  gs_layout_0440-sel_mode   = 'C'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0440
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0440 .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR2020TOP'
      i_internal_tabname     = 'GS_DEL_DISP'
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
      et_fieldcat_lvc = gt_fieldcat_0440[]
    TABLES
      it_data         = gt_del_disp
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT gt_fieldcat_0440 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CASE   <ls_fcat>-fieldname.
      WHEN 'STATUS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '상태'.
        <ls_fcat>-icon = abap_true.
        <ls_fcat>-just = 'C'.
      WHEN 'ORDNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '오더'.
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'C'.
      WHEN 'ORDTY'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '오더 타입'.
        <ls_fcat>-just = 'C'.
      WHEN 'MESSAGE'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '결과 메세지'.
        <ls_fcat>-just = 'L'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0440
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_of_toolbar_grid_0440 .

  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0440
        USING : cl_gui_alv_grid=>mc_fc_excl_all.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0440_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_grid_0440_display .

  CALL METHOD go_grid_0440->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0440
      it_toolbar_excluding = gt_exclude_0440
    CHANGING
      it_outtab            = gt_del_disp
      it_fieldcatalog      = gt_fieldcat_0440.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RELEASE_PRD_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM release_prd_order .

  DATA : lt_orders TYPE TABLE OF bapi_order_key.
  DATA : lt_detail_return TYPE bapi_order_return_tt.
  DATA : ls_return TYPE bapiret2.
  DATA : lv_seq_c(12).
  DATA : BEGIN OF ls_chk_pack,
           aufnr TYPE afpo-aufnr,
           posnr TYPE zgtppt2010-posnr,
         END OF ls_chk_pack.
  DATA : lt_chk_pack LIKE TABLE OF ls_chk_pack.
  DATA : lo_routing TYPE REF TO zgtpp_cl_routing.

  IF NOT line_exists( gt_detail[ check = 'X' ] ).
    MESSAGE s003 DISPLAY LIKE 'E' WITH '선택된 오더가 없습니다.'.
    RETURN.
  ENDIF.

  LOOP AT gt_detail INTO gs_detail WHERE check = abap_true.
    IF gs_detail-status IS NOT INITIAL.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '수정중인 오더가 있습니다. 반영후 릴리즈 가능합니다.'.
      RETURN.
    ENDIF.

    IF gs_detail-ordstat = '생성'.
      CLEAR ls_chk_pack.
      APPEND INITIAL LINE TO lt_orders ASSIGNING FIELD-SYMBOL(<ls_orders>).
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = gs_detail-ordno
        IMPORTING
          output = <ls_orders>-order_number.

      ls_chk_pack-aufnr = <ls_orders>-order_number.
      ls_chk_pack-posnr = gs_detail-posnr + 0.
      COLLECT ls_chk_pack INTO lt_chk_pack.
    ENDIF.
  ENDLOOP.

  IF lt_orders[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '릴리즈 할 수 있는 오더가 없습니다.'.
    RETURN.
  ENDIF.

  CLEAR gv_answer.
  PERFORM popup_to_confirm_step USING 'N'
    ' '
    '릴리즈 진행합니다. 계속 진행 하시겠습니까?'
    '작업확인'.
  IF gv_answer NE 'J'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  CALL FUNCTION 'BAPI_PRODORD_RELEASE'
    TABLES
      orders        = lt_orders
      detail_return = lt_detail_return.

  IF ls_return-type = 'E'.
    REFRESH gt_del_disp.
    LOOP AT lt_detail_return INTO DATA(ls_detail_return).
      APPEND INITIAL LINE TO gt_del_disp ASSIGNING FIELD-SYMBOL(<ls_del_disp>).
      CASE ls_detail_return-type.
        WHEN 'S'.
          <ls_del_disp>-status = icon_led_green.
        WHEN 'W'.
          <ls_del_disp>-status = icon_led_yellow.
        WHEN 'E'.
          <ls_del_disp>-status = icon_led_red.
      ENDCASE.

      <ls_del_disp>-ordnr = ls_detail_return-order_number.
      <ls_del_disp>-ordty = 'PRD'.
      <ls_del_disp>-message = ls_detail_return-message.
    ENDLOOP.
    CALL SCREEN '0440' STARTING AT 10 5 ENDING AT 90 9.
  ENDIF.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = abap_true.

  WAIT UP TO '0.5' SECONDS.

* 포장재 재지정 프로세스
  IF lt_chk_pack[] IS NOT INITIAL.
    SELECT * FROM zgtppt2010
      INTO TABLE @DATA(lt_2010)
      FOR ALL ENTRIES IN @lt_chk_pack
     WHERE ordnr = @lt_chk_pack-aufnr
        AND posnr = @lt_chk_pack-posnr
        AND dmordty = 'SO'.
    IF sy-subrc EQ 0 AND lt_2010 IS NOT INITIAL.
      CREATE OBJECT lo_routing
        EXPORTING
          iv_werks = p_werks.                 " 플랜트

      .LOOP AT lt_2010 INTO DATA(ls_2010).
        lo_routing->check_pack_set_menge( is_2010 = ls_2010 ).
      ENDLOOP.
    ENDIF.
  ENDIF.


  PERFORM disp_detail.

  PERFORM set_cell_attribute_grid_0300 .
  PERFORM refresh_grid_300 USING go_grid_0300.

  lv_seq_c = lines( lt_orders ).
  CONDENSE lv_seq_c.
  MESSAGE s006  WITH TEXT-e10 lv_seq_c TEXT-e21.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ALLSELECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0200
*&---------------------------------------------------------------------*
FORM process_allselect  USING    po_grid TYPE REF TO cl_gui_alv_grid.

  CASE po_grid.
    WHEN go_grid_0200.
      LOOP AT gt_grpnr ASSIGNING FIELD-SYMBOL(<ls_grpnr>).
        <ls_grpnr>-check = abap_true.
      ENDLOOP.
      CLEAR gv_chk_use_backup.
    WHEN go_grid_0300.
      LOOP AT gt_detail ASSIGNING FIELD-SYMBOL(<ls_detail>).
        <ls_detail>-check = abap_true.
      ENDLOOP.
  ENDCASE.

  PERFORM refresh_grid USING po_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DESELECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0200
*&---------------------------------------------------------------------*
FORM process_deselect  USING    po_grid TYPE REF TO cl_gui_alv_grid.

  CASE po_grid.
    WHEN go_grid_0200.
      LOOP AT gt_grpnr ASSIGNING FIELD-SYMBOL(<ls_grpnr>).
        CLEAR <ls_grpnr>-check.
      ENDLOOP.
      CLEAR gv_chk_use_backup.
    WHEN go_grid_0300.
      LOOP AT gt_detail ASSIGNING FIELD-SYMBOL(<ls_detail>).
        CLEAR <ls_detail>-check.
      ENDLOOP.
  ENDCASE.

  PERFORM refresh_grid USING po_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ALLSELECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0200
*&---------------------------------------------------------------------*
FORM process_allselect_300  USING    po_grid TYPE REF TO lcl_alv_grid.

  CASE po_grid.
    WHEN go_grid_0200.
      LOOP AT gt_grpnr ASSIGNING FIELD-SYMBOL(<ls_grpnr>).
        <ls_grpnr>-check = abap_true.
      ENDLOOP.
      CLEAR gv_chk_use_backup.
    WHEN go_grid_0300.
      LOOP AT gt_detail ASSIGNING FIELD-SYMBOL(<ls_detail>).
        <ls_detail>-check = abap_true.
      ENDLOOP.
  ENDCASE.

  PERFORM refresh_grid_300 USING po_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DESELECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0200
*&---------------------------------------------------------------------*
FORM process_deselect_300  USING    po_grid TYPE REF TO lcl_alv_grid.

  CASE po_grid.
    WHEN go_grid_0200.
      LOOP AT gt_grpnr ASSIGNING FIELD-SYMBOL(<ls_grpnr>).
        CLEAR <ls_grpnr>-check.
      ENDLOOP.
      CLEAR gv_chk_use_backup.
    WHEN go_grid_0300.
      LOOP AT gt_detail ASSIGNING FIELD-SYMBOL(<ls_detail>).
        CLEAR <ls_detail>-check.
      ENDLOOP.
  ENDCASE.

  PERFORM refresh_grid_300 USING po_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CAL_END_DATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_DETAIL
*&      <-- PV_SECONDS
*&---------------------------------------------------------------------*
FORM cal_end_date  USING    ps_detail STRUCTURE gs_detail
                          CHANGING     pv_seconds TYPE i.

  DATA : lv_seconds TYPE i.
  DATA : lv_cal_seconds TYPE i.

  SELECT SINGLE a~gamng, c~vgw02, c~vge02, c~bmsch
    FROM afko AS a
    INNER JOIN afvc AS b
                           ON b~aufpl = a~aufpl
    INNER JOIN afvv AS c
                           ON c~aufpl = b~aufpl
                          AND c~aplzl = b~aplzl
   WHERE a~aufnr = @ps_detail-ordno
      AND b~aplfl = '000000'
      AND b~rueck <> ' '
    INTO @DATA(ls_cal_time).

  CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
    EXPORTING
      input                = ls_cal_time-vgw02
      unit_in              = ls_cal_time-vge02
      unit_out             = 'S'
    IMPORTING
      output               = lv_seconds
    EXCEPTIONS
      conversion_not_found = 1
      division_by_zero     = 2
      input_invalid        = 3
      output_invalid       = 4
      overflow             = 5
      type_invalid         = 6
      units_missing        = 7
      unit_in_not_found    = 8
      unit_out_not_found   = 9
      OTHERS               = 10.

  IF ls_cal_time-bmsch NE 0.
    lv_cal_seconds = lv_seconds / ls_cal_time-bmsch * ls_cal_time-gamng.
  ENDIF.

  pv_seconds = pv_seconds + lv_cal_seconds.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_SECONDS
*&      <-- <LS_DETAIL>
*&---------------------------------------------------------------------*
FORM set_date  USING    pv_seconds TYPE i
                  CHANGING ps_detail STRUCTURE gs_detail.

  ps_detail-gstrp = gs_make_order-gstrp.
  ps_detail-gsuzp = gs_make_order-gsuzp.
  ps_detail-gsuzp_hhmm = ps_detail-gsuzp.

  CALL FUNCTION 'TSTR_CALC_TIME'
    EXPORTING
      iv_begin_datelocal_req   = ps_detail-gstrp
      iv_begin_timelocal_req   = ps_detail-gsuzp
      iv_duration_integer      = pv_seconds
      iv_direction             = '+'
    IMPORTING
      ev_end_datelocal         = ps_detail-gltrp
      ev_end_timelocal         = ps_detail-gluzp
    EXCEPTIONS
      fatal_error              = 1
      time_invalid             = 2
      time_missing             = 3
      tstream_not_loadable     = 4
      tstream_generation_error = 5
      parameter_error          = 6
      unspecified_error        = 7
      OTHERS                   = 8.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  DATA : lv_add_date TYPE n LENGTH 2.
  DATA : lv_minute TYPE n LENGTH 2.
  DATA : lv_hours TYPE n LENGTH 2.

  lv_minute = ps_detail-gluzp+2(1) && '0'.
  lv_hours = ps_detail-gluzp+0(2).

  IF ps_detail-gluzp+3(2) > 0.
    lv_minute = lv_minute + 10.
  ENDIF.
  IF lv_minute >= 60.
    lv_minute = lv_minute - 60.
    lv_hours = lv_hours + 1.
  ENDIF.
  IF lv_hours >= 24 AND lv_minute > 0.
    lv_hours = lv_hours - 24.
    lv_add_date = 1.
  ENDIF.

  ps_detail-gluzp = lv_hours && lv_minute && '00'.
  ps_detail-gltrp = ps_detail-gltrp + lv_add_date.
  ps_detail-gluzp_hhmm = ps_detail-gluzp.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECKING_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM authority_checking_proc .

*& MRP관리자에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_SPGCD'
  ID 'WERKS'  FIELD p_werks
  ID 'SPGCD'  FIELD p_spgcd.

  IF sy-subrc <> 0.
    MESSAGE e006 WITH 'SPG[' p_spgcd
                      '] 작업권한을 확인하세요.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_MARKING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_marking .

  DATA : lt_cells TYPE lvc_t_ceno.

  go_grid_0200->get_selected_cells_id(
      IMPORTING
       et_cells = lt_cells ).                " Cell IDs

  LOOP AT lt_cells INTO DATA(ls_cells).
    READ TABLE gt_grpnr ASSIGNING FIELD-SYMBOL(<ls_grpnr>) INDEX ls_cells-row_id.
    <ls_grpnr>-check = abap_true.

  ENDLOOP.

  CLEAR gv_chk_use_backup.

  PERFORM refresh_grid USING go_grid_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_MARKING_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_marking_0300 .

  DATA : lt_cells TYPE lvc_t_ceno.

  go_grid_0300->get_selected_cells_id(
      IMPORTING
       et_cells = lt_cells ).                " Cell IDs

  LOOP AT lt_cells INTO DATA(ls_cells).
    READ TABLE gt_detail ASSIGNING FIELD-SYMBOL(<ls_detail>) INDEX ls_cells-row_id.
    <ls_detail>-check = abap_true.

  ENDLOOP.

  PERFORM refresh_grid_300 USING go_grid_0300.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DRY_SCHEDUL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_NUMBER
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM set_dry_schedul  USING    pv_number TYPE aufnr
                                                 pv_posnr
                                CHANGING    pv_chk_err.

  DATA : lt_2010 TYPE TABLE OF zgtppt2010.
  DATA : lt_2010_dev TYPE TABLE OF zgtppt2010.
  DATA : lv_posnr(6) TYPE n.
  DATA : lv_number TYPE bapi_order_key-order_number.
  DATA : ls_orderdata TYPE bapi_pp_order_change.
  DATA : ls_orderdatax TYPE bapi_pp_order_changex.
  DATA : ls_return TYPE bapiret2.

  lv_posnr = pv_posnr + 0.

  SELECT * FROM zgtppt2010 AS a
    WHERE concat( a~grpnr, a~ordnr ) IN ( SELECT concat( b~grpnr, b~ordnr )
                                                                  FROM zgtppt2010 AS b
                                                               WHERE b~ordnr = @pv_number
                                                                    AND b~posnr = @lv_posnr
                                                                    AND gong_cd = 'INS' )
      INTO CORRESPONDING FIELDS OF TABLE @lt_2010.

  SORT lt_2010 BY ordnr posnr.
  DELETE ADJACENT DUPLICATES FROM lt_2010 COMPARING ordnr posnr.

  IF lt_2010[] IS NOT INITIAL.
    SELECT b~*
      FROM @lt_2010 AS a
      INNER JOIN zgtppt2010 AS b
                                       ON b~grpnr = a~grpnr
                                      AND b~gong_cd IN ('DRY', 'ODY')
                                      AND b~ordnr = a~dmord
                                      AND b~posnr = a~dmline
                                      AND b~ordty = a~dmordty
      INTO CORRESPONDING FIELDS OF TABLE @lt_2010_dev.
*   이전 공정으로 현 오더가 등록되어 있는 공정 조회
    SELECT b~*
      FROM @lt_2010 AS a
      INNER JOIN zgtppt2010 AS b
                                       ON b~grpnr = a~grpnr
                                      AND b~gong_cd  IN ('DRY', 'ODY')
                                      AND b~reord = a~ordnr
                                      AND b~reline = a~posnr
                                      AND b~reordty = a~ordty
      APPENDING CORRESPONDING FIELDS OF TABLE @lt_2010_dev.
  ENDIF.

  SORT lt_2010_dev BY ordnr ordty.
  DELETE ADJACENT DUPLICATES FROM lt_2010_dev COMPARING ordnr ordty.

* 조장구성표네 상위 오더 찾았을시 날짜 업로드
  LOOP AT lt_2010_dev INTO DATA(ls_2010_dev).
    IF ls_2010_dev-ordty = 'PRD'.

      SELECT SINGLE pdpcdrydayno FROM zgtcvordsyval
        INTO @DATA(lv_date)
        WHERE werks = @p_werks
          AND aufnr = @ls_2010_dev-ordnr.

      CLEAR : lv_number, ls_orderdata, ls_orderdatax, ls_return.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_2010_dev-ordnr
        IMPORTING
          output = lv_number.

      ls_orderdata-basic_start_date = gs_detail-gltrp.
      ls_orderdata-basic_start_time = gs_detail-gluzp.
      ls_orderdata-basic_end_date = gs_detail-gltrp + lv_date.
      ls_orderdata-basic_end_time = gs_detail-gluzp.
      ls_orderdata-basic_scheduling_type = '7'.
      ls_orderdatax-basic_start_date = 'X'.
*    LS_ORDERDATAX-BASIC_START_TIME = 'X'.
      ls_orderdatax-basic_end_date = 'X'.
*    LS_ORDERDATAX-BASIC_END_TIME = 'X'.
      ls_orderdatax-basic_scheduling_type = 'X'.

      CALL FUNCTION 'BAPI_PRODORD_CHANGE'
        EXPORTING
          number     = lv_number
          orderdata  = ls_orderdata
          orderdatax = ls_orderdatax
        IMPORTING
          return     = ls_return.

      IF ls_return-type NE 'E'.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
      ELSE.
        MESSAGE s006 DISPLAY LIKE 'E' WITH TEXT-e10 lv_number TEXT-e15.
        RETURN.
      ENDIF.
    ENDIF.
  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh .

  PERFORM disp_detail.
  PERFORM set_order_schedule.

  PERFORM refresh_grid_merge USING go_grid_merge.

ENDFORM.
