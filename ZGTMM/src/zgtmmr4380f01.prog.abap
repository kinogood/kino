*&---------------------------------------------------------------------*
*& Include          ZGTMMR4380F01
*&---------------------------------------------------------------------*

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
    "필수 값 설정
    CASE SCREEN-GROUP1.
      WHEN 'WRK' OR 'INS' OR 'LGO'. "OR 'APP'.  2026.06.09 승인 담당자 필수 제외
        IF SCREEN-GROUP3 NE 'HGH'.
          SCREEN-REQUIRED = 2.
        ENDIF.
        MODIFY SCREEN.

      WHEN 'APP'.
        IF P_APPV EQ ABAP_TRUE AND  P_INCOM EQ ABAP_TRUE.
          SCREEN-REQUIRED = 2.
        ENDIF.
    ENDCASE.

    "DISPLAY/HIDDEN 설정
    CASE SCREEN-GROUP1.
      WHEN 'MAT' OR 'CHA'.
        IF P_DISP EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.
      WHEN 'APP'.
        IF P_APPV EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.
      WHEN 'EKG'.
        IF P_DISP EQ ABAP_TRUE AND P_INCOM EQ ABAP_TRUE. "재고실사조회&미완료
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.
    ENDCASE.
  ENDLOOP.

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

  CHECK SY-UCOMM EQ 'ONLI'.

  CLEAR GV_ERROR.

  "필수 값 점검
  IF P_WERKS IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F01.
  ENDIF.

  CHECK GV_ERROR EQ SPACE.

  "유효성 점검
  SELECT SINGLE
    @ABAP_TRUE
    FROM T001W
    WHERE WERKS EQ @P_WERKS
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E166.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_LGORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_LGORT .

  CHECK SY-UCOMM EQ 'ONLI'.

  CLEAR GV_ERROR.

  "필수 값 점검
  IF S_LGORT[] IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F02.
  ENDIF.

  CHECK GV_ERROR EQ SPACE.

  "유효성 점검
  SELECT SINGLE
    @ABAP_TRUE
    FROM T001L
    WHERE WERKS EQ @P_WERKS
    AND LGORT IN @S_LGORT
    INTO @DATA(LV_CHK).
  IF SY-SUBRC NE 0.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E166.
  ENDIF.

*  3) 입력 조건에 실사 대상 저장위치가 아닌 값이 존재하면 에러 메세지 처리 "재고실사 확인 대상이 아닌 저장위치가 존재합니다. 입력값을 확인하세요".
*	: 대상 저장위치 점검
*	ZGTPPT1010-CODEGRP = '0810'
*	FLD_01 = 입력 플랜트
*	FLD_02 = 입력 저장위치
  SELECT SINGLE
    @ABAP_TRUE
    FROM T001L AS TL
    WHERE TL~WERKS EQ @P_WERKS
    AND TL~LGORT IN @S_LGORT
    AND NOT EXISTS (
      SELECT @ABAP_TRUE
        FROM ZGTPPT1010 AS ZZ
        WHERE ZZ~MODULE_KIND EQ 'MM'
          AND ZZ~CODEGRP EQ '0810'
          AND ZZ~FLD_01 EQ TL~WERKS
          AND ZZ~FLD_02 EQ TL~LGORT
    )
    INTO @DATA(LV_ZCHK).
  IF SY-SUBRC EQ 0.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E167.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_INSMM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_INSMM .

  CHECK SY-UCOMM EQ 'ONLI'.

  CLEAR GV_ERROR.

  "필수 값 점검
  IF P_INSMM IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F03.
  ENDIF.

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

*  DATA: LV_APPUSER TYPE PERSNO.

  CHECK SY-UCOMM EQ 'ONLI'
    AND P_APPV EQ ABAP_TRUE.

  CLEAR: GV_ERROR, GV_APPUSER.


  IF P_APPUS IS INITIAL AND P_INCOM = ABAP_TRUE.
*승인담당자_'재고실사승인'조회 조건의 '미완료' 상태 조건일 때만..
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F04.
  ENDIF.

  CHECK GV_ERROR EQ SPACE.
  CHECK P_APPUS IS NOT INITIAL.

  " 사용자 ID(사번) ALPHA CONVERSION
  DATA(LV_APPUS) = CONDENSE( P_APPUS ).

  IF LV_APPUS CO '0123456789'.
    GV_APPUSER = LV_APPUS.
    GV_APPUSER = |{ GV_APPUSER ALPHA = IN }|.
  ENDIF.


  CASE ABAP_TRUE.
    WHEN P_COMPL. "승인 완료 ->이력 테이블 기준 승인자 체크
      SELECT SINGLE
    @ABAP_TRUE
    FROM ZGTMMT9490
    WHERE APPUSER EQ @GV_APPUSER"P_APPUS
    INTO @DATA(LV_CHK).

    WHEN P_INCOM. "현재 승인자 기준 체크
      "유효성 점검
      SELECT SINGLE
        @ABAP_TRUE
        FROM ZGTMMT1022
        WHERE APPUSER EQ @GV_APPUSER"P_APPUS
        INTO @DATA(LV_CHK2).
  ENDCASE.

  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E166.

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

  CHECK GV_ERROR EQ SPACE. "오류가 없으면 진행

  CASE ABAP_TRUE.
    WHEN P_DISP. "재고실사 조회
      PERFORM F_GET_LIST_DISP.

    WHEN P_APPV. "재고실사 승인
      PERFORM F_GET_LIST_APPV.
  ENDCASE.

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

  CASE ABAP_TRUE.
    WHEN P_COMPL. "처리 완료
      PERFORM F_GET_LIST_DISP_COMPL.
    WHEN P_INCOM. "미완료
      PERFORM F_GET_LIST_DISP_INCOM.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_LIST_DISP_INCOM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_LIST_DISP_INCOM .

  "초기화
  CLEAR GT_DISP_I[].

*  1. 처리 상태 = 미완료 인 경우
* 1) 실행 조회조건 값을 기준으로 MES 재고실사 정보 테이블 조회
*    Table : ZPPT0600
*    Select 조건  : INSMM,WERKS,LGORT,SEQNO,MATNR,CHARG,TAGNR,BSTAR,MENGE,MEINS,VBELN,POSNR
*    WHERE조건
*    WERKS = 입력 플랜트
*    LGORT= 입력 저장위치
*1-1) 조회된 실사 대상의 저장위치 값 기준으로 공통 마스터 점검,
*Table: ZGTPPT1010
*SELECTION 조건: FLD_03,
*WHERE 조건:
*MODUlE_KIND = 'MM'
*CODEGROUP = '0850'
*FLD_01 = P_WERKS
*FLD_02 = P_LGORT
*: FLD_03 자재유형 필드에 값이 있으면 등록된 자재 유형 데이터만 조회
* 지정된 자재요형 값이 없으면 전체로 보여줌

*2) 재고실사 대상 데이터 기준 재고실사 조정 이력관리 테이블 조회
*	Table : ZGTMMT9490
*	SELECT 조건 : ZCHECK,APPUSER,ERDAT
*	WHERE 조건 :
*	INSMM  = 1)의 대상 값
*	WERKS = 1)의 대상값
*	LGORT = 1)의 대상 값
*	SEQNO = 1)의 대상값
*	MATNR = 1)의 대상 값
*	CHARG = 1)의 대상 값
*	TAGNR = 1)의 대상 값
*
*	: ZGTMMT9490 테이블에 존재하지 않거나 ZCHECK="" or "C" 인 대상 데이터 조회

*	3) SAP 현재 재고 정보 조회
*   CDS VIEW : ZGTMM_CV_GET_STOCKLIST
*   Select 조건
*    : MEINS,LABST,INSME,SPEME
*   WHERE조건
*   BUKRS = 2) 의 대상 값
*   WERKS = 2)의 대상 값
*   LGORT = 2)의 대상 값
*   MATNR = 2)의 대상 값
*   CHARG = 2)의 대상값
*
*	4) 기타 정보 추출
*   4-1) MAKTX = MAKT-MAKTX

*  DATA LR_MTART TYPE RANGE OF MARA-MTART. "
*아래 조건에 해당하는 공통코드 테이블에 자재유형이 존재하면, 해당 자재유형 재고만 조회
*없으면, 전체 자재유형 조회.
  SELECT FLD_02, FLD_03
  FROM ZGTPPT1010
  WHERE MODULE_KIND EQ 'MM'
    AND CODEGRP EQ '0810'
    AND FLD_01     EQ @P_WERKS
    AND FLD_02     IN  @S_LGORT
    INTO TABLE @DATA(LT_1010).
  SORT LT_1010 BY FLD_02 FLD_03.

  SELECT
    Z1~INSMM,
    Z1~INVDA,
    Z1~WERKS,
    Z1~LGORT,
    Z1~SEQNO,
    Z1~MATNR,
    MT~MAKTX,
    MA~MTART,
    Z1~CHARG,
    Z1~TAGNR,
    Z1~BSTAR,
    T1~BTEXT,
    Z1~MENGE,
    Z1~MEINS,
    Z1~VBELN,
    Z1~POSNR,
    Z2~ZCHECK,
*    Z2~APPUSER,   "2026.06.09 주석처리
    Z2~ERDAT,
    T0~WAERS,
    TW~BWKEY,
    Z2~APPREQ,
    Z3~MENGE AS STOCKQTY, "2026.06.09 추가
    Z3~MEINS   AS STOCKUNIT,  "2026.06.09 추가
    Z4~APPUSER,
    Z5~ENAME AS APPUSER_TEXT     "2026.06.09 추가
    FROM ZPPT0600 AS Z1
                INNER JOIN
              MARA AS MA ON Z1~MATNR EQ MA~MATNR
*>S.조회된 데이터 중 조회조건의 구매그룹 입력값이 있으면 MARC-EKGRP와 같은 것만 보여주게 변경
                INNER JOIN
              MARC AS MC ON Z1~MATNR EQ MC~MATNR
                                 AND Z1~WERKS EQ MC~WERKS
*<E.2026.08.05_ZGODEV04
                INNER JOIN
              T001W AS TW ON Z1~WERKS EQ TW~WERKS
               INNER JOIN
              T001K AS TK ON TW~BWKEY EQ TK~BWKEY
                INNER JOIN
              T001 AS T0 ON TK~BUKRS EQ T0~BUKRS
    "<--2026.06.09 재고기준/담당자 기준 변경
                LEFT OUTER JOIN     "재고 없는 경우 테이블에 값이 없음
               ZGTPPT4090 AS Z3 ON Z1~INSMM EQ Z3~INSMM
                                           AND Z1~WERKS EQ Z3~WERKS
                                           AND Z1~LGORT EQ Z3~LGORT
                                           AND Z1~MATNR EQ Z3~MATNR
                                           AND Z1~CHARG EQ Z3~CHARG
                                           AND Z1~VBELN EQ Z3~VBELN
                                           AND Z1~POSNR EQ Z3~POSNR
*>S.2026.07.27_전송상태값이 '00'인 데이터 기준..추가
                                           AND Z3~ZSTAT = '00'
*<E.2026.07.27_ZGODEV04.
                LEFT OUTER JOIN
                ZGTMMT1022 AS Z4 ON Z1~WERKS EQ Z4~WERKS
                LEFT OUTER JOIN
                ZZPA0001 AS Z5 ON Z4~APPUSER EQ Z5~PERNR
                                         AND Z5~ENDDA EQ '99991231'
  " 2026.06.09 재고기준/담당자 기준 변경-->
                LEFT OUTER JOIN
              ZGTMMT9490 AS Z2 ON Z1~INSMM EQ Z2~INSMM
                                         AND Z1~WERKS EQ Z2~WERKS
                                         AND Z1~LGORT EQ Z2~LGORT
                                         AND Z1~SEQNO EQ Z2~SEQNO
                                         AND Z1~MATNR EQ Z2~MATNR
                                         AND Z1~CHARG EQ Z2~CHARG
                                         AND Z1~TAGNR EQ Z2~TAGNR
                LEFT OUTER JOIN
              MAKT AS MT ON Z1~MATNR EQ MT~MATNR
                                AND MT~SPRAS EQ @SY-LANGU
                LEFT OUTER JOIN
              T064B AS T1 ON Z1~BSTAR EQ T1~BSTAR
                                AND T1~SPRAS EQ @SY-LANGU
    WHERE Z1~INSMM EQ @P_INSMM
    AND Z1~WERKS EQ @P_WERKS
    AND Z1~LGORT IN @S_LGORT
    AND Z1~MATNR IN @S_MATNR
    AND Z1~CHARG IN @S_CHARG
    AND MC~EKGRP IN @S_EKGRP "2026.08.05 추가
*>S.260803_조회된 최신 차수(ZGTPPT4090-ZCOUNT) 기준 전송 상태값이 “00” 인 데이터 조회
    AND ( Z3~ZCOUNT IS NULL OR Z3~ZCOUNT EQ (
            SELECT MAX( SUB_Z3~ZCOUNT )
              FROM ZGTPPT4090 AS SUB_Z3
             WHERE SUB_Z3~INSMM EQ Z1~INSMM
               AND SUB_Z3~WERKS EQ Z1~WERKS
               AND SUB_Z3~LGORT EQ Z1~LGORT
               AND SUB_Z3~MATNR EQ Z1~MATNR
               AND SUB_Z3~CHARG EQ Z1~CHARG
               AND SUB_Z3~VBELN EQ Z1~VBELN
               AND SUB_Z3~POSNR EQ Z1~POSNR
               AND SUB_Z3~ZSTAT = '00'
           ) )
*<E.260803_ZGODEV04.
*    AND Z5~ENDDA EQ '99991231' "위치 변경
*    AND MA~MTART IN @LR_MTART
*2) 재고실사 대상 데이터 기준 재고실사 조정 이력관리 테이블 조회
*	Table : ZGTMMT9490
*	SELECT 조건 : ZCHECK,APPUSER,ERDAT
*	WHERE 조건 :
*	INSMM  = 1)의 대상 값
*	WERKS = 1)의 대상값
*	LGORT = 1)의 대상 값
*	SEQNO = 1)의 대상값
*	MATNR = 1)의 대상 값
*	CHARG = 1)의 대상 값
*	TAGNR = 1)의 대상 값
*
*	: ZGTMMT9490 테이블에 존재하지 않거나 ZCHECK="" or "C" 인 대상 데이터 조회
    AND NOT EXISTS (
      SELECT @ABAP_TRUE
        FROM ZGTMMT9490 AS ZZ
        WHERE ZZ~INSMM EQ Z1~INSMM
           AND ZZ~WERKS EQ Z1~WERKS
           AND ZZ~LGORT EQ Z1~LGORT
           AND ZZ~SEQNO EQ Z1~SEQNO
           AND ZZ~MATNR EQ Z1~MATNR
           AND ZZ~CHARG EQ Z1~CHARG
           AND ZZ~TAGNR EQ Z1~TAGNR
           AND ZZ~ZCHECK NE @SPACE
           AND ZZ~ZCHECK NE @GC_C
    )
    INTO CORRESPONDING FIELDS OF TABLE @GT_DISP_I.


  CHECK GT_DISP_I[] IS NOT INITIAL.

  "<--2026.06.09 재고기준/담당자 기준 변경
