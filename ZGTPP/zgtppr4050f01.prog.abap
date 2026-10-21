*&---------------------------------------------------------------------*
*& Include          ZGTPPR4050F01
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
*-구매입고 전기일자
  IF S_BUDAT[] IS INITIAL.
    S_BUDAT-SIGN = GC_I.
    S_BUDAT-OPTION = GC_BT.
    S_BUDAT-LOW = SY-DATUM+0(6) && |01|.

    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
      EXPORTING
        DAY_IN            = SY-DATUM
      IMPORTING
        LAST_DAY_OF_MONTH = S_BUDAT-HIGH
      EXCEPTIONS
        DAY_IN_NO_DATE    = 1
        OTHERS            = 2.

    APPEND S_BUDAT.
  ENDIF.

*-자재유형
  IF S_MTART[] IS INITIAL.
    S_MTART[] = VALUE #( ( SIGN = GC_I
                           OPTION = GC_EQ
                           LOW = GC_ROH1 ) ).
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
      WHEN 'P_WERKS' OR 'S_BUDAT-LOW'.
        SCREEN-REQUIRED = 1.
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
  IF S_BUDAT-LOW LT '20250601'.
    MESSAGE S003 DISPLAY LIKE GC_E
       WITH TEXT-M03. "2025.06.01일 이후 데이터만 조회 가능합니다.
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

  CLEAR: GT_OPO.
  SELECT B~EBELN, B~EBELP, B~BEDNR AS JOB_NO,
         C~MBLNR, C~MJAHR, C~MENGE AS PO_MENGE, C~MEINS AS PO_MEINS,
         C~MATNR, C~WERKS, C~ZEILE,
         D~ZPJT_NO,
         E~MTART, E~MATKL,
         F~ZPTXT,
         G~ZJOB_NAME AS JOB_NM,
         H~MAKTX,
         I~NAME1,
         J~MTBEZ,
         K~WGBEZ
    FROM            EKKO       AS A
   INNER JOIN       EKPO       AS B ON B~EBELN EQ A~EBELN
   INNER JOIN       MATDOC     AS C ON C~EBELN EQ B~EBELN
                                   AND C~EBELP EQ B~EBELP
   INNER JOIN       ZGTEDT2121 AS D ON D~ZJOB_NO EQ B~BEDNR
   INNER JOIN       MARA       AS E ON E~MATNR EQ C~MATNR
    LEFT OUTER JOIN ZSD0106T   AS F ON F~ZPJNO EQ D~ZPJT_NO
    LEFT OUTER JOIN ZGTEDT2121 AS G ON G~ZSYSTEM_ID EQ @GC_KBDM
                                   AND G~ZWERKS EQ C~WERKS
                                   AND G~ZJOB_NO EQ B~BEDNR
    LEFT OUTER JOIN MAKT       AS H ON H~MATNR EQ C~MATNR
                                   AND H~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T001W      AS I ON I~WERKS EQ C~WERKS
    LEFT OUTER JOIN T134T      AS J ON J~SPRAS EQ @SY-LANGU
                                   AND J~MTART EQ E~MTART
    LEFT OUTER JOIN T023T      AS K ON K~SPRAS EQ @SY-LANGU
                                   AND K~MATKL EQ E~MATKL
   WHERE C~WERKS       EQ @P_WERKS
     AND D~ZPJT_NO     IN @S_ZPJNO
     AND B~BEDNR       IN @S_BEDNR
     AND B~EBELN       IN @S_EBELN
     AND B~EBELP       IN @S_EBELP
     AND C~BUDAT       IN @S_BUDAT
     AND C~MATNR       IN @S_MATNR
     AND E~MTART       IN @S_MTART
     AND E~MATKL       IN @S_MATKL
     AND C~EBELN       NE @SPACE
     AND C~RECORD_TYPE EQ @GC_MDOC
     AND C~BWART       EQ @GC_101
     AND C~CANCELLED   EQ @SPACE
     AND B~LOEKZ       EQ @SPACE
    INTO CORRESPONDING FIELDS OF TABLE @GT_OPO.

  IF GT_OPO IS NOT INITIAL.
    CLEAR: GT_OPROD.
    SELECT DISTINCT
           A~ZPJT_NO,
           B~AUFNR, B~JOB_NO,
           C~MBLNR, C~MJAHR, C~MENGE AS PRD_MENGE, C~MEINS AS PRD_MEINS,
           C~MATNR, C~ZEILE,
           E~ZPTXT,
           F~ZJOB_NAME AS JOB_NM,
           G~MAKTX
      FROM            @GT_OPO    AS A
     INNER JOIN       ZGTPPT3160 AS B ON B~JOB_NO EQ A~JOB_NO
     INNER JOIN       MATDOC     AS C ON C~AUFNR EQ B~AUFNR
     INNER JOIN       AUFK       AS D ON D~AUFNR EQ C~AUFNR
      LEFT OUTER JOIN ZSD0106T   AS E ON E~ZPJNO EQ A~ZPJT_NO
      LEFT OUTER JOIN ZGTEDT2121 AS F ON F~ZSYSTEM_ID EQ @GC_KBDM
                                     AND F~ZWERKS EQ A~WERKS
                                     AND F~ZJOB_NO EQ B~JOB_NO
      LEFT OUTER JOIN MAKT       AS G ON G~MATNR EQ C~MATNR
                                     AND G~SPRAS EQ @SY-LANGU
     WHERE C~AUFNR       NE @SPACE
       AND C~RECORD_TYPE EQ @GC_MDOC
       AND C~BWART       EQ @GC_261
       AND C~CANCELLED   EQ @SPACE
      INTO CORRESPONDING FIELDS OF TABLE @GT_OPROD.

  ENDIF.

  IF GT_OPROD IS NOT INITIAL.
    CLEAR: GT_BLD.
    SELECT DISTINCT
           A~JOB_NO,
           B~WEBLNR, B~WEBLPOS, B~MATNR, B~BWART,
           B~ERFMG, B~ERFME, B~AUFNR
      FROM      @GT_OPROD  AS A
     INNER JOIN ZGTPPT3000 AS B ON B~AUFNR EQ A~AUFNR
                               AND B~MATNR EQ A~MATNR
      INTO CORRESPONDING FIELDS OF TABLE @GT_BLD.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DATA .

  CLEAR: GT_PO_SUM.
  LOOP AT GT_OPO INTO DATA(LS_OPO).
    MOVE-CORRESPONDING LS_OPO TO GS_SUM.
    MOVE: LS_OPO-PO_MENGE TO GS_SUM-SMENGE,
          LS_OPO-PO_MEINS TO GS_SUM-MEINS.

    COLLECT GS_SUM INTO GT_PO_SUM.
    CLEAR: GS_SUM.
  ENDLOOP.

  CLEAR: GT_PROD_SUM.
  LOOP AT GT_OPROD INTO DATA(LS_OPROD).
    MOVE-CORRESPONDING LS_OPROD TO GS_SUM.
    MOVE: LS_OPROD-PRD_MENGE TO GS_SUM-SMENGE,
          LS_OPROD-PRD_MEINS TO GS_SUM-MEINS.

    COLLECT GS_SUM INTO GT_PROD_SUM.
    CLEAR: GS_SUM.
  ENDLOOP.

  CLEAR: GT_BLD_SUM.
  LOOP AT GT_BLD INTO DATA(LS_BLD).
    MOVE-CORRESPONDING LS_BLD TO GS_BLD_SUM.
    MOVE: LS_BLD-ERFMG TO GS_BLD_SUM-SERFMG.

    IF LS_BLD-BWART EQ '262'.
      GS_BLD_SUM-SERFMG = GS_BLD_SUM-SERFMG * ( -1 ).
    ENDIF.

    COLLECT GS_BLD_SUM INTO GT_BLD_SUM.
    CLEAR: GS_BLD_SUM.
  ENDLOOP.

  SORT: GT_PO_SUM BY JOB_NO MATNR,
        GT_PROD_SUM BY JOB_NO MATNR,
        GT_BLD_SUM BY JOB_NO MATNR.

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

  CLEAR: GT_DATA.
  LOOP AT GT_PO_SUM INTO DATA(LS_PO_SUM).
    MOVE-CORRESPONDING LS_PO_SUM TO GS_DATA.
    MOVE: LS_PO_SUM-SMENGE TO GS_DATA-PO_MENGE,
          LS_PO_SUM-MEINS  TO GS_DATA-PO_MEINS.

    READ TABLE GT_PROD_SUM INTO DATA(LS_PROD_SUM)
      WITH KEY JOB_NO = LS_PO_SUM-JOB_NO
               MATNR  = LS_PO_SUM-MATNR.

    IF SY-SUBRC EQ 0.
      MOVE: LS_PROD_SUM-SMENGE TO GS_DATA-PRD_MENGE,
            LS_PROD_SUM-MEINS  TO GS_DATA-PRD_MEINS.

      READ TABLE GT_BLD_SUM INTO DATA(LS_BLD_SUM)
        WITH KEY JOB_NO = LS_PO_SUM-JOB_NO
                 MATNR  = LS_PO_SUM-MATNR.

      IF SY-SUBRC EQ 0.
        MOVE: LS_BLD_SUM-SERFMG TO GS_DATA-BLD_MENGE,
              LS_BLD_SUM-ERFME  TO GS_DATA-BLD_MEINS.
      ENDIF.
    ENDIF.

    APPEND GS_DATA TO GT_DATA.
    CLEAR: GS_DATA.
  ENDLOOP.

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_S>).
    IF <FS_S>-PO_MENGE EQ <FS_S>-PRD_MENGE.
      <FS_S>-IN_STAT = ICON_LED_GREEN.
    ELSE.
      IF <FS_S>-PRD_MENGE GT 0.
        <FS_S>-IN_STAT = ICON_LED_YELLOW.
      ELSE.
        <FS_S>-IN_STAT = ICON_LED_RED.
      ENDIF.
    ENDIF.

    <FS_S>-DIFF_MENGE = <FS_S>-PO_MENGE - <FS_S>-PRD_MENGE.

  ENDLOOP.

  IF P_COMP EQ GC_X.
    DELETE GT_DATA WHERE IN_STAT NE ICON_LED_GREEN.
  ELSEIF P_ICOMP EQ GC_X.
    DELETE GT_DATA WHERE IN_STAT EQ ICON_LED_GREEN.
  ENDIF.

  SORT GT_DATA BY WERKS ZPJT_NO JOB_NO MATNR.

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
         GT_FIELDCAT_0101[], GS_LAYOUT_0101, GT_EXCLUDE_0101[],
         GT_EXCLUDE_0101,
         GT_FIELDCAT_0102[], GS_LAYOUT_0102, GT_EXCLUDE_0102[],
         GT_EXCLUDE_0102,
         GV_OK_CODE, GV_DBCNT,
         GT_DATA[], GT_PO[], GT_PROD[], GT_PO_SUM[], GT_PROD_SUM[].

  CALL METHOD GO_DOCKING_CONTAINER->FREE.
  CLEAR : GO_DOCKING_CONTAINER, GO_GRID_0100, GO_GRID_0101, GO_GRID_0102.
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
*화면 분할
  CREATE OBJECT GO_SPLITTER
    EXPORTING
      PARENT  = GO_DOCKING_CONTAINER
      ROWS    = 2
      COLUMNS = 1.

