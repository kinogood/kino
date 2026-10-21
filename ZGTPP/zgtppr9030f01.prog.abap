*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR9010F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& FORM SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN_OUTPUT .

  LOOP AT SCREEN.

*    IF  SCREEN-NAME = '%B002034_BLOCK_1000'. "모니터링조회옵션 블럭제어
*      CASE GC_X.
*        WHEN P_UP. "재고업로드
*          SCREEN-ACTIVE = 1.  "활성
*        WHEN P_DIS. "결과조회
*          SCREEN-ACTIVE = 0.  "비활성
*      ENDCASE.
*    ENDIF.
*
*    IF  SCREEN-NAME = '%B004024_BLOCK_1000'. "요청조회옵션 블럭제어
*      CASE GC_X.
*        WHEN P_UP. "재고업로드
*          SCREEN-ACTIVE = 1.  "활성
*        WHEN P_DIS. "결과조회
*          SCREEN-ACTIVE = 0.  "비활성
*      ENDCASE.
*    ENDIF.

    IF  SCREEN-GROUP1 = 'UP'.
      CASE ABAP_TRUE.
        WHEN P_UP. "재고업로드
          SCREEN-ACTIVE = 1.  "활성
        WHEN P_DIS. "결과조회
          SCREEN-ACTIVE = 0.  "비활성
      ENDCASE.
    ENDIF.

    IF  SCREEN-GROUP1 = 'DIS'.
      CASE ABAP_TRUE.
        WHEN P_UP. "재고업로드
          SCREEN-ACTIVE = 0.  "비활성
        WHEN P_DIS. "결과조회
          SCREEN-ACTIVE = 1.  "활성
      ENDCASE.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM F_F4_FILE
*&---------------------------------------------------------------------*
*& TEXT
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
*& FORM F_START_OF_SELECTION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM F_START_OF_SELECTION .

  IF P_UP = ABAP_TRUE.
    "엑셀 데이터 조회
    DATA LT_XLS TYPE STANDARD TABLE OF TY_XLS.
    PERFORM F_GET_EXCEL_DATA CHANGING LT_XLS.

    "데이터 설정
    PERFORM F_SET_DATA USING LT_XLS.

    "데이터 점검
    PERFORM F_CHECK_DATA.

  ELSEIF P_DIS = ABAP_TRUE.
    "처리결과조회
    PERFORM GET_DATA_RESULT.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_GET_EXCEL_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      <-- LT_XLS
*&---------------------------------------------------------------------*
FORM F_GET_EXCEL_DATA  CHANGING CT_XLS TYPE TY_T_XLS.

  CLEAR CT_XLS[].
  DATA LT_ITAB TYPE STANDARD TABLE OF ALSMEX_TABLINE.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      FILENAME                = P_FILE
      I_BEGIN_COL             = 1
      I_BEGIN_ROW             = 2
      I_END_COL               = 50
      I_END_ROW               = 60000
    TABLES
      INTERN                  = LT_ITAB
    EXCEPTIONS
      INCONSISTENT_PARAMETERS = 1
      UPLOAD_OLE              = 2
      OTHERS                  = 3.

  CHECK SY-SUBRC EQ 0.

  DATA:
    LV_COL_IDX TYPE INT4,
    LS_XLS     TYPE TY_XLS.

  LOOP AT LT_ITAB ASSIGNING FIELD-SYMBOL(<LS_G>) GROUP BY ( ROW = <LS_G>-ROW )
                                                                             ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    "값 설정
    CLEAR LS_XLS.
    LOOP AT GROUP <LS_GROUP> ASSIGNING FIELD-SYMBOL(<LS_XLS>).
      LV_COL_IDX = <LS_XLS>-COL.
      ASSIGN COMPONENT LV_COL_IDX OF STRUCTURE LS_XLS TO FIELD-SYMBOL(<LV_VAL>).
      CHECK <LV_VAL> IS ASSIGNED.
      <LV_VAL> = <LS_XLS>-VALUE.
    ENDLOOP.

    "라인추가
    APPEND LS_XLS TO CT_XLS.
  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_SET_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_XLS
*&---------------------------------------------------------------------*
FORM F_SET_DATA  USING  PT_XLS TYPE TY_T_XLS.

  "초기화
  CLEAR GT_LIST[].

  "데이터 유형 점검 및 설정
  DATA:
    LS_LIST    TYPE TY_LIST,
    LV_AMT_EXT TYPE BAPICURR-BAPICURR,
    LV_AMT_INT TYPE MATDOC-DMBTR.
*
*  "플랜트별 통화키
*  SELECT
*    TW~WERKS,
*    T1~WAERS
*    FROM T001W AS TW
*              INNER JOIN
*            T001K AS TK ON TW~BWKEY EQ TK~BWKEY
*              INNER JOIN
*            T001 AS T1 ON TK~BUKRS EQ T1~BUKRS
*    ORDER BY TW~WERKS
*    INTO TABLE @DATA(LT_WAERS).

  LOOP AT PT_XLS ASSIGNING FIELD-SYMBOL(<LS_XLS>).
    CLEAR LS_LIST.
    "기본 YELLOW 설정
    LS_LIST-STATUS = ICON_YELLOW_LIGHT.

    "대문자 변경
    TRANSLATE:
    <LS_XLS>-MATNR TO UPPER CASE, "자재코드
    <LS_XLS>-SOBKZ TO UPPER CASE, "특별재고지시자
    <LS_XLS>-WERKS TO UPPER CASE, "플랜트
    <LS_XLS>-LGORT TO UPPER CASE. "저장위치

    "날짜 형식(숫자만 남기고 제거)
    ##REGEX_POSIX
    REPLACE ALL OCCURRENCES OF REGEX '[^[:digit:]|.]' IN <LS_XLS>-BLDAT WITH SPACE. "증빙일
    ##REGEX_POSIX
    REPLACE ALL OCCURRENCES OF REGEX '[^[:digit:]|.]' IN <LS_XLS>-BUDAT WITH SPACE. "전기일

    "콤마 제거
    REPLACE ALL OCCURRENCES OF ',' IN <LS_XLS>-ERFMG WITH SPACE. "입력단위수량
