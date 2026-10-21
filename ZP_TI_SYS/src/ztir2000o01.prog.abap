
************************************************************************
* Title         :  ZTIR0000O01                                         *
*                                                                      *
* Description   : 수입 B/L 관리 PBO Include                            *
*                                                                      *
* Creation Date : 2003/07/11                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* 2010.02.22   MMB03            C20100217_12482  구매개선
*----------------------------------------------------------------------*

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

  MOVE-CORRESPONDING G_TC_2130_WA TO ZTISBLIT.

ENDMODULE.                 " tc_2130_move  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_get_lines  OUTPUT
*&---------------------------------------------------------------------*
MODULE TC_2130_GET_LINES OUTPUT.

  IF ZTITBLK-BLDTY EQ C_CHARO. ">OFE 자재일 경우.
*     ZTITBLK-bldty EQ c_chara.    ">사후송금일 경우.
    DESCRIBE TABLE IT_TAB  LINES G_LINE.            " LINE COUNT GET
    G_TC_2130_LINES = G_LINE.                       " LINE DEFINE
    TC_2130-LINES = G_LINE.
  ELSE.
    IF G_MODE EQ C_CHARC OR
       G_MODE EQ C_CHARM.
      DESCRIBE TABLE IT_TAB  LINES G_LINE.              " LINE COUNT GET
      G_LINE = G_LINE + 20.
      G_TC_2130_LINES = G_LINE.                         " LINE DEFINE
      TC_2130-LINES = G_LINE.
    ELSE.
      DESCRIBE TABLE IT_TAB  LINES G_LINE.            " LINE COUNT GET
      G_TC_2130_LINES = G_LINE.                       " LINE DEFINE
      TC_2130-LINES = G_LINE.
    ENDIF.
  ENDIF.

  G_TC_2130_LINES = SY-LOOPC.

  G_OLD_TOP_LINE  = TC_2130-TOP_LINE.

ENDMODULE.                 " tc_2130_get_lines  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
MODULE TC_2130_CHANGE_FIELD_ATTR OUTPUT.

  LOOP AT SCREEN.
*> 생성/변경 모드가 아닐 경우.
    IF NOT ( G_MODE EQ C_CHARC OR
             G_MODE EQ C_CHARM ) AND
       NOT ( SCREEN-NAME EQ 'G_TC_2130_WA-FLAG' ).
      SCREEN-INPUT = C_CHAR0.
    ENDIF.
    IF SCREEN-NAME EQ 'ZTISBLIT-NDFTY'.
      IF ZTITBLK-BLDTY EQ C_CHARO. "OR
*         ZTITBLK-bldty EQ c_chara.
        SCREEN-INPUT = C_CHAR0.
      ENDIF.
    ENDIF.

    IF NOT ( G_TC_2130_WA-EBELN IS INITIAL AND
             G_TC_2130_WA-REQNO IS INITIAL AND
             G_TC_2130_WA-RSNUM IS INITIAL ).
      CASE SCREEN-NAME.
********************************************************************
* 20060727 simcho by 박준용K
********************************************************************
        WHEN 'ZTISBLIT-BLMNG'.

          IF SY-TCODE = 'ZTIT202'.
            CLEAR ZTITIVP.      " [Import] 상업송장 Items table
            DATA LV_IVONO LIKE ZTITIVP-IVONO.
            SELECT SINGLE IVONO INTO LV_IVONO
              FROM ZTITIVP
             WHERE IBLNO = ZTISSCRCOM-IBLNO.

            IF SY-SUBRC = 0.
              CLEAR ZTITIVK.
              SELECT SINGLE IVONO INTO LV_IVONO
                FROM ZTITIVK
               WHERE IVONO = LV_IVONO
                 AND LIVST = 'P'. "전기완료

              IF SY-SUBRC = 0.
                SCREEN-INPUT      =   C_CHAR0.
              ELSE.
                SCREEN-INPUT      =   C_CHAR1.
              ENDIF.
            ENDIF.
          ENDIF.
********************************************************************
* end simcho
********************************************************************
************************************************************************
* 20060811 simcho by 박준용K
************************************************************************
        WHEN 'ZTISBLIT-NETPR' OR 'ZTISBLIT-REFWR'.  "단가,송장금액

          IF SY-TCODE = 'ZTIT202'.
            CLEAR ZTITIVP.      " [Import] 상업송장 Items table
