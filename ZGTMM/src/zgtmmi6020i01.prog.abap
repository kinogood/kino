*&---------------------------------------------------------------------*
*& Include          ZGTMMI6020I01
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

  "'CANC'(ESC) 일때 프로그램을 나가지 않도록(박상진E 25.01.23)

* CLEAR : GV_REF.

  CASE GV_OKCODE.
    WHEN 'BACK' OR 'CANC'.
      PERFORM FREE_OBJ.
      SET SCREEN 0.

    WHEN 'SEND'.
      PERFORM SEND_DATA USING 'X'.

      CHECK GV_MSG IS NOT INITIAL.
      SET SCREEN 0.
*     GV_REF = GC_X.

  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
