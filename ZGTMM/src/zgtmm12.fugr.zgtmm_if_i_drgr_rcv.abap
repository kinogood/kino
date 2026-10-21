FUNCTION ZGTMM_IF_I_DRGR_RCV.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET OPTIONAL
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"     VALUE(MBLNR) TYPE  MBLNR
*"     VALUE(MJAHR) TYPE  MJAHR
*"     VALUE(ZTYPE) TYPE  BAPI_MTYPE
*"     VALUE(ZMESSAGE) TYPE  BAPI_MSG
*"  TABLES
*"      IT_TAB STRUCTURE  ZGTMMS4012 OPTIONAL
*"      IT_TAB2 STRUCTURE  ZGTMMS4014 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_DRGR_RCV
*& 프로그램 명 :  MES OEM 드럼라벨 입고 처리 정보 수신(MES>SAP)
*& 개요   : MES 입고 처리 정보수신 및 입고 처리 실행 후 결과를 리턴하는 FUNCTION 개발
*& 생성일 : 2026.04.06
*& 생성자 : ZGODEV07
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : MES-> EAI -> SAP
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  : 2026.07.01
*& 수정자  : ZGODEV04
*& 수정개요: 입고처리유형 판단을 위한 재고 정보 사전 점검 로직 추가
*& 수정일  : 2026.08.06
*& 수정자  : ZGODEV04
*& 수정개요: 1.납품문서 이력 정보 점검 로직 추가 및 입고처리 프로세스 수정
*                2.ZGTMMT9410-DELTYPE=A 일때 재고 이전 처리 대상->재고이전 (311) BAPI수행
*&---------------------------------------------------------------------*

  "초기화
  CLEAR:
    ZO_RESULT,
    ZO_MESSAGE,
    MBLNR,
    MJAHR,
    ZTYPE,
    ZMESSAGE.

  DATA:
    LT_TAB        TYPE STANDARD TABLE OF ZGTMMS4012,
    LS_TAB2     TYPE  ZGTMMS4014,
    LT_TAB2       TYPE STANDARD TABLE OF ZGTMMS4014,
    LS_LOG        TYPE ZGTMMT9000,
    LT_LOG_DATA   TYPE STANDARD TABLE OF ZGTMMT9422,
    LT_LOG_DATA_N TYPE STANDARD TABLE OF TY_ZGTMMT9422,
    LT_LOG_DOC    TYPE STANDARD TABLE OF ZGTMMT9423.

  DATA:
    LV_CHECK      TYPE C LENGTH 1,
    LT_RESB       TYPE TY_T_PO_RESB_POGR_RCV,
    LT_DISPO      TYPE TY_T_PO_DISPO_POGR_RCV,
    LT_MSLB       TYPE TY_T_MSLB_POGR_RCV,
    LT_PO         TYPE TY_T_PO_DRGR_RCV,
    LT_ZGTMMT9450 TYPE TY_T_ZGTMMT9450.

  "bapi 사용
  DATA:
    LS_HEADER TYPE BAPI2017_GM_HEAD_01,
    LS_CODE   TYPE BAPI2017_GM_CODE,
    LT_ITEM   TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
    LT_RETURN TYPE STANDARD TABLE OF BAPIRET2,
    LS_HDRET  TYPE BAPI2017_GM_HEAD_RET,
    LS_0001 TYPE ZPPT0001,
    LV_ITEMTXT TYPE	BAPI2017_GM_ITEM_CREATE-ITEM_TEXT.

  "입력 값
  LT_TAB[] = IT_TAB[].
*>S.2026.08.06_IT_TAB2 납품문서 정보 수신 테이블 추가.
  LT_TAB2[] = IT_TAB2[].
  SORT LT_TAB2 BY DR_LABELNO EBELN EBELP.
