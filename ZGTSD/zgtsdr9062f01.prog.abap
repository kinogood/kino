*&---------------------------------------------------------------------*
*& Include          ZGTSDR9062F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM initialization .


ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_screen .



ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_INPUT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_input_data .


ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM authority_check .

*  "권한 체크
*  ZGTSD_CL_COMMON=>AUTHORITY_CHECK( EXPORTING IV_OBJECT     = 'VKO'
*                                              IV_AUTH_FIELD = CONV XUFIELD( |VKORG| )
*                                              IV_AUTH_VAL   = CONV XUVAL( P_VKORG )
*                                    IMPORTING EV_MTYPE      = DATA(LV_MTYPE)
*                                              EV_MSGTX      = DATA(LV_MSGTX) ).
*  IF LV_MTYPE = GC_E.
*    MESSAGE S001(00) WITH LV_MSGTX DISPLAY LIKE GC_E.
*    LEAVE LIST-PROCESSING.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_QUERY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM data_query USING pv_ref.

  TYPES  : BEGIN OF ls_dlv_stock,
             stock_qty TYPE kwmeng.
  TYPES : END OF ls_dlv_stock.

  DATA : lt_dlv_stock TYPE STANDARD TABLE OF ls_dlv_stock,
         lt_687_stock TYPE STANDARD TABLE OF ls_dlv_stock.

  DATA : ls_conv_posnr TYPE vepos.
  DATA : ls_conv_sonum TYPE lvs_sonum,
         ls_cuobj      TYPE lvs_sonum. "체크용


  SELECT * FROM zgtsdt9063 INTO CORRESPONDING FIELDS OF TABLE gt_9063.

  SELECT DISTINCT a~mreqno, b~vbeln, b~posnr, b~matnr,
         b~kwmeng, b~vrkme, c~maktx,b~werks, b~abgru
  FROM @gt_9063 AS a INNER JOIN vbap AS b
    ON a~vbeln = b~vbeln
    AND a~posnr = b~posnr
    AND b~werks = '1306'
   INNER JOIN makt AS c
    ON b~matnr = c~matnr
    AND c~spras = 3
   WHERE b~vbeln IN @s_vbeln
      INTO CORRESPONDING FIELDS OF TABLE @gt_alv.

  SELECT fld_01
    INTO TABLE @DATA(lt_jikchul_vbeln)
    FROM zgtppt1010
    WHERE module_kind = 'SD'
    AND codegrp = 'Z993'.

  SELECT fld_01, fld_02
    INTO TABLE @DATA(lt_delay)
    FROM zgtppt1010
    WHERE module_kind = 'SD'
    AND codegrp = 'Z992'.


  LOOP AT gt_alv INTO wa_alv.

    SELECT matnr, werks, vbeln, posnr, lgort, SUM( kalab ) AS sum_kalab
      INTO TABLE @DATA(lt_mska_stock)
      FROM mska
      WHERE vbeln = @wa_alv-vbeln
      AND posnr = @wa_alv-posnr
      AND matnr = @wa_alv-matnr
      GROUP BY matnr, werks, vbeln, posnr, lgort.

    SELECT matnr, werks, SUM( labst ) AS sum_labst
      INTO TABLE @DATA(lt_mard_stock)
      FROM mard
      WHERE werks = '1306' "부스덕트용으로 고정으로 감
        AND matnr = @wa_alv-matnr
      GROUP BY matnr, werks.

    SELECT vbeln AS vbeln_vl, SUM( lfimg ) AS lfimg_sum
      FROM lips
      INTO TABLE @DATA(lt_lips_data)
      WHERE vgbel = @wa_alv-vbeln
      AND vgpos = @wa_alv-posnr
      GROUP BY vbeln.

    IF wa_alv-matnr CP '000000000007*'. "원재료

      SELECT SUM( stock_qty ) AS stock_qty "재고 출고입고 합계
        FROM lips AS a INNER JOIN vbap AS b
        ON a~vgbel = b~vbeln
        AND a~vgpos = b~posnr
        INNER JOIN matdoc AS c
        ON a~vbeln = c~kdauf
        AND a~posnr = c~kdpos
        INTO CORRESPONDING FIELDS OF TABLE @lt_dlv_stock
        WHERE b~vbeln = @wa_alv-vbeln
        AND b~posnr = @wa_alv-posnr
        AND c~bwart IN ('601', '602').

      READ TABLE lt_dlv_stock TRANSPORTING NO FIELDS WITH KEY stock_qty = 0. "연결고리가 다름. 납품문서와 MATDOC의 다른 필드 연결
      IF sy-subrc = 0.

        SELECT SUM( stock_qty ) AS stock_qty "재고 출고입고 합계
          FROM lips AS a INNER JOIN vbap AS b
          ON a~vgbel = b~vbeln
          AND a~vgpos = b~posnr
          INNER JOIN matdoc AS c
          ON a~vbeln = c~vbeln_im
          AND a~posnr = c~vbelp_im
          INTO CORRESPONDING FIELDS OF TABLE @lt_dlv_stock
          WHERE b~vbeln = @wa_alv-vbeln
          AND b~posnr = @wa_alv-posnr
          AND c~bwart IN ('601', '602').

      ENDIF.


      SELECT SUM( stock_qty ) AS stock_qty "재고 출고입고 합계
        FROM lips AS a INNER JOIN vbap AS b
        ON a~vgbel = b~vbeln
        AND a~vgpos = b~posnr
        INNER JOIN matdoc AS c
        ON a~vbeln = c~kdauf
        AND a~posnr = c~kdpos
        INTO CORRESPONDING FIELDS OF TABLE @lt_687_stock
        WHERE b~vbeln = @wa_alv-vbeln
        AND b~posnr = @wa_alv-posnr
        AND c~bwart IN ('687', '688').

    ELSE.

      SELECT SUM( stock_qty ) AS stock_qty "재고 출고입고 합계
        FROM matdoc
        INTO CORRESPONDING FIELDS OF TABLE @lt_dlv_stock
        WHERE mat_kdauf = @wa_alv-vbeln
        AND mat_kdpos = @wa_alv-posnr
        AND bwart IN ('601', '602').

      SELECT SUM( stock_qty ) AS stock_qty "1차출하(운송중재고)
        FROM matdoc
        INTO CORRESPONDING FIELDS OF TABLE @lt_687_stock
        WHERE mat_kdauf = @wa_alv-vbeln
        AND mat_kdpos = @wa_alv-posnr
        AND bwart IN ('687', '688').

    ENDIF.




    LOOP AT lt_mska_stock INTO DATA(ls_mska_stock). "판매오더 재고

      CASE ls_mska_stock-lgort.
        WHEN '2530'.
          MOVE-CORRESPONDING ls_mska_stock TO wa_alv.
          wa_alv-menge_2530 = ls_mska_stock-sum_kalab.
        WHEN '2540'.
          MOVE-CORRESPONDING ls_mska_stock TO wa_alv.
          wa_alv-menge_2540 = ls_mska_stock-sum_kalab.
        WHEN '2550'.
          MOVE-CORRESPONDING ls_mska_stock TO wa_alv.
          wa_alv-menge_2550 = ls_mska_stock-sum_kalab.
        WHEN '3601'.
          MOVE-CORRESPONDING ls_mska_stock TO wa_alv.
          wa_alv-menge_3601 = ls_mska_stock-sum_kalab.
      ENDCASE.

      MODIFY gt_alv FROM wa_alv.
    ENDLOOP.

    LOOP AT lt_mard_stock INTO DATA(ls_mard_stock).
      wa_alv-labst = ls_mard_stock-sum_labst.
      MODIFY gt_alv FROM wa_alv.
    ENDLOOP.

    LOOP AT lt_687_stock INTO DATA(ls_687_stock). "출고재고 관리
      wa_alv-687_dlv_qty = ls_687_stock-stock_qty * -1. "양수로 변환
