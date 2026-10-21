*&---------------------------------------------------------------------*
*& Include          ZGTMMR1120I01
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
*&      Module  USER_COMMAND_0900  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0900 INPUT.

  CASE GV_OKCODE.
    WHEN 'CONV'. "조회/수정 전환
      CLEAR GV_OKCODE.
      PERFORM F_CONV_900.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0101 INPUT.

  CASE GV_OKCODE.
    WHEN 'BOK'. "입력
      CLEAR GV_OKCODE.
      GS_SCR_101-ZOK = ABAP_TRUE.
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
    WHEN 'BOK'. "입력
      CLEAR GV_OKCODE.
      GS_SCR_102-ZOK = ABAP_TRUE.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  GET_CURSOR_102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR_102 INPUT.
  GET CURSOR FIELD GS_SCR_102-CURSOR.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  SET_TEXT_102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_TEXT_102 INPUT.

  PERFORM F_SET_SCREEN_TEXT_102.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  F4_MRO_TYPE1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_MRO_TYPE1 INPUT.

  PERFORM F_F4_HELP_MRO_TYPE1.
  PERFORM F_SET_SCREEN_TEXT_102.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  F4_MRO_TYPE2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_MRO_TYPE2 INPUT.

  PERFORM F_F4_HELP_MRO_TYPE2.
  PERFORM F_SET_SCREEN_TEXT_102.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE GV_OKCODE.
    WHEN 'TDOWN'. "양식 다운로드
      CLEAR GV_OKCODE.
      PERFORM F_TEMPLATE_DOWNLOAD USING GC_ZGTMMR1120.
    WHEN 'TUPLO'. "양식 업로드
      CLEAR GV_OKCODE.
      PERFORM F_EXCEL_UPLOAD_CREATE.
    WHEN 'CREATE'. "생성
      CLEAR GV_OKCODE.
      PERFORM F_CREATE.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0103  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0103 INPUT.
  CASE GV_OKCODE.
    WHEN 'SEAR'.
      CLEAR GV_OKCODE.
      GS_SCR_103-ZOK = ABAP_TRUE.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CASE GV_OKCODE.
    WHEN 'CONV'. "조회/수정 전환
      CLEAR GV_OKCODE.
      PERFORM F_CONV_200.

    WHEN 'MMODI'. "저장
      CLEAR GV_OKCODE.
      PERFORM F_MMODI.

    WHEN 'MEXPA'. "확장
      CLEAR GV_OKCODE.
      PERFORM F_MEXPA.

  ENDCASE.

ENDMODULE.
