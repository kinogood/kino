*&---------------------------------------------------------------------*
*& Include          ZGTPPR4060F01
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

  P_WERKS = GC_1306.
  P_LGORT = GC_2510.
  P_SPMON = SY-DATUM+0(6).
  P_BUDAT = SY-DATUM.

  IF S_CRDAT[] IS INITIAL.
    S_CRDAT-SIGN   = GC_I.
    S_CRDAT-OPTION = GC_EQ.
    S_CRDAT-LOW    = SY-DATUM.
    APPEND S_CRDAT.
  ENDIF.

  CLEAR: GV_BUDAT.
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = SY-DATUM
    IMPORTING
      LAST_DAY_OF_MONTH = GV_BUDAT
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2.

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
  ID 'WERKS'  FIELD P_WERKS.

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
      WHEN 'P_WERKS' OR 'P_LGORT' OR 'P_SPMON' OR 'P_FILE' OR 'P_BUDAT'.
        SCREEN-REQUIRED = 2.
        MODIFY SCREEN.
    ENDCASE.

    IF P_R1 EQ GC_X.
      IF P_RP EQ GC_X.
        IF SCREEN-GROUP1 = 'S2' OR SCREEN-GROUP1 = 'S3' OR
           SCREEN-GROUP1 = 'S4' OR SCREEN-GROUP1 = 'S5'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.
      ELSEIF P_RC EQ GC_X.
        IF SCREEN-GROUP1 = 'S2'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.
        IF P_HAND EQ GC_X.
          IF SCREEN-GROUP1 = 'S5'.
            SCREEN-ACTIVE = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
      ENDIF.
      GV_TITLE = TEXT-T03.   "일반정보
    ELSEIF P_R2 EQ GC_X.
      IF SCREEN-GROUP1 = 'S1' OR SCREEN-GROUP1 = 'S3' OR
         SCREEN-GROUP1 = 'S4' OR SCREEN-GROUP1 = 'S5'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
      GV_TITLE = TEXT-T06.   "헤더정보
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
       WITH TEXT-M03. "필수 필드 "플랜트"에 입력하십시오.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF P_SPMON IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH TEXT-M04. "필수 필드 "대상월"에 입력하십시오.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF P_R1 EQ GC_X.
    IF P_LGORT IS INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH TEXT-M05. "필수 필드 "저장위치"에 입력하십시오.
      LEAVE LIST-PROCESSING.
    ENDIF.

    IF P_FILE IS INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH TEXT-M06. "필수 필드 "파일 경로"에 입력하십시오.
      LEAVE LIST-PROCESSING.
    ENDIF.

    IF P_RC EQ GC_X.
      IF P_BUDAT IS INITIAL.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH TEXT-M22. "필수 필드 "전기일자"에 입력하십시오.
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.
  ENDIF.

*-투입유형 세팅(ZCAT)
  CLEAR: GV_ZCAT.
  IF P_RP EQ GC_X.
    GV_ZCAT = GC_P.
  ELSEIF P_RC EQ GC_X.
    GV_ZCAT = GC_C.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_FILENAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_FILE
*&---------------------------------------------------------------------*
FORM F4_FILENAME  CHANGING P_FILE.

  DATA: L_RC               TYPE I VALUE 1,
        LT_FILES           TYPE FILETABLE,
        LV_USER_ACTION     TYPE I,
        L_DESKTOPDIRECTORY TYPE STRING,
        LV_TITLE           TYPE STRING.

  CLEAR: LV_TITLE.
  LV_TITLE = TEXT-T07.  "파일 열기

  CONCATENATE CL_GUI_FRONTEND_SERVICES=>FILETYPE_EXCEL
              CL_GUI_FRONTEND_SERVICES=>FILETYPE_ALL
         INTO DATA(LV_FILE_FILTER).

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GET_DESKTOP_DIRECTORY
    CHANGING
      DESKTOP_DIRECTORY = L_DESKTOPDIRECTORY.

  CALL METHOD CL_GUI_CFW=>UPDATE_VIEW.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE      = LV_TITLE
      FILE_FILTER       = LV_FILE_FILTER
      INITIAL_DIRECTORY = L_DESKTOPDIRECTORY
    CHANGING
      FILE_TABLE        = LT_FILES
      RC                = L_RC
      USER_ACTION       = LV_USER_ACTION.

  IF LT_FILES[] IS NOT INITIAL.
    READ TABLE LT_FILES INTO P_FILE INDEX 1.
  ELSE.
    MESSAGE S003 DISPLAY LIKE GC_E  WITH 'FILE NOT SELECT'.
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

  IF P_R1 EQ GC_X.
    PERFORM EXCEL_UPLOAD.
    IF P_RP EQ GC_X.
      PERFORM GET_DATA_AS.
    ELSEIF P_RC EQ GC_X.
      PERFORM GET_ZGINO.
      IF P_RATIO EQ GC_X.
        PERFORM GET_PRD_GR_CR.
      ENDIF.
    ENDIF.
  ELSEIF P_R2 EQ GC_X.
    IF P_RP EQ GC_X.
      PERFORM GET_DATA_RESULT.
    ELSEIF P_RC EQ GC_X.
      PERFORM GET_DATA_RESULT_C.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCEL_UPLOAD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCEL_UPLOAD .
  DATA: LT_EXCEL TYPE KCDE_CELLS OCCURS 0 WITH HEADER LINE.
  DATA: LV_INDEX LIKE SY-TABIX.

  DATA: LCL_ERROR  TYPE REF TO CX_ROOT,
        LV_MESSAGE TYPE STRING,
        LT_RETURN  TYPE TABLE OF BAPIRET2 WITH HEADER LINE.

  FIELD-SYMBOLS: <FS>.

  CALL FUNCTION 'KCD_EXCEL_OLE_TO_INT_CONVERT'
    EXPORTING
      FILENAME                = P_FILE
      I_BEGIN_COL             = C_START_COL
      I_BEGIN_ROW             = C_START_ROW
      I_END_COL               = C_END_COL
      I_END_ROW               = C_END_ROW
    TABLES
      INTERN                  = LT_EXCEL
    EXCEPTIONS
      INCONSISTENT_PARAMETERS = 1
      UPLOAD_OLE              = 2.

  IF SY-SUBRC NE 0.
    MESSAGE E003 WITH 'File Upload Failed !' .
    STOP.
  ENDIF.

  CHECK NOT LT_EXCEL[] IS INITIAL.
  SORT LT_EXCEL BY ROW COL.

  IF P_RP EQ GC_X.
    LOOP AT LT_EXCEL.
      MOVE: LT_EXCEL-COL TO LV_INDEX.
      ASSIGN COMPONENT LV_INDEX OF STRUCTURE GS_PUPLOAD TO <FS>.
      TRY.
          MOVE: LT_EXCEL-VALUE TO <FS>.
        CATCH CX_ROOT INTO LCL_ERROR.
          CLEAR: LT_RETURN.
          LV_MESSAGE = LCL_ERROR->GET_TEXT( ).
          LT_RETURN-TYPE       = 'E'.
          LT_RETURN-ID         = 'ZGTPP00'.
          LT_RETURN-NUMBER     = '999'.
          LT_RETURN-MESSAGE_V1 = LT_EXCEL-ROW.
          LT_RETURN-MESSAGE_V2 = LT_EXCEL-COL.
          LT_RETURN-MESSAGE_V3 = LT_EXCEL-VALUE.
          LT_RETURN-MESSAGE_V4 = LV_MESSAGE.
          LT_RETURN-MESSAGE    = SPACE.
          LT_RETURN-ROW        = LT_EXCEL-ROW.
          LT_RETURN-FIELD      = LT_EXCEL-COL.
          APPEND LT_RETURN.
      ENDTRY.
      AT END OF ROW.
        APPEND GS_PUPLOAD TO GT_PUPLOAD.
        CLEAR GS_PUPLOAD.
      ENDAT.
    ENDLOOP.

    CLEAR: GT_PDATA.
    LOOP AT GT_PUPLOAD INTO GS_PUPLOAD.
      CLEAR: GS_PDATA.
      MOVE-CORRESPONDING GS_PUPLOAD TO GS_PDATA.

      PERFORM CONV_MATN1 USING    GS_PDATA-MATNR GC_I
                         CHANGING GS_PDATA-MATNR.

      APPEND GS_PDATA TO GT_PDATA.
    ENDLOOP.

  ELSEIF P_RC EQ GC_X.
    IF P_HAND EQ GC_X.
      LOOP AT LT_EXCEL.
        MOVE: LT_EXCEL-COL TO LV_INDEX.
        ASSIGN COMPONENT LV_INDEX OF STRUCTURE GS_CHUPLOAD TO <FS>.
        TRY.
            MOVE: LT_EXCEL-VALUE TO <FS>.
          CATCH CX_ROOT INTO LCL_ERROR.
            CLEAR: LT_RETURN.
            LV_MESSAGE = LCL_ERROR->GET_TEXT( ).
            LT_RETURN-TYPE       = 'E'.
            LT_RETURN-ID         = 'ZGTPP00'.
            LT_RETURN-NUMBER     = '999'.
            LT_RETURN-MESSAGE_V1 = LT_EXCEL-ROW.
            LT_RETURN-MESSAGE_V2 = LT_EXCEL-COL.
            LT_RETURN-MESSAGE_V3 = LT_EXCEL-VALUE.
            LT_RETURN-MESSAGE_V4 = LV_MESSAGE.
            LT_RETURN-MESSAGE    = SPACE.
            LT_RETURN-ROW        = LT_EXCEL-ROW.
            LT_RETURN-FIELD      = LT_EXCEL-COL.
            APPEND LT_RETURN.
        ENDTRY.
        AT END OF ROW.
          APPEND GS_CHUPLOAD TO GT_CHUPLOAD.
          CLEAR GS_CHUPLOAD.
        ENDAT.
      ENDLOOP.

      CLEAR: GT_CDATA.
      LOOP AT GT_CHUPLOAD INTO GS_CHUPLOAD.
        CLEAR: GS_CDATA.
        MOVE-CORRESPONDING GS_CHUPLOAD TO GS_CDATA.

        PERFORM CONV_ALPHA USING    GS_CDATA-AUFNR GC_I
                           CHANGING GS_CDATA-AUFNR.
        PERFORM CONV_MATN1 USING    GS_CDATA-MATNR GC_I
                           CHANGING GS_CDATA-MATNR.

        APPEND GS_CDATA TO GT_CDATA.
      ENDLOOP.

    ELSEIF P_RATIO EQ GC_X.
      LOOP AT LT_EXCEL.
        MOVE: LT_EXCEL-COL TO LV_INDEX.
        ASSIGN COMPONENT LV_INDEX OF STRUCTURE GS_CRUPLOAD TO <FS>.
        TRY.
            MOVE: LT_EXCEL-VALUE TO <FS>.
          CATCH CX_ROOT INTO LCL_ERROR.
            CLEAR: LT_RETURN.
            LV_MESSAGE = LCL_ERROR->GET_TEXT( ).
            LT_RETURN-TYPE       = 'E'.
            LT_RETURN-ID         = 'ZGTPP00'.
            LT_RETURN-NUMBER     = '999'.
            LT_RETURN-MESSAGE_V1 = LT_EXCEL-ROW.
            LT_RETURN-MESSAGE_V2 = LT_EXCEL-COL.
            LT_RETURN-MESSAGE_V3 = LT_EXCEL-VALUE.
            LT_RETURN-MESSAGE_V4 = LV_MESSAGE.
            LT_RETURN-MESSAGE    = SPACE.
            LT_RETURN-ROW        = LT_EXCEL-ROW.
            LT_RETURN-FIELD      = LT_EXCEL-COL.
            APPEND LT_RETURN.
        ENDTRY.
        AT END OF ROW.
          APPEND GS_CRUPLOAD TO GT_CRUPLOAD.
          CLEAR GS_CRUPLOAD.
        ENDAT.
      ENDLOOP.

      CLEAR: GT_CRDATA.
      LOOP AT GT_CRUPLOAD INTO GS_CRUPLOAD.
        CLEAR: GS_CRDATA.
        MOVE-CORRESPONDING GS_CRUPLOAD TO GS_CRDATA.

        PERFORM CONV_MATN1 USING    GS_CRDATA-MATNR GC_I
                           CHANGING GS_CRDATA-MATNR.

        MOVE: GS_CRDATA-GI_QTY TO GS_CRDATA-REAL_QTY.
        APPEND GS_CRDATA TO GT_CRDATA.
      ENDLOOP.

    ENDIF.

  ENDIF.

  IF LT_RETURN[] IS NOT INITIAL.
    CLEAR: LT_RETURN.
    LT_RETURN-TYPE       = 'E'.
    LT_RETURN-ID         = 'ZGTPP00'.
    LT_RETURN-NUMBER     = '000'.
    LT_RETURN-MESSAGE_V1 = '엑셀 변환오류가 발생하였습니다. 처리를 종료합니다,'.
    APPEND LT_RETURN.
    CALL FUNCTION 'FINB_BAPIRET2_DISPLAY'
      EXPORTING
        IT_MESSAGE = LT_RETURN[].
    IF P_RP EQ GC_X.
      REFRESH GT_PDATA.
    ELSEIF P_RC EQ GC_X.
      IF P_HAND EQ GC_X.
        REFRESH GT_CDATA.
      ELSEIF P_RATIO EQ GC_X.
        REFRESH GT_CRDATA.
      ENDIF.
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

  IF P_R1 EQ GC_X.
    IF P_RP EQ GC_X.
      PERFORM MODIFY_DATA_P.
      PERFORM MODIFY_DATA_AS.
    ELSEIF P_RC EQ GC_X.
      IF P_RATIO EQ GC_X.
        PERFORM SET_DATA_CR.
      ENDIF.
      PERFORM MODIFY_DATA_C.
    ENDIF.
  ELSEIF P_R2 EQ GC_X.
    IF P_RP EQ GC_X.
      PERFORM MODIFY_DATA_REV.
    ELSEIF P_RC EQ GC_X.
      PERFORM MODIFY_DATA_REV_C.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA_P
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA_P .

  DATA: LV_MATNR TYPE MATNR,
        LV_LABST TYPE LABST.

  DATA: LT_PDATA LIKE TABLE OF GS_PDATA.

  CLEAR: LT_PDATA.
  APPEND LINES OF GT_PDATA TO LT_PDATA.

  SORT: LT_PDATA BY MATNR PCKTYPE,
        GT_PDATA BY MATNR PCKTYPE.

  CLEAR: GT_PCKSUM.
  LOOP AT GT_PDATA ASSIGNING FIELD-SYMBOL(<FS_P>).
