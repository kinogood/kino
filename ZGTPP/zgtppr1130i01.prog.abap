*&---------------------------------------------------------------------*
*& Include          ZGTPPR1130I01
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
    WHEN 'ADDLINE'.
      PERFORM PROCESS_ADDLINE.       "라인추가
    WHEN 'DELLINE'.
      PERFORM PROCESS_DELLINE.       "라인삭제
    WHEN 'ZSAVE'.
      PERFORM PROCESS_ZSAVE.         "ZGTPPT1080 저장
  ENDCASE.
ENDMODULE.