*    REPLACE ALL OCCURRENCES OF ',' IN <LS_XLS>-AMT WITH SPACE. "기초재고금액

    "공백 제거
    CONDENSE:
      <LS_XLS>-ERFMG,
      <LS_XLS>-AMT,
      <LS_XLS>-ERFME.

    "수량
    IF <LS_XLS>-ERFMG CN '0123456789.'.
      "ERROR
      PERFORM F_SET_ERR USING 'ERFMG' TEXT-E01 CHANGING LS_LIST. "수량을 확인하세요.
      CLEAR <LS_XLS>-ERFMG.
    ELSE.
      "소숫점이 2개 이상이면 에러
      IF COUNT( VAL = <LS_XLS>-ERFMG SUB = '.' ) GT 1.
        "ERROR
        PERFORM F_SET_ERR USING 'ERFMG' TEXT-E01 CHANGING LS_LIST. "수량을 확인하세요.
        CLEAR <LS_XLS>-ERFMG.
      ENDIF.
    ENDIF.

    "금액
    IF <LS_XLS>-AMT CN '0123456789.,'.
      "ERROR
      PERFORM F_SET_ERR USING 'AMT' TEXT-E02 CHANGING LS_LIST. "기초금액을 확인하세요.
*      CLEAR <LS_XLS>-AMT.
    ELSE.
      IF COUNT( VAL = <LS_XLS>-AMT SUB = '.' ) GT 1.
        "ERROR
        PERFORM F_SET_ERR USING 'AMT' TEXT-E02 CHANGING LS_LIST. "기초금액을 확인하세요.
*        CLEAR <LS_XLS>-AMT.
      ENDIF.
    ENDIF.

    "값 설정
    LS_LIST = CORRESPONDING #( BASE ( LS_LIST )  <LS_XLS> ).

    "ALPHA CONVERSION
    LS_LIST-LIFNR = |{ LS_LIST-LIFNR ALPHA = IN }|.
    LS_LIST-VBELN = |{ LS_LIST-VBELN ALPHA = IN }|.
    LS_LIST-VBELP = |{ LS_LIST-VBELP ALPHA = IN }|.

    LS_LIST-O_LIFNR = |{ LS_LIST-O_LIFNR ALPHA = IN }|.
    LS_LIST-O_VBELN = |{ LS_LIST-O_VBELN ALPHA = IN }|.

    "통화키(KRW고정)
    LS_LIST-WAERS = 'KRW'.

    "단위
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        INPUT  = LS_LIST-ERFME
      IMPORTING
        OUTPUT = LS_LIST-ERFME.
    IF SY-SUBRC NE 0.
      "ERROR
      PERFORM F_SET_ERR USING 'ERFME' TEXT-E03 CHANGING LS_LIST. "단위를 확인하세요.
    ENDIF.

    "자재코드
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT  = LS_LIST-MATNR
      IMPORTING
        OUTPUT = LS_LIST-MATNR.

    "라인추가
    APPEND LS_LIST TO GT_LIST.
  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_SET_ERR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> TEXT_E01
*&      <-- LS_LIST
*&---------------------------------------------------------------------*
FORM F_SET_ERR  USING PV_FIELDNAME
                         PV_MESSAGE
                CHANGING CS_LIST TYPE TY_LIST.

  DATA LS_COLOR TYPE LVC_S_COLO.
  LS_COLOR-COL = 6.
  LS_COLOR-INT = 0.
  LS_COLOR-INV = 0.

  "기존에 해당 필드가 설정 되어 있으면 삭제
  DELETE CS_LIST-ZCOLOR WHERE FNAME = PV_FIELDNAME.

  CS_LIST-STATUS = ICON_RED_LIGHT.

  IF PV_MESSAGE IS NOT INITIAL.
    IF CS_LIST-MESSAGE IS NOT INITIAL.
      CS_LIST-MESSAGE = CS_LIST-MESSAGE && ` `.
    ENDIF.
    CS_LIST-MESSAGE = CS_LIST-MESSAGE && PV_MESSAGE.
  ENDIF.
  CS_LIST-ZCOLOR = VALUE #( BASE CS_LIST-ZCOLOR ( FNAME = PV_FIELDNAME COLOR = LS_COLOR ) ).

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_CHECK_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM F_CHECK_DATA .
*2) 조회 된 데이터 기준으로 데이터 유효성 점검 (ZMMC10050 점검 로직 참조)
*	* 판매오더 정보 체크 추가
*TABLE : VBAP 기준 VBELN, VBELP 존재 유무 점검
*점검 메시지 변경 적용
*
*조건                 메시지
*수량 체크                  수량을 확인하세요.
*자재코드 체크                  "존재하지 않는 자재코드 입니다.
*                                     삭제된 자재코드 입니다. "
*플랜트 종속 체크                  플랜트를 확인하세요.
*회계뷰 체크                 회계뷰 정보를 확인하세요.
*입력단위 체크                  단위를 확인하세요.
*기초금액 체크                  기초금액을 확인하세요.
*업체코드 체크                  업체코드를 확인하세요.
*저장위치 체크                  저장위치를 확인하세요.
*구매정보레코드 체크                 구매정보레코드를 확인하세요.
*판매오더 정보 체크                 판매오더 정보를 확인하세요.

  "자재코드
  ##ITAB_KEY_IN_SELECT
  SELECT
    MR~MATNR,
    MR~LVORM
    FROM MARA AS MR
    WHERE EXISTS (
      SELECT ZZ~MATNR
        FROM @GT_LIST AS ZZ
        WHERE ZZ~MATNR EQ MR~MATNR
    )
    ORDER BY MR~MATNR
    INTO TABLE @DATA(LT_MARA).

  "자재/플랜트
  ##ITAB_KEY_IN_SELECT
  SELECT
    MC~MATNR,
    MC~WERKS,
    MC~PSTAT,
    MC~DPCBT
    FROM MARC AS MC
    WHERE EXISTS (
      SELECT ZZ~MATNR, ZZ~WERKS
        FROM @GT_LIST AS ZZ
        WHERE ZZ~MATNR EQ MC~MATNR
           AND ZZ~WERKS EQ MC~WERKS
           AND ZZ~MATNR IS NOT INITIAL
           AND ZZ~WERKS IS NOT INITIAL
    )
    AND MC~LVORM EQ @SPACE
    ORDER BY MC~MATNR, MC~WERKS
    INTO TABLE @DATA(LT_MARC).

  "기초금액
  ##ITAB_KEY_IN_SELECT
  SELECT
    MW~MATNR,
    TW~WERKS
    FROM MBEW AS MW
              INNER JOIN
           T001W AS TW ON MW~BWKEY EQ TW~BWKEY
    WHERE EXISTS (
      SELECT ZZ~MATNR, ZZ~WERKS
        FROM @GT_LIST AS ZZ
        WHERE ZZ~MATNR EQ MW~MATNR
           AND ZZ~WERKS EQ TW~WERKS
    )
    AND MW~VPRSV EQ @GC_V
    ORDER BY MW~MATNR, TW~WERKS
    INTO TABLE @DATA(LT_MBEW).

  "업체코드
  ##ITAB_KEY_IN_SELECT
  SELECT
    LF~LIFNR
    FROM LFA1 AS LF
    WHERE EXISTS (
      SELECT ZZ~LIFNR
        FROM @GT_LIST AS ZZ
        WHERE ZZ~LIFNR EQ LF~LIFNR
           AND ZZ~LIFNR IS NOT INITIAL
    )
    ORDER BY LF~LIFNR
    INTO TABLE @DATA(LT_LFA1).

  "저장위치
  ##ITAB_KEY_IN_SELECT
  SELECT
      TL~WERKS,
      TL~LGORT
    FROM T001L AS TL
    WHERE EXISTS (
      SELECT ZZ~WERKS, ZZ~LGORT
        FROM @GT_LIST AS ZZ
        WHERE ZZ~WERKS EQ TL~WERKS
           AND ZZ~LGORT EQ TL~LGORT
    )
    ORDER BY TL~WERKS, TL~LGORT
    INTO TABLE @DATA(LT_T001L).

  "판매오더
  ##ITAB_KEY_IN_SELECT
  SELECT
    VP~VBELN,
    VP~POSNR
    FROM VBAP AS VP
    WHERE EXISTS (
      SELECT ZZ~VBELN, VBELP
        FROM @GT_LIST AS ZZ
        WHERE ZZ~VBELN EQ VP~VBELN
           AND ZZ~VBELP EQ VP~POSNR
           AND ZZ~VBELN IS NOT INITIAL
    )
    ORDER BY VP~VBELN , VP~POSNR
    INTO TABLE @DATA(LT_VBAP).

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
    IF <LS_LIST>-ERFMG LE 0.
      PERFORM F_SET_ERR USING 'ERFMG' TEXT-E01 CHANGING <LS_LIST>. "수량을 확인하세요.
    ENDIF.

    READ TABLE LT_MARA ASSIGNING FIELD-SYMBOL(<LS_MARA>) WITH KEY MATNR = <LS_LIST>-MATNR BINARY SEARCH.
    IF SY-SUBRC NE 0.
      PERFORM F_SET_ERR USING 'MATNR' TEXT-E04 CHANGING <LS_LIST>. "존재하지 않는 자재코드 입니다.
    ELSE.
      IF <LS_MARA>-LVORM IS NOT INITIAL.
        PERFORM F_SET_ERR USING 'MATNR' TEXT-E05 CHANGING <LS_LIST>. "삭제된 자재코드 입니다.
      ELSEIF <LS_LIST>-WERKS IS NOT INITIAL.
        "플랜트 종속
        READ TABLE LT_MARC ASSIGNING FIELD-SYMBOL(<LS_MARC>) WITH KEY MATNR = <LS_LIST>-MATNR WERKS = <LS_LIST>-WERKS BINARY SEARCH.
        IF SY-SUBRC NE 0.
          PERFORM F_SET_ERR USING 'WERKS' TEXT-E06 CHANGING <LS_LIST>. "플랜트를 확인하세요.
        ELSE.
          <LS_LIST>-DPCBT = <LS_MARC>-DPCBT. "배치마스터 생성 대상 여부 확인용.

          IF <LS_MARC>-PSTAT NA GC_B.