*-구분(내수/수출) CHECK
    IF <FS_P>-PCKTYPE NE TEXT-T08 AND  "내수
       <FS_P>-PCKTYPE NE TEXT-T09.     "수출
      <FS_P>-UP_STAT = ICON_LED_RED.
      "구분 필드에 유효하지 않은 값이 입력되었습니다.(내수/수출)
      <FS_P>-UP_MSG  = TEXT-M07.

      CONTINUE.
    ENDIF.

    IF <FS_P>-PCKTYPE EQ TEXT-T08.
      <FS_P>-PCKCODE = GC_I.
    ELSEIF <FS_P>-PCKTYPE EQ TEXT-T09.
      <FS_P>-PCKCODE = GC_O.
    ENDIF.

*-자재코드 CHECK & 단위, 내역
    CLEAR: LV_MATNR.
    SELECT SINGLE A~MATNR, B~MEINS, C~MAKTX
      FROM            MARC AS A
     INNER JOIN       MARA AS B ON B~MATNR EQ A~MATNR
      LEFT OUTER JOIN MAKT AS C ON C~MATNR EQ A~MATNR
                               AND C~SPRAS EQ @SY-LANGU
     WHERE A~MATNR EQ @<FS_P>-MATNR
       AND A~WERKS EQ @P_WERKS
      INTO (@LV_MATNR, @<FS_P>-MEINS, @<FS_P>-MAKTX).

    IF LV_MATNR IS INITIAL.
      <FS_P>-UP_STAT = ICON_LED_RED.
      <FS_P>-UP_MSG  = TEXT-M08. "존재하지 않는 자재코드입니다.

      CONTINUE.
    ENDIF.

*-자재코드 중복 CHECK
    LOOP AT LT_PDATA INTO DATA(LS_PDATA) WHERE MATNR = <FS_P>-MATNR
                                           AND PCKTYPE = <FS_P>-PCKTYPE
      GROUP BY ( MATNR = LS_PDATA-MATNR
                 PCKTYPE = LS_PDATA-PCKTYPE
                 SIZE = GROUP SIZE )
      ASCENDING REFERENCE INTO DATA(GROUP_REF).

      CHECK GROUP_REF->*-SIZE > 1.

      <FS_P>-UP_STAT = ICON_LED_RED.

      CLEAR: LV_MATNR.
      LV_MATNR = <FS_P>-MATNR.
      PERFORM CONV_MATN1 USING    LV_MATNR GC_O
                         CHANGING LV_MATNR.

      "LV_MATNR 자재가 중복으로 업로드 되었습니다.
      <FS_P>-UP_MSG = LV_MATNR && TEXT-M09.

    ENDLOOP.

*-투입 수량 CHECK
    CLEAR: LV_LABST.
    SELECT SINGLE LABST
      FROM MARD
     WHERE MATNR EQ @<FS_P>-MATNR
       AND WERKS EQ @P_WERKS
       AND LGORT EQ @P_LGORT
      INTO @LV_LABST.

    IF LV_LABST LT <FS_P>-MENGE.
      <FS_P>-UP_STAT = ICON_LED_RED.
      "투입할 재고수량이 부족합니다.("LV_LABST")
      <FS_P>-UP_MSG = TEXT-M10 && |("| && LV_LABST && |")|.

      CONTINUE.
    ENDIF.

    IF <FS_P>-UP_STAT NE ICON_LED_RED.
      <FS_P>-UP_STAT = ICON_LED_GREEN.
    ENDIF.

    <FS_P>-REALMENGE = <FS_P>-MENGE.

*-구분별 SUM
    IF <FS_P>-PCKCODE IS NOT INITIAL.
      MOVE: <FS_P>-PCKCODE TO GS_PCKSUM-PCKCODE,
            <FS_P>-MENGE   TO GS_PCKSUM-SMENGE.
*            <FS_P>-MEINS   TO GS_PCKSUM-SMEINS.

      COLLECT GS_PCKSUM INTO GT_PCKSUM.
      CLEAR: GS_PCKSUM.
    ENDIF.
  ENDLOOP.

  SORT GT_PDATA BY PCKTYPE ASCENDING MENGE DESCENDING.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONV_MATN1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_PDATA_MATNR
*&      <-- GS_PDATA_MATNR
*&---------------------------------------------------------------------*
FORM CONV_MATN1  USING    PV_INPUT  TYPE ANY     PV_GUBUN
                 CHANGING PV_OUTPUT TYPE ANY.

  IF PV_GUBUN EQ GC_I.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT        = PV_INPUT
      IMPORTING
        OUTPUT       = PV_OUTPUT
      EXCEPTIONS
        LENGTH_ERROR = 1
        OTHERS       = 2.

  ELSEIF PV_GUBUN EQ GC_O.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = PV_INPUT
      IMPORTING
        OUTPUT = PV_OUTPUT.

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
         GT_FIELDCAT_0101[], GS_LAYOUT_0101, GT_EXCLUDE_0101[],
         GT_EXCLUDE_0101, GV_OK_CODE, GV_DBCNT,
         GT_PDATA[], GT_CDATA[], GT_BOTTOM[], GT_REVDATA[],
         GT_CRDATA[], GT_CREVDATA[].

  CALL METHOD GO_DOCKING_CONTAINER->FREE.
  FREE: GO_DOCKING_CONTAINER, GO_SPLITTER.
  FREE: GO_CONTAIN_0100, GO_CONTAIN_0101, GO_CONTAIN_TOP_0100.
  FREE: GO_GRID_0100, GO_GRID_0101.
  CLEAR : GO_DOCKING_CONTAINER, GO_GRID_0100, GO_GRID_0101.
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
      ROWS    = 3
      COLUMNS = 1.

  GO_SPLITTER->SET_ROW_HEIGHT(
    EXPORTING
      ID = 1
      HEIGHT = 5 ).

* HEADER 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_TOP_0100.
* top 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0100.
* bottom 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 3
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0101.

  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.

  IF ( P_R1 EQ GC_X AND P_RC EQ GC_X ) OR
       P_R2 EQ GC_X.
    GO_SPLITTER->SET_ROW_HEIGHT(
      EXPORTING
        ID = 3
        HEIGHT = 0 ).
  ENDIF.

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
  GS_LAYOUT_0100-CWIDTH_OPT = GC_X.
  GS_LAYOUT_0100-NO_ROWINS  = GC_X.
  IF P_R2 EQ GC_X.
    GS_LAYOUT_0100-SEL_MODE   = GC_D.
  ENDIF.
*  GS_LAYOUT_0100-STYLEFNAME = 'CELLTAB'.
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
  IF P_R1 EQ GC_X.
    IF P_RP EQ GC_X.
      PERFORM SET_FIELDCAT_P.
    ELSEIF P_RC EQ GC_X.
      PERFORM SET_FIELDCAT_C.
    ENDIF.
  ELSEIF P_R2 EQ GC_X.
    IF P_RP EQ GC_X.
      PERFORM SET_FIELDCAT_REV.
    ELSEIF P_RC EQ GC_X.
      PERFORM SET_FIELDCAT_REV_C.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_P
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_P .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR4060TOP'
      I_INTERNAL_TABNAME     = 'GS_PDATA'
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
      IT_DATA         = GT_PDATA
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'UP_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "처리상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
      WHEN 'UP_MSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "처리메시지
        <LS_FCAT>-JUST = GC_L.
      WHEN 'ZGINO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "투입이력번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "자재코드
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "자재내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'PCKTYPE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "구분
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "투입수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "수량단위
        <LS_FCAT>-JUST = GC_C.
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

