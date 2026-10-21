*&---------------------------------------------------------------------*
*& Include          ZGTMMR1040F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form F_INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_INITIALIZATION .

  "구매조직
  IF S_EKORG[] IS INITIAL.
    S_EKORG[] = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = '1400' ) ).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_FIELD_VALUE_1000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CHECK_FIELD_VALUE_1000 .

  "구매조직
  IF S_EKORG[] IS NOT INITIAL.
    SELECT SINGLE
      EKORG
      FROM T024E
      WHERE EKORG IN @S_EKORG
      INTO @DATA(LV_CHK1).
    IF SY-SUBRC NE 0.
      MESSAGE E013 WITH TEXT-H02.
    ENDIF.
  ENDIF.

  "공급업체
  IF S_LIFNR[] IS NOT INITIAL.
    SELECT SINGLE
      LIFNR
      FROM LFA1
      WHERE LIFNR IN @S_LIFNR
      INTO @DATA(LV_CHK2).
    IF SY-SUBRC NE 0.
      MESSAGE E013 WITH TEXT-H01.
    ENDIF.
  ENDIF.

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

  LOOP AT SCREEN.
    CASE SCREEN-GROUP1.
      WHEN 'FIL'.
        SCREEN-REQUIRED = 2.
        IF P_CREA EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.
      WHEN 'EKO' OR 'LIF'.
        IF SCREEN-GROUP1 EQ 'EKO' AND SCREEN-GROUP3 NE 'HGH'.
          SCREEN-REQUIRED = 2.
        ENDIF.

        IF P_DISP EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.
    ENDCASE.
  ENDLOOP.

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

  "입력 값 점검
  PERFORM F_CHECK_INPUT_FIELDS_1000.

  CASE ABAP_TRUE.
    WHEN P_CREA. "생성
      PERFORM F_GET_LIST_CREA.

    WHEN P_DISP. "조회
      PERFORM F_GET_LIST_DISP.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_LIST_CREA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_LIST_CREA .

  "엑셀 데이터 조회
  DATA LT_XLS TYPE STANDARD TABLE OF TY_XLS.
  PERFORM F_GET_EXCEL_DATA CHANGING LT_XLS.

  "데이터 설정
  PERFORM F_SET_DATA USING LT_XLS.

  "데이터 점검
  PERFORM F_CHECK_DATA.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_INPUT_FIELDS_1000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CHECK_INPUT_FIELDS_1000 .

  CASE ABAP_TRUE.
    WHEN P_CREA. "생성
      IF P_FILE IS INITIAL.
        MESSAGE S018 DISPLAY LIKE GC_E.
        LEAVE LIST-PROCESSING.
      ENDIF.

    WHEN P_DISP. "조회
      IF S_EKORG[] IS INITIAL.
        MESSAGE S018 DISPLAY LIKE GC_E.
        LEAVE LIST-PROCESSING.
      ENDIF.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_EXCEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_EXCEL_DATA CHANGING CT_XLS TYPE TY_T_XLS.

  CLEAR CT_XLS[].
  DATA LT_ITAB TYPE STANDARD TABLE OF ALSMEX_TABLINE.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      FILENAME                = P_FILE
      I_BEGIN_COL             = 1
      I_BEGIN_ROW             = 2
      I_END_COL               = 11
      I_END_ROW               = 50000
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
*& Form F_SET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_XLS
*&---------------------------------------------------------------------*
FORM F_SET_DATA  USING  PT_XLS TYPE TY_T_XLS.

  "초기화
  CLEAR GT_LIST[].
  "수량/금액 등 필드가 없으니 바로 설정
  GT_LIST[] = CORRESPONDING #( PT_XLS[] ).

  "내부유형으로 설정(Conversion exit , 대문자)
  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).

    "대문자 변경
    TRANSLATE:
      <LS_LIST>-LIFNR TO UPPER CASE,
      <LS_LIST>-EKORG TO UPPER CASE,
      <LS_LIST>-WAERS TO UPPER CASE,
      <LS_LIST>-ZTERM TO UPPER CASE,
      <LS_LIST>-INCO1 TO UPPER CASE,
      <LS_LIST>-WEBRE TO UPPER CASE,
      <LS_LIST>-KALSK TO UPPER CASE,
      <LS_LIST>-KZAUT TO UPPER CASE,
      <LS_LIST>-MEPRF TO UPPER CASE.

    "Conversion-exit
    <LS_LIST>-LIFNR = |{ <LS_LIST>-LIFNR ALPHA = IN }|.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CHECK_DATA .

  "대상이 있는 경우 진행
  CHECK GT_LIST[] IS NOT INITIAL.

  "BP 조회
  SELECT
    CV~VENDOR,
    BU~PARTNER
   FROM BUT000 AS BU
                INNER JOIN
             CVI_VEND_LINK AS CV ON   BU~PARTNER_GUID EQ CV~PARTNER_GUID
   WHERE EXISTS (
      SELECT ZZ~LIFNR
        FROM @GT_LIST AS ZZ
        WHERE ZZ~LIFNR EQ CV~VENDOR
    )
    ORDER BY CV~VENDOR
    INTO TABLE @DATA(LT_BP).

  "BP Role 조회
  SELECT BU~PARTNER,
               BT~RLTYP
     FROM BUT000 AS BU
                  INNER JOIN
               BUT100 AS BT ON BU~PARTNER EQ BT~PARTNER
   WHERE EXISTS (
      SELECT ZZ~PARTNER
          FROM @LT_BP AS ZZ
          WHERE ZZ~PARTNER EQ BU~PARTNER
   )
   ORDER BY BU~PARTNER, BT~RLTYP
   INTO TABLE @DATA(LT_ROLE).

  "공급업체 계정그룹
  SELECT
    LF~LIFNR,
    LF~KTOKK
    FROM LFA1 AS LF
    WHERE EXISTS (
     SELECT ZZ~LIFNR
       FROM @GT_LIST AS ZZ
       WHERE ZZ~LIFNR EQ LF~LIFNR
    )
    ORDER BY LF~LIFNR
    INTO TABLE @DATA(LT_LFA1).

  "유효성 점검 대상
