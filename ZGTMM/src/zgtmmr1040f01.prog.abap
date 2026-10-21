*&---------------------------------------------------------------------*
*& Include          ZGTMMR1040F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CHECK_AUTH .

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'BUKRS' FIELD P_BUKRS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE E172 WITH P_BUKRS. "회사코드[&] 작업권한을 확인하세요.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트 [&] 작업권한을 확인하세요.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'EKORG' FIELD P_EKORG.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'S_EKGRP-LOW'.
  MESSAGE E170 WITH P_EKORG."구매조직 [&] 작업권한을 확인하세요.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_SCREEN_ATTR_1000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_SCREEN_ATTR_1000 .

  "라디오버튼 Text 설정
  CASE ABAP_TRUE.
    WHEN P_SIZE.
      GV_TEXT1 = TEXT-R05.
    WHEN OTHERS.
      GV_TEXT1 = TEXT-R06.
  ENDCASE.

  "필드 별 속성 설정
  LOOP AT SCREEN.
    "필수 입력
    CASE SCREEN-GROUP1.
      WHEN 'BUK' OR 'EKO' OR 'WRK' OR 'LIF' OR 'ZYE' OR 'FIL'.
        SCREEN-REQUIRED = 2.
        MODIFY SCREEN.
    ENDCASE.

    "활성화/비활성화
    CASE SCREEN-GROUP1.
      WHEN 'DIS'. "조회 시 활성
        IF P_DISP EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.

      WHEN 'AUT'. "자동생성/조회 시 활성
        IF P_DISP EQ ABAP_TRUE OR P_AUTO EQ ABAP_TRUE.  " 자동생성/조회 시 활성
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.

      WHEN 'CRE' OR 'LIF' OR 'ZYE'.
        IF P_DISP EQ ABAP_TRUE.
          SCREEN-ACTIVE = 0.
        ELSE.
          SCREEN-ACTIVE = 1.
        ENDIF.
        MODIFY SCREEN.

      WHEN 'FIL'.
        IF P_DISP NE ABAP_TRUE AND P_NEW EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.

      WHEN 'LOD'.
        IF P_DRUM EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.
    ENDCASE.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_INITIALIZATION .

  "버튼
  SSCRFIELDS-FUNCTXT_01 = ICON_XLS && TEXT-BT1.
  SSCRFIELDS-FUNCTXT_02 = ICON_XLS && TEXT-BT2.

  "드럼 기호
  CLEAR GT_GUBUN[].
  SELECT DISTINCT
    DRM_GUBUN
    FROM ZGTMM_CV_DRUM_GUBUN
    ORDER BY DRM_GUBUN
    INTO TABLE @GT_GUBUN.

  "드럼 구분(일반/특수)
  CLEAR GT_TYPE_CD[].
  SELECT
    FLD_01 AS DRM_GUBUN,
    FLD_02 AS DRM_TYPE
    FROM ZGTPPT1010
   WHERE MODULE_KIND EQ 'MM'
   AND CODEGRP EQ '0700'
   ORDER BY FLD_01
   INTO CORRESPONDING FIELDS OF TABLE @GT_TYPE_CD.

  "관리 레벨
  CLEAR GT_LV_CD[].
  SELECT
    FLD_01 AS WERKS,
    CAST( FLD_02 AS DEC( 3, 0 ) ) AS DRM_SIZE_F,
    CAST( FLD_03 AS DEC( 3, 0 ) ) AS DRM_SIZE_T,
    CAST( FLD_04 AS DEC( 2, 0 ) ) AS DRM_LV
    FROM ZGTPPT1010
 	WHERE MODULE_KIND EQ 'MM'
       AND CODEGRP EQ '0710'
    ORDER BY FLD_01
    INTO CORRESPONDING FIELDS OF TABLE @GT_LV_CD.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SELECTION_SCREEN .

  CASE SY-UCOMM.
    WHEN 'FC01'. "양식 다운로드
      PERFORM F_DOWNLOAD_SMW0 USING GC_ZGTMMR1040_SIZE.
    WHEN 'FC02'. "양식 다운로드
      PERFORM F_DOWNLOAD_SMW0 USING GC_ZGTMMR1040_DRUM.
    WHEN 'CM1'.
      IF P_SIZE EQ ABAP_TRUE AND P_DISP EQ ABAP_TRUE.
        CLEAR P_DISP.
        P_NEW = ABAP_TRUE.

      ELSEIF P_SIZE EQ ABAP_TRUE AND P_AUTO EQ ABAP_TRUE.
        CLEAR P_AUTO.
        P_NEW = ABAP_TRUE.
      ENDIF.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DOWNLOAD_SMW0
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DOWNLOAD_SMW0 USING PV_OBJID TYPE W3OBJID.

  DATA:
    LS_WWWDATA           TYPE WWWDATATAB,
    LV_DEFAULT_FILE_NAME TYPE STRING,
    LV_FILENAME          TYPE STRING,
    LV_PATH              TYPE STRING,
    LV_FULLPATH          TYPE STRING,
    LV_RC                TYPE SY-SUBRC.

  CONSTANTS
    LC_FILE_EXT          TYPE W3_NAME VALUE 'fileextension'.

  "SMW0 조회
  SELECT SINGLE *
    FROM WWWDATA
   WHERE OBJID EQ @PV_OBJID
    INTO CORRESPONDING FIELDS OF @LS_WWWDATA.

  IF SY-SUBRC NE 0.
    "파일 정보가 없습니다.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E01.
    EXIT.
  ENDIF.

  SELECT SINGLE
    VALUE
    FROM WWWPARAMS
    WHERE RELID EQ @LS_WWWDATA-RELID
    AND OBJID EQ @LS_WWWDATA-OBJID
    AND NAME EQ @LC_FILE_EXT
    INTO @DATA(LV_FILE_EXT).

  LV_DEFAULT_FILE_NAME = LS_WWWDATA-TEXT && LV_FILE_EXT.
  CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG(
    EXPORTING
      DEFAULT_EXTENSION         =   CONV STRING( LV_FILE_EXT )
      DEFAULT_FILE_NAME         =   LV_DEFAULT_FILE_NAME
      FILE_FILTER               =  CONV STRING( LV_FILE_EXT )
    CHANGING
         FILENAME                  =   LV_FILENAME
         PATH                      =   LV_PATH
         FULLPATH                  =   LV_FULLPATH
       EXCEPTIONS
         CNTL_ERROR                =   1
         ERROR_NO_GUI              =   2
         NOT_SUPPORTED_BY_GUI      =   3
         INVALID_DEFAULT_FILE_NAME =   4
         OTHERS                    =   5
     ).

  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE GC_S NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
      DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  CHECK LV_FULLPATH IS NOT INITIAL.
  CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
    EXPORTING
      KEY         = LS_WWWDATA
      DESTINATION = CONV LOCALFILE( LV_FULLPATH )
    IMPORTING
      RC          = LV_RC.

  CHECK LV_RC EQ 0.

  CL_GUI_FRONTEND_SERVICES=>EXECUTE(
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
            OTHERS                 = 10
        ).

  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE GC_S NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
      DISPLAY LIKE GC_E.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_F4_FILE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_FILE
*&---------------------------------------------------------------------*
FORM F_F4_FILE  USING  PV_FILE.

  DATA:
    LT_FILE_TABLE TYPE FILETABLE,
    LV_RC         TYPE I,
    LV_FILE_PATH  TYPE STRING.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      DEFAULT_FILENAME = SPACE
      FILE_FILTER      = CL_GUI_FRONTEND_SERVICES=>FILETYPE_EXCEL
    CHANGING
      FILE_TABLE       = LT_FILE_TABLE
      RC               = LV_RC
    EXCEPTIONS
      OTHERS           = 1.

  CHECK SY-SUBRC EQ 0 AND LT_FILE_TABLE[] IS NOT INITIAL.

  READ TABLE LT_FILE_TABLE INDEX 1 INTO LV_FILE_PATH.
  CHECK NOT LV_FILE_PATH IS INITIAL.
  PV_FILE = LV_FILE_PATH.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_START_OF_SELECTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_START_OF_SELECTION .

  CLEAR GV_EDIT. "수정모드

  "입력 값 점검
  PERFORM F_CHECK_INPUT_VALUES_1000.

  CASE ABAP_TRUE.
    WHEN P_SIZE. "규격 단가 등록
      PERFORM F_GET_LIST_FOR_SIZE.
    WHEN P_DRUM.
      PERFORM F_GET_LIST_FOR_DRUM.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_INPUT_VALUES_1000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CHECK_INPUT_VALUES_1000 .

  "오류가 있으면 종료
  IF GV_ERROR EQ ABAP_TRUE.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_LIST_FOR_SIZE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_LIST_FOR_SIZE .

  "초기화
  CLEAR GT_SIZE[].

  CASE ABAP_TRUE.
    WHEN P_NEW. "신규 등록
      PERFORM F_GET_SIZE_XLS_DATA.

    WHEN P_LOAD. "조회/수정
      PERFORM F_GET_SIZE_CBO_DATA.
  ENDCASE.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_SIZE_XLS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_SIZE_XLS_DATA .

  "Excel 파일 읽기
  DATA LT_XLS TYPE STANDARD TABLE OF TY_SIZE_XLS.
  PERFORM F_GET_EXCEL_DATA USING 1 4 8 60000 P_FILE CHANGING LT_XLS.

  "데이터 점검 및 ALV 데이터 설정
  DATA LV_CHECK TYPE C LENGTH 1.
  PERFORM F_CHECK_EXCEL_DATA_SIZE USING LT_XLS CHANGING GT_SIZE LV_CHECK.

  IF LV_CHECK EQ GC_E.
    CLEAR GT_SIZE[].
  ENDIF.

  "상태 값 설정
  PERFORM F_SET_STATUS_MSG_SIZE CHANGING GT_SIZE.

  "수정 가능
  GV_EDIT = ABAP_TRUE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_EXCEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_1
*&      --> P_4
*&      --> P_1
*&      --> P_6000
*&      <-- LT_XLS
*&---------------------------------------------------------------------*
FORM F_GET_EXCEL_DATA  USING PV_BEGIN_COL
                                                      PV_BEGIN_ROW
                                                      PV_END_COL
                                                      PV_END_ROW
                                                      PV_FILE
                       CHANGING CT_XLS TYPE STANDARD TABLE.
  CLEAR:
     CT_XLS[].

  DATA LT_ITAB TYPE STANDARD TABLE OF ALSMEX_TABLINE.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      FILENAME                = PV_FILE
      I_BEGIN_COL             = PV_BEGIN_COL
      I_BEGIN_ROW             = PV_BEGIN_ROW
      I_END_COL               = PV_END_COL
      I_END_ROW               = PV_END_ROW
    TABLES
      INTERN                  = LT_ITAB
    EXCEPTIONS
      INCONSISTENT_PARAMETERS = 1
      UPLOAD_OLE              = 2
      OTHERS                  = 3.

  CHECK SY-SUBRC EQ 0.

  DATA:
    LO_DATA    TYPE REF TO DATA,
    LV_COL_IDX TYPE INT4.

  FIELD-SYMBOLS <LS_STRU> TYPE ANY.

  CASE ABAP_TRUE.
    WHEN P_SIZE.
      CREATE DATA LO_DATA TYPE TY_SIZE_XLS.
    WHEN P_DRUM.
      CREATE DATA LO_DATA TYPE TY_DRUM_XLS.
    WHEN OTHERS.
      EXIT.
  ENDCASE.

  ASSIGN LO_DATA->* TO <LS_STRU>.

  LOOP AT LT_ITAB ASSIGNING FIELD-SYMBOL(<LS_G>) GROUP BY ( ROW = <LS_G>-ROW )
                                                                             ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    "값 설정
    CLEAR <LS_STRU>.
    LOOP AT GROUP <LS_GROUP> ASSIGNING FIELD-SYMBOL(<LS_XLS>).
      LV_COL_IDX = <LS_XLS>-COL.
      ASSIGN COMPONENT LV_COL_IDX OF STRUCTURE <LS_STRU> TO FIELD-SYMBOL(<LV_VAL>).
      CHECK <LV_VAL> IS ASSIGNED.
      <LV_VAL> = <LS_XLS>-VALUE.
    ENDLOOP.

    "라인추가
    APPEND <LS_STRU> TO CT_XLS.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_EXCEL_DATA_SIZE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_XLS
