*&---------------------------------------------------------------------*
*& Include          ZGTPPR1090F01
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
      WHEN 'P_FILE' OR 'P_WERKS'.
        SCREEN-REQUIRED = 2.
        MODIFY SCREEN.
    ENDCASE.

    IF P_R1 EQ GC_X.
      IF SCREEN-GROUP1 = 'S2'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.

      SSCRFIELDS-FUNCTXT_01 = GV_DYNTXT.

      GV_TITLE = TEXT-T03. "업로드 파일

    ELSEIF P_R2 EQ GC_X.

      IF SCREEN-GROUP1 = 'S1'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.

      CLEAR: SSCRFIELDS-FUNCTXT_01.

      GV_TITLE = TEXT-T05. "조회 옵션

    ENDIF.
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

  DATA: L_RC               TYPE I VALUE 1,
        LT_FILES           TYPE FILETABLE,
        LV_USER_ACTION     TYPE I,
        L_DESKTOPDIRECTORY TYPE STRING,
        LV_TITLE           TYPE STRING.

  CLEAR: LV_TITLE.
  LV_TITLE = TEXT-T06.  "파일 열기

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
    MESSAGE S003 DISPLAY LIKE GC_E WITH 'FILE NOT SELECT'.
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

  LV_OBJ = |ZGTPPR1090|.

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
*& Form INPUT_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INPUT_CHECK .

  IF P_R1 EQ GC_X.
    IF P_WERKS IS INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH TEXT-M03. "필수 필드 "플랜트"에 입력하십시오.
      LEAVE LIST-PROCESSING.
    ENDIF.

    IF P_FILE IS INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH TEXT-M04. "필수 필드 "파일 경로"에 입력하십시오.
      LEAVE LIST-PROCESSING.
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

  IF P_R1 EQ GC_X.
    PERFORM EXCEL_UPLOAD.
    PERFORM CHECK_DATA.
  ELSEIF P_R2 EQ GC_X.
    PERFORM GET_ZGTPPT1080.
  ENDIF.

  CHECK GV_ERROR EQ SPACE.

  PERFORM MODIFY_DATA.

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
*& Form GET_ZGTPPT1080
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ZGTPPT1080 .

  CLEAR: GT_DATA.
  SELECT A~WERKS, A~SPART, A~MTART, A~MATKL, A~WGBEZ, A~STRGR,
         A~DISMM, A~DISPO, A~DISLS, A~BESKZ, A~SOBSL, A~LGPRO,
         A~LGFSB, A~RGEKZ, A~MTVFP, A~SBDKZ, A~XCHAR, A~UEETK,
         A~FEVOR, A~SFCPF, A~DPCBT, A~KZKUP, A~DISGR, A~INSMK,
         B~NAME1,
         C~VTEXT,
         D~MTBEZ
*         E~WGBEZ
    FROM ZGTPPT1080 AS A
    LEFT OUTER JOIN T001W AS B ON B~WERKS EQ A~WERKS
    LEFT OUTER JOIN TSPAT AS C ON C~SPRAS EQ @SY-LANGU
                              AND C~SPART EQ A~SPART
    LEFT OUTER JOIN T134T AS D ON D~SPRAS EQ @SY-LANGU
                              AND D~MTART EQ A~MTART
*    LEFT OUTER JOIN T023T AS E ON E~SPRAS EQ @SY-LANGU
*                              AND E~MATKL EQ A~MATKL
   WHERE A~WERKS IN @S_WERKS
     AND A~SPART IN @S_SPART
     AND A~MTART IN @S_MTART
     AND A~MATKL IN @S_MATKL
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.

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

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_S>).
    IF P_R1 EQ GC_X.

      "플랜트 내역
      SELECT SINGLE NAME1
        FROM T001W
       WHERE WERKS EQ @<FS_S>-WERKS
        INTO @<FS_S>-NAME1.

      "제품군 내역
      SELECT SINGLE VTEXT
        FROM TSPAT
       WHERE SPRAS EQ @SY-LANGU
         AND SPART EQ @<FS_S>-SPART
        INTO @<FS_S>-VTEXT.

      "자재유형 내역
      SELECT SINGLE MTBEZ
        FROM T134T
       WHERE SPRAS EQ @SY-LANGU
         AND MTART EQ @<FS_S>-MTART
        INTO @<FS_S>-MTBEZ.

      "자재그룹 내역
