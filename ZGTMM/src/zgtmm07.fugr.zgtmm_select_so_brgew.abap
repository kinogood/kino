FUNCTION ZGTMM_SELECT_SO_BRGEW.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      IT_SO STRUCTURE  ZGTMMS1020
*"      OT_BRGEW STRUCTURE  ZGTMMS1021
*"----------------------------------------------------------------------

  DATA:
    LT_SO     TYPE TABLE OF ZGTMMS1020, "INPUT
    LS_SO     TYPE ZGTMMS1020,
    LT_BRGEW  TYPE TABLE OF ZGTMMS1021, "OUTPUT
    LS_BRGEW  TYPE ZGTMMS1021,
    LT_DATA   TYPE TABLE OF ZGTMMS1015, "계산 DATA
    LS_DATA   TYPE ZGTMMS1015,
    LT_OUTPUT TYPE STANDARD TABLE OF ZGTEDSIF0034,  "ED FUNCTION
    LS_OUTPUT TYPE ZGTEDSIF0034.

  DATA:
    LV_DEST       TYPE ZIFDEST-DEST,      " 드럼 정보 원격 목적지
    LV_PMATNR     TYPE C LENGTH 40,       " 포장재 코드
    LT_DRUM_CBM   TYPE TABLE OF ZGTEDSIF0037,
    LV_KWMENG_MAT TYPE KWMENG,     " 기본단위 오더 수량
    LV_WELENG_MAT TYPE KWMENG,      " 기본단위 조장
    LS_MARA       TYPE MARA.

  TYPES: BEGIN OF TY_ITEM,               " 판매오더 품목 (구성 인스턴스, 자재 중량단위)
           VBELN TYPE VBELN_VA,
           POSNR TYPE POSNR_VA,
           CUOBJ TYPE CUOBJ,
           GEWEI TYPE GEWEI,
         END OF TY_ITEM,
         BEGIN OF TY_CBM_CACHE,          " 포장재 코드별 드럼 정보 보관
           PMATNR TYPE C LENGTH 40,
           FOUND  TYPE ABAP_BOOL,
           CBM    TYPE ZGTEDSIF0037,
         END OF TY_CBM_CACHE,
         BEGIN OF TY_CHR,                " 구성 특성값 (필요한 3개만)
           CUOBJ TYPE CUOBJ,
           ATNAM TYPE ATNAM,
           ATWRT TYPE ATWRT,
         END OF TY_CHR.

  DATA:
    LT_ITEM      TYPE SORTED TABLE OF TY_ITEM WITH UNIQUE KEY VBELN POSNR,
    LT_CBM_CACHE TYPE HASHED TABLE OF TY_CBM_CACHE WITH UNIQUE KEY PMATNR,
    LT_CHR       TYPE SORTED TABLE OF TY_CHR WITH NON-UNIQUE KEY CUOBJ ATNAM,
    LT_INST      TYPE SORTED TABLE OF CUOBJ  WITH UNIQUE KEY TABLE_LINE.

  CONSTANTS:
    GC_E       TYPE C LENGTH 1 VALUE 'E',
    GC_MSG_E08 TYPE CAMSG VALUE '해당 주문은 드럼을 지정하는 주문이 아닙니다. 제품군 확인 요망!',
    GC_MSG_E09 TYPE CAMSG VALUE '해당 드럼의 외폭/약경/중량 값 중 비어 있는 값이 존재합니다. 설계팀 문의 요망!',
    GC_MSG_E10 TYPE CAMSG VALUE '해당 주문 라인의 드럼 확정이 진행되지 않았습니다. 설계팀 드럼지정 확인 요망!'.

  "필수값 확인
  IF IT_SO[] IS INITIAL.
    MESSAGE TEXT-E01 TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  MOVE-CORRESPONDING IT_SO[] TO LT_OUTPUT.
  MOVE-CORRESPONDING IT_SO[] TO LT_SO.

