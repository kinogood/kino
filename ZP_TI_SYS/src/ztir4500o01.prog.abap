************************************************************************
* Title         :  ZTIR4500O01                                         *
*                                                                      *
* Description   : 반입예정정보 Subroutine Include                      *
*                                                                      *
* Creation Date : 2003/08/21                                           *
*                                                                      *
* Author        : Seung Jun, LEE                                       *
*                                                                      *
************************************************************************
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

  MOVE-CORRESPONDING g_tc_2130_wa TO ZTIsblit.

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

    IF ZTITRQS-setyn EQ c_true AND   ">정산여부 = 'Y'.
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
        IF ZTITRQS-setyn EQ c_false.   ">정산여부 = 'n'.
          gs_cols-invisible = c_char1.
          MODIFY tc_2130-cols  INDEX g_tabix FROM gs_cols.
        ENDIF.
      WHEN 'ZTISRQIT-EBELN' OR 'ZTISRQIT-EBELP'.
        IF ZTITRQS-setyn EQ c_true.   ">정산여부 = 'y'
          gs_cols-invisible = c_char0.
          MODIFY tc_2130-cols  INDEX g_tabix FROM gs_cols.
        ENDIF.
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
*> 생성/변경시.
      WHEN c_charc OR c_charm.
        CASE screen-name.
          WHEN 'ZTITRQS-OPNNO' OR 'ZTITRQK-OPNBK' OR
               'ZTSTIG3-NAMET' OR 'ZTITRQS-OPNDT' OR
               'ZTITRQS-SNDDT'.
            screen-input      =   c_char0.
            screen-invisible  =   c_char1.
        ENDCASE.
*> 접수/신청시.
      WHEN c_chara OR c_chary.
        CASE screen-name.
          WHEN 'ZTITRQK-OPNBK' OR
               'ZTSTIG3-NAMET' OR
               'ZTITRQS-SNDDT'.
            screen-input      =   c_char0.
            screen-invisible  =   c_char1.
        ENDCASE.
*> 개설정보 입력시.
      WHEN c_charo.

    ENDCASE.
    CASE ZTITRQK-reqty.
      WHEN c_lc.
        CASE screen-name.
          WHEN 'ZTITRQK-ANBTY' OR 'ZTITRQK-PPAID' OR
               'ZTITRQK-RPAID'.
            screen-input      =   c_char0.
            screen-invisible  =   c_char1.
        ENDCASE.
      WHEN c_tt.
        CASE screen-name.
          WHEN 'ZTITRQK-ANBTY' OR 'ZTITRQK-ILCTY' OR
               'ZTITRQS-EXDAT' OR 'ZTITRQS-LSDAT' OR
               'ZTITRQS-PAGRT' OR 'ZTITRQS-PARTY' OR
               'ZTITRQS-TRANY' OR ''.
            screen-input      =   c_char0.
            screen-invisible  =   c_char1.
        ENDCASE.
      WHEN c_pu.
      WHEN c_lo.
      WHEN c_da.
      WHEN c_dp.
      WHEN OTHERS.
    ENDCASE.
*----------------------------------------------------------------------
*반입예정정보 스크린 수정(spec에 없는 필드)_041206 jp, park.
*    if screen-group2 = 'INV'.
*       screen-invisible = c_char1.
*    endif.
*-----------------------------------------------------------------------

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " change_field_visible_mode  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2122_init  OUTPUT
*&---------------------------------------------------------------------*
* output module for tc 'TC_2122'. do not change this line!
* copy ddic-table to itab
*----------------------------------------------------------------------*
MODULE tc_2122_init OUTPUT.
  IF g_tc_2122_copied IS INITIAL.
    g_tc_2122_copied = 'X'.
    REFRESH CONTROL 'TC_2122' FROM SCREEN '2122'.
  ENDIF.
ENDMODULE.                    "TC_2122_init OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2122_move  OUTPUT
*&---------------------------------------------------------------------*
* output module for tc 'TC_2122'. do not change this line!
* move itab to dynpro
*----------------------------------------------------------------------*
MODULE tc_2122_move OUTPUT.
  MOVE-CORRESPONDING g_tc_2122_wa TO ZTITBLC.
ENDMODULE.                    "TC_2122_move OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2122_get_lines  OUTPUT
*&---------------------------------------------------------------------*
* output module for tc 'TC_2122'. do not change this line!
* get lines of tablecontrol
*----------------------------------------------------------------------*
MODULE tc_2122_get_lines OUTPUT.
  g_tc_2122_lines = sy-loopc.
*  DESCRIBE TABLE g_TC_2122_itab LINES g_tc_2122_lines.
*  TC_2122-LINES        = g_tc_2122_lines.
*  TC_2122-CURRENT_LINE = g_tc_2122_lines.
*  TC_2122-TOP_LINE     = g_tc_2122_lines.
*
ENDMODULE.                    "TC_2122_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2111  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_2111 input.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.

endmodule.                 " user_command_2111  INPUT
