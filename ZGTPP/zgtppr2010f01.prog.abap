*&---------------------------------------------------------------------*
*& Include          ZGTPPR2010F01
*&---------------------------------------------------------------------*
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
    IF screen-group1 = 'M1'.
      screen-input = 0.
      screen-intensified = 1.
      MODIFY SCREEN.
    ENDIF.

    CASE screen-name.
      WHEN 'P_NAME' OR 'P_NAME2'.
        screen-input = 0.
        screen-intensified = 1.
        MODIFY SCREEN.
    ENDCASE.

    IF screen-group1 = 'M2'.
      screen-input = 0.
      screen-intensified = 1.
      MODIFY SCREEN.
    ENDIF.

    CASE sy-tcode.
      WHEN 'ZGTPPR2050'.
        IF screen-group1 = 'BB'.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.

      WHEN OTHERS.
        IF screen-group1 = 'AA'.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.

  ENDLOOP.

ENDFORM.
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

* 납품처
  IF NOT p_kunn2 IS INITIAL.
    CLEAR kna1.
    SELECT SINGLE name1 INTO p_name
             FROM kna1
            WHERE werks EQ p_kunn2.
  ELSE.
    CLEAR p_name.
  ENDIF.

  IF sy-tcode = 'ZGTPPR2050'.
    p_chec2 = abap_true.
  ENDIF.

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

  TYPES : BEGIN OF ts_chk_order,
            vbeln TYPE vbap-vbeln,
            posnr TYPE vbap-posnr,
            matnr TYPE matnr,
          END OF ts_chk_order.
  DATA : lt_chk_order TYPE TABLE OF ts_chk_order.
  DATA : lt_chk_confirm TYPE TABLE OF zgtcvordsyval.
  DATA : ls_chk_confirm TYPE zgtcvordsyval.
  DATA : lv_line_c(4).
  DATA : BEGIN OF ls_stock_collect,
           vbeln TYPE zgtcv_stockval-vbeln,
           posnr TYPE zgtcv_stockval-posnr,
           labst TYPE zgtcv_stockval-labst,
           insme TYPE zgtcv_stockval-insme,
           speme TYPE zgtcv_stockval-speme,
         END OF ls_stock_collect.
  DATA : lt_stock_collect LIKE TABLE OF ls_stock_collect.
  DATA : lt_grpnr TYPE RANGE OF zgtppt2000-grpnr.
  DATA : lv_inlength TYPE zgtppt2000-inlength.
  DATA : lv_infactor TYPE zgtppt2000-infactor.
  DATA : lv_vbeln TYPE vbap-vbeln,
         lv_posnr TYPE vbap-posnr.


  RANGES : lt_kunnr FOR kna1-kunnr.

  CLEAR gv_chk_subpool_dir_full.

  IF p_kunnr IS NOT INITIAL.
    APPEND INITIAL LINE TO lt_kunnr ASSIGNING FIELD-SYMBOL(<ls_kunnr>).
    IF p_kunnr CO '*'.
      <ls_kunnr> = VALUE #( sign = 'I' option = 'CP' low = p_kunnr ).
    ELSE.
      <ls_kunnr> = VALUE #( sign = 'I' option = 'EQ' low = p_kunnr ).
    ENDIF.
  ENDIF.

  IF p_kunn2 IS NOT INITIAL AND sy-tcode EQ 'ZGTPPR2050'.
    REFRESH lt_kunnr.
    APPEND INITIAL LINE TO lt_kunnr ASSIGNING <ls_kunnr>.
    IF p_kunn2 CO '*'.
      <ls_kunnr> = VALUE #( sign = 'I' option = 'CP' low = p_kunn2 ).
    ELSE.
      <ls_kunnr> = VALUE #( sign = 'I' option = 'EQ' low = p_kunn2 ).
    ENDIF.
  ENDIF.

  REFRESH gt_main_disp .

  IF sy-tcode EQ 'ZGTPPR2050'.
    REFRESH lt_grpnr.
    IF s_aufnr[] IS NOT INITIAL.

      LOOP AT s_aufnr ASSIGNING FIELD-SYMBOL(<ls_aufnr>).
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <ls_aufnr>-low
          IMPORTING
            output = <ls_aufnr>-low.
      ENDLOOP.

      SELECT * FROM zgtppt2010
        WHERE grpnr IN @s_grpnr
           AND ordnr IN @s_aufnr
          INTO TABLE @DATA(lt_2010_chk).

      SORT lt_2010_chk BY grpnr.
      DELETE ADJACENT DUPLICATES FROM lt_2010_chk COMPARING grpnr.

      LOOP AT lt_2010_chk INTO DATA(ls_2010_chk).
        APPEND INITIAL LINE TO lt_grpnr ASSIGNING FIELD-SYMBOL(<ls_grpnr>).
        <ls_grpnr>-sign = 'I'.
        <ls_grpnr>-option = 'EQ'.
        <ls_grpnr>-low = ls_2010_chk-grpnr.
      ENDLOOP.

    ELSE.

      MOVE-CORRESPONDING s_grpnr[] TO lt_grpnr.
    ENDIF.


    SELECT * FROM zgtppt2000
      INTO CORRESPONDING FIELDS OF TABLE gt_main_disp
      WHERE spgcd = p_spgcd
      AND werks = p_werks
      AND matnr IN s_matnr
      AND maktx IN s_maktx
      AND grpnr IN lt_grpnr
      AND erdat IN s_date
      AND ordno IN s_ordn2
      AND kunnr IN lt_kunnr[]
      AND edatu IN s_edat2
      AND zstatus NE 'D'
      AND gcatg IN ( '판매오더', '견적' ).

  ELSE.
    SELECT * FROM zgtppt2000
      INTO CORRESPONDING FIELDS OF TABLE gt_main_disp
      WHERE spgcd = p_spgcd
        AND werks = p_werks
        AND matnr IN s_matnr
        AND maktx IN s_maktx
        AND grpnr IN s_grpnr
        AND erdat IN s_date
        AND ordno IN s_ordno
        AND kunnr IN lt_kunnr[]
        AND edatu IN s_edatu
        AND gcatg IN ( '판매오더', '견적' ).

  ENDIF.


  REFRESH lt_grpnr.
  LOOP AT gt_main_disp INTO DATA(ls_temp_main).
    APPEND INITIAL LINE TO lt_grpnr ASSIGNING <ls_grpnr>.
    <ls_grpnr>-sign = 'I'.
    <ls_grpnr>-option = 'EQ'.
    <ls_grpnr>-low = ls_temp_main-grpnr.
  ENDLOOP.

  SORT lt_grpnr BY low.
  DELETE ADJACENT DUPLICATES FROM lt_grpnr COMPARING low.

  IF lt_grpnr[] IS NOT INITIAL.
    SELECT * FROM zgtppt2010
        INTO TABLE @DATA(lt_2010)
     WHERE grpnr IN @lt_grpnr
         AND dmordty = 'SO'.
  ENDIF.


  lt_chk_order =  VALUE  #( FOR ls_main_disp IN gt_main_disp WHERE ( zstatus NE 'D' )
                                        ( vbeln = ls_main_disp-ordno posnr = ls_main_disp-posnr matnr = ls_main_disp-matnr ) ).

  SORT lt_chk_order BY vbeln posnr.
  DELETE ADJACENT DUPLICATES FROM lt_chk_order COMPARING vbeln posnr.
  IF lt_chk_order[] IS NOT INITIAL.
    SELECT kdauf, kdpos, aufnr, posnr, psmng, wemng, psamg
      FROM afpo
      INTO TABLE @DATA(lt_afpo)
      FOR ALL ENTRIES IN @lt_chk_order
    WHERE kdauf   = @lt_chk_order-vbeln
        AND kdpos  = @lt_chk_order-posnr.

    SELECT * FROM zgtcvordsyval
      INTO CORRESPONDING FIELDS OF TABLE lt_chk_confirm
      FOR ALL ENTRIES IN lt_chk_order
    WHERE kdauf   = lt_chk_order-vbeln
        AND kdpos  = lt_chk_order-posnr.

    SELECT vbeln, posnr, lgort, charg, labst, insme, speme
      FROM zgtcv_stockval
      FOR ALL ENTRIES IN @lt_chk_order
      WHERE werks = @p_werks
          AND matnr = @lt_chk_order-matnr
          AND vbeln = @lt_chk_order-vbeln
          AND posnr = @lt_chk_order-posnr
         INTO TABLE @DATA(lt_stockval).

  ENDIF.

  LOOP AT lt_stockval INTO DATA(ls_stockval).
    MOVE-CORRESPONDING ls_stockval TO ls_stock_collect.
    COLLECT ls_stock_collect INTO lt_stock_collect.
  ENDLOOP.


  DATA(lt_chk_afpo) = lt_afpo[].
  SORT lt_chk_afpo BY aufnr posnr.
  DELETE ADJACENT DUPLICATES FROM lt_chk_afpo COMPARING aufnr posnr.

  SORT lt_chk_confirm BY grpnr kdauf kdpos .

  IF lt_chk_afpo[] IS NOT INITIAL.
* 생산이력
*  생산 수량: MSEG-BWART = '102' 이면 * -1, SUM(MSEG-MENGE - AFPO-PSAMG)
    SELECT a~aufnr, a~aufps, a~bwart, a~menge, b~psamg, b~kdauf, b~kdpos
      FROM mseg AS a
         INNER JOIN @lt_chk_afpo AS b
                                              ON a~aufnr = b~aufnr
                                             AND a~aufps = b~posnr
         WHERE a~bwart IN ('101', '102')
         INTO TABLE @DATA(lt_mseg).
  ENDIF.

  DATA : BEGIN OF ls_sum_mseg,
           vbeln LIKE zgtppt2000-ordno,
           posnr LIKE zgtppt2000-posnr,
           menge LIKE mseg-menge,
         END OF ls_sum_mseg.
  DATA : lt_sum_mseg LIKE TABLE OF ls_sum_mseg.

  LOOP AT lt_mseg INTO DATA(ls_mseg).
    CLEAR ls_sum_mseg.
    ls_sum_mseg-vbeln = ls_mseg-kdauf.
    ls_sum_mseg-posnr = ls_mseg-kdpos.

    CASE ls_mseg-bwart.
      WHEN '101'.
        ls_sum_mseg-menge = ls_mseg-menge - ls_mseg-psamg.
      WHEN '102'.
        ls_sum_mseg-menge = ( ls_mseg-menge - ls_mseg-psamg ) * -1.
    ENDCASE.

    COLLECT ls_sum_mseg INTO lt_sum_mseg.
  ENDLOOP.

  DATA : lv_wmeng TYPE zgtppt2000-wmeng. " 완료여부 계산 수량

  LOOP AT gt_main_disp ASSIGNING FIELD-SYMBOL(<ls_main_disp>).
    CASE <ls_main_disp>-zstatus.
      WHEN 'D'.
        <ls_main_disp>-status = '삭제'.
      WHEN OTHERS. " 완료 여부 확인.
**        CLEAR LV_WMENG.
**        READ TABLE  LT_SUM_MSEG INTO LS_SUM_MSEG WITH KEY VBELN = <LS_MAIN_DISP>-ORDNO
**                                                                                    POSNR = <LS_MAIN_DISP>-POSNR.
**        IF SY-SUBRC EQ 0.
**          LV_WMENG = <LS_MAIN_DISP>-WMENG - LS_SUM_MSEG-MENGE.
**          IF LV_WMENG <= 0. "판매 오더 수량 - 입고 수량 <= 0 이면 완료
**            <LS_MAIN_DISP>-STATUS = '완료'.
**          ENDIF.
**        ENDIF.

*        LOOP AT LT_2010 INTO DATA(LS_2010) WHERE grpnr =
*                                                                  AND DMORD = <LS_MAIN_DISP>-ORDNO
*                                                                  AND KDPOS = <LS_MAIN_DISP>-POSNR

        CLEAR ls_chk_confirm.

        LOOP AT lt_chk_confirm INTO ls_chk_confirm WHERE grpnr = <ls_main_disp>-grpnr
                                                                                  AND kdauf = <ls_main_disp>-ordno
                                                                                  AND kdpos = <ls_main_disp>-posnr.
          IF ls_chk_confirm-elikz = ' '.
            EXIT.
          ENDIF.
        ENDLOOP.

        IF ls_chk_confirm-elikz = 'X'.
          <ls_main_disp>-status = '완료'.

          READ TABLE lt_stock_collect INTO ls_stock_collect WITH KEY vbeln = <ls_main_disp>-ordno
                                                                                                     posnr = <ls_main_disp>-posnr.
          IF sy-subrc EQ 0.
            DATA(lv_stock) = ls_stock_collect-labst + ls_stock_collect-insme + ls_stock_collect-speme.
            IF lv_stock > 0.
              <ls_main_disp>-status = '재고'.
            ENDIF.

          ENDIF.

        ENDIF.

    ENDCASE.

    CLEAR lv_line_c.
    lv_line_c = <ls_main_disp>-linno.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = lv_line_c
      IMPORTING
        output = lv_line_c.


    <ls_main_disp>-ordno_c = <ls_main_disp>-ordno && '/' && <ls_main_disp>-posnr && '/' && lv_line_c.
    <ls_main_disp>-name1 = zgtpp_cl_common=>get_bp_name( iv_kunnr = <ls_main_disp>-kunnr  ).
* 오더의 수량은 판매오더 특성정보의 조장 * 조장수
*조장(기본단위)
*조장수
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = <ls_main_disp>-ordno
      IMPORTING
        output = lv_vbeln.
    lv_posnr = <ls_main_disp>-posnr + 0.

    zgtpp_cl_common=>get_cha_millca(
      EXPORTING
        iv_vbeln = lv_vbeln
        iv_posnr = lv_posnr
      IMPORTING
        ev_zgteindlen = lv_inlength
        ev_zgtefactor = lv_infactor  ).

    <ls_main_disp>-wmeng = lv_inlength * lv_infactor.

    <ls_main_disp>-wmeng2 = -1 * <ls_main_disp>-wmeng. " 디스플레이용 금액 -처리

    IF p_check NE abap_true.
      IF <ls_main_disp>-status = '삭제'.
        DELETE gt_main_disp.
      ENDIF.
    ENDIF.

  ENDLOOP.

* 완료처리는 해당 조장 구성표 전체가 완료여야 삭제처리
  LOOP AT gt_main_disp ASSIGNING <ls_main_disp> WHERE status NE ''.
    CASE abap_true.
      WHEN p_check OR p_chec2.
      WHEN OTHERS.
        IF <ls_main_disp>-status = '완료'.
          READ TABLE gt_main_disp TRANSPORTING NO FIELDS WITH KEY grpnr = <ls_main_disp>-grpnr
                                                                                              status = ' '.
          IF sy-subrc NE 0.
            READ TABLE gt_main_disp TRANSPORTING NO FIELDS WITH KEY grpnr = <ls_main_disp>-grpnr
                                                                                              status = '재고'.
            IF sy-subrc NE 0.
              DELETE gt_main_disp WHERE grpnr = <ls_main_disp>-grpnr.
            ENDIF.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  SORT gt_main_disp BY grpnr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed
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
  DATA : lv_num(2) TYPE n.
  DATA : lv_fname01 TYPE fieldname. "오더넘버
  DATA : lv_fname02 TYPE fieldname. " 품목번호
  DATA : lv_fname03 TYPE fieldname. " 오더타입
  DATA : lv_fname04 TYPE fieldname. " 자재
  DATA : lv_chart TYPE atwrt.
  DATA : lv_seqno TYPE i.


  FIELD-SYMBOLS <lv_value> TYPE any.
  FIELD-SYMBOLS <lv_ordnr> TYPE any.
  FIELD-SYMBOLS <lv_posnr> TYPE any.
  FIELD-SYMBOLS <lv_ordty> TYPE any.
  FIELD-SYMBOLS <lv_matnr> TYPE any.
  FIELD-SYMBOLS <lv_line_seq> TYPE any.
  CLEAR  : gv_chk_line, gv_chk_value.

  DEFINE __set_field_name.
    CLEAR : lv_fname01, lv_fname02, lv_fname03.
    lv_fname01 = &1 && '_ORDNR'.
    lv_fname02 = &1 && '_POSNR'.
    lv_fname03 = &1 && '_ORDTY'.
    lv_fname04 = &1 && '_MATNR'.
  END-OF-DEFINITION.

  DEFINE __get_index_of_table.
    IF <lv_line_seq> IS ASSIGNED. UNASSIGN <lv_line_seq>. ENDIF.
    ASSIGN COMPONENT 'LINE_SEQ' OF STRUCTURE <ls_main_201> TO <lv_line_seq>.
  END-OF-DEFINITION.

  DEFINE __assign_field.
    IF <lv_ordnr> IS ASSIGNED. UNASSIGN <lv_ordnr>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_routing> TO <lv_ordnr>.
    IF <lv_posnr> IS ASSIGNED. UNASSIGN <lv_posnr>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_routing> TO <lv_posnr>.
    IF <lv_ordty> IS ASSIGNED. UNASSIGN <lv_ordty>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_routing> TO <lv_ordty>.
    IF <lv_matnr> IS ASSIGNED. UNASSIGN <lv_matnr>. ENDIF.
    ASSIGN COMPONENT lv_fname04 OF STRUCTURE <ls_routing> TO <lv_matnr>.
  END-OF-DEFINITION.

  CASE p_sender.
    WHEN go_grid_0100 OR go_grid_0230 OR go_grid_0240.
      LOOP AT po_data_changed->mt_good_cells INTO ls_mod_cells.
        CASE ls_mod_cells-fieldname.
          WHEN 'CHECK'.
            gv_chk_line = ls_mod_cells-row_id.
            gv_chk_value = ls_mod_cells-value.
            lv_call_func = abap_true.
        ENDCASE.
      ENDLOOP.
    WHEN go_grid_0201.
      LOOP AT po_data_changed->mt_good_cells INTO ls_mod_cells.
        SPLIT ls_mod_cells-fieldname AT '_' INTO TABLE DATA(lt_string).
        READ TABLE lt_string INTO DATA(ls_string) INDEX 1.
        lv_seqno = ls_string + 0.
        READ TABLE lt_string INTO ls_string INDEX 2.
        lv_chart = ls_string.

        READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY chart = lv_chart
                                                                                                       seqno = lv_seqno.
        IF sy-subrc EQ 0.
          READ TABLE <gt_main_201> ASSIGNING FIELD-SYMBOL(<ls_main_201>) INDEX ls_mod_cells-row_id.
          __get_index_of_table.
          READ TABLE <gt_routing> ASSIGNING FIELD-SYMBOL(<ls_routing>) INDEX <lv_line_seq>.
          DO.
            ADD 1 TO lv_num.
            __set_field_name lv_num.
            __assign_field.
            IF <lv_ordty> = ls_seq_routing-chart AND <lv_matnr> = ls_seq_routing-matnr.
              READ TABLE gt_2010 ASSIGNING FIELD-SYMBOL(<ls_2010>) WITH KEY gong_cd = lv_chart
                                                                                                          ordnr = <lv_ordnr>
                                                                                                          posnr = <lv_posnr>.
              IF sy-subrc EQ 0.
                IF <lv_value> IS ASSIGNED. UNASSIGN <lv_value>. ENDIF.
                ASSIGN COMPONENT 'CHK_CHAR' OF STRUCTURE <ls_2010> TO <lv_value>.
                IF <lv_value> IS ASSIGNED.
                  <lv_value> = ls_mod_cells-value.
                ENDIF.
              ENDIF.
              EXIT.
            ENDIF.

            IF lv_num >= gv_line_jojang.
              EXIT.
            ENDIF.
          ENDDO.

        ENDIF.
      ENDLOOP.

  ENDCASE.

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

ENDFORM.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_alv_0100 OUTPUT.

  IF go_grid_0100 IS NOT BOUND.
    PERFORM set_object_grid_0100.
    PERFORM event_handler_register USING go_grid_0100.
    PERFORM set_layout_grid_0100.
    PERFORM set_fieldcat_grid_0100.
    PERFORM set_sorttab_grid_0100.
    PERFORM set_cell_attribute_grid_0100.
    PERFORM exclude_of_toolbar_grid_0100.
    PERFORM call_grid_0100_display.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_object_grid_0100 .

  CREATE OBJECT go_contain_0100
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

  CREATE OBJECT go_grid_0100
    EXPORTING
      i_parent      = go_contain_0100
      i_appl_events = abap_true.

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
  gs_layout_0100-no_rowmark   = 'X'.
  gs_layout_0100-sel_mode   = 'C'.
  gs_layout_0100-stylefname = 'CELLTAB'.
  gs_layout_0100-ctab_fname   = 'CELLCOL'.

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
      i_inclname             = 'ZGTPPR2010TOP'
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
  <ls_fcat>-fieldname = 'STATUS'.
  <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '상태'.
  <ls_fcat>-col_pos = 1.
  <ls_fcat>-datatype = 'CHAR'.
  <ls_fcat>-dd_outlen = '10'.
  <ls_fcat>-just = 'C'.
  <ls_fcat>-key = abap_true.

*  APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
*  <LS_FCAT>-FIELDNAME = 'CHECK'.
*  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '상태'.
*  <LS_FCAT>-COL_POS = 2.
*  <LS_FCAT>-DATATYPE = 'CHAR'.
*  <LS_FCAT>-DD_OUTLEN = '1'.
*  <LS_FCAT>-JUST = 'C'.
*  <LS_FCAT>-KEY = ABAP_TRUE.
*  <LS_FCAT>-CHECKBOX = ABAP_TRUE.
*  <LS_FCAT>-EDIT = ABAP_TRUE.

  APPEND INITIAL LINE TO gt_fieldcat_0100 ASSIGNING <ls_fcat>.
  <ls_fcat>-fieldname = 'ORDNO_C'.
  <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '오더번호'.
  <ls_fcat>-col_pos = 7.
  <ls_fcat>-datatype = 'CHAR'.
  <ls_fcat>-dd_outlen = '30'.
  <ls_fcat>-just = 'C'.
  <ls_fcat>-key = abap_true.



  LOOP AT gt_fieldcat_0100 ASSIGNING <ls_fcat>.
    CASE   <ls_fcat>-fieldname.
      WHEN 'ZSTATUS'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'CHECK'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '선택'.
        <ls_fcat>-just = 'C'.
        <ls_fcat>-key = abap_true.
        <ls_fcat>-checkbox = abap_true.
        <ls_fcat>-edit = abap_true.
      WHEN 'GRPNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '조장구성표번호'.
        <ls_fcat>-just = 'C'.
        <ls_fcat>-key = abap_true.
      WHEN 'ERDAT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '작성일'.
        <ls_fcat>-just = 'C'.
        <ls_fcat>-key = abap_true.
      WHEN 'GCATG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '범주'.
        <ls_fcat>-just = 'C'.
        <ls_fcat>-key = abap_true.
      WHEN 'MATNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '제품'.
        <ls_fcat>-just = 'C'.
        <ls_fcat>-key = abap_true.
      WHEN 'ORDNO'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'POSNR'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'LINNO'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'MAKTX'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '제품내역'.
        <ls_fcat>-just = 'L'.
      WHEN 'KUNNR'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'NAME1'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '납품처'.
        <ls_fcat>-just = 'L'.
      WHEN 'EDATU'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '납품요청일'.
        <ls_fcat>-just = 'C'.
      WHEN 'WMENG'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'WMENG2'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '총수량'.
        <ls_fcat>-just = 'R'.
      WHEN 'INLENGTH'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '조장'.
        <ls_fcat>-just = 'R'.
      WHEN 'MEINS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '단위'.
        <ls_fcat>-just = 'C'.
      WHEN 'INFACTOR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '조장수'.
        <ls_fcat>-just = 'R'.
        <ls_fcat>-decimals_o = '0'.
      WHEN 'ERNAM'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '생성자'.
        <ls_fcat>-just = 'C'.
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
      it_sort              = gt_sort_0100
      it_fieldcatalog      = gt_fieldcat_0100.

* 인풋이벤트 추가
  CALL METHOD go_grid_0100->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CALL METHOD go_grid_0100->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_cell_attribute_grid_0100 .
* 셀 컬러부여
  DATA : lt_coltab TYPE lvc_t_scol.
  DATA : ls_coltab TYPE lvc_s_scol.

  DATA : lt_celltab TYPE lvc_t_styl.
  DATA : ls_celltab TYPE lvc_s_styl.

  DATA : BEGIN OF ls_chk_grpnr,
           grpnr TYPE zgtppt2010-grpnr,
           seqno TYPE i,
         END OF ls_chk_grpnr.
  DATA : lt_chk_grpnr LIKE TABLE OF ls_chk_grpnr.
  DATA : lv_seqno TYPE i.

  DATA(lt_chk_main) = gt_main_disp.
  SORT lt_chk_main BY grpnr.
  DELETE ADJACENT DUPLICATES FROM lt_chk_main COMPARING grpnr.
  LOOP AT lt_chk_main INTO DATA(ls_chk_main).
    CLEAR ls_chk_grpnr.
    ls_chk_grpnr-grpnr = ls_chk_main-grpnr.
    IF lv_seqno = 1.
      ls_chk_grpnr-seqno = lv_seqno.
      lv_seqno = 0.
    ELSE.
      ls_chk_grpnr-seqno = lv_seqno.
      lv_seqno = 1.
    ENDIF.
    APPEND ls_chk_grpnr TO lt_chk_grpnr.
  ENDLOOP.

  LOOP AT gt_main_disp ASSIGNING FIELD-SYMBOL(<ls_main_disp>).
    REFRESH lt_coltab.
    REFRESH lt_celltab.

    LOOP AT gt_fieldcat_0100 INTO DATA(ls_fieldcat).
      CASE ls_fieldcat-fieldname.
        WHEN 'STATUS'.
          CASE <ls_main_disp>-status.
            WHEN '삭제'.
*        바탕 빨강
              CLEAR ls_celltab.
              ls_celltab-fieldname = 'STATUS'.
              ls_celltab-style = alv_style_color_int_negative.
*              LS_CELLTAB-STYLE2 = ALV_STYLE_COLOR_INV_BACKGROUND.
              INSERT ls_celltab INTO TABLE lt_celltab.
*            체크박스 수정금지
              CLEAR ls_celltab.
              ls_celltab-fieldname = 'CHECK'.
              ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
              INSERT ls_celltab INTO TABLE lt_celltab.
            WHEN '재고'.
              CLEAR ls_celltab.
              ls_celltab-fieldname = 'STATUS'.
              ls_celltab-style = alv_style_color_int_group.
              INSERT ls_celltab INTO TABLE lt_celltab.
            WHEN '완료'.
            WHEN OTHERS.
              CLEAR ls_coltab.
              ls_celltab-fieldname = ls_fieldcat-fieldname.
              ls_celltab-style = alv_style_color_int_key + cl_gui_alv_grid=>mc_style_disabled.
              INSERT ls_celltab INTO TABLE lt_celltab.
          ENDCASE.
        WHEN 'GRPNR' OR 'ERDAT' OR 'ORDNO_C' OR 'GCATG' OR 'MATNR' OR 'MAKTX' OR
                 'KUNNR' OR  'NAME1' OR 'EDATU' OR 'WMENG2' OR 'INLENGTH' OR 'INFACTOR' OR 'ERNAM' OR 'MEINS'.
*       key 색깔지정
          CLEAR ls_coltab.
          ls_celltab-fieldname = ls_fieldcat-fieldname.
          READ TABLE lt_chk_grpnr INTO ls_chk_grpnr WITH KEY grpnr = <ls_main_disp>-grpnr.
          IF sy-subrc EQ 0.
            IF ls_chk_grpnr-seqno = 1.
              ls_celltab-style = alv_style_color_key.
            ELSE.
              ls_celltab-style = alv_style_color_total.
            ENDIF.
          ENDIF.
          INSERT ls_celltab INTO TABLE lt_celltab.
      ENDCASE.
    ENDLOOP.
    <ls_main_disp>-cellcol = lt_coltab.
    <ls_main_disp>-celltab = lt_celltab.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHECK_BOX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_check_box .

  LOOP AT gt_main_disp ASSIGNING FIELD-SYMBOL(<ls_disp_201>).
    CLEAR <ls_disp_201>-check.
  ENDLOOP.

  READ TABLE gt_main_disp INTO DATA(ls_main_disp) INDEX gv_chk_line.
  ls_main_disp-check = gv_chk_value.
  MODIFY gt_main_disp FROM ls_main_disp TRANSPORTING check WHERE grpnr = ls_main_disp-grpnr .

  PERFORM refresh_grid USING go_grid_0100.

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

  CASE po_grid.
    WHEN go_grid_0100.
      PERFORM set_cell_attribute_grid_0100.
  ENDCASE.

  CALL METHOD po_grid->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = ls_scroll.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_BOM_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_bom_proc .

  DATA : BEGIN OF ls_chk_grpnr,
           grpnr TYPE zgtppt2000-grpnr,
         END OF ls_chk_grpnr.
  DATA : lt_chk_grpnr LIKE TABLE OF ls_chk_grpnr.
  DATA : lv_matnr TYPE mara-matnr.
  DATA : ls_topmat TYPE cstmat.
  DATA : lt_stb TYPE TABLE OF stpox.
  DATA : lt_cscmat TYPE TABLE OF cscmat.
  DATA : lt_seq_routing LIKE gt_seq_routing.
  DATA : lv_check.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 1                 "indicator에 진행률(%)
      text       = '처리중..'.  "텍스트 표시

* 선택된 조장번호로 조장구성표 출력
  lt_chk_grpnr = VALUE #( FOR wa_main_disp IN gt_main_disp WHERE ( check = abap_true ) ( grpnr = wa_main_disp-grpnr ) ).

  SORT lt_chk_grpnr.
  DELETE ADJACENT DUPLICATES FROM lt_chk_grpnr.

  IF lines( lt_chk_grpnr ) = 0.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '선택된 조장구성표 번호가 없습니다.'.
    RETURN.
  ENDIF.

  IF lines( lt_chk_grpnr ) > 1.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '하나의 조장구성표 번호만 선택 가능합니다.'.
    RETURN.
  ENDIF.

* 공정 라우팅 구성을 위한 특성조회
  REFRESH gt_seq_routing.
  READ TABLE gt_main_disp INTO DATA(ls_main_disp) WITH KEY check = abap_true.
  lv_matnr = ls_main_disp-matnr.
  gv_grpnr = ls_main_disp-grpnr. " 공정 구성표 번호

* 조장구성표 관리시는 lock 설정
  IF sy-tcode NE 'ZGTPPR2050'.
    CLEAR lv_check.
    CLEAR gv_check_lock.
    PERFORM check_and_lock CHANGING lv_check.
    IF lv_check IS NOT INITIAL.
      gv_check_lock = abap_true.
      RETURN.
    ENDIF.
  ENDIF.

* BOM 하위전개
  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      aumgb                 = abap_on
      capid                 = 'PP01'
      datuv                 = sy-datum
      ehndl                 = '1'
      mktls                 = abap_on
      mehrs                 = abap_on
      mmory                 = '1'
      mtnrv                 = lv_matnr
      werks                 = p_werks
    IMPORTING
      topmat                = ls_topmat
    TABLES
      stb                   = lt_stb
      matcat                = lt_cscmat
    EXCEPTIONS
      alt_not_found         = 1
      call_invalid          = 2
      material_not_found    = 3
      missing_authorization = 4
      no_bom_found          = 5
      no_plant_data         = 6
      no_suitable_bom_found = 7
      conversion_error      = 8
      OTHERS                = 9.


  IF lt_cscmat[] IS NOT INITIAL.
    SELECT a~index AS seqno, a~matnr, b~mtart, c~maabc
      FROM @lt_cscmat AS a
      INNER JOIN mara AS b
                            ON b~matnr = a~matnr
      INNER JOIN marc AS c
                            ON c~matnr = a~matnr
                          AND c~werks = @p_werks
     WHERE b~mtart   IN ( 'MCFE', 'MCHF' )  " 완제품 반제품만 공정대상
       AND c~dismm IN ( 'X0', 'PD' )
       AND ( c~beskz = 'E' OR
            ( c~beskz = 'F' AND
              c~sobsl = 30 ) OR
            ( c~beskz = 'F' AND
              c~sobsl LIKE '4%' ) )
       AND c~maabc NE 'C'
       AND c~dpcbt EQ 'C'
       AND ( a~index EQ 1
        OR ( a~index NE 1
       AND  a~verid IS NOT INITIAL ) )
      INTO CORRESPONDING FIELDS OF TABLE @lt_seq_routing.
  ENDIF.

  SORT lt_stb BY stufe wegxx.
  LOOP AT lt_stb INTO DATA(ls_stb).
    READ TABLE lt_seq_routing ASSIGNING FIELD-SYMBOL(<ls_seq_routing_chk>) WITH KEY seqno = ls_stb-ttidx.
    IF sy-subrc EQ 0.
      DATA(lv_idx) = sy-tabix.
      <ls_seq_routing_chk>-seqno = lines( gt_seq_routing ) + 1.
      <ls_seq_routing_chk>-stufe = ls_stb-stufe.
      APPEND <ls_seq_routing_chk> TO gt_seq_routing.
      DELETE lt_seq_routing INDEX lv_idx.
    ENDIF.
  ENDLOOP.

  IF gt_seq_routing[] IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input  = lv_matnr
      IMPORTING
        output = lv_matnr.
    MESSAGE s000 DISPLAY LIKE 'E' WITH '조장 구성표를 진행할 수 없는 자재입니다.('lv_matnr ').'.
    RETURN.
  ENDIF.

*특성 코드값 밸류 찾아오기
  DATA : ls_chardetail TYPE bapicharactdetail.
  DATA : lt_chartval TYPE TABLE OF bapicharactvaluesdescr.
  DATA : lt_return TYPE TABLE OF bapiret2.

  CALL FUNCTION 'BAPI_CHARACT_GETDETAIL'
    EXPORTING
      charactname        = 'PD_CA_PROC_NAME'
      keydate            = sy-datum
      language           = sy-langu
    IMPORTING
      charactdetail      = ls_chardetail
    TABLES
      charactvaluesdescr = lt_chartval
      return             = lt_return.

  CLEAR gv_line_jojang.
*   공정구성표 공정 추출
  SORT gt_seq_routing BY seqno.
  LOOP AT gt_seq_routing ASSIGNING FIELD-SYMBOL(<ls_seq_routing>).
    <ls_seq_routing>-seqno = sy-tabix.
    PERFORM get_chart_pd_ca_proc_name USING <ls_seq_routing>-matnr
                                                         CHANGING <ls_seq_routing>-chart.
*   Chart desc
    READ TABLE lt_chartval INTO DATA(ls_chartval) WITH KEY value_char = <ls_seq_routing>-chart.
    IF sy-subrc EQ 0.
      <ls_seq_routing>-chart_val = ls_chartval-description.
    ENDIF.

    IF <ls_seq_routing>-maabc NE 'B'.
      gv_line_jojang = gv_line_jojang + 1.
    ENDIF.

  ENDLOOP.

  LOOP AT gt_seq_routing ASSIGNING <ls_seq_routing>.
    CLEAR lv_check.
    PERFORM check_available USING <ls_seq_routing>-matnr CHANGING lv_check.
    IF lv_check = abap_true.
      DELETE gt_seq_routing.
    ELSEIF lv_check = 'E'.
      RETURN.
    ENDIF.
  ENDLOOP.

  CLEAR gv_line_jojang.
*   공정구성표 공정 추출
  LOOP AT gt_seq_routing ASSIGNING <ls_seq_routing>.
    <ls_seq_routing>-seqno = sy-tabix.
    IF <ls_seq_routing>-maabc NE 'B'.
      gv_line_jojang = gv_line_jojang + 1.
    ENDIF.

  ENDLOOP.

  CLEAR gv_chk_she.
  LOOP AT gt_seq_routing INTO DATA(ls_seq_routing) WHERE chart = 'SHE'.
    IF ls_seq_routing-seqno NE 1.
      PERFORM chk_she USING ls_seq_routing-matnr ls_seq_routing-seqno CHANGING gv_chk_she.
      IF gv_chk_she IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

* 공정표 품목 구성을 위해 동적테이블 구성
  PERFORM set_fieldcat_grid_0201.
  PERFORM make_routing.

  IF gv_chk_subpool_dir_full IS NOT INITIAL.
    RETURN.
  ENDIF.

* 상세데이터 구성(Header)
  PERFORM make_data_200.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 10                 "indicator에 진행률(%)
      text       = '처리중..'.  "텍스트 표시

* 상세데이터 구성(Item)
  PERFORM make_data_201.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 100                 "indicator에 진행률(%)
      text       = '완료'.  "텍스트 표시

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CHART_PD_CA_PROC_NAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_SEQ_ROUTING>_MATNR
*&      <-- <LS_SEQ_ROUTING>_CHART
*&---------------------------------------------------------------------*
FORM get_chart_pd_ca_proc_name  USING    pv_matnr TYPE matnr
                                CHANGING pv_chart.

  SELECT SINGLE a~atwrt
    INTO pv_chart
    FROM ausp AS a
    INNER JOIN cabn AS b
                          ON b~atinn = a~atinn
    WHERE a~objek = pv_matnr
       AND b~atnam = 'PD_CA_PROC_NAME'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0201 .

  DATA : lv_num(2) TYPE n.
  DATA : lv_colpos TYPE i.
  SORT gt_seq_routing BY seqno DESCENDING.

  DATA : lv_fieldval(50) .

  REFRESH gt_fieldcat_0201.

* 순번
  APPEND INITIAL LINE TO gt_fieldcat_0201 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
  <ls_fcat>-fieldname = 'DISP_SEQNO'.
  <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '순번'.
  <ls_fcat>-col_pos = 1.
  <ls_fcat>-datatype = 'NUMC'.
  <ls_fcat>-dd_outlen = '6'.
  <ls_fcat>-outputlen = '2'.
  <ls_fcat>-just = 'C'.

* 순번
  APPEND INITIAL LINE TO gt_fieldcat_0201 ASSIGNING <ls_fcat>.
  <ls_fcat>-fieldname = 'SEQNO'.
  <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '순번'.
  <ls_fcat>-col_pos = 2.
  <ls_fcat>-datatype = 'NUMC'.
  <ls_fcat>-dd_outlen = '6'.
  <ls_fcat>-outputlen = '2'.
  <ls_fcat>-just = 'C'.
  <ls_fcat>-no_out = abap_true.

* 순번(내부 인덱스 조절용)
  APPEND INITIAL LINE TO gt_fieldcat_0201 ASSIGNING <ls_fcat>.
  <ls_fcat>-fieldname = 'LINE'.
  <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '순번'.
  <ls_fcat>-col_pos = 3.
  <ls_fcat>-datatype = 'NUMC'.
  <ls_fcat>-dd_outlen = '6'.
  <ls_fcat>-just = 'C'.
  <ls_fcat>-no_out = abap_true.

* 순번(내부 인덱스 조절용)
  APPEND INITIAL LINE TO gt_fieldcat_0201 ASSIGNING <ls_fcat>.
  <ls_fcat>-fieldname = 'LINE_SEQ'.
  <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '순번'.
  <ls_fcat>-col_pos = 4.
  <ls_fcat>-datatype = 'NUMC'.
  <ls_fcat>-dd_outlen = '6'.
  <ls_fcat>-just = 'C'.
  <ls_fcat>-no_out = abap_true.


  CLEAR lv_colpos.
  LOOP AT gt_seq_routing ASSIGNING FIELD-SYMBOL(<ls_routing>).
    APPEND INITIAL LINE TO gt_fieldcat_0201 ASSIGNING <ls_fcat>.
    CLEAR lv_num.
    lv_num = <ls_routing>-seqno + 0.
    <ls_fcat>-fieldname = lv_num && '_' && <ls_routing>-chart && '_CHK'.
    lv_colpos = lv_colpos + 10.
    <ls_fcat>-col_pos = lv_colpos.
    <ls_fcat>-datatype = 'CHAR'.
    <ls_fcat>-dd_outlen = '2'.
    <ls_fcat>-outputlen = '2'.
    <ls_fcat>-just = 'L'.
    IF sy-tcode EQ 'ZGTPPR2050'.
      <ls_fcat>-no_out = 'X'.
    ENDIF.

    APPEND INITIAL LINE TO gt_fieldcat_0201 ASSIGNING <ls_fcat>.
    CLEAR lv_num.
    lv_num = <ls_routing>-seqno + 0.
    <ls_fcat>-fieldname = lv_num && '_' && <ls_routing>-chart.
    CLEAR lv_fieldval.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input  = <ls_routing>-matnr
      IMPORTING
        output = lv_fieldval.

    lv_fieldval = <ls_routing>-chart_val && ' [' && lv_fieldval && ']'.

    IF <ls_routing>-seqno = 1.
      <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = lv_fieldval && '(END)'.
    ELSE.
      <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = lv_fieldval.
    ENDIF.
    lv_colpos = lv_colpos + 10.
    <ls_fcat>-col_pos = lv_colpos.
    <ls_fcat>-datatype = 'CHAR'.
    <ls_fcat>-dd_outlen = '50'.
    <ls_fcat>-outputlen = '23'.
    <ls_fcat>-just = 'L'.
*    <LS_FCAT>-ICON = ABAP_TRUE.
  ENDLOOP.

* 오더번호
  APPEND INITIAL LINE TO gt_fieldcat_0201 ASSIGNING <ls_fcat>.
  <ls_fcat>-fieldname = 'ORDNO_C'.
  <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '오더번호'.
  <ls_fcat>-col_pos = 300.
  <ls_fcat>-datatype = 'CHAR'.
  <ls_fcat>-dd_outlen = '30'.
  <ls_fcat>-outputlen = '23'.
  <ls_fcat>-just = 'L'.

  FREE gt_main_201.

  DATA : lt_abaplist TYPE TABLE OF abaplist.

  CALL FUNCTION 'LIST_FROM_MEMORY'
    TABLES
      listobject = lt_abaplist
    EXCEPTIONS
      not_found  = 1
      OTHERS     = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  cl_alv_table_create=>create_dynamic_table(
    EXPORTING
      i_style_table       = abap_true
      it_fieldcatalog           = gt_fieldcat_0201                " Field Catalog
    IMPORTING
      ep_table                  = gt_main_201                 " Pointer to Dynamic Data Table
    EXCEPTIONS
      generate_subpool_dir_full = 1                " At Most 36 Subroutine Pools Can Be Generated Temporarily
      OTHERS                    = 2
  ).
  IF sy-subrc <> 0.
    MESSAGE s005 DISPLAY LIKE 'E' WITH 'At Most 36 Subroutine Pools' 'Can Be Generated Temporarily'.
    gv_chk_subpool_dir_full = abap_true.
    RETURN.
  ENDIF.

  ASSIGN gt_main_201->* TO <gt_main_201>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DATA_201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_data_201 .

  DATA : ls_201_01 TYPE REF TO data. " 아이템 2줄로 추가를 위해 아이템 필드 2개 구성
  DATA : ls_201_02 TYPE REF TO data. " 아이템 2줄로 추가를 위해 아이템 필드 2개 구성

  FIELD-SYMBOLS : <ls_line01> TYPE any,
                  <ls_line02> TYPE any.
  FIELD-SYMBOLS : <lv_value01> TYPE any,
                  <lv_value02> TYPE any,
                  <lv_value03> TYPE any.
  DATA : lv_line_no(6) TYPE n.

  DATA : lv_fname01 TYPE fieldname. "오더넘버
  DATA : lv_fname02 TYPE fieldname. " 품목번호
  DATA : lv_fname03 TYPE fieldname. " 오더타입
  DATA : lv_fname04 TYPE fieldname. " 중복확인
  DATA : lv_fname05 TYPE fieldname. " 재고상태
  DATA : lv_fname06 TYPE fieldname. " 오더완료, 재고 0 이후공정 진행중
  DATA : lv_chart_name TYPE fieldname. " 공정명

  DATA : lv_num(2) TYPE n.
  DATA : lv_chk_jego.

  DATA : lv_tabix TYPE i.

  FIELD-SYMBOLS : <lv_ordnr>      TYPE any,
                  <lv_posnr>      TYPE any,
                  <lv_ordty>      TYPE any,
                  <lv_chk_duple>  TYPE any,
                  <lv_chk_stock>  TYPE any,
                  <lv_chk_zero>   TYPE any,
                  <lv_disp_seqno> TYPE any.

  DEFINE __set_field_of_line.
    IF <lv_value01> IS ASSIGNED. UNASSIGN <lv_value01>. ENDIF.
    ASSIGN COMPONENT &1 OF STRUCTURE <ls_line01> TO <lv_value01>.
    IF <lv_value02> IS ASSIGNED. UNASSIGN <lv_value02>. ENDIF.
    ASSIGN COMPONENT &1 OF STRUCTURE <ls_line02> TO <lv_value02>.
  END-OF-DEFINITION.

  DEFINE __get_field_of_routing.
    IF <lv_value03> IS ASSIGNED. UNASSIGN <lv_value03>. ENDIF.
    ASSIGN COMPONENT &1 OF STRUCTURE <ls_routing> TO <lv_value03>.
  END-OF-DEFINITION.

  DEFINE __set_field_name_of_routing.
    CLEAR : lv_fname01, lv_fname02, lv_fname03.
    lv_fname01 = &1 && '_ORDNR'.
    lv_fname02 = &1 && '_POSNR'.
    lv_fname03 = &1 && '_ORDTY'.
    lv_fname04 = &1 && '_CHK_DUP'.
    lv_fname05 = &1 && '_STOCK'.
    lv_fname06 = &1 && '_ZERO'.
  END-OF-DEFINITION.

  DEFINE __get_order_field_of_routing.
    IF <lv_ordnr> IS ASSIGNED. UNASSIGN <lv_ordnr>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_routing> TO <lv_ordnr>.
    IF <lv_posnr> IS ASSIGNED. UNASSIGN <lv_posnr>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_routing> TO <lv_posnr>.
    IF <lv_ordty> IS ASSIGNED. UNASSIGN <lv_ordty>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_routing> TO <lv_ordty>.
    IF <lv_chk_duple> IS ASSIGNED. UNASSIGN <lv_chk_duple>. ENDIF.
    ASSIGN COMPONENT lv_fname04 OF STRUCTURE <ls_routing> TO <lv_chk_duple>.
    IF <lv_chk_stock> IS ASSIGNED. UNASSIGN <lv_chk_stock>. ENDIF.
    ASSIGN COMPONENT lv_fname05 OF STRUCTURE <ls_routing> TO <lv_chk_stock>.
    IF <lv_chk_zero> IS ASSIGNED. UNASSIGN <lv_chk_zero>. ENDIF.
    ASSIGN COMPONENT lv_fname06 OF STRUCTURE <ls_routing> TO <lv_chk_zero>.
  END-OF-DEFINITION.


* 데이타 체인구성
  PERFORM make_chain_data.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 50                 "indicator에 진행률(%)
      text       = '처리중..'.  "텍스트 표시

  CREATE DATA ls_201_01 LIKE LINE OF <gt_main_201>.
  CREATE DATA ls_201_02 LIKE LINE OF <gt_main_201>.
  ASSIGN ls_201_01->* TO <ls_line01>.
  ASSIGN ls_201_02->* TO <ls_line02>.
* 츨력테이블 구성
  REFRESH <gt_main_201>.

  LOOP AT <gt_routing> ASSIGNING FIELD-SYMBOL(<ls_routing>).
    lv_tabix = lv_tabix + 1.
    CLEAR : <ls_line01>, <ls_line02>.

* 순번
    __set_field_of_line 'SEQNO'.
    __get_field_of_routing 'SEQNO'.
    <lv_value01> = <lv_value03>.
    <lv_value02> = <lv_value03>.

* 순번(내부 인덱스 조절용)(고정)
    __set_field_of_line 'LINE'.
    <lv_value01> = 1.
    <lv_value02> = 2.

* 순번(내부 인덱스 조절용)(인덱스)
    __set_field_of_line 'LINE_SEQ'.
    <lv_value01> = lv_tabix.
    <lv_value02> = lv_tabix.

* 라우팅별 데이터 구성
    CLEAR lv_chk_jego.
    DO.
      ADD 1 TO lv_num.
      __set_field_name_of_routing lv_num.
      __get_order_field_of_routing.
      CLEAR lv_chart_name.
      PERFORM set_field_chart USING lv_num <lv_ordty> CHANGING lv_chart_name.
      __set_field_of_line lv_chart_name.
      IF <lv_chk_duple> IS INITIAL.
        PERFORM make_routing_comment  USING <lv_ordnr> <lv_posnr> <lv_ordty>
                                      CHANGING <lv_value01> <lv_value02> <lv_chk_stock> <lv_chk_zero>.
      ENDIF.
      IF lv_num => gv_line_jojang.
        EXIT.
      ENDIF.
      IF <lv_ordty> = 'PRD' AND lv_chk_jego IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDDO.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = 80                 "indicator에 진행률(%)
        text       = '처리중..'.  "텍스트 표시

* 헤더 조장수로 분리하여 어팬드 후 2번 째라인에 내용 추가
    CLEAR lv_num.
    __set_field_name_of_routing lv_num.
    __get_order_field_of_routing.
    IF <lv_chk_duple> IS INITIAL.
      READ TABLE gt_main_200 INTO DATA(ls_main_200) WITH KEY ordno = <lv_ordnr>
                                                             posnr = <lv_posnr>.
      IF sy-subrc EQ 0.
        __set_field_of_line 'ORDNO_C'.
        CONCATENATE ls_main_200-gcatg ls_main_200-ordno_c INTO <lv_value02> SEPARATED BY space.
      ENDIF.
    ENDIF.

    APPEND <ls_line01> TO <gt_main_201>.
    APPEND <ls_line02> TO <gt_main_201>.
  ENDLOOP.

* 디스플레이 순번 세팅
  DATA : lv_seqno(6) TYPE n.
  CLEAR lv_seqno.
  LOOP AT <gt_main_201> ASSIGNING FIELD-SYMBOL(<ls_main_201>).
    IF <lv_value01> IS ASSIGNED. UNASSIGN <lv_value01>. ENDIF.
    ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <ls_main_201> TO <lv_value01>.
    IF <lv_value01> NE lv_seqno.
      lv_seqno = <lv_value01>.
      IF <lv_disp_seqno> IS ASSIGNED. UNASSIGN <lv_disp_seqno>. ENDIF.
      ASSIGN COMPONENT 'DISP_SEQNO' OF STRUCTURE <ls_main_201> TO <lv_disp_seqno>.
      <lv_disp_seqno> = <lv_value01>.
    ENDIF.
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
      rows    = 3
      columns = 1.

  go_splitter->set_row_height(
    EXPORTING
      id                =    1              " Row ID
      height            =    5 ).             " Height

  go_splitter->set_row_height(
    EXPORTING
      id                =    2              " Row ID
      height            =    25 ).             " Height

* top 컨테이너(Title)
  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_contain_top_0200.
* top 컨테이너(Grid)
  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_contain_0200.
* bottom 컨테이너
  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 3
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
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM event_handler_register  USING    po_grid TYPE REF TO cl_gui_alv_grid.

  IF go_event_handler IS NOT BOUND.
    CREATE OBJECT go_event_handler.
  ENDIF.

  CASE po_grid.
    WHEN go_grid_0100.
*// Event Handler ##
      SET HANDLER go_event_handler->handle_data_changed               FOR po_grid.
    WHEN go_grid_0200.
      SET HANDLER go_event_handler->handle_top_of_page          FOR po_grid.
      SET HANDLER go_event_handler->handle_double_click          FOR po_grid.
    WHEN go_grid_0201.
      IF sy-tcode NE 'ZGTPPR2050'.
        SET HANDLER go_event_handler->handle_toolbar               FOR po_grid.
        SET HANDLER go_event_handler->handle_user_command          FOR po_grid.
      ENDIF.
      SET HANDLER go_event_handler->handle_double_click          FOR po_grid.
      SET HANDLER go_event_handler->handle_data_changed          FOR po_grid.
      SET HANDLER go_event_handler->handle_context_menu          FOR po_grid.
    WHEN go_grid_0220.
      SET HANDLER go_event_handler->handle_double_click          FOR po_grid.
    WHEN go_grid_0230.
      SET HANDLER go_event_handler->handle_data_changed          FOR po_grid.
    WHEN go_grid_0240.
      SET HANDLER go_event_handler->handle_data_changed          FOR po_grid.
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
  gs_layout_0200-sel_mode   = 'C'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form alv_top_of_page
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
  ENDCASE.


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

* 프로젝트명
  CONCATENATE '조장구성표번호' gv_grpnr INTO lv_text SEPARATED BY space.

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
      i_inclname             = 'ZGTPPR2010TOP'
      i_internal_tabname     = 'GS_MAIN_200'
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
      it_data         = gt_main_200
    EXCEPTIONS
      OTHERS          = 1.

  APPEND INITIAL LINE TO gt_fieldcat_0200 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
  <ls_fcat>-fieldname = 'ORDNO_C'.
  <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '오더번호'.
  <ls_fcat>-col_pos = 4.
  <ls_fcat>-datatype = 'CHAR'.
  <ls_fcat>-dd_outlen = '30'.
  <ls_fcat>-just = 'C'.

  APPEND INITIAL LINE TO gt_fieldcat_0200 ASSIGNING <ls_fcat>.
  <ls_fcat>-fieldname = 'PACK_YN'.
  <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '포장재지정'.
  <ls_fcat>-col_pos = 50.
  <ls_fcat>-datatype = 'CHAR'.
  <ls_fcat>-dd_outlen = '20'.
  <ls_fcat>-just = 'C'.

  APPEND INITIAL LINE TO gt_fieldcat_0200 ASSIGNING <ls_fcat>.
  <ls_fcat>-fieldname = 'PACK_NO'.
  <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '포장재코드'.
  <ls_fcat>-col_pos = 60.
  <ls_fcat>-datatype = 'CHAR'.
  <ls_fcat>-dd_outlen = '30'.
  <ls_fcat>-just = 'C'.

  LOOP AT gt_fieldcat_0200 ASSIGNING <ls_fcat>.
    CASE   <ls_fcat>-fieldname.
      WHEN 'GRPNR'.
        <ls_fcat>-no_out = 'X'.
      WHEN 'ERDAT'.
        <ls_fcat>-no_out = 'X'.
      WHEN 'GCATG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '범주'.
        <ls_fcat>-just = 'C'.
      WHEN 'MATNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '제품'.
        <ls_fcat>-just = 'C'.
      WHEN 'ORDNO'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'POSNR'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'LINNO'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'MAKTX'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '제품내역'.
        <ls_fcat>-just = 'L'.
      WHEN 'KUNNR'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'NAME1'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '납품처'.
        <ls_fcat>-just = 'L'.
      WHEN 'EDATU'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '납품요청일'.
        <ls_fcat>-just = 'C'.
      WHEN 'WMENG'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'WMENG2'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '총수량'.
        <ls_fcat>-just = 'R'.
      WHEN 'INLENGTH'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '조장'.
        <ls_fcat>-just = 'R'.
      WHEN 'MEINS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '단위'.
        <ls_fcat>-just = 'C'.
      WHEN 'INFACTOR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '조장수'.
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
      it_outtab            = gt_main_200
*     IT_SORT              = GT_SORT_0200
      it_fieldcatalog      = gt_fieldcat_0200.

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
*& Form SET_OBJECT_GRID_0201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_object_grid_0201 .

  CREATE OBJECT go_grid_0201
    EXPORTING
      i_parent      = go_contain_0201
      i_appl_events = abap_true.

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

  CLEAR gs_layout_0201.
  gs_layout_0201-sel_mode = 'D'.
  gs_layout_0201-stylefname = 'XYZSTYLEZYX'.
*  GS_LAYOUT_0200-CWIDTH_OPT = ABAP_TRUE.
  gs_layout_0201-smalltitle = 'X'.
  gs_layout_0201-grid_title = '조장구성표'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_of_toolbar_grid_0201 .

  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0201
        USING : cl_gui_alv_grid=>mc_fc_excl_all.


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

  CALL METHOD go_grid_0201->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0201
      it_toolbar_excluding = gt_exclude_0201
    CHANGING
      it_outtab            = <gt_main_201>
      it_sort              = gt_sort_0201
      it_fieldcatalog      = gt_fieldcat_0201.

  go_grid_0201->set_ready_for_input( 1 ).

* 인풋이벤트 추가
  CALL METHOD go_grid_0201->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CALL METHOD go_grid_0201->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CHAIN_JOJANG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&---------------------------------------------------------------------*
FORM get_chain_jojang.

  DATA : lv_plnum TYPE plaf-plnum.

  REFRESH gt_2010.

  SELECT b~*
    FROM @gt_seq_routing AS a
    INNER JOIN zgtppt2010 AS b  ON b~gong_cd = a~chart
   WHERE grpnr = @gv_grpnr
    INTO CORRESPONDING FIELDS OF TABLE @gt_2010.

  SORT gt_2010 BY gong_cd ordnr posnr.
  DELETE ADJACENT DUPLICATES FROM gt_2010 COMPARING gong_cd ordnr posnr.

  LOOP AT gt_2010 ASSIGNING FIELD-SYMBOL(<ls_2010>).
    IF <ls_2010>-matnr IS INITIAL.
      CASE <ls_2010>-ordty.
        WHEN 'PRD'.
          SELECT SINGLE plnbez FROM afko
            INTO <ls_2010>-matnr
            WHERE aufnr = <ls_2010>-ordnr.
        WHEN 'PLN'.
          CLEAR lv_plnum.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = <ls_2010>-ordnr
            IMPORTING
              output = lv_plnum.

          SELECT SINGLE matnr FROM plaf
            INTO <ls_2010>-matnr
            WHERE plnum = lv_plnum.
      ENDCASE.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_data_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_data_200 .

  REFRESH gt_main_200.
  DATA : lv_matnr TYPE matnr.

  gt_main_200 = VALUE #( FOR wa_main_disp2 IN gt_main_disp WHERE ( check = abap_true ) ( CORRESPONDING #( wa_main_disp2 ) ) ).

  LOOP AT gt_main_200 ASSIGNING FIELD-SYMBOL(<ls_main_200>).
    zgtpp_cl_common=>get_cha_millca(
      EXPORTING
        iv_vbeln      =  CONV #( <ls_main_200>-ordno )                " 판매 관리 문서 번호
        iv_posnr      = <ls_main_200>-posnr                 " SD 문서의 품목 번호
      IMPORTING
        ev_pack_yn    = <ls_main_200>-pack_yn
        ev_pack_no    = <ls_main_200>-pack_no
    ).

    CLEAR lv_matnr.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input        = <ls_main_200>-pack_no
      IMPORTING
        output       = lv_matnr
      EXCEPTIONS
        length_error = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
    ENDIF.

    SELECT SINGLE mmsta FROM marc
      INTO @DATA(lv_mmsta)
      WHERE matnr = @lv_matnr
        AND werks = @p_werks.

    IF <ls_main_200>-pack_yn = 'CM'.
      <ls_main_200>-pack_yn = '확정'.

      IF lv_mmsta IS NOT INITIAL.
        <ls_main_200>-pack_yn = <ls_main_200>-pack_yn && '(' && lv_mmsta && ')'.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_CHAIN_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_chain_data .

  DATA : lv_so_num(3)  TYPE n.
  DATA : lv_num(2) TYPE n.
  DATA : lv_num2(2) TYPE n.
  DATA : lv_chk_num(2) TYPE n.
  DATA : lv_nextnum(2) TYPE n.
  DATA : lv_index TYPE i.

  DATA : lv_fname01 TYPE fieldname. "오더넘버
  DATA : lv_fname02 TYPE fieldname. " 품목번호
  DATA : lv_fname03 TYPE fieldname. " 오더타입
  DATA : lv_fname04 TYPE fieldname. " 오더체크
  DATA : lv_fname05 TYPE fieldname. " 자재
  DATA : lv_fname06 TYPE fieldname. " 길이

  DATA : lv_chain2 TYPE REF TO data.

  FIELD-SYMBOLS : <lv_ordnr>     TYPE any,
                  <lv_posnr>     TYPE any,
                  <lv_ordty>     TYPE any,
                  <lv_chk_duple> TYPE any,
                  <lv_so_idx>    TYPE any,
                  <lv_chk_stock> TYPE any,
                  <lv_chk_zero>  TYPE any,
                  <lv_matnr>     TYPE any,
                  <lv_leng>      TYPE any.
  FIELD-SYMBOLS : <lv_ordnr2>  TYPE any,
                  <lv_posnr2>  TYPE any,
                  <lv_ordty2>  TYPE any,
                  <lv_so_idx2> TYPE any..
  FIELD-SYMBOLS : <ls_chain> TYPE any.
  FIELD-SYMBOLS : <ls_chain2> TYPE any.

  DATA : lv_seqno(6) TYPE n.

  DEFINE __set_field_name.
    CLEAR : lv_fname01, lv_fname02, lv_fname03.
    lv_fname01 = &1 && '_ORDNR'.
    lv_fname02 = &1 && '_POSNR'.
    lv_fname03 = &1 && '_ORDTY'.
    lv_fname04 = &1 && '_CHK_DUP'.
    lv_fname05 = &1 && '_MATNR'.
    lv_fname06 = &1 && '_LENG'.
  END-OF-DEFINITION.
  DEFINE __assign_field.
    IF <lv_ordnr> IS ASSIGNED. UNASSIGN <lv_ordnr>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_chain> TO <lv_ordnr>.
    IF <lv_posnr> IS ASSIGNED. UNASSIGN <lv_posnr>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_chain> TO <lv_posnr>.
    IF <lv_ordty> IS ASSIGNED. UNASSIGN <lv_ordty>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_chain> TO <lv_ordty>.
    IF <lv_chk_duple> IS ASSIGNED. UNASSIGN <lv_chk_duple>. ENDIF.
    ASSIGN COMPONENT lv_fname04 OF STRUCTURE <ls_chain> TO <lv_chk_duple>.
   IF <lv_matnr> IS ASSIGNED. UNASSIGN <lv_matnr>. ENDIF.
    ASSIGN COMPONENT lv_fname05 OF STRUCTURE <ls_chain> TO <lv_matnr>.
  END-OF-DEFINITION.

  DEFINE __assign_pre_field.
    IF <lv_ordnr2> IS ASSIGNED. UNASSIGN <lv_ordnr2>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_chain> TO <lv_ordnr2>.
    IF <lv_posnr2> IS ASSIGNED. UNASSIGN <lv_posnr2>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_chain> TO <lv_posnr2>.
    IF <lv_ordty2> IS ASSIGNED. UNASSIGN <lv_ordty2>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_chain> TO <lv_ordty2>.
  END-OF-DEFINITION.

  DEFINE __assign_field_chk.
    IF <lv_ordnr2> IS ASSIGNED. UNASSIGN <lv_ordnr2>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_chain2> TO <lv_ordnr2>.
    IF <lv_posnr2> IS ASSIGNED. UNASSIGN <lv_posnr2>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_chain2> TO <lv_posnr2>.
    IF <lv_ordty2> IS ASSIGNED. UNASSIGN <lv_ordty2>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_chain2> TO <lv_ordty2>.
  END-OF-DEFINITION.

  DEFINE __assign_field_for_sort.
    IF <lv_ordnr> IS ASSIGNED. UNASSIGN <lv_ordnr>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_chain> TO <lv_ordnr>.
    IF <lv_posnr> IS ASSIGNED. UNASSIGN <lv_posnr>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_chain> TO <lv_posnr>.
    IF <lv_ordty> IS ASSIGNED. UNASSIGN <lv_ordty>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_chain> TO <lv_ordty>.
    IF <lv_leng> IS ASSIGNED. UNASSIGN <lv_leng>. ENDIF.
    ASSIGN COMPONENT lv_fname06 OF STRUCTURE <ls_chain> TO <lv_leng>.
  END-OF-DEFINITION.


  PERFORM get_chain_jojang.

  IF gv_chk_subpool_dir_full IS NOT INITIAL.
    RETURN.
  ENDIF.

* Chain 테이블로 구성단계 구축(0단계)
  REFRESH <gt_routing>.

  LOOP AT gt_main_200 INTO DATA(ls_main_200).
    CLEAR lv_index.
    lv_index = ls_main_200-infactor + 0. " 공정수 만큼 테이블 구성하여
    IF lv_index NE 0.
      CLEAR lv_so_num.
      DO lv_index TIMES.
        ADD 1 TO lv_so_num.
        APPEND INITIAL LINE TO <gt_routing> ASSIGNING <ls_chain>.
        lv_num = '00'.
        __set_field_name lv_num.
        __assign_field.
        <lv_ordnr> = ls_main_200-ordno.
        <lv_posnr> = ls_main_200-posnr.
        IF <lv_so_idx> IS ASSIGNED. UNASSIGN <lv_so_idx>. ENDIF.
        ASSIGN COMPONENT '00_SO_IDX' OF STRUCTURE <ls_chain> TO <lv_so_idx>.
        IF <lv_so_idx> IS ASSIGNED.
          <lv_so_idx> = lv_so_num.
        ENDIF.


        CASE ls_main_200-gcatg.
          WHEN '판매오더' OR '견적'.
            <lv_ordty> = 'SO'. " 판매오더 기준 추출
        ENDCASE.

        lv_num = gv_line_jojang.
        LOOP AT gt_seq_routing INTO DATA(ls_seq_routing).
          CHECK ls_seq_routing-maabc NE 'B'.

          __set_field_name lv_num.
          __assign_field.
          <lv_ordty> = ls_seq_routing-chart.
          <lv_matnr> = ls_seq_routing-matnr.
          lv_num = lv_num - 1.
        ENDLOOP.

      ENDDO.
    ENDIF.
  ENDLOOP.

*  내부 구성 테이블 순차 구성
  LOOP AT <gt_routing> ASSIGNING <ls_chain>.
    CLEAR lv_num.
    DO.
      lv_num2 = lv_num.
      ADD 1 TO lv_num.

* 이전 공정 오더번호 (이전공정이 아니라 상위/이후 공정아닌가)
      __set_field_name lv_num2.
      __assign_pre_field.

* 현재 공정 오더번호
      __set_field_name lv_num.
      __assign_field.

      IF <lv_ordnr2> IS NOT INITIAL.
        PERFORM get_chain_order USING <lv_ordnr2> <lv_posnr2>
                                CHANGING <lv_ordnr> <lv_posnr> <lv_ordty> <lv_matnr>.
      ENDIF.

      IF lv_num => gv_line_jojang.
        EXIT.
      ENDIF.
    ENDDO.
  ENDLOOP.
*  내부 구성 테이블 chin 미 확정분 추가구성
*  하위공정부터 순서 대로 매핑후 알맞은 라인에 모디
  CREATE DATA lv_chain2 LIKE LINE OF <gt_routing>.
  ASSIGN lv_chain2->* TO <ls_chain2>.

  DO.
    IF line_exists( gt_2010[ use_chk = ' ' ] ).

      LOOP AT gt_2010 ASSIGNING FIELD-SYMBOL(<ls_2010>) WHERE use_chk IS INITIAL.

        CLEAR <ls_chain2>.

        LOOP AT <gt_routing> ASSIGNING <ls_chain>.
          IF <ls_chain2> IS NOT INITIAL.
            EXIT.
          ENDIF.

          IF <ls_2010>-use_chk IS NOT INITIAL.
            EXIT.
          ENDIF.

          lv_num = gv_line_jojang.
          DO.
            lv_num2 = lv_num - 1.
            __set_field_name lv_num2.
            __assign_field.

            READ TABLE gt_2010  ASSIGNING FIELD-SYMBOL(<ls_2010_re>)
                                WITH KEY ordnr = <lv_ordnr>
                                         posnr = <lv_posnr>
                                         gong_cd = <lv_ordty>.
            IF sy-subrc EQ 0.
              IF <ls_2010_re>-ordnr = <ls_2010>-dmord AND
                <ls_2010_re>-posnr = <ls_2010>-dmline AND
                <ls_2010_re>-ordty = <ls_2010>-dmordty.
                " 미매핑된 필드의 상위 구조를 찾았을 경우/
                __set_field_name lv_num.
                __assign_pre_field.

                IF <lv_ordnr2> IS INITIAL. " 하위 필드가 비어있다면 모디
                  <lv_ordnr2> = <ls_2010>-ordnr.
                  <lv_posnr2> = <ls_2010>-posnr.
                  <ls_2010>-use_chk = abap_true.
                ELSE. " 하위 필드가 존재한다면 해당 라인 복사후 전공정 삭제후 들고 있는다.
                  MOVE-CORRESPONDING <ls_chain> TO <ls_chain2>.
                  __assign_field_chk.
                  <lv_ordnr2> = <ls_2010>-ordnr.
                  <lv_posnr2> = <ls_2010>-posnr.

                  lv_chk_num = lv_num  + 1.

                  DO.
                    IF lv_chk_num > gv_line_jojang.
                      EXIT.
                    ENDIF.

                    __set_field_name lv_chk_num.
                    __assign_field_chk.
                    CLEAR : <lv_ordnr2>, <lv_posnr2>.
                    ADD 1 TO lv_chk_num.
                  ENDDO.
                  EXIT.
                ENDIF.
              ENDIF.
            ENDIF.

            IF <ls_2010>-use_chk = abap_true OR lv_num2 = 0.
              EXIT.
            ENDIF.
            lv_num = lv_num - 1.
          ENDDO.
        ENDLOOP.

        IF <ls_chain2> IS NOT INITIAL AND <ls_2010>-use_chk IS INITIAL.
          APPEND <ls_chain2> TO <gt_routing>.
          <ls_2010>-use_chk = abap_true.
        ENDIF.

      ENDLOOP.
    ELSE.
      EXIT.
    ENDIF.
  ENDDO.

*  내부 구성 테이블 순차 구성 한번더
  LOOP AT <gt_routing> ASSIGNING <ls_chain>.
    CLEAR lv_num.
    DO.
      lv_num2 = lv_num.
      ADD 1 TO lv_num.
* 이전 공정 오더번호
      __set_field_name lv_num2.
      __assign_pre_field.
* 현재 공정 오더번호
      __set_field_name lv_num.
      __assign_field.

      IF <lv_ordnr2> IS NOT INITIAL AND <lv_ordnr> IS INITIAL.

        PERFORM get_chain_order USING <lv_ordnr2> <lv_posnr2>
                                CHANGING <lv_ordnr> <lv_posnr> <lv_ordty> <lv_matnr>.

      ENDIF.

      IF lv_num => gv_line_jojang.
        EXIT.
      ENDIF.
    ENDDO.
  ENDLOOP.

  FIELD-SYMBOLS : <lv_seqno> TYPE any.
  DATA : lv_columns TYPE string.
  DATA : lv_sort TYPE char01.
  GET PARAMETER ID 'Z2010' FIELD lv_sort.
  SET PARAMETER ID 'Z2010' FIELD space.

  IF lv_sort IS NOT INITIAL.
* 순번 적용을 위해 오더별 총수량 옮겨놓기
    LOOP AT <gt_routing> ASSIGNING <ls_chain>.
      CLEAR lv_num.
      DO.
        __set_field_name lv_num.
        __assign_field_for_sort.

        PERFORM get_length_of_order USING <lv_ordnr> <lv_posnr> <lv_ordty>
                                    CHANGING <lv_leng>.

        IF lv_num => gv_line_jojang.
          EXIT.
        ENDIF.

        ADD 1 TO lv_num.
      ENDDO.
    ENDLOOP.

    CLEAR lv_columns.
    CLEAR lv_num .
    lv_num = gv_line_jojang.
    __set_field_name lv_num.

    lv_columns = lv_fname06 && ',' && lv_fname01 && ',' && lv_fname02.

    SPLIT lv_columns AT `,` INTO TABLE DATA(lt_column_tab).

    DATA(lt_order) = VALUE abap_sortorder_tab(
                    FOR wa IN lt_column_tab
                   ( name = condense( to_upper( wa ) ) ) ).

    IF lv_sort NE 'U'.
      READ TABLE lt_order ASSIGNING FIELD-SYMBOL(<ls_order>) INDEX 1.
      <ls_order>-descending = abap_true.
    ENDIF.

    TRY.
        SORT <gt_routing> BY (lt_order).
      CATCH cx_sy_dyn_table_ill_comp_val.

    ENDTRY.

  ELSE.
* 소트후 순번적용(최종 라우팅 오더, 품목번호 기준)
    CLEAR lv_columns.
    CLEAR lv_num .
    lv_num = gv_line_jojang.
    DO.
      __set_field_name lv_num.
      IF lv_columns IS INITIAL.
        lv_columns = lv_fname01 && ',' && lv_fname02.
      ELSE.
        lv_columns = lv_columns && ',' && lv_fname01 && ',' && lv_fname02.
      ENDIF.

      lv_num = lv_num - 1.
      IF lv_num = 0.
        EXIT.
      ENDIF.

    ENDDO.
    SPLIT lv_columns AT `,` INTO TABLE lt_column_tab.
    lt_order = VALUE abap_sortorder_tab(
                    FOR wa IN lt_column_tab
                   ( name = condense( to_upper( wa ) ) ) ).

    TRY.
        SORT <gt_routing> BY (lt_order).
      CATCH cx_sy_dyn_table_ill_comp_val.

    ENDTRY.

    lv_seqno = 10.
    lv_num = gv_line_jojang.
    LOOP AT <gt_routing> ASSIGNING <ls_chain>.

      CLEAR lv_index.
      lv_index = sy-tabix + 1.

      __set_field_name lv_num.
      __assign_field.
      IF <lv_seqno> IS ASSIGNED. UNASSIGN <lv_seqno>. ENDIF.
      ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <ls_chain> TO <lv_seqno>.

      IF gv_chk_she IS NOT INITIAL.
        <lv_seqno> = 10.
        CONTINUE.
      ENDIF.


      CLEAR <ls_chain2>.
      READ TABLE <gt_routing> INTO <ls_chain2> INDEX lv_index.
      IF sy-subrc EQ 0.
        __assign_field_chk.
        IF <lv_ordnr> = <lv_ordnr2> AND <lv_posnr> = <lv_posnr2>.
          <lv_seqno> = lv_seqno.
        ELSE.
          <lv_seqno> = lv_seqno.
          ADD 10 TO lv_seqno.
        ENDIF.
      ELSE.
        <lv_seqno> = lv_seqno.
      ENDIF.
    ENDLOOP.

* 쉬스공정 이 연합뒤에 올시 최초 공정기준으로 소트
    IF gv_chk_she IS NOT INITIAL.
      CLEAR lv_num .
      CLEAR lv_columns.
      lv_num = 1.

      DO.
        __set_field_name lv_num.
        IF lv_columns IS INITIAL.
          lv_columns = lv_fname01 && ',' && lv_fname02.
        ELSE.
          lv_columns = lv_columns && ',' && lv_fname01 && ',' && lv_fname02.
        ENDIF.

        IF lv_num = gv_line_jojang.
          EXIT.
        ENDIF.
        ADD 1 TO lv_num.
      ENDDO.

      SPLIT lv_columns AT `,` INTO TABLE lt_column_tab.
      lt_order = VALUE abap_sortorder_tab(
                      FOR wa IN lt_column_tab
                     ( name = condense( to_upper( wa ) ) ) ).

      TRY.
          SORT <gt_routing> BY (lt_order).
        CATCH cx_sy_dyn_table_ill_comp_val.

      ENDTRY.
    ENDIF.

  ENDIF.

*   같은 순번안에 중복여부 확인후 오더 동일시 중복 체크
  CLEAR lv_seqno.
  LOOP AT <gt_routing> ASSIGNING <ls_chain>.
    IF <lv_seqno> IS ASSIGNED. UNASSIGN <lv_seqno>. ENDIF.
    ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <ls_chain> TO <lv_seqno>.
    IF lv_seqno = <lv_seqno>.
      CLEAR lv_num.
      DO.
        __set_field_name lv_num.
        __assign_field.
        __assign_field_chk.

        IF <lv_ordnr> = <lv_ordnr2> AND <lv_posnr> = <lv_posnr2>.
          IF <lv_ordty> EQ 'SO'.
            IF <lv_so_idx> IS ASSIGNED. UNASSIGN <lv_so_idx>. ENDIF.
            ASSIGN COMPONENT '00_SO_IDX' OF STRUCTURE <ls_chain> TO <lv_so_idx>.
            IF <lv_so_idx2> IS ASSIGNED. UNASSIGN <lv_so_idx2>. ENDIF.
            ASSIGN COMPONENT '00_SO_IDX' OF STRUCTURE <ls_chain2> TO <lv_so_idx2>.

            IF <lv_so_idx> = <lv_so_idx2>.
              <lv_chk_duple> = abap_true.
            ELSE.
              <lv_ordnr2> = <lv_ordnr>.
              <lv_posnr2> = <lv_posnr>.
              <lv_so_idx2> = <lv_so_idx>.
            ENDIF.

          ELSE.
            <lv_chk_duple> = abap_true.
          ENDIF.
        ELSE.
          IF <lv_ordty> EQ 'SO'.
            IF <lv_so_idx> IS ASSIGNED. UNASSIGN <lv_so_idx>. ENDIF.
            ASSIGN COMPONENT '00_SO_IDX' OF STRUCTURE <ls_chain> TO <lv_so_idx>.
            IF <lv_so_idx2> IS ASSIGNED. UNASSIGN <lv_so_idx2>. ENDIF.
            ASSIGN COMPONENT '00_SO_IDX' OF STRUCTURE <ls_chain2> TO <lv_so_idx2>.
            <lv_ordnr2> = <lv_ordnr>.
            <lv_posnr2> = <lv_posnr>.
            <lv_so_idx2> = <lv_so_idx>.
          ELSE.
            <lv_ordnr2> = <lv_ordnr>.
            <lv_posnr2> = <lv_posnr>.
          ENDIF.
        ENDIF.

        IF lv_num = gv_line_jojang.
          EXIT.
        ENDIF.
        ADD 1 TO lv_num.
      ENDDO.
    ELSE.
      lv_seqno = <lv_seqno>.
      CLEAR <ls_chain2>.
      MOVE-CORRESPONDING <ls_chain> TO <ls_chain2>.
    ENDIF.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_ROUTING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_routing .

  DATA : lv_col_no TYPE i.
  DEFINE __add_col_no.
    ADD 10 TO lv_col_no.
    <ls_fcat>-col_pos = lv_col_no.
  END-OF-DEFINITION.
  DATA : lt_fcat TYPE lvc_t_fcat.
  DATA : lv_num(2) TYPE n.
  DATA : lv_fieldname TYPE fieldname.

  CLEAR : lv_num, lv_col_no.

*  순번
  APPEND INITIAL LINE TO lt_fcat ASSIGNING FIELD-SYMBOL(<ls_fcat>).
  <ls_fcat>-fieldname = 'SEQNO'.
  __add_col_no.
  <ls_fcat>-datatype = 'NUMC'.
  <ls_fcat>-dd_outlen = '6'.


  DO .
*   order
    CLEAR lv_fieldname.
    APPEND INITIAL LINE TO lt_fcat ASSIGNING <ls_fcat>.
    lv_fieldname = lv_num && '_ORDNR'.
    <ls_fcat>-fieldname = lv_fieldname.
    __add_col_no.
    <ls_fcat>-datatype = 'CHAR'.
    <ls_fcat>-dd_outlen = '12'.

*   POSNR
    CLEAR lv_fieldname.
    APPEND INITIAL LINE TO lt_fcat ASSIGNING <ls_fcat>.
    lv_fieldname = lv_num && '_POSNR'.
    <ls_fcat>-fieldname = lv_fieldname.
    __add_col_no.
    <ls_fcat>-datatype = 'NUMC'.
    <ls_fcat>-dd_outlen = '6'.

*   오더타입
    CLEAR lv_fieldname.
    APPEND INITIAL LINE TO lt_fcat ASSIGNING <ls_fcat>.
    lv_fieldname = lv_num && '_ORDTY'.
    <ls_fcat>-fieldname = lv_fieldname.
    __add_col_no.
    <ls_fcat>-datatype = 'CHAR'.
    <ls_fcat>-dd_outlen = '5'.

*   오더타입
    CLEAR lv_fieldname.
    APPEND INITIAL LINE TO lt_fcat ASSIGNING <ls_fcat>.
    lv_fieldname = lv_num && '_MATNR'.
    <ls_fcat>-fieldname = lv_fieldname.
    __add_col_no.
    <ls_fcat>-datatype = 'CHAR'.
    <ls_fcat>-dd_outlen = '40'.

    CLEAR lv_fieldname.
    APPEND INITIAL LINE TO lt_fcat ASSIGNING <ls_fcat>.
    lv_fieldname = lv_num && '_CHK_DUP'.
    <ls_fcat>-fieldname = lv_fieldname.
    __add_col_no.
    <ls_fcat>-datatype = 'CHAR'.
    <ls_fcat>-dd_outlen = '1'.

    CLEAR lv_fieldname.
    APPEND INITIAL LINE TO lt_fcat ASSIGNING <ls_fcat>.
    lv_fieldname = lv_num && '_STOCK'. " 재고
    <ls_fcat>-fieldname = lv_fieldname.
    __add_col_no.
    <ls_fcat>-datatype = 'CHAR'.
    <ls_fcat>-dd_outlen = '1'.

    CLEAR lv_fieldname.
    APPEND INITIAL LINE TO lt_fcat ASSIGNING <ls_fcat>.
    lv_fieldname = lv_num && '_ZERO'.  " 재고 이후 공정으로 입고
    <ls_fcat>-fieldname = lv_fieldname.
    __add_col_no.
    <ls_fcat>-datatype = 'CHAR'.
    <ls_fcat>-dd_outlen = '1'.

    CLEAR lv_fieldname.
    APPEND INITIAL LINE TO lt_fcat ASSIGNING <ls_fcat>.
    lv_fieldname = lv_num && '_LENG'. " 조장길이
    <ls_fcat>-fieldname = lv_fieldname.
    __add_col_no.
    <ls_fcat>-datatype = 'INT4'.
    <ls_fcat>-dd_outlen = '11'.

    IF lv_num = '00'.
      CLEAR lv_fieldname.
      APPEND INITIAL LINE TO lt_fcat ASSIGNING <ls_fcat>.
      lv_fieldname = lv_num && '_SO_IDX'.  " 재고 이후 공정으로 입고
      <ls_fcat>-fieldname = lv_fieldname.
      __add_col_no.
      <ls_fcat>-datatype = 'NUMC'.
      <ls_fcat>-dd_outlen = '3'.
    ENDIF.

    ADD 1 TO lv_num.
    IF lv_num > gv_line_jojang.
      EXIT.
    ENDIF.

  ENDDO.

  FREE gt_routing.

  cl_alv_table_create=>create_dynamic_table(
    EXPORTING
*      I_STYLE_TABLE       = ABAP_TRUE
      it_fieldcatalog           = lt_fcat                " Field Catalog
    IMPORTING
      ep_table                  = gt_routing                 " Pointer to Dynamic Data Table
    EXCEPTIONS
      generate_subpool_dir_full = 1                " At Most 36 Subroutine Pools Can Be Generated Temporarily
      OTHERS                    = 2
  ).
  IF sy-subrc <> 0.
    MESSAGE s005 DISPLAY LIKE 'E' WITH 'At Most 36 Subroutine Pools' 'Can Be Generated Temporarily'.
    gv_chk_subpool_dir_full = abap_true.
    RETURN.
  ENDIF.

  ASSIGN gt_routing->* TO <gt_routing>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_ROUTING_COMMENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LV_ORDNR>
*&      --> <LV_POSNR>
*&      --> <LV_ORDTY>
*&      <-- <LV_VALUE01>
*&      <-- <LV_VALUE02>
*&      <-- LV_CHK_JEGO
*&---------------------------------------------------------------------*
FORM make_routing_comment USING     pv_ordnr   TYPE zgteordnr
                                    pv_posnr   TYPE posnr_va
                                    pv_ordty   TYPE zgteordty
                          CHANGING  pv_value01
                                    pv_value02
                                    pv_chk_jego
                                    pv_chk_zero.

  DATA : lv_string TYPE string.
  DATA : lv_value TYPE c LENGTH 30.
  DATA : lv_value2 TYPE p LENGTH 13 DECIMALS 2.
  DATA : lv_value3 TYPE i.
  DATA : lv_plnum TYPE plaf-plnum.
  DATA : lv_aufnr TYPE aufk-aufnr.
  DATA : lt_tj02t LIKE tj02t OCCURS 0 WITH HEADER LINE.
  DATA : lv_stcd TYPE zordstcd.
  DATA : lv_objnr TYPE jest-objnr.
  DATA : lv_user_line TYPE bsvx-sttxt.
  DATA : lt_charg TYPE RANGE OF mseg-charg .


  READ TABLE gt_2010  ASSIGNING FIELD-SYMBOL(<ls_2010>)
                      WITH KEY  ordnr = pv_ordnr
                                posnr = pv_posnr
                                gong_cd = pv_ordty.
  IF sy-subrc EQ 0.
    CASE     <ls_2010>-ordty.
      WHEN 'PLN'. "계획오더
*      1번 라인
        CLEAR lv_plnum.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = pv_ordnr
          IMPORTING
            output = lv_plnum.
        SELECT SINGLE auffx FROM plaf INTO @DATA(lv_auffx) WHERE plnum = @lv_plnum.

        pv_value01 = 'Pln오더'.
        IF lv_auffx = 'X'.
          pv_value01 = pv_value01 && '(F)'.
        ELSE.
          pv_value01 = pv_value01 && '()'.
        ENDIF.
        CLEAR lv_string.
        lv_string = pv_ordnr.
        CONCATENATE pv_value01 lv_string INTO pv_value01 SEPARATED BY space.

      WHEN 'PRD'. " 생산오더
*    Prd(생산오더): 오더 상태 조회 "CRTD" 상태 "(C)", "REL" 상태 "(R)", user status "PAYO" Payoff 장착 상태 "(P/O)"
        pv_value01 = 'Prd오더'.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = pv_ordnr
          IMPORTING
            output = lv_aufnr.

*    상태값 조회
        CALL FUNCTION 'Z_PP_RETURN_ORDER_STATUS'
          EXPORTING
            im_aufnr        = lv_aufnr
          IMPORTING
            ex_ostcd        = lv_stcd
          TABLES
            et_sttxt        = lt_tj02t
          EXCEPTIONS
            no_selection    = 1
            not_found_objnr = 2
            OTHERS          = 3.

        <ls_2010>-status = lv_stcd.

        CASE lv_stcd.
          WHEN 'Z'.
            pv_value01 = pv_value01 && '(E)'.
            <ls_2010>-status = 'E'.
          WHEN 'A'.
            pv_value01 = pv_value01 && '(C)'.
            <ls_2010>-status = 'C'.
          WHEN OTHERS.
            pv_value01 = pv_value01 && '(R)'.
            <ls_2010>-status = 'R'.

*           오더가 작업 완료 상태일때 재고조회
            CASE lv_stcd.
              WHEN 'D' OR 'G' OR 'F' OR 'C'.
                <ls_2010>-chk_prd = abap_true.
            ENDCASE.

            DATA : BEGIN OF ls_sum_mseg,
                     aufnr LIKE mseg-aufnr,
                     aufps LIKE mseg-aufps,
                     menge LIKE mseg-menge,
                   END OF ls_sum_mseg.
            DATA : lt_sum_mseg LIKE TABLE OF ls_sum_mseg.

            DATA : lv_matnr TYPE matnr.

            READ TABLE gt_seq_routing INTO DATA(ls_seq_routing)
                                      WITH KEY  chart = pv_ordty
                                                matnr = <ls_2010>-matnr.
            IF <ls_2010>-real_matnr IS NOT INITIAL.
              lv_matnr = <ls_2010>-real_matnr.
            ELSE.
              lv_matnr = ls_seq_routing-matnr.
            ENDIF.

            SELECT aufnr, aufps, bwart, charg, menge
               FROM mseg
              WHERE matnr = @lv_matnr
                  AND bwart IN ('101', '102')
                  AND aufnr = @lv_aufnr
                  AND aufps = @pv_posnr+2(4)
                  AND charg NE 'GR_ZERO1'
                 INTO TABLE @DATA(lt_mseg).

            IF sy-subrc EQ 0.

              LOOP AT lt_mseg INTO DATA(ls_mseg).
                CLEAR ls_sum_mseg.
                ls_sum_mseg-aufnr = ls_mseg-aufnr.
                ls_sum_mseg-aufps = ls_mseg-aufps.
                CASE ls_mseg-bwart.
                  WHEN '101'.
                    APPEND INITIAL LINE TO lt_charg ASSIGNING FIELD-SYMBOL(<ls_charg>).
                    <ls_charg>-sign = 'I'.
                    <ls_charg>-option = 'EQ'.
                    <ls_charg>-low = ls_mseg-charg.

                    ls_sum_mseg-menge = ls_mseg-menge .
                  WHEN '102'.
                    ls_sum_mseg-menge = ls_mseg-menge * -1.
                ENDCASE.
                COLLECT ls_sum_mseg INTO lt_sum_mseg.
              ENDLOOP.

              SORT lt_charg BY low.
              DELETE ADJACENT DUPLICATES FROM lt_charg COMPARING low.

              SELECT SINGLE aufnr, posnr, psmng, psamg, kdauf, kdpos, lgort
                FROM  afpo
               WHERE aufnr = @lv_aufnr
                  AND posnr = @pv_posnr
                  AND charg NE 'GR_ZERO1'
                 INTO @DATA(ls_afpo).
* 오더의 자재입고 완료 여부
              READ TABLE lt_sum_mseg INTO ls_sum_mseg INDEX 1. " 한건만 존재
              ls_afpo-psmng  = ls_afpo-psmng  + ls_afpo-psamg.
              "입고된 자재수량과 생산오더의 총수량이 같으면 재고 완료 처리.
              IF ls_sum_mseg-menge > 0.
                pv_chk_jego = abap_true.
              ENDIF.
* 자재가 이후공정으로 옮겨갔는지 확인.
              IF ls_afpo-kdauf IS NOT INITIAL. " 완제품 수량
                SELECT SINGLE SUM( kalab ) AS kalab, SUM( kains ) AS kains, SUM( kaspe ) AS kaspe
                  FROM mska
                  WHERE matnr = @lv_matnr
                     AND werks = @p_werks
*                     AND LGORT = @LS_AFPO-LGORT
                     AND charg IN @lt_charg
                     AND vbeln = @ls_afpo-kdauf
                     AND posnr = @ls_afpo-kdpos
                  GROUP BY matnr, werks
                   INTO (@DATA(lv_kalab), @DATA(lv_kains), @DATA(lv_kaspe)).
                IF lv_kalab = 0 AND lv_kains = 0 AND lv_kaspe = 0.
                  pv_chk_zero = abap_true.
                ENDIF.

              ELSE. " 반제품 수량체크
                SELECT SINGLE SUM( clabs ) AS clabs, SUM( cinsm ) AS cinsm, SUM( cspem ) AS cspem
                  FROM mchb
                  WHERE matnr = @lv_matnr
                     AND werks = @p_werks
                     AND lgort = @ls_afpo-lgort
                     AND charg IN @lt_charg
                   GROUP BY matnr, werks
                   INTO (@DATA(lv_clabs),@DATA(lv_cinsm), @DATA(lv_cspem)).
                IF lv_clabs = 0 AND lv_cinsm = 0 AND lv_cspem = 0.
                  pv_chk_zero = abap_true.
                ENDIF.

              ENDIF.

            ENDIF.
        ENDCASE.

*        ENDCASE.
*    유저스테이터스 조회
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_aufnr
          IMPORTING
            output = lv_aufnr.

        lv_objnr = 'OR' && lv_aufnr.
        CALL FUNCTION 'STATUS_TEXT_EDIT'
          EXPORTING
            flg_user_stat    = 'X'
            objnr            = lv_objnr
            only_active      = 'X'
            spras            = sy-langu
            bypass_buffer    = 'X'
          IMPORTING
            user_line        = lv_user_line
          EXCEPTIONS
            object_not_found = 1
            OTHERS           = 2.

        FIND ALL OCCURRENCES OF 'PAYO' IN lv_user_line MATCH COUNT FINAL(lv_line).
        IF lv_line > 0.
          IF pv_chk_zero IS INITIAL AND pv_chk_jego IS INITIAL.
            pv_value01 = pv_value01 && '(P/O)'.
          ENDIF.
          <ls_2010>-chk_prd = abap_true.
        ENDIF.

        CLEAR lv_string.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = pv_posnr
          IMPORTING
            output = lv_string.

        lv_string = pv_ordnr && '/' && lv_string.
        CONCATENATE pv_value01 lv_string INTO pv_value01 SEPARATED BY space.

    ENDCASE.

*    2번 라인
    IF pv_chk_jego IS INITIAL.
      CLEAR lv_value.
      IF <ls_2010>-dmordty = 'SO'.
        lv_value = <ls_2010>-inlength.
        CONDENSE lv_value.
        SPLIT lv_value AT '.' INTO DATA(lv_num) DATA(lv_dot).
        IF lv_dot > 0.
          lv_value = <ls_2010>-inlength.
        ELSE.
          lv_value3 = <ls_2010>-inlength.
          lv_value = lv_value3.
        ENDIF.
      ELSE.
        lv_value3 = <ls_2010>-inlength.
        lv_value = lv_value3.
      ENDIF.
      CONDENSE lv_value.
      CONCATENATE '(' lv_value INTO pv_value02.
      IF <ls_2010>-qlength = 0 AND <ls_2010>-clength = 0 AND <ls_2010>-adlength = 0.
      ELSE.
* 검사여장,
        lv_value3 = <ls_2010>-qlength.
        lv_value = lv_value3.
        CONDENSE lv_value.
        CONCATENATE pv_value02 '+' lv_value '+' INTO pv_value02.
* 연결여장
        lv_value3 = <ls_2010>-clength.
        lv_value = lv_value3.
        CONDENSE lv_value.
        CONCATENATE pv_value02  lv_value '+' INTO pv_value02.
* 추가여장
        lv_value3 = <ls_2010>-adlength.
        lv_value = lv_value3.
        CONDENSE lv_value.
        CONCATENATE pv_value02  lv_value  INTO pv_value02.
      ENDIF.
* 조장수
      lv_value3 = <ls_2010>-infactor.
      lv_value = lv_value3.
      CONDENSE lv_value.

      CONCATENATE pv_value02 ')X' lv_value INTO pv_value02.

    ELSE.
      <ls_2010>-check_jego = abap_true.
      IF pv_chk_zero = abap_true.
        lv_value2 = 0.
      ELSE.
        IF ls_afpo-kdauf IS NOT INITIAL. " 완제품 수량
          IF lv_kains > 0.
            <ls_2010>-check_jego = 'Q'.
            lv_value2 = lv_kains.
          ELSEIF lv_kaspe > 0.
            <ls_2010>-check_jego = 'B'.
            lv_value2 = lv_kaspe.
          ELSE.
            lv_value2 = lv_kalab.
          ENDIF.
        ELSE.
          IF lv_cinsm > 0.
            <ls_2010>-check_jego = 'Q'.
            lv_value2 = lv_cinsm.
          ELSEIF lv_cspem > 0.
            <ls_2010>-check_jego = 'B'.
            lv_value2 = lv_cspem.
          ELSE.
            lv_value2 = lv_clabs.
          ENDIF.
        ENDIF.
      ENDIF.
      lv_value = lv_value2.
      CONDENSE lv_value.
*  재고수량,
      IF <ls_2010>-check_jego = 'Q'.
        CONCATENATE '( QI Stock' lv_value ')' INTO pv_value02 SEPARATED BY space.
      ELSEIF <ls_2010>-check_jego = 'B'.
        CONCATENATE '( Block Stock' lv_value ')' INTO pv_value02 SEPARATED BY space.
      ELSE.
        CONCATENATE '( Stock' lv_value ')' INTO pv_value02 SEPARATED BY space.
      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_sorttab_grid_0201 .

  REFRESH gt_sort_0201.

  PERFORM set_sort_tab TABLES gt_sort_0201
                            USING : 1 'SEQNO'  'X' '' '',
                                       2 'LINE_SEQ'  'X' '' '',
                                       3 'LINE'  'X' '' ''.



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
*& Form GET_CHAIN_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LV_ORDNR2>
*&      --> <LV_POSNR2>
*&      --> <LV_ORDTY2>
*&      <-- <LV_ORDNR>
*&      <-- <LV_POSNR>
*&      <-- <LV_ORDTY>
*&---------------------------------------------------------------------*
FORM get_chain_order  USING    pv_ordnr2
                               pv_posnr2
                      CHANGING pv_ordnr
                               pv_posnr
                               pv_ordty
                               pv_matnr.

  READ TABLE gt_2010  ASSIGNING FIELD-SYMBOL(<ls_2010>)
                      WITH KEY  dmord = pv_ordnr2
                                dmline = pv_posnr2
                                use_chk = ' '.
  IF sy-subrc EQ 0.
    pv_ordnr = <ls_2010>-ordnr.
    pv_posnr = <ls_2010>-posnr.
    pv_ordty = <ls_2010>-gong_cd.
    pv_matnr = <ls_2010>-matnr.
    <ls_2010>-use_chk = abap_true.
  ELSE.
    READ TABLE gt_2010 ASSIGNING <ls_2010> WITH KEY ordnr = pv_ordnr2
                                                    posnr = pv_posnr2.
    IF sy-subrc EQ 0 AND <ls_2010>-reord IS NOT INITIAL.
      READ TABLE gt_2010 ASSIGNING FIELD-SYMBOL(<ls_2010_re>)
                          WITH KEY  ordnr = <ls_2010>-reord
                                    posnr = <ls_2010>-reline.
      IF sy-subrc EQ 0.
        pv_ordnr = <ls_2010_re>-ordnr.
        pv_posnr = <ls_2010_re>-posnr.
        pv_ordty = <ls_2010_re>-gong_cd.
        pv_matnr = <ls_2010_re>-matnr.
        <ls_2010_re>-use_chk = abap_true.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_create_routing
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM proc_create_routing .

  DATA : lv_chkerr.
  DATA : lv_num(2) TYPE n.
  DATA : lv_num2(2) TYPE n.

  DATA : lv_fname01 TYPE fieldname. "오더넘버
  DATA : lv_fname02 TYPE fieldname. " 품목번호
  DATA : lv_fname03 TYPE fieldname. " 오더타입
  DATA : lv_fname04 TYPE fieldname. " 재고 체크
  DATA : lv_fname05 TYPE fieldname. " 자재코드
  DATA : lo_jojang TYPE REF TO zgtpp_cl_routing.

  FIELD-SYMBOLS : <lv_ordnr> TYPE any,
                  <lv_posnr> TYPE any,
                  <lv_ordty> TYPE any,
                  <lv_matnr> TYPE any.

  FIELD-SYMBOLS : <lv_ordnr2> TYPE any,
                  <lv_posnr2> TYPE any,
                  <lv_ordty2> TYPE any.
  FIELD-SYMBOLS <lv_stock2> TYPE any.
* 계획오더 생성을 위한 정보를 받기위한 변수들
*&---------------------------------------------------------------------*
  DATA : lv_ordnr   TYPE zgteordno, " 선행 오더번호
         lv_posnr   TYPE posnr_va,       " 선행 오더품목
         lv_ordty   TYPE zgteordty,    "  선행 오더 타입
         lv_gong_cd TYPE zegong_cd,    "  현재 진행 공정코드
         lv_matnr   TYPE matnr.            " 생성할 자재코드

  DATA : lv_result_ordnr TYPE zgteordno, "
         lv_result_posnr TYPE posnr_va,
         lv_result_ordty TYPE zgteordty.
  DATA : lv_result  TYPE char01,
         lv_message TYPE char100.
  DATA : lv_idx TYPE i.
  DATA : lv_chk_she TYPE char01.
  DATA : lt_plnum TYPE mrpds_plono.
  DATA : lt_chk_plnum TYPE mrpds_plono.
  DATA : lv_chk_finish.

*&---------------------------------------------------------------------*
  DEFINE   __set_field_name.
    CLEAR : lv_fname01, lv_fname02, lv_fname03.
    lv_fname01 = &1 && '_ORDNR'.
    lv_fname02 = &1 && '_POSNR'.
    lv_fname03 = &1 && '_ORDTY'.
    lv_fname04 = &1 && '_STOCK'.
    lv_fname05 = &1 && '_MATNR'.
  END-OF-DEFINITION.
  DEFINE __assign_field.
    IF <lv_ordnr> IS ASSIGNED. UNASSIGN <lv_ordnr>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_routing> TO <lv_ordnr>.
    IF <lv_posnr> IS ASSIGNED. UNASSIGN <lv_posnr>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_routing> TO <lv_posnr>.
    IF <lv_ordty> IS ASSIGNED. UNASSIGN <lv_ordty>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_routing> TO <lv_ordty>.
    IF <lv_matnr> IS ASSIGNED. UNASSIGN <lv_matnr>. ENDIF.
    ASSIGN COMPONENT lv_fname05 OF STRUCTURE <ls_routing> TO <lv_matnr>.
  END-OF-DEFINITION.

  DEFINE __assign_pre_field.
    IF <lv_ordnr2> IS ASSIGNED. UNASSIGN <lv_ordnr2>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_routing> TO <lv_ordnr2>.
    IF <lv_posnr2> IS ASSIGNED. UNASSIGN <lv_posnr2>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_routing> TO <lv_posnr2>.
    IF <lv_ordty2> IS ASSIGNED. UNASSIGN <lv_ordty2>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_routing> TO <lv_ordty2>.
    IF <lv_stock2> IS ASSIGNED. UNASSIGN <lv_stock2>. ENDIF.
    ASSIGN COMPONENT lv_fname04 OF STRUCTURE <ls_routing> TO <lv_stock2>.
  END-OF-DEFINITION.

  DATA : lv_percent TYPE i.
  DATA : lv_sum_num TYPE i.

  IF gt_2010[] IS NOT INITIAL.
    PERFORM proc_check_before_routing CHANGING lv_chkerr.
    IF lv_chkerr IS NOT INITIAL.
      RETURN.
    ENDIF.
  ENDIF.

  CREATE OBJECT lo_jojang
    EXPORTING
      it_seq_routing = gt_seq_routing
      iv_werks       = p_werks
      iv_grpnr       = gv_grpnr.

  lv_percent = 10.
  lo_jojang->progress_indicator( iv_percent = lv_percent  iv_text = '처리중..' ).

  LOOP AT <gt_routing> ASSIGNING FIELD-SYMBOL(<ls_routing>).
    CLEAR lv_num.
    CLEAR : lv_result_ordnr, lv_result_posnr, lv_result_ordty, lv_chk_she, lv_chk_finish.
    REFRESH lt_chk_plnum.
    DO. " 조정구성표 대상 오더 기준부터 작업 순서상 빈 오더 찾는다.

      IF lv_num >= gv_line_jojang.
        EXIT.
      ENDIF.

      IF lv_chk_finish = abap_true.
        EXIT.
      ENDIF.

      CLEAR : lv_ordnr, lv_posnr, lv_gong_cd, lv_ordty, lv_matnr.
      lv_num2 = lv_num + 1.

      __set_field_name lv_num2.
      __assign_field.
      IF <lv_ordnr> IS INITIAL. " 적용된 오더가 없다면 계획 오더 생성.
        __set_field_name lv_num. " 선행 필드 값 조회후 해당정보 추출
        __assign_pre_field.

        CASE <lv_ordty2>. " 선행 공정코드 확인
          WHEN 'SO'. "선행 공정 오더타입 조회
            lv_ordnr  = <lv_ordnr2>.
            lv_posnr  = <lv_posnr2>.
            lv_gong_cd = <lv_ordty>.
            lv_ordty = 'SO'.
            lv_matnr = <lv_matnr>.

          WHEN OTHERS.

            IF <lv_ordnr2> IS NOT INITIAL.
              IF <lv_stock2> IS NOT INITIAL. " 재고 완료된 공정은 계획오더 생산불가 다음 공정으로
                lv_num = lv_num2.
                EXIT.
              ENDIF.
              lv_ordnr  = <lv_ordnr2>.
              lv_posnr  = <lv_posnr2>.
              lv_gong_cd = <lv_ordty>.
              lv_matnr = <lv_matnr>.

              READ TABLE gt_2010 INTO DATA(ls_2010) WITH KEY ordnr = lv_ordnr
                                                             posnr = lv_posnr
                                                             gong_cd = <lv_ordty2>.
              IF sy-subrc EQ 0.
*               이후공정 조회시 오더 생성이력 있는 오더는 계획오더 생성 없음
                READ TABLE lo_jojang->mt_2020_save TRANSPORTING NO FIELDS  WITH KEY ordnr = lv_ordnr
                                                                                    posnr = lv_posnr
                                                                                    gong_cd = <lv_ordty2>.
                IF sy-subrc EQ 0.
                  EXIT.
                ENDIF.

                lv_ordty  = ls_2010-ordty.
              ENDIF.

            ELSE.
              READ TABLE lo_jojang->mt_2020 INTO DATA(ls_2010_t) WITH KEY ordnr = lv_result_ordnr
                                                                          posnr = lv_result_posnr
                                                                          gong_cd = <lv_ordty2>.
              lv_ordnr  = lv_result_ordnr.
              lv_posnr  = lv_result_posnr.
              lv_gong_cd = <lv_ordty>.
              lv_ordty  = ls_2010_t-ordty.
              lv_matnr = <lv_matnr>.
            ENDIF.
        ENDCASE.

*          계획 오더 생성
        CLEAR : lv_result, lv_message.

        IF lv_chk_she IS NOT INITIAL.
          REFRESH lt_plnum.
          LOOP AT lt_chk_plnum INTO DATA(ls_plnum).

            lv_ordnr = ls_plnum.

            lo_jojang->proc_make_plan_order(
              EXPORTING
                iv_order   =  lv_ordnr                 " 오더번호
                iv_posnr   =  lv_posnr                " 판매 문서 항목
                iv_ordty   =  lv_ordty                " 오더유형
                iv_gong_cd =  lv_gong_cd                " 공정코드
                iv_matnr = lv_matnr
              IMPORTING
                ev_result  =   lv_result               " 길이 1의 문자 필드
                ev_message =   lv_message               " 문자 100
                ev_order   = lv_result_ordnr                 " 오더번호
                ev_posnr   = lv_result_posnr                 " 판매 문서 항목
                ev_ordty   = lv_result_ordty                 " 오더유형
            ).

            IF lv_result = 'E'.
              EXIT.
            ELSE.
              APPEND lv_result_ordnr TO lt_plnum.
            ENDIF.
          ENDLOOP.

          REFRESH lt_chk_plnum.
          lt_chk_plnum = lt_plnum.

        ELSE.
          lo_jojang->proc_make_plan_order(
            EXPORTING
              iv_order    = lv_ordnr                " 오더번호
              iv_posnr    = lv_posnr                " 판매 문서 항목
              iv_ordty    = lv_ordty                " 오더유형
              iv_gong_cd  = lv_gong_cd              " 공정코드
              iv_matnr    = lv_matnr
            IMPORTING
              ev_result   = lv_result               " 길이 1의 문자 필드
              ev_message  = lv_message              " 문자 100
              ev_order    = lv_result_ordnr         " 오더번호
              ev_posnr    = lv_result_posnr         " 판매 문서 항목
              ev_ordty    = lv_result_ordty         " 오더유형
              ev_chk_she  = lv_chk_she
              et_plnum    = lt_chk_plnum
          ).
        ENDIF.

        IF lv_result = 'F'.
          lv_chk_finish = abap_true.
        ENDIF.

        IF lv_percent > 90.
          lv_percent = 90.
        ELSE.
          ADD 2 TO lv_percent.
        ENDIF.
        lo_jojang->progress_indicator( iv_percent = lv_percent  iv_text = '처리중..' ).
        IF lv_result = 'E'.
          EXIT.
        ENDIF.
      ENDIF.

      lv_num = lv_num2.

    ENDDO.
    IF lv_result = 'E'.
      EXIT.
    ENDIF.
  ENDLOOP.

  lo_jojang->progress_indicator( iv_percent = '100'  iv_text = '완료' ).

  IF lv_result = 'E'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH lv_message.
  ELSE.
    DATA : lv_index(20) TYPE c.

    lo_jojang->confirm( ).
*  변경정보 MES전송
    zgtpp_cl_routing=>send_chg_mes(
      iv_werks = p_werks           " 플랜트
      iv_spgcd = p_spgcd          " SPG 코드
      iv_grpnr = gv_grpnr ).    " 조장 구성표 번호

    lv_index = lines( lo_jojang->mt_2020 ).
    CONDENSE lv_index.
    CLEAR lv_message.
    IF lv_index NE 0.
      CONCATENATE gv_grpnr '계획오더' lv_index '건 생성하였습니다.' INTO lv_message SEPARATED BY space.
    ELSE.
      CONCATENATE '연결된 이후공정이 없어 조장구성표 생성할 수 없습니다.' ' ' INTO lv_message SEPARATED BY space.
    ENDIF.

    MESSAGE s003 WITH lv_message.
  ENDIF.

  PERFORM refresh_screen_201.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CHECK_BEFORE_ROUTING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_FIELDNAME
*&      <-- LV_CHKERR
*&---------------------------------------------------------------------*
FORM proc_check_before_routing  CHANGING pv_chk_err.

  DATA : lt_column TYPE lvc_t_col.
  DATA : lt_cells TYPE lvc_t_ceno.
  DATA : lv_num(2) TYPE n.
  DATA : lt_2010 TYPE TABLE OF zgtppt2010.
  DATA : lv_chk_exist.
  DATA : lv_chart TYPE atwrt.

  FIELD-SYMBOLS <lv_line_seq> TYPE any.
  FIELD-SYMBOLS <lv_ordnr> TYPE any.
  FIELD-SYMBOLS <lv_posnr> TYPE any.
  FIELD-SYMBOLS <lv_ordty> TYPE any.
  FIELD-SYMBOLS <lv_stock> TYPE any.

  DATA : lv_fname01 TYPE fieldname. "오더넘버
  DATA : lv_fname02 TYPE fieldname. " 품목번호
  DATA : lv_fname03 TYPE fieldname. " 오더타입
  DATA : lv_fname04 TYPE fieldname. " 재고 체크

  DEFINE __get_index_of_table.
    IF <lv_line_seq> IS ASSIGNED. UNASSIGN <lv_line_seq>. ENDIF.
    ASSIGN COMPONENT 'LINE_SEQ' OF STRUCTURE <ls_main_201> TO <lv_line_seq>.
  END-OF-DEFINITION.

  DEFINE __set_field_name.
    CLEAR : lv_fname01, lv_fname02, lv_fname03.
    lv_fname01 = &1 && '_ORDNR'.
    lv_fname02 = &1 && '_POSNR'.
    lv_fname03 = &1 && '_ORDTY'.
    lv_fname04 = &1 && '_STOCK'.
  END-OF-DEFINITION.

  DEFINE __assign_field.
    IF <lv_ordnr> IS ASSIGNED. UNASSIGN <lv_ordnr>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_routing> TO <lv_ordnr>.
    IF <lv_posnr> IS ASSIGNED. UNASSIGN <lv_posnr>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_routing> TO <lv_posnr>.
    IF <lv_ordty> IS ASSIGNED. UNASSIGN <lv_ordty>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_routing> TO <lv_ordty>.
    IF <lv_stock> IS ASSIGNED. UNASSIGN <lv_stock>. ENDIF.
    ASSIGN COMPONENT lv_fname04 OF STRUCTURE <ls_routing> TO <lv_stock>.
  END-OF-DEFINITION.

  CLEAR : pv_chk_err.

  go_grid_0201->get_selected_columns(
    IMPORTING
      et_index_columns = lt_column                 " Cell IDs
  ).

  IF lines( lt_column[] ) > 1.
    pv_chk_err = abap_true.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '한개 이상의 칼럼을 선택할수 없습니다.'.
    RETURN.
  ENDIF.

  LOOP AT lt_column INTO DATA(ls_column).
    SPLIT ls_column-fieldname AT  '_'  INTO TABLE DATA(lt_string).
    READ TABLE lt_string INTO DATA(ls_string) INDEX 2.
    lv_chart = ls_string.
    IF NOT line_exists( gt_seq_routing[ chart = lv_chart ] ).
      MESSAGE s003 DISPLAY LIKE 'E' WITH '공정이 아닌 컬럼이 선택되었습니다.'.
      pv_chk_err = abap_true.
      EXIT.
    ENDIF.
* ABC타입 체크
    IF line_exists( gt_seq_routing[ chart = lv_chart maabc = 'B' ] ).
      pv_chk_err = abap_true.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '조장구성표 작성할 수 없는 공정 입니다.'.
      RETURN.
    ENDIF.

*  체인구성에 빈 곳이 있는지 여부 확인
    CLEAR lv_chk_exist.
    LOOP AT <gt_routing> ASSIGNING FIELD-SYMBOL(<ls_routing>).
      CLEAR lv_num.
      DO.
        ADD 1 TO lv_num.
        __set_field_name lv_num.
        __assign_field.

        IF <lv_stock> IS NOT INITIAL . "선행 오더 재고가 있으면 이전 공정 작업이 끝났다는 의미로 더이상 오더 생성할수 없다.
          EXIT.
        ENDIF.

*      조장구성표 구성체인중 해당 공정에 빈 공간이 있으면 ok
        IF <lv_ordty> = lv_chart AND <lv_ordnr> IS INITIAL.
          lv_chk_exist = abap_true.
          EXIT.
        ENDIF.

        IF lv_num >= gv_line_jojang.
          EXIT.
        ENDIF.
      ENDDO.
    ENDLOOP.
  ENDLOOP.

  CHECK pv_chk_err IS INITIAL.


  go_grid_0201->get_selected_cells_id(
    IMPORTING
     et_cells = lt_cells ).                " Cell IDs


  LOOP AT lt_cells INTO DATA(ls_cells).
    READ TABLE gt_fieldcat_0201 INTO DATA(ls_fcat) INDEX ls_cells-col_id.
    IF sy-subrc EQ 0.
      REFRESH lt_string.
      SPLIT ls_fcat-fieldname AT  '_'  INTO TABLE lt_string.
      READ TABLE lt_string INTO ls_string INDEX 2.
      lv_chart = ls_string.
      IF NOT line_exists( gt_seq_routing[ chart = lv_chart ] ).
        MESSAGE s003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'.
        pv_chk_err = abap_true.
        EXIT.
      ENDIF.
    ENDIF.

* ABC타입 체크
    IF line_exists( gt_seq_routing[ chart = lv_chart maabc = 'B' ] ).
      pv_chk_err = abap_true.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '조장구성표 작성할 수 없는 공정 입니다.'.
      RETURN.
    ENDIF.

*  선택된 필드의 오더정보 찾기
    READ TABLE <gt_main_201> ASSIGNING FIELD-SYMBOL(<ls_main_201>) INDEX ls_cells-row_id.
    IF sy-subrc EQ 0.
      __get_index_of_table.
      CLEAR lv_num.
      READ TABLE <gt_routing> ASSIGNING <ls_routing> INDEX <lv_line_seq>.
      DO.
        ADD 1 TO lv_num.
        __set_field_name lv_num.
        __assign_field.

        IF <lv_stock> IS NOT INITIAL . "선행 오더 재고가 있으면 이전 공정 작업이 끝났다는 의미로 더이상 오더 생성할수 없다.
          EXIT.
        ENDIF.


*      조장구성표 구성체인중 해당 공정에 빈 공간이 있으면 ok
        IF <lv_ordty> = lv_chart AND <lv_ordnr> IS INITIAL.
          lv_chk_exist = abap_true.
          EXIT.
        ENDIF.

        IF lv_num >= gv_line_jojang.
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.
  ENDLOOP.

  IF lv_chk_exist IS INITIAL.
    pv_chk_err = abap_true.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '조장구성표 작성할 수 없는 공정 입니다.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_cell_attribute_grid_0201 .

  DATA : lt_celltab TYPE lvc_t_styl.
  DATA : ls_celltab TYPE lvc_s_styl.

  DATA : lv_num(2) TYPE n.
  DATA : lv_index TYPE i.

  DATA : lv_fname01 TYPE fieldname. "오더넘버
  DATA : lv_fname02 TYPE fieldname. " 품목번호
  DATA : lv_fname03 TYPE fieldname. " 오더타입
  DATA : lv_fname04 TYPE fieldname. " 체크필드 네임
  DATA : lv_fname05 TYPE fieldname. " 재고상태
  DATA : lv_fname06 TYPE fieldname. " 오더완료, 재고 0 이후공정 진행중
  DATA : lv_chart_name TYPE fieldname. " 공정명

  CONSTANTS : lc_style01 TYPE lvc_style VALUE alv_style_color_int_heading, " 계획오더(파랑)
              lc_style02 TYPE lvc_style VALUE alv_style_color_int_positive, "생산오더(초록)
              lc_style03 TYPE lvc_style VALUE alv_style_color_positive, "판매오더(연초록)
              lc_style04 TYPE lvc_style VALUE alv_style_color_int_group, "재고(주황)
              lc_style05 TYPE lvc_style VALUE cl_gui_alv_grid=>mc_style_enabled, "열 수정가능
              lc_style06 TYPE lvc_style VALUE alv_style_font_italic, "이탤릭체
              lc_style07 TYPE lvc_style VALUE alv_style_color_inv_group. "생산완료 자재출고

  FIELD-SYMBOLS <lv_field> TYPE any.
  FIELD-SYMBOLS <lv_check> TYPE any.
  FIELD-SYMBOLS <lv_line_seq> TYPE any.
  FIELD-SYMBOLS <lv_line> TYPE any.
  FIELD-SYMBOLS <lt_celltab> TYPE any.

  FIELD-SYMBOLS : <lv_ordnr>     TYPE any,
                  <lv_posnr>     TYPE any,
                  <lv_ordty>     TYPE any,
                  <lv_chk_stock> TYPE any,
                  <lv_chk_zero>  TYPE any.

* Macro
  DEFINE __set_cell_attribute.
    CLEAR ls_celltab.
    ls_celltab-fieldname = &1.
    ls_celltab-style = &2.
    INSERT ls_celltab INTO TABLE lt_celltab.
  END-OF-DEFINITION.

  DEFINE __set_field_name.
    CLEAR : lv_fname01, lv_fname02, lv_fname03.
    lv_fname01 = &1 && '_ORDNR'.
    lv_fname02 = &1 && '_POSNR'.
    lv_fname03 = &1 && '_ORDTY'.
    lv_fname05 = &1 && '_STOCK'.
    lv_fname06 = &1 && '_ZERO'.
  END-OF-DEFINITION.

  DEFINE __assign_field.
    IF <lv_ordnr> IS ASSIGNED. UNASSIGN <lv_ordnr>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_routing> TO <lv_ordnr>.
    IF <lv_posnr> IS ASSIGNED. UNASSIGN <lv_posnr>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_routing> TO <lv_posnr>.
    IF <lv_ordty> IS ASSIGNED. UNASSIGN <lv_ordty>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_routing> TO <lv_ordty>.
  END-OF-DEFINITION.

  DEFINE __assign_etc_field.
    IF <lv_chk_stock> IS ASSIGNED. UNASSIGN <lv_chk_stock>. ENDIF.
    ASSIGN COMPONENT lv_fname05 OF STRUCTURE <ls_routing> TO <lv_chk_stock>.
    IF <lv_chk_zero> IS ASSIGNED. UNASSIGN <lv_chk_zero>. ENDIF.
    ASSIGN COMPONENT lv_fname06 OF STRUCTURE <ls_routing> TO <lv_chk_zero>.
  END-OF-DEFINITION.

  DEFINE __assign_main_field.
    CLEAR lv_fname04.
    lv_fname04 = &1 && '_CHK'.
    IF <lv_field> IS ASSIGNED. UNASSIGN <lv_field>. ENDIF.
    ASSIGN COMPONENT &1 OF STRUCTURE <ls_main> TO <lv_field>.
  END-OF-DEFINITION.

  LOOP AT <gt_main_201> ASSIGNING FIELD-SYMBOL(<ls_main>).

    CLEAR ls_celltab.
    REFRESH lt_celltab.

    __set_cell_attribute 'ORDNO_C' lc_style03.

    IF <lv_line_seq> IS ASSIGNED. UNASSIGN <lv_line_seq>. ENDIF.
    ASSIGN COMPONENT 'LINE_SEQ' OF STRUCTURE <ls_main> TO <lv_line_seq>.
    IF <lv_line_seq> IS ASSIGNED.
      CLEAR lv_index.
      lv_index = <lv_line_seq> + 0.
      READ TABLE <gt_routing> ASSIGNING FIELD-SYMBOL(<ls_routing>) INDEX lv_index.
      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.
    ENDIF.

    lv_num = gv_line_jojang.
    LOOP AT gt_seq_routing INTO DATA(ls_seq_routing).
      CHECK ls_seq_routing-maabc NE 'B'.

      __set_field_name lv_num.
      __assign_field.
      CLEAR lv_chart_name.
      PERFORM set_field_chart USING lv_num <lv_ordty> CHANGING lv_chart_name.
      __assign_main_field lv_chart_name.

*    각 첫번째열 체크필드 오픈
      IF <lv_line> IS ASSIGNED. UNASSIGN <lv_line>. ENDIF.
      ASSIGN COMPONENT 'LINE' OF STRUCTURE <ls_main> TO <lv_line>.
      IF <lv_line> IS ASSIGNED.
        IF <lv_line> = 1.
          __set_cell_attribute lv_fname04 lc_style05.
        ENDIF.
      ENDIF.

* 각필드 색상 지정
      IF <lv_ordnr> IS NOT INITIAL.
        READ TABLE gt_2010 INTO DATA(ls_2010) WITH KEY ordnr = <lv_ordnr>
                                                                       posnr = <lv_posnr>
                                                                       gong_cd = <lv_ordty>.
        IF sy-subrc EQ 0.

*          IF LS_2010-CHECK_JEGO = ABAP_TRUE.
*            __SET_CELL_ATTRIBUTE LS_SEQ_ROUTING-CHART LC_STYLE04.
*            CONTINUE.
*          ENDIF.
          CASE ls_2010-ordty.
            WHEN 'SO'.

            WHEN 'PLN'.
              __set_cell_attribute lv_chart_name lc_style01.
            WHEN 'PRD'.
              __assign_etc_field.
              IF <lv_chk_stock> = abap_true AND <lv_chk_zero> = abap_true. " 생산완료, 자재 출고
                CLEAR ls_celltab.
                ls_celltab-fieldname = lv_chart_name.
                ls_celltab-style = lc_style07 + lc_style06.
                INSERT ls_celltab INTO TABLE lt_celltab.
              ELSEIF  <lv_chk_stock> = abap_true AND <lv_chk_zero> = abap_false. "생산완료,재고상태
                IF ls_2010-check_jego = 'Q'.
                  __set_cell_attribute lv_chart_name alv_style_color_positive.
                ELSE.
                  __set_cell_attribute lv_chart_name lc_style04.
                ENDIF.
              ELSE.
                __set_cell_attribute lv_chart_name lc_style02.
              ENDIF.
            WHEN 'PO'. "차후적용

            WHEN 'PR'.  " 차후적용

          ENDCASE.
        ENDIF.
      ENDIF.
      <lv_ordty> = ls_seq_routing-chart.
      lv_num = lv_num - 1.
    ENDLOOP.

    IF <lt_celltab> IS ASSIGNED. UNASSIGN <lt_celltab>. ENDIF.
    ASSIGN COMPONENT 'XYZSTYLEZYX' OF STRUCTURE <ls_main> TO <lt_celltab>.
    IF <lt_celltab> IS ASSIGNED.
      <lt_celltab> = lt_celltab.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESIZING_FIELDCAT_GRID_0201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM resizing_fieldcat_grid_0201 .

  DATA : lv_string TYPE string.
  DATA : lv_chk_init.
  DATA : lv_num(2) TYPE n.
  DATA : lv_fieldname TYPE fieldname.
  DATA : lt_2010_cst LIKE gt_2010. " 연성 수량 계산을 위한 테이블
  DATA : lv_inlength TYPE i.
  DATA : lv_inlength_c TYPE c LENGTH 11.
  DATA : lv_infactor TYPE i.
  DATA : lv_infactor_c TYPE c LENGTH 11.

  lt_2010_cst = VALUE #( FOR lw_2010 IN gt_2010 WHERE ( gong_cd = 'CST' ) ( CORRESPONDING #( lw_2010 ) ) ).

  LOOP AT lt_2010_cst INTO DATA(ls_2010_cst).
    lv_inlength = lv_inlength + ls_2010_cst-inlength + ls_2010_cst-qlength + ls_2010_cst-clength + ls_2010_cst-adlength.
    lv_infactor = ls_2010_cst-infactor.
  ENDLOOP.

  lv_inlength_c = lv_inlength.
  lv_infactor_c = lv_infactor.
  CONDENSE : lv_inlength_c, lv_infactor_c.


  LOOP AT gt_seq_routing INTO DATA(ls_seq_routing).
    CLEAR lv_fieldname.
    lv_num = ls_seq_routing-seqno + 0.
    lv_fieldname = lv_num && '_' && ls_seq_routing-chart.

    READ TABLE gt_fieldcat_0201 ASSIGNING FIELD-SYMBOL(<ls_fcat>) WITH KEY fieldname = lv_fieldname.

    IF ls_seq_routing-chart = 'CST'.
      <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip &&'(' && lv_inlength_c && 'X' && lv_infactor_c && ')'.
    ENDIF.

    CLEAR <ls_fcat>-col_opt.
    IF ls_seq_routing-maabc = 'B'. " 조장 제외 대상은 무조건 OTP처리
      <ls_fcat>-col_opt = abap_true.
      CONTINUE.
    ENDIF.

    CLEAR lv_string.
    CLEAR lv_chk_init .
    CONCATENATE lv_fieldname 'is not initial' INTO lv_string SEPARATED BY space.
    LOOP AT <gt_main_201> ASSIGNING FIELD-SYMBOL(<ls_main>) WHERE (lv_string).
      lv_chk_init = abap_true.
      EXIT.
    ENDLOOP.
    IF lv_chk_init = abap_true.
      <ls_fcat>-col_opt = 'A'.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_SCREEN_201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_screen_201 .

  DATA: ls_scroll   TYPE lvc_s_stbl.

  ls_scroll-row = 'X'.
  ls_scroll-col = 'X'.

  PERFORM make_data_201.
  IF gv_chk_subpool_dir_full IS NOT INITIAL.
    IF gv_chk_subpool_dir_full IS NOT INITIAL.
*     종료
      CALL FUNCTION 'DEQUEUE_EZGT_ZGTPPR2010'
        EXPORTING
          grpnr = gv_grpnr.

      CALL METHOD go_docking_container->free.
      FREE : go_docking_container, go_grid_0200, go_grid_0201.
      CALL METHOD cl_gui_cfw=>flush.
      LEAVE TO SCREEN 0.
    ENDIF.

  ENDIF.

  PERFORM resizing_fieldcat_grid_0201.
  PERFORM set_cell_attribute_grid_0201.


  CALL METHOD go_grid_0201->set_frontend_fieldcatalog
    EXPORTING
      it_fieldcatalog = gt_fieldcat_0201.                 " Field Catalog
  CALL METHOD go_grid_0201->refresh_table_display
    EXPORTING
*     I_SOFT_REFRESH = 'X'
      is_stable = ls_scroll.

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
    WHEN go_grid_0201.
*      IF GT_ITEM_DISP[] IS INITIAL.
      PERFORM set_toolbar TABLES po_object->mt_toolbar
                          USING :
        'ALLSEL'      icon_select_all '전체선택' '전체선택' 0,
        'DESEL'       icon_deselect_all '선택해제' '선택해제' 0,
         '' '' '' '' 3,
        'DELE'        icon_delete '오더삭제' '오더삭제' 0,
        '' '' '' '' 3,    " " 재생산 오더 전환은 추후 재이관 예정
        'CHG_PRD'     icon_set_state '오더전환' '오더전환' 0 ,
        'CHG_PRD2'    icon_set_state '재생산오더전환' '재생산오더전환' 0 , "재생산 오더 전환은 추후 재이관 예정
        'CHG_PRD3'    icon_set_state '시작업오더전환' '시작업오더전환' 0 , "2026.04.14.zlsgpp5.SRM2604-05583.
        '' '' '' '' 3,
        'RELEASE'     icon_release '생산오더릴리즈' '생산오더릴리즈' 0 ,
        '' '' '' '' 3,
        'SET_NUM'     icon_system_cut '표준여장편집' '표준여장편집' 0 ,
        'EDIT_NUM'    icon_unlink '여장편집' '여장편집' 0 ,
        'CHG_QLENGTH' icon_system_local_cut '고정스크랩편집' '고정스크랩편집' 0 , "2026.07.28.zlsgpp5.SRM2607-10582.
        'CHG_BATCH'   icon_tools '설비변경' '설비변경' 0 ,
        '' '' '' '' 3,
        'CHG_PEGGING' icon_ps_relationship 'Pegging변경' 'Pegging변경' 0 ,
        'UNPEGGING'   icon_wf_unlink '재고 Pegging삭제' '재고 Pegging삭제' 0 ,
        'UNPEGGING_FORCE' icon_erase 'Pegging 강제삭제' 'Pegging 강제삭제' 0 ,
        '' '' '' '' 3,
        'SET_MULTY'   icon_interval_include_green '복조장구성' '복조장구성' 0 ,
        'SEPERATE'    icon_interval_exclude '개별오더전환' '개별오더전환' 0 ,
        '' '' '' '' 3,
        'LC_EXISTS'   icon_system_modus_delete 'LC 공정제외' 'LC 공정제외' 0 ,
        'SORT_UP'     icon_sort_up '' '조장정렬' 0 ,
        'SORT_DN'     icon_sort_down '' '조장정렬' 0 .
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
                  USING   pv_function
                          pv_icon
                          pv_text
                          pv_quickinfo
                          pv_butn_type.

  DATA : ls_toolbar  TYPE stb_button.

  CLEAR ls_toolbar.
  ls_toolbar-function  = pv_function.
  ls_toolbar-icon      = pv_icon.
  IF pv_text IS NOT INITIAL.
*    SRM2607-10582.2026.07.28.zlsgpp5.아이콘이 많아져서 공간을 줄임.
*    CONCATENATE ' '  pv_text ' '  INTO ls_toolbar-text SEPARATED BY space.
    ls_toolbar-text = pv_text.
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
FORM user_command_pros  USING po_sender  TYPE REF TO cl_gui_alv_grid
                              pv_ucomm.

  CASE po_sender.
    WHEN go_grid_0201.
      CASE pv_ucomm.
        WHEN 'DELE'.        "오더삭제
          PERFORM delete_order.
        WHEN 'CHG_PRD' OR 'CHG_PRD2' OR 'CHG_PRD3'.  " 오더전환
          PERFORM conversion_prod_order USING pv_ucomm.
        WHEN 'EDIT_NUM'.    "여장편집
          PERFORM edit_adlength.
        WHEN 'CHG_QLENGTH'. "고정스크랩편집.
          PERFORM change_qlength.
        WHEN 'RELEASE'.     "생산오더 릴리즈
          PERFORM release_prd_order.
        WHEN 'CHG_BATCH'.   "설비변경
          PERFORM change_batch.
        WHEN 'CHG_PEGGING'. "Pegging변경
          PERFORM process_pegging.
        WHEN 'UNPEGGING'.   "재고 Pegging삭제
          PERFORM process_unpegging.
        WHEN 'SET_MULTY'.   "복조장 구성
          PERFORM set_multy_posnr.
        WHEN 'SEPERATE'.    "개별오더전환
          PERFORM process_seperate.
        WHEN 'ALLSEL'.
          PERFORM process_allselect.
        WHEN 'DESEL'.
          PERFORM process_deselect.
        WHEN 'SET_NUM'.     "표준 여장 편집
          PERFORM set_standard_adlength.
        WHEN 'LC_EXISTS'.
          PERFORM exclude_bom_components.
        WHEN 'SUL_NO'.
          PERFORM disp_sul_no.
        WHEN 'UNPEGGING_FORCE'.
          PERFORM process_unpegging_force.
        WHEN 'SORT_UP'.
          PERFORM process_sort_leng USING 'U'.
        WHEN 'SORT_DN'.
          PERFORM process_sort_leng USING 'D'.
      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_PROD_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM conversion_prod_order USING pv_ucomm.

  DATA : lv_chk_err.
  DATA : lt_2010 TYPE TABLE OF zgtppt2010.
  DATA : lo_routing TYPE REF TO zgtpp_cl_routing.
  DATA : lv_result  TYPE char01,
         lv_message TYPE char100,
         lv_chk_con TYPE char01.
  DATA : lv_auart TYPE aufart.
  DATA : lv_text TYPE char100.

  CASE pv_ucomm.
    WHEN 'CHG_PRD3'.  "2026.04.14.zlsgpp5.SRM2604-05583.
      lv_auart = 'PL01'.
      lv_text = '선택된 계획오더를 시작업 오더로 전환하시겠습니까?'.
    WHEN 'CHG_PRD2'.
      lv_auart = 'RP01'.
      lv_text = '선택된 계획오더를 재생산 오더로 전환하시겠습니까?'.
    WHEN 'CHG_PRD'.
      lv_auart = 'PP01'.
      lv_text = '선택된 계획오더를 생산 오더로 전환하시겠습니까?'.
  ENDCASE.

  DATA : lv_chk_pojang TYPE char01.


  PERFORM chk_line_for_conversion TABLES lt_2010
                                  CHANGING lv_chk_err.

  IF lv_chk_err IS NOT INITIAL.
    RETURN.
  ENDIF.

  CHECK lt_2010[] IS NOT INITIAL.


  PERFORM check_pojang TABLES lt_2010 CHANGING lv_chk_pojang.

  IF lv_chk_pojang IS INITIAL.

    PERFORM popup_to_confirm_step USING 'N'
      ' '
      lv_text
      '작업확인'.
  ELSE.
    PERFORM popup_to_confirm_step USING 'N'
      ' '
      '포장재가 확정되지 않았습니다. 진행하시겠습니까?'
      '작업확인'.

  ENDIF.
  IF gv_answer NE 'J'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_routing
    EXPORTING
      iv_werks       = p_werks
      iv_grpnr       = gv_grpnr
      iv_auart       = lv_auart
      it_seq_routing = gt_seq_routing.

  lo_routing->conversion_prd_order(
    EXPORTING
      it_2010    = lt_2010
    IMPORTING
      ev_result  =  lv_result                " 길이 1의 문자 필드
      ev_message = lv_message                 " 문자 100
      ev_chk_con = lv_chk_con                 " 길이 1의 문자 필드
  ).

  IF lv_chk_con IS NOT INITIAL.
    PERFORM refresh_screen_201.
  ENDIF.

  IF lv_result = 'S'.
    DATA : lv_index(10) TYPE c.

*  변경정보 MES전송
    zgtpp_cl_routing=>send_chg_mes(
      iv_werks = p_werks           " 플랜트
      iv_spgcd = p_spgcd          " SPG 코드
      iv_grpnr = gv_grpnr ).    " 조장 구성표 번호

    lv_index = lines( lt_2010 ).
    CONDENSE lv_index.
    CLEAR lv_message.
    CONCATENATE gv_grpnr '계획오더' lv_index '건 생성하였습니다.' INTO lv_message SEPARATED BY space.
  ELSE.
    IF lo_routing->mt_tot_messtab[] IS NOT INITIAL.
      CALL FUNCTION 'Z_SD_DISPLAY_BDC_MESSAGE'
        TABLES
          it_retmsg = lo_routing->mt_tot_messtab.
    ELSE.

      MESSAGE s003 DISPLAY LIKE 'E' WITH lv_message.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_LINE_FOR_CONVERSION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM chk_line_for_conversion  TABLES pt_2010 STRUCTURE zgtppt2010
                                              CHANGING pv_chk_err.

  DATA : lt_column TYPE lvc_t_col.
  DATA : lt_cells TYPE lvc_t_ceno.
  DATA : lv_num(2) TYPE n.
  DATA : lt_2010 TYPE TABLE OF zgtppt2010.
  DATA : lv_chart TYPE atwrt.
  DATA : lv_seqno TYPE i.

  FIELD-SYMBOLS <lv_line_seq> TYPE any.
  FIELD-SYMBOLS <lv_ordnr> TYPE any.
  FIELD-SYMBOLS <lv_posnr> TYPE any.
  FIELD-SYMBOLS <lv_ordty> TYPE any.
  FIELD-SYMBOLS <lv_matnr> TYPE any.

  DATA : lv_fname01 TYPE fieldname. "오더넘버
  DATA : lv_fname02 TYPE fieldname. " 품목번호
  DATA : lv_fname03 TYPE fieldname. " 오더타입
  DATA : lv_fname04 TYPE fieldname. " 자재

  DEFINE __get_index_of_table.
    IF <lv_line_seq> IS ASSIGNED. UNASSIGN <lv_line_seq>. ENDIF.
    ASSIGN COMPONENT 'LINE_SEQ' OF STRUCTURE <ls_main_201> TO <lv_line_seq>.
  END-OF-DEFINITION.

  DEFINE __set_field_name.
    CLEAR : lv_fname01, lv_fname02, lv_fname03.
    lv_fname01 = &1 && '_ORDNR'.
    lv_fname02 = &1 && '_POSNR'.
    lv_fname03 = &1 && '_ORDTY'.
    lv_fname04 = &1 && '_MATNR'.
  END-OF-DEFINITION.

  DEFINE __assign_field.
    IF <lv_ordnr> IS ASSIGNED. UNASSIGN <lv_ordnr>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_routing> TO <lv_ordnr>.
    IF <lv_posnr> IS ASSIGNED. UNASSIGN <lv_posnr>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_routing> TO <lv_posnr>.
    IF <lv_ordty> IS ASSIGNED. UNASSIGN <lv_ordty>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_routing> TO <lv_ordty>.
    IF <lv_matnr> IS ASSIGNED. UNASSIGN <lv_matnr>. ENDIF.
    ASSIGN COMPONENT lv_fname04 OF STRUCTURE <ls_routing> TO <lv_matnr>.
  END-OF-DEFINITION.

  CLEAR : pv_chk_err.
  REFRESH pt_2010[].

  go_grid_0201->get_selected_columns(
    IMPORTING
      et_index_columns = lt_column ).                " Cell IDs

  go_grid_0201->get_selected_cells_id(
    IMPORTING
     et_cells = lt_cells ).                " Cell IDs

  IF lt_column[] IS INITIAL AND lt_cells[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '선택된 컬럼 또는 Cell이 없습니다.'.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  LOOP AT lt_column INTO DATA(ls_column).

    SPLIT ls_column-fieldname AT  '_'  INTO TABLE DATA(lt_string).
    READ TABLE lt_string INTO DATA(ls_string) INDEX 2.
    lv_chart = ls_string.

    IF NOT line_exists( gt_seq_routing[ chart = lv_chart ] ).
      MESSAGE s003 DISPLAY LIKE 'E' WITH '공정이 아닌 컬럼이 선택되었습니다.'.
      pv_chk_err = abap_true.
      EXIT.
    ENDIF.
* 선택된 컬럼의 공정 유형 전부 추출
    READ TABLE lt_string INTO ls_string INDEX 1.
    lv_seqno = ls_string + 0.
    READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY chart = lv_chart
                                                                                        seqno = lv_seqno.

    lt_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = lv_chart AND matnr = ls_seq_routing-matnr )
                                                   ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).
    IF lt_2010[] IS INITIAL.
      lt_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = lv_chart ) ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).
    ENDIF.

    APPEND LINES OF lt_2010 TO pt_2010.
  ENDLOOP.

  LOOP AT lt_cells INTO DATA(ls_cells).
    READ TABLE gt_fieldcat_0201 INTO DATA(ls_fcat) INDEX ls_cells-col_id.
    IF sy-subrc EQ 0.

      SPLIT ls_fcat-fieldname AT  '_'  INTO TABLE lt_string.
      READ TABLE lt_string INTO ls_string INDEX 2.
      lv_chart = ls_string.

      IF NOT line_exists( gt_seq_routing[ chart = lv_chart ] ).
        MESSAGE s003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'.
        pv_chk_err = abap_true.
        EXIT.
      ENDIF.
    ENDIF.

    READ TABLE lt_string INTO ls_string INDEX 1.
    lv_seqno = ls_string + 0.
    READ TABLE gt_seq_routing INTO ls_seq_routing WITH KEY chart = lv_chart
                                                                                          seqno = lv_seqno.

*  선택된 필드의 오더정보 찾기
    READ TABLE <gt_main_201> ASSIGNING FIELD-SYMBOL(<ls_main_201>) INDEX ls_cells-row_id.
    IF sy-subrc EQ 0.
      __get_index_of_table.
      CLEAR lv_num.
      READ TABLE <gt_routing> ASSIGNING FIELD-SYMBOL(<ls_routing>) INDEX <lv_line_seq>.
      DO.
        ADD 1 TO lv_num.
        __set_field_name lv_num.
        __assign_field.
        IF <lv_ordty> = ls_seq_routing-chart AND <lv_matnr> = ls_seq_routing-matnr.
          REFRESH lt_2010.
          lt_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = ls_seq_routing-chart
                                                                               AND ordnr = <lv_ordnr>
                                                                               AND matnr = ls_seq_routing-matnr
                                                                               AND check_jego IS INITIAL )
                                                            ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).
          IF lt_2010[] IS INITIAL.
            lt_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = ls_seq_routing-chart
                                                                                           AND ordnr = <lv_ordnr>
                                                                                           AND check_jego IS INITIAL )
                                                                        ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).
          ENDIF.

          APPEND LINES OF lt_2010 TO pt_2010.
          EXIT.
        ENDIF.

        IF lv_num >= lines( gt_seq_routing ).
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.
  ENDLOOP.

  CHECK pv_chk_err IS INITIAL.

  SORT pt_2010 BY gong_cd ordnr posnr ordty.
  DELETE ADJACENT DUPLICATES FROM pt_2010 COMPARING gong_cd ordnr posnr ordty.

* 자재조달유형 확인
  SELECT a~chart
    FROM @gt_seq_routing AS a
    INNER JOIN marc AS b
                           ON b~matnr = a~matnr
   WHERE b~werks = @p_werks
      AND b~beskz NE 'E'
      INTO TABLE @DATA(lt_chk_beskz).


*  계획 오더가 아닐시 오류로 종료
  LOOP AT pt_2010.
    IF pt_2010-ordty NE 'PLN'.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '계획 오더 유형이 아닌 오더가 선택 되었습니다. 계획 오더만 선택해 주세요'.
      pv_chk_err = abap_true.
      EXIT.
    ENDIF.

*   MARC-BESKZ = 'E' 내부 생산만 생산 오더 전환 가능
    IF line_exists( lt_chk_beskz[ chart = pt_2010-gong_cd ] ).
      DELETE pt_2010.
    ENDIF.
  ENDLOOP.



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

  DATA : lv_fname01 TYPE fieldname. "오더넘버
  DATA : lv_fname02 TYPE fieldname. " 품목번호
  DATA : lv_fname03 TYPE fieldname. " 오더타입
  DATA : lv_fname04 TYPE fieldname. "
  DATA : lv_num(2) TYPE n.
  DATA : lv_chart TYPE atwrt.
  DATA : lv_seqno TYPE i.

  FIELD-SYMBOLS <lv_line_seq> TYPE any.
  FIELD-SYMBOLS <lv_line> TYPE any.
  FIELD-SYMBOLS <lv_ordnr> TYPE any.
  FIELD-SYMBOLS <lv_posnr> TYPE any.
  FIELD-SYMBOLS <lv_ordty> TYPE any.
  FIELD-SYMBOLS <lv_matnr> TYPE any.
  FIELD-SYMBOLS <lv_vlaue> TYPE any.

  DEFINE __get_index_of_table.
    IF <lv_line_seq> IS ASSIGNED. UNASSIGN <lv_line_seq>. ENDIF.
    ASSIGN COMPONENT 'LINE_SEQ' OF STRUCTURE <ls_main_201> TO <lv_line_seq>.
  END-OF-DEFINITION.

  DEFINE __get_line_of_table.
    IF <lv_line> IS ASSIGNED. UNASSIGN <lv_line>. ENDIF.
    ASSIGN COMPONENT 'LINE' OF STRUCTURE <ls_main_201> TO <lv_line>.
  END-OF-DEFINITION.

  DEFINE __set_field_name.
    CLEAR : lv_fname01, lv_fname02, lv_fname03.
    lv_fname01 = &1 && '_ORDNR'.
    lv_fname02 = &1 && '_POSNR'.
    lv_fname03 = &1 && '_ORDTY'.
    lv_fname04 = &1 && '_MATNR'.
  END-OF-DEFINITION.

  DEFINE __assign_field.
    IF <lv_ordnr> IS ASSIGNED. UNASSIGN <lv_ordnr>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_routing> TO <lv_ordnr>.
    IF <lv_posnr> IS ASSIGNED. UNASSIGN <lv_posnr>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_routing> TO <lv_posnr>.
    IF <lv_ordty> IS ASSIGNED. UNASSIGN <lv_ordty>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_routing> TO <lv_ordty>.
    IF <lv_matnr> IS ASSIGNED. UNASSIGN <lv_matnr>. ENDIF.
    ASSIGN COMPONENT lv_fname04 OF STRUCTURE <ls_routing> TO <lv_matnr>.
  END-OF-DEFINITION.

  CHECK p_row-index > 0.

  CASE p_sender.
    WHEN go_grid_0200.
      IF p_column-fieldname = 'ORDNO_C'.
        READ TABLE gt_main_200 INTO gs_main_200 INDEX p_row-index.
        SET PARAMETER ID 'AUN' FIELD gs_main_200-ordno.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

      ENDIF.

    WHEN go_grid_0201.
      IF p_column-fieldname = 'ORDNO_C'.
        READ TABLE <gt_main_201> ASSIGNING FIELD-SYMBOL(<ls_main_201>) INDEX p_row-index.
        __get_index_of_table.
        CLEAR lv_num.
        READ TABLE <gt_routing> ASSIGNING FIELD-SYMBOL(<ls_routing>) INDEX <lv_line_seq>.
        __set_field_name lv_num.
        __assign_field.
        SET PARAMETER ID 'AUN' FIELD <lv_ordnr>.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

        EXIT.
      ENDIF.

      SPLIT p_column-fieldname AT  '_'  INTO TABLE DATA(lt_string).
      IF lines( lt_string ) NE 2.
        RETURN.
      ENDIF.

      READ TABLE lt_string INTO DATA(ls_string) INDEX 2.
      lv_chart = ls_string.

*      IF NOT LINE_EXISTS( GT_SEQ_ROUTING[ CHART = P_COLUMN-FIELDNAME ] ).
*        RETURN.
*      ENDIF.

      IF <lv_vlaue> IS ASSIGNED. UNASSIGN <lv_vlaue>. ENDIF.
      READ TABLE <gt_main_201> ASSIGNING <ls_main_201> INDEX p_row-index.
      ASSIGN COMPONENT p_column-fieldname OF STRUCTURE <ls_main_201> TO <lv_vlaue>.
      IF <lv_vlaue> IS ASSIGNED AND <lv_vlaue> IS INITIAL.
        RETURN.
      ENDIF.

* 선택된 컬럼의 공정 유형 전부 추출
      READ TABLE lt_string INTO ls_string INDEX 1.
      lv_seqno = ls_string + 0.

      READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY chart = lv_chart
                                                                                                      seqno = lv_seqno.

      READ TABLE <gt_main_201> ASSIGNING <ls_main_201> INDEX p_row-index.
      __get_line_of_table.
      __get_index_of_table.
      READ TABLE <gt_routing> ASSIGNING <ls_routing> INDEX <lv_line_seq>.

      lv_num = 1.
      DO.
        IF lv_num > gv_line_jojang.
          EXIT.
        ENDIF.

        __set_field_name lv_num.
        __assign_field.

        IF <lv_ordty> = ls_seq_routing-chart AND <lv_matnr> = ls_seq_routing-matnr.
          READ TABLE gt_2010 INTO DATA(ls_2010) WITH KEY gong_cd = ls_seq_routing-chart
                                                                                 ordnr = <lv_ordnr>
                                                                                 posnr = <lv_posnr>.
          EXIT.
        ENDIF.

        ADD 1 TO lv_num.

      ENDDO.

      CHECK ls_2010 IS NOT INITIAL.

      IF <lv_line> = 1. " 첫번째 열은 오더정보
        CASE ls_2010-ordty.
          WHEN 'PLN'.
            SET PARAMETER ID 'PAF' FIELD ls_2010-ordnr.
            CALL TRANSACTION 'MD13' AND SKIP FIRST SCREEN.

          WHEN 'PRD'.
            SET PARAMETER ID 'ANR' FIELD ls_2010-ordnr.
            CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
        ENDCASE.
        EXIT.
      ELSE. " 두번째 열은 자재정보
        SET PARAMETER ID 'WRK' FIELD p_werks.
        SET PARAMETER ID 'BERID' FIELD p_werks.
        IF ls_2010-real_matnr IS NOT INITIAL.
          SET PARAMETER ID 'MAT' FIELD ls_2010-real_matnr.
        ELSE.
          SET PARAMETER ID 'MAT' FIELD ls_seq_routing-matnr.
        ENDIF.
        IF ls_2010-check_jego IS INITIAL.
          CALL TRANSACTION 'MD04' AND SKIP FIRST SCREEN.
        ELSE.
          CALL TRANSACTION 'MMBE' AND SKIP FIRST SCREEN.
        ENDIF.

      ENDIF.

    WHEN go_grid_0220.
      READ TABLE gt_del_disp INTO gs_del_disp INDEX p_row-index.
      CASE gs_del_disp-ordty.
        WHEN 'PLN'.
          SET PARAMETER ID 'PAF' FIELD gs_del_disp-ordnr.
          CALL TRANSACTION 'MD13' AND SKIP FIRST SCREEN.
        WHEN 'PRD'.
          SET PARAMETER ID 'ANR' FIELD gs_del_disp-ordnr.
          CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
      ENDCASE.

  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form EDIT_ADLENGTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM edit_adlength .

  DATA : lt_2010 TYPE TABLE OF zgtppt2010.
  DATA : lt_2010_chg TYPE TABLE OF zgtppt2010.
  DATA : ls_2010_orign TYPE zgtppt2010.

  DATA : lv_chk_err.
  DATA : lo_routing TYPE REF TO zgtpp_cl_routing.
  DATA : lv_result  TYPE char01,
         lv_message TYPE char100.

  DATA : lv_chk_index TYPE i.

  PERFORM chk_before_edit_adlength  TABLES lt_2010
                                    CHANGING lv_chk_err.

  IF lv_chk_err IS NOT INITIAL.
    RETURN.
  ENDIF.

  CHECK lt_2010[] IS NOT INITIAL.

  CLEAR : gv_adlength, gv_adtype.

  LOOP AT lt_2010 ASSIGNING FIELD-SYMBOL(<ls_2010>).
    IF sy-tabix = 1.
      gv_adlength = <ls_2010>-adlength.
      gv_adtype = <ls_2010>-adtype.
      READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY chart = <ls_2010>-gong_cd
                                                                   matnr = <ls_2010>-matnr.
    ELSE.
      IF gv_adlength NE <ls_2010>-adlength.
        MESSAGE s003 DISPLAY LIKE 'E' WITH '여장정보가 다른 오더가 있습니다..'.
        RETURN.
      ENDIF.
      IF gv_adtype NE <ls_2010>-adtype.
        MESSAGE s003 DISPLAY LIKE 'E' WITH '여장정보가 다른 오더가 있습니다..'.
        RETURN.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CLEAR gv_chk_exit.
  CALL SCREEN '0210' STARTING AT 10 5 ENDING AT 90 9.

  CHECK gv_chk_exit IS INITIAL.

  CREATE OBJECT lo_routing
    EXPORTING
      it_seq_routing = gt_seq_routing
      iv_werks       = p_werks
      iv_grpnr       = gv_grpnr.


  REFRESH gt_del_disp.

  LOOP AT lt_2010 ASSIGNING <ls_2010>.
    IF NOT ( <ls_2010>-adlength = gv_adlength AND
             <ls_2010>-adtype = gv_adtype ).
      <ls_2010>-adlength = gv_adlength.
      <ls_2010>-adtype = gv_adtype.

      REFRESH lt_2010_chg.
      APPEND <ls_2010> TO lt_2010_chg.

      CLEAR : lv_result, lv_message.
* 여장 추가한 공정 수량 변경
      lo_routing->edit_adlength(
        EXPORTING
          it_2010    = lt_2010_chg
          iv_matnr   = ls_seq_routing-matnr   " 자재 번호
        IMPORTING
          ev_result  = lv_result              " 길이 1의 문자 필드
          ev_message = lv_message             " 문자 100
      ).

      APPEND INITIAL LINE TO gt_del_disp ASSIGNING FIELD-SYMBOL(<ls_del_disp>).
      <ls_del_disp>-ordnr = <ls_2010>-ordnr.
      <ls_del_disp>-ordty = <ls_2010>-ordty.
      IF lv_result = 'E'.
        <ls_del_disp>-status = icon_led_red.
        <ls_del_disp>-message = lv_message.
      ELSE.
        <ls_del_disp>-status = icon_led_green.
        <ls_del_disp>-message = '여장 추가 완료 되었습니다.'.
      ENDIF.

    ENDIF.
  ENDLOOP.

* 결과 메시지
  CLEAR gv_disp_set.
  gv_disp_set = 'B'.
  CALL SCREEN '0220' STARTING AT 10 5 ENDING AT 90 9.
  CLEAR gv_disp_set.

* 테이블 저장 : ZGTPPT2010, ZGTPPT2020, ZPPTC002, RESB
  lo_routing->confirm( ).

*  변경정보 MES전송
  zgtpp_cl_routing=>send_chg_mes(
    iv_werks = p_werks           " 플랜트
    iv_spgcd = p_spgcd          " SPG 코드
    iv_grpnr = gv_grpnr ).    " 조장 구성표 번호

  PERFORM refresh_screen_201.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_BEFORE_EDIT_ADLENGTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM chk_before_edit_adlength TABLES pt_2010 STRUCTURE zgtppt2010
                                              CHANGING pv_chk_err.

  DATA : lt_column TYPE lvc_t_col.
  DATA : lt_cells TYPE lvc_t_ceno.
  DATA : lv_num(2) TYPE n.
  DATA : lt_2010 TYPE TABLE OF zgtppt2010.
  DATA : lv_chart TYPE atwrt.
  DATA : lv_seqno TYPE i.

  FIELD-SYMBOLS <lv_line_seq> TYPE any.
  FIELD-SYMBOLS <lv_ordnr> TYPE any.
  FIELD-SYMBOLS <lv_posnr> TYPE any.
  FIELD-SYMBOLS <lv_ordty> TYPE any.
  FIELD-SYMBOLS <lv_stock> TYPE any.
  FIELD-SYMBOLS <lv_matnr> TYPE any.

  DATA : lv_fname01 TYPE fieldname. "오더넘버
  DATA : lv_fname02 TYPE fieldname. " 품목번호
  DATA : lv_fname03 TYPE fieldname. " 오더타입
  DATA : lv_fname04 TYPE fieldname. " 재고 체크
  DATA : lv_fname05 TYPE fieldname. " 자재

  DEFINE __get_index_of_table.
    IF <lv_line_seq> IS ASSIGNED. UNASSIGN <lv_line_seq>. ENDIF.
    ASSIGN COMPONENT 'LINE_SEQ' OF STRUCTURE <ls_main_201> TO <lv_line_seq>.
  END-OF-DEFINITION.

  DEFINE __set_field_name.
    CLEAR : lv_fname01, lv_fname02, lv_fname03.
    lv_fname01 = &1 && '_ORDNR'.
    lv_fname02 = &1 && '_POSNR'.
    lv_fname03 = &1 && '_ORDTY'.
    lv_fname04 = &1 && '_STOCK'.
    lv_fname05 = &1 && '_MATNR'.
  END-OF-DEFINITION.

  DEFINE __assign_field.
    IF <lv_ordnr> IS ASSIGNED. UNASSIGN <lv_ordnr>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_routing> TO <lv_ordnr>.
    IF <lv_posnr> IS ASSIGNED. UNASSIGN <lv_posnr>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_routing> TO <lv_posnr>.
    IF <lv_ordty> IS ASSIGNED. UNASSIGN <lv_ordty>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_routing> TO <lv_ordty>.
    IF <lv_stock> IS ASSIGNED. UNASSIGN <lv_stock>. ENDIF.
    ASSIGN COMPONENT lv_fname04 OF STRUCTURE <ls_routing> TO <lv_stock>.
    IF <lv_matnr> IS ASSIGNED. UNASSIGN <lv_matnr>. ENDIF.
    ASSIGN COMPONENT lv_fname05 OF STRUCTURE <ls_routing> TO <lv_matnr>.
  END-OF-DEFINITION.

  CLEAR : pv_chk_err.
  REFRESH pt_2010[].

  go_grid_0201->get_selected_columns(
    IMPORTING
      et_index_columns = lt_column ).                " Cell IDs

  IF lt_column[] IS NOT INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '컬럼을 선택할 수 없습니다.'.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  go_grid_0201->get_selected_cells_id(
    IMPORTING
     et_cells = lt_cells ).                " Cell IDs

*  IF 1 > LINES( LT_CELLS ). " 여러열 선택 가능하도록 변경
*    MESSAGE S003 DISPLAY LIKE 'E' WITH '하나의 셀만 선택해야 합니다.'.
*    PV_CHK_ERR = ABAP_TRUE.
*    RETURN.
*  ENDIF.

  LOOP AT lt_cells INTO DATA(ls_cells).
    READ TABLE gt_fieldcat_0201 INTO DATA(ls_fcat) INDEX ls_cells-col_id.
    IF sy-subrc EQ 0.

      SPLIT ls_fcat-fieldname AT  '_'  INTO TABLE DATA(lt_string).
      READ TABLE lt_string INTO DATA(ls_string) INDEX 2.
      lv_chart = ls_string.

      IF NOT line_exists( gt_seq_routing[ chart = lv_chart ] ).
        MESSAGE s003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'.
        pv_chk_err = abap_true.
        EXIT.
      ENDIF.
    ENDIF.

    READ TABLE lt_string INTO ls_string INDEX 1.
    lv_seqno = ls_string + 0.
    READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY chart = lv_chart
                                                                 seqno = lv_seqno.

*  선택된 필드의 오더정보 찾기
    READ TABLE <gt_main_201> ASSIGNING FIELD-SYMBOL(<ls_main_201>) INDEX ls_cells-row_id.
    IF sy-subrc EQ 0.
      __get_index_of_table.
      CLEAR lv_num.
      READ TABLE <gt_routing> ASSIGNING FIELD-SYMBOL(<ls_routing>) INDEX <lv_line_seq>.
      DO.
        ADD 1 TO lv_num.
        __set_field_name lv_num.
        __assign_field.
        IF <lv_ordty> = lv_chart AND <lv_stock> IS INITIAL AND <lv_matnr> = ls_seq_routing-matnr.
          lt_2010[] = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = ls_seq_routing-chart
                                                              AND   ordnr = <lv_ordnr>
                                                              AND   posnr = <lv_posnr> )
                                                            ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).

          APPEND LINES OF lt_2010 TO pt_2010.
          EXIT.
        ENDIF.

        IF lv_num >= gv_line_jojang.
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.
  ENDLOOP.

  IF pt_2010[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '작업 진행할수 없는 오더입니다.'.
    pv_chk_err = abap_true.
    EXIT.
  ENDIF.

  lt_2010 = pt_2010[].
  SORT lt_2010 BY gong_cd matnr.
  DELETE ADJACENT DUPLICATES FROM lt_2010 COMPARING gong_cd matnr.
  IF lines( lt_2010 ) > 1.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '하나의 공정만 선택가능합니다.'.
    pv_chk_err = abap_true.
    EXIT.
  ENDIF.
  REFRESH lt_2010.

  SORT pt_2010 BY gong_cd ordnr posnr ordty.
  DELETE ADJACENT DUPLICATES FROM pt_2010 COMPARING gong_cd ordnr posnr ordty.

*----------------------------------------------------------------------*
* 선택된 오더의 이전 공정 전부 추출후 정합성 체크
*----------------------------------------------------------------------*
  DATA : lv_chk_index TYPE i.

  LOOP AT pt_2010 INTO DATA(ls_2010_wq).
***  READ TABLE PT_2010 INTO DATA(LS_2010_WQ) INDEX 1.
    APPEND ls_2010_wq TO lt_2010.

    READ TABLE gt_seq_routing INTO ls_seq_routing WITH KEY matnr = ls_2010_wq-matnr.
    lv_chk_index = ls_seq_routing-seqno.
    lv_chk_index = lv_chk_index + 1.

    DO.
      IF lv_chk_index > lines( gt_seq_routing ).
        EXIT.
      ENDIF.

      READ TABLE gt_seq_routing INTO ls_seq_routing WITH KEY seqno = lv_chk_index.
      IF sy-subrc EQ 0 AND ls_seq_routing-maabc = 'B'. "ABC 지시자 B는 오더 변환 대상이 아님.
        lv_chk_index = lv_chk_index + 1.
        CONTINUE.
      ENDIF.

      LOOP AT gt_2010 INTO DATA(ls_2010) WHERE gong_cd = ls_seq_routing-chart
                                           AND matnr = ls_seq_routing-matnr.

        READ TABLE lt_2010 TRANSPORTING NO FIELDS WITH KEY ordnr = ls_2010-dmord
                                                           posnr = ls_2010-dmline
                                                           ordty = ls_2010-dmordty.
        IF sy-subrc EQ 0.
          IF ls_2010-check_jego IS NOT INITIAL.
            MESSAGE s003 DISPLAY LIKE 'E' WITH '이전 공정 중 작업 진행할수 없는 오더가 있습니다.'.
            pv_chk_err = abap_true.
            RETURN.
          ENDIF.

          APPEND INITIAL LINE TO lt_2010 ASSIGNING FIELD-SYMBOL(<ls_2010>).
          MOVE-CORRESPONDING ls_2010 TO <ls_2010>.
        ENDIF.

      ENDLOOP.

      lv_chk_index = lv_chk_index + 1.

    ENDDO.

  ENDLOOP.

*----------------------------------------------------------------------*
* 오더 Type이 생산 오더 "PRD" 가 아닌 경우, 경고 메시지: "생산 오더 유형만 여장을 추가 할 수 있습니다"
* 생산 오더 상태 확인 "PAYO", "PCNF", "CNF"의 경우, 오류 메시지: "생산 진행 중인 오더에 여장을 추가 할 수 없습니다."
* 이전 공정 오더 상태 확인(ZGTPPT2010-REORD), 이전 공정 오더가 생산 오더("PRD") 이면서 오더 상태 "PAYO", "PCNF", "CNF"의 경우
* 오류 메시지: "이전 공정 중 생산 중인 오더가 있어 여장을 추가 할 수 없습니다."
*----------------------------------------------------------------------*
  DATA : lv_aufnr TYPE aufk-aufnr.
  DATA : lv_stcd TYPE zordstcd.
  DATA : lv_objnr TYPE jest-objnr.
  DATA : lv_user_line TYPE bsvx-sttxt.

  LOOP AT lt_2010 INTO ls_2010_wq.

    IF ls_2010_wq-ordty EQ 'PRD'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_2010_wq-ordnr
        IMPORTING
          output = lv_aufnr.

*    상태값 조회
      CLEAR lv_stcd.
      CALL FUNCTION 'Z_PP_RETURN_ORDER_STATUS'
        EXPORTING
          im_aufnr        = lv_aufnr
        IMPORTING
          ex_ostcd        = lv_stcd
        EXCEPTIONS
          no_selection    = 1
          not_found_objnr = 2
          OTHERS          = 3.

      CLEAR lv_user_line.
      lv_objnr = 'OR' && lv_aufnr.
      CALL FUNCTION 'STATUS_TEXT_EDIT'
        EXPORTING
          flg_user_stat    = 'X'
          objnr            = lv_objnr
          only_active      = 'X'
          spras            = sy-langu
          bypass_buffer    = 'X'
        IMPORTING
          user_line        = lv_user_line
        EXCEPTIONS
          object_not_found = 1
          OTHERS           = 2.

    ENDIF.

    IF sy-tabix = 1. " 선택 라인의 경우
      IF ls_2010_wq-ordty NE 'PRD'.
        MESSAGE s003 DISPLAY LIKE 'E' WITH '생산 오더 유형만 여장을 추가 할 수 있습니다.'.
        pv_chk_err = abap_true.
        EXIT.
      ELSE.
        CASE lv_stcd.
          WHEN 'E' OR 'Z'. " 종료된 오더 혹은 비정상 오더
            MESSAGE s003 DISPLAY LIKE 'E' WITH '작업 진행할수 없는 오더입니다.'.
            pv_chk_err = abap_true.
            EXIT.
          WHEN 'D' OR 'G' OR 'F' OR 'C'. " 작업완료, 장업중인오더
            MESSAGE s003 DISPLAY LIKE 'E' WITH '생산 진행 중인 오더에 여장을 추가 할 수 없습니다.'.
            pv_chk_err = abap_true.
            EXIT.
        ENDCASE.

        FIND ALL OCCURRENCES OF 'PAYO' IN lv_user_line MATCH COUNT DATA(lv_line).
        IF lv_line > 0.
          MESSAGE s003 DISPLAY LIKE 'E' WITH '생산 진행 중인 오더에 여장을 추가 할 수 없습니다.'.
          pv_chk_err = abap_true.
          EXIT.
        ENDIF.
      ENDIF.
    ELSE. " 이전 공정의 경우
      IF ls_2010_wq-ordty EQ 'PRD'.
        CASE lv_stcd.
          WHEN 'E' OR 'Z'. " 종료된 오더 혹은 비정상 오더
            MESSAGE s003 DISPLAY LIKE 'E' WITH '이전 공정 중 작업 진행할수 없는 오더가 있습니다.'.
            pv_chk_err = abap_true.
            EXIT.
          WHEN 'D' OR 'G' OR 'F' OR 'C'. " 작업완료, 장업중인오더
            MESSAGE s003 DISPLAY LIKE 'E' WITH '이전 공정 중 생산 중인 오더가 있어 여장을 추가 할 수 없습니다.'.
            pv_chk_err = abap_true.
            EXIT.
        ENDCASE.

        FIND ALL OCCURRENCES OF 'PAYO' IN lv_user_line MATCH COUNT lv_line.
        IF lv_line > 0.
          MESSAGE s003 DISPLAY LIKE 'E' WITH '이전 공정 중 생산 중인 오더가 있어 여장을 추가 할 수 없습니다.'.
          pv_chk_err = abap_true.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

*  PT_2010[] = LT_2010[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_QLENGTH
*&---------------------------------------------------------------------*
* 2026.07.28.zlsgpp5.SRM2607-10582.고정 스크랩(각길이) 수정
*   1) 해당 프로그램에서 고정 스크랩(각길이) 수정 가능하도록 개선
*   2) "여장편집" 버튼과 별도의 버튼 클릭 후 사용자 입력하는 형태로 진행
*   - 완제품일 경우에만 처리.
*   - 여장편집 로직 복사 생성.
*----------------------------------------------------------------------*
FORM change_qlength.

  DATA : lt_2010        TYPE TABLE OF zgtppt2010,
         lt_2010_chg    TYPE TABLE OF zgtppt2010,
         ls_2010_orign  TYPE zgtppt2010,
         lv_chk_err,
         lo_routing     TYPE REF TO zgtpp_cl_routing,
         lv_result      TYPE char01,
         lv_message     TYPE char100,
         lv_chk_index   TYPE i,
         lv_chg_qlength TYPE zgtppt2010-qlength.


*__check.
  PERFORM chk_before_change_qlength TABLES lt_2010
                                    CHANGING lv_chk_err.
  IF lv_chk_err IS NOT INITIAL.
    RETURN.
  ENDIF.
  CHECK lt_2010[] IS NOT INITIAL.


*__call input screen.
  CLEAR: gv_chk_exit, gs_0260.
  CALL SCREEN '0260' STARTING AT 10 5 ENDING AT 90 9.
  CHECK gv_chk_exit IS INITIAL.


*__Instantiate the object
  CREATE OBJECT lo_routing
    EXPORTING
      it_seq_routing = gt_seq_routing
      iv_werks       = p_werks
      iv_grpnr       = gv_grpnr.


*__수량 변경
  REFRESH gt_del_disp.
  LOOP AT lt_2010 ASSIGNING FIELD-SYMBOL(<ls_2010>).
    IF <ls_2010>-qlength NE gs_0260-qlength.

      <ls_2010>-qlength = gs_0260-qlength.

      REFRESH lt_2010_chg.
      APPEND <ls_2010> TO lt_2010_chg.

      "고정스크랩 변경한 공정 수량 변경
      CLEAR : lv_result, lv_message.
      lo_routing->change_qlength(
        EXPORTING
          it_2010    = lt_2010_chg
          iv_matnr   = <ls_2010>-matnr        " 자재 번호
        IMPORTING
          ev_result  = lv_result              " 길이 1의 문자 필드
          ev_message = lv_message             " 문자 100
          ).

      "결과 메시지를 화면에 표시할 itab.
      APPEND INITIAL LINE TO gt_del_disp ASSIGNING FIELD-SYMBOL(<ls_del_disp>).
      <ls_del_disp>-ordnr = <ls_2010>-ordnr.
      <ls_del_disp>-ordty = <ls_2010>-ordty.
      IF lv_result = 'E'.
        <ls_del_disp>-status = icon_led_red.
        <ls_del_disp>-message = lv_message.
      ELSE.
        <ls_del_disp>-status = icon_led_green.
        <ls_del_disp>-message = '고정스크랩 변경 완료 되었습니다.'.
      ENDIF.

    ENDIF.
  ENDLOOP.


*__결과 메시지 스크린 호출
  CLEAR gv_disp_set.
  gv_disp_set = 'B'.
  CALL SCREEN '0220' STARTING AT 10 5 ENDING AT 90 9.
  CLEAR gv_disp_set.


*__테이블 저장 : ZGTPPT2010, ZGTPPT2020, ZPPTC002, RESB
  lo_routing->confirm( ).


*__변경정보 MES전송
  zgtpp_cl_routing=>send_chg_mes(
    iv_werks = p_werks           " 플랜트
    iv_spgcd = p_spgcd          " SPG 코드
    iv_grpnr = gv_grpnr ).    " 조장 구성표 번호

  PERFORM refresh_screen_201.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_BEFORE_CHANGE_QLENGTH
*&---------------------------------------------------------------------*
*& SRM2607-10582. 2026.07.28.zlsgpp5. 여장편집 로직 복사 생성.
*&                고정 스크랩(각길이) 수정하기 전 점검.
*&---------------------------------------------------------------------*
FORM chk_before_change_qlength  TABLES pt_2010 STRUCTURE zgtppt2010
                                CHANGING pv_chk_err.

  DATA : lt_column TYPE lvc_t_col,
         lt_cells  TYPE lvc_t_ceno,
         lv_num(2) TYPE n,
         lt_2010   TYPE TABLE OF zgtppt2010,
         lv_chart  TYPE atwrt,
         lv_seqno  TYPE i.

  FIELD-SYMBOLS <lv_line_seq> TYPE any.
  FIELD-SYMBOLS <lv_ordnr> TYPE any.
  FIELD-SYMBOLS <lv_posnr> TYPE any.
  FIELD-SYMBOLS <lv_ordty> TYPE any.
  FIELD-SYMBOLS <lv_stock> TYPE any.
  FIELD-SYMBOLS <lv_matnr> TYPE any.

  DATA : lv_fname01 TYPE fieldname. "오더넘버
  DATA : lv_fname02 TYPE fieldname. "품목번호
  DATA : lv_fname03 TYPE fieldname. "오더타입
  DATA : lv_fname04 TYPE fieldname. "재고 체크
  DATA : lv_fname05 TYPE fieldname. "자재

  DEFINE __get_index_of_table.
    IF <lv_line_seq> IS ASSIGNED. UNASSIGN <lv_line_seq>. ENDIF.
    ASSIGN COMPONENT 'LINE_SEQ' OF STRUCTURE <ls_main_201> TO <lv_line_seq>.
  END-OF-DEFINITION.

  DEFINE __set_field_name.
    CLEAR : lv_fname01, lv_fname02, lv_fname03.
    lv_fname01 = &1 && '_ORDNR'.
    lv_fname02 = &1 && '_POSNR'.
    lv_fname03 = &1 && '_ORDTY'.
    lv_fname04 = &1 && '_STOCK'.
    lv_fname05 = &1 && '_MATNR'.
  END-OF-DEFINITION.

  DEFINE __assign_field.
    IF <lv_ordnr> IS ASSIGNED. UNASSIGN <lv_ordnr>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_routing> TO <lv_ordnr>.
    IF <lv_posnr> IS ASSIGNED. UNASSIGN <lv_posnr>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_routing> TO <lv_posnr>.
    IF <lv_ordty> IS ASSIGNED. UNASSIGN <lv_ordty>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_routing> TO <lv_ordty>.
    IF <lv_stock> IS ASSIGNED. UNASSIGN <lv_stock>. ENDIF.
    ASSIGN COMPONENT lv_fname04 OF STRUCTURE <ls_routing> TO <lv_stock>.
    IF <lv_matnr> IS ASSIGNED. UNASSIGN <lv_matnr>. ENDIF.
    ASSIGN COMPONENT lv_fname05 OF STRUCTURE <ls_routing> TO <lv_matnr>.
  END-OF-DEFINITION.

  CLEAR : pv_chk_err.
  REFRESH pt_2010[].

  go_grid_0201->get_selected_columns(
    IMPORTING
      et_index_columns = lt_column ).                " Cell IDs

  IF lt_column[] IS NOT INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '컬럼을 선택할 수 없습니다.'.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  go_grid_0201->get_selected_cells_id(
    IMPORTING
     et_cells = lt_cells ).                " Cell IDs

*  IF 1 > LINES( LT_CELLS ). " 여러열 선택 가능하도록 변경
*    MESSAGE S003 DISPLAY LIKE 'E' WITH '하나의 셀만 선택해야 합니다.'.
*    PV_CHK_ERR = ABAP_TRUE.
*    RETURN.
*  ENDIF.

  LOOP AT lt_cells INTO DATA(ls_cells).
    READ TABLE gt_fieldcat_0201 INTO DATA(ls_fcat) INDEX ls_cells-col_id.
    IF sy-subrc EQ 0.
      SPLIT ls_fcat-fieldname AT  '_'  INTO TABLE DATA(lt_string).
      READ TABLE lt_string INTO DATA(ls_string) INDEX 2.
      lv_chart = ls_string.

      IF NOT line_exists( gt_seq_routing[ chart = lv_chart ] ).
        MESSAGE s003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'.
        pv_chk_err = abap_true.
        EXIT.
      ENDIF.
    ENDIF.

    READ TABLE lt_string INTO ls_string INDEX 1.
    lv_seqno = ls_string + 0.

    READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY chart = lv_chart
                                                                 seqno = lv_seqno.

*/s 2026.07.28.zlsgpp5.SRM2607-10582.고정 스크랩(각길이) 수정 가능하도록 개선.
    IF ls_seq_routing-seqno NE 1.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '완제품일 경우에만 변경 가능합니다.'.
      pv_chk_err = abap_true.
      RETURN.
    ENDIF.
*/e 2026.07.28.zlsgpp5.SRM2607-10582.


*   선택된 필드의 오더정보 찾기
    READ TABLE <gt_main_201> ASSIGNING FIELD-SYMBOL(<ls_main_201>) INDEX ls_cells-row_id.
    IF sy-subrc EQ 0.
      __get_index_of_table.
      CLEAR lv_num.
      READ TABLE <gt_routing> ASSIGNING FIELD-SYMBOL(<ls_routing>) INDEX <lv_line_seq>.
      DO.
        ADD 1 TO lv_num.
        __set_field_name lv_num.
        __assign_field.
        IF <lv_ordty> = lv_chart AND <lv_stock> IS INITIAL AND <lv_matnr> = ls_seq_routing-matnr.
          lt_2010[] = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = ls_seq_routing-chart AND
                                                              ordnr = <lv_ordnr> AND
                                                              posnr = <lv_posnr> )
                               ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).

          APPEND LINES OF lt_2010 TO pt_2010.
          EXIT.
        ENDIF.

        IF lv_num >= gv_line_jojang.
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.
  ENDLOOP.

  IF pt_2010[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '작업 진행할수 없는 오더입니다.'.
    pv_chk_err = abap_true.
    EXIT.
  ENDIF.

  lt_2010 = pt_2010[].
  SORT lt_2010 BY gong_cd matnr.
  DELETE ADJACENT DUPLICATES FROM lt_2010 COMPARING gong_cd matnr.
  IF lines( lt_2010 ) > 1.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '하나의 공정만 선택가능합니다.'.
    pv_chk_err = abap_true.
    EXIT.
  ENDIF.
  REFRESH lt_2010.

  SORT pt_2010 BY gong_cd ordnr posnr ordty.
  DELETE ADJACENT DUPLICATES FROM pt_2010 COMPARING gong_cd ordnr posnr ordty.

*----------------------------------------------------------------------*
* 선택된 오더의 이전 공정 전부 추출후 정합성 체크
*----------------------------------------------------------------------*
  DATA : lv_chk_index TYPE i.

  LOOP AT pt_2010 INTO DATA(ls_2010_wq).
***  READ TABLE PT_2010 INTO DATA(LS_2010_WQ) INDEX 1.
    APPEND ls_2010_wq TO lt_2010.

    READ TABLE gt_seq_routing INTO ls_seq_routing WITH KEY matnr = ls_2010_wq-matnr.
    lv_chk_index = ls_seq_routing-seqno.
    lv_chk_index = lv_chk_index + 1.

    DO.
      IF lv_chk_index > lines( gt_seq_routing ).
        EXIT.
      ENDIF.

      READ TABLE gt_seq_routing INTO ls_seq_routing WITH KEY seqno = lv_chk_index.
      IF sy-subrc EQ 0 AND ls_seq_routing-maabc = 'B'. "ABC 지시자 B는 오더 변환 대상이 아님.
        lv_chk_index = lv_chk_index + 1.
        CONTINUE.
      ENDIF.

      LOOP AT gt_2010 INTO DATA(ls_2010) WHERE gong_cd = ls_seq_routing-chart
                                           AND matnr = ls_seq_routing-matnr.

        READ TABLE lt_2010 TRANSPORTING NO FIELDS WITH KEY ordnr = ls_2010-dmord
                                                           posnr = ls_2010-dmline
                                                           ordty = ls_2010-dmordty.
        IF sy-subrc EQ 0.
          IF ls_2010-check_jego IS NOT INITIAL.
            MESSAGE s003 DISPLAY LIKE 'E' WITH '이전 공정 중 작업 진행할수 없는 오더가 있습니다.'.
            pv_chk_err = abap_true.
            RETURN.
          ENDIF.

          APPEND INITIAL LINE TO lt_2010 ASSIGNING FIELD-SYMBOL(<ls_2010>).
          MOVE-CORRESPONDING ls_2010 TO <ls_2010>.
        ENDIF.

      ENDLOOP.

      lv_chk_index = lv_chk_index + 1.

    ENDDO.

  ENDLOOP.

*----------------------------------------------------------------------*
* 오더 Type이 생산 오더 "PRD" 가 아닌 경우, 경고 메시지 표시.
* 생산 오더 상태 확인 "PAYO", "PCNF", "CNF"의 경우, 오류 메시지 표시.
* 이전 공정 오더 상태 확인(ZGTPPT2010-REORD), 이전 공정 오더가 생산 오더("PRD") 이면서 오더 상태 "PAYO", "PCNF", "CNF"의 경우
* 오류 메시지 표시.
*----------------------------------------------------------------------*
  DATA : lv_aufnr TYPE aufk-aufnr.
  DATA : lv_stcd TYPE zordstcd.
  DATA : lv_objnr TYPE jest-objnr.
  DATA : lv_user_line TYPE bsvx-sttxt.

  LOOP AT lt_2010 INTO ls_2010_wq.

    IF ls_2010_wq-ordty EQ 'PRD'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_2010_wq-ordnr
        IMPORTING
          output = lv_aufnr.

*    상태값 조회
      CLEAR lv_stcd.
      CALL FUNCTION 'Z_PP_RETURN_ORDER_STATUS'
        EXPORTING
          im_aufnr        = lv_aufnr
        IMPORTING
          ex_ostcd        = lv_stcd
        EXCEPTIONS
          no_selection    = 1
          not_found_objnr = 2
          OTHERS          = 3.

      CLEAR lv_user_line.
      lv_objnr = 'OR' && lv_aufnr.
      CALL FUNCTION 'STATUS_TEXT_EDIT'
        EXPORTING
          flg_user_stat    = 'X'
          objnr            = lv_objnr
          only_active      = 'X'
          spras            = sy-langu
          bypass_buffer    = 'X'
        IMPORTING
          user_line        = lv_user_line
        EXCEPTIONS
          object_not_found = 1
          OTHERS           = 2.

    ENDIF.

    IF sy-tabix = 1. " 선택 라인의 경우
      IF ls_2010_wq-ordty NE 'PRD'.
        MESSAGE s003 DISPLAY LIKE 'E' WITH '생산 오더 유형만 고정 스크랩(각길이)을 수정할 수 있습니다.'.
        pv_chk_err = abap_true.
        EXIT.
      ELSE.
        CASE lv_stcd.
          WHEN 'E' OR 'Z'. " 종료된 오더 혹은 비정상 오더
            MESSAGE s003 DISPLAY LIKE 'E' WITH '작업 진행할수 없는 오더입니다.'.
            pv_chk_err = abap_true.
            EXIT.
          WHEN 'D' OR 'G' OR 'F' OR 'C'. " 작업완료, 장업중인오더
            MESSAGE s003 DISPLAY LIKE 'E' WITH '생산 진행 중인 오더에 고정 스크랩(각길이)을 수정할 수 없습니다.'.
            pv_chk_err = abap_true.
            EXIT.
        ENDCASE.

        FIND ALL OCCURRENCES OF 'PAYO' IN lv_user_line MATCH COUNT DATA(lv_line).
        IF lv_line > 0.
          MESSAGE s003 DISPLAY LIKE 'E' WITH '생산 진행 중인 오더에 고정 스크랩(각길이)을 수정할 수 없습니다.'.
          pv_chk_err = abap_true.
          EXIT.
        ENDIF.
      ENDIF.
    ELSE. " 이전 공정의 경우
      IF ls_2010_wq-ordty EQ 'PRD'.
        CASE lv_stcd.
          WHEN 'E' OR 'Z'. " 종료된 오더 혹은 비정상 오더
            MESSAGE s003 DISPLAY LIKE 'E' WITH '이전 공정 중 작업 진행할수 없는 오더가 있습니다.'.
            pv_chk_err = abap_true.
            EXIT.
          WHEN 'D' OR 'G' OR 'F' OR 'C'. " 작업완료, 장업중인오더
            MESSAGE s003 DISPLAY LIKE 'E' WITH '이전 공정 중 생산 중인 오더가 있어 고정 스크랩(각길이)을 수정할 수 없습니다.'.
            pv_chk_err = abap_true.
            EXIT.
        ENDCASE.

        FIND ALL OCCURRENCES OF 'PAYO' IN lv_user_line MATCH COUNT lv_line.
        IF lv_line > 0.
          MESSAGE s003 DISPLAY LIKE 'E' WITH '이전 공정 중 생산 중인 오더가 있어 고정 스크랩(각길이)을 수정할 수 없습니다.'.
          pv_chk_err = abap_true.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

*  PT_2010[] = LT_2010[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_order .

  DATA: lt_2010      TYPE TABLE OF zgtppt2010,
        lo_routing   TYPE REF TO zgtpp_cl_routing,
        lt_err_order TYPE bapi_order_return_tt,
        lv_result    TYPE char01,
        lv_lines(11),
        lv_chk_err.

  PERFORM chk_before_edit_delete_order  TABLES lt_2010
                                        CHANGING lv_chk_err.
  IF lv_chk_err IS NOT INITIAL.
    RETURN.
  ENDIF.
  CHECK lt_2010[] IS NOT INITIAL.

  CLEAR gv_answer.
  PERFORM popup_to_confirm_step USING 'N'
    ' '
    '선택된 오더가 삭제 됩니다. 계속 진행 하시겠습니까?'
    '삭제확인'.
  IF gv_answer NE 'J'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_routing
    EXPORTING
      iv_werks       = p_werks
      iv_grpnr       = gv_grpnr
      it_seq_routing = gt_seq_routing.

  lo_routing->delete_order(
    EXPORTING
      it_2010      = lt_2010
    IMPORTING
      ev_result    =  lv_result     " 길이 1의 문자 필드
      et_err_order =  lt_err_order  " Table for BAPI Orders
  ).

  IF lv_result = 'E'.
    REFRESH gt_del_disp.
    LOOP AT lt_err_order INTO DATA(ls_err_order).
      APPEND INITIAL LINE TO gt_del_disp ASSIGNING FIELD-SYMBOL(<ls_del_disp>).
      <ls_del_disp>-ordnr = ls_err_order-order_number.
      IF ls_err_order-message IS INITIAL.
        <ls_del_disp>-ordty = 'PLN'.
        <ls_del_disp>-message = '계획오더 삭제중 오류 발생하였습니다.'.
      ELSE.
        <ls_del_disp>-ordty = 'PRD'.
        <ls_del_disp>-message = ls_err_order-message.
      ENDIF.
    ENDLOOP.
    CALL SCREEN '0220' STARTING AT 10 5 ENDING AT 90 9.
    PERFORM refresh_screen_201.

    IF gt_2010[] IS NOT INITIAL.
*  변경정보 MES전송
      zgtpp_cl_routing=>send_chg_mes(
        iv_werks = p_werks           " 플랜트
        iv_spgcd = p_spgcd          " SPG 코드
        iv_grpnr = gv_grpnr ).    " 조장 구성표 번호
    ENDIF.

  ELSE.
    PERFORM refresh_screen_201.

    IF gt_2010[] IS NOT INITIAL.
*  변경정보 MES전송
      zgtpp_cl_routing=>send_chg_mes(
        iv_werks = p_werks           " 플랜트
        iv_spgcd = p_spgcd          " SPG 코드
        iv_grpnr = gv_grpnr ).    " 조장 구성표 번호
    ENDIF.

    lv_lines = lines( lt_2010 ) .
    CONDENSE lv_lines.
    MESSAGE s006 WITH '총' lv_lines '건 오더 삭제되었습니다.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_BEFORE_EDIT_DELETE_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM chk_before_edit_delete_order  TABLES   pt_2010 STRUCTURE zgtppt2010
                                   CHANGING pv_chk_err.

  DATA : lt_column TYPE lvc_t_col.
  DATA : lt_cells TYPE lvc_t_ceno.
  DATA : lv_num(2) TYPE n.
  DATA : lt_2010 TYPE TABLE OF zgtppt2010.
  DATA : lv_chart TYPE atwrt.
  DATA : lv_seqno TYPE i.

  FIELD-SYMBOLS <lv_line_seq> TYPE any.
  FIELD-SYMBOLS <lv_ordnr> TYPE any.
  FIELD-SYMBOLS <lv_posnr> TYPE any.
  FIELD-SYMBOLS <lv_ordty> TYPE any.
  FIELD-SYMBOLS <lv_stock> TYPE any.
  FIELD-SYMBOLS <lv_matnr> TYPE any.

  DATA : lv_fname01 TYPE fieldname. "오더넘버
  DATA : lv_fname02 TYPE fieldname. " 품목번호
  DATA : lv_fname03 TYPE fieldname. " 오더타입
  DATA : lv_fname04 TYPE fieldname. " 재고 체크
  DATA : lv_fname05 TYPE fieldname. " 재고 체크

  DEFINE __get_index_of_table.
    IF <lv_line_seq> IS ASSIGNED. UNASSIGN <lv_line_seq>. ENDIF.
    ASSIGN COMPONENT 'LINE_SEQ' OF STRUCTURE <ls_main_201> TO <lv_line_seq>.
  END-OF-DEFINITION.

  DEFINE __set_field_name.
    CLEAR : lv_fname01, lv_fname02, lv_fname03.
    lv_fname01 = &1 && '_ORDNR'.
    lv_fname02 = &1 && '_POSNR'.
    lv_fname03 = &1 && '_ORDTY'.
    lv_fname04 = &1 && '_STOCK'.
    lv_fname05 = &1 && '_MATNR'.
  END-OF-DEFINITION.

  DEFINE __assign_field.
    IF <lv_ordnr> IS ASSIGNED. UNASSIGN <lv_ordnr>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_routing> TO <lv_ordnr>.
    IF <lv_posnr> IS ASSIGNED. UNASSIGN <lv_posnr>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_routing> TO <lv_posnr>.
    IF <lv_ordty> IS ASSIGNED. UNASSIGN <lv_ordty>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_routing> TO <lv_ordty>.
    IF <lv_stock> IS ASSIGNED. UNASSIGN <lv_stock>. ENDIF.
    ASSIGN COMPONENT lv_fname04 OF STRUCTURE <ls_routing> TO <lv_stock>.
    IF <lv_matnr> IS ASSIGNED. UNASSIGN <lv_matnr>. ENDIF.
    ASSIGN COMPONENT lv_fname05 OF STRUCTURE <ls_routing> TO <lv_matnr>.
  END-OF-DEFINITION.

  CLEAR : pv_chk_err.
  REFRESH pt_2010[].

  go_grid_0201->get_selected_columns(
    IMPORTING
      et_index_columns = lt_column ).                " Cell IDs

  go_grid_0201->get_selected_cells_id(
      IMPORTING
       et_cells = lt_cells ).                " Cell IDs

  IF lt_column[] IS INITIAL AND lt_cells[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '선택된 컬럼 또는 Cell이 없습니다.'.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  LOOP AT lt_column INTO DATA(ls_column).
    SPLIT ls_column-fieldname AT  '_'  INTO TABLE DATA(lt_string).
    READ TABLE lt_string INTO DATA(ls_string) INDEX 2.
    lv_chart = ls_string.

    IF NOT line_exists( gt_seq_routing[ chart = lv_chart ] ).
      MESSAGE s003 DISPLAY LIKE 'E' WITH '공정이 아닌 컬럼이 선택되었습니다.'.
      pv_chk_err = abap_true.
      EXIT.
    ENDIF.
* 선택된 컬럼의 공정 유형 전부 추출
    READ TABLE lt_string INTO ls_string INDEX 1.
    lv_seqno = ls_string + 0.
    READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY chart = lv_chart
                                                                 seqno = lv_seqno.

    lt_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = lv_chart AND matnr = ls_seq_routing-matnr )
                       ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).
    IF lt_2010[] IS INITIAL.
      lt_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = lv_chart )
                         ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).
    ENDIF.

    APPEND LINES OF lt_2010 TO pt_2010.
  ENDLOOP.


  LOOP AT lt_cells INTO DATA(ls_cells).
    READ TABLE gt_fieldcat_0201 INTO DATA(ls_fcat) INDEX ls_cells-col_id.
    IF sy-subrc EQ 0.

      SPLIT ls_fcat-fieldname AT  '_'  INTO TABLE lt_string.
      READ TABLE lt_string INTO ls_string INDEX 2.
      lv_chart = ls_string.

      IF NOT line_exists( gt_seq_routing[ chart = lv_chart ] ).
        MESSAGE s003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'.
        pv_chk_err = abap_true.
        EXIT.
      ENDIF.
    ENDIF.

    READ TABLE lt_string INTO ls_string INDEX 1.
    lv_seqno = ls_string + 0.
    READ TABLE gt_seq_routing INTO ls_seq_routing WITH KEY chart = lv_chart
                                                           seqno = lv_seqno.


*  선택된 필드의 오더정보 찾기
    READ TABLE <gt_main_201> ASSIGNING FIELD-SYMBOL(<ls_main_201>) INDEX ls_cells-row_id.
    IF sy-subrc EQ 0.
      __get_index_of_table.
      CLEAR lv_num.
      READ TABLE <gt_routing> ASSIGNING FIELD-SYMBOL(<ls_routing>) INDEX <lv_line_seq>.
      DO.
        ADD 1 TO lv_num.
        __set_field_name lv_num.
        __assign_field.

        IF <lv_ordty> = ls_seq_routing-chart AND <lv_matnr> = ls_seq_routing-matnr.
          REFRESH lt_2010.
          lt_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = ls_seq_routing-chart
                                                            AND ordnr = <lv_ordnr>
                                                            AND matnr = ls_seq_routing-matnr
                                                            AND check_jego IS INITIAL )
                             ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).
          IF lt_2010[] IS INITIAL.
            lt_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = ls_seq_routing-chart
                                                              AND ordnr = <lv_ordnr>
                                                              AND check_jego IS INITIAL )
                               ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).
          ENDIF.
          IF ls_seq_routing-chart = 'SHE' AND ls_seq_routing-seqno NE 1.
            READ TABLE lt_2010 INTO DATA(ls_she_2010) INDEX 1.
            REFRESH lt_2010.
            LOOP AT gt_2010 INTO DATA(ls_2010) WHERE dmord = ls_she_2010-dmord.
              APPEND INITIAL LINE TO lt_2010 ASSIGNING FIELD-SYMBOL(<ls_2010>).
              MOVE-CORRESPONDING ls_2010 TO <ls_2010>.
            ENDLOOP.

          ENDIF.

          APPEND LINES OF lt_2010 TO pt_2010.
          EXIT.
        ENDIF.

        IF lv_num >= gv_line_jojang.
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.
  ENDLOOP.

  REFRESH lt_2010.

  SORT pt_2010 BY gong_cd ordnr posnr.
  DELETE ADJACENT DUPLICATES FROM pt_2010 COMPARING gong_cd ordnr posnr.

*  선택된 오더의 이후 공정확인하여 복조장 일시 복조장 해재후 진행가능(202050327)
  LOOP AT pt_2010 INTO DATA(ls_2010_dm).
    IF ls_2010_dm-dmordty = 'PRD'.
      SELECT aufnr, posnr FROM afpo
      WHERE aufnr = @ls_2010_dm-dmord
        INTO TABLE @DATA(lt_dup_aufnr).
      SORT lt_dup_aufnr BY aufnr posnr.
      DELETE ADJACENT DUPLICATES FROM lt_dup_aufnr COMPARING aufnr posnr.
      IF lines( lt_dup_aufnr ) > 1.
*/s 2026.04.15.zlsgpp5.CHM2604-00316.복조장 및 Pegging 제한 해제.
*        MESSAGE s006 DISPLAY LIKE 'E' WITH  '이후공정' ls_2010_dm-dmord '오더는 복조장입니다. 구성 해재후 삭제 가능합니다.'.
*        pv_chk_err = abap_true.
*        RETURN.
*/e 2026.04.15.zlsgpp5.CHM2604-00316.
      ENDIF.
    ENDIF.
  ENDLOOP.


* 선택된 오더의 이전 공정 전부 추출후 정합성 체크
  DATA : lv_chk_index TYPE i.
  LOOP AT  pt_2010 INTO DATA(ls_2010_wq).
    APPEND ls_2010_wq TO lt_2010.
    READ TABLE gt_seq_routing INTO ls_seq_routing WITH KEY chart = ls_2010_wq-gong_cd
                                                           matnr = ls_2010_wq-matnr.
    IF sy-subrc NE 0.
      READ TABLE gt_seq_routing INTO ls_seq_routing WITH KEY chart = ls_2010_wq-gong_cd.
    ENDIF.

    lv_chk_index = ls_seq_routing-seqno.

    lv_chk_index = lv_chk_index + 1.
    DO.
      IF lv_chk_index > lines( gt_seq_routing ).
        EXIT.
      ENDIF.

      READ TABLE gt_seq_routing INTO ls_seq_routing WITH KEY seqno = lv_chk_index.
      IF sy-subrc EQ 0 AND ls_seq_routing-maabc = 'B'. "ABC 지시자 B는 오더 변환 대상이 아님.
        lv_chk_index = lv_chk_index + 1.
        CONTINUE.
      ENDIF.

      LOOP AT gt_2010 INTO ls_2010 WHERE gong_cd = ls_seq_routing-chart
                                     AND matnr = ls_seq_routing-matnr.
        READ TABLE lt_2010 TRANSPORTING NO FIELDS WITH KEY ordnr = ls_2010-dmord
                                                           posnr = ls_2010-dmline
                                                           ordty = ls_2010-dmordty.
        IF sy-subrc EQ 0.
          CLEAR ls_2010_wq.
          MOVE-CORRESPONDING ls_2010 TO ls_2010_wq.
          APPEND ls_2010_wq TO lt_2010.
        ENDIF.

      ENDLOOP.

      lv_chk_index = lv_chk_index + 1.

    ENDDO.
  ENDLOOP.

  SORT lt_2010 BY gong_cd ordnr ordty posnr.
  DELETE ADJACENT DUPLICATES FROM lt_2010 COMPARING gong_cd ordnr ordty posnr.


  DATA : lv_aufnr TYPE aufk-aufnr.
  DATA : lv_stcd TYPE zordstcd.
  DATA : lv_objnr TYPE jest-objnr.
  DATA : lv_user_line TYPE bsvx-sttxt.

* 생산 오더 상태 확인 "PAYO", "PCNF", "CNF"의 경우, 오류 메시지: 오더 + "오더는 생산 진행 중으로 삭제 할 수 없습니다."
* 이전 공정 오더 상태 확인(ZGTPPT2010-REORD), 이전 공정 오더가 생산 오더("PRD") 이면서 오더 상태 "PAYO", "PCNF", "CNF"의 경우
* 오류 메시지: "이전 공정" 오더 + "오더는 생산 진행 중으로 삭제 할 수 없습니다."
  LOOP AT lt_2010 INTO ls_2010_wq.

    IF ls_2010_wq-ordty EQ 'PRD'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_2010_wq-ordnr
        IMPORTING
          output = lv_aufnr.

*    상태값 조회
      CLEAR lv_stcd.
      CALL FUNCTION 'Z_PP_RETURN_ORDER_STATUS'
        EXPORTING
          im_aufnr        = lv_aufnr
        IMPORTING
          ex_ostcd        = lv_stcd
        EXCEPTIONS
          no_selection    = 1
          not_found_objnr = 2
          OTHERS          = 3.

      CLEAR lv_user_line.
      lv_objnr = 'OR' && lv_aufnr.
      CALL FUNCTION 'STATUS_TEXT_EDIT'
        EXPORTING
          flg_user_stat    = 'X'
          objnr            = lv_objnr
          only_active      = 'X'
          spras            = sy-langu
          bypass_buffer    = 'X'
        IMPORTING
          user_line        = lv_user_line
        EXCEPTIONS
          object_not_found = 1
          OTHERS           = 2.

    ENDIF.

    IF ls_2010_wq-ordty EQ 'PRD'.
      CASE lv_stcd.
        WHEN 'E' OR 'Z'. " 종료된 오더 혹은 비정상 오더
        WHEN 'D' OR 'G' OR 'F' OR 'C'. " 작업완료, 장업중인오더
          MESSAGE s006 DISPLAY LIKE 'E' WITH  '공정' ls_2010_wq-ordnr '오더는 생산 진행 중으로 삭제 할 수 없습니다.'.
          pv_chk_err = abap_true.
          EXIT.
      ENDCASE.

      FIND ALL OCCURRENCES OF 'PAYO' IN lv_user_line MATCH COUNT FINAL(lv_line).
      IF lv_line > 0.
        MESSAGE s006 DISPLAY LIKE 'E' WITH  '공정' ls_2010_wq-ordnr '오더는 생산 진행 중으로 삭제 할 수 없습니다.'.
        pv_chk_err = abap_true.
        EXIT.
      ENDIF.
    ENDIF.

  ENDLOOP.

  pt_2010[] = lt_2010[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0220
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_object_grid_0220 .

  CREATE OBJECT go_contain_0220
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

  CREATE OBJECT go_grid_0220
    EXPORTING
      i_parent      = go_contain_0220
      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0220
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_grid_0220 .

  DATA : lv_lines(11).
  CLEAR gs_layout_0220.
  gs_layout_0220-cwidth_opt = abap_true.
  gs_layout_0220-no_rowins = abap_true.
  gs_layout_0220-no_rowmark   = 'X'.
  gs_layout_0220-sel_mode   = 'C'.
  gs_layout_0220-smalltitle = abap_true.

  lv_lines = lines( gt_del_disp ).
  CONDENSE lv_lines.
  IF  gv_disp_set IS NOT INITIAL.
    CONCATENATE '건수 :' lv_lines '건' INTO gs_layout_0220-grid_title SEPARATED BY space.
  ELSE.
    CONCATENATE '에러 건수 :' lv_lines '건' INTO gs_layout_0220-grid_title SEPARATED BY space.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0220
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0220 .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR2010TOP'
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
      et_fieldcat_lvc = gt_fieldcat_0220[]
    TABLES
      it_data         = gt_del_disp
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT gt_fieldcat_0220 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CASE   <ls_fcat>-fieldname.
      WHEN 'STATUS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '상태'.
        <ls_fcat>-icon = abap_true.
        <ls_fcat>-just = 'C'.
        IF gv_disp_set IS INITIAL.
          <ls_fcat>-no_out = 'X'.
        ENDIF.
      WHEN 'ORDNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '오더'.
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'C'.
        IF gv_disp_set IS NOT INITIAL.
          <ls_fcat>-no_out = 'X'.
        ENDIF.
      WHEN 'ORDTY'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '오더 타입'.
        <ls_fcat>-just = 'C'.
        IF gv_disp_set IS NOT INITIAL.
          <ls_fcat>-no_out = 'X'.
        ENDIF.
      WHEN 'MESSAGE'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '결과 메세지'.
        <ls_fcat>-just = 'L'.
    ENDCASE.
    IF gv_disp_set = 'B'.
      CLEAR <ls_fcat>-no_out.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0220
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_of_toolbar_grid_0220 .

  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0220
        USING : cl_gui_alv_grid=>mc_fc_excl_all.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0220_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_grid_0220_display .

  CALL METHOD go_grid_0220->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0220
      it_toolbar_excluding = gt_exclude_0220
    CHANGING
      it_outtab            = gt_del_disp
      it_fieldcatalog      = gt_fieldcat_0220.

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

  DATA : lv_chk_err.
  DATA : lt_2010 TYPE TABLE OF zgtppt2010.
  DATA : lo_routing TYPE REF TO zgtpp_cl_routing.
  DATA : lt_err_order TYPE bapi_order_return_tt.
  DATA : lv_lines(11).

  DATA : lv_chk_pojang TYPE char01.

  PERFORM chk_line_for_release TABLES lt_2010
                                                 CHANGING lv_chk_err.

  IF lv_chk_err IS NOT INITIAL.
    RETURN.
  ENDIF.

  IF lt_2010[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '릴리즈 할 생산 오더를 선택해 주세요'.
    RETURN.
  ENDIF.

  PERFORM check_pojang TABLES lt_2010 CHANGING lv_chk_pojang.

  IF lv_chk_pojang IS INITIAL.

    CLEAR gv_answer.
    PERFORM popup_to_confirm_step USING 'N'
      ' '
      '선택된 오더가 릴리즈 됩니다. 계속 진행 하시겠습니까?'
      '작업확인'.
  ELSE.
    CLEAR gv_answer.
    PERFORM popup_to_confirm_step USING 'N'
      ' '
      '포장재가 확정되지 않았습니다. 진행하시겠습니까?'
      '작업확인'.

  ENDIF.
  IF gv_answer NE 'J'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_routing
    EXPORTING
      iv_werks = p_werks.

  lt_err_order = lo_routing->order_release( it_2010 = lt_2010 ).

  IF lt_err_order[] IS NOT INITIAL.
    REFRESH gt_del_disp.
    LOOP AT lt_err_order INTO DATA(ls_err_order).
      APPEND INITIAL LINE TO gt_del_disp ASSIGNING FIELD-SYMBOL(<ls_del_disp>).
      CASE ls_err_order-type.
        WHEN 'E'.
          <ls_del_disp>-status = icon_led_red.
        WHEN 'S'.
          <ls_del_disp>-status = icon_led_green.
        WHEN OTHERS.
          <ls_del_disp>-status = icon_led_yellow.
      ENDCASE.

      <ls_del_disp>-ordnr = ls_err_order-order_number.
      <ls_del_disp>-ordty = 'PRD'.
      <ls_del_disp>-message = ls_err_order-message.
    ENDLOOP.
    CLEAR gv_disp_set.
    gv_disp_set = 'B'.
    CALL SCREEN '0220' STARTING AT 10 5 ENDING AT 90 9.
    CLEAR gv_disp_set.
    PERFORM refresh_screen_201.

  ELSE.

    PERFORM refresh_screen_201.
    lv_lines = lines( lt_2010 ) .
    CONDENSE lv_lines.
    MESSAGE s006 WITH '총' lv_lines '건 릴리즈 완료하였습니다.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_LINE_FOR_RELEASE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM chk_line_for_release  TABLES pt_2010 STRUCTURE zgtppt2010
                                              CHANGING pv_chk_err.

  DATA : lt_column TYPE lvc_t_col.
  DATA : lt_cells TYPE lvc_t_ceno.
  DATA : lt_2010 TYPE TABLE OF zgtppt2010.
  DATA : lv_num(2) TYPE n.
  DATA : lv_chart TYPE atwrt.
  DATA : lv_seqno TYPE i.

  FIELD-SYMBOLS <lv_line_seq> TYPE any.
  FIELD-SYMBOLS <lv_ordnr> TYPE any.
  FIELD-SYMBOLS <lv_posnr> TYPE any.
  FIELD-SYMBOLS <lv_ordty> TYPE any.
  FIELD-SYMBOLS <lv_matnr> TYPE any.

  DATA : lv_fname01 TYPE fieldname. "오더넘버
  DATA : lv_fname02 TYPE fieldname. " 품목번호
  DATA : lv_fname03 TYPE fieldname. " 오더타입
  DATA : lv_fname04 TYPE fieldname. " 자재

  DEFINE __get_index_of_table.
    IF <lv_line_seq> IS ASSIGNED. UNASSIGN <lv_line_seq>. ENDIF.
    ASSIGN COMPONENT 'LINE_SEQ' OF STRUCTURE <ls_main_201> TO <lv_line_seq>.
  END-OF-DEFINITION.

  DEFINE __set_field_name.
    CLEAR : lv_fname01, lv_fname02, lv_fname03.
    lv_fname01 = &1 && '_ORDNR'.
    lv_fname02 = &1 && '_POSNR'.
    lv_fname03 = &1 && '_ORDTY'.
    lv_fname04 = &1 && '_MATNR'.
  END-OF-DEFINITION.

  DEFINE __assign_field.
    IF <lv_ordnr> IS ASSIGNED. UNASSIGN <lv_ordnr>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_routing> TO <lv_ordnr>.
    IF <lv_posnr> IS ASSIGNED. UNASSIGN <lv_posnr>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_routing> TO <lv_posnr>.
    IF <lv_ordty> IS ASSIGNED. UNASSIGN <lv_ordty>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_routing> TO <lv_ordty>.
    IF <lv_matnr> IS ASSIGNED. UNASSIGN <lv_matnr>. ENDIF.
    ASSIGN COMPONENT lv_fname04 OF STRUCTURE <ls_routing> TO <lv_matnr>.
  END-OF-DEFINITION.

  CLEAR : pv_chk_err.
  REFRESH pt_2010[].

  go_grid_0201->get_selected_columns(
    IMPORTING
      et_index_columns = lt_column ).                " Cell IDs

  go_grid_0201->get_selected_cells_id(
    IMPORTING
     et_cells = lt_cells ).                " Cell IDs

  IF lt_column[] IS INITIAL AND lt_cells[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '선택된 컬럼 또는 Cell이 없습니다.'.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  LOOP AT lt_column INTO DATA(ls_column).
    SPLIT ls_column-fieldname AT  '_'  INTO TABLE DATA(lt_string).
    READ TABLE lt_string INTO DATA(ls_string) INDEX 2.
    lv_chart = ls_string.

    IF NOT line_exists( gt_seq_routing[ chart = lv_chart ] ).
      MESSAGE s003 DISPLAY LIKE 'E' WITH '공정이 아닌 컬럼이 선택되었습니다.'.
      pv_chk_err = abap_true.
      EXIT.
    ENDIF.
* 선택된 컬럼의 공정 유형 전부 추출
    READ TABLE lt_string INTO ls_string INDEX 1.
    lv_seqno = ls_string + 0.
    READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY chart = lv_chart
                                                                                        seqno = lv_seqno.

    lt_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = lv_chart AND matnr = ls_seq_routing-matnr )
                                                   ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).
    IF lt_2010[] IS INITIAL.
      lt_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = lv_chart ) ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).
    ENDIF.

    APPEND LINES OF lt_2010 TO pt_2010.

  ENDLOOP.

  LOOP AT lt_cells INTO DATA(ls_cells).
    READ TABLE gt_fieldcat_0201 INTO DATA(ls_fcat) INDEX ls_cells-col_id.
    IF sy-subrc EQ 0.
      SPLIT ls_fcat-fieldname AT  '_'  INTO TABLE lt_string.
      READ TABLE lt_string INTO ls_string INDEX 2.
      lv_chart = ls_string.

      IF NOT line_exists( gt_seq_routing[ chart = lv_chart ] ).
        MESSAGE s003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'.
        pv_chk_err = abap_true.
        EXIT.
      ENDIF.
    ENDIF.

    READ TABLE lt_string INTO ls_string INDEX 1.
    lv_seqno = ls_string + 0.
    READ TABLE gt_seq_routing INTO ls_seq_routing WITH KEY chart = lv_chart
                                                                                          seqno = lv_seqno.

*  선택된 필드의 오더정보 찾기
    READ TABLE <gt_main_201> ASSIGNING FIELD-SYMBOL(<ls_main_201>) INDEX ls_cells-row_id.
    IF sy-subrc EQ 0.
      __get_index_of_table.
      CLEAR lv_num.
      READ TABLE <gt_routing> ASSIGNING FIELD-SYMBOL(<ls_routing>) INDEX <lv_line_seq>.
      DO.
        ADD 1 TO lv_num.
        __set_field_name lv_num.
        __assign_field.
        IF <lv_ordty> = ls_seq_routing-chart AND <lv_matnr> = ls_seq_routing-matnr.
          REFRESH lt_2010.
          lt_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = ls_seq_routing-chart
                                                                               AND ordnr = <lv_ordnr>
                                                                               AND matnr = ls_seq_routing-matnr
                                                                               AND check_jego IS INITIAL )
                                                            ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).
          IF lt_2010[] IS INITIAL.
            lt_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = ls_seq_routing-chart
                                                                                           AND ordnr = <lv_ordnr>
                                                                                           AND check_jego IS INITIAL )
                                                                        ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).
          ENDIF.
**          IF LS_SEQ_ROUTING-CHART = 'SHE' AND LS_SEQ_ROUTING-SEQNO NE 1.
**            READ TABLE LT_2010 INTO DATA(LS_SHE_2010) INDEX 1.
**            REFRESH LT_2010.
**            LOOP AT GT_2010 INTO DATA(LS_2010) WHERE DMORD = LS_SHE_2010-DMORD.
**              APPEND INITIAL LINE TO LT_2010 ASSIGNING FIELD-SYMBOL(<LS_2010>).
**              MOVE-CORRESPONDING LS_2010 TO <LS_2010>.
**            ENDLOOP.
**
**          ENDIF.

          APPEND LINES OF lt_2010 TO pt_2010.
          EXIT.
        ENDIF.

        IF lv_num >= lines( gt_seq_routing ).
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.
  ENDLOOP.

  CHECK pv_chk_err IS INITIAL.

  SORT pt_2010 BY gong_cd ordnr posnr ordty.
  DELETE ADJACENT DUPLICATES FROM pt_2010 COMPARING gong_cd ordnr ordty.

  DATA : lv_aufnr TYPE aufk-aufnr.
  DATA : lv_stcd TYPE zordstcd.
  DATA : lv_objnr TYPE jest-objnr.
  DATA : lv_user_line TYPE bsvx-sttxt.

*  생산 오더가 아닐시 스킵처리
* 생산 오더일시  상태가 CRTD 인건만 대상에 포함
  LOOP AT pt_2010.

    CASE pt_2010-ordty.
      WHEN 'PRD'.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = pt_2010-ordnr
          IMPORTING
            output = lv_aufnr.

*    상태값 조회
        CLEAR lv_stcd.
        CALL FUNCTION 'Z_PP_RETURN_ORDER_STATUS'
          EXPORTING
            im_aufnr        = lv_aufnr
          IMPORTING
            ex_ostcd        = lv_stcd
          EXCEPTIONS
            no_selection    = 1
            not_found_objnr = 2
            OTHERS          = 3.

        CLEAR lv_user_line.
        lv_objnr = 'OR' && lv_aufnr.
        CALL FUNCTION 'STATUS_TEXT_EDIT'
          EXPORTING
            flg_user_stat    = 'X'
            objnr            = lv_objnr
            only_active      = 'X'
            spras            = sy-langu
            bypass_buffer    = 'X'
          IMPORTING
            user_line        = lv_user_line
          EXCEPTIONS
            object_not_found = 1
            OTHERS           = 2.
        CASE lv_stcd.
          WHEN 'A'. " CRTD상태만 대상
          WHEN OTHERS.
            DELETE pt_2010.
            CONTINUE.
        ENDCASE.

        FIND ALL OCCURRENCES OF 'PAYO' IN lv_user_line MATCH COUNT FINAL(lv_line).
        IF lv_line > 0.
          DELETE pt_2010.
          CONTINUE.
        ENDIF.


      WHEN OTHERS.
        DELETE pt_2010.
    ENDCASE.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_batch
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM change_batch .

  DATA : lv_chk_err.
  DATA : lt_2010 TYPE TABLE OF zgtppt2010.
  DATA : lo_routing TYPE REF TO zgtpp_cl_routing.
  DATA : lv_result  TYPE char01,
         lv_message TYPE char100.
  DATA : lt_err_order TYPE bapi_order_return_tt.
  DATA : lv_lines(11).

  PERFORM chk_line_for_change_batch TABLES lt_2010
                                                       CHANGING lv_chk_err.

  IF lv_chk_err IS NOT INITIAL.
    RETURN.
  ENDIF.

  CHECK lt_2010[] IS NOT INITIAL.

  PERFORM get_routing_infor TABLES lt_2010.

  CHECK lines( gt_disp_arbpl ) IS NOT INITIAL.

* 변경설비 선택화면
  CALL SCREEN '0230' STARTING AT 10 5 ENDING AT 90 15.

  IF gs_disp_arbpl IS NOT INITIAL.
    CREATE OBJECT lo_routing.
    lt_err_order = lo_routing->change_batch(
                     it_2010  = lt_2010
                     iv_plnfl = gs_disp_arbpl-plnfl ).                 " 순서

    IF lt_err_order IS NOT INITIAL.
      REFRESH gt_del_disp.
      LOOP AT lt_err_order INTO DATA(ls_err_order).
        APPEND INITIAL LINE TO gt_del_disp ASSIGNING FIELD-SYMBOL(<ls_del_disp>).
        <ls_del_disp>-ordnr = ls_err_order-order_number.
        <ls_del_disp>-ordty = 'PRD'.
        <ls_del_disp>-message = ls_err_order-message.
      ENDLOOP.

      IF lo_routing->mt_tot_messtab[] IS NOT INITIAL.
        CALL FUNCTION 'Z_SD_DISPLAY_BDC_MESSAGE'
          TABLES
            it_retmsg = lo_routing->mt_tot_messtab.
      ELSE.
        CALL SCREEN '0220' STARTING AT 10 5 ENDING AT 90 9.
      ENDIF.
    ENDIF.

  ELSE.

*  변경정보 MES전송
    zgtpp_cl_routing=>send_chg_mes(
      iv_werks = p_werks           " 플랜트
      iv_spgcd = p_spgcd          " SPG 코드
      iv_grpnr = gv_grpnr ).    " 조장 구성표 번호

    lv_lines = lines( lt_2010 ) .
    CONDENSE lv_lines.
    MESSAGE s006 WITH '총' lv_lines '건 설비 변경 처리되었습니다.'.

  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_LINE_FOR_CHANGE_BATCH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM chk_line_for_change_batch  TABLES pt_2010 STRUCTURE zgtppt2010
                                                CHANGING pv_chk_err.

  DATA : lt_column TYPE lvc_t_col.
  DATA : lt_cells TYPE lvc_t_ceno.
  DATA : lv_num(2) TYPE n.
  DATA : lt_2010 TYPE TABLE OF zgtppt2010.
  DATA : lv_chart TYPE atwrt.
  DATA : lv_seqno TYPE i.

  FIELD-SYMBOLS <lv_line_seq> TYPE any.
  FIELD-SYMBOLS <lv_ordnr> TYPE any.
  FIELD-SYMBOLS <lv_posnr> TYPE any.
  FIELD-SYMBOLS <lv_ordty> TYPE any.
  FIELD-SYMBOLS <lv_stock> TYPE any.
  FIELD-SYMBOLS <lv_matnr> TYPE any.

  DATA : lv_fname01 TYPE fieldname. "오더넘버
  DATA : lv_fname02 TYPE fieldname. " 품목번호
  DATA : lv_fname03 TYPE fieldname. " 오더타입
  DATA : lv_fname04 TYPE fieldname. " 재고 체크
  DATA : lv_fname05 TYPE fieldname. "

  DEFINE __get_index_of_table.
    IF <lv_line_seq> IS ASSIGNED. UNASSIGN <lv_line_seq>. ENDIF.
    ASSIGN COMPONENT 'LINE_SEQ' OF STRUCTURE <ls_main_201> TO <lv_line_seq>.
  END-OF-DEFINITION.

  DEFINE __set_field_name.
    CLEAR : lv_fname01, lv_fname02, lv_fname03.
    lv_fname01 = &1 && '_ORDNR'.
    lv_fname02 = &1 && '_POSNR'.
    lv_fname03 = &1 && '_ORDTY'.
    lv_fname04 = &1 && '_STOCK'.
    lv_fname05 = &1 && '_MATNR'.
  END-OF-DEFINITION.

  DEFINE __assign_field.
    IF <lv_ordnr> IS ASSIGNED. UNASSIGN <lv_ordnr>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_routing> TO <lv_ordnr>.
    IF <lv_posnr> IS ASSIGNED. UNASSIGN <lv_posnr>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_routing> TO <lv_posnr>.
    IF <lv_ordty> IS ASSIGNED. UNASSIGN <lv_ordty>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_routing> TO <lv_ordty>.
    IF <lv_stock> IS ASSIGNED. UNASSIGN <lv_stock>. ENDIF.
    ASSIGN COMPONENT lv_fname04 OF STRUCTURE <ls_routing> TO <lv_stock>.
    IF <lv_matnr> IS ASSIGNED. UNASSIGN <lv_matnr>. ENDIF.
    ASSIGN COMPONENT lv_fname05 OF STRUCTURE <ls_routing> TO <lv_matnr>.
  END-OF-DEFINITION.

  CLEAR : pv_chk_err.
  REFRESH pt_2010[].

  go_grid_0201->get_selected_columns(
    IMPORTING
      et_index_columns = lt_column ).                " Cell IDs

  go_grid_0201->get_selected_cells_id(
    IMPORTING
     et_cells = lt_cells ).                " Cell IDs

  IF lt_column[] IS INITIAL AND lt_cells[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '선택된 컬럼 또는 Cell이 없습니다.'.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  IF 1 < lines( lt_column ).
    MESSAGE s003 DISPLAY LIKE 'E' WITH '하나의.공정만 선택가능합니다.'.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  LOOP AT lt_column INTO DATA(ls_column).
    SPLIT ls_column-fieldname AT  '_'  INTO TABLE DATA(lt_string).
    READ TABLE lt_string INTO DATA(ls_string) INDEX 2.
    lv_chart = ls_string.
    IF NOT line_exists( gt_seq_routing[ chart = lv_chart ] ).
      MESSAGE s003 DISPLAY LIKE 'E' WITH '공정이 아닌 컬럼이 선택되었습니다.'.
      pv_chk_err = abap_true.
      EXIT.
    ENDIF.
* 선택된 컬럼의 공정 유형 전부 추출
    READ TABLE lt_string INTO ls_string INDEX 1.
    lv_seqno = ls_string + 0.
    READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY chart = lv_chart
                                                                                        seqno = lv_seqno.

    lt_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = lv_chart AND matnr = ls_seq_routing-matnr )
                                                   ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).
    IF lt_2010[] IS INITIAL.
      lt_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = lv_chart ) ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).
    ENDIF.

    APPEND LINES OF lt_2010 TO pt_2010.
  ENDLOOP.

  DATA(lt_chk_sells) = lt_cells.
  SORT lt_chk_sells BY col_id.
  DELETE ADJACENT DUPLICATES FROM lt_chk_sells COMPARING col_id.

  IF 1 < lines( lt_chk_sells ).
    MESSAGE s003 DISPLAY LIKE 'E' WITH '하나의.공정만 선택가능합니다.'.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  LOOP AT lt_cells INTO DATA(ls_cells).
    READ TABLE gt_fieldcat_0201 INTO DATA(ls_fcat) INDEX ls_cells-col_id.
    IF sy-subrc EQ 0.

      SPLIT ls_fcat-fieldname AT  '_'  INTO TABLE lt_string.
      READ TABLE lt_string INTO ls_string INDEX 2.
      lv_chart = ls_string.

      IF NOT line_exists( gt_seq_routing[ chart = lv_chart ] ).
        MESSAGE s003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'.
        pv_chk_err = abap_true.
        EXIT.
      ENDIF.
    ENDIF.

    READ TABLE lt_string INTO ls_string INDEX 1.
    lv_seqno = ls_string + 0.
    READ TABLE gt_seq_routing INTO ls_seq_routing WITH KEY chart = lv_chart
                                                                                          seqno = lv_seqno.

*  선택된 필드의 오더정보 찾기
    READ TABLE <gt_main_201> ASSIGNING FIELD-SYMBOL(<ls_main_201>) INDEX ls_cells-row_id.
    IF sy-subrc EQ 0.
      __get_index_of_table.
      CLEAR lv_num.
      READ TABLE <gt_routing> ASSIGNING FIELD-SYMBOL(<ls_routing>) INDEX <lv_line_seq>.
      DO.
        ADD 1 TO lv_num.
        __set_field_name lv_num.
        __assign_field.
        IF <lv_ordty> = ls_seq_routing-chart AND <lv_matnr> = ls_seq_routing-matnr.
          REFRESH lt_2010.
          lt_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = ls_seq_routing-chart
                                                                               AND ordnr = <lv_ordnr>
                                                                               AND matnr = ls_seq_routing-matnr
                                                                               AND check_jego IS INITIAL )
                                                            ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).
          IF lt_2010[] IS INITIAL.
            lt_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = ls_seq_routing-chart
                                                                                           AND ordnr = <lv_ordnr>
                                                                                           AND check_jego IS INITIAL )
                                                                        ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).
          ENDIF.

          APPEND LINES OF lt_2010 TO pt_2010.
          EXIT.
        ENDIF.

        IF lv_num >= lines( gt_seq_routing ).
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.
  ENDLOOP.

  IF pt_2010[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '작업 진행할수 없는 오더입니다.'.
    pv_chk_err = abap_true.
  ENDIF.

  CHECK pv_chk_err IS INITIAL.

  DATA(lt_chk_2010) = pt_2010[].
  SORT lt_chk_2010 BY gong_cd.
  DELETE ADJACENT DUPLICATES FROM lt_chk_2010 COMPARING gong_cd.

  IF 1 < lines( lt_chk_2010 ).
    MESSAGE s003 DISPLAY LIKE 'E' WITH '하나의.공정만 선택가능합니다.'.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  SORT pt_2010 BY gong_cd ordnr ordty matnr.
  DELETE ADJACENT DUPLICATES FROM pt_2010 COMPARING gong_cd ordnr ordty matnr.

  DATA : lv_aufnr TYPE aufk-aufnr.
  DATA : lv_stcd TYPE zordstcd.
  DATA : lv_objnr TYPE jest-objnr.
  DATA : lv_user_line TYPE bsvx-sttxt.

* 생산오더만 변경가능 그외 오더는 스킵
* 생산 오더일시  상태가 CRTD 인건만 대상에 포함 그외 스킵
  LOOP AT pt_2010.
    CASE pt_2010-ordty.
      WHEN 'PRD'.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = pt_2010-ordnr
          IMPORTING
            output = lv_aufnr.

*    상태값 조회
        CLEAR lv_stcd.
        CALL FUNCTION 'Z_PP_RETURN_ORDER_STATUS'
          EXPORTING
            im_aufnr        = lv_aufnr
          IMPORTING
            ex_ostcd        = lv_stcd
          EXCEPTIONS
            no_selection    = 1
            not_found_objnr = 2
            OTHERS          = 3.

        CLEAR lv_user_line.
        lv_objnr = 'OR' && lv_aufnr.
        CALL FUNCTION 'STATUS_TEXT_EDIT'
          EXPORTING
            flg_user_stat    = 'X'
            objnr            = lv_objnr
            only_active      = 'X'
            spras            = sy-langu
            bypass_buffer    = 'X'
          IMPORTING
            user_line        = lv_user_line
          EXCEPTIONS
            object_not_found = 1
            OTHERS           = 2.
        CASE lv_stcd.
          WHEN 'A'. " CRTD상태만 대상
          WHEN OTHERS.
            DELETE pt_2010.
            CONTINUE.
        ENDCASE.

        FIND ALL OCCURRENCES OF 'PAYO' IN lv_user_line MATCH COUNT FINAL(lv_line).
        IF lv_line > 0.
          DELETE pt_2010.
          CONTINUE.
        ENDIF.

      WHEN OTHERS.
        DELETE pt_2010.
    ENDCASE.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ROUTING_INFOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&---------------------------------------------------------------------*
FORM get_routing_infor  TABLES   pt_2010 STRUCTURE zgtppt2010.

  DATA : lv_aufnr TYPE aufnr.
  READ TABLE pt_2010 INDEX 1.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = pt_2010-ordnr
    IMPORTING
      output = lv_aufnr.

  SELECT
   f~ktext, e~arbpl, b~aplfl AS plnfl
   FROM afko         AS a
   INNER JOIN afvc   AS b
                           ON b~aufpl = a~aufpl
   INNER JOIN crhd  AS e
                           ON e~objid = b~arbid
   INNER JOIN crtx   AS f
                           ON f~objid = e~objid
                          AND f~objty = e~objty
   WHERE a~aufnr = @lv_aufnr
    AND  f~spras = @sy-langu
   INTO CORRESPONDING FIELDS OF TABLE @gt_disp_arbpl.

  LOOP AT gt_disp_arbpl ASSIGNING FIELD-SYMBOL(<ls_arbpl>).
    IF <ls_arbpl>-plnfl = '000000'.
      <ls_arbpl>-check = abap_true.
    ENDIF.
  ENDLOOP.

  SORT gt_disp_arbpl BY plnfl.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0230
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_object_grid_0230 .

  CREATE OBJECT go_contain_0230
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

  CREATE OBJECT go_grid_0230
    EXPORTING
      i_parent      = go_contain_0230
      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0230
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_grid_0230 .

  gs_layout_0230-cwidth_opt = abap_true.
  gs_layout_0230-no_rowins = abap_true.
  gs_layout_0230-no_rowmark   = 'X'.
  gs_layout_0230-sel_mode   = 'C'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0230
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0230 .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR2010TOP'
      i_internal_tabname     = 'GS_DISP_ARBPL'
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
      et_fieldcat_lvc = gt_fieldcat_0230[]
    TABLES
      it_data         = gt_disp_arbpl
    EXCEPTIONS
      OTHERS          = 1.

  IF NOT line_exists( gt_fieldcat_0230[ fieldname = 'CHECK'] ).
    APPEND INITIAL LINE TO gt_fieldcat_0230 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    <ls_fcat>-fieldname = 'CHECK'.
    <ls_fcat>-datatype = 'CHAR'.
    <ls_fcat>-dd_outlen = '1'.
    <ls_fcat>-outputlen = '1'.
    <ls_fcat>-checkbox = abap_true.
  ENDIF.

  LOOP AT gt_fieldcat_0230 ASSIGNING <ls_fcat>.
    CASE   <ls_fcat>-fieldname.
      WHEN 'CHECK'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '선택'.
        <ls_fcat>-edit = abap_true.
        <ls_fcat>-just = 'C'.
        <ls_fcat>-col_pos = 1.
      WHEN 'KTEXT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '작업장명'.
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'L'.
        <ls_fcat>-col_pos = 2.
      WHEN 'ARBPL'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '작업장'.
        <ls_fcat>-just = 'C'.
        <ls_fcat>-col_pos = 3.
      WHEN 'PLNFL'.
        <ls_fcat>-no_out = abap_true.
        <ls_fcat>-col_pos = 4.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0230
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_of_toolbar_grid_0230 .

  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0230
        USING : cl_gui_alv_grid=>mc_fc_excl_all.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0230_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_grid_0230_display .

  CALL METHOD go_grid_0230->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0230
      it_toolbar_excluding = gt_exclude_0230
    CHANGING
      it_outtab            = gt_disp_arbpl
      it_fieldcatalog      = gt_fieldcat_0230.

* 인풋이벤트 추가
  CALL METHOD go_grid_0230->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CALL METHOD go_grid_0230->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_checkbox
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_checkbox .

  LOOP AT gt_disp_arbpl ASSIGNING FIELD-SYMBOL(<ls_disp_arbpl>).
    CLEAR <ls_disp_arbpl>-check.
  ENDLOOP.

  READ TABLE gt_disp_arbpl ASSIGNING <ls_disp_arbpl> INDEX gv_chk_line.
  <ls_disp_arbpl>-check = gv_chk_value.

  PERFORM refresh_grid USING go_grid_0230.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_PEGGING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_pegging .

  DATA : lv_chk_err.
  DATA : lt_2010 TYPE TABLE OF zgtppt2010.
  DATA : lo_routing TYPE REF TO zgtpp_cl_routing.
  DATA : lv_aufnr_from TYPE afpo-aufnr.
  DATA : lv_posnr_from TYPE afpo-posnr.
  DATA : lv_result  TYPE char01,
         lv_message TYPE char100.
  DATA  : lt_pegging LIKE gt_pegging.

  REFRESH gt_pegging.
  PERFORM chk_proc_pegging  TABLES lt_2010
                            CHANGING lv_chk_err.

  IF lv_chk_err IS NOT INITIAL.
    RETURN.
  ENDIF.

  IF lt_2010[] IS INITIAL.
    RETURN.
  ENDIF.

  REFRESH gt_pegging_2010.
  MOVE-CORRESPONDING lt_2010 TO gt_pegging_2010.

  READ TABLE lt_2010 INTO DATA(ls_2010) INDEX 1.
  gs_pegging_disp-matnr = ls_2010-matnr.
  PERFORM select_data_from_matnr USING ls_2010-matnr.

*  페깅 변경항 오더 선택화면
  CALL SCREEN '0240' STARTING AT 10 5 ENDING AT 145 20.

  READ TABLE gt_pegging INTO DATA(ls_pegging) WITH KEY check = abap_true.

  lv_aufnr_from = ls_pegging-aufnr.

  lt_pegging =   VALUE #( FOR lw_pegging IN gt_pegging WHERE ( check = abap_true )
                                                                                ( CORRESPONDING #( lw_pegging ) ) ).

  IF lines( lt_pegging ) = 1.
    lv_posnr_from = ls_pegging-posnr.
  ENDIF.

  CHECK lv_aufnr_from IS NOT INITIAL.

  CREATE OBJECT lo_routing
    EXPORTING
      it_seq_routing = gt_seq_routing
      iv_werks       = p_werks
      iv_grpnr       = gv_grpnr.

  lv_result = lo_routing->proc_pegging(
  EXPORTING
    iv_target_order =  lv_aufnr_from                " 오더 번호
    iv_target_posnr =  lv_posnr_from                " 품목 번호
    it_pegging_data =   lt_2010 ).


*  변경정보 MES전송
  zgtpp_cl_routing=>send_chg_mes(
    iv_werks = p_werks           " 플랜트
    iv_spgcd = p_spgcd          " SPG 코드
    iv_grpnr = gv_grpnr ).    " 조장 구성표 번호

  PERFORM refresh_screen_201.

  MESSAGE s003 WITH 'Pegging 변경되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_PROC_PEGGING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM chk_proc_pegging  TABLES pt_2010 STRUCTURE zgtppt2010
                                   CHANGING pv_chk_err.

  DATA : lt_column TYPE lvc_t_col.
  DATA : lt_cells TYPE lvc_t_ceno.
  DATA : lv_num(2) TYPE n.
  DATA : lt_2010 TYPE TABLE OF zgtppt2010.
  DATA : lv_chart TYPE atwrt.
  DATA : lv_seqno TYPE i.


  FIELD-SYMBOLS <lv_line_seq> TYPE any.
  FIELD-SYMBOLS <lv_ordnr> TYPE any.
  FIELD-SYMBOLS <lv_posnr> TYPE any.
  FIELD-SYMBOLS <lv_ordty> TYPE any.
  FIELD-SYMBOLS <lv_matnr> TYPE any.

  DATA : lv_fname01 TYPE fieldname. "오더넘버
  DATA : lv_fname02 TYPE fieldname. " 품목번호
  DATA : lv_fname03 TYPE fieldname. " 오더타입
  DATA : lv_fname04 TYPE fieldname. "

  DEFINE __get_index_of_table.
    IF <lv_line_seq> IS ASSIGNED. UNASSIGN <lv_line_seq>. ENDIF.
    ASSIGN COMPONENT 'LINE_SEQ' OF STRUCTURE <ls_main_201> TO <lv_line_seq>.
  END-OF-DEFINITION.

  DEFINE __set_field_name.
    CLEAR : lv_fname01, lv_fname02, lv_fname03, lv_fname03.
    lv_fname01 = &1 && '_ORDNR'.
    lv_fname02 = &1 && '_POSNR'.
    lv_fname03 = &1 && '_ORDTY'.
    lv_fname04 = &1 && '_MATNR'.
  END-OF-DEFINITION.

  DEFINE __assign_field.
    IF <lv_ordnr> IS ASSIGNED. UNASSIGN <lv_ordnr>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_routing> TO <lv_ordnr>.
    IF <lv_posnr> IS ASSIGNED. UNASSIGN <lv_posnr>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_routing> TO <lv_posnr>.
    IF <lv_ordty> IS ASSIGNED. UNASSIGN <lv_ordty>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_routing> TO <lv_ordty>.
    IF <lv_matnr> IS ASSIGNED. UNASSIGN <lv_matnr>. ENDIF.
    ASSIGN COMPONENT lv_fname04 OF STRUCTURE <ls_routing> TO <lv_matnr>.
  END-OF-DEFINITION.

  CLEAR : pv_chk_err.
  REFRESH pt_2010[].

  go_grid_0201->get_selected_columns(
    IMPORTING
      et_index_columns = lt_column ).                " Cell IDs

  IF lt_column[] IS NOT INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '컬럼을 선택할 수 없습니다.'.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  go_grid_0201->get_selected_cells_id(
    IMPORTING
     et_cells = lt_cells ).                " Cell IDs

  IF 1 > lines( lt_cells ).
    MESSAGE s003 DISPLAY LIKE 'E' WITH '하나의 셀만 선택해야 합니다.'.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  LOOP AT lt_cells INTO DATA(ls_cells).
    READ TABLE gt_fieldcat_0201 INTO DATA(ls_fcat) INDEX ls_cells-col_id.
    IF sy-subrc EQ 0.

      SPLIT ls_fcat-fieldname AT  '_'  INTO TABLE DATA(lt_string).
      READ TABLE lt_string INTO DATA(ls_string) INDEX 2.
      lv_chart = ls_string.

      IF NOT line_exists( gt_seq_routing[ chart = lv_chart ] ).
        MESSAGE s003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'.
        pv_chk_err = abap_true.
        EXIT.
      ENDIF.
    ENDIF.

    READ TABLE lt_string INTO ls_string INDEX 1.
    lv_seqno = ls_string + 0.
    READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY chart = lv_chart
                                                                 seqno = lv_seqno.
    IF ls_seq_routing-mtart = 'MCFE'.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '제품 Pegging은 변경 할 수 없습니다.'.
      pv_chk_err = abap_true.
      EXIT.
    ENDIF.

    CLEAR gv_pagging_gong_cd.
*  선택된 필드의 오더정보 찾기
    READ TABLE <gt_main_201> ASSIGNING FIELD-SYMBOL(<ls_main_201>) INDEX ls_cells-row_id.
    IF sy-subrc EQ 0.
      __get_index_of_table.
      CLEAR lv_num.
      READ TABLE <gt_routing> ASSIGNING FIELD-SYMBOL(<ls_routing>) INDEX <lv_line_seq>.
      DO.
        ADD 1 TO lv_num.
        __set_field_name lv_num.
        __assign_field.
        IF <lv_ordty> = ls_seq_routing-chart AND <lv_matnr> = ls_seq_routing-matnr.
          gv_pagging_gong_cd = lv_chart.
          lt_2010[] = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = lv_chart
                                                              AND   ordnr = <lv_ordnr>
                                                              AND   ordty = 'PRD' )
                                                            ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).
        ENDIF.

        READ TABLE gt_2010 INTO DATA(ls_2010) WITH KEY ordnr = <lv_ordnr>
                                                       posnr = <lv_posnr>.
        IF sy-subrc EQ 0.
          IF ls_2010-check_jego IS NOT INITIAL OR ls_2010-chk_prd IS NOT INITIAL.
            MESSAGE s003 DISPLAY LIKE 'E' WITH '생산중인 이전 공정이 있어 진행할 수 없습니다.'.
            pv_chk_err = abap_true.
            EXIT.
          ENDIF.
        ENDIF.

        IF lv_num >= gv_line_jojang.
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.
  ENDLOOP.

  CHECK pv_chk_err IS INITIAL.

  pt_2010[] = lt_2010.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0240 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0240 OUTPUT.
  SET PF-STATUS '0240'.
  SET TITLEBAR '0240'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0240
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_object_grid_0240 .

  CREATE OBJECT go_contain_0240
    EXPORTING
      container_name              = 'GV_CONTAIN_0240'                " Name of the Screen CustCtrl Name to Link Container To
    EXCEPTIONS
      cntl_error                  = 1                " CNTL_ERROR
      cntl_system_error           = 2                " CNTL_SYSTEM_ERROR
      create_error                = 3                " CREATE_ERROR
      lifetime_error              = 4                " LIFETIME_ERROR
      lifetime_dynpro_dynpro_link = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.


  CREATE OBJECT go_grid_0240
    EXPORTING
      i_parent      = go_contain_0240
      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0240
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_grid_0240 .

  CLEAR gs_layout_0240.
  gs_layout_0240-cwidth_opt = abap_true.
  gs_layout_0240-no_rowins = abap_true.
  gs_layout_0240-no_rowmark   = 'X'.
  gs_layout_0240-sel_mode   = 'C'.
  gs_layout_0240-stylefname = 'CELLTAB'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0240
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0240 .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR2010TOP'
      i_internal_tabname     = 'GS_PEGGING'
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
      et_fieldcat_lvc = gt_fieldcat_0240[]
    TABLES
      it_data         = gt_pegging
    EXCEPTIONS
      OTHERS          = 1.


  IF NOT line_exists( gt_fieldcat_0240[ fieldname = 'CHECK' ] ).
    APPEND INITIAL LINE TO gt_fieldcat_0240 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    <ls_fcat>-fieldname = 'CHECK'.
    <ls_fcat>-col_pos = 1.
    <ls_fcat>-datatype = 'CHAR'.
    <ls_fcat>-dd_outlen = '1'.
  ENDIF.

  IF NOT line_exists( gt_fieldcat_0240[ fieldname = 'TYPES' ] ).
    APPEND INITIAL LINE TO gt_fieldcat_0240 ASSIGNING <ls_fcat>.
    <ls_fcat>-fieldname = 'TYPES'.
    <ls_fcat>-col_pos = 2.
    <ls_fcat>-datatype = 'CHAR'.
    <ls_fcat>-dd_outlen = '10'.
  ENDIF.



  LOOP AT gt_fieldcat_0240 ASSIGNING <ls_fcat>.
    CASE   <ls_fcat>-fieldname.
      WHEN 'CHECK'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '선택'.
        <ls_fcat>-just = 'C'.
        <ls_fcat>-checkbox = abap_true.
        <ls_fcat>-edit = abap_true.
      WHEN 'TYPES'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '유형'.
        <ls_fcat>-just = 'C'.
      WHEN 'PSMNG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '수량'.
        <ls_fcat>-just = 'R'.
      WHEN 'LABST'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '가용'.
        <ls_fcat>-just = 'R'.
      WHEN 'INSME'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '품질'.
        <ls_fcat>-just = 'R'.
      WHEN 'SPEME'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '보류'.
        <ls_fcat>-just = 'R'.
      WHEN 'MEINS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '단위'.
        <ls_fcat>-just = 'C'.
      WHEN 'CHARG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '배치번호'.
        <ls_fcat>-just = 'L'.
      WHEN 'MAKTX'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '자재내역'.
        <ls_fcat>-just = 'L'.
      WHEN 'AUFNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '오더번호'.
        <ls_fcat>-just = 'C'.
      WHEN 'POSNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '품목번호'.
        <ls_fcat>-just = 'C'.
      WHEN 'LGORT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '저장위치'.
        <ls_fcat>-just = 'C'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0240
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_cell_attribute_grid_0240 .

  DATA : lt_celltab TYPE lvc_t_styl.
  DATA : ls_celltab TYPE lvc_s_styl.

  LOOP AT gt_pegging ASSIGNING FIELD-SYMBOL(<ls_pegging>).
    REFRESH lt_celltab.
    CLEAR ls_celltab.
    ls_celltab-fieldname = 'TYPES'.
    ls_celltab-style = alv_style_color_int_group.
    INSERT ls_celltab INTO TABLE lt_celltab.

    <ls_pegging>-celltab = lt_celltab.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0240
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_of_toolbar_grid_0240 .

  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0240
        USING : cl_gui_alv_grid=>mc_fc_excl_all.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0240_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_grid_0240_display .

  CALL METHOD go_grid_0240->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0240
      it_toolbar_excluding = gt_exclude_0240
    CHANGING
      it_outtab            = gt_pegging
      it_fieldcatalog      = gt_fieldcat_0240.

* 인풋이벤트 추가
  CALL METHOD go_grid_0240->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CALL METHOD go_grid_0240->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHECKBOX_0240
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_checkbox_0240 .

  LOOP AT gt_pegging ASSIGNING FIELD-SYMBOL(<ls_pegging>).
    CLEAR <ls_pegging>-check.
  ENDLOOP.

  READ TABLE gt_pegging INTO DATA(ls_pegging) INDEX gv_chk_line.
  LOOP AT gt_pegging ASSIGNING <ls_pegging> WHERE aufnr = ls_pegging-aufnr.
    <ls_pegging>-check = gv_chk_value.
  ENDLOOP.

  PERFORM refresh_grid USING go_grid_0240.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MULTY_POSNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_multy_posnr .

  DATA : lt_2010 LIKE gt_2010.
  DATA : lt_2010_chk LIKE gt_2010.
  DATA : lt_2010_chk2 TYPE TABLE OF zgtppt2010.
  DATA : lo_routing TYPE REF TO zgtpp_cl_routing.
  DATA : lt_result TYPE bapi_order_return_tt.
  DATA : lv_chk_err.
  DATA : lv_chk_release.
  DATA : lv_auart TYPE aufart.
  DATA : lt_auart TYPE TABLE OF aufart.

  go_grid_0201->check_changed_data( ).

  PERFORM chk_set_multy_posnr TABLES lt_2010
                              CHANGING lv_chk_err.

* 해당 선택된 오더들의 오더타입 확인,
  SELECT a~chk_char, b~aufnr, b~auart
    FROM @lt_2010 AS a
    INNER JOIN aufk AS b ON b~aufnr = a~ordnr
    INTO TABLE @DATA(lt_auart_tmp).

  DATA(lt_chk_auart)  = lt_auart_tmp.
  SORT lt_chk_auart BY chk_char.
  DELETE ADJACENT DUPLICATES FROM lt_chk_auart COMPARING chk_char.

  LOOP AT lt_chk_auart INTO DATA(ls_chk_auart).
    REFRESH lt_auart.
    LOOP AT lt_auart_tmp INTO DATA(ls_auart) WHERE chk_char = ls_chk_auart-chk_char.
      lv_auart = ls_auart-auart.
      COLLECT lv_auart INTO lt_auart.
    ENDLOOP.

    IF lines( lt_auart ) NE 1.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '동일한 생산오더 유형으로만 복조장 구성할 수 있습니다.'.
      RETURN.
    ENDIF.

  ENDLOOP.

  IF lv_chk_err IS NOT INITIAL.
    RETURN.
  ENDIF.

  IF lt_2010[] IS INITIAL.
    RETURN.
  ENDIF.

  CLEAR gv_answer.
  PERFORM popup_to_confirm_step USING 'N'
    ' '
    '복조장 구성 진행합니다. 계속 진행 하시겠습니까?'
    '구성확인'.
  IF gv_answer NE 'J'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  lt_2010_chk = lt_2010[].
  SORT lt_2010_chk BY chk_char.
  DELETE ADJACENT DUPLICATES FROM lt_2010_chk COMPARING chk_char.

  CREATE OBJECT lo_routing
    EXPORTING
      it_seq_routing = gt_seq_routing
      iv_werks       = p_werks
      iv_grpnr       = gv_grpnr.

  REFRESH gt_del_disp.
* 복조장 구성시 구성문자별로 생성후 최종 저장
  LOOP AT lt_2010_chk INTO DATA(ls_2010_chk).
    REFRESH lt_2010_chk2.
    lt_2010_chk2 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( chk_char = ls_2010_chk-chk_char )
                                                            ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).
    REFRESH lt_result.
    CLEAR lv_chk_release.
    IF line_exists( gt_2010[ chk_char = ls_2010_chk-chk_char
                                   status = 'R' ] ) .
      lv_chk_release = abap_true.
    ENDIF.

    READ TABLE lt_auart_tmp INTO ls_auart WITH KEY chk_char = ls_2010_chk-chk_char.
    IF ls_auart-auart = 'RP01'.
      lv_auart = 'RP01'.
    ELSEIF ls_auart-auart = 'PL01'. "2026.04.14.zlsgpp5.SRM2604-05583.
      lv_auart = 'PL01'.
    ELSE.
      lv_auart = 'PP01'.
    ENDIF..


    lo_routing->proc_multy_order(
      EXPORTING
        it_2010   = lt_2010_chk2
        iv_auart       = lv_auart
        iv_chk_release = lv_chk_release
    RECEIVING
      rt_result =  lt_result ).               " Table Type for Structure BAPI_ORDER_RETURN

    IF lt_result[] IS INITIAL.
      APPEND INITIAL LINE TO gt_del_disp ASSIGNING FIELD-SYMBOL(<ls_del_disp>).
      <ls_del_disp>-status = icon_led_green.
      CONCATENATE '복조장 구성 문자 ' ls_2010_chk-chk_char '에 대해 완료하였습니다.' INTO <ls_del_disp>-message SEPARATED BY space.

    ELSE.
      APPEND INITIAL LINE TO gt_del_disp ASSIGNING <ls_del_disp>.
      <ls_del_disp>-status = icon_led_red.
      CONCATENATE '복조장 구성 문자 ' ls_2010_chk-chk_char '작업 중 오류 발생하였습니다.' INTO <ls_del_disp>-message SEPARATED BY space.
      LOOP AT lt_result INTO DATA(ls_err_order).
        APPEND INITIAL LINE TO gt_del_disp ASSIGNING <ls_del_disp>.
        <ls_del_disp>-status = icon_led_red.
        <ls_del_disp>-message = ls_err_order-message.
      ENDLOOP.
    ENDIF.

  ENDLOOP.


  lo_routing->set_chain_history( ).

*  변경정보 MES전송
  zgtpp_cl_routing=>send_chg_mes(
    iv_werks = p_werks           " 플랜트
    iv_spgcd = p_spgcd          " SPG 코드
    iv_grpnr = gv_grpnr ).    " 조장 구성표 번호

  gv_disp_set = 'A'.
  CALL SCREEN '0220' STARTING AT 10 5 ENDING AT 90 9.
  CLEAR gv_disp_set.
  PERFORM refresh_screen_201.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_SET_MULTY_POSNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM chk_set_multy_posnr  TABLES   pt_2010 STRUCTURE gs_2010
                                          CHANGING pv_chk_err.

  DATA : lt_2010 LIKE TABLE OF gs_2010.
  DATA : lt_2010_collect LIKE TABLE OF gs_2010.
  DATA : lt_2010_chk LIKE TABLE OF gs_2010. "입력된 숫자나 문자 기준으로 소트된 테이블
  DATA : lt_2010_chk2 LIKE TABLE OF gs_2010. " 각종 체크 대상들
  DATA : lo_routing TYPE REF TO zgtpp_cl_routing.



* 조장구성표 상세내역에서 입력된 숫자나 문자가 있을경우 복조장 구성이 가능한지 체크
  lt_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( chk_char IS NOT INITIAL ) ( CORRESPONDING #( wa_2010 ) ) ).

  lt_2010_chk = lt_2010[].
  SORT lt_2010_chk BY chk_char.
  DELETE ADJACENT DUPLICATES FROM lt_2010_chk COMPARING chk_char..

  LOOP AT lt_2010_chk INTO DATA(ls_2010_chk).
    REFRESH lt_2010_chk2.
    lt_2010_chk2 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( chk_char = ls_2010_chk-chk_char ) ( CORRESPONDING #( wa_2010 ) ) ).

*  복조장에 구성문자 입력시 복조장은 전부 같은 구성문자로 포함 되어야 한다.
    LOOP AT lt_2010_chk2 INTO DATA(ls_2010_chk2).
      LOOP AT lt_2010 INTO DATA(ls_2010) WHERE ordnr = ls_2010_chk2-ordnr
                                                               AND chk_char NE ls_2010_chk-chk_char.
        MESSAGE s003 DISPLAY LIKE 'E' WITH '복조장 구성이 잘못되었습니다. 구성 표시 값을 확인해 주세요.'.
        pv_chk_err = abap_true.
        RETURN.
      ENDLOOP.

      IF ls_2010_chk2-ordty NE 'PRD'.
        MESSAGE s003 DISPLAY LIKE 'E' WITH '생산오더 유형만 복조장 구성할 수 있습니다.'.
        pv_chk_err = abap_true.
        RETURN.
      ENDIF.

    ENDLOOP.

* 같은 문자가 없이 개별로 지정된 오더가 있으면 에러
    IF lines( lt_2010_chk2 ) = 1. "단독으로 존재한다면 복조장 구성을 할수 없음
      MESSAGE s003 DISPLAY LIKE 'E' WITH '복조장 구성이 잘못되었습니다. 구성 표시 값을 확인해 주세요.'.
      pv_chk_err = abap_true.
      RETURN.
    ENDIF.

*   같은 구분자로 정해진 복조장 구성 요소가 같은 공정에 있는지 확인
    SORT lt_2010_chk2 BY gong_cd matnr.
    DELETE ADJACENT DUPLICATES FROM lt_2010_chk2 COMPARING gong_cd matnr.
    IF lines( lt_2010_chk2 ) > 1. "공정코드가 다른값이 존재하면 에러
      MESSAGE s003 DISPLAY LIKE 'E' WITH '복조장 구성이 잘못되었습니다. 구성 표시 값을 확인해 주세요.'.
      pv_chk_err = abap_true.
      RETURN.
    ENDIF.

** 상위 오더가 판매오더인 MTO 오더는 복조장 구성을 할 수 없음 - 제외
*    IF LINE_EXISTS( LT_2010_CHK2[ DMORDTY = 'SO' ] ).
*      MESSAGE S003 DISPLAY LIKE 'E' WITH 'MTO 오더는 복조장 구성 할 수 없습니다.'.
*      PV_CHK_ERR = ABAP_TRUE.
*      RETURN.
*    ENDIF.

* 쉬스공정 이후 공정으로 판매오더가 아닐경우.
* 이후공정 자재의 봄수량 체크하여 하위자재 수량이 1건이 아닐경우 제외
    IF ls_2010_chk-gong_cd = 'SHE' AND ls_2010_chk-dmordty NE 'SO'.
      PERFORM chk_num_idnrk USING ls_2010_chk-matnr CHANGING pv_chk_err.
      IF pv_chk_err = abap_true.
        MESSAGE s005 DISPLAY LIKE 'E' WITH '쉬스가 이후 공정에 복수 Core로 구성되어 있습니다.'.
        RETURN.
      ENDIF.

    ENDIF.

*  같은 레벨의 공정이 이전 공정에 존재할 경우
    READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY chart = ls_2010-gong_cd
                                                                 matnr = ls_2010-matnr.

    LOOP AT gt_seq_routing INTO DATA(ls_chk_routing) WHERE seqno > ls_seq_routing-seqno.
      IF ls_chk_routing-stufe = ls_seq_routing-stufe.
        MESSAGE s005 DISPLAY LIKE 'E' WITH '쉬스가 이후 공정에 복수 Core로 구성되어 있습니다.'.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDLOOP.

  DATA : lt_2010_orign TYPE TABLE OF zgtppt2010.
  DATA : lt_2010_pre TYPE TABLE OF zgtppt2010.
  DATA : lv_string TYPE string.

  LOOP AT lt_2010 INTO ls_2010.
    IF NOT ( ls_2010-chk_prd IS INITIAL AND ls_2010-check_jego IS INITIAL ).
      READ TABLE gt_seq_routing INTO ls_seq_routing WITH KEY chart = ls_2010-gong_cd
                                                             matnr = ls_2010-matnr.
      CLEAR lv_string.
      lv_string = '(' && ls_seq_routing-chart_val && ')'.

      MESSAGE s006 DISPLAY LIKE 'E' WITH lv_string ls_2010-ordnr '오더는 생산 진행중으로 복조장 구성할 수 없습니다.'.
      pv_chk_err = abap_true.
      RETURN.
    ENDIF.

    APPEND INITIAL LINE TO lt_2010_orign ASSIGNING FIELD-SYMBOL(<ls_2010_orign>).
    MOVE-CORRESPONDING ls_2010 TO <ls_2010_orign>.
  ENDLOOP.

* 선택된 공정의 이전 공정들에 대해 조회 후
  CREATE OBJECT lo_routing.

  lo_routing->get_chain_data(
    EXPORTING
      it_data      = lt_2010_orign
    IMPORTING
      et_pre_data  = lt_2010_pre ).

  LOOP AT lt_2010_pre INTO DATA(ls_2010_pre).
    CLEAR gs_2010.
    READ TABLE gt_2010 INTO gs_2010 WITH KEY gong_cd = ls_2010_pre-gong_cd
                                             ordnr = ls_2010_pre-ordnr
                                             posnr = ls_2010_pre-posnr
                                             ordty = ls_2010_pre-ordty.
    IF sy-subrc EQ 0.
      IF NOT ( gs_2010-chk_prd IS INITIAL AND gs_2010-check_jego IS INITIAL ).
        READ TABLE gt_seq_routing INTO ls_seq_routing WITH KEY chart = gs_2010-gong_cd.
        CLEAR lv_string.
        lv_string = '(' && ls_seq_routing-chart_val && ')'.

        MESSAGE s006 DISPLAY LIKE 'E' WITH lv_string gs_2010-ordnr '오더는 생산 진행중으로 복조장 구성할 수 없습니다.'.
        pv_chk_err = abap_true.
        RETURN.
      ENDIF.

      IF gs_2010-chk_char IS NOT INITIAL.
        CLEAR lv_string.
        lv_string = '(' && ls_seq_routing-chart_val && ')'.

        MESSAGE s006 DISPLAY LIKE 'E' WITH lv_string gs_2010-ordnr '이후공정 복조장 구성 이후 복조장 구성할 수 있습니다.'.
        pv_chk_err = abap_true.
        RETURN.
      ENDIF.
    ENDIF.

  ENDLOOP.

  pt_2010[] = lt_2010[].


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_SEPERATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_seperate .

  DATA : lt_2010 TYPE TABLE OF zgtppt2010.
  DATA : lo_routing TYPE REF TO zgtpp_cl_routing.
  DATA : lt_result TYPE bapi_order_return_tt.
  DATA : lv_chk_err.
  DATA : lv_idx TYPE i.
  DATA : lv_idx_c(10) TYPE c.
  DATA : lv_message(100).
  DATA : lv_auart TYPE aufart.


* 1) 선택데이터 확인.
  PERFORM chk_process_seperate TABLES lt_2010
                               CHANGING lv_chk_err.
  IF lv_chk_err IS NOT INITIAL.
    RETURN.
  ENDIF.

* 2) 확인메시지
  CLEAR gv_answer.
  PERFORM popup_to_confirm_step USING 'N'
    ' '
    '개별오더전환 진행합니다. 계속 진행 하시겠습니까?'
    '작업확인'.
  IF gv_answer NE 'J'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.


* 3) 해당 선택된 오더들의 오더타입 확인,
*/s 2026.04.15.zlsgpp5.CHM2604-00316. 메소드안에서 각 개별 오더유형을
*                       결정하기 때문에 로직이 필요없음. 주석처리.
*  SELECT b~aufnr, b~auart
*    FROM @lt_2010 AS a
*    INNER JOIN aufk AS b ON b~aufnr = a~ordnr
*    INTO TABLE @DATA(lt_chk_auart).
*
*  SORT lt_chk_auart BY aufnr auart.
*  DELETE ADJACENT DUPLICATES FROM lt_chk_auart COMPARING aufnr auart.
*
*  READ TABLE lt_chk_auart INTO DATA(ls_chk_auart) INDEX 1.
*  IF ls_chk_auart-auart = 'RP01'.
*    lv_auart = 'RP01'.
*  ELSEIF ls_chk_auart-auart = 'PL01'."2026.04.14.zlsgpp5.SRM2604-05583.
*    lv_auart = 'PL01'.
*  ELSE.
*    lv_auart = 'PP01'.
*  ENDIF.
*/e 2026.04.15.zlsgpp5.CHM2604-00316.


* 4) 메소드 실행.
  CREATE OBJECT lo_routing
    EXPORTING
      it_seq_routing = gt_seq_routing
      iv_werks       = p_werks
      iv_auart       = lv_auart
      iv_grpnr       = gv_grpnr.

  REFRESH lt_result.
  lt_result = lo_routing->process_seperate(
    EXPORTING
      it_2010   = lt_2010 ).


* 5) 결과 처리.
  REFRESH gt_del_disp.
  IF lt_result[] IS INITIAL.
    lv_idx = lines( lo_routing->mt_2020_save ) - lines( lt_2010 ).
    lv_idx_c = lv_idx.
    CONDENSE lv_idx_c.
    lv_message = lv_idx_c && '건의 개별 오더로 전환 되었습니다.'(m01).
    MESSAGE s003 WITH lv_message.

    lo_routing->set_chain_history( ).

*  변경정보 MES전송
    zgtpp_cl_routing=>send_chg_mes(
      iv_werks = p_werks            " 플랜트
      iv_spgcd = p_spgcd            " SPG 코드
      iv_grpnr = gv_grpnr ).        " 조장 구성표 번호

  ELSE.
    APPEND INITIAL LINE TO gt_del_disp ASSIGNING FIELD-SYMBOL(<ls_del_disp>).
    READ TABLE lt_2010 INTO DATA(ls_2010) INDEX 1.
    <ls_del_disp>-status = icon_led_red.
    CONCATENATE '복조장 오더' ls_2010-ordnr '개별 오더 전환 중 오류 발생하였습니다.' INTO <ls_del_disp>-message SEPARATED BY space.
    LOOP AT lt_result INTO DATA(ls_err_order).
      APPEND INITIAL LINE TO gt_del_disp ASSIGNING <ls_del_disp>.
      <ls_del_disp>-status = icon_led_red.
      <ls_del_disp>-message = ls_err_order-message.
    ENDLOOP.

    gv_disp_set = abap_true.
    CALL SCREEN '0220' STARTING AT 10 5 ENDING AT 90 9.
    CLEAR gv_disp_set.
  ENDIF.

* 데이터 갱신.
  PERFORM refresh_screen_201.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_PROCESS_SEPERATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM chk_process_seperate  TABLES   pt_2010 STRUCTURE zgtppt2010
                           CHANGING pv_chk_err.

  DATA : lt_column TYPE lvc_t_col.
  DATA : lt_cells TYPE lvc_t_ceno.
  DATA : lv_num(2) TYPE n.
  DATA : lt_2010 TYPE TABLE OF zgtppt2010.
  DATA : lo_routing TYPE REF TO zgtpp_cl_routing.
  DATA : lt_2010_orign LIKE TABLE OF gs_2010.
  DATA : lt_input TYPE TABLE OF zgtppt2010.
  DATA : lt_2010_pre TYPE TABLE OF zgtppt2010.
  DATA : lv_string TYPE string.
  DATA : lv_chart TYPE atwrt.
  DATA : lv_seqno TYPE i.

  FIELD-SYMBOLS <lv_line_seq> TYPE any.
  FIELD-SYMBOLS <lv_ordnr> TYPE any.
  FIELD-SYMBOLS <lv_posnr> TYPE any.
  FIELD-SYMBOLS <lv_ordty> TYPE any.
  FIELD-SYMBOLS <lv_matnr> TYPE any.

  DATA : lv_fname01 TYPE fieldname. "오더넘버
  DATA : lv_fname02 TYPE fieldname. " 품목번호
  DATA : lv_fname03 TYPE fieldname. " 오더타입
  DATA : lv_fname04 TYPE fieldname. "

  DEFINE __get_index_of_table.
    IF <lv_line_seq> IS ASSIGNED. UNASSIGN <lv_line_seq>. ENDIF.
    ASSIGN COMPONENT 'LINE_SEQ' OF STRUCTURE <ls_main_201> TO <lv_line_seq>.
  END-OF-DEFINITION.

  DEFINE __set_field_name.
    CLEAR : lv_fname01, lv_fname02, lv_fname03.
    lv_fname01 = &1 && '_ORDNR'.
    lv_fname02 = &1 && '_POSNR'.
    lv_fname03 = &1 && '_ORDTY'.
    lv_fname04 = &1 && '_MATNR'.
  END-OF-DEFINITION.

  DEFINE __assign_field.
    IF <lv_ordnr> IS ASSIGNED. UNASSIGN <lv_ordnr>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_routing> TO <lv_ordnr>.
    IF <lv_posnr> IS ASSIGNED. UNASSIGN <lv_posnr>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_routing> TO <lv_posnr>.
    IF <lv_ordty> IS ASSIGNED. UNASSIGN <lv_ordty>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_routing> TO <lv_ordty>.
    IF <lv_matnr> IS ASSIGNED. UNASSIGN <lv_matnr>. ENDIF.
    ASSIGN COMPONENT lv_fname04 OF STRUCTURE <ls_routing> TO <lv_matnr>.
  END-OF-DEFINITION.

  CLEAR : pv_chk_err.
  REFRESH pt_2010[].

  go_grid_0201->get_selected_columns(
    IMPORTING
      et_index_columns = lt_column ).                " Cell IDs

  IF lt_column[] IS NOT INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '컬럼을 선택할 수 없습니다.'.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  go_grid_0201->get_selected_cells_id(
    IMPORTING
     et_cells = lt_cells ).                " Cell IDs

  IF 1 > lines( lt_cells ).
    MESSAGE s003 DISPLAY LIKE 'E' WITH '하나의 셀만 선택해야 합니다.'.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.


  LOOP AT lt_cells INTO DATA(ls_cells).
    READ TABLE gt_fieldcat_0201 INTO DATA(ls_fcat) INDEX ls_cells-col_id.
    IF sy-subrc EQ 0.

      SPLIT ls_fcat-fieldname AT  '_'  INTO TABLE DATA(lt_string).
      READ TABLE lt_string INTO DATA(ls_string) INDEX 2.
      lv_chart = ls_string.

      IF NOT line_exists( gt_seq_routing[ chart = lv_chart ] ).
        MESSAGE s003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'.
        pv_chk_err = abap_true.
        EXIT.
      ENDIF.
    ENDIF.

    READ TABLE lt_string INTO ls_string INDEX 1.
    lv_seqno = ls_string + 0.
    READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY chart = lv_chart
                                                                 seqno = lv_seqno.

*  선택된 필드의 오더정보 찾기
    READ TABLE <gt_main_201> ASSIGNING FIELD-SYMBOL(<ls_main_201>) INDEX ls_cells-row_id.
    IF sy-subrc EQ 0.
      __get_index_of_table.
      CLEAR lv_num.
      READ TABLE <gt_routing> ASSIGNING FIELD-SYMBOL(<ls_routing>) INDEX <lv_line_seq>.
      DO.
        ADD 1 TO lv_num.
        __set_field_name lv_num.
        __assign_field.

        IF <lv_ordty> = ls_seq_routing-chart AND <lv_matnr> = ls_seq_routing-matnr.
          REFRESH lt_2010.
          lt_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = ls_seq_routing-chart
                                                            AND ordnr = <lv_ordnr>
                                                            AND matnr = ls_seq_routing-matnr
                                                            AND check_jego IS INITIAL )
                                                    ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).
          IF lt_2010[] IS INITIAL.
            lt_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = ls_seq_routing-chart
                                                              AND ordnr = <lv_ordnr>
                                                              AND check_jego IS INITIAL )
                                                      ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).
          ENDIF.

          APPEND LINES OF lt_2010 TO pt_2010. "2026.04.15.zlsgpp5.CHM2604-00316.
          EXIT.
        ENDIF.

        IF lv_num >= gv_line_jojang.
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.
  ENDLOOP.

*/s 2026.04.15.zlsgpp5.CHM2604-00316.복조장 및 Pegging 제한 해제.선택한 모든 오더 전환.
  DATA(lt_gong_cd) = pt_2010[].
  SORT lt_gong_cd BY gong_cd.
  DELETE ADJACENT DUPLICATES FROM lt_gong_cd COMPARING gong_cd.
  IF lines( lt_gong_cd ) > 1.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '복조장의 개별오더전환은 한 개의 공정만 가능합니다.'.
    pv_chk_err = abap_true.
    EXIT.
  ENDIF.

  "오더별 중복제거
  SORT pt_2010 BY ordnr.
  DELETE ADJACENT DUPLICATES FROM pt_2010 COMPARING ordnr.

  CLEAR: lt_2010.
*  READ TABLE lt_2010 INTO DATA(ls_2010) INDEX 1.
*/e 2026.04.15.zlsgpp5.CHM2604-00316.

  LOOP AT pt_2010 INTO DATA(ls_2010). "2026.04.15.zlsgpp5.CHM2604-00316.

    SELECT b~aufnr, b~posnr
      FROM aufk AS a
      INNER JOIN afpo AS b  ON b~aufnr = a~aufnr
      INTO TABLE @DATA(lt_afpo)
     WHERE a~aufnr = @ls_2010-ordnr
       AND a~flg_mltps = 'X'. " 복수품목

    IF lines( lt_afpo ) > 1. "선택된 오더의 품목이 여러개일시 복조장,
    ELSE.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '복조장 구성 오더가 아닙니다.'.
      pv_chk_err = abap_true.
      EXIT.
    ENDIF.

* 선택된 공정의 이전 공정들에 대해 조회 후
    CREATE OBJECT lo_routing.

    lt_2010_orign = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( ordnr = ls_2010-ordnr )
                                                    ( CORRESPONDING #( wa_2010 ) ) ).

    MOVE-CORRESPONDING lt_2010_orign TO lt_input.

    lo_routing->get_chain_data(
      EXPORTING
        it_data      = lt_input
      IMPORTING
        et_pre_data  = lt_2010_pre ).

* 선택된 공정에
    LOOP AT lt_2010_orign INTO DATA(ls_2010_orign).
      IF NOT ( ls_2010_orign-chk_prd IS INITIAL AND ls_2010_orign-check_jego IS INITIAL ).
        READ TABLE gt_seq_routing INTO ls_seq_routing WITH KEY matnr = ls_2010_orign-matnr.
        CLEAR lv_string.
        lv_string = '(' && ls_seq_routing-chart_val && ')'.

        MESSAGE s006 DISPLAY LIKE 'E' WITH lv_string ls_2010_orign-ordnr '오더는 생산 진행중으로 개별오더전환을 할 수 없습니다.'.
        pv_chk_err = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_2010_pre INTO DATA(ls_2010_pre).
      CLEAR gs_2010.
      READ TABLE gt_2010 INTO gs_2010 WITH KEY gong_cd = ls_2010_pre-gong_cd
                                               ordnr = ls_2010_pre-ordnr
                                               posnr = ls_2010_pre-posnr
                                               ordty = ls_2010_pre-ordty.
      IF sy-subrc EQ 0.
        IF NOT ( gs_2010-chk_prd IS INITIAL AND gs_2010-check_jego IS INITIAL ).
          READ TABLE gt_seq_routing INTO ls_seq_routing WITH KEY chart = gs_2010-gong_cd.
          CLEAR lv_string.
          lv_string = '(' && ls_seq_routing-chart_val && ')'.

          MESSAGE s006 DISPLAY LIKE 'E' WITH lv_string gs_2010-ordnr '오더는 생산 진행중으로 개별오더전환을 할 수 없습니다.'.
          pv_chk_err = abap_true.
          RETURN.
        ENDIF.

      ENDIF.

    ENDLOOP.

*    pt_2010[] = lt_input.                "2026.04.15.zlsgpp5.CHM2604-00316.
    APPEND LINES OF lt_input TO lt_2010.  "2026.04.15.zlsgpp5.CHM2604-00316.

  ENDLOOP.

  pt_2010[] = lt_2010.          "2026.04.15.zlsgpp5.CHM2604-00316.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_UNPEGGING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_unpegging .

  DATA : lt_2010 TYPE TABLE OF zgtppt2010.
  DATA : lt_2010_dev TYPE TABLE OF zgtppt2010.
  DATA : lv_chk_err.
  DATA : lo_routing TYPE REF TO zgtpp_cl_routing.

  PERFORM chk_proc_unpegging  TABLES lt_2010 lt_2010_dev
                              CHANGING lv_chk_err.

  IF lv_chk_err IS NOT INITIAL.
    RETURN.
  ENDIF.

  IF lt_2010[] IS INITIAL.
    RETURN.
  ENDIF.

  IF lv_chk_err IS NOT INITIAL.
    RETURN.
  ENDIF.

  CLEAR gv_answer.
  PERFORM popup_to_confirm_step USING 'N'
    ' '
    '재고 Pegging 삭제 진행합니다. 계속 진행 하시겠습니까?'
    '작업확인'.
  IF gv_answer NE 'J'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_routing
    EXPORTING
      iv_grpnr = gv_grpnr.

  IF lt_2010[] IS NOT INITIAL.
    DELETE zgtppt2010 FROM TABLE lt_2010.
    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

  IF lt_2010_dev[] IS NOT INITIAL.
    MODIFY zgtppt2010 FROM TABLE lt_2010_dev.
    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.


  lo_routing->set_chain_history( ).

*  변경정보 MES전송
  zgtpp_cl_routing=>send_chg_mes(
    iv_werks = p_werks           " 플랜트
    iv_spgcd = p_spgcd          " SPG 코드
    iv_grpnr = gv_grpnr ).    " 조장 구성표 번호

  PERFORM refresh_screen_201.

  MESSAGE s003 WITH '재고 Pegging 삭제 완료하였습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_PROC_UNPEGGING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM chk_proc_unpegging  TABLES   pt_2010 STRUCTURE zgtppt2010
                                  pt_2010_dev STRUCTURE zgtppt2010
                         CHANGING pv_chk_err.

  DATA : lt_column TYPE lvc_t_col.
  DATA : lt_cells TYPE lvc_t_ceno.
  DATA : lv_num(2) TYPE n.
  DATA : lo_routing TYPE REF TO zgtpp_cl_routing.
  DATA : lv_chart TYPE atwrt.
  DATA : lv_seqno TYPE i.
  DATA : lt_chk_2010 LIKE gt_2010.

  FIELD-SYMBOLS <lv_line_seq> TYPE any.
  FIELD-SYMBOLS <lv_ordnr> TYPE any.
  FIELD-SYMBOLS <lv_posnr> TYPE any.
  FIELD-SYMBOLS <lv_ordty> TYPE any.
  FIELD-SYMBOLS <lv_matnr> TYPE any.

  DATA : lv_fname01 TYPE fieldname. "오더넘버
  DATA : lv_fname02 TYPE fieldname. " 품목번호
  DATA : lv_fname03 TYPE fieldname. " 오더타입
  DATA : lv_fname04 TYPE fieldname. "

  DEFINE __get_index_of_table.
    IF <lv_line_seq> IS ASSIGNED. UNASSIGN <lv_line_seq>. ENDIF.
    ASSIGN COMPONENT 'LINE_SEQ' OF STRUCTURE <ls_main_201> TO <lv_line_seq>.
  END-OF-DEFINITION.

  DEFINE __set_field_name.
    CLEAR : lv_fname01, lv_fname02, lv_fname03.
    lv_fname01 = &1 && '_ORDNR'.
    lv_fname02 = &1 && '_POSNR'.
    lv_fname03 = &1 && '_ORDTY'.
    lv_fname04 = &1 && '_MATNR'.
  END-OF-DEFINITION.

  DEFINE __assign_field.
    IF <lv_ordnr> IS ASSIGNED. UNASSIGN <lv_ordnr>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_routing> TO <lv_ordnr>.
    IF <lv_posnr> IS ASSIGNED. UNASSIGN <lv_posnr>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_routing> TO <lv_posnr>.
    IF <lv_ordty> IS ASSIGNED. UNASSIGN <lv_ordty>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_routing> TO <lv_ordty>.
    IF <lv_matnr> IS ASSIGNED. UNASSIGN <lv_matnr>. ENDIF.
    ASSIGN COMPONENT lv_fname04 OF STRUCTURE <ls_routing> TO <lv_matnr>.
  END-OF-DEFINITION.

  CLEAR : pv_chk_err.
  REFRESH pt_2010[].

  go_grid_0201->get_selected_columns(
    IMPORTING
      et_index_columns = lt_column ).                " Cell IDs

  IF lt_column[] IS NOT INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '컬럼을 선택할 수 없습니다.'.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  go_grid_0201->get_selected_cells_id(
    IMPORTING
     et_cells = lt_cells ).                " Cell IDs

  IF 1 > lines( lt_cells ).
    MESSAGE s003 DISPLAY LIKE 'E' WITH '하나의 셀만 선택해야 합니다.'.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  LOOP AT lt_cells INTO DATA(ls_cells).
    READ TABLE gt_fieldcat_0201 INTO DATA(ls_fcat) INDEX ls_cells-col_id.
    IF sy-subrc EQ 0.
      SPLIT ls_fcat-fieldname AT  '_'  INTO TABLE DATA(lt_string).
      READ TABLE lt_string INTO DATA(ls_string) INDEX 2.
      lv_chart = ls_string.

      IF NOT line_exists( gt_seq_routing[ chart = lv_chart ] ).
        MESSAGE s003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'.
        pv_chk_err = abap_true.
        EXIT.
      ENDIF.
    ENDIF.

    READ TABLE lt_string INTO ls_string INDEX 1.
    lv_seqno = ls_string + 0.
    READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY chart = lv_chart
                                                                 seqno = lv_seqno.
*    IF LS_SEQ_ROUTING-MTART = 'MCFE'.
*      MESSAGE S003 DISPLAY LIKE 'E' WITH '제품 Pegging은 변경 할 수 없습니다.'.
*      PV_CHK_ERR = ABAP_TRUE.
*      EXIT.
*    ENDIF.


*  선택된 필드의 오더정보 찾기
    READ TABLE <gt_main_201> ASSIGNING FIELD-SYMBOL(<ls_main_201>) INDEX ls_cells-row_id.
    IF sy-subrc EQ 0.
      __get_index_of_table.
      CLEAR lv_num.
      READ TABLE <gt_routing> ASSIGNING FIELD-SYMBOL(<ls_routing>) INDEX <lv_line_seq>.
      DO.
        ADD 1 TO lv_num.
        __set_field_name lv_num.
        __assign_field.
        IF <lv_ordty> = ls_seq_routing-chart AND <lv_matnr> = ls_seq_routing-matnr.
          READ TABLE gt_2010 INTO DATA(ls_2010) WITH KEY gong_cd = ls_seq_routing-chart
                                                         ordnr = <lv_ordnr>.
          IF sy-subrc EQ 0.
            EXIT.
          ENDIF.
        ENDIF.

        IF lv_num >= gv_line_jojang.
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.
  ENDLOOP.

  CHECK ls_2010 IS NOT INITIAL.

  lt_chk_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = ls_2010-gong_cd AND ordnr = ls_2010-ordnr )
                                                ( CORRESPONDING #( wa_2010 ) ) ).

  LOOP AT lt_chk_2010 INTO ls_2010.

* 정합성 확인
* 재고 여부 확인
    IF ls_2010-check_jego IS INITIAL.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '재고 상태인 오더만 삭제 가능합니다.'.
      pv_chk_err = abap_true.
      RETURN.
    ENDIF.
* 이후공정 상태 확인 작업 진행중이면 삭제 불가
    READ TABLE gt_2010 INTO DATA(ls_2010_dev) WITH KEY ordnr = ls_2010-dmord
                                                       posnr = ls_2010-dmline
                                                       ordty = ls_2010-dmordty.

    IF ls_2010_dev-chk_prd = abap_true.
*/s 2026.04.15.zlsgpp5.CHM2604-00316.복조장 및 Pegging 제한 해제.
*      MESSAGE s003 DISPLAY LIKE 'E' WITH '이후 공정 작업 진행중으로 삭제 불가능합니다.'.
*      pv_chk_err = abap_true.
*      RETURN.
*/e 2026.04.15.zlsgpp5.CHM2604-00316.
    ENDIF.

* 선택된 공정의 이전 공정들에 대해 조회 후
    CREATE OBJECT lo_routing.

    DATA : lt_input TYPE TABLE OF zgtppt2010.
    DATA : lt_2010_pre TYPE TABLE OF zgtppt2010.
    APPEND INITIAL LINE TO lt_input ASSIGNING FIELD-SYMBOL(<ls_input>).
    MOVE-CORRESPONDING ls_2010 TO <ls_input>.

    lo_routing->get_chain_data(
      EXPORTING
        it_data      = lt_input
      IMPORTING
        et_pre_data  = lt_2010_pre
        et_dev_data  = pt_2010_dev[] ).

    APPEND LINES OF lt_input TO pt_2010.
    APPEND LINES OF lt_2010_pre TO pt_2010.
    APPEND LINES OF pt_2010_dev TO pt_2010.

* 이후 공정 체인데이터에서 이전 공정 연결 삭제
    LOOP AT pt_2010_dev ASSIGNING FIELD-SYMBOL(<ls_2010_dev>).
      CLEAR <ls_2010_dev>-reord.
      CLEAR <ls_2010_dev>-reline.
      CLEAR <ls_2010_dev>-reordty.
    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONTEXT_MENU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_OBJECT
*&---------------------------------------------------------------------*
FORM context_menu  USING    p_sender TYPE REF TO cl_gui_alv_grid
                                         p_object TYPE REF TO cl_ctmenu.

  DATA : lt_cells TYPE lvc_t_ceno.
  DATA : lv_num(2) TYPE n.
  DATA : lt_2010 TYPE TABLE OF zgtppt2010.
  DATA : lv_chart TYPE atwrt.
  DATA : lv_seqno TYPE i.

  FIELD-SYMBOLS <lv_line_seq> TYPE any.
  FIELD-SYMBOLS <lv_ordnr> TYPE any.
  FIELD-SYMBOLS <lv_posnr> TYPE any.
  FIELD-SYMBOLS <lv_ordty> TYPE any.
  FIELD-SYMBOLS <lv_matnr> TYPE any.

  DATA : lv_fname01 TYPE fieldname. "오더넘버
  DATA : lv_fname02 TYPE fieldname. " 품목번호
  DATA : lv_fname03 TYPE fieldname. " 오더타입
  DATA : lv_fname04 TYPE fieldname. " 오더타입

  DEFINE __get_index_of_table.
    IF <lv_line_seq> IS ASSIGNED. UNASSIGN <lv_line_seq>. ENDIF.
    ASSIGN COMPONENT 'LINE_SEQ' OF STRUCTURE <ls_main_201> TO <lv_line_seq>.
  END-OF-DEFINITION.

  DEFINE __set_field_name.
    CLEAR : lv_fname01, lv_fname02, lv_fname03.
    lv_fname01 = &1 && '_ORDNR'.
    lv_fname02 = &1 && '_POSNR'.
    lv_fname03 = &1 && '_ORDTY'.
    lv_fname04 = &1 && '_MATNR'.
  END-OF-DEFINITION.

  DEFINE __assign_field.
    IF <lv_ordnr> IS ASSIGNED. UNASSIGN <lv_ordnr>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_routing> TO <lv_ordnr>.
    IF <lv_posnr> IS ASSIGNED. UNASSIGN <lv_posnr>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_routing> TO <lv_posnr>.
    IF <lv_ordty> IS ASSIGNED. UNASSIGN <lv_ordty>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_routing> TO <lv_ordty>.
    IF <lv_matnr> IS ASSIGNED. UNASSIGN <lv_matnr>. ENDIF.
    ASSIGN COMPONENT lv_fname04 OF STRUCTURE <ls_routing> TO <lv_matnr>.
  END-OF-DEFINITION.

  DATA: lt_std_fcodes TYPE ui_functions,
        lt_own_fcodes TYPE ui_functions.
  DATA : lv_text TYPE gui_text.

  p_object->clear( ).

  CASE p_sender.
    WHEN go_grid_0201.

      go_grid_0201->get_selected_cells_id(
        IMPORTING
         et_cells = lt_cells ).                " Cell IDs

      LOOP AT lt_cells INTO DATA(ls_cells).
        READ TABLE gt_fieldcat_0201 INTO DATA(ls_fcat) INDEX ls_cells-col_id.
        IF sy-subrc EQ 0.
          SPLIT ls_fcat-fieldname AT  '_'  INTO TABLE DATA(lt_string).
          READ TABLE lt_string INTO DATA(ls_string) INDEX 2.
          lv_chart = ls_string.

          IF NOT line_exists( gt_seq_routing[ chart = lv_chart ] ).
            RETURN.
          ENDIF.
        ENDIF.

        READ TABLE lt_string INTO ls_string INDEX 1.
        lv_seqno = ls_string + 0.
        READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY chart = lv_chart
                                                                                                     seqno = lv_seqno.

*  선택된 필드의 오더정보 찾기
        READ TABLE <gt_main_201> ASSIGNING FIELD-SYMBOL(<ls_main_201>) INDEX ls_cells-row_id.
        IF sy-subrc EQ 0.
          __get_index_of_table.
          CLEAR lv_num.
          READ TABLE <gt_routing> ASSIGNING FIELD-SYMBOL(<ls_routing>) INDEX <lv_line_seq>.
          DO.
            ADD 1 TO lv_num.
            __set_field_name lv_num.
            __assign_field.
            IF <lv_ordty> = ls_seq_routing-chart AND <lv_matnr> = ls_seq_routing-matnr.
              lt_2010[] = VALUE #( FOR lw_2010 IN gt_2010 WHERE ( gong_cd = ls_seq_routing-chart
                                                                                   AND   ordnr = <lv_ordnr> )
                                                                ( CORRESPONDING zgtppt2010( lw_2010 ) ) ).
              EXIT.
            ENDIF.

            IF lv_num >= lines( gt_seq_routing ).
              EXIT.
            ENDIF.
          ENDDO.
        ENDIF.
      ENDLOOP.

      READ TABLE lt_2010 INTO DATA(ls_2010) INDEX 1.

      IF ls_2010-ordty EQ 'PRD'.
        SELECT SINGLE
         f~ktext
         FROM afko         AS a
         INNER JOIN afvc   AS b
                                 ON b~aufpl = a~aufpl
         INNER JOIN crtx   AS f
                                 ON f~objid = b~arbid
         WHERE a~aufnr = @ls_2010-ordnr
          AND b~aplfl = '000000'
          AND b~rueck <> '0000000000'
          AND f~spras = @sy-langu
          AND f~objty = 'A'
          INTO @DATA(lv_ktext).

        CHECK lv_ktext IS NOT INITIAL.
        lv_text = lv_ktext.
        CALL METHOD p_object->add_function
          EXPORTING
            fcode = 'AA'
            text  = lv_text.

        CALL METHOD p_object->show_functions
          EXPORTING
            fcodes = lt_own_fcodes.

        CALL METHOD cl_gui_cfw=>flush.
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEL_GRPNO
*&---------------------------------------------------------------------*
FORM del_grpno .

  DATA : BEGIN OF ls_chk_grpnr,
           grpnr TYPE zgtppt2000-grpnr,
         END OF ls_chk_grpnr.
  DATA : lt_chk_grpnr LIKE TABLE OF ls_chk_grpnr.

  DATA : lv_result  TYPE char01,
         lv_message TYPE char100,
         lv_chk_con TYPE char01.

* 선택된 조장번호 삭제
  lt_chk_grpnr = VALUE #( FOR wa_main_disp IN gt_main_disp WHERE ( check = abap_true ) ( grpnr = wa_main_disp-grpnr ) ).

  SORT lt_chk_grpnr.
  DELETE ADJACENT DUPLICATES FROM lt_chk_grpnr.

  IF lines( lt_chk_grpnr ) = 0.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '선택된 조장구성표 번호가 없습니다.'.
    RETURN.
  ENDIF.

  IF lines( lt_chk_grpnr ) > 1.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '하나의 조장구성표 번호만 선택 가능합니다.'.
    RETURN.
  ENDIF.

  PERFORM popup_to_confirm_step USING 'N'
    ' '
    '선택된 조장구성표 번호를 삭제하시겠습니까?'
    '삭제확인'.
  IF gv_answer NE 'J'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  SELECT COUNT(*)
    FROM zgtppt2010
    FOR ALL ENTRIES IN lt_chk_grpnr
   WHERE grpnr = lt_chk_grpnr-grpnr.
  IF sy-subrc = 0.
    MESSAGE s003 DISPLAY LIKE 'E'
                 WITH '조장 구성되어 오더 생성된 조장표는 삭제 할 수 없습니다.'.
    RETURN.
  ENDIF.

  LOOP AT lt_chk_grpnr INTO DATA(ls_grpnr).
    UPDATE zgtppt2000
       SET zstatus = 'D'
     WHERE grpnr = ls_grpnr.
    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
    ELSE.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF sy-subrc = 0.
    PERFORM get_proc.
    PERFORM refresh_grid USING go_grid_0100.

    MESSAGE s003 DISPLAY LIKE 'S'
                 WITH '조장구성표 삭제되었습니다.'.
  ELSE.
    PERFORM get_proc.
    PERFORM refresh_grid USING go_grid_0100.

    MESSAGE s003 DISPLAY LIKE 'E'
                 WITH '조장구성표 삭제 중 오류가 발생했습니다.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELD_CHART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_NUM
*&      --> <LV_ORDTY>
*&      <-- LV_CHART_NAME
*&---------------------------------------------------------------------*
FORM set_field_chart  USING     pv_num
                                pv_chart
                      CHANGING  pv_fieldname TYPE fieldname.

  DATA : lv_num(2) TYPE n.
  DATA : lv_num2(2) TYPE n.

  DATA(lt_seq_routing) = gt_seq_routing.
  SORT lt_seq_routing BY seqno.

  LOOP AT lt_seq_routing INTO DATA(ls_seq_routing).
    IF ls_seq_routing-maabc = 'B'.
      CONTINUE.
    ENDIF.
    ADD 1 TO lv_num.
    IF lv_num = pv_num AND ls_seq_routing-chart = pv_chart.
      lv_num2 = ls_seq_routing-seqno + 0.
      pv_fieldname = lv_num2 && '_' && ls_seq_routing-chart.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_SHE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SEQ_ROUTING_MATNR
*&      --> LS_SEQ_ROUTING_SEQNO
*&      <-- GV_CHK_SHE
*&---------------------------------------------------------------------*
FORM chk_she  USING    pv_matnr  TYPE matnr
                                   pv_seqno TYPE i
                  CHANGING    pv_chk_she.

  SELECT  a~matnr,
               c~idnrk
           FROM mast AS a
           INNER JOIN stko AS b
                                ON b~stlnr = a~stlnr
                               AND b~stlal = a~stlal
           INNER JOIN stpo AS c
                                ON c~stlnr = b~stlnr
                               AND c~stlty = b~stlty
          WHERE a~matnr IN ( SELECT itab~matnr
                                          FROM @gt_seq_routing AS itab
                                        WHERE seqno < @pv_seqno )
              AND a~werks  = @p_werks
              AND a~stlan = '1'
              AND a~stlal  = '01'
              AND b~stlty  = 'M'
              AND b~lkenz NE 'X'
              AND c~lkenz NE 'X'
              AND c~idnrk      = @pv_matnr
           INTO TABLE @DATA(lt_calcultab).

  IF lines( lt_calcultab ) > 1.
    pv_chk_she = abap_true.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_NUM_IDNRK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_2010_CHK_MATNR
*&      <-- PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM chk_num_idnrk  USING    pv_idnrk TYPE stpo-idnrk
                    CHANGING pv_chk_err.

  READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY matnr = pv_idnrk.

* 공정정보 조회
  SELECT  a~matnr,
         c~idnrk,
         c~/sapmp/met_lrch,  " 길이 계산 방법
         c~/sapmp/max_fertl,  " 최대생산 길이
         c~/sapmp/fix_as_j,       " 각길이
         c~/sapmp/fix_as_e,       " 첫번째 길이
         c~/sapmp/fix_as_l,        "최종길이
         c~/sapmp/rund_fakt      " 반올림 값
           FROM mast AS a
           INNER JOIN stko AS b
                                ON b~stlnr = a~stlnr
                               AND b~stlal = a~stlal
           INNER JOIN stpo AS c
                                ON c~stlnr = b~stlnr
                               AND c~stlty = b~stlty
          WHERE a~matnr IN ( SELECT itab~matnr
                                          FROM @gt_seq_routing AS itab
                                        WHERE seqno < @ls_seq_routing-seqno )
              AND a~werks  = @p_werks
              AND a~stlan = '1'
              AND a~stlal  = '01'
              AND b~stlty  = 'M'
              AND b~lkenz NE 'X'
              AND c~lkenz NE 'X'
              AND c~idnrk      = @pv_idnrk
           INTO TABLE @DATA(lt_calcultab).

  IF lines( lt_calcultab ) > 1.
    pv_chk_err = abap_true.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ALLSELECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_allselect .

  DATA : lt_col_table TYPE lvc_t_col.
  DATA : lv_num(2) TYPE n.
  DATA : lt_cell TYPE lvc_t_cell.
  DATA : lv_col_id TYPE i.
  DATA : ls_row_id TYPE lvc_s_row.
  DATA : ls_column_id TYPE lvc_s_col.

  lv_col_id = lines( gt_fieldcat_0201 ) .
  lv_col_id = lv_col_id - 1.
  ls_row_id-index = 1.
  READ TABLE gt_fieldcat_0201 INTO DATA(ls_fcat) INDEX lv_col_id.
  ls_column_id-fieldname = ls_fcat-fieldname.

  go_grid_0201->set_current_cell_via_id(
    is_row_id    =   ls_row_id               " Row
    is_column_id =  ls_column_id ).                " Column

  LOOP AT gt_seq_routing INTO DATA(ls_seq_routing).

    IF ls_seq_routing-maabc = 'B'.
      CONTINUE.
    ENDIF.

    APPEND INITIAL LINE TO lt_col_table ASSIGNING FIELD-SYMBOL(<ls_col_table>).
    lv_num = ls_seq_routing-seqno + 0.
    <ls_col_table>-fieldname = lv_num && '_' && ls_seq_routing-chart.

  ENDLOOP.

  go_grid_0201->set_selected_columns(
    it_col_table             =  lt_col_table                " Selected Columns
  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DESELECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_deselect .

  DATA : lt_col_table TYPE lvc_t_col.

  go_grid_0201->set_selected_columns(
    it_col_table             =  lt_col_table                " Selected Columns
  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_AVAILABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM check_available      USING pv_matnr
                                 CHANGING pv_check.

  DATA : lt_data TYPE REF TO data.
  DATA : lt_1010 TYPE TABLE OF zgtppt1010.
  DATA : lt_1010_source TYPE TABLE OF zgtppt1010.
  DATA : ls_1000_source TYPE zgtppt1000.
  DATA : lt_fcat TYPE lvc_t_fcat.
  DATA : lv_col_pos TYPE i.
  DATA : lv_sql TYPE string.
  DATA : lv_sql2 TYPE string.
  DATA : lv_fieldname TYPE fieldname.
  DATA : lv_fieldname2 TYPE fieldname.
  DATA : lv_matnr TYPE matnr.
  DATA : lv_num(2) TYPE n.
  DATA : lt_zgtcvmstval TYPE TABLE OF zgtcvmstval.
  FIELD-SYMBOLS : <lt_data> TYPE table.
  FIELD-SYMBOLS : <lv_value> TYPE any.

* 자재상태 체크
  SELECT SINGLE mmsta FROM marc
      INTO @DATA(lv_mmsta)
   WHERE matnr = @pv_matnr
       AND werks = @p_werks.
  IF lv_mmsta NE space.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input  = pv_matnr
      IMPORTING
        output = lv_matnr.

    MESSAGE s011 DISPLAY LIKE 'E' WITH lv_matnr lv_mmsta.
    RETURN.
  ENDIF.

* 라우팅 유효성 체크
  SELECT * FROM zgtppt1010
      INTO CORRESPONDING FIELDS OF TABLE lt_1010
  WHERE module_kind = 'PP'
      AND codegrp = '2021'.

  LOOP AT lt_1010 INTO DATA(ls_1010).
    ADD 1 TO lv_col_pos.
    APPEND INITIAL LINE TO lt_fcat ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    <ls_fcat>-fieldname = ls_1010-fld_03.
    <ls_fcat>-reptext = ls_1010-fld_01.
    <ls_fcat>-ref_table = ls_1010-fld_02.
    <ls_fcat>-ref_field = ls_1010-fld_03.
  ENDLOOP.

  ASSIGN lt_data->* TO <lt_data>.
  SELECT * FROM zgtcvmstval
    INTO CORRESPONDING FIELDS OF TABLE lt_zgtcvmstval
    WHERE werks = p_werks
       AND matnr = pv_matnr.


  SELECT SINGLE * FROM zgtppt1000
      INTO CORRESPONDING FIELDS OF ls_1000_source
   WHERE module_kind = 'PP'
       AND codegrp = '2020'.

  SELECT * FROM zgtppt1010
      INTO CORRESPONDING FIELDS OF TABLE lt_1010_source
   WHERE module_kind = 'PP'
       AND codegrp = '2020'.

  SORT lt_1010_source BY codeid.

  LOOP AT lt_1010_source INTO DATA(ls_source).
    CLEAR lv_sql.
    CLEAR lv_num.

    DO 10 TIMES.
      ADD 1 TO lv_num.
      CLEAR lv_fieldname.
      lv_fieldname = 'FLD_NAME_' && lv_num.

      READ TABLE lt_fcat ASSIGNING <ls_fcat> WITH KEY reptext = ls_1000_source-(lv_fieldname).
      IF sy-subrc EQ 0.
        lv_fieldname2 = 'FLD_' && lv_num.
        IF ls_source-(lv_fieldname2) IS INITIAL.
          EXIT.
        ENDIF.
        IF lv_sql IS NOT INITIAL.
          CONCATENATE lv_sql 'and' INTO lv_sql SEPARATED BY space.
        ENDIF.
        lv_sql2 = | { <ls_fcat>-fieldname } = '{ ls_source-(lv_fieldname2) }' |.
        CONCATENATE lv_sql lv_sql2 INTO lv_sql SEPARATED BY space.
      ELSE.
        EXIT.
      ENDIF.

    ENDDO.

    IF lv_sql IS NOT INITIAL.
      LOOP AT lt_zgtcvmstval INTO DATA(ls_zgtcvmstval) WHERE (lv_sql).
        IF ls_source-fld_02 = 'CST'.
          READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY matnr = pv_matnr.
          IF sy-subrc EQ 0.
            ls_seq_routing-stufe = ls_seq_routing-stufe - 1.
            READ TABLE gt_seq_routing TRANSPORTING NO FIELDS WITH KEY stufe = ls_seq_routing-stufe
                                                                                                        chart = 'UST'.
            IF sy-subrc EQ 0.
              pv_check = abap_true.
            ENDIF.
          ENDIF.
        ELSE.
          pv_check = abap_true.
        ENDIF.

      ENDLOOP.
    ENDIF.
  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STANDARD_ADLENGTH
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
FORM set_standard_adlength .

  DATA : lt_column TYPE lvc_t_col,
         lt_cells  TYPE lvc_t_ceno,
         lv_matnr  TYPE matnr.
  DATA : BEGIN OF ls_vbeln,
           vbeln TYPE vbeln_va,
           posnr TYPE posnr_va,
         END OF ls_vbeln.
  DATA : lt_vbeln LIKE TABLE OF ls_vbeln.
  DATA : lv_chart  TYPE atwrt,
         lv_seqno  TYPE i,
         lv_num(2) TYPE n.

  FIELD-SYMBOLS <lv_line_seq> TYPE any.
  FIELD-SYMBOLS <lv_ordnr> TYPE any.
  FIELD-SYMBOLS <lv_posnr> TYPE any.

  DATA : lv_fname01 TYPE fieldname. "오더넘버
  DATA : lv_fname02 TYPE fieldname. "품목번호

  DEFINE __get_index_of_table.
    IF <lv_line_seq> IS ASSIGNED. UNASSIGN <lv_line_seq>. ENDIF.
    ASSIGN COMPONENT 'LINE_SEQ' OF STRUCTURE <ls_main_201> TO <lv_line_seq>.
  END-OF-DEFINITION.

  DEFINE __set_field_name.
    CLEAR : lv_fname01, lv_fname02.
    lv_fname01 = &1 && '_ORDNR'.
    lv_fname02 = &1 && '_POSNR'.
  END-OF-DEFINITION.

  DEFINE __assign_field.
    IF <lv_ordnr> IS ASSIGNED. UNASSIGN <lv_ordnr>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_routing> TO <lv_ordnr>.
    IF <lv_posnr> IS ASSIGNED. UNASSIGN <lv_posnr>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_routing> TO <lv_posnr>.
  END-OF-DEFINITION.

  go_grid_0201->get_selected_columns(
    IMPORTING
      et_index_columns = lt_column ).                " Cell IDs

  CLEAR gs_standard_adlength.
  CLEAR gv_chk_all.

  IF lt_column[] IS NOT INITIAL.  "칼럼을 선택했을때

    gv_chk_all = abap_true.
    IF lines( lt_column ) > 1.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '하나의 공정만 선택 가능합니다.'.
      RETURN.
    ENDIF.

    LOOP AT lt_column INTO DATA(ls_column).
      SPLIT ls_column-fieldname AT  '_'  INTO TABLE DATA(lt_string).
      READ TABLE lt_string INTO DATA(ls_string) INDEX 2.
      lv_chart = ls_string.

      IF NOT line_exists( gt_seq_routing[ chart = lv_chart ] ).
        MESSAGE s003 DISPLAY LIKE 'E' WITH '공정이 아닌 컬럼이 선택되었습니다.'.
        RETURN.
      ENDIF.

      READ TABLE lt_string INTO ls_string INDEX 1.
      lv_seqno = ls_string + 0.
      READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY chart = lv_chart
                                                                   seqno = lv_seqno.
      gs_standard_adlength-matnr = ls_seq_routing-matnr.

      "기존 저장된 표준여장이 있으면 기존 여장 보여준다.
      SELECT SINGLE * FROM zgtppt2070
       WHERE grpnr = @gv_grpnr
         AND ordno = ' '
         AND ( posnr IS INITIAL OR posnr = '000000' )
         AND matnr = @ls_seq_routing-matnr
        INTO @DATA(ls_zgtppt2070).
      IF sy-subrc EQ 0.
        gs_standard_adlength-qlength = ls_zgtppt2070-qlength.
        gs_standard_adlength-clength = ls_zgtppt2070-clength.
      ENDIF.
    ENDLOOP.

  ELSE. "셀을 선택했을때
    go_grid_0201->get_selected_cells_id(
      IMPORTING
       et_cells = lt_cells ).                " Cell IDs

    LOOP AT lt_cells INTO DATA(ls_cells).
      READ TABLE gt_fieldcat_0201 INTO DATA(ls_fcat) INDEX ls_cells-col_id.
      IF sy-subrc EQ 0.

        SPLIT ls_fcat-fieldname AT  '_'  INTO TABLE lt_string.
        READ TABLE lt_string INTO ls_string INDEX 2.
        lv_chart = ls_string.

        IF NOT line_exists( gt_seq_routing[ chart = lv_chart ] ).
          MESSAGE s003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'.
          RETURN.
        ENDIF.
      ENDIF.

      READ TABLE lt_string INTO ls_string INDEX 1.
      lv_seqno = ls_string + 0.
      READ TABLE gt_seq_routing INTO ls_seq_routing WITH KEY chart = lv_chart
                                                             seqno = lv_seqno.

      IF gs_standard_adlength-matnr IS INITIAL.
        gs_standard_adlength-matnr = ls_seq_routing-matnr.
      ELSEIF gs_standard_adlength-matnr NE ls_seq_routing-matnr.
        MESSAGE s003 DISPLAY LIKE 'E' WITH '하나의 공정만 선택 가능합니다.'.
        RETURN.
      ENDIF.

      "선택된 필드의 판매오더정보 찾기
      READ TABLE <gt_main_201> ASSIGNING FIELD-SYMBOL(<ls_main_201>) INDEX ls_cells-row_id.
      IF sy-subrc EQ 0.
        __get_index_of_table.
        CLEAR lv_num.
        READ TABLE <gt_routing> ASSIGNING FIELD-SYMBOL(<ls_routing>) INDEX <lv_line_seq>.
        CLEAR lv_num.
        __set_field_name lv_num.
        __assign_field.
        APPEND INITIAL LINE TO lt_vbeln ASSIGNING FIELD-SYMBOL(<ls_vbeln>) .
        <ls_vbeln>-vbeln = <lv_ordnr>.
        <ls_vbeln>-posnr = <lv_posnr>.
      ENDIF.
    ENDLOOP.

    "동일 판매오더,품목만 선택할 수 있음.
    SORT lt_vbeln BY vbeln posnr.
    DELETE ADJACENT DUPLICATES FROM lt_vbeln COMPARING vbeln posnr.
    IF lines( lt_vbeln ) > 1.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '동일한 판매오더, 품목만 선택할 수 있습니다.'.
      RETURN.
    ENDIF.

    "기존 저장된 표준여장이 있으면 기존 여장 보여준다.
    READ TABLE lt_vbeln INTO ls_vbeln INDEX 1.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ls_vbeln-vbeln
      IMPORTING
        output = ls_vbeln-vbeln.

    gs_standard_adlength-vbeln = ls_vbeln-vbeln.
    gs_standard_adlength-posnr = ls_vbeln-posnr.
    READ TABLE gt_main_disp INTO DATA(ls_temp_data) WITH KEY grpnr = gv_grpnr
                                                             ordno = ls_vbeln-vbeln
                                                             posnr = ls_vbeln-posnr.
    IF sy-subrc EQ 0.
      gs_standard_adlength-inlength = ls_temp_data-inlength.
    ENDIF.

    "기존 저장된 표준여장이 있으면 기존 여장 보여준다.
    SELECT SINGLE * FROM zgtppt2070
      INTO ls_zgtppt2070
     WHERE grpnr = gv_grpnr
       AND ordno = ls_vbeln-vbeln
       AND posnr = ls_vbeln-posnr
       AND matnr = ls_seq_routing-matnr.
    IF sy-subrc EQ 0.
      gs_standard_adlength-qlength = ls_zgtppt2070-qlength.
      gs_standard_adlength-clength = ls_zgtppt2070-clength.
    ELSE.
      SELECT SINGLE * FROM zgtppt2070
       WHERE grpnr = @gv_grpnr
         AND ordno = ' '
         AND ( posnr IS INITIAL OR posnr = '000000' )
         AND matnr = @ls_seq_routing-matnr
        INTO @ls_zgtppt2070.
      IF sy-subrc EQ 0.
        gs_standard_adlength-qlength = ls_zgtppt2070-qlength.
        gs_standard_adlength-clength = ls_zgtppt2070-clength.
      ENDIF.
    ENDIF.

  ENDIF.

*__스크린 호출
  IF gv_chk_all IS INITIAL.
    CALL SCREEN '0250' STARTING AT 5 5 ENDING AT 76 12.
  ELSE.
    CALL SCREEN '0250' STARTING AT 5 5 ENDING AT 76 10.
  ENDIF.
  IF gs_standard_adlength IS INITIAL.
    RETURN.
  ENDIF.

*__표준여장 테이블 저장
  CLEAR ls_zgtppt2070.
  ls_zgtppt2070-grpnr = gv_grpnr.
  ls_zgtppt2070-ordno = gs_standard_adlength-vbeln.
  ls_zgtppt2070-posnr = gs_standard_adlength-posnr.
  ls_zgtppt2070-matnr = gs_standard_adlength-matnr.
  ls_zgtppt2070-qlength = gs_standard_adlength-qlength.
  ls_zgtppt2070-clength = gs_standard_adlength-clength.

  MODIFY zgtppt2070 FROM ls_zgtppt2070.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ENDIF.

*__메시지
  MESSAGE s003 WITH '표준여장이 변경되었습니다. 조장 구성표를 다시 작성하세요.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_BOM_COMPONENTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_bom_components .

  DATA : lv_err_chk.
  DATA : ls_seq_routing LIKE gs_seq_routing.
  DATA : lt_2010 TYPE TABLE OF zgtppt2010.
  DATA : lo_routing TYPE REF TO zgtpp_cl_routing.
  DATA : lt_2010_del TYPE TABLE OF zgtppt2010.
  DATA : lv_seqno TYPE i.
  DATA : lv_result    TYPE char01,
         lt_err_order TYPE bapi_order_return_tt.

  PERFORM check_exclude_bom CHANGING ls_seq_routing lv_err_chk.

  IF lv_err_chk IS NOT INITIAL.
    RETURN.
  ENDIF.

  CLEAR gv_answer.
  IF gt_2010[] IS NOT INITIAL.
    PERFORM popup_to_confirm_step USING 'N'
      ' '
      '공정이 제외되면 조장구성표 오더가 삭제 됩니다. 진행하시겠습니까?'
      'LC 공정 제외 확인'.
    IF gv_answer NE 'J'.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
      RETURN.
    ENDIF.
  ELSE.
    PERFORM popup_to_confirm_step USING 'N'
          ' '
          '공정이 제외됩니다. 진행하시겠습니까?'
          'LC 공정 제외 확인'.
    IF gv_answer NE 'J'.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

  TRY.
      UPDATE marc SET maabc = 'C'
        WHERE werks = p_werks
          AND matnr = ls_seq_routing-matnr.
      IF sy-subrc EQ 0.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
        MESSAGE s003 DISPLAY LIKE 'E' WITH 'LC 구성 삭제중 작업중 오류 발생하였습니다.'.
        RETURN.
      ENDIF.
    CATCH cx_root INTO DATA(lo_root).
      MESSAGE s003 DISPLAY LIKE 'E' WITH lo_root->get_text( ).
      RETURN.
  ENDTRY.

  IF gt_2010[] IS NOT INITIAL.
    lv_seqno = ls_seq_routing-seqno.
    DO.
      IF lv_seqno > gv_line_jojang.
        EXIT.
      ENDIF.

      READ TABLE gt_seq_routing INTO DATA(ls_temp) WITH KEY seqno = lv_seqno.
      REFRESH lt_2010.
      lt_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = ls_temp-chart
                                                                              AND matnr = ls_temp-matnr )
                                                            ( CORRESPONDING zgtppt2010( wa_2010 ) ) ).

      APPEND LINES OF lt_2010 TO lt_2010_del.

      CLEAR ls_temp.
      ADD 1 TO lv_seqno.

    ENDDO.

    SORT lt_2010_del BY ordnr posnr ordty.
    DELETE ADJACENT DUPLICATES FROM lt_2010_del COMPARING ordnr posnr ordty.

    IF lt_2010_del[] IS NOT INITIAL.

      CREATE OBJECT lo_routing
        EXPORTING
          iv_werks = p_werks
          iv_grpnr = gv_grpnr.

      lo_routing->delete_order(
        EXPORTING
          it_2010      = lt_2010_del
        IMPORTING
          ev_result    =  lv_result                " 길이 1의 문자 필드
          et_err_order =  lt_err_order                " Table for BAPI Orders
      ).

    ENDIF.

  ENDIF.

  PERFORM refresh_new_setting_201.

  MESSAGE s006 WITH 'LC 구성 ' ls_seq_routing-chart_val  '삭제 완료되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_EXCLUDE_BOM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ERR_CHK
*&---------------------------------------------------------------------*
FORM check_exclude_bom  CHANGING ps_seq_routing STRUCTURE gs_seq_routing
                                                       pv_chk_err.

  DATA : lt_column TYPE lvc_t_col.
  DATA : lv_chart TYPE atwrt.
  DATA : lv_seqno TYPE i.
  DATA : lt_2010 TYPE TABLE OF zgtppt2010.

  go_grid_0201->get_selected_columns(
  IMPORTING
    et_index_columns = lt_column ).                " Cell IDs

  IF lt_column[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '선택된 컬럼이 없습니다.'.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  IF lines( lt_column ) > 1.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '한개의 공정만 선택 가능합니다.'.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  READ TABLE lt_column INTO DATA(ls_column) INDEX 1.

  SPLIT ls_column-fieldname AT  '_'  INTO TABLE DATA(lt_string).
  READ TABLE lt_string INTO DATA(ls_string) INDEX 2.
  lv_chart = ls_string.

  IF NOT line_exists( gt_seq_routing[ chart = lv_chart ] ) OR lines( lt_string ) NE 2.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '공정이 아닌 컬럼이 선택되었습니다.'.
    pv_chk_err = abap_true.
    EXIT.
  ENDIF.
* 선택된 컬럼의 공정 유형 전부 추출
  READ TABLE lt_string INTO ls_string INDEX 1.
  lv_seqno = ls_string + 0.
  READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY chart = lv_chart
                                                                                                  seqno = lv_seqno.


  SELECT * FROM zgtppt2010
      INTO CORRESPONDING FIELDS OF TABLE lt_2010
    WHERE grpnr NE gv_grpnr
      AND gong_cd = lv_chart
      AND matnr = ls_seq_routing-matnr.
  IF sy-subrc EQ 0.
    MESSAGE s000 DISPLAY LIKE 'E' WITH '해당 자재의 같은 공정으로 작성된 조장 구성표가 존재합니다.'.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  IF line_exists( gt_2010[ chk_prd = 'X' ] ) OR
    line_exists( gt_2010[ check_jego = 'Q' ] ) OR
    line_exists( gt_2010[ check_jego = 'B' ] ).
    MESSAGE s000 DISPLAY LIKE 'E' WITH '생산중인 자재가 있어 LC 공정제외 할 수 없습니다.'.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  ps_seq_routing = ls_seq_routing.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_new_setting_201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_new_setting_201 .

  DATA: ls_scroll   TYPE lvc_s_stbl.

  ls_scroll-row = 'X'.
  ls_scroll-col = 'X'.

  PERFORM make_bom_proc.
  PERFORM resizing_fieldcat_grid_0201.
  PERFORM set_cell_attribute_grid_0201.


  CALL METHOD go_grid_0201->set_frontend_fieldcatalog
    EXPORTING
      it_fieldcatalog = gt_fieldcat_0201.                 " Field Catalog
  CALL METHOD go_grid_0201->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = ls_scroll.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_data_from_matnr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_data_from_matnr  USING pv_matnr TYPE matnr.


  DATA : BEGIN OF ls_sum_mseg,
           aufnr LIKE mseg-aufnr,
           aufps LIKE mseg-aufps,
           menge LIKE mseg-menge,
         END OF ls_sum_mseg.
  DATA : lt_sum_mseg LIKE TABLE OF ls_sum_mseg.

  DATA : BEGIN OF ls_afpo,
           aufnr LIKE afpo-aufnr,
           posnr LIKE afpo-posnr,
           psmng LIKE afpo-psmng,
           wemng LIKE afpo-wemng,
           psamg LIKE afpo-psamg,
           meins LIKE afpo-meins,
         END OF ls_afpo.
  DATA : lt_afpo LIKE TABLE OF ls_afpo.
  DATA : lt_afpo_idx LIKE TABLE OF ls_afpo.
  DATA : lt_afpo_orign LIKE TABLE OF ls_afpo.
  DATA : lt_afpo_sum LIKE TABLE OF ls_afpo.
  DATA : lt_afpo_orign_sum LIKE TABLE OF ls_afpo.
  DATA : lt_afpo_chk LIKE TABLE OF ls_afpo.
  DATA : lt_afpo_chk2 LIKE TABLE OF ls_afpo.

* - 선택한 오더의 자재, 소요량 및 조장과 동일한 재고 조회(복조장의 경우 조장 여러 개)
*    동일한 자재와 수량의 재고를 찾고 최종 입고에 사용한 생산 오더 확인
  READ TABLE gt_pegging_2010 INTO DATA(ls_2010) INDEX 1.
  SELECT aufnr, posnr, psmng, wemng, psamg, meins
    FROM  afpo
   WHERE aufnr = @ls_2010-ordnr
     INTO CORRESPONDING FIELDS OF TABLE @lt_afpo_orign.

  REFRESH lt_afpo_orign_sum.
  LOOP AT lt_afpo_orign INTO ls_afpo.
    CLEAR ls_afpo-posnr.
    COLLECT ls_afpo INTO lt_afpo_orign_sum.
  ENDLOOP.

  SELECT lgort, charg, labst, insme, speme
    FROM zgtcv_stockval
    WHERE werks = @p_werks
        AND matnr = @pv_matnr
        AND proccode = @gv_pagging_gong_cd
       INTO TABLE @DATA(lt_stockval).

  SORT lt_stockval BY lgort charg.
  DELETE ADJACENT DUPLICATES FROM lt_stockval COMPARING lgort charg.

  IF lt_stockval[] IS NOT INITIAL.
    SELECT b~mblnr, b~mjahr, b~zeile, b~aufnr, b~aufps, b~bwart, b~menge, b~lgort, b~charg
        FROM @lt_stockval AS a
        INNER JOIN mseg AS b
                              ON b~lgort = a~lgort
                             AND b~charg = a~charg
      WHERE b~matnr = @pv_matnr
          AND b~werks = @p_werks
          AND b~bwart IN ( '101', '102' )
      INTO TABLE @DATA(lt_mseg).
  ENDIF.

  SORT lt_mseg BY mblnr mjahr zeile.
  DELETE ADJACENT DUPLICATES FROM lt_mseg COMPARING mblnr mjahr zeile.

  LOOP AT lt_mseg INTO DATA(ls_mseg).
    CLEAR ls_sum_mseg.
    ls_sum_mseg-aufnr = ls_mseg-aufnr.
    ls_sum_mseg-aufps = ls_mseg-aufps.
    CASE ls_mseg-bwart.
      WHEN '101'.
        ls_sum_mseg-menge = ls_mseg-menge .
      WHEN '102'.
        ls_sum_mseg-menge = ls_mseg-menge * -1.
    ENDCASE.
    COLLECT ls_sum_mseg INTO lt_sum_mseg.
  ENDLOOP.

  READ TABLE lt_afpo_orign_sum INTO DATA(ls_afpo_orign_sum) INDEX 1.
  CLEAR gv_chk_psmng.
  gv_chk_psmng = ls_afpo_orign_sum-psmng.
  LOOP AT lt_sum_mseg ASSIGNING FIELD-SYMBOL(<ls_sum_mseg>).
*  생산오더별 오더별배치자재 입고 수량 합이 오더의 오더 계획된 총 수량 합보다 크거나 같을경우 비교대상
    IF <ls_sum_mseg>-menge >= ls_afpo_orign_sum-psmng.
    ELSE. " 작은 경우는 삭제
      DELETE lt_sum_mseg.
    ENDIF.
  ENDLOOP.

  SORT lt_sum_mseg BY aufnr.

  IF lt_sum_mseg[] IS NOT INITIAL.
    SELECT b~aufnr, b~posnr, b~psmng, b~wemng, b~psamg, b~meins
      FROM @lt_sum_mseg  AS a
      INNER JOIN afpo    AS b
                               ON b~aufnr = a~aufnr
                              AND b~posnr = a~aufps
      INTO CORRESPONDING FIELDS OF TABLE @lt_afpo.
  ENDIF.

  DELETE lt_afpo WHERE aufnr = ls_2010-ordnr.

  DATA(lt_chk_afpo_multy) = lt_afpo.

  SORT lt_chk_afpo_multy BY aufnr.
  DELETE ADJACENT DUPLICATES FROM lt_chk_afpo_multy COMPARING aufnr.

  LOOP AT lt_chk_afpo_multy ASSIGNING FIELD-SYMBOL(<ls_chk_afpo_multy>).
*   해당 오더가 복조장인지 확인
    SELECT aufnr, posnr FROM afpo
      INTO TABLE @DATA(lt_chk_lines)
      WHERE aufnr = @<ls_chk_afpo_multy>-aufnr.
    IF sy-subrc EQ 0 AND 1 < lines( lt_chk_lines ).
* 복조장 일시 해당 오더가 조장구성표에 존재하는지 확인
      SELECT ordnr, posnr FROM zgtppt2010
        INTO TABLE @DATA(lt_chk_2010_lines)
        WHERE ordnr = @<ls_chk_afpo_multy>-aufnr.
* 해당 오더가 조장구성표에 존재 할때 모든 품목이 자재상태가 아니라면 페깅 대상 아님
      IF sy-subrc EQ 0.
        REFRESH lt_afpo_idx.
        lt_afpo_idx = VALUE #( FOR lw_afpo IN lt_afpo WHERE ( aufnr = <ls_chk_afpo_multy>-aufnr )
                                                                        ( CORRESPONDING  #( lw_afpo ) ) ).
        IF lines( lt_afpo_idx ) NE lines( lt_chk_2010_lines ).
          DELETE lt_afpo WHERE aufnr = <ls_chk_afpo_multy>-aufnr.
        ENDIF.

      ENDIF.
    ENDIF.
  ENDLOOP.


  REFRESH lt_afpo_sum.
  LOOP AT lt_afpo INTO ls_afpo.
    CLEAR ls_afpo-posnr.
    COLLECT ls_afpo INTO lt_afpo_sum.
  ENDLOOP.

  SORT lt_afpo_orign BY psmng DESCENDING.

  REFRESH gt_pegging.

  READ TABLE lt_afpo_orign_sum INTO ls_afpo_orign_sum INDEX 1.
  LOOP AT lt_afpo_sum INTO DATA(ls_afpo_sum).
    IF ls_afpo_sum-psmng => ls_afpo_orign_sum-psmng."총 소요량이 같으면 비교 시작
*- 변경 대상 오더의 조장구성(복조장)을 고려하여 선택,
*   복조장 선택 시 품목 순서는 바뀔 수 있지만 전체 구성은 같아야 함
      IF lines( lt_afpo_orign ) > 1. "복조장 구성시

        REFRESH : lt_afpo_chk, lt_afpo_chk2.
        lt_afpo_chk = VALUE #( FOR wa_afpo IN lt_afpo WHERE ( aufnr = ls_afpo_sum-aufnr ) ( CORRESPONDING #( wa_afpo ) ) ).
        IF lines( lt_afpo_chk ) = 1.
          IF ls_afpo_sum-psmng >= ls_afpo_orign_sum-psmng.
            READ TABLE lt_afpo_chk INTO DATA(ls_afpo_chk2) INDEX 1.
            APPEND ls_afpo_chk2 TO lt_afpo_chk2.
            REFRESH lt_afpo_chk.
          ENDIF.

        ELSEIF lines( lt_afpo_chk ) = lines( lt_afpo_orign ).

          SORT lt_afpo_chk BY psmng DESCENDING.
          LOOP AT lt_afpo_orign INTO DATA(ls_afpo_orign).

            LOOP AT  lt_afpo_chk INTO DATA(ls_afpo_chk).
              IF ls_afpo_orign-psmng =< ls_afpo_chk-psmng.
                APPEND ls_afpo_chk TO lt_afpo_chk2.
                DELETE TABLE lt_afpo_chk FROM ls_afpo_chk.
              ENDIF.
            ENDLOOP.
          ENDLOOP.
        ENDIF.
      ELSE.

        REFRESH : lt_afpo_chk, lt_afpo_chk2.
        lt_afpo_chk = VALUE #( FOR wa_afpo IN lt_afpo WHERE ( aufnr = ls_afpo_sum-aufnr ) ( CORRESPONDING #( wa_afpo ) ) ).

        IF lines( lt_afpo_chk ) = 1.
          READ TABLE lt_afpo_chk INTO ls_afpo_chk2 INDEX 1.
          APPEND ls_afpo_chk2 TO lt_afpo_chk2.
          REFRESH lt_afpo_chk.
        ELSEIF lines( lt_afpo_chk ) > 1.
          CONTINUE.

        ENDIF.
      ENDIF.

      IF lt_afpo_chk[] IS INITIAL. " 처리결과 값이 비어있다면, 모든데이터 정합성이 맞는다는 의미, 화면 디스플레이 추가
        LOOP AT lt_afpo_chk2 INTO DATA(ls_data).
          APPEND INITIAL LINE TO gt_pegging ASSIGNING FIELD-SYMBOL(<ls_pegging>).
*           유형
          <ls_pegging>-types = 'Stock'.
          <ls_pegging>-matnr = pv_matnr.
          <ls_pegging>-aufnr = ls_data-aufnr.
          <ls_pegging>-posnr = ls_data-posnr.
          <ls_pegging>-psmng = ls_data-psmng.
          <ls_pegging>-meins = ls_data-meins.
          <ls_pegging>-maktx = zgtpp_cl_common=>get_maktx( iv_matnr = pv_matnr ).
          READ TABLE lt_mseg INTO ls_mseg WITH KEY aufnr = ls_data-aufnr
                                                                           aufps = ls_data-posnr
                                                                           bwart = '101'.
          <ls_pegging>-charg = ls_mseg-charg.
          <ls_pegging>-lgort = ls_mseg-lgort.

          READ TABLE lt_stockval INTO DATA(ls_stockval) WITH KEY charg = ls_mseg-charg
                                                                                                 lgort = ls_mseg-lgort.

          <ls_pegging>-labst = ls_stockval-labst.
          <ls_pegging>-insme = ls_stockval-insme.
          <ls_pegging>-speme = ls_stockval-speme.

          PERFORM get_jojangno USING <ls_pegging>-aufnr <ls_pegging>-posnr CHANGING <ls_pegging>-grpnr.

        ENDLOOP.
      ENDIF.

    ENDIF.
  ENDLOOP.

* 출력 필드 세팅
  DATA : lv_inlength TYPE i.
  DATA : lv_inlength_c(11) TYPE c.

  READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY chart = gv_pagging_gong_cd.
  gs_pegging_disp-gong_text = ls_seq_routing-chart_val && '(' && ls_seq_routing-chart && ')'.
  lv_inlength = ls_afpo_orign_sum-psmng.
  lv_inlength_c = lv_inlength.
  CONDENSE lv_inlength_c.
  gs_pegging_disp-inlength = lv_inlength_c &&  ls_afpo_orign_sum-meins.
  gs_pegging_disp-matnr_re = pv_matnr.
  gs_pegging_disp-maktx_re = zgtpp_cl_common=>get_maktx( iv_matnr = pv_matnr ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_JOJANGNO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_PEGGING>_AUFNR
*&      --> <LS_PEGGING>_POSNR
*&      <-- <LS_PEGGING>_GRPNR
*&---------------------------------------------------------------------*
FORM get_jojangno  USING    pv_aufnr TYPE aufnr
                                            pv_posnr TYPE co_posnr
                           CHANGING    pv_grpnr TYPE zgtegrpnr.

  DATA : lv_posnr(6) TYPE n.

  lv_posnr = pv_posnr + 0.

  SELECT SINGLE grpnr
    FROM zgtppt2010
    INTO pv_grpnr
   WHERE gong_cd = gv_pagging_gong_cd
     AND ordnr = pv_aufnr
     AND posnr = lv_posnr
     AND ordty = 'PRD'.

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
*& Form CHECK_AND_LOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM check_and_lock  CHANGING pv_check.

  DATA : lt_enq TYPE TABLE OF seqg3.

  CALL FUNCTION 'ENQUEUE_EZGT_ZGTPPR2010'
    EXPORTING
      grpnr          = gv_grpnr
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
    pv_check = abap_true.

    CALL FUNCTION 'ENQUEUE_READ'
      EXPORTING
        guname                = '*'
      TABLES
        enq                   = lt_enq
      EXCEPTIONS
        communication_failure = 1
        system_failure        = 2
        OTHERS                = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    LOOP AT lt_enq INTO DATA(ls_enq) WHERE gname = 'ZGTPPT2010'.
      FIND ALL OCCURRENCES OF gv_grpnr IN ls_enq-garg MATCH COUNT FINAL(lv_mcnt).
      IF lv_mcnt > 0.
        MESSAGE s000 DISPLAY LIKE 'E' WITH ls_enq-guname '가 조장구성표 번호 ' gv_grpnr '작성 중 입니다'.
      ENDIF.
      EXIT.
    ENDLOOP.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_sorttab_grid_0100 .

  REFRESH gt_sort_0100.

  PERFORM set_sort_tab TABLES gt_sort_0100
                            USING : 1 'GRPNR'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOWNLOAD_EXCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM download_excel .

  DATA : lo_excel TYPE REF TO zgtpp_cl_excel_service.
  DATA : lt_fcat_lvc TYPE lvc_t_fcat.
  DATA : lo_table TYPE REF TO data.
  DATA : lv_num(2) TYPE n.
  DATA : lv_fieldname(30).
  DATA : lv_filename TYPE string.
  FIELD-SYMBOLS : <lt_data> TYPE table.
  FIELD-SYMBOLS : <lv_value> TYPE any.

  lv_filename = '조장구성표(' && gv_grpnr && ')_' && sy-datum.

  LOOP AT gt_fieldcat_0201 INTO DATA(ls_fcat).
    IF ls_fcat-fieldname = 'DISP_SEQNO'.
      ls_fcat-datatype = 'CAHR'.
      APPEND ls_fcat TO lt_fcat_lvc.

    ENDIF.

    LOOP AT gt_seq_routing ASSIGNING FIELD-SYMBOL(<ls_routing>).
      CLEAR lv_num.
      lv_num = <ls_routing>-seqno + 0.
      CLEAR lv_fieldname.
      lv_fieldname = lv_num && '_' && <ls_routing>-chart.
      IF ls_fcat-fieldname = lv_fieldname.
        APPEND ls_fcat TO lt_fcat_lvc.
      ENDIF.
    ENDLOOP.

    IF ls_fcat-fieldname = 'ORDNO_C'.
      APPEND ls_fcat TO lt_fcat_lvc.
    ENDIF.

  ENDLOOP.

  cl_alv_table_create=>create_dynamic_table(
    EXPORTING
*      I_STYLE_TABLE       = ABAP_TRUE
      it_fieldcatalog           = lt_fcat_lvc                " Field Catalog
    IMPORTING
      ep_table                  = lo_table                 " Pointer to Dynamic Data Table
    EXCEPTIONS
      generate_subpool_dir_full = 1                " At Most 36 Subroutine Pools Can Be Generated Temporarily
      OTHERS                    = 2
  ).
  IF sy-subrc <> 0.
  ENDIF.

  ASSIGN lo_table->* TO <lt_data>.

  MOVE-CORRESPONDING <gt_main_201> TO <lt_data>.

  LOOP AT <lt_data> ASSIGNING FIELD-SYMBOL(<ls_data>).
    IF <lv_value> IS ASSIGNED. UNASSIGN <lv_value>. ENDIF.
    ASSIGN COMPONENT 'DISP_SEQNO' OF STRUCTURE <ls_data> TO <lv_value>.
    IF <lv_value> IS ASSIGNED AND <lv_value> = '000000'.
      CLEAR <lv_value>.
    ENDIF.
  ENDLOOP.

  TRY.
      lo_excel ?= zgtpp_cl_excel_service=>get_instance(
        EXPORTING
          iv_mode    = 'D' ).

      CHECK lo_excel IS BOUND.

      lo_excel->download_spreadsheet(
        it_data       = <lt_data>
        it_fcat       = lt_fcat_lvc                 " 리스트뷰어 제어에 대한 필드 카타로그
*        IV_TOP        = 1
      ).
    CATCH cx_bcs INTO DATA(lo_err). " BCS: General Exceptions
  ENDTRY.

  lo_excel->destroy_document( ).

*  ZGTSD_CL_COMMON=>EXCEL_DOWNLOAD(
*    EXPORTING
*      IT_DATA        = <LT_DATA>
*      IT_FCAT        = LT_FCAT_LVC
*      IV_DEF_FNAME   = LV_FILENAME
*
*  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_SUL_NO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM disp_sul_no .

  READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY seqno = 1.


  SELECT *
    INTO TABLE @DATA(lt_zedt100)
    FROM zedt1000
   WHERE werks = @p_werks
      AND new_matnr = @ls_seq_routing-matnr.

  IF sy-subrc EQ 0.
    SORT lt_zedt100 BY sul_no DESCENDING
                               rev_seq DESCENDING.

    READ TABLE lt_zedt100 INTO DATA(ls_zedt100) INDEX 1.

    SET PARAMETER ID 'ZED_SUL_NO'   FIELD ls_zedt100-sul_no.
    SET PARAMETER ID 'ZED_REV_SEQ' FIELD ls_zedt100-rev_seq.

    CALL TRANSACTION 'ZED1L1030'
                       AND SKIP FIRST SCREEN.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_POJANG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_POJANG
*&---------------------------------------------------------------------*
FORM check_pojang  TABLES   pt_2010 STRUCTURE zgtppt2010
                             CHANGING   pv_chk_pojang.

  DATA : lv_matnr TYPE matnr.

  LOOP AT pt_2010.
    IF pt_2010-dmordty = 'SO' AND p_werks = 1302.
      CLEAR gs_main_200.
      READ TABLE gt_main_200 INTO gs_main_200 WITH KEY ordno = pt_2010-dmord
                                                                                  posnr = pt_2010-dmline.
      IF sy-subrc EQ 0.

        IF gs_main_200-pack_yn NE '확정'.
          pv_chk_pojang = abap_true.
          RETURN.
        ENDIF.

        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            input        = gs_main_200-pack_no
          IMPORTING
            output       = lv_matnr
          EXCEPTIONS
            length_error = 1
            OTHERS       = 2.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

        SELECT SINGLE b~mmsta FROM mara AS a
          INNER JOIN marc AS b ON b~matnr = a~matnr
          WHERE a~matnr = @lv_matnr
              AND a~mtart LIKE 'MRM%'
              AND b~werks = @p_werks
            INTO @DATA(lv_mmsta).
        IF sy-subrc EQ 0 AND lv_mmsta IS NOT INITIAL.
          pv_chk_pojang = abap_true.
          RETURN.
        ENDIF.

      ENDIF.
    ENDIF.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_INIT_TITLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_init_title .

  IF sy-tcode = 'ZGTPPR2050'.
    SET TITLEBAR '[GT] 조장 구성표 조회'(t01).
    sy-title = '[GT] 조장 구성표 조회'(t01).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_UNPEGGING_FORCE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_unpegging_force .

  DATA : lt_2010 TYPE TABLE OF zgtppt2010.
  DATA : lt_2010_del TYPE TABLE OF zgtppt2010.
  DATA : lt_2010_multy TYPE TABLE OF zgtppt2010.
  DATA : lt_2010_dev TYPE TABLE OF zgtppt2010.
  DATA : lt_2010_pre TYPE TABLE OF zgtppt2010.
  DATA : lv_chk_err.
  DATA : lo_routing TYPE REF TO zgtpp_cl_routing.

  PERFORM chk_proc_unpegging_force  TABLES lt_2010
                                    CHANGING lv_chk_err.

  IF lv_chk_err IS NOT INITIAL.
    RETURN.
  ENDIF.

  IF lt_2010[] IS INITIAL.
    RETURN.
  ENDIF.

  CLEAR gv_answer.
  PERFORM popup_to_confirm_step USING 'N'
    ' '
    'Pegging 강제 삭제되면 복구할 수 없습니다. 계속 진행 하시겠습니까?'
    '작업확인'.
  IF gv_answer NE 'J'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.


*/s 2026.04.15.zlsgpp5.CHM2604-00316.복조장 및 Pegging 제한 해제.선택한 모든 오더 삭제.
* 한건만 존재.
*  READ TABLE lt_2010 INTO DATA(ls_2010_main) INDEX 1.

* 현재 조장구성표에 존재하는 해당 복조장 제거
*    SELECT * FROM zgtppt2010
*      INTO CORRESPONDING FIELDS OF TABLE lt_2010_multy
*     WHERE grpnr = ls_2010_main-grpnr
*       AND gong_cd = ls_2010_main-gong_cd
*       AND ordnr = ls_2010_main-ordnr
*       AND ordty = ls_2010_main-ordty.
  CLEAR: lt_2010_multy.
  SELECT b~*
    FROM @lt_2010 AS a
    INNER JOIN zgtppt2010 AS b ON b~grpnr = a~grpnr
                               AND b~gong_cd = a~gong_cd
                               AND b~ordnr = a~ordnr
                               AND b~ordty = a~ordty
    INTO CORRESPONDING FIELDS OF TABLE @lt_2010_multy.
*/e 2026.04.15.zlsgpp5.CHM2604-00316.


  CREATE OBJECT lo_routing
    EXPORTING
      iv_grpnr = gv_grpnr.

  lo_routing->get_chain_data(
    EXPORTING
      it_data      = lt_2010
    IMPORTING
      et_pre_data  = lt_2010_pre
      et_dev_data  = lt_2010_dev ).

* 삭제 대상건 현재 재고중인 복조장의 전체 오더, 이전공정 - 조장구성표에서만 삭제
  APPEND LINES OF lt_2010_multy TO lt_2010_del.
  APPEND LINES OF lt_2010_pre TO lt_2010_del.
  APPEND LINES OF lt_2010_dev TO lt_2010_del.

* 기존건 삭제
  IF lt_2010_del[] IS NOT INITIAL.
    DELETE zgtppt2010 FROM TABLE lt_2010_del.
    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

* 이후 공정건 연걸고리 작제후 다시 인서트
  LOOP AT lt_2010_dev ASSIGNING FIELD-SYMBOL(<ls_2010_dev>).
    CLEAR <ls_2010_dev>-reord.
    CLEAR <ls_2010_dev>-reline.
    CLEAR <ls_2010_dev>-reordty.
  ENDLOOP.

* 이후공정 업데이트
  IF lt_2010_dev[] IS NOT INITIAL.
    MODIFY zgtppt2010 FROM TABLE lt_2010_dev.
    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.


  lo_routing->set_chain_history( ).

*  변경정보 MES전송
  zgtpp_cl_routing=>send_chg_mes(
    iv_werks = p_werks           " 플랜트
    iv_spgcd = p_spgcd          " SPG 코드
    iv_grpnr = gv_grpnr ).    " 조장 구성표 번호

  PERFORM refresh_screen_201.

  MESSAGE s003 WITH 'Pegging 강제삭제 완료하였습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_PROC_UNPEGGING_FORCE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      --> LT_2010_DEV
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM chk_proc_unpegging_force   TABLES   pt_2010 STRUCTURE zgtppt2010
                                CHANGING pv_chk_err.

  DATA : lt_column TYPE lvc_t_col.
  DATA : lt_cells TYPE lvc_t_ceno.
  DATA : lv_num(2) TYPE n.
  DATA : lo_routing TYPE REF TO zgtpp_cl_routing.
  DATA : lv_chart TYPE atwrt.
  DATA : lv_seqno TYPE i.
  DATA : lt_chk_2010 LIKE gt_2010.
  DATA : lv_available_chk.

  FIELD-SYMBOLS <lv_line_seq> TYPE any.
  FIELD-SYMBOLS <lv_ordnr> TYPE any.
  FIELD-SYMBOLS <lv_posnr> TYPE any.
  FIELD-SYMBOLS <lv_ordty> TYPE any.
  FIELD-SYMBOLS <lv_matnr> TYPE any.

  DATA : lv_fname01 TYPE fieldname. "오더넘버
  DATA : lv_fname02 TYPE fieldname. " 품목번호
  DATA : lv_fname03 TYPE fieldname. " 오더타입
  DATA : lv_fname04 TYPE fieldname. "

  DEFINE __get_index_of_table.
    IF <lv_line_seq> IS ASSIGNED. UNASSIGN <lv_line_seq>. ENDIF.
    ASSIGN COMPONENT 'LINE_SEQ' OF STRUCTURE <ls_main_201> TO <lv_line_seq>.
  END-OF-DEFINITION.

  DEFINE __set_field_name.
    CLEAR : lv_fname01, lv_fname02, lv_fname03.
    lv_fname01 = &1 && '_ORDNR'.
    lv_fname02 = &1 && '_POSNR'.
    lv_fname03 = &1 && '_ORDTY'.
    lv_fname04 = &1 && '_MATNR'.
  END-OF-DEFINITION.

  DEFINE __assign_field.
    IF <lv_ordnr> IS ASSIGNED. UNASSIGN <lv_ordnr>. ENDIF.
    ASSIGN COMPONENT lv_fname01 OF STRUCTURE <ls_routing> TO <lv_ordnr>.
    IF <lv_posnr> IS ASSIGNED. UNASSIGN <lv_posnr>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_routing> TO <lv_posnr>.
    IF <lv_ordty> IS ASSIGNED. UNASSIGN <lv_ordty>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_routing> TO <lv_ordty>.
    IF <lv_matnr> IS ASSIGNED. UNASSIGN <lv_matnr>. ENDIF.
    ASSIGN COMPONENT lv_fname04 OF STRUCTURE <ls_routing> TO <lv_matnr>.
  END-OF-DEFINITION.

  CLEAR : pv_chk_err.
  REFRESH pt_2010[].

  go_grid_0201->get_selected_columns(
    IMPORTING
      et_index_columns = lt_column ).                " Cell IDs

  IF lt_column[] IS NOT INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '컬럼을 선택할 수 없습니다.'.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  go_grid_0201->get_selected_cells_id(
    IMPORTING
     et_cells = lt_cells ).                " Cell IDs

  IF 1 > lines( lt_cells ).
    MESSAGE s003 DISPLAY LIKE 'E' WITH '하나의 셀만 선택해야 합니다.'.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  LOOP AT lt_cells INTO DATA(ls_cells).
    READ TABLE gt_fieldcat_0201 INTO DATA(ls_fcat) INDEX ls_cells-col_id.
    IF sy-subrc EQ 0.
      SPLIT ls_fcat-fieldname AT  '_'  INTO TABLE DATA(lt_string).
      READ TABLE lt_string INTO DATA(ls_string) INDEX 2.
      lv_chart = ls_string.

      IF NOT line_exists( gt_seq_routing[ chart = lv_chart ] ).
        MESSAGE s003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'.
        pv_chk_err = abap_true.
        EXIT.
      ENDIF.
    ENDIF.

    READ TABLE lt_string INTO ls_string INDEX 1.
    lv_seqno = ls_string + 0.
    READ TABLE gt_seq_routing INTO DATA(ls_seq_routing) WITH KEY chart = lv_chart
                                                                 seqno = lv_seqno.
    IF ls_seq_routing-mtart = 'MCFE'.
*/s 2026.04.15.zlsgpp5.CHM2604-00316.복조장 및 Pegging 제한 해제.
*      MESSAGE s003 DISPLAY LIKE 'E' WITH '제품 Pegging은 변경 할 수 없습니다.'.
*      pv_chk_err = abap_true.
*      EXIT.
*/e 2026.04.15.zlsgpp5.CHM2604-00316.
    ENDIF.


*  선택된 필드의 오더정보 찾기
    READ TABLE <gt_main_201> ASSIGNING FIELD-SYMBOL(<ls_main_201>) INDEX ls_cells-row_id.
    IF sy-subrc EQ 0.
      __get_index_of_table.
      CLEAR lv_num.
      READ TABLE <gt_routing> ASSIGNING FIELD-SYMBOL(<ls_routing>) INDEX <lv_line_seq>.
      DO.
        ADD 1 TO lv_num.
        __set_field_name lv_num.
        __assign_field.
        IF <lv_ordty> = ls_seq_routing-chart AND <lv_matnr> = ls_seq_routing-matnr.
          READ TABLE gt_2010 INTO DATA(ls_2010) WITH KEY gong_cd = ls_seq_routing-chart
                                                         ordnr = <lv_ordnr>
                                                         posnr = <lv_posnr>.
          IF sy-subrc EQ 0.
*/s 2026.04.15.zlsgpp5.CHM2604-00316.복조장 및 Pegging 제한 해제.선택한 모든 오더 삭제.
            APPEND ls_2010 TO lt_chk_2010.
*/e 2026.04.15.zlsgpp5.CHM2604-00316.
            EXIT.
          ENDIF.
        ENDIF.

        IF lv_num >= gv_line_jojang.
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.
  ENDLOOP.


*/s 2026.04.15.zlsgpp5.CHM2604-00316.복조장 및 Pegging 제한 해제.선택한 모든 오더 삭제.
*  CHECK ls_2010 IS NOT INITIAL.
*
*  lt_chk_2010 = VALUE #( FOR wa_2010 IN gt_2010 WHERE ( gong_cd = ls_2010-gong_cd
*                                                        AND  ordnr = ls_2010-ordnr
*                                                        AND  posnr = ls_2010-posnr )
*                                                ( CORRESPONDING #( wa_2010 ) ) ).
  SORT lt_chk_2010 BY gong_cd ordnr posnr ordty.
  DELETE ADJACENT DUPLICATES FROM lt_chk_2010 COMPARING gong_cd ordnr posnr ordty.
*/e 2026.04.15.zlsgpp5.CHM2604-00316.


  LOOP AT lt_chk_2010 INTO ls_2010.
* 정합성 확인
* 재고 여부 확인
*    IF LS_2010-CHECK_JEGO IS INITIAL.
*      MESSAGE S003 DISPLAY LIKE 'E' WITH '재고 상태인 오더만 삭제 가능합니다.'.
*      PV_CHK_ERR = ABAP_TRUE.
*      RETURN.
*    ENDIF.

* 이후공정 상태 확인 작업 진행중이면 삭제 불가
    READ TABLE gt_2010 INTO DATA(ls_2010_dev) WITH KEY ordnr = ls_2010-dmord
                                                       posnr = ls_2010-dmline
                                                       ordty = ls_2010-dmordty.

    IF ls_2010_dev-chk_prd = abap_true.
*/s 2026.04.15.zlsgpp5.CHM2604-00316.복조장 및 Pegging 제한 해제.
*      MESSAGE s003 DISPLAY LIKE 'E' WITH '이후 공정 작업 진행중으로 삭제 불가능합니다.'.
*      pv_chk_err = abap_true.
*      RETURN.
*/e 2026.04.15.zlsgpp5.CHM2604-00316.
    ENDIF.

* 복조장 여부 확인
    SELECT aufnr, posnr FROM afpo
      WHERE aufnr = @ls_2010-ordnr
         INTO TABLE @DATA(lt_afpo_chk).
    IF sy-subrc EQ 0 AND lines( lt_afpo_chk ) > 1.
*     현재 선택된 복조장 오더가 조장구성표에 마직막 남은 오더일 경우 삭제처리되면 안됨
      CLEAR lv_available_chk.
      LOOP AT gt_2010 INTO DATA(ls_2010_chk_multy) WHERE ordnr = ls_2010-ordnr
                                                     AND posnr NE ls_2010-posnr
                                                     AND ordty = ls_2010-ordty.
        lv_available_chk = abap_true.
        CONTINUE.
      ENDLOOP.
      IF lv_available_chk IS INITIAL.
        MESSAGE s003 DISPLAY LIKE 'E' WITH 'Pegging 강제삭제 처리 불가능한 오더입니다.'.
        pv_chk_err = abap_true.
        RETURN.
      ENDIF.

    ELSE.
*/s 2026.04.15.zlsgpp5.CHM2604-00316.복조장 및 Pegging 제한 해제.
*      MESSAGE s003 DISPLAY LIKE 'E' WITH '복조장인 오더만 Pegging 강제삭제 가능합니다.'.
*      pv_chk_err = abap_true.
*      RETURN.
*/e 2026.04.15.zlsgpp5.CHM2604-00316.
    ENDIF.

    APPEND INITIAL LINE TO pt_2010[] ASSIGNING FIELD-SYMBOL(<ls_chk_2010>).
    MOVE-CORRESPONDING ls_2010 TO <ls_chk_2010>.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_SORT_LENG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM process_sort_leng  USING  pv_gubun.

  SET PARAMETER ID 'Z2010' FIELD pv_gubun.

  PERFORM refresh_screen_201.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LENGTH_OF_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LV_ORDNR>
*&      --> <LV_POSNR>
*&      --> <LV_ORDTY>
*&      <-- <LV_LENG>
*&---------------------------------------------------------------------*
FORM get_length_of_order  USING    pv_ordnr
                                   pv_posnr
                                   pv_ordty
                          CHANGING pv_leng.

  DATA : lv_posnr(6) TYPE n.
  DATA : ls_2010 LIKE gs_2010.

  lv_posnr = pv_posnr + 0.
  READ TABLE gt_2010 INTO ls_2010 WITH KEY ordnr = pv_ordnr
                                           posnr = lv_posnr
                                           gong_cd = pv_ordty.

  CASE ls_2010-ordty.
    WHEN 'PRD' OR 'PLN'.
      pv_leng = ( ls_2010-inlength + ls_2010-qlength + ls_2010-adlength ) *
                      ls_2010-infactor.

  ENDCASE.


ENDFORM.
