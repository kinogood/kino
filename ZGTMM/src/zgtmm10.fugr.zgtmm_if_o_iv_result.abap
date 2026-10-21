FUNCTION ZGTMM_IF_O_IV_RESULT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_DATE_FR) TYPE  DATUM
*"     VALUE(I_DATE_TO) TYPE  DATUM
*"     VALUE(I_LIFNR) TYPE  ELIFN
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      OT_IVDATA STRUCTURE  ZGTMMS5002
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_O_IV_RESULT
*& 프로그램 명 : 마감 결과 조회
*& 개요   : G-SRM(전자구매시스템)으로 마감 확정 요청 정보를 전송하는 RFC 개발
*& 생성일 : 2026.02.06
*& 생성자 : ZGODEV04
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

 DATA : BEGIN OF LS_IV.
              INCLUDE TYPE ZGTMMS5002.
 DATA : ERFMG TYPE ERFMG,
            ERFME TYPE ERFME,
            MATNR TYPE MATNR_D,
            EKORG TYPE EKORG,
            WERKS TYPE WERKS_D,
            ESOKZ TYPE ESOKZ,
            MEPRF TYPE MEPRF,
            END OF LS_IV.

 DATA : LT_IV LIKE TABLE OF LS_IV,
            LR_LIFNR TYPE RANGE OF ZGTMMS5002-LIFNR.

 IF I_LIFNR IS INITIAL.
   CLEAR LR_LIFNR.
 ELSE.
   LR_LIFNR = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = I_LIFNR HIGH = SPACE ) ).
 ENDIF.

 SELECT FROM ZGTMM_CV_GET_MATDOC
   FIELDS *
   WHERE BUKRS = @I_BUKRS
        AND BUDAT BETWEEN  @I_DATE_FR  AND @I_DATE_TO
        AND CANCELLED IS INITIAL
        AND REVERSAL_MOVEMENT IS INITIAL
        AND ZGOCONF = @GC_Y
        AND ZVDCONF = @GC_Y
        AND LIFNR IN @LR_LIFNR
        INTO CORRESPONDING FIELDS OF TABLE @LT_IV.

  IF LT_IV[] IS INITIAL.
      ZO_RESULT    = GC_02.
      ZO_MESSAGE = '조건에 맞는 정보가 없습니다.'(E12).
      RETURN.

  ELSE.
*INFORECORD 단가 정보 조회
     SELECT FROM ZGTMM_CV_GET_INFOPRICE
       FIELDS *
       FOR ALL ENTRIES IN @LT_IV
       WHERE LIFNR = @LT_IV-LIFNR
            AND MATNR = @LT_IV-MATNR
            AND EKORG = @LT_IV-EKORG
            AND WERKS = @LT_IV-WERKS
            AND ESOKZ = @LT_IV-ESOKZ
            AND DATAB >= @LT_IV-BUDAT
            AND DATBI <= @LT_IV-BUDAT
            AND LIFNR IN @LR_LIFNR
            INTO TABLE @DATA(LT_INFO).

*정산금액
     LOOP AT  LT_IV ASSIGNING FIELD-SYMBOL(<FS>).
        IF <FS>-MEPRF EQ GC_5.
           READ TABLE LT_INFO ASSIGNING FIELD-SYMBOL(<INFO>)
           WITH KEY LIFNR = <FS>-LIFNR
                          MATNR = <FS>-MATNR
                          EKORG = <FS>-EKORG
                          WERKS = <FS>-WERKS
                          ESOKZ = <FS>-ESOKZ BINARY SEARCH.

           IF SY-SUBRC = 0.
            <FS>-IV_NETPR = <INFO>-KBETR.
            <FS>-IV_PEINH  = <INFO>-KPEIN.
            <FS>-IV_BRTWR = ( <FS>-ERFMG * <INFO>-KBETR ) / <INFO>-KPEIN.
           ENDIF.

        ELSE.
          <FS>-IV_NETPR = <FS>-PO_NETPR.
          <FS>-IV_PEINH  = <FS>-PO_PEINH.
          <FS>-IV_BRTWR = <FS>-PO_BRTWR.
        ENDIF.
     ENDLOOP.

     OT_IVDATA[] = CORRESPONDING #( LT_IV[] ).

     ZO_RESULT    = GC_00.
     ZO_MESSAGE = '확정된 마감 정보를 조회 하였습니다.'(M16).
  ENDIF.


ENDFUNCTION.
