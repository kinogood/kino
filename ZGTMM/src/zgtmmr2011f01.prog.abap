*&---------------------------------------------------------------------*
*& Include          ZGTMMR2011F01
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

  IF S_BADAT[] IS INITIAL.
    S_BADAT[] = VALUE #( ( SIGN = 'I' OPTION = 'BT'  LOW = SY-DATLO - 1 HIGH = SY-DATLO ) ).
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
      WHEN 'BUK' OR 'APP'.
        SCREEN-REQUIRED = 2.
        MODIFY SCREEN.

    ENDCASE.
  ENDLOOP.

ENDFORM.

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

  IF S_WERKS[] IS NOT INITIAL.
    LOOP AT S_WERKS INTO DATA(LS_WERKS2).
      AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
                   ID 'WERKS' FIELD LS_WERKS2-LOW.

      CHECK SY-SUBRC <> 0.

      SET CURSOR FIELD 'S_WERKS-LOW'.
      MESSAGE E106 WITH S_WERKS-LOW. "플랜트 [&] 작업권한을 확인하세요.
    ENDLOOP.
  ENDIF.

  IF S_EKORG[] IS NOT INITIAL.
    LOOP AT S_EKORG INTO DATA(LS_EKORG2).
      AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
                   ID 'EKORG' FIELD LS_EKORG2-LOW.

      CHECK SY-SUBRC <> 0.

      SET CURSOR FIELD 'S_EKORG-LOW'.
      MESSAGE E170 WITH S_EKORG-LOW. "구매조직 [&] 작업권한을 확인하세요.
    ENDLOOP.
  ENDIF.

  IF S_EKGRP[] IS NOT INITIAL.
    LOOP AT S_EKGRP INTO DATA(LS_EKGRP2).
      AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
                   ID 'EKGRP' FIELD LS_EKGRP2-LOW.

      CHECK SY-SUBRC <> 0.

      SET CURSOR FIELD 'S_EKGRP-LOW'.
      MESSAGE E171 WITH S_EKGRP-LOW. "구매그룹 [&] 작업권한을 확인하세요.
    ENDLOOP.
  ENDIF.

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
  MESSAGE E000 WITH TEXT-E01. "참조테이블에 없는 값을 입력할 경우 오류메시지 처리 "입력된 정보를 확인하세요.")

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

  CHECK S_WERKS[] IS NOT INITIAL.

  "유효성 점검
  SELECT SINGLE
    WERKS
    FROM T001W
    WHERE WERKS IN @S_WERKS
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E000 WITH TEXT-E01. "참조테이블에 없는 값을 입력할 경우 오류메시지 처리 "입력된 정보를 확인하세요.")

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

  CHECK S_EKORG[] IS NOT INITIAL.

  "유효성 점검
  SELECT SINGLE
    EKORG
    FROM T024E
    WHERE EKORG IN @S_EKORG
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E000 WITH TEXT-E01. "참조테이블에 없는 값을 입력할 경우 오류메시지 처리 "입력된 정보를 확인하세요.")

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_EKGRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_EKGRP .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR GV_ERROR.

  CHECK S_EKGRP[] IS NOT INITIAL.

  "유효성 점검
  SELECT SINGLE
    EKGRP
    FROM T024
    WHERE EKGRP IN @S_EKGRP
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E000 WITH TEXT-E01. "참조테이블에 없는 값을 입력할 경우 오류메시지 처리 "입력된 정보를 확인하세요.")

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_MATNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_MATNR .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR GV_ERROR.

  CHECK S_MATNR[] IS NOT INITIAL.

  "유효성 점검
  SELECT SINGLE
    MATNR
    FROM MARA
    WHERE MATNR IN @S_MATNR
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E000 WITH TEXT-E01. "참조테이블에 없는 값을 입력할 경우 오류메시지 처리 "입력된 정보를 확인하세요.")

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_BADAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_BADAT .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR GV_ERROR.

  CHECK S_BADAT[] IS NOT INITIAL.

  "유효성 점검
  SELECT SINGLE
    BADAT
    FROM EBAN
    WHERE BADAT IN @S_BADAT
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E000 WITH TEXT-E01. "참조테이블에 없는 값을 입력할 경우 오류메시지 처리 "입력된 정보를 확인하세요.")

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_BANFN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_BANFN .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR GV_ERROR.

  CHECK S_BANFN[] IS NOT INITIAL.

  "유효성 점검
  SELECT SINGLE
    BANFN
    FROM EBAN
    WHERE BANFN IN @S_BANFN
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E000 WITH TEXT-E01. "참조테이블에 없는 값을 입력할 경우 오류메시지 처리 "입력된 정보를 확인하세요.")

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_APPUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_APPUS .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR GV_ERROR.

  "필수 값 점검
  IF P_APPUS IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F02.
  ENDIF.

  CHECK GV_ERROR EQ SPACE.

  " 사용자 ID(사번) ALPHA CONVERSION
  DATA(LV_APPUS) = CONDENSE( P_APPUS ).

  IF LV_APPUS CO '0123456789'.
    GV_APPUSER = LV_APPUS.
    GV_APPUSER = |{ GV_APPUSER ALPHA = IN }|.
  ENDIF.


  "유효성 점검
  SELECT SINGLE
    APPUSER
    FROM ZGTMMT1070
    WHERE APPUSER EQ @GV_APPUSER "P_APPUS
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E000 WITH TEXT-E01. "참조테이블에 없는 값을 입력할 경우 오류메시지 처리 "입력된 정보를 확인하세요.")

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

  "데이터 조회
  PERFORM F_GET_LIST.

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

  IF GT_LIST[] IS INITIAL.
*      2) 조회된 데이터가 없는 경우 하단 정보메시지 DISPLAY "조회된 값이 없습니다."
    MESSAGE S002 DISPLAY LIKE GC_E.
    LEAVE LIST-PROCESSING.
  ENDIF.

  CALL SCREEN 100.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_LIST .

  CASE ABAP_TRUE.
    WHEN P_DISP.
      PERFORM F_GET_LIST_DISP.
    WHEN P_CONF.
      PERFORM F_GET_LIST_CONF.
  ENDCASE.

