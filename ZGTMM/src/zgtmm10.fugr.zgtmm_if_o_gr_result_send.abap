FUNCTION ZGTMM_IF_O_GR_RESULT_SEND.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_SDATE) TYPE  DATUM
*"     VALUE(I_EDATE) TYPE  DATUM
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      OT_TAB STRUCTURE  ZGTMMS1011
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_O_GR_RESULT_SEND
*& 프로그램 명 :  납품문서 입고 실적 전송(GSRM->SAP)
*& 개요   : G-SRM(전자구매시스템) 에서 SAP로 조회 조건 전송 후 결과 값 리턴
*& 생성일 : 2026.02.05
*& 생성자 : ZGODEV07
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : G-SRM -> EAI -> SAP
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  : 2026.09.28
*& 수정자  :
*& 수정개요: 호출 로그(ZGTMMT9000, MM00062) 및
*&           호출별 전송 데이터(ZGTMMT9426) 저장 추가 - G-PRO 수신 누락 추적용
*&---------------------------------------------------------------------*

  DATA LV_LOGMSG TYPE ZGTEBAPIMSG.

  "초기화
  CLEAR:
    OT_TAB[],
    ZO_RESULT,
    ZO_MESSAGE.

*>S.2026.09.28_호출 로그 시작(ZGTMMT9000)
  GV_SYSTEM_ID = I_SYSTEM_ID.
  PERFORM SET_COM_LOG USING 'S' GC_MM00062 '' '' CHANGING GS_9000.
*<E.2026.09.28

*1) 전송 정보 누락 여부 확인
*	1-1) Import Parameter 중 전송 필수 정보가 없는 경우 다음 값 Return 후 종료
*   Export Parameter                      Value
*   ZO_RESULT                     "02"
*   ZO_MESSAGE                      "필수 값이 누락되었습니다."

  "시스템ID 회사코드 필수 입력
  IF I_SYSTEM_ID EQ SPACE OR I_BUKRS EQ SPACE
    OR I_SDATE IS INITIAL OR I_EDATE IS INITIAL
    OR I_SDATE EQ SPACE OR I_EDATE EQ SPACE.
    ZO_RESULT = GC_02.
    ZO_MESSAGE = TEXT-E01.
    LV_LOGMSG = |{ ZO_MESSAGE } ({ I_BUKRS }/{ I_SDATE }~{ I_EDATE })|.
    PERFORM SET_COM_LOG USING 'E' GC_MM00062 'E' LV_LOGMSG CHANGING GS_9000.
    EXIT.
  ENDIF.


  DATA:
    LR_BUDAT TYPE RANGE OF MATDOC-BUDAT,
    LR_WERKS TYPE RANGE OF MATDOC-WERKS.

  "전기일
  LR_BUDAT = VALUE #( ( SIGN = 'I' OPTION = 'BT' LOW = I_SDATE HIGH = I_EDATE ) ).

  "플랜트
*2-1) 입력 받은 BUKRS 값 기준으도 대상 플랜트 선정
  SELECT DISTINCT
    'I' AS SIGN,
    'EQ' AS OPTION,
    TW~WERKS AS LOW
    FROM T001K AS TK
                INNER JOIN
            T001W AS TW ON TK~BWKEY EQ TW~BWKEY
    WHERE TK~BUKRS EQ @I_BUKRS
    INTO CORRESPONDING FIELDS OF TABLE @LR_WERKS.
  IF SY-SUBRC NE 0.
    "대상 플랜트가 없으면 종료
    ZO_RESULT = GC_00.
    LV_LOGMSG = |{ I_BUKRS } 대상 플랜트 없음 ({ I_SDATE }~{ I_EDATE }) 반환 0건|.
    PERFORM SET_COM_LOG USING 'E' GC_MM00062 'S' LV_LOGMSG CHANGING GS_9000.
    EXIT.
  ENDIF.
