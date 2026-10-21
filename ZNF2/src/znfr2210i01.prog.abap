*----------------------------------------------------------------------*
***INCLUDE ZNFR2210I01 .
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

      IF SY-DYNNR = '0200'.
        REFRESH : GT_COLS.
      ENDIF.

      LEAVE TO SCREEN 0.

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
      PERFORM GET_FUTURES_REQ_DATA.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  PERFORM GET_SELECTED_ROWS_2.

  CASE OK_SAVE.
    WHEN 'INPT'.         "신규선물집행등록
      PERFORM CALL_SCREEN_0300.

    WHEN 'REQT'.         "결재요청
      PERFORM CONFIRM_REQEUST.

    WHEN 'RFSH'.
      PERFORM GET_FUTURES_TRADING_DATA.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      IF SY-DYNNR = '0200'.
        REFRESH : GT_COLS.
      ENDIF.

      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  CASE OK_SAVE.
    WHEN 'SAVE'.         "저장
      PERFORM SAVE_FUTURES_TRADING USING ' '.

    WHEN 'REQT'.         "결재요청
      PERFORM SAVE_FUTURES_TRADING USING 'X'.

    WHEN 'RADD'.         "행추가
      PERFORM INSERT_ROW.

    WHEN 'RDEL'.         "행삭제
      PERFORM DELETE_ROW.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_EPRO_CHANGED  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_EPRO_CHANGED INPUT.

  CLEAR : ZNFT1021, GV_CHANGE.

  CHECK GT_1020N-ZEPRO IS NOT INITIAL.

  SELECT SINGLE *
    FROM ZNFT1021
   WHERE BUKRS = GT_1011-BUKRS
     AND ZEPRO = GT_1020N-ZEPRO.

  IF SY-SUBRC = 0.
    IF ZNFT1021-YNFIN = 'X'.
      MESSAGE E003 WITH 'e-Pro 번호' GT_1020N-ZEPRO
                        '은(는) 마감되었습니다.'.
    ENDIF.

    GV_CHANGE = 'X'.
  ELSE.
    MESSAGE E003 WITH 'e-Pro 번호' GT_1020N-ZEPRO
                      '은(는) 존재하지 않습니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_EPRO_CHANGED  INPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_ITAB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_ITAB INPUT.

  READ TABLE GT_1020N INTO GS_1020 INDEX TC1-CURRENT_LINE.
  IF SY-SUBRC = 0.
    IF GS_1020-REQNO IS INITIAL.
      PERFORM MOVE_TC1_TO_ITAB USING 'I'.
    ELSE.
      PERFORM MOVE_TC1_TO_ITAB USING 'U'.
    ENDIF.

    MODIFY GT_1020N FROM GS_1020 INDEX TC1-CURRENT_LINE.
  ELSE.
    CLEAR : GS_1020.

    PERFORM MOVE_TC1_TO_ITAB USING 'I'.

    APPEND GS_1020 TO GT_1020N.
  ENDIF.

ENDMODULE.                 " MODIFY_ITAB  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_REMAIN_QUANTITY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_REMAIN_QUANTITY INPUT.

  CHECK GT_1020N-ZEPRO IS NOT INITIAL.

  PERFORM CHECK_EPRO_REMAIN_QUANTITY USING GT_1011-BUKRS
                                           GT_1020N-ZEPRO
                                           TC1-CURRENT_LINE
                                           GV_REMQTY
                                           GV_ERROR.

  IF GV_ERROR IS INITIAL.
    IF GT_1020N-EMENG > GV_REMQTY.
      MESSAGE I003 DISPLAY LIKE 'W'
         WITH 'e-Pro 번호' GT_1020N-ZEPRO
              '의 잔량보다 큰 값이 입력되었습니다.'.
    ENDIF.
  ELSE.
    MESSAGE I003 DISPLAY LIKE 'W'
       WITH 'e-Pro 번호' GT_1020N-ZEPRO
            '에 잔량이 존재하지 않습니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_REMAIN_QUANTITY  INPUT
*&---------------------------------------------------------------------*
*&      Module  APPLY_EPRO_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE APPLY_EPRO_DATA INPUT.

  IF GV_CHANGE = 'X'.
    CLEAR : GV_CHANGE.

    GT_1020N-RUDAT = ZNFT1021-RUDAT.
    GT_1020N-FCM   = ZNFT1021-FCM.
    GT_1020N-ENDAT = ZNFT1021-ENDAT.
    GT_1020N-MITYP = ZNFT1021-MITYP.
    GT_1020N-MISPD = ZNFT1021-MISPD.
    GT_1020N-MIMON = ZNFT1021-MIMON.
    GT_1020N-PRICE = ZNFT1021-PRICE.
    GT_1020N-MISUS = ZNFT1021-MISUS.

    IF GT_1020N-EMENG IS INITIAL.
      GT_1020N-EMENG = GV_REMQTY.
    ENDIF.
  ENDIF.

  PERFORM CHECK_REQ_REMAIN_QUANTITY.

