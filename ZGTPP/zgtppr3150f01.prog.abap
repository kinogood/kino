*&---------------------------------------------------------------------*
*& Include          ZGTPPR3150F01
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

  S_CRDAT[] = VALUE #( ( SIGN = GC_I
                         OPTION = GC_BT
                         LOW = SY-DATUM
                         HIGH = SY-DATUM ) ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BUTTON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BUTTON .
  CLEAR: GV_DYNTXT.
*  GV_DYNTXT-ICON_ID = '@0S@'.  "information
  GV_DYNTXT-TEXT = '배관 품목 설정'.
  GV_DYNTXT-ICON_TEXT = '배관 품목 설정'.
  GV_DYNTXT-QUICKINFO = '배관 품목 설정'.
  SSCRFIELDS-FUNCTXT_01 = GV_DYNTXT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_ZGTPPT3320
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_ZGTPPT3320 .

  DATA: L_VERID LIKE MKAL-VERID. "생산버전

  CLEAR: GT_3320.
  SELECT A~WERKS, A~F_MATN, A~T_MATN, A~F_LGORT, A~T_LGORT, A~ADD_GI,
         B~NAME1,
         C~MAKTX AS F_MAKTX,
         D~MAKTX AS T_MAKTX,
         E~LGOBE AS F_LGOBE,
         F~LGOBE AS T_LGOBE
    FROM ZGTPPT3320 AS A
    LEFT OUTER JOIN T001W AS B ON B~WERKS EQ A~WERKS
    LEFT OUTER JOIN MAKT  AS C ON C~MATNR EQ A~F_MATN
                              AND C~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN MAKT  AS D ON D~MATNR EQ A~T_MATN
                              AND D~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T001L AS E ON E~WERKS EQ A~WERKS
                              AND E~LGORT EQ A~F_LGORT
    LEFT OUTER JOIN T001L AS F ON F~WERKS EQ A~WERKS
                              AND F~LGORT EQ A~T_LGORT
    WHERE A~WERKS  EQ @P_WERKS
      AND A~F_MATN IN @S_FMATN
      AND A~T_MATN IN @S_TMATN
     INTO CORRESPONDING FIELDS OF TABLE @GT_3320.

  LOOP AT GT_3320 ASSIGNING FIELD-SYMBOL(<FS_S>).
    "BOM 존재여부
    SELECT SINGLE STLNR, STLAL, STLAN
      FROM MAST
     WHERE MATNR EQ @<FS_S>-T_MATN
       AND WERKS EQ @<FS_S>-WERKS
       AND STLAN EQ '1'
       AND STLAL EQ '01'
      INTO (@<FS_S>-STLNR, @<FS_S>-STLAL, @<FS_S>-STLAN).

    IF <FS_S>-STLNR IS NOT INITIAL.
      <FS_S>-BOM_STAT = ICON_LED_GREEN.
    ELSE.
      <FS_S>-BOM_STAT = ICON_LED_RED.
    ENDIF.

    "ROUTING 존재 여부
    SELECT SINGLE PLNTY, PLNNR, PLNAL, DATUV
      FROM MAPL
     WHERE MATNR EQ @<FS_S>-T_MATN
       AND WERKS EQ @<FS_S>-WERKS
       AND PLNTY EQ 'N'
       AND PLNAL EQ '01'
      INTO (@<FS_S>-PLNTY, @<FS_S>-PLNNR, @<FS_S>-PLNAL, @<FS_S>-DATUV).

    IF <FS_S>-PLNNR IS NOT INITIAL.
      <FS_S>-ROUT_STAT = ICON_LED_GREEN.
    ELSE.
      <FS_S>-ROUT_STAT = ICON_LED_RED.
    ENDIF.

    "생산버전 존재여부
    CLEAR: L_VERID.
    SELECT SINGLE VERID
      FROM MKAL
     WHERE MATNR EQ @<FS_S>-T_MATN
       AND WERKS EQ @<FS_S>-WERKS
       AND VERID EQ '1000'
      INTO @L_VERID.

    IF L_VERID IS NOT INITIAL.
      <FS_S>-PVER_STAT = ICON_LED_GREEN.
    ELSE.
      <FS_S>-PVER_STAT = ICON_LED_RED.
    ENDIF.

    PERFORM SET_STY_RTN_3320 CHANGING <FS_S>.
  ENDLOOP.

  "BOM 구성용
  CLEAR: GT_3320_B.
  APPEND LINES OF GT_3320 TO GT_3320_B.
  DELETE GT_3320_B WHERE BOM_STAT NE ICON_LED_RED.
  SORT GT_3320_B BY T_MATN F_MATN.

  CALL SCREEN 0200.

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
      WHEN 'P_WERKS'.
        SCREEN-REQUIRED = 2.
        MODIFY SCREEN.
    ENDCASE.

    IF P_R1 EQ GC_X.
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
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .

  CLEAR: GT_PROC.

  IF P_R1 EQ GC_X.
    SELECT A~WERKS, A~F_MATN, A~T_MATN, A~F_LGORT, A~T_LGORT, A~ADD_GI,
           B~NAME1,
           C~MAKTX AS F_MAKTX,
           D~MAKTX AS T_MAKTX,
           E~LGOBE AS F_LGOBE,
           F~LGOBE AS T_LGOBE
      FROM ZGTPPT3320 AS A
      LEFT OUTER JOIN T001W AS B ON B~WERKS EQ A~WERKS
      LEFT OUTER JOIN MAKT  AS C ON C~MATNR EQ A~F_MATN
                                AND C~SPRAS EQ @SY-LANGU
      LEFT OUTER JOIN MAKT  AS D ON D~MATNR EQ A~T_MATN
                                AND D~SPRAS EQ @SY-LANGU
      LEFT OUTER JOIN T001L AS E ON E~WERKS EQ A~WERKS
                                AND E~LGORT EQ A~F_LGORT
      LEFT OUTER JOIN T001L AS F ON F~WERKS EQ A~WERKS
                                AND F~LGORT EQ A~T_LGORT
      WHERE A~WERKS  EQ @P_WERKS
        AND A~F_MATN IN @S_FMATN
        AND A~T_MATN IN @S_TMATN
       INTO CORRESPONDING FIELDS OF TABLE @GT_PROC.

    "추가투입용 추출
    CLEAR: GT_PROX.
    APPEND LINES OF GT_PROC TO GT_PROX.

    DELETE GT_PROC WHERE ADD_GI EQ GC_X.
    DELETE GT_PROX WHERE ADD_GI EQ SPACE.

  ELSEIF P_R2 EQ GC_X.
    SELECT A~WERKS, A~F_MATN, A~T_MATN, A~F_LGORT, A~T_LGORT, A~AUFNR,
           A~CRDAT, A~CRTIM, A~CRNAM,
           C~PSMNG,
           D~NAME1,
           E~MAKTX AS F_MAKTX,
           F~MAKTX AS T_MAKTX,
           G~LGOBE AS F_LGOBE,
           H~LGOBE AS T_LGOBE
      FROM ZGTPPT3330 AS A
     INNER JOIN AUFK AS B ON B~AUFNR EQ A~AUFNR
     INNER JOIN AFPO AS C ON C~AUFNR EQ B~AUFNR
      LEFT OUTER JOIN T001W AS D ON D~WERKS EQ A~WERKS
      LEFT OUTER JOIN MAKT  AS E ON E~MATNR EQ A~F_MATN
                                AND E~SPRAS EQ @SY-LANGU
      LEFT OUTER JOIN MAKT  AS F ON F~MATNR EQ A~T_MATN
                                AND F~SPRAS EQ @SY-LANGU
      LEFT OUTER JOIN T001L AS G ON G~WERKS EQ A~WERKS
                                AND G~LGORT EQ A~F_LGORT
      LEFT OUTER JOIN T001L AS H ON H~WERKS EQ A~WERKS
                                AND H~LGORT EQ A~T_LGORT
      WHERE A~WERKS  EQ @P_WERKS
        AND A~F_MATN IN @S_FMATN
        AND A~T_MATN IN @S_TMATN
        AND A~AUFNR  IN @S_AUFNR
        AND A~CRDAT  IN @S_CRDAT
        AND B~LOEKZ  EQ @SPACE
       INTO CORRESPONDING FIELDS OF TABLE @GT_PROC.

    "추가투입용 추출
    CLEAR: GT_PROX.
    SELECT WERKS, F_MATN, T_MATN, F_LGORT, T_LGORT, ADD_GI
      FROM ZGTPPT3320
     WHERE ADD_GI EQ @GC_X
      INTO CORRESPONDING FIELDS OF TABLE @GT_PROX.

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
         GT_PROC[].

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
*  GS_LAYOUT_0100-ZEBRA      = GC_X.
  GS_LAYOUT_0100-COL_OPT    = GC_X.
  GS_LAYOUT_0100-CWIDTH_OPT = GC_X.
  GS_LAYOUT_0100-NO_ROWINS  = GC_X.
  GS_LAYOUT_0100-SEL_MODE   = GC_D.
