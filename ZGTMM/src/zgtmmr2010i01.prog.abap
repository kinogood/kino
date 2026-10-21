*&---------------------------------------------------------------------*
*& Include          ZGTMMR2010I01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.

  CASE GV_OKCODE.
    WHEN 'CANC' OR 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE GV_OKCODE.
    WHEN 'RFRS'. "새로고침
      CLEAR GV_OKCODE.
      PERFORM F_REFRESH.
    WHEN 'CLSD'. "종결
      CLEAR GV_OKCODE.
      PERFORM F_PR_CLOSED USING ABAP_TRUE.
    WHEN 'RCLSD'. "종결 취소
      CLEAR GV_OKCODE.
      PERFORM F_PR_CLOSED USING SPACE.
    WHEN 'CONFR'. "승인 요청
      CLEAR GV_OKCODE.
      PERFORM F_APPROVAL_REQ_DISP.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CASE GV_OKCODE.
    WHEN 'RFRS'. "새로고침
      CLEAR GV_OKCODE.
      PERFORM F_REFRESH.

    WHEN 'CREA'. "구매요청 생성
      CLEAR GV_OKCODE.
      PERFORM F_CREATE_PR_OPT1.

    WHEN 'TMPL'. "Upload template
      CLEAR GV_OKCODE.
*      1-5. Upload Template: Exel 업로드 양식 다운로드
      PERFORM F_TEMPLATE_DOWNLOAD USING GC_ZGTMMR2010_OPT1.

    WHEN 'UPLO'. "Excel upload
      CLEAR GV_OKCODE.
      PERFORM F_EXCEL_UPLOAD_OPT1.

  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  CASE GV_OKCODE.
    WHEN 'RFRS'. "새로고침
      CLEAR GV_OKCODE.
      PERFORM F_REFRESH.

    WHEN 'CREA'. "구매요청 생성
      CLEAR GV_OKCODE.
      PERFORM F_CREATE_PR_OPT2.

    WHEN 'TMPL'. "Upload template
      CLEAR GV_OKCODE.
*      1-5. Upload Template: Exel 업로드 양식 다운로드
      PERFORM F_TEMPLATE_DOWNLOAD USING GC_ZGTMMR2010_OPT2.

    WHEN 'UPLO'. "Excel upload
      CLEAR GV_OKCODE.
      PERFORM F_EXCEL_UPLOAD_OPT2.

    WHEN 'BGCHK'. "예산 점검
      CLEAR GV_OKCODE.
      PERFORM F_CHECK_BUDGET.

    WHEN 'CONFR'. "승인 요청
      CLEAR GV_OKCODE.
      PERFORM F_APPROVAL_REQ.

  ENDCASE.
ENDMODULE.
