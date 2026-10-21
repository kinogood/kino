*----------------------------------------------------------------------*
***INCLUDE LZ_TI_COMMON_FUNCTIONSF01 .
*----------------------------------------------------------------------*
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2014/09/30    조성익   기능개선 44040 수입무환PO 수입제비용 처리 시
*                                       전표 생성 로직 수정요청
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  USER_POPUP_COMMAND
*&---------------------------------------------------------------------*
FORM user_popup_command USING r_ucomm LIKE sy-ucomm
                              index TYPE slis_selfield.

  DATA: l_msg LIKE xmsg.

  READ TABLE xmsg INDEX index-tabindex INTO l_msg.

  IF sy-subrc IS INITIAL AND
     ( r_ucomm EQ '&NT1' OR
       r_ucomm EQ '&IC1' OR
       r_ucomm EQ '&ETA' ).

    MOVE : l_msg-msgid TO t100-arbgb,
           l_msg-msgno TO t100-msgnr.

    CALL FUNCTION 'MASS_MESSAGE_SHOW_LONGTEXT'
      EXPORTING
        sprsl     = sy-langu
        arbgb     = t100-arbgb
        msgnr     = t100-msgnr
        msgv1     = l_msg-msgv1
        msgv2     = l_msg-msgv2
        msgv3     = l_msg-msgv3
        msgv4     = l_msg-msgv4
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CLEAR: r_ucomm.
  ELSE.
    MESSAGE s906(zmti00).
  ENDIF.

ENDFORM.                    " USER_POPUP_COMMAND


*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
FORM user_ok_tc USING    p_tc_name TYPE dynfnam
                         p_table_name
                         p_mark_name
                CHANGING p_ok      LIKE sy-ucomm.

  DATA: l_ok              TYPE sy-ucomm,
        l_offset          TYPE i.

*> Table control specific operations                          *
*> evaluate TC name and operations                            *
  SEARCH p_ok FOR p_tc_name.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
  l_offset = STRLEN( p_tc_name ) + 1.
  l_ok = p_ok+l_offset.
*> execute general and TC specific operations                 *
  CASE l_ok.
    WHEN 'OK'.                      "확인.
      answer = 'Y'.
      CLEAR: g_count.
      LOOP AT xprtctl WHERE flag EQ 'X'.
        ADD 1 TO g_count.
      ENDLOOP.
      IF g_count EQ 0.
        MESSAGE e908(zmti00).
      ENDIF.
      LEAVE TO SCREEN 0.
    WHEN 'EX'.                      "취소.
      CLEAR xprtctl-flag.
      MODIFY   xprtctl TRANSPORTING flag WHERE flag = 'X'.
      answer = 'N'.
      LEAVE TO SCREEN 0.
    WHEN 'INSR' OR 'INSR1' OR 'INSR2' OR 'INSR3'.   "insert row
      PERFORM fcode_insert_row USING    p_tc_name
                                        p_table_name.
      CLEAR p_ok.

    WHEN 'DELE' OR 'DELE1' OR 'DELE2' OR 'DELE3'.   "delete row
      PERFORM fcode_delete_row USING    p_tc_name
                                        p_table_name
                                        p_mark_name.
      CLEAR p_ok.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++' OR                     "bottom of list
         'P--1' OR                    "top of list
         'P-1'  OR                    "previous page
         'P+1'  OR                    "next page
         'P++1' OR                    "bottom of list
         'P--2' OR                    "top of list
         'P-2'  OR                    "previous page
         'P+2'  OR                    "next page
         'P++2' OR                    "bottom of list
         'P--3' OR                    "top of list
         'P-3'  OR                    "previous page
         'P+3'  OR                    "next page
         'P++3'.                      "bottom of list

      PERFORM compute_scrolling_in_tc USING p_tc_name
                                            l_ok.
      CLEAR p_ok.
*>"mark all filled lines
    WHEN 'MARK' OR 'MARK1' OR 'MARK2' OR 'MARK3'.
      PERFORM fcode_tc_mark_lines USING p_tc_name
                                        p_table_name
                                        p_mark_name   .
      CLEAR p_ok.
*>"demark all filled lines
    WHEN 'DMRK' OR 'DMRK1' OR 'DMRK2' OR 'DMRK3'.
      PERFORM fcode_tc_demark_lines USING p_tc_name
                                          p_table_name
                                          p_mark_name .
      CLEAR p_ok.

  ENDCASE.

ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_insert_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_lines_name       LIKE feld-name.
  DATA l_selline          LIKE sy-stepl.
  DATA l_lastline         TYPE i.
  DATA l_line             TYPE i.
  DATA l_table_name       LIKE feld-name.
  FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
  FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
  FIELD-SYMBOLS <lines>              TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_lines_name.
  ASSIGN (l_lines_name) TO <lines>.

*&SPWIZARD: get current line                                           *
  GET CURSOR LINE l_selline.
  IF sy-subrc <> 0.                   " append line to table
    l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line                                               *
    IF l_selline > <lines>.
      <tc>-top_line = l_selline - <lines> + 1 .
    ELSE.
      <tc>-top_line = 1.
    ENDIF.
  ELSE.                               " insert line into table
    l_selline = <tc>-top_line + l_selline - 1.
    l_lastline = <tc>-top_line + <lines> - 1.
  ENDIF.
*&SPWIZARD: set new cursor line                                        *
  l_line = l_selline - <tc>-top_line + 1.

*&SPWIZARD: insert initial line                                        *
  INSERT INITIAL LINE INTO <table> INDEX l_selline.
  <tc>-lines = <tc>-lines + 1.
*&SPWIZARD: set cursor                                                 *
  SET CURSOR LINE l_line.

ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_delete_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name
                       p_mark_name   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
  DESCRIBE TABLE <table> LINES <tc>-lines.

  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    IF <mark_field> = 'X'.
      DELETE <table> INDEX syst-tabix.
      IF sy-subrc = 0.
        <tc>-lines = <tc>-lines - 1.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
FORM compute_scrolling_in_tc USING    p_tc_name
                                      p_ok.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_tc_new_top_line     TYPE i.
  DATA l_tc_name             LIKE feld-name.
  DATA l_tc_lines_name       LIKE feld-name.
  DATA l_tc_field_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <lines>      TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.
*&SPWIZARD: get looplines of TableControl                              *
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
  ASSIGN (l_tc_lines_name) TO <lines>.


*&SPWIZARD: is no line filled?                                         *
  IF <tc>-lines = 0.
*&SPWIZARD: yes, ...                                                   *
    l_tc_new_top_line = 1.
  ELSE.
*&SPWIZARD: no, ...                                                    *
    CALL FUNCTION 'SCROLLING_IN_TABLE'
         EXPORTING
              entry_act             = <tc>-top_line
              entry_from            = 1
              entry_to              = <tc>-lines
              last_page_full        = 'X'
              loops                 = <lines>
              ok_code               = p_ok
              overlapping           = 'X'
         IMPORTING
              entry_new             = l_tc_new_top_line
         EXCEPTIONS
*              NO_ENTRY_OR_PAGE_ACT  = 01
*              NO_ENTRY_TO           = 02
*              NO_OK_CODE_OR_PAGE_GO = 03
              OTHERS                = 0.
  ENDIF.

*&SPWIZARD: get actual tc and column                                   *
  GET CURSOR FIELD l_tc_field_name
             AREA  l_tc_name.

  IF syst-subrc = 0.
    IF l_tc_name = p_tc_name.
*&SPWIZARD: et actual column                                           *
      SET CURSOR FIELD l_tc_field_name LINE 1.
    ENDIF.
  ENDIF.

*&SPWIZARD: set the new top line                                       *
  <tc>-top_line = l_tc_new_top_line.


ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_mark_lines USING p_tc_name
                               p_table_name
                               p_mark_name.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_demark_lines USING p_tc_name
                                 p_table_name
                                 p_mark_name .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = space.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*&      Form  user_ok_tc_no_button
*&---------------------------------------------------------------------*
FORM user_ok_tc_no_button USING    p_tc_name TYPE dynfnam
                                   p_table_name
                                   p_mark_name
                          CHANGING p_ok      LIKE sy-ucomm.

  DATA: l_ok              TYPE sy-ucomm,
        l_offset          TYPE i.

*> Table control specific operations                          *
*> evaluate TC name and operations                            *
  SEARCH p_ok FOR p_tc_name.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  l_offset = STRLEN( p_ok ) - 1.
  l_ok     = p_ok+l_offset.
  CASE l_ok.
    WHEN '1'.     CHECK g_lcity EQ '7'.
    WHEN '2'.     CHECK g_lcity EQ '8'.
    WHEN '3'.     CHECK g_lcity EQ '9'.
    WHEN OTHERS.  EXIT.
  ENDCASE.

  l_offset = STRLEN( p_tc_name ) + 1.
  l_ok     = p_ok+l_offset.


*> execute general and TC specific operations                 *
  CASE l_ok.
    WHEN 'OK'.                      "확인.
      answer = 'Y'.
      CLEAR: g_count.
      LOOP AT xprtctl WHERE flag EQ 'X'.
        ADD 1 TO g_count.
      ENDLOOP.
      IF g_count EQ 0.
        MESSAGE e908(zmti00).
      ENDIF.
      LEAVE TO SCREEN 0.
    WHEN 'EX'.                      "취소.
      CLEAR xprtctl-flag.
      MODIFY   xprtctl TRANSPORTING flag WHERE flag = 'X'.
      answer = 'N'.
      LEAVE TO SCREEN 0.
    WHEN 'INSR' OR 'INSR1' OR 'INSR2' OR 'INSR3'.   "insert row
      PERFORM fcode_insert_row USING    p_tc_name
                                        p_table_name.
      CLEAR p_ok.

    WHEN 'DELE' OR 'DELE1' OR 'DELE2' OR 'DELE3'.   "delete row
      PERFORM fcode_delete_row USING    p_tc_name
                                        p_table_name
                                        p_mark_name.
      CLEAR p_ok.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++' OR                     "bottom of list
         'P--1' OR                    "top of list
         'P-1'  OR                    "previous page
         'P+1'  OR                    "next page
         'P++1' OR                    "bottom of list
         'P--2' OR                    "top of list
         'P-2'  OR                    "previous page
         'P+2'  OR                    "next page
         'P++2' OR                    "bottom of list
         'P--3' OR                    "top of list
         'P-3'  OR                    "previous page
         'P+3'  OR                    "next page
         'P++3'.                      "bottom of list

      PERFORM compute_scrolling_in_tc USING p_tc_name
                                            l_ok.
      CLEAR p_ok.
*>"mark all filled lines
    WHEN 'MARK' OR 'MARK1' OR 'MARK2' OR 'MARK3'.
      PERFORM fcode_tc_mark_lines USING p_tc_name
                                        p_table_name
                                        p_mark_name   .
      CLEAR p_ok.
*>"demark all filled lines
    WHEN 'DMRK' OR 'DMRK1' OR 'DMRK2' OR 'DMRK3'.
      PERFORM fcode_tc_demark_lines USING p_tc_name
                                          p_table_name
                                          p_mark_name .
      CLEAR p_ok.

  ENDCASE.

ENDFORM.                              " USER_OK_TC_NO_BUTTON
*&---------------------------------------------------------------------*
*&      Form  DOC_HISTORY_SELECTION_BUILD
*&---------------------------------------------------------------------*
*       Selection screen상 selection 조건 테이블 build
*----------------------------------------------------------------------*
FORM doc_history_selection_build
                       TABLES pt_selscreen STRUCTURE rsparams
                       USING  p_ebeln      TYPE      ebeln
                              p_ebelp      TYPE      ebelp.

* fill selections: first single values & parameters
  pt_selscreen-selname = 'S_EBELN'.
  pt_selscreen-kind    = 'S'.
  pt_selscreen-sign    = 'I'.
  pt_selscreen-option  = 'EQ'.
  pt_selscreen-low     = p_ebeln.
  APPEND pt_selscreen.

** fill selections: first single values & parameters
*  IF NOT p_ebelp IS INITIAL.
*    pt_selscreen-selname = 'S_EBELP'.
*    pt_selscreen-kind    = 'S'.
*    pt_selscreen-sign    = 'I'.
*    pt_selscreen-option  = 'EQ'.
*    pt_selscreen-low     = p_ebelp.
*    APPEND pt_selscreen.
*  ENDIF.

ENDFORM.                    " DOC_HISTORY_SELECTION_BUILD
*&---------------------------------------------------------------------*
*&      Form  doc_history_callback_BUILD
*&---------------------------------------------------------------------*
*       call back form 정의.
*----------------------------------------------------------------------*
FORM doc_history_callback_build  TABLES   pt_callback STRUCTURE ldbcb.

  REFRESH: pt_callback.
  pt_callback-ldbnode = 'ZTIVPO01'.
  pt_callback-get     = 'X'.
  pt_callback-cb_prog = c_repid.
  pt_callback-cb_form = 'ZTIL01_GET_ZTIVPO01'.
  APPEND pt_callback.
*> 적하보험.
  pt_callback-ldbnode = 'ZTITIP1'.
  pt_callback-get     = 'X'.
  pt_callback-cb_prog = c_repid.
  pt_callback-cb_form = 'ZTIL01_GET_ZTITIP1'.
  APPEND pt_callback.
*> 선급금
  pt_callback-ldbnode = 'ZTIVIV01'.
  pt_callback-get     = 'X'.
  pt_callback-cb_prog = c_repid.
  pt_callback-cb_form = 'ZTIL01_GET_ZTIVIV01'.
  APPEND pt_callback.
*> B/L
  pt_callback-ldbnode = 'ZTIVBL00'.
  pt_callback-get     = 'X'.
  pt_callback-cb_prog = c_repid.
  pt_callback-cb_form = 'ZTIL01_GET_ZTIVBL00'.
  APPEND pt_callback.
*> I/V
  pt_callback-ldbnode = 'ZTIVIV00'.
  pt_callback-get     = 'X'.
  pt_callback-cb_prog = c_repid.
  pt_callback-cb_form = 'ZTIL01_GET_ZTIVIV00'.
  APPEND pt_callback.
*> I/V
  pt_callback-ldbnode = 'ZTIVPN00'.
  pt_callback-get     = 'X'.
  pt_callback-cb_prog = c_repid.
  pt_callback-cb_form = 'ZTIL01_GET_ZTIVPN00'.
  APPEND pt_callback.
*> L/G
  pt_callback-ldbnode = 'ZTITLG1'.
  pt_callback-get     = 'X'.
  pt_callback-cb_prog = c_repid.
  pt_callback-cb_form = 'ZTIL01_GET_ZTITLG1'.
  APPEND pt_callback.
*> 반입예정정보.
  pt_callback-ldbnode = 'ZTITBSK'.
  pt_callback-get     = 'X'.
  pt_callback-cb_prog = c_repid.
  pt_callback-cb_form = 'ZTIL01_GET_ZTITBSK'.
  APPEND pt_callback.
*> 반입정보.
  pt_callback-ldbnode = 'ZTITBIK'.
  pt_callback-get     = 'X'.
  pt_callback-cb_prog = c_repid.
  pt_callback-cb_form = 'ZTIL01_GET_ZTITBIK'.
  APPEND pt_callback.
*> 반출정보.
  pt_callback-ldbnode = 'ZTITBOK'.
  pt_callback-get     = 'X'.
  pt_callback-cb_prog = c_repid.
  pt_callback-cb_form = 'ZTIL01_GET_ZTITBOK'.
  APPEND pt_callback.
*> 수입신고의뢰.
  pt_callback-ldbnode = 'ZTIVCR00'.
  pt_callback-get     = 'X'.
  pt_callback-cb_prog = c_repid.
  pt_callback-cb_form = 'ZTIL01_GET_ZTIVCR00'.
  APPEND pt_callback.
*> C/C
  pt_callback-ldbnode = 'ZTIVCC00'.
  pt_callback-get     = 'X'.
  pt_callback-cb_prog = c_repid.
  pt_callback-cb_form = 'ZTIL01_GET_ZTIVCC00'.
  APPEND pt_callback.
*> G/R
  pt_callback-ldbnode = 'ZTIVGR00'.
  pt_callback-get     = 'X'.
  pt_callback-cb_prog = c_repid.
  pt_callback-cb_form = 'ZTIL01_GET_ZTIVGR00'.
  APPEND pt_callback.

ENDFORM.                    " doc_history_callback_BUILD
*&---------------------------------------------------------------------*
*&      Form  pbo_document_history_tree
*&---------------------------------------------------------------------*
*       문서이력 조회용 Tree build
*----------------------------------------------------------------------*
FORM pbo_document_history_tree .

  DATA: l_container(20)    TYPE c,
        l_handle           TYPE cntl_handle,
        l_hierarchy_header LIKE treev_hdr,
        l_item             LIKE mtreeitm,
        l_tabix            LIKE sy-tabix,
        l_this_repid       LIKE sy-repid,
        l_this_dynnr       LIKE sy-dynnr,
        lt_columns         LIKE treev_col  OCCURS 0,
        lt_headers         LIKE treev_hdr  OCCURS 0,
        lt_nodes           LIKE treev_node OCCURS 0,
        lt_items           LIKE mtreeitm   OCCURS 0.

  IF g_tree_handle IS INITIAL.

    l_this_repid = sy-repid.
    l_this_dynnr = sy-dynnr.
    l_container  = 'TREE_SCR2128'.

    PERFORM build_columns          TABLES   lt_columns.
    PERFORM build_hierarchy_header CHANGING l_hierarchy_header.
    PERFORM build_headers          TABLES   lt_headers.
    PERFORM build_nodes_and_items  TABLES   lt_nodes
                                            lt_items.

* if no tree existe create new one and register callbacks
    PERFORM build_tree TABLES   lt_columns
                                lt_headers
                                lt_nodes
                                lt_items
                       USING    l_this_repid
                                l_this_dynnr
                                l_hierarchy_header
                                l_container
                       CHANGING l_handle.

    PERFORM register_callbacks CHANGING l_handle.

    g_tree_handle = l_handle.

  ENDIF.

ENDFORM.                    " pbo_document_history_tree
*&---------------------------------------------------------------------*
*&      Form  build_columns
*&---------------------------------------------------------------------*
FORM build_columns   TABLES pt_columns STRUCTURE treev_col.

  DATA: l_column LIKE treev_col.

  REFRESH pt_columns.

  CLEAR l_column.
  l_column-name       = c_column1.
  l_column-alignment  = treev_align_auto.
*  l_column-width      = 40.
*  l_column-width_char = ' '.
  l_column-hidden     = ' '.
  l_column-selectable = 'X'.
  APPEND l_column TO pt_columns.

  CLEAR l_column.
  l_column-name       = c_column2.
  l_column-alignment  = treev_align_auto.
*  l_column-width      = 12.
*  l_column-width_char = ' '.
  l_column-hidden     = ' '.
  l_column-selectable = 'X'.
  APPEND l_column TO pt_columns.

  CLEAR l_column.
  l_column-name       = c_column3.
  l_column-alignment  = treev_align_auto.
*  l_column-width      = 12.
*  l_column-width_char = ' '.
  l_column-hidden     = ' '.
  l_column-selectable = 'X'.
  APPEND l_column TO pt_columns.

  CLEAR l_column.
  l_column-name       = c_column4.
  l_column-alignment  = treev_align_auto.
*  l_column-width      = 12.
*  l_column-width_char = ' '.
  l_column-hidden     = ' '.
  l_column-selectable = 'X'.
  APPEND l_column TO pt_columns.

  CLEAR l_column.
  l_column-name       = c_column5.
  l_column-alignment  = treev_align_auto.
*  l_column-width      = 12.
*  l_column-width_char = ' '.
  l_column-hidden     = ' '.
  l_column-selectable = 'X'.
  APPEND l_column TO pt_columns.

  CLEAR l_column.
  l_column-name       = c_column6.
  l_column-alignment  = treev_align_auto.
*  l_column-width      = 12.
*  l_column-width_char = ' '.
  l_column-hidden     = ' '.
  l_column-selectable = 'X'.
  APPEND l_column TO pt_columns.

  CLEAR l_column.
  l_column-name       = c_column7.
  l_column-alignment  = treev_align_auto.
*  l_column-width      = 12.
*  l_column-width_char = ' '.
  l_column-hidden     = ' '.
  l_column-selectable = 'X'.
  APPEND l_column TO pt_columns.

