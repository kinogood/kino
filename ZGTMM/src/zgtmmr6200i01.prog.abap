*&---------------------------------------------------------------------*
*& Include          ZGTMMR6200I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  "'CANC'(ESC) 일때 프로그램을 나가지 않도록(PSJ 25.01.23)

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

    WHEN 'FVND'. "공급업체 지정
      PERFORM PRCS_FVND.

    WHEN 'DVND'. "직납처 지정
      PERFORM PRCS_DVND.

    WHEN 'CBAN'. "구매요청 생성
      PERFORM PRCS_CBAN.

    WHEN 'DBAN'. "구매요청 삭제
      PERFORM PRCS_DBAN.

    WHEN 'CBES'. "구매오더 생성
      PERFORM PRCS_CBES.

    WHEN 'DBES'. "구매오더 삭제
      PERFORM PRCS_DBES.

    WHEN 'RDPO'. "구매오더 삭제요청
      PERFORM PRCS_RDPO.

    WHEN 'CNFC'. "확정대상 취소
      PERFORM PRCS_CNFX USING 'X'.

    WHEN 'CNFR'. "확정대상 원복
      PERFORM PRCS_CNFX USING ' '.

  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PAI_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_0200 INPUT.

  CLEAR : GV_REF.

  CASE GV_OKCODE.
    WHEN 'RDPS'. "삭제요청
      PERFORM PRCS_RDPS.

      IF GV_ERR IS INITIAL.
        SET SCREEN 0.
      ENDIF.

  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
