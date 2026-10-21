*----------------------------------------------------------------------*
***INCLUDE LZGTPP01F03.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form BAPI_PRODORDCONF_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_PRODORDCONF_CANCEL TABLES PS_RETURN STRUCTURE BAPIRET1
                             USING PV_AFRU_RUECK
                                   PV_AFRU_RMZHL
                                   PV_AFRU_BUDAT
                                   PV_RUECK
                                   PV_RMZHL
                                   PV_CANCEL_FLAG.
  DATA : LS_RETURN  TYPE BAPIRET1,
         LV_RUECK   TYPE BAPI_PP_CONF_KEY-CONF_NO,
         LV_RMZHL   TYPE BAPI_PP_CONF_KEY-CONF_CNT,
         LV_MESSAGE TYPE BAPIRET1-MESSAGE.

  CLEAR : LS_RETURN, LV_RUECK, LV_RMZHL, LV_MESSAGE.


*- 실적 취소 펑션
  CALL FUNCTION 'BAPI_PRODORDCONF_CANCEL'
    EXPORTING
      CONFIRMATION        = PV_AFRU_RUECK "확정번호
      CONFIRMATIONCOUNTER = PV_AFRU_RMZHL "확정카운터
      POSTG_DATE          = PV_AFRU_BUDAT
    IMPORTING
      RETURN              = PS_RETURN
      CREATED_CONF_NO     = PV_RUECK
      CREATED_CONF_COUNT  = PV_RMZHL.
*- 실패
  IF PV_RUECK IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    PV_CANCEL_FLAG = 'E'.
*- 성공
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
    PV_CANCEL_FLAG = 'S'.
  ENDIF.
**- 성공
*  IF ls_return IS INITIAL.
*    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*      EXPORTING
*        wait = 'X'.
*    pv_cancel_flag = 'S'.
**- 실패
*  ELSE.
*    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*    pv_cancel_flag = 'E'.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_PRODORDCONF_CREATE_TT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_GOODSMOVEMENTS
*&---------------------------------------------------------------------*
FORM BAPI_PRODORDCONF_CREATE_TT_A TABLES PT_GOODSMOVEMENTS
                                 STRUCTURE BAPI2017_GM_ITEM_CREATE
                                  PT_RETURN STRUCTURE BAPIRET1
                                  USING PV_FIN_CONF
                                        PV_CLEAR_RES
                                        PV_ISM06
                                        PV_EXTID
                                        PV_BAPI_FLAG
                                        PV_TIMESTAMP
                                        PV_SYSTEM_ID
                                        PV_MODE
                                        PV_COUNT TYPE N
                                        .


  DATA: LT_TT      TYPE TABLE OF BAPI_PP_TIMETICKET,
        LT_GOODS   TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_DETAIL  TYPE TABLE OF BAPI_CORU_RETURN,
        LS_DETAIL  TYPE BAPI_CORU_RETURN,
        LS_RETURN  TYPE BAPIRET1,
        LV_MESSAGE TYPE BAPI_CORU_RETURN-MESSAGE.
  DATA : LT_RETURN         LIKE TABLE OF BAPIRET1,
         LV_RUECK          TYPE BAPI_PP_CONF_KEY-CONF_NO,
         LV_RMZHL          TYPE BAPI_PP_CONF_KEY-CONF_CNT,
         LV_EXTID(32),
         LV_CANCEL_FLAG(1).

  DATA: LV_BUDAT TYPE BUCHDATUM. "GO02(+)

*- GO02 Start GAON 전기일 설정
  CLEAR: LV_BUDAT.
  IF GV_GAON EQ ABAP_TRUE.
    LV_BUDAT = GV_BUDAT.
  ELSE.
    LV_BUDAT = GS_CON-BUDAT.
  ENDIF.
*- GO02 End GAON 전기일 설정

*  DATA: lv_fin_time TYPE ru_iebz.  "20260427 ZGODEV03
*
*  "가온전선 추가 20260427
*  CLEAR: lv_fin_time.
*  IF gv_gaon EQ abap_true.
*    lv_fin_time = sy-uzeit.
*  ELSE.
*    lv_fin_time = gs_con-iedz.
*  ENDIF.
*  "가온전선 추가 20260427

  CLEAR : LT_TT, LT_GOODS, LT_DETAIL, LS_RETURN, LV_MESSAGE, LS_DETAIL.


  LT_TT = VALUE #( ( ORDERID         = GS_CON-AUFNR
                     OPERATION       = GS_CON-VORNR
                     FIN_CONF        = PV_FIN_CONF
                     CLEAR_RES       = PV_CLEAR_RES
                     POSTG_DATE      = LV_BUDAT "GS_CON-BUDAT   "GO02(+)
                     DEV_REASON      = ''
                     PLANT           = GS_CON-WERKS
                     WORK_CNTR       = GS_CON-ARBPL
                     YIELD           = GS_CON-LMNGA
                     SCRAP           = ''
                     REWORK          = ''
                     CONF_TEXT       = GS_CON-TAGNR
                     CONF_ACTIVITY1  = '' " 공란
                     CONF_ACTI_UNIT1 = GS_CON-ILE01
                     CONF_ACTIVITY2  = '' " 공란
                     CONF_ACTI_UNIT2 = GS_CON-ILE02
                     CONF_ACTIVITY3  = '' " 공란
                     CONF_ACTI_UNIT3 = GS_CON-ILE03
                     CONF_ACTIVITY4  = '' " 공란
                     CONF_ACTI_UNIT4 = GS_CON-ILE04
                     CONF_ACTIVITY5  = '' " 공란
                     CONF_ACTI_UNIT5 = GS_CON-ILE05
                     CONF_ACTIVITY6  = '' " 공란
                     CONF_ACTI_UNIT6 = GS_CON-ILE06
                     EXEC_START_DATE = GS_CON-ISDD
                     EXEC_START_TIME = GS_CON-ISDZ
                     PROC_FIN_DATE   = GS_CON-IEDD
                     PROC_FIN_TIME   = GS_CON-IEDZ
*                     proc_fin_time   = lv_fin_time   "gs_con-iedz 20260427 ZGODEV03
                     EX_IDENT        = PV_EXTID
                     PERS_NO         = GS_CON-PERNR   ) ).

*- 생산 실적 처리
  CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
    IMPORTING
      RETURN         = LS_RETURN
    TABLES
      TIMETICKETS    = LT_TT
      GOODSMOVEMENTS = PT_GOODSMOVEMENTS
      DETAIL_RETURN  = LT_DETAIL.

*  WAIT UP TO 2 SECONDS.
*- 성공
  IF LS_RETURN IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    LS_DETAIL = VALUE #( LT_DETAIL[ 1 ] OPTIONAL ).

    PERFORM RETURN_MESSAGE_CON_C  USING 'S'
                                      LS_DETAIL-MESSAGE
                                      LS_DETAIL-CONF_NO
                                      LS_DETAIL-CONF_CNT
                                      PV_EXTID.

    PERFORM SAVE_LOG_CON  USING 'S'
                                LS_DETAIL-MESSAGE
                                LS_DETAIL-CONF_NO
                                LS_DETAIL-CONF_CNT
                                PV_EXTID
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE
                                .

*- 생산오더 전송 프로그램 호출(zgtppi2010)
***    PERFORM call_transaction_zgtppi2010.

    PV_BAPI_FLAG = 'A'.
*- 실패
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*- 확정 외부 ID KEY 생성
    CLEAR : LV_EXTID.
    LV_EXTID = GS_CON-RU_EXTID.
    LOOP AT   GT_GR_RESULT_C INTO  GS_GR_RESULT_C .

      PERFORM BAPI_PRODORDCONF_CANCEL TABLES LT_RETURN
                                      USING GS_GR_RESULT_C-RUECK
                                            GS_GR_RESULT_C-RMZHL
                                            LV_BUDAT "GS_CON-BUDAT   "GO02(+)
                                            LV_RUECK
                                            LV_RMZHL
                                            LV_CANCEL_FLAG.
      IF LV_CANCEL_FLAG = 'E'.

*          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*          READ TABLE lt_return INTO DATA(ls_return)  WITH KEY type = 'E'.
*          IF sy-subrc = 0.
        IF LV_RUECK IS INITIAL.
          PERFORM RETURN_MESSAGE_CON  USING 'E'
*                                              ls_return-message
                                           TEXT-M04
                                            '  '
                                            '  '
                                            LV_EXTID.
          PERFORM SAVE_LOG_CON_CANCEL  USING 'E'
*                                        ls_return-message
                                      TEXT-M04
                                      '  '
                                      '  '
                                      LV_EXTID
                                      PV_TIMESTAMP
                                      PV_SYSTEM_ID
                                      PV_MODE.
        ENDIF.
        EXIT.
      ENDIF.

    ENDLOOP.

    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'A'
                                       OR  TYPE = 'E'
                                       OR  TYPE = 'X'.

      PERFORM RETURN_MESSAGE_CON  USING 'E'
                                      LS_DETAIL-MESSAGE
                                      '  '
                                      '  '
                                      PV_EXTID.

      PERFORM SAVE_LOG_CON  USING 'E'
                                  LS_DETAIL-MESSAGE
                                  '  '
                                  '  '
                                  PV_EXTID
                                  PV_TIMESTAMP
                                  PV_SYSTEM_ID
                                  PV_MODE.

      EXIT.
    ENDLOOP.

    PV_BAPI_FLAG = 'X'.


    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'E'
                                       AND  ID = 'CO'
                           AND ( NUMBER = '469' OR NUMBER = '341' ) .
      WAIT UP TO '0.1' SECONDS.
      IF PV_COUNT < 21.
        PV_COUNT = PV_COUNT + 1.
        PERFORM BAPI_PRODORDCONF_CREATE_TT_A TABLES PT_GOODSMOVEMENTS
                                                    PT_RETURN
                                                 USING PV_FIN_CONF
                                                       PV_CLEAR_RES
                                                       PV_ISM06
                                                       PV_EXTID
                                                       PV_BAPI_FLAG
                                                       PV_TIMESTAMP
                                                       PV_SYSTEM_ID
                                                       PV_MODE
                                                       PV_COUNT.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_TRANSACTION_ZAUMI_P06
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_TRANSACTION_ZGTPPI2010 USING PV_WERKS PV_AUFNR .

*<-
  JOBNAME = '생산오더전송'.
  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      JOBNAME          = JOBNAME
    IMPORTING
      JOBCOUNT         = JOBCOUNT
    EXCEPTIONS
      CANT_CREATE_JOB  = 1
      INVALID_JOB_DATA = 2
      JOBNAME_MISSING  = 3
      OTHERS           = 4.

  RANGES : LR_AUFNR FOR AFKO-AUFNR.
  LR_AUFNR[] = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = PV_AUFNR ) ).
  RANGES : LR_DISPO FOR AFKO-DISPO.
  LR_DISPO[] = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = 'AUF' )
                        ( SIGN = 'I' OPTION = 'EQ' LOW = 'AUH' ) ).

  SUBMIT ZGTPPI2010 VIA JOB JOBNAME
                   NUMBER JOBCOUNT
                  AND RETURN
                  WITH P_WERKS = PV_WERKS
                  WITH S_AUFNR IN LR_AUFNR
                  WITH P_C1    = 'X'
                  WITH P_C2    = 'X'.

  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      JOBCOUNT             = JOBCOUNT
      JOBNAME              = JOBNAME
      STRTIMMED            = 'X'
    EXCEPTIONS
      CANT_START_IMMEDIATE = 1
      INVALID_STARTDATE    = 2
      JOBNAME_MISSING      = 3
      JOB_CLOSE_FAILED     = 4
      JOB_NOSTEPS          = 5
      JOB_NOTEX            = 6
      LOCK_FAILED          = 7
      OTHERS               = 8.
*->

*  SET PARAMETER ID 'M1' FIELD GS_CON-WERKS. "플랜트
*  SET PARAMETER ID 'M2' FIELD GS_CON-AUFNR. "생산오더
*
*  CALL TRANSACTION 'ZAUMI_P06'  AND SKIP FIRST SCREEN.
*
*  SET PARAMETER ID 'M1' FIELD '  '.
*  SET PARAMETER ID 'M2' FIELD '  '.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CANCEL_CON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERROR
*&---------------------------------------------------------------------*
FORM CHECK_CANCEL_CON  USING PV_ERROR
                             PV_EXTID.


  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @GT_AFRU
    FROM AFRU
    WHERE EXTID = @PV_EXTID
     AND  AUFNR = @GS_CON-AUFNR
     AND  STOKZ = ''
     AND  STZHL = ''.

  IF GT_AFRU[] IS INITIAL.
    PERFORM RETURN_MESSAGE_CON  USING 'E'
                                      '확정번호가 존재하지 않습니다.'
                                      '  '
                                      '  '
                                      PV_EXTID.
    PV_ERROR = 'X'.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_COMMON_CON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERROR
*&---------------------------------------------------------------------*
FORM CHECK_COMMON_CON  USING  PV_ERROR.

  DATA : LV_MESSAGE(220).

*- 플랜트
  SELECT SINGLE MANDT
   FROM T001W
   WHERE WERKS = @GS_CON-WERKS
   INTO @SY-MANDT.
  IF SY-SUBRC <> 0.

    PERFORM RETURN_MESSAGE_CON  USING 'E'
                                      '존재하지 않는 플랜트 입니다.'
                                      '  '
                                      '  '
                                      '  '.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.



*- 생산오더 번호
  SELECT SINGLE MANDT
    FROM AUFK
    WHERE AUFNR = @GS_CON-AUFNR
    INTO @SY-MANDT.
  IF SY-SUBRC <> 0.

    PERFORM RETURN_MESSAGE_CON USING 'E'
                                     '존재하지 않는 생산오더 입니다.'
                                     '  '
                                     '  '
                                     '  '.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

*- 생산오더 상태
  PERFORM GET_STATUS_CON USING PV_ERROR.


  IF PV_ERROR = 'X'.

    PERFORM RETURN_MESSAGE_CON   USING 'E'
                                       '오더상태를 체크하시기 바랍니다.'
                                       '  '
                                       '  '
                                       '  '.
  ENDIF.


*- 25.09.11 Strart 생산오더 Lock 점검 추가
  PERFORM CHECK_PRODORDCONF_CREATE_LOCK2
                                   USING  GS_CON-AUFNR
                                               PV_ERROR
                                               LV_MESSAGE
                                               ' '
                                               ' '.

  IF PV_ERROR = 'X'.

*** Start. 25.09.26 메세지 Perform문 처리
*    CONCATENATE '오더번호 (' gs_con-aufnr ')이 처리중입니다'
*                                                                      INTO lv_message .
*** End. 25.09.26 메세지 Perform문 처리
    PERFORM RETURN_MESSAGE_CON   USING 'E'
                                       LV_MESSAGE
                                       '  '
                                       '  '
                                       '  '.
  ENDIF.
*- 25.09.11 End 생산오더 Lock 점검 추가

*- GO01 Start GAON WIP 생산오더 관련 Validation
  SELECT SINGLE WIPST
    FROM ZGTPPT4150
   WHERE WERKS EQ @GS_CON-WERKS
     AND AUFNR EQ @GS_CON-AUFNR
    INTO @DATA(LV_WIPST).

  IF LV_WIPST EQ 'W'.
    PERFORM RETURN_MESSAGE_CON USING 'E'
                                     'WIP 처리중 오더이기 때문에 실적 처리를 할 수 없습니다.'
                                     '  '
                                     '  '
                                     '  '.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.
*- GO01 End GAON WIP 생산오더 관련 Validation

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_GOODSMOVEMENTS
*&      --> LV_ERROR
*&---------------------------------------------------------------------*
FORM CHECK_CON  TABLES PT_GOODSMOVEMENTS STRUCTURE BAPI2017_GM_ITEM_CREATE
                USING  PV_ERROR
                       PV_EXTID
                       PV_CASE.

  DATA : LS_PROPOSE      TYPE BAPI_PP_CONF_PROP,
         LT_RETURN       TYPE TABLE OF BAPI_CORU_RETURN,
         LT_TT           TYPE TABLE OF BAPI_PP_TIMETICKET,
         LS_TT           TYPE BAPI_PP_TIMETICKET,
         LV_RU_EXTID(32).

  CLEAR : LT_RETURN, LS_TT.


*- Import Prameter
  LS_PROPOSE = VALUE #( GOODSMOVEMENT = 'X'
*                        QUANTITY = 'X'
                        ACTIVITY = 'X' ).


  LT_TT = VALUE #( ( ORDERID    = GS_CON-AUFNR
                     OPERATION  = GS_CON-VORNR
                     POSTG_DATE = GS_CON-BUDAT
                     PLANT      = GS_CON-WERKS
                     YIELD      = GS_CON-LMNGA
                     EX_IDENT   = PV_EXTID
                     WORK_CNTR  = GS_CON-ARBPL
*                     scrap      = gs_con-xmnga
*                     rework     = gs_con-rmnga
                      ) ).
*- 생산오더의 실적처리 전 참조값 바피 호출
  CALL FUNCTION 'BAPI_PRODORDCONF_GET_TT_PROP'
    EXPORTING
      PROPOSE        = LS_PROPOSE
    TABLES
      TIMETICKETS    = LT_TT
      GOODSMOVEMENTS = PT_GOODSMOVEMENTS
      DETAIL_RETURN  = LT_RETURN.

  LS_TT = VALUE #( LT_TT[ 1 ] OPTIONAL ).

*기존에 해당 오더, 작업번호로 유형(GRUND)별 실적처리된 작업시간의 SUM을 추출함
  SELECT  AUFNR, VORNR, GRUND,
          SUM( ISM01 ) AS ISM01,
          SUM( ISM02 ) AS ISM02,
          SUM( ISM03 ) AS ISM03,
          SUM( ISM04 ) AS ISM04,
          SUM( ISM05 ) AS ISM05,
          SUM( ISM06 ) AS ISM06
    FROM AFRU
    INTO CORRESPONDING FIELDS OF TABLE @GT_AFRU_SUM
    WHERE AUFNR = @GS_CON-AUFNR
       AND VORNR = @GS_CON-VORNR
       AND STOKZ = @SPACE
       AND STZHL = @SPACE
     GROUP BY AUFNR, VORNR, GRUND
     .

*    - 액티비지 확정 단위
  "액티비티 1 확정 단위 점검
  IF GS_CON-ILE01 <> LS_TT-CONF_ACTI_UNIT1.
    PERFORM RETURN_MESSAGE_CON  USING 'E'
            TEXT-E87 "'액티비티 확정 단위가 생산오더와 다릅니다.'
            '  '
            '  '
            PV_EXTID.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.
  IF GS_CON-ISM01 < 0.
    READ TABLE GT_AFRU_SUM WITH KEY GRUND = ''.
    IF SY-SUBRC = 0.
      IF GT_AFRU_SUM-ISM01 < ABS( GS_CON-ISM01 ).
        PERFORM RETURN_MESSAGE_CON  USING 'E'
                TEXT-E89 " 'Activity (-) 시간이 기존 실적처리된 가동준비시간보다 작아 처리할 수 없습니다.
                '  '
                '  '
                PV_EXTID.
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ELSE.
      PERFORM RETURN_MESSAGE_CON  USING 'E'
              TEXT-E89 " 'Activity (-) 시간이 기존 실적처리된 가동준비시간보다 작아 처리할 수 없습니다.
              '  '
              '  '
              PV_EXTID.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.

  "액티비티 2 확정 단위 점검
  IF GS_CON-ILE02 <> LS_TT-CONF_ACTI_UNIT2.
    PERFORM RETURN_MESSAGE_CON  USING 'E'
            TEXT-E87 "''액티비티 확정 단위가 생산오더와 다릅니다.'
            '  '
            '  '
            PV_EXTID.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.
  IF GS_CON-ISM02 < 0.
    READ TABLE GT_AFRU_SUM WITH KEY GRUND = ''.
    IF SY-SUBRC = 0.
      IF GT_AFRU_SUM-ISM02 < ABS( GS_CON-ISM02 ).
        PERFORM RETURN_MESSAGE_CON  USING 'E'
                TEXT-E91 " 'Activity (-) 시간이 기존 실적처리된 기계시간보다 작아 처리할 수 없습니다.
                '  '
                '  '
                PV_EXTID.
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ELSE.
      PERFORM RETURN_MESSAGE_CON  USING 'E'
              TEXT-E91 " 'Activity (-) 시간이 기존 실적처리된 기계시간보다 작아 처리할 수 없습니다.
              '  '
              '  '
              PV_EXTID.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.
  "액티비티 3 확정 단위 점검
  IF GS_CON-ILE03 <> LS_TT-CONF_ACTI_UNIT3.
    PERFORM RETURN_MESSAGE_CON  USING 'E'
            TEXT-E87 "''액티비티 확정 단위가 생산오더와 다릅니다.'
            '  '
            '  '
            PV_EXTID.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.
  IF GS_CON-ISM03 < 0.
    READ TABLE GT_AFRU_SUM WITH KEY GRUND = ''.
    IF SY-SUBRC = 0.
      IF GT_AFRU_SUM-ISM03 < ABS( GS_CON-ISM03 ).
        PERFORM RETURN_MESSAGE_CON  USING 'E'
                TEXT-E92 " 'Activity (-) 시간이 기존 실적처리된 제조지원시간보다 작아 처리할 수 없습니다.
                '  '
                '  '
                PV_EXTID.
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ELSE.
      PERFORM RETURN_MESSAGE_CON  USING 'E'
              TEXT-E92 " 'Activity (-) 시간이 기존 실적처리된 제조지원시간보다 작아 처리할 수 없습니다.
              '  '
              '  '
              PV_EXTID.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.
  "액티비티 4 확정 단위 점검
  IF GS_CON-ILE04 <> LS_TT-CONF_ACTI_UNIT4.
    PERFORM RETURN_MESSAGE_CON  USING 'E'
            TEXT-E87 "''액티비티 확정 단위가 생산오더와 다릅니다.'
            '  '
            '  '
            PV_EXTID.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.
  IF GS_CON-ISM04 < 0.
    READ TABLE GT_AFRU_SUM WITH KEY GRUND = ''.
    IF SY-SUBRC = 0.
      IF GT_AFRU_SUM-ISM04 < ABS( GS_CON-ISM04 ).
        PERFORM RETURN_MESSAGE_CON  USING 'E'
               TEXT-E93 " 'Activity (-) 시간이 기존 실적처리된 제조직접시간보다 작아 처리할 수 없습니다.
               '  '
               '  '
               PV_EXTID.
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ELSE.
      PERFORM RETURN_MESSAGE_CON  USING 'E'
              TEXT-E93 " 'Activity (-) 시간이 기존 실적처리된 제조직접시간보다 작아 처리할 수 없습니다.
              '  '
              '  '
              PV_EXTID.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.
  "액티비티 5 확정 단위 점검
  IF GS_CON-ILE05 <> LS_TT-CONF_ACTI_UNIT5.
    PERFORM RETURN_MESSAGE_CON  USING 'E'
            TEXT-E87 "''액티비티 확정 단위가 생산오더와 다릅니다.'
            '  '
            '  '
            PV_EXTID.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.
  IF GS_CON-ISM05 < 0.
    READ TABLE GT_AFRU_SUM WITH KEY GRUND = ''.
    IF SY-SUBRC = 0.
      IF GT_AFRU_SUM-ISM05 < ABS( GS_CON-ISM05 ).
        PERFORM RETURN_MESSAGE_CON  USING 'E'
               TEXT-E94 " 'Activity (-) 시간이 기존 실적처리된 배부직접시간보다 작아 처리할 수 없습니다.
               '  '
               '  '
               PV_EXTID.
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ELSE.
      PERFORM RETURN_MESSAGE_CON  USING 'E'
              TEXT-E94 " 'Activity (-) 시간이 기존 실적처리된 배부직접시간보다 작아 처리할 수 없습니다.
              '  '
              '  '
              PV_EXTID.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.
  "액티비티 6 확정 단위 점검
  IF GS_CON-ILE06 <> LS_TT-CONF_ACTI_UNIT6.
    PERFORM RETURN_MESSAGE_CON  USING 'E'
            TEXT-E87 "''액티비티 확정 단위가 생산오더와 다릅니다.'
            '  '
            '  '
            PV_EXTID.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.
  IF GS_CON-ISM06 < 0.
    READ TABLE GT_AFRU_SUM WITH KEY GRUND = ''.
    IF SY-SUBRC = 0.
      IF GT_AFRU_SUM-ISM06 < ABS( GS_CON-ISM06 ).
        PERFORM RETURN_MESSAGE_CON  USING 'E'
               TEXT-E95 " 'Activity (-) 시간이 기존 실적처리된 노무시간보다 작아 처리할 수 없습니다.
               '  '
               '  '
               PV_EXTID.
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ELSE.
      PERFORM RETURN_MESSAGE_CON  USING 'E'
              TEXT-E95 " 'Activity (-) 시간이 기존 실적처리된 노무시간보다 작아 처리할 수 없습니다.
              '  '
              '  '
              PV_EXTID.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.
  "액티비티 7 확정 단위 점검_가동준비
  IF GS_CON-ILE07 <> LS_TT-CONF_ACTI_UNIT1.
    PERFORM RETURN_MESSAGE_CON  USING 'E'
            TEXT-E87 "''액티비티 확정 단위가 생산오더와 다릅니다.'
            '  '
            '  '
            PV_EXTID.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.
  IF GS_CON-ISM07 < 0.
    READ TABLE GT_AFRU_SUM WITH KEY GRUND = 'CH01'.
    IF SY-SUBRC = 0.
      IF GT_AFRU_SUM-ISM01 < ABS( GS_CON-ISM07 ).
        PERFORM RETURN_MESSAGE_CON  USING 'E'
               TEXT-E96 " 'Activity (-) 시간이 기존 실적처리된 예압시간보다 작아 처리할 수 없습니다.
               '  '
               '  '
               PV_EXTID.
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ELSE.
      PERFORM RETURN_MESSAGE_CON  USING 'E'
              TEXT-E96 " 'Activity (-) 시간이 기존 실적처리된 예압시간보다 작아 처리할 수 없습니다.
              '  '
              '  '
              PV_EXTID.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.
  "액티비티 8 확정 단위 점검_가동준비
  IF GS_CON-ILE08 <> LS_TT-CONF_ACTI_UNIT2.
    PERFORM RETURN_MESSAGE_CON  USING 'E'
            TEXT-E87 "''액티비티 확정 단위가 생산오더와 다릅니다.'
            '  '
            '  '
            PV_EXTID.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.
  IF GS_CON-ISM08 < 0.
    READ TABLE GT_AFRU_SUM WITH KEY GRUND = 'RW01'.
    IF SY-SUBRC = 0.
      IF GT_AFRU_SUM-ISM02 < ABS( GS_CON-ISM08 ).
        PERFORM RETURN_MESSAGE_CON  USING 'E'
               TEXT-E97 " 'Activity (-) 시간이 기존 실적처리된 수리시간보다 작아 처리할 수 없습니다.
               '  '
               '  '
               PV_EXTID.
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ELSE.
      PERFORM RETURN_MESSAGE_CON  USING 'E'
              TEXT-E97 " 'Activity (-) 시간이 기존 실적처리된 수리시간보다 작아 처리할 수 없습니다.
              '  '
              '  '
              PV_EXTID.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.
  "액티비티 9 확정 단위 점검_가동준비
  IF GS_CON-ILE09 <> LS_TT-CONF_ACTI_UNIT2.
    PERFORM RETURN_MESSAGE_CON  USING 'E'
            TEXT-E87 "''액티비티 확정 단위가 생산오더와 다릅니다.'
            '  '
            '  '
            PV_EXTID.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.
  IF GS_CON-ISM09 < 0.
    READ TABLE GT_AFRU_SUM WITH KEY GRUND = 'CH02'.
    IF SY-SUBRC = 0.
      IF GT_AFRU_SUM-ISM02 < ABS( GS_CON-ISM09 ).
        PERFORM RETURN_MESSAGE_CON  USING 'E'
               TEXT-E98 " 'Activity (-) 시간이 기존 실적처리된 Start 여장 작업시간보다 작아 처리할 수 없습니다.
               '  '
               '  '
               PV_EXTID.
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ELSE.
      PERFORM RETURN_MESSAGE_CON  USING 'E'
              TEXT-E98 " 'Activity (-) 시간이 기존 실적처리된 Start 여장 작업시간보다 작아 처리할 수 없습니다.
              '  '
              '  '
              PV_EXTID.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.
  "액티비티 10 확정 단위 점검_가동준비
  IF GS_CON-ILE10 <> LS_TT-CONF_ACTI_UNIT2.
    PERFORM RETURN_MESSAGE_CON  USING 'E'
                TEXT-E87 "''액티비티 확정 단위가 생산오더와 다릅니다.'
                '  '
                '  '
                PV_EXTID.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.
  IF GS_CON-ISM10 < 0.
    READ TABLE GT_AFRU_SUM WITH KEY GRUND = 'CH03'.
    IF SY-SUBRC = 0.
      IF GT_AFRU_SUM-ISM02 < ABS(  GS_CON-ISM10 ).
        PERFORM RETURN_MESSAGE_CON  USING 'E'
                TEXT-E99 " 'Activity (-) 시간이 기존 실적처리된 End 여장 작업 시간보다 작아 처리할 수 없습니다.
                '  '
                '  '
                PV_EXTID.
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ELSE.
      PERFORM RETURN_MESSAGE_CON  USING 'E'
              TEXT-E99 " 'Activity (-) 시간이 기존 실적처리된 End 여장 작업 시간시간보다 작아 처리할 수 없습니다.
              '  '
              '  '
              PV_EXTID.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.

  CASE PV_CASE.
    WHEN 'A'.
      CLEAR : LT_RETURN, LS_TT, LT_TT[].
      LT_TT = VALUE #( ( ORDERID    = GS_CON-AUFNR
                         OPERATION  = GS_CON-VORNR
                         POSTG_DATE = GS_CON-BUDAT
                         PLANT      = GS_CON-WERKS
                         YIELD      = GS_CON-LMNGA
                         EX_IDENT   = PV_EXTID
                         WORK_CNTR  = GS_CON-ARBPL
