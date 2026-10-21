*&---------------------------------------------------------------------*
*& Include          ZGTPPR2300I01
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
      CALL METHOD GO_DOCKING_CONTAINER->FREE.
      CLEAR : GO_DOCKING_CONTAINER, GO_GRID_0100, GO_GRID_0101.
      CLEAR : GO_CONTAIN_0100_TOP, GO_CONTAIN_0101.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'REFRESH'.

      PERFORM GET_PROC.
      PERFORM REFRESH_GRID USING GO_GRID_0100.
      PERFORM REFRESH_GRID USING GO_GRID_0101.

    WHEN 'SETCHECK'.
      PERFORM SET_CHECK_BOX.

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

  CASE GV_OK_CODE2.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.

      CALL METHOD GO_DOCKING_0200->FREE.
      FREE : GO_DOCKING_0200, GO_SPLITTER_0200, GO_CONTAIN_0200.
      FREE : GO_CONTAIN_0201, GO_GRID_0200, GO_GRID_0201.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.


    WHEN 'CONFIRM'.
      CLEAR GV_ANSWER.
      CLEAR GV_CONTINUE_200.
      PERFORM CHECK_0200 CHANGING GV_ANSWER.

      IF GV_ANSWER IS NOT INITIAL.
        RETURN.
      ENDIF.

      GV_CONTINUE_200 = ABAP_TRUE.

      CALL METHOD GO_DOCKING_0200->FREE.
      FREE : GO_DOCKING_0200, GO_SPLITTER_0200, GO_CONTAIN_0200.
      FREE : GO_CONTAIN_0201, GO_GRID_0200, GO_GRID_0201.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4HELP_LIFNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_LIFNR INPUT.

  PERFORM F4HELP_LIFNR.

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
      GO_CONTAINER_400->FREE( ).
      GO_TEXT_400->FREE( ).
      FREE : GO_CONTAINER_400, GO_TEXT_400.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0500 INPUT.

  CLEAR GV_OK_CODE7.
  GV_OK_CODE7 = SY-UCOMM.

  CASE GV_OK_CODE7.
    WHEN 'BACK' OR 'EXIT' OR 'CANC' OR 'CONFIRM'.
      CALL METHOD GO_CONTAIN_0500->FREE.
      FREE : GO_CONTAIN_0500, GO_GRID_0500.
      FREE : GT_SORT_0500, GT_EXCLUDE_0500, GT_FIELDCAT_0500.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4HELP_LGORT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_LGORT INPUT.

   PERFORM F4HELP_LGORT.

ENDMODULE.