*// Event Handler ##
  CASE PO_GRID.
    WHEN GO_GRID_0100.
      SET HANDLER GO_EVTR_0100->HDL_TOP_OF_PAGE           FOR PO_GRID.
      SET HANDLER GO_EVTR_0100->HDL_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVTR_0100->HDL_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVTR_0100->HDL_DOUBLE_CLICK          FOR PO_GRID.
    WHEN GO_GRID_0101.
      SET HANDLER GO_EVTR_0100->HDL_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVTR_0100->HDL_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVTR_0100->HDL_DOUBLE_CLICK          FOR PO_GRID.
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
  IF P_R1 EQ GC_X.
    IF P_RP EQ GC_X.
      CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
        EXPORTING
          IS_LAYOUT            = GS_LAYOUT_0100
          IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
        CHANGING
          IT_OUTTAB            = GT_PDATA
          IT_FIELDCATALOG      = GT_FIELDCAT_0100.
    ELSEIF P_RC EQ GC_X.
      CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
        EXPORTING
          IS_LAYOUT            = GS_LAYOUT_0100
          IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
        CHANGING
          IT_OUTTAB            = GT_CDATA
          IT_FIELDCATALOG      = GT_FIELDCAT_0100.
    ENDIF.

  ELSEIF P_R2 EQ GC_X.
    IF P_RP EQ GC_X.
      CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
        EXPORTING
          IS_LAYOUT            = GS_LAYOUT_0100
          IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
        CHANGING
          IT_OUTTAB            = GT_REVDATA
          IT_FIELDCATALOG      = GT_FIELDCAT_0100.
    ELSEIF P_RC EQ GC_X.
      CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
        EXPORTING
          IS_LAYOUT            = GS_LAYOUT_0100
          IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
        CHANGING
          IT_OUTTAB            = GT_CREVDATA
          IT_FIELDCATALOG      = GT_FIELDCAT_0100.
    ENDIF.
  ENDIF.

  IF GO_DD_DOCU_0100 IS BOUND.
    CALL METHOD GO_DD_DOCU_0100->INITIALIZE_DOCUMENT.
  ELSE.
    CREATE OBJECT GO_DD_DOCU_0100
      EXPORTING
        STYLE = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
  ENDIF.

  CALL METHOD GO_GRID_0100->LIST_PROCESSING_EVENTS
    EXPORTING
      I_EVENT_NAME = 'TOP_OF_PAGE'
      I_DYNDOC_ID  = GO_DD_DOCU_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_OBJECT_>MT_TOOLBAR
*&      --> P_
*&      --> ICON_CREATE
*&      --> P_
*&      --> P_
*&      --> SPACE
*&      --> P_0
*&---------------------------------------------------------------------*
FORM SET_TOOLBAR  TABLES   PT_TOOLBAR STRUCTURE STB_BUTTON
                  USING    PV_FUNCTION
                           PV_ICON
                           PV_TEXT
                           PV_QUICKINFO
                           PV_DISABLED
                           PV_BUTN_TYPE.

  DATA : LS_TOOLBAR  TYPE STB_BUTTON.

  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-FUNCTION  = PV_FUNCTION.
  LS_TOOLBAR-ICON      = PV_ICON.
  IF PV_TEXT IS NOT INITIAL.
    CONCATENATE '　' PV_TEXT '　' INTO LS_TOOLBAR-TEXT SEPARATED BY SPACE.
  ENDIF.
  LS_TOOLBAR-DISABLED = PV_DISABLED.
  LS_TOOLBAR-QUICKINFO = PV_QUICKINFO.
  LS_TOOLBAR-BUTN_TYPE = PV_BUTN_TYPE.
  APPEND LS_TOOLBAR TO PT_TOOLBAR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_P
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_P .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  CLEAR: L_ANSWER.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T10 "실적 추출 및 수량 할당
      "프로젝트별 조립실적 추출 및 포장재 수량을 할당하시겠습니까? 추출한 데이터가 저장됩니다.
      TEXT_QUESTION         = TEXT-T11
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.

    PERFORM INIT_DATA.

    PERFORM GET_ZGINO.

    CLEAR: GT_BOTTOM.
    PERFORM SET_DATA_ASSIGNMENT_I.
    PERFORM SET_DATA_ASSIGNMENT_O.

    IF GT_BOTTOM IS NOT INITIAL.
      PERFORM MODIFY_DATA_ASSIGNMENT.

*실적 추출 및 수량 할당 결과 저장
      PERFORM SAVE_ZGTPPT4020_4030.
    ENDIF.

    PERFORM SET_BOTTOM_ALV.

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
*& Form GET_DATA_AS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_AS .

  CLEAR: GT_AS.
  SELECT DISTINCT
         A~AUFNR, A~MENGE, A~MEINS, A~MBLNR, A~ZEILE, A~MJAHR,
         B~KDAUF, B~KDPOS,
         C~ZPJNO,
         D~LAND1,
         E~JOB_NO,
         F~MTART
    FROM      MATDOC     AS A
   INNER JOIN AFPO       AS B ON B~AUFNR EQ A~AUFNR
   INNER JOIN VBAK       AS C ON C~VBELN EQ B~KDAUF
   INNER JOIN ZSD0106T   AS D ON D~ZPJNO EQ C~ZPJNO
   INNER JOIN ZGTPPT3160 AS E ON E~AUFNR EQ A~AUFNR
   INNER JOIN MARA       AS F ON F~MATNR EQ A~MATNR
   WHERE A~WERKS EQ @P_WERKS
     AND A~YEARMONTH_BUDAT EQ @P_SPMON
     AND A~BWART EQ @GC_101
     AND A~CANCELLED EQ @SPACE
     AND A~AUFNR NE @SPACE
     AND A~MENGE GT 0
     AND F~MTART EQ @GC_FERT
    INTO CORRESPONDING FIELDS OF TABLE @GT_AS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA_AS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA_AS .

  DATA: LV_AS_QTY_S TYPE MENG15,
        LV_DIFF     TYPE MENG15.

  LOOP AT GT_AS ASSIGNING FIELD-SYMBOL(<FS_AS>).
    IF <FS_AS>-LAND1 EQ 'KR'.
      <FS_AS>-PCKCODE = GC_I.
    ELSE.
      <FS_AS>-PCKCODE = GC_O.
    ENDIF.
  ENDLOOP.

  SORT GT_AS BY PCKCODE ZPJNO JOB_NO AUFNR.

*-구분/프로젝트 SUM & 구분/프로젝트/오더 SUM & 구분별 SUM
  CLEAR: GT_ZPJNOSUMI, GT_ZPJNOSUMO, GT_AUFNRSUMI, GT_AUFNRSUMO,
         GT_ZPJNOSUM.

  LOOP AT GT_AS INTO GS_AS.
    MOVE-CORRESPONDING GS_AS TO GS_ZPJNOSUM.
    MOVE-CORRESPONDING GS_AS TO GS_AUFNRSUM.
    MOVE-CORRESPONDING GS_AS TO GS_PCKSUM.
    MOVE: GS_AS-MENGE TO GS_ZPJNOSUM-SMENGE,
          GS_AS-MENGE TO GS_AUFNRSUM-SMENGE,
          GS_AS-MENGE TO GS_PCKSUM-SMENGE,
          GS_AS-MEINS TO GS_ZPJNOSUM-SMEINS,
          GS_AS-MEINS TO GS_AUFNRSUM-SMEINS.
*          GS_AS-MEINS TO GS_PCKSUM-SMEINS.

    IF GS_AS-PCKCODE EQ GC_I.
      COLLECT GS_ZPJNOSUM INTO GT_ZPJNOSUMI.
      COLLECT GS_AUFNRSUM INTO GT_AUFNRSUMI.
    ELSEIF GS_AS-PCKCODE EQ GC_O.
      COLLECT GS_ZPJNOSUM INTO GT_ZPJNOSUMO.
      COLLECT GS_AUFNRSUM INTO GT_AUFNRSUMO.
    ENDIF.

*-구분별 조립 실적 수량 SUM
    COLLECT GS_PCKSUM INTO GT_ZPJNOSUM.

    CLEAR: GS_AS, GS_ZPJNOSUM, GS_AUFNRSUM, GS_PCKSUM.

  ENDLOOP.

  SORT: GT_ZPJNOSUMI BY SMENGE DESCENDING,
        GT_ZPJNOSUMO BY SMENGE DESCENDING,
        GT_AUFNRSUMI BY ZPJNO ASCENDING SMENGE DESCENDING,
        GT_AUFNRSUMO BY ZPJNO ASCENDING SMENGE DESCENDING.

*-할당수량(내수)
  CLEAR: LV_AS_QTY_S.
  LOOP AT GT_ZPJNOSUMI ASSIGNING FIELD-SYMBOL(<FS_I>).
    READ TABLE GT_PCKSUM   INTO DATA(LS_PCK) WITH KEY PCKCODE = GC_I.
    READ TABLE GT_ZPJNOSUM INTO DATA(LS_ZPJNO) WITH KEY PCKCODE = GC_I.

    <FS_I>-AS_QTY = LS_PCK-SMENGE * ( <FS_I>-SMENGE / LS_ZPJNO-SMENGE ).
    CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
      EXPORTING
        I_RTYPE     = ' '
        I_RUNIT     = '1'
        I_VALUE     = <FS_I>-AS_QTY
      IMPORTING
        E_VALUE_RND = <FS_I>-AS_QTY.

    ADD <FS_I>-AS_QTY TO LV_AS_QTY_S.

    CLEAR: LS_PCK, LS_ZPJNO.
  ENDLOOP.

*-할당수량 조정
  IF LV_AS_QTY_S NE 0.
    READ TABLE GT_PCKSUM INTO LS_PCK WITH KEY PCKCODE = GC_I.
    IF LV_AS_QTY_S NE LS_PCK-SMENGE.
      CLEAR: LV_DIFF.
      LV_DIFF = LV_AS_QTY_S - LS_PCK-SMENGE.

      READ TABLE GT_ZPJNOSUMI ASSIGNING <FS_I> INDEX 1.
      IF <FS_I> IS ASSIGNED.
        <FS_I>-AS_QTY = <FS_I>-AS_QTY - LV_DIFF.
      ENDIF.
    ENDIF.
  ENDIF.

*-할당수량(수출)
  CLEAR: LV_AS_QTY_S.
  LOOP AT GT_ZPJNOSUMO ASSIGNING FIELD-SYMBOL(<FS_O>).
    READ TABLE GT_PCKSUM   INTO LS_PCK WITH KEY PCKCODE = GC_O.
    READ TABLE GT_ZPJNOSUM INTO LS_ZPJNO WITH KEY PCKCODE = GC_O.

    <FS_O>-AS_QTY = LS_PCK-SMENGE * ( <FS_O>-SMENGE / LS_ZPJNO-SMENGE ).
    CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
      EXPORTING
        I_RTYPE     = ' '
        I_RUNIT     = '1'
        I_VALUE     = <FS_O>-AS_QTY
      IMPORTING
        E_VALUE_RND = <FS_O>-AS_QTY.

    ADD <FS_O>-AS_QTY TO LV_AS_QTY_S.

    CLEAR: LS_PCK, LS_ZPJNO.
  ENDLOOP.

*-할당수량 조정
  IF LV_AS_QTY_S NE 0.
    READ TABLE GT_PCKSUM INTO LS_PCK WITH KEY PCKCODE = GC_O.
    IF LV_AS_QTY_S NE LS_PCK-SMENGE.
      CLEAR: LV_DIFF.
      LV_DIFF = LV_AS_QTY_S - LS_PCK-SMENGE.

      READ TABLE GT_ZPJNOSUMO ASSIGNING <FS_O> INDEX 1.
      IF <FS_O> IS ASSIGNED.
        <FS_O>-AS_QTY = <FS_O>-AS_QTY - LV_DIFF.
      ENDIF.
    ENDIF.
  ENDIF.

  LOOP AT GT_ZPJNOSUMI ASSIGNING <FS_I>.
    <FS_I>-REALASQTY = <FS_I>-AS_QTY.
  ENDLOOP.

  LOOP AT GT_ZPJNOSUMO ASSIGNING <FS_O>.
    <FS_O>-REALASQTY = <FS_O>-AS_QTY.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATA_assignment_I
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DATA_ASSIGNMENT_I .

  SORT GT_PDATA BY PCKCODE ASCENDING MENGE DESCENDING.
  SORT GT_AUFNRSUMI BY ZPJNO AUFNR.

  LOOP AT GT_ZPJNOSUMI ASSIGNING FIELD-SYMBOL(<FS_ZPJNOI>) WHERE REALASQTY NE 0.
    MOVE: <FS_ZPJNOI>-PCKCODE TO GS_BOTTOM-PCKCODE,
          <FS_ZPJNOI>-ZPJNO   TO GS_BOTTOM-ZPJNO,
          <FS_ZPJNOI>-SMENGE  TO GS_BOTTOM-TOT_QTY,
          <FS_ZPJNOI>-SMEINS  TO GS_BOTTOM-TOT_UNIT,
          <FS_ZPJNOI>-AS_QTY  TO GS_BOTTOM-AS_QTY.

    LOOP AT GT_PDATA ASSIGNING FIELD-SYMBOL(<FS_PDATA>) WHERE PCKCODE EQ GC_I
                                                          AND REALMENGE NE 0.
      MOVE: <FS_PDATA>-MATNR TO GS_BOTTOM-MATNR,
            <FS_PDATA>-MAKTX TO GS_BOTTOM-MAKTX,
            <FS_PDATA>-MEINS TO GS_BOTTOM-GI_UNIT,
            '1'              TO GS_BOTTOM-GI_QTY,
            <FS_PDATA>-MEINS TO GS_BOTTOM-AS_UNIT.

      LOOP AT GT_AUFNRSUMI ASSIGNING FIELD-SYMBOL(<FS_AUFNRI>) WHERE ZPJNO EQ <FS_ZPJNOI>-ZPJNO
                                                                 AND CHK NE GC_X.
        MOVE: <FS_AUFNRI>-AUFNR  TO GS_BOTTOM-AUFNR,
              <FS_AUFNRI>-SMENGE TO GS_BOTTOM-GR_QTY,
              <FS_AUFNRI>-SMEINS TO GS_BOTTOM-GR_UNIT.

        <FS_AUFNRI>-CHK = GC_X.

        APPEND GS_BOTTOM TO GT_BOTTOM.

