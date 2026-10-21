*&---------------------------------------------------------------------*
*&  Include           LZ_TI_COMMON_FUNCTIONSO01                        *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  TC_0100_CHANGE_TC_ATTR  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_0100'. do not change this line!
*> update lines for equivalent scrollbar
*----------------------------------------------------------------------*
MODULE tc_0100_change_tc_attr OUTPUT.
  DESCRIBE TABLE xprtctl LINES tc_0100-lines.
ENDMODULE.                    "TC_0100_change_tc_attr OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TC_0100_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_0100'. do not change this line!
*> get lines of tablecontrol
*----------------------------------------------------------------------*
MODULE tc_0100_get_lines OUTPUT.
  g_tc_0100_lines = sy-loopc.
ENDMODULE.                    "TC_0100_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS 'LIST'.
  SET TITLEBAR 'T0100'.

ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TC_0200_CHANGE_TC_ATTR  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_0200'. do not change this line!
*> update lines for equivalent scrollbar
*----------------------------------------------------------------------*
MODULE tc_0200_change_tc_attr OUTPUT.

  DESCRIBE TABLE it_pokey LINES tc_0200-lines.

  tc_0200-lines = tc_0200-lines + 10.

ENDMODULE.                    "TC_0200_change_tc_attr OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  SET PF-STATUS 'LIST2'.
  SET TITLEBAR  'T0200'.

  CLEAR:  ok_code.

ENDMODULE.                 " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TC_0300_INIT  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_0300'. do not change this line!
*> copy ddic-table to itab
*----------------------------------------------------------------------*
MODULE tc_0300_init OUTPUT.
  IF g_tc_0300_copied IS INITIAL.
*> copy ddic-table 'ZTITLC2'
*> into internal table 'g_TC_0300_itab'
*    select * from ZTITLC2
*       into corresponding fields
*       of table g_TC_0300_itab.
    g_tc_0300_copied = 'X'.
    REFRESH CONTROL 'TC_0300' FROM SCREEN '0300'.
  ENDIF.
ENDMODULE.                    "TC_0300_init OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TC_0300_MOVE  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_0300'. do not change this line!
*> move itab to dynpro
*----------------------------------------------------------------------*
MODULE tc_0300_move OUTPUT.

  MOVE-CORRESPONDING g_tc_0300_wa TO ztitlc2.

ENDMODULE.                    "TC_0300_move OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TC_0300_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_0300'. do not change this line!
*> get lines of tablecontrol
*----------------------------------------------------------------------*
MODULE tc_0300_get_lines OUTPUT.

*  DESCRIBE TABLE g_tc_0300_itab LINES g_line.
*  g_tc_0300_lines = g_line + 2.
*
  g_tc_0300_lines = sy-loopc.

ENDMODULE.                    "TC_0300_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_0300_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_0300_change_field_attr OUTPUT.

  LOOP AT SCREEN.
    IF g_mode EQ 'D' OR
       g_mode EQ 'S'.
      screen-input = '0'.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " TC_0300_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_0300_change_col_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_0300_change_col_attr OUTPUT.

  LOOP AT SCREEN.
    IF g_mode EQ 'D' OR
       g_mode EQ 'S'.
      IF screen-group1 EQ 'MOD'.
        screen-input = '0'.
      ENDIF.
    ENDIF.
    IF g_button       EQ 'N' AND
       screen-name(8) EQ 'TC_0300_'.
      screen-input     = '0'.
      screen-invisible = '1'.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " TC_0300_change_col_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_cursor_position  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_position OUTPUT.

  CHECK NOT g_findscr IS INITIAL.

  CHECK g_findscr EQ sy-dynnr.

  IF g_findline IS INITIAL.
    SET CURSOR FIELD g_fieldname.
  ELSE.
    SET CURSOR FIELD g_fieldname LINE g_findline.
  ENDIF.

ENDMODULE.                 " SET_cursor_position  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_tree_scr2128  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_tree_scr2128 OUTPUT.
*>
  PERFORM pbo_document_history_tree.

ENDMODULE.                 " pbo_tree_scr2128  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SCR2127_SET_GRID  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_scr2127_set_grid OUTPUT.

  IF g_scr2127_container IS INITIAL.
