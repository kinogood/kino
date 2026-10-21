FUNCTION ZGTMM_IF_O_311_RESULT_SEND.
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
*& 프로그램 ID : ZGTMM_IF_O_311_RESULT_SEND
*& 프로그램 명 : 매입보관품 311 이동 실적 전송(SAP->G-PRO)
*& 개요   : MES 드럼라벨 입고(ZGTMM_IF_I_DRGR_RCV)에서 재고이전(311)으로
*&          처리된 자재문서(취소 312 포함)를 납품문서(DELNO) 기준으로 리턴
*&          - 101/102 입고 실적은 ZGTMM_IF_O_GR_RESULT_SEND 에서 전송
*&          - 이동유형은 전송하지 않음(DELNO 로 G-PRO 가 처리 유형 판단)
*& 생성일 : 2026.10.06
*& 생성자 :
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : G-PRO -> EAI -> SAP
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  "I/F 번호 - 확정 후 변경 (호출 로그 ZGTMMT9000 ZIFNO)
  CONSTANTS LC_ZIFNO TYPE C LENGTH 7 VALUE 'MM00068'.

  DATA LV_LOGMSG TYPE ZGTEBAPIMSG.

  "초기화
  CLEAR:
    OT_TAB[],
    ZO_RESULT,
    ZO_MESSAGE.

*>호출 로그 시작(ZGTMMT9000)
  GV_SYSTEM_ID = I_SYSTEM_ID.
  PERFORM SET_COM_LOG USING 'S' LC_ZIFNO '' '' CHANGING GS_9000.

*1) 전송 정보 누락 여부 확인
*   필수 값이 없는 경우 ZO_RESULT "02", ZO_MESSAGE "필수 값이 누락되었습니다." 후 종료
  IF I_SYSTEM_ID EQ SPACE OR I_BUKRS EQ SPACE
    OR I_SDATE IS INITIAL OR I_EDATE IS INITIAL
    OR I_SDATE EQ SPACE OR I_EDATE EQ SPACE.
    ZO_RESULT = GC_02.
    ZO_MESSAGE = TEXT-E01.
    LV_LOGMSG = |{ ZO_MESSAGE } ({ I_BUKRS }/{ I_SDATE }~{ I_EDATE })|.
    PERFORM SET_COM_LOG USING 'E' LC_ZIFNO 'E' LV_LOGMSG CHANGING GS_9000.
    EXIT.
  ENDIF.

  DATA:
    LR_CPUDT TYPE RANGE OF MATDOC-CPUDT,
    LR_WERKS TYPE RANGE OF MATDOC-WERKS.

  "입력일(CPUDT) 기준 - ZGTMM_IF_O_GR_RESULT_SEND 와 동일
  LR_CPUDT = VALUE #( ( SIGN = 'I' OPTION = 'BT' LOW = I_SDATE HIGH = I_EDATE ) ).

*2-1) 입력 받은 BUKRS 기준 대상 플랜트 선정
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
    PERFORM SET_COM_LOG USING 'E' LC_ZIFNO 'S' LV_LOGMSG CHANGING GS_9000.
    EXIT.
  ENDIF.

*2-2) CDS VIEW ZGTMM_CV_GET_MATDOC_311 조회
*   312(취소) 인 경우 REVERSAL_MOVEMENT = "X" 이면 ERFMG * -1
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
    FROM ZGTMM_CV_GET_MATDOC_311 AS V1
    WHERE V1~CPUDT IN @LR_CPUDT
      AND V1~WERKS IN @LR_WERKS
    ORDER BY V1~MBLNR, V1~ZEILE
    INTO TABLE @DATA(LT_311).

  DATA LS_TAB TYPE ZGTMMS1011.
  LOOP AT LT_311 ASSIGNING FIELD-SYMBOL(<LS_311>).

    "값 설정
    CLEAR LS_TAB.
    LS_TAB = CORRESPONDING #( <LS_311> ).

    "Convertion exit
    LS_TAB-MBLNR = |{ LS_TAB-MBLNR ALPHA = OUT }|.
    LS_TAB-ZEILE = |{ LS_TAB-ZEILE ALPHA = OUT }|.
    LS_TAB-LFBNR = |{ LS_TAB-LFBNR ALPHA = OUT }|.
    LS_TAB-EBELN = |{ LS_TAB-EBELN ALPHA = OUT }|.
    LS_TAB-EBELP = |{ LS_TAB-EBELP ALPHA = OUT }|.

    "수량
    WRITE <LS_311>-ERFMG TO LS_TAB-ERFMG LEFT-JUSTIFIED NO-GROUPING.
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

  SORT OT_TAB BY MBLNR ZEILE.

  ZO_RESULT = GC_00. "성공

*>호출 로그 종료(ZGTMMT9000, COMMIT)
  LV_LOGMSG = |{ I_SDATE }~{ I_EDATE } 반환 { LINES( OT_TAB ) }건|.
  PERFORM SET_COM_LOG USING 'E' LC_ZIFNO 'S' LV_LOGMSG CHANGING GS_9000.

ENDFUNCTION.
