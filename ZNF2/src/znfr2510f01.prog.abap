*&---------------------------------------------------------------------*
*&  Include           ZNFR2510F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  CREATE_OBJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_object .

* Create Object : GRF_CONTAINER_H
  CREATE OBJECT grf_container_h
    EXPORTING
      container_name = grf_container_name_h.

* Create Object : GRF_GRID_H
  CREATE OBJECT grf_grid_h
    EXPORTING
      i_parent      = grf_container_h
      i_appl_events = 'X'.

ENDFORM.                    " CREATE_OBJECT


*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_EXCLUDE  text
*----------------------------------------------------------------------*
FORM exclude_tb_functions CHANGING pt_exclude TYPE ui_functions.
  DATA : ls_exclude TYPE ui_func.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO pt_exclude.

ENDFORM.                    " EXCLUDE_TB_FUNCTIONS


*&---------------------------------------------------------------------*
*&      Form  SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_grid_layout .

  CLEAR gs_layout_h.
  gs_layout_h-sel_mode   = 'A'.
  gs_layout_h-zebra      = 'X'.
  gs_layout_h-stylefname = 'CELLTAB'.
  gs_layout_h-numc_total = 'X'.
  gs_layout_h-no_rowins  = 'X'.
* GS_LAYOUT_H-NO_TOTLINE = 'X'.
* GS_LAYOUT_H-CWIDTH_OPT = 'X'.
* GS_LAYOUT_H-NO_UTSPLIT = 'X'.

ENDFORM.                    " SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_grid_sort .

  CLEAR : gs_sort_h.
  CLEAR : gt_sort_h. REFRESH gt_sort_h.

  gs_sort_h-spos = 1.
  gs_sort_h-fieldname = 'REQ_TYPE'.
  gs_sort_h-up = 'X'.
  gs_sort_h-comp = 'X'.
  gs_sort_h-subtot = 'X'.
  APPEND gs_sort_h TO gt_sort_h.

ENDFORM.                    " SET_GRID_SORT

*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_grid_fieldcatalog .

  CLEAR gt_fieldcat_h. REFRESH gt_fieldcat_h.

  PERFORM set_fieldcat_h USING:
    'REQ_TYPE'         '구분'           '4'      'C'    ' '     ,
    'REQ_LIST'         '결재항목'       '30'     'L'    ' '     ,
    'REQ_CNT'          '건수'           '5'      'C'    ' '     .

ENDFORM.                    " SET_GRID_FIELDCATALOG
*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT
*&---------------------------------------------------------------------*
FORM set_fieldcat_h  USING  p_fieldname
                            p_coltext
                            p_outputlen
                            p_just
                            p_convexit.

  CLEAR gs_fieldcat_h.

  gs_fieldcat_h-fieldname  = p_fieldname .
  gs_fieldcat_h-coltext    = p_coltext   .
  gs_fieldcat_h-outputlen  = p_outputlen .
  gs_fieldcat_h-just       = p_just      .
  gs_fieldcat_h-convexit   = p_convexit  .

  CASE p_fieldname.
    WHEN 'REQ_TYPE'.
      gs_fieldcat_h-no_out  = 'X'.
    WHEN 'REQ_CNT'.
      gs_fieldcat_h-hotspot = 'X'.
  ENDCASE.

  APPEND gs_fieldcat_h TO gt_fieldcat_h.

ENDFORM.                    " SET_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  SET_CELL_ATTRIBUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_cell_attribute .

* 각 셀의 특성 제어
  DATA : lt_celltab TYPE lvc_t_styl,
         l_index    TYPE i.

  LOOP AT gt_list INTO gs_list.
    l_index = sy-tabix.
    REFRESH lt_celltab.
    CLEAR gs_list-celltab.
    INSERT LINES OF lt_celltab INTO TABLE gs_list-celltab.
    MODIFY gt_list FROM gs_list INDEX l_index.
  ENDLOOP.

ENDFORM.                    " SET_CELL_ATTRIBUTE