*      SELECT SINGLE WGBEZ
*        FROM T023T
*       WHERE SPRAS EQ @SY-LANGU
*         AND MATKL EQ @<FS_S>-MATKL
*        INTO @<FS_S>-WGBEZ.
    ENDIF.

    PERFORM SET_STY_RTN USING SPACE
                        CHANGING <FS_S>.

  ENDLOOP.

  IF P_R2 EQ GC_X.
    SORT GT_DATA BY WERKS SPART MTART MATKL.
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
  GS_LAYOUT_0100-EDIT       = GC_X.
  GS_LAYOUT_0100-STYLEFNAME = 'CELL_STY'.
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
      I_INCLNAME             = 'ZGTPPR1090TOP'
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
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'SPART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "제품군
        <LS_FCAT>-JUST = GC_C.
      WHEN 'VTEXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "제품군내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MTART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "자재유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MTBEZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "자재유형내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MATKL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "자재그룹
        <LS_FCAT>-JUST = GC_C.
      WHEN 'WGBEZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "자재그룹내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'STRGR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "생산전략
        <LS_FCAT>-JUST = GC_C.
      WHEN 'DISMM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "MRP유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'DISPO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "MRP관리자
        <LS_FCAT>-JUST = GC_C.
      WHEN 'DISLS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "로트크기유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'BESKZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F13. "조달유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'SOBSL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "특별조달유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LGPRO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "생산저장위치
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LGFSB'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "외부조달저장위치
        <LS_FCAT>-JUST = GC_C.
      WHEN 'RGEKZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "백플러쉬
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MTVFP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "가용성점검
        <LS_FCAT>-JUST = GC_C.
      WHEN 'SBDKZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "개별/일괄
        <LS_FCAT>-JUST = GC_C.
      WHEN 'XCHAR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "배치관리
        <LS_FCAT>-JUST = GC_C.
      WHEN 'UEETK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "무제한허용
        <LS_FCAT>-JUST = GC_C.
      WHEN 'FEVOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "생산감독자
        <LS_FCAT>-JUST = GC_C.
      WHEN 'SFCPF'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F23. "생산일정프로파일
        <LS_FCAT>-JUST = GC_C.
      WHEN 'DPCBT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F24. "단일단위배치기본값
        <LS_FCAT>-JUST = GC_C.
      WHEN 'KZKUP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F25. "연산품
        <LS_FCAT>-JUST = GC_C.
      WHEN 'DISGR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F26. "MRP그룹
        <LS_FCAT>-JUST = GC_C.
      WHEN 'INSMK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F27. "검사재고로 전기
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
  IF GO_EVTR_0100 IS NOT BOUND.
    CREATE OBJECT GO_EVTR_0100.
  ENDIF.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      SET HANDLER: GO_EVTR_0100->HDL_DATA_CHANGED FOR GO_GRID_0100.
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
*& Form SET_STY_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_S>
*&---------------------------------------------------------------------*
FORM SET_STY_RTN USING P_STATUS
                 CHANGING P_LINE LIKE GS_DATA.

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

  IF P_STATUS EQ GC_C.
    SET_STY 'WERKS'   SPACE.
    SET_STY 'NAME1'   'X'.
    SET_STY 'SPART'   SPACE.
    SET_STY 'VTEXT'   'X'.
    SET_STY 'MTART'   SPACE.
    SET_STY 'MTBEZ'   'X'.
    SET_STY 'MATKL'   SPACE.
    SET_STY 'WGBEZ'   SPACE.

  ELSE.
    SET_STY 'WERKS'   'X'.
    SET_STY 'NAME1'   'X'.
    SET_STY 'SPART'   'X'.
    SET_STY 'VTEXT'   'X'.
    SET_STY 'MTART'   'X'.
    SET_STY 'MTBEZ'   'X'.
    SET_STY 'MATKL'   'X'.
    SET_STY 'WGBEZ'   'X'.

  ENDIF.

  SET_STY 'STRGR'   SPACE.
  SET_STY 'DISMM'   SPACE.
  SET_STY 'DISPO'   SPACE.
  SET_STY 'DISLS'   SPACE.
  SET_STY 'BESKZ'   SPACE.
  SET_STY 'SOBSL'   SPACE.
  SET_STY 'LGPRO'   SPACE.
  SET_STY 'LGFSB'   SPACE.
  SET_STY 'RGEKZ'   SPACE.
  SET_STY 'MTVFP'   SPACE.
  SET_STY 'SBDKZ'   SPACE.
  SET_STY 'XCHAR'   SPACE.
  SET_STY 'UEETK'   SPACE.
  SET_STY 'FEVOR'   SPACE.
  SET_STY 'SFCPF'   SPACE.
  SET_STY 'DPCBT'   SPACE.
  SET_STY 'KZKUP'   SPACE.
  SET_STY 'DISGR'   SPACE.
  SET_STY 'INSMK'   SPACE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_DATA .

  CLEAR: GV_ERROR.

  "플랜트, 제품군, 자재유형, 자재그룹 중 하나라도 빈값 체크
  IF LINE_EXISTS( GT_DATA[ WERKS = SPACE ] ).
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M05. "플랜트 필드에 값을 입력하십시요.
    GV_ERROR = GC_X.
    RETURN.
  ENDIF.

  IF LINE_EXISTS( GT_DATA[ SPART = SPACE ] ).
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M06. "제품군 필드에 값을 입력하십시요.
    GV_ERROR = GC_X.
    RETURN.
  ENDIF.

  IF LINE_EXISTS( GT_DATA[ MTART = SPACE ] ).
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M07. "자재유형 필드에 값을 입력하십시요.
    GV_ERROR = GC_X.
    RETURN.
  ENDIF.

  IF LINE_EXISTS( GT_DATA[ MATKL = SPACE ] ).
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M08. "자재그룹 필드에 값을 입력하십시요.
    GV_ERROR = GC_X.
    RETURN.
  ENDIF.

  IF P_R1 EQ GC_X.
    LOOP AT GT_DATA INTO DATA(LS_DATA).
      "조회조건의 플랜트와 엑셀 상 플랜트 상이 체크
      IF LS_DATA-WERKS NE P_WERKS.
        MESSAGE S003 DISPLAY LIKE GC_W
           WITH TEXT-M09. "조회조건의 플랜트와 엑셀 상 플랜트가 서로 다릅니다.
        GV_ERROR = GC_X.
        RETURN.
      ENDIF.

      "자재유형 점검
