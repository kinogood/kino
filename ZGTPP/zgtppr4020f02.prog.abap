*----------------------------------------------------------------------*
***INCLUDE ZGTPPR4020F02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_ALV .
  PERFORM INIT_CONTAINER.
  PERFORM INIT_ALV_GRID.
ENDFORM.                    " DISPLAY_ALV
*&---------------------------------------------------------------------*
*&      Form  INIT_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INIT_CONTAINER .
  IF G_CONTAINER IS INITIAL.

    CREATE OBJECT G_CONTAINER
      EXPORTING
        CONTAINER_NAME = MYCON
        REPID          = SY-REPID
        DYNNR          = SY-DYNNR.

  ENDIF.
ENDFORM.                    " INIT_CONTAINER
*&---------------------------------------------------------------------*
*&      Form  INIT_ALV_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INIT_ALV_GRID .
  IF G_GRID IS INITIAL.


    CREATE OBJECT G_GRID
      EXPORTING
        I_APPL_EVENTS = 'X'
        I_PARENT      = G_CONTAINER.

    CREATE OBJECT G_EVENT.

    GS_VARI-REPORT = 'ZGTPPR4020_100'.
**   TOOL BAR
*    PERFORM EXLUDE_TOOL_BAR_200T USING 'GT_EXCLUDE'.

*   FIELD CATALOG
    PERFORM BUILD_FIELD_CATALOG CHANGING GT_FIELDCAT.

*   Display시 다양한 옵션을 지정
    PERFORM MAKE_LAYOUT CHANGING GS_LAYOUT.

*   SORT
*    PERFORM BUILD_SORT_200T  CHANGING GT_SORT_200T.

*   DISPLAY
    CALL METHOD G_GRID->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
*       I_BUFFER_ACTIVE               =
*       I_BYPASSING_BUFFER            =
*       I_CONSISTENCY_CHECK           =
*       I_STRUCTURE_NAME              = ' '
        IS_VARIANT                    = GS_VARI
        I_SAVE                        = 'A'
*       I_DEFAULT                     = 'X'
        IS_LAYOUT                     = GS_LAYOUT
*       IS_PRINT                      = GS_PRINT
*       IT_SPECIAL_GROUPS             =
*       IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE[]
*       IT_HYPERLINK                  =
*       IT_ALV_GRAPHICS               =
*       IT_EXCEPT_QINFO               =
*       IR_SALV_ADAPTER               =
      CHANGING
        IT_OUTTAB                     = IT_LIST[]
        IT_FIELDCATALOG               = GT_FIELDCAT[]
        IT_SORT                       = GT_SORT[]
*       IT_FILTER                     =
      EXCEPTIONS
        INVALID_PARAMETER_COMBINATION = 1
        PROGRAM_ERROR                 = 2
        TOO_MANY_LINES                = 3
        OTHERS                        = 4.

    SET HANDLER G_EVENT->HANDLE_HOTSPOT_CLICK FOR G_GRID.
  ELSE.
    GS_STABLE-COL = 'X'.
    GS_STABLE-ROW = 'X'.

    CALL METHOD G_GRID->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE      = GS_STABLE
        I_SOFT_REFRESH = 'X'.

  ENDIF.
ENDFORM.                    " INIT_ALV_GRID
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM BUILD_FIELD_CATALOG  CHANGING PT_FIELDCAT TYPE LVC_T_FCAT.

  DATA: LS_FCAT TYPE LVC_S_FCAT.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
*     I_BUFFER_ACTIVE        =
      I_STRUCTURE_NAME       = 'ZGTBDS310'
*     I_CLIENT_NEVER_DISPLAY = 'X'
*     I_BYPASSING_BUFFER     =
*     I_INTERNAL_TABNAME     =
    CHANGING
      CT_FIELDCAT            = PT_FIELDCAT[]
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  LOOP AT PT_FIELDCAT INTO LS_FCAT.
    CASE LS_FCAT-FIELDNAME.
      WHEN 'ZSIGN'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-OUTPUTLEN = '3'.
        LS_FCAT-COLTEXT  = 'S'.
        LS_FCAT-COL_POS  = '1'.
      WHEN 'WERKS'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-OUTPUTLEN = '4'.
        LS_FCAT-COL_POS  = '2'.
      WHEN 'LGORT'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-OUTPUTLEN = '4'.
        LS_FCAT-COL_POS  = '3'.
      WHEN 'MATNR'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-OUTPUTLEN = '10'.
        LS_FCAT-COL_POS  = '4'.
      WHEN 'MAKTX'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-OUTPUTLEN = '20'.
        LS_FCAT-COL_POS = '5'.
      WHEN 'ZMTOS'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-COLTEXT  = TEXT-F01. "재고유형
        LS_FCAT-OUTPUTLEN = '5'.
        LS_FCAT-COL_POS  = '6'.
      WHEN 'ZEBUN'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-OUTPUTLEN = '12'.
        LS_FCAT-COL_POS  = '7'.
      WHEN 'ZSILMG'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-COLTEXT = TEXT-F07. "실사수량
        LS_FCAT-OUTPUTLEN = '13'.
        LS_FCAT-COL_POS = '8'.
      WHEN 'ZERPMG'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-COLTEXT = TEXT-F08. "전산수량
        LS_FCAT-OUTPUTLEN = '13'.
        LS_FCAT-COL_POS = '9'.
      WHEN 'ERFMG'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-OUTPUTLEN = '13'.
        LS_FCAT-COL_POS  = '10'.
      WHEN 'ERFME'.
        LS_FCAT-OUTPUTLEN = '3'.
        LS_FCAT-COL_POS  = '11'.
      WHEN 'KDAUF'.
        LS_FCAT-NO_OUT  = 'X'.
        LS_FCAT-COL_POS  = '12'.
      WHEN 'KDPOS'.
        LS_FCAT-NO_OUT  = 'X'.
        LS_FCAT-COL_POS  = '13'.
      WHEN 'BWART'.
        LS_FCAT-NO_OUT  = 'X'.
        LS_FCAT-COL_POS  = '14'.
      WHEN 'MBLNR'.
        LS_FCAT-HOTSPOT = 'X'.
        LS_FCAT-NO_OUT  = 'X'.
        LS_FCAT-COLTEXT = TEXT-F02. "실사차이
        LS_FCAT-COL_POS  = '15'.
      WHEN 'MBLNR2'.
        LS_FCAT-HOTSPOT = 'X'.
        LS_FCAT-NO_OUT  = 'X'.
        LS_FCAT-COLTEXT = TEXT-F03. "MTO전환
        LS_FCAT-COL_POS  = '16'.
      WHEN 'MBLNRC1'.
        LS_FCAT-HOTSPOT = 'X'.
        LS_FCAT-NO_OUT  = 'X'.
        LS_FCAT-COLTEXT = TEXT-F04. "취소(실사차이)
        LS_FCAT-COL_POS  = '17'.
      WHEN 'MBLNRC2'.
        LS_FCAT-HOTSPOT = 'X'.
        LS_FCAT-NO_OUT  = 'X'.
        LS_FCAT-COLTEXT = TEXT-F05. "취소(MTO전환)
        LS_FCAT-COL_POS  = '18'.
      WHEN 'ZMESSAGE'.
        LS_FCAT-COLTEXT = TEXT-F06. "에러 메세지
        LS_FCAT-OUTPUTLEN = '100'.
        LS_FCAT-COL_POS  = '19'.
      WHEN OTHERS.
        LS_FCAT-NO_OUT  = 'X'.
    ENDCASE.

    MODIFY PT_FIELDCAT FROM LS_FCAT.
  ENDLOOP.
ENDFORM.                    " BUILD_FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  MAKE_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GS_LAYOUT  text
*----------------------------------------------------------------------*
FORM MAKE_LAYOUT  CHANGING PS_LAYOUT TYPE LVC_S_LAYO.

  PS_LAYOUT-ZEBRA      = 'X'.
*  PS_LAYOUT-CWIDTH_OPT = 'X'.
*  PS_LAYOUT-BOX_FNAME  = 'ZBOX'.
  PS_LAYOUT-SEL_MODE   = 'D'.

ENDFORM.                    " MAKE_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  PHYSICAL_INVENTORY_POST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PHYSICAL_INVENTORY_POST .
  DATA: LV_CHECK(1).
*-------LV_CHECK='A':MTO해당 재고 없음
*-------LV_CHECK='E':ERROR
  DATA: IT_TEMP TYPE ZGTBDS310 OCCURS 0 WITH HEADER LINE.
  DATA: LV_INDEX TYPE SY-TABIX.
  DATA: LS_ZPBT0030 LIKE ZPBT0030.
  DATA: LS_LINES(4) TYPE I,
        LS_COUNT(4) TYPE N.


  IT_TEMP[] = IT_LIST[].

  DESCRIBE TABLE IT_TEMP LINES LS_LINES.

  LOOP AT IT_TEMP.
    CLS: GT_BDCDATA, GT_MESSTAB.
    CLEAR: GS_CTU_PARAMS, LV_CHECK.

    LV_INDEX = SY-TABIX.
    LS_COUNT = LS_COUNT + 1.

