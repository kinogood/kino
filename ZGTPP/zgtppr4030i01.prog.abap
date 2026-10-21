*&---------------------------------------------------------------------*
*& Include          ZGTPPR4030I01
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
      CALL METHOD GO_CONTAIN_0100->FREE.
      FREE : GO_CONTAIN_0100, GO_GRID_0100.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
*U01
    WHEN 'MIG'.
      PERFORM PROC_MIG.
    WHEN 'CRET11'.
      PERFORM PROC_CRET11.
    WHEN 'CANT10'.
      PERFORM PROC_CANT10.
*U01
  ENDCASE.

ENDMODULE.
