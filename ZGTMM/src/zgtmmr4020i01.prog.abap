*&---------------------------------------------------------------------*
*& Include          ZGTMMR4020I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CASE GV_OKCODE.
    WHEN 'EXIT' OR 'CANC'.
      PERFORM FREE_OBJ.

      CASE SY-DYNNR.
        WHEN '0100'.
          LEAVE PROGRAM.
        WHEN '0200'.
          SET SCREEN 0.
      ENDCASE.

  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PAI_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_0100 INPUT.

  "'CCEL'(ESC) 일때 프로그램을 나가지 않도록(SJM 25.01.14)

  CLEAR : GV_REF.

  CASE GV_OKCODE.
    WHEN 'BACK' OR 'CCEL'.
      PERFORM FREE_OBJ.
      SET SCREEN 0.

    WHEN 'REFR'. "재조회
      PERFORM PRCS_REFR.

    WHEN 'PCGR'. "입고처리
      PERFORM PRCS_PCGR.

    WHEN 'CCGR'. "입고취소
      PERFORM PRCS_CCGR.

*   WHEN 'CPDO'. "납품종료(ICON_CLOSE) "삭제(SJM 25.02.17)
*     PERFORM PRCS_CPDO.

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
    WHEN 'YPRX'. "Yes
      CASE GV_PRXX.
        WHEN 'PGR'.
          PERFORM PRCS_YPGR.
        WHEN 'CGR'.
          PERFORM PRCS_YCGR.
      ENDCASE.

      LEAVE TO SCREEN 0.

    WHEN 'NPRX'. "No
      LEAVE TO SCREEN 0.
*     SET SCREEN 0.

  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