*   진행상태
    PERFORM PROCESSING_STATUS USING LS_LINES LS_COUNT.

*   MTO/MTS 구분하여 처리
    CASE IT_TEMP-ZMTOS.
      WHEN 'MTO'.
*-------MTO의 경우 제번에 해당하는 판매오더 리스트 추출
*-------해당 MTO재고에 대하여 재고실사 차이 반영할 MTO재고 선정
        PERFORM BUILD_SO_LIST    USING IT_TEMP LV_CHECK.
        IF LV_CHECK NE 'E'.
          IF IT_TEMP-ZMTOS = 'MTO' AND
             IT_TEMP-SHKZG = 'H'.
            PERFORM PHYSICAL_INV_MTOH USING IT_TEMP LV_CHECK.
          ELSE.
            PERFORM PHYSICAL_INV_MTO USING IT_TEMP LV_CHECK.
          ENDIF.
        ENDIF.
      WHEN 'MTS'.
*-------MTS의 경우 해당 창고 재고에 실사차이 반영
        PERFORM BUILD_MTS_LIST   USING IT_TEMP LV_CHECK.
        IF LV_CHECK NE 'E'.
          PERFORM PHYSICAL_INV_MTS USING IT_TEMP LV_CHECK.
        ENDIF.
    ENDCASE.

    CASE LV_CHECK.
      WHEN 'S'.
        IT_TEMP-ZSIGN  = '@5B@'.
        IT_TEMP-ZRESLT = 'S'.
      WHEN 'E'.
        IT_TEMP-ZSIGN = '@5C@'.
        IT_TEMP-ZRESLT = 'E'.
    ENDCASE.

*   이동유형
    PERFORM GET_BWART USING IT_TEMP.

    MODIFY IT_TEMP INDEX LV_INDEX.

*---처리결과 저장

    CLEAR LS_ZPBT0030.
    MOVE-CORRESPONDING IT_TEMP TO LS_ZPBT0030.
    LS_ZPBT0030-BUDAT = P_ZLDAT.
    LS_ZPBT0030-BLDAT = P_BLDAT.
    LS_ZPBT0030-CPUDT = SY-DATUM.
    LS_ZPBT0030-CPUTM = SY-UZEIT.
    LS_ZPBT0030-USNAM = SY-UNAME.

    INSERT ZPBT0030 FROM LS_ZPBT0030.
    COMMIT WORK AND WAIT.

  ENDLOOP.

  CLS: IT_LIST.
  IT_LIST[] = IT_TEMP[].

  GV_STATUS = 'C'.

  PERFORM CHANGE_CATALOG.
ENDFORM.                    " PHYSICAL_INVENTORY_POST
*&---------------------------------------------------------------------*
*&      Form  CHECK_UPLOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_LIST  text
*      <--P_LV_CHECK  text
*----------------------------------------------------------------------*
FORM CHECK_UPLOAD_DATA.
  DATA: LV_INDEX TYPE SY-TABIX.
  DATA: LV_STOCK_QTY LIKE MATDOC-STOCK_QTY,
        LV_MENGE_QTY LIKE MATDOC-MENGE,
        LV_MENGE     LIKE MATDOC-MENGE,
        LV_ERFMG     LIKE IT_LIST-ERFMG.

  LOOP AT IT_LIST.
    LV_INDEX = SY-TABIX.

*---플랜트
    IF IT_LIST-WERKS IS INITIAL.
      IT_LIST-WERKS = P_WERKS.
    ENDIF.

*---STORAGE LOCATION
    IF IT_LIST-LGORT IS INITIAL.
      IT_LIST-ZSIGN = '@5C@'.
      IT_LIST-ZMESSAGE = TEXT-E14.  "저장위치를 입력하세요.
    ELSE.
      "250311 로직 주석
*      IF IT_LIST-LGORT = '2510' AND
*         IT_LIST-ZMTOS = 'MTS'.
*        IT_LIST-ZSIGN = '@5C@'.
*        IT_LIST-ZMESSAGE = TEXT-E15.  "MTS:2510 저장위치가 올바르지 않습니다.
*      ENDIF.
    ENDIF.

*---MTO/MTS
    CASE IT_LIST-ZMTOS.
      WHEN 'MTO'.
        IF IT_LIST-ZEBUN IS INITIAL.
          IT_LIST-ZSIGN = '@5C@'.
          IT_LIST-ZMESSAGE = TEXT-E12.  "MTO:제번이 필요합니다.
        ENDIF.
    ENDCASE.

*---수량
    IF IT_LIST-ERFMG = 0.
      IT_LIST-ZSIGN = '@5C@'.
      IT_LIST-ZMESSAGE = TEXT-E13.  "재고실사차이 수량 필요.
    ENDIF.

*--- 전산 수량 추출
    IF P_ZLDAT+0(6) EQ SY-DATUM+0(6).
      CASE IT_LIST-ZMTOS.
        WHEN 'MTO'.
          SELECT SUM( KALAB )
            FROM MSKA
           WHERE MATNR EQ @IT_LIST-MATNR
             AND WERKS EQ @IT_LIST-WERKS
             AND LGORT EQ @IT_LIST-LGORT
            INTO @IT_LIST-ZERPMG.

        WHEN 'MTS'.
          SELECT SINGLE LABST
            FROM MARD
           WHERE MATNR EQ @IT_LIST-MATNR
             AND WERKS EQ @IT_LIST-WERKS
             AND LGORT EQ @IT_LIST-LGORT
            INTO @IT_LIST-ZERPMG.

      ENDCASE.

    ELSE.
      CASE IT_LIST-ZMTOS.
        WHEN 'MTO'.
          SELECT SUM( KALAB )
            FROM MSKAH
           WHERE MATNR EQ @IT_LIST-MATNR
             AND WERKS EQ @IT_LIST-WERKS
             AND LGORT EQ @IT_LIST-LGORT
             AND LFGJA EQ @P_ZLDAT+0(4)
             AND LFMON EQ @P_ZLDAT+4(2)
            INTO @IT_LIST-ZERPMG.

        WHEN 'MTS'.
          SELECT SINGLE LABST
            FROM MARDH
           WHERE MATNR EQ @IT_LIST-MATNR
             AND WERKS EQ @IT_LIST-WERKS
             AND LGORT EQ @IT_LIST-LGORT
             AND LFGJA EQ @P_ZLDAT+0(4)
             AND LFMON EQ @P_ZLDAT+4(2)
            INTO @IT_LIST-ZERPMG.

      ENDCASE.
    ENDIF.

*--수량 조정
    IF P_R1 EQ 'X'.   "실사수량입력
*-엑셀업로드 값이 실사값으로 필드 값 CHANGE
      IT_LIST-ZSILMG = IT_LIST-ERFMG.
*-재고조정수량 = 실사값 - 전산값
      CLEAR: IT_LIST-ERFMG.
      IT_LIST-ERFMG = IT_LIST-ZSILMG - IT_LIST-ZERPMG.

*** 2025.07.02 SHKZG 기입 PYS S
      IF IT_LIST-ERFMG > 0.
        IT_LIST-SHKZG = 'S'.
      ELSEIF IT_LIST-ERFMG < 0.
        IT_LIST-SHKZG = 'H'.
      ENDIF.
*** 2025.07.02 SHKZG 기입 PYS E

*---수량
      IF IT_LIST-ERFMG = 0.
        IT_LIST-ZSIGN = '@5C@'.
        IT_LIST-ZMESSAGE = TEXT-E13.  "재고실사차이 수량 필요.
      ENDIF.

    ELSEIF P_R2 EQ 'X'.   "차이수량입력
*-엑셀업로드 값이 재고조정수량으로 기존과 동일
*-실사값 = 재고조정수량 + 전산값
      IT_LIST-ZSILMG = IT_LIST-ERFMG + IT_LIST-ZERPMG.
    ENDIF.

    IF SY-TCODE EQ 'ZGTPPR4022'.
*---조정 허용수량을 초과한 조정 수량 입력 시 오류
*-월 자재 투입 수량
      CLEAR: LV_STOCK_QTY.
      SELECT SUM( STOCK_QTY )
        FROM MATDOC
       WHERE WERKS EQ @IT_LIST-WERKS
         AND MATNR EQ @IT_LIST-MATNR
         AND BWART IN ('261', '262')
         AND AUFNR NE @SPACE
         AND BUDAT BETWEEN @GV_FDATE AND @GV_TDATE
        INTO @LV_STOCK_QTY.

      IF LV_STOCK_QTY LT 0.
        LV_STOCK_QTY = ABS( LV_STOCK_QTY ).
      ENDIF.

      CLEAR: LV_MENGE_QTY.
      LV_MENGE_QTY = LV_STOCK_QTY.

