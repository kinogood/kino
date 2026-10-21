*&---------------------------------------------------------------------*
*& Include          ZGTPPI1030F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM GET_DATA .

  IF P_R1 = 'X'. "전송
* 선택한 송신 대상 시스템에 따라 조회 조건 플랜트 및 MRP 관리자, 자재 유형 필터링
    PERFORM FILTER_WERKS_DISPO.
* 전송 대상 플랜트가 없을 경우 데이터 취합하지 말 것
    CHECK GR_WERKS[] IS NOT INITIAL.
* 걸러진 필터값으로 데이터 취합
    PERFORM GET_MKAL.

  ELSE. "로그 조회(재처리)

    PERFORM GET_MKAL_SEND_LOG.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_display_condition
*&---------------------------------------------------------------------*
FORM CHECK_DISPLAY_CONDITION .

  CLEAR GV_ERROR.

  IF P_R1 = 'X'. "전송

    IF S_WERKS[] IS INITIAL OR S_DATUM[] IS INITIAL.

      GV_ERROR = 'X'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-M01.

    ENDIF.

  ELSE. "로그 조회(재처리)

    IF S_TARG[] IS INITIAL OR S_WERKS[] IS INITIAL OR S_DATUM2[] IS INITIAL.

      GV_ERROR = 'X'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-M01.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_screen_attribute
*&---------------------------------------------------------------------*
FORM SET_SCREEN_ATTRIBUTE .

  LOOP AT SCREEN.

    IF SCREEN-NAME = 'S_WERKS-LOW' OR
      SCREEN-NAME = 'S_DATUM-LOW' OR
      SCREEN-NAME = 'S_WERKS2-LOW' OR
      SCREEN-NAME = 'S_DATUM2-LOW' OR
      SCREEN-NAME = 'S_TARG-LOW'.
      SCREEN-REQUIRED = 2.
    ENDIF.

    IF SCREEN-GROUP1 = 'DS1'.

      IF P_R1 = 'X'. "전송
        SCREEN-ACTIVE       = 1.
      ELSE.
        SCREEN-ACTIVE       = 0.
      ENDIF.

    ELSEIF SCREEN-GROUP1 = 'DS2'.

      IF P_R2 = 'X'. "로그 조회(재처리)
        SCREEN-ACTIVE       = 1.
      ELSE.
        SCREEN-ACTIVE       = 0.
      ENDIF.

    ENDIF.

    MODIFY SCREEN.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_mkal
*&---------------------------------------------------------------------*
FORM GET_MKAL .

  DATA : LV_OK.

  CLEAR : GS_DISP, GT_DISP. ", GS_DATA, GT_DATA.
*- PV(생산버전) 변경 이력 발췌
*  SELECT DISTINCT MATNR,
*                  WERKS,
*                  VERID,
*                  ANDAT,
*                  AEDAT,
*                  ZAEHL
*    FROM MKAL_AEND
*    WHERE WERKS IN @GR_WERKS
*     AND  MATNR   IN @S_MAT
*     AND  ( ANDAT IN @S_DATUM OR AEDAT IN @S_DATUM )
*    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.

* 생산 버젼 변경 이력 중 최근 것만 남기고 삭제
*  SORT GT_DATA BY MATNR ASCENDING WERKS ASCENDING VERID ASCENDING
*                                  ZAEHL DESCENDING.
*  DELETE ADJACENT DUPLICATES FROM GT_DATA
*                        COMPARING MATNR WERKS VERID.

*- PV 전송 데이터 발췌
*- BOM 헤더 발췌
  SELECT A~MATNR,   " 자재번호
         A~WERKS,   " 플랜트
         A~VERID,   " 생산버전
         A~TEXT1,   " 생산버전 내역
         A~ADATU,   " 생산버전 효력발생일
         A~BDATU,   " 실행시간종료 : 생산버전
         A~PLNNR,   " 직무리스트그룹 키
         A~ALNAL,   " 그룹 카운터
         A~STLAL,   " 대체 BOM
         A~MDV01,   " 반복제조 생산라인
         A~ALORT,   " 반복제조를 위한 입고 저장위치
         A~ELPRO,   " 구성부품에 대한 제안출고 저장
         A~PRDAT,   " 최종점검일
         C~MTART,   " 자재유형
         D~DISPO    " MRP 관리자
    FROM MKAL AS A
