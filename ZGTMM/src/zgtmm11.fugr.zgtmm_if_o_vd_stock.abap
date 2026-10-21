FUNCTION ZGTMM_IF_O_VD_STOCK.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_LIFNR) TYPE  LIFNR
*"     VALUE(I_WERKS) TYPE  WERKS_D
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_MATNR STRUCTURE  ZGTMMS4506 OPTIONAL
*"      IT_VBELN STRUCTURE  ZGTMMS4514 OPTIONAL
*"      OT_DATA STRUCTURE  ZGTMMS4507 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_O_VD_STOCK
*& 프로그램 명 : 보관재고현황조회 송신(SAP -> G-SRM)
*& 개요   : 보관재고 현황을 조회할 수 있는 RFC 개발
*& 생성일 : 2026.08.06
*& 생성자 : ZGODEV04
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  DATA : LV_WHERE  TYPE STRING,
         LV_MAKTX  TYPE STRING,
         LV_MATNR  TYPE MATNR_D,
         LT_RESULT TYPE TABLE OF ZGTMMS4507,
         LS_RESULT TYPE ZGTMMS4507.

  DATA :
    LR_MATNR TYPE RANGE OF ZGTMMS9001-MATNR,
    LR_VBELN TYPE RANGE OF VBELN.


*--전송 데이터 누락여부 확인
  IF I_SYSTEM_ID IS INITIAL OR I_BUKRS IS INITIAL OR
     I_LIFNR IS INITIAL OR I_WERKS IS INITIAL.
    ZO_RESULT    = GC_02.
    ZO_MESSAGE = '필수 값이 누락 되었습니다.'(E01).
    RETURN.
  ENDIF.

*--DATA SELECT
  IF IT_MATNR[] IS INITIAL.
    CLEAR LR_MATNR.
  ELSE.
    LOOP AT IT_MATNR INTO DATA(LS_MAT).
      LS_MAT-MATNR = CONV MATNR18( |{ LS_MAT-MATNR ALPHA = IN }| ).
      APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LS_MAT-MATNR ) TO  LR_MATNR.
    ENDLOOP.
  ENDIF.

  IF IT_VBELN[] IS INITIAL.
    CLEAR LR_VBELN.
  ELSE.
    LOOP AT IT_VBELN INTO DATA(LS_SO).
      APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LS_SO-VBELN ) TO  LR_VBELN.
    ENDLOOP.
  ENDIF.

*조회조건 설정_입력된 값이 있으면, 해당 값 적용, 없으면 전체조회 되도록..
* LV_MATNR = COND #( WHEN I_MATNR IS INITIAL THEN '%' ELSE '%' && I_MATNR && '%' ).
  I_LIFNR = |{ I_LIFNR ALPHA = IN }|.

  SELECT *
    FROM ZGTMM_CV_GET_STOCK_VENDOR_SUM
    WHERE BUKRS = @I_BUKRS
         AND LIFNR = @I_LIFNR
         AND WERKS = @I_WERKS
         AND MATNR IN @LR_MATNR
         AND VBELN IN @LR_VBELN
    INTO TABLE @DATA(LT_DATA).

  IF LT_DATA IS INITIAL.
    ZO_RESULT    = GC_02. "02
    ZO_MESSAGE = '조회된 정보가 없습니다.'(M08).

  ELSE.
    CLEAR : LS_RESULT, LT_RESULT.

    LOOP AT LT_DATA INTO DATA(WA).
      LS_RESULT = CORRESPONDING #( WA ).

      LS_RESULT-LIFNR   = |{ WA-LIFNR ALPHA = OUT }|.
      LS_RESULT-MATNR = |{ WA-MATNR ALPHA = OUT }|.

      APPEND LS_RESULT TO LT_RESULT.
      CLEAR : WA, LS_RESULT.
    ENDLOOP.

*--EXPORT 구성
    OT_DATA[] = LT_RESULT[].

    IF OT_DATA[] IS INITIAL.
      ZO_RESULT    = GC_02. "02
      ZO_MESSAGE = '조회된 정보가 없습니다.'(M08).
    ELSE.
      ZO_RESULT    = GC_00."NUMBER 00
      ZO_MESSAGE = '데이터 조회에 성공했습니다.'(M10).
    ENDIF.

  ENDIF.


ENDFUNCTION.
