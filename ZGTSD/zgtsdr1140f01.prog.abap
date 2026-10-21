*&---------------------------------------------------------------------*
*&  Include           ZSDR0960F                                        *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  STATUS
*&---------------------------------------------------------------------*
FORM STATUS USING   RT_EXTAB  TYPE  SLIS_T_EXTAB.

  DATA: LS_EXTAB TYPE SLIS_EXTAB.

  REFRESH: RT_EXTAB.

*___기능개선 52912 - 커미션 이중지급을 방지하기 위해 지급제외 요청.
*  IF PA_VKORG <> '1000'.
*    LS_EXTAB = 'ZOUT'.
*    APPEND LS_EXTAB TO RT_EXTAB.
*
*    LS_EXTAB = 'ZCANC'.
*    APPEND LS_EXTAB TO RT_EXTAB.
*  ENDIF.

*-> CCM : 17.10.2023 11:36:55 / ZLSGSD3
*- 부가세 별도 처리 버튼 제외 처리
  LS_EXTAB = 'REQU2'.
  APPEND LS_EXTAB TO RT_EXTAB.
*<-

*___기능개선 52912
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

  DATA : P_UCOMM LIKE SY-UCOMM.
  DATA : LV_TEXT(100).
  READ TABLE G_ITEM_T INDEX RS_SELFIELD-TABINDEX.

  GV_UCOMM  =  RS_UCOMM.

  CASE RS_UCOMM.
    WHEN 'REQU'.         " 지급전표생성
      REFRESH GT_BDCMSG.
      PERFORM DETERMINE_BUPLA.
      PERFORM EXECUTE_BDC_DATA.
      PERFORM INTIALIZATION_DATA.
*      PERFORM READ_DATA_PROCESS.     "2023.07.20 ZITCS4HDEV01 - 주석
      PERFORM READ_DATA_PROCESS_HANA. "2023.07.20 ZITCS4HDEV01 - 추가
      PERFORM MODIFY_DATA_PROCESS.
      RS_SELFIELD-REFRESH = 'X'.

    WHEN 'REQU2'.        " 부가세지급전표생성
      REFRESH GT_BDCMSG.
      PERFORM DETERMINE_BUPLA.
      PERFORM EXECUTE_BDC_DATA2.
      PERFORM INTIALIZATION_DATA.
*      PERFORM READ_DATA_PROCESS.     "2023.07.20 ZITCS4HDEV01 - 주석
      PERFORM READ_DATA_PROCESS_HANA. "2023.07.20 ZITCS4HDEV01 - 추가
      PERFORM MODIFY_DATA_PROCESS.
      RS_SELFIELD-REFRESH = 'X'.

    WHEN 'REQU3'.         " 지급전표생성+부가세지급전표
      REFRESH GT_BDCMSG.
      PERFORM DETERMINE_BUPLA.
      PERFORM EXECUTE_BDC_DATA_REQU3.
      PERFORM INTIALIZATION_DATA.
*      PERFORM READ_DATA_PROCESS.     "2023.07.20 ZITCS4HDEV01 - 주석
      PERFORM READ_DATA_PROCESS_HANA. "2023.07.20 ZITCS4HDEV01 - 추가
      PERFORM MODIFY_DATA_PROCESS.
      RS_SELFIELD-REFRESH = 'X'.

*    when 'FB08' .        " 지급전표취소
*      refresh gt_bdcmsg.
*      perform execute_bdc_fb08_data.
*      perform intialization_data.
*      perform read_data_process.
*      perform modify_data_process.
*      rs_selfield-refresh = 'X'.
*
*    when 'FB08_2' .      " 부가세지급전표취소
*      refresh gt_bdcmsg.
*      perform execute_bdc_fb08_data2.
*      perform intialization_data.
*      perform read_data_process.
*      perform modify_data_process.
*      rs_selfield-refresh = 'X'.

    WHEN 'ZSEL' .        " 지급전표상세조회
      PERFORM CALL_DETAIL_LIST.
      PERFORM INTIALIZATION_DATA.
*      PERFORM READ_DATA_PROCESS.     "2023.07.20 ZITCS4HDEV01 - 주석
      PERFORM READ_DATA_PROCESS_HANA. "2023.07.20 ZITCS4HDEV01 - 추가
      PERFORM MODIFY_DATA_PROCESS.
      RS_SELFIELD-REFRESH = 'X'.

    WHEN '&IC1'.
      PERFORM DETAIL_CLICK USING RS_SELFIELD-TABINDEX
                                  RS_SELFIELD-FIELDNAME
                                  RS_SELFIELD-VALUE.

*___기능개선 52912 - 커미션 이중지급을 방지하기 위해 지급제외 요청.
    WHEN 'ZOUT'.
      PERFORM GET_ITEM_T.

      IF GV_ERROR IS INITIAL AND GV_ERROR2 IS INITIAL
                             AND GV_ERROR3 IS INITIAL.

        CALL SCREEN 5000 STARTING AT  10 10
                           ENDING AT 100 15.

      ELSEIF GV_ERROR IS NOT INITIAL.
        MESSAGE S002 WITH
        '지급완료설정/취소는' '한개의 미지급전표씩 처리 됩니다. '
        DISPLAY LIKE 'E'.

      ELSEIF GV_ERROR2 IS NOT INITIAL.
        MESSAGE S001 WITH
       '이미 지급완료설정이 되어 있습니다.'
       DISPLAY LIKE 'E'.

      ELSE.
        MESSAGE S002 WITH
        '이미 지급전표가 생성된 건이 포함된 미지급전표는'
        '지급완료설정이 불가능합니다.'
        DISPLAY LIKE 'E'.
      ENDIF.

      PERFORM INTIALIZATION_DATA.
*      PERFORM READ_DATA_PROCESS.     "2023.07.20 ZITCS4HDEV01 - 주석
      PERFORM READ_DATA_PROCESS_HANA. "2023.07.20 ZITCS4HDEV01 - 추가
      PERFORM MODIFY_DATA_PROCESS.
      RS_SELFIELD-REFRESH = 'X'.

    WHEN 'ZCANC'.
      PERFORM GET_ITEM_T.

      IF GV_ERROR IS INITIAL AND GV_ERROR2 IS INITIAL.

        CONCATENATE '미지급전표' G_ITEM_T-BELNR '의 지급완료설정을 취소'
                    '하시겠습니까?' INTO LV_TEXT.


        PERFORM POPUP_TO_COMFIRM USING '지급완료취소'
                                       LV_TEXT
                                       '1'
                                       GV_ANSWER.

        IF GV_ANSWER = '1'.
          PERFORM SET_ZSD0016T_DATA USING 2.

        ENDIF.


      ELSEIF GV_ERROR IS NOT INITIAL.
        MESSAGE S002 WITH
        '지급완료설정/취소는' '한개의 미지급전표씩 처리 됩니다. '
        DISPLAY LIKE 'E'.
      ELSE.
        MESSAGE S002 WITH
        '해당 미지급전표는' '지급완료설정이 되어있지 않습니다.'
        DISPLAY LIKE 'E'.
      ENDIF.

      PERFORM INTIALIZATION_DATA.
*      PERFORM READ_DATA_PROCESS.     "2023.07.20 ZITCS4HDEV01 - 주석
      PERFORM READ_DATA_PROCESS_HANA. "2023.07.20 ZITCS4HDEV01 - 추가
      PERFORM MODIFY_DATA_PROCESS.
      RS_SELFIELD-REFRESH = 'X'.
*___기능개선 52912

  ENDCASE.
ENDFORM.                    " USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  DETAIL_CLICK
*&---------------------------------------------------------------------*
FORM DETAIL_CLICK USING    P_TABINDEX P_FLDNAME P_VALUE.

  DATA : LV_ANLN2 LIKE ANLA-ANLN2 VALUE '0000',
         LV_BUKRS LIKE ANLA-BUKRS VALUE 'DSF'.

  CASE P_FLDNAME.
    WHEN 'BELNR'.
*      read table g_item_t index p_tabindex.
      READ TABLE G_HEADER_T INDEX P_TABINDEX.
      SET PARAMETER ID 'BLN' FIELD G_HEADER_T-BELNR.
      SET PARAMETER ID 'BUK' FIELD PA_VKORG.
      IF G_HEADER_T-FBUDA(4) <= 2023.
        SET PARAMETER ID 'GJR' FIELD '2023'.
      ELSE.
        SET PARAMETER ID 'GJR' FIELD G_HEADER_T-FBUDA(4).
      ENDIF.

      "      SET PARAMETER ID 'GJR' FIELD PA_SPMON(4).
      CALL TRANSACTION 'FB03'
           AND SKIP FIRST SCREEN.
    WHEN 'VBELN2'.
      READ TABLE G_ITEM_T INDEX P_TABINDEX.
      SET PARAMETER ID 'VF' FIELD G_ITEM_T-VBELN2.
      CALL TRANSACTION 'VF03'
           AND SKIP FIRST SCREEN.
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
  LS_FIELDCAT-FIELDNAME     = 'KUNAG'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_HEADER.
  LS_FIELDCAT-OUTPUTLEN     = 10.
  LS_FIELDCAT-SELTEXT_L     = '고객'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '6'.
  LS_FIELDCAT-FIELDNAME     = 'NAME1'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_HEADER.
  LS_FIELDCAT-OUTPUTLEN     = 20.
  LS_FIELDCAT-SELTEXT_L     = '고객명'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.


