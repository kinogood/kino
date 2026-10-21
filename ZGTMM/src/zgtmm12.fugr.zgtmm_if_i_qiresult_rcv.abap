FUNCTION ZGTMM_IF_I_QIRESULT_RCV.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_TAB STRUCTURE  ZGTMMS0009 OPTIONAL
*"      OT_TAB STRUCTURE  ZGTMMS0010 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_QIRESULT_RCV
*& 프로그램 명 :  MES 수입 검사 결과 수신(MES-SAP)
*& 개요   : 품질 검사 대상 자재에 대해 품질 검사 후 합격 정보를 MES 로부터 수신 재고 상태
*             변경 처리하는(품질재고->가용재고) FUNCTION 개발
*& 생성일 : 2026.03.18
*& 생성자 : ZGODEV07
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : MES-> EAI -> SAP
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  : 2026.08.05
*& 수정자  : ZGODEV04
*& 수정개요: BAPI 전/후 배치 클래스 속성 업데이트 수행 로직 추가(FACTOR BATCH)
*&---------------------------------------------------------------------*

  DATA:
    LV_CNT_S TYPE INT4,
    LV_CNT_E TYPE INT4.

*1) 전송 정보 저장(1차 Log 등록)
*	1-1) TIMESTAMP
*        LV_TIMESTAMP TYPE TIMESTAMPL.
*        GET TIME STAMP FIELD LV_TIMESTAMP
*
*	1-2) 1차 수신 로그 Internal Table 저장
*   LT_ZGTMMT9000                   Value
*   ZIFNO                   "MM00037"
*   ZIFKEY                    LV_TIMESTAMP
*   SYSTEM_ID                   I_SYSTEM_ID
*   ZSTAT
*   MESSAGE
*   IFDAT                   SY-DATUM
*   IFTIM                   SY-UZEIT
*   IFNAM                   SY-UNAME
*   ERDAT
*   ERDAT_LOCAL
*   ERTIM
*   ERTIM_LOCAL
*   ERNAM
*
*   LT_ZGTMMT9440                   Value
*   ZIFKEY                    LV_TIMESTAMP
*   SYSTEM_ID                   I_SYSTEM_ID
*   GROUPCODE                   IT_TAB-GROUPCODE
*   BUDAT                   IT_TAB-BUDAT
*   MATNR                   IT_TAB-MATNR
*   WERKS                   IT_TAB-WERKS
*   LGORT                   IT_TAB-LGORT
*   ERFMG                   IT_TAB-ERFMG
*   ERFME                   IT_TAB-ERFME
*   CHARG                   IT_TAB-CHARGE
*   SOBKZ                   IT_TAB-SOBKZ
*   VBELN                   IT_TAB-VBELN
*   POSNR                   IT_TAB-POSNR
*
*	1-3) Log Table 1차 저장
*     ZTGMMMT9000, ZGTMMT9440

  DATA:
    LS_LOG        TYPE ZGTMMT9000,
    LT_ZGTMMT9440 TYPE STANDARD TABLE OF ZGTMMT9440,
    LS_ZGTMMT9441 TYPE ZGTMMT9441,
    LT_ZGTMMT9441 TYPE STANDARD TABLE OF ZGTMMT9441.

  CLEAR LS_LOG.
  GET TIME STAMP FIELD LS_LOG-ZIFKEY.
  LS_LOG-ZIFNO = GC_MM00037.
  LS_LOG-SYSTEM_ID = I_SYSTEM_ID.
  LS_LOG-IFDAT = SY-DATLO.
  LS_LOG-IFTIM = SY-TIMLO.
  LS_LOG-IFNAM = SY-UNAME.

  LT_ZGTMMT9440[] = CORRESPONDING #( IT_TAB[] ).

  LOOP AT LT_ZGTMMT9440 ASSIGNING FIELD-SYMBOL(<LS_ZGTMMT9440>).
    <LS_ZGTMMT9440>-ZIFKEY = LS_LOG-ZIFKEY.
    <LS_ZGTMMT9440>-VBELN = |{ <LS_ZGTMMT9440>-VBELN ALPHA = IN }|.
    <LS_ZGTMMT9440>-POSNR = |{ <LS_ZGTMMT9440>-POSNR ALPHA = IN }|.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT  = <LS_ZGTMMT9440>-MATNR
      IMPORTING
        OUTPUT = <LS_ZGTMMT9440>-MATNR.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        INPUT  = <LS_ZGTMMT9440>-ERFME
      IMPORTING
        OUTPUT = <LS_ZGTMMT9440>-ERFME.

  ENDLOOP.

*  MODIFY ZGTMMT9000 FROM LS_LOG.
*  MODIFY ZGTMMT9440 FROM TABLE LT_ZGTMMT9440.
*  COMMIT WORK.