*            PERFORM F_SET_ERR USING 'WERKS' TEXT-E07 CHANGING <LS_LIST>. "회계뷰 정보를 확인하세요.
          ELSE.
            "기초금액
            IF <LS_LIST>-AMT IS INITIAL.
              READ TABLE LT_MBEW WITH KEY MATNR = <LS_LIST>-MATNR WERKS = <LS_LIST>-WERKS BINARY SEARCH TRANSPORTING NO FIELDS.
              IF SY-SUBRC EQ 0.
                PERFORM F_SET_ERR USING 'AMT' TEXT-E02 CHANGING <LS_LIST>. "기초금액을 확인하세요.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    "업체코드
    IF <LS_LIST>-LIFNR IS NOT INITIAL.
      READ TABLE LT_LFA1 WITH KEY LIFNR = <LS_LIST>-LIFNR BINARY SEARCH TRANSPORTING NO FIELDS.
      IF SY-SUBRC NE 0.
        PERFORM F_SET_ERR USING 'LIFNR' TEXT-E08 CHANGING <LS_LIST>. "업체코드를 확인하세요.
      ENDIF.
    ENDIF.

    CASE <LS_LIST>-SOBKZ.
      WHEN SPACE. "공백
        "저장위치
        READ TABLE LT_T001L WITH KEY WERKS = <LS_LIST>-WERKS LGORT = <LS_LIST>-LGORT BINARY SEARCH TRANSPORTING NO FIELDS.
        IF SY-SUBRC NE 0.
          PERFORM F_SET_ERR USING 'WERKS' TEXT-E06 CHANGING <LS_LIST>. "플랜트를 확인하세요.
          PERFORM F_SET_ERR USING 'LGORT' TEXT-E09 CHANGING <LS_LIST>. "저장위치를 확인하세요.
        ENDIF.
      WHEN GC_O.
        IF <LS_LIST>-WERKS IS INITIAL.
          PERFORM F_SET_ERR USING 'WERKS' TEXT-E06 CHANGING <LS_LIST>. "플랜트를 확인하세요.
        ENDIF.
      WHEN GC_E.
        IF <LS_LIST>-VBELN IS INITIAL OR <LS_LIST>-VBELP IS INITIAL.
          PERFORM F_SET_ERR USING 'VBELN' TEXT-E10 CHANGING <LS_LIST>. "판매오더 정보를 확인하세요.
          PERFORM F_SET_ERR USING 'VBELP' SPACE CHANGING <LS_LIST>.
        ELSE.
          "판매오더
          READ TABLE LT_VBAP WITH KEY VBELN = <LS_LIST>-VBELN POSNR = <LS_LIST>-VBELP BINARY SEARCH TRANSPORTING NO FIELDS.
          IF SY-SUBRC NE 0.
            PERFORM F_SET_ERR USING 'VBELN' TEXT-E10 CHANGING <LS_LIST>. "판매오더 정보를 확인하세요.
            PERFORM F_SET_ERR USING 'VBELP' SPACE CHANGING <LS_LIST>.
          ENDIF.
        ENDIF.

        "저장위치
        READ TABLE LT_T001L WITH KEY WERKS = <LS_LIST>-WERKS LGORT = <LS_LIST>-LGORT BINARY SEARCH TRANSPORTING NO FIELDS.
        IF SY-SUBRC NE 0.
          PERFORM F_SET_ERR USING 'WERKS' TEXT-E06 CHANGING <LS_LIST>. "플랜트를 확인하세요.
          PERFORM F_SET_ERR USING 'LGORT' TEXT-E09 CHANGING <LS_LIST>. "저장위치를 확인하세요.
        ENDIF.

    ENDCASE.

  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_END_OF_SELECTION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM F_END_OF_SELECTION .

  "데이터가 없으면 메세지 처리
  IF GT_LIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE GC_E.
    LEAVE LIST-PROCESSING.
  ENDIF.

  "SCREEN 100 이동
  CALL SCREEN 100.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM F_UPLOAD
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM F_UPLOAD .

  DATA:
    LV_ANS      TYPE C LENGTH 1,
    LV_QUESTION TYPE STRING.

  IF P_TEST EQ SPACE.
    LV_QUESTION = TEXT-Q01. "기초 재고 업로드 하시겠습니까?
  ELSE.
    LV_QUESTION = TEXT-Q02. "기초 재고 업로드 테스트 하시겠습니까?
  ENDIF.

