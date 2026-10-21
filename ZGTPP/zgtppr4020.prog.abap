*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR4020
*& 프로그램 명 : [BD]월말 재고실사(MTS)
*& 개요   : 월말 재고실사 후 차이 수량을 전기하는 재고실사문서를
*&          생성하는 기능
*&          (기존의 ZPBR0030 프로그램을 복사 생성하여 프로그램을 보완함)
*& 생성일 : 2025.01.20
*& 생성자 : ZGSIDEV08
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION
*----------------------------------------------------------------------*
* 2015/02/09   이정익     기능개선_66038 부스닥트 플랜트 이전 반영
* 2025/05/07   ZGSIDEV08  수량 입력 방식 추가
*&---------------------------------------------------------------------*
REPORT ZGTPPR4020 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR4020TOP.
INCLUDE ZGTCONTROLS.
INCLUDE ZGTCONTROLS_EVENT01.
INCLUDE ZGTPPR4020PBO.
INCLUDE ZGTPPR4020PAI.
INCLUDE ZGTPPR4020F01.
INCLUDE ZGTPPR4020F02.
INCLUDE ZGTPPR4020F03.

*-------------------------------------------------------------*
*  INITIALIZATION
*-------------------------------------------------------------*
INITIALIZATION.
  PERFORM INIT_FUNC.
  PERFORM INIT_DATE.
  PERFORM INIT_COMMAND.


*-------------------------------------------------------------*
*  AT SELECTION-SCREEN
*-------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM F4_FILENAME CHANGING P_FILE.


*&---------------------------------------------------------------------*
*&   Event AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM AUTHORITY_CHECKING_PROC.
  PERFORM ACTION_FUNC.

*-------------------------------------------------------------*
*  START-OF-SELECTION
*-------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM CHK_COCKPIT.
  PERFORM INIT_TABLE.
  PERFORM CONVERT_EXCEL.
  IF SY-TCODE EQ 'ZGTPPR4022'.
    PERFORM SPLIT_EXCEL.
  ENDIF.
  IF GV_CHECK = ' '.
    CALL SCREEN 100.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  INIT_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INIT_DATE .

  P_ZLDAT = SY-DATUM.
  P_BLDAT = SY-DATUM.
ENDFORM.                    " INIT_DATE
*&---------------------------------------------------------------------*
*&      Form  F4_FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_FILE  text
*----------------------------------------------------------------------*
FORM F4_FILENAME  CHANGING P_FILE.

  DATA : L_PATH(40) VALUE 'C:\',
         L_FILENAME LIKE RLGRAP-FILENAME.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      DEF_FILENAME     = P_FILE         " 화일명
      DEF_PATH         = L_PATH
      MASK             = ',*.XLS,*.XLS;,*.TXT,*.TXT;,*.*,*.*.'
      MODE             = 'O'
      TITLE            = 'File Select'
    IMPORTING
      FILENAME         = L_FILENAME
    EXCEPTIONS
      INV_WINSYS       = 01
      NO_BATCH         = 02
      SELECTION_CANCEL = 03
      SELECTION_ERROR  = 04.

  IF ( SY-SUBRC = 0 ) OR ( SY-SUBRC = 3 ).
    P_FILE = L_FILENAME.
  ELSE.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " F4_FILENAME
*&---------------------------------------------------------------------*
*&      Form  CONVERT_EXCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONVERT_EXCEL .
  DATA: LV_FNAM     LIKE  RLGRAP-FILENAME,
        LV_INDEX(4) TYPE N.

  DATA: LV_NUM(4)   TYPE I,
        LV_COUNT(4) TYPE N.

  DATA: LV_SEQNO(10).

  LV_FNAM = P_FILE.

*-SEQ No.
  PERFORM GET_SEQ_NO USING LV_SEQNO.

  IF NOT LV_FNAM IS INITIAL.
*---EXCEL 업로드 데이터 인터널 테이블로 이동
    PERFORM UPLOAD_DATA USING 'GT_EXCEL_DATA'
                              LV_FNAM.

    DESCRIBE TABLE GT_EXCEL_DATA LINES LV_INDEX.

    IF LV_INDEX  > 0.
      CLEAR GT_EXCEL_DATA.
      LOOP AT GT_EXCEL_DATA.
*        LV_NUM = LV_NUM + 1.
*        CLEAR LV_COUNT.
*        LV_COUNT = LV_NUM.

        CLEAR IT_LIST.
        MOVE-CORRESPONDING GT_EXCEL_DATA TO IT_LIST.
        IT_LIST-REQ_NO = LV_SEQNO.