*----------------------------------------------------------------------*
* 1. ED 드럼 중량 조회 (ED 함수 ZGTED_SELECT_CBM_DATA 대체 - 속도 개선)
*    ED 함수는 품목마다 원격호출 ZGTED_GET_DRUM_CBM 을 반복 호출해
*    조회 1회에 60초 이상 소요되었다(품목 243건 / 포장재 코드 24종).
*    - 구성 조회: 품목별 VC_I_GET_CONFIGURATION 호출 대신
*      구성 테이블(IBIN*)에서 필요한 특성 3개를 한 번에 조회 (속도 개선)
*    - 판정 규칙은 운영 ED 함수(확정 상태 검사 주석 처리본)와 동일
*    - 드럼 정보 원격호출: 포장재 코드별 1회만 호출 (ED 함수 수정 없음)
*    판정 규칙과 결과 필드는 ED 함수와 동일하게 유지한다.
*----------------------------------------------------------------------*
  SORT LT_OUTPUT BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_OUTPUT COMPARING VBELN POSNR.

  " 1-1. 판매오더 품목의 구성 인스턴스(CUOBJ)와 자재 중량단위
  "      (ED 함수와 동일하게 자재 중량단위를 드럼 중량단위로 사용)
  SELECT VP~VBELN, VP~POSNR, VP~CUOBJ, M~GEWEI
    FROM VBAP AS VP
      JOIN MARA AS M ON VP~MATNR EQ M~MATNR
      JOIN @LT_OUTPUT AS OT ON VP~VBELN EQ OT~VBELN
                           AND VP~POSNR EQ OT~POSNR
    INTO CORRESPONDING FIELDS OF TABLE @LT_ITEM.

  IF LT_ITEM IS NOT INITIAL.
    CALL FUNCTION 'Z_IF_DESTINATION'
      EXPORTING
        GUBUN                 = 'P1'
      IMPORTING
        DEST_NAME             = LV_DEST
      EXCEPTIONS
        DESTINATION_NOT_FOUND = 1
        OTHERS                = 2.

    " 1-2. 구성 특성값을 한 번에 조회 (품목별 VC_I_GET_CONFIGURATION 호출 대체)
    "      필요한 특성: PD_CA_PACKING_DM / SAP_MILLCA_PACKAGING / PD_GA_PACKAGE_METHOD
    SELECT I~CUOBJ, E~ATNAM, D~ATWRT
      FROM @LT_ITEM AS I
        INNER JOIN IBIN       AS B ON B~INSTANCE  = I~CUOBJ
                                  AND B~VALTO     = 99991231235959
        INNER JOIN IBINVALUES AS C ON C~IN_RECNO  = B~IN_RECNO
        INNER JOIN IBSYMBOL   AS D ON D~SYMBOL_ID = C~SYMBOL_ID
        INNER JOIN CABN       AS E ON E~ATINN     = D~ATINN
      WHERE E~ATNAM IN ( 'PD_CA_PACKING_DM', 'SAP_MILLCA_PACKAGING', 'PD_GA_PACKAGE_METHOD' )
      INTO CORRESPONDING FIELDS OF TABLE @LT_CHR.

    " 구성이 존재하는 인스턴스 (없으면 기존 로직의 E10 메시지)
    SELECT DISTINCT I~CUOBJ
      FROM @LT_ITEM AS I
        INNER JOIN IBIN AS B ON B~INSTANCE = I~CUOBJ
                            AND B~VALTO    = 99991231235959
      INTO TABLE @LT_INST.
  ENDIF.

  " 1-3. 필요한 포장재 코드별 드럼 정보를 동시에(aRFC) 호출 - 순차 호출 시 코드 수 x 호출시간 소요
  "      실패/미수신 건은 아래 LOOP 에서 기존 방식(순차 호출)으로 처리한다.
  FIELD-SYMBOLS: <LS_OT>   TYPE ZGTEDSIF0034,
                 <LS_ITEM> TYPE TY_ITEM.

  IF LT_ITEM IS NOT INITIAL.
    DATA: LT_PMATNR TYPE SORTED TABLE OF CHAR40 WITH UNIQUE KEY TABLE_LINE,
          LV_TASK   TYPE C LENGTH 8,
          LV_SENT   TYPE I.

    LOOP AT LT_OUTPUT ASSIGNING <LS_OT>.
      READ TABLE LT_ITEM ASSIGNING <LS_ITEM>
           WITH TABLE KEY VBELN = <LS_OT>-VBELN POSNR = <LS_OT>-POSNR.
      CHECK SY-SUBRC EQ 0.
      CHECK LINE_EXISTS( LT_INST[ TABLE_LINE = <LS_ITEM>-CUOBJ ] ).
      CHECK VALUE ATWRT( LT_CHR[ CUOBJ = <LS_ITEM>-CUOBJ ATNAM = 'PD_CA_PACKING_DM' ]-ATWRT OPTIONAL ) IS NOT INITIAL.

      CLEAR LV_PMATNR.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = VALUE ATWRT( LT_CHR[ CUOBJ = <LS_ITEM>-CUOBJ ATNAM = 'SAP_MILLCA_PACKAGING' ]-ATWRT OPTIONAL )
        IMPORTING
          OUTPUT = LV_PMATNR.
      INSERT LV_PMATNR INTO TABLE LT_PMATNR.
    ENDLOOP.

    CLEAR: GT_DRUM_RES, GV_DRUM_RCV.
    LOOP AT LT_PMATNR INTO LV_PMATNR.
      LV_TASK = |DRM{ SY-TABIX }|.
      CLEAR LT_DRUM_CBM.
      CALL FUNCTION 'ZGTED_GET_DRUM_CBM'
        STARTING NEW TASK LV_TASK
        DESTINATION LV_DEST
        PERFORMING DRUM_CBM_DONE ON END OF TASK
        EXPORTING
          IV_MATNR  = LV_PMATNR
        TABLES
          OT_OUTPUT = LT_DRUM_CBM
        EXCEPTIONS
          COMMUNICATION_FAILURE = 1
          SYSTEM_FAILURE        = 2
          RESOURCE_FAILURE      = 3
          OTHERS                = 4.
      CHECK SY-SUBRC EQ 0.
      INSERT VALUE #( TASK = LV_TASK PMATNR = LV_PMATNR ) INTO TABLE GT_DRUM_RES.
      LV_SENT = LV_SENT + 1.
    ENDLOOP.

    IF LV_SENT GT 0.
      WAIT UNTIL GV_DRUM_RCV GE LV_SENT UP TO 120 SECONDS.
    ENDIF.

    LOOP AT GT_DRUM_RES ASSIGNING FIELD-SYMBOL(<LS_RES>) WHERE OK EQ ABAP_TRUE.
      INSERT VALUE #( PMATNR = <LS_RES>-PMATNR
                      FOUND  = <LS_RES>-FOUND
                      CBM    = <LS_RES>-CBM ) INTO TABLE LT_CBM_CACHE.
    ENDLOOP.
  ENDIF.

  LOOP AT LT_OUTPUT ASSIGNING <LS_OT>.

    READ TABLE LT_ITEM ASSIGNING <LS_ITEM>
         WITH TABLE KEY VBELN = <LS_OT>-VBELN POSNR = <LS_OT>-POSNR.
    CHECK SY-SUBRC EQ 0.   "판매오더 품목 없음: 결과 미설정(ED 함수와 동일)

    " 구성 존재 여부 (기존: LT_CONFG IS INITIAL)
    IF NOT LINE_EXISTS( LT_INST[ TABLE_LINE = <LS_ITEM>-CUOBJ ] ).
      <LS_OT>-MSG_TYPE = GC_E.
      <LS_OT>-MSG_TXT  = GC_MSG_E10.
      CONTINUE.
    ENDIF.

    " 드럼 확정 상태(PD_CA_PACKMARK_STATUS = CM) 검사는 운영 ED 함수에서 주석 처리되어 있어 제외한다.
    " (개발 ED 함수에는 검사가 살아 있음 - ED 함수 이관 시 이 부분도 맞출 것)

    " 드럼포장재 지정 여부
    IF VALUE ATWRT( LT_CHR[ CUOBJ = <LS_ITEM>-CUOBJ ATNAM = 'PD_CA_PACKING_DM' ]-ATWRT OPTIONAL ) IS INITIAL.
      <LS_OT>-MSG_TYPE = GC_E.
      <LS_OT>-MSG_TXT  = GC_MSG_E08.
      CONTINUE.
    ENDIF.

    " 포장재 코드 (알파 변환)
    CLEAR LV_PMATNR.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = VALUE ATWRT( LT_CHR[ CUOBJ = <LS_ITEM>-CUOBJ ATNAM = 'SAP_MILLCA_PACKAGING' ]-ATWRT OPTIONAL )
      IMPORTING
        OUTPUT = LV_PMATNR.

    " 드럼 정보: 같은 포장재 코드는 재호출하지 않고 보관값 사용
    ASSIGN LT_CBM_CACHE[ PMATNR = LV_PMATNR ] TO FIELD-SYMBOL(<LS_CACHE>).
    IF SY-SUBRC NE 0.
      CLEAR LT_DRUM_CBM.
      CALL FUNCTION 'ZGTED_GET_DRUM_CBM' DESTINATION LV_DEST
        EXPORTING
          IV_MATNR  = LV_PMATNR
        TABLES
          OT_OUTPUT = LT_DRUM_CBM.

      INSERT VALUE #( PMATNR = LV_PMATNR
                      FOUND  = COND #( WHEN LT_DRUM_CBM IS NOT INITIAL THEN ABAP_TRUE )
                      CBM    = VALUE #( LT_DRUM_CBM[ 1 ] OPTIONAL ) )
        INTO TABLE LT_CBM_CACHE ASSIGNING <LS_CACHE>.
    ENDIF.

    CHECK <LS_CACHE>-FOUND EQ ABAP_TRUE.   "드럼 정보 없음: 결과 미설정(ED 함수와 동일)

    DATA(LS_DRUM_CBM) = <LS_CACHE>-CBM.

    IF LS_DRUM_CBM-WHEP IS INITIAL OR
     ( LS_DRUM_CBM-SPEC_FLANG IS INITIAL AND LS_DRUM_CBM-FLANG IS INITIAL ) OR
       LS_DRUM_CBM-WEIGHT IS INITIAL OR
       LS_DRUM_CBM-DR_WEIGHT IS INITIAL.
      <LS_OT>-MSG_TYPE = GC_E.
      <LS_OT>-MSG_TXT  = GC_MSG_E09.
      CONTINUE.
    ENDIF.

    " 외폭 / 약경
    <LS_OT>-OUT_WID    = LS_DRUM_CBM-WHEP.
    <LS_OT>-BARREL_DIA = COND #( WHEN LS_DRUM_CBM-SPEC_FLANG IS NOT INITIAL
                                 THEN LS_DRUM_CBM-SPEC_FLANG
                                 ELSE LS_DRUM_CBM-FLANG ).

    " 드럼 중량: 완전포장(1), 완전포장+SKID(7), 완전포장+우든화이바(8)는 포장 포함 중량
    DATA(LV_PACK_METHOD) = VALUE ATWRT( LT_CHR[ CUOBJ = <LS_ITEM>-CUOBJ ATNAM = 'PD_GA_PACKAGE_METHOD' ]-ATWRT OPTIONAL ).
    <LS_OT>-BRGEW = COND #( WHEN LV_PACK_METHOD EQ '1' OR LV_PACK_METHOD EQ '7' OR LV_PACK_METHOD EQ '8'
                            THEN LS_DRUM_CBM-WEIGHT
                            ELSE LS_DRUM_CBM-DR_WEIGHT ).
    <LS_OT>-GEWEI    = <LS_ITEM>-GEWEI.
    <LS_OT>-MSG_TYPE = GC_S.

  ENDLOOP.