*POP-UP 확인 후 처리
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT1
      TEXT_QUESTION = LV_QUESTION
    IMPORTING
      ANSWER        = LV_ANS.

  CHECK LV_ANS EQ GC_1.

  DATA:
    LT_9070 TYPE STANDARD TABLE OF ZGTPPT9070,
    LT_0001 TYPE STANDARD TABLE OF ZPPT0001.

  DATA:
    LV_AMT_C  TYPE STRING,
    LS_HEADER TYPE BAPI2017_GM_HEAD_01,
    LS_CODE   TYPE BAPI2017_GM_CODE,
    LS_ITEM   TYPE BAPI2017_GM_ITEM_CREATE,
    LT_ITEM   TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
    LT_RETURN TYPE STANDARD TABLE OF BAPIRET2,
    LS_HDRET  TYPE BAPI2017_GM_HEAD_RET,
    LS_ATTR   TYPE BAPIBATCHATT,
    LS_CTRL   TYPE BAPIBATCHCTRL.

  FIELD-SYMBOLS:
    <LS_LIST>   TYPE TY_LIST,
    <LS_RETURN> TYPE BAPIRET2.

*1-2) BAPI_GOODSMVT_CREATE 실행
*	: 자재 문서 생성 기준
* 조건                  VALUE
* SOBKZ = ""                  WERKS 기준 SORTING, '하나의 자재문서 품목 레벨로 생성
* SOBKZ = "O"                 LIFNR 기준 SORTING, 동일한 LIFNR 기준으로 문서 생성
* SOBKZ = "E"                 VBELN, VBELP 기준 SORTING, 하나의 자재문서 품목 레벨로 생성
*->PP는 라인별 자재문서 생성.->선택 대상만 처리되도록..

*선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  DATA LT_ROW TYPE LVC_T_ROID.
  CALL METHOD GO_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW.

  DELETE LT_ROW WHERE ROW_ID LE 0.
  IF LT_ROW[] IS INITIAL.
    MESSAGE E050.
  ENDIF.

*  LOOP AT GT_LIST ASSIGNING <LS_LIST>.
  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).

    READ TABLE GT_LIST ASSIGNING <LS_LIST> INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

*선택한 라인의 상태 <> "YELLOW" 인 경우만 생성가능.
    IF  ( <LS_LIST>-STATUS = ICON_GREEN_LIGHT OR
           <LS_LIST>-STATUS = ICON_LED_GREEN ).
      <LS_LIST>-MESSAGE = TEXT-E15.
      CONTINUE.
    ENDIF.

*    IF <LS_LIST>-STATUS <> ICON_YELLOW_LIGHT.
*      <LS_LIST>-MESSAGE = TEXT-E15.
*      CONTINUE.
*    ENDIF.

    CLEAR LT_RETURN.
*2)DPCBT = 'A'인 경우, 배치 마스터 선 생성_실패시, 재고전기 미수행(오류처리)
*2-1)배치번호 존재여부 점검
*MARC-DPCBT = 'A'.인 경우 배치 마스터 생성 대상+배치 미존재 자재만.
    IF <LS_LIST>-DPCBT = 'A'.
      SELECT SINGLE CHARG
        FROM MCHA
        WHERE MATNR = @<LS_LIST>-MATNR
        AND WERKS = @<LS_LIST>-WERKS
        AND CHARG = @<LS_LIST>-CHARG
        INTO @DATA(LV_CHARG).
*2-2) 배치번호 존재하지 않는 경우에만 배치마스터 생성 수행.
      IF SY-SUBRC <> 0 .
        CLEAR : LS_ATTR, LS_CTRL.
        LS_ATTR-STATUSKEY = GC_1. "'1'
        LS_CTRL-DOCLASSIFY = ABAP_TRUE.
*
        CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
          EXPORTING
            MATERIAL           = <LS_LIST>-MATNR
            PLANT              = <LS_LIST>-WERKS
            CLASSTYPE          = '023'
          IMPORTING
            CLASS              = LS_CTRL-CLASS_NUM
          EXCEPTIONS
            NO_CLASS_FOUND     = 1
            NO_CLASSTYPE_FOUND = 2
            OTHERS             = 3.

        IF SY-SUBRC <> 0.
*          CHECK <LS_LIST>-STATUS EQ ICON_YELLOW_LIGHT.
          <LS_LIST>-MESSAGE = TEXT-E14. "배치 마스터 생성 실패(자재문서 미생성)
          CHECK P_TEST EQ SPACE. "테스트 실행이 아닌 경우만
          <LS_LIST>-STATUS = ICON_RED_LIGHT.

          CONTINUE. "실패시, 아래 기초재고전기 미수행.
        ENDIF.

**배치마스터 생성
        DATA(LV_MATNR) = CONV MATNR18( <LS_LIST>-MATNR ).

        CALL FUNCTION 'BAPI_BATCH_CREATE'
          EXPORTING
            MATERIAL           = LV_MATNR "<LS_LIST>-MATNR
            BATCH              = <LS_LIST>-CHARG
            PLANT              = <LS_LIST>-WERKS
            BATCHATTRIBUTES    = LS_ATTR
            BATCHCONTROLFIELDS = LS_CTRL
          TABLES
            RETURN             = LT_RETURN.

        READ TABLE LT_RETURN ASSIGNING <LS_RETURN> WITH KEY TYPE = GC_E.
        IF SY-SUBRC EQ 0.
          "오류
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*          CHECK <LS_LIST>-STATUS EQ ICON_YELLOW_LIGHT.
          <LS_LIST>-MESSAGE = TEXT-E14. "배치 마스터 생성 실패(자재문서 미생성)
          CHECK P_TEST EQ SPACE. "테스트 실행이 아닌 경우만
          <LS_LIST>-STATUS = ICON_RED_LIGHT.

          CONTINUE. "실패시, 아래 기초재고전기 미수행.
        ELSE.
          "성공
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              WAIT = ABAP_TRUE.
        ENDIF.
      ENDIF.
    ENDIF.

    CLEAR LV_CHARG.

    "초기화
    CLEAR:
      LS_HEADER,
      LT_ITEM[],
      LT_RETURN[],
      LS_HDRET.

