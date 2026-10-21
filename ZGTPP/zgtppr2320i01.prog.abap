*&---------------------------------------------------------------------*
*& Include          ZGTPPR2320I01
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
      IF GV_CHK_EDIT_200 = ABAP_TRUE.

        CLEAR GV_ANSWER.
        PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
          ' '
          '수정된 내용이 있습니다. 저장 없이 나가시겠습니까?'
          '종료확인'.
        IF GV_ANSWER NE 'J'.
          MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
          RETURN.
        ENDIF.


      ENDIF.

      CALL METHOD GO_CONTAIN_0200->FREE.
      FREE : GO_CONTAIN_0200, GO_GRID_0200.
      REFRESH : GT_SORT_0200, GT_EXCLUDE_0200, GT_FIELDCAT_0200.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      PERFORM PROC_SAVE_0200.

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

  CASE GV_OK_CODE3.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     종료
      IF GV_CHK_EDIT_300 = ABAP_TRUE.

        CLEAR GV_ANSWER.
        PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
          ' '
          '수정된 내용이 있습니다. 저장 없이 나가시겠습니까?'
          '종료확인'.
        IF GV_ANSWER NE 'J'.
          MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
          RETURN.
        ENDIF.


      ENDIF.

      CALL METHOD GO_CONTAIN_0300->FREE.
      FREE : GO_CONTAIN_0300, GO_GRID_0300.
      REFRESH : GT_SORT_0300, GT_EXCLUDE_0300, GT_FIELDCAT_0300.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      PERFORM PROC_SAVE_0300.
    WHEN 'REFRESH'.
      PERFORM REFRESH_GRID USING GO_GRID_0300.

  ENDCASE.

ENDMODULE.
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

      IF GV_CHK_EDIT_100 = ABAP_TRUE.
        CLEAR GV_ANSWER.
        PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
          ' '
          '수정된 내용이 있습니다. 저장 없이 나가시겠습니까?'
          '종료확인'.
        IF GV_ANSWER NE 'J'.
          MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
          RETURN.
        ENDIF.
      ENDIF.
      CALL METHOD GO_CONTAIN_0100->FREE.
      FREE : GO_CONTAIN_0100, GO_GRID_0100.
      REFRESH : GT_SORT_0100, GT_EXCLUDE_0100, GT_FIELDCAT_0100.
      FREE GO_EVENT_HANDLER.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      PERFORM PROC_SAVE.

    WHEN 'REFRESH'.
      PERFORM REFRESH_GRID USING GO_GRID_0100.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0500 INPUT.

  CLEAR GV_OK_CODE5.
  GV_OK_CODE5 = SY-UCOMM.

  CASE GV_OK_CODE5.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.

      CALL METHOD GO_CONTAIN_0500->FREE.
      FREE : GO_CONTAIN_0500, GO_GRID_0500.
      REFRESH : GT_SORT_0500, GT_EXCLUDE_0500, GT_FIELDCAT_0500.
      FREE GO_EVENT_HANDLER.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
