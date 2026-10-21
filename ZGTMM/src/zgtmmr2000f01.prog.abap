*&---------------------------------------------------------------------*
*& Include          ZGTMMR2010F01
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

  "I/F 시스템
  DATA : LT_IFNO TYPE VRM_VALUES.

  " 1) SELECT FLD_01,FLD_02 INTO Internal Table IFSYST
*   FROM ZGTPPT1010 WHERE MODULE_KIND = 'PP' AND CODEGRP = '0010'.
* 2) IFSYST FLD_01,FLD_02 기준 중복 제거"
  SELECT DISTINCT
         FLD_01 AS KEY,
         FLD_02 AS TEXT
    FROM ZGTPPT1010
    INTO CORRESPONDING FIELDS OF TABLE @LT_IFNO
   WHERE MODULE_KIND EQ @GC_PP
   AND CODEGRP EQ @GC_0010.

  "값이 있는 경우
  IF LT_IFNO[] IS NOT INITIAL.
    "정렬
    SORT LT_IFNO BY KEY.
    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        ID     = 'P_IFSYT'
        VALUES = LT_IFNO.

    "기본 값 설정
    READ TABLE LT_IFNO WITH KEY KEY = 'KSRM' TRANSPORTING NO FIELDS.
    IF SY-SUBRC EQ 0.
      P_IFSYT = 'KSRM'.
    ENDIF.
  ENDIF.

  "I/F Date
  IF S_IFDAT[] IS INITIAL.
    S_IFDAT[] = VALUE #( ( SIGN = 'I' OPTION = 'BT' LOW = SY-DATLO - 1  HIGH = SY-DATLO ) ).
  ENDIF.

  "생성/변경일
  IF S_ERDAT[] IS INITIAL.
    S_ERDAT[] = VALUE #( ( SIGN = 'I' OPTION = 'BT' LOW = SY-DATLO - 1  HIGH = SY-DATLO ) ).
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

    "활성화/비활성화
    CASE SCREEN-GROUP1.
      WHEN 'ERD' OR 'BAT'.
        IF P_ILOG EQ ABAP_TRUE.
          SCREEN-ACTIVE = 0.
        ELSE.
          SCREEN-ACTIVE = 1.
        ENDIF.

      WHEN 'IFD' OR  'FRC' OR 'LST'.
        IF P_ILOG EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
    ENDCASE.

    "필수입력 표시
    CASE SCREEN-GROUP1.
      WHEN 'IFD' OR 'ERD'.
        IF SCREEN-GROUP3 EQ 'LOW'.
          SCREEN-REQUIRED = 2.
        ENDIF.

      WHEN 'IFS'.
        IF P_ILOG EQ SPACE.
          SCREEN-REQUIRED = 2.
        ENDIF.

      WHEN 'WRK'.
        IF SCREEN-GROUP3 EQ 'LOW' AND P_ILOG EQ SPACE.
          SCREEN-REQUIRED = 2.
        ENDIF.
    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

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

  "플랜트
  SELECT SINGLE
    WERKS
    FROM T001W
    WHERE WERKS IN @S_WERKS
    INTO @DATA(LV_CHK1).
  IF SY-SUBRC NE 0.
    MESSAGE E013 WITH TEXT-H08.
  ENDIF.

  "구매요청번호
  IF S_BANFN[] IS NOT INITIAL.
    SELECT SINGLE
      BANFN
      FROM EBAN
      WHERE BANFN IN @S_BANFN
      INTO @DATA(LV_CHK2).
    IF SY-SUBRC NE 0.
      MESSAGE E013 WITH TEXT-H01.
    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CHECK_AUTH.
  CLEAR GV_ERR.

  "플랜트 권한 체크..
  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
  ID 'WERKS' FIELD S_WERKS-LOW.

  IF SY-SUBRC NE 0.
    "플랜트 &에 대한 권한이 없습니다.
    MESSAGE E000 WITH '플랜트[' S_WERKS-LOW '] 에 대한 권한이 없습니다.'.
    GV_ERR = ABAP_TRUE.
    STOP.
  ENDIF.

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

  "필수 입력 값 점검
  PERFORM F_CHECK_INPUT_REQU_VALUES_1000.

  "데이터 조회
  CASE ABAP_TRUE.
    WHEN P_SEND. "CASE 1 : RADIO BUTTON = "Data 전송" 인 경우 Data Gathering

      "PR 데이터 조회
      PERFORM F_GET_PR_DATA.

    WHEN P_ILOG. "로그조회

      "로그 데이터 조회
      PERFORM F_GET_IF_LOG_DATA.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_INPUT_REQU_VALUES_1000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CHECK_INPUT_REQU_VALUES_1000 .

  CASE ABAP_TRUE.
    WHEN P_ILOG. "I/F Log 조회
      IF S_IFDAT[] IS INITIAL.
        MESSAGE S018 DISPLAY LIKE GC_E.
        LEAVE LIST-PROCESSING.
      ENDIF.
    WHEN P_SEND. "Data 전송
      IF P_IFSYT IS INITIAL
        OR S_WERKS[] IS INITIAL
        OR S_ERDAT[] IS INITIAL.
        MESSAGE S018 DISPLAY LIKE GC_E.
        LEAVE LIST-PROCESSING.
      ENDIF.
  ENDCASE.

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
  IF GT_PR[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE GC_E.
    LEAVE LIST-PROCESSING.
  ENDIF.

  "배치실행이 아닌 경우만 진행
  IF P_BAT EQ ABAP_TRUE AND P_SEND EQ ABAP_TRUE.
    "데이터 전송
    PERFORM F_SEND.
  ELSE.
    CHECK SY-BATCH NE ABAP_TRUE. "배치 실행이 아닌 경우
    "Screen 100 이동
    CALL SCREEN 100.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SEND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SEND .

  DATA:
    LV_DEST    TYPE ZDEST,
    LT_SEND    TYPE STANDARD TABLE OF TY_PR,
    LT_BANFN   TYPE STANDARD TABLE OF TY_BANFN,

    LT_SYS     TYPE TY_T_SYS,
    LV_CNT_S   TYPE INT4,
    LV_CNT_E   TYPE INT4,
    LV_CNT_RUN TYPE INT4,
    LV_RESULT  TYPE ZO_RESULT,
    LV_MESSAGE TYPE ZO_MESSAGE.

  "선택 여부 점검
  PERFORM F_CHECK_SEL_DATA.

  "대상 시스템 설정
  PERFORM F_SET_TARGET_SYSTEM_LIST CHANGING LT_SYS.

*  *4-4) 선택 된 라인이 존재하면 Pop Up 메세지 실행 후 전송
* 4-5) P_BATCH = 'X'인 경우는 화면 실행 및 POP-UP 없이 조회된 전체 데이터 전송
  IF ( SY-BATCH EQ SPACE AND P_BAT EQ SPACE )
    OR P_ILOG EQ ABAP_TRUE.

    DATA LV_ANS TYPE C LENGTH 1.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR      = TEXT-TT4
        TEXT_QUESTION = TEXT-Q01
      IMPORTING
        ANSWER        = LV_ANS.
    CHECK LV_ANS EQ GC_1.
  ENDIF.

  "대상 PR의 최종 IF 점검 (I/F 로그인 경우)
  IF P_ILOG EQ ABAP_TRUE.
    PERFORM F_CHECK_LAST_IF.
  ENDIF.

  "4) 전송 대상 진행 상태 점검
  PERFORM F_CHECK_ZGTMMT2000.

  LOOP AT LT_SYS ASSIGNING FIELD-SYMBOL(<LS_SYS>).

    "전송 데이터 설정
    IF ( SY-BATCH EQ SPACE AND P_BAT EQ SPACE )
      OR P_ILOG EQ ABAP_TRUE.
      "일반 실행 인 경우
      PERFORM F_SET_SEND_DATA USING <LS_SYS> CHANGING LT_SEND LT_BANFN.
    ELSE.
      "배치 인 경우
      PERFORM F_SET_BAT_SEND_DATA USING <LS_SYS> CHANGING LT_SEND LT_BANFN.
