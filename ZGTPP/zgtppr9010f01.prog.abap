*&---------------------------------------------------------------------*
*& Include          ZGTPPR9010F01
*&---------------------------------------------------------------------*
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
      WHEN 'P_WERKS'.
*        SCREEN-REQUIRED = 1.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
    ENDCASE.

    IF P_R1 EQ GC_X.
      IF SCREEN-GROUP1 = 'S1' OR
         SCREEN-GROUP1 = 'S2' OR
         SCREEN-GROUP1 = 'S3' OR
         SCREEN-GROUP1 = 'S4'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSEIF P_R2 EQ GC_X.
      IF SCREEN-GROUP1 = 'S2'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSEIF P_R3 EQ GC_X.
      IF SCREEN-GROUP1 = 'S4'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
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

  IF P_R1 EQ GC_X.     "재고정보저장
    PERFORM GET_DATA_STOCK.
  ELSEIF P_R2 EQ GC_X. "재고변환처리
    PERFORM GET_DATA_TRANS.
  ELSEIF P_R3 EQ GC_X. "재고변환결과조회/취소
    PERFORM GET_DATA_TRANS_C.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_STOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_STOCK .

  CLEAR: GT_STOCK.

  SELECT A~WERKS, A~LGORT, A~SOBKZ, A~MATNR, A~VBELN, A~POSNR,
         A~CHARG, A~KALAB,
         B~MEINS, B~MTART, B~MATKL,
         I~KWMENG, I~VRKME,
         C~NAME1,
         D~LGOBE,
         E~MAKTX,
         F~MTBEZ,
         G~WGBEZ,
         H~LWEDT
    FROM            MSKA  AS A
   INNER JOIN       MARA  AS B ON B~MATNR EQ A~MATNR
   INNER JOIN       VBAP  AS I ON I~VBELN EQ A~VBELN
                              AND I~POSNR EQ A~POSNR
    LEFT OUTER JOIN T001W AS C ON C~WERKS EQ A~WERKS
    LEFT OUTER JOIN T001L AS D ON D~WERKS EQ A~WERKS
                              AND D~LGORT EQ A~LGORT
    LEFT OUTER JOIN MAKT  AS E ON E~MATNR EQ A~MATNR
                              AND E~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T134T AS F ON F~SPRAS EQ @SY-LANGU
                              AND F~MTART EQ B~MTART
    LEFT OUTER JOIN T023T AS G ON G~SPRAS EQ @SY-LANGU
                              AND G~MATKL EQ B~MATKL
    LEFT OUTER JOIN MCH1  AS H ON H~MATNR EQ A~MATNR
                              AND H~CHARG EQ A~CHARG
   WHERE A~WERKS EQ @P_WERKS
     AND A~LGORT IN @S_LGORT
     AND A~KALAB GT 0
     AND B~MTART IN (@GC_FERT, @GC_HALB)
    INTO CORRESPONDING FIELDS OF TABLE @GT_STOCK.

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

  IF P_R1 EQ GC_X.     "재고정보저장
    PERFORM MODIFY_DATA_STOCK.
  ELSEIF P_R2 EQ GC_X. "재고변환처리
    PERFORM MODIFY_DATA_TRANS.
  ELSEIF P_R3 EQ GC_X. "재고변환결과조회/취소
    PERFORM MODIFY_DATA_TRANS_C.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA_STOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA_STOCK .

  DATA: LV_MATNR TYPE MATNR.

  DATA: LT_LIST LIKE TABLE OF ZLES001,
        LS_LIST LIKE ZLES001.

  SORT GT_STOCK BY WERKS LGORT SOBKZ MATNR VBELN POSNR CHARG.

  LOOP AT GT_STOCK ASSIGNING FIELD-SYMBOL(<FS>).
    SELECT SINGLE ZSTOCK_NO
      FROM ZGTPPT9010
     WHERE WERKS   EQ @<FS>-WERKS
       AND LGORT   EQ @<FS>-LGORT
       AND SOBKZ   EQ @<FS>-SOBKZ
       AND O_MATNR EQ @<FS>-MATNR
       AND O_VBELN EQ @<FS>-VBELN
       AND O_POSNR EQ @<FS>-POSNR
       AND O_CHARG EQ @<FS>-CHARG
      INTO @DATA(LV_ZSTK_NO).

    IF LV_ZSTK_NO IS NOT INITIAL.
      <FS>-STAT_SAVE = ICON_LED_GREEN.
      CLEAR: LV_ZSTK_NO.
    ENDIF.

    IF <FS>-STAT_SAVE IS INITIAL.
      <FS>-STAT_SAVE = ICON_LED_INACTIVE.
    ENDIF.

    <FS>-ZSTOCK_TYPE = GC_MSKA.

*-재고유형 내역
    IF <FS>-ZSTOCK_TYPE EQ GC_MSKA.
      <FS>-ZSTOCK_NAME = TEXT-T06. "판매오더재고
    ENDIF.

*-제조지시번호
    SELECT SINGLE BSTKD_E
      FROM VBKD
     WHERE VBELN EQ @<FS>-VBELN
       AND POSNR EQ @<FS>-POSNR
      INTO @<FS>-JOB_NO.

*-최종입고일 없는 경우
    IF <FS>-LWEDT IS INITIAL.
      SELECT MIN( BUDAT )
        FROM MATDOC
       WHERE RECORD_TYPE EQ @GC_MDOC
         AND WERKS EQ @<FS>-WERKS
         AND MAT_KDAUF EQ @<FS>-VBELN
         AND MAT_KDPOS EQ @<FS>-POSNR
         AND MATNR EQ @<FS>-MATNR
         AND LGORT EQ @<FS>-LGORT
         AND SHKZG EQ @GC_S
        INTO @<FS>-LWEDT.
    ENDIF.

*-형상코드/견적품명
    CLEAR: LV_MATNR.
    SELECT SINGLE MATNR
      FROM VBAP
     WHERE VBELN EQ @<FS>-VBELN
       AND POSNR EQ @<FS>-POSNR
      INTO @LV_MATNR.

    IF LV_MATNR IS NOT INITIAL.
      CLEAR: LT_LIST.
      CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC'
        EXPORTING
          I_VBELN                      = <FS>-VBELN
          I_POSNR                      = <FS>-POSNR
          I_OBJECT                     = LV_MATNR
          I_WERKS                      = <FS>-WERKS
        TABLES
          GT_LIST                      = LT_LIST
        EXCEPTIONS
          INSTANCE_NOT_FOUND           = 1
          INSTANCE_IS_A_CLASSIFICATION = 2
          INVALID_DATA                 = 3
          OTHERS                       = 4.

*-형상코드/품명
      CLEAR: LS_LIST.
      READ TABLE LT_LIST INTO LS_LIST WITH KEY ATNAM = 'PD_BD_STD_PRODUCT_NAME'.
      IF LS_LIST IS NOT INITIAL.
        <FS>-STD_PROD_NM = LS_LIST-ATWRT.
        <FS>-STD_PROD_DSCR = LS_LIST-ATWTB.
      ENDIF.

*-견적코드/품명
      CLEAR: LS_LIST.
      READ TABLE LT_LIST INTO LS_LIST WITH KEY ATNAM = 'PD_BD_PROD_NAME'.
      IF LS_LIST IS NOT INITIAL.
        <FS>-PROD_NM = LS_LIST-ATWRT.
        <FS>-PROD_DSCR = LS_LIST-ATWTB.
      ENDIF.
    ENDIF.

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
         GT_EXCLUDE_0100, GV_OK_CODE, GV_DBCNT,
         GT_STOCK[], GT_TRANS[], GT_TRANS_C[].

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
  IF P_R2 EQ GC_X.
    GS_LAYOUT_0100-EDIT       = GC_X.
    GS_LAYOUT_0100-STYLEFNAME = 'CELL_STY'.
  ENDIF.
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
  IF P_R1 EQ GC_X.     "재고정보저장
    PERFORM SET_FIELDCAT_GRID_STOCK.
  ELSEIF P_R2 EQ GC_X. "재고변환처리
    PERFORM SET_FIELDCAT_GRID_TRANS.
  ELSEIF P_R3 EQ GC_X. "재고변환결과조회/취소
    PERFORM SET_FIELDCAT_GRID_TRANS_C.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_STOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_STOCK .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR9010TOP'
      I_INTERNAL_TABNAME     = 'GS_STOCK'
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
      IT_DATA         = GT_STOCK
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'STAT_SAVE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "저장상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
      WHEN 'RTMSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "저장메시지
        <LS_FCAT>-JUST = GC_L.
      WHEN 'ZSTOCK_TYPE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "재고유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZSTOCK_NAME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "재고유형내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "플랜트
        <LS_FCAT>-JUST = GC_C.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "플랜트내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'LGORT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "저장위치
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LGOBE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "저장위치내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'SOBKZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "특별재고지시자
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "자재코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "자재내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'VBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "판매오더번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F13. "판매오더품목
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'JOB_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F59. "제조지시번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'CHARG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "배치번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'LWEDT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F61. "최종입고일
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'KALAB'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "재고수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "재고단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'MTART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "자재유형
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'MATKL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "자재그룹
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'KWMENG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F68. "판매오더수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'VRKME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F70. "수량단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'STD_PROD_NM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F72. "형상코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'STD_PROD_DSCR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F73. "형상내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'PROD_NM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F74. "견적품명코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'PROD_DSCR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F75. "견적품명내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C100'.
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
*& Form CALL_GRID_0100_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .
  IF P_R1 EQ GC_X.     "재고정보저장
    PERFORM CALL_GRID_DISPLAY_STOCK.
  ELSEIF P_R2 EQ GC_X. "재고변환처리
    PERFORM CALL_GRID_DISPLAY_TRANS.
  ELSEIF P_R3 EQ GC_X. "재고변환결과조회/취소
    PERFORM CALL_GRID_DISPLAY_TRANS_C.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_DISPLAY_STOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_DISPLAY_STOCK .
  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
