*&---------------------------------------------------------------------*
*&  Include           ZNFR2510I01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           ZNFR2250I01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CLEAR : GV_PERNR, GV_ENAME, GV_PASSWD.
  CLEAR : GV_CONSQ.

  CASE SY-UCOMM..
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1200 INPUT.

  CLEAR : OK_SAVE, GV_ERROR.
  OK_SAVE = OK_CODE.
  CLEAR : OK_CODE.

  CASE OK_SAVE.
    WHEN 'ALLOW'.
      PERFORM DATA_ALLOW.
      PERFORM DATA_RELOAD.
    WHEN 'REJECT'.
      PERFORM DATA_REJECT.
      PERFORM DATA_RELOAD.
    WHEN 'ASEL' OR 'DSEL'.
      PERFORM SELECT_ALL.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1200  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1210 INPUT.

  CLEAR : OK_SAVE.
  OK_SAVE = OK_CODE.
  CLEAR : OK_CODE.

  CASE OK_SAVE.
    WHEN 'CONF'.
*     ### 승인처리
      PERFORM PASWD_CHECK USING GV_ERROR.
      IF GV_ERROR IS INITIAL.
        LEAVE TO SCREEN 0.
      ENDIF.
    WHEN 'CANC'.
      GV_ERROR = 'X'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1210  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_PASSWORD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_PASSWORD INPUT.

* ----------------------------------------
*  ###    사번 입력후 체크로직    ###
* ----------------------------------------
  DATA: LV_PERNR  TYPE PERNR_D,
        LV_PASSWD TYPE FIEB_ENCRYPTED_PASSWD.

  CLEAR: GV_ERROR, LV_PASSWD.

* ### 선택한 데이터에 대한 사번체크 ###
  CHECK GV_PERNR IS NOT INITIAL.

  LOOP AT GT_OUTTAB_A INTO GS_OUTTAB_A WHERE CHECK EQ 'X'.
    CLEAR : LV_PERNR.

    SELECT SINGLE Z1~PERNR INTO LV_PERNR
      FROM ZNFT1090 AS Z1
           INNER JOIN ZNFT1091 AS Z2
              ON Z2~BUKRS EQ Z1~BUKRS AND Z2~CONGB EQ Z1~CONGB
             AND Z2~CONSQ EQ Z1~CONSQ AND Z2~PERNR EQ Z1~PERNR
     WHERE Z1~BUKRS EQ P_BUKRS
       AND Z1~CONGB EQ '2'
       AND Z1~CONSQ EQ GS_OUTTAB_A-CONSQ
       AND Z2~NFNUM EQ GS_OUTTAB_A-REQNO
       AND Z1~PERNR EQ GV_PERNR.         " 공용ID인경우 : 입력사번

    IF LV_PERNR IS INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH GS_OUTTAB_A-REQNO '는 승인권한이 없는 요청번호입니다.'.
      GV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

  CHECK GV_ERROR IS INITIAL.

* ### PASSWORD CHECK ###
  SELECT SINGLE PASWD INTO LV_PASSWD
    FROM ZNFT1090
   WHERE BUKRS EQ P_BUKRS
     AND CONGB EQ '2'
     AND CONSQ IN (1,2,3,4)
     AND PERNR EQ GV_PERNR.   " 입력한 사번

  IF SY-SUBRC EQ 0.
    IF LV_PASSWD NE GV_PASSWD.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '비밀번호가 틀립니다. 다시 입력하십시오.'.
      GV_ERROR = 'X'.
      EXIT.
    ELSE.

    ENDIF.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '승인자 관리정보가 존재하지 않습니다.'.
    GV_ERROR = 'X'.
    EXIT.
  ENDIF.

ENDMODULE.                 " CHECK_PASSWORD  INPUT