*        <FS_ZPJNOI>-REALASQTY = <FS_ZPJNOI>-REALASQTY - 1.  "프로젝트 할당량 CNT

        <FS_PDATA>-REALMENGE = <FS_PDATA>-REALMENGE - 1.    "자재 입고량 CNT

*        IF <FS_ZPJNOI>-REALASQTY EQ 0.  "프로젝트 할당량 CHK
*          EXIT.
*        ENDIF.

        IF <FS_PDATA>-REALMENGE EQ 0.   "자재 입고량 CHK
          EXIT.
        ENDIF.

      ENDLOOP.

*      IF <FS_ZPJNOI>-REALASQTY EQ 0.  "프로젝트 할당량 CHK
*        EXIT.
*      ENDIF.

    ENDLOOP.

    CLEAR: GS_BOTTOM.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATA_ASSIGNMENT_O
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DATA_ASSIGNMENT_O .

  SORT GT_PDATA BY PCKCODE ASCENDING MENGE DESCENDING.
  SORT GT_AUFNRSUMO BY ZPJNO AUFNR.
  LOOP AT GT_ZPJNOSUMO ASSIGNING FIELD-SYMBOL(<FS_ZPJNOO>) WHERE REALASQTY NE 0.
    MOVE: <FS_ZPJNOO>-PCKCODE TO GS_BOTTOM-PCKCODE,
          <FS_ZPJNOO>-ZPJNO   TO GS_BOTTOM-ZPJNO,
          <FS_ZPJNOO>-SMENGE  TO GS_BOTTOM-TOT_QTY,
          <FS_ZPJNOO>-SMEINS  TO GS_BOTTOM-TOT_UNIT,
          <FS_ZPJNOO>-AS_QTY  TO GS_BOTTOM-AS_QTY.

    LOOP AT GT_PDATA ASSIGNING FIELD-SYMBOL(<FS_PDATA>) WHERE PCKCODE EQ GC_O
                                                          AND REALMENGE NE 0.
      MOVE: <FS_PDATA>-MATNR TO GS_BOTTOM-MATNR,
            <FS_PDATA>-MAKTX TO GS_BOTTOM-MAKTX,
            <FS_PDATA>-MEINS TO GS_BOTTOM-GI_UNIT,
            '1'              TO GS_BOTTOM-GI_QTY,
            <FS_PDATA>-MEINS TO GS_BOTTOM-AS_UNIT.

      LOOP AT GT_AUFNRSUMO ASSIGNING FIELD-SYMBOL(<FS_AUFNRO>) WHERE ZPJNO EQ <FS_ZPJNOO>-ZPJNO
                                                                 AND CHK NE GC_X.
        MOVE: <FS_AUFNRO>-AUFNR  TO GS_BOTTOM-AUFNR,
              <FS_AUFNRO>-SMENGE TO GS_BOTTOM-GR_QTY,
              <FS_AUFNRO>-SMEINS TO GS_BOTTOM-GR_UNIT.

        <FS_AUFNRO>-CHK = GC_X.

        APPEND GS_BOTTOM TO GT_BOTTOM.

*        <FS_ZPJNOO>-REALASQTY = <FS_ZPJNOO>-REALASQTY - 1.  "프로젝트 할당량 CNT

        <FS_PDATA>-REALMENGE = <FS_PDATA>-REALMENGE - 1.    "자재 입고량 CNT

*        IF <FS_ZPJNOO>-REALASQTY EQ 0.  "프로젝트 할당량 CHK
*          EXIT.
*        ENDIF.

        IF <FS_PDATA>-REALMENGE EQ 0.   "자재 입고량 CHK
          EXIT.
        ENDIF.

      ENDLOOP.

*      IF <FS_ZPJNOO>-REALASQTY EQ 0.  "프로젝트 할당량 CHK
*        EXIT.
*      ENDIF.


    ENDLOOP.

    CLEAR: GS_BOTTOM.
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
    PERFORM SET_EVENT_GRID_0100 USING GO_GRID_0101.
    PERFORM CALL_GRID_0101_DISPLAY.
    PERFORM REF_ALV_RTN USING GO_GRID_0100.
  ELSE.
    PERFORM REF_ALV_RTN USING GO_GRID_0101.
    PERFORM REF_ALV_RTN USING GO_GRID_0100.
  ENDIF.
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
    WHEN GO_GRID_0100.
      CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
        EXPORTING
          IS_LAYOUT = GS_LAYOUT_0100.

    WHEN GO_GRID_0101.
      CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
        EXPORTING
          IS_LAYOUT = GS_LAYOUT_0101.

  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

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
*  GS_LAYOUT_0101-ZEBRA      = GC_X.
  GS_LAYOUT_0101-COL_OPT    = GC_X.
  GS_LAYOUT_0101-CWIDTH_OPT = GC_X.
  GS_LAYOUT_0101-SEL_MODE   = GC_D.
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
  IF P_R1 EQ GC_X.
    IF P_RP EQ GC_X.
      PERFORM SET_FIELDCAT_0101.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_0101 .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR4060TOP'
      I_INTERNAL_TABNAME     = 'GS_BOTTOM'
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
      IT_DATA         = GT_BOTTOM
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0101 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'GI_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "투입처리상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'GI_MSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "투입처리메시지
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'ZGINO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "투입이력번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'PCKTYPE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "구분
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'ZPJNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "프로젝트번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'ZPTXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "프로젝트내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'TOT_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F13. "조립실적수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'TOT_UNIT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "실적수량단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'AS_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "할당수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'AS_UNIT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "할당수량단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "생산오더번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'GR_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "생산입고수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'GR_UNIT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "생산입고단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "자재코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "자재내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'GI_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "투입수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'GI_UNIT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "투입수량단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'MBLNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "자재문서번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'MJAHR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "자재문서연도
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
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
  IF P_R1 EQ GC_X.
*    IF P_RP EQ GC_X.
    CALL METHOD GO_GRID_0101->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT            = GS_LAYOUT_0101
        IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0101
      CHANGING
        IT_OUTTAB            = GT_BOTTOM
        IT_FIELDCATALOG      = GT_FIELDCAT_0101.
*    ELSEIF P_RC EQ GC_X.
*      CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
*        EXPORTING
*          IS_LAYOUT            = GS_LAYOUT_0101
*          IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0101
*        CHANGING
*          IT_OUTTAB            = GT_BOTTOM
*          IT_FIELDCATALOG      = GT_FIELDCAT_0101.
*    ENDIF.

  ELSEIF P_R2 EQ GC_X.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA_ASSIGNMENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA_ASSIGNMENT .

  LOOP AT GT_BOTTOM ASSIGNING FIELD-SYMBOL(<FS_B>).
    <FS_B>-GI_STAT = ICON_LED_INACTIVE.
    <FS_B>-ZGINO = GV_ZGINO.

    IF <FS_B>-PCKCODE EQ GC_I.
      <FS_B>-PCKTYPE = TEXT-T08.
    ELSEIF <FS_B>-PCKCODE EQ GC_O.
      <FS_B>-PCKTYPE = TEXT-T09.
    ENDIF.

    SELECT SINGLE ZPTXT
      FROM ZSD0106T
     WHERE ZPJNO EQ @<FS_B>-ZPJNO
      INTO @<FS_B>-ZPTXT.

*-자재내역
    SELECT SINGLE MAKTX
      FROM MAKT
     WHERE MATNR EQ @<FS_B>-MATNR
       AND SPRAS EQ @SY-LANGU
      INTO @<FS_B>-MAKTX.

  ENDLOOP.

