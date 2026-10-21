FUNCTION ZGTMM_IF_I_QI_REQUEST.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_TAB STRUCTURE  ZGTMMS4504
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_QI_REQUEST
*& 프로그램 명 :  OEM 검수요청 FUNCTION(G-SRM->SAP)
*& 개요   : OEM 검수 요청을 등록하는 RFC 개발
*& 생성일 : 2026.04.08
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

  DATA:
    LV_EMAIL     TYPE AD_SMTPADR,
    LV_HEAD_TEXT TYPE SO_OBJ_DES.
  DATA:
    LV_LINE TYPE SO_TEXT255,
    LT_BODY TYPE BCSY_TEXT.
  DATA : LV_CREATE TYPE C.
  DATA : LT_4402 LIKE TABLE OF ZGTMMT4402,
             LT_DEL LIKE TABLE OF ZGTMMT4402,
             LS_DEL TYPE ZGTMMT4402,
             LT_MOD LIKE TABLE OF ZGTMMT4402,
             LS_MOD TYPE ZGTMMT4402.
  DATA:
    lv_check       TYPE c LENGTH 1,
    lo_receiver    TYPE REF TO if_recipient_bcs,
    lo_email       TYPE REF TO cl_bcs,
    lo_email_body  TYPE REF TO cl_document_bcs,
    lx_exception   TYPE REF TO cx_bcs,
    lv_send_result TYPE c.


*--전송 데이터 누락여부 확인
  IF I_SYSTEM_ID IS INITIAL OR I_BUKRS IS INITIAL.

    ZO_RESULT    = GC_02.
    ZO_MESSAGE = '필수 값이 누락 되었습니다.'(E01).
    RETURN.
  ENDIF.

  IF IT_TAB[] IS INITIAL.

    ZO_RESULT    = GC_02.
    ZO_MESSAGE = '필수 값이 누락 되었습니다.'(E01).
    RETURN.

  ELSE.
*테이블 데이터 있더라도, 필수 필드 하나라도 누락 시, 리턴
*1.아래 6개 필드는 공통 필수 체크
    IF LINE_EXISTS( IT_TAB[ EBELN = '' ] )  OR
        LINE_EXISTS( IT_TAB[ EBELP = '' ] )  OR
        LINE_EXISTS( IT_TAB[ ZINSP_NO = '' ] )  OR
        LINE_EXISTS( IT_TAB[ ZINSP_QTY = '' ] ) OR
        LINE_EXISTS( IT_TAB[ MEINS = '' ] ) OR
        LINE_EXISTS( IT_TAB[ ZINSP_CERTI = '' ] ) OR
        LINE_EXISTS( IT_TAB[ ZINSP_DATE = '' ] )   .


      ZO_RESULT    = GC_02.
      ZO_MESSAGE = '검사 요청 필수 값이 누락 되었습니다.'(E23).
      RETURN.

    ENDIF.

  ENDIF.

*--DATA SAVE_ZGTMMT4411
*기존 데이터 가져오기.
  SELECT FROM EKPO
    FIELDS WERKS
    FOR ALL ENTRIES IN @IT_TAB
    WHERE EBELN = @IT_TAB-EBELN
         AND EBELP = @IT_TAB-EBELP
        INTO TABLE @DATA(LT_WERKS).
  SORT LT_WERKS BY WERKS.
  DELETE ADJACENT DUPLICATES FROM LT_WERKS COMPARING WERKS.


*기존 데이터 가져오기.
  SELECT FROM ZGTMMT4402
    FIELDS *
    FOR ALL ENTRIES IN @IT_TAB
    WHERE BUKRS = @I_BUKRS
         AND EBELN = @IT_TAB-EBELN
         AND EBELP = @IT_TAB-EBELP
         AND ZINSP_NO = @IT_TAB-ZINSP_NO
        INTO TABLE @LT_4402.
  SORT LT_4402 BY BUKRS EBELN EBELP ZINSP_NO.


  LOOP AT IT_TAB ASSIGNING FIELD-SYMBOL(<FS>).
        READ TABLE LT_4402 INTO DATA(LS_4402)
        WITH KEY BUKRS = I_BUKRS
                       EBELN = <FS>-EBELN
                       EBELP = <FS>-EBELP
                       ZINSP_NO = <FS>-ZINSP_NO BINARY SEARCH.

        IF SY-SUBRC EQ 0.
             IF <FS>-STATUS = GC_X.
                  IF LS_4402-ZINSPTYPE <> '' OR LS_4402-ZINSPDATE <> '00000000' OR LS_4402-ZINSPRES <> '' OR LS_4402-ZINSP_PERNO <> '' OR LS_4402-ZINSP_NAME <> ''.
                         ZO_RESULT    = GC_02.
                         ZO_MESSAGE = '검사 결과를 접수한 건은 삭제할 수  없습니다.'(E22).
                         RETURN.
                  ELSE.
                          LS_DEL = VALUE #( BASE CORRESPONDING #( LS_4402 )
                                                        AEDAT = SY-DATUM )  .
                         APPEND LS_DEL TO LT_DEL.
                         CLEAR : LS_DEL, LS_4402..
                  ENDIF.

             ELSE.
               LS_MOD = VALUE #( BASE CORRESPONDING #( LS_4402 )
                                          ZINSP_QTY = <FS>-ZINSP_QTY
                                          MEINS = <FS>-MEINS
                                          ZINSP_CERTI = <FS>-ZINSP_CERTI
                                          ZINSP_DATE = <FS>-ZINSP_DATE
                                          AEDAT = SY-DATUM
                                          AETIM  = SY-UZEIT
                                          AENAM = SY-UNAME
                                          AEDAT_LOCAL = SY-DATLO
                                          AETIM_LOCAL  = SY-TIMLO ) .
                          APPEND LS_MOD TO LT_MOD.
                         CLEAR : LS_MOD, LS_4402..




             ENDIF.

        ELSE.

             IF <FS>-STATUS = GC_X.
                         ZO_RESULT    = GC_02.
                         ZO_MESSAGE = '삭제할 검사 요청이 없습니다.'(E21).
                         RETURN.
             ELSE.
               LS_MOD = VALUE #( BASE CORRESPONDING #( <fs> )
                                          BUKRS = I_BUKRS
                                          ERDAT = SY-DATUM
                                          ERTIM = SY-UZEIT
                                          ERNAM = SY-UNAME
                                          ERDAT_LOCAL = SY-DATLO
                                          ERTIM_LOCAL  = SY-TIMLO
                                          AEDAT = SY-DATUM
                                          AETIM  = SY-UZEIT
                                          AENAM = SY-UNAME
                                          AEDAT_LOCAL = SY-DATLO
                                          AETIM_LOCAL  = SY-TIMLO ) .
                          APPEND LS_MOD TO LT_MOD.
                         CLEAR : LS_MOD, LS_4402.



                   LV_CREATE = GC_X.

             ENDIF.

        ENDIF.

  ENDLOOP.

  IF LT_DEL[] IS NOT INITIAL.
      TRY.
         DELETE ZGTMMT4402 FROM TABLE LT_DEL.
