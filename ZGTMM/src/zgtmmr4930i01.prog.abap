*&---------------------------------------------------------------------*
*& Include          ZGTMMR4911I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CASE GV_OKCODE.
    WHEN 'EXIT'. "OR 'CANC'.
      PERFORM FREE_OBJ.
      LEAVE PROGRAM.

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
    WHEN 'BACK' OR 'CANC'.
      PERFORM FREE_OBJ.
      SET SCREEN 0.

    WHEN 'SEND'.
      PERFORM SEND_DATA USING 'X'.
      GV_REF = GC_X.

    WHEN 'ASEL'.
      PERFORM SET_SELECT_ALL USING GC_A.
      GV_REF = GC_X.

    WHEN 'DSEL'.
      PERFORM SET_SELECT_ALL USING GC_D.
      GV_REF = GC_X.

  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