*  GS_LAYOUT_0100-EDIT       = GC_X.
  GS_LAYOUT_0100-STYLEFNAME = 'CELL_STY'.
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
    GS_VARIANT_0100-VARIANT = P_LAYO.
  ENDIF.
  GS_VARIANT_0100-REPORT = SY-REPID.
  GS_VARIANT_0100-USERNAME = SY-UNAME.
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
      I_INCLNAME             = 'ZGTPPR3150TOP'
      I_INTERNAL_TABNAME     = 'GS_PROC'
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
      IT_DATA         = GT_PROC
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "플랜트
        <LS_FCAT>-JUST = GC_C.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'F_MATN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "전환 전 품목번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'F_MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "전환 전 품목내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'F_LGORT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "전환 전 품목창고
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'F_LGOBE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "전환 전 창고내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'F_LABST'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "전환 전 품목 재고
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'T_MATN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "전환 후 품목번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C710'.
      WHEN 'T_MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "전환 후 품목내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C710'.
      WHEN 'T_LGORT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "전환 후 품목창고
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C710'.
      WHEN 'T_LGOBE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "전환 후 창고내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C710'.
      WHEN 'T_LABST'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "전환 후 품목 재고
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C710'.
      WHEN 'PSTD_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F34. "생산기준정보
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C710'.
      WHEN 'AUART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F13. "오더유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZMESSAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "메시지
        <LS_FCAT>-JUST = GC_L.
      WHEN '1ST_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "오더 상태
        <LS_FCAT>-JUST = GC_C.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "생산오더번호
        <LS_FCAT>-JUST = GC_C.
        IF P_R2 EQ GC_X.
          <LS_FCAT>-HOTSPOT = GC_X.
        ENDIF.
      WHEN 'PSMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "전환 품목 수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-EDIT = GC_X.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "전환 품목 단위
        <LS_FCAT>-JUST = GC_C.
      WHEN '2ND_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "투입 상태
        <LS_FCAT>-JUST = GC_C.
      WHEN 'F_MBLNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "전환 전 품목 투입
        <LS_FCAT>-JUST = GC_C.
        IF P_R2 EQ GC_X.
          <LS_FCAT>-HOTSPOT = GC_X.
        ENDIF.
      WHEN '3RD_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "입고 상태
        <LS_FCAT>-JUST = GC_C.
      WHEN 'T_MBLNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "전환 후 품목 입고
        <LS_FCAT>-JUST = GC_C.
        IF P_R2 EQ GC_X.
          <LS_FCAT>-HOTSPOT = GC_X.
        ENDIF.
      WHEN '4TH_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F27. "확정 상태
        <LS_FCAT>-JUST = GC_C.
      WHEN 'RUECK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F28. "확정 번호
        <LS_FCAT>-JUST = GC_C.
        IF P_R2 EQ GC_X.
          <LS_FCAT>-HOTSPOT = GC_X.
        ENDIF.
      WHEN 'BUDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F23. "전기일자
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EDIT = GC_X.
      WHEN 'CRDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F24. "생성일자
        <LS_FCAT>-JUST = GC_C.
      WHEN 'CRTIM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F25. "생성시간
        <LS_FCAT>-JUST = GC_C.
      WHEN 'CRNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F26. "생성자
        <LS_FCAT>-JUST = GC_C.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

    IF P_R1 EQ GC_X.
      IF <LS_FCAT>-FIELDNAME = 'CRDAT' OR <LS_FCAT>-FIELDNAME = 'CRTIM' OR
         <LS_FCAT>-FIELDNAME = 'CRNAM'.
        <LS_FCAT>-NO_OUT = GC_X.
      ENDIF.
    ELSEIF P_R2 EQ GC_X.
      IF <LS_FCAT>-FIELDNAME = 'F_LABST' OR <LS_FCAT>-FIELDNAME = 'T_LABST' OR
         <LS_FCAT>-FIELDNAME = 'PSTD_STAT'.
        <LS_FCAT>-NO_OUT = GC_X.
      ENDIF.
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
      SET HANDLER: GO_EVTR_0100->HDL_DATA_CHANGED FOR GO_GRID_0100.
      SET HANDLER: GO_EVTR_0100->HDL_HOTSPOT_CLICK FOR GO_GRID_0100.
    WHEN GO_GRID_0200.
      SET HANDLER: GO_EVTR_0100->HDL_DATA_CHANGED FOR GO_GRID_0200.
  ENDCASE.

* 인풋이벤트 추가
  CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

* DATA CHANGE
  CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
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
      IS_VARIANT           = GS_VARIANT_0100
      I_SAVE               = GC_X
    CHANGING
      IT_OUTTAB            = GT_PROC
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STY_RTN_3320
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_S>
*&---------------------------------------------------------------------*
FORM SET_STY_RTN_3320  CHANGING P_LINE LIKE GS_3320.

  DATA: LS_STY TYPE LVC_S_STYL.

  DEFINE SET_STY.
    IF &2 EQ 'X'.
      LS_STY-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    ELSE.
      LS_STY-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
    ENDIF.

    LS_STY-FIELDNAME = &1.
    INSERT LS_STY INTO TABLE P_LINE-CELL_STY.
    CLEAR LS_STY.
  END-OF-DEFINITION.

  CLEAR : P_LINE-CELL_STY.

  SET_STY 'WERKS'      SPACE.
  SET_STY 'NAME1'      'X'.
  SET_STY 'F_MATN'     SPACE.
  SET_STY 'F_MAKTX'    'X'.
  SET_STY 'F_LGORT'    SPACE.
  SET_STY 'F_LGOBE'    'X'.
  SET_STY 'T_MATN'     SPACE.
  SET_STY 'T_MAKTX'    'X'.
  SET_STY 'T_LGORT'    SPACE.
  SET_STY 'T_LGOBE'    'X'.
  SET_STY 'ADD_GI'     SPACE.
  SET_STY 'BOM_STAT'   'X'.
  SET_STY 'ROUT_STAT'  'X'.
  SET_STY 'PVER_STAT'  'X'.
  SET_STY 'PROC_MSG'   'X'.
  SET_STY 'STLNR'      'X'.
  SET_STY 'STLAL'      'X'.
  SET_STY 'STLAN'      'X'.
  SET_STY 'PLNTY'      'X'.
  SET_STY 'PLNNR'      'X'.
  SET_STY 'PLNAL'      'X'.
  SET_STY 'DATUV'      'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0200 .
  CREATE OBJECT GO_CONTAIN_0200
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

  CREATE OBJECT GO_GRID_0200
    EXPORTING
      I_PARENT      = GO_CONTAIN_0200
      I_APPL_EVENTS = ABAP_TRUE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0200 .
  CLEAR GS_LAYOUT_0200.
*  GS_LAYOUT_0200-ZEBRA      = GC_X.
  GS_LAYOUT_0200-COL_OPT    = GC_X.
*  GS_LAYOUT_0200-CWIDTH_OPT = GC_X.
  GS_LAYOUT_0200-NO_ROWINS  = GC_X.
  GS_LAYOUT_0200-SEL_MODE   = GC_D.
*  GS_LAYOUT_0200-EDIT       = GC_X.
  GS_LAYOUT_0200-STYLEFNAME = 'CELL_STY'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_VARIANT_GRID_0200 .
  IF P_LAYO IS NOT INITIAL.
    GS_VARIANT_0200-VARIANT = P_LAYO.
  ENDIF.
  GS_VARIANT_0200-REPORT = SY-REPID.
  GS_VARIANT_0200-USERNAME = SY-UNAME.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0200 .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3150TOP'
      I_INTERNAL_TABNAME     = 'GS_3320'
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
      ET_FIELDCAT_LVC = GT_FIELDCAT_0200[]
    TABLES
      IT_DATA         = GT_3320
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0200 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "플랜트
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EDIT = GC_X.
        <LS_FCAT>-OUTPUTLEN = '10'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '15'.
      WHEN 'F_MATN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "전환 전 품목번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EDIT = GC_X.
        <LS_FCAT>-OUTPUTLEN = '15'.
      WHEN 'F_MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "전환 전 품목내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-OUTPUTLEN = '20'.
      WHEN 'F_LGORT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "전환 전 품목창고
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EDIT = GC_X.
        <LS_FCAT>-OUTPUTLEN = '15'.
      WHEN 'F_LGOBE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "전환 전 창고내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-OUTPUTLEN = '20'.
      WHEN 'T_MATN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "전환 후 품목번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EDIT = GC_X.
        <LS_FCAT>-OUTPUTLEN = '15'.
      WHEN 'T_MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "전환 후 품목내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C710'.
        <LS_FCAT>-OUTPUTLEN = '20'.
      WHEN 'T_LGORT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "전환 후 품목창고
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EDIT = GC_X.
        <LS_FCAT>-OUTPUTLEN = '15'.
      WHEN 'T_LGOBE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "전환 후 창고내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C710'.
        <LS_FCAT>-OUTPUTLEN = '20'.
      WHEN 'ADD_GI'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F29. "추가투입
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-CHECKBOX = GC_X.
        <LS_FCAT>-EDIT = GC_X.
        <LS_FCAT>-OUTPUTLEN = '10'.
      WHEN 'BOM_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F30. "BOM
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EDIT = GC_X.
        <LS_FCAT>-OUTPUTLEN = '10'.
      WHEN 'ROUT_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F31. "라우팅
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EDIT = GC_X.
        <LS_FCAT>-OUTPUTLEN = '10'.
      WHEN 'PVER_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F32. "생산버전
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EDIT = GC_X.
        <LS_FCAT>-OUTPUTLEN = '10'.
      WHEN 'PROC_MSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F33. "처리메시지
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '20'.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0200 .
  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0200
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
*& Form CALL_GRID_0200_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0200_DISPLAY .
  CALL METHOD GO_GRID_0200->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0200
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0200
      IS_VARIANT           = GS_VARIANT_0200
      I_SAVE               = GC_X
    CHANGING
      IT_OUTTAB            = GT_3320
      IT_FIELDCATALOG      = GT_FIELDCAT_0200.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLS_OBJT_RTN_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CLS_OBJT_RTN_0200 .
  CLEAR: GT_FIELDCAT_0200[], GS_LAYOUT_0200, GT_EXCLUDE_0200[],
         GT_EXCLUDE_0200,
         GV_OK_CODE, GV_DBCNT,
         GT_3320[].

  CALL METHOD GO_CONTAIN_0200->FREE.
  CLEAR : GO_CONTAIN_0200, GO_GRID_0200.
  CALL METHOD CL_GUI_CFW=>FLUSH.
  LEAVE TO SCREEN 0.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ZSAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_ZSAVE .
  DATA: L_ANSWER TYPE CHAR01.

  DATA: LT_ZGTPPT3320 LIKE TABLE OF ZGTPPT3320,
        LS_ZGTPPT3320 LIKE ZGTPPT3320.

  DATA: LV_CX_REF TYPE REF TO CX_ROOT.

  FIELD-SYMBOLS: <FS_S> LIKE GS_3320.

  CLEAR: L_ANSWER.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T04 "배관 품목 저장
      TEXT_QUESTION         = TEXT-T05 "데이터를 저장하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: LT_ZGTPPT3320.
    LOOP AT GT_3320 INTO GS_3320.
      MOVE-CORRESPONDING GS_3320 TO LS_ZGTPPT3320.
      MOVE: SY-DATUM TO LS_ZGTPPT3320-CRDAT,
            SY-UZEIT TO LS_ZGTPPT3320-CRTIM,
            SY-UNAME TO LS_ZGTPPT3320-CRNAM.

      APPEND LS_ZGTPPT3320 TO LT_ZGTPPT3320.
      CLEAR: GS_3320, LS_ZGTPPT3320.
    ENDLOOP.

    DELETE FROM ZGTPPT3320 WHERE WERKS EQ P_WERKS.

    IF LT_ZGTPPT3320 IS NOT INITIAL.
      TRY.
          INSERT ZGTPPT3320 FROM TABLE LT_ZGTPPT3320.
          IF SY-SUBRC EQ 0.
            COMMIT WORK.
          ELSE.
            ROLLBACK WORK.
          ENDIF.
        CATCH CX_ROOT INTO LV_CX_REF.
          ROLLBACK WORK.
      ENDTRY.
    ENDIF.

    MESSAGE S004.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEL_ROW_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROW_NO
