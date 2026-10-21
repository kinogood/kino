FUNCTION ZGTMM_IF_I_DRLABEL_RCV.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_TAB STRUCTURE  ZGTMMS4007
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_DRLABEL_RCV
*& 프로그램 명 :  OEM 드럼라벨 정보 수신(G-SRM->SAP)
*& 개요   : GSRM 에서 발행된 OEM 드럼라벨 정보를 수신 저장하는 FUNCTION 개발
*& 생성일 : 2026.03.16
*& 생성자 : ZGODEV07
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

  "초기화
  CLEAR:
    ZO_RESULT,
    ZO_MESSAGE.

*1) 전송 정보 누락 여부 확인
*	1-1) Import Parameter 중 전송 정보가 없는 경우 다음 값 Return 후 종료
*   Export Parameter                      Value
*   ZO_RESULT                     "02"
*   ZO_MESSAGE                      "필수 값이 누락되었습니다."

  IF I_SYSTEM_ID IS INITIAL OR I_BUKRS IS INITIAL OR IT_TAB[] IS INITIAL.
    ZO_RESULT = GC_02.
    ZO_MESSAGE = TEXT-E01.
    EXIT.
  ENDIF.


*2) 전송 정보 저장(Log 등록)
*
*	2-1) TIMESTAMP
*        LV_TIMESTAMP TYPE TIMESTAMPL.
*        GET TIME STAMP FIELD LV_TIMESTAMP
  DATA:
    LS_LOG        TYPE ZGTMMT9000,
    LT_ZGTMMT9415 TYPE STANDARD TABLE OF ZGTMMT9415.


  GET TIME STAMP FIELD LS_LOG-ZIFKEY.
  LS_LOG-ZIFNO = GC_MM00030.
  LS_LOG-SYSTEM_ID = I_SYSTEM_ID.
  LS_LOG-ZSTAT = GC_S.
  LS_LOG-IFDAT = SY-DATLO.
  LS_LOG-IFTIM = SY-TIMLO.
  LS_LOG-IFNAM = SY-UNAME.
  LS_LOG-ERDAT = SY-DATUM.
  LS_LOG-ERDAT_LOCAL = SY-DATLO.
  LS_LOG-ERTIM = SY-UZEIT.
  LS_LOG-ERTIM_LOCAL = SY-TIMLO.
  LS_LOG-ERNAM = SY-UNAME.

  LT_ZGTMMT9415[] = VALUE #( FOR <LS_TAB> IN IT_TAB
                       ( VALUE #( BASE CORRESPONDING #( <LS_TAB> )
                                  ZIFKEY  = LS_LOG-ZIFKEY
                                  SYSTEM_ID = LS_LOG-SYSTEM_ID ) ) ).

  LOOP AT LT_ZGTMMT9415 ASSIGNING FIELD-SYMBOL(<LS_ZGTMMT9415>).
    <LS_ZGTMMT9415>-EBELN = |{ <LS_ZGTMMT9415>-EBELN ALPHA = IN }|.
    <LS_ZGTMMT9415>-EBELP = |{ <LS_ZGTMMT9415>-EBELP ALPHA = IN }|.

    TRANSLATE: <LS_ZGTMMT9415>-ERFME TO UPPER CASE.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        INPUT  = <LS_ZGTMMT9415>-ERFME
      IMPORTING
        OUTPUT = <LS_ZGTMMT9415>-ERFME.

  ENDLOOP.

  MODIFY ZGTMMT9415 FROM TABLE LT_ZGTMMT9415.
  MODIFY ZGTMMT9000 FROM LS_LOG.
  COMMIT WORK.

  ZO_RESULT = GC_00.
  ZO_MESSAGE = TEXT-M23."라벨정보 수신 완료하였습니다."

ENDFUNCTION.