***20180112 추가/S
  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '7'.
  LS_FIELDCAT-FIELDNAME     = 'KUNAG2'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_HEADER.
  LS_FIELDCAT-OUTPUTLEN     = 10.
  LS_FIELDCAT-SELTEXT_L     = '납품처'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '8'.
  LS_FIELDCAT-FIELDNAME     = 'NAME2'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_HEADER.
  LS_FIELDCAT-OUTPUTLEN     = 20.
  LS_FIELDCAT-SELTEXT_L     = '납품처명'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.
*** 20180112 추가/E

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '9'.
  LS_FIELDCAT-EMPHASIZE     = 'X'.
  LS_FIELDCAT-HOTSPOT       = 'X'.
  LS_FIELDCAT-FIELDNAME     = 'BELNR'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_HEADER.
  LS_FIELDCAT-OUTPUTLEN     = 10.
  LS_FIELDCAT-SELTEXT_L     = '미지급전표'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '10'.
  LS_FIELDCAT-FIELDNAME     = 'WRBTR'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_HEADER.
  LS_FIELDCAT-OUTPUTLEN     = 18.
  LS_FIELDCAT-SELTEXT_L     = '미지급금액'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  LS_FIELDCAT-CFIELDNAME    = 'WAERS'.
  LS_FIELDCAT-CTABNAME      = 'G_HEADER_T'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '11'.
  LS_FIELDCAT-FIELDNAME     = 'WAERS'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_HEADER.
  LS_FIELDCAT-OUTPUTLEN     = 5.
  LS_FIELDCAT-SELTEXT_L     = '계약통화'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '12'.
  LS_FIELDCAT-FIELDNAME     = 'BUGA_AMNT'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_HEADER.
  LS_FIELDCAT-OUTPUTLEN     = 18.
  LS_FIELDCAT-SELTEXT_L     = '미지급(Tax)'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

** Item fieldcat

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '1'.
  LS_FIELDCAT-EMPHASIZE     = 'X'.
  LS_FIELDCAT-HOTSPOT       = 'X'.
  LS_FIELDCAT-FIELDNAME     = 'VKBUR'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 10.
  LS_FIELDCAT-SELTEXT_L     = '영업팀'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '2'.
  LS_FIELDCAT-EMPHASIZE     = 'X'.
  LS_FIELDCAT-HOTSPOT       = 'X'.
  LS_FIELDCAT-FIELDNAME     = 'VBELN2'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 10.
  LS_FIELDCAT-SELTEXT_L     = '대금청구NO'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '3'.
  LS_FIELDCAT-FIELDNAME     = 'NETWR'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 15.
  LS_FIELDCAT-SELTEXT_L     = '매출액'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '4'.
  LS_FIELDCAT-FIELDNAME     = 'WAERK'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 5.
  LS_FIELDCAT-SELTEXT_L     = '매출통화'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '5'.
  LS_FIELDCAT-FIELDNAME     = 'WRBTR'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 18.
  LS_FIELDCAT-SELTEXT_L     = '미지급금액'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  LS_FIELDCAT-CFIELDNAME    = 'WAERS'.
  LS_FIELDCAT-CTABNAME      = 'G_ITEM_T'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '6'.
  LS_FIELDCAT-FIELDNAME     = 'R_WRBTR'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 18.
  LS_FIELDCAT-SELTEXT_L     = '지급가능금액'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  LS_FIELDCAT-CFIELDNAME    = 'WAERS'.
  LS_FIELDCAT-CTABNAME      = 'G_ITEM_T'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '7'.
  LS_FIELDCAT-FIELDNAME     = 'WAERS'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 5.
  LS_FIELDCAT-SELTEXT_L     = '계약통화'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '8'.
  LS_FIELDCAT-FIELDNAME     = 'BUGA_AMNT'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 18.
  LS_FIELDCAT-SELTEXT_L     = '미지급(Tax)'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '9'.
  LS_FIELDCAT-FIELDNAME     = 'R_BUGA'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 18.
  LS_FIELDCAT-SELTEXT_L     = '지급가능(Tax)'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '10'.
  LS_FIELDCAT-FIELDNAME     = 'WRBTR2'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 18.
  LS_FIELDCAT-SELTEXT_L     = '누적지급액'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  LS_FIELDCAT-CFIELDNAME    = 'WAERS'.
  LS_FIELDCAT-CTABNAME      = 'G_ITEM_T'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '11'.
  LS_FIELDCAT-FIELDNAME     = 'BUGA'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 18.
  LS_FIELDCAT-SELTEXT_L     = '누적지급액(Tax)'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '12'.
  LS_FIELDCAT-FIELDNAME     = 'SUKUM'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 18.
  LS_FIELDCAT-SELTEXT_L     = '수금액'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '13'.
  LS_FIELDCAT-FIELDNAME     = 'YUBOM'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 18.
  LS_FIELDCAT-SELTEXT_L     = '유보금'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '14'.
  LS_FIELDCAT-FIELDNAME     = 'YUSUK'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 18.
  LS_FIELDCAT-SELTEXT_L     = '유보금수금액'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '15'.
  LS_FIELDCAT-FIELDNAME     = 'RETXT'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 10.
  LS_FIELDCAT-SELTEXT_L     = '반품'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

*___기능개선 52912 - 커미션 이중지급을 방지하기 위해 지급제외 요청.
  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '16'.
  LS_FIELDCAT-FIELDNAME     = 'ZOUT'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 17.
  LS_FIELDCAT-SELTEXT_L     = '지급완료상태 여부'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '17'.
  LS_FIELDCAT-FIELDNAME     = 'ZBELNR'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 15.
  LS_FIELDCAT-SELTEXT_L     = '커미션 환입전표'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-COL_POS       = '18'.
  LS_FIELDCAT-FIELDNAME     = 'ZMSG'.
  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
  LS_FIELDCAT-OUTPUTLEN     = 50.
  LS_FIELDCAT-SELTEXT_L     = '사유'.
  LS_FIELDCAT-DDICTXT       = 'L'.
  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

*___기능개선 52912

*  CLEAR LS_FIELDCAT.
*  LS_FIELDCAT-COL_POS       = '15'.
*  LS_FIELDCAT-FIELDNAME     = 'REERK'.
*  LS_FIELDCAT-TABNAME       = G_TABNAME_ITEM.
*  LS_FIELDCAT-OUTPUTLEN     = 5.
*  LS_FIELDCAT-SELTEXT_L     = '반품상계통화'.
*  LS_FIELDCAT-DDICTXT       = 'L'.
*  APPEND LS_FIELDCAT TO E01_LT_FIELDCAT.

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

  E05_LS_LAYOUT-LIGHTS_FIELDNAME  = P_LIGNAM.
  E05_LS_LAYOUT-LIGHTS_TABNAME    = G_TABNAME_ITEM.
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
  GS_KEYINFO-HEADER05 = 'KUNAG'.
  GS_KEYINFO-ITEM05   = 'KUNAG'.

  PERFORM E01_FIELDCAT_INIT    USING GT_FIELDCAT[].
*  perform e01_fieldcat_header  using gt_fieldcat[].
*  perform e01_fieldcat_item    using gt_fieldcat[].
  PERFORM E03_EVENTTAB_BUILD USING GT_EVENTS[].
  PERFORM E04_COMMENT_BUILD  USING GT_LIST_TOP_OF_PAGE[].
  PERFORM E07_SP_GROUP_BUILD USING GT_SP_GROUP[].
  PERFORM E05_LAYOUT_BUILD   USING GS_LAYOUT.     "wg. Parameters
  PERFORM ALV_SORT_BUILD.

* Call ABAP/4 List Viewer
  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = G_REPID
      I_CALLBACK_PF_STATUS_SET = G_STATUS_SET
      I_CALLBACK_USER_COMMAND  = G_USER_COMMAND
      IS_LAYOUT                = GS_LAYOUT
      IT_FIELDCAT              = GT_FIELDCAT[]
"     IT_EXCLUDING             = gt_excluding
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
*-> CCM : 17.10.2023 09:47:33 / ZLSGSD3
* TABLE 변경 KONA->ZKONA
  SELECT  KONA~VKORG          KONA~VTWEG
          KONA~SPART          KONA~VKBUR
          KONA~VKGRP          KONA~BONEM
          KONA~KNUMA          KONA~BOTEXT
          KONA~BOSTA          KONA~WAERS
          VBRK~VBELN AS VBELN2
          VBRK~KUNRG AS KUNAG
          VBRK~NETWR          VBRK~WAERK
          VBRK~NETWR          VBRK~WAERK
          ZSD0016T~WRBTR      ZSD0016T~BUGA_AMNT
          ZSD0016T~K_WAERK    ZSD0016T~BELNR
          ZSD0016T~VBELN      ZSD0016T~FBUDA
          ZSD0016T~BUGA_BELNR ZSD0016T~ZBELNR
          ZSD0016T~ZOUT       ZSD0016T~ZMSG
    INTO  CORRESPONDING FIELDS OF TABLE G_ITAB_T
    FROM  ZKONA AS KONA INNER JOIN ZSD0016T ON ZSD0016T~KNUMA = KONA~KNUMA
               INNER JOIN VBRK     ON VBRK~VBELN = ZSD0016T~VBELN2
   WHERE  KONA~VKORG  =  PA_VKORG
     AND  KONA~VTWEG  =  PA_VTWEG
     AND  KONA~SPART  =  PA_SPART
     AND  KONA~VKBUR  IN PA_VKBUR
     AND  KONA~VKGRP  IN PA_VKGRP
     AND  KONA~KNUMA  IN SO_KNUMA
     AND  KONA~BONEM  IN SO_BONEM
     AND  KONA~BOART  =  'Z001'
     AND  ZSD0016T~FBUDA  IN  PA_SPMON
     AND  VBRK~DRAFT  =  SPACE.