*--EXPORT 구성
          IF SY-SUBRC = 0.
            COMMIT WORK AND WAIT .
            ZO_RESULT    = GC_00."NUMBER 00
            ZO_MESSAGE = '검사 요청이 등록되었습니다..'(M27) .
          ENDIF.
        CATCH CX_ROOT INTO DATA(LV_ERROR).

          ZO_MESSAGE = LV_ERROR->GET_TEXT(  ).
          ZO_RESULT    = GC_02. "02
      ENDTRY.
 ENDIF.

 IF LT_MOD[] IS NOT INITIAL.
      TRY.
          MODIFY ZGTMMT4402 FROM TABLE LT_MOD.

*--EXPORT 구성
          IF SY-SUBRC = 0.
            COMMIT WORK AND WAIT .
            ZO_RESULT    = GC_00."NUMBER 00
            ZO_MESSAGE = '검사 요청이 등록되었습니다..'(M26) .
          ENDIF.

        CATCH CX_ROOT INTO DATA(LV_ERROR2).
*             LV_MSG = LV_ERROR->GET_TEXT(  ).
          ZO_MESSAGE = LV_ERROR2->GET_TEXT(  ).
          ZO_RESULT    = GC_02. "02
      ENDTRY.

ENDIF.


   IF LT_WERKS[] IS NOT INITIAL AND LV_CREATE = GC_X.
       SELECT FROM ZGTMMT1021
       FIELDS EMAIL
       FOR ALL ENTRIES IN @LT_WERKS
       WHERE WERKS = @LT_WERKS-WERKS
           AND  ZTYPE = 'QC' "260710 추가_ZGODEV04
       APPENDING TABLE @DATA(lt_ZGTMMT1021_C).
   ENDIF.

IF LT_ZGTMMT1021_C[] IS NOT INITIAL.

*******************담당자 EMAIL 전송**************************
               LV_HEAD_TEXT = '검사 요청이 접수되었습니다.'(m29).

               LV_LINE = |<html><body style="font-size:14">|.
               LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
               LV_LINE = |<p>{ TEXT-EM1 }</p>|.

               LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
               LV_LINE = |<p>SAP T-code <strong>ZGTMMR4370</strong>에서 확인 부탁드립니다. </p>|.
               LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).

********************담당자 EMAIL 전송**************************

  LOOP AT LT_ZGTMMT1021_C  INTO DATA(LS_ZGTMMT1021).
      CLEAR : LV_EMAIL.
       LV_EMAIL =  LS_ZGTMMT1021-EMAIL.

        TRY.
            lo_email = cl_bcs=>create_persistent( ).

            lo_email_body = cl_document_bcs=>create_document(
                            i_type    = 'HTM'
                            i_text    = lt_body
                            i_subject = lv_head_text ).

            lo_email->set_document( lo_email_body ).

            lo_receiver =
            cl_cam_address_bcs=>create_internet_address( lv_email ).

            lo_email->add_recipient( i_recipient = lo_receiver
                                     i_express = 'X' ).

            lo_email->set_send_immediately( 'X' ).

            lo_email->send( EXPORTING i_with_error_screen = 'X'
                            RECEIVING result = lv_send_result ).
          CATCH cx_bcs INTO lx_exception.
            lv_check = gc_e.
        ENDTRY.

        CLEAR : lv_check,    lo_receiver ,  lo_email ,  lo_email_body ,  lx_exception  ,    lv_send_result.

        CLEAR  :  lv_email.

 ENDLOOP.

COMMIT WORK AND WAIT.
CLEAR  : lt_body[], lt_body.
ENDIF.

ENDFUNCTION.
