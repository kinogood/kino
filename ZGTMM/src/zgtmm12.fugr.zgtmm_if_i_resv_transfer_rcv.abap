FUNCTION ZGTMM_IF_I_RESV_TRANSFER_RCV.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_TAB STRUCTURE  ZGTMMS0011 OPTIONAL
*"      OT_TAB STRUCTURE  ZGTMMS0010 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_RESV_TRANSFER_RCV
*& 프로그램 명 :  MES 예약오더 이전전기 수신(MES-SAP)
*& 개요   : MES에서 예약오더 정보를 기준으로 물자창고->현장창고 자재 이전전기 정보 수신
*             및 이전처리  FUNCTION 개발
*& 생성일 : 2026.05.04
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

  DATA:
    LV_CNT_S TYPE INT4,
    LV_CNT_E TYPE INT4.

*&---------------------------------------------------------------------*
*& 전송 정보 저장(1차 Log 등록)
*&---------------------------------------------------------------------*
  DATA:
    LS_LOG        TYPE ZGTMMT9000,
    LT_ZGTMMT9464 TYPE STANDARD TABLE OF ZGTMMT9464,
    LS_ZGTMMT9465 TYPE ZGTMMT9465,
    LT_ZGTMMT9465 TYPE STANDARD TABLE OF ZGTMMT9465.

  CLEAR LS_LOG.
  GET TIME STAMP FIELD LS_LOG-ZIFKEY.
  LS_LOG-ZIFNO = GC_MM00056.
  LS_LOG-SYSTEM_ID = I_SYSTEM_ID.
  LS_LOG-IFDAT = SY-DATLO.
  LS_LOG-IFTIM = SY-TIMLO.
  LS_LOG-IFNAM = SY-UNAME.

  LT_ZGTMMT9464[] = CORRESPONDING #( IT_TAB[] ).

  LOOP AT LT_ZGTMMT9464 ASSIGNING FIELD-SYMBOL(<LS_ZGTMMT9464>).
    <LS_ZGTMMT9464>-ZIFKEY = LS_LOG-ZIFKEY.
    <LS_ZGTMMT9464>-SYSTEM_ID = LS_LOG-SYSTEM_ID.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        INPUT  = <LS_ZGTMMT9464>-ERFME
      IMPORTING
        OUTPUT = <LS_ZGTMMT9464>-ERFME.

  ENDLOOP.


*&---------------------------------------------------------------------*
*& 자재 이전전기를 위한 Data 설정
*&---------------------------------------------------------------------*
  DATA:
    LS_HEADER TYPE BAPI2017_GM_HEAD_01,
    LT_ITEM   TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
    LT_RETURN TYPE STANDARD TABLE OF BAPIRET2,
    LS_HDRET  TYPE BAPI2017_GM_HEAD_RET.


  LOOP AT LT_ZGTMMT9464 ASSIGNING <LS_ZGTMMT9464>.
    CLEAR:
      LS_ZGTMMT9465,
      LS_HDRET,
      LS_HEADER,
      LT_ITEM[],
      LT_RETURN[].


    LS_ZGTMMT9465-ZIFKEY = <LS_ZGTMMT9464>-ZIFKEY.
    LS_ZGTMMT9465-SYSTEM_ID = <LS_ZGTMMT9464>-SYSTEM_ID.
    LS_ZGTMMT9465-GROUPCODE = <LS_ZGTMMT9464>-GROUPCODE.

    LS_HEADER-PSTNG_DATE = <LS_ZGTMMT9464>-BUDAT.
    LS_HEADER-DOC_DATE = <LS_ZGTMMT9464>-BUDAT.

* 예약오더 정보 SELECT (RSNUM, RSPOS, 이동유형 기준)
    SELECT SINGLE
      RK~RSNUM,
      RS~RSPOS,
      RK~BWART,
      RS~MATNR,
      RS~WERKS,
      RS~MEINS,
      RS~LGORT,
      RS~UMLGO,
      MC~XCHPF,
      RS~CHARG
      FROM RKPF AS RK
                  INNER JOIN
                RESB AS RS ON RK~RSNUM EQ RS~RSNUM
                  INNER JOIN
                MARC AS MC ON RS~WERKS EQ MC~WERKS
                                   AND RS~MATNR EQ MC~MATNR
      WHERE RK~RSNUM EQ @<LS_ZGTMMT9464>-RSNUM
      AND RS~RSPOS EQ @<LS_ZGTMMT9464>-RSPOS
      AND RK~BWART EQ @GC_311
      INTO @DATA(LS_RSDATA).