*구매조직                 EKORG  T024E
  SELECT
    EKORG
    FROM T024E
    ORDER BY EKORG
    INTO TABLE @DATA(LT_T024E).

*오더통화                 WAERS  TCURC
  SELECT
    WAERS
    FROM TCURC
    ORDER BY WAERS
    INTO TABLE @DATA(LT_TCURC).

*지급조건                 ZTERM  T052
  SELECT DISTINCT
    ZTERM
    FROM T052
    ORDER BY ZTERM
    INTO TABLE @DATA(LT_T052).

*인코텀스                 INCO1  TINC
  SELECT INCO1
    FROM TINC
    ORDER BY INCO1
    INTO TABLE @DATA(LT_TINC).

*스키마그룹                  KALSK TMKK
  SELECT
    KALSK
    FROM TMKK
    ORDER BY KALSK
    INTO TABLE @DATA(LT_TMKK).

*가격 결정일 관리                  MEPRF    MEPRF(domain)
  DATA LT_DOMVAL TYPE STANDARD TABLE OF DD07V.
  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      DOMNAME    = 'MEPRF'
    TABLES
      VALUES_TAB = LT_DOMVAL.
  SORT LT_DOMVAL BY DOMVALUE_L.


  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).

*    기본 필수 값 점검 (필수 값이 누락되었습니다. &)
    "공급업체
    IF <LS_LIST>-LIFNR IS INITIAL.
      <LS_LIST>-STATUS = ICON_RED_LIGHT.
      MESSAGE S008 WITH TEXT-H01 INTO <LS_LIST>-MESSAGE.
      CONTINUE.
    ENDIF.
    "구매조직
    IF <LS_LIST>-EKORG IS INITIAL.
      <LS_LIST>-STATUS = ICON_RED_LIGHT.
      MESSAGE S008 WITH TEXT-H02 INTO <LS_LIST>-MESSAGE.
      CONTINUE.
    ENDIF.
    "오더통화
    IF <LS_LIST>-WAERS IS INITIAL.
      <LS_LIST>-STATUS = ICON_RED_LIGHT.
      MESSAGE S008 WITH TEXT-H03 INTO <LS_LIST>-MESSAGE.
      CONTINUE.
    ENDIF.
    "지급조건
    IF <LS_LIST>-ZTERM IS INITIAL.
      <LS_LIST>-STATUS = ICON_RED_LIGHT.
      MESSAGE S008 WITH TEXT-H04 INTO <LS_LIST>-MESSAGE.
      CONTINUE.
    ENDIF.