"<--2026.07.22 주석처리
**
**1)   실행 조회조건 값을 기준으로 승인 요청 내역 추출
**
**  Table : ZGTMMT1070
**
**  SELECT 조건: BANFN,BNFPO
**  WHERE 조건:
**  WERKS = 조건 입력값
**  APPUSER = 조건 입력 값
**  APPTYPE = "A" 이고 AEDAT = "" 인 구매요청번호, 구매요청 품목 추출
**
**2) 구매요청 일반정보 조회
**  Table : EBAN
**
**  SELECT 조건: BANFN,BNFPO,BADAT,ERNAM,MATNR,TXZ01,WERKS,LGORT,MENGE,MEINS,LFDAT,
**            PREIS,WAERS,PEINH,EKORG,EKGRP,AFNAM,KNTTP,FRGKZ
**  WHERE 조건 :
**  BANFN = 1) 의 대상 요청 번호
**  BNFPO = 1) 의 대상 품목 번호
**
**3) 구매요청 계정 지정 정보 조회
**  Table : EBKN
**
**  SELECT 조건: ANLN1,KOSTL,SAKTO,AUFNR,PS_PSP_NR
**  WHERE 조건 :
**  BANFN =1) 의 대상 구매요청 번호
**  BNFPO = 1) 의 대상구매요청 품목번호
**
**4) Text 및 기타 정보 추출
**  3-1) NAME_TEXT : PUSER002-NAME_TEXT
**  3-2) NAME1 : T001W-NAME1
**  3-3) LGOBE : T001L-LGOBE
**  3-4) EKOTX : T024E-EKOTX
**  3-5) EKNAM : T024-EKNAM
**  "3-6) KNTTX : T163I-KNTTX "
**  3-7) TXT50 : ANLA-TXT50
** "3-8) TXT20 : SKAT-TXT20 (SPRAS = ""3"")  "
**  "3-9) KTEXT : CSKT-KTEXT (SPRAS=""3"", KOKRS=BUKRS 입력값) "
**  3-10) KTEXT : AUFK-KTEXT
**  3-11) POST1 : PRPS-POST1
**  3-12) WGBEZ : T023T-WGBEZ
*
*  "초기화
*  CLEAR GT_LIST[].
*
**  "승인 대상/완료 구분조건 설정
**  DATA LR_AEDAT TYPE RANGE OF ZGTMMT1070-AEDAT.
**  CASE ABAP_TRUE.
**    WHEN P_DISP.
**      LR_AEDAT = VALUE #( ( SIGN = 'I' OPTION = 'NE' LOW = '00000000' ) ).
**    WHEN P_CONF.
**      LR_AEDAT = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = '00000000' ) ).
**  ENDCASE.
*
**APPTYPE = "A" 이고 APPSTATUS <> "" 인 구매요청번호, 구매요청 품목 추출
*  DATA:
*    LR_APPTYPE   TYPE RANGE OF ZGTMMT1070-APPTYPE,
*    LR_APPSTATUS TYPE RANGE OF ZGTMMT1070-APPSTATUS.
*
**  CASE ABAP_TRUE.
**    WHEN P_DISP.
**      LR_AEDAT = VALUE #( ( SIGN = 'I' OPTION = 'NE' LOW = '00000000' ) ).
**    WHEN P_CONF.
**      LR_AEDAT = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = '00000000' ) ).
**  ENDCASE.
*
*  SELECT
*    EB~BANFN,
*    EB~BNFPO,
*    EB~FRGKZ,
*    EB~BADAT,
*    EB~ERNAM,
*    EB~MATNR,
*    EB~TXZ01,
*    EB~WERKS,
*    TW~NAME1,
*    EB~LGORT,
*    TL~LGOBE,
*    EB~MENGE,
*    EB~MEINS,
*    EB~LFDAT,
*    EB~PREIS,
*    EB~WAERS,
*    EB~PEINH,
*    EB~EKORG,
*    TE~EKOTX,
*    EB~EKGRP,
*    T4~EKNAM,
*    EB~AFNAM,
*    EB~KNTTP,
*    TI~KNTTX,
*    EK~ANLN1,
*    AN~TXT50,
*    EK~KOSTL,
*    CT~KTEXT AS KOSTL_TEXT,
*    EK~SAKTO,
*    ST~TXT20 AS SAKTO_TEXT,
*    EK~AUFNR,
*    AK~KTEXT AS AUFNR_TEXT,
*    EK~PS_PSP_PNR,
*    PS~POST1
*    FROM EBAN AS EB
*                  INNER JOIN
*              T001W AS TW ON EB~WERKS EQ TW~WERKS
*                  INNER JOIN
*              T001K AS TK ON TW~BWKEY EQ TK~BWKEY
*                  INNER JOIN
*              T001 AS T1 ON TK~BUKRS EQ T1~BUKRS
*                  LEFT OUTER JOIN
*              T001L AS TL ON EB~WERKS EQ TL~WERKS
*                               AND EB~LGORT EQ TL~LGORT
*                  LEFT OUTER JOIN
*              T024E AS TE ON EB~EKORG EQ TE~EKORG
*                  LEFT OUTER JOIN
*              T024 AS T4 ON EB~EKGRP EQ T4~EKGRP
*                  LEFT OUTER JOIN
*              T163I AS TI ON EB~KNTTP EQ TI~KNTTP
*                             AND TI~SPRAS EQ @SY-LANGU
*                  LEFT OUTER JOIN
*              EBKN AS EK ON EB~BANFN EQ EK~BANFN
*                                AND EB~BNFPO EQ EK~BNFPO
*                  LEFT OUTER JOIN
*              ANLA AS AN ON TK~BUKRS EQ AN~BUKRS
*                                AND EK~ANLN1 EQ AN~ANLN1
*                                AND EK~ANLN2 EQ AN~ANLN2
*                  LEFT OUTER JOIN
*              CSKT AS CT ON EK~KOSTL EQ CT~KOSTL
*                           AND TK~BUKRS EQ CT~KOKRS
*                           AND CT~DATBI EQ '99991231'
*                           AND CT~SPRAS EQ @SY-LANGU
*                  LEFT OUTER JOIN
*               SKAT AS ST ON EK~SAKTO EQ ST~SAKNR
*                                AND T1~KTOPL EQ ST~KTOPL
*                                AND ST~SPRAS EQ @SY-LANGU
*                  LEFT OUTER JOIN
*                AUFK AS AK ON EK~AUFNR EQ AK~AUFNR
*                  LEFT OUTER JOIN
*                PRPS AS PS ON EK~PS_PSP_PNR EQ PS~PSPNR
*    WHERE TK~BUKRS EQ @P_BUKRS
*    AND EB~WERKS IN @S_WERKS
*    AND EB~EKORG IN @S_EKORG
*    AND EB~EKGRP IN @S_EKGRP
*    AND EB~BADAT IN @S_BADAT
*    AND EB~ERNAM IN @S_ERNAM
*    AND EB~BANFN IN @S_BANFN
*    AND EB~MATNR IN @S_MATNR
**  Table : ZGTMMT1070
**
**  SELECT 조건: BANFN,BNFPO
**  WHERE 조건:
**  WERKS = 조건 입력값
**  APPUSER = 조건 입력 값
**  APPTYPE = "A" 이고 AEDAT = "" 인 구매요청번호, 구매요청 품목 추출
*    AND EXISTS (
*      SELECT ZZ~BANFN
*        FROM ZGTMMT1070 AS ZZ
*        WHERE ZZ~BANFN EQ EB~BANFN
*             AND ZZ~BNFPO EQ EB~BNFPO
**             AND ZZ~WERKS EQ EB~WERKS ?????
*             AND APPUSER EQ @GV_APPUSER"P_APPUS
*             AND APPTYPE EQ @GC_A
**             AND AEDAT IN @LR_AEDAT
*    )
*    ORDER BY EB~BANFN, EB~BNFPO
*    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.
*
*  CHECK SY-SUBRC EQ 0.
*
*  SELECT
*    V1~BNAME,
*    V1~NAME_TEXT
*    FROM V_USERNAME AS V1
*    WHERE EXISTS (
*      SELECT ZZ~ERNAM
*        FROM @GT_LIST AS ZZ
*        WHERE ZZ~ERNAM EQ V1~BNAME
*    )
*    ORDER BY V1~BNAME
*    INTO TABLE @DATA(LT_USER).
*
*  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
*    READ TABLE LT_USER ASSIGNING FIELD-SYMBOL(<LS_USER>) WITH KEY BNAME = <LS_LIST>-ERNAM BINARY SEARCH.
*    IF SY-SUBRC EQ 0.
*      <LS_LIST>-NAME_TEXT = <LS_USER>-NAME_TEXT.
*    ENDIF.
*
**    PREIS*MENGE/PEINH
*    IF <LS_LIST>-PEINH IS NOT INITIAL.
*      <LS_LIST>-ZAMT = ( <LS_LIST>-PREIS * <LS_LIST>-MENGE ) / <LS_LIST>-PEINH.
*    ENDIF.
*  ENDLOOP.
"-->2026.07.22 주석처리
ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_REFRESH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_REFRESH .
*1-1. REFRESH : 조회 화면에서 선택시 ALV List Update

  "데이터 다시 조회
  PERFORM F_GET_LIST.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_PR_RELEASE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_PR_RELEASE .
