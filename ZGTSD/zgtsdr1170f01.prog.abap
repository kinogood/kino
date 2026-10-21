*&---------------------------------------------------------------------*
*& Include          ZGTSDR1170F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INITIALIZATION .

*-01. EXCEL TEMPLATE
  PERFORM SET_BUTTON.

  PA_VKORG = GC_VKORG_6000.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN .
  CASE SY-UCOMM.
    WHEN 'FC01'.
      PERFORM DOWNLOAD_EXCEL_TEMPLATE.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN_OUTPUT .
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 EQ 'ZM1'.
      SCREEN-INPUT = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_FILENAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_FILE
*&---------------------------------------------------------------------*
FORM F4_FILENAME  CHANGING P_FILE.

  DATA: LV_RC               TYPE I VALUE 1,
        LT_FILES            TYPE FILETABLE,
        LV_USER_ACTION      TYPE I,
        LV_DESKTOPDIRECTORY TYPE STRING,
        LV_TITLE            TYPE STRING.

  CLEAR: LV_TITLE.
  LV_TITLE = TEXT-T02.  "파일 열기

  CONCATENATE CL_GUI_FRONTEND_SERVICES=>FILETYPE_EXCEL
              CL_GUI_FRONTEND_SERVICES=>FILETYPE_ALL
         INTO DATA(LV_FILE_FILTER).

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GET_DESKTOP_DIRECTORY
    CHANGING
      DESKTOP_DIRECTORY = LV_DESKTOPDIRECTORY.

  CALL METHOD CL_GUI_CFW=>UPDATE_VIEW.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE      = LV_TITLE
      FILE_FILTER       = LV_FILE_FILTER
      INITIAL_DIRECTORY = LV_DESKTOPDIRECTORY
    CHANGING
      FILE_TABLE        = LT_FILES
      RC                = LV_RC
      USER_ACTION       = LV_USER_ACTION.

  IF LT_FILES[] IS NOT INITIAL.
    READ TABLE LT_FILES INTO P_FILE INDEX 1.
  ELSE.
    MESSAGE S000 DISPLAY LIKE GC_E  WITH 'FILE NOT SELECT'.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOWNLOAD_EXCEL_TEMPLATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DOWNLOAD_EXCEL_TEMPLATE .
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

  LV_OBJ = GC_OBJID.

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
        MESSAGE E000 WITH TEXT-M01. "파일명을 확인하세요.
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
        MESSAGE S000 DISPLAY LIKE GC_E
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
        MESSAGE E000 WITH TEXT-M02. "다운로드 중 오류가 발생하였습니다.
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
*& Form SET_BUTTON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BUTTON .
  DATA: LV_DYNTXT TYPE SMP_DYNTXT.

  LV_DYNTXT-TEXT = |{ TEXT-003 } { TEXT-002 }|.
  LV_DYNTXT-ICON_TEXT = TEXT-002.
  LV_DYNTXT-QUICKINFO = TEXT-002.
  SSCRFIELDS-FUNCTXT_01 = LV_DYNTXT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAIN .
*-01. INIT OBJECTS
  PERFORM INIT_OBJECTS.

*-02. CHECK INPUT
  PERFORM CHECK_INPUT_VALUE.

*-03. SET VALUES
  PERFORM SET_VALUES.

*-04. UPLOAD EXCEL
  PERFORM UPLOAD_EXCEL.

*-05. MAKE LIST
  PERFORM MAKE_LIST.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_OBJECTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_OBJECTS .
  CLEAR:
         GV_TITLE,GV_EDIT.

  REFRESH:
          GT_LIST,GT_EXCEL.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_INPUT_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_INPUT_VALUE .
  IF P_FILE IS INITIAL.
    MESSAGE S000 WITH TEXT-M16 DISPLAY LIKE GC_E.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VALUES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_VALUES .

  GV_TITLE = TEXT-004.

  GV_EDIT = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPLOAD_EXCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM UPLOAD_EXCEL .

  DATA: LT_EXCEL TYPE TABLE OF ZGTSDS1090.
  DATA: LO_NEW_LINE TYPE REF TO DATA,
        LO_STRU_REF TYPE REF TO CL_ABAP_STRUCTDESCR,
        LO_TAB_REF  TYPE REF TO CL_ABAP_TABLEDESCR.
  DATA: LV_END_COL TYPE I.

  PERFORM PROGRESS_INDICATOR USING TEXT-005.

  LO_TAB_REF  ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( GT_EXCEL ).
  LO_STRU_REF ?= LO_TAB_REF->GET_TABLE_LINE_TYPE( ).
  LV_END_COL = LINES( LO_STRU_REF->COMPONENTS ).

  CALL FUNCTION 'ZGTSD_EXCEL_UPLOAD_2'
    EXPORTING
      FILENAME                = P_FILE
      I_BEGIN_COL             = 1
      I_BEGIN_ROW             = 3
      I_END_COL               = LV_END_COL
      I_END_ROW               = 69999