*&      <-- GT_SIZE
*&---------------------------------------------------------------------*
FORM F_CHECK_EXCEL_DATA_SIZE  USING    PT_XLS TYPE TY_T_SIZE_XLS
                      CHANGING CT_SIZE TYPE TY_T_SIZE
                                       CV_CHECK.

  "초기화
  CLEAR:
    CT_SIZE[],
    CV_CHECK.

  DATA LS_SIZE TYPE TY_SIZE.

  "통화 키
  SELECT SINGLE
    WAERS
    FROM T001
    WHERE BUKRS EQ @P_BUKRS
    INTO @DATA(LV_WAERS).

  LOOP AT PT_XLS ASSIGNING FIELD-SYMBOL(<LS_XLS>).

    "초기화
    CLEAR LS_SIZE.

    "대문자 변경
    TRANSLATE:
    <LS_XLS>-DRM_GUBUN TO UPPER CASE. "드럼 기호

    "콤마 제거
    REPLACE ALL OCCURRENCES OF ',' IN <LS_XLS>-SDR_NETPR WITH SPACE. "신드럼 단가
    REPLACE ALL OCCURRENCES OF ',' IN <LS_XLS>-GDR_NETPR WITH SPACE. "고드럼 단가
    REPLACE ALL OCCURRENCES OF ',' IN <LS_XLS>-BOARD_NETPR WITH SPACE. "골판지 조립 단가
    REPLACE ALL OCCURRENCES OF ',' IN <LS_XLS>-MARK_NETPR WITH SPACE. "신드럼 마킹 단가
    REPLACE ALL OCCURRENCES OF ',' IN <LS_XLS>-MARK_H_NETPR WITH SPACE. "한전 마킹 단가
    REPLACE ALL OCCURRENCES OF ',' IN <LS_XLS>-DIS_NETPR WITH SPACE. "고드럼 해체 단가

    "공백 제거
    CONDENSE:
      <LS_XLS>-DRM_SIZE,
      <LS_XLS>-SDR_NETPR,
      <LS_XLS>-GDR_NETPR,
      <LS_XLS>-BOARD_NETPR,
      <LS_XLS>-MARK_NETPR,
      <LS_XLS>-MARK_H_NETPR,
      <LS_XLS>-DIS_NETPR.

    READ TABLE GT_GUBUN WITH KEY DRM_GUBUN = <LS_XLS>-DRM_GUBUN BINARY SEARCH TRANSPORTING NO FIELDS.
    IF SY-SUBRC NE 0.
      "유효하지 않은 &을 포함합니다.
      MESSAGE S162 DISPLAY LIKE GC_E WITH <LS_XLS>-DRM_GUBUN .
      CV_CHECK = GC_E.
*      EXIT.
      LEAVE LIST-PROCESSING.
    ENDIF.

    IF <LS_XLS>-DRM_SIZE CN '0123456789'.
      "드럼 규격에는 숫자만 입력이 가능합니다.
      MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E02.
      CV_CHECK = GC_E.
*      EXIT.
      LEAVE LIST-PROCESSING.
    ENDIF.

    "단가에는 숫자만 입력이 가능합니다.
    PERFORM F_SET_STRING_TO_CURR USING LV_WAERS CHANGING <LS_XLS>-SDR_NETPR CV_CHECK.
    IF CV_CHECK EQ GC_E. EXIT. ENDIF.
    PERFORM F_SET_STRING_TO_CURR USING LV_WAERS CHANGING <LS_XLS>-GDR_NETPR CV_CHECK.
    IF CV_CHECK EQ GC_E. EXIT. ENDIF.
    PERFORM F_SET_STRING_TO_CURR USING LV_WAERS CHANGING <LS_XLS>-BOARD_NETPR CV_CHECK.
    IF CV_CHECK EQ GC_E. EXIT. ENDIF.
    PERFORM F_SET_STRING_TO_CURR USING LV_WAERS CHANGING <LS_XLS>-MARK_NETPR CV_CHECK.
    IF CV_CHECK EQ GC_E. EXIT. ENDIF.
    PERFORM F_SET_STRING_TO_CURR USING LV_WAERS CHANGING <LS_XLS>-MARK_H_NETPR CV_CHECK.
    IF CV_CHECK EQ GC_E. EXIT. ENDIF.
    PERFORM F_SET_STRING_TO_CURR USING LV_WAERS CHANGING <LS_XLS>-DIS_NETPR CV_CHECK.
    IF CV_CHECK EQ GC_E. EXIT. ENDIF.

    "값 설정
    LS_SIZE = CORRESPONDING #( <LS_XLS> ).
    LS_SIZE-BUKRS = P_BUKRS.
    LS_SIZE-EKORG = P_EKORG.
    LS_SIZE-WERKS = P_WERKS.
    LS_SIZE-LIFNR = P_LIFNR.
    LS_SIZE-ZYEAR = P_YEAR.
    LS_SIZE-WAERS = LV_WAERS.

    "라인추가
    CT_SIZE = VALUE #( BASE CT_SIZE ( LS_SIZE ) ).

  ENDLOOP.

  "오류가 없는 경우
  CHECK CV_CHECK NE GC_E.

*  "기존 데이터 점검
*  SELECT
*    Z1~DRM_GUBUN,
*    Z1~DRM_SIZE
*    FROM ZGTMMT1041 AS Z1
*    WHERE Z1~BUKRS EQ @P_BUKRS
*      AND Z1~EKORG EQ @P_EKORG
*      AND Z1~WERKS EQ @P_WERKS
*      AND Z1~LIFNR EQ @P_LIFNR
*      AND Z1~ZYEAR EQ @P_YEAR
*      AND EXISTS (
*          SELECT ZZ~DRM_GUBUN, ZZ~DRM_SIZE
*            FROM @CT_SIZE AS ZZ
*            WHERE ZZ~DRM_GUBUN EQ Z1~DRM_GUBUN
*              AND  ZZ~DRM_SIZE EQ Z1~DRM_SIZE
*      )
*    ORDER BY Z1~DRM_GUBUN, Z1~DRM_SIZE
*    INTO TABLE @DATA(LT_ORG).

  LOOP AT CT_SIZE ASSIGNING FIELD-SYMBOL(<LS_SIZE>).
    <LS_SIZE>-ZSTAT = ICON_CREATE. "업로드는 신규 아이콘
    <LS_SIZE>-ZNEW = ABAP_TRUE.
    <LS_SIZE>-ZCHG = ABAP_TRUE.
*
*    READ TABLE LT_ORG WITH KEY DRM_GUBUN = <LS_SIZE>-DRM_GUBUN DRM_SIZE = <LS_SIZE>-DRM_SIZE
*                                                BINARY SEARCH TRANSPORTING NO FIELDS.
*    IF SY-SUBRC EQ 0.
**      <LS_SIZE>-ZSTAT = ICON_CHANGE.
*      <LS_SIZE>-ZCHG = ABAP_TRUE.
*      <LS_SIZE>-ZSTYLE = VALUE #( ( FIELDNAME = 'DRM_GUBUN' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
*                                                  ( FIELDNAME = 'DRM_SIZE' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
*    ELSE.
**      <LS_SIZE>-ZSTAT = ICON_CREATE.
*      <LS_SIZE>-ZNEW = ABAP_TRUE.
*      <LS_SIZE>-ZCHG = ABAP_TRUE.
*    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_STRING_TO_CURR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_WAERS
*&      --> <LS_XLS>_SDR_NETPR
*&      <-- LS_SIZE_SDR_NETPR
*&      <-- CV_CHECK
*&---------------------------------------------------------------------*
FORM F_SET_STRING_TO_CURR  USING    PV_WAERS
                           CHANGING CV_STR CV_CHECK.
  DATA:
    LV_AMT_EXT TYPE BAPICURR-BAPICURR,
    LV_AMT_INT TYPE MATDOC-DMBTR.

  IF CV_STR CN '0123456789.'.
    "단가에는 숫자만 입력이 가능합니다.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E03.
*    EXIT.
    LEAVE LIST-PROCESSING.
  ELSE.
    "소숫점이 2개 이상이면 에러
    IF COUNT( VAL = CV_STR SUB = '.' ) GT 1.
      "단가에는 숫자만 입력이 가능합니다.
      MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E03.
*      EXIT.
      LEAVE LIST-PROCESSING.
    ELSE.
      CLEAR:
       LV_AMT_EXT,
       LV_AMT_INT.

      "금액 변환(Ext - > Int)
      LV_AMT_EXT = CV_STR.
      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
        EXPORTING
          CURRENCY             = PV_WAERS
          AMOUNT_EXTERNAL      = LV_AMT_EXT
          MAX_NUMBER_OF_DIGITS = 23
        IMPORTING
          AMOUNT_INTERNAL      = LV_AMT_INT.

      CV_STR = LV_AMT_INT.
    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_STATUS_MSG_SIZE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_SIZE
*&---------------------------------------------------------------------*
FORM F_SET_STATUS_MSG_SIZE  CHANGING CT_SIZE TYPE TY_T_SIZE.

  CHECK CT_SIZE[] IS NOT INITIAL.

  DATA LT_DUPL TYPE TY_T_KEY_SIZE.

  SELECT
    ZZ~DRM_GUBUN,
    ZZ~DRM_SIZE
    FROM @CT_SIZE AS ZZ
    GROUP BY ZZ~DRM_GUBUN, ZZ~DRM_SIZE
    HAVING SUM( 1 ) GT 1
    ORDER BY ZZ~DRM_GUBUN, ZZ~DRM_SIZE
    INTO TABLE @LT_DUPL.

  LOOP AT CT_SIZE ASSIGNING FIELD-SYMBOL(<LS_SIZE>).
    PERFORM F_CHK_LINE_DATA_SIZE USING LT_DUPL CHANGING <LS_SIZE>.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHK_LINE_DATA_SIZE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_SIZE>
*&---------------------------------------------------------------------*
FORM F_CHK_LINE_DATA_SIZE  USING PT_DUPL TYPE TY_T_KEY_SIZE CHANGING CS_SIZE TYPE TY_SIZE.

  DATA:
    LV_MSG TYPE BAPI_MSG,
    LT_MSG TYPE STANDARD TABLE OF TY_MSG_T.

  "기본 녹색 설정
  CS_SIZE-STATUS = ICON_LED_GREEN.
  CS_SIZE-MESSAGE = SPACE.

*키 값 중복             GT_SIZE 내에 동일한 DRM_GUBUN & DRM_SIZE 존재      중복: 드럼기호-규격
  READ TABLE PT_DUPL WITH KEY DRM_GUBUN = CS_SIZE-DRM_GUBUN DRM_SIZE = CS_SIZE-DRM_SIZE
                                            BINARY SEARCH TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CS_SIZE-STATUS = ICON_LED_RED.
    LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = TEXT-E04 ) ) .
  ENDIF.

