*----------------------------------------------------------------------*
***INCLUDE ZNFR2200I01 .
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

  CASE OK_SAVE.
    WHEN 'SAVE'.     "저장
      PERFORM SAVE_CONFIRM_DATA.

    WHEN 'RFSH'.     "Refresh
      PERFORM GET_EPRO_IF_DATA.

    WHEN 'ASEL' OR 'DSEL'.
      PERFORM SET_SELECT_ALL.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
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
      SELECTED_MONTH = GT_MAIN-MIMON.

ENDMODULE.                 " F4HELP_MIMON  INPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_ITAB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_ITAB INPUT.

  READ TABLE GT_MAIN INDEX TC1-CURRENT_LINE
                     TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    MODIFY GT_MAIN INDEX TC1-CURRENT_LINE
                   TRANSPORTING CHECK BY_SL MISPD MIMON
                                PRICE EMENG MISUS ZNOTE.
  ENDIF.

ENDMODULE.                 " MODIFY_ITAB  INPUT
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

  IF GT_MAIN-MIMON+4(2) < '01' OR GT_MAIN-MIMON+4(2) > '12'.
    MESSAGE E001 WITH '기준월을 점검하시기 바랍니다.'.
  ENDIF.

ENDMODULE.                 " CHECK_MIMON  INPUT
