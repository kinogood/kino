*&---------------------------------------------------------------------*
*& Include          ZGTMMR4122I01
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

  "'CANC'(ESC) 일때 프로그램을 나가지 않도록(송종면E 25.01.14)

  CASE GV_OKCODE.
    WHEN 'BACK' OR 'CANC'.
      PERFORM FREE_OBJ.
      SET SCREEN 0.

    WHEN 'REFR'. "재조회(송종면E 25.01.03)
      PERFORM GET_DATA.
      PERFORM REFRESH_GRID USING GR_HGRID
                                 GS_HLAYO.

  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