*드럼 기호 오입력              ZGTMM_CV_DRUM_GUBUN 기준 DRM_GUBUN 미존재      오류: 드럼기호

  READ TABLE GT_GUBUN WITH KEY DRM_GUBUN = CS_SIZE-DRM_GUBUN BINARY SEARCH TRANSPORTING NO FIELDS.
  IF SY-SUBRC NE 0.
    CS_SIZE-STATUS = ICON_LED_RED.
    LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = TEXT-E05 )  ).
  ENDIF.

*단가 누락 - 신드럼 입고             SDR_NETPR IS INITIAL      단가 누락: 신드럼 입고(필수)
  IF CS_SIZE-SDR_NETPR IS INITIAL
        OR CS_SIZE-GDR_NETPR IS INITIAL
        OR CS_SIZE-BOARD_NETPR IS INITIAL
        OR CS_SIZE-MARK_NETPR IS INITIAL
        OR CS_SIZE-DIS_NETPR IS INITIAL.

    IF CS_SIZE-SDR_NETPR IS INITIAL.
      CS_SIZE-STATUS = ICON_LED_RED.
      LV_MSG = TEXT-E06. "신드럼 입고(필수)
    ENDIF.

    IF CS_SIZE-WERKS NE '6600'. "전주는 제외
*고드럼 입고   GDR_NETPR IS INITIAL      단가 누락: 고드럼 입고
      IF CS_SIZE-GDR_NETPR IS INITIAL.
        IF CS_SIZE-STATUS EQ ICON_LED_GREEN. CS_SIZE-STATUS = ICON_LED_YELLOW. ENDIF.
        IF LV_MSG IS NOT INITIAL.
          LV_MSG = |{ LV_MSG }, { TEXT-E07 }|. ""고드럼 입고
        ELSE.
          LV_MSG = TEXT-E07. "고드럼 입고
        ENDIF.
      ENDIF.

*골판지 조립   BOARD_NETPR IS INITIAL      단가 누락: 골판지 조립
      IF CS_SIZE-BOARD_NETPR IS INITIAL.
        IF CS_SIZE-STATUS EQ ICON_LED_GREEN. CS_SIZE-STATUS = ICON_LED_YELLOW. ENDIF.
        IF LV_MSG IS NOT INITIAL.
          LV_MSG = |{ LV_MSG }, { TEXT-E08 }|. ""골판지 조립
        ELSE.
          LV_MSG = TEXT-E08. "골판지 조립
        ENDIF.
      ENDIF.

*신드럼 마킹   MARK_NETPR IS INITIAL     단가 누락: 마킹
      IF CS_SIZE-MARK_NETPR IS INITIAL.
        IF CS_SIZE-STATUS EQ ICON_LED_GREEN. CS_SIZE-STATUS = ICON_LED_YELLOW. ENDIF.
        IF LV_MSG IS NOT INITIAL.
          LV_MSG = |{ LV_MSG }, { TEXT-E09 }|. ""마킹
        ELSE.
          LV_MSG = TEXT-E09. "마킹
        ENDIF.
      ENDIF.

*고드럼 해체   DIS_NETPR IS INITIAL      단가 누락: 고드럼 해체
      IF CS_SIZE-DIS_NETPR IS INITIAL.
        IF CS_SIZE-STATUS EQ ICON_LED_GREEN. CS_SIZE-STATUS = ICON_LED_YELLOW. ENDIF.
        IF LV_MSG IS NOT INITIAL.
          LV_MSG = |{ LV_MSG }, { TEXT-E10 }|. ""고드럼 해체
        ELSE.
          LV_MSG = TEXT-E10. "고드럼 해체
        ENDIF.
      ENDIF.
    ENDIF.

    IF LV_MSG IS NOT INITIAL.
      "단가 누락:
      LV_MSG = |{ TEXT-E11 } { LV_MSG } |.
      LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = LV_MSG  ) ).
    ENDIF.
  ENDIF.

  "메세지 설정
  LOOP AT LT_MSG ASSIGNING FIELD-SYMBOL(<LS_MSG>).
    IF CS_SIZE-MESSAGE IS NOT INITIAL.
      CS_SIZE-MESSAGE = |{ CS_SIZE-MESSAGE }, { <LS_MSG>-MESSAGE }|.
    ELSE.
      CS_SIZE-MESSAGE = <LS_MSG>-MESSAGE.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_SIZE_CBO_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_SIZE_CBO_DATA .

  "기존 데이터 점검
  SELECT
    Z1~BUKRS,
    Z1~EKORG,
    Z1~WERKS,
    Z1~LIFNR,
    Z1~ZYEAR,
    Z1~DRM_GUBUN,
    Z1~DRM_SIZE,
    Z1~WAERS,
    Z1~SDR_NETPR,
    Z1~GDR_NETPR,
    Z1~BOARD_NETPR,
    Z1~MARK_NETPR,
    Z1~MARK_H_NETPR,
    Z1~DIS_NETPR
    FROM ZGTMMT1041 AS Z1
    WHERE Z1~BUKRS EQ @P_BUKRS
      AND Z1~EKORG EQ @P_EKORG
      AND Z1~WERKS EQ @P_WERKS
      AND Z1~LIFNR EQ @P_LIFNR
      AND Z1~ZYEAR EQ @P_YEAR
    ORDER BY Z1~DRM_GUBUN, Z1~DRM_SIZE
    INTO CORRESPONDING FIELDS OF TABLE @GT_SIZE.

  LOOP AT GT_SIZE ASSIGNING FIELD-SYMBOL(<LS_SIZE>).
*    <LS_SIZE>-STATUS = ICON_LED_GREEN.
    <LS_SIZE>-ZSTYLE = VALUE #( ( FIELDNAME = 'DRM_GUBUN' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                                                ( FIELDNAME = 'DRM_SIZE' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_END_OF_SELECTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_END_OF_SELECTION .

  CASE ABAP_TRUE.
    WHEN P_SIZE. "규격 단가 등록

      "신규 등록인 경우 데이터가 없으면 오류
      IF P_NEW EQ ABAP_TRUE AND GT_SIZE[] IS INITIAL.
        MESSAGE S002 DISPLAY LIKE GC_E.
        LEAVE LIST-PROCESSING.
      ENDIF.

      "화면 호출
      CALL SCREEN 100.

    WHEN P_DRUM.

      "신규 등록, 조회/수정 인 경우 데이터가 없으면 오류
      IF ( P_NEW EQ ABAP_TRUE
        OR P_DISP EQ ABAP_TRUE ) AND GT_DRUM[] IS INITIAL.
        MESSAGE S002 DISPLAY LIKE GC_E.
        LEAVE LIST-PROCESSING.
      ENDIF.

      "화면 호출
      CALL SCREEN 200.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_BUKRS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_BUKRS .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR GV_ERROR.

  "필수 값 점검
  IF P_BUKRS IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F01.
  ENDIF.

  CHECK GV_ERROR EQ SPACE.

  "유효성 점검
  SELECT SINGLE
    BUKRS
    FROM T001
    WHERE BUKRS EQ @P_BUKRS
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E013.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_EKORG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_EKORG .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR GV_ERROR.

  "규격 단가 등록 / 드럼 단가 등록 인 경우만 점검
  CHECK P_SIZE EQ  ABAP_TRUE OR P_DRUM EQ ABAP_TRUE.

  "필수 값 점검
  IF P_EKORG IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F02.
  ENDIF.

  "유효성 점검
  SELECT SINGLE
    EKORG
    FROM T024E
    WHERE EKORG EQ @P_EKORG
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E013.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_WERKS .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR GV_ERROR.

  "규격 단가 등록 / 드럼 단가 등록 인 경우만 점검
  CHECK P_SIZE EQ  ABAP_TRUE OR P_DRUM EQ ABAP_TRUE.

  "필수 값 점검
  IF P_WERKS IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F03.
  ENDIF.

  "유효성 점검
  SELECT SINGLE
    WERKS
    FROM T001W
    WHERE WERKS EQ @P_WERKS
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E013.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_LIFNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_LIFNR .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR GV_ERROR.

  "단일 입력 하는 화면인 경우만 진행
  CHECK P_NEW EQ  ABAP_TRUE OR P_LOAD EQ ABAP_TRUE OR P_AUTO EQ ABAP_TRUE.

  "필수 값 점검
  IF P_LIFNR IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F04.
  ENDIF.

  "유효성 점검
  SELECT SINGLE
    LIFNR
    FROM LFA1
    WHERE LIFNR EQ @P_LIFNR
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E013.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_YEAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_YEAR .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR GV_ERROR.

  "단일 입력 하는 화면인 경우만 진행
  CHECK P_NEW EQ  ABAP_TRUE OR P_LOAD EQ ABAP_TRUE OR P_AUTO EQ ABAP_TRUE.

  "필수 값 점검
  IF P_YEAR IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F05.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_FILE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_FILE .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR GV_ERROR.

  "규격 단가 등록 / 드럼 단가 등록 면서 신규등록인 경우만 점검
  CHECK ( P_SIZE EQ  ABAP_TRUE OR P_DRUM EQ ABAP_TRUE ) AND P_NEW EQ ABAP_TRUE.

  "필수 값 점검
  IF P_FILE IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E023.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CONV_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CONV_100 .

  IF GV_EDIT EQ ABAP_TRUE.
    GV_EDIT = SPACE.
  ELSE.
    GV_EDIT = ABAP_TRUE.
  ENDIF.

  "필드카탈로그 설정
  PERFORM F_ADJ_FCAT_100.

  CALL METHOD GO_GRID_100->SET_FRONTEND_FIELDCATALOG
    EXPORTING
      IT_FIELDCATALOG = GT_FCAT_100.

  CALL METHOD GO_GRID_100->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO_100.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SAVE_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SAVE_100 .

  DATA:
    LV_ANS   TYPE C LENGTH 1,
    LV_CHECK TYPE C LENGTH 1.

  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  SELECT COUNT( * ) AS CNT
    FROM @GT_SIZE AS ZZ
    WHERE ZZ~ZCHG EQ @ABAP_TRUE
    INTO @DATA(LV_CHG).

  CHECK LV_CHG GT 0. "생성/변경 건이 있는 경우 진행

  "1건이라도 있는 경우
*에러 메시지 출력 후 반영 하지 않음
*TYPE S DISPLAY LIKE E"     오류가 존재하여  저장할 수 없습니다.
  SELECT COUNT( * ) AS CNT
    FROM @GT_SIZE AS ZZ
    WHERE ZZ~STATUS EQ @ICON_LED_RED
    AND ZZ~ZSTAT NE @ICON_DELETE
    INTO @DATA(LV_CNT_R).
  IF LV_CNT_R GT 0.
    MESSAGE E000 WITH TEXT-E12.
  ENDIF.

