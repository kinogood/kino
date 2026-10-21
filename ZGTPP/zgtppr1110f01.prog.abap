*&---------------------------------------------------------------------*
*& Include          ZGTPPR1110F01
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
  S_ANDAT[] = VALUE #( ( SIGN = GC_I
                         OPTION = GC_BT
                         LOW = SY-DATUM
                         HIGH = SY-DATUM ) ).
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
      WHEN 'P_WERKS' OR 'P_SPGCD'.
        SCREEN-REQUIRED = 2.
        MODIFY SCREEN.
    ENDCASE.

    IF P_R2 EQ GC_X.
      IF SCREEN-GROUP1 = 'S1' OR SCREEN-GROUP1 = 'S2'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSEIF P_R3 EQ GC_X.
      IF SCREEN-GROUP1 = 'S1'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INPUT_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INPUT_CHECK .
  IF P_WERKS IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH TEXT-M01. "필수 필드 "플랜트"에 입력하십시오.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF P_SPGCD IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH TEXT-M02. "필수 필드 "SPG코드"에 입력하십시오.
    LEAVE LIST-PROCESSING.
  ENDIF.
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

  PERFORM SET_SPGCD.

  IF P_R1 EQ GC_X.
    PERFORM GET_DATA_C.
    PERFORM MODIFY_DATA.
  ELSEIF P_R2 EQ GC_X OR P_R3 EQ GC_X.
    PERFORM GET_DATA_S.
  ENDIF.

  SORT GT_DATA BY MATNR WERKS BESKZ SOBSL VERID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_C .

*-생산버전 구성 마스터
  CLEAR: GT_1010.
  SELECT (GC_ALL)
    FROM ZGTPPT1010
   WHERE MODULE_KIND EQ @GC_PP
     AND CODEGRP     EQ @GC_1040
    INTO CORRESPONDING FIELDS OF TABLE @GT_1010.

*-생산버전 생성 대상
  CLEAR: GT_ODATA.
  SELECT DISTINCT
         A~MATNR, A~MATKL,
         B~WERKS, B~BESKZ, B~SOBSL, B~DISPO,
         D~NAME1,
         E~MAKTX,
         F~WGBEZ
    FROM            MARA  AS A
   INNER JOIN       MARC  AS B ON B~MATNR EQ A~MATNR
   INNER JOIN       MAST  AS C ON C~MATNR EQ B~MATNR
                              AND C~WERKS EQ B~WERKS
    LEFT OUTER JOIN T001W AS D ON D~WERKS EQ B~WERKS
    LEFT OUTER JOIN MAKT  AS E ON E~MATNR EQ A~MATNR
                              AND E~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T023T AS F ON F~SPRAS EQ @SY-LANGU
                              AND F~MATKL EQ A~MATKL
   WHERE A~MATNR IN @S_MATNR
     AND B~WERKS EQ @P_WERKS
     AND B~FEVOR IN @S_FEVOR
     AND (GV_DYN)
     AND C~ANDAT IN @S_ANDAT
     AND ( ( ( B~BESKZ EQ @GC_E OR B~BESKZ EQ @GC_X ) AND B~SOBSL EQ @SPACE ) "자작
          OR ( B~BESKZ EQ @GC_F AND B~SOBSL EQ @GC_30 )         "외주
          OR ( B~BESKZ EQ @GC_F AND B~SOBSL EQ @GC_50 )         ""외주 가상부품
          OR ( B~BESKZ EQ @GC_X AND B~SOBSL EQ @GC_30 )         "자작/외주
          OR ( B~BESKZ EQ @GC_F AND B~SOBSL EQ @SPACE AND A~MATKL EQ @GC_RW600407 ) ) "종이박스
    INTO CORRESPONDING FIELDS OF TABLE @GT_ODATA.

  SORT GT_ODATA BY BESKZ SOBSL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_S
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_S .

  CLEAR: GT_DATA.
  SELECT A~MATNR, A~WERKS, A~VERID, A~BDATU, A~ADATU, A~STLAL, A~STLAN,
         A~PLNTY, A~PLNNR, A~ALNAL, A~TEXT1, A~PRFG_F, A~PRFG_S, A~PRDAT,
         E~MATKL,
         B~BESKZ, B~SOBSL, B~DISPO,
         C~NAME1,
         D~MAKTX,
         F~WGBEZ
    FROM            MKAL  AS A
   INNER JOIN       MARC  AS B ON B~MATNR EQ A~MATNR
                              AND B~WERKS EQ A~WERKS
   INNER JOIN       MARA  AS E ON E~MATNR EQ A~MATNR
    LEFT OUTER JOIN T001W AS C ON C~WERKS EQ A~WERKS
    LEFT OUTER JOIN MAKT  AS D ON D~MATNR EQ A~MATNR
                              AND D~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T023T AS F ON F~SPRAS EQ @SY-LANGU
                              AND F~MATKL EQ E~MATKL
   WHERE A~WERKS EQ @P_WERKS
     AND A~MATNR IN @S_MATNR
     AND B~FEVOR IN @S_FEVOR
     AND (GV_DYN)
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_S>).
    CASE <FS_S>-PRFG_S.
      WHEN 1.      <FS_S>-BOM_CHECK = ICON_LED_GREEN.
      WHEN 2.      <FS_S>-BOM_CHECK = ICON_LED_YELLOW.
      WHEN 3.      <FS_S>-BOM_CHECK = ICON_LED_RED.
      WHEN OTHERS. <FS_S>-BOM_CHECK = ICON_LED_INACTIVE.
    ENDCASE.

    CASE <FS_S>-PRFG_F.
      WHEN 1.      <FS_S>-ROUT_CHECK = ICON_LED_GREEN.
      WHEN 2.      <FS_S>-ROUT_CHECK = ICON_LED_YELLOW.
      WHEN 3.      <FS_S>-ROUT_CHECK = ICON_LED_RED.
      WHEN OTHERS. <FS_S>-ROUT_CHECK = ICON_LED_INACTIVE.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA .

*-생산버전
  DATA: L_VERID LIKE MKAL-VERID,
        L_BDATU LIKE MKAL-BDATU,
        L_ADATU LIKE MKAL-ADATU,
        L_PRDAT LIKE MKAL-PRDAT.

*-BOM
  DATA: L_STLNR LIKE MAST-STLNR.

*-ROUTING
  DATA: L_PLNNR LIKE MAPL-PLNNR,
        L_PLNAL LIKE MAPL-PLNAL,
        L_PLNTY LIKE MAPL-PLNTY.

*-생산버전 구성 마스터 기준으로 대상 품목 확인
  CLEAR: GT_DATA.
  LOOP AT GT_ODATA INTO DATA(LS_ODATA).
    LOOP AT GT_1010 INTO DATA(LS_1010) WHERE FLD_01 EQ LS_ODATA-BESKZ
                                         AND FLD_02 EQ LS_ODATA-SOBSL.

*-공통
      MOVE: ICON_LED_INACTIVE TO GS_DATA-PROC_STAT,
            LS_ODATA-MATNR TO GS_DATA-MATNR,
            LS_ODATA-MAKTX TO GS_DATA-MAKTX,
            LS_ODATA-MATKL TO GS_DATA-MATKL,
            LS_ODATA-WGBEZ TO GS_DATA-WGBEZ,
            LS_ODATA-WERKS TO GS_DATA-WERKS,
            LS_ODATA-NAME1 TO GS_DATA-NAME1,
            LS_ODATA-BESKZ TO GS_DATA-BESKZ,
            LS_ODATA-SOBSL TO GS_DATA-SOBSL.

      "특정 자재그룹 기준
      CASE LS_1010-FLD_10.
        WHEN GC_RW600407.
          MOVE: LS_1010-FLD_05 TO GS_DATA-FLD_05,
                LS_1010-FLD_06 TO GS_DATA-FLD_06.
        WHEN OTHERS.
          MOVE: LS_1010-FLD_05 TO GS_DATA-FLD_05,
                LS_1010-FLD_06 TO GS_DATA-FLD_06.
      ENDCASE.

