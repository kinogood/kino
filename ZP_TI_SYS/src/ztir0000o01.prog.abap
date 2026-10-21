************************************************************************
* Title         :  ZTIR0000O01                                         *
*                                                                      *
* Description   : 수입 L/C 관리 PBO Include                            *
*                                                                      *
* Creation Date : 2003/07/11                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*&---------------------------------------------------------------------*
*&      Module  tc_2130_init  OUTPUT
*&---------------------------------------------------------------------*
MODULE TC_2130_INIT OUTPUT.

  IF G_TC_2130_COPIED IS INITIAL.
*> COPY DDIC-TABLE 'ZTMIRQIT'
*> INTO INTERNAL TABLE 'g_tc_2130_itab'
*    SELECT * FROM ztmirqit
*       INTO CORRESPONDING FIELDS
*       OF TABLE g_tc_2130_itab.
    G_TC_2130_COPIED = 'X'.
    REFRESH CONTROL 'TC_2130' FROM SCREEN '2130'.
  ENDIF.

ENDMODULE.                 " tc_2130_init  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_move  OUTPUT
*&---------------------------------------------------------------------*
MODULE TC_2130_MOVE OUTPUT.

  MOVE-CORRESPONDING G_TC_2130_WA TO ZTISRQIT.

ENDMODULE.                 " tc_2130_move  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_get_lines  OUTPUT
*&---------------------------------------------------------------------*
MODULE TC_2130_GET_LINES OUTPUT.

*  g_tc_2130_lines = sy-loopc.
  DESCRIBE TABLE IT_TAB  LINES G_LINE.                  " LINE COUNT GET
  G_TC_2130_LINES = G_LINE.                             " LINE DEFINE
  TC_2130-LINES = G_LINE.

ENDMODULE.                 " tc_2130_get_lines  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
MODULE TC_2130_CHANGE_FIELD_ATTR OUTPUT.

  LOOP AT SCREEN.
*> 생성/변경 모드가 아닐 경우.
*    IF NOT ( g_mode EQ c_charc OR
*             g_mode EQ c_charm ) AND
*       NOT ( screen-name EQ 'G_TC_2130_WA-FLAG' ).
*    ENDIF.

    IF ZTITRQS-DOCST EQ C_CHARY AND
       G_MODE         EQ C_CHARY.
      SCREEN-INPUT      =   C_CHAR0.
    ENDIF.

    IF ZTITRQS-SETYN EQ C_TRUE AND   ">정산여부 = 'Y'.
       NOT ( SCREEN-NAME EQ 'G_TC_2130_WA-FLAG' ).
      SCREEN-INPUT = C_CHAR0.
*     20031020 lsj add.

      IF SCREEN-NAME = 'ZTISRQIT-STAWN'.
        IF G_MODE EQ C_CHARC OR
           G_MODE EQ C_CHARM.
          SCREEN-INPUT = C_CHAR1.
        ELSE.
          SCREEN-INPUT = C_CHAR0.
        ENDIF.
      ENDIF.
    ENDIF.

*> 금액수정 Setting에 따라서..
    IF ZTITIG00-AMTCC EQ C_FALSE.
      SCREEN-INPUT = C_CHAR0.
    ELSE.
      CLEAR G_FIELDGROUP.
      CONCATENATE SCREEN-GROUP1 SCREEN-GROUP2
                  SCREEN-GROUP3 SCREEN-GROUP4
             INTO G_FIELDGROUP.

      SEARCH G_FIELDGROUP FOR G_MODE.
      IF SY-SUBRC <> 0.
        SCREEN-INPUT = C_CHAR0.
      ELSE.
        SCREEN-INPUT = C_CHAR1.
      ENDIF.
    ENDIF.

    IF ZTITRQK-RPAID EQ C_TRUE.
      SCREEN-INPUT = C_CHAR0.
    ENDIF.

    IF SCREEN-NAME EQ 'G_TC_2130_WA-FLAG'.
      SCREEN-INPUT     = C_CHAR1.
      SCREEN-INVISIBLE = C_CHAR0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " tc_2130_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2130_CHANGE_COL_ATTR  OUTPUT
*&---------------------------------------------------------------------*
*       Column Invisibe/Visible
*----------------------------------------------------------------------*
MODULE TC_2130_CHANGE_COL_ATTR OUTPUT.

  LOOP AT TC_2130-COLS INTO GS_COLS.
    G_TABIX = SY-TABIX.
    CASE  GS_COLS-SCREEN-NAME.
      WHEN 'ZTISRQIT-MJAHR' OR 'ZTISRQIT-MBLNR' OR 'ZTISRQIT-ZEILE'.
        IF ZTITRQS-SETYN EQ C_FALSE.   ">정산여부 = 'n'.
          GS_COLS-INVISIBLE = C_CHAR1.
        ELSE.
          GS_COLS-INVISIBLE = C_CHAR0.
        ENDIF.
        MODIFY TC_2130-COLS  INDEX G_TABIX FROM GS_COLS.
      WHEN 'ZTISRQIT-EBELN' OR 'ZTISRQIT-EBELP' OR 'ZTISRQIT-EEIND'.
        IF ZTITRQS-SETYN EQ C_TRUE.   ">정산여부 = 'y'
          GS_COLS-INVISIBLE = C_CHAR1.
        ELSE.
          GS_COLS-INVISIBLE = C_CHAR0.
        ENDIF.
        MODIFY TC_2130-COLS  INDEX G_TABIX FROM GS_COLS.
*      WHEN 'ZTISRQIT-IBLNO' OR 'ZTISRQIT-IBLIT'.
*        IF ZTITRQS-setyn EQ c_true.   ">정산여부 = 'y'
*          gs_cols-invisible = c_char1.
*        ELSE.
*          gs_cols-invisible = c_char0.
*        ENDIF.
      WHEN 'ZTISRQIT-PPMNG'.
        IF ZTITRQS-PPAMT IS INITIAL.
          GS_COLS-INVISIBLE = C_CHAR1.
        ELSE.
          GS_COLS-INVISIBLE = C_CHAR0.
        ENDIF.
        MODIFY TC_2130-COLS  INDEX G_TABIX FROM GS_COLS.
    ENDCASE.
  ENDLOOP.

ENDMODULE.                 " TC_2130_CHANGE_COL_ATTR  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  pbo_scr2200_set_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR2200_SET_SUBSCREEN OUTPUT.

  G_CALL_PROG  = SY-CPROG.

  PERFORM  SET_EDI_SCREEN  USING ZTITRQK-REQTY.

ENDMODULE.                 " pbo_scr2200_set_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2240_init  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2240'. do not change this line!
*> copy ddic-table to itab
*&---------------------------------------------------------------------*
MODULE TC_2240_INIT OUTPUT.
  IF G_TC_2240_COPIED IS INITIAL.
*> copy ddic-table 'ZTITTT2'
*> into internal table 'g_TC_2240_itab'
*    SELECT * FROM ZTITTT2
*       INTO CORRESPONDING FIELDS
*       OF TABLE g_tc_2240_itab.
    G_TC_2240_COPIED = 'X'.
    REFRESH CONTROL 'TC_2240' FROM SCREEN '2240'.
  ENDIF.

  TC_2240-LINES = TC_2240-TOP_LINE + 2.

ENDMODULE.                    "TC_2240_init OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2240_move output  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2240'. do not change this line!
*> move itab to dynpro
*&---------------------------------------------------------------------*
MODULE TC_2240_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TC_2240_WA TO ZTITTT2.
ENDMODULE.                    "TC_2240_move OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2240_get_lines OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2240'. do not change this line!
*> get lines of tablecontrol
*&---------------------------------------------------------------------*
MODULE TC_2240_GET_LINES OUTPUT.
  G_TC_2240_LINES = SY-LOOPC.
ENDMODULE.                    "TC_2240_get_lines OUTPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2220_1_init  OUTPUT
*&---------------------------------------------------------------------*
*  output module for tc 'TC_2220_1'. do not change this line!
*  copy ddic-table to itab
*----------------------------------------------------------------------*
MODULE TC_2220_1_INIT OUTPUT.

  IF G_TC_2220_1_COPIED IS INITIAL.
    G_TC_2220_1_COPIED = 'X'.
    REFRESH CONTROL 'TC_2220_1' FROM SCREEN '2220'.
*-> 기능개선 75594 시작_2015.04.29
*  tc_2220_1-lines = tc_2220_1-top_line + 2.
    DESCRIBE TABLE G_TC_2220_1_ITAB LINES TC_2220_1-LINES.
*<- 기능개선 75594 종료
  ENDIF.


* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

ENDMODULE.                    "TC_2220_1_init OUTPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2220_1_move  OUTPUT
*&---------------------------------------------------------------------*
* output module for tc 'TC_2220_1'. do not change this line!
* move itab to dynpro
*&---------------------------------------------------------------------*
MODULE TC_2220_1_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TC_2220_1_WA TO ZTITPC2.
ENDMODULE.                    "TC_2220_1_move OUTPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2220_1_get_lines  OUTPUT
*&---------------------------------------------------------------------*
* output module for tc 'TC_2220_1'. do not change this line!
* get lines of tablecontrol
*&---------------------------------------------------------------------*
MODULE TC_2220_1_GET_LINES OUTPUT.
  G_TC_2220_1_LINES = SY-LOOPC.
ENDMODULE.                    "TC_2220_1_get_lines OUTPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2220_2_init  OUTPUT
*&---------------------------------------------------------------------*
*  output module for tc 'TC_2220_2'. do not change this line!
*  copy ddic-table to itab
*&---------------------------------------------------------------------*
MODULE TC_2220_2_INIT OUTPUT.
  IF G_TC_2220_2_COPIED IS INITIAL.
    G_TC_2220_2_COPIED = 'X'.
    REFRESH CONTROL 'TC_2220_2' FROM SCREEN '2220'.
