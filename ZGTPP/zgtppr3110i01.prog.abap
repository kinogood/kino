*&---------------------------------------------------------------------*
*& Include          ZGTPPR3110I01
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
      PERFORM GET_PROC.
      PERFORM REFRESH_GRID USING GO_GRID_0100.

    WHEN 'INPUT'.
      PERFORM PROC_INPUT.
      PERFORM REFRESH_GRID USING GO_GRID_0100.

    WHEN 'CONFIRM'.
      PERFORM PROC_CONFIRM.
      PERFORM REFRESH_GRID USING GO_GRID_0100.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  GO_GRID_0200->CHECK_CHANGED_DATA( ).

  CLEAR GV_OK_CODE2.
  GV_OK_CODE2 = SY-UCOMM.
  CLEAR SY-UCOMM.
  CASE GV_OK_CODE2.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      IF GV_CHK_CHG IS NOT INITIAL.
        CLEAR GV_ANSWER.
        PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
          ' '
          '사유가 입력되었습니다. 종료 하시겠습니까?'(M05)
          '종료확인'(M06).
        IF GV_ANSWER NE 'J'.
          RETURN.
        ENDIF.
      ENDIF.
*     종료
      CLEAR GV_CHK_CHG.
      CALL METHOD GO_CONTAIN_0200->FREE.
      CLEAR : GO_CONTAIN_0200, GO_GRID_0200.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      IF GV_CHK_CHG IS INITIAL.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '변경된 내용이 없습니다.'(M04).
        RETURN.
      ENDIF.

      CLEAR GV_ANSWER.
      PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
        ' '
        '차이 사유 입력된 내용이 저장됩니다. 계속 진행 하시겠습니까?'(M01)
        '저장확인'(M02).
      IF GV_ANSWER NE 'J'.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'(M03).
        RETURN.
      ENDIF.

*     저장
      PERFORM SAVE_REASON.

      CLEAR GV_CHK_CHG.

*    저장후 종료
      CALL METHOD GO_CONTAIN_0200->FREE.
      CLEAR : GO_CONTAIN_0200, GO_GRID_0200.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

    WHEN 'WRITE_ALL'.
      PERFORM WRITE_ALL.
      PERFORM REFRESH_GRID USING GO_GRID_0200.
    WHEN 'AA'.
*      PERFORM SET_ORDER_INFOR.


  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SET_ORDER_INFOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_ORDER_INFOR INPUT.

  PERFORM SET_ORDER_INFOR.

ENDMODULE.
