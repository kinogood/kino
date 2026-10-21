************************************************************************
* Title         : ZTIR7200O01                                          *
*                                                                      *
* Description   : 수입 인수증 관리 PBO Include                         *
*                                                                      *
* Creation Date : 2004/02/11                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
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

  MOVE-CORRESPONDING g_tc_2130_wa TO ztisacit.

*>by YSH(050826)
  SELECT SINGLE waers
    INTO ztitblk-waers
    FROM ztitrqs
*   WHERE ebeln EQ g_tc_2130_wa-ebeln.
*  복수PO로 수입개설시 대표PO가 아닌 경우 통화를 불러올 수 없어서 수정
   WHERE reqno EQ g_tc_2130_wa-reqno.  "Q20120402_79301

*>by YSH(050826)
  SELECT SINGLE waers
    INTO ztitblk-waers
    FROM ztitrqs
   WHERE ebeln EQ g_tc_2130_wa-ebeln.

* 2011/05/01 오민석C긴급 요청 - 단순문의 1079676
* 2011/07/29 인경식S긴급 요청 - 단순문의 1162323
  IF sy-subrc <> 0
  AND g_tc_2130_wa-ebeln = '4501267696'.
    ztitblk-waers = 'KRW'.
  ENDIF.

  IF sy-subrc <> 0
  AND g_tc_2130_wa-ebeln = '4501353297'.
    ztitblk-waers = 'KRW'.
  ENDIF.
*

ENDMODULE.                 " tc_2130_move  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_get_lines  OUTPUT
*&---------------------------------------------------------------------*
MODULE tc_2130_get_lines OUTPUT.

*  g_tc_2130_lines = sy-loopc.
  DESCRIBE TABLE it_tab  LINES g_line.              " LINE COUNT GET
  g_tc_2130_lines = g_line.                         " LINE DEFINE
  tc_2130-lines = g_line.

ENDMODULE.                 " tc_2130_get_lines  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
MODULE tc_2130_change_field_attr OUTPUT.

  LOOP AT SCREEN.
    CLEAR g_fieldgroup.
    CONCATENATE screen-group1 screen-group2
                screen-group3 screen-group4
           INTO g_fieldgroup.

*> 생성/변경 모드가 아닐 경우.
    IF NOT ( g_mode EQ c_charc OR
             g_mode EQ c_charm ) AND
       NOT ( screen-name EQ 'G_TC_2130_WA-FLAG' ).
      screen-input = c_char0.
    ENDIF.

    SEARCH g_fieldgroup FOR g_mode.
    IF sy-subrc <> 0.
      screen-input = c_char0.
    ELSE.
      screen-input = c_char1.
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
    CASE  gs_cols-screen-name.
      WHEN 'ZTISGRIT-RSNUM' OR 'ZTISGRIT-RSPOS' OR 'ZTISGRIT-RSART'.
        IF ztitgrk-igrty EQ c_charp.
          gs_cols-invisible = c_char1.
          MODIFY tc_2130-cols  INDEX g_tabix FROM gs_cols.
        ELSE.
          gs_cols-invisible = c_char0.
          MODIFY tc_2130-cols  INDEX g_tabix FROM gs_cols.
        ENDIF.
      WHEN 'ZTISGRIT-EBELN' OR 'ZTISGRIT-EBELP' OR 'ZTISGRIT-KNTTP'.
        IF ztitgrk-igrty EQ c_charr.
          gs_cols-invisible = c_char0.
          MODIFY tc_2130-cols  INDEX g_tabix FROM gs_cols.
        ELSE.
          gs_cols-invisible = c_char0.
          MODIFY tc_2130-cols  INDEX g_tabix FROM gs_cols.
        ENDIF.
    ENDCASE.
  ENDLOOP.

ENDMODULE.                 " TC_2130_CHANGE_COL_ATTR  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  pbo_scr2210_sub0_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_scr2210_sub0_subscreen OUTPUT.

*  g_call_prog        =  c_common_prog.
  g_call_prog        =  sy-cprog.
  g_call_subscreen   =  c_scr2211.

*  CALL FUNCTION 'Z_TI_OTHERS_TEXT_EXPORT'
*    EXPORTING
*      lcity  = c_char7
*      start  = c_chars
*      mode   = g_mode
*    TABLES
*      it_tab = it_lctext.
*
ENDMODULE.                 " pbo_scr2210_sub0_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2210_sub1_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_scr2210_sub1_subscreen OUTPUT.

*  g_call_prog        =  c_common_prog.
  g_call_prog        =  sy-cprog.
  g_call_subscreen   =  c_scr2212.

*  CALL FUNCTION 'Z_TI_OTHERS_TEXT_EXPORT'
*    EXPORTING
*      lcity  = c_char7
*      start  = c_chars
*      mode   = g_mode
*    TABLES
*      it_tab = it_lctext.
*