*     IS_VARIANT           = GS_VARIANT
*     I_SAVE               = GC_X
    CHANGING
      IT_OUTTAB            = GT_STOCK
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_TRANS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_TRANS .

  CLEAR: GT_TRANS.
  IF P_FERT EQ GC_X.
    SELECT A~*,
           C~MTART AS O_MTART, C~MATKL AS O_MATKL,
           D~JOB_NO AS N_JOB_NO, D~MKEY,
           E~MATNR AS N_MATNR, E~VBELN AS N_VBELN, E~POSNR AS N_POSNR,
           E~VRKME AS N_MEINS, E~KWMENG AS N_KWMENG,
           F~ZPJNO,
           G~MTART AS N_MTART, G~MATKL AS N_MATKL,
           H~NAME1,
           I~LGOBE,
           J~MAKTX AS O_MAKTX,
           K~MTBEZ AS O_MTBEZ,
           L~WGBEZ AS O_WGBEZ,
           M~MAKTX AS N_MAKTX,
           N~MTBEZ AS N_MTBEZ,
           O~WGBEZ AS N_WGBEZ
      FROM      ZGTPPT9010  AS A
     INNER JOIN ZGTSDT9060  AS B ON B~VBELN EQ A~O_VBELN
                                AND B~POSNR EQ A~O_POSNR
                                AND B~ZPJNO EQ 'MIG2025619'   "SD 추가
     INNER JOIN       MARA  AS C ON C~MATNR EQ A~O_MATNR
     INNER JOIN ZGTSDT0066  AS D ON D~MKEY  EQ B~MKEY
     INNER JOIN       VBAP  AS E ON E~VBELN EQ D~VBELN
                                AND E~POSNR EQ D~POSNR
     INNER JOIN       VBAK  AS F ON F~VBELN EQ E~VBELN
     INNER JOIN       MARA  AS G ON G~MATNR EQ E~MATNR
      LEFT OUTER JOIN T001W AS H ON H~WERKS EQ A~WERKS
      LEFT OUTER JOIN T001L AS I ON I~WERKS EQ A~WERKS
                                AND I~LGORT EQ A~LGORT
      LEFT OUTER JOIN MAKT  AS J ON J~MATNR EQ A~O_MATNR
                                AND J~SPRAS EQ @SY-LANGU
      LEFT OUTER JOIN T134T AS K ON K~SPRAS EQ @SY-LANGU
                                AND K~MTART EQ C~MTART
      LEFT OUTER JOIN T023T AS L ON L~SPRAS EQ @SY-LANGU
                                AND L~MATKL EQ C~MATKL
      LEFT OUTER JOIN MAKT  AS M ON M~MATNR EQ E~MATNR
                                AND M~SPRAS EQ @SY-LANGU
      LEFT OUTER JOIN T134T AS N ON N~SPRAS EQ @SY-LANGU
                                AND N~MTART EQ G~MTART
      LEFT OUTER JOIN T023T AS O ON O~SPRAS EQ @SY-LANGU
                                AND O~MATKL EQ G~MATKL
     WHERE A~WERKS       EQ @P_WERKS
       AND A~LGORT       IN @S_LGORT
       AND A~ZSTOCK_TYPE IN @S_STKTY
       AND A~ZSTOCK_NO   IN @S_STKNO
       AND A~O_MATNR     IN @S_OMATNR
       AND A~O_VBELN     IN @S_OVBELN
       AND A~O_POSNR     IN @S_OPOSNR
       AND A~O_CHARG     IN @S_OCHARG
       AND C~MTART       EQ @GC_FERT
       AND C~MATKL       IN @S_OMATKL
       AND A~O_JOB_NO    IN @S_OJOBNO
       AND D~MKEY        NE @SPACE
      INTO CORRESPONDING FIELDS OF TABLE @GT_TRANS.

  ELSEIF P_HALB EQ GC_X.
    SELECT A~*,
           C~MTART AS O_MTART, C~MATKL AS O_MATKL,
           D~JOB_NO AS N_JOB_NO,
           E~VBELN AS N_VBELN, E~POSNR AS N_POSNR,
           F~ZPJNO,
           H~NAME1,
           I~LGOBE,
           J~MAKTX AS O_MAKTX,
           K~MTBEZ AS O_MTBEZ,
           L~WGBEZ AS O_WGBEZ
      FROM      ZGTPPT9010  AS A
     INNER JOIN ZGTSDT9060  AS B ON B~VBELN EQ A~O_VBELN
                                AND B~POSNR EQ A~O_POSNR
                                AND B~ZPJNO EQ 'MIG2025619'   "SD 추가
     INNER JOIN       MARA  AS C ON C~MATNR EQ A~O_MATNR
     INNER JOIN ZGTSDT0066  AS D ON D~MKEY  EQ B~MKEY
     INNER JOIN       VBAP  AS E ON E~VBELN EQ D~VBELN
                                AND E~POSNR EQ D~POSNR
     INNER JOIN       VBAK  AS F ON F~VBELN EQ E~VBELN
      LEFT OUTER JOIN T001W AS H ON H~WERKS EQ A~WERKS
      LEFT OUTER JOIN T001L AS I ON I~WERKS EQ A~WERKS
                                AND I~LGORT EQ A~LGORT
      LEFT OUTER JOIN MAKT  AS J ON J~MATNR EQ A~O_MATNR
                                AND J~SPRAS EQ @SY-LANGU
      LEFT OUTER JOIN T134T AS K ON K~SPRAS EQ @SY-LANGU
                                AND K~MTART EQ C~MTART
      LEFT OUTER JOIN T023T AS L ON L~SPRAS EQ @SY-LANGU
                                AND L~MATKL EQ C~MATKL
     WHERE A~WERKS       EQ @P_WERKS
       AND A~LGORT       IN @S_LGORT
       AND A~ZSTOCK_TYPE IN @S_STKTY
       AND A~ZSTOCK_NO   IN @S_STKNO
       AND A~O_MATNR     IN @S_OMATNR
       AND A~O_VBELN     IN @S_OVBELN
       AND A~O_POSNR     IN @S_OPOSNR
       AND A~O_CHARG     IN @S_OCHARG
       AND C~MTART       EQ @GC_HALB
       AND C~MATKL       IN @S_OMATKL
       AND A~O_JOB_NO    IN @S_OJOBNO
       AND D~MKEY        NE @SPACE
      INTO CORRESPONDING FIELDS OF TABLE @GT_TRANS.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_TRANS_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_TRANS_C .

  CLEAR: GT_TRANS_C.

  SELECT A~*,
         B~MTART AS O_MTART, B~MATKL AS O_MATKL,
         C~MTART AS N_MTART, C~MATKL AS N_MATKL,
         D~NAME1,
         E~LGOBE,
         F~MAKTX AS O_MAKTX,
         G~MTBEZ AS O_MTBEZ,
         H~WGBEZ AS O_WGBEZ,
         I~MAKTX AS N_MAKTX,
         J~MTBEZ AS N_MTBEZ,
         K~WGBEZ AS N_WGBEZ
    FROM      ZGTPPT9020  AS A
   INNER JOIN       MARA  AS B ON B~MATNR EQ A~O_MATNR
   INNER JOIN       MARA  AS C ON C~MATNR EQ A~N_MATNR
    LEFT OUTER JOIN T001W AS D ON D~WERKS EQ A~WERKS
    LEFT OUTER JOIN T001L AS E ON E~WERKS EQ A~WERKS
                              AND E~LGORT EQ A~LGORT
    LEFT OUTER JOIN MAKT  AS F ON F~MATNR EQ A~O_MATNR
                              AND F~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T134T AS G ON G~SPRAS EQ @SY-LANGU
                              AND G~MTART EQ B~MTART
    LEFT OUTER JOIN T023T AS H ON H~SPRAS EQ @SY-LANGU
                              AND H~MATKL EQ B~MATKL
    LEFT OUTER JOIN MAKT  AS I ON I~MATNR EQ A~N_MATNR
                              AND I~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T134T AS J ON J~SPRAS EQ @SY-LANGU
                              AND J~MTART EQ C~MTART
    LEFT OUTER JOIN T023T AS K ON K~SPRAS EQ @SY-LANGU
                              AND K~MATKL EQ C~MATKL
   WHERE A~WERKS       EQ @P_WERKS
     AND A~LGORT       IN @S_LGORT
     AND A~ZSTOCK_TYPE IN @S_STKTY
     AND A~ZSTOCK_NO   IN @S_STKNO
     AND A~MBLNR_GI    IN @S_MBLNGI
     AND A~MBLNR_GR    IN @S_MBLNGR
     AND A~AUFNR       IN @S_AUFNR
     AND A~N_MATNR     IN @S_NMATNR
     AND A~N_VBELN     IN @S_NVBELN
     AND A~N_POSNR     IN @S_NPOSNR
     AND A~N_JOB_NO    IN @S_NJOBNO
     AND A~N_CHARG     IN @S_NCHARG
     AND C~MTART       IN @S_NMTART
     AND C~MATKL       IN @S_NMATKL
     AND A~O_MATNR     IN @S_OMATNR
     AND A~O_VBELN     IN @S_OVBELN
     AND A~O_POSNR     IN @S_OPOSNR
     AND A~O_CHARG     IN @S_OCHARG
     AND A~O_JOB_NO    IN @S_OJOBNO
     AND B~MTART       IN @S_OMTART
     AND B~MATKL       IN @S_OMATKL
    INTO CORRESPONDING FIELDS OF TABLE @GT_TRANS_C.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA_TRANS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA_TRANS .

  DATA: BEGIN OF LS_SUM,
          N_VBELN  LIKE VBAP-VBELN,   "신규 판매오더번호
          N_POSNR  LIKE VBAP-POSNR,   "신규 판매오더품목
          N_MATNR  LIKE VBAP-MATNR,   "신규 자재코드
          N_MAKTX  LIKE MAKT-MAKTX,   "신규 자재내역
          N_SKALAB TYPE MENG15,       "신규 재고수량 SUM
        END OF LS_SUM.
  DATA: LT_SUM LIKE TABLE OF LS_SUM.

  DATA: BEGIN OF LS_SUM_F,
          N_VBELN  LIKE VBAP-VBELN,   "신규 판매오더번호
          N_POSNR  LIKE VBAP-POSNR,   "신규 판매오더품목
          N_MATNR  LIKE VBAP-MATNR,   "신규 자재코드
          N_MAKTX  LIKE MAKT-MAKTX,   "신규 자재내역
          N_KALAB  LIKE MSKA-KALAB,   "신규 재고수량
          N_KWMENG LIKE VBAP-KWMENG,  "신규 판매오더수량
        END OF LS_SUM_F.
  DATA: LT_SUM_F LIKE TABLE OF LS_SUM_F.

  DATA: LV_NO       TYPE ZGTE_ZSTOCK_NO,
        LV_AUFNR    TYPE AUFNR,
        LV_MBLNGI   TYPE MBLNR,
        LV_MBLNGR   TYPE MBLNR,
        LV_CHARG    TYPE CHARG_D,
        LV_O_MATNRC TYPE ZGTE_FLDVAL.

  DATA: LT_LIST LIKE TABLE OF ZLES001,
        LT_MKAL LIKE TABLE OF MKAL.

  DATA: LT_TRANS LIKE TABLE OF GS_TRANS,
        LS_TRANS LIKE GS_TRANS.

  SORT GT_TRANS BY WERKS LGORT SOBKZ ZSTOCK_NO O_MATNR.

  CLEAR: LV_NO.
  LOOP AT GT_TRANS ASSIGNING FIELD-SYMBOL(<FS>).
*-재고유형 내역
    IF <FS>-ZSTOCK_TYPE EQ GC_MSKA.
      <FS>-ZSTOCK_NAME = TEXT-T06. "판매오더재고
    ENDIF.

*-재고순번
    IF <FS>-ZSTOCK_NO EQ LV_NO.
      <FS>-ZSTOCK_SEQ = <FS>-ZSTOCK_SEQ + 1.
    ELSE.
      <FS>-ZSTOCK_SEQ = '0001'.
      CLEAR: LV_NO.
      LV_NO = <FS>-ZSTOCK_NO.
    ENDIF.

    CLEAR: LV_MBLNGI, LV_MBLNGR.
    SELECT SINGLE AUFNR, MBLNR_GI, MBLNR_GR
      FROM ZGTPPT9020
     WHERE ZSTOCK_NO  EQ @<FS>-ZSTOCK_NO
       AND ZSTOCK_SEQ EQ @<FS>-ZSTOCK_SEQ
      INTO (@<FS>-AUFNR, @LV_MBLNGI, @LV_MBLNGR).

*-재고변환생산오더상태
    IF <FS>-AUFNR IS INITIAL.
      <FS>-STAT_TRANSORD = ICON_LED_INACTIVE.
    ELSE.
      <FS>-STAT_TRANSORD = ICON_LED_GREEN.
    ENDIF.

*-기존재고투입상태
    IF LV_MBLNGI IS INITIAL.
      <FS>-STAT_OMATGI = ICON_LED_INACTIVE.
    ELSE.
      <FS>-STAT_OMATGI = ICON_LED_GREEN.
    ENDIF.

*-신규재고입고상태
    IF LV_MBLNGR IS INITIAL.
      <FS>-STAT_NMATGR = ICON_LED_INACTIVE.
    ELSE.
      <FS>-STAT_NMATGR = ICON_LED_GREEN.
    ENDIF.

*-반제품인 경우
    IF P_HALB EQ GC_X.
      SELECT SINGLE MATNR
        FROM VBAP
       WHERE VBELN EQ @<FS>-N_VBELN
         AND POSNR EQ @<FS>-N_POSNR
        INTO @DATA(LV_MATNR).

      CLEAR: LT_LIST.
      CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC'
        EXPORTING
          I_VBELN                      = <FS>-N_VBELN
          I_POSNR                      = <FS>-N_POSNR
          I_OBJECT                     = LV_MATNR
          I_WERKS                      = <FS>-WERKS
        TABLES
          GT_LIST                      = LT_LIST
        EXCEPTIONS
          INSTANCE_NOT_FOUND           = 1
          INSTANCE_IS_A_CLASSIFICATION = 2
          INVALID_DATA                 = 3
          OTHERS                       = 4.

      READ TABLE LT_LIST INTO DATA(LS_LIST) WITH KEY ATNAM = 'PD_NBD_CM_COND_MAT'.

      CLEAR: LV_O_MATNRC.
      PERFORM CONV_EXIT USING <FS>-O_MATNR LV_O_MATNRC GC_O.

      SELECT SINGLE FLD_05
        FROM ZGTPPT1010
       WHERE MODULE_KIND EQ @GC_PP
         AND CODEGRP     EQ @GC_9010
         AND FLD_01      EQ @<FS>-WERKS
         AND FLD_02      EQ @LV_O_MATNRC
         AND FLD_04      EQ @LS_LIST-ATWTB
        INTO @<FS>-N_MATNR.

      IF <FS>-N_MATNR IS INITIAL.
        SELECT SINGLE MATNR
          FROM VBAP
         WHERE VBELN EQ @<FS>-N_VBELN
           AND POSNR EQ @<FS>-N_POSNR
          INTO @<FS>-N_MATNR.
      ENDIF.

      PERFORM CONV_EXIT USING <FS>-N_MATNR <FS>-N_MATNR GC_I.

      CLEAR: LS_LIST.

      IF <FS>-N_MATNR IS NOT INITIAL.
        SELECT SINGLE
               A~MTART, A~MATKL, A~MEINS,
               B~MAKTX,
               C~MTBEZ,
               D~WGBEZ
          FROM            MARA  AS A
          LEFT OUTER JOIN MAKT  AS B ON B~MATNR EQ A~MATNR
                                    AND B~SPRAS EQ @SY-LANGU
          LEFT OUTER JOIN T134T AS C ON C~SPRAS EQ @SY-LANGU
                                    AND C~MTART EQ A~MTART
          LEFT OUTER JOIN T023T AS D ON D~SPRAS EQ @SY-LANGU
                                    AND D~MATKL EQ A~MATKL
         WHERE A~MATNR EQ @<FS>-N_MATNR
          INTO (@<FS>-N_MTART, @<FS>-N_MATKL, @<FS>-N_MEINS,
                @<FS>-N_MAKTX, @<FS>-N_MTBEZ, @<FS>-N_WGBEZ).
      ENDIF.

      IF <FS>-N_MEINS EQ <FS>-O_MEINS.
        <FS>-N_KALAB = <FS>-O_KALAB.
      ELSE.
        CLEAR: <FS>-N_KALAB.
        <FS>-RTMSG = TEXT-M42. "신규 재고수량을 결정하지 못하였습니다.
      ENDIF.