*                         scrap      = gs_con-xmnga
*                         rework     = gs_con-rmnga
                          ) ).
*    - 생산오더의 실적처리 전 참조값 바피 호출
      CALL FUNCTION 'BAPI_PRODORDCONF_GET_TT_PROP'
        EXPORTING
          PROPOSE        = LS_PROPOSE
        TABLES
          TIMETICKETS    = LT_TT
          GOODSMOVEMENTS = PT_GOODSMOVEMENTS
          DETAIL_RETURN  = LT_RETURN.

      LS_TT = VALUE #( LT_TT[ 1 ] OPTIONAL ).

*- 단위 비교
*- 작업장
*  IF GS_CON-ARBPL <> LS_TT-WORK_CNTR.
*
*    PERFORM RETURN_MESSAGE_CON  USING 'E'
*                                     '작업장이 생산오더와 다릅니다.'
*                                     '  '
*                                     '  '.
*    PV_ERROR = 'X'.
*    EXIT.
*  ENDIF.

*    - 확정 수량 단위
      IF GS_CON-MEINH <> LS_TT-CONF_QUAN_UNIT.
        PERFORM RETURN_MESSAGE_CON  USING 'E'
                TEXT-E90 "'확정 수량 단위가 생산오더와 다릅니다.'
                '  '
                '  '
                PV_EXTID.
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.


    WHEN 'B'.
      CLEAR : LT_RETURN, LS_TT, LT_TT[].
      LT_TT = VALUE #( ( ORDERID    = GS_CON-AUFNR
                         OPERATION  = GS_CON-VORNR
                         POSTG_DATE = GS_CON-BUDAT
                         PLANT      = GS_CON-WERKS
*                         yield      = gs_con-lmnga
                         EX_IDENT   = PV_EXTID
                         WORK_CNTR  = GS_CON-ARBPL
                         SCRAP      = GS_CON-XMNGA
*                         rework     = gs_con-rmnga
                          ) ).
*    - 생산오더의 실적처리 전 참조값 바피 호출
      CALL FUNCTION 'BAPI_PRODORDCONF_GET_TT_PROP'
        EXPORTING
          PROPOSE        = LS_PROPOSE
        TABLES
          TIMETICKETS    = LT_TT
          GOODSMOVEMENTS = PT_GOODSMOVEMENTS
          DETAIL_RETURN  = LT_RETURN.

      LS_TT = VALUE #( LT_TT[ 1 ] OPTIONAL ).
    WHEN 'C'.

    WHEN 'D'.
      CLEAR : LT_RETURN, LS_TT, LT_TT[].
      LT_TT = VALUE #( ( ORDERID    = GS_CON-AUFNR
                         OPERATION  = GS_CON-VORNR
                         POSTG_DATE = GS_CON-BUDAT
                         PLANT      = GS_CON-WERKS
                         YIELD      = GS_CON-SMNGA
                         EX_IDENT   = PV_EXTID
                         WORK_CNTR  = GS_CON-ARBPL
*                         scrap      = gs_con-xmnga
*                         rework     = gs_con-rmnga
                          ) ).
*    - 생산오더의 실적처리 전 참조값 바피 호출
      CALL FUNCTION 'BAPI_PRODORDCONF_GET_TT_PROP'
        EXPORTING
          PROPOSE        = LS_PROPOSE
        TABLES
          TIMETICKETS    = LT_TT
          GOODSMOVEMENTS = PT_GOODSMOVEMENTS
          DETAIL_RETURN  = LT_RETURN.

      LS_TT = VALUE #( LT_TT[ 1 ] OPTIONAL ).
    WHEN 'E'.
      CLEAR : LT_RETURN, LS_TT, LT_TT[].
      LT_TT = VALUE #( ( ORDERID    = GS_CON-AUFNR
                         OPERATION  = GS_CON-VORNR
                         POSTG_DATE = GS_CON-BUDAT
                         PLANT      = GS_CON-WERKS
                         YIELD      = GS_CON-EMNGA
                         EX_IDENT   = PV_EXTID
                         WORK_CNTR  = GS_CON-ARBPL
*                         scrap      = gs_con-xmnga
*                         rework     = gs_con-rmnga
                          ) ).
*    - 생산오더의 실적처리 전 참조값 바피 호출
      CALL FUNCTION 'BAPI_PRODORDCONF_GET_TT_PROP'
        EXPORTING
          PROPOSE        = LS_PROPOSE
        TABLES
          TIMETICKETS    = LT_TT
          GOODSMOVEMENTS = PT_GOODSMOVEMENTS
          DETAIL_RETURN  = LT_RETURN.

      LS_TT = VALUE #( LT_TT[ 1 ] OPTIONAL ).

  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_INPUT_CON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONVERSION_INPUT_CON .


  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = GS_CON-AUFNR
    IMPORTING
      OUTPUT = GS_CON-AUFNR.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = GS_CON-VORNR
    IMPORTING
      OUTPUT = GS_CON-VORNR.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = GS_CON-RU_EXTID
    IMPORTING
      OUTPUT = GS_CON-RU_EXTID.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_OUTPUT_GT_GR_RESULT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONVERSION_OUTPUT_GT_GR_RESULT .

  LOOP AT GT_GR_RESULT INTO DATA(LS_RESULT).

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LS_RESULT-AUFNR
      IMPORTING
        OUTPUT = LS_RESULT-AUFNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LS_RESULT-RUECK
      IMPORTING
        OUTPUT = LS_RESULT-RUECK.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LS_RESULT-RMZHL
      IMPORTING
        OUTPUT = LS_RESULT-RMZHL.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LS_RESULT-RU_EXTID
      IMPORTING
        OUTPUT = LS_RESULT-RU_EXTID.

    MODIFY GT_GR_RESULT FROM LS_RESULT.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STATUS_CON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_ERROR
*&---------------------------------------------------------------------*
FORM GET_STATUS_CON   USING  PV_ERROR.

  DATA : LV_LINE  TYPE CHAR100,
         LV_OBJNR TYPE JEST-OBJNR.
  DATA : BEGIN OF LS_LINE,
           LINE TYPE CHAR100,
         END OF LS_LINE,
         LT_LINE LIKE TABLE OF LS_LINE.

  CLEAR : LV_OBJNR, LV_LINE, LS_LINE, LT_LINE.


*- 오더 상태 펑션
*  lv_objnr = |OR{ gs_con-aufnr }|.
*
*  CALL FUNCTION 'STATUS_TEXT_EDIT'
*    EXPORTING
*      objnr            = lv_objnr
*      only_active      = 'X'
*      spras            = sy-langu
*    IMPORTING
*      line             = lv_line "오더상태
*    EXCEPTIONS
*      object_not_found = 1
*      OTHERS           = 2.

  CALL FUNCTION 'Z_PP_ORDER_STATUS'
    EXPORTING
      I_AUFNR  = GS_CON-AUFNR
    IMPORTING
      E_STATUS = LV_LINE.


*- 오더상태는 CRTD/TECO/DLF 중 일치하는 것이 있으면 에러처리.
  IF SY-SUBRC = 0.
    SPLIT LV_LINE AT ' ' INTO TABLE LT_LINE.

    LOOP AT LT_LINE INTO LS_LINE WHERE LINE IS NOT INITIAL.

      IF LS_LINE-LINE = 'CRTD' OR
         LS_LINE-LINE = 'TECO' OR
         LS_LINE-LINE = 'DLF'.

        PV_ERROR = 'X'.
        EXIT.

      ELSE.
        CLEAR LS_LINE.
        CONTINUE.
      ENDIF.

    ENDLOOP.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESULT_GR_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ZO_RESULT
*&      --> ZO_MESSAGE
*&---------------------------------------------------------------------*
FORM RESULT_GR_DATA   USING  PO_RESULT
                             PO_MESSAGE
                             PV_BAPI_FLAG.

  DATA : LV_MESSAGE(80),
         LV_RESULT(2).
  CLEAR : LV_MESSAGE, LV_RESULT.

  IF GT_GR_RESULT IS NOT INITIAL
     AND PV_BAPI_FLAG <> 'N'.

*- 전체 건수
    DATA(LV_CNT_T) = REDUCE I(
                     INIT SUM = 0 FOR LS_CNT_T IN GT_GR_RESULT
*                     WHERE ( zerp_stat = 'S' )
                     NEXT SUM = SUM + 1 ).

*- 성공 건수
    DATA(LV_CNT_S) = REDUCE I(
                     INIT SUM = 0 FOR LS_CNT_S IN GT_GR_RESULT
                     WHERE ( ZERP_STAT = 'S' )
                     NEXT SUM = SUM + 1 ).

*- 실패 건수
    DATA(LV_CNT_E) = REDUCE I(
                     INIT SUM = 0 FOR LS_CNT_E IN GT_GR_RESULT
                     WHERE ( ZERP_STAT = 'E' )
                     NEXT SUM = SUM + 1 ).

    "전체 성공
    IF LV_CNT_S IS NOT INITIAL AND
       LV_CNT_E IS INITIAL.

      LV_RESULT = '00'.
      LV_MESSAGE = |전체{ LV_CNT_T }건 중 { LV_CNT_S }건 처리 성공|.

      "전체 실패
    ELSEIF LV_CNT_S IS INITIAL AND
           LV_CNT_E IS NOT INITIAL.

      LV_RESULT = '01'.
      LV_MESSAGE = |전체{ LV_CNT_T }건 중 { LV_CNT_E }건 처리 실패|.

      "부분 성공
    ELSE.

      LV_RESULT = '01'.
      LV_MESSAGE = |전체{ LV_CNT_T }건 중 { LV_CNT_S }건 처리 성공, { LV_CNT_E }건 처리 실패|.

    ENDIF.

*- 처리 결과
    PO_RESULT  = LV_RESULT.
    PO_MESSAGE = LV_MESSAGE.

  ELSE.

    LV_RESULT = '01'.
    LV_MESSAGE = '실적 처리할 데이터가 없습니다'.

*- 처리 결과
    PO_RESULT  = LV_RESULT.
    PO_MESSAGE = LV_MESSAGE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RETURN_MESSAGE_CON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> LS_DETAIL_MESSAGE
*&      --> LS_DETAIL_CONF_NO
*&      --> LS_DETAIL_CONF_CNT
*&---------------------------------------------------------------------*
FORM RETURN_MESSAGE_CON  USING   PV_FLAG
                                 PV_MESSAGE
                                 PV_RUECK
                                 PV_RMZHL
                                 PV_EXTID.

  CLEAR : GT_GR_RESULT[], GT_GR_RESULT.
  GT_GR_RESULT = VALUE #(  BASE GT_GR_RESULT
                        (   AUFNR  = GS_CON-AUFNR
                            ZSERNO = GS_CON-ZSERNO
                            RUECK  = PV_RUECK    "BAPI에서 리턴된 확정 번호
                            RMZHL  = PV_RMZHL    "BAPI에서 리턴된 확정 카운터
                            RU_EXTID  = PV_EXTID
                            ZERP_STAT  = PV_FLAG
                            ZERP_MESSAGE  = PV_MESSAGE ) ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_LOG_CON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> LV_MESSAGE
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SAVE_LOG_CON  USING PV_FLAG
                          PV_MESSAGE
                          PV_RUECK
                          PV_RMZHL
                          PV_EXTID
                          PV_TIMESTAMP
                          PV_SYSTEM_ID
                          PV_MODE.

  DATA : LT_ZGTPPT3080 TYPE TABLE OF ZGTPPT3080.
*  DATA  : lv_timestamp TYPE timestampl.
  CLEAR : LT_ZGTPPT3080.


*  GET TIME STAMP FIELD lv_timestamp.

  GT_ZGTPPT3080 = VALUE #( ( VALUE #( BASE CORRESPONDING #( GS_CON MAPPING ZC_RUECK = RUECK
                                                                         ZC_RMZHL = RMZHL )
                           ZIFKEY  = PV_TIMESTAMP
                           I_MODE  = PV_MODE
                           RUECK   = PV_RUECK "BAPI에서 리턴된 확정 번호
                           RMZHL   = PV_RMZHL "BAPI에서 리턴된 확정 카운터
                           RU_EXTID =  PV_EXTID
                           ZSYSTEM_ID = PV_SYSTEM_ID
                           ZERP_STAT = PV_FLAG
                           ZERP_MESSAGE    = PV_MESSAGE
                           IFNAM  = SY-UNAME
                           IFDAT  = SY-DATUM
                           IFTIM  = SY-UZEIT
                       ) ) ).


***  MODIFY zgtppt3080 FROM TABLE lt_zgtppt3080.
***  IF sy-subrc = 0.
***    COMMIT WORK.
***  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_COMMON_ORDER_STATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_FIN_CONF
*&---------------------------------------------------------------------*
FORM CHECK_COMMON_ORDER_STATE  USING    PV_FIN_CONF
                                        PV_CLEAR_RES
                                        PV_CASE.

  DATA : LV_AUFNR LIKE AFRU-AUFNR,
         LV_VORNR LIKE AFRU-VORNR,
         LV_AUERU LIKE AFRU-AUERU.

  SELECT SINGLE AUERU
    INTO @LV_AUERU
    FROM AFRU
    WHERE AUFNR = @GS_CON-AUFNR
      AND STOKZ = ''
      AND STZHL = ''
      AND VORNR IN ( SELECT MAX( VORNR )
                       FROM AFRU
                      WHERE AUFNR = @GS_CON-AUFNR
                        AND STOKZ = ''
                        AND STZHL = '' ).

  CASE PV_CASE.
    WHEN 'A'.
      IF LV_AUERU = 'X'. "최종 확정 상태가 지정되어 있다
        PV_FIN_CONF = 'X'.
      ELSE.
        PV_FIN_CONF = ''.
      ENDIF.
    WHEN 'B'.
      IF LV_AUERU = 'X'. "최종 확정 상태가 지정되어 있다
        PV_FIN_CONF = 'X'.
        PV_CLEAR_RES = 'X'.
      ELSE.
        PV_FIN_CONF = ''.
      ENDIF.
    WHEN 'C'.
      IF LV_AUERU = 'X'. "최종 확정 상태가 지정되어 있다
        PV_FIN_CONF = 'X'.
        PV_CLEAR_RES = 'X'.
      ELSE.
        PV_FIN_CONF = ''.
      ENDIF.
    WHEN 'D'.
      IF LV_AUERU = 'X'. "최종 확정 상태가 지정되어 있다
        PV_FIN_CONF = 'X'.
        PV_CLEAR_RES = 'X'.
      ELSE.
        PV_FIN_CONF = ''.
      ENDIF.
    WHEN 'E'.
      IF LV_AUERU = 'X'. "최종 확정 상태가 지정되어 있다
        PV_FIN_CONF = 'X'.
        PV_CLEAR_RES = 'X'.
      ELSE.
        PV_FIN_CONF = ''.
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_IDKEY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_EXTID
*&---------------------------------------------------------------------*
FORM CREATE_IDKEY  USING    PV_EXTID.

  DATA : LV_EXTID       LIKE AFRU-EXTID,
         LV_EXTID_C(32),
         LV_EXTID_N(32) TYPE N,
         LV_STR         TYPE STRING,
         LV_EXTID32(32).

  SELECT SINGLE EXTID
    INTO @LV_EXTID
    FROM AFRU
    WHERE AUFNR = @GS_CON-AUFNR
      AND EXTID IN ( SELECT MAX( EXTID )
                       FROM AFRU
                      WHERE AUFNR = @GS_CON-AUFNR ).

**  CALL FUNCTION 'ECATT_CONV_XSTRING_TO_STRING'
**    EXPORTING
**      im_xstring  = lv_extid
***      im_encoding = ‘DEFAULT’
**    IMPORTING
**      ex_string   = lv_str.
  LV_EXTID_C = LV_EXTID.
  IF ( LV_EXTID_C  <> '00000000000000000000000000000000').

*SRM2601-14984 순번 3->5자리로 변경
    IF LV_EXTID_C+17(12) = GS_CON-AUFNR.     "순번이 3자리인 경우
      LV_EXTID_C+15(12) =  LV_EXTID_C+17(12).
      LV_EXTID_C+27(2) = '00'.
      LV_EXTID_C+29(3) = LV_EXTID_C+29(3).
    ENDIF.
*SRM2601-14984

    LV_EXTID_N = LV_EXTID_C.
    LV_EXTID_N = LV_EXTID_N + 1.
    LV_EXTID32 = LV_EXTID_N .
    CONCATENATE GS_CON-AUFNR LV_EXTID32+27(5)
           INTO PV_EXTID.

  ELSE.
    LV_EXTID_C = '00000000000000000000000000000001'.
    LV_EXTID32 = LV_EXTID_C .
    CONCATENATE GS_CON-AUFNR LV_EXTID32+27(5)
           INTO PV_EXTID.
  ENDIF.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = PV_EXTID
    IMPORTING
      OUTPUT = PV_EXTID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIN_CONF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_FIN_CONF
*&---------------------------------------------------------------------*
FORM SET_FIN_CONF  USING    PV_FIN_CONF
                            PV_CLEAR_RES
                            PV_CASE.

  DATA : LV_AUFNR     LIKE AFRU-AUFNR,
         LV_VORNR     LIKE AFRU-VORNR,
         LV_LMNGA_SUM LIKE AFRU-LMNGA,
         LV_LMNGA_TOT LIKE AFRU-LMNGA,
         LV_AUERU     LIKE AFRU-AUERU.

  CASE PV_CASE.

    WHEN 'A'.

      SELECT VORNR, SMENG, LMNGA, STOKZ, STZHL
        INTO CORRESPONDING FIELDS OF TABLE @GT_AFRU
        FROM AFRU
        WHERE AUFNR = @GS_CON-AUFNR
          AND STOKZ = ''
          AND STZHL = ''
          AND GRUND = ''.
      SORT GT_AFRU BY VORNR DESCENDING.

      IF GT_AFRU[] IS NOT INITIAL.
        CLEAR :LV_LMNGA_SUM.
        "확인 대상 수율 C총 합계를 구한다
        LOOP AT GT_AFRU.
          LV_LMNGA_SUM = LV_LMNGA_SUM + GT_AFRU-LMNGA.
        ENDLOOP.

        SORT GT_AFRU BY VORNR DESCENDING.
        READ TABLE GT_AFRU INDEX 1.
        IF SY-SUBRC = 0.
          " 최종 확정 지시자(FIN_CONF) 'X' :
          " SUM(LMNGA) + I/F받은 LMNGA >= SMNGA(단일 값)
          " FIN_CONF = 'X'이면, CLEAR_RES 또한 'X'로 처리
          IF ( LV_LMNGA_SUM + GT_AFRU-LMNGA ) => GT_AFRU-SMENG.
            PV_FIN_CONF  = 'X'.
            PV_CLEAR_RES = 'X'.
          ELSE.
            PV_FIN_CONF = ''.
          ENDIF.
        ENDIF.

      ENDIF.

    WHEN 'B' OR 'C' OR 'D' OR 'E'.

      SELECT VORNR, SMENG, LMNGA, STOKZ, STZHL
        INTO CORRESPONDING FIELDS OF TABLE @GT_AFRU
        FROM AFRU
        WHERE AUFNR = @GS_CON-AUFNR
          AND STOKZ = ''
          AND STZHL = ''
          AND VORNR IN ( SELECT MAX( VORNR )
                           FROM AFRU
                          WHERE AUFNR = @GS_CON-AUFNR
                            AND STOKZ = ''
                            AND STZHL = '' ).
      SORT GT_AFRU BY VORNR DESCENDING.

      IF GT_AFRU[] IS NOT INITIAL.

        SORT GT_AFRU BY VORNR DESCENDING.
        READ TABLE GT_AFRU INDEX 1.
        IF SY-SUBRC = 0.
          " 기존 최종 확정 지시자 확인하여 AUERU = 'X'이면,
          " FIN_CONF에 'X' 대입
          IF GT_AFRU-AUERU = 'X'.
            PV_FIN_CONF  = 'X'.
            PV_CLEAR_RES = 'X'.
          ELSE.
            PV_FIN_CONF = ''.
          ENDIF.
        ENDIF.

      ENDIF.


  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_ism06
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_ISMVAL  USING  PV_ISMVAL PV_CASE PV_AUART PV_SYSTEM_ID.