*<-

*  sort g_itab_t.
*
*  delete adjacent duplicates from g_itab_t.

  SORT G_ITAB_T BY VBELN.

*  delete adjacent duplicates from g_itab_t comparing vbeln.

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

** Changed by SDC06 : 2005-09-05
** 해외 Agent(38)의 경우는 부가세 전표가 없기때문에 Remark.
** 그리고 해외 Agent의 경우에는 부가세없기때문에 부가세 관련 금액을
** 0으로 한다.

*    if  g_itab_t-bonem+0(6)  =  '000018'  and
*        g_itab_t-buga_belnr  is initial.
*        delete  g_itab_t.
*    endif.

    IF  G_ITAB_T-BONEM+0(6)  =  '000038'.

      G_ITAB_T-BUGA_AMNT  =  0.
      G_ITAB_T-BUGA       =  0.
      G_ITAB_T-R_BUGA     =  0.

      MODIFY  G_ITAB_T.
      CLEAR  G_ITAB_T.

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

** 납품처코드
    SELECT SINGLE KUNNR
      INTO G_ITAB_T-KUNAG2
      FROM VBPA AS VBPA
      INNER JOIN VBRP AS VBRP ON VBRP~AUBEL EQ VBPA~VBELN
      WHERE VBRP~VBELN = G_ITAB_T-VBELN2
      AND VBPA~PARVW IN ('SH' , 'WE').

*-> MIG Table 추가 : 2023.08.21
    IF SY-SUBRC NE 0.
      SELECT SINGLE KUNNR
       INTO G_ITAB_T-KUNAG2
       FROM ZVBPA_R3 AS VBPA
       INNER JOIN ZVBRP_R3 AS VBRP ON VBRP~AUBEL EQ VBPA~VBELN
       WHERE VBRP~VBELN = G_ITAB_T-VBELN2
         AND VBPA~PARVW IN ('SH' , 'WE').
    ENDIF.
*<-

** 고객명
    SELECT  SINGLE NAME1
      INTO  G_ITAB_T-NAME2
      FROM  KNA1
     WHERE  KUNNR  =  G_ITAB_T-KUNAG2.

** 수금액.
    PERFORM  SUKUM_AMNT_RTN.

** 유보금.
    PERFORM  YUBO_AMNT_RTN.

** 유보금수금액.
    PERFORM  YUBO_SUKUM_RTN.

    MODIFY  G_ITAB_T.
    CLEAR  G_ITAB_T.

  ENDLOOP.

** Header Data Setting.
  DATA : L_TEXT(20).
  CONCATENATE  PA_VKORG '( LS 전선 )'
         INTO  G_DATA1 SEPARATED BY SPACE.

  CLEAR  L_TEXT.
  SELECT  SINGLE VTEXT
    INTO  L_TEXT
    FROM  TVTWT
   WHERE  SPRAS  =  SY-LANGU
     AND  VTWEG  =  PA_VTWEG.

  CONCATENATE  PA_VTWEG '( ' L_TEXT ' )'
         INTO  G_DATA2 SEPARATED BY SPACE.

  CLEAR  L_TEXT.
  SELECT  SINGLE VTEXT
    INTO  L_TEXT
    FROM  TSPAT
   WHERE  SPRAS  =  SY-LANGU
     AND  SPART  =  PA_SPART.

  CONCATENATE  PA_SPART '( ' L_TEXT ' )'
         INTO  G_DATA3 SEPARATED BY SPACE.

  READ TABLE G_ITAB_T INDEX 1.

  CONCATENATE  PA_VKBUR '( ' G_ITAB_T-BEZEI ' )'
         INTO  G_DATA4 SEPARATED BY SPACE.

  CONCATENATE  PA_VKGRP '( ' G_ITAB_T-BEZEI2 ' )'
         INTO  G_DATA5 SEPARATED BY SPACE.

ENDFORM.                    " data_sub_query

*&---------------------------------------------------------------------*
*&      Form  MODIFY_DATA_PROCESS
*&---------------------------------------------------------------------*
FORM MODIFY_DATA_PROCESS .

  DATA : LV_STBLG LIKE BKPF-STBLG.

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

*** Before
*    select  belnr2 buga_belnr wrbtr buga_amnt
*      into (g_itab_t-belnr2,      " 지급전표
*            g_itab_t-buga_belnr2, " 부가세지급전표
*            g_itab_t-wrbtr2,      " 지급금액
*            g_itab_t-buga)        " 지급금액(Tax)
*      from  zsd0017t
*     where  knuma  =  g_tmp_t-knuma
*       and  fbuda  =  g_tmp_t-fbuda
*       and  vbeln  =  g_tmp_t-vbeln
*       and  belnr  =  g_tmp_t-belnr
*       and  vbeln2 =  g_tmp_t-vbeln2.
*
*      append  g_itab_t.
*
*    endselect.
*
*    if  sy-subrc  ne  0.
*        append  g_itab_t.
*    endif.
*
*    clear : g_tmp_t, g_itab_t.

** After
    SELECT  SINGLE BELNR2 BUGA_BELNR
      INTO (G_ITAB_T-BELNR2,      " 지급전표
            G_ITAB_T-BUGA_BELNR2) " 부가세지급전표
      FROM  ZSD0017T
     WHERE  KNUMA  =  G_TMP_T-KNUMA
       AND  FBUDA  =  G_TMP_T-FBUDA
       AND  VBELN  =  G_TMP_T-VBELN
       AND  BELNR  =  G_TMP_T-BELNR
       AND  VBELN2 =  G_TMP_T-VBELN2.

    IF  SY-SUBRC  =  0.


*{ CHM2102-00226
      CLEAR : GT_ZSD0017T , GT_ZSD0017T[].

      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE GT_ZSD0017T
        FROM  ZSD0017T
       WHERE  KNUMA  =  G_TMP_T-KNUMA  "계약번호
         AND  FBUDA  =  G_TMP_T-FBUDA  "기준년월
         AND  VBELN  =  G_TMP_T-VBELN  "정산오더
         AND  BELNR  =  G_TMP_T-BELNR  "미지급전표
         AND  VBELN2 =  G_TMP_T-VBELN2."빌링

      LOOP AT GT_ZSD0017T.     "역분개 체크

        CLEAR : LV_STBLG.

        IF GT_ZSD0017T-FBUDA_MIG IS NOT INITIAL.
          SELECT SINGLE STBLG
            INTO LV_STBLG
            FROM BKPF
            WHERE BUKRS = PA_VKORG
            AND BELNR = GT_ZSD0017T-BELNR2
            AND GJAHR = GT_ZSD0017T-FBUDA2_MIG+0(4).
        ELSE.
          SELECT SINGLE STBLG
            INTO LV_STBLG
            FROM BKPF
            WHERE BUKRS = PA_VKORG
            AND   BELNR = GT_ZSD0017T-BELNR2
            AND   GJAHR = GT_ZSD0017T-FBUDA2+0(4).
        ENDIF.

        IF SY-SUBRC <> 0 . " 테이블에 없다면 아카이브 테이블

          SELECT SINGLE MANDT
            INTO SY-MANDT
            FROM ZARIXFI3
            WHERE  BUKRS = PA_VKORG
            AND   BELNR = GT_ZSD0017T-BELNR2
            AND   GJAHR = GT_ZSD0017T-FBUDA2+0(4)
            AND   STBLG = ' '.

          IF SY-SUBRC = 0 ."역분개 되지 않았다면
            G_ITAB_T-WRBTR2 = G_ITAB_T-WRBTR2 + GT_ZSD0017T-WRBTR.
            G_ITAB_T-BUGA = G_ITAB_T-BUGA + GT_ZSD0017T-BUGA_AMNT.
          ENDIF.

        ELSEIF LV_STBLG IS INITIAL. "역분개 안되어 있으면

          G_ITAB_T-WRBTR2 = G_ITAB_T-WRBTR2 + GT_ZSD0017T-WRBTR.
          G_ITAB_T-BUGA   = G_ITAB_T-BUGA   + GT_ZSD0017T-BUGA_AMNT.

        ELSE. "테이블에 있는데 역분개 되었으면.          "
          "무시
        ENDIF.
      ENDLOOP.

*      SELECT  SUM( WRBTR ) SUM( BUGA_AMNT )
*        INTO (G_ITAB_T-WRBTR2,      " 지급금액
*              G_ITAB_T-BUGA)        " 부가세지급금액(Tax)
*        FROM  ZSD0017T
*       WHERE  KNUMA  =  G_TMP_T-KNUMA
*         AND  FBUDA  =  G_TMP_T-FBUDA
*         AND  VBELN  =  G_TMP_T-VBELN
*         AND  BELNR  =  G_TMP_T-BELNR
*         AND  VBELN2 =  G_TMP_T-VBELN2.
*} CHM2102-00226

    ELSE.

      G_ITAB_T-BELNR2      = SPACE.
      G_ITAB_T-BUGA_BELNR2 = SPACE.
      G_ITAB_T-WRBTR2      = 0.
      G_ITAB_T-BUGA        = 0.

    ENDIF.

    APPEND  G_ITAB_T.
    CLEAR : G_TMP_T, G_ITAB_T.

  ENDLOOP.


  LOOP AT G_ITAB_T.

    MOVE-CORRESPONDING  G_ITAB_T  TO  G_HEADER_T.
    COLLECT  G_HEADER_T.

    MOVE-CORRESPONDING  G_ITAB_T  TO  G_ITEM_T.

    IF  NOT G_ITAB_T-BELNR2 IS INITIAL  OR
        G_ITAB_T-BELNR2  NE  SPACE.

      IF  NOT G_ITAB_T-BUGA_BELNR2 IS INITIAL  OR
          G_ITAB_T-BUGA_BELNR2  NE  SPACE.

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

