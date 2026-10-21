FUNCTION ZGTMM_IF_O_QI_PROGRESS.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_LIFNR) TYPE  LIFNR OPTIONAL
*"     VALUE(I_EBELN) TYPE  EBELN OPTIONAL
*"     VALUE(I_DATE_F) TYPE  DATS
*"     VALUE(I_DATE_T) TYPE  DATS
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      OT_DATA STRUCTURE  ZGTMMS4505
*"----------------------------------------------------------------------
 DATA : LV_COND TYPE STRING.
 DATA: LR_LIFNR TYPE RANGE OF  ZGTMM_CV_GET_QI_PROGRESS-LIFNR,
           LS_LIFNR LIKE LINE OF LR_LIFNR,
           LR_EBELN TYPE RANGE OF ZGTMM_CV_GET_QI_PROGRESS-EBELN,
           LS_EBELN LIKE LINE OF LR_EBELN.

*--전송 데이터 누락여부 확인
  IF i_system_id IS INITIAL OR i_bukrs  IS INITIAL OR I_DATE_F  IS INITIAL OR  I_DATE_T  IS INITIAL.

    zo_result    = gc_02.
    zo_message = '필수 값이 누락 되었습니다.'(e01).
    RETURN.
  ENDIF.

  LV_COND = | BUKRS = '{ I_BUKRS }' AND AEDAT >=  @I_DATE_F AND AEDAT <=  @I_DATE_T AND ZINSPTYPE <> ''|.

 IF I_LIFNR IS NOT INITIAL.
  LV_COND &&= | AND LIFNR =  @I_LIFNR |.
 ENDIF.

 IF I_EBELN IS NOT INITIAL.
  LV_COND &&= | AND EBELN =  @I_EBELN |.
 ENDIF.


**기존 데이터 가져오기.
  SELECT FROM ZGTMM_CV_GET_QI_PROGRESS
    FIELDS *
    WHERE (LV_COND)  INTO TABLE @DATA(LT_QIRESULT).


   IF LT_QIRESULT[] IS INITIAL.
     ZO_RESULT    = GC_00.
     ZO_MESSAGE = '조건에 맞는 정보가 없습니다.'(E12).

  ELSE.

     OT_DATA[] = CORRESPONDING #( LT_QIRESULT[] ).

     ZO_RESULT    = GC_00.
     ZO_MESSAGE = '검사요청 정보가 조회되었습니다.'(M28).
  ENDIF.



ENDFUNCTION.
