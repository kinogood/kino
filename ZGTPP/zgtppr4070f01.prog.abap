*&---------------------------------------------------------------------*
*& Include          ZGTPPR4070F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_SCREEN_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SCREEN_VALUE .

  P_ZSYS = GC_KBDM.
  P_SPMON = SY-DATUM+0(6).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECKING_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM AUTHORITY_CHECKING_PROC .
*& 플랜트에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
                      ID 'WERKS' FIELD P_WERKS.

  IF SY-SUBRC <> 0.
    "플랜트[P_WERKS] 작업권한을 확인하세요.
    MESSAGE E006 WITH TEXT-M01 P_WERKS TEXT-M02.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_ALV_VARIANT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_LAYO
*&---------------------------------------------------------------------*
FORM SELECT_ALV_VARIANT  CHANGING PV_LAYO TYPE DISVARIANT-VARIANT.

  DATA: LS_VARIANT TYPE DISVARIANT.

  LS_VARIANT-REPORT = SY-REPID.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      IS_VARIANT    = LS_VARIANT
      I_SAVE        = 'A'
    IMPORTING
      ES_VARIANT    = LS_VARIANT
    EXCEPTIONS
      NOT_FOUND     = 1
      PROGRAM_ERROR = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    PV_LAYO = LS_VARIANT-VARIANT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_FIRST_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_FIRST_SCREEN .
  LOOP AT SCREEN.
    CASE SCREEN-NAME.
      WHEN 'P_ZSYS' OR 'P_SPMON' OR 'P_WERKS'.
        SCREEN-REQUIRED = 1.
        MODIFY SCREEN.
    ENDCASE.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_DATA .

  DATA: LV_DATE TYPE SY-DATUM.

  CLEAR: LV_DATE.
  LV_DATE = P_SPMON && |01|.

*-당월 말일
  CLEAR: GV_BUDATE.
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = LV_DATE
    IMPORTING
      LAST_DAY_OF_MONTH = GV_BUDATE
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2.

*-차월 1일
  CLEAR: GV_BUDAT1.
  GV_BUDAT1 = P_SPMON && |01|.

  CALL FUNCTION 'MONTH_PLUS_DETERMINE'
    EXPORTING
      MONTHS  = '1'
      OLDDATE = GV_BUDAT1
    IMPORTING
      NEWDATE = GV_BUDAT1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .

  DATA: LT_LIST LIKE TABLE OF ZLES001.

  DATA: L_CSTAT(50),
        L_RSTAT(50).

  CLEAR: L_CSTAT, L_RSTAT.
  IF P_R1 EQ GC_X.
    IF P_PROC EQ GC_X.
      L_CSTAT = 'A~C_STAT EQ @GC_Y'.
    ELSEIF P_UNPROC EQ GC_X.
      L_CSTAT = 'A~C_STAT NE @GC_Y'.
    ENDIF.
  ELSEIF P_R2 EQ GC_X.
    L_CSTAT = 'A~C_STAT EQ @GC_Y'.
    IF P_PROC EQ GC_X.
      L_RSTAT = 'A~R_STAT EQ @GC_Y'.
    ELSEIF P_UNPROC EQ GC_X.
      L_RSTAT = 'A~R_STAT NE @GC_Y'.
    ENDIF.
  ENDIF.

  CLEAR: GT_DATA.
  SELECT B~WERKS, B~AUFNR, B~AUART, B~OBJNR,
         C~GAMNG, C~IGMNG, C~GMEIN, C~GSTRP, C~GLTRP,
         D~MATNR, D~WEMNG, D~KDAUF, D~KDPOS, D~LGORT,
         E~MTART, E~MATKL,
         F~ZPJNO, F~BSTNK,
         G~NAME1,
         H~MTBEZ,
         I~WGBEZ,
         J~MAKTX,
         K~ZPTXT,
         L~ZJOB_NAME AS JOBNM
    FROM            ZGTPPT9030 AS A
   INNER JOIN       AUFK       AS B ON B~AUFNR EQ A~AUFNR
   INNER JOIN       AFKO       AS C ON C~AUFNR EQ B~AUFNR
   INNER JOIN       AFPO       AS D ON D~AUFNR EQ C~AUFNR
   INNER JOIN       MARA       AS E ON E~MATNR EQ D~MATNR
    LEFT OUTER JOIN VBAK       AS F ON F~VBELN EQ D~KDAUF
    LEFT OUTER JOIN T001W      AS G ON G~WERKS EQ B~WERKS
    LEFT OUTER JOIN T134T      AS H ON H~SPRAS EQ @SY-LANGU
                                   AND H~MTART EQ E~MTART
    LEFT OUTER JOIN T023T      AS I ON I~SPRAS EQ @SY-LANGU
                                   AND I~MATKL EQ E~MATKL
    LEFT OUTER JOIN MAKT       AS J ON J~MATNR EQ D~MATNR
                                   AND J~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN ZSD0106T   AS K ON K~ZPJNO EQ F~ZPJNO
    LEFT OUTER JOIN ZGTEDT2121 AS L ON L~ZJOB_NO EQ F~BSTNK
   WHERE A~ZSYSTEM_ID EQ @P_ZSYS
     AND A~SPMON      EQ @P_SPMON
     AND A~WERKS      EQ @P_WERKS
     AND B~AUFNR      IN @S_AUFNR
     AND A~ZCOMPLETED NE @GC_Y
     AND A~ZERP_STAT  EQ @GC_S
     AND (L_CSTAT)
     AND (L_RSTAT)
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.

  SORT: GT_DATA BY AUFNR,
        GT_RT BY AUFNR RTCOD.

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_S>).
    PERFORM MODIFY_STAT USING <FS_S>.

*-오더상태
    CALL FUNCTION 'ZGTPP_ORDER_STATUS'
      EXPORTING
        I_AUFNR  = <FS_S>-AUFNR
      IMPORTING
        E_STATUS = <FS_S>-ORDSTAT.

*-생산잔량 = 생산오더수량 - 생산입고수량
    <FS_S>-REMNG = <FS_S>-GAMNG - <FS_S>-WEMNG.

*-제품구분
    IF <FS_S>-KDAUF IS NOT INITIAL.
      CLEAR: LT_LIST.
      CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC'
        EXPORTING
          I_VBELN                      = <FS_S>-KDAUF
          I_POSNR                      = <FS_S>-KDPOS
          I_OBJECT                     = <FS_S>-MATNR
          I_WERKS                      = <FS_S>-WERKS
        TABLES
          GT_LIST                      = LT_LIST
        EXCEPTIONS
          INSTANCE_NOT_FOUND           = 1
          INSTANCE_IS_A_CLASSIFICATION = 2
          INVALID_DATA                 = 3
          OTHERS                       = 4.

      READ TABLE LT_LIST INTO DATA(LS_LIST) WITH KEY ATNAM = 'PD_NBD_CM_PROD_ID'.

      <FS_S>-PROD_ID = LS_LIST-ATWTB.

      CLEAR: LS_LIST.
    ENDIF.

