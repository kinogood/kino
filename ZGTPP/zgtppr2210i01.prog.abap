*&---------------------------------------------------------------------*
*& Include          ZGTPPR2210I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.
  CASE GV_OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      PERFORM CLS_OBJT_RTN.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE GV_OK_CODE.
    WHEN 'VADD'.
      PERFORM PROCESS_VER_ADD. "버전추가
    WHEN 'VDEL'.
      PERFORM PROCESS_VER_DEL. "버전삭제
    WHEN 'CALC'.
      PERFORM PROCESS_CALC.    "데이터산출
    WHEN 'ZSAVE'.
      PERFORM PROCESS_ZSAVE.   "저장
  ENDCASE.
ENDMODULE.
