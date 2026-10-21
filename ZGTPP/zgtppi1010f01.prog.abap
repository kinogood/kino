*&---------------------------------------------------------------------*
*& Include          ZGTPPI1010F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form set_screen_attribute
*&---------------------------------------------------------------------*
FORM SET_SCREEN_ATTRIBUTE .

  LOOP AT SCREEN.

    IF SCREEN-NAME = 'S_WERKS-LOW' OR
      SCREEN-NAME = 'S_DATUM-LOW' OR
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
*& Form get_data
*&---------------------------------------------------------------------*
FORM GET_DATA .

  IF P_R1 = 'X'. "전송
* 선택한 송신 대상 시스템에 따라 조회 조건 플랜트 필터링
    PERFORM FILTER_WERKS.
* 전송 대상 플랜트가 없을 경우 데이터 취합하지 말 것
    CHECK GR_WERKS[] IS NOT INITIAL.
* 걸러진 필터값으로 데이터 취합
    PERFORM GET_CRHD.

  ELSE. "로그 조회(재처리)

    PERFORM GET_CRHD_SEND_LOG.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_data
*&---------------------------------------------------------------------*
FORM SEND_DATA .
* 배치 모드일때는 조회된 모든 작업장 전송
  IF P_R8 EQ 'X'.

    PERFORM ALL_SEND_DATA.

  ELSE.

    PERFORM CHOICE_SEND_DATA.

  ENDIF.

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
*& Form filter_werks
*&---------------------------------------------------------------------*
FORM FILTER_WERKS .

  CLEAR : GR_WERKS, GR_WERKS[], GT_ZGTPPT1010, GT_ZGTPPT1010[].
  GT_ZGTPPT1010 = ZGTPP_CL_COMMON=>GET_CODE_VALUE(
                          IV_MODULE_KIND = 'PP'                 " 모듈 코드
                          IV_CODEGRP     =  '0010' ).                " 코드 그룹

  CASE ABAP_TRUE.
    WHEN P_R3. "지중 MES
      DELETE GT_ZGTPPT1010 WHERE FLD_01 NE 'KPCM'.
    WHEN P_R4. "부스닥트 MES
      DELETE GT_ZGTPPT1010 WHERE FLD_01 NE 'KBDM'.
    WHEN P_R9. "소재 MOM SRM2510-04825
      DELETE GT_ZGTPPT1010 WHERE FLD_01 NE 'KSCM'.
* 가온전선 파라미터 추가
    WHEN P_R11. "가온 전력 MES
      DELETE GT_ZGTPPT1010 WHERE FLD_01 NE 'KGPM'.
    WHEN P_R12. "가온 통신 MES
      DELETE GT_ZGTPPT1010 WHERE FLD_01 NE 'KGOM'.
    WHEN P_R13. "한미소 MOM 20260825
      DELETE GT_ZGTPPT1010 WHERE FLD_01 NE 'KFCM'.
  ENDCASE.

  SELECT WERKS AS LOW FROM T001W
   INTO CORRESPONDING FIELDS OF TABLE GR_WERKS
  WHERE WERKS IN S_WERKS.

  IF GR_WERKS[] IS INITIAL.

    MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E01.
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

    IF GR_WERKS[] IS  INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E01.
      LEAVE TO LIST-PROCESSING.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_crhd
*&---------------------------------------------------------------------*
FORM GET_CRHD .

  DATA : LV_DATE TYPE DATS,
         LV_TIME TYPE TIMS.

  CLEAR : GS_DISP, GT_DISP, GS_DATA, GT_DATA.
*- 작업장 변경 이력 발췌
  SELECT DISTINCT A~WERKS, "플랜트
                           A~ARBPL, "작업장 코드
                           A~VERWE, "작업장 범주
                           A~VERAN, "책임자
                           A~LVORM, "삭제플래그
                           A~BEGDA, "시작일
                           A~AEDAT_GRND, "변경일
                           B~KOSTL, "코스트센터
                           C~KTEXT, "작업장 내역
                           A~LASTCHANGE_DATETIME "최종변경일자
    FROM CRHD AS A INNER JOIN CRCO AS B
        ON   A~OBJTY EQ B~OBJTY
        AND A~OBJID EQ B~OBJID
        INNER JOIN CRTX AS C
        ON   A~OBJTY EQ C~OBJTY
        AND A~OBJID EQ C~OBJID
        AND C~SPRAS EQ @SY-LANGU
    WHERE A~WERKS IN @GR_WERKS
        AND A~ARBPL IN @S_ARBPL
        AND B~ENDDA = '99991231'
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.

  LOOP AT GT_DATA INTO GS_DATA.
