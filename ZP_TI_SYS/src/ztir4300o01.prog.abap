************************************************************************
* Title         : ZTIR4300O01                                          *
*                                                                      *
* Description   : 수입신고의뢰 관리 PBO Include                        *
*                                                                      *
* Creation Date : 2004/02/18                                           *
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

  MOVE-CORRESPONDING g_tc_2130_wa TO ztiscrit.

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
    IF ztitblk-bldty EQ c_charo.
      CASE  gs_cols-screen-name.
        WHEN 'ZTISCRIT-EBELN' OR 'ZTISCRIT-EBELP' OR
             'ZTISCRIT-REQNO' OR 'ZTISCRIT-REQIT'.
          gs_cols-invisible = c_char1.
          MODIFY tc_2130-cols  INDEX g_tabix FROM gs_cols.
      ENDCASE.
    ELSE.
      CASE  gs_cols-screen-name.
        WHEN 'ZTISCRIT-RSNUM' OR 'ZTISCRIT-RSPOS' OR
             'ZTISCRIT-RSART'.
          gs_cols-invisible = c_char1.
          MODIFY tc_2130-cols  INDEX g_tabix FROM gs_cols.
      ENDCASE.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " TC_2130_CHANGE_COL_ATTR  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2200_set_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_scr2200_set_subscreen OUTPUT.

  g_call_prog  = sy-cprog.

  PERFORM  set_cus_edi_screen USING c_cc.
*  PERFORM  set_edi_screen  USING ZTITRQK-reqty.

ENDMODULE.                 " pbo_scr2200_set_subscreen  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  pbo_scr2210_sub0_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_scr2210_sub0_subscreen OUTPUT.

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
*&      Module  TC_2211_INIT  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2211'. do not change this line!
*> copy ddic-table to itab
*----------------------------------------------------------------------*
MODULE tc_2211_init OUTPUT.
  IF g_tc_2211_copied IS INITIAL.
    g_tc_2211_copied = 'X'.
    REFRESH CONTROL 'TC_2211' FROM SCREEN '2211'.
  ENDIF.

  DESCRIBE TABLE g_tc_2211_itab LINES g_line.     " LINE COUNT GET
  g_tc_2211_lines = g_line.                       " LINE DEFINE
  tc_2211-lines = g_line.

ENDMODULE.                    "TC_2211_init OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2212_INIT  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2212'. do not change this line!
*> copy ddic-table to itab
*----------------------------------------------------------------------*
MODULE tc_2212_init OUTPUT.

  IF g_tc_2212_copied IS INITIAL.
*> copy ddic-table 'ZTITLC02'
    g_tc_2212_copied = 'X'.
    REFRESH CONTROL 'TC_2212' FROM SCREEN '2212'.
  ENDIF.
*line.
  DESCRIBE TABLE g_tc_2212_tmp  LINES g_line.     " LINE COUNT GET
  g_tc_2212_lines = g_line.                       " LINE DEFINE
  tc_2212-lines = g_line.

ENDMODULE.                    "TC_2211_init OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2212_1_INIT  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2212_1'. do not change this line!
*> copy ddic-table to itab
*----------------------------------------------------------------------*
MODULE tc_2212_1_init OUTPUT.

  IF g_tc_2212_1_copied IS INITIAL.
    g_tc_2212_1_copied = 'X'.
    REFRESH CONTROL 'TC_2212_1' FROM SCREEN '2212'.
  ENDIF.

*line.
  DESCRIBE TABLE g_tc_2212_1_tmp LINES g_line.      " LINE COUNT GET
  IF g_mode EQ c_charc OR
     g_mode EQ c_charm.
    tc_2212_1-lines = g_line + 2.
  ELSE.
    tc_2212_1-lines = g_line.
  ENDIF.
  g_tc_2212_1_lines = tc_2212_1-lines.

ENDMODULE.                    "TC_2211_init OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2211_MOVE  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2211'. do not change this line!
*> move itab to dynpro
*----------------------------------------------------------------------*
MODULE tc_2211_move OUTPUT.

  MOVE-CORRESPONDING g_tc_2211_wa TO ztitcr1.

ENDMODULE.                    "TC_2211_move OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2212_MOVE  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2212'. do not change this line!
*> move itab to dynpro
*----------------------------------------------------------------------*
MODULE tc_2212_move OUTPUT.

  MOVE-CORRESPONDING g_tc_2212_wa TO ztitcr2.

ENDMODULE.                    "TC_2212_move OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TC_2211_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2211'. do not change this line!
*> get lines of tablecontrol
*----------------------------------------------------------------------*
MODULE tc_2211_get_lines OUTPUT.

