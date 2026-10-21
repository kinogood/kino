FUNCTION ZGTMM_IF_I_POGR_RCV.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"     VALUE(MBLNR) TYPE  MBLNR
*"     VALUE(MJAHR) TYPE  MJAHR
*"     VALUE(ZTYPE) TYPE  BAPI_MTYPE
*"     VALUE(ZMESSAGE) TYPE  BAPI_MSG
*"  TABLES
*"      IT_TAB STRUCTURE  ZGTMMS4005 OPTIONAL
*"      IT_TAB2 STRUCTURE  ZGTMMS4009 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_POGR_RCV
*& 프로그램 명 :  MES 입고 처리 정보 수신(MES>SAP)
*& 개요   : MES 입고 처리 정보수신 및 입고 처리 실행 후 결과를 리턴
*& 생성일 : 2026.01.30
*& 생성자 : ZGODEV07
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : MES-> EAI -> SAP
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  : 2026.07.22
*& 수정자  : ZGODEV04
*& 수정개요: Factor Batch인 자재의 경우, 배치 클래스 속성 정보 업데이트 로직 추가
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
    LT_TAB       TYPE STANDARD TABLE OF ZGTMMS4005,
    LT_TAB2      TYPE STANDARD TABLE OF ZGTMMS4009,
    LS_LOG       TYPE ZGTMMT9000,
    LT_LOG_DATA  TYPE STANDARD TABLE OF ZGTMMT9420,
    LT_LOG_DATA2 TYPE STANDARD TABLE OF ZGTMMT9424,
    LT_LOG_9420  TYPE TY_T_ZGTMMT9420,
    LT_LOG_9424  TYPE TY_T_ZGTMMT9424.


  DATA:
    LV_CHECK      TYPE C LENGTH 1,
    LV_BATCH      TYPE CHARG_D,
    LV_DPCBT      TYPE MARC-DPCBT,
    LT_RESB       TYPE TY_T_PO_RESB_POGR_RCV,
    LT_DELCOMP    TYPE TY_T_PO_DELCOMP_POGR_RCV,
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
    LS_HDRET  TYPE BAPI2017_GM_HEAD_RET.

  "입력 값
  LT_TAB[] = IT_TAB[].
  LT_TAB2[] = IT_TAB2[].

  IF LT_TAB[] IS NOT INITIAL OR LT_TAB2[] IS NOT INITIAL.
    "Conversion Exit
    PERFORM F_CONV_EXIT_IN_POGR_RCV CHANGING LT_TAB LT_TAB2.
    "입력 값 점검
    PERFORM F_CHECK_INPUT_VALUES_POGR_RCV USING I_SYSTEM_ID LT_TAB LT_TAB2
          CHANGING ZO_RESULT ZO_MESSAGE.
  ENDIF.

  "오류가 없으면 진행
  CHECK ZO_RESULT NE GC_02.

  "로그 설정
  CLEAR LS_LOG.
  GET TIME STAMP FIELD LS_LOG-ZIFKEY.
  LS_LOG-ZIFNO       = GC_MM00061.
  LS_LOG-SYSTEM_ID   = I_SYSTEM_ID.
  LS_LOG-IFDAT       = SY-DATLO.
  LS_LOG-IFTIM       = SY-TIMLO.
  LS_LOG-IFNAM       = SY-UNAME.

  "공통코드 마스터 조회
  SELECT FROM ZGTPPT1010
    FIELDS *
    WHERE MODULE_KIND = @GC_MM
         AND CODEGRP = @GC_0830
    INTO TABLE @GT_ZGTPPT1010.
  SORT GT_ZGTPPT1010 BY FLD_01 FLD_02.

  "납품문서 Component 조회
  PERFORM F_GET_PO_DELCOMP_POGR_RCV USING LT_TAB CHANGING LT_DELCOMP.
  PERFORM F_GET_PO_DELCOMP_POGR_RCV2 USING LT_TAB2 CHANGING LT_DELCOMP.

  "PO기준 MRP 관리자 조회
  PERFORM F_GET_PO_DISPO_POGR_RCV USING LT_TAB CHANGING LT_DISPO.
  PERFORM F_GET_PO_DISPO_POGR_RCV2 USING LT_TAB2 CHANGING LT_DISPO.

  "외주 임가공 PO 예약데이터 조회
  PERFORM F_GET_PO_RESB_POGR_RCV USING LT_TAB CHANGING LT_RESB.
  PERFORM F_GET_PO_RESB_POGR_RCV2 USING LT_TAB2 CHANGING LT_RESB.

  "단일배치관리/재고 조회
  PERFORM F_GET_MSLB_POGR_RCV USING LT_RESB LT_DELCOMP CHANGING LT_MSLB.

  "3-2-4-2) 외주임가공 투입정보 관리 이력 테이블 정보 점검(ISSUE_COMP)
  PERFORM F_GET_ZGTMMT9450_POGR_RCV USING LT_TAB CHANGING LT_ZGTMMT9450.
  PERFORM F_GET_ZGTMMT9450_POGR_RCV2 USING LT_TAB2 CHANGING LT_ZGTMMT9450.

  "C) 배치자재인 경우(MARC-XCHPF=X) 배치마스터 제조일자 업데이트
  ##ITAB_KEY_IN_SELECT
  SELECT
    MC~MATNR,
    MC~WERKS,
    MC~DPCBT
    FROM MARC AS MC
    WHERE EXISTS (
      SELECT @ABAP_TRUE
        FROM @LT_TAB AS ZZ
        WHERE ZZ~WERKS EQ MC~WERKS
          AND ZZ~MATNR EQ MC~MATNR
    )
    AND MC~XCHPF EQ @ABAP_TRUE
    ORDER BY MC~MATNR, MC~WERKS
    INTO TABLE @DATA(LT_XCHPF).

  IF LT_TAB2 IS NOT INITIAL.
    ##ITAB_KEY_IN_SELECT
    SELECT
      MC~MATNR,
      MC~WERKS,
      MC~DPCBT
      FROM MARC AS MC
      WHERE EXISTS (
        SELECT @ABAP_TRUE
          FROM @LT_TAB2 AS ZZ
          WHERE ZZ~WERKS EQ MC~WERKS
            AND ZZ~MATNR EQ MC~MATNR
      )
      AND MC~XCHPF EQ @ABAP_TRUE
      ORDER BY MC~MATNR, MC~WERKS
      APPENDING TABLE @LT_XCHPF.
  ENDIF.

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

  IF LT_TAB2 IS NOT INITIAL.
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
             FROM @LT_TAB2 AS ZZ
             WHERE ZZ~MATNR EQ MC~MATNR
                  AND ZZ~WERKS EQ MC~WERKS
                  AND ZZ~EBELN EQ VC~PDOC
                  AND ZZ~EBELP EQ VC~PDOCITEM
                 )
      AND MC~DPCBT = 'A'
      APPENDING CORRESPONDING FIELDS OF TABLE @LT_VC.
  ENDIF.

  SORT LT_VC BY EBELN EBELP .

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

  IF LT_TAB2 IS NOT INITIAL.
    ##ITAB_KEY_IN_SELECT
    SELECT
      EP~EBELN,
      EP~EBELP,
      EP~INSMK
      FROM EKPO AS EP
      WHERE EXISTS (
        SELECT @ABAP_TRUE
          FROM @LT_TAB2 AS ZZ
          WHERE ZZ~EBELN EQ EP~EBELN
            AND ZZ~EBELP EQ EP~EBELP
      )
      ORDER BY EP~EBELN, EP~EBELP
      APPENDING TABLE @LT_PO.
  ENDIF.