*POP UP TO CONFIRM 결과에 따라 저장/취소     "경고 메시지가 있습니다.
*저장 하시겠습니까? (예/아니오)"
  SELECT COUNT( * ) AS CNT
    FROM @GT_SIZE AS ZZ
    WHERE ZZ~STATUS EQ @ICON_LED_YELLOW
    INTO @DATA(LV_CNT_W).
  IF LV_CNT_W GT 0.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR      = TEXT-TT4
        TEXT_QUESTION = TEXT-Q01
      IMPORTING
        ANSWER        = LV_ANS.
  ELSE.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR      = TEXT-TT4
        TEXT_QUESTION = TEXT-Q02
      IMPORTING
        ANSWER        = LV_ANS.
  ENDIF.
  CHECK LV_ANS EQ GC_1.

  DATA:
    LT_MOD TYPE STANDARD TABLE OF ZGTMMT1041,
    LT_DEL TYPE STANDARD TABLE OF ZGTMMT1041.

  LOOP AT GT_SIZE ASSIGNING FIELD-SYMBOL(<LS_SIZE>).
    CHECK <LS_SIZE>-ZCHG EQ ABAP_TRUE.
    CASE <LS_SIZE>-ZSTAT.
      WHEN ICON_DELETE. "삭제
        LT_DEL = VALUE #( BASE LT_DEL ( CORRESPONDING #( <LS_SIZE> ) ) ).
      WHEN ICON_CREATE OR ICON_CHANGE. "신규/수정
        LT_MOD = VALUE #( BASE LT_MOD ( CORRESPONDING #( <LS_SIZE> ) ) ).
    ENDCASE.
  ENDLOOP.

  IF LT_DEL[] IS NOT INITIAL.
    DELETE ZGTMMT1041 FROM TABLE LT_DEL.
  ENDIF.

  IF LT_MOD[] IS NOT INITIAL.
    MODIFY ZGTMMT1041 FROM TABLE LT_MOD.
  ENDIF.

  COMMIT WORK.

  LOOP AT GT_SIZE ASSIGNING <LS_SIZE>.
    CHECK <LS_SIZE>-ZCHG EQ ABAP_TRUE.
    CASE <LS_SIZE>-ZSTAT.
      WHEN ICON_DELETE. "삭제
        DELETE GT_SIZE.
        CONTINUE.
      WHEN ICON_CREATE OR ICON_CHANGE. "신규/수정
        "초기화
        CLEAR:
*          <LS_SIZE>-STATUS,
          <LS_SIZE>-ZSTAT,
          <LS_SIZE>-MESSAGE,
          <LS_SIZE>-ZNEW,
          <LS_SIZE>-ZCHG.
        <LS_SIZE>-STATUS = ICON_LED_GREEN.
        <LS_SIZE>-ZSTYLE = VALUE #( ( FIELDNAME = 'DRM_GUBUN' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                                                    ( FIELDNAME = 'DRM_SIZE' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
    ENDCASE.
  ENDLOOP.


*	실패: TYPE S DISPLAY LIKE E 저장에 실패했습니다.
*	성공: TYPE S 저장에 성공했습니다.
  MESSAGE S000 WITH TEXT-M01.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_LIST_FOR_DRUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_LIST_FOR_DRUM .

  "초기화
  CLEAR GT_DRUM[].

  CASE ABAP_TRUE.
    WHEN P_NEW. "신규 등록
      PERFORM F_GET_DRUM_XLS_DATA.

    WHEN P_LOAD. "이전 연도 조회
      PERFORM F_GET_DRUM_LAST_YEAR_DATA.

      "2026.05.27 누락 드럼 자동 생성기능 추가
    WHEN P_AUTO. "신규 드럼 자동 등록
      PERFORM F_GET_NEW_DRUM_DATA.

    WHEN P_DISP. "조회/변경
      PERFORM F_GET_DRUM_DATA.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_DRUM_XLS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_DRUM_XLS_DATA .

  "Excel 파일 읽기
  DATA LT_XLS TYPE STANDARD TABLE OF TY_DRUM_XLS.
  PERFORM F_GET_EXCEL_DATA USING 1 4 7 60000 P_FILE CHANGING LT_XLS.

  "데이터 점검 및 ALV 데이터 설정
  DATA LV_CHECK TYPE C LENGTH 1.
  PERFORM F_CHECK_EXCEL_DATA_DRUM USING LT_XLS CHANGING GT_DRUM LV_CHECK.

  IF LV_CHECK EQ GC_E.
    CLEAR GT_DRUM[].
  ENDIF.

  "상태 값 설정
  PERFORM F_SET_STATUS_MSG_DRUM CHANGING GT_DRUM.

  "수정 가능
  GV_EDIT = ABAP_TRUE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_EXCEL_DATA_DRUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_XLS
*&      <-- GT_DRUM
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM F_CHECK_EXCEL_DATA_DRUM  USING    PT_XLS TYPE TY_T_DRUM_XLS
                      CHANGING CT_DRUM TYPE TY_T_DRUM
                                       CV_CHECK.

  "초기화
  CLEAR:
    CT_DRUM[],
    CV_CHECK.

  DATA LS_DRUM TYPE TY_DRUM.

  "통화 키
  SELECT SINGLE
    WAERS
    FROM T001
    WHERE BUKRS EQ @P_BUKRS
    INTO @DATA(LV_WAERS).

  LOOP AT PT_XLS ASSIGNING FIELD-SYMBOL(<LS_XLS>).

    "초기화
    CLEAR LS_DRUM.

    "대문자 변경
    TRANSLATE:
    <LS_XLS>-MATNR TO UPPER CASE, "자재코드
    <LS_XLS>-AUTO TO UPPER CASE. "단가 자동계산 여부

    "콤마 제거
    REPLACE ALL OCCURRENCES OF ',' IN <LS_XLS>-DRM_NETPR WITH SPACE. "드럼 입고 단가
    REPLACE ALL OCCURRENCES OF ',' IN <LS_XLS>-BOARD_NETPR WITH SPACE. "골판지 조립 단가
    REPLACE ALL OCCURRENCES OF ',' IN <LS_XLS>-MARK_NETPR WITH SPACE. "신드럼 마킹 단가
    REPLACE ALL OCCURRENCES OF ',' IN <LS_XLS>-MARK_H_NETPR WITH SPACE. "한전 마킹 단가
    REPLACE ALL OCCURRENCES OF ',' IN <LS_XLS>-DIS_NETPR WITH SPACE. "고드럼 해체 단가

    "공백 제거
    CONDENSE:
      <LS_XLS>-MATNR,
      <LS_XLS>-AUTO,
      <LS_XLS>-DRM_NETPR,
      <LS_XLS>-BOARD_NETPR,
      <LS_XLS>-MARK_NETPR,
      <LS_XLS>-MARK_H_NETPR,
      <LS_XLS>-DIS_NETPR.

*자재코드 자재코드  "* 자재코드는 추후 로직에서 검사.
*엑셀 단계에서는 숫자 외 값인 경우만 판별"     자재코드에는 숫자만 입력이 가능합니다.
    IF <LS_XLS>-MATNR CN '0123456789'.
      MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E13.
      CV_CHECK = GC_E.
      LEAVE LIST-PROCESSING.
*      EXIT.
    ENDIF.

*X or NULL 외의 값이 있는 경우      B열에는 X 혹은 빈칸만 입력 가능합니다.
    IF <LS_XLS>-AUTO NE ABAP_TRUE AND <LS_XLS>-AUTO NE SPACE.
      MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E14.
      CV_CHECK = GC_E.
      LEAVE LIST-PROCESSING.
*      EXIT.
    ENDIF.

    "단가에는 숫자만 입력이 가능합니다.
    PERFORM F_SET_STRING_TO_CURR USING LV_WAERS CHANGING <LS_XLS>-DRM_NETPR CV_CHECK.
    IF CV_CHECK EQ GC_E. EXIT. ENDIF.
    PERFORM F_SET_STRING_TO_CURR USING LV_WAERS CHANGING <LS_XLS>-BOARD_NETPR CV_CHECK.
    IF CV_CHECK EQ GC_E. EXIT. ENDIF.
    PERFORM F_SET_STRING_TO_CURR USING LV_WAERS CHANGING <LS_XLS>-MARK_NETPR CV_CHECK.
    IF CV_CHECK EQ GC_E. EXIT. ENDIF.
    PERFORM F_SET_STRING_TO_CURR USING LV_WAERS CHANGING <LS_XLS>-MARK_H_NETPR CV_CHECK.
    IF CV_CHECK EQ GC_E. EXIT. ENDIF.
    PERFORM F_SET_STRING_TO_CURR USING LV_WAERS CHANGING <LS_XLS>-DIS_NETPR CV_CHECK.
    IF CV_CHECK EQ GC_E. EXIT. ENDIF.

    "값 설정
    LS_DRUM = CORRESPONDING #( <LS_XLS> ).
    LS_DRUM-BUKRS = P_BUKRS.
    LS_DRUM-EKORG = P_EKORG.
    LS_DRUM-WERKS = P_WERKS.
    LS_DRUM-LIFNR = P_LIFNR.
    LS_DRUM-ZYEAR = P_YEAR.
    LS_DRUM-WAERS = LV_WAERS.
    LS_DRUM-PEINH = 1.

    "Conversion exit
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT  = LS_DRUM-MATNR
      IMPORTING
        OUTPUT = LS_DRUM-MATNR.

    "라인추가
    CT_DRUM = VALUE #( BASE CT_DRUM ( LS_DRUM ) ).

  ENDLOOP.

  "오류가 없는 경우
  CHECK CV_CHECK NE GC_E.

*  "기존 데이터 점검
*  SELECT
*    Z1~MATNR
*    FROM ZGTMMT1042 AS Z1
*    WHERE Z1~BUKRS EQ @P_BUKRS
*      AND Z1~EKORG EQ @P_EKORG
*      AND Z1~WERKS EQ @P_WERKS
*      AND Z1~LIFNR EQ @P_LIFNR
*      AND Z1~ZYEAR EQ @P_YEAR
*      AND EXISTS (
*          SELECT ZZ~MATNR
*            FROM @CT_DRUM AS ZZ
*            WHERE ZZ~MATNR EQ Z1~MATNR
*      )
*    ORDER BY Z1~MATNR
*    INTO TABLE @DATA(LT_ORG).

  LOOP AT CT_DRUM ASSIGNING FIELD-SYMBOL(<LS_DRUM>).
    <LS_DRUM>-ZSTAT = ICON_CREATE. "업로드는 신규 아이콘
    <LS_DRUM>-ZNEW = ABAP_TRUE.
    <LS_DRUM>-ZCHG = ABAP_TRUE.
    <LS_DRUM>-ZSTYLE = VALUE #( ( FIELDNAME = 'MATNR' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