*	3) SAP 현재 재고 정보 조회
*   CDS VIEW : ZGTMM_CV_GET_STOCKLIST
*   Select 조건
*    : MEINS,LABST,INSME,SPEME
*   WHERE조건
*   BUKRS = 2) 의 대상 값  -- 회사코드 없음
*   WERKS = 2)의 대상 값
*   LGORT = 2)의 대상 값
*   MATNR = 2)의 대상 값
*   CHARG = 2)의 대상값
*  SELECT
*      V1~WERKS,
*      V1~LGORT,
*      V1~MATNR,
*      V1~CHARG,
*      V1~MEINS,
*      V1~LABST,
*      V1~INSME,
*      V1~SPEME
*    FROM ZGTMM_CV_GET_STOCKLIST AS V1
*    WHERE EXISTS (
*##ITAB_KEY_IN_SELECT
*      SELECT @ABAP_TRUE
*        FROM @GT_DISP_I AS ZZ
*        WHERE ZZ~WERKS EQ V1~WERKS
*           AND ZZ~LGORT EQ V1~LGORT
*           AND ZZ~MATNR EQ V1~MATNR
*           AND ZZ~CHARG EQ V1~CHARG
*    )
*    ORDER BY V1~WERKS, V1~LGORT, V1~MATNR, V1~CHARG
*    INTO TABLE @DATA(LT_STOCK).
  " 2026.06.09 재고기준/담당자 기준 변경-->

*"표준원가를 기준으로 계산한 값으로 표기
*1) 자재 단가, 가격단위 조회
*Table: MBEW
*SELECT 조건: STPRS,PEINH
*WHERE 조건 :
*MATNR = ZPPT0600-MATNR
*BWKEY = ZPPT0600-WERKS
*2) 평가영역 회사코드 조회
*Table : T001K
*SELECT 조건 : BUKRS
*WHERE 조건 : BWKEY = ZPPT0600-WERKS
*3) 조회한 BUKRS 값의 통화키 점검
*Table : T001
*SELECT 조건 : WAERS
*WHERE 조건 :
*BUKRS = 2) 의 BUKRS
*WAERS = KRW 이면 1)의 STPRS*100 으로 최종 원가 산출하여 재고금액 계산"
  SELECT
    MW~MATNR,
    MW~BWKEY,
    MW~STPRS,
    MW~PEINH
    FROM MBEW AS MW
    WHERE EXISTS (
##ITAB_KEY_IN_SELECT
      SELECT @ABAP_TRUE
        FROM @GT_DISP_I AS ZZ
        WHERE ZZ~MATNR EQ MW~MATNR
          AND ZZ~BWKEY EQ MW~BWKEY
    )
    ORDER BY MW~MATNR, MW~BWKEY
    INTO TABLE @DATA(LT_MBEW).

  "<--2026.06.09 재고기준/담당자 기준 변경

**"ZGTMMT9490 값이 없으면 처리 사용자 ID 기준으로 팀장 정보 추출, 이름 텍스트로 표기
**A) 사용자 ID 의 부서정보 조회
**Table: ZZPA0001
**SELECT  조건 : KOSTL
**WHERE 조건 :
**PERNR = SY-NAME
**BUKRS = 조회 조건 입력 값
**ENDDA = ""9999.12.31""
*  DATA:
*    LV_PERSNO TYPE PERSNO,
*    LV_UNAME  TYPE SY-UNAME.
*
*  SELECT SINGLE
*    TK~BUKRS
*    FROM T001W AS TW
*                INNER JOIN
*           T001K AS TK ON TW~BWKEY EQ TK~BWKEY
*    WHERE TW~WERKS EQ @P_WERKS
*    INTO @DATA(LV_BUKRS).
*
*  LV_UNAME = SY-UNAME.
*  ##REGEX_POSIX
*  REPLACE ALL OCCURRENCES OF REGEX '[^[:digit:]]' IN LV_UNAME WITH SPACE.
*  LV_PERSNO = LV_UNAME.
*  SELECT SINGLE
*    KOSTL
*    FROM ZZPA0001
*    WHERE PERNR EQ @LV_PERSNO
*    AND BUKRS EQ @LV_BUKRS
*    AND ENDDA EQ '99991231'
*    INTO @DATA(LV_KOSTL).

**B) 부서의 승인 담담자 조회
**Table: ZZPA0001
**SELECT 조건 : EMNAM
**WHERE 조건:
**KOSTL = A)의 KOSTL
**ZZ_JOBTL = ""7400""
**ENDDA = ""9999.12.31""   "
*  SELECT SINGLE
*    PERNR,
*    ENAME
*    FROM ZZPA0001
*    WHERE KOSTL EQ @LV_KOSTL
*    AND ZZ_JOBTL EQ '7400'
*    AND ENDDA EQ '99991231'
*    INTO (@DATA(LV_PERNR), @DATA(LV_ENAME) ).
*
*  "승인 담당자 이름
*  SELECT
*    Z1~PERNR,
*    Z1~ENAME
*    FROM ZZPA0001 AS Z1
*    WHERE Z1~BUKRS EQ @LV_BUKRS
*    AND Z1~ENDDA EQ '99991231'
*    AND EXISTS (
*##ITAB_KEY_IN_SELECT
*      SELECT @ABAP_TRUE
*        FROM @GT_DISP_I AS ZZ
*        WHERE ZZ~APPUSER EQ Z1~PERNR
*    )
*    ORDER BY Z1~PERNR
*    INTO TABLE @DATA(LT_HR).

  " 2026.06.09 재고기준/담당자 기준 변경-->


  LOOP AT GT_DISP_I ASSIGNING FIELD-SYMBOL(<LS_DISP>).
    DATA(LV_TABIX) = SY-TABIX.
*공통코드 테이블에 특정 저장위치/자재유형이 존재하면, 해당 자재유형 재고만 대상. 없으면, 전체 대상.
    READ TABLE LT_1010 TRANSPORTING NO FIELDS
    WITH KEY FLD_02 = <LS_DISP>-LGORT
                   FLD_03 = <LS_DISP>-MTART BINARY SEARCH.

    IF SY-SUBRC NE 0 .
      READ TABLE LT_1010 ASSIGNING FIELD-SYMBOL(<MTART>)
      WITH KEY FLD_02 = <LS_DISP>-LGORT BINARY SEARCH.
      IF SY-SUBRC = 0.
        IF <MTART>-FLD_03 IS NOT INITIAL AND <MTART>-FLD_03 NE <LS_DISP>-MTART.
          DELETE GT_DISP_I INDEX LV_TABIX. CONTINUE.
        ENDIF.
      ELSE.
        DELETE GT_DISP_I INDEX LV_TABIX. CONTINUE.
      ENDIF.
    ENDIF.