*___기능개선 52912 - 커미션 이중지급을 방지하기 위해 지급제외 요청.
*___지급완료설정된 경우 지급된 것으로 변경
    IF G_ITAB_T-ZOUT = 'X'.

      G_ITEM_T-LIGHTS = C_CLIGHT.

    ENDIF.

*___기능개선 52912

    APPEND  G_ITEM_T.

    CLEAR : G_HEADER_T, G_ITEM_T, G_ITAB_T.

  ENDLOOP.

  DATA : L_CALC_AMNT  LIKE BSID-WRBTR,
         L_CALC_AMNT2 LIKE BSID-WRBTR,
         L_CALC_RATE  LIKE BSID-WRBTR.

  CLEAR : L_CALC_AMNT, L_CALC_AMNT2, L_CALC_RATE.


** 지급가능금액 Calc
  LOOP AT G_ITEM_T.

** 수금액 + 유보금 : l_calc_amnt.
    L_CALC_AMNT  =  G_ITEM_T-SUKUM  +  G_ITEM_T-YUBOM.
** 수금액 + 유보금수금액 : l_calc_amnt2.
    L_CALC_AMNT2  =  G_ITEM_T-SUKUM  +  G_ITEM_T-YUSUK.

** 경우 1 : 일괄지급 / 수금액으로 간주시
    IF  P_R21  =  'X'  AND
        P_R31  =  'X'.

      IF  L_CALC_AMNT  =  G_ITEM_T-NETWR.
        G_ITEM_T-R_WRBTR  =  G_ITEM_T-WRBTR - G_ITEM_T-WRBTR2.
        G_ITEM_T-R_BUGA   =  G_ITEM_T-BUGA_AMNT.
      ELSE.
        G_ITEM_T-R_WRBTR  =  0.
        G_ITEM_T-R_BUGA   =  0.
      ENDIF.

** 경우 2 : 일괄지급 / 미수금액으로 간주시
    ELSEIF  P_R21  =  'X'  AND
            P_R32  =  'X'.

      IF  L_CALC_AMNT2  =  G_ITEM_T-NETWR.
        G_ITEM_T-R_WRBTR  =  G_ITEM_T-WRBTR - G_ITEM_T-WRBTR2.
        G_ITEM_T-R_BUGA   =  G_ITEM_T-BUGA_AMNT.
      ELSE.
        G_ITEM_T-R_WRBTR  =  0.
        G_ITEM_T-R_BUGA   =  0.
      ENDIF.

** 경우 3 : 수금율만큼지급 / 수금액으로 간주시
    ELSEIF  P_R22  =  'X'  AND
            P_R31  =  'X'.

      IF  L_CALC_AMNT  =  0  OR
          G_ITEM_T-NETWR  =  0.
        L_CALC_RATE  =  0.
      ELSE.
        L_CALC_RATE  =  L_CALC_AMNT  /  G_ITEM_T-NETWR.
      ENDIF.

* 윤방희 수정
      G_ITEM_T-R_WRBTR =  ( ( L_CALC_AMNT  *  G_ITEM_T-WRBTR ) /
                              G_ITEM_T-NETWR ) -  G_ITEM_T-WRBTR2.
      G_ITEM_T-R_BUGA = ( ( L_CALC_AMNT  *  G_ITEM_T-BUGA_AMNT ) /
                              G_ITEM_T-NETWR ) -  G_ITEM_T-BUGA.
*            g_item_t-r_wrbtr  =  ( l_calc_rate  *  g_item_t-wrbtr )
*                                 -  g_item_t-wrbtr2.
*            g_item_t-r_buga   =  ( l_calc_rate  *  g_item_t-buga_amnt )
*                                 -  g_item_t-buga.

** 경우 4 : 수금율만큼지급 / 미수금액으로 간주시
    ELSEIF  P_R22  =  'X'  AND
            P_R32  =  'X'.

      IF  L_CALC_AMNT2  =  0  OR
          G_ITEM_T-NETWR  =  0.
        L_CALC_RATE  =  0.
      ELSE.
        L_CALC_RATE  =  L_CALC_AMNT2  /  G_ITEM_T-NETWR.
      ENDIF.

      G_ITEM_T-R_WRBTR  = ( ( L_CALC_AMNT2  *  G_ITEM_T-WRBTR ) /
                             G_ITEM_T-NETWR ) -  G_ITEM_T-WRBTR2.
      G_ITEM_T-R_BUGA = ( ( L_CALC_AMNT2  * G_ITEM_T-BUGA_AMNT ) /
                            G_ITEM_T-NETWR ) -  G_ITEM_T-BUGA.
*            g_item_t-r_wrbtr  =  ( l_calc_rate  *  g_item_t-wrbtr )
*                                 -  g_item_t-wrbtr2.
*            g_item_t-r_buga   =  ( l_calc_rate  *  g_item_t-buga_amnt )
*                                 -  g_item_t-buga.

    ENDIF.

*___기능개선 52912 - 커미션 이중지급을 방지하기 위해 지급제외 요청.
*___지급완료설정상태인 경우 금액 변경
    IF G_ITEM_T-ZOUT = 'X'.
      G_ITEM_T-WRBTR2 = G_ITEM_T-WRBTR.
      G_ITEM_T-WRBTR = 0.
      G_ITEM_T-R_WRBTR = 0.
    ENDIF.
*___기능개선 52912

*기능개선 240109
*지급가능액/부가세지급가능액 모두 0원이면 그린라이트
    IF G_ITEM_T-R_BUGA = 0 AND G_ITEM_T-R_WRBTR = 0.
      IF G_ITEM_T-WRBTR2 = G_ITEM_T-WRBTR.
        G_ITEM_T-LIGHTS  =  C_BLIGHT.
      ENDIF.
    ENDIF.
*기능개선 240109

    MODIFY  G_ITEM_T.
    CLEAR : G_ITEM_T, L_CALC_AMNT, L_CALC_AMNT2, L_CALC_RATE.

  ENDLOOP.

* 지급완료 제외
  IF P_R01 = 'X'.
    DELETE G_ITEM_T WHERE LIGHTS  =  C_BLIGHT.


    LOOP AT G_HEADER_T.
*->[CHG]-------------------------S
      DATA(LV_INDEX) = SY-TABIX.
      IF LINE_EXISTS( G_ITEM_T[ BONEM = G_HEADER_T-BONEM
                                KNUMA = G_HEADER_T-KNUMA
                                FBUDA = G_HEADER_T-FBUDA
                                BELNR = G_HEADER_T-BELNR
                                KUNAG = G_HEADER_T-KUNAG ] ).
      ELSE.
        DELETE G_HEADER_T INDEX LV_INDEX.
      ENDIF.
      CLEAR LV_INDEX.
*      READ TABLE G_ITEM_T WITH KEY  BONEM = G_HEADER_T-BONEM.
*      IF SY-SUBRC <> 0 .
*        DELETE G_HEADER_T.
*      ENDIF.
*-<[CHG]-------------------------E
    ENDLOOP.

  ENDIF.

  FREE:LV_INDEX.
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
         L_GJAHR        LIKE BSEG-GJAHR,
         L_REAMT        LIKE VBRK-NETWR,  " 반품상계금액
         L_REERK        LIKE VBRK-WAERK,  " 반품상계통화
         L_SUM_REAMT    LIKE VBRK-NETWR.  " 반품상계금액

  DATA : L_SAD_SHKZG LIKE BSAD-SHKZG,
         LS_SGTXT    LIKE BSAD-SGTXT,
         L_SID_SHKZG LIKE BSID-SHKZG.

  CLEAR : L_DMBTR, L_SUM_DMBTR, L_WRBTR, L_SUM_WRBTR,
          L_BUDAT, L_AUGBL, L_GJAHR,
          L_SUM_DMBTR, L_SUM_WRBTR, L_SID_SHKZG,
          L_SUM_REAMT, L_REAMT,L_REERK.

  DATA : LV_HANA_BELNR LIKE BKPF-BELNR.

  CLEAR L_VBELN2_SGTXT.

  CONCATENATE  '%' G_ITAB_T-VBELN2 '%'  INTO  L_VBELN2_SGTXT.

