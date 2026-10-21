*&---------------------------------------------------------------------*
*& Include          ZGTMMR6600I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

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

    WHEN 'PDEL'. "삭제
      PERFORM XDEL_DATA USING 'P'.

    WHEN 'CDEL'. "삭제 취소
      PERFORM XDEL_DATA USING 'C'.

  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