*     I_SHEETS                =
*     I_SHEETNO               =
    TABLES
      INTERN                  = LT_EXCEL
    EXCEPTIONS
      INCONSISTENT_PARAMETERS = 1
      UPLOAD_OLE              = 2
      OTHERS                  = 3.

  IF SY-SUBRC <> 0.
    MESSAGE S000 WITH TEXT-M04 DISPLAY LIKE GC_E.
    LEAVE LIST-PROCESSING.
  ENDIF.

  SORT LT_EXCEL BY ROW COL.
  DATA: LV_COL_POS TYPE LVC_COLPOS.
  DATA: LV_INDEX LIKE SY-TABIX.

  TRY.
      LOOP AT LT_EXCEL INTO DATA(LS_EXCEL).
        IF LS_EXCEL IS INITIAL.
          CONTINUE.
        ENDIF.
        MOVE: LS_EXCEL-COL TO LV_INDEX.
        ASSIGN COMPONENT LV_INDEX OF STRUCTURE GS_EXCEL TO FIELD-SYMBOL(<FS_VAL>).
        CHECK SY-SUBRC EQ 0.

        DESCRIBE FIELD <FS_VAL> TYPE DATA(LV_TYPE).

        CASE LV_TYPE.
          WHEN GC_D. "DATE
            ZGTSD_CL_COMMON=>CONV_DATE_INPUT( CHANGING CV_INPUT = LS_EXCEL-VALUE ).
            <FS_VAL> = LS_EXCEL-VALUE.

          WHEN GC_T. "TIME
            ZGTSD_CL_COMMON=>CONV_TIME_INPUT( CHANGING CV_INPUT = LS_EXCEL-VALUE ).
            <FS_VAL> = LS_EXCEL-VALUE.

          WHEN GC_I  OR GC_P OR GC_N OR
               GC_SB OR GC_SS.

            PERFORM CONV_NUMC_INPUT CHANGING LS_EXCEL-VALUE.
            <FS_VAL> = LS_EXCEL-VALUE.

          WHEN GC_X. "RAW
            <FS_VAL> = LS_EXCEL-VALUE.
          WHEN GC_SG.
            <FS_VAL> = LS_EXCEL-VALUE.
          WHEN OTHERS.
            <FS_VAL> = LS_EXCEL-VALUE.
        ENDCASE.

        AT END OF ROW.
          APPEND GS_EXCEL TO GT_EXCEL.
          CLEAR:GS_EXCEL.
        ENDAT.
        IF <FS_VAL> IS ASSIGNED. UNASSIGN <FS_VAL>. ENDIF.
      ENDLOOP.

    CATCH CX_ROOT INTO DATA(LO_REF).

      DATA(LV_MSG) = LO_REF->GET_TEXT( ).
      MESSAGE I000 WITH TEXT-M04 LV_MSG.
      LEAVE LIST-PROCESSING.
  ENDTRY.

  GT_LIST[] = CORRESPONDING #( GT_EXCEL[] ).

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>).
    IF <FS_LIST>-KUNNR IS NOT INITIAL.
      <FS_LIST>-KUNNR = |{ <FS_LIST>-KUNNR ALPHA = IN }|.
    ENDIF.
    IF <FS_LIST>-CHECK_RULE IS NOT INITIAL.
      TRANSLATE <FS_LIST>-CHECK_RULE TO UPPER CASE.
    ENDIF.
    IF <FS_LIST>-CREDIT_SGMNT IS NOT INITIAL.
      TRANSLATE <FS_LIST>-CREDIT_SGMNT TO UPPER CASE.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONV_NUMC_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_VAL>
*&---------------------------------------------------------------------*
FORM CONV_NUMC_INPUT  CHANGING PV_VAL.
  DATA : LV_CURR_INPUT  TYPE STRING,
         LV_CHK_INPUT   TYPE STRING,
         LV_CURR_OUTPUT TYPE C LENGTH 30.
  DATA: LC_COMMA(1) TYPE C VALUE ',',
        LC_POINT(1) TYPE C VALUE '.'.

  CHECK PV_VAL IS NOT INITIAL.

  LV_CURR_INPUT = PV_VAL.