*2-1) LIFNR 기준 BP 존재 여부 점검
    READ TABLE LT_BP ASSIGNING FIELD-SYMBOL(<LS_BP>) WITH KEY VENDOR = <LS_LIST>-LIFNR BINARY SEARCH.
    IF SY-SUBRC NE 0.
*      BP 존재 여부 점검 : 공급업체 번호를 확인하세요.
      <LS_LIST>-STATUS = ICON_RED_LIGHT.
      <LS_LIST>-MESSAGE = TEXT-E01.
      CONTINUE.
*    ELSE.
**      공급처 Role 점검 : 이미 등록된 공급업체 입니다.
*      READ TABLE LT_ROLE WITH KEY PARTNER = <LS_BP>-PARTNER RLTYP = 'FLVN01' BINARY SEARCH TRANSPORTING NO FIELDS.
*      IF SY-SUBRC EQ 0.
*        <LS_LIST>-STATUS = ICON_RED_LIGHT.
*        <LS_LIST>-MESSAGE = TEXT-E02.
*        CONTINUE.
*      ENDIF.
    ENDIF.

    READ TABLE LT_LFA1 ASSIGNING FIELD-SYMBOL(<LS_LFA1>) WITH KEY LIFNR = <LS_LIST>-LIFNR BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      "공급업체 계정그룹 = 2000 이면 필수
      IF <LS_LFA1>-KTOKK EQ '2000'.
        "인코텀스
        IF <LS_LIST>-INCO1 IS INITIAL.
          <LS_LIST>-STATUS = ICON_RED_LIGHT.
          MESSAGE S008 WITH TEXT-H05 INTO <LS_LIST>-MESSAGE.
          CONTINUE.
        ENDIF.
        "스키마그룹
        IF <LS_LIST>-KALSK IS INITIAL.
          <LS_LIST>-STATUS = ICON_RED_LIGHT.
          MESSAGE S008 WITH TEXT-H09 INTO <LS_LIST>-MESSAGE.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.

*  유효성 점검
*구매조직                 EKORG  T024E
    READ TABLE LT_T024E WITH KEY EKORG = <LS_LIST>-EKORG BINARY SEARCH TRANSPORTING NO FIELDS.
    IF SY-SUBRC NE 0.
      <LS_LIST>-STATUS = ICON_RED_LIGHT.
      MESSAGE S160 WITH TEXT-H02 INTO <LS_LIST>-MESSAGE.
      CONTINUE.
    ENDIF.

*오더통화                 WAERS  TCURC
    READ TABLE LT_TCURC WITH KEY WAERS = <LS_LIST>-WAERS BINARY SEARCH TRANSPORTING NO FIELDS.
    IF SY-SUBRC NE 0.
      <LS_LIST>-STATUS = ICON_RED_LIGHT.
      MESSAGE S160 WITH TEXT-H03 INTO <LS_LIST>-MESSAGE.
      CONTINUE.
    ENDIF.