*-> CCM : 20.10.2023 08:46:07 / ZLSGSD3
  IF G_ITAB_T-ECC_MIG = 'X'.
    SELECT SINGLE BELNR
      INTO LV_HANA_BELNR
      FROM ZFITC120
     WHERE BELNR_ECC = G_ITAB_T-VBELN2.
  ELSE.
    CLEAR : LV_HANA_BELNR.
  ENDIF.
*<-

*>> START - Archiving 관련변경 13 -> 20080311
  SELECT  BSID~DMBTR
          BSID~WRBTR
          BSID~SHKZG
          BSID~SGTXT
    INTO (L_DMBTR, L_WRBTR, L_SID_SHKZG, LS_SGTXT)
    FROM  BSID INNER JOIN BKPF
                     ON BSID~BUKRS = BKPF~BUKRS
                    AND BSID~BELNR = BKPF~BELNR
                    AND BSID~GJAHR = BKPF~GJAHR
   WHERE  BKPF~STBLG  =  ' '
     AND  BSID~KUNNR  =  G_ITAB_T-KUNAG
     AND  BSID~SGTXT  LIKE  L_VBELN2_SGTXT
     AND  BSID~UMSKZ  =  ' '
     AND  BSID~BLART  IN ('CC', 'CE', 'CF', 'CL', 'CJ', 'AB', 'CA', 'AG', 'TE', 'SA', 'CS', 'DA',
*-> CCM : 20.10.2023 08:54:57 / ZLSGSD3
                          'YY') "YY = ECC MIG 전표 유형
     AND  BSID~BELNR NE LV_HANA_BELNR. "매출전표는 제외처리
*<-


**  [START]C20080103_93754 "확인요망
    IF LS_SGTXT+19(10) = G_ITAB_T-VBELN2.

      IF L_SID_SHKZG = 'H'.
        L_SUM_DMBTR  = L_SUM_DMBTR + L_DMBTR.
        L_SUM_WRBTR  = L_SUM_WRBTR + L_WRBTR.
      ELSE.
        L_SUM_DMBTR  = L_SUM_DMBTR - L_DMBTR.
        L_SUM_WRBTR  = L_SUM_WRBTR - L_WRBTR.
      ENDIF.

    ENDIF.

    CLEAR : L_DMBTR, L_WRBTR, L_AUGBL, L_SID_SHKZG, LS_SGTXT.

  ENDSELECT.

*-- 아카이브 체크를 한 경우에만 AS 테이블에서 정보를 가지고 온다.
  IF NOT P_ARCV IS INITIAL.

    IF PA_SPMON < '200701'.

      SELECT  BSID~DMBTR BSID~WRBTR BSID~SHKZG BSID~SGTXT
        INTO (L_DMBTR, L_WRBTR, L_SID_SHKZG, LS_SGTXT)
        FROM  BSID
       WHERE  BSID~KUNNR =  G_ITAB_T-KUNAG
         AND  BSID~SGTXT LIKE  L_VBELN2_SGTXT
         AND  BSID~BLART IN ('CC', 'CE', 'CF', 'CL', 'CJ', 'AB', 'CA', 'AG', 'TE', 'SA', 'CS','DA')
         AND  BSID~UMSKZ =  ' '.

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

    ELSE.

      SELECT  BSID~DMBTR BSID~WRBTR BSID~SHKZG BSID~SGTXT
        INTO (L_DMBTR, L_WRBTR, L_SID_SHKZG, LS_SGTXT)
        FROM  BSID INNER JOIN ZARIXFI3 AS BKPF
                                   ON BSID~BUKRS = BKPF~BUKRS
                                  AND BSID~BELNR = BKPF~BELNR
                                  AND BSID~GJAHR = BKPF~GJAHR
       WHERE  BKPF~STBLG  =  ' '
         AND  BSID~KUNNR  =  G_ITAB_T-KUNAG
         AND  BSID~SGTXT  LIKE  L_VBELN2_SGTXT
         AND  BSID~BLART  IN ('CC', 'CE', 'CF', 'CL', 'CJ', 'AB', 'CA', 'AG', 'TE', 'SA', 'CS', 'DA')
         AND  BSID~UMSKZ  = ' '.

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
  ENDIF.

  IF L_SUM_DMBTR IS INITIAL.
    G_ITAB_T-K_SUKUM  =  0.
  ELSE.
    G_ITAB_T-K_SUKUM  =  L_SUM_DMBTR.
  ENDIF.

  IF L_SUM_WRBTR IS INITIAL.
    G_ITAB_T-SUKUM    =  0.
  ELSE.
    G_ITAB_T-SUKUM    =  L_SUM_WRBTR.
  ENDIF.
*>> END   - Archiving 관련변경 13 -> 20080311

  CLEAR : L_DMBTR, L_SUM_DMBTR,
          L_WRBTR, L_SUM_WRBTR,
          L_BUDAT, L_AUGBL, L_SGTXT, L_GJAHR,
          L_SUM_DMBTR, L_SUM_WRBTR, L_SAD_SHKZG.

*>> START - Archiving 관련변경 14 -> 20080311
  SELECT  BSAD~DMBTR
          BSAD~WRBTR
          BSAD~SGTXT
          BSAD~SHKZG
    INTO (L_DMBTR, L_WRBTR, L_SGTXT, L_SAD_SHKZG)
    FROM  BSAD INNER JOIN BKPF
                       ON BSAD~BUKRS = BKPF~BUKRS
                      AND BSAD~BELNR = BKPF~BELNR
                      AND BSAD~GJAHR = BKPF~GJAHR
   WHERE  BKPF~STBLG =  ' '
     AND  BSAD~KUNNR =  G_ITAB_T-KUNAG
     AND  BSAD~SGTXT LIKE  L_VBELN2_SGTXT
     AND  BSAD~UMSKZ =  ' '
     AND  BSAD~BLART IN ('CC', 'CE', 'CF', 'CL', 'CJ','AB', 'CA', 'AG', 'TE', 'SA', 'CS', 'DA',
*-> CCM : 20.10.2023 08:54:57 / ZLSGSD3
                         'YY') "YY = ECC MIG 전표 유형
    AND  BSAD~BELNR NE LV_HANA_BELNR. "매출전표는 제외처리
*<-

    IF  L_SGTXT+19(10)  EQ  G_ITAB_T-VBELN2.

      IF  L_AUGBL+0(3) NE '114'.
        IF L_SAD_SHKZG = 'H'.
          L_SUM_DMBTR  = L_SUM_DMBTR  +  L_DMBTR.
          L_SUM_WRBTR  = L_SUM_WRBTR  +  L_WRBTR.
        ELSE.
          L_SUM_DMBTR  = L_SUM_DMBTR  -  L_DMBTR.
          L_SUM_WRBTR  = L_SUM_WRBTR  -  L_WRBTR.
        ENDIF.
      ENDIF.

    ENDIF.

    CLEAR : L_DMBTR, L_WRBTR, L_SGTXT, L_SID_SHKZG.

  ENDSELECT.

*-- 아카이브 체크를 한 경우에만 AS 테이블에서 정보를 가지고 온다.
  IF NOT P_ARCV IS INITIAL.
* [START] CSR Number : C20111212_14315
* FAGL_GET_ARCH_FI_DOCUMENT 실제 BKPF데이터 접근(아카이빙)
* 05,06년도의 경우 BSAD만 가지고 판단함

    IF PA_SPMON < '200701'.
      SELECT  BSAD~DMBTR BSAD~WRBTR BSAD~SGTXT BSAD~SHKZG
        INTO (L_DMBTR, L_WRBTR, L_SGTXT, L_SAD_SHKZG)
        FROM  BSAD
       WHERE  BSAD~KUNNR  =  G_ITAB_T-KUNAG
         AND  BSAD~SGTXT  LIKE  L_VBELN2_SGTXT
         AND  BSAD~BLART  IN ('CC', 'CE', 'CF', 'CL', 'CJ','AB'
                             ,'CA', 'AG', 'TE', 'SA', 'CS','DA')
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
*[END] CSR Number : C20111212_14315

    ELSE.

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
                             ,'CA', 'AG', 'TE', 'SA', 'CS'
*  [START CSR : C20100830_28507 ]
*  //DA(고객전표) 추가
                           ,'DA')
*  [END CSR : C20100830_28507 ]

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
  ENDIF.
*>> END   - Archiving 관련변경 14 -> 20080311

