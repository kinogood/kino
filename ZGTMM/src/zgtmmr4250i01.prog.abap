*&---------------------------------------------------------------------*
*& Include          ZGTMMR4250I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CLEAR : GV_REF.

  CASE GV_OKCODE.
    WHEN 'EXIT'.
      PERFORM CHECK_EXIT USING 'C'.

    WHEN 'CANC'.
      PERFORM CHECK_EXIT USING 'N'.

  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PAI_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_0100 INPUT.

  CLEAR : GV_REF.

  CASE GV_OKCODE.
    WHEN 'BACK'.
      PERFORM CHECK_EXIT USING 'N'.

    WHEN 'REFR'. "재조회
      PERFORM REFR_DATA.

    WHEN 'SAVE'. "저장
      PERFORM SAVE_DATA USING 'X'.

  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