*-신규 배치번호
      CLEAR: <FS>-N_CHARG.

*-제품인 경우
    ELSEIF P_FERT EQ GC_X.
      CLEAR: LT_LIST.
      CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC'
        EXPORTING
          I_VBELN                      = <FS>-N_VBELN
          I_POSNR                      = <FS>-N_POSNR
          I_OBJECT                     = <FS>-N_MATNR
          I_WERKS                      = <FS>-WERKS
        TABLES
          GT_LIST                      = LT_LIST
        EXCEPTIONS
          INSTANCE_NOT_FOUND           = 1
          INSTANCE_IS_A_CLASSIFICATION = 2
          INVALID_DATA                 = 3
          OTHERS                       = 4.

*-신규 총길이
      CLEAR: LS_LIST.
      READ TABLE LT_LIST INTO LS_LIST WITH KEY ATNAM = 'PD_NBD_CM_LENGTH'.
      IF LS_LIST IS NOT INITIAL.
        <FS>-N_LENGTH = LS_LIST-ATWRT.
      ENDIF.

*-신규 시리얼번호수
      CLEAR: LS_LIST.
      READ TABLE LT_LIST INTO LS_LIST WITH KEY ATNAM = 'PD_NBD_CM_SERIAL_NO'.
      IF LS_LIST IS NOT INITIAL.
        <FS>-N_SERIAL_CNT = LS_LIST-ATWRT.
      ENDIF.

*-신규 배치번호
      <FS>-N_CHARG = <FS>-N_JOB_NO && GC_00.

      CLEAR: LV_CHARG.
      SELECT SINGLE CHARG
        FROM MCHA
       WHERE MATNR EQ @<FS>-N_MATNR
         AND WERKS EQ @<FS>-WERKS
         AND CHARG EQ @<FS>-N_CHARG
        INTO @LV_CHARG.

*-배치번호생성상태
      IF LV_CHARG IS INITIAL.
        <FS>-STAT_BATCHCRE = ICON_LED_INACTIVE.
      ELSE.
        <FS>-STAT_BATCHCRE = ICON_LED_GREEN.
      ENDIF.

    ENDIF.

*-신규 최종입고일
    <FS>-N_LWEDT = <FS>-O_LWEDT.

*-신규 자재코드에 대한 생산버전
    CLEAR: LT_MKAL.
    SELECT *
      FROM MKAL
     WHERE MATNR EQ @<FS>-N_MATNR
       AND WERKS EQ @<FS>-WERKS
      INTO CORRESPONDING FIELDS OF TABLE @LT_MKAL.

    SORT LT_MKAL BY VERID.
    READ TABLE LT_MKAL INTO DATA(LS_MKAL) WITH KEY VERID = GC_0010.
    IF SY-SUBRC EQ 0.
      <FS>-VERID = LS_MKAL-VERID.
    ELSE.
      CLEAR: LS_MKAL.
      READ TABLE LT_MKAL INTO LS_MKAL WITH KEY VERID = GC_SC10.
      IF SY-SUBRC EQ 0.
        <FS>-VERID = LS_MKAL-VERID.
      ENDIF.
    ENDIF.
    CLEAR: LS_MKAL.

*-형상내역/견적품내역/견적품수량
    SELECT SINGLE
           FLD_02, FLD_04, FLD_05
      FROM ZGTPPT1010
     WHERE MODULE_KIND EQ @GC_PP
       AND CODEGRP     EQ @GC_9020
       AND FLD_01      EQ @<FS>-O_STD_PROD_NM
       AND FLD_03      EQ @<FS>-O_PROD_NM
      INTO (@<FS>-O_STD_PROD_DSCR, @<FS>-O_PROD_DSCR, @<FS>-O_PROD_MNG).

  ENDLOOP.

  IF P_HALB EQ GC_X.
    CLEAR: LT_TRANS.
    APPEND LINES OF GT_TRANS TO LT_TRANS.

    SORT LT_TRANS BY N_VBELN N_POSNR N_MATNR.
    DELETE LT_TRANS WHERE N_KALAB EQ 0.

    CLEAR: LT_SUM.
    LOOP AT LT_TRANS INTO LS_TRANS.
      MOVE-CORRESPONDING LS_TRANS TO LS_SUM.
      MOVE: LS_TRANS-N_KALAB TO LS_SUM-N_SKALAB.

      COLLECT LS_SUM INTO LT_SUM.
      CLEAR: LS_SUM.
    ENDLOOP.

    SORT LT_SUM BY N_VBELN N_POSNR N_MATNR.

    LOOP AT GT_TRANS ASSIGNING <FS>.
      CLEAR: LS_SUM.
      READ TABLE LT_SUM INTO LS_SUM WITH KEY N_VBELN = <FS>-N_VBELN
                                             N_POSNR = <FS>-N_POSNR
                                             N_MATNR = <FS>-N_MATNR.
      IF LS_SUM IS NOT INITIAL.
        <FS>-N_KALAB = LS_SUM-N_SKALAB.
        CLEAR: <FS>-RTMSG.
      ELSE.
        CLEAR: LS_SUM.
        READ TABLE LT_SUM INTO LS_SUM WITH KEY N_VBELN = <FS>-N_VBELN
                                               N_POSNR = <FS>-N_POSNR.
        IF LS_SUM IS NOT INITIAL.
          IF <FS>-N_KALAB EQ 0 AND <FS>-O_MEINS EQ 'EA'.
            <FS>-N_MATNR = LS_SUM-N_MATNR.
            <FS>-N_MAKTX = LS_SUM-N_MAKTX.
            <FS>-N_KALAB = LS_SUM-N_SKALAB.
            CLEAR: <FS>-RTMSG.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: LS_SUM.

*-신규 자재코드에 대한 생산버전
      CLEAR: LT_MKAL.
      SELECT *
        FROM MKAL
       WHERE MATNR EQ @<FS>-N_MATNR
         AND WERKS EQ @<FS>-WERKS
        INTO CORRESPONDING FIELDS OF TABLE @LT_MKAL.

      SORT LT_MKAL BY VERID.
      CLEAR: LS_MKAL.
      READ TABLE LT_MKAL INTO LS_MKAL WITH KEY VERID = GC_0010.
      IF SY-SUBRC EQ 0.
        <FS>-VERID = LS_MKAL-VERID.
      ELSE.
        CLEAR: LS_MKAL.
        READ TABLE LT_MKAL INTO LS_MKAL WITH KEY VERID = GC_SC10.
        IF SY-SUBRC EQ 0.
          <FS>-VERID = LS_MKAL-VERID.
        ENDIF.
      ENDIF.
      CLEAR: LS_MKAL.

    ENDLOOP.

  ELSEIF P_FERT EQ GC_X.
    CLEAR: LT_TRANS.
    APPEND LINES OF GT_TRANS TO LT_TRANS.

    SORT LT_TRANS BY N_VBELN N_POSNR N_MATNR.

    CLEAR: LT_SUM_F.
    LOOP AT LT_TRANS INTO LS_TRANS.
      MOVE-CORRESPONDING LS_TRANS TO LS_SUM_F.

      APPEND LS_SUM_F TO LT_SUM_F.
      CLEAR: LS_SUM_F.
    ENDLOOP.

    SORT LT_SUM_F BY N_VBELN N_POSNR N_MATNR.
    DELETE ADJACENT DUPLICATES FROM LT_SUM_F COMPARING N_VBELN N_POSNR N_MATNR.

    LOOP AT LT_SUM_F ASSIGNING FIELD-SYMBOL(<LS_F>).
      CLEAR: LS_TRANS.
      LOOP AT LT_TRANS INTO LS_TRANS WHERE N_VBELN EQ <LS_F>-N_VBELN
                                       AND N_POSNR EQ <LS_F>-N_POSNR
                                       AND N_MATNR EQ <LS_F>-N_MATNR.
        IF LS_TRANS-O_KALAB EQ LS_TRANS-O_KWMENG.
          <LS_F>-N_KALAB = <LS_F>-N_KWMENG.
        ELSE.
          CLEAR: <LS_F>-N_KALAB.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    DELETE LT_SUM_F WHERE N_KALAB EQ 0.

    LOOP AT GT_TRANS ASSIGNING <FS>.
      READ TABLE LT_SUM_F INTO DATA(LS_F) WITH KEY N_VBELN = <FS>-N_VBELN
                                                   N_POSNR = <FS>-N_POSNR
                                                   N_MATNR = <FS>-N_MATNR.
      IF LS_F IS NOT INITIAL AND SY-SUBRC EQ 0.
        <FS>-N_KALAB = LS_F-N_KALAB.

      ELSE.
        <FS>-N_KALAB = 0.
*        IF <FS>-N_SERIAL_CNT IS INITIAL AND <FS>-N_LENGTH IS INITIAL AND
*           <FS>-O_MEINS EQ 'SET'.
*          <FS>-N_KALAB = <FS>-O_KALAB.
*        ELSE.
*          READ TABLE LT_TRANS INTO DATA(LS_M) WITH KEY N_VBELN = <FS>-N_VBELN
*                                                       N_POSNR = <FS>-N_POSNR
*                                                       N_MATNR = <FS>-N_MATNR
*                                                       O_MEINS = 'M'.
*          IF LS_M IS NOT INITIAL.
*            READ TABLE LT_TRANS INTO DATA(LS_EA) WITH KEY N_VBELN = <FS>-N_VBELN
*                                                          N_POSNR = <FS>-N_POSNR
*                                                          N_MATNR = <FS>-N_MATNR
*                                                          O_MEINS = 'EA'.
*
*            IF LS_EA IS NOT INITIAL.
*              <FS>-N_KALAB = LS_EA-O_KALAB * ( LS_M-N_SERIAL_CNT / LS_EA-O_KWMENG ).
*            ELSE.
*              <FS>-N_KALAB = LS_M-N_KWMENG * ( LS_M-O_KALAB / LS_M-N_LENGTH ).
*            ENDIF.
*          ENDIF.
*          CLEAR: LS_M, LS_EA.
*        ENDIF.
      ENDIF.
      CLEAR: LS_F.

*-반올림
      CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
        EXPORTING
          I_RTYPE     = ' '
          I_RUNIT     = '1'
          I_VALUE     = <FS>-N_KALAB
        IMPORTING
          E_VALUE_RND = <FS>-N_KALAB.
    ENDLOOP.

  ENDIF.

*-투입 자재용
  CLEAR: GT_TRANS_I.
  APPEND LINES OF GT_TRANS TO GT_TRANS_I.
  SORT GT_TRANS_I BY N_VBELN N_POSNR.

  LOOP AT GT_TRANS ASSIGNING FIELD-SYMBOL(<FS_S>).
    PERFORM SET_STY_RTN CHANGING <FS_S>.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA_TRANS_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA_TRANS_C .

  SORT GT_TRANS_C BY WERKS LGORT SOBKZ ZSTOCK_NO ZSTOCK_SEQ.

  LOOP AT GT_TRANS_C ASSIGNING FIELD-SYMBOL(<FS>).
*-재고유형 내역
    IF <FS>-ZSTOCK_TYPE EQ GC_MSKA.
      <FS>-ZSTOCK_NAME = TEXT-T06. "판매오더재고
    ENDIF.