*     1.234.567,89
*  X  1,234,567.89
*  Y  1 234 567,89
  SELECT SINGLE DCPFM INTO @DATA(LV_DCPFM)
    FROM USR01
   WHERE BNAME EQ @SY-UNAME.

  CASE LV_DCPFM.
    WHEN SPACE.
      REPLACE ALL OCCURRENCES OF LC_POINT IN LV_CURR_INPUT WITH SPACE.
      REPLACE ALL OCCURRENCES OF LC_COMMA IN LV_CURR_INPUT WITH LC_POINT.
    WHEN GC_X.
      REPLACE ALL OCCURRENCES OF LC_COMMA IN LV_CURR_INPUT WITH SPACE.
    WHEN GC_Y.
      REPLACE ALL OCCURRENCES OF LC_COMMA IN LV_CURR_INPUT WITH LC_POINT.
  ENDCASE.

  CONDENSE LV_CURR_INPUT NO-GAPS.

  LV_CHK_INPUT = LV_CURR_INPUT.
  REPLACE ALL OCCURRENCES OF LC_POINT IN LV_CHK_INPUT WITH SPACE.
  REPLACE ALL OCCURRENCES OF LC_COMMA IN LV_CHK_INPUT WITH SPACE.
  CONDENSE LV_CHK_INPUT NO-GAPS.

  DATA:LV_TYPE TYPE DD01V-DATATYPE.
  CALL FUNCTION 'NUMERIC_CHECK'
    EXPORTING
      STRING_IN = LV_CHK_INPUT
    IMPORTING
*     STRING_OUT       =
      HTYPE     = LV_TYPE.
  IF LV_TYPE NE 'NUMC'.
    CLEAR PV_VAL.
    EXIT.
  ENDIF.



  PV_VAL = LV_CURR_INPUT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_LIST .

  CHECK GT_LIST[] IS NOT INITIAL.

*-01.영업그룹 => 여신세그먼트
  SELECT A~KKBER,B~CREDIT_SGMNT,C~CURRENCY, D~CREDIT_SGMNT_TXT
    FROM ZGTSDT1012 AS A INNER JOIN UKM_KKBER2SGM AS B
                         ON A~KKBER = B~KKBER
                         INNER JOIN UKMCRED_SGM0C AS C
                         ON B~CREDIT_SGMNT = C~CREDIT_SGMNT
                         INNER JOIN UKMCRED_SGM0T AS D
                         ON C~CREDIT_SGMNT = D~CREDIT_SGMNT AND
                            D~LANGU        = @SY-LANGU
   WHERE VKORG EQ @PA_VKORG
     AND LOEVM EQ @SPACE
    INTO TABLE @DATA(LT_ZGTSDT1012).
  SORT LT_ZGTSDT1012 BY CREDIT_SGMNT.

*-02. CHECK RULE
  SELECT A~CHECK_RULE,B~CHECK_RULE_TXT
    FROM UKM_CHCK_RULE AS A INNER JOIN UKM_CHCK_RULE0T AS B
                            ON A~CHECK_RULE = B~CHECK_RULE AND
                               B~LANGU      = @SY-LANGU
     INTO TABLE @DATA(LT_CHECK_RULE).

*-03. 판매처/BP
  DATA(LT_TEMP) = GT_LIST[].
  DELETE LT_TEMP WHERE KUNNR IS INITIAL.
  SORT LT_TEMP BY KUNNR.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING KUNNR.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT A~KUNNR, A~NAME1, C~PARTNER
      FROM KNA1 AS A LEFT OUTER JOIN CVI_CUST_LINK AS B
                     ON A~KUNNR = B~CUSTOMER
                     LEFT OUTER JOIN BUT000 AS C
                     ON B~PARTNER_GUID = C~PARTNER_GUID
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE A~KUNNR EQ @LT_TEMP-KUNNR
      INTO TABLE @DATA(LT_KNA1).
    SORT LT_KNA1 BY KUNNR.
  ENDIF.

