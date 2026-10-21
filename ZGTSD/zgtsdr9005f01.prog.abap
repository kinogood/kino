*&---------------------------------------------------------------------*
*& Include          ZGTSDR9002F01
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
*  DATA: LV_DYNTXT TYPE SMP_DYNTXT.
*
*  LV_DYNTXT-TEXT = |{ TEXT-007 } { TEXT-008 }|.
*  LV_DYNTXT-ICON_TEXT = TEXT-008.
*  LV_DYNTXT-QUICKINFO = TEXT-008.
*  SSCRFIELDS-FUNCTXT_01 = LV_DYNTXT.
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
*  CASE SY-UCOMM.
*    WHEN 'FC01'.
*      PERFORM DOWNLOAD_EXCEL_TEMPLATE.
*  ENDCASE.
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
  GV_TITLE = TEXT-002.

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
    IF <FS_LIST>-VBELN IS NOT INITIAL.
      <FS_LIST>-VBELN = |{ <FS_LIST>-VBELN ALPHA = IN }|.
    ENDIF.
  ENDLOOP.

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
  DATA:LV_MSG(100).
  DATA:LV_CNT TYPE I.

  CHECK GT_LIST[] IS NOT INITIAL.
  SORT GT_LIST BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM GT_LIST COMPARING VBELN POSNR.

* SO
  DATA(LT_TEMP) = GT_LIST[].
  SORT LT_TEMP BY VBELN POSNR.
  DELETE LT_TEMP WHERE VBELN EQ SPACE.
  DELETE LT_TEMP WHERE POSNR IS INITIAL.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT VBELN,POSNR,PSTYV,BEDAE
      FROM VBAP
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE VBELN EQ @LT_TEMP-VBELN
       AND POSNR EQ @LT_TEMP-POSNR
      INTO TABLE @DATA(LT_VBAP).
    SORT LT_VBAP BY VBELN POSNR.
  ENDIF.

** MARC
*  DATA(LT_TEMP10) = LT_VBAP[].
*  SORT LT_TEMP10 BY MATNR WERKS.
*  DELETE ADJACENT DUPLICATES FROM LT_TEMP10 COMPARING MATNR WERKS.
*  IF LT_TEMP10[] IS NOT INITIAL.
*    SELECT MATNR,WERKS,PRCTR
*      FROM MARC
*       FOR ALL ENTRIES IN @LT_TEMP10
*     WHERE MATNR EQ @LT_TEMP10-MATNR
*       AND WERKS EQ @LT_TEMP10-WERKS
*      INTO TABLE @DATA(LT_MARC).
*    SORT LT_MARC BY MATNR WERKS.
*  ENDIF.

  CLEAR GV_INDEX.
  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>).
    GV_INDEX = SY-TABIX.

    CLEAR:LV_MSG.
    IF <FS_LIST>-VBELN IS INITIAL.
      <FS_LIST>-RSLT1   = GC_E.
      LV_MSG = TEXT-M05.
    ENDIF.
    IF <FS_LIST>-POSNR IS INITIAL.
      <FS_LIST>-RSLT1   = GC_E.
      IF LV_MSG IS NOT INITIAL.
        LV_MSG = |{ LV_MSG },{ TEXT-M06 }|.
      ELSE.
        LV_MSG = TEXT-M06.
      ENDIF.
    ENDIF.
    IF LV_MSG IS NOT INITIAL.
      <FS_LIST>-MESSAGE = |{ LV_MSG } { TEXT-006 }|.
    ENDIF.


    CLEAR LV_MSG.
    DATA(LS_VBAP) = VALUE #( LT_VBAP[ VBELN = <FS_LIST>-VBELN POSNR = <FS_LIST>-POSNR ] OPTIONAL ).
    IF LS_VBAP IS INITIAL.
      <FS_LIST>-RSLT1   = GC_E.
      IF <FS_LIST>-MESSAGE IS NOT INITIAL.
        <FS_LIST>-MESSAGE = |{ <FS_LIST>-MESSAGE }/{ TEXT-M08 }|.
      ELSE.
        <FS_LIST>-MESSAGE = TEXT-M08.
      ENDIF.
    ELSE.
      <FS_LIST>-BEDAE_O = LS_VBAP-BEDAE.

      ""ITEM CATEGORY :ZHAW
      IF LS_VBAP-PSTYV NE 'ZHAW'.
        DELETE GT_LIST INDEX GV_INDEX.

        CLEAR: LS_VBAP.
        CONTINUE.
      ENDIF.


