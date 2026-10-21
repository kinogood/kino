*&---------------------------------------------------------------------*
*& Include          ZGTSDR1290F01
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
*-고객계정그룹
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_KTOKD_0001 )
      TO S_KTOKD.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_KTOKD_9001 )
      TO S_KTOKD.

*-회사코드
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_BUKRS_6000 )
      TO S_BUKRS.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN_OUTPUT .
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 EQ 'ZM1'.
      SCREEN-INPUT = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAIN .
*-01. INIT OBJECTS
  PERFORM INIT_OBJECTS.

*-02. CHECK INPUT
  PERFORM CHECK_INPUT_VALUE.

*-03. SET VALUES
  PERFORM SET_VALUES.

*-04. GET DATA
  PERFORM GET_DATA.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_OBJECTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_OBJECTS .
  CLEAR:
         GV_TITLE,GV_EDIT.

  REFRESH:
          GT_LIST.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_INPUT_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_INPUT_VALUE .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VALUES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_VALUES .
  GV_TITLE = TEXT-001.

  GV_EDIT  = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .

*-01. 내수고객/해외고객
  SELECT A~KUNNR,A~BUKRS,
         B~KTOKD,
         D~PARTNER,
         E~CHECK_RULE AS CHECK_RULE_O
    FROM KNB1 AS A INNER JOIN KNA1 AS B
                   ON A~KUNNR = B~KUNNR
                   INNER JOIN CVI_CUST_LINK AS C
                   ON B~KUNNR = C~CUSTOMER
                   INNER JOIN BUT000 AS D
                   ON C~PARTNER_GUID = D~PARTNER_GUID
                   INNER JOIN UKMBP_CMS AS E
                   ON D~PARTNER = E~PARTNER
   WHERE A~BUKRS      IN @S_BUKRS
     AND B~KTOKD      IN @S_KTOKD
*     AND E~CHECK_RULE NE @SPACE
     AND E~CHECK_RULE NE @GC_CRULE_GO_STND
    INTO TABLE @DATA(LT_DATA).

  CHECK LT_DATA[] IS NOT INITIAL.
  SORT LT_DATA BY KUNNR PARTNER.
  DELETE ADJACENT DUPLICATES FROM LT_DATA COMPARING KUNNR PARTNER.

*-02. TEXT
  "고객명
  DATA(LT_TEMP) = LT_DATA[].
  SORT LT_TEMP BY PARTNER.
  DELETE ADJACENT DUPLICATES FROM LT_DATA COMPARING PARTNER.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT A~PARTNER,B~NAME1
      FROM BUT020 AS A INNER JOIN ADRC AS B
                       ON A~ADDRNUMBER = B~ADDRNUMBER AND
                          B~DATE_FROM  <= @SY-DATLO  AND
                          B~NATION     = @SPACE
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE A~PARTNER EQ @LT_TEMP-PARTNER
      INTO TABLE @DATA(LT_ADRC).
  ENDIF.

*-03. 리스트 구성
  LOOP AT LT_DATA INTO DATA(LS_DATA).
    CLEAR GS_LIST.
    MOVE-CORRESPONDING LS_DATA TO GS_LIST.

    "고객명
    IF GS_LIST-PARTNER IS NOT INITIAL.
      GS_LIST-KUNNR_TX = VALUE #( LT_ADRC[ PARTNER = GS_LIST-PARTNER ]-NAME1 OPTIONAL ).
    ENDIF.

    "신규 CHECK_RULE
    GS_LIST-CHECK_RULE_N = GC_CRULE_GO_STND.

    "LED
    PERFORM SET_LED CHANGING GS_LIST.

    APPEND GS_LIST TO GT_LIST.
  ENDLOOP.

  SORT GT_LIST BY KTOKD KUNNR.

  FREE:LT_DATA,LT_TEMP,LS_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_LIST
