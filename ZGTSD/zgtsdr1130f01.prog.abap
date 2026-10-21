*&---------------------------------------------------------------------*
*&  Include           ZSDR1001F                                        *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  STATUS
*&---------------------------------------------------------------------*

FORM STATUS USING   RT_EXTAB  TYPE  SLIS_T_EXTAB.

  DATA: LS_EXTAB TYPE SLIS_EXTAB.

  REFRESH: RT_EXTAB.
*  LS_EXTAB = '&UMC'.
*  APPEND LS_EXTAB TO RT_EXTAB.
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

  CLEAR : G_UCOMM.

  DATA : P_UCOMM LIKE SY-UCOMM.

  READ TABLE GT_HEADER INDEX RS_SELFIELD-TABINDEX.

  G_UCOMM  =  RS_UCOMM.

  CASE RS_UCOMM.
    WHEN 'FB60'.         " 미지급 전표 생성
      REFRESH GT_BDCMSG.
*      PERFORM EXECUTE_FB60_BDC.
      PERFORM EXECUTE_FB60_BDC_HANA.
      PERFORM INTIALIZATION_DATA.
      PERFORM READ_DATA_PROCESS.
      PERFORM MODIFY_DATA_PROCESS.

      RS_SELFIELD-REFRESH = 'X'.
    WHEN 'FB08' OR       " 역분개 전표 생성
         'BUGA_C'.       " 부가세 전표취소

      REFRESH GT_BDCMSG.
      IF  RS_UCOMM  =  'FB08'.
        PERFORM EXECUTE_FB08_BDC.
      ELSEIF  RS_UCOMM  =  'BUGA_C'.
        PERFORM EXECUTE_FB08_BDC2.
      ENDIF.
      PERFORM INTIALIZATION_DATA.
      PERFORM READ_DATA_PROCESS.
      PERFORM MODIFY_DATA_PROCESS.
      RS_SELFIELD-REFRESH = 'X'.

