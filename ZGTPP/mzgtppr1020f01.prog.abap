*&---------------------------------------------------------------------*
*&  Include           MZGTPPR1020F01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  check_validation_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_VALIDATION_0100 .

  SELECT SINGLE NAME1
    INTO GW_SEL-NAME1
    FROM T001W
   WHERE WERKS  = GW_SEL-WERKS.

  IF GW_SEL-NAME1 IS INITIAL.
    MESSAGE S003 WITH '존재하지 않는 플랜트 입니다.'(m01).
  ENDIF.

ENDFORM.                    " check_validation_0100
*&---------------------------------------------------------------------*
*&      Form  read_data_from_tables
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_DATA_FROM_TABLES.

  SELECT *
     INTO CORRESPONDING FIELDS OF TABLE GT_DATA
     FROM ZGTPPT1030
    WHERE WERKS  = GW_SEL-WERKS
      AND SPGCD  = GW_SEL-SPGCD
     ORDER BY WERKS SPGCD PROCD MATNR MATKL.

ENDFORM.                    " read_data_from_tables
*&---------------------------------------------------------------------*
*&      Form  add_line_to_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0064   text
*----------------------------------------------------------------------*
FORM ADD_LINE_TO_SCREEN  USING    PV_CHK.

  GV_INDEX = GV_INDEX + 2.

  CLEAR: GT_DATA.

  GT_DATA-WERKS = GW_SEL-WERKS.
  GT_DATA-SPGCD = GW_SEL-SPGCD.
  GT_DATA-CHK   = PV_CHK.
  GT_DATA-FLAG  = 'NEW'.
  GT_DATA-INDEX = GV_INDEX.

  APPEND GT_DATA.

  TC_200-TOP_LINE = 1.

  SORT GT_DATA DESCENDING BY INDEX.


ENDFORM.                    " add_line_to_screen
*&---------------------------------------------------------------------*
*&      Form  function_for_confirm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0102   text
*      -->P_0103   text
*      -->P_SPACE  text
*      <--P_LV_ANSWER  text
*----------------------------------------------------------------------*
FORM FUNCTION_FOR_CONFIRM  USING P_TITLE
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
ENDFORM.                    " function_for_confirm
*&---------------------------------------------------------------------*
*&      Form  save_data_to_zppt0034
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_DATA.

  DATA: LV_MATNR        LIKE MARA-MATNR.
  DATA : LS_SAVE LIKE LINE OF GT_SAVE.

  IF NOT GT_DATA[] IS INITIAL.
    LOOP AT GT_DATA WHERE CHK = 'X'
                      AND WERKS IS NOT INITIAL
                      AND SPGCD IS NOT INITIAL
                      AND PROCD IS NOT INITIAL.

      CLEAR LS_SAVE.

      MOVE-CORRESPONDING GT_DATA TO LS_SAVE.

      IF GT_DATA-FLAG = 'NEW'.
        LS_SAVE-CRDAT  = SY-DATUM.
        LS_SAVE-CRTIM  = SY-UZEIT.
        LS_SAVE-CRNAM  = SY-UNAME.
      ENDIF.
      LS_SAVE-CHDAT  = SY-DATUM.
      LS_SAVE-CHTIM  = SY-UZEIT.
      LS_SAVE-CHNAM  = SY-UNAME.

      APPEND LS_SAVE TO GT_SAVE.
    ENDLOOP.
  ENDIF.

* 현재 조회 된 테이블 삭제후 재저장
  SELECT *
   FROM ZGTPPT1030
  WHERE WERKS  = @GW_SEL-WERKS
    AND SPGCD  = @GW_SEL-SPGCD
   INTO TABLE @DATA(LT_TEMP).

  IF SY-SUBRC EQ 0.
    DELETE ZGTPPT1030 FROM TABLE LT_TEMP.
  ENDIF.



  IF GT_SAVE[] IS NOT INITIAL.
    MODIFY ZGTPPT1030 FROM TABLE GT_SAVE.
  ENDIF.

  IF SY-SUBRC = 0.
    COMMIT WORK AND WAIT.
    MESSAGE S003 WITH '작업을 완료하였습니다.!!!'(M02).
    GV_SAVEFLG  = ''.
    DESCRIBE TABLE GT_DATA LINES GV_CNT.
  ELSE.
    ROLLBACK WORK.
    MESSAGE S003 WITH'작업을 처리하지 못하였습니다.!!!'(M03) DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.                    " save_data_to_zppt0034