*      "MARC
*      DATA(LS_MARC) = VALUE #( LT_MARC[ MATNR = LS_VBAP-MATNR WERKS = LS_VBAP-WERKS ] OPTIONAL ).
*      IF LS_MARC IS NOT INITIAL.
*
*        IF LS_MARC-PRCTR IS NOT INITIAL.
*          <FS_LIST>-PRCTR = LS_MARC-PRCTR.
*        ELSE.
*          <FS_LIST>-RSLT1   = GC_E.
*          IF <FS_LIST>-MESSAGE IS NOT INITIAL.
*            <FS_LIST>-MESSAGE = |{ <FS_LIST>-MESSAGE }/{ TEXT-M18 }|.
*          ELSE.
*            <FS_LIST>-MESSAGE = TEXT-M18.
*          ENDIF.
*        ENDIF.
*
*      ELSE.
*        <FS_LIST>-RSLT1   = GC_E.
*        IF <FS_LIST>-MESSAGE IS NOT INITIAL.
*          <FS_LIST>-MESSAGE = |{ <FS_LIST>-MESSAGE }/{ TEXT-M17 }|.
*        ELSE.
*          <FS_LIST>-MESSAGE = TEXT-M17.
*        ENDIF.
*      ENDIF.
    ENDIF.

    IF <FS_LIST>-RSLT1 NE GC_E.
      <FS_LIST>-RSLT1 = GC_S.
      IF <FS_LIST>-BEDAE_O EQ <FS_LIST>-BEDAE.
        <FS_LIST>-RSLT2 = GC_S.
        <FS_LIST>-MESSAGE = TEXT-M09.
      ENDIF.

    ENDIF.

    PERFORM SET_LED CHANGING <FS_LIST>.

    CLEAR: LS_VBAP.
  ENDLOOP.

