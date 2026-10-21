*&---------------------------------------------------------------------*
*& Include          ZGTPPR4120I01
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
    WHEN 'REFRESH'.

      PERFORM PROC_GET_DATA.

      PERFORM REFRESH_GRID USING GO_GRID_0100.
    WHEN 'WIP'.

      PERFORM PROC_WIP. " WIP 실적취소

    WHEN 'CNC_WIP'.

      PERFORM PROC_CNC_WIP. " 실적 재처리

  ENDCASE.

ENDMODULE.