***  DATA : lv_auart TYPE aufk-auart.
***
***  SELECT SINGLE auart
***    INTO lv_auart
***    FROM aufk
***   WHERE aufnr = gs_con-aufnr.

  IF PV_AUART EQ 'RW01' AND GV_GAON NE ABAP_TRUE.
    IF PV_CASE = 'C'.
      PV_ISMVAL = GS_CON-ISM07.
    ELSE.
      PV_ISMVAL = 0.
    ENDIF.
  ELSE.
    CASE PV_CASE.
      WHEN 'A'.

        SELECT B~VGW02, B~VGW06, B~VGE06
          INTO CORRESPONDING FIELDS OF TABLE @GT_AFVV
          FROM AFKO AS A INNER JOIN AFVV AS B
                         ON A~AUFPL = B~AUFPL
          WHERE A~AUFNR = @GS_CON-AUFNR
            AND B~MGVRG > 0  .

        READ TABLE GT_AFVV INDEX 1.
        IF SY-SUBRC = 0.
          IF GT_AFVV-VGW02 <> 0
             AND GT_AFVV-VGW06  <> 0
             AND GS_CON-ISM02  <> 0.
            PV_ISMVAL = GS_CON-ISM02 * GT_AFVV-VGW06 / GT_AFVV-VGW02.
          ELSE.
            PV_ISMVAL = 0.
          ENDIF.
        ENDIF.

      WHEN 'B'.

        SELECT B~VGW02, B~VGW06, B~VGE06
          INTO CORRESPONDING FIELDS OF TABLE @GT_AFVV
          FROM AFKO AS A INNER JOIN AFVV AS B
                         ON A~AUFPL = B~AUFPL
          WHERE A~AUFNR = @GS_CON-AUFNR
            AND B~MGVRG > 0  .

        READ TABLE GT_AFVV INDEX 1.
        IF SY-SUBRC = 0.
          IF GT_AFVV-VGW02 <> 0
             AND GT_AFVV-VGW06  <> 0
             AND GS_CON-ISM08  <> 0.                        "20241220
            "ISM06 = I/F 수신 ISM08 * AFVV-VGW06 / AFVV-VGW02
            PV_ISMVAL = GS_CON-ISM08 * GT_AFVV-VGW06 / GT_AFVV-VGW02.
          ELSE.
            PV_ISMVAL = 0.
          ENDIF.
        ENDIF.

      WHEN 'C'.

        PV_ISMVAL = GS_CON-ISM07.

      WHEN 'D'.

        SELECT B~VGW02, B~VGW06, B~VGE06
          INTO CORRESPONDING FIELDS OF TABLE @GT_AFVV
          FROM AFKO AS A INNER JOIN AFVV AS B
                         ON A~AUFPL = B~AUFPL
          WHERE A~AUFNR = @GS_CON-AUFNR
            AND B~MGVRG > 0  .

        READ TABLE GT_AFVV INDEX 1.
        IF SY-SUBRC = 0.
          IF GT_AFVV-VGW02 <> 0
             AND GT_AFVV-VGW06  <> 0
             AND GS_CON-ISM09  <> 0.                        "20241220
            "ISM06 = I/F 수신 ISM08 * AFVV-VGW06 / AFVV-VGW02
            PV_ISMVAL = GS_CON-ISM09 * GT_AFVV-VGW06 / GT_AFVV-VGW02.
          ELSE.
            PV_ISMVAL = 0.
          ENDIF.
        ENDIF.

      WHEN 'E'.

        SELECT B~VGW02, B~VGW06, B~VGE06
          INTO CORRESPONDING FIELDS OF TABLE @GT_AFVV
          FROM AFKO AS A INNER JOIN AFVV AS B
                         ON A~AUFPL = B~AUFPL
          WHERE A~AUFNR = @GS_CON-AUFNR
            AND B~MGVRG > 0  .

        READ TABLE GT_AFVV INDEX 1.
        IF SY-SUBRC = 0.
          IF GT_AFVV-VGW02 <> 0
             AND GT_AFVV-VGW06  <> 0
             AND GS_CON-ISM10  <> 0.                        "20241220
            "ISM06 = I/F 수신 ISM08 * AFVV-VGW06 / AFVV-VGW02
            PV_ISMVAL = GS_CON-ISM10 * GT_AFVV-VGW06 / GT_AFVV-VGW02.
          ELSE.
            PV_ISMVAL = 0.
          ENDIF.
        ENDIF.

    ENDCASE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_prodordconf_create_tt_b
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_GOODSMOVEMENTS
*&      --> LV_FIN_CONF
*&      --> LV_CLEAR_RES
*&      --> LV_ISM06
*&      --> LV_EXTID
*&      --> LV_BAPI_FLAG
*&---------------------------------------------------------------------*
FORM BAPI_PRODORDCONF_CREATE_TT_B  TABLES PT_GOODSMOVEMENTS
                                STRUCTURE BAPI2017_GM_ITEM_CREATE
                                  USING PV_FIN_CONF
                                        PV_CLEAR_RES
                                        PV_ISM08
                                        PV_EXTID
                                        PV_BAPI_FLAG
                                        PV_TIMESTAMP
                                        PV_SYSTEM_ID
                                        PV_MODE
                                        PV_COUNT TYPE N.


  DATA: LT_TT      TYPE TABLE OF BAPI_PP_TIMETICKET,
        LT_GOODS   TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_DETAIL  TYPE TABLE OF BAPI_CORU_RETURN,
        LS_DETAIL  TYPE BAPI_CORU_RETURN,
        LS_RETURN  TYPE BAPIRET1,
        LV_MESSAGE TYPE BAPI_CORU_RETURN-MESSAGE.
  DATA : LT_RETURN         LIKE TABLE OF BAPIRET1,
         LV_RUECK          TYPE BAPI_PP_CONF_KEY-CONF_NO,
         LV_RMZHL          TYPE BAPI_PP_CONF_KEY-CONF_CNT,
         LV_EXTID(32),
         LV_CANCEL_FLAG(1).

  CLEAR : LT_TT, LT_GOODS, LT_DETAIL, LS_RETURN, LV_MESSAGE, LS_DETAIL.


  LT_TT = VALUE #( ( ORDERID         = GS_CON-AUFNR
                     OPERATION       = GS_CON-VORNR
                     FIN_CONF        = PV_FIN_CONF
                     CLEAR_RES       = PV_CLEAR_RES
                     POSTG_DATE      = GS_CON-BUDAT
                     DEV_REASON      = 'RW01'
                     PLANT           = GS_CON-WERKS
                     WORK_CNTR       = GS_CON-ARBPL
                     YIELD           = '' " 공란
                     SCRAP           = GS_CON-XMNGA
                     REWORK          = '' " 공란
                     CONF_TEXT       = '' " 공란
                     CONF_ACTIVITY1  = '' " 공란
                     CONF_ACTI_UNIT1 = GS_CON-ILE01
                     CONF_ACTIVITY2  = '' " 공란
                     CONF_ACTI_UNIT2 = GS_CON-ILE02
                     CONF_ACTIVITY3  = '' " 공란
                     CONF_ACTI_UNIT3 = GS_CON-ILE03
                     CONF_ACTIVITY4  = '' " 공란
                     CONF_ACTI_UNIT4 = GS_CON-ILE04
                     CONF_ACTIVITY5  = '' " 공란
                     CONF_ACTI_UNIT5 = GS_CON-ILE05
                     CONF_ACTIVITY6  = '' " 공란
                     CONF_ACTI_UNIT6 = GS_CON-ILE06
                     EXEC_START_DATE = GS_CON-ISDD
                     EXEC_START_TIME = GS_CON-ISDZ
                     PROC_FIN_DATE   = GS_CON-IEDD
                     PROC_FIN_TIME   = GS_CON-IEDZ
                     EX_IDENT        = PV_EXTID
                     PERS_NO         = GS_CON-PERNR   ) ).

*- 생산 실적 처리
  CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
    IMPORTING
      RETURN         = LS_RETURN
    TABLES
      TIMETICKETS    = LT_TT
      GOODSMOVEMENTS = PT_GOODSMOVEMENTS
      DETAIL_RETURN  = LT_DETAIL.
*  WAIT UP TO 2 SECONDS.
*- 성공
  IF LS_RETURN IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    LS_DETAIL = VALUE #( LT_DETAIL[ 1 ] OPTIONAL ).

    PERFORM RETURN_MESSAGE_CON_C  USING 'S'
                                      LS_DETAIL-MESSAGE
                                      LS_DETAIL-CONF_NO
                                      LS_DETAIL-CONF_CNT
                                      PV_EXTID.

    PERFORM SAVE_LOG_CON  USING 'S'
                                LS_DETAIL-MESSAGE
                                LS_DETAIL-CONF_NO
                                LS_DETAIL-CONF_CNT
                                PV_EXTID
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE.

****- 생산오더 전송 프로그램 호출(zgtppi2010)
***    PERFORM call_transaction_zgtppi2010.

    PV_BAPI_FLAG = 'B'.
*- 실패
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*- 확정 외부 ID KEY 생성
    CLEAR : LV_EXTID.
    LV_EXTID = GS_CON-RU_EXTID.
    LOOP AT   GT_GR_RESULT_C INTO  GS_GR_RESULT_C .

      PERFORM BAPI_PRODORDCONF_CANCEL TABLES LT_RETURN
                                      USING GS_GR_RESULT_C-RUECK
                                            GS_GR_RESULT_C-RMZHL
                                            GS_CON-BUDAT
                                            LV_RUECK
                                            LV_RMZHL
                                            LV_CANCEL_FLAG.
      IF LV_CANCEL_FLAG = 'E'.

*          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*          READ TABLE lt_return INTO DATA(ls_return)  WITH KEY type = 'E'.
*          IF sy-subrc = 0.
        IF LV_RUECK IS INITIAL.
          PERFORM RETURN_MESSAGE_CON  USING 'E'
*                                              ls_return-message
                                           TEXT-M04
                                            '  '
                                            '  '
                                            LV_EXTID.
          PERFORM SAVE_LOG_CON_CANCEL  USING 'E'
*                                        ls_return-message
                                      TEXT-M04
                                      '  '
                                      '  '
                                      LV_EXTID
                                      PV_TIMESTAMP
                                      PV_SYSTEM_ID
                                      PV_MODE.
        ENDIF.
        EXIT.
      ENDIF.

    ENDLOOP.

    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'A'
                                       OR  TYPE = 'E'
                                       OR  TYPE = 'X'.

      PERFORM RETURN_MESSAGE_CON  USING 'E'
                                      LS_DETAIL-MESSAGE
                                      '  '
                                      '  '
                                      PV_EXTID.

      PERFORM SAVE_LOG_CON  USING 'E'
                                  LS_DETAIL-MESSAGE
                                  '  '
                                  '  '
                                  PV_EXTID
                                  PV_TIMESTAMP
                                  PV_SYSTEM_ID
                                  PV_MODE.

      EXIT.
    ENDLOOP.

    PV_BAPI_FLAG = 'X'.

    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'E'
                                       AND  ID = 'CO'
                            AND ( NUMBER = '469' OR NUMBER = '341' ).
      WAIT UP TO '0.1' SECONDS.
      IF PV_COUNT < 21.
        PV_COUNT = PV_COUNT + 1.
        PERFORM BAPI_PRODORDCONF_CREATE_TT_B TABLES PT_GOODSMOVEMENTS
                                                 USING PV_FIN_CONF
                                                       PV_CLEAR_RES
                                                       PV_ISM08
                                                       PV_EXTID
                                                       PV_BAPI_FLAG
                                                       PV_TIMESTAMP
                                                       PV_SYSTEM_ID
                                                       PV_MODE
                                                       PV_COUNT.
      ENDIF.
    ENDLOOP.


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_BAPI_CASE_A
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_GOODSMOVEMENTS
*&      --> LV_MESSAGE
*&      --> LV_ERROR
*&      --> LV_EXTID
*&      --> P_
*&---------------------------------------------------------------------*
FORM CALL_BAPI_CASE_A  TABLES   PT_GOODSMOVEMENTS
                       STRUCTURE BAPI2017_GM_ITEM_CREATE
                                PT_RETURN STRUCTURE BAPIRET1
                       USING    PV_MESSAGE
                                PV_ERROR
                                PV_EXTID
                                PV_CASE
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE
                                PV_AUART
                       CHANGING PV_BAPI_FLAG.

  DATA : LV_FIN_CONF         LIKE AFRU-AUERU,
         LV_ISM06            LIKE AFRU-ISM06,
         LV_CLEAR_RES(1),
         LV_EXTID(32),
         LV_LOCK_CHK_FLAG(1),
         LV_CHK_FLAG(1),
         LV_BAPI_FLAG(1).

*- 실적처리 체크항목
  CLEAR PT_GOODSMOVEMENTS.

  PERFORM CHECK_CON TABLES PT_GOODSMOVEMENTS
                    USING PV_ERROR
                          PV_EXTID
                          PV_CASE.

  IF PV_ERROR = 'X'.
    PV_MESSAGE = VALUE #( GT_GR_RESULT[ ZSERNO = GS_CON-ZSERNO ]-ZERP_MESSAGE OPTIONAL ).
    PERFORM SAVE_LOG_CON  USING 'E'
                                PV_MESSAGE
                                ''
                                ''
                                PV_EXTID
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE.
    PV_BAPI_FLAG = 'X'.
    CLEAR GS_CON.
    EXIT.
  ENDIF.

  CHECK PV_ERROR <> 'X'.

*- 최종확정 지시자 값 셋팅
***  PERFORM set_fin_conf USING lv_fin_conf
***                             lv_clear_res
***                             'A'.
*- 대체순서에 따른 노무 Activity와 기계 Activity의 비율로 노무 Activity 처리 값 계산

  PERFORM SET_ISMVAL USING LV_ISM06 'A' PV_AUART PV_SYSTEM_ID.

  IF GS_CON-LMNGA IS NOT INITIAL
     AND ( GS_CON-ISM01 IS NOT INITIAL
     OR GS_CON-ISM02 IS NOT INITIAL ).


*  - 실적처리 A  수량  tagnr 값 셋팅
    PERFORM BAPI_PRODORDCONF_CREATE_TT_A TABLES PT_GOODSMOVEMENTS
                                                PT_RETURN
                                             USING LV_FIN_CONF
                                                   LV_CLEAR_RES
                                                   LV_ISM06
                                                   PV_EXTID
                                                   PV_BAPI_FLAG
                                                   PV_TIMESTAMP
                                                   PV_SYSTEM_ID
                                                   PV_MODE
                                                   0.

    IF PV_BAPI_FLAG = 'X'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ELSE.
      IF PV_AUART NE 'RW01' OR GV_GAON EQ ABAP_TRUE.
        PERFORM CHECK_PRODORDCONF_CREATE_LOCK USING  GS_CON-AUFNR
                                                     LV_LOCK_CHK_FLAG
                                                     PV_TIMESTAMP
                                                     PV_SYSTEM_ID
                                                     PV_MODE
                                                     .
        IF LV_LOCK_CHK_FLAG = 'S'.
*  - 실적처리 A  작업길이
          PERFORM BAPI_PRODORDCONF_CREATE_TT_A2 TABLES PT_GOODSMOVEMENTS
                                                      PT_RETURN
                                                   USING LV_FIN_CONF
                                                         LV_CLEAR_RES
                                                         LV_ISM06
                                                         PV_EXTID
                                                         PV_BAPI_FLAG
                                                         PV_TIMESTAMP
                                                         PV_SYSTEM_ID
                                                         PV_MODE
                                                         0.
        ELSE.
          CONCATENATE '오더번호('
                      GS_CON-AUFNR
                      ')이 처리중입니다'
                 INTO PV_MESSAGE .
          PERFORM SAVE_LOG_CON  USING 'E'
                                      PV_MESSAGE
                                      ''
                                      ''
                                      PV_EXTID
                                      PV_TIMESTAMP
                                      PV_SYSTEM_ID
                                      PV_MODE.
          PV_BAPI_FLAG = 'X'.

          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        ENDIF.
      ENDIF.                                                  .
    ENDIF.

  ELSEIF GS_CON-LMNGA IS NOT INITIAL
     AND ( GS_CON-ISM01 IS INITIAL
     OR GS_CON-ISM02 IS INITIAL ) .


*- 실적처리 A  수량  tagnr 값 셋팅
    PERFORM BAPI_PRODORDCONF_CREATE_TT_A TABLES PT_GOODSMOVEMENTS
                                                PT_RETURN
                                             USING LV_FIN_CONF
                                                   LV_CLEAR_RES
                                                   LV_ISM06
                                                   PV_EXTID
                                                   PV_BAPI_FLAG
                                                   PV_TIMESTAMP
                                                   PV_SYSTEM_ID
                                                   PV_MODE
                                                   0.


  ELSEIF GS_CON-LMNGA IS INITIAL
     AND ( GS_CON-ISM01 IS NOT INITIAL
     OR GS_CON-ISM02 IS NOT INITIAL ).
    IF PV_AUART NE 'RW01' OR GV_GAON EQ ABAP_TRUE.
      PERFORM BAPI_PRODORDCONF_CREATE_TT_A2 TABLES PT_GOODSMOVEMENTS
                                                  PT_RETURN
                                               USING LV_FIN_CONF
                                                     LV_CLEAR_RES
                                                     LV_ISM06
                                                     PV_EXTID
                                                     PV_BAPI_FLAG
                                                     PV_TIMESTAMP
                                                     PV_SYSTEM_ID
                                                     PV_MODE
                                                     0.
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_BAPI_CASE_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_GOODSMOVEMENTS
*&      --> LV_MESSAGE
*&      --> LV_ERROR
*&      --> LV_EXTID
*&      --> P_
*&      <-- LV_BAPI_FLAG
*&---------------------------------------------------------------------*
FORM CALL_BAPI_CASE_B  TABLES   PT_GOODSMOVEMENTS
                       STRUCTURE BAPI2017_GM_ITEM_CREATE
                       USING    PV_MESSAGE
                                PV_ERROR
                                PV_EXTID
                                PV_CASE
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE
                                PV_AUART
                       CHANGING PV_BAPI_FLAG.

  DATA : LV_FIN_CONF         LIKE AFRU-AUERU,
         LV_ISM06            LIKE AFRU-ISM06,               "20241220
         LV_ISM08            LIKE AFRU-ISM06,
         LV_CLEAR_RES(1),
         LV_EXTID(32),
         LV_LOCK_CHK_FLAG(1),
         LV_CHK_FLAG(1),
         LV_BAPI_FLAG(1).

*- 실적처리 체크항목
  CLEAR PT_GOODSMOVEMENTS.

  PERFORM CHECK_CON TABLES PT_GOODSMOVEMENTS
                    USING PV_ERROR
                          PV_EXTID
                          PV_CASE.

  IF PV_ERROR = 'X'.
    PV_MESSAGE = VALUE #( GT_GR_RESULT[ ZSERNO = GS_CON-ZSERNO ]-ZERP_MESSAGE OPTIONAL ).
    PERFORM SAVE_LOG_CON  USING 'E'
                                PV_MESSAGE
                                ''
                                ''
                                PV_EXTID
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE.
    PV_BAPI_FLAG = 'X'.
    CLEAR GS_CON.
    EXIT.
  ENDIF.

  CHECK PV_ERROR <> 'X'.

*- 최종확정 지시자 값 셋팅
***  PERFORM set_fin_conf USING lv_fin_conf
***                             lv_clear_res
***                             'B'.
*- 대체순서에 따른 노무 Activity와 기계 Activity의 비율로 노무 Activity 처리 값 계산
*- Start 2024.12.20
*  PERFORM set_ismval USING lv_ism08
*                                'B'.
  LV_ISM08 = GS_CON-ISM08.
  PERFORM SET_ISMVAL USING LV_ISM06 'B' PV_AUART PV_SYSTEM_ID.

*- End 2024.12.20
  IF GS_CON-XMNGA IS NOT INITIAL  " 수리 실적 대상이 있는경우
    AND GS_CON-ISM08 IS NOT INITIAL.

*- 실적처리 B 수량
    PERFORM BAPI_PRODORDCONF_CREATE_TT_B TABLES PT_GOODSMOVEMENTS
                                             USING LV_FIN_CONF
                                                   LV_CLEAR_RES
                                                   LV_ISM08
                                                   PV_EXTID
                                                   PV_BAPI_FLAG
                                                   PV_TIMESTAMP
                                                   PV_SYSTEM_ID
                                                   PV_MODE
                                                   0.
    IF PV_BAPI_FLAG = 'X'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ELSE.
      IF PV_AUART NE 'RW01' OR GV_GAON EQ ABAP_TRUE.
        PERFORM CHECK_PRODORDCONF_CREATE_LOCK USING  GS_CON-AUFNR
                                                   LV_LOCK_CHK_FLAG
                                                   PV_TIMESTAMP
                                                   PV_SYSTEM_ID
                                                   PV_MODE
                                                   .
        IF LV_LOCK_CHK_FLAG = 'S'.
*  - 실적처리 B 작업 길이
          PERFORM BAPI_PRODORDCONF_CREATE_TT_B2 TABLES PT_GOODSMOVEMENTS
                                                   USING LV_FIN_CONF
                                                         LV_CLEAR_RES
                                                         LV_ISM08
                                                         PV_EXTID
                                                         PV_BAPI_FLAG
                                                         LV_ISM06 "20241220
                                                         PV_TIMESTAMP
                                                         PV_SYSTEM_ID
                                                         PV_MODE
                                                         0.
        ELSE.
          CONCATENATE '오더번호('
                      GS_CON-AUFNR
                      ')이 처리중입니다'
                 INTO PV_MESSAGE .
          PERFORM SAVE_LOG_CON  USING 'E'
                                      PV_MESSAGE
                                      ''
                                      ''
                                      PV_EXTID
                                      PV_TIMESTAMP
                                      PV_SYSTEM_ID
                                      PV_MODE.
          PV_BAPI_FLAG = 'X'.

          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        ENDIF.
      ENDIF.                                                 .
    ENDIF.

  ELSEIF GS_CON-XMNGA IS NOT INITIAL  " 수리 실적 대상이 있는경우
         AND GS_CON-ISM08 IS INITIAL.

*- 실적처리 B 수량
    PERFORM BAPI_PRODORDCONF_CREATE_TT_B TABLES PT_GOODSMOVEMENTS
                                             USING LV_FIN_CONF
                                                   LV_CLEAR_RES
                                                   LV_ISM08
                                                   PV_EXTID
                                                   PV_BAPI_FLAG
                                                   PV_TIMESTAMP
                                                   PV_SYSTEM_ID
                                                   PV_MODE
                                                   0.

  ELSEIF GS_CON-XMNGA IS INITIAL  " 수리 실적 대상이 있는경우
         AND GS_CON-ISM08 IS NOT INITIAL.
    IF PV_AUART NE 'RW01' OR GV_GAON EQ ABAP_TRUE.
*  - 실적처리 B 작업 길이
      PERFORM BAPI_PRODORDCONF_CREATE_TT_B2 TABLES PT_GOODSMOVEMENTS
                                               USING LV_FIN_CONF
                                                     LV_CLEAR_RES
                                                     LV_ISM08
                                                     PV_EXTID
                                                     PV_BAPI_FLAG
                                                     LV_ISM06 "20241220
                                                     PV_TIMESTAMP
                                                     PV_SYSTEM_ID
                                                     PV_MODE
                                                     0.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_BAPI_CASE_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_GOODSMOVEMENTS
*&      --> LV_MESSAGE
*&      --> LV_ERROR
*&      --> LV_EXTID
*&      --> P_
*&      <-- LV_BAPI_FLAG
*&---------------------------------------------------------------------*
FORM CALL_BAPI_CASE_C  TABLES   PT_GOODSMOVEMENTS
                       STRUCTURE BAPI2017_GM_ITEM_CREATE
                       USING    PV_MESSAGE
                                PV_ERROR
                                PV_EXTID
                                PV_CASE
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE
                                PV_AUART
                       CHANGING PV_BAPI_FLAG.

  DATA : LV_FIN_CONF         LIKE AFRU-AUERU,
         LV_ISM07            LIKE AFRU-ISM06,
         LV_CLEAR_RES(1),
         LV_EXTID(32),
         LV_LOCK_CHK_FLAG(1),
         LV_CHK_FLAG(1),
         LV_BAPI_FLAG(1).

*- 실적처리 체크항목
  CLEAR PT_GOODSMOVEMENTS.

  PERFORM CHECK_CON TABLES PT_GOODSMOVEMENTS
                    USING PV_ERROR
                          PV_EXTID
                          PV_CASE.
  IF PV_ERROR = 'X'.
    PV_MESSAGE = VALUE #( GT_GR_RESULT[ ZSERNO = GS_CON-ZSERNO ]-ZERP_MESSAGE OPTIONAL ).
    PERFORM SAVE_LOG_CON  USING 'E'
                                PV_MESSAGE
                                ''
                                ''
                                PV_EXTID
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE.
    PV_BAPI_FLAG = 'X'.
    CLEAR GS_CON.
    EXIT.
  ENDIF.

  CHECK PV_ERROR <> 'X'.

*- 최종확정 지시자 값 셋팅
***  PERFORM set_fin_conf USING lv_fin_conf
***                             lv_clear_res
***                             'C'.
*- 대체순서에 따른 노무 Activity와 기계 Activity의 비율로 노무 Activity 처리 값 계산

  PERFORM SET_ISMVAL USING LV_ISM07 'C' PV_AUART PV_SYSTEM_ID.

  IF PV_AUART NE 'RW01' OR GV_GAON EQ ABAP_TRUE.
*- 실적처리 c
    PERFORM BAPI_PRODORDCONF_CREATE_TT_C TABLES PT_GOODSMOVEMENTS
                                             USING LV_FIN_CONF
                                                   LV_CLEAR_RES
                                                   LV_ISM07
                                                   PV_EXTID
                                                   PV_BAPI_FLAG
                                                   PV_TIMESTAMP
                                                   PV_SYSTEM_ID
                                                   PV_MODE
                                                   0.
  ENDIF.
  PERFORM CHECK_PRODORDCONF_CREATE_LOCK USING  GS_CON-AUFNR
                                             LV_LOCK_CHK_FLAG
                                             PV_TIMESTAMP
                                             PV_SYSTEM_ID
                                             PV_MODE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_prodordconf_create_tt_c
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_GOODSMOVEMENTS
*&      --> LV_FIN_CONF
*&      --> LV_CLEAR_RES
*&      --> LV_ISM07
*&      --> PV_EXTID
*&      --> PV_BAPI_FLAG
*&---------------------------------------------------------------------*
FORM BAPI_PRODORDCONF_CREATE_TT_C   TABLES PT_GOODSMOVEMENTS
                                STRUCTURE BAPI2017_GM_ITEM_CREATE
                                  USING PV_FIN_CONF
                                        PV_CLEAR_RES
                                        PV_ISM07
                                        PV_EXTID
                                        PV_BAPI_FLAG
                                        PV_TIMESTAMP
                                        PV_SYSTEM_ID
                                        PV_MODE
                                        PV_COUNT TYPE N.


  DATA: LT_TT      TYPE TABLE OF BAPI_PP_TIMETICKET,
        LT_GOODS   TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_DETAIL  TYPE TABLE OF BAPI_CORU_RETURN,
        LS_DETAIL  TYPE BAPI_CORU_RETURN,
        LS_RETURN  TYPE BAPIRET1,
        LV_MESSAGE TYPE BAPI_CORU_RETURN-MESSAGE.
  DATA : LT_RETURN         LIKE TABLE OF BAPIRET1,
         LV_RUECK          TYPE BAPI_PP_CONF_KEY-CONF_NO,
         LV_RMZHL          TYPE BAPI_PP_CONF_KEY-CONF_CNT,
         LV_EXTID(32),
         LV_CANCEL_FLAG(1).
  CLEAR : LT_TT, LT_GOODS, LT_DETAIL, LS_RETURN, LV_MESSAGE, LS_DETAIL.


  LT_TT = VALUE #( ( ORDERID         = GS_CON-AUFNR
                     OPERATION       = GS_CON-VORNR
                     FIN_CONF        = PV_FIN_CONF
                     CLEAR_RES       = PV_CLEAR_RES
                     POSTG_DATE      = GS_CON-BUDAT
                     DEV_REASON      = 'CH01'
                     PLANT           = GS_CON-WERKS
                     WORK_CNTR       = GS_CON-ARBPL
                     YIELD           = '' " 공란
                     SCRAP           = '' " 공란
                     REWORK          = '' " 공란
                     CONF_TEXT       = '' " 공란
                     CONF_ACTIVITY1  = PV_ISM07
                     CONF_ACTI_UNIT1 = GS_CON-ILE02
                     CONF_ACTIVITY2  = '' " 공란
                     CONF_ACTI_UNIT2 = GS_CON-ILE03
                     CONF_ACTIVITY3  = '' " 공란
                     CONF_ACTI_UNIT3 = GS_CON-ILE04
                     CONF_ACTIVITY4  = '' " 공란
                     CONF_ACTI_UNIT4 = GS_CON-ILE05
                     CONF_ACTIVITY5  = '' " 공란
                     CONF_ACTI_UNIT5 = GS_CON-ILE06
                     CONF_ACTIVITY6  = '' " 공란
                     CONF_ACTI_UNIT6 = GS_CON-ILE07
                     EXEC_START_DATE = GS_CON-ISDD
                     EXEC_START_TIME = GS_CON-ISDZ
                     PROC_FIN_DATE   = GS_CON-IEDD
                     PROC_FIN_TIME   = GS_CON-IEDZ
                     EX_IDENT        = PV_EXTID
                     PERS_NO         = GS_CON-PERNR   ) ).

*- 생산 실적 처리
  CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
    IMPORTING
      RETURN         = LS_RETURN
    TABLES
      TIMETICKETS    = LT_TT
      GOODSMOVEMENTS = PT_GOODSMOVEMENTS
      DETAIL_RETURN  = LT_DETAIL.