*<E.2026.08.06_ZGODEV04.

  "입력 값 점검
  PERFORM F_CHECK_INPUT_VALUES_DRGR_RCV USING I_SYSTEM_ID LT_TAB LT_TAB2
                              CHANGING ZO_RESULT ZO_MESSAGE.

  "오류가 없으면 진행
  CHECK ZO_RESULT NE GC_02.

  "로그 설정
  CLEAR LS_LOG.
  GET TIME STAMP FIELD LS_LOG-ZIFKEY. "I/F KEY 최초 1회 채번으로 변경
  LS_LOG-ZIFNO       = GC_MM00035.
  LS_LOG-SYSTEM_ID   = I_SYSTEM_ID.
  LS_LOG-IFDAT       = SY-DATLO.
  LS_LOG-IFTIM       = SY-TIMLO.
  LS_LOG-IFNAM       = SY-UNAME.

  "Conversion Exit
  PERFORM F_CONV_EXIT_IN_DRGR_RCV CHANGING LT_TAB.

  "PO기준 MRP 관리자 조회
  PERFORM F_GET_PO_DISPO_DRGR_RCV USING LT_TAB CHANGING LT_DISPO.

*S.2026.08.06 IT_TAB2추가에 따른 납품서 유형 별 입고 프로세스 분기 로직 추가
*기존 로직 주석->새 루틴으로 변경.
**OEM마이그레이션 라벨정보이고, 보관품 재고 체크 후 해당하는 경우, 별도 로직으로 수행
  DATA LV_CHK.
*  PERFORM F_GET_STOCK_DRGR_RCV USING LT_DISPO LT_TAB2
*                                                   CHANGING LT_TAB LS_LOG ZO_RESULT ZO_MESSAGE
*                                                                   MBLNR MJAHR ZTYPE ZMESSAGE LV_CHK.
  PERFORM F_GET_STOCK_DRGR_RCV2 USING LT_DISPO
                                                      CHANGING LT_TAB LT_TAB2 LS_LOG ZO_RESULT ZO_MESSAGE
                                                                       MBLNR MJAHR ZTYPE ZMESSAGE LV_CHK.
*E.2026.08.06_ZGODEV04

*자재이전 처리 안되었으면 기존 구매입고 진행
  CHECK LV_CHK IS INITIAL.

  "외주임가공 투입정보 관리 이력
  PERFORM F_GET_ZGTMMT9450_DRGR_RCV USING LT_TAB CHANGING LT_ZGTMMT9450.

  "외주 임가공 PO 예약데이터 조회
  PERFORM F_GET_PO_RESB_DRGR_RCV USING LT_TAB CHANGING LT_RESB.

  "단일배치관리/재고 조회
  PERFORM F_GET_MSLB_DRGR_RCV USING LT_RESB CHANGING LT_MSLB.

  "PO기준 MRP 관리자 조회
  PERFORM F_GET_PO_DISPO_DRGR_RCV USING LT_TAB CHANGING LT_DISPO.

  "PO 재고유형 조회
  ##ITAB_KEY_IN_SELECT
  SELECT
    EP~EBELN,
    EP~EBELP,
    EP~INSMK
    FROM EKPO AS EP
    WHERE EXISTS (
      SELECT @ABAP_TRUE
        FROM @LT_TAB AS ZZ
        WHERE ZZ~EBELN EQ EP~EBELN
          AND ZZ~EBELP EQ EP~EBELP
    )
    ORDER BY EP~EBELN, EP~EBELP
    INTO TABLE @LT_PO.

*배치자재 조장정보 조회.
  DATA : LT_VC TYPE TY_T_BATCH_VC_VALUE.
  ##ITAB_KEY_IN_SELECT
  SELECT MC~MATNR, MC~WERKS, MC~DPCBT,
               VC~PDOC AS EBELN,
               VC~PDOCITEM AS EBELP,
               VC~LENGTH
    FROM MARC AS MC
    INNER JOIN ZGTMM_CV_PO_VCVALUE_MAIN AS VC
    ON MC~MATNR EQ VC~MATNR
    WHERE EXISTS (
        SELECT @ABAP_TRUE
           FROM @LT_TAB AS ZZ
           WHERE ZZ~MATNR EQ MC~MATNR
                AND ZZ~WERKS EQ MC~WERKS
                AND ZZ~EBELN EQ VC~PDOC
                AND ZZ~EBELP EQ VC~PDOCITEM
               )
    AND MC~DPCBT = 'A'
    INTO CORRESPONDING FIELDS OF TABLE @LT_VC.

*S.LT_TAB2 테이블 존재 시, 조장 정보 추가 조회
  IF LT_TAB2 IS NOT INITIAL.