ENDFORM.                    " build_columns
*&---------------------------------------------------------------------*
*&      Form  build_hierarchy_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_hierarchy_header  CHANGING p_hierarchy_header LIKE treev_hdr.

  CLEAR p_hierarchy_header.
*  p_hierarchy_header-name      = c_header1.
  p_hierarchy_header-end_col   = c_column1.
  p_hierarchy_header-heading   = '수입문서 구분'.
  p_hierarchy_header-width     = 50.
  p_hierarchy_header-width_pix = ' '.
  p_hierarchy_header-type      = treev_header_variable.
  p_hierarchy_header-alignment = treev_align_left.

ENDFORM.                    " build_hierarchy_header
*&---------------------------------------------------------------------*
*&      Form  build_headers
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_headers   TABLES pt_headers STRUCTURE treev_hdr.

  DATA: l_header LIKE treev_hdr.

  REFRESH pt_headers.
  CLEAR: l_header.
  l_header-name      = c_header2.
  l_header-end_col   = c_column2.
  l_header-heading   = '문서번호'.
  l_header-width     = 14.
  l_header-width_pix = ' '.
  l_header-type      = treev_header_variable.
  l_header-alignment = treev_align_left.
  APPEND l_header TO pt_headers.

  CLEAR: l_header.
  l_header-name      = c_header3.
  l_header-end_col   = c_column3.
  l_header-heading   = 'Seq.'.
  l_header-width     = 5.
  l_header-width_pix = ' '.
  l_header-type      = treev_header_variable.
  l_header-alignment = treev_align_center.
  APPEND l_header TO pt_headers.

  CLEAR: l_header.
  l_header-name      = c_header4.
  l_header-end_col   = c_column4.
  l_header-heading   = '금액'.
  l_header-width     = 23.
  l_header-width_pix = ' '.
  l_header-type      = treev_header_auto.
  l_header-alignment = treev_align_right.
  APPEND l_header TO pt_headers.

  CLEAR: l_header.
  l_header-name      = c_header5.
  l_header-end_col   = c_column5.
  l_header-heading   = '통화'.
  l_header-width     = 6.
  l_header-width_pix = ' '.
  l_header-type      = treev_header_variable.
  l_header-alignment = treev_align_center.
  APPEND l_header TO pt_headers.

  CLEAR: l_header.
  l_header-name      = c_header6.
  l_header-end_col   = c_column6.
  l_header-heading   = '관련일자'.
  l_header-width     = 14.
  l_header-width_pix = ' '.
  l_header-type      = treev_header_variable.
  l_header-alignment = treev_align_center.
  APPEND l_header TO pt_headers.

  CLEAR: l_header.
  l_header-name      = c_header7.
  l_header-end_col   = c_column7.
  l_header-heading   = '관련문서번호'.
  l_header-width     = 40.
  l_header-width_pix = ' '.
  l_header-type      = treev_header_variable.
  l_header-alignment = treev_align_left.
  APPEND l_header TO pt_headers.

ENDFORM.                    " build_headers
*&---------------------------------------------------------------------*
*&      Form  register_callbacks
*&---------------------------------------------------------------------*
FORM register_callbacks  CHANGING p_tree TYPE cntl_handle.

*  CALL FUNCTION 'TREEV_EVENT_CB_SEL_CHANGE'
*       EXPORTING
*            CALLBACK_FORM              = 'HANDLE_TREE_SEL_CHANGE'
**      IMPORTING
**           CALLBACK_ID                =
*       CHANGING
*            HANDLE                     = P_TREE
*       EXCEPTIONS
*            CB_NOT_FOUND               = 1
*            FAILED                     = 2
*            INSTANCE_NOT_FOUND         = 3
*            INV_CALLBACK_DEFINITION    = 4
*            ITEM_SELECTION_NOT_ALLOWED = 5
*            SINGLE_NODE_SELECTION_ONLY = 6
*            OTHERS                     = 7.
*  IF SY-SUBRC <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*
  CALL FUNCTION 'TREEV_EVENT_CB_NODE_DBL_CLK'
    EXPORTING
      callback_form                 = 'HANDLE_NODE_DBL_CLK'
*    IMPORTING
*      CALLBACK_ID                   =
    CHANGING
      handle                        = p_tree
    EXCEPTIONS
      cb_not_found                  = 1
      failed                        = 2
      inv_callback_definition       = 3
      OTHERS                        = 4.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL FUNCTION 'TREEV_EVENT_CB_ITEM_DBL_CLK'
    EXPORTING
      callback_form                 = 'HANDLE_ITEM_DBL_CLK'
* IMPORTING
*   CALLBACK_ID                       =
    CHANGING
      handle                        = p_tree
   EXCEPTIONS
     cb_not_found                   = 1
     failed                         = 2
     instance_not_found             = 3
     not_allowed_for_simple_tree    = 4
     inv_callback_definition        = 5
     no_item_selection              = 6
     OTHERS                         = 7 .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
*
ENDFORM.                    " register_callbacks

*&---------------------------------------------------------------------*
*&      Form  build_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_tree TABLES   t_columns          STRUCTURE treev_col
                         t_headers          STRUCTURE treev_hdr
                         t_nodes            STRUCTURE treev_node
                         t_items
                USING    p_repid            LIKE      sy-repid
                         p_dynnr            LIKE      sy-dynnr
                         p_hierarchy_header LIKE      treev_hdr
                         p_container
                CHANGING c_handle           TYPE      cntl_handle.

  CALL FUNCTION 'TREEV_CREATE_COLUMN_TREE'
       EXPORTING
            owner_repid                    = p_repid
            dynnr                          = p_dynnr
            container                      = p_container
            left                           = 0
            top                            = 0
            width                          = 0
            height                         = 0
*           ALIGNMENT                      =
*           METRIC                         = CNTL_METRIC_DYNPRO
            no_flush                       = 'X'
*           LINK_REPID                     =
*           SHELLSTYLE                     =
*           PARENTID                       =
*            reg_event_expand_no_children   = ' '
            register_event_item_dbl_click  = 'X'
            register_event_node_dbl_click  = 'X'
*            register_event_header_click    = ' '
*            register_event_node_context_m  = ' '
*            register_event_item_context_m  = ' '
*            register_event_link_click      = ' '
*            register_event_button_click    = ' '
*            register_event_checkbox_change = ' '
*            register_event_sel_change      = ' '
            item_selection                 = 'X'
            node_selection_mode            = treev_node_sel_mode_single
*           GROUP_HEADERS                  =
*           HIDE_SELECTION                 =
            hierarchy_header               = p_hierarchy_header
            item_table_structure_name      = 'MTREEITM'
       TABLES
            columns                        = t_columns
            headers                        = t_headers
            node_table                     = t_nodes
            item_table                     = t_items
       CHANGING
            handle                         = c_handle
       EXCEPTIONS
            create_error                   = 1
            tree_control_not_existing      = 2
            cntl_system_error              = 3
            failed                         = 4
            illegal_node_selection_mode    = 5
            illegal_column_name            = 6
            illegal_column_alignment       = 7
            illegal_header_alignment       = 8
            illegal_header_type            = 9
            illegal_header_name            = 10
            duplicated_column_name         = 11
            duplicated_header_name         = 12
            illegal_end_col                = 13
            end_col_not_found              = 14
            missing_item_structure_name    = 15
            empty_node_table               = 16
            empty_item_table               = 17
            error_in_tables                = 18
            dp_error                       = 19
            illegal_owner_repid            = 20
            too_many_columns               = 21
            table_structure_name_not_found = 22
            multi_column_header            = 23
            OTHERS                         = 24.
  IF sy-subrc NE 0.
    MESSAGE a001(treecontrol) WITH 'TREEV_CREATE_COLUMN_TREE'.
  ENDIF.

  CALL FUNCTION 'TREEV_EXPAND_ROOT_NODES'
    EXPORTING
      handle              = c_handle
      level_count         = 1
      expand_all_children = 'X'
      no_flush            = 'X'
    EXCEPTIONS
      failed              = 1
      illegal_level_count = 2
      cntl_system_error   = 3
      OTHERS              = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF NOT g_set_nodekey IS INITIAL.
    CALL FUNCTION 'TREEV_SET_SELECTED_NODE'
      EXPORTING
        handle                     = c_handle
        node_key                   = g_set_nodekey
*        no_flush                   =
      EXCEPTIONS
        failed                     = 1
        instance_not_found         = 2
        single_node_selection_only = 3
        cntl_system_error          = 4
        node_not_found             = 5
        OTHERS                     = 6.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'CONTROL_FLUSH'
    EXCEPTIONS
      cntl_system_error = 1
      cntl_error        = 2
      OTHERS            = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " build_tree
*&---------------------------------------------------------------------*
*&      Form  BUILD_NODES_AND_ITEMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_nodes_and_items TABLES   pt_nodes STRUCTURE treev_node
                                    pt_items STRUCTURE mtreeitm.

  DATA: l_item     LIKE mtreeitm,
        l_node     LIKE treev_node,
        l_tdtext   LIKE ttxit-tdtext,
        l_thead    LIKE thead,
        l_texttype LIKE mmpur_texttypes,
        lt_reftext LIKE thead OCCURS 0,
        l_text(23) TYPE c,
        ls_dochis  LIKE it_dochis.

  LOOP AT it_dochis.
    l_node-node_key = it_dochis-nodekey.
    l_node-relatkey = it_dochis-relatkey.

    l_node-hidden   = ' '.
    l_node-disabled = ' '.
    CLEAR l_node-n_image.
    CLEAR l_node-exp_image.
    l_node-expander = ' '.

    READ TABLE it_dochis INTO ls_dochis
                         WITH KEY relatkey = l_node-node_key.
    g_subrc = sy-subrc.

    IF sy-subrc EQ 0.
      l_node-isfolder  = 'X'.
      l_node-n_image   = icon_otf_document.
      l_node-exp_image = icon_otf_document.
      CLEAR l_node-relatship.
    ELSE.
      CLEAR l_node-isfolder.
      l_node-relatship = treev_relat_last_child.
    ENDIF.
    APPEND l_node TO pt_nodes.

    CLEAR l_item.
    l_item-node_key  = it_dochis-nodekey.
    l_item-item_name = c_column1.
    l_item-class     = treev_item_class_text.
    l_item-text      = it_dochis-docct.
*    if g_subrc ne 0.
*       l_item-T_IMAGE = ICON_OTF_DOCUMENT.
*    endif.
    IF g_set_nodekey EQ l_item-node_key.
      l_item-style     = 5.
    ELSE.
      l_item-style     = 1.
    ENDIF.
    APPEND l_item TO pt_items.

    CLEAR l_item.
    l_item-node_key  = it_dochis-nodekey.
    l_item-item_name = c_column2.
    l_item-class     = treev_item_class_text.
    l_item-text      = it_dochis-docnb.
    IF g_set_nodekey EQ l_item-node_key.
      l_item-style     = 4.
    ELSE.
      l_item-style     = 1.
    ENDIF.
    APPEND l_item TO pt_items.

    CLEAR l_item.
    l_item-node_key  = it_dochis-nodekey.
    l_item-item_name = c_column3.
    l_item-class     = treev_item_class_text.
    l_item-text      = it_dochis-amdsq.
    IF g_set_nodekey EQ l_item-node_key.
      l_item-style     = 4.
    ELSE.
      l_item-style     = 1.
    ENDIF.
    APPEND l_item TO pt_items.

    CLEAR : l_item, l_text.
    l_item-node_key  = it_dochis-nodekey.
    l_item-item_name = c_column4.
    l_item-class     = treev_item_class_text.
*    l_item-text      = it_dochis-docct.
    WRITE it_dochis-docat TO l_text
                          CURRENCY it_dochis-waers.
    l_item-text      = l_text.

    IF g_set_nodekey EQ l_item-node_key.
      l_item-style     = 4.
    ELSE.
      l_item-style     = 2.
    ENDIF.
    APPEND l_item TO pt_items.

    CLEAR l_item.
    l_item-node_key  = it_dochis-nodekey.
    l_item-item_name = c_column5.
    l_item-class     = treev_item_class_text.
    l_item-text      = it_dochis-waers.
    IF g_set_nodekey EQ l_item-node_key.
      l_item-style     = 4.
    ELSE.
      l_item-style     = 2.
    ENDIF.
    APPEND l_item TO pt_items.

    CLEAR l_item.
    l_item-node_key  = it_dochis-nodekey.
    l_item-item_name = c_column6.
    l_item-class     = treev_item_class_text.
    WRITE it_dochis-docdt TO l_item-text.
    IF g_set_nodekey EQ l_item-node_key.
      l_item-style     = 4.
    ELSE.
      l_item-style     = 1.
    ENDIF.
    APPEND l_item TO pt_items.

    CLEAR l_item.
    l_item-node_key  = it_dochis-nodekey.
    l_item-item_name = c_column7.
    l_item-class     = treev_item_class_text.
    l_item-text      = it_dochis-docnm.
    IF g_set_nodekey EQ l_item-node_key.
      l_item-style     = 4.
    ELSE.
      l_item-style     = 1.
    ENDIF.

    APPEND l_item TO pt_items.

*    CLEAR l_item.
*    l_item-node_key  = it_dochis-nodekey.
*    l_item-item_name = c_column7.
*    l_item-class     = treev_item_class_text.
*    l_item-text      = it_dochis-docnm.
*    l_item-style     = 6.
*    APPEND l_item TO pt_items.

  ENDLOOP.

ENDFORM.                               " BUILD_NODES_AND_ITEMS

*&---------------------------------------------------------------------*
*&      Form  display_selected_node_info
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_selected_node_info  USING    p_node_key.

  DATA:         l_strlen   TYPE i.

  CHECK NOT p_node_key IS INITIAL.

*> 현재문서 라인을 더블클릭했을 경우.
  CHECK g_set_nodekey NE p_node_key.

  READ TABLE it_dochis WITH KEY nodekey = p_node_key.
  IF sy-subrc EQ 0.
    CASE it_dochis-doccl.
      WHEN 'P'.
        PERFORM  display_purchase_order(ztir0000)
                                        USING it_dochis-docnb
                                              '00000'.
      WHEN '0' OR '1' OR '2' OR '3' OR '4' OR
           '5' OR '6' OR '7' OR '8' OR '9' OR
           'M'.
        PERFORM  display_import_document(ztir0000)
                                        USING it_dochis-docnb
                                              it_dochis-amdsq
                                              '00000'.
      WHEN 'I'.
        PERFORM  display_ip_document(ztir0000)
                                        USING it_dochis-docnb
                                              it_dochis-amdsq.
      WHEN 'B'.   "> B/L 문서.
        PERFORM  display_bl_document(ztir0000)
                                        USING it_dochis-docnb
                                              '00000'.
      WHEN 'L'.   "> L/G 문서.
        PERFORM  display_lg_document(ztir0000)
                                        USING it_dochis-docnb.
      WHEN 'R'.   "> 수입신고 문서.
        PERFORM  display_cr_document(ztir0000)
                                        USING it_dochis-docnb
                                              it_dochis-amdsq.
      WHEN 'C'.   "> 수입필증 문서.
        PERFORM display_cc_document(ztir0000)
                                        USING it_dochis-docnb
                                              it_dochis-amdsq.
      WHEN 'V' OR 'Z'.   "> 송장/선급금 문서.
        PERFORM  display_civ_document(ztir0000)
                                        USING it_dochis-docnb.
      WHEN 'G'.           "> 입고.
        PERFORM  display_gr_document(ztir0000)
                                        USING it_dochis-docnb.
      WHEN 'Y'.           ">Notice.
        PERFORM  display_pn_document(ztir0000)
                                        USING it_dochis-docnb.
      WHEN OTHERS.
    ENDCASE.
  ELSE.
    MESSAGE s903.
  ENDIF.

ENDFORM.                    " display_selected_node_info
*&---------------------------------------------------------------------*
*&      Form  get_items_net_price_by_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_items_net_price_by_request TABLES xztitrqk  STRUCTURE ztitrqk
                                           xztislcit STRUCTURE ztisrqit
                                     USING p_reqno
                                           p_amdsq
                                           p_ebeln
                                           p_netwr.

  DATA: ls_proj  LIKE proj.

  CLEAR: p_netwr.

  IF p_ebeln IS INITIAL.

    LOOP AT xztislcit WHERE   reqno = p_reqno
                        AND   amdsq = p_amdsq
                        AND   repos = 'X'.
      g_tabix = sy-tabix.
*---> 위탁자재일 경우.
      IF xztislcit-ebeln IS INITIAL.
        CLEAR:rkwa.
*----> 수입의뢰 헤더.
        READ TABLE xztitrqk WITH KEY reqno = xztislcit-reqno.

        SELECT SINGLE *
          FROM rkwa
         WHERE mblnr   = xztislcit-mblnr
           AND mjahr   = xztislcit-mjahr
           AND zeile   = xztislcit-zeile.

        MOVE: 1          TO xztislcit-peinh,
              1          TO xztislcit-bpumz,
              1          TO xztislcit-bpumn,
              rkwa-bstmg TO xztislcit-menge,
              rkwa-bstme TO xztislcit-meins,
              rkwa-werks TO xztislcit-werks,
              rkwa-matnr TO xztislcit-matnr.
*-----> Get WBS Element
        SELECT SINGLE ps_psp_pnr
          INTO xztislcit-ps_psp_pnr
          FROM mseg
         WHERE mblnr   = xztislcit-mblnr
           AND mjahr   = xztislcit-mjahr
           AND zeile   = xztislcit-zeile.

        IF xztislcit-ps_psp_pnr IS INITIAL.
          IF rkwa-bstmg EQ 0.
            xztislcit-netpr = 0.
          ELSE.
            xztislcit-netpr = rkwa-wrbtr / rkwa-bstmg.
          ENDIF.
        ELSE.
          PERFORM get_parent_wbs_element(ztir0000)
                                         USING xztislcit-ps_psp_pnr
                                               ls_proj.
          MOVE: ls_proj-pspnr   TO xztislcit-ps_psp_pnr.

*        SELECT SINGLE netpr
*          INTO xztislcit-netpr
*          FROM zmmt0003
*         WHERE lifnr EQ xZTITRQK-lifnr
*           AND matnr EQ xztislcit-matnr
*           AND pspid EQ xztislcit-ps_psp_pnr
*           AND sdate LE rkwa-budat
*           AND edate GE rkwa-budat.
          xztislcit-netwr = xztislcit-netpr * rkwa-bstmg.
        ENDIF.
      ELSE.
**---> 기타자재일 경우.
*      SELECT SINGLE menge werks lgort matnr txz01
*                    loekz elikz bprme bpumz bpumn umrez
*                    umren netpr peinh uebto uebtk untto
*                    repos wepos
*      INTO CORRESPONDING FIELDS OF xZTIslcit
*        FROM ekpo
*       WHERE ebeln  EQ  xZTIslcit-ebeln
*         AND ebelp  EQ  xZTIslcit-ebelp.
      ENDIF.

*---> 품목별 정가를 계산함.
      IF xztislcit-peinh IS INITIAL.
        xztislcit-peinh = 1.
      ENDIF.
      IF xztislcit-bpumz IS INITIAL.
        xztislcit-bpumz = 1.
      ENDIF.
      IF xztislcit-bpumn IS INITIAL.
        xztislcit-bpumn = 1.
      ENDIF.

      CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
        EXPORTING
          peinh = xztislcit-peinh
          bpumz = xztislcit-bpumz
          bpumn = xztislcit-bpumn
          menge = xztislcit-rqmng
          netpr = xztislcit-netpr
        CHANGING
          netwr = xztislcit-netwr.

      MODIFY xztislcit INDEX g_tabix.
*-----> 정가 총합계산.
      ADD xztislcit-netwr TO p_netwr.
    ENDLOOP.

****************************  사후건 일 경우.....
  ELSE.

    LOOP AT xztislcit WHERE   reqno = space
                        AND   ebeln = p_ebeln
*                      AND   amdsq = p_amdsq
                        AND   repos = 'X'.
      g_tabix = sy-tabix.
*---> 위탁자재일 경우.
      IF xztislcit-ebeln IS INITIAL.
        CLEAR:rkwa.
*----> 수입의뢰 헤더.
        READ TABLE xztitrqk WITH KEY reqno = xztislcit-reqno.

        SELECT SINGLE *
          FROM rkwa
         WHERE mblnr   = xztislcit-mblnr
           AND mjahr   = xztislcit-mjahr
           AND zeile   = xztislcit-zeile.

        MOVE: 1          TO xztislcit-peinh,
              1          TO xztislcit-bpumz,
              1          TO xztislcit-bpumn,
              rkwa-bstmg TO xztislcit-menge,
              rkwa-bstme TO xztislcit-meins,
              rkwa-werks TO xztislcit-werks,
              rkwa-matnr TO xztislcit-matnr.
