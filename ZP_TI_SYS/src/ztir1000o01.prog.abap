************************************************************************
* Title         :  ZTIR1000O01                                         *
*                                                                      *
* Description   : 적하부보 관리 PBO Include                            *
*                                                                      *
* Creation Date : 2003/08/20                                           *
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
*> COPY DDIC-TABLE 'ZTMIRQIT'
*> INTO INTERNAL TABLE 'g_tc_2130_itab'
*    SELECT * FROM ztmirqit
*       INTO CORRESPONDING FIELDS
*       OF TABLE g_tc_2130_itab.
    g_tc_2130_copied = 'X'.
    REFRESH CONTROL 'TC_2130' FROM SCREEN '2130'.
  ENDIF.

ENDMODULE.                 " tc_2130_init  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_move  OUTPUT
*&---------------------------------------------------------------------*
MODULE tc_2130_move OUTPUT.

  MOVE-CORRESPONDING g_tc_2130_wa TO ztisrqit.

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
    CASE  gs_cols-screen-name.
      WHEN 'ZTISRQIT-MJAHR' OR 'ZTISRQIT-MBLNR' OR 'ZTISRQIT-ZEILE'.
        IF ztitrqs-setyn EQ c_false.   ">정산여부 = 'n'.
          gs_cols-invisible = c_char1.
          MODIFY tc_2130-cols  INDEX g_tabix FROM gs_cols.
        ENDIF.
      WHEN 'ZTISRQIT-EBELN' OR 'ZTISRQIT-EBELP'.
        IF ztitrqs-setyn EQ c_true.   ">정산여부 = 'y'
          gs_cols-invisible = c_char0.
          MODIFY tc_2130-cols  INDEX g_tabix FROM gs_cols.
        ENDIF.
*{ 기능개선 283274 - 추가_S
      WHEN 'ZTISRQIT-IBLNO' OR 'ZTISRQIT-IBLIT'.
        IF sy-tcode <> 'ZTIT101N'.
          gs_cols-invisible = c_char1.
          MODIFY tc_2130-cols  INDEX g_tabix FROM gs_cols.
        ENDIF.
*} 기능개선 283274 - 추가_E
    ENDCASE.
  ENDLOOP.

ENDMODULE.                 " TC_2130_CHANGE_COL_ATTR  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  pbo_scr2200_set_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_scr2200_set_subscreen OUTPUT.

  g_call_prog  = sy-cprog.
  g_call_subscreen = c_scr2210.
*  PERFORM  set_edi_screen  USING ZTITRQK-reqty.

ENDMODULE.                 " pbo_scr2200_set_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2210_sub0_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_scr2210_sub0_subscreen OUTPUT.

*  g_call_prog        =  c_common_prog.
  g_call_prog        =  sy-cprog.
  g_call_subscreen   =  c_scr2211.

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

  LOOP AT SCREEN.
    CASE g_mode.
**> 생성/변경시.
*      WHEN c_charc OR c_charm.
*        CASE screen-name.
*          WHEN 'ZTITRQS-OPNNO' OR 'ZTITRQK-OPNBK' OR
*               'ZTSTIG3-NAMET' OR 'ZTITRQS-OPNDT' OR
*               'ZTITRQS-SNDDT'.
*            screen-input      =   c_char0.
*            screen-invisible  =   c_char1.
*        ENDCASE.
**> 접수/신청시.
*      WHEN c_chara OR c_chary.
*        CASE screen-name.
*          WHEN 'ZTITRQK-OPNBK' OR
*               'ZTSTIG3-NAMET' OR
*               'ZTITRQS-SNDDT'.
*            screen-input      =   c_char0.
*            screen-invisible  =   c_char1.
*        ENDCASE.
*> 개설정보 입력시.
      WHEN c_charo.
    ENDCASE.

    IF screen-name EQ 'TABSTRIP_TAB2'.
      IF ztitip1-damag EQ c_true.
        screen-input      =   c_char1.
        screen-invisible  =   c_char0.
      ELSE.
        screen-input      =   c_char0.
        screen-invisible  =   c_char1.
      ENDIF.
    ENDIF.

    IF ztstig3-itoyn IS INITIAL AND
      ( screen-name EQ 'ZTITIP1-ITOCP' OR
        screen-name EQ 'ZTITIP1-ITORT' ).
      screen-input      =   c_char0.
      screen-invisible  =   c_char1.
    ENDIF.

    IF ztstig3-iopyn IS INITIAL AND
       screen-name EQ 'ZTITIP1-IOPNO'.
      screen-input      =   c_char0.
      screen-invisible  =   c_char1.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " change_field_visible_mode  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2210_init   OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2210'. do not change this line!