*&      --> GO_GRID_0200
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

    WHEN GO_GRID_0200.
      CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
        EXPORTING
          IS_LAYOUT = GS_LAYOUT_0200.
  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ADDLINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_ADDLINE .

  CLEAR: GS_3320.

  GS_3320-WERKS = P_WERKS.

  SELECT SINGLE NAME1
    FROM T001W
   WHERE WERKS EQ @P_WERKS
    INTO @GS_3320-NAME1.

  PERFORM SET_STY_RTN_3320 CHANGING GS_3320.
  APPEND GS_3320 TO GT_3320.

  " REFRESH DISPLAY
  PERFORM REF_ALV_RTN USING GO_GRID_0200.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DELLINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_DELLINE .

  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_3320.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0200.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M02. "레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T06 "배관 품목 삭제
      TEXT_QUESTION         = TEXT-T07 "선택한 레코드를 삭제하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    SORT LT_ROW_NO BY ROW_ID DESCENDING.

    LOOP AT LT_ROW_NO.
      READ TABLE GT_3320 ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      DELETE GT_3320 INDEX LT_ROW_NO-ROW_ID.

    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0200.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_NAME1_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LVC_S_MODI
*&      <-- ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM SET_NAME1_RTN    USING    P_LVC_S_MODI   TYPE LVC_S_MODI
                      CHANGING P_DATA_CHANGED
                               TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA: L_WERKS TYPE WERKS_D,
        L_NAME1 TYPE NAME1.

  DATA: L_VALUE TYPE LVC_S_MODI-VALUE.

  FIELD-SYMBOLS: <FS_3> LIKE GS_3320.

  READ TABLE GT_3320 ASSIGNING <FS_3> INDEX P_LVC_S_MODI-ROW_ID.

  L_VALUE = P_LVC_S_MODI-VALUE.

  TRANSLATE L_VALUE TO UPPER CASE.

  CLEAR: L_WERKS, L_NAME1.
  SELECT SINGLE WERKS, NAME1
    FROM T001W
   WHERE WERKS EQ @L_VALUE
    INTO (@L_WERKS, @L_NAME1).

  IF L_WERKS IS INITIAL AND L_NAME1 IS INITIAL.
    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'WERKS'
        I_VALUE     = <FS_3>-WERKS.

    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'NAME1'
        I_VALUE     = <FS_3>-NAME1.

  ELSE.
    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'NAME1'
        I_VALUE     = L_NAME1.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MAKTX_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LVC_S_MODI
*&      <-- ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM SET_MAKTX_RTN  USING    P_LVC_S_MODI   TYPE LVC_S_MODI
                    CHANGING P_DATA_CHANGED
                             TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA: L_MATNR TYPE MATNR,
        L_MAKTX TYPE MAKTX.

  DATA: L_VALUE TYPE LVC_S_MODI-VALUE.

  FIELD-SYMBOLS: <FS_3> LIKE GS_3320.

  READ TABLE GT_3320 ASSIGNING <FS_3> INDEX P_LVC_S_MODI-ROW_ID.

  L_VALUE = P_LVC_S_MODI-VALUE.

  TRANSLATE L_VALUE TO UPPER CASE.

  CLEAR: L_MATNR.
  L_MATNR = L_VALUE.

  PERFORM CONV_MATN1 USING GC_I
                     CHANGING L_MATNR.

  CLEAR: L_MAKTX.
  SELECT SINGLE MAKTX
    FROM MARC AS A
    LEFT OUTER JOIN MAKT AS B ON B~MATNR EQ A~MATNR
                             AND B~SPRAS EQ @SY-LANGU
   WHERE A~WERKS EQ @<FS_3>-WERKS
     AND A~MATNR EQ @L_MATNR
    INTO @L_MAKTX.

  PERFORM CONV_MATN1 USING GC_O
                     CHANGING L_MATNR.

  IF L_MAKTX IS INITIAL.
    IF P_LVC_S_MODI-FIELDNAME EQ 'F_MATN'.
      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'F_MATN'
          I_VALUE     = <FS_3>-F_MATN.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'F_MAKTX'
          I_VALUE     = <FS_3>-F_MAKTX.

    ELSEIF P_LVC_S_MODI-FIELDNAME EQ 'T_MATN'.
      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'T_MATN'
          I_VALUE     = <FS_3>-T_MATN.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'T_MAKTX'
          I_VALUE     = <FS_3>-T_MAKTX.
    ENDIF.

  ELSE.
    IF P_LVC_S_MODI-FIELDNAME EQ 'F_MATN'.
      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'F_MAKTX'
          I_VALUE     = L_MAKTX.
    ELSEIF P_LVC_S_MODI-FIELDNAME EQ 'T_MATN'.
      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'T_MAKTX'
          I_VALUE     = L_MAKTX.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LGOBE_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LVC_S_MODI
*&      <-- ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM SET_LGOBE_RTN  USING    P_LVC_S_MODI   TYPE LVC_S_MODI
                    CHANGING P_DATA_CHANGED
                             TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA: L_LGOBE TYPE LGOBE.

  DATA: L_VALUE TYPE LVC_S_MODI-VALUE.

  FIELD-SYMBOLS: <FS_3> LIKE GS_3320.

  READ TABLE GT_3320 ASSIGNING <FS_3> INDEX P_LVC_S_MODI-ROW_ID.

  L_VALUE = P_LVC_S_MODI-VALUE.

  TRANSLATE L_VALUE TO UPPER CASE.

  CLEAR: L_LGOBE.
  SELECT SINGLE LGOBE
    FROM T001L
   WHERE WERKS EQ @<FS_3>-WERKS
     AND LGORT EQ @L_VALUE
    INTO @L_LGOBE.

  IF L_LGOBE IS INITIAL.
    IF P_LVC_S_MODI-FIELDNAME EQ 'F_LGORT'.
      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'F_LGORT'
          I_VALUE     = <FS_3>-F_LGORT.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'F_LGOBE'
          I_VALUE     = <FS_3>-F_LGOBE.

    ELSEIF P_LVC_S_MODI-FIELDNAME EQ 'T_LGOET'.
      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'T_LGORT'
          I_VALUE     = <FS_3>-T_LGORT.

      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'T_LGOBE'
          I_VALUE     = <FS_3>-T_LGOBE.
    ENDIF.

  ELSE.
    IF P_LVC_S_MODI-FIELDNAME EQ 'F_LGORT'.
      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'F_LGOBE'
          I_VALUE     = L_LGOBE.
    ELSEIF P_LVC_S_MODI-FIELDNAME EQ 'T_LGORT'.
      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
          I_TABIX     = P_LVC_S_MODI-TABIX
          I_FIELDNAME = 'T_LGOBE'
          I_VALUE     = L_LGOBE.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ORDCRE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_ORDCRE .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_PROC.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M02. "레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T08 "생산오더 생성
      TEXT_QUESTION         = TEXT-T09 "생산오더 생성을 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: GV_TIMESTAMP, GV_ZSEQNO.

    GET TIME STAMP FIELD GV_TIMESTAMP.

    LOOP AT LT_ROW_NO.
      READ TABLE GT_PROC ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-1ST_STAT EQ ICON_LED_GREEN.
        <FS_S>-ZMESSAGE = TEXT-M03. "이미 오더 생성이 완료된 레코드가 선택되었습니다.
      ELSE.
        IF <FS_S>-PSMNG EQ 0.
          <FS_S>-ZMESSAGE = TEXT-M15. "품목 전환 수량을 입력하세요.
        ELSE.
          PERFORM EXEC_ORD_CREATE USING <FS_S>.
        ENDIF.
      ENDIF.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_ORD_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_ORD_CREATE  USING    P_LINE LIKE GS_PROC.
  DATA: LT_PRD_ORDERS TYPE TB_BAPI_ORDER_KEY.
  DATA: LS_ORDER TYPE BAPI_PP_ORDER_CREATE.
  DATA: LS_RETURN TYPE BAPIRET2.
  DATA: LV_ORDER_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER.

  DATA: LT_ORDERS	TYPE BAPI_ORDER_KEY OCCURS 0 WITH HEADER LINE,
        LT_RETURN	TYPE BAPIRET2 OCCURS 0 WITH HEADER LINE.

  DATA: LS_ZGTPPT3330 LIKE ZGTPPT3330.

  CLEAR : LS_ORDER, LS_RETURN, LV_ORDER_NUMBER.
*  오더 생성
  LS_ORDER-MATERIAL              = P_LINE-T_MATN.
  LS_ORDER-PLANT                 = P_LINE-WERKS.
  LS_ORDER-ORDER_TYPE            = GC_PP01.
  LS_ORDER-BASIC_START_DATE      = P_LINE-BUDAT.
  LS_ORDER-BASIC_START_TIME      = '000000'.
  LS_ORDER-BASIC_END_DATE        = P_LINE-BUDAT.
  LS_ORDER-BASIC_END_TIME        = '000000'.
  LS_ORDER-QUANTITY              = P_LINE-PSMNG.
  LS_ORDER-QUANTITY_UOM          = P_LINE-MEINS.
  LS_ORDER-PROD_VERSION          = '1000'.
  LS_ORDER-BASIC_SCHEDULING_TYPE = '3'.

  CALL FUNCTION 'BAPI_PRODORD_CREATE'
    EXPORTING
      ORDERDATA    = LS_ORDER
    IMPORTING
      RETURN       = LS_RETURN
      ORDER_NUMBER = LV_ORDER_NUMBER.

  IF LS_RETURN-TYPE NE GC_E.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