*            DATA lv_ivono LIKE ztitivp-ivono.
            SELECT SINGLE IVONO INTO LV_IVONO
              FROM ZTITIVP
             WHERE IBLNO = ZTISSCRCOM-IBLNO.

            IF SY-SUBRC = 0.
              CLEAR ZTITIVK.
              SELECT SINGLE IVONO INTO LV_IVONO
                FROM ZTITIVK
               WHERE IVONO = LV_IVONO
                 AND LIVST = 'P'. "전기완료

              IF SY-SUBRC = 0.
                SCREEN-INPUT      =   C_CHAR0.
              ELSE.
                SCREEN-INPUT      =   C_CHAR1.
              ENDIF.
            ENDIF.
          ENDIF.
************************************************************************
* end simcho
************************************************************************

        WHEN 'ZTISBLIT-NDFTY' OR 'ZTISBLIT-MEINS' OR
             'ZTISBLIT-MATNR' OR 'ZTISBLIT-TXZ01' OR
             'ZTISBLIT-PEINH'.
          SCREEN-INPUT = C_CHAR0.
        WHEN 'ZTISBLIT-NETPR'.
          IF G_TC_2130_WA-REPOS EQ C_FALSE.
            IF ( G_MODE EQ C_CHARC OR
                 G_MODE EQ C_CHARM OR
                 G_MODE EQ C_CHARY ).
              SCREEN-INPUT = C_CHAR1.
            ELSE.
              SCREEN-INPUT = C_CHAR0.
            ENDIF.
          ENDIF.
        WHEN 'ZTISBLIT-WERKS'.
          IF NOT G_TC_2130_WA-WERKS IS INITIAL.
            SCREEN-INPUT = C_CHAR0.
          ENDIF.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.
*> 구매오더 존재할 경우.
    IF NOT G_TC_2130_WA-EBELN IS INITIAL.
      CASE SCREEN-NAME.
        WHEN 'ZTISBLIT-PEINH'.
          SCREEN-INPUT = C_CHAR0.
      ENDCASE.
    ENDIF.

    IF SCREEN-NAME EQ 'ZTISBLIT-STAWN' AND
       ( G_MODE EQ C_CHARC OR
         G_MODE EQ C_CHARM OR
         G_MODE EQ C_CHARY ).
      SCREEN-INPUT = C_CHAR1.
    ENDIF.

    IF SCREEN-NAME EQ 'G_TC_2130_WA-FLAG'.
      SCREEN-INPUT = C_CHAR1.
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


  DATA  : LT_TAB LIKE ZTISBLIT,
          LF_VBELN_IN.

  LOOP AT IT_TAB INTO LT_TAB WHERE VBELN_IN IS NOT INITIAL.
    LF_VBELN_IN = 'X'.
    EXIT.
  ENDLOOP.


  LOOP AT TC_2130-COLS INTO GS_COLS.
    G_TABIX = SY-TABIX.
    CASE ZTITBLK-BLDTY.
      WHEN C_CHARO.
        CASE  GS_COLS-SCREEN-NAME.
          WHEN 'ZTISBLIT-RSNUM' OR 'ZTISBLIT-RSPOS' OR
               'ZTISBLIT-RSART' OR 'ZTISBLIT-BDMNG'.
            GS_COLS-INVISIBLE = C_CHAR0.
            MODIFY TC_2130-COLS  INDEX G_TABIX FROM GS_COLS.
          WHEN 'ZTISBLIT-EBELN' OR 'ZTISBLIT-EBELP'  OR
               'ZTISBLIT-MENGE' OR
               'ZTISBLIT-REQNO' OR 'ZTISBLIT-REQIT'  OR
               'ZTISBLIT-RQMNG' OR 'ZTISBLIT-EEIND'.
            GS_COLS-INVISIBLE = C_CHAR1.
            MODIFY TC_2130-COLS  INDEX G_TABIX FROM GS_COLS.
          WHEN OTHERS.
            GS_COLS-INVISIBLE = C_CHAR0.
            MODIFY TC_2130-COLS  INDEX G_TABIX FROM GS_COLS.
        ENDCASE.
      WHEN C_CHARA. "사후송금인 경우
        CASE  GS_COLS-SCREEN-NAME.
          WHEN 'ZTISBLIT-RSNUM' OR 'ZTISBLIT-RSPOS' OR
               'ZTISBLIT-RSART' OR 'ZTISBLIT-BDMNG' OR
               'ZTISBLIT-REQNO' OR 'ZTISBLIT-REQIT' OR
               'ZTISBLIT-RQMNG'.
            GS_COLS-INVISIBLE = C_CHAR1.
            MODIFY TC_2130-COLS  INDEX G_TABIX FROM GS_COLS.

          WHEN 'ZTISBLIT-EBELN' OR 'ZTISBLIT-EBELP'  OR
               'ZTISBLIT-MENGE'.
            GS_COLS-INVISIBLE = C_CHAR0.
            MODIFY TC_2130-COLS  INDEX G_TABIX FROM GS_COLS.

          WHEN OTHERS.
            GS_COLS-INVISIBLE = C_CHAR0.
            MODIFY TC_2130-COLS  INDEX G_TABIX FROM GS_COLS.
        ENDCASE.
      WHEN C_CHARS.
        CASE  GS_COLS-SCREEN-NAME.
          WHEN 'ZTISBLIT-RSNUM' OR 'ZTISBLIT-RSPOS' OR
               'ZTISBLIT-RSART' OR 'ZTISBLIT-BDMNG' OR
               'ZTISBLIT-REQNO' OR 'ZTISBLIT-REQIT' OR
               'ZTISBLIT-RQMNG'.