*1-2. 구매요청 승인 : 선택한 라인에 대해 구매요청 릴리즈 처리

*1. 구매 요청 승인 버튼
*	1-1) 라인은 다중선택 가능 (전체선택 포함)
*	1-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
*	1-3) 선택한 라인이 존재하는 경우 POP-UP 확인 후 구매요청 릴리즈 처리

  DATA:
    LV_CHECK TYPE C LENGTH 1,
    LV_ANS   TYPE C LENGTH 1,
    LT_ROW   TYPE LVC_T_ROID.

  DATA:
    LV_CNT_S TYPE INT4,
    LV_CNT_E TYPE INT4.

  CALL METHOD GO_GRID_100->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW.
  DELETE LT_ROW WHERE ROW_ID LE 0.
  IF LT_ROW[] IS INITIAL.
*	1-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
    MESSAGE E163.
  ENDIF.

*	1-3) 선택한 라인이 존재하는 경우 POP-UP 확인 후 구매요청 릴리즈 처리
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT1
      TEXT_QUESTION = TEXT-Q01
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.

  DATA:
    LV_REL_CODE TYPE BAPIMMPARA-REL_CODE,
    LV_REL_IND  TYPE BAPIMMPARA-REL_IND,
    LT_RETURN   TYPE STANDARD TABLE OF BAPIRETURN,
    LT_LOG      TYPE STANDARD TABLE OF ZGTMMT1070,
    LT_LIST     TYPE TY_T_LIST.

  LV_REL_CODE = GC_REL_CODE.
  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.
*2. BAPI_REQUISITION_RELEASE 호출 PR 릴리즈 처리 수행
*	2-1) BAPI 처리를 위한 데이터 설정

    CLEAR:
      LV_REL_IND,
      LT_RETURN[].

    CALL FUNCTION 'BAPI_REQUISITION_RELEASE'
      EXPORTING
        NUMBER                 = <LS_LIST>-BANFN
        REL_CODE               = LV_REL_CODE
        ITEM                   = <LS_LIST>-BNFPO
      IMPORTING
        REL_INDICATOR_NEW      = LV_REL_IND
      TABLES
        RETURN                 = LT_RETURN
      EXCEPTIONS
        AUTHORITY_CHECK_FAIL   = 1
        REQUISITION_NOT_FOUND  = 2
        ENQUEUE_FAIL           = 3
        PREREQUISITE_FAIL      = 4
        RELEASE_ALREADY_POSTED = 5
        RESPONSIBILITY_FAIL    = 6
        OTHERS                 = 7.
    IF SY-SUBRC NE 0.
*2-2) RETURN-TYPE = E 이면
*	: CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
*	: ALV 화면 필드 업데이트
*
* 필드                  VALUE
* STATUS                   RED
* MESSAGE                 BAPI 실행 메시지
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      <LS_LIST>-STATUS = ICON_LED_RED.
      <LS_LIST>-MESSAGE = LT_RETURN[ TYPE = GC_E ]-MESSAGE.
      LV_CNT_E += 1.

    ELSE.
*2-3) RETURN-TYPE = S 이고 이면
*: CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*: ALV 화면 필드 업데이트
*
*필드                 VALUE
*STATUS                 GREEN
*MESSAGE                  구매요청 승인 완료 되었습니다.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.
      <LS_LIST>-STATUS = ICON_LED_GREEN.
      <LS_LIST>-MESSAGE = SPACE.
      <LS_LIST>-FRGKZ = LV_REL_IND.

      "로그 저장용
      LT_LOG = VALUE #( BASE LT_LOG ( BANFN = <LS_LIST>-BANFN
                                                             BNFPO = <LS_LIST>-BNFPO ) ).

      "이메일 전송용
      APPEND <LS_LIST> TO LT_LIST.

      LV_CNT_S += 1.
    ENDIF.
  ENDLOOP.

  IF LT_LOG[] IS NOT INITIAL.
    "이력 저장
    PERFORM F_SAVE_APPR_LOG USING LT_LOG GC_C.
    "이메일 전송
    PERFORM F_SEND_EMAIL USING LT_LIST GC_C.
  ENDIF.

  "메세지 처리
  "전체 데이터: &1 성공: &2 실패: &3
  DATA(LV_TOT) = LV_CNT_S + LV_CNT_E.
  MESSAGE S073 WITH LV_TOT LV_CNT_S LV_CNT_E.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SAVE_APPR_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_LOG