*-생산버전 구성 기준 정보로 존재 유무 파악(생산버전,BOM,ROUTING)
*-생산버전
      CLEAR: L_VERID, L_BDATU, L_ADATU.
      SELECT SINGLE VERID, BDATU, ADATU, PRDAT
        FROM MKAL
       WHERE MATNR EQ @LS_ODATA-MATNR
         AND WERKS EQ @LS_ODATA-WERKS
         AND VERID EQ @LS_1010-FLD_03
        INTO (@L_VERID, @L_BDATU, @L_ADATU, @L_PRDAT).

      IF L_VERID IS INITIAL.
        MOVE: ICON_LED_INACTIVE TO GS_DATA-PVER_STAT,
              SY-DATUM          TO GS_DATA-ADATU,
              '99991231'        TO GS_DATA-BDATU.
      ELSE.
        MOVE: ICON_LED_GREEN TO GS_DATA-PVER_STAT,
              L_ADATU        TO GS_DATA-ADATU,
              L_BDATU        TO GS_DATA-BDATU,
              L_PRDAT        TO GS_DATA-PRDAT.
      ENDIF.

      "특정 자재그룹 기준
      CASE LS_1010-FLD_10.
        WHEN GC_RW600407.
          MOVE: LS_1010-FLD_03 TO GS_DATA-VERID,
                LS_1010-FLD_04 TO GS_DATA-TEXT1.
        WHEN OTHERS.
          MOVE: LS_1010-FLD_03 TO GS_DATA-VERID,
                LS_1010-FLD_04 TO GS_DATA-TEXT1.
      ENDCASE.

*-BOM
      CLEAR: L_STLNR.
      SELECT SINGLE STLNR
        FROM MAST
       WHERE MATNR EQ @GS_DATA-MATNR
         AND WERKS EQ @GS_DATA-WERKS
         AND STLAN EQ @LS_1010-FLD_07
         AND STLAL EQ @LS_1010-FLD_08
        INTO @L_STLNR.

      IF L_STLNR IS INITIAL.
        MOVE: ICON_LED_RED   TO GS_DATA-BOM_STAT.
      ELSE.
        MOVE: ICON_LED_GREEN TO GS_DATA-BOM_STAT,
              L_STLNR        TO GS_DATA-STLNR.
      ENDIF.

      "특정 자재그룹 기준
      CASE LS_1010-FLD_10.
        WHEN GC_RW600407.
          MOVE: LS_1010-FLD_07 TO GS_DATA-STLAN,
                LS_1010-FLD_08 TO GS_DATA-STLAL.
        WHEN OTHERS.
          MOVE: LS_1010-FLD_07 TO GS_DATA-STLAN,
                LS_1010-FLD_08 TO GS_DATA-STLAL.
      ENDCASE.

      IF LS_1010-FLD_05 EQ GC_N.
        CLEAR: GS_DATA-BOM_STAT.
      ENDIF.

*-ROUTING
      CLEAR: L_PLNNR, L_PLNAL, L_PLNTY.
      SELECT SINGLE PLNNR, PLNAL, PLNTY
        FROM MAPL
       WHERE MATNR EQ @LS_ODATA-MATNR
         AND WERKS EQ @LS_ODATA-WERKS
         AND PLNAL EQ @LS_1010-FLD_09
*// Modified by ZGODEV06 on 2026-03-19 {
         AND LOEKZ EQ @SPACE