****IT_TAB_표준거래명세서(납품번호입고) 입고처리
  "구매문서 품목 범주 별 입고 처리 실행
  SORT LT_TAB BY PSTYP BUDAT DELNO DELITEM EBELN EBELP DELNO DELITEM TAGNR.
  GT_TAB[] = LT_TAB[].
  LOOP AT LT_TAB ASSIGNING FIELD-SYMBOL(<LS_G1>) GROUP BY ( PSTYP = <LS_G1>-PSTYP )
                                                                                      ASSIGNING FIELD-SYMBOL(<LS_GROUP1>).


    "전기일이 다르면 새로 채번
    LOOP AT GROUP <LS_GROUP1> ASSIGNING FIELD-SYMBOL(<LS_G2>) GROUP BY ( BUDAT = <LS_G2>-BUDAT )
                                                                                               ASSIGNING FIELD-SYMBOL(<LS_GROUP2>).

      "납품문서 번호가 다르면 새로 채번
      LOOP AT GROUP <LS_GROUP2> ASSIGNING FIELD-SYMBOL(<LS_G3>) GROUP BY ( DELNO = <LS_G3>-DELNO )
                                                                                            ASSIGNING FIELD-SYMBOL(<LS_GROUP3>).


        "PO 번호가 다르면 새로 채번
        LOOP AT GROUP <LS_GROUP3> ASSIGNING FIELD-SYMBOL(<LS_G4>) GROUP BY ( EBELN = <LS_G4>-EBELN )
                                                                                            ASSIGNING FIELD-SYMBOL(<LS_GROUP4>).

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
          PERFORM F_SET_GOODSMVT_HEADER_POGR_RCV USING <LS_GROUP1>-PSTYP
                                                                                        <LS_GROUP2>-BUDAT
                                                                                        <LS_GROUP3>-DELNO
                                                                                        CHANGING LS_HEADER.

          "<--2026.07.12 로그 데이터 1차 저장
          "로그 데이터 생성
          CLEAR : LT_LOG_DATA[], LT_LOG_DATA2[], LT_LOG_9420[], LT_LOG_9424[] .
          LOOP AT GROUP <LS_GROUP4> ASSIGNING FIELD-SYMBOL(<LS_TAB>).
