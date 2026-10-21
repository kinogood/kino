FUNCTION ZGTMM_SELECT_SKID_DATA.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_VKORG) TYPE  VKORG
*"  TABLES
*"      IT_SO STRUCTURE  ZGTMMS1016
*"      OT_SKID STRUCTURE  ZGTMMS1015
*"----------------------------------------------------------------------

*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*
  DATA:
    LT_SKID   TYPE TABLE OF ZGTMMS1015,
    LS_SKID   TYPE ZGTMMS1015,
    LT_SO     TYPE TABLE OF ZGTMMS1016,
    LS_SO     TYPE ZGTMMS1016,

    LT_OUTPUT TYPE TABLE OF ZGTEDSIF0034,
    LS_OUTPUT TYPE ZGTEDSIF0034.

*----------------------------------------------------------------------*
* 용적률 + 중량 + SKID 구성표 계산 (조장 별 수치)
*----------------------------------------------------------------------*
  DATA:
    LV_FAR        TYPE P LENGTH 16 DECIMALS 3,
    LV_KWMENG_MAT TYPE KWMENG,     " 기본단위 오더 수량
    LV_WELENG_MAT TYPE KWMENG,      " 기본단위 조장

    LS_MARA       TYPE MARA,
    LS_PP1010     TYPE ZGTPPT1010.

  IF IT_SO[] IS INITIAL.
    MESSAGE TEXT-E01 TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  CLEAR: OT_SKID[].

  MOVE-CORRESPONDING IT_SO[] TO LT_SKID.


  LOOP AT LT_SKID ASSIGNING FIELD-SYMBOL(<LS_SKID>).
    CLEAR: LV_FAR, LV_KWMENG_MAT, LV_WELENG_MAT, LS_MARA, LS_PP1010.

* 필수값 누락 시 메시지 반환
    IF <LS_SKID>-VBELN IS INITIAL OR <LS_SKID>-POSNR IS INITIAL OR <LS_SKID>-MATNR IS INITIAL OR
      <LS_SKID>-BARREL_DIA IS INITIAL OR <LS_SKID>-OUT_WID IS INITIAL OR <LS_SKID>-BRGEW_DRUM IS INITIAL OR <LS_SKID>-GEWEI_DRUM IS INITIAL.
      <LS_SKID>-TYPE = GC_E.
      <LS_SKID>-MESSAGE = '필수 값이 누락되었습니다.'.
      CONTINUE.
    ENDIF.

*----------------------------------------------------------------------*
* 1. TOTAL 용적률(FAR) 계산
*----------------------------------------------------------------------*
    LV_FAR = <LS_SKID>-WECNT * ( <LS_SKID>-BARREL_DIA * <LS_SKID>-BARREL_DIA * <LS_SKID>-OUT_WID ).

* 1-1. MM3->M3 단위 환산
    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING
        INPUT                = LV_FAR
        NO_TYPE_CHECK        = 'X'
        ROUND_SIGN           = 'X '
        UNIT_IN              = GC_MMQ
        UNIT_OUT             = GC_M3
      IMPORTING
        OUTPUT               = <LS_SKID>-FAR
      EXCEPTIONS
        CONVERSION_NOT_FOUND = 1
        DIVISION_BY_ZERO     = 2
        INPUT_INVALID        = 3
        OUTPUT_INVALID       = 4
        OVERFLOW             = 5
        TYPE_INVALID         = 6
        UNITS_MISSING        = 7
        UNIT_IN_NOT_FOUND    = 8
        UNIT_OUT_NOT_FOUND   = 9
        OTHERS               = 10.
    IF SY-SUBRC <> 0.
      <LS_SKID>-TYPE = SY-MSGTY.
      <LS_SKID>-CODE = SY-MSGNO.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
                INTO <LS_SKID>-MESSAGE.
      CONTINUE.
    ENDIF.

*----------------------------------------------------------------------*
* 2. 중량 계산
*----------------------------------------------------------------------*
* 중량 단위에 KG 값 할당
    <LS_SKID>-GEWEI = GC_KG.

* 2-1. 드럼 중량 단위 환산

    IF <LS_SKID>-GEWEI_DRUM NE GC_KG. "드럼 중량 단위가 KG이 아닌 경우

      CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
        EXPORTING
          INPUT         = <LS_SKID>-BRGEW_DRUM
          NO_TYPE_CHECK = 'X'
          ROUND_SIGN    = 'X'
          UNIT_IN       = <LS_SKID>-GEWEI_DRUM
          UNIT_OUT      = GC_KG
        IMPORTING
          OUTPUT        = <LS_SKID>-BRGEW_DRUM.

      IF SY-SUBRC <> 0.
        <LS_SKID>-TYPE = SY-MSGTY.
        <LS_SKID>-CODE = SY-MSGNO.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
                  INTO <LS_SKID>-MESSAGE.
        CONTINUE.
      ENDIF.
      <LS_SKID>-GEWEI_DRUM = GC_KG.
    ENDIF.