*-형상내역/견적품내역/견적품수량
    SELECT SINGLE
           FLD_02, FLD_04, FLD_05
      FROM ZGTPPT1010
     WHERE MODULE_KIND EQ @GC_PP
       AND CODEGRP     EQ @GC_9020
       AND FLD_01      EQ @<FS>-O_STD_PROD_NM
       AND FLD_03      EQ @<FS>-O_PROD_NM
      INTO (@<FS>-O_STD_PROD_DSCR, @<FS>-O_PROD_DSCR, @<FS>-O_PROD_MNG).
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_TRANS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_TRANS .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR9010TOP'
      I_INTERNAL_TABNAME     = 'GS_TRANS'
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
      IT_DATA         = GT_TRANS
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ZSTOCK_TYPE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "재고유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZSTOCK_NAME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "재고유형내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "플랜트
        <LS_FCAT>-JUST = GC_C.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "플랜트내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'LGORT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "저장위치
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LGOBE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "저장위치내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'SOBKZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "특별재고지시자
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZSTOCK_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "재고번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZSTOCK_SEQ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "재고순번
        <LS_FCAT>-JUST = GC_C.
      WHEN 'STAT_TRANSORD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "재고변환생산오더상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F64. "생산오더번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'STAT_OMATGI'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "기존재고투입상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
      WHEN 'STAT_BATCHCRE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F23. "배치번호생성상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
        IF P_HALB EQ GC_X.
          <LS_FCAT>-NO_OUT = GC_X.
        ENDIF.
      WHEN 'STAT_NMATGR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F24. "신규재고입고상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
      WHEN 'RTMSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F25. "처리메시지
        <LS_FCAT>-JUST = GC_L.
      WHEN 'N_MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F26. "신규자재코드
        <LS_FCAT>-JUST = GC_C.
*        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F27. "신규자재내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_VBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F28. "신규판매오더번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F29. "신규판매오더품목
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_JOB_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F30. "신규제조지시번호
        <LS_FCAT>-JUST = GC_C.
*        <LS_FCAT>-EMPHASIZE = 'C600'.
*      WHEN 'N_LINE_NO'.
*        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F31. "신규라인번호
*        <LS_FCAT>-JUST = GC_C.
*        <LS_FCAT>-EMPHASIZE = 'C600'.
*      WHEN 'N_SERIAL_INFO'.
*        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F32. "신규시리얼정보
*        <LS_FCAT>-JUST = GC_C.
*        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_CHARG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F33. "신규배치번호
        <LS_FCAT>-JUST = GC_C.
*        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_LWEDT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F62. "신규최종입고일
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_KALAB'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F34. "신규재고수량
        <LS_FCAT>-JUST = GC_R.
*        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F35. "신규재고단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_MTART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F36. "신규자재유형
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_MATKL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F37. "신규자재그룹
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_KWMENG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F65. "신규판매오더수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C600'.
        IF P_HALB EQ GC_X.
          <LS_FCAT>-NO_OUT = GC_X.
        ENDIF.
      WHEN 'N_LENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F66. "신규총길이
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
        IF P_HALB EQ GC_X.
          <LS_FCAT>-NO_OUT = GC_X.
        ENDIF.
      WHEN 'N_SERIAL_CNT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F67. "신규시리얼번호수
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
        IF P_HALB EQ GC_X.
          <LS_FCAT>-NO_OUT = GC_X.
        ENDIF.
      WHEN 'O_MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F38. "기존자재코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F39. "기존자재내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_VBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F40. "기존판매오더번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F41. "기존판매오더품목
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_JOB_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F60. "기존제조지시번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_CHARG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F42. "기존배치번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_LWEDT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F63. "기존최종입고일
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_KALAB'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F43. "기존재고수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F44. "기존재고단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_MTART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F45. "기존자재유형
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_MATKL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F46. "기존자재그룹
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_KWMENG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F69. "기존판매오더수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_VRKME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F71. "기존수량단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_STD_PROD_NM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F72. "형상코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_STD_PROD_DSCR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F73. "형상내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_PROD_NM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F74. "견적품명코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_PROD_DSCR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F75. "견적품명내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_PROD_MNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F76. "견적품수량
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'CRDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F47. "생성일자
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'CRTIM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F48. "생성시간
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'CRNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F49. "생성자
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_DISPLAY_TRANS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_DISPLAY_TRANS .
  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
*     IS_VARIANT           = GS_VARIANT
*     I_SAVE               = GC_X
    CHANGING
      IT_OUTTAB            = GT_TRANS
      IT_SORT              = GT_SORT_0100
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_TRANS_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_TRANS_C .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR9010TOP'
      I_INTERNAL_TABNAME     = 'GS_TRANS_C'
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
      IT_DATA         = GT_TRANS_C
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ZSTOCK_TYPE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "재고유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZSTOCK_NAME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "재고유형내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "플랜트
        <LS_FCAT>-JUST = GC_C.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "플랜트내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'LGORT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "저장위치
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LGOBE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "저장위치내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'SOBKZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "특별재고지시자
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZSTOCK_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "재고번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZSTOCK_SEQ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "재고순번
        <LS_FCAT>-JUST = GC_C.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F50. "재고변환생산오더
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MBLNR_GI'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F51. "기존재고투입자재문서
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MBLNR_GR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F52. "신규재고입고자재문서
        <LS_FCAT>-JUST = GC_C.
      WHEN 'RTMSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F53. "취소처리메시지
        <LS_FCAT>-JUST = GC_L.
      WHEN 'N_MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F26. "신규자재코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F27. "신규자재내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_VBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F28. "신규판매오더번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F29. "신규판매오더품목
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_JOB_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F30. "신규제조지시번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
*      WHEN 'N_LINE_NO'.
*        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F31. "신규라인번호
*        <LS_FCAT>-JUST = GC_C.
*        <LS_FCAT>-EMPHASIZE = 'C600'.
*      WHEN 'N_SERIAL_INFO'.
*        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F32. "신규시리얼정보
*        <LS_FCAT>-JUST = GC_C.
*        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_CHARG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F33. "신규배치번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_LWEDT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F62. "신규최종입고일
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_KALAB'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F34. "신규재고수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F35. "신규재고단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_MTART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F36. "신규자재유형
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_MATKL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F37. "신규자재그룹
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_KWMENG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F65. "신규판매오더수량
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_LENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F66. "신규총길이
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'N_SERIAL_CNT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F67. "신규시리얼번호수
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'O_MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F38. "기존자재코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F39. "기존자재내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_VBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F40. "기존판매오더번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F41. "기존판매오더품목
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_JOB_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F60. "기존제조지시번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_CHARG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F42. "기존배치번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_LWEDT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F63. "기존최종입고일
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_KALAB'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F43. "기존재고수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F44. "기존재고단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_MTART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F45. "기존자재유형
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_MATKL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F46. "기존자재그룹
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_KWMENG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F69. "기존판매오더수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_VRKME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F71. "기존수량단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_STD_PROD_NM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F72. "형상코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_STD_PROD_DSCR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F73. "형상내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_PROD_NM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F74. "견적품명코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_PROD_DSCR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F75. "견적품명내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'O_PROD_MNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F76. "견적품수량
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'CRDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F47. "생성일자
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'CRTIM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F48. "생성시간
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'CRNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F49. "생성자
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'CHDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F54. "변경일자
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'CHTIM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F55. "변경시간
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'CHNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F56. "변경자
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_DISPLAY_TRANS_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_DISPLAY_TRANS_C .
  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
*     IS_VARIANT           = GS_VARIANT
*     I_SAVE               = GC_X
    CHANGING
      IT_OUTTAB            = GT_TRANS_C
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_STKCONF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_STKCONF .

  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_STOCK.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M03. "저장할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T07 "재고 확정 처리
      TEXT_QUESTION         = TEXT-T08 "재고 확정 처리를 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    SELECT SINGLE WERKS
      FROM ZGTPPT9010
     WHERE WERKS EQ @P_WERKS
      INTO @DATA(LV_WERKS).

    IF LV_WERKS IS NOT INITIAL.
      MESSAGE S003 DISPLAY LIKE GC_E
         WITH TEXT-M04. "확정된 재고 데이터가 존재합니다.필요시 확정 취소 후 진행하세요.
      EXIT.
    ELSE.
      LOOP AT LT_ROW_NO.
        READ TABLE GT_STOCK ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

        PERFORM EXEC_STK_CONF USING <FS_S>.
      ENDLOOP.
    ENDIF.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REF_ALV_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REF_ALV_RTN .
  DATA LS_STABLE TYPE LVC_S_STBL.

  CALL METHOD GO_GRID_0100->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYOUT_0100.

  LS_STABLE-ROW = 'X'.
  LS_STABLE-COL = 'X'.

  CALL METHOD GO_GRID_0100->REFRESH_TABLE_DISPLAY
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
*& Form EXEC_STK_CONF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_STK_CONF  USING    P_LINE LIKE GS_STOCK.

  DATA: LS_ZGTPPT9010 LIKE ZGTPPT9010.

  DATA: LV_ZSTOCK_NO LIKE ZGTPPT9010-ZSTOCK_NO.

  CLEAR: LV_ZSTOCK_NO.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = GC_01
      OBJECT                  = GC_ZGTPP_STNO
    IMPORTING
      NUMBER                  = LV_ZSTOCK_NO
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.

  IF LV_ZSTOCK_NO IS INITIAL.
    P_LINE-RTMSG = TEXT-M05. "재고번호 채번 오류
  ENDIF.

  CHECK LV_ZSTOCK_NO IS NOT INITIAL.

  CLEAR: LS_ZGTPPT9010.
  LS_ZGTPPT9010-ZSTOCK_NO     = LV_ZSTOCK_NO.
  LS_ZGTPPT9010-ZSTOCK_TYPE   = P_LINE-ZSTOCK_TYPE.
  LS_ZGTPPT9010-WERKS         = P_LINE-WERKS.
  LS_ZGTPPT9010-LGORT         = P_LINE-LGORT.
  LS_ZGTPPT9010-SOBKZ         = P_LINE-SOBKZ.
  LS_ZGTPPT9010-O_MATNR       = P_LINE-MATNR.
  LS_ZGTPPT9010-O_VBELN       = P_LINE-VBELN.
  LS_ZGTPPT9010-O_POSNR       = P_LINE-POSNR.
  LS_ZGTPPT9010-O_JOB_NO      = P_LINE-JOB_NO.
  LS_ZGTPPT9010-O_CHARG       = P_LINE-CHARG.
  LS_ZGTPPT9010-O_LWEDT       = P_LINE-LWEDT.
  LS_ZGTPPT9010-O_KALAB       = P_LINE-KALAB.
  LS_ZGTPPT9010-O_MEINS       = P_LINE-MEINS.
  LS_ZGTPPT9010-O_KWMENG      = P_LINE-KWMENG.
  LS_ZGTPPT9010-O_VRKME       = P_LINE-VRKME.
  LS_ZGTPPT9010-O_STD_PROD_NM = P_LINE-STD_PROD_NM.
  LS_ZGTPPT9010-O_PROD_NM     = P_LINE-PROD_NM.
  LS_ZGTPPT9010-CRDAT         = SY-DATUM.
  LS_ZGTPPT9010-CRTIM         = SY-UZEIT.
  LS_ZGTPPT9010-CRNAM         = SY-UNAME.

  MODIFY ZGTPPT9010 FROM LS_ZGTPPT9010.

  IF SY-SUBRC EQ 0.
    COMMIT WORK.
    P_LINE-STAT_SAVE = ICON_LED_GREEN.
    P_LINE-RTMSG = TEXT-M06. "재고 확정 처리에 성공하였습니다.
  ELSE.
    ROLLBACK WORK.
    P_LINE-STAT_SAVE = ICON_LED_RED.
    P_LINE-RTMSG = TEXT-M07. "재고 확정 처리 도중 오류가 발생하였습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_BATCHCRE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_BATCHCRE .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  DATA: LT_SEL LIKE TABLE OF GS_TRANS.

  FIELD-SYMBOLS: <FS_S> LIKE GS_TRANS.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M08. "배치번호 생성을 수행할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T09 "배치번호 생성
      TEXT_QUESTION         = TEXT-T10 "배치번호 생성을 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: LT_SEL.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_TRANS ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-STAT_BATCHCRE EQ ICON_LED_GREEN.
        <FS_S>-RTMSG = TEXT-M09. "이미 배치번호가 생성된 레코드입니다.
      ELSE.
*-선택한 데이터
        APPEND <FS_S> TO LT_SEL.
      ENDIF.
    ENDLOOP.

*-선택한 데이터를 플랜트, 신규 자재코드, 신규 배치번호 기준으로 중복 제거
    SORT LT_SEL BY WERKS N_MATNR N_CHARG.
    DELETE ADJACENT DUPLICATES FROM LT_SEL
                          COMPARING WERKS N_MATNR N_CHARG.