##ITAB_KEY_IN_SELECT
    SELECT VC~PDOC AS EBELN,
                 VC~PDOCITEM AS EBELP,
                 MC~MATNR, MC~WERKS, MC~DPCBT,
                 VC~LENGTH
      FROM MARC AS MC
      INNER JOIN ZGTMM_CV_PO_VCVALUE_MAIN AS VC
      ON MC~MATNR EQ VC~MATNR
      WHERE EXISTS (
        SELECT @ABAP_TRUE
           FROM @LT_TAB2 AS ZZ
           WHERE ZZ~MATNR EQ MC~MATNR
                AND ZZ~WERKS EQ MC~WERKS
                AND ZZ~EBELN EQ VC~PDOC
                AND ZZ~EBELP EQ VC~PDOCITEM
               )
      AND MC~DPCBT = 'A'
      APPENDING TABLE @LT_VC.
  ENDIF.
*E.2026.08.06_ZGODEV04.

  "구매문서 품목 범주 별 실행
  SORT LT_TAB BY PSTYP BUDAT EBELN EBELP DR_LABELNO TAGNR.
  LOOP AT LT_TAB ASSIGNING FIELD-SYMBOL(<LS_G1>) GROUP BY ( PSTYP = <LS_G1>-PSTYP )
                                                                                      ASSIGNING FIELD-SYMBOL(<LS_GROUP1>).

    "전기일이 다르면 새로 채번
    LOOP AT GROUP <LS_GROUP1> ASSIGNING FIELD-SYMBOL(<LS_G2>) GROUP BY ( BUDAT = <LS_G2>-BUDAT )
                                                                                               ASSIGNING FIELD-SYMBOL(<LS_GROUP2>).

      "PO 번호가 다르면 새로 채번
      LOOP AT GROUP <LS_GROUP2> ASSIGNING FIELD-SYMBOL(<LS_G3>) GROUP BY ( EBELN = <LS_G3>-EBELN )
                                                                                          ASSIGNING FIELD-SYMBOL(<LS_GROUP3>).

        "초기화
        CLEAR:
          LS_CODE,
          LS_HEADER,
          LT_ITEM[],
          LT_RETURN[],
          LS_HDRET.

        "CODE 설정
        LS_CODE-GM_CODE = GC_01. "입고

        "Header 설정
        PERFORM F_SET_GOODSMVT_HEADER_DRGR_RCV USING <LS_GROUP1>-PSTYP
                                                                                      <LS_GROUP2>-BUDAT
                                                                                      CHANGING LS_HEADER.

        "<--2026.07.12 로그 데이터 1차 저장
        "로그 데이터 생성
        CLEAR LT_LOG_DATA_N[]."LT_LOG_DATA[].
        LOOP AT GROUP <LS_GROUP3> ASSIGNING FIELD-SYMBOL(<LS_TAB>).
          APPEND VALUE #(
                                     BASE CORRESPONDING #( <LS_TAB> )
                                     DR_LABEL_NO = <LS_TAB>-DR_LABELNO
                                   ) TO LT_LOG_DATA_N. "LT_LOG_DATA.
        ENDLOOP.
*    4-4) 처리 결과 Log 저장 및 RETURN
        PERFORM F_SAVE_LOG_DRGR_RCV USING LS_LOG LT_LOG_DATA_N LS_HDRET LT_TAB2.
        "-->2026.07.12 로그 데이터 1차 저장

        "Item 설정
        CLEAR LV_CHECK.

        LOOP AT GROUP <LS_GROUP3> ASSIGNING <LS_TAB>.

*>S.2026.08.06_수신된 납품문서 있으면(IT_TAB2),
          READ TABLE LT_TAB2 ASSIGNING FIELD-SYMBOL(<TAB>)
          WITH KEY DR_LABELNO = <LS_TAB>-DR_LABELNO
                                   EBELN = <LS_TAB>-EBELN
                                   EBELP = <LS_TAB>-EBELP BINARY SEARCH.
          IF SY-SUBRC = 0.
            CLEAR : LS_HEADER-REF_DOC_NO, LV_ITEMTXT.
*1)해당 납품문서 번호로 참조문서 설정.
            LS_HEADER-REF_DOC_NO = <TAB>-DELNO.