*-----> Get WBS Element
        SELECT SINGLE ps_psp_pnr
          INTO xztislcit-ps_psp_pnr
          FROM mseg
         WHERE mblnr   = xztislcit-mblnr
           AND mjahr   = xztislcit-mjahr
           AND zeile   = xztislcit-zeile.

        IF xztislcit-ps_psp_pnr IS INITIAL.
          IF rkwa-bstmg EQ 0.
            xztislcit-netpr = 0.
          ELSE.
            xztislcit-netpr = rkwa-wrbtr / rkwa-bstmg.
          ENDIF.
        ELSE.
          PERFORM get_parent_wbs_element(ztir0000)
                                         USING xztislcit-ps_psp_pnr
                                               ls_proj.
          MOVE: ls_proj-pspnr   TO xztislcit-ps_psp_pnr.

*        SELECT SINGLE netpr
*          INTO xztislcit-netpr
*          FROM zmmt0003
*         WHERE lifnr EQ xZTITRQK-lifnr
*           AND matnr EQ xztislcit-matnr
*           AND pspid EQ xztislcit-ps_psp_pnr
*           AND sdate LE rkwa-budat
*           AND edate GE rkwa-budat.
          xztislcit-netwr = xztislcit-netpr * rkwa-bstmg.
        ENDIF.
      ELSE.
**---> 기타자재일 경우.
*      SELECT SINGLE menge werks lgort matnr txz01
*                    loekz elikz bprme bpumz bpumn umrez
*                    umren netpr peinh uebto uebtk untto
*                    repos wepos
*      INTO CORRESPONDING FIELDS OF xZTIslcit
*        FROM ekpo
*       WHERE ebeln  EQ  xZTIslcit-ebeln
*         AND ebelp  EQ  xZTIslcit-ebelp.
      ENDIF.

*---> 품목별 정가를 계산함.
      IF xztislcit-peinh IS INITIAL.
        xztislcit-peinh = 1.
      ENDIF.
      IF xztislcit-bpumz IS INITIAL.
        xztislcit-bpumz = 1.
      ENDIF.
      IF xztislcit-bpumn IS INITIAL.
        xztislcit-bpumn = 1.
      ENDIF.

      CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
        EXPORTING
          peinh = xztislcit-peinh
          bpumz = xztislcit-bpumz
          bpumn = xztislcit-bpumn
          menge = xztislcit-rqmng
          netpr = xztislcit-netpr
        CHANGING
          netwr = xztislcit-netwr.

      MODIFY xztislcit INDEX g_tabix.
*-----> 정가 총합계산.
      ADD xztislcit-netwr TO p_netwr.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " get_items_net_price_by_request
*&---------------------------------------------------------------------*
*&      Form  build_invoice_items_by_po
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_invoice_items_by_po  TABLES xztivrq04  STRUCTURE ztivrq02
                                       xztislcit  STRUCTURE ztisrqit
                                       xztiscsdt  STRUCTURE ztiscsdt
                                       xztitig06  STRUCTURE ztitig06
                                USING  xztiscsit  STRUCTURE ztiscsit
                                       xztitcsk  STRUCTURE ztitcsk
                                       p_netwr
                                       p_ebeln.


  TYPE-POOLS : mmcr.
  DATA: t_ek08bn_temp    TYPE mmcr_xek08bn,
        ek08bn_temp      TYPE mmcr_ek08bn.

  DATA : l_buzei     LIKE ztitcsd-buzei,
         ls_proj     LIKE proj,
         l_konv      TYPE c.

  DATA : l_rate      TYPE f,
         l_wrbtr_max TYPE bapicurr_d,
         l_tabix_max TYPE sy-tabix,
         l_tabix     TYPE sy-tabix,
         l_menge     TYPE menge_d,
         l_wrbtr     TYPE bapicurr_d,
         l_dmbtr     TYPE bapicurr_d,
         l_netwr     TYPE bapicurr_d.

  DATA : g_wrbtr1    LIKE xztiscsdt-wrbtr,
         g_dmbtr1    LIKE xztiscsdt-dmbtr,
         g_wmwst1    LIKE xztiscsdt-wmwst,
         g_fwbas1    LIKE xztiscsdt-fwbas.


  DATA : l_lifnr    LIKE lfa1-lifnr.

  CLEAR: l_buzei, l_tabix.
  CLEAR: l_wrbtr_max, l_tabix_max.

  LOOP AT xztislcit WHERE   ebeln = p_ebeln
                      AND   reqno = space
                      AND   repos = 'X'.

    CLEAR: ekko, ekpo, konv, rkwa, mkpf, mseg.
    IF NOT xztislcit-ebeln IS INITIAL.
*> P/O Header Data select.
      SELECT SINGLE *
        FROM ekko
       WHERE ebeln  EQ  xztislcit-ebeln.

*> P/O Item Data select.
      SELECT SINGLE *
        FROM ekpo
       WHERE ebeln  EQ  xztislcit-ebeln
         AND ebelp  EQ  xztislcit-ebelp.
*         AND REPOS  EQ  'X'.
      IF ekpo-repos IS INITIAL.
        CONTINUE.
      ENDIF.
    ELSE.
*> Settlement select.
      SELECT SINGLE *
        FROM rkwa
       WHERE mblnr  EQ  xztislcit-mblnr
         AND mjahr  EQ  xztislcit-mjahr
         AND zeile  EQ  xztislcit-zeile.

*> Material document header select.
      SELECT SINGLE *
        FROM mkpf
       WHERE mblnr  EQ  xztislcit-mblnr
         AND mjahr  EQ  xztislcit-mjahr.

*> Material document item select.
      SELECT SINGLE *
        FROM mseg
       WHERE mblnr  EQ  xztislcit-mblnr
         AND mjahr  EQ  xztislcit-mjahr
         AND zeile  EQ  xztislcit-zeile.
    ENDIF.

*> Get 수입의뢰헤더.
    READ TABLE xztivrq04 WITH KEY reqno = xztislcit-reqno.
    IF sy-subrc EQ 0.
    ENDIF.

*> Get 비용코드 .
    CLEAR: konv, l_konv.
    READ TABLE xztitig06 WITH KEY expcd = xztiscsit-expcd.
    IF xztitig06-cscty EQ 'P' AND
      sy-subrc         EQ 0 .
      IF sy-subrc            EQ 0        AND
         NOT xztitig06-kschl IS INITIAL.
        IF NOT xztislcit-ebeln IS INITIAL.
          SELECT *
            FROM konv UP TO 1 ROWS
           WHERE knumv  EQ  ekko-knumv
             AND kposn  EQ  xztislcit-ebelp
*           AND zaehk  EQ  '01'
*             and STUNR
             AND kappl  EQ  'M'
             AND kschl  EQ  xztitig06-kschl.
          ENDSELECT.
          IF sy-subrc EQ 0.
            l_konv = 'X'.
*>
            CLEAR: l_lifnr.
            CALL FUNCTION 'ME_READ_COND_INVOICE'
              EXPORTING
                i_ebeln      = xztislcit-ebeln
                i_ebelp      = xztislcit-ebelp
                i_lifnr      = l_lifnr
              TABLES
                xek08bn_curr = t_ek08bn_temp.

            READ TABLE t_ek08bn_temp INTO ek08bn_temp
                                     WITH KEY kschl = xztitig06-kschl.
            IF sy-subrc NE 0.
*            MESSAGE E875 WITH xZTIslcit-ebeln xZTIslcit-ebelP
*                              xZTItig06-kschl
*                         RAISING distribution_error.
              CLEAR: konv.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    ADD 1 TO l_buzei.
    CLEAR: xztiscsdt.

    IF NOT ekpo-ebeln IS INITIAL.

      MOVE-CORRESPONDING ekpo TO xztiscsdt.

      SELECT SINGLE *
        FROM ekkn
       WHERE ebeln = ekpo-ebeln
       AND   ebelp = ekpo-ebelp
       AND   zekkn = '01'.
      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING ekkn TO xztiscsdt.
* 20051230 simcho 수입비용계정 PO계정으로 update되는것 방지
* ASEG 강S confirm
*        MOVE: ekkn-sakto        TO xztiscsdt-saknr.
* end simcho
      ENDIF.

*>> WBS (작업분할구조) 요소 마스터 데이타.
      IF NOT xztiscsdt-ps_psp_pnr IS INITIAL.
        SELECT SINGLE posid
          INTO xztiscsdt-pspnr
          FROM prps
         WHERE pspnr = xztiscsdt-ps_psp_pnr.
      ENDIF.
    ENDIF.

    MOVE: xztitcsk-bukrs     TO xztiscsdt-bukrs,
          xztitcsk-icsno     TO xztiscsdt-icsno,
          l_buzei            TO xztiscsdt-buzei,
          xztiscsit-icssq    TO xztiscsdt-icssq,
          xztitcsk-expgr     TO xztiscsdt-expgr,
          xztiscsit-expcd    TO xztiscsdt-expcd,
          'S'                TO xztiscsdt-koart,
          ekko-knumv         TO xztiscsdt-knumv,
          ekpo-knttp         TO xztiscsdt-knttp,
          konv-stunr         TO xztiscsdt-stunr,
          konv-zaehk         TO xztiscsdt-zaehk,
          konv-kschl         TO xztiscsdt-kschl,
          xztiscsit-mwskz    TO xztiscsdt-mwskz,
          xztislcit-reqno    TO xztiscsdt-refno,
          xztislcit-reqit    TO xztiscsdt-refit,
          xztislcit-ebeln    TO xztiscsdt-ebeln,
          xztislcit-ebelp    TO xztiscsdt-ebelp,
*          xztitig06-saknr    TO xztiscsdt-saknr,
          '40'               TO xztiscsdt-bschl,
          'S'                TO xztiscsdt-shkzg,
          xztitcsk-bupla     TO xztiscsdt-bupla,
*          xztitcsk-gsber     TO xztiscsdt-gsber,
*          xztiscsit-kostl    TO xztiscsdt-kostl,
*          xztiscsit-prctr    TO xztiscsdt-prctr,
*          xztiscsit-pspnr    TO xztiscsdt-pspnr,
*          xztivrq04-opnno    TO xztiscsdt-zuonr,
*          xztitig06-exptx    TO xztiscsdt-sgtxt,
          xztiscsit-zuonr    TO xztiscsdt-zuonr,
          xztiscsit-sgtxt    TO xztiscsdt-sgtxt,
*          xztiscsit-xref1    TO xztiscsdt-xref1,
*          xztiscsit-xref2    TO xztiscsdt-xref2,
*          xztiscsit-xref3    TO xztiscsdt-xref3,
          sy-uname           TO xztiscsdt-cnam,
          sy-datlo           TO xztiscsdt-cdat,
          sy-timlo           TO xztiscsdt-ctme,
          sy-uname           TO xztiscsdt-unam,
          sy-datlo           TO xztiscsdt-udat,
          sy-timlo           TO xztiscsdt-utme.

*> 구매오더상에 계정결정이 되지 않았을 경우,
    IF xztiscsdt-saknr IS INITIAL.
      MOVE xztitig06-saknr    TO xztiscsdt-saknr.
    ENDIF.
    IF xztiscsdt-kostl IS INITIAL.
      MOVE xztiscsit-kostl    TO xztiscsdt-kostl.
    ENDIF.
    IF xztiscsdt-prctr IS INITIAL.
      MOVE xztiscsit-prctr    TO xztiscsdt-prctr.
    ENDIF.


*> 사업영역 결정(플랜트+디비젼).
    IF xztiscsdt-gsber IS INITIAL AND
       NOT xztiscsdt-matnr IS INITIAL.
      SELECT SINGLE gsber
        INTO xztiscsdt-gsber
        FROM t134g
       WHERE werks EQ xztiscsdt-werks
         AND spart EQ ( SELECT spart
                          FROM mara
                         WHERE matnr EQ xztiscsdt-matnr ).
    ENDIF.
*
    IF NOT xztislcit-ebeln IS INITIAL.
      MOVE: ekpo-menge       TO xztiscsdt-menge,
            ekpo-meins       TO xztiscsdt-meins,
            ekpo-bprme       TO xztiscsdt-bprme,
            ekpo-peinh       TO xztiscsdt-peinh.
*> 해당문서별 배부원칙일 경우.
      IF ztitig00-dstbt EQ 'D'.
        MOVE: xztislcit-rqmng TO xztiscsdt-menge.
      ENDIF.
    ELSE.
      MOVE: xztislcit-rqmng  TO xztiscsdt-menge,
            xztislcit-meins  TO xztiscsdt-meins,
            xztislcit-meins  TO xztiscsdt-bprme,
            1                TO xztiscsdt-peinh.
    ENDIF.

    IF p_netwr IS INITIAL.
      l_rate =  1.
    ELSE.
      l_rate =  xztislcit-netwr / p_netwr.
    ENDIF.

*    xZTIscsdt-wrbtr = xZTIscsit-wrbtr * l_rate.
*    xZTIscsdt-dmbtr = xZTIscsit-dmbtr * l_rate.
*    xZTIscsdt-wmwst = xZTIscsit-wmwst * l_rate.
*    xZTIscsdt-fwbas = xZTIscsit-fwbas * l_rate.
*
    xztiscsdt-wrbtr =
       ( TRUNC( ( xztiscsit-wrbtr * l_rate ) * 100 ) ) / 100.

    xztiscsdt-dmbtr =
       ( TRUNC( ( xztiscsit-dmbtr * l_rate ) * 100 ) ) / 100.

    xztiscsdt-wmwst =
       ( TRUNC( ( xztiscsit-wmwst * l_rate ) * 100 ) ) / 100.

    xztiscsdt-fwbas =
       ( TRUNC( ( xztiscsit-fwbas * l_rate ) * 100 ) ) / 100.

*>구매오더 이력 수량을 계산하여 송장처리 수량 조정.
    PERFORM calc_po_history_qty TABLES xztiscsdt
                                USING  xztiscsdt-ebeln
                                       xztiscsdt-ebelp
                                       ekpo
                                       xztitcsk
                                       xztiscsdt-menge
                                       xztiscsit-cscty.


*> 가장 큰 항목을 찾기 위해.
    DESCRIBE TABLE xztiscsdt LINES l_tabix.
    READ TABLE xztiscsdt INDEX l_tabix.

    IF l_wrbtr_max LT xztiscsdt-wrbtr.
      l_wrbtr_max = xztiscsdt-wrbtr.
      l_tabix_max = l_tabix.
    ENDIF.

    ADD: xztiscsdt-wrbtr TO g_wrbtr1,
         xztiscsdt-dmbtr TO g_dmbtr1,
         xztiscsdt-wmwst TO g_wmwst1,
         xztiscsdt-fwbas TO g_fwbas1.
  ENDLOOP.

  IF l_tabix_max IS INITIAL.
    DESCRIBE TABLE xztiscsdt LINES g_line.
    READ TABLE xztiscsdt INDEX g_line.
  ELSE.
    READ TABLE xztiscsdt INDEX l_tabix_max.
  ENDIF.
  g_tabix = sy-tabix.
*> ITEM 보정 작업.
  IF sy-subrc EQ 0.
*> 문서상 금액.
    IF xztiscsit-wrbtr GT g_wrbtr1.
      xztiscsdt-wrbtr = xztiscsdt-wrbtr +
                       ( xztiscsit-wrbtr - g_wrbtr1 ).
    ELSEIF xztiscsit-wrbtr LT g_wrbtr1.
      xztiscsdt-wrbtr = xztiscsdt-wrbtr -
                       ( g_wrbtr1 - xztiscsit-wrbtr ).
    ENDIF.

*> 현지통화.
    IF xztiscsit-dmbtr GT g_dmbtr1.
      xztiscsdt-dmbtr = xztiscsdt-dmbtr +
                       ( xztiscsit-dmbtr - g_dmbtr1 ).
    ELSEIF xztiscsit-dmbtr LT g_dmbtr1.
      xztiscsdt-dmbtr = xztiscsdt-dmbtr -
                       ( g_dmbtr1 - xztiscsit-dmbtr ).
    ENDIF.

*> 세액.
    IF xztiscsit-wmwst GT g_wmwst1.
      xztiscsdt-wmwst = xztiscsdt-wmwst +
                       ( xztiscsit-wmwst - g_wmwst1 ).
    ELSEIF xztiscsit-wmwst LT g_wmwst1.
      xztiscsdt-wmwst = xztiscsdt-wmwst -
                       ( g_wmwst1 - xztiscsit-wmwst ).
    ENDIF.

*> 표준액.
    IF xztiscsit-fwbas GT g_fwbas1.
      xztiscsdt-fwbas = xztiscsdt-fwbas +
                       ( xztiscsit-fwbas - g_fwbas1 ).
    ELSEIF xztiscsit-fwbas LT g_fwbas1.
      xztiscsdt-fwbas = xztiscsdt-fwbas -
                       ( g_fwbas1 - xztiscsit-fwbas ).
    ENDIF.

    MODIFY xztiscsdt INDEX g_tabix.
  ENDIF.

ENDFORM.                    " build_invoice_items_by_po

*&---------------------------------------------------------------------*
*&      Form  build_invoice_items_amount
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_invoice_items_by_lc  TABLES xztivrq04  STRUCTURE ztivrq02
                                       xztislcit  STRUCTURE ztisrqit
                                       xztiscsdt  STRUCTURE ztiscsdt
                                       xztitig06  STRUCTURE ztitig06
                                USING  xztiscsit  STRUCTURE ztiscsit
                                       xztitcsk  STRUCTURE ztitcsk
                                       p_netwr
                                       p_reqno
                                       p_amdsq.


  TYPE-POOLS : mmcr.
  DATA: t_ek08bn_temp    TYPE mmcr_xek08bn,
        ek08bn_temp      TYPE mmcr_ek08bn.

  DATA : l_buzei     LIKE ztitcsd-buzei,
         ls_proj     LIKE proj,
         l_konv      TYPE c.

  DATA : l_rate      TYPE f,
         l_wrbtr_max TYPE bapicurr_d,
         l_tabix_max TYPE sy-tabix,
         l_tabix     TYPE sy-tabix,
         l_menge     TYPE menge_d,
         l_wrbtr     TYPE bapicurr_d,
         l_dmbtr     TYPE bapicurr_d,
         l_netwr     TYPE bapicurr_d.

  DATA : g_wrbtr1    LIKE xztiscsdt-wrbtr,
         g_dmbtr1    LIKE xztiscsdt-dmbtr,
         g_wmwst1    LIKE xztiscsdt-wmwst,
         g_fwbas1    LIKE xztiscsdt-fwbas.


  DATA : l_lifnr    LIKE lfa1-lifnr.

  CLEAR: l_buzei, l_tabix.
  CLEAR: l_wrbtr_max, l_tabix_max.

  LOOP AT xztislcit WHERE   reqno = p_reqno
                      AND   amdsq = p_amdsq
                      AND   repos = 'X'.

    CLEAR: ekko, ekpo, konv, rkwa, mkpf, mseg.
    IF NOT xztislcit-ebeln IS INITIAL.
*> P/O Header Data select.
      SELECT SINGLE *
        FROM ekko
       WHERE ebeln  EQ  xztislcit-ebeln.

*> P/O Item Data select.
      SELECT SINGLE *
        FROM ekpo
       WHERE ebeln  EQ  xztislcit-ebeln
         AND ebelp  EQ  xztislcit-ebelp.
*         AND REPOS  EQ  'X'.
      IF ekpo-repos IS INITIAL.
        CONTINUE.
      ENDIF.
    ELSE.
*> Settlement select.
      SELECT SINGLE *
        FROM rkwa
       WHERE mblnr  EQ  xztislcit-mblnr
         AND mjahr  EQ  xztislcit-mjahr
         AND zeile  EQ  xztislcit-zeile.

*> Material document header select.
      SELECT SINGLE *
        FROM mkpf
       WHERE mblnr  EQ  xztislcit-mblnr
         AND mjahr  EQ  xztislcit-mjahr.

*> Material document item select.
      SELECT SINGLE *
        FROM mseg
       WHERE mblnr  EQ  xztislcit-mblnr
         AND mjahr  EQ  xztislcit-mjahr
         AND zeile  EQ  xztislcit-zeile.
    ENDIF.