*&---------------------------------------------------------------------*
FORM SET_LED  CHANGING PS_LIST LIKE GS_LIST.
  CASE PS_LIST-RSLT.
    WHEN GC_S.
      PS_LIST-STAT = ICON_LED_GREEN.
    WHEN GC_E.
      PS_LIST-STAT = ICON_LED_RED.
    WHEN OTHERS.
      PS_LIST-STAT = ICON_LED_YELLOW.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY .
  IF GT_LIST[] IS NOT INITIAL.
    IF SY-BATCH IS NOT INITIAL.
      PERFORM BACKGROUND_PROCESS.
    ELSE.
      CALL SCREEN 0100.
    ENDIF.
  ELSE.
    MESSAGE S018.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BACKGROUND_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BACKGROUND_PROCESS .
  MODIFY GT_LIST FROM VALUE #( SEL = GC_X )
                 TRANSPORTING SEL
                WHERE SEL NE GC_X.

*-고객 점검규칙 변경
  PERFORM CHANGE_BP_CHECK_RULE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_ALL_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECT_ALL_0100 .
  MODIFY GT_LIST FROM VALUE #( SEL = GC_X )
                 TRANSPORTING SEL
                 WHERE SEL NE GC_X
                   AND RSLT NE GC_S.

  PERFORM REFRESH_ALV USING GO_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DESELECT_ALL_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DESELECT_ALL_0100 .
  MODIFY GT_LIST FROM VALUE #( SEL = '' )
                 TRANSPORTING SEL
                 WHERE SEL EQ GC_X.

  PERFORM REFRESH_ALV USING GO_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAINTAIN_BP_CHECK_RULE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAINTAIN_BP_CHECK_RULE .

  PERFORM CHECK_CHANGED_DATA USING GO_GRID.

*-01. CHECK
  CLEAR GV_ERROR.
  PERFORM CHECK_LIST_PRCESS_0100.
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.

  CHECK ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-P01 ) EQ GC_J.

*-02. 고객 점검규칙 변경
  PERFORM CHANGE_BP_CHECK_RULE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_LIST_PRCESS_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_LIST_PRCESS_0100 .
  DATA:LV_CHK(1).


