*&---------------------------------------------------------------------*
*&  Include           MZNF2000I01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CLEAR GS_FILEM.

  CASE SY-UCOMM.
    WHEN 'EXIT'.
      IF SY-TCODE EQ GV_TCODE2 OR SY-TCODE EQ GV_TCODE3.
        PERFORM DEQUEUE_ZNFT1000.
      ENDIF.
      LEAVE PROGRAM.
    WHEN 'BACK' OR 'CANC'.
      IF SY-TCODE EQ GV_TCODE2 OR SY-TCODE EQ GV_TCODE3.
        PERFORM DEQUEUE_ZNFT1000.
      ENDIF.
      IF SY-CALLD = 'X'.
        LEAVE PROGRAM.
      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT_PRINT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_PRINT INPUT.

  CLEAR GS_FILEM.

  CASE SY-UCOMM.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " EXIT_PRINT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  OK_SAVE = OK_CODE.
  CLEAR : OK_CODE.

  CASE OK_SAVE.
    WHEN 'ENTR'.
      PERFORM GET_FUTURES_REQ_DATA_100.
      IF GV_ERROR = 'X' AND SY-CALLD = 'X'.
        LEAVE PROGRAM.
      ELSE.
        PERFORM SET_MODIFY_SCREEN_FLAG.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  OK_SAVE = OK_CODE.
  CLEAR : OK_CODE.

  CASE OK_SAVE.
    WHEN 'ENTR'.
      PERFORM GET_FUTURES_REQ_DATA_200.
      IF GV_ERROR = 'X' AND SY-CALLD = 'X'.
        LEAVE PROGRAM.
      ELSE.
        PERFORM SET_MODIFY_SCREEN_FLAG.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  OK_SAVE = OK_CODE.
  CLEAR : OK_CODE.

  CASE OK_SAVE.
    WHEN 'ENTR'.
      PERFORM GET_FUTURES_REQ_DATA_300.
      IF GV_ERROR = 'X' AND SY-CALLD = 'X'.
        LEAVE PROGRAM.
      ELSE.
        PERFORM SET_MODIFY_SCREEN_FLAG.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0400 INPUT.

  OK_SAVE = OK_CODE.
  CLEAR : OK_CODE.

  CASE OK_SAVE.
    WHEN 'ENTR'.
      PERFORM GET_FUTURES_REQ_DATA_400.
      IF GV_ERROR = 'X' AND SY-CALLD = 'X'.
        LEAVE PROGRAM.
*      ELSE.
*        PERFORM SET_MODIFY_SCREEN_FLAG.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0500 INPUT.

  OK_SAVE = OK_CODE.
  CLEAR : OK_CODE.

  CASE OK_SAVE.
    WHEN 'SAVE'.         " 저장
      PERFORM DATA_SAVE.
    WHEN 'HIST'.
      PERFORM DISPLAY_CHANGE_HISTORY.
    WHEN 'INS_FILE'.
      PERFORM INSERT_FILE.
    WHEN 'LNK_FILE'.
      PERFORM LINK_FILE.
    WHEN 'PRT'.
      PERFORM CALL_SCREEN_0600.
  ENDCASE.

*  PERFORM SET_MODIFY_SCREEN_FLAG.

ENDMODULE.                 " USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_CURSOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR INPUT.
  GET CURSOR FIELD GV_CURSOR LINE GV_CURLIN.
ENDMODULE.                 " GET_CURSOR  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_REQUEST_QTY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_REQUEST_QTY INPUT.

  CLEAR : GV_DEC.

  GV_DEC = FRAC( GS_ZNFT1001-EMENG ).

  IF GV_DEC IS NOT INITIAL.
    MESSAGE E001 WITH '수주량은 정수로 입력해야 합니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_REQUEST_QTY  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_EXPIRE_MONTH  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_EXPIRE_MONTH INPUT.

  CHECK GT_ZNFT1001-AVGPR IS NOT INITIAL.

  IF GT_ZNFT1001-AVGPR < SY-DATLO(6).
    MESSAGE E001 WITH 'Average Price는 당월 이후로 입력해야 합니다.'.
  ENDIF.

  IF GT_ZNFT1001-AVGPR+4(2) < '01' OR GT_ZNFT1001-AVGPR+4(2) > '12'.
    MESSAGE E001 WITH 'Average Price를 점검하시기 바랍니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_EXPIRE_MONTH  INPUT