*-처리 결과
    IF GT_RT IS NOT INITIAL.
      READ TABLE GT_RT INTO DATA(LS_RT) WITH KEY AUFNR = <FS_S>-AUFNR
                                                 RTCOD = GC_E.
      IF LS_RT IS NOT INITIAL AND SY-SUBRC EQ 0.
        <FS_S>-ID = ICON_LED_RED.
        <FS_S>-RTMSG = LS_RT-RTMSG.
      ELSE.
        READ TABLE GT_RT INTO LS_RT WITH KEY AUFNR = <FS_S>-AUFNR.

        CLEAR: GV_GBN.
        CASE LS_RT-PROCCODE.
          WHEN 'CGR'.
            <FS_S>-RTMSG = TEXT-M05. "생산오더의 당월 생산입고 취소 처리를 성공하였습니다.
          WHEN 'CTM'.
            <FS_S>-RTMSG = TEXT-M08. "생산오더의 당월 시간투입 취소 처리를 성공하였습니다.
            GV_GBN = GC_C.
          WHEN 'CGI'.
            <FS_S>-RTMSG = TEXT-M11. "생산오더의 당월 수기 자재투입 취소 처리를 성공하였습니다.
            GV_GBN = GC_C.
          WHEN 'RGR'.
            <FS_S>-RTMSG = TEXT-M13. "차월로 생산오더의 생산입고 재처리를 성공하였습니다.
          WHEN 'RTM'.
            <FS_S>-RTMSG = TEXT-M15. "차월로 생산오더의 시간투입 재처리를 성공하였습니다.
            GV_GBN = GC_R.
          WHEN 'RGI'.
            <FS_S>-RTMSG = TEXT-M17. "차월로 생산오더의 수기 자재투입 재처리를 성공하였습니다.
            GV_GBN = GC_R.
        ENDCASE.

        <FS_S>-ID = ICON_LED_GREEN.

        IF GV_GBN EQ GC_C OR GV_GBN = GC_R.
          IF <FS_S>-GI_STAT EQ ICON_LED_GREEN.
            PERFORM UPDATE_ZGTPPT9030 USING <FS_S> GV_GBN.
          ENDIF.
        ENDIF.

      ENDIF.
      CLEAR: LS_RT.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_STAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM MODIFY_STAT  USING    P_LINE LIKE GS_DATA.

  DATA: LV_MBLNR TYPE MBLNR,
        LV_RUECK TYPE CO_RUECK.

  IF P_R1 EQ GC_X.
*-생산입고 취소
    CLEAR: LV_MBLNR.
    SELECT SINGLE MBLNR
      FROM MATDOC
     WHERE RECORD_TYPE EQ @GC_MDOC
       AND WERKS       EQ @P_LINE-WERKS
       AND AUFNR       EQ @P_LINE-AUFNR
       AND BWART       EQ @GC_101
       AND CANCELLED   EQ @SPACE
      INTO @LV_MBLNR.

    IF LV_MBLNR IS NOT INITIAL.
      P_LINE-GR_STAT = ICON_LED_RED.
    ELSE.
      P_LINE-GR_STAT = ICON_LED_GREEN.
    ENDIF.

*-시간투입 취소
    CLEAR: LV_RUECK.
    SELECT SINGLE RUECK
      FROM AFRU
     WHERE WERKS EQ @P_LINE-WERKS
       AND AUFNR EQ @P_LINE-AUFNR
       AND STOKZ EQ @SPACE
       AND STZHL EQ @SPACE
      INTO @LV_RUECK.

    IF LV_RUECK IS NOT INITIAL.
      P_LINE-TM_STAT = ICON_LED_RED.
    ELSE.
      P_LINE-TM_STAT = ICON_LED_GREEN.
    ENDIF.

*-자재투입 취소
    CLEAR: LV_MBLNR.
    SELECT SINGLE MBLNR
      FROM MATDOC
     WHERE RECORD_TYPE EQ @GC_MDOC
       AND WERKS       EQ @P_LINE-WERKS
       AND AUFNR       EQ @P_LINE-AUFNR
       AND BWART       EQ @GC_261
       AND CANCELLED   EQ @SPACE
       AND AUFPL = @SPACE                 "SRM2511-01091 수기 투입건만 발췌
      INTO @LV_MBLNR.

    IF LV_MBLNR IS NOT INITIAL.
      P_LINE-GI_STAT = ICON_LED_RED.
    ELSE.
      P_LINE-GI_STAT = ICON_LED_GREEN.
    ENDIF.

  ELSEIF P_R2 EQ GC_X.
*-생산입고 재처리
    CLEAR: LV_MBLNR.
    SELECT SINGLE MBLNR
      FROM ZGTPPT9040
     WHERE ZSYSTEM_ID EQ @P_ZSYS
       AND SPMON      EQ @P_SPMON
       AND WERKS      EQ @P_LINE-WERKS
       AND AUFNR      EQ @P_LINE-AUFNR
       AND MBLNR_R    EQ @SPACE
      INTO @LV_MBLNR.

    IF LV_MBLNR IS NOT INITIAL.
      P_LINE-GR_STAT = ICON_LED_RED.
    ELSE.
      P_LINE-GR_STAT = ICON_LED_GREEN.
    ENDIF.

*-시간투입 재처리
    CLEAR: LV_RUECK.
    SELECT SINGLE RUECK
      FROM ZGTPPT9050
     WHERE ZSYSTEM_ID EQ @P_ZSYS
       AND SPMON      EQ @P_SPMON
       AND WERKS      EQ @P_LINE-WERKS
       AND AUFNR      EQ @P_LINE-AUFNR
       AND RUECK_R    EQ @SPACE
      INTO @LV_RUECK.

    IF LV_RUECK IS NOT INITIAL.
      P_LINE-TM_STAT = ICON_LED_RED.
    ELSE.
      P_LINE-TM_STAT = ICON_LED_GREEN.
    ENDIF.