*-01. 선택
  IF NOT LINE_EXISTS( GT_LIST[ SEL = GC_X ] ).
    GV_ERROR = GC_X.
    MESSAGE I004 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  LOOP AT GT_LIST INTO GS_LIST WHERE SEL  EQ GC_X
                                 AND RSLT NE GC_S.
    LV_CHK = GC_X.
    EXIT.
  ENDLOOP.
  IF LV_CHK IS INITIAL.
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-M01 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_BP_CHECK_RULE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_BP_CHECK_RULE .
  DATA: LV_MSG1(50),
        LV_MSG2(50).

  CLEAR:GV_ERROR.
  CLEAR:GT_ZGTSDT9050[].

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>) WHERE SEL  EQ GC_X
                                                      AND RSLT NE GC_S.
    CLEAR: <FS_LIST>-RSLT,<FS_LIST>-MESSAGE.

    "고객 BP 점검규칙 변경
    PERFORM CHANGE_BP_CHECK_RULE_PROC CHANGING <FS_LIST>.


    "LED
    PERFORM SET_LED CHANGING <FS_LIST>.

    PERFORM SET_ATTRIBUTES_LINE CHANGING <FS_LIST>.

    IF <FS_LIST>-RSLT EQ GC_E.
      GV_ERROR = GC_X.
    ENDIF.

    "log
    APPEND VALUE #( ZGUID        = CL_SYSTEM_UUID=>CREATE_UUID_X16_STATIC( )
                    KUNNR        = <FS_LIST>-KUNNR
                    BUKRS        = <FS_LIST>-BUKRS
                    PARTNER      = <FS_LIST>-PARTNER
                    CHECK_RULE_O = <FS_LIST>-CHECK_RULE_O
                    CHECK_RULE_N = <FS_LIST>-CHECK_RULE_N
                    TYPE         = <FS_LIST>-RSLT
                    MESSAGE      = <FS_LIST>-MESSAGE
                  ) TO GT_ZGTSDT9050.
  ENDLOOP.

  "LOG
  IF GT_ZGTSDT9050[] IS NOT INITIAL.
    ZGTSD_CL_COMMON2=>GET_TIMESTAMP_MULTI( CHANGING IT_VALUE = GT_ZGTSDT9050[] ).
    MODIFY ZGTSDT9050 FROM TABLE GT_ZGTSDT9050.
    COMMIT WORK AND WAIT.
  ENDIF.

  IF SY-BATCH IS NOT INITIAL.

    DATA(LS_LOG) = VALUE #( GT_ZGTSDT9050[ 1 ] OPTIONAL ).
    IF LS_LOG IS NOT INITIAL.
      WRITE: LS_LOG-ERDAT  TO LV_MSG1 USING EDIT MASK '____.__.__'.CONDENSE LV_MSG1.
      WRITE: LS_LOG-ERZEIT TO LV_MSG2 USING EDIT MASK '__:__:__'.  CONDENSE LV_MSG2.
      LV_MSG1 = |[{ LV_MSG1 }/{ LV_MSG2 }]|.
      CLEAR LV_MSG2.
      LV_MSG2 = TEXT-002.

      MESSAGE S000(ZGTSD01) WITH LV_MSG2 TEXT-003 LV_MSG1 ')'.
    ELSE.
      MESSAGE S000(ZGTSD01) WITH TEXT-002.
    ENDIF.

  ELSE.
    IF GV_ERROR IS NOT INITIAL.
      MESSAGE I000(ZGTSD01) WITH TEXT-M02 DISPLAY LIKE GC_E.
    ELSE.
      CLEAR LV_MSG2.
      LV_MSG2 = TEXT-002.
      MESSAGE I000(ZGTSD01) WITH LV_MSG2 DISPLAY LIKE GC_S.
    ENDIF.
    PERFORM REFRESH_ALV USING GO_GRID.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_BP_CHECK_RULE_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM CHANGE_BP_CHECK_RULE_PROC  CHANGING PS_LIST LIKE GT_LIST.
  DATA: IO_FACADE       TYPE REF TO CL_UKM_FACADE,
        IO_PARTNER      TYPE REF TO CL_UKM_BUSINESS_PARTNER,
        IO_BUPA_FACTORY TYPE REF TO CL_UKM_BUPA_FACTORY,
        IO_ACCOUNT      TYPE REF TO CL_UKM_ACCOUNT.

  DATA: LS_BP_CREDIT_SGM TYPE UKM_S_BP_CMS_SGM,
        LS_UKM_S_BP_CMS  TYPE UKM_S_BP_CMS,
        LT_BP1012        TYPE UKM_T_BP1012,
        LV_GRADE         TYPE BP_GRADE,
        LS_NEW_SCORE     TYPE BAPI_STR_BUPA_FS_RATING,
        LS_OLD_SCORE     TYPE BAPI_STR_BUPA_FS_RATING,
        LT_ADD_INFO      TYPE UKM_TS_ADD_INFO,
        LS_ADD_INFO      TYPE UKM_S_ADD_INFO.

  DATA: LS_BUPA_ERROR TYPE MDS_CTRLS_ERROR.

  DATA: LV_PARTNER      TYPE BU_PARTNER,
        LV_CREDIT_SGMNT TYPE UKM_CREDIT_SGMNT,
        LV_CREDIT_GROUP TYPE UKM_CRED_GROUP,
        LV_CREDIT_LIMIT TYPE UKM_S_BP_CMS_SGM-CREDIT_LIMIT.

  DATA: LV_AMT  TYPE UKM_AMOUNT,
        LV_DATE TYPE SY-DATUM.

  DATA: LT_RETURN   TYPE UKM_T_MONITOR_RETURN,
        LT_RET2     TYPE TABLE OF BAPIRET2,
        LS_BAPIRET2 TYPE BAPIRET2.

  DATA: LV_CMS_CHK(1),
        LV_SGM_CHK(1).

  DATA: LV_MSG(100).

  LV_PARTNER = PS_LIST-PARTNER.