*// }
        INTO (@L_PLNNR, @L_PLNAL, @L_PLNTY).

      IF L_PLNNR IS INITIAL.
        MOVE: ICON_LED_RED   TO GS_DATA-ROUT_STAT.
      ELSE.
        MOVE: ICON_LED_GREEN TO GS_DATA-ROUT_STAT,
              L_PLNNR        TO GS_DATA-PLNNR.
      ENDIF.

      "특정 자재그룹 기준
      CASE LS_1010-FLD_10.
        WHEN GC_RW600407.
          MOVE: LS_1010-FLD_09 TO GS_DATA-ALNAL.
        WHEN OTHERS.
          MOVE: LS_1010-FLD_09 TO GS_DATA-ALNAL.
      ENDCASE.

      IF LS_1010-FLD_06 EQ GC_N.
        CLEAR: GS_DATA-ROUT_STAT.
      ENDIF.

      APPEND GS_DATA TO GT_DATA.

      CLEAR: LS_1010, GS_DATA.
    ENDLOOP.

    CLEAR: LS_ODATA, GS_DATA.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SPGCD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SPGCD .

  CLEAR: GV_DYN, GV_DISPO.
  IF P_SPGCD NE '*'.
    GV_DISPO = P_SPGCD && |%|.
    GV_DYN = 'B~DISPO LIKE @GV_DISPO'.
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
         GT_EXCLUDE_0100, GV_OK_CODE, GV_DBCNT,
         GT_1010[], GT_ODATA[], GT_DATA[].

  CALL METHOD GO_CONTAIN_0100->FREE.
  CLEAR : GO_CONTAIN_0100, GO_GRID_0100.
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
  CREATE OBJECT GO_CONTAIN_0100
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
      I_PARENT      = GO_CONTAIN_0100
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
  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-ZEBRA      = GC_X.
  GS_LAYOUT_0100-COL_OPT    = GC_X.
  GS_LAYOUT_0100-CWIDTH_OPT = GC_X.
  GS_LAYOUT_0100-NO_ROWINS  = GC_X.
  GS_LAYOUT_0100-SEL_MODE   = GC_D.
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
      I_INCLNAME             = 'ZGTPPR1110TOP'
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
      WHEN 'PROC_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "처리상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
      WHEN 'PROC_MSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "메세지
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "품목코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "품목내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'MATKL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F24. "자재그룹
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'WGBEZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F25. "자재그룹내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "플랜트
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "플랜트 내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'BESKZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "조달유형
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'SOBSL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "특별조달
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'PVER_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "생산버전상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'VERID'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "생산버전
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'TEXT1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "생산버전내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'ADATU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "효력시작일
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'BDATU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F13. "효력종료일
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'BOM_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "BOM상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'STLAN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "BOM용도
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'STLAL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "대체BOM
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'ROUT_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "ROUTING상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
        <LS_FCAT>-EMPHASIZE = 'C500'.
      WHEN 'PLNTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "태스크리스트유형
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C500'.
      WHEN 'PLNNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "그룹번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C500'.
      WHEN 'ALNAL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "그룹카운터
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C500'.
      WHEN 'BOM_CHECK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "BOM점검
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
        <LS_FCAT>-EMPHASIZE = 'C500'.
      WHEN 'ROUT_CHECK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "라우팅점검
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
        <LS_FCAT>-EMPHASIZE = 'C500'.
      WHEN 'PRDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F23. "최종점검일
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C500'.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    IF P_R1 EQ GC_X.
      IF <LS_FCAT>-FIELDNAME = 'PLNTY'  OR <LS_FCAT>-FIELDNAME = 'PLNNR' OR
         <LS_FCAT>-FIELDNAME = 'BOM_CHECK' OR <LS_FCAT>-FIELDNAME = 'ROUT_CHECK' OR
         <LS_FCAT>-FIELDNAME = 'PRDAT'.
        <LS_FCAT>-NO_OUT = GC_X.
      ENDIF.
    ELSEIF P_R2 EQ GC_X OR P_R3 EQ GC_X.
      IF <LS_FCAT>-FIELDNAME = 'PROC_STAT' OR <LS_FCAT>-FIELDNAME = 'PROC_MSG' OR
         <LS_FCAT>-FIELDNAME = 'PVER_STAT' OR <LS_FCAT>-FIELDNAME = 'BOM_STAT' OR
         <LS_FCAT>-FIELDNAME = 'ROUT_STAT'.
        <LS_FCAT>-NO_OUT = GC_X.
      ENDIF.
    ENDIF.

    CLEAR: <LS_FCAT>-KEY.

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
    CHANGING
      IT_OUTTAB            = GT_DATA
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_PVERCRE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_PVERCRE .
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
      TITLEBAR              = TEXT-T05 "생산버전 생성
      TEXT_QUESTION         = TEXT-T06 "생산버전 생성을 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-PVER_STAT EQ ICON_LED_GREEN OR <FS_S>-PROC_STAT EQ ICON_LED_GREEN.
        <FS_S>-PROC_MSG = TEXT-M04. "이미 생산버전이 생성된 레코드입니다.
      ELSE.
        IF <FS_S>-FLD_05 EQ GC_Y AND <FS_S>-BOM_STAT NE ICON_LED_GREEN.
          <FS_S>-PROC_MSG = TEXT-M05. "생산버전 생성 전, BOM 생성이 선행되어야 합니다.
        ELSE.
          IF <FS_S>-FLD_06 EQ GC_Y AND <FS_S>-ROUT_STAT NE ICON_LED_GREEN.
            <FS_S>-PROC_MSG = TEXT-M06. "생산버전 생성 전, Routing 생성이 선행되어야 합니다.
          ELSE.
            PERFORM VERID_CREATE USING <FS_S>.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.
  ENDIF.

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
      IS_STABLE = LS_STABLE
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

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

  CLEAR: LT_INDEX_ROWS, LT_INDEX_ROWS[],
         LT_ROW_NO, LT_ROW_NO[].

  PR_ALV->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_INDEX_ROWS
      ET_ROW_NO     = LT_ROW_NO ).

  PT_ROW_NO[] = LT_ROW_NO[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VERID_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM VERID_CREATE  USING    P_LINE LIKE GS_DATA.

  DATA: LT_PROD_VERSION TYPE BOM_TT_PRODVER_MKAL_ENTRIES,
        LS_PROD_VERSION TYPE BOM_TY_PRODVER_MKAL_ENTRIES.

  CLEAR: LS_PROD_VERSION, LT_PROD_VERSION, LT_PROD_VERSION[].
  LS_PROD_VERSION-MATNR  = P_LINE-MATNR.
  LS_PROD_VERSION-WERKS  = P_LINE-WERKS.
  LS_PROD_VERSION-VERID  = P_LINE-VERID.
  LS_PROD_VERSION-ADATU  = P_LINE-ADATU.
  LS_PROD_VERSION-BDATU  = P_LINE-BDATU.
  LS_PROD_VERSION-STLAL  = P_LINE-STLAL.
  LS_PROD_VERSION-STLAN  = P_LINE-STLAN.
  LS_PROD_VERSION-PLNTY  = GC_N.
  LS_PROD_VERSION-PLNNR  = P_LINE-PLNNR.
  LS_PROD_VERSION-ALNAL  = P_LINE-ALNAL.
  LS_PROD_VERSION-PRFG_S = '1'.
  LS_PROD_VERSION-PRFG_F = '1'.
  LS_PROD_VERSION-PRDAT  = SY-DATUM.
  LS_PROD_VERSION-TEXT1  = P_LINE-TEXT1.

  APPEND LS_PROD_VERSION TO LT_PROD_VERSION.

  CALL FUNCTION 'CS_BOM_UPDATE_PROD_VERSIONS'
    EXPORTING
      IT_PROD_VERSION = LT_PROD_VERSION.

  IF SY-SUBRC EQ 0.
    "버전지시자 update
    UPDATE MARC SET VERKZ = @GC_X
              WHERE WERKS EQ @P_LINE-WERKS
                AND MATNR EQ @P_LINE-MATNR.

    IF SY-SUBRC EQ 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = GC_X.

      P_LINE-PVER_STAT = ICON_LED_GREEN.
      P_LINE-PROC_STAT = ICON_LED_GREEN.
      P_LINE-PROC_MSG = TEXT-M07. "생산버전을 성공적으로 생성하였습니다.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      P_LINE-PROC_STAT = ICON_LED_RED.
      P_LINE-PROC_MSG = TEXT-M08. "생산버전 생성 중 오류가 발생하였습니다.
    ENDIF.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    P_LINE-PROC_STAT = ICON_LED_RED.
    P_LINE-PROC_MSG = TEXT-M08. "생산버전 생성 중 오류가 발생하였습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_PVERDEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_PVERDEL .

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
      TITLEBAR              = TEXT-T07 "생산버전 삭제
      TEXT_QUESTION         = TEXT-T08 "생산버전 삭제를 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: GV_SUC.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      PERFORM VERID_DELETE USING <FS_S>.

    ENDLOOP.

    PERFORM GET_DATA.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VERID_DELETE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM VERID_DELETE  USING    P_LINE LIKE GS_DATA.

  DATA: LT_MKAL_I    LIKE TABLE OF MKAL,
        LT_MKAL_U    LIKE TABLE OF MKAL,
        LT_MKAL_D    LIKE TABLE OF MKAL,
        LT_MKAL_AEND LIKE TABLE OF MKAL_AEND,
        LS_MKAL_D    LIKE MKAL.

  CLEAR: LT_MKAL_D, LS_MKAL_D.
  LS_MKAL_D-MATNR = P_LINE-MATNR.
  LS_MKAL_D-WERKS = P_LINE-WERKS.
  LS_MKAL_D-VERID = P_LINE-VERID.

  APPEND LS_MKAL_D TO LT_MKAL_D.

  CALL FUNCTION 'CM_FV_PROD_VERS_DB_UPDATE'
    TABLES
      IT_MKAL_I    = LT_MKAL_I
      IT_MKAL_U    = LT_MKAL_U
      IT_MKAL_D    = LT_MKAL_D
      IT_MKAL_AEND = LT_MKAL_AEND.

  IF SY-SUBRC EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = GC_X.

    GV_SUC = GV_SUC + 1.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BATCH_EXEC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BATCH_EXEC .

  IF P_R1 EQ GC_X.
    PERFORM VERID_CREATE_JOB.
  ELSEIF P_R3 EQ GC_X.
    PERFORM VERID_DELETE_JOB.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VERID_CREATE_JOB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VERID_CREATE_JOB .

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_S>).
    IF <FS_S>-PVER_STAT EQ ICON_LED_GREEN OR <FS_S>-PROC_STAT EQ ICON_LED_GREEN.