* top 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0100.
* bottom 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0200.

*BOTTOM 화면 분할
  CREATE OBJECT GO_SPLITTER2
    EXPORTING
      PARENT  = GO_CONTAIN_0200
      ROWS    = 1
      COLUMNS = 2.

* LEFT 컨테이너
  CALL METHOD GO_SPLITTER2->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0101.
* RIGHT 컨테이너
  CALL METHOD GO_SPLITTER2->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 2
    RECEIVING
      CONTAINER = GO_CONTAIN_0102.

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
      I_INCLNAME             = 'ZGTPPR4050TOP'
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
      WHEN 'IN_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "생산투입여부
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "플랜트
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "플랜트내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'ZPJT_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "프로젝트번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'ZPTXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "프로젝트내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'JOB_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "제조지시번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'JOB_NM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "제조지시내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "자재코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "자재내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MTART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "자재유형
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'MTBEZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "자재유형 내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MATKL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "자재그룹
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'WGBEZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F13. "자재그룹 내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'PO_MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "구매입고수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C100'.
        <LS_FCAT>-QFIELDNAME = 'PO_MEINS'.
      WHEN 'PO_MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "구매단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'PRD_MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "생산투입수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C700'.
        <LS_FCAT>-QFIELDNAME = 'PRD_MEINS'.
      WHEN 'PRD_MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "투입단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'DIFF_MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "차이수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C700'.
        <LS_FCAT>-QFIELDNAME = 'PO_MEINS'.
      WHEN 'BLD_MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F24. "백로그 삭제수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C600'.
        <LS_FCAT>-QFIELDNAME = 'BLD_MEINS'.
      WHEN 'BLD_MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F25. "백로그 단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
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
*& Form SET_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM SET_EVENT  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.
  IF GO_EVTR IS NOT BOUND.
    CREATE OBJECT GO_EVTR.
  ENDIF.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      SET HANDLER: GO_EVTR->HDL_DOUBLE_CLICK FOR GO_GRID_0100.
    WHEN GO_GRID_0101.
      SET HANDLER: GO_EVTR->HDL_DOUBLE_CLICK FOR GO_GRID_0101.
    WHEN GO_GRID_0102.
      SET HANDLER: GO_EVTR->HDL_DOUBLE_CLICK FOR GO_GRID_0102.
  ENDCASE.

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
*     IT_SORT              = GT_SORT_0100
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DETAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_DETAIL .
  DATA: LT_ROW_NO  TYPE LVC_T_ROID WITH HEADER LINE.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M04. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  IF LINES( LT_ROW_NO ) > 1.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M05. "하나의 레코드만 선택하세요.
    EXIT.
  ENDIF.

  CLEAR: GT_PO, GT_PROD.
  LOOP AT LT_ROW_NO.
    READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.
    PERFORM SET_BOTTOM_DATA USING <FS_S>.
    PERFORM SET_BOTTOM_ALV.
  ENDLOOP.
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
*& Form SET_BOTTOM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM SET_BOTTOM_DATA  USING    P_LINE LIKE GS_DATA.

  CLEAR: GT_PO.
  LOOP AT GT_OPO INTO DATA(LS_OPO) WHERE JOB_NO EQ P_LINE-JOB_NO
                                     AND MATNR  EQ P_LINE-MATNR.
    MOVE-CORRESPONDING LS_OPO TO GS_PO.
    APPEND GS_PO TO GT_PO.

    CLEAR: GS_PO.
  ENDLOOP.

  CLEAR: GT_PROD.
  LOOP AT GT_OPROD INTO DATA(LS_OPROD) WHERE JOB_NO EQ P_LINE-JOB_NO
                                         AND MATNR  EQ P_LINE-MATNR.
    MOVE-CORRESPONDING LS_OPROD TO GS_PROD.
    APPEND GS_PROD TO GT_PROD.

    CLEAR: GS_PROD.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BOTTOM_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BOTTOM_ALV .
  IF GO_GRID_0101 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0101.
    PERFORM SET_LAYOUT_GRID_0101.
    PERFORM SET_FIELDCAT_GRID_0101.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0101.
    PERFORM SET_EVENT USING GO_GRID_0101.
    PERFORM CALL_GRID_0101_DISPLAY.
  ELSE.
    PERFORM REF_ALV_RTN USING GO_GRID_0101.
  ENDIF.

  IF GO_GRID_0102 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0102.
    PERFORM SET_LAYOUT_GRID_0102.
    PERFORM SET_FIELDCAT_GRID_0102.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0102.
    PERFORM SET_EVENT USING GO_GRID_0102.
    PERFORM CALL_GRID_0102_DISPLAY.
  ELSE.
    PERFORM REF_ALV_RTN USING GO_GRID_0102.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0101 .