*               'ZTISBLIT-EBELN' OR 'ZTISBLIT-EBELP'  OR
*               'ZTISBLIT-MENGE'.
            GS_COLS-INVISIBLE = C_CHAR1.
            MODIFY TC_2130-COLS  INDEX G_TABIX FROM GS_COLS.
        ENDCASE.
      WHEN OTHERS.
        CASE  GS_COLS-SCREEN-NAME.
          WHEN 'ZTISBLIT-RSNUM' OR 'ZTISBLIT-RSPOS' OR
               'ZTISBLIT-RSART' OR 'ZTISBLIT-BDMNG'.
            GS_COLS-INVISIBLE = C_CHAR1.
            MODIFY TC_2130-COLS  INDEX G_TABIX FROM GS_COLS.
          WHEN OTHERS.
            GS_COLS-INVISIBLE = C_CHAR0.
            MODIFY TC_2130-COLS  INDEX G_TABIX FROM GS_COLS.
        ENDCASE.

    ENDCASE.
*    if gs_cols-screen-name eq 'ZTISBLIT-PPAMT' OR
*       gs_cols-screen-name EQ 'ZTISBLIT-NETWR'.
*      gs_cols-invisible = c_char1.
*      MODIFY tc_2130-cols  INDEX g_tabix FROM gs_cols.
*    ENDIF.


    IF GS_COLS-SCREEN-NAME EQ 'ZTISBLIT-VBELN_IN'.
      IF LF_VBELN_IN IS NOT INITIAL.
        GS_COLS-INVISIBLE = C_CHAR0.
      ELSE.
        GS_COLS-INVISIBLE = C_CHAR1.
      ENDIF.
      MODIFY TC_2130-COLS  INDEX G_TABIX FROM GS_COLS.
    ENDIF.

*-<< 기능개선 XXXXX - 원산지 증명서 추가
    IF GS_COLS-SCREEN-NAME EQ 'ZTISBLIT-ZCOTY'.
      IF ZTITBLK-BUKRS EQ '1000'.
        GS_COLS-INVISIBLE = C_CHAR0.
      ELSE.
        GS_COLS-INVISIBLE = C_CHAR1.
      ENDIF.
      MODIFY TC_2130-COLS  INDEX G_TABIX FROM GS_COLS.
    ENDIF.
*->> 기능개선 XXXXX


*-[XXXXX] 엠트론한정 조회, 사후개설인 경우
*  개설번호 송장번호 표시
   IF GF_RQIV_CHK IS NOT INITIAL.
      IF GS_COLS-SCREEN-NAME EQ 'ZTISBLIT-REQNO'.
         GS_COLS-INVISIBLE = C_CHAR0.
      ENDIF.

      IF GS_COLS-SCREEN-NAME EQ  'ZTISBLIT-IVONO'.
         GS_COLS-INVISIBLE = C_CHAR0.
      ENDIF.
      MODIFY TC_2130-COLS  INDEX G_TABIX FROM GS_COLS.

    ELSE.
      IF GS_COLS-SCREEN-NAME EQ  'ZTISBLIT-IVONO'.
         GS_COLS-INVISIBLE = C_CHAR1.
         MODIFY TC_2130-COLS  INDEX G_TABIX FROM GS_COLS.
      ENDIF.

    ENDIF.

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
*&      Module  pbo_scr2210_sub0_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE PBO_SCR2210_SUB0_SUBSCREEN OUTPUT.

*  g_call_prog        =  c_common_prog.
  G_CALL_PROG        =  SY-CPROG.
  G_CALL_SUBSCREEN   =  C_SCR2211.

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
MODULE PBO_SCR2210_SUB1_SUBSCREEN OUTPUT.

*  g_call_prog        =  c_common_prog.
  G_CALL_PROG        =  SY-CPROG.
  G_CALL_SUBSCREEN   =  C_SCR2212.

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
MODULE PBO_SCR2210_SUB2_SUBSCREEN OUTPUT.