*-조정허용수량
      LV_MENGE = LV_MENGE_QTY * ( GV_LIMIT / 100 ).

      CLEAR: LV_ERFMG.
      LV_ERFMG = IT_LIST-ERFMG * ( -1 ).

      IF LV_ERFMG GT LV_MENGE.   "조정수량 > 조정 허용 수량
        IT_LIST-ZSIGN = '@5C@'.
        IT_LIST-ZMESSAGE = TEXT-E17 && LV_MENGE && TEXT-E18.
      ENDIF.
    ENDIF.

    MODIFY IT_LIST INDEX LV_INDEX.
  ENDLOOP.

  CLEAR IT_LIST.
  IT_LIST-ZSIGN = '@5B@'.
  MODIFY IT_LIST TRANSPORTING ZSIGN WHERE ZSIGN EQ SPACE.

  CLEAR IT_LIST.
  READ TABLE IT_LIST WITH KEY ZSIGN = '@5C@'.
  IF SY-SUBRC = 0.
    GV_STATUS = 'B'.
  ELSE.
    GV_STATUS = 'A'.
  ENDIF.
ENDFORM.                    " CHECK_UPLOAD_DATA
*&---------------------------------------------------------------------*
*&      Form  PHYSICAL_INV_MTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_TEMP  text
*----------------------------------------------------------------------*
FORM PHYSICAL_INV_MTS  USING    P_TEMP TYPE ZGTBDS310
                                P_CHECK.

* BUILD BDC
  PERFORM BDC_DYNPRO USING:'SAPMM07I'       '0700'.
  PERFORM BDC_FIELD  USING:'BDC_OKCODE'     '/00',
                           'RM07I-ZLDAT'   P_ZLDAT,
                           'RM07I-BLDAT'   P_BLDAT,
                           'IKPF-WERKS'    P_WERKS,
                           'IKPF-LGORT'    P_TEMP-LGORT.

  PERFORM BDC_DYNPRO USING:'SAPMM07I'       '0731'.
  PERFORM BDC_FIELD  USING:'BDC_OKCODE'     '=BU',
                           'ISEG-MATNR(01)' P_TEMP-MATNR.

  IF P_TEMP-ZERFMG <= 0.
    PERFORM BDC_FIELD  USING:'ISEG-XNULL(01)' 'X'.
  ELSE.
    PERFORM BDC_FIELD  USING:'ISEG-ERFMG(01)' P_TEMP-ZERFMG.
  ENDIF.


  PERFORM BDC_TRANSACTION USING 'MI10' BDC_MODE
                          CHANGING P_TEMP P_CHECK.
ENDFORM.                    " PHYSICAL_INV_MTS
*&---------------------------------------------------------------------*
*&      Form  BDC_TRANSACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0270   text
*      -->P_BDC_MODE  text
*      <--P_P_TEMP  text
*----------------------------------------------------------------------*
FORM BDC_TRANSACTION  USING    TCODE
                               MODE
                      CHANGING P_TEMP TYPE ZGTBDS310
                               P_CHECK.

  DATA: LV_TEXT LIKE CFGNL-MSGLIN.

  GS_CTU_PARAMS-DISMODE  = MODE.
  GS_CTU_PARAMS-UPDMODE  = 'S'.
  GS_CTU_PARAMS-CATTMODE = ' '.
  GS_CTU_PARAMS-DEFSIZE  = ' '. "Default Size(Recording과 같은화면으로처
  GS_CTU_PARAMS-RACOMMIT = ' '. "NOT EXIT AT COMMIT WORK
  GS_CTU_PARAMS-NOBINPT  = ' '. "Not as batch input session, that is, SY
  GS_CTU_PARAMS-NOBIEND  = ' '. "Not as batch input session after end of

  CALL TRANSACTION TCODE   USING GT_BDCDATA
                           OPTIONS FROM GS_CTU_PARAMS
                           MESSAGES INTO GT_MESSTAB.

  CLEAR GT_MESSTAB.
  READ TABLE GT_MESSTAB WITH KEY MSGTYP = 'S'
                                 MSGID  = 'M7'
                                 MSGNR  = '716'.
  IF SY-SUBRC = 0.

    P_TEMP-MBLNR = GT_MESSTAB-MSGV2.
    CLEAR MKPF.
    SELECT SINGLE MJAHR
      INTO P_TEMP-MJAHR
      FROM MKPF
     WHERE MBLNR = P_TEMP-MBLNR.

    IF P_CHECK = 'A'.
*-----MTS --> MTO
      PERFORM TRANSFER_POST_MTO USING P_TEMP P_CHECK.
    ELSE.
      P_CHECK = 'S'.
    ENDIF.
  ELSE.
    P_CHECK = 'E'.
    CLEAR GT_MESSTAB.
    READ TABLE GT_MESSTAB WITH KEY MSGTYP = 'E'.

    CONCATENATE GT_MESSTAB-MSGTYP GT_MESSTAB-MSGID GT_MESSTAB-MSGNR
                GT_MESSTAB-MSGV1 GT_MESSTAB-MSGV2
                GT_MESSTAB-MSGV3 GT_MESSTAB-MSGV4
           INTO P_TEMP-ZMESSAGE.

  ENDIF.
ENDFORM.                    " BDC_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  PHYSICAL_INV_MTO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_TEMP  text
*----------------------------------------------------------------------*
FORM PHYSICAL_INV_MTO  USING    P_TEMP TYPE ZGTBDS310
                                P_CHECK.

* BUILD BDC
  PERFORM BDC_DYNPRO USING:'SAPMM07I'    '0700'.
  PERFORM BDC_FIELD  USING:'BDC_OKCODE'  '/00',
                           'RM07I-ZLDAT'   P_ZLDAT,
                           'RM07I-BLDAT'   P_BLDAT,
                           'IKPF-WERKS'    P_WERKS,
                           'IKPF-LGORT'    P_TEMP-LGORT.
  IF P_CHECK = 'A'.
    PERFORM BDC_FIELD  USING:'IKPF-SOBKZ'    ' '.
  ELSE.
    PERFORM BDC_FIELD  USING:'IKPF-SOBKZ'    'E'.
  ENDIF.


  PERFORM BDC_DYNPRO USING:'SAPMM07I'       '0731'.
  PERFORM BDC_FIELD  USING:'BDC_OKCODE'     '=BU',
                           'ISEG-MATNR(01)' P_TEMP-MATNR.

  IF P_CHECK NE 'A'.
    PERFORM BDC_FIELD  USING:'ISEGK-KDAUF'    P_TEMP-KDAUF,
                             'ISEGK-KDPOS'    P_TEMP-KDPOS.
  ENDIF.

  IF P_TEMP-ZERFMG <= 0.
    PERFORM BDC_FIELD      USING 'ISEG-XNULL(01)' 'X'.
  ELSE.
    PERFORM BDC_FIELD      USING:'ISEG-ERFMG(01)' P_TEMP-ZERFMG.
  ENDIF.


*-MI10 실행
  PERFORM BDC_TRANSACTION USING    'MI10' BDC_MODE
                          CHANGING P_TEMP P_CHECK.
ENDFORM.                    " PHYSICAL_INV_MTO
*&---------------------------------------------------------------------*
*&      Form  REVERSE_POST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REVERSE_POST .
  DATA: LV_INDEX    TYPE SY-TABIX,
        LV_CHECK(1),
        LV_DOUBL(1).
  DATA: LS_LINES(4) TYPE I,
        LS_COUNT(4) TYPE I.
  DATA: PT_TEMP LIKE ZGTBDS310 OCCURS 0 WITH HEADER LINE.

  PT_TEMP[] = IT_LIST[].
  DELETE PT_TEMP WHERE MBLNR  EQ SPACE
                   AND MBLNR2 EQ SPACE.

  DESCRIBE TABLE PT_TEMP LINES LS_LINES.

  LOOP AT IT_LIST WHERE MBLNR  NE SPACE
                     OR MBLNR2 NE SPACE.
    CLEAR LV_CHECK.
    LV_INDEX = SY-TABIX.

*   진행상태
    PERFORM PROCESSING_STATUS USING LS_LINES LS_COUNT.

    CLEAR: IT_LIST-ZMESSAGE, LV_DOUBL.

*---실사차이 자재문서 취소
    IF NOT IT_LIST-MBLNR2 IS INITIAL.
      LV_DOUBL = 'X'.