*> Get 수입의뢰헤더.
    READ TABLE xztivrq04 WITH KEY reqno = xztislcit-reqno.
    IF sy-subrc EQ 0.
    ENDIF.

*> Get 비용코드 .
    CLEAR: konv, l_konv.
    READ TABLE xztitig06 WITH KEY expcd = xztiscsit-expcd.
    IF xztitig06-cscty EQ 'P' AND
      sy-subrc         EQ 0 .
      IF sy-subrc            EQ 0        AND
         NOT xztitig06-kschl IS INITIAL.
        IF NOT xztislcit-ebeln IS INITIAL.
          SELECT *
            FROM konv UP TO 1 ROWS
           WHERE knumv  EQ  ekko-knumv
             AND kposn  EQ  xztislcit-ebelp
*           AND zaehk  EQ  '01'
*             and STUNR
             AND kappl  EQ  'M'
             AND kschl  EQ  xztitig06-kschl.
          ENDSELECT.
          IF sy-subrc EQ 0.
            l_konv = 'X'.
*>
            CLEAR: l_lifnr.
            CALL FUNCTION 'ME_READ_COND_INVOICE'
              EXPORTING
                i_ebeln      = xztislcit-ebeln
                i_ebelp      = xztislcit-ebelp
                i_lifnr      = l_lifnr
              TABLES
                xek08bn_curr = t_ek08bn_temp.

            READ TABLE t_ek08bn_temp INTO ek08bn_temp
                                     WITH KEY kschl = xztitig06-kschl.
            IF sy-subrc NE 0.
*            MESSAGE E875 WITH xZTIslcit-ebeln xZTIslcit-ebelP
*                              xZTItig06-kschl
*                         RAISING distribution_error.
              CLEAR: konv.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    ADD 1 TO l_buzei.
    CLEAR: xztiscsdt.

    IF NOT ekpo-ebeln IS INITIAL.

      MOVE-CORRESPONDING ekpo TO xztiscsdt.

      SELECT SINGLE *
        FROM ekkn
       WHERE ebeln = ekpo-ebeln
       AND   ebelp = ekpo-ebelp
       AND   zekkn = '01'.
      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING ekkn TO xztiscsdt.
* 20051230 simcho 수입비용계정 PO계정으로 update되는것 방지
* ASEG 강S confirm
*        MOVE: ekkn-sakto        TO xztiscsdt-saknr.
* end simcho
      ENDIF.

*>> WBS (작업분할구조) 요소 마스터 데이타.
      IF NOT xztiscsdt-ps_psp_pnr IS INITIAL.
        SELECT SINGLE posid
          INTO xztiscsdt-pspnr
          FROM prps
         WHERE pspnr = xztiscsdt-ps_psp_pnr.
      ENDIF.
    ENDIF.

    MOVE: xztitcsk-bukrs     TO xztiscsdt-bukrs,
          xztitcsk-icsno     TO xztiscsdt-icsno,
          l_buzei            TO xztiscsdt-buzei,
          xztiscsit-icssq    TO xztiscsdt-icssq,
          xztitcsk-expgr     TO xztiscsdt-expgr,
          xztiscsit-expcd    TO xztiscsdt-expcd,
          'S'                TO xztiscsdt-koart,
          ekko-knumv         TO xztiscsdt-knumv,
          ekpo-knttp         TO xztiscsdt-knttp,
          konv-stunr         TO xztiscsdt-stunr,
          konv-zaehk         TO xztiscsdt-zaehk,
          konv-kschl         TO xztiscsdt-kschl,
          xztiscsit-mwskz    TO xztiscsdt-mwskz,
          xztislcit-reqno    TO xztiscsdt-refno,
          xztislcit-reqit    TO xztiscsdt-refit,
          xztislcit-ebeln    TO xztiscsdt-ebeln,
          xztislcit-ebelp    TO xztiscsdt-ebelp,
*          xztitig06-saknr    TO xztiscsdt-saknr,
          '40'               TO xztiscsdt-bschl,
          'S'                TO xztiscsdt-shkzg,
          xztitcsk-bupla     TO xztiscsdt-bupla,
*          xztitcsk-gsber     TO xztiscsdt-gsber,
*          xztiscsit-kostl    TO xztiscsdt-kostl,
*          xztiscsit-prctr    TO xztiscsdt-prctr,
*          xztiscsit-pspnr    TO xztiscsdt-pspnr,
          xztivrq04-opnno    TO xztiscsdt-zuonr,
          xztitig06-exptx    TO xztiscsdt-sgtxt,
          sy-uname           TO xztiscsdt-cnam,
          sy-datlo           TO xztiscsdt-cdat,
          sy-timlo           TO xztiscsdt-ctme,
          sy-uname           TO xztiscsdt-unam,
          sy-datlo           TO xztiscsdt-udat,
          sy-timlo           TO xztiscsdt-utme.

*> 구매오더상에 계정결정이 되지 않았을 경우,
    IF xztiscsdt-saknr IS INITIAL.
      MOVE xztitig06-saknr    TO xztiscsdt-saknr.
    ENDIF.
    IF xztiscsdt-kostl IS INITIAL.
      MOVE xztiscsit-kostl    TO xztiscsdt-kostl.
    ENDIF.
    IF xztiscsdt-prctr IS INITIAL.
      MOVE xztiscsit-prctr    TO xztiscsdt-prctr.
    ENDIF.


*> 사업영역 결정(플랜트+디비젼).
    IF xztiscsdt-gsber IS INITIAL AND
       NOT xztiscsdt-matnr IS INITIAL.
      SELECT SINGLE gsber
        INTO xztiscsdt-gsber
        FROM t134g
       WHERE werks EQ xztiscsdt-werks
         AND spart EQ ( SELECT spart
                          FROM mara
                         WHERE matnr EQ xztiscsdt-matnr ).
    ENDIF.
*
*
    IF NOT xztislcit-ebeln IS INITIAL.
      MOVE: ekpo-menge       TO xztiscsdt-menge,
            ekpo-meins       TO xztiscsdt-meins,
            ekpo-bprme       TO xztiscsdt-bprme,
            ekpo-peinh       TO xztiscsdt-peinh.
*> 해당문서별 배부원칙일 경우.
      IF ztitig00-dstbt EQ 'D'.
        MOVE: xztislcit-rqmng TO xztiscsdt-menge.
      ENDIF.
    ELSE.
      MOVE: xztislcit-rqmng  TO xztiscsdt-menge,
            xztislcit-meins  TO xztiscsdt-meins,
            xztislcit-meins  TO xztiscsdt-bprme,
            1                TO xztiscsdt-peinh.
    ENDIF.

    IF p_netwr IS INITIAL.
      l_rate =  1.
    ELSE.
      l_rate =  xztislcit-netwr / p_netwr.
    ENDIF.

*    xZTIscsdt-wrbtr = xZTIscsit-wrbtr * l_rate.
*    xZTIscsdt-dmbtr = xZTIscsit-dmbtr * l_rate.
*    xZTIscsdt-wmwst = xZTIscsit-wmwst * l_rate.
*    xZTIscsdt-fwbas = xZTIscsit-fwbas * l_rate.
*
    xztiscsdt-wrbtr =
       ( TRUNC( ( xztiscsit-wrbtr * l_rate ) * 100 ) ) / 100.

    xztiscsdt-dmbtr =
       ( TRUNC( ( xztiscsit-dmbtr * l_rate ) * 100 ) ) / 100.

    xztiscsdt-wmwst =
       ( TRUNC( ( xztiscsit-wmwst * l_rate ) * 100 ) ) / 100.

    xztiscsdt-fwbas =
       ( TRUNC( ( xztiscsit-fwbas * l_rate ) * 100 ) ) / 100.

*>구매오더 이력 수량을 계산하여 송장처리 수량 조정.
    PERFORM calc_po_history_qty TABLES xztiscsdt
                                USING  xztiscsdt-ebeln
                                       xztiscsdt-ebelp
                                       ekpo
                                       xztitcsk
                                       xztiscsdt-menge
                                       xztiscsit-cscty.


*> 가장 큰 항목을 찾기 위해.
    DESCRIBE TABLE xztiscsdt LINES l_tabix.
    READ TABLE xztiscsdt INDEX l_tabix.

    IF l_wrbtr_max LT xztiscsdt-wrbtr.
      l_wrbtr_max = xztiscsdt-wrbtr.
      l_tabix_max = l_tabix.
    ENDIF.

    ADD: xztiscsdt-wrbtr TO g_wrbtr1,
         xztiscsdt-dmbtr TO g_dmbtr1,
         xztiscsdt-wmwst TO g_wmwst1,
         xztiscsdt-fwbas TO g_fwbas1.
  ENDLOOP.

  IF l_tabix_max IS INITIAL.
    DESCRIBE TABLE xztiscsdt LINES g_line.
    READ TABLE xztiscsdt INDEX g_line.
  ELSE.
    READ TABLE xztiscsdt INDEX l_tabix_max.
  ENDIF.
  g_tabix = sy-tabix.
*> ITEM 보정 작업.
  IF sy-subrc EQ 0.
*> 문서상 금액.
    IF xztiscsit-wrbtr GT g_wrbtr1.
      xztiscsdt-wrbtr = xztiscsdt-wrbtr +
                       ( xztiscsit-wrbtr - g_wrbtr1 ).
    ELSEIF xztiscsit-wrbtr LT g_wrbtr1.
      xztiscsdt-wrbtr = xztiscsdt-wrbtr -
                       ( g_wrbtr1 - xztiscsit-wrbtr ).
    ENDIF.

*> 현지통화.
    IF xztiscsit-dmbtr GT g_dmbtr1.
      xztiscsdt-dmbtr = xztiscsdt-dmbtr +
                       ( xztiscsit-dmbtr - g_dmbtr1 ).
    ELSEIF xztiscsit-dmbtr LT g_dmbtr1.
      xztiscsdt-dmbtr = xztiscsdt-dmbtr -
                       ( g_dmbtr1 - xztiscsit-dmbtr ).
    ENDIF.

*> 세액.
    IF xztiscsit-wmwst GT g_wmwst1.
      xztiscsdt-wmwst = xztiscsdt-wmwst +
                       ( xztiscsit-wmwst - g_wmwst1 ).
    ELSEIF xztiscsit-wmwst LT g_wmwst1.
      xztiscsdt-wmwst = xztiscsdt-wmwst -
                       ( g_wmwst1 - xztiscsit-wmwst ).
    ENDIF.

*> 표준액.
    IF xztiscsit-fwbas GT g_fwbas1.
      xztiscsdt-fwbas = xztiscsdt-fwbas +
                       ( xztiscsit-fwbas - g_fwbas1 ).
    ELSEIF xztiscsit-fwbas LT g_fwbas1.
      xztiscsdt-fwbas = xztiscsdt-fwbas -
                       ( g_fwbas1 - xztiscsit-fwbas ).
    ENDIF.

    MODIFY xztiscsdt INDEX g_tabix.
  ENDIF.

ENDFORM.                    " build_invoice_items_amount
*&---------------------------------------------------------------------*
*&      Form  build_vat_posting_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_vat_posting_data  TABLES   xztiscsdt STRUCTURE ztiscsdt
                                      xztitig06 STRUCTURE ztitig06
                                      xztiscsit STRUCTURE ztiscsit
                             USING    xztitcsk STRUCTURE ztitcsk
                                      xexpgr.

  xztitcsk-ptdcl = 'V'.
  xztitcsk-dstrb = 'N'.

  READ TABLE xztiscsit INDEX 1.

*> AP 금액.
  CLEAR: xztiscsdt.
  MOVE: 1               TO xztiscsdt-buzei,
        '31'            TO xztiscsdt-bschl,
        xexpgr          TO xztiscsdt-expgr,
        'K'             TO xztiscsdt-koart,
        xztiscsit-mwskz TO xztiscsdt-mwskz,
        'H'             TO xztiscsdt-shkzg,
        xztitcsk-akont TO xztiscsdt-saknr,
        xztitcsk-wrbtr TO xztiscsdt-wrbtr,
*        xZTITCSK-wmwst TO xZTIscsdt-wmwst,
        xztitcsk-dmbtr TO xztiscsdt-dmbtr,
*        xZTITCSK-fwbas TO xZTIscsdt-fwbas,
        xztiscsit-kostl TO xztiscsdt-kostl,
        xztiscsit-prctr TO xztiscsdt-prctr,
        xztiscsit-pspnr TO xztiscsdt-pspnr,
        xztitcsk-bupla TO xztiscsdt-bupla,
        xztitcsk-gsber TO xztiscsdt-gsber,
        xztitcsk-sgtxt TO xztiscsdt-sgtxt,
        xztiscsit-zuonr TO xztiscsdt-zuonr,
        '5'             TO xztiscsdt-itmst,
        sy-uname        TO xztiscsdt-cnam,
        sy-datlo        TO xztiscsdt-cdat,
        sy-timlo        TO xztiscsdt-ctme,
        sy-uname        TO xztiscsdt-unam,
        sy-datlo        TO xztiscsdt-udat,
        sy-timlo        TO xztiscsdt-utme.
*
  APPEND xztiscsdt.

*> 부가세 금액.
  CLEAR: xztiscsdt.
  READ TABLE xztitig06 WITH KEY expgr = 'V'.
  IF sy-subrc NE 0.
    MESSAGE e868 RAISING distribution_error.
  ELSE.
    xztiscsdt-saknr = xztitig06-saknr.
  ENDIF.
*  SELECT saknr
*    INTO xZTIscsdt-saknr
*    FROM ZTItig06
*   WHERE bukrs  EQ  xZTITCSK-bukrs
*     AND cscty  EQ  'V'.
*  ENDSELECT.
*
  MOVE: 2               TO xztiscsdt-buzei,
        '40'            TO xztiscsdt-bschl,
        xexpgr          TO xztiscsdt-expgr,
        'S'             TO xztiscsdt-koart,
        xztiscsit-mwskz TO xztiscsdt-mwskz,
        'S'             TO xztiscsdt-shkzg,
        xztitcsk-wrbtr TO xztiscsdt-wrbtr,
        xztitcsk-wmwst TO xztiscsdt-wmwst,
*        0               TO xZTIscsdt-wmwst,
        xztitcsk-dmbtr TO xztiscsdt-dmbtr,
*        0               TO xZTIscsdt-fwbas,
        xztiscsit-kostl TO xztiscsdt-kostl,
        xztiscsit-prctr TO xztiscsdt-prctr,
        xztiscsit-pspnr TO xztiscsdt-pspnr,
        xztitcsk-fwbas TO xztiscsdt-fwbas,
        xztitcsk-bupla TO xztiscsdt-bupla,
        xztitcsk-gsber TO xztiscsdt-gsber,
        xztiscsit-sgtxt TO xztiscsdt-sgtxt,
        '5'             TO xztiscsdt-itmst,
        xztiscsit-zuonr TO xztiscsdt-zuonr,
        sy-uname        TO xztiscsdt-cnam,
        sy-datlo        TO xztiscsdt-cdat,
        sy-timlo        TO xztiscsdt-ctme,
        sy-uname        TO xztiscsdt-unam,
        sy-datlo        TO xztiscsdt-udat,
        sy-timlo        TO xztiscsdt-utme.
  APPEND xztiscsdt.

ENDFORM.                    " build_vat_posting_data
*&---------------------------------------------------------------------*
*&      Form  build_ap_posting_data
*&---------------------------------------------------------------------*
*       무환건만 존재할 경우 회계기표함.(FB01) -> BAPIs
*----------------------------------------------------------------------*
FORM build_ap_posting_data   TABLES   xztiscsdt STRUCTURE ztiscsdt
                                      xztitig06 STRUCTURE ztitig06
                                      xztiscsit STRUCTURE ztiscsit
                                      xztislcit STRUCTURE ztisrqit
                                      xztisblit STRUCTURE ztisblit
                                      xztisccit STRUCTURE ztisccit
                                      xztistxit STRUCTURE ztistxit
                             USING    xztitcsk STRUCTURE ztitcsk
                                      xexpgr
                                      xwrbtr    TYPE bapicurr_d.

  DATA: l_buzei  LIKE xztiscsdt-buzei.

  REFRESH: xztiscsdt.

  READ TABLE xztiscsit INDEX 1.

  IF xztitcsk-wmwst EQ xztitcsk-wrbtr.
    xztitcsk-ptdcl = 'V'.
  ELSE.
    xztitcsk-ptdcl = 'F'.
  ENDIF.
*  xztitcsk-ptdcl = 'M'.
  xztitcsk-dstrb = 'N'.

*> AP 금액.
  CLEAR: xztiscsdt, l_buzei.
  ADD 1 TO l_buzei.
  MOVE: l_buzei         TO xztiscsdt-buzei,
        '31'            TO xztiscsdt-bschl,
        xexpgr          TO xztiscsdt-expgr,
        'K'             TO xztiscsdt-koart,
        xztitcsk-mwskz  TO xztiscsdt-mwskz,
        'H'             TO xztiscsdt-shkzg,
        xztitcsk-akont  TO xztiscsdt-saknr,
        xztitcsk-wrbtr  TO xztiscsdt-wrbtr,
*        xZTITCSK-wmwst TO xZTIscsdt-wmwst,
*        xZTITCSK-dmbtr TO xZTIscsdt-dmbtr,
*        xZTITCSK-fwbas TO xZTIscsdt-fwbas,
        xztiscsit-kostl TO xztiscsdt-kostl,
        xztiscsit-prctr TO xztiscsdt-prctr,
        xztiscsit-pspnr TO xztiscsdt-pspnr,
        xztitcsk-bupla  TO xztiscsdt-bupla,
        xztitcsk-gsber  TO xztiscsdt-gsber,
        xztiscsit-sgtxt TO xztiscsdt-sgtxt,
        xztiscsit-zuonr TO xztiscsdt-zuonr,
        'P'             TO xztiscsdt-itmst,
        sy-uname        TO xztiscsdt-cnam,
        sy-datlo        TO xztiscsdt-cdat,
        sy-timlo        TO xztiscsdt-ctme,
        sy-uname        TO xztiscsdt-unam,
        sy-datlo        TO xztiscsdt-udat,
        sy-timlo        TO xztiscsdt-utme.

  APPEND xztiscsdt.

*> 부대비 금액.
  IF xztitcsk-wmwst NE xztitcsk-wrbtr.
    CLEAR: xztiscsdt.
    READ TABLE xztitig06 WITH KEY expgr = 'N'.
    IF sy-subrc NE 0.
      MESSAGE e871 RAISING distribution_error.
    ELSE.
      IF xztitig06-saknr IS INITIAL.
        MESSAGE e871 RAISING distribution_error.
      ENDIF.
      xztiscsdt-saknr = xztitig06-saknr.
    ENDIF.

    MOVE: '40'            TO xztiscsdt-bschl,
          xexpgr          TO xztiscsdt-expgr,
          'S'             TO xztiscsdt-koart,
          xztiscsit-mwskz TO xztiscsdt-mwskz,
          'S'             TO xztiscsdt-shkzg,
*          xZTITCSK-akont TO xZTIscsdt-saknr,
          xwrbtr          TO xztiscsdt-wrbtr,
*          xZTITCSK-wmwst TO xZTIscsdt-wmwst,
          xwrbtr          TO xztiscsdt-dmbtr,
*          xZTITCSK-fwbas TO xZTIscsdt-fwbas,
          xztiscsit-kostl TO xztiscsdt-kostl,
          xztiscsit-prctr TO xztiscsdt-prctr,
          xztiscsit-pspnr TO xztiscsdt-pspnr,
          xztitcsk-bupla  TO xztiscsdt-bupla,
          xztitcsk-gsber  TO xztiscsdt-gsber,
          xztiscsit-sgtxt TO xztiscsdt-sgtxt,
          xztiscsit-zuonr TO xztiscsdt-zuonr,
          '5'             TO xztiscsdt-itmst,
          sy-uname        TO xztiscsdt-cnam,
          sy-datlo        TO xztiscsdt-cdat,
          sy-timlo        TO xztiscsdt-ctme,
          sy-uname        TO xztiscsdt-unam,
          sy-datlo        TO xztiscsdt-udat,
          sy-timlo        TO xztiscsdt-utme.

    CASE xexpgr.
      WHEN 'L' OR 'I'.
        MOVE: 2 TO xztiscsdt-buzei.

        SELECT *
          FROM ekkn UP TO 1 ROWS
           FOR ALL ENTRIES IN xztislcit
         WHERE ebeln EQ xztislcit-ebeln
           AND ebelp EQ xztislcit-ebelp.
        ENDSELECT.

      WHEN 'T'.
        MOVE: 2 TO xztiscsdt-buzei.

        SELECT *
          FROM ekkn UP TO 1 ROWS
           FOR ALL ENTRIES IN xztistxit
         WHERE ebeln EQ xztistxit-ebeln
           AND ebelp EQ xztistxit-ebelp.
        ENDSELECT.
