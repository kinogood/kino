*&---------------------------------------------------------------------*
*& Include          ZGTPPR1080F01
*&---------------------------------------------------------------------*
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
  GV_DYNTXT-TEXT = '엑셀 양식 다운로드'.
  GV_DYNTXT-ICON_TEXT = '엑셀 양식 다운로드'.
  GV_DYNTXT-QUICKINFO = '엑셀 양식 다운로드'.
  SSCRFIELDS-FUNCTXT_01 = GV_DYNTXT.

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
  LV_TITLE = TEXT-T02.  "파일 열기

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

  LV_OBJ = |ZGTPPR1080|.

  TRY .
      LV_EXTEN    = |xlsx|.
      LV_FILENAME = LV_OBJ.

      CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
        EXPORTING
          WINDOW_TITLE         = LC_TITLE
          DEFAULT_EXTENSION    = LV_EXTEN
          DEFAULT_FILE_NAME    = LV_FILENAME
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
        MESSAGE E003 WITH TEXT-M01. "파일명을 확인하세요.
        EXIT.
      ENDIF.

* DOWNLOAD OBJECT FILE
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
           WITH TEXT-M02. "다운로드 중 오류가 발생하였습니다.
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
        MESSAGE E003 WITH TEXT-M02. "다운로드 중 오류가 발생하였습니다.
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
      WHEN 'P_FILE'.
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
  IF P_FILE IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH TEXT-M03. "필수 필드 "파일 경로"에 입력하십시오.
    LEAVE LIST-PROCESSING.
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

  LOOP AT LT_EXCEL.
    MOVE: LT_EXCEL-COL TO LV_INDEX.
    ASSIGN COMPONENT LV_INDEX OF STRUCTURE GS_UPLOAD TO <FS>.
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
      APPEND GS_UPLOAD TO GT_UPLOAD.
      CLEAR GS_UPLOAD.
    ENDAT.
  ENDLOOP.

  CLEAR: GT_DATA.
  LOOP AT GT_UPLOAD INTO GS_UPLOAD.
    CLEAR: GS_DATA.
    MOVE-CORRESPONDING GS_UPLOAD TO GS_DATA.

    PERFORM CONV_ALPHA USING    GS_DATA-KOSTL GC_I
                       CHANGING GS_DATA-KOSTL.

    APPEND GS_DATA TO GT_DATA.
  ENDLOOP.

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
    REFRESH GT_DATA.
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

  DATA: LT_DATA LIKE TABLE OF GS_DATA.

  DATA: LV_MANDT TYPE MANDT.

  DATA: NAME1     TYPE STRING,
        NAME2     TYPE STRING,
        LV_CNT(2).

  FIELD-SYMBOLS: <FS1>, <FS2>.

  CLEAR: LT_DATA.
  APPEND LINES OF GT_DATA TO LT_DATA.

  SORT: GT_DATA BY VGWTS,
        LT_DATA BY VGWTS.

  LOOP AT GT_DATA INTO GS_DATA.
    "표준값키 상이 여부
    LOOP AT LT_DATA INTO DATA(LS_DATA) WHERE VGWTS NE GS_DATA-VGWTS.
      IF SY-SUBRC EQ 0.
        MESSAGE S003 DISPLAY LIKE GC_W
           WITH TEXT-M07. "표준값 키가 서로 다릅니다.

        STOP.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  SORT: GT_DATA BY WERKS ARBPL.

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS>).
    "작업장 존재 여부
    CLEAR: LV_MANDT.
    SELECT SINGLE MANDT
      FROM CRHD
     WHERE WERKS EQ @<FS>-WERKS
       AND ARBPL EQ @<FS>-ARBPL
      INTO @LV_MANDT.

    IF SY-SUBRC EQ 0.
      <FS>-ZTYPE = TEXT-M04. "변경
    ELSE.
      <FS>-ZTYPE = TEXT-M05. "생성
    ENDIF.

    "코스트센터 존재 여부
    SELECT SINGLE DATAB
      FROM CSKS
     WHERE KOSTL EQ @<FS>-KOSTL
      INTO @<FS>-DATAB.

    IF SY-SUBRC NE 0.
      <FS>-ZSTAT = ICON_LED_RED.

      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          MSGID               = 'ZGTPP00'
          MSGNR               = '015'
          MSGV1               = <FS>-KOSTL
        IMPORTING
          MESSAGE_TEXT_OUTPUT = <FS>-ZMESSAGE. "존재하지 않는 코스트센터입니다.(&1)
    ENDIF.

  ENDLOOP.

  CLEAR: GS_DATA.
  READ TABLE GT_DATA INTO GS_DATA INDEX 1.

  "표준값키에 따른 액티비티 유형 정보 추출
  CLEAR: GS_TC21.
  SELECT SINGLE PAR01, PAR02, PAR03, PAR04, PAR05, PAR06
    FROM TC21
   WHERE VGWTS EQ @GS_DATA-VGWTS
    INTO CORRESPONDING FIELDS OF @GS_TC21.

  "계산식 키에서 액티비티 유형 정보 추출
  CLEAR: GS_TC20T, LV_CNT.
  DO 6 TIMES.
    LV_CNT = LV_CNT + 1.

    LV_CNT = |0| && LV_CNT.

    UNASSIGN <FS1>.
    CLEAR: NAME1.
    NAME1 = |GS_TC21-PAR| && LV_CNT.
    ASSIGN (NAME1) TO <FS1>.

    UNASSIGN <FS2>.
    CLEAR: NAME2.
    NAME2 = |GS_TC20T-TXT| && LV_CNT.
    ASSIGN (NAME2) TO <FS2>.

    IF <FS1> IS ASSIGNED AND <FS2> IS ASSIGNED.
      SELECT SINGLE TXT
        FROM TC20T
       WHERE SPRAS EQ @SY-LANGU
         AND PARID EQ @<FS1>
        INTO @<FS2>.
    ENDIF.

  ENDDO.

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
  FREE: GO_CONTAIN_0100.
  FREE: GO_GRID_0100.
  CLEAR : GO_CONTAIN_0100, GO_GRID_0100.
  CALL METHOD CL_GUI_CFW=>FLUSH.
  LEAVE TO SCREEN 0.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_EXEC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_EXEC .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA,
                 <FS_C> LIKE GS_DATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M08. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T06 "작업장 생성/변경
      TEXT_QUESTION         = TEXT-T07 "작업장 생성/변경을 하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_C> INDEX LT_ROW_NO-ROW_ID.
      IF <FS_C>-ZSTAT EQ ICON_LED_GREEN.
        "이미 처리 완료된 레코드가 포함되어 있습니다.
        MESSAGE S003 WITH TEXT-M06 DISPLAY LIKE GC_E.
        RETURN.
      ENDIF.
    ENDLOOP.

    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-ZSTAT NE ICON_LED_GREEN.
        PERFORM EXEC_WORKCENTER USING <FS_S>.
      ENDIF.
    ENDLOOP.

    SET PARAMETER ID 'AGR' FIELD SPACE.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.
  ENDIF.
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
  DATA: LV_TEXT TYPE STRING.
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR1080TOP'
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
      WHEN 'ZSTAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
      WHEN 'ZMESSAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "메시지
        <LS_FCAT>-JUST = GC_L.
      WHEN 'ZTYPE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "플랜트
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ARBPL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "작업장코드
        <LS_FCAT>-JUST = GC_C.
      WHEN 'VERWE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "작업장범주
        <LS_FCAT>-JUST = GC_C.
      WHEN 'KTEXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "작업장내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'VERAN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "작업장책임자
        <LS_FCAT>-JUST = GC_C.
      WHEN 'PLANV'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "용도
        <LS_FCAT>-JUST = GC_C.
      WHEN 'VGWTS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "표준값키
        <LS_FCAT>-JUST = GC_C.
      WHEN 'STEUS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "제어키
        <LS_FCAT>-JUST = GC_C.
      WHEN 'KOSTL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "코스트센터
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LAR01'.
        CLEAR: LV_TEXT.
        LV_TEXT = GS_TC20T-TXT01 && TEXT-T03.  "(유형)
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_TEXT. "가동준비(유형)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LEINH01'.
        CLEAR: LV_TEXT.
        LV_TEXT = GS_TC20T-TXT01 && TEXT-T04.  "(단위)
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_TEXT. "가동준비(단위)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'FOR01'.
        CLEAR: LV_TEXT.
        LV_TEXT = GS_TC20T-TXT01 && TEXT-T05.  "(계산식)
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_TEXT. "가동준비(계산식)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LAR02'.
        CLEAR: LV_TEXT.
        LV_TEXT = GS_TC20T-TXT02 && TEXT-T03.  "(유형)
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_TEXT. "기계(유형)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LEINH02'.
        CLEAR: LV_TEXT.
        LV_TEXT = GS_TC20T-TXT02 && TEXT-T04.  "(단위)
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_TEXT. "기계(단위)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'FOR02'.
        CLEAR: LV_TEXT.
        LV_TEXT = GS_TC20T-TXT02 && TEXT-T05.  "(계산식)
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_TEXT. "기계(계산식)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LAR03'.
        CLEAR: LV_TEXT.
        LV_TEXT = GS_TC20T-TXT03 && TEXT-T03.  "(유형)
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_TEXT. "제조지원(유형)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LEINH03'.
        CLEAR: LV_TEXT.
        LV_TEXT = GS_TC20T-TXT03 && TEXT-T04.  "(단위)
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_TEXT. "제조지원(단위)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'FOR03'.
        CLEAR: LV_TEXT.
        LV_TEXT = GS_TC20T-TXT03 && TEXT-T05.  "(계산식)
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_TEXT. "제조지원(계산식)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LAR04'.
        CLEAR: LV_TEXT.
        LV_TEXT = GS_TC20T-TXT04 && TEXT-T03.  "(유형)
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_TEXT. "제조직접(유형)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LEINH04'.
        CLEAR: LV_TEXT.
        LV_TEXT = GS_TC20T-TXT04 && TEXT-T04.  "(단위)
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_TEXT. "제조직접(단위)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'FOR04'.
        CLEAR: LV_TEXT.
        LV_TEXT = GS_TC20T-TXT04 && TEXT-T05.  "(계산식)
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_TEXT. "제조직접(계산식)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LAR05'.
        CLEAR: LV_TEXT.
        LV_TEXT = GS_TC20T-TXT05 && TEXT-T03.  "(유형)
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_TEXT. "배부간접(유형)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LEINH05'.
        CLEAR: LV_TEXT.
        LV_TEXT = GS_TC20T-TXT05 && TEXT-T04.  "(단위)
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_TEXT. "배부간접(단위)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'FOR05'.
        CLEAR: LV_TEXT.
        LV_TEXT = GS_TC20T-TXT05 && TEXT-T05.  "(계산식)
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_TEXT. "배부간접(계산식)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LAR06'.
        CLEAR: LV_TEXT.
        LV_TEXT = GS_TC20T-TXT06 && TEXT-T03.  "(유형)
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_TEXT. "노무(유형)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LEINH06'.
        CLEAR: LV_TEXT.
        LV_TEXT = GS_TC20T-TXT06 && TEXT-T04.  "(단위)
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_TEXT. "노무(단위)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'FOR06'.
        CLEAR: LV_TEXT.
        LV_TEXT = GS_TC20T-TXT06 && TEXT-T05.  "(계산식)
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_TEXT. "노무(계산식)
        <LS_FCAT>-JUST = GC_C.
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

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

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
    CHANGING
      IT_OUTTAB            = GT_DATA
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.
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
*& Form EXEC_WORKCENTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_WORKCENTER  USING    P_LINE LIKE GS_DATA.

  DATA: LV_MSG TYPE BAPIRET2-MESSAGE.

  SET PARAMETER ID 'AGR' FIELD SPACE.

  CLEAR: BDCDATA, BDCDATA[], MESSTAB, MESSTAB[].

  "초기화면
  IF P_LINE-ZTYPE EQ TEXT-M04. "변경
    PERFORM DYNPRO1 USING:
          'X' 'SAPLCRA0'   '0100',
          ' ' 'BDC_OKCODE' '/00',
          ' ' 'RC68A-WERKS' P_LINE-WERKS, "플랜트
          ' ' 'RC68A-ARBPL' P_LINE-ARBPL. "작업장

  ELSEIF P_LINE-ZTYPE EQ TEXT-M05. "생성.
    PERFORM DYNPRO1 USING:
          'X' 'SAPLCRA0'   '0101',
          ' ' 'BDC_OKCODE' '=NEXT',
          ' ' 'RC68A-WERKS' P_LINE-WERKS, "플랜트
          ' ' 'RC68A-ARBPL' P_LINE-ARBPL, "작업장
          ' ' 'RC68A-VERWE' P_LINE-VERWE. "작업장범주
  ENDIF.

  "기본데이터 탭
  PERFORM DYNPRO1 USING:
        'X' 'SAPLCRA0'    '4000',
        ' ' 'BDC_OKCODE'  '=VORA',
        ' ' 'P1000-STEXT' P_LINE-KTEXT, "내역
        ' ' 'P3000-VERAN' P_LINE-VERAN, "책임자
        ' ' 'P3000-PLANV' P_LINE-PLANV, "용도
        ' ' 'P3000-VGWTS' P_LINE-VGWTS. "표준값키

  "기본값 탭
  PERFORM DYNPRO1 USING:
        'X' 'SAPLCRA0'        '4000',
        ' ' 'BDC_OKCODE'      '=VK11',
        ' ' 'P3003-STEUS'     P_LINE-STEUS,   "제어키
        ' ' 'RC68A-VGEXX(01)' P_LINE-LEINH01, "ACT.단위1
        ' ' 'RC68A-VGEXX(02)' P_LINE-LEINH02, "ACT.단위2
        ' ' 'RC68A-VGEXX(03)' P_LINE-LEINH03, "ACT.단위3
        ' ' 'RC68A-VGEXX(04)' P_LINE-LEINH04, "ACT.단위4
        ' ' 'RC68A-VGEXX(05)' P_LINE-LEINH05, "ACT.단위5
        ' ' 'RC68A-VGEXX(06)' P_LINE-LEINH06. "ACT.단위6

  "원가계산탭(1)-코스트센터 입력
  IF P_LINE-ZTYPE EQ TEXT-M04. "변경
    PERFORM DYNPRO1 USING:
          'X' 'SAPLCRA0'     '4000',
          ' ' 'BDC_OKCODE'   '/00',
          ' ' 'P1001-BEGDA'  P_LINE-DATAB, "시작일
          ' ' 'P1001-ENDDA'  '99991231',   "종료일
          ' ' 'CRKEYK-KOSTL' P_LINE-KOSTL. "코스트센터

  ELSEIF P_LINE-ZTYPE EQ TEXT-M05. "생성.
    PERFORM DYNPRO1 USING:
          'X' 'SAPLCRA0'     '4000',
          ' ' 'BDC_OKCODE'   '/00',
          ' ' 'P1001-BEGDA'  SY-DATUM,     "시작일
          ' ' 'P1001-ENDDA'  '99991231',   "종료일
          ' ' 'CRKEYK-KOSTL' P_LINE-KOSTL. "코스트센터
  ENDIF.

  "원가계산탭(2)-ACT. 입력
  PERFORM DYNPRO1 USING:
        'X' 'SAPLCRA0'        '4000',
        ' ' 'BDC_OKCODE'      '=UPD',
        ' ' 'RC68A-LARXX(01)' P_LINE-LAR01,   "ACT.유형1
        ' ' 'RC68A-LEINH(01)' P_LINE-LEINH01, "ACT.단위1
        ' ' 'RC68A-FORXX(01)' P_LINE-FOR01,   "계산식키1
        ' ' 'RC68A-LARXX(02)' P_LINE-LAR02,   "ACT.유형2
        ' ' 'RC68A-LEINH(02)' P_LINE-LEINH02, "ACT.단위2
        ' ' 'RC68A-FORXX(02)' P_LINE-FOR02,   "계산식키2
        ' ' 'RC68A-LARXX(03)' P_LINE-LAR03,   "ACT.유형3
        ' ' 'RC68A-LEINH(03)' P_LINE-LEINH03, "ACT.단위3
        ' ' 'RC68A-FORXX(03)' P_LINE-FOR03,   "계산식키3
        ' ' 'RC68A-LARXX(04)' P_LINE-LAR04,   "ACT.유형4
        ' ' 'RC68A-LEINH(04)' P_LINE-LEINH04, "ACT.단위4
        ' ' 'RC68A-FORXX(04)' P_LINE-FOR04,   "계산식키4
        ' ' 'RC68A-LARXX(05)' P_LINE-LAR05,   "ACT.유형5
        ' ' 'RC68A-LEINH(05)' P_LINE-LEINH05, "ACT.단위5
        ' ' 'RC68A-FORXX(05)' P_LINE-FOR05,   "계산식키5
        ' ' 'RC68A-LARXX(06)' P_LINE-LAR06,   "ACT.유형6
        ' ' 'RC68A-LEINH(06)' P_LINE-LEINH06, "ACT.단위6
        ' ' 'RC68A-FORXX(06)' P_LINE-FOR06.   "계산식키6

  GS_PARAMS-DISMODE  = P_MODE. " 처리모드
  GS_PARAMS-UPDMODE  = 'S'.    " 갱신세션
  GS_PARAMS-CATTMODE = ' '.    " CATT모드
  GS_PARAMS-DEFSIZE  = ' '.    " 기본화면
  GS_PARAMS-RACOMMIT = 'X'.    " COMMIT 이후 지속
  GS_PARAMS-NOBINPT  = 'X'.    " BI 세션

  "처리
  IF P_LINE-ZTYPE EQ TEXT-M04. "변경
    CALL TRANSACTION 'CR02'
               USING BDCDATA
             OPTIONS FROM GS_PARAMS
            MESSAGES INTO MESSTAB.

  ELSEIF P_LINE-ZTYPE EQ TEXT-M05. "생성.
    CALL TRANSACTION 'CR01'
               USING BDCDATA
             OPTIONS FROM GS_PARAMS
            MESSAGES INTO MESSTAB.
  ENDIF.

  READ TABLE MESSTAB ASSIGNING FIELD-SYMBOL(<LS_MESSAGE>)
                     WITH KEY MSGTYP = GC_E.
  IF SY-SUBRC EQ 0.
    CLEAR: LV_MSG.
    CALL FUNCTION 'FORMAT_MESSAGE'
      EXPORTING
        ID        = <LS_MESSAGE>-MSGID
        LANG      = SY-LANGU
        NO        = <LS_MESSAGE>-MSGNR
        V1        = <LS_MESSAGE>-MSGV1
        V2        = <LS_MESSAGE>-MSGV2
        V3        = <LS_MESSAGE>-MSGV3
        V4        = <LS_MESSAGE>-MSGV4
      IMPORTING
        MSG       = LV_MSG
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.

    P_LINE-ZMESSAGE = LV_MSG.
    P_LINE-ZSTAT = ICON_LED_RED.

  ELSE.
    P_LINE-ZSTAT = ICON_LED_GREEN.

    IF P_LINE-ZTYPE EQ TEXT-M04. "변경
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          MSGID               = 'ZGTPP00'
          MSGNR               = '016'
          MSGV1               = P_LINE-ARBPL
        IMPORTING
          MESSAGE_TEXT_OUTPUT = P_LINE-ZMESSAGE.  "작업장(&1)을 변경 완료하였습니다.

    ELSEIF P_LINE-ZTYPE EQ TEXT-M05. "생성
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          MSGID               = 'ZGTPP00'
          MSGNR               = '017'
          MSGV1               = P_LINE-ARBPL
        IMPORTING
          MESSAGE_TEXT_OUTPUT = P_LINE-ZMESSAGE.  "작업장(&1)을 생성 완료하였습니다.

    ENDIF.
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
*& Form CONV_ALPHA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DATA_KOSTL
*&      --> GC_I
*&      <-- GS_DATA_KOSTL
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
*& Form SET_MODE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MODE .

  DATA: LT_VALUES TYPE VRM_VALUES,
        LS_VALUE  TYPE VRM_VALUE.

  DATA: LT_DOM_VALUES TYPE TABLE OF DD07V,
        LS_DOM_VALUE  TYPE DD07V.

  CLEAR: LT_DOM_VALUES.
  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      DOMNAME        = 'CTU_MODE'
      TEXT           = GC_T
    TABLES
      DD07V_TAB      = LT_DOM_VALUES
    EXCEPTIONS
      WRONG_TEXTFLAG = 1
      OTHERS         = 2.

  CLEAR: LT_VALUES.
  LOOP AT LT_DOM_VALUES INTO LS_DOM_VALUE.
    LS_VALUE-KEY = LS_DOM_VALUE-DOMVALUE_L.
    LS_VALUE-TEXT = LS_DOM_VALUE-DDTEXT.
    APPEND LS_VALUE TO LT_VALUES.
  ENDLOOP.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID     = 'P_MODE'   " 파라미터 이름
      VALUES = LT_VALUES.

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