*      PERFORM F_SET_BAT_SEND_DATA TABLES LT_HEAD LT_ITEM USING <LS_SYS>.
    ENDIF.

    "실행 건 계산
    LV_CNT_RUN = LINES( LT_BANFN ) DIV GC_MAX.
    IF LINES( LT_BANFN ) MOD GC_MAX NE 0.
      LV_CNT_RUN += 1.
    ENDIF.

    "분할 전송
    DO LV_CNT_RUN TIMES.
      "RFC 전송 실행
      PERFORM F_RUN_SEND_RFC USING SY-INDEX
                                                             <LS_SYS>
                                                             LT_BANFN
                                           CHANGING  LT_SEND
                                                             LV_CNT_S LV_CNT_E.
    ENDDO.

  ENDLOOP.

  "메세지 처리
  "전체 데이터: &1 성공: &2 실패: &3
  DATA(LV_TOT) = LV_CNT_S + LV_CNT_E.
  MESSAGE S073 WITH LV_TOT LV_CNT_S LV_CNT_E.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_HEAD
*&      --> LT_ITEM
*&      <-- LV_CHK
*&---------------------------------------------------------------------*
FORM F_SET_SEND_DATA  USING PS_SYS TYPE TY_SYS
                                          CHANGING CT_SEND TYPE TY_T_PR
                                                           CT_BANFN TYPE TY_T_BANFN.

  CLEAR:
    CT_SEND[],
    CT_BANFN[].

  "정렬
  SORT GT_PR BY SYSTEM_ID BUKRS BANFN.

  "선택 한 라인 조회
  DATA LT_ROW TYPE LVC_T_ROID.
  CALL METHOD GO_GRID_IT->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW.

  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    CHECK <LS_ROW>-ROW_ID GT 0.
    READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    "대상 시스템
    CHECK <LS_ITEM>-SYSTEM_ID = PS_SYS-SYSTEM_ID
        AND <LS_ITEM>-BUKRS = PS_SYS-BUKRS.

    "아이템 데이터 설정
    READ TABLE GT_PR WITH KEY SYSTEM_ID = <LS_ITEM>-SYSTEM_ID
                                                  BUKRS = <LS_ITEM>-BUKRS
                                                  BANFN = <LS_ITEM>-BANFN " .BINARY SEARCH TRANSPORTING NO FIELDS. "2026.05.27 라인별 전송 로직 추가
                                                  BNFPO = <LS_ITEM>-BNFPO ASSIGNING FIELD-SYMBOL(<LS_PR>). "2026.05.27 라인별 전송 로직 추가
    IF SY-SUBRC EQ 0.

      "<-- 2026.05.27 라인별 전송 로직 추가
      IF <LS_PR>-SYSTEM_ID NE <LS_ITEM>-SYSTEM_ID
        OR <LS_PR>-BUKRS NE <LS_ITEM>-BUKRS
        OR <LS_PR>-BANFN NE <LS_ITEM>-BANFN.
        EXIT.
      ENDIF.

      CT_SEND[] = VALUE #( BASE CT_SEND[] ( <LS_PR> ) ).

      " 기존 로직 주석처리 (동일 PR 모두 선택)
*      LOOP AT GT_PR ASSIGNING FIELD-SYMBOL(<LS_PR>) FROM SY-TABIX.
*        IF <LS_PR>-SYSTEM_ID NE <LS_ITEM>-SYSTEM_ID
*          OR <LS_PR>-BUKRS NE <LS_ITEM>-BUKRS
*          OR <LS_PR>-BANFN NE <LS_ITEM>-BANFN.
*          EXIT.
*        ENDIF.
*
*        "라인추가
*        CT_SEND[] = VALUE #( BASE CT_SEND[] ( <LS_PR> ) ).
*
*      ENDLOOP.
      "2026.05.27 라인별 전송 로직 추가-->

    ENDIF.
  ENDLOOP.

  "PR번호 설정
  CHECK CT_SEND[] IS NOT INITIAL.
  ##ITAB_KEY_IN_SELECT
  ##ITAB_DB_SELECT
  SELECT DISTINCT
    ZZ~BANFN
    FROM @CT_SEND AS ZZ
    INTO TABLE @CT_BANFN.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_BAT_SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_HEAD