*지급조건                 ZTERM  T052
    READ TABLE LT_T052 WITH KEY ZTERM = <LS_LIST>-ZTERM BINARY SEARCH TRANSPORTING NO FIELDS.
    IF SY-SUBRC NE 0.
      <LS_LIST>-STATUS = ICON_RED_LIGHT.
      MESSAGE S160 WITH TEXT-H04 INTO <LS_LIST>-MESSAGE.
      CONTINUE.
    ENDIF.

*인코텀스                 INCO1  TINC
    IF <LS_LIST>-INCO1 IS NOT INITIAL.
      READ TABLE LT_TINC WITH KEY INCO1 = <LS_LIST>-INCO1 BINARY SEARCH TRANSPORTING NO FIELDS.
      IF SY-SUBRC NE 0.
        <LS_LIST>-STATUS = ICON_RED_LIGHT.
        MESSAGE S160 WITH TEXT-H05 INTO <LS_LIST>-MESSAGE.
        CONTINUE.
      ENDIF.
    ENDIF.

*스키마그룹                  KALSK TMKK
    IF <LS_LIST>-INCO1 IS NOT INITIAL.
      READ TABLE LT_TMKK WITH KEY KALSK = <LS_LIST>-KALSK BINARY SEARCH TRANSPORTING NO FIELDS.
      IF SY-SUBRC NE 0.
        <LS_LIST>-STATUS = ICON_RED_LIGHT.
        MESSAGE S160 WITH TEXT-H09 INTO <LS_LIST>-MESSAGE.
        CONTINUE.
      ENDIF.
    ENDIF.

*가격 결정일 관리                  MEPRF    MEPRF(domain)
    IF <LS_LIST>-INCO1 IS NOT INITIAL.
      READ TABLE LT_DOMVAL WITH KEY DOMVALUE_L = <LS_LIST>-MEPRF BINARY SEARCH TRANSPORTING NO FIELDS.
      IF SY-SUBRC NE 0.
        <LS_LIST>-STATUS = ICON_RED_LIGHT.
        MESSAGE S160 WITH TEXT-H11 INTO <LS_LIST>-MESSAGE.
        CONTINUE.
      ENDIF.
    ENDIF.

    "입고기준 송장검증
    IF <LS_LIST>-WEBRE IS NOT INITIAL AND <LS_LIST>-WEBRE NE ABAP_TRUE.
      <LS_LIST>-STATUS = ICON_RED_LIGHT.
      MESSAGE S160 WITH TEXT-H08 INTO <LS_LIST>-MESSAGE.
      CONTINUE.
    ENDIF.

    "자동구매오더
    IF <LS_LIST>-KZAUT IS NOT INITIAL AND <LS_LIST>-KZAUT NE ABAP_TRUE.
      <LS_LIST>-STATUS = ICON_RED_LIGHT.
      MESSAGE S160 WITH TEXT-H10 INTO <LS_LIST>-MESSAGE.
      CONTINUE.
    ENDIF.

    <LS_LIST>-STATUS = ICON_YELLOW_LIGHT.
    <LS_LIST>-MESSAGE = SPACE.
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

  "데이터가 없으면 메세지 처리
  IF GT_LIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE GC_E.
    LEAVE LIST-PROCESSING.
  ENDIF.

  "Screen 100 이동
  CALL SCREEN 100.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CREATE_BP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE_BP .
*
*  1. 작업구분 = "생성" 인 경우 생성 버튼 선택시
*
*  1) BP ROLE  FVLN01 생성을 위한 데이터 설정


  "BP 조회
  SELECT
    CV~VENDOR,
    BU~PARTNER
   FROM BUT000 AS BU
                INNER JOIN
             CVI_VEND_LINK AS CV ON   BU~PARTNER_GUID EQ CV~PARTNER_GUID
   WHERE EXISTS (
      SELECT ZZ~LIFNR
        FROM @GT_LIST AS ZZ
        WHERE ZZ~LIFNR EQ CV~VENDOR
            AND ZZ~STATUS EQ @ICON_YELLOW_LIGHT
    )
    ORDER BY CV~VENDOR
    INTO TABLE @DATA(LT_BP).

  "BP Role 조회
  SELECT BU~PARTNER,
               BT~RLTYP
     FROM BUT000 AS BU
                  INNER JOIN
               BUT100 AS BT ON BU~PARTNER EQ BT~PARTNER
   WHERE EXISTS (
      SELECT ZZ~PARTNER
          FROM @LT_BP AS ZZ
          WHERE ZZ~PARTNER EQ BU~PARTNER
   )
   ORDER BY BT~RLTYP
   INTO TABLE @DATA(LT_ROLE).

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
    CHECK <LS_LIST>-STATUS EQ ICON_YELLOW_LIGHT. "노란색만 실행

    "한건 씩 실행
    PERFORM F_RUN USING <LS_LIST>.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_RUN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_LIST>
