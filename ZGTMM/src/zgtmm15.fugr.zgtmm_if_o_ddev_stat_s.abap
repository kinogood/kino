FUNCTION ZGTMM_IF_O_DDEV_STAT_S.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(IS_D365_LOGIN) TYPE  ZSDS_LOG_0000
*"     VALUE(I_RDATE_F) TYPE  DATS OPTIONAL
*"     VALUE(I_RDATE_T) TYPE  DATS OPTIONAL
*"     VALUE(I_VKBUR) TYPE  VKBUR OPTIONAL
*"     VALUE(I_VKGRP) TYPE  VKGRP OPTIONAL
*"     VALUE(I_KUNNR) TYPE  KUNNR OPTIONAL
*"     VALUE(I_LIFNR) TYPE  LIFNR OPTIONAL
*"     VALUE(I_VBELN) TYPE  VBELN OPTIONAL
*"     VALUE(I_DLVRQ) TYPE  ZEDLVRQ OPTIONAL
*"     VALUE(I_DRDAT_F) TYPE  DATS OPTIONAL
*"     VALUE(I_DRDAT_T) TYPE  DATS OPTIONAL
*"  EXPORTING
*"     VALUE(ES_RETURN) TYPE  ZSDS_LOG_0001
*"  TABLES
*"      OT_DATA STRUCTURE  ZGTMMS4510
*"      OT_TRUCK STRUCTURE  ZGTMMS4512
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_O_DDEV_STAT_S
*& 프로그램 명 :  직송 의뢰 진행 상태 조회(SAP -> Sales Outlook)
*& 개요   : 직송 의뢰 대상의 전체 상태를 조회 할 수 있는 RFC
*& 생성일 : 2026.01.19
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
  DATA : LV_WHERE     TYPE STRING,
             LT_TRUCK      LIKE TABLE OF ZGTMMS4512.

*--필수 입력 값 체크
  IF IS_D365_LOGIN IS INITIAL OR I_BUKRS IS INITIAL.
*Sales Outlook 공용 로그 저장
     PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.
     ES_RETURN = VALUE #( MTYPE = 'E'
                                          MESSAGE = '필수 입력값이 누락 되었습니다.'(M01) ).
     RETURN.
  ENDIF.

  IF I_RDATE_F IS INITIAL.
      IF I_DRDAT_F IS INITIAL OR I_DRDAT_T IS INITIAL.
*Sales Outlook 공용 로그 저장
     PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.
     ES_RETURN = VALUE #( MTYPE = 'E'
                                          MESSAGE = '필수 입력값이 누락 되었습니다.'(M01) ).
     RETURN.

     IF  I_RDATE_T IS INITIAL.
*Sales Outlook 공용 로그 저장
     PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.
     ES_RETURN = VALUE #( MTYPE = 'E'
                                          MESSAGE = '필수 입력값이 누락 되었습니다.'(M01) ).
     RETURN.
     ENDIF.
     ENDIF.
  ENDIF.

  I_LIFNR = |{ I_LIFNR   ALPHA = IN }|.
  I_kunnr = |{ I_kunnr   ALPHA = IN }|.


*--DATA 조회
*필수 입력 데이터 웨어조건 설정

 IF I_RDATE_F IS NOT INITIAL.
  LV_WHERE &&= | BUKRS = '{ I_BUKRS }' AND REQDATE >= '{ I_RDATE_F }'  AND REQDATE <= '{ I_RDATE_T }' |.
 ELSE.
   LV_WHERE &&= | BUKRS = '{ I_BUKRS }' AND DRDAT >= '{ I_DRDAT_F }'  AND DRDAT <= '{ I_DRDAT_T }' |.
 ENDIF.
*선택 입력 조건 데이터 유무에 따라 웨어조건 추가
  PERFORM SET_WHERE_OPTION2 USING I_VKBUR I_VKGRP I_KUNNR I_LIFNR I_VBELN  I_DLVRQ
                                                   CHANGING LV_WHERE.

  SELECT FROM ZGTMM_CV_GET_DDINFO
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

*배차정보 가져오기
     CLEAR LT_TRUCK.
     SELECT FROM ZGTMMT4403
       FIELDS *
       FOR ALL ENTRIES IN @LT_DATA
       WHERE BUKRS         EQ @LT_DATA-BUKRS
            AND ZREQ_TYPE EQ @LT_DATA-ZREQ_TYPE
            AND DLVRQ         EQ @LT_DATA-DLVRQ
            AND VBELN         EQ @LT_DATA-VBELN
            AND POSNR        EQ @LT_DATA-POSNR
            AND EBELN         EQ @LT_DATA-EBELN
            AND EBELP         EQ @LT_DATA-EBELP
            INTO CORRESPONDING FIELDS OF TABLE @LT_TRUCK.

     SELECT FROM ZGTMMT4405
       FIELDS *
       FOR ALL ENTRIES IN @LT_DATA
       WHERE BUKRS         EQ @LT_DATA-BUKRS
            AND ZREQ_TYPE EQ @LT_DATA-ZREQ_TYPE
            AND DLVRQ         EQ @LT_DATA-DLVRQ
            AND VBELN         EQ @LT_DATA-VBELN
            AND POSNR        EQ @LT_DATA-POSNR
            APPENDING CORRESPONDING FIELDS OF TABLE @LT_TRUCK.

      IF LT_TRUCK[] IS NOT INITIAL.
          OT_TRUCK[] =  LT_TRUCK[].
      ENDIF.

      ES_RETURN = VALUE #( MTYPE = 'S'
                                           MESSAGE = '조회에 성공 했습니다..'(M03) ).
  ENDIF.

*Sales Outlook 공용 로그 저장
  PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.

ENDFUNCTION.