*&---------------------------------------------------------------------*
*&      Form  SET_EVENT_HANDLER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_event_handler .

  CALL METHOD grf_grid_h->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CREATE OBJECT grf_event_receiver_h.
  SET HANDLER :
    grf_event_receiver_h->handle_hotspot_click FOR grf_grid_h.

ENDFORM.                    " SET_EVENT_HANDLER


*&---------------------------------------------------------------------*
*&      Form  SET_F4_HELP_REGISTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_f4_help_register .

  CLEAR   : gs_f4_h.
  REFRESH : gt_f4_h.

* FieldName별 소트해서 APPEND
* GS_F4_H-FIELDNAME = 'NFUTN'.
* GS_F4_H-REGISTER  = 'X'.
* APPEND GS_F4_H TO GT_F4_H.
*
* CALL METHOD GRF_GRID_H->REGISTER_F4_FOR_FIELDS
*   EXPORTING
*     IT_F4 = GT_F4_H.

ENDFORM.                    " SET_F4_HELP_REGISTER


*&---------------------------------------------------------------------*
*&      Form  SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_table_for_first_display .

  gs_variant_h-handle = '0001'.
  gs_variant_h-report = sy-repid.

  CALL METHOD grf_grid_h->set_table_for_first_display
    EXPORTING
      is_variant                    = gs_variant_h
      is_layout                     = gs_layout_h
      i_save                        = 'A'
      i_default                     = 'X'
      it_toolbar_excluding          = gt_exclude_h
    CHANGING
      it_fieldcatalog               = gt_fieldcat_h[]
      it_sort                       = gt_sort_h[]
      it_outtab                     = gt_list[]
      it_filter                     = gt_filter_h
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  CALL METHOD grf_grid_h->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  GET_REQ_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_req_list .

*   =========================================
*   REQ_TYPE 코드값(Hotsopt용 구분값)
*   =========================================
*   'A' = 선물요청승인
*   'B' = 만기이동요청승인
*   'C' = 만기이동집행승인
*   'D' = 신규선물집행승인
*   'E' = 청산선물집행승인
*   'F' = 신규/청산선물집행수정승인
*   =========================================

  DATA: lv_cnt TYPE i.

  CLEAR : gv_pernr, gv_uname.
  CLEAR : gt_pernr. REFRESH gt_pernr[].

  IF p_uname IS NOT INITIAL.
    gv_uname = p_uname.
  ELSE.
    gv_uname = sy-uname.
  ENDIF.

  PERFORM get_usrid_per_sapid TABLES gt_pernr
                               USING gv_uname
                                     gv_pernr.
*.GV_PERNR -> 개인아이디
* GT_PERNR -> 공용아이디
  IF gv_pernr IS NOT INITIAL.
    gt_pernr-pernr = gv_pernr.
    APPEND gt_pernr.
    IF gt_pernr IS INITIAL.
      MESSAGE s003 DISPLAY LIKE 'E'
         WITH gv_uname '에 대한 사번정보가 존재하지 않습니다.'.
      EXIT.
    ENDIF.
  ENDIF.

* --------------------------------------------------------------------
* 'A' = 선물요청승인
* --------------------------------------------------------------------
  DATA: lt_nfnum_a LIKE TABLE OF gs_nfnum.
  CLEAR : gs_list.  REFRESH : gt_list.
  CLEAR : gs_nfnum. REFRESH : gt_nfnum_a.

  IF gt_pernr[] IS NOT INITIAL.

    SELECT COUNT(*) INTO lv_cnt
      FROM znft1090 AS z2
           FOR ALL ENTRIES IN gt_pernr
     WHERE z2~bukrs EQ p_bukrs
       AND z2~congb EQ '2'
       AND z2~pernr EQ gt_pernr-pernr
       AND z2~lvorm NE 'X'.

    IF sy-subrc EQ 0 AND lv_cnt NE 0.

