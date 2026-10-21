*&---------------------------------------------------------------------*
*& Include          ZGTMMR4111I01
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
      PERFORM PRCS_REFR.

    WHEN 'POSR'. "환입
      PERFORM PRCS_POSR.

    WHEN 'COSR'. "환입취소
      PERFORM PRCS_COSR.

  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PAI_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_0200 INPUT.

* CLEAR : GV_ERR.

  CASE GV_OKCODE.
    WHEN 'YOSR'. "Yes
      CASE GV_XOSR.
        WHEN 'P'.
          PERFORM PRCS_YPOS.
        WHEN 'C'.
          PERFORM PRCS_YCOS.
      ENDCASE.

    WHEN 'NOSR'. "No
*     SET SCREEN 0.

  ENDCASE.

* IF GV_ERR IS INITIAL.
  LEAVE TO SCREEN 0.
* ENDIF.

  CLEAR : GV_OKCODE.

ENDMODULE.