*  "중복라인
*  CLEAR:LT_TEMP[].
*  LT_TEMP[] = GT_LIST[].
*  SORT LT_TEMP BY VBELN POSNR.
*  DELETE LT_TEMP WHERE VBELN EQ SPACE.
*  DELETE LT_TEMP WHERE POSNR IS INITIAL.
*  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VBELN POSNR.
*
*  LOOP AT LT_TEMP INTO DATA(LS_TEMP).
*    CLEAR LV_CNT.
*    LV_CNT = REDUCE #( INIT X TYPE I
*                       FOR LS_LINE IN GT_LIST
*                          WHERE ( VBELN = LS_TEMP-VBELN AND
*                                  POSNR = LS_TEMP-POSNR     )
*                       NEXT X = X + 1
*                     ).
*
*    IF LV_CNT > 1.
*      LOOP AT GT_LIST ASSIGNING <FS_LIST> WHERE VBELN = LS_TEMP-VBELN
*                                            AND POSNR = LS_TEMP-POSNR.
*        <FS_LIST>-RSLT1 = GC_E.
*        IF <FS_LIST>-MESSAGE IS NOT INITIAL.
*          <FS_LIST>-MESSAGE = |{ <FS_LIST>-MESSAGE }/{ TEXT-M14 }|.
*        ELSE.
*          <FS_LIST>-MESSAGE = TEXT-M14.
*        ENDIF.
*        PERFORM SET_LED CHANGING <FS_LIST>.
*      ENDLOOP.
*    ENDIF.
*
*  ENDLOOP.

  DELETE GT_LIST WHERE RSLT1   EQ GC_S
                   AND BEDAE_O NE 'KEB'.

  FREE:LT_TEMP,LS_VBAP,LT_VBAP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONV_NUMC_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LS_EXCEL_VALUE
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
*& Form PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> TEXT_005
*&---------------------------------------------------------------------*
FORM PROGRESS_INDICATOR  USING PV_TEXT.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     percentage = l_percent
      TEXT = PV_TEXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM SET_LED  CHANGING PS_LIST LIKE GT_LIST.

  IF PS_LIST-RSLT1 EQ GC_E.
    PS_LIST-STAT1 = ICON_LED_RED.
  ELSE.
    PS_LIST-STAT1 = ICON_LED_GREEN.
  ENDIF.

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
*& Form SELECT_ALL_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECT_ALL_0100 .
  CLEAR GS_LIST.
  GS_LIST-SEL = GC_X.
  MODIFY GT_LIST FROM GS_LIST TRANSPORTING SEL WHERE SEL    EQ SPACE
                                                 AND RSLT1  NE GC_E
                                                 AND RSLT2  NE GC_S.

  PERFORM REFRESH_ALV USING GO_GRID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DESELECT_ALL_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DESELECT_ALL_0100 .
  CLEAR GS_LIST.

  MODIFY GT_LIST FROM GS_LIST TRANSPORTING SEL WHERE SEL  NE SPACE.


  PERFORM REFRESH_ALV USING GO_GRID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_SO_ATTRIBUTES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_SO_ATTRIBUTES .
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

  CHECK ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-P01 ) EQ GC_J.

  "SO 변경
  PERFORM CHANGE_SO_DOC.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_SO_DOC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_SO_DOC .
  DATA: LV_SALESDOCUMENT    TYPE BAPIVBELN-VBELN,
        LS_ORDER_HEADER_IN  TYPE BAPISDH1,
        LS_ORDER_HEADER_INX TYPE BAPISDH1X,
        LT_ORDER_ITEM_IN    TYPE TABLE OF BAPISDITM,
        LT_ORDER_ITEM_INX   TYPE TABLE OF BAPISDITMX,
        LT_SCHEDULE_LINES   TYPE TABLE OF BAPISCHDL,
        LT_SCHEDULE_LINESX  TYPE TABLE OF BAPISCHDLX,
        LT_CONDITIONS_IN    TYPE TABLE OF BAPICOND,
        LT_CONDITIONS_INX   TYPE TABLE OF BAPICONDX,
        LT_RETURN           TYPE TABLE OF BAPIRET2,
        LS_ORDER_ITEM_IN    TYPE BAPISDITM,
        LS_ORDER_ITEM_INX   TYPE BAPISDITMX,
        LS_SCHEDULE_LINES   TYPE BAPISCHDL,
        LS_SCHEDULE_LINESX  TYPE BAPISCHDLX,
        LS_CONDITIONS_IN    TYPE BAPICOND,
        LS_CONDITIONS_INX   TYPE BAPICONDX.
  DATA: LV_VBELN TYPE VBELN_VA,
        LV_POSNR TYPE POSNR_VA,
        LV_MVGR3 TYPE MVGR3,
        LV_LIFSP TYPE LIFSP.
  DATA: LV_MSG(220),
        LV_RSLT(1).
  DATA: LV_CHK(1),
        LV_CHK1(1),
        LV_CHK2(1).

  CLEAR:GV_ERROR.

  LOOP AT GT_LIST INTO DATA(LS_LIST) WHERE SEL = GC_X
                                     GROUP BY ( VBELN = LS_LIST-VBELN
                                                INDEX = GROUP INDEX SIZE = GROUP SIZE )
                                     ASCENDING ASSIGNING FIELD-SYMBOL(<FS_MAIN>).
    CLEAR:LV_SALESDOCUMENT,LS_ORDER_HEADER_IN,LS_ORDER_HEADER_INX,
          LT_ORDER_ITEM_IN[],LT_ORDER_ITEM_INX[],LT_SCHEDULE_LINES[],
          LT_SCHEDULE_LINESX[],LT_RETURN[].
    CLEAR:LV_CHK,LV_CHK1,LV_CHK2,LV_MSG,LV_RSLT.

    LOOP AT GROUP <FS_MAIN> ASSIGNING FIELD-SYMBOL(<FS_LINE>).
      CLEAR:LS_ORDER_ITEM_IN,LS_ORDER_ITEM_INX.

      LV_SALESDOCUMENT = <FS_LINE>-VBELN.

      SELECT SINGLE VBELN,POSNR,BEDAE
        FROM VBAP
       WHERE VBELN     EQ @<FS_LINE>-VBELN
         AND POSNR     EQ @<FS_LINE>-POSNR
        INTO @DATA(LS_DATA).

      LS_ORDER_ITEM_IN-ITM_NUMBER = <FS_LINE>-POSNR.

      LS_ORDER_ITEM_INX-ITM_NUMBER = <FS_LINE>-POSNR.
      LS_ORDER_ITEM_INX-UPDATEFLAG = GC_U.

      "소요량유형
      IF LS_DATA IS NOT INITIAL AND LS_DATA-BEDAE NE <FS_LINE>-BEDAE.
        LV_CHK1 = GC_X.
        LS_ORDER_ITEM_IN-REQMTS_TYP = <FS_LINE>-BEDAE.
        APPEND LS_ORDER_ITEM_IN TO LT_ORDER_ITEM_IN.

        LS_ORDER_ITEM_INX-REQMTS_TYP = GC_X.
        APPEND LS_ORDER_ITEM_INX TO LT_ORDER_ITEM_INX.
      ENDIF.

      CLEAR:LS_DATA.
    ENDLOOP.

    IF LV_CHK1 IS INITIAL.
      LV_RSLT = GC_S.
      LV_MSG  = TEXT-M09.
    ELSE.
      LV_CHK = GC_X.
    ENDIF.

    IF LV_CHK EQ GC_X.

      LS_ORDER_HEADER_INX = GC_U.

      CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
        EXPORTING
          SALESDOCUMENT    = LV_SALESDOCUMENT
          ORDER_HEADER_IN  = LS_ORDER_HEADER_IN
          ORDER_HEADER_INX = LS_ORDER_HEADER_INX
        TABLES
          RETURN           = LT_RETURN
          ORDER_ITEM_IN    = LT_ORDER_ITEM_IN
          ORDER_ITEM_INX   = LT_ORDER_ITEM_INX.
