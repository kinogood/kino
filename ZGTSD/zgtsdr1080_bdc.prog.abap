*&---------------------------------------------------------------------*
*&  Include           ZGTSDR1080_BDC                                   *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZPPU0111BDC                                      *
*&---------------------------------------------------------------------*
INCLUDE ZPPLBDCPARA.


*&---------------------------------------------------------------------*
*&      Form  CALL_MESSAGE_SCREEN.
*&---------------------------------------------------------------------*
*       처리결과 메시지 보이기.
*----------------------------------------------------------------------*
FORM CALL_MESSAGE_SCREEN.
  DATA LC_MESSAGE_COUNT TYPE I.
  DESCRIBE TABLE GT_BDCMSG LINES LC_MESSAGE_COUNT.
  CHECK LC_MESSAGE_COUNT > 0.
  CALL SCREEN 2000 STARTING AT 10 10
                   ENDING   AT 89 25.

ENDFORM.                    " CALL_MESSAGE_SCREEN.
*&---------------------------------------------------------------------*
*&      Module  LIST_MESSAGES  OUTPUT
*&---------------------------------------------------------------------*
*       결과 메시지 리스트.
*----------------------------------------------------------------------*
MODULE LIST_MESSAGES OUTPUT.
  PERFORM SHOW_MESSAGES.
ENDMODULE.                 " LIST_MESSAGES  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  SHOW_MESSAGES
*&---------------------------------------------------------------------*
*       처리결과 메시지 보이기.
*----------------------------------------------------------------------*
FORM SHOW_MESSAGES.
  SET PF-STATUS SPACE.
  SET TITLEBAR 'TT_MESSAGE'.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM WRITE_MESSAGE_TOP.
  PERFORM WRITE_MESSAGE_LINE.
ENDFORM.                    " SHOW_MESSAGES
*&---------------------------------------------------------------------*
*&      Form  WRITE_MESSAGE_TOP
*&---------------------------------------------------------------------*
*       메시지 헤더 쓰기.
*----------------------------------------------------------------------*
FORM WRITE_MESSAGE_TOP.
  FORMAT COLOR COL_HEADING.
  WRITE: /03(02) 'St',
          06(20) 'Message ID',
          27(03) 'No.',
          31(50) 'Message'.
  ULINE.
ENDFORM.                    " WRITE_MESSAGE_TOP
*&---------------------------------------------------------------------*
*&      Form  WRITE_MESSAGE_LINE
*&---------------------------------------------------------------------*
*       메시지 내역 쓰기.
*----------------------------------------------------------------------*
FORM WRITE_MESSAGE_LINE.
  DATA: LC_MESSAGE TYPE BAPIRET2-MESSAGE,
        LC_ODD.
  LOOP AT GT_BDCMSG.
    AT NEW MATNR.
      WRITE: /01(10) GT_BDCMSG-MATNR COLOR COL_KEY
                                     INTENSIFIED ON.
      CASE GT_BDCMSG-UPDKZ.
        WHEN 'I'.
          WRITE: 12(02) ICON_CREATE AS ICON.
        WHEN 'U'.
          WRITE: 12(02) ICON_CHANGE AS ICON.
        WHEN 'D'.
          WRITE: 12(02) ICON_DELETE AS ICON.
      ENDCASE.
    ENDAT.
    IF LC_ODD IS INITIAL.
      LC_ODD = 'X'.
      FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
    ELSE.
      CLEAR LC_ODD.
      FORMAT COLOR COL_NORMAL INTENSIFIED ON.
    ENDIF.
    CASE GT_BDCMSG-MSGTYP.
      WHEN 'S'.
        WRITE: /03(02) ICON_LED_GREEN  AS ICON.
      WHEN 'W'.
        WRITE: /03(02) ICON_LED_YELLOW AS ICON.
      WHEN 'E' OR 'A' OR 'X'.
        WRITE: /03(02) ICON_LED_RED    AS ICON.
      WHEN OTHERS.
        WRITE: /03(02) ICON_SPACE      AS ICON.
    ENDCASE.
    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        MSGID               = GT_BDCMSG-MSGID
        MSGNR               = GT_BDCMSG-MSGNR
        MSGV1               = GT_BDCMSG-MSGV1
        MSGV2               = GT_BDCMSG-MSGV2
        MSGV3               = GT_BDCMSG-MSGV3
        MSGV4               = GT_BDCMSG-MSGV4
      IMPORTING
        MESSAGE_TEXT_OUTPUT = LC_MESSAGE.

    WRITE: 06(20) GT_BDCMSG-MSGID,
           27(03) GT_BDCMSG-MSGNR,
           31(50) LC_MESSAGE.
  ENDLOOP.
ENDFORM.                    " WRITE_MESSAGE_LINE