*-상단 화면 투입 이력번호 UPDATE
  LOOP AT GT_PDATA ASSIGNING FIELD-SYMBOL(<FS>).
    <FS>-ZGINO = GV_ZGINO.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ZGINO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ZGINO .

  DATA: LV_ZGINO LIKE ZGTPPT4020-ZGINO.

  CLEAR: LV_ZGINO, GV_ZGINO, GV_SEQ.

  IF P_R1 EQ GC_X.
    IF P_RP EQ GC_X.
      SELECT MAX( ZGINO )
        FROM ZGTPPT4020
       WHERE ZCAT  EQ @GV_ZCAT
         AND SPMON EQ @P_SPMON
        INTO @LV_ZGINO.

      IF LV_ZGINO IS INITIAL.
        GV_SEQ = '00001'.
      ELSE.
        GV_SEQ = LV_ZGINO+7(5) + 1.
      ENDIF.

      GV_ZGINO = GV_ZCAT && P_SPMON && GV_SEQ.

    ELSEIF P_RC EQ GC_X.
      SELECT MAX( ZGINO )
        FROM ZGTPPT4040
       WHERE ZCAT  EQ @GV_ZCAT
         AND SPMON EQ @P_SPMON
        INTO @LV_ZGINO.

      IF LV_ZGINO IS INITIAL.
        GV_SEQ = '00001'.
      ELSE.
        GV_SEQ = LV_ZGINO+7(5) + 1.
      ENDIF.

      GV_ZGINO = GV_ZCAT && P_SPMON && GV_SEQ.

    ENDIF.
  ENDIF.

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

  LOOP AT GT_PDATA ASSIGNING FIELD-SYMBOL(<FS>).
    <FS>-REALMENGE = <FS>-MENGE.
  ENDLOOP.

  LOOP AT GT_ZPJNOSUMI ASSIGNING FIELD-SYMBOL(<FS_I>).
    <FS_I>-REALASQTY = <FS_I>-AS_QTY.
  ENDLOOP.

  LOOP AT GT_ZPJNOSUMO ASSIGNING FIELD-SYMBOL(<FS_O>).
    <FS_O>-REALASQTY = <FS_O>-AS_QTY.
  ENDLOOP.

  CLEAR: GS_AUFNRSUM.
  MODIFY GT_AUFNRSUMI FROM GS_AUFNRSUM TRANSPORTING CHK WHERE CHK = 'X'.
  MODIFY GT_AUFNRSUMO FROM GS_AUFNRSUM TRANSPORTING CHK WHERE CHK = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZGTPPT4020_4030
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_ZGTPPT4020_4030 .

  DATA: LT_ZGTPPT4020 LIKE TABLE OF ZGTPPT4020.
  DATA: LS_ZGTPPT4020 LIKE ZGTPPT4020.
  DATA: LT_ZGTPPT4030 LIKE TABLE OF ZGTPPT4030.
  DATA: LS_ZGTPPT4030 LIKE ZGTPPT4030.

  DATA: LS_BTM LIKE GS_BOTTOM.

  CLEAR: LT_ZGTPPT4020, LT_ZGTPPT4030.

  LOOP AT GT_PDATA INTO DATA(LS_PDATA).
    MOVE: GV_ZGINO         TO LS_ZGTPPT4020-ZGINO,
          LS_PDATA-MATNR   TO LS_ZGTPPT4020-MATNR,
          GV_ZCAT          TO LS_ZGTPPT4020-ZCAT,
          P_WERKS          TO LS_ZGTPPT4020-WERKS,
          P_LGORT          TO LS_ZGTPPT4020-LGORT,
          P_SPMON          TO LS_ZGTPPT4020-SPMON,
          LS_PDATA-PCKTYPE TO LS_ZGTPPT4020-PCKTYPE,
          LS_PDATA-MENGE   TO LS_ZGTPPT4020-MENGE,
          LS_PDATA-MEINS   TO LS_ZGTPPT4020-MEINS,
          SY-DATUM         TO LS_ZGTPPT4020-CRDAT,
          SY-UZEIT         TO LS_ZGTPPT4020-CRTIM,
          SY-UNAME         TO LS_ZGTPPT4020-CRNAM.

    APPEND LS_ZGTPPT4020 TO LT_ZGTPPT4020.
    CLEAR: LS_ZGTPPT4020.
  ENDLOOP.

  LOOP AT GT_BOTTOM INTO LS_BTM.
    MOVE: GV_ZCAT         TO LS_ZGTPPT4030-ZCAT,
          GV_ZGINO        TO LS_ZGTPPT4030-ZGINO,
          LS_BTM-ZPJNO    TO LS_ZGTPPT4030-ZPJNO,
          LS_BTM-AUFNR    TO LS_ZGTPPT4030-AUFNR,
          LS_BTM-TOT_QTY  TO LS_ZGTPPT4030-TOT_QTY,
          LS_BTM-TOT_UNIT TO LS_ZGTPPT4030-TOT_UNIT,
          LS_BTM-AS_QTY   TO LS_ZGTPPT4030-AS_QTY,
          LS_BTM-AS_UNIT  TO LS_ZGTPPT4030-AS_UNIT,
          LS_BTM-GR_QTY   TO LS_ZGTPPT4030-GR_QTY,
          LS_BTM-GR_UNIT  TO LS_ZGTPPT4030-GR_UNIT,
          LS_BTM-MATNR    TO LS_ZGTPPT4030-MATNR,
          LS_BTM-GI_QTY   TO LS_ZGTPPT4030-GI_QTY,
          LS_BTM-GI_UNIT  TO LS_ZGTPPT4030-GI_UNIT,
          SY-DATUM        TO LS_ZGTPPT4030-CRDAT,
          SY-UZEIT        TO LS_ZGTPPT4030-CRTIM,
          SY-UNAME        TO LS_ZGTPPT4030-CRNAM.

    APPEND LS_ZGTPPT4030 TO LT_ZGTPPT4030.
    CLEAR: LS_ZGTPPT4030, LS_BTM.
  ENDLOOP.

  MODIFY ZGTPPT4020 FROM TABLE LT_ZGTPPT4020.
  MODIFY ZGTPPT4030 FROM TABLE LT_ZGTPPT4030.
  IF SY-SUBRC EQ 0.
    COMMIT WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_GI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_GI .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_B> LIKE GS_BOTTOM.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0101.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M11. "실행할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T12 "포장재 투입 처리
      TEXT_QUESTION         = TEXT-T13 "선택하신 레코드의 포장재 투입 처리를 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_BOTTOM ASSIGNING <FS_B> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_B>-GI_STAT EQ ICON_LED_GREEN.
        <FS_B>-GI_MSG = TEXT-M12. "이미 투입이 처리된 레코드입니다.
      ELSE.
        PERFORM EXEC_MAT_GI USING <FS_B>.
      ENDIF.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0101.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_MAT_GI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_P>
*&---------------------------------------------------------------------*
FORM EXEC_MAT_GI  USING    P_LINE LIKE GS_BOTTOM.

  DATA: LS_HEADER    TYPE BAPI2017_GM_HEAD_01,
        LT_ITEM      TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LV_CODE      TYPE BAPI2017_GM_CODE VALUE '03',
        LV_DOCUMENT  TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_YEAR      TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LS_GMHEADRET LIKE BAPI2017_GM_HEAD_RET,
        LT_RETURN    TYPE TABLE OF BAPIRET2.

  DATA: LV_ZSTAT LIKE ZGTPPT4030-ZSTAT.

  CLEAR: LS_HEADER, LT_ITEM.

  LS_HEADER = VALUE #( PSTNG_DATE = GV_BUDAT        "조회조건 대상월의 말일
                       DOC_DATE   = GV_BUDAT
                       PR_UNAME   = SY-UNAME
                       HEADER_TXT = GC_ZGTPPR4060 ).

  LT_ITEM = VALUE #( ( MATERIAL       = P_LINE-MATNR
                       PLANT          = P_WERKS
                       STGE_LOC       = P_LGORT
                       BATCH          = SPACE
                       MOVE_TYPE      = GC_261
                       STCK_TYPE      = GC_F
                       ENTRY_QNT      = P_LINE-GI_QTY
                       ENTRY_UOM      = P_LINE-GI_UNIT
                       ORDERID        = P_LINE-AUFNR ) ).

  CLEAR: LV_DOCUMENT, LV_YEAR, LS_GMHEADRET, LT_RETURN, LV_ZSTAT.
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
    P_LINE-GI_MSG = LS_RETURN-MESSAGE.
    P_LINE-GI_STAT = ICON_LED_RED.
    LV_ZSTAT = GC_E.

    CLEAR: LS_RETURN.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = GC_X.

    P_LINE-GI_STAT = ICON_LED_GREEN.
    P_LINE-GI_MSG = TEXT-M13. "자재 투입 처리에 성공하였습니다.
    P_LINE-MBLNR = LV_DOCUMENT.
    P_LINE-MJAHR = LV_YEAR.
    LV_ZSTAT = GC_S.

    WAIT UP TO '0.5' SECONDS.
  ENDIF.

  UPDATE ZGTPPT4030 SET ZSTAT = LV_ZSTAT
                        ZMSG  = P_LINE-GI_MSG
                        MBLNR = P_LINE-MBLNR
                        MJAHR = P_LINE-MJAHR
                  WHERE ZCAT  = GV_ZCAT
                    AND ZGINO = P_LINE-ZGINO
                    AND ZPJNO = P_LINE-ZPJNO
                    AND AUFNR = P_LINE-AUFNR.

  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_RESULT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_RESULT .

  CLEAR: GT_REVDATA.

  SELECT A~PCKTYPE,
         B~ZGINO, B~ZPJNO,
         B~AUFNR, B~TOT_QTY, B~TOT_UNIT, B~AS_QTY, B~AS_UNIT,
         B~GR_QTY, B~GR_UNIT, B~MATNR, B~GI_QTY, B~GI_UNIT,
         B~ZSTAT, B~ZMSG, B~MBLNR, B~MJAHR,
         B~CRDAT, B~CRTIM, B~CRNAM,
         C~ZPTXT,
         D~MAKTX
    FROM            ZGTPPT4020 AS A
   INNER JOIN       ZGTPPT4030 AS B ON B~ZCAT EQ A~ZCAT
                                   AND B~ZGINO EQ A~ZGINO
                                   AND B~MATNR EQ A~MATNR
    LEFT OUTER JOIN ZSD0106T   AS C ON C~ZPJNO EQ B~ZPJNO
    LEFT OUTER JOIN MAKT       AS D ON D~MATNR EQ B~MATNR
                                   AND D~SPRAS EQ @SY-LANGU
   WHERE A~WERKS EQ @P_WERKS
     AND A~SPMON EQ @P_SPMON
     AND A~ZGINO IN @S_ZGINO
     AND A~MATNR IN @S_MATNR
     AND A~CRDAT IN @S_CRDAT
     AND B~AUFNR IN @S_AUFNR
     AND B~MBLNR IN @S_MBLNR
     AND B~ZCAT  EQ @GV_ZCAT
    INTO CORRESPONDING FIELDS OF TABLE @GT_REVDATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_REV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_REV .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR4060TOP'
      I_INTERNAL_TABNAME     = 'GS_REVDATA'
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
      IT_DATA         = GT_REVDATA
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'GI_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "투입처리상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'ZMSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "투입처리메시지
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'ZGINO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "투입이력번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'PCKTYPE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "구분
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'ZPJNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "프로젝트번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'ZPTXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "프로젝트내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'TOT_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F13. "조립실적수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'TOT_UNIT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "실적수량단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'AS_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "할당수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'AS_UNIT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "할당수량단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "생산오더번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'GR_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "생산입고수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'GR_UNIT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "생산입고단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "자재코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "자재내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'GI_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "투입수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'GI_UNIT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "투입수량단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'MBLNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "자재문서번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'MJAHR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "자재문서연도
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'CRDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F23. "생성일자
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C710'.
      WHEN 'CRTIM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F24. "생성시간
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C710'.
      WHEN 'CRNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F25. "생성자ID
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C710'.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

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

  FIELD-SYMBOLS: <FS_R> LIKE GS_REVDATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M14. "투입 처리를 수행할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T12 "포장재 투입 처리
      TEXT_QUESTION         = TEXT-T13 "선택하신 레코드의 포장재 투입 처리를 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_REVDATA ASSIGNING <FS_R> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_R>-GI_STAT EQ ICON_LED_GREEN.
        <FS_R>-ZMSG = TEXT-M15. "이미 투입 처리된 레코드가 선택되었습니다.
      ELSE.
        PERFORM EXEC_MAT_REGI USING <FS_R>.
      ENDIF.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_MAT_REGI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_R>
*&---------------------------------------------------------------------*
FORM EXEC_MAT_REGI  USING    P_LINE LIKE GS_REVDATA.

  DATA: LS_HEADER    TYPE BAPI2017_GM_HEAD_01,
        LT_ITEM      TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LV_CODE      TYPE BAPI2017_GM_CODE VALUE '03',
        LV_DOCUMENT  TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_YEAR      TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LS_GMHEADRET LIKE BAPI2017_GM_HEAD_RET,
        LT_RETURN    TYPE TABLE OF BAPIRET2.

  CLEAR: LS_HEADER, LT_ITEM.

  LS_HEADER = VALUE #( PSTNG_DATE = GV_BUDAT        "조회조건 대상월의 말일
                       DOC_DATE   = GV_BUDAT
                       PR_UNAME   = SY-UNAME
                       HEADER_TXT = GC_ZGTPPR4060 ).

  LT_ITEM = VALUE #( ( MATERIAL       = P_LINE-MATNR
                       PLANT          = P_WERKS
                       STGE_LOC       = P_LGORT
                       BATCH          = SPACE
                       MOVE_TYPE      = GC_261
                       STCK_TYPE      = GC_F
                       ENTRY_QNT      = P_LINE-GI_QTY
                       ENTRY_UOM      = P_LINE-GI_UNIT
                       ORDERID        = P_LINE-AUFNR ) ).

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
    P_LINE-ZMSG = LS_RETURN-MESSAGE.
    P_LINE-GI_STAT = ICON_LED_RED.
    P_LINE-ZSTAT = GC_E.

    CLEAR: LS_RETURN.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = GC_X.

    P_LINE-ZMSG = TEXT-M13. "자재 투입 처리에 성공하였습니다.
    P_LINE-MBLNR = LV_DOCUMENT.
    P_LINE-MJAHR = LV_YEAR.
    P_LINE-GI_STAT = ICON_LED_GREEN.
    P_LINE-ZSTAT = GC_S.

    WAIT UP TO '0.5' SECONDS.
  ENDIF.

  UPDATE ZGTPPT4030 SET ZSTAT = P_LINE-ZSTAT
                        ZMSG  = P_LINE-ZMSG
                        MBLNR = P_LINE-MBLNR
                        MJAHR = P_LINE-MJAHR
                  WHERE ZCAT  = GV_ZCAT
                    AND ZGINO = P_LINE-ZGINO
                    AND ZPJNO = P_LINE-ZPJNO
                    AND AUFNR = P_LINE-AUFNR.

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

  FIELD-SYMBOLS: <FS_R> LIKE GS_REVDATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M16. "투입 처리 취소를 수행할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T14 "투입 취소 처리
      TEXT_QUESTION         = TEXT-T15 "투입 취소를 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_REVDATA ASSIGNING <FS_R> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_R>-GI_STAT NE ICON_LED_GREEN.
        <FS_R>-ZMSG = TEXT-M17. "취소할 데이터가 없습니다.
      ELSE.
        PERFORM EXEC_MAT_CANGI USING <FS_R>.
      ENDIF.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_MAT_CANGI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_R>