*&---------------------------------------------------------------------*
FORM F_SAVE_APPR_LOG  USING  PT_LOG TYPE TY_T_ZGTMMT1070
                                                     PV_APPSTATUS.

  CHECK PT_LOG[] IS NOT INITIAL.

*: 구매요청 승인 이력 테이블 업데이트
*필드                   ZGTMMT1070
*BANFN
*BANFPO
*APPTYPE
*APPUSER
*MAILSEND
*ERDAT
*ERDAT_LOCAL
*ERTIM
*ERTIM_LOCAL
*AEDAT                    SY-DATUM
*AEDAT_LOCAL                    SY-DATLO
*AEZET                    SY-UZEIT
*AEZET_LOCAL                    SY-TIMLO
*

  SELECT
    *
    FROM ZGTMMT1070 AS Z1
    WHERE EXISTS (
      SELECT ZZ~BANFN
      FROM @PT_LOG AS ZZ
      WHERE ZZ~BANFN EQ Z1~BANFN
         AND ZZ~BNFPO EQ Z1~BNFPO
    )
    AND Z1~APPTYPE EQ @GC_A
    ORDER BY Z1~BANFN, Z1~BNFPO
    INTO TABLE @DATA(LT_ORG).

  LOOP AT PT_LOG ASSIGNING FIELD-SYMBOL(<LS_LOG>).
    READ TABLE LT_ORG ASSIGNING FIELD-SYMBOL(<LS_ORG>) WITH KEY BANFN = <LS_LOG>-BANFN
                                                                                                    BNFPO = <LS_LOG>-BNFPO
                                                                                                    BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_LOG> = CORRESPONDING #( BASE ( <LS_LOG> ) <LS_ORG> ).
    ENDIF.

    <LS_LOG>-APPSTATUS = PV_APPSTATUS. "GC_C. "APPSATTUS                   "C"
    <LS_LOG>-AEDAT = SY-DATUM.
    <LS_LOG>-AEDAT_LOCAL = SY-DATLO.
    <LS_LOG>-AEZET = SY-UZEIT.
    <LS_LOG>-AEZET_LOCAL = SY-TIMLO.
  ENDLOOP.

  MODIFY ZGTMMT1070 FROM TABLE PT_LOG.
  COMMIT WORK.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SEND_EMAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_LIST
*&---------------------------------------------------------------------*
FORM F_SEND_EMAIL  USING   PT_LIST TYPE TY_T_LIST
                                               PV_APPSTATUS.
*3. 처리 결과 메일 전송
*
*	3-1) 수신 담당자(PR 생성자기준) 이메일 정보 조회
*
*   Table : ZPA0105
*   SELECT 조건 : SYSID
*   WEHRE 조건 :
*   PERNR = EBAN-ERNAM
*   SUBTY = "0007"
*   ENDDA = "9999.12.31"
*
*	3-2) 이메일 본문 내용 구성
*   첫번째 라인) 구매요청문서에 대한 승인이 완료 되었습니다.
*   두번째 라인) SAP에서 처리 상태를 확인하세요.
*
*   : ALV에서 릴리즈 성공한 구매요청번호,품목번호,승인일자(ZGTMMT1070-AEDAT) 리스트 형태로 구성
*
*	3-3) 결재 요청 메일 전송 FUNCTION Z_MM_SEND_MAIL  호출
*
* Parameter           VALUE
* I_UNAME           대상 구매요청의생성자 사번  EBAN-ERNAM
* I_E-MAIL            3-1) SYSID
* I_HEAD_TEXT           [승인완료] 구매요청문서에 대한 승인 완료되었습니다.
*
*	TABLE
* T_MSG           3-2)
*
  DATA LT_LIST TYPE TY_T_LIST.
*  수신 담당자(PR 생성자기준) 별 실행
  LOOP AT PT_LIST ASSIGNING FIELD-SYMBOL(<LS_G1>) GROUP BY ( ERNAM = <LS_G1>-ERNAM )
                                                                               ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    CLEAR LT_LIST[].
    LOOP AT GROUP <LS_GROUP> ASSIGNING FIELD-SYMBOL(<LS_LIST>).
      APPEND <LS_LIST> TO LT_LIST.
    ENDLOOP.

    "Emali 전송
    PERFORM F_SEND_EMAIL_BY_ERNAM USING LT_LIST PV_APPSTATUS.


  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SEND_EMAIL_BY_ERNAM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_LIST
*&---------------------------------------------------------------------*
FORM F_SEND_EMAIL_BY_ERNAM  USING  PT_LIST TYPE TY_T_LIST
                                                                 PV_APPSTATUS.

  FIELD-SYMBOLS <LS_LIST> TYPE TY_LIST.
  READ TABLE PT_LIST ASSIGNING <LS_LIST> INDEX 1.

  DATA:
    LV_PERNR     TYPE ZPERSNO,
    LV_UNAME     TYPE SY-UNAME,
    LV_EMAIL     TYPE AD_SMTPADR,
    LV_HEAD_TEXT TYPE SO_OBJ_DES,
    LT_MSG       TYPE BCSY_TEXT,
    LV_RETURN    TYPE C LENGTH 1,
    LV_MESSAGE   TYPE C LENGTH 100.

*	3-1) 수신 담당자(PR 생성자기준) 이메일 정보 조회
*
*   Table : ZPA0105
*   SELECT 조건 : SYSID
*   WEHRE 조건 :
*   PERNR = EBAN-ERNAM
*   SUBTY = "0007"
*   ENDDA = "9999.12.31"

  "숫자만 있을 때 진행
  IF <LS_LIST>-ERNAM+0(1) EQ 'Z'.
    EXIT.
  ENDIF.

  LV_PERNR = <LS_LIST>-ERNAM.

  SELECT SINGLE
    USRID
    FROM ZPA0105
    WHERE PERNR EQ @LV_PERNR
    AND SUBTY EQ '0007'
    AND ENDDA EQ '99991231'
    INTO @DATA(LV_SYSID).
  CHECK LV_SYSID IS NOT INITIAL.

