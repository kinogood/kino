FUNCTION Z_TI_EXPENCES_CODE_BY_GROUP.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(XBUKRS) TYPE  BUKRS
*"     VALUE(XEXPGR) TYPE  ZTIEXPGR
*"     VALUE(XAUTO) TYPE  C DEFAULT SPACE
*"  EXPORTING
*"     VALUE(P_ANSWER) TYPE  C
*"  TABLES
*"      XZTITIG06 STRUCTURE  ZTISIG06 OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------
  DATA: L_TEXT32(32)   TYPE C.

  PERFORM GET_DOMAIN_VALUE_TEXT(ZTIR0000)
                               USING    'ZTIEXPGR'
                                         XEXPGR
                                         L_TEXT32.

  SELECT  *
    INTO  CORRESPONDING FIELDS OF TABLE XZTITIG06
    FROM  ZTITIG06 AS H INNER JOIN T001 AS C
      ON  H~BUKRS EQ C~BUKRS
   WHERE  H~BUKRS EQ XBUKRS
     AND  H~EXPGR EQ XEXPGR.

  IF SY-SUBRC NE 0.
    MESSAGE E874 RAISING NOT_FOUND.
  ENDIF.

  LOOP AT XZTITIG06.
    G_TABIX = SY-TABIX.

*-<< 기능개선 283274 - 비용코드 삭제에 따른 수정
    IF XBUKRS = '1000' AND XEXPGR = 'B'. "선적관련 비용
      IF XZTITIG06-EXPCD EQ 'AR2' OR     "항공운임(해외포딩 영수증)
         XZTITIG06-EXPCD EQ 'CTX' OR     "CONTAINER TAX
         XZTITIG06-EXPCD EQ 'IN2' .      "경비료
        DELETE XZTITIG06 INDEX G_TABIX.
        CONTINUE.
      ENDIF.
    ENDIF.
*->> 기능개선 283274

    SELECT *
      FROM ZTITIG07 UP TO 1 ROWS
     WHERE EXPGR EQ XZTITIG06-EXPGR
       AND EXPCD EQ XZTITIG06-EXPCD.
    ENDSELECT.
    IF SY-SUBRC EQ 0.
      DELETE XZTITIG06 INDEX G_TABIX.
      CONTINUE.
    ELSE.
      IF XAUTO EQ 'X'.
        XZTITIG06-BOX = 'X'.
        MODIFY XZTITIG06.
      ENDIF.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE XZTITIG06 LINES G_LINE.
  IF G_LINE EQ 1.
    LOOP AT XZTITIG06.
      XZTITIG06-BOX = 'X'.
      MODIFY XZTITIG06.
    ENDLOOP.
    P_ANSWER = 'Y'.
    EXIT.
  ELSEIF G_LINE EQ 0.
    MESSAGE E874 RAISING NOT_FOUND.
  ENDIF.

  IF XAUTO EQ 'X'.
    P_ANSWER = 'Y'.
    EXIT.
  ENDIF.

  FREE : T_FIELDCAT.  CLEAR: T_FIELDCAT.
  MFC 'XZTITIG06'  'BOX'      'ZTISIG06' 'BOX'   '' '' ''.
  MFC 'XZTITIG06'  'EXPCD'    'ZTISIG06' 'EXPCD' '' '' ''.
  MFC 'XZTITIG06'  'EXPTX'    'ZTISIG06' 'EXPTX' '' '' ''.
  MFC 'XZTITIG06'  'MWSKZ'    'ZTISIG06' 'MWSKZ' '' '' ''.
  MFC 'XZTITIG06'  'KSCHL'    'ZTISIG06' 'KSCHL' '' '' ''.
  MFC 'XZTITIG06'  'CSCTY'    'ZTISIG06' 'CSCTY' '' '' ''.
  MFC 'XZTITIG06'  'SAKNR'    'ZTISIG06' 'SAKNR' '' '' ''.
  MFC 'XZTITIG06'  'RSBTR'    'ZTISIG06' 'RSBTR' '' 'C' 'WAERS'.
  MFC 'XZTITIG06'  'WAERS'    'ZTISIG06' 'WAERS' '' '' ''.

  PERFORM GET_FTEXT(RDDFIE00)   USING    'ZTITIG06' 'EXPGR' SY-LANGU
                                CHANGING DFIES G_SUBRC.

  IF G_SUBRC EQ 0.
    CONCATENATE DFIES-SCRTEXT_M ':' L_TEXT32 INTO G_TITLE.
  ELSE.
    G_TITLE = L_TEXT32.
  ENDIF.

  REFRESH: EXTAB.

*  APPEND '&NT1'      TO extab.
*  APPEND '&ALL'      TO extab.
*  APPEND '&SAL'      TO extab.
*  APPEND '&IC1'      TO extab.
*  APPEND '&ETA'      TO extab.

  DYNAME = 'SAPLZ_TI_COMMON_FUNCTIONS'.

  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      I_TITLE                 = G_TITLE
      I_SELECTION             = 'X'
      I_ALLOW_NO_SELECTION    = 'X'
      I_ZEBRA                 = 'X'
      I_CHECKBOX_FIELDNAME    = 'BOX'
      I_LINEMARK_FIELDNAME    = 'BOX'
      I_SCROLL_TO_SEL_LINE    = 'X'
      I_TABNAME               = 'XZTITIG06'
      IT_FIELDCAT             = T_FIELDCAT[]
      IS_PRIVATE              = GS_PRIVATE
      I_SCREEN_START_COLUMN   = 1
      I_SCREEN_START_LINE     = 1
*      i_screen_end_column     = 100
*      i_screen_end_line       = 20
      IT_EXCLUDING            = EXTAB
      I_CALLBACK_PROGRAM      = DYNAME
*      i_callback_user_command = 'USER_POPUP_COMMAND1'
    IMPORTING
      ES_SELFIELD             = GS_SELFIELD
      E_EXIT                  = G_EXIT
    TABLES
      T_OUTTAB                = XZTITIG06[]
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.

  IF SY-SUBRC EQ 0.
    IF G_EXIT IS INITIAL.
      P_ANSWER = 'Y'.
    ELSE.
      P_ANSWER = 'N'.
    ENDIF.
  ENDIF.

ENDFUNCTION.