*__START 기능개선 44040 수입무환PO 수입제비용 처리시 전표 생성 로직 수정
      WHEN 'B'.
        LOOP AT xztiscsit.
          ADD 1 TO l_buzei.
          MOVE: l_buzei TO xztiscsdt-buzei.

          xztiscsdt-wrbtr = xztiscsit-wrbtr.
          xztiscsdt-dmbtr = xztiscsit-wrbtr.

          xztiscsdt-mwskz = xztiscsit-mwskz.
          xztiscsdt-kostl = xztiscsit-kostl.
          xztiscsdt-prctr = xztiscsit-prctr.
          xztiscsdt-pspnr = xztiscsit-pspnr.
          xztiscsdt-sgtxt = xztiscsit-sgtxt.
          xztiscsdt-zuonr = xztiscsit-zuonr.

          READ TABLE xztisblit WITH KEY iblno = xztiscsit-refno.

          IF sy-subrc EQ 0.
            SELECT SINGLE *
              FROM ekkn
             WHERE ebeln EQ xztisblit-ebeln
               AND ebelp EQ xztisblit-ebelp.

            IF sy-subrc EQ 0.
              MOVE: ekkn-sakto      TO xztiscsdt-saknr,
                    ekkn-kostl      TO xztiscsdt-kostl,
                    ekkn-prctr      TO xztiscsdt-prctr,
                    ekkn-gsber      TO xztiscsdt-gsber,
                    ekkn-ebeln      TO xztiscsdt-ebeln,
                    ekkn-ebelp      TO xztiscsdt-ebelp.
            ELSE.
              MOVE: xztisblit-ebeln TO xztiscsdt-ebeln,
                    xztisblit-ebelp TO xztiscsdt-ebelp.

            ENDIF.
          ENDIF.

          APPEND xztiscsdt.
        ENDLOOP.

      WHEN 'C'.
        LOOP AT xztiscsit.
          ADD 1 TO l_buzei.
          MOVE: l_buzei TO xztiscsdt-buzei.

          xztiscsdt-wrbtr = xztiscsit-wrbtr.
          xztiscsdt-dmbtr = xztiscsit-wrbtr.

          xztiscsdt-mwskz = xztiscsit-mwskz.
          xztiscsdt-kostl = xztiscsit-kostl.
          xztiscsdt-prctr = xztiscsit-prctr.
          xztiscsdt-pspnr = xztiscsit-pspnr.
          xztiscsdt-sgtxt = xztiscsit-sgtxt.
          xztiscsdt-zuonr = xztiscsit-zuonr.

          READ TABLE xztisccit WITH KEY iccno = xztiscsit-refno.

          IF sy-subrc EQ 0.
            SELECT SINGLE *
              FROM ekkn
             WHERE ebeln EQ xztisccit-ebeln
               AND ebelp EQ xztisccit-ebelp.

            IF sy-subrc EQ 0.
              MOVE: ekkn-sakto      TO xztiscsdt-saknr,
                    ekkn-kostl      TO xztiscsdt-kostl,
                    ekkn-prctr      TO xztiscsdt-prctr,
                    ekkn-gsber      TO xztiscsdt-gsber,
                    ekkn-ebeln      TO xztiscsdt-ebeln,
                    ekkn-ebelp      TO xztiscsdt-ebelp.
            ELSE.
              MOVE: xztisccit-ebeln TO xztiscsdt-ebeln,
                    xztisccit-ebelp TO xztiscsdt-ebelp.

            ENDIF.
          ENDIF.

          APPEND xztiscsdt.
        ENDLOOP.
    ENDCASE.
*__END 기능개선 44040 수입무환PO 수입제비용 처리시 전표 생성 로직 수정
    IF xexpgr EQ 'L' OR xexpgr EQ 'I' OR xexpgr EQ 'T'.
      IF sy-subrc EQ 0.
        MOVE: ekkn-sakto      TO xztiscsdt-saknr,
              ekkn-kostl      TO xztiscsdt-kostl,
              ekkn-prctr      TO xztiscsdt-prctr,
              ekkn-gsber      TO xztiscsdt-gsber,
              ekkn-ebeln      TO xztiscsdt-ebeln,
              ekkn-ebelp      TO xztiscsdt-ebelp.
      ENDIF.

      APPEND xztiscsdt.
    ENDIF.
  ENDIF.

*  IF xztitcsk-wmwst NE xztitcsk-wrbtr.
*    CLEAR: xztiscsdt.
*    READ TABLE xztitig06 WITH KEY expgr = 'N'.
*    IF sy-subrc NE 0.
*      MESSAGE e871 RAISING distribution_error.
*    ELSE.
*      IF xztitig06-saknr IS INITIAL.
*        MESSAGE e871 RAISING distribution_error.
*      ENDIF.
*      xztiscsdt-saknr = xztitig06-saknr.
*    ENDIF.
*    ADD 1 TO l_buzei.
*    MOVE: 2               TO xztiscsdt-buzei,
*          '40'            TO xztiscsdt-bschl,
*          xexpgr          TO xztiscsdt-expgr,
*          'S'             TO xztiscsdt-koart,
*          xztiscsit-mwskz TO xztiscsdt-mwskz,
*          'S'             TO xztiscsdt-shkzg,
**          xZTITCSK-akont TO xZTIscsdt-saknr,
*          xwrbtr          TO xztiscsdt-wrbtr,
**          xZTITCSK-wmwst TO xZTIscsdt-wmwst,
*          xwrbtr          TO xztiscsdt-dmbtr,
**          xZTITCSK-fwbas TO xZTIscsdt-fwbas,
*          xztiscsit-kostl TO xztiscsdt-kostl,
*          xztiscsit-prctr TO xztiscsdt-prctr,
*          xztiscsit-pspnr TO xztiscsdt-pspnr,
*          xztitcsk-bupla  TO xztiscsdt-bupla,
*          xztitcsk-gsber  TO xztiscsdt-gsber,
*          xztiscsit-sgtxt TO xztiscsdt-sgtxt,
*          xztiscsit-zuonr TO xztiscsdt-zuonr,
*          '5'             TO xztiscsdt-itmst,
*          sy-uname        TO xztiscsdt-cnam,
*          sy-datlo        TO xztiscsdt-cdat,
*          sy-timlo        TO xztiscsdt-ctme,
*          sy-uname        TO xztiscsdt-unam,
*          sy-datlo        TO xztiscsdt-udat,
*          sy-timlo        TO xztiscsdt-utme.
*
*    CASE xexpgr.
*      WHEN 'L' OR 'I'.
*        SELECT *
*          FROM ekkn UP TO 1 ROWS
*           FOR ALL ENTRIES IN xztislcit
*         WHERE ebeln EQ xztislcit-ebeln
*           AND ebelp EQ xztislcit-ebelp.
*        ENDSELECT.
*      WHEN 'B'.
*        SELECT *
*          FROM ekkn UP TO 1 ROWS
*           FOR ALL ENTRIES IN xztisblit
*         WHERE ebeln EQ xztisblit-ebeln
*           AND ebelp EQ xztisblit-ebelp.
*        ENDSELECT.
*      WHEN 'C'.
*        SELECT *
*          FROM ekkn UP TO 1 ROWS
*           FOR ALL ENTRIES IN xztisccit
*         WHERE ebeln EQ xztisccit-ebeln
*           AND ebelp EQ xztisccit-ebelp.
*        ENDSELECT.
*      WHEN 'T'.
*        SELECT *
*          FROM ekkn UP TO 1 ROWS
*           FOR ALL ENTRIES IN xztistxit
*         WHERE ebeln EQ xztistxit-ebeln
*           AND ebelp EQ xztistxit-ebelp.
*        ENDSELECT.
*    ENDCASE.
*
*    IF sy-subrc EQ 0.
*      MOVE: ekkn-sakto      TO xztiscsdt-saknr,
*            ekkn-kostl      TO xztiscsdt-kostl,
*            ekkn-prctr      TO xztiscsdt-prctr,
*            ekkn-gsber      TO xztiscsdt-gsber,
*            ekkn-ebeln      TO xztiscsdt-ebeln,
*            ekkn-ebelp      TO xztiscsdt-ebelp.
*    ENDIF.
*
*    APPEND xztiscsdt.
*  ENDIF.

  CHECK NOT xztitcsk-wmwst IS INITIAL.
*> 부가세 금액.
  CLEAR: xztiscsdt.
  READ TABLE xztitig06 WITH KEY expgr = 'V'.
  IF sy-subrc NE 0.
    MESSAGE e868 RAISING distribution_error.
  ELSE.
    IF xztitig06-saknr IS INITIAL.
      MESSAGE e868 RAISING distribution_error.
    ENDIF.
    xztiscsdt-saknr = xztitig06-saknr.
  ENDIF.

  ADD 1 TO l_buzei.
  MOVE: l_buzei         TO xztiscsdt-buzei,
        '40'            TO xztiscsdt-bschl,
        xexpgr          TO xztiscsdt-expgr,
        'S'             TO xztiscsdt-koart,
        xztitcsk-mwskz  TO xztiscsdt-mwskz,
        'S'             TO xztiscsdt-shkzg,
        xztitcsk-wmwst  TO xztiscsdt-wrbtr,
        xztitcsk-wmwst  TO xztiscsdt-wmwst,
*        0               TO xZTIscsdt-wmwst,
        xztitcsk-wmwst  TO xztiscsdt-dmbtr,
*        0               TO xZTIscsdt-fwbas,
        xztitcsk-fwbas  TO xztiscsdt-fwbas,
        xztiscsit-kostl TO xztiscsdt-kostl,
        xztiscsit-prctr TO xztiscsdt-prctr,
        xztiscsit-pspnr TO xztiscsdt-pspnr,
        xztitcsk-bupla  TO xztiscsdt-bupla,
        xztitcsk-gsber  TO xztiscsdt-gsber,
        xztiscsit-sgtxt TO xztiscsdt-sgtxt,
        xztiscsit-zuonr TO xztiscsdt-zuonr,
        'V'             TO xztiscsdt-itmst,
        sy-uname        TO xztiscsdt-cnam,
        sy-datlo        TO xztiscsdt-cdat,
        sy-timlo        TO xztiscsdt-ctme,
        sy-uname        TO xztiscsdt-unam,
        sy-datlo        TO xztiscsdt-udat,
        sy-timlo        TO xztiscsdt-utme.

  APPEND xztiscsdt.

ENDFORM.                    " build_ap_posting_data
*&---------------------------------------------------------------------*
*&      Form  add_no_draft_amount
*&---------------------------------------------------------------------*
*       무환 금액을 유환PO에 비율별로 더함.
*----------------------------------------------------------------------*
FORM add_no_draft_amount     TABLES   xztiscsdt STRUCTURE ztiscsdt
                                      xztitig06 STRUCTURE ztitig06
                                      xztiscsit STRUCTURE ztiscsit
                             USING    xztitcsk STRUCTURE ztitcsk
                                      xekkn     STRUCTURE ekkn
                                      xexpgr
                                      xwrbtr    TYPE bapicurr_d
                                      p_ebeln
                                      p_ebelp
                                      p_zekkn.
*                                      P_SUBRC   LIKE SY-SUBRC.


  DATA:  l_wrbtr     TYPE bapicurr_d,
         l_dmbtr     TYPE bapicurr_d.

*  CLEAR: P_SUBRC.

  SELECT SINGLE *
    FROM ekpo
   WHERE ebeln EQ p_ebeln
     AND ebelp EQ p_ebelp.

*> 부대비 금액.
  CLEAR: xztiscsdt.
  READ TABLE xztitig06 WITH KEY expgr = 'N'.
  IF sy-subrc NE 0.
    MESSAGE e871 RAISING distribution_error.
  ELSE.
    IF xztitig06-saknr IS INITIAL.
      MESSAGE e871 RAISING distribution_error.
    ENDIF.
    xztiscsdt-saknr = xztitig06-saknr.
  ENDIF.

  MOVE: 99999           TO xztiscsdt-buzei,
        '40'            TO xztiscsdt-bschl,
        xexpgr          TO xztiscsdt-expgr,
        'S'             TO xztiscsdt-koart,
*        xztitcsk-mwskz TO xztiscsdt-mwskz,
        xztitig06-mwskz TO xztiscsdt-mwskz,
        'S'             TO xztiscsdt-shkzg,
*        xZTITCSK-akont TO xZTIscsdt-saknr,
        xwrbtr          TO xztiscsdt-wrbtr,
*        xZTITCSK-wmwst TO xZTIscsdt-wmwst,
*        xwrbtr          TO xZTIscsdt-dmbtr,
*        xZTITCSK-fwbas TO xZTIscsdt-fwbas,
        xztiscsit-kostl TO xztiscsdt-kostl,
        xztiscsit-prctr TO xztiscsdt-prctr,
        xztiscsit-pspnr TO xztiscsdt-pspnr,
        xztitcsk-bupla TO xztiscsdt-bupla,
        xztitcsk-gsber TO xztiscsdt-gsber,
        xztiscsit-sgtxt TO xztiscsdt-sgtxt,
        xztiscsit-zuonr TO xztiscsdt-zuonr,
        p_ebeln         TO xztiscsdt-ebeln,
        p_ebelp         TO xztiscsdt-ebelp,
        p_zekkn         TO xztiscsdt-zekkn,
        '5'             TO xztiscsdt-itmst,
        sy-uname        TO xztiscsdt-cnam,
        sy-datlo        TO xztiscsdt-cdat,
        sy-timlo        TO xztiscsdt-ctme,
        sy-uname        TO xztiscsdt-unam,
        sy-datlo        TO xztiscsdt-udat,
        sy-timlo        TO xztiscsdt-utme.

  IF xztiscsdt-mwskz IS INITIAL.
    xztiscsdt-mwskz = xztiscsit-mwskz.
  ENDIF.

  APPEND xztiscsdt.

ENDFORM.                    " add_no_draft_amount
*&---------------------------------------------------------------------*
*&      Form  calc_po_history_qty
*&---------------------------------------------------------------------*
*    구매오더 이력 수량을 계산하여 송장처리 수량 조정.
*----------------------------------------------------------------------*
FORM calc_po_history_qty   TABLES  xztiscsdt  STRUCTURE ztiscsdt
                           USING   p_ebeln    TYPE      ebeln
                                   p_ebelp    TYPE      ebelp
                                   xekpo      STRUCTURE ekpo
                                   xztitcsk   STRUCTURE ztitcsk
                                   xmenge     LIKE      xztiscsdt-menge
                                   p_cscty    TYPE      zticscty.

  DATA:    l_ekbe      LIKE ekbe,
           l_ekbz      LIKE ekbz,
           l_ztiscsdt  LIKE ztiscsdt,
           l_findmng   TYPE remng,
           l_menge     LIKE xztiscsdt-menge,
           l_find      TYPE c.

  DATA: l_wemng        LIKE ekbes-wemng,
        l_remng        LIKE ekbes-remng,
        l_remng_tmp    LIKE ekbes-remng,
        l_wewrt        LIKE ekbes-wewrt,
        l_arewr        LIKE ekbes-arewr,
        l_rewrt        LIKE ekbes-rewrt.

*> Begin of Added By SH, Yoon ( 2008/08/11 )
  IF NOT xekpo-uebto IS INITIAL.
    xekpo-menge = xekpo-menge + ( xekpo-menge * ( xekpo-uebto / 100 ) ).
  ENDIF.
*> End of Added By SH, Yoon( 2008/08/11 )


  IF ztitig00-pstmt EQ 'F'.
    xztiscsdt-itmst = '5'.
    APPEND xztiscsdt.
    EXIT.
  ELSE.
    IF p_cscty EQ 'F' OR
       p_cscty EQ 'V'.
      xztiscsdt-itmst = '5'.
      APPEND xztiscsdt.
      EXIT.
    ENDIF.
  ENDIF.

  l_menge = xmenge.

  CLEAR iekbe.  REFRESH iekbe.
  CLEAR iekbes. REFRESH iekbes.
  CLEAR iekbez. REFRESH iekbez.
  CLEAR iekbnk. REFRESH iekbnk.
  CLEAR iekbz.  REFRESH iekbz.

  CALL FUNCTION 'ME_READ_HISTORY'
    EXPORTING
      ebeln              = p_ebeln
      ebelp              = p_ebelp
      webre              = xekpo-webre
      i_bypassing_buffer = 'X'
      i_refresh_buffer   = 'X'
    TABLES
      xekbe              = iekbe
      xekbes             = iekbes
      xekbez             = iekbez
      xekbnk             = iekbnk
      xekbz              = iekbz.

  CASE xztitcsk-vorgang.
    WHEN '1'.

    WHEN '2'.

    WHEN '3'.

    WHEN '4'.

  ENDCASE.

*  READ TABLE xZTIscsdt INTO l_ZTIscsdt WITH KEY ebeln = xekpo-ebeln
*                                                ebelp = xekpo-ebelp.
  CLEAR: l_findmng.
  LOOP AT xztiscsdt INTO l_ztiscsdt WHERE ebeln = p_ebeln
                                      AND ebelp = p_ebelp
                                      AND tbtkz = space.
    l_findmng = l_ztiscsdt-menge.
  ENDLOOP.
  IF sy-subrc EQ 0.
    l_find = 'X'.
  ELSE.
    CLEAR: l_find.
  ENDIF.


*>----------------------------------------------------------------------
*> 1 처리가능 : 송장 차변메모
*> 2 처리가능 : 송장 후속차변메모
*> 3 처리불능 : 송장 처리 후 차변메모
*> 4 처리불능 : 송장 처리 후 후속차변메모
*> 5 처리가능 : 회계전표
*>----------------------------------------------------------------------
  CLEAR: l_ekbe,  l_wemng, l_remng,
         l_wewrt, l_arewr, l_rewrt.

  IF xztiscsdt-kschl IS INITIAL.
* Goods receipts
    LOOP AT iekbes WHERE zekkn EQ space
                     AND ebelp EQ p_ebelp.
      ADD iekbes-wemng TO l_wemng.  ">입고
      ADD iekbes-remng TO l_remng.  ">송장처리
      ADD iekbes-rewrt TO l_rewrt.  ">입고금액
      ADD iekbes-wewrt TO l_wewrt.  ">송장금액
      IF iekbes-rewrt <> iekbes-arewr.
        ADD      iekbes-rewrt TO   l_wewrt.
        SUBTRACT iekbes-arewr FROM l_wewrt.
      ENDIF.
    ENDLOOP.

*> 송장처리수량이 0일 경우.
    IF l_remng EQ 0.
      xztiscsdt-itmst = '4'.
    ELSE.
*> 송장처리수량 만큼 후속차변..
      IF xztiscsdt-menge GT l_remng.
        xztiscsdt-menge = l_remng.
      ELSE.
*        xztiscsdt-menge = xekpo-menge.
        xztiscsdt-menge = l_menge.
      ENDIF.
      xztiscsdt-itmst = '2'.
    ENDIF.
    xztiscsdt-tbtkz = 'X'.
  ELSE.
    CLEAR: l_ekbz.
    LOOP AT iekbz WHERE kschl EQ xztiscsdt-kschl
                    AND ebelp EQ p_ebelp.
      IF iekbz-shkzg = 'H'.
        iekbz-menge = - iekbz-menge.
        iekbz-dmbtr = - iekbz-dmbtr.
        iekbz-arewr = - iekbz-arewr.
      ENDIF.
      CASE iekbz-bewtp.
        WHEN 'F'.                                  " goods receipt
          SUBTRACT iekbz-menge FROM l_wemng.
          IF iekbz-arewr IS INITIAL.
            SUBTRACT iekbz-dmbtr FROM l_wewrt.
          ELSE.
            SUBTRACT iekbz-arewr FROM l_wewrt.
          ENDIF.
*         consider posting for account maintenance of the
*         freight clearing account
        WHEN 'G' OR 'M' OR 'K'.
          ADD iekbz-menge TO l_remng.
