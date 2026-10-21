*&---------------------------------------------------------------------*
*& Include          ZGTPPR4130F01
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
  S_INSMM[] = VALUE #( ( SIGN = GC_I
                         OPTION = GC_EQ
                         LOW = SY-DATUM+0(6) - 1 ) ).
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
      WHEN 'P_WERKS' OR 'S_INSMM-LOW'.
        SCREEN-REQUIRED = 2.
        MODIFY SCREEN.
    ENDCASE.
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
  DATA: LV_CNT TYPE I.

  IF P_WERKS IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH TEXT-M03. "필수 필드 "플랜트"에 입력하십시오.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF S_INSMM IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH TEXT-M04. "필수 필드 "재고실사년월"에 입력하십시오.
    LEAVE LIST-PROCESSING.
  ENDIF.

  CLEAR: GV_LGORT, LV_CNT.
  IF ( S_LGORT-LOW IS NOT INITIAL AND S_LGORT-HIGH IS NOT INITIAL ) OR
     ( S_LGORT-LOW IS INITIAL AND S_LGORT-HIGH IS INITIAL ).
    GV_LGORT = TEXT-T10. "전체.
  ELSE.
    LOOP AT S_LGORT.
      LV_CNT += 1.
    ENDLOOP.

    IF LV_CNT >= 2.
      GV_LGORT = TEXT-T10. "전체.
    ELSE.
      GV_LGORT = S_LGORT-LOW.
    ENDIF.
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
  DATA: LT_0601_A LIKE TABLE OF GS_0601,
        LT_PDA_A  LIKE TABLE OF GS_PDA.
  DATA: LV_WERKS_91 TYPE WERKS_D. "보관품 플랜트

  CLEAR: LV_WERKS_91.
  LV_WERKS_91 = P_WERKS+0(2) && '91'.

  "재고실사 대상
  CLEAR: GT_0601.
  SELECT DISTINCT
         A~WERKS, A~INSMM, A~LGORT, A~MATNR, A~CHARG,
         A~VBELN, A~POSNR, A~MEINS, A~LABST, A~INSME, A~SPEME,
         B~TAGNR,
         C~DPCBT
    FROM ZPPT0601 AS A
    JOIN ZPPT0001 AS B ON B~WERKS EQ A~WERKS
                      AND B~CHARG EQ A~CHARG
                      AND B~MATNR EQ A~MATNR
    JOIN MARC     AS C ON C~MATNR EQ B~MATNR
                      AND C~WERKS EQ B~WERKS
   WHERE A~WERKS EQ @P_WERKS
     AND A~INSMM IN @S_INSMM
     AND A~LGORT IN @S_LGORT
     AND A~MATNR IN @S_MATNR
     AND A~CHARG IN @S_CHARG
     AND A~CHARG NE @SPACE
     AND A~ITYPE NE '1'
     AND B~TAGNR IN @S_TAGNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_0601.

  SORT GT_0601 BY INSMM WERKS LGORT MATNR CHARG TAGNR.
  DELETE ADJACENT DUPLICATES FROM GT_0601
                        COMPARING INSMM WERKS LGORT MATNR CHARG.

  CLEAR: LT_0601_A.
  APPEND LINES OF GT_0601 TO LT_0601_A.

  DELETE GT_0601 WHERE DPCBT EQ GC_A.
  DELETE LT_0601_A WHERE DPCBT NE GC_A.

  SORT LT_0601_A BY INSMM WERKS LGORT MATNR CHARG.
  DELETE ADJACENT DUPLICATES FROM LT_0601_A
                        COMPARING INSMM WERKS LGORT MATNR CHARG.

  MODIFY LT_0601_A FROM VALUE #( TAGNR = SPACE ) TRANSPORTING TAGNR
                  WHERE TAGNR NE SPACE.

  APPEND LINES OF LT_0601_A TO GT_0601.

  SORT GT_0601 BY INSMM WERKS LGORT MATNR CHARG TAGNR.

  "PDA SCAN 로그
  CLEAR: GT_PDA.
  SELECT DISTINCT
         A~INSMM, A~WERKS, A~LGORT, A~TAGNR,
         B~CHARG, B~MATNR,
         C~DPCBT
    FROM ZGTPPT4160 AS A
    JOIN ZPPT0001   AS B ON B~WERKS EQ A~WERKS
                        AND B~TAGNR EQ A~TAGNR
    JOIN MARC       AS C ON C~MATNR EQ B~MATNR
                        AND C~WERKS EQ B~WERKS
   WHERE A~WERKS EQ @P_WERKS
     AND A~INSMM IN @S_INSMM
     AND A~LGORT IN @S_LGORT
     AND B~MATNR IN @S_MATNR
     AND B~CHARG IN @S_CHARG
     AND A~TAGNR IN @S_TAGNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_PDA.

  CLEAR: LT_PDA_A.
  APPEND LINES OF GT_PDA TO LT_PDA_A.

  DELETE GT_PDA WHERE DPCBT EQ GC_A.
  DELETE LT_PDA_A WHERE DPCBT NE GC_A.

  SORT LT_PDA_A BY INSMM WERKS LGORT MATNR CHARG.
  DELETE ADJACENT DUPLICATES FROM LT_PDA_A
                        COMPARING INSMM WERKS LGORT MATNR CHARG.

  MODIFY LT_PDA_A FROM VALUE #( TAGNR = SPACE ) TRANSPORTING TAGNR
                 WHERE TAGNR NE SPACE.

  APPEND LINES OF LT_PDA_A TO GT_PDA.

  SORT GT_PDA BY INSMM WERKS LGORT MATNR CHARG TAGNR.

  "재고실사결과
  CLEAR: GT_0600.
  SELECT *
    FROM ZPPT0600
   WHERE WERKS EQ @P_WERKS
     AND INSMM IN @S_INSMM
     AND LGORT IN @S_LGORT
     AND MATNR IN @S_MATNR
     AND CHARG IN @S_CHARG
     AND TAGNR IN @S_TAGNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_0600.

  SORT GT_0600 BY INSMM WERKS LGORT MATNR CHARG TAGNR.

  "대체가능꼬리표번호