*2)BAPI ITEM TEXT->납품문서-품목 조합으로 설정.
            LV_ITEMTXT = <TAB>-DELNO && '-' && <TAB>-DELITEM.
          ENDIF.
*>E.2026.08.06_ZGODEV04

          PERFORM F_SET_GOODSMVT_ITEM_DRGR_RCV USING  LT_RESB LT_MSLB LT_ZGTMMT9450 LT_PO LT_VC LV_ITEMTXT
                CHANGING <LS_TAB> LT_ITEM LV_CHECK.

          IF LV_CHECK EQ GC_E.
            EXIT.
          ENDIF.
        ENDLOOP.

        IF LV_CHECK EQ GC_E.
          LT_RETURN = VALUE #( ( TYPE = GC_E MESSAGE = TEXT-E02 ) ). "투입 자재 정보를 확인하세요.
        ELSE.
          "bapi실행
          CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
            EXPORTING
              GOODSMVT_HEADER  = LS_HEADER
              GOODSMVT_CODE    = LS_CODE
            IMPORTING
              GOODSMVT_HEADRET = LS_HDRET
            TABLES
              GOODSMVT_ITEM    = LT_ITEM
              RETURN           = LT_RETURN.
        ENDIF.

        READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_RETURN>) WITH KEY TYPE = GC_E.
        IF SY-SUBRC EQ 0.
          "오류
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          LS_LOG-ZSTAT = GC_E.
          LS_LOG-MESSAGE = <LS_RETURN>-MESSAGE.

          ZO_RESULT = GC_02.
          ZO_MESSAGE = TEXT-M02.""입고처리 실패"
          MBLNR = SPACE.
          MJAHR = SPACE.
          ZTYPE = GC_E.
          ZMESSAGE = <LS_RETURN>-MESSAGE.

        ELSE.
          "성공
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              WAIT = ABAP_TRUE.

          LS_LOG-ZSTAT = GC_S.
          LS_LOG-MESSAGE = SPACE.

          ZO_RESULT = GC_00.
          ZO_MESSAGE = TEXT-M01."입고처리 성공"
          MBLNR = LS_HDRET-MAT_DOC.
          MJAHR = LS_HDRET-DOC_YEAR.
          ZTYPE = GC_S.
          ZMESSAGE = SPACE.
*>S.입고처리 성공 후 배치특성 업데이트 로직 추가
          PERFORM F_UPDATE_CLASS_BATCH_DRGR USING <LS_TAB> .
*<E.2026.08.06_ZGODEV04
        ENDIF.

        "로그 데이터 생성
        CLEAR LT_LOG_DATA_N[]."LT_LOG_DATA[].
        LOOP AT GROUP <LS_GROUP3> ASSIGNING <LS_TAB>.
          APPEND VALUE #(
                                     BASE CORRESPONDING #( <LS_TAB> )
                                     DR_LABEL_NO = <LS_TAB>-DR_LABELNO
                                   ) TO LT_LOG_DATA_N. "LT_LOG_DATA.
        ENDLOOP.

*    4-4) 처리 결과 Log 저장 및 RETURN
        PERFORM F_SAVE_LOG_DRGR_RCV USING LS_LOG LT_LOG_DATA_N LS_HDRET LT_TAB2.

        "C) 꼬리표 번호 정보 테이블
*: 생성된 자재문서, 품목 내 배치번호(CHARG) 가 존재하면 ZPPT0001 테이블 테이터 저장 -> LT_ITEM에 배치 번호 존재시 저장
        IF LS_LOG-ZSTAT EQ GC_S.
*>S.2026.08.06_동일한 WERKS/TAGNR 번호가 존재하면 기존 ZPPT0001 UPDATE
          CLEAR LS_0001.
          SELECT SINGLE *
            FROM ZPPT0001
            WHERE WERKS EQ @<LS_TAB>-WERKS
            AND TAGNR EQ @<LS_TAB>-TAGNR
            INTO @LS_0001.

          PERFORM F_SAVE_ZPPT0001_DRGR_RCV USING LT_LOG_DATA_N LS_HDRET LT_DISPO LV_CHK LS_0001 LT_ITEM.
        ENDIF.
*E.2026.08.06_ZGODEV04.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.


ENDFUNCTION.