*-----413자재문서 취소
      PERFORM CANCEL_413MAT_DOC USING IT_LIST LV_CHECK.
    ENDIF.

    IF LV_CHECK NE 'E'.
      IF IT_LIST-ZMTOS = 'MTO' AND
         IT_LIST-SHKZG = 'H'.
        PERFORM CANCEL_MTOH_PROCESS USING IT_LIST LV_CHECK.
      ELSE.
        PERFORM CANCEL_701MAT_DOC USING IT_LIST LV_CHECK LV_DOUBL.
      ENDIF.
    ENDIF.

    CASE LV_CHECK.
      WHEN 'E'.
        IT_LIST-ZSIGN = '@5C@'.
      WHEN 'S'.
        IT_LIST-ZSIGN = '@5B@'.
    ENDCASE.

    MODIFY IT_LIST INDEX LV_INDEX.

    IF LV_CHECK = 'S'.
      CLEAR ZPBT0030.
      UPDATE ZPBT0030 SET MBLNRC1 = IT_LIST-MBLNRC1
                          MBLNRC2 = IT_LIST-MBLNRC2
                          AEDAT   = SY-DATUM
                          USNAM   = SY-UNAME
                          ZCANC   = 'X'
                    WHERE REQ_NO  = IT_LIST-REQ_NO
                      AND SORT_NO = IT_LIST-SORT_NO
                      AND MBLNR   = IT_LIST-MBLNR
                      AND MJAHR   = IT_LIST-MJAHR.

      COMMIT WORK AND WAIT.
    ENDIF.
  ENDLOOP.

  GV_STATUS = 'B'.

  PERFORM CHANGE_CATALOG_CANCEL.
ENDFORM.                    " REVERSE_POST
*&---------------------------------------------------------------------*
*&      Form  BUILD_SO_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_TEMP  text
*----------------------------------------------------------------------*
FORM BUILD_SO_LIST  USING    PS_TEMP TYPE ZGTBDS310
                             P_CHECK.
  DATA: IT_LOG10 LIKE ZPPTLOG10 OCCURS 0 WITH HEADER LINE,
        IT_VBAP  LIKE VBAP      OCCURS 0 WITH HEADER LINE.
  DATA: GT_CHAR LIKE ZLES001 OCCURS 0 WITH HEADER LINE.

  CLS R_POSNR.

*-판매오더별 제번 리스트 로그 테이블 ZPPTLOG10에서
*-해당 제번의 판매오더번호 가져옴.
  SELECT *
    INTO TABLE IT_LOG10
    FROM ZPPTLOG10
   WHERE ZCHARC16 = PS_TEMP-ZEBUN.

  SORT IT_LOG10 BY VBELN ZCHARC16.
  DELETE ADJACENT DUPLICATES FROM IT_LOG10 COMPARING VBELN.

  IF NOT IT_LOG10[] IS INITIAL.
*   제번에 해당하는 판매오더의 리스트 추출
    READ TABLE IT_LOG10 INDEX 1.
    PS_TEMP-KDAUF = IT_LOG10-VBELN.

    SELECT *
      INTO TABLE IT_VBAP
      FROM VBAP
     WHERE VBELN = PS_TEMP-KDAUF.

    LOOP AT IT_VBAP.
      CLS GT_CHAR.
      PERFORM GET_CHARACTERISTICS(ZPBR0026) TABLES GT_CHAR
                                            USING IT_VBAP.

*-----해당 판매오더 품번의 특성값중
*-----PS_TEMP-ZEBUN 과 'PD_BD_JOB_NO'가 같은 데이터 가져옴
      CLEAR GT_CHAR.
      READ TABLE GT_CHAR WITH KEY ATNAM = 'PD_BD_JOB_NO'.

      CHECK SY-SUBRC = 0.
      CONDENSE GT_CHAR-ATWRT.
      IF PS_TEMP-ZEBUN = GT_CHAR-ATWRT.
        CLEAR R_POSNR.
        R_POSNR-SIGN   = 'I'.
        R_POSNR-OPTION = 'EQ'.
        R_POSNR-LOW    = IT_VBAP-POSNR.
        APPEND R_POSNR.
      ENDIF.
    ENDLOOP.

*---MTO 재고 리스트
    PERFORM FILTER_STOCK_LIST USING PS_TEMP P_CHECK.
  ELSE.

  ENDIF.
ENDFORM.                    " BUILD_SO_LIST
*&---------------------------------------------------------------------*
*&      Form  FILTER_STOCK_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PS_TEMP  text
*      -->P_P_CHCK  text
*----------------------------------------------------------------------*
FORM FILTER_STOCK_LIST  USING    PS_TEMP TYPE ZGTBDS310
                                 P_CHECK.
  DATA: IT_STOCK    LIKE MSKA OCCURS 0 WITH HEADER LINE,
        LV_QTY2     LIKE ZGTBDS310-ERFMG,
        LV_QTY3     LIKE MSKA-KALAB,
        LV_QTY4     LIKE ZGTBDS310-ERFMG,
        LV_FIRST(1),
        LV_NO(1).

*-판매오더/품번별 재고 리스트
  SELECT *
    INTO TABLE IT_STOCK
    FROM MSKA
   WHERE MATNR = PS_TEMP-MATNR
     AND WERKS = PS_TEMP-WERKS
     AND LGORT = PS_TEMP-LGORT
     AND SOBKZ = 'E'
     AND VBELN = PS_TEMP-KDAUF
     AND POSNR IN R_POSNR.
*     AND KALAB > 0.

  IF IT_STOCK[] IS INITIAL.
    CASE PS_TEMP-SHKZG.
      WHEN 'S'.
*-------MTO 장부재고가 없음
*-------701실사차이 전기가 안되므로 MTS로 실사차이 전기 후
*-------413/MB1B 이용 MTO전환
        P_CHECK = 'A'.
        SORT R_POSNR BY LOW ASCENDING.
        READ TABLE R_POSNR INDEX 1.
        PS_TEMP-KDPOS  = R_POSNR-LOW.

        CLEAR MARD.
        SELECT SINGLE *
          FROM MARD
         WHERE MATNR = PS_TEMP-MATNR
           AND WERKS = PS_TEMP-WERKS
           AND LGORT = PS_TEMP-LGORT.

        IF SY-SUBRC = 0.
*---------해당 창고에 MTS재고 체크하여
*---------재고있으면 장부재고 + 재고조정수량
*---------재고없으면 재고조정수량
          PS_TEMP-ZERFMG = MARD-LABST + ABS( PS_TEMP-ERFMG ).
        ELSE.
          P_CHECK = 'E'.
          PS_TEMP-ZMESSAGE = TEXT-E16.
        ENDIF.
      WHEN 'H'.
        P_CHECK = 'E'.
        PS_TEMP-ZMESSAGE = TEXT-E10.
    ENDCASE.
  ELSE.
*---장부재고보다 실사재고가 많은경우: 'S' 가장큰 장부재고에 더함
*---장부재고보다 실사재고가 적은경우: 'H' 가장작은 장부재고에서 뺌
    CASE PS_TEMP-SHKZG.
      WHEN 'S'.
        SORT IT_STOCK BY KALAB DESCENDING.
        CLEAR IT_STOCK.
        READ TABLE IT_STOCK INDEX 1.
        PS_TEMP-KDPOS  = IT_STOCK-POSNR.
        PS_TEMP-ZERFMG = IT_STOCK-KALAB + ABS( PS_TEMP-ERFMG ).
      WHEN 'H'.
        SORT IT_STOCK BY KALAB ASCENDING.
        CLEAR: IT_STOCK, LV_NO.
        CLS  : GT_LIST.
        LV_QTY2 = ABS( PS_TEMP-ERFMG ).
        LV_QTY4 = LV_QTY2.
        LOOP AT IT_STOCK.
          LV_QTY3 = LV_QTY3 + IT_STOCK-KALAB.

          IF LV_QTY4 > LV_QTY3.
            LV_QTY2        = LV_QTY2 - IT_STOCK-KALAB.
            GT_LIST-ZERFMG = 0.
            GT_LIST-KDAUF  = PS_TEMP-KDAUF.
            GT_LIST-KDPOS  = IT_STOCK-POSNR.
            APPEND GT_LIST.
          ELSEIF LV_QTY4 = LV_QTY3.
            LV_QTY2        = LV_QTY2 - IT_STOCK-KALAB.
            GT_LIST-ZERFMG = 0.
            GT_LIST-KDAUF  = PS_TEMP-KDAUF.
            GT_LIST-KDPOS  = IT_STOCK-POSNR.
            APPEND GT_LIST.
            EXIT.
          ELSEIF LV_QTY4 < LV_QTY3.
            LV_QTY2        = LV_QTY2 - IT_STOCK-KALAB.
            GT_LIST-ZERFMG = ABS( LV_QTY2 ).
            GT_LIST-KDAUF  = PS_TEMP-KDAUF.
            GT_LIST-KDPOS  = IT_STOCK-POSNR.
            APPEND GT_LIST.
            EXIT.
          ENDIF.
        ENDLOOP.

