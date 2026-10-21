*&---------------------------------------------------------------------*
*& Include          ZGTPPI2040I01
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
      CALL METHOD GO_DOCKING_CONTAINER->FREE.
      FREE : GO_DOCKING_CONTAINER, GO_SPLITTER, GO_SPLIT_CONTAINER.
      FREE : GO_SPLITTER2, GO_CONTAIN_0100, GO_GRID_0100.
      FREE : GO_CONTAIN_0101, GO_GRID_0101.
      FREE : GO_CONTAIN_0102, GO_GRID_0102.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

    WHEN 'REFRESH'.
      PERFORM GET_PROC.
      PERFORM REFRESH_GRID USING GO_GRID_0100.
      PERFORM REFRESH_GRID USING GO_GRID_0101.
      PERFORM REFRESH_GRID USING GO_GRID_0102.

    WHEN 'SEND'. " 전송

      PERFORM PROC_ONLINE_SEND.


    WHEN 'RESEND'. " 재전송

      PERFORM PROC_ONLINE_RESEND.

  ENDCASE.

ENDMODULE.