*-자재투입 재처리
    CLEAR: LV_MBLNR.
    SELECT SINGLE MBLNR
      FROM ZGTPPT9060
     WHERE ZSYSTEM_ID EQ @P_ZSYS
       AND SPMON      EQ @P_SPMON
       AND WERKS      EQ @P_LINE-WERKS
       AND AUFNR      EQ @P_LINE-AUFNR
       AND MBLNR_R    EQ @SPACE
      INTO @LV_MBLNR.

    IF LV_MBLNR IS NOT INITIAL.
      P_LINE-GI_STAT = ICON_LED_RED.
    ELSE.
      P_LINE-GI_STAT = ICON_LED_GREEN.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLS_OBJT_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CLS_OBJT_RTN .
  CLEAR: GT_FIELDCAT_0100[], GS_LAYOUT_0100, GT_EXCLUDE_0100[],
         GT_EXCLUDE_0100,
         GV_OK_CODE, GV_DBCNT,
         GT_DATA[].

  CALL METHOD GO_DOCKING_CONTAINER->FREE.
  FREE: GO_DOCKING_CONTAINER.
  FREE: GO_CONTAIN_0100.
  FREE: GO_GRID_0100.
  CLEAR : GO_DOCKING_CONTAINER, GO_GRID_0100.
  CALL METHOD CL_GUI_CFW=>FLUSH.
  LEAVE TO SCREEN 0.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0100 .
  CREATE OBJECT GO_DOCKING_CONTAINER
    EXPORTING
      REPID                       = SY-REPID
      DYNNR                       = SY-DYNNR
      EXTENSION                   = 10000
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.

  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_DOCKING_CONTAINER
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0100 .
  DATA: LV_TITLE(40).

  CLEAR: LV_TITLE.
  IF P_R1 EQ GC_X.
    LV_TITLE = TEXT-T11 && |: | &&
               GV_BUDATE+0(4) && |.| && GV_BUDATE+4(2) && |.| && GV_BUDATE+6(2).
  ELSEIF P_R2 EQ GC_X.
    LV_TITLE = TEXT-T12 && |: | &&
               GV_BUDAT1+0(4) && |.| && GV_BUDAT1+4(2) && |.| && GV_BUDAT1+6(2)..
  ENDIF.

  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-ZEBRA      = GC_X.
  GS_LAYOUT_0100-COL_OPT    = GC_X.
  GS_LAYOUT_0100-CWIDTH_OPT = GC_X.
  GS_LAYOUT_0100-NO_ROWINS  = GC_X.
  GS_LAYOUT_0100-SEL_MODE   = GC_D.
  GS_LAYOUT_0100-GRID_TITLE = LV_TITLE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_VARIANT_GRID_0100 .
  IF P_LAYO IS NOT INITIAL.
    GS_VARIANT-VARIANT = P_LAYO.
  ENDIF.
  GS_VARIANT-REPORT = SY-REPID.
  GS_VARIANT-USERNAME = SY-UNAME.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0100 .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR4070TOP'
      I_INTERNAL_TABNAME     = 'GS_DATA'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_DATA
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'GR_STAT'.
        IF P_R1 EQ GC_X.
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "생산입고취소
        ELSEIF P_R2 EQ GC_X.
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "생산입고재처리
        ENDIF.
        <LS_FCAT>-KEY = GC_X.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
      WHEN 'TM_STAT'.
        IF P_R1 EQ GC_X.
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "시간투입취소
        ELSEIF P_R2 EQ GC_X.
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "시간투입재처리
        ENDIF.
        <LS_FCAT>-KEY = GC_X.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
      WHEN 'GI_STAT'.
        IF P_R1 EQ GC_X.
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "수기자재투입취소
        ELSEIF P_R2 EQ GC_X.
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "수기자재투입재처리
        ENDIF.
        <LS_FCAT>-KEY = GC_X.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "생산오더번호
        <LS_FCAT>-KEY = GC_X.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ORDSTAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "생산오더상태
        <LS_FCAT>-JUST = GC_L.
      WHEN 'ID'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "처리상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
      WHEN 'RTMSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "처리 메세지
        <LS_FCAT>-KEY = GC_X.
        <LS_FCAT>-JUST = GC_L.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "플랜트
        <LS_FCAT>-JUST = GC_C.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "플랜트 내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MTART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F13. "자재유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MTBEZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "자재유형 내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'AUART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "생산오더유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MATKL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "자재그룹
        <LS_FCAT>-JUST = GC_C.
      WHEN 'WGBEZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "자재그룹 내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'PROD_ID'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "제품구분
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "품목코드
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "품목내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'GAMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "생산오더수량
        <LS_FCAT>-JUST = GC_R.
      WHEN 'WEMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "생산입고수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-QFIELDNAME = 'GMEIN'.
      WHEN 'IGMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F23. "생산확정수량
        <LS_FCAT>-JUST = GC_R.
      WHEN 'REMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F24. "생산잔량
        <LS_FCAT>-JUST = GC_R.
      WHEN 'GMEIN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F25. "생산단위
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZPJNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F26. "프로젝트번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZPTXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F27. "프로젝트내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'BSTNK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F28. "제조지시번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'JOBNM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F29. "제조지시내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'KDAUF'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F30. "판매오더번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'KDPOS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F31. "판매오더품목
        <LS_FCAT>-JUST = GC_C.
      WHEN 'GSTRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F32. "오더시작일
        <LS_FCAT>-JUST = GC_C.
      WHEN 'GLTRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F33. "오더종료일
        <LS_FCAT>-JUST = GC_C.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    IF <LS_FCAT>-FIELDNAME = 'GR_STAT' OR <LS_FCAT>-FIELDNAME = 'TM_STAT' OR
       <LS_FCAT>-FIELDNAME = 'GI_STAT' OR <LS_FCAT>-FIELDNAME = 'AUFNR'.

    ELSE.
      CLEAR: <LS_FCAT>-KEY.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0100 .
  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0100
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_EXCLUDE_TOOLBAR_BUTTON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_EXCLUDE_0100
*&      --> CL_GUI_ALV_GRID=>MC_FC_LOC_UND
*&---------------------------------------------------------------------*
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   P_TABLE
                                 USING    P_VALUE.
  DATA: L_EXCLUDE TYPE UI_FUNC.
  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM SET_EVENT_GRID_0100  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.
  IF GO_EVTR_0100 IS NOT BOUND.
    CREATE OBJECT GO_EVTR_0100.
  ENDIF.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      SET HANDLER: GO_EVTR_0100->HDL_DOUBLE_CLICK FOR GO_GRID_0100.
  ENDCASE.

* DATA CHANGE
  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0100_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .
  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
      IS_VARIANT           = GS_VARIANT
      I_SAVE               = GC_X
    CHANGING
      IT_OUTTAB            = GT_DATA
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_CANGR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_CANGR .

  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'W'
       WITH TEXT-M03. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T05 "당월 생산 입고 취소
      TEXT_QUESTION         = TEXT-T06 "당월 생산 입고 취소를 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-GR_STAT EQ ICON_LED_GREEN.
        <FS_S>-RTMSG = TEXT-M04. "이미 생산오더의 당월 생산입고를 모두 취소하였습니다.
      ELSE.
        PERFORM EXEC_CAN_GR USING <FS_S>.
      ENDIF.
    ENDLOOP.

    IF GT_CGR IS NOT INITIAL.
      LOOP AT GT_CGR INTO DATA(LS_CGR).
        MOVE-CORRESPONDING LS_CGR TO GS_RT.
        GS_RT-PROCCODE = 'CGR'.
        COLLECT GS_RT INTO GT_RT.
        CLEAR: GS_RT.
      ENDLOOP.

*-데이터 REFRESH
      PERFORM GET_DATA.
    ENDIF.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEL_ROW_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROW_NO
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM SEL_ROW_RTN  TABLES PT_ROW_NO TYPE LVC_T_ROID
                  USING  PR_ALV TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LT_INDEX_ROWS TYPE LVC_T_ROW,
        LT_ROW_NO     TYPE LVC_T_ROID.