*[START] CSR Number : C20120116_34382
*지급현황에 반품상계일 경우 반품에 대한 데이타 추가
  CONCATENATE  '%' G_ITAB_T-VBELN2 '%'  INTO  L_VBELN2_SGTXT.

  DATA  : L_BUKRS LIKE BSAD-BUKRS,
          L_KUNNR LIKE BSAD-KUNNR,
          L_BELNR LIKE BSAD-BELNR,
          L_SGTX1 LIKE BSAD-SGTXT,
          L_VBELN LIKE VBRK-VBELN.

  CLEAR : L_BUKRS, L_KUNNR,
          L_BELNR, L_GJAHR, L_SGTXT, L_VBELN.

  SELECT BSID~BUKRS
         BSID~KUNNR
         BSID~BELNR
         BSID~GJAHR
    INTO (L_BUKRS, L_KUNNR, L_BELNR, L_GJAHR)
    FROM  BSID INNER JOIN BKPF
                     ON BSID~BUKRS = BKPF~BUKRS
                    AND BSID~BELNR = BKPF~BELNR
                    AND BSID~GJAHR = BKPF~GJAHR
   WHERE  BKPF~STBLG =  ' '
     AND  BSID~KUNNR =  G_ITAB_T-KUNAG
     AND  BSID~SGTXT LIKE L_VBELN2_SGTXT
     AND  BSID~UMSKZ  = ' '
     AND  BSID~BLART IN ('CC', 'CE', 'CF', 'CL', 'CJ','AB', 'CA', 'AG', 'TE', 'SA', 'CS','DA',
*-> CCM : 20.10.2023 08:56:08 / ZLSGSD3
                         'YY') "YY = ECC MIG 전표 유형
    AND BSID~BELNR NE LV_HANA_BELNR.
*<-

    IF SY-SUBRC = 0.

      CLEAR : L_SGTX1,L_VBELN.

      SELECT SGTXT
        INTO L_SGTX1
        FROM BSAD
       WHERE BUKRS = L_BUKRS
         AND KUNNR = L_KUNNR
         AND BELNR = L_BELNR
         AND GJAHR = L_GJAHR.

        L_VBELN = L_SGTX1+19(10).

        SELECT SINGLE MANDT
          INTO SY-MANDT
          FROM VBRK
         WHERE VBELN = L_VBELN
           AND FKART = 'RE'.

        IF SY-SUBRC = 0.
          G_ITAB_T-RETXT = 'X'.
*-> MIG Table 추가 : 2023.08.21
        ELSE.
          SELECT SINGLE MANDT
            INTO SY-MANDT
            FROM ZVBRK_R3
           WHERE VBELN = L_VBELN
             AND FKART = 'RE'.
          IF SY-SUBRC = 0.
            G_ITAB_T-RETXT = 'X'.
          ENDIF.
*<-
        ENDIF.

      ENDSELECT.

    ENDIF.

    CLEAR : L_BUKRS, L_KUNNR, L_BELNR, L_GJAHR.

  ENDSELECT.

  SELECT  BSAD~BUKRS
          BSAD~KUNNR
          BSAD~BELNR
          BSAD~GJAHR
    INTO (L_BUKRS, L_KUNNR, L_BELNR, L_GJAHR)
    FROM  BSAD INNER JOIN BKPF
                       ON BSAD~BUKRS = BKPF~BUKRS
                      AND BSAD~BELNR = BKPF~BELNR
                      AND BSAD~GJAHR = BKPF~GJAHR
   WHERE  BKPF~STBLG  =  ' '
     AND  BSAD~KUNNR  =  G_ITAB_T-KUNAG
     AND  BSAD~SGTXT  LIKE  L_VBELN2_SGTXT
     AND  BSAD~UMSKZ  =  ' '
     AND  BSAD~BLART  IN ('CC', 'CE', 'CF', 'CL', 'CJ','AB', 'CA', 'AG', 'TE', 'SA', 'CS','DA',
*-> CCM : 20.10.2023 08:57:31 / ZLSGSD3
                          'YY')
     AND  BSAD~BELNR NE LV_HANA_BELNR.
*<-

    IF SY-SUBRC = 0.

      CLEAR : L_SGTX1,L_VBELN.

      SELECT SGTXT
        INTO L_SGTX1
        FROM BSAD
       WHERE BUKRS = L_BUKRS
         AND KUNNR = L_KUNNR
         AND BELNR = L_BELNR
         AND GJAHR = L_GJAHR.

        L_VBELN = L_SGTX1+19(10).
        SELECT SINGLE MANDT
          INTO SY-MANDT
          FROM VBRK
         WHERE VBELN = L_VBELN
           AND FKART = 'RE'.

        IF SY-SUBRC = 0.
          G_ITAB_T-RETXT = 'X'.

*-> MIG Table 추가 : 2023.08.21
        ELSE.
          SELECT SINGLE MANDT
            INTO SY-MANDT
            FROM ZVBRK_R3
           WHERE VBELN = L_VBELN
             AND FKART = 'RE'.

          IF SY-SUBRC = 0.
            G_ITAB_T-RETXT = 'X'.
          ENDIF.
*<-

        ENDIF.

      ENDSELECT.

    ENDIF.

    CLEAR : L_BUKRS, L_KUNNR, L_BELNR, L_GJAHR.

  ENDSELECT.
*[END]   CSR Number : C20120116_34382

  G_ITAB_T-K_SUKUM  =  G_ITAB_T-K_SUKUM  +  L_SUM_DMBTR.
  G_ITAB_T-SUKUM    =  G_ITAB_T-SUKUM    +  L_SUM_WRBTR.

  IF G_ITAB_T-SUKUM > G_ITAB_T-NETWR.
    G_ITAB_T-SUKUM = G_ITAB_T-NETWR.
  ENDIF.

  IF  G_ITAB_T-SUKUM = G_ITAB_T-SUKUM AND G_ITAB_T-VBELN2 = '8110146993'.
    G_ITAB_T-SUKUM = G_ITAB_T-NETWR.
  ENDIF.

*{ S4HANA  매출채권 반제완료로 미이관시 수금금액 완료처리
* 빌링이없고, ECC매출건이고, 이관전표가 없으면 반제완료로 인식
  SELECT SINGLE MANDT
    INTO SY-MANDT
    FROM VBRK
    WHERE VBELN EQ G_ITAB_T-VBELN2.
  IF SY-SUBRC <> 0 .
    SELECT SINGLE MANDT
      INTO SY-MANDT
      FROM ZVBRK_R3
      WHERE VBELN EQ G_ITAB_T-VBELN2.
    IF SY-SUBRC = 0.
      SELECT SINGLE MANDT
        INTO SY-MANDT
        FROM ZFITC120
        WHERE BELNR_ECC = G_ITAB_T-VBELN2.
      IF SY-SUBRC <> 0 .
        G_ITAB_T-SUKUM = G_ITAB_T-NETWR.
      ENDIF.
    ENDIF.
  ENDIF.


*}

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
      L_SUM_DMBTR = L_SUM_DMBTR + L_DMBTR.
      L_SUM_WRBTR = L_SUM_WRBTR + L_WRBTR.
    ENDIF.

    CLEAR : L_DMBTR, L_WRBTR, L_AUGBL.

  ENDSELECT.

  G_ITAB_T-K_YUBOM = G_ITAB_T-K_YUBOM + L_SUM_DMBTR.
  G_ITAB_T-YUBOM   = G_ITAB_T-YUBOM + L_SUM_WRBTR.

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
  DATA : LV_STBLG1 LIKE BKPF-STBLG,
         LV_STBLG2 LIKE BKPF-STBLG.
  CLEAR : G_IT_T, G_IT_T[].

  LOOP AT G_ITEM_T WHERE BOX = 'X'.

    MOVE-CORRESPONDING G_ITEM_T TO G_IT_T.

    CLEAR  L_CNT.

    CLEAR : GT_ZSD0017T , GT_ZSD0017T[].
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE GT_ZSD0017T
      FROM  ZSD0017T
     WHERE  KNUMA  =  G_ITEM_T-KNUMA "계약번호
       AND  FBUDA  =  G_ITEM_T-FBUDA "기준년월
       AND  VBELN  =  G_ITEM_T-VBELN "정산오더
       AND  BELNR  =  G_ITEM_T-BELNR "미지급전표
       AND  VBELN2 =  G_ITEM_T-VBELN2. "빌링

    LOOP AT GT_ZSD0017T.
      "역분개 체크
      CLEAR : LV_STBLG1, LV_STBLG2.
      SELECT SINGLE STBLG
        INTO LV_STBLG1
        FROM BKPF
       WHERE BUKRS = PA_VKORG
         AND BELNR = GT_ZSD0017T-BELNR2
         AND GJAHR = GT_ZSD0017T-FBUDA2+0(4).
      "아카이빙 테이블
      SELECT SINGLE STBLG
        INTO LV_STBLG2
        FROM ZARIXFI3
       WHERE BUKRS = PA_VKORG
         AND BELNR = GT_ZSD0017T-BELNR2
         AND GJAHR = GT_ZSD0017T-FBUDA2+0(4).

      IF LV_STBLG1 IS INITIAL AND LV_STBLG2 IS INITIAL.
        ADD 1 TO L_CNT.
      ENDIF.
    ENDLOOP.


    IF  L_CNT  <=  0.
      MESSAGE E001 WITH '선택하신 Data를 확인하세요.'.
    ENDIF.

    G_IT_T-KNUMA       =  G_ITEM_T-KNUMA.
    G_IT_T-FBUDA       =  G_ITEM_T-FBUDA.
    G_IT_T-VBELN       =  G_ITEM_T-VBELN.
    G_IT_T-BELNR       =  G_ITEM_T-BELNR.
    G_IT_T-VBELN2      =  G_ITEM_T-VBELN2.
    G_IT_T-BUGA_BELNR  =  G_ITEM_T-BUGA_BELNR.
    G_IT_T-WRBTR       =  G_ITEM_T-WRBTR.
    G_IT_T-BUGA_AMNT   =  G_ITEM_T-BUGA_AMNT.