* LEFT 컨테이너
  CALL METHOD GO_SPLITTER2->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0101.

  CREATE OBJECT GO_GRID_0101
    EXPORTING
      I_PARENT      = GO_CONTAIN_0101
      I_APPL_EVENTS = ABAP_TRUE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0101 .
  CLEAR GS_LAYOUT_0101.
  GS_LAYOUT_0101-ZEBRA      = GC_X.
  GS_LAYOUT_0101-COL_OPT    = GC_X.
  GS_LAYOUT_0101-CWIDTH_OPT = GC_X.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0101 .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR4050TOP'
      I_INTERNAL_TABNAME     = 'GS_PO'
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
      ET_FIELDCAT_LVC = GT_FIELDCAT_0101[]
    TABLES
      IT_DATA         = GT_PO
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0101 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'EBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "구매오더번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'EBELP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "구매오더품목
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZPJT_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "프로젝트번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZPTXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "프로젝트내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'JOB_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "제조지시번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'JOB_NM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "제조지시내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "자재코드
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "자재내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'PO_MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "구매입고수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-DO_SUM = GC_X.
        <LS_FCAT>-QFIELDNAME = 'PO_MEINS'.
      WHEN 'PO_MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "구매단위
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MBLNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "자재문서번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MJAHR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "자재문서연도
        <LS_FCAT>-JUST = GC_C.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0101 .
  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0101
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
*& Form CALL_GRID_0101_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0101_DISPLAY .
  CALL METHOD GO_GRID_0101->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0101
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0101
    CHANGING
      IT_OUTTAB            = GT_PO
      IT_FIELDCATALOG      = GT_FIELDCAT_0101.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REF_ALV_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0101