*-------------------------------------------------------
*-01. 현재 CHECK_RULE
*-------------------------------------------------------
  SELECT SINGLE CHECK_RULE
    FROM UKMBP_CMS
   WHERE PARTNER EQ @LV_PARTNER
    INTO @DATA(LV_CHECK_RULE).
  IF SY-SUBRC EQ 0.
    IF LV_CHECK_RULE EQ PS_LIST-CHECK_RULE_N.
      PS_LIST-RSLT    = GC_S.
      EXIT.
    ENDIF.
  ELSE.
    PS_LIST-RSLT    = GC_E.
    PS_LIST-MESSAGE = TEXT-M03.
    EXIT.
  ENDIF.

*-------------------------------------------------------
*-02. CREDIT ROLE
*-------------------------------------------------------
  SELECT SINGLE PARTNER
    FROM BUT100
   WHERE PARTNER EQ @LV_PARTNER
     AND RLTYP   EQ 'UKM000'
    INTO @DATA(LV_PART).
  IF SY-SUBRC NE 0.
    CALL FUNCTION 'BAPI_BUPA_ROLE_ADD_2'
      EXPORTING
        BUSINESSPARTNER             = LV_PARTNER
        BUSINESSPARTNERROLECATEGORY = 'UKM000'
        BUSINESSPARTNERROLE         = 'UKM000'
      TABLES
        RETURN                      = LT_RET2.
    LOOP AT LT_RET2 INTO DATA(LS_RET2) WHERE TYPE CA 'AE'.
      EXIT.
    ENDLOOP.
    IF SY-SUBRC EQ 0.
      __BAPI_TRANSACTION_ROLLBACK.

      PS_LIST-RSLT = GC_E.
      LOOP AT LT_RET2 INTO LS_RET2 WHERE TYPE CA 'AE'.
        CLEAR:LV_MSG.
        CALL FUNCTION 'MESSAGE_TEXT_BUILD'
          EXPORTING
            MSGID               = LS_RET2-ID
            MSGNR               = LS_RET2-NUMBER
            MSGV1               = LS_RET2-MESSAGE_V1
            MSGV2               = LS_RET2-MESSAGE_V2
            MSGV3               = LS_RET2-MESSAGE_V3
            MSGV4               = LS_RET2-MESSAGE_V4
          IMPORTING
            MESSAGE_TEXT_OUTPUT = LV_MSG.
        IF PS_LIST-MESSAGE IS NOT INITIAL.
          PS_LIST-MESSAGE = |{ PS_LIST-MESSAGE }/{ LV_MSG }|.
        ELSE.
          PS_LIST-MESSAGE = LV_MSG.
        ENDIF.
      ENDLOOP.
      EXIT.
    ENDIF.

    __BAPI_TRANSACTION_COMMIT.
    WAIT UP TO '0.5' SECONDS.
  ENDIF.