*	3-2) 이메일 본문 내용 구성
*   첫번째 라인) 구매요청문서에 대한 승인이 완료 되었습니다.
*   두번째 라인) SAP에서 처리 상태를 확인하세요.
*
*   : ALV에서 릴리즈 성공한 구매요청번호,품목번호,승인일자(ZGTMMT1070-AEDAT) 리스트 형태로 구성
*
*	3-3) 결재 요청 메일 전송 FUNCTION Z_MM_SEND_MAIL  호출
*
* Parameter           VALUE
* I_UNAME           대상 구매요청의생성자 사번  EBAN-ERNAM
* I_E-MAIL            3-1) SYSID
* I_HEAD_TEXT           [승인완료] 구매요청문서에 대한 승인 완료되었습니다.
*
*	TABLE
* T_MSG           3-2)


* Parameter           VALUE
* I_UNAME           대상 구매요청의생성자 사번  EBAN-ERNAM
* I_E-MAIL            3-1) SYSID
* I_HEAD_TEXT           [승인완료] 구매요청문서에 대한 승인 완료되었습니다.

  LV_UNAME = <LS_LIST>-ERNAM.
  LV_EMAIL = LV_SYSID.
  LV_HEAD_TEXT = TEXT-Z01.

  DATA:
    LV_DATE_C TYPE C LENGTH 10.

  DATA:
    LV_LINE TYPE SO_TEXT255,
    LT_BODY TYPE BCSY_TEXT.

  LV_LINE = |<html><body style="font-size:10">|.
  LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).

  IF PV_APPSTATUS EQ GC_C.
    LV_LINE = |<p>구매요청문서에 대한 승인이 완료 되었습니다.</p>|.
  ELSE.
    LV_LINE = |<p>구매요청문서에 대한 승인이 반려 되었습니다.</p>|.
  ENDIF.
  LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).

  LV_LINE = |<p>SAP에서 처리 상태를 확인하세요. </p>|.
  LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
  LV_LINE = |<table border=1 STYLE="border-collapse: collapse;border-color: #000000;font-size:10" >|.
  LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).

  LV_LINE = |<tr align="center" style="background-color: #B3B1B1" ><td width="150px"><strong>구매요청번호</strong></td>|.
  LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
  LV_LINE = |<td width="100px" ><strong>품목번호</strong></td>|.
  LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
  IF PV_APPSTATUS EQ GC_C.
    LV_LINE = |<td width="150px" ><strong>승인일자</strong></td>|.
  ELSE.
    LV_LINE = |<td width="150px" ><strong>반려일자</strong></td>|.
  ENDIF.

  LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).

  LOOP AT PT_LIST ASSIGNING <LS_LIST>.

    LV_LINE = |<tr><td align="center" >{ <LS_LIST>-BANFN ALPHA = OUT }</td>|.
    LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
    LV_LINE = |<td align="center" >{ <LS_LIST>-BNFPO ALPHA = OUT }</td>|.
    LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
    LV_LINE = |<td align="center" >{ SY-DATUM+0(4) }.{ SY-DATUM+4(2) }.{ SY-DATUM+6(2) }</td></tr>|.
    LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
  ENDLOOP.

  LV_LINE = |</table></body></html>|.
  LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).


  DATA:
    LV_CHECK       TYPE C LENGTH 1,
    LO_RECEIVER    TYPE REF TO IF_RECIPIENT_BCS,
    LO_EMAIL       TYPE REF TO CL_BCS,
    LO_EMAIL_BODY  TYPE REF TO CL_DOCUMENT_BCS,
    LX_EXCEPTION   TYPE REF TO CX_BCS,
    LV_SEND_RESULT TYPE C.

  TRY.
      LO_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).

      LO_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                      I_TYPE    = 'HTM'
                      I_TEXT    = LT_BODY
                      I_SUBJECT = LV_HEAD_TEXT ).

      LO_EMAIL->SET_DOCUMENT( LO_EMAIL_BODY ).

      LO_RECEIVER =
      CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( LV_EMAIL ).

      LO_EMAIL->ADD_RECIPIENT( I_RECIPIENT = LO_RECEIVER
                               I_EXPRESS = 'X' ).

      LO_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).

      LO_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                      RECEIVING RESULT = LV_SEND_RESULT ).
    CATCH CX_BCS INTO LX_EXCEPTION.
      LV_CHECK = GC_E.
  ENDTRY.
  COMMIT WORK.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_LIST_CONF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_LIST_CONF .