*    WA_ALV-REM_DLV_QTY = WA_ALV-KWMENG -  LS_687_STOCK-STOCK_QTY. "출하잔량
      MODIFY gt_alv FROM wa_alv.
    ENDLOOP.

    LOOP AT lt_dlv_stock INTO DATA(ls_dlv_stock). "출고재고 관리
      wa_alv-stock_qty = ls_dlv_stock-stock_qty * -1. "양수로 변환
*    IF WA_ALV-687_DLV_QTY IS INITIAL. "687 미 존재 시에만 601 출고량 .
*    WA_ALV-REM_DLV_QTY = WA_ALV-KWMENG -  LS_DLV_STOCK-STOCK_QTY.
*    ENDIF.

      MODIFY gt_alv FROM wa_alv.
    ENDLOOP.

    LOOP AT lt_lips_data INTO DATA(ls_lips_data).
      wa_alv-vbeln_vl = ls_lips_data-vbeln_vl.
      wa_alv-lfimg_sum = ls_lips_data-lfimg_sum.
      MODIFY gt_alv FROM wa_alv.
    ENDLOOP.

  ENDLOOP.

  LOOP AT gt_alv INTO wa_alv.

    READ TABLE lt_delay INTO data(wa_dlv)  WITH KEY fld_01 = wa_alv-vbeln.
    IF sy-subrc = 0.
      wa_alv-delay_dlv = 'O'.
      wa_alv-delay_reason = wa_dlv-fld_02.
    ELSE.

    ENDIF.

    READ TABLE lt_jikchul_vbeln TRANSPORTING NO FIELDS WITH KEY fld_01 = wa_alv-vbeln.

    IF sy-subrc = 0.
      wa_alv-jikchul_check = 'O'.
    ELSE.
      wa_alv-jikchul_check = 'X'.
    ENDIF.



    IF wa_alv-abgru IS NOT INITIAL.
*      wa_alv-abgru_check = icon_checked.
      wa_alv-abgru_check = 'O'.
    ELSE.
      "공란
    ENDIF.

    IF wa_alv-lfimg_sum > ( wa_alv-menge_2550 + wa_alv-menge_3601 + wa_alv-labst ).
*      wa_alv-bujok_menge = icon_led_red.
      wa_alv-bujok_menge = 'X'.
    ELSE.
*      wa_alv-bujok_menge = icon_led_green.
      wa_alv-bujok_menge = 'O'.
    ENDIF.

    wa_alv-labst2 =  wa_alv-menge_2550 + wa_alv-menge_3601 + wa_alv-labst.

    IF wa_alv-687_dlv_qty > 0 OR wa_alv-stock_qty > 0.
*      wa_alv-dlv_check = icon_led_green.
      wa_alv-dlv_check = 'O'.
      CLEAR : wa_alv-abgru_check. "출하 완료 시 거부사유 Clear.
    ELSE.
*      wa_alv-dlv_check = icon_led_red.
      wa_alv-dlv_check = 'X'.
    ENDIF.


