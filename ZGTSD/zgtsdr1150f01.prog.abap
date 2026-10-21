*&---------------------------------------------------------------------*
*&  Include           ZSDR0960F                                        *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  STATUS
*&---------------------------------------------------------------------*
FORM STATUS USING   RT_EXTAB  TYPE  SLIS_T_EXTAB.

  DATA: LS_EXTAB TYPE SLIS_EXTAB.

  REFRESH: RT_EXTAB.

  IF PA_VKORG NE '3000'.
    LS_EXTAB-FCODE = 'WELS'.
    APPEND LS_EXTAB TO RT_EXTAB.
  ENDIF.

  SET PF-STATUS 'STANDARD' EXCLUDING RT_EXTAB.

ENDFORM.                    " STATUS

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
    AT NEW BELNR.
      WRITE: /01(10) GT_BDCMSG-BELNR COLOR COL_KEY
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

*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
FORM USER_COMMAND USING  RS_UCOMM LIKE SY-UCOMM
                         RS_SELFIELD TYPE SLIS_SELFIELD.

  DATA : P_UCOMM LIKE SY-UCOMM.
  READ TABLE G_ITEM_T INDEX RS_SELFIELD-TABINDEX.

  GV_UCOMM  =  RS_UCOMM.

  CASE RS_UCOMM.

    WHEN 'ZSEL' .        " 지급전표상세조회
      PERFORM CALL_DETAIL_LIST.
      PERFORM INTIALIZATION_DATA.
      PERFORM READ_DATA_PROCESS.
      PERFORM MODIFY_DATA_PROCESS.
      RS_SELFIELD-REFRESH = 'X'.

    WHEN '&IC1'.
      PERFORM DETAIL_CLICK USING RS_SELFIELD-TABINDEX
                                  RS_SELFIELD-FIELDNAME
                                  RS_SELFIELD-VALUE.
    WHEN 'WELS'.
      PERFORM GET_WELS_DOC.
      RS_SELFIELD-REFRESH = 'X'.
  ENDCASE.
ENDFORM.                    " USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  DETAIL_CLICK
*&---------------------------------------------------------------------*
FORM DETAIL_CLICK USING    P_TABINDEX P_FLDNAME P_VALUE.

  DATA : LV_ANLN2 LIKE ANLA-ANLN2 VALUE '0000',
         LV_BUKRS LIKE ANLA-BUKRS VALUE 'DSF'.
  DATA: LV_ZURL(255) TYPE C.

  CASE P_FLDNAME.
    WHEN 'BELNR'.
*      read table g_item_t index p_tabindex.
      READ TABLE G_HEADER_T INDEX P_TABINDEX.
      SET PARAMETER ID 'BLN' FIELD G_HEADER_T-BELNR.
      SET PARAMETER ID 'BUK' FIELD PA_VKORG.
      SET PARAMETER ID 'GJR' FIELD G_HEADER_T-FBUDA(4).
      CALL TRANSACTION 'FB03'
           AND SKIP FIRST SCREEN.
    WHEN 'BUGA_BELNR'.
*      read table g_item_t index p_tabindex.
      READ TABLE G_HEADER_T INDEX P_TABINDEX.
      SET PARAMETER ID 'BLN' FIELD G_HEADER_T-BUGA_BELNR.
      SET PARAMETER ID 'BUK' FIELD PA_VKORG.
      SET PARAMETER ID 'GJR' FIELD G_HEADER_T-FBUDA(4).
      CALL TRANSACTION 'FB03'
           AND SKIP FIRST SCREEN.
    WHEN 'BELNR2'.
*      read table g_item_t index p_tabindex.
      READ TABLE G_HEADER_T INDEX P_TABINDEX.
      SET PARAMETER ID 'BLN' FIELD G_ITEM_T-BELNR2.
      SET PARAMETER ID 'BUK' FIELD PA_VKORG.
      SET PARAMETER ID 'GJR' FIELD G_ITEM_T-FBUDA2(4).
      CALL TRANSACTION 'FB03'
           AND SKIP FIRST SCREEN.
    WHEN 'BELNR2_BUGA'.
*      read table g_item_t index p_tabindex.
      READ TABLE G_HEADER_T INDEX P_TABINDEX.
      SET PARAMETER ID 'BLN' FIELD G_ITEM_T-BELNR2_BUGA.
      SET PARAMETER ID 'BUK' FIELD PA_VKORG.
      SET PARAMETER ID 'GJR' FIELD G_ITEM_T-FBUDA2_BUGA(4).
      CALL TRANSACTION 'FB03'
           AND SKIP FIRST SCREEN.
    WHEN 'VBELN2'.
      READ TABLE G_ITEM_T INDEX P_TABINDEX.
      SET PARAMETER ID 'VF' FIELD G_ITEM_T-VBELN2.
      CALL TRANSACTION 'VF03'
           AND SKIP FIRST SCREEN.
*--20190423 sondu SAP-WeLS 연동
    WHEN 'DOCNO'.
      READ TABLE G_ITEM_T INDEX P_TABINDEX.
      CLEAR LV_ZURL.
      SELECT SINGLE ZURL
        INTO LV_ZURL
        FROM ZFIT0800
       WHERE BUKRS EQ G_ITEM_T-VKORG
         AND GJAHR EQ G_ITEM_T-FBUDA2+0(4)
         AND BELNR2 EQ G_ITEM_T-BELNR2
         AND DOCNO EQ G_ITEM_T-DOCNO.

      CALL FUNCTION 'GUI_RUN'
        EXPORTING
          COMMAND = LV_ZURL.

  ENDCASE.

ENDFORM.                    " DETAIL_CLICK

*---------------------------------------------------------------------*
*       FORM E01_FIELDCAT_INIT                                        *
*---------------------------------------------------------------------*
*  -->  E01_LT_FIELDCAT                                               *
*---------------------------------------------------------------------*
FORM E01_FIELDCAT_INIT USING E01_LT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.

  DATA: LS_FIELDCAT TYPE SLIS_FIELDCAT_ALV.

  G_REPID = SY-REPID.

  LOOP AT E01_LT_FIELDCAT INTO LS_FIELDCAT.
    IF SY-TABIX > 0.
      CHECK LS_FIELDCAT-KEY <> 'X'.
      LS_FIELDCAT-NO_OUT = 'X'.

      MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
    ENDIF.
  ENDLOOP.

** Header fieldcat
  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '1'.
  LS_FIELDCAT-FIELDNAME     = 'BONEM'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_HEADER.
  LS_FIELDCAT-OUTPUTLEN     = 10.
  LS_FIELDCAT-SELTEXT_L     = 'Agent'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '2'.
  LS_FIELDCAT-FIELDNAME     = 'NAME'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_HEADER.
  LS_FIELDCAT-OUTPUTLEN     = 20.
  LS_FIELDCAT-SELTEXT_L     = 'Agent명'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '3'.
  LS_FIELDCAT-FIELDNAME     = 'KNUMA'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_HEADER.
  LS_FIELDCAT-OUTPUTLEN     = 10.
  LS_FIELDCAT-SELTEXT_L     = '계약No'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '4'.
  LS_FIELDCAT-FIELDNAME     = 'FBUDA'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_HEADER.
  LS_FIELDCAT-OUTPUTLEN     = 8.
  LS_FIELDCAT-SELTEXT_L     = '정산월'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '5'.
  LS_FIELDCAT-FIELDNAME     = 'VBELN'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_HEADER.
  LS_FIELDCAT-OUTPUTLEN     = 10.
  LS_FIELDCAT-SELTEXT_L     = '커미션정산오더'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '6'.
  LS_FIELDCAT-FIELDNAME     = 'KUNAG'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_HEADER.
  LS_FIELDCAT-OUTPUTLEN     = 10.
  LS_FIELDCAT-SELTEXT_L     = '고객'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '7'.
  LS_FIELDCAT-FIELDNAME     = 'NAME1'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_HEADER.
  LS_FIELDCAT-OUTPUTLEN     = 20.
  LS_FIELDCAT-SELTEXT_L     = '고객명'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '8'.
  LS_FIELDCAT-EMPHASIZE     = 'X'.
  LS_FIELDCAT-HOTSPOT       = 'X'.
  LS_FIELDCAT-FIELDNAME     = 'BELNR'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_HEADER.
  LS_FIELDCAT-OUTPUTLEN     = 10.
  LS_FIELDCAT-SELTEXT_L     = '미지급전표'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '9'.
  LS_FIELDCAT-FIELDNAME     = 'WRBTR'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_HEADER.
  LS_FIELDCAT-OUTPUTLEN     = 18.
  LS_FIELDCAT-SELTEXT_L     = '미지급금액'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  LS_FIELDCAT-CFIELDNAME    = 'WAERS'.
  LS_FIELDCAT-CTABNAME      = 'G_HEADER_T'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '10'.
  LS_FIELDCAT-FIELDNAME     = 'WAERS'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_HEADER.
  LS_FIELDCAT-OUTPUTLEN     = 5.
  LS_FIELDCAT-SELTEXT_L     = '계약통화'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '11'.
  LS_FIELDCAT-EMPHASIZE     = 'X'.
  LS_FIELDCAT-HOTSPOT       = 'X'.
  LS_FIELDCAT-FIELDNAME     = 'BUGA_BELNR'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_HEADER.
  LS_FIELDCAT-OUTPUTLEN     = 10.
  LS_FIELDCAT-SELTEXT_L     = '미지급 부가세전표'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.


  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '12'.
  LS_FIELDCAT-FIELDNAME     = 'BUGA_AMNT'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_HEADER.
  LS_FIELDCAT-OUTPUTLEN     = 18.
  LS_FIELDCAT-SELTEXT_L     = '미지급(Tax)'.
  LS_FIELDCAT-CFIELDNAME    = 'KRW'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '13'.
  LS_FIELDCAT-FIELDNAME     = 'K_WAERK'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_HEADER.
  LS_FIELDCAT-OUTPUTLEN     = 5.
  LS_FIELDCAT-SELTEXT_L     = '미지급통화'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.