*-산택된 데이터를 플랜트, 신규 자재코드, 신규 배치번호 기준으로 배치 생성
    LOOP AT LT_SEL ASSIGNING FIELD-SYMBOL(<FS_SEL>).
      PERFORM EXEC_BATCH_CRE USING <FS_SEL>.
    ENDLOOP.

*-처리 결과 ALV 적용
    LOOP AT GT_TRANS ASSIGNING <FS_S> WHERE STAT_BATCHCRE NE ICON_LED_GREEN.
      READ TABLE LT_SEL INTO DATA(LS_SEL) WITH KEY WERKS   = <FS_S>-WERKS
                                                   N_MATNR = <FS_S>-N_MATNR
                                                   N_CHARG = <FS_S>-N_CHARG.
      IF SY-SUBRC EQ 0 AND LS_SEL IS NOT INITIAL.
        <FS_S>-STAT_BATCHCRE = LS_SEL-STAT_BATCHCRE.
        <FS_S>-RTMSG         = LS_SEL-RTMSG.
      ENDIF.
      CLEAR: LS_SEL.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_BATCH_CRE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_BATCH_CRE  USING    P_LINE LIKE GS_TRANS.

  DATA : LS_YMCHA  LIKE MCHA,
         LT_RETURN LIKE TABLE OF BAPIRET2 WITH HEADER LINE.

  CLEAR:LS_YMCHA.
  LS_YMCHA-MATNR         = P_LINE-N_MATNR.
  LS_YMCHA-WERKS         = P_LINE-WERKS.
  LS_YMCHA-CHARG         = P_LINE-N_CHARG.
  LS_YMCHA-ZZPJT_NO      = P_LINE-ZPJNO.
  LS_YMCHA-ZZJOB_NO      = P_LINE-N_JOB_NO.
  LS_YMCHA-ZZLINE_NO     = GC_MIG.
  LS_YMCHA-ZZSERIAL_INFO = GC_MIG.
  LS_YMCHA-LWEDT         = P_LINE-N_LWEDT.

  CLEAR: LT_RETURN, LT_RETURN[].
  CALL FUNCTION 'VB_CREATE_BATCH'
    EXPORTING
      YMCHA                        = LS_YMCHA
    TABLES
      RETURN                       = LT_RETURN
    EXCEPTIONS
      NO_MATERIAL                  = 1
      NO_BATCH                     = 2
      NO_PLANT                     = 3
      MATERIAL_NOT_FOUND           = 4
      PLANT_NOT_FOUND              = 5
      STOLOC_NOT_FOUND             = 6
      LOCK_ON_MATERIAL             = 7
      LOCK_ON_PLANT                = 8
      LOCK_ON_BATCH                = 9
      LOCK_SYSTEM_ERROR            = 10
      NO_AUTHORITY                 = 11
      BATCH_EXIST                  = 12
      STOLOC_EXIST                 = 13
      ILLEGAL_BATCH_NUMBER         = 14
      NO_BATCH_HANDLING            = 15
      NO_VALUATION_AREA            = 16
      VALUATION_TYPE_NOT_FOUND     = 17
      NO_VALUATION_FOUND           = 18
      ERROR_AUTOMATIC_BATCH_NUMBER = 19
      CANCELLED                    = 20
      WRONG_STATUS                 = 21
      INTERVAL_NOT_FOUND           = 22
      NUMBER_RANGE_NOT_EXTERN      = 23
      OBJECT_NOT_FOUND             = 24
      ERROR_CHECK_BATCH_NUMBER     = 25
      NO_EXTERNAL_NUMBER           = 26
      NO_CUSTOMER_NUMBER           = 27
      NO_CLASS                     = 28
      ERROR_IN_CLASSIFICATION      = 29
      INCONSISTENCY_IN_KEY         = 30
      REGION_OF_ORIGIN_NOT_FOUND   = 31
      COUNTRY_OF_ORIGIN_NOT_FOUND  = 32
      VENDOR_ERROR                 = 33
      OTHERS                       = 34.

  IF SY-SUBRC EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = GC_X.

    P_LINE-STAT_BATCHCRE = ICON_LED_GREEN.
    P_LINE-RTMSG = TEXT-M10. "배치마스터 생성에 성공하였습니다.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    P_LINE-STAT_BATCHCRE = ICON_LED_RED.

    READ TABLE LT_RETURN WITH KEY TYPE = GC_E.
    P_LINE-RTMSG = LT_RETURN-MESSAGE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_TRAORDCRE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_TRAORDCRE .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  DATA: LT_SEL LIKE TABLE OF GS_TRANS.

  FIELD-SYMBOLS: <FS_S> LIKE GS_TRANS.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M11. "변환 생산오더 생성을 수행할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T11 "재고변환 생산오더 생성
      TEXT_QUESTION         = TEXT-T12 "재고변환 생산오더 생성을 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: LT_SEL.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_TRANS ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-STAT_TRANSORD EQ ICON_LED_GREEN.
        <FS_S>-RTMSG = TEXT-M12. "이미 재고 변환 생산오더가 생성된 레코드입니다.
      ELSE.
        IF P_FERT EQ GC_X.
*          IF <FS_S>-STAT_BATCHCRE NE ICON_LED_GREEN.
*            <FS_S>-RTMSG = TEXT-M13. "배치번호 생성 이후 진행하십시요.
*          ELSE.
          IF <FS_S>-VERID IS INITIAL.
            <FS_S>-RTMSG = TEXT-M41. "알맞은 생산버전은 존재하지 않습니다.
          ELSE.
*-선택한 데이터
            APPEND <FS_S> TO LT_SEL.
          ENDIF.
*          ENDIF.
        ELSEIF P_HALB EQ GC_X.
          IF <FS_S>-VERID IS INITIAL.
            <FS_S>-RTMSG = TEXT-M41. "알맞은 생산버전은 존재하지 않습니다.
          ELSE.
*-선택한 데이터
            APPEND <FS_S> TO LT_SEL.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

*-선택한 데이터를 신규판매오더, 신규판매품목, 신규자재번호 기준으로 중복 제거
    SORT LT_SEL BY N_VBELN N_POSNR N_MATNR.
    DELETE ADJACENT DUPLICATES FROM LT_SEL
                          COMPARING N_VBELN N_POSNR N_MATNR.

*-선택된 데이터를 신규판매오더, 신규판매품목 기준으로 변환 오더 생성
    LOOP AT LT_SEL ASSIGNING FIELD-SYMBOL(<FS_SEL>).
      PERFORM EXEC_TRAORDER_CRE USING <FS_SEL>.
    ENDLOOP.

*-처리 결과 ALV 적용
    IF P_FERT EQ GC_X.
*      LOOP AT GT_TRANS ASSIGNING <FS_S> WHERE STAT_BATCHCRE EQ ICON_LED_GREEN
      LOOP AT GT_TRANS ASSIGNING <FS_S> WHERE STAT_TRANSORD NE ICON_LED_GREEN.
        READ TABLE LT_SEL INTO DATA(LS_SEL) WITH KEY N_VBELN = <FS_S>-N_VBELN
                                                     N_POSNR = <FS_S>-N_POSNR
                                                     N_MATNR = <FS_S>-N_MATNR.
        IF SY-SUBRC EQ 0 AND LS_SEL IS NOT INITIAL.
          <FS_S>-STAT_TRANSORD = LS_SEL-STAT_TRANSORD.
          <FS_S>-RTMSG         = LS_SEL-RTMSG.
          <FS_S>-AUFNR         = LS_SEL-AUFNR.

          IF LS_SEL-STAT_TRANSORD EQ ICON_LED_GREEN.
            PERFORM SAVE_ZGTPPT9020 USING <FS_S>.
          ENDIF.
        ENDIF.
        CLEAR: LS_SEL.
      ENDLOOP.

*-투입 자재용 ITAB에 처리 결과 UPDATE(성공만)
      LOOP AT GT_TRANS_I ASSIGNING FIELD-SYMBOL(<FS_I>).
        READ TABLE LT_SEL INTO LS_SEL WITH KEY N_VBELN = <FS_I>-N_VBELN
                                               N_POSNR = <FS_I>-N_POSNR
                                               N_MATNR = <FS_I>-N_MATNR.
        IF SY-SUBRC EQ 0 AND LS_SEL IS NOT INITIAL.
          IF LS_SEL-STAT_TRANSORD EQ ICON_LED_GREEN.
            <FS_I>-STAT_TRANSORD = LS_SEL-STAT_TRANSORD.
            <FS_I>-RTMSG         = LS_SEL-RTMSG.
            <FS_I>-AUFNR         = LS_SEL-AUFNR.
          ENDIF.
        ENDIF.
        CLEAR: LS_SEL.
      ENDLOOP.

    ELSEIF P_HALB EQ GC_X.
      LOOP AT GT_TRANS ASSIGNING <FS_S> WHERE STAT_TRANSORD NE ICON_LED_GREEN.
        READ TABLE LT_SEL INTO LS_SEL WITH KEY N_VBELN = <FS_S>-N_VBELN
                                               N_POSNR = <FS_S>-N_POSNR
                                               N_MATNR = <FS_S>-N_MATNR.
        IF SY-SUBRC EQ 0 AND LS_SEL IS NOT INITIAL.
          <FS_S>-STAT_TRANSORD = LS_SEL-STAT_TRANSORD.
          <FS_S>-RTMSG         = LS_SEL-RTMSG.
          <FS_S>-AUFNR         = LS_SEL-AUFNR.

          IF LS_SEL-STAT_TRANSORD EQ ICON_LED_GREEN.
            PERFORM SAVE_ZGTPPT9020 USING <FS_S>.
          ENDIF.
        ENDIF.
        CLEAR: LS_SEL.
      ENDLOOP.

*-투입 자재용 ITAB에 처리 결과 UPDATE(성공만)
      LOOP AT GT_TRANS_I ASSIGNING <FS_I>.
        READ TABLE LT_SEL INTO LS_SEL WITH KEY N_VBELN = <FS_I>-N_VBELN
                                               N_POSNR = <FS_I>-N_POSNR
                                               N_MATNR = <FS_I>-N_MATNR.
        IF SY-SUBRC EQ 0 AND LS_SEL IS NOT INITIAL.
          IF LS_SEL-STAT_TRANSORD EQ ICON_LED_GREEN.
            <FS_I>-STAT_TRANSORD = LS_SEL-STAT_TRANSORD.
            <FS_I>-RTMSG         = LS_SEL-RTMSG.
            <FS_I>-AUFNR         = LS_SEL-AUFNR.
          ENDIF.
        ENDIF.
        CLEAR: LS_SEL.
      ENDLOOP.

    ENDIF.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_TRAORDER_CRE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_TRAORDER_CRE  USING    P_LINE LIKE GS_TRANS.

  DATA: LS_ORDER TYPE BAPI_PP_ORDER_CREATE.
  DATA: LS_RETURN TYPE BAPIRET2.
  DATA: LV_ORDER_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER.

  CLEAR: LS_ORDER.

*  오더 생성
  LS_ORDER-MATERIAL              = P_LINE-N_MATNR.
  LS_ORDER-PLANT                 = P_LINE-WERKS.
  LS_ORDER-ORDER_TYPE            = GC_PP99.
  LS_ORDER-BASIC_START_DATE      = SY-DATUM.
  LS_ORDER-BASIC_START_TIME      = '000000'.
  LS_ORDER-BASIC_END_DATE        = SY-DATUM.
  LS_ORDER-BASIC_END_TIME        = '000000'.
  LS_ORDER-QUANTITY              = P_LINE-N_KALAB.
  LS_ORDER-QUANTITY_UOM          = P_LINE-N_MEINS.
  LS_ORDER-PROD_VERSION          = P_LINE-VERID.
  LS_ORDER-SALES_ORDER           = P_LINE-N_VBELN.
  LS_ORDER-SALES_ORDER_ITEM      = P_LINE-N_POSNR.
  LS_ORDER-BASIC_SCHEDULING_TYPE = GC_3.

  CLEAR: LS_RETURN, LV_ORDER_NUMBER.
  CALL FUNCTION 'BAPI_PRODORD_CREATE'
    EXPORTING
      ORDERDATA    = LS_ORDER
    IMPORTING
      RETURN       = LS_RETURN
      ORDER_NUMBER = LV_ORDER_NUMBER.

  IF LS_RETURN-TYPE NE GC_E.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = GC_X.