*상태               STATUS      "ZCHECK = """" 이면 GREY
*ZCHECK = ""C"" 이면 YELLOW"
*진행 상태                ZCHECK      "ZCHECK="""" 이면 ""실사완료""
*ZCHECK=""C""이면 ""확정완료"""   ZCHECK 필드값의 텍스트로 표기
    CASE <LS_DISP>-ZCHECK.
      WHEN SPACE.
        <LS_DISP>-STATUS = ICON_LED_INACTIVE.
        <LS_DISP>-ZCHECK_TEXT = TEXT-C01.
      WHEN GC_C.
        <LS_DISP>-STATUS = ICON_LED_YELLOW.
        <LS_DISP>-ZCHECK_TEXT = TEXT-C02.
    ENDCASE.


    "<--2026.06.09 재고기준/담당자 기준 변경

*SAP 재고수량               STOCKQTY      "1) BSTAR = ""1"" 이면
*ZGTMM_CV_GET_STOCKLIST-LABST
*2) BSTAR = ""2"" 이면
*ZGTMM_CV_GET_STOCKLIST-INSME
*2) BSTAR = ""4"" 이면
*ZGTMM_CV_GET_STOCKLIST-SPEME"    "BSTAR 값에 따라 재고 상태별 수량 표기
*ALV 필드 컬럼 색 :  YELLOW
*"
*SAP 재고 단위                STOCKUNIT     ZGTMM_CV_GET_STOCKLIST-STOCKUNIT
*    READ TABLE LT_STOCK ASSIGNING FIELD-SYMBOL(<LS_STOCK>)
*                                        WITH KEY WERKS = <LS_DISP>-WERKS
*                                                     LGORT = <LS_DISP>-LGORT
*                                                     MATNR = <LS_DISP>-MATNR
*                                                     CHARG = <LS_DISP>-CHARG BINARY SEARCH.
*    IF SY-SUBRC EQ 0.
*      <LS_DISP>-STOCKUNIT = <LS_STOCK>-MEINS.
*      CASE <LS_DISP>-BSTAR.
*        WHEN '1'.
*          <LS_DISP>-STOCKQTY = <LS_STOCK>-LABST.
*        WHEN '2'.
*          <LS_DISP>-STOCKQTY = <LS_STOCK>-INSME.
*        WHEN '4'.
*          <LS_DISP>-STOCKQTY = <LS_STOCK>-SPEME.
*        WHEN OTHERS.  " 2026.06.09 재고유형 없는 경우 가용재고 값 표시
*          <LS_DISP>-STOCKQTY = <LS_STOCK>-LABST.
*      ENDCASE.
*    ENDIF.

    " 2026.06.09 재고기준/담당자 기준 변경-->

*실사수량               COUNTQTY      STOCKQTY-MENGE    "ALV 필드 컬럼 색 : GREEN
*(계산식 변경)"
*>S.2026.07.27_실사수량 계산식 변경(SAP재고수량+차이수량)
*    <LS_DISP>-COUNTQTY = <LS_DISP>-STOCKQTY - <LS_DISP>-MENGE.
    <LS_DISP>-COUNTQTY = <LS_DISP>-STOCKQTY + <LS_DISP>-MENGE.
*<E.2026.07.27_ZGODEV04.

*차이금액               DIFFAMT     "계산식= MENGE*표준원가/가격단위
*"    "표준원가를 기준으로 계산한 값으로 표기
*1) 자재 단가, 가격단위 조회
*Table: MBEW
*SELECT 조건: STPRS,PEINH
*WHERE 조건 :
*MATNR = ZPPT0600-MATNR
*BWKEY = ZPPT0600-WERKS
*2) 평가영역 회사코드 조회
*Table : T001K
*SELECT 조건 : BUKRS
*WHERE 조건 : BWKEY = ZPPT0600-WERKS
*3) 조회한 BUKRS 값의 통화키 점검
*Table : T001
*SELECT 조건 : WAERS
*WHERE 조건 :
*BUKRS = 2) 의 BUKRS
*WAERS = KRW 이면 1)의 STPRS*100 으로 최종 원가 산출하여 재고금액 계산"

    READ TABLE LT_MBEW ASSIGNING FIELD-SYMBOL(<LS_MBEW>)
      WITH KEY MATNR = <LS_DISP>-MATNR
                     BWKEY = <LS_DISP>-BWKEY BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      IF <LS_MBEW>-PEINH IS NOT INITIAL.
        <LS_DISP>-DIFFAMT = ( <LS_DISP>-MENGE * <LS_MBEW>-STPRS )  / <LS_MBEW>-PEINH.
      ENDIF.
    ENDIF.


    "<--2026.06.09 재고기준/담당자 기준 변경

*승인담당자                APPUSER     ZGTMMT9490-APPUSER    "ZGTMMT9490 값이 없으면 처리 사용자 ID 기준으로 팀장 정보 추출, 이름 텍스트로 표기
*A) 사용자 ID 의 부서정보 조회
*Table: ZZPA0001
*SELECT  조건 : KOSTL
*WHERE 조건 :
*PERNR = SY-NAME
*BUKRS = 조회 조건 입력 값
*ENDDA = ""9999.12.31""
*B) 부서의 승인 담담자 조회
*Table: ZZPA0001
*SELECT 조건 : EMNAM
*WHERE 조건:
*KOSTL = A)의 KOSTL
*ZZ_JOBTL = ""7400""
*ENDDA = ""9999.12.31""   "
*    IF <LS_DISP>-APPUSER IS NOT INITIAL.
*      READ TABLE LT_HR ASSIGNING FIELD-SYMBOL(<LS_HR>) WITH KEY PERNR = <LS_DISP>-APPUSER BINARY SEARCH.
*      IF SY-SUBRC EQ 0.
*        <LS_DISP>-APPUSER_TEXT = <LS_HR>-ENAME.
*      ENDIF.
*    ELSE.
*      <LS_DISP>-APPUSER = LV_PERNR.
*      <LS_DISP>-APPUSER_TEXT = LV_ENAME.
*    ENDIF.
    " 2026.06.09 재고기준/담당자 기준 변경-->

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
    WHEN P_DISP.
*    2) 조회된 데이터가 없는 경우 하단 정보메시지 DISPLAY "조회된 값이 없습니다."
      IF  GT_DISP_I[] IS INITIAL
        AND GT_DISP_C[] IS INITIAL.
        MESSAGE S002 DISPLAY LIKE GC_E.
        LEAVE LIST-PROCESSING.
      ENDIF.

      CALL SCREEN 100.
    WHEN P_APPV.
*    2) 조회된 데이터가 없는 경우 하단 정보메시지 DISPLAY "조회된 값이 없습니다."
      IF  GT_APPV[] IS INITIAL.
        MESSAGE S002 DISPLAY LIKE GC_E.
        LEAVE LIST-PROCESSING.
      ENDIF.

      CALL SCREEN 200.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_LIST_DISP_COMPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_LIST_DISP_COMPL .
*2. 처리 상태 = 처리 완료인 경우
*	1) 실행 조회조건 값을 기준으로 재고실사 조정 이력관리 테이블 조회
*	Table : ZGTMMT9490
*	Select 조건  : INSMM,WERKS,LGORT,SEQNO,MATNR,CHARG,TAGNR,COUNTQTY,DIFFAMT,IBLNR,MBLNR,APPUSER,ERDAT,AEDAT,ZCHECK,VBELN,POSNR
*	WHERE조건
*	WERKS = 입력 플랜트
*	LGORT= 입력 저장위치
*
*	: ZCHECK ="P" 인 데이터 추출
*
*	2) 기타 정보 추출
*   2-1) MAKTX = MAKT-MAKTX
*
*	3) 추출한 데이터를 기준으로 ALV Display
*   **ALV-DISPLAY
*   : 상세필드정보는 화면 에이아웃 시트에 정의


  "초기화
  CLEAR GT_DISP_C[].

  SELECT
    Z1~INSMM,
    Z1~INVDA,
    Z1~WERKS,
    Z1~LGORT,
    Z1~SEQNO,
    Z1~MATNR,
    MT~MAKTX,
    Z1~CHARG,
    Z1~TAGNR,
    Z1~BSTAR,
    T1~BTEXT,
    Z1~MENGE,
    Z1~MEINS,
    Z1~VBELN,
    Z1~POSNR,
    Z1~ZCHECK,
    Z1~APPUSER,
    Z1~ERDAT,
    Z1~AEDAT,
    T0~WAERS,
    Z1~COUNTQTY,
    Z1~DIFFAMT,
    Z1~IBLNR,
    Z1~BUDAT,
    Z1~MBLNR,
    Z1~APPREQ
    FROM ZGTMMT9490 AS Z1
                INNER JOIN
              T001W AS TW ON Z1~WERKS EQ TW~WERKS
               INNER JOIN
              T001K AS TK ON TW~BWKEY EQ TK~BWKEY
                INNER JOIN
              T001 AS T0 ON TK~BUKRS EQ T0~BUKRS
                LEFT OUTER JOIN
              MAKT AS MT ON Z1~MATNR EQ MT~MATNR
                                AND MT~SPRAS EQ @SY-LANGU
                LEFT OUTER JOIN
              T064B AS T1 ON Z1~BSTAR EQ T1~BSTAR
                                AND T1~SPRAS EQ @SY-LANGU
    WHERE Z1~INSMM EQ @P_INSMM
    AND Z1~WERKS EQ @P_WERKS
    AND Z1~LGORT IN @S_LGORT
    AND Z1~MATNR IN @S_MATNR
    AND Z1~CHARG IN @S_CHARG
    AND Z1~ZCHECK EQ @GC_P
    INTO CORRESPONDING FIELDS OF TABLE @GT_DISP_C.

  CHECK GT_DISP_C[] IS NOT INITIAL.

  SELECT SINGLE
    TK~BUKRS
    FROM T001W AS TW
                INNER JOIN
           T001K AS TK ON TW~BWKEY EQ TK~BWKEY
    WHERE TW~WERKS EQ @P_WERKS
    INTO @DATA(LV_BUKRS).

  SELECT
    Z1~PERNR,
    Z1~ENAME
    FROM ZZPA0001 AS Z1
    WHERE Z1~BUKRS EQ @LV_BUKRS
    AND Z1~ENDDA EQ '99991231'
    AND EXISTS (
##ITAB_KEY_IN_SELECT
      SELECT @ABAP_TRUE
        FROM @GT_DISP_C AS ZZ
        WHERE ZZ~APPUSER EQ Z1~PERNR
    )
    ORDER BY Z1~PERNR
    INTO TABLE @DATA(LT_HR).

  LOOP AT GT_DISP_C ASSIGNING FIELD-SYMBOL(<LS_DISP>).
*상태               STATUS      GREEN
*진행 상태                ZCHECK      ZCHECK="P" 이면 "조정완료" 로 표기   ZCHECK 필드값의 텍스트로 표기
    CASE <LS_DISP>-ZCHECK.
      WHEN GC_P.
        <LS_DISP>-STATUS = ICON_LED_GREEN.
        <LS_DISP>-ZCHECK_TEXT = TEXT-C03.
    ENDCASE.

    READ TABLE LT_HR ASSIGNING FIELD-SYMBOL(<LS_HR>) WITH KEY PERNR = <LS_DISP>-APPUSER BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_DISP>-APPUSER_TEXT = <LS_HR>-ENAME.
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_REFRESH_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_REFRESH_100 .

  "데이터 다시 조회
  PERFORM F_GET_LIST_DISP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_BCONF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_BCONF .

*1. 재고실사 차이 확정
*1-1) 라인은 다중 선택가능(전체선택포함)
*   : ALV의 동일한 실사년월 데이터 중 선택안된 데이터가 있어도 전체를 기준으로 실행함
*1-2) 선택한 라인이 없는 경우에도 실행 가능
*1-3) ALV 의 동일한 실사년월의 데이터 전체를 기준으로 후속 처리
*1-4) 선택한 라인의 ZCHECK ="C" 인 데이터가 존재하는 경우 하단 오류메세지 "확정 처리 대상이 아닙니다. 진행 상태를 확인하세요."
*1-5) ZCHECK="" 이고 오류가 없는 경우 하단 POP-UP 확인 후 이력 테이블 저장
  DATA:
    LT_CBO   TYPE STANDARD TABLE OF ZGTMMT9490,
    LV_CHECK TYPE C LENGTH 1,
    LV_ANS   TYPE C LENGTH 1,
    LT_ROW   TYPE LVC_T_ROID.

  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.
*>S.1-1) 라인은 다중 선택가능(전체선택포함): 조회 리스트에서 일부 데이터만 선택 하여도 확정 처리 가능으로 변경
  CALL METHOD GO_GRID_100->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW.
  DELETE LT_ROW WHERE ROW_ID LE 0.

  IF LT_ROW[] IS INITIAL.
*선택한 데이터가 없는 경우 오류 메세지 “선택한 데이터가 없습니다.”
    MESSAGE E163 .
*    DO LINES( GT_DISP_I ) TIMES.
*      LT_ROW = VALUE #( BASE LT_ROW ( ROW_ID = SY-INDEX ) ).
*    ENDDO.
  ENDIF.

  CHECK LT_ROW[] IS NOT INITIAL.
*<E.2026.08.05_ZGODEV04

  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_DISP_I ASSIGNING FIELD-SYMBOL(<LS_DISP>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.
*1-4) 선택한 라인의 ZCHECK ="C" 인 데이터가 존재하는 경우 하단 오류메세지 "확정 처리 대상이 아닙니다. 진행 상태를 확인하세요."
    IF <LS_DISP>-ZCHECK NE SPACE.
      MESSAGE E000 WITH TEXT-E01.
    ENDIF.

    LT_CBO = VALUE #( BASE LT_CBO ( INSMM = <LS_DISP>-INSMM
                                                           WERKS = <LS_DISP>-WERKS
                                                           LGORT = <LS_DISP>-LGORT
                                                           SEQNO = <LS_DISP>-SEQNO
                                                           MATNR = <LS_DISP>-MATNR
                                                           CHARG = <LS_DISP>-CHARG
                                                           TAGNR = <LS_DISP>-TAGNR
                                                           BSTAR = <LS_DISP>-BSTAR

                                                          COUNTQTY = <LS_DISP>-COUNTQTY
                                                          MENGE = <LS_DISP>-MENGE
                                                          MEINS = <LS_DISP>-MEINS
                                                          VBELN = <LS_DISP>-VBELN
                                                          POSNR = <LS_DISP>-POSNR
                                                          INVDA = <LS_DISP>-INVDA

                                                          APPUSER = <LS_DISP>-APPUSER
                                                          ZCHECK = GC_C


                                                          ERDAT = SY-DATUM
                                                          ERDAT_LOCAL = SY-DATLO
                                                          ERTIM = SY-UZEIT
                                                          ERTIM_LOCAL = SY-TIMLO
                                                          ERNAM = SY-UNAME
                                                           ) ).
  ENDLOOP.

*1-5) ZCHECK="" 이고 오류가 없는 경우 하단 POP-UP 확인 후 이력 테이블 저장
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT1
      TEXT_QUESTION = TEXT-Q01 "재고실사 내역 확정 처리 하시겠습니까?
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.

  MODIFY ZGTMMT9490 FROM TABLE LT_CBO.
  COMMIT WORK.

  LOOP AT LT_ROW ASSIGNING <LS_ROW>.
    READ TABLE GT_DISP_I ASSIGNING <LS_DISP> INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.
    <LS_DISP>-STATUS = ICON_LED_YELLOW.
    <LS_DISP>-ZCHECK = GC_C.
    <LS_DISP>-ZCHECK_TEXT = TEXT-C02.

  ENDLOOP.

  "메세지
  MESSAGE S000 WITH TEXT-M01."

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_BCANC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_BCANC .
*2. 재고실사 차이 확정취소
*2-1) 라인은 다중 선택가능(전체선택포함)
*   : ALV의 동일한 실사년월 데이터 중 선택안된 데이터가 있어도 전체를 기준으로 실행함
*2-2) 선택한 라인이 없는 경우에도 실행 가능
*2-3) ALV 의 동일한 실사년월의 데이터 전체를 기준으로 후속 처리
*2-4) 선택한 라인의 ZCHECK <>C 인 데이터가 존재하는 경우 하단 오류메세지 "확정취소 대상이 아닙니다. 진행 상태를 확인하세요."
*2-5) ZCHECK="C" 이고 오류가 없는 경우 하단 POP-UP 확인 후 진행상태값 업데이트
  DATA:
    LT_CBO   TYPE STANDARD TABLE OF ZGTMMT9490,
    LV_CHECK TYPE C LENGTH 1,
    LV_ANS   TYPE C LENGTH 1,
    LT_ROW   TYPE LVC_T_ROID.

  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

*>S.1-1) 라인은 다중 선택가능(전체선택포함): 조회 리스트에서 일부 데이터만 선택 하여도 확정 처리 가능으로 변경
  CALL METHOD GO_GRID_100->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW.
  DELETE LT_ROW WHERE ROW_ID LE 0.

  IF LT_ROW[] IS INITIAL.
*선택한 데이터가 없는 경우 오류 메세지 “선택한 데이터가 없습니다.”
    MESSAGE E163 .
*    DO LINES( GT_DISP_I ) TIMES.
*      LT_ROW = VALUE #( BASE LT_ROW ( ROW_ID = SY-INDEX ) ).
*    ENDDO.
  ENDIF.

  CHECK LT_ROW[] IS NOT INITIAL.
*<E.2026.08.06_ZGODEV04

  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_DISP_I ASSIGNING FIELD-SYMBOL(<LS_DISP>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.
*2-4) 선택한 라인의 ZCHECK <>C 인 데이터가 존재하는 경우 하단 오류메세지 "확정취소 대상이 아닙니다. 진행 상태를 확인하세요."
    IF <LS_DISP>-ZCHECK NE GC_C.
      MESSAGE E000 WITH TEXT-E02.
    ENDIF.

    LT_CBO = VALUE #( BASE LT_CBO ( INSMM = <LS_DISP>-INSMM
                                                           WERKS = <LS_DISP>-WERKS
                                                           LGORT = <LS_DISP>-LGORT
                                                           SEQNO = <LS_DISP>-SEQNO
                                                           MATNR = <LS_DISP>-MATNR
                                                           CHARG = <LS_DISP>-CHARG
                                                           TAGNR = <LS_DISP>-TAGNR
                                                           ZCHECK = SPACE
                                                           ERDAT = SY-DATUM
                                                           ERDAT_LOCAL = SY-DATLO
                                                           ERTIM = SY-UZEIT
                                                           ERTIM_LOCAL = SY-TIMLO
                                                           ERNAM = SY-UNAME
                                                           ) ).
  ENDLOOP.

*2-5) ZCHECK="C" 이고 오류가 없는 경우 하단 POP-UP 확인 후 진행상태값 업데이트
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT1
      TEXT_QUESTION = TEXT-Q02 "재고실사 내역 확정취소 하시겠습니까?
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.

  MODIFY ZGTMMT9490 FROM TABLE LT_CBO.
  COMMIT WORK.


  LOOP AT LT_ROW ASSIGNING <LS_ROW>.
    READ TABLE GT_DISP_I ASSIGNING <LS_DISP> INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.
    <LS_DISP>-STATUS = ICON_LED_INACTIVE.
    <LS_DISP>-ZCHECK = SPACE.
    <LS_DISP>-ZCHECK_TEXT = TEXT-C01.

  ENDLOOP.

  "메세지
  MESSAGE S000 WITH TEXT-M01."

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_LIST_APPV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_LIST_APPV .
*CASE 2 : 작업구분 "재고실사 승인"

  CASE ABAP_TRUE.
    WHEN P_COMPL. "처리 완료
      PERFORM F_GET_LIST_APPV_COMPL.
    WHEN P_INCOM. "미완료
      PERFORM F_GET_LIST_APPV_INCOM.
  ENDCASE.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_LIST_APPV_INCOM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_LIST_APPV_INCOM .

*1. 처리 상태 = 미완료 인 경우
*	1) 실행 조회조건 값을 기준으로 재고실사 조정 이력관리 테이블 조회
*	Table : ZGTMMT9490
*	Select 조건  : INSMM,WERKS,LGORT,SEQNO,BSTAR,MATNR,CHARG,TAGNR,MENGE,MEINS,ZCHECK,APPUSER,ERADT,VBELN,POSNR
*	WHERE조건
*	WERKS = 입력 플랜트
*	LGORT= 입력 저장위치
*	APPUSER = 입력 승인 담당자
*	: ZCHECK ="C" or "N" 이고, APPREQ = "Y" 인 데이터 추출
*
*2) SAP 현재 재고 정보 조회
*	CDS VIEW : ZGTMM_CV_GET_STOCKLIST
*	Select 조건
*	 : MEINS,LABST,INSME,SPEME
*	WHERE조건
*	BUKRS = 2) 의 대상 값
*	WERKS = 2)의 대상 값
*	LGORT = 2)의 대상 값
*	MATNR = 2)의 대상 값
*	CHARG = 2)의 대상값
*
*3) 기타 정보 추출
*	3-1) MAKTX = MAKT-MAKTX
*
*4) 추출한 데이터를 기준으로 ALV Display
*	**ALV-DISPLAY
*	: 상세필드정보는 화면 에이아웃 시트에 정의

  CLEAR GT_APPV[].
  "<--2026.06.09 재고기준/담당자 기준 변경
  IF P_APPUS IS NOT INITIAL.
    SELECT
      Z1~INSMM,
      Z1~INVDA,
      Z1~WERKS,
      Z1~LGORT,
      Z1~SEQNO,
      Z1~MATNR,
      MT~MAKTX,
      Z1~CHARG,
      Z1~TAGNR,
      Z1~BSTAR,
      T1~BTEXT,
      Z1~MENGE,
      Z1~MEINS,
      Z1~VBELN,
      Z1~POSNR,
      Z1~ZCHECK,
      Z1~APPUSER,
      Z1~ERDAT,
      Z1~AEDAT,
      T0~WAERS,
      Z1~BUDAT,
      Z1~MBLNR,
      TW~BWKEY,
      Z1~APPREQ,
      IK~IBLNR,
      IS~ZEILI AS ITEM,
      IK~ZSTAT,
      IK~DSTAT,
      Z2~MENGE AS STOCKQTY, "2026.06.09 추가
      Z2~MEINS   AS STOCKUNIT  "2026.06.09 추가
      FROM ZGTMMT9490 AS Z1
                  INNER JOIN
                T001W AS TW ON Z1~WERKS EQ TW~WERKS
                 INNER JOIN
                T001K AS TK ON TW~BWKEY EQ TK~BWKEY
                  INNER JOIN
                T001 AS T0 ON TK~BUKRS EQ T0~BUKRS
                  LEFT OUTER JOIN
                MAKT AS MT ON Z1~MATNR EQ MT~MATNR
                                  AND MT~SPRAS EQ @SY-LANGU
                  LEFT OUTER JOIN
                T064B AS T1 ON Z1~BSTAR EQ T1~BSTAR
                                  AND T1~SPRAS EQ @SY-LANGU
                  LEFT OUTER JOIN
                IKPF AS IK ON Z1~IBLNR EQ IK~IBLNR
                            AND IK~GJAHR EQ @P_INSMM+0(4)
                  LEFT OUTER JOIN
                ISEG AS IS ON Z1~IBLNR EQ IS~IBLNR
                              AND Z1~ITEM EQ IS~ZEILI
                              AND IS~GJAHR EQ @P_INSMM+0(4)
          "<--2026.06.09 재고기준/담당자 기준 변경
              LEFT OUTER JOIN     "재고 없는 경우 테이블에 값이 없음
             ZGTPPT4090 AS Z2 ON Z1~INSMM EQ Z2~INSMM
                                         AND Z1~WERKS EQ Z2~WERKS
                                         AND Z1~LGORT EQ Z2~LGORT
                                         AND Z1~MATNR EQ Z2~MATNR
                                         AND Z1~CHARG EQ Z2~CHARG
                                         AND Z1~POSNR EQ Z2~POSNR
*>S.2026.07.28_전송상태값이 '00'인 데이터 기준..추가
                                         AND Z2~ZSTAT = '00'
*<E.2026.07.28_ZGODEV04.
  " 2026.06.09 재고기준/담당자 기준 변경-->
      WHERE Z1~INSMM EQ @P_INSMM
      AND Z1~WERKS EQ @P_WERKS
      AND Z1~LGORT IN @S_LGORT
      AND Z1~APPUSER EQ @GV_APPUSER"P_APPUS
      AND Z1~ZCHECK IN ( @GC_C, @GC_N )
      AND Z1~APPREQ EQ @GC_Y
*>S.260804_조회된 최신 차수(ZGTPPT4090-ZCOUNT) 기준 전송 상태값이 “00” 인 데이터 조회
      AND ( Z2~ZCOUNT IS NULL OR Z2~ZCOUNT EQ (
            SELECT MAX( SUB_Z2~ZCOUNT )
              FROM ZGTPPT4090 AS SUB_Z2
             WHERE SUB_Z2~INSMM EQ Z1~INSMM
               AND SUB_Z2~WERKS EQ Z1~WERKS
               AND SUB_Z2~LGORT EQ Z1~LGORT
               AND SUB_Z2~MATNR EQ Z1~MATNR
               AND SUB_Z2~CHARG EQ Z1~CHARG
               AND SUB_Z2~VBELN EQ Z1~VBELN
               AND SUB_Z2~POSNR EQ Z1~POSNR
               AND SUB_Z2~ZSTAT = '00'
           ) )
*<E.260804_ZGODEV04.
      INTO CORRESPONDING FIELDS OF TABLE @GT_APPV.

  ELSE.
    SELECT
  Z1~INSMM,
  Z1~INVDA,
  Z1~WERKS,
  Z1~LGORT,
  Z1~SEQNO,
  Z1~MATNR,
  MT~MAKTX,
  Z1~CHARG,
  Z1~TAGNR,
  Z1~BSTAR,
  T1~BTEXT,
  Z1~MENGE,
  Z1~MEINS,
  Z1~VBELN,
  Z1~POSNR,
  Z1~ZCHECK,
  Z1~APPUSER,
  Z1~ERDAT,
  Z1~AEDAT,
  T0~WAERS,
  Z1~BUDAT,
  Z1~MBLNR,
  TW~BWKEY,
  Z1~APPREQ,
  IK~IBLNR,
  IS~ZEILI AS ITEM,
  IK~ZSTAT,
  IK~DSTAT,
  Z2~MENGE AS STOCKQTY, "2026.06.09 추가
  Z2~MEINS   AS STOCKUNIT  "2026.06.09 추가
  FROM ZGTMMT9490 AS Z1
              INNER JOIN
            T001W AS TW ON Z1~WERKS EQ TW~WERKS
             INNER JOIN
            T001K AS TK ON TW~BWKEY EQ TK~BWKEY
              INNER JOIN
            T001 AS T0 ON TK~BUKRS EQ T0~BUKRS
              LEFT OUTER JOIN
            MAKT AS MT ON Z1~MATNR EQ MT~MATNR
                              AND MT~SPRAS EQ @SY-LANGU
              LEFT OUTER JOIN
            T064B AS T1 ON Z1~BSTAR EQ T1~BSTAR
                              AND T1~SPRAS EQ @SY-LANGU
              LEFT OUTER JOIN
            IKPF AS IK ON Z1~IBLNR EQ IK~IBLNR
                        AND IK~GJAHR EQ @P_INSMM+0(4)
              LEFT OUTER JOIN
            ISEG AS IS ON Z1~IBLNR EQ IS~IBLNR
                          AND Z1~ITEM EQ IS~ZEILI
                          AND IS~GJAHR EQ @P_INSMM+0(4)
          "<--2026.06.09 재고기준/담당자 기준 변경
              LEFT OUTER JOIN     "재고 없는 경우 테이블에 값이 없음
             ZGTPPT4090 AS Z2 ON Z1~INSMM EQ Z2~INSMM
                                         AND Z1~WERKS EQ Z2~WERKS
                                         AND Z1~LGORT EQ Z2~LGORT
                                         AND Z1~MATNR EQ Z2~MATNR
                                         AND Z1~CHARG EQ Z2~CHARG
                                         AND Z1~POSNR EQ Z2~POSNR
*>S.2026.07.28_전송상태값이 '00'인 데이터 기준..추가
                                         AND Z2~ZSTAT = '00'
*<E.2026.07.28_ZGODEV04.
  " 2026.06.09 재고기준/담당자 기준 변경-->
  WHERE Z1~INSMM EQ @P_INSMM
  AND Z1~WERKS EQ @P_WERKS
  AND Z1~LGORT IN @S_LGORT
*      AND Z1~APPUSER EQ @P_APPUS
  AND Z1~ZCHECK IN ( @GC_C, @GC_N )
  AND Z1~APPREQ EQ @GC_Y
*>S.260804_조회된 최신 차수(ZGTPPT4090-ZCOUNT) 기준 전송 상태값이 “00” 인 데이터 조회
  AND ( Z2~ZCOUNT IS NULL OR Z2~ZCOUNT EQ (
            SELECT MAX( SUB_Z2~ZCOUNT )
              FROM ZGTPPT4090 AS SUB_Z2
             WHERE SUB_Z2~INSMM EQ Z1~INSMM
               AND SUB_Z2~WERKS EQ Z1~WERKS
               AND SUB_Z2~LGORT EQ Z1~LGORT
               AND SUB_Z2~MATNR EQ Z1~MATNR
               AND SUB_Z2~CHARG EQ Z1~CHARG
               AND SUB_Z2~VBELN EQ Z1~VBELN
               AND SUB_Z2~POSNR EQ Z1~POSNR
               AND SUB_Z2~ZSTAT = '00'
           ) )
*<E.260804_ZGODEV04.
  INTO CORRESPONDING FIELDS OF TABLE @GT_APPV.
  ENDIF.

*    SELECT
*    Z1~INSMM,
*    Z1~INVDA,
*    Z1~WERKS,
*    Z1~LGORT,
*    Z1~SEQNO,
*    Z1~MATNR,
*    MT~MAKTX,
*    Z1~CHARG,
*    Z1~TAGNR,
*    Z1~BSTAR,
*    T1~BTEXT,
*    Z1~MENGE,
*    Z1~MEINS,
*    Z1~VBELN,
*    Z1~POSNR,
*    Z1~ZCHECK,
*    Z1~APPUSER,
*    Z1~ERDAT,
*    Z1~AEDAT,
*    T0~WAERS,
*    Z1~BUDAT,
*    Z1~MBLNR,
*    TW~BWKEY,
*    Z1~APPREQ,
*    IK~IBLNR,
*    IS~ZEILI AS ITEM,
*    IK~ZSTAT,
*    IK~DSTAT
*    FROM ZGTMMT9490 AS Z1
*                INNER JOIN
*              T001W AS TW ON Z1~WERKS EQ TW~WERKS
*               INNER JOIN
*              T001K AS TK ON TW~BWKEY EQ TK~BWKEY
*                INNER JOIN
*              T001 AS T0 ON TK~BUKRS EQ T0~BUKRS
*                LEFT OUTER JOIN
*              MAKT AS MT ON Z1~MATNR EQ MT~MATNR
*                                AND MT~SPRAS EQ @SY-LANGU
*                LEFT OUTER JOIN
*              T064B AS T1 ON Z1~BSTAR EQ T1~BSTAR
*                                AND T1~SPRAS EQ @SY-LANGU
*                LEFT OUTER JOIN
*              IKPF AS IK ON Z1~IBLNR EQ IK~IBLNR
*                          AND IK~GJAHR EQ @P_INSMM+0(4)
*                LEFT OUTER JOIN
*              ISEG AS IS ON Z1~IBLNR EQ IS~IBLNR
*                            AND Z1~ITEM EQ IS~ZEILI
*                            AND IS~GJAHR EQ @P_INSMM+0(4)
*    WHERE Z1~INSMM EQ @P_INSMM
*    AND Z1~WERKS EQ @P_WERKS
*    AND Z1~LGORT IN @S_LGORT
*    AND Z1~APPUSER EQ @P_APPUS
*    AND Z1~ZCHECK IN ( @GC_C, @GC_N )
*    AND Z1~APPREQ EQ @GC_Y
*    INTO CORRESPONDING FIELDS OF TABLE @GT_APPV.
  " 2026.06.09 재고기준/담당자 기준 변경-->


  CHECK GT_APPV[] IS NOT INITIAL.

  SELECT SINGLE
    TK~BUKRS
    FROM T001W AS TW
                INNER JOIN
           T001K AS TK ON TW~BWKEY EQ TK~BWKEY
    WHERE TW~WERKS EQ @P_WERKS
    INTO @DATA(LV_BUKRS).

  "승인 담당자 이름
  SELECT
    Z1~PERNR,
    Z1~ENAME
    FROM ZZPA0001 AS Z1
    WHERE Z1~BUKRS EQ @LV_BUKRS
    AND Z1~ENDDA EQ '99991231'
    AND EXISTS (
##ITAB_KEY_IN_SELECT
      SELECT @ABAP_TRUE
        FROM @GT_APPV AS ZZ
        WHERE ZZ~APPUSER EQ Z1~PERNR
    )
    ORDER BY Z1~PERNR
    INTO TABLE @DATA(LT_HR).

*2) SAP 현재 재고 정보 조회
*	CDS VIEW : ZGTMM_CV_GET_STOCKLIST
*	Select 조건
*	 : MEINS,LABST,INSME,SPEME
*	WHERE조건
*	BUKRS = 2) 의 대상 값
*	WERKS = 2)의 대상 값
*	LGORT = 2)의 대상 값
*	MATNR = 2)의 대상 값
*	CHARG = 2)의 대상값

  "<--2026.06.09 재고기준/담당자 기준 변경

*  SELECT
*      V1~WERKS,
*      V1~LGORT,
*      V1~MATNR,
*      V1~CHARG,
*      V1~MEINS,
*      V1~LABST,
*      V1~INSME,
*      V1~SPEME
*    FROM ZGTMM_CV_GET_STOCKLIST AS V1
*    WHERE EXISTS (
*##ITAB_KEY_IN_SELECT
*      SELECT @ABAP_TRUE
*        FROM @GT_APPV AS ZZ
*        WHERE ZZ~WERKS EQ V1~WERKS
*           AND ZZ~LGORT EQ V1~LGORT
*           AND ZZ~MATNR EQ V1~MATNR
*           AND ZZ~CHARG EQ V1~CHARG
*    )
*    ORDER BY V1~WERKS, V1~LGORT, V1~MATNR, V1~CHARG
*    INTO TABLE @DATA(LT_STOCK).

  " 2026.06.09 재고기준/담당자 기준 변경-->


*"표준원가를 기준으로 계산한 값으로 표기
*1) 자재 단가, 가격단위 조회
*Table: MBEW
*SELECT 조건: STPRS,PEINH
*WHERE 조건 :
*MATNR = ZPPT0600-MATNR
*BWKEY = ZPPT0600-WERKS
*2) 평가영역 회사코드 조회
*Table : T001K
*SELECT 조건 : BUKRS
*WHERE 조건 : BWKEY = ZPPT0600-WERKS
*3) 조회한 BUKRS 값의 통화키 점검
*Table : T001
*SELECT 조건 : WAERS
*WHERE 조건 :
*BUKRS = 2) 의 BUKRS
*WAERS = KRW 이면 1)의 STPRS*100 으로 최종 원가 산출하여 재고금액 계산"
  SELECT
    MW~MATNR,
    MW~BWKEY,
    MW~STPRS,
    MW~PEINH
    FROM MBEW AS MW
    WHERE EXISTS (
##ITAB_KEY_IN_SELECT
      SELECT @ABAP_TRUE
        FROM @GT_APPV AS ZZ
        WHERE ZZ~MATNR EQ MW~MATNR
          AND ZZ~BWKEY EQ MW~BWKEY
    )
    ORDER BY MW~MATNR, MW~BWKEY
    INTO TABLE @DATA(LT_MBEW).

  LOOP AT GT_APPV ASSIGNING FIELD-SYMBOL(<LS_APPV>).
*상태               STATUS      ZCHECK = "C" 이면 RED
*진행상태               ZCHECK      ZCHECK="C" 이면 "확정완료" 로 표기   ZCHECK 필드값의 텍스트로 표기
    CASE <LS_APPV>-ZCHECK.
      WHEN GC_C.
        <LS_APPV>-STATUS = ICON_LED_RED.
        <LS_APPV>-ZCHECK_TEXT = TEXT-C02.
      WHEN GC_N.
        <LS_APPV>-STATUS = ICON_LED_RED.
        <LS_APPV>-ZCHECK_TEXT = TEXT-C04.
    ENDCASE.

*SAP 재고수량               STOCKQTY      "1) BSTAR = ""1"" 이면
*ZGTMM_CV_GET_STOCKLIST-LABST
*2) BSTAR = ""2"" 이면
*ZGTMM_CV_GET_STOCKLIST-INSME
*2) BSTAR = ""4"" 이면
*ZGTMM_CV_GET_STOCKLIST-SPEME"    "BSTAR 값에 따라 재고 상태별 수량 표기
*ALV 필드 컬럼 색 :  YELLOW
*"
*SAP 재고 단위                STOCKUNIT     ZGTMM_CV_GET_STOCKLIST-STOCKUNIT


    "<--2026.06.09 재고기준/담당자 기준 변경
*    READ TABLE LT_STOCK ASSIGNING FIELD-SYMBOL(<LS_STOCK>)
*                                 WITH KEY WERKS = <LS_APPV>-WERKS
*                                              LGORT = <LS_APPV>-LGORT
*                                              MATNR = <LS_APPV>-MATNR
*                                              CHARG = <LS_APPV>-CHARG BINARY SEARCH.
*    IF SY-SUBRC EQ 0.
*      <LS_APPV>-STOCKUNIT = <LS_STOCK>-MEINS.
*      CASE <LS_APPV>-BSTAR.
*        WHEN '1'.
*          <LS_APPV>-STOCKQTY = <LS_STOCK>-LABST.
*        WHEN '2'.
*          <LS_APPV>-STOCKQTY = <LS_STOCK>-INSME.
*        WHEN '4'.
*          <LS_APPV>-STOCKQTY = <LS_STOCK>-SPEME.
*      ENDCASE.
*    ENDIF.
    " 2026.06.09 재고기준/담당자 기준 변경-->
*실사수량               COUNTQTY      STOCKQTY-MENGE    "ALV 필드 컬럼 색 : GREEN
*(계산식 변경)"
*>S.2026.07.27_실사수량 계산식 변경(SAP재고수량+차이수량)
*    <LS_APPV>-COUNTQTY = <LS_APPV>-STOCKQTY - <LS_APPV>-MENGE.
    <LS_APPV>-COUNTQTY = <LS_APPV>-STOCKQTY + <LS_APPV>-MENGE.
*<E.2026.07.27_ZGODEV04.

*차이금액               DIFFAMT     "계산식= MENGE*표준원가/가격단위
*"    "표준원가를 기준으로 계산한 값으로 표기
*1) 자재 단가, 가격단위 조회
*Table: MBEW
*SELECT 조건: STPRS,PEINH
*WHERE 조건 :
*MATNR = ZPPT0600-MATNR
*BWKEY = ZPPT0600-WERKS
*2) 평가영역 회사코드 조회
*Table : T001K
*SELECT 조건 : BUKRS
*WHERE 조건 : BWKEY = ZPPT0600-WERKS
*3) 조회한 BUKRS 값의 통화키 점검
*Table : T001
*SELECT 조건 : WAERS
*WHERE 조건 :
*BUKRS = 2) 의 BUKRS
*WAERS = KRW 이면 1)의 STPRS*100 으로 최종 원가 산출하여 재고금액 계산"

    READ TABLE LT_MBEW ASSIGNING FIELD-SYMBOL(<LS_MBEW>)
      WITH KEY MATNR = <LS_APPV>-MATNR
                     BWKEY = <LS_APPV>-BWKEY BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      IF <LS_MBEW>-PEINH IS NOT INITIAL.
        <LS_APPV>-DIFFAMT = ( <LS_APPV>-MENGE * <LS_MBEW>-STPRS )  / <LS_MBEW>-PEINH .
      ENDIF.
    ENDIF.

    READ TABLE LT_HR ASSIGNING FIELD-SYMBOL(<LS_HR>) WITH KEY PERNR = <LS_APPV>-APPUSER BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_APPV>-APPUSER_TEXT = <LS_HR>-ENAME.
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_LIST_APPV_COMPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_LIST_APPV_COMPL .

*2. 처리 상태 = 처리 완료인 경우
*	1) 실행 조회조건 값을 기준으로 재고실사 조정 이력관리 테이블 조회
*	Table : ZGTMMT9490
*	Select 조건  : INSMM,WERKS,LGORT,SEQNO,MATNR,CHARG,TAGNR,BSTAR,COUNTQTY,DIFFAMT,APPUSER,ERADT,ERTIM,ZCHECK,VBELN,POSNR
*	WHERE조건
*	WERKS = 입력 플랜트
*	LGORT= 입력 저장위치
*	: ZCHECK ="P" 인 데이터 추출
*
*	2) 기타 정보 추출
*   2-1) MAKTX = MAKT-MAKTX
*
*	3) 추출한 데이터를 기준으로 ALV Display
*   **ALV-DISPLAY
*   : 상세필드정보는 화면 에이아웃 시트에 정의

  "초기화
  CLEAR GT_APPV[].
  "<--2026.06.09 재고기준/담당자 기준 변경
  IF P_APPUS IS NOT INITIAL.
    SELECT
     Z1~INSMM,
     Z1~INVDA,
     Z1~WERKS,
     Z1~LGORT,
     Z1~SEQNO,
     Z1~MATNR,
     MT~MAKTX,
     Z1~CHARG,
     Z1~TAGNR,
     Z1~BSTAR,
     T1~BTEXT,
     Z1~MENGE,
     Z1~MEINS,
     Z1~VBELN,
     Z1~POSNR,
     Z1~ZCHECK,
     Z1~APPUSER,
     Z1~ERDAT,
     Z1~AEDAT,
     T0~WAERS,
     Z1~COUNTQTY,
     Z1~DIFFAMT,
     Z1~IBLNR,
     Z1~BUDAT,
     Z1~MBLNR,
     Z1~APPREQ,
     IK~ZSTAT,
     IK~DSTAT
     FROM ZGTMMT9490 AS Z1
                 INNER JOIN
               T001W AS TW ON Z1~WERKS EQ TW~WERKS
                INNER JOIN
               T001K AS TK ON TW~BWKEY EQ TK~BWKEY
                 INNER JOIN
               T001 AS T0 ON TK~BUKRS EQ T0~BUKRS
                 LEFT OUTER JOIN
               MAKT AS MT ON Z1~MATNR EQ MT~MATNR
                                 AND MT~SPRAS EQ @SY-LANGU
                 LEFT OUTER JOIN
               T064B AS T1 ON Z1~BSTAR EQ T1~BSTAR
                                 AND T1~SPRAS EQ @SY-LANGU
                 LEFT OUTER JOIN
               IKPF AS IK ON Z1~IBLNR EQ IK~IBLNR
                           AND IK~GJAHR EQ @P_INSMM+0(4)
     WHERE Z1~INSMM EQ @P_INSMM
     AND Z1~WERKS EQ @P_WERKS
     AND Z1~LGORT IN @S_LGORT
     AND Z1~APPUSER EQ @GV_APPUSER"P_APPUS
     AND Z1~ZCHECK EQ @GC_P
     INTO CORRESPONDING FIELDS OF TABLE @GT_APPV.

  ELSE.
    SELECT
     Z1~INSMM,
     Z1~INVDA,
     Z1~WERKS,
     Z1~LGORT,
     Z1~SEQNO,
     Z1~MATNR,
     MT~MAKTX,
     Z1~CHARG,
     Z1~TAGNR,
     Z1~BSTAR,
     T1~BTEXT,
     Z1~MENGE,
     Z1~MEINS,
     Z1~VBELN,
     Z1~POSNR,
     Z1~ZCHECK,
     Z1~APPUSER,
     Z1~ERDAT,
     Z1~AEDAT,
     T0~WAERS,
     Z1~COUNTQTY,
     Z1~DIFFAMT,
     Z1~IBLNR,
     Z1~BUDAT,
     Z1~MBLNR,
     Z1~APPREQ,
     IK~ZSTAT,
     IK~DSTAT
     FROM ZGTMMT9490 AS Z1
                 INNER JOIN
               T001W AS TW ON Z1~WERKS EQ TW~WERKS
                INNER JOIN
               T001K AS TK ON TW~BWKEY EQ TK~BWKEY
                 INNER JOIN
               T001 AS T0 ON TK~BUKRS EQ T0~BUKRS
                 LEFT OUTER JOIN
               MAKT AS MT ON Z1~MATNR EQ MT~MATNR
                                 AND MT~SPRAS EQ @SY-LANGU
                 LEFT OUTER JOIN
               T064B AS T1 ON Z1~BSTAR EQ T1~BSTAR
                                 AND T1~SPRAS EQ @SY-LANGU
                 LEFT OUTER JOIN
               IKPF AS IK ON Z1~IBLNR EQ IK~IBLNR
                           AND IK~GJAHR EQ @P_INSMM+0(4)
     WHERE Z1~INSMM EQ @P_INSMM
     AND Z1~WERKS EQ @P_WERKS
     AND Z1~LGORT IN @S_LGORT
*     AND Z1~APPUSER EQ @P_APPUS
     AND Z1~ZCHECK EQ @GC_P
     INTO CORRESPONDING FIELDS OF TABLE @GT_APPV.
  ENDIF.

*   SELECT
*    Z1~INSMM,
*    Z1~INVDA,
*    Z1~WERKS,
*    Z1~LGORT,
*    Z1~SEQNO,
*    Z1~MATNR,
*    MT~MAKTX,
*    Z1~CHARG,
*    Z1~TAGNR,
*    Z1~BSTAR,
*    T1~BTEXT,
*    Z1~MENGE,
*    Z1~MEINS,
*    Z1~VBELN,
*    Z1~POSNR,
*    Z1~ZCHECK,
*    Z1~APPUSER,
*    Z1~ERDAT,
*    Z1~AEDAT,
*    T0~WAERS,
*    Z1~COUNTQTY,
*    Z1~DIFFAMT,
*    Z1~IBLNR,
*    Z1~BUDAT,
*    Z1~MBLNR,
*    Z1~APPREQ,
*    IK~ZSTAT,
*    IK~DSTAT
*    FROM ZGTMMT9490 AS Z1
*                INNER JOIN
*              T001W AS TW ON Z1~WERKS EQ TW~WERKS
*               INNER JOIN
*              T001K AS TK ON TW~BWKEY EQ TK~BWKEY
*                INNER JOIN
*              T001 AS T0 ON TK~BUKRS EQ T0~BUKRS
*                LEFT OUTER JOIN
*              MAKT AS MT ON Z1~MATNR EQ MT~MATNR
*                                AND MT~SPRAS EQ @SY-LANGU
*                LEFT OUTER JOIN
*              T064B AS T1 ON Z1~BSTAR EQ T1~BSTAR
*                                AND T1~SPRAS EQ @SY-LANGU
*                LEFT OUTER JOIN
*              IKPF AS IK ON Z1~IBLNR EQ IK~IBLNR
*                          AND IK~GJAHR EQ @P_INSMM+0(4)
*    WHERE Z1~INSMM EQ @P_INSMM
*    AND Z1~WERKS EQ @P_WERKS
*    AND Z1~LGORT IN @S_LGORT
*    AND Z1~APPUSER EQ @P_APPUS
*    AND Z1~ZCHECK EQ @GC_P
*    INTO CORRESPONDING FIELDS OF TABLE @GT_APPV.

  " 2026.06.09 재고기준/담당자 기준 변경-->

  CHECK GT_APPV[] IS NOT INITIAL.

  SELECT SINGLE
    TK~BUKRS
    FROM T001W AS TW
                INNER JOIN
           T001K AS TK ON TW~BWKEY EQ TK~BWKEY
    WHERE TW~WERKS EQ @P_WERKS
    INTO @DATA(LV_BUKRS).

  "승인 담당자 이름
  SELECT
    Z1~PERNR,
    Z1~ENAME
    FROM ZZPA0001 AS Z1
    WHERE Z1~BUKRS EQ @LV_BUKRS
    AND Z1~ENDDA EQ '99991231'
    AND EXISTS (
##ITAB_KEY_IN_SELECT
      SELECT @ABAP_TRUE
        FROM @GT_APPV AS ZZ
        WHERE ZZ~APPUSER EQ Z1~PERNR
    )
    ORDER BY Z1~PERNR
    INTO TABLE @DATA(LT_HR).

  LOOP AT GT_APPV ASSIGNING FIELD-SYMBOL(<LS_APPV>).
*상태               STATUS      GREEN
*진행 상태                ZCHECK      ZCHECK="P" 이면 "조정완료" 로 표기   ZCHECK 필드값의 텍스트로 표기
    CASE <LS_APPV>-ZCHECK.
      WHEN GC_P.
        <LS_APPV>-STATUS = ICON_LED_GREEN.
        <LS_APPV>-ZCHECK_TEXT = TEXT-C03.
    ENDCASE.

    READ TABLE LT_HR ASSIGNING FIELD-SYMBOL(<LS_HR>) WITH KEY PERNR = <LS_APPV>-APPUSER BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_APPV>-APPUSER_TEXT = <LS_HR>-ENAME.
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_REFRESH_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_REFRESH_200 .

  "데이터 다시 조회
  PERFORM F_GET_LIST_APPV.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ACONF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ACONF .

*3-1) 라인은 다중 선택가능(전체선택포함)
*   : ALV의 동일한 실사년월 데이터 중 선택안된 데이터가 있어도 전체를 기준으로 실행함
*3-2) 선택한 라인이 없는 경우에도 실행 가능
*3-3) ALV 의 동일한 실사년월의 데이터 전체를 기준으로 후속 처리
*3-4) 선택한 라인에 ZCHECK <>"C" 인 데이터가 존재하는 경우 하단 오류메세지 "차이조정 승인 대상이 아닙니다. 진행 상태를 확인하세요."
*3-5) ZCHECK="C" or  "N" 이고 오류가 없는 경우 하단 POP-UP 확인 후 이력 테이블 저장

  DATA:
    LT_CBO     TYPE STANDARD TABLE OF ZGTMMT9490,
    LV_CHECK   TYPE C LENGTH 1,
    LV_ERROR   TYPE C LENGTH 1,
    LV_MESSAGE TYPE BAPI_MSG,
    LV_ANS     TYPE C LENGTH 1,
    LT_ROW     TYPE LVC_T_ROID.

  CALL METHOD GO_GRID_200->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

*  CALL METHOD GO_GRID_200->GET_SELECTED_ROWS
*    IMPORTING
*      ET_ROW_NO = LT_ROW.
*  DELETE LT_ROW WHERE ROW_ID LE 0.

  IF LT_ROW[] IS INITIAL.
    DO LINES( GT_APPV ) TIMES.
      LT_ROW = VALUE #( BASE LT_ROW ( ROW_ID = SY-INDEX ) ).
    ENDDO.
  ENDIF.

  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_APPV ASSIGNING FIELD-SYMBOL(<LS_APPV>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.
*3-4) 선택한 라인에 ZCHECK <>"C" 인 데이터가 존재하는 경우 하단 오류메세지 "차이조정 승인 대상이 아닙니다. 진행 상태를 확인하세요."
*3-5) ZCHECK="C" or  "N" 이고 오류가 없는 경우 하단 POP-UP 확인 후 이력 테이블 저장
    IF <LS_APPV>-ZCHECK NE GC_C
      AND <LS_APPV>-ZCHECK NE GC_N.
      MESSAGE E000 WITH TEXT-E05.
    ENDIF.
  ENDLOOP.

*실사년월 ALV-INSMM" 의 말일자로 조정처리 됩니다.
*승인 하시겠습니까?
  DATA:
    LV_INSMM    TYPE C LENGTH 7,
    LV_QUESTION TYPE C LENGTH 100.

  WRITE P_INSMM TO LV_INSMM LEFT-JUSTIFIED NO-GAP.
  LV_QUESTION = |{ TEXT-F03 } "{ LV_INSMM }" { TEXT-MS1 }|.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT1
      TEXT_QUESTION = LV_QUESTION
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.

*3-6-1) Yes 선택 시 재고실사문서 생성-Count-조정 처리 BAPI 순차 수행
*3-6-2) ZCHECK="N"일때 재고실사문서가 존재하고, 실사 문서 상태 IKPF-ZSTAT = "" or "A" 이면 BAPI_MATPHYSINV_COUNT 부터 수행
*3-6-3) ZCHECK="N" 일때 재고실사문서가 존재하고, 실사 문서 상태 IKPF-DSTAT = "" or "A" 이면 BAPI_MATPHYSINV_POSTDIFF 부터 수행

  CLEAR:
    LV_CHECK, LV_ERROR, LV_MESSAGE.
*3-6) 재고실사 문서 생성 (BAPI_MATPHYSINV_CREATE)
  PERFORM F_BAPI_MATPHYSINV_CREATE USING LT_ROW CHANGING LV_ERROR LV_MESSAGE.
  IF LV_ERROR EQ GC_E.
    LV_CHECK = GC_E.
    LV_MESSAGE = TEXT-E06. "재고실사 문서 생성 실패하였습니다
  ENDIF.

*3-7) 재고실사 문서 COUNT 입력 (BAPI_MATPHYSINV_COUNT)
  CLEAR LV_ERROR.
  PERFORM F_BAPI_MATPHYSINV_COUNT USING LT_ROW CHANGING LV_ERROR LV_MESSAGE.
  IF LV_ERROR EQ GC_E.
    LV_CHECK = GC_E.
    LV_MESSAGE = TEXT-E07. "재고실사 결과 입력 실패하였습니다.
  ENDIF.

*3-8) 재고실사 문서 전기 (BAPI_MATPHYSINV_POSTDIFF)
  CLEAR LV_ERROR.
  PERFORM F_BAPI_MATPHYSINV_POSTDIFF USING LT_ROW CHANGING LV_ERROR LV_MESSAGE.
  IF LV_ERROR EQ GC_E.
    LV_CHECK = GC_E.
    LV_MESSAGE = TEXT-E08. "재고실사 조정 전기 실패하였습니다.
  ENDIF.

  " 실사 완전히 성공한 경우에만 차이수량 0 데이터 UPDATE
  IF LV_CHECK NE GC_E.
    "차이수량 0인 데이터 저장
    PERFORM F_SAVE_DIFF_ZERO USING LT_ROW.
  ENDIF.

  IF LV_CHECK NE GC_E.
*    : 하단 완료 메시지 처리 "재고실사 조정 전기 완료하였습니다."
    MESSAGE S000 WITH TEXT-M02.".
  ELSE.
    MESSAGE S000 DISPLAY LIKE GC_E WITH LV_MESSAGE.".
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ACANC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ACANC .

*4. 재고실사 조정 반려
*4-1) 라인은 다중 선택가능(전체선택포함)
*   : ALV의 동일한 실사년월 데이터 중 선택안된 데이터가 있어도 전체를 기준으로 실행함
*4-2) 선택한 라인이 없는 경우에도 실행 가능
*4-3) ALV 의 동일한 실사년월의 데이터 전체를 기준으로 후속 처리
*4-4) 선택한 라인의 ZCHECK<>"C" 인 데이터가 존재하는 경우 하단 오류메세지 "조정 반려 대상이 아닙니다. 진행 상태를 확인하세요."
*4-5) ZCHECK="C" 이고 오류가 없는 경우 하단 POP-UP 확인 후 이력 테이블 저장

  DATA:
    LT_TMP   TYPE STANDARD TABLE OF TY_APPV,
    LS_CBO   TYPE ZGTMMT9490,
    LT_CBO   TYPE STANDARD TABLE OF ZGTMMT9490,
    LV_CHECK TYPE C LENGTH 1,
    LV_ANS   TYPE C LENGTH 1,
    LT_ROW   TYPE LVC_T_ROID.

  CALL METHOD GO_GRID_200->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

*  CALL METHOD GO_GRID_200->GET_SELECTED_ROWS
*    IMPORTING
*      ET_ROW_NO = LT_ROW.
*  DELETE LT_ROW WHERE ROW_ID LE 0.

  IF LT_ROW[] IS INITIAL.
    DO LINES( GT_APPV ) TIMES.
      LT_ROW = VALUE #( BASE LT_ROW ( ROW_ID = SY-INDEX ) ).
    ENDDO.
  ENDIF.

  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_APPV ASSIGNING FIELD-SYMBOL(<LS_APPV>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.
*4-4) 선택한 라인의 ZCHECK<>"C" 인 데이터가 존재하는 경우 하단 오류메세지 "조정 반려 대상이 아닙니다. 진행 상태를 확인하세요."
*4-5) ZCHECK="C" 이고 오류가 없는 경우 하단 POP-UP 확인 후 이력 테이블 저장
    IF <LS_APPV>-ZCHECK NE GC_C.
      MESSAGE E000 WITH TEXT-E09.
    ENDIF.

    LT_TMP = VALUE #( BASE LT_TMP ( <LS_APPV> ) ).
  ENDLOOP.

*재고실사 조정 반려 처리 하시겠습니까?
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT1
      TEXT_QUESTION = TEXT-Q04
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.


  "CBO Table 적용
  CHECK LT_TMP[] IS NOT INITIAL.

  SELECT
    *
    FROM ZGTMMT9490 AS Z1
    WHERE EXISTS (
##ITAB_KEY_IN_SELECT
        SELECT @ABAP_TRUE
            FROM @LT_TMP AS ZZ
            WHERE ZZ~INSMM EQ Z1~INSMM
                AND ZZ~WERKS EQ Z1~WERKS
                AND ZZ~LGORT EQ Z1~LGORT
                AND ZZ~SEQNO EQ Z1~SEQNO
                AND ZZ~MATNR EQ Z1~MATNR
                AND ZZ~CHARG EQ Z1~CHARG
                AND ZZ~TAGNR EQ Z1~TAGNR
    )
    ORDER BY INSMM, WERKS, LGORT, SEQNO, MATNR, CHARG, TAGNR
    INTO TABLE @DATA(LT_ORG).


  LOOP AT LT_TMP ASSIGNING FIELD-SYMBOL(<LS_TMP>).
    CLEAR LS_CBO.

    READ TABLE LT_ORG ASSIGNING FIELD-SYMBOL(<LS_ORG>) WITH KEY
                                                           INSMM = <LS_TMP>-INSMM
                                                           WERKS = <LS_TMP>-WERKS
                                                           LGORT = <LS_TMP>-LGORT
                                                           SEQNO = <LS_TMP>-SEQNO
                                                           MATNR = <LS_TMP>-MATNR
                                                           CHARG = <LS_TMP>-CHARG
                                                           TAGNR = <LS_TMP>-TAGNR BINARY SEARCH.
    CHECK SY-SUBRC EQ 0.
    LS_CBO = <LS_ORG>.
    LS_CBO-ZCHECK = SPACE.
    LS_CBO-APPREQ = SPACE.
    LS_CBO-AEDAT = SY-DATUM.
    LS_CBO-AEDAT_LOCAL = SY-DATLO.
    LS_CBO-AETIM = SY-UZEIT.
    LS_CBO-AETIM_LOCAL = SY-TIMLO.
    LS_CBO-AENAM = SY-UNAME.
    APPEND LS_CBO TO LT_CBO.
  ENDLOOP.

  CHECK LT_CBO[] IS NOT INITIAL.
  MODIFY ZGTMMT9490 FROM TABLE LT_CBO.
  COMMIT WORK.

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

  " 2026.05.29 P_APPUS 초기값 할당 위치 수정

  DATA(LV_UNAME) = CONDENSE( SY-UNAME ).

  IF LV_UNAME CO '0123456789'.
    P_APPUS = LV_UNAME.
  ENDIF.

  " 2026.06.09 ZGTMMR1070 연결 버튼 추가
  DATA: LS_BTN TYPE SMP_DYNTXT.

  LS_BTN-ICON_ID = ICON_LIST.
  LS_BTN-ICON_TEXT = TEXT-BT1.
  LS_BTN-QUICKINFO = TEXT-QI1.
  SSCRFIELDS-FUNCTXT_01 = LS_BTN.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_BAPPV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_BAPPV .

*3-1) 라인은 다중 선택가능(전체선택포함)
*   : ALV의 동일한 실사년월 데이터 중 선택안된 데이터가 있어도 전체를 기준으로 실행함
*3-2) 선택한 라인이 없는 경우에도 실행 가능
*3-3) ALV 의 동일한 실사년월의 데이터 전체를 기준으로 후속 처리
*3-4) 선택한 라인의 ZCHECK =<>"C" 인 데이터가 존재하는 경우 하단 오류메세지 "승인 요청 대상이 아닙니다. 진행 상태를 확인하세요."
*3-5) 선택한 라인의 APPREQ <> "" 인 데이터가 존재하는 경우 하단 오류메세지 "이미 승인 요청한 데이터입니다."
*3-6) ZCHECK="C" 이고 오류가 없는 경우 하단 POP-UP 확인 후 이력 테이블 저장

  DATA:
    LT_CBO   TYPE STANDARD TABLE OF ZGTMMT9490,
    LV_CHECK TYPE C LENGTH 1,
    LV_ANS   TYPE C LENGTH 1,
    LT_ROW   TYPE LVC_T_ROID.

  DATA LV_APPUSER TYPE ZGTMMT9490-APPUSER.

  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

*>S.1-1) 라인은 다중 선택가능(전체선택포함): 조회 리스트에서 일부 데이터만 선택 하여도 확정 처리 가능으로 변경
  CALL METHOD GO_GRID_100->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW.
  DELETE LT_ROW WHERE ROW_ID LE 0.

  IF LT_ROW[] IS INITIAL.
*선택한 데이터가 없는 경우 오류 메세지 “선택한 데이터가 없습니다.”
    MESSAGE E163 .
*    DO LINES( GT_DISP_I ) TIMES.
*      LT_ROW = VALUE #( BASE LT_ROW ( ROW_ID = SY-INDEX ) ).
*    ENDDO.
  ENDIF.

  CHECK LT_ROW[] IS NOT INITIAL.
*<E.2026.08.06_ZGODEV04

  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_DISP_I ASSIGNING FIELD-SYMBOL(<LS_DISP>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.
*3-4) 선택한 라인의 ZCHECK =<>"C" 인 데이터가 존재하는 경우 하단 오류메세지 "승인 요청 대상이 아닙니다. 진행 상태를 확인하세요."
    IF <LS_DISP>-ZCHECK NE GC_C.
      MESSAGE E000 WITH TEXT-E03.
    ENDIF.
*3-5) 선택한 라인의 APPREQ <> "" 인 데이터가 존재하는 경우 하단 오류메세지 "이미 승인 요청한 데이터입니다."
    IF <LS_DISP>-APPREQ NE SPACE.
      MESSAGE E000 WITH TEXT-E04.
    ENDIF.

    LT_CBO = VALUE #( BASE LT_CBO ( INSMM = <LS_DISP>-INSMM
                                                           WERKS = <LS_DISP>-WERKS
                                                           LGORT = <LS_DISP>-LGORT
                                                           SEQNO = <LS_DISP>-SEQNO
                                                           MATNR = <LS_DISP>-MATNR
                                                           CHARG = <LS_DISP>-CHARG
                                                           TAGNR = <LS_DISP>-TAGNR
                                                           ) ).

    LV_APPUSER = <LS_DISP>-APPUSER.
  ENDLOOP.

*3-6) ZCHECK="C" 이고 오류가 없는 경우 하단 POP-UP 확인 후 이력 테이블 저장
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT1
      TEXT_QUESTION = TEXT-Q03 "재고실사 승인 요청 하시겠습니까?
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.

*
*   3-6-1) 전송 대상 승인자 메일주소 조회
*
*	Table : ZPA0105
*	SELECT 조건 : SYSID
*	WEHRE 조건 :
*	PERNR = ALV-APPUSER 사번
*	SUBTY = "0007"
*	ENDDA = "9999.12.31"
  SELECT SINGLE
    USRID
    FROM ZPA0105
    WHERE PERNR EQ @LV_APPUSER
    AND SUBTY EQ '0007'
    AND ENDDA EQ '99991231'
    INTO @DATA(LV_USRID).
*
*3-6-2) 이메일 본문 내용 구성
*
*첫번째 라인) 실사년월 "ALV-" 에대 한 재고실사 승인 요청 드립니다.
*두번째 라인) SAP 메뉴 ZGTMMR4380에서 대상 확인 승인 부탁드립니다.
*
*3-6-3) 결재 요청 메일 전송 FUNCTION Z_MM_SEND_MAIL  호출
*Parameter            VALUE
*I_UNAME            3-5-1) PERNR
*I_E-MAIL           3-5-1) PERNR
*I_HEAD_TEXT            [승인요청] 재고실사 차이 조정 승인요청 드립니다.

  DATA:
    LV_UNAME     TYPE SY-UNAME,
    LV_EMAIL     TYPE AD_SMTPADR,
    LV_HEAD_TEXT TYPE SO_OBJ_DES,
    LV_RET       TYPE CHAR01,
    LV_MESSAGE   TYPE CHAR100,
    LT_MSG       TYPE BCSY_TEXT,
    LV_INSMM     TYPE C LENGTH 7.

  LV_UNAME = LV_APPUSER.
  LV_EMAIL = LV_USRID.
  LV_HEAD_TEXT = TEXT-HT1. "[승인요청] 재고실사 차이 조정 승인요청 드립니다.

  WRITE P_INSMM TO LV_INSMM LEFT-JUSTIFIED NO-GAP.

  LT_MSG = VALUE #(
        ( LINE = |{ TEXT-F03 } "{ LV_INSMM }" { TEXT-EM1 }| )
        ( LINE = TEXT-EM2 )
  ).
  CALL FUNCTION 'Z_MM_SEND_MAIL'
    EXPORTING
      I_UNAME     = LV_UNAME
      I_EMAIL     = LV_EMAIL
      I_HEAD_TEXT = LV_HEAD_TEXT
    IMPORTING
      E_RETURN    = LV_RET
      E_MESSAGE   = LV_MESSAGE
    TABLES
      T_MSG       = LT_MSG.

*3-7) 전송 성공 후 이력 테이블 업데이트
*필드명            필드          Value
*승인요청여부           APPREQ          "Y"
  IF LV_RET EQ GC_S.
    UPDATE ZGTMMT9490 SET
        APPREQ = @GC_Y
      WHERE EXISTS
##ITAB_KEY_IN_SELECT
     ( SELECT @ABAP_TRUE
        FROM @LT_CBO AS ZZ
        WHERE ZZ~INSMM EQ ZGTMMT9490~INSMM
        AND ZZ~WERKS EQ ZGTMMT9490~WERKS
        AND ZZ~LGORT EQ ZGTMMT9490~LGORT
        AND ZZ~SEQNO EQ ZGTMMT9490~SEQNO
        AND ZZ~MATNR EQ ZGTMMT9490~MATNR
        AND ZZ~CHARG EQ ZGTMMT9490~CHARG
        AND ZZ~TAGNR EQ ZGTMMT9490~TAGNR ).
    COMMIT WORK.

    LOOP AT LT_ROW ASSIGNING <LS_ROW>.
      READ TABLE GT_DISP_I ASSIGNING <LS_DISP> INDEX <LS_ROW>-ROW_ID.
      CHECK SY-SUBRC EQ 0.
      <LS_DISP>-APPREQ = GC_Y.
    ENDLOOP.

  ELSE.
    MESSAGE E000 WITH LV_MESSAGE.
  ENDIF.

  "메세지
  MESSAGE S000 WITH TEXT-M01."

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_BAPI_MATPHYSINV_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROW
*&---------------------------------------------------------------------*
FORM F_BAPI_MATPHYSINV_CREATE  USING PT_ROW TYPE LVC_T_ROID
                                                          CHANGING CV_CHECK
                                                                           CV_MESSAGE.

  DATA:
    LT_CBO    TYPE STANDARD TABLE OF ZGTMMT9490,
    LS_CBO    TYPE ZGTMMT9490,
    LT_RUN    TYPE STANDARD TABLE OF TY_APPV,
    LT_RUN_SP TYPE STANDARD TABLE OF TY_APPV,
    LT_TMP    TYPE STANDARD TABLE OF TY_APPV.

  LOOP AT PT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_APPV ASSIGNING FIELD-SYMBOL(<LS_APPV>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    CHECK <LS_APPV>-MENGE IS NOT INITIAL "차이수량이 있으면서 실사 문서가 없으면 실행
      AND <LS_APPV>-IBLNR IS INITIAL.
*
**3-6-2) ZCHECK="N"일때 재고실사문서가 존재하고, 실사 문서 상태 IKPF-ZSTAT = "" or "A" 이면 BAPI_MATPHYSINV_COUNT 부터 수행
**3-6-3) ZCHECK="N" 일때 재고실사문서가 존재하고, 실사 문서 상태 IKPF-DSTAT = "" or "A" 이면 BAPI_MATPHYSINV_POSTDIFF 부터 수행
*
*    IF <LS_APPV>-ZCHECK EQ GC_N
*       AND <LS_APPV>-IBLNR IS NOT INITIAL.
**3-6-2) ZCHECK="N"일때 재고실사문서가 존재하고, 실사 문서 상태 IKPF-ZSTAT = "" or "A" 이면 BAPI_MATPHYSINV_COUNT 부터 수행
*      IF <LS_APPV>-ZSTAT EQ SPACE OR <LS_APPV>-ZSTAT EQ GC_A.
*        CONTINUE.
*      ENDIF.
**3-6-3) ZCHECK="N" 일때 재고실사문서가 존재하고, 실사 문서 상태 IKPF-DSTAT = "" or "A" 이면 BAPI_MATPHYSINV_POSTDIFF 부터 수행
*      IF <LS_APPV>-DSTAT EQ SPACE OR <LS_APPV>-DSTAT EQ GC_A.
*        CONTINUE.
*      ENDIF.
*    ENDIF.
    <LS_APPV>-TABIX = <LS_ROW>-ROW_ID.
    LT_RUN =  VALUE #( BASE LT_RUN ( <LS_APPV> ) ).
  ENDLOOP.

  CHECK LT_RUN[] IS NOT INITIAL.

  DATA:
    LV_CNT     TYPE INT4,
    LV_RUN_CNT TYPE INT4,
    LV_IBLNR   TYPE IKPF-IBLNR,
    LV_ITEM    TYPE DZEILE,
    LV_BUDAT   TYPE IKPF-BUDAT,  "POSTING DATE
    LS_HEAD    TYPE BAPI_PHYSINV_CREATE_HEAD,
    LT_ITEM    TYPE STANDARD TABLE OF BAPI_PHYSINV_CREATE_ITEMS,
    LT_RETURN  TYPE STANDARD TABLE OF BAPIRET2.

  FIELD-SYMBOLS:
    <LS_RUN_SP> TYPE TY_APPV,
    <LS_RETURN> TYPE BAPIRET2.


  CLEAR LT_TMP[].

  LOOP AT LT_RUN ASSIGNING FIELD-SYMBOL(<LS_G1>) GROUP BY ( WERKS = <LS_G1>-WERKS
                                                                                                          LGORT = <LS_G1>-LGORT
                                                                                                          INVDA = <LS_G1>-INVDA
                                                                                                          BSTAR = <LS_G1>-BSTAR
                                                                                                          VBELN = <LS_G1>-VBELN
                                                                                                          POSNR = <LS_G1>-POSNR )
                                                                                      ASSIGNING FIELD-SYMBOL(<LS_GROUP>).
    CLEAR:
      LV_ITEM,
      LV_IBLNR,
      LS_HEAD,
      LT_ITEM,
      LT_RETURN,
      LT_RUN_SP,
      LV_BUDAT.

    "해당 월 말일 계산
    LV_BUDAT = P_INSMM && '01'.
    LV_BUDAT += 31.
    LV_BUDAT = LV_BUDAT+0(6) && '01'.
    LV_BUDAT -= 1.

*3-6) 재고실사 문서 생성 (BAPI_MATPHYSINV_CREATE)
*	: ALV-MENGE  = 0인 건은 제외하고 실행
    LS_HEAD-PLANT = <LS_GROUP>-WERKS.
    LS_HEAD-STGE_LOC = <LS_GROUP>-LGORT.

* 전기일: 처리월 말일 / 증빙일: 실사일자
    LS_HEAD-DOC_DATE = <LS_GROUP>-INVDA."SY-DATUM.
    LS_HEAD-PLAN_DATE = LV_BUDAT."<LS_GROUP>-INVDA.

    IF <LS_GROUP>-VBELN IS NOT INITIAL. "판매오더가 있으면..
      LS_HEAD-SPEC_STOCK = GC_E. "특별재고 지시자
    ENDIF.

    LOOP AT GROUP <LS_GROUP> ASSIGNING FIELD-SYMBOL(<LS_LINE>).
      LV_ITEM += 1.
      <LS_LINE>-ITEM = LV_ITEM. "항번 설정

      LT_ITEM = VALUE #( BASE LT_ITEM (
          MATERIAL = <LS_LINE>-MATNR
          BATCH = <LS_LINE>-CHARG
          STOCK_TYPE = <LS_LINE>-BSTAR
          SALES_ORD = <LS_LINE>-VBELN
          S_ORD_ITEM = <LS_LINE>-POSNR
      ) ).

      APPEND <LS_LINE> TO LT_RUN_SP.

      IF LV_ITEM GE '900'.

        "BAPI 실행
        PERFORM F_RUN_BAPI_MATPHYSINV_CREATE USING LS_HEAD LT_ITEM CHANGING LV_IBLNR
                                                                                                                          CV_CHECK
                                                                                                                          CV_MESSAGE.
        "ALV 적용
        LOOP AT LT_RUN_SP ASSIGNING <LS_RUN_SP>.
          IF LV_IBLNR IS NOT INITIAL.
            GT_APPV[ <LS_RUN_SP>-TABIX ]-ZCHECK = GC_N.
            GT_APPV[ <LS_RUN_SP>-TABIX ]-IBLNR = LV_IBLNR.
            GT_APPV[ <LS_RUN_SP>-TABIX ]-ITEM = <LS_RUN_SP>-ITEM.

            "CBO Table 저장 대상
            APPEND GT_APPV[ <LS_RUN_SP>-TABIX ] TO LT_TMP.
          ELSE.
            GT_APPV[ <LS_RUN_SP>-TABIX ]-STATUS = ICON_LED_RED.
            GT_APPV[ <LS_RUN_SP>-TABIX ]-MESSAGE = CV_MESSAGE. "2026.05.29 BAPI 메시지 할당
          ENDIF.
        ENDLOOP.

        CLEAR:
          LV_ITEM,
          LV_IBLNR,
          LT_ITEM,
          LT_RETURN,
          LT_RUN_SP.
      ENDIF.
    ENDLOOP.

    IF LT_ITEM[] IS NOT INITIAL.
      "BAPI 실행
      PERFORM F_RUN_BAPI_MATPHYSINV_CREATE USING LS_HEAD LT_ITEM CHANGING LV_IBLNR
                                                                                                                        CV_CHECK
                                                                                                                        CV_MESSAGE.
      "ALV 적용
      LOOP AT LT_RUN_SP ASSIGNING <LS_RUN_SP>.
        IF LV_IBLNR IS NOT INITIAL.
          GT_APPV[ <LS_RUN_SP>-TABIX ]-ZCHECK = GC_N.
          GT_APPV[ <LS_RUN_SP>-TABIX ]-IBLNR = LV_IBLNR.
          GT_APPV[ <LS_RUN_SP>-TABIX ]-ITEM = <LS_RUN_SP>-ITEM.
          "CBO Table 저장 대상
          APPEND GT_APPV[ <LS_RUN_SP>-TABIX ] TO LT_TMP.
        ELSE.
          GT_APPV[ <LS_RUN_SP>-TABIX ]-STATUS = ICON_LED_RED.
          GT_APPV[ <LS_RUN_SP>-TABIX ]-MESSAGE = CV_MESSAGE. "2026.05.29 BAPI 메시지 할당
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDLOOP.

  "CBO Table 적용
  CHECK LT_TMP[] IS NOT INITIAL.

  SELECT
    *
    FROM ZGTMMT9490 AS Z1
    WHERE EXISTS (
##ITAB_KEY_IN_SELECT
        SELECT @ABAP_TRUE
            FROM @LT_TMP AS ZZ
            WHERE ZZ~INSMM EQ Z1~INSMM
                AND ZZ~WERKS EQ Z1~WERKS
                AND ZZ~LGORT EQ Z1~LGORT
                AND ZZ~SEQNO EQ Z1~SEQNO
                AND ZZ~MATNR EQ Z1~MATNR
                AND ZZ~CHARG EQ Z1~CHARG
                AND ZZ~TAGNR EQ Z1~TAGNR
    )
    ORDER BY INSMM, WERKS, LGORT, SEQNO, MATNR, CHARG, TAGNR
    INTO TABLE @DATA(LT_ORG).


  LOOP AT LT_TMP ASSIGNING FIELD-SYMBOL(<LS_TMP>).
    CLEAR LS_CBO.

    READ TABLE LT_ORG ASSIGNING FIELD-SYMBOL(<LS_ORG>) WITH KEY
                                                           INSMM = <LS_TMP>-INSMM
                                                           WERKS = <LS_TMP>-WERKS
                                                           LGORT = <LS_TMP>-LGORT
                                                           SEQNO = <LS_TMP>-SEQNO
                                                           MATNR = <LS_TMP>-MATNR
                                                           CHARG = <LS_TMP>-CHARG
                                                           TAGNR = <LS_TMP>-TAGNR BINARY SEARCH.
    CHECK SY-SUBRC EQ 0.
    LS_CBO = <LS_ORG>.
    LS_CBO-ZCHECK = <LS_TMP>-ZCHECK.
    LS_CBO-IBLNR = <LS_TMP>-IBLNR.
    LS_CBO-ITEM = <LS_TMP>-ITEM.
    APPEND LS_CBO TO LT_CBO.
  ENDLOOP.

  CHECK LT_CBO[] IS NOT INITIAL.
  MODIFY ZGTMMT9490 FROM TABLE LT_CBO.
  COMMIT WORK.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_BAPI_MATPHYSINV_COUNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROW
*&      <-- LV_CHECK
*&      <-- LV_MESSAGE
*&---------------------------------------------------------------------*
FORM F_BAPI_MATPHYSINV_COUNT  USING PT_ROW TYPE LVC_T_ROID
                                                          CHANGING CV_CHECK
                                                                           CV_MESSAGE.


  DATA:
    LT_CBO TYPE STANDARD TABLE OF ZGTMMT9490,
    LT_RUN TYPE STANDARD TABLE OF TY_APPV.

  LOOP AT PT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_APPV ASSIGNING FIELD-SYMBOL(<LS_APPV>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.
    CHECK <LS_APPV>-MENGE IS NOT INITIAL AND <LS_APPV>-IBLNR IS NOT INITIAL.
*3-6-3) ZCHECK="N" 일때 재고실사문서가 존재하고, 실사 문서 상태 IKPF-DSTAT = "" or "A" 이면 BAPI_MATPHYSINV_POSTDIFF 부터 수행

    CHECK <LS_APPV>-ZSTAT NE ABAP_TRUE "실사 문서가 있으면서 실사 상태 가 'X' 가 아닌 경우 실행
      AND <LS_APPV>-IBLNR IS NOT INITIAL.

*    IF <LS_APPV>-ZCHECK EQ GC_N
*       AND <LS_APPV>-IBLNR IS NOT INITIAL
*       AND <LS_APPV>-ZSTAT NE ABAP_TRUE.
**3-6-3) ZCHECK="N" 일때 재고실사문서가 존재하고, 실사 문서 상태 IKPF-DSTAT = "" or "A" 이면 BAPI_MATPHYSINV_POSTDIFF 부터 수행
*      IF <LS_APPV>-DSTAT EQ SPACE OR <LS_APPV>-DSTAT EQ GC_A.
*        CONTINUE.
*      ENDIF.
*    ENDIF.
    <LS_APPV>-TABIX = <LS_ROW>-ROW_ID.
    LT_RUN =  VALUE #( BASE LT_RUN ( <LS_APPV> ) ).
  ENDLOOP.

  CHECK LT_RUN[] IS NOT INITIAL.

  DATA:
    LV_IBLNR  TYPE IKPF-IBLNR,
    LV_GJAHR  TYPE IKPF-GJAHR,
    LV_ZLDAT  TYPE IKPF-ZLDAT,
    LT_ITEM   TYPE STANDARD TABLE OF BAPI_PHYSINV_COUNT_ITEMS,
    LT_RETURN TYPE STANDARD TABLE OF BAPIRET2.

  LOOP AT LT_RUN ASSIGNING FIELD-SYMBOL(<LS_G1>)
                                                    GROUP BY ( IBLNR = <LS_G1>-IBLNR
                                                                       INVDA = <LS_G1>-INVDA )
                                                              ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    CLEAR:
      LV_IBLNR,
      LV_GJAHR,
      LV_ZLDAT,
      LT_ITEM,
      LT_RETURN.

    LV_IBLNR = <LS_GROUP>-IBLNR.

    " GJAHR, ZLDAT 처리월 기준으로 변경
    LV_GJAHR = P_INSMM+0(4). "<LS_GROUP>-INVDA+0(4).
*    LV_ZLDAT = <LS_GROUP>-INVDA.
    LV_ZLDAT = P_INSMM && '01'.
    LV_ZLDAT += 31.
    LV_ZLDAT = LV_ZLDAT+0(6) && '01'.
    LV_ZLDAT -= 1.

    LOOP AT GROUP <LS_GROUP> ASSIGNING FIELD-SYMBOL(<LS_LINE>).
      LT_ITEM = VALUE #( BASE LT_ITEM (
                ITEM = <LS_LINE>-ITEM
                MATERIAL = <LS_LINE>-MATNR
                BATCH = <LS_LINE>-CHARG
                ENTRY_QNT = <LS_LINE>-COUNTQTY
                ENTRY_UOM = <LS_LINE>-MEINS
                ZERO_COUNT = COND #( WHEN <LS_LINE>-COUNTQTY IS INITIAL THEN ABAP_TRUE ELSE SPACE )
        ) ).
    ENDLOOP.

    CALL FUNCTION 'BAPI_MATPHYSINV_COUNT'
      EXPORTING
        PHYSINVENTORY = LV_IBLNR
        FISCALYEAR    = LV_GJAHR
        COUNT_DATE    = LV_ZLDAT
      TABLES
        ITEMS         = LT_ITEM
        RETURN        = LT_RETURN.

    READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_RETURN>) WITH KEY TYPE = GC_E.
    IF SY-SUBRC EQ 0.
*	3-7-3-1) RETURN-TYPE = E 이면
*	: ALV 화면 필드업데이트
*	: 하단 에러 메시지 처리 "재고실사 결과 입력 실패하였습니다."
      CV_CHECK = GC_E.
      CV_MESSAGE = <LS_RETURN>-MESSAGE.

      "<--2026.05.29 BAPI 메시지 할당
      LOOP AT GROUP <LS_GROUP> ASSIGNING <LS_LINE>.
        GT_APPV[ <LS_LINE>-TABIX ]-MESSAGE = CV_MESSAGE.
      ENDLOOP.
      "2026.05.29 BAPI 메시지 할당-->

    ELSE.
*3-7-3-2) RETURN-TYPE = S 이면
*: CALL FUNCTION 'BAPI_TRANSACTION_COMMIT
*3-7-3-3) 차이 수량 차이조정 전기 BAPI 수행
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.

      LOOP AT GROUP <LS_GROUP> ASSIGNING <LS_LINE>.
        GT_APPV[ <LS_LINE>-TABIX ]-ZSTAT = ABAP_TRUE.
      ENDLOOP.
    ENDIF.

  ENDLOOP.




ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_RUN_BAPI_MATPHYSINV_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_HEAD
*&      --> LT_ITEM
*&      <-- LV_IBLNR
*&      <-- CV_CHECK
*&      <-- CV_MESSAGE
*&---------------------------------------------------------------------*
FORM F_RUN_BAPI_MATPHYSINV_CREATE  USING PS_HEAD TYPE BAPI_PHYSINV_CREATE_HEAD
                                            PT_ITEM TYPE TY_T_CREATE_ITEM
                                   CHANGING CV_IBLNR
                                            CV_CHECK
                                            CV_MESSAGE.

  DATA LT_RETURN TYPE STANDARD TABLE OF BAPIRET2.
  FIELD-SYMBOLS <LS_RETURN> TYPE BAPIRET2.

  CALL FUNCTION 'BAPI_MATPHYSINV_CREATE'
    EXPORTING
      HEAD   = PS_HEAD
    TABLES
      ITEMS  = PT_ITEM
      RETURN = LT_RETURN.

  READ TABLE LT_RETURN ASSIGNING <LS_RETURN>
                                          WITH KEY TYPE = GC_S
                                                          ID = 'M7'
                                                          NUMBER = '710'.
  IF SY-SUBRC EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

    CV_IBLNR = <LS_RETURN>-MESSAGE_V1.
    CV_IBLNR = |{ CV_IBLNR ALPHA = IN }|.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    READ TABLE LT_RETURN ASSIGNING <LS_RETURN> WITH KEY TYPE = GC_E.
    IF SY-SUBRC NE 0.
      READ TABLE LT_RETURN ASSIGNING <LS_RETURN> WITH KEY TYPE = GC_A.
      IF SY-SUBRC NE 0.
        READ TABLE LT_RETURN ASSIGNING <LS_RETURN> WITH KEY TYPE = GC_W.
      ENDIF.
    ENDIF.

    CV_CHECK = GC_E.
    IF SY-SUBRC EQ 0.
      CV_MESSAGE = <LS_RETURN>-MESSAGE.
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_BAPI_MATPHYSINV_POSTDIFF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROW
*&      <-- LV_CHECK
*&      <-- LV_MESSAGE
*&---------------------------------------------------------------------*
FORM F_BAPI_MATPHYSINV_POSTDIFF  USING PT_ROW TYPE LVC_T_ROID
                                                          CHANGING CV_CHECK
                                                                           CV_MESSAGE.


  DATA:
    LS_CBO TYPE ZGTMMT9490,
    LT_CBO TYPE STANDARD TABLE OF ZGTMMT9490,
    LT_TMP TYPE STANDARD TABLE OF TY_APPV,
    LT_RUN TYPE STANDARD TABLE OF TY_APPV.


  LOOP AT PT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_APPV ASSIGNING FIELD-SYMBOL(<LS_APPV>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    IF <LS_APPV>-MENGE IS NOT INITIAL.
      CHECK  <LS_APPV>-IBLNR IS NOT INITIAL       "실사 문서가 있고, 실사 상태가 X, 전기 상태가 X가 아닌 경우 진행
           AND <LS_APPV>-ZSTAT EQ ABAP_TRUE
           AND <LS_APPV>-DSTAT NE ABAP_TRUE.


      <LS_APPV>-TABIX = <LS_ROW>-ROW_ID.
      LT_RUN =  VALUE #( BASE LT_RUN ( <LS_APPV> ) ).
    ENDIF.
  ENDLOOP.

  CHECK LT_RUN[] IS NOT INITIAL.


  DATA:
    LV_MBLNR  TYPE MKPF-MBLNR,
    LV_IBLNR  TYPE IKPF-IBLNR,
    LV_GJAHR  TYPE IKPF-GJAHR,
    LV_BUDAT  TYPE IKPF-BUDAT,
    LT_RETURN TYPE STANDARD TABLE OF BAPIRET2.

  FIELD-SYMBOLS:
    <LS_RETURN> TYPE BAPIRET2,
    <LS_LINE>   TYPE TY_APPV.

  "해당 월 말일
  LV_BUDAT = P_INSMM && '01'.
  LV_BUDAT += 31.
  LV_BUDAT = LV_BUDAT+0(6) && '01'.
  LV_BUDAT -= 1.
  LOOP AT LT_RUN ASSIGNING FIELD-SYMBOL(<LS_G1>)
                                                    GROUP BY ( IBLNR = <LS_G1>-IBLNR )
                                                              ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    LV_GJAHR = P_INSMM+0(4).
    LV_IBLNR = <LS_GROUP>-IBLNR.

    CLEAR LT_RETURN[].
    CALL FUNCTION 'BAPI_MATPHYSINV_POSTDIFF'
      EXPORTING
        PHYSINVENTORY = LV_IBLNR
        FISCALYEAR    = LV_GJAHR
        PSTNG_DATE    = LV_BUDAT
      TABLES
        RETURN        = LT_RETURN.

    READ TABLE LT_RETURN ASSIGNING <LS_RETURN> WITH KEY
                      TYPE = GC_S
                      ID = 'M7'
                      NUMBER = '716'.
    IF SY-SUBRC EQ 0.
*MESSAGE_V2
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.

      LV_MBLNR = <LS_RETURN>-MESSAGE_V2.
      LV_MBLNR = |{ LV_MBLNR ALPHA = IN }|.

      LOOP AT GROUP <LS_GROUP> ASSIGNING <LS_LINE>.
        GT_APPV[ <LS_LINE>-TABIX ]-MBLNR = LV_MBLNR.
        GT_APPV[ <LS_LINE>-TABIX ]-BUDAT = LV_BUDAT.
        GT_APPV[ <LS_LINE>-TABIX ]-DSTAT = ABAP_TRUE.
        GT_APPV[ <LS_LINE>-TABIX ]-ZCHECK = GC_P.
        GT_APPV[ <LS_LINE>-TABIX ]-STATUS = ICON_LED_GREEN.

        LT_TMP = VALUE #( BASE LT_TMP ( GT_APPV[ <LS_LINE>-TABIX ] ) ).
      ENDLOOP.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      READ TABLE LT_RETURN ASSIGNING <LS_RETURN> WITH KEY TYPE = GC_E.
      IF SY-SUBRC NE 0.
        READ TABLE LT_RETURN ASSIGNING <LS_RETURN> WITH KEY TYPE = GC_A.
        IF SY-SUBRC NE 0.
          READ TABLE LT_RETURN ASSIGNING <LS_RETURN> WITH KEY TYPE = GC_W.
        ENDIF.
      ENDIF.
      CV_CHECK = GC_E.
      IF SY-SUBRC EQ 0.
        CV_MESSAGE = <LS_RETURN>-MESSAGE.
      ENDIF.
*	3-8-1-1) RETURN-TYPE = E 이면
*	: ALV 화면 필드업데이트
*	: 하단 에러 메시지 처리 "재고실사 조정 전기 실패하였습니다."

      LOOP AT GROUP <LS_GROUP> ASSIGNING <LS_LINE>.
        GT_APPV[ <LS_LINE>-TABIX ]-STATUS = ICON_LED_RED.
        GT_APPV[ <LS_LINE>-TABIX ]-MESSAGE = CV_MESSAGE.  " 2026.05.29 BAPI 메시지 할당
      ENDLOOP.
    ENDIF.
  ENDLOOP.


  "CBO Table 적용
  CHECK LT_TMP[] IS NOT INITIAL.

  SELECT
    *
    FROM ZGTMMT9490 AS Z1
    WHERE EXISTS (
##ITAB_KEY_IN_SELECT
        SELECT @ABAP_TRUE
            FROM @LT_TMP AS ZZ
            WHERE ZZ~INSMM EQ Z1~INSMM
                AND ZZ~WERKS EQ Z1~WERKS
                AND ZZ~LGORT EQ Z1~LGORT
                AND ZZ~SEQNO EQ Z1~SEQNO
                AND ZZ~MATNR EQ Z1~MATNR
                AND ZZ~CHARG EQ Z1~CHARG
                AND ZZ~TAGNR EQ Z1~TAGNR
    )
    ORDER BY INSMM, WERKS, LGORT, SEQNO, MATNR, CHARG, TAGNR
    INTO TABLE @DATA(LT_ORG).


  LOOP AT LT_TMP ASSIGNING FIELD-SYMBOL(<LS_TMP>).
    CLEAR LS_CBO.

    READ TABLE LT_ORG ASSIGNING FIELD-SYMBOL(<LS_ORG>) WITH KEY
                                                           INSMM = <LS_TMP>-INSMM
                                                           WERKS = <LS_TMP>-WERKS
                                                           LGORT = <LS_TMP>-LGORT
                                                           SEQNO = <LS_TMP>-SEQNO
                                                           MATNR = <LS_TMP>-MATNR
                                                           CHARG = <LS_TMP>-CHARG
                                                           TAGNR = <LS_TMP>-TAGNR BINARY SEARCH.
    CHECK SY-SUBRC EQ 0.
    LS_CBO = <LS_ORG>.
    LS_CBO-ZCHECK = <LS_TMP>-ZCHECK.
    LS_CBO-BUDAT = <LS_TMP>-BUDAT.
    LS_CBO-MBLNR = <LS_TMP>-MBLNR.
    LS_CBO-AEDAT = SY-DATUM.
    LS_CBO-AEDAT_LOCAL = SY-DATLO.
    LS_CBO-AETIM = SY-UZEIT.
    LS_CBO-AETIM_LOCAL = SY-TIMLO.
    LS_CBO-AENAM = SY-UNAME.
    APPEND LS_CBO TO LT_CBO.
  ENDLOOP.

  CHECK LT_CBO[] IS NOT INITIAL.
  MODIFY ZGTMMT9490 FROM TABLE LT_CBO.
  COMMIT WORK.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SAVE_DIFF_ZERO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROW
*&---------------------------------------------------------------------*
FORM F_SAVE_DIFF_ZERO  USING PT_ROW TYPE LVC_T_ROID.
  DATA:
    LS_CBO TYPE ZGTMMT9490,
    LT_CBO TYPE STANDARD TABLE OF ZGTMMT9490,
    LT_TMP TYPE STANDARD TABLE OF TY_APPV.

  LOOP AT PT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    READ TABLE GT_APPV ASSIGNING FIELD-SYMBOL(<LS_APPV>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.
    IF <LS_APPV>-MENGE IS INITIAL "차이수량이 0이면서
       AND <LS_APPV>-ZCHECK NE GC_P. "완료가 아닌 건
      LT_TMP =  VALUE #( BASE LT_TMP ( <LS_APPV> ) ).

      <LS_APPV>-ZCHECK = GC_P.
      <LS_APPV>-IBLNR = TEXT-DC1.
      <LS_APPV>-MBLNR = TEXT-DC1.
      <LS_APPV>-STATUS = ICON_LED_GREEN.  "2026.05.28 LED 상태값 수정
    ENDIF.
  ENDLOOP.

  "CBO Table 적용
  CHECK LT_TMP[] IS NOT INITIAL.

  SELECT
    *
    FROM ZGTMMT9490 AS Z1
    WHERE EXISTS (
##ITAB_KEY_IN_SELECT
        SELECT @ABAP_TRUE
            FROM @LT_TMP AS ZZ
            WHERE ZZ~INSMM EQ Z1~INSMM
                AND ZZ~WERKS EQ Z1~WERKS
                AND ZZ~LGORT EQ Z1~LGORT
                AND ZZ~SEQNO EQ Z1~SEQNO
                AND ZZ~MATNR EQ Z1~MATNR
                AND ZZ~CHARG EQ Z1~CHARG
                AND ZZ~TAGNR EQ Z1~TAGNR
    )
    ORDER BY INSMM, WERKS, LGORT, SEQNO, MATNR, CHARG, TAGNR
    INTO TABLE @DATA(LT_ORG).


  LOOP AT LT_TMP ASSIGNING FIELD-SYMBOL(<LS_TMP>).
    CLEAR LS_CBO.

    READ TABLE LT_ORG ASSIGNING FIELD-SYMBOL(<LS_ORG>) WITH KEY
                                                           INSMM = <LS_TMP>-INSMM
                                                           WERKS = <LS_TMP>-WERKS
                                                           LGORT = <LS_TMP>-LGORT
                                                           SEQNO = <LS_TMP>-SEQNO
                                                           MATNR = <LS_TMP>-MATNR
                                                           CHARG = <LS_TMP>-CHARG
                                                           TAGNR = <LS_TMP>-TAGNR BINARY SEARCH.
    CHECK SY-SUBRC EQ 0.
    LS_CBO = <LS_ORG>.
    LS_CBO-ZCHECK = GC_P.
    LS_CBO-IBLNR = TEXT-DC1.
    LS_CBO-MBLNR = TEXT-DC1.
    LS_CBO-AEDAT = SY-DATUM.
    LS_CBO-AEDAT_LOCAL = SY-DATLO.
    LS_CBO-AETIM = SY-UZEIT.
    LS_CBO-AETIM_LOCAL = SY-TIMLO.
    LS_CBO-AENAM = SY-UNAME.
    APPEND LS_CBO TO LT_CBO.
  ENDLOOP.

  CHECK LT_CBO[] IS NOT INITIAL.
  MODIFY ZGTMMT9490 FROM TABLE LT_CBO.
  COMMIT WORK.

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
    WHEN 'FC01'.

      PERFORM F_CALL_PROGRAM.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CHECK_AUTH .

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트[&] 작업권한을 확인하세요.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_CALL_PROGRAM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CALL_PROGRAM .

  DATA: LV_BUKRS   TYPE BUKRS.

  CLEAR: LV_BUKRS.

  " 회사코드 SELECT
  SELECT SINGLE K~BUKRS
    FROM T001W AS W
       JOIN T001K AS K
         ON K~BWKEY = W~BWKEY
       INTO LV_BUKRS
   WHERE W~WERKS = P_WERKS.

  SET PARAMETER ID: 'BUK' FIELD LV_BUKRS,
                                 'WRK' FIELD P_WERKS.

  CALL TRANSACTION 'ZGTMMR1070' AND SKIP FIRST SCREEN.

ENDFORM.