** 직출기반 포장여부 확인

    IF wa_alv-dlv_check = 'O'. "출하완료 제외
      wa_alv-pojang_check = '출하완료'.
    ELSE.
      IF wa_alv-matnr NP '000000000007*'."원재료 제외
        IF wa_alv-jikchul_check = 'O'.
          wa_alv-pojang_check = 'N/A'. "직출일 경우 제외.
        ELSE.
          IF wa_alv-menge_3601 = 0.
            wa_alv-pojang_check = 'X'.
          ELSEIF wa_alv-menge_3601 <> wa_alv-lfimg_sum.
            wa_alv-pojang_check = '포장수량과 납품수량 미일치'.
          ELSE.
            wa_alv-pojang_check = 'O'.
          ENDIF.
        ENDIF.
      ELSE.
        wa_alv-pojang_check = 'N/A'.
      ENDIF.
    ENDIF.


    MODIFY gt_alv FROM wa_alv.
  ENDLOOP.

  LOOP AT gt_alv INTO wa_alv.
    READ TABLE gt_alv  TRANSPORTING NO FIELDS WITH KEY dlv_check = 'X'
                                                                                        mreqno = wa_alv-mreqno.
    IF sy-subrc NE 0.
      wa_alv-jik_non_check = 'O'.
    ELSE.
      READ TABLE gt_alv TRANSPORTING NO FIELDS WITH KEY bujok_menge = 'X'
                                                                                      mreqno = wa_alv-mreqno.
      IF sy-subrc = 0.
*      wa_alv-jik_non_check = icon_led_red.
        wa_alv-jik_non_check = 'X'.
      ELSE.
*      wa_alv-jik_non_check = icon_led_green.
        wa_alv-jik_non_check = 'O'.
      ENDIF.
    ENDIF.



    READ TABLE gt_alv TRANSPORTING NO FIELDS WITH KEY pojang_check = 'X'
                                                                                        mreqno = wa_alv-mreqno. "포장실적이 있고..
    IF sy-subrc NE 0.
      READ TABLE gt_alv TRANSPORTING NO FIELDS WITH KEY jik_non_check = 'X'  "재고 Complete가 활성화 되어있을 경우..
                                                                                        mreqno = wa_alv-mreqno.
      IF sy-subrc NE 0.
        wa_alv-gi_avail = 'O'. "출하 가능
      ELSE.
        wa_alv-gi_avail = 'X'. "이외엔 불가
      ENDIF.
    ELSE.
      wa_alv-gi_avail = 'X'. "이외엔 불가
    ENDIF.

    MODIFY gt_alv FROM wa_alv.

  ENDLOOP.




  SORT gt_alv BY mreqno vbeln posnr.
  CHECK pv_ref IS INITIAL.