*  CLEAR: GT_REP_TAGNR.
*  LOOP AT GT_0600 INTO DATA(LS_0600) WHERE MENGE NE 0.
*    MOVE-CORRESPONDING LS_0600 TO GS_REP_TAGNR.
*    GS_REP_TAGNR-MENGE_ABS = ABS( LS_0600-MENGE ).
*
*    APPEND GS_REP_TAGNR TO GT_REP_TAGNR.
*    CLEAR: LS_0600, GS_REP_TAGNR.
*  ENDLOOP.
*
*  SORT GT_REP_TAGNR BY INSMM WERKS LGORT MATNR TAGNR.

  CLEAR: GT_DATA.

  "재고실사 대상 정보 move
  LOOP AT GT_0601 INTO DATA(LS_0601).
    MOVE-CORRESPONDING LS_0601 TO GS_DATA.
    GS_DATA-PHY_INV = GC_Y.

    APPEND GS_DATA TO GT_DATA.
    CLEAR: LS_0601, GS_DATA.
  ENDLOOP.

  "재고실사 정보에 없는 PDA 스캔정보 move
  LOOP AT GT_PDA INTO DATA(LS_PDA).
    READ TABLE GT_0601 INTO LS_0601 WITH KEY INSMM = LS_PDA-INSMM
                                             WERKS = LS_PDA-WERKS
                                             LGORT = LS_PDA-LGORT
                                             MATNR = LS_PDA-MATNR
                                             CHARG = LS_PDA-CHARG
                                             TAGNR = LS_PDA-TAGNR.

    IF SY-SUBRC NE 0.
      MOVE-CORRESPONDING LS_PDA TO GS_DATA.

      APPEND GS_DATA TO GT_DATA.
    ENDIF.

    CLEAR: LS_PDA, LS_0601, GS_DATA.
  ENDLOOP.

  SORT GT_DATA BY INSMM WERKS LGORT MATNR CHARG TAGNR.

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_S>).
    "플랜트내역
    SELECT SINGLE NAME1
      FROM T001W
     WHERE WERKS EQ @<FS_S>-WERKS
      INTO @<FS_S>-NAME1.

    "저장위치내역
    SELECT SINGLE LGOBE
      FROM T001L
     WHERE WERKS EQ @<FS_S>-WERKS
       AND LGORT EQ @<FS_S>-LGORT
      INTO @<FS_S>-LGOBE.

    "자재내역
    SELECT SINGLE MAKTX
      FROM MAKT
     WHERE MATNR EQ @<FS_S>-MATNR
       AND SPRAS EQ @SY-LANGU
      INTO @<FS_S>-MAKTX.

    "스캔여부
    CLEAR: GS_PDA.
    READ TABLE GT_PDA INTO GS_PDA WITH KEY INSMM = <FS_S>-INSMM
                                           WERKS = <FS_S>-WERKS
                                           LGORT = <FS_S>-LGORT
                                           MATNR = <FS_S>-MATNR
                                           CHARG = <FS_S>-CHARG
                                           TAGNR = <FS_S>-TAGNR.
    IF SY-SUBRC EQ 0.
      <FS_S>-SCAN_YN = GC_Y.
    ENDIF.

    "재고실사결과
    CLEAR: GS_0600.
    READ TABLE GT_0600 INTO GS_0600 WITH KEY INSMM = <FS_S>-INSMM
                                             WERKS = <FS_S>-WERKS
                                             LGORT = <FS_S>-LGORT
                                             MATNR = <FS_S>-MATNR
                                             CHARG = <FS_S>-CHARG.

    "실사재고
    <FS_S>-MENGE = ( <FS_S>-LABST + <FS_S>-INSME + <FS_S>-SPEME ) + GS_0600-MENGE.
    "차이량
    <FS_S>-DIFF = GS_0600-MENGE.
    "차이량(절대값)
    <FS_S>-DIFF_ABS = ABS( GS_0600-MENGE ).

    "대체가능꼬리표번호