*--------------------------------------------------------------------*

  CLEAR: LT_INDEX_ROWS, LT_INDEX_ROWS[],
         LT_ROW_NO, LT_ROW_NO[].

  PR_ALV->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_INDEX_ROWS
      ET_ROW_NO     = LT_ROW_NO ).

  PT_ROW_NO[] = LT_ROW_NO[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REF_ALV_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM REF_ALV_RTN  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.
  DATA LS_STABLE TYPE LVC_S_STBL.

  LS_STABLE-ROW = 'X'.
  LS_STABLE-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
        EXPORTING
          IS_LAYOUT = GS_LAYOUT_0100.
  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = LS_STABLE
    EXCEPTIONS
      FINISHED       = 1
      OTHERS         = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_CAN_GR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_CAN_GR  USING    P_LINE LIKE GS_DATA.

  DATA: LT_RETURN     TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
        LS_RETURNS    TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
        LS_GOODSMVT   TYPE BAPI2017_GM_HEAD_RET,
        LV_HEADER_TXT TYPE BAPI2017_GM_HEAD_02-HEADER_TXT.

  CLEAR: GT_CGR.
  SELECT WERKS, AUFNR, MBLNR, MJAHR, BKTXT
    FROM MATDOC
   WHERE RECORD_TYPE EQ @GC_MDOC
     AND WERKS       EQ @P_LINE-WERKS
     AND AUFNR       EQ @P_LINE-AUFNR
     AND BWART       EQ @GC_101
     AND CANCELLED   EQ @SPACE
    INTO CORRESPONDING FIELDS OF TABLE @GT_CGR.

  LOOP AT GT_CGR ASSIGNING FIELD-SYMBOL(<FS_CGR>).

    CLEAR: LT_RETURN, LS_RETURNS, LS_GOODSMVT.

    CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
      EXPORTING
        MATERIALDOCUMENT    = <FS_CGR>-MBLNR
        MATDOCUMENTYEAR     = <FS_CGR>-MJAHR
        GOODSMVT_PSTNG_DATE = GV_BUDATE
        GOODSMVT_PR_UNAME   = SY-UNAME
        DOCUMENTHEADER_TEXT = <FS_CGR>-BKTXT
      IMPORTING
        GOODSMVT_HEADRET    = LS_GOODSMVT
      TABLES
        RETURN              = LT_RETURN.

    IF LS_GOODSMVT-MAT_DOC IS NOT INITIAL.
      <FS_CGR>-RTCOD = GC_S.
      <FS_CGR>-MBLNR_C = LS_GOODSMVT-MAT_DOC.
      <FS_CGR>-MJAHR_C = LS_GOODSMVT-DOC_YEAR.

      PERFORM SAVE_ZGTPPT9040 USING <FS_CGR>.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = GC_X.

      WAIT UP TO '0.5' SECONDS.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      CLEAR: LT_RETURN.
      READ TABLE LT_RETURN WITH KEY TYPE = GC_E.
      <FS_CGR>-RTMSG = LT_RETURN-MESSAGE.
      <FS_CGR>-RTCOD = GC_E.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZGTPPT9040
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_GR>
*&---------------------------------------------------------------------*
FORM SAVE_ZGTPPT9040  USING    P_RTLINE LIKE GS_CGRGI.

  DATA: LS_ZGTPPT9040 LIKE ZGTPPT9040.

  CLEAR: LS_ZGTPPT9040.
  LS_ZGTPPT9040-ZSYSTEM_ID = P_ZSYS.
  LS_ZGTPPT9040-SPMON      = P_SPMON.
  LS_ZGTPPT9040-WERKS      = P_RTLINE-WERKS.
  LS_ZGTPPT9040-AUFNR      = P_RTLINE-AUFNR.
  LS_ZGTPPT9040-MBLNR      = P_RTLINE-MBLNR.
  LS_ZGTPPT9040-MJAHR      = P_RTLINE-MJAHR.
  LS_ZGTPPT9040-MBLNR_C    = P_RTLINE-MBLNR_C.
  LS_ZGTPPT9040-MJAHR_C    = P_RTLINE-MJAHR_C.
  LS_ZGTPPT9040-CRDAT      = SY-DATUM.
  LS_ZGTPPT9040-CRTIM      = SY-UZEIT.
  LS_ZGTPPT9040-CRNAM      = SY-UNAME.

  MODIFY ZGTPPT9040 FROM LS_ZGTPPT9040.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_CANTM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_CANTM .

  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'W'
       WITH TEXT-M03. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T07 "당월 시간 투입 취소
      TEXT_QUESTION         = TEXT-T08 "당월 시간 투입 취소를 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-GR_STAT NE ICON_LED_GREEN.
        <FS_S>-RTMSG = TEXT-M06. "생산입고 취소 완료 후 시간투입 취소를 진행하십시요.
      ELSE.
        IF <FS_S>-TM_STAT EQ ICON_LED_GREEN.
          <FS_S>-RTMSG = TEXT-M07. "이미 생산오더의 당월 시간투입을 모두 취소하였습니다.
        ELSE.
          PERFORM EXEC_CAN_TM USING <FS_S>.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF GT_CTM IS NOT INITIAL.
      LOOP AT GT_CTM INTO DATA(LS_CTM).
        MOVE-CORRESPONDING LS_CTM TO GS_RT.
        GS_RT-PROCCODE = 'CTM'.
        COLLECT GS_RT INTO GT_RT.
        CLEAR: GS_RT.
      ENDLOOP.

*-데이터 REFRESH
      PERFORM GET_DATA.
    ENDIF.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_CAN_TM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_CAN_TM  USING    P_LINE LIKE GS_DATA.

  DATA: LS_LOCKED   TYPE BAPI_CORU_PARAM,
        LV_CONF_NO  TYPE CO_RUECK,
        LV_CONF_CNT TYPE CO_RMZHL,
        LS_RETURN   TYPE BAPIRET1.

  DATA : LV_EXTID TYPE RU_EXTID_CHAR.

  CLEAR: GT_CTM.
  SELECT WERKS, AUFNR, RUECK, RMZHL, LTXA1, EXTID
    FROM AFRU
   WHERE WERKS EQ @P_LINE-WERKS
     AND AUFNR EQ @P_LINE-AUFNR
     AND STOKZ EQ @SPACE
     AND STZHL EQ @SPACE
    INTO CORRESPONDING FIELDS OF TABLE @GT_CTM.

  LOOP AT GT_CTM ASSIGNING FIELD-SYMBOL(<FS_CTM>).

    CLEAR: LS_LOCKED, LV_CONF_NO, LV_CONF_CNT, LS_RETURN, LV_EXTID.

*    LV_EXTID = <FS_CTM>-EXTID.

    CALL FUNCTION 'BAPI_PRODORDCONF_CANCEL'
      EXPORTING
        CONFIRMATION        = <FS_CTM>-RUECK
        CONFIRMATIONCOUNTER = <FS_CTM>-RMZHL
        POSTG_DATE          = GV_BUDATE
        CONF_TEXT           = <FS_CTM>-LTXA1
*        EX_IDENT            = <FS_CTM>-EXTID
      IMPORTING
        RETURN              = LS_RETURN
*        LOCKED              = LS_LOCKED
        CREATED_CONF_NO     = LV_CONF_NO
        CREATED_CONF_COUNT  = LV_CONF_CNT.

    IF LV_CONF_NO IS NOT INITIAL.
      <FS_CTM>-RTCOD = GC_S.
      <FS_CTM>-RUECK_C = LV_CONF_NO.
      <FS_CTM>-RMZHL_C = LV_CONF_CNT.

      PERFORM SAVE_ZGTPPT9050 USING <FS_CTM>.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = GC_X.

      WAIT UP TO '0.5' SECONDS.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      <FS_CTM>-RTMSG = LS_RETURN-MESSAGE.
      <FS_CTM>-RTCOD = GC_E.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZGTPPT9050
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_TM>
*&---------------------------------------------------------------------*
FORM SAVE_ZGTPPT9050  USING    P_RTLINE LIKE GS_CTM.

  DATA: LS_ZGTPPT9050 LIKE ZGTPPT9050.

  CLEAR: LS_ZGTPPT9050.
  LS_ZGTPPT9050-ZSYSTEM_ID = P_ZSYS.
  LS_ZGTPPT9050-SPMON      = P_SPMON.
  LS_ZGTPPT9050-WERKS      = P_RTLINE-WERKS.
  LS_ZGTPPT9050-AUFNR      = P_RTLINE-AUFNR.
  LS_ZGTPPT9050-RUECK      = P_RTLINE-RUECK.
  LS_ZGTPPT9050-RMZHL      = P_RTLINE-RMZHL.
  LS_ZGTPPT9050-RUECK_C    = P_RTLINE-RUECK_C.
  LS_ZGTPPT9050-RMZHL_C    = P_RTLINE-RMZHL_C.
  LS_ZGTPPT9050-CRDAT      = SY-DATUM.
  LS_ZGTPPT9050-CRTIM      = SY-UZEIT.
  LS_ZGTPPT9050-CRNAM      = SY-UNAME.

  MODIFY ZGTPPT9050 FROM LS_ZGTPPT9050.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_ZGTPPT9030
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM UPDATE_ZGTPPT9030  USING    P_LINE LIKE GS_DATA
                                 P_GBN.

  DATA: L_DYN(50).

  CLEAR: L_DYN.

  IF P_GBN EQ GC_C.
*    L_DYN = 'C_STAT =  GC_Y'.
    CONCATENATE 'C_STAT = ' ' ''Y'' '  INTO L_DYN.
  ELSEIF P_GBN EQ GC_R.
*    L_DYN = 'R_STAT = GC_Y'.
    CONCATENATE 'R_STAT = ' ' ''Y'' '  INTO L_DYN.
  ENDIF.

  UPDATE ZGTPPT9030 SET (L_DYN)
                  WHERE ZSYSTEM_ID = P_ZSYS
                    AND SPMON      = P_SPMON
                    AND WERKS      = P_LINE-WERKS
                    AND AUFNR      = P_LINE-AUFNR.

  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_CANGI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_CANGI .

  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'W'
       WITH TEXT-M03. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T09 "당월 수기 자재 투입 취소
      TEXT_QUESTION         = TEXT-T10 "당월 수기 자재 투입 취소를 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-TM_STAT NE ICON_LED_GREEN.
        <FS_S>-RTMSG = TEXT-M09. "시간투입 취소 완료 후 수기 자재투입 취소를 진행하십시요.
      ELSE.
        IF <FS_S>-GI_STAT EQ ICON_LED_GREEN.
          <FS_S>-RTMSG = TEXT-M10. "이미 생산오더의 당월 자재투입을 모두 취소하였습니다.
        ELSE.
          PERFORM EXEC_CAN_GI USING <FS_S>.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF GT_CGI IS NOT INITIAL.
      LOOP AT GT_CGI INTO DATA(LS_CGI).
        MOVE-CORRESPONDING LS_CGI TO GS_RT.
        GS_RT-PROCCODE = 'CGI'.
        COLLECT GS_RT INTO GT_RT.
        CLEAR: GS_RT.
      ENDLOOP.

*-데이터 REFRESH
      PERFORM GET_DATA.
    ENDIF.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_CAN_GI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_CAN_GI  USING    P_LINE LIKE GS_DATA.

  DATA: LT_RETURN     TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
        LS_RETURNS    TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
        LS_GOODSMVT   TYPE BAPI2017_GM_HEAD_RET,
        LV_HEADER_TXT TYPE BAPI2017_GM_HEAD_02-HEADER_TXT.

  CLEAR: GT_CGI.
  SELECT WERKS, AUFNR, MBLNR, MJAHR, BKTXT
    FROM MATDOC
   WHERE RECORD_TYPE EQ @GC_MDOC
     AND WERKS       EQ @P_LINE-WERKS
     AND AUFNR       EQ @P_LINE-AUFNR
     AND BWART       EQ @GC_261
     AND CANCELLED   EQ @SPACE
    INTO CORRESPONDING FIELDS OF TABLE @GT_CGI.

  LOOP AT GT_CGI ASSIGNING FIELD-SYMBOL(<FS_CGI>).

    CLEAR: LT_RETURN, LS_RETURNS, LS_GOODSMVT.

    CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
      EXPORTING
        MATERIALDOCUMENT    = <FS_CGI>-MBLNR
        MATDOCUMENTYEAR     = <FS_CGI>-MJAHR
        GOODSMVT_PSTNG_DATE = GV_BUDATE
        GOODSMVT_PR_UNAME   = SY-UNAME
        DOCUMENTHEADER_TEXT = GC_ZGTPPR4070
      IMPORTING
        GOODSMVT_HEADRET    = LS_GOODSMVT
      TABLES
        RETURN              = LT_RETURN.

    IF LS_GOODSMVT-MAT_DOC IS NOT INITIAL.
      <FS_CGI>-RTCOD = GC_S.
      <FS_CGI>-MBLNR_C = LS_GOODSMVT-MAT_DOC.
      <FS_CGI>-MJAHR_C = LS_GOODSMVT-DOC_YEAR.

      PERFORM SAVE_ZGTPPT9060 USING <FS_CGI>.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = GC_X.

      WAIT UP TO '0.5' SECONDS.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      CLEAR: LT_RETURN.
      READ TABLE LT_RETURN WITH KEY TYPE = GC_E.
      <FS_CGI>-RTMSG = LT_RETURN-MESSAGE.
      <FS_CGI>-RTCOD = GC_E.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZGTPPT9060
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_GI>
*&---------------------------------------------------------------------*
FORM SAVE_ZGTPPT9060  USING    P_RTLINE LIKE GS_CGRGI.

  DATA: LS_ZGTPPT9060 LIKE ZGTPPT9060.

  CLEAR: LS_ZGTPPT9060.
  LS_ZGTPPT9060-ZSYSTEM_ID = P_ZSYS.
  LS_ZGTPPT9060-SPMON      = P_SPMON.
  LS_ZGTPPT9060-WERKS      = P_RTLINE-WERKS.
  LS_ZGTPPT9060-AUFNR      = P_RTLINE-AUFNR.
  LS_ZGTPPT9060-MBLNR      = P_RTLINE-MBLNR.
  LS_ZGTPPT9060-MJAHR      = P_RTLINE-MJAHR.
  LS_ZGTPPT9060-MBLNR_C    = P_RTLINE-MBLNR_C.
  LS_ZGTPPT9060-MJAHR_C    = P_RTLINE-MJAHR_C.
  LS_ZGTPPT9060-CRDAT      = SY-DATUM.
  LS_ZGTPPT9060-CRTIM      = SY-UZEIT.
  LS_ZGTPPT9060-CRNAM      = SY-UNAME.

  MODIFY ZGTPPT9060 FROM LS_ZGTPPT9060.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_REGR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_REGR .

  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'W'
       WITH TEXT-M03. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T13 "차월 생산 입고 재처리
      TEXT_QUESTION         = TEXT-T14 "차월로 생산 입고를 재처리하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-GR_STAT EQ ICON_LED_GREEN.
        <FS_S>-RTMSG = TEXT-M12. "이미 생산오더의 생산입고를 모두 차월로 재처리하였습니다.
      ELSE.
        PERFORM EXEC_RE_GR USING <FS_S>.
      ENDIF.
    ENDLOOP.

    IF GT_RGR IS NOT INITIAL.
      LOOP AT GT_RGR INTO DATA(LS_RGR).
        MOVE-CORRESPONDING LS_RGR TO GS_RT.
        GS_RT-PROCCODE = 'RGR'.
        COLLECT GS_RT INTO GT_RT.
        CLEAR: GS_RT.
      ENDLOOP.

*-데이터 REFRESH
      PERFORM GET_DATA.
    ENDIF.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_RE_GR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_RE_GR  USING    P_LINE LIKE GS_DATA.

  DATA: LS_HEADER    TYPE BAPI2017_GM_HEAD_01,
        LV_CODE      TYPE BAPI2017_GM_CODE VALUE '02',
        LV_DOCUMENT  TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_YEAR      TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LV_MESSAGE   TYPE BAPIRET2-MESSAGE,
        LT_ITEM      TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LS_GMHEADRET LIKE BAPI2017_GM_HEAD_RET,
        LT_RETURN    TYPE TABLE OF BAPIRET2,
        LS_RETURN    TYPE BAPIRET2.

  CLEAR: GT_RGR.
  SELECT A~MBLNR, A~MJAHR, A~AUFNR, A~WERKS,
         B~BKTXT, B~MATNR, B~CHARG, B~ERFMG, B~ERFME,
         C~LGORT
    FROM  ZGTPPT9040 AS A
   INNER JOIN MATDOC AS B ON B~MBLNR EQ A~MBLNR
                         AND B~MJAHR EQ A~MJAHR
   INNER JOIN AFPO   AS C ON C~AUFNR EQ A~AUFNR
                         AND C~POSNR EQ @GC_0001
   WHERE A~ZSYSTEM_ID EQ @P_ZSYS
     AND A~SPMON      EQ @P_SPMON
     AND A~WERKS      EQ @P_LINE-WERKS
     AND A~AUFNR      EQ @P_LINE-AUFNR
     AND A~MBLNR_R    EQ @SPACE
    INTO CORRESPONDING FIELDS OF TABLE @GT_RGR.

  LOOP AT GT_RGR ASSIGNING FIELD-SYMBOL(<FS_RGR>).
    CLEAR: GV_CHK.

    CLEAR: LS_HEADER.
    LS_HEADER = VALUE #( PSTNG_DATE = GV_BUDAT1
                         DOC_DATE   = GV_BUDAT1
                         HEADER_TXT = <FS_RGR>-BKTXT ).

    CLEAR: LT_ITEM.
    LT_ITEM = VALUE #( ( MATERIAL   = <FS_RGR>-MATNR
                         PLANT      = <FS_RGR>-WERKS
                         ORDERID    = <FS_RGR>-AUFNR
                         ORDER_ITNO = GC_0001
                         MVT_IND    = GC_F
                         STCK_TYPE  = SPACE
                         NO_MORE_GR = GC_X
                         MOVE_TYPE  = GC_101
                         STGE_LOC   = <FS_RGR>-LGORT
                         BATCH      = <FS_RGR>-CHARG
                         ENTRY_UOM  = <FS_RGR>-ERFME
                         ENTRY_QNT  = <FS_RGR>-ERFMG ) ).

    CLEAR: LV_DOCUMENT, LV_YEAR, LS_GMHEADRET, LS_RETURN, LT_RETURN, LV_MESSAGE.
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = LS_HEADER
        GOODSMVT_CODE    = LV_CODE
      IMPORTING
        GOODSMVT_HEADRET = LS_GMHEADRET
        MATERIALDOCUMENT = LV_DOCUMENT
        MATDOCUMENTYEAR  = LV_YEAR
      TABLES
        GOODSMVT_ITEM    = LT_ITEM
        RETURN           = LT_RETURN.

    IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