*-03.LIST 구성
  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>).

    "필수필드 체크
    PERFORM CHECK_REQUIRED_VALUE CHANGING <FS_LIST>.

    "판매처/BP
    IF <FS_LIST>-KUNNR IS NOT INITIAL.
      DATA(LS_KNA1) = VALUE #( LT_KNA1[ KUNNR = <FS_LIST>-KUNNR ] OPTIONAL ).
      IF LS_KNA1 IS INITIAL.
        <FS_LIST>-RSLT1 = GC_E.
        IF <FS_LIST>-MESSAGE IS NOT INITIAL.
          <FS_LIST>-MESSAGE = |{ <FS_LIST>-MESSAGE }/{ TEXT-M06 }|.
        ELSE.
          <FS_LIST>-MESSAGE = TEXT-M06.
        ENDIF.
      ELSE.
        "판매처 명
        <FS_LIST>-KUNNR_TX = LS_KNA1-NAME1.

        "BP
        IF LS_KNA1-PARTNER IS NOT INITIAL.
          <FS_LIST>-PARTNER = LS_KNA1-PARTNER.
        ELSE.
          <FS_LIST>-RSLT1 = GC_E.
          IF <FS_LIST>-MESSAGE IS NOT INITIAL.
            <FS_LIST>-MESSAGE = |{ <FS_LIST>-MESSAGE }/{ TEXT-M07 }|.
          ELSE.
            <FS_LIST>-MESSAGE = TEXT-M07.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    "점검규칙
    IF <FS_LIST>-CHECK_RULE IS NOT INITIAL.
      DATA(LS_CHECK_RULE) = VALUE #( LT_CHECK_RULE[ CHECK_RULE = <FS_LIST>-CHECK_RULE ] OPTIONAL ).
      IF LS_CHECK_RULE IS NOT INITIAL.
        <FS_LIST>-CHECK_RULE_TX = LS_CHECK_RULE-CHECK_RULE_TXT.
      ELSE.
        <FS_LIST>-RSLT1 = GC_E.
        IF <FS_LIST>-MESSAGE IS NOT INITIAL.
          <FS_LIST>-MESSAGE = |{ <FS_LIST>-MESSAGE }/{ TEXT-M08 }|.
        ELSE.
          <FS_LIST>-MESSAGE = TEXT-M08.
        ENDIF.
      ENDIF.
    ENDIF.

    "여신세그먼트
    IF <FS_LIST>-CREDIT_SGMNT IS NOT INITIAL.
      DATA(LS_ZGTSDT1012) = VALUE #( LT_ZGTSDT1012[ CREDIT_SGMNT = <FS_LIST>-CREDIT_SGMNT ] OPTIONAL ).
      IF LS_ZGTSDT1012 IS NOT INITIAL.
        <FS_LIST>-CREDIT_SGMNT_TX = LS_ZGTSDT1012-CREDIT_SGMNT_TXT.
        <FS_LIST>-CURRENCY        = LS_ZGTSDT1012-CURRENCY.
      ELSE.
        <FS_LIST>-RSLT1 = GC_E.
        IF <FS_LIST>-MESSAGE IS NOT INITIAL.
          <FS_LIST>-MESSAGE = |{ <FS_LIST>-MESSAGE }/{ TEXT-M09 }|.
        ELSE.
          <FS_LIST>-MESSAGE = TEXT-M09.
        ENDIF.
      ENDIF.
    ENDIF.

    "기본한도
    IF <FS_LIST>-CREDIT_LIMIT NE 0 AND <FS_LIST>-CURRENCY IS NOT INITIAL.
      CALL FUNCTION 'CURRENCY_AMOUNT_IDOC_TO_SAP'
        EXPORTING
          CURRENCY    = <FS_LIST>-CURRENCY
          IDOC_AMOUNT = <FS_LIST>-CREDIT_LIMIT
        IMPORTING
          SAP_AMOUNT  = <FS_LIST>-CREDIT_LIMIT.
    ENDIF.

    "LED
    PERFORM SET_LED CHANGING <FS_LIST>.

    CLEAR:LS_KNA1,LS_CHECK_RULE,LS_ZGTSDT1012.
  ENDLOOP.

*-04. 중복 체크
  PERFORM CHECK_DUPLICATES_DATA.

*-05. 점검규칙
  PERFORM CHECK_RULE_DIFF.

  IF LINE_EXISTS( GT_LIST[ RSLT1 = GC_E ] ).
    MESSAGE I000 WITH TEXT-M11 DISPLAY LIKE GC_W.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_REQUIRED_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_LIST
*&---------------------------------------------------------------------*
FORM CHECK_REQUIRED_VALUE  CHANGING PS_LIST LIKE GS_LIST.
  DATA:LV_MSG(100).

  "판매처
  IF PS_LIST-KUNNR IS INITIAL.
    PS_LIST-RSLT1 = GC_E.
    LV_MSG = TEXT-H04.
  ENDIF.
  "점검규칙
  IF PS_LIST-CHECK_RULE IS INITIAL.
    PS_LIST-RSLT1 = GC_E.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }/{ TEXT-H07 }|.
    ELSE.
      LV_MSG = TEXT-H07.
    ENDIF.
  ENDIF.
  "여신세그먼트
  IF PS_LIST-CREDIT_SGMNT IS INITIAL.
    PS_LIST-RSLT1 = GC_E.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }/{ TEXT-H09 }|.
    ELSE.
      LV_MSG = TEXT-H09.
    ENDIF.
  ENDIF.
  "기본한도
  IF PS_LIST-CREDIT_LIMIT <= 0.
    PS_LIST-RSLT1 = GC_E.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }/{ TEXT-H11 }|.
    ELSE.
      LV_MSG = TEXT-H11.
    ENDIF.
  ENDIF.

  IF PS_LIST-RSLT1 = GC_E.
    MESSAGE S007 WITH LV_MSG INTO PS_LIST-MESSAGE.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_LIST
