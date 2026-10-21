*&---------------------------------------------------------------------*
*& Include          ZGTSDR9063F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INITIALIZATION .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_SCREEN .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_INPUT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_INPUT_DATA .

  CLEAR : GV_ERROR, GS_MESSAGE.

  IF P_SYSID IS INITIAL.
    MESSAGE S007 WITH %_P_SYSID_%_APP_%-TEXT INTO GS_MESSAGE-MESSAGE.
    GV_ERROR = ZGTSD_X.
    EXIT.
  ENDIF.

  IF P_VBELN IS INITIAL.
    MESSAGE S007 WITH %_P_VBELN_%_APP_%-TEXT INTO GS_MESSAGE-MESSAGE.
    GV_ERROR = ZGTSD_X.
    EXIT.
  ENDIF.

  IF P_WERKS IS INITIAL.
    MESSAGE S007 WITH %_P_WERKS_%_APP_%-TEXT INTO GS_MESSAGE-MESSAGE.
    GV_ERROR = ZGTSD_X.
    EXIT.
  ENDIF.

  IF P_JOB_NO IS INITIAL.
    MESSAGE S007 WITH %_P_JOB_NO_%_APP_%-TEXT INTO GS_MESSAGE-MESSAGE.
    GV_ERROR = ZGTSD_X.
    EXIT.
  ENDIF.

  WRITE : / 'SYTEMID :', P_SYSID, '/ SO :', P_VBELN, '/ Plant :',
            P_WERKS, '/ 제번 :', P_JOB_NO, 'Call Change Func :', P_CHG_F.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM AUTHORITY_CHECK .

*  "권한 체크
*  ZGTSD_CL_COMMON=>AUTHORITY_CHECK( EXPORTING IV_OBJECT     = 'VKO'
*                                              IV_AUTH_FIELD = CONV XUFIELD( |VKORG| )
*                                              IV_AUTH_VAL   = CONV XUVAL( P_VKORG )
*                                    IMPORTING EV_MTYPE      = DATA(LV_MTYPE)
*                                              EV_MSGTX      = DATA(LV_MSGTX) ).
*  IF LV_MTYPE = GC_E.
*    MESSAGE S001(00) WITH LV_MSGTX DISPLAY LIKE GC_E.
*    LEAVE LIST-PROCESSING.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_EXEC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DATA_EXEC .

  DATA : LV_SYSID   TYPE ZGTETARGET,
         LV_STAT    TYPE CHAR02,
         LV_TRTYP   TYPE CHAR01,
         LV_FACTOR  TYPE ISOC_FACTOR,
         LV_MSG     TYPE ZO_MESSAGE,
         LV_ZPGM    TYPE CHAR20,
         LV_RESULT  TYPE ZO_RESULT,
         LS_MESSAGE TYPE ZSDS_LOG_0001,
         LV_ABSTK   TYPE VBAK-ABSTK.

  CONSTANTS : LC_ZPGM    TYPE TEXT20 VALUE 'ZGTSDR9063',
              LC_ZMODULE TYPE CHAR02 VALUE 'SD'.

  SELECT SINGLE ABGRU, ABSTK, ZPJNO INTO @DATA(LS_SO)
    FROM VBAP AS A INNER JOIN VBAK AS B
      ON A~VBELN = B~VBELN
   WHERE A~VBELN = @P_VBELN.

  IF P_CHG_F IS INITIAL.
    LV_ABSTK       = |A|.
    LV_STAT        = |S1|.
    LV_TRTYP       = 'C'.
    LV_ZPGM        = |ZGTSDR9063|.
  ELSE.
    LV_ABSTK = LS_SO-ABSTK.
    LV_STAT  = |S2|.
    LV_TRTYP = 'U'.
    LV_ZPGM  = |ZGTSDR9063_CHANGE|.
  ENDIF.

  TRY.
      CALL FUNCTION 'ZGTED_BD_WORK_DATA_STATUS'
        EXPORTING
          I_ZMODULE  = LC_ZMODULE
          I_ZPROGRAM = LC_ZPGM
          I_ZWERKS   = P_WERKS
          I_ZJOB_NO  = P_JOB_NO
          I_ZSTATUS  = LV_STAT
          I_VBELN    = P_VBELN
          I_ZABSTK   = LV_ABSTK
          I_ZATT1    = P_ZATT1
          I_ZATT2    = P_ZATT2
          I_ZATT3    = P_ZATT3
        IMPORTING
          ZO_RESULT  = LV_RESULT
          ZO_MESSAGE = LV_MSG.
    CATCH CX_ROOT INTO DATA(LO_ERR).
      LS_MESSAGE-MTYPE = 'E'.
      IF P_CHG_F IS INITIAL.
        LS_MESSAGE-MESSAGE = '판매오더 생성되었으나 제조지시상태는 변경되지 않았습니다.'.
        CASE LS_SO-ABGRU.
          WHEN 'Z1'.
            LS_MESSAGE-MESSAGE = '판매오더 생성(수주조건 차이로 보류) 되었으나 제조지시상태는 변경되지 않았습니다.'.
        ENDCASE.
      ELSE.
        LS_MESSAGE-MESSAGE = '제조지시 상태 변경 실패.'.
      ENDIF.

