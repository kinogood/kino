*&---------------------------------------------------------------------*
*& Include          ZGTSDR1410I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.
  CASE SY-UCOMM.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
*  CALL METHOD GRID->REGISTER_EDIT_EVENT
*    EXPORTING
*      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER. " 엔터 입력 시 PAI 발생

  IF P_VBELN IS INITIAL OR P_REQT IS INITIAL OR P_READTL IS INITIAL OR P_REASON IS INITIAL.
    "필수 값 &1 이 입력되지 않았습니다.
    MESSAGE S071  DISPLAY LIKE 'E' .
    EXIT.
  ENDIF.

  IF OK_CODE EQ SPACE AND GT_DATA[] IS INITIAL.
    OK_CODE = 'DISP'.
  ENDIF.

  CASE OK_CODE.
    WHEN 'DISP'.
      PERFORM GET_DATA.
    WHEN 'SAVE'.  "프로그램 미사용으로 인한 주석처리
*      PERFORM DATA_SAVE.
  ENDCASE.

ENDMODULE.
