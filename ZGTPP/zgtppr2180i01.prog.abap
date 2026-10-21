*&---------------------------------------------------------------------*
*& Include          ZGTPPR2180I01
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
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CLEAR GV_OK_CODE.
  GV_OK_CODE = SY-UCOMM.

  CASE GV_OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CALL METHOD GO_CONTAIN_0100->FREE.
      FREE : GO_CONTAIN_0100, GO_GRID_0100.
      REFRESH : GT_SORT_0100, GT_EXCLUDE_0100, GT_FIELDCAT_0100.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.


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
      CLEAR GV_ZBILLING.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
