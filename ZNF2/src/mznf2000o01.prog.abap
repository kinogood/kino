*&---------------------------------------------------------------------*
*&  Include           MZNF2000O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR  '0100'.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  SET PF-STATUS '0200'.
  SET TITLEBAR  '0200'.
ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.
  SET PF-STATUS '0300'.
  SET TITLEBAR  '0300'.
ENDMODULE.                 " STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0400  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0400 OUTPUT.
  SET PF-STATUS '0400'.
  SET TITLEBAR  '0400'.
ENDMODULE.                 " STATUS_0400  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0500 OUTPUT.

  CASE SY-TCODE.
    WHEN GV_TCODE1.
      SET PF-STATUS '0501'.
      SET TITLEBAR  '0100'.
    WHEN GV_TCODE2.
      SET PF-STATUS '0502'.
      SET TITLEBAR  '0200'.
    WHEN  GV_TCODE3.
      SET PF-STATUS '0502'.
      SET TITLEBAR  '0300'.
    WHEN GV_TCODE4.
      SET PF-STATUS '0503'.
      SET TITLEBAR  '0400'.
  ENDCASE.

ENDMODULE.                 " STATUS_0500  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_TC1_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_TC1_LINES OUTPUT.

  DESCRIBE TABLE GT_ZNFT1001 LINES TC1-LINES.

  IF TC1-TOP_LINE > TC1-LINES.
    TC1-TOP_LINE = TC1-LINES.
  ENDIF.

ENDMODULE.                 " SET_TC1_LINES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MOVE_ITAB_TO_TC1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MOVE_ITAB_TO_TC1 OUTPUT.

  READ TABLE GT_ZNFT1001 INDEX TC1-CURRENT_LINE.
  IF SY-SUBRC NE 0.
    CLEAR : GT_ZNFT1001.
    EXIT FROM STEP-LOOP.
  ENDIF.

ENDMODULE.                 " MOVE_ITAB_TO_TC1  OUTPUT

**&---------------------------------------------------------------------
*
**&      Module  GET_MODIFY_SCREEN_FLAG  OUTPUT
**&---------------------------------------------------------------------
*
**       text
**----------------------------------------------------------------------
*
*MODULE GET_MODIFY_SCREEN_FLAG OUTPUT.
**
**  CLEAR GV_SCR_CHANG_FIELD.
**
*** =======================================================
*** ### GV_MODI_A ### : S/O, 또는 선물요청과 연결유무
*** =======================================================
**  CLEAR : GV_MODI_A.
**
**  DATA: LV_REQNO TYPE ZREQNO_1,
**        LV_VBELN TYPE VBELN_VA.
**
**  SELECT SINGLE REQNO INTO LV_REQNO
**    FROM ZNFT1011
**   WHERE CONNO EQ GV_CONNO.
**
**  IF LV_REQNO IS NOT INITIAL.
**    GV_MODI_A = 'X'.
**  ENDIF.
**
**  SELECT SINGLE VBELN INTO LV_VBELN
**    FROM VBAP
**   WHERE CONNO EQ GV_CONNO.
**
**  IF LV_VBELN IS NOT INITIAL.
**    GV_MODI_A = 'X'.
**  ENDIF.
**
**
*** =======================================================
*** ### GV_MODI_B ### : 선물집행후 정산 여부
*** =======================================================
**  CLEAR : GV_MODI_B.
**
**  DATA: LV_YNFIN TYPE ZFUTNO.
**
**  SELECT SINGLE Z2~YNFIN INTO LV_YNFIN
**    FROM ZNFT1011 AS Z1
**         INNER JOIN ZNFT1020 AS Z2
**            ON Z2~REQNO EQ Z1~REQNO AND Z2~H_NO1 EQ Z1~H_NO1
**   WHERE Z1~CONNO EQ GV_CONNO.
**
**  IF LV_YNFIN IS NOT INITIAL.
**    GV_MODI_B = 'X'.
**  ENDIF.
**
**
*** =======================================================
*** ### GV_MODI_B ### : 계약유형 (경상선물,재고헷지)
*** =======================================================
**  CLEAR : GV_MODI_C.
**
**  DATA: LV_COTYP TYPE ZCOTYP.
**
**  CASE SY-TCODE.
**    WHEN GV_TCODE1.
**      IF GV_COTYP EQ '3' OR GV_COTYP EQ '5'.
**        GV_MODI_C = 'X'.
**      ELSE.
**        GV_MODI_C = SPACE.
**      ENDIF.
**    WHEN GV_TCODE2 OR GV_TCODE3.
**      SELECT SINGLE COTYP INTO LV_COTYP
**        FROM ZNFT1000
**       WHERE CONNO EQ GV_CONNO.
**
**      IF LV_COTYP EQ '3' OR LV_COTYP EQ '5'.
**        GV_MODI_C = 'X'.
**      ELSE.
**        GV_MODI_C = SPACE.
**      ENDIF.
**  ENDCASE.
*
*ENDMODULE.                 " GET_MODIFY_SCREEN_FLAG  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTRIBUTE  OUTPUT
*&---------------------------------------------------------------------*
*       text : SCREEN FIELD
*----------------------------------------------------------------------*
MODULE SET_SCREEN_ATTRIBUTE OUTPUT.