** Item fieldcat
  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '1'.
  LS_FIELDCAT-FIELDNAME     = 'BONEM1'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 10.
  LS_FIELDCAT-SELTEXT_L     = 'Agent'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '2'.
  LS_FIELDCAT-FIELDNAME     = 'KUNAG'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 10.
  LS_FIELDCAT-SELTEXT_L     = '고객'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.


  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '3'.
  LS_FIELDCAT-FIELDNAME     = 'VKORG'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 4.
  LS_FIELDCAT-SELTEXT_L     = '영업조직'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.


  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '4'.
  LS_FIELDCAT-FIELDNAME     = 'VTWEG'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 2.
  LS_FIELDCAT-SELTEXT_L     = '유통경로'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.


  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '5'.
  LS_FIELDCAT-FIELDNAME     = 'SPART'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 2.
  LS_FIELDCAT-SELTEXT_L     = '제품군'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.


  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '6'.
  LS_FIELDCAT-FIELDNAME     = 'BEZEI'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 20.
  LS_FIELDCAT-SELTEXT_L     = '영업팀'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.


  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '7'.
  LS_FIELDCAT-FIELDNAME     = 'BEZEI2'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 20.
  LS_FIELDCAT-SELTEXT_L     = '영업그룹'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.


  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '8'.
  LS_FIELDCAT-FIELDNAME     = 'BUPLA'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 3.
  LS_FIELDCAT-SELTEXT_L     = '사업장'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '9'.
  LS_FIELDCAT-EMPHASIZE     = 'X'.
  LS_FIELDCAT-HOTSPOT       = 'X'.
  LS_FIELDCAT-FIELDNAME     = 'VBELN2'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 10.
  LS_FIELDCAT-SELTEXT_L     = '대금청구NO'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '10'.
  LS_FIELDCAT-FIELDNAME     = 'NETWR'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 15.
  LS_FIELDCAT-SELTEXT_L     = '매출액'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '11'.
  LS_FIELDCAT-FIELDNAME     = 'WAERK'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 5.
  LS_FIELDCAT-SELTEXT_L     = '매출통화'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '12'.
  LS_FIELDCAT-FIELDNAME     = 'SUKUM'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 18.
  LS_FIELDCAT-SELTEXT_L     = '수금금액'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  LS_FIELDCAT-CFIELDNAME    = 'WAERS'.
  LS_FIELDCAT-CTABNAME      = 'G_ITEM_T'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.


  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '13'.
  LS_FIELDCAT-FIELDNAME     = 'WRBTR'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 18.
  LS_FIELDCAT-SELTEXT_L     = '커미션금액'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  LS_FIELDCAT-CFIELDNAME    = 'WAERS'.
  LS_FIELDCAT-CTABNAME      = 'G_ITEM_T'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.


  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '14'.
  LS_FIELDCAT-EMPHASIZE     = 'X'.
  LS_FIELDCAT-HOTSPOT       = 'X'.
  LS_FIELDCAT-FIELDNAME     = 'BELNR2'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 5.
  LS_FIELDCAT-SELTEXT_L     = '지급전표번호'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '15'.
  LS_FIELDCAT-FIELDNAME     = 'WRBTR3'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 18.
  LS_FIELDCAT-SELTEXT_L     = '지급전표금액'.
  LS_FIELDCAT-CFIELDNAME    = 'WAERK2'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '16'.
  LS_FIELDCAT-FIELDNAME     = 'DMBTR2'.
  LS_FIELDCAT-TABNAME       =  G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     =  18.
  LS_FIELDCAT-SELTEXT_L     =  '지급현지통화액'.
  LS_FIELDCAT-CURRENCY      =  'KRW'.
  LS_FIELDCAT-DDICTXT       =  'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '17'.
  LS_FIELDCAT-FIELDNAME     = 'WAERK2'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 18.
  LS_FIELDCAT-SELTEXT_L     = '지급전표통화'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.


  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '18'.
  LS_FIELDCAT-EMPHASIZE     = 'X'.
  LS_FIELDCAT-HOTSPOT       = 'X'.
  LS_FIELDCAT-FIELDNAME     = 'BELNR2_BUGA'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 18.
  LS_FIELDCAT-SELTEXT_L     = '부가세지급전표'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  LS_FIELDCAT-CTABNAME      = 'G_ITEM_T'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '19'.
  LS_FIELDCAT-FIELDNAME     = 'WRBTR2_BUGA'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 18.
  LS_FIELDCAT-SELTEXT_L     = '부가세지급전표금액'.
  LS_FIELDCAT-CFIELDNAME    = 'WAERK2_BUGA'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '20'.
  LS_FIELDCAT-FIELDNAME     = 'DMBTR2_BUGA'.
  LS_FIELDCAT-TABNAME       =  G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     =  18.
  LS_FIELDCAT-SELTEXT_L     =  '부가세지급현지통화액'.
  LS_FIELDCAT-CURRENCY      =  'KRW'.
  LS_FIELDCAT-DDICTXT       =  'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '21'.
  LS_FIELDCAT-FIELDNAME     = 'WAERK2_BUGA'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 18.
  LS_FIELDCAT-SELTEXT_L     = '부가세지급통화'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.
*--20180423 SONDU SAP-WeLS 연동
  IF PA_VKORG EQ '3000'.
    CLEAR LS_FIELDCAT.
    LS_FIELDCAT-COL_POS       = '22'.
    LS_FIELDCAT-FIELDNAME     = 'DOCNO'.
    LS_FIELDCAT-EMPHASIZE     = 'X'.
    LS_FIELDCAT-HOTSPOT       = 'X'.
    LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
    LS_FIELDCAT-OUTPUTLEN     = 18.
    LS_FIELDCAT-SELTEXT_L     = 'WeLS 결재 문서번호'.
    LS_FIELDCAT-DDICTXT       = 'L'.
    APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.
  ENDIF.
*<--END.
ENDFORM.                    "E01_FIELDCAT_INIT

*---------------------------------------------------------------------*
*       FORM E01_FIELDCAT_HEADER                                      *
*---------------------------------------------------------------------*
*  -->  E01_LT_FIELDCAT                                               *
*---------------------------------------------------------------------*
FORM E01_FIELDCAT_HEADER USING E01_LT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.

  DATA: LS_FIELDCAT TYPE SLIS_FIELDCAT_ALV.

  G_REPID = SY-REPID.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = G_REPID
      I_INTERNAL_TABNAME = G_TABNAME_HEADER
      I_STRUCTURE_NAME   = G_HEADER_T
    CHANGING
      CT_FIELDCAT        = E01_LT_FIELDCAT[].

  LOOP AT E01_LT_FIELDCAT INTO LS_FIELDCAT.
    CHECK LS_FIELDCAT-TABNAME = G_TABNAME_HEADER.
    CASE LS_FIELDCAT-FIELDNAME.
      WHEN 'BONEM'.
        LS_FIELDCAT-SELTEXT_L  = 'Agent'.
        LS_FIELDCAT-SELTEXT_M  = 'Agent'.
        LS_FIELDCAT-SELTEXT_S  = 'Agent'.
        LS_FIELDCAT-REPTEXT_DDIC = 'Agent'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_HEADER.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'NAME'.
        LS_FIELDCAT-SELTEXT_L  = 'Agent명'.
        LS_FIELDCAT-SELTEXT_M  = 'Agent명'.
        LS_FIELDCAT-SELTEXT_S  = 'Agent명'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_HEADER.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'KNUMA'.
        LS_FIELDCAT-SELTEXT_L  = '계약No'.
        LS_FIELDCAT-SELTEXT_M  = '계약No'.
        LS_FIELDCAT-SELTEXT_S  = '계약No'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_HEADER.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'FBUDA'.
        LS_FIELDCAT-SELTEXT_L  = '정산월'.
        LS_FIELDCAT-SELTEXT_M  = '정산월'.
        LS_FIELDCAT-SELTEXT_S  = '정산월'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_HEADER.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'KUNAG'.
        LS_FIELDCAT-HOTSPOT    = 'X'.
        LS_FIELDCAT-SELTEXT_L  = '고객'.
        LS_FIELDCAT-SELTEXT_M  = '고객'.
        LS_FIELDCAT-SELTEXT_S  = '고객'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_HEADER.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'NAME1'.
        LS_FIELDCAT-SELTEXT_L  = '고객명'.
        LS_FIELDCAT-SELTEXT_M  = '고객명'.
        LS_FIELDCAT-SELTEXT_S  = '고객명'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_HEADER.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'BELNR'.
        LS_FIELDCAT-EMPHASIZE  = 'X'.
        LS_FIELDCAT-HOTSPOT    = 'X'.
        LS_FIELDCAT-SELTEXT_L  = '미지급전표'.
        LS_FIELDCAT-SELTEXT_M  = '미지급전표'.
        LS_FIELDCAT-SELTEXT_S  = '미지급전표'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_HEADER.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'WRBTR'.
        LS_FIELDCAT-SELTEXT_L  = '미지급금액'.
        LS_FIELDCAT-SELTEXT_M  = '미지급금액'.
        LS_FIELDCAT-SELTEXT_S  = '미지급금액'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_HEADER.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'WAERS'.
        LS_FIELDCAT-SELTEXT_L  = '계약통화'.
        LS_FIELDCAT-SELTEXT_M  = '계약통화'.
        LS_FIELDCAT-SELTEXT_S  = '계약통화'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_HEADER.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'BUGA_AMNT'.
        LS_FIELDCAT-SELTEXT_L  = '미지급(Tax)'.
        LS_FIELDCAT-SELTEXT_M  = '미지급(Tax)'.
        LS_FIELDCAT-SELTEXT_S  = '미지급(Tax)'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_HEADER.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    "E01_FIELDCAT_INIT

*---------------------------------------------------------------------*
*       FORM E01_FIELDCAT_ITEM                                      *
*---------------------------------------------------------------------*
*  -->  E01_LT_FIELDCAT                                               *
*---------------------------------------------------------------------*
FORM E01_FIELDCAT_ITEM USING E01_LT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.

  DATA: LS_FIELDCAT TYPE SLIS_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = G_REPID
      I_INTERNAL_TABNAME = G_TABNAME_ITEM
      I_STRUCTURE_NAME   = G_ITEM_T
    CHANGING
      CT_FIELDCAT        = E01_LT_FIELDCAT[].

  LOOP AT E01_LT_FIELDCAT INTO LS_FIELDCAT.
    CHECK LS_FIELDCAT-TABNAME = G_TABNAME_ITEM.
    CASE LS_FIELDCAT-FIELDNAME.
      WHEN 'VBELN2'.
        LS_FIELDCAT-EMPHASIZE  = 'X'.
        LS_FIELDCAT-HOTSPOT    = 'X'.
        LS_FIELDCAT-SELTEXT_L  = '대금청구NO'.
        LS_FIELDCAT-SELTEXT_M  = '대금청구NO'.
        LS_FIELDCAT-SELTEXT_S  = '대금청구NO'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'NETWR'.
        LS_FIELDCAT-SELTEXT_L  = '매출액'.
        LS_FIELDCAT-SELTEXT_M  = '매출액'.
        LS_FIELDCAT-SELTEXT_S  = '매출액'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'WAERK'.
        LS_FIELDCAT-SELTEXT_L  = '매출통화'.
        LS_FIELDCAT-SELTEXT_M  = '매출통화'.
        LS_FIELDCAT-SELTEXT_S  = '매출통화'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'WRBTR'.
        LS_FIELDCAT-SELTEXT_L  = '미지급금액'.
        LS_FIELDCAT-SELTEXT_M  = '미지급금액'.
        LS_FIELDCAT-SELTEXT_S  = '미지급금액'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'R_WRBTR'.
        LS_FIELDCAT-SELTEXT_L  = '지급가능금액'.
        LS_FIELDCAT-SELTEXT_M  = '지급가능금액'.
        LS_FIELDCAT-SELTEXT_S  = '지급가능금액'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'WAERS'.
        LS_FIELDCAT-SELTEXT_L  = '계약통화'.
        LS_FIELDCAT-SELTEXT_M  = '계약통화'.
        LS_FIELDCAT-SELTEXT_S  = '계약통화'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'BUGA_AMNT'.
        LS_FIELDCAT-SELTEXT_L  = '미지급(Tax)'.
        LS_FIELDCAT-SELTEXT_M  = '미지급(Tax)'.
        LS_FIELDCAT-SELTEXT_S  = '미지급(Tax)'.
        LS_FIELDCAT-REPTEXT_DDIC = '미지급(Tax)'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'R_BUGA'.
        LS_FIELDCAT-SELTEXT_L  = '지급가능(Tax)'.
        LS_FIELDCAT-SELTEXT_M  = '지급가능(Tax)'.
        LS_FIELDCAT-SELTEXT_S  = '지급가능(Tax)'.
        LS_FIELDCAT-REPTEXT_DDIC = '지급가능(Tax)'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'SUKUM'.
        LS_FIELDCAT-SELTEXT_L  = '수금액'.
        LS_FIELDCAT-SELTEXT_M  = '수금액'.
        LS_FIELDCAT-SELTEXT_S  = '수금액'.
        LS_FIELDCAT-REPTEXT_DDIC = '수금액'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'YUBOM'.
        LS_FIELDCAT-SELTEXT_L  = '유보액'.
        LS_FIELDCAT-SELTEXT_M  = '유보액'.
        LS_FIELDCAT-SELTEXT_S  = '유보액'.
        LS_FIELDCAT-REPTEXT_DDIC = '유보액'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'YUSUK'.
        LS_FIELDCAT-SELTEXT_L  = '유보금수금액'.
        LS_FIELDCAT-SELTEXT_M  = '유보금수금액'.
        LS_FIELDCAT-SELTEXT_S  = '유보금수금액'.
        LS_FIELDCAT-REPTEXT_DDIC = '유보금수금액'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    "E01_FIELDCAT_ITEM