*            ADD iekbz-dmbtr TO L_rewrt.
          IF iekbz-arewr IS INITIAL.
            ADD iekbz-dmbtr TO l_rewrt.
          ELSE.
            ADD iekbz-arewr TO l_rewrt.
          ENDIF.
        WHEN 'P'.
          ADD iekbz-menge TO l_remng.
          ADD iekbz-arewr TO l_rewrt.
      ENDCASE.
    ENDLOOP.

*> 송장처리수량이 0일 경우.
    IF l_remng EQ 0.
      IF l_find EQ 'X'.
        xztiscsdt-itmst = '2'.
        xztiscsdt-tbtkz = 'X'.
      ELSE.
        xztiscsdt-itmst = '1'.
        CLEAR: xztiscsdt-tbtkz.
      ENDIF.
    ELSE.
*> 송장처리수량 만큼 후속차변..
      l_remng_tmp = l_remng.

      IF l_find EQ 'X'.
        l_remng_tmp = l_remng_tmp + l_findmng.
      ENDIF.

      l_remng_tmp = l_remng_tmp + l_menge.

      IF l_remng_tmp GT xekpo-menge.
        xztiscsdt-menge = l_menge.
        xztiscsdt-itmst = '2'.
        xztiscsdt-tbtkz = 'X'.
      ELSE.
        xztiscsdt-menge = l_menge.
        xztiscsdt-itmst = '1'.
        xztiscsdt-tbtkz = ' '.
      ENDIF.

**      IF xekpo-menge EQ l_remng.
**        xztiscsdt-menge = xekpo-menge.
*      IF l_menge EQ l_remng.
*        xztiscsdt-menge = l_menge.
*        xztiscsdt-itmst = '2'.
*        xztiscsdt-tbtkz = 'X'.
**      ELSEIF xekpo-menge GT l_remng.
*      ELSEIF l_menge GT l_remng.
**> 무조건 PO 수량으로 처리.
***        xZTIscsdt-menge = xekpo-menge - l_remng.
**        xztiscsdt-menge = xekpo-menge.
*        xztiscsdt-menge = l_menge.
*        xztiscsdt-itmst = '1'.
*        CLEAR xztiscsdt-tbtkz.
*      ELSE.
**        xztiscsdt-menge = xekpo-menge.
*        xztiscsdt-menge = l_menge.
*        xztiscsdt-itmst = '2'.
*        xztiscsdt-tbtkz = 'X'.
*      ENDIF.
    ENDIF.
  ENDIF.

*  IF xZTIscsdt-itmst EQ '3' OR
*     xZTIscsdt-itmst EQ '4' OR
*     xZTIscsdt-itmst EQ '5'.
*    xZTIscsdt-menge = 0.
*  ENDIF.

  APPEND xztiscsdt.

ENDFORM.                    " calc_po_history_qty
*&---------------------------------------------------------------------*
*&      Form  check_posting_methods
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_posting_methods  TABLES xztiscsdt  STRUCTURE ztiscsdt
                            USING  xztiscsit  STRUCTURE ztiscsit.

  DATA: l_planned_cnt   TYPE i,
        l_unplan_cnt    TYPE i,
        l_error         TYPE c.

*> ITMST
*>----------------------------------------------------------------------
*> 1 처리가능 : 송장 차변메모
*> 2 처리가능 : 송장 후속차변메모
*> 3 처리불능 : 송장 처리 후 차변메모
*> 4 처리불능 : 송장 처리 후 후속차변메모
*> 5 처리가능 : 회계전표
*>----------------------------------------------------------------------
  IF ztitig00-pstmt EQ 'F'.
    LOOP AT xztiscsdt WHERE icssq = xztiscsit-icssq.
      xztiscsdt-itmst = '5'.
      MODIFY xztiscsdt.
    ENDLOOP.
    xztiscsit-cscrt = 'F'.
    EXIT.
  ELSEIF ztitig00-pstmt EQ 'B'.
    IF xztiscsit-cscty EQ 'F'.
      LOOP AT xztiscsdt WHERE icssq = xztiscsit-icssq.
        xztiscsdt-itmst = '5'.
        MODIFY xztiscsdt.
      ENDLOOP.
      xztiscsit-cscrt = 'F'.
      EXIT.
    ENDIF.
  ENDIF.


*>----------------------------------------------------------------------
*>  P : 계획비용
*>  U : 비계획비용
*>  C : 계획/비계획 콤바인
*>  F : 회계기표
*>  N : 미처리
*>----------------------------------------------------------------------
  CLEAR: l_planned_cnt, l_unplan_cnt, l_error.

  LOOP AT xztiscsdt WHERE icssq = xztiscsit-icssq.
    IF xztiscsdt-itmst EQ '3' OR
       xztiscsdt-itmst EQ '4'.
      l_error = 'X'.
      EXIT.
    ENDIF.

    IF xztiscsdt-tbtkz IS INITIAL.
      xztiscsit-cscrt = 'P'.
      ADD 1 TO l_planned_cnt.
    ELSE.
      ADD 1 TO l_unplan_cnt.
    ENDIF.
  ENDLOOP.

  IF l_error IS INITIAL.
    IF l_unplan_cnt EQ 0.
      xztiscsit-cscrt = 'P'.
    ELSEIF l_planned_cnt EQ 0.
      xztiscsit-cscrt = 'U'.
    ELSE.
      xztiscsit-cscrt = 'C'.
    ENDIF.
  ELSE.
    xztiscsit-cscrt = 'N'.
  ENDIF.

ENDFORM.                    " check_posting_methods
*&---------------------------------------------------------------------*
*&      Form  get_items_net_price_by_bl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_items_net_price_by_bl      TABLES xztisblit STRUCTURE ztisblit
                                     USING p_iblno
                                           p_netwr.

  DATA: ls_proj  LIKE proj.

  CLEAR: p_netwr.

  LOOP AT xztisblit WHERE   iblno = p_iblno
                      AND   repos = 'X'.
    g_tabix = sy-tabix.
*-----> 정가 총합계산.
    ADD xztisblit-refwr TO p_netwr.
  ENDLOOP.

ENDFORM.                    " get_items_net_price_by_bl
*&---------------------------------------------------------------------*
*&      Form  get_items_net_price_by_tx
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_items_net_price_by_tx      TABLES xztistxit STRUCTURE ztistxit
                                     USING p_taxno
                                           p_netwr.

  DATA: ls_proj  LIKE proj.

  CLEAR: p_netwr.

  LOOP AT xztistxit WHERE   taxno = p_taxno
                      AND   repos = 'X'.
    g_tabix = sy-tabix.
*-----> 정가 총합계산.
    ADD xztistxit-refwr TO p_netwr.
  ENDLOOP.

ENDFORM.                    " get_items_net_price_by_tx

*&---------------------------------------------------------------------*
*&      Form  build_invoice_items_by_bl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_invoice_items_by_bl  TABLES xztisblit  STRUCTURE ztisblit
                                       xztiscsdt  STRUCTURE ztiscsdt
                                       xztitig06  STRUCTURE ztitig06
                                USING  xztiscsit  STRUCTURE ztiscsit
                                       xztitcsk  STRUCTURE ztitcsk
                                       p_netwr
                                       p_iblno.

  TYPE-POOLS : mmcr.
  TYPE-POOLS : mmcr.
  DATA: t_ek08bn_temp    TYPE mmcr_xek08bn,
        ek08bn_temp      TYPE mmcr_ek08bn.

  DATA : l_buzei     LIKE ztitcsd-buzei,
         ls_proj     LIKE proj,
         l_konv      TYPE c.

  DATA : l_rate      TYPE f,
         l_wrbtr_max TYPE bapicurr_d,
         l_tabix_max TYPE sy-tabix,
         l_tabix     TYPE sy-tabix,
         l_wrbtr     TYPE bapicurr_d,
         l_dmbtr     TYPE bapicurr_d,
         l_netwr     TYPE bapicurr_d.

  DATA : g_wrbtr1    LIKE xztiscsdt-wrbtr,
         g_dmbtr1    LIKE xztiscsdt-dmbtr,
         g_wmwst1    LIKE xztiscsdt-wmwst,
         g_fwbas1    LIKE xztiscsdt-fwbas.

  DATA : l_lifnr     LIKE lfa1-lifnr.

  CLEAR: l_buzei, l_tabix.
  CLEAR: l_wrbtr_max, l_tabix_max.

  DATA: lt_xztisblit_c LIKE xztisblit OCCURS 0 WITH HEADER LINE.
  REFRESH lt_xztisblit_c.

  LOOP AT xztisblit WHERE   iblno = p_iblno
                      AND   repos = 'X'.
    CLEAR: ekko, ekpo, konv, mkpf, mseg.

    IF NOT xztisblit-ebeln IS INITIAL.
*> P/O Header Data select.
      SELECT SINGLE *
        FROM ekko
       WHERE ebeln  EQ  xztisblit-ebeln.

*> P/O Item Data select.
      SELECT SINGLE *
        FROM ekpo
       WHERE ebeln  EQ  xztisblit-ebeln
         AND ebelp  EQ  xztisblit-ebelp.
*         AND REPOS  EQ  'X'.
      IF ekpo-repos IS INITIAL.
        CONTINUE.
      ENDIF.
    ENDIF.

*> Get 비용코드 .
    CLEAR: konv, l_konv.
    READ TABLE xztitig06 WITH KEY expcd = xztiscsit-expcd.
    IF xztitig06-cscty EQ 'P' AND
      sy-subrc         EQ 0 .

      IF sy-subrc            EQ 0        AND
         NOT xztitig06-kschl IS INITIAL.
        IF NOT xztisblit-ebeln IS INITIAL.
          SELECT *
            FROM konv UP TO 1 ROWS
           WHERE knumv  EQ  ekko-knumv
             AND kposn  EQ  xztisblit-ebelp
*           AND zaehk  EQ  '01'
*             and STUNR
             AND kappl  EQ  'M'
             AND kschl  EQ  xztitig06-kschl.
          ENDSELECT.
          IF sy-subrc EQ 0.
            l_konv = 'X'.
*>
            CLEAR: l_lifnr.
            CALL FUNCTION 'ME_READ_COND_INVOICE'
              EXPORTING
                i_ebeln      = xztisblit-ebeln
                i_ebelp      = xztisblit-ebelp
                i_lifnr      = l_lifnr
              TABLES
                xek08bn_curr = t_ek08bn_temp.

            READ TABLE t_ek08bn_temp INTO ek08bn_temp
                                     WITH KEY kschl = xztitig06-kschl.
            IF sy-subrc NE 0.
*            MESSAGE E875 WITH xZTIslcit-ebeln xZTIslcit-ebelP
*                              xZTItig06-kschl
*                         RAISING distribution_error.
              CLEAR: konv.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    ADD 1 TO l_buzei.
    CLEAR: xztiscsdt.
    IF NOT ekpo-ebeln IS INITIAL.

      MOVE-CORRESPONDING ekpo TO xztiscsdt.

      SELECT SINGLE *
        FROM ekkn
       WHERE ebeln = ekpo-ebeln
       AND   ebelp = ekpo-ebelp
       AND   zekkn = '01'.
      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING ekkn TO xztiscsdt.
* 20051230 simcho 수입비용계정 PO계정으로 update되는것 방지
* ASEG 강S confirm
*        MOVE: ekkn-sakto        TO xztiscsdt-saknr.
* end simcho
      ENDIF.

*>> WBS (작업분할구조) 요소 마스터 데이타.
      IF NOT xztiscsdt-ps_psp_pnr IS INITIAL.
        SELECT SINGLE posid
          INTO xztiscsdt-pspnr
          FROM prps
         WHERE pspnr = xztiscsdt-ps_psp_pnr.
      ENDIF.
    ENDIF.

    MOVE: xztitcsk-bukrs     TO xztiscsdt-bukrs,
          xztitcsk-icsno     TO xztiscsdt-icsno,
          l_buzei            TO xztiscsdt-buzei,
          xztiscsit-icssq    TO xztiscsdt-icssq,
          xztitcsk-expgr     TO xztiscsdt-expgr,
          xztiscsit-expcd    TO xztiscsdt-expcd,
          'S'                TO xztiscsdt-koart,
          ekko-knumv         TO xztiscsdt-knumv,
          konv-stunr         TO xztiscsdt-stunr,
          konv-zaehk         TO xztiscsdt-zaehk,
          konv-kschl         TO xztiscsdt-kschl,
          xztiscsit-mwskz    TO xztiscsdt-mwskz,
          xztisblit-iblno    TO xztiscsdt-refno,
          xztisblit-iblit    TO xztiscsdt-refit,
          xztisblit-ebeln    TO xztiscsdt-ebeln,
          xztisblit-ebelp    TO xztiscsdt-ebelp,
*          xztitig06-saknr    TO xztiscsdt-saknr,
          '40'               TO xztiscsdt-bschl,
          'S'                TO xztiscsdt-shkzg,
          xztitcsk-bupla     TO xztiscsdt-bupla,
*          xztitcsk-gsber     TO xztiscsdt-gsber,
*          xztiscsit-kostl    TO xztiscsdt-kostl,
*          xztiscsit-prctr    TO xztiscsdt-prctr,
*          xztiscsit-pspnr    TO xztiscsdt-pspnr,
          xztisblit-blnum    TO xztiscsdt-zuonr,
          xztitig06-exptx    TO xztiscsdt-sgtxt,
          sy-uname           TO xztiscsdt-cnam,
          sy-datlo           TO xztiscsdt-cdat,
          sy-timlo           TO xztiscsdt-ctme,
          sy-uname           TO xztiscsdt-unam,
          sy-datlo           TO xztiscsdt-udat,
          sy-timlo           TO xztiscsdt-utme.

*> 구매오더상에 계정결정이 되지 않았을 경우,
    IF xztiscsdt-saknr IS INITIAL.
      MOVE xztitig06-saknr    TO xztiscsdt-saknr.
    ENDIF.
    IF xztiscsdt-kostl IS INITIAL.
      MOVE xztiscsit-kostl    TO xztiscsdt-kostl.
    ENDIF.
    IF xztiscsdt-prctr IS INITIAL.
      MOVE xztiscsit-prctr    TO xztiscsdt-prctr.
    ENDIF.


*> 사업영역 결정(플랜트+디비젼).
    IF xztiscsdt-gsber IS INITIAL AND
       NOT xztiscsdt-matnr IS INITIAL.
      SELECT SINGLE gsber
        INTO xztiscsdt-gsber
        FROM t134g
       WHERE werks EQ xztiscsdt-werks
         AND spart EQ ( SELECT spart
                          FROM mara
                         WHERE matnr EQ xztiscsdt-matnr ).
    ENDIF.
*

*
    IF NOT xztisblit-ebeln IS INITIAL.
      MOVE: ekpo-menge       TO xztiscsdt-menge,
            ekpo-meins       TO xztiscsdt-meins,
            ekpo-bprme       TO xztiscsdt-bprme,
            ekpo-peinh       TO xztiscsdt-peinh.
*> 해당문서별 배부원칙일 경우.
      IF ztitig00-dstbt EQ 'D'.
        MOVE: xztisblit-blmng TO xztiscsdt-menge.
      ENDIF.
    ELSE.
      MOVE: xztisblit-blmng  TO xztiscsdt-menge,
            xztisblit-meins  TO xztiscsdt-meins,
            xztisblit-meins  TO xztiscsdt-bprme,
            1                TO xztiscsdt-peinh.
    ENDIF.

    IF p_netwr IS INITIAL.
      l_rate =  1.
    ELSE.
      l_rate =  xztisblit-refwr / p_netwr.
    ENDIF.

*    xZTIscsdt-wrbtr = xZTIscsit-wrbtr * l_rate.
*    xZTIscsdt-dmbtr = xZTIscsit-dmbtr * l_rate.
*    xZTIscsdt-wmwst = xZTIscsit-wmwst * l_rate.
*    xZTIscsdt-fwbas = xZTIscsit-fwbas * l_rate.
*
    xztiscsdt-wrbtr =
       ( TRUNC( ( xztiscsit-wrbtr * l_rate ) * 100 ) ) / 100.

    xztiscsdt-dmbtr =
       ( TRUNC( ( xztiscsit-dmbtr * l_rate ) * 100 ) ) / 100.

    xztiscsdt-wmwst =
       ( TRUNC( ( xztiscsit-wmwst * l_rate ) * 100 ) ) / 100.

    xztiscsdt-fwbas =
       ( TRUNC( ( xztiscsit-fwbas * l_rate ) * 100 ) ) / 100.

*>구매오더 이력 수량을 계산하여 송장처리 수량 조정.
    PERFORM calc_po_history_qty TABLES xztiscsdt
                                USING  xztiscsdt-ebeln
                                       xztiscsdt-ebelp
                                       ekpo
                                       xztitcsk
                                       xztiscsdt-menge
                                       xztiscsit-cscty.

*> 가장 큰 항목을 찾기 위해.
    DESCRIBE TABLE xztiscsdt LINES l_tabix.
    READ TABLE xztiscsdt INDEX l_tabix.

    IF l_wrbtr_max LT xztiscsdt-wrbtr.
      l_wrbtr_max = xztiscsdt-wrbtr.
      l_tabix_max = l_tabix.
    ENDIF.

    ADD: xztiscsdt-wrbtr TO g_wrbtr1,
         xztiscsdt-dmbtr TO g_dmbtr1,
         xztiscsdt-wmwst TO g_wmwst1,
         xztiscsdt-fwbas TO g_fwbas1.
  ENDLOOP.

  IF l_tabix_max IS INITIAL.
    DESCRIBE TABLE xztiscsdt LINES g_line.
    READ TABLE xztiscsdt INDEX g_line.
  ELSE.
    READ TABLE xztiscsdt INDEX l_tabix_max.
  ENDIF.
  g_tabix = sy-tabix.
*> ITEM 보정 작업.
  IF sy-subrc EQ 0.
*> 문서상 금액.
    IF xztiscsit-wrbtr GT g_wrbtr1.
      xztiscsdt-wrbtr = xztiscsdt-wrbtr +
                       ( xztiscsit-wrbtr - g_wrbtr1 ).
    ELSEIF xztiscsit-wrbtr LT g_wrbtr1.
      xztiscsdt-wrbtr = xztiscsdt-wrbtr -
                       ( g_wrbtr1 - xztiscsit-wrbtr ).
    ENDIF.

*> 현지통화.
    IF xztiscsit-dmbtr GT g_dmbtr1.
      xztiscsdt-dmbtr = xztiscsdt-dmbtr +
                       ( xztiscsit-dmbtr - g_dmbtr1 ).
    ELSEIF xztiscsit-dmbtr LT g_dmbtr1.
      xztiscsdt-dmbtr = xztiscsdt-dmbtr -
                       ( g_dmbtr1 - xztiscsit-dmbtr ).
    ENDIF.
*> 세액.
    IF xztiscsit-wmwst GT g_wmwst1.
      xztiscsdt-wmwst = xztiscsdt-wmwst +
                       ( xztiscsit-wmwst - g_wmwst1 ).
    ELSEIF xztiscsit-wmwst LT g_wmwst1.
      xztiscsdt-wmwst = xztiscsdt-wmwst -
                       ( g_wmwst1 - xztiscsit-wmwst ).
    ENDIF.

*> 표준액.
    IF xztiscsit-fwbas GT g_fwbas1.
      xztiscsdt-fwbas = xztiscsdt-fwbas +
                       ( xztiscsit-fwbas - g_fwbas1 ).
    ELSEIF xztiscsit-fwbas LT g_fwbas1.
      xztiscsdt-fwbas = xztiscsdt-fwbas -
                       ( g_fwbas1 - xztiscsit-fwbas ).
    ENDIF.

    MODIFY xztiscsdt INDEX g_tabix.
  ENDIF.

ENDFORM.                    " build_invoice_items_by_bl
*&---------------------------------------------------------------------*
*&      Form  get_items_net_price_by_cc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_XZTISCCIT  text
*      -->P_XCSIT_ICCNO  text
*      -->P_L_NETWR  text
*----------------------------------------------------------------------*
FORM get_items_net_price_by_cc      TABLES xztisccit STRUCTURE ztisccit
                                     USING p_iccno
                                           p_netwr.

  DATA: ls_proj  LIKE proj.

  CLEAR: p_netwr.

  LOOP AT xztisccit WHERE   iccno = p_iccno
                      AND   repos = 'X'.
    g_tabix = sy-tabix.
