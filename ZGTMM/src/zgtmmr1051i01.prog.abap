*&---------------------------------------------------------------------*
*& Include          ZGTMMR3000I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE EXIT_0100 INPUT.

  GV_OKCODE_SAVE = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE.

    WHEN 'BACK' OR 'CANC'.
       PERFORM RELEASE_ALV.
       LEAVE TO SCREEN 0.

    WHEN 'EXIT'.
      PERFORM RELEASE_ALV.
      LEAVE PROGRAM.

  ENDCASE.

ENDMODULE.
**&---------------------------------------------------------------------*
**&      Module  CHECK_KUNNR  INPUT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*MODULE check_kunnr INPUT.
*
*  CLEAR : gs_info-kunnr_tx.
*  IF gs_info-kunnr IS NOT INITIAL.
*    gs_info-kunnr = |{ gs_info-kunnr ALPHA = IN }|.
*    SELECT SINGLE name1
*      FROM kna1
*      INTO @gs_info-kunnr_tx
*     WHERE kunnr = @gs_info-kunnr.
*    IF sy-subrc <> 0.
*      MESSAGE e017.  "유효하지 않은 코드 입니다.
*    ENDIF.
*  ENDIF.
*
*ENDMODULE.