*  WAIT UP TO 2 SECONDS.
*- 성공
  IF LS_RETURN IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    LS_DETAIL = VALUE #( LT_DETAIL[ 1 ] OPTIONAL ).

    PERFORM RETURN_MESSAGE_CON_C  USING 'S'
                                      LS_DETAIL-MESSAGE
                                      LS_DETAIL-CONF_NO
                                      LS_DETAIL-CONF_CNT
                                      PV_EXTID.

    PERFORM SAVE_LOG_CON  USING 'S'
                                LS_DETAIL-MESSAGE
                                LS_DETAIL-CONF_NO
                                LS_DETAIL-CONF_CNT
                                PV_EXTID
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE.

****- 생산오더 전송 프로그램 호출(zgtppi2010)
***    PERFORM call_transaction_zgtppi2010.

    PV_BAPI_FLAG = 'C'.
*- 실패
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*- 확정 외부 ID KEY 생성
    CLEAR : LV_EXTID.
    LV_EXTID = GS_CON-RU_EXTID.
    LOOP AT   GT_GR_RESULT_C INTO  GS_GR_RESULT_C .

      PERFORM BAPI_PRODORDCONF_CANCEL TABLES LT_RETURN
                                      USING GS_GR_RESULT_C-RUECK
                                            GS_GR_RESULT_C-RMZHL
                                            GS_CON-BUDAT
                                            LV_RUECK
                                            LV_RMZHL
                                            LV_CANCEL_FLAG.
      IF LV_CANCEL_FLAG = 'E'.

*          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*          READ TABLE lt_return INTO DATA(ls_return)  WITH KEY type = 'E'.
*          IF sy-subrc = 0.
        IF LV_RUECK IS INITIAL.
          PERFORM RETURN_MESSAGE_CON  USING 'E'
*                                              ls_return-message
                                           TEXT-M04
                                            '  '
                                            '  '
                                            LV_EXTID.
          PERFORM SAVE_LOG_CON_CANCEL  USING 'E'
*                                        ls_return-message
                                      TEXT-M04
                                      '  '
                                      '  '
                                      LV_EXTID
                                      PV_TIMESTAMP
                                      PV_SYSTEM_ID
                                      PV_MODE.
        ENDIF.
        EXIT.
      ENDIF.

    ENDLOOP.

    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'A'
                                       OR  TYPE = 'E'
                                       OR  TYPE = 'X'.

      PERFORM RETURN_MESSAGE_CON  USING 'E'
                                      LS_DETAIL-MESSAGE
                                      '  '
                                      '  '
                                      PV_EXTID.

      PERFORM SAVE_LOG_CON  USING 'E'
                                  LS_DETAIL-MESSAGE
                                  '  '
                                  '  '
                                  PV_EXTID
                                  PV_TIMESTAMP
                                  PV_SYSTEM_ID
                                  PV_MODE.

      EXIT.
    ENDLOOP.

    PV_BAPI_FLAG = 'X'.


    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'E'
                                       AND  ID = 'CO'
                         AND  ( NUMBER = '469' OR NUMBER = '341' ).
      WAIT UP TO '0.1' SECONDS.
      IF PV_COUNT < 21.
        PV_COUNT = PV_COUNT + 1.
        PERFORM BAPI_PRODORDCONF_CREATE_TT_C TABLES PT_GOODSMOVEMENTS
                                                 USING PV_FIN_CONF
                                                       PV_CLEAR_RES
                                                       PV_ISM07
                                                       PV_EXTID
                                                       PV_BAPI_FLAG
                                                       PV_TIMESTAMP
                                                       PV_SYSTEM_ID
                                                       PV_MODE
                                                       PV_COUNT.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_BAPI_CASE_D
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_GOODSMOVEMENTS
*&      --> LV_MESSAGE
*&      --> LV_ERROR
*&      --> LV_EXTID
*&      --> P_
*&      <-- LV_BAPI_FLAG
*&---------------------------------------------------------------------*
FORM CALL_BAPI_CASE_D  TABLES   PT_GOODSMOVEMENTS
                       STRUCTURE BAPI2017_GM_ITEM_CREATE
                       USING    PV_MESSAGE
                                PV_ERROR
                                PV_EXTID
                                PV_CASE
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE
                                PV_AUART
                       CHANGING PV_BAPI_FLAG.

  DATA : LV_FIN_CONF         LIKE AFRU-AUERU,
         LV_ISM06            LIKE AFRU-ISM06,
         LV_ISM09            LIKE AFRU-ISM06,
         LV_CLEAR_RES(1),
         LV_EXTID(32),
         LV_LOCK_CHK_FLAG(1),
         LV_CHK_FLAG(1),
         LV_BAPI_FLAG(1).

*- 실적처리 체크항목
  CLEAR PT_GOODSMOVEMENTS.

  PERFORM CHECK_CON TABLES PT_GOODSMOVEMENTS
                    USING PV_ERROR
                          PV_EXTID
                          PV_CASE.

  IF PV_ERROR = 'X'.
    PV_MESSAGE = VALUE #( GT_GR_RESULT[ ZSERNO = GS_CON-ZSERNO ]-ZERP_MESSAGE OPTIONAL ).
    PERFORM SAVE_LOG_CON  USING 'E'
                                PV_MESSAGE
                                ''
                                ''
                                PV_EXTID
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE.
    PV_BAPI_FLAG = 'X'.
    CLEAR GS_CON.
    EXIT.
  ENDIF.

  CHECK PV_ERROR <> 'X'.

*- 최종확정 지시자 값 셋팅
***  PERFORM set_fin_conf USING lv_fin_conf
***                             lv_clear_res
***                             'D'.
*- 대체순서에 따른 노무 Activity와 기계 Activity의 비율로 노무 Activity 처리 값 계산
*- Start 2024.12.20
*  PERFORM set_ismval USING lv_ism09
*                                'D'.
*  PERFORM set_ismval USING lv_ism06
*                                'A'.
  LV_ISM09 = GS_CON-ISM09.

  PERFORM SET_ISMVAL USING LV_ISM06 'D' PV_AUART PV_SYSTEM_ID.

*- End 2024.12.20

  IF GS_CON-SMNGA IS NOT INITIAL  " Start 여장 작업 실적 처리대상이 있는경우
     AND GS_CON-ISM09 IS NOT INITIAL.
*- 실적처리 D  수량
    PERFORM BAPI_PRODORDCONF_CREATE_TT_D TABLES PT_GOODSMOVEMENTS
                                             USING LV_FIN_CONF
                                                   LV_CLEAR_RES
                                                   LV_ISM09
                                                   PV_EXTID
                                                   PV_BAPI_FLAG
                                                   LV_ISM06
                                                   PV_TIMESTAMP
                                                   PV_SYSTEM_ID
                                                   PV_MODE
                                                   0.
    IF PV_BAPI_FLAG = 'X'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ELSE.
      IF PV_AUART NE 'RW01' OR GV_GAON EQ ABAP_TRUE.
        PERFORM CHECK_PRODORDCONF_CREATE_LOCK USING  GS_CON-AUFNR
                                                   LV_LOCK_CHK_FLAG
                                                   PV_TIMESTAMP
                                                   PV_SYSTEM_ID
                                                   PV_MODE
                                                   .
        IF LV_LOCK_CHK_FLAG = 'S'.
*  - 실적처리 D  작업길이
          PERFORM BAPI_PRODORDCONF_CREATE_TT_D2 TABLES PT_GOODSMOVEMENTS
                                                   USING LV_FIN_CONF
                                                         LV_CLEAR_RES
                                                         LV_ISM09
                                                         PV_EXTID
                                                         PV_BAPI_FLAG
                                                         LV_ISM06
                                                         PV_TIMESTAMP
                                                         PV_SYSTEM_ID
                                                         PV_MODE
                                                         0.
        ELSE.
          CONCATENATE '오더번호('
                      GS_CON-AUFNR
                      ')이 처리중입니다'
                 INTO PV_MESSAGE .
          PERFORM SAVE_LOG_CON  USING 'E'
                                      PV_MESSAGE
                                      ''
                                      ''
                                      PV_EXTID
                                      PV_TIMESTAMP
                                      PV_SYSTEM_ID
                                      PV_MODE.
          PV_BAPI_FLAG = 'X'.

          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        ENDIF.
      ENDIF.                                               .
    ENDIF.

  ELSEIF GS_CON-SMNGA IS NOT INITIAL   " Start 여장 작업 실적 처리대상이 있는경우
        AND GS_CON-ISM09 IS INITIAL.

*- 실적처리 D  수량
    PERFORM BAPI_PRODORDCONF_CREATE_TT_D TABLES PT_GOODSMOVEMENTS
                                             USING LV_FIN_CONF
                                                   LV_CLEAR_RES
                                                   LV_ISM09
                                                   PV_EXTID
                                                   PV_BAPI_FLAG
                                                   LV_ISM06
                                                   PV_TIMESTAMP
                                                   PV_SYSTEM_ID
                                                   PV_MODE
                                                   0.

  ELSEIF GS_CON-SMNGA IS INITIAL   " Start 여장 작업 실적 처리대상이 있는경우
        AND GS_CON-ISM09 IS NOT INITIAL.
    IF PV_AUART NE 'RW01' OR GV_GAON EQ ABAP_TRUE.
*  - 실적처리 D  작업길이
      PERFORM BAPI_PRODORDCONF_CREATE_TT_D2 TABLES PT_GOODSMOVEMENTS
                                               USING LV_FIN_CONF
                                                     LV_CLEAR_RES
                                                     LV_ISM09
                                                     PV_EXTID
                                                     PV_BAPI_FLAG
                                                     LV_ISM06
                                                     PV_TIMESTAMP
                                                     PV_SYSTEM_ID
                                                     PV_MODE
                                                     0.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_prodordconf_create_tt_d
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_GOODSMOVEMENTS
*&      --> LV_FIN_CONF
*&      --> LV_CLEAR_RES
*&      --> LV_ISM09
*&      --> PV_EXTID
*&      --> PV_BAPI_FLAG
*&---------------------------------------------------------------------*
FORM BAPI_PRODORDCONF_CREATE_TT_D   TABLES PT_GOODSMOVEMENTS
                                STRUCTURE BAPI2017_GM_ITEM_CREATE
                                  USING PV_FIN_CONF
                                        PV_CLEAR_RES
                                        PV_ISM09
                                        PV_EXTID
                                        PV_BAPI_FLAG
                                        PV_ISM06
                                        PV_TIMESTAMP
                                        PV_SYSTEM_ID
                                        PV_MODE
                                        PV_COUNT TYPE N
                                        .


  DATA: LT_TT      TYPE TABLE OF BAPI_PP_TIMETICKET,
        LT_GOODS   TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_DETAIL  TYPE TABLE OF BAPI_CORU_RETURN,
        LS_DETAIL  TYPE BAPI_CORU_RETURN,
        LS_RETURN  TYPE BAPIRET1,
        LV_MESSAGE TYPE BAPI_CORU_RETURN-MESSAGE.
  DATA : LT_RETURN         LIKE TABLE OF BAPIRET1,
         LV_RUECK          TYPE BAPI_PP_CONF_KEY-CONF_NO,
         LV_RMZHL          TYPE BAPI_PP_CONF_KEY-CONF_CNT,
         LV_EXTID(32),
         LV_CANCEL_FLAG(1).

  CLEAR : LT_TT, LT_GOODS, LT_DETAIL, LS_RETURN, LV_MESSAGE, LS_DETAIL.


  LT_TT = VALUE #( ( ORDERID         = GS_CON-AUFNR
                     OPERATION       = GS_CON-VORNR
                     FIN_CONF        = PV_FIN_CONF
                     CLEAR_RES       = PV_CLEAR_RES
                     POSTG_DATE      = GS_CON-BUDAT
                     DEV_REASON      = 'CH02'
                     PLANT           = GS_CON-WERKS
                     WORK_CNTR       = GS_CON-ARBPL
                     YIELD           = GS_CON-SMNGA
                     SCRAP           = '' " 공란
                     REWORK          = '' " 공란
                     CONF_TEXT       = '' " 공란
                     CONF_ACTIVITY1  = '' " 공란
                     CONF_ACTI_UNIT1 = GS_CON-ILE01
                     CONF_ACTIVITY2  = '' " 공란
                     CONF_ACTI_UNIT2 = GS_CON-ILE02
                     CONF_ACTIVITY3  = '' " 공란
                     CONF_ACTI_UNIT3 = GS_CON-ILE03
                     CONF_ACTIVITY4  = '' " 공란
                     CONF_ACTI_UNIT4 = GS_CON-ILE04
                     CONF_ACTIVITY5  = '' " 공란
                     CONF_ACTI_UNIT5 = GS_CON-ILE05
                     CONF_ACTIVITY6  = '' " 공란
                     CONF_ACTI_UNIT6 = GS_CON-ILE06
                     EXEC_START_DATE = GS_CON-ISDD
                     EXEC_START_TIME = GS_CON-ISDZ
                     PROC_FIN_DATE   = GS_CON-IEDD
                     PROC_FIN_TIME   = GS_CON-IEDZ
                     EX_IDENT        = PV_EXTID
                     PERS_NO         = GS_CON-PERNR   ) ).

*- 생산 실적 처리
  CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
    IMPORTING
      RETURN         = LS_RETURN
    TABLES
      TIMETICKETS    = LT_TT
      GOODSMOVEMENTS = PT_GOODSMOVEMENTS
      DETAIL_RETURN  = LT_DETAIL.

*- 성공
  IF LS_RETURN IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    LS_DETAIL = VALUE #( LT_DETAIL[ 1 ] OPTIONAL ).

    PERFORM RETURN_MESSAGE_CON_C  USING 'S'
                                      LS_DETAIL-MESSAGE
                                      LS_DETAIL-CONF_NO
                                      LS_DETAIL-CONF_CNT
                                      PV_EXTID.

    PERFORM SAVE_LOG_CON  USING 'S'
                                LS_DETAIL-MESSAGE
                                LS_DETAIL-CONF_NO
                                LS_DETAIL-CONF_CNT
                                PV_EXTID
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE.

****- 생산오더 전송 프로그램 호출(zgtppi2010)
***    PERFORM call_transaction_zgtppi2010.

    PV_BAPI_FLAG = 'D'.
*- 실패
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*- 확정 외부 ID KEY 생성
    CLEAR : LV_EXTID.
    LV_EXTID = GS_CON-RU_EXTID.
    LOOP AT   GT_GR_RESULT_C INTO  GS_GR_RESULT_C .

      PERFORM BAPI_PRODORDCONF_CANCEL TABLES LT_RETURN
                                      USING GS_GR_RESULT_C-RUECK
                                            GS_GR_RESULT_C-RMZHL
                                            GS_CON-BUDAT
                                            LV_RUECK
                                            LV_RMZHL
                                            LV_CANCEL_FLAG.
      IF LV_CANCEL_FLAG = 'E'.

*          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*          READ TABLE lt_return INTO DATA(ls_return)  WITH KEY type = 'E'.
*          IF sy-subrc = 0.
        IF LV_RUECK IS INITIAL.
          PERFORM RETURN_MESSAGE_CON  USING 'E'
*                                              ls_return-message
                                           TEXT-M04
                                            '  '
                                            '  '
                                            LV_EXTID.
          PERFORM SAVE_LOG_CON_CANCEL  USING 'E'
*                                        ls_return-message
                                      TEXT-M04
                                      '  '
                                      '  '
                                      LV_EXTID
                                      PV_TIMESTAMP
                                      PV_SYSTEM_ID
                                      PV_MODE.
        ENDIF.
        EXIT.
      ENDIF.

    ENDLOOP.

    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'A'
                                       OR  TYPE = 'E'
                                       OR  TYPE = 'X'.

      PERFORM RETURN_MESSAGE_CON  USING 'E'
                                      LS_DETAIL-MESSAGE
                                      '  '
                                      '  '
                                      PV_EXTID.

      PERFORM SAVE_LOG_CON  USING 'E'
                                  LS_DETAIL-MESSAGE
                                  '  '
                                  '  '
                                  PV_EXTID
                                  PV_TIMESTAMP
                                  PV_SYSTEM_ID
                                  PV_MODE.

      EXIT.
    ENDLOOP.

    PV_BAPI_FLAG = 'X'.

    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'E'
                                       AND  ID = 'CO'
                           AND  ( NUMBER = '469' OR NUMBER = '341' ).
      WAIT UP TO '0.1' SECONDS.
      IF PV_COUNT < 21.
        PV_COUNT = PV_COUNT + 1.
        PERFORM BAPI_PRODORDCONF_CREATE_TT_D TABLES PT_GOODSMOVEMENTS
                                                 USING PV_FIN_CONF
                                                       PV_CLEAR_RES
                                                       PV_ISM09
                                                       PV_EXTID
                                                       PV_BAPI_FLAG
                                                       PV_ISM06
                                                       PV_TIMESTAMP
                                                       PV_SYSTEM_ID
                                                       PV_MODE
                                                       PV_COUNT.
      ENDIF.
    ENDLOOP.


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_BAPI_CASE_E
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_GOODSMOVEMENTS
*&      --> LV_MESSAGE
*&      --> LV_ERROR
*&      --> LV_EXTID
*&      --> P_
*&      <-- LV_BAPI_FLAG
*&---------------------------------------------------------------------*
FORM CALL_BAPI_CASE_E  TABLES   PT_GOODSMOVEMENTS
                       STRUCTURE BAPI2017_GM_ITEM_CREATE
                       USING    PV_MESSAGE
                                PV_ERROR
                                PV_EXTID
                                PV_CASE
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE
                                PV_AUART
                       CHANGING PV_BAPI_FLAG.

  DATA : LV_FIN_CONF         LIKE AFRU-AUERU,
         LV_ISM06            LIKE AFRU-ISM06,
         LV_ISM10            LIKE AFRU-ISM06,
         LV_CLEAR_RES(1),
         LV_EXTID(32),
         LV_LOCK_CHK_FLAG(1),
         LV_CHK_FLAG(1),
         LV_BAPI_FLAG(1).


*- 실적처리 체크항목
  CLEAR PT_GOODSMOVEMENTS.

  PERFORM CHECK_CON TABLES PT_GOODSMOVEMENTS
                    USING PV_ERROR
                          PV_EXTID
                          PV_CASE.

  IF PV_ERROR = 'X'.
    PV_MESSAGE = VALUE #( GT_GR_RESULT[ ZSERNO = GS_CON-ZSERNO ]-ZERP_MESSAGE OPTIONAL ).
    PERFORM SAVE_LOG_CON  USING 'E'
                                PV_MESSAGE
                                ''
                                ''
                                PV_EXTID
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE.
    PV_BAPI_FLAG = 'X'.
    CLEAR GS_CON.
    EXIT.
  ENDIF.

  CHECK PV_ERROR <> 'X'.

*- 최종확정 지시자 값 셋팅
***  PERFORM set_fin_conf USING lv_fin_conf
***                             lv_clear_res
***                             'E'.
*- 대체순서에 따른 노무 Activity와 기계 Activity의 비율로 노무 Activity 처리 값 계산
*- Start 2024.12.20
*  PERFORM set_ismval USING lv_ism10
*                                'E'.
*  PERFORM set_ismval USING lv_ism06
*                                'A'.
  LV_ISM10 = GS_CON-ISM10.

  PERFORM SET_ISMVAL USING LV_ISM06 'E' PV_AUART PV_SYSTEM_ID.

*- End 2024.12.20

  IF GS_CON-EMNGA IS NOT INITIAL   " End 여장 작업  실적 처리대상이 있는경우
     AND GS_CON-ISM10 IS NOT INITIAL.
*- 실적처리 E 수량
    PERFORM BAPI_PRODORDCONF_CREATE_TT_E TABLES PT_GOODSMOVEMENTS
                                             USING LV_FIN_CONF
                                                   LV_CLEAR_RES
                                                   LV_ISM10
                                                   PV_EXTID
                                                   PV_BAPI_FLAG
                                                   LV_ISM06
                                                   PV_TIMESTAMP
                                                   PV_SYSTEM_ID
                                                   PV_MODE
                                                   0.

    IF PV_BAPI_FLAG = 'X'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ELSE.
      IF PV_AUART NE 'RW01' OR GV_GAON EQ ABAP_TRUE.
        PERFORM CHECK_PRODORDCONF_CREATE_LOCK USING  GS_CON-AUFNR
                                                   LV_LOCK_CHK_FLAG
                                                   PV_TIMESTAMP
                                                   PV_SYSTEM_ID
                                                   PV_MODE
                                                   .

        IF LV_LOCK_CHK_FLAG = 'S'.
*  - 실적처리 E  작업시간
          PERFORM BAPI_PRODORDCONF_CREATE_TT_E2 TABLES PT_GOODSMOVEMENTS
                                                   USING LV_FIN_CONF
                                                         LV_CLEAR_RES
                                                         LV_ISM10
                                                         PV_EXTID
                                                         PV_BAPI_FLAG
                                                         LV_ISM06
                                                         PV_TIMESTAMP
                                                         PV_SYSTEM_ID
                                                         PV_MODE
                                                         0.
        ELSE.
          CONCATENATE '오더번호('
                      GS_CON-AUFNR
                      ')이 처리중입니다'
                 INTO PV_MESSAGE .
          PERFORM SAVE_LOG_CON  USING 'E'
                                      PV_MESSAGE
                                      ''
                                      ''
                                      PV_EXTID
                                      PV_TIMESTAMP
                                      PV_SYSTEM_ID
                                      PV_MODE.
          PV_BAPI_FLAG = 'X'.

          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        ENDIF.
      ENDIF.
    ENDIF.

  ELSEIF GS_CON-EMNGA IS NOT INITIAL   " End 여장 작업  실적 처리대상이 있는경우
     AND GS_CON-ISM10 IS INITIAL.
*- 실적처리 E 수량
    PERFORM BAPI_PRODORDCONF_CREATE_TT_E TABLES PT_GOODSMOVEMENTS
                                             USING LV_FIN_CONF
                                                   LV_CLEAR_RES
                                                   LV_ISM10
                                                   PV_EXTID
                                                   PV_BAPI_FLAG
                                                   LV_ISM06
                                                   PV_TIMESTAMP
                                                   PV_SYSTEM_ID
                                                   PV_MODE
                                                   0.
  ELSEIF GS_CON-EMNGA IS INITIAL   " End 여장 작업  실적 처리대상이 있는경우
     AND GS_CON-ISM10 IS NOT INITIAL.
    IF PV_AUART NE 'RW01' OR GV_GAON EQ ABAP_TRUE.
*  - 실적처리 E  작업시간
      PERFORM BAPI_PRODORDCONF_CREATE_TT_E2 TABLES PT_GOODSMOVEMENTS
                                               USING LV_FIN_CONF
                                                     LV_CLEAR_RES
                                                     LV_ISM10
                                                     PV_EXTID
                                                     PV_BAPI_FLAG
                                                     LV_ISM06
                                                     PV_TIMESTAMP
                                                     PV_SYSTEM_ID
                                                     PV_MODE
                                                     0.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_prodordconf_create_tt_e
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_GOODSMOVEMENTS
*&      --> LV_FIN_CONF
*&      --> LV_CLEAR_RES
*&      --> LV_ISM10
*&      --> PV_EXTID
*&      --> PV_BAPI_FLAG
*&      --> LV_ISM06
*&---------------------------------------------------------------------*
FORM BAPI_PRODORDCONF_CREATE_TT_E  TABLES PT_GOODSMOVEMENTS
                                STRUCTURE BAPI2017_GM_ITEM_CREATE
                                  USING PV_FIN_CONF
                                        PV_CLEAR_RES
                                        PV_ISM10
                                        PV_EXTID
                                        PV_BAPI_FLAG
                                        PV_ISM06
                                        PV_TIMESTAMP
                                        PV_SYSTEM_ID
                                        PV_MODE
                                        PV_COUNT TYPE N
                                        .


  DATA: LT_TT      TYPE TABLE OF BAPI_PP_TIMETICKET,
        LT_GOODS   TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_DETAIL  TYPE TABLE OF BAPI_CORU_RETURN,
        LS_DETAIL  TYPE BAPI_CORU_RETURN,
        LS_RETURN  TYPE BAPIRET1,
        LV_MESSAGE TYPE BAPI_CORU_RETURN-MESSAGE.
  DATA : LT_RETURN         LIKE TABLE OF BAPIRET1,
         LV_RUECK          TYPE BAPI_PP_CONF_KEY-CONF_NO,
         LV_RMZHL          TYPE BAPI_PP_CONF_KEY-CONF_CNT,
         LV_EXTID(32),
         LV_CANCEL_FLAG(1).


  CLEAR : LT_TT, LT_GOODS, LT_DETAIL, LS_RETURN, LV_MESSAGE, LS_DETAIL.


  LT_TT = VALUE #( ( ORDERID         = GS_CON-AUFNR
                     OPERATION       = GS_CON-VORNR
                     FIN_CONF        = PV_FIN_CONF
                     CLEAR_RES       = PV_CLEAR_RES
                     POSTG_DATE      = GS_CON-BUDAT
                     DEV_REASON      = 'CH03'
                     PLANT           = GS_CON-WERKS
                     WORK_CNTR       = GS_CON-ARBPL
                     YIELD           = GS_CON-EMNGA
                     SCRAP           = '' " 공란
                     REWORK          = '' " 공란
                     CONF_TEXT       = '' " 공란
                     CONF_ACTIVITY1  = '' " 공란
                     CONF_ACTI_UNIT1 = GS_CON-ILE01
                     CONF_ACTIVITY2  = '' " 공란
                     CONF_ACTI_UNIT2 = GS_CON-ILE02
                     CONF_ACTIVITY3  = '' " 공란
                     CONF_ACTI_UNIT3 = GS_CON-ILE03
                     CONF_ACTIVITY4  = '' " 공란
                     CONF_ACTI_UNIT4 = GS_CON-ILE04
                     CONF_ACTIVITY5  = '' " 공란
                     CONF_ACTI_UNIT5 = GS_CON-ILE05
                     CONF_ACTIVITY6  = '' " 공란
                     CONF_ACTI_UNIT6 = GS_CON-ILE06
                     EXEC_START_DATE = GS_CON-ISDD
                     EXEC_START_TIME = GS_CON-ISDZ
                     PROC_FIN_DATE   = GS_CON-IEDD
                     PROC_FIN_TIME   = GS_CON-IEDZ
                     EX_IDENT        = PV_EXTID
                     PERS_NO         = GS_CON-PERNR   ) ).

*- 생산 실적 처리
  CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
    IMPORTING
      RETURN         = LS_RETURN
    TABLES
      TIMETICKETS    = LT_TT
      GOODSMOVEMENTS = PT_GOODSMOVEMENTS
      DETAIL_RETURN  = LT_DETAIL.

*  WAIT UP TO 2 SECONDS.
*- 성공
  IF LS_RETURN IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    LS_DETAIL = VALUE #( LT_DETAIL[ 1 ] OPTIONAL ).

    PERFORM RETURN_MESSAGE_CON_C  USING 'S'
                                      LS_DETAIL-MESSAGE
                                      LS_DETAIL-CONF_NO
                                      LS_DETAIL-CONF_CNT
                                      PV_EXTID.

    PERFORM SAVE_LOG_CON  USING 'S'
                                LS_DETAIL-MESSAGE
                                LS_DETAIL-CONF_NO
                                LS_DETAIL-CONF_CNT
                                PV_EXTID
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE.