*&---------------------------------------------------------------------*
FORM EXEC_MAT_CANGI  USING    P_LINE LIKE GS_REVDATA.
  DATA: LT_RETURN     TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
        LS_RETURNS    TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
        LS_GOODSMVT   TYPE BAPI2017_GM_HEAD_RET,
        LV_HEADER_TXT TYPE BAPI2017_GM_HEAD_02-HEADER_TXT.

  CLEAR: LT_RETURN, LS_RETURNS, LS_GOODSMVT.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = P_LINE-MBLNR
      MATDOCUMENTYEAR     = P_LINE-MJAHR
      DOCUMENTHEADER_TEXT = GC_ZGTPPR4060
    IMPORTING
      GOODSMVT_HEADRET    = LS_GOODSMVT
    TABLES
      RETURN              = LT_RETURN.

  IF LS_GOODSMVT-MAT_DOC IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = GC_X.

    P_LINE-ZMSG  = TEXT-M18. "투입 취소 처리에 성공하였습니다.
    P_LINE-GI_STAT = ICON_LED_GREEN.

    CLEAR: P_LINE-MBLNR, P_LINE-MJAHR.

    UPDATE ZGTPPT4030 SET ZSTAT = SPACE
                          ZMSG  = SPACE
                          MBLNR = SPACE
                          MJAHR = SPACE
                    WHERE ZCAT = GV_ZCAT
                      AND ZGINO = P_LINE-ZGINO
                      AND ZPJNO = P_LINE-ZPJNO
                      AND AUFNR = P_LINE-AUFNR.

    COMMIT WORK.

    WAIT UP TO 1 SECONDS.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CLEAR: LT_RETURN.
    READ TABLE LT_RETURN WITH KEY TYPE = GC_E.
    P_LINE-ZMSG = LT_RETURN-MESSAGE.
    P_LINE-GI_STAT = ICON_LED_RED.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_CANPROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_CANPROC .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  DATA: BEGIN OF LS_ZGINO,
          ZGINO LIKE ZGTPPT4030-ZGINO,
        END OF LS_ZGINO.
  DATA: LT_ZGINO LIKE TABLE OF LS_ZGINO.

  FIELD-SYMBOLS: <FS_R> LIKE GS_REVDATA.

  CLEAR: L_ANSWER.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T16 "실적 추출 및 수량 할당 취소
      "선택한 투입이력번호에 해당하는 전체 레코드가 취소됩니다. 진행하시겠습니까?
      TEXT_QUESTION         = TEXT-T17
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    SELECT SINGLE B~MBLNR
      FROM @GT_REVDATA AS A
     INNER JOIN ZGTPPT4030 AS B ON B~ZGINO EQ A~ZGINO
                               AND B~ZCAT EQ @GV_ZCAT
     WHERE B~MBLNR NE @SPACE
      INTO @DATA(LV_MBLNR).

    IF LV_MBLNR IS NOT INITIAL.
      MESSAGE S003 DISPLAY LIKE GC_W
         WITH TEXT-M19. "이미 투입 처리된 데이터가 존재하므로 취소가 불가합니다.
      EXIT.
    ELSE.
      CLEAR: LT_ZGINO.
      LOOP AT GT_REVDATA INTO DATA(LS_REV).
        MOVE: LS_REV-ZGINO TO LS_ZGINO-ZGINO.
        COLLECT LS_ZGINO INTO LT_ZGINO.
        CLEAR: LS_ZGINO.
      ENDLOOP.

      LOOP AT LT_ZGINO INTO LS_ZGINO.
        DELETE FROM ZGTPPT4020 WHERE ZGINO = LS_ZGINO-ZGINO
                                 AND ZCAT  = GV_ZCAT.
        IF SY-SUBRC EQ 0.
          DELETE FROM ZGTPPT4030 WHERE ZGINO = LS_ZGINO-ZGINO
                                   AND ZCAT  = GV_ZCAT.
          IF SY-SUBRC EQ 0.
            COMMIT WORK.
            MESSAGE S003 DISPLAY LIKE GC_S
               WITH TEXT-M20. "취소 처리에 성공하였습니다.
          ELSE.
            ROLLBACK WORK.
            MESSAGE S003 DISPLAY LIKE GC_E
               WITH TEXT-M21. "취소 처리 도중 오류가 발생하였습니다.
          ENDIF.
        ELSE.
          ROLLBACK WORK.
          MESSAGE S003 DISPLAY LIKE GC_E
             WITH TEXT-M21. "취소 처리 도중 오류가 발생하였습니다.
        ENDIF.

      ENDLOOP.

    ENDIF.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA_REV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA_REV .

  LOOP AT GT_REVDATA ASSIGNING FIELD-SYMBOL(<FS_R>).
    IF <FS_R>-ZSTAT EQ GC_S.
      <FS_R>-GI_STAT = ICON_LED_GREEN.
    ELSEIF <FS_R>-ZSTAT EQ GC_E.
      <FS_R>-GI_STAT = ICON_LED_RED.
    ELSE.
      <FS_R>-GI_STAT = ICON_LED_INACTIVE.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA_C .

  DATA: LV_AUFNR TYPE AUFNR,
        LV_MATNR TYPE MATNR,
        LV_LABST TYPE LABST.

  DATA: LT_CDATA LIKE TABLE OF GS_CDATA.

  CLEAR: LT_CDATA.
  APPEND LINES OF GT_CDATA TO LT_CDATA.

  SORT: LT_CDATA BY AUFNR MATNR,
        GT_CDATA BY AUFNR MATNR.

  LOOP AT GT_CDATA ASSIGNING FIELD-SYMBOL(<FS_C>).
*-투입 이력 번호
    <FS_C>-ZGINO = GV_ZGINO.

*-자재코드 CHECK
    CLEAR: LV_MATNR.
    SELECT SINGLE A~MATNR, B~MEINS, C~MAKTX
      FROM            MARC AS A
     INNER JOIN       MARA AS B ON B~MATNR EQ A~MATNR
      LEFT OUTER JOIN MAKT AS C ON C~MATNR EQ A~MATNR
                               AND C~SPRAS EQ @SY-LANGU
     WHERE A~MATNR EQ @<FS_C>-MATNR
       AND A~WERKS EQ @P_WERKS
      INTO (@LV_MATNR, @<FS_C>-GI_UNIT, @<FS_C>-MAKTX).

    IF LV_MATNR IS INITIAL.
      <FS_C>-GI_STAT = ICON_LED_RED.
      <FS_C>-GI_MSG = TEXT-M08. "존재하지 않는 자재코드입니다.

      CONTINUE.
    ENDIF.

*-투입 수량 CHECK
    CLEAR: LV_LABST.
    SELECT SINGLE LABST
      FROM MARD
     WHERE MATNR EQ @<FS_C>-MATNR
       AND WERKS EQ @P_WERKS
       AND LGORT EQ @P_LGORT
      INTO @LV_LABST.

    IF LV_LABST LT <FS_C>-GI_QTY OR LV_LABST EQ 0.
      <FS_C>-GI_STAT = ICON_LED_RED.
      "투입할 재고수량이 부족합니다.("LV_LABST")
      <FS_C>-GI_MSG = TEXT-M10 && |("| && LV_LABST && |")|.

      CONTINUE.
    ENDIF.

    IF P_HAND EQ GC_X.
*-생산오더 CHECK
      CLEAR: LV_AUFNR.
      SELECT SINGLE AUFNR
        FROM AUFK
       WHERE AUFNR EQ @<FS_C>-AUFNR
         AND WERKS EQ @P_WERKS
        INTO @LV_AUFNR.

      IF LV_AUFNR IS INITIAL.
        <FS_C>-GI_STAT = ICON_LED_RED.
        <FS_C>-GI_MSG = TEXT-M24. "존재하지 않는 생산오더번호입니다.

        CONTINUE.
      ENDIF.

*-오더+자재코드 중복 CHECK
      LOOP AT LT_CDATA INTO DATA(LS_CDATA) WHERE AUFNR = <FS_C>-AUFNR
                                             AND MATNR = <FS_C>-MATNR
        GROUP BY ( AUFNR = LS_CDATA-AUFNR
                   MATNR = LS_CDATA-MATNR
                   SIZE = GROUP SIZE )
        ASCENDING REFERENCE INTO DATA(GROUP_REF).

        CHECK GROUP_REF->*-SIZE > 1.

        <FS_C>-GI_STAT = ICON_LED_RED.

        CLEAR: LV_AUFNR, LV_MATNR.
        LV_AUFNR = <FS_C>-AUFNR.
        LV_MATNR = <FS_C>-MATNR.
        PERFORM CONV_ALPHA USING    LV_AUFNR GC_O
                           CHANGING LV_AUFNR.
        PERFORM CONV_MATN1 USING    LV_MATNR GC_O
                           CHANGING LV_MATNR.

        "생산오더/자재가 중복으로 업로드 되었습니다.(LV_AUFNR/LV_MATNR)
        <FS_C>-GI_MSG = TEXT-M23 && |(| && LV_AUFNR && |/| && LV_MATNR && |)|.

      ENDLOOP.

*-생산오더 상세정보
      SELECT SINGLE
             A~KDAUF, A~KDPOS, A~WEMNG,
             B~GMEIN,
             C~ZPJNO, C~BSTNK,
             D~ZPTXT,
             E~ZJOB_NAME AS JOBNM
        FROM            AFPO       AS A
       INNER JOIN       AFKO       AS B ON B~AUFNR EQ A~AUFNR
       INNER JOIN       VBAK       AS C ON C~VBELN EQ A~KDAUF
        LEFT OUTER JOIN ZSD0106T   AS D ON D~ZPJNO EQ C~ZPJNO
        LEFT OUTER JOIN ZGTEDT2121 AS E ON E~ZJOB_NO EQ C~BSTNK
       WHERE A~AUFNR EQ @<FS_C>-AUFNR
        INTO (@<FS_C>-KDAUF, @<FS_C>-KDPOS, @<FS_C>-WEMNG,
              @<FS_C>-GMEIN, @<FS_C>-ZPJNO, @<FS_C>-BSTNK,
              @<FS_C>-ZPTXT, @<FS_C>-JOBNM).
    ENDIF.

    IF <FS_C>-GI_STAT NE ICON_LED_RED.
      <FS_C>-GI_STAT = ICON_LED_INACTIVE.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONV_ALPHA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_AUFNR