*&---------------------------------------------------------------------*
*&      Form  delete_line_from_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DELETE_LINE_FROM_SCREEN .
  DATA: LV_TABIX        TYPE SY-TABIX.

  LOOP AT GT_DATA WHERE CHK  = 'X'.
    LV_TABIX = SY-TABIX.

*    CLEAR GT_SAVE.

*    GT_SAVE = GT_DATA.
*
*    APPEND GT_SAVE.

    DELETE GT_DATA  INDEX LV_TABIX.

  ENDLOOP.

ENDFORM.                    " delete_line_from_screen
*&---------------------------------------------------------------------*
*&      Form  conversion_matnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0274   text
*      -->P_GT_DATA_MATNR  text
*      <--P_LV_MATNR  text
*----------------------------------------------------------------------*
FORM CONVERSION_MATNR  USING    P_FLAG
                                PI_MATNR
                       CHANGING PO_MATNR.

  IF P_FLAG = 'I'.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT  = PI_MATNR
      IMPORTING
        OUTPUT = PO_MATNR.

  ELSE.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = PI_MATNR
      IMPORTING
        OUTPUT = PO_MATNR.

  ENDIF.
ENDFORM.                    " conversion_matnr
*&---------------------------------------------------------------------*
*&      Form  mark_line_items
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0197   text
*----------------------------------------------------------------------*
FORM MARK_LINE_ITEMS USING LP_CHECK.
  LOOP AT GT_DATA.
    GT_DATA-CHK = LP_CHECK.
    MODIFY GT_DATA.
  ENDLOOP.
ENDFORM.                    "mark_line_items
*&---------------------------------------------------------------------*
*&      Form  file_upload_process
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILE_UPLOAD_PROCESS .

  DATA: LV_FILENM  TYPE RLGRAP-FILENAME,
        LV_MATNR   LIKE MARA-MATNR,
        LV_MATNR_R LIKE MARA-MATNR.

  LV_FILENM = 'C:\'.

  REFRESH GT_UPLOAD.    CLEAR GT_UPLOAD.

  DATA: L_FILE TYPE STRING .

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      DEF_FILENAME     = L_FILE
      DEF_PATH         = LV_FILENM
      MASK             = ',*.*,*.*.'
      MODE             = 'O'
    IMPORTING
      FILENAME         = L_FILE
    EXCEPTIONS
      INV_WINSYS       = 1
      NO_BATCH         = 2
      SELECTION_CANCEL = 3
      SELECTION_ERROR  = 4
      OTHERS           = 5.

  IF SY-SUBRC <> 0.
*    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
*           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    REJECT.
  ENDIF.



  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME                = L_FILE
      FILETYPE                = 'DAT'
    TABLES
      DATA_TAB                = GT_UPLOAD
    EXCEPTIONS
      FILE_OPEN_ERROR         = 1
      FILE_READ_ERROR         = 2
      NO_BATCH                = 3
      GUI_REFUSE_FILETRANSFER = 4
      INVALID_TYPE            = 5
      NO_AUTHORITY            = 6
      UNKNOWN_ERROR           = 7
      BAD_DATA_FORMAT         = 8
      HEADER_NOT_ALLOWED      = 9
      SEPARATOR_NOT_ALLOWED   = 10
      HEADER_TOO_LONG         = 11
      UNKNOWN_DP_ERROR        = 12
      ACCESS_DENIED           = 13
      DP_OUT_OF_MEMORY        = 14
      DISK_FULL               = 15
      DP_TIMEOUT              = 16
      OTHERS                  = 17.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*자재코드 Conversion
  IF GT_UPLOAD[] IS INITIAL.

    MESSAGE E003 WITH 'Upload할 데이터가 없습니다.'(M04).

  ELSE.

    LOOP AT GT_UPLOAD.

      READ TABLE GT_DATA WITH KEY WERKS = GT_UPLOAD-WERKS
                                  SPGCD = GT_UPLOAD-SPGCD
                                  PROCD = GT_UPLOAD-PROCD
                                  MATNR = GT_UPLOAD-MATNR
                                  MATKL = GT_UPLOAD-MATKL.

      IF SY-SUBRC = 0.

        DELETE FROM ZGTPPT1030
     WHERE  WERKS   = GT_UPLOAD-WERKS
       AND  SPGCD   = GT_UPLOAD-SPGCD
       AND  PROCD   = GT_UPLOAD-PROCD
       AND  MATNR   = GT_UPLOAD-MATNR
       AND  MATKL   = GT_UPLOAD-MATKL.


        DELETE TABLE GT_DATA.

      ENDIF.

      MOVE-CORRESPONDING GT_UPLOAD TO GT_DATA.

      IF GT_DATA-MATNR IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            INPUT  = GT_DATA-MATNR
          IMPORTING
            OUTPUT = GT_DATA-MATNR.
      ENDIF.

      GT_DATA-CHK     = 'X'.
      GT_DATA-FLAG    = 'NEW'.

      APPEND GT_DATA.

      CLEAR GT_DATA.

    ENDLOOP.

  ENDIF.


