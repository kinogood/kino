*&---------------------------------------------------------------------*
*& Include          ZGTMMR2020I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE GV_OKCODE.
    WHEN 'BOK'. "구매요청 생성
      CLEAR GV_OKCODE.
      PERFORM F_CREATE_PR.
    WHEN 'BCAN'. "구매요청 취소
      CLEAR GV_OKCODE.
      PERFORM F_CANCEL_PR.
    WHEN 'BED'. "설계 담당자 관리
      CLEAR GV_OKCODE.
      PERFORM F_MODIFY_2021.
    WHEN 'BPRINT'. "출력
      CLEAR GV_OKCODE.
      PERFORM F_SMART_FORM_PRINT.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.

  CASE GV_OKCODE.
    WHEN 'CANC' OR 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0101 INPUT.

  CASE GV_OKCODE.
    WHEN 'BCHK'. "입력
      CLEAR GV_OKCODE.
      GS_SCR_101-ZCHK = ABAP_TRUE.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0102 INPUT.

  CASE GV_OKCODE.
    WHEN 'BSAVE'. "저장
      DATA LV_ANS TYPE C LENGTH 1.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TITLEBAR      = TEXT-TT2 "확인
          TEXT_QUESTION = TEXT-Q03
        IMPORTING
          ANSWER        = LV_ANS.

      CHECK LV_ANS EQ GC_1.

      CLEAR GV_OKCODE.
      GS_SCR_102-ZCHK = ABAP_TRUE.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