*    IF <FS_S>-DIFF < 0.
*      LOOP AT GT_REP_TAGNR ASSIGNING FIELD-SYMBOL(<FS_REP_TAGNR>)
*                                     WHERE INSMM EQ <FS_S>-INSMM
*                                       AND WERKS EQ <FS_S>-WERKS
*                                       AND LGORT EQ <FS_S>-LGORT
*                                       AND MATNR EQ <FS_S>-MATNR
*                                       AND TAGNR NE <FS_S>-TAGNR
*                                       AND ZUSE  EQ SPACE
*                                       AND MENGE GT 0.
*
*        IF <FS_S>-DIFF_ABS EQ <FS_REP_TAGNR>-MENGE_ABS.
*          <FS_REP_TAGNR>-ZUSE = GC_X.
*          <FS_S>-REP_TAGNR = <FS_REP_TAGNR>-TAGNR.
*          EXIT.
*        ENDIF.
*      ENDLOOP.
*
*    ELSEIF <FS_S>-DIFF > 0.
*      UNASSIGN <FS_REP_TAGNR>.
*      LOOP AT GT_REP_TAGNR ASSIGNING <FS_REP_TAGNR>
*                                     WHERE INSMM EQ <FS_S>-INSMM
*                                       AND WERKS EQ <FS_S>-WERKS
*                                       AND LGORT EQ <FS_S>-LGORT
*                                       AND MATNR EQ <FS_S>-MATNR
*                                       AND TAGNR NE <FS_S>-TAGNR
*                                       AND ZUSE  EQ SPACE
*                                       AND MENGE LT 0.
*
*        IF <FS_S>-DIFF_ABS EQ <FS_REP_TAGNR>-MENGE_ABS.
*          <FS_REP_TAGNR>-ZUSE = GC_X.
*          <FS_S>-REP_TAGNR = <FS_REP_TAGNR>-TAGNR.
*          EXIT.
*        ENDIF.
*      ENDLOOP.
*
*    ENDIF.

    "보관품이력
    SELECT SINGLE MANDT
      FROM ZPPT0001
     WHERE WERKS EQ @LV_WERKS_91
       AND TAGNR EQ @<FS_S>-TAGNR
      INTO @DATA(LV_MANDT).

    IF SY-SUBRC EQ 0.
      <FS_S>-HIS_901 = GC_Y.
    ENDIF.

    "기초재고이력
    CLEAR: LV_MANDT.
    SELECT SINGLE MANDT
      FROM MATDOC
     WHERE WERKS EQ @<FS_S>-WERKS
       AND MATNR EQ @<FS_S>-MATNR
       AND CHARG EQ @<FS_S>-CHARG
       AND CANCELLED EQ @SPACE
       AND BWART EQ '561'
      INTO @LV_MANDT.

    IF SY-SUBRC EQ 0.
      <FS_S>-HIS_561 = GC_Y.
    ENDIF.

    "과거PDA스캔이력