*        IT_LIST-SORT_NO = LV_COUNT.

*-------MTO/MTS 구분
        CASE IT_LIST-ZMTOS.
          WHEN 'O'.
            CLEAR IT_LIST-ZMTOS.
            IT_LIST-ZMTOS = 'MTO'.
            IT_LIST-SOBKZ = 'E'.
          WHEN 'X'.
            CLEAR IT_LIST-ZMTOS.
            IT_LIST-ZMTOS = 'MTS'.
        ENDCASE.

*-------재고조정 수량
        IF IT_LIST-ERFMG > 0.
          IT_LIST-SHKZG = 'S'.
        ELSEIF IT_LIST-ERFMG < 0.
          IT_LIST-SHKZG = 'H'.
        ENDIF.

        PERFORM CONVERSION_MATNR_INPUT CHANGING IT_LIST-MATNR.

        SELECT SINGLE MAKTX
          FROM MAKT
         WHERE MATNR EQ @IT_LIST-MATNR
           AND SPRAS EQ @SY-LANGU
          INTO @IT_LIST-MAKTX.

        APPEND IT_LIST.
      ENDLOOP.

    ELSE.
      GV_CHECK = 'X'.
      MESSAGE I001 WITH TEXT-004.
    ENDIF.
  ELSE.
    GV_CHECK = 'X'.
  ENDIF.

  CHECK GV_CHECK = ' '.

*-CHECK UPLOAD DATA
  PERFORM CHECK_UPLOAD_DATA.
ENDFORM.                    " CONVERT_EXCEL
*&---------------------------------------------------------------------*
*&      Form  INIT_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INIT_TABLE .
  CLS : GT_EXCEL_DATA,
        IT_LIST.

  CLEAR: GV_CHECK.

  CLEAR: GV_LIMIT.
  SELECT SINGLE FLD_02
    FROM ZGTPPT1010
   WHERE MODULE_KIND EQ 'PP'
     AND CODEGRP     EQ '4000'
     AND FLD_01      EQ @P_WERKS
    INTO @GV_LIMIT.

  CLEAR: GV_SPLIT.
  SELECT SINGLE FLD_02
    FROM ZGTPPT1010
   WHERE MODULE_KIND EQ 'PP'
     AND CODEGRP     EQ '4010'
     AND FLD_01      EQ @P_WERKS
    INTO @GV_SPLIT.
ENDFORM.                    " INIT_TABLE
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOAD_DATA  USING  LC_TABLE_NAME
                         LC_FILE  LIKE RLGRAP-FILENAME.

* internal table 변환용
  FIELD-SYMBOLS : <FS_TABLE>    TYPE STANDARD TABLE.

  TYPES TRUXS_T_TEXT_DATA(4096) TYPE C OCCURS 0.
  DATA: LV_TABLE_NAME LIKE FELD-NAME,
        V_DATA        TYPE TRUXS_T_TEXT_DATA.

*Internal Table Assign

  CONCATENATE LC_TABLE_NAME '[]' INTO LV_TABLE_NAME.

  ASSIGN (LV_TABLE_NAME)  TO  <FS_TABLE>.

  TRANSLATE LC_FILE  TO UPPER CASE.

  FIND '.TXT' IN LC_FILE .
  IF SY-SUBRC = 0.
*20090205 1ST Upgrade UPGDCC01 start***********************************
*Define a various
    DATA: LV_FILE TYPE STRING.
    LV_FILE = LC_FILE.
*Modify function 'WS_UPLOAD' to 'GUI_UPLOAD'
*    CALL FUNCTION 'WS_UPLOAD'
*      EXPORTING
*        CODEPAGE            = 'ASC'
*        FILENAME            = LC_FILE           "File Location
*        FILETYPE            = 'DAT'
**    IMPORTING
**      filelength          = flength
*      TABLES
*        DATA_TAB            = <FS_TABLE>
*      EXCEPTIONS
*        FILE_OPEN_ERROR     = 1
*        INVALID_TABLE_WIDTH = 2
*        INVALID_TYPE        = 3.
    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        FILENAME                = LV_FILE
        FILETYPE                = 'DAT'
        HAS_FIELD_SEPARATOR     = 'X'
      TABLES
        DATA_TAB                = <FS_TABLE>
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
*20090205 1ST Upgrade UPGDCC01 end*************************************
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.

    FIND '.XLS' IN LC_FILE .
    IF SY-SUBRC = 0.