*  g_call_prog        =  c_common_prog.
  G_CALL_PROG        =  SY-CPROG.
  G_CALL_SUBSCREEN   =  C_SCR2213.

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
MODULE PBO_SCR2210_SUB3_SUBSCREEN OUTPUT.

*  g_call_prog        =  c_common_prog.
  G_CALL_PROG        =  SY-CPROG.
  G_CALL_SUBSCREEN   =  C_SCR2214.

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
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " change_EDI_field_attr  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  pbo_scr2215_sub0_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE PBO_SCR2215_SUB0_SUBSCREEN OUTPUT.

  G_CALL_PROG        =  SY-CPROG.
  G_CALL_SUBSCREEN   =  C_SCR2214.

ENDMODULE.                 " pbo_scr2215_sub0_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2215_sub1_subscreen  OUTPUT
*&---------------------------------------------------------------------*
MODULE PBO_SCR2215_SUB1_SUBSCREEN OUTPUT.

  G_CALL_PROG        =  SY-CPROG.
  G_CALL_SUBSCREEN   =  C_SCR2216.

ENDMODULE.                 " pbo_scr2215_sub1_subscreen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  change_field_visible_mode  OUTPUT
*&---------------------------------------------------------------------*
*       업무별로 화면상에 필드를 visible/Invisible 함.
*----------------------------------------------------------------------*
MODULE CHANGE_FIELD_VISIBLE_MODE OUTPUT.

  LOOP AT SCREEN.

    CASE G_MODE.
*> 생성/변경시.
      WHEN C_CHARC OR C_CHARM.
        IF ZTITBLK-BLDTY EQ C_CHARS OR
           ZTITBLK-BLDTY EQ C_CHARO.
          CASE SCREEN-NAME.
            WHEN 'ZTITBLK-WAERS' OR 'ZTITBLK-BUKRS'.
              SCREEN-INPUT      =   C_CHAR1.
              SCREEN-INVISIBLE  =   C_CHAR0.
            WHEN 'ZTITBLK-RTCHG'.
              SCREEN-INPUT      =   C_CHAR0.
              SCREEN-INVISIBLE  =   C_CHAR1.
          ENDCASE.
        ENDIF.
************************************************************************
*-> 기능개선 99963 - B/L 운임 수기입력란 조회시 안보이게함
************************************************************************
      WHEN C_CHARS.
*        IF SCREEN-NAME EQ 'GV_SUGI'.
*          SCREEN-INPUT      =   C_CHAR0.
*          SCREEN-INVISIBLE  =   C_CHAR1.
*        ENDIF.
************************************************************************
    ENDCASE.

    IF ZTITBLK-PPAMT IS INITIAL.
      CASE SCREEN-NAME.
*        WHEN 'ZTITBLK-PPAMT' OR 'ZTITBLK-SMAMT'.
        WHEN 'ZTITBLK-PPAMT'.
          SCREEN-INPUT      =   C_CHAR0.
*          screen-invisible  =   c_char1.
************************************************************************
* 20060727 simcho by 박준용K
************************************************************************
        WHEN 'ZTITBLK-SMAMT'.

          IF SY-TCODE = 'ZTIT202'.
            CLEAR ZTITIVP.      " [Import] 상업송장 Items table
*            DATA lv_ivono LIKE ztitivp-ivono.
            SELECT SINGLE IVONO INTO LV_IVONO
              FROM ZTITIVP
             WHERE IBLNO = ZTISSCRCOM-IBLNO.

            IF SY-SUBRC = 0.
              CLEAR ZTITIVK.
              SELECT SINGLE IVONO INTO LV_IVONO
                FROM ZTITIVK
               WHERE IVONO = LV_IVONO
                 AND LIVST = 'P'. "전기완료

              IF SY-SUBRC = 0.
                SCREEN-INPUT      =   C_CHAR0.
              ELSE.
                SCREEN-INPUT      =   C_CHAR1.
              ENDIF.
            ENDIF.
          ENDIF.
************************************************************************
* end simcho
************************************************************************
      ENDCASE.
    ENDIF.

    IF G_BLDTY     EQ C_CHARA OR
       G_BLDTY     EQ C_CHARO OR
       G_BLDTY     EQ C_CHARS.
      IF SCREEN-NAME EQ 'ZTITBLK-RTCHG'.
        SCREEN-INPUT      =   C_CHAR0.
        SCREEN-INVISIBLE  =   C_CHAR1.
      ENDIF.
    ENDIF.

*050302 jp, park 추가.
    IF G_REQTY   EQ C_TT OR
       G_REQTY   EQ C_DA OR
       G_REQTY   EQ C_DP .
      IF SCREEN-NAME EQ 'ZTITBLK-LGAYN'.
        SCREEN-INPUT      =   C_CHAR0.
      ENDIF.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " change_field_visible_mode  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2122_init  OUTPUT