*-> 기능개선 75594 시작_2015.04.29
    DESCRIBE TABLE G_TC_2220_2_ITAB LINES TC_2220_2-LINES.
*  tc_2220_2-lines = tc_2220_2-top_line + 2.
*<- 기능개선 75594 종료
  ENDIF.


ENDMODULE.                    "TC_2220_2_init OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2220_2_move  OUTPUT
*&---------------------------------------------------------------------*
*  output module for tc 'TC_2220_2'. do not change this line!
*  move itab to dynpro
*&---------------------------------------------------------------------*
MODULE TC_2220_2_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TC_2220_2_WA TO ZTITPC3.
ENDMODULE.                    "TC_2220_2_move OUTPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2220_2_get_lines  OUTPUT
*&---------------------------------------------------------------------*
*  output module for tc 'TC_2220_2'. do not change this line!
*  get lines of tablecontrol
*&---------------------------------------------------------------------*
MODULE TC_2220_2_GET_LINES OUTPUT.
  G_TC_2220_2_LINES = SY-LOOPC.
ENDMODULE.                    "TC_2220_2_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2210_sub0_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE PBO_SCR2210_SUB0_SUBSCREEN OUTPUT.

  G_CALL_PROG          = C_TEXT_PROG.
  G_TABSTRIP-PROG      = C_TEXT_PROG.
  G_TEXTID             = C_CHAR7.

*> 텍스트 데이타 Put
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    IT_TEXTTYPES[]       = GT_CONTROL-TEXTTYPES[].
    IT_ALL_LINES[]       = GT_CONTROL-TEXTLINES[].
    G_TEXTOBJECT         = GT_CONTROL-OBJECT.
    G_CALL_SUBSCREEN     = GT_CONTROL-DYNNR.
    G_TABSTRIP-SUBSCREEN = GT_CONTROL-DYNNR.
  ENDIF.

  CALL FUNCTION 'Z_TS_TEXT_EXP_SUBSCREEN_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
    TABLES
      IMT_TEXTTYPES = IT_TEXTTYPES
      IMT_TEXTLINES = IT_ALL_LINES.
*
ENDMODULE.                 " pbo_scr2210_sub0_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2210_sub1_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE PBO_SCR2210_SUB1_SUBSCREEN OUTPUT.

  G_CALL_PROG          = C_TEXT_PROG.
  G_TABSTRIP-PROG      = C_TEXT_PROG.
  G_TEXTID             = C_CHAR8.

  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    IT_TEXTTYPES[]       = GT_CONTROL-TEXTTYPES[].
    IT_ALL_LINES[]       = GT_CONTROL-TEXTLINES[].
    G_TEXTOBJECT         = GT_CONTROL-OBJECT.
    G_CALL_SUBSCREEN     = GT_CONTROL-DYNNR.
    G_TABSTRIP-SUBSCREEN = GT_CONTROL-DYNNR.
  ENDIF.

  CALL FUNCTION 'Z_TS_TEXT_EXP_SUBSCREEN_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
    TABLES
      IMT_TEXTTYPES = IT_TEXTTYPES
      IMT_TEXTLINES = IT_ALL_LINES.
*
ENDMODULE.                 " pbo_scr2210_sub1_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2210_sub2_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE PBO_SCR2210_SUB2_SUBSCREEN OUTPUT.

  G_CALL_PROG          = C_TEXT_PROG.
  G_TABSTRIP-PROG      = C_TEXT_PROG.
  G_TEXTID             = C_CHAR9.

  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.

  IF SY-SUBRC EQ 0.
    IT_TEXTTYPES[]       = GT_CONTROL-TEXTTYPES[].
    IT_ALL_LINES[]       = GT_CONTROL-TEXTLINES[].
    G_TEXTOBJECT         = GT_CONTROL-OBJECT.
    G_CALL_SUBSCREEN     = GT_CONTROL-DYNNR.
    G_TABSTRIP-SUBSCREEN = GT_CONTROL-DYNNR.
  ENDIF.

  CALL FUNCTION 'Z_TS_TEXT_EXP_SUBSCREEN_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
    TABLES
      IMT_TEXTTYPES = IT_TEXTTYPES
      IMT_TEXTLINES = IT_ALL_LINES.
*
ENDMODULE.                 " pbo_scr2210_sub2_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2210_sub3_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE PBO_SCR2210_SUB3_SUBSCREEN OUTPUT.

  G_CALL_PROG        =  SY-CPROG.
  G_CALL_SUBSCREEN   =  C_SCR2214.

ENDMODULE.                 " pbo_scr2210_sub3_subscreen  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TC_2211_INIT  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2211'. do not change this line!
*> copy ddic-table to itab
*----------------------------------------------------------------------*
MODULE TC_2211_INIT OUTPUT.
  IF G_TC_2211_COPIED IS INITIAL.
    G_TC_2211_COPIED = 'X'.
    REFRESH CONTROL 'TC_2211' FROM SCREEN '2211'.
  ENDIF.

  TC_2211-LINES = TC_2211-TOP_LINE + 2.

ENDMODULE.                    "TC_2211_init OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2212_INIT  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2212'. do not change this line!
*> copy ddic-table to itab
*----------------------------------------------------------------------*
MODULE TC_2212_INIT OUTPUT.
  IF G_TC_2212_COPIED IS INITIAL.
    G_TC_2212_COPIED = 'X'.
    REFRESH CONTROL 'TC_2212' FROM SCREEN '2212'.
  ENDIF.

  TC_2212-LINES = TC_2212-TOP_LINE + 2.

ENDMODULE.                    "TC_2211_init OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2213_INIT  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2213'. do not change this line!
*> copy ddic-table to itab
*----------------------------------------------------------------------*
MODULE TC_2213_INIT OUTPUT.
  IF G_TC_2213_COPIED IS INITIAL.
    G_TC_2213_COPIED = 'X'.
    REFRESH CONTROL 'TC_2213' FROM SCREEN '2213'.
  ENDIF.

  TC_2213-LINES = TC_2213-TOP_LINE + 2.

ENDMODULE.                    "TC_2211_init OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TC_2211_MOVE  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2211'. do not change this line!
*> move itab to dynpro
*----------------------------------------------------------------------*
MODULE TC_2211_MOVE OUTPUT.

  MOVE-CORRESPONDING G_TC_2211_WA TO ZTITLC2.

ENDMODULE.                    "TC_2211_move OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2212_MOVE  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2212'. do not change this line!
*> move itab to dynpro
*----------------------------------------------------------------------*
MODULE TC_2212_MOVE OUTPUT.

  MOVE-CORRESPONDING G_TC_2212_WA TO ZTITLC2.

ENDMODULE.                    "TC_2212_move OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2213_MOVE  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2213'. do not change this line!
*> move itab to dynpro
*----------------------------------------------------------------------*
MODULE TC_2213_MOVE OUTPUT.

  MOVE-CORRESPONDING G_TC_2213_WA TO ZTITLC2.

ENDMODULE.                    "TC_2213_move OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TC_2211_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2211'. do not change this line!
*> get lines of tablecontrol
*----------------------------------------------------------------------*
MODULE TC_2211_GET_LINES OUTPUT.

*  DESCRIBE TABLE g_tc_0300_itab LINES g_line.
*  g_tc_0300_lines = g_line + 2.
*
  G_TC_2211_LINES = SY-LOOPC.

ENDMODULE.                    "TC_2211_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2212_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2212'. do not change this line!
*> get lines of tablecontrol
*----------------------------------------------------------------------*
MODULE TC_2212_GET_LINES OUTPUT.

*  DESCRIBE TABLE g_tc_0300_itab LINES g_line.
*  g_tc_0300_lines = g_line + 2.
*
  G_TC_2212_LINES = SY-LOOPC.

ENDMODULE.                    "TC_2212_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2213_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2213'. do not change this line!
*> get lines of tablecontrol
*----------------------------------------------------------------------*
MODULE TC_2213_GET_LINES OUTPUT.

*  DESCRIBE TABLE g_tc_0300_itab LINES g_line.
*  g_tc_0300_lines = g_line + 2.
*
  G_TC_2213_LINES = SY-LOOPC.

ENDMODULE.                    "TC_2213_get_lines OUTPUT

*&---------------------------------------------------------------------*
*&      Module  change_EDI_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_EDI_FIELD_ATTR OUTPUT.

  LOOP AT SCREEN.
    IF G_MODE EQ 'D' OR
       G_MODE EQ 'S'.
      SCREEN-INPUT = '0'.
    ENDIF.
    IF G_MODE EQ 'D'   OR
       G_MODE EQ 'S' .

      IF SCREEN-GROUP1 EQ 'MOD' AND
         SCREEN-NAME(3) EQ 'TC_'.
        SCREEN-INPUT = '0'.
      ENDIF.
    ENDIF.

* 동보전송 체크했으면 사업자번호 비활성화
    IF SCREEN-NAME = 'ZTITPC1-PSPID' AND
       ZTITRQS-DONGBO = 'X'.
      SCREEN-INPUT = '0'.
    ENDIF.

*-{ 기능개선 198545 - 개설 의뢰인 상호 수정 불가
*-- 가온전선도 추가
    IF ( ZTITIG00-BUKRS = '1000' OR  ZTITIG00-BUKRS = '5000'
         OR   ZTITIG00-BUKRS = '6000' )
       AND  SCREEN-GROUP1 EQ 'NM' .
      SCREEN-INPUT = '0'.
    ENDIF.
*-} 기능개선 198545
*-- 가온전선도 추가
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " change_EDI_field_attr  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TC_2214_INIT  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2214'. do not change this line!
*> copy ddic-table to itab
*----------------------------------------------------------------------*
MODULE TC_2214_INIT OUTPUT.
  IF G_TC_2214_COPIED IS INITIAL.
    G_TC_2214_COPIED = 'X'.
    REFRESH CONTROL 'TC_2214' FROM SCREEN '2214'.
  ENDIF.

  TC_2214-LINES = TC_2214-TOP_LINE + 2.