*---------------------------------------------------------------------*
*       FORM EVENTTAB_BUILD                                           *
*---------------------------------------------------------------------*
FORM E03_EVENTTAB_BUILD USING RT_EVENTS TYPE SLIS_T_EVENT.
*"Registration of events to happen during list display
  DATA: LS_EVENT TYPE SLIS_ALV_EVENT.
*
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      I_LIST_TYPE = 0
    IMPORTING
      ET_EVENTS   = RT_EVENTS.
  READ TABLE RT_EVENTS WITH KEY NAME = SLIS_EV_TOP_OF_PAGE
                           INTO LS_EVENT.
  IF SY-SUBRC = 0.
    MOVE G_TOP_OF_PAGE TO LS_EVENT-FORM.
    APPEND LS_EVENT TO RT_EVENTS.
  ENDIF.
ENDFORM.                    "E03_EVENTTAB_BUILD
*---------------------------------------------------------------------*
*       FORM E04_COMMENT_BUILD                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  E04_LT_TOP_OF_PAGE                                            *
*---------------------------------------------------------------------*
FORM E04_COMMENT_BUILD USING E04_LT_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER.
  DATA: LS_LINE TYPE SLIS_LISTHEADER.
*
** Listen?erschrift: Typ H
*  clear ls_line.
*  ls_line-typ  = 'H'.
** LS_LINE-KEY:  not used for this type
*  ls_line-info = text-001.
*  append ls_line to e04_lt_top_of_page.
** Kopfinfo: Typ S
*  clear ls_line.
*  ls_line-typ  = 'S'.
*  ls_line-key  = text-050.
*  ls_line-info = text-010.
*  append ls_line to e04_lt_top_of_page.
*  ls_line-key  = text-051.
*  append ls_line to e04_lt_top_of_page.
** Aktionsinfo: Typ A
  CLEAR LS_LINE.
  LS_LINE-TYP  = 'A'.
* LS_LINE-KEY:  not used for this type
  LS_LINE-INFO = TEXT-050.
  APPEND LS_LINE TO  E04_LT_TOP_OF_PAGE.

ENDFORM.                    "E04_COMMENT_BUILD
*---------------------------------------------------------------------*
*       FORM E05_LAYOUT_BUILD                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  <->  E05_LS_LAYOUT                                                 *
*---------------------------------------------------------------------*
FORM E05_LAYOUT_BUILD USING E05_LS_LAYOUT TYPE SLIS_LAYOUT_ALV.

*  e05_ls_layout-lights_fieldname  = p_lignam.
*  e05_ls_layout-lights_tabname    = g_tabname_item.
*  E05_LS_LAYOUT-LIGHTS_CONDENSE   = P_LIGHTC.
  E05_LS_LAYOUT-BOX_FIELDNAME     = G_BOXNAM.
  E05_LS_LAYOUT-BOX_TABNAME       = G_TABNAME_ITEM.
*  E05_LS_LAYOUT-HEADER_TEXT       = TEXT-071.
*  E05_LS_LAYOUT-ITEM_TEXT         = TEXT-072.
*  E05_LS_LAYOUT-DEFAULT_ITEM      = 'X'.
*  E05_LS_LAYOUT-F2CODE            = P_F2CODE.
  E05_LS_LAYOUT-ZEBRA             = 'X'.
*  E05_LS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
*  E05_LS_LAYOUT-NO_INPUT          = 'X'.
*  E05_LS_LAYOUT-NO_COLHEAD        = 'X'.
*  E05_LS_LAYOUT-TOTALS_TEXT       = 'X'.
*  E05_LS_LAYOUT-SUBTOTALS_TEXT    = 'X'.
*  E05_LS_LAYOUT-TOTALS_ONLY       = 'X'.
*  E05_LS_LAYOUT-KEY_HOTSPOT       = 'X'.
*  E05_LS_LAYOUT-DETAIL_POPUP      = 'X'.
*  E05_LS_LAYOUT-GROUP_CHANGE_EDIT = 'X'.
*  E05_LS_LAYOUT-GROUP_BUTTONS     = P_GROUPB.
*  E05_LS_LAYOUT-GROUP_BUTTONS       = SPACE.
*  E05_LS_LAYOUT-F2CODE              = 'BELE'.
*  E05_LS_LAYOUT-NO_SUMCHOICE        = 'X'.
*  E05_LS_LAYOUT-NO_SUBTOTALS        = 'X'.
*  E05_LS_LAYOUT-GROUP_CHANGE_EDIT = 'X'.

ENDFORM.                    "E05_LAYOUT_BUILD
*---------------------------------------------------------------------*
*       FORM E07_SP_GROUP_BUILD                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  E07_LT_SP_GROUP                                               *
*---------------------------------------------------------------------*
FORM E07_SP_GROUP_BUILD USING E07_LT_SP_GROUP TYPE SLIS_T_SP_GROUP_ALV.
  DATA: LS_SP_GROUP TYPE SLIS_SP_GROUP_ALV.
*
  CLEAR  LS_SP_GROUP.
  LS_SP_GROUP-SP_GROUP = 'A'.
  LS_SP_GROUP-TEXT     = TEXT-005.
  APPEND LS_SP_GROUP TO E07_LT_SP_GROUP.
ENDFORM.                    "E07_SP_GROUP_BUILD
*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM TOP_OF_PAGE.
*
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = GT_LIST_TOP_OF_PAGE.

ENDFORM.                    "TOP_OF_PAGE
*---------------------------------------------------------------------*
*       FORM F4_FOR_VARIANT                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM F4_FOR_VARIANT.
*
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      IS_VARIANT       = G_VARIANT
      I_SAVE           = G_SAVE
      I_TABNAME_HEADER = G_TABNAME_HEADER
      I_TABNAME_ITEM   = G_TABNAME_ITEM
*     it_default_fieldcat =
    IMPORTING
      E_EXIT           = G_EXIT
      ES_VARIANT       = GX_VARIANT
    EXCEPTIONS
      NOT_FOUND        = 2.
  IF SY-SUBRC = 2.
    MESSAGE ID SY-MSGID TYPE 'S'      NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    IF G_EXIT = SPACE.
      P_VARI = GX_VARIANT-VARIANT.
    ENDIF.
  ENDIF.

ENDFORM.                    "F4_FOR_VARIANT

*&---------------------------------------------------------------------*
*&      Form  PAI_OF_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM PAI_OF_SELECTION_SCREEN.
*
  IF NOT P_VARI IS INITIAL.
    MOVE G_VARIANT TO GX_VARIANT.
    MOVE P_VARI TO GX_VARIANT-VARIANT.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        I_SAVE     = G_SAVE
      CHANGING
        CS_VARIANT = GX_VARIANT.
    G_VARIANT = GX_VARIANT.
  ELSE.
    PERFORM VARIANT_INIT.
  ENDIF.

ENDFORM.                               " PAI_OF_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  VARIANT_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VARIANT_INIT.
*
  CLEAR G_VARIANT.
  G_VARIANT-REPORT = G_REPID.

*   Get default variant
  GX_VARIANT = G_VARIANT.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      I_SAVE     = G_SAVE
    CHANGING
      CS_VARIANT = GX_VARIANT
    EXCEPTIONS
      NOT_FOUND  = 2.
  IF SY-SUBRC = 0.
    P_VARI = GX_VARIANT-VARIANT.
  ENDIF.

ENDFORM.                               " VARIANT_INIT
*---------------------------------------------------------------------*
*       FORM alv_sort_build                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM ALV_SORT_BUILD.
  DATA: LS_SORT TYPE SLIS_SORTINFO_ALV.

*  GT_SORT-FIELDNAME = 'WAERK'.
*  GT_SORT-TABNAME = G_TABNAME_HEADER.
*  GT_SORT-SPOS      = 1.
*  GT_SORT-UP        = 'X'.
**  GT_SORT-SUBTOT    = 'X'.
**  GT_SORT-GROUP    = 'A'.
*  APPEND GT_SORT.
*  GT_SORT-FIELDNAME = 'NETWR'.
*  GT_SORT-TABNAME = G_TABNAME_HEADER.
*  GT_SORT-SPOS      = 2.
*  GT_SORT-UP        = 'X'.
*  GT_SORT-SUBTOT    = 'X'.
**  GT_SORT-GROUP    = 'A'.
*  APPEND GT_SORT.

ENDFORM.                    "ALV_SORT_BUILD
*&---------------------------------------------------------------------*
*&      Form  DATA_WRITE_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_WRITE_PROCESS .

  G_TABNAME_HEADER = 'GT_HEADER'.
  G_TABNAME_ITEM   = 'GT_ITEM'.
* define keyinfo
  CLEAR GS_KEYINFO.
  GS_KEYINFO-HEADER01 = 'BONEM'.
  GS_KEYINFO-ITEM01   = 'BONEM'.
  GS_KEYINFO-HEADER02 = 'KNUMA'.
  GS_KEYINFO-ITEM02   = 'KNUMA'.
  GS_KEYINFO-HEADER03 = 'FBUDA'.
  GS_KEYINFO-ITEM03   = 'FBUDA'.
  GS_KEYINFO-HEADER04 = 'BELNR'.
  GS_KEYINFO-ITEM04   = 'BELNR'.

  PERFORM E01_FIELDCAT_INIT    USING GT_FIELDCAT[].
*  perform e01_fieldcat_header  using gt_fieldcat[].
*  perform e01_fieldcat_item    using gt_fieldcat[].
  PERFORM E03_EVENTTAB_BUILD USING GT_EVENTS[].
  PERFORM E04_COMMENT_BUILD  USING GT_LIST_TOP_OF_PAGE[].
  PERFORM E07_SP_GROUP_BUILD USING GT_SP_GROUP[].
  PERFORM E05_LAYOUT_BUILD USING GS_LAYOUT.     "wg. Parameters
  PERFORM ALV_SORT_BUILD.

* Call ABAP/4 List Viewer
  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = G_REPID
      I_CALLBACK_PF_STATUS_SET = G_STATUS_SET
      I_CALLBACK_USER_COMMAND  = G_USER_COMMAND
      IS_LAYOUT                = GS_LAYOUT
      IT_FIELDCAT              = GT_FIELDCAT[]
*     IT_EXCLUDING             =
      IT_SPECIAL_GROUPS        = GT_SP_GROUP[]
*     IT_SORT                  = GT_SORT[]
*     IT_FILTER                =
*     IS_SEL_HIDE              =
*     I_SCREEN_START_COLUMN    = 0
*     I_SCREEN_START_LINE      = 0
*     I_SCREEN_END_COLUMN      = 0
*     I_SCREEN_END_LINE        = 0
*     i_default                = g_default
      I_SAVE                   = 'A'
      IS_VARIANT               = G_VARIANT
      IT_EVENTS                = GT_EVENTS[]
*     IT_EVENT_EXIT            =
      I_TABNAME_HEADER         = G_TABNAME_HEADER
      I_TABNAME_ITEM           = G_TABNAME_ITEM
      IS_KEYINFO               = GS_KEYINFO
*     IS_PRINT                 =
*      IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
    TABLES
      T_OUTTAB_HEADER          = G_HEADER_T
      T_OUTTAB_ITEM            = G_ITEM_T.

ENDFORM.                    " DATA_WRITE_PROCESS

*&---------------------------------------------------------------------*
*&      Form  READ_DATA_PROCESS
*&---------------------------------------------------------------------*
FORM READ_DATA_PROCESS .

  CLEAR : G_ITAB_T, G_ITAB_T[].

