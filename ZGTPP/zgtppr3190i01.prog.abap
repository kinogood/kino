*&---------------------------------------------------------------------*
*& Include          ZGTPPR3190I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.
  CASE GV_OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      PERFORM CLS_OBJT_RTN.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE GV_OK_CODE.
    WHEN 'TRS_B'.
      PERFORM PROCESS_TRANS_B.       "재고 비활성(보류재고 이전)
    WHEN 'TRS_BC'.
      PERFORM PROCESS_TRANS_BC.      "재고 비활성(보류재고 이전) 취소
    WHEN 'REFRESH'.
      PERFORM PROC_REFRESH.
    WHEN 'CONV_STOCK'.
      PERFORM PROC_CONV_STOCK.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  CLEAR GV_OK_CODE2.
  GV_OK_CODE2 = SY-UCOMM.
  CLEAR SY-UCOMM.
  CASE GV_OK_CODE2.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR: GV_MENGE.
      LEAVE TO SCREEN 0.
    WHEN 'TRANS' OR 'TRANS_C'.
      IF GV_MENGE IS NOT INITIAL.
        GV_CHK = 'X'.
        LEAVE TO SCREEN 0.
      ELSE.
        MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-E01.
      ENDIF.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  CLEAR GV_OK_CODE3.
  GV_OK_CODE3 = SY-UCOMM.

  CASE GV_OK_CODE3.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR GV_CHK_SAVE_0300.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      GV_CHK_SAVE_0300 = ABAP_TRUE.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0400 INPUT.

  CLEAR GV_OK_CODE4.
  GV_OK_CODE4 = SY-UCOMM.

  CASE GV_OK_CODE4.
    WHEN 'BACK' OR 'EXIT' OR 'CANC' OR 'CONFIRM'.

*     종료
      CALL METHOD GO_CONTAIN_0400->FREE.
      CLEAR : GO_CONTAIN_0400, GO_GRID_0400.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