*&---------------------------------------------------------------------*
FORM REF_ALV_RTN  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA LS_STABLE TYPE LVC_S_STBL.

  LS_STABLE-ROW = 'X'.
  LS_STABLE-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0101.
      CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
        EXPORTING
          IS_LAYOUT = GS_LAYOUT_0101.
    WHEN GO_GRID_0102.
      CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
        EXPORTING
          IS_LAYOUT = GS_LAYOUT_0102.
  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0102 .
* RIGHT 컨테이너
  CALL METHOD GO_SPLITTER2->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 2
    RECEIVING
      CONTAINER = GO_CONTAIN_0102.

  CREATE OBJECT GO_GRID_0102
    EXPORTING
      I_PARENT      = GO_CONTAIN_0102
      I_APPL_EVENTS = ABAP_TRUE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0102 .
  CLEAR GS_LAYOUT_0102.
  GS_LAYOUT_0102-ZEBRA      = GC_X.
  GS_LAYOUT_0102-COL_OPT    = GC_X.
  GS_LAYOUT_0102-CWIDTH_OPT = GC_X.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0102 .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR4050TOP'
      I_INTERNAL_TABNAME     = 'GS_PROD'
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
      ET_FIELDCAT_LVC = GT_FIELDCAT_0102[]
    TABLES
      IT_DATA         = GT_PROD
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0102 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F23. "생산오더번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZPJT_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "프로젝트번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZPTXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "프로젝트내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'JOB_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "제조지시번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'JOB_NM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "제조지시내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "자재코드
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "자재내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'PRD_MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "생산투입수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-DO_SUM = GC_X.
        <LS_FCAT>-QFIELDNAME = 'PRD_MEINS'.
      WHEN 'PRD_MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "투입단위
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MBLNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "자재문서번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MJAHR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "자재문서연도
        <LS_FCAT>-JUST = GC_C.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0102 .
  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0102
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
*& Form CALL_GRID_0102_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0102_DISPLAY .
  CALL METHOD GO_GRID_0102->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0102
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0102
    CHANGING
      IT_OUTTAB            = GT_PROD
      IT_FIELDCATALOG      = GT_FIELDCAT_0102.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_SENDER
*&      --> P_ROW_INDEX
*&---------------------------------------------------------------------*
FORM SET_SELECTED_ROWS  USING    P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                                 P_INDEX  TYPE LVC_INDEX.

  DATA: LT_INDEX_ROWS TYPE LVC_T_ROW,
        LT_ROW_NO     TYPE LVC_T_ROID.

  DATA: LS_INDEX_ROWS TYPE LVC_S_ROW,
        LS_ROW_NO     TYPE LVC_S_ROID.

  CLEAR: LT_INDEX_ROWS, LT_INDEX_ROWS[],
         LT_ROW_NO, LT_ROW_NO[].

  LS_INDEX_ROWS-INDEX = P_INDEX.
  APPEND LS_INDEX_ROWS TO LT_INDEX_ROWS.

  LS_ROW_NO-ROW_ID = P_INDEX.
  APPEND LS_ROW_NO TO LT_ROW_NO.

  P_SENDER->SET_SELECTED_ROWS(
    EXPORTING
      IT_INDEX_ROWS = LT_INDEX_ROWS
      IT_ROW_NO     = LT_ROW_NO ).
ENDFORM.