** 대상 Data를 Query.
  SELECT  VBRK~VBELN AS VBELN2
          ZKONA~VKORG ZKONA~VTWEG ZKONA~SPART
*->[CHG]-------------------------S
          VBAK~VKBUR VBAK~VKGRP    "ZKONA~VKBUR ZKONA~VKGRP
*-<[CHG]-------------------------E
          VBRK~KUNAG VBRK~NETWR  VBRK~WAERK
          ZKONA~BONEM ZKONA~KNUMA ZKONA~BOTEXT ZKONA~BOSTA
          ZKONA~WAERS VBRK~KUNAG VBRK~NETWR  VBRK~WAERK
          ZSD0016T~WRBTR ZSD0016T~BUGA_AMNT ZSD0016T~K_WAERK
          ZSD0016T~BELNR ZSD0016T~VBELN     ZSD0016T~FBUDA
          ZSD0016T~BUGA_BELNR VBRK~BUPLA
    INTO  CORRESPONDING FIELDS OF TABLE G_ITAB_T
    FROM  ZKONA INNER JOIN ZSD0016T
                ON ZSD0016T~KNUMA = ZKONA~KNUMA
                INNER JOIN VBRK
                ON VBRK~VBELN = ZSD0016T~VBELN2
*->[CHG]-------------------------S
                INNER JOIN VBAK
                ON ZSD0016T~VBELN = VBAK~VBELN
*-<[CHG]-------------------------E
   WHERE  ZKONA~VKORG    EQ  PA_VKORG
     AND  ZKONA~VTWEG    IN  PA_VTWEG
     AND  ZKONA~SPART    IN  PA_SPART
*->[CHG]-------------------------S
     AND  VBAK~VKBUR    IN  PA_VKBUR
     AND  VBAK~VKGRP    IN  PA_VKGRP
*     AND  ZKONA~VKBUR    IN  PA_VKBUR
*     AND  ZKONA~VKGRP    IN  PA_VKGRP
*-<[CHG]-------------------------E
     AND  ZKONA~KNUMA    IN  SO_KNUMA
     AND  ZKONA~BONEM    IN  SO_BONEM
     AND  ZSD0016T~FBUDA EQ  PA_SPMON
     AND  VBRK~DRAFT     EQ  SPACE.



  DATA : LS_ITAB  LIKE LINE OF G_ITAB_T,
         LT_ITAB  LIKE STANDARD TABLE OF G_ITAB_T,
         LT_ITAB2 LIKE STANDARD TABLE OF G_ITAB_T.

  SELECT A~VBELN AS VBELN2 A~KUNAG
         A~NETWR           A~WAERK
         A~KUNAG           A~NETWR
         A~WAERK           A~BUPLA
         B~VKORG           B~VTWEG
*->[CHG]-------------------------S
         B~SPART           D~VKBUR
         D~VKGRP           B~BONEM
*         B~SPART           B~VKBUR
*         B~VKGRP           B~BONEM
*-<[CHG]-------------------------E
         B~KNUMA           B~BOTEXT
         B~BOSTA           B~WAERS
         C~WRBTR           C~BUGA_AMNT
         C~K_WAERK         C~BELNR
         C~VBELN           C~FBUDA
         C~BUGA_BELNR
  INTO CORRESPONDING FIELDS OF TABLE LT_ITAB
    FROM ZKONA AS B INNER JOIN ZSD0016T AS C
                    ON C~KNUMA = B~KNUMA
                    INNER JOIN ZVBRK_R3 AS A
                    ON A~VBELN = C~VBELN2
*->[CHG]-------------------------S
                    INNER JOIN ZVBAK_R3 AS D
                    ON C~VBELN = D~VBELN
*-<[CHG]-------------------------E
    WHERE B~VKORG EQ PA_VKORG
      AND B~VTWEG IN PA_VTWEG
      AND B~SPART IN PA_SPART
*->[CHG]-------------------------S
      AND D~VKBUR IN PA_VKBUR
      AND D~VKGRP IN PA_VKGRP
*      AND B~VKBUR IN PA_VKBUR
*      AND B~VKGRP IN PA_VKGRP
*-<[CHG]-------------------------E
      AND B~KNUMA IN SO_KNUMA
      AND B~BONEM IN SO_BONEM
      AND C~FBUDA EQ PA_SPMON.



  IF SY-SUBRC = 0 AND LT_ITAB[] IS NOT INITIAL.

    SORT G_ITAB_T BY VBELN.

    CLEAR : LS_ITAB, LT_ITAB2, LT_ITAB2[].

    LOOP AT LT_ITAB INTO LS_ITAB.

      LS_ITAB-ECC_MIG = 'X'.
      APPEND LS_ITAB TO LT_ITAB2.
      CLEAR LS_ITAB.

    ENDLOOP.

    IF LT_ITAB2[] IS NOT INITIAL.
      APPEND LINES OF LT_ITAB2[] TO G_ITAB_T[].
    ENDIF.

    SORT G_ITAB_T BY VBELN BELNR VBELN2 KNUMA.

    DELETE ADJACENT DUPLICATES FROM G_ITAB_T COMPARING VBELN BELNR VBELN2 KNUMA.


  ENDIF.


  SORT G_ITAB_T BY VBELN.

  DESCRIBE TABLE G_ITAB_T LINES G_TOTCNT.

  IF  G_TOTCNT  >  0.

    PERFORM  DATA_SUB_QUERY.

    PERFORM  DATA_GETHERING.

  ELSE.

    IF  G_ITAB_T[] IS INITIAL.

      CALL FUNCTION 'WS_MSG'
        EXPORTING
          MSG_TYPE = 'I'
          TEXT     = '조건에 맞는 DATA가 없습니다.'
          TITL     = '검색결과'.
      EXIT.

    ENDIF.

  ENDIF.

ENDFORM.                    " READ_DATA_PROCESS

*&---------------------------------------------------------------------*
*&      Form  data_gethering
*&---------------------------------------------------------------------*
FORM DATA_GETHERING .

  DATA : L_ZYYMM LIKE ZSD0013T-ZYYYYMM.

  LOOP AT G_ITAB_T.

    IF  G_ITAB_T-BONEM+0(6)  =  '000038'.

      G_ITAB_T-BUGA_AMNT = 0.
      G_ITAB_T-BUGA      = 0.
      G_ITAB_T-R_BUGA    = 0.

      MODIFY G_ITAB_T.
      CLEAR G_ITAB_T.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " data_gethering

*&---------------------------------------------------------------------*
*&      Form  data_sub_query
*&---------------------------------------------------------------------*
FORM DATA_SUB_QUERY .

  LOOP AT G_ITAB_T.

** 고객명
    SELECT  SINGLE NAME1
      INTO  G_ITAB_T-NAME1
      FROM  KNA1
     WHERE  KUNNR  =  G_ITAB_T-KUNAG.

** Agent명
    SELECT  SINGLE NAME1
      INTO  G_ITAB_T-NAME
      FROM  KNA1
     WHERE  KUNNR  =  G_ITAB_T-BONEM.

** 사업장명
    SELECT  SINGLE BEZEI
      INTO  G_ITAB_T-BEZEI
      FROM  TVKBT
     WHERE  SPRAS  =  SY-LANGU
       AND  VKBUR  =  G_ITAB_T-VKBUR.

** 영업그룹명
    SELECT  SINGLE BEZEI
      INTO  G_ITAB_T-BEZEI2
      FROM  TVGRT
     WHERE  SPRAS  =  SY-LANGU
       AND  VKGRP  =  G_ITAB_T-VKGRP.

** 수금액.
    PERFORM SUKUM_AMNT_RTN.

** 유보금.
*    perform  yubo_amnt_rtn.

** 유보금수금액.
*    perform  yubo_sukum_rtn.

    MODIFY  G_ITAB_T.
    CLEAR  G_ITAB_T.

  ENDLOOP.

ENDFORM.                    " data_sub_query

*&---------------------------------------------------------------------*
*&      Form  MODIFY_DATA_PROCESS
*&---------------------------------------------------------------------*
FORM MODIFY_DATA_PROCESS .

  CLEAR : G_HEADER_T, G_ITEM_T, G_TMP_T.
  REFRESH : G_HEADER_T, G_ITEM_T, G_TMP_T.

  LOOP AT G_ITAB_T.
    MOVE-CORRESPONDING  G_ITAB_T  TO  G_TMP_T.
    APPEND  G_TMP_T.
    CLEAR : G_TMP_T, G_ITAB_T.
  ENDLOOP.

** Internal TBL를 빌링번호/지급전표번호별로 다시 구성한다.
** 그래서 화면에 Display할때는 빌링번호별로 지급금액을 Sum해서
** 보여준다.
  CLEAR : G_ITAB_T, G_ITAB_T[].

  LOOP AT G_TMP_T.

    MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.

    G_TMP_T-SEQ = 0.

    SELECT  BELNR2
            BUGA_BELNR
            FBUDA_BELNR2
            FBUDA2
      INTO (G_ITAB_T-BELNR2,      " 지급전표
            G_ITAB_T-BELNR2_BUGA,
            G_ITAB_T-FBUDA2_BUGA,
            G_ITAB_T-FBUDA2) " 부가세지급전표
      FROM  ZSD0017T
     WHERE  KNUMA  =  G_TMP_T-KNUMA
       AND  VBELN  =  G_TMP_T-VBELN
       AND  BELNR  =  G_TMP_T-BELNR
       AND  VBELN2 =  G_TMP_T-VBELN2.

      IF  SY-SUBRC  =  0.
        G_ITAB_T-SEQ =  G_ITAB_T-SEQ + 1.
        APPEND  G_ITAB_T.
      ELSE.

        G_ITAB_T-BELNR2       =  SPACE.
        G_ITAB_T-BELNR2_BUGA  =  SPACE.
        G_ITAB_T-WRBTR2       =  0.
        G_ITAB_T-BUGA         =  0.

      ENDIF.

    ENDSELECT.

*->[CHG]--------------------------BY ZGODEV01 2026.01.27
*    CLEAR : G_TMP_T, G_ITAB_T.
    IF SY-SUBRC NE 0.
    APPEND  G_ITAB_T.
    ENDIF.
    CLEAR : G_TMP_T, G_ITAB_T.
*-<[CHG]--------------------------BY ZGODEV01 2026.01.27
  ENDLOOP.

  LOOP AT G_ITAB_T.

    IF G_ITAB_T-VKORG IS INITIAL.
      DELETE G_ITAB_T.
    ELSE.

      MOVE-CORRESPONDING  G_ITAB_T  TO  G_HEADER_T.
      COLLECT  G_HEADER_T.

      MOVE-CORRESPONDING  G_ITAB_T  TO  G_ITEM_T.
      G_ITEM_T-BONEM1 = G_ITEM_T-BONEM.

      IF  NOT G_ITAB_T-BELNR2 IS INITIAL  OR
          G_ITAB_T-BELNR2  NE  SPACE.

        IF  NOT G_ITAB_T-BELNR2_BUGA IS INITIAL  OR
            G_ITAB_T-BELNR2_BUGA  NE  SPACE.

          IF  G_ITAB_T-BUGA  =  G_ITAB_T-BUGA_AMNT.
            G_ITEM_T-LIGHTS  =  C_BLIGHT.
          ELSE.
            G_ITEM_T-LIGHTS  =  C_CLIGHT.
          ENDIF.

        ELSE.

          IF  G_ITAB_T-WRBTR  =  G_ITAB_T-WRBTR2.
            G_ITEM_T-LIGHTS  =  C_CLIGHT.
          ELSE.
            G_ITEM_T-LIGHTS  =  C_FLIGHT.
          ENDIF.

        ENDIF.

      ELSE.
        G_ITEM_T-LIGHTS  =  C_FLIGHT.
      ENDIF.

      APPEND  G_ITEM_T.

      CLEAR : G_HEADER_T, G_ITEM_T, G_ITAB_T.

    ENDIF.

  ENDLOOP.