*-------실사차이를 반영할 재고가 없으면
        IF LV_QTY2 > 0.
          P_CHECK = 'E'.
          PS_TEMP-ZMESSAGE = TEXT-E10.
        ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.                    " FILTER_STOCK_LIST
*&---------------------------------------------------------------------*
*&      Form  TRANSFER_POST_MTO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TEMP  text
*      -->P_P_CHECK  text
*----------------------------------------------------------------------*
FORM TRANSFER_POST_MTO  USING    P_TEMP TYPE ZGTBDS310
                                 P_CHECK.
  DATA: LV_STRING LIKE CFGNL-MSGLIN.

  CLEAR: GM_HEADER, GM_CODE, GM_HEADRET, GM_MATDOC,
         GM_DOCYER.
  CLS  : GM_ITEM, GM_RETURN.

*-헤더
  GM_HEADER-PSTNG_DATE   = P_ZLDAT."전기일
  GM_HEADER-DOC_DATE     = P_BLDAT."증빙일

  GM_CODE-GM_CODE        = '04'.   "TRANSACTION(MB1B)

* 아이템
  GM_ITEM-MATERIAL       = P_TEMP-MATNR.
  GM_ITEM-MOVE_TYPE      = '413'.         "이동유형
  GM_ITEM-PLANT          = P_WERKS.
  GM_ITEM-STGE_LOC       = P_TEMP-LGORT.    "저장위치
  GM_ITEM-ENTRY_QNT      = P_TEMP-ZERFMG.   "입력단위수량
  GM_ITEM-MOVE_PLANT     = P_WERKS.
  GM_ITEM-MOVE_STLOC     = P_TEMP-LGORT.
  GM_ITEM-VAL_SALES_ORD  = P_TEMP-KDAUF.    "판매문서
  GM_ITEM-VAL_S_ORD_ITEM = P_TEMP-KDPOS.    "품목번호
  GM_ITEM-MVT_IND        = SPACE.                "이동지시자
  APPEND GM_ITEM.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = GM_HEADER
      GOODSMVT_CODE    = GM_CODE
    IMPORTING
      GOODSMVT_HEADRET = GM_HEADRET
      MATERIALDOCUMENT = GM_MATDOC
      MATDOCUMENTYEAR  = GM_DOCYER
    TABLES
      GOODSMVT_ITEM    = GM_ITEM
      RETURN           = GM_RETURN.

  IF NOT GM_MATDOC IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    P_CHECK = 'S'.
    P_TEMP-MBLNR2 = GM_MATDOC.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    P_CHECK = 'E'.

    CLEAR GM_RETURN.
    READ TABLE GM_RETURN WITH KEY TYPE = 'E'.

    CONCATENATE GM_RETURN-TYPE GM_RETURN-ID GM_RETURN-NUMBER
                GM_RETURN-MESSAGE_V1 GM_RETURN-MESSAGE_V2
                GM_RETURN-MESSAGE_V3 GM_RETURN-MESSAGE_V4
           INTO P_TEMP-ZMESSAGE.

*---MTS로 재고차이 전기한 자재문서 취소
*    PERFORM CANCEL_MAT_DOC USING P_TEMP.
  ENDIF.


ENDFORM.                    " TRANSFER_POST_MTO
*&---------------------------------------------------------------------*
*&      Form  CANCEL_413MAT_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_LIST  text
*----------------------------------------------------------------------*
FORM CANCEL_413MAT_DOC  USING    PS_LIST TYPE ZGTBDS310
                                 P_CHECK.
  DATA: LV_STRING LIKE CFGNL-MSGLIN.

  CLS: GM_RETURN.
  CLEAR: GM_HEADRET.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = PS_LIST-MBLNR2
      MATDOCUMENTYEAR     = PS_LIST-MJAHR
      GOODSMVT_PSTNG_DATE = P_ZLDAT
    IMPORTING
      GOODSMVT_HEADRET    = GM_HEADRET
    TABLES
      RETURN              = GM_RETURN.

  IF NOT GM_HEADRET-MAT_DOC IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    PS_LIST-MBLNRC2 = GM_HEADRET-MAT_DOC.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    P_CHECK = 'E'.

    CLEAR GM_RETURN.
    READ TABLE GM_RETURN WITH KEY TYPE = 'E'.

    CONCATENATE GM_RETURN-TYPE GM_RETURN-ID GM_RETURN-NUMBER
                GM_RETURN-MESSAGE ' '
                GM_RETURN-MESSAGE_V1 GM_RETURN-MESSAGE_V2
                GM_RETURN-MESSAGE_V3 GM_RETURN-MESSAGE_V4
           INTO PS_LIST-ZMESSAGE.
  ENDIF.

ENDFORM.                    " CANCEL_413MAT_DOC
*&---------------------------------------------------------------------*
*&      Form  CANCEL_701MAT_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_LIST  text
*      -->P_LV_CHECK  text
*----------------------------------------------------------------------*
FORM CANCEL_701MAT_DOC  USING    PS_LIST TYPE ZGTBDS310
                                 P_CHECK
                                 P_DOUBL.
  DATA: LV_QTY    LIKE ZPBT0030-ERFMG,
        LV_MTO(1).

  CLS: GT_BDCDATA, GT_MESSTAB.
  CLEAR: GS_CTU_PARAMS.

  LV_QTY = ABS( PS_LIST-ERFMG ).

  IF PS_LIST-ZMTOS = 'MTO'.
    IF PS_LIST-SHKZG = 'H'.
      CLEAR MSKA.
      SELECT SINGLE *
        FROM MSKA
       WHERE MATNR = PS_LIST-MATNR
         AND WERKS = PS_LIST-WERKS
         AND LGORT = PS_LIST-LGORT
         AND SOBKZ = 'E'
         AND VBELN = PS_LIST-KDAUF
         AND POSNR = PS_LIST-KDPOS.
*         AND KALAB > 0.
      IF SY-SUBRC <> 0.
        LV_MTO = 'X'.
      ENDIF.
    ENDIF.
  ENDIF.

* BUILD BDC
  PERFORM BDC_DYNPRO USING:'SAPMM07I'    '0700'.
  PERFORM BDC_FIELD  USING:'BDC_OKCODE'  '/00',
                           'RM07I-ZLDAT'   P_ZLDAT,
                           'RM07I-BLDAT'   P_BLDAT,
                           'IKPF-WERKS'    P_WERKS,
                           'IKPF-LGORT'    PS_LIST-LGORT.

  CASE PS_LIST-ZMTOS.
    WHEN 'MTO'.
      IF P_DOUBL = 'X'.
        PERFORM BDC_FIELD  USING:'IKPF-SOBKZ'    ' '.
      ELSE.
        IF LV_MTO = 'X'.
          PERFORM BDC_FIELD  USING:'IKPF-SOBKZ'    ' '.
        ELSE.
          PERFORM BDC_FIELD  USING:'IKPF-SOBKZ'    'E'.
        ENDIF.
      ENDIF.
    WHEN 'MTS'.
      PERFORM BDC_FIELD  USING:'IKPF-SOBKZ'    ' '.
  ENDCASE.

  PERFORM BDC_DYNPRO USING:'SAPMM07I'       '0731'.
  PERFORM BDC_FIELD  USING:'BDC_OKCODE'     '=BU',
                           'ISEG-MATNR(01)' PS_LIST-MATNR.

  IF PS_LIST-ZMTOS = 'MTO'.
    IF P_DOUBL NE 'X' AND
       LV_MTO  NE 'X'.
      PERFORM BDC_FIELD  USING:'ISEGK-KDAUF'    PS_LIST-KDAUF,
                               'ISEGK-KDPOS'    PS_LIST-KDPOS.
    ENDIF.
  ENDIF.

  CASE PS_LIST-ZMTOS.
    WHEN 'MTO'.
      IF P_DOUBL = 'X'.
        CLEAR MARD.
        SELECT SINGLE *
          FROM MARD
         WHERE MATNR = PS_LIST-MATNR
           AND WERKS = PS_LIST-WERKS
           AND LGORT = PS_LIST-LGORT.

        IF SY-SUBRC = 0.
          LV_QTY = MARD-LABST - LV_QTY.
          IF LV_QTY = 0.
            PERFORM BDC_FIELD      USING 'ISEG-XNULL(01)' 'X'.
          ELSEIF LV_QTY > 0.
            PERFORM BDC_FIELD      USING:'ISEG-ERFMG(01)'
                                             LV_QTY.
          ELSEIF LV_QTY < 0.
            P_CHECK = 'E'.
            PS_LIST-ZMESSAGE = TEXT-E10.
          ENDIF.
        ELSE.
          P_CHECK = 'E'.
          PS_LIST-ZMESSAGE = TEXT-E16.
        ENDIF.
      ELSE.
        PERFORM PROCESS_MTO_DETAIL USING PS_LIST P_CHECK LV_QTY LV_MTO.
      ENDIF.
    WHEN 'MTS'.
      CLEAR MARD.
      SELECT SINGLE *
        FROM MARD
       WHERE MATNR = PS_LIST-MATNR
         AND WERKS = P_WERKS
         AND LGORT = PS_LIST-LGORT.

      CASE PS_LIST-SHKZG.
        WHEN 'S'.
          IF MARD-LABST < LV_QTY.
            P_CHECK = 'E'.
            PS_LIST-ZMESSAGE = TEXT-E10.
          ELSE.
            LV_QTY = MARD-LABST - LV_QTY.
            IF LV_QTY = 0.
              PERFORM BDC_FIELD      USING 'ISEG-XNULL(01)' 'X'.
            ELSE.
              PERFORM BDC_FIELD      USING:'ISEG-ERFMG(01)'
                                           LV_QTY.
            ENDIF.
          ENDIF.
        WHEN 'H'.
          LV_QTY = MARD-LABST + LV_QTY.
          PERFORM BDC_FIELD      USING:'ISEG-ERFMG(01)'
                                           LV_QTY.
      ENDCASE.
  ENDCASE.

  CHECK P_CHECK NE 'E'.