*----------------------------------------------------------------------*
* 2. 중량 계산
*----------------------------------------------------------------------*
  " 판매오더 DATA SELECT
  SELECT VK~VBELN, VP~POSNR, VP~MATNR, VP~KWMENG,  VP~VRKME,
               CV~WELENG,  CV~WECNT, M~MEINS
    FROM VBAK AS VK
      JOIN VBAP AS VP ON VK~VBELN EQ VP~VBELN
      JOIN MARA AS M ON VP~MATNR EQ M~MATNR
      JOIN ZGTMM_CV_SO_VCVALUE_BRGEW  AS CV ON VK~VBELN EQ CV~VBELN
                                                                        AND VP~POSNR EQ CV~POSNR
    JOIN @LT_SO AS ZZ ON VK~VBELN EQ ZZ~VBELN
                                  AND VP~POSNR EQ ZZ~POSNR
  INTO CORRESPONDING FIELDS OF TABLE @LT_DATA.

  LOOP AT LT_DATA ASSIGNING FIELD-SYMBOL(<LS_DATA>).
    CLEAR: LV_KWMENG_MAT, LV_WELENG_MAT, LS_MARA.

* 전체 중량 단위에 KG 값 할당
    <LS_DATA>-GEWEI = GC_KG.

* ED 값 READ TABLE
    READ TABLE LT_OUTPUT ASSIGNING FIELD-SYMBOL(<LS_OUTPUT>)
                                          WITH KEY VBELN = <LS_DATA>-VBELN POSNR = <LS_DATA>-POSNR.

    <LS_DATA>-BRGEW_DRUM = <LS_OUTPUT>-BRGEW.
    <LS_DATA>-GEWEI_DRUM = <LS_OUTPUT>-GEWEI.
    <LS_DATA>-MESSAGE = <LS_OUTPUT>-MSG_TXT.
    <LS_DATA>-TYPE = <LS_OUTPUT>-MSG_TYPE.

    IF <LS_OUTPUT>-MSG_TYPE EQ GC_S.  "ED 데이터 정상 수신 된 경우