* 커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
    DO .
      SELECT SINGLE AUFNR, POSNR
        FROM AFPO
       WHERE AUFNR = @LV_ORDER_NUMBER
        INTO @DATA(LS_AFPO).
      IF SY-SUBRC EQ 0.
        EXIT.
      ELSE.
        WAIT UP TO '0.5' SECONDS.
      ENDIF.
    ENDDO.

    CLEAR: LT_RETURN, LT_RETURN[], LT_ORDERS, LT_ORDERS[].
    LT_ORDERS-ORDER_NUMBER = LV_ORDER_NUMBER.
    APPEND LT_ORDERS.

    CALL FUNCTION 'BAPI_PRODORD_RELEASE'
      EXPORTING
        RELEASE_CONTROL    = '1'
        WORK_PROCESS_GROUP = 'COWORK_BAPI'
        WORK_PROCESS_MAX   = 99
      IMPORTING
        RETURN             = LT_RETURN
      TABLES
        ORDERS             = LT_ORDERS.

    READ TABLE LT_RETURN WITH KEY TYPE = 'E'.
    IF SY-SUBRC NE 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
      WAIT UP TO '0.5' SECONDS.

      P_LINE-1ST_STAT = ICON_LED_GREEN.
      P_LINE-ZMESSAGE = TEXT-M04. "오더 생성에 성공하였습니다.
      P_LINE-AUFNR = LV_ORDER_NUMBER.

      ADD 1 TO GV_ZSEQNO.

* ZGTPPT3330 저장
      CLEAR: LS_ZGTPPT3330.
      LS_ZGTPPT3330-ZDATETIME = GV_TIMESTAMP.
      LS_ZGTPPT3330-ZSEQNO    = GV_ZSEQNO.
      LS_ZGTPPT3330-WERKS     = P_LINE-WERKS.
      LS_ZGTPPT3330-F_MATN    = P_LINE-F_MATN.
      LS_ZGTPPT3330-T_MATN    = P_LINE-T_MATN.
      LS_ZGTPPT3330-F_LGORT   = P_LINE-F_LGORT.
      LS_ZGTPPT3330-T_LGORT   = P_LINE-T_LGORT.
      LS_ZGTPPT3330-AUFNR     = P_LINE-AUFNR.
      LS_ZGTPPT3330-CRDAT     = SY-DATUM.
      LS_ZGTPPT3330-CRTIM     = SY-UZEIT.
      LS_ZGTPPT3330-CRNAM     = SY-UNAME.

      MODIFY ZGTPPT3330 FROM LS_ZGTPPT3330.
      IF SY-SUBRC EQ 0.
        COMMIT WORK.
      ELSE.
        ROLLBACK WORK.
      ENDIF.

    ELSE.