*> copy ddic-table to itab
*&---------------------------------------------------------------------*
MODULE tc_2210_init OUTPUT.
  IF g_tc_2210_copied IS INITIAL.
    IF sy-dynnr EQ c_scr2124.
      REFRESH CONTROL 'TC_2124' FROM SCREEN '2124'.
    ELSEIF sy-dynnr EQ c_scr2210.
      REFRESH CONTROL 'TC_2210' FROM SCREEN '2210'.
    ENDIF.
    g_tc_2210_copied = c_true.
  ENDIF.
ENDMODULE.                    "TC_2210_init OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2210_move    OUTPUT
*&---------------------------------------------------------------------*
*&spwizard: output module for tc 'TC_2210'. do not change this line!
*&spwizard: move itab to dynpro
*&---------------------------------------------------------------------*
MODULE tc_2210_move OUTPUT.

  MOVE-CORRESPONDING g_tc_2210_wa TO ztisip02.

ENDMODULE.                    "tc_2210_move  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2210_move    OUTPUT
*&---------------------------------------------------------------------*
*&spwizard: output module for tc 'TC_2210'. do not change this line!
*&spwizard: get lines of tablecontrol
*&---------------------------------------------------------------------*
MODULE tc_2210_get_lines OUTPUT.
*  g_tc_2210_lines = sy-loopc.
*  g_tc_2130_lines = sy-loopc.

  IF sy-dynnr EQ c_scr2124.
    IF g_mode EQ c_charc OR
       g_mode EQ c_chary.
      DESCRIBE TABLE g_tc_2210_itab LINES g_line.     " LINE COUNT GET
      g_tc_2124_lines = g_line + 10.                  " LINE DEFINE
      tc_2124-lines = g_line + 10.
    ELSE.
      DESCRIBE TABLE g_tc_2210_itab LINES g_line.     " LINE COUNT GET
      g_tc_2124_lines = g_line.                       " LINE DEFINE
      tc_2124-lines = g_line.
    ENDIF.
  ELSEIF sy-dynnr EQ c_scr2210.
    IF g_mode EQ c_charc OR
       g_mode EQ c_chary.
      DESCRIBE TABLE g_tc_2210_itab LINES g_line.     " LINE COUNT GET
      g_tc_2210_lines = g_line + 10.                  " LINE DEFINE
      tc_2210-lines = g_line + 10.
    ELSE.
      DESCRIBE TABLE g_tc_2210_itab LINES g_line.     " LINE COUNT GET
      g_tc_2210_lines = g_line.                       " LINE DEFINE
      tc_2210-lines = g_line.
    ENDIF.
  ENDIF.
ENDMODULE.                    "TC_2210_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr0100_import_memory  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_scr0100_import_memory OUTPUT.

  CASE g_tcode.
    WHEN 'ZTIR103'.  ">수입의뢰 Due List(기타)
      g_tcode1 = g_tcode.
      g_tcode  = c_create.
      g_mode   = c_charc.
*{ 기능개선 283274 - 추가_S
    WHEN 'ZTIT101N'. ">생성-B/L기준
      g_tcode1 = g_tcode.
      g_tcode  = c_create.
      g_mode   = c_charc.
*} 기능개선 283274 - 추가_E
    WHEN OTHERS.
      g_tcode = sy-tcode.
  ENDCASE.

ENDMODULE.                 " pbo_scr0100_import_memory  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_scr7000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_scr7000 OUTPUT.

  SET PF-STATUS 'LIST'.
  SET TITLEBAR  'T7000'.

  CLEAR:  ok_code_popup.

ENDMODULE.                 " status_scr7000  OUTPUT