*
*2-2) 2-1 의 대상 플랜트와 입력 받은 일자 기준으로 CDS VIEW ZGTMM_CV_GET_GODELIVERY_DATA 조회
*
*	Table : ZGTMM_CV_GET_GODELIVERY_DATA
*	SELECT 조건 : DELNO,DELITEM,MBLNR,ZEILE,MJAHR,BUDAT,CPUDT,EBELN,EBELP,ERFME,ERFMG,CANCELLED,LFBJA,LFBNR,LFPOS,USNAM,ENAME,TEL_NUMBER,MAILADD,REVERSE_MOVEMENT
*	WHERE 조건 :
*	BUDAT : I_SDATE ~ I_EDATE
*	WERKS : 2-1) 의 대상플랜트

  SELECT
    V1~DELNO,
    V1~DELITEM,
    V1~MJAHR,
    V1~MBLNR,
    V1~ZEILE,
    V1~BUDAT,
    V1~CPUDT,
    V1~EBELN,
    V1~EBELP,
*2-3) 취소 이동유형인 경우 수량 값 재 설정
*   REVERSE_MOVEMENT = "X" 이면 ERFMG*-1
    CASE WHEN V1~REVERSAL_MOVEMENT EQ @ABAP_TRUE THEN V1~ERFMG * -1 ELSE V1~ERFMG END AS ERFMG,
    V1~ERFME,
    V1~REVERSAL_MOVEMENT AS CANCELLED,
    CASE WHEN V1~LFBNR IS NOT INITIAL THEN CAST( V1~LFBJA AS CHAR( 4 ) ) ELSE @SPACE END AS LFBJA,
    V1~LFBNR,
    CASE WHEN V1~LFBNR IS NOT INITIAL THEN CAST( V1~LFPOS AS CHAR( 4 ) ) ELSE @SPACE END AS LFPOS,
    V1~USNAM,
    V1~ENAME,
    V1~TEL_NUMBER,
    V1~SMTP_ADDR AS MAILADD
    FROM ZGTMM_CV_GET_GODELIVERY_DATA AS V1
*>S.2026.07.27_CPUDT : I_SDATE ~ I_EDATE - 기준 일자 조건 변경 (기존 BUDAT -> CPUDT)
*    WHERE V1~BUDAT IN @LR_BUDAT
    WHERE V1~CPUDT IN @LR_BUDAT
*<E.2026.07.27_ZGODEV04
    AND V1~WERKS IN @LR_WERKS
*   MBLNR <> "" 인 납품문서 및 입고 정보 데이터 추출
    AND V1~MBLNR IS NOT INITIAL
    ORDER BY V1~MBLNR, V1~ZEILE
    INTO TABLE @DATA(LT_DOC).

*>S.2026.07.27_2-3) PO 입고 처리 문서 내역 조회 추가
*: 2-1 의 대상 플랜트와 수신 받은 일자 기준으로 ZGTMM_CV_GET_MATDOC 조회
  SELECT Z~MBLNR, Z~ZEILE, Z~MJAHR,
               Z~BUDAT, Z~CPUDT, Z~EBELN, Z~EBELP,
               Z~ERFME, Z~LFBNR,

    CASE WHEN Z~LFBNR IS NOT INITIAL THEN CAST( Z~LFBJA AS CHAR( 4 ) )
              ELSE @SPACE END AS LFBJA,
    CASE WHEN Z~LFBNR IS NOT INITIAL THEN CAST( Z~LFPOS AS CHAR( 4 ) )
              ELSE @SPACE END AS LFPOS,

               Z~USNAM, ENAME, Z~TEL_NUMBER, Z~SMTP_ADDR AS MAILADD,

    CASE WHEN Z~REVERSAL_MOVEMENT EQ @ABAP_TRUE
             THEN ERFMG * -1 ELSE ERFMG END AS ERFMG,
               Z~CANCELLED AS REVERSAL_MOVEMENT

     FROM ZGTMM_CV_GET_MATDOC AS Z
     WHERE Z~CPUDT IN @LR_BUDAT
          AND Z~WERKS IN @LR_WERKS
          AND Z~MBLNR IS NOT INITIAL
          AND NOT EXISTS ( SELECT DOC~MBLNR
                                         FROM @LT_DOC AS DOC
                                        WHERE DOC~MBLNR = Z~MBLNR
                                     )
     ORDER BY Z~MBLNR, Z~ZEILE
     INTO TABLE @DATA(LT_MAT).