*-----> 정가 총합계산.
    ADD xztisccit-refwr TO p_netwr.
  ENDLOOP.

ENDFORM.                    " get_items_net_price_by_cc
*&---------------------------------------------------------------------*
*&      Form  build_invoice_items_by_cc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_invoice_items_by_cc  TABLES xztisccit  STRUCTURE ztisccit
                                       xztiscsdt  STRUCTURE ztiscsdt
                                       xztitig06  STRUCTURE ztitig06
                                USING  xztiscsit  STRUCTURE ztiscsit
                                       xztitcsk  STRUCTURE ztitcsk
                                       p_netwr
                                       p_iccno.
  TYPE-POOLS : mmcr.

  DATA: t_ek08bn_temp    TYPE mmcr_xek08bn,
        ek08bn_temp      TYPE mmcr_ek08bn.


  DATA : l_buzei     LIKE ztitcsd-buzei,
         ls_proj     LIKE proj,
         l_konv      TYPE c.

  DATA : l_rate      TYPE f,
         l_wrbtr_max TYPE bapicurr_d,
         l_tabix_max TYPE sy-tabix,
         l_tabix     TYPE sy-tabix,
         l_wrbtr     TYPE bapicurr_d,
         l_dmbtr     TYPE bapicurr_d,
         l_netwr     TYPE bapicurr_d.

  DATA : g_wrbtr1    LIKE xztiscsdt-wrbtr,
         g_dmbtr1    LIKE xztiscsdt-dmbtr,
         g_wmwst1    LIKE xztiscsdt-wmwst,
         g_fwbas1    LIKE xztiscsdt-fwbas.

  DATA : l_lifnr     LIKE lfa1-lifnr.

  CLEAR: l_buzei, l_tabix.
  CLEAR: l_wrbtr_max, l_tabix_max.

  LOOP AT xztisccit WHERE   iccno = p_iccno
                      AND   repos = 'X'.
    CLEAR: ekko, ekpo, konv, mkpf, mseg.

    IF NOT xztisccit-ebeln IS INITIAL.
*> P/O Header Data select.
      SELECT SINGLE *
        FROM ekko
       WHERE ebeln  EQ  xztisccit-ebeln.

*> P/O Item Data select.
      SELECT SINGLE *
        FROM ekpo
       WHERE ebeln  EQ  xztisccit-ebeln
         AND ebelp  EQ  xztisccit-ebelp.
*         AND REPOS  EQ  'X'.
      IF ekpo-repos IS INITIAL.
        CONTINUE.
      ENDIF.
    ENDIF.

*> Get 비용코드 .
    CLEAR: konv, l_konv.
    READ TABLE xztitig06 WITH KEY expcd = xztiscsit-expcd.
    IF xztitig06-cscty EQ 'P' AND
      sy-subrc         EQ 0 .

      IF sy-subrc            EQ 0        AND
         NOT xztitig06-kschl IS INITIAL.
        IF NOT xztisccit-ebeln IS INITIAL.
          SELECT *
            FROM konv UP TO 1 ROWS
           WHERE knumv  EQ  ekko-knumv
             AND kposn  EQ  xztisccit-ebelp
*           AND zaehk  EQ  '01'
*             and STUNR
             AND kappl  EQ  'M'
             AND kschl  EQ  xztitig06-kschl.
          ENDSELECT.
          IF sy-subrc EQ 0.
            l_konv = 'X'.
*>
            CLEAR: l_lifnr.
            CALL FUNCTION 'ME_READ_COND_INVOICE'
              EXPORTING
                i_ebeln      = xztisccit-ebeln
                i_ebelp      = xztisccit-ebelp
                i_lifnr      = l_lifnr
              TABLES
                xek08bn_curr = t_ek08bn_temp.

            READ TABLE t_ek08bn_temp INTO ek08bn_temp
                                     WITH KEY kschl = xztitig06-kschl.
            IF sy-subrc NE 0.
*            MESSAGE E875 WITH xZTIslcit-ebeln xZTIslcit-ebelP
*                              xZTItig06-kschl
*                         RAISING distribution_error.
              CLEAR: konv.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    ADD 1 TO l_buzei.
    CLEAR: xztiscsdt.
    IF NOT ekpo-ebeln IS INITIAL.

      MOVE-CORRESPONDING ekpo TO xztiscsdt.

      SELECT SINGLE *
        FROM ekkn
       WHERE ebeln = ekpo-ebeln
       AND   ebelp = ekpo-ebelp
       AND   zekkn = '01'.
      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING ekkn TO xztiscsdt.
* 20051230 simcho 수입비용계정 PO계정으로 update되는것 방지
* ASEG 강S confirm
*        MOVE: ekkn-sakto        TO xztiscsdt-saknr.
* end simcho
      ENDIF.

*>> WBS (작업분할구조) 요소 마스터 데이타.
      IF NOT xztiscsdt-ps_psp_pnr IS INITIAL.
        SELECT SINGLE posid
          INTO xztiscsdt-pspnr
          FROM prps
         WHERE pspnr = xztiscsdt-ps_psp_pnr.
      ENDIF.
    ENDIF.
    MOVE: xztitcsk-bukrs     TO xztiscsdt-bukrs,
          xztitcsk-icsno     TO xztiscsdt-icsno,
          l_buzei            TO xztiscsdt-buzei,
          xztiscsit-icssq    TO xztiscsdt-icssq,
          xztitcsk-expgr     TO xztiscsdt-expgr,
          xztiscsit-expcd    TO xztiscsdt-expcd,
          'S'                TO xztiscsdt-koart,
          ekko-knumv         TO xztiscsdt-knumv,
          konv-stunr         TO xztiscsdt-stunr,
          konv-zaehk         TO xztiscsdt-zaehk,
          konv-kschl         TO xztiscsdt-kschl,
          xztiscsit-mwskz    TO xztiscsdt-mwskz,
          xztisccit-iblno    TO xztiscsdt-refno,
          xztisccit-iblit    TO xztiscsdt-refit,
          xztisccit-ebeln    TO xztiscsdt-ebeln,
          xztisccit-ebelp    TO xztiscsdt-ebelp,
*          xztitig06-saknr    TO xztiscsdt-saknr,
          '40'               TO xztiscsdt-bschl,
          'S'                TO xztiscsdt-shkzg,
          xztitcsk-bupla    TO xztiscsdt-bupla,
*          xztitcsk-gsber    TO xztiscsdt-gsber,
*          xztiscsit-kostl    TO xztiscsdt-kostl,
*          xztiscsit-prctr    TO xztiscsdt-prctr,
*          xztiscsit-pspnr    TO xztiscsdt-pspnr,
          xztisccit-cdcno    TO xztiscsdt-zuonr,
          xztitig06-exptx    TO xztiscsdt-sgtxt,
          sy-uname           TO xztiscsdt-cnam,
          sy-datlo           TO xztiscsdt-cdat,
          sy-timlo           TO xztiscsdt-ctme,
          sy-uname           TO xztiscsdt-unam,
          sy-datlo           TO xztiscsdt-udat,
          sy-timlo           TO xztiscsdt-utme.

*> 구매오더상에 계정결정이 되지 않았을 경우,
    IF xztiscsdt-saknr IS INITIAL.
      MOVE xztitig06-saknr    TO xztiscsdt-saknr.
    ENDIF.
    IF xztiscsdt-kostl IS INITIAL.
      MOVE xztiscsit-kostl    TO xztiscsdt-kostl.
    ENDIF.
    IF xztiscsdt-prctr IS INITIAL.
      MOVE xztiscsit-prctr    TO xztiscsdt-prctr.
    ENDIF.


*> 사업영역 결정(플랜트+디비젼).
    IF xztiscsdt-gsber IS INITIAL AND
       NOT xztiscsdt-matnr IS INITIAL.
      SELECT SINGLE gsber
        INTO xztiscsdt-gsber
        FROM t134g
       WHERE werks EQ xztiscsdt-werks
         AND spart EQ ( SELECT spart
                          FROM mara
                         WHERE matnr EQ xztiscsdt-matnr ).
    ENDIF.

*
    IF NOT xztisccit-ebeln IS INITIAL.
      MOVE: ekpo-menge       TO xztiscsdt-menge,
            ekpo-meins       TO xztiscsdt-meins,
            ekpo-bprme       TO xztiscsdt-bprme,
            ekpo-peinh       TO xztiscsdt-peinh.
*> 해당문서별 배부원칙일 경우.
      IF ztitig00-dstbt EQ 'D'.
        MOVE: xztisccit-ccmng TO xztiscsdt-menge.
      ENDIF.
    ELSE.
      MOVE: xztisccit-ccmng  TO xztiscsdt-menge,
            xztisccit-meins  TO xztiscsdt-meins,
            xztisccit-meins  TO xztiscsdt-bprme,
            1                TO xztiscsdt-peinh.
    ENDIF.

    IF p_netwr IS INITIAL.
      l_rate =  1.
    ELSE.
      l_rate =  xztisccit-refwr / p_netwr.
    ENDIF.

*    xZTIscsdt-wrbtr = xZTIscsit-wrbtr * l_rate.
*    xZTIscsdt-dmbtr = xZTIscsit-dmbtr * l_rate.
*    xZTIscsdt-wmwst = xZTIscsit-wmwst * l_rate.
*    xZTIscsdt-fwbas = xZTIscsit-fwbas * l_rate.

    xztiscsdt-wrbtr =
       ( TRUNC( ( xztiscsit-wrbtr * l_rate ) * 100 ) ) / 100.

    xztiscsdt-dmbtr =
       ( TRUNC( ( xztiscsit-dmbtr * l_rate ) * 100 ) ) / 100.

    xztiscsdt-wmwst =
       ( TRUNC( ( xztiscsit-wmwst * l_rate ) * 100 ) ) / 100.

    xztiscsdt-fwbas =
       ( TRUNC( ( xztiscsit-fwbas * l_rate ) * 100 ) ) / 100.

*>구매오더 이력 수량을 계산하여 송장처리 수량 조정.
    PERFORM calc_po_history_qty TABLES xztiscsdt
                                USING  xztiscsdt-ebeln
                                       xztiscsdt-ebelp
                                       ekpo
                                       xztitcsk
                                       xztiscsdt-menge
                                       xztiscsit-cscty.

*> 가장 큰 항목을 찾기 위해.
    DESCRIBE TABLE xztiscsdt LINES l_tabix.
    READ TABLE xztiscsdt INDEX l_tabix.

    IF l_wrbtr_max LT xztiscsdt-wrbtr.
      l_wrbtr_max = xztiscsdt-wrbtr.
      l_tabix_max = l_tabix.
    ENDIF.

    ADD: xztiscsdt-wrbtr TO g_wrbtr1,
         xztiscsdt-dmbtr TO g_dmbtr1,
         xztiscsdt-wmwst TO g_wmwst1,
         xztiscsdt-fwbas TO g_fwbas1.
  ENDLOOP.

  IF l_tabix_max IS INITIAL.
    DESCRIBE TABLE xztiscsdt LINES g_line.
    READ TABLE xztiscsdt INDEX g_line.
  ELSE.
    READ TABLE xztiscsdt INDEX l_tabix_max.
  ENDIF.
  g_tabix = sy-tabix.
*> ITEM 보정 작업.
  IF sy-subrc EQ 0.
*> 문서상 금액.
    IF xztiscsit-wrbtr GT g_wrbtr1.
      xztiscsdt-wrbtr = xztiscsdt-wrbtr +
                       ( xztiscsit-wrbtr - g_wrbtr1 ).
    ELSEIF xztiscsit-wrbtr LT g_wrbtr1.
      xztiscsdt-wrbtr = xztiscsdt-wrbtr -
                       ( g_wrbtr1 - xztiscsit-wrbtr ).
    ENDIF.

*> 현지통화.
    IF xztiscsit-dmbtr GT g_dmbtr1.
      xztiscsdt-dmbtr = xztiscsdt-dmbtr +
                       ( xztiscsit-dmbtr - g_dmbtr1 ).
    ELSEIF xztiscsit-dmbtr LT g_dmbtr1.
      xztiscsdt-dmbtr = xztiscsdt-dmbtr -
                       ( g_dmbtr1 - xztiscsit-dmbtr ).
    ENDIF.
*> 세액.
    IF xztiscsit-wmwst GT g_wmwst1.
      xztiscsdt-wmwst = xztiscsdt-wmwst +
                       ( xztiscsit-wmwst - g_wmwst1 ).
    ELSEIF xztiscsit-wmwst LT g_wmwst1.
      xztiscsdt-wmwst = xztiscsdt-wmwst -
                       ( g_wmwst1 - xztiscsit-wmwst ).
    ENDIF.

*> 표준액.
    IF xztiscsit-fwbas GT g_fwbas1.
      xztiscsdt-fwbas = xztiscsdt-fwbas +
                       ( xztiscsit-fwbas - g_fwbas1 ).
    ELSEIF xztiscsit-fwbas LT g_fwbas1.
      xztiscsdt-fwbas = xztiscsdt-fwbas -
                       ( g_fwbas1 - xztiscsit-fwbas ).
    ENDIF.

    MODIFY xztiscsdt INDEX g_tabix.
  ENDIF.

ENDFORM.                    " build_invoice_items_by_cc

*&---------------------------------------------------------------------*
*&      Form  build_invoice_items_by_tx
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_invoice_items_by_tx  TABLES xztistxit  STRUCTURE ztistxit
                                       xztiscsdt  STRUCTURE ztiscsdt
                                       xztitig06  STRUCTURE ztitig06
                                USING  xztiscsit  STRUCTURE ztiscsit
                                       xztitcsk   STRUCTURE ztitcsk
                                       p_netwr
                                       p_taxno.

  TYPE-POOLS : mmcr.
  TYPE-POOLS : mmcr.
  DATA: t_ek08bn_temp    TYPE mmcr_xek08bn,
        ek08bn_temp      TYPE mmcr_ek08bn.

  DATA : l_buzei     LIKE ztitcsd-buzei,
         ls_proj     LIKE proj,
         l_konv      TYPE c.

  DATA : l_rate      TYPE f,
         l_wrbtr_max TYPE bapicurr_d,
         l_tabix_max TYPE sy-tabix,
         l_tabix     TYPE sy-tabix,
         l_wrbtr     TYPE bapicurr_d,
         l_dmbtr     TYPE bapicurr_d,
         l_netwr     TYPE bapicurr_d.

  DATA : g_wrbtr1    LIKE xztiscsdt-wrbtr,
         g_dmbtr1    LIKE xztiscsdt-dmbtr,
         g_wmwst1    LIKE xztiscsdt-wmwst,
         g_fwbas1    LIKE xztiscsdt-fwbas.

  DATA : l_lifnr     LIKE lfa1-lifnr.

  CLEAR: l_buzei, l_tabix.
  CLEAR: l_wrbtr_max, l_tabix_max.

  LOOP AT xztistxit WHERE   taxno = p_taxno
                      AND   repos = 'X'.
    CLEAR: ekko, ekpo, konv, mkpf, mseg.

    IF NOT xztistxit-ebeln IS INITIAL.
*> P/O Header Data select.
      SELECT SINGLE *
        FROM ekko
       WHERE ebeln  EQ  xztistxit-ebeln.

*> P/O Item Data select.
      SELECT SINGLE *
        FROM ekpo
       WHERE ebeln  EQ  xztistxit-ebeln
         AND ebelp  EQ  xztistxit-ebelp.
*         AND REPOS  EQ  'X'.
      IF ekpo-repos IS INITIAL.
        CONTINUE.
      ENDIF.
    ENDIF.

*> Get 비용코드 .
    CLEAR: konv, l_konv.
    READ TABLE xztitig06 WITH KEY expcd = xztiscsit-expcd.
    IF xztitig06-cscty EQ 'P' AND
      sy-subrc         EQ 0 .
      IF sy-subrc            EQ 0        AND
         NOT xztitig06-kschl IS INITIAL.
        IF NOT xztistxit-ebeln IS INITIAL.
          SELECT *
            FROM konv UP TO 1 ROWS
           WHERE knumv  EQ  ekko-knumv
             AND kposn  EQ  xztistxit-ebelp
*           AND zaehk  EQ  '01'
*             and STUNR
             AND kappl  EQ  'M'
             AND kschl  EQ  xztitig06-kschl.
          ENDSELECT.
          IF sy-subrc EQ 0.
            l_konv = 'X'.
*>
            CLEAR: l_lifnr.
            CALL FUNCTION 'ME_READ_COND_INVOICE'
              EXPORTING
                i_ebeln      = xztistxit-ebeln
                i_ebelp      = xztistxit-ebelp
                i_lifnr      = l_lifnr
              TABLES
                xek08bn_curr = t_ek08bn_temp.

            READ TABLE t_ek08bn_temp INTO ek08bn_temp
                                     WITH KEY kschl = xztitig06-kschl.
            IF sy-subrc NE 0.
*            MESSAGE E875 WITH xZTIslcit-ebeln xZTIslcit-ebelP
*                              xZTItig06-kschl
*                         RAISING distribution_error.
              CLEAR: konv.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    ADD 1 TO l_buzei.
    CLEAR: xztiscsdt.
    IF NOT ekpo-ebeln IS INITIAL.

      MOVE-CORRESPONDING ekpo TO xztiscsdt.

      SELECT SINGLE *
        INTO CORRESPONDING FIELDS OF xztiscsdt
        FROM ekkn
       WHERE ebeln = ekpo-ebeln
       AND   ebelp = ekpo-ebelp
       AND   zekkn = '01'.
*>> WBS (작업분할구조) 요소 마스터 데이타.
      IF NOT xztiscsdt-ps_psp_pnr IS INITIAL.
        SELECT SINGLE posid
          INTO xztiscsdt-pspnr
          FROM prps
         WHERE pspnr = xztiscsdt-ps_psp_pnr.
      ENDIF.
    ENDIF.

    MOVE: xztitcsk-bukrs     TO xztiscsdt-bukrs,
          xztitcsk-icsno     TO xztiscsdt-icsno,
          l_buzei            TO xztiscsdt-buzei,
          xztiscsit-icssq    TO xztiscsdt-icssq,
          xztitcsk-expgr     TO xztiscsdt-expgr,
          xztiscsit-expcd    TO xztiscsdt-expcd,
          'S'                TO xztiscsdt-koart,
          ekko-knumv         TO xztiscsdt-knumv,
          konv-stunr         TO xztiscsdt-stunr,
          konv-zaehk         TO xztiscsdt-zaehk,
          konv-kschl         TO xztiscsdt-kschl,
          xztiscsit-mwskz    TO xztiscsdt-mwskz,
          xztistxit-taxno    TO xztiscsdt-refno,
          xztistxit-txz01    TO xztiscsdt-refit,
          xztistxit-ebeln    TO xztiscsdt-ebeln,
          xztistxit-ebelp    TO xztiscsdt-ebelp,
          xztitig06-saknr    TO xztiscsdt-saknr,
          '40'               TO xztiscsdt-bschl,
          'S'                TO xztiscsdt-shkzg,
          xztitcsk-bupla     TO xztiscsdt-bupla,
          xztitcsk-gsber     TO xztiscsdt-gsber,
          xztiscsit-kostl    TO xztiscsdt-kostl,
          xztiscsit-prctr    TO xztiscsdt-prctr,
          xztiscsit-pspnr    TO xztiscsdt-pspnr,
          xztistxit-txrno    TO xztiscsdt-zuonr,
          xztitig06-exptx    TO xztiscsdt-sgtxt,
          sy-uname           TO xztiscsdt-cnam,
          sy-datlo           TO xztiscsdt-cdat,
          sy-timlo           TO xztiscsdt-ctme,
          sy-uname           TO xztiscsdt-unam,
          sy-datlo           TO xztiscsdt-udat,
          sy-timlo           TO xztiscsdt-utme.
*
    IF NOT xztistxit-ebeln IS INITIAL.
      MOVE: ekpo-menge       TO xztiscsdt-menge,
            ekpo-meins       TO xztiscsdt-meins,
            ekpo-bprme       TO xztiscsdt-bprme,
            ekpo-peinh       TO xztiscsdt-peinh.
*> 해당문서별 배부원칙일 경우.
      IF ztitig00-dstbt EQ 'D'.
        MOVE: xztistxit-txmng TO xztiscsdt-menge.
      ENDIF.
    ELSE.
      MOVE: xztistxit-txmng  TO xztiscsdt-menge,
            xztistxit-meins  TO xztiscsdt-meins,
            xztistxit-meins  TO xztiscsdt-bprme,
            1                TO xztiscsdt-peinh.
    ENDIF.

    IF p_netwr IS INITIAL.
      l_rate =  1.
    ELSE.
      l_rate =  xztistxit-refwr / p_netwr.
    ENDIF.

