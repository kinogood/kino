*----------------------------------------------------------------------*
***INCLUDE ZNFR2220I01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CASE OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR : OK_CODE.

      SET SCREEN 0.

  ENDCASE.

ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  SAVE_OK_CODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SAVE_OK_CODE INPUT.

  OK_SAVE = OK_CODE.

  CLEAR : OK_CODE.

ENDMODULE.                 " SAVE_OK_CODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  PERFORM GET_SELECTED_ROWS_1.

  CASE OK_SAVE.
    WHEN 'FUTU'.
      PERFORM CALL_SCREEN_0200.

    WHEN 'RFSH'.
      PERFORM GET_ZNFT1020_DATA.

    WHEN 'ASEL' OR 'DSEL'.
      PERFORM SELECT_ALL.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0110 INPUT.

*  PERFORM GET_SELECTED_ROWS_1.

  IF OK_CODE IS INITIAL.
    SET SCREEN 0.
  ENDIF.

  CASE OK_CODE.
    WHEN 'CONT'.
      PERFORM EXEC_MASS_INPUT.

  ENDCASE.



*  CASE OK_SAVE.
**    WHEN 'FUTU'.
**      PERFORM CALL_SCREEN_0200.
**
**    WHEN 'RFSH'.
**      PERFORM GET_ZNFT1020_DATA.
**
**    WHEN 'ASEL' OR 'DSEL'.
**      PERFORM SELECT_ALL.
*
*
*    WHEN 'MASS'.         "Screen 0110 - 계속
*      PERFORM EXEC_MASS_INPUT.
*
*    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     LEAVE TO SCREEN 0.
*
*  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0110  INPUT

*&---------------------------------------------------------------------*
*&      Module  GET_CURSOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR INPUT.

  GET CURSOR FIELD GV_CURSOR LINE GV_CURLIN.

ENDMODULE.                 " GET_CURSOR  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CASE OK_SAVE.
    WHEN 'SAVE'.
      PERFORM SAVE_FUTURE_TRANSACTION USING ' '.

    WHEN 'REQT'.
      PERFORM SAVE_FUTURE_TRANSACTION USING 'X'.

    WHEN 'ASEL' OR 'DSEL'.
      PERFORM SELECT_ALL.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      PERFORM GET_ZNFT1020_DATA.

    WHEN 'MASS'.
      PERFORM GET_SELECTED_ROWS.
      CALL SCREEN 0110 STARTING AT 20 5.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_ITAB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_ITAB INPUT.

  READ TABLE GT_TRAN INDEX TC1-CURRENT_LINE
                     TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    IF GT_TRAN-MITYP = 'S'.
      CLEAR : GT_TRAN-MISPD, GT_TRAN-MIMON.
    ENDIF.

    PERFORM GET_LIFNR_DESC USING GT_TRAN-FCM
                                 GT_TRAN-NAME1.

*--> 비철 CME 관리 추가
    IF GT_TRAN-MEINS IS NOT INITIAL.
      IF GT_TRAN-MEINS <> 'TON' AND GT_TRAN-MEINS <> 'LB'.
        MESSAGE E003 WITH '단위는 TON or LB만 입력 가능합니다.'.
      ENDIF.
    ENDIF.
*<-- 비철 CME 관리 추가

    MODIFY GT_TRAN INDEX TC1-CURRENT_LINE
                   TRANSPORTING CHECK RUDAT FCM   NAME1 NFKEY BY_SL
                                ENDAT MITYP MISPD MIMON MISUS PRICE
                                EMENG ZEPRO BIGO4
                                MEINS. " 비철 CME 관리 추가
  ENDIF.

ENDMODULE.                 " MODIFY_ITAB  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_FCM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_FCM INPUT.

  PERFORM F4HELP_FCM USING GT_TRAN-FCM.

ENDMODULE.                 " F4HELP_FCM  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_MIMON  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_MIMON INPUT.

  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      ACTUAL_MONTH   = SY-DATLO(6)
    IMPORTING
      SELECTED_MONTH = GT_TRAN-MIMON.

ENDMODULE.                 " F4HELP_MIMON  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_ZEPRO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_ZEPRO INPUT.

  PERFORM F4HELP_ZEPRO USING GT_TRAN-ZEPRO.