*2) 자재 이전전기를 위한 Data 설정
*
*    - BAPI HEADER 설정
*
*     BAPI 필드                 VALUE
*     PSTING_DATE                 I_TAB-BUDAT
*     DOC_DATE                  I_TAB-BUDAT
*
*   - GM Code 설정
*     BAPI 필드                 VALUE
*     GM_CODE                 '04'
*
*    - BAPI ITEM 설정
*     BAPI 필드                 VALUE
*     MOVE_TYPE                 '321'
*     MATERIAL                  IT_TAB-MATNR
*     PLANT                 IT_TAB-PLANT
*     STGE_LOC                  IT_TAB-LGORT
*     ENTRY_QNT                 IT_TAB-ERFMG
*     ENTRY_UOM                 IT_TAB-ERFME
*     BATCH                 IT_TAB-CHARG
*     SPEC_STOCK                  IT_TAB-SOBKZ
*     VAL_SALES_ORD                 IT_TAB-VBELN
*     VAL_SO_ITEM                 IT_TAB-POSNR
*
*3) BAPI_GOODSMVT_CREATE 호출 자재 이전전기 수행
*	3-1) RETURN-TYPE= E 인 데이터가 없으면 성공 처리
*   A) BAPI_TRANSACTION_COMMIT
*	3-2) RETUNR-TYPE = E 인 데이터가 존재하면 오류로 처리
*   B) BAPI_TRANSACTION_ROLLBACK

  DATA:
    LS_HEADER TYPE BAPI2017_GM_HEAD_01,
    LT_ITEM   TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
    LT_RETURN TYPE STANDARD TABLE OF BAPIRET2,
    LS_HDRET  TYPE BAPI2017_GM_HEAD_RET.


  LOOP AT LT_ZGTMMT9440 ASSIGNING <LS_ZGTMMT9440>.
    CLEAR:
      LS_ZGTMMT9441,
      LS_HDRET,
      LS_HEADER,
      LT_ITEM[],
      LT_RETURN[].


    LS_ZGTMMT9441-ZIFKEY = <LS_ZGTMMT9440>-ZIFKEY.
    LS_ZGTMMT9441-SYSTEM_ID = <LS_ZGTMMT9440>-SYSTEM_ID.
    LS_ZGTMMT9441-GROUPCODE = <LS_ZGTMMT9440>-GROUPCODE.

    LS_HEADER-PSTNG_DATE = <LS_ZGTMMT9440>-BUDAT.
    LS_HEADER-DOC_DATE = <LS_ZGTMMT9440>-BUDAT.

    LT_ITEM = VALUE #( (
*      MOVE_TYPE = GC_321
      MOVE_TYPE = <LS_ZGTMMT9440>-BWART
      MATERIAL = <LS_ZGTMMT9440>-MATNR
      PLANT = <LS_ZGTMMT9440>-WERKS
      STGE_LOC = <LS_ZGTMMT9440>-LGORT
      ENTRY_QNT = <LS_ZGTMMT9440>-ERFMG
      ENTRY_UOM = <LS_ZGTMMT9440>-ERFME
      BATCH = <LS_ZGTMMT9440>-CHARG
      SPEC_STOCK = <LS_ZGTMMT9440>-SOBKZ
      VAL_SALES_ORD = <LS_ZGTMMT9440>-VBELN
      VAL_S_ORD_ITEM = <LS_ZGTMMT9440>-POSNR
    ) ).

*>S.Factor Batch인 경우, 배치 클래스 특성정보 업데이트 선 수행 추가
    PERFORM UPDATE_CLASS_BATCH USING <LS_ZGTMMT9440>.
*<E.2026.08.05_ZGODEV04

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

      LT_ZGTMMT9441 = VALUE #( BASE LT_ZGTMMT9441 (
          ZIFKEY = <LS_ZGTMMT9440>-ZIFKEY
          SYSTEM_ID = <LS_ZGTMMT9440>-SYSTEM_ID
          GROUPCODE = <LS_ZGTMMT9440>-GROUPCODE
          ZRESULT = GC_E
          ZMESSAGE = <LS_RETURN>-MESSAGE
    ) ).

      LV_CNT_E += 1.

    ELSE.
      "성공
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.

      LT_ZGTMMT9441 = VALUE #( BASE LT_ZGTMMT9441 (
          ZIFKEY = <LS_ZGTMMT9440>-ZIFKEY
          SYSTEM_ID = <LS_ZGTMMT9440>-SYSTEM_ID
          GROUPCODE = <LS_ZGTMMT9440>-GROUPCODE
          MBLNR = LS_HDRET-MAT_DOC
          MJAHR = LS_HDRET-DOC_YEAR
          ZRESULT = GC_S
          ZMESSAGE = TEXT-M03
    ) ).

      LV_CNT_S += 1.

*>S.Factor Batch인 경우, BAPI성공 후 배치 클래스 특성정보 업데이트 수행 추가
    PERFORM UPDATE_CLASS_BATCH USING <LS_ZGTMMT9440>.
*<E.2026.08.05_ZGODEV04
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
  MODIFY ZGTMMT9441 FROM TABLE LT_ZGTMMT9441.
  MODIFY ZGTMMT9440 FROM TABLE LT_ZGTMMT9440.
  COMMIT WORK.

  OT_TAB[] = CORRESPONDING #( LT_ZGTMMT9441[] ).

  ZO_RESULT = GC_00.
  ZO_MESSAGE = LS_LOG-MESSAGE.

ENDFUNCTION.