*&---------------------------------------------------------------------*
* output module for tc 'TC_2122'. do not change this line!
* copy ddic-table to itab
*----------------------------------------------------------------------*
MODULE TC_2122_INIT OUTPUT.
  IF G_TC_2122_COPIED IS INITIAL.
    G_TC_2122_COPIED = 'X'.
    REFRESH CONTROL 'TC_2122' FROM SCREEN '2122'.
  ENDIF.
ENDMODULE.                    "TC_2122_init OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2122_move  OUTPUT
*&---------------------------------------------------------------------*
* output module for tc 'TC_2122'. do not change this line!
* move itab to dynpro
*----------------------------------------------------------------------*
MODULE TC_2122_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TC_2122_WA TO ZTITBLC.
ENDMODULE.                    "TC_2122_move OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2122_get_lines  OUTPUT
*&---------------------------------------------------------------------*
* output module for tc 'TC_2122'. do not change this line!
* get lines of tablecontrol
*----------------------------------------------------------------------*
MODULE TC_2122_GET_LINES OUTPUT.
  G_TC_2122_LINES = SY-LOOPC.
*  DESCRIBE TABLE g_TC_2122_itab LINES g_tc_2122_lines.
*  TC_2122-LINES        = g_tc_2122_lines.
*  TC_2122-CURRENT_LINE = g_tc_2122_lines.
*  TC_2122-TOP_LINE     = g_tc_2122_lines.
*
ENDMODULE.                    "TC_2122_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr0100_Import_memory  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR0100_IMPORT_MEMORY OUTPUT.

  IF SY-CALLD EQ C_TRUE.
**  CALL 'GET_PARAM_TCOD' ID 'PTCOD' FIELD g_tcode.
*    FREE MEMORY ID g_indxkey.
*
*    gs_indx-aedat = sy-datlo.
*    gs_indx-usera = sy-uname.
*
*    IMPORT g_tcode = g_tcode
*           FROM DATABASE indx(zm)  ID g_indxkey
*                                   TO gs_indx.
    IF SY-TCODE NE C_CREATE.
      G_TCODE = SY-TCODE.
    ENDIF.
    CASE G_TCODE.
      WHEN C_CREATE_D.  ">B/L Due List(기타)

      WHEN C_DUE_LIST_OFE.  ">OFE 자재 B/L Due List(위탁자재)
*        IMPORT it_resb  = it_resb
*               FROM DATABASE indx(zm)  ID g_indxkey
*                                       TO gs_indx.
        IF IT_RESB[] IS INITIAL.
          MESSAGE A003(OK).
        ENDIF.
        G_TCODE = C_CREATE.
        G_MODE  = C_CHARC.

      WHEN C_DUE_LIST_TT.  ">사후송금 자재 B/L Due List(위탁자재)
*        IMPORT it_ekpo  = it_ekpo
*               FROM DATABASE indx(zm)  ID g_indxkey
*                                       TO gs_indx.
        IF IT_EKPO[] IS INITIAL.
          MESSAGE A003(OK).
        ENDIF.
        G_TCODE = C_CREATE.
        G_MODE  = C_CHARC.

      WHEN 'SEU_INT'.
        IF IT_EKPO[] IS INITIAL.
          MESSAGE A003(OK).
        ENDIF.
        G_TCODE = C_CREATE.
        G_MODE  = C_CHARC.

      WHEN OTHERS.
    ENDCASE.
*    FREE MEMORY ID g_indxkey.
  ELSE.
*    CLEAR: g_tcode.
    G_TCODE = SY-TCODE.
  ENDIF.

ENDMODULE.                 " pbo_scr0100_Import_memory  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  change_field_attribute_scr2121  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_FIELD_ATTRIBUTE_SCR2121 OUTPUT.

  IF G_MODE EQ C_CHARD OR
     G_MODE EQ C_CHARS.
    LOOP AT  SCREEN .
      CASE SCREEN-NAME.
        WHEN 'ZTITBLK-KUNNR' OR 'ZTITBLK-VBELN' OR
             'KNA1-NAME1'.
          IF ZTITBLK-BLDTY NE C_CHARH.
            SCREEN-INPUT     = C_CHAR0.
            SCREEN-INVISIBLE = C_CHAR1.
            MODIFY SCREEN.
          ENDIF.
        WHEN 'ZTITBLK-BBLNO'.
          IF ZTITBLK-BBLNO IS INITIAL.
            SCREEN-INPUT     = C_CHAR0.
            SCREEN-INVISIBLE = C_CHAR1.
            MODIFY SCREEN.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDIF.

  CHECK: G_MODE EQ C_CHARC OR
         G_MODE EQ C_CHARM OR
         G_MODE EQ C_CHARA OR
         G_MODE EQ C_CHARY OR
         G_MODE EQ C_CHARO.