*&---------------------------------------------------------------------*
FORM SET_LED  CHANGING PS_LIST LIKE GS_LIST.

  CASE PS_LIST-RSLT1.
    WHEN GC_E.
      PS_LIST-STAT1 = ICON_LED_RED.

    WHEN OTHERS.
      PS_LIST-STAT1 = ICON_LED_GREEN.
  ENDCASE.

  CASE PS_LIST-RSLT2.
    WHEN GC_S.
      PS_LIST-STAT2 = ICON_LED_GREEN.
    WHEN GC_E.
      PS_LIST-STAT2 = ICON_LED_RED.
    WHEN OTHERS.
      PS_LIST-STAT2 = ICON_LED_YELLOW.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY .
  IF GT_LIST[] IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE S000 WITH TEXT-M10 DISPLAY LIKE GC_E.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_ALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECT_ALL .
  CLEAR GS_LIST.
  MODIFY GT_LIST FROM GS_LIST TRANSPORTING SEL WHERE SEL EQ GC_X.

  GS_LIST-SEL = GC_X.
  MODIFY GT_LIST FROM GS_LIST TRANSPORTING SEL WHERE SEL EQ SPACE
                                                 AND RSLT1 NE GC_E
                                                 AND RSLT2 NE GC_S.

  PERFORM REFRESH_ALV USING GO_GRID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DESELECT_ALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DESELECT_ALL .
  CLEAR GS_LIST.
  MODIFY GT_LIST FROM GS_LIST TRANSPORTING SEL WHERE SEL EQ GC_X.

  PERFORM REFRESH_ALV USING GO_GRID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAINTAIN_BP_CREDIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAINTAIN_BP_CREDIT .
  DATA:LV_CHK(1).

  PERFORM CHECK_CHANGED_DATA USING GO_GRID.

*-선택라인
  LOOP AT GT_LIST INTO DATA(LS_LIST) WHERE SEL   EQ GC_X
                                       AND RSLT1 NE GC_E
                                       AND RSLT2 NE GC_S.
    LV_CHK = GC_X.
    EXIT.
  ENDLOOP.
  IF LV_CHK IS INITIAL.
    MESSAGE I004 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.
*  IF NOT ( LINE_EXISTS( GT_LIST[ SEL = GC_X ] ) ).
*    MESSAGE I004 DISPLAY LIKE GC_E.
*    EXIT.
*  ENDIF.

  CHECK ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-P01 ) EQ GC_J.


*-MAINTAIN BP CREDIT
  PERFORM MAINTAIN_BP_CREDIT_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAINTAIN_BP_CREDIT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAINTAIN_BP_CREDIT_DATA .

  CLEAR GV_ERROR.

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>) WHERE SEL  EQ GC_X
                                                      AND RSLT1 NE GC_E "엑셀에러
                                                      AND RSLT2 NE GC_S."처리완료
    CLEAR:<FS_LIST>-RSLT2,<FS_LIST>-MESSAGE,<FS_LIST>-STAT2.
    PERFORM UPLOAD_BP_CREDIT_DATA CHANGING <FS_LIST>.

    PERFORM SET_ATTRIBUTES_LINE CHANGING <FS_LIST>.

    PERFORM SET_LED CHANGING <FS_LIST>.
    CLEAR:<FS_LIST>-SEL.
  ENDLOOP.

  IF GV_ERROR IS NOT INITIAL.
    MESSAGE I000 WITH TEXT-M15 DISPLAY LIKE GC_E.
  ENDIF.

  PERFORM REFRESH_ALV USING GO_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPLOAD_BP_CREDIT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM UPLOAD_BP_CREDIT_DATA  CHANGING PS_LIST LIKE GS_LIST.
  DATA: IO_FACADE       TYPE REF TO CL_UKM_FACADE,
        IO_PARTNER      TYPE REF TO CL_UKM_BUSINESS_PARTNER,
        IO_BUPA_FACTORY TYPE REF TO CL_UKM_BUPA_FACTORY,
        IO_ACCOUNT      TYPE REF TO CL_UKM_ACCOUNT.

  DATA: LS_BP_CREDIT_SGM TYPE UKM_S_BP_CMS_SGM,
        LS_UKM_S_BP_CMS  TYPE UKM_S_BP_CMS,
        LT_BP1012        TYPE UKM_T_BP1012,
        LV_GRADE         TYPE BP_GRADE,
        LS_NEW_SCORE     TYPE BAPI_STR_BUPA_FS_RATING,
        LS_OLD_SCORE     TYPE BAPI_STR_BUPA_FS_RATING,
        LT_ADD_INFO      TYPE UKM_TS_ADD_INFO,
        LS_ADD_INFO      TYPE UKM_S_ADD_INFO.

  DATA: LS_BUPA_ERROR TYPE MDS_CTRLS_ERROR.

  DATA: LV_PARTNER      TYPE BU_PARTNER,
        LV_CREDIT_SGMNT TYPE UKM_CREDIT_SGMNT,
        LV_CREDIT_GROUP TYPE UKM_CRED_GROUP,
        LV_CREDIT_LIMIT TYPE UKM_S_BP_CMS_SGM-CREDIT_LIMIT.

  DATA: LV_AMT  TYPE UKM_AMOUNT,
        LV_DATE TYPE SY-DATUM.

  DATA: LT_RETURN   TYPE UKM_T_MONITOR_RETURN,
        LT_RET2     TYPE TABLE OF BAPIRET2,
        LS_BAPIRET2 TYPE BAPIRET2.

  DATA: LV_CMS_CHK(1),
        LV_SGM_CHK(1).

  DATA: LV_MSG(100).

  LV_PARTNER = PS_LIST-PARTNER.