*.....선물요청승인(1차)은 ZNFT1091에 승인자 사번 정보가 존재
      SELECT z1~nfnum INTO CORRESPONDING FIELDS OF TABLE gt_nfnum_a
        FROM znft1091 AS z1
             INNER JOIN znft1090 AS z2
                ON z2~bukrs EQ z1~bukrs AND z2~congb EQ z1~congb
               AND z2~consq EQ z1~consq AND z2~pernr EQ z1~pernr
             FOR ALL ENTRIES IN gt_pernr
       WHERE z1~bukrs EQ p_bukrs
         AND z1~congb EQ '2'
         AND z1~const EQ 'B'
         AND z1~consq EQ '1'
         AND z1~pernr EQ gt_pernr-pernr
         AND z2~lvorm NE 'X'.

*.....선물요청 접수,확인,최종확인(2차~4차)은 ZNFT1090에 승인권한만 확인
      REFRESH lt_nfnum_a.
      SELECT z1~nfnum INTO CORRESPONDING FIELDS OF TABLE lt_nfnum_a
        FROM znft1091 AS z1
             INNER JOIN znft1090 AS z2
                ON z2~bukrs EQ z1~bukrs AND z2~congb EQ z1~congb
               AND z2~consq EQ z1~consq
       WHERE z1~bukrs EQ p_bukrs
         AND z1~congb EQ '2'
         AND z1~const EQ 'B'
         AND z1~consq IN ('2','3','4')
         AND z2~pernr EQ gt_pernr-pernr
         AND z2~lvorm NE 'X'.

      IF lt_nfnum_a IS NOT INITIAL.
        APPEND LINES OF lt_nfnum_a TO gt_nfnum_a.
      ENDIF.

      IF gt_nfnum_a IS NOT INITIAL.

        SORT gt_nfnum_a BY nfnum.
        gs_list-req_type = 'A'.
        gs_list-req_list = '선물요청승인'.
        SELECT COUNT(*) INTO gs_list-req_cnt
          FROM znft1010
               FOR ALL ENTRIES IN gt_nfnum_a
         WHERE bukrs EQ p_bukrs
           AND reqno EQ gt_nfnum_a-nfnum.
        APPEND gs_list TO gt_list.
      ELSE.
        gs_list-req_type = 'A'.
        gs_list-req_list = '선물요청승인'.
        gs_list-req_cnt  = 0.
        APPEND gs_list TO gt_list.
      ENDIF.

    ELSE.
*......승인권한이 없는 경우 List되지 않도록 변경
*      gs_list-req_type = 'A'.
*      gs_list-req_list = '선물요청승인'.
*      gs_list-req_cnt  = 0.
*      APPEND gs_list TO gt_list.

    ENDIF.

  ENDIF.

* --------------------------------------------------------------------
* 'B' = 만기이동요청승인
* --------------------------------------------------------------------
  DATA  : lt_nfnum_b LIKE TABLE OF gs_nfnum.
  CLEAR : gs_list.
  CLEAR : gs_nfnum. REFRESH : gt_nfnum_b.

  IF gt_pernr[] IS NOT INITIAL.

    SELECT COUNT(*) INTO lv_cnt
      FROM znft1090 AS z2
           FOR ALL ENTRIES IN gt_pernr
     WHERE z2~bukrs EQ p_bukrs
       AND z2~congb EQ '5'
       AND z2~consq EQ '1'
       AND z2~pernr EQ gt_pernr-pernr
       AND z2~lvorm NE 'X'.

    IF sy-subrc EQ 0 AND lv_cnt NE 0.
*.....만기이동요청승인(1차)은 ZNFT1091에 승인자 사번 정보가 존재
      SELECT z1~nfnum INTO CORRESPONDING FIELDS OF TABLE gt_nfnum_b
        FROM znft1091 AS z1
             INNER JOIN znft1090 AS z2
                ON z2~bukrs EQ z1~bukrs AND z2~congb EQ z1~congb
               AND z2~consq EQ z1~consq
             FOR ALL ENTRIES IN gt_pernr
       WHERE z1~bukrs EQ p_bukrs
         AND z1~congb EQ '5'
         AND z1~const EQ 'B'
         AND z1~consq EQ '1'
         AND z1~pernr EQ gt_pernr-pernr
         AND z2~lvorm NE 'X'.

      IF gt_nfnum_b IS NOT INITIAL.

        SORT gt_nfnum_b BY nfnum.
        gs_list-req_type = 'B'.
        gs_list-req_list = '만기이동요청승인'.
        SELECT COUNT(*) INTO gs_list-req_cnt
          FROM znft1040
               FOR ALL ENTRIES IN gt_nfnum_b
         WHERE bukrs EQ p_bukrs
           AND shfno EQ gt_nfnum_b-nfnum.
        APPEND gs_list TO gt_list.
      ELSE.
        gs_list-req_type = 'B'.
        gs_list-req_list = '만기이동요청승인'.
        gs_list-req_cnt  = 0.
        APPEND gs_list TO gt_list.
      ENDIF.
    ELSE.