*  DESCRIBE TABLE g_tc_0300_itab LINES g_line.
*  g_tc_0300_lines = g_line + 2.
*
  g_tc_2211_lines = sy-loopc.

ENDMODULE.                    "TC_2211_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2212_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2212'. do not change this line!
*> get lines of tablecontrol
*----------------------------------------------------------------------*
MODULE tc_2212_get_lines OUTPUT.

*  DESCRIBE TABLE g_tc_0300_itab LINES g_line.
*  g_tc_0300_lines = g_line + 2.
*
  g_tc_2212_lines = sy-loopc.

ENDMODULE.                    "TC_2212_get_lines OUTPUT
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
    IF screen-name EQ 'PB_BUTTON_001'.
      screen-input = '1'.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " change_EDI_field_attr  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  change_field_visible_mode  OUTPUT
*&---------------------------------------------------------------------*
*       업무별로 화면상에 필드를 visible/Invisible 함.
*----------------------------------------------------------------------*
MODULE change_field_visible_mode OUTPUT.

*  loop at screen.
*    case g_mode.
**> 생성/변경시.
*      when c_charc or c_charm.
*        case screen-name.
*          when 'ZTITRQS-OPNNO' or 'ZTITRQK-OPNBK' or
*               'ZTSTIG3-NAMET' or 'ZTITRQS-OPNDT' or
*               'ZTITRQS-SNDDT'.
*            screen-input      =   c_char0.
*            screen-invisible  =   c_char1.
*        endcase.
**> 접수/신청시.
*      when c_chara or c_chary.
*        case screen-name.
*          when 'ZTITRQK-OPNBK' or
*               'ZTSTIG3-NAMET' or
*               'ZTITRQS-SNDDT'.
*            screen-input      =   c_char0.
*            screen-invisible  =   c_char1.
*        endcase.
**> 개설정보 입력시.
*      when c_charo.
*
*    endcase.
*    case ZTITRQK-reqty.
*      when c_lc.
*        case screen-name.
*          when 'ZTITRQK-ANBTY' or 'ZTITRQK-PPAID' or
*               'ZTITRQK-RPAID'.
*            screen-input      =   c_char0.
*            screen-invisible  =   c_char1.
*        endcase.
*      when c_tt.
*        case screen-name.
*          when 'ZTITRQK-ANBTY' or 'ZTITRQK-ILCTY' or
*               'ZTITRQS-EXDAT' or 'ZTITRQS-LSDAT' or
*               'ZTITRQS-PAGRT' or 'ZTITRQS-PARTY' or
*               'ZTITRQS-TRANY' or ''.
*            screen-input      =   c_char0.
*            screen-invisible  =   c_char1.
*        endcase.
*      when c_pu.
*      when c_lo.
*      when c_da.
*      when c_dp.
*      when others.
*    endcase.
*    modify screen.
*  endloop.

ENDMODULE.                 " change_field_visible_mode  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2212_1_move  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_2212_1_move OUTPUT.

  MOVE-CORRESPONDING g_tc_2212_1_wa TO ztitcr3.

  g_tc_2212_1_lines = sy-loopc.

ENDMODULE.                 " TC_2212_1_move  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2212_2_INIT  OUTPUT
*&---------------------------------------------------------------------*
*       기능개선 xxxxx
*----------------------------------------------------------------------*
MODULE TC_2212_2_INIT OUTPUT.

  IF g_tc_2212_2_copied IS INITIAL.
    g_tc_2212_2_copied = 'X'.
    REFRESH CONTROL 'tc_2212_2' FROM SCREEN '2212'.
  ENDIF.

*line.
  DESCRIBE TABLE g_tc_2212_2_tmp LINES g_line.      " LINE COUNT GET
  IF g_mode EQ c_charc OR
     g_mode EQ c_charm.
    tc_2212_2-lines = g_line + 2.
  ELSE.
    tc_2212_2-lines = g_line.
  ENDIF.
  g_tc_2212_2_lines = tc_2212_2-lines.

ENDMODULE.                 " TC_2212_2_INIT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2212_2_MOVE  OUTPUT
*&---------------------------------------------------------------------*
*       기능개선 xxxxx
*----------------------------------------------------------------------*
MODULE TC_2212_2_MOVE OUTPUT.

  MOVE-CORRESPONDING g_tc_2212_2_wa TO ztitcr5.

  g_tc_2212_2_lines = sy-loopc.

ENDMODULE.                 " TC_2212_2_MOVE  OUTPUT