*    CLEAR: LV_MANDT.
*    SELECT SINGLE A~MANDT
*      FROM ZGTPPT4160 AS A
*      JOIN ZPPT0001   AS B ON B~WERKS EQ A~WERKS
*                          AND B~TAGNR EQ A~TAGNR
*     WHERE A~INSMM LT @<FS_S>-INSMM
*       AND A~WERKS EQ @<FS_S>-WERKS
**       AND A~LGORT EQ @<FS_S>-LGORT
*       AND B~MATNR EQ @<FS_S>-MATNR
*       AND B~CHARG EQ @<FS_S>-CHARG
*       AND A~TAGNR EQ @<FS_S>-TAGNR
*      INTO @LV_MANDT.
*
*    IF SY-SUBRC EQ 0.
*      <FS_S>-HIS_PDA = GC_Y.
*    ENDIF.

    SELECT SINGLE *
      FROM ZGTPPT4170
     WHERE INSMM EQ @<FS_S>-INSMM
       AND WERKS EQ @<FS_S>-WERKS
       AND LGORT EQ @<FS_S>-LGORT
       AND MATNR EQ @<FS_S>-MATNR
       AND CHARG EQ @<FS_S>-CHARG
       AND TAGNR EQ @<FS_S>-TAGNR
      INTO @DATA(LS_4170).

    "비교
    IF <FS_S>-DIFF = 0.
      <FS_S>-COMPARE = COND #( WHEN <FS_S>-PHY_INV EQ GC_Y  AND <FS_S>-SCAN_YN EQ GC_Y  THEN TEXT-T07
                               WHEN <FS_S>-PHY_INV EQ GC_Y  AND <FS_S>-SCAN_YN EQ SPACE THEN '실사재고 없음' "TEXT-T12
                               WHEN <FS_S>-PHY_INV EQ SPACE AND <FS_S>-SCAN_YN EQ GC_Y  THEN '장부재고 없음' "TEXT-T13
                               ).
    ELSEIF <FS_S>-DIFF < 0.
      <FS_S>-COMPARE = TEXT-T08. "전산<실사
    ELSEIF <FS_S>-DIFF > 0.
      <FS_S>-COMPARE = TEXT-T09. "전산>실사
    ENDIF.

    "점검결과
    <FS_S>-CHK_RESULT = LS_4170-CHK_RESULT.

    "비고
    <FS_S>-REMARK = LS_4170-REMARK.

  ENDLOOP.

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
  GS_LAYOUT_0100-SMALLTITLE = GC_X.
  GS_LAYOUT_0100-GRID_TITLE = |{ TEXT-T04 }: { P_WERKS }    { TEXT-T05 }: { S_INSMM-LOW+0(4) }.{ S_INSMM-LOW+4(2) }    { TEXT-T06 }: { GV_LGORT }    { TEXT-T11 }: { GV_DBCNT }|.
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
*  IF P_LAYO IS NOT INITIAL.
*    GS_VARIANT_0100-VARIANT = P_LAYO.
*  ENDIF.
*  GS_VARIANT_0100-REPORT = SY-REPID.
*  GS_VARIANT_0100-USERNAME = SY-UNAME.
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
      I_INCLNAME             = 'ZGTPPR4130TOP'
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
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "플랜트
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'INSMM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "재고년월
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'LGORT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "저장위치
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'LGOBE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "저장위치내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "자재코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "자재내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'CHARG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "배치번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-HOTSPOT = GC_X.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'TAGNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "꼬리표번호
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-HOTSPOT = GC_X.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'PHY_INV'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "실사대상
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'SCAN_YN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "스캔여부
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
*      WHEN 'REP_TAGNR'.
*        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "대체가능꼬리표번호
*        <LS_FCAT>-JUST = GC_L.
      WHEN 'VBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F13. "판매오더번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "판매오더품목
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "기본단위
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LABST'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "장부재고(가용)
        <LS_FCAT>-JUST = GC_R.
      WHEN 'INSME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "장부재고(품질)
        <LS_FCAT>-JUST = GC_R.
      WHEN 'SPEME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "장부재고(보류)
        <LS_FCAT>-JUST = GC_R.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "실사재고
        <LS_FCAT>-JUST = GC_R.
      WHEN 'DIFF'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "차이량
        <LS_FCAT>-JUST = GC_R.
      WHEN 'DIFF_ABS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "차이량(절대값)
        <LS_FCAT>-JUST = GC_R.
      WHEN 'HIS_901'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "보관품이력
        <LS_FCAT>-JUST = GC_C.
      WHEN 'HIS_561'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F23. "26년7월기초재고이력
        <LS_FCAT>-JUST = GC_C.
*      WHEN 'HIS_PDA'.
*        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F24. "과거PDA스캔이력
*        <LS_FCAT>-JUST = GC_C.
      WHEN 'COMPARE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F25. "비교
        <LS_FCAT>-JUST = GC_C.
      WHEN 'CHK_RESULT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F26. "점검결과
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EDIT = GC_X.
      WHEN 'REMARK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F27. "비고
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EDIT = GC_X.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

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
*     IS_VARIANT           = GS_VARIANT_0100
*     I_SAVE               = GC_X
    CHANGING
      IT_OUTTAB            = GT_DATA
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.
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
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  DATA: LT_DATA LIKE TABLE OF GS_DATA.

  DATA: LT_ZGTPPT4170 LIKE TABLE OF ZGTPPT4170.
  DATA: LS_ZGTPPT4170 LIKE ZGTPPT4170.

  DATA: LV_SEQNO LIKE ZGTPPT4170-SEQNO.

  DATA: LV_CX_REF TYPE REF TO CX_ROOT.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: L_ANSWER.