* 2-2. 실중량/실중량합 계산 (제품 중량)
* 판매 단위 = 기본 단위 일치 확인 -> 일치하지 않는 경우 판매수량 / 조장 단위 환산
    IF <LS_SKID>-VRKME NE <LS_SKID>-MEINS.

      CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
        EXPORTING
          INPUT         = <LS_SKID>-KWMENG
          NO_TYPE_CHECK = 'X'
          ROUND_SIGN    = 'X'
          UNIT_IN       = <LS_SKID>-VRKME
          UNIT_OUT      = <LS_SKID>-MEINS
        IMPORTING
          OUTPUT        = LV_KWMENG_MAT.

      IF SY-SUBRC <> 0.
        <LS_SKID>-TYPE = SY-MSGTY.
        <LS_SKID>-CODE = SY-MSGNO.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
                  INTO <LS_SKID>-MESSAGE.
        CONTINUE.
      ENDIF.

      CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
        EXPORTING
          INPUT         = <LS_SKID>-WELENG
          NO_TYPE_CHECK = 'X'
          ROUND_SIGN    = 'X'
          UNIT_IN       = <LS_SKID>-VRKME
          UNIT_OUT      = <LS_SKID>-MEINS
        IMPORTING
          OUTPUT        = LV_WELENG_MAT.

      IF SY-SUBRC <> 0.
        <LS_SKID>-TYPE = SY-MSGTY.
        <LS_SKID>-CODE = SY-MSGNO.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
                  INTO <LS_SKID>-MESSAGE.
        CONTINUE.
      ENDIF.

    ELSE.
      LV_KWMENG_MAT = <LS_SKID>-KWMENG.
      LV_WELENG_MAT = <LS_SKID>-WELENG.
    ENDIF.

* 자재마스터 질량
    SELECT SINGLE *
       FROM MARA
         INTO CORRESPONDING FIELDS OF LS_MARA
     WHERE MATNR = <LS_SKID>-MATNR.

* 실중량 계산 = 자재 중량
    <LS_SKID>-NTGEW = LV_WELENG_MAT * LS_MARA-BRGEW.
    <LS_SKID>-NTGEW_SUM = LV_KWMENG_MAT * LS_MARA-BRGEW.

* 실중량 단위 KG로 변환
    IF LS_MARA-GEWEI <> GC_KG.

      CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
        EXPORTING
          INPUT         = <LS_SKID>-NTGEW
          NO_TYPE_CHECK = 'X'
          ROUND_SIGN    = 'X'
          UNIT_IN       = LS_MARA-GEWEI
          UNIT_OUT      = GC_KG
        IMPORTING
          OUTPUT        = <LS_SKID>-NTGEW.

      IF SY-SUBRC <> 0.
        <LS_SKID>-TYPE = SY-MSGTY.
        <LS_SKID>-CODE = SY-MSGNO.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
                  INTO <LS_SKID>-MESSAGE.
        CONTINUE.
      ENDIF.

      CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
        EXPORTING
          INPUT         = <LS_SKID>-NTGEW_SUM
          NO_TYPE_CHECK = 'X'
          ROUND_SIGN    = 'X'
          UNIT_IN       = LS_MARA-GEWEI
          UNIT_OUT      = GC_KG
        IMPORTING
          OUTPUT        = <LS_SKID>-NTGEW_SUM.

      IF SY-SUBRC <> 0.
        <LS_SKID>-TYPE = SY-MSGTY.
        <LS_SKID>-CODE = SY-MSGNO.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
                  INTO <LS_SKID>-MESSAGE.
        CONTINUE.
      ENDIF.

    ENDIF.

* 2-3. 중량/중량합 계산 (제품+드럼)
    <LS_SKID>-BRGEW = <LS_SKID>-NTGEW + <LS_SKID>-BRGEW_DRUM.
    <LS_SKID>-BRGEW_SUM = <LS_SKID>-NTGEW_SUM + <LS_SKID>-BRGEW_DRUM * <LS_SKID>-WECNT.


*----------------------------------------------------------------------*
* 3. 장착 후 수치 계산
*----------------------------------------------------------------------*

* 3-1. 영업조직 별 코드마스터 SELECT
    SELECT SINGLE *
    FROM ZGTPPT1010
    WHERE MODULE_KIND = 'MM'
    AND CODEGRP = '0740'
    AND FLD_01 = @I_VKORG
    AND CAST( FLD_02 AS DEC( 13, 3 ) ) LE @<LS_SKID>-BRGEW
    AND CAST( FLD_03 AS DEC( 13, 3 ) ) GT @<LS_SKID>-BRGEW
   INTO CORRESPONDING FIELDS OF @LS_PP1010.

    IF SY-SUBRC NE 0.
      <LS_SKID>-TYPE = GC_E.
      <LS_SKID>-MESSAGE = '코드마스터에서 상수를 불러올 수 없습니다.'.
      CONTINUE.
    ENDIF.

* 3-2. SKID 설계 참고치(A) 계산 -> 10단위 계산
    <LS_SKID>-CHORD_A = FLOOR( ( SQRT( ( <LS_SKID>-BARREL_DIA / 2 ) ** 2 -
                                       ( ( <LS_SKID>-BARREL_DIA / 2 ) - LS_PP1010-FLD_09 ) ** 2 ) * 2  ) / 10 ) * 10.

* 3-3. H2 계산 (H2 = H1 + 보정상수)
    <LS_SKID>-BARREL_DIA_2 = <LS_SKID>-BARREL_DIA + LS_PP1010-FLD_05.

* 3-4. W2 계산 (W2 = W1 + 보정상수)
    <LS_SKID>-OUT_WID_2 = <LS_SKID>-OUT_WID + LS_PP1010-FLD_06.

* 3-5. 중량 계산 ((H1+W2)*보정상수 + W2*보정상수2) -> 정수 반올림
    <LS_SKID>-BRGEW_2 = ROUND( VAL = ( <LS_SKID>-BRGEW + ( <LS_SKID>-BARREL_DIA + <LS_SKID>-OUT_WID_2 ) * LS_PP1010-FLD_07
                                       + <LS_SKID>-OUT_WID_2  *  LS_PP1010-FLD_08 ) DEC = 0 ).

  ENDLOOP.


  MOVE-CORRESPONDING LT_SKID TO OT_SKID[].

ENDFUNCTION.