*>운임 수기입력 가능여부 점검 " 기능개선 283274 추가
  PERFORM CHECK_EXCEPTION_FOR_MANUAL USING GV_SUGI
                                           GV_MANUL.

  LOOP AT  SCREEN .
    CASE SCREEN-NAME.
************************************************************************
* 날짜   : 2008.10.08
* 요청인 : 박혁세 K
* 내용   : 선적서류 생성시 수입신고구분 디폴트 값 = 'B' 보세운송통
************************************************************************
* 날짜   : 2010.02.18
* 요청 : C20100217_12482 [구매개선]
* 내용 : 선적서류 생성시 수입신고구분이 없을 경우에만
*        디폴트 값 = 'B' 보세운송통관
************************************************************************
      WHEN 'ZTITBLK-RPTTY'.
        IF ZTITBLK-RPTTY IS INITIAL.
          ZTITBLK-RPTTY = C_CHARB.
        ENDIF.
************************************************************************
      WHEN 'ZTITBLK-SDRDT' OR 'ZTITBLK-SDRLT'.
        CASE ZTITIG00-BLPCS.
          WHEN C_CHARA.  ">전체프로세스 사용.
            CASE G_MODE.
              WHEN C_CHARC OR C_CHARM.  ">생성/변경.
                SCREEN-INPUT     = C_CHAR0.
                SCREEN-INVISIBLE = C_CHAR1.
              WHEN C_CHARA.
                SCREEN-INPUT     = C_CHAR1.
                SCREEN-INVISIBLE = C_CHAR0.
              WHEN C_CHARY.
                IF ZTITBLK-SDRLT IS INITIAL.
                  IF SCREEN-NAME EQ 'ZTITBLK-SDRLT'.
                    SCREEN-INPUT     = C_CHAR1.
                    SCREEN-INVISIBLE = C_CHAR0.
                  ELSE.
                    SCREEN-INPUT     = C_CHAR0.
                    SCREEN-INVISIBLE = C_CHAR0.
                  ENDIF.
                ELSE.
                  SCREEN-INPUT     = C_CHAR0.
                  SCREEN-INVISIBLE = C_CHAR0.
                ENDIF.
              WHEN C_CHARO.
            ENDCASE.
          WHEN C_CHARB.
            CASE G_MODE.
              WHEN C_CHARC OR C_CHARM.  ">생성/변경.
                SCREEN-INPUT     = C_CHAR0.
                SCREEN-INVISIBLE = C_CHAR1.
              WHEN C_CHARY.
                SCREEN-INPUT     = C_CHAR1.
                SCREEN-INVISIBLE = C_CHAR0.
              WHEN C_CHARO.
            ENDCASE.
          WHEN C_CHARZ.
            SCREEN-INPUT     = C_CHAR0.
            SCREEN-INVISIBLE = C_CHAR1.
        ENDCASE.
*      WHEN 'ZTITBLK-RPTTY' OR 'ZTITBLK-CSATY' OR 'ZTITBLK-INBDT' OR
      WHEN 'ZTITBLK-RPTTY' OR 'ZTITBLK-INBDT' OR
           'ZTITBLK-CFRAT' OR 'ZTITBLK-CFRATC'.
        CASE ZTITIG00-BLPCS.
          WHEN C_CHARA OR C_CHARB.  ">전체프로세스/실입항 사용.
            CASE G_MODE.
              WHEN C_CHARC OR C_CHARM.  ">생성/변경.
                SCREEN-INPUT     = C_CHAR0.
                SCREEN-INVISIBLE = C_CHAR1.
              WHEN C_CHARY.
                SCREEN-INPUT     = C_CHAR1.
                SCREEN-INVISIBLE = C_CHAR0.
                IF SCREEN-NAME EQ 'ZTITBLK-CFRATC'.
                  SCREEN-INPUT     = C_CHAR0.
                ENDIF.
            ENDCASE.
          WHEN C_CHARZ.
* 20060627 simcho by
* BL생성시 운임 통화 입력가능하도록 수정
            IF SCREEN-NAME EQ 'ZTITBLK-CFRATC'.
              SCREEN-INPUT     = C_CHAR1.
            ENDIF.
