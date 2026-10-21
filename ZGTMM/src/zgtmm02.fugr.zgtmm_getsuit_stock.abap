FUNCTION ZGTMM_GETSUIT_STOCK.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_PTYPE) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_OPTION) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_FROM) TYPE  BUDAT OPTIONAL
*"     VALUE(I_TO) TYPE  BUDAT OPTIONAL
*"     VALUE(I_VALUE) TYPE  SALK3 OPTIONAL
*"  EXPORTING
*"     VALUE(ZRESULT) TYPE  BAPI_MTYPE
*"     VALUE(MESSAGE) TYPE  BAPI_MSG
*"  TABLES
*"      IT_TAB STRUCTURE  ZGTMMS0003
*"      OT_TAB STRUCTURE  ZGTMMS0004
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_GETSUIT_STOCK
*& 프로그램 명 : 적정 재고 조회(과거 소모 실적 기준)
*& 개요   : 적정재고 산출 결과 조회
*& 생성일 : 2024.12.06
*& 생성자 : ZGSIDEV03
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  DATA : LT_TAB LIKE ZGTMMS0003 OCCURS 0 WITH HEADER LINE.


  CLEAR : GV_TYPE, GR_VAL[].
  CLEAR : ZRESULT, MESSAGE, OT_TAB[].

  "로직 주석 처리(송종면E 25.01.08)
* IF I_OPTION <> GC_9 AND IT_TAB[] IS INITIAL.
*   ZRESULT = GC_E.
*   MESSAGE S072(ZGTMM01) INTO MESSAGE. "조회 대상 정보가 누락되었습니다.
*   RETURN.
* ENDIF.

  PERFORM SET_ITAB TABLES IT_TAB
                          LT_TAB.

  GV_TYPE = SWITCH #( I_PTYPE WHEN ' ' THEN 'W'
                                       ELSE I_PTYPE ).

  IF I_VALUE > 0.
    GR_VAL[] = VALUE #( ( SIGN   = GC_I
                          OPTION = GC_GE
                          LOW    = I_VALUE ) ).
  ENDIF.

  CASE I_OPTION.
    WHEN ' '.    "저장 테이블 추출
      PERFORM GET_T_STOCK TABLES LT_TAB OT_TAB.

    WHEN OTHERS. "현행 로직 유지
      PERFORM SET_SDATE USING I_FROM
                              I_TO.

      PERFORM GET_V_STOCK TABLES LT_TAB OT_TAB
                           USING I_OPTION.

  ENDCASE.

  IF OT_TAB[] IS NOT INITIAL.
    ZRESULT = GC_S.

    IF I_OPTION = GC_9.
      CLEAR : OT_TAB[].
      MESSAGE S080(ZGTMM01) INTO MESSAGE. "저장 성공
*     RETURN.
    ELSE.
      "& 건의 데이터가 조회되었습니다.
      DATA(LV_CNT) = LINES( OT_TAB ).
      MESSAGE S003(ZGTMM01) WITH LV_CNT INTO MESSAGE.
    ENDIF.
  ELSE.
    ZRESULT = GC_E.
    MESSAGE S002(ZGTMM01) INTO MESSAGE. "조회된 값이 없습니다.
  ENDIF.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*& Form SET_ITAB
*&---------------------------------------------------------------------*
FORM SET_ITAB TABLES PT_ITAB STRUCTURE ZGTMMS0003
                     PT_LTAB STRUCTURE ZGTMMS0003.

  CLEAR : PT_LTAB[].
  CHECK PT_ITAB[] IS NOT INITIAL.

  LOOP AT PT_ITAB.
    PT_LTAB = CORRESPONDING #( PT_ITAB ).
    PERFORM CONVERT_MATN1_INPUT USING PT_LTAB-MATNR.

    COLLECT PT_LTAB.
  ENDLOOP.

  SORT PT_LTAB BY WERKS MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_T_STOCK
*&---------------------------------------------------------------------*
FORM GET_T_STOCK TABLES PT_IT STRUCTURE ZGTMMS0003
                        PT_OT STRUCTURE ZGTMMS0004.

  IF PT_IT[] IS NOT INITIAL.
    SELECT *
      FROM ZGTMMT4210
      INTO CORRESPONDING FIELDS OF TABLE @PT_OT
       FOR ALL ENTRIES IN @PT_IT
     WHERE ZCYCLE    = @GV_TYPE
       AND WERKS     = @PT_IT-WERKS
       AND MATNR     = @PT_IT-MATNR
       AND STOCKVAL IN @GR_VAL.
  ELSE.
    SELECT *
      FROM ZGTMMT4210
      INTO CORRESPONDING FIELDS OF TABLE @PT_OT
     WHERE ZCYCLE    = @GV_TYPE
       AND STOCKVAL IN @GR_VAL.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_V_STOCK