**********************************************************************
  "데이타 건수 메시지 출력
  IF gt_alv IS NOT INITIAL.
    MESSAGE s009 WITH |{ lines( gt_alv ) NUMBER = USER }|. "& 건 검색되었습니다.
  ELSE.
    MESSAGE s010.                                           "조회할 데이타가 없습니다.
    gv_error = gc_x.                                        "데이타 없으면 출력 X
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_ALV_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GO_CON
*&      <-- GO_GRID
*&---------------------------------------------------------------------*
FORM init_alv_0100  CHANGING po_dcon TYPE REF TO cl_gui_docking_container
                             po_grid TYPE REF TO cl_gui_alv_grid.

  "Create Main Container
  PERFORM create_doc_container CHANGING po_dcon.

  PERFORM create_alv USING    po_dcon
                     CHANGING po_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_DOC_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_doc_container CHANGING po_dcon TYPE REF TO cl_gui_docking_container.

  CREATE OBJECT po_dcon
    EXPORTING
      parent                      = cl_gui_container=>default_screen
      repid                       = sy-repid
      dynnr                       = sy-dynnr
      side                        = cl_gui_docking_container=>dock_at_top
      extension                   = 3000
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_alv CHANGING po_con
                         po_grid TYPE REF TO cl_gui_alv_grid.

  CREATE OBJECT po_grid
    EXPORTING
      i_parent          = po_con
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ATTRIBUTES_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_attributes_0100 .

  "Layout 지정
  PERFORM set_grid_layout USING 'X' space zgtsd_d.

  "Field Catalog
  PERFORM set_fieldcatalog.

  "Toolbar 제외
  PERFORM exclude_toolbar TABLES gt_toolbar.

  "Event Handler 등록
  PERFORM create_event_receiver USING go_grid.

  "F4 필드 등록
  PERFORM register_f4_fields.

  "SORT
  PERFORM set_alv_sort CHANGING gt_sort.

  "Top-Of-Page Event 등록
  PERFORM set_top_of_page_event.

  "ALV Grid Display
  PERFORM set_table_for_first_display USING go_grid
                                            gt_alv.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_grid_layout USING pv_cwopt
                           pv_stylefname
                           pv_sel_mode.

  CLEAR gs_layout.
  gs_layout = VALUE #( sel_mode   = pv_sel_mode
                       zebra      = zgtsd_x
                       cwidth_opt = pv_cwopt
                       stylefname = pv_stylefname ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_fieldcatalog .

  "Get Field Catalog
  PERFORM get_field_catalog USING gt_alv[] CHANGING gt_fcat.

  "Set Field Catalog
  PERFORM set_fieldcatalog_main.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_field_catalog USING pt_table TYPE table
                    CHANGING pt_fcat TYPE lvc_t_fcat.

  REFRESH pt_fcat.

  pt_fcat = zgtsd_cl_common=>get_field_catalog( it_table = pt_table
                                                iv_cells = zgtsd_x
                                                iv_cellc = zgtsd_x ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG_MAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcatalog_main .


  SORT gt_fcat BY fieldname.

  PERFORM reset_field_catalog TABLES gt_fcat USING :
      'S' 'FIELDNAME'   'MREQNO',
      ' ' 'COLTEXT'     '제번',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'VBELN',
      ' ' 'COLTEXT'     '판매오더',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'POSNR',
      ' ' 'COLTEXT'     '품목',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'VBELN_VL',
      ' ' 'COLTEXT'     '납품문서',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',


      'S' 'FIELDNAME'   'WERKS',
      ' ' 'COLTEXT'     '플랜트',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'MATNR',
      ' ' 'COLTEXT'     '자재코드',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'MAKTX',
      ' ' 'COLTEXT'     '자재코드	자재내역',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'LFIMG_SUM',
      ' ' 'COLTEXT'     '납품수량 합계',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'KWMENG',
      ' ' 'COLTEXT'     '수량',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'VRKME',
      ' ' 'COLTEXT'     '단위',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'MENGE_2530',
      ' ' 'COLTEXT'     '2530',
      ' ' 'QFIELDNAME'  'VRKME',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'MENGE_2540',
      ' ' 'COLTEXT'     '2540',
      ' ' 'QFIELDNAME'  'VRKME',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'MENGE_2550',
      ' ' 'COLTEXT'     '2550',
      ' ' 'QFIELDNAME'  'VRKME',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'MENGE_3601',
      ' ' 'COLTEXT'     '3601',
      ' ' 'QFIELDNAME'  'VRKME',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'LABST',
      ' ' 'COLTEXT'     '플랜트재고',
      ' ' 'QFIELDNAME'  'VRKME',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'LABST2',
      ' ' 'COLTEXT'     '출고가능재고',
      ' ' 'QFIELDNAME'  'VRKME',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   '687_DLV_QTY',
      ' ' 'COLTEXT'     '1차출하(687) 처리 수량',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'STOCK_QTY',
      ' ' 'COLTEXT'     '판매출하(601) 처리 수량',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'DELAY_DLV',
      ' ' 'COLTEXT'     '차월 출하 대상',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'BUJOK_MENGE',
      ' ' 'COLTEXT'     '재고여부',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'DLV_CHECK',
      ' ' 'COLTEXT'     '출하 여부',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'ABGRU_CHECK',
      ' ' 'COLTEXT'     '거부사유 존재여부',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'JIK_NON_CHECK',
      ' ' 'COLTEXT'     '재고 Complete',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'JIKCHUL_CHECK',
      ' ' 'COLTEXT'     '직출여부',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'POJANG_CHECK',
      ' ' 'COLTEXT'     '포장실적 처리상태',
      'E' 'OUTPUTLEN'   '20',

            'S' 'FIELDNAME'   'GI_AVAIL',
      ' ' 'COLTEXT'     '출하가능 여부',
      'E' 'OUTPUTLEN'   '20'.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM reset_field_catalog TABLES pt_fcat TYPE lvc_t_fcat
                         USING  pv_flag
                                pv_fname
                                pv_value.

  STATICS : ls_fcat   TYPE lvc_s_fcat,
            lv_colpos TYPE lvc_colpos,
            lv_tabix  TYPE sytabix.

  IF pv_flag = zgtsd_s.  "Start
    CLEAR ls_fcat.
    READ TABLE pt_fcat INTO ls_fcat WITH KEY fieldname = pv_value BINARY SEARCH.
    CHECK sy-subrc = 0.
    lv_tabix = sy-tabix.

    lv_colpos = lv_colpos + 1.

    ls_fcat-tech    = space.
    ls_fcat-col_pos = lv_colpos.
  ENDIF.

  CASE pv_fname.
    WHEN 'COLTEXT'.   "Text
      ls_fcat-coltext  = pv_value.
      ls_fcat-reptext  = pv_value.
      ls_fcat-seltext  = pv_value.
      ls_fcat-tooltip  = pv_value.
    WHEN OTHERS.
      ASSIGN COMPONENT pv_fname OF STRUCTURE ls_fcat TO FIELD-SYMBOL(<lv_value>).
      CHECK sy-subrc = 0.
      <lv_value> = pv_value.
  ENDCASE.

  IF pv_flag = zgtsd_e.  "End
    MODIFY pt_fcat FROM ls_fcat INDEX lv_tabix.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*----------------------------------------------------------------------*
FORM exclude_toolbar TABLES pt_exclude TYPE ui_functions.

  REFRESH pt_exclude.

  APPEND : cl_gui_alv_grid=>mc_fc_loc_undo            TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_data_save           TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_copy            TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_copy_row        TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_cut             TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_delete_row      TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_insert_row      TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_move_row        TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_append_row      TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_paste           TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_paste_new_row   TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_refresh             TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_check               TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_print               TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_views               TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_graph               TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_info                TO pt_exclude.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_EVENT_RECEIVER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM create_event_receiver USING po_sender TYPE REF TO cl_gui_alv_grid.

  "Create Event
  DATA(lo_event) = NEW lcl_event_receiver( ).

  CASE po_sender.
    WHEN go_grid.
*      SET HANDLER : LO_EVENT->HANDLE_TOP_OF_PAGE FOR PO_SENDER.
  ENDCASE.

  SET HANDLER : lo_event->handle_hotspot_click         FOR po_sender,
                lo_event->handle_dbl_click             FOR po_sender,
                lo_event->handle_toolbar               FOR po_sender,
                lo_event->handle_user_command          FOR po_sender,
                lo_event->handle_data_changed          FOR po_sender.
*                LO_EVENT->HANDLE_ON_F4                 FOR PO_SENDER.
*               LO_EVENT->HANDLE_DATA_CHANGED_FINISHED FOR PO_SENDER.

*  "Data Changed Event
*  PO_SENDER->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
*  PO_SENDER->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_ENTER ).
*
**  "Set Ready for Input
*  GO_GRID->SET_READY_FOR_INPUT( SWITCH #( GV_EDIT WHEN ZGTSD_X THEN 1 ELSE 0 ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REGISTER_F4_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM register_f4_fields .

  DATA : lt_f4   TYPE lvc_t_f4,
         lt_fcat TYPE TABLE OF lvc_s_fcat
                 WITH NON-UNIQUE SORTED KEY key_mode
                 COMPONENTS f4availabl fieldname.

  lt_fcat = gt_fcat.
  LOOP AT lt_fcat INTO DATA(ls_fcat) USING KEY key_mode
                  WHERE f4availabl = zgtsd_x.
    lt_f4 = VALUE #( BASE lt_f4 ( fieldname  = ls_fcat-fieldname
                                  register   = zgtsd_x
                                  chngeafter = zgtsd_x ) ).
  ENDLOOP.

  go_grid->register_f4_for_fields( EXPORTING it_f4 = lt_f4 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TOP_OF_PAGE_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_top_of_page_event .

  CHECK go_docu IS BOUND.

  go_docu->initialize_document( background_color = cl_dd_area=>col_textarea ).

  CALL METHOD go_grid->list_processing_events(
      i_event_name = slis_ev_top_of_page
      i_dyndoc_id  = go_docu ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_table_for_first_display USING po_sender TYPE REF TO cl_gui_alv_grid
                                       pt_data TYPE table.
  DATA : lv_handl TYPE slis_handl.

  "레이아웃 Variant 구분자
  PERFORM set_variant_handle USING po_sender CHANGING lv_handl.

  DELETE gt_fcat WHERE tech = zgtsd_x. "불필요한 필드 제외

  "Formatted Output Table is Sent to Control
  CALL METHOD po_sender->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout
      is_variant           = VALUE #( report = sy-repid
                                      handle = lv_handl )
      i_save               = zgtsd_a
      it_toolbar_excluding = gt_toolbar
    CHANGING
      it_fieldcatalog      = gt_fcat
      it_sort              = gt_sort[]
      it_outtab            = pt_data[].


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT_HANDLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_variant_handle USING po_sender TYPE REF TO cl_gui_alv_grid
                         CHANGING pv_handl.

  CLEAR pv_handl.
  CASE po_sender.
    WHEN go_grid. "Main
      pv_handl = '1'.
    WHEN OTHERS.
      pv_handl = '2'.

  ENDCASE.
  CONDENSE pv_handl.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_top_of_page USING po_docu TYPE REF TO cl_dd_document
                                  po_sender.
  DATA : lv_text TYPE sdydo_text_element.

  CHECK po_sender = go_grid "Main
    AND po_docu IS BOUND.

  "Set Column Width
  po_docu->add_table( EXPORTING no_of_columns = 3 border = '0' IMPORTING table = DATA(lo_table) ).

  lo_table->add_column( EXPORTING width = '35%' IMPORTING column = DATA(lo_col_key) ).
  lo_table->add_column( EXPORTING width = '3%' IMPORTING column = DATA(lo_col_sep) ).
  lo_table->add_column( EXPORTING width = '62%' IMPORTING column = DATA(lo_col_val) ).
  lo_table->new_row( ).

  "Set Column Style
  lo_table->set_column_style( col_no = 1 sap_emphasis = cl_dd_document=>strong sap_align = 'LEFT' ).
  lo_table->set_column_style( col_no = 3 sap_emphasis = cl_dd_document=>medium sap_align = 'LEFT' ).

  "Add Text
*  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE         "영업조직
*                                ZGTSD_P %_P_VKORG_%_APP_%-TEXT P_VKORG.


  "Display Document
  po_docu->merge_document( ).
  po_docu->display_document( EXPORTING
                               reuse_control      = zgtsd_x
                               parent             = go_con_top
                             EXCEPTIONS
                               html_display_error = 1 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_TEXT_COMMON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM add_text_common USING po_col_key TYPE REF TO cl_dd_area
                               po_col_sep TYPE REF TO cl_dd_area
                               po_col_val TYPE REF TO cl_dd_area
                               po_table   TYPE REF TO cl_dd_table_element
                               pv_flag
                               pv_key
                               pv_value.
  FIELD-SYMBOLS : <lt_selopt> TYPE table.
  DATA lv_text TYPE char255.

  CASE pv_flag.
    WHEN zgtsd_p. "Parameter
      CHECK pv_value IS NOT INITIAL.
      lv_text = CONV sdydo_text_element( pv_value ).
    WHEN zgtsd_s. "Select-Option
      ASSIGN (pv_value) TO <lt_selopt>.
      CHECK sy-subrc = 0.

      CHECK lines( <lt_selopt> ) => 1.

      ASSIGN COMPONENT 'LOW' OF STRUCTURE <lt_selopt>[ 1 ] TO FIELD-SYMBOL(<lv_low>).
      CHECK sy-subrc = 0.
      ASSIGN COMPONENT 'HIGH' OF STRUCTURE <lt_selopt>[ 1 ] TO FIELD-SYMBOL(<lv_high>).
      CHECK sy-subrc = 0.

      IF <lv_high> IS INITIAL.
        lv_text = <lv_low>.
      ELSEIF <lv_low> IS INITIAL.
        lv_text = `~ ` &&  <lv_low>.
      ELSE.
        lv_text = <lv_low> && ` ~ ` &&  <lv_high>.
      ENDIF.
  ENDCASE.

  po_col_key->add_text( text = CONV sdydo_text_element( pv_key ) ).
  po_col_sep->add_text( text = CONV sdydo_text_element( zgtsd_colon ) ).
  po_col_val->add_text( text = lv_text ).

  po_table->new_row( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_hotspot_click USING ps_column TYPE lvc_s_col
                                ps_row_no TYPE lvc_s_roid
                                po_sender.

  DATA : lt_msg TYPE rs_t_msg.

  CHECK po_sender = go_grid. "Main

  CASE ps_column-fieldname.

    WHEN 'ICON'.

      READ TABLE gt_alv INTO DATA(ls_main) INDEX ps_row_no-row_id.
      CHECK sy-subrc = 0.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_data_changed USING po_data_changed TYPE REF TO
                                 cl_alv_changed_data_protocol
                                 po_sender.

  CHECK po_sender = go_grid.  "Main

  DATA(lt_mod_cells) = po_data_changed->mt_good_cells.
  SORT lt_mod_cells BY row_id fieldname.

  REFRESH gt_chg.

*  LOOP AT LT_MOD_CELLS INTO DATA(LS_MOD_TEMP).
*
*    DATA(LS_MOD_CELLS) = LS_MOD_TEMP.
*
*    AT NEW ROW_ID.
*      READ TABLE GT_ALV INTO DATA(LS_MAIN) INDEX LS_MOD_CELLS-ROW_ID.
*      CHECK SY-SUBRC = 0.
*    ENDAT.
*
*    "체크사항 점검 및 Set Value
*    PERFORM CHECK_VALUE_IN_DATACHD USING    PO_DATA_CHANGED
*                                            LS_MOD_CELLS
*                                   CHANGING LS_MAIN.
*
*    AT END OF ROW_ID.
*      "변경상태 Update
*      PERFORM UPDATE_STATU USING    PO_DATA_CHANGED
*                                    LS_MOD_CELLS
*                           CHANGING LS_MAIN-STATU
*                                    LS_MAIN-MODI.
*      MODIFY GT_ALV FROM LS_MAIN INDEX LS_MOD_CELLS-ROW_ID.
*      APPEND CORRESPONDING #( LS_MAIN ) TO GT_CHG.
*    ENDAT.
*
*  ENDLOOP.

  "Display Protocol
  po_data_changed->display_protocol( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_VALUE_IN_DATACHD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*FORM CHECK_VALUE_IN_DATACHD USING PO_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
*                                  PS_MOD_CELLS TYPE LVC_S_MODI
*                         CHANGING PS_DATA STRUCTURE GS_ALV.

*  CASE PS_MOD_CELLS-FIELDNAME.
*
**    WHEN 'SPART'.
**      PERFORM CHECK_VALUE_SPART USING PO_DATA_CHANGED
**                                      PS_MOD_CELLS
**                             CHANGING PS_DATA.
*    WHEN 'O_DR_WEIGHT'.
*      PS_DATA-O_DR_WEIGHT = PS_MOD_CELLS-VALUE.
*      PS_DATA-GROSS_WEIGHT = PS_DATA-BRGEW + PS_DATA-O_DR_WEIGHT.
*
*      PERFORM MODIFY_CELL USING PO_DATA_CHANGED
*                              PS_MOD_CELLS-ROW_ID
*                              PS_MOD_CELLS-TABIX
*                              'GROSS_WEIGHT'
*                              PS_DATA-GROSS_WEIGHT.
*    WHEN OTHERS.
*      ASSIGN COMPONENT PS_MOD_CELLS-FIELDNAME OF STRUCTURE PS_DATA TO FIELD-SYMBOL(<LV_VALUE>).
*      CHECK SY-SUBRC = 0.
*      <LV_VALUE> = PS_MOD_CELLS-VALUE.
*  ENDCASE.

*ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CHANGED_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_changed_data USING po_grid TYPE REF TO cl_gui_alv_grid
                              pv_ck.

  CLEAR gv_error.
  CHECK po_grid IS BOUND.

  po_grid->check_changed_data( IMPORTING e_valid = DATA(lv_valid) ).

  IF pv_ck = zgtsd_x AND lv_valid IS INITIAL.
    gv_error = zgtsd_x. "오류 Flag
    MESSAGE s029 DISPLAY LIKE zgtsd_e. "오류 내역이 존재합니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_STATU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM update_statu USING po_data_changed TYPE REF TO
                            cl_alv_changed_data_protocol
                            ps_mod_cells TYPE lvc_s_modi
                   CHANGING pv_statu
                            pv_modi.

  pv_modi  = zgtsd_x.     "변경 Flag
  pv_statu = icon_change. "변경 Icon

  PERFORM modify_cell USING po_data_changed
                            ps_mod_cells-row_id
                            ps_mod_cells-tabix
                            'STATU'
                            pv_statu.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CELL_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_cell_value USING po_data_changed TYPE REF TO
                              cl_alv_changed_data_protocol
                              pv_row_id
                              pv_fieldname
                     CHANGING pv_value.

  CLEAR pv_value.
  po_data_changed->get_cell_value( EXPORTING
                                     i_row_id    = pv_row_id
                                     i_fieldname = pv_fieldname
                                   IMPORTING
                                     e_value     = pv_value ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_PROTOCOL_ENTRY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM add_protocol_entry USING po_data_changed TYPE REF TO
                                cl_alv_changed_data_protocol
                                pv_msgid
                                pv_msgno
                                pv_msgv1
                                pv_msgv2
                                pv_fieldname
                                pv_row_id.

  DATA : lt_data TYPE TABLE OF lvc_s_msg1
                 WITH NON-UNIQUE SORTED KEY key_mode
                 COMPONENTS msgid msgno msgv1 msgv2 fieldname row_id.

  lt_data = po_data_changed->mt_protocol.  "기존 동일 오류 제외

  CHECK NOT line_exists( lt_data[ KEY key_mode COMPONENTS msgid     = pv_msgid
                                                          msgno     = pv_msgno
                                                          msgv1     = pv_msgv1
                                                          msgv2     = pv_msgv2
                                                          fieldname = pv_fieldname
                                                          row_id    = pv_row_id ] ).

  po_data_changed->add_protocol_entry(
      EXPORTING
        i_msgid     = pv_msgid
        i_msgno     = pv_msgno
        i_msgty     = zgtsd_e
        i_msgv1     = pv_msgv1
        i_msgv2     = pv_msgv2
        i_fieldname = pv_fieldname
        i_row_id    = pv_row_id ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_CELL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM modify_cell USING po_data_changed TYPE REF TO
                         cl_alv_changed_data_protocol
                         pv_row_id
                         pv_tabix
                         pv_fieldname
                         pv_value.

  po_data_changed->modify_cell( i_row_id    = pv_row_id
                                i_tabix     = pv_tabix
                                i_fieldname = pv_fieldname
                                i_value     = pv_value ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_data_changed_finished USING pv_modified
                                            pt_good_cells TYPE lvc_t_modi
                                            po_sender.

  CHECK pv_modified = zgtsd_x
    AND po_sender   = go_grid
    AND gt_chg IS NOT INITIAL.

*  변경사항 반영
  PERFORM update_edit_fields USING gt_chg.

  "Refresh Grid
  PERFORM refresh_table_display USING po_sender space.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_EDIT_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM update_edit_fields USING pt_chg TYPE ty_t_chg.

  "Set 수정 필드
*  DELETE ADJACENT DUPLICATES FROM PT_CHG USING KEY KEY_MODE COMPARING VBELN POSNR.
*
*  LOOP AT PT_CHG INTO DATA(LS_CHG).
*
*    DATA(LS_DATA) = VALUE #( GT_ALV[ KEY K_KEY
*                               COMPONENTS VBELN = LS_CHG-VBELN
*                                          POSNR = LS_CHG-POSNR ] OPTIONAL ).
*    CHECK LS_DATA-SPART IS NOT INITIAL.
*
*    LOOP AT GT_ALV ASSIGNING FIELD-SYMBOL(<LS_MAIN>) USING KEY K_KEY
*                     WHERE VBELN = LS_DATA-VBELN
*                       AND POSNR = LS_DATA-POSNR.
*      <LS_MAIN>-O_PLAN_DIA    = LS_DATA-O_PLAN_DIA.
*      <LS_MAIN>-O_OUT_WID     = LS_DATA-O_OUT_WID.
*      <LS_MAIN>-O_IN_WID      = LS_DATA-O_IN_WID.
*      <LS_MAIN>-O_DR_WEIGHT   = LS_DATA-O_DR_WEIGHT.
*      <LS_MAIN>-TOT_QTY       = LS_DATA-TOT_QTY.
*      <LS_MAIN>-TOT_QTY_GROSS = LS_DATA-TOT_QTY_GROSS.
*      <LS_MAIN>-BOX_QTY       = LS_DATA-BOX_QTY.
*
*    ENDLOOP.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_toolbar USING po_object TYPE REF TO cl_alv_event_toolbar_set
                              po_sender.
  DEFINE _add_toolbar.
    ls_toolbar = VALUE #( function   = &1
                          icon       = &2
                          quickinfo  = &3
                          text       = &4
                          butn_type  = &5 ).

    CASE &6.
      WHEN zgtsd_a. "Append
        APPEND ls_toolbar TO po_object->mt_toolbar.
      WHEN zgtsd_i. "Insert
        INSERT ls_toolbar INTO po_object->mt_toolbar INDEX 1.
    ENDCASE.
  END-OF-DEFINITION.

  DATA : ls_toolbar TYPE stb_button.

*  CHECK GV_EDIT = ZGTSD_X.     "수정가능 상태
*
*  CASE PO_SENDER.
*    WHEN GO_GRID. "Main
*      _ADD_TOOLBAR SPACE                SPACE            SPACE    SPACE    3 'A'.
*      _ADD_TOOLBAR 'SAVR' ICON_SYSTEM_SAVE   '규격/중량저장' '규격/중량저장' 0 'A'.
*
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_TABLE_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM refresh_table_display USING po_grid TYPE REF TO cl_gui_alv_grid
                                  pv_soft_refresh.

  CHECK po_grid IS BOUND.

  CALL METHOD po_grid->refresh_table_display
    EXPORTING
      is_stable      = CONV #( 'XX' )
      i_soft_refresh = pv_soft_refresh
    EXCEPTIONS
      finished       = 1
      OTHERS         = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_ON_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_on_f4 USING pv_fieldname TYPE lvc_fname
                            pv_fieldvalue  TYPE lvc_value
                            ps_row_no      TYPE lvc_s_roid
                            po_event_data  TYPE REF TO cl_alv_event_data
                            pv_display     TYPE char01
                            po_sender.
  DATA : lv_value TYPE lvc_value.
  FIELD-SYMBOLS : <lt_data> TYPE table.

*  CHECK PO_SENDER = GO_GRID. "Main
*
*  PO_EVENT_DATA->M_EVENT_HANDLED = ZPS01_X.
*
*  CASE PV_FIELDNAME.
*    WHEN ZPS01_FNAME-Z_IV_ANLKL.  "자산 클래스
*
*      PERFORM F4_CODE_MASTER USING    ZPS01_ROLLNAME-ZE_IV_ANLKL
*                                      ZPS01_CODE-PSAC02
*                                      PV_DISPLAY
*                             CHANGING LV_VALUE.
*
*    WHEN OTHERS.
*      RETURN.
*  ENDCASE.
*
*  CHECK LV_VALUE IS NOT INITIAL.
*
*  ASSIGN PO_EVENT_DATA->M_DATA->* TO <LT_DATA>.
*  CHECK SY-SUBRC = 0.
*
*  APPEND VALUE LVC_S_MODI( FIELDNAME = PV_FIELDNAME
*                           ROW_ID    = PS_ROW_NO-ROW_ID
*                           VALUE     = LV_VALUE ) TO <LT_DATA>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FREE_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM free_object .
* Field Catalog
  CLEAR: gt_fcat[].

* Grid Clear
  CALL METHOD: go_grid->free.

  CLEAR: go_grid.

* Container Clear
  CALL METHOD: go_con->free,
               go_split->free,
               go_con_top->free.

  CLEAR: go_con, go_split, go_con_top.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DBL_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM handle_dbl_click  USING    pv_row     TYPE lvc_s_row
                                pv_column  TYPE lvc_s_col.

  CHECK pv_row-rowtype EQ space.
  READ TABLE gt_alv INTO gs_alv INDEX pv_row-index.
  CHECK sy-subrc = 0 .

  CASE pv_column.
    WHEN 'VBELN'.
      CHECK gs_alv-vbeln IS NOT INITIAL.
      SET PARAMETER ID: 'AUN' FIELD   gs_alv-vbeln.
      CALL TRANSACTION  'VA03' AND SKIP FIRST SCREEN.
*    WHEN 'AUFNR'.
*      CHECK GS_ALV-AUFNR IS NOT INITIAL.
*      SET PARAMETER ID: 'ANR' FIELD   GS_ALV-AUFNR.
*      CALL TRANSACTION  'CO03' AND SKIP FIRST SCREEN.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_SORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_SORT
*&---------------------------------------------------------------------*
FORM set_alv_sort  CHANGING pt_sort TYPE lvc_t_sort.

  CLEAR : pt_sort[].

  PERFORM set_sort_field USING: pt_sort 'MREQNO' gc_x '' '',
                                pt_sort 'VBELN' gc_x '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_SORT
*&      --> P_
*&      --> GC_X
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_sort_field  USING pt_sort TYPE lvc_t_sort
                           pv_fldname
                           pv_up
                           pv_down
                           pv_subtot.

  APPEND VALUE #( spos      = lines( pt_sort ) + 1
                  fieldname = pv_fldname
                  up        = pv_up
                  down      = pv_down
                  subtot    = pv_subtot ) TO pt_sort.
ENDFORM.
*&--------------------------------------------------------------------*
*& Form  GET_SELECTED_ROWS
*&--------------------------------------------------------------------*
FORM get_selected_rows USING po_grid TYPE REF TO cl_gui_alv_grid
                       CHANGING pt_rows TYPE lvc_t_row.

  REFRESH pt_rows.

  CALL METHOD po_grid->get_selected_rows
    IMPORTING
      et_index_rows = pt_rows.

  DELETE pt_rows WHERE rowtype NE space.

ENDFORM. " GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PRF_SENDER  text
*      -->P_C_X  text
*      -->P_GV_ERR  text
*----------------------------------------------------------------------*
FORM check_selected_rows USING po_grid TYPE REF TO cl_gui_alv_grid
                               pt_rows TYPE lvc_t_row
                               pv_single.

  PERFORM get_selected_rows USING po_grid pt_rows.

*>> pv_single -> 'X'  Single   Item Select
*                ' '  Multiple Item Select
  CASE pv_single.
    WHEN gc_x.
      IF lines( pt_rows ) EQ 0.
        MESSAGE s004 DISPLAY LIKE gc_e.
        EXIT.
      ENDIF.

      IF lines( pt_rows ) NE 1.
        MESSAGE s002 DISPLAY LIKE gc_e. "Select only one valid line.
        CLEAR pt_rows[].  EXIT.
      ENDIF.

    WHEN OTHERS.
      IF lines( pt_rows ) EQ 0.
        MESSAGE s004 DISPLAY LIKE gc_e.
        EXIT.
      ENDIF.

  ENDCASE.

ENDFORM. " CHECK_SELECTED_ROWS