*&      --> LT_ITEM
*&---------------------------------------------------------------------*
FORM F_SET_BAT_SEND_DATA  USING PS_SYS TYPE TY_SYS
                                                  CHANGING CT_SEND TYPE TY_T_PR
                                                                   CT_BANFN TYPE TY_T_BANFN.

  CLEAR:
    CT_SEND[],
    CT_BANFN[].

  LOOP AT GT_PR ASSIGNING FIELD-SYMBOL(<LS_PR>).

    "대상 시스템
    CHECK <LS_PR>-SYSTEM_ID = PS_SYS-SYSTEM_ID
        AND <LS_PR>-BUKRS = PS_SYS-BUKRS.

    "라인추가
    CT_SEND[] = VALUE #( BASE CT_SEND[] ( <LS_PR> ) ).

  ENDLOOP.


  "PR번호 설정
  CHECK CT_SEND[] IS NOT INITIAL.
  ##ITAB_DB_SELECT
  ##ITAB_KEY_IN_SELECT
  SELECT DISTINCT
    ZZ~BANFN
    FROM @CT_SEND AS ZZ
    INTO TABLE @CT_BANFN.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SAVE_IF_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_HEAD
*&      --> LT_ITEM
*&      --> LV_RET
*&      --> LV_MSG
*&---------------------------------------------------------------------*
FORM F_SAVE_IF_LOG  USING    PV_RET
                                                  PV_MSG
                                                  PS_SYS TYPE TY_SYS
                                                  PT_LOG TYPE TY_T_PR.

  DATA:
    LS_LOG      TYPE ZGTMMT9000,
    LS_LOG_DATA TYPE ZGTMMT9260,
    LT_LOG_DATA TYPE STANDARD TABLE OF ZGTMMT9260,
    LS_LOG_STAT TYPE ZGTMMT2000,
    LT_LOG_STAT TYPE STANDARD TABLE OF ZGTMMT2000.


  GET TIME STAMP FIELD LS_LOG-ZIFKEY.
  LS_LOG-ZIFNO       = GC_MM00028.
  LS_LOG-SYSTEM_ID   = PS_SYS-SYSTEM_ID.
  LS_LOG-ZSTAT       = PV_RET.
  LS_LOG-MESSAGE     = PV_MSG.
  LS_LOG-IFDAT       = SY-DATLO.
  LS_LOG-IFTIM       = SY-TIMLO.
  LS_LOG-IFNAM       = SY-UNAME.
  LS_LOG-ERDAT       = SY-DATUM.
  LS_LOG-ERDAT_LOCAL = SY-DATLO.
  LS_LOG-ERTIM       = SY-UZEIT.
  LS_LOG-ERTIM_LOCAL = SY-TIMLO.
  LS_LOG-ERNAM       = SY-UNAME.

  LT_LOG_DATA[] = VALUE #( FOR <LS_LOG> IN PT_LOG
                       ( VALUE #( BASE CORRESPONDING #( <LS_LOG> )
                                  ZIFKEY  = LS_LOG-ZIFKEY
                                  SYSTEM_ID = LS_LOG-SYSTEM_ID ) ) ).