*  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
*                      USING  GO_GRID_0100.
*
*  IF LT_ROW_NO[] IS INITIAL.
*    MESSAGE S003 DISPLAY LIKE GC_W
*       WITH TEXT-M02. "저장할 레코드를 선택하세요.
*    EXIT.
*  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T02 "저장
      TEXT_QUESTION         = TEXT-T03 "데이터 저장을 진행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: LT_ZGTPPT4170, LV_SEQNO.
    LOOP AT GT_DATA ASSIGNING <FS_S>.
      MOVE-CORRESPONDING <FS_S> TO LS_ZGTPPT4170.
      LV_SEQNO += 1.

      LS_ZGTPPT4170-SEQNO = LV_SEQNO.
      LS_ZGTPPT4170-CRDAT = SY-DATLO.
      LS_ZGTPPT4170-CRTIM = SY-TIMLO.
      LS_ZGTPPT4170-CRNAM = SY-UNAME.

      APPEND LS_ZGTPPT4170 TO LT_ZGTPPT4170.
      CLEAR: LS_ZGTPPT4170.
    ENDLOOP.

    IF LT_ZGTPPT4170[] IS NOT INITIAL.
      MODIFY ZGTPPT4170 FROM TABLE LT_ZGTPPT4170.
    ENDIF.

    COMMIT WORK AND WAIT.

    MESSAGE S004.

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
*& Form CRE_OBJ_POP_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CRE_OBJ_POP_ALV .
  PERFORM SET_LAYO_POP.
  PERFORM SET_FCAT_POP.
  PERFORM CRE_OBJT_POP.
  PERFORM CRE_ALVG_POP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYO_POP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYO_POP .
  GS_LAYOD-COL_OPT    = 'X'.
  GS_LAYOD-CWIDTH_OPT = 'X'.
  GS_LAYOD-SMALLTITLE = GC_X.
  GS_LAYOD-GRID_TITLE = |{ TEXT-F08 }: { GV_CHARG }    { TEXT-F09 }: { GV_TAGNR }|.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT_POP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FCAT_POP .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR4130TOP'
      I_INTERNAL_TABNAME     = 'GS_MBLNR_H'
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
      ET_FIELDCAT_LVC = GT_FCATD[]
    TABLES
      IT_DATA         = GT_MBLNR_H
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FCATD ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "플랜트
        <LS_FCAT>-JUST = 'C'.
      WHEN 'LGORT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "저장위치
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "자재코드
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "자재내역
        <LS_FCAT>-JUST = 'L'.
      WHEN 'BWART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F28. "이동유형
        <LS_FCAT>-JUST = 'C'.
      WHEN 'BTEXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F29. "이동유형텍스트
        <LS_FCAT>-JUST = 'L'.
      WHEN 'STOCK_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F30. "수량
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F31. "단위
        <LS_FCAT>-JUST = 'C'.
      WHEN 'EBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F32. "구매오더
        <LS_FCAT>-JUST = 'C'.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F33. "생산오더
        <LS_FCAT>-JUST = 'C'.
      WHEN 'KDAUF'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F13. "판매오더번호
        <LS_FCAT>-JUST = 'C'.
      WHEN 'KDPOS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "판매오더품목
        <LS_FCAT>-JUST = 'C'.
      WHEN 'BUDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F34. "전기일자
        <LS_FCAT>-JUST = 'C'.
      WHEN 'CPUDT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F35. "입력일자
        <LS_FCAT>-JUST = 'C'.
      WHEN 'CPUTM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F36. "입력시간
        <LS_FCAT>-JUST = 'C'.
      WHEN 'USNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F37. "입력자
        <LS_FCAT>-JUST = 'C'.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = 'X'.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CRE_OBJT_POP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CRE_OBJT_POP .
  CREATE OBJECT GCL_POP
    EXPORTING
      I_T_FIELDCATALOG = GT_FCATD[]
      I_S_LAYOUT       = GS_LAYOD
      I_REPID          = SY-REPID
      I_DYNNR          = SY-DYNNR
      I_LEFT           = 300
      I_TOP            = 300
      I_HEIGHT         = 700
      I_WIDTH          = 1500.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CRE_ALVG_POP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CRE_ALVG_POP .
  CALL METHOD GCL_POP->SHOW_DATA
    EXPORTING
      I_T_DATA = GT_MBLNR_H[].
ENDFORM.
