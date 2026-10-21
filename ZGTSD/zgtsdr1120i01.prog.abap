*&---------------------------------------------------------------------*
*& Include          ZSDR1005_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.
  DATA : L_ANSWER,
         L_QUESTION(100).
  CLEAR : L_ANSWER , L_QUESTION.

  CASE SY-UCOMM.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      IF GV_SUCCES = 'X' OR P_R2 = 'X'. "ZLSGSD4정산오더 삭제 화면에서는 바로 조회화면으로 이동
        LEAVE TO SCREEN 0.
      ELSE.

      L_QUESTION = |내역을 저장하지 않아 정산이 되지 않았습니다. 프로그램을 종료하시겠습니까?'|.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TITLEBAR      = '저장'
          TEXT_QUESTION = L_QUESTION
          TEXT_BUTTON_1 = 'Yes'
          TEXT_BUTTON_2 = 'No'
        IMPORTING
          ANSWER        = L_ANSWER.

      IF L_ANSWER = '1'.
         LEAVE TO SCREEN 0. "조회화면으로 이동
      ELSE.
        "ALV 화면으로 이동
      ENDIF.
      ENDIF.

  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE SY-UCOMM.

    WHEN 'SETMT'.
      PERFORM CREATE_SETTLEMENT_BP_SAVE.

    WHEN 'SETMT_DEL'.
      PERFORM DELETE_SETTLEMENT_BP_SAVE.

  ENDCASE.

ENDMODULE.