*      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      READ TABLE LT_RETURN WITH KEY TYPE = 'E'.
      P_LINE-1ST_STAT = ICON_LED_RED.
      P_LINE-ZMESSAGE = LT_RETURN-MESSAGE.

    ENDIF.

  ELSE.
    P_LINE-1ST_STAT = ICON_LED_RED.
    P_LINE-ZMESSAGE = LS_RETURN-MESSAGE.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ORDDEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_ORDDEL .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_PROC.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M02. "레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T10 "생산오더 삭제 설정
      TEXT_QUESTION         = TEXT-T11 "생산오더 삭제 설정을 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_PROC ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-AUFNR IS NOT INITIAL.
        IF <FS_S>-2ND_STAT EQ ICON_LED_GREEN AND
           <FS_S>-3RD_STAT EQ ICON_LED_GREEN.
          <FS_S>-ZMESSAGE = TEXT-M13. "실적이 입력된 생산오더는 삭제 설정이 불가합니다.

        ELSE.
          PERFORM EXEC_ORD_DELETE USING <FS_S>.
        ENDIF.

      ENDIF.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_ORD_DELETE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_ORD_DELETE  USING    P_LINE LIKE GS_PROC.

  DATA: LT_ORDERS	       TYPE BAPI_ORDER_KEY OCCURS 0 WITH HEADER LINE,
        LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN OCCURS 0 WITH HEADER LINE.

  CLEAR: LT_DETAIL_RETURN, LT_DETAIL_RETURN[], LT_ORDERS, LT_ORDERS[].

  LT_ORDERS-ORDER_NUMBER = P_LINE-AUFNR.
  APPEND LT_ORDERS.

  CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
    EXPORTING
      WORK_PROCESS_GROUP = 'COWORK_BAPI'
      WORK_PROCESS_MAX   = 99
    TABLES
      ORDERS             = LT_ORDERS
      DETAIL_RETURN      = LT_DETAIL_RETURN.

  READ TABLE LT_DETAIL_RETURN WITH KEY TYPE = GC_E.
  IF SY-SUBRC NE 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    P_LINE-ZMESSAGE = TEXT-M14. "생산오더 삭제 설정에 성공하였습니다.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    READ TABLE LT_DETAIL_RETURN WITH KEY TYPE = 'E'.
    P_LINE-ZMESSAGE = LT_DETAIL_RETURN-MESSAGE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_MATGIGRCF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_MATGIGRCF .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_PROC.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M02. "레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T12 "배관 실적 처리
      TEXT_QUESTION         = TEXT-T13 "배관 실적 처리를 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_PROC ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-2ND_STAT EQ ICON_LED_GREEN AND
         <FS_S>-3RD_STAT EQ ICON_LED_GREEN AND
         <FS_S>-4TH_STAT EQ ICON_LED_GREEN.
        <FS_S>-ZMESSAGE = TEXT-M05. "이미 배관 실적 처리가 완료된 레코드가 선택되었습니다.
      ELSE.
        IF <FS_S>-GSTRP+0(6) NE <FS_S>-BUDAT+0(6).
          <FS_S>-ZMESSAGE = TEXT-M18. "생산오더의 시작월과 전기월이 서로 다릅니다.
        ELSE.
          IF <FS_S>-PSMNG GT 0.
            IF <FS_S>-2ND_STAT NE ICON_LED_GREEN.
              PERFORM EXEC_MAT_GI USING <FS_S>.
            ENDIF.
            IF <FS_S>-2ND_STAT EQ ICON_LED_GREEN AND
               <FS_S>-3RD_STAT NE ICON_LED_GREEN.
              PERFORM EXEC_MAT_GR USING <FS_S>.
            ENDIF.
            IF <FS_S>-3RD_STAT EQ ICON_LED_GREEN.
              PERFORM EXEC_PRD_CONF USING <FS_S>.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_MAT_GI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_MAT_GI  USING    P_LINE LIKE GS_PROC.

  DATA: LS_HEADER    TYPE BAPI2017_GM_HEAD_01,
        LT_ITEM      TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LV_CODE      TYPE BAPI2017_GM_CODE VALUE '03',
        LV_DOCUMENT  TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_YEAR      TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LS_GMHEADRET LIKE BAPI2017_GM_HEAD_RET,
        LT_RETURN    TYPE TABLE OF BAPIRET2.

  CLEAR: LS_HEADER, LT_ITEM.

  LS_HEADER = VALUE #( PSTNG_DATE = P_LINE-BUDAT
                       HEADER_TXT = '배관 실적 처리' ).

  LT_ITEM = VALUE #( ( MATERIAL  = P_LINE-F_MATN
                       PLANT     = P_LINE-WERKS
                       STGE_LOC  = P_LINE-F_LGORT
                       MOVE_TYPE = GC_261
                       MVT_IND   = SPACE
                       STCK_TYPE = SPACE
                       ENTRY_UOM = P_LINE-MEINS
                       ENTRY_QNT = P_LINE-PSMNG
                       ORDERID   = P_LINE-AUFNR ) ).

  "추가 투입 자재 추가
  LOOP AT GT_PROX INTO DATA(LS_PROX) WHERE WERKS EQ P_LINE-WERKS
                                       AND T_MATN EQ P_LINE-T_MATN.

    APPEND INITIAL LINE TO LT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM>).
    <FS_ITEM> = VALUE #( MATERIAL  = LS_PROX-F_MATN
                         PLANT     = LS_PROX-WERKS
                         STGE_LOC  = LS_PROX-F_LGORT
                         MOVE_TYPE = GC_261
                         MVT_IND   = SPACE
                         STCK_TYPE = SPACE
                         ENTRY_UOM = P_LINE-MEINS
                         ENTRY_QNT = P_LINE-PSMNG
                         ORDERID   = P_LINE-AUFNR ).
  ENDLOOP.

  CLEAR: LV_DOCUMENT, LV_YEAR, LS_GMHEADRET, LT_RETURN.
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

    READ TABLE LT_RETURN INTO DATA(LS_RETURN) WITH KEY TYPE = GC_E.
    IF LS_RETURN-MESSAGE IS INITIAL.
      P_LINE-ZMESSAGE = TEXT-M06. "품목 투입 처리 도중 오류가 발생하였습니다.
    ELSE.
      P_LINE-ZMESSAGE = LS_RETURN-MESSAGE.
    ENDIF.
    P_LINE-2ND_STAT = ICON_LED_RED.

    CLEAR: LS_RETURN.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = GC_X.

    P_LINE-2ND_STAT = ICON_LED_GREEN.
    P_LINE-ZMESSAGE = TEXT-M07. "품목 투입 처리에 성공하였습니다.
    P_LINE-F_MBLNR = LV_DOCUMENT.

    WAIT UP TO '0.5' SECONDS.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_MAT_GR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_MAT_GR  USING    P_LINE LIKE GS_PROC.

  DATA: LS_HEADER    TYPE BAPI2017_GM_HEAD_01,
        LT_ITEM      TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LV_CODE      TYPE BAPI2017_GM_CODE VALUE '02',
        LV_DOCUMENT  TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_YEAR      TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LS_GMHEADRET LIKE BAPI2017_GM_HEAD_RET,
        LT_RETURN    TYPE TABLE OF BAPIRET2.

  CLEAR: LS_HEADER, LT_ITEM.

  LS_HEADER = VALUE #( PSTNG_DATE = P_LINE-BUDAT
                       HEADER_TXT = '배관 실적 처리' ).

  LT_ITEM = VALUE #( ( MATERIAL  = P_LINE-T_MATN
                       PLANT     = P_LINE-WERKS
                       STGE_LOC  = P_LINE-T_LGORT
                       MOVE_TYPE = GC_101
                       MVT_IND   = GC_F
                       STCK_TYPE = SPACE
                       ENTRY_UOM = P_LINE-MEINS
                       ENTRY_QNT = P_LINE-PSMNG
                       ORDERID   = P_LINE-AUFNR ) ).

  CLEAR: LV_DOCUMENT, LV_YEAR, LS_GMHEADRET, LT_RETURN.
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

    READ TABLE LT_RETURN INTO DATA(LS_RETURN) WITH KEY TYPE = GC_E.
    IF LS_RETURN-MESSAGE IS INITIAL.
      P_LINE-ZMESSAGE = TEXT-M08. "품목 입고 처리 도중 오류가 발생하였습니다.
    ELSE.
      P_LINE-ZMESSAGE = LS_RETURN-MESSAGE.
    ENDIF.
    P_LINE-3RD_STAT = ICON_LED_RED.

    CLEAR: LS_RETURN.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = GC_X.

    P_LINE-3RD_STAT = ICON_LED_GREEN.
    P_LINE-ZMESSAGE = TEXT-M09. "품목 입고 처리에 성공하였습니다.
    P_LINE-T_MBLNR = LV_DOCUMENT.

    WAIT UP TO '0.5' SECONDS.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_MATGIGRCFC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_MATGIGRCFC .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_PROC.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M02. "레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T14 "실적 처리 취소
      TEXT_QUESTION         = TEXT-T15 "실적 처리 취소를 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_PROC ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-2ND_STAT EQ ICON_LED_RED AND
         <FS_S>-3RD_STAT EQ ICON_LED_RED AND
         <FS_S>-4TH_STAT EQ ICON_LED_RED.
        <FS_S>-ZMESSAGE = TEXT-M10. "실적 처리 취소할 레코드가 없습니다.
      ELSE.
        IF <FS_S>-GSTRP+0(6) NE <FS_S>-BUDAT+0(6).
          <FS_S>-ZMESSAGE = TEXT-M18. "생산오더의 시작월과 전기월이 서로 다릅니다.
        ELSE.
          IF <FS_S>-PSMNG GT 0.
            IF <FS_S>-RUECK IS NOT INITIAL.
              PERFORM EXEC_PRD_CONF_C USING <FS_S>.
            ENDIF.
            IF <FS_S>-T_MBLNR IS NOT INITIAL.
              PERFORM EXEC_MAT_GR_C USING <FS_S>.
            ENDIF.
            IF <FS_S>-T_MBLNR IS INITIAL AND
               <FS_S>-F_MBLNR IS NOT INITIAL.
              PERFORM EXEC_MAT_GI_C USING <FS_S>.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_MAT_GR_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_MAT_GR_C  USING    P_LINE LIKE GS_PROC.
  DATA: LT_RETURN     TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
        LS_RETURNS    TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
        LS_GOODSMVT   TYPE BAPI2017_GM_HEAD_RET,
        LV_HEADER_TXT TYPE BAPI2017_GM_HEAD_02-HEADER_TXT.

  CLEAR: LT_RETURN, LS_RETURNS, LS_GOODSMVT.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT = P_LINE-T_MBLNR
      MATDOCUMENTYEAR  = P_LINE-T_MJAHR
    IMPORTING
      GOODSMVT_HEADRET = LS_GOODSMVT
    TABLES
      RETURN           = LT_RETURN.

  IF LS_GOODSMVT-MAT_DOC IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = GC_X.

    P_LINE-3RD_STAT = ICON_LED_INACTIVE.
    CLEAR: P_LINE-T_MBLNR.

    WAIT UP TO '0.5' SECONDS.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CLEAR: LT_RETURN.
    READ TABLE LT_RETURN WITH KEY TYPE = GC_E.
    IF LT_RETURN-MESSAGE IS INITIAL.
      P_LINE-ZMESSAGE = TEXT-M11. "입고 취소 처리 도중 오류가 발생하였습니다.
    ELSE.
      P_LINE-ZMESSAGE = LT_RETURN-MESSAGE.
    ENDIF.

  ENDIF.

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

  LOOP AT GT_PROC ASSIGNING FIELD-SYMBOL(<FS_S>).
    "전환 품목 단위 정보
    SELECT SINGLE MEINS
      FROM MARA
     WHERE MATNR EQ @<FS_S>-F_MATN
      INTO @<FS_S>-MEINS.

    "전기일자
    <FS_S>-BUDAT = SY-DATUM.

    IF P_R1 EQ GC_X.
      "전환 전 품목 재고
      SELECT SINGLE LABST
        FROM MARD
       WHERE MATNR EQ @<FS_S>-F_MATN
         AND WERKS EQ @<FS_S>-WERKS
         AND LGORT EQ @<FS_S>-F_LGORT
        INTO @<FS_S>-F_LABST.

      "전환 후 품목 재고
      SELECT SINGLE LABST
        FROM MARD
       WHERE MATNR EQ @<FS_S>-T_MATN
         AND WERKS EQ @<FS_S>-WERKS
         AND LGORT EQ @<FS_S>-T_LGORT
        INTO @<FS_S>-T_LABST.

      "생산기준정보 존재유무:생산버전 생성유무로 확인
      SELECT SINGLE VERID
        FROM MKAL
       WHERE MATNR EQ @<FS_S>-T_MATN
         AND WERKS EQ @<FS_S>-WERKS
         AND VERID EQ '1000'
        INTO @DATA(LV_VERID).

      IF LV_VERID IS NOT INITIAL.
        <FS_S>-PSTD_STAT = ICON_LED_GREEN.
      ELSE.
        <FS_S>-PSTD_STAT = ICON_LED_RED.
      ENDIF.

      <FS_S>-AUART = GC_PP01.
      <FS_S>-GSTRP = SY-DATUM.
      <FS_S>-1ST_STAT = ICON_LED_INACTIVE.
      <FS_S>-2ND_STAT = ICON_LED_INACTIVE.
      <FS_S>-3RD_STAT = ICON_LED_INACTIVE.
      <FS_S>-4TH_STAT = ICON_LED_INACTIVE.

    ELSEIF P_R2 EQ GC_X.
      "오더 정보
      SELECT SINGLE A~AUART, B~GSTRP
        FROM AUFK AS A
       INNER JOIN AFKO AS B ON B~AUFNR EQ A~AUFNR
       WHERE A~AUFNR EQ @<FS_S>-AUFNR
        INTO (@<FS_S>-AUART, @<FS_S>-GSTRP).

      "오더 상태
      IF <FS_S>-AUFNR IS NOT INITIAL.
        <FS_S>-1ST_STAT = ICON_LED_GREEN.
      ELSE.
        <FS_S>-1ST_STAT = ICON_LED_INACTIVE.
      ENDIF.

      "전환 전 품목 투입 정보
      SELECT SINGLE MBLNR, MJAHR, MENGE
        FROM MATDOC
       WHERE AUFNR EQ @<FS_S>-AUFNR
         AND BWART EQ @GC_261
         AND CANCELLED EQ @SPACE
        INTO (@<FS_S>-F_MBLNR, @<FS_S>-F_MJAHR, @<FS_S>-PSMNG).

      "투입상태
      IF <FS_S>-F_MBLNR IS NOT INITIAL.
        <FS_S>-2ND_STAT = ICON_LED_GREEN.
      ELSE.
        <FS_S>-2ND_STAT = ICON_LED_INACTIVE.
      ENDIF.

      "전환 후 품목 입고 정보
      SELECT SINGLE MBLNR, MJAHR
        FROM MATDOC
       WHERE AUFNR EQ @<FS_S>-AUFNR
         AND BWART EQ @GC_101
         AND CANCELLED EQ @SPACE
        INTO (@<FS_S>-T_MBLNR, @<FS_S>-T_MJAHR).

      "입고 상태
      IF <FS_S>-T_MBLNR IS NOT INITIAL.
        <FS_S>-3RD_STAT = ICON_LED_GREEN.
      ELSE.
        <FS_S>-3RD_STAT = ICON_LED_INACTIVE.
      ENDIF.

      "확정 정보
      SELECT SINGLE RUECK, RMZHL
        FROM AFRU
       WHERE AUFNR EQ @<FS_S>-AUFNR
         AND STOKZ EQ @SPACE
         AND STZHL EQ @SPACE
        INTO (@<FS_S>-RUECK, @<FS_S>-RMZHL).

      "확정 상태
      IF <FS_S>-RUECK IS NOT INITIAL.
        <FS_S>-4TH_STAT = ICON_LED_GREEN.
      ELSE.
        <FS_S>-4TH_STAT = ICON_LED_INACTIVE.
      ENDIF.

    ENDIF.

    PERFORM SET_STY_RTN CHANGING <FS_S>.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STY_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_S>