* 2-1. 드럼 중량 단위 환산
      IF <LS_DATA>-GEWEI_DRUM NE GC_KG. "드럼 중량 단위가 KG이 아닌 경우

        CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
          EXPORTING
            INPUT         = <LS_DATA>-BRGEW_DRUM
            NO_TYPE_CHECK = 'X'
            ROUND_SIGN    = 'X'
            UNIT_IN       = <LS_DATA>-GEWEI_DRUM
            UNIT_OUT      = GC_KG
          IMPORTING
            OUTPUT        = <LS_DATA>-BRGEW_DRUM.

        IF SY-SUBRC <> 0.
          <LS_DATA>-TYPE = SY-MSGTY.
          <LS_DATA>-CODE = SY-MSGNO.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
                    INTO <LS_DATA>-MESSAGE.
          CONTINUE.
        ENDIF.
        <LS_DATA>-GEWEI_DRUM = GC_KG.
      ENDIF.


* 2-2. 실중량/실중량합 계산 (제품 중량)
* 판매 단위 = 기본 단위 일치 확인 -> 일치하지 않는 경우 판매수량 / 조장 단위 환산
      IF <LS_DATA>-VRKME NE <LS_DATA>-MEINS.

        CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
          EXPORTING
            INPUT         = <LS_DATA>-KWMENG
            NO_TYPE_CHECK = 'X'
            ROUND_SIGN    = 'X'
            UNIT_IN       = <LS_DATA>-VRKME
            UNIT_OUT      = <LS_DATA>-MEINS
          IMPORTING
            OUTPUT        = LV_KWMENG_MAT.

        IF SY-SUBRC <> 0.
          <LS_DATA>-TYPE = SY-MSGTY.
          <LS_DATA>-CODE = SY-MSGNO.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
                    INTO <LS_DATA>-MESSAGE.
          CONTINUE.
        ENDIF.

        CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
          EXPORTING
            INPUT         = <LS_DATA>-WELENG
            NO_TYPE_CHECK = 'X'
            ROUND_SIGN    = 'X'
            UNIT_IN       = <LS_DATA>-VRKME
            UNIT_OUT      = <LS_DATA>-MEINS
          IMPORTING
            OUTPUT        = LV_WELENG_MAT.

        IF SY-SUBRC <> 0.
          <LS_DATA>-TYPE = SY-MSGTY.
          <LS_DATA>-CODE = SY-MSGNO.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
                    INTO <LS_DATA>-MESSAGE.
          CONTINUE.
        ENDIF.

      ELSE.
        LV_KWMENG_MAT = <LS_DATA>-KWMENG.
        LV_WELENG_MAT = <LS_DATA>-WELENG.
      ENDIF.