*{ ZLSGSD4 - ZSDR1005에 정산오더 삭제 기능 구현으로 유저커맨드 삭제
* 필요시VA02-휴지통모양으로 재생성(재구현시ZSD0018T삭제로직추가해야함)
    WHEN 'VA02'.
      REFRESH GT_BDCMSG.
      PERFORM EXECUTE_VA02_BDC.
      PERFORM INTIALIZATION_DATA.
      PERFORM READ_DATA_PROCESS.
      PERFORM MODIFY_DATA_PROCESS.
      RS_SELFIELD-REFRESH = 'X'.

    WHEN 'BUGA'  OR      " 매입부가세 전표생성
         'ZSUM'.         " 합계금액
      IF  RS_UCOMM  =  'BUGA'.
        PERFORM EXECUTE_BUGA_BDC.
      ELSEIF  RS_UCOMM  =  'ZSUM'.
        PERFORM EXECUTE_BUGA_SUM.
      ENDIF.
      PERFORM INTIALIZATION_DATA.
      PERFORM READ_DATA_PROCESS.
      PERFORM MODIFY_DATA_PROCESS.
      RS_SELFIELD-REFRESH = 'X'.

    WHEN '&IC1'.
      PERFORM DETAIL_CLICK USING RS_SELFIELD-TABINDEX
                                  RS_SELFIELD-FIELDNAME
                                  RS_SELFIELD-VALUE.

    WHEN 'ZSEL' .        " 미지급전표상세조회
      PERFORM CALL_DETAIL_LIST.
      PERFORM INTIALIZATION_DATA.
      PERFORM READ_DATA_PROCESS.
      PERFORM MODIFY_DATA_PROCESS.
  ENDCASE.

ENDFORM.                    " USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  DETAIL_CLICK
*&---------------------------------------------------------------------*
FORM DETAIL_CLICK USING    P_TABINDEX P_FLDNAME P_VALUE.

  DATA : LV_ANLN2 LIKE ANLA-ANLN2 VALUE '0000',
         LV_BUKRS LIKE ANLA-BUKRS VALUE 'DSF'.

  CASE P_FLDNAME.
    WHEN 'BONEM'.
      READ TABLE GT_HEADER INDEX P_TABINDEX.
      IF GT_HEADER-BONEM IS NOT INITIAL.

        CALL FUNCTION 'Z_BP_DISPLAY_S4H'
          EXPORTING
            I_LIFNR = GT_HEADER-BONEM
            I_GUBUN = 'D'
            I_TCODE = 'XD03'.
      ENDIF.

    WHEN 'KUNNR'.
      READ TABLE GT_HEADER INDEX P_TABINDEX.

      IF GT_HEADER-KUNNR IS NOT INITIAL.
        CALL FUNCTION 'Z_BP_DISPLAY_S4H'
          EXPORTING
            I_LIFNR = GT_HEADER-KUNNR
            I_GUBUN = 'D'
            I_TCODE = 'XD03'.
      ENDIF.

    WHEN 'KNUMA'.

      READ TABLE GT_HEADER INDEX P_TABINDEX.
      IF GT_HEADER-KNUMA IS NOT INITIAL.
        SET PARAMETER ID 'REQ' FIELD GT_HEADER-KNUMA.
        CALL TRANSACTION 'ZGTSDR1103' WITH AUTHORITY-CHECK
             AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'VBELN'.
      READ TABLE GT_HEADER INDEX P_TABINDEX.
      IF GT_HEADER-VBELN IS NOT INITIAL.
        SET PARAMETER ID 'AUN' FIELD GT_HEADER-VBELN.
        CALL TRANSACTION 'VA03' WITH AUTHORITY-CHECK
             AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'BELNR'.
      READ TABLE GT_HEADER INDEX P_TABINDEX.
      IF GT_HEADER-BELNR IS NOT INITIAL.
        SET PARAMETER ID 'BLN' FIELD GT_HEADER-BELNR.
        SET PARAMETER ID 'BUK' FIELD GT_HEADER-BUKRS.
        SET PARAMETER ID 'GJR' FIELD P_SPMON(4).
        CALL TRANSACTION 'FB03' WITH AUTHORITY-CHECK
             AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'AUGBL'.
      READ TABLE GT_HEADER INDEX P_TABINDEX.
      IF GT_HEADER-AUGBL IS NOT INITIAL.
        SET PARAMETER ID 'BLN' FIELD GT_HEADER-AUGBL.
        SET PARAMETER ID 'BUK' FIELD GT_HEADER-BUKRS.
        SET PARAMETER ID 'GJR' FIELD P_SPMON(4).
        CALL TRANSACTION 'FB03' WITH AUTHORITY-CHECK
             AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'VBELN2'.
      READ TABLE GT_ITEM INDEX P_TABINDEX.
      IF GT_ITEM-VBELN2 IS NOT INITIAL.
        SET PARAMETER ID 'VF' FIELD GT_ITEM-VBELN2.
        CALL TRANSACTION 'VF03' WITH AUTHORITY-CHECK
             AND SKIP FIRST SCREEN.
      ENDIF.
  ENDCASE.

ENDFORM.                    " DETAIL_CLICK

*---------------------------------------------------------------------*
*       FORM E01_FIELDCAT_HEADER                                      *
*---------------------------------------------------------------------*
FORM E01_FIELDCAT_HEADER USING E01_LT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.

  DATA: LS_FIELDCAT TYPE SLIS_FIELDCAT_ALV.

  G_REPID = SY-REPID.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = G_REPID
      I_INTERNAL_TABNAME = G_TABNAME_HEADER
      I_STRUCTURE_NAME   = 'ZSDS002'
    CHANGING
      CT_FIELDCAT        = E01_LT_FIELDCAT[].

  LOOP AT E01_LT_FIELDCAT INTO LS_FIELDCAT.
    CHECK LS_FIELDCAT-TABNAME = G_TABNAME_HEADER.
    CASE LS_FIELDCAT-FIELDNAME.
      WHEN 'KNUMA'.
        LS_FIELDCAT-EMPHASIZE  = 'X'.
        LS_FIELDCAT-HOTSPOT    = 'X'.
        LS_FIELDCAT-SELTEXT_L  = '계약No'.
        LS_FIELDCAT-SELTEXT_M  = '계약No'.
        LS_FIELDCAT-SELTEXT_S  = '계약No'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_HEADER.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'BOTEXT'.
        LS_FIELDCAT-SELTEXT_L  = '계약명'.
        LS_FIELDCAT-SELTEXT_M  = '계약명'.
        LS_FIELDCAT-SELTEXT_S  = '계약명'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_HEADER.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'BONEM'.
        LS_FIELDCAT-HOTSPOT    = 'X'.
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
      WHEN 'KUNNR'.
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
      WHEN 'FBUDA'.
        LS_FIELDCAT-SELTEXT_L  = '정산월'.
        LS_FIELDCAT-SELTEXT_M  = '정산월'.
        LS_FIELDCAT-SELTEXT_S  = '정산월'.
        LS_FIELDCAT-NO_OUT  = 'X'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_HEADER.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'VBELN'.
        LS_FIELDCAT-EMPHASIZE  = 'X'.
        LS_FIELDCAT-HOTSPOT    = 'X'.
        LS_FIELDCAT-SELTEXT_L  = '정산오더'.
        LS_FIELDCAT-SELTEXT_M  = '정산오더'.
        LS_FIELDCAT-SELTEXT_S  = '정산오더'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_HEADER.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'KWERT'.
        LS_FIELDCAT-SELTEXT_L  = '발생액'.
        LS_FIELDCAT-SELTEXT_M  = '발생액'.
        LS_FIELDCAT-SELTEXT_S  = '발생액'.
        LS_FIELDCAT-REPTEXT_DDIC = '발생액'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_HEADER.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'NETWR'.
*        LS_FIELDCAT-DO_SUM     = 'X'.
        LS_FIELDCAT-SELTEXT_L  = '오더금액'.
        LS_FIELDCAT-SELTEXT_M  = '오더금액'.
        LS_FIELDCAT-SELTEXT_S  = '오더금액'.
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
      WHEN 'AUGBL'.
        LS_FIELDCAT-EMPHASIZE  = 'X'.
        LS_FIELDCAT-HOTSPOT    = 'X'.
        LS_FIELDCAT-NO_OUT     = 'X'.
        LS_FIELDCAT-SELTEXT_L  = '지급Clear여부'.
        LS_FIELDCAT-SELTEXT_M  = '지급Clear여부'.
        LS_FIELDCAT-SELTEXT_S  = '지급Clear여부'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_HEADER.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'BUGA_BELNR'.
        LS_FIELDCAT-EMPHASIZE  = 'X'.
        LS_FIELDCAT-HOTSPOT    = 'X'.
        LS_FIELDCAT-SELTEXT_L  = '부가세전표'.
        LS_FIELDCAT-SELTEXT_M  = '부가세전표'.
        LS_FIELDCAT-SELTEXT_S  = '부가세전표'.
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

*      BONEM LIKE KONA-BONEM,  " AGENT
*      NAME  LIKE KNA1-NAME1,  " AGENT 명
*      KUNNR LIKE KNA1-KUNNR,  " 고객
*      NAME1 LIKE KNA1-NAME1,  " 고객명
*      VBELN LIKE VBAK-VBELN,  " 정산오더번호
*      WRBTR LIKE BSEG-WRBTR,  " 미지급금액
*      PSWSL LIKE BSEG-PSWSL,  " 통화단위
*      AUGBL LIKE BSEG-AUGBL.  " 반제전표번호

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = G_REPID
      I_INTERNAL_TABNAME = G_TABNAME_ITEM
      I_STRUCTURE_NAME   = 'ZSDS003'
    CHANGING
      CT_FIELDCAT        = E01_LT_FIELDCAT[].

  LOOP AT E01_LT_FIELDCAT INTO LS_FIELDCAT.
    CHECK LS_FIELDCAT-TABNAME = G_TABNAME_ITEM.
    CASE LS_FIELDCAT-FIELDNAME.
      WHEN 'KNUMA'.
        LS_FIELDCAT-NO_OUT    = 'X'.
        LS_FIELDCAT-SELTEXT_L  = '계약No'.
        LS_FIELDCAT-SELTEXT_M  = '계약No'.
        LS_FIELDCAT-SELTEXT_S  = '계약No'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'VBELN2'.
        LS_FIELDCAT-EMPHASIZE  = 'X'.
        LS_FIELDCAT-HOTSPOT    = 'X'.
        LS_FIELDCAT-SELTEXT_L  = '대금청구NO'.
        LS_FIELDCAT-SELTEXT_M  = '대금청구NO'.
        LS_FIELDCAT-SELTEXT_S  = '대금청구NO'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'INCO1'.
        LS_FIELDCAT-SELTEXT_L  = 'Incoterms'.
        LS_FIELDCAT-SELTEXT_M  = 'Incoterms'.
        LS_FIELDCAT-SELTEXT_S  = 'Incoterms'.
        LS_FIELDCAT-REPTEXT_DDIC = 'Incoterms'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'ZTERM'.
        LS_FIELDCAT-SELTEXT_L  = '수금조건'.
        LS_FIELDCAT-SELTEXT_M  = '수금조건'.
        LS_FIELDCAT-SELTEXT_S  = '수금조건'.
        LS_FIELDCAT-REPTEXT_DDIC = '수금조건'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'KURRF'.
        LS_FIELDCAT-SELTEXT_L  = '환율'.
        LS_FIELDCAT-SELTEXT_M  = '환율'.
        LS_FIELDCAT-SELTEXT_S  = '환율'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'NETWR'.
*        LS_FIELDCAT-DO_SUM     = 'X'.
        LS_FIELDCAT-SELTEXT_L  = '매출액'.
        LS_FIELDCAT-SELTEXT_M  = '매출액'.
        LS_FIELDCAT-SELTEXT_S  = '매출액'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'KWERT_K'.
        LS_FIELDCAT-SELTEXT_L  = '커미션발생액'.
        LS_FIELDCAT-SELTEXT_M  = '커미션발생액'.
        LS_FIELDCAT-SELTEXT_S  = '커미션발생액'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'KSTBS'.
        LS_FIELDCAT-NO_OUT     = 'X'.
        LS_FIELDCAT-SELTEXT_L  = 'FOB액'.
        LS_FIELDCAT-SELTEXT_M  = 'FOB액'.
        LS_FIELDCAT-SELTEXT_S  = 'FOB액'.
        LS_FIELDCAT-REPTEXT_DDIC = 'FOB액'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'BUGA_AMNT'.
*        ls_fieldcat-currency   = 'KRW'.
        LS_FIELDCAT-SELTEXT_L  = '부가세액'.
        LS_FIELDCAT-SELTEXT_M  = '부가세액'.
        LS_FIELDCAT-SELTEXT_S  = '부가세액'.
        LS_FIELDCAT-REPTEXT_DDIC = '부가세액'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        LS_FIELDCAT-CURRENCY  = 'KRW'.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.

      WHEN 'ARKTX'.
        LS_FIELDCAT-SELTEXT_L  = '자재명'.
        LS_FIELDCAT-SELTEXT_M  = '자재명'.
        LS_FIELDCAT-SELTEXT_S  = '자재명'.
        LS_FIELDCAT-REPTEXT_DDIC = '자재명'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'KBETR'.
*        LS_FIELDCAT-EMPHASIZE  = 'X'.
*        LS_FIELDCAT-HOTSPOT    = 'X'.
        LS_FIELDCAT-SELTEXT_L  = '커미션조건'.
        LS_FIELDCAT-SELTEXT_M  = '커미션조건'.
        LS_FIELDCAT-SELTEXT_S  = '커미션조건'.
        LS_FIELDCAT-TABNAME   = G_TABNAME_ITEM.
        MODIFY E01_LT_FIELDCAT FROM LS_FIELDCAT.
      WHEN 'KWAEH'.
        LS_FIELDCAT-SELTEXT_L  = '단위'.
        LS_FIELDCAT-SELTEXT_M  = '단위'.
        LS_FIELDCAT-SELTEXT_S  = '단위'.
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
  LS_LINE-INFO = TEXT-002.
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

  E05_LS_LAYOUT-LIGHTS_FIELDNAME  = P_LIGNAM.
  E05_LS_LAYOUT-LIGHTS_TABNAME    = G_TABNAME_HEADER.
*  E05_LS_LAYOUT-LIGHTS_CONDENSE   = P_LIGHTC.
  E05_LS_LAYOUT-BOX_FIELDNAME     = G_BOXNAM.
  E05_LS_LAYOUT-BOX_TABNAME       = G_TABNAME_HEADER.
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
FORM DATA_WRITE_PROCESS .

  G_TABNAME_HEADER = 'GT_HEADER'.
  G_TABNAME_ITEM   = 'GT_ITEM'.
* define keyinfo
  CLEAR GS_KEYINFO.
  GS_KEYINFO-HEADER01 = 'KNUMA'.
  GS_KEYINFO-ITEM01   = 'KNUMA'.
  GS_KEYINFO-HEADER02 = 'FBUDA'.
  GS_KEYINFO-ITEM02   = 'FBUDA'.
*->2023.07.18 ZITCS4HDEV01 - 추가
  GS_KEYINFO-HEADER03 = 'KUNNR'.
  GS_KEYINFO-ITEM03   = 'KUNNR'.
*<-
*->[CHG]-------------------------S 2026.02.04
  GS_KEYINFO-HEADER04 = 'VBELN'.
  GS_KEYINFO-ITEM04   = 'VBELN_SE'.
*-<[CHG]-------------------------E 2026.02.04

  PERFORM E01_FIELDCAT_HEADER  USING GT_FIELDCAT[].
  PERFORM E01_FIELDCAT_ITEM    USING GT_FIELDCAT[].
  PERFORM E03_EVENTTAB_BUILD   USING GT_EVENTS[].
  PERFORM E04_COMMENT_BUILD    USING GT_LIST_TOP_OF_PAGE[].
  PERFORM E07_SP_GROUP_BUILD   USING GT_SP_GROUP[].
  PERFORM E05_LAYOUT_BUILD     USING GS_LAYOUT.     "wg. Parameters
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
      T_OUTTAB_HEADER          = GT_HEADER
      T_OUTTAB_ITEM            = GT_ITEM.

ENDFORM.                    " DATA_WRITE_PROCESS

*&---------------------------------------------------------------------*
*&      Form  READ_DATA_PROCESS
*&---------------------------------------------------------------------*
FORM READ_DATA_PROCESS .

  PERFORM READ_KNUMA_DATA.   " 윤방희 추가: 대상 데이타
*  PERFORM READ_MAIN_DATA.      "2023.07.07 ZITCS4HDEV01 - 주석
  PERFORM READ_MAIN_DATA_HANA. "2023.07.07 ZITCS4HDEV01 - 추가
* perform read_vmvaf_data.   " 리베이트 계약과 주문번호 연결 테이블
  PERFORM READ_VBAK_DATA.    " 정산 오더의 금액
  PERFORM READ_BKPF_DATA.    " 미지급 전표
  PERFORM READ_BSEG_DATA.    " 미지급 금액
* perform read_vbox_data.
  PERFORM READ_VBRK_DATA.    " Billing Header
  PERFORM READ_VBRP_DATA.    " BILLING ITEM
* perform read_vbuk_data.    " 대금청구문서 상태

ENDFORM.                    " READ_DATA_PROCESS

*&---------------------------------------------------------------------*
*&      Form  READ_VBOX_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_VBOX_DATA .

  IF NOT GT_OUTAB[] IS INITIAL.
*-> CCM : 20.04.2023 15:30:23 / ZLSGSD4
*    CLEAR : GT_VBOX, GT_VBOX[].
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_VBOX
*              FROM VBOX
*              FOR ALL ENTRIES IN GT_OUTAB
*                WHERE KAPPL    = GT_OUTAB-KAPPL
*                  AND KOTABNR  = GT_OUTAB-KOTABNR
*                  AND VAKEY    = GT_OUTAB-VAKEY.
*<-
  ENDIF.

ENDFORM.                    " READ_VBOX_DATA

*&---------------------------------------------------------------------*
*&      Form  READ_VBRK_DATA
*&---------------------------------------------------------------------*
FORM READ_VBRK_DATA .

* 취소 FLAG 가 없거나 취소 문서가 존재 하지 않음.
  IF NOT GT_OUTAB[] IS INITIAL.
    CLEAR : GT_VBRK, GT_VBRK[].
    SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_VBRK
      FROM VBRK
       FOR ALL ENTRIES IN GT_OUTAB
     WHERE VBELN = GT_OUTAB-VBELN2
       AND FKSTO NE C_FKSTO
       AND SFAKN EQ C_SFAKN
       AND FKDAT IN S_FKDAT
       AND RFBSK EQ 'C'.     "윤방희수정:회계전기된것만

*-> MIG Table 추가 : 2023.08.21
    DATA: LS_VBRK LIKE LINE OF GT_VBRK,
          LT_VBRK LIKE STANDARD TABLE OF LS_VBRK.

    SELECT *
      FROM ZVBRK_R3
       FOR ALL ENTRIES IN @GT_OUTAB
     WHERE VBELN EQ @GT_OUTAB-VBELN2
       AND FKSTO NE @C_FKSTO
       AND SFAKN EQ @C_SFAKN
       AND FKDAT IN @S_FKDAT
       AND RFBSK EQ 'C'
      INTO TABLE @DATA(LT_ZVBRK_R3).
    IF SY-SUBRC EQ 0.
      SORT GT_VBRK BY VBELN.
      LOOP AT LT_ZVBRK_R3 ASSIGNING FIELD-SYMBOL(<LS_ZVBRK_R3>).
        READ TABLE GT_VBRK WITH KEY VBELN = <LS_ZVBRK_R3>-VBELN BINARY SEARCH TRANSPORTING NO FIELDS.
        IF SY-SUBRC NE 0.
          CLEAR LS_VBRK.
          MOVE-CORRESPONDING <LS_ZVBRK_R3> TO LS_VBRK.
          APPEND LS_VBRK TO LT_VBRK.
        ENDIF.
      ENDLOOP.
      IF LT_VBRK[] IS NOT INITIAL.
        APPEND LINES OF LT_VBRK[] TO GT_VBRK[].
      ENDIF.
    ENDIF.
*<-
  ENDIF.

ENDFORM.                    " READ_VBRK_DATA

*&---------------------------------------------------------------------*
*&      Form  READ_VMVAF_DATA
*&---------------------------------------------------------------------*
FORM READ_VMVAF_DATA .

  RANGES : LR_KNUMA FOR KONA-KNUMA.
  CLEAR : LR_KNUMA, LR_KNUMA[].
  LOOP AT GT_OUTAB.
    LR_KNUMA-SIGN   = 'I'.
    LR_KNUMA-OPTION = 'EQ'.
    LR_KNUMA-LOW    = GT_OUTAB-KNUMA.
    APPEND LR_KNUMA.  CLEAR LR_KNUMA.
  ENDLOOP.

  CLEAR : GT_VMVAF, GT_VMVAF[].
  SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_VMVAF
           FROM V_VMVAF
           WHERE KNUMA IN LR_KNUMA.

ENDFORM.                    " READ_VMVAF_DATA

*&---------------------------------------------------------------------*
*&      Form  MODIFY_DATA_PROCESS
*&---------------------------------------------------------------------*
FORM MODIFY_DATA_PROCESS .

  DATA : LV_AUGRU LIKE VBAK-AUGRU,
         LV_FBUDA LIKE VBKD-FBUDA,
         LV_BELNR LIKE VBAK-VBELN,
         LV_ZDESI LIKE ZLET0201-ZDESI.

  DATA : LT_ZSD0018T TYPE TABLE OF ZSD0018T.

  SORT : GT_VMVAF ASCENDING BY KNUMA,
         GT_VBAK ASCENDING BY VBELN,
         GT_BKPF ASCENDING BY XBLNR,
         GT_BSEG ASCENDING BY BELNR,
         GT_VBRK ASCENDING BY VBELN.

*-> CCM : 20.04.2023 15:54:47 / ZLSGSD4
*         GT_VBUK ASCENDING BY VBELN
*<-
  CLEAR : GT_TOTAL, GT_TOTAL[].

  IF S_VKORG-LOW = '1000'.

    C_BUPLA = '110'.

  ENDIF.

  IF S_VKORG-LOW = '2000'.
    C_BUPLA = '220'.
  ENDIF.

  C_BUKRS = S_VKORG-LOW.

**->[CHG]-------------------------S 2026.02.04
*  DATA(LT_TEMP) = GT_OUTABH[].
*  SORT LT_TEMP BY VBELN2.
*  IF LT_TEMP[] IS NOT INITIAL.
*    SELECT *
*      FROM ZSD0018T
*       FOR ALL ENTRIES IN @LT_TEMP
*     WHERE VBELN EQ @LT_TEMP-VBELN2
*      INTO CORRESPONDING FIELDS OF TABLE @LT_ZSD0018T.
*  ENDIF.
**-<[CHG]-------------------------E 2026.02.04

  LOOP AT GT_OUTABH.

    CLEAR : GT_VMVAF, GT_VBAK, GT_BKPF, GT_BSEG.
    LOOP AT GT_VMVAF WHERE KNUMA = GT_OUTABH-KNUMA.

      CLEAR:GT_VBAK.
      READ TABLE GT_VBAK WITH KEY VBELN = GT_VMVAF-VBELN
                        BINARY SEARCH.
      IF SY-SUBRC EQ 0.
* 전표 생성후 해당 정산 오더의 거절 사유에 'B31' 로 되어있음.
* 전표 재생성 할수 없음. 완료 처리함.
        CLEAR : LV_AUGRU.
        SELECT SINGLE AUGRU INTO LV_AUGRU
               FROM VBAK WHERE VBELN = GT_VBAK-VBELN.
*-> MIG Table 추가
        IF SY-SUBRC NE 0.
          SELECT SINGLE AUGRU INTO LV_AUGRU
            FROM ZVBAK_R3 WHERE VBELN = GT_VBAK-VBELN.
        ENDIF.

        IF LV_AUGRU EQ 'B31'.
          GT_HEADER-LIGHTS = C_CLIGHT.
        ELSE.
          GT_HEADER-LIGHTS = C_FLIGHT.
        ENDIF.

* 정산월 가져옴.
        CLEAR SPMON_ITAB.
        READ TABLE SPMON_ITAB WITH KEY VBELN = GT_VBAK-VBELN.
        GT_HEADER-FBUDA = SPMON_ITAB-FBUDA.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = GT_VBAK-BSTNK
          IMPORTING
            OUTPUT = LV_BELNR.

        CLEAR:GT_BSEG.
        READ TABLE GT_BSEG WITH KEY BELNR = LV_BELNR
                                    BINARY SEARCH.

      ELSE.
        GT_HEADER-LIGHTS = C_FLIGHT.
      ENDIF.

* 발생액 : Billing 커미션 발생 금액 합계.
      IF  GT_HEADER-FBUDA EQ P_SPMON.

*->[CHG]-------------------------S
        IF S_VKORG-LOW = '3000' OR
           S_VKORG-LOW = '6000'.
*        IF S_VKORG-LOW = '3000'.
*-<[CHG]-------------------------E
          SELECT SINGLE W~J_1BBRANCH
            INTO (GT_HEADER-BUPLA)
            FROM T001W AS W
            JOIN VBAP AS P
              ON W~WERKS = P~WERKS
           WHERE P~VBELN = GT_VBAK-VBELN.
*-> MIG Table 추가 : 2023.08.21
          IF SY-SUBRC NE 0.
            SELECT SINGLE W~J_1BBRANCH
             INTO (GT_HEADER-BUPLA)
             FROM T001W AS W
             JOIN ZVBAP_R3 AS P
               ON W~WERKS = P~WERKS
            WHERE P~VBELN = GT_VBAK-VBELN.
          ENDIF.
*<-

        ENDIF.


        MOVE-CORRESPONDING : GT_OUTABH TO GT_HEADER,
                             GT_VBAK   TO GT_HEADER,
                             GT_BKPF   TO GT_HEADER,
                             GT_BSEG   TO GT_HEADER.
        GT_HEADER-WAERK = GT_OUTABH-WAERS.
        APPEND GT_HEADER. CLEAR GT_HEADER.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  SORT GT_OUTABI.
  DELETE ADJACENT DUPLICATES FROM GT_OUTABI.

*  BREAK SDC09.
* 커미션 ITEM 데이터
  LOOP AT GT_OUTABI.

    IF GT_OUTABI-KONWA IS INITIAL.
      GT_OUTABI-KONWA = '%'.

      GT_OUTABI-KBETR = GT_OUTABI-KBETR / -10.
    ELSE.
      GT_OUTABI-KBETR = GT_OUTABI-KBETR * -1.
    ENDIF.


    CLEAR : GT_VBRK.

    READ TABLE GT_VBRK WITH KEY VBELN = GT_OUTABI-VBELN2
                       BINARY SEARCH.
**->[CHG]-------------------------S 2026.02.04
*    CHECK SY-SUBRC EQ 0.
**-<[CHG]-------------------------E 2026.02.04
    LOOP AT GT_VBRP WHERE VBELN = GT_OUTABI-VBELN2
                     AND  POSNR = GT_OUTABI-POSNR2.
*--   정산월을 대금청구일이 아닌 실제 정산월로
      GT_ITEM-FBUDA = GT_VBRK-FKDAT(6).

      IF  GT_VBRP-VBELN = '8110258202'
        OR GT_VBRP-VBELN = '8110258203'
        OR GT_VBRP-VBELN = '8110258310'
        OR GT_VBRP-VBELN = '8110259265'
        OR GT_VBRP-VBELN = '8110261009'.
        GT_ITEM-FBUDA = '200910'.
      ENDIF.

*___커미션 지급 정산월 예외처리 - T-Code 'ZLEV0200'에서 관리
      CLEAR : LV_ZDESI.

      SELECT SINGLE ZDESI
        INTO LV_ZDESI
        FROM ZLET0201
       WHERE ZCODH = 'CM01'
         AND ZCODI = GT_VBRP-VBELN.

      IF SY-SUBRC = 0.
        GT_ITEM-FBUDA = LV_ZDESI.
      ENDIF.

      IF GT_ITEM-FBUDA EQ P_SPMON.

        SELECT SINGLE *
          INTO @DATA(LS_ZSD0018T)
          FROM ZSD0018T
*->[CHG]-------------------------S
         WHERE KNUMA = @GT_OUTABI-KNUMA
           AND VBELN = @GT_VBRP-VBELN
           AND POSNR = @GT_VBRP-POSNR.
*         WHERE VBELN = @GT_VBRP-VBELN
*           AND POSNR = @GT_VBRP-POSNR.
*-<[CHG]-------------------------E

        IF GT_VBRK-VBTYP EQ 'K' OR
           GT_VBRK-VBTYP EQ 'H' OR
           GT_VBRK-VBTYP EQ 'O'.
        ELSE.

          GT_ITEM-KWERT_K = LS_ZSD0018T-KWERT_K.

          GT_ITEM-KSTBS   = GT_VBRP-BONBA.    "FOB 액
        ENDIF.

        GT_ITEM-KWAEH = LS_ZSD0018T-KWAEH.
*->[CHG]-------------------------S 2026.02.04
        "커미션 정산오더
        GT_ITEM-VBELN_SE = LS_ZSD0018T-VBELN_SE.
*-<[CHG]-------------------------E 2026.02.04

        MOVE-CORRESPONDING : GT_OUTABI TO GT_ITEM,
                             GT_VBRK   TO GT_ITEM,

                             GT_VBRP   TO GT_ITEM.
        GT_TOTAL-KNUMA = GT_OUTABI-KNUMA.
        GT_TOTAL-FBUDA = GT_ITEM-FBUDA.
        GT_TOTAL-KUNNR = GT_ITEM-KUNNR.
        GT_TOTAL-KWERT_K = GT_ITEM-KWERT_K.
*->[CHG]-------------------------S 2026.02.04
        GT_TOTAL-VBELN_SE = GT_ITEM-VBELN_SE.
*-<[CHG]-------------------------E 2026.02.04

        APPEND GT_ITEM. CLEAR GT_ITEM.
        COLLECT GT_TOTAL. CLEAR GT_TOTAL.
      ENDIF.
      CLEAR : GT_VBRP.

      CLEAR : GT_ITEM-KWERT_K, GT_ITEM-KSTBS.

    ENDLOOP.
  ENDLOOP.

  SORT GT_TOTAL ASCENDING BY KNUMA FBUDA
                             KUNNR.

  LOOP AT GT_HEADER.
    GV_TABIX = SY-TABIX.

    READ TABLE GT_TOTAL WITH KEY KNUMA = GT_HEADER-KNUMA
                                 FBUDA = GT_HEADER-FBUDA
                                 KUNNR = GT_HEADER-KUNNR
*->[CHG]-------------------------S 2026.02.04
                                 VBELN_SE = GT_HEADER-VBELN
*-<[CHG]-------------------------E 2026.02.04
                                 BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      GT_HEADER-KWERT = GT_TOTAL-KWERT_K.
      MODIFY GT_HEADER INDEX GV_TABIX.
    ENDIF.

    IF P_R01 EQ 'X'.
*->[CHG]-------------------------S 2026.02.04
*      IF GT_HEADER-LIGHTS = C_CLIGHT.
*        DELETE GT_HEADER WHERE KNUMA = GT_HEADER-KNUMA.
*        DELETE GT_ITEM   WHERE KNUMA = GT_HEADER-KNUMA.
*      ENDIF.
*-<[CHG]-------------------------E 2026.02.04
    ENDIF.
  ENDLOOP.

*->[CHG]-------------------------S 2026.02.04
  "ITEM 미존재 헤더 삭제
  LOOP AT GT_HEADER INTO DATA(LS_HEADER).
    GV_TABIX = SY-TABIX.
    IF LINE_EXISTS( GT_ITEM[ KNUMA = LS_HEADER-KNUMA
                             FBUDA = LS_HEADER-FBUDA
                             KUNNR = LS_HEADER-KUNNR
                             VBELN_SE = LS_HEADER-VBELN ] ).
    ELSE.
      DELETE GT_HEADER INDEX GV_TABIX.
    ENDIF.
  ENDLOOP.


  DATA(LT_TEMP) = GT_HEADER[].
  IF P_R01 EQ 'X'.
    LOOP AT LT_TEMP INTO DATA(LS_TEMP).
      IF LS_TEMP-LIGHTS = C_CLIGHT.
        DELETE GT_HEADER WHERE KNUMA = LS_TEMP-KNUMA
                           AND FBUDA = LS_TEMP-FBUDA
                           AND KUNNR = LS_TEMP-KUNNR
                           AND VBELN = LS_TEMP-VBELN.
        DELETE GT_ITEM WHERE KNUMA    = LS_TEMP-KNUMA
                         AND FBUDA    = LS_TEMP-FBUDA
                         AND KUNNR    = LS_TEMP-KUNNR
                         AND VBELN_SE = LS_TEMP-VBELN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*-<[CHG]-------------------------E 2026.02.04

* 발생처리액 없는 라인 지움
  DELETE GT_ITEM WHERE KWERT_K = 0.


*___ 공사자재 여부
  IF S_VKORG-LOW = 1000.
    DATA : LV_KTGRM LIKE MVKE-KTGRM.
    LOOP AT GT_ITEM  .
      CLEAR : LV_KTGRM.

      SELECT SINGLE MANDT
       INTO SY-MANDT
       FROM MARA
       WHERE MATNR = GT_ITEM-MATNR
       AND   MTART = 'DIEN'.

      CHECK SY-SUBRC = 0.

      SELECT SINGLE KTGRM
        INTO LV_KTGRM
        FROM MVKE
        WHERE MATNR = GT_ITEM-MATNR
        AND   VKORG = S_VKORG-LOW
        AND   VTWEG = S_VTWEG-LOW.
      IF LV_KTGRM = '03'.
        GT_ITEM-CONTR = 'X'.
      ENDIF.
      MODIFY GT_ITEM.

    ENDLOOP.
  ENDIF.
ENDFORM.                    " MODIFY_DATA_PROCESS

*&---------------------------------------------------------------------*
*&      Form  READ_VBAK_DATA
*&---------------------------------------------------------------------*
FORM READ_VBAK_DATA .

  IF NOT GT_VMVAF[] IS INITIAL.
    CLEAR : GT_VBAK, GT_VBAK[].
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE GT_VBAK
      FROM VBAK
       FOR ALL ENTRIES IN GT_VMVAF
     WHERE VBELN EQ GT_VMVAF-VBELN.

*-> MIG Table 추가 : 2023.08.21
    DATA:
      LT_VBAK LIKE STANDARD TABLE OF GT_VBAK,
      LS_VBAK LIKE LINE OF GT_VBAK.
    SELECT *
      FROM ZVBAK_R3
       FOR ALL ENTRIES IN @GT_VMVAF
     WHERE VBELN EQ @GT_VMVAF-VBELN
      INTO TABLE @DATA(LT_ZVBAK_R3).
    IF SY-SUBRC EQ 0.
      SORT GT_VBAK BY VBELN.
      LOOP AT LT_ZVBAK_R3 ASSIGNING FIELD-SYMBOL(<LS_ZVBAK_R3>).
        READ TABLE GT_VBAK WITH KEY VBELN = <LS_ZVBAK_R3>-VBELN BINARY SEARCH TRANSPORTING NO FIELDS.
        IF SY-SUBRC NE 0.
          CLEAR LS_VBAK.
          MOVE-CORRESPONDING <LS_ZVBAK_R3> TO LS_VBAK.
          APPEND LS_VBAK TO LT_VBAK.
        ENDIF.
      ENDLOOP.
      IF LT_VBAK[] IS NOT INITIAL.
        APPEND LINES OF LT_VBAK TO GT_VBAK.
      ENDIF.
    ENDIF.
*<-
  ENDIF.

ENDFORM.                    " READ_VBAK_DATA

*&---------------------------------------------------------------------*
*&      Form  READ_BKPF_DATA
*&---------------------------------------------------------------------*
FORM READ_BKPF_DATA .



ENDFORM.                    " READ_BKPF_DATA

*&---------------------------------------------------------------------*
*&      Form  READ_BSEG_DATA
*&---------------------------------------------------------------------*
FORM READ_BSEG_DATA .

  RANGES : LR_BELNR FOR VBAK-VBELN.
  CLEAR : LR_BELNR, LR_BELNR[].
  LOOP AT GT_VBAK WHERE BSTNK IS NOT INITIAL.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = GT_VBAK-BSTNK
      IMPORTING
        OUTPUT = LR_BELNR-LOW.

    LR_BELNR-SIGN   = 'I'.
    LR_BELNR-OPTION = 'EQ'.
    APPEND LR_BELNR.  CLEAR LR_BELNR.

  ENDLOOP.

  CLEAR : GT_BSEG, GT_BSEG[].

  LOOP AT LR_BELNR.
*>> START - Archiving 관련변경 09 -> 20080312
    SELECT * INTO CORRESPONDING FIELDS OF GT_BSEG
      FROM BSEG
     WHERE BELNR = LR_BELNR-LOW
       AND BUKRS = S_VKORG-LOW
       AND GJAHR = P_SPMON(4)
       AND BUZEI = '001'
       AND SHKZG = 'H'.

      APPEND GT_BSEG.

    ENDSELECT.
*-- 아카이브 체크를 한 경우
    IF NOT P_ARCV IS INITIAL.
      SELECT * INTO CORRESPONDING FIELDS OF GT_BSEG
        FROM ZARIXFI1
       WHERE BELNR = LR_BELNR-LOW
         AND BUKRS = S_VKORG-LOW
         AND GJAHR = P_SPMON(4)
         AND BUZEI = '001'
         AND SHKZG = 'H'.

        APPEND GT_BSEG.

      ENDSELECT.
    ENDIF.

  ENDLOOP.


ENDFORM.                    " READ_BSEG_DATA

*&---------------------------------------------------------------------*
*&      Form  EXECUTE_FB60_BDC
*&---------------------------------------------------------------------*
FORM EXECUTE_FB60_BDC .

  DATA : LV_ERROR,
         LV_FLAG,
         LV_FLAG2,
         LV_KUNNR LIKE KNA1-KUNNR,
         LV_LIFNR LIKE KNA1-LIFNR.

  CLEAR : LV_FLAG, LV_FLAG2.
  CLEAR : G_TMP_T, G_TMP_T[].

  REFRESH GT_BDCDATA.

  LOOP AT GT_HEADER WHERE BOX = 'X'.
** c_blight value '3',  " 부가세전표 생성완료
** c_clight value '2',  " 미지급전표 생성완료
** c_flight value '1',  " 전표 생성 미완료
** 전표 생성 완료 된것
    IF GT_HEADER-LIGHTS NE C_FLIGHT.
      LV_FLAG = 'X'.
      EXIT.
    ENDIF.
*분할정산 오더가 없을경우 전표 생성 하면 안됨.
    IF GT_HEADER-VBELN IS INITIAL.
      LV_FLAG2 = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF LV_FLAG2 EQ ' '.
    IF LV_FLAG EQ ' '.
      LOOP AT GT_HEADER WHERE BOX = 'X'.

        CALL FUNCTION 'ENQUEUE_EVKONAE'
          EXPORTING
            MODE_KONA      = 'E'
            MANDT          = SY-MANDT
            KNUMA          = GT_HEADER-KNUMA
            X_KNUMA        = ' '
            _SCOPE         = '2'
            _WAIT          = ' '
            _COLLECT       = ' '
          EXCEPTIONS
            FOREIGN_LOCK   = 1
            SYSTEM_FAILURE = 2
            OTHERS         = 3.

        IF SY-SUBRC <> 0.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.


** c_hkont 계정 결정 수정 written by choi seok won
        PERFORM CHANGE_HKONT.

** Request by 윤위원 : 2005-04-14
** 정산오더의 영업사원과 대금청구문서의 영업사원이 다를경우
** 정산오더의 영업사원을 대금청구상의 영업사원으로 Change한다.
*        perform  change_order_va02.

        SELECT SINGLE LIFNR INTO LV_LIFNR
               FROM LFA1
               WHERE KUNNR = GT_HEADER-BONEM.

* 미지급 전표 생성 BDC 처리
        PERFORM FILL_FIELD_DATA USING LV_LIFNR.
        PERFORM CALL_TRANSACTION_FB01.

        IF NOT GV_BELNR IS INITIAL  AND
           GV_BELNR+0(2) EQ '12'.    " 전표번호의 Number Range
* 분할 정산 오더 전표 번호 업데이트 및 거절사유 입력
          PERFORM CHANGE_SALES_DOC USING  GT_HEADER-VBELN
                                          GV_BELNR
                                          C_AUGRU
                         CHANGING LV_ERROR.
          PERFORM CALL_TRANSACTION_VA02 USING GT_HEADER-VBELN.
        ELSE.

        ENDIF.


        CALL FUNCTION 'DEQUEUE_EVKONAE'
          EXPORTING
            MODE_KONA = 'E'
            MANDT     = SY-MANDT
            KNUMA     = GT_HEADER-KNUMA
            X_KNUMA   = ' '
            _SCOPE    = '3'
            _SYNCHRON = ' '
            _COLLECT  = ' '.

      ENDLOOP.

      PERFORM EXECUTE_BUGA_BDC2.

      PERFORM CALL_MESSAGE_SCREEN.
    ELSE.
      CLEAR GT_HEADER-BOX.
      MODIFY GT_HEADER TRANSPORTING BOX WHERE BOX = 'X'.
      MESSAGE E001(ZSD1) WITH '발생된 전표가 이미 존재합니다.'.
    ENDIF.
  ELSE.
    CLEAR GT_HEADER-BOX.
    MODIFY GT_HEADER TRANSPORTING BOX WHERE BOX = 'X'.
    MESSAGE E001(ZSD1) WITH '분할정산오더가 존재하지않습니다.'.
  ENDIF.

ENDFORM.                    " EXECUTE_FB60_BDC
*&---------------------------------------------------------------------*
*&      Form  FILL_FIELD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  BDC FIELD 정의
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILL_FIELD_DATA  USING P_LIFNR.

  DATA : LV_NETWR(15),
         LV_TEMP LIKE ZSDS002-NETWR.
  DATA: LV_LIFNR     LIKE LFA1-LIFNR,
        LV_PNR       LIKE VBAP-PS_PSP_PNR,
        ONE(1)       TYPE C,
        TWO(09)      TYPE C,
        LV_LAST      TYPE C,
        LV_XBLNR(21).

  DATA : BEGIN OF LT_ITEM OCCURS 0.
  DATA : VBELN     LIKE VBAP-VBELN,
         POSNR     LIKE VBAP-POSNR,
         KWERT_K   LIKE ZSDS003-KWERT_K,
         NETWR(15),
         WBSCD(30) .
  DATA : END OF LT_ITEM.

  DATA : BEGIN OF LT_COBRB OCCURS 0 .
  DATA : OBJNR   LIKE COBRB-OBJNR,
         PAOBJNR LIKE COBRB-PAOBJNR,
         AVORG   LIKE COBRB-AVORG.

  DATA : END OF LT_COBRB.
  CLEAR : LT_ITEM ,LT_ITEM[].
  CLEAR : LV_TEMP, ONE, TWO, LV_XBLNR, LV_LAST.


*___ 공사아닌 매출 합
  LOOP AT GT_ITEM WHERE KNUMA = GT_HEADER-KNUMA
                         AND CONTR = ' '.
    LT_ITEM-VBELN = GT_HEADER-VBELN.
    LT_ITEM-POSNR = '10'.
    LT_ITEM-KWERT_K = GT_ITEM-KWERT_K.
    COLLECT LT_ITEM.CLEAR : LT_ITEM.
  ENDLOOP.


*___ 공사 매출
  DATA : LV_VBELN   LIKE VBAP-VBELN,
         LV_POSNR   LIKE VBAP-POSNR,
         LV_OBJNR   LIKE PRPS-OBJNR,
         LV_PAOBJNR LIKE COBRB-PAOBJNR.
  LOOP AT GT_ITEM WHERE KNUMA = GT_HEADER-KNUMA
                       AND CONTR = 'X'.


    CLEAR : LV_PNR, LV_VBELN, LV_POSNR, LV_OBJNR , LV_PAOBJNR .

    SELECT SINGLE AUBEL AUPOS
      INTO (LV_VBELN , LV_POSNR)
      FROM VBRP
      WHERE VBELN = GT_ITEM-VBELN2
      AND   POSNR = GT_ITEM-POSNR.
*-> MIG Table 추가 : 2023.08.21
    IF SY-SUBRC NE 0.
      SELECT SINGLE AUBEL AUPOS
       INTO (LV_VBELN , LV_POSNR)
       FROM ZVBRP_R3
       WHERE VBELN = GT_ITEM-VBELN2
       AND   POSNR = GT_ITEM-POSNR.
    ENDIF.
*<-

    SELECT SINGLE PS_PSP_PNR
      INTO LV_PNR
      FROM VBAP
      WHERE VBELN = LV_VBELN
      AND   POSNR = LV_POSNR.
*-> MIG Table 추가 : 2023.08.21
    IF SY-SUBRC NE 0.
      SELECT SINGLE PS_PSP_PNR
      INTO LV_PNR
      FROM ZVBAP_R3
      WHERE VBELN = LV_VBELN
      AND   POSNR = LV_POSNR.
    ENDIF.
*<-

    CALL FUNCTION 'CONVERSION_EXIT_KONPR_OUTPUT'
      EXPORTING
        INPUT  = LV_PNR
      IMPORTING
        OUTPUT = LT_ITEM-WBSCD.

    SELECT SINGLE OBJNR
      INTO LV_OBJNR
      FROM PRPS
      WHERE PSPNR = LV_PNR.

    CLEAR : LT_COBRB, LT_COBRB[].

    SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_COBRB
      FROM COBRB
      WHERE OBJNR = LV_OBJNR
      AND   AVORG = 'KOAO' .

    SORT LT_COBRB DESCENDING.
    READ TABLE LT_COBRB WITH KEY AVORG = 'KOAO'.
    IF SY-SUBRC = 0.
      LV_PAOBJNR = LT_COBRB-PAOBJNR.
    ELSE.
      CLEAR : LT_COBRB, LT_COBRB[].
      SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_COBRB
        FROM COBRB
        WHERE OBJNR = LV_OBJNR
        AND   AVORG = 'KOAW' .

      SORT LT_COBRB DESCENDING.

      READ TABLE LT_COBRB WITH KEY AVORG = 'KOAW'.
      IF SY-SUBRC = 0 .
        LV_PAOBJNR = LT_COBRB-PAOBJNR.
      ENDIF.
    ENDIF.

    SELECT SINGLE KAUFN KDPOS
      INTO (LT_ITEM-VBELN , LT_ITEM-POSNR)
      FROM  CE41000_ACCT
      WHERE PAOBJNR = LV_PAOBJNR.



*    SELECT SINGLE PAOBJNR
*    INTO LV_PAOBJNR
*    FROM COBRB
*    WHERE OBJNR = LV_OBJNR .


    IF LT_ITEM-VBELN IS INITIAL OR LT_ITEM-POSNR IS INITIAL.
      MESSAGE E001(ZSD1) WITH
                      'WBS코드 가져오기 실패'.
    ENDIF.
    LT_ITEM-KWERT_K = GT_ITEM-KWERT_K .

    APPEND LT_ITEM.CLEAR : LT_ITEM.
  ENDLOOP.

*___ 금액 변환

  LOOP AT LT_ITEM.
    LT_ITEM-KWERT_K = LT_ITEM-KWERT_K * -1.
    WRITE : LT_ITEM-KWERT_K TO LT_ITEM-NETWR
    CURRENCY GT_HEADER-WAERK.
    MODIFY LT_ITEM.
  ENDLOOP.



  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = GT_HEADER-KNUMA
    IMPORTING
      OUTPUT = GT_HEADER-KNUMA.


  WRITE : GT_HEADER-NETWR TO LV_NETWR CURRENCY GT_HEADER-WAERK.




  CLEAR : GT_BDCDATA, GT_BDCDATA[].

  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0100'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RF05A-NEWUM'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BKPF-BLDAT'
                                GV_LDATE.   "입력월의 마지막날
  PERFORM BDC_FIELD       USING 'BKPF-BLART'
                                C_BLART.   "전표유형
  PERFORM BDC_FIELD       USING 'BKPF-BUKRS'
                                S_VKORG-LOW.
  PERFORM BDC_FIELD       USING 'BKPF-BUDAT'
                                GV_LDATE.    "입력월의 마지막날
  PERFORM BDC_FIELD       USING 'BKPF-WAERS'
                                GT_HEADER-WAERK.  "통화
  PERFORM BDC_FIELD       USING 'RF05A-NEWBS'
                                '39'.       "전기키
  PERFORM BDC_FIELD       USING 'RF05A-NEWKO'
                                 GT_HEADER-BONEM.   "Agent
  PERFORM BDC_FIELD       USING 'RF05A-NEWUM'
                                 C_UMSKZ.   "특별 G/L 지시자



  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0303'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RF05A-NEWKO'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BSEG-WRBTR'
                                  LV_NETWR.      "오더금액
  IF S_VKORG-LOW = '3000'.
    C_BUPLA = GT_HEADER-BUPLA.
  ENDIF.
  PERFORM BDC_FIELD       USING 'BSEG-BUPLA'
                                  C_BUPLA.       "사업장

  PERFORM BDC_FIELD       USING 'BSEG-GSBER'
                                GT_HEADER-GSBER.
  PERFORM BDC_FIELD       USING 'BSEG-ZFBDT'
                                    GV_LDATE.    "입력월의 마지막날
  PERFORM BDC_FIELD       USING 'BSEG-ZUONR'
                                GT_HEADER-VBELN.  " 분할 정산오더
  PERFORM BDC_FIELD       USING 'BSEG-SGTXT'
                                GT_HEADER-KNUMA.  "계약 NO
  PERFORM BDC_FIELD       USING 'RF05A-NEWBS'
                                '40'.  "전기키 '40'
  PERFORM BDC_FIELD       USING 'RF05A-NEWKO'
                                 C_HKONT.
  PERFORM BDC_FIELD       USING 'BSEG-HKONT'
                               H_HKONT.       "사업장


*________________________
  LOOP AT LT_ITEM.
    AT LAST .
      LV_LAST = 'X'.
    ENDAT.

    PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0300'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'BSEG-BUPLA'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'BSEG-WRBTR'
*                                '*'.
                                  LT_ITEM-NETWR.
    PERFORM BDC_FIELD       USING 'BSEG-MWSKZ'
                                   C_MWSKZ.
    PERFORM BDC_FIELD       USING 'BSEG-BUPLA'
                                   C_BUPLA.       "사업장
    PERFORM BDC_FIELD       USING 'DKACB-FMORE'
                                  'X'.

    IF LV_LAST  = ' '.
      PERFORM BDC_FIELD       USING 'RF05A-NEWBS'
                                    '40'.  "전기키 '40'
      PERFORM BDC_FIELD       USING 'RF05A-NEWKO'
                                     C_HKONT.
*      PERFORM BDC_FIELD       USING 'BSEG-HKONT'
*                                   H_HKONT.       "사업장

    ENDIF.

    PERFORM BDC_DYNPRO      USING 'SAPLKACB' '0002'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'COBL-GSBER'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=COBL_XERGO'.

    PERFORM BDC_DYNPRO      USING 'SAPLKEAK' '0300'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=WEIT'.

    PERFORM BDC_FIELD       USING 'RKEAK-FIELD(04)'
                                  LT_ITEM-VBELN.  " 분할 정산오더
    PERFORM BDC_FIELD       USING 'RKEAK-FIELD(05)'
                                  LT_ITEM-POSNR.
    IF  LT_ITEM-WBSCD IS NOT INITIAL.
      PERFORM BDC_FIELD       USING 'RKEAK-FIELD(11)'
                                    LT_ITEM-WBSCD. "공사 WBS 오더
    ENDIF.


    PERFORM BDC_DYNPRO      USING 'SAPLKACB' '0002'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'COBL-GSBER'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=ENTE'.
  ENDLOOP.
*____________________________________________


  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0300'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'BSEG-WRBTR'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=BU'.

  PERFORM BDC_DYNPRO      USING 'SAPLKACB' '0002'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'COBL-GSBER'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=ENTE'.


ENDFORM.                    " FILL_FIELD_DATA
*&---------------------------------------------------------------------*
*&      Form  FILL_FIELD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  BDC FIELD 정의
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILL_FIELD_DATA_NEW  USING P_LIFNR.

* 전표 BDC 전기를 위한 변수
  DATA: LT_BBKPF LIKE STANDARD TABLE OF BBKPF WITH HEADER LINE,
        LT_BBSEG LIKE STANDARD TABLE OF BBSEG WITH HEADER LINE,
        LT_FIMSG LIKE STANDARD TABLE OF FIMSG WITH HEADER LINE.

  DATA: LV_MSG(100),
        LV_BELNR  TYPE  BELNR_D.

  DATA : LV_NETWR(15),
         LV_TEMP LIKE ZSDS002-NETWR.
  DATA: LV_LIFNR     LIKE LFA1-LIFNR,
        LV_PNR       LIKE VBAP-PS_PSP_PNR,
        ONE(1)       TYPE C,
        TWO(09)      TYPE C,
        LV_LAST      TYPE C,
        LV_XBLNR(21).

  DATA : BEGIN OF LT_ITEM OCCURS 0.
  DATA : VBELN     LIKE VBAP-VBELN,
         POSNR     LIKE VBAP-POSNR,
         KWERT_K   LIKE ZSDS003-KWERT_K,
         NETWR(15),
         WBSCD(30) .
  DATA : END OF LT_ITEM.

  DATA : BEGIN OF LT_COBRB OCCURS 0 .
  DATA : OBJNR   LIKE COBRB-OBJNR,
         PAOBJNR LIKE COBRB-PAOBJNR,
         AVORG   LIKE COBRB-AVORG.

  DATA : END OF LT_COBRB.
  CLEAR : LT_ITEM ,LT_ITEM[].
  CLEAR : LV_TEMP, ONE, TWO, LV_XBLNR, LV_LAST.


*___ 공사아닌 매출 합
*->[CHG]-------------------------S 2026.02.04
  LOOP AT GT_ITEM WHERE KNUMA   = GT_HEADER-KNUMA
                    AND VBELN_SE = GT_HEADER-VBELN
                    AND CONTR = ' '.
*  LOOP AT GT_ITEM WHERE KNUMA = GT_HEADER-KNUMA
*                         AND CONTR = ' '.
*-<[CHG]-------------------------E 2026.02.04
    LT_ITEM-VBELN = GT_HEADER-VBELN.
    LT_ITEM-POSNR = '10'.
    LT_ITEM-KWERT_K = GT_ITEM-KWERT_K.
    COLLECT LT_ITEM.CLEAR : LT_ITEM.
  ENDLOOP.


*___ 공사 매출
  DATA : LV_VBELN   LIKE VBAP-VBELN,
         LV_POSNR   LIKE VBAP-POSNR,
         LV_OBJNR   LIKE PRPS-OBJNR,
         LV_PAOBJNR LIKE COBRB-PAOBJNR.
  LOOP AT GT_ITEM WHERE KNUMA = GT_HEADER-KNUMA
                       AND VBELN_SE = GT_HEADER-VBELN
                       AND CONTR = 'X'.


    CLEAR : LV_PNR, LV_VBELN, LV_POSNR, LV_OBJNR , LV_PAOBJNR .

    SELECT SINGLE AUBEL AUPOS
      INTO (LV_VBELN , LV_POSNR)
      FROM VBRP
      WHERE VBELN = GT_ITEM-VBELN2
      AND   POSNR = GT_ITEM-POSNR.
*-> MIG Table 추가 : 2023.08.21
    IF SY-SUBRC NE 0.
      SELECT SINGLE AUBEL AUPOS
        INTO (LV_VBELN , LV_POSNR)
        FROM ZVBRP_R3
        WHERE VBELN = GT_ITEM-VBELN2
        AND   POSNR = GT_ITEM-POSNR.
    ENDIF.
*<-
    SELECT SINGLE PS_PSP_PNR
      INTO LV_PNR
      FROM VBAP
      WHERE VBELN = LV_VBELN
      AND   POSNR = LV_POSNR.
*-> MIG Table 추가 : 2023.08.21
    IF SY-SUBRC NE 0.
      SELECT SINGLE PS_PSP_PNR
       INTO LV_PNR
       FROM ZVBAP_R3
       WHERE VBELN = LV_VBELN
       AND   POSNR = LV_POSNR.
    ENDIF.
*<-

    CALL FUNCTION 'CONVERSION_EXIT_KONPR_OUTPUT'
      EXPORTING
        INPUT  = LV_PNR
      IMPORTING
        OUTPUT = LT_ITEM-WBSCD.

    SELECT SINGLE OBJNR
      INTO LV_OBJNR
      FROM PRPS
      WHERE PSPNR = LV_PNR.

    CLEAR : LT_COBRB, LT_COBRB[].

    SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_COBRB
      FROM COBRB
      WHERE OBJNR = LV_OBJNR
      AND   AVORG = 'KOAO' .

    SORT LT_COBRB DESCENDING.
    READ TABLE LT_COBRB WITH KEY AVORG = 'KOAO'.
    IF SY-SUBRC = 0.
      LV_PAOBJNR = LT_COBRB-PAOBJNR.
    ELSE.
      CLEAR : LT_COBRB, LT_COBRB[].
      SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_COBRB
        FROM COBRB
        WHERE OBJNR = LV_OBJNR
        AND   AVORG = 'KOAW' .

      SORT LT_COBRB DESCENDING.

      READ TABLE LT_COBRB WITH KEY AVORG = 'KOAW'.
      IF SY-SUBRC = 0 .
        LV_PAOBJNR = LT_COBRB-PAOBJNR.
      ENDIF.
    ENDIF.

    SELECT SINGLE KAUFN KDPOS
      INTO (LT_ITEM-VBELN , LT_ITEM-POSNR)
      FROM  CE41000_ACCT
     WHERE PAOBJNR = LV_PAOBJNR.



*    SELECT SINGLE PAOBJNR
*    INTO LV_PAOBJNR
*    FROM COBRB
*    WHERE OBJNR = LV_OBJNR .


    IF LT_ITEM-VBELN IS INITIAL OR LT_ITEM-POSNR IS INITIAL.
      MESSAGE E001(ZSD1) WITH 'WBS코드 가져오기 실패'.
    ENDIF.
    LT_ITEM-KWERT_K = GT_ITEM-KWERT_K .

    APPEND LT_ITEM.CLEAR : LT_ITEM.
  ENDLOOP.

*___ 금액 변환

  LOOP AT LT_ITEM.
    LT_ITEM-KWERT_K = LT_ITEM-KWERT_K * -1.
    WRITE : LT_ITEM-KWERT_K TO LT_ITEM-NETWR
    CURRENCY GT_HEADER-WAERK.
    MODIFY LT_ITEM.
  ENDLOOP.



  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = GT_HEADER-KNUMA
    IMPORTING
      OUTPUT = GT_HEADER-KNUMA.


  WRITE : GT_HEADER-NETWR TO LV_NETWR CURRENCY GT_HEADER-WAERK.

  CLEAR: LT_BBKPF[], LT_BBKPF, LT_BBSEG[], LT_BBSEG,
         LT_FIMSG[], LT_FIMSG.

* 전표헤더정보
  LT_BBKPF-TCODE = 'FB01'.
  LT_BBKPF-BLDAT = GV_LDATE.         "입력월의 마지막날
  LT_BBKPF-BLART = C_BLART.          "전표유형
  LT_BBKPF-BUKRS = S_VKORG-LOW.      "회사코드
  LT_BBKPF-BUDAT = GV_LDATE.         "입력월의 마지막날
  LT_BBKPF-WAERS = GT_HEADER-WAERK.  "통화
  APPEND LT_BBKPF.

* 라인아이템 1
  LT_BBSEG-NEWBS = '39'.             "전기키
  LT_BBSEG-NEWKO = GT_HEADER-BONEM.  "Agent
  LT_BBSEG-NEWUM = C_UMSKZ.          "특별 G/L 지시자
  LT_BBSEG-WRBTR = LV_NETWR.         "오더금액
  LT_BBSEG-HKONT = H_HKONT.          "조정계정
*->[CHG]-------------------------S
  IF S_VKORG-LOW = '3000' OR
     S_VKORG-LOW = '6000'.
*  IF S_VKORG-LOW = '3000'.
*-<[CHG]-------------------------E
    C_BUPLA = GT_HEADER-BUPLA.
  ENDIF.
  LT_BBSEG-BUPLA = C_BUPLA.          "사업장
  LT_BBSEG-GSBER = GT_HEADER-GSBER.  "사업영역
  LT_BBSEG-ZFBDT = GV_LDATE.         "입력월의 마지막날
  LT_BBSEG-ZUONR = GT_HEADER-VBELN.  "분할 정산오더
  LT_BBSEG-SGTXT = GT_HEADER-KNUMA.  "계약 NO
  APPEND LT_BBSEG. CLEAR LT_BBSEG.

*________________________
  LOOP AT LT_ITEM.
*   라인아이템 2
    LT_BBSEG-NEWBS = '40'.             "전기키 '40'
    LT_BBSEG-NEWKO = C_HKONT.          "계정
    LT_BBSEG-WRBTR = LT_ITEM-NETWR.    "금액
    LT_BBSEG-MWSKZ = C_MWSKZ.          "세금코드
    LT_BBSEG-BUPLA = C_BUPLA.          "사업장
*   수익성 세그먼트
    LT_BBSEG-RKE_BUKRS = S_VKORG-LOW.
    LT_BBSEG-RKE_KAUFN = LT_ITEM-VBELN.    "분할 정산오더
    LT_BBSEG-RKE_KDPOS = LT_ITEM-POSNR.    "품목번호
    IF  LT_ITEM-WBSCD IS NOT INITIAL.
      LT_BBSEG-RKE_PSPNR = LT_ITEM-WBSCD . "공사WBS오더
    ENDIF.
    APPEND LT_BBSEG. CLEAR LT_BBSEG.
  ENDLOOP.
*____________________________________________

  CLEAR : GV_BELNR.
  EXPORT 'ZSD1R1000' TO MEMORY ID 'ZFITCODE'.

* 전표생성 펑션 Call
  CLEAR: LV_BELNR, LV_MSG.
  CALL FUNCTION 'ZFI_DOCUMENT_POSTING'
    EXPORTING
      I_BDC_MODE  = P_MODE
      I_MESSAGE   = ''
    IMPORTING
      E_BELNR     = LV_BELNR
      E_RESULTMSG = LV_MSG
    TABLES
      T_BBKPF     = LT_BBKPF
      T_BBSEG     = LT_BBSEG
      T_MESSTAB   = LT_FIMSG.

  IF NOT LV_BELNR IS INITIAL.
    GV_BELNR = LV_BELNR.
  ENDIF.

* 메시지 생성
  LOOP AT LT_FIMSG.
    AT LAST.
      LV_LAST = 'X'.
    ENDAT.
    IF LV_LAST IS INITIAL.
      CASE LT_FIMSG-MSGTY.
        WHEN 'A' OR 'E' OR 'X'.
          CLEAR GT_BDCMSG.
          GT_BDCMSG-BELNR = GV_BELNR.
          GT_BDCMSG-UPDKZ = 'I'.
          MOVE-CORRESPONDING LT_FIMSG TO GT_BDCMSG.
          GT_BDCMSG-MSGNR = LT_FIMSG-MSGNO.
          APPEND GT_BDCMSG.
        WHEN 'W'.
          IF LT_FIMSG-MSGNO NE '394'.
            CLEAR GT_BDCMSG.
            GT_BDCMSG-BELNR = GV_BELNR.
            GT_BDCMSG-UPDKZ = 'I'.
            MOVE-CORRESPONDING LT_FIMSG TO GT_BDCMSG.
            GT_BDCMSG-MSGNR = LT_FIMSG-MSGNO.
            APPEND GT_BDCMSG.
          ENDIF.
      ENDCASE.
    ELSE.
      CLEAR GT_BDCMSG.
      GT_BDCMSG-BELNR = GV_BELNR.
      GT_BDCMSG-UPDKZ = 'I'.
      MOVE-CORRESPONDING LT_FIMSG TO GT_BDCMSG.
      GT_BDCMSG-MSGNR = LT_FIMSG-MSGNO.
      APPEND GT_BDCMSG.
    ENDIF.
  ENDLOOP.

** CBO테이블 관리.
** 미지급전표 생성여부 Check.
  CHECK NOT GV_BELNR IS INITIAL  AND
            GV_BELNR+0(2) EQ '12'.    " 전표번호의 Number Range

  MOVE-CORRESPONDING  GT_HEADER  TO  G_TMP_T.
  G_TMP_T-C_WAERK  =  GT_HEADER-WAERK.
  G_TMP_T-BELNR  =  GV_BELNR.

  APPEND  G_TMP_T.
  CLEAR  G_TMP_T.


ENDFORM.                    " FILL_FIELD_DATA_new
*&---------------------------------------------------------------------*
*&      Form  CHANGE_SALES_DOC
*&---------------------------------------------------------------------*
*       영업문서 변경.
*----------------------------------------------------------------------*
*      -->I_VBELN  영업문서.
*      <--E_ERROR  오류지시자.
*----------------------------------------------------------------------*
FORM CHANGE_SALES_DOC USING    P_VBELN
                               P_BELNR
                               P_AUGRU
                      CHANGING E_ERROR.

  CLEAR : GT_BDCDATA, GT_BDCDATA[].
  PERFORM BDC_DYNPRO      USING 'SAPMV45A' '0102'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'VBAK-VBELN'
                                P_VBELN.
  PERFORM BDC_DYNPRO      USING 'SAPMV45A' '4001'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=T\07'. "2023.07.11 ZITCS4HDEV01 - '=T\08' -> '=T\07' 수정
  PERFORM BDC_FIELD       USING 'VBKD-BSTKD'
                                P_BELNR.
  PERFORM BDC_DYNPRO      USING 'SAPMV45A' '4001'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=SICH'.
  PERFORM BDC_FIELD       USING 'VBAK-AUGRU'
                                P_AUGRU.                    "'B31'.

ENDFORM.                    " CHANGE_SALES_DOC

*&---------------------------------------------------------------------*
*&      Form  READ_MAIN_DATA
*&---------------------------------------------------------------------*
FORM READ_MAIN_DATA .

  CLEAR : GT_OUTAB, GT_OUTAB[].




  SELECT A~VKORG   AS VKORG
         A~VTWEG   AS VTWEG
         A~SPART   AS SPART
         A~VKBUR   AS VKBUR
         A~VKGRP   AS VKGRP
         A~BONEM   AS BONEM        " Agent
         D~NAME1   AS NAME         " Agent명
         B~KUNNR   AS KUNNR        " 고객
         E~NAME1   AS NAME1        " 고객명
         A~KNUMA   AS KNUMA        " 계약 NO
         A~BOTEXT  AS BOTEXT       " 계약명
         A~BOSTA   AS BOSTA        " 계약상태
         A~WAERS   AS WAERS        " 통화단위
*        c~kbetr   as kbetr        " RATE
         C~KBRUE   AS KBETR        " RATE        "윤방희 수정
         C~KONWA   AS KONWA        " RATE 단위
         C~KPEIN   AS KPEIN
         C~KMEIN   AS KMEIN
         A~DATAB   AS DATAB        " 효력발생일
         A~DATBI   AS DATBI        " 효력만료일
*-> CCM : 20.04.2023 15:38:10 / ZLSGSD4
*         F~VAKEY   AS VAKEY        " 변수키
*<-
         F~KOTABNR AS KOTABNR      " 조건 테이블
         F~KAPPL   AS KAPPL        " 어플리케이션
*-> CCM : 20.04.2023 15:39:35 / ZLSGSD4
*         K~VBELN   AS VBELN2       " BILLING DOC
*         K~POSNR   AS POSNR2       " item NO
         M~VBELN   AS VBELN2       " BILLING DOC
         M~POSNR   AS POSNR2       " item NO
*<-
         B~KNUMH   AS KNUMH        " 조건번호
         B~KSCHL   AS KSCHL        " 조건유형
         APPENDING CORRESPONDING FIELDS OF TABLE GT_OUTAB
         FROM KONA AS A INNER JOIN KOTE909 AS B
          ON A~KNUMA EQ B~KNUMA
          INNER JOIN KONP AS C
          ON B~KNUMH EQ C~KNUMH
          INNER JOIN KNA1 AS D
          ON A~BONEM EQ D~KUNNR
          INNER JOIN KNA1 AS E
          ON B~KUNNR EQ E~KUNNR
          INNER JOIN KONH AS F
          ON B~KNUMH EQ F~KNUMH
*-> CCM : 20.04.2023 15:30:47 / ZLSGSD4
*           INNER JOIN VBOX AS K
*           ON   F~KAPPL EQ K~KAPPL
*            AND F~KOTABNR EQ K~KOTABNR
*            AND F~VAKEY   EQ K~VAKEY
           INNER JOIN VBRK AS K
           ON A~KNUMA EQ K~KNUMA
           INNER JOIN VBRK AS L
           ON F~KAPPL EQ L~KAPPL
           INNER JOIN VBRP AS M
           ON K~VBELN EQ M~VBELN
*<-
         WHERE A~VKORG IN S_VKORG
          AND  A~VTWEG IN S_VTWEG
          AND  A~SPART IN S_SPART
*          and  a~vkbur in s_vkbur
*          and  a~vkgrp in s_vkgrp
          AND  A~BONEM IN S_BONEM
          AND  A~KNUMA IN S_KNUMA
          AND  A~BOSTA IN S_BOSTA
          AND  A~DATBI >= GV_DATE
          AND  A~DATAB <= GV_DATE
          AND  C~LOEVM_KO EQ SPACE
*-> CCM : 20.04.2023 15:40:10 / ZLSGSD4
          AND  K~DRAFT = SPACE
          AND  M~DRAFT = SPACE
          AND  L~DRAFT = SPACE.
*<-

  SELECT A~VKORG   AS VKORG
         A~VTWEG   AS VTWEG
         A~SPART   AS SPART
         A~VKBUR   AS VKBUR
         A~VKGRP   AS VKGRP
         A~BONEM   AS BONEM        " Agent
         D~NAME1   AS NAME         " Agent명
         B~KUNNR   AS KUNNR        " 고객
         E~NAME1   AS NAME1        " 고객명
         A~KNUMA   AS KNUMA        " 계약 NO
         A~BOTEXT  AS BOTEXT       " 계약명
         A~BOSTA   AS BOSTA        " 계약상태
         A~WAERS   AS WAERS        " 통화단위
*        c~kbetr   as kbetr        " RATE
         C~KBRUE   AS KBETR        " RATE        "윤방희 수정
         C~KONWA   AS KONWA        " RATE 단위
         C~KPEIN   AS KPEIN
         C~KMEIN   AS KMEIN
         A~DATAB   AS DATAB        " 효력발생일
         A~DATBI   AS DATBI        " 효력만료일
*-> CCM : 20.04.2023 15:40:44 / ZLSGSD4
*         F~VAKEY   AS VAKEY        " 변수키
*<-
         F~KOTABNR AS KOTABNR      " 조건 테이블
         F~KAPPL   AS KAPPL        " 어플리케이션
*-> CCM : 20.04.2023 15:40:59 / ZLSGSD4
*         K~VBELN   AS VBELN2       " BILLING DOC
*         K~POSNR   AS POSNR2       " item NO
         M~VBELN   AS VBELN2       " BILLING DOC
         M~POSNR   AS POSNR2       " item NO
*<-
         B~KNUMH   AS KNUMH        " 조건번호
         B~KSCHL   AS KSCHL        " 조건유형
         APPENDING CORRESPONDING FIELDS OF TABLE GT_OUTAB
         FROM KONA AS A INNER JOIN KOTE910 AS B
          ON A~KNUMA EQ B~KNUMA
          INNER JOIN KONP AS C
          ON B~KNUMH EQ C~KNUMH
          INNER JOIN KNA1 AS D
          ON A~BONEM EQ D~KUNNR
          INNER JOIN KNA1 AS E
          ON B~KUNNR EQ E~KUNNR
          INNER JOIN KONH AS F
          ON B~KNUMH EQ F~KNUMH
*-> CCM : 20.04.2023 15:31:03 / ZLSGSD4
*           INNER JOIN VBOX AS K
*           ON   F~KAPPL EQ K~KAPPL
*            AND F~KOTABNR EQ K~KOTABNR
*            AND F~VAKEY   EQ K~VAKEY
           INNER JOIN VBRK AS K
           ON A~KNUMA EQ K~KNUMA
           INNER JOIN VBRK AS L
           ON F~KAPPL EQ L~KAPPL
           INNER JOIN VBRP AS M
           ON K~VBELN EQ M~VBELN
*<-
         WHERE A~VKORG IN S_VKORG
          AND  A~VTWEG IN S_VTWEG
          AND  A~SPART IN S_SPART
*          and  a~vkbur in s_vkbur
*          and  a~vkgrp in s_vkgrp
          AND  A~BONEM IN S_BONEM
          AND  A~KNUMA IN S_KNUMA
          AND  A~BOSTA IN S_BOSTA
          AND  A~DATBI >= GV_DATE
          AND  A~DATAB <= GV_DATE
          AND  C~LOEVM_KO EQ SPACE
*-> CCM : 20.04.2023 15:41:27 / ZLSGSD4
          AND  K~DRAFT = SPACE
          AND  M~DRAFT = SPACE
          AND  L~DRAFT = SPACE.
*<-

  SELECT A~VKORG   AS VKORG
         A~VTWEG   AS VTWEG
         A~SPART   AS SPART
         A~VKBUR   AS VKBUR
         A~VKGRP   AS VKGRP
         A~BONEM   AS BONEM        " Agent
         D~NAME1   AS NAME         " Agent명
         B~KUNNR   AS KUNNR        " 고객
         E~NAME1   AS NAME1        " 고객명
         A~KNUMA   AS KNUMA        " 계약 NO
         A~BOTEXT  AS BOTEXT       " 계약명
         A~BOSTA   AS BOSTA        " 계약상태
         A~WAERS   AS WAERS        " 통화단위
*        c~kbetr   as kbetr        " RATE
         C~KBRUE   AS KBETR        " RATE        "윤방희 수정
         C~KONWA   AS KONWA        " RATE 단위
         C~KPEIN   AS KPEIN
         C~KMEIN   AS KMEIN
         A~DATAB   AS DATAB        " 효력발생일
         A~DATBI   AS DATBI        " 효력만료일
*-> CCM : 20.04.2023 15:41:43 / ZLSGSD4
*         F~VAKEY   AS VAKEY        " 변수키
*<-
         F~KOTABNR AS KOTABNR      " 조건 테이블
         F~KAPPL   AS KAPPL        " 어플리케이션
*-> CCM : 20.04.2023 15:41:54 / ZLSGSD4
*         K~VBELN   AS VBELN2       " BILLING DOC
*         K~POSNR   AS POSNR2       " item NO
         M~VBELN   AS VBELN2       " BILLING DOC
         M~POSNR   AS POSNR2       " item NO
*<-
         B~KNUMH   AS KNUMH        " 조건번호
         B~KSCHL   AS KSCHL        " 조건유형
         APPENDING CORRESPONDING FIELDS OF TABLE GT_OUTAB
         FROM KONA AS A INNER JOIN KOTE911 AS B
           ON A~KNUMA EQ B~KNUMA
           INNER JOIN KONP AS C
           ON B~KNUMH EQ C~KNUMH
           INNER JOIN KNA1 AS D
           ON A~BONEM EQ D~KUNNR
           INNER JOIN KNA1 AS E
           ON B~KUNNR EQ E~KUNNR
           INNER JOIN KONH AS F
           ON B~KNUMH EQ F~KNUMH
*-> CCM : 20.04.2023 15:31:18 / ZLSGSD4
*           INNER JOIN VBOX AS K
*           ON   F~KAPPL EQ K~KAPPL
*            AND F~KOTABNR EQ K~KOTABNR
*            AND F~VAKEY   EQ K~VAKEY
           INNER JOIN VBRK AS K
           ON A~KNUMA EQ K~KNUMA
           INNER JOIN VBRK AS L
           ON F~KAPPL EQ L~KAPPL
           INNER JOIN VBRP AS M
           ON K~VBELN EQ M~VBELN
*<-
          WHERE A~VKORG IN S_VKORG
           AND  A~VTWEG IN S_VTWEG
           AND  A~SPART IN S_SPART
*           and  a~vkbur in s_vkbur
*           and  a~vkgrp in s_vkgrp
           AND  A~BONEM IN S_BONEM
           AND  A~KNUMA IN S_KNUMA
           AND  A~BOSTA IN S_BOSTA
           AND  A~DATBI >= GV_DATE
           AND  A~DATAB <= GV_DATE
           AND  C~LOEVM_KO EQ SPACE
*-> CCM : 20.04.2023 15:42:11 / ZLSGSD4
           AND  K~DRAFT = SPACE
           AND  M~DRAFT = SPACE
           AND  L~DRAFT = SPACE.
*<-

** Table 추가 : kote912, kote913
  SELECT A~VKORG   AS VKORG
         A~VTWEG   AS VTWEG
         A~SPART   AS SPART
         A~VKBUR   AS VKBUR
         A~VKGRP   AS VKGRP
         A~BONEM   AS BONEM        " Agent
         D~NAME1   AS NAME         " Agent명
         B~KUNNR   AS KUNNR        " 고객
         E~NAME1   AS NAME1        " 고객명
         A~KNUMA   AS KNUMA        " 계약 NO
         A~BOTEXT  AS BOTEXT       " 계약명
         A~BOSTA   AS BOSTA        " 계약상태
         A~WAERS   AS WAERS        " 통화단위
*        c~kbetr   as kbetr        " RATE
         C~KBRUE   AS KBETR        " RATE        "윤방희 수정
         C~KONWA   AS KONWA        " RATE 단위
         C~KPEIN   AS KPEIN
         C~KMEIN   AS KMEIN
         A~DATAB   AS DATAB        " 효력발생일
         A~DATBI   AS DATBI        " 효력만료일
*-> CCM : 20.04.2023 15:42:30 / ZLSGSD4
*         F~VAKEY   AS VAKEY        " 변수키
*<-
         F~KOTABNR AS KOTABNR      " 조건 테이블
         F~KAPPL   AS KAPPL        " 어플리케이션
*-> CCM : 20.04.2023 15:42:46 / ZLSGSD4
*         K~VBELN   AS VBELN2       " BILLING DOC
*         K~POSNR   AS POSNR2       " item NO
         M~VBELN   AS VBELN2       " BILLING DOC
         M~POSNR   AS POSNR2       " item NO
*<-
         B~KNUMH   AS KNUMH        " 조건번호
         B~KSCHL   AS KSCHL        " 조건유형
          APPENDING CORRESPONDING FIELDS OF TABLE GT_OUTAB
          FROM KONA AS A INNER JOIN KOTE912 AS B
           ON A~KNUMA EQ B~KNUMA
           INNER JOIN KONP AS C
           ON B~KNUMH EQ C~KNUMH
           INNER JOIN KNA1 AS D
           ON A~BONEM EQ D~KUNNR
           INNER JOIN KNA1 AS E
           ON B~KUNNR EQ E~KUNNR
           INNER JOIN KONH AS F
           ON B~KNUMH EQ F~KNUMH
*-> CCM : 20.04.2023 15:31:36 / ZLSGSD4
*           INNER JOIN VBOX AS K
*           ON   F~KAPPL EQ K~KAPPL
*            AND F~KOTABNR EQ K~KOTABNR
*            AND F~VAKEY   EQ K~VAKEY
           INNER JOIN VBRK AS K
           ON A~KNUMA EQ K~KNUMA
           INNER JOIN VBRK AS L
           ON F~KAPPL EQ L~KAPPL
           INNER JOIN VBRP AS M
           ON K~VBELN EQ M~VBELN
*<-
          WHERE A~VKORG IN S_VKORG
           AND  A~VTWEG IN S_VTWEG
           AND  A~SPART IN S_SPART
*           and  a~vkbur in s_vkbur
*           and  a~vkgrp in s_vkgrp
           AND  A~BONEM IN S_BONEM
           AND  A~KNUMA IN S_KNUMA
           AND  A~BOSTA IN S_BOSTA
           AND  A~DATBI >= GV_DATE
           AND  A~DATAB <= GV_DATE
           AND  C~LOEVM_KO EQ SPACE
*-> CCM : 20.04.2023 15:43:05 / ZLSGSD4
          AND  K~DRAFT = SPACE
          AND  M~DRAFT = SPACE
          AND  L~DRAFT = SPACE.
*<-

  SELECT A~VKORG   AS VKORG
         A~VTWEG   AS VTWEG
         A~SPART   AS SPART
         A~VKBUR   AS VKBUR
         A~VKGRP   AS VKGRP
         A~BONEM   AS BONEM        " Agent
         D~NAME1   AS NAME         " Agent명
         B~KUNNR   AS KUNNR        " 고객
         E~NAME1   AS NAME1        " 고객명
         A~KNUMA   AS KNUMA        " 계약 NO
         A~BOTEXT  AS BOTEXT       " 계약명
         A~BOSTA   AS BOSTA        " 계약상태
         A~WAERS   AS WAERS        " 통화단위
*        c~kbetr   as kbetr        " RATE
         C~KBRUE   AS KBETR        " RATE        "윤방희 수정
         C~KONWA   AS KONWA        " RATE 단위
         C~KPEIN   AS KPEIN
         C~KMEIN   AS KMEIN
         A~DATAB   AS DATAB        " 효력발생일
         A~DATBI   AS DATBI        " 효력만료일
*-> CCM : 20.04.2023 15:43:20 / ZLSGSD4
*         F~VAKEY   AS VAKEY        " 변수키
*<-
         F~KOTABNR AS KOTABNR      " 조건 테이블
         F~KAPPL   AS KAPPL        " 어플리케이션
*-> CCM : 20.04.2023 15:43:30 / ZLSGSD4
*         K~VBELN   AS VBELN2       " BILLING DOC
*         K~POSNR   AS POSNR2       " item NO
         M~VBELN   AS VBELN2       " BILLING DOC
         M~POSNR   AS POSNR2       " item NO
*<-
         B~KNUMH   AS KNUMH        " 조건번호
         B~KSCHL   AS KSCHL        " 조건유형
          APPENDING CORRESPONDING FIELDS OF TABLE GT_OUTAB
          FROM KONA AS A INNER JOIN KOTE913 AS B
           ON A~KNUMA EQ B~KNUMA
           INNER JOIN KONP AS C
           ON B~KNUMH EQ C~KNUMH
           INNER JOIN KNA1 AS D
           ON A~BONEM EQ D~KUNNR
           INNER JOIN KNA1 AS E
           ON B~KUNNR EQ E~KUNNR
           INNER JOIN KONH AS F
           ON B~KNUMH EQ F~KNUMH
*-> CCM : 20.04.2023 15:31:52 / ZLSGSD4
*           INNER JOIN VBOX AS K
*           ON   F~KAPPL EQ K~KAPPL
*            AND F~KOTABNR EQ K~KOTABNR
*            AND F~VAKEY   EQ K~VAKEY
           INNER JOIN VBRK AS K
           ON A~KNUMA EQ K~KNUMA
           INNER JOIN VBRK AS L
           ON F~KAPPL EQ L~KAPPL
           INNER JOIN VBRP AS M
           ON K~VBELN EQ M~VBELN
*<-
          WHERE A~VKORG IN S_VKORG
           AND  A~VTWEG IN S_VTWEG
           AND  A~SPART IN S_SPART
*           and  a~vkbur in s_vkbur
*           and  a~vkgrp in s_vkgrp
           AND  A~BONEM IN S_BONEM
           AND  A~KNUMA IN S_KNUMA
           AND  A~BOSTA IN S_BOSTA
           AND  A~DATBI >= GV_DATE
           AND  A~DATAB <= GV_DATE
           AND  C~LOEVM_KO EQ SPACE
*-> CCM : 20.04.2023 15:43:50 / ZLSGSD4
           AND  K~DRAFT = SPACE
           AND  M~DRAFT = SPACE
           AND  L~DRAFT = SPACE.
*<-
***  기계 commission
  SELECT A~VKORG   AS VKORG
           A~VTWEG   AS VTWEG
           A~SPART   AS SPART
           A~VKBUR   AS VKBUR
           A~VKGRP   AS VKGRP
           A~BONEM   AS BONEM        " Agent
           D~NAME1   AS NAME         " Agent명
*         b~kunnr   as kunnr        " 고객
*         e~name1   as name1        " 고객명
           A~KNUMA   AS KNUMA        " 계약 NO
           A~BOTEXT  AS BOTEXT       " 계약명
           A~BOSTA   AS BOSTA        " 계약상태
           A~WAERS   AS WAERS        " 통화단위
*        c~kbetr   as kbetr        " RATE
           C~KBRUE   AS KBETR        " RATE        "윤방희 수정
           C~KONWA   AS KONWA        " RATE 단위
           C~KPEIN   AS KPEIN
           C~KMEIN   AS KMEIN
           A~DATAB   AS DATAB        " 효력발생일
           A~DATBI   AS DATBI        " 효력만료일
*-> CCM : 20.04.2023 15:44:07 / ZLSGSD4
*           F~VAKEY   AS VAKEY        " 변수키
*<-
           F~KOTABNR AS KOTABNR      " 조건 테이블
           F~KAPPL   AS KAPPL        " 어플리케이션
*-> CCM : 20.04.2023 15:44:23 / ZLSGSD4
*           K~VBELN   AS VBELN2       " BILLING DOC
*           K~POSNR   AS POSNR2       " item NO
           M~VBELN   AS VBELN2       " BILLING DOC
           M~POSNR   AS POSNR2       " item NO
*<-
           B~KNUMH   AS KNUMH        " 조건번호
           B~KSCHL   AS KSCHL        " 조건유형
            APPENDING CORRESPONDING FIELDS OF TABLE GT_OUTAB
            FROM KONA AS A INNER JOIN KOTE890 AS B
             ON A~KNUMA EQ B~KNUMA
             INNER JOIN KONP AS C
             ON B~KNUMH EQ C~KNUMH
             INNER JOIN KNA1 AS D
             ON A~BONEM EQ D~KUNNR
*           inner join kna1 as e
*           on b~ausfu eq e~kunnr
             INNER JOIN KONH AS F
             ON B~KNUMH EQ F~KNUMH
*-> CCM : 20.04.2023 15:37:48 / ZLSGSD4
*           INNER JOIN VBOX AS K
*           ON   F~KAPPL EQ K~KAPPL
*            AND F~KOTABNR EQ K~KOTABNR
*            AND F~VAKEY   EQ K~VAKEY
           INNER JOIN VBRK AS K
           ON A~KNUMA EQ K~KNUMA
           INNER JOIN VBRK AS L
           ON F~KAPPL EQ L~KAPPL
           INNER JOIN VBRP AS M
           ON K~VBELN EQ M~VBELN
*<-
            WHERE A~VKORG IN S_VKORG
             AND  A~VTWEG IN S_VTWEG
             AND  A~SPART IN S_SPART
*           and  a~vkbur in s_vkbur
*           and  a~vkgrp in s_vkgrp
             AND  A~BONEM IN S_BONEM
             AND  A~KNUMA IN S_KNUMA
             AND  A~BOSTA IN S_BOSTA
             AND  A~DATBI >= GV_DATE
             AND  A~DATAB <= GV_DATE
             AND  C~LOEVM_KO EQ SPACE
*-> CCM : 20.04.2023 15:45:38 / ZLSGSD4
             AND  K~DRAFT = SPACE
             AND  M~DRAFT = SPACE
             AND  L~DRAFT = SPACE.
*<-

** Request by 윤위원 : 2005-04-13
** 미지급전표생성시 사업영역을 Assign하기 위함.
  LOOP AT GT_OUTAB.

*    select  single gsber
*      into  gt_outab-gsber
*      from  znft0003
*     where  kokrs  =  '1000'
*       and  vkgrp  =  gt_outab-vkgrp.


** Request by 송준호k : 2006-05-02
** co 관리 테이블 변경 됨.

* [START] CSR Number : C20110905_58443
* 커미션 프로세스를 JS전선에도 적용 가능토록 변경
*   IF S_VKORG-LOW NE '2000'.

    SELECT SINGLE GSBER
      INTO GT_OUTAB-GSBER
      FROM ZCOTA031
     WHERE GJAHR = P_SPMON(4)
       AND KOKRS = S_VKORG-LOW
       AND VKGRP = GT_OUTAB-VKGRP.


    MODIFY  GT_OUTAB.

*    ENDIF.
* [END] CSR Number : C20110905_58443
    CLEAR  GT_OUTAB.



  ENDLOOP.

  GT_OUTABH[] = GT_OUTAB[].
  GT_OUTABI[] = GT_OUTAB[].

*-> CCM : 20.04.2023 15:46:47 / ZLSGSD4
  SORT GT_OUTABH BY BONEM KUNNR KNUMA.
*<-
  DELETE ADJACENT DUPLICATES FROM GT_OUTABH
         COMPARING BONEM KUNNR KNUMA.

  IF GT_OUTAB[] IS INITIAL.
    CALL FUNCTION 'WS_MSG'
      EXPORTING
        MSG_TYPE = 'I'
        TEXT     = '조건에 맞는 DATA가 없습니다.'
        TITL     = '검색결과'.
    EXIT.
  ENDIF.

ENDFORM.                    " READ_MAIN_DATA

*&---------------------------------------------------------------------*
*&      Form  READ_VBUK_DATA
*&---------------------------------------------------------------------*
FORM READ_VBUK_DATA .

  IF NOT GT_VBRK[] IS INITIAL.
*-> CCM : 20.04.2023 15:52:52 / ZLSGSD4
*    CLEAR : GT_VBUK, GT_VBUK[].
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_VBUK
*             FROM VBUK
*             FOR ALL ENTRIES IN GT_VBRK
*             WHERE VBELN = GT_VBRK-VBELN.
*<-
  ENDIF.

ENDFORM.                    " READ_VBUK_DATA

*&---------------------------------------------------------------------*
*&      Form  INTIALIZATION_DATA
*&---------------------------------------------------------------------*
FORM INTIALIZATION_DATA .

  CLEAR : GT_OUTAB, GT_OUTABH, GT_OUTABI,
          GT_HEADER, GT_ITEM, G_ITAB_T.
  REFRESH : GT_OUTAB, GT_OUTABH, GT_OUTABI,GR_SDATE,
            GT_HEADER, GT_ITEM, G_ITAB_T.

ENDFORM.                    " INTIALIZATION_DATA

*&---------------------------------------------------------------------*
*&      Form  READ_VBRP_DATA
*&---------------------------------------------------------------------*
FORM READ_VBRP_DATA .

  IF NOT GT_VBRK[] IS INITIAL.
    CLEAR : GT_VBRP, GT_VBRP[].
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE GT_VBRP
      FROM VBRP
       FOR ALL ENTRIES IN GT_VBRK
     WHERE VBELN = GT_VBRK-VBELN.
*-> MIG Table 추가 : 2023.08.21
    DATA: LT_VBRP LIKE STANDARD TABLE OF GT_VBRP,
          LS_VBRP LIKE LINE OF GT_VBRP.

    SELECT *
      FROM ZVBRP_R3
       FOR ALL ENTRIES IN @GT_VBRK
     WHERE VBELN = @GT_VBRK-VBELN
      INTO TABLE @DATA(LT_ZVBRP_R3).
    IF SY-SUBRC EQ 0.
      SORT GT_VBRP BY VBELN POSNR.
      LOOP AT LT_ZVBRP_R3 ASSIGNING FIELD-SYMBOL(<LS_ZVBRP_R3>).
        READ TABLE GT_VBRP WITH KEY VBELN = <LS_ZVBRP_R3>-VBELN POSNR = <LS_ZVBRP_R3>-POSNR BINARY SEARCH TRANSPORTING NO FIELDS.
        IF SY-SUBRC NE 0.
          CLEAR LS_VBRP.
          MOVE-CORRESPONDING <LS_ZVBRP_R3> TO LS_VBRP.
          APPEND LS_VBRP TO LT_VBRP.
        ENDIF.
      ENDLOOP.
      IF LT_VBRP[] IS NOT INITIAL.
        APPEND LINES OF LT_VBRP[] TO GT_VBRP[].
      ENDIF.
    ENDIF.

*<-
  ENDIF.

ENDFORM.                    " READ_VBRP_DATA

*&---------------------------------------------------------------------*
*&      Form  execute_fb08_bdc
*&---------------------------------------------------------------------*
FORM EXECUTE_FB08_BDC .

  DATA : LV_ERROR,
         LV_FLAG,
         LV_FLAG2,
         LV_FLAG3,
         LV_FLAG4,
         LV_KUNNR LIKE KNA1-KUNNR,
         LV_LIFNR LIKE KNA1-LIFNR.

  LOOP AT GT_HEADER WHERE BOX = 'X'.


*[START] CSR Number : C20120116_34374
*이미 지급전표가 생성되어 있는경우 미지급 전표 역분개 불가

* 전표 생성 완료 된것
    IF NOT GT_HEADER-AUGBL IS INITIAL.
      LV_FLAG3 = 'X'.
      EXIT.
    ENDIF.
** 부가세전표 생성 완료 된것 Check
*    if gt_header-buga_belnr+0(3) = '121'.
*      lv_flag4 = 'X'.
*      exit.
*    endif.
  ENDLOOP.

  IF LV_FLAG3 EQ 'X'.
    MESSAGE E002(ZSD1) WITH GT_HEADER-AUGBL
                            '지급전표가 존재합니다.'.
  ELSEIF LV_FLAG4 EQ 'X'.
    MESSAGE E001(ZSD1) WITH '매입부가세 전표가 존재합니다.'.
*[END]   CSR Number : C20120116_34374

  ELSE.
    CLEAR : LV_FLAG, LV_FLAG2.
    REFRESH GT_BDCDATA.

    LOOP AT GT_HEADER WHERE BOX = 'X'.

** c_hkont 계정 결정 수정 written by choi seok won
      PERFORM CHANGE_HKONT.
* 역분개전표생성 BDC 처리
      PERFORM FILL_FIELD_DATA_FB08.
      PERFORM CALL_TRANSACTION_FB08.

** Changed by SDC06 : 2005-07-12
      IF NOT GV_BELNR IS INITIAL  AND
         GV_BELNR+0(2) EQ '14'.    " 취소전표번호의 Number Range

* 분할 정산 오더 전표 번호 업데이트 및 거절사유 입력
        PERFORM CHANGE_SALES_DOC USING  GT_HEADER-VBELN
                                        '_'
                                        '_'
                              CHANGING LV_ERROR.
        PERFORM CALL_TRANSACTION_VA02 USING GT_HEADER-VBELN.

      ENDIF.

    ENDLOOP.

    PERFORM CALL_MESSAGE_SCREEN.

  ENDIF.


ENDFORM.                    " execute_fb08_bdc

*&---------------------------------------------------------------------*
*&      Form  execute_fb08_bdc2
*&---------------------------------------------------------------------*
FORM EXECUTE_FB08_BDC2 .

  DATA : LV_ERROR,
         LV_FLAG,
         LV_FLAG2,
         LV_FLAG3,
         LV_KUNNR LIKE KNA1-KUNNR,
         LV_LIFNR LIKE KNA1-LIFNR.

  LOOP AT GT_HEADER WHERE BOX = 'X'.

** 부가세전표의 생성여부 Check
*    if gt_header-buga_belnr = '비대상' or
*       gt_header-buga_belnr = '미완료' or
*       gt_header-buga_belnr is initial.
*      lv_flag3 = 'X'.
*      exit.
*    endif.

  ENDLOOP.

  IF LV_FLAG3 EQ 'X'.
    MESSAGE E001(ZSD1) WITH '부가세전표가 없습니다.'.
  ELSE.

    CLEAR : LV_FLAG, LV_FLAG2.
    REFRESH GT_BDCDATA.

    LOOP AT GT_HEADER WHERE BOX = 'X'.

      PERFORM CHANGE_HKONT.
*     역분개전표생성 BDC 처리
      PERFORM FILL_FIELD_DATA_FB08_2.
      PERFORM CALL_TRANSACTION_FB08_2.

    ENDLOOP.

    PERFORM CALL_MESSAGE_SCREEN.

  ENDIF.


ENDFORM.                    " execute_fb08_bdc2

*&---------------------------------------------------------------------*
*&      Form  read_knuma_data
*&---------------------------------------------------------------------*
FORM READ_KNUMA_DATA .

  RANGES : KNUMA FOR KONA-KNUMA.
  CLEAR : KNUMA, KNUMA[].

  LOOP AT S_KNUMA.
    KNUMA = S_KNUMA.
    APPEND KNUMA. CLEAR KNUMA.
  ENDLOOP.

  REFRESH S_KNUMA.
  CLEAR S_KNUMA.
  TABLES : ZV_VMVAF.

  CONCATENATE P_SPMON '01' INTO GV_DATE.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = GV_DATE
    IMPORTING
      LAST_DAY_OF_MONTH = GV_LDATE.

  CLEAR : SPMON_ITAB, SPMON_ITAB[],
          GT_VMVAF, GT_VMVAF[].
*->[CHG]-------------------------S 2026.02.04
  APPEND VALUE #( SIGN = 'I' OPTION = 'BT'
                  LOW  = P_SPMON && '01'
                  HIGH = GV_LDATE
                 ) TO GR_SDATE.