* 1)   실행 조회조건 값을 기준으로 승인 요청 내역 추출
*
*   Table : ZGTMMT1070
*
*   SELECT 조건: BANFN,BNFPO
*   WHERE 조건:
*   WERKS = 조건 입력값
*   APPUSER = 조건 입력 값
*   APPTYPE = "A" 이고 AEDAT = "" 인 구매요청번호, 구매요청 품목 추출
*
*	2) 구매요청 일반정보 조회
*   Table : EBAN
*
*   SELECT 조건: BANFN,BNFPO,BADAT,ERNAM,MATNR,TXZ01,WERKS,LGORT,MENGE,MEINS,LFDAT,
*              PREIS,WAERS,PEINH,EKORG,EKGRP,AFNAM,KNTTP,FRGKZ
*   WHERE 조건 :
*   BANFN = 1) 의 대상 요청 번호
*   BNFPO = 1) 의 대상 품목 번호
*
*	3) 구매요청 계정 지정 정보 조회
*   Table : EBKN
*
*   SELECT 조건: ANLN1,KOSTL,SAKTO,AUFNR,PS_PSP_NR
*   WHERE 조건 :
*   BANFN =1) 의 대상 구매요청 번호
*   BNFPO = 1) 의 대상구매요청 품목번호
*
*	4) Text 및 기타 정보 추출
*   3-1) NAME_TEXT : PUSER002-NAME_TEXT
*   3-2) NAME1 : T001W-NAME1
*   3-3) LGOBE : T001L-LGOBE
*   3-4) EKOTX : T024E-EKOTX
*   3-5) EKNAM : T024-EKNAM
*   "3-6) KNTTX : T163I-KNTTX "
*   3-7) TXT50 : ANLA-TXT50
*   "3-8) TXT20 : SKAT-TXT20 (SPRAS = ""3"")  "
*   "3-9) KTEXT : CSKT-KTEXT (SPRAS=""3"", KOKRS=BUKRS 입력값) "
*   3-10) KTEXT : AUFK-KTEXT
*   3-11) POST1 : PRPS-POST1
*   3-12) WGBEZ : T023T-WGBEZ
*
*
*	4) 추출한 데이터를 기준으로 ALV Display

  "초기화
  CLEAR GT_LIST[].

  "승인 대상/완료 구분조건 설정
  DATA LR_AEDAT TYPE RANGE OF ZGTMMT1070-AEDAT.
  LR_AEDAT = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = '00000000' ) ).

  SELECT
    EB~BANFN,
    EB~BNFPO,
    EB~FRGKZ,
    EB~BADAT,
    EB~ERNAM,
    EB~MATNR,
    EB~TXZ01,
    EB~WERKS,
    TW~NAME1,
    EB~LGORT,
    TL~LGOBE,
    EB~MENGE,
    EB~MEINS,
    EB~LFDAT,
    EB~PREIS,
    EB~WAERS,
    EB~PEINH,
    EB~EKORG,
    TE~EKOTX,
    EB~EKGRP,
    T4~EKNAM,
    EB~AFNAM,
    EB~KNTTP,
    TI~KNTTX,
    EK~ANLN1,
    AN~TXT50,
    EK~KOSTL,
    CT~KTEXT AS KOSTL_TEXT,
    EK~SAKTO,
    ST~TXT20 AS SAKTO_TEXT,
    EK~AUFNR,
    AK~KTEXT AS AUFNR_TEXT,
    EK~PS_PSP_PNR,
    PS~POST1
    FROM EBAN AS EB
                  INNER JOIN
              T001W AS TW ON EB~WERKS EQ TW~WERKS
                  INNER JOIN
              T001K AS TK ON TW~BWKEY EQ TK~BWKEY
                  INNER JOIN
              T001 AS T1 ON TK~BUKRS EQ T1~BUKRS
                  LEFT OUTER JOIN
              T001L AS TL ON EB~WERKS EQ TL~WERKS
                               AND EB~LGORT EQ TL~LGORT
                  LEFT OUTER JOIN
              T024E AS TE ON EB~EKORG EQ TE~EKORG
                  LEFT OUTER JOIN
              T024 AS T4 ON EB~EKGRP EQ T4~EKGRP
                  LEFT OUTER JOIN
              T163I AS TI ON EB~KNTTP EQ TI~KNTTP
                             AND TI~SPRAS EQ @SY-LANGU
                  LEFT OUTER JOIN
              EBKN AS EK ON EB~BANFN EQ EK~BANFN
                                AND EB~BNFPO EQ EK~BNFPO
                  LEFT OUTER JOIN
              ANLA AS AN ON TK~BUKRS EQ AN~BUKRS
                                AND EK~ANLN1 EQ AN~ANLN1
                                AND EK~ANLN2 EQ AN~ANLN2
                  LEFT OUTER JOIN
              CSKT AS CT ON EK~KOSTL EQ CT~KOSTL
                           AND TK~BUKRS EQ CT~KOKRS
                           AND CT~DATBI EQ '99991231'
                           AND CT~SPRAS EQ @SY-LANGU
                  LEFT OUTER JOIN
               SKAT AS ST ON EK~SAKTO EQ ST~SAKNR
                                AND T1~KTOPL EQ ST~KTOPL
                                AND ST~SPRAS EQ @SY-LANGU
                  LEFT OUTER JOIN
                AUFK AS AK ON EK~AUFNR EQ AK~AUFNR
                  LEFT OUTER JOIN
                PRPS AS PS ON EK~PS_PSP_PNR EQ PS~PSPNR
    WHERE TK~BUKRS EQ @P_BUKRS
    AND EB~WERKS IN @S_WERKS
    AND EB~EKORG IN @S_EKORG
    AND EB~EKGRP IN @S_EKGRP
    AND EB~BADAT IN @S_BADAT
    AND EB~ERNAM IN @S_ERNAM
    AND EB~BANFN IN @S_BANFN
    AND EB~MATNR IN @S_MATNR
*	Table : ZGTMMT1070
*
*	SELECT 조건: BANFN,BNFPO
*	WHERE 조건:
*	WERKS = 조건 입력값
*	APPUSER = 조건 입력 값
*	APPTYPE = "A" 이고 AEDAT = "" 인 구매요청번호, 구매요청 품목 추출
    AND EXISTS (
      SELECT ZZ~BANFN
        FROM ZGTMMT1070 AS ZZ
        WHERE ZZ~BANFN EQ EB~BANFN
             AND ZZ~BNFPO EQ EB~BNFPO
*             AND ZZ~WERKS EQ EB~WERKS ?????
             AND ZZ~APPUSER EQ @GV_APPUSER"P_APPUS
             AND ZZ~APPTYPE EQ @GC_A
             AND AEDAT IN @LR_AEDAT
    )
    ORDER BY EB~BANFN, EB~BNFPO
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

  CHECK SY-SUBRC EQ 0.

  SELECT
    V1~BNAME,
    V1~NAME_TEXT
    FROM V_USERNAME AS V1
    WHERE EXISTS (
      SELECT ZZ~ERNAM
        FROM @GT_LIST AS ZZ
        WHERE ZZ~ERNAM EQ V1~BNAME
    )
    ORDER BY V1~BNAME
    INTO TABLE @DATA(LT_USER).

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
    READ TABLE LT_USER ASSIGNING FIELD-SYMBOL(<LS_USER>) WITH KEY BNAME = <LS_LIST>-ERNAM BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_LIST>-NAME_TEXT = <LS_USER>-NAME_TEXT.
    ENDIF.

