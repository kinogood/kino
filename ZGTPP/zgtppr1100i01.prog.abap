*&---------------------------------------------------------------------*
*& Include          ZGTPPR1100I01
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
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE GV_OK_CODE.
    WHEN 'EXEC'.
      IF P_R5 EQ GC_X.
        PERFORM PROCESS_EXEC.          "플랜트 확장
      ELSEIF P_R6 EQ GC_X.
        IF P_R1 EQ GC_X OR P_R2 EQ GC_X.
          PERFORM PROCESS_EXEC_RM.     "플랜트 확장
        ENDIF.
      ENDIF.
    WHEN 'UPDATE'.
      PERFORM PROCESS_EXEC_UPDATE. "BOM생산저장위치 업데이트
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND_0200 INPUT.
  CASE GV_OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      PERFORM CLS_OBJT_RTN_0200.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  CASE GV_OK_CODE.
    WHEN 'ADDLINE'.
      PERFORM PROCESS_ADDLINE.       "라인추가
    WHEN 'DELLINE'.
      PERFORM PROCESS_DELLINE.       "라인삭제
    WHEN 'ZSAVE'.
      PERFORM PROCESS_ZSAVE.         "ZGTPPT1150 저장
  ENDCASE.
ENDMODULE.
