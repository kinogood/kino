*&---------------------------------------------------------------------*
*& Include          ZGTPPR2120I01
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
      IF GV_CHK_EDIT_101 = ABAP_TRUE OR GV_CHK_EDIT = ABAP_TRUE.
        CLEAR GV_ANSWER.
        PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
          ' '
          '변경된 요청계획이 있습니다. 저장 없이 종료 하시겠습니까?'
          '종료확인'.
        IF GV_ANSWER NE 'J'.
          MESSAGE S003 DISPLAY LIKE 'E' WITH '종료 취소 되었습니다.'.
          RETURN.
        ENDIF.
      ENDIF.

*     종료
      CALL METHOD GO_DOCKING_0100->FREE.

      FREE : GO_DOCKING_0100, GO_SPLITTER_0100.
      FREE : GO_CONTAIN_0100, GO_CONTAIN_TOP_0100.
      FREE : GO_GRID_0100.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      IF NOT ( GV_CHK_EDIT_101 = ABAP_TRUE OR GV_CHK_EDIT = ABAP_TRUE ).
        MESSAGE S003 DISPLAY LIKE 'E' WITH '수정된 계획이 없습니다.'.
        RETURN.
      ENDIF.

      PERFORM SAVE_PLAN.

    WHEN 'REFRESH'.

      IF GV_CHK_EDIT_101 = ABAP_TRUE OR GV_CHK_EDIT = ABAP_TRUE.
        CLEAR GV_ANSWER.
        PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
          ' '
          '변경된 요청계획이 있습니다. Refresh 하시겠습니까?'
          'Refresh 확인'.
        IF GV_ANSWER NE 'J'.
          MESSAGE S003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
          RETURN.
        ENDIF.
      ENDIF.

* 대상정보 추출.
      PERFORM GET_DATA.

* 대상정보 추출.
      PERFORM SET_DISP_TABLE.

      PERFORM SET_SCREEN_101.
      PERFORM SET_WITH_MAIN USING GV_CHK_DETAIL.

* 화면 초기화
      PERFORM REFRESH_0100.
      PERFORM REFRESH_0101.

      CLEAR : GV_CHK_EDIT, GV_CHK_EDIT_101.

    WHEN 'CHANGE_101'.
      PERFORM CHANGE_ICON_DETAIL.

  ENDCASE.

ENDMODULE.
