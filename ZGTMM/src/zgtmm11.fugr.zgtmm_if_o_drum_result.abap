FUNCTION ZGTMM_IF_O_DRUM_RESULT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_EKORG) TYPE  EKORG
*"     VALUE(I_WERKS) TYPE  WERKS_D
*"     VALUE(I_LIFNR) TYPE  LIFNR
*"     VALUE(I_DATE_FROM) TYPE  SY-DATUM
*"     VALUE(I_DATE_TO) TYPE  SY-DATUM
*"     VALUE(I_DRM_TYPE) TYPE  ZGTEDRMTYPE OPTIONAL
*"     VALUE(I_DRM_LV) TYPE  ZGTEDRMLV OPTIONAL
*"     VALUE(I_MATNR) TYPE  MATNR OPTIONAL
*"     VALUE(I_MAKTX) TYPE  MAKTX OPTIONAL
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      OT_RESULT STRUCTURE  ZGTMMS9001
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_O_DRUM_RESULT
*& 프로그램 명 :  목드럼 작업 실적 송신(SAP -> G-SRM)
*& 개요   : 수신된 조회 조건에 맞는 목드럼 실적을 리턴하는 FUNCTION
*& 생성일 : 2026.01.22
*& 생성자 : ZGODEV04
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

 DATA : LV_WHERE TYPE STRING,
            LV_MAKTX TYPE STRING,
            LV_MATNR TYPE MATNR_D,
            LT_RESULT TYPE TABLE OF ZGTMMS9001,
            LS_RESULT TYPE ZGTMMS9001.

DATA : LR_TYPE    TYPE RANGE OF ZGTMMS9001-DRM_TYPE,
           LR_LV        TYPE RANGE OF ZGTMMS9001-DRM_LV,
           LR_MATNR TYPE RANGE OF ZGTMMS9001-MATNR.


*--전송 데이터 누락여부 확인
  IF I_SYSTEM_ID IS INITIAL OR I_BUKRS IS INITIAL OR I_EKORG IS INITIAL OR
      I_WERKS IS INITIAL OR I_LIFNR IS INITIAL OR I_DATE_FROM IS INITIAL OR
      I_DATE_TO IS INITIAL.

      ZO_RESULT    = GC_02.
      ZO_MESSAGE = '필수 값이 누락 되었습니다.'(E01).
      RETURN.
  ENDIF.

*--DATA SELECT
*조회조건 설정_입력된 값이 있으면, 해당 값 적용, 없으면 전체조회 되도록..
 LV_MAKTX = COND #( WHEN I_MAKTX IS INITIAL THEN '%' ELSE '%' && I_MAKTX && '%' ).
 LV_MATNR = COND #( WHEN I_MATNR IS INITIAL THEN '%' ELSE '%' && I_MATNR && '%' ).
 I_LIFNR = |{ I_LIFNR ALPHA = IN }|.

 IF I_DRM_TYPE IS INITIAL.
   CLEAR LR_TYPE.
 ELSE.
   LR_TYPE    = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = I_DRM_TYPE HIGH = SPACE ) ).
 ENDIF.

 IF I_DRM_LV IS INITIAL.
   CLEAR LR_LV.
 ELSE.
   LR_LV        = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = I_DRM_LV HIGH = SPACE ) ).
 ENDIF.