* 작업장 변경 이력 중 조회 기간에 해당되지 않는 건 제외
    CONVERT TIME STAMP GS_DATA-LASTCHANGE_DATETIME
               TIME ZONE SY-ZONLO
               INTO DATE LV_DATE TIME LV_TIME.

    READ TABLE S_DATUM INDEX 1.
    IF S_DATUM-HIGH IS INITIAL.
      IF S_DATUM-LOW <= LV_DATE AND LV_DATE <= S_DATUM-LOW.
      ELSE.
        CONTINUE.
      ENDIF.
    ELSE.
      IF S_DATUM-LOW <= LV_DATE AND LV_DATE <= S_DATUM-HIGH.
      ELSE.
        CONTINUE.
      ENDIF.
    ENDIF.

    CLEAR GS_DISP.
    MOVE-CORRESPONDING GS_DATA TO GS_DISP.
* 전송 상태
    GS_DISP-ICON = ICON_LED_INACTIVE.
* 수신 시스템
    IF P_R3 = 'X'.
      GS_DISP-ZSYSTEM_ID = 'KPCM'.
    ELSEIF P_R4 = 'X'.
      GS_DISP-ZSYSTEM_ID = 'KBDM'.
    ELSEIF P_R9 = 'X'.                "소재 MOM SRM2510-04825
      GS_DISP-ZSYSTEM_ID = 'KSCM'.
* 가온전선 파라미터 추가
    ELSEIF P_R11 = 'X'. "가온 전력 MES
      GS_DISP-ZSYSTEM_ID =  'KGPM'.
    ELSEIF P_R12 = 'X'. "가온 통신 MES
      GS_DISP-ZSYSTEM_ID =  'KGOM'.
    ELSEIF P_R13 = 'X'. "한미소 MOM 20260825
      GS_DISP-ZSYSTEM_ID =  'KFCM'.
    ENDIF.