*    READ TABLE LT_ORG WITH KEY MATNR = <LS_DRUM>-MATNR
*                                                BINARY SEARCH TRANSPORTING NO FIELDS.
*    IF SY-SUBRC EQ 0.
*      <LS_DRUM>-ZCHG = ABAP_TRUE.
*      <LS_DRUM>-ZSTYLE = VALUE #( ( FIELDNAME = 'LIFNR' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
*                                                  ( FIELDNAME = 'ZYEAR' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
*                                                  ( FIELDNAME = 'MATNR' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
*    ELSE.
*      <LS_DRUM>-ZNEW = ABAP_TRUE.
*      <LS_DRUM>-ZCHG = ABAP_TRUE.
*    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_STATUS_MSG_DRUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_DRUM
*&---------------------------------------------------------------------*
FORM F_SET_STATUS_MSG_DRUM  CHANGING CT_DRUM TYPE TY_T_DRUM.

  CHECK CT_DRUM[] IS NOT INITIAL.

  DATA:
    LT_DUPL TYPE TY_T_KEY_DRUM,
    LT_MST  TYPE TY_T_MST,
    LT_MARA TYPE TY_T_MARA.

  "Key 중복
  SELECT
    ZZ~BUKRS,
    ZZ~EKORG,
    ZZ~WERKS,
    ZZ~LIFNR,
    ZZ~ZYEAR,
    ZZ~MATNR
    FROM @CT_DRUM AS ZZ
    GROUP BY ZZ~BUKRS, ZZ~EKORG, ZZ~WERKS, ZZ~LIFNR, ZZ~ZYEAR, ZZ~MATNR
    HAVING SUM( 1 ) GT 1
    ORDER BY ZZ~BUKRS, ZZ~EKORG, ZZ~WERKS, ZZ~LIFNR, ZZ~ZYEAR, ZZ~MATNR
    INTO TABLE @LT_DUPL.

  "특성 값
  SELECT
    V1~MATNR,
    V1~MAKTX,
    V1~DRM_GUBUN,
    V1~DRM_SIZE,
    V1~DRM_SG_TYPE,
    V1~MEINS,
    V1~LVORM
    FROM ZGTMM_CV_DRUM_STATUS AS V1
    WHERE EXISTS (
      SELECT ZZ~MATNR
        FROM @CT_DRUM AS ZZ
        WHERE ZZ~MATNR EQ V1~MATNR
    )
    ORDER BY V1~MATNR
    INTO TABLE @LT_MST.

  "규격 단가
  SELECT
    Z1~BUKRS,
    Z1~EKORG,
    Z1~WERKS,
    Z1~LIFNR,
    Z1~ZYEAR,
    Z1~DRM_GUBUN,
    Z1~DRM_SIZE,
    Z1~WAERS,
    Z1~SDR_NETPR,
    Z1~GDR_NETPR,
    Z1~BOARD_NETPR,
    Z1~MARK_NETPR,
    Z1~MARK_H_NETPR,
    Z1~DIS_NETPR
    FROM ZGTMMT1041 AS Z1
    WHERE EXISTS (
        SELECT ZZ~BUKRS
          FROM @CT_DRUM AS ZZ
          WHERE ZZ~BUKRS EQ Z1~BUKRS
             AND ZZ~EKORG EQ Z1~EKORG
             AND ZZ~WERKS EQ Z1~WERKS
             AND ZZ~LIFNR EQ Z1~LIFNR
             AND ZZ~ZYEAR EQ Z1~ZYEAR
    )
    ORDER BY Z1~BUKRS, Z1~EKORG, Z1~WERKS, Z1~LIFNR, Z1~ZYEAR, Z1~DRM_GUBUN,  Z1~DRM_SIZE
    INTO TABLE @DATA(LT_SIZE).

  "자재마스터
  SELECT
    MR~MATNR
    FROM MARA AS MR
    WHERE EXISTS (
      SELECT ZZ~MATNR
        FROM @CT_DRUM AS ZZ
        WHERE ZZ~MATNR EQ MR~MATNR
    )
    ORDER BY MR~MATNR
    INTO TABLE @LT_MARA.

  "인포레코드
  SELECT
    EE~EKORG,
    EE~WERKS,
    EE~VERID, "생산버전 추가
    EA~LIFNR,
    EA~MATNR,
    AA~DATAB,
    AA~DATBI,
    KP~KBETR
    FROM EINA AS EA
                INNER JOIN
              EINE AS EE ON EA~INFNR EQ EE~INFNR
                INNER JOIN
              A017 AS AA ON EA~LIFNR EQ AA~LIFNR
                              AND EA~MATNR EQ AA~MATNR
                              AND EE~EKORG EQ AA~EKORG
                              AND EE~WERKS EQ AA~WERKS
                              AND EE~ESOKZ EQ AA~ESOKZ
                INNER JOIN
              KONH AS KH ON AA~KNUMH EQ KH~KNUMH
                                AND AA~KAPPL EQ KH~KAPPL
                                AND AA~KSCHL EQ KH~KSCHL
                INNER JOIN
              KONP AS KP ON KH~KNUMH EQ KP~KNUMH
                               AND KH~KAPPL EQ KP~KAPPL
                               AND KH~KSCHL EQ KP~KSCHL
    WHERE EXISTS (
      SELECT ZZ~EKORG
        FROM @CT_DRUM AS ZZ
        WHERE ZZ~EKORG EQ EE~EKORG
           AND ZZ~WERKS EQ EE~WERKS
           AND ZZ~LIFNR EQ EA~LIFNR
           AND ZZ~MATNR EQ EA~MATNR
    )
    AND EA~LOEKZ EQ @SPACE
    AND EE~LOEKZ EQ @SPACE
    AND KP~LOEVM_KO EQ @SPACE
    AND EE~ESOKZ EQ @GC_3
    AND AA~KAPPL EQ @GC_M
    AND AA~KSCHL EQ @GC_PB00
    INTO TABLE @DATA(LT_INFO).

  "드럼 구분, 관리레벨(P_DISP 한정)
  IF P_DISP EQ ABAP_TRUE.
    SELECT *
      FROM ZGTMMT1042
      WHERE BUKRS EQ @P_BUKRS
          AND WERKS EQ @P_WERKS
          AND LIFNR IN @S_LIFNR
          AND DRM_SG_TYPE IN @S_SG_TYP
          AND MATNR IN @S_MATNR
      ORDER BY BUKRS, LIFNR, ZYEAR, MATNR
      INTO TABLE @DATA(LT_1042)
      .
  ENDIF.

  DATA LV_DATE TYPE DATUM.
  LOOP AT CT_DRUM ASSIGNING FIELD-SYMBOL(<LS_DRUM>).
    "특성 값 설정
    READ TABLE LT_MST ASSIGNING FIELD-SYMBOL(<LS_MST>) WITH KEY MATNR = <LS_DRUM>-MATNR BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_DRUM> = CORRESPONDING #( BASE ( <LS_DRUM> ) <LS_MST> ). "값 설정
      IF P_NEW EQ ABAP_TRUE. "신규인 경우
        <LS_DRUM>-BPRME = <LS_DRUM>-MEINS.
      ENDIF.
    ENDIF.

    "일반/특수, 관리레벨 설정 -> P_DISP(조회/수정) 경우 ZGTMMT1042 테이블 참고 하여 가져오도록 수정
    IF P_DISP EQ ABAP_TRUE.
      READ TABLE LT_1042 ASSIGNING FIELD-SYMBOL(<LS_1042>)
                                       WITH KEY BUKRS = <LS_DRUM>-BUKRS LIFNR = <LS_DRUM>-LIFNR
                                                       ZYEAR = <LS_DRUM>-ZYEAR MATNR = <LS_DRUM>-MATNR BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        <LS_DRUM> = CORRESPONDING #( BASE ( <LS_DRUM> ) <LS_1042> ).
      ENDIF.
    ELSE.
      READ TABLE GT_TYPE_CD ASSIGNING FIELD-SYMBOL(<LS_TYPE_CD>) WITH KEY DRM_GUBUN = <LS_DRUM>-DRM_GUBUN BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        <LS_DRUM> = CORRESPONDING #( BASE ( <LS_DRUM> ) <LS_TYPE_CD> ). "값 설정
      ENDIF.
    ENDIF.


    "관리 레벨 설정 (P_DISP 이외)
    IF P_DISP NE ABAP_TRUE.
      LOOP AT GT_LV_CD ASSIGNING FIELD-SYMBOL(<LS_G1>) GROUP BY ( WERKS = <LS_G1>-WERKS )
                                                                                      ASSIGNING FIELD-SYMBOL(<LS_GROUP>).
        CHECK <LS_GROUP>-WERKS = <LS_DRUM>-WERKS.
        LOOP AT GROUP <LS_GROUP> ASSIGNING FIELD-SYMBOL(<LS_LV_CD>).
          CHECK <LS_LV_CD>-DRM_SIZE_F LE <LS_DRUM>-DRM_SIZE AND <LS_LV_CD>-DRM_SIZE_T GE <LS_DRUM>-DRM_SIZE.
          <LS_DRUM>-DRM_LV = <LS_LV_CD>-DRM_LV.
          EXIT.
        ENDLOOP.
      ENDLOOP.
    ENDIF.


    "신드럼은 인포레코드 단가 적용
    IF <LS_DRUM>-DRM_SG_TYPE EQ GC_S.
      IF P_DISP EQ ABAP_TRUE. "조회/수정 인 경우만
        LOOP AT LT_INFO ASSIGNING FIELD-SYMBOL(<LS_IGRP>) GROUP BY ( EKORG = <LS_IGRP>-EKORG
                                                                                                             WERKS = <LS_IGRP>-WERKS
                                                                                                             LIFNR = <LS_IGRP>-LIFNR
                                                                                                             MATNR = <LS_IGRP>-MATNR )
                                                                           ASSIGNING FIELD-SYMBOL(<LS_INF_GROUP>).
          CHECK <LS_INF_GROUP>-EKORG EQ <LS_DRUM>-EKORG
            AND <LS_INF_GROUP>-WERKS EQ <LS_DRUM>-WERKS
            AND <LS_INF_GROUP>-LIFNR EQ <LS_DRUM>-LIFNR
            AND <LS_INF_GROUP>-MATNR EQ <LS_DRUM>-MATNR.

          LV_DATE = |{ <LS_DRUM>-ZYEAR }0101|.
          LOOP AT GROUP <LS_INF_GROUP> ASSIGNING FIELD-SYMBOL(<LS_INF>).
            CHECK <LS_INF>-DATAB LE LV_DATE AND <LS_INF>-DATBI GE LV_DATE.
            <LS_DRUM>-DRM_NETPR = <LS_INF>-KBETR.
            <LS_DRUM>-VERID = <LS_INF>-VERID. "생산버전 추가
          ENDLOOP.
        ENDLOOP.
      ENDIF.

      " 인포레코드 생산버전 / 생산버전 / BOM 존재여부에 따라 상태값 설정
      IF <LS_DRUM>-VERID EQ GC_SC10.  "인포에 생산버전 존재
        <LS_DRUM>-STATUS_SC10 = ICON_LED_GREEN.
      ELSE.
        " BOM+생산버전 SELECT
        SELECT SINGLE MA~STLAN, MA~STLAL, MK~VERID
          FROM MAST AS MA
          LEFT OUTER JOIN MKAL AS MK ON MA~MATNR EQ MK~MATNR
                                                        AND MA~WERKS EQ MK~WERKS
                                                        AND MK~VERID EQ @GC_SC10
          WHERE MA~STLAN EQ @GC_1
              AND MA~STLAL EQ '01'
              AND MA~MATNR EQ @<LS_DRUM>-MATNR
              AND MA~WERKS EQ @<LS_DRUM>-WERKS
            INTO @DATA(LS_SC10).

        IF LS_SC10 IS INITIAL.  "BOM, 생산버전 미존재
          <LS_DRUM>-STATUS_SC10 = ICON_LED_RED.
        ELSEIF LS_SC10-VERID IS INITIAL.  "BOM 존재 / 생산버전 미존재
          <LS_DRUM>-STATUS_SC10 = ICON_LED_YELLOW.
        ELSE.
          <LS_DRUM>-STATUS_SC10 = ICON_LED_GREEN. "BOM, 생산버전 존재
        ENDIF.
        CLEAR: LS_SC10.
      ENDIF.

    ENDIF.

    "3-7-1) 단가 자동 계산
    IF <LS_DRUM>-AUTO EQ ABAP_TRUE.
      CLEAR :
        <LS_DRUM>-DRM_NETPR,
        <LS_DRUM>-BOARD_NETPR,
        <LS_DRUM>-MARK_NETPR,
        <LS_DRUM>-MARK_H_NETPR,
        <LS_DRUM>-DIS_NETPR.

      READ TABLE LT_SIZE ASSIGNING FIELD-SYMBOL(<LS_SIZE>) WITH KEY BUKRS = <LS_DRUM>-BUKRS
                                                                                                         EKORG = <LS_DRUM>-EKORG
                                                                                                         WERKS = <LS_DRUM>-WERKS
                                                                                                         LIFNR = <LS_DRUM>-LIFNR
                                                                                                         ZYEAR = <LS_DRUM>-ZYEAR
                                                                                                         DRM_GUBUN = <LS_DRUM>-DRM_GUBUN
                                                                                                         DRM_SIZE = <LS_DRUM>-DRM_SIZE BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        CASE <LS_DRUM>-DRM_SG_TYPE.
          WHEN GC_S. "신드럼
            <LS_DRUM>-DRM_NETPR = <LS_SIZE>-SDR_NETPR.
            <LS_DRUM>-BOARD_NETPR = <LS_SIZE>-BOARD_NETPR.
            <LS_DRUM>-MARK_NETPR = <LS_SIZE>-MARK_NETPR.
            <LS_DRUM>-MARK_H_NETPR = <LS_SIZE>-MARK_H_NETPR.
          WHEN GC_G."고드럼
            <LS_DRUM>-DRM_NETPR = <LS_SIZE>-GDR_NETPR.
            <LS_DRUM>-BOARD_NETPR = <LS_SIZE>-BOARD_NETPR.
            <LS_DRUM>-DIS_NETPR = <LS_SIZE>-DIS_NETPR.
        ENDCASE.
      ENDIF.
    ENDIF.

    "오류 점검 및 메세지 설정
    PERFORM F_CHK_LINE_DATA_DRUM USING LT_DUPL LT_MST LT_MARA CHANGING <LS_DRUM>.
  ENDLOOP.

  " 결과 SORT
  SORT CT_DRUM[] BY DRM_TYPE DRM_GUBUN DRM_SG_TYPE DRM_SIZE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHK_LINE_DATA_DRUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_DUPL
*&      --> LT_MST
*&      --> LT_MARA
*&      <-- <LS_DRUM>
*&---------------------------------------------------------------------*
FORM F_CHK_LINE_DATA_DRUM  USING  PT_DUPL TYPE TY_T_KEY_DRUM
                                    PT_MST TYPE TY_T_MST
                                    PT_MARA TYPE TY_T_MARA
                           CHANGING CS_DRUM TYPE TY_DRUM.

  DATA:
    LV_MSG_E TYPE BAPI_MSG, "오류:
    LV_MSG_N TYPE BAPI_MSG, "단가 누락:
    LV_MSG_V TYPE BAPI_MSG, "생산버전/BOM 누락:
    LT_MSG   TYPE STANDARD TABLE OF TY_MSG_T.

  "기본 녹색 설정
  CS_DRUM-STATUS = ICON_LED_GREEN.
  CS_DRUM-MESSAGE = SPACE.

*자재코드 오류(미존재-MARA)              MARA에 MATNR 미존재     오류: 미존재 자재코드
  READ TABLE PT_MARA WITH KEY MATNR = CS_DRUM-MATNR BINARY SEARCH TRANSPORTING NO FIELDS.
  IF SY-SUBRC NE 0.
    CS_DRUM-STATUS = ICON_LED_RED.

    IF LV_MSG_E IS NOT INITIAL.
      LV_MSG_E = |{ LV_MSG_E }, { TEXT-E15 }|. "미존재 자재코드
    ELSE.
      LV_MSG_E = TEXT-E15. "미존재 자재코드
    ENDIF.
  ENDIF.

*자재코드 오류(목드럼 外 자재)              ZGTMM_CV_DRUM_STATUS 에 MATNR 미존재      오류: 목드럼 외 자재코드
  READ TABLE PT_MST WITH KEY MATNR = CS_DRUM-MATNR BINARY SEARCH TRANSPORTING NO FIELDS.
  IF SY-SUBRC NE 0.
    CS_DRUM-STATUS = ICON_LED_RED.

    IF LV_MSG_E IS NOT INITIAL.
      LV_MSG_E = |{ LV_MSG_E }, { TEXT-E16 }|. "목드럼 외 자재코드
    ELSE.
      LV_MSG_E = TEXT-E16. "목드럼 외 자재코드
    ENDIF.
  ENDIF.

*자재코드 중복              현재 화면(ITAB) 기준 자재코드 중복      오류: 중복 자재코드
  READ TABLE PT_DUPL WITH KEY BUKRS = CS_DRUM-BUKRS
                                                    EKORG = CS_DRUM-EKORG
                                                    WERKS = CS_DRUM-WERKS
                                                    LIFNR = CS_DRUM-LIFNR
                                                    ZYEAR = CS_DRUM-ZYEAR
                                                    MATNR = CS_DRUM-MATNR BINARY SEARCH TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CS_DRUM-STATUS = ICON_LED_RED.

    IF LV_MSG_E IS NOT INITIAL.
      LV_MSG_E = |{ LV_MSG_E }, { TEXT-E17 }|. "중복 자재코드
    ELSE.
      LV_MSG_E = TEXT-E17. "중복 자재코드
    ENDIF.
  ENDIF.

*삭제된 자재(MARA)             LVORM = 'X'     오류: 삭제 자재코드
  IF CS_DRUM-LVORM EQ ABAP_TRUE.
    CS_DRUM-STATUS = ICON_LED_RED.

    IF LV_MSG_E IS NOT INITIAL.
      LV_MSG_E = |{ LV_MSG_E }, { TEXT-E18 }|. "삭제 자재코드
    ELSE.
      LV_MSG_E = TEXT-E18. "삭제 자재코드
    ENDIF.
  ENDIF.

*관리 레벨 누락             DRM_LV = NULL     오류: 관리 레벨 누락
  IF CS_DRUM-DRM_LV IS INITIAL.
    CS_DRUM-STATUS = ICON_LED_RED.

    IF LV_MSG_E IS NOT INITIAL.
      LV_MSG_E = |{ LV_MSG_E }, { TEXT-E19 }|. "관리 레벨 누락
    ELSE.
      LV_MSG_E = TEXT-E19. "관리 레벨 누락
    ENDIF.
  ENDIF.

  "오류 메세지 추가
  IF LV_MSG_E IS NOT INITIAL.
    "오류:
    LV_MSG_E = |{ TEXT-E20 } { LV_MSG_E } |.
    LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = LV_MSG_E  ) ).
  ENDIF.