* 20060627 end simcho
        ENDCASE.

      WHEN 'ZTITBLK-APPCT' OR 'ZTITBLK-INCO1' OR
           'ZTITBLK-LIFNR' OR 'LFA1-NAME1'.
        IF ZTITBLK-BLDTY EQ C_CHARS OR
           ZTITBLK-BLDTY EQ C_CHARO.
          SCREEN-INPUT = C_CHAR1.
        ELSEIF ZTITBLK-BLDTY EQ C_CHARH.
          SCREEN-INVISIBLE = C_CHAR1.
        ELSE.
          SCREEN-INPUT = C_CHAR0.
        ENDIF.

*-<< 기능개선 283274 추가
        IF ZTITBLK-BUKRS EQ '1000' AND
            SCREEN-NAME EQ 'ZTITBLK-INCO1'.
          SCREEN-INPUT     = C_CHAR1.
        ENDIF.
*->>

*      WHEN 'ZTITBLK-LIFNR' OR 'LFA1-NAME1'.
**           'ZTITBLK-EKGRP' OR
**           'T001-BUTXT'    OR 'T024E-EKOTX'   OR 'T024-EKNAM'.
*        IF ztitblk-bldty EQ c_charh.
*          screen-invisible = c_char1.
*        ENDIF.
      WHEN 'ZTITBLK-KUNNR' OR 'ZTITBLK-VBELN' OR
           'KNA1-NAME1'.
        IF ZTITBLK-BLDTY NE C_CHARH.
          SCREEN-INVISIBLE = C_CHAR1.
        ENDIF.

      WHEN 'ZTITBLK-ZROUTE' OR 'GV_BEZEI'. " 기능개선 283274 추가
        IF ZTITBLK-BUKRS NE '1000' .
          SCREEN-INPUT     = C_CHAR0.
          SCREEN-INVISIBLE = C_CHAR1.
        ELSE.
          IF ZTITBLK-INCO1 NE 'EXW' AND ZTITBLK-INCO1 NE 'FOB' AND
*-<< 296419 추가
             ZTITBLK-INCO1 NE 'FAS' AND ZTITBLK-INCO1 NE 'FCA ' AND
*->>
            SCREEN-INPUT     = C_CHAR0.
            SCREEN-INVISIBLE = C_CHAR1.
          ENDIF.

*-<< 기능개선 298023 - 미통관은 운임/부보 제외
          IF ZTITBLK-RPTTY EQ C_CHARZ.
            SCREEN-INPUT     = C_CHAR0.
            SCREEN-INVISIBLE = C_CHAR1.
          ENDIF.
*->> 기능개선 298023
        ENDIF.
    ENDCASE.
*> 무환일 경우.
    IF ZTITBLK-BLDTY EQ C_CHARS OR
       ZTITBLK-BLDTY EQ C_CHARO.
      CASE SCREEN-NAME.
        WHEN 'ZTITBLK-IVAMT'.
          SCREEN-INPUT = C_CHAR0.
      ENDCASE.
    ENDIF.

*> 무환일 경우....코스트센터 및 WBS요소 등록.
    CASE SCREEN-NAME.
      WHEN 'PRPS-POST1' OR 'ZTITBLK-KOSTL' OR
           'ZTITBLK-PSPNR'.
        IF ZTITBLK-BLDTY EQ 'S'.
          IF G_MODE EQ C_CHARC OR
             G_MODE EQ C_CHARM OR
             G_MODE EQ C_CHARY.
            SCREEN-INPUT = C_CHAR1.
          ELSE.
            SCREEN-INPUT    = C_CHAR0.
          ENDIF.
          SCREEN-INVISIBLE = C_CHAR0.
        ELSE.
          SCREEN-INPUT    = C_CHAR0.
          SCREEN-INVISIBLE = C_CHAR1.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.

*> 무환일 경우.... 이전 B/L 관리번호 찾기.
    IF SCREEN-NAME EQ 'ZTITBLK-BBLNO'.
      IF ZTITBLK-BLDTY EQ 'S'.
        READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.
        IF SY-SUBRC EQ 0.
          IF G_TC_2130_WA-NDFTY EQ 'B' OR
             G_TC_2130_WA-NDFTY EQ 'C' OR
             G_TC_2130_WA-NDFTY EQ 'R'.
            IF ZTITBLK-BBLNO IS INITIAL.
              SCREEN-INVISIBLE = C_CHAR0.
              IF G_MODE EQ C_CHARC OR
                 G_MODE EQ C_CHARM OR
                 G_MODE EQ C_CHARY.
                SCREEN-INPUT = C_CHAR1.
              ELSE.
                SCREEN-INPUT = C_CHAR0.
              ENDIF.
            ENDIF.
          ELSE.
            SCREEN-INPUT    = C_CHAR0.
            SCREEN-INVISIBLE = C_CHAR1.
          ENDIF.
        ELSE.
          SCREEN-INPUT = C_CHAR0.
          SCREEN-INVISIBLE = C_CHAR1.
        ENDIF.
      ELSE.
        SCREEN-INPUT     = C_CHAR0.
        SCREEN-INVISIBLE = C_CHAR1.
      ENDIF.
    ENDIF.