*4) 전송상태값 S 인 구매요청 항번 정보 ZGTMMT2000 테이블 추가 업데이트
  IF PV_RET EQ GC_S.
    ##ITAB_DB_SELECT
    ##ITAB_KEY_IN_SELECT
    SELECT
      ST~BANFN,
      ST~BNFPO,
      ST~FLAG,
      ST~ERDAT,
      ST~ERDAT_LOCAL,
      ST~ERTIM,
      ST~ERTIM_LOCAL,
      ST~ERNAM
      FROM ZGTMMT2000 AS ST
      WHERE EXISTS (
        SELECT ZZ~BANFN, ZZ~BNFPO
          FROM @LT_LOG_DATA AS ZZ
          WHERE ZZ~BANFN EQ ST~BANFN
             AND ZZ~BNFPO EQ ST~BNFPO
      )
      ORDER BY ST~BANFN, ST~BNFPO
      INTO TABLE @DATA(LT_ORG).

    LOOP AT LT_LOG_DATA ASSIGNING FIELD-SYMBOL(<LS_LOG_DATA>).
      CLEAR LS_LOG_STAT.
      LS_LOG_STAT-BANFN = <LS_LOG_DATA>-BANFN.
      LS_LOG_STAT-BNFPO = <LS_LOG_DATA>-BNFPO.
      READ TABLE LT_ORG ASSIGNING FIELD-SYMBOL(<LS_ORG>) WITH KEY BANFN = <LS_LOG_DATA>-BANFN
                                                                                                    BNFPO = <LS_LOG_DATA>-BNFPO
                                                                                                    BINARY SEARCH.

      IF SY-SUBRC EQ 0.
        LS_LOG_STAT = CORRESPONDING #( BASE ( LS_LOG_STAT ) <LS_ORG> ).
      ELSE.
        LS_LOG_STAT-ERDAT = SY-DATUM.
        LS_LOG_STAT-ERDAT_LOCAL = SY-DATLO.
        LS_LOG_STAT-ERTIM = SY-UZEIT.
        LS_LOG_STAT-ERTIM_LOCAL = SY-TIMLO.
        LS_LOG_STAT-ERNAM = SY-UNAME.
      ENDIF.

      LS_LOG_STAT-AEDAT = SY-DATUM.
      LS_LOG_STAT-AEDAT_LOCAL = SY-DATLO.
      LS_LOG_STAT-AETIM = SY-UZEIT.
      LS_LOG_STAT-AETIM_LOCAL = SY-TIMLO.
      LS_LOG_STAT-AENAM = SY-UNAME.
      APPEND LS_LOG_STAT TO LT_LOG_STAT.
    ENDLOOP.

    MODIFY ZGTMMT2000 FROM TABLE LT_LOG_STAT.
  ENDIF.


  MODIFY ZGTMMT9260 FROM TABLE LT_LOG_DATA.
  MODIFY ZGTMMT9000 FROM LS_LOG.
  COMMIT WORK.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_IF_LOG_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_IF_LOG_DATA .

  "초기화
  CLEAR:
    GT_PR[],
    GT_HEAD[],
    GT_ITEM[].

  DATA:
    LR_SYSTEM_ID TYPE RANGE OF ZGTMMT9000-SYSTEM_ID,
    LR_ZSTAT     TYPE RANGE OF ZGTMMT9000-ZSTAT.

  "I/F 시스템
  IF P_IFSYT IS NOT INITIAL.
    LR_SYSTEM_ID = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = P_IFSYT ) ).
  ENDIF.

  "상태
  IF P_FRC NE ABAP_TRUE.
    LR_ZSTAT = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = GC_E ) ).
  ENDIF.

  IF P_LST EQ ABAP_TRUE. "최종 데이터 조회
    WITH
      +V_LAST AS (
          SELECT
           Z1~SYSTEM_ID,
           Z2~BANFN,
           Z2~BNFPO,
           MAX( Z1~ZIFKEY ) AS ZIFKEY
          FROM ZGTMMT9000 AS Z1
                        INNER JOIN
                    ZGTMMT9260 AS Z2 ON Z1~ZIFKEY EQ Z2~ZIFKEY
                                                 AND Z1~SYSTEM_ID EQ Z2~SYSTEM_ID
          WHERE Z1~ZIFNO EQ @GC_MM00028
          AND Z1~SYSTEM_ID IN @LR_SYSTEM_ID
          AND Z1~ERDAT IN @S_IFDAT
          AND Z2~WERKS IN @S_WERKS
          AND Z2~BANFN IN @S_BANFN
          GROUP BY Z1~SYSTEM_ID, Z2~BANFN, Z2~BNFPO
      )
    SELECT
  "I/F
      Z1~ZIFNO,
      Z1~ZIFKEY,
      Z1~SYSTEM_ID,
      Z1~ZSTAT,
      Z1~MESSAGE,
      Z1~IFNAM,
  "PR
      Z2~BANFN,
      Z2~BNFPO,
      Z2~BUKRS,
      Z2~ERNAM,
      Z2~BSART,
      Z2~BATXT,
      Z2~BADAT,
      Z2~ERDAT,
      Z2~MATNR,
      Z2~ZZMAKTX80,
      Z2~WERKS,
      Z2~NAME1,
      Z2~LGORT,
      Z2~LGOBE,
      Z2~PSTLZ,
      Z2~ORT01,
      Z2~STRAS,
      Z2~MENGE,
      Z2~MEINS,
      Z2~LFDAT,
      Z2~PREIS,
      Z2~WAERS,
      Z2~PEINH,
      Z2~EKORG,
      Z2~EKOTX,
      Z2~EKGRP,
      Z2~EKNAM,
      Z2~LIFNR,
      Z2~FLIEF,
      Z2~LOEKZ,
      Z2~ITEMTEXT
      FROM ZGTMMT9000 AS Z1
                    INNER JOIN
                ZGTMMT9260 AS Z2 ON Z1~ZIFKEY EQ Z2~ZIFKEY
                                             AND Z1~SYSTEM_ID EQ Z2~SYSTEM_ID
                    INNER JOIN
                +V_LAST AS V1 ON Z2~SYSTEM_ID EQ V1~SYSTEM_ID
                                  AND Z2~ZIFKEY EQ V1~ZIFKEY
                                  AND Z2~BANFN EQ V1~BANFN
                                  AND Z2~BNFPO EQ V1~BNFPO
      WHERE Z1~ZSTAT IN @LR_ZSTAT "I/F 성공 데이터 포함
      ORDER BY Z1~ZIFKEY DESCENDING, Z2~BANFN ASCENDING, Z2~BNFPO ASCENDING
      INTO CORRESPONDING FIELDS OF TABLE @GT_PR.

  ELSE.

    SELECT
  "I/F
      Z1~ZIFNO,
      Z1~ZIFKEY,
      Z1~SYSTEM_ID,
      Z1~ZSTAT,
      Z1~MESSAGE,
      Z1~IFNAM,
  "PR
      Z2~BANFN,
      Z2~BNFPO,
      Z2~BUKRS,
      Z2~ERNAM,
      Z2~BSART,
      Z2~BATXT,
      Z2~BADAT,
      Z2~ERDAT,
      Z2~MATNR,
      Z2~ZZMAKTX80,
      Z2~WERKS,
      Z2~NAME1,
      Z2~LGORT,
      Z2~LGOBE,
      Z2~PSTLZ,
      Z2~ORT01,
      Z2~STRAS,
      Z2~MENGE,
      Z2~MEINS,
      Z2~LFDAT,
      Z2~PREIS,
      Z2~WAERS,
      Z2~ZAMT,
      Z2~PEINH,
      Z2~EKORG,
      Z2~EKOTX,
      Z2~EKGRP,
      Z2~EKNAM,
      Z2~LIFNR,
      Z2~FLIEF,
      Z2~LOEKZ,
      Z2~ITEMTEXT
      FROM ZGTMMT9000 AS Z1
                    INNER JOIN
                ZGTMMT9260 AS Z2 ON Z1~ZIFKEY EQ Z2~ZIFKEY
                                             AND Z1~SYSTEM_ID EQ Z2~SYSTEM_ID
      WHERE Z1~ZIFNO EQ @GC_MM00028
      AND Z1~SYSTEM_ID IN @LR_SYSTEM_ID
      AND Z1~ERDAT IN @S_IFDAT
      AND Z2~WERKS IN @S_WERKS
      AND Z2~BANFN IN @S_BANFN
      AND Z1~ZSTAT IN @LR_ZSTAT "I/F 성공 데이터 포함
      ORDER BY Z1~ZIFKEY DESCENDING, Z2~BANFN ASCENDING, Z2~BNFPO ASCENDING
      INTO CORRESPONDING FIELDS OF TABLE @GT_PR.

  ENDIF.

  "데이터가 존재 하면 진행
  CHECK GT_PR[] IS NOT INITIAL.

  "시스템 내역
  SELECT DISTINCT
         FLD_01,
         FLD_02
    FROM ZGTPPT1010
   WHERE MODULE_KIND EQ @GC_PP
   AND CODEGRP EQ @GC_0010
   ORDER BY FLD_01
   INTO TABLE @DATA(LT_TXT).

  "GT_HEAD
  ##ITAB_DB_SELECT
  ##ITAB_KEY_IN_SELECT
  SELECT DISTINCT
    "I/F
      ZZ~ZIFNO,
      ZZ~ZIFKEY,
      ZZ~SYSTEM_ID,
      ZZ~ZSTAT,
      ZZ~MESSAGE,
      ZZ~IFNAM
    FROM @GT_PR AS ZZ
    INTO CORRESPONDING FIELDS OF TABLE @GT_HEAD.

  LOOP AT GT_HEAD ASSIGNING FIELD-SYMBOL(<LS_HEAD>).
    READ TABLE LT_TXT ASSIGNING FIELD-SYMBOL(<LS_TXT>) WITH KEY FLD_01 = <LS_HEAD>-SYSTEM_ID BINARY SEARCH.
    CHECK SY-SUBRC EQ 0.
    <LS_HEAD>-SYSTEM_TXT = <LS_TXT>-FLD_02.
  ENDLOOP.

  "이름/주소
  ##ITAB_DB_SELECT
  ##ITAB_KEY_IN_SELECT
  SELECT
    V1~BNAME,
    V1~NAME_TEXT,
    V1~SMTP_ADDR
    FROM P_USER002 AS V1
    WHERE EXISTS (
      SELECT ZZ~ERNAM
        FROM @GT_PR AS ZZ
        WHERE ZZ~ERNAM EQ V1~BNAME
    )
    ORDER BY V1~BNAME
    INTO TABLE @DATA(LT_USER).


  LOOP AT GT_PR ASSIGNING FIELD-SYMBOL(<LS_PR>).

    READ TABLE LT_USER ASSIGNING FIELD-SYMBOL(<LS_USER>) WITH KEY BNAME = <LS_PR>-ERNAM BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_PR>-ENAME = <LS_USER>-NAME_TEXT.
      <LS_PR>-MAILADD = <LS_USER>-SMTP_ADDR.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_DATA_ITEM_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_HEAD>_BANFN