*2022.12.13 AIP도입으로 변경
*      CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
*        EXPORTING
**     I_FIELD_SEPERATOR          =
**     I_LINE_HEADER              =
*          i_tab_raw_data             = v_data
*          i_filename                     = lc_file
*        TABLES
*          i_tab_converted_data       = <fs_table>
*       EXCEPTIONS
*         conversion_failed          = 1
*         OTHERS                        = 2.
*
*      IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDIF.
      DATA : LV_MESSAGE   TYPE  STRING.

      CALL FUNCTION 'ZCOMM_UPLOAD_EXCEL'
        EXPORTING
          I_HEADERLINE = 0
          I_FILENAME   = LC_FILE
        IMPORTING
          E_MESSAGE    = LV_MESSAGE
        TABLES
          T_TAB        = <FS_TABLE>.

      IF LV_MESSAGE IS NOT INITIAL.
        MESSAGE S001 WITH LV_MESSAGE.
      ENDIF.

    ENDIF.
  ENDIF.

* 데이타 건수 체크
  DELETE <FS_TABLE> INDEX 1.
ENDFORM.                    " UPLOAD_DATA
*&---------------------------------------------------------------------*
*&      Form  INIT_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INIT_COMMAND .

  CLEAR: FCODE_A[], FCODE_B[], FCODE_C[].

  APPEND 'ZPOST' TO FCODE_A.
  APPEND 'ZREVS' TO FCODE_A.
  APPEND 'ZREVS' TO FCODE_B.
  APPEND 'ZPOST' TO FCODE_C.
ENDFORM.                    " INIT_COMMAND
*&---------------------------------------------------------------------*
*&      Form  GET_SEQ_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_SEQNO  text
*----------------------------------------------------------------------*
FORM GET_SEQ_NO  USING    P_SEQNO.
  DATA: IT_ZPBT0030 LIKE ZPBT0030 OCCURS 0 WITH HEADER LINE.
  DATA: FDATE     LIKE SY-DATUM,
        TDATE     LIKE SY-DATUM,
        LV_SEQ(2) TYPE N.


  CLEAR: GV_FDATE, GV_TDATE.

  FDATE = P_ZLDAT.
  FDATE+6(2) = '01'.

  GV_FDATE = FDATE.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = P_ZLDAT
    IMPORTING
      LAST_DAY_OF_MONTH = TDATE
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2.

  GV_TDATE = TDATE.

  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  SELECT *
    INTO TABLE IT_ZPBT0030
    FROM ZPBT0030
   WHERE BUDAT >= FDATE
     AND BUDAT <= TDATE.

  IF SY-SUBRC = 0.
    SORT IT_ZPBT0030 BY REQ_NO DESCENDING.
    READ TABLE IT_ZPBT0030 INDEX 1.
    LV_SEQ = IT_ZPBT0030-REQ_NO+8(2).
    LV_SEQ = LV_SEQ + 1.
  ELSE.
    LV_SEQ = '01'.
  ENDIF.

  CONCATENATE 'BD' P_ZLDAT+0(6) LV_SEQ
           INTO P_SEQNO.
ENDFORM.                    " GET_SEQ_NO
*&---------------------------------------------------------------------*
*&      Form  INIT_FUNC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INIT_FUNC .
  CONCATENATE ICON_LINK TEXT-012    "재고실사 차이전기 조회
         INTO SSCRFIELDS-FUNCTXT_01.
ENDFORM.                    " INIT_FUNC
*&---------------------------------------------------------------------*
*&      Form  ACTION_FUNC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ACTION_FUNC .
  IF SSCRFIELDS-UCOMM = 'FC01'.
    CALL TRANSACTION 'ZPBR0031'.
  ENDIF.

ENDFORM.                    " ACTION_FUNC
*&---------------------------------------------------------------------*
*& Form SPLIT_EXCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SPLIT_EXCEL .

  DATA: BEGIN OF LS_MATNR,
          MATNR TYPE MATNR,
        END OF LS_MATNR.
  DATA: LT_MATNR LIKE TABLE OF LS_MATNR.

  DATA: BEGIN OF LS_AUFNR,
          MATNR    LIKE MATDOC-MATNR,
          AUFNR    LIKE MATDOC-AUFNR,
          AUFNRCNT TYPE I,
        END OF LS_AUFNR.
  DATA: LT_AUFNR LIKE TABLE OF LS_AUFNR.

  DATA: LT_LIST LIKE TABLE OF IT_LIST.

  DATA: LV_SPLIT TYPE P DECIMALS 5.
  DATA: LV_ERFMG TYPE ZW_QTY.
  DATA: LV_LAST TYPE ZW_QTY.
  DATA: L_INDEX TYPE I.

  DATA: LV_NUM(4)   TYPE I,
        LV_COUNT(4) TYPE N.

  CLEAR: LT_MATNR.
  LOOP AT IT_LIST WHERE ZSIGN = '@5B@'.
    MOVE-CORRESPONDING IT_LIST TO LS_MATNR.
    COLLECT LS_MATNR INTO LT_MATNR.
    CLEAR: LS_MATNR.
  ENDLOOP.