*>운임 수기입력 불가 여부
    IF SCREEN-GROUP3(2) = 'FR' AND GV_MANUL IS INITIAL.
      SCREEN-INPUT     = C_CHAR0.
      SCREEN-INVISIBLE = SCREEN-GROUP3+2(1).
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

  G_ZTITBLK_PBO = ZTITBLK.

ENDMODULE.                 " change_field_attribute_scr2121  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  change_field_attribute_scr2123  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_FIELD_ATTRIBUTE_SCR2123 OUTPUT.

*  CHECK: g_mode EQ c_charc OR
*         g_mode EQ c_charm.
*
  LOOP AT  SCREEN.
    IF ZTITBLK-BLDTY EQ C_CHARS OR
       ZTITBLK-BLDTY EQ C_CHARO.
      CASE SCREEN-NAME.
        WHEN 'ZTITBLK-BUKRS' OR 'ZTITBLK-EKORG' OR
             'ZTITBLK-EKGRP'.
          SCREEN-INPUT = C_CHAR1.
        WHEN 'ZTITBLK-VKORG' OR 'ZTITBLK-VTWEG' OR
             'ZTITBLK-SPART'.
          SCREEN-INPUT     = C_CHAR0.
          SCREEN-INVISIBLE = C_CHAR0.
      ENDCASE.
    ELSEIF ZTITBLK-BLDTY EQ C_CHARH.
      CASE SCREEN-NAME.
        WHEN 'ZTITBLK-VKORG' OR 'ZTITBLK-VTWEG' OR
             'ZTITBLK-SPART'.
          SCREEN-INPUT     = C_CHAR0.
          SCREEN-INVISIBLE = C_CHAR0.
        WHEN 'ZTITBLK-BUKRS' OR 'ZTITBLK-EKORG' OR
             'ZTITBLK-EKGRP' OR
             'T001-BUTXT'    OR 'T024E-EKOTX'   OR 'T024-EKNAM'.
          SCREEN-INPUT     = C_CHAR0.
          SCREEN-INVISIBLE = C_CHAR1.
      ENDCASE.
    ELSE.
      CASE SCREEN-NAME.
        WHEN 'ZTITBLK-VKORG' OR 'ZTITBLK-VTWEG' OR
             'ZTITBLK-SPART'.
          SCREEN-INPUT     = C_CHAR0.
          SCREEN-INVISIBLE = C_CHAR1.
        WHEN 'ZTITBLK-BUKRS' OR 'ZTITBLK-EKORG' OR
             'ZTITBLK-EKGRP' OR
             'T001-BUTXT'    OR 'T024E-EKOTX'   OR 'T024-EKNAM'.
          SCREEN-INPUT     = C_CHAR0.
          SCREEN-INVISIBLE = C_CHAR0.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.
    IF G_MODE EQ C_CHARS OR
       G_MODE EQ C_CHARD.
      SCREEN-INPUT     = C_CHAR0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " change_field_attribute_scr2123  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_status_7000  OUTPUT
*&---------------------------------------------------------------------*
*       Set GUI Status
*----------------------------------------------------------------------*
MODULE PBO_STATUS_7000 OUTPUT.

  SET PF-STATUS '7000'.
  SET TITLEBAR  'T7000'.

ENDMODULE.                 " pbo_status_7000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_change_field_attr_scr0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_CHANGE_FIELD_ATTR_SCR0100 OUTPUT.

  IF SY-BINPT EQ C_TRUE.
    LOOP AT SCREEN.
      IF SCREEN-NAME EQ 'ZTISSCRCOM-CRLSE'.
        SCREEN-INPUT     = C_CHAR1.
        SCREEN-INVISIBLE = C_CHAR0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF SCREEN-NAME EQ 'ZTISSCRCOM-CRLSE'.
        SCREEN-INPUT     = C_CHAR0.
        SCREEN-INVISIBLE = C_CHAR1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " pbo_change_field_attr_scr0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_status_7010  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_STATUS_7010 OUTPUT.

ENDMODULE.                 " pbo_status_7010  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_status_7020  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_STATUS_7020 OUTPUT.

  SET PF-STATUS 'LIST'.
  SET TITLEBAR  'T7020'.

  CLEAR: OK-CODE.

ENDMODULE.                 " pbo_status_7020  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_7040  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_7040 OUTPUT.
  SET PF-STATUS '7040'.
  SET TITLEBAR 'T7040'.
ENDMODULE.                 " STATUS_7040  OUTPUT