*&---------------------------------------------------------------------*
*&      Module  GET_SCR_KUNNR_DESC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_SCR_KUNNR_DESC INPUT.


  SELECT SINGLE * FROM KNA1 WHERE KUNNR EQ ZNFT1000-KUNNR.
  IF SY-SUBRC EQ 0.
*-{기능개선 110852 - 일회성 고객코드(문자) 입력 금지
    IF KNA1-XCPDK = 'X'.
      MESSAGE E001 WITH '일회성 고객코드(문자)는 입력할 수 없습니다.'.
    ENDIF.
*-}기능개선 110852
    IF KNA1-NAME1 IS NOT INITIAL.
      ZNFT1000-NCUST = KNA1-NAME1.
    ELSE.
      CLEAR ZNFT1000-NCUST.
    ENDIF.
  ELSE.
    CLEAR ZNFT1000-NCUST.
  ENDIF.

ENDMODULE.                 " GET_SCR_KUNNR_DESC  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_FIELD_EXIST  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_FIELD_EXIST INPUT.

  DATA: LV_FIELD_EXIST TYPE I.

  CLEAR LV_FIELD_EXIST.

  READ TABLE GT_ZNFT1001 INTO GS_ZNFT1001 INDEX TC1-CURRENT_LINE.

  IF SY-SUBRC EQ 0.
    IF GT_ZNFT1001-EMENG IS INITIAL.
      IF GT_ZNFT1001-PRICE IS NOT INITIAL OR
         GT_ZNFT1001-AVGPR IS NOT INITIAL OR
         GT_ZNFT1001-OFFCH IS NOT INITIAL.
        MESSAGE W003 WITH '수주량은 필수입력 필드입니다.'.
        GV_CURSOR = 'GT_ZNFT1001-EMENG'.
        GV_CURLIN = TC1-CURRENT_LINE.
      ENDIF.
    ELSE.

      IF GT_ZNFT1001-PRICE IS NOT INITIAL.
        ADD 1 TO LV_FIELD_EXIST.
      ENDIF.

      IF GT_ZNFT1001-AVGPR IS NOT INITIAL.
        ADD 1 TO LV_FIELD_EXIST.
      ENDIF.

      IF GT_ZNFT1001-OFFCH IS NOT INITIAL.
        ADD 1 TO LV_FIELD_EXIST.
      ENDIF.

*      IF GT_ZNFT1001-CURPR IS NOT INITIAL.
*        ADD 1 TO LV_FIELD_EXIST.
*      ENDIF.

      IF LV_FIELD_EXIST EQ 0.
        MESSAGE W003 WITH '가격정보를 입력하십시오.'
                          '(Fix Price/Average Price/Offical Cash)'.
        GV_CURSOR = 'GT_ZNFT1001-PRICE'.
        GV_CURLIN = TC1-CURRENT_LINE.
      ENDIF.

*      IF LV_FIELD_EXIST EQ 0.
*        MESSAGE W003 WITH '가격정보를 입력하십시오.'
*                          '(Fix Price/Average Price/Offical Cash/시세)'.
*        GV_CURSOR = 'GT_ZNFT1001-PRICE'.
*        GV_CURLIN = TC1-CURRENT_LINE.
*      ENDIF.

      IF LV_FIELD_EXIST GE 2.
        MESSAGE W003 WITH '가격정보는 하나만 입력하십시오.'
                          '(Fix Price/Average Price/Offical Cash)'.
        GV_CURSOR = 'GT_ZNFT1001-PRICE'.
        GV_CURLIN = TC1-CURRENT_LINE.
      ENDIF.

*      IF LV_FIELD_EXIST GE 2.
*        MESSAGE W003 WITH '가격정보는 하나만 입력하십시오.'
*                          '(Fix Price/Average Price/Offical Cash/시세)'.
*        GV_CURSOR = 'GT_ZNFT1001-PRICE'.
*        GV_CURLIN = TC1-CURRENT_LINE.
*      ENDIF.

    ENDIF.

  ENDIF.