*&      --> GC_O
*&      <-- LV_AUFNR
*&---------------------------------------------------------------------*
FORM CONV_ALPHA  USING    PV_INPUT  TYPE ANY     PV_GUBUN
                 CHANGING PV_OUTPUT TYPE ANY.

  IF PV_GUBUN EQ GC_I.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = PV_INPUT
      IMPORTING
        OUTPUT = PV_OUTPUT.

  ELSEIF PV_GUBUN EQ GC_O.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = PV_INPUT
      IMPORTING
        OUTPUT = PV_OUTPUT.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_C .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR4060TOP'
      I_INTERNAL_TABNAME     = 'GS_CDATA'
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
      IT_DATA         = GT_CDATA
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'GI_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "투입처리상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'GI_MSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "투입처리메시지
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'ZGINO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "투입이력번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'ZPJNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "프로젝트번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'ZPTXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "프로젝트내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'BSTNK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F26. "제조지시번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'JOBNM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F27. "제조지시내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'KDAUF'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F28. "판매오더번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'KDPOS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F29. "판매오더품목
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "생산오더번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'WEMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "생산입고수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C510'.
        <LS_FCAT>-QFIELDNAME = 'GMEIN'.
      WHEN 'GMEIN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "생산입고단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "자재코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "자재내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'GI_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "투입수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'GI_UNIT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "투입수량단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'MBLNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "자재문서번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'MJAHR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "자재문서연도
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_GI_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_GI_C .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_C> LIKE GS_CDATA.

  CLEAR: L_ANSWER.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T18 "정산자재 투입 처리
      TEXT_QUESTION         = TEXT-T19 "선택하신 레코드의 정산자재 투입 처리를 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT GT_CDATA ASSIGNING <FS_C>.
      PERFORM EXEC_MAT_GI_C USING <FS_C>.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_MAT_GI_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_C>
*&---------------------------------------------------------------------*
FORM EXEC_MAT_GI_C  USING    P_LINE LIKE GS_CDATA.

  DATA: LS_HEADER    TYPE BAPI2017_GM_HEAD_01,
        LT_ITEM      TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LV_CODE      TYPE BAPI2017_GM_CODE VALUE '03',
        LV_DOCUMENT  TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_YEAR      TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LS_GMHEADRET LIKE BAPI2017_GM_HEAD_RET,
        LT_RETURN    TYPE TABLE OF BAPIRET2.

  DATA: LV_ZSTAT LIKE ZGTPPT4030-ZSTAT.

  CLEAR: LS_HEADER, LT_ITEM.

  LS_HEADER = VALUE #( PSTNG_DATE = P_BUDAT
                       DOC_DATE   = P_BUDAT
                       PR_UNAME   = SY-UNAME
                       HEADER_TXT = GC_ZGTPPR4060 ).

  LT_ITEM = VALUE #( ( MATERIAL       = P_LINE-MATNR
                       PLANT          = P_WERKS
                       STGE_LOC       = P_LGORT
                       BATCH          = SPACE
                       MOVE_TYPE      = GC_261
                       STCK_TYPE      = GC_F
                       ENTRY_QNT      = P_LINE-GI_QTY
                       ENTRY_UOM      = P_LINE-GI_UNIT
                       ORDERID        = P_LINE-AUFNR ) ).

  CLEAR: LV_DOCUMENT, LV_YEAR, LS_GMHEADRET, LT_RETURN, LV_ZSTAT.
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
    P_LINE-GI_MSG = LS_RETURN-MESSAGE.
    P_LINE-GI_STAT = ICON_LED_RED.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = GC_X.

    P_LINE-GI_STAT = ICON_LED_GREEN.
    P_LINE-GI_MSG = TEXT-M13. "자재 투입 처리에 성공하였습니다.
    P_LINE-MBLNR = LV_DOCUMENT.
    P_LINE-MJAHR = LV_YEAR.

    WAIT UP TO '0.5' SECONDS.

    PERFORM SAVE_ZGTPPT4040 USING P_LINE GC_S.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZGTPPT4040
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM SAVE_ZGTPPT4040  USING    P_LINE LIKE GS_CDATA
                               P_STAT.

  DATA: LS_ZGTPPT4040 LIKE ZGTPPT4040.

  CLEAR: LS_ZGTPPT4040.

  LS_ZGTPPT4040-ZCAT    = GV_ZCAT.
  LS_ZGTPPT4040-ZGINO   = P_LINE-ZGINO.
  LS_ZGTPPT4040-AUFNR   = P_LINE-AUFNR.
  LS_ZGTPPT4040-WERKS   = P_WERKS.
  LS_ZGTPPT4040-LGORT   = P_LGORT.
  LS_ZGTPPT4040-SPMON   = P_SPMON.
  LS_ZGTPPT4040-MATNR   = P_LINE-MATNR.
  LS_ZGTPPT4040-GI_QTY  = P_LINE-GI_QTY.
  LS_ZGTPPT4040-GI_UNIT = P_LINE-GI_UNIT.
  LS_ZGTPPT4040-BUDAT   = P_BUDAT.
  LS_ZGTPPT4040-ZSTAT   = P_STAT.
  LS_ZGTPPT4040-ZMSG    = P_LINE-GI_MSG.
  LS_ZGTPPT4040-MBLNR   = P_LINE-MBLNR.
  LS_ZGTPPT4040-MJAHR   = P_LINE-MJAHR.
  LS_ZGTPPT4040-CRDAT   = SY-DATUM.
  LS_ZGTPPT4040-CRTIM   = SY-UZEIT.
  LS_ZGTPPT4040-CRNAM   = SY-UNAME.

  MODIFY ZGTPPT4040 FROM LS_ZGTPPT4040.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_RESULT_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_RESULT_C .

  CLEAR: GT_CREVDATA.

  SELECT A~*,
         B~MAKTX
    FROM      ZGTPPT4040 AS A
    LEFT OUTER JOIN MAKT AS B ON B~MATNR EQ A~MATNR
                             AND B~SPRAS EQ @SY-LANGU
   WHERE A~WERKS EQ @P_WERKS
     AND A~SPMON EQ @P_SPMON
     AND A~ZGINO IN @S_ZGINO
     AND A~MATNR IN @S_MATNR
     AND A~CRDAT IN @S_CRDAT
     AND A~AUFNR IN @S_AUFNR
     AND A~MBLNR IN @S_MBLNR
     AND A~ZCAT  EQ @GV_ZCAT
    INTO CORRESPONDING FIELDS OF TABLE @GT_CREVDATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA_REV_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA_REV_C .

  LOOP AT GT_CREVDATA ASSIGNING FIELD-SYMBOL(<FS_CR>).
    IF <FS_CR>-ZSTAT EQ GC_S.
      <FS_CR>-GI_STAT = ICON_LED_GREEN.
    ELSEIF <FS_CR>-ZSTAT EQ GC_E.
      <FS_CR>-GI_STAT = ICON_LED_RED.
    ELSE.
      <FS_CR>-GI_STAT = ICON_LED_INACTIVE.
    ENDIF.

*-생산오더 상세정보
    SELECT SINGLE
           A~KDAUF, A~KDPOS, A~WEMNG,
           B~GMEIN,
           C~ZPJNO, C~BSTNK,
           D~ZPTXT,
           E~ZJOB_NAME AS JOBNM
      FROM            AFPO       AS A
     INNER JOIN       AFKO       AS B ON B~AUFNR EQ A~AUFNR
     INNER JOIN       VBAK       AS C ON C~VBELN EQ A~KDAUF
      LEFT OUTER JOIN ZSD0106T   AS D ON D~ZPJNO EQ C~ZPJNO
      LEFT OUTER JOIN ZGTEDT2121 AS E ON E~ZJOB_NO EQ C~BSTNK
     WHERE A~AUFNR EQ @<FS_CR>-AUFNR
      INTO (@<FS_CR>-KDAUF, @<FS_CR>-KDPOS, @<FS_CR>-WEMNG,
            @<FS_CR>-GMEIN, @<FS_CR>-ZPJNO, @<FS_CR>-BSTNK,
            @<FS_CR>-ZPTXT, @<FS_CR>-JOBNM).

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_REV_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_REV_C .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR4060TOP'
      I_INTERNAL_TABNAME     = 'GS_CREVDATA'
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
      IT_DATA         = GT_CREVDATA
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'GI_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "투입처리상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'ZMSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "투입처리메시지
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'ZGINO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "투입이력번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'ZPJNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "프로젝트번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'ZPTXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "프로젝트내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'BSTNK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F26. "제조지시번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'JOBNM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F27. "제조지시내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'KDAUF'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F28. "판매오더번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'KDPOS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F29. "판매오더품목
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C100'.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "생산오더번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'WEMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "생산입고수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C510'.
        <LS_FCAT>-QFIELDNAME = 'GMEIN'.
      WHEN 'GMEIN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "생산입고단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "자재코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "자재내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'GI_QTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "투입수량
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'GI_UNIT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "투입수량단위
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'BUDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F30. "전기일자
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'MBLNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "자재문서번호
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'MJAHR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "자재문서연도
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C700'.
      WHEN 'CRDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F23. "생성일자
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C710'.
      WHEN 'CRTIM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F24. "생성시간
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C710'.
      WHEN 'CRNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F25. "생성자ID
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C710'.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_CANGI_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_CANGI_C .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_CR> LIKE GS_CREVDATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M16. "투입 처리 취소를 수행할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T14 "투입 취소 처리
      TEXT_QUESTION         = TEXT-T15 "투입 취소를 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_CREVDATA ASSIGNING <FS_CR> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_CR>-GI_STAT NE ICON_LED_GREEN.
        <FS_CR>-ZMSG = TEXT-M17. "취소할 데이터가 없습니다.
      ELSE.
        PERFORM EXEC_MAT_CANGI_C USING <FS_CR>.
      ENDIF.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_MAT_CANGI_c
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_CR>
*&---------------------------------------------------------------------*
FORM EXEC_MAT_CANGI_C  USING    P_LINE LIKE GS_CREVDATA.
  DATA: LT_RETURN     TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
        LS_RETURNS    TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
        LS_GOODSMVT   TYPE BAPI2017_GM_HEAD_RET,
        LV_HEADER_TXT TYPE BAPI2017_GM_HEAD_02-HEADER_TXT.

  CLEAR: LT_RETURN, LS_RETURNS, LS_GOODSMVT.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = P_LINE-MBLNR
      MATDOCUMENTYEAR     = P_LINE-MJAHR
      DOCUMENTHEADER_TEXT = GC_ZGTPPR4060
    IMPORTING
      GOODSMVT_HEADRET    = LS_GOODSMVT
    TABLES
      RETURN              = LT_RETURN.

  IF LS_GOODSMVT-MAT_DOC IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = GC_X.

    P_LINE-ZMSG  = TEXT-M18. "투입 취소 처리에 성공하였습니다.
    P_LINE-GI_STAT = ICON_LED_GREEN.

    CLEAR: P_LINE-MBLNR, P_LINE-MJAHR.

    UPDATE ZGTPPT4040 SET ZSTAT = SPACE
                          ZMSG  = SPACE
                          MBLNR = SPACE
                          MJAHR = SPACE
                    WHERE ZCAT = GV_ZCAT
                      AND ZGINO = P_LINE-ZGINO
                      AND AUFNR = P_LINE-AUFNR
                      AND MATNR = P_LINE-MATNR.

    COMMIT WORK.

    WAIT UP TO 1 SECONDS.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CLEAR: LT_RETURN.
    READ TABLE LT_RETURN WITH KEY TYPE = GC_E.
    P_LINE-ZMSG = LT_RETURN-MESSAGE.
    P_LINE-GI_STAT = ICON_LED_RED.
  ENDIF.

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
  GV_DYNTXT-TEXT = '엑셀 업로드 양식 다운로드'.
  GV_DYNTXT-ICON_TEXT = '엑셀 업로드 양식 다운로드'.
  GV_DYNTXT-QUICKINFO = '엑셀 업로드 양식 다운로드'.
  SSCRFIELDS-FUNCTXT_01 = GV_DYNTXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_EXCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_EXCEL .
  DATA: LV_OBJ TYPE CHAR40.

  DATA: LV_DESTINATION TYPE RLGRAP-FILENAME,
        LV_FILENAME    TYPE STRING,
        LV_PATH        TYPE STRING,
        LV_FULLPATH    TYPE STRING,
        LS_KEY         TYPE WWWDATATAB,
        LV_EXTEN       TYPE STRING,
        LV_SUBRC       TYPE SY-SUBRC,
        LV_USER_ACTION TYPE I.

  CONSTANTS: LC_TITLE TYPE STRING VALUE 'Select File',
             LC_MI(2) TYPE C VALUE 'MI'.

  IF P_R1 EQ GC_X.
    IF P_RP EQ GC_X.
      LV_OBJ = |ZGTPPR4060_P|.
    ELSEIF P_RC EQ GC_X.
      IF P_HAND EQ GC_X.
        LV_OBJ = |ZGTPPR4060_CH|.
      ELSEIF P_RATIO EQ GC_X.
        LV_OBJ = |ZGTPPR4060_CR|.
      ENDIF.
    ENDIF.

    TRY .
        LV_EXTEN    = |xlsx|.
        LV_FILENAME = LV_OBJ.

        CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
          EXPORTING
            WINDOW_TITLE         = LC_TITLE
            DEFAULT_EXTENSION    = LV_EXTEN
            DEFAULT_FILE_NAME    = LV_FILENAME