ENDMODULE.                    "TC_2214_init OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TC_2214_MOVE  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2214'. do not change this line!
*> move itab to dynpro
*----------------------------------------------------------------------*
MODULE TC_2214_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TC_2214_WA TO ZTITLC3.
ENDMODULE.                    "TC_2214_move OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TC_2214_MOVE  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2214'. do not change this line!
*> get lines of tablecontrol
*----------------------------------------------------------------------*
MODULE TC_2214_GET_LINES OUTPUT.
  G_TC_2214_LINES = SY-LOOPC.
ENDMODULE.                    "TC_2214_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2215_sub0_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE PBO_SCR2215_SUB0_SUBSCREEN OUTPUT.

  G_CALL_PROG        =  SY-CPROG.
  G_CALL_SUBSCREEN   =  C_SCR2214.
*
ENDMODULE.                 " pbo_scr2215_sub0_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2215_sub1_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE PBO_SCR2215_SUB1_SUBSCREEN OUTPUT.

  IF G_MODE = 'S' OR    "조회
     G_MODE = 'D' OR    "삭제
     G_MODE = '0'.      "개설

    G_CALL_PROG          = C_TEXT_PROG.
    G_TABSTRIP-PROG      = C_TEXT_PROG.
    G_TEXTID             = C_CHARA.

*> 텍스트 데이타 Put
    CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

    READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
    IF SY-SUBRC EQ 0.
      IT_TEXTTYPES[]       = GT_CONTROL-TEXTTYPES[].
      IT_ALL_LINES[]       = GT_CONTROL-TEXTLINES[].
      G_TEXTOBJECT         = GT_CONTROL-OBJECT.
      G_CALL_SUBSCREEN     = GT_CONTROL-DYNNR.
      G_TABSTRIP-SUBSCREEN = GT_CONTROL-DYNNR.
    ENDIF.

    CALL FUNCTION 'Z_TS_TEXT_EXP_SUBSCREEN_SINGLE'
      EXPORTING
        IM_TEXTOBJECT = G_TEXTOBJ
        IM_TEXTID     = G_TEXTID
      TABLES
        IMT_TEXTTYPES = IT_TEXTTYPES
        IMT_TEXTLINES = IT_ALL_LINES.

  ELSE.
    G_CALL_PROG      = C_TEXT_PROG.
    G_CALL_SUBSCREEN = C_SCR2065.
  ENDIF.

ENDMODULE.                 " pbo_scr2215_sub1_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  change_field_visible_mode  OUTPUT
*&---------------------------------------------------------------------*
*       업무별로 화면상에 필드를 visible/Invisible 함.
*----------------------------------------------------------------------*
MODULE CHANGE_FIELD_VISIBLE_MODE OUTPUT.
  DATA: LV_BNFA LIKE ZTITIG00-BNFA.

  LOOP AT SCREEN.
    IF ( SCREEN-NAME EQ 'SWIFTCODE'  OR
         SCREEN-NAME EQ 'IBANCODE'   OR
         SCREEN-NAME EQ 'BLOCK0'        ).
      SCREEN-INVISIBLE  =   C_CHAR1.
    ENDIF.

    CASE G_MODE.
*> 생성/변경시.
      WHEN C_CHARC OR C_CHARM.
        CASE SCREEN-NAME.
          WHEN 'ZTITRQS-OPNNO' OR 'ZTITRQK-OPNBK' OR
               'ZTSTIG3-NAMET' OR 'ZTITRQS-OPNDT' OR
               'ZTITRQS-SNDDT' OR 'ZTITTT1-TECDT' OR
               'ZTISSCRCOM-OPNNO' OR 'ZTITRQS-BUSCL' OR
               'ZTITRQS-AKKUR' OR 'ZTITRQS-DMBTR' OR
               'ZTITRQS-HWAER' .
            SCREEN-INPUT      =   C_CHAR0.
            SCREEN-INVISIBLE  =   C_CHAR1.

******************************************************************
* 20070302 simcho by 박혁세K : addtional chg. 비활성화
* 20080626 simcho by 박혁시K : addtional chg. 활성화
*                            : MTRON 마이그레이션 용
******************************************************************
*          WHEN  'ZTITRQS-OTCHG' .
*            screen-input      =   c_char0.
*            screen-invisible  =   c_char0.
******************************************************************
* 20070302 simcho by 박혁세K : 공급업체 활성
******************************************************************
          WHEN  'ZTITRQK-LIFNR' .
            SCREEN-INPUT      =   C_CHAR1.
            SCREEN-INVISIBLE  =   C_CHAR0.
******************************************************************
        ENDCASE.

*> 접수시.
      WHEN C_CHARA.
        CASE SCREEN-NAME.
          WHEN 'ZTITRQK-OPNBK' OR
               'ZTSTIG3-NAMET' OR
               'ZTITRQS-SNDDT' OR
               'ZTITRQS-OPNNO' OR
               'ZTITRQS-OPNDT' OR
               'ZTITTT1-TECDT' OR
               'ZTITRQS-BUSCL' OR
               'ZTISSCRCOM-OPNNO' OR
               'ZTITRQS-AKKUR' OR 'ZTITRQS-DMBTR' OR
               'ZTITRQS-HWAER'.

            SCREEN-INPUT      =   C_CHAR0.
            SCREEN-INVISIBLE  =   C_CHAR1.
        ENDCASE.
*> 신청시.
      WHEN C_CHARY.
        CASE SCREEN-NAME.
          WHEN 'ZTITRQS-OPNNO'  OR
               'ZTITRQS-OPNDT'  OR
               'ZTISSCRCOM-OPNNO' OR
               'ZTITRQS-AKKUR' OR 'ZTITRQS-DMBTR' OR
               'ZTITRQS-HWAER'.
            SCREEN-INPUT      =   C_CHAR0.
            SCREEN-INVISIBLE  =   C_CHAR1.
* 20060112 simcho 지불조건
          WHEN 'ZTITRQK-ILCTY'.
            SCREEN-INPUT      =   C_CHAR1.
            SCREEN-INVISIBLE  =   C_CHAR0.
* end
        ENDCASE.
        IF ZTITRQS-DOCST EQ C_CHARY.
          SCREEN-INPUT      =   C_CHAR0.
        ENDIF.
*> 개설정보 입력시.
      WHEN C_CHARO.
    ENDCASE.

*> Amend시.
    IF ZTITRQS-AMDSQ GT C_ZERO .
      IF SCREEN-NAME    EQ 'ZTITRQK-OPNBK' OR
         SCREEN-NAME    EQ 'ZTSTIG3-NAMET' OR
         SCREEN-NAME    EQ 'ZTITRQK-ILCTY' OR
         SCREEN-NAME    EQ 'ZTITRQS-PAGRT' OR
         SCREEN-NAME    EQ 'ZTITRQS-UMTCU' OR
         SCREEN-NAME    EQ 'ZTITLC1-CHGER' OR
         SCREEN-NAME    EQ 'ZTITRQK-USCDY' OR
         SCREEN-NAME    EQ 'ZTITRQS-BUSCL'.
        SCREEN-INPUT    =   C_CHAR0.
      ENDIF.
    ENDIF.

    CASE ZTITRQK-REQTY.
      WHEN C_LC.
        CASE SCREEN-NAME.
          WHEN 'ZTITRQK-ANBTY'  OR 'ZTITRQK-PPAID'  OR
               'ZTITRQK-RPAID'  OR 'ZTITPC1-PSPY1'  OR
               'ZTITPC1-PSPY2'  OR 'ZTITPC1-PSPY3'  OR
               'ZTITLO1-LLCTY'  OR 'ZTITLO1-LOPME'  OR
               'ZTITTT1-TPYFN'  OR 'ZTITTT1-TSTCD'  OR
               'ZTITTT1-TECDT'  OR 'ZTITTT1-TBBNM'  OR
               'ZTITTT1-TBBAD1' OR 'ZTITTT1-TBBAD2' OR
               'ZTITTT1-TBBAD3' OR 'ZTITTT1-TBBAN'  OR
               'ZTITRQS-SETLR'  OR 'ZTITRQS-REPTR'  OR
               'ZTITRQS-AKKUR'  OR 'ZTITRQS-DMBTR'  OR
               'ZTITRQS-PAYCD'  OR 'ZTITLO1-LSENO1' OR
               'ZTITRQS-HWAER'  OR 'ZTITTT1-TBBAM'  OR "기능개선 184344
               'ZTITPC1-PSBUS'  OR
               'ZTITPC1-PSPCD'  OR
               'ZTITRQS-DONGBO' OR   "동보전송여부
               'ZTITPC1-PSBNM'  OR 'ZTITLO1-LOPME_TXT'.
            "2004.01.15 상신자추가
            "2015.09.16 개설근거용도 텍스트추가
            SCREEN-INPUT      =   C_CHAR0.
            SCREEN-INVISIBLE  =   C_CHAR1.
        ENDCASE.
      WHEN C_TT.
        CASE SCREEN-NAME.
          WHEN 'ZTITRQK-ILCTY' OR
               'ZTITRQS-EXDAT' OR 'ZTITRQS-LSDAT' OR
               'ZTITRQS-PAGRT' OR 'ZTITRQS-PARTY' OR
               'ZTITRQS-TRANY' OR 'ZTITPC1-PSPY1' OR
               'ZTITPC1-PSPY2' OR 'ZTITPC1-PSPY3' OR
               'ZTITLO1-LLCTY' OR 'ZTITLO1-LOPME' OR
               'ZTITRQS-CTOCD' OR 'ZTITRQS-CTONM' OR