*GM CODE
    LS_CODE-GM_CODE = GC_05. "MB1C

    "HEADER
    LS_HEADER-PSTNG_DATE = <LS_LIST>-BUDAT.
    LS_HEADER-DOC_DATE = <LS_LIST>-BLDAT.
    LS_HEADER-PR_UNAME = SY-UNAME.
    LS_HEADER-HEADER_TXT  = TEXT-HD1. "기초재고 마이그레이션

*    CHECK <LS_LIST>-STATUS EQ ICON_YELLOW_LIGHT.
    "ITEM
    CLEAR LS_ITEM.
    LS_ITEM-MOVE_TYPE = GC_561.
    LS_ITEM-MATERIAL = <LS_LIST>-MATNR.
    LS_ITEM-BATCH = <LS_LIST>-CHARG.
    LS_ITEM-PLANT = <LS_LIST>-WERKS.
    LS_ITEM-STGE_LOC = <LS_LIST>-LGORT.
    LS_ITEM-SPEC_STOCK = <LS_LIST>-SOBKZ.
    LS_ITEM-ENTRY_QNT = <LS_LIST>-ERFMG.
    LS_ITEM-ENTRY_UOM = <LS_LIST>-ERFME.
    LS_ITEM-VENDOR = <LS_LIST>-LIFNR.
    LV_AMT_C = <LS_LIST>-AMT.
    ##REGEX_POSIX
    REPLACE ALL OCCURRENCES OF REGEX '[^[:digit:]|.]' IN LV_AMT_C WITH SPACE.
    LS_ITEM-AMOUNT_LC = LV_AMT_C.
    LS_ITEM-VAL_SALES_ORD = <LS_LIST>-VBELN.
    LS_ITEM-VAL_S_ORD_ITEM = <LS_LIST>-VBELP.
    APPEND LS_ITEM TO LT_ITEM.

    CHECK LT_ITEM[] IS NOT INITIAL.
    CLEAR LT_RETURN.

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = LS_HEADER
        GOODSMVT_CODE    = LS_CODE
        TESTRUN          = P_TEST
      IMPORTING
        GOODSMVT_HEADRET = LS_HDRET
      TABLES
        GOODSMVT_ITEM    = LT_ITEM
        RETURN           = LT_RETURN.

    READ TABLE LT_RETURN ASSIGNING <LS_RETURN> WITH KEY TYPE = GC_E.
    IF SY-SUBRC EQ 0.
      "오류
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*      CHECK <LS_LIST>-STATUS EQ ICON_YELLOW_LIGHT.
      <LS_LIST>-MESSAGE = <LS_RETURN>-MESSAGE.

      CHECK P_TEST EQ SPACE. "테스트 실행이 아닌 경우만
      <LS_LIST>-STATUS = ICON_RED_LIGHT.

    ELSE.
      "성공
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.

*      CHECK <LS_LIST>-STATUS EQ ICON_YELLOW_LIGHT.
      <LS_LIST>-MESSAGE = SPACE.

      CHECK P_TEST EQ SPACE. "테스트 실행이 아닌 경우만
      <LS_LIST>-MBLNR = LS_HDRET-MAT_DOC.
      <LS_LIST>-STATUS = ICON_GREEN_LIGHT.

*2-1)(ITAB-TAGNR 필드값이 존재하는 레코드에 한하여) 꼬리표 테이블(TABLE: ZPPT0001)업데이트
      IF <LS_LIST>-TAGNR IS NOT INITIAL.
        LT_0001[] = VALUE #( BASE LT_0001
                          ( VALUE #( BASE CORRESPONDING #( <LS_LIST> )
                                       MBLNR = LS_HDRET-MAT_DOC
                                       MGVRG = <LS_LIST>-O_LENGTH
                                       FOSTCNT = <LS_LIST>-O_COUNT
                                       REMAIN = <LS_LIST>-ERFMG
                                       MEINS   = <LS_LIST>-ERFME
                                       GIFLG    = GC_N
                                       GRFLG   = GC_Y
                                       INSPFLG = GC_OK
                                       WKDAT = SY-DATUM
                                       WKINDAT = SY-DATUM
                                       WKINTIM = SY-UZEIT
                                       WKINNAM = SY-UNAME
                                       GRINDAT = SY-DATUM
                                       GRINTIM  = SY-UZEIT
                                       GRINNAM = SY-UNAME
                                       BKTXT = GC_MIG ) ) ). "마이그레이션 지시자
      ENDIF.
*2-2) 기초재고 업로드 결과를 TABLE: ZGTPPT9070에 저장함->SET
      LT_9070[] = VALUE #( BASE LT_9070
                                ( VALUE #( BASE CORRESPONDING #( <LS_LIST> )
                                       MBLNR = LS_HDRET-MAT_DOC
                                       MJAHR = LS_HDRET-DOC_YEAR
                                       LOEKZ = SPACE
                                       CRDAT = SY-DATUM
                                       CRTIM = SY-UZEIT
                                       CRNAM = SY-UNAME ) ) ).
    ENDIF.
  ENDLOOP.

*꼬리표테이블&재고이전테이블 업데이트
  IF LT_0001[] IS NOT INITIAL.
    MODIFY ZPPT0001 FROM TABLE LT_0001.
    IF SY-SUBRC = 0.
      COMMIT WORK.
    ENDIF.
  ENDIF.

  IF LT_9070[] IS NOT INITIAL.
    MODIFY ZGTPPT9070 FROM TABLE LT_9070.
    IF SY-SUBRC = 0.
      COMMIT WORK.
    ENDIF.
  ENDIF.

  IF P_TEST EQ ABAP_TRUE.
    MESSAGE S000 WITH TEXT-M01. "테스트 실행 성공
  ELSE.
    MESSAGE S000 WITH TEXT-M02. "기초 재고 업로드 완료
  ENDIF.