*단가 누락 - 드럼 입고(필수)              DRM_NETPR = NULL      단가 누락: 드럼입고(필수)
  IF CS_DRUM-DRM_NETPR IS INITIAL.
    CS_DRUM-STATUS = ICON_LED_RED.
    IF LV_MSG_N IS NOT INITIAL.
      LV_MSG_N = |{ LV_MSG_N }, { TEXT-E23 }|. ""드럼입고(필수)
    ELSE.
      LV_MSG_N = TEXT-E23. "드럼입고(필수)
    ENDIF.
  ENDIF.

*고드럼에 신드럼 마킹 단가 존재          신드럼마킹 단가 존재   DRM_SG_TYPE = 'G', MARK_NETPR <> NULL     고드럼: 신드럼 마킹 불가
  IF CS_DRUM-DRM_SG_TYPE EQ GC_G AND CS_DRUM-MARK_NETPR IS NOT INITIAL.
    IF CS_DRUM-STATUS EQ ICON_LED_GREEN. CS_DRUM-STATUS = ICON_LED_YELLOW. ENDIF.
    LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = TEXT-E21 ) ) .
  ENDIF.

*신드럼에 고드럼 해체 단가 존재          신드럼 - 고드럼해체   DRM_SG_TYPE = 'S', DIS_NETPR <> NULL      신드럼: 고드럼 마킹 불가
  IF CS_DRUM-DRM_SG_TYPE EQ GC_S AND CS_DRUM-DIS_NETPR IS NOT INITIAL.
    IF CS_DRUM-STATUS EQ ICON_LED_GREEN. CS_DRUM-STATUS = ICON_LED_YELLOW. ENDIF.
    LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = TEXT-E22 ) ) .
  ENDIF.

  IF CS_DRUM-WERKS NE '6600'. "전주는 제외
*골판지 조립   BOARD_NETPR = NULL      단가 누락: 골판지 조립
    IF CS_DRUM-BOARD_NETPR IS INITIAL.
      IF CS_DRUM-STATUS EQ ICON_LED_GREEN. CS_DRUM-STATUS = ICON_LED_YELLOW. ENDIF.
      IF LV_MSG_N IS NOT INITIAL.
        LV_MSG_N = |{ LV_MSG_N }, { TEXT-E08 }|. ""골판지 조립
      ELSE.
        LV_MSG_N = TEXT-E08. "골판지 조립
      ENDIF.
    ENDIF.

*신드럼 마킹   DRM_SG_TYPE = 'S', MARK_NETPR = NULL      단가 누락: 신드럼 마킹
    IF CS_DRUM-DRM_SG_TYPE EQ GC_S AND CS_DRUM-MARK_NETPR IS INITIAL.
      IF CS_DRUM-STATUS EQ ICON_LED_GREEN. CS_DRUM-STATUS = ICON_LED_YELLOW. ENDIF.
      IF LV_MSG_N IS NOT INITIAL.
        LV_MSG_N = |{ LV_MSG_N }, { TEXT-E09 }|. ""신드럼 마킹
      ELSE.
        LV_MSG_N = TEXT-E09. "신드럼 마킹
      ENDIF.
    ENDIF.

*고드럼 해체   DRM_SG_TYPE = 'G', DIS_NETPR = NULL     단가 누락: 고드럼 해체
    IF CS_DRUM-DRM_SG_TYPE EQ GC_G AND CS_DRUM-DIS_NETPR IS INITIAL.
      IF CS_DRUM-STATUS EQ ICON_LED_GREEN. CS_DRUM-STATUS = ICON_LED_YELLOW. ENDIF.
      IF LV_MSG_N IS NOT INITIAL.
        LV_MSG_N = |{ LV_MSG_N }, { TEXT-E10 }|. ""고드럼 해체
      ELSE.
        LV_MSG_N = TEXT-E10. "고드럼 해체
      ENDIF.
    ENDIF.
  ENDIF.

  "오류 메세지 추가
  IF LV_MSG_N IS NOT INITIAL.
    "단가 누락:
    LV_MSG_N = |{ TEXT-E11 } { LV_MSG_N } |.
    LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = LV_MSG_N  ) ).
  ENDIF.

  " <--인포레코드 생산버전 / 생산버전 / BOM 존재여부에 따라 메시지 추가
  IF CS_DRUM-STATUS_SC10 = ICON_LED_GREEN.
    IF CS_DRUM-VERID NE GC_SC10 AND P_DISP EQ ABAP_TRUE.
      LV_MSG_V = |{ TEXT-W03 } { LV_MSG_N } |.
    ENDIF.
  ELSEIF CS_DRUM-STATUS_SC10 = ICON_LED_YELLOW.  "BOM 존재 + 생산버전 미존재
    LV_MSG_V = |{ TEXT-W01 } { LV_MSG_N } |.
  ELSEIF CS_DRUM-STATUS_SC10 = ICON_LED_RED."BOM 미존재
    LV_MSG_V = |{ TEXT-W02 } { LV_MSG_N } |.
  ENDIF.

  IF LV_MSG_V IS NOT INITIAL.
    "생산버전 누락
    LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = LV_MSG_V  ) ).
  ENDIF.
  " -->인포레코드 생산버전 / 생산버전 / BOM 존재여부에 따라 메시지 추가

  "메세지 설정
  LOOP AT LT_MSG ASSIGNING FIELD-SYMBOL(<LS_MSG>).
    IF CS_DRUM-MESSAGE IS NOT INITIAL.
      CS_DRUM-MESSAGE = |{ CS_DRUM-MESSAGE }, { <LS_MSG>-MESSAGE }|.
    ELSE.
      CS_DRUM-MESSAGE = <LS_MSG>-MESSAGE.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_DRUM_LAST_YEAR_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_DRUM_LAST_YEAR_DATA .

  "기존 데이터 점검
  WITH
    +V_MAX AS (
      SELECT
        Z1~BUKRS,
        Z1~EKORG,
        Z1~WERKS,
        Z1~LIFNR,
        Z1~MATNR,
        MAX( Z1~ZYEAR ) AS ZYEAR
        FROM ZGTMMT1042 AS Z1
        WHERE Z1~BUKRS EQ @P_BUKRS
      AND Z1~EKORG EQ @P_EKORG
      AND Z1~WERKS EQ @P_WERKS
      AND Z1~LIFNR EQ @P_LIFNR
      GROUP BY Z1~BUKRS, Z1~EKORG, Z1~WERKS, Z1~LIFNR, Z1~MATNR
    )
  SELECT
    Z1~BUKRS,
    Z1~EKORG,
    Z1~WERKS,
    Z1~LIFNR,
    @P_YEAR AS ZYEAR,
    Z1~MATNR,
    Z1~DRM_TYPE,
    Z1~DRM_SG_TYPE,
    Z1~DRM_LV,
    Z1~WAERS,
    Z1~GDR_NETPR AS DRM_NETPR,
    Z1~BOARD_NETPR,
    Z1~MARK_NETPR,
    Z1~MARK_H_NETPR,
    Z1~DIS_NETPR,
    Z1~PEINH,
    Z1~BPRME,
    Z1~MEINS,
    @ABAP_TRUE AS AUTO
    FROM +V_MAX AS V1
                INNER JOIN
              ZGTMMT1042 AS Z1 ON V1~BUKRS EQ Z1~BUKRS
                                          AND V1~EKORG EQ Z1~EKORG
                                          AND V1~WERKS EQ Z1~WERKS
                                          AND V1~LIFNR EQ Z1~LIFNR
                                          AND V1~MATNR EQ Z1~MATNR
                                          AND V1~ZYEAR EQ Z1~ZYEAR