* 자재마스터 질량
      SELECT SINGLE *
         FROM MARA
           INTO CORRESPONDING FIELDS OF LS_MARA
       WHERE MATNR = <LS_DATA>-MATNR.

* 실중량 계산 = 자재 중량
      <LS_DATA>-NTGEW = LV_WELENG_MAT * LS_MARA-BRGEW.
      <LS_DATA>-NTGEW_SUM = LV_KWMENG_MAT * LS_MARA-BRGEW.

* 실중량 단위 KG로 변환
      IF LS_MARA-GEWEI <> GC_KG.

        CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
          EXPORTING
            INPUT         = <LS_DATA>-NTGEW
            NO_TYPE_CHECK = 'X'
            ROUND_SIGN    = 'X'
            UNIT_IN       = LS_MARA-GEWEI
            UNIT_OUT      = GC_KG
          IMPORTING
            OUTPUT        = <LS_DATA>-NTGEW.

        IF SY-SUBRC <> 0.
          <LS_DATA>-TYPE = SY-MSGTY.
          <LS_DATA>-CODE = SY-MSGNO.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
                    INTO <LS_DATA>-MESSAGE.
          CONTINUE.
        ENDIF.

        CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
          EXPORTING
            INPUT         = <LS_DATA>-NTGEW_SUM
            NO_TYPE_CHECK = 'X'
            ROUND_SIGN    = 'X'
            UNIT_IN       = LS_MARA-GEWEI
            UNIT_OUT      = GC_KG
          IMPORTING
            OUTPUT        = <LS_DATA>-NTGEW_SUM.

        IF SY-SUBRC <> 0.
          <LS_DATA>-TYPE = SY-MSGTY.
          <LS_DATA>-CODE = SY-MSGNO.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
                    INTO <LS_DATA>-MESSAGE.
          CONTINUE.
        ENDIF.

      ENDIF.

* 2-3. 중량/중량합 계산 (제품+드럼)
      <LS_DATA>-BRGEW = <LS_DATA>-NTGEW + <LS_DATA>-BRGEW_DRUM.
      <LS_DATA>-BRGEW_SUM = <LS_DATA>-NTGEW_SUM + <LS_DATA>-BRGEW_DRUM * <LS_DATA>-WECNT.

    ENDIF.

  ENDLOOP.

  MOVE-CORRESPONDING LT_DATA TO OT_BRGEW[].
ENDFUNCTION.