*      <FS_S>-PROC_MSG = TEXT-M04. "이미 생산버전이 생성된 레코드입니다.
    ELSE.
      IF <FS_S>-FLD_05 EQ GC_Y AND <FS_S>-BOM_STAT NE ICON_LED_GREEN.
*        <FS_S>-PROC_MSG = TEXT-M05. "생산버전 생성 전, BOM 생성이 선행되어야 합니다.
      ELSE.
        IF <FS_S>-FLD_06 EQ GC_Y AND <FS_S>-ROUT_STAT NE ICON_LED_GREEN.
*          <FS_S>-PROC_MSG = TEXT-M06. "생산버전 생성 전, Routing 생성이 선행되어야 합니다.
        ELSE.
          PERFORM VERID_CREATE USING <FS_S>.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

*- 전체 건수
  DATA(LV_CNT_T) = LINES( GT_DATA ).

*- 성공 건수
  DATA(LV_CNT_S) = REDUCE I(
                   INIT SUM = 0 FOR LS_CNT_S IN GT_DATA
                   WHERE ( PROC_STAT = ICON_LED_GREEN )
                   NEXT SUM = SUM + 1 ).

*- 실패 건수
  DATA(LV_CNT_E) = LV_CNT_T - LV_CNT_S.

  "전체 &1건 중 &2건 처리 성공, &3건 처리 실패
  MESSAGE S009(ZGTPP00) WITH LV_CNT_T LV_CNT_S LV_CNT_E.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VERID_DELETE_JOB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VERID_DELETE_JOB .

  CLEAR: GV_SUC.
  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_S>).
    PERFORM VERID_DELETE USING <FS_S>.
  ENDLOOP.