ENDMODULE.                 " CHECK_FIELD_EXIST  INPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_GT_ZNFT1001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_GT_ZNFT1001 INPUT.

  READ TABLE GT_ZNFT1001 INTO GS_ZNFT1001 INDEX TC1-CURRENT_LINE.

  IF SY-SUBRC EQ 0.
*   ### DB DATA인 경우
    IF GS_ZNFT1001-DBCHK EQ 'Y'.
*     수주량, 수주금액, AveragePrice, OfficialCash,
*     시세가 없는경우 삭제로 간주
      IF GT_ZNFT1001-EMENG IS INITIAL AND
         GT_ZNFT1001-PRICE IS INITIAL AND
         GT_ZNFT1001-AVGPR IS INITIAL AND
         GT_ZNFT1001-OFFCH IS INITIAL.
*         AND GT_ZNFT1001-CURPR IS INITIAL.

        PERFORM MOVE_CHANGED_DATA.
        GS_ZNFT1001-AEDAT = SY-DATLO.
        GS_ZNFT1001-AEZET = SY-TIMLO.
        GS_ZNFT1001-AENAM = SY-UNAME.
        GS_ZNFT1001-UPDKZ = 'D'.  " 삭제 FLAG
        MODIFY GT_ZNFT1001 FROM GS_ZNFT1001 INDEX TC1-CURRENT_LINE.
      ELSE.
        PERFORM MOVE_CHANGED_DATA.
        GS_ZNFT1001-AEDAT = SY-DATLO.
        GS_ZNFT1001-AEZET = SY-TIMLO.
        GS_ZNFT1001-AENAM = SY-UNAME.
        GS_ZNFT1001-UPDKZ = 'U'.  " 수정 FLAG
        MODIFY GT_ZNFT1001 FROM GS_ZNFT1001 INDEX TC1-CURRENT_LINE.
      ENDIF.
*   ### DB DATA 아닌 경우
    ELSE.
      IF GT_ZNFT1001-EMENG IS INITIAL AND
         GT_ZNFT1001-PRICE IS INITIAL AND
         GT_ZNFT1001-AVGPR IS INITIAL AND
         GT_ZNFT1001-OFFCH IS INITIAL.
*         AND GT_ZNFT1001-CURPR IS INITIAL.

        GS_ZNFT1001-UPDKZ = SPACE.
        GS_ZNFT1001-EMENG = GT_ZNFT1001-EMENG .
        GS_ZNFT1001-MEINS = GT_ZNFT1001-MEINS .
        GS_ZNFT1001-PRICE = GT_ZNFT1001-PRICE .
        GS_ZNFT1001-WAERS = GT_ZNFT1001-WAERS .
        GS_ZNFT1001-AVGPR = GT_ZNFT1001-AVGPR .
        GS_ZNFT1001-OFFCH = GT_ZNFT1001-OFFCH .
*        GS_ZNFT1001-CURPR = GT_ZNFT1001-CURPR .
        GS_ZNFT1001-BIGO4 = GT_ZNFT1001-BIGO4 .
        GS_ZNFT1001-ERDAT = SPACE.
        GS_ZNFT1001-ERZET = SPACE.
        GS_ZNFT1001-ERNAM = SPACE.
        GS_ZNFT1001-AEDAT = SPACE.
        GS_ZNFT1001-AEZET = SPACE.
        GS_ZNFT1001-AENAM = SPACE.
        GS_ZNFT1001-CHECK = GT_ZNFT1001-CHECK .

        MODIFY GT_ZNFT1001 FROM GS_ZNFT1001 INDEX TC1-CURRENT_LINE.
      ELSE.

        PERFORM MOVE_CHANGED_DATA.

        GS_ZNFT1001-UPDKZ = 'I'.      " 신규 FLAG
*        GS_ZNFT1001-MEINS = 'TON'. " 비철 CME 관리
        GS_ZNFT1001-WAERS = 'USD'.
        GS_ZNFT1001-ERDAT = SY-DATLO.
        GS_ZNFT1001-ERZET = SY-TIMLO.
        GS_ZNFT1001-ERNAM = SY-UNAME.
        GS_ZNFT1001-AEDAT = SY-DATLO.
        GS_ZNFT1001-AEZET = SY-TIMLO.
        GS_ZNFT1001-AENAM = SY-UNAME.
        MODIFY GT_ZNFT1001 FROM GS_ZNFT1001 INDEX TC1-CURRENT_LINE.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " MODIFY_GT_ZNFT1001  INPUT