****- 생산오더 전송 프로그램 호출(zgtppi2010)
***    PERFORM call_transaction_zgtppi2010.

    PV_BAPI_FLAG = 'E'.
*- 실패
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*- 확정 외부 ID KEY 생성
    CLEAR : LV_EXTID.
    LV_EXTID = GS_CON-RU_EXTID.
    LOOP AT   GT_GR_RESULT_C INTO  GS_GR_RESULT_C .

      PERFORM BAPI_PRODORDCONF_CANCEL TABLES LT_RETURN
                                      USING GS_GR_RESULT_C-RUECK
                                            GS_GR_RESULT_C-RMZHL
                                            GS_CON-BUDAT
                                            LV_RUECK
                                            LV_RMZHL
                                            LV_CANCEL_FLAG.
      IF LV_CANCEL_FLAG = 'E'.

*          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*          READ TABLE lt_return INTO DATA(ls_return)  WITH KEY type = 'E'.
*          IF sy-subrc = 0.
        IF LV_RUECK IS INITIAL.
          PERFORM RETURN_MESSAGE_CON  USING 'E'
*                                              ls_return-message
                                           TEXT-M04
                                            '  '
                                            '  '
                                            LV_EXTID.
          PERFORM SAVE_LOG_CON_CANCEL  USING 'E'
*                                        ls_return-message
                                      TEXT-M04
                                      '  '
                                      '  '
                                      LV_EXTID
                                      PV_TIMESTAMP
                                      PV_SYSTEM_ID
                                      PV_MODE.
        ENDIF.
        EXIT.
      ENDIF.

    ENDLOOP.

    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'A'
                                       OR  TYPE = 'E'
                                       OR  TYPE = 'X'.

      PERFORM RETURN_MESSAGE_CON  USING 'E'
                                      LS_DETAIL-MESSAGE
                                      '  '
                                      '  '
                                      PV_EXTID.

      PERFORM SAVE_LOG_CON  USING 'E'
                                  LS_DETAIL-MESSAGE
                                  '  '
                                  '  '
                                  PV_EXTID
                                  PV_TIMESTAMP
                                  PV_SYSTEM_ID
                                  PV_MODE.

      EXIT.
    ENDLOOP.

    PV_BAPI_FLAG = 'X'.

    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'E'
                                       AND  ID = 'CO'
                     AND ( NUMBER = '469' OR NUMBER = '341' ).
      WAIT UP TO '0.1' SECONDS.
      IF PV_COUNT < 21.
        PV_COUNT = PV_COUNT + 1.
        PERFORM BAPI_PRODORDCONF_CREATE_TT_E TABLES PT_GOODSMOVEMENTS
                                                 USING PV_FIN_CONF
                                                       PV_CLEAR_RES
                                                       PV_ISM10
                                                       PV_EXTID
                                                       PV_BAPI_FLAG
                                                       PV_ISM06
                                                       PV_TIMESTAMP
                                                       PV_SYSTEM_ID
                                                       PV_MODE
                                                       PV_COUNT.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CANCEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_CON_RU_EXTID
*&      --> GS_CON_AUFNR
*&---------------------------------------------------------------------*
FORM GET_CANCEL_DATA  USING    PV_RU_EXTID
                               PV_AUFNR.

  CLEAR : GT_AFRU[], GT_AFRU.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @GT_AFRU
    FROM AFRU
   WHERE AUFNR = @PV_AUFNR
     AND EXTID = @PV_RU_EXTID
     AND STOKZ = ''
     AND STZHL = ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_transaction_zgtppi2010_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_AFRU_WERKS
*&      --> GT_AFRU_AUFNR
*&---------------------------------------------------------------------*
FORM CALL_TRANSACTION_ZGTPPI2010_C  USING    PV_WERKS
                                             PV_AUFNR.

*<-
  JOBNAME = '생산오더전송'.
  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      JOBNAME          = JOBNAME
    IMPORTING
      JOBCOUNT         = JOBCOUNT
    EXCEPTIONS
      CANT_CREATE_JOB  = 1
      INVALID_JOB_DATA = 2
      JOBNAME_MISSING  = 3
      OTHERS           = 4.

  RANGES : LR_AUFNR FOR AFKO-AUFNR.
  LR_AUFNR[] = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = PV_AUFNR ) ).
  RANGES : LR_DISPO FOR AFKO-DISPO.
  LR_DISPO[] = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = 'AUF' )
                        ( SIGN = 'I' OPTION = 'EQ' LOW = 'AUH' ) ).

  SUBMIT ZGTPPI2010 VIA JOB JOBNAME
                   NUMBER JOBCOUNT
                  AND RETURN
                  WITH P_WERKS = PV_WERKS
                  WITH S_AUFNR IN LR_AUFNR
                  WITH P_C1    = 'X'
                  WITH P_C2    = 'X'.

  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      JOBCOUNT             = JOBCOUNT
      JOBNAME              = JOBNAME
      STRTIMMED            = 'X'
    EXCEPTIONS
      CANT_START_IMMEDIATE = 1
      INVALID_STARTDATE    = 2
      JOBNAME_MISSING      = 3
      JOB_CLOSE_FAILED     = 4
      JOB_NOSTEPS          = 5
      JOB_NOTEX            = 6
      LOCK_FAILED          = 7
      OTHERS               = 8.
*->

*  SET PARAMETER ID 'M1' FIELD GS_CON-WERKS. "플랜트
*  SET PARAMETER ID 'M2' FIELD GS_CON-AUFNR. "생산오더
*
*  CALL TRANSACTION 'ZAUMI_P06'  AND SKIP FIRST SCREEN.
*
*  SET PARAMETER ID 'M1' FIELD '  '.
*  SET PARAMETER ID 'M2' FIELD '  '.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_log_con_cancel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> LV_MESSAGE
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SAVE_LOG_CON_CANCEL  USING PV_FLAG
                          PV_MESSAGE
                          PV_RUECK
                          PV_RMZHL
                          PV_EXTID
                          PV_TIMESTAMP
                          PV_SYSTEM_ID
                          PV_MODE.

  DATA : LT_ZGTPPT3080 TYPE TABLE OF ZGTPPT3080.
*  DATA  : lv_timestamp TYPE timestampl.
  CLEAR : LT_ZGTPPT3080.


*  GET TIME STAMP FIELD lv_timestamp.

  GT_ZGTPPT3080 = VALUE #( ( VALUE #( BASE CORRESPONDING #( GS_CON MAPPING ZC_RUECK = RUECK
                                                                         ZC_RMZHL = RMZHL )
                           ZIFKEY  = PV_TIMESTAMP
                           I_MODE  = PV_MODE
                           ZC_RUECK   = PV_RUECK "BAPI에서 리턴된 확정 번호
                           ZC_RMZHL   = PV_RMZHL "BAPI에서 리턴된 확정 카운터
                           ZC_RU_EXTID =  PV_EXTID
                           ZSYSTEM_ID  = PV_SYSTEM_ID
                           ZERP_STAT = PV_FLAG
                           ZERP_MESSAGE    = PV_MESSAGE
                           IFNAM  = SY-UNAME
                           IFDAT  = SY-DATUM
                           IFTIM  = SY-UZEIT
                       ) ) ).

***  MODIFY zgtppt3080 FROM TABLE lt_zgtppt3080.
***  IF sy-subrc = 0.
***    COMMIT WORK.
***  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_prodordconf_create_tt_a2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_GOODSMOVEMENTS
*&      --> PT_RETURN
*&      --> LV_FIN_CONF
*&      --> LV_CLEAR_RES
*&      --> LV_ISM06
*&      --> PV_EXTID
*&      --> PV_BAPI_FLAG
*&      --> PV_TIMESTAMP
*&      --> PV_SYSTEM_ID
*&      --> PV_MODE
*&---------------------------------------------------------------------*
FORM BAPI_PRODORDCONF_CREATE_TT_A2 TABLES PT_GOODSMOVEMENTS
                                 STRUCTURE BAPI2017_GM_ITEM_CREATE
                                  PT_RETURN STRUCTURE BAPIRET1
                                  USING PV_FIN_CONF
                                        PV_CLEAR_RES
                                        PV_ISM06
                                        PV_EXTID
                                        PV_BAPI_FLAG
                                        PV_TIMESTAMP
                                        PV_SYSTEM_ID
                                        PV_MODE
                                        PV_COUNT TYPE N
                                        .


  DATA: LT_TT      TYPE TABLE OF BAPI_PP_TIMETICKET,
        LT_GOODS   TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_DETAIL  TYPE TABLE OF BAPI_CORU_RETURN,
        LS_DETAIL  TYPE BAPI_CORU_RETURN,
        LS_RETURN  TYPE BAPIRET1,
        LV_MESSAGE TYPE BAPI_CORU_RETURN-MESSAGE.

  DATA : LT_RETURN         LIKE TABLE OF BAPIRET1,
         LV_RUECK          TYPE BAPI_PP_CONF_KEY-CONF_NO,
         LV_RMZHL          TYPE BAPI_PP_CONF_KEY-CONF_CNT,
         LV_EXTID(32),
         LV_CANCEL_FLAG(1).

  DATA: LV_BUDAT TYPE BUCHDATUM. "GO02(+)

  CLEAR : LT_TT, LT_GOODS, LT_DETAIL, LS_RETURN, LV_MESSAGE, LS_DETAIL.

*- GO02 Start GAON 전기일 설정
  CLEAR: LV_BUDAT.
  IF GV_GAON EQ ABAP_TRUE.
    LV_BUDAT = GV_BUDAT.
  ELSE.
    LV_BUDAT = GS_CON-BUDAT.
  ENDIF.
*- GO02 End GAON 전기일 설정

  LT_TT = VALUE #( ( ORDERID         = GS_CON-AUFNR
                     OPERATION       = GS_CON-VORNR
                     FIN_CONF        = PV_FIN_CONF
                     CLEAR_RES       = PV_CLEAR_RES
                     POSTG_DATE      = LV_BUDAT "GS_CON-BUDAT   "GO02(+)
                     DEV_REASON      = ''
                     PLANT           = GS_CON-WERKS
                     WORK_CNTR       = GS_CON-ARBPL
                     YIELD           = '' " 공란
                     SCRAP           = ''
                     REWORK          = ''
                     CONF_TEXT       = '' " 공란
                     CONF_ACTIVITY1  = GS_CON-ISM01
                     CONF_ACTI_UNIT1 = GS_CON-ILE01
                     CONF_ACTIVITY2  = GS_CON-ISM02
                     CONF_ACTI_UNIT2 = GS_CON-ILE02
                     CONF_ACTIVITY3  = GS_CON-ISM03
                     CONF_ACTI_UNIT3 = GS_CON-ILE03
                     CONF_ACTIVITY4  = GS_CON-ISM04
                     CONF_ACTI_UNIT4 = GS_CON-ILE04
                     CONF_ACTIVITY5  = GS_CON-ISM05
                     CONF_ACTI_UNIT5 = GS_CON-ILE05
                     CONF_ACTIVITY6  = PV_ISM06
                     CONF_ACTI_UNIT6 = GS_CON-ILE06
                     EXEC_START_DATE = GS_CON-ISDD
                     EXEC_START_TIME = GS_CON-ISDZ
                     PROC_FIN_DATE   = GS_CON-IEDD
                     PROC_FIN_TIME   = GS_CON-IEDZ
                     EX_IDENT        = PV_EXTID
                     PERS_NO         = GS_CON-PERNR   ) ).

*- 생산 실적 처리
  CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
    IMPORTING
      RETURN         = LS_RETURN
    TABLES
      TIMETICKETS    = LT_TT
      GOODSMOVEMENTS = PT_GOODSMOVEMENTS
      DETAIL_RETURN  = LT_DETAIL.

*  WAIT UP TO 2 SECONDS.
*- 성공
  IF LS_RETURN IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    LS_DETAIL = VALUE #( LT_DETAIL[ 1 ] OPTIONAL ).

    PERFORM RETURN_MESSAGE_CON_C  USING 'S'
                                      LS_DETAIL-MESSAGE
                                      LS_DETAIL-CONF_NO
                                      LS_DETAIL-CONF_CNT
                                      PV_EXTID.

    PERFORM SAVE_LOG_CON  USING 'S'
                                LS_DETAIL-MESSAGE
                                LS_DETAIL-CONF_NO
                                LS_DETAIL-CONF_CNT
                                PV_EXTID
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE
                                .

*- 생산오더 전송 프로그램 호출(zgtppi2010)
***    PERFORM call_transaction_zgtppi2010.

    PV_BAPI_FLAG = 'A'.
*- 실패
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*- 확정 외부 ID KEY 생성
    CLEAR : LV_EXTID.
    LV_EXTID = GS_CON-RU_EXTID.
    LOOP AT   GT_GR_RESULT_C INTO  GS_GR_RESULT_C .

      PERFORM BAPI_PRODORDCONF_CANCEL TABLES LT_RETURN
                                      USING GS_GR_RESULT_C-RUECK
                                            GS_GR_RESULT_C-RMZHL
                                            LV_BUDAT "GS_CON-BUDAT   "GO02(+)
                                            LV_RUECK
                                            LV_RMZHL
                                            LV_CANCEL_FLAG.
      IF LV_CANCEL_FLAG = 'E'.

*          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*          READ TABLE lt_return INTO DATA(ls_return)  WITH KEY type = 'E'.
*          IF sy-subrc = 0.
        IF LV_RUECK IS INITIAL.
          PERFORM RETURN_MESSAGE_CON  USING 'E'
*                                              ls_return-message
                                           TEXT-M04
                                            '  '
                                            '  '
                                            LV_EXTID.
          PERFORM SAVE_LOG_CON_CANCEL  USING 'E'
*                                        ls_return-message
                                      TEXT-M04
                                      '  '
                                      '  '
                                      LV_EXTID
                                      PV_TIMESTAMP
                                      PV_SYSTEM_ID
                                      PV_MODE.
        ENDIF.
        EXIT.
      ENDIF.

    ENDLOOP.

    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'A'
                                       OR  TYPE = 'E'
                                       OR  TYPE = 'X'.

      PERFORM RETURN_MESSAGE_CON  USING 'E'
                                      LS_DETAIL-MESSAGE
                                      '  '
                                      '  '
                                      PV_EXTID.

      PERFORM SAVE_LOG_CON  USING 'E'
                                  LS_DETAIL-MESSAGE
                                  '  '
                                  '  '
                                  PV_EXTID
                                  PV_TIMESTAMP
                                  PV_SYSTEM_ID
                                  PV_MODE.

      EXIT.
    ENDLOOP.

    PV_BAPI_FLAG = 'X'.


    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'E'
                                       AND  ID = 'CO'
                       AND  ( NUMBER = '469' OR NUMBER = '341' ).
      WAIT UP TO '0.1' SECONDS.
      IF PV_COUNT < 21.
        PV_COUNT = PV_COUNT + 1.
        PERFORM BAPI_PRODORDCONF_CREATE_TT_A2 TABLES PT_GOODSMOVEMENTS
                                                     PT_RETURN
                                               USING PV_FIN_CONF
                                                     PV_CLEAR_RES
                                                     PV_ISM06
                                                     PV_EXTID
                                                     PV_BAPI_FLAG
                                                     PV_TIMESTAMP
                                                     PV_SYSTEM_ID
                                                     PV_MODE
                                                     PV_COUNT.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_prodordconf_create_tt_b2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_GOODSMOVEMENTS
*&      --> LV_FIN_CONF
*&      --> LV_CLEAR_RES
*&      --> LV_ISM08
*&      --> PV_EXTID
*&      --> PV_BAPI_FLAG
*&      --> PV_TIMESTAMP
*&      --> PV_SYSTEM_ID
*&      --> PV_MODE
*&---------------------------------------------------------------------*
FORM BAPI_PRODORDCONF_CREATE_TT_B2  TABLES PT_GOODSMOVEMENTS
                                STRUCTURE BAPI2017_GM_ITEM_CREATE
                                  USING PV_FIN_CONF
                                        PV_CLEAR_RES
                                        PV_ISM08
                                        PV_EXTID
                                        PV_BAPI_FLAG
                                        PV_ISM06            "20241220
                                        PV_TIMESTAMP
                                        PV_SYSTEM_ID
                                        PV_MODE
                                        PV_COUNT TYPE N.


  DATA: LT_TT      TYPE TABLE OF BAPI_PP_TIMETICKET,
        LT_GOODS   TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_DETAIL  TYPE TABLE OF BAPI_CORU_RETURN,
        LS_DETAIL  TYPE BAPI_CORU_RETURN,
        LS_RETURN  TYPE BAPIRET1,
        LV_MESSAGE TYPE BAPI_CORU_RETURN-MESSAGE.
  DATA : LT_RETURN         LIKE TABLE OF BAPIRET1,
         LV_RUECK          TYPE BAPI_PP_CONF_KEY-CONF_NO,
         LV_RMZHL          TYPE BAPI_PP_CONF_KEY-CONF_CNT,
         LV_EXTID(32),
         LV_CANCEL_FLAG(1).


  CLEAR : LT_TT, LT_GOODS, LT_DETAIL, LS_RETURN, LV_MESSAGE, LS_DETAIL.

  " pv_ism08 값이 있을 때만 bapi 수행
  LT_TT = VALUE #( ( ORDERID         = GS_CON-AUFNR
                     OPERATION       = GS_CON-VORNR
                     FIN_CONF        = PV_FIN_CONF
                     CLEAR_RES       = PV_CLEAR_RES
                     POSTG_DATE      = GS_CON-BUDAT
                     DEV_REASON      = 'RW01'
                     PLANT           = GS_CON-WERKS
                     WORK_CNTR       = GS_CON-ARBPL
                     YIELD           = '' " 공란
                     SCRAP           = '' " 공란
                     REWORK          = '' " 공란
                     CONF_TEXT       = '' " 공란
                     CONF_ACTIVITY1  = '' " 공란
                     CONF_ACTI_UNIT1 = GS_CON-ILE01
                     CONF_ACTIVITY2  = PV_ISM08
                     CONF_ACTI_UNIT2 = GS_CON-ILE08
                     CONF_ACTIVITY3  = PV_ISM08
                     CONF_ACTI_UNIT3 = GS_CON-ILE08
                     CONF_ACTIVITY4  = PV_ISM08
                     CONF_ACTI_UNIT4 = GS_CON-ILE08
                     CONF_ACTIVITY5  = PV_ISM08
                     CONF_ACTI_UNIT5 = GS_CON-ILE08
*- Start 2024.12.20
*                     conf_activity6  = gs_con-ism06
                     CONF_ACTIVITY6 = PV_ISM06
*- End 2024.12.20
                     CONF_ACTI_UNIT6 = GS_CON-ILE06
                     EXEC_START_DATE = GS_CON-ISDD
                     EXEC_START_TIME = GS_CON-ISDZ
                     PROC_FIN_DATE   = GS_CON-IEDD
                     PROC_FIN_TIME   = GS_CON-IEDZ
                     EX_IDENT        = PV_EXTID
                     PERS_NO         = GS_CON-PERNR   ) ).

*- 생산 실적 처리
  CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
    IMPORTING
      RETURN         = LS_RETURN
    TABLES
      TIMETICKETS    = LT_TT
      GOODSMOVEMENTS = PT_GOODSMOVEMENTS
      DETAIL_RETURN  = LT_DETAIL.
*  WAIT UP TO 2 SECONDS.
*- 성공
  IF LS_RETURN IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    LS_DETAIL = VALUE #( LT_DETAIL[ 1 ] OPTIONAL ).

    PERFORM RETURN_MESSAGE_CON_C  USING 'S'
                                      LS_DETAIL-MESSAGE
                                      LS_DETAIL-CONF_NO
                                      LS_DETAIL-CONF_CNT
                                      PV_EXTID.

    PERFORM SAVE_LOG_CON  USING 'S'
                                LS_DETAIL-MESSAGE
                                LS_DETAIL-CONF_NO
                                LS_DETAIL-CONF_CNT
                                PV_EXTID
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE.

****- 생산오더 전송 프로그램 호출(zgtppi2010)
***    PERFORM call_transaction_zgtppi2010.

    PV_BAPI_FLAG = 'B'.
*- 실패
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*- 확정 외부 ID KEY 생성
    CLEAR : LV_EXTID.
    LV_EXTID = GS_CON-RU_EXTID.
    LOOP AT   GT_GR_RESULT_C INTO  GS_GR_RESULT_C .

      PERFORM BAPI_PRODORDCONF_CANCEL TABLES LT_RETURN
                                      USING GS_GR_RESULT_C-RUECK
                                            GS_GR_RESULT_C-RMZHL
                                            GS_CON-BUDAT
                                            LV_RUECK
                                            LV_RMZHL
                                            LV_CANCEL_FLAG.
      IF LV_CANCEL_FLAG = 'E'.

*          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*          READ TABLE lt_return INTO DATA(ls_return)  WITH KEY type = 'E'.
*          IF sy-subrc = 0.
        IF LV_RUECK IS INITIAL.
          PERFORM RETURN_MESSAGE_CON  USING 'E'
*                                              ls_return-message
                                           TEXT-M04
                                            '  '
                                            '  '
                                            LV_EXTID.
          PERFORM SAVE_LOG_CON_CANCEL  USING 'E'
*                                        ls_return-message
                                      TEXT-M04
                                      '  '
                                      '  '
                                      LV_EXTID
                                      PV_TIMESTAMP
                                      PV_SYSTEM_ID
                                      PV_MODE.
        ENDIF.
        EXIT.
      ENDIF.

    ENDLOOP.


    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'A'
                                       OR  TYPE = 'E'
                                       OR  TYPE = 'X'.

      PERFORM RETURN_MESSAGE_CON  USING 'E'
                                      LS_DETAIL-MESSAGE
                                      '  '
                                      '  '
                                      PV_EXTID.

      PERFORM SAVE_LOG_CON  USING 'E'
                                  LS_DETAIL-MESSAGE
                                  '  '
                                  '  '
                                  PV_EXTID
                                  PV_TIMESTAMP
                                  PV_SYSTEM_ID
                                  PV_MODE.

      EXIT.
    ENDLOOP.

    PV_BAPI_FLAG = 'X'.

    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'E'
                                       AND  ID = 'CO'
                         AND  ( NUMBER = '469' OR NUMBER = '341' ).
      WAIT UP TO '0.1' SECONDS.
      IF PV_COUNT < 21.
        PV_COUNT = PV_COUNT + 1.
        PERFORM BAPI_PRODORDCONF_CREATE_TT_B2
                                    TABLES PT_GOODSMOVEMENTS
                                    USING PV_FIN_CONF
                                          PV_CLEAR_RES
                                          PV_ISM08
                                          PV_EXTID
                                          PV_BAPI_FLAG
                                          PV_ISM06          "20241220
                                          PV_TIMESTAMP
                                          PV_SYSTEM_ID
                                          PV_MODE
                                          PV_COUNT.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_prodordconf_create_tt_d2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_GOODSMOVEMENTS
*&      --> LV_FIN_CONF
*&      --> LV_CLEAR_RES
*&      --> LV_ISM09
*&      --> PV_EXTID
*&      --> PV_BAPI_FLAG
*&      --> LV_ISM06
*&      --> PV_TIMESTAMP
*&      --> PV_SYSTEM_ID
*&      --> PV_MODE
*&---------------------------------------------------------------------*
FORM BAPI_PRODORDCONF_CREATE_TT_D2  TABLES PT_GOODSMOVEMENTS
                                STRUCTURE BAPI2017_GM_ITEM_CREATE
                                  USING PV_FIN_CONF
                                        PV_CLEAR_RES
                                        PV_ISM09
                                        PV_EXTID
                                        PV_BAPI_FLAG
                                        PV_ISM06
                                        PV_TIMESTAMP
                                        PV_SYSTEM_ID
                                        PV_MODE
                                        PV_COUNT TYPE N
                                        .


  DATA: LT_TT      TYPE TABLE OF BAPI_PP_TIMETICKET,
        LT_GOODS   TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_DETAIL  TYPE TABLE OF BAPI_CORU_RETURN,
        LS_DETAIL  TYPE BAPI_CORU_RETURN,
        LS_RETURN  TYPE BAPIRET1,
        LV_MESSAGE TYPE BAPI_CORU_RETURN-MESSAGE.
  DATA : LT_RETURN         LIKE TABLE OF BAPIRET1,
         LV_RUECK          TYPE BAPI_PP_CONF_KEY-CONF_NO,
         LV_RMZHL          TYPE BAPI_PP_CONF_KEY-CONF_CNT,
         LV_EXTID(32),
         LV_CANCEL_FLAG(1).

  CLEAR : LT_TT, LT_GOODS, LT_DETAIL, LS_RETURN, LV_MESSAGE, LS_DETAIL.


  LT_TT = VALUE #( ( ORDERID         = GS_CON-AUFNR
                     OPERATION       = GS_CON-VORNR
                     FIN_CONF        = PV_FIN_CONF
                     CLEAR_RES       = PV_CLEAR_RES
                     POSTG_DATE      = GS_CON-BUDAT
                     DEV_REASON      = 'CH02'
                     PLANT           = GS_CON-WERKS
                     WORK_CNTR       = GS_CON-ARBPL
                     YIELD           = '' " 공란
                     SCRAP           = '' " 공란
                     REWORK          = '' " 공란
                     CONF_TEXT       = '' " 공란
                     CONF_ACTIVITY1  = '' " 공란
                     CONF_ACTI_UNIT1 = '' " 공란
                     CONF_ACTIVITY2  = PV_ISM09
                     CONF_ACTI_UNIT2 = GS_CON-ILE09
                     CONF_ACTIVITY3  = PV_ISM09
                     CONF_ACTI_UNIT3 = GS_CON-ILE09
                     CONF_ACTIVITY4  = PV_ISM09
                     CONF_ACTI_UNIT4 = GS_CON-ILE09
                     CONF_ACTIVITY5  = PV_ISM09
                     CONF_ACTI_UNIT5 = GS_CON-ILE09
                     CONF_ACTIVITY6  = PV_ISM06
                     CONF_ACTI_UNIT6 = GS_CON-ILE06
                     EXEC_START_DATE = GS_CON-ISDD
                     EXEC_START_TIME = GS_CON-ISDZ
                     PROC_FIN_DATE   = GS_CON-IEDD
                     PROC_FIN_TIME   = GS_CON-IEDZ
                     EX_IDENT        = PV_EXTID
                     PERS_NO         = GS_CON-PERNR   ) ).

*- 생산 실적 처리
  CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
    IMPORTING
      RETURN         = LS_RETURN
    TABLES
      TIMETICKETS    = LT_TT
      GOODSMOVEMENTS = PT_GOODSMOVEMENTS
      DETAIL_RETURN  = LT_DETAIL.
