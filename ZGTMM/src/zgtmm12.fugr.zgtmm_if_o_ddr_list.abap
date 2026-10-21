FUNCTION ZGTMM_IF_O_DDR_LIST.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"     VALUE(I_VBELN) TYPE  VBELN_VA
*"     VALUE(I_POSNR) TYPE  POSNR_VA
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      OT_DATA STRUCTURE  ZGTMMS4519
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_O_DDR_LIST
*& 프로그램 명 :  MES OEM 직송 입고 내역 조회
*& 개요   : OEM 입고 실적 정보를 MES에서 조회해 볼수 있는 RFC 개발
*& 생성일 : 2026.07.20
*& 생성자 : ZGODEV04
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : MES-> EAI -> SAP
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  "초기화
  CLEAR:
    ZO_RESULT,
    ZO_MESSAGE.

  "입력 값 점검
  IF I_SYSTEM_ID EQ SPACE OR I_VBELN EQ SPACE OR I_POSNR EQ SPACE.
    ZO_RESULT = GC_02.
    ZO_MESSAGE = TEXT-E01.
    EXIT.
  ENDIF.

  DATA(LV_VBELN) = |{ I_VBELN ALPHA = IN }|.
  DATA(LV_POSNR) = |{ I_POSNR ALPHA = IN }|.

   "입고내역 조회
  SELECT * FROM ZGTMM_CV_GET_MTO_MVT101_LIST
    WHERE VBELN = @LV_VBELN
         AND POSNR = @LV_POSNR
    INTO TABLE @DATA(LT_TAB).

  IF LT_TAB[] IS INITIAL.
    ZO_RESULT = GC_02.
    ZO_MESSAGE = TEXT-E05."조회된 정보가 없습니다.

  ELSE.
    OT_DATA[] = CORRESPONDING #( LT_TAB[] ).
    ZO_RESULT = GC_00.
    ZO_MESSAGE = TEXT-M05."직송 입고 정보가 조회되었습니다.
  ENDIF.


ENDFUNCTION.
