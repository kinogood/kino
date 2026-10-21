*&---------------------------------------------------------------------*
*&  Include           ZNFR2101I01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CLEAR : OK_SAVE.
  OK_SAVE = OK_CODE.
  CLEAR : OK_CODE.

  CLEAR: GV_COMPLETE_SAVE, GV_COMPLETE_REQ, GV_RNT_MSG.
  CLEAR: GV_PERNR, GV_ENAME.

  CASE OK_SAVE.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1100 INPUT.

  CLEAR : OK_SAVE.
  OK_SAVE = OK_CODE.
  CLEAR : OK_CODE.

  CASE OK_SAVE.
*   저장
    WHEN 'DATA_SAVE'.
      PERFORM DATA_SAVE.
*   결재요청
    WHEN 'DATA_SIGN'.
      PERFORM DATA_SIGN.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1100  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_PERNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_PERNR INPUT.

  PERFORM CHECK_APPLOVAL_USER USING GV_PERNR.

ENDMODULE.                 " CHECK_PERNR  INPUT

*&---------------------------------------------------------------------*
*&      Form  CHECK_APPLOVAL_USER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_APPLOVAL_USER  USING    PV_PERNR.

*___사번 존재여부
  SELECT SINGLE ENAME INTO GV_ENAME
    FROM PA0001
   WHERE PERNR EQ PV_PERNR
     AND ENDDA GE SY-DATLO
     AND BEGDA LE SY-DATLO.

  IF SY-SUBRC NE 0.
    MESSAGE E003 WITH '결재자 사번이 존재하지 않습니다.'.
  ENDIF.

*___사번의 권한 점검
  CLEAR : ZNFT1090.

  SELECT SINGLE * FROM ZNFT1090
   WHERE BUKRS EQ P_BUKRS
     AND CONGB EQ '5'
     AND CONSQ EQ '1'
     AND PERNR EQ PV_PERNR
     AND LVORM EQ ' '.

  IF SY-SUBRC NE 0.
    MESSAGE E003 WITH '결재자 사번이 권한 마스터에 존재하지 않습니다.'.
  ENDIF.

ENDFORM.                    " CHECK_APPLOVAL_USER

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1200 INPUT.

  CLEAR : OK_SAVE.
  OK_SAVE = OK_CODE.
  CLEAR : OK_CODE.

  CASE OK_SAVE.
    WHEN 'SAVE'.
      CLEAR GV_ERROR.
      PERFORM DATA_CHECK_PERNR USING GV_ERROR.
      CHECK GV_ERROR NE 'X'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1200  INPUT

*&---------------------------------------------------------------------*
*&      Module  F4HELP_PERNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_PERNR INPUT.

  CLEAR   : GT_PERNR.
  REFRESH : GT_PERNR.

  SELECT A~PERNR
         B~ENAME
    INTO TABLE GT_PERNR
    FROM ZNFT1090 AS A
   INNER JOIN PA0001 AS B
      ON A~PERNR EQ  B~PERNR
     AND B~ENDDA GE SY-DATLO
     AND B~BEGDA LE SY-DATLO
   WHERE A~CONGB EQ  '2'
     AND A~CONSQ EQ  '1'
     AND A~LVORM EQ  ' '.

  IF SY-SUBRC NE 0.
    MESSAGE E003
       WITH '결재자 사번을 찾을수 없습니다.'.
  ELSE.
    SORT GT_PERNR BY ENAME.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD     = 'PERNR'
        DYNPPROG     = SY-CPROG
        DYNPNR       = SY-DYNNR
        DYNPROFIELD  = 'GV_PERNR'
        WINDOW_TITLE = '결재자사번'
        VALUE_ORG    = 'S'
      TABLES
        VALUE_TAB    = GT_PERNR.

    IF SY-SUBRC NE 0.
      MESSAGE ID SY-MSGID
            TYPE SY-MSGTY
          NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDMODULE.                 " F4HELP_PERNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_PERNR_CLEAR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_PERNR_CLEAR INPUT.

  IF GV_PERNR IS INITIAL.
    CLEAR GV_ENAME.
  ENDIF.

ENDMODULE.                 " CHECK_PERNR_CLEAR  INPUT