ENDFORM.                    " file_upload_process
*&---------------------------------------------------------------------*
*&      Form  file_down_process
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILE_DOWN_PROCESS .
  DATA: LV_FILENM         TYPE RLGRAP-FILENAME.

  REFRESH GT_DOWN.    CLEAR GT_DOWN.

  LOOP AT GT_DATA.

    GT_DOWN-WERKS  = GT_DATA-WERKS.
    GT_DOWN-SPGCD  = GT_DATA-SPGCD.
    GT_DOWN-PROCD  = GT_DATA-PROCD.
    GT_DOWN-MATNR  = GT_DATA-MATNR.
    GT_DOWN-MATKL  = GT_DATA-MATKL.
    GT_DOWN-ZCUSTOMER  = GT_DATA-ZCUSTOMER.
    GT_DOWN-A_SCRAP  = GT_DATA-A_SCRAP.
    GT_DOWN-C_SCRAP1  = GT_DATA-C_SCRAP1.
    GT_DOWN-C_SCRAP6  = GT_DATA-C_SCRAP6.

    IF GT_DOWN-MATNR IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          INPUT  = GT_DOWN-MATNR
        IMPORTING
          OUTPUT = GT_DOWN-MATNR.

    ENDIF.

    APPEND GT_DOWN. CLEAR GT_DOWN.

  ENDLOOP.

  LV_FILENM = 'C:\'.

  DATA: L_FILE TYPE STRING .

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      DEF_FILENAME     = L_FILE
      DEF_PATH         = 'C:\'
      MASK             = ',*.*,*.*.'
      MODE             = 'S'
    IMPORTING
      FILENAME         = L_FILE
    EXCEPTIONS
      INV_WINSYS       = 1
      NO_BATCH         = 2
      SELECTION_CANCEL = 3
      SELECTION_ERROR  = 4
      OTHERS           = 5.

  IF SY-SUBRC <> 0.
    REJECT.
  ENDIF.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      FILENAME                = L_FILE
      FILETYPE                = 'DAT'
    TABLES
      DATA_TAB                = GT_DOWN
    EXCEPTIONS
      FILE_WRITE_ERROR        = 1
      NO_BATCH                = 2
      GUI_REFUSE_FILETRANSFER = 3
      INVALID_TYPE            = 4
      NO_AUTHORITY            = 5
      UNKNOWN_ERROR           = 6
      HEADER_NOT_ALLOWED      = 7
      SEPARATOR_NOT_ALLOWED   = 8
      FILESIZE_NOT_ALLOWED    = 9
      HEADER_TOO_LONG         = 10
      DP_ERROR_CREATE         = 11
      DP_ERROR_SEND           = 12
      DP_ERROR_WRITE          = 13
      UNKNOWN_DP_ERROR        = 14
      ACCESS_DENIED           = 15
      DP_OUT_OF_MEMORY        = 16
      DISK_FULL               = 17
      DP_TIMEOUT              = 18
      FILE_NOT_FOUND          = 19
      DATAPROVIDER_EXCEPTION  = 20
      CONTROL_FLUSH_ERROR     = 21
      OTHERS                  = 22.

  IF SY-SUBRC <> 0.
    MESSAGE S003 WITH '기타 오류.'.
    RETURN.
  ENDIF.

