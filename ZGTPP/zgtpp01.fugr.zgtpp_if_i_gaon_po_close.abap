FUNCTION ZGTPP_IF_I_GAON_PO_CLOSE.
*"--------------------------------------------------------------------
*"*"로컬인터페이스:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_CLSD STRUCTURE  ZGTPPSIF0028
*"      OT_RESULT STRUCTURE  ZGTPPSIF0029
*"--------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_GAON_PO_CLOSE
*& 프로그램 명 : [GT] [Cable MES] 생산오더 종료 처리
*& 개요   :
*& 생성일 : 2024.12.12
*& 생성자 : ZGSIDEV08
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : 지중/부스닥트 MES
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*
  DATA: LT_CLSD TYPE TABLE OF ZGTPPSIF0028.
  DATA: LV_ERROR.
  DATA: LV_MESSAGE(220).
  DATA: LV_WERKS TYPE T001W-WERKS.
  DATA: LV_RUECK TYPE ZGTPPT3130-RUECK,
        LV_RMZHL TYPE ZGTPPT3130-RMZHL.

  CLEAR: LT_CLSD, LV_ERROR, GS_CLSD, GT_CLSD, GT_CLSD_RESULT[],
         OT_RESULT, OT_RESULT[], GS_CLSD_KEYS, GT_CLSD_KEYS.

  LT_CLSD[] = IT_CLSD[].
  GT_CLSD = CORRESPONDING #( LT_CLSD MAPPING I_MODE = MODE ).

  LOOP AT GT_CLSD INTO GS_CLSD.
    CLEAR: LV_ERROR, LV_RUECK, LV_RMZHL.

*- Conversion input
    PERFORM CONVERSION_INPUT_CLSD USING GS_CLSD-AUFNR.

    GS_CLSD-ZSYSTEM_ID = I_SYSTEM_ID.

*- 생산오더 종료/취소 처리
    PERFORM PRO_ORD_CHG_STAT USING LV_ERROR
                                   LV_RUECK
                                   LV_RMZHL
                                   GS_CLSD-I_MODE.
    IF LV_ERROR = GC_X.
      LV_MESSAGE = VALUE #( GT_CLSD_RESULT[ ZSERNO = GS_CLSD-ZSERNO ]-ZERP_MESSAGE OPTIONAL ).
      PERFORM SAVE_LOG_ZGTPPT3130 USING GC_E
                                        LV_MESSAGE
                                        ''
                                        ''.
      CLEAR GS_CLSD.
      CONTINUE.
    ENDIF.

    "절단 지시 생성/취소
    IF GS_CLSD-ZSYSTEM_ID EQ 'KGPM' AND GV_CHK IS INITIAL AND
     ( GS_CLSD-I_MODE EQ 'P' OR GS_CLSD-I_MODE EQ 'C' ).
      PERFORM PRO_ZZCUT_REQ USING LV_ERROR.

      IF LV_ERROR = GC_X.
*        LV_MESSAGE = VALUE #( GT_CLSD_RESULT[ ZSERNO = GS_CLSD-ZSERNO ]-ZERP_MESSAGE OPTIONAL ).
*        PERFORM SAVE_LOG_ZGTPPT3130 USING GC_E
*                                          LV_MESSAGE
*                                          ''
*                                          ''.
        CLEAR GS_CLSD.
        CONTINUE.
      ENDIF.
    ENDIF.

    GR_AUFNR[] = VALUE #( BASE GR_AUFNR[] ( SIGN = 'I' OPTION = 'EQ' LOW = GS_CLSD-AUFNR ) ).
    CLEAR GS_CLSD.
  ENDLOOP.

*- 생산오더 전송 프로그램 호출(ZGTPPI2010)
*  RANGES: LR_ERDAT FOR SY-DATUM.
*
*  JOBNAME = '생산오더전송'.
*  CALL FUNCTION 'JOB_OPEN'
*    EXPORTING
*      JOBNAME          = JOBNAME
*    IMPORTING
*      JOBCOUNT         = JOBCOUNT
*    EXCEPTIONS
*      CANT_CREATE_JOB  = 1
*      INVALID_JOB_DATA = 2
*      JOBNAME_MISSING  = 3
*      OTHERS           = 4.
*
*  CLEAR: LR_ERDAT[].
*
*  SUBMIT ZGTPPI2010 VIA JOB JOBNAME
*                    NUMBER JOBCOUNT
*                    AND RETURN
*                    WITH S_AUFNR IN GR_AUFNR
*                    WITH S_ERDAT IN LR_ERDAT
*                    WITH P_R3    = 'X'
*                    WITH P_R8    = 'X'.
*
*  CALL FUNCTION 'JOB_CLOSE'
*    EXPORTING
*      JOBCOUNT             = JOBCOUNT
*      JOBNAME              = JOBNAME
*      STRTIMMED            = 'X'
*    EXCEPTIONS
*      CANT_START_IMMEDIATE = 1
*      INVALID_STARTDATE    = 2
*      JOBNAME_MISSING      = 3
*      JOB_CLOSE_FAILED     = 4
*      JOB_NOSTEPS          = 5
*      JOB_NOTEX            = 6
*      LOCK_FAILED          = 7
*      OTHERS               = 8.

*- RFC 펑션 결과 리턴
  PERFORM CONVERSION_OUTPUT_CLSD.

  PERFORM RESULT_CLSD_DATA USING ZO_RESULT
                                 ZO_MESSAGE.

  OT_RESULT[] = GT_CLSD_RESULT[].

*- ZO_RESULT, ZO_MESSAGE 업데이트
  IF GT_CLSD_KEYS[] IS NOT INITIAL.
    LOOP AT GT_CLSD_KEYS INTO GS_CLSD_KEYS.
      UPDATE ZGTPPT3130 SET ZSTAT    = ZO_RESULT
                            ZMESSAGE = ZO_MESSAGE
                      WHERE ZIFKEY     = GS_CLSD_KEYS-ZIFKEY
                        AND ZSYSTEM_ID = GS_CLSD_KEYS-ZSYSTEM_ID
                        AND ZSERNO     = GS_CLSD_KEYS-ZSERNO
                        AND WERKS      = GS_CLSD_KEYS-WERKS
                        AND AUFNR      = GS_CLSD_KEYS-AUFNR.
    ENDLOOP.

    COMMIT WORK.
  ENDIF.

ENDFUNCTION.