** 지급가능금액 Calc
  LOOP AT G_ITEM_T WHERE SEQ > 1.

    G_ITEM_T-BONEM1 = SPACE.
    G_ITEM_T-KUNAG =  SPACE.
    G_ITEM_T-VKORG =  SPACE.
    G_ITEM_T-VTWEG =  SPACE.
    G_ITEM_T-SPART =  SPACE.
    G_ITEM_T-BEZEI =  SPACE.
    G_ITEM_T-BEZEI2 =  SPACE.
    G_ITEM_T-BUPLA =  SPACE.
    G_ITEM_T-VBELN2 =  SPACE.
    G_ITEM_T-NETWR = 0.
    G_ITEM_T-WAERK =  SPACE.
    G_ITEM_T-SUKUM = 0.
    G_ITEM_T-WRBTR = 0.

    MODIFY  G_ITEM_T.
    CLEAR : G_ITEM_T.

  ENDLOOP.

ENDFORM.                    " MODIFY_DATA_PROCESS

*&---------------------------------------------------------------------*
*&      Form  INTIALIZATION_DATA
*&---------------------------------------------------------------------*
FORM INTIALIZATION_DATA .

  CLEAR : G_HEADER_T, G_ITEM_T, G_ITAB_T.
  REFRESH : G_HEADER_T, G_ITEM_T, G_ITAB_T.

ENDFORM.                    " INTIALIZATION_DATA

*&---------------------------------------------------------------------*
*&      Form  sukum_amnt_rtn
*&---------------------------------------------------------------------*
FORM SUKUM_AMNT_RTN .

  DATA : L_DMBTR        LIKE BSEG-DMBTR,
         L_SUM_DMBTR    LIKE BSEG-DMBTR,
         L_WRBTR        LIKE BSEG-DMBTR,
         L_SUM_WRBTR    LIKE BSEG-DMBTR,
         L_SHKZG        LIKE BSEG-SHKZG,
         L_BUDAT        LIKE SY-DATUM,
         L_AUGBL        LIKE BSAD-AUGBL,
         L_SGTXT        LIKE BSAD-SGTXT,
         L_VBELN2_SGTXT TYPE C LENGTH 12,
         L_GJAHR        LIKE BSEG-GJAHR.

  DATA : L_SAD_SHKZG LIKE BSAD-SHKZG,
         LS_SGTXT    LIKE BSAD-SGTXT,
         L_SID_SHKZG LIKE BSID-SHKZG.

  CLEAR : L_DMBTR, L_SUM_DMBTR,
          L_WRBTR, L_SUM_WRBTR,
          L_BUDAT, L_AUGBL, L_GJAHR,
          L_SUM_DMBTR, L_SUM_WRBTR, L_SID_SHKZG.

  CLEAR L_VBELN2_SGTXT.

  CONCATENATE  '%' G_ITAB_T-VBELN2 '%'  INTO  L_VBELN2_SGTXT.
*>> START - Archiving 관련변경 03 -> 20080312
  SELECT  BSID~DMBTR BSID~WRBTR BSID~SHKZG BSID~SGTXT
    INTO (L_DMBTR, L_WRBTR, L_SID_SHKZG, LS_SGTXT)
    FROM  BSID INNER JOIN BKPF ON BSID~BUKRS = BKPF~BUKRS
                              AND BSID~BELNR = BKPF~BELNR
                              AND BSID~GJAHR = BKPF~GJAHR
   WHERE  BKPF~STBLG = ' '
     AND  BSID~KUNNR EQ G_ITAB_T-KUNAG
     AND  BSID~SGTXT LIKE L_VBELN2_SGTXT
     AND  BSID~BLART IN ('CC', 'CE', 'CF', 'CL', 'CJ', 'AB', 'CA', 'AG', 'TE' )
     AND  BSID~UMSKZ = ' '.

    IF LS_SGTXT+19(10) = G_ITAB_T-VBELN2.

      IF L_SID_SHKZG = 'H'.
        L_SUM_DMBTR  =  L_SUM_DMBTR  +  L_DMBTR.
        L_SUM_WRBTR  =  L_SUM_WRBTR  +  L_WRBTR.
      ELSE.
        L_SUM_DMBTR  =  L_SUM_DMBTR  -  L_DMBTR.
        L_SUM_WRBTR  =  L_SUM_WRBTR  -  L_WRBTR.

      ENDIF.

    ENDIF.

    CLEAR : L_DMBTR, L_WRBTR, L_AUGBL, L_SID_SHKZG, LS_SGTXT.

  ENDSELECT.

*-- 아카이브 체크를 한 경우에만 AS 테이블에서 정보를 가지고 온다.
  IF NOT P_ARCV IS INITIAL.
    SELECT  BSID~DMBTR BSID~WRBTR BSID~SHKZG BSID~SGTXT
      INTO (L_DMBTR, L_WRBTR, L_SID_SHKZG, LS_SGTXT)
      FROM  BSID INNER JOIN ZARIXFI3 AS BKPF
                                 ON BSID~BUKRS = BKPF~BUKRS
                                AND BSID~BELNR = BKPF~BELNR
                                AND BSID~GJAHR = BKPF~GJAHR
     WHERE  BKPF~STBLG  =  ' '
       AND  BSID~KUNNR  EQ  G_ITAB_T-KUNAG
       AND  BSID~SGTXT  LIKE L_VBELN2_SGTXT
       AND  BSID~BLART  IN ('CC', 'CE', 'CF', 'CL', 'CJ', 'AB'
                           ,'CA', 'AG', 'TE' )
  "확인요망
       AND  BSID~UMSKZ  =  ' '.

      IF LS_SGTXT+19(10) = G_ITAB_T-VBELN2.

        IF L_SID_SHKZG = 'H'.
          L_SUM_DMBTR  =  L_SUM_DMBTR  +  L_DMBTR.
          L_SUM_WRBTR  =  L_SUM_WRBTR  +  L_WRBTR.
        ELSE.
          L_SUM_DMBTR  =  L_SUM_DMBTR  -  L_DMBTR.
          L_SUM_WRBTR  =  L_SUM_WRBTR  -  L_WRBTR.

        ENDIF.

      ENDIF.

      CLEAR : L_DMBTR, L_WRBTR, L_AUGBL, L_SID_SHKZG, LS_SGTXT.

    ENDSELECT.
  ENDIF.

  IF L_SUM_DMBTR IS INITIAL.
    G_ITAB_T-K_SUKUM = 0.
  ELSE.
    G_ITAB_T-K_SUKUM = L_SUM_DMBTR.
  ENDIF.

  IF L_SUM_WRBTR IS INITIAL.
    G_ITAB_T-SUKUM = 0.
  ELSE.
    G_ITAB_T-SUKUM = L_SUM_WRBTR.
  ENDIF.

  CLEAR : L_DMBTR, L_SUM_DMBTR,
          L_WRBTR, L_SUM_WRBTR,
          L_BUDAT, L_AUGBL, L_SGTXT, L_GJAHR,
          L_SUM_DMBTR, L_SUM_WRBTR, L_SAD_SHKZG.

*>> START - Archiving 관련변경 04 -> 20080312
  SELECT  BSAD~DMBTR BSAD~WRBTR BSAD~SGTXT BSAD~SHKZG
    INTO (L_DMBTR, L_WRBTR, L_SGTXT, L_SAD_SHKZG)
    FROM  BSAD INNER JOIN BKPF
               ON BSAD~BUKRS = BKPF~BUKRS
              AND BSAD~BELNR = BKPF~BELNR
              AND BSAD~GJAHR = BKPF~GJAHR
   WHERE  BKPF~STBLG = ' '
     AND  BSAD~KUNNR = G_ITAB_T-KUNAG
     AND  BSAD~SGTXT LIKE L_VBELN2_SGTXT
     AND  BSAD~BLART IN ('CC', 'CE', 'CF', 'CL', 'CJ','AB', 'CA', 'AG', 'TE')
     AND  BSAD~UMSKZ EQ ' '.

    IF  L_SGTXT+19(10) EQ G_ITAB_T-VBELN2.

      IF  L_AUGBL+0(3) NE '114'.

        IF L_SAD_SHKZG = 'H'.
          L_SUM_DMBTR  =  L_SUM_DMBTR  +  L_DMBTR.
          L_SUM_WRBTR  =  L_SUM_WRBTR  +  L_WRBTR.
        ELSE.
          L_SUM_DMBTR  =  L_SUM_DMBTR  -  L_DMBTR.
          L_SUM_WRBTR  =  L_SUM_WRBTR  -  L_WRBTR.
        ENDIF.

      ENDIF.

    ENDIF.

    CLEAR : L_DMBTR, L_WRBTR, L_SGTXT, L_SID_SHKZG.

  ENDSELECT.

*-- 아카이브 체크를 한 경우에만 AS 테이블에서 정보를 가지고 온다.
  IF NOT P_ARCV IS INITIAL.

    SELECT  BSAD~DMBTR BSAD~WRBTR BSAD~SGTXT BSAD~SHKZG
      INTO (L_DMBTR, L_WRBTR, L_SGTXT, L_SAD_SHKZG)
      FROM  BSAD INNER JOIN ZARIXFI3 AS BKPF
                 ON BSAD~BUKRS = BKPF~BUKRS
                AND BSAD~BELNR = BKPF~BELNR
                AND BSAD~GJAHR = BKPF~GJAHR
     WHERE  BKPF~STBLG  =  ' '
       AND  BSAD~KUNNR  =  G_ITAB_T-KUNAG
       AND  BSAD~SGTXT  LIKE  L_VBELN2_SGTXT
       AND  BSAD~BLART  IN ('CC', 'CE', 'CF', 'CL', 'CJ','AB'
                           ,'CA', 'AG', 'TE')
       AND  BSAD~UMSKZ  =  ' '.

      IF  L_SGTXT+19(10)  EQ  G_ITAB_T-VBELN2.

        IF  L_AUGBL+0(3)  NE  '114'.
          IF L_SAD_SHKZG = 'H'.
            L_SUM_DMBTR  =  L_SUM_DMBTR  +  L_DMBTR.
            L_SUM_WRBTR  =  L_SUM_WRBTR  +  L_WRBTR.
          ELSE.
            L_SUM_DMBTR  =  L_SUM_DMBTR  -  L_DMBTR.
            L_SUM_WRBTR  =  L_SUM_WRBTR  -  L_WRBTR.
          ENDIF.
        ENDIF.

      ENDIF.

      CLEAR : L_DMBTR, L_WRBTR, L_SGTXT, L_SID_SHKZG.

    ENDSELECT.
  ENDIF.
*>> END   - Archiving 관련변경 04 -> 20080312

  G_ITAB_T-K_SUKUM = G_ITAB_T-K_SUKUM + L_SUM_DMBTR.
  G_ITAB_T-SUKUM   = G_ITAB_T-SUKUM + L_SUM_WRBTR.


  IF G_ITAB_T-SUKUM > G_ITAB_T-NETWR.
    G_ITAB_T-SUKUM = G_ITAB_T-NETWR.
  ENDIF.

ENDFORM.                    " sukum_amnt_rtn

