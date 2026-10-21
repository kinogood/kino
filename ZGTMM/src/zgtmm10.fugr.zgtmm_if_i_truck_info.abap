FUNCTION ZGTMM_IF_I_TRUCK_INFO.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"     VALUE(ZDOC_NO) TYPE  ZGTE_IV_NO
*"  TABLES
*"      IT_TRUCK STRUCTURE  ZGTMMS4502
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_TRUCK_INFO
*& 프로그램 명 :  OEM 직납 배차 정보 수신(G-SRM->SAP)
*& 개요   : G-SRM에 등록된 배차 정보를 수신하여 저장하는 RFC 개발
*& 생성일 : 2026.01.20
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

  DATA : LT_SAVE LIKE TABLE OF ZGTMMT4403,
             LV_MSG TYPE STRING,
             LV_ZDOC_ITEM_NO TYPE NUMC5.

*>S.2026.09.28_호출 로그 시작(ZGTMMT9000, MM00048)
*  저장 실패 시 ROLLBACK에 로그가 휩쓸리지 않도록 시작 로그는 즉시 확정
  GV_SYSTEM_ID = I_SYSTEM_ID.
  PERFORM SET_COM_LOG USING 'S' GC_MM00048 '' '' CHANGING GS_9000.
  COMMIT WORK.
*<E.2026.09.28

*--전송 데이터 누락여부 확인
  IF I_SYSTEM_ID IS INITIAL OR I_BUKRS IS INITIAL.

      ZO_RESULT    = GC_02.
      ZO_MESSAGE = '필수 값이 누락 되었습니다.'(E01).
      PERFORM SET_TRUCK_LOG_END TABLES IT_TRUCK USING ZO_RESULT ZO_MESSAGE ZDOC_NO.
      RETURN.

  ELSE.
     IF IT_TRUCK[] IS INITIAL.

        ZO_RESULT    = GC_02.
        ZO_MESSAGE = '필수 값이 누락 되었습니다.'(E01).
        PERFORM SET_TRUCK_LOG_END TABLES IT_TRUCK USING ZO_RESULT ZO_MESSAGE ZDOC_NO.
        RETURN.

     ELSE.
*테이블 데이터 있더라도, 필수 필드 하나라도 누락 시, 리턴
       PERFORM CHECK_ERROR TABLES IT_TRUCK   "USING I_TYPE
                                              CHANGING ZO_RESULT ZO_MESSAGE.
       IF ZO_RESULT = GC_02.
            PERFORM SET_TRUCK_LOG_END TABLES IT_TRUCK USING ZO_RESULT ZO_MESSAGE ZDOC_NO.
            RETURN.
       ENDIF.
     ENDIF.

  ENDIF.

*SEQUENCE 정보 추출
  DATA : LT_TRUCK TYPE TABLE OF ZGTMMS4502,
             LT_TRUCK_B TYPE TABLE OF ZGTMMS4502.

  LT_TRUCK[] = LT_TRUCK_B = IT_TRUCK[].

  DELETE ADJACENT DUPLICATES FROM LT_TRUCK
  COMPARING BUKRS ZREQ_TYPE DLVRQ VBELN POSNR EBELN EBELP.
  DELETE LT_TRUCK WHERE ZREQ_TYPE NE GC_A.

  DELETE ADJACENT DUPLICATES FROM LT_TRUCK_B
  COMPARING BUKRS ZREQ_TYPE DLVRQ VBELN POSNR.
  DELETE LT_TRUCK_B WHERE ZREQ_TYPE EQ GC_A.

  CLEAR : GT_4403, GT_4405.
##ITAB_KEY_IN_SELECT
  SELECT A~BUKRS, A~ZREQ_TYPE, A~DLVRQ,
               A~VBELN, A~POSNR, A~EBELN, A~EBELP,
               MAX( A~ZSEQ ) AS ZSEQ
    FROM @LT_TRUCK AS B
    INNER JOIN ZGTMMT4403 AS A
    ON   A~BUKRS = B~BUKRS
    AND  A~ZREQ_TYPE = B~ZREQ_TYPE
    AND A~DLVRQ = B~DLVRQ
    AND A~VBELN = B~VBELN
    AND A~POSNR = B~POSNR
    AND A~EBELN = B~EBELN
    AND A~EBELP = B~EBELP
    WHERE A~ZREQ_TYPE = @GC_A
    GROUP BY A~BUKRS, A~ZREQ_TYPE, A~DLVRQ,
                     A~VBELN, A~POSNR, A~EBELN, A~EBELP
    INTO TABLE @GT_4403.
*>S.2026.09.28_SAVE_DATA_A의 BINARY SEARCH용 정렬
*  미정렬 상태에서 검색 실패 → ZSEQ 001 부여 → 기존 배차 줄 덮어씀
  SORT GT_4403 BY BUKRS ZREQ_TYPE DLVRQ VBELN POSNR EBELN EBELP.
*<E.2026.09.28

##ITAB_KEY_IN_SELECT
  SELECT A~BUKRS, A~ZREQ_TYPE, A~DLVRQ,
               A~VBELN, A~POSNR,
               MAX( A~ZSEQ ) AS ZSEQ
    FROM @LT_TRUCK_B AS B
    INNER JOIN ZGTMMT4405 AS A
    ON   A~BUKRS = B~BUKRS
    AND  A~ZREQ_TYPE = B~ZREQ_TYPE
    AND A~DLVRQ = B~DLVRQ
    AND A~VBELN = B~VBELN
    AND A~POSNR = B~POSNR
    WHERE A~ZREQ_TYPE NE @GC_A
    GROUP BY A~BUKRS, A~ZREQ_TYPE, A~DLVRQ,
                     A~VBELN, A~POSNR
    INTO TABLE @GT_4405.
*>S.2026.09.28_SAVE_DATA_B의 BINARY SEARCH용 정렬
  SORT GT_4405 BY BUKRS ZREQ_TYPE DLVRQ VBELN POSNR.
*<E.2026.09.28

*거래명세서번호 채번
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          NR_RANGE_NR = '01'
          OBJECT      = 'ZTRDOCNO'
        IMPORTING
          NUMBER      = ZDOC_NO.
      IF SY-SUBRC <> 0.
* IMPLEMENT SUITABLE ERROR HANDLING HERE
      ENDIF.

*SAVE DATA
   PERFORM SAVE_DATA_A TABLES IT_TRUCK
                                         CHANGING ZO_RESULT ZO_MESSAGE ZDOC_NO LV_ZDOC_ITEM_NO .

*>S.2026.09.28_A 저장 실패 결과를 B 저장 결과가 덮어쓰지 않도록
   IF ZO_RESULT <> GC_02.
     PERFORM SAVE_DATA_B TABLES IT_TRUCK
                                         CHANGING ZO_RESULT ZO_MESSAGE ZDOC_NO LV_ZDOC_ITEM_NO .
   ENDIF.

*호출 로그 종료(ZGTMMT9000)
   PERFORM SET_TRUCK_LOG_END TABLES IT_TRUCK USING ZO_RESULT ZO_MESSAGE ZDOC_NO.
*<E.2026.09.28



ENDFUNCTION.