*      IF LS_DATA-MTART NE 'FERT' AND
*         LS_DATA-MTART NE 'HALB' AND
*         LS_DATA-MTART NE 'HAWA' AND
*         LS_DATA-MTART NE 'MCFE' AND
*         LS_DATA-MTART NE 'MCHF' AND
*         LS_DATA-MTART NE 'MCHA'.
*        MESSAGE S003 DISPLAY LIKE GC_W
*           WITH TEXT-M10. "제품, 반제품, 상품만 등록 가능합니다.
*        GV_ERROR = GC_X.
*        RETURN.
*      ENDIF.
    ENDLOOP.
  ENDIF.

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
  CLEAR: GS_DATA.

  GS_DATA-WERKS = P_WERKS.

  SELECT SINGLE NAME1
    FROM T001W
   WHERE WERKS EQ @GS_DATA-WERKS
    INTO @GS_DATA-NAME1.

  PERFORM SET_STY_RTN USING GC_C
                      CHANGING GS_DATA.
  APPEND GS_DATA TO GT_DATA.

  " REFRESH DISPLAY
  PERFORM REF_ALV_RTN USING GO_GRID_0100.
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

  DATA: LS_ZGTPPT1080 LIKE ZGTPPT1080.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M11. "삭제할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T07 "삭제
      TEXT_QUESTION         = TEXT-T08 "삭제를 진행하시겠습니까?(DB에서도 삭제됩니다.)
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    SORT LT_ROW_NO BY ROW_ID DESCENDING.

    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      CLEAR: LS_ZGTPPT1080.
      SELECT SINGLE *
        FROM ZGTPPT1080
       WHERE WERKS EQ @<FS_S>-WERKS
         AND SPART EQ @<FS_S>-SPART
         AND MTART EQ @<FS_S>-MTART
         AND MATKL EQ @<FS_S>-MATKL
        INTO @LS_ZGTPPT1080.

      IF SY-SUBRC EQ 0.
        "ZGTPPT1080에서 삭제
        DELETE ZGTPPT1080 FROM LS_ZGTPPT1080.

        IF SY-SUBRC EQ 0.
          COMMIT WORK.
          "ALV에서 삭제
          DELETE GT_DATA INDEX LT_ROW_NO-ROW_ID.

        ELSE.
          ROLLBACK WORK.

        ENDIF.

      ELSE.
        "ALV에서 삭제
        DELETE GT_DATA INDEX LT_ROW_NO-ROW_ID.

      ENDIF.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.
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

  CLEAR: LT_INDEX_ROWS, LT_INDEX_ROWS[],
         LT_ROW_NO, LT_ROW_NO[].

  PR_ALV->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_INDEX_ROWS
      ET_ROW_NO     = LT_ROW_NO ).

  PT_ROW_NO[] = LT_ROW_NO[].

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

  DATA: LT_ZGTPPT1080 LIKE TABLE OF ZGTPPT1080,
        LS_ZGTPPT1080 LIKE ZGTPPT1080.

  DATA: LV_CX_REF TYPE REF TO CX_ROOT.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: L_ANSWER.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T09 "저장
      TEXT_QUESTION         = TEXT-T10 "데이터 저장을 진행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    PERFORM CHECK_DATA.

    CHECK GV_ERROR EQ SPACE.

    CLEAR: LT_ZGTPPT1080.
    LOOP AT GT_DATA ASSIGNING <FS_S>.
      MOVE-CORRESPONDING <FS_S> TO LS_ZGTPPT1080.
      MOVE: SY-DATUM TO LS_ZGTPPT1080-CRDAT,
            SY-UZEIT TO LS_ZGTPPT1080-CRTIM,
            SY-UNAME TO LS_ZGTPPT1080-CRNAM.

      APPEND LS_ZGTPPT1080 TO LT_ZGTPPT1080.
      CLEAR: LS_ZGTPPT1080.

      PERFORM SET_STY_RTN USING SPACE
                       CHANGING <FS_S>.
    ENDLOOP.

    MODIFY ZGTPPT1080 FROM TABLE LT_ZGTPPT1080.
    IF SY-SUBRC EQ 0.
      COMMIT WORK.
      MESSAGE S018. "고정값 설정 데이터 저장에 성공하였습니다.
    ELSE.
      ROLLBACK WORK.
      MESSAGE S019. "데이터 저장 도중 오류가 발생하였습니다.
    ENDIF.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.

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
FORM SET_NAME1_RTN  USING    P_LVC_S_MODI   TYPE LVC_S_MODI
                    CHANGING P_DATA_CHANGED
                             TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA: L_NAME1 TYPE NAME1.

  DATA: L_VALUE TYPE LVC_S_MODI-VALUE.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  READ TABLE GT_DATA ASSIGNING <FS_S> INDEX P_LVC_S_MODI-ROW_ID.

  L_VALUE = P_LVC_S_MODI-VALUE.

  TRANSLATE L_VALUE TO UPPER CASE.

  CLEAR: L_NAME1.
  SELECT SINGLE NAME1
    FROM T001W
   WHERE WERKS EQ @L_VALUE
    INTO @L_NAME1.

  IF L_NAME1 IS INITIAL.
    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'WERKS'
        I_VALUE     = <FS_S>-WERKS.

    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'NAME1'
        I_VALUE     = <FS_S>-NAME1.

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
*& Form SET_VTEXT_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LVC_S_MODI
*&      <-- ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM SET_VTEXT_RTN  USING    P_LVC_S_MODI   TYPE LVC_S_MODI
                    CHANGING P_DATA_CHANGED
                             TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA: L_VTEXT TYPE VTXTK.

  DATA: L_VALUE TYPE LVC_S_MODI-VALUE.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  READ TABLE GT_DATA ASSIGNING <FS_S> INDEX P_LVC_S_MODI-ROW_ID.

  L_VALUE = P_LVC_S_MODI-VALUE.

  TRANSLATE L_VALUE TO UPPER CASE.

  CLEAR: L_VTEXT.
  SELECT SINGLE VTEXT
    FROM TSPAT
   WHERE SPRAS EQ @SY-LANGU
     AND SPART EQ @L_VALUE
    INTO @L_VTEXT.

  IF L_VTEXT IS INITIAL.
    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'SPART'
        I_VALUE     = <FS_S>-SPART.

    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'VTEXT'
        I_VALUE     = <FS_S>-VTEXT.

  ELSE.
    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'VTEXT'
        I_VALUE     = L_VTEXT.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MTBEZ_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LVC_S_MODI