*      GS_LIST-REQ_TYPE = 'B'.
*      GS_LIST-REQ_LIST = '만기이동요청승인'.
*      GS_LIST-REQ_CNT  = 0.
*      APPEND GS_LIST TO GT_LIST.
    ENDIF.

  ENDIF.

* --------------------------------------------------------------------
* 'C' = 만기이동집행승인
* --------------------------------------------------------------------
  CLEAR : gs_list.
  CLEAR : gs_nfnum. REFRESH : gt_nfnum_c.

  IF gt_pernr[] IS NOT INITIAL.

    SELECT COUNT(*) INTO lv_cnt
      FROM znft1090 AS z2
           FOR ALL ENTRIES IN gt_pernr
     WHERE z2~bukrs EQ p_bukrs
       AND z2~congb EQ '5'
       AND z2~consq EQ '3'
       AND z2~pernr EQ gt_pernr-pernr
       AND z2~lvorm NE 'X'.

    IF sy-subrc EQ 0 AND lv_cnt NE 0.
*.....만기이동확인(3차)은 ZNFT1090에 승인권한만 확인
      SELECT z1~nfnum INTO CORRESPONDING FIELDS OF TABLE gt_nfnum_c
        FROM znft1091 AS z1
             INNER JOIN znft1090 AS z2
                ON z2~bukrs EQ z1~bukrs AND z2~congb EQ z1~congb
               AND z2~consq EQ z1~consq
             FOR ALL ENTRIES IN gt_pernr
       WHERE z1~bukrs EQ p_bukrs
         AND z1~congb EQ '5'
         AND z1~const EQ 'B'
         AND z1~consq EQ '3'
         AND z2~pernr EQ gt_pernr-pernr
         AND z2~lvorm NE 'X'.

      IF gt_nfnum_c IS NOT INITIAL.
        SORT gt_nfnum_b BY nfnum.
        gs_list-req_type = 'C'.
        gs_list-req_list = '만기이동집행승인'.
        SELECT COUNT(*) INTO gs_list-req_cnt
          FROM znft1040
               FOR ALL ENTRIES IN gt_nfnum_c
         WHERE shfno EQ gt_nfnum_c-nfnum
           AND bukrs EQ p_bukrs
           AND drsta EQ '5'.
        APPEND gs_list TO gt_list.
      ELSE.
        gs_list-req_type = 'C'.
        gs_list-req_list = '만기이동집행승인'.
        gs_list-req_cnt  = 0.
        APPEND gs_list TO gt_list.
      ENDIF.

    ELSE.
*      GS_LIST-REQ_TYPE = 'C'.
*      GS_LIST-REQ_LIST = '만기이동집행승인'.
*      GS_LIST-REQ_CNT  = 0.
*      APPEND GS_LIST TO GT_LIST.
    ENDIF.

  ENDIF.

* --------------------------------------------------------------------
* 'D' = 신규선물집행승인
* --------------------------------------------------------------------
  CLEAR : gs_list, lv_cnt.
  CLEAR : gs_nfnum. REFRESH : gt_nfnum_d.

* 신규선물집행권한이 있는지 체크
  IF gt_pernr[] IS NOT INITIAL.
    SELECT COUNT(*) INTO lv_cnt
      FROM znft1090 AS z2
           FOR ALL ENTRIES IN gt_pernr
     WHERE z2~bukrs EQ p_bukrs
       AND z2~congb EQ '3'
       AND z2~consq EQ '1'
       AND z2~pernr EQ gt_pernr-pernr
       AND z2~lvorm NE 'X'.