*           INITIAL_DIRECTORY    = IV_INITIAL_DIRECTORY
            FILE_FILTER          = 'xlsx'
            PROMPT_ON_OVERWRITE  = ABAP_TRUE
          CHANGING
            FILENAME             = LV_FILENAME
            PATH                 = LV_PATH
            FULLPATH             = LV_FULLPATH
            USER_ACTION          = LV_USER_ACTION
          EXCEPTIONS
            CNTL_ERROR           = 1
            ERROR_NO_GUI         = 2
            NOT_SUPPORTED_BY_GUI = 3
            OTHERS               = 4.
        IF SY-SUBRC <> 0.
          LV_SUBRC  = SY-SUBRC.
          MESSAGE E162(ALVHT).
          EXIT.
        ENDIF.

        IF LV_USER_ACTION = CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL .
          MESSAGE S161(ALVHT) DISPLAY LIKE GC_E.
          EXIT.
        ENDIF.

*-- check file path
        IF LV_FULLPATH IS INITIAL.
          MESSAGE E003 WITH TEXT-M25. "파일명을 확인하세요.
          EXIT.
        ENDIF.

*-----------------------------------------------------------------------------*
* DOWNLOAD OBJECT FILE
*-----------------------------------------------------------------------------
        CLEAR: LS_KEY.
        SELECT SINGLE *
          FROM WWWDATA
         WHERE OBJID EQ @LV_OBJ
          INTO CORRESPONDING FIELDS OF @LS_KEY.

        LS_KEY-RELID = LC_MI.
        LS_KEY-OBJID = LV_OBJ.
        LV_DESTINATION = LV_FULLPATH.

        DATA(LV_LEN) = STRLEN( LV_FULLPATH ).
        IF LV_LEN > 128.
          MESSAGE S003 DISPLAY LIKE GC_E
             WITH TEXT-M26. "다운로드 중 오류가 발생하였습니다.
          EXIT.
        ENDIF.

        CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
          EXPORTING
            KEY         = LS_KEY
            DESTINATION = LV_DESTINATION
          IMPORTING
            RC          = LV_SUBRC
          EXCEPTIONS
            OTHERS      = 1.
        IF SY-SUBRC IS NOT INITIAL OR LV_SUBRC IS NOT INITIAL.
          MESSAGE E003 WITH TEXT-M26. "다운로드 중 오류가 발생하였습니다.
          EXIT.
        ENDIF.

        CALL METHOD CL_GUI_FRONTEND_SERVICES=>EXECUTE
          EXPORTING
            DOCUMENT               = LV_FULLPATH
          EXCEPTIONS
            CNTL_ERROR             = 1
            ERROR_NO_GUI           = 2
            BAD_PARAMETER          = 3
            FILE_NOT_FOUND         = 4
            PATH_NOT_FOUND         = 5
            FILE_EXTENSION_UNKNOWN = 6
            ERROR_EXECUTE_FAILED   = 7
            SYNCHRONOUS_FAILED     = 8
            NOT_SUPPORTED_BY_GUI   = 9
            OTHERS                 = 10.
        IF SY-SUBRC IS NOT INITIAL.
          MESSAGE E162(ALVHT).
          EXIT.
        ENDIF.

      CATCH CX_ROOT INTO DATA(LO_ERR).
        MESSAGE S000 DISPLAY LIKE GC_E
           WITH LO_ERR->GET_LONGTEXT( ).
    ENDTRY.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PRD_GR_CR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PRD_GR_CR .

  DATA: LV_FLD_01 LIKE ZGTPPT1010-FLD_01.

  CLEAR: GR_GSTRP, GR_GSTRP[].
  GR_GSTRP-SIGN = GC_I.
  GR_GSTRP-OPTION = GC_BT.
  GR_GSTRP-LOW = P_SPMON && |01|.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = GR_GSTRP-LOW
    IMPORTING
      LAST_DAY_OF_MONTH = GR_GSTRP-HIGH
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2.

  APPEND GR_GSTRP.

  CLEAR: LV_FLD_01.
  CASE GC_X.
    WHEN P_ASM.
      LV_FLD_01 = |01|.
    WHEN P_INS.
      LV_FLD_01 = |02|.
    WHEN P_BUS.
      LV_FLD_01 = |03|.
  ENDCASE.

  SELECT SINGLE FLD_03, FLD_04
    FROM ZGTPPT1010
   WHERE MODULE_KIND EQ @GC_PP
     AND CODEGRP     EQ @GC_4030
     AND FLD_01      EQ @LV_FLD_01
    INTO (@DATA(LV_FLD_03), @DATA(LV_FLD_04)).

  CLEAR: GR_MTART, GR_MATKL, GR_MTART[], GR_MATKL[].
  IF LV_FLD_03 IS NOT INITIAL.
    GR_MTART[] = VALUE #( ( SIGN = GC_I
                            OPTION = GC_EQ
                            LOW = LV_FLD_03 ) ).
  ENDIF.
  IF LV_FLD_04 IS NOT INITIAL.
    GR_MATKL[] = VALUE #( ( SIGN = GC_I
                            OPTION = GC_EQ
                            LOW = LV_FLD_04 ) ).
  ENDIF.

  CLEAR: GT_PRDGR_CR.
  SELECT A~KDAUF, A~KDPOS, A~AUFNR, A~MATNR, A~WEMNG,
         B~GMEIN,
         C~ZPJNO, C~BSTNK,
         E~MAKTX,
         F~ZPTXT,
         G~ZJOB_NAME AS JOBNM
    FROM            AFPO       AS A
   INNER JOIN       AFKO       AS B ON B~AUFNR EQ A~AUFNR
   INNER JOIN       VBAK       AS C ON C~VBELN EQ A~KDAUF
   INNER JOIN       MARA       AS D ON D~MATNR EQ A~MATNR
   INNER JOIN       AUFK       AS H ON H~AUFNR EQ A~AUFNR
    LEFT OUTER JOIN MAKT       AS E ON E~SPRAS EQ @SY-LANGU
                                   AND E~MATNR EQ A~MATNR
    LEFT OUTER JOIN ZSD0106T   AS F ON F~ZPJNO EQ C~ZPJNO
    LEFT OUTER JOIN ZGTEDT2121 AS G ON G~ZJOB_NO EQ C~BSTNK
   WHERE B~GSTRP IN @GR_GSTRP
     AND D~MTART IN @GR_MTART
     AND D~MATKL IN @GR_MATKL
     AND H~WERKS EQ @P_WERKS
     AND H~AUART EQ @GC_PP04
     AND A~WEMNG GT 0
    INTO CORRESPONDING FIELDS OF TABLE @GT_PRDGR_CR.

  SORT GT_PRDGR_CR BY KDAUF KDPOS WEMNG DESCENDING.
  DELETE ADJACENT DUPLICATES FROM GT_PRDGR_CR COMPARING KDAUF KDPOS.

  CLEAR: GV_SWEMNG.
  LOOP AT GT_PRDGR_CR INTO DATA(LS_PRDGR).
    GV_SWEMNG = GV_SWEMNG + LS_PRDGR-WEMNG.
  ENDLOOP.

  CLEAR: GT_PRDGR_1.
  APPEND LINES OF GT_PRDGR_CR TO GT_PRDGR_1.
  SORT GT_PRDGR_1 BY WEMNG DESCENDING.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATA_CR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DATA_CR .

  CLEAR: GT_CDATA.
  LOOP AT GT_CRDATA ASSIGNING FIELD-SYMBOL(<FS_CR>).
    MOVE: <FS_CR>-MATNR TO GS_CDATA-MATNR.
    LOOP AT GT_PRDGR_CR INTO DATA(LS_PRDGR).
      MOVE: LS_PRDGR-ZPJNO TO GS_CDATA-ZPJNO,
            LS_PRDGR-ZPTXT TO GS_CDATA-ZPTXT,
            LS_PRDGR-BSTNK TO GS_CDATA-BSTNK,
            LS_PRDGR-JOBNM TO GS_CDATA-JOBNM,
            LS_PRDGR-KDAUF TO GS_CDATA-KDAUF,
            LS_PRDGR-KDPOS TO GS_CDATA-KDPOS,
            LS_PRDGR-AUFNR TO GS_CDATA-AUFNR,
            LS_PRDGR-WEMNG TO GS_CDATA-WEMNG,
            LS_PRDGR-GMEIN TO GS_CDATA-GMEIN.

*-투입수량
      GS_CDATA-GI_QTY = <FS_CR>-GI_QTY * ( LS_PRDGR-WEMNG / GV_SWEMNG ).

      IF <FS_CR>-REAL_QTY LE GS_CDATA-GI_QTY.
        GS_CDATA-GI_QTY = <FS_CR>-REAL_QTY.
        CLEAR: <FS_CR>-REAL_QTY.

        APPEND GS_CDATA TO GT_CDATA.

        EXIT.
      ENDIF.

*-자재 투입수량 차감
      <FS_CR>-REAL_QTY = <FS_CR>-REAL_QTY - GS_CDATA-GI_QTY.

      APPEND GS_CDATA TO GT_CDATA.
      CLEAR: LS_PRDGR.
    ENDLOOP.

    CLEAR: GS_CDATA, LS_PRDGR.
  ENDLOOP.

  LOOP AT GT_CRDATA INTO DATA(LS_CRDATA) WHERE REAL_QTY NE 0.
    READ TABLE GT_PRDGR_1 INTO DATA(LS_PRD1) INDEX 1.

    READ TABLE GT_CDATA ASSIGNING FIELD-SYMBOL(<FS>) WITH KEY MATNR = LS_CRDATA-MATNR
                                                              AUFNR = LS_PRD1-AUFNR.
    IF SY-SUBRC EQ 0.
      <FS>-GI_QTY = <FS>-GI_QTY + LS_CRDATA-REAL_QTY.
    ENDIF.

  ENDLOOP.

  DELETE GT_CDATA WHERE GI_QTY EQ 0.

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