*            LT_LOG_DATA[] = VALUE #( BASE LT_LOG_DATA ( CORRESPONDING #( <LS_TAB> ) ) ).
            LT_LOG_9420[] = VALUE #( BASE LT_LOG_9420 ( CORRESPONDING #( <LS_TAB> ) ) ).
          ENDLOOP.

*    4-4) 처리 결과 Log 저장 및 RETURN
*          PERFORM F_SAVE_LOG_POGR_RCV USING LT_LOG_DATA LS_HDRET CHANGING LS_LOG.
          PERFORM F_SAVE_LOG_POGR_RCV USING LT_LOG_9420 LS_HDRET CHANGING LS_LOG.
          "-->2026.07.12 로그 데이터 1차 저장

          "Item 설정
          CLEAR LV_CHECK.

          LOOP AT GROUP <LS_GROUP4> ASSIGNING <LS_TAB>.
*>S.26.07.29_배치특성 업데이트 선행 위한 DPCBT 정보 확인
            CLEAR LV_DPCBT.
            READ TABLE LT_XCHPF ASSIGNING FIELD-SYMBOL(<XC>)
            WITH KEY MATNR = <LS_TAB>-MATNR BINARY SEARCH.
            IF SY-SUBRC = 0.
              LV_DPCBT = <XC>-DPCBT.
            ENDIF.
*<E.26.07.29_ZGODEV04.

            PERFORM F_SET_GOODSMVT_ITEM_POGR_RCV USING LT_RESB LT_DELCOMP LT_MSLB LT_ZGTMMT9450
                  LT_PO LT_VC LV_DPCBT
                  CHANGING LT_ITEM <LS_TAB> LV_CHECK .

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


            "C) 배치자재인 경우(MARC-XCHPF=X) 배치마스터 제조일자 업데이트
            LOOP AT GROUP <LS_GROUP4> ASSIGNING <LS_TAB>.
              READ TABLE LT_XCHPF WITH KEY MATNR = <LS_TAB>-MATNR WERKS = <LS_TAB>-WERKS BINARY SEARCH TRANSPORTING NO FIELDS.
              CHECK SY-SUBRC EQ 0.
              PERFORM F_BATCH_CHANGE_POGR_RCV USING MBLNR LT_VC CHANGING <LS_TAB>.
            ENDLOOP.


          ENDIF.

          "로그 데이터 생성
          CLEAR : LT_LOG_DATA[], LT_LOG_DATA2[], LT_LOG_9420[], LT_LOG_9424[] .
          LOOP AT GROUP <LS_GROUP4> ASSIGNING <LS_TAB>.
*            LT_LOG_DATA[] = VALUE #( BASE LT_LOG_DATA ( CORRESPONDING #( <LS_TAB> ) ) ).
            LT_LOG_9420[] = VALUE #( BASE LT_LOG_9420 ( CORRESPONDING #( <LS_TAB> ) ) ).
          ENDLOOP.

*    4-4) 처리 결과 Log 저장 및 RETURN
*          PERFORM F_SAVE_LOG_POGR_RCV USING LT_LOG_DATA LS_HDRET CHANGING LS_LOG.
          PERFORM F_SAVE_LOG_POGR_RCV USING LT_LOG_9420 LS_HDRET CHANGING LS_LOG.

          "C) 꼬리표 번호 정보 테이블
*: 생성된 자재문서, 품목 내 배치번호(CHARG) 가 존재하면 ZPPT0001 테이블 테이터 저장
          IF LS_LOG-ZSTAT EQ GC_S.
*            PERFORM F_SAVE_ZPPT0001_POGR_RCV USING LT_LOG_DATA LS_HDRET LT_DISPO.
            PERFORM F_SAVE_ZPPT0001_POGR_RCV USING LT_LOG_9420 LS_HDRET LT_DISPO.
          ENDIF.

        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