*-MI10 실행
  PERFORM BDC_TRANSACTION_CANCEL USING    'MI10' BDC_MODE
                              CHANGING PS_LIST P_CHECK.

  CHECK P_CHECK = 'S' AND LV_MTO = 'X'.

*-MB1B 413이전전기
  PERFORM GOODS_MVT_413 USING PS_LIST P_CHECK LV_QTY.
ENDFORM.                    " CANCEL_701MAT_DOC
*&---------------------------------------------------------------------*
*&      Form  CALL_POPUP_FUNC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEXT_007  text
*      -->P_TEXT_008  text
*      -->P_0051   text
*      <--P_LV_ANSWER  text
*----------------------------------------------------------------------*
FORM CALL_POPUP_FUNC  USING    P_TITLE
                               P_TEXT1
                               P_TEXT2
                      CHANGING P_ANSWER.

  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      TITEL     = P_TITLE
      TEXTLINE1 = P_TEXT1
      TEXTLINE2 = P_TEXT2
    IMPORTING
      ANSWER    = P_ANSWER.

ENDFORM.                    " CALL_POPUP_FUNC
*&---------------------------------------------------------------------*
*&      Form  INIT_CNTROLS_OBJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INIT_CNTROLS_OBJECT .

  IF NOT G_GRID IS INITIAL.
    CALL METHOD G_GRID->FREE.
    CLEAR G_GRID.
  ENDIF.

  IF NOT G_CONTAINER IS INITIAL.
    CALL METHOD G_CONTAINER->FREE.
    CLEAR G_CONTAINER.
  ENDIF.

  CLS: IT_LIST, GT_FIELDCAT, GT_SORT, GT_EXCLUDE.
  CLEAR: GS_LAYOUT, GS_VARI, GV_STATUS.
ENDFORM.                    " INIT_CNTROLS_OBJECT
*&---------------------------------------------------------------------*
*&      Form  CHANGE_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHANGE_CATALOG .
  DATA: PT_FIELDCAT TYPE LVC_T_FCAT,
        LS_FCAT     TYPE LVC_S_FCAT.

  CALL METHOD G_GRID->GET_FRONTEND_FIELDCATALOG
    IMPORTING
      ET_FIELDCATALOG = PT_FIELDCAT.

  LOOP AT PT_FIELDCAT INTO LS_FCAT.
    CASE LS_FCAT-FIELDNAME.
      WHEN 'ZSIGN'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-OUTPUTLEN = '3'.
        LS_FCAT-COLTEXT  = 'S'.
        LS_FCAT-COL_POS  = '1'.
      WHEN 'WERKS'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-OUTPUTLEN = '4'.
        LS_FCAT-COL_POS  = '2'.
      WHEN 'LGORT'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-OUTPUTLEN = '4'.
        LS_FCAT-COL_POS  = '3'.
      WHEN 'MATNR'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-OUTPUTLEN = '10'.
        LS_FCAT-COL_POS  = '4'.
      WHEN 'MAKTX'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-OUTPUTLEN = '20'.
        LS_FCAT-COL_POS = '5'.
      WHEN 'ZMTOS'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-COLTEXT  = TEXT-F01. "재고유형
        LS_FCAT-OUTPUTLEN = '5'.
        LS_FCAT-COL_POS  = '6'.
      WHEN 'ZEBUN'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-OUTPUTLEN = '12'.
        LS_FCAT-COL_POS  = '7'.
      WHEN 'ZSILMG'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-COLTEXT = TEXT-F07. "실사수량
        LS_FCAT-OUTPUTLEN = '13'.
        LS_FCAT-COL_POS = '8'.
      WHEN 'ZERPMG'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-COLTEXT = TEXT-F08. "전산수량
        LS_FCAT-OUTPUTLEN = '13'.
        LS_FCAT-COL_POS = '9'.
      WHEN 'ERFMG'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-OUTPUTLEN = '13'.
        LS_FCAT-COL_POS  = '10'.
      WHEN 'ERFME'.
        LS_FCAT-OUTPUTLEN = '3'.
        LS_FCAT-COL_POS  = '11'.
      WHEN 'KDAUF'.
        LS_FCAT-NO_OUT  = ' '.
        LS_FCAT-COL_POS  = '12'.
      WHEN 'KDPOS'.
        LS_FCAT-NO_OUT  = ' '.
        LS_FCAT-COL_POS  = '13'.
      WHEN 'BWART'.
        LS_FCAT-NO_OUT  = ' '.
        LS_FCAT-COL_POS  = '14'.
      WHEN 'MBLNR'.
        LS_FCAT-HOTSPOT = 'X'.
        LS_FCAT-NO_OUT  = ' '.
        LS_FCAT-COLTEXT = TEXT-F02. "실사차이
        LS_FCAT-COL_POS  = '15'.
      WHEN 'MBLNR2'.
        LS_FCAT-HOTSPOT = 'X'.
        LS_FCAT-NO_OUT  = ' '.
        LS_FCAT-COLTEXT = TEXT-F03. "MTO전환
        LS_FCAT-COL_POS  = '16'.
      WHEN 'MBLNRC1'.
        LS_FCAT-HOTSPOT = 'X'.
        LS_FCAT-NO_OUT  = 'X'.
        LS_FCAT-COLTEXT = TEXT-F04. "취소(실사차이)
        LS_FCAT-COL_POS  = '17'.
      WHEN 'MBLNRC2'.
        LS_FCAT-HOTSPOT = 'X'.
        LS_FCAT-NO_OUT  = 'X'.
        LS_FCAT-COLTEXT = TEXT-F05. "취소(MTO전환)
        LS_FCAT-COL_POS  = '18'.
      WHEN 'ZMESSAGE'.
        LS_FCAT-COLTEXT = TEXT-F06. "에러 메세지
        LS_FCAT-OUTPUTLEN = '100'.
        LS_FCAT-COL_POS  = '19'.
      WHEN OTHERS.
        LS_FCAT-NO_OUT  = 'X'.
    ENDCASE.

    MODIFY PT_FIELDCAT FROM LS_FCAT.
  ENDLOOP.

  CALL METHOD G_GRID->SET_FRONTEND_FIELDCATALOG
    EXPORTING
      IT_FIELDCATALOG = PT_FIELDCAT.