*&      <-- ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM SET_MTBEZ_RTN  USING    P_LVC_S_MODI   TYPE LVC_S_MODI
                    CHANGING P_DATA_CHANGED
                             TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA: L_MTBEZ TYPE MTBEZ.

  DATA: L_VALUE TYPE LVC_S_MODI-VALUE.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  READ TABLE GT_DATA ASSIGNING <FS_S> INDEX P_LVC_S_MODI-ROW_ID.

  L_VALUE = P_LVC_S_MODI-VALUE.

  TRANSLATE L_VALUE TO UPPER CASE.

  CLEAR: L_MTBEZ.
  SELECT SINGLE MTBEZ
    FROM T134T
   WHERE SPRAS EQ @SY-LANGU
     AND MTART EQ @L_VALUE
    INTO @L_MTBEZ.

  IF L_MTBEZ IS INITIAL.
    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'MTART'
        I_VALUE     = <FS_S>-MTART.

    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'MTBEZ'
        I_VALUE     = <FS_S>-MTBEZ.

  ELSE.
    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'MTBEZ'
        I_VALUE     = L_MTBEZ.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_WGBEZ_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LVC_S_MODI
*&      <-- ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM SET_WGBEZ_RTN  USING    P_LVC_S_MODI   TYPE LVC_S_MODI
                    CHANGING P_DATA_CHANGED
                             TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA: L_WGBEZ TYPE WGBEZ.

  DATA: L_VALUE TYPE LVC_S_MODI-VALUE.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  READ TABLE GT_DATA ASSIGNING <FS_S> INDEX P_LVC_S_MODI-ROW_ID.

  L_VALUE = P_LVC_S_MODI-VALUE.

  TRANSLATE L_VALUE TO UPPER CASE.

  CLEAR: L_WGBEZ.
  SELECT SINGLE WGBEZ
    FROM T023T
   WHERE SPRAS EQ @SY-LANGU
     AND MATKL EQ @L_VALUE
    INTO @L_WGBEZ.

  IF L_WGBEZ IS NOT INITIAL.
    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'WGBEZ'
        I_VALUE     = L_WGBEZ.
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
  IF P_R1 EQ GC_X.