*-<[CHG]-------------------------E 2026.02.04

  SELECT Z~KNUMA
         A~KUNNR
         A~VBELN
    INTO CORRESPONDING FIELDS OF TABLE GT_VMVAF
    FROM ZSD0018T AS Z INNER JOIN VBAK AS A
                       ON Z~VBELN_SE = A~VBELN
                       INNER JOIN VBKD AS B
                       ON A~VBELN = B~VBELN
                      AND B~POSNR = '000000'
*->[CHG]-------------------------S 2026.02.04
                       INNER JOIN VBRK AS C
                       ON Z~VBELN = C~VBELN
*-<[CHG]-------------------------E 2026.02.04
   WHERE A~VKORG IN S_VKORG
     AND A~VTWEG IN S_VTWEG
     AND A~SPART IN S_SPART
     AND A~VKBUR IN S_VKBUR
     AND A~VKGRP IN S_VKGRP
     AND A~AUART EQ 'B3'
     AND A~KUNNR IN S_BONEM
*->[CHG]-------------------------S 2026.02.04
     AND B~FBUDA IN GR_SDATE
     AND C~FKDAT IN S_FKDAT
*     AND B~FBUDA EQ GV_LDATE
*-<[CHG]-------------------------E 2026.02.04
   ORDER BY A~VBELN.