*  ###################################################
*  SCREEN-INVISIBLE = 0.
*  SCREEN-INVISIBLE = 1.  <== Hidden
*
*  SCREEN-INPUT = 0.
*  SCREEN-INPUT = 1.      <== Editable

*  GV_MODI_A : S/O, 또는 선물요청연결유무
*  GV_MODI_B : 선물집행후 정산 여부
*  GV_MODI_C : 계약유형이 경상선물 OR 재고헷지인지 여부

*  GV_TCODE1 = 'ZNF2M2001'   : 계약생성
*  GV_TCODE2 = 'ZNF2M2002A'  : 계약수정 - 요청부서용
*  GV_TCODE3 = 'ZNF2M2002B'  : 계약수정 - 선물부서용
*  GV_TCODE4 = 'ZNF2M2003'   : 계약조회
*  ###################################################


* T-CODE별로 상세화면의 입력필드 활성화/비활성화
  LOOP AT SCREEN.
    CASE SY-TCODE.
      WHEN GV_TCODE1.   " (계약생성)
*       ### Hidden ###
        IF SCREEN-GROUP1 EQ 'GV1'.
          SCREEN-INVISIBLE = 1.
        ENDIF.
*       ### Editable ###
        IF GV_MODI_C EQ 'X' AND SCREEN-GROUP4 = 'G_C'.
          SCREEN-INPUT = 0.
        ENDIF.

      WHEN GV_TCODE2.   " (계약수정 - 요청부서용)
*       ### Hidden ###
*       N/A
*       ### Editable ###
        IF GV_MODI_B EQ 'X' AND SCREEN-GROUP1 = 'G_B'.
          SCREEN-INPUT = 0.
        ELSE.
          IF GV_MODI_A EQ 'X' AND SCREEN-GROUP2 = 'G_A'.
            SCREEN-INPUT = 0.
          ELSE.
            SCREEN-INPUT = 1.
          ENDIF.
        ENDIF.

        IF SCREEN-GROUP2 EQ 'GV2'.
          SCREEN-INPUT = 0.
        ENDIF.

        IF GV_MODI_C EQ 'X' AND SCREEN-GROUP4 = 'G_C'.
          SCREEN-INPUT = 0.
        ENDIF.

      WHEN GV_TCODE3.   " (계약수정 - 선물부서용)
