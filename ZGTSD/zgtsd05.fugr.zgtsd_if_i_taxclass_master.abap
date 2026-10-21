FUNCTION ZGTSD_IF_I_TAXCLASS_MASTER.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_D365_LOGIN) TYPE  ZSDS_LOG_0000 OPTIONAL
*"  EXPORTING
*"     VALUE(ES_RETURN) TYPE  ZSDS_LOG_0001
*"  TABLES
*"      IT_DATA STRUCTURE  RANGE_KUNAG OPTIONAL
*"      OT_DATA STRUCTURE  ZGTSDSIF0013 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : SD
*& 프로그램 ID : ZGTSD_IF_I_TAXCLASS_MASTER
*& 프로그램 명 : 지급처 세금분류코드 조회
*& 개요   :
*& 생성일 : 2025.07.09
*& 생성자 : ZGSISD02
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : SalesOutlook
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*
  INCLUDE ZSDC0000.

  DATA : LT_DATA TYPE TABLE OF RANGE_KUNAG WITH EMPTY KEY.
  RANGES: LR_KUNNR FOR VBAK-KUNNR,
           lr_vkorg FOR mvke-vkorg. "판매법인Roll-in / 22.04.2026 10:20:12

  CLEAR: ES_RETURN, OT_DATA, OT_DATA[], LT_DATA, LT_DATA[], LR_KUNNR, LR_KUNNR[].
*-----------------------------------------------------------------------
*-- Import 값 정합성 체크
*-----------------------------------------------------------------------
  IF IS_D365_LOGIN-ENAME IS INITIAL OR IT_DATA[] IS INITIAL.
    ES_RETURN-MTYPE = 'E'.
*    ES_RETURN-MESSAGE = '필수 입력값이 누락 되었습니다.'.
    ES_RETURN-MESSAGE = text-001..
    PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.
    EXIT.
  ENDIF.

  DELETE ADJACENT DUPLICATES FROM IT_DATA[] COMPARING LOW.

  LT_DATA[] = CORRESPONDING #( IT_DATA[] ).

  LOOP AT LT_DATA INTO DATA(LS_DATA).
    LS_DATA-LOW = |{ LS_DATA-LOW ALPHA = IN }|.
    __RNG LR_kunnr 'I' 'EQ' LS_DATA-LOW ''.
  ENDLOOP.

*{ 판매법인Roll-in / 22.04.2026 10:23:52 - Start
  IF  is_d365_login-vkorg IS NOT INITIAL.
    _ranges lr_vkorg  is_d365_login-vkorg.
  ENDIF.
*} - End

*-----------------------------------------------------------------------
*-- Sold-to Party에 연결된 Payer의 Tax Classification 정보 조회
*-----------------------------------------------------------------------
  IF LR_KUNNR[] IS NOT INITIAL.
    SELECT A~VKORG, A~VTWEG, A~SPART, A~KUNNR,
           A~KUNN2 AS KUNRG, B~ALAND, B~TATYP, B~TAXKD
     INTO CORRESPONDING FIELDS OF TABLE @OT_DATA
    FROM KNVP AS A
      LEFT OUTER JOIN KNVI AS B
      ON A~KUNN2 EQ B~KUNNR
    WHERE A~KUNNR IN @LR_KUNNR
      AND A~VKORG IN @LR_VKORG "판매법인Roll-in / 22.04.2026 10:50:41
      AND A~PARVW EQ 'RG'. "PAYER

    SORT OT_DATA BY KUNNR KUNRG VKORG VTWEG SPART.
  ENDIF.

  IF OT_DATA[] IS NOT INITIAL.
    ES_RETURN = VALUE #( MTYPE = ZGTSD_S MESSAGE = TEXT-M18 ).
  ELSE.
    ES_RETURN = VALUE #( MTYPE = ZGTSD_E MESSAGE = TEXT-E32 ).
  ENDIF.

  PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.

ENDFUNCTION.