* 커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
    DO 10000 TIMES.
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

    P_LINE-STAT_TRANSORD = ICON_LED_GREEN.
    P_LINE-RTMSG = TEXT-M14. "재고변환 생산오더 생성에 성공하였습니다.
    P_LINE-AUFNR = LV_ORDER_NUMBER.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    P_LINE-STAT_TRANSORD = ICON_LED_RED.
    P_LINE-RTMSG = LS_RETURN-MESSAGE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZGTPPT9020
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM SAVE_ZGTPPT9020  USING    P_LINE LIKE GS_TRANS.

  DATA: LS_ZGTPPT9020  LIKE ZGTPPT9020,
        LS_ZGTPPT9020S LIKE ZGTPPT9020.

  CLEAR: LS_ZGTPPT9020S.
  SELECT SINGLE *
    FROM ZGTPPT9020
   WHERE ZSTOCK_NO EQ @P_LINE-ZSTOCK_NO
     AND ZSTOCK_SEQ EQ @P_LINE-ZSTOCK_SEQ
    INTO CORRESPONDING FIELDS OF @LS_ZGTPPT9020S.

  CLEAR: LS_ZGTPPT9020.
  LS_ZGTPPT9020-ZSTOCK_NO     = P_LINE-ZSTOCK_NO.
  LS_ZGTPPT9020-ZSTOCK_SEQ    = P_LINE-ZSTOCK_SEQ.
  LS_ZGTPPT9020-ZSTOCK_TYPE   = P_LINE-ZSTOCK_TYPE.
  LS_ZGTPPT9020-WERKS         = P_LINE-WERKS.
  LS_ZGTPPT9020-LGORT         = P_LINE-LGORT.
  LS_ZGTPPT9020-SOBKZ         = P_LINE-SOBKZ.
  LS_ZGTPPT9020-O_MATNR       = P_LINE-O_MATNR.
  LS_ZGTPPT9020-O_VBELN       = P_LINE-O_VBELN.
  LS_ZGTPPT9020-O_POSNR       = P_LINE-O_POSNR.
  LS_ZGTPPT9020-O_JOB_NO      = P_LINE-O_JOB_NO.
  LS_ZGTPPT9020-O_CHARG       = P_LINE-O_CHARG.
  LS_ZGTPPT9020-O_LWEDT       = P_LINE-O_LWEDT.
  LS_ZGTPPT9020-O_KALAB       = P_LINE-O_KALAB.
  LS_ZGTPPT9020-O_MEINS       = P_LINE-O_MEINS.
  LS_ZGTPPT9020-O_KWMENG      = P_LINE-O_KWMENG.
  LS_ZGTPPT9020-O_VRKME       = P_LINE-O_VRKME.
  LS_ZGTPPT9020-O_STD_PROD_NM = P_LINE-O_STD_PROD_NM.
  LS_ZGTPPT9020-O_PROD_NM     = P_LINE-O_PROD_NM.
  LS_ZGTPPT9020-N_MATNR       = P_LINE-N_MATNR.
  LS_ZGTPPT9020-N_VBELN       = P_LINE-N_VBELN.
  LS_ZGTPPT9020-N_POSNR       = P_LINE-N_POSNR.
  LS_ZGTPPT9020-N_JOB_NO      = P_LINE-N_JOB_NO.
  LS_ZGTPPT9020-N_CHARG       = P_LINE-N_CHARG.
  LS_ZGTPPT9020-N_LWEDT       = P_LINE-N_LWEDT.
  LS_ZGTPPT9020-N_KALAB       = P_LINE-N_KALAB.
  LS_ZGTPPT9020-N_MEINS       = P_LINE-N_MEINS.
  LS_ZGTPPT9020-N_KWMENG      = P_LINE-N_KWMENG.
  LS_ZGTPPT9020-N_LENGTH      = P_LINE-N_LENGTH.
  LS_ZGTPPT9020-N_SERIAL_CNT  = P_LINE-N_SERIAL_CNT.
  LS_ZGTPPT9020-AUFNR         = P_LINE-AUFNR.
  LS_ZGTPPT9020-MBLNR_GI      = SPACE.
  LS_ZGTPPT9020-MJAHR_GI      = SPACE.
  LS_ZGTPPT9020-MBLNR_GR      = SPACE.
  LS_ZGTPPT9020-MJAHR_GR      = SPACE.
  IF LS_ZGTPPT9020S IS INITIAL.
    LS_ZGTPPT9020-CRDAT         = SY-DATUM.
    LS_ZGTPPT9020-CRTIM         = SY-UZEIT.
    LS_ZGTPPT9020-CRNAM         = SY-UNAME.
  ELSE.
    LS_ZGTPPT9020-CRDAT         = LS_ZGTPPT9020S-CRDAT.
    LS_ZGTPPT9020-CRTIM         = LS_ZGTPPT9020S-CRTIM.
    LS_ZGTPPT9020-CRNAM         = LS_ZGTPPT9020S-CRNAM.
    LS_ZGTPPT9020-CHDAT         = SY-DATUM.
    LS_ZGTPPT9020-CHTIM         = SY-UZEIT.
    LS_ZGTPPT9020-CHNAM         = SY-UNAME.
  ENDIF.

  MODIFY ZGTPPT9020 FROM LS_ZGTPPT9020.

  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_OMATGI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_OMATGI .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  DATA: LT_SEL LIKE TABLE OF GS_TRANS.

  FIELD-SYMBOLS: <FS_S> LIKE GS_TRANS.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M15. "기존 자재 투입 처리를 수행할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T13 "기존 재고 투입 처리
      TEXT_QUESTION         = TEXT-T14 "기존 재고 투입 처리를 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: LT_SEL.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_TRANS ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-STAT_OMATGI EQ ICON_LED_GREEN.
        <FS_S>-RTMSG = TEXT-M16. "이미 기존 재고 투입이 처리된 레코드입니다.
      ELSE.
        IF <FS_S>-STAT_TRANSORD NE ICON_LED_GREEN.
          <FS_S>-RTMSG = TEXT-M17. "재고 변환 생산오더 생성 이후 진행하십시요.
        ELSE.
*-선택한 데이터
          APPEND <FS_S> TO LT_SEL.
        ENDIF.
      ENDIF.
    ENDLOOP.

*-선택한 데이터를 변환 생산오더 기준으로 중복 제거
    SORT LT_SEL BY AUFNR.
    DELETE ADJACENT DUPLICATES FROM LT_SEL
                          COMPARING AUFNR.

*-선택한 데이터를 변환 생산오더 기준으로 기존 자재 투입
    LOOP AT LT_SEL ASSIGNING FIELD-SYMBOL(<FS_SEL>).
      PERFORM EXEC_OMAT_GI USING <FS_SEL>.
    ENDLOOP.

*-처리 결과 ALV 적용
    IF P_FERT EQ GC_X.
      LOOP AT GT_TRANS ASSIGNING <FS_S> WHERE STAT_TRANSORD EQ ICON_LED_GREEN
                                          AND STAT_OMATGI   NE ICON_LED_GREEN.
        READ TABLE LT_SEL INTO DATA(LS_SEL) WITH KEY AUFNR = <FS_S>-AUFNR.
        IF SY-SUBRC EQ 0 AND LS_SEL IS NOT INITIAL.
          <FS_S>-STAT_OMATGI = LS_SEL-STAT_OMATGI.
          <FS_S>-RTMSG       = LS_SEL-RTMSG.
          <FS_S>-MBLNR_GI    = LS_SEL-MBLNR_GI.
          <FS_S>-MJAHR_GI    = LS_SEL-MJAHR_GI.

          IF LS_SEL-STAT_OMATGI EQ ICON_LED_GREEN.
            UPDATE ZGTPPT9020 SET MBLNR_GI = LS_SEL-MBLNR_GI
                                  MJAHR_GI = LS_SEL-MJAHR_GI
                                  CHDAT    = SY-DATUM
                                  CHTIM    = SY-UZEIT
                                  CHNAM    = SY-UNAME
                            WHERE ZSTOCK_NO = <FS_S>-ZSTOCK_NO
                              AND ZSTOCK_SEQ = <FS_S>-ZSTOCK_SEQ.

            COMMIT WORK.

          ENDIF.
        ENDIF.
        CLEAR: LS_SEL.
      ENDLOOP.

    ELSEIF P_HALB EQ GC_X.
      LOOP AT GT_TRANS ASSIGNING <FS_S> WHERE STAT_TRANSORD EQ ICON_LED_GREEN
                                          AND STAT_OMATGI   NE ICON_LED_GREEN.
        READ TABLE LT_SEL INTO LS_SEL WITH KEY AUFNR = <FS_S>-AUFNR.
        IF SY-SUBRC EQ 0 AND LS_SEL IS NOT INITIAL.
          <FS_S>-STAT_OMATGI = LS_SEL-STAT_OMATGI.
          <FS_S>-RTMSG       = LS_SEL-RTMSG.
          <FS_S>-MBLNR_GI    = LS_SEL-MBLNR_GI.
          <FS_S>-MJAHR_GI    = LS_SEL-MJAHR_GI.

          IF LS_SEL-STAT_OMATGI EQ ICON_LED_GREEN.
            UPDATE ZGTPPT9020 SET MBLNR_GI = LS_SEL-MBLNR_GI
                                  MJAHR_GI = LS_SEL-MJAHR_GI
                                  CHDAT    = SY-DATUM
                                  CHTIM    = SY-UZEIT
                                  CHNAM    = SY-UNAME
                            WHERE ZSTOCK_NO = <FS_S>-ZSTOCK_NO
                              AND ZSTOCK_SEQ = <FS_S>-ZSTOCK_SEQ.

            COMMIT WORK.

          ENDIF.
        ENDIF.
        CLEAR: LS_SEL.
      ENDLOOP.

    ENDIF.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_OMAT_GI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_OMAT_GI  USING    P_LINE LIKE GS_TRANS.

  DATA: LS_HEADER    TYPE BAPI2017_GM_HEAD_01,
        LT_ITEM      TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LV_CODE      TYPE BAPI2017_GM_CODE VALUE '03',
        LV_DOCUMENT  TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_YEAR      TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LS_GMHEADRET LIKE BAPI2017_GM_HEAD_RET,
        LT_RETURN    TYPE TABLE OF BAPIRET2.

  DATA: LV_SOBKZ TYPE SOBKZ.

  CLEAR: LS_HEADER, LT_ITEM.

  LS_HEADER = VALUE #( PSTNG_DATE = SY-DATUM
                       HEADER_TXT = GC_ZGTPPR9010 ).

  LOOP AT GT_TRANS_I INTO DATA(LS_TRANS_I) WHERE AUFNR EQ P_LINE-AUFNR.
    CLEAR: LV_SOBKZ.
    IF LS_TRANS_I-O_VBELN IS NOT INITIAL.
      LV_SOBKZ = GC_E.
    ENDIF.

    APPEND VALUE #( MATERIAL       = LS_TRANS_I-O_MATNR
                    PLANT          = LS_TRANS_I-WERKS
                    STGE_LOC       = LS_TRANS_I-LGORT
                    BATCH          = LS_TRANS_I-O_CHARG
                    VAL_SALES_ORD  = LS_TRANS_I-O_VBELN
                    VAL_S_ORD_ITEM = LS_TRANS_I-O_POSNR
                    MOVE_TYPE      = GC_261
                    SPEC_STOCK     = LV_SOBKZ
                    STCK_TYPE      = GC_F
                    ENTRY_UOM      = LS_TRANS_I-O_MEINS
                    ENTRY_QNT      = LS_TRANS_I-O_KALAB
                    ORDERID        = LS_TRANS_I-AUFNR )
           TO LT_ITEM.

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
      P_LINE-RTMSG = TEXT-M19. "기존 자재 투입 처리 도중 오류가 발생하였습니다.
    ELSE.
      P_LINE-RTMSG = LS_RETURN-MESSAGE.
    ENDIF.
    P_LINE-STAT_OMATGI = ICON_LED_RED.

    CLEAR: LS_RETURN.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = GC_X.

    P_LINE-STAT_OMATGI = ICON_LED_GREEN.
    P_LINE-RTMSG = TEXT-M18. "기존 자재 투입 처리에 성공하였습니다.
    P_LINE-MBLNR_GI = LV_DOCUMENT.
    P_LINE-MJAHR_GI = LV_YEAR.

    WAIT UP TO '0.5' SECONDS.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_NMATGR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_NMATGR .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  DATA: LT_SEL LIKE TABLE OF GS_TRANS.

  FIELD-SYMBOLS: <FS_S> LIKE GS_TRANS.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M20. "신규 자재 입고 처리를 수행할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T15 "신규 재고 입고 처리
      TEXT_QUESTION         = TEXT-T16 "신규 재고 입고 처리를 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: LT_SEL.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_TRANS ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-STAT_NMATGR EQ ICON_LED_GREEN.
        <FS_S>-RTMSG = TEXT-M21. "이미 신규 재고 입고가 처리된 레코드입니다.
      ELSE.
        IF <FS_S>-STAT_OMATGI NE ICON_LED_GREEN.
          <FS_S>-RTMSG = TEXT-M22. "기존 재고 투입 처리 이후 진행하십시요.
        ELSE.