*& 플랜트에 대한 권한체크
    AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
    ID 'WERKS' FIELD P_WERKS.

    IF SY-SUBRC <> 0.
      "플랜트[P_WERKS] 작업권한을 확인하세요.
      MESSAGE S006 DISPLAY LIKE GC_E
         WITH TEXT-M12 P_WERKS TEXT-M13.
      LEAVE LIST-PROCESSING.
    ENDIF.

  ELSEIF P_R2 EQ GC_X.
*& 플랜트에 대한 권한체크
    AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
    ID 'WERKS' FIELD S_WERKS-LOW.

    IF SY-SUBRC <> 0.
      "플랜트[S_WERKS-LOW] 작업권한을 확인하세요.
      MESSAGE S006 DISPLAY LIKE GC_E
         WITH TEXT-M12 S_WERKS-LOW TEXT-M13.
      LEAVE LIST-PROCESSING.
    ELSE.
*& 제품군에 대한 권한체크
      AUTHORITY-CHECK OBJECT 'ZPP_SPART'
      ID 'WERKS'  FIELD S_WERKS-LOW
      ID 'SPART'  FIELD S_SPART-LOW.

      IF SY-SUBRC <> 0.
        "제품군[S_SPART-LOW] 작업권한을 확인하세요.
        MESSAGE S006 DISPLAY LIKE GC_E
           WITH TEXT-M14 S_SPART-LOW TEXT-M15.
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