ENDFORM.                    " file_down_process
*&---------------------------------------------------------------------*
*& Form file_down_process_new
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FILE_DOWN_PROCESS_NEW .

  DATA : LO_EXCEL TYPE REF TO ZGTPP_CL_EXCEL_SERVICE.
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  DATA : LT_FCAT_LVC TYPE LVC_T_FCAT.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'MZGTPPR1020TOP'
      I_INTERNAL_TABNAME     = 'GT_DOWN'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = LT_FCAT_LVC[]
    TABLES
      IT_DATA         = GT_DOWN[]
    EXCEPTIONS
      OTHERS          = 1.

  REFRESH GT_DOWN.    CLEAR GT_DOWN.

  LOOP AT GT_DATA.
    GT_DOWN-WERKS  = GT_DATA-WERKS.
    GT_DOWN-SPGCD  = GT_DATA-SPGCD.
    GT_DOWN-PROCD  = GT_DATA-PROCD.
    GT_DOWN-MATNR  = GT_DATA-MATNR.
    GT_DOWN-MATKL  = GT_DATA-MATKL.
    GT_DOWN-ZCUSTOMER  = GT_DATA-ZCUSTOMER.
    GT_DOWN-A_SCRAP  = GT_DATA-A_SCRAP.
    GT_DOWN-C_SCRAP1  = GT_DATA-C_SCRAP1.
    GT_DOWN-C_SCRAP6  = GT_DATA-C_SCRAP6.

*    IF gt_down-matnr IS NOT INITIAL.
*      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
*        EXPORTING
*          input  = gt_down-matnr
*        IMPORTING
*          output = gt_down-matnr.
*
*    ENDIF.
    APPEND GT_DOWN. CLEAR GT_DOWN.
  ENDLOOP.

  TRY.
      LO_EXCEL ?= ZGTPP_CL_EXCEL_SERVICE=>GET_INSTANCE(
        EXPORTING
          IV_MODE    = 'D' ).

      CHECK LO_EXCEL IS BOUND.

      LO_EXCEL->DOWNLOAD_SPREADSHEET(
        IT_DATA       = GT_DOWN[]
        IT_FCAT       = LT_FCAT_LVC                 " 리스트뷰어 제어에 대한 필드 카타로그
*        iv_sheet_name = lv_title                 " 30자
        IV_TOP        = 1
      ).
    CATCH CX_BCS INTO DATA(LO_ERR). " BCS: General Exceptions
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form file_upload_process_new
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FILE_UPLOAD_PROCESS_NEW .

  DATA : LO_EXCEL TYPE REF TO ZGTPP_CL_EXCEL_SERVICE.

  REFRESH GT_UPLOAD.    CLEAR GT_UPLOAD.

  TRY.
      LO_EXCEL = ZGTPP_CL_EXCEL_SERVICE=>GET_INSTANCE(
        EXPORTING
          IV_MODE    = 'U' ).

      CHECK LO_EXCEL IS BOUND.

      LO_EXCEL->READ_SPREADSHEET(
        EXPORTING
          IV_TOP = 1
        IMPORTING
          ET_DATA       = GT_UPLOAD[]
          ET_RETURN     = DATA(LT_RETURN)                 " 오류 메시지
      ).

      LO_EXCEL->DESTROY_DOCUMENT( ).

    CATCH CX_BCS INTO DATA(LO_ERR). " BCS: General Exceptions
  ENDTRY.