*  WAIT UP TO 2 SECONDS.
*- 성공
  IF LS_RETURN IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    LS_DETAIL = VALUE #( LT_DETAIL[ 1 ] OPTIONAL ).

    PERFORM RETURN_MESSAGE_CON_C  USING 'S'
                                      LS_DETAIL-MESSAGE
                                      LS_DETAIL-CONF_NO
                                      LS_DETAIL-CONF_CNT
                                      PV_EXTID.

    PERFORM SAVE_LOG_CON  USING 'S'
                                LS_DETAIL-MESSAGE
                                LS_DETAIL-CONF_NO
                                LS_DETAIL-CONF_CNT
                                PV_EXTID
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE.

****- 생산오더 전송 프로그램 호출(zgtppi2010)
***    PERFORM call_transaction_zgtppi2010.

    PV_BAPI_FLAG = 'D'.
*- 실패
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*- 확정 외부 ID KEY 생성
    CLEAR : LV_EXTID.
    LV_EXTID = GS_CON-RU_EXTID.
    LOOP AT   GT_GR_RESULT_C INTO  GS_GR_RESULT_C .

      PERFORM BAPI_PRODORDCONF_CANCEL TABLES LT_RETURN
                                      USING GS_GR_RESULT_C-RUECK
                                            GS_GR_RESULT_C-RMZHL
                                            GS_CON-BUDAT
                                            LV_RUECK
                                            LV_RMZHL
                                            LV_CANCEL_FLAG.
      IF LV_CANCEL_FLAG = 'E'.

*          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*          READ TABLE lt_return INTO DATA(ls_return)  WITH KEY type = 'E'.
*          IF sy-subrc = 0.
        IF LV_RUECK IS INITIAL.
          PERFORM RETURN_MESSAGE_CON  USING 'E'
*                                              ls_return-message
                                           TEXT-M04
                                            '  '
                                            '  '
                                            LV_EXTID.
          PERFORM SAVE_LOG_CON_CANCEL  USING 'E'
*                                        ls_return-message
                                      TEXT-M04
                                      '  '
                                      '  '
                                      LV_EXTID
                                      PV_TIMESTAMP
                                      PV_SYSTEM_ID
                                      PV_MODE.
        ENDIF.
        EXIT.
      ENDIF.

    ENDLOOP.

    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'A'
                                       OR  TYPE = 'E'
                                       OR  TYPE = 'X'.

      PERFORM RETURN_MESSAGE_CON  USING 'E'
                                      LS_DETAIL-MESSAGE
                                      '  '
                                      '  '
                                      PV_EXTID.

      PERFORM SAVE_LOG_CON  USING 'E'
                                  LS_DETAIL-MESSAGE
                                  '  '
                                  '  '
                                  PV_EXTID
                                  PV_TIMESTAMP
                                  PV_SYSTEM_ID
                                  PV_MODE.

      EXIT.
    ENDLOOP.

    PV_BAPI_FLAG = 'X'.

    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'E'
                                       AND  ID = 'CO'
                          AND ( NUMBER = '469' OR NUMBER = '341' ).
      WAIT UP TO '0.1' SECONDS.
      IF PV_COUNT < 21.
        PV_COUNT = PV_COUNT + 1.
        PERFORM BAPI_PRODORDCONF_CREATE_TT_D2 TABLES PT_GOODSMOVEMENTS
                                               USING PV_FIN_CONF
                                                     PV_CLEAR_RES
                                                     PV_ISM09
                                                     PV_EXTID
                                                     PV_BAPI_FLAG
                                                     PV_ISM06
                                                     PV_TIMESTAMP
                                                     PV_SYSTEM_ID
                                                     PV_MODE
                                                     PV_COUNT.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_prodordconf_create_tt_e2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_GOODSMOVEMENTS
*&      --> LV_FIN_CONF
*&      --> LV_CLEAR_RES
*&      --> LV_ISM10
*&      --> PV_EXTID
*&      --> PV_BAPI_FLAG
*&      --> LV_ISM06
*&      --> PV_TIMESTAMP
*&      --> PV_SYSTEM_ID
*&      --> PV_MODE
*&---------------------------------------------------------------------*
FORM BAPI_PRODORDCONF_CREATE_TT_E2  TABLES PT_GOODSMOVEMENTS
                                STRUCTURE BAPI2017_GM_ITEM_CREATE
                                  USING PV_FIN_CONF
                                        PV_CLEAR_RES
                                        PV_ISM10
                                        PV_EXTID
                                        PV_BAPI_FLAG
                                        PV_ISM06
                                        PV_TIMESTAMP
                                        PV_SYSTEM_ID
                                        PV_MODE
                                        PV_COUNT TYPE N
                                        .


  DATA: LT_TT      TYPE TABLE OF BAPI_PP_TIMETICKET,
        LT_GOODS   TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_DETAIL  TYPE TABLE OF BAPI_CORU_RETURN,
        LS_DETAIL  TYPE BAPI_CORU_RETURN,
        LS_RETURN  TYPE BAPIRET1,
        LV_MESSAGE TYPE BAPI_CORU_RETURN-MESSAGE.
  DATA : LT_RETURN         LIKE TABLE OF BAPIRET1,
         LV_RUECK          TYPE BAPI_PP_CONF_KEY-CONF_NO,
         LV_RMZHL          TYPE BAPI_PP_CONF_KEY-CONF_CNT,
         LV_EXTID(32),
         LV_CANCEL_FLAG(1).

  CLEAR : LT_TT, LT_GOODS, LT_DETAIL, LS_RETURN, LV_MESSAGE, LS_DETAIL.


  LT_TT = VALUE #( ( ORDERID         = GS_CON-AUFNR
                     OPERATION       = GS_CON-VORNR
                     FIN_CONF        = PV_FIN_CONF
                     CLEAR_RES       = PV_CLEAR_RES
                     POSTG_DATE      = GS_CON-BUDAT
                     DEV_REASON      = 'CH03'
                     PLANT           = GS_CON-WERKS
                     WORK_CNTR       = GS_CON-ARBPL
                     YIELD           = '' " 공란
                     SCRAP           = '' " 공란
                     REWORK          = '' " 공란
                     CONF_TEXT       = '' " 공란
                     CONF_ACTIVITY1  = '' " 공란
                     CONF_ACTI_UNIT1 = '' " 공란
                     CONF_ACTIVITY2  = PV_ISM10
                     CONF_ACTI_UNIT2 = GS_CON-ILE10
                     CONF_ACTIVITY3  = PV_ISM10
                     CONF_ACTI_UNIT3 = GS_CON-ILE10
                     CONF_ACTIVITY4  = PV_ISM10
                     CONF_ACTI_UNIT4 = GS_CON-ILE10
                     CONF_ACTIVITY5  = PV_ISM10
                     CONF_ACTI_UNIT5 = GS_CON-ILE10
                     CONF_ACTIVITY6  = PV_ISM06
                     CONF_ACTI_UNIT6 = GS_CON-ILE06
                     EXEC_START_DATE = GS_CON-ISDD
                     EXEC_START_TIME = GS_CON-ISDZ
                     PROC_FIN_DATE   = GS_CON-IEDD
                     PROC_FIN_TIME   = GS_CON-IEDZ
                     EX_IDENT        = PV_EXTID
                     PERS_NO         = GS_CON-PERNR   ) ).

*- 생산 실적 처리
  CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
    IMPORTING
      RETURN         = LS_RETURN
    TABLES
      TIMETICKETS    = LT_TT
      GOODSMOVEMENTS = PT_GOODSMOVEMENTS
      DETAIL_RETURN  = LT_DETAIL.

*  WAIT UP TO 2 SECONDS.
*- 성공
  IF LS_RETURN IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    LS_DETAIL = VALUE #( LT_DETAIL[ 1 ] OPTIONAL ).

    PERFORM RETURN_MESSAGE_CON_C  USING 'S'
                                      LS_DETAIL-MESSAGE
                                      LS_DETAIL-CONF_NO
                                      LS_DETAIL-CONF_CNT
                                      PV_EXTID.

    PERFORM SAVE_LOG_CON  USING 'S'
                                LS_DETAIL-MESSAGE
                                LS_DETAIL-CONF_NO
                                LS_DETAIL-CONF_CNT
                                PV_EXTID
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE.

****- 생산오더 전송 프로그램 호출(zgtppi2010)
***    PERFORM call_transaction_zgtppi2010.

    PV_BAPI_FLAG = 'E'.
*- 실패
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*- 확정 외부 ID KEY 생성
    CLEAR : LV_EXTID.
    LV_EXTID = GS_CON-RU_EXTID.
    LOOP AT   GT_GR_RESULT_C INTO  GS_GR_RESULT_C .

      PERFORM BAPI_PRODORDCONF_CANCEL TABLES LT_RETURN
                                      USING GS_GR_RESULT_C-RUECK
                                            GS_GR_RESULT_C-RMZHL
                                            GS_CON-BUDAT
                                            LV_RUECK
                                            LV_RMZHL
                                            LV_CANCEL_FLAG.
      IF LV_CANCEL_FLAG = 'E'.

*          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*          READ TABLE lt_return INTO DATA(ls_return)  WITH KEY type = 'E'.
*          IF sy-subrc = 0.
        IF LV_RUECK IS INITIAL.
          PERFORM RETURN_MESSAGE_CON  USING 'E'
*                                              ls_return-message
                                           TEXT-M04
                                            '  '
                                            '  '
                                            LV_EXTID.
          PERFORM SAVE_LOG_CON_CANCEL  USING 'E'
*                                        ls_return-message
                                      TEXT-M04
                                      '  '
                                      '  '
                                      LV_EXTID
                                      PV_TIMESTAMP
                                      PV_SYSTEM_ID
                                      PV_MODE.
        ENDIF.
        EXIT.
      ENDIF.

    ENDLOOP.

    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'A'
                                       OR  TYPE = 'E'
                                       OR  TYPE = 'X'.

      PERFORM RETURN_MESSAGE_CON  USING 'E'
                                      LS_DETAIL-MESSAGE
                                      '  '
                                      '  '
                                      PV_EXTID.

      PERFORM SAVE_LOG_CON  USING 'E'
                                  LS_DETAIL-MESSAGE
                                  '  '
                                  '  '
                                  PV_EXTID
                                  PV_TIMESTAMP
                                  PV_SYSTEM_ID
                                  PV_MODE.

      EXIT.
    ENDLOOP.

    PV_BAPI_FLAG = 'X'.

    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'E'
                                       AND  ID = 'CO'
                         AND ( NUMBER = '469' OR NUMBER = '341' ).
      WAIT UP TO '0.1' SECONDS.
      IF PV_COUNT < 21.
        PV_COUNT = PV_COUNT + 1.
        PERFORM BAPI_PRODORDCONF_CREATE_TT_E2 TABLES PT_GOODSMOVEMENTS
                                               USING PV_FIN_CONF
                                                     PV_CLEAR_RES
                                                     PV_ISM10
                                                     PV_EXTID
                                                     PV_BAPI_FLAG
                                                     PV_ISM06
                                                     PV_TIMESTAMP
                                                     PV_SYSTEM_ID
                                                     PV_MODE
                                                     PV_COUNT.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_prodordconf_create_lock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_CON_AUFNR
*&      --> LV_LOCK_CHK_FLAG
*&---------------------------------------------------------------------*
FORM CHECK_PRODORDCONF_CREATE_LOCK  USING   PV_AUFNR
                                            PV_LOCK_CHK_FLAG
                                            PV_TIMESTAMP
                                            PV_SYSTEM_ID
                                            PV_MODE
                                             .

  DATA : LT_ENQ    TYPE SEQG3  OCCURS 0 WITH HEADER LINE.
  DATA : LV_GARG   TYPE  SEQG3-GARG,
         LV_NUMBER TYPE  SY-TABIX,
         LV_SUBRC  TYPE  SY-SUBRC.

  DATA : LV_MESSAGE(220).


  CONCATENATE SY-MANDT GS_CON-AUFNR
         INTO LV_GARG.

  DO 50 TIMES.

    CALL FUNCTION 'ENQUEUE_READ'
      EXPORTING
        GCLIENT               = SY-MANDT
        GNAME                 = 'AUFK'  "AUFK
        GARG                  = LV_GARG "CLIENT 번호 + 현재 오더번호
      IMPORTING
        NUMBER                = LV_NUMBER
        SUBRC                 = LV_SUBRC
      TABLES
        ENQ                   = LT_ENQ  "값이 있으면 현재 오더 누가 잡고 있다 .WHILE ENQ 있으면 0.1
      EXCEPTIONS
        COMMUNICATION_FAILURE = 1
        SYSTEM_FAILURE        = 2
        OTHERS                = 3.

    IF LT_ENQ[] IS INITIAL.
      CLEAR: LT_ENQ[],LT_ENQ.
      PV_LOCK_CHK_FLAG = 'S'.
      EXIT.
    ELSE.
      PV_LOCK_CHK_FLAG = 'E'.
      WAIT UP TO '0.1' SECONDS.
    ENDIF.

  ENDDO.

  IF PV_LOCK_CHK_FLAG = 'E'.
    CONCATENATE '오더번호('
                GS_CON-AUFNR
                ')이 처리중입니다'
           INTO LV_MESSAGE .

    PERFORM RETURN_MESSAGE_CON  USING 'E'
                                      LV_MESSAGE
                                      ''
                                      ''
                                      ''.

    PERFORM SAVE_LOG_CON  USING 'E'
                                LV_MESSAGE
                                ''
                                ''
                                ''
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE          .
  ENDIF.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_common_con_bd
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERROR
*&---------------------------------------------------------------------*
FORM CHECK_COMMON_CON_BD  USING  PV_ERROR.

  DATA : LV_MESSAGE(220).

*- 플랜트
  SELECT SINGLE MANDT
   FROM T001W
   WHERE WERKS = @GS_CON-WERKS
   INTO @SY-MANDT.
  IF SY-SUBRC <> 0.

    PERFORM RETURN_MESSAGE_CON  USING 'E'
                                      '존재하지 않는 플랜트 입니다.'
                                      '  '
                                      '  '
                                      '  '.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

*- 플랜트 유효성 체크
  IF GS_CON-WERKS <> '1306'  .

    PERFORM RETURN_MESSAGE_CON  USING 'E'
                                      '유효한 플랜트가 아닙니다.'
                                      '  '
                                      '  '
                                      '  '.
    PV_ERROR = 'X'.
    EXIT.

  ENDIF.


*- 생산오더 번호
  SELECT SINGLE MANDT
    FROM AUFK
    WHERE AUFNR = @GS_CON-AUFNR
    INTO @SY-MANDT.
  IF SY-SUBRC <> 0.

    PERFORM RETURN_MESSAGE_CON USING 'E'
                                     '존재하지 않는 생산오더 입니다.'
                                     '  '
                                     '  '
                                     '  '.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

*- start 2025.02.11
  "수신받은 데이터의 생산오더 시작일자의 월과 전기일자의 월이 서로 다른 경우
  DATA : LV_GSTRP TYPE AFKO-GSTRP.

  DATA : LV_AFKO_DATE(2)  TYPE N,
         LV_GSCON_DATE(2) TYPE N.

  SELECT SINGLE GSTRP
    INTO LV_GSTRP
    FROM AFKO
   WHERE AUFNR = GS_CON-AUFNR.
  IF LV_GSTRP IS NOT INITIAL.
    LV_AFKO_DATE = LV_GSTRP+4(2).
    LV_GSCON_DATE = GS_CON-BUDAT+4(2).
    IF LV_AFKO_DATE <> LV_GSCON_DATE.
      PERFORM RETURN_MESSAGE_CON USING 'E'
                                       '생산오더의 월과 전기일자의 월이 서로 다릅니다.'
                                       '  '
                                       '  '
                                       '  '.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.
*- end 2025.02.11


*- 생산오더 상태
  PERFORM GET_STATUS_CON USING PV_ERROR.


  IF PV_ERROR = 'X'.

    PERFORM RETURN_MESSAGE_CON   USING 'E'
                                       '오더상태를 체크하시기 바랍니다.'
                                       '  '
                                       '  '
                                       '  '.
  ENDIF.


*- 25.09.11 Strart 생산오더 Lock 점검 추가
  PERFORM CHECK_PRODORDCONF_CREATE_LOCK2
                                   USING  GS_CON-AUFNR
                                               PV_ERROR
                                               LV_MESSAGE
                                               ' '
                                               ' '.

  IF PV_ERROR = 'X'.

    PERFORM RETURN_MESSAGE_CON   USING 'E'
                                       LV_MESSAGE "오더번호 &&을 &&가 처리중입니다."
                                       '  '
                                       '  '
                                       '  '.
  ENDIF.
*- 25.09.11 End 생산오더 Lock 점검 추가

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_prodordconf_create_tt_abd
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_GOODSMOVEMENTS
*&      --> PT_RETURN
*&      --> PV_FIN_CONF
*&      --> PV_CLEAR_RES
*&      --> PV_ISM06
*&      --> PV_EXTID
*&      --> PV_BAPI_FLAG
*&      --> PV_TIMESTAMP
*&      --> PV_SYSTEM_ID
*&      --> PV_MODE
*&      --> PV_COUNT
*&---------------------------------------------------------------------*
FORM BAPI_PRODORDCONF_CREATE_TT_AB  TABLES PT_GOODSMOVEMENTS
                                 STRUCTURE BAPI2017_GM_ITEM_CREATE
                                  PT_RETURN STRUCTURE BAPIRET1
                                  USING PV_FIN_CONF
                                        PV_CLEAR_RES
                                        PV_ISM06
                                        PV_EXTID
                                        PV_BAPI_FLAG
                                        PV_TIMESTAMP
                                        PV_SYSTEM_ID
                                        PV_MODE
                                        PV_COUNT TYPE N
                                        .


  DATA: LT_TT      TYPE TABLE OF BAPI_PP_TIMETICKET,
        LT_GOODS   TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_DETAIL  TYPE TABLE OF BAPI_CORU_RETURN,
        LS_DETAIL  TYPE BAPI_CORU_RETURN,
        LS_RETURN  TYPE BAPIRET1,
        LV_MESSAGE TYPE BAPI_CORU_RETURN-MESSAGE.
  DATA : LT_RETURN         LIKE TABLE OF BAPIRET1,
         LV_RUECK          TYPE BAPI_PP_CONF_KEY-CONF_NO,
         LV_RMZHL          TYPE BAPI_PP_CONF_KEY-CONF_CNT,
         LV_EXTID(32),
         LV_CONF_TEXT(40),
         LV_CANCEL_FLAG(1).

*  DATA : LV_MENGE(17).

  CLEAR : LT_TT, LT_GOODS, LT_DETAIL, LS_RETURN, LV_MESSAGE, LS_DETAIL,
          LV_CONF_TEXT.

*  write gs_con-menge  to LV_MENGE    unit gs_con-MEINH..



  LT_TT = VALUE #( ( ORDERID         = GS_CON-AUFNR
                     OPERATION       = GS_CON-VORNR
                     FIN_CONF        = '1' "pv_fin_conf
                     CLEAR_RES       = PV_CLEAR_RES
                     POSTG_DATE      = GS_CON-BUDAT
                     DEV_REASON      = ''
                     PLANT           = GS_CON-WERKS
                     WORK_CNTR       = GS_CON-ARBPL
                     YIELD           = GS_CON-LMNGA
                     SCRAP           = ''
                     REWORK          = ''
                     CONF_TEXT       = GS_CON-TAGNR
                     CONF_ACTIVITY1  = ''
                     CONF_ACTI_UNIT1 = GS_CON-ILE01
                     CONF_ACTIVITY2  = ''
                     CONF_ACTI_UNIT2 = GS_CON-ILE01
                     CONF_ACTIVITY3  = ''
                     CONF_ACTI_UNIT3 = GS_CON-ILE01
                     CONF_ACTIVITY4  = ''
                     CONF_ACTI_UNIT4 = GS_CON-ILE01
                     CONF_ACTIVITY5  = ''
                     CONF_ACTI_UNIT5 = GS_CON-ILE01
                     CONF_ACTIVITY6  = ''
                     CONF_ACTI_UNIT6 = GS_CON-ILE01
                     EXEC_START_DATE = GS_CON-ISDD
                     EXEC_START_TIME = GS_CON-ISDZ
                     PROC_FIN_DATE   = GS_CON-IEDD
                     PROC_FIN_TIME   = GS_CON-IEDZ
                     EX_IDENT        = PV_EXTID
                     PERS_NO         = GS_CON-PERNR   ) ).

*- 생산 실적 처리
  CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
    IMPORTING
      RETURN         = LS_RETURN
    TABLES
      TIMETICKETS    = LT_TT
      GOODSMOVEMENTS = PT_GOODSMOVEMENTS
      DETAIL_RETURN  = LT_DETAIL.

*  WAIT UP TO 2 SECONDS.
*- 성공
  IF LS_RETURN IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    LS_DETAIL = VALUE #( LT_DETAIL[ 1 ] OPTIONAL ).

    PERFORM RETURN_MESSAGE_CON_CBD  USING 'S'
                                      LS_DETAIL-MESSAGE
                                      LS_DETAIL-CONF_NO
                                      LS_DETAIL-CONF_CNT
                                      PV_EXTID.

    PERFORM SAVE_LOG_CON  USING 'S'
                                LS_DETAIL-MESSAGE
                                LS_DETAIL-CONF_NO
                                LS_DETAIL-CONF_CNT
                                PV_EXTID
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE
                                .

*- 생산오더 전송 프로그램 호출(zgtppi2010)
***    PERFORM call_transaction_zgtppi2010.

    PV_BAPI_FLAG = 'A'.
*- 실패
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*- 확정 외부 ID KEY 생성
    CLEAR : LV_EXTID.
    LV_EXTID = GS_CON-RU_EXTID.
***  Start 25.09.11 지중과 동일하게 성공처리한 실적 취소 처리
    LOOP AT   GT_GR_RESULT_C INTO  GS_GR_RESULT_C .

      PERFORM BAPI_PRODORDCONF_CANCEL TABLES LT_RETURN
                                      USING GS_GR_RESULT_C-RUECK
                                            GS_GR_RESULT_C-RMZHL
                                            GS_CON-BUDAT
                                            LV_RUECK
                                            LV_RMZHL
                                            LV_CANCEL_FLAG.
      IF LV_CANCEL_FLAG = 'E'.

*          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*          READ TABLE lt_return INTO DATA(ls_return)  WITH KEY type = 'E'.
*          IF sy-subrc = 0.
        IF LV_RUECK IS INITIAL.
          PERFORM RETURN_MESSAGE_CON_BD  USING 'E'
*                                              ls_return-message
                                           TEXT-M04
                                            '  '
                                            '  '
                                            LV_EXTID.

          PERFORM SAVE_LOG_CON_CANCEL  USING 'E'
*                                        ls_return-message
                                      TEXT-M04
                                      '  '
                                      '  '
                                      LV_EXTID
                                      PV_TIMESTAMP
                                      PV_SYSTEM_ID
                                      PV_MODE.
        ENDIF.
        EXIT.
      ENDIF.

    ENDLOOP.
***  Start 25.09.11 지중과 동일하게 성공처리한 실적 취소 처리



    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'A'
                                       OR  TYPE = 'E'
                                       OR  TYPE = 'X'.

      PERFORM RETURN_MESSAGE_CON_BD  USING 'E'
                                      LS_DETAIL-MESSAGE
                                      '  '
                                      '  '
                                      PV_EXTID.

      PERFORM SAVE_LOG_CON  USING 'E'
                                  LS_DETAIL-MESSAGE
                                  '  '
                                  '  '
                                  PV_EXTID
                                  PV_TIMESTAMP
                                  PV_SYSTEM_ID
                                  PV_MODE.

      EXIT.
    ENDLOOP.

    PV_BAPI_FLAG = 'X'.


    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'E'
                                       AND  ID = 'CO'
                           AND ( NUMBER = '469' OR NUMBER = '341' ) .
      WAIT UP TO '0.1' SECONDS.
      IF PV_COUNT < 21.
        PV_COUNT = PV_COUNT + 1.
        PERFORM BAPI_PRODORDCONF_CREATE_TT_AB TABLES PT_GOODSMOVEMENTS
                                                    PT_RETURN
                                                 USING PV_FIN_CONF
                                                       PV_CLEAR_RES
                                                       PV_ISM06
                                                       PV_EXTID
                                                       PV_BAPI_FLAG
                                                       PV_TIMESTAMP
                                                       PV_SYSTEM_ID
                                                       PV_MODE
                                                       PV_COUNT.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_bapi_case_abd
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_GOODSMOVEMENTS
*&      --> LT_RETURN
*&      --> LV_MESSAGE
*&      --> LV_ERROR
*&      --> LV_EXTID
*&      --> P_
*&      --> LV_TIMESTAMP
*&      --> I_SYSTEM_ID
*&      --> I_MODE
*&      --> LV_AUART
*&      <-- LV_BAPI_FLAG
*&---------------------------------------------------------------------*
FORM CALL_BAPI_CASE_ABD  TABLES   PT_GOODSMOVEMENTS
                       STRUCTURE BAPI2017_GM_ITEM_CREATE
                                PT_RETURN STRUCTURE BAPIRET1
                       USING    PV_MESSAGE
                                PV_ERROR
                                PV_EXTID
                                PV_CASE
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE
                                PV_AUART
                       CHANGING PV_BAPI_FLAG.


  DATA : LV_FIN_CONF         LIKE AFRU-AUERU,
         LV_ISM06            LIKE AFRU-ISM06,
         LV_CLEAR_RES(1),
         LV_EXTID(32),
         LV_LOCK_CHK_FLAG(1),
         LV_CHK_FLAG(1),
         LV_BAPI_FLAG(1).

*- 실적처리 체크항목
  CLEAR PT_GOODSMOVEMENTS.
***  IF gs_con-werks = '1306'.
***
***  ELSE.
***    PERFORM check_con TABLES pt_goodsmovements
***                      USING pv_error
***                            pv_extid
***                            pv_case.
***  ENDIF.
***  IF pv_error = 'X'.
***    pv_message = VALUE #( gt_gr_result[ zserno = gs_con-zserno ]-zerp_message OPTIONAL ).
***    PERFORM save_log_con  USING 'E'
***                                pv_message
***                                ''
***                                ''
***                                pv_extid
***                                pv_timestamp
***                                pv_system_id
***                                pv_mode.
***    pv_bapi_flag = 'X'.
***    CLEAR gs_con.
***    EXIT.
***  ENDIF.
***
***  CHECK pv_error <> 'X'.

