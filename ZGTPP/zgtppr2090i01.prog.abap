*&---------------------------------------------------------------------*
*& Include          ZGTPPR2090I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CLEAR GV_OK_CODE.
  GV_OK_CODE = SY-UCOMM.

  CASE GV_OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.

*     종료
      CALL METHOD GO_DOCKING_0100->FREE.

      FREE : GO_DOCKING_0100, GO_SPLITTER_0100.
      FREE : GO_CONTAIN_0100, GO_CONTAIN_TOP_0100.
      FREE : GO_CONTAIN_0101, GO_CONTAIN_TOP_0101.
      FREE : GO_GRID_0100, GO_GRID_0101.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