*...만기이동 생성건을 제외하기 위해, OLDFT EQ SPACE 조건 추가.
*...만기이동 생성건은 OLDFT값이 있고, 승인요청시 CONFM 상태를 '2'로 생성.
    IF sy-subrc EQ 0 AND lv_cnt NE 0.
      gs_list-req_type = 'D'.
      gs_list-req_list = '신규선물집행승인'.
      SELECT COUNT(*) INTO gs_list-req_cnt
        FROM znft1020
       WHERE bukrs EQ p_bukrs
         AND confm EQ '2'
         AND oldft EQ space
         AND yncan NE 'X'
         AND ynfin NE 'X'
         AND ynnet NE 'X'.
      APPEND gs_list TO gt_list.
    ELSE.
*      GS_LIST-REQ_TYPE = 'D'.
*      GS_LIST-REQ_LIST = '신규선물집행승인'.
*      GS_LIST-REQ_CNT  = 0.
*      APPEND GS_LIST TO GT_LIST.
    ENDIF.

  ENDIF.

* --------------------------------------------------------------------
* 'E' = 청산선물집행승인
* --------------------------------------------------------------------
  CLEAR : gs_list, lv_cnt.
  CLEAR : gs_nfnum. REFRESH : gt_nfnum_e.

  IF gt_pernr[] IS NOT INITIAL.

    SELECT COUNT(*) INTO lv_cnt
      FROM znft1090 AS z1
           FOR ALL ENTRIES IN gt_pernr
     WHERE z1~pernr EQ gt_pernr-pernr
       AND z1~bukrs EQ p_bukrs
       AND z1~congb EQ '4'
       AND z1~consq EQ '1'
       AND z1~lvorm NE 'X'.

*...만기이동 생성건을 제외하기 위해, OLDFT EQ SPACE 조건 추가.
*...만기이동 생성건은 OLDFT값이 있고, 승인요청시 CONFM 상태를 '2'로 생성.
    IF sy-subrc EQ 0 AND lv_cnt NE 0.
      gs_list-req_type = 'E'.
      gs_list-req_list = '청산선물집행승인'.
      SELECT COUNT(*) INTO gs_list-req_cnt
        FROM znft1030
       WHERE bukrs EQ p_bukrs
         AND confm EQ '2'
         AND oldft EQ space
         AND yncan NE 'X'
         AND ynfin NE 'X'
         AND ynnet NE 'X'.
      APPEND gs_list TO gt_list.
    ELSE.
*      GS_LIST-REQ_TYPE = 'E'.
*      GS_LIST-REQ_LIST = '청산선물집행승인'.
*      GS_LIST-REQ_CNT  = 0.
*      APPEND GS_LIST TO GT_LIST.
    ENDIF.

  ENDIF.

* --------------------------------------------------------------------
* 'F' = 신규/청산선물집행수정승인
* --------------------------------------------------------------------
  CLEAR : gs_list, lv_cnt.
  CLEAR : gs_nfnum. REFRESH : gt_nfnum_f.

  IF gt_pernr[] IS NOT INITIAL.
    SELECT COUNT(*) INTO lv_cnt
      FROM znft1090 AS z1
           FOR ALL ENTRIES IN gt_pernr
     WHERE z1~pernr EQ gt_pernr-pernr
       AND z1~bukrs EQ p_bukrs
       AND z1~congb IN ('3', '4')
       AND z1~consq EQ '1'
       AND z1~lvorm NE 'X'.

    IF sy-subrc EQ 0 AND lv_cnt NE 0.
*.....만기이동으로 인한 생성건을 제외해야하므로, OLDFT = SPACE 조건이 필요했으나,
*     만기이동생성후 수정승인도 가능함으로 만기이동후 생성건은 CONFM 상태를
*     '3'으로 생성토록 변경하고 OLDFT = SPACE 조건을 삭제함.
*.....삭제상태의 변경을 승인요청할 경우도 있으므로, YNCAN NE 'X' 조건을 삭제함.
      SELECT COUNT(*) INTO lv_cnt
        FROM znft1020
       WHERE bukrs EQ p_bukrs
         AND confm EQ '6'