*- 최종확정 지시자 값 셋팅
***  PERFORM set_fin_conf USING lv_fin_conf
***                             lv_clear_res
***                             'A'.
*- 대체순서에 따른 노무 Activity와 기계 Activity의 비율로 노무 Activity 처리 값 계산

  PERFORM SET_ISMVAL USING LV_ISM06 'A' PV_AUART PV_SYSTEM_ID.

  IF GS_CON-LMNGA IS NOT INITIAL      " 작업 수량  작업 시간 둘다 있는경우
     AND ( GS_CON-ISM01 IS NOT INITIAL
     OR GS_CON-ISM02 IS NOT INITIAL ).

*** Start 25.09.10 실적 '작업시간' 처리를 실적 '수량' 보다 먼저 처리하도록 수정
*  - 실적처리 A  작업시간
    PERFORM BAPI_PRODORDCONF_CREATE_TT_AB2 TABLES PT_GOODSMOVEMENTS
                                                PT_RETURN
                                             USING LV_FIN_CONF
                                                   LV_CLEAR_RES
                                                   LV_ISM06
                                                   PV_EXTID
                                                   PV_BAPI_FLAG
                                                   PV_TIMESTAMP
                                                   PV_SYSTEM_ID
                                                   PV_MODE
                                                   0.
**  - 실적처리 A  수량  tagnr 값 셋팅
*    PERFORM bapi_prodordconf_create_tt_ab TABLES pt_goodsmovements
*                                                pt_return
*                                             USING lv_fin_conf
*                                                   lv_clear_res
*                                                   lv_ism06
*                                                   pv_extid
*                                                   pv_bapi_flag
*                                                   pv_timestamp
*                                                   pv_system_id
*                                                   pv_mode
*                                                   0.
*** End 25.09.10 실적 '작업시간' 처리를 실적 '수량' 보다 먼저 처리하도록 수정

    IF PV_BAPI_FLAG = 'X'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ELSE.
      IF PV_AUART NE 'RW01' OR GV_GAON EQ ABAP_TRUE.
        PERFORM CHECK_PRODORDCONF_CREATE_LOCK USING  GS_CON-AUFNR
                                                   LV_LOCK_CHK_FLAG
                                                   PV_TIMESTAMP
                                                   PV_SYSTEM_ID
                                                   PV_MODE
                                                   .
        IF LV_LOCK_CHK_FLAG = 'S'.
*** Start 25.09.10 실적 '작업시간' 처리를 실적 '수량' 보다 먼저 처리하도록 수정
*  - 실적처리 A  수량  tagnr 값 셋팅
          PERFORM BAPI_PRODORDCONF_CREATE_TT_AB TABLES PT_GOODSMOVEMENTS
                                                      PT_RETURN
                                                   USING LV_FIN_CONF
                                                         LV_CLEAR_RES
                                                         LV_ISM06
                                                         PV_EXTID
                                                         PV_BAPI_FLAG
                                                         PV_TIMESTAMP
                                                         PV_SYSTEM_ID
                                                         PV_MODE
                                                         0.
**  - 실적처리 A  작업시간
*          PERFORM bapi_prodordconf_create_tt_ab2 TABLES pt_goodsmovements
*                                                      pt_return
*                                                   USING lv_fin_conf
*                                                         lv_clear_res
*                                                         lv_ism06
*                                                         pv_extid
*                                                         pv_bapi_flag
*                                                         pv_timestamp
*                                                         pv_system_id
*                                                         pv_mode
*                                                         0.
*** End 25.09.10 실적 '작업시간' 처리를 실적 '수량' 보다 먼저 처리하도록 수정
        ELSE.
          CONCATENATE '오더번호('
                      GS_CON-AUFNR
                      ')이 처리중입니다'
                 INTO PV_MESSAGE .
          PERFORM SAVE_LOG_CON  USING 'E'
                                      PV_MESSAGE
                                      ''
                                      ''
                                      PV_EXTID
                                      PV_TIMESTAMP
                                      PV_SYSTEM_ID
                                      PV_MODE.
          PV_BAPI_FLAG = 'X'.

          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        ENDIF.

      ENDIF.                                                  .
    ENDIF.

  ELSEIF GS_CON-LMNGA IS NOT INITIAL  " 수량만 있는 경우
     AND ( GS_CON-ISM01 IS INITIAL
     OR GS_CON-ISM02 IS INITIAL ) .


*- 실적처리 A  수량  tagnr 값 셋팅
    PERFORM BAPI_PRODORDCONF_CREATE_TT_AB TABLES PT_GOODSMOVEMENTS
                                                PT_RETURN
                                             USING LV_FIN_CONF
                                                   LV_CLEAR_RES
                                                   LV_ISM06
                                                   PV_EXTID
                                                   PV_BAPI_FLAG
                                                   PV_TIMESTAMP
                                                   PV_SYSTEM_ID
                                                   PV_MODE
                                                   0.


  ELSEIF GS_CON-LMNGA IS INITIAL
     AND ( GS_CON-ISM01 IS NOT INITIAL   " 시간만 있는 경우
     OR GS_CON-ISM02 IS NOT INITIAL ).
    IF PV_AUART NE 'RW01' OR GV_GAON EQ ABAP_TRUE.
      PERFORM BAPI_PRODORDCONF_CREATE_TT_AB2 TABLES PT_GOODSMOVEMENTS
                                                  PT_RETURN
                                               USING LV_FIN_CONF
                                                     LV_CLEAR_RES
                                                     LV_ISM06
                                                     PV_EXTID
                                                     PV_BAPI_FLAG
                                                     PV_TIMESTAMP
                                                     PV_SYSTEM_ID
                                                     PV_MODE
                                                     0.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_prodordconf_create_tt_ab2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_GOODSMOVEMENTS
*&      --> PT_RETURN
*&      --> LV_FIN_CONF
*&      --> LV_CLEAR_RES
*&      --> LV_ISM06
*&      --> PV_EXTID
*&      --> PV_BAPI_FLAG
*&      --> PV_TIMESTAMP
*&      --> PV_SYSTEM_ID
*&      --> PV_MODE
*&      --> P_0
*&---------------------------------------------------------------------*
FORM BAPI_PRODORDCONF_CREATE_TT_AB2 TABLES PT_GOODSMOVEMENTS
                                 STRUCTURE BAPI2017_GM_ITEM_CREATE
                                  PT_RETURN STRUCTURE BAPIRET1
                                  USING PV_FIN_CONF
                                        PV_CLEAR_RES
                                        PV_ISM06
                                        PV_EXTID
                                        PV_BAPI_FLAG
                                        PV_TIMESTAMP
                                        PV_SYSTEM_ID
                                        PV_MODE
                                        PV_COUNT TYPE N
                                        .


  DATA: LT_TT      TYPE TABLE OF BAPI_PP_TIMETICKET,
        LT_GOODS   TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_DETAIL  TYPE TABLE OF BAPI_CORU_RETURN,
        LS_DETAIL  TYPE BAPI_CORU_RETURN,
        LS_RETURN  TYPE BAPIRET1,
        LV_MESSAGE TYPE BAPI_CORU_RETURN-MESSAGE.
  DATA : LT_RETURN         LIKE TABLE OF BAPIRET1,
         LV_RUECK          TYPE BAPI_PP_CONF_KEY-CONF_NO,
         LV_RMZHL          TYPE BAPI_PP_CONF_KEY-CONF_CNT,
         LV_EXTID(32),
         LV_CANCEL_FLAG(1).
*  DATA : LV_MENGE(17).

  CLEAR : LT_TT, LT_GOODS, LT_DETAIL, LS_RETURN, LV_MESSAGE, LS_DETAIL.

*  write gs_con-menge  to LV_MENGE    unit gs_con-MEINH..
  LT_TT = VALUE #( ( ORDERID         = GS_CON-AUFNR
                     OPERATION       = GS_CON-VORNR
                     FIN_CONF        = '1' "pv_fin_conf
                     CLEAR_RES       = PV_CLEAR_RES
                     POSTG_DATE      = GS_CON-BUDAT
                     DEV_REASON      = ''
                     PLANT           = GS_CON-WERKS
                     WORK_CNTR       = GS_CON-ARBPL
                     YIELD           = '' " 공란
                     SCRAP           = ''
                     REWORK          = ''
                     CONF_TEXT       = GS_CON-TAGNR
                     CONF_ACTIVITY1  = '' " 공란
                     CONF_ACTI_UNIT1 = '' " 공란
                     CONF_ACTIVITY2  = GS_CON-ISM01
                     CONF_ACTI_UNIT2 = GS_CON-ILE01
                     CONF_ACTIVITY3  = GS_CON-ISM01
                     CONF_ACTI_UNIT3 = GS_CON-ILE01
                     CONF_ACTIVITY4  = GS_CON-ISM01
                     CONF_ACTI_UNIT4 = GS_CON-ILE01
                     CONF_ACTIVITY5  = GS_CON-ISM01
                     CONF_ACTI_UNIT5 = GS_CON-ILE01
                     CONF_ACTIVITY6  = GS_CON-ISM01
                     CONF_ACTI_UNIT6 = GS_CON-ILE01
                     EXEC_START_DATE = GS_CON-ISDD
                     EXEC_START_TIME = GS_CON-ISDZ
                     PROC_FIN_DATE   = GS_CON-IEDD
                     PROC_FIN_TIME   = GS_CON-IEDZ
                     EX_IDENT        = PV_EXTID
                     PERS_NO         = GS_CON-PERNR   ) ).

*- 생산 실적 처리
  CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
    IMPORTING
      RETURN         = LS_RETURN
    TABLES
      TIMETICKETS    = LT_TT
      GOODSMOVEMENTS = PT_GOODSMOVEMENTS
      DETAIL_RETURN  = LT_DETAIL.

*  WAIT UP TO 2 SECONDS.
*- 성공
  IF LS_RETURN IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    LS_DETAIL = VALUE #( LT_DETAIL[ 1 ] OPTIONAL ).

    PERFORM RETURN_MESSAGE_CON_CBD  USING 'S'
                                      LS_DETAIL-MESSAGE
                                      LS_DETAIL-CONF_NO
                                      LS_DETAIL-CONF_CNT
                                      PV_EXTID.

    PERFORM SAVE_LOG_CON  USING 'S'
                                LS_DETAIL-MESSAGE
                                LS_DETAIL-CONF_NO
                                LS_DETAIL-CONF_CNT
                                PV_EXTID
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE
                                .

*- 생산오더 전송 프로그램 호출(zgtppi2010)
***    PERFORM call_transaction_zgtppi2010.

    PV_BAPI_FLAG = 'A'.
*- 실패
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*- 확정 외부 ID KEY 생성
    CLEAR : LV_EXTID.
    LV_EXTID = GS_CON-RU_EXTID.
***  Start. 20250911 수량, 시간 실적 중 오류 발생시 이전의 확정 취소
    LOOP AT   GT_GR_RESULT_C INTO  GS_GR_RESULT_C .

      PERFORM BAPI_PRODORDCONF_CANCEL TABLES LT_RETURN
                                      USING GS_GR_RESULT_C-RUECK
                                            GS_GR_RESULT_C-RMZHL
                                            GS_CON-BUDAT
                                            LV_RUECK
                                            LV_RMZHL
                                            LV_CANCEL_FLAG.
      IF LV_CANCEL_FLAG = 'E'.

*          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*          READ TABLE lt_return INTO DATA(ls_return)  WITH KEY type = 'E'.
*          IF sy-subrc = 0.
        IF LV_RUECK IS INITIAL.
          PERFORM RETURN_MESSAGE_CON_BD  USING 'E'
*                                              ls_return-message
                                           TEXT-M04
                                            '  '
                                            '  '
                                            LV_EXTID.
          PERFORM SAVE_LOG_CON_CANCEL  USING 'E'
*                                        ls_return-message
                                      TEXT-M04
                                      '  '
                                      '  '
                                      LV_EXTID
                                      PV_TIMESTAMP
                                      PV_SYSTEM_ID
                                      PV_MODE.
        ENDIF.
        EXIT.
      ENDIF.

    ENDLOOP.
***  End. 20250911 수량, 시간 실적 중 오류 발생시 이전의 확정 취소


    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'A'
                                       OR  TYPE = 'E'
                                       OR  TYPE = 'X'.

      PERFORM RETURN_MESSAGE_CON  USING 'E'
                                      LS_DETAIL-MESSAGE
                                      '  '
                                      '  '
                                      PV_EXTID.

      PERFORM SAVE_LOG_CON  USING 'E'
                                  LS_DETAIL-MESSAGE
                                  '  '
                                  '  '
                                  PV_EXTID
                                  PV_TIMESTAMP
                                  PV_SYSTEM_ID
                                  PV_MODE.

      EXIT.
    ENDLOOP.

    PV_BAPI_FLAG = 'X'.


    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'E'
                                       AND  ID = 'CO'
                       AND  ( NUMBER = '469' OR NUMBER = '341' ).
      WAIT UP TO '0.1' SECONDS.
      IF PV_COUNT < 21.
        PV_COUNT = PV_COUNT + 1.
        PERFORM BAPI_PRODORDCONF_CREATE_TT_AB2 TABLES PT_GOODSMOVEMENTS
                                                     PT_RETURN
                                               USING PV_FIN_CONF
                                                     PV_CLEAR_RES
                                                     PV_ISM06
                                                     PV_EXTID
                                                     PV_BAPI_FLAG
                                                     PV_TIMESTAMP
                                                     PV_SYSTEM_ID
                                                     PV_MODE
                                                     PV_COUNT.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_prodordconf_cancel_bd
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_RETURN
*&      --> GT_AFRU_RUECK
*&      --> GT_AFRU_RMZHL
*&      --> GT_AFRU_BUDAT
*&      --> LV_RUECK
*&      --> LV_RMZHL
*&      --> LV_CANCEL_FLAG
*&---------------------------------------------------------------------*
FORM BAPI_PRODORDCONF_CANCEL_BD  TABLES PS_RETURN STRUCTURE BAPIRET1
                             USING PV_AFRU_RUECK
                                   PV_AFRU_RMZHL
                                   PV_AFRU_BUDAT
                                   PV_RUECK
                                   PV_RMZHL
                                   PV_CANCEL_FLAG
                                   PV_TAGNR.
  DATA : LS_RETURN  TYPE BAPIRET1,
         LV_RUECK   TYPE BAPI_PP_CONF_KEY-CONF_NO,
         LV_RMZHL   TYPE BAPI_PP_CONF_KEY-CONF_CNT,
         LV_MESSAGE TYPE BAPIRET1-MESSAGE.

  CLEAR : LS_RETURN, LV_RUECK, LV_RMZHL, LV_MESSAGE.


*- 실적 취소 펑션
  CALL FUNCTION 'BAPI_PRODORDCONF_CANCEL'
    EXPORTING
      CONFIRMATION        = PV_AFRU_RUECK "확정번호
      CONFIRMATIONCOUNTER = PV_AFRU_RMZHL "확정카운터
      POSTG_DATE          = PV_AFRU_BUDAT
      CONF_TEXT           = PV_TAGNR
    IMPORTING
      RETURN              = PS_RETURN
      CREATED_CONF_NO     = PV_RUECK
      CREATED_CONF_COUNT  = PV_RMZHL.
*- 실패
  IF PV_RUECK IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    PV_CANCEL_FLAG = 'E'.
*- 성공
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
    PV_CANCEL_FLAG = 'S'.
  ENDIF.
**- 성공
*  IF ls_return IS INITIAL.
*    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*      EXPORTING
*        wait = 'X'.
*    pv_cancel_flag = 'S'.
**- 실패
*  ELSE.
*    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*    pv_cancel_flag = 'E'.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form return_message_con_c
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> TEXT_M04
*&      --> P_
*&      --> P_
*&      --> LV_EXTID
*&---------------------------------------------------------------------*
FORM RETURN_MESSAGE_CON_C  USING   PV_FLAG
                                 PV_MESSAGE
                                 PV_RUECK
                                 PV_RMZHL
                                 PV_EXTID.

  CLEAR : GT_GR_RESULT[], GT_GR_RESULT.
  GT_GR_RESULT = VALUE #(  BASE GT_GR_RESULT
                        (   AUFNR  = GS_CON-AUFNR
                            ZSERNO = GS_CON-ZSERNO
                            RUECK  = PV_RUECK    "BAPI에서 리턴된 확정 번호
                            RMZHL  = PV_RMZHL    "BAPI에서 리턴된 확정 카운터
                            RU_EXTID  = PV_EXTID
                            ZERP_STAT  = PV_FLAG
                            ZERP_MESSAGE  = PV_MESSAGE ) ).

  GT_GR_RESULT_C = VALUE #(  BASE GT_GR_RESULT_C
                        (   AUFNR  = GS_CON-AUFNR
                            ZSERNO = GS_CON-ZSERNO
                            RUECK  = PV_RUECK    "BAPI에서 리턴된 확정 번호
                            RMZHL  = PV_RMZHL    "BAPI에서 리턴된 확정 카운터
                            RU_EXTID  = PV_EXTID
                            ZERP_STAT  = PV_FLAG
                            ZERP_MESSAGE  = PV_MESSAGE ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form return_message_con_cbd
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> LS_DETAIL_MESSAGE
*&      --> LS_DETAIL_CONF_NO
*&      --> LS_DETAIL_CONF_CNT
*&      --> PV_EXTID
*&---------------------------------------------------------------------*
FORM RETURN_MESSAGE_CON_CBD  USING   PV_FLAG
                                 PV_MESSAGE
                                 PV_RUECK
                                 PV_RMZHL
                                 PV_EXTID.

*  CLEAR : gt_gr_result[], gt_gr_result.
  GT_GR_RESULT = VALUE #(  BASE GT_GR_RESULT
                        (   AUFNR  = GS_CON-AUFNR
                            ZSERNO = GS_CON-ZSERNO
                            RUECK  = PV_RUECK    "BAPI에서 리턴된 확정 번호
                            RMZHL  = PV_RMZHL    "BAPI에서 리턴된 확정 카운터
                            RU_EXTID  = PV_EXTID
                            ZERP_STAT  = PV_FLAG
                            ZERP_MESSAGE  = PV_MESSAGE ) ).

  GT_GR_RESULT_C = VALUE #(  BASE GT_GR_RESULT_C
                        (   AUFNR  = GS_CON-AUFNR
                            ZSERNO = GS_CON-ZSERNO
                            RUECK  = PV_RUECK    "BAPI에서 리턴된 확정 번호
                            RMZHL  = PV_RMZHL    "BAPI에서 리턴된 확정 카운터
                            RU_EXTID  = PV_EXTID
                            ZERP_STAT  = PV_FLAG
                            ZERP_MESSAGE  = PV_MESSAGE ) ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form return_message_con_bd
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> TEXT_M04
*&      --> P_
*&      --> P_
*&      --> LV_EXTID
*&---------------------------------------------------------------------*
FORM RETURN_MESSAGE_CON_BD  USING   PV_FLAG
                                 PV_MESSAGE
                                 PV_RUECK
                                 PV_RMZHL
                                 PV_EXTID.

*  CLEAR : gt_gr_result[], gt_gr_result.
  GT_GR_RESULT = VALUE #(  BASE GT_GR_RESULT
                        (   AUFNR  = GS_CON-AUFNR
                            ZSERNO = GS_CON-ZSERNO
                            RUECK  = PV_RUECK    "BAPI에서 리턴된 확정 번호
                            RMZHL  = PV_RMZHL    "BAPI에서 리턴된 확정 카운터
                            RU_EXTID  = PV_EXTID
                            ZERP_STAT  = PV_FLAG
                            ZERP_MESSAGE  = PV_MESSAGE ) ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form return_message_end
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> TEXT_M04
*&      --> P_
*&      --> P_
*&      --> LV_EXTID
*&---------------------------------------------------------------------*
FORM RETURN_MESSAGE_END  USING   PV_FLAG
                                 PV_MESSAGE
                                 PV_RUECK
                                 PV_RMZHL
                                 PV_EXTID
                                 PV_AUFNR
                                 PV_ZSERNO.

*  CLEAR : gt_gr_result[], gt_gr_result.
  GT_GR_RESULT = VALUE #(  BASE GT_GR_RESULT
                        (   AUFNR  = PV_AUFNR
                            ZSERNO = PV_ZSERNO
                            RUECK  = PV_RUECK    "BAPI에서 리턴된 확정 번호
                            RMZHL  = PV_RMZHL    "BAPI에서 리턴된 확정 카운터
                            RU_EXTID  = PV_EXTID
                            ZERP_STAT  = PV_FLAG
                            ZERP_MESSAGE  = PV_MESSAGE ) ).

  GT_GR_RESULT_C = VALUE #(  BASE GT_GR_RESULT_C
                        (   AUFNR  = PV_AUFNR
                            ZSERNO = PV_ZSERNO
                            RUECK  = PV_RUECK    "BAPI에서 리턴된 확정 번호
                            RMZHL  = PV_RMZHL    "BAPI에서 리턴된 확정 카운터
                            RU_EXTID  = PV_EXTID
                            ZERP_STAT  = PV_FLAG
                            ZERP_MESSAGE  = PV_MESSAGE ) ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_prodordconf_create_lock2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_CON_AUFNR
*&      --> PV_ERROR
*&---------------------------------------------------------------------*
FORM CHECK_PRODORDCONF_CREATE_LOCK2  USING    PV_AUFNR
                                                                           PV_ERROR
                                                                           PV_MESSAGE
                                                                           PV_GI_MATNR

                                                                           PV_MODE.


  DATA : LT_ENQ    TYPE SEQG3  OCCURS 0 WITH HEADER LINE.
  DATA : LV_GARG     TYPE  SEQG3-GARG,
         LV_GARG_MAT TYPE  SEQG3-GARG,
         LV_NUMBER   TYPE  SY-TABIX,
         LV_SUBRC    TYPE  SY-SUBRC.

  DATA : LV_MESSAGE(220).


***  25.09.26 Start. 자재 Lock 점검 추가
  SELECT SINGLE MATNR                                       "250926 추가
     FROM AFPO                                              "250926 추가
    WHERE AUFNR = @PV_AUFNR                                 "250926 추가
    INTO @DATA(LV_MATNR).                                   "250926 추가

  CONCATENATE SY-MANDT PV_AUFNR
         INTO LV_GARG.

  IF PV_MODE = 'GI'.
    LV_MATNR = PV_GI_MATNR.
  ENDIF.

*SRM2601-11135 MARC Lock 체크를 위해서 플랜트 추가
  SELECT SINGLE WERKS
      FROM AUFK
     WHERE AUFNR = @PV_AUFNR
        INTO @DATA(LV_WERKS).

  CONCATENATE SY-MANDT  LV_MATNR                            "250926 추가
         INTO LV_GARG_MAT.

  LV_GARG_MAT+43(4) = LV_WERKS.
*SRM2601-11135

  DO 50 TIMES.

    CALL FUNCTION 'ENQUEUE_READ'
      EXPORTING
        GCLIENT               = SY-MANDT
        GNAME                 = 'AUFK'  "AUFK
        GARG                  = LV_GARG "CLIENT 번호 + 현재 오더번호
      IMPORTING
        NUMBER                = LV_NUMBER
        SUBRC                 = LV_SUBRC
      TABLES
        ENQ                   = LT_ENQ  "값이 있으면 현재 오더 누가 잡고 있다 .WHILE ENQ 있으면 0.1
      EXCEPTIONS
        COMMUNICATION_FAILURE = 1
        SYSTEM_FAILURE        = 2
        OTHERS                = 3.

    IF LT_ENQ[] IS INITIAL.
      CLEAR: LT_ENQ[],LT_ENQ.
      PV_ERROR = 'S'.
*      EXIT.   "25.09.26 - 자재 Lock 추가, 하단 로직 타도록
    ELSE.
      READ TABLE LT_ENQ INTO DATA(LS_ENQ) INDEX 1.
      PV_ERROR = 'X'.
      PV_MESSAGE = |오더번호 { PV_AUFNR } { LS_ENQ-GUNAME }이 처리중입니다|.
      WAIT UP TO '0.1' SECONDS.
    ENDIF.

*** 25.09.26 오더 Lock 이상 없을시 >> 자재 Lock 점검
    IF PV_ERROR = 'S'.

      CALL FUNCTION 'ENQUEUE_READ'
        EXPORTING
          GCLIENT               = SY-MANDT
          GNAME                 = 'MARC'  "MARA
          GARG                  = LV_GARG_MAT
        IMPORTING
          NUMBER                = LV_NUMBER
          SUBRC                 = LV_SUBRC
        TABLES
          ENQ                   = LT_ENQ  "값이 있으면 현재 자재 누가 잡고 있다 .WHILE ENQ 있으면 0.1
        EXCEPTIONS
          COMMUNICATION_FAILURE = 1
          SYSTEM_FAILURE        = 2
          OTHERS                = 3.

      IF LT_ENQ[] IS INITIAL.
        CLEAR: LT_ENQ[],LT_ENQ.
        PV_ERROR = 'S'.
        EXIT.
      ELSE.
        READ TABLE LT_ENQ INTO LS_ENQ INDEX 1.
        PV_ERROR = 'X'.
        PV_MESSAGE = |자재번호 { LV_MATNR } { LS_ENQ-GUNAME }이 처리중입니다|.
        WAIT UP TO '0.1' SECONDS.
      ENDIF.
    ENDIF.
***  25.09.26 End. 자재 Lock 점검 추가
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_dup_conf
*&---------------------------------------------------------------------*
*& 2025.11.28.zlsgpp5. 중복 여부 체크.
*&---------------------------------------------------------------------*
FORM CHECK_DUP_CONF USING IV_EXTID
                          IV_TIMESTAMP
                          IV_SYSTEM_ID
                          IV_MODE
                          OV_DUP_FLAG.

  DATA: LV_MODE TYPE CHAR2.
*  DATA: lv_message(220) VALUE '이미 처리된 건입니다!!'.

  DATA : LV_RUECK LIKE  AFRU-RUECK.

  CLEAR: OV_DUP_FLAG.

*----------------------------------------*
* 1) 테이블 조회
*----------------------------------------*
  "[GT] 생산오더 실적처리 수신
  SELECT * INTO TABLE @DATA(LT_3080)
    FROM ZGTPPT3080
   WHERE AUFNR      EQ @GS_CON-AUFNR
     AND TAGNR      EQ @GS_CON-TAGNR
     AND ZERP_STAT  EQ 'S'
     AND I_MODE     EQ @IV_MODE.

  "데이터가 없으면 중복체크종료.
  IF LT_3080[] IS INITIAL.
    EXIT.
  ENDIF.

**---------------------------------------
** 2) afru에서 취소건은 제거
**---------------------------------------