*  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_G1>) GROUP BY ( SOBKZ = <LS_G1>-SOBKZ )
*                                                                              ASSIGNING FIELD-SYMBOL(<LS_GROUP1>).
*
*    "증빙/전기일별 실행
*    LOOP AT GROUP <LS_GROUP1> ASSIGNING FIELD-SYMBOL(<LS_G2>) GROUP BY ( BLDAT = <LS_G2>-BLDAT
*                                                                                                                        BUDAT = <LS_G2>-BUDAT )
*                                                                                                      ASSIGNING FIELD-SYMBOL(<LS_GROUP2>).
*
*
*      "초기화
*      CLEAR:
*        LS_CODE,
*        LS_HEADER,
*        LT_ITEM[],
*        LT_RETURN[],
*        LS_HDRET.
*
*      LS_CODE-GM_CODE = GC_05. "MB1C
*
*      LS_HEADER-PSTNG_DATE = <LS_GROUP2>-BUDAT.
*      LS_HEADER-DOC_DATE = <LS_GROUP2>-BLDAT.
*      LS_HEADER-PR_UNAME = SY-UNAME.
*      LS_HEADER-HEADER_TXT  = TEXT-HD1. "기초재고 마이그레이션
*
*
*      CASE <LS_GROUP1>-SOBKZ.
*        WHEN GC_O.
**SOBKZ = "O"                  LIFNR 기준 SORTING, 동일한 LIFNR 기준으로 문서 생성
*          LOOP AT GROUP <LS_GROUP2> ASSIGNING FIELD-SYMBOL(<LS_G_O>) GROUP BY ( LIFNR = <LS_G_O>-LIFNR ) ASCENDING
*                                                                                                        ASSIGNING FIELD-SYMBOL(<LS_GROUP_O>).
*
*            CLEAR:
*              LT_ITEM[],
*              LT_RETURN[],
*              LS_HDRET.
*
*            LOOP AT GROUP <LS_GROUP_O> ASSIGNING <LS_LIST>.
*              CHECK <LS_LIST>-STATUS EQ ICON_YELLOW_LIGHT.
*              CLEAR LS_ITEM.
*              LS_ITEM-MOVE_TYPE = GC_561.
*              LS_ITEM-MATERIAL = <LS_LIST>-MATNR.
*              LS_ITEM-BATCH = <LS_LIST>-CHARG.
*              LS_ITEM-PLANT = <LS_LIST>-WERKS.
*              LS_ITEM-STGE_LOC = <LS_LIST>-LGORT.
*              LS_ITEM-SPEC_STOCK = <LS_LIST>-SOBKZ.
*              LS_ITEM-ENTRY_QNT = <LS_LIST>-ERFMG.
*              LS_ITEM-ENTRY_UOM = <LS_LIST>-ERFME.
*              LS_ITEM-VENDOR = <LS_LIST>-LIFNR.
*              LV_AMT_C = <LS_LIST>-AMT.
*##REGEX_POSIX
*              REPLACE ALL OCCURRENCES OF REGEX '[^[:DIGIT:]|.]' IN LV_AMT_C WITH SPACE.
*              LS_ITEM-AMOUNT_LC = LV_AMT_C.
*              LS_ITEM-VAL_SALES_ORD = <LS_LIST>-VBELN.
*              LS_ITEM-VAL_S_ORD_ITEM = <LS_LIST>-VBELP.
*              APPEND LS_ITEM TO LT_ITEM.
*            ENDLOOP.
*
*            CHECK LT_ITEM[] IS NOT INITIAL.
*            CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
*              EXPORTING
*                GOODSMVT_HEADER  = LS_HEADER
*                GOODSMVT_CODE    = LS_CODE
*                TESTRUN          = P_TEST
*              IMPORTING
*                GOODSMVT_HEADRET = LS_HDRET
*              TABLES
*                GOODSMVT_ITEM    = LT_ITEM
*                RETURN           = LT_RETURN.
*
*            READ TABLE LT_RETURN ASSIGNING <LS_RETURN> WITH KEY TYPE = GC_E.
*            IF SY-SUBRC EQ 0.
*              "오류
*              CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*
*              LOOP AT GROUP <LS_GROUP_O> ASSIGNING <LS_LIST>.
*                CHECK <LS_LIST>-STATUS EQ ICON_YELLOW_LIGHT.
*                <LS_LIST>-MESSAGE = <LS_RETURN>-MESSAGE.
*                CHECK P_TEST EQ SPACE. "테스트 실행이 아닌 경우만
*                <LS_LIST>-STATUS = ICON_RED_LIGHT.
*              ENDLOOP.
*
*            ELSE.
*              "성공
*              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*                EXPORTING
*                  WAIT = ABAP_TRUE.
*
*              LOOP AT GROUP <LS_GROUP_O> ASSIGNING <LS_LIST>.
*                CHECK <LS_LIST>-STATUS EQ ICON_YELLOW_LIGHT.
*                <LS_LIST>-MESSAGE = SPACE.
*                CHECK P_TEST EQ SPACE. "테스트 실행이 아닌 경우만
*                <LS_LIST>-MBLNR = LS_HDRET-MAT_DOC.
*                <LS_LIST>-STATUS = ICON_GREEN_LIGHT.
*
**2-1)(ITAB-TAGNR 필드값이 존재하는 레코드에 한하여) 꼬리표 테이블(TABLE: ZPPT0001)업데이트
*                IF <LS_LIST>-TAGNR IS NOT INITIAL.
*                  LT_0001[] = VALUE #( BASE LT_0001
*                                 ( VALUE #( BASE CORRESPONDING #( <LS_LIST> )
*                                       MBLNR = LS_HDRET-MAT_DOC
*                                       MGVRG = <LS_LIST>-O_LENGTH
*                                       FOSTCNT = <LS_LIST>-O_COUNT
*                                       REMAIN = <LS_LIST>-ERFMG
*                                       MEINS   = <LS_LIST>-ERFME
*                                       GIFLG    = GC_N
*                                       GRFLG   = GC_Y
*                                       INSPFLG = GC_OK
*                                       WKDAT = SY-DATUM
*                                       WKINDAT = SY-DATUM
*                                       WKINTIM = SY-UZEIT
*                                       WKINNAM = SY-UNAME
*                                       GRINDAT = SY-DATUM
*                                       GRINTIM  = SY-UZEIT
*                                       GRINNAM = SY-UNAME
*                                       BKTXT = GC_MIG ) ) ). "마이그레이션 지시자
*                ENDIF.
**2-2) 기초재고 업로드 결과를 TABLE: ZGTPPT9070에 저장함->SET
*                LT_9070[] = VALUE #( BASE LT_9070
*                                ( VALUE #( BASE CORRESPONDING #( <LS_LIST> )
*                                       MBLNR = LS_HDRET-MAT_DOC
*                                       MJAHR = LS_HDRET-DOC_YEAR
*                                       LOEKZ = SPACE
*                                       CRDAT = SY-DATUM
*                                       CRTIM = SY-UZEIT
*                                       CRNAM = SY-UNAME ) ) ).
*
*              ENDLOOP.
*
*            ENDIF.
*          ENDLOOP.
*
*        WHEN OTHERS.
**SOBKZ = ""                 WERKS 기준 SORTING, '하나의 자재문서 품목 레벨로 생성
**SOBKZ = "E"                  VBELN, VBELP 기준 SORTING, 하나의 자재문서 품목 레벨로 생성
*          CLEAR:
*            LT_ITEM[],
*            LT_RETURN[],
*            LS_HDRET.
*
*          LOOP AT GROUP <LS_GROUP2> ASSIGNING <LS_LIST>.
*            CHECK <LS_LIST>-STATUS EQ ICON_YELLOW_LIGHT.
*            CLEAR LS_ITEM.
*            LS_ITEM-MOVE_TYPE = GC_561.
*            LS_ITEM-MATERIAL = <LS_LIST>-MATNR.
*            LS_ITEM-BATCH = <LS_LIST>-CHARG.
*            LS_ITEM-PLANT = <LS_LIST>-WERKS.
*            LS_ITEM-STGE_LOC = <LS_LIST>-LGORT.
*            LS_ITEM-SPEC_STOCK = <LS_LIST>-SOBKZ.
*            LS_ITEM-ENTRY_QNT = <LS_LIST>-ERFMG.
*            LS_ITEM-ENTRY_UOM = <LS_LIST>-ERFME.
*            LS_ITEM-VENDOR = <LS_LIST>-LIFNR.
*            LV_AMT_C = <LS_LIST>-AMT.
*##REGEX_POSIX
*            REPLACE ALL OCCURRENCES OF REGEX '[^[:DIGIT:]|.]' IN LV_AMT_C WITH SPACE.
*            LS_ITEM-AMOUNT_LC = LV_AMT_C.
*            LS_ITEM-VAL_SALES_ORD = <LS_LIST>-VBELN.
*            LS_ITEM-VAL_S_ORD_ITEM = <LS_LIST>-VBELP.
*            APPEND LS_ITEM TO LT_ITEM.
*          ENDLOOP.
*
*          CHECK LT_ITEM[] IS NOT INITIAL.
*
*          CASE <LS_GROUP1>-SOBKZ.
*            WHEN GC_E.
*              SORT LT_ITEM BY SALES_ORD S_ORD_ITEM STGE_LOC.
*            WHEN OTHERS.
*              SORT LT_ITEM BY PLANT MATERIAL .
*          ENDCASE.
*
*          CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
*            EXPORTING
*              GOODSMVT_HEADER  = LS_HEADER
*              GOODSMVT_CODE    = LS_CODE
*              TESTRUN          = P_TEST
*            IMPORTING
*              GOODSMVT_HEADRET = LS_HDRET
*            TABLES
*              GOODSMVT_ITEM    = LT_ITEM
*              RETURN           = LT_RETURN.
*
*          READ TABLE LT_RETURN ASSIGNING <LS_RETURN> WITH KEY TYPE = GC_E.
*          IF SY-SUBRC EQ 0.
*            "오류
*            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*
*            LOOP AT GROUP <LS_GROUP2> ASSIGNING <LS_LIST>.
*              CHECK <LS_LIST>-STATUS EQ ICON_YELLOW_LIGHT.
*              <LS_LIST>-MESSAGE = <LS_RETURN>-MESSAGE.
*              CHECK P_TEST EQ SPACE. "테스트 실행이 아닌 경우만
*              <LS_LIST>-STATUS = ICON_RED_LIGHT.
*            ENDLOOP.
*
*          ELSE.
*            "성공
*            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*              EXPORTING
*                WAIT = ABAP_TRUE.
*
*            LOOP AT GROUP <LS_GROUP2> ASSIGNING <LS_LIST>.
*              CHECK <LS_LIST>-STATUS EQ ICON_YELLOW_LIGHT.
*              <LS_LIST>-MESSAGE = SPACE.
*              CHECK P_TEST EQ SPACE. "테스트 실행이 아닌 경우만
*              <LS_LIST>-MBLNR = LS_HDRET-MAT_DOC.
*              <LS_LIST>-STATUS = ICON_GREEN_LIGHT.
*
**2-1)(ITAB-TAGNR 필드값이 존재하는 레코드에 한하여) 꼬리표 테이블(TABLE: ZPPT0001)업데이트
*              IF <LS_LIST>-TAGNR IS NOT INITIAL.
*                LT_0001[] = VALUE #( BASE LT_0001
*                                 ( VALUE #( BASE CORRESPONDING #( <LS_LIST> )
*                                       MBLNR = LS_HDRET-MAT_DOC
*                                       MGVRG = <LS_LIST>-O_LENGTH
*                                       FOSTCNT = <LS_LIST>-O_COUNT
*                                       REMAIN = <LS_LIST>-ERFMG
*                                       MEINS   = <LS_LIST>-ERFME
*                                       GIFLG    = GC_N
*                                       GRFLG   = GC_Y
*                                       INSPFLG = GC_OK
*                                       WKDAT = SY-DATUM
*                                       WKINDAT = SY-DATUM
*                                       WKINTIM = SY-UZEIT
*                                       WKINNAM = SY-UNAME
*                                       GRINDAT = SY-DATUM
*                                       GRINTIM  = SY-UZEIT
*                                       GRINNAM = SY-UNAME
*                                       BKTXT = GC_MIG ) ) ). "마이그레이션 지시자
*              ENDIF.
**2-2) 기초재고 업로드 결과를 TABLE: ZGTPPT9070에 저장함->SET
*              LT_9070[] = VALUE #( BASE LT_9070
*                                ( VALUE #( BASE CORRESPONDING #( <LS_LIST> )
*                                       MBLNR = LS_HDRET-MAT_DOC
*                                       MJAHR = LS_HDRET-DOC_YEAR
*                                       LOEKZ = SPACE
*                                       CRDAT = SY-DATUM
*                                       CRTIM = SY-UZEIT
*                                       CRNAM = SY-UNAME ) ) ).
*            ENDLOOP.
*
*          ENDIF.
*
*      ENDCASE.
*
*    ENDLOOP.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_DATA_RESULT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM GET_DATA_RESULT .
*3) "결과 조회" 모드 시 하기의 로직으로 데이터 추출 후 ALV 화면에 출력

  SELECT FROM ZGTPPT9070
    FIELDS *
    WHERE MBLNR IN @S_MBLNR
        AND BLDAT IN @S_BLDAT
        AND BUDAT IN @S_BUDAT
        AND SOBKZ IN @S_SOBKZ
        AND LIFNR IN @S_LIFNR
        AND WERKS IN @S_WERKS
        AND LGORT IN @S_LGORT
        AND MATNR IN @S_MATNR
        AND CHARG IN @S_CHARG
        AND VBELN IN @S_VBELN
        AND VBELP IN @S_VBELP
        AND TAGNR IN @S_TAGNR
        AND CRDAT IN @S_CRDAT
        AND CRNAM IN @S_CRNAM
        AND O_WERKS IN @SO_WERKS
        AND O_KUNNR IN @SO_KUNNR
        AND O_LIFNR IN @SO_LIFNR
        AND O_VBELN IN @SO_VBELN
        AND O_MATNR IN @SO_MATNR
        AND O_MAKTX IN @SO_MAKTX
        AND O_SPEC IN @SO_SPEC
        AND O_SPECID IN @SO_SCID
        AND O_COLOR IN @SO_COLOR
        AND O_SUL_NO IN @SO_SULNO
        AND O_LGORT IN @SO_LGORT
        AND O_OP_SEQ IN @SO_OPSEQ
        AND O_OP_CODE IN @SO_OPCD
        AND O_CHARG IN @SO_CHARG
        AND O_OP_SEQ_LAST IN @SO_LAST
        AND LOEKZ IS INITIAL
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

  SORT GT_LIST BY MBLNR MJAHR.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM F_REVERSAL_DOC
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM F_REVERSAL_DOC .