ENDFORM.                    " CHANGE_CATALOG
*&---------------------------------------------------------------------*
*&      Form  CHANGE_CATALOG_CANCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHANGE_CATALOG_CANCEL .
  DATA: PT_FIELDCAT TYPE LVC_T_FCAT,
        LS_FCAT     TYPE LVC_S_FCAT.

  CALL METHOD G_GRID->GET_FRONTEND_FIELDCATALOG
    IMPORTING
      ET_FIELDCATALOG = PT_FIELDCAT.

  LOOP AT PT_FIELDCAT INTO LS_FCAT.
    CASE LS_FCAT-FIELDNAME.
      WHEN 'ZSIGN'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-OUTPUTLEN = '3'.
        LS_FCAT-COLTEXT  = 'S'.
        LS_FCAT-COL_POS  = '1'.
      WHEN 'WERKS'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-OUTPUTLEN = '4'.
        LS_FCAT-COL_POS  = '2'.
      WHEN 'LGORT'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-OUTPUTLEN = '4'.
        LS_FCAT-COL_POS  = '3'.
      WHEN 'MATNR'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-OUTPUTLEN = '10'.
        LS_FCAT-COL_POS  = '4'.
      WHEN 'MAKTX'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-OUTPUTLEN = '20'.
        LS_FCAT-COL_POS = '5'.
      WHEN 'ZMTOS'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-COLTEXT  = TEXT-F01. "재고유형
        LS_FCAT-OUTPUTLEN = '5'.
        LS_FCAT-COL_POS  = '6'.
      WHEN 'ZEBUN'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-OUTPUTLEN = '12'.
        LS_FCAT-COL_POS  = '7'.
      WHEN 'ZSILMG'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-COLTEXT = TEXT-F07. "실사수량
        LS_FCAT-OUTPUTLEN = '13'.
        LS_FCAT-COL_POS = '8'.
      WHEN 'ZERPMG'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-COLTEXT = TEXT-F08. "전산수량
        LS_FCAT-OUTPUTLEN = '13'.
        LS_FCAT-COL_POS = '9'.
      WHEN 'ERFMG'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-OUTPUTLEN = '13'.
        LS_FCAT-COL_POS  = '10'.
      WHEN 'ERFME'.
        LS_FCAT-OUTPUTLEN = '3'.
        LS_FCAT-COL_POS  = '11'.
      WHEN 'KDAUF'.
        LS_FCAT-NO_OUT  = ' '.
        LS_FCAT-COL_POS  = '12'.
      WHEN 'KDPOS'.
        LS_FCAT-NO_OUT  = ' '.
        LS_FCAT-COL_POS  = '13'.
      WHEN 'BWART'.
        LS_FCAT-NO_OUT  = ' '.
        LS_FCAT-COL_POS  = '14'.
      WHEN 'MBLNR'.
        LS_FCAT-HOTSPOT = 'X'.
        LS_FCAT-NO_OUT  = ' '.
        LS_FCAT-COLTEXT = TEXT-F02. "실사차이
        LS_FCAT-COL_POS  = '15'.
      WHEN 'MBLNR2'.
        LS_FCAT-HOTSPOT = 'X'.
        LS_FCAT-NO_OUT  = ' '.
        LS_FCAT-COLTEXT = TEXT-F03. "MTO전환
        LS_FCAT-COL_POS  = '16'.
      WHEN 'MBLNRC1'.
        LS_FCAT-HOTSPOT = 'X'.
        LS_FCAT-NO_OUT  = ' '.
        LS_FCAT-COLTEXT = TEXT-F04. "취소(실사차이)
        LS_FCAT-COL_POS  = '17'.
      WHEN 'MBLNRC2'.
        LS_FCAT-HOTSPOT = 'X'.
        LS_FCAT-NO_OUT  = ' '.
        LS_FCAT-COLTEXT = TEXT-F05. "취소(MTO전환)
        LS_FCAT-COL_POS  = '18'.
      WHEN 'ZMESSAGE'.
        LS_FCAT-COLTEXT = TEXT-F06. "에러 메세지
        LS_FCAT-OUTPUTLEN = '100'.
        LS_FCAT-COL_POS  = '19'.
      WHEN OTHERS.
        LS_FCAT-NO_OUT  = 'X'.
    ENDCASE.

    MODIFY PT_FIELDCAT FROM LS_FCAT.
  ENDLOOP.

  CALL METHOD G_GRID->SET_FRONTEND_FIELDCATALOG
    EXPORTING
      IT_FIELDCATALOG = PT_FIELDCAT.

ENDFORM.                    " CHANGE_CATALOG_CANCEL
*&---------------------------------------------------------------------*
*&      Form  BUILD_MTS_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_TEMP  text
*      -->P_LV_CHECK  text
*----------------------------------------------------------------------*
FORM BUILD_MTS_LIST  USING    P_TEMP TYPE ZGTBDS310
                              P_CHECK.

  DATA: LS_MARD LIKE MARD.

  SELECT SINGLE *
    INTO LS_MARD
    FROM MARD
   WHERE MATNR = P_TEMP-MATNR
     AND WERKS = P_WERKS
     AND LGORT = P_TEMP-LGORT.

  IF SY-SUBRC = 0.
    CASE P_TEMP-SHKZG.
      WHEN 'S'.
        P_TEMP-ZERFMG = LS_MARD-LABST + ABS( P_TEMP-ERFMG ).
      WHEN 'H'.
        IF LS_MARD-LABST < P_TEMP-ERFMG.
          P_CHECK = 'E'.
          P_TEMP-ZMESSAGE = TEXT-E10.
        ELSE.
          P_TEMP-ZERFMG = LS_MARD-LABST - ABS( P_TEMP-ERFMG ).
        ENDIF.
    ENDCASE.
  ELSE.
    P_CHECK = 'E'.
    P_TEMP-ZMESSAGE = TEXT-E16.
  ENDIF.
ENDFORM.                    " BUILD_MTS_LIST
*&---------------------------------------------------------------------*
*&      Form  PROCESS_MTO_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PS_LIST  text
*      -->P_P_CHECK  text
*----------------------------------------------------------------------*
FORM PROCESS_MTO_DETAIL  USING    PS_LIST TYPE ZGTBDS310
                                  P_CHECK
                                  P_QTY
                                  P_MTO.

  CLEAR MSKA.
  SELECT SINGLE *
    FROM MSKA
   WHERE MATNR = PS_LIST-MATNR
     AND WERKS = PS_LIST-WERKS
     AND LGORT = PS_LIST-LGORT
     AND SOBKZ = 'E'
     AND VBELN = PS_LIST-KDAUF
     AND POSNR = PS_LIST-KDPOS
     AND KALAB > 0.

  IF SY-SUBRC <> 0.
    CASE PS_LIST-SHKZG.
      WHEN 'S'.
        P_CHECK = 'E'.
        PS_LIST-ZMESSAGE = TEXT-E10.
      WHEN 'H'.
        IF P_MTO = 'X'.
          PERFORM BDC_FIELD      USING:'ISEG-ERFMG(01)'
                                           P_QTY.
        ELSE.
          P_QTY = MSKA-KALAB + P_QTY.
          PERFORM BDC_FIELD      USING:'ISEG-ERFMG(01)'
                                           P_QTY.
        ENDIF.
    ENDCASE.
  ELSE.
    CASE PS_LIST-SHKZG.
      WHEN 'S'.
        IF MSKA-KALAB < P_QTY.
          P_CHECK = 'E'.
          PS_LIST-ZMESSAGE = TEXT-E10.
        ELSE.
          P_QTY = MSKA-KALAB - P_QTY.
          PERFORM BDC_FIELD      USING:'ISEG-ERFMG(01)'
                                           P_QTY.
        ENDIF.
      WHEN 'H'.
        P_QTY = MSKA-KALAB + P_QTY.
        PERFORM BDC_FIELD      USING:'ISEG-ERFMG(01)'
                                           P_QTY.
    ENDCASE.
  ENDIF.
ENDFORM.                    " PROCESS_MTO_DETAIL
*&---------------------------------------------------------------------*
*&      Form  GOODS_MVT_413
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PS_LIST  text
*      -->P_P_CHECK  text
*----------------------------------------------------------------------*
FORM GOODS_MVT_413  USING    PS_LIST TYPE ZGTBDS310
                             P_CHECK
                             P_QTY.
  CLEAR: GM_HEADER, GM_CODE, GM_HEADRET, GM_MATDOC,
         GM_DOCYER.
  CLS  : GM_ITEM, GM_RETURN.

*-헤더
  GM_HEADER-PSTNG_DATE   = P_ZLDAT."전기일
  GM_HEADER-DOC_DATE     = P_BLDAT."증빙일

  GM_CODE-GM_CODE        = '04'.   "TRANSACTION(MB1B)

* 아이템
  GM_ITEM-MATERIAL       = PS_LIST-MATNR.
  GM_ITEM-MOVE_TYPE      = '413'.         "이동유형
  GM_ITEM-PLANT          = P_WERKS.
  GM_ITEM-STGE_LOC       = PS_LIST-LGORT.    "저장위치
  GM_ITEM-ENTRY_QNT      = P_QTY.   "입력단위수량
  GM_ITEM-MOVE_PLANT     = P_WERKS.
  GM_ITEM-MOVE_STLOC     = PS_LIST-LGORT.
  GM_ITEM-VAL_SALES_ORD  = PS_LIST-KDAUF.    "판매문서
  GM_ITEM-VAL_S_ORD_ITEM = PS_LIST-KDPOS.    "품목번호
  GM_ITEM-MVT_IND        = SPACE.                "이동지시자
  APPEND GM_ITEM.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = GM_HEADER
      GOODSMVT_CODE    = GM_CODE
    IMPORTING
      GOODSMVT_HEADRET = GM_HEADRET
      MATERIALDOCUMENT = GM_MATDOC
      MATDOCUMENTYEAR  = GM_DOCYER
    TABLES
      GOODSMVT_ITEM    = GM_ITEM
      RETURN           = GM_RETURN.

  IF NOT GM_MATDOC IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    P_CHECK = 'S'.
    PS_LIST-MBLNRC2 = GM_MATDOC.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    P_CHECK = 'E'.

    CLEAR GM_RETURN.
    READ TABLE GM_RETURN WITH KEY TYPE = 'E'.

    CONCATENATE GM_RETURN-TYPE GM_RETURN-ID GM_RETURN-NUMBER
                GM_RETURN-MESSAGE_V1 GM_RETURN-MESSAGE_V2
                GM_RETURN-MESSAGE_V3 GM_RETURN-MESSAGE_V4
           INTO PS_LIST-ZMESSAGE.

  ENDIF.