* 자재 락 에러일 경우 추가 5번 시도
      CLEAR LS_RETURN.
      READ TABLE LT_RETURN INTO LS_RETURN WITH KEY TYPE = 'E'
                                                     ID = 'M3'
                                                 NUMBER = '897'.
      IF LS_RETURN IS NOT INITIAL.
        DO 5 TIMES.
          CALL FUNCTION 'DEQUEUE_EMMARCE'
            EXPORTING
              MATNR = <FS_RGR>-MATNR
              WERKS = <FS_RGR>-WERKS.

          WAIT UP TO '0.5' SECONDS.

          CLEAR: LV_DOCUMENT, LV_YEAR, LS_GMHEADRET, LS_RETURN, LT_RETURN, LV_MESSAGE.
          CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
            EXPORTING
              GOODSMVT_HEADER  = LS_HEADER
              GOODSMVT_CODE    = LV_CODE
            IMPORTING
              GOODSMVT_HEADRET = LS_GMHEADRET
              MATERIALDOCUMENT = LV_DOCUMENT
              MATDOCUMENTYEAR  = LV_YEAR
            TABLES
              GOODSMVT_ITEM    = LT_ITEM
              RETURN           = LT_RETURN.

          IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).

            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

            LV_MESSAGE = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

            <FS_RGR>-RTCOD = GC_E.
            <FS_RGR>-RTMSG = LV_MESSAGE.

          ELSE.
            <FS_RGR>-RTCOD = GC_S.
            <FS_RGR>-RTMSG = TEXT-M13. "차월로 생산오더의 생산입고 재처리를 성공하였습니다.

            UPDATE ZGTPPT9040 SET MBLNR_R = LV_DOCUMENT
                                  MJAHR_R = LV_YEAR
                                  CHDAT   = SY-DATUM
                                  CHTIM   = SY-UZEIT
                                  CHNAM   = SY-UNAME
                            WHERE ZSYSTEM_ID = P_ZSYS
                              AND SPMON      = P_SPMON
                              AND WERKS      = <FS_RGR>-WERKS
                              AND AUFNR      = <FS_RGR>-AUFNR
                              AND MBLNR      = <FS_RGR>-MBLNR
                              AND MJAHR      = <FS_RGR>-MJAHR.

            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                WAIT = 'X'.

            GV_CHK = 'X'.
            EXIT.

          ENDIF.

        ENDDO.