*&---------------------------------------------------------------------*
FORM SET_STY_RTN  CHANGING P_LINE LIKE GS_PROC.

  DATA: LS_STY TYPE LVC_S_STYL.

  DEFINE SET_STY.
    IF &2 EQ 'X'.
      LS_STY-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    ELSE.
      LS_STY-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
    ENDIF.

    LS_STY-FIELDNAME = &1.
    INSERT LS_STY INTO TABLE P_LINE-CELL_STY.
    CLEAR LS_STY.
  END-OF-DEFINITION.

  CLEAR : P_LINE-CELL_STY.

  SET_STY 'WERKS'      'X'.
  SET_STY 'NAME1'      'X'.
  SET_STY 'F_MATN'     'X'.
  SET_STY 'F_MAKTX'    'X'.
  SET_STY 'F_LGORT'    'X'.
  SET_STY 'F_LGOBE'    'X'.
  SET_STY 'F_LABST'    'X'.
  SET_STY 'T_MATN'     'X'.
  SET_STY 'T_MAKTX'    'X'.
  SET_STY 'T_LGORT'    'X'.
  SET_STY 'T_LGOBE'    'X'.
  SET_STY 'T_LABST'    'X'.
  SET_STY 'PSTD_STAT'  'X'.
  SET_STY 'AUART'      'X'.
  SET_STY 'ZMESSAGE'   'X'.
  SET_STY '1ST_STAT'   'X'.
  SET_STY 'AUFNR'      'X'.
  IF P_R1 EQ GC_X.
    SET_STY 'PSMNG'    SPACE.
  ELSEIF P_R2 EQ GC_X.
    SET_STY 'PSMNG'    'X'.
  ENDIF.
  SET_STY 'MEINS'      'X'.
  SET_STY '2ND_STAT'   'X'.
  SET_STY 'F_MBLNR'    'X'.
  SET_STY '3RD_STAT'   'X'.
  SET_STY 'T_MBLNR'    'X'.
  SET_STY '4TH_STAT'   'X'.
  SET_STY 'RUECK'      'X'.
  SET_STY 'BUDAT'      SPACE.
  SET_STY 'CRDAT'      'X'.
  SET_STY 'CRTIM'      'X'.
  SET_STY 'CRNAM'      'X'.
  SET_STY 'F_MJAHR'    'X'.
  SET_STY 'T_MJAHR'    'X'.
  SET_STY 'RMZHL'      'X'.
  SET_STY 'GSTRP'      'X'.
  SET_STY 'ADD_GI'     'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_MAT_GI_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_MAT_GI_C  USING    P_LINE LIKE GS_PROC.

  DATA: LT_RETURN     TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
        LS_RETURNS    TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
        LS_GOODSMVT   TYPE BAPI2017_GM_HEAD_RET,
        LV_HEADER_TXT TYPE BAPI2017_GM_HEAD_02-HEADER_TXT.

  CLEAR: LT_RETURN, LS_RETURNS, LS_GOODSMVT.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT = P_LINE-F_MBLNR
      MATDOCUMENTYEAR  = P_LINE-F_MJAHR
    IMPORTING
      GOODSMVT_HEADRET = LS_GOODSMVT
    TABLES
      RETURN           = LT_RETURN.

  IF LS_GOODSMVT-MAT_DOC IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = GC_X.

    P_LINE-2ND_STAT = ICON_LED_INACTIVE.
    CLEAR: P_LINE-F_MBLNR.

    WAIT UP TO '0.5' SECONDS.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CLEAR: LT_RETURN.
    READ TABLE LT_RETURN WITH KEY TYPE = GC_E.
    IF LT_RETURN-MESSAGE IS INITIAL.
      P_LINE-ZMESSAGE = TEXT-M12. "투입 취소 처리 도중 오류가 발생하였습니다.
    ELSE.
      P_LINE-ZMESSAGE = LT_RETURN-MESSAGE.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONV_MATN1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_I
*&      <-- L_MATNR
*&---------------------------------------------------------------------*
FORM CONV_MATN1  USING    P_GUBUN
                 CHANGING P_VALUE.

  CASE P_GUBUN.
    WHEN GC_I.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          INPUT        = P_VALUE
        IMPORTING
          OUTPUT       = P_VALUE
        EXCEPTIONS
          LENGTH_ERROR = 1
          OTHERS       = 2.

    WHEN GC_O.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          INPUT  = P_VALUE
        IMPORTING
          OUTPUT = P_VALUE.

  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_PRD_CONF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_PRD_CONF  USING    P_LINE LIKE GS_PROC.

  DATA : LS_PROP        TYPE BAPI_PP_CONF_PROP,
         LT_RETURN_PROP TYPE TABLE OF BAPI_CORU_RETURN,
         LT_TT_PROP     TYPE TABLE OF BAPI_PP_TIMETICKET.

  DATA: LT_TT           TYPE TABLE OF BAPI_PP_TIMETICKET,
        LT_GOODS        TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_DETAIL       TYPE TABLE OF BAPI_CORU_RETURN,
        LS_DETAIL       TYPE BAPI_CORU_RETURN,
        LS_RETURN       TYPE BAPIRET1,
        LV_MESSAGE      TYPE BAPI_CORU_RETURN-MESSAGE,
        LV_RU_EXTID(32).

  CLEAR: LS_PROP.
  LS_PROP = VALUE #( "GOODSMOVEMENT = 'X'
                     QUANTITY = 'X'
                     ACTIVITY = 'X' ).

  SELECT SINGLE B~RUECK
    FROM AFKO AS A
   INNER JOIN AFVC AS B ON B~AUFPL EQ A~AUFPL
   WHERE A~AUFNR EQ @P_LINE-AUFNR
    INTO @DATA(LV_RUECK).

  CLEAR: LT_TT_PROP.
  LT_TT_PROP = VALUE #( ( CONF_NO = LV_RUECK
                          YIELD   = P_LINE-PSMNG ) ).

*-생산수량 기준 표준값(ACTIVITY) 추출
  CLEAR: LT_RETURN_PROP.
  CALL FUNCTION 'BAPI_PRODORDCONF_GET_TT_PROP'
    EXPORTING
      PROPOSE       = LS_PROP
    TABLES
      TIMETICKETS   = LT_TT_PROP
*     GOODSMOVEMENTS = PT_GOODSMOVEMENTS
      DETAIL_RETURN = LT_RETURN_PROP.

*-추출한 표준값 기반으로 생산 확정 처리
  READ TABLE LT_TT_PROP INTO DATA(LS_TT_PROP) INDEX 1.

  CLEAR: LT_TT.
  LT_TT = VALUE #( ( CONF_NO             = LS_TT_PROP-CONF_NO
                     POSTG_DATE          = P_LINE-BUDAT
                     CONF_TEXT           = '배관실적처리'
                     FIN_CONF            = GC_X           "최종확정
                     CONF_QUAN_UNIT      = LS_TT_PROP-CONF_QUAN_UNIT
                     CONF_QUAN_UNIT_ISO  = LS_TT_PROP-CONF_QUAN_UNIT_ISO
                     YIELD               = P_LINE-PSMNG
                     CONF_ACTI_UNIT1     = LS_TT_PROP-CONF_ACTI_UNIT1
                     CONF_ACTI_UNIT1_ISO = LS_TT_PROP-CONF_ACTI_UNIT1_ISO
                     CONF_ACTIVITY1      = LS_TT_PROP-CONF_ACTIVITY1
                     CONF_ACTI_UNIT2     = LS_TT_PROP-CONF_ACTI_UNIT2
                     CONF_ACTI_UNIT2_ISO = LS_TT_PROP-CONF_ACTI_UNIT2_ISO
                     CONF_ACTIVITY2      = LS_TT_PROP-CONF_ACTIVITY2
                     CONF_ACTI_UNIT3     = LS_TT_PROP-CONF_ACTI_UNIT3
                     CONF_ACTI_UNIT3_ISO = LS_TT_PROP-CONF_ACTI_UNIT3_ISO
                     CONF_ACTIVITY3      = LS_TT_PROP-CONF_ACTIVITY3
                     CONF_ACTI_UNIT4     = LS_TT_PROP-CONF_ACTI_UNIT4
                     CONF_ACTI_UNIT4_ISO = LS_TT_PROP-CONF_ACTI_UNIT4_ISO
                     CONF_ACTIVITY4      = LS_TT_PROP-CONF_ACTIVITY4
                     CONF_ACTI_UNIT5     = LS_TT_PROP-CONF_ACTI_UNIT5
                     CONF_ACTI_UNIT5_ISO = LS_TT_PROP-CONF_ACTI_UNIT5_ISO
                     CONF_ACTIVITY5      = LS_TT_PROP-CONF_ACTIVITY5
                     CONF_ACTI_UNIT6     = LS_TT_PROP-CONF_ACTI_UNIT6
                     CONF_ACTI_UNIT6_ISO = LS_TT_PROP-CONF_ACTI_UNIT6_ISO
                     CONF_ACTIVITY6      = LS_TT_PROP-CONF_ACTIVITY6 ) ).

*- 생산 실적 처리 (최종 확정 처리)
  CLEAR: LT_GOODS, LT_DETAIL, LS_RETURN, LV_MESSAGE, LS_DETAIL.
  CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
    IMPORTING
      RETURN         = LS_RETURN
    TABLES
      TIMETICKETS    = LT_TT
      GOODSMOVEMENTS = LT_GOODS
      DETAIL_RETURN  = LT_DETAIL.

*- 성공
  IF LS_RETURN IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    LS_DETAIL = VALUE #( LT_DETAIL[ 1 ] OPTIONAL ).

    P_LINE-4TH_STAT = ICON_LED_GREEN.
    IF LS_DETAIL-MESSAGE IS INITIAL.
      P_LINE-ZMESSAGE = TEXT-M16. "품목 확정 처리에 성공하였습니다.
    ELSE.
      P_LINE-ZMESSAGE = LS_DETAIL-MESSAGE.
    ENDIF.
    P_LINE-RUECK = LS_DETAIL-CONF_NO.
    P_LINE-RMZHL = LS_DETAIL-CONF_CNT.

*- 실패
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    READ TABLE LT_DETAIL INTO LS_DETAIL WITH KEY TYPE = 'E'.
    IF LS_DETAIL-MESSAGE IS INITIAL.
      P_LINE-ZMESSAGE = TEXT-M17. "품목 확정 처리 도중 오류가 발생하였습니다.
    ELSE.
      P_LINE-ZMESSAGE = LS_DETAIL-MESSAGE.
    ENDIF.
    P_LINE-4TH_STAT = ICON_LED_RED.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_PRD_CONF_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_PRD_CONF_C  USING    P_LINE LIKE GS_PROC.

  DATA: LV_RMZHL     TYPE CO_RMZHL,
        LV_LOCKED    TYPE RU_LOCKED,
        LV_CONF_NO   TYPE CO_RUECK,
        LV_CONF_CNT  TYPE CO_RMZHL,
        LS_RETURN    TYPE BAPIRET1,
        LV_CONF_TEXT TYPE BAPI_PP_CONFIRM-CONF_TEXT.

  CLEAR: LV_RMZHL.
  SELECT SINGLE RMZHL
    FROM AFRU
   WHERE RUECK EQ @P_LINE-RUECK
     AND STOKZ EQ @SPACE
     AND STZHL EQ @SPACE
    INTO @LV_RMZHL.

  CLEAR: LV_LOCKED, LV_CONF_NO, LV_CONF_CNT, LS_RETURN.

  CALL FUNCTION 'BAPI_PRODORDCONF_CANCEL'
    EXPORTING
      CONFIRMATION        = P_LINE-RUECK
      CONFIRMATIONCOUNTER = P_LINE-RMZHL "LV_RMZHL