SELECT  A~BUKRS, A~EKORG, A~WERKS, A~LIFNR, C~MATNR,
              A~SPMON, B~ZDATE, C~DRM_TYPE, C~DRM_LV, C~DRM_SG_TYPE,
              MR~ZZMAKTX80, D~MAKTX,
              C~DRM_COUNT, C~DRM_PRICE, C~BOARD_COUNT, C~BOARD_PRICE,
              C~MARK_COUNT, C~MARK_PRICE, C~DIS_COUNT, C~DIS_PRICE,
              A~WAERS, C~MEINS, B~MEINH,
              B~EMP_TIME, B~DLAB_TIME, B~OVER_TIME, A~ADJUST, A~TEXT

  FROM ZGTMMT4270 AS A JOIN ZGTMMT4271 AS B
      ON A~EKORG EQ B~EKORG
     AND A~WERKS EQ B~WERKS
     AND A~LIFNR   EQ B~LIFNR
     AND A~SPMON EQ B~SPMON

    LEFT OUTER JOIN ZGTMMT4272 AS C
      ON B~EKORG EQ C~EKORG
    AND B~WERKS EQ C~WERKS
    AND B~LIFNR   EQ C~LIFNR
    AND B~ZDATE  EQ C~ZDATE

    LEFT OUTER JOIN MARA AS MR
      ON C~MATNR EQ MR~MATNR

    LEFT OUTER JOIN MAKT AS D
      ON C~MATNR EQ D~MATNR
     AND D~SPRAS EQ @GC_3

  WHERE A~BUKRS = @I_BUKRS
      AND A~EKORG = @I_EKORG
      AND A~WERKS = @I_WERKS
      AND A~LIFNR   = @I_LIFNR
      AND B~ZDATE BETWEEN @I_DATE_FROM AND @I_DATE_TO
      AND C~DRM_TYPE IN @LR_TYPE
      AND C~DRM_LV     IN @LR_LV
      AND C~MATNR LIKE @LV_MATNR
      AND ( ( MR~ZZMAKTX80 NE @SPACE AND MR~ZZMAKTX80 LIKE @LV_MAKTX )
         OR ( MR~ZZMAKTX80 EQ @SPACE AND D~MAKTX LIKE @LV_MAKTX ) )

      INTO TABLE @DATA(LT_DATA).

   IF LT_DATA IS INITIAL.
    ZO_RESULT    = GC_02. "02
    ZO_MESSAGE = '조회된 정보가 없습니다.'(M08).

   ELSE.
      CLEAR : LS_RESULT, LT_RESULT.
*회사코드 별 전기일자 체크
      SELECT SINGLE *
        FROM MARV
        WHERE BUKRS = @I_BUKRS
        INTO @DATA(LS_MARV).
        DATA(LV_MON) =  LS_MARV-LFGJA && LS_MARV-LFMON .

      LOOP AT LT_DATA INTO DATA(WA).
         LS_RESULT = CORRESPONDING #( WA ).
         LS_RESULT-MAKTX = COND #( WHEN WA-ZZMAKTX80 IS NOT INITIAL
                                   THEN WA-ZZMAKTX80
                                   ELSE WA-MAKTX ).
         LS_RESULT-MON_CLOSE = COND #( WHEN WA-SPMON < LV_MON
                                                                  THEN GC_X ELSE SPACE ).
*금액필드_원화표기 변환
         PERFORM CONVERT_CURRENCY  USING WA-DRM_PRICE CHANGING LS_RESULT-DRM_PRICE.
         PERFORM CONVERT_CURRENCY  USING WA-BOARD_PRICE CHANGING LS_RESULT-BOARD_PRICE.
         PERFORM CONVERT_CURRENCY  USING WA-MARK_PRICE CHANGING LS_RESULT-MARK_PRICE.
         PERFORM CONVERT_CURRENCY  USING WA-DIS_PRICE CHANGING LS_RESULT-DIS_PRICE.
         PERFORM CONVERT_CURRENCY  USING WA-ADJUST CHANGING LS_RESULT-ADJUST.

         LS_RESULT-LIFNR   = |{ WA-LIFNR ALPHA = OUT }|.
         LS_RESULT-MATNR = |{ WA-MATNR ALPHA = OUT }|.

         APPEND LS_RESULT TO LT_RESULT.
         CLEAR : WA, LS_RESULT.
      ENDLOOP.

*--EXPORT 구성
      OT_RESULT[] = LT_RESULT[].

      IF OT_RESULT[] IS INITIAL.
        ZO_RESULT    = GC_02. "02
        ZO_MESSAGE = '조회된 정보가 없습니다.'(M08).
      ELSE.
        ZO_RESULT    = GC_00."NUMBER 00
        ZO_MESSAGE = '데이터 조회에 성공했습니다.'(M10).
      ENDIF.

   ENDIF.


ENDFUNCTION.