*   INNER JOIN @GT_DATA AS B
*      ON A~MATNR = B~MATNR
*     AND A~WERKS = B~WERKS
*     AND A~VERID = B~VERID
   INNER JOIN MARA AS C
      ON A~MATNR = C~MATNR
   INNER JOIN MARC AS D
      ON A~MATNR = D~MATNR
     AND A~WERKS = D~WERKS
   WHERE A~WERKS IN @GR_WERKS[]
     AND A~MATNR IN @S_MAT
     AND A~PRDAT IN @S_DATUM
     AND A~STLAN = '1'
     AND A~PLNNR <> @SPACE
    INTO CORRESPONDING FIELDS OF TABLE @GT_MKAL.

  LOOP AT GT_MKAL INTO GS_MKAL.

    CLEAR GS_DISP.
    MOVE-CORRESPONDING GS_MKAL TO GS_DISP.
* 전송 상태
    GS_DISP-ICON = ICON_LED_INACTIVE.
* 수신 시스템
    IF P_R3 = 'X'.
      GS_DISP-ZSYSTEM_ID = 'KPCM'.
    ELSEIF P_R4 = 'X'.
      GS_DISP-ZSYSTEM_ID = 'KBDM'.
      "소재 MOM SRM2510-04825
    ELSEIF P_R9 = 'X'.
      GS_DISP-ZSYSTEM_ID = 'KSCM'.
      "소재 MOM SRM2510-04825
*U01 가온전선 추가
    ELSEIF P_R10 = 'X'.  "가온전력MES
      GS_DISP-ZSYSTEM_ID = 'KGPM'.
    ELSEIF P_R11 = 'X'.  "가온통신MES
      GS_DISP-ZSYSTEM_ID = 'KGOM'.
*U01 가온전선 추가
      "한미소 260827
    ELSEIF P_R12 = 'X'.
      GS_DISP-ZSYSTEM_ID = 'KFCM'.
      "한미소 260827
    ENDIF.

* 완제품&반제품 자재 유형 한정으로 MRP 관리자를 체크하여 전송 데이터 필터
    CLEAR LV_OK.
    IF GS_MKAL-MTART = 'MCFE' OR "완제품
       GS_MKAL-MTART = 'MCHF' OR "반제품
       GS_MKAL-MTART = 'ZCSH'.   "수탁반제품
      LOOP AT GT_ZGTPPT1010 INTO GS_ZGTPPT1010
                           WHERE FLD_01 = GS_DISP-ZSYSTEM_ID
                             AND FLD_03 = GS_MKAL-WERKS.
        IF GS_ZGTPPT1010 IS INITIAL.
          CONTINUE.
* MRP 관리자 앞 2자리와 SPG코드가 같지 않으면 전송 X
        ELSEIF GS_MKAL-DISPO+0(2) NE GS_ZGTPPT1010-FLD_04+0(2).
          CONTINUE.
        ELSE.
          LV_OK = 'X'.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
      LV_OK = 'X'.
    ENDIF.

    CHECK LV_OK EQ 'X'.
