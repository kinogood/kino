FUNCTION ZGTMM_IF_I_DIRECTREQ.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_WERKS) TYPE  WERKS_D
*"     VALUE(IS_D365_LOGIN) TYPE  ZSDS_LOG_0000
*"     VALUE(I_PERNR) TYPE  PERSNO
*"     VALUE(I_NAME) TYPE  NAME1
*"     VALUE(I_EMAIL) TYPE  AD_SMTPADR
*"     VALUE(I_TELNO) TYPE  CHAR16
*"  EXPORTING
*"     VALUE(ES_RETURN) TYPE  ZSDS_LOG_0001
*"  TABLES
*"      IT_DATA STRUCTURE  ZGTMMS4511
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_DIRECTREQ
*& 프로그램 명 :  OEM 직납 요청(Sales Outlook -> SAP)
*& 개요   : OEM 직송 의뢰를 접수 받아 SAP Table에 저장하는 RFC
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

  DATA : LT_4410 LIKE TABLE OF ZGTMMT4410,
             LT_4411 LIKE TABLE OF ZGTMMT4411,
             LS_4411 TYPE ZGTMMT4411,
             LT_4412 LIKE TABLE OF ZGTMMT4412,
             LS_4412 TYPE ZGTMMT4412,
             LV_MSG TYPE STRING.

*--필수 입력 값 체크
  IF I_BUKRS IS INITIAL OR I_WERKS IS INITIAL OR  IS_D365_LOGIN IS INITIAL OR
      I_PERNR IS INITIAL OR I_NAME IS INITIAL OR I_EMAIL IS INITIAL.
*Sales Outlook 공용 로그 저장
     PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.
     ES_RETURN = VALUE #( MTYPE = 'E'
                                          MESSAGE = '필수 입력값이 누락 되었습니다.'(M01) ).
     RETURN.
  ENDIF.

  IF IT_DATA[] IS INITIAL.

     ES_RETURN = VALUE #( MTYPE = 'E'
                                          MESSAGE = '필수 입력값이 누락 되었습니다.'(M01) ).
     RETURN.

  ELSE.
*테이블 데이터 있더라도, 필수 필드 하나라도 누락 시, 리턴
       IF LINE_EXISTS( IT_DATA[ ZREQ_TYPE = '' ] )  OR
           LINE_EXISTS( IT_DATA[ DLVRQ = '' ] )  OR
           LINE_EXISTS( IT_DATA[ VKBUR = '' ] ) OR
           LINE_EXISTS( IT_DATA[ VKGRP = '' ] ) OR
           LINE_EXISTS( IT_DATA[ KUNNR = '' ] ) OR
           LINE_EXISTS( IT_DATA[ VBELN = '' ] ) OR
           LINE_EXISTS( IT_DATA[ POSNR = '' ] ) OR
           LINE_EXISTS( IT_DATA[ REQDATE = '' ] ) OR
           LINE_EXISTS( IT_DATA[ REQ_QTY = '' ] ) OR
           LINE_EXISTS( IT_DATA[ DR_MEINS = '' ] ) OR
           LINE_EXISTS( IT_DATA[ AR_DATE = '' ] ) OR
*          LINE_EXISTS( IT_DATA[ BLAND = '' ] ) OR
*         LINE_EXISTS( IT_DATA[ CITY1 = '' ] ) OR
         LINE_EXISTS( IT_DATA[ DEST1 = '' ] ) OR
           LINE_EXISTS( IT_DATA[ SITE_TEL = '' ] ) .

           ES_RETURN = VALUE #( MTYPE = 'E'
                                                MESSAGE = '필수 입력값이 누락 되었습니다.'(M01) ).
           RETURN.
       ENDIF.
  ENDIF.