*-선택한 데이터
          APPEND <FS_S> TO LT_SEL.
        ENDIF.
      ENDIF.
    ENDLOOP.

*-선택한 데이터를 변환 생산오더 기준으로 중복 제거
    SORT LT_SEL BY AUFNR.
    DELETE ADJACENT DUPLICATES FROM LT_SEL
                          COMPARING AUFNR.

*-선택한 데이터를 변환 생산오더 기준으로 1번만 입고
    LOOP AT LT_SEL ASSIGNING FIELD-SYMBOL(<FS_SEL>).
      PERFORM EXEC_NMAT_GR USING <FS_SEL>.
    ENDLOOP.

*-처리 결과 ALV 적용
    IF P_FERT EQ GC_X.
      LOOP AT GT_TRANS ASSIGNING <FS_S> WHERE STAT_TRANSORD EQ ICON_LED_GREEN
                                          AND STAT_OMATGI   EQ ICON_LED_GREEN
                                          AND STAT_NMATGR   NE ICON_LED_GREEN.
        READ TABLE LT_SEL INTO DATA(LS_SEL) WITH KEY AUFNR = <FS_S>-AUFNR.
        IF SY-SUBRC EQ 0 AND LS_SEL IS NOT INITIAL.
          <FS_S>-STAT_NMATGR = LS_SEL-STAT_NMATGR.
          <FS_S>-RTMSG       = LS_SEL-RTMSG.
          <FS_S>-MBLNR_GR    = LS_SEL-MBLNR_GR.
          <FS_S>-MJAHR_GR    = LS_SEL-MJAHR_GR.

          IF LS_SEL-STAT_NMATGR EQ ICON_LED_GREEN.
            UPDATE ZGTPPT9020 SET MBLNR_GR = LS_SEL-MBLNR_GR
                                  MJAHR_GR = LS_SEL-MJAHR_GR
                                  CHDAT    = SY-DATUM
                                  CHTIM    = SY-UZEIT
                                  CHNAM    = SY-UNAME
                            WHERE ZSTOCK_NO = <FS_S>-ZSTOCK_NO
                              AND ZSTOCK_SEQ = <FS_S>-ZSTOCK_SEQ.

            COMMIT WORK.

          ENDIF.
        ENDIF.
        CLEAR: LS_SEL.
      ENDLOOP.

    ELSEIF P_HALB EQ GC_X.
      LOOP AT GT_TRANS ASSIGNING <FS_S> WHERE STAT_TRANSORD EQ ICON_LED_GREEN
                                          AND STAT_OMATGI   EQ ICON_LED_GREEN
                                          AND STAT_NMATGR   NE ICON_LED_GREEN.
        READ TABLE LT_SEL INTO LS_SEL WITH KEY AUFNR = <FS_S>-AUFNR.
        IF SY-SUBRC EQ 0 AND LS_SEL IS NOT INITIAL.
          <FS_S>-STAT_NMATGR = LS_SEL-STAT_NMATGR.
          <FS_S>-RTMSG       = LS_SEL-RTMSG.
          <FS_S>-MBLNR_GR    = LS_SEL-MBLNR_GR.
          <FS_S>-MJAHR_GR    = LS_SEL-MJAHR_GR.

          IF LS_SEL-STAT_NMATGR EQ ICON_LED_GREEN.
            UPDATE ZGTPPT9020 SET MBLNR_GR = LS_SEL-MBLNR_GR
                                  MJAHR_GR = LS_SEL-MJAHR_GR
                                  CHDAT    = SY-DATUM
                                  CHTIM    = SY-UZEIT
                                  CHNAM    = SY-UNAME
                            WHERE ZSTOCK_NO = <FS_S>-ZSTOCK_NO
                              AND ZSTOCK_SEQ = <FS_S>-ZSTOCK_SEQ.

            COMMIT WORK.

          ENDIF.
        ENDIF.
        CLEAR: LS_SEL.
      ENDLOOP.

    ENDIF.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_NMAT_GR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_NMAT_GR  USING    P_LINE LIKE GS_TRANS.

  DATA: LS_HEADER    TYPE BAPI2017_GM_HEAD_01,
        LT_ITEM      TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LV_CODE      TYPE BAPI2017_GM_CODE VALUE '02',
        LV_DOCUMENT  TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_YEAR      TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LS_GMHEADRET LIKE BAPI2017_GM_HEAD_RET,
        LT_RETURN    TYPE TABLE OF BAPIRET2.

  CLEAR: LS_HEADER, LT_ITEM.

  LS_HEADER = VALUE #( PSTNG_DATE = SY-DATUM
                       HEADER_TXT = GC_ZGTPPR9010 ).

  LT_ITEM = VALUE #( ( MATERIAL       = P_LINE-N_MATNR
                       PLANT          = P_LINE-WERKS
                       STGE_LOC       = P_LINE-LGORT
                       BATCH          = P_LINE-N_CHARG
                       MOVE_TYPE      = GC_101
                       STCK_TYPE      = SPACE
                       ENTRY_UOM      = P_LINE-N_MEINS
                       ENTRY_QNT      = P_LINE-N_KALAB
                       ORDERID        = P_LINE-AUFNR
                       MVT_IND        = GC_F ) ).

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
      P_LINE-RTMSG = TEXT-M24. "신규 재고 입고 처리 도중 오류가 발생하였습니다.
    ELSE.
      P_LINE-RTMSG = LS_RETURN-MESSAGE.
    ENDIF.
    P_LINE-STAT_NMATGR = ICON_LED_RED.

    CLEAR: LS_RETURN.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = GC_X.

    P_LINE-STAT_NMATGR = ICON_LED_GREEN.
    P_LINE-RTMSG = TEXT-M23. "신규 재고 입고 처리에 성공하였습니다.
    P_LINE-MBLNR_GR = LV_DOCUMENT.
    P_LINE-MJAHR_GR = LV_YEAR.

    WAIT UP TO '0.5' SECONDS.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_NMATGRCAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_NMATGRCAN .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  DATA: LT_SEL LIKE TABLE OF GS_TRANS_C.

  FIELD-SYMBOLS: <FS_S> LIKE GS_TRANS_C.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M25. "신규 자재 입고 취소 처리를 수행할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T17 "신규 재고 입고 취소
      TEXT_QUESTION         = TEXT-T18 "신규 재고 입고 취소를 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: LT_SEL.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_TRANS_C ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-MBLNR_GR IS INITIAL.
        <FS_S>-RTMSG = TEXT-M26. "취소할 데이터가 없습니다.
      ELSE.
*-선택한 데이터
        APPEND <FS_S> TO LT_SEL.
      ENDIF.
    ENDLOOP.

*-선택한 데이터를 입고 자재문서 기준으로 중복 제거
    SORT LT_SEL BY MBLNR_GR.
    DELETE ADJACENT DUPLICATES FROM LT_SEL
                          COMPARING MBLNR_GR.

*-선택한 데이터를 입고 자재문서 기준으로 신규 입고 취소
    LOOP AT LT_SEL ASSIGNING FIELD-SYMBOL(<FS_SEL>).
      PERFORM EXEC_NMAT_GR_CAN USING <FS_SEL>.
    ENDLOOP.

*-처리 결과 ALV 적용
    LOOP AT GT_TRANS_C ASSIGNING <FS_S>.
      READ TABLE LT_SEL INTO DATA(LS_SEL) WITH KEY MBLNR_GR = <FS_S>-MBLNR_GR.
      IF SY-SUBRC EQ 0 AND LS_SEL IS NOT INITIAL.
        <FS_S>-RTMSG = LS_SEL-RTMSG.
        IF LS_SEL-RTMSG = TEXT-M27.
          UPDATE ZGTPPT9020 SET MBLNR_GR = SPACE
                                MJAHR_GR = SPACE
                                CHDAT    = SY-DATUM
                                CHTIM    = SY-UZEIT
                                CHNAM    = SY-UNAME
                          WHERE ZSTOCK_NO = <FS_S>-ZSTOCK_NO
                            AND ZSTOCK_SEQ = <FS_S>-ZSTOCK_SEQ.

          COMMIT WORK.

          CLEAR: <FS_S>-MBLNR_GR, <FS_S>-MJAHR_GR.
        ENDIF.
      ENDIF.
      CLEAR: LS_SEL.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_NMAT_GR_CAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_NMAT_GR_CAN  USING    P_LINE LIKE GS_TRANS_C.
  DATA: LT_RETURN     TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
        LS_RETURNS    TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
        LS_GOODSMVT   TYPE BAPI2017_GM_HEAD_RET,
        LV_HEADER_TXT TYPE BAPI2017_GM_HEAD_02-HEADER_TXT.

  CLEAR: LT_RETURN, LS_RETURNS, LS_GOODSMVT.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = P_LINE-MBLNR_GR
      MATDOCUMENTYEAR     = P_LINE-MJAHR_GR
      DOCUMENTHEADER_TEXT = GC_ZGTPPR9010
    IMPORTING
      GOODSMVT_HEADRET    = LS_GOODSMVT
    TABLES
      RETURN              = LT_RETURN.

  IF LS_GOODSMVT-MAT_DOC IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = GC_X.

    P_LINE-RTMSG = TEXT-M27. "신규 재고 입고 취소 처리에 성공하였습니다.

    WAIT UP TO '0.5' SECONDS.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CLEAR: LT_RETURN.
    READ TABLE LT_RETURN WITH KEY TYPE = GC_E.
    IF LT_RETURN-MESSAGE IS INITIAL.
      P_LINE-RTMSG = TEXT-M28. "신규 재고 입고 취소 처리 도중 오류가 발생하였습니다.
    ELSE.
      P_LINE-RTMSG = LT_RETURN-MESSAGE.
    ENDIF.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_OMATGICAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_OMATGICAN .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  DATA: LT_SEL LIKE TABLE OF GS_TRANS_C.

  FIELD-SYMBOLS: <FS_S> LIKE GS_TRANS_C.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M29. "기존 자재 투입 취소 처리를 수행할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T19 "기존 재고 투입 취소
      TEXT_QUESTION         = TEXT-T20 "기존 재고 투입 취소를 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: LT_SEL.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_TRANS_C ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-MBLNR_GI IS INITIAL.
        <FS_S>-RTMSG = TEXT-M26. "취소할 데이터가 없습니다.
      ELSE.
        IF <FS_S>-MBLNR_GR IS NOT INITIAL.
          <FS_S>-RTMSG = TEXT-M30. "신규 자재 입고 취소 처리 이후 진행하십시요.
        ELSE.
*-선택한 데이터
          APPEND <FS_S> TO LT_SEL.
        ENDIF.
      ENDIF.
    ENDLOOP.

*-선택한 데이터를 투입 자재문서 기준으로 중복 제거
    SORT LT_SEL BY MBLNR_GI.
    DELETE ADJACENT DUPLICATES FROM LT_SEL
                          COMPARING MBLNR_GI.

*-선택한 데이터를 투입 자재문서 기준으로 신규 입고 취소
    LOOP AT LT_SEL ASSIGNING FIELD-SYMBOL(<FS_SEL>).
      PERFORM EXEC_OMAT_GI_CAN USING <FS_SEL>.
    ENDLOOP.