*-------------------------------------------------------
*-01. CREDIT ROLE
*-------------------------------------------------------
  SELECT SINGLE PARTNER
    FROM BUT100
   WHERE PARTNER EQ @LV_PARTNER
     AND RLTYP   EQ 'UKM000'
    INTO @DATA(LV_PART).
  IF SY-SUBRC NE 0.
    CALL FUNCTION 'BAPI_BUPA_ROLE_ADD_2'
      EXPORTING
        BUSINESSPARTNER             = LV_PARTNER
        BUSINESSPARTNERROLECATEGORY = 'UKM000'
        BUSINESSPARTNERROLE         = 'UKM000'
      TABLES
        RETURN                      = LT_RET2.
    LOOP AT LT_RET2 INTO DATA(LS_RET2) WHERE TYPE CA 'AE'.
      EXIT.
    ENDLOOP.
    IF SY-SUBRC EQ 0.
      __BAPI_TRANSACTION_ROLLBACK.

      PS_LIST-RSLT2 = GC_E.
      LOOP AT LT_RET2 INTO LS_RET2 WHERE TYPE CA 'AE'.
        CLEAR:LV_MSG.
        CALL FUNCTION 'MESSAGE_TEXT_BUILD'
          EXPORTING
            MSGID               = LS_RET2-ID
            MSGNR               = LS_RET2-NUMBER
            MSGV1               = LS_RET2-MESSAGE_V1
            MSGV2               = LS_RET2-MESSAGE_V2
            MSGV3               = LS_RET2-MESSAGE_V3
            MSGV4               = LS_RET2-MESSAGE_V4
          IMPORTING
            MESSAGE_TEXT_OUTPUT = LV_MSG.
        IF PS_LIST-MESSAGE IS NOT INITIAL.
          PS_LIST-MESSAGE = |{ PS_LIST-MESSAGE }/{ LV_MSG }|.
        ELSE.
          PS_LIST-MESSAGE = LV_MSG.
        ENDIF.
      ENDLOOP.
      EXIT.
    ENDIF.

    __BAPI_TRANSACTION_COMMIT.
    WAIT UP TO '0.5' SECONDS.
  ENDIF.


  "BP LOCK 체크
  DATA(LO_BUPA) = NEW CL_IM_MDS_BUPA_LOCK( ).

  CALL METHOD LO_BUPA->IF_EX_BUPA_LOCK~LOCK
    EXPORTING
      IV_PARTNER = LV_PARTNER
    CHANGING
      CS_ERROR   = LS_BUPA_ERROR.

  IF LS_BUPA_ERROR-IS_ERROR IS NOT INITIAL.
    PS_LIST-RSLT2 = GC_E.
    DATA(LS_MSG) = VALUE #( LS_BUPA_ERROR-MESSAGES[ TYPE = GC_E
                                                    ID = 'MC'
                                                    NUMBER = '601' ] OPTIONAL ).
    IF LS_MSG IS NOT INITIAL.
      PS_LIST-MESSAGE = LS_MSG-MESSAGE.
    ELSE.
      LOOP AT LS_BUPA_ERROR-MESSAGES INTO LS_MSG WHERE TYPE EQ GC_E.
        IF PS_LIST-MESSAGE IS INITIAL.
          PS_LIST-MESSAGE = LS_MSG-MESSAGE.
        ELSE.
          PS_LIST-MESSAGE = |{ PS_LIST-MESSAGE }/{ LS_MSG-MESSAGE }|.
        ENDIF.
      ENDLOOP.
    ENDIF.
    EXIT.
  ENDIF.

  IO_FACADE       = CL_UKM_FACADE=>CREATE( I_ACTIVITY = CL_UKM_CNST_EVENTING=>BP_MAINTENANCE ).
  IO_BUPA_FACTORY = IO_FACADE->GET_BUPA_FACTORY( ).
  IO_PARTNER      = IO_BUPA_FACTORY->GET_BUSINESS_PARTNER( LV_PARTNER ).

*-------------------------------------------------------
*-02. CREDIT PROFILE
*-------------------------------------------------------