*&      --> <LS_HEAD>_ZIFKEY
*&      --> <LS_HEAD>_SYSTEM_ID
*&---------------------------------------------------------------------*
FORM F_SET_ALV_DATA_ITEM_LOG  USING PV_ZIFKEY
                                                                  PV_SYSTEM_ID.

  CLEAR GT_ITEM[].
  ##ITAB_DB_SELECT
  ##ITAB_KEY_IN_SELECT
  SELECT
    ZZ~*
    FROM @GT_PR AS ZZ
    WHERE ZZ~ZIFKEY EQ @PV_ZIFKEY
    AND ZZ~SYSTEM_ID EQ @PV_SYSTEM_ID
    INTO CORRESPONDING FIELDS OF TABLE @GT_ITEM.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_TARGET_SYSTEM_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SYS
*&---------------------------------------------------------------------*
FORM F_SET_TARGET_SYSTEM_LIST  CHANGING CT_SYS TYPE TY_T_SYS.

  "초기화
  CLEAR CT_SYS[].

  "전송 대상 시스템 설정
*  IF P_SEND EQ ABAP_TRUE.
*    CT_SYS[] = VALUE #( ( SYSTEM_ID = P_IFSYT ) ).
*  ELSE.
  IF ( SY-BATCH EQ SPACE AND P_BAT EQ SPACE )
    OR P_ILOG EQ ABAP_TRUE.

    "선택 한 라인 조회
    DATA LT_ROW TYPE LVC_T_ROID.
    CALL METHOD GO_GRID_IT->GET_SELECTED_ROWS
      IMPORTING
        ET_ROW_NO = LT_ROW.

    LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
      CHECK <LS_ROW>-ROW_ID GT 0.
      READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>) INDEX <LS_ROW>-ROW_ID.
      CHECK SY-SUBRC EQ 0.
      CT_SYS[] = VALUE #( BASE CT_SYS[] ( SYSTEM_ID = <LS_ITEM>-SYSTEM_ID
                                                                  BUKRS = <LS_ITEM>-BUKRS ) ).
    ENDLOOP.

    SORT CT_SYS BY SYSTEM_ID BUKRS.
    DELETE ADJACENT DUPLICATES FROM CT_SYS COMPARING SYSTEM_ID BUKRS.

  ELSE.
    ##ITAB_DB_SELECT
    ##ITAB_KEY_IN_SELECT
    "조회 된 전체 시스템
    SELECT DISTINCT ZZ~SYSTEM_ID, ZZ~BUKRS
      FROM @GT_PR AS ZZ
       INTO TABLE @CT_SYS.

  ENDIF.
*  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_LAST_IF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CHECK_LAST_IF .

  "초기화
  CLEAR GT_LAST[].

  "선택 한 라인 조회
  DATA LT_ROW TYPE LVC_T_ROID.
  CALL METHOD GO_GRID_IT->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW.

  DATA:
    BEGIN OF LS_KEY,
      SYSTEM_ID TYPE ZGTMMT9000-SYSTEM_ID,
      BANFN     TYPE EBAN-BANFN,
    END OF LS_KEY,
    LT_KEY LIKE STANDARD TABLE OF LS_KEY.

  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    CHECK <LS_ROW>-ROW_ID GT 0.
    READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.
    LT_KEY[] = VALUE #( BASE LT_KEY ( SYSTEM_ID = <LS_ITEM>-SYSTEM_ID BANFN = <LS_ITEM>-BANFN ) ).
  ENDLOOP.

  "전송 대상 시스템/PR 번호 별 마지막 I/F key 조회
  ##ITAB_DB_SELECT
  ##ITAB_KEY_IN_SELECT
  SELECT
    Z1~SYSTEM_ID,
    Z2~BANFN,
    MAX( Z1~ZIFKEY ) AS ZIFKEY
    FROM ZGTMMT9000 AS Z1
                  INNER JOIN
              ZGTMMT9260 AS Z2 ON Z1~ZIFKEY EQ Z2~ZIFKEY
                                           AND Z1~SYSTEM_ID EQ Z2~SYSTEM_ID
    WHERE Z1~ZIFNO EQ @GC_MM00028
    AND EXISTS (
        SELECT ZZ~SYSTEM_ID, BANFN
          FROM @LT_KEY AS ZZ
          WHERE ZZ~SYSTEM_ID EQ Z1~SYSTEM_ID
             AND ZZ~BANFN EQ Z2~BANFN
    )
    GROUP BY Z1~SYSTEM_ID, Z2~BANFN
    INTO TABLE @GT_LAST.

  LOOP AT LT_ROW ASSIGNING <LS_ROW>.
    CHECK <LS_ROW>-ROW_ID GT 0.
    READ TABLE GT_ITEM ASSIGNING <LS_ITEM> INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.
    READ TABLE GT_LAST WITH TABLE KEY SYSTEM_ID = <LS_ITEM>-SYSTEM_ID
                                                                BANFN = <LS_ITEM>-BANFN
                                                                ZIFKEY = <LS_ITEM>-ZIFKEY TRANSPORTING NO FIELDS.
    CHECK SY-SUBRC NE 0.
    MESSAGE E049. "최종이 아닌 데이터는 전송할 수 없습니다.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ITEM_LINE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_PR>