*          SCHEDULE_LINES   = LT_SCHEDULE_LINES
*          SCHEDULE_LINESX  = LT_SCHEDULE_LINESX
*          CONDITIONS_IN    = LT_CONDITIONS_IN
*          CONDITIONS_INX   = LT_CONDITIONS_INX.

      LOOP AT LT_RETURN INTO DATA(LS_RETURN) WHERE TYPE CA 'AE'.
        EXIT.
      ENDLOOP.
      IF SY-SUBRC EQ 0.
        __BAPI_TRANSACTION_ROLLBACK.

        LV_RSLT = GC_E.

        GV_ERROR = GC_X.

        LOOP AT LT_RETURN INTO LS_RETURN WHERE TYPE CA 'AE'.
          IF LV_MSG IS INITIAL.
            LV_MSG = LS_RETURN-MESSAGE.
          ELSE.
            LV_MSG = |{ LV_MSG }/{ LS_RETURN-MESSAGE }|.
          ENDIF.
        ENDLOOP.

      ELSE.
        __BAPI_TRANSACTION_COMMIT.

        LV_RSLT = GC_S.
        LV_MSG  = TEXT-S01.
      ENDIF.

    ENDIF.

    "결과
    LOOP AT GROUP <FS_MAIN> ASSIGNING FIELD-SYMBOL(<FS_LINE1>).
      <FS_LINE1>-RSLT2   = LV_RSLT.
      <FS_LINE1>-MESSAGE = LV_MSG.

      PERFORM SET_LED CHANGING <FS_LINE1>.

      PERFORM SET_ATTRIBUTES_LINE CHANGING <FS_LINE1>.
    ENDLOOP.

  ENDLOOP.

  IF GV_ERROR EQ GC_X.
    MESSAGE I000 WITH TEXT-M11 DISPLAY LIKE GC_E.
  ELSE.
    MESSAGE I000 WITH TEXT-M12.
  ENDIF.

  PERFORM REFRESH_ALV USING GO_GRID.

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
    WHEN 'VBELN'.
      IF LS_LIST-VBELN IS NOT INITIAL.
        SET PARAMETER ID 'AUN' FIELD LS_LIST-VBELN.
        CALL TRANSACTION 'VA03' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
      ENDIF.

  ENDCASE.

ENDFORM.