*        AND OLDFT EQ SPACE
*        AND YNCAN NE 'X'
         AND ynfin NE 'X'
         AND ynnet NE 'X'.
      IF lv_cnt IS NOT INITIAL.
        ADD lv_cnt TO gs_list-req_cnt.
      ENDIF.

      SELECT COUNT(*) INTO lv_cnt
        FROM znft1030
       WHERE bukrs EQ p_bukrs
         AND confm EQ '6'
*        AND OLDFT EQ SPACE
*        AND YNCAN NE 'X'
         AND ynfin NE 'X'
         AND ynnet NE 'X'.
      IF lv_cnt IS NOT INITIAL.
        ADD lv_cnt TO gs_list-req_cnt.
      ENDIF.
      gs_list-req_type = 'F'.
      gs_list-req_list = '신규/청산선물집행수정승인'.
      APPEND gs_list TO gt_list.
    ELSE.
*      GS_LIST-REQ_TYPE = 'F'.
*      GS_LIST-REQ_LIST = '신규/청산선물집행수정승인'.
*      GS_LIST-REQ_CNT  = 0.
*      APPEND GS_LIST TO GT_LIST.
    ENDIF.

  ENDIF.

* --------------------------------------------------------------------
* 'G' = 선물집행 최종확인
* --------------------------------------------------------------------
  CLEAR : gs_list, lv_cnt.
  CLEAR : gs_nfnum. REFRESH : gt_nfnum_g.

*.선물집행 최종확인 권한이 있는지 체크
* (선물요청 최종확인자 = 선물집행 최종확인자로 Process정함 by 구영헌C)
  IF gt_pernr[] IS NOT INITIAL.
    SELECT COUNT(*) INTO lv_cnt
      FROM znft1090 AS z2
           FOR ALL ENTRIES IN gt_pernr
     WHERE z2~bukrs EQ p_bukrs
       AND z2~congb EQ '2'
       AND z2~consq EQ '4'
       AND z2~pernr EQ gt_pernr-pernr
       AND z2~lvorm NE 'X'.

*...선물집행 최종확인 대상건 Count(신규 + 청산)
    IF sy-subrc EQ 0 AND lv_cnt NE 0.
      SELECT COUNT(*) INTO lv_cnt
        FROM znft1020 AS z1
             INNER JOIN znft1011 AS z3
                ON z3~reqno EQ z1~reqno AND z3~h_no1 EQ z1~h_no1
             INNER JOIN znft1010 AS z2
                ON z2~reqno EQ z3~reqno
             INNER JOIN znft1000 AS z4
                ON z4~conno EQ z3~conno
       WHERE z1~bukrs EQ p_bukrs
         AND z1~confm IN ('3', '7')
         AND z1~yncan NE 'X'
         AND z1~ynnet NE 'X'
         AND z1~lcnam EQ space
         AND z4~cotyp NE '4'.

      IF lv_cnt IS NOT INITIAL.
        ADD lv_cnt TO gs_list-req_cnt.
      ENDIF.

      SELECT COUNT(*) INTO lv_cnt
        FROM znft1030 AS z1
             INNER JOIN znft1020 AS z2
                ON z2~nfutn EQ z1~nfutn
             INNER JOIN znft1011 AS z4
                ON z4~reqno EQ z2~reqno AND z4~h_no1 EQ z2~h_no1
             INNER JOIN znft1010 AS z3
                ON z3~reqno EQ z4~reqno
             INNER JOIN znft1000 AS z5
                ON z5~conno EQ z4~conno
       WHERE z1~bukrs EQ p_bukrs
         AND z1~lcnam EQ space
         AND z1~confm IN ('3', '7')
         AND z1~yncan NE 'X'
         AND z1~ynnet NE 'X'
         AND z1~lcnam EQ space
         AND z5~cotyp NE '4'.

      IF lv_cnt IS NOT INITIAL.
        ADD lv_cnt TO gs_list-req_cnt.
      ENDIF.

      gs_list-req_type = 'G'.
      gs_list-req_list = '선물집행최종확인'.
      APPEND gs_list TO gt_list.
    ELSE.