*&---------------------------------------------------------------------*
*&      Form  yubo_amnt_rtn
*&---------------------------------------------------------------------*
FORM YUBO_AMNT_RTN .

  DATA : L_DMBTR     LIKE BSEG-DMBTR,
         L_SUM_DMBTR LIKE BSEG-DMBTR,
         L_WRBTR     LIKE BSEG-DMBTR,
         L_SUM_WRBTR LIKE BSEG-DMBTR,
         L_SHKZG     LIKE BSEG-SHKZG,
         L_BUDAT     LIKE SY-DATUM,
         L_AUGBL     LIKE BSAD-AUGBL,
         L_GJAHR     LIKE BSEG-GJAHR.
  CLEAR : L_DMBTR, L_SUM_DMBTR,
          L_WRBTR, L_SUM_WRBTR,
          L_BUDAT, L_AUGBL, L_GJAHR.

  SELECT  SINGLE DMBTR WRBTR   " dmbtr:현지, wrbtr:전표
    INTO (G_ITAB_T-K_YUBOM, G_ITAB_T-YUBOM)
    FROM  BSID
   WHERE  KUNNR  =  G_ITAB_T-KUNAG
     AND  REBZG  =  G_ITAB_T-VBELN2
     AND  BLART  =  'CM'.

  IF  SY-SUBRC  NE  0.
    G_ITAB_T-K_YUBOM  =  0.
    G_ITAB_T-YUBOM    =  0.
  ENDIF.

  SELECT  DMBTR WRBTR AUGBL  " dmbtr:현지, wrbtr:전표
    INTO (L_DMBTR, L_WRBTR, L_AUGBL)
    FROM  BSAD
   WHERE  KUNNR  =  G_ITAB_T-KUNAG
     AND  REBZG  =  G_ITAB_T-VBELN2
     AND  BLART  =  'CM'.

    IF  L_AUGBL+0(3)  NE  '114'.
      L_SUM_DMBTR  =  L_SUM_DMBTR  +  L_DMBTR.
      L_SUM_WRBTR  =  L_SUM_WRBTR  +  L_WRBTR.
    ENDIF.

    CLEAR : L_DMBTR, L_WRBTR, L_AUGBL.

  ENDSELECT.

  G_ITAB_T-K_YUBOM  =  G_ITAB_T-K_YUBOM  +  L_SUM_DMBTR.
  G_ITAB_T-YUBOM  =  G_ITAB_T-YUBOM  +  L_SUM_WRBTR.

ENDFORM.                    " yubo_amnt_rtn

*&---------------------------------------------------------------------*
*&      Form  yubo_sukum_rtn
*&---------------------------------------------------------------------*
FORM YUBO_SUKUM_RTN .

  DATA : L_DMBTR     LIKE BSEG-DMBTR,
         L_SUM_DMBTR LIKE BSEG-DMBTR,
         L_WRBTR     LIKE BSEG-DMBTR,
         L_SUM_WRBTR LIKE BSEG-DMBTR,
         L_SHKZG     LIKE BSEG-SHKZG,
         L_BUDAT     LIKE SY-DATUM,
         L_AUGBL     LIKE BSAD-AUGBL,
         L_BELNR     LIKE BSAD-BELNR.
  CLEAR : L_DMBTR, L_SUM_DMBTR,
          L_WRBTR, L_SUM_WRBTR,
          L_BUDAT, L_AUGBL, L_BELNR.

  SELECT  SINGLE BELNR
    INTO  L_BELNR
    FROM  BSID
   WHERE  KUNNR  =  G_ITAB_T-KUNAG
     AND  REBZG  =  G_ITAB_T-VBELN2
     AND  BLART  =  'CM'.

  IF  SY-SUBRC  EQ  0.

    SELECT  SINGLE DMBTR WRBTR   " dmbtr:현지, wrbtr:전표
      INTO (G_ITAB_T-K_YUSUK, G_ITAB_T-YUSUK)
      FROM  BSID
     WHERE  KUNNR  =  G_ITAB_T-KUNAG
       AND  REBZG  =  L_BELNR
       AND  BLART  =  'CM'.

  ELSE.
    G_ITAB_T-K_YUSUK  =  0.
    G_ITAB_T-YUSUK    =  0.
  ENDIF.

  SELECT  BELNR
    INTO  L_BELNR
    FROM  BSAD
   WHERE  KUNNR  =  G_ITAB_T-KUNAG
     AND  REBZG  =  G_ITAB_T-VBELN2
     AND  BLART  =  'CM'.

    SELECT  DMBTR WRBTR AUGBL  " dmbtr:현지, wrbtr:전표
      INTO (L_DMBTR, L_WRBTR, L_AUGBL)
      FROM  BSAD
     WHERE  KUNNR  =  G_ITAB_T-KUNAG
       AND  REBZG  =  L_BELNR
       AND  BLART  =  'CM'.

      IF  L_AUGBL+0(3)  NE  '114'.
        L_SUM_DMBTR  =  L_SUM_DMBTR  +  L_DMBTR.
        L_SUM_WRBTR  =  L_SUM_WRBTR  +  L_WRBTR.
      ENDIF.

      CLEAR : L_DMBTR, L_WRBTR, L_AUGBL.

    ENDSELECT.

    CLEAR L_BELNR.

  ENDSELECT.

  G_ITAB_T-K_YUSUK  =  G_ITAB_T-K_YUSUK  +  L_SUM_DMBTR.
  G_ITAB_T-YUSUK  =  G_ITAB_T-YUSUK  +  L_SUM_WRBTR.

ENDFORM.                    " yubo_sukum_rtn

*&---------------------------------------------------------------------*
*&      Form  call_detail_list
*&---------------------------------------------------------------------*
FORM CALL_DETAIL_LIST .

  DATA : L_CNT TYPE I.
  CLEAR : G_IT_T, G_IT_T[].

  LOOP AT G_ITEM_T WHERE BOX = 'X'.

    CLEAR  L_CNT.
** Data 유효성 Check
    SELECT  COUNT( * )
      INTO  L_CNT
      FROM  ZSD0017T
     WHERE  KNUMA  =  G_ITEM_T-KNUMA
       AND  FBUDA  =  G_ITEM_T-FBUDA
       AND  VBELN  =  G_ITEM_T-VBELN
       AND  BELNR  =  G_ITEM_T-BELNR
       AND  VBELN2 =  G_ITEM_T-VBELN2.

    IF  L_CNT  <=  0.
      MESSAGE E001 WITH '선택하신 Data를 확인하세요.'.
    ENDIF.

    G_IT_T-KNUMA  =  G_ITEM_T-KNUMA.
    G_IT_T-FBUDA  =  G_ITEM_T-FBUDA.
    G_IT_T-VBELN  =  G_ITEM_T-VBELN.
    G_IT_T-BELNR  =  G_ITEM_T-BELNR.
    G_IT_T-VBELN2  =  G_ITEM_T-VBELN2.
    G_IT_T-BUGA_BELNR  =  G_ITEM_T-BUGA_BELNR.
    G_IT_T-WRBTR  =  G_ITEM_T-WRBTR.
    G_IT_T-BUGA_AMNT  =  G_ITEM_T-BUGA_AMNT.

*   c_blight value '3',  " 부가세전표 생성완료
*   c_clight value '2',  " 지급전표 생성완료
*   c_flight value '1',  " 전표 생성 미완료

*    if  g_item_t-lights  =  c_flight..
*      g_it_t-gubun  =  '1'.
*    elseif  g_item_t-lights  =  c_clight..
*      g_it_t-gubun  =  '2'.
*    elseif  g_item_t-lights  =  c_blight..
*      g_it_t-gubun  =  '3'.
*    endif.

    APPEND  G_IT_T.
    CLEAR  G_IT_T.

  ENDLOOP.

*  export g_it_t to memory id 'ZSD0960'.
*  export p_mode to memory id 'ZSD0960_2'.
**** [START] AFTER MODIFIED FOR COMPANY CODE **********************
*  export pa_vkorg to memory id 'ZSD0960_3'.
**** [END] AFTER MODIFIED FOR COMPANY CODE **********************
*  submit zsdr0960_s and return.

ENDFORM.                    " call_detail_list

*&---------------------------------------------------------------------*
*&      Form  replace_process_rtn
*&---------------------------------------------------------------------*
FORM REPLACE_PROCESS_RTN .

  DATA : L_XLFZB LIKE LFB1-XLFZB.
  CLEAR : L_XLFZB.




*** [START] BEFORE MODIFIED FOR COMPANY CODE **********************
*   select  single xlfzb
*    into  l_xlfzb
*    from  lfb1
*   where  lifnr  =  g_item_t-bonem
*     and  bukrs  =  '1000'.
*** [END] BEFORE MODIFIED FOR COMPANY CODE **********************


*** [START] AFTER MODIFIED FOR COMPANY CODE **********************
  SELECT  SINGLE XLFZB
   INTO  L_XLFZB
   FROM  LFB1
  WHERE  LIFNR  =  G_ITEM_T-BONEM
    AND  BUKRS  =  PA_VKORG.
*** [END] AFTER MODIFIED FOR COMPANY CODE **********************


  CHECK L_XLFZB EQ 'X'.

*** [START] BEFORE MODIFIED FOR COMPANY CODE **********************
*  select  empfk
*    into  corresponding fields of table g_lfza_t
*    from  lfza
*   where  lifnr  =  g_item_t-bonem
*     and  bukrs  =  '1000'.
*** [END] BEFORE MODIFIED FOR COMPANY CODE **********************


*** [START] AFTER MODIFIED FOR COMPANY CODE **********************
  SELECT  EMPFK
    INTO  CORRESPONDING FIELDS OF TABLE G_LFZA_T
    FROM  LFZA
   WHERE  LIFNR  =  G_ITEM_T-BONEM
     AND  BUKRS  =  PA_VKORG.
*** [END] AFTER MODIFIED FOR COMPANY CODE **********************


  IF  NOT G_LFZA_T[] IS INITIAL.

    CALL SCREEN 3000 STARTING AT 15 7 ENDING AT 80 12.

    IF  SY-UCOMM  EQ  'ENTE'  AND
        G_H_EMPFK NE  SPACE.

    ENDIF.

  ENDIF.

ENDFORM.                    " replace_process_rtn

*&---------------------------------------------------------------------*
*&      Module  STATUS_3000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_3000 OUTPUT.

  SET PF-STATUS '3000'.
  SET TITLEBAR '3000'.

ENDMODULE.                 " STATUS_3000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_3000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_3000 INPUT.

  G_SYUCOMM =  SY-UCOMM.

  CASE  SY-UCOMM.

    WHEN  'ENTE'.
      LEAVE TO SCREEN 0.

    WHEN  'CANC'.
      G_H_EMPFK  =  SPACE.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_3000  INPUT

*&---------------------------------------------------------------------*
*&      Module  f4_empfk  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_EMPFK INPUT.

  PERFORM  F4_EMPFK_RTN.

ENDMODULE.                 " f4_empfk  INPUT

*&---------------------------------------------------------------------*
*&      Form  f4_empfk_rtn
*&---------------------------------------------------------------------*
FORM F4_EMPFK_RTN .

  DATA : L_SELECTFIELD  LIKE HELP_INFO-FIELDNAME,
         L_SELECT_VALUE LIKE HELP_INFO-FLDVALUE,
         L_FLD_TAB      LIKE HELP_VALUE OCCURS 1 WITH HEADER LINE,
         L_LD_TABIX     LIKE SY-TABIX,
         L_SCR_FIELDS   LIKE DYNPREAD OCCURS 0 WITH HEADER LINE,
         L_KTOKD        LIKE KNA1-KTOKD.
*-> CCM : 20.04.2023 16:19:16 / ZLSGSD4
*         l_kkber         like knkk-kkber.
*<-
  DATA : BEGIN OF IT_VALUE OCCURS 0,
           EMPFK LIKE  LFZA-EMPFK,
           NAME1 LIKE  LFA1-NAME1,
         END OF IT_VALUE.

*-> CCM : 20.04.2023 16:19:28 / ZLSGSD4
*  clear: l_selectfield, l_fld_tab, l_ld_tabix, l_ktokd, l_kkber.
  CLEAR: L_SELECTFIELD, L_FLD_TAB, L_LD_TABIX, L_KTOKD.
