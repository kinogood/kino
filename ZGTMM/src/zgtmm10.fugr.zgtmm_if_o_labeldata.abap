FUNCTION ZGTMM_IF_O_LABELDATA.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_DATE_F) TYPE  DATUM OPTIONAL
*"     VALUE(I_DATE_T) TYPE  DATUM OPTIONAL
*"     VALUE(I_LIFNR) TYPE  ELIFN OPTIONAL
*"     VALUE(I_VBELN) TYPE  VBELN OPTIONAL
*"     VALUE(I_POSNR) TYPE  POSNR OPTIONAL
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      OT_LABEL STRUCTURE  ZGTMMS5004
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_O_LABELDATA
*& 프로그램 명 : 마감 결과 조회
*& 개요   : G-SRM(전자구매시스템)으로 마감 확정 요청 정보를 전송하는 RFC 개발
*& 생성일 : 2026.02.12
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

 DATA : LR_LIFNR TYPE RANGE OF ZGTMMS5002-LIFNR,
            LV_COND TYPE STRING.

*--필수 입력 값 체크
  IF I_SYSTEM_ID IS INITIAL OR I_BUKRS IS INITIAL.

     ZO_RESULT    = '02'.
     ZO_MESSAGE = '필수 값이 누락 되었습니다.'(E01).
     RETURN.
  ENDIF.

  IF ( I_DATE_F IS INITIAL AND I_DATE_T IS NOT INITIAL )
     OR ( I_DATE_F IS NOT INITIAL AND I_DATE_T IS INITIAL ).

     ZO_RESULT    = '02'.
     ZO_MESSAGE = '조회 기간 입력 시 FROM~TO로 입력하세요.'(E13).
     RETURN.
  ENDIF.

  LV_COND = | BUKRS = '{ I_BUKRS }' |.
  IF I_LIFNR IS NOT INITIAL.
     LV_COND &&= | AND LIFNR = '{ I_LIFNR }' |.
  ENDIF.

  IF I_VBELN IS NOT INITIAL.
     LV_COND &&= | AND VBELN = '{ I_VBELN }' |.
  ENDIF.

  IF I_POSNR IS NOT INITIAL.
     LV_COND &&= | AND POSNR = '{ I_POSNR }' |.
  ENDIF.

  IF I_DATE_F IS NOT INITIAL.
     LV_COND &&= | AND AEDAT BETWEEN '{ I_DATE_F }' AND '{ I_DATE_T }' |.
  ENDIF.

*  IF I_LIFNR IS INITIAL.
*   CLEAR LR_LIFNR.
*  ELSE.
*   LR_LIFNR = VALUE #( ( SIGN = GC_I OPTION = GC_EQ LOW = I_LIFNR HIGH = SPACE ) ).
*  ENDIF.

*라벨 특기사항 정보 가져오기
  SELECT FROM ZGTMM_CV_GET_DRUMLABELINFO
       FIELDS *
       WHERE (LV_COND)
            INTO TABLE @DATA(LT_INFO).

  IF LT_INFO[] IS INITIAL.
     ZO_RESULT    = GC_00.
     ZO_MESSAGE = '조건에 맞는 정보가 없습니다.'(E12).

  ELSE.
*     LOOP AT  LT_INFO ASSIGNING FIELD-SYMBOL(<FS>).
*     ENDLOOP.

     OT_LABEL[] = CORRESPONDING #( LT_INFO[] ).

     ZO_RESULT    = GC_00.
     ZO_MESSAGE = '라벨 특기사항이 조회되었습니다.'(M17).
  ENDIF.


ENDFUNCTION.