ENDMODULE.                 " pbo_scr2210_sub1_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2210_sub2_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_scr2210_sub2_subscreen OUTPUT.

*  g_call_prog        =  c_common_prog.
  g_call_prog        =  sy-cprog.
  g_call_subscreen   =  c_scr2213.

*  CALL FUNCTION 'Z_TI_OTHERS_TEXT_EXPORT'
*    EXPORTING
*      lcity  = c_char7
*      start  = c_chars
*      mode   = g_mode
*    TABLES
*      it_tab = it_lctext.
*

ENDMODULE.                 " pbo_scr2210_sub2_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2210_sub3_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_scr2210_sub3_subscreen OUTPUT.

*  g_call_prog        =  c_common_prog.
  g_call_prog        =  sy-cprog.
  g_call_subscreen   =  c_scr2214.

*  CALL FUNCTION 'Z_TI_OTHERS_TEXT_EXPORT'
*    EXPORTING
*      lcity  = c_char7
*      start  = c_chars
*      mode   = g_mode
*    TABLES
*      it_tab = it_lctext.
*
ENDMODULE.                 " pbo_scr2210_sub3_subscreen  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  change_EDI_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_edi_field_attr OUTPUT.

  LOOP AT SCREEN.
    IF g_mode EQ 'D' OR
       g_mode EQ 'S'.
      screen-input = '0'.
    ENDIF.
    IF g_mode EQ 'D'   OR
       g_mode EQ 'S' .

      IF screen-group1 EQ 'MOD' AND
         screen-name(3) EQ 'TC_'.
        screen-input = '0'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " change_EDI_field_attr  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  pbo_scr2215_sub0_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_scr2215_sub0_subscreen OUTPUT.

  g_call_prog        =  sy-cprog.
  g_call_subscreen   =  c_scr2214.

ENDMODULE.                 " pbo_scr2215_sub0_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2215_sub1_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_scr2215_sub1_subscreen OUTPUT.

  g_call_prog        =  sy-cprog.
  g_call_subscreen   =  c_scr2216.

ENDMODULE.                 " pbo_scr2215_sub1_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  change_field_visible_mode  OUTPUT
*&---------------------------------------------------------------------*
*       업무별로 화면상에 필드를 visible/Invisible 함.
*----------------------------------------------------------------------*
MODULE change_field_visible_mode OUTPUT.

*  LOOP AT SCREEN.
*    IF ZTITBLK-BLDTY NE C_CHARO.
*
*    ENDIF.
*
*            screen-input      =   c_char0.
*            screen-invisible  =   c_char1.
*    MODIFY SCREEN.
*  ENDLOOP.
*
ENDMODULE.                 " change_field_visible_mode  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SCR2123_SET_GRID  OUTPUT
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
      EXPORTING
        i_parent = g_scr2123_container.

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
        i_structure_name = 'ZTISACF'
        i_save           = g_variant_save
        is_variant       = g_variant
        i_default        = 'X'
      CHANGING
        it_fieldcatalog  = it_fieldcat_lvc[]
        it_outtab        = it_ztisacf[].
  ENDIF.

ENDMODULE.                 " PBO_SCR2123_SET_GRID  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2123_set_tabstrip  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_scr2123_set_tabstrip OUTPUT.

  LOOP AT SCREEN.
    IF screen-name EQ 'TABSTRIP_TAB3'.
      IF g_history_post EQ c_true.
        screen-input      =  c_char1.
        screen-invisible  =  c_char0.
      ELSE.
        screen-input      =  c_char0.
        screen-invisible  =  c_char1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " pbo_scr2123_set_tabstrip  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_status_6010  OUTPUT
*&---------------------------------------------------------------------*
*       입고취소 전기창.
*----------------------------------------------------------------------*
MODULE pbo_status_6010 OUTPUT.

  SET PF-STATUS '6010'.
  IF sy-dynnr EQ '6010'.
    SET TITLEBAR  'T6010'.
  ELSE.
    SET TITLEBAR  'T6020'.
  ENDIF.

ENDMODULE.                 " pbo_status_6010  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr0100_import_memory  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_scr0100_import_memory OUTPUT.

  IF sy-calld EQ c_true .
*> Batch Input일 경우.
    IF sy-tcode NE c_create.
      g_tcode = sy-tcode.
    ENDIF.

    CASE g_tcode.
      WHEN c_create_d.  ">다중 생성일 경우..
        IF it_ac_key[] IS INITIAL.
          MESSAGE a003(ok).
        ENDIF.
        g_tcode1 = g_tcode.
        g_tcode  = g_tcode.
        g_mode   = c_charc.
      WHEN OTHERS.
    ENDCASE.
  ELSE.
    g_tcode = sy-tcode.
  ENDIF.

ENDMODULE.                 " pbo_scr0100_import_memory  OUTPUT