*    PREIS*MENGE/PEINH
    IF <LS_LIST>-PEINH IS NOT INITIAL.
      <LS_LIST>-ZAMT = ( <LS_LIST>-PREIS * <LS_LIST>-MENGE ) / <LS_LIST>-PEINH.
    ENDIF.
  ENDLOOP.

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
*1)	 실행 조회조건 값을 기준으로 구매요처 승인 요청 내역 추출
*
*	Table : ZGTMMT1070
*
*	SELECT 조건: BANFN,BNFPO
*	WHERE 조건:
*	WERKS = 조건 입력값
*	APPUSER = 조건 입력 값
*	APPTYPE = "A" 이고 APPSTATUS <> "" 인 구매요청번호, 구매요청 품목 추출
*
*2) 구매요청 일반정보 조회
*	Table : EBAN
*
*	SELECT 조건: BANFN,BNFPO,BADAT,ERNAM,MATNR,TXZ01,WERKS,LGORT,MENGE,MEINS,LFDAT,
*
*	WHERE 조건 :
*	BANFN = 1) 의 대상 요청 번호
*	BNFPO = 1) 의 대상 품목 번호
*
*3) 구매요청 계정 지정 정보 조회
*	Table : EBKN
*
*	SELECT 조건: ANLN1,KOSTL,SAKTO,AUFNR,PS_PSP_NR
*	WHERE 조건 :
*	BANFN =1) 의 대상 구매요청 번호
*	BNFPO = 1) 의 대상구매요청 품목번호
*
*4) Text 및 기타 정보 추출
*	3-1) NAME_TEXT : PUSER002-NAME_TEXT
*	3-2) NAME1 : T001W-NAME1
*	3-3) LGOBE : T001L-LGOBE
*	3-4) EKOTX : T024E-EKOTX
*	3-5) EKNAM : T024-EKNAM
*	"3-6) KNTTX : T163I-KNTTX	"
*	3-7) TXT50 : ANLA-TXT50
* "3-8) TXT20 : SKAT-TXT20 (SPRAS = ""3"")  "
*	"3-9) KTEXT : CSKT-KTEXT (SPRAS=""3"", KOKRS=BUKRS 입력값)	"
*	3-10) KTEXT : AUFK-KTEXT
*	3-11) POST1 : PRPS-POST1
*	3-12) WGBEZ : T023T-WGBEZ




*
*1)	 실행 조회조건 값을 기준으로 승인 요청 내역 추출
*
*	Table : ZGTMMT1070
*
*	SELECT 조건: BANFN,BNFPO
*	WHERE 조건:
*	WERKS = 조건 입력값
*	APPUSER = 조건 입력 값
*	APPTYPE = "A" 이고 AEDAT = "" 인 구매요청번호, 구매요청 품목 추출
*
*2) 구매요청 일반정보 조회
*	Table : EBAN
*
*	SELECT 조건: BANFN,BNFPO,BADAT,ERNAM,MATNR,TXZ01,WERKS,LGORT,MENGE,MEINS,LFDAT,
*            PREIS,WAERS,PEINH,EKORG,EKGRP,AFNAM,KNTTP,FRGKZ
*	WHERE 조건 :
*	BANFN = 1) 의 대상 요청 번호
*	BNFPO = 1) 의 대상 품목 번호
*
*3) 구매요청 계정 지정 정보 조회
*	Table : EBKN
*
*	SELECT 조건: ANLN1,KOSTL,SAKTO,AUFNR,PS_PSP_NR
*	WHERE 조건 :
*	BANFN =1) 의 대상 구매요청 번호
*	BNFPO = 1) 의 대상구매요청 품목번호
*
*4) Text 및 기타 정보 추출
*	3-1) NAME_TEXT : PUSER002-NAME_TEXT
*	3-2) NAME1 : T001W-NAME1
*	3-3) LGOBE : T001L-LGOBE
*	3-4) EKOTX : T024E-EKOTX
*	3-5) EKNAM : T024-EKNAM
*	"3-6) KNTTX : T163I-KNTTX	"
*	3-7) TXT50 : ANLA-TXT50
* "3-8) TXT20 : SKAT-TXT20 (SPRAS = ""3"")  "
*	"3-9) KTEXT : CSKT-KTEXT (SPRAS=""3"", KOKRS=BUKRS 입력값)	"
*	3-10) KTEXT : AUFK-KTEXT
*	3-11) POST1 : PRPS-POST1
*	3-12) WGBEZ : T023T-WGBEZ

  "초기화
  CLEAR GT_LIST[].

  SELECT
    EB~BANFN,
    EB~BNFPO,
    EB~FRGKZ,
    EB~BADAT,
    EB~ERNAM,
    EB~MATNR,
    EB~TXZ01,
    EB~WERKS,
    TW~NAME1,
    EB~LGORT,
    TL~LGOBE,
    EB~MENGE,
    EB~MEINS,
    EB~LFDAT,
    EB~PREIS,
    EB~WAERS,
    EB~PEINH,
    EB~EKORG,
    TE~EKOTX,
    EB~EKGRP,
    T4~EKNAM,
    EB~AFNAM,
    EB~KNTTP,
    TI~KNTTX,
    EK~ANLN1,
    AN~TXT50,
    EK~KOSTL,
    CT~KTEXT AS KOSTL_TEXT,
    EK~SAKTO,
    ST~TXT20 AS SAKTO_TEXT,
    EK~AUFNR,
    AK~KTEXT AS AUFNR_TEXT,
    EK~PS_PSP_PNR,
    PS~POST1
    FROM EBAN AS EB
                  INNER JOIN
              T001W AS TW ON EB~WERKS EQ TW~WERKS
                  INNER JOIN
              T001K AS TK ON TW~BWKEY EQ TK~BWKEY
                  INNER JOIN
              T001 AS T1 ON TK~BUKRS EQ T1~BUKRS
                  LEFT OUTER JOIN
              T001L AS TL ON EB~WERKS EQ TL~WERKS
                               AND EB~LGORT EQ TL~LGORT
                  LEFT OUTER JOIN
              T024E AS TE ON EB~EKORG EQ TE~EKORG
                  LEFT OUTER JOIN
              T024 AS T4 ON EB~EKGRP EQ T4~EKGRP
                  LEFT OUTER JOIN
              T163I AS TI ON EB~KNTTP EQ TI~KNTTP
                             AND TI~SPRAS EQ @SY-LANGU
                  LEFT OUTER JOIN
              EBKN AS EK ON EB~BANFN EQ EK~BANFN
                                AND EB~BNFPO EQ EK~BNFPO
                  LEFT OUTER JOIN
              ANLA AS AN ON TK~BUKRS EQ AN~BUKRS
                                AND EK~ANLN1 EQ AN~ANLN1
                                AND EK~ANLN2 EQ AN~ANLN2
                  LEFT OUTER JOIN
              CSKT AS CT ON EK~KOSTL EQ CT~KOSTL
                           AND TK~BUKRS EQ CT~KOKRS
                           AND CT~DATBI EQ '99991231'
                           AND CT~SPRAS EQ @SY-LANGU
                  LEFT OUTER JOIN
               SKAT AS ST ON EK~SAKTO EQ ST~SAKNR
                                AND T1~KTOPL EQ ST~KTOPL
                                AND ST~SPRAS EQ @SY-LANGU
                  LEFT OUTER JOIN
                AUFK AS AK ON EK~AUFNR EQ AK~AUFNR
                  LEFT OUTER JOIN
                PRPS AS PS ON EK~PS_PSP_PNR EQ PS~PSPNR
    WHERE TK~BUKRS EQ @P_BUKRS
    AND EB~WERKS IN @S_WERKS
    AND EB~EKORG IN @S_EKORG
    AND EB~EKGRP IN @S_EKGRP
    AND EB~BADAT IN @S_BADAT
    AND EB~ERNAM IN @S_ERNAM
    AND EB~BANFN IN @S_BANFN
    AND EB~MATNR IN @S_MATNR