* 수신 시스템 내역
    GS_DISP-ZSYSTEM_ID_DESC = ZGTPP_CL_COMMON=>GET_DOMAIN_TEXT(
                                  IV_DOMNAME  = 'ZGTDTARGET'" 도메인이름
                                  IV_DOMVALUE = CONV #( GS_DISP-ZSYSTEM_ID ) ).
    "도메인에 대한 값: 단일값/상한
* 플랜트 내역
    GS_DISP-NAME1 = ZGTPP_CL_COMMON=>GET_PLANT_NAME(
                                IV_WERKS = CONV #( GS_DISP-WERKS ) ).
* 자재 내역
    GS_DISP-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX(
                           IV_MATNR = GS_DISP-MATNR ).
* 생성일 변경일
*    CLEAR GS_DATA.
*    READ TABLE GT_DATA INTO GS_DATA WITH KEY MATNR = GS_MKAL-MATNR
*                                             WERKS = GS_MKAL-WERKS
*                                             VERID = GS_MKAL-VERID.
*    IF GS_DATA IS NOT INITIAL.
*      GS_DISP-ANDAT = GS_DATA-ANDAT. "생성일
*      GS_DISP-AEDAT = GS_DATA-AEDAT. "변경일
*    ENDIF.

* 생성일 변경일
    GS_DISP-ANDAT = GS_MKAL-PRDAT. "생성일
    GS_DISP-AEDAT = GS_MKAL-PRDAT. "변경일

    APPEND GS_DISP TO GT_DISP.

  ENDLOOP.

  SORT GT_DISP BY WERKS MATNR VERID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_mkal_send_log
*&---------------------------------------------------------------------*
FORM GET_MKAL_SEND_LOG .

  RANGES : LR_ZSTAT FOR ZGTPPT1040-ZSTAT.

  IF P_R6 = 'X'. "성공건만 조회
    LR_ZSTAT-SIGN = 'I'.
    LR_ZSTAT-OPTION = 'EQ'.
    LR_ZSTAT-LOW = '00'.
    APPEND LR_ZSTAT.
    LR_ZSTAT-LOW = '0'.
    APPEND LR_ZSTAT.
  ELSEIF P_R7 = 'X'. "오류건만 조회
    LR_ZSTAT-SIGN = 'I'.
    LR_ZSTAT-OPTION = 'EQ'.
    APPEND LR_ZSTAT.
  ENDIF.

  CLEAR : GS_ZGTPPT1040, GT_ZGTPPT1040, GS_DISP2, GT_DISP2.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @GT_ZGTPPT1040
    FROM ZGTPPT1040
   WHERE ZSYSTEM_ID IN @S_TARG
     AND WERKS IN @S_WERKS
     AND MATNR IN @S_MAT
     AND IFDAT IN @S_DATUM2
     AND ZSTAT IN @LR_ZSTAT.

  LOOP AT GT_ZGTPPT1040 INTO GS_ZGTPPT1040.

    CLEAR GS_DISP2.
    MOVE-CORRESPONDING GS_ZGTPPT1040 TO GS_DISP2.
* 전송 상태
    IF GS_DISP2-ZSTAT = 'S' OR GS_DISP2-ZSTAT = '00'.
      GS_DISP2-ICON = ICON_LED_GREEN.
    ELSE.
      GS_DISP2-ICON = ICON_LED_RED.
    ENDIF.
* 수신 시스템 내역
    GS_DISP2-ZSYSTEM_ID_DESC = ZGTPP_CL_COMMON=>GET_DOMAIN_TEXT(
                                  IV_DOMNAME  = 'ZGTDTARGET'" 도메인이름
                                  IV_DOMVALUE = CONV #( GS_DISP2-ZSYSTEM_ID ) ).
    "도메인에 대한 값: 단일값/상한
* 플랜트 내역
    GS_DISP2-NAME1 = ZGTPP_CL_COMMON=>GET_PLANT_NAME(
                                IV_WERKS = CONV #( GS_DISP2-WERKS ) ).
* 자재 내역
    GS_DISP2-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX(
                           IV_MATNR = GS_DISP2-MATNR ).

    APPEND GS_DISP2 TO GT_DISP2.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exit_program
*&---------------------------------------------------------------------*
FORM EXIT_PROGRAM .

  CALL METHOD GO_DOCKING_CONTAINER->FREE.
  CLEAR : GO_DOCKING_CONTAINER, GO_GRID_0100.
  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_data
*&---------------------------------------------------------------------*
FORM SEND_DATA .
* 배치 모드일때는 조회된 모든 생산 버젼 전송
  IF P_R8 EQ 'X'.

    PERFORM ALL_SEND_DATA.

  ELSE.

    PERFORM CHOICE_SEND_DATA.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_rfc
*&---------------------------------------------------------------------*
FORM CALL_RFC TABLES PT_SENDTAB STRUCTURE ZGTPPT1040.

  DATA : LT_OT_TAB LIKE GT_OT_ITAB.
  DATA : LV_DEST TYPE ZIFDEST-DEST.
  DATA : LV_ZSYSTEM_ID   TYPE ZGTPPT1040-ZSYSTEM_ID.

  MOVE-CORRESPONDING PT_SENDTAB[] TO LT_OT_TAB[].
*- MATNR, VORNR, PLNAL PLNFL 앞에 0 제거
  PERFORM DATA_CONVERSION TABLES LT_OT_TAB.

  CLEAR: GV_RESULT, GV_MESSAGE, LV_DEST.
*- Destination 가져오기
  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      GUBUN                 = 'P1'
    IMPORTING
      DEST_NAME             = LV_DEST
    EXCEPTIONS
      DESTINATION_NOT_FOUND = 1
      OTHERS                = 2.

  CASE ABAP_TRUE.
    WHEN P_R3. "지중 MES
      LV_ZSYSTEM_ID = 'KPCM'.
    WHEN P_R4. "부스닥트 MES
      LV_ZSYSTEM_ID = 'KBDM'.
    WHEN P_R9. ""소재 MOM SRM2510-04825
      LV_ZSYSTEM_ID = 'KSCM'.
*U01 가온전선 추가
    WHEN P_R10. "가온전력MES
      LV_ZSYSTEM_ID = 'KGPM'.
    WHEN P_R11. "가온통신MES
      LV_ZSYSTEM_ID = 'KGOM'.
*U01 가온전선 추가
    WHEN P_R12. ""한미소 260827
      LV_ZSYSTEM_ID = 'KFCM'.
  ENDCASE.
*- rfc 전송
  CALL FUNCTION 'ZGTPP_IF_O_PV_INFO' DESTINATION LV_DEST
    EXPORTING
      I_SYSTEM_ID = LV_ZSYSTEM_ID
    IMPORTING
      ZO_RESULT   = GV_RESULT
      ZO_MESSAGE  = GV_MESSAGE
    TABLES
      IT_DATA     = LT_OT_TAB.
*- History_Table에 저장
  IF GV_RESULT = '00' OR GV_RESULT = '0'.
    IF GV_MESSAGE IS INITIAL.
      GV_MESSAGE    = TEXT-011.
    ENDIF.
  ELSE.
    IF GV_MESSAGE IS INITIAL.
      GV_MESSAGE = TEXT-012.
    ENDIF.
  ENDIF.

  PERFORM SAVE_HISTORY_TABLE TABLES PT_SENDTAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_conversion
*&---------------------------------------------------------------------*
FORM DATA_CONVERSION TABLES PT_OT_TAB STRUCTURE ZGTPPSIF0002.

  LOOP AT PT_OT_TAB ASSIGNING FIELD-SYMBOL(<LS_ITAB>).
    "자재번호
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = <LS_ITAB>-MATNR
      IMPORTING
        OUTPUT = <LS_ITAB>-MATNR.
    "그룹카운터
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = <LS_ITAB>-ALNAL
      IMPORTING
        OUTPUT = <LS_ITAB>-ALNAL.
    "대체 BOM No.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = <LS_ITAB>-STLAL
      IMPORTING
        OUTPUT = <LS_ITAB>-STLAL.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_history_table
*&---------------------------------------------------------------------*
FORM SAVE_HISTORY_TABLE TABLES  PT_SENDTAB STRUCTURE ZGTPPT1040.

  DATA : LV_SEQNO_N TYPE N LENGTH 10.
  DATA : LV_TIMESTAMP TYPE TIMESTAMPL.
*- 맵핑을 위한 변수키 생성
  LV_SEQNO_N = 1.

  GET TIME STAMP FIELD LV_TIMESTAMP.
  SORT PT_SENDTAB BY WERKS MATNR VERID.
  LOOP AT PT_SENDTAB ASSIGNING FIELD-SYMBOL(<LS_SDENTAB>).

    <LS_SDENTAB>-ZIFKEY = LV_TIMESTAMP.
    <LS_SDENTAB>-ZSEQNO = LV_SEQNO_N.
    CASE ABAP_TRUE.
      WHEN P_R3. "지중 MES
        <LS_SDENTAB>-ZSYSTEM_ID = 'KPCM'.
      WHEN P_R4. "부스닥트 MES
        <LS_SDENTAB>-ZSYSTEM_ID = 'KBDM'.
      WHEN P_R9. "소재 MOM SRM2510-04825
        <LS_SDENTAB>-ZSYSTEM_ID = 'KSCM'.
*U01 가온전선 추가
      WHEN P_R10. "가온전력MES
        <LS_SDENTAB>-ZSYSTEM_ID = 'KGPM'.
      WHEN P_R11. "가온통신MES
        <LS_SDENTAB>-ZSYSTEM_ID = 'KGOM'.
*U01 가온전선 추가
      WHEN P_R12. "한미소 260827
        <LS_SDENTAB>-ZSYSTEM_ID = 'KFCM'.
    ENDCASE.

    <LS_SDENTAB>-ZSTAT = GV_RESULT.
    <LS_SDENTAB>-ZMESSAGE = GV_MESSAGE.
    <LS_SDENTAB>-IFDAT = SY-DATUM.
    <LS_SDENTAB>-IFTIM = SY-UZEIT.
    <LS_SDENTAB>-IFNAM = SY-UNAME.

    ADD 1 TO LV_SEQNO_N.

  ENDLOOP.

  MODIFY ZGTPPT1040 FROM TABLE PT_SENDTAB[].
  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_alv_list
*&---------------------------------------------------------------------*
FORM UPDATE_ALV_LIST .

  DATA : LV_LINES_C TYPE C LENGTH 10.

  LOOP AT GT_ROW_NO.

    IF P_R1 = 'X'.

      CLEAR : GS_DISP.
      READ TABLE GT_DISP INTO GS_DISP INDEX GT_ROW_NO-ROW_ID.
      IF GS_DISP IS NOT INITIAL.
        IF GV_RESULT = '00' OR GV_RESULT = '0'.
          GS_DISP-ICON = ICON_LED_GREEN.
          GS_DISP-ZMESSAGE = TEXT-M03.
        ELSE.
          GS_DISP-ICON = ICON_LED_RED.
          GS_DISP-ZMESSAGE = GV_MESSAGE.
        ENDIF.
        MODIFY GT_DISP FROM GS_DISP INDEX GT_ROW_NO-ROW_ID.
      ENDIF.

    ELSE.

      CLEAR : GS_DISP2.
      READ TABLE GT_DISP2 INTO GS_DISP2 INDEX GT_ROW_NO-ROW_ID.
      IF GS_DISP2 IS NOT INITIAL.
        IF GV_RESULT = '00' OR GV_RESULT = '0'.
          GS_DISP2-ICON = ICON_LED_GREEN.
          GS_DISP2-ZMESSAGE = TEXT-M03.
        ELSE.
          GS_DISP2-ICON = ICON_LED_RED.
          GS_DISP2-ZMESSAGE = GV_MESSAGE.
        ENDIF.
        MODIFY GT_DISP2 FROM GS_DISP2 INDEX GT_ROW_NO-ROW_ID.
      ENDIF.

    ENDIF.

  ENDLOOP.

  IF LINE_EXISTS( GT_SEND[ ZSTAT = '00' ] ) OR
    LINE_EXISTS( GT_SEND[ ZSTAT = '0' ] ). " 성공시

    DATA(LV_INDEX) = LINES( GT_SEND ) .
    LV_LINES_C = LV_INDEX.
    CONDENSE LV_LINES_C.
    MESSAGE S000 WITH LV_LINES_C TEXT-013.

  ELSE.
    MESSAGE S003 WITH TEXT-014 DISPLAY LIKE 'E'. "전송 데이터가 없습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form filter_werks_dispo
*&---------------------------------------------------------------------*
FORM FILTER_WERKS_DISPO .

  CLEAR : GR_WERKS, GR_WERKS[], GT_ZGTPPT1010, GT_ZGTPPT1010[].
  GT_ZGTPPT1010 = ZGTPP_CL_COMMON=>GET_CODE_VALUE(
                          IV_MODULE_KIND = 'PP'       " 모듈 코드
                          IV_CODEGRP     = '0010' ).  " 코드 그룹

  CASE ABAP_TRUE.
    WHEN P_R3. "지중 MES
      DELETE GT_ZGTPPT1010 WHERE FLD_01 NE 'KPCM'.
    WHEN P_R4. "부스닥트 MES
      DELETE GT_ZGTPPT1010 WHERE FLD_01 NE 'KBDM'.
    WHEN P_R9. "소재 MOM SRM2510-04825
      DELETE GT_ZGTPPT1010 WHERE FLD_01 NE 'KSCM'.
*U01 가온전선 추가
    WHEN P_R10. "가온전력MES
      DELETE GT_ZGTPPT1010 WHERE FLD_01 NE 'KGPM'.
    WHEN P_R11. "가온통신MES
      DELETE GT_ZGTPPT1010 WHERE FLD_01 NE 'KGOM'.
*U01 가온전선 추가
    WHEN P_R12. "한미소 260827
      DELETE GT_ZGTPPT1010 WHERE FLD_01 NE 'KFCM'.
  ENDCASE.

  SELECT WERKS AS LOW FROM T001W
   INTO CORRESPONDING FIELDS OF TABLE GR_WERKS
  WHERE WERKS IN S_WERKS.

  IF GR_WERKS[] IS INITIAL.

    MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-015.
    LEAVE TO LIST-PROCESSING.

  ELSE.

    LOOP AT GR_WERKS ASSIGNING FIELD-SYMBOL(<LS_WERKS>).
      READ TABLE GT_ZGTPPT1010 TRANSPORTING NO FIELDS WITH KEY FLD_03 = <LS_WERKS>-LOW.
      IF SY-SUBRC EQ 0.
        <LS_WERKS>-SIGN = 'I'.
        <LS_WERKS>-OPTION = 'EQ'.
      ELSE.
        DELETE GR_WERKS.
      ENDIF.
    ENDLOOP.

    IF GR_WERKS[] IS INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-015.
      LEAVE TO LIST-PROCESSING.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form choice_send_data
*&---------------------------------------------------------------------*
FORM CHOICE_SEND_DATA .
* CALL FUNCTION - POPUP_TO_CONFIRM_STEP
  CLEAR: GV_ANSWER.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      TITEL     = TEXT-016 "생산버젼 정보 전송
      TEXTLINE1 = TEXT-017 "생산버젼 정보를 전송 하시겠습니까?
      TEXTLINE2 = ''
    IMPORTING
      ANSWER    = GV_ANSWER.
  CHECK GV_ANSWER = 'J'.
* 선택 레코드 중 한 건이라도 전기일자가 현재월에 해당되지 않는 건이 있으면 오류메시지 처리
  CLEAR  : GT_ROW_NO, GT_ROW_NO[].
  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = GT_ROW_NO[].
* 선택 라인 없으면 오류 메시지 출력
  CLEAR: GV_CNT.
  DESCRIBE TABLE GT_ROW_NO LINES GV_CNT.

  IF GV_CNT = 0.
    MESSAGE S000 WITH TEXT-M02 DISPLAY LIKE 'E'.
  ENDIF.

  CHECK GV_CNT > 0.

  CLEAR GT_SEND.
  LOOP AT GT_ROW_NO.

    IF P_R1 = 'X'. "전송

      CLEAR : GS_DISP, GS_SEND.
      READ TABLE GT_DISP INTO GS_DISP INDEX GT_ROW_NO-ROW_ID.
      IF GS_DISP IS NOT INITIAL.

        MOVE-CORRESPONDING GS_DISP TO GS_SEND.
        APPEND GS_SEND TO GT_SEND.

      ENDIF.

    ELSEIF P_R2 = 'X'. "로그 조회(재처리)

      CLEAR : GS_DISP2, GS_SEND.
      READ TABLE GT_DISP2 INTO GS_DISP2 INDEX GT_ROW_NO-ROW_ID.
      IF GS_DISP2 IS NOT INITIAL.

        MOVE-CORRESPONDING GS_DISP2 TO GS_SEND.
        APPEND GS_SEND TO GT_SEND.

      ENDIF.

    ENDIF.

  ENDLOOP.

  CHECK GT_SEND[] IS NOT INITIAL.
* 데이터 전송 후 로그 히스토리 업데이트( ZGTPPT1040 )
  PERFORM CALL_RFC TABLES GT_SEND.
* 전송 처리 후 상태값 업데이트
  PERFORM UPDATE_ALV_LIST.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form all_send_data
*&---------------------------------------------------------------------*
FORM ALL_SEND_DATA .

  CLEAR : GS_SEND, GT_SEND.
  IF P_R1 = 'X'. "전송
    MOVE-CORRESPONDING GT_DISP[] TO GT_SEND[].
  ELSEIF P_R2 = 'X'. "로그 조회(재처리)
    MOVE-CORRESPONDING GT_DISP2[] TO GT_SEND[].
  ENDIF.

  CHECK GT_SEND[] IS NOT INITIAL.
* 데이터 전송 후 로그 히스토리 업데이트( ZGTPPT1040 )
  PERFORM CALL_RFC TABLES GT_SEND.

ENDFORM.