*&---------------------------------------------------------------------*
FORM GET_V_STOCK TABLES PT_IT STRUCTURE ZGTMMS0003
                        PT_OT STRUCTURE ZGTMMS0004
                  USING PV_OPTION.

  DATA : LV_VNME(80).

  DATA : LT_DATA TYPE ZGTMM_CV_GETGICAL_DAILY OCCURS 0 WITH HEADER LINE.

  DATA : LV_F1 LIKE ZGTMMS0004-F1,
         LV_F2 LIKE ZGTMMS0004-LASTAVG.

  DATA : LT_4210 LIKE ZGTMMT4210 OCCURS 0 WITH HEADER LINE.


  LV_VNME = SWITCH #( GV_TYPE WHEN 'W' THEN 'ZGTMM_CV_GETGICAL_WEEK'
                                       ELSE 'ZGTMM_CV_GETGICAL_DAILY' ).

  LV_VNME = LV_VNME && '( P_STARTDATE = @GV_FDATE, P_ENDDATE = @GV_TDATE )'.

  IF PT_IT[] IS NOT INITIAL.
    SELECT *
      FROM (LV_VNME)
       FOR ALL ENTRIES IN @PT_IT
     WHERE WERKS     = @PT_IT-WERKS
       AND MATNR     = @PT_IT-MATNR
       AND STOCKVAL IN @GR_VAL
      INTO CORRESPONDING FIELDS OF TABLE @LT_DATA.
  ELSE.
    SELECT *
      FROM (LV_VNME)
     WHERE STOCKVAL IN @GR_VAL
      INTO CORRESPONDING FIELDS OF TABLE @LT_DATA.
  ENDIF.

  LOOP AT LT_DATA INTO DATA(LS_DATA).
    CLEAR : PT_OT, LV_F1, LV_F2.
    MOVE-CORRESPONDING LS_DATA TO PT_OT.

    LV_F1 = SWITCH #( GV_TYPE WHEN 'W' THEN SQRT( LS_DATA-F1 )
                              WHEN 'D' THEN SQRT( LS_DATA-APLFZ ) ).

    LV_F2 = SQRT( LS_DATA-LASTAVG ).

    PT_OT-SAFTYQTY = LS_DATA-FACTOR * LV_F1 * LV_F2.
    PT_OT-PSTOCK   = PT_OT-SAFTYQTY + LS_DATA-SUQTY.
    PT_OT-LASTAVG  = LV_F2.

    APPEND PT_OT.
  ENDLOOP.

  "적정재고 산출 결과 테이블 저장(기존 데이터 전체 삭제 후 신규 저장)
  CHECK PT_OT[] IS NOT INITIAL.
  CHECK PV_OPTION = GC_1 OR PV_OPTION = GC_9.

  DELETE FROM ZGTMMT4210 WHERE ZCYCLE = GV_TYPE.

  LT_4210[] = VALUE #( FOR LS_OT IN PT_OT
                       ( VALUE #( BASE CORRESPONDING #( LS_OT )
                                  ZCYCLE      = GV_TYPE
                                  ERDAT       = SY-DATUM
                                  ERDAT_LOCAL = SY-DATLO
                                  ERTIM       = SY-UZEIT
                                  ERTIM_LOCAL = SY-TIMLO
                                  ERNAM       = SY-UNAME ) ) ).

  MODIFY ZGTMMT4210 FROM TABLE LT_4210.

  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SDATE
*&---------------------------------------------------------------------*
FORM SET_SDATE USING PV_FROM
                     PV_TO.

  CLEAR : GV_FDATE, GV_TDATE.

  IF PV_FROM IS NOT INITIAL
 AND PV_TO   IS NOT INITIAL.
    GV_FDATE = PV_FROM.
    GV_TDATE = PV_TO.
  ELSE.
    _CALC_DATE SY-DATLO '00' '06' '-' '00'.

    GV_FDATE = GV_DATE.
    GV_TDATE = SY-DATLO.
  ENDIF.

ENDFORM.