*     POSTG_DATE          = P_LINE-BUDATT10
*     CONF_TEXT           = LV_CONF_TEXT
    IMPORTING
      RETURN              = LS_RETURN
      LOCKED              = LV_LOCKED
      CREATED_CONF_NO     = LV_CONF_NO
      CREATED_CONF_COUNT  = LV_CONF_CNT.

  IF LV_CONF_NO IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    P_LINE-4TH_STAT = ICON_LED_INACTIVE.
    CLEAR: P_LINE-RUECK.

    WAIT UP TO '0.5' SECONDS.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    P_LINE-ZMESSAGE = LS_RETURN-MESSAGE.

  ENDIF.

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
    MESSAGE E006 WITH TEXT-M19 P_WERKS TEXT-M20.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_PSTDCRE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_PSTDCRE .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  DATA: LT_3320SEL LIKE TABLE OF GS_3320.

  FIELD-SYMBOLS: <FS_S> LIKE GS_3320.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0200.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M02. "레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T16 "생산 기준 정보 생성
      TEXT_QUESTION         = TEXT-T17 "미생성된 생산기준정보를 생성하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: LT_3320SEL.

    LOOP AT LT_ROW_NO.
      READ TABLE GT_3320 ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      "BOM 미생성 OR 라우팅 미생성 OR 생산버전 미생성
      IF <FS_S>-BOM_STAT  EQ ICON_LED_RED OR
         <FS_S>-ROUT_STAT EQ ICON_LED_RED OR
         <FS_S>-PVER_STAT EQ ICON_LED_RED.
        APPEND <FS_S> TO LT_3320SEL.
      ENDIF.
    ENDLOOP.

    "선택된 데이터를 전환 후 품목코드(T_MATN) 기준으로 중복 제거
    SORT LT_3320SEL BY T_MATN.
    DELETE ADJACENT DUPLICATES FROM LT_3320SEL COMPARING T_MATN.

    "선택된 데이터를 기준으로 BOM, 라우팅, 생산버전 생성
    LOOP AT LT_3320SEL ASSIGNING FIELD-SYMBOL(<FS_SEL>).
      IF <FS_SEL>-BOM_STAT NE ICON_LED_GREEN.
        "BOM 생성
        PERFORM BOM_CREATE USING <FS_SEL>.

        IF <FS_SEL>-BOM_STAT = ICON_LED_GREEN.
          "원가BOM(6) 생성 추가 - 2026.09.16
          PERFORM BOM_CREATE_06 USING <FS_SEL>.
        ENDIF.

      ENDIF.

      IF <FS_SEL>-BOM_STAT  EQ ICON_LED_GREEN AND
         <FS_SEL>-ROUT_STAT NE ICON_LED_GREEN.
        "라우팅 생성
        PERFORM ROUTING_CREATE USING <FS_SEL>.
      ENDIF.

      IF <FS_SEL>-BOM_STAT  EQ ICON_LED_GREEN AND
         <FS_SEL>-ROUT_STAT EQ ICON_LED_GREEN AND
         <FS_SEL>-PVER_STAT NE ICON_LED_GREEN.
        "생산버전 생성
        PERFORM VERID_CREATE USING <FS_SEL>.

      ENDIF.

      IF <FS_SEL>-BOM_STAT  EQ ICON_LED_GREEN AND
         <FS_SEL>-ROUT_STAT EQ ICON_LED_GREEN AND
         <FS_SEL>-PVER_STAT EQ ICON_LED_GREEN.
        <FS_SEL>-PROC_MSG = TEXT-M24. "생산 기준 정보 생성에 성공하였습니다.
      ENDIF.

    ENDLOOP.

    "처리 결과 ALV 적용
    UNASSIGN <FS_S>.
    LOOP AT GT_3320 ASSIGNING <FS_S>.
      READ TABLE LT_3320SEL INTO DATA(LS_SEL) WITH KEY T_MATN = <FS_S>-T_MATN.

      IF SY-SUBRC EQ 0.
        <FS_S>-BOM_STAT = LS_SEL-BOM_STAT.
        <FS_S>-ROUT_STAT = LS_SEL-ROUT_STAT.
        <FS_S>-PVER_STAT = LS_SEL-PVER_STAT.
        <FS_S>-PROC_MSG = LS_SEL-PROC_MSG.
      ENDIF.

    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0200.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BOM_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM BOM_CREATE  USING    P_LINE LIKE GS_3320.

  DATA: LV_NUM(2) TYPE N.
  DATA: LV_FIELDNAME TYPE FNAM_____4.

  CLEAR: BDCDATA, BDCDATA[], MESSTAB, MESSTAB[],
         GV_INDEX, GV_TEXT.

  PERFORM DYNPRO1 USING:
        'X' 'SAPLCSDI'    '0100',
        ' ' 'BDC_OKCODE'  '/00',
        ' ' 'RC29N-MATNR' P_LINE-T_MATN,
        ' ' 'RC29N-WERKS' P_LINE-WERKS,
        ' ' 'RC29N-STLAN' '1',
*          ' ' 'RC29N-STLAL' P_LINE-STLAL,
        ' ' 'RC29N-DATUV' SY-DATUM.

  PERFORM DYNPRO1 USING:
        'X' 'SAPLCSDI'    '2150',
        ' ' 'BDC_OKCODE'  '/00'.

  CLEAR: LV_NUM.
  LOOP AT GT_3320_B INTO DATA(LS_BOM) WHERE T_MATN EQ P_LINE-T_MATN.
    ADD 1 TO LV_NUM.

    CLEAR: LV_FIELDNAME.
    LV_FIELDNAME = |RC29P-POSTP({ LV_NUM })|.
    PERFORM DYNPRO1 USING:
          ' ' LV_FIELDNAME 'L'.

    CLEAR: LV_FIELDNAME.
    LV_FIELDNAME = |RC29P-IDNRK({ LV_NUM })|.
    PERFORM DYNPRO1 USING:
          ' ' LV_FIELDNAME LS_BOM-F_MATN.

    CLEAR: LV_FIELDNAME.
    LV_FIELDNAME = |RC29P-MENGE({ LV_NUM })|.
    PERFORM DYNPRO1 USING:
          ' ' LV_FIELDNAME '1000'.

  ENDLOOP.

  PERFORM DYNPRO1 USING:
        'X' 'SAPLCSDI'    '2150',
        ' ' 'BDC_OKCODE'  '=FCBU'.

  GS_PARAMS-DISMODE  = 'N'.   " 처리모드
  GS_PARAMS-UPDMODE  = 'S'.   " 갱신세션
  GS_PARAMS-CATTMODE = 'A'.   " CATT모드
  GS_PARAMS-DEFSIZE  = ' '.   " 기본화면
  GS_PARAMS-RACOMMIT = 'X'.   " COMMIT 이후 지속
  GS_PARAMS-NOBINPT  = 'X'.   " BI 세션

  CALL TRANSACTION 'CS01'
             USING BDCDATA
           OPTIONS FROM GS_PARAMS
          MESSAGES INTO MESSTAB.

  READ TABLE MESSTAB WITH KEY MSGTYP = GC_E.

  IF SY-SUBRC EQ 0.
    P_LINE-PROC_MSG = TEXT-M21. "BOM 생성 중 오류 발생
  ELSE.
    "자재 ~에 대한 BOM을 생성하고 있습니다.
    READ TABLE MESSTAB WITH KEY MSGTYP = GC_S
                                MSGID  = '29'
                                MSGNR  = '030'.

    IF SY-SUBRC EQ 0.
      DO 1000 TIMES.
        SELECT SINGLE STLNR, STLAL, STLAN
          FROM MAST
         WHERE MATNR EQ @P_LINE-T_MATN
           AND WERKS EQ @P_LINE-WERKS
           AND STLAN EQ '1'
           AND STLAL EQ '01'
          INTO (@P_LINE-STLNR, @P_LINE-STLAL, @P_LINE-STLAN).
        IF SY-SUBRC EQ 0.
          EXIT.
        ELSE.
          WAIT UP TO '0.5' SECONDS.
        ENDIF.
      ENDDO.
    ELSE.
      P_LINE-PROC_MSG = TEXT-M21. "BOM 생성 중 오류 발생
    ENDIF.
  ENDIF.

  IF P_LINE-STLNR IS NOT INITIAL.
    P_LINE-BOM_STAT = ICON_LED_GREEN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DYNPRO1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM DYNPRO1  USING DYNBEGIN NAME VALUE.
  CLEAR BDCDATA.
  IF DYNBEGIN = 'X'.
    MOVE: NAME  TO BDCDATA-PROGRAM,
          VALUE TO BDCDATA-DYNPRO,
          'X'   TO BDCDATA-DYNBEGIN.
    APPEND BDCDATA.
  ELSE.
    MOVE: NAME  TO BDCDATA-FNAM,
          VALUE TO BDCDATA-FVAL.
    APPEND BDCDATA.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ROUTING_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_SEL>
*&---------------------------------------------------------------------*
FORM ROUTING_CREATE  USING    P_LINE LIKE GS_3320.

  CLEAR: BDCDATA, BDCDATA[], MESSTAB, MESSTAB[],
         GV_INDEX, GV_TEXT.

  PERFORM DYNPRO1 USING:
        'X' 'SAPLCPDI'        '1010',
        ' ' 'BDC_OKCODE'      '=XALU',
        ' ' 'RC27M-MATNR'     P_LINE-T_MATN,
        ' ' 'RC27M-WERKS'     P_LINE-WERKS,
        ' ' 'RC271-STTAG'     SY-DATUM.

  PERFORM DYNPRO1 USING:
        'X' 'SAPLCPDA'        '1200',
        ' ' 'BDC_OKCODE'      '/00',