* AFRU에서 확정카운터가 취소된 건은 제외
  SELECT RMZHL
       INTO TABLE @DATA(LT_AFRU)
       FROM AFRU
     WHERE AUFNR EQ @GS_CON-AUFNR
         AND  STOKZ EQ 'X'.

  SORT LT_AFRU BY RMZHL.

  LOOP AT LT_3080 ASSIGNING FIELD-SYMBOL(<LT_3080>).

    READ TABLE LT_AFRU ASSIGNING FIELD-SYMBOL(<LT_TMP>)
                                  WITH KEY RMZHL = <LT_3080>-RMZHL
                                  BINARY SEARCH.

    IF SY-SUBRC EQ 0 AND IV_MODE EQ 'P'.
      CLEAR: <LT_3080>-AUFNR.
    ELSEIF SY-SUBRC NE 0 AND IV_MODE EQ 'C'.
      CLEAR: <LT_3080>-AUFNR.
    ENDIF.

  ENDLOOP.

  DELETE LT_3080 WHERE AUFNR IS INITIAL.

**----------------------------------------*
** 3) 중복 여부 체크
**----------------------------------------*
  "최근 I/F 일자 순으로 정렬.
  DATA(LV_CNT) = LINES( LT_3080 ).
  IF LV_CNT > 1.
    SORT LT_3080 BY IFDAT DESCENDING
                             IFTIM DESCENDING.
  ENDIF.

  "첫번째 라인 읽기.
  READ TABLE LT_3080 INTO DATA(LS_3080) INDEX 1.

  "중복일 경우 리턴메시지와 로그itab에 담기
  IF IV_MODE EQ LS_3080-I_MODE.

    IF IV_MODE EQ 'P'.
      PERFORM RETURN_MESSAGE_CON_CBD  USING 'S'
                                        LS_3080-ZERP_MESSAGE
                                        LS_3080-RUECK
                                        LS_3080-RMZHL
                                        LS_3080-RU_EXTID.
      PERFORM SAVE_LOG_CON  USING 'S'
                                  LS_3080-ZERP_MESSAGE
                                  LS_3080-RUECK
                                  LS_3080-RMZHL
                                  LS_3080-RU_EXTID
                                  IV_TIMESTAMP
                                  IV_SYSTEM_ID
                                  IV_MODE.

    ELSE.
      PERFORM RETURN_MESSAGE_CON  USING 'S'
                                        LS_3080-ZERP_MESSAGE
                                        LS_3080-RUECK
                                        LS_3080-RMZHL
                                        LS_3080-RU_EXTID.

      PERFORM SAVE_LOG_CON_CANCEL  USING 'S'
                                  LS_3080-ZERP_MESSAGE
                                  LS_3080-ZC_RUECK
                                  LS_3080-ZC_RMZHL
                                  LS_3080-ZC_RU_EXTID
                                  IV_TIMESTAMP
                                  IV_SYSTEM_ID
                                  IV_MODE.
    ENDIF.

    "중복체크 flag 리턴.
    OV_DUP_FLAG = 'X'.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_dup_gr
*&---------------------------------------------------------------------*
*& 2025.11.28.zlsgpp5. 중복 여부 체크.
*&---------------------------------------------------------------------*
FORM CHECK_DUP_GR  USING  IV_SYSTEM_ID
                          IV_MODE
                          OV_DUP_FLAG.


  DATA: LV_MODE TYPE CHAR2.

  CLEAR: OV_DUP_FLAG.

*----------------------------------------*
* 1) 테이블 조회
*----------------------------------------*
  "[GT] 생산오더 입고 수신 이력
  SELECT * INTO TABLE @DATA(LT_3110)
    FROM ZGTPPT3110
   WHERE AUFNR      EQ @GS_TAB-AUFNR
     AND ATNAM01    EQ @GS_TAB-ATNAM01
     AND ZERP_STAT  EQ 'S'
     AND I_MODE     EQ @IV_MODE.

  "데이터가 없으면 중복체크종료.
  IF LT_3110[] IS INITIAL.
    EXIT.
  ENDIF.
**----------------------------------------
** 2)matdoc에서 입고 자재문서 취소건만 조회
**    입고 취소에 대한 재취소는 없으므로 입고취소는 로그를 사용
**----------------------------------------
  SELECT SMBLN AS MBLNR
      INTO TABLE @DATA(LT_MATDOC)
      FROM MATDOC
    WHERE AUFNR EQ @GS_TAB-AUFNR
         AND SMBLN NE @SPACE
         AND BWART  EQ '102'.

  SORT LT_MATDOC BY MBLNR.

  LOOP AT LT_3110 ASSIGNING FIELD-SYMBOL(<LT_3110>).

    READ TABLE LT_MATDOC ASSIGNING FIELD-SYMBOL(<LT_TMP>)
                                  WITH KEY MBLNR  = <LT_3110>-MBLNR
                                  BINARY SEARCH.

    IF SY-SUBRC EQ 0 AND IV_MODE EQ 'P'.
      CLEAR: <LT_3110>-AUFNR.
    ENDIF.

  ENDLOOP.

  DELETE LT_3110 WHERE AUFNR IS INITIAL.

*----------------------------------------*
* 3) 중복 여부 체크
*----------------------------------------*
  "최근 I/F 일자 순으로 정렬.
  DATA(LV_CNT) = LINES( LT_3110 ).
  IF LV_CNT > 1.
    SORT LT_3110 BY IFDAT DESCENDING
                            IFTIM DESCENDING.
  ENDIF.

  "첫번째 라인 읽기.
  READ TABLE LT_3110 INTO DATA(LS_3110) INDEX 1.

  "중복일 경우 리턴메시지와 로그itab에 담기
  IF IV_MODE EQ LS_3110-I_MODE.

    PERFORM RETURN_MESSAGE_TAB USING  'S'
                                      LS_3110-ZERP_MESSAGE
                                      LS_3110-MJAHR
                                      LS_3110-MBLNR.

    GS_TAB-ZC_MBLNR = LS_3110-ZC_MBLNR.
    GS_TAB-ZC_MJAHR = LS_3110-ZC_MJAHR.

    PERFORM SAVE_LOG_ZGTPPT3110 USING 'S'
                                      LS_3110-ZERP_MESSAGE
                                      LS_3110-MJAHR
                                      LS_3110-MBLNR
                                      IV_SYSTEM_ID.

    "중복체크 flag 리턴.
    OV_DUP_FLAG = 'X'.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_dup_conf_1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_SYSTEM_ID
*&      --> I_MODE
*&      --> GS_CON_ZSERNO
*&      --> GS_CON_WERKS
*&      --> GS_CON_AUFNR
*&      --> GS_CON_BUDAT
*&      --> GS_CON_MENGE
*&      --> GS_CON_TAGNR
*&      --> LV_DUP_FLAG
*&---------------------------------------------------------------------*
FORM CHECK_DUP_CONF_1  USING    IV_SYSTEM_ID
                                                     IV_MODE
                                                     IV_ZSERNO
                                                     IV_WERKS
                                                     IV_AUFNR
                                                     IV_BUDAT
                                                     IV_MENGE
                                                     IV_TAGNR
                                                     IV_TIMESTAMP
                                                     OV_FLAG.

  CHECK IV_SYSTEM_ID EQ 'KSCM'. " OR     "소재 MOM인 경우만 실행
*        IV_SYSTEM_ID EQ 'KFCM' .      "한미소 MOM 260902

  CLEAR OV_FLAG.
*----------------------------------------*
* 1) 테이블 조회
*----------------------------------------*
  "[GT] 생산오더 실적처리 수신
  SELECT * INTO TABLE @DATA(LT_3080)
    FROM ZGTPPT3080
   WHERE WERKS  EQ  @IV_WERKS
     AND ZSERNO   EQ @IV_ZSERNO
     AND  AUFNR     EQ @IV_AUFNR
     AND TAGNR      EQ @IV_TAGNR
     AND BUDAT     EQ @IV_BUDAT
     AND MENGE   EQ @IV_MENGE
     AND ZERP_STAT EQ 'S'
     AND I_MODE    EQ @IV_MODE.

  "데이터가 없으면 중복체크종료.
  IF LT_3080[] IS INITIAL.
    EXIT.
  ENDIF.

**---------------------------------------
** 2) afru에서 취소건은 제거
**---------------------------------------
* AFRU에서 확정카운터가 취소된 건은 제외
  SELECT RMZHL
       INTO TABLE @DATA(LT_AFRU)
       FROM AFRU
     WHERE AUFNR EQ @IV_AUFNR
         AND  STOKZ EQ 'X'.

  SORT LT_AFRU BY RMZHL.

  LOOP AT LT_3080 ASSIGNING FIELD-SYMBOL(<LT_3080>).

    READ TABLE LT_AFRU ASSIGNING FIELD-SYMBOL(<LT_TMP>)
                                  WITH KEY RMZHL = <LT_3080>-RMZHL
                                  BINARY SEARCH.

    IF SY-SUBRC EQ 0 AND IV_MODE EQ 'P'.
      CLEAR: <LT_3080>-AUFNR.
    ELSEIF SY-SUBRC NE 0 AND IV_MODE EQ 'C'.
      CLEAR: <LT_3080>-AUFNR.
    ENDIF.

  ENDLOOP.

  DELETE LT_3080 WHERE AUFNR IS INITIAL.

**----------------------------------------*
** 3) 중복 여부 체크
**----------------------------------------*
  "최근 I/F 일자 순으로 정렬.
  DATA(LV_CNT) = LINES( LT_3080 ).
  IF LV_CNT > 1.
    SORT LT_3080 BY IFDAT DESCENDING
                             IFTIM DESCENDING.
  ENDIF.

  "첫번째 라인 읽기.
  READ TABLE LT_3080 INTO DATA(LS_3080) INDEX 1.

  "중복일 경우 리턴메시지와 로그itab에 담기
  IF IV_MODE EQ LS_3080-I_MODE.

    IF IV_MODE EQ 'P'.
      PERFORM RETURN_MESSAGE_CON  USING 'S'
                                        LS_3080-ZERP_MESSAGE
                                        LS_3080-RUECK
                                        LS_3080-RMZHL
                                        LS_3080-RU_EXTID.

      PERFORM SAVE_LOG_CON  USING 'S'
                                  LS_3080-ZERP_MESSAGE
                                  LS_3080-RUECK
                                  LS_3080-RMZHL
                                  LS_3080-RU_EXTID
                                  IV_TIMESTAMP
                                  IV_SYSTEM_ID
                                  IV_MODE.

    ELSE.
      PERFORM RETURN_MESSAGE_CON  USING 'S'
                                        LS_3080-ZERP_MESSAGE
                                        LS_3080-RUECK
                                        LS_3080-RMZHL
                                        LS_3080-RU_EXTID.

      PERFORM SAVE_LOG_CON_CANCEL  USING 'S'
                                  LS_3080-ZERP_MESSAGE
                                  LS_3080-ZC_RUECK
                                  LS_3080-ZC_RMZHL
                                  LS_3080-ZC_RU_EXTID
                                  IV_TIMESTAMP
                                  IV_SYSTEM_ID
                                  IV_MODE.
    ENDIF.

    "중복체크 flag 리턴.
    OV_FLAG = 'X'.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_bapi_case_a_gaon
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_GOODSMOVEMENTS
*&      --> LT_RETURN
*&      --> LV_MESSAGE
*&      --> LV_ERROR
*&      --> LV_EXTID
*&      --> P_
*&      --> LV_TIMESTAMP
*&      --> I_SYSTEM_ID
*&      --> I_MODE
*&      --> LV_AUART
*&      <-- LV_BAPI_FLAG
*&---------------------------------------------------------------------*
FORM CALL_BAPI_CASE_A_GAON  TABLES   PT_GOODSMOVEMENTS
                       STRUCTURE BAPI2017_GM_ITEM_CREATE
                                PT_RETURN STRUCTURE BAPIRET1
                       USING    PV_MESSAGE
                                PV_ERROR
                                PV_EXTID
                                PV_CASE
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE
                                PV_AUART
                       CHANGING PV_BAPI_FLAG.

  DATA : LV_FIN_CONF         LIKE AFRU-AUERU,
         LV_ISM06            LIKE AFRU-ISM06,
         LV_CLEAR_RES(1),
         LV_EXTID(32),
         LV_LOCK_CHK_FLAG(1),
         LV_CHK_FLAG(1),
         LV_BAPI_FLAG(1).

*- 실적처리 체크항목
  CLEAR PT_GOODSMOVEMENTS.

  PERFORM CHECK_CON TABLES PT_GOODSMOVEMENTS
                    USING PV_ERROR
                          PV_EXTID
                          PV_CASE.

  IF PV_ERROR = 'X'.
    PV_MESSAGE = VALUE #( GT_GR_RESULT[ ZSERNO = GS_CON-ZSERNO ]-ZERP_MESSAGE OPTIONAL ).
    PERFORM SAVE_LOG_CON  USING 'E'
                                PV_MESSAGE
                                ''
                                ''
                                PV_EXTID
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE.
    PV_BAPI_FLAG = 'X'.
    CLEAR GS_CON.
    EXIT.
  ENDIF.

  CHECK PV_ERROR <> 'X'.

*- 최종확정 지시자 값 셋팅
***  PERFORM set_fin_conf USING lv_fin_conf
***                             lv_clear_res
***                             'A'.
*- 대체순서에 따른 노무 Activity와 기계 Activity의 비율로 노무 Activity 처리 값 계산

  PERFORM SET_ISMVAL USING LV_ISM06 'A' PV_AUART PV_SYSTEM_ID.

  IF GS_CON-LMNGA IS NOT INITIAL
     AND ( GS_CON-ISM01 IS NOT INITIAL
     OR GS_CON-ISM02 IS NOT INITIAL ).

    IF PV_AUART NE 'RW01' OR GV_GAON EQ ABAP_TRUE.
*  - 실적처리 A  작업길이
      PERFORM BAPI_PRODORDCONF_CREATE_TT_A2 TABLES PT_GOODSMOVEMENTS
                                                  PT_RETURN
                                               USING LV_FIN_CONF
                                                     LV_CLEAR_RES
                                                     LV_ISM06
                                                     PV_EXTID
                                                     PV_BAPI_FLAG
                                                     PV_TIMESTAMP
                                                     PV_SYSTEM_ID
                                                     PV_MODE
                                                     0.
    ENDIF.

    IF PV_BAPI_FLAG = 'X'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ELSE.
      PERFORM CHECK_PRODORDCONF_CREATE_LOCK USING  GS_CON-AUFNR
                                                   LV_LOCK_CHK_FLAG
                                                   PV_TIMESTAMP
                                                   PV_SYSTEM_ID
                                                   PV_MODE
                                                   .
      IF LV_LOCK_CHK_FLAG = 'S'.
*  - 실적처리 A  수량  tagnr 값 셋팅
        PERFORM BAPI_PRODORDCONF_CREATE_TT_A_G TABLES PT_GOODSMOVEMENTS
                                                    PT_RETURN
                                                 USING LV_FIN_CONF
                                                       LV_CLEAR_RES
                                                       LV_ISM06
                                                       PV_EXTID
                                                       PV_BAPI_FLAG
                                                       PV_TIMESTAMP
                                                       PV_SYSTEM_ID
                                                       PV_MODE
                                                       0.
      ELSE.
        CONCATENATE '오더번호('
                    GS_CON-AUFNR
                    ')이 처리중입니다'
               INTO PV_MESSAGE .
        PERFORM SAVE_LOG_CON  USING 'E'
                                    PV_MESSAGE
                                    ''
                                    ''
                                    PV_EXTID
                                    PV_TIMESTAMP
                                    PV_SYSTEM_ID
                                    PV_MODE.
        PV_BAPI_FLAG = 'X'.

        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ENDIF.
    ENDIF.                                                  .

  ELSEIF GS_CON-LMNGA IS NOT INITIAL
     AND ( GS_CON-ISM01 IS INITIAL
     OR GS_CON-ISM02 IS INITIAL ) .


*- 실적처리 A  수량  tagnr 값 셋팅
    PERFORM BAPI_PRODORDCONF_CREATE_TT_A TABLES PT_GOODSMOVEMENTS
                                                PT_RETURN
                                             USING LV_FIN_CONF
                                                   LV_CLEAR_RES
                                                   LV_ISM06
                                                   PV_EXTID
                                                   PV_BAPI_FLAG
                                                   PV_TIMESTAMP
                                                   PV_SYSTEM_ID
                                                   PV_MODE
                                                   0.


  ELSEIF GS_CON-LMNGA IS INITIAL
     AND ( GS_CON-ISM01 IS NOT INITIAL
     OR GS_CON-ISM02 IS NOT INITIAL ).
    IF PV_AUART NE 'RW01' OR GV_GAON EQ ABAP_TRUE.
      PERFORM BAPI_PRODORDCONF_CREATE_TT_A2 TABLES PT_GOODSMOVEMENTS
                                                  PT_RETURN
                                               USING LV_FIN_CONF
                                                     LV_CLEAR_RES
                                                     LV_ISM06
                                                     PV_EXTID
                                                     PV_BAPI_FLAG
                                                     PV_TIMESTAMP
                                                     PV_SYSTEM_ID
                                                     PV_MODE
                                                     0.
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_PRODORDCONF_CREATE_TT_A_G
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_GOODSMOVEMENTS
*&      --> PT_RETURN
*&      --> LV_FIN_CONF
*&      --> LV_CLEAR_RES
*&      --> LV_ISM06
*&      --> PV_EXTID
*&      --> PV_BAPI_FLAG
*&      --> PV_TIMESTAMP
*&      --> PV_SYSTEM_ID
*&      --> PV_MODE
*&      --> P_0
*&---------------------------------------------------------------------*
FORM BAPI_PRODORDCONF_CREATE_TT_A_G  TABLES  PT_GOODSMOVEMENTS
                                 STRUCTURE BAPI2017_GM_ITEM_CREATE
                                  PT_RETURN STRUCTURE BAPIRET1
                                  USING PV_FIN_CONF
                                        PV_CLEAR_RES
                                        PV_ISM06
                                        PV_EXTID
                                        PV_BAPI_FLAG
                                        PV_TIMESTAMP
                                        PV_SYSTEM_ID
                                        PV_MODE
                                        PV_COUNT TYPE N
                                        .


  DATA: LT_TT      TYPE TABLE OF BAPI_PP_TIMETICKET,
        LT_GOODS   TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_DETAIL  TYPE TABLE OF BAPI_CORU_RETURN,
        LS_DETAIL  TYPE BAPI_CORU_RETURN,
        LS_RETURN  TYPE BAPIRET1,
        LV_MESSAGE TYPE BAPI_CORU_RETURN-MESSAGE.
  DATA : LT_RETURN         LIKE TABLE OF BAPIRET1,
         LV_RUECK          TYPE BAPI_PP_CONF_KEY-CONF_NO,
         LV_RMZHL          TYPE BAPI_PP_CONF_KEY-CONF_CNT,
         LV_EXTID(32),
         LV_CANCEL_FLAG(1).

  DATA: LV_BUDAT TYPE BUCHDATUM. "GO02(+)

*- GO02 Start GAON 전기일 설정
  CLEAR: LV_BUDAT.
  IF GV_GAON EQ ABAP_TRUE.
    LV_BUDAT = GV_BUDAT.
  ELSE.
    LV_BUDAT = GS_CON-BUDAT.
  ENDIF.
*- GO02 End GAON 전기일 설정

*  DATA: lv_fin_time TYPE ru_iebz.  "20260427 ZGODEV03
*
*  "가온전선 추가 20260427
*  CLEAR: lv_fin_time.
*  IF gv_gaon EQ abap_true.
*    lv_fin_time = sy-uzeit.
*  ELSE.
*    lv_fin_time = gs_con-iedz.
*  ENDIF.
*  "가온전선 추가 20260427

  CLEAR : LT_TT, LT_GOODS, LT_DETAIL, LS_RETURN, LV_MESSAGE, LS_DETAIL.


  LT_TT = VALUE #( ( ORDERID         = GS_CON-AUFNR
                     OPERATION       = GS_CON-VORNR
                     FIN_CONF        = PV_FIN_CONF
                     CLEAR_RES       = PV_CLEAR_RES
                     POSTG_DATE      = LV_BUDAT "GS_CON-BUDAT   "GO02(+)
                     DEV_REASON      = ''
                     PLANT           = GS_CON-WERKS
                     WORK_CNTR       = GS_CON-ARBPL
                     YIELD           = GS_CON-LMNGA
                     SCRAP           = ''
                     REWORK          = ''
                     CONF_TEXT       = GS_CON-TAGNR
                     CONF_ACTIVITY1  = '' " 공란
                     CONF_ACTI_UNIT1 = GS_CON-ILE01
                     CONF_ACTIVITY2  = '' " 공란
                     CONF_ACTI_UNIT2 = GS_CON-ILE02
                     CONF_ACTIVITY3  = '' " 공란
                     CONF_ACTI_UNIT3 = GS_CON-ILE03
                     CONF_ACTIVITY4  = '' " 공란
                     CONF_ACTI_UNIT4 = GS_CON-ILE04
                     CONF_ACTIVITY5  = '' " 공란
                     CONF_ACTI_UNIT5 = GS_CON-ILE05
                     CONF_ACTIVITY6  = '' " 공란
                     CONF_ACTI_UNIT6 = GS_CON-ILE06
                     EXEC_START_DATE = GS_CON-ISDD
                     EXEC_START_TIME = GS_CON-ISDZ
                     PROC_FIN_DATE   = GS_CON-IEDD
                     PROC_FIN_TIME   = GS_CON-IEDZ
*                     proc_fin_time   = lv_fin_time   "gs_con-iedz 20260427 ZGODEV03
                     EX_IDENT        = PV_EXTID
                     PERS_NO         = GS_CON-PERNR   ) ).

*- 생산 실적 처리
  CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
    IMPORTING
      RETURN         = LS_RETURN
    TABLES
      TIMETICKETS    = LT_TT
      GOODSMOVEMENTS = PT_GOODSMOVEMENTS
      DETAIL_RETURN  = LT_DETAIL.

*  WAIT UP TO 2 SECONDS.
*- 성공
  IF LS_RETURN IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    LS_DETAIL = VALUE #( LT_DETAIL[ 1 ] OPTIONAL ).

    PERFORM RETURN_MESSAGE_CON_C  USING 'S'
                                      LS_DETAIL-MESSAGE
                                      LS_DETAIL-CONF_NO
                                      LS_DETAIL-CONF_CNT
                                      PV_EXTID.

    PERFORM SAVE_LOG_CON  USING 'S'
                                LS_DETAIL-MESSAGE
                                LS_DETAIL-CONF_NO
                                LS_DETAIL-CONF_CNT
                                PV_EXTID
                                PV_TIMESTAMP
                                PV_SYSTEM_ID
                                PV_MODE
                                .

*- 생산오더 전송 프로그램 호출(zgtppi2010)
***    PERFORM call_transaction_zgtppi2010.

    PV_BAPI_FLAG = 'A'.
*- 실패
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

* 해당 라인은 마지막 호출순번에만 적용
    IF PV_COUNT = 21.
*- 확정 외부 ID KEY 생성
      CLEAR : LV_EXTID.
      LV_EXTID = GS_CON-RU_EXTID.
      LOOP AT   GT_GR_RESULT_C INTO  GS_GR_RESULT_C .

        PERFORM BAPI_PRODORDCONF_CANCEL TABLES LT_RETURN
                                        USING GS_GR_RESULT_C-RUECK
                                              GS_GR_RESULT_C-RMZHL
                                              LV_BUDAT "GS_CON-BUDAT   "GO02(+)
                                              LV_RUECK
                                              LV_RMZHL
                                              LV_CANCEL_FLAG.
        IF LV_CANCEL_FLAG = 'E'.

*          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*          READ TABLE lt_return INTO DATA(ls_return)  WITH KEY type = 'E'.
*          IF sy-subrc = 0.
          IF LV_RUECK IS INITIAL.
            PERFORM RETURN_MESSAGE_CON  USING 'E'
*                                              ls_return-message
                                             TEXT-M04
                                              '  '
                                              '  '
                                              LV_EXTID.
            PERFORM SAVE_LOG_CON_CANCEL  USING 'E'
*                                        ls_return-message
                                        TEXT-M04
                                        '  '
                                        '  '
                                        LV_EXTID
                                        PV_TIMESTAMP
                                        PV_SYSTEM_ID
                                        PV_MODE.
          ENDIF.
          EXIT.
        ENDIF.

      ENDLOOP.

    ENDIF.

    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'A'
                                       OR  TYPE = 'E'
                                       OR  TYPE = 'X'.

      PERFORM RETURN_MESSAGE_CON  USING 'E'
                                      LS_DETAIL-MESSAGE
                                      '  '
                                      '  '
                                      PV_EXTID.

      PERFORM SAVE_LOG_CON  USING 'E'
                                  LS_DETAIL-MESSAGE
                                  '  '
                                  '  '
                                  PV_EXTID
                                  PV_TIMESTAMP
                                  PV_SYSTEM_ID
                                  PV_MODE.

      EXIT.
    ENDLOOP.

    PV_BAPI_FLAG = 'X'.


    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'E'
                                       AND  ID = 'CO'
                           AND ( NUMBER = '469' OR NUMBER = '341' ) .
      WAIT UP TO '0.1' SECONDS.
      IF PV_COUNT < 21.
        PV_COUNT = PV_COUNT + 1.
        PERFORM BAPI_PRODORDCONF_CREATE_TT_A_G TABLES PT_GOODSMOVEMENTS
                                                    PT_RETURN
                                                 USING PV_FIN_CONF
                                                       PV_CLEAR_RES
                                                       PV_ISM06
                                                       PV_EXTID
                                                       PV_BAPI_FLAG
                                                       PV_TIMESTAMP
                                                       PV_SYSTEM_ID
                                                       PV_MODE
                                                       PV_COUNT.
      ENDIF.
    ENDLOOP.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BUDAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_BUDAT
*&---------------------------------------------------------------------*
FORM SET_BUDAT  USING  PV_AUFNR TYPE AUFNR
                       PV_IF_BUDAT TYPE BUDAT.

  CLEAR: GV_BUDAT.

  "생산오더의 마지막(최근) 입고의 전기일 추출
  SELECT SINGLE MAX( BUDAT )
    FROM MATDOC
   WHERE AUFNR EQ @PV_AUFNR
     AND BWART EQ '101'
     AND CANCELLED NE 'X'
    INTO @DATA(LV_BUDAT_MAX).

  IF LV_BUDAT_MAX IS NOT INITIAL.
    "I/F 전기일의 월과 생산오더의 마지막(최근) 전기일의 월이 다른 경우
    IF PV_IF_BUDAT+0(6) NE LV_BUDAT_MAX+0(6).
      "생산오더의 마지막 전기월의 말일자로 전기일 설정
      CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
        EXPORTING
          DAY_IN            = LV_BUDAT_MAX
        IMPORTING
          LAST_DAY_OF_MONTH = GV_BUDAT
        EXCEPTIONS
          DAY_IN_NO_DATE    = 1
          OTHERS            = 2.

    ELSE.
      GV_BUDAT = PV_IF_BUDAT.
    ENDIF.

  ELSE.   "마지막(최근) 전기일이 없으면
    GV_BUDAT = PV_IF_BUDAT.
  ENDIF.

ENDFORM.