*자재코드 Conversion
  IF GT_UPLOAD[] IS INITIAL.

    MESSAGE E003 WITH 'Upload할 데이터가 없습니다.'(M04).

  ELSE.

    LOOP AT GT_UPLOAD.

      IF GT_UPLOAD-MATNR IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            INPUT  = GT_UPLOAD-MATNR
          IMPORTING
            OUTPUT = GT_UPLOAD-MATNR.
      ENDIF.

      READ TABLE GT_DATA WITH KEY WERKS = GT_UPLOAD-WERKS
                                  SPGCD = GT_UPLOAD-SPGCD
                                  PROCD = GT_UPLOAD-PROCD
                                  MATNR = GT_UPLOAD-MATNR
                                  MATKL = GT_UPLOAD-MATKL
                                  ZCUSTOMER = GT_UPLOAD-ZCUSTOMER.

      IF SY-SUBRC = 0.

        DELETE GT_DATA INDEX SY-TABIX.

      ENDIF.

      CLEAR GT_DATA.
      MOVE-CORRESPONDING GT_UPLOAD TO GT_DATA.

      GT_DATA-CHK     = 'X'.
      GT_DATA-FLAG    = 'NEW'.

      APPEND GT_DATA.

      CLEAR GT_DATA.

    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_GONG_CD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4_GONG_CD .

  DATA : BEGIN OF LS_GONG,
           SPART   TYPE ZEDT0010-SPART,
           GONG_CD TYPE ZEDT0010-GONG_CD,
           GONG_NM TYPE ZEDT0011-GONG_NM,
         END OF LS_GONG.
  DATA : LT_GONG LIKE TABLE OF LS_GONG.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : LV_IDX TYPE I.
  DATA : LT_SIMNO TYPE RANGE OF ZGTPPT2090-SIMNO.

  DATA : LV_OFFSET(6) TYPE N.
  DATA : LO_FLIEF TYPE REF TO DATA.

  DATA : LT_FIELD_TAB TYPE TABLE OF DFIES.
  DATA : LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  DATA : LV_LINE       LIKE SY-STEPL,
         LT_DYNPFIELDS LIKE TABLE OF DYNPREAD.

  DATA : LV_BUKRS TYPE BUKRS.

  SELECT SINGLE BUKRS FROM T001K
    INTO LV_BUKRS
   WHERE BWKEY = GW_SEL-WERKS.

  SELECT DISTINCT A~SPART, A~GONG_CD, B~GONG_NM
    FROM ZEDT0010 AS A
    INNER JOIN ZEDT0011 AS B ON B~GONG_CD = A~GONG_CD
    INTO CORRESPONDING FIELDS OF TABLE @LT_GONG
   WHERE A~BUKRS = @LV_BUKRS.

  FREE LO_FLIEF.
  CREATE DATA LO_FLIEF LIKE LS_GONG.

  LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_FLIEF ).
  LT_FIELD_TAB = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

  CLEAR LV_OFFSET.
  LOOP AT LT_FIELD_TAB ASSIGNING FIELD-SYMBOL(<LS_FIELD_TAB>).

    CASE <LS_FIELD_TAB>-FIELDNAME.
      WHEN 'SPART'.
        <LS_FIELD_TAB>-REPTEXT  = '제품군'.
      WHEN 'GONG_CD'.
        <LS_FIELD_TAB>-REPTEXT  = '공정코드'.
      WHEN 'GONG_NM'.
        <LS_FIELD_TAB>-REPTEXT  = '공정명'.
    ENDCASE.

    <LS_FIELD_TAB>-OFFSET = LV_OFFSET.
    LV_OFFSET = LV_OFFSET + <LS_FIELD_TAB>-INTLEN.
  ENDLOOP.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'GONG_CD'
      DYNPROFIELD     = 'GT_DATA-PROCD'           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '공정 조회'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      FIELD_TAB       = LT_FIELD_TAB
      VALUE_TAB       = LT_GONG                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    REFRESH LT_DYNPFIELDS.
    PERFORM GET_STEPL USING LV_LINE.

*      공정코드
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING FIELD-SYMBOL(<LS_DYNPFIELDS>).
    <LS_DYNPFIELDS>-FIELDNAME = 'GT_DATA-PROCD'.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LS_RETURN_TAB-FIELDVAL.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        DYNAME               = SY-CPROG
        DYNUMB               = SY-DYNNR
      TABLES
        DYNPFIELDS           = LT_DYNPFIELDS
      EXCEPTIONS
        INVALID_ABAPWORKAREA = 1
        INVALID_DYNPROFIELD  = 2
        INVALID_DYNPRONAME   = 3
        INVALID_DYNPRONUMMER = 4
        INVALID_REQUEST      = 5
        NO_FIELDDESCRIPTION  = 6
        UNDEFIND_ERROR       = 7
        OTHERS               = 8.
    IF SY-SUBRC <> 0.
    ENDIF.


  ENDIF.


ENDFORM.