*        ' ' 'PLKOD-PLNAL'     P_LINE-PLNAL,
        ' ' 'PLKOD-VERWE'     '1',
        ' ' 'PLKOD-STATU'     '4'.

  PERFORM DYNPRO1 USING:
        'X' 'SAPLCPDA'        '1200',
        ' ' 'BDC_OKCODE'      '=ALUE'.

  PERFORM DYNPRO1 USING:
        'X' 'SAPLCPDI'        '1200',
        ' ' 'BDC_CURSOR'      'PLKOD-KTEXT(01)',
        ' ' 'BDC_OKCODE'      '=PICK',
        ' ' 'RC27X-ENTRY_ACT' '1'.

  PERFORM DYNPRO1 USING:
        'X' 'SAPLCPDI'        '1400',
        ' ' 'BDC_OKCODE'      '/00',
        ' ' 'PLPOD-ARBPL(01)' 'PIP001',
        ' ' 'PLPOD-STEUS(01)' 'PP01',
        ' ' 'PLPOD-LTXA1(01)' '배관'.

  PERFORM DYNPRO1 USING:
        'X' 'SAPLCPDI'        '1400',
        ' ' 'BDC_OKCODE'      '=BU',
        ' ' 'RC27X-ENTRY_ACT' '1',
*        ' ' 'PLPOD-VGW01(01)' '1',
        ' ' 'PLPOD-VGW02(01)' '1',
        ' ' 'PLPOD-VGW03(01)' '1',
        ' ' 'PLPOD-VGW04(01)' '1',
        ' ' 'PLPOD-VGW05(01)' '1',
        ' ' 'PLPOD-VGW06(01)' '1'.

  GS_PARAMS-DISMODE  = 'N'.   " 처리모드
  GS_PARAMS-UPDMODE  = 'S'.   " 갱신세션
  GS_PARAMS-CATTMODE = 'A'.   " CATT모드
  GS_PARAMS-DEFSIZE  = ' '.   " 기본화면
  GS_PARAMS-RACOMMIT = 'X'.   " COMMIT 이후 지속
  GS_PARAMS-NOBINPT  = 'X'.   " BI 세션

  CALL TRANSACTION 'CA01'
             USING BDCDATA
           OPTIONS FROM GS_PARAMS
          MESSAGES INTO MESSTAB.

  READ TABLE MESSTAB WITH KEY MSGTYP = GC_E.

  IF SY-SUBRC EQ 0.
    P_LINE-PROC_MSG = TEXT-M22. "Routing 생성 중 오류 발생
  ELSE.
    "공정을 그룹 ~ 및 자재 ~과(와) 함께 저장했습니다.
    READ TABLE MESSTAB WITH KEY MSGTYP = GC_S
                                MSGID  = 'CV'
                                MSGNR  = '761'.
    IF SY-SUBRC EQ 0.
      DO 1000 TIMES.
        SELECT SINGLE PLNNR, PLNTY, PLNAL, DATUV
          FROM MAPL
         WHERE MATNR EQ @P_LINE-T_MATN
           AND WERKS EQ @P_LINE-WERKS
           AND PLNTY EQ @GC_N
           AND PLNAL EQ '01'
          INTO (@P_LINE-PLNNR, @P_LINE-PLNTY, @P_LINE-PLNAL, @P_LINE-DATUV).
        IF SY-SUBRC EQ 0.
          EXIT.
        ELSE.
          WAIT UP TO '0.5' SECONDS.
        ENDIF.
      ENDDO.
    ELSE.
      P_LINE-PROC_MSG = TEXT-M22. "Routing 생성 중 오류 발생
    ENDIF.
  ENDIF.

  IF P_LINE-PLNNR IS NOT INITIAL.
    P_LINE-ROUT_STAT = ICON_LED_GREEN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VERID_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_SEL>
*&---------------------------------------------------------------------*
FORM VERID_CREATE  USING    P_LINE LIKE GS_3320.

  DATA: LT_PROD_VERSION TYPE BOM_TT_PRODVER_MKAL_ENTRIES,
        LS_PROD_VERSION TYPE BOM_TY_PRODVER_MKAL_ENTRIES.

  CLEAR: LS_PROD_VERSION, LT_PROD_VERSION, LT_PROD_VERSION[].
  LS_PROD_VERSION-MATNR  = P_LINE-T_MATN.
  LS_PROD_VERSION-WERKS  = P_LINE-WERKS.
  LS_PROD_VERSION-VERID  = '1000'.
  LS_PROD_VERSION-ADATU  = P_LINE-DATUV.
  LS_PROD_VERSION-BDATU  = '99991231'.
  LS_PROD_VERSION-STLAL  = P_LINE-STLAL.
  LS_PROD_VERSION-STLAN  = P_LINE-STLAN.
  LS_PROD_VERSION-PLNTY  = P_LINE-PLNTY.
  LS_PROD_VERSION-PLNNR  = P_LINE-PLNNR.
  LS_PROD_VERSION-ALNAL  = P_LINE-PLNAL.
  LS_PROD_VERSION-PRFG_F = '1'.
  LS_PROD_VERSION-PRFG_S = '1'.
  LS_PROD_VERSION-PRDAT  = SY-DATUM.
  LS_PROD_VERSION-TEXT1  = '자작'.

  APPEND LS_PROD_VERSION TO LT_PROD_VERSION.

  CALL FUNCTION 'CS_BOM_UPDATE_PROD_VERSIONS'
    EXPORTING
      IT_PROD_VERSION = LT_PROD_VERSION.

  IF SY-SUBRC EQ 0.
    "버전지시자 update
    UPDATE MARC SET VERKZ = @GC_X
              WHERE WERKS EQ @P_LINE-WERKS
                AND MATNR EQ @P_LINE-T_MATN.

    IF SY-SUBRC EQ 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = GC_X.

      P_LINE-PVER_STAT = ICON_LED_GREEN.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      P_LINE-PROC_MSG = TEXT-M23. "생산버전 생성 중 오류 발생
    ENDIF.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    P_LINE-PROC_MSG = TEXT-M23. "생산버전 생성 중 오류 발생
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BOM_CREATE_06
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_SEL>
*&---------------------------------------------------------------------*
FORM BOM_CREATE_06  USING    P_LINE LIKE GS_3320.

  DATA: LV_NUM(2) TYPE N.
  DATA: LV_FIELDNAME TYPE FNAM_____4.

  CLEAR: BDCDATA, BDCDATA[], MESSTAB, MESSTAB[],
         GV_INDEX, GV_TEXT.

  PERFORM DYNPRO1 USING:
        'X' 'SAPLCSDI'    '0100',
        ' ' 'BDC_OKCODE'  '/00',
        ' ' 'RC29N-MATNR' P_LINE-T_MATN,
        ' ' 'RC29N-WERKS' P_LINE-WERKS,
        ' ' 'RC29N-STLAN' '6',
*          ' ' 'RC29N-STLAL' P_LINE-STLAL,
        ' ' 'RC29N-DATUV' SY-DATUM.

  PERFORM DYNPRO1 USING:
        'X' 'SAPLCSDI'    '2150',
        ' ' 'BDC_OKCODE'  '/00'.

  CLEAR: LV_NUM.
  LOOP AT GT_3320_B INTO DATA(LS_BOM) WHERE T_MATN EQ P_LINE-T_MATN.
    ADD 1 TO LV_NUM.

    CLEAR: LV_FIELDNAME.
    LV_FIELDNAME = |RC29P-POSTP({ LV_NUM })|.
    PERFORM DYNPRO1 USING:
          ' ' LV_FIELDNAME 'L'.

    CLEAR: LV_FIELDNAME.
    LV_FIELDNAME = |RC29P-IDNRK({ LV_NUM })|.
    PERFORM DYNPRO1 USING:
          ' ' LV_FIELDNAME LS_BOM-F_MATN.

    CLEAR: LV_FIELDNAME.
    LV_FIELDNAME = |RC29P-MENGE({ LV_NUM })|.
    PERFORM DYNPRO1 USING:
          ' ' LV_FIELDNAME '1000'.

  ENDLOOP.

  PERFORM DYNPRO1 USING:
        'X' 'SAPLCSDI'    '2150',
        ' ' 'BDC_OKCODE'  '=FCBU'.

  GS_PARAMS-DISMODE  = 'N'.   " 처리모드
  GS_PARAMS-UPDMODE  = 'S'.   " 갱신세션
  GS_PARAMS-CATTMODE = 'A'.   " CATT모드
  GS_PARAMS-DEFSIZE  = ' '.   " 기본화면
  GS_PARAMS-RACOMMIT = 'X'.   " COMMIT 이후 지속
  GS_PARAMS-NOBINPT  = 'X'.   " BI 세션

  CALL TRANSACTION 'CS01'
             USING BDCDATA
           OPTIONS FROM GS_PARAMS
          MESSAGES INTO MESSTAB.

  READ TABLE MESSTAB WITH KEY MSGTYP = GC_E.

  IF SY-SUBRC EQ 0.
    P_LINE-PROC_MSG = TEXT-M21. "BOM 생성 중 오류 발생
  ELSE.
    "자재 ~에 대한 BOM을 생성하고 있습니다.
    READ TABLE MESSTAB WITH KEY MSGTYP = GC_S
                                MSGID  = '29'
                                MSGNR  = '030'.

    IF SY-SUBRC EQ 0.
      DO 1000 TIMES.
        SELECT SINGLE STLNR, STLAL, STLAN
          FROM MAST
         WHERE MATNR EQ @P_LINE-T_MATN
           AND WERKS EQ @P_LINE-WERKS
           AND STLAN EQ '6'
           AND STLAL EQ '01'
          INTO (@P_LINE-STLNR, @P_LINE-STLAL, @P_LINE-STLAN).
        IF SY-SUBRC EQ 0.
          EXIT.
        ELSE.
          WAIT UP TO '0.5' SECONDS.
        ENDIF.
      ENDDO.
    ELSE.
      P_LINE-PROC_MSG = TEXT-M26. "BOM 생성 중 오류 발생
    ENDIF.
  ENDIF.

  IF P_LINE-STLNR IS NOT INITIAL.
    P_LINE-BOM_STAT = ICON_LED_GREEN.
  ENDIF.

ENDFORM.