*-> MIG Table 추가 : 2023.08.21
  SELECT Z~KNUMA
         A~KUNNR
         A~VBELN
  APPENDING CORRESPONDING FIELDS OF TABLE GT_VMVAF
    FROM  ZSD0018T AS Z INNER JOIN ZVBAK_R3 AS A
                      ON Z~VBELN_SE = A~VBELN
   WHERE A~VKORG IN S_VKORG
     AND A~VTWEG IN S_VTWEG
     AND A~SPART IN S_SPART
     AND A~VKBUR IN S_VKBUR
     AND A~VKGRP IN S_VKGRP
     AND A~AUART EQ 'B3'
     AND A~KUNNR IN S_BONEM
   ORDER BY A~VBELN.

  SORT GT_VMVAF BY VBELN.

  DELETE ADJACENT DUPLICATES FROM GT_VMVAF COMPARING VBELN.

  LOOP AT GT_VMVAF.
    S_KNUMA-SIGN   = 'I'.
    S_KNUMA-OPTION = 'EQ'.
    S_KNUMA-LOW    = GT_VMVAF-KNUMA.
    APPEND S_KNUMA.  CLEAR S_KNUMA.

    SPMON_ITAB-VBELN = GT_VMVAF-VBELN.
    SPMON_ITAB-FBUDA = GV_LDATE.
    APPEND SPMON_ITAB. CLEAR SPMON_ITAB.
  ENDLOOP.

