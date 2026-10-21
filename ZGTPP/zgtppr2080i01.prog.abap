*&---------------------------------------------------------------------*
*& Include          ZGTPPR2080I01
*&---------------------------------------------------------------------*
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
*     종료
      REFRESH GT_DISP_PLAN.

      CALL METHOD GO_CONTAIN_0200->FREE.

      FREE : GO_CONTAIN_0200, GO_GRID_0200.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.

      GO_GRID_0200->CHECK_CHANGED_DATA(  ).

      CASE GV_OK_CODE2.
        WHEN 'OKAY'.
          CLEAR GV_ERR_CHK.
          PERFORM CHECK_SET_PLAN CHANGING GV_ERR_CHK.
          CHECK GV_ERR_CHK IS INITIAL.

          CALL METHOD GO_CONTAIN_0200->FREE.

          FREE : GO_CONTAIN_0200, GO_GRID_0200.
          CALL METHOD CL_GUI_CFW=>FLUSH.
          LEAVE TO SCREEN 0.
        WHEN 'ALL'.
          PERFORM SET_ARBPL.
      ENDCASE.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4HELP_ARBPL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_ARBPL INPUT.

  PERFORM F4_ARBPL USING 'GS_200_TOP-ARBPL'.

  IF GS_200_TOP-ARBPL IS NOT INITIAL.
    READ TABLE GT_ARBPL INTO GS_ARBPL WITH KEY ARBPL = GS_200_TOP-ARBPL.
    IF SY-SUBRC EQ 0.
      GS_200_TOP-KTEXT = GS_ARBPL-KTEXT.
      PERFORM DISP_SCREEN_FIELD USING 'GS_200_TOP-KTEXT'.
    ENDIF.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_ARBPL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_ARBPL INPUT.

  IF GS_200_TOP-ARBPL IS NOT INITIAL.
    CLEAR GS_200_TOP-KTEXT.
    READ TABLE GT_ARBPL INTO GS_ARBPL WITH KEY ARBPL = GS_200_TOP-ARBPL.
    IF SY-SUBRC EQ 0.
      GS_200_TOP-KTEXT = GS_ARBPL-KTEXT.
    ENDIF.
  ENDIF.

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
*     종료
      CALL METHOD GO_DOCKING_0300->FREE.

      FREE : GO_DOCKING_0300, GO_SPLITTER_0300.
      FREE : GO_CONTAIN_0300, GO_CONTAIN_TOP_0300.
      FREE : GO_GRID_0300.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'OKAY'.

      CLEAR GV_ERR_CHK.
      PERFORM CHK_MATERIAL CHANGING GV_ERR_CHK.
      CHECK GV_ERR_CHK IS INITIAL.

*     종료
      CALL METHOD GO_DOCKING_0300->FREE.

      FREE : GO_DOCKING_0300, GO_SPLITTER_0300.
      FREE : GO_CONTAIN_0300, GO_CONTAIN_TOP_0300.
      FREE : GO_GRID_0300.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

    WHEN 'OKAY2'.
      IF GS_DISP_METERIAL-USECHK NE ABAP_TRUE.
        RETURN.
      ENDIF.

*     종료
      CALL METHOD GO_DOCKING_0300->FREE.

      FREE : GO_DOCKING_0300, GO_SPLITTER_0300.
      FREE : GO_CONTAIN_0300, GO_CONTAIN_TOP_0300.
      FREE : GO_GRID_0300.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