*&---------------------------------------------------------------------*
*&      Module  F4HELP_ENDMM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_ENDMM INPUT.

  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      ACTUAL_MONTH   = SY-DATLO(6)
    IMPORTING
      SELECTED_MONTH = GT_ZNFT1001-AVGPR.

ENDMODULE.                 " F4HELP_ENDMM  INPUT

*&---------------------------------------------------------------------*
*&      Module  F4HELP_NFCTR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_NFCTR INPUT.

  CLEAR   : GT_NFCTR.
  REFRESH : GT_NFCTR.

  SELECT NFCTR
         NTEXT
    INTO TABLE GT_NFCTR
    FROM ZNFT0005
   WHERE BUKRS EQ ZNFT1000-BUKRS.   "회사코드

  IF SY-SUBRC NE 0.
    MESSAGE I002 WITH ZNFT1000-BUKRS
    '회사코드에 해당하는 사업부가 없습니다.'.
  ELSE.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD     = 'NFCTR'
        DYNPPROG     = SY-CPROG
        DYNPNR       = SY-DYNNR
        DYNPROFIELD  = 'ZNFT1000-NFCTR'
        WINDOW_TITLE = '사업부'
        VALUE_ORG    = 'S'
      TABLES
        VALUE_TAB    = GT_NFCTR.

    IF SY-SUBRC NE 0.
      MESSAGE ID SY-MSGID
            TYPE SY-MSGTY
          NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDMODULE.                 " F4HELP_NFCTR  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_PRCTR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_PRCTR INPUT.

  CLEAR   : SCR_FIELDS, GT_PRCTR.
  REFRESH : SCR_FIELDS, GT_PRCTR.

*___화면상의 사업부를 읽는다.
  SCR_FIELDS-FIELDNAME = 'ZNFT1000-NFCTR'.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = SY-CPROG
      DYNUMB     = SY-DYNNR
    TABLES
      DYNPFIELDS = SCR_FIELDS.

  READ TABLE SCR_FIELDS WITH KEY FIELDNAME = 'ZNFT1000-NFCTR'.
  ZNFT1000-NFCTR = SCR_FIELDS-FIELDVALUE.

  PERFORM CONVERSION_EXIT_ALPHA USING 'I'
                                      ZNFT1000-NFCTR.

  SELECT PRCTR
         PTEXT
    INTO TABLE GT_PRCTR
    FROM ZNFT0004
   WHERE KOKRS   EQ ZNFT1000-BUKRS  "관리회계영역
     AND NFCTR   EQ ZNFT1000-NFCTR  "사업부
     AND BDATU   GE SY-DATLO        "효력만료일
     AND CFACTIV EQ 'X'.            "선물요청(활성)

  IF SY-SUBRC <> 0.
    MESSAGE I000 WITH '사업부에 해당하는 손익센터가 없습니다.'.
  ELSE.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD     = 'PRCTR'
        DYNPPROG     = SY-CPROG
        DYNPNR       = SY-DYNNR
        DYNPROFIELD  = 'ZNFT1000-PRCTR'
        WINDOW_TITLE = '손익센터'
        VALUE_ORG    = 'S'
      TABLES
        VALUE_TAB    = GT_PRCTR.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID
            TYPE SY-MSGTY
          NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDMODULE.                 " F4HELP_PRCTR  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_VKGRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_VKGRP INPUT.

  CLEAR   : SCR_FIELDS, GT_VKGRP.
  REFRESH : SCR_FIELDS, GT_VKGRP.

