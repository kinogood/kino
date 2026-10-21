*&---------------------------------------------------------------------*
*& Include          ZGTPPR2220I01
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
      IF GV_CHK_CHG IS NOT INITIAL.
        CLEAR GV_ANSWER.
        PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
          ' '
          '변경된 데이터가 있습니다. 종료하시겠습니까?'(M01)
          '종료확인'(M02).
        IF GV_ANSWER = 'J'.
        ELSE.
          MESSAGE S000 WITH '작업이 취소 되었습니다.'(M03).
          RETURN.
        ENDIF.
      ENDIF.

*     종료
      CALL METHOD GO_DOCKING_CONTAINER->FREE.
      FREE : GO_DOCKING_CONTAINER, GO_SPLITTER, GO_SPLITTER2, GO_BOTTOM_CONTAINER,
               GO_CONTAIN_0101, GO_GRID_0101,
               GO_CONTAIN_0102, GO_GRID_0102,
               GO_CONTAIN_0100, GO_GRID_0100.

      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'REFRESH'.
      IF GV_CHK_CHG IS NOT INITIAL.
        CLEAR GV_ANSWER.
        PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
          ' '
          '변경된 데이터가 있습니다. Refresh 하시겠습니까?'(M04)
          'Refresh 확인'(M05).
        IF GV_ANSWER = 'J'.
        ELSE.
          MESSAGE S000 WITH '작업이 취소 되었습니다.'(M03).
          RETURN.
        ENDIF.
      ENDIF.

      CLEAR : GV_ZVERS_NO, GV_ZVERS_DESC, GV_ARBPL, GV_KTEXT.
      PERFORM GET_DATA_FR_DB.

      PERFORM REFRESH_GRID USING GO_GRID_0100.
      PERFORM REFRESH_GRID USING GO_GRID_0101.
      PERFORM REFRESH_GRID USING GO_GRID_0102.

    WHEN 'SAVE'.
      IF GV_CHK_CHG IS INITIAL.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '변경된 내용이 없습니다.'.
        RETURN.
      ENDIF.

      CLEAR GV_ANSWER.
      PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
        ' '
        '변경된 데이터가 있습니다. 저장 하시겠습니까?'(M09)
        '저장 확인'(M10).
      IF GV_ANSWER = 'J'.
      ELSE.
        MESSAGE S000 WITH '작업이 취소 되었습니다.'(M03).
        RETURN.
      ENDIF.

      MODIFY ZGTPPT2360 FROM TABLE GT_2360_CHG.
      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
      ENDIF.

      CLEAR : GV_ZVERS_NO, GV_ZVERS_DESC, GV_ARBPL, GV_KTEXT.
      PERFORM GET_DATA_FR_DB.

      PERFORM REFRESH_GRID USING GO_GRID_0100.
      PERFORM REFRESH_GRID USING GO_GRID_0101.
      PERFORM REFRESH_GRID USING GO_GRID_0102.

      MESSAGE S006  WITH '데이터 저장되었습니다.'.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CASE GV_OK_CODE2.
    WHEN 'BACK' OR 'EXIT' OR 'CANC' OR 'NO'.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      PERFORM PROC_CONFIRM_ARBPL.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4HELP_ARBPL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_ARBPL INPUT.

  PERFORM F4HELP_ARBPL.

ENDMODULE.
