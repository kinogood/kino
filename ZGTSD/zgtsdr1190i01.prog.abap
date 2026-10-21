*&---------------------------------------------------------------------*
*& Include          ZGTSDR1190I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0100 INPUT.
  SAVE_OK = OK_CODE.
  CLEAR OK_CODE.

  CASE SAVE_OK.
    WHEN 'BACK' OR 'CANC' OR 'EXIT'.
      PERFORM INIT_CONTROLS_0100.
      LEAVE TO SCREEN 0.


    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  SAVE_OK = OK_CODE.
  CLEAR OK_CODE.

  CASE SAVE_OK.
    WHEN 'ZCOMP'. "마감처리
      PERFORM COMPLETE_PROCESS USING GC_H.

    WHEN 'ZUNDO'. "마감취소
      PERFORM COMPLETE_PROCESS USING GC_C.

    WHEN 'ZSELA'. "전체선택
      PERFORM SELECT_ALL.

    WHEN 'ZDALL'. "전체해제
      PERFORM DESELECT_ALL.

    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
