*&---------------------------------------------------------------------*
*& Include          ZGTPPR2110I01
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
      IF GV_CHK_EDIT IS NOT INITIAL.
        CLEAR GV_ANSWER.
        PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
          ' '
          '생산 계획이 저장되지 않았습니다. 저장 없이 종료 하시겠습니까?'
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
      IF GV_CHK_EDIT IS NOT INITIAL.
        CLEAR GV_ANSWER.
        PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
          ' '
          '생산계획 저장 하시겠습니까?'
          '저장확인'.
        IF GV_ANSWER NE 'J'.
          MESSAGE S003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
          RETURN.
        ENDIF.

        PERFORM PROC_SAVE.

      ELSE.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '변경된 생산계획이 없습니다..'.
        RETURN.
      ENDIF.

    WHEN 'VIEW_2150'.
      PERFORM VIEW_2150.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form popup_to_confirm_step
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM_STEP  USING LP_OPT
                                  LP_TEXT1
                                  LP_TEXT2
                                  LP_TITLE.
  CLEAR GV_ANSWER.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      DEFAULTOPTION  = LP_OPT
      TEXTLINE1      = LP_TEXT1
      TEXTLINE2      = LP_TEXT2
      TITEL          = LP_TITLE
      CANCEL_DISPLAY = ''
    IMPORTING
      ANSWER         = GV_ANSWER.

ENDFORM.
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
      CALL METHOD GO_DOCKING_0300->FREE.

      FREE : GO_DOCKING_0300.
      FREE : GO_SPLITTER_0300.
      FREE : GO_CONTAIN_TOP_0300.
      FREE : GO_CONTAIN_0300.
      FREE : GO_DD_DOCU_0300.
      FREE : GO_GRID_0300.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.


      GV_CHK_STATUS_300 = 'S'.

*     종료
      CALL METHOD GO_DOCKING_0300->FREE.
      FREE : GO_DOCKING_0300.
      FREE : GO_SPLITTER_0300.
      FREE : GO_CONTAIN_TOP_0300.
      FREE : GO_CONTAIN_0300.
      FREE : GO_DD_DOCU_0300.
      FREE : GO_GRID_0300.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

  ENDCASE.

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
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CALL METHOD GO_DOCKING_0400->FREE.

      FREE : GO_DOCKING_0400.
      FREE : GO_SPLITTER_0400.
      FREE : GO_CONTAIN_TOP_0400.
      FREE : GO_CONTAIN_0400.
      FREE : GO_DD_DOCU_0400.
      FREE : GO_GRID_0400.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.


      GV_CHK_STATUS_400 = 'S'.

*     종료
      CALL METHOD GO_DOCKING_0400->FREE.
      FREE : GO_DOCKING_0400.
      FREE : GO_SPLITTER_0400.
      FREE : GO_CONTAIN_TOP_0400.
      FREE : GO_CONTAIN_0400.
      FREE : GO_DD_DOCU_0400.
      FREE : GO_GRID_0400.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