*	Table : ZGTMMT1070
*
*	SELECT 조건: BANFN,BNFPO
*	WHERE 조건:
*	WERKS = 조건 입력값
*	APPUSER = 조건 입력 값
*	APPTYPE = "A" 이고 AEDAT = "" 인 구매요청번호, 구매요청 품목 추출
    AND EXISTS (
      SELECT ZZ~BANFN
        FROM ZGTMMT1070 AS ZZ
        WHERE ZZ~BANFN EQ EB~BANFN
             AND ZZ~BNFPO EQ EB~BNFPO
*             AND ZZ~WERKS EQ EB~WERKS ?????
             AND ZZ~APPUSER EQ @GV_APPUSER"P_APPUS
             AND ZZ~APPTYPE EQ @GC_A
             AND ZZ~APPSTATUS NE @SPACE
    )
    ORDER BY EB~BANFN, EB~BNFPO
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

  CHECK SY-SUBRC EQ 0.

  SELECT
    V1~BNAME,
    V1~NAME_TEXT
    FROM V_USERNAME AS V1
    WHERE EXISTS (
      SELECT ZZ~ERNAM
        FROM @GT_LIST AS ZZ
        WHERE ZZ~ERNAM EQ V1~BNAME
    )
    ORDER BY V1~BNAME
    INTO TABLE @DATA(LT_USER).

*  승인상태                 APPSTATUS ZGTMMT1070-APPSTATUS  "APPSTATUS='C' 이면 ""승인완료""
*APPSTATUS='R' 이면 ""승인반려"""

  SELECT
    Z1~BANFN,
    Z1~BNFPO,
    Z1~APPSTATUS
    FROM ZGTMMT1070 AS Z1
    WHERE EXISTS (
      SELECT @ABAP_TRUE
        FROM @GT_LIST AS ZZ
        WHERE ZZ~BANFN EQ Z1~BANFN
           AND ZZ~BNFPO EQ Z1~BNFPO
    )
    AND Z1~APPTYPE EQ @GC_A
    ORDER BY Z1~BANFN, Z1~BNFPO
    INTO TABLE @DATA(LT_APP).


  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
    READ TABLE LT_USER ASSIGNING FIELD-SYMBOL(<LS_USER>) WITH KEY BNAME = <LS_LIST>-ERNAM BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_LIST>-NAME_TEXT = <LS_USER>-NAME_TEXT.
    ENDIF.

*    PREIS*MENGE/PEINH
    IF <LS_LIST>-PEINH IS NOT INITIAL.
      <LS_LIST>-ZAMT = ( <LS_LIST>-PREIS * <LS_LIST>-MENGE ) / <LS_LIST>-PEINH.
    ENDIF.


*  승인상태                 APPSTATUS ZGTMMT1070-APPSTATUS  "APPSTATUS='C' 이면 ""승인완료""
*APPSTATUS='R' 이면 ""승인반려"""
    READ TABLE LT_APP ASSIGNING FIELD-SYMBOL(<LS_APP>) WITH KEY BANFN = <LS_LIST>-BANFN
                                                                                                   BNFPO = <LS_LIST>-BNFPO BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      CASE <LS_APP>-APPSTATUS.
        WHEN GC_C.
          <LS_LIST>-APPSTATUS = TEXT-X01. "승인완료
        WHEN GC_R.
          <LS_LIST>-APPSTATUS = TEXT-X02. "승인반려
      ENDCASE.
    ENDIF.

  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_PR_REJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_PR_REJECT .

*2-1) 라인은 다중선택 가능 (전체선택 포함)
*2-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
*2-3) 선택한 라인이 존재하는 경우 POP-UP 확인 후 이력 테이블 업데이트

  DATA:
    LV_CHECK TYPE C LENGTH 1,
    LV_ANS   TYPE C LENGTH 1,
    LT_ROW   TYPE LVC_T_ROID,
    LT_LOG   TYPE STANDARD TABLE OF ZGTMMT1070,
    LT_LIST  TYPE TY_T_LIST.

  DATA:
    LV_CNT_S TYPE INT4,
    LV_CNT_E TYPE INT4.

  CALL METHOD GO_GRID_100->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW.
  DELETE LT_ROW WHERE ROW_ID LE 0.
  IF LT_ROW[] IS INITIAL.
*2-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
    MESSAGE E163.
  ENDIF.
*2-3) 선택한 라인이 존재하는 경우 POP-UP 확인 후 이력 테이블 업데이트
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT1
      TEXT_QUESTION = TEXT-Q02
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.

*: 구매요청 승인 이력 테이블 업데이트
*필드                   ZGTMMT1070
*BANFN
*BANFPO
*APPTYPE
*APPUSER
*MAILSEND
*APPSATTUS                    "R"
*ERDAT
*ERDAT_LOCAL
*ERTIM
*ERTIM_LOCAL
*AEDAT                    SY-DATUM
*AEDAT_LOCAL                    SY-DATLO
*AEZET                    SY-UZEIT
*AEZET_LOCAL                    SY-TIMLO
*

  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    "로그 저장용
    LT_LOG = VALUE #( BASE LT_LOG ( BANFN = <LS_LIST>-BANFN
                                                           BNFPO = <LS_LIST>-BNFPO ) ).
    "이메일 전송용
    APPEND <LS_LIST> TO LT_LIST.
    LV_CNT_S += 1.

  ENDLOOP.

  IF LT_LOG[] IS NOT INITIAL.
    "이력 저장
    PERFORM F_SAVE_APPR_LOG USING LT_LOG GC_R.
    "이메일 전송
    PERFORM F_SEND_EMAIL USING LT_LIST GC_R.
  ENDIF.

  "메세지 처리
  "전체 데이터: &1 성공: &2 실패: &3
  DATA(LV_TOT) = LV_CNT_S + LV_CNT_E.
  MESSAGE S073 WITH LV_TOT LV_CNT_S LV_CNT_E.

ENDFORM.