*&      <-- LS_ITEM
*&---------------------------------------------------------------------*
FORM F_SET_ITEM_LINE_DATA  USING    PS_PR TYPE TY_PR
                           CHANGING PS_ITEM TYPE ZGTMMS2000.

  CLEAR PS_ITEM.

  PS_ITEM = CORRESPONDING #( PS_PR ).

  "금액 -> 문자열
  WRITE:
  PS_PR-PREIS TO PS_ITEM-PREIS CURRENCY PS_PR-WAERS NO-GROUPING LEFT-JUSTIFIED,
  PS_PR-ZAMT TO PS_ITEM-ZAMT CURRENCY PS_PR-WAERS NO-GROUPING LEFT-JUSTIFIED.

  "Alpha conversion
  PS_ITEM-BANFN = |{ PS_ITEM-BANFN ALPHA = OUT }|.
  PS_ITEM-BNFPO = |{ PS_ITEM-BNFPO ALPHA = OUT }|.
  PS_ITEM-LIFNR = |{ PS_ITEM-LIFNR ALPHA = OUT }|.
  PS_ITEM-FLIEF = |{ PS_ITEM-FLIEF ALPHA = OUT }|.

  "자재코드
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      INPUT  = PS_ITEM-MATNR
    IMPORTING
      OUTPUT = PS_ITEM-MATNR.

  "단위
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      INPUT  = PS_ITEM-MEINS
    IMPORTING
      OUTPUT = PS_ITEM-MEINS.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_SEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CHECK_SEL_DATA .

*  "데이터 점검
  IF ( SY-BATCH EQ SPACE AND P_BAT EQ SPACE )
    OR P_ILOG EQ ABAP_TRUE.

    "선택 한 라인  없으면 오류
    DATA LT_ROW TYPE LVC_T_ROID.
    CALL METHOD GO_GRID_IT->GET_SELECTED_ROWS
      IMPORTING
        ET_ROW_NO = LT_ROW.
    DELETE LT_ROW WHERE ROW_ID LE 0.
    IF LT_ROW[] IS INITIAL.
      MESSAGE E050.
    ENDIF.

  ELSE.

    "배치 실행인 경우 데이터 없으면 오류
    IF GT_PR[] IS INITIAL.
*4-3) 전송 버튼 클릭시 선택 된 라인이 없으면 하단 에러 메시지 처리 "선택된 데이터가 없습니다."
      MESSAGE E050.
    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_RUN_SEND_RFC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SY_INDEX
*&      --> <LS_SYS>_SYSTEM_ID
*&      --> LT_HEAD
*&      --> LT_ITEM
*&      <-- LV_CNT_S
*&      <-- LV_CNT_E
*&---------------------------------------------------------------------*
FORM F_RUN_SEND_RFC  USING    PV_INDEX
                              PS_SYS TYPE TY_SYS
                              PT_BANFN TYPE TY_T_BANFN
                        CHANGING      PT_SEND TYPE TY_T_PR
                              CV_CNT_S
                              CV_CNT_E.

  DATA:
    LV_START_IDX TYPE INT4,
    LV_END_IDX   TYPE INT4,
    LT_DATA      TYPE STANDARD TABLE OF ZGTMMS2000,
    LS_DATA      TYPE ZGTMMS2000,
    LT_LOG       TYPE STANDARD TABLE OF TY_PR.

  DATA:
    LV_DEST    TYPE ZDEST,
    LV_LINE    TYPE I, "2026.05.27 라인별 전송 건수
    LV_RESULT  TYPE ZO_RESULT,
    LV_MESSAGE TYPE ZO_MESSAGE.

  "시작 Tabix
  LV_START_IDX = PV_INDEX - 1.
  LV_START_IDX *= GC_MAX.
  LV_START_IDX += 1.

  "종료 Tabix
  LV_END_IDX = LV_START_IDX + GC_MAX.

  "정렬
  SORT PT_SEND BY BANFN BNFPO.

  LOOP AT PT_BANFN ASSIGNING FIELD-SYMBOL(<LS_BANFN>) FROM LV_START_IDX.
    "종료 Tab index 보다 크거나 같으면 종료
    IF SY-TABIX GE LV_END_IDX.
      EXIT.
    ENDIF.

    "라인추가(아이템)
    READ TABLE PT_SEND WITH KEY BANFN = <LS_BANFN>-BANFN BINARY SEARCH TRANSPORTING NO FIELDS.
    IF SY-SUBRC EQ 0.
      LOOP AT PT_SEND ASSIGNING FIELD-SYMBOL(<LS_SEND>) FROM SY-TABIX.
        IF <LS_SEND>-BANFN NE <LS_BANFN>-BANFN.
          EXIT.
        ENDIF.

        PERFORM F_SET_ITEM_LINE_DATA USING <LS_SEND> CHANGING LS_DATA.
        LT_DATA[] = VALUE #( BASE LT_DATA ( LS_DATA ) ).

        LT_LOG[] = VALUE #( BASE LT_LOG ( <LS_SEND> ) ). "로그

      ENDLOOP.
    ENDIF.

  ENDLOOP.

  "전송 대상이 있으면 진행
  CHECK LT_DATA[] IS NOT INITIAL.

  " 전송 라인 수 확인
  LV_LINE = LINES( LT_DATA ).

