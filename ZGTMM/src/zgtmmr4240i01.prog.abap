*&---------------------------------------------------------------------*
*& Include          ZGTMMR4240I01
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
      PERFORM FREE_OBJ.
      LEAVE PROGRAM.

    WHEN 'CANC'.
      PERFORM FREE_OBJ.
      SET SCREEN 0.

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
      PERFORM FREE_OBJ.
      SET SCREEN 0.

    WHEN 'REFR'. "재조회
      PERFORM REFR_DATA.

  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
