************************************************************************
* Title         :  ZTIR8000O01                                         *
*                                                                      *
* Description   : 수입 Notice 관리 PBO Include                         *
*                                                                      *
* Creation Date : 2004/02/12                                           *
*                                                                      *
* Author        : Seog bong, Kang                                      *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* dd-mmm-yyyy  xxxxxxxxxxxxxxx  DVPK9xxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  *
*                                                                      *
*                                                                      *
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Module  tc_2130_init  OUTPUT
*&---------------------------------------------------------------------*
MODULE tc_2130_init OUTPUT.

  IF g_tc_2130_copied IS INITIAL.

    g_tc_2130_copied = 'X'.
    REFRESH CONTROL 'TC_2130' FROM SCREEN '2130'.
  ENDIF.

ENDMODULE.                 " tc_2130_init  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_move  OUTPUT
*&---------------------------------------------------------------------*
MODULE tc_2130_move OUTPUT.
  MOVE-CORRESPONDING g_tc_2130_wa TO ztispnit.
ENDMODULE.                 " tc_2130_move  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_get_lines  OUTPUT
*&---------------------------------------------------------------------*
MODULE tc_2130_get_lines OUTPUT.

*  g_tc_2130_lines = sy-loopc.
  DESCRIBE TABLE it_tab  LINES g_line.                  " LINE COUNT GET
  g_tc_2130_lines = g_line.                             " LINE DEFINE
  tc_2130-lines = g_line.

ENDMODULE.                 " tc_2130_get_lines  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
MODULE tc_2130_change_field_attr OUTPUT.

  LOOP AT SCREEN.
*> 생성/변경 모드가 아닐 경우.
    IF NOT ( g_mode EQ c_charc OR
             g_mode EQ c_charm ) AND
       NOT ( screen-name EQ 'G_TC_2130_WA-FLAG' ).
      screen-input = c_char0.
    ENDIF.

    IF ztitrqs-setyn EQ c_true AND   ">정산여부 = 'Y'.
       NOT ( screen-name EQ 'G_TC_2130_WA-FLAG' ).
      screen-input = c_char0.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " tc_2130_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2130_CHANGE_COL_ATTR  OUTPUT
*&---------------------------------------------------------------------*
*       Column Invisibe/Visible
*----------------------------------------------------------------------*
MODULE tc_2130_change_col_attr OUTPUT.

  LOOP AT tc_2130-cols INTO gs_cols.
    g_tabix = sy-tabix.
*    CASE  gs_cols-screen-name.
*      WHEN 'ZTISRQIT-MJAHR' OR 'ZTISRQIT-MBLNR' OR 'ZTISRQIT-ZEILE'.
*        IF ZTITRQS-setyn EQ c_false.   ">정산여부 = 'n'.
*          gs_cols-invisible = c_char1.
*          MODIFY tc_2130-cols  INDEX g_tabix FROM gs_cols.
*        ENDIF.
*      WHEN 'ZTISRQIT-EBELN' OR 'ZTISRQIT-EBELP'.
*        IF ZTITRQS-setyn EQ c_true.   ">정산여부 = 'y'
*          gs_cols-invisible = c_char0.
*          MODIFY tc_2130-cols  INDEX g_tabix FROM gs_cols.
*        ENDIF.
*    ENDCASE.
  ENDLOOP.

ENDMODULE.                 " TC_2130_CHANGE_COL_ATTR  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  change_field_visible_mode  OUTPUT
*&---------------------------------------------------------------------*
*       업무별로 화면상에 필드를 visible/Invisible 함.
*----------------------------------------------------------------------*
MODULE change_field_visible_mode OUTPUT.

  LOOP AT SCREEN.
    CASE ztivrq04-reqty.
      WHEN c_lc.
        IF ztivrq04-ilcty EQ 'U'.
          CASE screen-name.
            WHEN 'ZTITPNK-STLDT' OR 'ZTITPNK-NGODT'.
              screen-input     = c_char0.
              screen-invisible = c_char1.
            WHEN OTHERS.