*       ### Hidden ###
*       N/A
*       ### Editable ###
        IF GV_MODI_B EQ 'X' AND SCREEN-GROUP1 = 'G_B'.
          SCREEN-INPUT = 0.
        ELSE.
          IF GV_MODI_A EQ 'X' AND SCREEN-GROUP2 = 'G_A'.
            SCREEN-INPUT = 1.
          ELSE.
            SCREEN-INPUT = 1.
          ENDIF.
        ENDIF.

        IF SCREEN-GROUP2 EQ 'GV2'.
          SCREEN-INPUT = 0.
        ENDIF.

        IF GV_MODI_C EQ 'X' AND SCREEN-GROUP4 = 'G_C'.
          SCREEN-INPUT = 0.
        ENDIF.

      WHEN GV_TCODE4.   " 조회
*       ### Hidden ###
*       N/A
*       ### Editable ###
        IF SCREEN-NAME EQ 'BTN_INS_FILE' OR
         SCREEN-NAME EQ 'BTN_LNK_FILE'.
          SCREEN-INPUT = 1.
        ELSE.
          SCREEN-INPUT = 0.
        ENDIF.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

* TABLE CONTROL : GT_ZNFT1001-DBCHK 필드 숨기기
  LOOP AT TC1-COLS INTO GS_COLS.
    IF GS_COLS-SCREEN-GROUP1 = 'GT1' .
      GS_COLS-SCREEN-INPUT = '0'.
      GS_COLS-INVISIBLE    = '1'.
    ENDIF.
    MODIFY TC1-COLS INDEX SY-TABIX FROM GS_COLS.
  ENDLOOP.

ENDMODULE.                 " SET_SCREEN_ATTRIBUTE  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTRIBUTE_TC1  OUTPUT
*&---------------------------------------------------------------------*
*       text : TABLE FIELD
*----------------------------------------------------------------------*
MODULE SET_SCREEN_ATTRIBUTE_TC1 OUTPUT.

*  ###################################################
*  SCREEN-INVISIBLE = 0.
*  SCREEN-INVISIBLE = 1.  <== Hidden
*
*  SCREEN-INPUT = 0.      <== Editable
*  SCREEN-INPUT = 1.


*  GV_MODI_A : S/O, 또는 선물요청연결유무
*  GV_MODI_B : 선물집행후 정산 여부

*  GV_MODI_C : 계약유형 (경상선물,재고헷지)

*  GV_TCODE1 = 'ZNF2M2001'   : 계약생성
*  GV_TCODE2 = 'ZNF2M2002A'  : 계약수정 - 요청부서용
*  GV_TCODE3 = 'ZNF2M2002B'  : 계약수정 - 선물부서용
*  GV_TCODE4 = 'ZNF2M2003'   : 계약조회
*  ###################################################

* T-CODE별로 상세화면의 입력필드 활성화/비활성화
  LOOP AT SCREEN.
    CASE SY-TCODE.
      WHEN GV_TCODE1.   " 생

*     ### Hidden ###

*     ### Editale ###

      WHEN GV_TCODE2.   " 요청 수정

*     ### Hidden ###
*       N/A
*     ### Editale ###
        IF GV_MODI_B EQ 'X' AND SCREEN-GROUP1 = 'G_B'.
          SCREEN-INPUT = 0.
        ENDIF.
      WHEN GV_TCODE3.   " 선물 수정
*     ### Hidden ###
*       N/A
*     ### Editale ###
        IF GV_MODI_B EQ 'X' AND SCREEN-GROUP1 = 'G_B'.
          SCREEN-INPUT = 0.
        ENDIF.
      WHEN GV_TCODE4.   " 조회
*     ### Hidden ###
*       N/A
*     ### Editale ###
        SCREEN-INPUT = 0.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " SET_SCREEN_ATTRIBUTE_TC1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR OUTPUT.

  SET CURSOR FIELD GV_CURSOR LINE GV_CURLIN.

ENDMODULE.                 " SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_PRINT_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPLAY_PRINT_SCREEN OUTPUT.

  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.

  SET PF-STATUS '0600'.
  SET TITLEBAR  '0600'.

  SUPPRESS DIALOG.

  PERFORM DISPLAY_PRINT_SCREEN.

ENDMODULE.                 " DISPLAY_PRINT_SCREEN  OUTPUT