* 5번 시도 후 여전히 처리안됐을 경우 마지막 에러 메시지 반영
        IF GV_CHK IS INITIAL.

          LV_MESSAGE = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

          <FS_RGR>-RTCOD = GC_E.
          <FS_RGR>-RTMSG = LV_MESSAGE.
          EXIT.

        ENDIF.
* 일반 에러일 경우 바로 메시지 반영
      ELSE.

        LV_MESSAGE = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

        <FS_RGR>-RTCOD = GC_E.
        <FS_RGR>-RTMSG = LV_MESSAGE.
        EXIT.

      ENDIF.

    ELSE.
      <FS_RGR>-RTCOD = GC_S.
      <FS_RGR>-RTMSG = TEXT-M13. "차월로 생산오더의 생산입고 재처리를 성공하였습니다.

      UPDATE ZGTPPT9040 SET MBLNR_R = LV_DOCUMENT
                            MJAHR_R = LV_YEAR
                            CHDAT   = SY-DATUM
                            CHTIM   = SY-UZEIT
                            CHNAM   = SY-UNAME
                      WHERE ZSYSTEM_ID = P_ZSYS
                        AND SPMON      = P_SPMON
                        AND WERKS      = <FS_RGR>-WERKS
                        AND AUFNR      = <FS_RGR>-AUFNR
                        AND MBLNR      = <FS_RGR>-MBLNR
                        AND MJAHR      = <FS_RGR>-MJAHR.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.

    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_RETM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_RETM .

  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'W'
       WITH TEXT-M03. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T15 "차월 시간 투입 재처리
      TEXT_QUESTION         = TEXT-T16 "차월로 시간 투입을 재처리하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-TM_STAT EQ ICON_LED_GREEN.
        <FS_S>-RTMSG = TEXT-M14. "이미 생산오더의 시간투입을 모두 차월로 재처리하였습니다.
      ELSE.
        PERFORM EXEC_RE_TM USING <FS_S>.
      ENDIF.
    ENDLOOP.

    IF GT_RTM IS NOT INITIAL.
      LOOP AT GT_RTM INTO DATA(LS_RTM).
        MOVE-CORRESPONDING LS_RTM TO GS_RT.
        GS_RT-PROCCODE = 'RTM'.
        COLLECT GS_RT INTO GT_RT.
        CLEAR: GS_RT.
      ENDLOOP.