*<-
  REFRESH: L_FLD_TAB, IT_VALUE.

** Title 정의.
  MOVE: 'LFZA'      TO L_FLD_TAB-TABNAME,
        'EMPFK'     TO L_FLD_TAB-FIELDNAME,
        'X'         TO L_FLD_TAB-SELECTFLAG.
  APPEND L_FLD_TAB.

  MOVE: 'LFA1'      TO L_FLD_TAB-TABNAME,
        'NAME1'     TO L_FLD_TAB-FIELDNAME,
        ' '         TO L_FLD_TAB-SELECTFLAG.
  APPEND L_FLD_TAB.

  LOOP AT G_LFZA_T.

    IT_VALUE-EMPFK  =  G_LFZA_T-EMPFK.

    SELECT  SINGLE NAME1
      INTO  IT_VALUE-NAME1
      FROM  LFA1
     WHERE  LIFNR  =  G_LFZA_T-EMPFK.

    APPEND  IT_VALUE.
    CLEAR  IT_VALUE.

  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM IT_VALUE COMPARING EMPFK.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      SELECTFIELD                  = L_SELECTFIELD
    IMPORTING
      IND                          = L_LD_TABIX
      SELECT_VALUE                 = L_SELECT_VALUE
    TABLES
      FIELDS                       = L_FLD_TAB
      FULL_TABLE                   = IT_VALUE
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT L_LD_TABIX IS INITIAL.

  READ TABLE IT_VALUE INDEX L_LD_TABIX.
* 전달값 첫번째 값을 가져온다.
  G_H_EMPFK = L_SELECT_VALUE.

* 코드 선택해서 Text 보요줄떄 사용.
  L_SCR_FIELDS-FIELDNAME  = 'G_H_NAME1'.
  L_SCR_FIELDS-FIELDVALUE = IT_VALUE-NAME1.
  APPEND L_SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = L_SCR_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      UNDEFIND_ERROR       = 7
      OTHERS               = 8.

ENDFORM.                    " f4_empfk_rtn

*&---------------------------------------------------------------------*
*&      Module  data_check  INPUT
*&---------------------------------------------------------------------*
MODULE DATA_CHECK INPUT.

  CHECK NOT G_H_EMPFK IS INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = G_H_EMPFK
    IMPORTING
      OUTPUT = G_H_EMPFK.

  READ TABLE G_LFZA_T WITH KEY EMPFK  =  G_H_EMPFK.

  IF  SY-SUBRC  NE  0.
    MESSAGE E001 WITH '입력한 코드를 확인하세요.'.
  ENDIF.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = G_H_EMPFK
    IMPORTING
      OUTPUT = G_H_EMPFK.

ENDMODULE.                 " data_check  INPUT


*&---------------------------------------------------------------------*
*&      Form  decimal_point_compute
*&---------------------------------------------------------------------*
FORM DECIMAL_POINT_COMPUTE  USING    P_WAERK.

** TCURX-CURRKEY (통화키), TCURX-CURRDEC (소수 자릿수)

  GV_POINT = 1.

  CLEAR TCURX.

  SELECT  SINGLE CURRDEC
    FROM  TCURX
    INTO  TCURX-CURRDEC
   WHERE  CURRKEY EQ P_WAERK.

  IF  SY-SUBRC  NE  0.
    TCURX-CURRDEC  =  2.
  ENDIF.

  IF  TCURX-CURRDEC  =  2.
    GV_POINT  =  1  /  100.
  ELSEIF  TCURX-CURRDEC  =  3.
    GV_POINT  =  1  /  1000.
  ELSEIF  TCURX-CURRDEC  =  4.
    GV_POINT  =  1  /  10000.
  ELSEIF  TCURX-CURRDEC  =  5.
    GV_POINT  =  1  /  100000.
  ENDIF.

ENDFORM.                    " decimal_point_compute
*&---------------------------------------------------------------------*
*&      Form  replace_r_wrbtr_rtn
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REPLACE_R_WRBTR_RTN CHANGING GT_RETURN_CODE.

  CLEAR : G_P_NETWR3.

  G_P_NETWR3 =  G_P_NETWR1.

*  write : g_p_netwr1 to g_p_netwr3 currency g_item_t-waers.

  CALL SCREEN 4000 STARTING AT 15 7 ENDING AT 70 16.

  IF  G_SYUCOMM  =  'ENTE'.

    GT_RETURN_CODE = 'X'.

    IF G_P_NETWR3  >  G_P_NETWR1.

      MESSAGE E001 WITH '지급가능금액 이상은 조정할 수 없습니다.'.

    ELSE.

      G_ITEM_T-R_WRBTR = G_P_NETWR3.
      MODIFY G_ITEM_T.

    ENDIF.

  ELSE.

    GT_RETURN_CODE = 'Y'.

  ENDIF.


ENDFORM.                    " replace_r_wrbtr_rtn
*&---------------------------------------------------------------------*
*&      Form  read_amt_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_AMT_DATA .

  DATA: LL_DMBTR2      LIKE BSEG-DMBTR,
        LL_WRBTR2      LIKE BSEG-WRBTR,
        LL_BUGA_DMBTR2 LIKE BSEG-DMBTR,
        LL_BUGA_WRBTR2 LIKE BSEG-WRBTR.

  CLEAR:  LL_DMBTR2, LL_WRBTR2,
          LL_BUGA_DMBTR2, LL_BUGA_WRBTR2.

  LOOP AT G_ITEM_T.

*** 미지급 전표 금액 확인
*         if g_item_t-belnr is not initial.
*
*            select single DMBTR WRBTR PSWSL
*              into (
*              from bseg
*             where BUKRS = PA_VKORG
*               and BELNR = g_item_t-belnr
*               and GJAHR = g_item_t-fbuda+0(4)
*               and BSCHL = '40'
*               and HKONT in ('6430101', '6310317' )
*               and UMSKZ = ' '.

*         endif.

** 지급전표 금액 확인
    IF G_ITEM_T-BELNR2 IS NOT INITIAL.
*>> START - Archiving 관련변경 05 -> 20080312
      SELECT DMBTR WRBTR PSWSL
        INTO (LL_DMBTR2, LL_WRBTR2, G_ITEM_T-WAERK2)
       FROM BSEG
      WHERE BUKRS = PA_VKORG
        AND BELNR = G_ITEM_T-BELNR2
        AND GJAHR = G_ITEM_T-FBUDA2+0(4)
        AND BSCHL = '31'
        AND UMSKZ = ' '.

        G_ITEM_T-DMBTR2 = LL_DMBTR2 + G_ITEM_T-DMBTR2.
        G_ITEM_T-WRBTR3 = LL_WRBTR2 + G_ITEM_T-WRBTR3.

      ENDSELECT.
*-- 아카이브 체크를 한 경우에만 AS 테이블에서 정보를 가지고 온다.
      IF NOT P_ARCV IS INITIAL.
        SELECT DMBTR WRBTR PSWSL
          INTO (LL_DMBTR2, LL_WRBTR2, G_ITEM_T-WAERK2)
         FROM ZARIXFI1
        WHERE BUKRS = PA_VKORG
          AND BELNR = G_ITEM_T-BELNR2
          AND GJAHR = G_ITEM_T-FBUDA2+0(4)
          AND BSCHL = '31'
          AND UMSKZ = ' '.

          G_ITEM_T-DMBTR2 = LL_DMBTR2 + G_ITEM_T-DMBTR2.
          G_ITEM_T-WRBTR3 = LL_WRBTR2 + G_ITEM_T-WRBTR3.

          CLEAR : LL_DMBTR2, LL_WRBTR2.
        ENDSELECT.
      ENDIF.
*>> END   - Archiving 관련변경 05 -> 20080312
    ENDIF.

*** 미지급부가세전표 금액 확인
*         if g_item_t-buga_belnr is not initial.
*
*           select single DMBTR WRBTR PSWSL
*           into (g_item_t-dmbtr2,
*           from bseg
*          where BUKRS = PA_VKORG
*            and BELNR = g_item_t-buga_belnr
*            and GJAHR = g_item_t-fbuda+0(4)
*            and BSCHL = '40'
*            and HKONT = '1220101'
*            and UMSKZ = ' '
*
*         endif.
** 지급부가세전표 금액확인
    IF G_ITEM_T-BELNR2_BUGA IS NOT INITIAL.
*>> START - Archiving 관련변경 06 -> 20080312
      SELECT DMBTR WRBTR PSWSL
        INTO (LL_BUGA_DMBTR2, LL_BUGA_WRBTR2, G_ITEM_T-WAERK2_BUGA)
       FROM BSEG
      WHERE BUKRS = PA_VKORG
        AND BELNR = G_ITEM_T-BELNR2_BUGA
        AND GJAHR = G_ITEM_T-FBUDA2_BUGA+0(4)
        AND BSCHL = '31'
        AND UMSKZ = ' '.

        G_ITEM_T-DMBTR2_BUGA = LL_BUGA_DMBTR2 + G_ITEM_T-DMBTR2_BUGA.
        G_ITEM_T-WRBTR2_BUGA = LL_BUGA_WRBTR2 + G_ITEM_T-WRBTR2_BUGA.

      ENDSELECT.
*-- 아카이브 체크를 한 경우에만 AS 테이블에서 정보를 가지고 온다.
      IF NOT P_ARCV IS INITIAL.
        SELECT DMBTR WRBTR PSWSL
          INTO (LL_BUGA_DMBTR2, LL_BUGA_WRBTR2, G_ITEM_T-WAERK2_BUGA)
         FROM ZARIXFI1
        WHERE BUKRS = PA_VKORG
          AND BELNR = G_ITEM_T-BELNR2_BUGA
          AND GJAHR = G_ITEM_T-FBUDA2_BUGA+0(4)
          AND BSCHL = '31'
          AND UMSKZ = ' '.

          G_ITEM_T-DMBTR2_BUGA = LL_BUGA_DMBTR2 + G_ITEM_T-DMBTR2_BUGA.
          G_ITEM_T-WRBTR2_BUGA = LL_BUGA_WRBTR2 + G_ITEM_T-WRBTR2_BUGA.

          CLEAR : LL_BUGA_DMBTR2, LL_BUGA_WRBTR2.
        ENDSELECT.
      ENDIF.
*>> END   - Archiving 관련변경 06 -> 20080312
    ENDIF.

    MODIFY  G_ITEM_T.
    CLEAR : G_ITEM_T, LL_BUGA_DMBTR2, LL_BUGA_WRBTR2,
            LL_DMBTR2, LL_WRBTR2 .

  ENDLOOP.

ENDFORM.                    " read_amt_data
*&---------------------------------------------------------------------*
*&      Form  GET_WELS_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_WELS_DOC .

  DATA: LV_SABUN(12) TYPE C.
  DATA: LV_WELCD(10) TYPE C.
  DATA: LV_DOCNO TYPE ZDCNO.
  DATA: LV_RURL TYPE CHAR255.
  DATA: LS_0800T TYPE ZFIT0800.
  DATA: LV_CHKLN TYPE N.
  DATA: LV_ZLSPR TYPE BSIK-ZLSPR.

  CLEAR: LV_CHKLN, LV_SABUN, LV_WELCD,
         LV_DOCNO, LV_RURL,  LS_0800T.

  LOOP AT G_ITEM_T WHERE BOX = 'X'.
    LV_CHKLN = LV_CHKLN + 1.
  ENDLOOP.

  IF LV_CHKLN <> 1.
    MESSAGE E001 WITH '1건의 데이터를 선택해 주시기 바랍니다.'.
  ENDIF.

**--지급보류 해재 된 건인지 확인
  CLEAR: G_ITEM_T.
  READ TABLE G_ITEM_T WITH KEY  BOX = 'X'.

  SELECT SINGLE ZLSPR
       INTO LV_ZLSPR
     FROM BSIK
   WHERE BUKRS = G_ITEM_T-VKORG
       AND GJAHR = G_ITEM_T-FBUDA2+0(4)
       AND BELNR = G_ITEM_T-BELNR2
       AND SHKZG = 'H'.
  IF SY-SUBRC <> 0.
    MESSAGE E000 WITH '반제 처리된 항목입니다.'.
    EXIT.
  ELSEIF LV_ZLSPR NE 'C' AND LV_ZLSPR NE 'D'.
    MESSAGE E000 WITH '지급보류 해제가 처리 되었습니다.'.
    EXIT.
  ENDIF.

*-->(수정)양식코드 Mapping 로직 추가 필요
  LV_WELCD = '5A379DB'.
*<--END

*-->(수정) 사번 파라미터 부분 불필요
  CONCATENATE 'A005' LV_SABUN INTO LV_SABUN.
*<-- END

  CALL FUNCTION 'Z_FI_GET_WELS_DOC'
    EXPORTING
      BNAME2 = LV_SABUN
      WELCD  = LV_WELCD
*     FDATE  =
*     TDATE  =
    IMPORTING
      RDOCNO = LV_DOCNO
      RURL   = LV_RURL.

  IF LV_DOCNO IS NOT INITIAL.
* --1건만 체크 가능 하도록 앞에서 체크
    CLEAR: G_ITEM_T.
    READ TABLE G_ITEM_T WITH KEY BOX = 'X'.

    CLEAR: LS_0800T.
    LS_0800T-BUKRS  = PA_VKORG.
    LS_0800T-GJAHR  = G_ITEM_T-FBUDA2+0(4).
    LS_0800T-BELNR2 = G_ITEM_T-BELNR2.
    LS_0800T-DOCNO  = LV_DOCNO.
    LS_0800T-ZURL   = LV_RURL.
    LS_0800T-AEDAT  = SY-DATUM.
    LS_0800T-AEZET  = SY-TIMLO.
    LS_0800T-AENAM  = SY-UNAME.

    MODIFY ZFIT0800 FROM LS_0800T.
    IF SY-SUBRC = 0.
      COMMIT WORK.
      G_ITEM_T-DOCNO = LV_DOCNO.
      LOOP AT G_ITEM_T WHERE BOX EQ 'X'.
        G_ITEM_T-DOCNO = LV_DOCNO.
        MODIFY G_ITEM_T.
      ENDLOOP.
    ENDIF.

  ENDIF.
ENDFORM.                    " GET_WELS_DOC
*&---------------------------------------------------------------------*
*&      Form  SET_WELS_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_WELS_DOC .

  DATA: LT_0800T TYPE TABLE OF ZFIT0800 WITH HEADER LINE.

*--엠트론만 적용
  CHECK PA_VKORG = '3000'.

*--key 값인 회사코드/회계연도/전표번호로 Mapping
  CLEAR:LT_0800T, LT_0800T[].
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE LT_0800T
    FROM ZFIT0800
     FOR ALL ENTRIES IN G_ITEM_T
   WHERE BUKRS = G_ITEM_T-VKORG
     AND GJAHR = G_ITEM_T-FBUDA2+0(4)
     AND BELNR2 = G_ITEM_T-BELNR2.

  IF LT_0800T[] IS NOT INITIAL.

    LOOP AT G_ITEM_T.
      CLEAR: LT_0800T.
      READ TABLE LT_0800T WITH KEY BUKRS = G_ITEM_T-VKORG
                                   GJAHR = G_ITEM_T-FBUDA2+0(4)
                                   BELNR2 = G_ITEM_T-BELNR2.
      IF SY-SUBRC = 0.
        G_ITEM_T-DOCNO = LT_0800T-DOCNO.
        MODIFY G_ITEM_T.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " SET_WELS_DOC
*&---------------------------------------------------------------------*
*& Form SET_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_INIT .
  PA_VKORG = GC_VKORG_6000.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VTWEG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VTWEG  USING    PV_FNAME.
  DATA : LT_RETURN LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE,
         LT_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

  RANGES : LR_VKORG FOR VBAK-VKORG,
           LR_VTWEG FOR VBAK-VTWEG,
           LR_SPART FOR VBAK-SPART,
           LR_VKBUR FOR VBAK-VKBUR,
           LR_VKGRP FOR VBAK-VKGRP,
           LR_BONEM FOR ZKONA-BONEM.

*- SELECTION SCREEN 값 읽어오기
  LT_FIELDS-FIELDNAME = 'PA_VKORG'. "영업조직
  APPEND LT_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VKORG'.
  IF SY-SUBRC = 0.

    DATA(LV_VKORG) = LT_FIELDS-FIELDVALUE.
    TRANSLATE LV_VKORG TO UPPER CASE.
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LV_VKORG ) TO LR_VKORG.
  ENDIF.

  SELECT A~VKORG,A~VTWEG,B~VTEXT
    FROM TVKOV AS A INNER JOIN TVTWT AS B
                    ON A~VTWEG = B~VTWEG AND
                       B~SPRAS = @SY-LANGU
   WHERE A~VKORG IN @LR_VKORG
    INTO TABLE @DATA(LT_VALUE).
  SORT LT_VALUE BY VKORG VTWEG.
  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VTWEG'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_SPART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_SPART  USING    PV_FNAME.
  DATA : LT_RETURN LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE,
         LT_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

  RANGES : LR_VKORG FOR VBAK-VKORG,
           LR_VTWEG FOR VBAK-VTWEG,
           LR_SPART FOR VBAK-SPART,
           LR_VKBUR FOR VBAK-VKBUR,
           LR_VKGRP FOR VBAK-VKGRP,
           LR_BONEM FOR ZKONA-BONEM.

*- SELECTION SCREEN 값 읽어오기
  LT_FIELDS-FIELDNAME = 'PA_VKORG'. "영업조직
  APPEND LT_FIELDS.


  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VKORG'.
  IF SY-SUBRC = 0.

    DATA(LV_VKORG) = LT_FIELDS-FIELDVALUE.
    TRANSLATE LV_VKORG TO UPPER CASE.
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LV_VKORG ) TO LR_VKORG.
  ENDIF.