ENDFORM.                    " read_knuma_data

*&---------------------------------------------------------------------*
*&      Form  execute_buga_bdc
*&---------------------------------------------------------------------*
FORM EXECUTE_BUGA_BDC .

  DATA : LV_ERROR,
         LV_FLAG,
         LV_FLAG2,
         LV_BONEM LIKE ZSDS002-BONEM,
         LV_KNUMA LIKE ZSDS002-KNUMA,
         LV_WAERK LIKE ZSDS002-WAERK.

  CLEAR : LV_BONEM, LV_KNUMA, LV_ERROR, LV_FLAG, LV_FLAG2, LV_WAERK.
  CLEAR : G_ITAB_T, G_ITAB_T[].

  READ TABLE GT_HEADER WITH KEY BOX = 'X'.

  CHECK SY-SUBRC = 0.

  LV_BONEM  =  GT_HEADER-BONEM.
  LV_KNUMA  =  GT_HEADER-KNUMA.
  LV_WAERK  =  GT_HEADER-WAERK.


*  loop at gt_header where bonem = lv_bonem
*                      and waerk = lv_waerk.
*
*     gt_header-box = 'X'.
*
*  endloop.
*
*  modify  gt_header.

  LOOP AT GT_HEADER WHERE BONEM = LV_BONEM
                      AND WAERK = LV_WAERK.

