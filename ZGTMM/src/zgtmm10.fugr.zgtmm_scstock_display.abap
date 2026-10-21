FUNCTION ZGTMM_SCSTOCK_DISPLAY.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_WERKS) TYPE  WERKS_D
*"     VALUE(I_LIFNR) TYPE  LIFNR
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_TAB STRUCTURE  ZGTMMS4006 OPTIONAL
*"      OT_TAB STRUCTURE  ZGTMMS4001 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_SCSTOCK_DISPLAY
*& 프로그램 명 :  사급자재 이전전기 현황 조회 (G-SRM -> SAP)
*& 개요   : G-SRM(전자구매시스템) 에서 SAP로 조회 조건 전송 후 결과 값 리턴
*& 생성일 : 2026.01.07
*& 생성자 : ZGODEV07
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : G-SRM -> EAI -> SAP
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  "초기화
  CLEAR:
    OT_TAB[],
    ZO_RESULT,
    ZO_MESSAGE.

*1) 전송 정보 누락 여부 확인
*	1-1) Import Parameter 중 전송 필수 정보가 없는 경우 다음 값 Return 후 종료
*   Export Parameter                      Value
*   ZO_RESULT                     "02"
*   ZO_MESSAGE                      "필수 값이 누락되었습니다."
  "시스템ID, 플랜트 필수 입력
  IF I_SYSTEM_ID EQ SPACE OR I_BUKRS EQ SPACE OR I_WERKS EQ SPACE OR I_LIFNR EQ SPACE.
    ZO_RESULT = GC_02.
    ZO_MESSAGE = TEXT-E01.
    EXIT.
  ENDIF.

*  	2-1) 공급업체 재고 정보 추출
*     Table : MSLB
*     SELECT 조건 : WERKS, LIFNR, MATNR, CHARG, LBLAB
*
*      WHERE 조건 :
*      WERKS = I_WERKS
*      LIFNR  = I_LIFNR
*
*	2-1) 자재 단위 추출
*     Table : MARA
*     SELECT 조건  MEINS
*
*      WHERE 조건 :
*   MATNR = I_MATNR

  DATA:
    LR_BUKRS TYPE RANGE OF T001-BUKRS,
    LR_WERKS TYPE RANGE OF MSLB-WERKS,
    LR_MATNR TYPE RANGE OF MSLB-MATNR,
    LR_LIFNR TYPE RANGE OF MSLB-LIFNR.

  "회사코드
  LR_BUKRS = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = |{ I_BUKRS ALPHA = IN }| ) ).

  "플랜트
  LR_WERKS = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = |{ I_WERKS ALPHA = IN }| ) ).

  "업체코드
  LR_LIFNR = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = |{ I_LIFNR ALPHA = IN }| ) ).

  "자재코드
  LOOP AT IT_TAB ASSIGNING FIELD-SYMBOL(<LS_ITAB>).

    DATA LV_MATNR TYPE MATNR.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT        = <LS_ITAB>-MATNR
      IMPORTING
        OUTPUT       = LV_MATNR
      EXCEPTIONS
        LENGTH_ERROR = 1
        OTHERS       = 2.
    IF SY-SUBRC NE 0.
      LV_MATNR = <LS_ITAB>-MATNR.
    ENDIF.
    LR_MATNR = VALUE #( BASE LR_MATNR ( SIGN = 'I' OPTION = 'EQ' LOW = LV_MATNR ) ).
  ENDLOOP.

  "재고조회
  SELECT
    MS~WERKS,
    MS~LIFNR,
    MS~MATNR,
    CASE WHEN MR~ZZMAKTX80 EQ @SPACE THEN MT~MAKTX ELSE MR~ZZMAKTX80 END AS ZZMAKTX80,
    MS~CHARG,
    MR~MEINS,
    MS~LBLAB
   FROM MSLB AS MS
             INNER JOIN
           MARA AS MR ON MS~MATNR EQ MR~MATNR
             INNER JOIN
           T001W AS TW ON MS~WERKS EQ TW~WERKS
             INNER JOIN
           T001K AS TK ON TW~BWKEY EQ TK~BWKEY
             LEFT OUTER JOIN
           MAKT AS MT ON MR~MATNR EQ MT~MATNR
                             AND MT~SPRAS EQ @SY-LANGU
   WHERE MS~WERKS IN @LR_WERKS
   AND MS~LIFNR IN @LR_LIFNR
   AND MS~MATNR IN @LR_MATNR
    AND TK~BUKRS IN @LR_BUKRS
   AND MS~LBLAB IS NOT INITIAL
   INTO TABLE @OT_TAB.

  "Convertion Exit
  LOOP AT OT_TAB ASSIGNING FIELD-SYMBOL(<LS_TAB>).
    <LS_TAB>-LIFNR = |{ <LS_TAB>-LIFNR ALPHA = OUT }|.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = <LS_TAB>-MATNR
      IMPORTING
        OUTPUT = <LS_TAB>-MATNR.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        INPUT  = <LS_TAB>-MEINS
      IMPORTING
        OUTPUT = <LS_TAB>-MEINS.

  ENDLOOP.

  ZO_RESULT = GC_00. "성공

ENDFUNCTION.