ENDMODULE.                 " F4HELP_ZEPRO  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_EPRO_CHANGED  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_EPRO_CHANGED INPUT.

  CLEAR : ZNFT1021, GV_CHANGE.

  CHECK GT_TRAN-ZEPRO IS NOT INITIAL.

  SELECT SINGLE *
    FROM ZNFT1021
   WHERE BUKRS = P_BUKRS
     AND ZEPRO = GT_TRAN-ZEPRO.

  IF SY-SUBRC = 0.
    IF ZNFT1021-YNFIN = 'X'.
      MESSAGE E003 WITH 'e-Pro 번호' GT_TRAN-ZEPRO
                        '은(는) 마감되었습니다.'.
    ENDIF.

    GV_CHANGE = 'X'.
  ELSE.
    MESSAGE E003 WITH 'e-Pro 번호' GT_TRAN-ZEPRO
                      '은(는) 존재하지 않습니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_EPRO_CHANGED  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_FCM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_FCM INPUT.

  CHECK GT_TRAN-FCM IS NOT INITIAL.

  SELECT SINGLE A~LIFNR
    INTO GT_TRAN-FCM
    FROM ZNFT0021 AS A
   INNER JOIN LFA1 AS B
      ON A~LIFNR = B~LIFNR
   WHERE A~BUKRS = P_BUKRS
     AND A~LIFNR = GT_TRAN-FCM
     AND B~LOEVM = ' '.

  IF SY-SUBRC <> 0.
    MESSAGE E003 WITH 'FCM' GT_TRAN-FCM
                      '이(가) 존재하지 않습니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_FCM  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_RUDAT_FCM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_RUDAT_FCM INPUT.

  CHECK GV_CHANGE = 'X'.

  IF GT_TRAN-NFKEY <> ZNFT1021-NFKEY.
    MESSAGE E003 WITH 'e-Pro 정보의 비철품목을 확인하시기 바랍니다.'.
  ENDIF.

  IF GT_TRAN-BY_SL IS NOT INITIAL AND
     GT_TRAN-BY_SL <> ZNFT1021-BY_SL.
    MESSAGE E003 WITH 'e-Pro 정보의 Buy/Sell을 확인하시기 바랍니다.'.
  ENDIF.

  IF GT_TRAN-RUDAT IS NOT INITIAL AND
     GT_TRAN-RUDAT <> ZNFT1021-RUDAT.
    MESSAGE E003 WITH 'e-Pro 정보의 집행일을 확인하시기 바랍니다.'.
  ENDIF.

  IF GT_TRAN-FCM IS NOT INITIAL AND
     GT_TRAN-FCM <> ZNFT1021-FCM.
    MESSAGE E003 WITH 'e-Pro 정보의 FCM을 확인하시기 바랍니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_RUDAT_FCM  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_REMAIN_QUANTITY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_REMAIN_QUANTITY INPUT.

  CHECK GT_TRAN-ZEPRO IS NOT INITIAL.

  PERFORM CHECK_EPRO_REMAIN_QUANTITY USING P_BUKRS
                                           GT_TRAN-ZEPRO
                                           TC1-CURRENT_LINE
                                           GV_REMQTY
                                           GV_ERROR.

  IF GV_ERROR IS INITIAL.
    IF GT_TRAN-EMENG > GV_REMQTY.
      MESSAGE I003 DISPLAY LIKE 'W'
         WITH 'e-Pro 번호' GT_TRAN-ZEPRO
              '의 잔량보다 큰 값이 입력되었습니다.'.
    ENDIF.
  ELSE.
    MESSAGE I003 DISPLAY LIKE 'W'
       WITH 'e-Pro 번호' GT_TRAN-ZEPRO
            '에 잔량이 존재하지 않습니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_REMAIN_QUANTITY  INPUT
*&---------------------------------------------------------------------*
*&      Module  APPLY_EPRO_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE APPLY_EPRO_DATA INPUT.

  CHECK GV_CHANGE = 'X'.

  CLEAR : GV_CHANGE.

  GT_TRAN-RUDAT = ZNFT1021-RUDAT.
  GT_TRAN-FCM   = ZNFT1021-FCM.
  GT_TRAN-NFKEY = ZNFT1021-NFKEY.
  GT_TRAN-ENDAT = ZNFT1021-ENDAT.
  GT_TRAN-MITYP = ZNFT1021-MITYP.
  GT_TRAN-MISPD = ZNFT1021-MISPD.
  GT_TRAN-MIMON = ZNFT1021-MIMON.
  GT_TRAN-PRICE = ZNFT1021-PRICE.
  GT_TRAN-MISUS = ZNFT1021-MISUS.

  IF GT_TRAN-EMENG IS INITIAL.
    GT_TRAN-EMENG = GV_REMQTY.
  ENDIF.

ENDMODULE.                 " APPLY_EPRO_DATA  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_MIMON  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_MIMON INPUT.

  CHECK GT_TRAN-MIMON IS NOT INITIAL.

  IF GT_TRAN-MIMON+4(2) < '01' OR GT_TRAN-MIMON+4(2) > '12'.
    MESSAGE E001 WITH '청산기준월을 점검하시기 바랍니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_MIMON  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_SETTLEMENT_FCM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_SETTLEMENT_FCM INPUT.

*___만기일/FCM에 대한 정산진행여부 점검
  PERFORM CHECK_SELLEMENT_FCM.

ENDMODULE.                 " CHECK_SETTLEMENT_FCM  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_EXPIRE_MONTH  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_EXPIRE_MONTH INPUT.

*___집행유형이 Average인 경우 만기일은 기준월과 동월이거나 이후
  CHECK GT_TRAN-ENDAT IS NOT INITIAL AND
        GT_TRAN-MIMON IS NOT INITIAL AND
        GT_TRAN-MITYP = 'A'.

  IF GT_TRAN-MIMON > GT_TRAN-ENDAT(6).
    MESSAGE E003 WITH '만기일은 기준월과 동월이거나'
                      '이후여야 합니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_EXPIRE_MONTH  INPUT