ENDMODULE.                 " APPLY_EPRO_DATA  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_RUDAT_FCM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_RUDAT_FCM INPUT.

  CHECK GV_CHANGE = 'X'.

  IF GT_1011-NFKEY <> ZNFT1021-NFKEY.
    MESSAGE E003 WITH 'e-Pro 정보의 비철품목을 확인하시기 바랍니다.'.
  ENDIF.

  IF GT_1011-BY_SL <> ZNFT1021-BY_SL.
    MESSAGE E003 WITH 'e-Pro 정보의 Buy/Sell을 확인하시기 바랍니다.'.
  ENDIF.

  IF GT_1020N-RUDAT IS NOT INITIAL AND
     GT_1020N-RUDAT <> ZNFT1021-RUDAT.
    MESSAGE E003 WITH 'e-Pro 정보의 집행일을 확인하시기 바랍니다.'.
  ENDIF.

  IF GT_1020N-FCM IS NOT INITIAL AND
     GT_1020N-FCM <> ZNFT1021-FCM.
    MESSAGE E003 WITH 'e-Pro 정보의 FCM을 확인하시기 바랍니다.'.
  ENDIF.

  IF GT_1011-ENDMM <> ZNFT1021-ENDAT(6).
    MESSAGE I003 DISPLAY LIKE 'W'
       WITH '선물요청 만기월과 만기일의 년월이 다릅니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_RUDAT_FCM  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_FCM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_FCM INPUT.

  PERFORM F4HELP_FCM USING GT_1020N-FCM.

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
      SELECTED_MONTH = GT_1020N-MIMON.

ENDMODULE.                 " F4HELP_MIMON  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_ZEPRO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_ZEPRO INPUT.

  PERFORM F4HELP_ZEPRO USING GT_1020N-ZEPRO.

ENDMODULE.                 " F4HELP_ZEPRO  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_FCM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_FCM INPUT.

  CHECK GT_1020N-FCM IS NOT INITIAL.

  SELECT SINGLE A~LIFNR
    INTO GT_1020N-FCM
    FROM ZNFT0021 AS A
   INNER JOIN LFA1 AS B
      ON A~LIFNR = B~LIFNR
   WHERE A~BUKRS = GT_1011-BUKRS
     AND A~LIFNR = GT_1020N-FCM
     AND B~LOEVM = ' '.

  IF SY-SUBRC <> 0.
    MESSAGE E003 WITH 'FCM' GT_1020N-FCM
                      '이(가) 존재하지 않습니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_FCM  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_ENDAT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_ENDAT INPUT.

  CHECK GT_1020N-ENDAT IS NOT INITIAL.

  IF GT_1020N-ENDAT(6) <> GT_1011-ENDMM.
    MESSAGE I003 DISPLAY LIKE 'W'
       WITH '선물요청 만기월과 만기일의 년월이 다릅니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_ENDAT  INPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_REQNO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPLAY_REQNO INPUT.

  PERFORM DISPLAY_REQNO.

ENDMODULE.                 " DISPLAY_REQNO  INPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_CONNO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPLAY_CONNO INPUT.

  PERFORM DISPLAY_CONNO.

ENDMODULE.                 " DISPLAY_CONNO  INPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR OUTPUT.

  SET CURSOR FIELD GV_CURSOR LINE GV_CURLIN.

ENDMODULE.                 " SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_CURSOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR INPUT.

  GET CURSOR FIELD GV_CURSOR LINE GV_CURLIN.

ENDMODULE.                 " GET_CURSOR  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_MIMON  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_MIMON INPUT.

  CHECK GT_1020N-MIMON IS NOT INITIAL.

  IF GT_1020N-MIMON+4(2) < '01' OR GT_1020N-MIMON+4(2) > '12'.
    MESSAGE E001 WITH '기준월을 점검하시기 바랍니다.'.
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
  CHECK GT_1020N-ENDAT IS NOT INITIAL AND
        GT_1020N-MIMON IS NOT INITIAL AND
        GT_1020N-MITYP = 'A'.

  IF GT_1020N-MIMON > GT_1020N-ENDAT(6).
    MESSAGE E003 WITH '만기일은 기준월과 동월이거나'
                      '이후여야 합니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_EXPIRE_MONTH  INPUT