*___화면상의 손익센터를 읽는다.
  SCR_FIELDS-FIELDNAME = 'ZNFT1000-PRCTR'.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = SY-CPROG
      DYNUMB     = SY-DYNNR
    TABLES
      DYNPFIELDS = SCR_FIELDS.

  READ TABLE SCR_FIELDS WITH KEY FIELDNAME = 'ZNFT1000-PRCTR'.
  ZNFT1000-PRCTR = SCR_FIELDS-FIELDVALUE.

  PERFORM CONVERSION_EXIT_ALPHA USING 'I'
                                      ZNFT1000-PRCTR.

  SELECT VKGRP
         VTEXT
    INTO TABLE GT_VKGRP
    FROM ZNFT0003
   WHERE KOKRS = ZNFT1000-BUKRS   "회사코드
     AND PRCTR = ZNFT1000-PRCTR.

  IF SY-SUBRC <> 0.
    MESSAGE I000 WITH '손익센터에 해당하는 영업그룹이 없습니다.'.
  ELSE.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD     = 'VKGRP'
        DYNPPROG     = SY-CPROG
        DYNPNR       = SY-DYNNR
        DYNPROFIELD  = 'ZNFT1000-VKGRP'
        WINDOW_TITLE = '영업그룹'
        VALUE_ORG    = 'S'
      TABLES
        VALUE_TAB    = GT_VKGRP.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID
            TYPE SY-MSGTY
          NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDMODULE.                 " F4HELP_VKGRP  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHEKC_FIELD_CHANGED  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHEKC_FIELD_CHANGED INPUT.

* Header Info Change Flag :
  DATA: LS_ZNFT1000 TYPE ZNFT1000.
  CLEAR LS_ZNFT1000.
  CLEAR GV_H_CHNG.

  SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1000
    FROM ZNFT1000
   WHERE CONNO EQ GV_CONNO.

  IF ZNFT1000 NE LS_ZNFT1000.
    GV_H_CHNG = 'Y'.
  ELSE.
    GV_H_CHNG = 'N'.
  ENDIF.

ENDMODULE.                 " CHEKC_FIELD_CHANGED  INPUT

*&---------------------------------------------------------------------*
*&      Module  GET_SCR_NFCTR_DESC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_SCR_NFCTR_DESC INPUT.

  PERFORM GET_NFCTR_DESC USING ZNFT1000-BUKRS
                               ZNFT1000-NFCTR
                               ZNFT0005-NTEXT.

ENDMODULE.                 " GET_SCR_NFCTR_DESC  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_SCR_PRCTR_DESC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_SCR_PRCTR_DESC INPUT.

  PERFORM GET_PRCTR_DESC USING ZNFT1000-BUKRS
                               ZNFT1000-PRCTR
                               ZNFT0004-PTEXT.

ENDMODULE.                 " GET_SCR_PRCTR_DESC  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_SCR_VKGRP_DESC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_SCR_VKGRP_DESC INPUT.

  PERFORM GET_VKGRP_DESC USING ZNFT1000-BUKRS
                               ZNFT1000-VKGRP
                               ZNFT0003-VTEXT.

ENDMODULE.                 " GET_SCR_VKGRP_DESC  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_SCREEN_FIELD_01  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_SCREEN_FIELD_01 INPUT.

  IF ZNFT1000-NFCTR IS NOT INITIAL AND
     ZNFT1000-PRCTR IS NOT INITIAL.
    SELECT SINGLE PRCTR
      INTO ZNFT1000-PRCTR
      FROM ZNFT0004
     WHERE KOKRS EQ ZNFT1000-BUKRS
       AND NFCTR EQ ZNFT1000-NFCTR
       AND PRCTR EQ ZNFT1000-PRCTR.

    IF SY-SUBRC <> 0.
      MESSAGE E003 WITH '사업부에 해당하는 손익센터가 아닙니다.'.
    ENDIF.
  ENDIF.

ENDMODULE.                 " CHECK_SCREEN_FIELD_01  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_SCREEN_FIELD_02  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_SCREEN_FIELD_02 INPUT.

  IF ZNFT1000-PRCTR IS NOT INITIAL AND
     ZNFT1000-VKGRP IS NOT INITIAL.

    SELECT SINGLE VKGRP
      INTO ZNFT1000-VKGRP
      FROM ZNFT0003
     WHERE KOKRS EQ ZNFT1000-BUKRS
       AND PRCTR EQ ZNFT1000-PRCTR
       AND VKGRP EQ ZNFT1000-VKGRP.

    IF SY-SUBRC <> 0.
      MESSAGE E003 WITH '손익센터에 해당하는 영업그룹이 아닙니다.'.
    ENDIF.
  ENDIF.

ENDMODULE.                 " CHECK_SCREEN_FIELD_02  INPUT