*<E.2026.07.27_ZGODEV04


  DATA LS_TAB TYPE ZGTMMS1011.
  LOOP AT LT_DOC ASSIGNING FIELD-SYMBOL(<LS_DOC>).

    "값 설정
    CLEAR LS_TAB.
    LS_TAB = CORRESPONDING #( <LS_DOC> ).

    "Convertion exit
    LS_TAB-MBLNR = |{ LS_TAB-MBLNR ALPHA = OUT }|.
    LS_TAB-ZEILE = |{ LS_TAB-ZEILE ALPHA = OUT }|.
    LS_TAB-LFBNR = |{ LS_TAB-LFBNR ALPHA = OUT }|.
    LS_TAB-EBELN = |{ LS_TAB-EBELN ALPHA = OUT }|.
    LS_TAB-EBELP = |{ LS_TAB-EBELP ALPHA = OUT }|.

    "수량
    WRITE <LS_DOC>-ERFMG TO LS_TAB-ERFMG LEFT-JUSTIFIED NO-GROUPING.
    CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
      CHANGING
        VALUE = LS_TAB-ERFMG.

    "단위
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        INPUT  = LS_TAB-ERFME
      IMPORTING
        OUTPUT = LS_TAB-ERFME.

    "라인추가
    APPEND LS_TAB TO OT_TAB.
  ENDLOOP.

*>S.2026.07.27_PO 입고 처리 문서 내역 전송 대상에 추가
  IF LT_MAT IS NOT INITIAL.

    LOOP AT LT_MAT ASSIGNING FIELD-SYMBOL(<MAT>).
*2-2) 납품문서 참조 입고 실적 처리 내역(LT_DOC)에 존재하는 자재문서면 제외,
      READ TABLE LT_DOC ASSIGNING FIELD-SYMBOL(<TAB>)
      WITH KEY  MBLNR = <MAT>-MBLNR.

      IF SY-SUBRC = 0.
        CONTINUE.
      ENDIF.

*(LT_DOC)에 없는 자재문서를 대상으로 RETUNR 값 추가 구성
    "값 설정
      CLEAR LS_TAB.
      LS_TAB = CORRESPONDING #( <MAT> ).

      LS_TAB-DELNO = <MAT>-EBELN.
      LS_TAB-DELITEM = <MAT>-EBELP.

    "Convertion exit
      LS_TAB-MBLNR = |{ LS_TAB-MBLNR ALPHA = OUT }|.
      LS_TAB-ZEILE = |{ LS_TAB-ZEILE ALPHA = OUT }|.
      LS_TAB-LFBNR = |{ LS_TAB-LFBNR ALPHA = OUT }|.
      LS_TAB-EBELN = |{ LS_TAB-EBELN ALPHA = OUT }|.
      LS_TAB-EBELP = |{ LS_TAB-EBELP ALPHA = OUT }|.

    "수량
      WRITE <MAT>-ERFMG TO LS_TAB-ERFMG LEFT-JUSTIFIED NO-GROUPING.
      CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
        CHANGING
          VALUE = LS_TAB-ERFMG.

    "단위
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          INPUT  = LS_TAB-ERFME
        IMPORTING
          OUTPUT = LS_TAB-ERFME.

    "라인추가
      APPEND LS_TAB TO OT_TAB.
    ENDLOOP.

  ENDIF.
*2-5) 2-2) 와 2-3) 에서 조회된 데이터를 APPEND 하여 자재문서번호, 자재문서품목 번호로 정렬하여 리턴
  SORT OT_TAB BY MBLNR ZEILE.
*>E.2026.07.27_ZGODEV04

  ZO_RESULT = GC_00. "성공

*>S.2026.09.28_호출별 전송 데이터(ZGTMMT9426) + 호출 로그 종료(ZGTMMT9000, COMMIT)
  PERFORM SET_GR_SEND_LOG TABLES OT_TAB USING I_SDATE I_EDATE.

  LV_LOGMSG = |{ I_SDATE }~{ I_EDATE } 반환 { LINES( OT_TAB ) }건|.
  PERFORM SET_COM_LOG USING 'E' GC_MM00062 'S' LV_LOGMSG CHANGING GS_9000.
*<E.2026.09.28

ENDFUNCTION.
