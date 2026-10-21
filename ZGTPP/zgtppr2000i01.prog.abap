*&---------------------------------------------------------------------*
*& Include          ZGTPPR2000I01
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
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'REFRESH'.
      IF GT_ITEM_DISP[] IS NOT INITIAL.
        PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
          ' '
          '작업중 데이터가 있습니다. Refresh 하시겠습니까?'
          '작업확인'.
        IF GV_ANSWER EQ 'J'.
          REFRESH GT_ITEM_DISP.

          IF GO_GRID_0101 IS BOUND.
            GO_GRID_0101->FREE( ).
            FREE : GO_GRID_0101, GO_CONTAIN_0101.
          ENDIF.
        ELSE.
          RETURN.
        ENDIF.
      ENDIF.

      PERFORM GET_PROC.
      PERFORM REFRESH_GRID USING GO_GRID_0100.

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
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CASE GV_OK_CODE2.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR GV_GRPNR.
      LEAVE TO SCREEN 0.
    WHEN 'OKAY'.
      SELECT SINGLE GRPNR
         FROM ZGTPPT2000
         INTO ZGTPPT2000-GRPNR
        WHERE GRPNR = GV_GRPNR.
      IF SY-SUBRC EQ 0.
        LEAVE TO SCREEN 0.
      ELSE.
        MESSAGE I000 WITH '기존 조장구성표에 등록된 번호가 아닙니다.'.
        RETURN.
      ENDIF.
  ENDCASE.
ENDMODULE.