*4. 자재문서취소 버튼 선택
*4-1) 동일한 자재문서 단위로 선택 가능
*4-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
*4-3) 선택한 라인의 상태 <> "GREEN" 인 경우 자재문서 취소 로직을 수행함

*  DATA LV_VALID TYPE C LENGTH 1.
*  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
*    IMPORTING
*      E_VALID = LV_VALID.
*  CHECK LV_VALID EQ ABAP_TRUE.

*4-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  DATA LT_ROW TYPE LVC_T_ROID.
  CALL METHOD GO_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW.

  DELETE LT_ROW WHERE ROW_ID LE 0.
  IF LT_ROW[] IS INITIAL.
    MESSAGE E050.
  ENDIF.

  DATA:
    BEGIN OF LS_RUN,
      TABIX TYPE SY-TABIX,
      MJAHR TYPE MATDOC-MJAHR,
      MBLNR TYPE MATDOC-MBLNR,
      BUDAT TYPE MATDOC-BUDAT,
    END OF LS_RUN,
    LT_RUN LIKE STANDARD TABLE OF LS_RUN.
  DATA:
    LV_ANS      TYPE C LENGTH 1.

  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    IF <LS_LIST>-MBLNR IS INITIAL.
      <LS_LIST>-MESSAGE = TEXT-E12.
      CONTINUE.
    ENDIF.

    "실행 대상
    CLEAR LS_RUN.
    LS_RUN-MJAHR = <LS_LIST>-BUDAT(4).
    LS_RUN-MBLNR = <LS_LIST>-MBLNR.
    LS_RUN-BUDAT = <LS_LIST>-BUDAT.
    LS_RUN-TABIX = <LS_ROW>-ROW_ID.
    APPEND LS_RUN TO LT_RUN.
  ENDLOOP.

  IF LT_RUN[] IS INITIAL.
    MESSAGE E000 WITH TEXT-E12.
  ENDIF.