*-------------------------------------------------------
*-03."BP LOCK 체크
*-------------------------------------------------------
  DATA(LO_BUPA) = NEW CL_IM_MDS_BUPA_LOCK( ).

  CALL METHOD LO_BUPA->IF_EX_BUPA_LOCK~LOCK
    EXPORTING
      IV_PARTNER = LV_PARTNER
    CHANGING
      CS_ERROR   = LS_BUPA_ERROR.

  IF LS_BUPA_ERROR-IS_ERROR IS NOT INITIAL.
    PS_LIST-RSLT = GC_E.
    DATA(LS_MSG) = VALUE #( LS_BUPA_ERROR-MESSAGES[ TYPE   = GC_E
                                                    ID     = 'MC'
                                                    NUMBER = '601' ] OPTIONAL ).
    IF LS_MSG IS NOT INITIAL.
      PS_LIST-MESSAGE = LS_MSG-MESSAGE.
    ELSE.
      LOOP AT LS_BUPA_ERROR-MESSAGES INTO LS_MSG WHERE TYPE EQ GC_E.
        IF PS_LIST-MESSAGE IS INITIAL.
          PS_LIST-MESSAGE = LS_MSG-MESSAGE.
        ELSE.
          PS_LIST-MESSAGE = |{ PS_LIST-MESSAGE }/{ LS_MSG-MESSAGE }|.
        ENDIF.
      ENDLOOP.
    ENDIF.
    EXIT.
  ENDIF.

  IO_FACADE       = CL_UKM_FACADE=>CREATE( I_ACTIVITY = CL_UKM_CNST_EVENTING=>BP_MAINTENANCE ).
  IO_BUPA_FACTORY = IO_FACADE->GET_BUPA_FACTORY( ).
  IO_PARTNER      = IO_BUPA_FACTORY->GET_BUSINESS_PARTNER( LV_PARTNER ).

*-------------------------------------------------------
*-04. CREDIT PROFILE
*-------------------------------------------------------
*-일반정보 유지보수
  IO_PARTNER->GET_BP_CMS( IMPORTING ES_BP_CMS = LS_UKM_S_BP_CMS ).
  IF LS_UKM_S_BP_CMS-CHECK_RULE NE PS_LIST-CHECK_RULE_N.
    LV_CMS_CHK = GC_X.
    LS_UKM_S_BP_CMS-CHECK_RULE = PS_LIST-CHECK_RULE_N.
  ENDIF.

  IF LV_CMS_CHK = GC_X.
    IO_PARTNER->SET_BP_CMS( LS_UKM_S_BP_CMS ).
  ENDIF.

*-------------------------------------------------------
*-05. SAVE
*-------------------------------------------------------
  IF LV_CMS_CHK IS INITIAL.
    PS_LIST-RSLT    = GC_S.
    PS_LIST-MESSAGE = TEXT-M04.

  ELSE.
    CALL METHOD IO_BUPA_FACTORY->SAVE_ALL
      EXPORTING
        I_UPD_TASK = ABAP_FALSE
*       I_FREE_ALL = NO
*       I_WITH_EXTERNAL_SCORINGS = NO
*       I_WITH_ADD_INFOS = ABAP_TRUE
*       I_WITH_VECTORS   = NO
*       I_WITH_ENQUEUE   = NO
*       I_FROM_HCP = NO
*       I_TESTRUN  = NO
      RECEIVING
        ET_RETURN  = LT_RETURN
      EXCEPTIONS
        FAILED     = 1
        OTHERS     = 2.
    IF LINE_EXISTS( LT_RETURN[ MSGTY = 'E' ] ).
      __BAPI_TRANSACTION_ROLLBACK.

      PS_LIST-RSLT    = GC_E.
      PS_LIST-MESSAGE = TEXT-M05.
      LOOP AT LT_RETURN INTO DATA(LS_RETURN) WHERE MSGTY EQ GC_E.
        PS_LIST-MESSAGE = |{ PS_LIST-MESSAGE }/{ LS_RETURN-MESSAGE }|.
      ENDLOOP.

    ELSE.
      __BAPI_TRANSACTION_COMMIT.

      PS_LIST-RSLT    = GC_S.
      PS_LIST-MESSAGE = TEXT-S01.

    ENDIF.

  ENDIF.

  IO_BUPA_FACTORY->REFRESH_PREREAD_BUFFER( ).

  CALL METHOD LO_BUPA->IF_EX_BUPA_LOCK~UNLOCK
    EXPORTING
      IV_PARTNER = LV_PARTNER
    CHANGING
      CS_ERROR   = LS_BUPA_ERROR.

  IO_BUPA_FACTORY->FREE_ALL( ).

ENDFORM.
