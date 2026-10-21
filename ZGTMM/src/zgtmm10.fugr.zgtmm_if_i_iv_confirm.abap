FUNCTION ZGTMM_IF_I_IV_CONFIRM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_IVDATA STRUCTURE  ZGTMMS5001
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_IV_CONFIRM
*& 프로그램 명 :  업체 마감 결과 수신(G-SRM->SAP)
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

  DATA : LT_5000 LIKE TABLE OF ZGTMMT5000,
         LT_SAVE LIKE TABLE OF ZGTMMT5000,
         LS_SAVE TYPE ZGTMMT5000,
         LV_MSG  TYPE STRING.
  CLEAR : LS_SAVE, LT_SAVE.

*--전송 데이터 누락여부 확인
  IF I_SYSTEM_ID IS INITIAL OR I_BUKRS IS INITIAL.

    ZO_RESULT    = GC_02.
    ZO_MESSAGE = '필수 값이 누락 되었습니다.'(E01).
    RETURN.
  ENDIF.

  IF IT_IVDATA[] IS INITIAL.

    ZO_RESULT    = GC_02.
    ZO_MESSAGE = '필수 값이 누락 되었습니다.'(E01).
    RETURN.

  ELSE.
*테이블 데이터 있더라도, 필수 필드 하나라도 누락 시, 리턴
*1.아래 6개 필드는 공통 필수 체크
    IF LINE_EXISTS( IT_IVDATA[ LIFNR = '' ] )  OR
        LINE_EXISTS( IT_IVDATA[ PERIOD = '' ] )  OR
        LINE_EXISTS( IT_IVDATA[ MJAHR = '' ] )  OR
        LINE_EXISTS( IT_IVDATA[ MBLNR = '' ] ) OR
        LINE_EXISTS( IT_IVDATA[ ZEILE = '' ] ) OR
        LINE_EXISTS( IT_IVDATA[ ZVDCONF = '' ] ) .

      ZO_RESULT    = GC_02.
      ZO_MESSAGE = '필수 값이 누락 되었습니다.'(E01).
      RETURN.
    ENDIF.

  ENDIF.

*--DATA SAVE_ZGTMMT5000
*기존 데이터 가져오기.
  SELECT FROM ZGTMMT5000
    FIELDS *
    FOR ALL ENTRIES IN @IT_IVDATA
    WHERE MJAHR = @IT_IVDATA-MJAHR
         AND MBLNR = @IT_IVDATA-MBLNR
         AND ZEILE = @IT_IVDATA-ZEILE
        INTO TABLE @LT_5000.
  SORT LT_5000 BY MJAHR MBLNR ZEILE.

  IF LT_5000[] IS INITIAL.
    ZO_RESULT    = GC_02."NUMBER 00
    ZO_MESSAGE = '변경 할 기존 데이터가 없습니다.'(E11) .

  ELSE.
    LOOP AT IT_IVDATA ASSIGNING FIELD-SYMBOL(<FS>).

        READ TABLE LT_5000 ASSIGNING FIELD-SYMBOL(<FS5000>)
        WITH KEY MJAHR = <FS>-MJAHR
                       MBLNR = <FS>-MBLNR
                       ZEILE = <FS>-ZEILE BINARY SEARCH.

        IF SY-SUBRC = 0 AND <FS5000> IS ASSIGNED.
            LS_SAVE = VALUE #( BASE CORRESPONDING #( <FS5000> )
                                          ZVDCONF = <FS>-ZVDCONF
                                          ZMEMO = <FS>-ZMEMO
                                          AEDAT = SY-DATUM
                                          AETIM  = SY-UZEIT
                                          AENAM = SY-UNAME
                                          AEDAT_LOCAL = SY-DATLO
                                          AETIM_LOCAL  = SY-TIMLO ) .
        APPEND LS_SAVE TO LT_SAVE.
      ENDIF.

      CLEAR  LS_SAVE.
    ENDLOOP.

    IF LT_SAVE[] IS NOT INITIAL.
      TRY.
          MODIFY ZGTMMT5000 FROM TABLE LT_SAVE.

*--EXPORT 구성
          IF SY-SUBRC = 0.
            COMMIT WORK AND WAIT .
            ZO_RESULT    = GC_00."NUMBER 00
            ZO_MESSAGE = '업체 마감 확정 정보가 등록  되었습니다.'(M15) .
          ENDIF.

        CATCH CX_ROOT INTO DATA(LV_ERROR).
          ZO_MESSAGE = LV_ERROR->GET_TEXT(  ).
          IF ZO_MESSAGE IS INITIAL.
            ZO_MESSAGE = '업체 마감 확정 정보 등록에 실패했습니다.'(E10).
          ENDIF.
          ZO_RESULT    = GC_02. "02
      ENDTRY.
    ENDIF.

  ENDIF.


ENDFUNCTION.