*- 전체 건수
  DATA(LV_CNT_T) = LINES( GT_DATA ).

*- 성공 건수
  DATA(LV_CNT_S) = GV_SUC.

*- 실패 건수
  DATA(LV_CNT_E) = LV_CNT_T - LV_CNT_S.

  "전체 &1건 중 &2건 처리 성공, &3건 처리 실패
  MESSAGE S009(ZGTPP00) WITH LV_CNT_T LV_CNT_S LV_CNT_E.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_SPGCD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_SPGCD  USING    PV_DYNPROFLD TYPE HELP_INFO-DYNPROFLD .

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : LV_OFFSET(6) TYPE N.
  DATA : LO_FLIEF TYPE REF TO DATA.

  DATA : LT_FIELD_TAB TYPE TABLE OF DFIES.
  DATA : LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  DATA : LV_LINE       LIKE SY-STEPL,
         LT_DYNPFIELDS LIKE TABLE OF DYNPREAD.

  DATA: LV_WERKS TYPE WERKS_D.

  CALL FUNCTION 'GET_DYNP_VALUE'
    EXPORTING
      I_FIELD = 'P_WERKS'
      I_REPID = SY-REPID
      I_DYNNR = '1000'
    CHANGING
      O_VALUE = LV_WERKS.

  CLEAR: GT_0107.
  SELECT DISTINCT
         WERKS, SPGCD, SPART, DESCR
    FROM ZPPT0107
   WHERE WERKS EQ @LV_WERKS
    INTO CORRESPONDING FIELDS OF TABLE @GT_0107.

  FREE LO_FLIEF.
  CREATE DATA LO_FLIEF LIKE GS_0107.

  LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_FLIEF ).
  LT_FIELD_TAB = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

  CLEAR LV_OFFSET.
  LOOP AT LT_FIELD_TAB ASSIGNING FIELD-SYMBOL(<LS_FIELD_TAB>).

    CASE <LS_FIELD_TAB>-FIELDNAME.
      WHEN 'WERKS'.
        <LS_FIELD_TAB>-REPTEXT  = 'Plant'.
      WHEN 'SPGCD'.
        <LS_FIELD_TAB>-REPTEXT  = 'SPG 코드'.
      WHEN 'SPART'.
        <LS_FIELD_TAB>-REPTEXT  = '제품군'.
      WHEN 'DESCR'.
        <LS_FIELD_TAB>-REPTEXT  = '내역'.
    ENDCASE.

    <LS_FIELD_TAB>-OFFSET = LV_OFFSET.
    LV_OFFSET = LV_OFFSET + <LS_FIELD_TAB>-INTLEN.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'SPGCD'
      DYNPROFIELD     = PV_DYNPROFLD    "F4누른 필드
      VALUE_ORG       = 'S'             "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = 'SPG 코드'      "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      FIELD_TAB       = LT_FIELD_TAB
      VALUE_TAB       = GT_0107         "데이터 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB   "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.

    REFRESH LT_DYNPFIELDS.
    PERFORM GET_STEPL USING LV_LINE.

    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING FIELD-SYMBOL(<LS_DYNPFIELDS>).
    <LS_DYNPFIELDS>-FIELDNAME = PV_DYNPROFLD.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LS_RETURN_TAB-FIELDVAL.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        DYNAME               = SY-CPROG
        DYNUMB               = SY-DYNNR
      TABLES
        DYNPFIELDS           = LT_DYNPFIELDS
      EXCEPTIONS
        INVALID_ABAPWORKAREA = 1
        INVALID_DYNPROFIELD  = 2
        INVALID_DYNPRONAME   = 3
        INVALID_DYNPRONUMMER = 4
        INVALID_REQUEST      = 5
        NO_FIELDDESCRIPTION  = 6
        UNDEFIND_ERROR       = 7
        OTHERS               = 8.
    IF SY-SUBRC <> 0.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STEPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_LINE
*&---------------------------------------------------------------------*
FORM GET_STEPL  USING    PV_LINE LIKE SY-STEPL.
  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL        = PV_LINE
    EXCEPTIONS
      STEPL_NOT_FOUND = 01.

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
*& SPG에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_SPGCD'
  ID 'WERKS'  FIELD P_WERKS
  ID 'SPGCD'  FIELD P_SPGCD.

  IF SY-SUBRC <> 0.
    "SPG[P_SPGCD] 작업권한을 확인하세요.
    MESSAGE E006 WITH TEXT-M09 P_SPGCD TEXT-M10.
  ENDIF.
ENDFORM.