*   c_blight value '3',  " 부가세전표 생성완료
*   c_clight value '2',  " 지급전표 생성완료
*   c_flight value '1',  " 전표 생성 미완료

    IF  G_ITEM_T-LIGHTS  =  C_FLIGHT.
      G_IT_T-GUBUN  =  '1'.
    ELSEIF  G_ITEM_T-LIGHTS  =  C_CLIGHT.
      G_IT_T-GUBUN  =  '2'.
    ELSEIF  G_ITEM_T-LIGHTS  =  C_BLIGHT.
      G_IT_T-GUBUN  =  '3'.
    ENDIF.

    APPEND  G_IT_T.
    CLEAR  G_IT_T.

  ENDLOOP.

  EXPORT G_IT_T TO MEMORY ID 'ZSD0960'.
  EXPORT P_MODE TO MEMORY ID 'ZSD0960_2'.
  EXPORT PA_VKORG TO MEMORY ID 'ZSD0960_3'.
  EXPORT P_ARCV TO MEMORY ID 'ZSD0960_4'.

  SUBMIT ZSDR0960_S AND RETURN.

ENDFORM.                    " call_detail_list

*&---------------------------------------------------------------------*
*&      Form  replace_process_rtn
*&---------------------------------------------------------------------*
FORM REPLACE_PROCESS_RTN .

  DATA : L_XLFZB LIKE LFB1-XLFZB.
  CLEAR : L_XLFZB.


  SELECT  SINGLE XLFZB
   INTO  L_XLFZB
   FROM  LFB1
  WHERE  LIFNR  =  G_ITEM_T-BONEM
    AND  BUKRS  =  PA_VKORG.



  CHECK L_XLFZB EQ 'X'.


  SELECT  EMPFK
    INTO  CORRESPONDING FIELDS OF TABLE G_LFZA_T
    FROM  LFZA
   WHERE  LIFNR  =  G_ITEM_T-BONEM
     AND  BUKRS  =  PA_VKORG.



  IF  NOT G_LFZA_T[] IS INITIAL.

    CALL SCREEN 3000 STARTING AT 15 7 ENDING AT 80 12.

    IF  SY-UCOMM  EQ  'ENTE'  AND
        G_H_EMPFK NE  SPACE.

    ENDIF.

  ENDIF.

ENDFORM.                    " replace_process_rtn

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
*-> CCM : 20.04.2023 16:35:52 / ZLSGSD4
*         L_KKBER         LIKE KNKK-KKBER.
*<-
  DATA : BEGIN OF IT_VALUE OCCURS 0,
           EMPFK LIKE  LFZA-EMPFK,
           NAME1 LIKE  LFA1-NAME1,
         END OF IT_VALUE.

*-> CCM : 20.04.2023 16:36:10 / ZLSGSD4
*  CLEAR: L_SELECTFIELD, L_FLD_TAB, L_LD_TABIX, L_KTOKD, L_KKBER.
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
*&      Form  DETERMINE_BUPLA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DETERMINE_BUPLA .

  DATA : LV_BELNR TYPE BELNR_D,
         LV_GJAHR TYPE GJAHR.

**[START]C20080215_17216
  CLEAR: C_BUPLA.

  SELECT SINGLE BUPLA
    INTO C_BUPLA
    FROM BSEG
   WHERE BUKRS  =  PA_VKORG
     AND BELNR  =  G_ITEM_T-BELNR
     AND GJAHR  =  G_ITEM_T-FBUDA+0(4)
     AND BUZEI = '001'
     AND SHKZG = 'H'.
**[END]C20080215_17216

*-> CCM : 20.10.2023 09:40:13 / ZLSGSD3
* ECC Mig 데이터는 001이 S
  IF C_BUPLA IS INITIAL.

    CLEAR : LV_BELNR, LV_GJAHR.

    SELECT SINGLE BELNR GJAHR
      INTO (LV_BELNR, LV_GJAHR)
      FROM ZFITC120
      WHERE BELNR_ECC = G_ITEM_T-VBELN2.

    IF SY-SUBRC = 0.
      SELECT SINGLE BUPLA
        INTO C_BUPLA
        FROM BSEG
       WHERE BUKRS = PA_VKORG
         AND BELNR = LV_BELNR
         AND GJAHR = LV_GJAHR
         AND BUZEI = '001'.
    ENDIF.

  ENDIF.
*<-

ENDFORM.                    " DETERMINE_BUPLA
*&---------------------------------------------------------------------*
*&      Form  GET_BLENR_GJR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_ITEM_T_BELNR  text
*      -->P_GT_BELNR2_FBUDA2(4)  text
*      -->P_1245   text
*      <--P_L_BELNR_GJR  text
*----------------------------------------------------------------------*
FORM GET_BLENR_GJR  USING    PA_BELNR
                             PA_GJAHR
                             PA_BUZEI
                    CHANGING PA_BELNR_GJR.


  DATA: L_BELNR LIKE BSEG-BELNR,
        L_BUZEI LIKE BSEG-BUZEI.

  CLEAR PA_BELNR_GJR.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = PA_BELNR
    IMPORTING
      OUTPUT = L_BELNR.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = PA_BUZEI
    IMPORTING
      OUTPUT = L_BUZEI.


  CONCATENATE L_BELNR PA_GJAHR L_BUZEI INTO PA_BELNR_GJR.

ENDFORM.                    " GET_BLENR_GJR

*&---------------------------------------------------------------------*
*&      Form  GET_ITEM_T
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ITEM_T .

  DATA: LV_CNT.
  DATA: LV_BELNR  LIKE ZSD0016T-BELNR,
        LV_BELNR2 LIKE ZSD0016T-BELNR.

  CLEAR: GV_ERROR, GV_ERROR2, GV_ERROR3.

  READ TABLE G_ITEM_T WITH KEY BOX = 'X'.

  IF SY-SUBRC <> 0.
    GV_ERROR = 'X'.
  ENDIF.

  CHECK GV_ERROR IS INITIAL.

*___서로다른 미지급전표들을 선택한 경우 에러
  LOOP AT G_ITEM_T WHERE BOX = 'X'.

    LV_CNT = LV_CNT + 1.

    IF LV_BELNR IS INITIAL.
      LV_BELNR = G_ITEM_T-BELNR.
    ELSE.
      LV_BELNR2 = G_ITEM_T-BELNR.
    ENDIF.

    IF LV_CNT > 1.
      IF LV_BELNR NE LV_BELNR2.
        GV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ENDIF.

  ENDLOOP.

  IF GV_ERROR IS INITIAL AND GV_UCOMM = 'ZOUT'.

    LOOP AT G_ITEM_T WHERE BOX = 'X'.

      "이미 지급완료설정이 되어 있는지 확인
      IF G_ITEM_T-ZOUT = 'X'.
        GV_ERROR2 = 'X'.

        "지급이 된 항목이 있는지 확인
      ELSEIF G_ITEM_T-LIGHTS = '2'.
        GV_ERROR3 = 'X'.

      ENDIF.

    ENDLOOP.
  ENDIF.

  IF GV_ERROR IS INITIAL AND GV_UCOMM = 'ZCANC'.

    READ TABLE G_ITEM_T WITH KEY BOX = 'X' ZOUT = 'X'.

    IF SY-SUBRC <> 0.

      GV_ERROR2 = 'X'.

    ENDIF.

  ENDIF.


ENDFORM.                    " GET_ITEM_T
*&---------------------------------------------------------------------*
*&      Form  SET_ZSD0016T_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_ZSD0016T_DATA USING P_FLAG.

  DATA: LV_BELNR LIKE G_ITEM_T-BELNR.

  LV_BELNR = G_ITEM_T-BELNR.

  IF P_FLAG = 1.

*  ___ 선택한 아이템의 미지급전표 전체가 대상이 됨
    LOOP AT G_ITEM_T WHERE BELNR = LV_BELNR.

      UPDATE ZSD0016T SET ZOUT   = 'X'
                          ZBELNR = ZSD0016T-ZBELNR
                          ZMSG   = ZSD0016T-ZMSG
                          ERDAT  = SY-DATLO
                          ERNAM  = SY-UNAME
                    WHERE KNUMA  = G_ITEM_T-KNUMA
                      AND FBUDA  = G_ITEM_T-FBUDA
                      AND VBELN  = G_ITEM_T-VBELN
                      AND BELNR  = LV_BELNR
                      AND VBELN2 = G_ITEM_T-VBELN2.
    ENDLOOP.

    IF SY-SUBRC = 0.
      MESSAGE S001 WITH '정상적으로 지급완료설정이 되었습니다.'.
    ELSE.
      MESSAGE S001 WITH '지급완료설정 중 에러가 발생했습니다.'.
    ENDIF.

  ELSE.

    LOOP AT G_ITEM_T WHERE BELNR = LV_BELNR.

      UPDATE ZSD0016T SET ZOUT   = ' '
                          ZBELNR = ' '
                          ZMSG   = ' '
                          ERDAT  = SY-DATLO
                          ERNAM  = SY-UNAME
                    WHERE KNUMA  = G_ITEM_T-KNUMA
                      AND FBUDA  = G_ITEM_T-FBUDA
                      AND VBELN  = G_ITEM_T-VBELN
                      AND BELNR  = LV_BELNR
                      AND VBELN2 = G_ITEM_T-VBELN2.
    ENDLOOP.

    IF SY-SUBRC = 0.
      MESSAGE S001 WITH '정상적으로 지급완료설정이 취소 되었습니다.'.
    ELSE.
      MESSAGE S001 WITH '지급완료설정 취소 중 에러가 발생했습니다.'.
    ENDIF.

  ENDIF.