* create a custom container control for our ALV Control
    CREATE OBJECT g_scr2127_container
        EXPORTING
            container_name = 'SCR2127_CONTAINER'.

* create an instance of alv control
    CREATE OBJECT g_scr2127_grid
           EXPORTING i_parent = g_scr2127_container.
*
*-. Event Receive.
    CREATE OBJECT event_receiver.

    SET HANDLER :
        event_receiver->handle_double_click          FOR g_scr2127_grid,
        event_receiver->handle_hotspot_click         FOR g_scr2127_grid.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = 'ZTISCOSTDOC'
        i_client_never_display = 'X'
      CHANGING
        ct_fieldcat            = it_fieldcat_lvc[].

    LOOP AT it_fieldcat_lvc.
      CASE it_fieldcat_lvc-fieldname.
        WHEN 'EXPCD'.
          it_fieldcat_lvc-key  = 'X'.
          it_fieldcat_lvc-outputlen = 4.
        WHEN 'EXPTX'.
          it_fieldcat_lvc-key  = 'X'.
          it_fieldcat_lvc-outputlen = 14.
        WHEN 'LIFNR'.
          it_fieldcat_lvc-outputlen = 6.
        WHEN 'NAME1'.
          it_fieldcat_lvc-outputlen = 10.
        WHEN 'WRBTR'.
          it_fieldcat_lvc-do_sum = 'X'.
        WHEN 'WAERS'.
        WHEN 'ICSNO'.
          it_fieldcat_lvc-hotspot  = 'X'.
        WHEN 'ICSSQ'.
          it_fieldcat_lvc-hotspot  = 'X'.
        WHEN 'BELNR'.
          it_fieldcat_lvc-hotspot  = 'X'.
        WHEN 'VORGANG'.
        WHEN 'CSTYP'.
        WHEN 'LIVST'.
        WHEN 'MWSKZ'.
          it_fieldcat_lvc-outputlen = 2.
        WHEN 'REFNO' OR 'AMDSQ'.
          it_fieldcat_lvc-hotspot  = 'X'.
          it_fieldcat_lvc-no_out = 'X'.
        WHEN OTHERS.
          it_fieldcat_lvc-no_out = 'X'.
      ENDCASE.
      MODIFY it_fieldcat_lvc.
    ENDLOOP.

*    g_layout-CWIDTH_OPT = 'X'.
    g_layout-zebra        = 'X'.

    CALL METHOD g_scr2127_grid->set_table_for_first_display
      EXPORTING
*        i_structure_name = 'ZTISCSHS'
        is_layout        = g_layout
        is_variant       = g_variant
        is_print         = g_print
        i_save           = 'A'   " 전체가능유형.
      CHANGING
        it_fieldcatalog  = it_fieldcat_lvc[]
        it_outtab        = it_costdoc[].
  ELSE.
    CALL METHOD g_scr2127_grid->get_frontend_layout
      IMPORTING
        es_layout = g_layout.

    CALL METHOD cl_gui_cfw=>flush.
*
    CALL METHOD g_scr2127_grid->set_frontend_fieldcatalog
      EXPORTING
        it_fieldcatalog = it_fieldcat_lvc[].

    CALL METHOD g_scr2127_grid->set_frontend_layout
      EXPORTING
        is_layout = g_layout.

    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    CALL METHOD g_scr2127_grid->refresh_table_display
      EXPORTING
        is_stable = gs_stable.

  ENDIF.

ENDMODULE.                 " PBO_SCR2127_SET_GRID  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_0210_change_tc_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_0210_change_tc_attr OUTPUT.

  DESCRIBE TABLE it_pokey LINES tc_0210-lines.

  tc_0210-lines = tc_0210-lines + 10.


ENDMODULE.                 " TC_0210_change_tc_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_0500  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0500 OUTPUT.

  SET PF-STATUS 'LIST'.
  SET TITLEBAR 'T0500'.

ENDMODULE.                 " status_0500  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_status_8000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_status_8000 OUTPUT.

  REFRESH excl.

  IF NOT ( g_mode EQ 'C' OR
           g_mode EQ 'M' ).
    MOVE 'ZTIOKAY' TO excl-funktion.     APPEND excl.
  ENDIF.

  SET PF-STATUS '8000' EXCLUDING excl.
  SET TITLEBAR  'T8000'.