*               'ZTITRQS-FLAND' OR 'ZTITRQS-FPORT' OR
*               'ZTITRQS-PLLOD' OR 'ZTITRQS-PLTRN' OR
*               'ZTITRQS-TLAND' OR 'ZTITRQS-TPORT' OR
               'ZTITRQK-FWDCD' OR 'ZTITRQK-FWDTX' OR
               'ZTITRQK-USCDY'                    OR
               'ZTITRQS-PAYCD' OR
               'ZTITLC1-CHGER' OR 'ZTITRQS-SETLR' OR
               'ZTITRQS-UMTCU' OR 'ZTITRQS-REPTR' OR
               'ZTITRQS-AKKUR' OR 'ZTITRQS-DMBTR' OR
               'ZTITRQS-HWAER' OR
               'ZTITLO1-LSENO1' OR
               'ZTITPC1-PSBUS'  OR
               'ZTITPC1-PSPCD'  OR
               'ZTITRQS-DONGBO' OR   "동보전송여부
               'ZTITPC1-PSBNM'  OR
               'ZTITLO1-LOPME_TXT'.

            SCREEN-INPUT      =   C_CHAR0.
            SCREEN-INVISIBLE  =   C_CHAR1.
        ENDCASE.

        IF ( SCREEN-NAME EQ 'BLOCK0' ).
          SCREEN-INVISIBLE  =   C_CHAR0.
        ENDIF.

*> 유보금일 경우 금액 필드를 입력가능하도록 함.
        IF ( G_MODE EQ C_CHARC OR
             G_MODE EQ C_CHARM ) AND
           ( SCREEN-NAME EQ 'ZTITRQS-OPAMT' ) AND
             ZTITRQK-RPAID EQ C_TRUE.
          SCREEN-INPUT      =   C_CHAR1.
          SCREEN-INVISIBLE  =   C_CHAR0.
        ENDIF.
*> TT일 경우 계좌 필드를 입력 불가능하도록 함.
*> 수취인 계좌내역 Setting
***********************************************************************
* 회사별 프로세스 정의 개설요청 수취인거래은행 관리여부 => x
* 수취인 관리계좌내역에서 테이터를 QUERY
***********************************************************************
        SELECT SINGLE BNFA
         INTO LV_BNFA
         FROM ZTITIG00
        WHERE BUKRS EQ ZTITRQK-BUKRS.
***********************************************************************
        IF LV_BNFA EQ 'X'.
          IF ( G_MODE EQ C_CHARC OR
                G_MODE EQ C_CHARM ) AND
              ( SCREEN-NAME EQ 'ZTITTT1-TBBNM'  OR
                SCREEN-NAME EQ 'ZTITTT1-TBBAD1' OR
                SCREEN-NAME EQ 'ZTITTT1-TBBAD2' OR
                SCREEN-NAME EQ 'ZTITTT1-TBBAD3' OR
                SCREEN-NAME EQ 'ZTITTT1-TBBAM' OR
                SCREEN-NAME EQ 'ZTITTT1-TBBAN'   ).
            SCREEN-INPUT      =   C_CHAR0.
            SCREEN-INVISIBLE  =   C_CHAR0.
          ENDIF.
          IF ( SCREEN-NAME EQ 'SWIFTCODE'  OR
               SCREEN-NAME EQ 'IBANCODE'    ).
            SCREEN-INVISIBLE  =   C_CHAR0.
          ENDIF.
          IF ( SCREEN-NAME EQ 'G_TXT50' ).
            G_TXT50 = '지점명'.
          ENDIF.
        ELSE.
          IF ( SCREEN-NAME EQ 'SWIFTCODE'  OR
               SCREEN-NAME EQ 'IBANCODE'    ).
            SCREEN-INVISIBLE  =   C_CHAR1.
          ENDIF.
          IF ( SCREEN-NAME EQ 'G_TXT50' ).
            G_TXT50 = '주 소'.
          ENDIF.
        ENDIF.
      WHEN C_PU.
        CASE SCREEN-NAME.
          WHEN 'ZTITRQK-ILCTY' OR 'ZTITRQK-PPAID' OR
               'ZTITRQK-RPAID' OR 'ZTITRQS-EXDAT' OR
               'ZTITRQS-LSDAT' OR 'ZTITRQS-PAGRT' OR
*               'ZTITRQS-INSYN' OR 'ZTITRQS-INCO1' OR
               'ZTITRQS-INCO2' OR 'ZTITRQS-FWDTY' OR
               'ZTITRQS-PARTY' OR 'ZTITRQS-TRANY' OR
               'ZTITRQS-CTOCD' OR 'ZTITRQS-CTONM' OR
               'ZTITRQS-FLAND' OR 'ZTITRQS-FPORT' OR
               'ZTITRQS-PLLOD' OR 'ZTITRQS-PLTRN' OR
               'ZTITRQS-TLAND' OR 'ZTITRQS-TPORT' OR
               'ZTITRQK-TDPYN' OR
               'ZTITRQS-PAYCD' OR
*               'ZTITRQS-PLTRN' OR
               'ZTITLC1-CHGER' OR
*               'ZTITRQS-CHGER' OR
*               'ZTITLC1-CHGER' OR
               'ZTITTT1-TPYFN' OR 'ZTITTT1-TSTCD' OR
               'ZTITTT1-TECDT' OR
               'ZTITTT1-TBBAD1' OR 'ZTITTT1-TBBAD2' OR
               'ZTITTT1-TBBAD3' OR 'ZTITTT1-TBBAN'  OR
*               'ZTITLO1-LLCTY' OR 'ZTITLO1-LOPME'  OR
               'ZTITRQK-FWDCD' OR 'ZTITRQK-FWDTX'  OR
               'ZTITRQK-USCDY'                      OR
               'ZTITLO1-LLCTY' OR 'ZTITLO1-LOPME'  OR
               'ZTITTT1-TBBNM' OR 'ZTITRQK-FWDAS'  OR
               'ZTITRQS-UMTCU' OR 'ZTITTT1-TBBAM' OR
               'G_LSDATX'       OR 'G_EXDATX'       OR
               'G_FWDTYX'       OR 'G_PARTYX'       OR
               'G_TRANYX'       OR
               'ZTITLO1-LSENO1' OR 'ZTITLO1-LOPME_TXT'.
            SCREEN-INPUT      =   C_CHAR0.
            SCREEN-INVISIBLE  =   C_CHAR1.
        ENDCASE.

        IF ZTITRQS-SETYN   NE C_TRUE AND
           SCREEN-NAME      EQ 'ZTITRQS-SETLR'.
          SCREEN-INPUT      =   C_CHAR0.
          SCREEN-INVISIBLE  =   C_CHAR1.
        ENDIF.
        IF ZTITRQS-SETYN   NE C_TRUE AND
           SCREEN-NAME      EQ 'ZTITRQS-REPTR'.
          SCREEN-INPUT      =   C_CHAR0.
          SCREEN-INVISIBLE  =   C_CHAR1.
        ENDIF.

      WHEN C_LO.
        CASE SCREEN-NAME.
          WHEN 'ZTITRQK-ANBTY' OR 'ZTITRQK-ILCTY' OR