ENDFORM.                    " SET_ZSD0016T_DATA
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_COMFIRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0397   text
*      -->P_0398   text
*      -->P_0399   text
*      -->P_GV_ANSWER  text
*----------------------------------------------------------------------*
FORM POPUP_TO_COMFIRM  USING    PV_TITLE
                                PV_TEXT
                                PV_DEFAULT
                                PV_ANSWER.
  CLEAR : PV_ANSWER.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = PV_TITLE
      TEXT_QUESTION         = PV_TEXT
      TEXT_BUTTON_1         = '예'
      ICON_BUTTON_1         = 'ICON_OKAY'
      TEXT_BUTTON_2         = '아니오'
      ICON_BUTTON_2         = 'ICON_CANCEL'
      DEFAULT_BUTTON        = PV_DEFAULT
      DISPLAY_CANCEL_BUTTON = ' '
    IMPORTING
      ANSWER                = PV_ANSWER
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.

ENDFORM.                    " POPUP_TO_COMFIRM
*&---------------------------------------------------------------------*
*&      Form  GET_EXCHANGE_FACTOR
*&---------------------------------------------------------------------*
*       기능개선 287676 - 추가
*----------------------------------------------------------------------*
FORM GET_EXCHANGE_FACTOR  USING    PV_FCURR
                                   PV_TCURR
                          CHANGING PV_FFACT
                                   PV_TFACT.
  DATA: LV_GDATU    LIKE TCURF-GDATU.

  CLEAR : PV_FFACT, PV_TFACT, LV_GDATU.

  CALL FUNCTION 'CONVERSION_EXIT_INVDT_INPUT'
    EXPORTING
      INPUT  = SY-DATUM
    IMPORTING
      OUTPUT = LV_GDATU.

  SELECT SINGLE FFACT
                TFACT
    INTO (PV_FFACT, PV_TFACT)
    FROM TCURF
   WHERE KURST =  'M'
     AND FCURR =  PV_FCURR
     AND TCURR =  PV_TCURR
     AND GDATU >= LV_GDATU.

  IF PV_FFACT IS INITIAL.
    PV_FFACT = 1.
  ENDIF.

  IF PV_TFACT IS INITIAL.
    PV_TFACT = 1.
  ENDIF.

ENDFORM.                    " GET_EXCHANGE_FACTOR
*&---------------------------------------------------------------------*
*& Form read_data_process_HANA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM READ_DATA_PROCESS_HANA .
  CLEAR : G_ITAB_T, G_ITAB_T[].

** 대상 Data를 Query.
  SELECT  VBRK~VBELN AS VBELN2
          ZKONA~VKORG ZKONA~VTWEG ZKONA~SPART
*->[CHG]-------------------------S
          VBAK~VKBUR VBAK~VKGRP
*          ZKONA~VKBUR ZKONA~VKGRP
*-<[CHG]-------------------------E
          VBRK~KUNRG AS KUNAG
          VBRK~NETWR VBRK~WAERK ZKONA~BONEM ZKONA~KNUMA ZKONA~BOTEXT
          ZKONA~BOSTA ZKONA~WAERS VBRK~NETWR  VBRK~WAERK
          ZSD0016T~WRBTR ZSD0016T~BUGA_AMNT ZSD0016T~K_WAERK
          ZSD0016T~BELNR ZSD0016T~VBELN     ZSD0016T~FBUDA
          ZSD0016T~BUGA_BELNR ZSD0016T~ZBELNR ZSD0016T~ZOUT
          ZSD0016T~ZMSG
    INTO  CORRESPONDING FIELDS OF TABLE G_ITAB_T
    FROM  ZKONA INNER JOIN ZSD0016T
                ON ZSD0016T~KNUMA = ZKONA~KNUMA
                INNER JOIN VBRK
                ON VBRK~VBELN = ZSD0016T~VBELN2
*->[CHG]-------------------------S
                INNER JOIN VBAK
                ON ZSD0016T~VBELN = VBAK~VBELN
*-<[CHG]-------------------------E
   WHERE  ZKONA~VKORG    EQ PA_VKORG
     AND  ZKONA~VTWEG    EQ PA_VTWEG
     AND  ZKONA~SPART    EQ PA_SPART
*->[CHG]-------------------------S
     AND  VBAK~VKBUR    IN PA_VKBUR
     AND  VBAK~VKGRP    IN PA_VKGRP
*     AND  ZKONA~VKBUR    IN PA_VKBUR
*     AND  ZKONA~VKGRP    IN PA_VKGRP
*-<[CHG]-------------------------E
     AND  ZKONA~KNUMA    IN SO_KNUMA
     AND  ZKONA~BONEM    IN SO_BONEM
     AND  ZSD0016T~FBUDA IN PA_SPMON
     AND  VBRK~DRAFT     EQ SPACE.



*-> MIG Table 추가 : 2023.08.21
  DATA:
    LS_ITAB_S   LIKE LINE OF G_ITAB_T,
    LT_ITAB_T   LIKE STANDARD TABLE OF G_ITAB_T,
    LT_ITAB_ADD LIKE STANDARD TABLE OF G_ITAB_T.
*<-

*-> CCM : 08.10.2023 23:54:39 / ZLSGSD3
* MIG 시 로직 변경
  SELECT A~VBELN AS VBELN2
         A~KUNRG AS KUNAG
         A~NETWR      A~WAERK
         A~NETWR      A~WAERK
         B~VKORG      B~VTWEG
*->[CHG]-------------------------S
         B~SPART      D~VKBUR
         D~VKGRP      B~BONEM
*         B~SPART      B~VKBUR
*         B~VKGRP      B~BONEM
*-<[CHG]-------------------------E
         B~KNUMA      B~BOTEXT
         B~BOSTA      B~WAERS
         C~WRBTR      C~BUGA_AMNT
         C~K_WAERK    C~BELNR
         C~VBELN      C~FBUDA
         C~BUGA_BELNR C~ZBELNR
         C~ZOUT       C~ZMSG
    INTO CORRESPONDING FIELDS OF TABLE LT_ITAB_T
    FROM  ZKONA AS B INNER JOIN ZSD0016T AS C
                     ON C~KNUMA = B~KNUMA
                     INNER JOIN ZVBRK_R3 AS A
                     ON A~VBELN = C~VBELN2
*->[CHG]-------------------------S
                     INNER JOIN ZVBAK_R3 AS D
                     ON C~VBELN = D~VBELN
*-<[CHG]-------------------------E
     WHERE  B~VKORG  EQ  PA_VKORG
       AND  B~VTWEG  EQ  PA_VTWEG
       AND  B~SPART  EQ  PA_SPART
*->[CHG]-------------------------S
       AND  D~VKBUR  IN PA_VKBUR
       AND  D~VKGRP  IN PA_VKGRP
*       AND  B~VKBUR  IN PA_VKBUR
*       AND  B~VKGRP  IN PA_VKGRP
*-<[CHG]-------------------------E
       AND  B~KNUMA  IN SO_KNUMA
       AND  B~BONEM  IN SO_BONEM
       AND  C~FBUDA  IN PA_SPMON.

  IF SY-SUBRC EQ 0.
    SORT G_ITAB_T BY VBELN2.
    LOOP AT LT_ITAB_T INTO LS_ITAB_S.
      READ TABLE G_ITAB_T WITH KEY VBELN2 = LS_ITAB_S-VBELN2 BINARY SEARCH TRANSPORTING NO FIELDS.
      IF SY-SUBRC NE 0.
        LS_ITAB_S-ECC_MIG = 'X'.            "ECC 마이그 데이터 구분자 X
        APPEND LS_ITAB_S TO LT_ITAB_ADD.
      ENDIF.
    ENDLOOP.
    IF LT_ITAB_ADD[] IS NOT INITIAL.
      APPEND LINES OF LT_ITAB_ADD[] TO G_ITAB_T[].
    ENDIF.
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
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VTWEG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VTWEG  USING   PV_FNAME.
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
FORM F4_SPART  USING  PV_FNAME.
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
  LT_FIELDS-FIELDNAME = 'PA_VTWEG'. "유통경로
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

  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VTWEG'.
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
FORM F4_VKBUR  USING    PV_FNAME.
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
FORM F4_VKGRP  USING  PV_FNAME.
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