ENDMODULE.                 " pbo_status_8000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  change_field_attribute  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_field_attribute OUTPUT.

  LOOP AT  SCREEN .
    CLEAR g_fieldgroup.
    CONCATENATE screen-group1 screen-group2
                screen-group3 screen-group4
           INTO g_fieldgroup.

    SEARCH g_fieldgroup FOR g_mode.
    IF sy-subrc <> 0.
      screen-input = '0'.
    ELSE.
      screen-input = '1'.
    ENDIF.
*    IF screen-name EQ 'G_TC_2130_WA-FLAG' OR
*       screen-name EQ 'ZTISIVVS-FLAG'.
*      screen-input = '1'.
*    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " change_field_attribute  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr0600_set_grid  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_scr0600_set_grid OUTPUT.

  SET PF-STATUS '0600'.
  SET TITLEBAR  'T0600'.

  IF g_scr0600_container IS INITIAL.
* create a custom container control for our ALV Control
    CREATE OBJECT g_scr0600_container
        EXPORTING
            container_name = 'SCR0600_CONTAINER'.

* create an instance of alv control
    CREATE OBJECT g_scr0600_grid
           EXPORTING i_parent = g_scr0600_container.
*
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = 'ZTISAMENDFID'
        i_client_never_display = 'X'
      CHANGING
        ct_fieldcat            = it_fieldcat_lvc[].

    LOOP AT it_fieldcat_lvc.
      CASE it_fieldcat_lvc-fieldname.
        WHEN 'TABNAME' OR 'FIELDNAME' OR 'OUTLEN'.
          it_fieldcat_lvc-no_out = 'X'.
        WHEN 'SCRTEXT_M'.
          it_fieldcat_lvc-key  = 'X'.
          it_fieldcat_lvc-outputlen = 20.
          it_fieldcat_lvc-scrtext_l = '변경항목'.
          it_fieldcat_lvc-scrtext_m = '변경항목'.
          it_fieldcat_lvc-scrtext_s = '변경항목'.
        WHEN 'F_OLD' OR 'F_NEW'.
          it_fieldcat_lvc-outputlen = 40.
        WHEN OTHERS.
          it_fieldcat_lvc-no_out = 'X'.
      ENDCASE.
      MODIFY it_fieldcat_lvc.
    ENDLOOP.

*    g_layout-CWIDTH_OPT = 'X'.
    g_layout-zebra        = 'X'.

    CALL METHOD g_scr0600_grid->set_table_for_first_display
      EXPORTING
*        i_structure_name = 'ZTISCSHS'
        is_layout        = g_layout
        is_variant       = g_variant
        is_print         = g_print
        i_save           = 'A'   " 전체가능유형.
      CHANGING
        it_fieldcatalog  = it_fieldcat_lvc[]
        it_outtab        = it_amendfield[].
  ELSE.
**> FIELD CATALLOG BUILD
*    PERFORM scr7000_fieldcat_build.
*
**    CALL METHOD g_scr7000_grid->get_frontend_fieldcatalog
**      IMPORTING
**        et_fieldcatalog = it_fieldcat_lvc_1[].
**
    CALL METHOD g_scr0600_grid->get_frontend_layout
      IMPORTING
        es_layout = g_layout.

    CALL METHOD cl_gui_cfw=>flush.
*
    CALL METHOD g_scr0600_grid->set_frontend_fieldcatalog
      EXPORTING
        it_fieldcatalog = it_fieldcat_lvc[].

    CALL METHOD g_scr0600_grid->set_frontend_layout
      EXPORTING
        is_layout = g_layout.

    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    CALL METHOD g_scr0600_grid->refresh_table_display
      EXPORTING
        is_stable = gs_stable.

  ENDIF.

  CLEAR: ok-code.

ENDMODULE.                 " pbo_scr0600_set_grid  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0700  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0700 OUTPUT.

  SET PF-STATUS 'LIST'.
  SET TITLEBAR  'T0700'.

ENDMODULE.                 " STATUS_0700  OUTPUT