*               'ZTITRQS-EXDAT' OR 'ZTITRQS-LSDAT' OR
               'ZTITRQS-PAGRT' OR
               'ZTITTT1-TPYFN' OR 'ZTITTT1-TSTCD' OR
               'ZTITTT1-TECDT' OR
               'ZTITRQK-RPAID' OR 'ZTITRQK-PPAID' OR
               'ZTITRQS-TRANY' OR 'ZTITPC1-PSPY1' OR
               'ZTITPC1-PSPY2' OR 'ZTITPC1-PSPY3' OR
               'ZTITLC1-CHGER' OR
               'ZTITRQS-CTOCD' OR 'ZTITRQS-CTONM' OR
               'ZTITRQS-FLAND' OR 'ZTITRQS-FPORT' OR
               'ZTITRQS-PLLOD' OR 'ZTITRQS-PLTRN' OR
               'ZTITRQS-TLAND' OR 'ZTITRQS-TPORT' OR
               'ZTITRQK-FWDCD' OR 'ZTITRQK-FWDTX' OR
               'ZTITRQK-USCDY'                     OR
               'ZTITRQK-TDPYN' OR
               'ZTITRQS-FWDTY' OR
               'ZTITRQS-PAYCD' OR 'ZTITTT1-TBBAM' OR
               'ZTITRQK-FWDAS' OR 'ZTITTT1-TBBNM'   OR
               'ZTITTT1-TBBAD1' OR 'ZTITTT1-TBBAD2' OR
               'ZTITTT1-TBBAD3' OR 'ZTITTT1-TBBAN'  OR
               'ZTITRQS-UMTCU'  OR 'ZTITRQS-SETLR'  OR
               'ZTITPC1-PSBUS'  OR
               'ZTITPC1-PSPCD'  OR
               'ZTITPC1-PSBNM'  OR
               'ZTITRQS-DONGBO' OR   "동보전송여부
               'ZTITRQS-REPTR'.
            SCREEN-INPUT      =   C_CHAR0.
            SCREEN-INVISIBLE  =   C_CHAR1.
        ENDCASE.
      WHEN C_DA.
        CASE SCREEN-NAME.
          WHEN 'ZTITRQK-ANBTY' OR 'ZTITRQK-ILCTY' OR
               'ZTITRQS-EXDAT' OR 'ZTITRQS-LSDAT' OR
               'ZTITRQS-PAGRT' OR 'ZTITRQS-PARTY' OR
               'ZTITRQS-TRANY' OR 'ZTITPC1-PSPY1' OR
               'ZTITPC1-PSPY2' OR 'ZTITPC1-PSPY3' OR
               'ZTITTT1-TPYFN' OR 'ZTITTT1-TSTCD' OR
               'ZTITTT1-TECDT' OR
               'ZTITRQK-PPAID' OR 'ZTITRQK-RPAID' OR
               'ZTITLC1-CHGER' OR
               'ZTITRQK-FWDCD' OR 'ZTITRQK-FWDTX' OR
               'ZTITRQK-USCDY'                     OR
               'ZTITTT1-TBBNM'  OR 'ZTITTT1-TBBAM' OR
               'ZTITTT1-TBBAD1' OR 'ZTITTT1-TBBAD2' OR
               'ZTITTT1-TBBAD3' OR 'ZTITTT1-TBBAN'  OR
               'ZTITLO1-LLCTY'  OR 'ZTITLO1-LOPME'  OR
               'ZTITRQS-UMTCU'  OR 'ZTITRQS-SETLR'  OR
               'ZTITRQS-REPTR'  OR
               'ZTITRQS-AKKUR' OR 'ZTITRQS-DMBTR' OR
               'ZTITRQS-HWAER'  OR
               'ZTITLO1-LSENO1' OR
               'ZTITPC1-PSBUS'  OR
               'ZTITPC1-PSPCD'  OR
               'ZTITRQS-DONGBO' OR   "동보전송여부
               'ZTITPC1-PSBNM' OR 'ZTITLO1-LOPME_TXT'.
            SCREEN-INPUT      =   C_CHAR0.
            SCREEN-INVISIBLE  =   C_CHAR1.
        ENDCASE.
      WHEN C_DP.
        CASE SCREEN-NAME.
          WHEN 'ZTITRQK-ANBTY' OR 'ZTITRQK-ILCTY' OR
               'ZTITRQS-EXDAT' OR 'ZTITRQS-LSDAT' OR
               'ZTITRQS-PAGRT' OR 'ZTITRQS-PARTY' OR
               'ZTITRQS-TRANY' OR 'ZTITPC1-PSPY1' OR
               'ZTITPC1-PSPY2' OR 'ZTITPC1-PSPY3' OR
               'ZTITTT1-TPYFN' OR 'ZTITTT1-TSTCD' OR
               'ZTITTT1-TECDT' OR 'ZTITTT1-TBBAM' OR
               'ZTITRQK-PPAID' OR 'ZTITRQK-RPAID' OR
               'ZTITLC1-CHGER' OR
               'ZTITRQK-FWDCD' OR 'ZTITRQK-FWDTX' OR
               'ZTITRQK-USCDY'                     OR
               'ZTITRQS-PAYCD'  OR
               'ZTITTT1-TBBNM'  OR
               'ZTITTT1-TBBAD1' OR 'ZTITTT1-TBBAD2' OR
               'ZTITTT1-TBBAD3' OR 'ZTITTT1-TBBAN'  OR
               'ZTITLO1-LLCTY'  OR 'ZTITLO1-LOPME'  OR
               'ZTITRQS-UMTCU'  OR 'ZTITRQS-SETLR'  OR
               'ZTITRQS-REPTR'  OR
               'ZTITRQS-AKKUR' OR 'ZTITRQS-DMBTR' OR
               'ZTITRQS-HWAER'  OR
               'ZTITLO1-LSENO1' OR
               'ZTITPC1-PSBUS'  OR
               'ZTITPC1-PSPCD'  OR
               'ZTITRQS-DONGBO' OR   "동보전송여부
               'ZTITPC1-PSBNM' OR 'ZTITLO1-LOPME_TXT'.
            SCREEN-INPUT      =   C_CHAR0.
            SCREEN-INVISIBLE  =   C_CHAR1.
        ENDCASE.
      WHEN OTHERS.
    ENDCASE.
*> 선급금 %/유보금 %
    CASE SCREEN-NAME.
      WHEN 'ZTITRQK-RPRAT' OR
           'ZTITRQK-PPRAT'.
        SCREEN-INPUT      =   C_CHAR0.
        SCREEN-INVISIBLE  =   C_CHAR1.
    ENDCASE.

    IF ZTITRQS-PPAMT IS INITIAL.
      CASE SCREEN-NAME.
        WHEN 'ZTITRQS-PPAMT' OR 'ZTITRQS-SMAMT'.
          SCREEN-INPUT      =   C_CHAR0.
          SCREEN-INVISIBLE  =   C_CHAR1.
      ENDCASE.
    ENDIF.
*> 구매확인서일 경우만 환율입력토록 함.
    IF SCREEN-NAME     EQ 'ZTITRQS-WKURS'.
      IF G_DOCUMENT    EQ C_LC             AND
        ZTITRQK-REQTY EQ C_PU.
        SCREEN-INPUT      =   C_CHAR1.
      ELSE.
        SCREEN-INPUT      =   C_CHAR0.
      ENDIF.
      IF ZTITRQS-DOCST EQ C_CHARY OR
         ZTITRQS-DOCST EQ C_CHARO.
        SCREEN-INPUT      =   C_CHAR0.
      ENDIF.
      IF G_MODE EQ C_CHARS OR
         G_MODE EQ C_CHARA OR
         G_MODE EQ C_CHARD.
        SCREEN-INPUT      =   C_CHAR0.
      ENDIF.
    ENDIF.

*> 구매확인서일 경우.
    IF ZTITRQK-REQTY EQ C_PU.
      CASE SCREEN-NAME.
        WHEN 'ZTITRQK-OFFER' OR 'ZTITRQK-LIFRE' OR
             'ZTITRQS-ZTERM' OR 'ZTITRQS-INCO1' OR
             'ZTITRQK-ANBTY'.
          SCREEN-INPUT      =   C_CHAR0.

        WHEN 'ZTITRQS-DONGBO'.  "동보전송여부
          SCREEN-INPUT      =   C_CHAR1.
      ENDCASE.
    ENDIF.

*> 전신환 송금일 경우.
    IF ZTITRQK-REQTY EQ C_TT    AND
       SCREEN-NAME    EQ 'ZTITRQK-ANBTY'.
      SCREEN-INPUT   =   C_CHAR0.
    ENDIF.
    IF ZTITRQK-REQTY EQ C_TT .
      IF ZTITRQK-ANBTY EQ C_CHARB.
        IF SCREEN-NAME EQ 'ZTITRQK-RPAID'.
          SCREEN-INPUT     =   C_CHAR0.
          SCREEN-INVISIBLE =   C_CHAR1.
        ENDIF.
      ELSEIF ZTITRQK-ANBTY EQ C_CHARA.
        IF SCREEN-NAME EQ 'ZTITRQK-PPAID'.
          SCREEN-INPUT     =   C_CHAR0.
          SCREEN-INVISIBLE =   C_CHAR1.
        ENDIF.
      ENDIF.
    ENDIF.

*> 변경시 변경 항목 체크.
    IF ZTITRQS-AMDSQ EQ 0.
      CASE SCREEN-NAME.
        WHEN 'G_OPAMTX' OR 'G_EXDATX' OR
             'G_LSDATX' OR 'G_PARTYX' OR
             'G_TRANYX' OR 'G_FPORTX' OR
             'G_TPORTX' OR 'G_INCO1X' OR
             'G_FWDTYX' OR 'G_ZTERMX' OR
             'G_CTOCDX' OR 'G_INSYNX'.
          SCREEN-INVISIBLE = C_CHAR1.
        WHEN OTHERS.
      ENDCASE.
    ELSE.
*> 변경지시자.
      CASE SCREEN-NAME.
        WHEN 'ZTITRQS-OPAMT' OR 'G_OPAMTX'.
          PERFORM  SET_CHANGE_SYMBOLS_MODE USING ZTITRQS-OPAMTX.
        WHEN 'ZTITRQS-EXDAT' OR 'G_EXDATX'.
          PERFORM  SET_CHANGE_SYMBOLS_MODE USING ZTITRQS-EXDATX.
        WHEN 'ZTITRQS-LSDAT' OR 'G_LSDATX'.
          PERFORM  SET_CHANGE_SYMBOLS_MODE USING ZTITRQS-LSDATX.
        WHEN 'ZTITRQS-PARTY' OR 'G_PARTYX'.
          PERFORM  SET_CHANGE_SYMBOLS_MODE USING ZTITRQS-PARTYX.
        WHEN 'ZTITRQS-TRANY' OR 'G_TRANYX'.
          PERFORM  SET_CHANGE_SYMBOLS_MODE USING ZTITRQS-TRANYX.
        WHEN 'ZTITRQS-FLAND' OR 'ZTITRQS-FPORT' OR 'ZTITRQS-PLLOD'
                              OR 'G_FPORTX'.
          PERFORM  SET_CHANGE_SYMBOLS_MODE USING ZTITRQS-FPORTX.
        WHEN 'ZTITRQS-TLAND' OR 'ZTITRQS-TPORT' OR 'ZTITRQS-PLTRN'
                              OR 'G_TPORTX'.
          PERFORM  SET_CHANGE_SYMBOLS_MODE USING ZTITRQS-TPORTX.
        WHEN 'ZTITRQS-INCO1' OR 'G_INCO1X'.
          PERFORM  SET_CHANGE_SYMBOLS_MODE USING ZTITRQS-INCO1X.
        WHEN 'ZTITRQS-ZTERM' OR 'G_ZTERMX'.
          PERFORM  SET_CHANGE_SYMBOLS_MODE USING ZTITRQS-ZTERMX.
        WHEN 'ZTITRQS-FWDTY' OR 'G_FWDTYX'.
          PERFORM  SET_CHANGE_SYMBOLS_MODE USING ZTITRQS-FWDTYX.
        WHEN 'ZTITRQS-CTOCD' OR 'ZTITRQS-CTONM' OR 'G_CTOCDX'.
          PERFORM  SET_CHANGE_SYMBOLS_MODE USING ZTITRQS-CTOCDX.
        WHEN 'ZTITRQS-INSYN' OR 'G_INSYNX'.
          PERFORM  SET_CHANGE_SYMBOLS_MODE USING ZTITRQS-INSYNX.
      ENDCASE.
    ENDIF.
    IF ZTITRQK-REQTY EQ C_PU.
      CASE SCREEN-NAME.
        WHEN 'G_LSDATX' OR 'G_EXDATX' OR
             'G_FWDTYX' OR 'G_PARTYX' OR 'G_TRANYX'.
          SCREEN-INVISIBLE = C_CHAR1.
      ENDCASE.
    ENDIF.

    IF ZTITRQK-ANBTY     EQ C_CHARA AND
       ZTITRQK-REQTY     EQ C_TT.
      IF SCREEN-NAME      EQ 'ZTITRQS-ZTERM'.
        SCREEN-INPUT = C_CHAR0.
      ENDIF.
    ENDIF.

    IF G_MODE EQ C_CHARC OR
       G_MODE EQ C_CHARM.
      IF ZTITRQK-ANBTY     EQ C_CHARA AND
         ZTITRQK-REQTY     EQ C_TT.
        IF NOT ZTITRQS-LSDAT IS INITIAL.
          IF  SCREEN-NAME      EQ 'ZTITRQS-LSDAT'.
