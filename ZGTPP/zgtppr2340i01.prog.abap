*&---------------------------------------------------------------------*
*& Include          ZGTPPR2340I01
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
    WHEN 'CHG_SM'.
      PERFORM PROC_CHG_TYPE USING 'SM'.

    WHEN 'CHG_OM'.
      PERFORM PROC_CHG_TYPE USING 'OM'.

    WHEN 'CR_PR'.
      PERFORM PROC_CREATE_PR.

    WHEN 'DEL_PR'.
      PERFORM PROC_DELETE_PR.

    WHEN 'REFRESH'.
      PERFORM GET_PROC.
      PERFORM REFRESH_GRID USING GO_GRID_0100.
  ENDCASE.

ENDMODULE.