*  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VTWEG-LOW'.
*  IF SY-SUBRC = 0.
*    DATA(LV_VTWEG) = LT_FIELDS-FIELDVALUE.
*    TRANSLATE LV_VTWEG TO UPPER CASE.
*    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LV_VTWEG ) TO LR_VTWEG.
*  ENDIF.

  SELECT VKORG,VTWEG,SPART
    FROM TVTA
   WHERE VKORG IN @LR_VKORG
     AND VTWEG IN @LR_VTWEG
    INTO TABLE @DATA(LT_VALUE).

  SORT LT_VALUE BY VKORG VTWEG SPART.
  DELETE ADJACENT DUPLICATES FROM LT_VALUE COMPARING VKORG VTWEG SPART.

  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'SPART'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VKBUR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VKBUR  USING   PV_FNAME.
  DATA : LT_RETURN LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE,
         LT_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

  RANGES : LR_VKORG FOR VBAK-VKORG,
           LR_VTWEG FOR VBAK-VTWEG,
           LR_SPART FOR VBAK-SPART,
           LR_VKBUR FOR VBAK-VKBUR,
           LR_VKGRP FOR VBAK-VKGRP,
           LR_BONEM FOR ZKONA-BONEM.

*- SELECTION SCREEN 값 읽어오기
  LT_FIELDS-FIELDNAME = 'PA_VKORG'. "영업조직
  APPEND LT_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VKORG'.
  IF SY-SUBRC = 0.

    DATA(LV_VKORG) = LT_FIELDS-FIELDVALUE.
    TRANSLATE LV_VKORG TO UPPER CASE.
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LV_VKORG ) TO LR_VKORG.
  ENDIF.


  SELECT DISTINCT A~VKBUR,B~BEZEI
    FROM TVKBZ AS A INNER JOIN TVKBT AS B
                    ON A~VKBUR = B~VKBUR

   WHERE A~VKORG IN @LR_VKORG
    INTO TABLE @DATA(LT_VALUE).
  SORT LT_VALUE BY VKBUR.
  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VKBUR'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VKGRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VKGRP  USING    PV_FNAME.
  DATA : LT_RETURN LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE,
         LT_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

  RANGES : LR_VKORG FOR VBAK-VKORG,
           LR_VTWEG FOR VBAK-VTWEG,
           LR_SPART FOR VBAK-SPART,
           LR_VKBUR FOR VBAK-VKBUR,
           LR_VKGRP FOR VBAK-VKGRP,
           LR_BONEM FOR ZKONA-BONEM.

*- SELECTION SCREEN 값 읽어오기
  LT_FIELDS-FIELDNAME = 'PA_VKORG'. "영업조직
  APPEND LT_FIELDS.
*  LT_FIELDS-FIELDNAME = 'PA_VKBUR'. "사업장
*  APPEND LT_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VKORG'.
  IF SY-SUBRC = 0.

    DATA(LV_VKORG) = LT_FIELDS-FIELDVALUE.
    TRANSLATE LV_VKORG TO UPPER CASE.
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LV_VKORG ) TO LR_VKORG.
  ENDIF.

*  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VKBUR'.
*  IF SY-SUBRC = 0.
*    DATA(LV_VKBUR) = LT_FIELDS-FIELDVALUE.
*    TRANSLATE LV_VKBUR TO UPPER CASE.
*    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LV_VKBUR ) TO LR_VKBUR.
*  ENDIF.

  SELECT DISTINCT A~VKBUR,B~BEZEI,A~VKGRP,C~BEZEI AS VKGRP_TXT
    FROM TVKBZ AS H INNER JOIN TVBVK AS A
                    ON H~VKBUR = A~VKBUR
                    INNER JOIN TVKBT AS B
                    ON A~VKBUR = B~VKBUR AND
                       B~SPRAS = @SY-LANGU
                    INNER JOIN TVGRT AS C
                    ON A~VKGRP = C~VKGRP AND
                       C~SPRAS = @SY-LANGU
   WHERE H~VKORG IN @LR_VKORG
     AND A~VKBUR IN @LR_VKBUR
    INTO TABLE @DATA(LT_VALUE).

  SORT LT_VALUE BY VKBUR.

  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VKGRP'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MONTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MONTH .
  DATA : LV_MONTH  TYPE I,
         LV_MONTH2 TYPE I,
         LV_COUNT  TYPE I,
         LV_MONTH3 TYPE N LENGTH 2,
         LV_SPMON  LIKE ZSDS004-FBUDA.

  CLEAR : RS_SPMON, RS_SPMON[].

  C_BUKRS  = PA_VKORG.
  LV_YEAR  = PA_SPMON+0(4).
  LV_MONTH = PA_SPMON+4(2).
  LV_COUNT = LV_MONTH.

  DO  LV_COUNT TIMES.

    IF SY-INDEX EQ 1.
      LV_MONTH2 = LV_MONTH.
      LV_MONTH3 = LV_MONTH2.
      CONCATENATE PA_SPMON(4) LV_MONTH3 INTO LV_SPMON.
    ELSE.
      LV_MONTH2 = LV_MONTH - 1.
      LV_MONTH3 = LV_MONTH2.
      CONCATENATE PA_SPMON(4) LV_MONTH3 INTO LV_SPMON.
    ENDIF.
    RS_SPMON-SIGN   = 'I'.
    RS_SPMON-OPTION = 'EQ'.
    RS_SPMON-LOW    = LV_SPMON.
    APPEND RS_SPMON.
    CLEAR RS_SPMON.

    LV_MONTH = LV_MONTH2.

  ENDDO.

ENDFORM.