* ----> 사후송금건 유효기일 입력가능하도록 수정 By 김도훈 (050508)
*                                                 OR
*              screen-name      EQ 'ZTITRQS-EXDAT'.
* ----> End of Modification
            SCREEN-INPUT = C_CHAR0.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

*> 포워더 지정사용여부.
    IF SCREEN-NAME EQ 'ZTITRQK-FWDAS'.
      IF ZTITRQK-REQTY EQ C_LC OR
         ZTITRQK-REQTY EQ C_TT OR
         ZTITRQK-REQTY EQ C_DA OR
         ZTITRQK-REQTY EQ C_DP.
        IF ZTITIG00-FWDYN EQ C_TRUE.
          SCREEN-INVISIBLE = C_CHAR0.
          IF G_MODE EQ C_CHARC OR
             G_MODE EQ C_CHARM OR
             G_MODE EQ C_CHARY OR
             G_MODE EQ C_CHARO.
            SCREEN-INPUT     = C_CHAR1.
          ELSE.
            SCREEN-INPUT     = C_CHAR0.
          ENDIF.
        ELSE.
          SCREEN-INPUT     = C_CHAR0.
          SCREEN-INVISIBLE = C_CHAR1.
        ENDIF.
      ELSE.
        SCREEN-INPUT     = C_CHAR0.
        SCREEN-INVISIBLE = C_CHAR1.
      ENDIF.
    ENDIF.

    IF SCREEN-NAME EQ 'ZTITRQS-PAYCD'.
      SCREEN-INPUT      =   C_CHAR0.
      SCREEN-INVISIBLE  =   C_CHAR1.

*      IF ZTITRQK-REQTY EQ C_DA.
*        screen-invisible  =   c_char0.
*      ELSE.
*        screen-input      =   c_char0.
*        screen-invisible  =   c_char1.
*      ENDIF.
    ENDIF.
* 20060411 simcho by C2006040601000001033
    IF SCREEN-NAME EQ 'ZTITRQS-SETLR'.
      SCREEN-INPUT      =   C_CHAR1.
      SCREEN-INVISIBLE  =   C_CHAR0.
    ENDIF.
* end simcho by C2006040601000001033

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " change_field_visible_mode  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  HELP_PAYMENT_TERM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HELP_PAYMENT_TERM INPUT.

  LOOP AT SCREEN.
    IF SCREEN-NAME EQ 'ZTITRQS-ZTERM'.
      EXIT.
    ENDIF.
  ENDLOOP.

  PERFORM GET_F4_FOR_ZTERM_DYNPRO USING ZTITRQS-ZTERM.

ENDMODULE.                 " HELP_PAYMENT_TERM  INPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2216_init  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_2216_INIT OUTPUT.

  TC_2216-LINES = TC_2216-TOP_LINE + 5.

ENDMODULE.                 " tc_2216_init  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2216_move  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_2216_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TC_2216_WA TO ZTITLC2.
ENDMODULE.                 " tc_2216_move  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2216_get_lines  OUTPUT
*&---------------------------------------------------------------------*
MODULE TC_2216_GET_LINES OUTPUT.
  G_TC_2216_LINES = SY-LOOPC.
ENDMODULE.                 " tc_2216_get_lines  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  change_field_attribute_2100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_FIELD_ATTRIBUTE_2100 OUTPUT.

  LOOP AT  SCREEN .
*> 구매확인서 및 내국신용장일 경우 수입의뢰 종류를 수정할 수 없음.
    IF ZTITRQK-REQTY EQ C_LO OR
       ZTITRQK-REQTY EQ C_PU.
      SCREEN-INPUT = C_CHAR0.
      MODIFY SCREEN.
    ENDIF.
*> 위탁자재일 경우 수입의뢰 종류를 수정할 수 없음.
    IF ZTITRQS-SETYN EQ C_TRUE.
      SCREEN-INPUT = C_CHAR0.
      MODIFY SCREEN.
    ENDIF.
    IF ZTITRQK-REQTY EQ C_TT AND
       ZTITRQK-ANBTY EQ C_CHARA.
      SCREEN-INPUT = C_CHAR0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " change_field_attribute_2100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_status_7000  OUTPUT
*&---------------------------------------------------------------------*
*       Set GUI Status
*----------------------------------------------------------------------*
MODULE PBO_STATUS_7000 OUTPUT.

  SET PF-STATUS '7000'.
  IF SY-DYNNR EQ C_SCR7000.
    SET TITLEBAR  'T7000'.
  ELSE.
    SET TITLEBAR  'T8000'.
  ENDIF.

ENDMODULE.                 " pbo_status_7000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2123_init  OUTPUT
*&---------------------------------------------------------------------*
*  output module for tc 'TC_2123'. do not change this line!
*  copy ddic-table to itab
*----------------------------------------------------------------------*
MODULE TC_2123_INIT OUTPUT.
  IF G_TC_2123_COPIED IS INITIAL.
    G_TC_2123_COPIED = 'X'.
    REFRESH CONTROL 'TC_2123' FROM SCREEN '2123'.
  ENDIF.
ENDMODULE.                    "TC_2123_init OUTPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2123_move  OUTPUT
*&---------------------------------------------------------------------*
*  output module for tc 'TC_2123'. do not change this line!
*  move itab to dynpro
*----------------------------------------------------------------------*
MODULE TC_2123_MOVE OUTPUT.

  MOVE-CORRESPONDING : G_TC_2123_WA TO ZTITLC4,
                       G_TC_2123_WA TO ZTISLC04.

ENDMODULE.                    "TC_2123_move OUTPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2123_move  OUTPUT
*&---------------------------------------------------------------------*
*  output module for tc 'TC_2123'. do not change this line!
*  get lines of tablecontrol
*----------------------------------------------------------------------*
MODULE TC_2123_GET_LINES OUTPUT.

*  g_tc_2123_lines = sy-loopc.
  IF G_MODE EQ C_CHARS OR
     G_MODE EQ C_CHARD OR
     G_MODE EQ C_CHARG OR
     G_MODE EQ C_CHARA.
    DESCRIBE TABLE G_TC_2123_ITAB LINES G_LINE.     " LINE COUNT GET
    G_TC_2123_LINES = G_LINE.                       " LINE DEFINE
    TC_2123-LINES   = G_LINE.
  ELSE.
    DESCRIBE TABLE G_TC_2123_ITAB LINES G_LINE.     " LINE COUNT GET
    G_LINE = G_LINE + 20.
    G_TC_2123_LINES = G_LINE.                       " LINE DEFINE
    TC_2123-LINES   = G_LINE.
  ENDIF.

ENDMODULE.                    "TC_2123_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2123_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_2123_CHANGE_FIELD_ATTR OUTPUT.

  LOOP AT SCREEN.
    IF SCREEN-NAME EQ 'G_TC_2123_WA-FLAG'.
      SCREEN-INPUT = C_CHAR1.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " TC_2123_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2130_disable_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_2130_DISABLE_FIELD_ATTR OUTPUT.

  CHECK : G_MODE EQ C_CHARC OR
          G_MODE EQ C_CHARM .

  LOOP AT SCREEN.
    IF G_TC_2130_WA-NETPR IS INITIAL AND
       SCREEN-NAME        EQ 'ZTISRQIT-NETWR'.
      SCREEN-INPUT = C_CHAR0.
    ENDIF.

******************************************************
*  20080627 박혁세K - 수입개설시 수량조정 가능
******************************************************
*    IF ztitrqk-anbty     EQ c_chara AND
*       ztitrqk-reqty     EQ c_tt.
*      IF screen-name        EQ 'ZTISRQIT-RQMNG'.
*        screen-input = c_char0.
*      ENDIF.
*    ENDIF.
******************************************************


**> 금액수정 Setting에 따라서..
*    IF ztitig00-amtcc EQ c_false.
*      screen-input = c_char0.
*    ENDIF.
******************************************************
*  20070124 박혁세K - 수입개설시 정가 수정불가
******************************************************
    IF SCREEN-NAME EQ 'ZTISRQIT-NETWR'.
      SCREEN-INPUT = C_CHAR0.
    ENDIF.