* BAPI ITEM 값 할당
    LT_ITEM = VALUE #( (
      MOVE_TYPE = GC_311
      MATERIAL = LS_RSDATA-MATNR
      PLANT = LS_RSDATA-WERKS
      STGE_LOC = LS_RSDATA-LGORT
      MOVE_STLOC = LS_RSDATA-UMLGO
      RESERV_NO = <LS_ZGTMMT9464>-RSNUM
      RES_ITEM = <LS_ZGTMMT9464>-RSPOS
      ENTRY_QNT = <LS_ZGTMMT9464>-ERFMG
      ENTRY_UOM = <LS_ZGTMMT9464>-ERFME
      BATCH = <LS_ZGTMMT9464>-CHARG
      MOVE_BATCH = <LS_ZGTMMT9464>-CHARG
    ) ).

*&---------------------------------------------------------------------*
*& 자재 이전전기
*&---------------------------------------------------------------------*
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = LS_HEADER
        GOODSMVT_CODE    = '04'
      IMPORTING
        GOODSMVT_HEADRET = LS_HDRET
      TABLES
        GOODSMVT_ITEM    = LT_ITEM
        RETURN           = LT_RETURN.

    READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_RETURN>) WITH KEY TYPE = GC_E.
    IF SY-SUBRC EQ 0.
      "오류
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      LT_ZGTMMT9465 = VALUE #( BASE LT_ZGTMMT9465 (
          ZIFKEY = <LS_ZGTMMT9464>-ZIFKEY
          SYSTEM_ID = <LS_ZGTMMT9464>-SYSTEM_ID
          GROUPCODE = <LS_ZGTMMT9464>-GROUPCODE
          ZRESULT = GC_E
          ZMESSAGE = <LS_RETURN>-MESSAGE
    ) ).

      LV_CNT_E += 1.

    ELSE.
      "성공
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.

      LT_ZGTMMT9465 = VALUE #( BASE LT_ZGTMMT9465 (
          ZIFKEY = <LS_ZGTMMT9464>-ZIFKEY
          SYSTEM_ID = <LS_ZGTMMT9464>-SYSTEM_ID
          GROUPCODE = <LS_ZGTMMT9464>-GROUPCODE
          MBLNR = LS_HDRET-MAT_DOC
          MJAHR = LS_HDRET-DOC_YEAR
          ZRESULT = GC_S
          ZMESSAGE = TEXT-M04
    ) ).

      LV_CNT_S += 1.

    ENDIF.
  ENDLOOP.

  DATA(LV_TOT) = LV_CNT_S + LV_CNT_E.
  MESSAGE S073(ZGTMM01) WITH LV_TOT LV_CNT_S LV_CNT_E INTO LS_LOG-MESSAGE.
  LS_LOG-ZSTAT = GC_S.
  LS_LOG-ERDAT = SY-DATUM.
  LS_LOG-ERDAT_LOCAL = SY-DATLO.
  LS_LOG-ERTIM = SY-UZEIT.
  LS_LOG-ERTIM_LOCAL = SY-TIMLO.
  LS_LOG-ERNAM = SY-UNAME.

  MODIFY ZGTMMT9000 FROM LS_LOG.
  MODIFY ZGTMMT9465 FROM TABLE LT_ZGTMMT9465.
  MODIFY ZGTMMT9464 FROM TABLE LT_ZGTMMT9464.
  COMMIT WORK.

  OT_TAB[] = CORRESPONDING #( LT_ZGTMMT9465[] ).

  ZO_RESULT = GC_00.
  ZO_MESSAGE = LS_LOG-MESSAGE.

ENDFUNCTION.
