*&---------------------------------------------------------------------*
*& Include          ZGTMMR6500I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

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
      PERFORM PRCS_REFR.

    WHEN 'SAVE'. "저장(구매요청 생성)
      PERFORM PRCS_CBAN.

    WHEN 'MAIL'. "메일 전송
      PERFORM SEND_MAIL.

  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PAI_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_0200 INPUT.

  CASE GV_OKCODE.
    WHEN 'SEND'. "전송
      PERFORM SEND_DATA.

      IF GV_ERR IS INITIAL.
        SET SCREEN 0.
      ENDIF.

  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