******************************************************

    IF SCREEN-NAME EQ 'G_TC_2130_WA-FLAG'.
      SCREEN-INPUT     = C_CHAR1.
      SCREEN-INVISIBLE = C_CHAR0.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " TC_2130_disable_field_attr  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2124_init  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2124'. do not change this line!
*> copy ddic-table to itab
*&---------------------------------------------------------------------*
MODULE TC_2124_INIT OUTPUT.
  IF G_TC_2124_COPIED IS INITIAL.
*> copy ddic-table 'ZTITTT4'
*> into internal table 'g_TC_2124_itab'
*    SELECT * FROM ztittt4
*       INTO CORRESPONDING FIELDS
*       OF TABLE g_tc_2124_itab.
    G_TC_2124_COPIED = 'X'.
    REFRESH CONTROL 'TC_2124' FROM SCREEN '2124'.
  ENDIF.
ENDMODULE.                    "TC_2124_init OUTPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2124_move  OUTPUT
*&---------------------------------------------------------------------*
*> output module for tc 'TC_2124'. do not change this line!
*> move itab to dynpro
*&---------------------------------------------------------------------*
MODULE TC_2124_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TC_2124_WA TO ZTISTT4.
ENDMODULE.                    "TC_2124_move OUTPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2124_get_lines  OUTPUT
*&---------------------------------------------------------------------*
*&> output module for tc 'TC_2124'. do not change this line!
*&> get lines of tablecontrol
*&---------------------------------------------------------------------*
MODULE TC_2124_GET_LINES OUTPUT.

  DESCRIBE TABLE G_TC_2124_ITAB LINES G_LINE.     " LINE COUNT GET
  G_TC_2124_LINES = G_LINE.                       " LINE DEFINE
  TC_2124-LINES   = G_LINE.

ENDMODULE.                    "TC_2124_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2124_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_2124_CHANGE_FIELD_ATTR OUTPUT.

  LOOP AT  SCREEN .
    CLEAR G_FIELDGROUP.
    CONCATENATE SCREEN-GROUP1 SCREEN-GROUP2
                SCREEN-GROUP3 SCREEN-GROUP4
           INTO G_FIELDGROUP.

    SEARCH G_FIELDGROUP FOR G_MODE.
    IF SY-SUBRC <> 0.
      SCREEN-INPUT = C_CHAR0.
    ELSE.
      SCREEN-INPUT = C_CHAR1.
    ENDIF.

    IF ZTITRQK-IMPTY EQ C_CHARA OR
       ZTITRQK-IMPTY EQ C_CHARB.
      IF SCREEN-NAME  EQ 'ZTITTT1-IMACD' AND
         SCREEN-INPUT EQ C_CHAR1.
        SCREEN-INPUT = C_CHAR0.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " tc_2124_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2124_change_col_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_2124_CHANGE_COL_ATTR OUTPUT.

*GLCNO
*IVNUM
*BLNUM
*CDCNO
*NEGEN
*
  LOOP AT TC_2124-COLS INTO GS_COLS.
    G_TABIX = SY-TABIX.
    IF ZTITTT1-PAYRS EQ 'ACB'.     ">수입대금결제..
      CASE  GS_COLS-SCREEN-NAME.
        WHEN 'ZTISTT4-NGBEN' OR 'ZTISTT4-GLCNO' OR 'ZTISTT4-IVNUM'.
          GS_COLS-INVISIBLE = C_CHAR1.
        WHEN OTHERS.
          GS_COLS-INVISIBLE = C_CHAR0.
      ENDCASE.
      MODIFY TC_2124-COLS  INDEX G_TABIX FROM GS_COLS.
    ELSEIF ZTITTT1-PAYRS EQ 'ACE'. ">중계무역일 경우.
      CASE  GS_COLS-SCREEN-NAME.
        WHEN 'ZTISTT4-CDCNO'.
          GS_COLS-INVISIBLE = C_CHAR1.
        WHEN OTHERS.
          GS_COLS-INVISIBLE = C_CHAR0.
      ENDCASE.
      MODIFY TC_2124-COLS  INDEX G_TABIX FROM GS_COLS.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " tc_2124_change_col_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SCR2215_SUB1_1_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR2215_SUB1_1_SUBSCREEN OUTPUT.

    G_CALL_PROG          = C_TEXT_PROG.
    G_TABSTRIP-PROG      = C_TEXT_PROG.
    G_TEXTID             = C_CHARB.

*> 텍스트 데이타 Put
    CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

    READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
    IF SY-SUBRC EQ 0.
      IT_TEXTTYPES[]       = GT_CONTROL-TEXTTYPES[].
      IT_ALL_LINES[]       = GT_CONTROL-TEXTLINES[].
      G_TEXTOBJECT         = GT_CONTROL-OBJECT.
      G_CALL_SUBSCREEN     = GT_CONTROL-DYNNR.
      G_TABSTRIP-SUBSCREEN = GT_CONTROL-DYNNR.
    ENDIF.

    CALL FUNCTION 'Z_TS_TEXT_EXP_SUBSCREEN_SINGLE'
      EXPORTING
        IM_TEXTOBJECT = G_TEXTOBJ
        IM_TEXTID     = G_TEXTID
      TABLES
        IMT_TEXTTYPES = IT_TEXTTYPES
        IMT_TEXTLINES = IT_ALL_LINES.

ENDMODULE.                 " PBO_SCR2215_SUB1_1_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SCR2215_SUB1_2_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR2215_SUB1_2_SUBSCREEN OUTPUT.

    G_CALL_PROG          = C_TEXT_PROG.
    G_TABSTRIP-PROG      = C_TEXT_PROG.
    G_TEXTID             = C_CHARC.

*> 텍스트 데이타 Put
    CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

    READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
    IF SY-SUBRC EQ 0.
      IT_TEXTTYPES[]       = GT_CONTROL-TEXTTYPES[].
      IT_ALL_LINES[]       = GT_CONTROL-TEXTLINES[].
      G_TEXTOBJECT         = GT_CONTROL-OBJECT.
      G_CALL_SUBSCREEN     = GT_CONTROL-DYNNR.
      G_TABSTRIP-SUBSCREEN = GT_CONTROL-DYNNR.
    ENDIF.

    CALL FUNCTION 'Z_TS_TEXT_EXP_SUBSCREEN_SINGLE'
      EXPORTING
        IM_TEXTOBJECT = G_TEXTOBJ
        IM_TEXTID     = G_TEXTID
      TABLES
        IMT_TEXTTYPES = IT_TEXTTYPES
        IMT_TEXTLINES = IT_ALL_LINES.

ENDMODULE.                 " PBO_SCR2215_SUB1_2_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SCR2215_SUB1_3_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR2215_SUB1_3_SUBSCREEN OUTPUT.

    G_CALL_PROG          = C_TEXT_PROG.
    G_TABSTRIP-PROG      = C_TEXT_PROG.
    G_TEXTID             = C_CHARD.

*> 텍스트 데이타 Put
    CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

    READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
    IF SY-SUBRC EQ 0.
      IT_TEXTTYPES[]       = GT_CONTROL-TEXTTYPES[].
      IT_ALL_LINES[]       = GT_CONTROL-TEXTLINES[].
      G_TEXTOBJECT         = GT_CONTROL-OBJECT.
      G_CALL_SUBSCREEN     = GT_CONTROL-DYNNR.
      G_TABSTRIP-SUBSCREEN = GT_CONTROL-DYNNR.
    ENDIF.

    CALL FUNCTION 'Z_TS_TEXT_EXP_SUBSCREEN_SINGLE'
      EXPORTING
        IM_TEXTOBJECT = G_TEXTOBJ
        IM_TEXTID     = G_TEXTID
      TABLES
        IMT_TEXTTYPES = IT_TEXTTYPES
        IMT_TEXTLINES = IT_ALL_LINES.

ENDMODULE.                 " PBO_SCR2215_SUB1_3_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SCR2215_SUB2_1_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR2215_SUB2_1_SUBSCREEN OUTPUT.

    G_CALL_PROG          = C_TEXT_PROG.
    G_TABSTRIP-PROG      = C_TEXT_PROG.
    G_TEXTID             = C_CHARE.

*> 텍스트 데이타 Put
    CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

    READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
    IF SY-SUBRC EQ 0.
      IT_TEXTTYPES[]       = GT_CONTROL-TEXTTYPES[].
      IT_ALL_LINES[]       = GT_CONTROL-TEXTLINES[].
      G_TEXTOBJECT         = GT_CONTROL-OBJECT.
      G_CALL_SUBSCREEN     = GT_CONTROL-DYNNR.
      G_TABSTRIP-SUBSCREEN = GT_CONTROL-DYNNR.
    ENDIF.

    CALL FUNCTION 'Z_TS_TEXT_EXP_SUBSCREEN_SINGLE'
      EXPORTING
        IM_TEXTOBJECT = G_TEXTOBJ
        IM_TEXTID     = G_TEXTID
      TABLES
        IMT_TEXTTYPES = IT_TEXTTYPES
        IMT_TEXTLINES = IT_ALL_LINES.

ENDMODULE.                 " PBO_SCR2215_SUB2_1_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SCR2215_SUB2_2_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR2215_SUB2_2_SUBSCREEN OUTPUT.

    G_CALL_PROG          = C_TEXT_PROG.
    G_TABSTRIP-PROG      = C_TEXT_PROG.
    G_TEXTID             = C_CHARF.