"<--2026.06.19 삭제 자재 대상 제외
                INNER JOIN
              MARC AS MC ON Z1~WERKS EQ MC~WERKS
                                  AND Z1~MATNR EQ MC~MATNR
   WHERE MC~LVORM EQ @SPACE
"2026.06.19 삭제 자재 대상 제외-->
    INTO CORRESPONDING FIELDS OF TABLE @GT_DRUM.

  LOOP AT GT_DRUM ASSIGNING FIELD-SYMBOL(<LS_DRUM>).
    <LS_DRUM>-ZSTAT = ICON_CREATE.
    <LS_DRUM>-ZNEW = ABAP_TRUE.
    <LS_DRUM>-ZCHG = ABAP_TRUE.


    <LS_DRUM>-ZSTYLE = VALUE #( ( FIELDNAME = 'MATNR' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).

*    <LS_DRUM>-ZSTYLE = VALUE #( ( FIELDNAME = 'LIFNR' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
*                                                ( FIELDNAME = 'ZYEAR' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
*                                                ( FIELDNAME = 'MATNR' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
  ENDLOOP.

  "인포레코드 단가 조회 해야 함..

  "상태 값 설정
  PERFORM F_SET_STATUS_MSG_DRUM CHANGING GT_DRUM.

  "수정 가능
  GV_EDIT = ABAP_TRUE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_DRUM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_DRUM_DATA .

  SELECT
      Z1~BUKRS,
      Z1~EKORG,
      Z1~WERKS,
      Z1~LIFNR,
      Z1~ZYEAR,
      Z1~MATNR,
      Z1~DRM_TYPE,
      Z1~DRM_SG_TYPE,
      Z1~DRM_LV,
      Z1~WAERS,
      Z1~GDR_NETPR AS DRM_NETPR,
      Z1~BOARD_NETPR,
      Z1~MARK_NETPR,
      Z1~MARK_H_NETPR,
      Z1~DIS_NETPR,
      Z1~PEINH,
      Z1~BPRME,
      Z1~MEINS
      FROM ZGTMMT1042 AS Z1
      WHERE Z1~BUKRS EQ @P_BUKRS
      AND Z1~EKORG EQ @P_EKORG
      AND Z1~WERKS EQ @P_WERKS
      AND Z1~LIFNR IN @S_LIFNR
      AND Z1~ZYEAR IN @S_YEAR
      AND Z1~DRM_SG_TYPE IN @S_SG_TYP
      AND Z1~MATNR IN @S_MATNR
      AND EXISTS (
          SELECT V1~MATNR
            FROM ZGTMM_CV_DRUM_STATUS AS V1
            WHERE V1~MATNR EQ Z1~MATNR
                 AND V1~DRM_GUBUN IN @S_GUBUN
                 AND V1~DRM_SIZE IN @S_SIZE
      )
      INTO CORRESPONDING FIELDS OF TABLE @GT_DRUM.

  LOOP AT GT_DRUM ASSIGNING FIELD-SYMBOL(<LS_DRUM>).
    <LS_DRUM>-ZSTYLE = VALUE #( ( FIELDNAME = 'MATNR' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
  ENDLOOP.

  "상태 값 설정
  PERFORM F_SET_STATUS_MSG_DRUM CHANGING GT_DRUM.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CONV_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CONV_200 .

  IF GV_EDIT EQ ABAP_TRUE.
    GV_EDIT = SPACE.
  ELSE.
    GV_EDIT = ABAP_TRUE.
  ENDIF.

  "필드카탈로그 설정
  PERFORM F_ADJ_FCAT_200.

  CALL METHOD GO_GRID_200->SET_FRONTEND_FIELDCATALOG
    EXPORTING
      IT_FIELDCATALOG = GT_FCAT_200.

  CALL METHOD GO_GRID_200->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO_200.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SAVE_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SAVE_200 .

  DATA:
    LV_ANS   TYPE C LENGTH 1,
    LV_CHECK TYPE C LENGTH 1.

  CALL METHOD GO_GRID_200->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  SELECT COUNT( * ) AS CNT
    FROM @GT_DRUM AS ZZ
    WHERE ZZ~ZCHG EQ @ABAP_TRUE
    INTO @DATA(LV_CHG).

  CHECK LV_CHG GT 0. "생성/변경 건이 있는 경우 진행

  "1건이라도 있는 경우
*에러 메시지 출력 후 반영 하지 않음
*TYPE S DISPLAY LIKE E"     오류가 존재하여  저장할 수 없습니다.
  SELECT COUNT( * ) AS CNT
    FROM @GT_DRUM AS ZZ
    WHERE ZZ~STATUS EQ @ICON_LED_RED
    AND ZZ~ZSTAT NE @ICON_DELETE "삭제가 아닌 경우
    INTO @DATA(LV_CNT_R).
  IF LV_CNT_R GT 0.
    MESSAGE E000 WITH TEXT-E12.
  ENDIF.

*POP UP TO CONFIRM 결과에 따라 저장/취소     "경고 메시지가 있습니다.
*저장 하시겠습니까? (예/아니오)"
  SELECT COUNT( * ) AS CNT
    FROM @GT_DRUM AS ZZ
    WHERE ZZ~STATUS EQ @ICON_LED_YELLOW
    INTO @DATA(LV_CNT_W).
  IF LV_CNT_W GT 0.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR      = TEXT-TT4
        TEXT_QUESTION = TEXT-Q01
      IMPORTING
        ANSWER        = LV_ANS.
  ELSE.
*"드럼별 단가를 저장 하시겠습니까? (G-SRM 전송)
*(예/아니오)"
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR      = TEXT-TT4
        TEXT_QUESTION = TEXT-Q03
      IMPORTING
        ANSWER        = LV_ANS.
  ENDIF.
  CHECK LV_ANS EQ GC_1.

*6-2) GSRM에 I/F 전송
  CLEAR LV_CHECK.
  PERFORM F_SEND_GSRM CHANGING LV_CHECK.

*6-3) I/F 전송 성공한 경우 신드럼의 INFO RECORD 생성/수정/삭제 + 존재하는 LINE 전체 MODIFY/DELETE
  CHECK LV_CHECK NE GC_E.
  "하나 씩 실행
  DATA:
    LV_CNT_S TYPE INT4,
    LV_CNT_E TYPE INT4.

  "코드 데이터 조회
  CLEAR GT_CODE[].
  SELECT *
    FROM ZGTPPT1010
    WHERE MODULE_KIND EQ 'MM'
    AND CODEGRP EQ '0730'
    ORDER BY FLD_02, FLD_03
    INTO TABLE @GT_CODE.

  LOOP AT GT_DRUM ASSIGNING FIELD-SYMBOL(<LS_DRUM>).

    CHECK <LS_DRUM>-ZCHG EQ ABAP_TRUE. "변경 된 라인

    CLEAR LV_CHECK.

    "인포레코드 -> 2026.07.01 신/고드럼 분기 추가
    IF <LS_DRUM>-DRM_SG_TYPE EQ GC_S. "신드럼인 경우 인포 생성
      PERFORM F_INFORECORD_MAINTAIN CHANGING <LS_DRUM> LV_CHECK.
    ENDIF.

    IF LV_CHECK NE GC_E. "오류가 없는 경우 진행
      PERFORM F_SAVE_CBO_TABLE_DRUM CHANGING <LS_DRUM>.
      LV_CNT_S += 1.
      IF <LS_DRUM>-ZSTAT EQ ICON_DELETE.
        DELETE GT_DRUM.
        CONTINUE.
      ENDIF.
    ELSE.
      LV_CNT_E += 1.
    ENDIF.
  ENDLOOP.

  "메세지 처리
  "전체 데이터: &1 성공: &2 실패: &3
  DATA(LV_TOT) = LV_CNT_S + LV_CNT_E.
  MESSAGE S073 WITH LV_TOT LV_CNT_S LV_CNT_E.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SEND_GSRM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM F_SEND_GSRM  CHANGING CV_CHECK.


  DATA:
    LV_DEST    TYPE ZDEST,
    LV_RESULT  TYPE ZO_RESULT,
    LV_MESSAGE TYPE ZO_MESSAGE.

  CALL FUNCTION 'ZGTMM_IF_GET_DESTINATION'
    EXPORTING
      I_ZIFNO = GC_MM00028
    IMPORTING
      E_ZDEST = LV_DEST.

  DATA LT_DRUM TYPE STANDARD TABLE OF ZGTMMS9000.
  LT_DRUM = VALUE #( FOR <LS_DRUM> IN GT_DRUM WHERE ( ZCHG EQ ABAP_TRUE )
            ( WERKS = <LS_DRUM>-WERKS
              MATNR = |{ <LS_DRUM>-MATNR ALPHA = OUT }|
              DRM_TYPE = <LS_DRUM>-DRM_TYPE
              DRM_LV = <LS_DRUM>-DRM_LV
              DRM_SG_TYPE = <LS_DRUM>-DRM_SG_TYPE
              MAKTX = <LS_DRUM>-MAKTX
              STATUS = <LS_DRUM>-LVORM ) ).

  CALL FUNCTION 'ZGTMM_IF_O_DRUM_SEND'
    DESTINATION LV_DEST
    EXPORTING
      I_SYSTEM_ID = GC_KSRM
      I_BUKRS     = P_BUKRS
    IMPORTING
      ZO_RESULT   = LV_RESULT
      ZO_MESSAGE  = LV_MESSAGE
    TABLES
      OT_DRUM     = LT_DRUM.

  CASE LV_RESULT.
    WHEN GC_00.
      CLEAR CV_CHECK.
    WHEN OTHERS.
      CV_CHECK = GC_E.
      MESSAGE E000 WITH TEXT-E24. "저장에 실패했습니다.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_INFORECORD_MAINTAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_DRUM>
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM F_INFORECORD_MAINTAIN  CHANGING CS_DRUM TYPE TY_DRUM
                                     CV_CHECK.


