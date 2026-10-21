*&---------------------------------------------------------------------*
*& Include          ZGTPPR2370F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC .

  DATA : LV_TEXT(100).
*  갱신된 생산오더정보 MES 전송
  DATA : LV_JOBNAME  TYPE TBTCJOB-JOBNAME VALUE 'SUBMIT_ZGTPPI2010_'.
  DATA : LV_JOBNAME01  TYPE TBTCJOB-JOBNAME.
  DATA : LV_JOBCOUNT TYPE TBTCJOB-JOBCOUNT.
  DATA : LT_SELTAB   TYPE TABLE OF RSPARAMS.
  DATA : LV_GUBUN(10) TYPE N.
  DATA : LV_WERKS TYPE WERKS_D.
  DATA : BEGIN OF LS_AUFNR,
           AUFNR TYPE AUFK-AUFNR,
           WERKS TYPE WERKS_D,
         END OF LS_AUFNR.
  DATA : LT_AUFNR LIKE TABLE OF LS_AUFNR.

  WITH +T_2010 AS (
    SELECT GRPNR, ORDNR, POSNR, DMORD, DMLINE FROM ZGTPPT2010
     WHERE ORDNR IN @S_AUFNR
       AND ORDTY = 'PRD'
       AND DMORDTY = 'SO' )
    SELECT DISTINCT B~AUFNR, B~POSNR, B~KDAUF, B~KDPOS, A~DMORD, A~DMLINE, A~GRPNR
      FROM +T_2010 AS A
      INNER JOIN AFPO AS B ON B~AUFNR = A~ORDNR
                     AND CONCAT( '00', B~POSNR ) = A~POSNR
     WHERE B~KDAUF = ''
      INTO TABLE @DATA(LT_MOSU).


  IF LT_MOSU[] IS INITIAL.
    MESSAGE S006 WITH '판매오더, 품목 정보 갱신 할 생산오더가 없습니다.'(m01).
    RETURN.
  ENDIF.

  WRITE '판매오더 갱신대상 정보'.

  LOOP AT LT_MOSU INTO DATA(LS_MOSU).
    UPDATE AFPO SET KDAUF = LS_MOSU-DMORD
                      KDPOS = LS_MOSU-DMLINE
                      SOBKZ = 'E'
                      KZBWS = 'A'
              WHERE AUFNR = LS_MOSU-AUFNR
                  AND POSNR = LS_MOSU-POSNR.
    COMMIT WORK AND WAIT.

    CLEAR LV_TEXT.
    LV_TEXT = |생산오더({ LS_MOSU-AUFNR }/{ LS_MOSU-POSNR })에 판매오더({ LS_MOSU-DMORD }/{ LS_MOSU-DMLINE }) 정보 갱신하였습니다.|.
    WRITE : / LV_TEXT.

    CLEAR LS_AUFNR.
    LS_AUFNR-WERKS = COND #( WHEN LS_MOSU-GRPNR+0(2) EQ 'GP' THEN '6500'
                             WHEN LS_MOSU-GRPNR+0(2)  EQ 'GO' THEN '6600' ).
    IF LS_AUFNR-WERKS IS INITIAL. " 현재 가온전선만 적용
      CONTINUE.
    ENDIF.

    LS_AUFNR-AUFNR = LS_MOSU-AUFNR.
    COLLECT LS_AUFNR INTO LT_AUFNR.
  ENDLOOP.

* mes 전송
  CLEAR LV_GUBUN.
  LOOP AT LT_AUFNR INTO LS_AUFNR.

    ADD 1 TO LV_GUBUN.
    CLEAR LV_JOBNAME01.
    LV_JOBNAME01 = LV_JOBNAME && LV_GUBUN.

    REFRESH LT_SELTAB.
    APPEND VALUE #( SELNAME = 'S_AUFNR' KIND = 'S' SIGN = 'I' OPTION = 'EQ' LOW = LS_AUFNR-AUFNR ) TO LT_SELTAB.
    LT_SELTAB = VALUE #( BASE LT_SELTAB ( SELNAME = 'S_ERDAT' KIND = 'S' SIGN = 'I' OPTION = 'BT' LOW = ( SY-DATUM - 365 ) HIGH = SY-DATUM )
                                        ( SELNAME = 'P_R1'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = ABAP_TRUE  )    "// 처리모드
                                        ( SELNAME = 'P_R2'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = ABAP_FALSE )
                                        ( SELNAME = 'P_R3'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = ABAP_FALSE )    "// 대상시스템.
                                        ( SELNAME = 'P_R4'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = ABAP_FALSE )
                                        ( SELNAME = 'P_R9'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = ABAP_FALSE )
                                        ( SELNAME = 'P_R10'   KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = COND #( WHEN LS_AUFNR-WERKS EQ '6500' THEN ABAP_TRUE ) )
                                        ( SELNAME = 'P_R11'   KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = COND #( WHEN LS_AUFNR-WERKS EQ '6600' THEN ABAP_TRUE ) )
                                        ( SELNAME = 'P_R8'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = ABAP_TRUE   ) ). "// 배치처리.

    PERFORM BATCH_JOB_OPEN USING LV_JOBNAME01 LV_JOBCOUNT.

    CHECK LV_JOBCOUNT IS NOT INITIAL.

    SUBMIT ZGTPPI2010 VIA JOB LV_JOBNAME01 NUMBER LV_JOBCOUNT
                      WITH SELECTION-TABLE LT_SELTAB
                      AND RETURN.

    PERFORM BATCH_JOB_CLOSE USING LV_JOBNAME01 LV_JOBCOUNT.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BATCH_JOB_OPEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM BATCH_JOB_OPEN  USING PV_JOBNAME PV_JOBCOUNT.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      JOBNAME          = PV_JOBNAME
    IMPORTING
      JOBCOUNT         = PV_JOBCOUNT
    EXCEPTIONS
      CANT_CREATE_JOB  = 1
      INVALID_JOB_DATA = 2
      JOBNAME_MISSING  = 3
      OTHERS           = 4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form batch_job_CLOSE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM BATCH_JOB_CLOSE  USING PV_JOBNAME PV_JOBCOUNT.
  DATA LV_RELEASED TYPE BTCH0000-CHAR1.

  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      JOBCOUNT             = PV_JOBCOUNT
      JOBNAME              = PV_JOBNAME
      STRTIMMED            = ABAP_TRUE
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

ENDFORM.