* 수신 시스템 내역
    GS_DISP-ZSYSTEM_ID_DESC = ZGTPP_CL_COMMON=>GET_DOMAIN_TEXT(
                                  IV_DOMNAME  = 'ZGTDTARGET'" 도메인이름
                                  IV_DOMVALUE = CONV #( GS_DISP-ZSYSTEM_ID ) ).
    "도메인에 대한 값: 단일값/상한
* 작업장 범주 내역
    SELECT SINGLE KTEXT INTO @GS_DISP-ZZTEXT1
                                  FROM TC30T
                                  WHERE SPRAS EQ @SY-LANGU
                                       AND VERWE EQ @GS_DISP-VERWE.
* 작업장 범주 내역
    SELECT SINGLE KTEXT INTO @GS_DISP-ZZTEXT2
                                  FROM TC24
                                  WHERE WERKS EQ @GS_DISP-WERKS
                                       AND VERAN EQ @GS_DISP-VERAN.

    CASE ABAP_TRUE.
      WHEN P_R11 OR P_R12.
        SELECT SINGLE GONG_CD, GONG_NM FROM ZEDT0011
          INTO ( @GS_DISP-GONG_CD, @GS_DISP-GONG_NM )
          WHERE GONG_CD = @GS_DISP-ARBPL+0(3).
    ENDCASE.

    APPEND GS_DISP TO GT_DISP.

  ENDLOOP.

  SORT GT_DISP BY WERKS ARBPL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_crhd_send_log
*&---------------------------------------------------------------------*
FORM GET_CRHD_SEND_LOG .

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

  CLEAR : GS_ZGTPPT1020, GT_ZGTPPT1020, GS_DISP2, GT_DISP2.
  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE @GT_ZGTPPT1020
      FROM ZGTPPT1020
      WHERE ZSYSTEM_ID IN @S_TARG
          AND WERKS IN @S_WERKS
          AND ARBPL IN @S_ARBPL
          AND IFDAT IN @S_DATUM2
          AND ZSTAT IN @LR_ZSTAT.

  LOOP AT GT_ZGTPPT1020 INTO GS_ZGTPPT1020.

    CLEAR GS_DISP2.
    MOVE-CORRESPONDING GS_ZGTPPT1020 TO GS_DISP2.
* 전송 상태
    IF GS_DISP2-ZSTAT = '00' OR GS_DISP2-ZSTAT = '0'.
      GS_DISP2-ICON = ICON_LED_GREEN.
    ELSE.
      GS_DISP2-ICON = ICON_LED_RED.
    ENDIF.
* 수신 시스템 내역
    GS_DISP2-ZSYSTEM_ID_DESC = ZGTPP_CL_COMMON=>GET_DOMAIN_TEXT(
                                  IV_DOMNAME  = 'ZGTDTARGET'" 도메인이름
                                  IV_DOMVALUE = CONV #( GS_DISP2-ZSYSTEM_ID ) ).
    "도메인에 대한 값: 단일값/상한

    APPEND GS_DISP2 TO GT_DISP2.

  ENDLOOP.

  SORT GT_DISP2 BY ZIFKEY WERKS ARBPL.

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
*&---------------------------------------------------------------------*
*& Form call_rfc
*&---------------------------------------------------------------------*
FORM CALL_RFC TABLES PT_SENDTAB STRUCTURE ZGTPPT1020.

  DATA : LT_OT_TAB LIKE GT_OT_ITAB.
  DATA : LV_DEST TYPE ZIFDEST-DEST.
  DATA : LV_ZSYSTEM_ID   TYPE ZGTPPT1020-ZSYSTEM_ID.

  MOVE-CORRESPONDING PT_SENDTAB[] TO LT_OT_TAB[].

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
    WHEN P_R9. "소재 MOM SRM2510-04825
      LV_ZSYSTEM_ID = 'KSCM'.
* 가온전선 파라미터 추가
    WHEN P_R11. "가온 전력 MES
      LV_ZSYSTEM_ID =  'KGPM'.
    WHEN P_R12. "가온 통신 MES
      LV_ZSYSTEM_ID =  'KGOM'.
    WHEN P_R13. "한미소 MOM 260825
      LV_ZSYSTEM_ID =  'KFCM'.
  ENDCASE.
*- RFC 전송
  CALL FUNCTION 'ZGTPP_IF_O_WC_INFO' DESTINATION LV_DEST
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
      GV_MESSAGE    = TEXT-013.
    ENDIF.
  ELSE.
    IF GV_MESSAGE IS INITIAL.
      GV_MESSAGE = TEXT-014.
    ENDIF.
  ENDIF.

  PERFORM SAVE_HISTORY_TABLE TABLES PT_SENDTAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_history_table
*&---------------------------------------------------------------------*
FORM SAVE_HISTORY_TABLE TABLES PT_SENDTAB STRUCTURE ZGTPPT1020.

  DATA : LV_TIMESTAMP TYPE TIMESTAMPL.
*- 맵핑을 위한 변수키 생성
  GET TIME STAMP FIELD LV_TIMESTAMP.
  SORT PT_SENDTAB BY WERKS ARBPL.
  LOOP AT PT_SENDTAB ASSIGNING FIELD-SYMBOL(<LS_SDENTAB>).

    <LS_SDENTAB>-ZIFKEY = LV_TIMESTAMP.
    CASE ABAP_TRUE.
      WHEN P_R3. "지중 MES
        <LS_SDENTAB>-ZSYSTEM_ID = 'KPCM'.
      WHEN P_R4. "부스닥트 MES
        <LS_SDENTAB>-ZSYSTEM_ID = 'KBDM'.
      WHEN P_R9. "소재 MOM SRM2510-04825
        <LS_SDENTAB>-ZSYSTEM_ID = 'KSCM'.
* 가온전선 파라미터 추가
      WHEN P_R11. "가온 전력 MES
        <LS_SDENTAB>-ZSYSTEM_ID =  'KGPM'.
      WHEN P_R12. "가온 통신 MES
        <LS_SDENTAB>-ZSYSTEM_ID =  'KGOM'.
      WHEN P_R13. "한미소 MOM 260825
        <LS_SDENTAB>-ZSYSTEM_ID =  'KFCM'.
    ENDCASE.

    <LS_SDENTAB>-ZSTAT = GV_RESULT.
    <LS_SDENTAB>-ZMESSAGE = GV_MESSAGE.
    <LS_SDENTAB>-IFDAT = SY-DATUM.
    <LS_SDENTAB>-IFTIM = SY-UZEIT.
    <LS_SDENTAB>-IFNAM = SY-UNAME.

  ENDLOOP.

  MODIFY ZGTPPT1020 FROM TABLE PT_SENDTAB[].
  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
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
      TITEL     = TEXT-011
      TEXTLINE1 = TEXT-012
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
    MESSAGE S000 WITH LV_LINES_C TEXT-S01. "건의 작업장 정보가 전송되었습니다.

  ELSE.
    MESSAGE S003 WITH TEXT-E02 DISPLAY LIKE 'E'. "전송 데이터가 없습니다.
  ENDIF.

ENDFORM.