** 미지급전표 생성여부 확인.
    IF  GT_HEADER-BELNR IS INITIAL.
      LV_FLAG  =  'X'.
      EXIT.
    ENDIF.

** 대상 Agent Check.
    IF  GT_HEADER-BONEM+0(2)  =  '18'  OR
        GT_HEADER-BONEM+0(6)  =  '000018'.
    ELSE.
      LV_FLAG2  =  'X'.
      EXIT.
    ENDIF.

  ENDLOOP.

  IF  LV_FLAG  =  'X'.
    CLEAR GT_HEADER-BOX.
    MODIFY GT_HEADER TRANSPORTING BOX WHERE BOX = 'X'.
    MESSAGE E001(ZSD1) WITH
        '미지급전표가 생성되지 않은 계약건이 있습니다.'.
    EXIT.
  ENDIF.

  IF  LV_FLAG2  =  'X'.
    CLEAR GT_HEADER-BOX.
    MODIFY GT_HEADER TRANSPORTING BOX WHERE BOX = 'X'.
    MESSAGE E001(ZSD1) WITH '내수 Agent만 가능합니다.'.
    EXIT.
  ENDIF.

  LOOP AT GT_HEADER WHERE BONEM = LV_BONEM
                      AND WAERK = LV_WAERK.

    MOVE-CORRESPONDING  GT_HEADER  TO  G_ITAB_T.

    LOOP AT GT_ITEM WHERE KNUMA = GT_HEADER-KNUMA.

      MOVE-CORRESPONDING  GT_ITEM  TO  G_ITAB_T.

      G_ITAB_T-WRBTR  =  GT_ITEM-KWERT_K  *  -1.

      IF  GT_HEADER-WAERK  EQ  'KRW'.
        G_ITAB_T-K_WRBTR  =  GT_ITEM-KWERT_K  *  100.
      ELSE.
        G_ITAB_T-K_WRBTR  =  GT_ITEM-KWERT_K  *  GT_ITEM-KURRF.
      ENDIF.

      G_ITAB_T-K_WRBTR  =  G_ITAB_T-K_WRBTR  *  -1.

      IF  G_ITAB_T-BUGA_AMNT IS INITIAL.
        G_ITAB_T-BUGA_AMNT  =  G_ITAB_T-K_WRBTR  /  10.
      ELSE.
        G_ITAB_T-BUGA_AMNT  =  G_ITAB_T-K_WRBTR  /  10.
      ENDIF.

      G_ITAB_T-K_WAERK  =  'KRW'.