*  DESTINATION 구분 관리용도로 ZGTPPT1010-CODEGRP = '0600' 으로 공통 마스터 추가해뒀습니다.
  CALL FUNCTION 'ZGTMM_IF_GET_DESTINATION'
    EXPORTING
      I_ZIFNO = GC_MM00028
    IMPORTING
      E_ZDEST = LV_DEST.

  CALL FUNCTION 'ZGTMM_IF_O_PR_SEND'
    DESTINATION LV_DEST
    EXPORTING
      I_SYSTEM_ID = PS_SYS-SYSTEM_ID
      I_BUKRS     = PS_SYS-BUKRS
    IMPORTING
      ZO_RESULT   = LV_RESULT
      ZO_MESSAGE  = LV_MESSAGE
    TABLES
      OT_ITEM     = LT_DATA
    EXCEPTIONS
      OTHERS      = 1.

  IF SY-SUBRC NE 0.
    LV_RESULT = GC_02.
  ENDIF.

  "메세지 처리

  "<-- 2026.05.27 라인별 전송 로직 추가

  IF ( SY-BATCH EQ SPACE AND P_BAT EQ SPACE )
  OR P_ILOG EQ ABAP_TRUE.
    "일반 실행 인 경우
    IF LV_RESULT EQ GC_00.
      "성공
      CV_CNT_S += LV_LINE.
      LV_RESULT = GC_S.
    ELSE.
      "오류
      CV_CNT_E += LV_LINE.
      LV_RESULT = GC_E  .
    ENDIF.
  ELSE.
    "배치 인 경우
    IF LV_RESULT EQ GC_00.
      "성공
      CV_CNT_S += LINES( PT_BANFN ).
      LV_RESULT = GC_S.
    ELSE.
      "오류
      CV_CNT_E += LINES( PT_BANFN ).
      LV_RESULT = GC_E  .
    ENDIF.
  ENDIF.
  " 2026.05.27 라인별 전송 로직 추가-->

  "로그 저장
  PERFORM F_SAVE_IF_LOG USING LV_RESULT LV_MESSAGE PS_SYS LT_LOG.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_PR_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_PR_DATA .

  "초기화
  CLEAR:
     GT_ITEM[].
*
*1)	 실행 조회조건 값을 기준으로 변경 이력테이블에서 대상 구매요청번호, 구매요청품목 번호 추출 (GT_CDHDR)
*	Table : CDHDR
*	Select 조건  : OBJECTID
*	WHERE 조건
*	OBJECTCLAS = 'BANF'
*	TCODE : ME51N or ME52N
*	UPDATE = 조회 조건의 생성/변경 일자
*
*2) 조회된 OBJECTID 값 기준으로 Sorting 중복 제거 후 EBAN 구매요청정보 추출(GT_ITEM)
*	추출 정보
*	      banfn,bnfpo,ernam,bsart,badat,erdat,matnr,werks
*	      lgort,menge,meins,lfdat,preis,waers,peinh,ekorg
*	      lifnr,plief,loekz,ekgrp
*

  SELECT DISTINCT
    EB~BANFN,
    EB~BNFPO,
    TK~BUKRS,
    EB~ERNAM,
    EB~BSART,
    T01~BATXT,
    EB~BADAT,
    EB~ERDAT,
    EB~MATNR,
*    EB~TXZ01 AS ZZMAKTX80,
    CASE WHEN MR~ZZMAKTX80 EQ @SPACE THEN MT~MAKTX ELSE MR~ZZMAKTX80 END AS ZZMAKTX80,
    EB~WERKS,
    TW~NAME1,
    EB~LGORT,
    TL~LGOBE,
    TW~PSTLZ,
    TW~ORT01,
    TW~STRAS,
    EB~MENGE,
    EB~MEINS,
    EB~LFDAT,
    EB~PREIS,
    EB~WAERS,
    EB~PEINH,
    EB~EKORG,
    T02~EKOTX,
    EB~EKGRP,
    T03~EKNAM,
    EB~LIFNR,
    EB~FLIEF,
    EB~LOEKZ
    FROM EBAN AS EB
                INNER JOIN
              MARA AS MR ON EB~MATNR EQ MR~MATNR
                INNER JOIN
             T001W AS TW ON EB~WERKS EQ TW~WERKS
                INNER JOIN
             T001K AS TK ON TW~BWKEY EQ TK~BWKEY
                LEFT OUTER JOIN
              MAKT AS MT ON EB~MATNR EQ MT~MATNR
                                 AND MT~SPRAS EQ @SY-LANGU
                LEFT OUTER JOIN
              T001L AS TL ON EB~WERKS EQ TL~WERKS
                               AND EB~LGORT EQ TL~LGORT
                LEFT OUTER JOIN
              T161T AS T01 ON EB~BSART EQ T01~BSART
                               AND EB~BSTYP EQ T01~BSTYP
                               AND T01~SPRAS EQ @SY-LANGU
                LEFT OUTER JOIN
              T024E AS T02 ON EB~EKORG EQ T02~EKORG
                LEFT OUTER JOIN
              T024 AS T03 ON EB~EKGRP EQ T03~EKGRP
    WHERE EB~WERKS IN @S_WERKS
    AND EB~BANFN IN @S_BANFN
    AND EB~BADAT IN @S_ERDAT  "생성/변경일자
*    AND ( CD~OBJECTID IS NOT NULL OR EB~ESTKZ EQ @GC_V )"EB~ESTKZ EQ @GC_V "2026.08.14 CDHDR 참고X
*	4) 릴리즈 상태 점검
*    : 조회된 구매요청 품목의 릴리즈 지시자(EBAN-FRGKZ) 가 공백 or 2 or S 인 대상만 선정
    AND EB~FRGKZ IN ( @SPACE, @GC_2, @GC_S )

*4) 전송 대상 진행 상태 점검
*PR 항번 기준으로 구매요청 진행 상태 점검
*TABLE : ZGTMMT2000
*SELECT 조건 : BANFN,BNFPO,STATUS
*WHERE 조건 :
*BANFN = 전송대상 BANFN
*BNFPO = 전송대상 BNFPO
*
*BNFN BNFPO 값이 존재하고 STATUS="" 이면 전송 대상
*아니면 전송 대상에서 제외
    AND NOT EXISTS (
      SELECT ZZ~BANFN, ZZ~BNFPO
        FROM ZGTMMT2000 AS ZZ
        WHERE ZZ~BANFN EQ EB~BANFN
          AND ZZ~BNFPO EQ EB~BNFPO
          AND ZZ~FLAG NE @SPACE
    )
    INTO CORRESPONDING FIELDS OF TABLE @GT_ITEM.

  CHECK GT_ITEM[] IS NOT INITIAL.

  "이름/주소
  ##ITAB_DB_SELECT
  ##ITAB_KEY_IN_SELECT
  SELECT
    V1~BNAME,
    V1~NAME_TEXT,
    V1~SMTP_ADDR
    FROM P_USER002 AS V1
    WHERE EXISTS (
      SELECT ZZ~ERNAM
        FROM @GT_ITEM AS ZZ
        WHERE ZZ~ERNAM EQ V1~BNAME
    )
    ORDER BY V1~BNAME
    INTO TABLE @DATA(LT_USER).

  DATA :
    LT_LINES TYPE TABLE OF  TLINE,
    LV_LINE  TYPE STRING,
    LV_NAME  TYPE THEAD-TDNAME.

  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).
    "대상 시스템
    <LS_ITEM>-SYSTEM_ID = P_IFSYT.

    READ TABLE LT_USER ASSIGNING FIELD-SYMBOL(<LS_USER>) WITH KEY BNAME = <LS_ITEM>-ERNAM BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_ITEM>-ENAME = <LS_USER>-NAME_TEXT.
      <LS_ITEM>-MAILADD = <LS_USER>-SMTP_ADDR.
    ENDIF.

    "예상금액
    IF <LS_ITEM>-PEINH IS NOT INITIAL.
      <LS_ITEM>-ZAMT = ( <LS_ITEM>-MENGE * <LS_ITEM>-PREIS ) / <LS_ITEM>-PEINH.
    ENDIF.