*POP-UP 확인 후 자재문서 취소 처리
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT1
      TEXT_QUESTION = TEXT-Q03 "'자재문서 취소 하시겠습니까?'
    IMPORTING
      ANSWER        = LV_ANS.

  CHECK LV_ANS EQ GC_1.

  DATA:
    LS_HEAD   LIKE BAPI2017_GM_HEAD_02,
    LS_HRET   LIKE BAPI2017_GM_HEAD_RET,
    LS_RETURN TYPE BAPIRET2,
    LT_RETURN TYPE STANDARD TABLE OF BAPIRET2.

  CLEAR LS_RUN.
  LOOP AT  LT_RUN INTO LS_RUN.

    LS_HEAD-MAT_DOC    = LS_RUN-MBLNR.
    LS_HEAD-DOC_YEAR   = LS_RUN-MJAHR.
    LS_HEAD-PSTNG_DATE = LS_RUN-BUDAT.

    CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
      EXPORTING
        MATERIALDOCUMENT    = LS_HEAD-MAT_DOC
        MATDOCUMENTYEAR     = LS_HEAD-DOC_YEAR
        GOODSMVT_PSTNG_DATE = LS_HEAD-PSTNG_DATE
      IMPORTING
        GOODSMVT_HEADRET    = LS_HRET
      TABLES
        RETURN              = LT_RETURN.


    IF LS_HRET-MAT_DOC IS NOT INITIAL.
      "성공
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.

      READ TABLE GT_LIST ASSIGNING <LS_LIST> INDEX LS_RUN-TABIX.
      CHECK SY-SUBRC EQ 0.

      <LS_LIST>-STATUS = ICON_LED_GREEN.
      <LS_LIST>-MESSAGE = SPACE.
      <LS_LIST>-MBLNR = SPACE.

*기초재고 이관 이력 테이블 자재문서 취소 UPDATE
      UPDATE ZGTPPT9070
            SET LOEKZ = ABAP_TRUE
                   CHNAM = SY-UNAME
                   CHDAT = SY-DATUM
                   CHTIM = SY-UZEIT
        WHERE MBLNR = LS_RUN-MBLNR
             AND MJAHR = LS_RUN-MJAHR.

      MESSAGE S000 WITH TEXT-M03. "자재문서 취소 완료 했습니다.

    ELSE.
      "오류
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      CLEAR LS_RETURN.
      READ TABLE LT_RETURN INTO LS_RETURN WITH KEY TYPE = GC_E.

      READ TABLE GT_LIST ASSIGNING <LS_LIST> INDEX LS_RUN-TABIX.
      CHECK SY-SUBRC EQ 0.
      <LS_LIST>-STATUS = ICON_LED_RED.
      <LS_LIST>-MESSAGE = LS_RETURN-MESSAGE.

*      MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-E13. "자재문서 취소 실패 했습니다.
    ENDIF.

    CLEAR LS_RUN.
  ENDLOOP.

ENDFORM.