*-데이터 REFRESH
      PERFORM GET_DATA.
    ENDIF.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_RE_TM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_RE_TM  USING    P_LINE LIKE GS_DATA.

  DATA: LT_TT     TYPE TABLE OF BAPI_PP_TIMETICKET,
        LT_GOODS  TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_DETAIL TYPE TABLE OF BAPI_CORU_RETURN,
        LS_DETAIL TYPE BAPI_CORU_RETURN,
        LS_RETURN TYPE BAPIRET1.

  CLEAR: GT_RTM.
  SELECT A~RUECK, A~RMZHL, A~AUFNR, A~WERKS,
         B~VORNR, B~ARBID, B~LMNGA,
         B~ISDD, B~ISDZ, B~IEDD, B~IEDZ, B~EXTID, B~LTXA1, B~PERNR,
         B~ILE01, B~ILE02, B~ILE03, B~ILE04, B~ILE05, B~ILE06,
         B~ISM01, B~ISM02, B~ISM03, B~ISM04, B~ISM05, B~ISM06,
         C~ARBPL
    FROM      ZGTPPT9050 AS A
   INNER JOIN       AFRU AS B ON B~RUECK EQ A~RUECK
                             AND B~RMZHL EQ A~RMZHL
    LEFT OUTER JOIN CRHD AS C ON C~OBJTY EQ @GC_A
                             AND C~OBJID EQ B~ARBID
   WHERE A~ZSYSTEM_ID EQ @P_ZSYS
     AND A~SPMON      EQ @P_SPMON
     AND A~WERKS      EQ @P_LINE-WERKS
     AND A~AUFNR      EQ @P_LINE-AUFNR
     AND A~RUECK_R    EQ @SPACE
    INTO CORRESPONDING FIELDS OF TABLE @GT_RTM.

  LOOP AT GT_RTM ASSIGNING FIELD-SYMBOL(<FS_RTM>).
    CLEAR: LT_TT.
    IF <FS_RTM>-LMNGA IS NOT INITIAL.
      LT_TT = VALUE #( ( ORDERID         = <FS_RTM>-AUFNR
                         OPERATION       = <FS_RTM>-VORNR
                         FIN_CONF        = SPACE
                         CLEAR_RES       = SPACE
                         POSTG_DATE      = GV_BUDAT1
                         DEV_REASON      = SPACE
                         PLANT           = <FS_RTM>-WERKS
                         WORK_CNTR       = <FS_RTM>-ARBPL
                         YIELD           = <FS_RTM>-LMNGA
                         SCRAP           = SPACE
                         REWORK          = SPACE
                         CONF_ACTIVITY1  = SPACE
                         CONF_ACTI_UNIT1 = <FS_RTM>-ILE01
                         CONF_ACTIVITY2  = SPACE
                         CONF_ACTI_UNIT2 = <FS_RTM>-ILE02
                         CONF_ACTIVITY3  = SPACE
                         CONF_ACTI_UNIT3 = <FS_RTM>-ILE03
                         CONF_ACTIVITY4  = SPACE
                         CONF_ACTI_UNIT4 = <FS_RTM>-ILE04
                         CONF_ACTIVITY5  = SPACE
                         CONF_ACTI_UNIT5 = <FS_RTM>-ILE05
                         CONF_ACTIVITY6  = SPACE
                         CONF_ACTI_UNIT6 = <FS_RTM>-ILE06
                         EXEC_START_DATE = <FS_RTM>-ISDD
                         EXEC_START_TIME = <FS_RTM>-ISDZ
                         PROC_FIN_DATE   = <FS_RTM>-IEDD
                         PROC_FIN_TIME   = <FS_RTM>-IEDZ
                         EX_IDENT        = <FS_RTM>-EXTID
                         CONF_TEXT       = <FS_RTM>-LTXA1
                         PERS_NO         = <FS_RTM>-PERNR ) ).

    ELSEIF <FS_RTM>-LMNGA IS INITIAL.
      LT_TT = VALUE #( ( ORDERID         = <FS_RTM>-AUFNR
                         OPERATION       = <FS_RTM>-VORNR
                         FIN_CONF        = '1'
                         CLEAR_RES       = SPACE
                         POSTG_DATE      = GV_BUDAT1
                         DEV_REASON      = SPACE
                         PLANT           = <FS_RTM>-WERKS
                         WORK_CNTR       = <FS_RTM>-ARBPL
                         YIELD           = SPACE
                         SCRAP           = SPACE
                         REWORK          = SPACE
                         CONF_ACTIVITY1  = SPACE
                         CONF_ACTI_UNIT1 = SPACE
                         CONF_ACTIVITY2  = <FS_RTM>-ISM02
                         CONF_ACTI_UNIT2 = <FS_RTM>-ILE02
                         CONF_ACTIVITY3  = <FS_RTM>-ISM03
                         CONF_ACTI_UNIT3 = <FS_RTM>-ILE03
                         CONF_ACTIVITY4  = <FS_RTM>-ISM04
                         CONF_ACTI_UNIT4 = <FS_RTM>-ILE04
                         CONF_ACTIVITY5  = <FS_RTM>-ISM05
                         CONF_ACTI_UNIT5 = <FS_RTM>-ILE05
                         CONF_ACTIVITY6  = <FS_RTM>-ISM06
                         CONF_ACTI_UNIT6 = <FS_RTM>-ILE06
                         EXEC_START_DATE = <FS_RTM>-ISDD
                         EXEC_START_TIME = <FS_RTM>-ISDZ
                         PROC_FIN_DATE   = <FS_RTM>-IEDD
                         PROC_FIN_TIME   = <FS_RTM>-IEDZ
                         EX_IDENT        = <FS_RTM>-EXTID
                         CONF_TEXT       = <FS_RTM>-LTXA1
                         PERS_NO         = <FS_RTM>-PERNR ) ).
    ENDIF.

*- 생산 실적 처리 (최종 확정 처리)
    CLEAR: LT_GOODS, LT_DETAIL, LS_RETURN, LS_DETAIL.
    CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
      IMPORTING
        RETURN         = LS_RETURN
      TABLES
        TIMETICKETS    = LT_TT
        GOODSMOVEMENTS = LT_GOODS
        DETAIL_RETURN  = LT_DETAIL.

*- 실패
    IF LS_RETURN IS NOT INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = GC_A
                                         OR  TYPE = GC_E
                                         OR  TYPE = GC_X.

        <FS_RTM>-RTMSG = LS_DETAIL-MESSAGE.
        EXIT.
      ENDLOOP.

      <FS_RTM>-RTCOD = GC_E.

