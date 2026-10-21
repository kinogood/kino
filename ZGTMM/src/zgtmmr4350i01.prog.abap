*&---------------------------------------------------------------------*
*& Include          ZGTMMR4350I01
*&---------------------------------------------------------------------*

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
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE GV_OKCODE.
    WHEN 'RFRS'. "새로고침
      CLEAR GV_OKCODE.
      PERFORM F_START_OF_SELECTION. "다시 조회

    WHEN 'BDOWN'."Upload template
      CLEAR GV_OKCODE.
      PERFORM F_TEMPLATE_DOWNLOAD USING GC_ZGTMMR4350_ROH.

    WHEN 'BUPLO'. "Excel upload
      CLEAR GV_OKCODE.
      PERFORM F_EXCEL_UPLOAD_ROH.

    WHEN 'BSAVE'. "저장
      CLEAR GV_OKCODE.
*>S.2026.07.07 '조회'시 에도 저장 기능 추가로 인한 로직 분기
      IF P_NEW = ABAP_TRUE.
         PERFORM F_SAVE_ROH.

      ELSEIF P_DISP = ABAP_TRUE.
         PERFORM F_SAVE_CHANGE.
      ENDIF.
*'조회<->변경' 버튼 추가로직
    WHEN 'CHANGE'. "조회<->변경
      PERFORM F_DISPLAY_CHANGE.
      CLEAR GV_OKCODE.
*<E.2026.07.07 ZGODEV04.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CASE GV_OKCODE.
    WHEN 'RFRS'. "새로고침
      CLEAR GV_OKCODE.
      PERFORM F_START_OF_SELECTION. "다시 조회

    WHEN 'BDOWN'."Upload template
      CLEAR GV_OKCODE.
      PERFORM F_TEMPLATE_DOWNLOAD USING GC_ZGTMMR4350_EXW.

    WHEN 'BUPLO'. "Excel upload
      CLEAR GV_OKCODE.
      PERFORM F_EXCEL_UPLOAD_EXW.

    WHEN 'BSAVE'. "저장
      CLEAR GV_OKCODE.
*>S.2026.07.07 '조회'시 에도 저장 기능 추가로 인한 로직 분기
      IF P_NEW = ABAP_TRUE.
         PERFORM F_SAVE_EXW.

      ELSEIF P_DISP = ABAP_TRUE.
         PERFORM F_SAVE_CHANGE.
      ENDIF.

*'조회<->변경' 버튼 추가로직
    WHEN 'CHANGE'. "조회<->변경
      PERFORM F_DISPLAY_CHANGE.
      CLEAR GV_OKCODE.
*<E.2026.07.07 ZGODEV04.
  ENDCASE.

ENDMODULE.