*    xZTIscsdt-wrbtr = xZTIscsit-wrbtr * l_rate.
*    xZTIscsdt-dmbtr = xZTIscsit-dmbtr * l_rate.
*    xZTIscsdt-wmwst = xZTIscsit-wmwst * l_rate.
*    xZTIscsdt-fwbas = xZTIscsit-fwbas * l_rate.
*
    xztiscsdt-wrbtr =
       ( TRUNC( ( xztiscsit-wrbtr * l_rate ) * 100 ) ) / 100.

    xztiscsdt-dmbtr =
       ( TRUNC( ( xztiscsit-dmbtr * l_rate ) * 100 ) ) / 100.

    xztiscsdt-wmwst =
       ( TRUNC( ( xztiscsit-wmwst * l_rate ) * 100 ) ) / 100.

    xztiscsdt-fwbas =
       ( TRUNC( ( xztiscsit-fwbas * l_rate ) * 100 ) ) / 100.

*>구매오더 이력 수량을 계산하여 송장처리 수량 조정.
    PERFORM calc_po_history_qty TABLES xztiscsdt
                                USING  xztiscsdt-ebeln
                                       xztiscsdt-ebelp
                                       ekpo
                                       xztitcsk
                                       xztiscsdt-menge
                                       xztiscsit-cscty.

*> 가장 큰 항목을 찾기 위해.
    DESCRIBE TABLE xztiscsdt LINES l_tabix.
    READ TABLE xztiscsdt INDEX l_tabix.

    IF l_wrbtr_max LT xztiscsdt-wrbtr.
      l_wrbtr_max = xztiscsdt-wrbtr.
      l_tabix_max = l_tabix.
    ENDIF.

    ADD: xztiscsdt-wrbtr TO g_wrbtr1,
         xztiscsdt-dmbtr TO g_dmbtr1,
         xztiscsdt-wmwst TO g_wmwst1,
         xztiscsdt-fwbas TO g_fwbas1.
  ENDLOOP.

  IF l_tabix_max IS INITIAL.
    DESCRIBE TABLE xztiscsdt LINES g_line.
    READ TABLE xztiscsdt INDEX g_line.
  ELSE.
    READ TABLE xztiscsdt INDEX l_tabix_max.
  ENDIF.
  g_tabix = sy-tabix.
*> ITEM 보정 작업.
  IF sy-subrc EQ 0.
*> 문서상 금액.
    IF xztiscsit-wrbtr GT g_wrbtr1.
      xztiscsdt-wrbtr = xztiscsdt-wrbtr +
                       ( xztiscsit-wrbtr - g_wrbtr1 ).
    ELSEIF xztiscsit-wrbtr LT g_wrbtr1.
      xztiscsdt-wrbtr = xztiscsdt-wrbtr -
                       ( g_wrbtr1 - xztiscsit-wrbtr ).
    ENDIF.

*> 현지통화.
    IF xztiscsit-dmbtr GT g_dmbtr1.
      xztiscsdt-dmbtr = xztiscsdt-dmbtr +
                       ( xztiscsit-dmbtr - g_dmbtr1 ).
    ELSEIF xztiscsit-dmbtr LT g_dmbtr1.
      xztiscsdt-dmbtr = xztiscsdt-dmbtr -
                       ( g_dmbtr1 - xztiscsit-dmbtr ).
    ENDIF.
*> 세액.
    IF xztiscsit-wmwst GT g_wmwst1.
      xztiscsdt-wmwst = xztiscsdt-wmwst +
                       ( xztiscsit-wmwst - g_wmwst1 ).
    ELSEIF xztiscsit-wmwst LT g_wmwst1.
      xztiscsdt-wmwst = xztiscsdt-wmwst -
                       ( g_wmwst1 - xztiscsit-wmwst ).
    ENDIF.

*> 표준액.
    IF xztiscsit-fwbas GT g_fwbas1.
      xztiscsdt-fwbas = xztiscsdt-fwbas +
                       ( xztiscsit-fwbas - g_fwbas1 ).
    ELSEIF xztiscsit-fwbas LT g_fwbas1.
      xztiscsdt-fwbas = xztiscsdt-fwbas -
                       ( g_fwbas1 - xztiscsit-fwbas ).
    ENDIF.

    MODIFY xztiscsdt INDEX g_tabix.
  ENDIF.

ENDFORM.                    " build_invoice_items_by_tx
*&---------------------------------------------------------------------*
*&      Form  build_invoice_items_by_tx1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_invoice_items_by_tx1 TABLES xztivtx01  STRUCTURE ztivtx01
                                       xztiscsdt  STRUCTURE ztiscsdt
                                       xztitig06  STRUCTURE ztitig06
                                USING  xztiscsit  STRUCTURE ztiscsit
                                       xztitcsk   STRUCTURE ztitcsk
                                       p_netwr
                                       p_taxno.

  TYPE-POOLS : mmcr.
  TYPE-POOLS : mmcr.
  DATA: t_ek08bn_temp    TYPE mmcr_xek08bn,
        ek08bn_temp      TYPE mmcr_ek08bn.

  DATA : l_buzei     LIKE ztitcsd-buzei,
         ls_proj     LIKE proj,
         l_konv      TYPE c.

  DATA : l_rate      TYPE f,
         l_wrbtr_max TYPE bapicurr_d,
         l_tabix_max TYPE sy-tabix,
         l_tabix     TYPE sy-tabix,
         l_wrbtr     TYPE bapicurr_d,
         l_dmbtr     TYPE bapicurr_d,
         l_netwr     TYPE bapicurr_d.

  DATA : g_wrbtr1    LIKE xztiscsdt-wrbtr,
         g_dmbtr1    LIKE xztiscsdt-dmbtr,
         g_wmwst1    LIKE xztiscsdt-wmwst,
         g_fwbas1    LIKE xztiscsdt-fwbas.

  DATA : l_lifnr     LIKE lfa1-lifnr.

  CLEAR: l_buzei, l_tabix.
  CLEAR: l_wrbtr_max, l_tabix_max.

  LOOP AT xztivtx01 WHERE   taxno = p_taxno
                      AND   repos = 'X'.
    CLEAR: ekko, ekpo, konv, mkpf, mseg.

    IF NOT xztivtx01-ebeln IS INITIAL.
*> P/O Header Data select.
      SELECT SINGLE *
        FROM ekko
       WHERE ebeln  EQ  xztivtx01-ebeln.

*> P/O Item Data select.
      SELECT SINGLE *
        FROM ekpo
       WHERE ebeln  EQ  xztivtx01-ebeln
         AND ebelp  EQ  xztivtx01-ebelp.
*         AND REPOS  EQ  'X'.
      IF ekpo-repos IS INITIAL.
        CONTINUE.
      ENDIF.
    ENDIF.

*> Get 비용코드 .
    CLEAR: konv, l_konv.
    READ TABLE xztitig06 WITH KEY expcd = xztiscsit-expcd.
    IF xztitig06-cscty EQ 'P' AND
      sy-subrc         EQ 0 .
      IF sy-subrc            EQ 0        AND
         NOT xztitig06-kschl IS INITIAL.
        IF NOT xztivtx01-ebeln IS INITIAL.
          SELECT *
            FROM konv UP TO 1 ROWS
           WHERE knumv  EQ  ekko-knumv
             AND kposn  EQ  xztivtx01-ebelp
*           AND zaehk  EQ  '01'
*             and STUNR
             AND kappl  EQ  'M'
             AND kschl  EQ  xztitig06-kschl.
          ENDSELECT.
          IF sy-subrc EQ 0.
            l_konv = 'X'.
*>
            CLEAR: l_lifnr.
            CALL FUNCTION 'ME_READ_COND_INVOICE'
              EXPORTING
                i_ebeln      = xztivtx01-ebeln
                i_ebelp      = xztivtx01-ebelp
                i_lifnr      = l_lifnr
              TABLES
                xek08bn_curr = t_ek08bn_temp.

            READ TABLE t_ek08bn_temp INTO ek08bn_temp
                                     WITH KEY kschl = xztitig06-kschl.
            IF sy-subrc NE 0.
*            MESSAGE E875 WITH xZTIslcit-ebeln xZTIslcit-ebelP
*                              xZTItig06-kschl
*                         RAISING distribution_error.
              CLEAR: konv.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    ADD 1 TO l_buzei.
    CLEAR: xztiscsdt.
    IF NOT ekpo-ebeln IS INITIAL.

      MOVE-CORRESPONDING ekpo TO xztiscsdt.

      SELECT SINGLE *
        FROM ekkn
       WHERE ebeln = ekpo-ebeln
       AND   ebelp = ekpo-ebelp
       AND   zekkn = '01'.
      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING ekkn TO xztiscsdt.
      ENDIF.

*>> WBS (작업분할구조) 요소 마스터 데이타.
      IF NOT xztiscsdt-ps_psp_pnr IS INITIAL.
        SELECT SINGLE posid
          INTO xztiscsdt-pspnr
          FROM prps
         WHERE pspnr = xztiscsdt-ps_psp_pnr.
      ENDIF.
    ENDIF.

    MOVE: xztitcsk-bukrs     TO xztiscsdt-bukrs,
          xztitcsk-icsno     TO xztiscsdt-icsno,
          l_buzei            TO xztiscsdt-buzei,
          xztiscsit-icssq    TO xztiscsdt-icssq,
          xztitcsk-expgr     TO xztiscsdt-expgr,
          xztiscsit-expcd    TO xztiscsdt-expcd,
          'S'                TO xztiscsdt-koart,
          ekko-knumv         TO xztiscsdt-knumv,
          konv-stunr         TO xztiscsdt-stunr,
          konv-zaehk         TO xztiscsdt-zaehk,
          konv-kschl         TO xztiscsdt-kschl,
          xztiscsit-mwskz    TO xztiscsdt-mwskz,
          xztivtx01-taxno    TO xztiscsdt-refno,
          xztivtx01-taxit    TO xztiscsdt-refit,
          xztivtx01-ebeln    TO xztiscsdt-ebeln,
          xztivtx01-ebelp    TO xztiscsdt-ebelp,
*          xztitig06-saknr    TO xztiscsdt-saknr,
          '40'               TO xztiscsdt-bschl,
          'S'                TO xztiscsdt-shkzg,
          xztitcsk-bupla     TO xztiscsdt-bupla,
*          xztitcsk-gsber     TO xztiscsdt-gsber,
*          xztiscsit-kostl    TO xztiscsdt-kostl,
*          xztiscsit-prctr    TO xztiscsdt-prctr,
*          xztiscsit-pspnr    TO xztiscsdt-pspnr,
          xztivtx01-txrno    TO xztiscsdt-zuonr,
          xztitig06-exptx    TO xztiscsdt-sgtxt,
          xztivtx01-gjahrd   TO xztiscsdt-mjahr,
          xztivtx01-belnrd   TO xztiscsdt-mblnr,
          xztivtx01-buzeid   TO xztiscsdt-mblpo,
          sy-uname           TO xztiscsdt-cnam,
          sy-datlo           TO xztiscsdt-cdat,
          sy-timlo           TO xztiscsdt-ctme,
          sy-uname           TO xztiscsdt-unam,
          sy-datlo           TO xztiscsdt-udat,
          sy-timlo           TO xztiscsdt-utme.

*> 구매오더상에 계정결정이 되지 않았을 경우,
    IF xztiscsdt-saknr IS INITIAL.
      MOVE xztitig06-saknr    TO xztiscsdt-saknr.
    ENDIF.
    IF xztiscsdt-kostl IS INITIAL.
      MOVE xztiscsit-kostl    TO xztiscsdt-kostl.
    ENDIF.
    IF xztiscsdt-prctr IS INITIAL.
      MOVE xztiscsit-prctr    TO xztiscsdt-prctr.
    ENDIF.

*> 사업영역 결정(플랜트+디비젼).
    IF xztiscsdt-gsber IS INITIAL AND
       NOT xztiscsdt-matnr IS INITIAL.
      SELECT SINGLE gsber
        INTO xztiscsdt-gsber
        FROM t134g
       WHERE werks EQ xztiscsdt-werks
         AND spart EQ ( SELECT spart
                          FROM mara
                         WHERE matnr EQ xztiscsdt-matnr ).
    ENDIF.

*
*    IF NOT xztiVtx01-ebeln IS INITIAL.
*      MOVE: ekpo-menge       TO xztiscsdt-menge,
*            ekpo-meins       TO xztiscsdt-meins,
*            ekpo-bprme       TO xztiscsdt-bprme,
*            ekpo-peinh       TO xztiscsdt-peinh.
**> 해당문서별 배부원칙일 경우.
*      IF ztitig00-dstbt EQ 'D'.
*        MOVE: xztistxit-txmng TO xztiscsdt-menge.
*      ENDIF.
*    ELSE.
*      MOVE: xztistxit-txmngD  TO xztiscsdt-menge,
*            xztistxit-meinsD  TO xztiscsdt-meins,
*            xztistxit-meinsD  TO xztiscsdt-bprme,
*            1                 TO xztiscsdt-peinh.
*    ENDIF.

    MOVE: xztivtx01-txmngd  TO xztiscsdt-menge,
          xztivtx01-meinsd  TO xztiscsdt-meins,
          xztivtx01-meinsd  TO xztiscsdt-bprme,
          1                 TO xztiscsdt-peinh,
          xztivtx01-txamtsd TO xztiscsdt-wrbtr.

*    IF p_netwr IS INITIAL.
*      l_rate =  1.
*    ELSE.
*      l_rate =  xztistxit-refwr / p_netwr.
*    ENDIF.
*
**    xZTIscsdt-wrbtr = xZTIscsit-wrbtr * l_rate.
**    xZTIscsdt-dmbtr = xZTIscsit-dmbtr * l_rate.
**    xZTIscsdt-wmwst = xZTIscsit-wmwst * l_rate.
**    xZTIscsdt-fwbas = xZTIscsit-fwbas * l_rate.
**
*    xztiscsdt-wrbtr =
*       ( TRUNC( ( xztiscsit-wrbtr * l_rate ) * 100 ) ) / 100.
*
*    xztiscsdt-dmbtr =
*       ( TRUNC( ( xztiscsit-dmbtr * l_rate ) * 100 ) ) / 100.
*
*    xztiscsdt-wmwst =
*       ( TRUNC( ( xztiscsit-wmwst * l_rate ) * 100 ) ) / 100.
*
*    xztiscsdt-fwbas =
*       ( TRUNC( ( xztiscsit-fwbas * l_rate ) * 100 ) ) / 100.

*>구매오더 이력 수량을 계산하여 송장처리 수량 조정.
    PERFORM calc_po_history_qty TABLES xztiscsdt
                                USING  xztiscsdt-ebeln
                                       xztiscsdt-ebelp
                                       ekpo
                                       xztitcsk
                                       xztiscsdt-menge
                                       xztiscsit-cscty.

**> 가장 큰 항목을 찾기 위해.
*    DESCRIBE TABLE xztiscsdt LINES l_tabix.
*    READ TABLE xztiscsdt INDEX l_tabix.
*
*    IF l_wrbtr_max LT xztiscsdt-wrbtr.
*      l_wrbtr_max = xztiscsdt-wrbtr.
*      l_tabix_max = l_tabix.
*    ENDIF.

    ADD: xztiscsdt-wrbtr TO g_wrbtr1,
         xztiscsdt-dmbtr TO g_dmbtr1,
         xztiscsdt-wmwst TO g_wmwst1,
         xztiscsdt-fwbas TO g_fwbas1.
  ENDLOOP.

*  IF l_tabix_max IS INITIAL.
*    DESCRIBE TABLE xztiscsdt LINES g_line.
*    READ TABLE xztiscsdt INDEX g_line.
*  ELSE.
*    READ TABLE xztiscsdt INDEX l_tabix_max.
*  ENDIF.
*  g_tabix = sy-tabix.
**> ITEM 보정 작업.
*  IF sy-subrc EQ 0.
**> 문서상 금액.
*    IF xztiscsit-wrbtr GT g_wrbtr1.
*      xztiscsdt-wrbtr = xztiscsdt-wrbtr +
*                       ( xztiscsit-wrbtr - g_wrbtr1 ).
*    ELSEIF xztiscsit-wrbtr LT g_wrbtr1.
*      xztiscsdt-wrbtr = xztiscsdt-wrbtr -
*                       ( g_wrbtr1 - xztiscsit-wrbtr ).
*    ENDIF.
*
**> 현지통화.
*    IF xztiscsit-dmbtr GT g_dmbtr1.
*      xztiscsdt-dmbtr = xztiscsdt-dmbtr +
*                       ( xztiscsit-dmbtr - g_dmbtr1 ).
*    ELSEIF xztiscsit-dmbtr LT g_dmbtr1.
*      xztiscsdt-dmbtr = xztiscsdt-dmbtr -
*                       ( g_dmbtr1 - xztiscsit-dmbtr ).
*    ENDIF.
**> 세액.
*    IF xztiscsit-wmwst GT g_wmwst1.
*      xztiscsdt-wmwst = xztiscsdt-wmwst +
*                       ( xztiscsit-wmwst - g_wmwst1 ).
*    ELSEIF xztiscsit-wmwst LT g_wmwst1.
*      xztiscsdt-wmwst = xztiscsdt-wmwst -
*                       ( g_wmwst1 - xztiscsit-wmwst ).
*    ENDIF.
*
**> 표준액.
*    IF xztiscsit-fwbas GT g_fwbas1.
*      xztiscsdt-fwbas = xztiscsdt-fwbas +
*                       ( xztiscsit-fwbas - g_fwbas1 ).
*    ELSEIF xztiscsit-fwbas LT g_fwbas1.
*      xztiscsdt-fwbas = xztiscsdt-fwbas -
*                       ( g_fwbas1 - xztiscsit-fwbas ).
*    ENDIF.
*
*    MODIFY xztiscsdt INDEX g_tabix.
*  ENDIF.
*
ENDFORM.                    " build_invoice_items_by_tx1
*&---------------------------------------------------------------------*
*&      Form  BUILD_AP_LINE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_ap_line_data      TABLES   xztiscsdt STRUCTURE ztiscsdt
                                      xztiscsit STRUCTURE ztiscsit
                             USING    xztitcsk  STRUCTURE ztitcsk
                                      xexpgr.

  DATA: l_buzei  LIKE xztiscsdt-buzei.

*  REFRESH: xztiscsdt.

*  xztitcsk-ptdcl = 'F'.

  READ TABLE xztiscsit INDEX 1.


*> AP 금액.
  CLEAR: xztiscsdt, l_buzei.
  MOVE: l_buzei         TO xztiscsdt-buzei,
        '31'            TO xztiscsdt-bschl,
        xexpgr          TO xztiscsdt-expgr,
        'K'             TO xztiscsdt-koart,
        xztitcsk-mwskz  TO xztiscsdt-mwskz,
        'H'             TO xztiscsdt-shkzg,
        xztitcsk-akont  TO xztiscsdt-saknr,
        xztitcsk-wrbtr  TO xztiscsdt-wrbtr,
*        xZTITCSK-wmwst TO xZTIscsdt-wmwst,
*        xZTITCSK-dmbtr TO xZTIscsdt-dmbtr,
*        xZTITCSK-fwbas TO xZTIscsdt-fwbas,
        xztiscsit-kostl TO xztiscsdt-kostl,
        xztiscsit-prctr TO xztiscsdt-prctr,
        xztiscsit-pspnr TO xztiscsdt-pspnr,
        xztitcsk-bupla  TO xztiscsdt-bupla,
        xztitcsk-gsber  TO xztiscsdt-gsber,
        xztitcsk-sgtxt  TO xztiscsdt-sgtxt,
        xztitcsk-zuonr  TO xztiscsdt-zuonr,
        'P'             TO xztiscsdt-itmst,
        sy-uname        TO xztiscsdt-cnam,
        sy-datlo        TO xztiscsdt-cdat,
        sy-timlo        TO xztiscsdt-ctme,
        sy-uname        TO xztiscsdt-unam,
        sy-datlo        TO xztiscsdt-udat,
        sy-timlo        TO xztiscsdt-utme.

  APPEND xztiscsdt.

ENDFORM.                    " BUILD_AP_LINE_DATA