*&---------------------------------------------------------------------*
FORM F_RUN  USING    PS_LIST TYPE TY_LIST.
*2) CL_MD_BP_MAINTAIN 호출
*2-1) 실행 성공시 COMMIT 수행 및 STAUTS Green 으로 업데이트
*2-2) 실행 실패시 STAUTS RED, 오류 메시지 MESSAGE  화면 필드 업데이트

  DATA :
    LV_PARTNER      TYPE BU_PARTNER,
    LV_PARTNER_GUID TYPE SYSUUID_X16,
    LS_DATA         TYPE CVIS_EI_EXTERN,
    LT_DATA         TYPE CVIS_EI_EXTERN_T.

  SELECT SINGLE
    BU~PARTNER,
    BU~PARTNER_GUID
   FROM BUT000 AS BU
                INNER JOIN
             CVI_VEND_LINK AS CV ON   BU~PARTNER_GUID EQ CV~PARTNER_GUID
   WHERE CV~VENDOR EQ  @PS_LIST-LIFNR
    INTO (@LV_PARTNER , @LV_PARTNER_GUID).

  LS_DATA-PARTNER-HEADER-OBJECT_TASK = GC_U.
  LS_DATA-PARTNER-HEADER-OBJECT_INSTANCE-BPARTNER = LV_PARTNER .
  LS_DATA-PARTNER-HEADER-OBJECT_INSTANCE-BPARTNERGUID =  LV_PARTNER_GUID.

  SELECT BT~RLTYP
     FROM BUT000 AS BU
                  INNER JOIN
               BUT100 AS BT ON BU~PARTNER EQ BT~PARTNER
   WHERE BU~PARTNER EQ @LV_PARTNER
    ORDER BY BT~RLTYP
    INTO TABLE @DATA(LT_RCHK).

  READ TABLE LT_RCHK WITH KEY RLTYP = 'FLVN01' BINARY SEARCH TRANSPORTING NO FIELDS.
  IF SY-SUBRC NE 0.
    DATA LS_ROLE TYPE BUS_EI_BUPA_ROLES.
    LS_ROLE-TASK = GC_I.
    LS_ROLE-DATA_KEY = 'FLVN01'.
    LS_ROLE-DATA-ROLECATEGORY = 'FLVN01'.
    LS_ROLE-DATA-VALID_FROM = SY-DATUM.
    LS_ROLE-DATA-VALID_TO = '99991231'.
    LS_ROLE-DATAX-VALID_FROM = ABAP_TRUE.
    LS_ROLE-DATAX-VALID_TO = ABAP_TRUE.
    APPEND LS_ROLE TO LS_DATA-PARTNER-CENTRAL_DATA-ROLE-ROLES.
  ENDIF.

  LS_DATA-VENDOR-HEADER-OBJECT_INSTANCE-LIFNR = PS_LIST-LIFNR.
  LS_DATA-VENDOR-HEADER-OBJECT_TASK =  GC_U.


  DATA LS_PURCHASING TYPE VMDS_EI_PURCHASING.
  LS_PURCHASING-TASK = GC_I.

  LS_PURCHASING-DATA_KEY = PS_LIST-EKORG.
  LS_PURCHASING-DATA-WAERS = PS_LIST-WAERS.
  LS_PURCHASING-DATA-ZTERM = PS_LIST-ZTERM.
  LS_PURCHASING-DATA-INCO1 = PS_LIST-INCO1.
  LS_PURCHASING-DATA-VERKF = PS_LIST-VERKF.
  LS_PURCHASING-DATA-TELF1 = PS_LIST-TELF1.
  LS_PURCHASING-DATA-WEBRE = PS_LIST-WEBRE.
  LS_PURCHASING-DATA-KALSK = PS_LIST-KALSK.
  LS_PURCHASING-DATA-KZAUT = PS_LIST-KZAUT.
  LS_PURCHASING-DATA-MEPRF = PS_LIST-MEPRF.

  LS_PURCHASING-DATAX-WAERS = ABAP_TRUE.
  LS_PURCHASING-DATAX-ZTERM = ABAP_TRUE.
  LS_PURCHASING-DATAX-INCO1 = ABAP_TRUE.
  LS_PURCHASING-DATAX-VERKF = ABAP_TRUE.
  LS_PURCHASING-DATAX-TELF1 = ABAP_TRUE.
  LS_PURCHASING-DATAX-WEBRE = ABAP_TRUE.
  LS_PURCHASING-DATAX-KALSK = ABAP_TRUE.
  LS_PURCHASING-DATAX-KZAUT = ABAP_TRUE.
  LS_PURCHASING-DATAX-MEPRF = ABAP_TRUE.

  APPEND LS_PURCHASING TO LS_DATA-VENDOR-PURCHASING_DATA-PURCHASING.
  APPEND LS_DATA TO LT_DATA.

  DATA LT_RET TYPE BAPIRETCT.
  CL_MD_BP_MAINTAIN=>MAINTAIN(
    EXPORTING
        I_DATA = LT_DATA
        IMPORTING
          E_RETURN = DATA(LT_RES)
  ).

  IF LT_RES[] IS NOT INITIAL.
    READ TABLE LT_RES ASSIGNING FIELD-SYMBOL(<LT_MSG>) INDEX 1.
    READ TABLE <LT_MSG>-OBJECT_MSG[] ASSIGNING FIELD-SYMBOL(<LS_MSG_E>) WITH KEY TYPE = GC_E.
    IF SY-SUBRC EQ 0.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      PS_LIST-STATUS = ICON_RED_LIGHT.
      PS_LIST-MESSAGE = <LS_MSG_E>-MESSAGE.
    ELSE.
      READ TABLE <LT_MSG>-OBJECT_MSG[] ASSIGNING FIELD-SYMBOL(<LS_MSG_A>) WITH KEY TYPE = GC_A.
      IF SY-SUBRC EQ 0.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        PS_LIST-STATUS = ICON_RED_LIGHT.
        PS_LIST-MESSAGE = <LS_MSG_A>-MESSAGE.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = ABAP_TRUE.
        PS_LIST-STATUS = ICON_GREEN_LIGHT.
        PS_LIST-MESSAGE = SPACE.

      ENDIF.
    ENDIF.
  ELSE.
    PS_LIST-STATUS = ICON_GREEN_LIGHT.
    PS_LIST-MESSAGE = SPACE.
  ENDIF.

  CHECK PS_LIST-STATUS EQ ICON_GREEN_LIGHT.

*3) 처리 결과 Log  저장
  DATA LS_LOG TYPE ZGTMMT9280.
  LS_LOG = CORRESPONDING #( PS_LIST ).
  LS_LOG-ERDAT = SY-DATLO.
  LS_LOG-ERNAM = SY-UNAME.

  MODIFY ZGTMMT9280 FROM LS_LOG.
  COMMIT WORK.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_LIST_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_LIST_DISP .

  CLEAR GT_LIST[].

  SELECT
    *
    FROM ZGTMMT9280 AS Z1
    WHERE Z1~EKORG IN @S_EKORG
    AND Z1~LIFNR IN @S_LIFNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

ENDFORM.