*              screen-invisible = c_char0.
          ENDCASE.
          IF ztitrqs-umtcu EQ c_false AND
             screen-name    EQ 'ZTITPNK-WAERS'.
            screen-input     = c_char0.
          ENDIF.
        ELSE.
          CASE screen-name.
            WHEN 'ZTITPNK-PROCP' OR 'ZTITPNK-BGNDT' OR
                 'ZTITPNK-EXPDT' OR
                 'ZTITPNK-NDAYS' OR 'ZTITPNK-TSATZ' OR
                 'ZTITPNK-BNRAT' OR 'ZTITRQS-UMTCU' OR
                 'ZTITPNK-NGODT'.
              screen-input     = c_char0.
              screen-invisible = c_char1.
            WHEN OTHERS.
*              screen-invisible = c_char0.
          ENDCASE.
        ENDIF.

      WHEN c_lo.
        CASE screen-name.
          WHEN 'ZTITPNK-PROCP' OR 'ZTITPNK-BGNDT' OR
               'ZTITPNK-EXPDT' OR 'ZTITPNK-PNTDT' OR
               'ZTITPNK-NDAYS' OR 'ZTITPNK-TSATZ' OR
               'ZTITPNK-BNRAT' OR 'ZTITRQS-UMTCU'.
            screen-input     = c_char0.
            screen-invisible = c_char1.
          WHEN OTHERS.
*            screen-invisible = c_char0.
        ENDCASE.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " change_field_visible_mode  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_status_6010  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_status_6010 OUTPUT.

  SET PF-STATUS '6010'.
  SET TITLEBAR  'T6010'.

ENDMODULE.                 " pbo_status_6010  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2123_set_grid  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_scr2123_set_grid OUTPUT.

  IF g_scr2123_container IS INITIAL.
*> FIELD CATALLOG BUILD
    PERFORM scr2123_fieldcat_build.

* create a custom container control for our ALV Control
    CREATE OBJECT g_scr2123_container
        EXPORTING
            container_name = 'SCR2123_CONTAINER'.

* create an instance of alv control
    CREATE OBJECT g_scr2123_grid
           EXPORTING i_parent = g_scr2123_container.
*> Set grid handler
*-. Event Receive.
    CREATE OBJECT event_receiver.

* Edit  이벤트 등록
    SET HANDLER :
        event_receiver->handle_double_click          FOR g_scr2123_grid,
        event_receiver->handle_hotspot_click         FOR g_scr2123_grid.
*
    CALL METHOD g_scr2123_grid->set_table_for_first_display
      EXPORTING
        i_structure_name = 'ZTISPNHS'
        i_save           = g_variant_save
        is_variant       = g_variant
        i_default        = 'X'
      CHANGING
        it_fieldcatalog  = it_fieldcat_lvc[]
        it_outtab        = it_ztispnhs[].
  ENDIF.

ENDMODULE.                 " pbo_scr2123_set_grid  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2120_set_tabstrip  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_scr2120_set_tabstrip OUTPUT.

  LOOP AT SCREEN.
    IF screen-name EQ 'TABSTRIP_TAB3'.
      IF g_history_post EQ c_true.
        screen-input      =  c_char1.
        screen-invisible  =  c_char0.
        MODIFY SCREEN.
      ELSE.
        screen-input      =  c_char0.
        screen-invisible  =  c_char1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " pbo_scr2120_set_tabstrip  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr0100_Import_memory  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_scr0100_import_memory OUTPUT.

  IF sy-calld EQ c_true .
    IF sy-tcode NE c_create.
      g_tcode = sy-tcode.
    ENDIF.
*    BREAK-POINT.
    CASE g_tcode.
      WHEN 'ZTIR801'.  ">내국신용장 Notice Due List.
        IF it_ztisrqit[] IS INITIAL.
          MESSAGE a003(ok).
        ENDIF.
        g_tcode1 = g_tcode.
*        g_tcode1 = c_due_list_lo.
        g_tcode  = c_create.
        g_mode   = c_charc.
      WHEN 'ZTIR804'.  ">유보금 Notice Due List.
        IF it_ztisrqit[] IS INITIAL.
          MESSAGE a003(ok).
        ENDIF.
        g_tcode1 = g_tcode.
        g_tcode  = c_create.
        g_mode   = c_charc.
        ztitpnk-rpaid = c_true.
    ENDCASE.
  ELSE.
    g_tcode = sy-tcode.
  ENDIF.

ENDMODULE.                 " pbo_scr0100_Import_memory  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_status_6020  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_status_6020 OUTPUT.

  SET PF-STATUS '6010'.
  SET TITLEBAR  'T6020'.

ENDMODULE.                 " pbo_status_6020  OUTPUT