*-자재별 오더 count
  IF LT_MATNR IS NOT INITIAL.
    SORT LT_MATNR BY MATNR.
    DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING MATNR.

    CLEAR: LT_AUFNR.
    SELECT MATNR, AUFNR
      FROM MATDOC
       FOR ALL ENTRIES IN @LT_MATNR
     WHERE WERKS EQ @P_WERKS
       AND MATNR EQ @LT_MATNR-MATNR
       AND BWART IN ('261', '262')
       AND AUFNR NE @SPACE
       AND BUDAT BETWEEN @GV_FDATE AND @GV_TDATE
      INTO CORRESPONDING FIELDS OF TABLE @LT_AUFNR.

    SORT LT_AUFNR BY MATNR AUFNR.
    DELETE ADJACENT DUPLICATES FROM LT_AUFNR COMPARING MATNR AUFNR.

    CLEAR: GT_AUFNRCNT.
    LOOP AT LT_AUFNR ASSIGNING FIELD-SYMBOL(<LS_AUFNR>).
      <LS_AUFNR>-AUFNRCNT = 1.

      MOVE-CORRESPONDING <LS_AUFNR> TO GS_AUFNRCNT.
      COLLECT GS_AUFNRCNT INTO GT_AUFNRCNT.
      CLEAR: GS_AUFNRCNT.
    ENDLOOP.

    SORT GT_AUFNRCNT BY MATNR.

    LOOP AT GT_AUFNRCNT ASSIGNING FIELD-SYMBOL(<FS>).
      CLEAR: LV_SPLIT.
      LV_SPLIT = <FS>-AUFNRCNT / GV_SPLIT.

      CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
        EXPORTING
          I_RTYPE     = '+'
          I_RUNIT     = '1'
          I_VALUE     = LV_SPLIT
        IMPORTING
          E_VALUE_RND = <FS>-SPLIT.
    ENDLOOP.
  ENDIF.

  CLEAR: LT_LIST.
  APPEND LINES OF IT_LIST TO LT_LIST.

  CLEAR: IT_LIST, IT_LIST[].
  LOOP AT LT_LIST INTO DATA(LS_LIST).
    IF LS_LIST-ZSIGN = '@5B@'.
      READ TABLE GT_AUFNRCNT INTO DATA(LS_AUFNRCNT) WITH KEY MATNR = LS_LIST-MATNR.
      IF LS_AUFNRCNT-SPLIT LE 1.
        MOVE-CORRESPONDING LS_LIST TO IT_LIST.
        APPEND IT_LIST.
      ELSE.
        CLEAR: LV_ERFMG.
        LV_ERFMG = LS_LIST-ERFMG / LS_AUFNRCNT-SPLIT.  "건수로 나눈 수량

        CLEAR: LV_LAST.
        LV_LAST = LS_LIST-ERFMG.

        DO LS_AUFNRCNT-SPLIT TIMES.
          L_INDEX = L_INDEX + 1.

          MOVE-CORRESPONDING LS_LIST TO IT_LIST.

          IF L_INDEX NE LS_AUFNRCNT-SPLIT.
            IT_LIST-ERFMG = LV_ERFMG.

            LV_LAST = LV_LAST - LV_ERFMG.

          ELSEIF L_INDEX EQ LS_AUFNRCNT-SPLIT.
            IT_LIST-ERFMG = LV_LAST.
          ENDIF.

          APPEND IT_LIST.
        ENDDO.

      ENDIF.

    ELSE.
      MOVE-CORRESPONDING LS_LIST TO IT_LIST.
      APPEND IT_LIST.
    ENDIF.

    CLEAR: IT_LIST, LS_LIST.

  ENDLOOP.

  LOOP AT IT_LIST ASSIGNING FIELD-SYMBOL(<FS_S>).
    LV_NUM = LV_NUM + 1.
    CLEAR LV_COUNT.
    LV_COUNT = LV_NUM.

    <FS_S>-SORT_NO = LV_COUNT.
  ENDLOOP.

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