*      gs_list-req_type = 'G'.
*      gs_list-req_list = '선물집행최종확인'.
*      gs_list-req_cnt  = 0.
*      APPEND gs_list TO gt_list.
    ENDIF.

  ENDIF.

ENDFORM.                    " GET_REQ_LIST

*&---------------------------------------------------------------------*
*&      Form  ALV_EVENT_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_NAME  text
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
FORM alv_event_hotspot_click  USING p_row_id TYPE lvc_s_row
                                    p_column_id.

  CLEAR : gs_list.
  DATA  : lv_req_type TYPE char01.
  CLEAR : lv_req_type.

  CHECK sy-dynnr EQ 1100.

  CASE p_column_id.
    WHEN 'REQ_CNT'.
      READ TABLE gt_list INTO gs_list INDEX p_row_id-index.

      IF gs_list-req_cnt EQ 0.
        MESSAGE s003 DISPLAY LIKE 'E'
           WITH gs_list-req_list
                '에 대한 승인처리 할 데이터가 존재하지 않습니다.'.
      ELSE.
        gv_type = gs_list-req_type.
        PERFORM data_select USING gv_type.
        PERFORM data_reload.
      ENDIF.
  ENDCASE.

ENDFORM.                    " ALV_EVENT_HOTSPOT_CLICK

*&---------------------------------------------------------------------*
*&      Form  DATA_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LIST_REQ_TYPE  text
*----------------------------------------------------------------------*
FORM data_select USING pv_reqtype.

  CLEAR gs_reqno. REFRESH gt_reqno.

  SET PARAMETER ID 'UNM' FIELD gv_uname.

  CASE pv_reqtype.
    WHEN 'A'.
      CALL TRANSACTION 'ZNF2R2520' AND SKIP FIRST SCREEN.
    WHEN 'B'.
      CALL TRANSACTION 'ZNF2R2530' AND SKIP FIRST SCREEN.
    WHEN 'C'.
      CALL TRANSACTION 'ZNF2R2540' AND SKIP FIRST SCREEN.
    WHEN 'D'.
      CALL TRANSACTION 'ZNF2R2550' AND SKIP FIRST SCREEN.
    WHEN 'E'.
      CALL TRANSACTION 'ZNF2R2560' AND SKIP FIRST SCREEN.
    WHEN 'F'.
      CALL TRANSACTION 'ZNF2R2570' AND SKIP FIRST SCREEN.
    WHEN 'G'.
      CALL TRANSACTION 'ZNF2R2580' AND SKIP FIRST SCREEN.
  ENDCASE.

  FREE MEMORY ID 'UNM'.

ENDFORM.                    " DATA_SELECT

*&---------------------------------------------------------------------*
*&      Form  DATA_RELOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_reload.

  PERFORM get_req_list.

  gs_stbl_h-row = 'X'.
  gs_stbl_h-col = 'X'.

  CALL METHOD grf_grid_h->refresh_table_display
    EXPORTING
      i_soft_refresh = ' '
      is_stable      = gs_stbl_h.     "화면 라인 Refresh

ENDFORM.                    " DATA_RELOAD

*&---------------------------------------------------------------------*
*&      Form  MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_screen .

  IF NOT ( sy-uname EQ 'ZERPMM'  OR sy-uname EQ 'ZLSGMM2' OR
           sy-uname EQ 'ZLSGMM'  OR sy-uname EQ 'ZLSGLSC' OR
           sy-uname EQ 'ZLSGLSM' OR sy-uname EQ 'ZTEST07').
    LOOP AT SCREEN.
      IF screen-name = 'P_UNAME' OR
        screen-name  = '%_P_UNAME_%_APP_%-TEXT'.
        screen-input     = 0.
        screen-invisible = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " MODIFY_SCREEN