****IT_TAB2_수기거래명세서(PO입고) 입고처리
*  "구매문서 품목 범주 별 입고 처리 실행
  SORT LT_TAB2 BY PSTYP BUDAT EBELN EBELP TAGNR.
  LOOP AT LT_TAB2 ASSIGNING FIELD-SYMBOL(<LS_GR1>) GROUP BY ( PSTYP = <LS_GR1>-PSTYP )
                                                                                      ASSIGNING FIELD-SYMBOL(<LS_GRP1>).
    "전기일이 다르면 새로 채번
    LOOP AT GROUP <LS_GRP1> ASSIGNING FIELD-SYMBOL(<LS_GR2>) GROUP BY ( BUDAT = <LS_GR2>-BUDAT )
                                                                                               ASSIGNING FIELD-SYMBOL(<LS_GRP2>).
      "PO 번호가 다르면 새로 채번
      LOOP AT GROUP <LS_GRP2> ASSIGNING FIELD-SYMBOL(<LS_GR4>) GROUP BY ( EBELN = <LS_GR4>-EBELN )
                                                                                          ASSIGNING FIELD-SYMBOL(<LS_GRP4>).
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
        PERFORM F_SET_GOODSMVT_HEADER_POGR_RCV USING <LS_GRP1>-PSTYP
                                                                                      <LS_GRP2>-BUDAT
                                                                                      ''
                                                                                      CHANGING LS_HEADER.

        "<--2026.07.12 로그 데이터 1차 저장
        "로그 데이터 생성
        CLEAR  LT_LOG_DATA2[].
        LOOP AT GROUP <LS_GRP4> ASSIGNING FIELD-SYMBOL(<LS_TAB2>).
          LT_LOG_DATA2[] = VALUE #( BASE LT_LOG_DATA2 ( CORRESPONDING #( <LS_TAB2> ) ) ).
          LT_LOG_9424[] = VALUE #( BASE LT_LOG_9424 ( CORRESPONDING #( <LS_TAB2> ) ) ).
        ENDLOOP.

*    4-4) 처리 결과 Log 저장 및 RETURN
        PERFORM F_SAVE_LOG_POGR_RCV2 USING LS_LOG LT_LOG_9424 LS_HDRET.
        "-->2026.07.12 로그 데이터 1차 저장

        "Item 설정
        CLEAR LV_CHECK.

        LOOP AT GROUP <LS_GRP4> ASSIGNING <LS_TAB2>.
          PERFORM F_SET_GOODSMVT_ITEM_POGR_RCV2 USING LT_RESB LT_DELCOMP LT_MSLB LT_ZGTMMT9450 LT_PO LT_VC
                CHANGING LT_ITEM <LS_TAB2> LV_CHECK.

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

        READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_RETURN2>) WITH KEY TYPE = GC_E.
        IF SY-SUBRC EQ 0.
          "오류
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          LS_LOG-ZSTAT = GC_E.
          LS_LOG-MESSAGE = <LS_RETURN2>-MESSAGE.

          ZO_RESULT = GC_02.
          ZO_MESSAGE = TEXT-M02.""입고처리 실패"
          MBLNR = SPACE.
          MJAHR = SPACE.
          ZTYPE = GC_E.
          ZMESSAGE = <LS_RETURN2>-MESSAGE.

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
          "C) 배치자재인 경우(MARC-XCHPF=X) 배치마스터 제조일자 업데이트
          LOOP AT GROUP <LS_GRP4> ASSIGNING <LS_TAB2>.
            READ TABLE LT_XCHPF TRANSPORTING NO FIELDS
            WITH KEY MATNR = <LS_TAB2>-MATNR
                           WERKS = <LS_TAB2>-WERKS BINARY SEARCH .
            CHECK SY-SUBRC EQ 0.
            PERFORM F_BATCH_CHANGE_POGR_RCV2 USING <LS_TAB2> MBLNR LT_VC.
          ENDLOOP.
        ENDIF.

        "로그 데이터 생성
        CLEAR  LT_LOG_DATA2[].
        LOOP AT GROUP <LS_GRP4> ASSIGNING <LS_TAB2>.
          LT_LOG_DATA2[] = VALUE #( BASE LT_LOG_DATA2 ( CORRESPONDING #( <LS_TAB2> ) ) ).
          LT_LOG_9424[] = VALUE #( BASE LT_LOG_9424 ( CORRESPONDING #( <LS_TAB2> ) ) ).
        ENDLOOP.

*    4-4) 처리 결과 Log 저장 및 RETURN
        PERFORM F_SAVE_LOG_POGR_RCV2 USING LS_LOG LT_LOG_9424 LS_HDRET.

        "C) 꼬리표 번호 정보 테이블
*: 생성된 자재문서, 품목 내 배치번호(CHARG) 가 존재하면 ZPPT0001 테이블 테이터 저장
        IF LS_LOG-ZSTAT EQ GC_S.
          PERFORM F_SAVE_ZPPT0001_POGR_RCV2 USING LT_LOG_9424 LS_HDRET LT_DISPO.
        ENDIF.

      ENDLOOP.
*      ENDLOOP.
    ENDLOOP.
  ENDLOOP.



ENDFUNCTION.