*zgtsdt9000 UPDATE
      PERFORM BD_LOG_UPDATE USING    P_SYSID
                                     LV_RESULT
                                     LV_MSG
                                     LS_MESSAGE-MTYPE
                                     LS_MESSAGE-MESSAGE
                                     LC_ZMODULE
                                     LV_ZPGM
                                     P_WERKS
                                     P_JOB_NO
                                     P_VBELN
                                     LV_ABSTK
                                     LV_STAT
                                     LV_TRTYP
                                     P_ZATT1
                                     P_ZATT2
                                     P_ZATT3.
      EXIT.
  ENDTRY.

  IF LV_RESULT NE '00'.
    LS_MESSAGE-MTYPE = 'E'.
    IF P_CHG_F IS INITIAL.
      LS_MESSAGE-MESSAGE = '판매오더 생성되었으나 제조지시상태는 변경되지 않았습니다.'.
      CASE LS_SO-ABGRU.
        WHEN 'Z1'.
          LS_MESSAGE-MESSAGE = '판매오더 생성(수주조건 차이로 보류) 되었으나 제조지시상태는 변경되지 않았습니다.'.
      ENDCASE.
    ELSE.
      LS_MESSAGE-MESSAGE = '제조지시 상태 변경 실패.'.
    ENDIF.
  ELSE.
    LS_MESSAGE-MTYPE = 'S'.
    IF P_CHG_F IS INITIAL.
      LS_MESSAGE-MESSAGE = '판매오더 생성 후 제조지시상태 변경 성공.'.
      CASE LS_SO-ABGRU.
        WHEN 'Z1'.
          LS_MESSAGE-MESSAGE = '판매오더 생성(수주조건 차이로 보류)후 제조지시상태 변경 성공.'.
      ENDCASE.
    ELSE.
      LS_MESSAGE-MESSAGE = '제조지시 상태 변경 성공.'.
      IF LV_ABSTK  = |C|.

*-- 일괄거부 판매오더 제조지시정보 삭제
        TRY.
            UPDATE : ZGTSDT0065 SET VBELN = SPACE
                              WHERE ZSYSTEM_ID EQ P_SYSID
                                AND JOB_NO     EQ P_JOB_NO
                                AND ZPJNO      EQ LS_SO-ZPJNO,
                     ZGTSDT0066 SET VBELN = SPACE
                              WHERE ZSYSTEM_ID EQ P_SYSID
                                AND JOB_NO     EQ P_JOB_NO,
                     ZGTSDT0067 SET VBELN = SPACE
                              WHERE ZSYSTEM_ID EQ P_SYSID
                                AND JOB_NO     EQ P_JOB_NO.
          CATCH CX_SY_OPEN_SQL_DB INTO DATA(LO_SQL_DB).
            DATA(LV_EMSG) = LO_SQL_DB->GET_TEXT( ).
            LS_MESSAGE-MESSAGE = LV_EMSG.
            LS_MESSAGE-MTYPE = 'E'.
*zgtsdt9000 UPDATE
            PERFORM BD_LOG_UPDATE USING    P_SYSID
                                           LV_RESULT
                                           LV_MSG
                                           LS_MESSAGE-MTYPE
                                           LS_MESSAGE-MESSAGE
                                           LC_ZMODULE
                                           LV_ZPGM
                                           P_WERKS
                                           P_JOB_NO
                                           P_VBELN
                                           LV_ABSTK
                                           LV_STAT
                                           LV_TRTYP
                                           P_ZATT1
                                           P_ZATT2
                                           P_ZATT3.

        ENDTRY.

      ENDIF.

    ENDIF.
  ENDIF.

*zgtsdt9000 UPDATE
  PERFORM BD_LOG_UPDATE USING    P_SYSID
                                 LV_RESULT
                                 LV_MSG
                                 LS_MESSAGE-MTYPE
                                 LS_MESSAGE-MESSAGE
                                 LC_ZMODULE
                                 LV_ZPGM
                                 P_WERKS
                                 P_JOB_NO
                                 P_VBELN
                                 LV_ABSTK
                                 LV_STAT
                                 LV_TRTYP
                                 P_ZATT1
                                 P_ZATT2
                                 P_ZATT3.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form BD_LOG_UPDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_SYSID