*-처리 결과 ALV 적용
    LOOP AT GT_TRANS_C ASSIGNING <FS_S>.
      READ TABLE LT_SEL INTO DATA(LS_SEL) WITH KEY MBLNR_GI = <FS_S>-MBLNR_GI.
      IF SY-SUBRC EQ 0 AND LS_SEL IS NOT INITIAL.
        <FS_S>-RTMSG = LS_SEL-RTMSG.
        IF LS_SEL-RTMSG = TEXT-M31.
          UPDATE ZGTPPT9020 SET MBLNR_GI = SPACE
                                MJAHR_GI = SPACE
                                CHDAT    = SY-DATUM
                                CHTIM    = SY-UZEIT
                                CHNAM    = SY-UNAME
                          WHERE ZSTOCK_NO = <FS_S>-ZSTOCK_NO
                            AND ZSTOCK_SEQ = <FS_S>-ZSTOCK_SEQ.

          COMMIT WORK.

          CLEAR: <FS_S>-MBLNR_GI, <FS_S>-MJAHR_GI.
        ENDIF.
      ENDIF.
      CLEAR: LS_SEL.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_OMAT_GI_CAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_OMAT_GI_CAN  USING    P_LINE LIKE GS_TRANS_C.
  DATA: LT_RETURN     TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
        LS_RETURNS    TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
        LS_GOODSMVT   TYPE BAPI2017_GM_HEAD_RET,
        LV_HEADER_TXT TYPE BAPI2017_GM_HEAD_02-HEADER_TXT.

  CLEAR: LT_RETURN, LS_RETURNS, LS_GOODSMVT.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = P_LINE-MBLNR_GI
      MATDOCUMENTYEAR     = P_LINE-MJAHR_GI
      DOCUMENTHEADER_TEXT = GC_ZGTPPR9010
    IMPORTING
      GOODSMVT_HEADRET    = LS_GOODSMVT
    TABLES
      RETURN              = LT_RETURN.

  IF LS_GOODSMVT-MAT_DOC IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = GC_X.

    P_LINE-RTMSG = TEXT-M31. "기존 재고 투입 취소 처리에 성공하여습니다.

    WAIT UP TO '0.5' SECONDS.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CLEAR: LT_RETURN.
    READ TABLE LT_RETURN WITH KEY TYPE = GC_E.
    IF LT_RETURN-MESSAGE IS INITIAL.
      P_LINE-RTMSG = TEXT-M32. "기존 재고 투입 취소 처리 도중 오류가 발생하였습니다.
    ELSE.
      P_LINE-RTMSG = LT_RETURN-MESSAGE.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_TRAORDDEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_TRAORDDEL .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  DATA: LT_SEL LIKE TABLE OF GS_TRANS_C.

  FIELD-SYMBOLS: <FS_S> LIKE GS_TRANS_C.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M33. "변환 생산오더 삭제를 수행할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T21 "재고 변환 생산오더 삭제
      TEXT_QUESTION         = TEXT-T22 "재고 변환 생산오더 삭제 설정을 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: LT_SEL.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_TRANS_C ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-AUFNR IS INITIAL.
        <FS_S>-RTMSG = TEXT-M26. "취소할 데이터가 없습니다.
      ELSE.
        IF <FS_S>-MBLNR_GI IS NOT INITIAL.
          <FS_S>-RTMSG = TEXT-M34. "기존 자재 투입 취소 처리 이후 진행하십시요.
        ELSE.
*-선택한 데이터
          APPEND <FS_S> TO LT_SEL.
        ENDIF.
      ENDIF.
    ENDLOOP.

*-선택한 데이터를 변환 생산오더 기준으로 중복 제거
    SORT LT_SEL BY AUFNR.
    DELETE ADJACENT DUPLICATES FROM LT_SEL
                          COMPARING AUFNR.

*-선택된 데이터를 변환 생산오더 기준으로 삭제
    LOOP AT LT_SEL ASSIGNING FIELD-SYMBOL(<FS_SEL>).
      PERFORM EXEC_TRAORDER_DEL USING <FS_SEL>.
    ENDLOOP.

*-처리 결과 ALV 적용
    LOOP AT GT_TRANS_C ASSIGNING <FS_S>.
      READ TABLE LT_SEL INTO DATA(LS_SEL) WITH KEY AUFNR = <FS_S>-AUFNR.
      IF SY-SUBRC EQ 0 AND LS_SEL IS NOT INITIAL.
        <FS_S>-RTMSG = LS_SEL-RTMSG.
        IF LS_SEL-RTMSG = TEXT-M35.
          UPDATE ZGTPPT9020 SET AUFNR = SPACE
                                CHDAT = SY-DATUM
                                CHTIM = SY-UZEIT
                                CHNAM = SY-UNAME
                          WHERE ZSTOCK_NO = <FS_S>-ZSTOCK_NO
                            AND ZSTOCK_SEQ = <FS_S>-ZSTOCK_SEQ.

          COMMIT WORK.

          CLEAR: <FS_S>-AUFNR.
        ENDIF.
      ENDIF.
      CLEAR: LS_SEL.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_TRAORDER_DEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_TRAORDER_DEL  USING    P_LINE LIKE GS_TRANS_C.
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
        WAIT = GC_X.

    P_LINE-RTMSG = TEXT-M35. "생산오더 삭제 설정에 성공하였습니다.

    WAIT UP TO '0.5' SECONDS.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    IF LT_DETAIL_RETURN-MESSAGE IS INITIAL.
      P_LINE-RTMSG = TEXT-M36. "생산오더 삭제 설정 도중 오류가 발생하였습니다.
    ELSE.
      P_LINE-RTMSG = LT_DETAIL_RETURN-MESSAGE.
    ENDIF.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_STKCONFCAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_STKCONFCAN .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_TRANS_C.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M37. "재고 확정 취소를 수행할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T23 "재고 확정 취소
      TEXT_QUESTION         = TEXT-T24 "재고 확정 취소를 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    SELECT SINGLE AUFNR
      FROM ZGTPPT9020
     WHERE WERKS EQ @P_WERKS
      INTO @DATA(LV_AUFNR).

    IF LV_AUFNR IS NOT INITIAL.
      MESSAGE S003 DISPLAY LIKE GC_W
         WITH TEXT-M38. "재고 변환 생산오더 삭제 설정 이후 진행하십시요.
      EXIT.
    ELSE.
      DELETE FROM ZGTPPT9020 WHERE WERKS = P_WERKS.
      DELETE FROM ZGTPPT9010 WHERE WERKS = P_WERKS.

      IF SY-SUBRC EQ 0.
        COMMIT WORK.
        MESSAGE S003 DISPLAY LIKE GC_S
           WITH TEXT-M39. "재고 확정 취소 처리에 성공하였습니다.
      ELSE.
        ROLLBACK WORK.
        MESSAGE S003 DISPLAY LIKE GC_E
           WITH TEXT-M40. "재고 확정 취소 처리 도중 오류가 발생하였습니다.
      ENDIF.

    ENDIF.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONV_EXIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS>_OMATNR
*&      --> LVO_MATNRC
*&      --> GC_O
*&---------------------------------------------------------------------*
FORM CONV_EXIT  USING    P_INPUT
                         P_OUTPUT
                         P_GBN.

  IF P_GBN EQ GC_I.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT        = P_INPUT
      IMPORTING
        OUTPUT       = P_OUTPUT
      EXCEPTIONS
        LENGTH_ERROR = 1
        OTHERS       = 2.
  ELSEIF P_GBN EQ GC_O.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = P_INPUT
      IMPORTING
        OUTPUT = P_OUTPUT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0100 .
  REFRESH GT_SORT_0100.

  IF P_R2 EQ GC_X.
    IF P_FERT EQ GC_X.
      PERFORM SET_SORT_TAB TABLES GT_SORT_0100
                            USING : 1 'N_VBELN'      'X' '' '',
                                    2 'N_POSNR'      'X' '' ''.
    ELSEIF P_HALB EQ GC_X.
      PERFORM SET_SORT_TAB TABLES GT_SORT_0100
                            USING : 1 'N_MATNR'      'X' '' '',
                                    2 'N_MAKTX'      'X' '' '',
                                    3 'N_VBELN'      'X' '' '',
                                    4 'N_POSNR'      'X' '' ''.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_TAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SORT_0100
*&      --> P_1
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_SORT_TAB  TABLES   PT_SORTTAB STRUCTURE LVC_S_SORT
                   USING    PV_POS
                            PV_FIELDNAME
                            PV_UP
                            PV_DOWN
                            PV_SUBTOT.

  DATA : LS_SORT TYPE LVC_S_SORT.
  LS_SORT-SPOS = PV_POS.
  LS_SORT-FIELDNAME = PV_FIELDNAME.
  LS_SORT-UP = PV_UP.
  LS_SORT-DOWN = PV_DOWN.
  LS_SORT-SUBTOT =  PV_SUBTOT.
  APPEND LS_SORT TO PT_SORTTAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STY_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_S>
*&---------------------------------------------------------------------*
FORM SET_STY_RTN  CHANGING P_LINE LIKE GS_TRANS.

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

  SET_STY 'ZSTOCK_TYPE'     'X'.
  SET_STY 'ZSTOCK_NAME'     'X'.
  SET_STY 'WERKS'           'X'.
  SET_STY 'NAME1'           'X'.
  SET_STY 'LGORT'           'X'.
  SET_STY 'LGOBE'           'X'.
  SET_STY 'SOBKZ'           'X'.
  SET_STY 'ZSTOCK_NO'       'X'.
  SET_STY 'ZSTOCK_SEQ'      'X'.
  SET_STY 'STAT_TRANSORD'   'X'.
  SET_STY 'AUFNR'           'X'.
  SET_STY 'STAT_OMATGI'     'X'.
  SET_STY 'STAT_BATCHCRE'   'X'.
  SET_STY 'STAT_NMATGR'     'X'.
  SET_STY 'RTMSG'           'X'.
  SET_STY 'N_MATNR'         SPACE.
  SET_STY 'N_MAKTX'         'X'.
  SET_STY 'N_VBELN'         'X'.
  SET_STY 'N_POSNR'         'X'.
  SET_STY 'N_JOB_NO'        SPACE.
  SET_STY 'N_CHARG'         SPACE.
  SET_STY 'N_LWEDT'         'X'.
  SET_STY 'N_KALAB'         SPACE.
  SET_STY 'N_MEINS'         'X'.
  SET_STY 'N_MTART'         'X'.
  SET_STY 'N_MATKL'         'X'.
  SET_STY 'N_KWMENG'        'X'.
  SET_STY 'N_LENGTH'        'X'.
  SET_STY 'N_SERIAL_CNT'    'X'.
  SET_STY 'O_MATNR'         'X'.
  SET_STY 'O_MAKTX'         'X'.
  SET_STY 'O_VBELN'         'X'.
  SET_STY 'O_POSNR'         'X'.
  SET_STY 'O_JOB_NO'        'X'.
  SET_STY 'O_CHARG'         'X'.
  SET_STY 'O_LWEDT'         'X'.
  SET_STY 'O_KALAB'         'X'.
  SET_STY 'O_MEINS'         'X'.
  SET_STY 'O_MTART'         'X'.
  SET_STY 'O_MATKL'         'X'.
  SET_STY 'O_KWMENG'        'X'.
  SET_STY 'O_VRKME'         'X'.
  SET_STY 'O_STD_PROD_NM'   'X'.
  SET_STY 'O_STD_PROD_DSCR' 'X'.
  SET_STY 'O_PROD_NM'       'X'.
  SET_STY 'O_PROD_DSCR'     'X'.
  SET_STY 'O_PROD_MNG'      'X'.
  SET_STY 'CRDAT'           'X'.
  SET_STY 'CRTIM'           'X'.
  SET_STY 'CRNAM'           'X'.
  SET_STY 'MKEY'            'X'.
  SET_STY 'ZPJNO'           'X'.
  SET_STY 'N_MTBEZ'         'X'.
  SET_STY 'N_WGBEZ'         'X'.
  SET_STY 'O_MTBEZ'         'X'.
  SET_STY 'O_WGBEZ'         'X'.
  SET_STY 'MBLNR_GI'        'X'.
  SET_STY 'MJAHR_GI'        'X'.
  SET_STY 'MBLNR_GR'        'X'.
  SET_STY 'MJAHR_GR'        'X'.

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
      SET HANDLER: GO_EVTR_0100->HDL_DOUBLE_CLICK FOR GO_GRID_0100.
  ENDCASE.

* DATA CHANGE
  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_N_MAKTX_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LVC_S_MODI
*&      <-- ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM SET_N_MAKTX_RTN  USING    P_LVC_S_MODI   TYPE LVC_S_MODI
                      CHANGING P_DATA_CHANGED
                               TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA: L_MATNR TYPE MATNR,
        L_MAKTX TYPE MAKTX.

  DATA: L_VALUE TYPE LVC_S_MODI-VALUE.

  FIELD-SYMBOLS: <FS_S> LIKE GS_TRANS.

  READ TABLE GT_TRANS ASSIGNING <FS_S> INDEX P_LVC_S_MODI-ROW_ID.

  L_VALUE = P_LVC_S_MODI-VALUE.

  TRANSLATE L_VALUE TO UPPER CASE.

  CLEAR: L_MATNR.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT        = L_VALUE
    IMPORTING
      OUTPUT       = L_MATNR
    EXCEPTIONS
      LENGTH_ERROR = 1
      OTHERS       = 2.

  CLEAR: L_MAKTX.
  SELECT SINGLE MATNR, MAKTX
    FROM MAKT
   WHERE MATNR EQ @L_MATNR
     AND SPRAS EQ @SY-LANGU
    INTO (@DATA(L_MATNR1), @L_MAKTX).

  IF L_MATNR1 IS INITIAL AND L_MAKTX IS INITIAL.
    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'N_MATNR'
        I_VALUE     = <FS_S>-N_MATNR.

    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'N_MAKTX'
        I_VALUE     = <FS_S>-N_MAKTX.

  ELSE.
    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'N_MAKTX'
        I_VALUE     = L_MAKTX.
  ENDIF.

ENDFORM.