*--DATA 저장
  LT_4410 = VALUE #( BASE LT_4410
                                 FOR WA IN IT_DATA
                               ( VALUE #( BASE CORRESPONDING #( WA )
                                      BUKRS = I_BUKRS
                                      WERKS = I_WERKS
*                                      ZREQ_TYPE = WA-ZREQ_TYPE
*                                      DLVRQ = WA-DLVRQ
*                                      VKBUR = WA-VKBUR
*                                      VKGRP = WA-VKGRP
*                                      KUNNR = WA-KUNNR
*                                      REQDATE = WA-REQDATE
*                                      AR_DATE = WA-AR_DATE
*                                      AR_TIME = WA-AR_TIME
*                                      BLAND = WA-BLAND
*                                      CITY1 = WA-CITY1
*                                      DEST1 = WA-DEST1
*                                      SITE_NAME = WA-SITE_NAME
*                                      SITE_TEL = WA-SITE_TEL
*                                      CUST_NAME = WA-CUST_NAME
*                                      CUST_TEL = WA-CUST_TEL
*                                      DEST2 = WA-DEST2
*                                      SP_NOTE = WA-SP_NOTE
                                      ZSD_STAT  = 'R'
                                      PERNR = I_PERNR
                                      NAME = I_NAME
                                      EMAIL = I_EMAIL
                                      PER_TEL = I_TELNO
                                      ERDAT = SY-DATUM
                                      ERDAT_LOCAL = SY-DATLO
                                      ERTIM = SY-UZEIT
                                      ERTIM_LOCAL = SY-TIMLO
                                      ERNAM = SY-UNAME ) ) ).

  SORT LT_4410 BY BUKRS ZREQ_TYPE DLVRQ.
  DELETE ADJACENT DUPLICATES FROM LT_4410 COMPARING BUKRS ZREQ_TYPE DLVRQ.


  LOOP AT IT_DATA ASSIGNING FIELD-SYMBOL(<FS>).
    IF  <FS>-ZREQ_TYPE = 'A'.
           LS_4411 = VALUE #( BASE CORRESPONDING #( <FS> )
                                          REQ_DRQTY = <FS>-REQ_QTY
                                          BUKRS = I_BUKRS
                                          ZMM_STAT = ' '
                                         AEDAT = SY-DATUM
                                         AEDAT_LOCAL = SY-DATLO
                                         AETIM = SY-UZEIT
                                         AETIM_LOCAL = SY-TIMLO
                                         AENAM = SY-UNAME ).
                          APPEND LS_4411 TO LT_4411.
                         CLEAR : LS_4411.


    ELSE.
           LS_4412 = VALUE #( BASE CORRESPONDING #( <FS> )
                                          REQ_DRQTY = <FS>-REQ_QTY
                                          BUKRS = I_BUKRS
                                          ZMM_STAT = ' '
                                         AEDAT = SY-DATUM
                                         AEDAT_LOCAL = SY-DATLO
                                         AETIM = SY-UZEIT
                                         AETIM_LOCAL = SY-TIMLO
                                         AENAM = SY-UNAME ).
                          APPEND LS_4412 TO LT_4412.
                         CLEAR : LS_4412.

    ENDIF.

  ENDLOOP.



    IF LT_4411[] IS NOT INITIAL.

    SORT LT_4411 BY BUKRS DLVRQ VBELN POSNR EBELN EBELP.
    DELETE ADJACENT DUPLICATES FROM LT_4411 COMPARING BUKRS DLVRQ VBELN POSNR EBELN EBELP.

    TRY.
       MODIFY ZGTMMT4410 FROM TABLE LT_4410.
       MODIFY ZGTMMT4411 FROM TABLE LT_4411.

       IF SY-SUBRC = 0.
          COMMIT WORK AND WAIT .
          ES_RETURN = VALUE #( MTYPE = 'S'
                                               MESSAGE = '직납 요청 되었습니다.'(M02) ).
       ENDIF.

        CATCH CX_ROOT INTO DATA(LV_ERROR).
             LV_MSG = LV_ERROR->GET_TEXT(  ).
             ES_RETURN = VALUE #( MTYPE = 'S'
                                                  MESSAGE = COND #( WHEN LV_MSG IS INITIAL
                                                                                   THEN '직납 요청 실패!'(M03)
                                                                                   ELSE LV_MSG ) ).
    ENDTRY.


    ENDIF.

   IF LT_4412[] IS NOT INITIAL.
    SORT LT_4412 BY BUKRS DLVRQ VBELN POSNR.
    DELETE ADJACENT DUPLICATES FROM LT_4412 COMPARING BUKRS DLVRQ VBELN POSNR.

    TRY.
       MODIFY ZGTMMT4410 FROM TABLE LT_4410.
       MODIFY ZGTMMT4412 FROM TABLE LT_4412.

       IF SY-SUBRC = 0.
          COMMIT WORK AND WAIT .
          ES_RETURN = VALUE #( MTYPE = 'S'
                                               MESSAGE = '직납 요청 되었습니다.'(M02) ).
       ENDIF.

        CATCH CX_ROOT INTO DATA(LV_ERROR2).
             LV_MSG = LV_ERROR2->GET_TEXT(  ).
             ES_RETURN = VALUE #( MTYPE = 'S'
                                                  MESSAGE = COND #( WHEN LV_MSG IS INITIAL
                                                                                   THEN '직납 요청 실패!'(M03)
                                                                                   ELSE LV_MSG ) ).
    ENDTRY.
   ENDIF.



*Sales Outlook 공용 로그 저장
  PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.

ENDFUNCTION.