*- 성공
    ELSE.
      <FS_RTM>-RTCOD = GC_S.
      <FS_RTM>-RTMSG = TEXT-T15. "차월로 생산오더의 시간투입 재처리를 성공하였습니다.

      LS_DETAIL = VALUE #( LT_DETAIL[ 1 ] OPTIONAL ).

      UPDATE ZGTPPT9050 SET RUECK_R = LS_DETAIL-CONF_NO
                            RMZHL_R = LS_DETAIL-CONF_CNT
                            CHDAT   = SY-DATUM
                            CHTIM   = SY-UZEIT
                            CHNAM   = SY-UNAME
                      WHERE ZSYSTEM_ID = P_ZSYS
                        AND SPMON      = P_SPMON
                        AND WERKS      = <FS_RTM>-WERKS
                        AND AUFNR      = <FS_RTM>-AUFNR
                        AND RUECK      = <FS_RTM>-RUECK
                        AND RMZHL      = <FS_RTM>-RMZHL.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = GC_X.

      WAIT UP TO '0.5' SECONDS.

    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_REGI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_REGI .

  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'W'
       WITH TEXT-M03. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T17 "차월 수기 자재 투입 재처리
      TEXT_QUESTION         = TEXT-T18 "차월로 수기 자재 투입을 재처리하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-GI_STAT EQ ICON_LED_GREEN.
        <FS_S>-RTMSG = TEXT-M16. "이미 생산오더의 자재투입을 모두 차월로 재처리하였습니다.
      ELSE.
        PERFORM EXEC_RE_GI USING <FS_S>.
      ENDIF.
    ENDLOOP.

    IF GT_RGI IS NOT INITIAL.
      LOOP AT GT_RGI INTO DATA(LS_RGI).
        MOVE-CORRESPONDING LS_RGI TO GS_RT.
        GS_RT-PROCCODE = 'RGI'.
        COLLECT GS_RT INTO GT_RT.
        CLEAR: GS_RT.
      ENDLOOP.

*-데이터 REFRESH
      PERFORM GET_DATA.
    ENDIF.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_RE_GI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_RE_GI  USING    P_LINE LIKE GS_DATA.

  DATA: LS_HEADER    TYPE BAPI2017_GM_HEAD_01,
        LV_CODE      TYPE BAPI2017_GM_CODE VALUE '03',
        LV_DOCUMENT  TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_YEAR      TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LV_MESSAGE   TYPE BAPIRET2-MESSAGE,
        LT_ITEM      TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LS_GMHEADRET LIKE BAPI2017_GM_HEAD_RET,
        LT_RETURN    TYPE TABLE OF BAPIRET2,
        LS_RETURN    TYPE BAPIRET2.

  CLEAR: GT_RGI.
  SELECT A~MBLNR, A~MJAHR, A~AUFNR, A~WERKS,
         B~MATNR, B~LGORT, B~CHARG, B~ERFMG, B~ERFME
    FROM  ZGTPPT9060 AS A
   INNER JOIN MATDOC AS B ON B~MBLNR EQ A~MBLNR
                         AND B~MJAHR EQ A~MJAHR
   WHERE A~ZSYSTEM_ID EQ @P_ZSYS
     AND A~SPMON      EQ @P_SPMON
     AND A~WERKS      EQ @P_LINE-WERKS
     AND A~AUFNR      EQ @P_LINE-AUFNR
     AND A~MBLNR_R    EQ @SPACE
    INTO CORRESPONDING FIELDS OF TABLE @GT_RGR.

  LOOP AT GT_RGI ASSIGNING FIELD-SYMBOL(<FS_RGI>).
    CLEAR: LS_HEADER.
    LS_HEADER = VALUE #( PSTNG_DATE = GV_BUDAT1
                         DOC_DATE   = GV_BUDAT1
                         PR_UNAME   = SY-UNAME
                         HEADER_TXT = GC_ZGTPPR4070 ).

    CLEAR: LT_ITEM.
    LT_ITEM = VALUE #( ( MATERIAL   = <FS_RGI>-MATNR
                         PLANT      = <FS_RGI>-WERKS
                         ORDERID    = <FS_RGI>-AUFNR
                         STCK_TYPE  = GC_F
                         MOVE_TYPE  = GC_261
                         STGE_LOC   = <FS_RGI>-LGORT
                         BATCH      = <FS_RGI>-CHARG
                         ENTRY_UOM  = <FS_RGI>-ERFME
                         ENTRY_QNT  = <FS_RGI>-ERFMG ) ).

    CLEAR: LV_DOCUMENT, LV_YEAR, LS_GMHEADRET, LS_RETURN, LT_RETURN, LV_MESSAGE.
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = LS_HEADER
        GOODSMVT_CODE    = LV_CODE
      IMPORTING
        GOODSMVT_HEADRET = LS_GMHEADRET
        MATERIALDOCUMENT = LV_DOCUMENT
        MATDOCUMENTYEAR  = LV_YEAR
      TABLES
        GOODSMVT_ITEM    = LT_ITEM
        RETURN           = LT_RETURN.

    IF LS_GMHEADRET IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      READ TABLE LT_RETURN INTO LS_RETURN WITH KEY TYPE = GC_E.
      <FS_RGI>-RTCOD = GC_E.
      <FS_RGI>-RTMSG = LS_RETURN-MESSAGE.

      CLEAR: LS_RETURN.
    ELSE.
      <FS_RGI>-RTCOD = GC_S.
      <FS_RGI>-RTMSG = TEXT-M17. "차월로 생산오더의 수기 자재투입 재처리를 성공하였습니다.

      UPDATE ZGTPPT9060 SET MBLNR_R = LV_DOCUMENT
                            MJAHR_R = LV_YEAR
                            CHDAT   = SY-DATUM
                            CHTIM   = SY-UZEIT
                            CHNAM   = SY-UNAME
                      WHERE ZSYSTEM_ID = P_ZSYS
                        AND SPMON      = P_SPMON
                        AND WERKS      = <FS_RGI>-WERKS
                        AND AUFNR      = <FS_RGI>-AUFNR
                        AND MBLNR      = <FS_RGI>-MBLNR
                        AND MJAHR      = <FS_RGI>-MJAHR.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = GC_X.

      WAIT UP TO '0.5' SECONDS.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_SPMON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_SPMON
*&---------------------------------------------------------------------*
FORM F4_SPMON  CHANGING PV_SPMON TYPE SPMON.

  DATA: LV_SUBRC LIKE SY-SUBRC,
        LV_MONTH LIKE ISELLIST-MONTH.

  LV_MONTH = SY-DATUM+0(6).

  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      ACTUAL_MONTH               = LV_MONTH
      FACTORY_CALENDAR           = ' '
      HOLIDAY_CALENDAR           = ' '
      LANGUAGE                   = SY-LANGU
      START_COLUMN               = 8
      START_ROW                  = 5
    IMPORTING
      SELECTED_MONTH             = PV_SPMON
      RETURN_CODE                = LV_SUBRC
    EXCEPTIONS
      FACTORY_CALENDAR_NOT_FOUND = 1
      HOLIDAY_CALENDAR_NOT_FOUND = 2
      MONTH_NOT_FOUND            = 3
      OTHERS                     = 4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_COCKPIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_COCKPIT .
  DATA: LV_CKP(1).
  IMPORT CKP TO LV_CKP FROM MEMORY ID 'CKP'.
  FREE MEMORY ID 'CKP'.

  IF LV_CKP EQ 'X'.
    EXPORT CKP = 'S' TO MEMORY ID 'CKP'.
    CLEAR: LV_CKP.
  ENDIF.
ENDFORM.