*
*"SELECT SINGLE *
*FROM ZGTPPT1010
*WHERE MODULE_KIND = 'MM'
*AND CODEGRP = '0730'
*AND FLD_02 = CV_DRUM-WERKS
*AND FLD_03 = CV_DRUM-DRM_TYPE."
  "코드 값
  DATA LS_CODE TYPE ZGTPPT1010.
  READ TABLE GT_CODE INTO LS_CODE WITH KEY
                                                              FLD_02 = CS_DRUM-WERKS
                                                              FLD_03 = CS_DRUM-DRM_TYPE BINARY SEARCH.


  DATA:
    LS_EINA   TYPE MEWIEINA,
    LS_EINAX  TYPE MEWIEINAX,
    LS_EINE   TYPE MEWIEINE,
    LS_EINEX  TYPE MEWIEINEX,
    LT_COND   TYPE STANDARD TABLE OF MEWICONDITION,
    LT_VALID  TYPE STANDARD TABLE OF MEWIVALIDITY,
    LT_RETURN TYPE MEWI_T_RETURN.

  LS_EINA-MATERIAL = CS_DRUM-MATNR.
  LS_EINA-VENDOR = CS_DRUM-LIFNR.
  IF CS_DRUM-ZSTAT EQ ICON_DELETE.
    LS_EINA-DELETE_IND = ABAP_TRUE.
  ENDIF.

  LS_EINAX-MATERIAL = ABAP_TRUE.
  LS_EINAX-VENDOR = ABAP_TRUE.
  LS_EINAX-DELETE_IND = ABAP_TRUE.

  LS_EINE-PURCH_ORG = CS_DRUM-EKORG.
  LS_EINE-INFO_TYPE = '3'.
  LS_EINE-PLANT = CS_DRUM-WERKS.
  IF CS_DRUM-ZSTAT EQ ICON_DELETE.
    LS_EINE-DELETE_IND = ABAP_TRUE.
  ENDIF.
  LS_EINE-PUR_GROUP = LS_CODE-FLD_04. "'Z32'.
  LS_EINE-CURRENCY = CS_DRUM-WAERS.

  LS_EINE-PLND_DELRY = LS_CODE-FLD_05. "''21'.
  LS_EINE-OVERDELTOL = LS_CODE-FLD_06. "''10'.

*  CASE CS_DRUM-DRM_TYPE.
*    WHEN GC_S.
*      LS_EINE-PLND_DELRY = '21'.
*      LS_EINE-OVERDELTOL = '10'.
*    WHEN GC_D.
*      LS_EINE-PLND_DELRY = '14'.
*      LS_EINE-OVERDELTOL = '30'.
*  ENDCASE.
  LS_EINE-NRM_PO_QTY = '1'.
  LS_EINE-GR_BASEDIV = ABAP_TRUE.
  LS_EINE-TAX_CODE = LS_CODE-FLD_07. "''VA'.
  LS_EINE-VERSION = LS_CODE-FLD_08. "생산 버전


  LS_EINEX-PURCH_ORG = ABAP_TRUE.
  LS_EINEX-INFO_TYPE = ABAP_TRUE.
  LS_EINEX-PLANT = ABAP_TRUE.
  LS_EINEX-DELETE_IND = ABAP_TRUE.
  LS_EINEX-PUR_GROUP = ABAP_TRUE.
  LS_EINEX-CURRENCY = ABAP_TRUE.
  LS_EINEX-PLND_DELRY = ABAP_TRUE.
  LS_EINEX-OVERDELTOL = ABAP_TRUE.
  LS_EINEX-NRM_PO_QTY = ABAP_TRUE.
  LS_EINEX-GR_BASEDIV = ABAP_TRUE.
  LS_EINEX-TAX_CODE = ABAP_TRUE.
  LS_EINEX-VERSION = ABAP_TRUE. "생산 버전

  LT_VALID = VALUE #( ( VALID_FROM = COND #( WHEN CS_DRUM-ZSTAT EQ ICON_DELETE THEN SY-DATUM ELSE |{ CS_DRUM-ZYEAR }0101| )
                                     VALID_TO = '99991231' ) ).

  DATA LV_COND_VALUE TYPE C LENGTH 30.
  WRITE CS_DRUM-DRM_NETPR TO LV_COND_VALUE CURRENCY CS_DRUM-WAERS LEFT-JUSTIFIED NO-GROUPING NO-GAP.
  LT_COND = VALUE #( ( DELETION_IND = COND #( WHEN CS_DRUM-ZSTAT EQ ICON_DELETE THEN ABAP_TRUE ELSE SPACE )
                                     COND_TYPE = 'PB00'
                                     COND_VALUE = LV_COND_VALUE
                                     CURRENCY = CS_DRUM-WAERS
                                     COND_P_UNT = CS_DRUM-PEINH
                                     COND_UNIT = CS_DRUM-BPRME ) ).

  CALL FUNCTION 'ME_INFORECORD_MAINTAIN'
    EXPORTING
      I_EINA        = LS_EINA
      I_EINAX       = LS_EINAX
      I_EINE        = LS_EINE
      I_EINEX       = LS_EINEX
    TABLES
      COND_VALIDITY = LT_VALID
      CONDITION     = LT_COND
      RETURN        = LT_RETURN.

  READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_RETURN>) WITH KEY TYPE = GC_E.
  CHECK SY-SUBRC EQ 0.
  "오류가 있으면 메세지 실정
  CS_DRUM-MESSAGE = <LS_RETURN>-MESSAGE.
  CV_CHECK = GC_E.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SAVE_CBO_TABLE_DRUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_DRUM>
*&---------------------------------------------------------------------*
FORM F_SAVE_CBO_TABLE_DRUM  CHANGING CV_DRUM TYPE TY_DRUM.


  DATA LS_CBO TYPE ZGTMMT1042.

  LS_CBO = CORRESPONDING #( CV_DRUM ). "기본 값 설정
  LS_CBO-AEDAT = SY-DATUM.
  LS_CBO-AEDAT_LOCAL = SY-DATLO.
  LS_CBO-AETIM = SY-UZEIT.
  LS_CBO-AETIM_LOCAL = SY-TIMLO.
  LS_CBO-AENAM = SY-UNAME.

  IF CV_DRUM-DRM_SG_TYPE EQ GC_G.
    LS_CBO-GDR_NETPR = CV_DRUM-DRM_NETPR.
  ENDIF.

  CASE CV_DRUM-ZSTAT.
    WHEN ICON_DELETE.
      DELETE ZGTMMT1042 FROM LS_CBO.
      COMMIT WORK.
      EXIT.
    WHEN OTHERS.
      "기존 데이터 조회
      SELECT SINGLE
         BUKRS,
         EKORG,
         WERKS,
         LIFNR,
         ZYEAR,
         MATNR,
         ERDAT,
         ERDAT_LOCAL,
         ERTIM,
         ERTIM_LOCAL,
         ERNAM
        FROM ZGTMMT1042
        WHERE  BUKRS EQ @CV_DRUM-BUKRS
            AND EKORG EQ @CV_DRUM-EKORG
            AND WERKS EQ @CV_DRUM-WERKS
            AND LIFNR EQ @CV_DRUM-LIFNR
            AND ZYEAR EQ @CV_DRUM-ZYEAR
            AND MATNR EQ @CV_DRUM-MATNR
        INTO @DATA(LS_ORG).
      IF SY-SUBRC EQ 0.
        LS_CBO = CORRESPONDING #( BASE ( LS_CBO ) LS_ORG ).
      ELSE.
        LS_CBO-ERDAT = SY-DATUM.
        LS_CBO-ERDAT_LOCAL = SY-DATLO.
        LS_CBO-ERTIM = SY-UZEIT.
        LS_CBO-ERTIM_LOCAL = SY-TIMLO.
        LS_CBO-ERNAM = SY-UNAME.
      ENDIF.

      MODIFY ZGTMMT1042 FROM LS_CBO.

      COMMIT WORK.

      CV_DRUM-ZSTAT = SPACE.
      CV_DRUM-MESSAGE = SPACE.
      CV_DRUM-ZSTYLE = VALUE #( ( FIELDNAME = 'MATNR' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).

  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GET_NEW_DRUM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_NEW_DRUM_DATA .

  " 목드럼 중 단가 등록되지 않은 건 자동 단가 계산 후 등록 기능 추가

  "기존 데이터 점검
  SELECT
    @P_BUKRS AS BUKRS,
    @P_EKORG AS EKORG,
    MC~WERKS,
    @P_LIFNR AS LIFNR,
    @P_YEAR AS ZYEAR,
    M~MATNR,
    M~MEINS,
    M~MEINS AS BPRME,
    @ABAP_TRUE AS AUTO
    FROM MARA AS M
    INNER JOIN MARC AS MC
                ON M~MATNR EQ MC~MATNR
    INNER JOIN ZGTMM_CV_DRUM_STATUS AS CV
                ON M~MATNR EQ CV~MATNR
WHERE M~MTART EQ @GC_MRM1
    AND MC~WERKS EQ @P_WERKS
    AND CV~MAT_NAME LIKE '%드럼%'  "드럼 대상 조회
    AND CV~DRM_GUBUN IN @S_GUBUN    "조회 조건 추가
    AND CV~DRM_SIZE IN @S_SIZE    "조회 조건 추가
    AND CV~DRM_SG_TYPE IN @S_SG_TYP   "조회 조건 추가
    AND M~MATNR IN @S_MATNR   "조회 조건 추가
    AND MC~LVORM EQ @SPACE "삭제 자재 제외
    AND NOT EXISTS ( SELECT MATNR     "올해 단가 미등록된 건만 조회
                      FROM ZGTMMT1042
                     WHERE BUKRS = @P_BUKRS
                       AND EKORG = @P_EKORG
                       AND WERKS = MC~WERKS
                       AND LIFNR = @P_LIFNR
                       AND ZYEAR = @P_YEAR
                       AND MATNR = M~MATNR )
    INTO CORRESPONDING FIELDS OF TABLE @GT_DRUM.

  " 통화키 세팅
  SELECT SINGLE
    WAERS
    FROM T001
    WHERE BUKRS EQ @P_BUKRS
    INTO @DATA(LV_WAERS).

  LOOP AT GT_DRUM ASSIGNING FIELD-SYMBOL(<LS_DRUM>).
    <LS_DRUM>-ZSTAT = ICON_CREATE.
    <LS_DRUM>-ZNEW = ABAP_TRUE.
    <LS_DRUM>-ZCHG = ABAP_TRUE.


    <LS_DRUM>-ZSTYLE = VALUE #( ( FIELDNAME = 'MATNR' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).

*    <LS_DRUM>-ZSTYLE = VALUE #( ( FIELDNAME = 'LIFNR' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
*                                                ( FIELDNAME = 'ZYEAR' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
*                                                ( FIELDNAME = 'MATNR' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).

    "가격 조건 기본 값 세팅
    <LS_DRUM>-WAERS = LV_WAERS.
    <LS_DRUM>-PEINH = GC_1.

  ENDLOOP.

  "인포레코드 단가 조회 해야 함..

  "상태 값 설정
  PERFORM F_SET_STATUS_MSG_DRUM CHANGING GT_DRUM.

  "수정 가능
  GV_EDIT = ABAP_TRUE.

ENDFORM.