ENDFORM.                    " GOODS_MVT_413
*&---------------------------------------------------------------------*
*&      Form  BDC_TRANSACTION_CANCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1766   text
*      -->P_BDC_MODE  text
*      <--P_PS_LIST  text
*      <--P_P_CHECK  text
*----------------------------------------------------------------------*
FORM BDC_TRANSACTION_CANCEL  USING TCODE
                                   MODE
                          CHANGING PS_LIST TYPE ZGTBDS310
                                   P_CHECK.

  DATA: LV_TEXT LIKE CFGNL-MSGLIN.

  GS_CTU_PARAMS-DISMODE  = MODE.
  GS_CTU_PARAMS-UPDMODE  = 'S'.
  GS_CTU_PARAMS-CATTMODE = ' '.
  GS_CTU_PARAMS-DEFSIZE  = ' '. "Default Size(Recording과 같은화면으로처
  GS_CTU_PARAMS-RACOMMIT = ' '. "NOT EXIT AT COMMIT WORK
  GS_CTU_PARAMS-NOBINPT  = ' '. "Not as batch input session, that is, SY
  GS_CTU_PARAMS-NOBIEND  = ' '. "Not as batch input session after end of

  CALL TRANSACTION TCODE   USING GT_BDCDATA
                           OPTIONS FROM GS_CTU_PARAMS
                           MESSAGES INTO GT_MESSTAB.

  WAIT UP TO '3.0' SECONDS.
  CLEAR GT_MESSTAB.
  READ TABLE GT_MESSTAB WITH KEY MSGTYP = 'S'
                                 MSGID  = 'M7'
                                 MSGNR  = '716'.
  IF SY-SUBRC = 0.

    PS_LIST-MBLNRC1 = GT_MESSTAB-MSGV2.
    P_CHECK = 'S'.
  ELSE.
    P_CHECK = 'E'.
    CLEAR GT_MESSTAB.
    READ TABLE GT_MESSTAB WITH KEY MSGTYP = 'E'.

    CONCATENATE GT_MESSTAB-MSGTYP GT_MESSTAB-MSGID GT_MESSTAB-MSGNR
                GT_MESSTAB-MSGV1 GT_MESSTAB-MSGV2
                GT_MESSTAB-MSGV3 GT_MESSTAB-MSGV4
           INTO PS_LIST-ZMESSAGE.

  ENDIF.

ENDFORM.                    " BDC_TRANSACTION_CANCEL
*&---------------------------------------------------------------------*
*&      Form  GET_BWART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_TEMP  text
*----------------------------------------------------------------------*
FORM GET_BWART  USING    PS_TEMP TYPE ZGTBDS310.

  CHECK NOT PS_TEMP-MBLNR IS INITIAL.

  CLEAR MSEG.
  SELECT BWART
    INTO PS_TEMP-BWART
    FROM MSEG
      UP TO 1 ROWS
   WHERE MBLNR = PS_TEMP-MBLNR
     AND MJAHR = PS_TEMP-MJAHR.
  ENDSELECT.
ENDFORM.                    " GET_BWART
*&---------------------------------------------------------------------*
*&      Form  PHYSICAL_INV_MTOH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_TEMP  text
*      -->P_LV_CHECK  text
*----------------------------------------------------------------------*
FORM PHYSICAL_INV_MTOH  USING    P_TEMP TYPE ZGTBDS310
                                 P_CHECK.

* BUILD BDC
  PERFORM BDC_DYNPRO USING:'SAPMM07I'    '0700'.
  PERFORM BDC_FIELD  USING:'BDC_OKCODE'  '/00',
                           'RM07I-ZLDAT'   P_ZLDAT,
                           'RM07I-BLDAT'   P_BLDAT,
                           'IKPF-WERKS'    P_WERKS,
                           'IKPF-LGORT'    P_TEMP-LGORT,
                           'IKPF-SOBKZ'    'E'.


  LOOP AT GT_LIST.
    PERFORM BDC_DYNPRO USING:'SAPMM07I'       '0731'.
    PERFORM BDC_FIELD  USING:'BDC_OKCODE'     '/00',
                             'ISEG-MATNR(01)' P_TEMP-MATNR,
                             'ISEGK-KDAUF'    GT_LIST-KDAUF,
                             'ISEGK-KDPOS'    GT_LIST-KDPOS.

    IF GT_LIST-ZERFMG <= 0.
      PERFORM BDC_FIELD      USING 'ISEG-XNULL(01)' 'X'.
    ELSE.
      PERFORM BDC_FIELD      USING:'ISEG-ERFMG(01)' GT_LIST-ZERFMG.
    ENDIF.
  ENDLOOP.

  PERFORM BDC_DYNPRO USING:'SAPMM07I'       '0731'.
  PERFORM BDC_FIELD  USING:'BDC_OKCODE'     '=BU'.

*-MI10 실행
  PERFORM BDC_TRANSACTION USING    'MI10' BDC_MODE
                          CHANGING P_TEMP P_CHECK.

ENDFORM.                    " PHYSICAL_INV_MTOH
*&---------------------------------------------------------------------*
*&      Form  CANCEL_MTOH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_LIST  text
*      -->P_LV_CHECK  text
*----------------------------------------------------------------------*
FORM CANCEL_MTOH_PROCESS  USING    PS_LIST TYPE ZGTBDS310
                                   P_CHECK.

  DATA: T_MSEG   LIKE MSEG OCCURS 0 WITH HEADER LINE,
        T_STOCK  LIKE MSKA OCCURS 0 WITH HEADER LINE,
        LV_VBELN LIKE MSKA-VBELN.
  DATA: LV_QTY LIKE MSEG-ERFMG.

  CLS: GT_BDCDATA, GT_MESSTAB.
  CLEAR: GS_CTU_PARAMS.

*-자재문서
  SELECT *
    INTO TABLE T_MSEG
    FROM MSEG
   WHERE MBLNR = PS_LIST-MBLNR
     AND MJAHR = PS_LIST-MJAHR.

  CLEAR T_MSEG.
  READ TABLE T_MSEG INDEX 1.
  LV_VBELN = T_MSEG-MAT_KDAUF.

*-MTO STOCK
  SELECT *
    INTO TABLE T_STOCK
    FROM MSKA
     FOR ALL ENTRIES IN T_MSEG
   WHERE MATNR = PS_LIST-MATNR
     AND WERKS = PS_LIST-WERKS
     AND LGORT = PS_LIST-LGORT
     AND SOBKZ = 'E'
     AND VBELN = LV_VBELN
     AND POSNR = T_MSEG-MAT_KDPOS.

* BUILD BDC
  PERFORM BDC_DYNPRO USING:'SAPMM07I'    '0700'.
  PERFORM BDC_FIELD  USING:'BDC_OKCODE'  '/00',
                           'RM07I-ZLDAT'   P_ZLDAT,
                           'RM07I-BLDAT'   P_BLDAT,
                           'IKPF-WERKS'    P_WERKS,
                           'IKPF-LGORT'    PS_LIST-LGORT,
                           'IKPF-SOBKZ'    'E'.


  LOOP AT T_MSEG.
    CLEAR: T_STOCK, LV_QTY.
    READ TABLE T_STOCK WITH KEY MATNR = T_MSEG-MATBF
                                VBELN = T_MSEG-MAT_KDAUF
                                POSNR = T_MSEG-MAT_KDPOS.

    PERFORM BDC_DYNPRO USING:'SAPMM07I'       '0731'.
    PERFORM BDC_FIELD  USING:'BDC_OKCODE'     '/00',
                             'ISEG-MATNR(01)' T_MSEG-MATBF,
                             'ISEGK-KDAUF'    T_MSEG-MAT_KDAUF,
                             'ISEGK-KDPOS'    T_MSEG-MAT_KDPOS.

    LV_QTY = T_STOCK-KALAB + T_MSEG-ERFMG.
    PERFORM BDC_FIELD      USING:'ISEG-ERFMG(01)' LV_QTY.

  ENDLOOP.

  PERFORM BDC_DYNPRO USING:'SAPMM07I'       '0731'.
  PERFORM BDC_FIELD  USING:'BDC_OKCODE'     '=BU'.

*-MI10 실행

  PERFORM BDC_TRANSACTION_CANCEL USING    'MI10' BDC_MODE
                              CHANGING PS_LIST P_CHECK.


ENDFORM.                    " CANCEL_MTOH