** 이유는 Header와 Item모두에 통화가 동일한 이름으로 되어있기때문에
** 강제로 Header에 있는 통화로 가져가기 위함.
      G_ITAB_T-C_WAERK  =  GT_HEADER-WAERK.

** 매출액통화를 Move
      G_ITAB_T-WAERK2  =  GT_ITEM-WAERK.

      APPEND  G_ITAB_T.

    ENDLOOP.

    CLEAR  G_ITAB_T.

  ENDLOOP.

  EXPORT P_MODE  TO MEMORY ID 'ZSDCSW'.
  EXPORT G_ITAB_T TO MEMORY ID 'ZSD1000'.
  EXPORT G_UCOMM  TO MEMORY ID 'ZSD1100'.

  SUBMIT ZSDR1000_S AND RETURN.

ENDFORM.                    " execute_buga_bdc

*&---------------------------------------------------------------------*
*&      Form  execute_buga_sum
*&---------------------------------------------------------------------*
FORM EXECUTE_BUGA_SUM .

  DATA : LV_ERROR,
         LV_FLAG,
         LV_FLAG2,
         LV_BONEM LIKE ZSDS002-BONEM,
         LV_KNUMA LIKE ZSDS002-KNUMA.
  CLEAR : LV_BONEM, LV_KNUMA, LV_ERROR, LV_FLAG, LV_FLAG2.
  CLEAR : G_ITAB_T, G_ITAB_T[].

  READ TABLE GT_HEADER WITH KEY BOX = 'X'.

  CHECK SY-SUBRC = 0.

*  lv_bonem  =  gt_header-bonem.
*  lv_knuma  =  gt_header-knuma.

*  loop at gt_header where bonem = lv_bonem.
  LOOP AT GT_HEADER WHERE BOX = 'X'.

    MOVE-CORRESPONDING  GT_HEADER  TO  G_ITAB_T.

    LOOP AT GT_ITEM WHERE KNUMA = GT_HEADER-KNUMA
                      AND KUNNR = GT_HEADER-KUNNR. "2023.07.19 ZITCS4HDEV01 - 추가

      MOVE-CORRESPONDING  GT_ITEM  TO  G_ITAB_T.

      G_ITAB_T-WRBTR  =  GT_ITEM-KWERT_K  *  -1.

      IF  GT_HEADER-WAERK  EQ  'KRW'.
        G_ITAB_T-K_WRBTR  =  GT_ITEM-KWERT_K  *  100.
      ELSE.
        G_ITAB_T-K_WRBTR  =  GT_ITEM-KWERT_K  *  GT_ITEM-KURRF.
      ENDIF.

      G_ITAB_T-K_WRBTR  =  G_ITAB_T-K_WRBTR  *  -1.

      IF  G_ITAB_T-BUGA_AMNT IS INITIAL.
        G_ITAB_T-BUGA_AMNT  =  G_ITAB_T-K_WRBTR  /  10.
      ELSE.
        G_ITAB_T-BUGA_AMNT  =  G_ITAB_T-K_WRBTR  /  10.
      ENDIF.

      G_ITAB_T-K_WAERK  =  'KRW'.

** 이유는 Header와 Item모두에 통화가 동일한 이름으로 되어있기때문에
** 강제로 Header에 있는 통화로 가져가기 위함.
      G_ITAB_T-C_WAERK  =  GT_HEADER-WAERK.

** 매출액통화를 Move
      G_ITAB_T-WAERK2  =  GT_ITEM-WAERK.

      APPEND  G_ITAB_T.

    ENDLOOP.

    CLEAR  G_ITAB_T.

  ENDLOOP.
  EXPORT P_MODE  TO MEMORY ID 'ZSDCSW'.
  EXPORT G_ITAB_T TO MEMORY ID 'ZSD1000'.
  EXPORT G_UCOMM  TO MEMORY ID 'ZSD1100'.


  SUBMIT ZSDR1000_S AND RETURN.

ENDFORM.                    " execute_buga_sum

*&---------------------------------------------------------------------*
*&      Form  execute_buga_bdc2
*&---------------------------------------------------------------------*
FORM EXECUTE_BUGA_BDC2 .

  DATA : LV_ERROR,
         LV_FLAG,
         LV_FLAG2,
         LV_BONEM LIKE ZSDS002-BONEM,
         LV_KNUMA LIKE ZSDS002-KNUMA.
  CLEAR : LV_BONEM, LV_KNUMA, LV_ERROR, LV_FLAG, LV_FLAG2.

** 정상적으로 수행이 되면 부가세전표관련 테이블 생성
  LOOP AT G_TMP_T.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = G_TMP_T-KNUMA
      IMPORTING
        OUTPUT = G_TMP_T-KNUMA.

*->[CHG]-------------------------S 2026.02.04
    LOOP AT GT_ITEM WHERE KNUMA    = G_TMP_T-KNUMA
                      AND VBELN_SE = G_TMP_T-VBELN.

*    LOOP AT GT_ITEM WHERE KNUMA = G_TMP_T-KNUMA.
*-<[CHG]-------------------------E 2026.02.04

      MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
      MOVE-CORRESPONDING  GT_ITEM  TO  G_ITAB_T.

      G_ITAB_T-BUGA_BELNR  =  SPACE.

      G_ITAB_T-WRBTR  =  GT_ITEM-KWERT_K  *  -1.

      IF  G_TMP_T-C_WAERK  EQ  'KRW'.
        G_ITAB_T-K_WRBTR  =  GT_ITEM-KWERT_K  *  100.
      ELSE.
        G_ITAB_T-K_WRBTR  =  GT_ITEM-KWERT_K  *  GT_ITEM-KURRF.
      ENDIF.

      G_ITAB_T-K_WRBTR  =  G_ITAB_T-K_WRBTR  *  -1.

      IF  G_ITAB_T-BUGA_AMNT IS INITIAL.
        G_ITAB_T-BUGA_AMNT  =  G_ITAB_T-K_WRBTR  /  10.
      ELSE.
        G_ITAB_T-BUGA_AMNT  =  G_ITAB_T-K_WRBTR  /  10.
      ENDIF.

      G_ITAB_T-K_WAERK  =  'KRW'.

** 이유는 Header와 Item모두에 통화가 동일한 이름으로 되어있기때문에
** 강제로 Header에 있는 통화로 가져가기 위함.
      G_ITAB_T-C_WAERK  =  G_TMP_T-C_WAERK.

** 매출액통화를 Move
      G_ITAB_T-WAERK2  =  GT_ITEM-WAERK.

      APPEND  G_ITAB_T.
      CLEAR  G_ITAB_T.

    ENDLOOP.

  ENDLOOP.

  CLEAR : G_ZSD0016T.
  REFRESH : G_ZSD0016T.

  LOOP AT G_ITAB_T.

    MOVE-CORRESPONDING  G_ITAB_T  TO  G_ZSD0016T.
    G_ZSD0016T-WAERK  =  G_ITAB_T-C_WAERK.

    G_ZSD0016T-AEDAT  =  SY-DATUM.
    G_ZSD0016T-AENAM  =  SY-UNAME.

*    append  g_zsd0016t.
    COLLECT  G_ZSD0016T.
    CLEAR  G_ZSD0016T.

  ENDLOOP.

  MODIFY ZSD0016T FROM TABLE G_ZSD0016T.

  IF  SY-SUBRC  EQ  0.
    COMMIT WORK.
    MESSAGE S000 WITH '저장을 완료하였습니다'.
  ELSE.
    ROLLBACK WORK.
    MESSAGE S000 WITH '저장에 실패하였습니다'.
  ENDIF.

  CLEAR : G_ITAB_T, G_ITAB_T[],
          G_ZSD0016T, G_ZSD0016T[].

ENDFORM.                    " execute_buga_bdc2
*&---------------------------------------------------------------------*
*&      Form  CALL_DETAIL_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_DETAIL_LIST .

  CLEAR : GT_DETAIL, GT_DETAIL[].

  LOOP AT GT_HEADER WHERE BOX = 'X'.
*->[CHG]-------------------------S 2026.02.04
    LOOP AT GT_ITEM WHERE KNUMA = GT_HEADER-KNUMA
                      AND VBELN_SE = GT_HEADER-VBELN
                      AND FBUDA = GT_HEADER-FBUDA.
*    LOOP AT GT_ITEM WHERE KNUMA = GT_HEADER-KNUMA
*                      AND FBUDA = GT_HEADER-FBUDA.
*-<[CHG]-------------------------E 2026.02.04
      MOVE-CORRESPONDING GT_ITEM TO GT_DETAIL.

      GT_DETAIL-KNUMA = GT_HEADER-KNUMA.
      GT_DETAIL-BONEM = GT_HEADER-BONEM.
      GT_DETAIL-NAME  = GT_HEADER-NAME.
      GT_DETAIL-KUNNR = GT_HEADER-KUNNR.
      GT_DETAIL-NAME1 = GT_HEADER-NAME1.
      GT_DETAIL-BELNR = GT_HEADER-BELNR.
      GT_DETAIL-VBELN = GT_HEADER-VBELN.

      APPEND GT_DETAIL.

    ENDLOOP.
  ENDLOOP.

  EXPORT GT_DETAIL TO MEMORY ID 'ZSDR1000_D'.
  SUBMIT ZSDR1000_D AND RETURN.

ENDFORM.                    " CALL_DETAIL_LIST
*&---------------------------------------------------------------------*
*& Form READ_MAIN_DATA_HANA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM READ_MAIN_DATA_HANA .

  CLEAR : GT_OUTAB, GT_OUTAB[].

  SELECT A~VKORG   AS VKORG
         A~VTWEG   AS VTWEG
         A~SPART   AS SPART
*->[CHG]-------------------------S
*         A~VKBUR   AS VKBUR
*         A~VKGRP   AS VKGRP
*-<[CHG]-------------------------E
         A~BONEM   AS BONEM        " Agent
         D~NAME1   AS NAME         " Agent명
         K~KUNAG   AS KUNNR        " 고객
         E~NAME1   AS NAME1        " 고객명
         A~KNUMA   AS KNUMA        " 계약 NO
         A~BOTEXT  AS BOTEXT       " 계약명
         A~BOSTA   AS BOSTA        " 계약상태
         A~WAERS   AS WAERS        " 통화단위
         C~KBETR   AS KBETR        " RATE        "윤방희 수정
         C~WAERS   AS KONWA        " RATE 단위
         C~KPEIN   AS KPEIN
         C~KMEIN   AS KMEIN
         A~DATAB   AS DATAB        " 효력발생일
         A~DATBI   AS DATBI        " 효력만료일
*         F~KOTABNR AS KOTABNR      " 조건 테이블
         C~KAPPL   AS KAPPL        " 어플리케이션
         M~VBELN   AS VBELN2       " BILLING DOC
         M~POSNR   AS POSNR2       " item NO
*->[CHG]-------------------------S
         M~VKBUR   AS VKBUR
         M~VKGRP   AS VKGRP
*-<[CHG]-------------------------E
         C~KNUMH   AS KNUMH        " 조건번호
         C~KSCHL   AS KSCHL        " 조건유형

         G~KOSRT
         APPENDING CORRESPONDING FIELDS OF TABLE GT_OUTAB
         FROM ZKONA AS A  INNER JOIN KNA1 AS D
                          ON A~BONEM EQ D~KUNNR
                          INNER JOIN ZSD0018T AS Z
                          ON  A~KNUMA EQ Z~KNUMA
*->[CHG]-------------------------S 2026.02.04
                          INNER JOIN VBKD AS Y
                          ON Z~VBELN_SE = Y~VBELN
                         AND Y~POSNR = '000000'
*-<[CHG]-------------------------E 2026.02.04
                          INNER JOIN VBRK AS K
                          ON K~VBELN EQ Z~VBELN
                          INNER JOIN VBRP AS M
                          ON Z~VBELN EQ M~VBELN
                         AND Z~POSNR EQ M~POSNR
                          INNER JOIN KNA1 AS E
                          ON K~KUNAG EQ E~KUNNR
                          INNER JOIN KONV AS C
                          ON M~KNUMV_ANA = C~KNUMV
                         AND M~POSNR     = C~KPOSN
                          INNER JOIN KONH AS G
                          ON C~KNUMH = G~KNUMH AND
                             Z~KNUMA = G~KOSRT


         WHERE A~VKORG IN S_VKORG
          AND  A~VTWEG IN S_VTWEG
          AND  A~SPART IN S_SPART
*->[CHG]-------------------------S
          AND  M~VKBUR IN S_VKBUR
          AND  M~VKGRP IN S_VKGRP
*          AND  A~VKBUR IN S_VKBUR
*          AND  A~VKGRP IN S_VKGRP
*-<[CHG]-------------------------E
          AND  A~BONEM IN S_BONEM
          AND  A~KNUMA IN S_KNUMA
          AND  A~BOSTA IN S_BOSTA
          AND  A~DATBI >= GV_DATE
          AND  A~DATAB <= GV_DATE
          AND  C~KSCHL IN ('ZBO1','ZBO2','ZBO3','ZBO4','ZBO5','ZBO6','ZBO7','ZBO8')
          AND  K~DRAFT = SPACE
*->[CHG]-------------------------S 2026.02.04
          AND  Z~SPMON EQ P_SPMON
          AND  Y~FBUDA IN GR_SDATE
          AND  K~FKDAT IN S_FKDAT
*-<[CHG]-------------------------E 2026.02.04
          AND  M~DRAFT = SPACE.

