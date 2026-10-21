************************************************************************
* Title         :  ZTIR3000O01                                         *
*                                                                      *
* Description   : 수입 I/V 관리 PBO Include                            *
*                                                                      *
* Creation Date : 2003/08/12                                           *
*                                                                      *
* Author        : Seung Jun, Lee                                       *
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

  MOVE-CORRESPONDING g_tc_2130_wa TO ztisivit.

ENDMODULE.                 " tc_2130_move  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_get_lines  OUTPUT
*&---------------------------------------------------------------------*
MODULE tc_2130_get_lines OUTPUT.

*  g_tc_2130_lines = sy-loopc.
  DESCRIBE TABLE it_tab  LINES g_line.                  " LINE COUNT GET
  g_tc_2130_lines = g_line.                             " LINE DEFINE
  tc_2130-lines   = g_line.
  g_old_top_line  = tc_2130-top_line.

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
    IF screen-name    EQ 'ZTISIVIT-REMNG' AND
       ztitivk-prpyn EQ c_charp.
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
    IF ztitivk-prpyn NE c_chari.
      CASE screen-name.
        WHEN 'ZTITBLK-EBELN' OR 'ZTITBLK-BLCNT'.
          screen-input      =   c_char0.
          screen-invisible  =   c_char1.
************************************************************
* 2008.07.08  simcho by 박혁세K
* 수입 마이그레이션을 위한 임시 수정
************************************************************
        WHEN 'ZTITIVK-LIFNR'.
          screen-input      =   c_char0.
          screen-invisible  =   c_char1.
************************************************************
      ENDCASE.
    ELSE.
      CASE screen-name.
************************************************************
* 2008.07.08  simcho by 박혁세K
* 수입 마이그레이션을 위한 임시 수정
************************************************************
        WHEN 'ZTITIVK-LIFNR'.
          screen-input      =   c_char1.
          screen-invisible  =   c_char0.
************************************************************
      ENDCASE.

    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

  LOOP AT SCREEN. "엠트론 한정 조회필드
  IF SCREEN-NAME EQ 'GF_POST_DIV' .
    IF ZTITIVK-BUKRS NE '3000'.
      SCREEN-INPUT      =   C_CHAR0.
      SCREEN-INVISIBLE  =   C_CHAR1.
      MODIFY SCREEN.
    ELSEIF  ( SY-UNAME NE 'C526812' AND "엠트론 사용자 한정
              SY-UNAME NE 'C526806' AND
              SY-UNAME NE 'C526811' AND
              SY-UNAME(4) NE 'ZLSG'  ).
      SCREEN-INPUT      =   C_CHAR0.
      SCREEN-INVISIBLE  =   C_CHAR1.
      MODIFY SCREEN.
    ENDIF.
  ENDIF.
ENDLOOP.


ENDMODULE.                 " change_field_visible_mode  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2120_set_tabstrip  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_scr2120_set_tabstrip OUTPUT.

  LOOP AT SCREEN.
    IF screen-name EQ 'TABSTRIP_TAB3'.  ">분할금액
      IF NOT ztitivk-rtchg IS INITIAL.
        screen-input      =  c_char1.
        screen-invisible  =  c_char0.
        MODIFY SCREEN.
      ELSE.
        screen-input      =  c_char0.
        screen-invisible  =  c_char1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
    IF screen-name EQ 'TABSTRIP_TAB4'.   ">전기이력.
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
*&      Module  PBO_SCR2124_SET_GRID  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_scr2124_set_grid OUTPUT.

  IF g_scr2124_container IS INITIAL.
*> FIELD CATALLOG BUILD
    PERFORM scr2124_fieldcat_build.

* create a custom container control for our ALV Control
    CREATE OBJECT g_scr2124_container
        EXPORTING
            container_name = 'SCR2124_CONTAINER'.

* create an instance of alv control
    CREATE OBJECT g_scr2124_grid
           EXPORTING i_parent = g_scr2124_container.
*
*> Set grid handler
*-. Event Receive.
    CREATE OBJECT event_receiver.

* Edit  이벤트 등록
    SET HANDLER :
        event_receiver->handle_double_click          FOR g_scr2124_grid,
        event_receiver->handle_hotspot_click         FOR g_scr2124_grid.

    CALL METHOD g_scr2124_grid->set_table_for_first_display
      EXPORTING
        i_structure_name = 'ZTISIVHS'
        i_save           = g_variant_save
        is_variant       = g_variant
        i_default        = 'X'
      CHANGING
        it_fieldcatalog  = it_fieldcat_lvc[]
        it_outtab        = it_ztitivh[].
  ENDIF.

ENDMODULE.                 " PBO_SCR2124_SET_GRID  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2123_init  OUTPUT
*&---------------------------------------------------------------------*
*&> output module for tc 'TC_2123'. do not change this line!
*&> copy ddic-table to itab
*&---------------------------------------------------------------------*
MODULE tc_2123_init OUTPUT.
  IF g_tc_2123_copied IS INITIAL.
    g_tc_2123_copied = 'X'.
    REFRESH CONTROL 'TC_2123' FROM SCREEN '2123'.
  ENDIF.
ENDMODULE.                    "tc_2123_init OUTPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2123_move  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2123'. do not change this line!
*> move itab to dynpro
*&---------------------------------------------------------------------*
MODULE tc_2123_move OUTPUT.
  MOVE-CORRESPONDING g_tc_2123_wa TO ztisivvs.
ENDMODULE.                    "TC_2123_move OUTPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2123_get_lines  OUTPUT
*&---------------------------------------------------------------------*
*&> output module for tc 'TC_2123'. do not change this line!
*&> get lines of tablecontrol
*&---------------------------------------------------------------------*
MODULE tc_2123_get_lines OUTPUT.
  g_tc_2123_lines = sy-loopc.
ENDMODULE.                    "TC_2123_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2123_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_2123_change_field_attr OUTPUT.

  LOOP AT SCREEN.
    IF g_tc_2123_wa-split EQ 1 AND
       screen-name        NE 'ZTISIVVS-FLAG'.
      screen-input = c_char0.
      MODIFY SCREEN.
    ELSE.
      CLEAR g_fieldgroup.
      CONCATENATE screen-group1 screen-group2
                  screen-group3 screen-group4
             INTO g_fieldgroup.

      SEARCH g_fieldgroup FOR g_mode.
      IF sy-subrc <> 0.
        screen-input = c_char0.
      ELSE.
        screen-input = c_char1.
      ENDIF.
      IF screen-name EQ 'ZTISIVVS-FLAG'.
        screen-input = c_char1.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " TC_2123_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_scr7000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_scr7000 OUTPUT.

  SET PF-STATUS 'LIST'.
  SET TITLEBAR  'T7000'.

  CLEAR:  ok_code_popup.

ENDMODULE.                 " STATUS_scr7000  OUTPUT
