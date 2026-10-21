*&---------------------------------------------------------------------*
*& Include          ZGTMMR6300I01
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
      PERFORM REFR_DATA.

    WHEN 'DSCH'. "조회<->수정
      PERFORM DSCH_DATA.

    WHEN 'SAVE'. "저장
      PERFORM SAVE_DATA USING 'X'.

    WHEN 'COPY'. "공급업체 복사
      PERFORM COPY_DATA.

  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
