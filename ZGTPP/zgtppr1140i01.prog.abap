*&---------------------------------------------------------------------*
*& Include          ZGTPPR1140I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CLEAR GV_OK_CODE.
  GV_OK_CODE = SY-UCOMM.
  CLEAR SY-UCOMM.

  CASE GV_OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.

*     종료
      CALL METHOD GO_DOCKING_0100->FREE.
      CLEAR : GO_DOCKING_0100, GO_GRID_0100.
      CLEAR GS_LAYOUT_0100.
      REFRESH : GT_SORT_0100, GT_EXCLUDE_0100, GT_FIELDCAT_0100.

      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

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

*     종료
      CALL METHOD GO_DOCKING_0200->FREE.
      CLEAR : GO_DOCKING_0200, GO_GRID_0200.
      CLEAR GS_LAYOUT_0200.
      REFRESH : GT_SORT_0200, GT_EXCLUDE_0200, GT_FIELDCAT_0200.

      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

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
  CLEAR SY-UCOMM.

  CASE GV_OK_CODE3.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.

*     종료
      CALL METHOD GO_DOCKING_0300->FREE.
      CLEAR : GO_DOCKING_0300, GO_GRID_0300.
      CLEAR GS_LAYOUT_0300.
      REFRESH : GT_SORT_0300, GT_EXCLUDE_0300, GT_FIELDCAT_0300.

      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