*-일반정보 유지보수
  IO_PARTNER->GET_BP_CMS( IMPORTING ES_BP_CMS = LS_UKM_S_BP_CMS ).
  IF LS_UKM_S_BP_CMS IS INITIAL.
    LV_CMS_CHK = GC_X.

    LS_UKM_S_BP_CMS-CHECK_RULE = PS_LIST-CHECK_RULE.
    LS_UKM_S_BP_CMS-RISK_CLASS = GC_RISK_CLASS_001. "'001'.

  ELSE.
    IF NOT ( LS_UKM_S_BP_CMS-CHECK_RULE EQ PS_LIST-CHECK_RULE AND
             LS_UKM_S_BP_CMS-RISK_CLASS EQ GC_RISK_CLASS_001       ).
      LV_CMS_CHK = GC_X.

      LS_UKM_S_BP_CMS-CHECK_RULE = PS_LIST-CHECK_RULE.
      LS_UKM_S_BP_CMS-RISK_CLASS = GC_RISK_CLASS_001.
    ENDIF.

  ENDIF.
  IF LV_CMS_CHK = GC_X.
    IO_PARTNER->SET_BP_CMS( LS_UKM_S_BP_CMS ).
  ENDIF.

*-------------------------------------------------------
*-03. CREDIT SEGMENT
*-------------------------------------------------------
  LV_CREDIT_SGMNT = PS_LIST-CREDIT_SGMNT.
  LV_CREDIT_LIMIT = PS_LIST-CREDIT_LIMIT.

  CALL METHOD IO_BUPA_FACTORY->GET_CREDIT_ACCOUNT
    EXPORTING
      I_PARTNER         = LV_PARTNER
      I_CREDIT_SGMNT    = LV_CREDIT_SGMNT
    RECEIVING
      RO_CREDIT_ACCOUNT = IO_ACCOUNT.

  SELECT SINGLE PARTNER
    FROM UKMBP_CMS_SGM
   WHERE PARTNER      EQ @LV_PARTNER
     AND CREDIT_SGMNT EQ @LV_CREDIT_SGMNT
    INTO @LV_PART.
  IF SY-SUBRC EQ 0.
    IO_ACCOUNT->GET_BP_CMS_SGM( EXPORTING
                                  I_DB_READ = GC_X
                                IMPORTING
                                  ES_BP_CMS_SGM = LS_BP_CREDIT_SGM
                              ).

    IF LS_BP_CREDIT_SGM-CREDIT_LIMIT NE LV_CREDIT_LIMIT.
      LV_SGM_CHK = GC_X.

      LS_BP_CREDIT_SGM-CREDIT_LIMIT   = LV_CREDIT_LIMIT.
      LS_BP_CREDIT_SGM-LIMIT_CHG_DATE = SY-DATLO.
    ENDIF.

  ELSE.
    LV_SGM_CHK = GC_X.

    LS_BP_CREDIT_SGM-CREDIT_LIMIT   = LV_CREDIT_LIMIT.
    LS_BP_CREDIT_SGM-LIMIT_CHG_DATE = SY-DATLO.
  ENDIF.

  IF LV_SGM_CHK = GC_X.
    IO_ACCOUNT->SET_BP_CMS_SGM( EXPORTING IS_BP_CMS_SGM = LS_BP_CREDIT_SGM ).
  ENDIF.

*-------------------------------------------------------
*-04. SAVE
*-------------------------------------------------------
  IF LV_CMS_CHK IS INITIAL AND
     LV_SGM_CHK IS INITIAL.
    PS_LIST-RSLT2   = GC_S.
    PS_LIST-MESSAGE = TEXT-M12.


  ELSE.
    CALL METHOD IO_BUPA_FACTORY->SAVE_ALL
      EXPORTING
        I_UPD_TASK = ABAP_FALSE
