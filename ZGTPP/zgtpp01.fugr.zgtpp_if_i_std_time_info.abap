FUNCTION ZGTPP_IF_I_STD_TIME_INFO.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_ITEM STRUCTURE  ZGTPPSIF0026
*"      OT_RESULT STRUCTURE  ZGTPPSIF0027
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_STD_TIME_INFO
*& 프로그램 명 : [GT] 품목별 표준 작업 시간 수신 처리
*& 개요   :
*& 생성일 : 2024.12.09
*& 생성자 : ZGSIDEV08
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : 부스닥트 MES
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*
  DATA: LT_TIME TYPE TABLE OF ZGTPPSIF0026.
  DATA: LV_ERROR.
  DATA: LV_MESSAGE(220).
  DATA: BEGIN OF LS_SUBMIT,
          WERKS TYPE WERKS_D,
          MATNR TYPE MATNR,
          STDDT TYPE ZSTDDT,
        END OF LS_SUBMIT,
        LT_SUBMIT LIKE TABLE OF LS_SUBMIT.

  DATA : LV_JOBNAME  LIKE TBTCJOB-JOBNAME VALUE 'ZGTPPR1060',
         LV_JOBNAME2 LIKE TBTCJOB-JOBNAME,
         LV_JOBCOUNT LIKE TBTCJOB-JOBCOUNT,
         LV_RELEASED LIKE BTCH0000-CHAR1,
         LV_UZEIT    LIKE SY-UZEIT.

  DATA: LS_SELTAB TYPE RSPARAMS,
        LT_SELTAB TYPE TABLE OF RSPARAMS.

  CLEAR: LT_TIME, LV_ERROR, LV_MESSAGE, GS_TIME, GT_TIME,
         GT_TIME_RESULT[], OT_RESULT, OT_RESULT[].

  IF IT_ITEM[] IS INITIAL.
    OT_RESULT-ZERP_STAT = GC_E.
    OT_RESULT-ZERP_MESSAGE = TEXT-E14.
    APPEND OT_RESULT. EXIT.
  ENDIF.

  LT_TIME[] = IT_ITEM[].
  GT_TIME = CORRESPONDING #( LT_TIME ).

  LOOP AT GT_TIME INTO GS_TIME.
    CLEAR: LV_ERROR.

*- Conversion input
    PERFORM CONVERSION_INPUT_TIME USING GS_TIME.

    GS_TIME-ZSYSTEM_ID = I_SYSTEM_ID.

*- 수신 데이터 점검
    PERFORM CHECK_RECEPTION_TIME USING LV_ERROR.
    IF LV_ERROR = GC_X.
      LV_MESSAGE = VALUE #( GT_TIME_RESULT[ ZSERNO = GS_TIME-ZSERNO ]-ZERP_MESSAGE OPTIONAL ).
      PERFORM SAVE_LOG_ZGTPPT1060 USING GC_E LV_MESSAGE.
      CLEAR GS_TIME.
      CONTINUE.
    ELSE.
      PERFORM RETURN_MESSAGE_TIME USING GC_S
                                        TEXT-S04. "데이터 수신에 성공하였습니다.
      PERFORM SAVE_LOG_ZGTPPT1060 USING GC_S
                                        TEXT-S04. "데이터 수신에 성공하였습니다.
      CLEAR GS_TIME.
    ENDIF.
  ENDLOOP.

*- RFC 펑션 결과 리턴
  PERFORM CONVERSION_OUTPUT_TIME.

  PERFORM RESULT_TIME_DATA USING ZO_RESULT
                                 ZO_MESSAGE.

  OT_RESULT[] = GT_TIME_RESULT[].

*-수신된 완제품 코드 기준으로 라우팅 생성/변경
*-수신 데이터가 모두 성공인 경우만 진행
  CHECK ZO_RESULT EQ '00'.
*-수신된 데이터의 플랜트+완제품코드+기준일자 기준으로 중복 제거
  CLEAR: LT_SUBMIT.
  LOOP AT GT_TIME_RESULT INTO DATA(LS_TIME).
    MOVE-CORRESPONDING LS_TIME TO LS_SUBMIT.
    COLLECT LS_SUBMIT INTO LT_SUBMIT.
    CLEAR: LS_SUBMIT.
  ENDLOOP.

  SORT LT_SUBMIT BY WERKS MATNR STDDT.
  DELETE ADJACENT DUPLICATES FROM LT_SUBMIT
         COMPARING WERKS MATNR STDDT.

  IF LT_SUBMIT IS NOT INITIAL.
    LOOP AT LT_SUBMIT INTO LS_SUBMIT.
      CLEAR: LV_JOBNAME2.
      LV_JOBNAME2 = LV_JOBNAME && |_| && SY-DATUM && |_| && SY-UZEIT.

      CLEAR: LV_JOBCOUNT.
      DO.
        CALL FUNCTION 'JOB_OPEN'
          EXPORTING
            JOBNAME          = LV_JOBNAME2
          IMPORTING
            JOBCOUNT         = LV_JOBCOUNT
          EXCEPTIONS
            CANT_CREATE_JOB  = 1
            INVALID_JOB_DATA = 2
            JOBNAME_MISSING  = 3
            OTHERS           = 4.
        IF SY-SUBRC EQ 0.
          EXIT.
        ENDIF.
      ENDDO.

      CLEAR: LT_SELTAB[].
      LT_SELTAB = VALUE #(
      ( SELNAME = 'S_WERKS' KIND = 'S' SIGN = 'I' OPTION = 'EQ' LOW = LS_SUBMIT-WERKS )
      ( SELNAME = 'S_MATNR' KIND = 'S' SIGN = 'I' OPTION = 'EQ' LOW = LS_SUBMIT-MATNR )
      ( SELNAME = 'S_STDDT' KIND = 'S' SIGN = 'I' OPTION = 'EQ' LOW = LS_SUBMIT-STDDT )
      ( SELNAME = 'P_EXEC'  KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = 'X' )
      ( SELNAME = 'P_BATCH' KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = 'X' ) ).

      SUBMIT ZGTPPR1060 VIA JOB LV_JOBNAME2
                        NUMBER LV_JOBCOUNT
                        WITH SELECTION-TABLE LT_SELTAB
                        AND RETURN.

      CLEAR: LV_UZEIT.
      LV_UZEIT = SY-UZEIT + 10.
      CALL FUNCTION 'JOB_CLOSE'
        EXPORTING
          JOBCOUNT             = LV_JOBCOUNT
          JOBNAME              = LV_JOBNAME2
          SDLSTRTDT            = SY-DATUM
          SDLSTRTTM            = LV_UZEIT
          STRTIMMED            = 'X'  "즉시 기동
        IMPORTING
          JOB_WAS_RELEASED     = LV_RELEASED
        EXCEPTIONS
          CANT_START_IMMEDIATE = 1
          INVALID_STARTDATE    = 2
          JOBNAME_MISSING      = 3
          JOB_CLOSE_FAILED     = 4
          JOB_NOSTEPS          = 5
          JOB_NOTEX            = 6
          LOCK_FAILED          = 7
          OTHERS               = 8.

    ENDLOOP.
  ENDIF.

ENDFUNCTION.