*-> MIG Table 추가 : 2023.08.21
  DATA:
    LS_OUTAB     LIKE LINE OF GT_OUTAB,
    LT_OUTAB     LIKE STANDARD TABLE OF GT_OUTAB,
    LT_OUTAB_ADD LIKE STANDARD TABLE OF GT_OUTAB.

  SELECT A~VKORG   AS VKORG
         A~VTWEG   AS VTWEG
         A~SPART   AS SPART
*         A~VKBUR   AS VKBUR
*         A~VKGRP   AS VKGRP
         A~BONEM   AS BONEM        " Agent
         D~NAME1   AS NAME         " Agent명
         K~KUNAG   AS KUNNR        " 고객
         E~NAME1   AS NAME1        " 고객명
         A~KNUMA   AS KNUMA        " 계약 NO
         A~BOTEXT  AS BOTEXT       " 계약명
         A~BOSTA   AS BOSTA        " 계약상태
         A~WAERS   AS WAERS        " 통화단위
         C~KBETR   AS KBETR        " RATE        "윤방희 수정
         C~WAERS   AS KONWA        " RATE 단위
         C~KPEIN   AS KPEIN
         C~KMEIN   AS KMEIN
         A~DATAB   AS DATAB        " 효력발생일
         A~DATBI   AS DATBI        " 효력만료일
*         F~KOTABNR AS KOTABNR      " 조건 테이블
         C~KAPPL   AS KAPPL        " 어플리케이션
         M~VBELN   AS VBELN2       " BILLING DOC
         M~POSNR   AS POSNR2       " item NO
*->[CHG]-------------------------S
         M~VKBUR   AS VKBUR
         M~VKGRP   AS VKGRP
*-<[CHG]-------------------------E
         C~KNUMH   AS KNUMH        " 조건번호
         C~KSCHL   AS KSCHL        " 조건유형
         APPENDING CORRESPONDING FIELDS OF TABLE LT_OUTAB
         FROM ZKONA AS A  INNER JOIN KNA1 AS D
                          ON A~BONEM EQ D~KUNNR
                          INNER JOIN ZSD0018T AS Z
                          ON  A~KNUMA EQ Z~KNUMA
*->[CHG]-------------------------S 2026.02.04
                          INNER JOIN ZVBKD_R3 AS Y
                          ON Z~VBELN_SE = Y~VBELN
                         AND Y~POSNR = '000000'
*-<[CHG]-------------------------E 2026.02.04
                          INNER JOIN ZVBRK_R3 AS K
                          ON K~VBELN EQ Z~VBELN
                          INNER JOIN ZVBRP_R3 AS M
                          ON Z~VBELN EQ M~VBELN
                         AND Z~POSNR EQ M~POSNR
                          INNER JOIN KNA1 AS E
                          ON K~KUNAG EQ E~KUNNR
                          INNER JOIN KONV AS C
                          ON K~KNUMV EQ C~KNUMV
                         AND M~POSNR EQ C~KPOSN
                          INNER JOIN KONH AS G
                          ON C~KNUMH = G~KNUMH

         WHERE A~VKORG IN S_VKORG
          AND  A~VTWEG IN S_VTWEG
          AND  A~SPART IN S_SPART
*->[CHG]-------------------------S
          AND  M~VKBUR IN S_VKBUR
          AND  M~VKGRP IN S_VKGRP
*          AND  A~VKBUR IN S_VKBUR
*          AND  A~VKGRP IN S_VKGRP
*-<[CHG]-------------------------E
          AND  A~BONEM IN S_BONEM
          AND  A~KNUMA IN S_KNUMA
          AND  A~BOSTA IN S_BOSTA
          AND  A~DATBI >= GV_DATE
          AND  A~DATAB <= GV_DATE
*->[CHG]-------------------------S 2026.02.04
          AND  Z~SPMON EQ P_SPMON
          AND  Y~FBUDA IN GR_SDATE
          AND  K~FKDAT IN S_FKDAT
*-<[CHG]-------------------------E 2026.02.04
          AND  C~KSCHL IN ('ZBO1','ZBO2','ZBO3','ZBO4','ZBO5','ZBO6','ZBO7','ZBO8').
  IF SY-SUBRC EQ 0.
    SORT GT_OUTAB BY VBELN2 POSNR2.
    LOOP AT LT_OUTAB INTO LS_OUTAB.
      READ TABLE GT_OUTAB WITH KEY VBELN2 = LS_OUTAB-VBELN2 POSNR2 = LS_OUTAB-POSNR2 BINARY SEARCH TRANSPORTING NO FIELDS.
      IF SY-SUBRC NE 0.
        APPEND LS_OUTAB TO LT_OUTAB_ADD.
      ENDIF.
    ENDLOOP.
    IF LT_OUTAB_ADD[] IS NOT INITIAL.
      APPEND LINES OF LT_OUTAB_ADD[] TO GT_OUTAB[].
    ENDIF.
  ENDIF.


** 미지급전표생성시 사업영역을 Assign하기 위함.
  LOOP AT GT_OUTAB.

    SELECT SINGLE GSBER
      INTO GT_OUTAB-GSBER
      FROM ZCOTA031
     WHERE GJAHR = P_SPMON(4)
       AND KOKRS = S_VKORG-LOW
       AND VKGRP = GT_OUTAB-VKGRP.

    MODIFY  GT_OUTAB.
    CLEAR  GT_OUTAB.
  ENDLOOP.

  GT_OUTABH[] = GT_OUTAB[].
  GT_OUTABI[] = GT_OUTAB[].


  SORT GT_OUTABH BY BONEM KUNNR KNUMA.

  DELETE ADJACENT DUPLICATES FROM GT_OUTABH
         COMPARING BONEM KUNNR KNUMA.


  IF GT_OUTAB[] IS INITIAL.
    CALL FUNCTION 'WS_MSG'
      EXPORTING
        MSG_TYPE = 'I'
        TEXT     = '조건에 맞는 DATA가 없습니다.'
        TITL     = '검색결과'.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXECUTE_FB60_BDC_HANA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXECUTE_FB60_BDC_HANA .

  DATA : LV_ERROR,
         LV_FLAG,
         LV_FLAG2,
         LV_KUNNR LIKE KNA1-KUNNR,
         LV_LIFNR LIKE KNA1-LIFNR.

  CLEAR : LV_FLAG, LV_FLAG2.
  CLEAR : G_TMP_T, G_TMP_T[].

  REFRESH GT_BDCDATA.

*->2023.07.19 ZITCS4HDEV01 - 추가
  DATA : BEGIN OF LT_KNUMA OCCURS 0,
           KNUMA LIKE ZKONA-KNUMA,
*->[CHG]-------------------------S 2026.02.04
           VBELN LIKE VBAK-VBELN,
*-<[CHG]-------------------------E 2026.02.04
         END OF LT_KNUMA.
  CLEAR: LT_KNUMA, LT_KNUMA[].

  LOOP AT GT_HEADER WHERE BOX = 'X'.
    LT_KNUMA-KNUMA = GT_HEADER-KNUMA.
*->[CHG]-------------------------S 2026.02.04
    LT_KNUMA-VBELN = GT_HEADER-VBELN.
*-<[CHG]-------------------------E 2026.02.04
    COLLECT LT_KNUMA.
  ENDLOOP.

  LOOP AT LT_KNUMA.
*->[CHG]-------------------------S 2026.02.04
    LOOP AT GT_HEADER WHERE KNUMA = LT_KNUMA-KNUMA
                        AND VBELN = LT_KNUMA-VBELN.
*    LOOP AT GT_HEADER WHERE KNUMA = LT_KNUMA-KNUMA.
*-<[CHG]-------------------------E 2026.02.04
*<-
** c_blight value '3',  " 부가세전표 생성완료
** c_clight value '2',  " 미지급전표 생성완료
** c_flight value '1',  " 전표 생성 미완료
** 전표 생성 완료 된것
      IF GT_HEADER-LIGHTS NE C_FLIGHT.
        LV_FLAG = 'X'.
        EXIT.
      ENDIF.
*분할정산 오더가 없을경우 전표 생성 하면 안됨.
      IF GT_HEADER-VBELN IS INITIAL.
        LV_FLAG2 = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  IF LV_FLAG2 EQ ' '.
    IF LV_FLAG EQ ' '.

      LOOP AT LT_KNUMA.
*->[CHG]-------------------------S 2026.02.04
        LOOP AT GT_HEADER WHERE KNUMA = LT_KNUMA-KNUMA
                            AND VBELN = LT_KNUMA-VBELN.
*        LOOP AT GT_HEADER WHERE KNUMA = LT_KNUMA-KNUMA.
*-<[CHG]-------------------------E 2026.02.04

          CALL FUNCTION 'ENQUEUE_EVKONAE'
            EXPORTING
              MODE_KONA      = 'E'
              MANDT          = SY-MANDT
              KNUMA          = GT_HEADER-KNUMA
              X_KNUMA        = ' '
              _SCOPE         = '2'
              _WAIT          = ' '
              _COLLECT       = ' '
            EXCEPTIONS
              FOREIGN_LOCK   = 1
              SYSTEM_FAILURE = 2
              OTHERS         = 3.

          IF SY-SUBRC <> 0.
            MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.



          PERFORM CHANGE_HKONT.


** 정산오더의 영업사원과 대금청구문서의 영업사원이 다를경우
** 정산오더의 영업사원을 대금청구상의 영업사원으로 Change한다.
*        perform  change_order_va02.

          SELECT SINGLE LIFNR
            INTO LV_LIFNR
            FROM LFA1
           WHERE KUNNR = GT_HEADER-BONEM.

          PERFORM FILL_FIELD_DATA_NEW USING LV_LIFNR.

          IF NOT GV_BELNR IS INITIAL  AND
             GV_BELNR+0(2) EQ '12'.    " 전표번호의 Number Range
* 분할 정산 오더 전표 번호 업데이트 및 거절사유 입력
            PERFORM CHANGE_SALES_DOC USING  GT_HEADER-VBELN
                                            GV_BELNR
                                            C_AUGRU
                           CHANGING LV_ERROR.
            PERFORM CALL_TRANSACTION_VA02 USING GT_HEADER-VBELN.
          ELSE.

          ENDIF.

          CALL FUNCTION 'DEQUEUE_EVKONAE'
            EXPORTING
              MODE_KONA = 'E'
              MANDT     = SY-MANDT
              KNUMA     = GT_HEADER-KNUMA
              X_KNUMA   = ' '
              _SCOPE    = '3'
              _SYNCHRON = ' '
              _COLLECT  = ' '.

          EXIT.
        ENDLOOP.
      ENDLOOP.

      PERFORM EXECUTE_BUGA_BDC2.

      PERFORM CALL_MESSAGE_SCREEN.
    ELSE.
      CLEAR GT_HEADER-BOX.
      MODIFY GT_HEADER TRANSPORTING BOX WHERE BOX = 'X'.
      MESSAGE E001(ZSD1) WITH '발생된 전표가 이미 존재합니다.'.
    ENDIF.
  ELSE.
    CLEAR GT_HEADER-BOX.
    MODIFY GT_HEADER TRANSPORTING BOX WHERE BOX = 'X'.
    MESSAGE E001(ZSD1) WITH '분할정산오더가 존재하지않습니다.'.
  ENDIF.

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
  LT_FIELDS-FIELDNAME = 'S_VKORG-LOW'. "영업조직
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

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'S_VKORG-LOW'.
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
  LT_FIELDS-FIELDNAME = 'S_VKORG-LOW'. "영업조직
  APPEND LT_FIELDS.
  LT_FIELDS-FIELDNAME = 'S_VTWEG-LOW'. "유통경로
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

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'S_VKORG-LOW'.
  IF SY-SUBRC = 0.

    DATA(LV_VKORG) = LT_FIELDS-FIELDVALUE.
    TRANSLATE LV_VKORG TO UPPER CASE.
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LV_VKORG ) TO LR_VKORG.
  ENDIF.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'S_VTWEG-LOW'.
  IF SY-SUBRC = 0.
    DATA(LV_VTWEG) = LT_FIELDS-FIELDVALUE.
    TRANSLATE LV_VTWEG TO UPPER CASE.
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LV_VTWEG ) TO LR_VTWEG.
  ENDIF.

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
  LT_FIELDS-FIELDNAME = 'S_VKORG-LOW'. "영업조직
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

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'S_VKORG-LOW'.
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
FORM F4_VKGRP  USING   PV_FNAME.
  DATA : LT_RETURN LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE,
         LT_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

  RANGES : LR_VKORG FOR VBAK-VKORG,
           LR_VTWEG FOR VBAK-VTWEG,
           LR_SPART FOR VBAK-SPART,
           LR_VKBUR FOR VBAK-VKBUR,
           LR_VKGRP FOR VBAK-VKGRP,
           LR_BONEM FOR ZKONA-BONEM.

*- SELECTION SCREEN 값 읽어오기
  LT_FIELDS-FIELDNAME = 'S_VKORG-LOW'. "영업조직
  APPEND LT_FIELDS.
  LT_FIELDS-FIELDNAME = 'S_VKBUR-LOW'. "사업장
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

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'S_VKORG-LOW'.
  IF SY-SUBRC = 0.

    DATA(LV_VKORG) = LT_FIELDS-FIELDVALUE.
    TRANSLATE LV_VKORG TO UPPER CASE.
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LV_VKORG ) TO LR_VKORG.
  ENDIF.

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'S_VKBUR-LOW'.
  IF SY-SUBRC = 0.
    DATA(LV_VKBUR) = LT_FIELDS-FIELDVALUE.
    TRANSLATE LV_VKBUR TO UPPER CASE.
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LV_VKBUR ) TO LR_VKBUR.
  ENDIF.

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
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_INIT .
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_VKORG_6000 )
      TO S_VKORG.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_KNUMA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_KNUMA  USING    PV_FNAME.
  DATA : BEGIN OF LS_VALUE,
           KNUMA TYPE ZKONA-KNUMA,    "계약
           VKORG TYPE ZKONA-VKORG,    "영업조직
           VTWEG TYPE ZKONA-VTWEG,    "유통경로
           SPART TYPE ZKONA-SPART,    "제품군
           VKBUR TYPE ZKONA-VKBUR,    "영업팀
           VKGRP TYPE ZKONA-VKGRP,    "영업그룹
           BONEM TYPE ZKONA-BONEM,    "에이전트(리베이트 수령인)
         END OF LS_VALUE.
  DATA : LT_VALUE  LIKE TABLE OF LS_VALUE,
         LT_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.


  SELECT KNUMA
         VKORG
         VTWEG
         SPART
         VKBUR
         VKGRP
         BONEM
    INTO CORRESPONDING FIELDS OF TABLE LT_VALUE
    FROM ZKONA
   WHERE VKORG IN S_VKORG
     AND VTWEG IN S_VTWEG
     AND SPART IN S_SPART
*->[CHG]-------------------------S
*     AND VKBUR IN S_VKBUR
*     AND VKGRP IN S_VKGRP
*-<[CHG]-------------------------E
     AND BONEM IN S_BONEM.

*- Search Help 출력
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'KNUMA'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'  "'C'
    TABLES
      VALUE_TAB       = LT_VALUE
*     RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SCREEN_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_FIELDS
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_SCREEN_VALUE  TABLES   PT_FIELDS STRUCTURE DYNPREAD
                        USING PV_FIELD.


  DATA : LV_OPTION(6) VALUE 'OPTION',
         LV_LOW(3)    VALUE 'LOW',
         LV_SIGN(4)   VALUE 'SIGN',
         LV_HIGH(4)   VALUE 'HIGH',
         LV_FIELD(20).


*   CONCATENATE PV_FIELD LV_OPTION INTO LV_FIELD.
*   PT_FIELDS-FIELDNAME = LV_FIELD.
*   APPEND PT_FIELDS.
*   CLEAR PT_FIELDS.

  CONCATENATE PV_FIELD LV_LOW INTO LV_FIELD.
  PT_FIELDS-FIELDNAME = LV_FIELD.
  APPEND PT_FIELDS.
  CLEAR PT_FIELDS.

*   CONCATENATE PV_FIELD LV_SIGN INTO LV_FIELD.
*   PT_FIELDS-FIELDNAME = LV_FIELD.
*   APPEND PT_FIELDS.
*   CLEAR PT_FIELDS.
*
  CONCATENATE PV_FIELD LV_HIGH INTO LV_FIELD.
  PT_FIELDS-FIELDNAME = LV_FIELD.
  APPEND PT_FIELDS.
  CLEAR PT_FIELDS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_SCREEN .
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 EQ 'ZX1'.
      SCREEN-ACTIVE = 0.

    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_SPMON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_SPMON
*&---------------------------------------------------------------------*
FORM F4_SPMON  USING    P_FVAL.
  DATA:LV_SUBRC TYPE SY-SUBRC.

  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      ACTUAL_MONTH               = SY-DATLO(6)
    IMPORTING
      SELECTED_MONTH             = P_FVAL
      RETURN_CODE                = LV_SUBRC
    EXCEPTIONS
      FACTORY_CALENDAR_NOT_FOUND = 1
      HOLIDAY_CALENDAR_NOT_FOUND = 2
      MONTH_NOT_FOUND            = 3
      OTHERS                     = 4.
  IF SY-SUBRC <> 0.

  ENDIF.

ENDFORM.