*ITEM TEXT구성
    LV_NAME = <LS_ITEM>-BANFN && <LS_ITEM>-BNFPO.
    CLEAR : LV_LINE, LT_LINES.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        ID        = 'B01'
        LANGUAGE  = SY-LANGU
        NAME      = LV_NAME
        OBJECT    = 'EBAN' "
      TABLES
        LINES     = LT_LINES
      EXCEPTIONS
        NOT_FOUND = 4.

    IF LT_LINES[] IS NOT INITIAL.
      LOOP AT LT_LINES INTO DATA(LS_LINE).
        LV_LINE = |{ LV_LINE } { LS_LINE-TDLINE }|.
      ENDLOOP.

      <LS_ITEM>-ITEMTEXT = LV_LINE.
    ENDIF.

  ENDLOOP.

  GT_PR[] = GT_ITEM[].

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_ZGTMMT2000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CHECK_ZGTMMT2000 .
*4) 전송 대상 진행 상태 점검
*PR 항번 기준으로 구매요청 진행 상태 점검
*TABLE : ZGTMMT2000
*SELECT 조건 : BANFN,BNFPO,STATUS
*WHERE 조건 :
*BANFN = 전송대상 BANFN
*BNFPO = 전송대상 BNFPO
*
*BNFN BNFPO 값이 존재하고 STATUS="" 이면 전송 대상
*아니면 전송 대상에서 제외

  "선택 한 라인 조회
  DATA:
    LV_BAT TYPE C LENGTH 1,
    LT_ROW TYPE LVC_T_ROID.

  FIELD-SYMBOLS <LS_ITEM> TYPE TY_PR.

  IF ( SY-BATCH EQ SPACE AND P_BAT EQ SPACE )
    OR P_ILOG EQ ABAP_TRUE.
    CALL METHOD GO_GRID_IT->GET_SELECTED_ROWS
      IMPORTING
        ET_ROW_NO = LT_ROW.
    LV_BAT = SPACE.
  ELSE.
    LV_BAT = ABAP_TRUE.
  ENDIF.

  DATA:
    BEGIN OF LS_KEY,
      BANFN TYPE EBAN-BANFN,
      BNFPO TYPE EBAN-BNFPO,
    END OF LS_KEY,
    LT_KEY LIKE STANDARD TABLE OF LS_KEY.

  IF LV_BAT EQ SPACE.
    LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
      CHECK <LS_ROW>-ROW_ID GT 0.
      READ TABLE GT_ITEM ASSIGNING <LS_ITEM> INDEX <LS_ROW>-ROW_ID.
      CHECK SY-SUBRC EQ 0.
      LT_KEY[] = VALUE #( BASE LT_KEY ( BANFN = <LS_ITEM>-BANFN BNFPO = <LS_ITEM>-BNFPO ) ).
    ENDLOOP.
  ELSE.
    ##ITAB_DB_SELECT
    ##ITAB_KEY_IN_SELECT
    SELECT DISTINCT ZZ~BANFN, ZZ~BNFPO
      FROM @GT_ITEM AS ZZ
      INTO TABLE @LT_KEY.
  ENDIF.

  "전송 대상 시스템/PR 번호 별 마지막 I/F key 조회
  ##ITAB_DB_SELECT
  ##ITAB_KEY_IN_SELECT
  SELECT
    Z1~BANFN,
    Z1~BNFPO,
    Z1~FLAG
    FROM ZGTMMT2000 AS Z1
    WHERE EXISTS (
        SELECT ZZ~BANFN, BNFPO
          FROM @LT_KEY AS ZZ
          WHERE ZZ~BANFN EQ Z1~BANFN
             AND ZZ~BNFPO EQ Z1~BNFPO
    )
    INTO TABLE @DATA(LT_STAT).

  FIELD-SYMBOLS <LS_STAT> LIKE LINE OF LT_STAT.

  IF LV_BAT EQ SPACE.
    LOOP AT LT_ROW ASSIGNING <LS_ROW>.
      CHECK <LS_ROW>-ROW_ID GT 0.
      READ TABLE GT_ITEM ASSIGNING <LS_ITEM> INDEX <LS_ROW>-ROW_ID.
      CHECK SY-SUBRC EQ 0.
      READ TABLE LT_STAT ASSIGNING <LS_STAT> WITH KEY BANFN = <LS_ITEM>-BANFN
                                                                                       BNFPO = <LS_ITEM>-BNFPO BINARY SEARCH.
      CHECK SY-SUBRC EQ 0.
      CHECK <LS_STAT>-FLAG NE SPACE.

      MESSAGE E000 WITH TEXT-E01. "전송 가능하지 않은 상태의 구매요청이 포함되었습니다.
    ENDLOOP.
  ELSE.
    LOOP AT GT_ITEM ASSIGNING <LS_ITEM>.
      READ TABLE LT_STAT ASSIGNING <LS_STAT> WITH KEY BANFN = <LS_ITEM>-BANFN
                                                                                          BNFPO = <LS_ITEM>-BNFPO BINARY SEARCH.
      CHECK SY-SUBRC EQ 0.
      CHECK <LS_STAT>-FLAG NE SPACE.
      MESSAGE E000 WITH TEXT-E01. "전송 가능하지 않은 상태의 구매요청이 포함되었습니다.
    ENDLOOP.
  ENDIF.

ENDFORM.
