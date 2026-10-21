*&---------------------------------------------------------------------*
*&  Include           ZNFR2614I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE EXIT INPUT.

  CASE SY-UCOMM.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1100  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_1100 INPUT.

  CLEAR : GV_CODE.
  GV_CODE = OK_CODE.
  CLEAR : OK_CODE.

  CASE GV_CODE.
    WHEN 'POST'.    "IN전표 일괄생성
      PERFORM GET_SELECTED_ROWS USING 'POST'.
      PERFORM CALL_SCREEN_0300.

    WHEN 'CANE'.    "IN전표 역분개
      PERFORM GET_SELECTED_ROWS USING 'CANE'.
      PERFORM CALL_SCREEN_0200.

    WHEN 'REFR'.    "재조회
      PERFORM DATA_SELECT.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1100  INPUT

*&---------------------------------------------------------------------*
*&      Module  SAVE_OK_CODE  INPUT
*&---------------------------------------------------------------------*
MODULE SAVE_OK_CODE INPUT.

  OK_SAVE = OK_CODE.

  CLEAR : OK_CODE.

ENDMODULE.                 " SAVE_OK_CODE  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT  (역분개)
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CASE OK_SAVE.
    WHEN 'REVS'.    "전표역분개
      IF GV_BUDAT IS INITIAL.
        MESSAGE '역분개 전기일을 입력해 주세요.'
           TYPE 'S' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      PERFORM REVERSE_FI_DOC.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT  (전표생성)
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  CASE OK_SAVE.
    WHEN 'CONT'.    "전표생성
      IF GV_BUDAT IS INITIAL OR GV_BLDAT IS INITIAL.
        MESSAGE '전기일/증빙일을 입력해 주세요.'
           TYPE 'S' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      PERFORM CREATE_FI_DOC.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0300  INPUT
