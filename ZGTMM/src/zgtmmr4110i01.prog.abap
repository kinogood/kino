*&---------------------------------------------------------------------*
*& Include          ZGTMMR4110I01
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
        WHEN '0100' OR '0110'.
          LEAVE PROGRAM.
        WHEN '0200' OR '0400'
          OR '0500' OR '0600'.
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

    WHEN 'CCAP'. "상신/확정취소
      PERFORM PRCS_CCAP.

    WHEN 'PRGI'. "출고처리/출하지시
      PERFORM PRCS_PRXX.

    WHEN 'ISGO'. "통문증발급
      PERFORM PRCS_ISGO.

    WHEN 'TGIH'. "전체출고이력
      PERFORM PRCS_TGIH.

    WHEN 'DRSK'. "사급Risk 정보 조회(Hidden)

    WHEN 'CCGO'. "통문증취소
      PERFORM PRCS_CCGO.

    WHEN 'CCGI'. "출고취소
      PERFORM PRCS_CCGI.

    WHEN 'APPV'. "승인
      PERFORM PRCS_APPV.

    WHEN 'REJT'. "반려
      PERFORM PRCS_REJT.

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
    WHEN 'OKAY'.
      PERFORM SET_ISQTY_B.

      CHECK GV_ERR IS INITIAL.
      LEAVE TO SCREEN 0.
  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PAI_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_0400 INPUT.

  CASE GV_OKCODE.
    WHEN 'OKAY'.
      PERFORM SET_ISQTY_M.

      CHECK GV_ERR IS INITIAL.
      LEAVE TO SCREEN 0.
  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PAI_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_0500 INPUT.

  CLEAR : GV_ERR.

  CASE GV_OKCODE.
    WHEN 'YPRX'. "Yes
      CASE GV_PRXX.
        WHEN 'PGI'
          OR 'POD'. "추가(SJM 25.06.11)
          PERFORM PRCS_YPGI.
        WHEN 'CGI'.
          PERFORM PRCS_YCGI.
        WHEN 'APV'.
          PERFORM PRCS_XAPV USING 'A' '승인'(I03).
*       WHEN 'REJ'.
*         PERFORM PRCS_XAPV USING 'R' '반려'.
        WHEN 'CAP'.
          PERFORM PRCS_YCAP.
      ENDCASE.

    WHEN 'NPRX'. "No
*     SET SCREEN 0.

    WHEN 'GIAR'. "출고품의
      PERFORM PRCS_GIAR.

    WHEN 'RJPR'. "반려처리
      PERFORM PRCS_XAPV USING 'R' '반려'(I04).

    WHEN 'CCXX'. "취소
*     SET SCREEN 0.

  ENDCASE.

  IF GV_ERR IS INITIAL.
    LEAVE TO SCREEN 0.
  ENDIF.

  CLEAR : GV_OKCODE.

ENDMODULE.
