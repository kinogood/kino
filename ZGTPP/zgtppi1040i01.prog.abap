*&---------------------------------------------------------------------*
*& Include          ZGTPPI1040I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.


  CASE GV_OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.

*     종료
      CALL METHOD GO_CONTAIN_0100->FREE.
      CLEAR : GO_CONTAIN_0100, GO_GRID_0100.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'SEND'.
      PERFORM PROCESS_SEND.

    WHEN 'RESEND'.
      PERFORM PROCESS_SEND.

  ENDCASE.

ENDMODULE.