*       I_FREE_ALL = NO
*       I_WITH_EXTERNAL_SCORINGS = NO
*       I_WITH_ADD_INFOS = ABAP_TRUE
*       I_WITH_VECTORS   = NO
*       I_WITH_ENQUEUE   = NO
*       I_FROM_HCP = NO
*       I_TESTRUN  = NO
      RECEIVING
        ET_RETURN  = LT_RETURN
      EXCEPTIONS
        FAILED     = 1
        OTHERS     = 2.
    IF LINE_EXISTS( LT_RETURN[ MSGTY = 'E' ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      PS_LIST-RSLT2 = GC_E.
      PS_LIST-MESSAGE = TEXT-M13.
      LOOP AT LT_RETURN INTO DATA(LS_RETURN) WHERE MSGTY EQ GC_E.
        PS_LIST-MESSAGE = |{ PS_LIST-MESSAGE }/{ LS_RETURN-MESSAGE }|.
      ENDLOOP.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.

      PS_LIST-RSLT2   = GC_S.
      PS_LIST-MESSAGE = TEXT-S01.

    ENDIF.
  ENDIF.

  IO_BUPA_FACTORY->REFRESH_PREREAD_BUFFER( ).

  CALL METHOD LO_BUPA->IF_EX_BUPA_LOCK~UNLOCK
    EXPORTING
      IV_PARTNER = LV_PARTNER
    CHANGING
      CS_ERROR   = LS_BUPA_ERROR.

  IO_BUPA_FACTORY->FREE_ALL( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> TEXT_005
*&---------------------------------------------------------------------*
FORM PROGRESS_INDICATOR  USING    PV_TEXT.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     percentage = l_percent
      TEXT = PV_TEXT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_DOUBLE_CLICK_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_E_ROW
*&      --> PS_E_COLUMN
*&---------------------------------------------------------------------*
FORM ALV_DOUBLE_CLICK_0100  USING    PS_E_ROW  TYPE LVC_S_ROW
                                     PS_E_COLUMN TYPE LVC_S_COL.

  READ TABLE GT_LIST INTO DATA(LS_LIST) INDEX PS_E_ROW-INDEX.
  CHECK SY-SUBRC EQ 0.

  CASE PS_E_COLUMN-FIELDNAME.
    WHEN 'KUNNR'.
      IF LS_LIST-KUNNR   IS NOT INITIAL AND
         LS_LIST-PARTNER IS NOT INITIAL.

        ZGTSD_CL_COMMON2=>BP_DISPLAY( IV_PARTNER = LS_LIST-PARTNER
                                      IV_ROLE    = GC_ROLE_UKM000   ).
      ENDIF.

    WHEN 'PARTNER'.
      IF LS_LIST-PARTNER IS NOT INITIAL.
        ZGTSD_CL_COMMON2=>BP_DISPLAY( IV_PARTNER = LS_LIST-PARTNER
                                      IV_ROLE    = GC_ROLE_UKM000   ).
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DUPLICATES_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_DUPLICATES_DATA .
  DATA: LV_CNT TYPE I.

  CHECK GT_LIST[] IS NOT INITIAL.

  DATA(LT_TEMP) = GT_LIST[].

  DELETE LT_TEMP WHERE KUNNR IS INITIAL.
  DELETE LT_TEMP WHERE CREDIT_SGMNT IS INITIAL.
  SORT LT_TEMP BY KUNNR CREDIT_SGMNT.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING KUNNR CREDIT_SGMNT.

  LOOP AT LT_TEMP INTO DATA(LS_TEMP).
    CLEAR LV_CNT.

    LV_CNT = REDUCE I( INIT X TYPE I
                       FOR LS_LIST IN GT_LIST
                        WHERE ( KUNNR        = LS_TEMP-KUNNR AND
                                CREDIT_SGMNT = LS_TEMP-CREDIT_SGMNT )
                       NEXT X = X + 1
                     ).
    IF LV_CNT > 1.
      LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>) WHERE KUNNR        = LS_TEMP-KUNNR
                                                          AND CREDIT_SGMNT = LS_TEMP-CREDIT_SGMNT.
        <FS_LIST>-RSLT1 = GC_E.
        IF <FS_LIST>-MESSAGE IS NOT INITIAL.
          <FS_LIST>-MESSAGE = |{ <FS_LIST>-MESSAGE }/{ TEXT-M17 }|.
        ELSE.
          <FS_LIST>-MESSAGE = TEXT-M17.
        ENDIF.
        PERFORM SET_LED CHANGING <FS_LIST>.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_RULE_DIFF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_RULE_DIFF .
  DATA:LV_CHK(1).

  CHECK GT_LIST[] IS NOT INITIAL.

  DATA(LT_TEMP) = GT_LIST[].
  DELETE LT_TEMP WHERE KUNNR IS INITIAL.
  DELETE LT_TEMP WHERE CHECK_RULE IS INITIAL.

  SORT LT_TEMP BY KUNNR CHECK_RULE.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING KUNNR.

  LOOP AT LT_TEMP INTO DATA(LS_TEMP).
    CLEAR LV_CHK.
    LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>) WHERE KUNNR      EQ LS_TEMP-KUNNR
                                                        AND CHECK_RULE NE SPACE
                                                        AND CHECK_RULE NE LS_TEMP-CHECK_RULE.
      LV_CHK = GC_X.
      <FS_LIST>-RSLT1 = GC_E.
      IF <FS_LIST>-MESSAGE IS NOT INITIAL.
        <FS_LIST>-MESSAGE = |{ <FS_LIST>-MESSAGE }/{ TEXT-M18 }|.
      ELSE.
        <FS_LIST>-MESSAGE = TEXT-M18.
      ENDIF.
      PERFORM SET_LED CHANGING <FS_LIST>.
    ENDLOOP.
    IF LV_CHK IS NOT INITIAL.
      LOOP AT GT_LIST ASSIGNING <FS_LIST> WHERE KUNNR      EQ LS_TEMP-KUNNR
                                            AND CHECK_RULE EQ LS_TEMP-CHECK_RULE.
        LV_CHK = GC_X.
        <FS_LIST>-RSLT1 = GC_E.
        IF <FS_LIST>-MESSAGE IS NOT INITIAL.
          <FS_LIST>-MESSAGE = |{ <FS_LIST>-MESSAGE }/{ TEXT-M18 }|.
        ELSE.
          <FS_LIST>-MESSAGE = TEXT-M18.
        ENDIF.
        PERFORM SET_LED CHANGING <FS_LIST>.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
ENDFORM.
