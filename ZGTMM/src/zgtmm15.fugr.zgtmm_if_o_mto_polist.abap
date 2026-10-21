FUNCTION ZGTMM_IF_O_MTO_POLIST.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_D365_LOGIN) TYPE  ZSDS_LOG_0000 OPTIONAL
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_ZPJNO) TYPE  ZPJNO OPTIONAL
*"     VALUE(I_VKBUR) TYPE  VKBUR
*"     VALUE(I_VKGRP) TYPE  VKGRP
*"     VALUE(I_KUNNR) TYPE  KUNAG OPTIONAL
*"     VALUE(I_LIFNR) TYPE  LIFNR OPTIONAL
*"     VALUE(I_VBELN) TYPE  VBELN_VA OPTIONAL
*"     VALUE(I_POSNR) TYPE  POSNR_VA OPTIONAL
*"     VALUE(I_MATNR) TYPE  MATNR OPTIONAL
*"  EXPORTING
*"     VALUE(ES_RETURN) TYPE  ZSDS_LOG_0001
*"  TABLES
*"      OT_DATA STRUCTURE  ZGTMMS4500
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_MTO_POLIST
*& 프로그램 명 :  직송 대상 조회(SAP -> Sales Outlook)
*& 개요   : SAP에서 생성된 구매 오더 Sales Outlook으로 전송하는 RFC
*& 생성일 : 2026.01.13
*& 생성자 : ZGODEV04
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*
*Sales Outlook 공용 로그용
  INCLUDE ZSDC0000.

  DATA : LV_WHERE     TYPE STRING.

*--필수 입력 값 체크
  IF I_BUKRS IS INITIAL OR  I_VKBUR IS INITIAL OR I_VKGRP IS INITIAL.
*Sales Outlook 공용 로그 저장
     PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.
     ES_RETURN = VALUE #( MTYPE = 'E'
                                          MESSAGE = '필수 입력값이 누락 되었습니다.'(M01) ).
     RETURN.
  ENDIF.

*--DATA 조회
*필수 입력 데이터 웨어조건 설정
  LV_WHERE &&= | BUKRS = '{ I_BUKRS }' AND VKBUR = '{ I_VKBUR }'  AND VKGRP = '{ I_VKGRP }' |.

*선택 입력 조건 데이터 유무에 따라 웨어조건 추가
  PERFORM SET_WHERE_OPTION USING I_ZPJNO I_KUNNR I_LIFNR I_VBELN I_POSNR I_MATNR
                                                   CHANGING LV_WHERE.

  SELECT FROM ZGTMM_CV_GET_DDLIST2
    FIELDS *
    WHERE (LV_WHERE)
        INTO TABLE @DATA(LT_DATA).

*--RESULT
  CLEAR OT_DATA.

  IF LT_DATA IS INITIAL.
     ES_RETURN = VALUE #( MTYPE = 'S'
                                          MESSAGE = '해당 조건에 맞는 데이터가 없습니다..'(M02) ).

  ELSE.
     OT_DATA[]  = CORRESPONDING #( LT_DATA[] ).
     ES_RETURN = VALUE #( MTYPE = 'S'
                                          MESSAGE = '조회에 성공 했습니다.'(M03) ).
  ENDIF.

*Sales Outlook 공용 로그 저장
  PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.

ENDFUNCTION.