*> 텍스트 데이타 Put
    CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

    READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
    IF SY-SUBRC EQ 0.
      IT_TEXTTYPES[]       = GT_CONTROL-TEXTTYPES[].
      IT_ALL_LINES[]       = GT_CONTROL-TEXTLINES[].
      G_TEXTOBJECT         = GT_CONTROL-OBJECT.
      G_CALL_SUBSCREEN     = GT_CONTROL-DYNNR.
      G_TABSTRIP-SUBSCREEN = GT_CONTROL-DYNNR.
    ENDIF.

    CALL FUNCTION 'Z_TS_TEXT_EXP_SUBSCREEN_SINGLE'
      EXPORTING
        IM_TEXTOBJECT = G_TEXTOBJ
        IM_TEXTID     = G_TEXTID
      TABLES
        IMT_TEXTTYPES = IT_TEXTTYPES
        IMT_TEXTLINES = IT_ALL_LINES.

ENDMODULE.                 " PBO_SCR2215_SUB2_2_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SCR2215_SUB2_3_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR2215_SUB2_3_SUBSCREEN OUTPUT.

    G_CALL_PROG          = C_TEXT_PROG.
    G_TABSTRIP-PROG      = C_TEXT_PROG.
    G_TEXTID             = C_CHARG.

*> 텍스트 데이타 Put
    CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

    READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
    IF SY-SUBRC EQ 0.
      IT_TEXTTYPES[]       = GT_CONTROL-TEXTTYPES[].
      IT_ALL_LINES[]       = GT_CONTROL-TEXTLINES[].
      G_TEXTOBJECT         = GT_CONTROL-OBJECT.
      G_CALL_SUBSCREEN     = GT_CONTROL-DYNNR.
      G_TABSTRIP-SUBSCREEN = GT_CONTROL-DYNNR.
    ENDIF.

    CALL FUNCTION 'Z_TS_TEXT_EXP_SUBSCREEN_SINGLE'
      EXPORTING
        IM_TEXTOBJECT = G_TEXTOBJ
        IM_TEXTID     = G_TEXTID
      TABLES
        IMT_TEXTTYPES = IT_TEXTTYPES
        IMT_TEXTLINES = IT_ALL_LINES.

ENDMODULE.                 " PBO_SCR2215_SUB2_3_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SCR2215_SUB3_1_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR2215_SUB3_1_SUBSCREEN OUTPUT.

    G_CALL_PROG          = C_TEXT_PROG.
    G_TABSTRIP-PROG      = C_TEXT_PROG.
    G_TEXTID             = C_CHARH.

*> 텍스트 데이타 Put
    CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

    READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
    IF SY-SUBRC EQ 0.
      IT_TEXTTYPES[]       = GT_CONTROL-TEXTTYPES[].
      IT_ALL_LINES[]       = GT_CONTROL-TEXTLINES[].
      G_TEXTOBJECT         = GT_CONTROL-OBJECT.
      G_CALL_SUBSCREEN     = GT_CONTROL-DYNNR.
      G_TABSTRIP-SUBSCREEN = GT_CONTROL-DYNNR.
    ENDIF.

    CALL FUNCTION 'Z_TS_TEXT_EXP_SUBSCREEN_SINGLE'
      EXPORTING
        IM_TEXTOBJECT = G_TEXTOBJ
        IM_TEXTID     = G_TEXTID
      TABLES
        IMT_TEXTTYPES = IT_TEXTTYPES
        IMT_TEXTLINES = IT_ALL_LINES.

ENDMODULE.                 " PBO_SCR2215_SUB3_1_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SCR2215_SUB3_2_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR2215_SUB3_2_SUBSCREEN OUTPUT.

    G_CALL_PROG          = C_TEXT_PROG.
    G_TABSTRIP-PROG      = C_TEXT_PROG.
    G_TEXTID             = C_CHARI.

*> 텍스트 데이타 Put
    CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

    READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
    IF SY-SUBRC EQ 0.
      IT_TEXTTYPES[]       = GT_CONTROL-TEXTTYPES[].
      IT_ALL_LINES[]       = GT_CONTROL-TEXTLINES[].
      G_TEXTOBJECT         = GT_CONTROL-OBJECT.
      G_CALL_SUBSCREEN     = GT_CONTROL-DYNNR.
      G_TABSTRIP-SUBSCREEN = GT_CONTROL-DYNNR.
    ENDIF.

    CALL FUNCTION 'Z_TS_TEXT_EXP_SUBSCREEN_SINGLE'
      EXPORTING
        IM_TEXTOBJECT = G_TEXTOBJ
        IM_TEXTID     = G_TEXTID
      TABLES
        IMT_TEXTTYPES = IT_TEXTTYPES
        IMT_TEXTLINES = IT_ALL_LINES.

ENDMODULE.                 " PBO_SCR2215_SUB3_2_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SCR2215_SUB3_3_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR2215_SUB3_3_SUBSCREEN OUTPUT.

    G_CALL_PROG          = C_TEXT_PROG.
    G_TABSTRIP-PROG      = C_TEXT_PROG.
    G_TEXTID             = C_CHARJ.

*> 텍스트 데이타 Put
    CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

    READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
    IF SY-SUBRC EQ 0.
      IT_TEXTTYPES[]       = GT_CONTROL-TEXTTYPES[].
      IT_ALL_LINES[]       = GT_CONTROL-TEXTLINES[].
      G_TEXTOBJECT         = GT_CONTROL-OBJECT.
      G_CALL_SUBSCREEN     = GT_CONTROL-DYNNR.
      G_TABSTRIP-SUBSCREEN = GT_CONTROL-DYNNR.
    ENDIF.

    CALL FUNCTION 'Z_TS_TEXT_EXP_SUBSCREEN_SINGLE'
      EXPORTING
        IM_TEXTOBJECT = G_TEXTOBJ
        IM_TEXTID     = G_TEXTID
      TABLES
        IMT_TEXTTYPES = IT_TEXTTYPES
        IMT_TEXTLINES = IT_ALL_LINES.

ENDMODULE.                 " PBO_SCR2215_SUB3_3_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SCR2215_SUB4_1_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR2215_SUB4_1_SUBSCREEN OUTPUT.

    G_CALL_PROG          = C_TEXT_PROG.
    G_TABSTRIP-PROG      = C_TEXT_PROG.
    G_TEXTID             = C_CHARK.

*> 텍스트 데이타 Put
    CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

    READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
    IF SY-SUBRC EQ 0.
      IT_TEXTTYPES[]       = GT_CONTROL-TEXTTYPES[].
      IT_ALL_LINES[]       = GT_CONTROL-TEXTLINES[].
      G_TEXTOBJECT         = GT_CONTROL-OBJECT.
      G_CALL_SUBSCREEN     = GT_CONTROL-DYNNR.
      G_TABSTRIP-SUBSCREEN = GT_CONTROL-DYNNR.
    ENDIF.

    CALL FUNCTION 'Z_TS_TEXT_EXP_SUBSCREEN_SINGLE'
      EXPORTING
        IM_TEXTOBJECT = G_TEXTOBJ
        IM_TEXTID     = G_TEXTID
      TABLES
        IMT_TEXTTYPES = IT_TEXTTYPES
        IMT_TEXTLINES = IT_ALL_LINES.

ENDMODULE.                 " PBO_SCR2215_SUB4_1_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SCR2215_SUB4_2_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR2215_SUB4_2_SUBSCREEN OUTPUT.

    G_CALL_PROG          = C_TEXT_PROG.
    G_TABSTRIP-PROG      = C_TEXT_PROG.
    G_TEXTID             = C_CHARL.

*> 텍스트 데이타 Put
    CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

    READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
    IF SY-SUBRC EQ 0.
      IT_TEXTTYPES[]       = GT_CONTROL-TEXTTYPES[].
      IT_ALL_LINES[]       = GT_CONTROL-TEXTLINES[].
      G_TEXTOBJECT         = GT_CONTROL-OBJECT.
      G_CALL_SUBSCREEN     = GT_CONTROL-DYNNR.
      G_TABSTRIP-SUBSCREEN = GT_CONTROL-DYNNR.
    ENDIF.

    CALL FUNCTION 'Z_TS_TEXT_EXP_SUBSCREEN_SINGLE'
      EXPORTING
        IM_TEXTOBJECT = G_TEXTOBJ
        IM_TEXTID     = G_TEXTID
      TABLES
        IMT_TEXTTYPES = IT_TEXTTYPES
        IMT_TEXTLINES = IT_ALL_LINES.

ENDMODULE.                 " PBO_SCR2215_SUB4_2_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SCR2215_SUB4_3_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR2215_SUB4_3_SUBSCREEN OUTPUT.

    G_CALL_PROG          = C_TEXT_PROG.
    G_TABSTRIP-PROG      = C_TEXT_PROG.
    G_TEXTID             = C_CHARM.

*> 텍스트 데이타 Put
    CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

    READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
    IF SY-SUBRC EQ 0.
      IT_TEXTTYPES[]       = GT_CONTROL-TEXTTYPES[].
      IT_ALL_LINES[]       = GT_CONTROL-TEXTLINES[].
      G_TEXTOBJECT         = GT_CONTROL-OBJECT.
      G_CALL_SUBSCREEN     = GT_CONTROL-DYNNR.
      G_TABSTRIP-SUBSCREEN = GT_CONTROL-DYNNR.
    ENDIF.

    CALL FUNCTION 'Z_TS_TEXT_EXP_SUBSCREEN_SINGLE'
      EXPORTING
        IM_TEXTOBJECT = G_TEXTOBJ
        IM_TEXTID     = G_TEXTID
      TABLES
        IMT_TEXTTYPES = IT_TEXTTYPES
        IMT_TEXTLINES = IT_ALL_LINES.

ENDMODULE.                 " PBO_SCR2215_SUB4_3_SUBSCREEN  OUTPUT