*&      --> LV_RESULT
*&      --> LV_MSG
*&---------------------------------------------------------------------*
FORM BD_LOG_UPDATE  USING    PV_SYSID
                             PV_RESULT
                             PV_MSG
                             PV_ERP_RSLT
                             PV_ERP_MSG
                             PV_ZMODULE
                             PV_ZPGM
                             PV_WERKS
                             PV_JOBNO
                             PV_VBELN
                             PV_ABSTK
                             PV_JOB_STAT
                             PV_TRTYP
                             PV_USERID
                             PV_NAME
                             PV_EMAIL.

  DATA : LS_9000 TYPE ZGTSDT9000.

  GET TIME STAMP FIELD LS_9000-ZIFKEY.
  LS_9000-ZIFRFC       = 'ZGTED_BD_WORK_DATA_STATUS'.
  LS_9000-ZSYSTEM_ID   = PV_SYSID.
  LS_9000-ZVALUE01     = PV_ZMODULE.
  LS_9000-ZVALUE02     = PV_ZPGM.
  LS_9000-ZVALUE03     = PV_WERKS.
  LS_9000-ZVALUE04     = PV_JOBNO.
  LS_9000-ZVALUE05     = PV_VBELN.
  LS_9000-ZVALUE06     = PV_ABSTK.
  LS_9000-ZVALUE07     = PV_JOB_STAT.
  LS_9000-ZVALUE08     = PV_TRTYP.
  LS_9000-ZVALUE09     = PV_USERID.
  LS_9000-ZVALUE10     = PV_NAME.
  LS_9000-ZVALUE11     = PV_EMAIL.
  LS_9000-ZSTAT        = PV_RESULT.
  LS_9000-ZMESSAGE     = PV_MSG.
  LS_9000-ZERP_STAT    = PV_ERP_RSLT.
  LS_9000-ZERP_MESSAGE = PV_ERP_MSG.
  LS_9000-IFDAT        = SY-DATUM.
  LS_9000-IFTIM        = SY-TIMLO.
  LS_9000-IFNAM        = SY-UNAME.
  LS_9000-ERNAM        = SY-UNAME.
  LS_9000-ERDAT        = SY-DATUM.
  LS_9000-ERZEIT       = SY-UZEIT.
  LS_9000-ERDATLO      = SY-DATLO.
  LS_9000-ERTIMLO      = SY-TIMLO.
  LS_9000-ERTCODE      = SY-TCODE.

  MODIFY ZGTSDT9000 FROM LS_9000.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_ERR_MESSAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_ERR_MESSAGE .

  DATA : LV_SYSID  TYPE ZGTETARGET,
         LV_STAT   TYPE CHAR02,
         LV_TRTYP  TYPE CHAR01,
         LV_FACTOR TYPE ISOC_FACTOR,
         LV_MSG    TYPE ZO_MESSAGE,
         LV_ZPGM   TYPE CHAR20,
         LV_RESULT TYPE ZO_RESULT.

  CONSTANTS : LC_ZPGM    TYPE TEXT20 VALUE 'ZGTSDR9063',
              LC_ZMODULE TYPE CHAR02 VALUE 'SD'.


  SELECT SINGLE ABGRU, ABSTK INTO @DATA(LS_SO)
    FROM VBAP AS A INNER JOIN VBAK AS B
      ON A~VBELN = B~VBELN
   WHERE A~VBELN = @P_VBELN.


  IF P_CHG_F IS INITIAL.
    DATA(LV_ABSTK) = |A|.
    LV_STAT        = |S1|.
    LV_TRTYP       = 'C'.
    LV_ZPGM        = |ZGTSDR9063|.
  ELSE.
    LV_STAT  = |S2|.
    LV_TRTYP = 'U'.
    LV_ABSTK = LS_SO-ABSTK.
    LV_ZPGM  = |ZGTSDR9063_CHANGE|.
  ENDIF.

  GS_MESSAGE-MTYPE = 'E'.

*zgtsdt9000 UPDATE
  PERFORM BD_LOG_UPDATE USING    P_SYSID
                                 LV_RESULT
                                 LV_MSG
                                 GS_MESSAGE-MTYPE
                                 GS_MESSAGE-MESSAGE
                                 LC_ZMODULE
                                 LV_ZPGM
                                 P_WERKS
                                 P_JOB_NO
                                 P_VBELN
                                 LV_ABSTK
                                 LV_STAT
                                 LV_TRTYP
                                 P_ZATT1
                                 P_ZATT2
                                 P_ZATT3.

  MESSAGE S000 WITH GS_MESSAGE-MESSAGE DISPLAY LIKE 'E'.

ENDFORM.
