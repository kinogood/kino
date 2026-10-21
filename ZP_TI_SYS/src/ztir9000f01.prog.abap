************************************************************************
* Title         :  ZTIR9000F01                                         *
*                                                                      *
* Description   : 수입 제비용 관리 Subroutine Include                  *
*                                                                      *
* Creation Date : 2004/02/22                                           *
*                                                                      *
* Author        : Seog bong, Kang                                      *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
*2014.09.05       조성익          43275: 수입비용배부 손익센터 추가
*                                                                      *
*                                                                      *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Modify history
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  p3000_set_data_of_screen
*&---------------------------------------------------------------------*
FORM P3000_SET_DATA_OF_SCREEN .

  IF SY-TCODE EQ C_CREATE OR
     SY-TCODE EQ C_CREATE_D.

    REFRESH: IT_TAB.

    CLEAR: ZTITCSK,
          *ZTITCSK,
           ZTITCSP,
           IT_TAB,
           IT_ZTISCSHS,
           IT_ZTISCSDT,
           XZTITCSP,
           YZTITCSP,
           J_1BBRANCH,
           TGSBT,
           LFA1,
          *LFA1,
           W_LFA1,
           W_LFA1_BANK,
           ZTSTIGP,
           T001,
           T005,
           T024,
           T024E.

    CLEAR:  GT_CONTROL-TEXTLINES[], GT_CONTROL-TEXTTYPES[].
  ELSE.
*> 변경 문서 관리를 위한 이전데이타를 Move.
    ZTITCSK-ICSNO   = *ZTITCSK-ICSNO.
  ENDIF.

*> Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

ENDFORM.                    " p3000_set_data_of_screen
*&---------------------------------------------------------------------*
*&      Form  check_for_sub_document_exist
*&---------------------------------------------------------------------*
*  삭제시 후속 문서의 존재여부를 확인함..
*----------------------------------------------------------------------*
FORM CHECK_FOR_SUB_DOCUMENT_EXIST.

*  LOOP AT it_tab INTO g_tc_2130_wa.
*    PERFORM check_bl_sub_document_exist
*                             USING   g_tc_2130_wa-iblno
*                                     g_tc_2130_wa-iblit
*                                     c_error
*                                     g_subrc.
*  ENDLOOP.
*
ENDFORM.                    " check_for_sub_document_exist


*&---------------------------------------------------------------------*
*&      Form  check_for_document_field
*&---------------------------------------------------------------------*
*  필드들의 오류 값들을 체크하여 공통 nternal table에 저장함.
*----------------------------------------------------------------------*
FORM CHECK_FOR_DOCUMENT_FIELD USING P_MODE.

  DATA: L_IF_NULL    TYPE REF TO IF_MESSAGE_OBJ_MM.
  DATA: LT_EVENTS TYPE        MMPUR_EVENTS,
        L_HANDLE  TYPE REF TO CL_HANDLE_MM,
        L_MSG     TYPE REF TO CL_MESSAGE_MM.

  DATA: BEGIN OF LT_CSCTY OCCURS 1,
          CSCTY TYPE ZTICSCTY,
        END   OF LT_CSCTY.

  FIELD-SYMBOLS: <EVENT> LIKE LINE OF LT_EVENTS.
*
* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

  REFRESH : LT_CSCTY.

  LOOP AT IT_TAB INTO G_TC_2130_WA.
    LT_CSCTY-CSCTY = G_TC_2130_WA-CSCTY.
*    IF lt_cscty-cscty NE c_charv.
    IF LT_CSCTY-CSCTY EQ C_CHARU.
      LT_CSCTY-CSCTY = C_CHARP.
    ENDIF.
    COLLECT LT_CSCTY.
*    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE LT_CSCTY LINES G_LINE.
  IF G_LINE EQ 1.
    READ TABLE LT_CSCTY INDEX 1.
    IF SY-SUBRC EQ 0.
      IF LT_CSCTY-CSCTY EQ C_CHARF.
        ZTITCSK-PTDCL = C_CHARF.
      ELSEIF LT_CSCTY-CSCTY EQ C_CHARV.
        ZTITCSK-PTDCL = C_CHARV.
      ELSE.
        ZTITCSK-PTDCL = C_CHARM.
      ENDIF.
    ENDIF.
  ELSEIF G_LINE EQ 0.
    ZTITCSK-PTDCL = C_CHARF.
  ELSE.
    MESSAGE S881.
    PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    CLEAR ZTITCSK-PTDCL.
  ENDIF.

*  IF ZTITRQS-zterm IS INITIAL.
*    PERFORM set_return_message USING 'ZTITRQS' 'ZTERM' c_error.
*  ENDIF.
*
*ZTISCSIT-CSCTY

*> 일회성 계정.
  IF NOT ZTITCSK-XCPDK IS INITIAL.
    CLEAR : OK-CODE.
    IF ZTITCSO IS INITIAL.
      PERFORM SET_ONE_TIME_VENDER_DATA.
      IF OK-CODE NE 'ZTIOKAY'.
        MESSAGE S900.
      ENDIF.
    ENDIF.
    IF ZTITCSO IS INITIAL.
      MESSAGE S266(F5).
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.
  ELSE.
    CLEAR: ZTITCSO.
  ENDIF.

**> 참조사항 체크.
*  IF ztitcsk-xblnr IS INITIAL.
*    PERFORM set_return_message USING 'ZTITCSK' 'XBLNR' c_error.
*  ENDIF.
*
*> 전기 항목 체크.
  DESCRIBE TABLE IT_TAB LINES G_LINE.
  IF G_LINE EQ 0.
    MESSAGE S877.
    PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
  ENDIF.
*> 전기비용체크.
  IF ZTITCSK-WRBTR IS INITIAL.
    MESSAGE S864.
    PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
  ENDIF.

*> 오류정보가 존재시 메시지 상자 POPUP.
  G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                        IM_BUSINESS_OBJ          = L_IF_NULL
                        IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

  IF G_LINE GT 0.
    IF SY-CALLD EQ C_TRUE.
*> List of Events
      CALL METHOD G_MESSAGE_HANDLER->GETLIST
        EXPORTING
          IM_OBJECT = L_HANDLE
        IMPORTING
          EX_EVNT   = LT_EVENTS.

      CLEAR: G_CNT.
      LOOP AT LT_EVENTS ASSIGNING <EVENT>.
        MMPUR_DYNAMIC_CAST L_MSG <EVENT>-EVENT.
        CHECK NOT L_MSG    IS INITIAL.
        CHECK L_MSG->MSGTY EQ C_ERROR.
        MESSAGE ID     L_MSG->MSGID
                TYPE   L_MSG->MSGTY
                NUMBER L_MSG->MSGNO
                WITH   L_MSG->MSGV1
                       L_MSG->MSGV2
                       L_MSG->MSGV3
                       L_MSG->MSGV4.
        EXIT.
      ENDLOOP.
      IF SY-SUBRC NE 0.
        LOOP AT LT_EVENTS ASSIGNING <EVENT>.
          MMPUR_DYNAMIC_CAST L_MSG <EVENT>-EVENT.
          CHECK NOT L_MSG    IS INITIAL.
          MESSAGE ID     L_MSG->MSGID
                  TYPE   L_MSG->MSGTY
                  NUMBER L_MSG->MSGNO
                  WITH   L_MSG->MSGV1
                         L_MSG->MSGV2
                         L_MSG->MSGV3
                         L_MSG->MSGV4.
          EXIT.
        ENDLOOP.
      ENDIF.
    ELSE.
      CALL METHOD G_MESSAGE_HANDLER->SHOW(
          IM_POPUP  = C_TRUE
          IM_AMODAL = C_FALSE ).
    ENDIF.
  ENDIF.

ENDFORM.                    " check_for_document_field
*&---------------------------------------------------------------------*
*&      Form  p8000_save_master_data
*&---------------------------------------------------------------------*
FORM P8000_SAVE_MASTER_DATA USING P_MODE.

*> 공통테이블 적용.
  IF G_MODE      EQ C_CHARY AND
     OK_CODE_OLD EQ 'ZTISAVE'.
    P_MODE = 'Y'.
  ENDIF.

  PERFORM P8100_SAVE_COMMON_DATA  TABLES IT_TAB
                                  USING  ZTITCSK
                                         G_SUBRC
                                         P_MODE.
  IF G_SUBRC NE C_ZERO.
    MESSAGE A912.   EXIT.
  ENDIF.

*> Long Text 저장 루틴.
  PERFORM SAVE_LONG_TEXT USING ZTITCSK+3(14)
                               C_TEXTOBJECT_HEADER
                               G_SUBRC.

  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    MESSAGE A912.   EXIT.
  ENDIF.

*> Change document setting.
  PERFORM P8120_CHANGE_DOCUMENT.

*> Set parameter ID
  IF OK_CODE_OLD EQ 'ZTIDELETE'.
    MESSAGE S111 WITH ZTITCSK-BUKRS ZTITCSK-ICSNO.
  ELSE.
    SET PARAMETER ID 'ZTIICSNO' FIELD ZTITCSK-ICSNO.
    SET PARAMETER ID 'BUK'      FIELD ZTITCSK-BUKRS.
    MESSAGE S105 WITH ZTITCSK-BUKRS ZTITCSK-ICSNO.
    MOVE-CORRESPONDING ZTITCSK TO *ZTITCSK.
    EXPORT *ZTITCSK TO MEMORY ID 'ZTIR9000'.
  ENDIF.
*> Commit work.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
  COMMIT WORK.

ENDFORM.                    " p8000_save_master_data
**&---------------------------------------------------------------------
*
**&      Form  p8100_save_common_data
**&---------------------------------------------------------------------
*
FORM P8100_SAVE_COMMON_DATA  TABLES  PT_TAB     STRUCTURE G_TC_2130_WA
                             USING   P_ZTITCSK STRUCTURE ZTITCSK
                                     P_SUBRC    LIKE      SY-SUBRC
                                     P_MODE.

  DATA: L_LCONO TYPE ZTIREQNO.
  TABLES: ZTSTFBC.

  RANGES: LR_TAXNO FOR ZTITTXK-TAXNO OCCURS 1.

  CLEAR: P_SUBRC, L_LCONO.

  IF SY-TCODE EQ C_CREATE OR  SY-TCODE EQ C_CREATE_D.

    CALL FUNCTION 'Z_TI_GET_NUMBER_NEXT'
      EXPORTING
        ZMPTY    = G_DOCUMENT
        BUKRS    = P_ZTITCSK-BUKRS
      IMPORTING
        LCONO    = L_LCONO
      EXCEPTIONS
        NOT_TYPE = 1
        OTHERS   = 2.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
    L_LCONO = P_ZTITCSK-ICSNO.
  ENDIF.

  IF  P_ZTITCSK-CNAM IS INITIAL.
    MOVE: SY-UNAME   TO   P_ZTITCSK-CNAM,
          SY-DATLO   TO   P_ZTITCSK-CDAT,
          SY-TIMLO   TO   P_ZTITCSK-CTME.
  ENDIF.

  MOVE: SY-MANDT         TO   P_ZTITCSK-MANDT,
        L_LCONO          TO   P_ZTITCSK-ICSNO,
        SY-MANDT         TO   ZTITCSO-MANDT,
        L_LCONO          TO   ZTITCSO-ICSNO,
        P_ZTITCSK-ICSNO TO   ZTITCSO-BUKRS,
        SY-UNAME         TO   P_ZTITCSK-UNAM,
        SY-DATLO         TO   P_ZTITCSK-UDAT,
        SY-TIMLO         TO   P_ZTITCSK-UTME.
*> 전기시.
  IF P_MODE EQ 'H'.
    MOVE: INVOICEDOCNUMBER TO P_ZTITCSK-BELNR,
          C_CHARP          TO P_ZTITCSK-LIVST.
  ELSEIF P_MODE EQ 'R'.
    MOVE: SPACE            TO P_ZTITCSK-BELNR,
          C_CHARN          TO P_ZTITCSK-LIVST.
  ENDIF.



  IF OK_CODE_OLD EQ 'ZTIDELETE'.
*> C20130115_53137 START
*> FINBIL연계건에 대한 처리
    SELECT SINGLE * FROM ZTSTFBC
     WHERE BUKRS EQ P_ZTITCSK-BUKRS
       AND ICSNO EQ P_ZTITCSK-ICSNO
       AND SYSYN EQ 'Y'.

    IF SY-SUBRC EQ 0.
      UPDATE ZTSTFBC
         SET : SYSYN = 'N'
               BELNR = SPACE
               ICSNO = SPACE
       WHERE BUKRS EQ P_ZTITCSK-BUKRS
         AND ICSNO EQ P_ZTITCSK-ICSNO
         AND SYSYN EQ 'Y'.
    ENDIF.
*> C20130115_53137 END

*> Header table delete.
    DELETE FROM ZTITCSK
     WHERE BUKRS EQ P_ZTITCSK-BUKRS
       AND ICSNO EQ P_ZTITCSK-ICSNO.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
    ENDIF.
*> Item table delete
    DELETE FROM ZTITCSP
     WHERE BUKRS EQ P_ZTITCSK-BUKRS
       AND ICSNO EQ P_ZTITCSK-ICSNO.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
    ENDIF.
*> 배부내역 table delete
    DELETE FROM ZTITCSD
     WHERE BUKRS EQ P_ZTITCSK-BUKRS
       AND ICSNO EQ P_ZTITCSK-ICSNO.
*> 이력 table delete
    DELETE FROM ZTITCSH
     WHERE BUKRS EQ P_ZTITCSK-BUKRS
       AND ICSNO EQ P_ZTITCSK-ICSNO.
*> 일회성계정 delete
    DELETE FROM ZTITCSO
     WHERE BUKRS EQ P_ZTITCSK-BUKRS
       AND ICSNO EQ P_ZTITCSK-ICSNO.

    EXIT.
  ELSE.
*> Header table modify.
    MODIFY ZTITCSK FROM P_ZTITCSK.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
    ENDIF.

    IF NOT P_ZTITCSK-XCPDK IS INITIAL.
      MODIFY ZTITCSO.
      IF SY-SUBRC NE 0.
        ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
      ENDIF.
    ENDIF.

*> Items table modify.
    DELETE FROM ZTITCSP
     WHERE BUKRS EQ P_ZTITCSK-BUKRS
       AND ICSNO EQ P_ZTITCSK-ICSNO.

    REFRESH : XZTITCSP.
    LOOP AT IT_TAB INTO G_TC_2130_WA.
      MOVE-CORRESPONDING G_TC_2130_WA TO XZTITCSP.
      XZTITCSP-MANDT = P_ZTITCSK-MANDT.
      XZTITCSP-BUKRS = P_ZTITCSK-BUKRS.
      XZTITCSP-ICSNO = P_ZTITCSK-ICSNO.
      APPEND XZTITCSP.
*> 기납증일 경우.
      IF XZTITCSP-EXPGR EQ C_CHART.
        CLEAR: LR_TAXNO.
        LR_TAXNO-SIGN   = C_CHARI.
        LR_TAXNO-OPTION = 'EQ'.
        LR_TAXNO-LOW    = XZTITCSP-REFNO.
        APPEND LR_TAXNO.
      ENDIF.
    ENDLOOP.

    MODIFY ZTITCSP FROM TABLE XZTITCSP.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
    ENDIF.

*> 배부내역 table modify.
    DELETE FROM ZTITCSD
     WHERE BUKRS EQ P_ZTITCSK-BUKRS
       AND ICSNO EQ P_ZTITCSK-ICSNO.

*    REFRESH : it_ZTIscsdt.
    CLEAR G_COUNT.
    LOOP AT IT_ZTISCSDT.
      ADD 1 TO G_COUNT.
      IT_ZTISCSDT-MANDT = P_ZTITCSK-MANDT.
      IT_ZTISCSDT-BUKRS = P_ZTITCSK-BUKRS.
      IT_ZTISCSDT-ICSNO = P_ZTITCSK-ICSNO.
      IT_ZTISCSDT-BUZEI = G_COUNT.

*** START_43275 수입비용배부 테이블(ZTITCSD) 손익센터 반영 로직 추가
*** 단순 정보값을 채워주는 것이기 때문에 마지막에 처리(기표로직 변함X)
      IF IT_ZTISCSDT-PRCTR IS INITIAL AND
         IT_ZTISCSDT-MATNR IS NOT INITIAL.
        SELECT SINGLE PRCTR
          INTO IT_ZTISCSDT-PRCTR
          FROM MARC
         WHERE MATNR = IT_ZTISCSDT-MATNR
           AND WERKS = IT_ZTISCSDT-WERKS.
      ENDIF.
*** END_43275 수입비용배부 테이블(ZTITCSD) 손익센터 반영 로직 추
      MODIFY IT_ZTISCSDT.
    ENDLOOP.
    IF G_COUNT GT 0.
      MODIFY ZTITCSD FROM TABLE IT_ZTISCSDT.
      IF SY-SUBRC NE 0.
        ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
      ENDIF.
    ENDIF.

*> 전기이력 table modify.
    IF P_MODE EQ 'H'.
      CLEAR: ZTITCSH.
      SELECT MAX( IVSEQ )
        INTO ZTITCSH-IVSEQ
        FROM ZTITCSH
       WHERE BUKRS    EQ   P_ZTITCSK-BUKRS
         AND ICSNO    EQ   P_ZTITCSK-ICSNO.
      ADD 1 TO  ZTITCSH-IVSEQ.

      MOVE : SY-MANDT            TO     ZTITCSH-MANDT,
             P_ZTITCSK-BUKRS     TO     ZTITCSH-BUKRS,
             P_ZTITCSK-BLDAT     TO     ZTITCSH-BUDAT,
             P_ZTITCSK-BUDAT     TO     ZTITCSH-BLDAT,
             P_ZTITCSK-ICSNO     TO     ZTITCSH-ICSNO,
             P_ZTITCSK-WAERS     TO     ZTITCSH-WAERS,
             P_ZTITCSK-WRBTR     TO     ZTITCSH-WRBTR,
             P_ZTITCSK-DMBTR     TO     ZTITCSH-DMBTR,
             P_ZTITCSK-VORGANG   TO     ZTITCSH-VORGANG,
             SY-UNAME            TO     ZTITCSH-CNAM,
             SY-DATLO            TO     ZTITCSH-CDAT,
             SY-TIMLO            TO     ZTITCSH-CTME,
             'S'                 TO     ZTITCSH-SHKZG,
             FISCALYEAR          TO     ZTITCSH-GJAHR,
             INVOICEDOCNUMBER    TO     ZTITCSH-BELNR.
      INSERT ZTITCSH.
      IF SY-SUBRC NE 0.
        ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
      ENDIF.
*> 기납증일 경우.
      IF P_ZTITCSK-EXPGR EQ C_CHART.
        UPDATE ZTITTXK
               SET: POSTS = C_CHARY
                    BELNR = INVOICEDOCNUMBER
                    GJAHR = FISCALYEAR
              WHERE TAXNO IN LR_TAXNO.
        IF SY-SUBRC NE 0.
          ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
        ENDIF.
      ENDIF.
*> 전기 취소.
    ELSEIF P_MODE EQ 'R'.
      CLEAR: ZTITCSH.
      SELECT MAX( IVSEQ )
        INTO ZTITCSH-IVSEQ
        FROM ZTITCSH
       WHERE BUKRS    EQ   P_ZTITCSK-BUKRS
         AND ICSNO    EQ   P_ZTITCSK-ICSNO.

      SELECT SINGLE *
        FROM ZTITCSH
       WHERE BUKRS    EQ   P_ZTITCSK-BUKRS
         AND ICSNO    EQ   P_ZTITCSK-ICSNO
         AND IVSEQ    EQ   ZTITCSH-IVSEQ.
      IF SY-SUBRC EQ 0.
        MOVE: ZTISSCRCOM-STGRD          TO ZTITCSH-STGRD,
              ZTISSCRCOM-CBUDAT         TO ZTITCSH-CBUDAT,
              FISCALYEAR_REVERSAL       TO ZTITCSH-CGJAHR,
              INVOICEDOCNUMBER_REVERSAL TO ZTITCSH-CBELNR,
              SY-UNAME                  TO ZTITCSH-UNAM,
              SY-DATLO                  TO ZTITCSH-UDAT,
              SY-TIMLO                  TO ZTITCSH-UTME.
        MODIFY ZTITCSH.
        IF SY-SUBRC NE 0.
          ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
        ENDIF.
      ENDIF.
*> 기납증일 경우.
      IF P_ZTITCSK-EXPGR EQ C_CHART.
        UPDATE ZTITTXK
               SET: POSTS = C_CHARN
                    BELNR = SPACE
                    GJAHR = SPACE
              WHERE TAXNO IN LR_TAXNO.
        IF SY-SUBRC NE 0.
          ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " p8100_save_common_data
*&---------------------------------------------------------------------*
*&      Form  call_smartforms_functioins
*&---------------------------------------------------------------------*
FORM CALL_SMARTFORMS_FUNCTIOINS USING P_FUNC_MOD_NAME.

  CALL FUNCTION P_FUNC_MOD_NAME
    EXPORTING
*     ARCHIVE_INDEX        =
*     ARCHIVE_INDEX_TAB    =
*     ARCHIVE_PARAMETERS   =
*     MAIL_APPL_OBJ        = MAIL_APPL_OBJ
*     MAIL_RECIPIENT       = MAIL_RECIPIENT
*     MAIL_SENDER          = MAIL_SENDER
      USER_SETTINGS        = SPACE
      CONTROL_PARAMETERS   = G_CONTROL_PARAMETERS
      OUTPUT_OPTIONS       = G_OUTPUT_OPTIONS
*     LFA1                 = LFA1
*     SUMMARY              = ZMMKR_RTC_ERS_LIST
*     SDATE                = GW_SDATE
*     TITLE                = TEXT-T01
*     TITLE                = 'ERS LIST'
    IMPORTING
      DOCUMENT_OUTPUT_INFO = G_DOCUMENT_OUTPUT_INFO
      JOB_OUTPUT_INFO      = G_JOB_OUTPUT_INFO
      JOB_OUTPUT_OPTIONS   = G_JOB_OUTPUT_OPTIONS
*       TABLES
*     I_ITEM               = XITAB
*     SUBTOTAL             = SITAB
    EXCEPTIONS
      FORMATTING_ERROR     = 1
      INTERNAL_ERROR       = 2
      SEND_ERROR           = 3
      USER_CANCELED        = 4.

  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " call_smartforms_functioins
*&---------------------------------------------------------------------*
*&      Form  GET_OTHERS_TEXT_BY_MASTER_DATA
*&---------------------------------------------------------------------*
*       화면상의 Text를 Master Data 등에서 Read.
*----------------------------------------------------------------------*
FORM GET_OTHERS_TEXT_BY_MASTER_DATA .

  IF ZTITCSK-BUKRS IS INITIAL.
    CLEAR: T001.
  ELSE.
    SELECT SINGLE * FROM T001
     WHERE BUKRS EQ ZTITCSK-BUKRS.
    IF SY-SUBRC EQ 0.
      SELECT SINGLE *
        FROM T005
       WHERE LAND1 EQ T001-LAND1.
    ENDIF.
  ENDIF.

  SELECT SINGLE *
    FROM ZTITIG00
   WHERE BUKRS EQ T001-BUKRS.
  IF SY-SUBRC NE 0.
    MESSAGE E035 WITH T001-WAERS.
  ENDIF.

*> Get Vendor master
  PERFORM  GET_IMPORT_VENDORS_TEXT  USING C_SUCCESS.

ENDFORM.                    " GET_OTHERS_TEXT_BY_MASTER_DATA

*&---------------------------------------------------------------------*
*&      Form  p8120_change_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM P8120_CHANGE_DOCUMENT .

  DATA: L_OBJECTID        TYPE CDHDR-OBJECTID,
        L_TCODE           TYPE CDHDR-TCODE,
        L_UTIME           TYPE CDHDR-UTIME,
        L_UDATE           TYPE CDHDR-UDATE,
        L_USERNAME        TYPE CDHDR-USERNAME,
        L_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND,
        L_UPD_ICDTXT      TYPE CHAR1,
        L_UPD             TYPE CHAR1,
*        l_upd                   TYPE char1,
        LT_CDTXT          TYPE STANDARD TABLE OF CDTXT
                                     INITIAL SIZE 0.

  CASE SY-TCODE.
    WHEN C_CREATE OR C_CREATE_D.
      L_CDOC_UPD_OBJECT = 'I'.
      L_UPD_ICDTXT      = ' '.
      L_UPD             = ' '.
*      l_upd_eban        = ' '.
*      l_upd_ebkn        = ' '.
    WHEN OTHERS.
      L_CDOC_UPD_OBJECT = 'U'.
      L_UPD_ICDTXT      = 'U'.
      L_UPD             = 'U'.
*      l_upd_eban        = 'U'.
*      l_upd_ebkn        = 'U'.
  ENDCASE.

  IF OK_CODE_OLD EQ 'ZTIDELETE'.
    L_CDOC_UPD_OBJECT = 'D'.
    L_UPD_ICDTXT      = 'D'.
    L_UPD             = 'D'.
*    l_upd_eban        = 'D'.
*    l_upd_ebkn        = 'D'.
  ENDIF.

  L_OBJECTID(14) = ZTITCSK+3(14).

  L_TCODE        = SY-TCODE.
  L_UTIME        = SY-TIMLO.
  L_UDATE        = SY-DATLO.
  L_USERNAME     = SY-UNAME.

  IF G_MODE EQ C_CHARC.  ">생성모드일 경우.
    REFRESH : YZTITCSP.
  ENDIF.

  LOOP AT XZTITCSP.
    XZTITCSP-KZ = L_UPD.
    MODIFY XZTITCSP.
  ENDLOOP.

  CALL FUNCTION 'ZTICSCHDOC_WRITE_DOCUMENT'
    EXPORTING
      OBJECTID                = L_OBJECTID
      TCODE                   = L_TCODE
      UTIME                   = L_UTIME
      UDATE                   = L_UDATE
      USERNAME                = L_USERNAME
*     PLANNED_CHANGE_NUMBER   = ' '
      OBJECT_CHANGE_INDICATOR = L_CDOC_UPD_OBJECT
*     PLANNED_OR_REAL_CHANGES = ' '
*     NO_CHANGE_POINTERS      = ' '
*     UPD_ICDTXT_ZTIIVCHDOC   = ' '
      N_ZTITCSK               = ZTITCSK
      O_ZTITCSK               = *ZTITCSK
      N_ZTITCSO               = ZTITCSO
      O_ZTITCSO               = *ZTITCSO
      UPD_ZTITCSK             = L_UPD
      UPD_ZTITCSO             = L_UPD
      UPD_ZTITCSP             = L_UPD
    TABLES
      ICDTXT_ZTICSCHDOC       = LT_CDTXT
      XZTITCSP                = XZTITCSP
      YZTITCSP                = YZTITCSP.

ENDFORM.                    " p8120_change_document
*&---------------------------------------------------------------------*
*&      Form  call_print_process
*&---------------------------------------------------------------------*
FORM CALL_PRINT_PROCESS .

*> GET OUTPUT OPTIONS
  IF IT_PRTCTL[] IS INITIAL.
    REFRESH : IT_PRTCTL.
    CLEAR: IT_PRTCTL.
*    IF NOT ZTITRQK-opnbk IS INITIAL.   ">Openning bank.
*      SELECT lifnr name1 land1 spras telfx adrnr
*      INTO CORRESPONDING FIELDS OF TABLE it_prtctl
*      FROM lfa1
*      WHERE lifnr IN ( SELECT lifnr
*                       FROM ztstigp
*                       WHERE epart EQ ZTITRQK-opnbk ).
*    ENDIF.
*    DESCRIBE TABLE it_prtctl LINES g_line.
*    IF g_line EQ c_zero.
*      CLEAR: it_prtctl.
*      MOVE: t001-land1    TO    it_prtctl-land1,
*            sy-langu      TO    it_prtctl-spras.
*      APPEND it_prtctl.
*    ENDIF.
  ENDIF.

*> Get Output Paramenters
  PERFORM GET_OUTPUT_INFORMATION TABLES IT_PRTCTL
                                 USING  G_ANSWER.
  IF G_ANSWER EQ C_Y.

    LOOP AT IT_PRTCTL WHERE FLAG EQ C_TRUE.
**> Get SMARTFORM NAME
*      PERFORM p7000_set_smart_form_name USING ZTITRQK-reqty
*                                              '00'
*                                              it_prtctl-docty
*                                              g_ssf_name.
**> GET THE SMART FORM'S FUNCTION MODULE
*      PERFORM get_smart_form_name    USING  g_ssf_name
*                                            g_func_mod_name.
*
**> Set Output Paramenters
*      PERFORM set_output_information USING it_prtctl.
**> Call SmartForms functions
*      PERFORM call_smartforms_functioins USING g_func_mod_name.
**> Call SmartForms functions
*      PERFORM exec_external_sending USING it_prtctl.
    ENDLOOP.
  ELSE.
    MESSAGE S900.
  ENDIF.

ENDFORM.                    " call_print_process
*&---------------------------------------------------------------------*
*&      Form  SET_OTHERS_FIELDS_BY_ITEMS
*&---------------------------------------------------------------------*
*       아이템의 기타 필드들을 fill
*----------------------------------------------------------------------*
FORM SET_OTHERS_FIELDS_BY_ITEMS .
  DATA: L_EINDT  LIKE EKET-EINDT.

*  LOOP AT it_tab INTO g_tc_2130_wa.
*    IF NOT g_tc_2130_wa-ebeln IS INITIAL.
*      READ TABLE it_ZTIspnit WITH KEY ebeln = g_tc_2130_wa-ebeln
*                                      ebelp = g_tc_2130_wa-ebelp.
*      IF sy-subrc EQ 0.
*        MOVE : it_ZTIspnit-werks TO g_tc_2130_wa-werks,
*               it_ZTIspnit-lgort TO g_tc_2130_wa-lgort,
*               it_ZTIspnit-matnr TO g_tc_2130_wa-matnr,
*               it_ZTIspnit-txz01 TO g_tc_2130_wa-txz01,
*               it_ZTIspnit-loekz TO g_tc_2130_wa-loekz,
*               it_ZTIspnit-elikz TO g_tc_2130_wa-elikz,
*               it_ZTIspnit-bprme TO g_tc_2130_wa-bprme,
*               it_ZTIspnit-bpumz TO g_tc_2130_wa-bpumz,
*               it_ZTIspnit-bpumn TO g_tc_2130_wa-bpumn,
*               it_ZTIspnit-umrez TO g_tc_2130_wa-umrez,
*               it_ZTIspnit-umren TO g_tc_2130_wa-umren,
*               it_ZTIspnit-netpr TO g_tc_2130_wa-netpr,
*               it_ZTIspnit-peinh TO g_tc_2130_wa-peinh,
*               it_ZTIspnit-uebto TO g_tc_2130_wa-uebto,
*               it_ZTIspnit-uebtk TO g_tc_2130_wa-uebtk,
*               it_ZTIspnit-untto TO g_tc_2130_wa-untto.
*      ENDIF.
*    ENDIF.
**> 정가 계산.
*    CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
*      EXPORTING
*        peinh = g_tc_2130_wa-peinh
*        bpumz = g_tc_2130_wa-bpumz
*        bpumn = g_tc_2130_wa-bpumn
*        menge = g_tc_2130_wa-pnmng
*        netpr = g_tc_2130_wa-netpr
*      CHANGING
*        netwr = g_tc_2130_wa-netwr.
*
**>Get 플랜트명 및 사업장코드.
*    IF NOT g_tc_2130_wa-werks IS INITIAL.
*      SELECT SINGLE name1 j_1bbranch
*        INTO (g_tc_2130_wa-name1, g_tc_2130_wa-bupla)
*        FROM t001w
*       WHERE werks  EQ  g_tc_2130_wa-werks.
*    ELSE.
*      CLEAR: g_tc_2130_wa-name1, g_tc_2130_wa-bupla.
*    ENDIF.
*
**>Get 저장위치명.
*    IF NOT g_tc_2130_wa-lgort IS INITIAL.
*      SELECT SINGLE lgobe
*        INTO (g_tc_2130_wa-lgobe)
*        FROM t001l
*       WHERE lgort  EQ  g_tc_2130_wa-lgort.
*    ELSE.
*      CLEAR g_tc_2130_wa-lgobe.
*    ENDIF.
*
**>Get 납품일.
*    CLEAR: l_eindt.
*    SELECT MIN( eindt ) INTO l_eindt
*      FROM eket
*     WHERE ebeln EQ g_tc_2130_wa-ebeln
*       AND ebelp EQ g_tc_2130_wa-ebelp.
*
*    IF l_eindt IS INITIAL.
*      CLEAR g_tc_2130_wa-eeind.
*    ELSE.
*      WRITE l_eindt TO g_tc_2130_wa-eeind.
*    ENDIF.
*    MODIFY it_tab FROM g_tc_2130_wa.
*  ENDLOOP.
*
ENDFORM.                    " SET_OTHERS_FIELDS_BY_ITEMS
*&---------------------------------------------------------------------*
*&      Form  get_Import_vendors_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_IMPORT_VENDORS_TEXT USING P_MSGTY.

  IF ZTITCSK-LIFNR IS INITIAL.
    CLEAR: LFA1.
  ELSE.
    SELECT SINGLE * FROM LFA1
     WHERE LIFNR EQ ZTITCSK-LIFNR.
    IF SY-SUBRC NE 0.
      PERFORM MESSAGE_NOT_FOUND_VENDOR USING 'ZTITCSK'
                                             'LIFNR'
                                             P_MSGTY.
    ENDIF.
  ENDIF.

  IF ZTITCSK-EMPFK IS INITIAL.
    CLEAR *LFA1.
  ELSE.
    SELECT SINGLE *
      FROM *LFA1
     WHERE LIFNR EQ ZTITCSK-EMPFK.
    IF SY-SUBRC NE 0.
      PERFORM MESSAGE_NOT_FOUND_VENDOR USING 'ZTITCSK'
                                             'EMPFK'
                                             P_MSGTY.
    ENDIF.
  ENDIF.

  IF ZTITCSK-BUPLA IS INITIAL.
    CLEAR J_1BBRANCH.
  ELSE.
    SELECT SINGLE *
      INTO J_1BBRANCH
      FROM J_1BBRANCH
     WHERE BUKRS  EQ  ZTITCSK-BUKRS
       AND BRANCH EQ  ZTITCSK-BUPLA.
  ENDIF.

  IF ZTITCSK-GSBER IS INITIAL.
    CLEAR TGSBT.
  ELSE.
    SELECT SINGLE *
      INTO TGSBT
      FROM TGSBT
     WHERE SPRAS  EQ  SY-LANGU
       AND GSBER  EQ  ZTITCSK-GSBER.
  ENDIF.
*
ENDFORM.                    " get_Import_vendors_text
*&---------------------------------------------------------------------*
*&      Form  SET_INITIAL_VALUE
*&---------------------------------------------------------------------*
FORM SET_INITIAL_VALUE .

*> 문서 종류.
  G_DOCUMENT = C_CS.

  FREE:  ITEMDATA,   TAXDATA,          WITHTAXDATA,
         RETURN,     ACCOUNTINGDATA,   VENDORITEMSPLITDATA.

  CLEAR: HEADERDATA, INVOICEDOCNUMBER, FISCALYEAR,        ADDRESSDATA,
         ITEMDATA,   TAXDATA,          WITHTAXDATA,
         RETURN,     ACCOUNTINGDATA,   VENDORITEMSPLITDATA.

  REFRESH: IT_TAB,
           XZTITCSP, YZTITCSP,
           IT_ZTISCSHS,
           IT_ZTISCSDT.

  CLEAR:   IT_TAB,
           XZTITCSP, YZTITCSP,
           ZTITCSK,    ">Notice Header
          *ZTITCSK,    ">Notice Header
           ZTITCSO,
          *ZTITCSO,
           T001,
           T005,
           TGSBT,
           J_1BBRANCH,
           LFA1,
          *LFA1,
           W_LFA1,
           W_LFA1_BANK.

  GET PARAMETER ID 'BUK' FIELD ZTISSCRCOM-BUKRS.

  IF NOT ZTISSCRCOM-BUKRS IS INITIAL.
    SELECT SINGLE *
      FROM T001
     WHERE BUKRS  EQ  ZTISSCRCOM-BUKRS.
  ENDIF.

  IF ZTISSCRCOM-BUDAT IS INITIAL.
    MOVE: SY-DATLO   TO  ZTISSCRCOM-BUDAT.  ">전기일자.
  ENDIF.
  IF ZTISSCRCOM-CSTYP IS INITIAL.
    MOVE: C_CHARP    TO  ZTISSCRCOM-CSTYP.  ">미지급금.
  ENDIF.
*  IF ztisscrcom-blart IS INITIAL.
*    MOVE: 'KR'       TO  ztisscrcom-blart.  ">전표유형.
*  ENDIF.

* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

ENDFORM.                    " SET_INITIAL_VALUE
*&---------------------------------------------------------------------*
*&      Form  double_click_event
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK_EVENT .

  CHECK G_FIELDNAME IS INITIAL.

  GET CURSOR LINE G_FINDLINE.
  IF SY-SUBRC EQ 0.
    GET CURSOR FIELD G_FIELDNAME.
    IF SY-SUBRC EQ 0.
      G_FINDSCR = SY-DYNNR.

*****************************************************************
* 20070312 simcho by 박혁세 K
* page down 후 double click시 오류 수정
*****************************************************************
      IF SY-TCODE = 'ZTIT903'.
        G_FINDLINE = TC_2130-TOP_LINE + G_FINDLINE - 1.
      ENDIF.
*****************************************************************

      READ TABLE IT_TAB INTO G_TC_2130_WA INDEX G_FINDLINE.
      IF SY-SUBRC NE 0.
        EXIT.
      ENDIF.
      CHECK OK_CODE EQ 'ZTISELECT'.   ">문서선택.

      CASE G_FIELDNAME.
*> 수입의뢰문서.
        WHEN 'ZTISCSIT-REQNO'.
          SELECT DISTINCT AMDSQ
            INTO ZTIVRQ00-AMDSQ
            FROM ZTIVRQ00
           WHERE REQNO   =   G_TC_2130_WA-REQNO.
          ENDSELECT.
          IF SY-SUBRC EQ 0.
            PERFORM DISPLAY_IMPORT_DOCUMENT USING G_TC_2130_WA-REQNO
                                                  ZTIVRQ00-AMDSQ
                                                  '00000'.
          ENDIF.
*> 적하보험부보 문서.
        WHEN 'ZTISCSIT-IIPNO' OR 'ZTISCSIT-AMDSQ'.
          PERFORM DISPLAY_IP_DOCUMENT USING G_TC_2130_WA-IIPNO
                                            G_TC_2130_WA-AMDSQ.

*> B/L 문서.
        WHEN 'ZTISCSIT-IBLNO'.
          PERFORM DISPLAY_BL_DOCUMENT USING G_TC_2130_WA-IBLNO
                                            '00000'.
*> 통관 문서.
        WHEN 'ZTISCSIT-ICCNO'.
          PERFORM DISPLAY_CC_DOCUMENT USING G_TC_2130_WA-ICCNO
                                            G_TC_2130_WA-AMDSQ.
*> 기납증문서.
        WHEN 'ZTISCSIT-TAXNO'.
          PERFORM DISPLAY_TAX_DOCUMENT USING G_TC_2130_WA-TAXNO.
        WHEN OTHERS.
          PERFORM DISPLAY_DISTRIBUTION  USING  G_TC_2130_WA-ICSSQ.
      ENDCASE.
    ENDIF.
  ELSE.
    GET CURSOR FIELD G_FIELDNAME.
    IF SY-SUBRC EQ 0.
      G_FINDSCR = SY-DYNNR.
      CHECK OK_CODE EQ 'ZTISELECT'.   ">문서선택.

      CASE G_FIELDNAME.
        WHEN 'ZTITCSK-LIFNR'.
          PERFORM DISPLAY_VENDOR_MASTER USING ZTITCSK-LIFNR
                                              SPACE.
        WHEN 'ZTITCSK-EMPFK'.
          PERFORM DISPLAY_VENDOR_MASTER USING ZTITCSK-EMPFK
                                              SPACE.
        WHEN 'ZTITCSK-BELNR' OR 'ZTITCSK-GJAHR'.
          PERFORM DISPLAY_LIV_DOCUMENT  USING ZTITCSK-BELNR
                                              ZTITCSK-GJAHR
                                              ZTITCSK-BUKRS.
      ENDCASE.
    ENDIF.
  ENDIF.

ENDFORM.                    " double_click_event
*&---------------------------------------------------------------------*
*&      Form  set_item_number_build
*&---------------------------------------------------------------------*
*       아이템 번호를 생성함.
*----------------------------------------------------------------------*
FORM SET_ITEM_NUMBER_BUILD  TABLES   P_IT_TAB   LIKE      IT_TAB
                            USING    P_ZTITCSK STRUCTURE ZTITCSK.

  DATA: L_LPONR LIKE P_ZTITCSK-LPONR.

  IF G_MODE EQ C_CHARC.
    CLEAR: L_LPONR.
    LOOP AT P_IT_TAB.
      ADD 1 TO L_LPONR.
      MOVE L_LPONR TO P_IT_TAB-ICSSQ.
      MODIFY P_IT_TAB.
    ENDLOOP.
    MOVE L_LPONR TO P_ZTITCSK-LPONR.
  ELSE.
    CLEAR: G_LINES.
    IF G_LINES GT C_ZERO.
      CLEAR: L_LPONR.
      LOOP AT P_IT_TAB.
        IF P_IT_TAB-ICSSQ IS INITIAL.
          ADD 1 TO P_ZTITCSK-LPONR.
          MOVE P_ZTITCSK-LPONR TO P_IT_TAB-ICSSQ.
        ENDIF.
        MODIFY P_IT_TAB.
      ENDLOOP.
    ELSE.
      CLEAR: L_LPONR.
      LOOP AT P_IT_TAB.
        ADD 1 TO L_LPONR.
        MOVE L_LPONR TO P_IT_TAB-ICSSQ.
        MODIFY P_IT_TAB.
      ENDLOOP.
      MOVE L_LPONR TO P_ZTITCSK-LPONR.
    ENDIF.
  ENDIF.
  CLEAR: L_LPONR.
  LOOP AT P_IT_TAB.
    IF P_IT_TAB-ICSSQ GT L_LPONR.
      MOVE P_IT_TAB-ICSSQ TO L_LPONR.
    ENDIF.
  ENDLOOP.
  MOVE L_LPONR TO P_ZTITCSK-LPONR.

ENDFORM.                    " set_item_number_build
*&---------------------------------------------------------------------*
*&      Form  set_function_by_BUSINESS
*&---------------------------------------------------------------------*
FORM SET_FUNCTION_BY_BUSINESS .

  IF ZTITCSK-LIVST NE C_CHARP.
    MOVE 'ZTIACDOC'     TO FTAB-FCODE.   APPEND FTAB. ">후속문서.
    MOVE 'ZTIMMDOC'     TO FTAB-FCODE.   APPEND FTAB. ">송장문서.
*    MOVE 'ZTIDSTR'      TO ftab-fcode.   APPEND ftab. ">원시데이타.
  ELSE.
    IF ZTITCSK-PTDCL NE C_CHARM.
      MOVE 'ZTIACDOC'     TO FTAB-FCODE.   APPEND FTAB. ">후속문서.
    ENDIF.
  ENDIF.

  IF ZTITCSK-LIVST EQ C_CHARP.
    MOVE 'ZTIDELETE'    TO FTAB-FCODE.   APPEND FTAB. ">삭제.
  ENDIF.

  IF ZTITCSK-XCPDK IS INITIAL.
    MOVE 'ZTIONTIME'    TO FTAB-FCODE.   APPEND FTAB. ">삭제.
  ENDIF.

  "[CHM2110-00555] 세금계산서 코드 추가
*  IF G_TCODE NE C_CHANGE   AND ZTITCSK-BUKRS EQ 3000 AND
*     ZTITCSK-MWSKZ NE 'V0'  AND
*     ( ZTITCSK-EXPGR EQ 'B' OR ZTITCSK-EXPGR EQ 'C') .
*    MOVE 'ZTITAX'  TO FTAB-FCODE.   APPEND FTAB. " <계산서매핑
*    MOVE 'ZTITAXC' TO FTAB-FCODE.   APPEND FTAB. " <계산서매핑취소
*  ENDIF.
*
*  IF ( SY-DYNNR  EQ C_SCR0100 OR  SY-DYNNR  EQ C_SCR0101  OR
*      SY-DYNNR  EQ C_SCR0200 ) .
*    MOVE 'ZTITAX'  TO FTAB-FCODE.   APPEND FTAB. " <계산서매핑
*    MOVE 'ZTITAXC' TO FTAB-FCODE.   APPEND FTAB. " <계산서매핑
*  ENDIF.


ENDFORM.                    " set_function_by_BUSINESS
*&---------------------------------------------------------------------*
*&      Form  check_invoice_doc_status
*&---------------------------------------------------------------------*
*       송장문서의 상태를 검증함.
*----------------------------------------------------------------------*
FORM CHECK_INVOICE_DOC_STATUS .

  DATA: L_DDTEXT LIKE G_DDTEXT.

*> Trnasaction 점검.
  IF NOT ( ZTITIVK-VORGANG EQ C_CHAR1 OR
           ZTITIVK-VORGANG EQ C_CHAR3 ).
*> 트랜잭션 종류 Fixed value read.
    PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'MRM_VORGANG'
                                               SY-LANGU
                                               ZTITIVK-VORGANG
                                               G_DDTEXT
                                               C_SUCCESS.
    L_DDTEXT = G_DDTEXT.

    MESSAGE E805 WITH L_DDTEXT.
  ENDIF.

*> 선급금 점검.
  IF ZTITIVK-PRPYN EQ C_CHARP.
*> 송장 종류 Fixed value read.
    PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIPRPYN'
                                               SY-LANGU
                                               ZTITIVK-PRPYN
                                               G_DDTEXT
                                               C_SUCCESS.
    L_DDTEXT = G_DDTEXT.
    MESSAGE E805 WITH L_DDTEXT.
  ENDIF.

*> 전기여부 점검.
  IF ZTITIVK-LIVST NE C_CHARY.
*> 전기여부 Fixed value read.
    PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTILIVST'
                                               SY-LANGU
                                               ZTITIVK-LIVST
                                               G_DDTEXT
                                               C_SUCCESS.
    L_DDTEXT = G_DDTEXT.
    MESSAGE E805 WITH L_DDTEXT.
  ENDIF.

ENDFORM.                    " check_invoice_doc_status

*&---------------------------------------------------------------------*
*&      Form  get_and_check_IV_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_AND_CHECK_IV_DATA  USING    P_IVONO
                                     P_RBLGP
                                     P_MODIFY
                                     P_ZTIVIV00 STRUCTURE ZTIVIV00
                                     P_COUNT.

  CLEAR: P_ZTIVIV00.

  SELECT SINGLE * INTO P_ZTIVIV00
    FROM ZTIVIV00
   WHERE IVONO EQ P_IVONO
     AND RBLGP EQ P_RBLGP.

  IF SY-SUBRC EQ 0.
*>수입의뢰번호 체크.
    IF P_ZTIVIV00-REQNO  NE ZTITPNK-REQNO.
      IF P_COUNT         GT C_ZERO.
        MESSAGE S806 WITH P_ZTIVIV00-REQNO ZTITPNK-REQNO.
        P_MODIFY = C_TRUE.
        EXIT.
      ELSE.
        MOVE P_ZTIVIV00-REQNO TO ZTITPNK-REQNO.
      ENDIF.
    ENDIF.
*>Get 신용장 번호.
    IF ZTITPNK-OPNNO IS INITIAL AND
       NOT ZTITPNK-REQNO IS INITIAL.
      SELECT OPNNO OPNBK
        INTO (ZTITPNK-OPNNO, ZTITPNK-NTCBK)
        FROM ZTIVRQ00 UP TO 1 ROWS
       WHERE REQNO EQ ZTITPNK-REQNO.
      ENDSELECT.
    ENDIF.
*>Get B/L 번호 .
    IF ZTITPNK-BLNUM IS INITIAL AND
       NOT ZTITPNK-IBLNO IS INITIAL.
      SELECT SINGLE BLNUM
        INTO ZTITPNK-BLNUM
        FROM ZTITBLK
       WHERE IBLNO EQ ZTITPNK-IBLNO.
    ENDIF.
*>B/L 번호 체크.
    IF P_ZTIVIV00-IBLNO  NE ZTITPNK-IBLNO.
      IF P_COUNT          GT C_ZERO.
        MESSAGE S808 WITH P_ZTIVIV00-IBLNO ZTITPNK-IBLNO.
        P_MODIFY = C_TRUE.
        EXIT.
      ELSE.
        MOVE P_ZTIVIV00-IBLNO TO ZTITPNK-IBLNO.
      ENDIF.
    ENDIF.
*> Lock Object
    PERFORM  SET_IV_LOCK_OBJECT  USING P_IVONO
                                       P_RBLGP
                                       C_LOCK
                                       C_SUCCESS
                                       P_MODIFY.
  ELSE.
    MESSAGE S019(06) WITH P_IVONO.
    P_MODIFY = C_TRUE.
    EXIT.
  ENDIF.

ENDFORM.                    " get_and_check_IV_data
*&---------------------------------------------------------------------*
*&      Form  SET_INVOICE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_INVOICE_DATA .
*> 수입비용배부 함수.
  CLEAR: G_ANSWER_DIST.
  IF IT_ZTISCSDT[] IS INITIAL.
    G_ANSWER_DIST = 'J'.
  ELSE.
    IF SY-CALLD EQ C_TRUE OR
       SY-BATCH EQ C_TRUE.
      G_ANSWER_DIST = 'J'.
    ELSE.
      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
        EXPORTING
          TEXTLINE1 = '기존에 배부된 내역이 존재합니다.'
          TEXTLINE2 = '재배부 후 전기하시겠습니까?'
          TITEL     = '배부 확인'
        IMPORTING
          ANSWER    = G_ANSWER_DIST.
    ENDIF.
  ENDIF.
  IF G_ANSWER_DIST = 'J'.
    PERFORM SET_DISTRIBUTION_EXPENCES.
  ELSEIF G_ANSWER_DIST = 'C'.
    MESSAGE S900.
    G_ANSWER = C_CHARN.
    EXIT.
  ENDIF.

*> 물류송장검증일 경우.
  IF ZTITCSK-PTDCL EQ C_CHARM.
    PERFORM FILL_LIV_INTERNAL_TABLE.
*> 회계전표 직기표일 경우.
  ELSEIF ZTITCSK-PTDCL EQ C_CHARF.
    PERFORM FILL_ACCOUNT_INTERNAL_TABLE.
*> 회계전표 부가세 기표일 경우.
  ELSEIF ZTITCSK-PTDCL EQ C_CHARV.
*    PERFORM fill_account_internal_table.
    PERFORM FILL_VAT_INTERNAL_TABLE.
  ENDIF.
  G_ANSWER = C_CHARY.

ENDFORM.                    " SET_INVOICE_DATA
*&---------------------------------------------------------------------*
*&      Form  fill_account_internal_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_ACCOUNT_INTERNAL_TABLE .

  CLEAR: GS_DOCUMENTHEADER,
         GS_CUSTOMERCPD,
         GS_FICA_HD,
         G_TYPE,
         G_KEY,
         G_SYS.

  REFRESH: IT_ACCOUNTRECEIVABLE,
           IT_ACCOUNTGL,
           IT_ACCOUNTTAX,
           IT_CRITERIA,
           IT_VALUEFIELD,
           IT_CURRENCYAMOUNT,
           IT_RETURN,
           IT_RECEIVERS,
           IT_FICA_IT,
           IT_ACCOUNTPAYABLE,
           IT_PAYMENTCARD,
           IT_EXT,
           IT_RE,
           IT_EXT2,
           IT_DOC,
           IT_APP.

  PERFORM FILL_ACCOUNT_HEADER.         ">Header
  LOOP AT IT_ZTISCSDT.
    CASE IT_ZTISCSDT-KOART.
      WHEN 'K'.   ">AP
        PERFORM FILL_ACCOUNT_ACCOUNTAP.      ">AP account
      WHEN 'S'.
        IF IT_ZTISCSDT-ITMST EQ 'V'.
          PERFORM FILL_ACCOUNT_ACCOUNTTAX.   ">Tax Code
*          PERFORM fill_account_criteria USING :
*                  it_ztIscsdT-buzei 'SGTXT' it_ztIscsdT-SGTXT.
        ELSE.
          PERFORM FILL_ACCOUNT_ACCOUNTGL.    ">GL account
        ENDIF.
*      WHEN 'S'.   ">GL
*        PERFORM fill_account_accounttax.     ">Tax Code
    ENDCASE.

*    PERFORM fill_account_accountar.      ">AR account
    PERFORM FILL_ACCOUNT_CURRENCYAMOUNT. ">Amount
  ENDLOOP.

*  PERFORM fill_account_criteria.
  PERFORM FILL_ACCOUNT_VALUEFIELD.
  PERFORM FILL_ACCOUNT_RE.
  PERFORM FILL_ACCOUNT_CPD.
  PERFORM FILL_ACCOUNT_CONTRACTITEM.
  PERFORM FILL_ACCOUNT_CONTRACTHEADER.
  PERFORM FILL_ACCOUNT_PAYMENTCARD.
  PERFORM FILL_ACCOUNT_EXTENSION.

ENDFORM.                    " fill_account_internal_table
*&---------------------------------------------------------------------*
*&      Form  fill_liv_internal_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_LIV_INTERNAL_TABLE .

  TABLES : TCURC.

  DATA: L_ZTISCSDT  LIKE ZTISCSDT.

*-----------------------------------------------------------------------
*> Initialization BAPIs structures and Internal tables
*-----------------------------------------------------------------------
  FREE:  ITEMDATA,      TAXDATA,          WITHTAXDATA,
         RETURN,        ACCOUNTINGDATA,   VENDORITEMSPLITDATA,
         GLACCOUNTDATA, MATERIALDATA.

  CLEAR: HEADERDATA, INVOICEDOCNUMBER, FISCALYEAR,        ADDRESSDATA,
         ITEMDATA,   TAXDATA,          WITHTAXDATA,
         RETURN,     ACCOUNTINGDATA,   VENDORITEMSPLITDATA.

*-----------------------------------------------------------------------
*> Set header sturcture
*-----------------------------------------------------------------------
  IF ZTITCSK-VORGANG EQ C_CHAR1 OR
     ZTITCSK-VORGANG EQ C_CHAR3.
    MOVE: C_TRUE   TO HEADERDATA-INVOICE_IND."지시자: 송장전기
  ELSE.
    MOVE: C_FALSE  TO HEADERDATA-INVOICE_IND."지시자: 송장전기
  ENDIF.
*
  MOVE  ZTITCSK-BLART TO  HEADERDATA-DOC_TYPE.  "전표유형
  MOVE  ZTITCSK-BLDAT TO  HEADERDATA-DOC_DATE.  "전표증빙일
  MOVE  ZTITCSK-BUDAT TO  HEADERDATA-PSTNG_DATE."전표의 전기일
  MOVE  ZTITCSK-XBLNR TO  HEADERDATA-REF_DOC_NO."참조전표번호
  MOVE  ZTITCSK-BUKRS TO  HEADERDATA-COMP_CODE. "회사코드
  MOVE  ZTITCSK-LIFNR TO  HEADERDATA-DIFF_INV.  "다른 송장발행처
  MOVE  ZTITCSK-WAERS TO  HEADERDATA-CURRENCY.  "통화키

*>> Get CURRENCY ISO CODE.
  SELECT SINGLE *
    FROM TCURC
   WHERE WAERS EQ ZTITCSK-WAERS.
  IF SY-SUBRC EQ 0.
    MOVE TCURC-ISOCD   TO  HEADERDATA-CURRENCY_ISO. "ISO 통화코드
  ENDIF.

  IF ZTITCSK-WAERS NE T001-WAERS.
    MOVE  ZTITCSK-KURSF TO  HEADERDATA-EXCH_RATE. "직접호가환율
*  headerdata-EXCH_RATE_V."간접호가환율
  ENDIF.

*> 총송장금액.
  WRITE ZTITCSK-WRBTR TO G_TEXT_AMOUNT CURRENCY ZTITCSK-WAERS.
  PERFORM    SET_WRITE_NO_MASK     CHANGING  G_TEXT_AMOUNT.
  MOVE  G_TEXT_AMOUNT  TO  HEADERDATA-GROSS_AMOUNT."총송장금액

*  headerdata-CALC_TAX_IND."세금을 자동으로 계산
  MOVE  ZTITCSK-ZTERM TO  HEADERDATA-PMNTTRMS.  "지급조건키
  MOVE  ZTITCSK-ZFBDT TO  HEADERDATA-BLINE_DATE."만기계산기준일

**************************************************************
*> SB, Kang [ 05/03/11 ] : 지급조건키만 넘기도록 수정
*>    Why? Standard에서 양쪽의 값이 들어오면 오류발생함.
**************************************************************
*  MOVE  ztitcsk-zbd2t TO  headerdata-dsct_days2."현금 할인기간 2
*  MOVE  ztitcsk-zbd3t TO  headerdata-netterms.  "순액지급조건기간
*  MOVE  ztitcsk-zbd1p TO  headerdata-dsct_pct1. "현금할인율 1
*  MOVE  ztitcsk-zbd2p TO  headerdata-dsct_pct2. "현금할인율 1
**************************************************************

*  headerdata-IV_CATEGORY."물류송장검증 문서의 원본
  MOVE  ZTITCSK-BKTXT TO  HEADERDATA-HEADER_TXT."전표헤더텍스트
  MOVE  ZTITCSK-ZLSPR TO  HEADERDATA-PMNT_BLOCK."지급보류키
*  headerdata-DEL_COSTS."비계획운송비용
*  headerdata-DEL_COSTS_TAXC."운송비용 세금코드
*  headerdata-DEL_COSTS_TAXJ."운송비용에 대한 조세관할코드
  MOVE  SY-UNAME       TO  HEADERDATA-PERSON_EXT."외부시스템 사용자
  MOVE  ZTITCSK-ZLSCH TO  HEADERDATA-PYMT_METH. "지급방법
  MOVE  ZTITCSK-UZAWE TO  HEADERDATA-PMTMTHSUPL."지급방법보충
*  MOVE  ztitcsk-belnr TO  headerdata-inv_doc_no."송장문서문서번호
*  headerdata-SCBANK_IND."중앙은행지시자
*  headerdata-SUPCOUNTRY."공급국가
*  headerdata-BLLSRV_IND."서비스지시자 (해외지급)
  MOVE  ZTITCSK-XBLNR TO  HEADERDATA-REF_DOC_NO_LONG."참조전표번호
*  headerdata-DSCT_AMOUNT."문서통화의 현금할인액
*  headerdata-PO_SUB_NO."POR 서명자번호
*  headerdata-PO_CHECKDG."POR 점검숫자
*  headerdata-PO_REF_NO."POR 참조번호
  MOVE  ZTITCSK-EMPFK TO  HEADERDATA-PAYEE_PAYER."수취인 / 지급인
*  headerdata-PARTNER_BK."거래처은행유형

*> 은행관련비용일 경우-->House Bank ID.
  IF ZTITCSK-EXPGR EQ C_CHARL.
    SELECT HBKID
      INTO HEADERDATA-HOUSEBANKID    ">거래은행에 대한 단축키
      FROM ZTSTIG3 UP TO 1 ROWS
     WHERE BUKRS EQ ZTITCSK-BUKRS
       AND LIFNR EQ ZTITCSK-LIFNR
       AND PARTI EQ C_CHARB.
    ENDSELECT.
  ENDIF.
*
  MOVE  ZTITCSK-ZUONR TO   HEADERDATA-ALLOC_NMBR."지정번호
*  headerdata-PAYMT_REF."지급참조
*  headerdata-INV_REF_NO."송장참조: 송장참조를 위한 문서번호
*  headerdata-INV_YEAR."관련송장의 회계연도 (대변메모)
*  headerdata-INV_REC_DATE."송장수령일
*  headerdata-PLANNING_LEVEL."계획레벨
*  headerdata-PLANNING_DATE."계획일
*  headerdata-FIXEDTERMS."고정지급조건
  MOVE  ZTITCSK-GSBER TO  HEADERDATA-BUS_AREA.  "사업영역
*  headerdata-LOT_NUMBER."전표 로트번호
  MOVE  ZTITCSK-SGTXT TO  HEADERDATA-ITEM_TEXT. "항목텍스트

*-----------------------------------------------------------------------
*>Set item internal table.
*-----------------------------------------------------------------------
  LOOP AT IT_ZTISCSDT WHERE ITMST NE '5'
                        AND ITMST NE 'V'
                        AND ITMST NE 'P'.

    MOVE IT_ZTISCSDT-BUZEI TO  ITEMDATA-INVOICE_DOC_ITEM.
    "송장문서의 문서품목
    MOVE IT_ZTISCSDT-EBELN TO  ITEMDATA-PO_NUMBER. "구매오더번호.
    MOVE IT_ZTISCSDT-EBELP TO  ITEMDATA-PO_ITEM.   "구매문서 품목번호.
    MOVE IT_ZTISCSDT-MBLNR TO  ITEMDATA-REF_DOC.   "참조문서의 문서번호.
    MOVE IT_ZTISCSDT-MJAHR TO  ITEMDATA-REF_DOC_YEAR. "현재기간회계연도.
    MOVE IT_ZTISCSDT-MBLPO TO  ITEMDATA-REF_DOC_IT. "참조문서품목
    MOVE IT_ZTISCSDT-TBTKZ TO  ITEMDATA-DE_CRE_IND. "후속 차변/대변
    MOVE IT_ZTISCSDT-MWSKZ TO  ITEMDATA-TAX_CODE.   "세금코드
*        itemdata-TAXJURCODE"세금계산 관할구역 - 조세관할코드
*>
    IF IT_ZTISCSDT-ITMST EQ '1' OR
       IT_ZTISCSDT-ITMST EQ '2'.
      WRITE IT_ZTISCSDT-WRBTR TO       G_TEXT_AMOUNT
                              CURRENCY ZTITCSK-WAERS.
      PERFORM    SET_WRITE_NO_MASK     CHANGING  G_TEXT_AMOUNT.
      MOVE G_TEXT_AMOUNT     TO  ITEMDATA-ITEM_AMOUNT."전표통화금액
    ELSE.
      CLEAR G_TEXT_AMOUNT.
    ENDIF.

    MOVE IT_ZTISCSDT-MENGE TO  ITEMDATA-QUANTITY.   "수량
    MOVE IT_ZTISCSDT-MEINS TO  ITEMDATA-PO_UNIT.    "오더단위
*        itemdata-PO_UNIT_ISO"ISO 코드 오더단위
    MOVE IT_ZTISCSDT-PEINH TO  ITEMDATA-PO_PR_QNT.  "구매오더가격단위
    MOVE IT_ZTISCSDT-BPRME TO  ITEMDATA-PO_PR_UOM.  "오더가격단위
*        itemdata-PO_PR_UOM_ISO"ISO 코드의 구매오더 가격단위
    MOVE IT_ZTISCSDT-KSCHL TO  ITEMDATA-COND_TYPE.  "조건유형
*    MOVE it_ztiscsdt-stunr TO  itemdata-cond_st_no. "단계번호
*    MOVE it_ztiscsdt-zaehk TO  itemdata-cond_count. "조건카운터
*        itemdata-SHEET_NO"입력서번호
    MOVE IT_ZTISCSDT-SGTXT TO  ITEMDATA-ITEM_TEXT.  "항목텍스트


*        itemdata-FINAL_INV"최종송장지시자
*        itemdata-SHEET_ITEM"라인번호
*        itemdata-GRIR_CLEAR_SRV
*                      "외부서비스에 대한 GR/IR 전기의 반제지시자
*    move ztitcsk-lifnr to   itemdata-FREIGHT_VEN


*-[CHM2209-00266] 특정조건(엠트론, 관세비용, 제비용처리 담당자)
*  하에서 중복 구매오더 제외 -[s]
    IF IT_ZTISCSDT-BUKRS EQ '6000' AND  IT_ZTISCSDT-EXPCD EQ  'CCF' .
*      AND ( SY-UNAME EQ 'C287801' OR SY-UNAME EQ 'ZLSGLSM2').

      READ TABLE ITEMDATA WITH  KEY  PO_NUMBER = IT_ZTISCSDT-EBELN
                                     PO_ITEM   = IT_ZTISCSDT-EBELP .
      IF SY-SUBRC EQ 0.
        ITEMDATA-QUANTITY    = ITEMDATA-QUANTITY    + IT_ZTISCSDT-MENGE .
        ITEMDATA-ITEM_AMOUNT = ITEMDATA-ITEM_AMOUNT + G_TEXT_AMOUNT  .
        MODIFY ITEMDATA  TRANSPORTING QUANTITY ITEM_AMOUNT
                                WHERE PO_NUMBER = IT_ZTISCSDT-EBELN
                                  AND PO_ITEM   = IT_ZTISCSDT-EBELP.
        CONTINUE.
      ENDIF.
    ENDIF.
*
**-[CHM2209-00266] 특정조건(엠트론, 관세비용, 제비용처리 담당자)
**  하에서 중복 구매오더 제외 -[e]

    . "구매처 .
    APPEND ITEMDATA.
  ENDLOOP.

*-----------------------------------------------------------------------
*> Set G/L account data internal table.
*>      : 무환부대비 계정 생성.
*-----------------------------------------------------------------------
*  LOOP AT it_ztiscsdt WHERE itmst EQ '5'
*                         OR itmst EQ 'V'.
  LOOP AT IT_ZTISCSDT WHERE ITMST EQ '5'.
*
    CLEAR: GLACCOUNTDATA .

*    WRITE it_ztiscsdt-wrbtr TO       g_text_amount
*                            CURRENCY ztitcsk-waers.
*    PERFORM    set_write_no_mask     CHANGING  g_text_amount.
    IF IT_ZTISCSDT-ITMST EQ '5'.
      WRITE IT_ZTISCSDT-WRBTR TO       G_TEXT_AMOUNT
                              CURRENCY ZTITCSK-WAERS.
    ELSEIF IT_ZTISCSDT-ITMST EQ 'V'.
      WRITE IT_ZTISCSDT-WMWST TO       G_TEXT_AMOUNT
                              CURRENCY ZTITCSK-WAERS.
    ENDIF.
    PERFORM    SET_WRITE_NO_MASK     CHANGING  G_TEXT_AMOUNT.

    GLACCOUNTDATA-INVOICE_DOC_ITEM = IT_ZTISCSDT-BUZEI. "문서품목
    GLACCOUNTDATA-GL_ACCOUNT  = IT_ZTISCSDT-SAKNR.      "총계정원장계정
    GLACCOUNTDATA-ITEM_AMOUNT = G_TEXT_AMOUNT.          "전표통화금액
    GLACCOUNTDATA-DB_CR_IND   = IT_ZTISCSDT-SHKZG.      "차변/대변
    GLACCOUNTDATA-COMP_CODE   = ZTITCSK-BUKRS.         "회사코드
    GLACCOUNTDATA-TAX_CODE    = IT_ZTISCSDT-MWSKZ.      "부가가치세코드
    GLACCOUNTDATA-ITEM_TEXT   = IT_ZTISCSDT-SGTXT.      "항목텍스트
    GLACCOUNTDATA-COSTCENTER  = IT_ZTISCSDT-KOSTL.      "코스트센터
    GLACCOUNTDATA-PROFIT_CTR  = IT_ZTISCSDT-PRCTR.      "손익센터
    GLACCOUNTDATA-BUS_AREA    = IT_ZTISCSDT-GSBER.      "사업영역
    GLACCOUNTDATA-WBS_ELEM    = IT_ZTISCSDT-PSPNR.      "WBS 요소

    IF IT_ZTISCSDT-ITMST EQ 'V'.
      WRITE IT_ZTISCSDT-FWBAS TO       G_TEXT_AMOUNT
                              CURRENCY ZTITCSK-WAERS.
      PERFORM    SET_WRITE_NO_MASK     CHANGING  G_TEXT_AMOUNT.
      GLACCOUNTDATA-TAX_BASE_AMOUNT = G_TEXT_AMOUNT.   ">과세표준액.
    ENDIF.

    APPEND GLACCOUNTDATA.
*NEG_POSTNG. "지시자: 마이너스전기
*TAXJURCODE. "세금계산 관할구역 - 조세관할코드
*FUND. "펀드
*TR_PART_BA. "거래처 사업영역
*COSTOBJECT. "원가집적대상
*NETWORK. "계정지정 네트워크번호
*ACTIVITY. "액티비티번호
*SD_DOC. "영업/유통 문서번호
*SDOC_ITEM. "영업문서품목
*ORDERID. "오더번호
*REF_DATE. "정산참조일
*CMMT_ITEM. "약정항목
*FUNDS_CTR. "예산관리센터
*FUNC_AREA. "기능 영역
*ACTTYPE. "액티비티유형
*RL_EST_KEY. "부동산 오브젝트에 대한 내부키
*PERSON_NO. "사원번호
*CO_BUSPROC. "비지니스 프로세스
*GRANT_NBR. "교부금
*CMMT_ITEM_LONG. "약정항목
*FUNC_AREA_LONG. "기능영역
*QUANTITY. "수량
*BASE_UOM. "기본단위
*ALLOC_NMBR. "지정번호
*CSHDIS_IND. "지시자: 현금할인하지 않는 개별항목
*TAX_BASE_AMOUNT = . "문서통화로 표시된 과세표준액
  ENDLOOP.

*  LOOP AT itemdata.
*    SELECT SINGLE *
*      FROM ekpo
*     WHERE ebeln  EQ  itemdata-po_number
*       AND ebelp  EQ  itemdata-po_item.
*
*    SELECT SINGLE *
*      FROM t001w
*     WHERE werks  EQ  ekpo-werks.
*
*    SELECT SINGLE *
*      FROM t006
*     WHERE msehi  EQ  ekpo-lmein.
*
*    MOVE: itemdata-invoice_doc_item TO materialdata-invoice_doc_item,
*          ekpo-matnr                TO materialdata-material,
*          t001w-bwkey               TO materialdata-val_area,
*          ekpo-bwtar                TO materialdata-valuation_type,
**          itemdata-de_cre_ind       to materialdata-DB_CR_IND,
*          itemdata-item_amount      TO materialdata-item_amount,
*          itemdata-quantity         TO materialdata-quantity,
*          ekpo-lmein                TO materialdata-base_uom,
*          t006-isocode              TO materialdata-base_uom_iso,
*          itemdata-tax_code         TO materialdata-tax_code.
*    IF headerdata-invoice_ind EQ c_true.
*      materialdata-db_cr_ind = c_chars.
*    ELSE.
*      materialdata-db_cr_ind = c_charh.
*    ENDIF.
**materialdata-TAXJURCODE
**materialdata-MATERIAL_EXTERNAL
**materialdata-MATERIAL_GUID
**materialdata-MATERIAL_VERSION
*    APPEND materialdata.
*  ENDLOOP.

*---------------------------------------------------------------------
*>>>> NF Material.
*---------------------------------------------------------------------
*> 환율.
  DATA: L_EXCHANGE_RATE LIKE TCURR-UKURS,
        L_CONV_DATE     LIKE SY-DATUM.

  DATA: BEGIN OF RATEEQUATION,
          KURSP  LIKE RFCU9-KURSP,
          FFACTP LIKE TCURF-FFACT,
          TFACTP LIKE TCURF-TFACT,
          FCURRP LIKE TCURC-WAERS,
          TCURRP LIKE TCURC-WAERS,
          KURSM  LIKE RFCU9-KURSM,
          FFACTM LIKE TCURF-FFACT,
          TFACTM LIKE TCURF-TFACT,
          FCURRM LIKE TCURC-WAERS,
          TCURRM LIKE TCURC-WAERS,
        END OF RATEEQUATION.
  DATA  RATE       LIKE TCURR-UKURS.

  DATA: BEGIN OF AMOUNTS,
          FORAMOUNT(16) TYPE P DECIMALS 2,
          LOCAMOUNT(16) TYPE P DECIMALS 2,
          FORCUR        LIKE TCURR-FCURR,
          LOCCUR        LIKE TCURR-TCURR,
        END OF AMOUNTS.


*  TABLES: /nfm/torderpos.
*  REFRESH: nfmetallitms.
*  LOOP AT itemdata.
*    SELECT *
*      INTO CORRESPONDING FIELDS OF TABLE nfm_torderpos
*      FROM /nfm/torderpos
*     WHERE blt     EQ c_charb   ">구매오더.
*       AND belnr   EQ itemdata-po_number
*       AND posnr   EQ itemdata-po_item
*       AND bukrs   EQ ztitcsk-bukrs.
*
*    LOOP AT nfm_torderpos.
**       PERFORM  currency_convert_to_internal
**                         CHANGING itemdata-item_amount
**                                  nfmetallitms-rate
**                                  ztitcsk-waers
**                                  tcurc-isocd.
**> 금액 계산.
*      IF ztitcsk-waers NE nfm_torderpos-nkw.
**        CALL FUNCTION 'READ_EXCHANGE_RATE'
**          EXPORTING
**            date             = l_conv_date
**            foreign_currency = nfm_torderpos-nkw
**            local_currency   = ztitcsk-waers
**            type_of_rate     = 'M'
**          IMPORTING
**            exchange_rate    = l_exchange_rate
**          EXCEPTIONS
**            error_message    = 1.
**        IF sy-subrc = 1.
**          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
**        ENDIF.
**
**        IF l_exchange_rate > 0.
**          rate = nfm_torderpos-bks.
**        ELSE.
**          rate = - nfm_torderpos-bks.
**        ENDIF.
*      else.
*        rate = 1.
*      ENDIF.
*
**      l_conv_date = ztitcsk-WWERT.
**      amounts-foramount = nfm_torderpos-nkn.
**
**      CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
**        EXPORTING
**          date             = l_conv_date
**          foreign_amount   = amounts-foramount
**          foreign_currency = nfm_torderpos-nkw
**          local_currency   = ztitcsk-waers
***          rate             = rate
**          type_of_rate     = 'M'
**        IMPORTING
**          local_amount     = amounts-locamount
**        EXCEPTIONS
**          error_message    = 1.
**      IF sy-subrc <> 0.
**        MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
**                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
**        EXIT.
**      ENDIF.
**      nfm_torderpos-nkn = amounts-locamount.
*
*
*      MOVE: itemdata-invoice_doc_item TO nfmetallitms-data_index,
*            nfm_torderpos-belnr       TO nfmetallitms-doc_number,
*            nfm_torderpos-posnr       TO nfmetallitms-itm_number,
*            nfm_torderpos-bukrs       TO nfmetallitms-compcode,
*            ztitcsk-gjahr             TO nfmetallitms-fiscyear,
*            nfm_torderpos-nes         TO nfmetallitms-nfmkey,
*            nfm_torderpos-nfs         TO nfmetallitms-ratedetkey,
*            nfm_torderpos-neb         TO nfmetallitms-basekey,
*            nfm_torderpos-bsl         TO nfmetallitms-exchangekey,
*            nfm_torderpos-ndt         TO nfmetallitms-ratedetdat,
*            nfm_torderpos-nmo         TO nfmetallitms-ratemonth,
*            nfm_torderpos-kta         TO nfmetallitms-actratedat,
*            nfm_torderpos-nkn         TO nfmetallitms-rate,
*            nfm_torderpos-nkw         TO nfmetallitms-ratecurky,
**            nfm_torderpos-nkn   TO nfmetallitms-rate,
**            ztitcsk-waers       TO nfmetallitms-ratecurky,
**            tcurc-isocd         TO nfmetallitms-ratecurkyiso,
*            nfm_torderpos-nku         TO nfmetallitms-ratedoccur,
**            amounts-locamount   TO nfmetallitms-ratedoccur,
*            nfm_torderpos-fsp         TO nfmetallitms-invoicebl,
*            nfm_torderpos-bwr         TO nfmetallitms-bvaldoccur,
*            nfm_torderpos-bcu         TO nfmetallitms-bvalcurkyd,
**            ztitcsk-waers       TO nfmetallitms-bvalcurkyd,
**            tcurc-isocd         TO nfmetallitms-bvalcurkydiso,
**            nfmetallitms-rate   TO nfmetallitms-netrate,
*            nfm_torderpos-nno         TO nfmetallitms-netrate,
*            nfm_torderpos-bek         TO nfmetallitms-provider,
*            nfm_torderpos-eind        TO nfmetallitms-vendorcov,
*            nfm_torderpos-eds         TO nfmetallitms-coverageky,
*            nfm_torderpos-nbd         TO nfmetallitms-postingdays,
*            'I'                       TO nfmetallitms-updtype.
*
*      APPEND nfmetallitms.
*    ENDLOOP.
*
*  ENDLOOP.

*-----------------------------------------------------------------------
*> Set Tax internal table.
*>      : Tax data 생성.
*-----------------------------------------------------------------------
  LOOP AT IT_TAB INTO G_TC_2130_WA WHERE CSCTY NE 'V'.
**>> TAX DATA.
    TAXDATA-TAX_CODE         = G_TC_2130_WA-MWSKZ.     "부가가치세코드
    WRITE G_TC_2130_WA-WMWST  TO        G_TEXT_AMOUNT
                       CURRENCY  ZTITCSK-WAERS.
    PERFORM    SET_WRITE_NO_MASK CHANGING  G_TEXT_AMOUNT.
    TAXDATA-TAX_AMOUNT       = G_TEXT_AMOUNT. "전표통화세액
    WRITE G_TC_2130_WA-FWBAS  TO        G_TEXT_AMOUNT
                       CURRENCY  ZTITCSK-WAERS.
    PERFORM    SET_WRITE_NO_MASK CHANGING  G_TEXT_AMOUNT.
    TAXDATA-TAX_BASE_AMOUNT  = G_TEXT_AMOUNT.  "문서통화 과세표준액
    COLLECT TAXDATA.
  ENDLOOP.

*-----------------------------------------------------------------------
*> Set One time account data.
*>   : 일회성 계정.
*-----------------------------------------------------------------------
  MOVE-CORRESPONDING ZTITCSO TO ADDRESSDATA.

ENDFORM.                    " fill_liv_internal_table
*&---------------------------------------------------------------------*
*&      Form  SET_CANCEL_DOCUMENT_NUMBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_CANCEL_DOCUMENT_NUMBER USING P_ZTISSCRCOM STRUCTURE ZTISSCRCOM.

  MOVE: ZTITCSK-BELNR   TO   P_ZTISSCRCOM-BELNR,
        ZTITCSK-GJAHR   TO   P_ZTISSCRCOM-GJAHR,
        ZTITCSK-BUKRS   TO   P_ZTISSCRCOM-BUKRS,
        ZTITCSK-BLART   TO   P_ZTISSCRCOM-BLART,
        ZTITCSK-LIFNR   TO   P_ZTISSCRCOM-LIFNR,
        ZTITCSK-WAERS   TO   P_ZTISSCRCOM-WAERS,
        ZTITCSK-WRBTR   TO   P_ZTISSCRCOM-WRBTR.

  IF P_ZTISSCRCOM-CBUDAT IS   INITIAL.
    MOVE: SY-DATLO       TO   P_ZTISSCRCOM-CBUDAT.
  ENDIF.

  SPOP-TEXTLINE1 = '해당 비용회계문서를 취소하시겠습니까?'.

ENDFORM.                    " SET_CANCEL_DOCUMENT_NUMBER
*&---------------------------------------------------------------------*
*&      Form  BELEGART_AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BELEGART_AUTHORITY_CHECK.

*  CHECK T003-BRGRU NE SPACE.
*
*  AUTHORITY-CHECK OBJECT F_BKPF_BLA
*    ID 'ACTVT' FIELD ACT_HINZ
*    ID 'BRGRU' FIELD T003-BRGRU.
*
*  CHECK SY-SUBRC NE 0.
*  MESSAGE E087(F5) WITH ZTITCSK-BLART.

ENDFORM.                    " BELEGART_AUTHORITY_CHECK
*---------------------------------------------------------------------*
*       FORM fill_account_header
*---------------------------------------------------------------------*
FORM FILL_ACCOUNT_HEADER.

  CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
    IMPORTING
      OWN_LOGICAL_SYSTEM = GS_DOCUMENTHEADER-OBJ_SYS.

* OBJ_TYPE has to be replaced by customers object key (Y* or Z*)
  GS_DOCUMENTHEADER-OBJ_TYPE   = 'BKPFF'.
  GS_DOCUMENTHEADER-OBJ_KEY    = '$'.
  GS_DOCUMENTHEADER-BUS_ACT    = 'RFBU'.   ">FB01, MIRO

  GS_DOCUMENTHEADER-USERNAME   = SY-UNAME.
  GS_DOCUMENTHEADER-HEADER_TXT = ZTITCSK-BKTXT.
  GS_DOCUMENTHEADER-COMP_CODE  = ZTITCSK-BUKRS.
  GS_DOCUMENTHEADER-DOC_DATE   = ZTITCSK-BLDAT.
  GS_DOCUMENTHEADER-PSTNG_DATE = ZTITCSK-BUDAT.
  GS_DOCUMENTHEADER-TRANS_DATE = ZTITCSK-WWERT.
  GS_DOCUMENTHEADER-FISC_YEAR  = ZTITCSK-GJAHR.
  GS_DOCUMENTHEADER-FIS_PERIOD = ZTITCSK-MONAT.
  GS_DOCUMENTHEADER-DOC_TYPE   = ZTITCSK-BLART.
* Gs_DOCUMENTHEADER-REF_DOC_NO =
* Gs_DOCUMENTHEADER-AC_DOC_NO  =
* gs_documentheader-obj_key_r  =
* Gs_DOCUMENTHEADER-reason_rev =
* Gs_DOCUMENTHEADER-COMPO_ACC  =
  GS_DOCUMENTHEADER-REF_DOC_NO_LONG = ZTITCSK-XBLNR.
* Gs_DOCUMENTHEADER-ACC_PRINCIPLE =

*> 일회용계정일 경우.
  IF ZTITCSK-XCPDK IS INITIAL.
    CLEAR: GS_CUSTOMERCPD.
  ELSE.
    MOVE-CORRESPONDING ZTITCSO TO GS_CUSTOMERCPD.
  ENDIF.

ENDFORM.                    "fill_account_header
*---------------------------------------------------------------------*
*       FORM fill_account_header_cancel
*---------------------------------------------------------------------*
FORM FILL_ACCOUNT_HEADER_CANCEL USING P_ZTISSCRCOM STRUCTURE ZTISSCRCOM.

  CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
    IMPORTING
      OWN_LOGICAL_SYSTEM = GS_DOCUMENTHEADER-OBJ_SYS.

* OBJ_TYPE has to be replaced by customers object key (Y* or Z*)
  GS_DOCUMENTHEADER-OBJ_TYPE   = 'BKPFF'.
  GS_DOCUMENTHEADER-OBJ_KEY    = '$'.
  GS_DOCUMENTHEADER-BUS_ACT    = 'RFBU'.   ">FB01, MIRO

  GS_DOCUMENTHEADER-USERNAME   = SY-UNAME.
  GS_DOCUMENTHEADER-HEADER_TXT = P_ZTISSCRCOM-BKTXT.
  GS_DOCUMENTHEADER-COMP_CODE  = P_ZTISSCRCOM-BUKRS.
  GS_DOCUMENTHEADER-DOC_DATE   = P_ZTISSCRCOM-BLDAT.
  GS_DOCUMENTHEADER-PSTNG_DATE = P_ZTISSCRCOM-BUDAT.
  GS_DOCUMENTHEADER-TRANS_DATE = P_ZTISSCRCOM-WWERT.
  GS_DOCUMENTHEADER-FISC_YEAR  = P_ZTISSCRCOM-GJAHR.
  GS_DOCUMENTHEADER-FIS_PERIOD = P_ZTISSCRCOM-MONAT.
  GS_DOCUMENTHEADER-DOC_TYPE   = P_ZTISSCRCOM-BLART.
* Gs_DOCUMENTHEADER-REF_DOC_NO =
* Gs_DOCUMENTHEADER-AC_DOC_NO  =
* gs_documentheader-obj_key_r  =
* Gs_DOCUMENTHEADER-reason_rev =
* Gs_DOCUMENTHEADER-COMPO_ACC  =
  GS_DOCUMENTHEADER-REF_DOC_NO_LONG = P_ZTISSCRCOM-XBLNR.
* Gs_DOCUMENTHEADER-ACC_PRINCIPLE =

ENDFORM.                    "fill_account_header_cancel


*---------------------------------------------------------------------*
*       FORM fill_account_contractheader
*---------------------------------------------------------------------*
FORM FILL_ACCOUNT_CONTRACTHEADER.

*  gd_fica_hd-doc_no           =
*  gd_fica_hd-doc_type_ca      =
*  gd_fica_hd-res_key          =
*  gd_fica_hd-fikey            =
*  gd_fica_hd-payment_form_ref =

ENDFORM.                    "fill_account_contractheader

*---------------------------------------------------------------------*
*       FORM fill_account_cpd
*---------------------------------------------------------------------*
FORM FILL_ACCOUNT_CPD.

*  gd_customercpd-name
*  gd_customercpd-name_2
*  gd_customercpd-name_3
*  gd_customercpd-name_4
*  gd_customercpd-postl_code
*  gd_customercpd-city
*  gd_customercpd-country
*  gd_customercpd-country_iso
*  gd_customercpd-street
*  gd_customercpd-po_box
*  gd_customercpd-pobx_pcd
*  gd_customercpd-pobk_curac
*  gd_customercpd-bank_acct
*  gd_customercpd-bank_no
*  gd_customercpd-bank_ctry
*  gd_customercpd-bank_ctry_iso
*  gd_customercpd-tax_no_1
*  gd_customercpd-tax_no_2
*  gd_customercpd-tax
*  gd_customercpd-equal_tax
*  gd_customercpd-region
*  gd_customercpd-ctrl_key
*  gd_customercpd-instr_key
*  gd_customercpd-dme_ind
*  gd_customercpd-langu_iso

ENDFORM.                    "fill_account_cpd
*---------------------------------------------------------------------*
*       FORM fill_account_accountgl
*---------------------------------------------------------------------*
FORM FILL_ACCOUNT_ACCOUNTGL.

  CLEAR IT_ACCOUNTGL.
  IT_ACCOUNTGL-ITEMNO_ACC     = IT_ZTISCSDT-BUZEI.
*  it_accountgl-gl_account     = it_ztiscsdt-saknr.

************************************************************************
* 20051025 simcho 수입제비용 처리 계정
************************************************************************
* 구매오더 계정지정범주 select
  DATA  LV_KNTTP LIKE EKPO-KNTTP.
  CLEAR LV_KNTTP.

  SELECT SINGLE KNTTP INTO LV_KNTTP
    FROM EKPO
   WHERE EBELN = IT_ZTISCSDT-EBELN
     AND EBELP = IT_ZTISCSDT-EBELP.

* 20060328 simcho WBS코드 지정
  IF LV_KNTTP = 'P' OR LV_KNTTP = 'N'.
    IF IT_ZTISCSDT-PS_PSP_PNR IS INITIAL.
      CLEAR EKKN.
      SELECT SINGLE PS_PSP_PNR INTO IT_ZTISCSDT-PS_PSP_PNR
        FROM EKKN
       WHERE EBELN = IT_ZTISCSDT-EBELN
         AND EBELP = IT_ZTISCSDT-EBELP.
      "CCM : 2023.04.12  ZITCS4HDEV04 - MATNR과 관련 없음 (확인 완료)
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = IT_ZTISCSDT-PS_PSP_PNR
        IMPORTING
          OUTPUT = IT_ZTISCSDT-PS_PSP_PNR.

    ENDIF.
  ENDIF.
* end simcho

* PO계정지정범주: P,N,K 일때 PO계정으로 회계전표 처리
  IF LV_KNTTP = 'P' OR LV_KNTTP = 'N' OR LV_KNTTP = 'K'.
    IF IT_ZTISCSDT-SAKTO IS INITIAL.
      "CCM : 2023.04.12  ZITCS4HDEV04 - MATNR과 관련 없음 (확인 완료)
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = IT_ZTISCSDT-SAKNR
        IMPORTING
          OUTPUT = IT_ACCOUNTGL-GL_ACCOUNT.
    ELSE.
      "CCM : 2023.04.12  ZITCS4HDEV04 - MATNR과 관련 없음 (확인 완료)
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = IT_ZTISCSDT-SAKTO
        IMPORTING
          OUTPUT = IT_ACCOUNTGL-GL_ACCOUNT.
    ENDIF.
  ELSE.
    "CCM : 2023.04.12  ZITCS4HDEV04 - MATNR과 관련 없음 (확인 완료)
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = IT_ZTISCSDT-SAKNR
      IMPORTING
        OUTPUT = IT_ACCOUNTGL-GL_ACCOUNT.
  ENDIF.

* 20051025 simcho 수입제비용 처리 계정 무조건 세팅계정으로
* PO계정 무시
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*        input  = it_ztiscsdt-saknr
*      IMPORTING
*        output = it_accountgl-gl_account.
************************************************************************
* end simcho
************************************************************************


** 20051024 simcho 네트워크 액티비티번호 추가
  IF NOT IT_ZTISCSDT-NPLNR IS INITIAL.  "네트워크번호
    SELECT SINGLE VORNR INTO IT_ZTISCSDT-ACTIVITY
      FROM AFVC
     WHERE AUFPL = IT_ZTISCSDT-AUFPL
       AND APLZL = IT_ZTISCSDT-APLZL.
  ENDIF.
** end simcho

* IT_ACCOUNTGL-STAT_CON       =
* IT_ACCOUNTGL-REF_KEY_1      =
* IT_ACCOUNTGL-REF_KEY_2      =
* IT_ACCOUNTGL-REF_KEY_3      =
  IT_ACCOUNTGL-TAX_CODE       = IT_ZTISCSDT-MWSKZ.
  IT_ACCOUNTGL-ACCT_TYPE      = IT_ZTISCSDT-KOART.
  IT_ACCOUNTGL-COMP_CODE      = IT_ZTISCSDT-BUKRS.
  IT_ACCOUNTGL-ASSET_NO       = IT_ZTISCSDT-ANLN1.
  IT_ACCOUNTGL-SUB_NUMBER     = IT_ZTISCSDT-ANLN2.
  IT_ACCOUNTGL-ORDERID        = IT_ZTISCSDT-AUFNR.
  IT_ACCOUNTGL-COSTOBJECT     = IT_ZTISCSDT-KSTRG.

* 20051022 simcho network/activity 삭제
  IT_ACCOUNTGL-NETWORK        = IT_ZTISCSDT-NPLNR.
  IT_ACCOUNTGL-ACTIVITY       = IT_ZTISCSDT-ACTIVITY.
* end simcho
  IT_ACCOUNTGL-ROUTING_NO     = IT_ZTISCSDT-AUFPL.
  IT_ACCOUNTGL-PART_ACCT      = IT_ZTISCSDT-VPTNR.
  IT_ACCOUNTGL-CMMT_ITEM      = IT_ZTISCSDT-FIPOS.
  IT_ACCOUNTGL-FUNDS_CTR      = IT_ZTISCSDT-FISTL.
  IT_ACCOUNTGL-FUND           = IT_ZTISCSDT-GEBER.
  IT_ACCOUNTGL-FUNC_AREA_LONG = IT_ZTISCSDT-FKBER.
  IT_ACCOUNTGL-ROUTING_NO     = IT_ZTISCSDT-AUFPL_ORD.
  IT_ACCOUNTGL-TAXJURCODE     = IT_ZTISCSDT-TXJCD.
  IT_ACCOUNTGL-ACTTYPE        = IT_ZTISCSDT-LSTAR.
  IT_ACCOUNTGL-CO_BUSPROC     = IT_ZTISCSDT-PRZNR.
  IT_ACCOUNTGL-GRANT_NBR      = IT_ZTISCSDT-GRANT_NBR.
  IT_ACCOUNTGL-WBS_ELEMENT    = IT_ZTISCSDT-PSPNR.


  IT_ACCOUNTGL-QUANTITY       = IT_ZTISCSDT-MENGE.
  IT_ACCOUNTGL-BASE_UOM       = IT_ZTISCSDT-MEINS.
*  IT_ACCOUNTGL-ACCT_KEY       = '31'.
* IT_ACCOUNTGL-TAXJURCODE     =
* IT_ACCOUNTGL-CSHDIS_IND     =
  IT_ACCOUNTGL-ITEM_TEXT      = IT_ZTISCSDT-SGTXT.
  IT_ACCOUNTGL-ALLOC_NMBR     = IT_ZTISCSDT-ZUONR.
  IT_ACCOUNTGL-BUS_AREA       = IT_ZTISCSDT-GSBER.
  IT_ACCOUNTGL-PROFIT_CTR     = IT_ZTISCSDT-PRCTR.
  IT_ACCOUNTGL-COSTCENTER     = IT_ZTISCSDT-KOSTL.
  IT_ACCOUNTGL-WBS_ELEMENT    = IT_ZTISCSDT-PSPNR.
* 2006.03.28 simcho WBS코드 생성
  CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
    EXPORTING
      INPUT  = IT_ZTISCSDT-PS_PSP_PNR
    IMPORTING
      OUTPUT = IT_ACCOUNTGL-WBS_ELEMENT.

*  it_accountgl-wbs_element    = it_ztiscsdt-ps_psp_pnr.
* end simcho
  IT_ACCOUNTGL-PO_NUMBER      = IT_ZTISCSDT-EBELN.
  IT_ACCOUNTGL-PO_ITEM        = IT_ZTISCSDT-EBELP.

*  it_accountgl-plant          = it_ztiscsdt-werks.
  IT_ACCOUNTGL-PLANT          = IT_ZTISCSDT-BUPLA.
  IT_ACCOUNTGL-MATERIAL       = IT_ZTISCSDT-MATNR.

* IT_ACCOUNTGL-ORDERID        =
* it_accountgl-ext_object_id  =
* it_accountgl-bus_scenario   =
* IT_ACCOUNTGL-MATERIAL       =
* IT_ACCOUNTGL-QUANTITY       =
* IT_ACCOUNTGL-BASE_UOM       =
* IT_ACCOUNTGL-BASE_UOM_ISO   =
* IT_ACCOUNTGL-PART_PRCTR     =
* IT_ACCOUNTGL-WBS_ELEMENT    =
* IT_ACCOUNTGL-NETWORK        =
* IT_ACCOUNTGL-CMMT_ITEM      =
* IT_ACCOUNTGL-FUNDS_CTR      =
* IT_ACCOUNTGL-FUND           =
* IT_ACCOUNTGL-SALES_ORD      =
* IT_ACCOUNTGL-S_ORD_ITEM     =
* IT_ACCOUNTGL-P_EL_PRCTR     =
* IT_ACCOUNTGL-BILL_TYPE      =
* IT_ACCOUNTGL-DISTR_CHAN     =
* IT_ACCOUNTGL-SOLD_TO        =
* IT_ACCOUNTGL-DIVISION       =
* IT_ACCOUNTGL-SALESORG       =
* IT_ACCOUNTGL-SALES_OFF      =
* IT_ACCOUNTGL-SALES_GRP      =
* IT_ACCOUNTGL-INV_QTY        =
* IT_ACCOUNTGL-SALES_UNIT     =
* IT_ACCOUNTGL-SALES_UNIT_ISO =
* IT_ACCOUNTGL-INV_QTY_SU     =
* IT_ACCOUNTGL-NET_WEIGHT     =
* IT_ACCOUNTGL-GROSS_WT       =
* IT_ACCOUNTGL-UNIT_OF_WT     =
* IT_ACCOUNTGL-UNIT_OF_WT_ISO =
* IT_ACCOUNTGL-VOLUME         =
* IT_ACCOUNTGL-VOLUMEUNIT     =
* IT_ACCOUNTGL-VOLUMEUNIT_ISO =
* it_accountgl-fm_area        =
* it_accountgl-log_proc       =
* it_accountgl-ac_doc_no      =
* it_accountgl-acct_type      =
* it_accountgl-doc_type       =
* it_accountgl-comp_code      =
* it_accountgl-func_area      =
* it_accountgl-plant          =
* it_accountgl-fis_period     =
* it_accountgl-fisc_year      =
* it_accountgl-pstng_date     =
* it_accountgl-value_date     =
* it_accountgl-customer       =
* it_accountgl-vendor_no      =
* it_accountgl-costobject     =
* it_accountgl-acttype        =
* it_accountgl-order_itno     =
* it_accountgl-routing_no     =
* it_accountgl-activity       =
* it_accountgl-cond_type      =
* it_accountgl-cond_count     =
* it_accountgl-cond_st_no     =
* it_accountgl-co_busproc     =
* it_accountgl-asset_no       =
* it_accountgl-sub_number     =
* it_accountgl-de_cre_ind     =
* it_accountgl-p_el_prctr     =
* it_accountgl-xmfrw          =
* it_accountgl-po_pr_qnt      =
* it_accountgl-po_pr_uom      =
* it_accountgl-po_pr_uom_iso  =
* it_accountgl-entry_qnt      =
* it_accountgl-entry_uom      =
* it_accountgl-entry_uom_iso  =
* it_accountgl-item_cat       =
* it_accountgl-matl_type      =
* it_accountgl-mvt_ind        =
* it_accountgl-reval_ind      =
* it_accountgl-orig_group     =
* it_accountgl-orig_mat       =
* it_accountgl-serial_no      =
* it_accountgl-part_acct      =
* it_accountgl-tr_part_ba     =
* it_accountgl-trade_id       =
* it_accountgl-val_area       =
* it_accountgl-val_type       =
* it_accountgl-asval_date     =
* it_accountgl-po_number      =
* it_accountgl-po_item        =
  APPEND IT_ACCOUNTGL.

ENDFORM.                    "fill_account_accountgl

*---------------------------------------------------------------------*
*       FORM fill_account_ar
*---------------------------------------------------------------------*
FORM FILL_ACCOUNT_ACCOUNTAR.

* CLEAR it_accountreceivable.
* it_accountreceivable-itemno_acc =
* it_accountreceivable-customer   =
* IT_ACCOUNTRECEIVABLE-REF_KEY_1  =
* IT_ACCOUNTRECEIVABLE-REF_KEY_2  =
* IT_ACCOUNTRECEIVABLE-REF_KEY_3  =
* IT_ACCOUNTRECEIVABLE-PMNTTRMS   =
* IT_ACCOUNTRECEIVABLE-BLINE_DATE =
* IT_ACCOUNTRECEIVABLE-DSCT_DAYS1 =
* IT_ACCOUNTRECEIVABLE-DSCT_DAYS2 =
* IT_ACCOUNTRECEIVABLE-NETTERMS   =
* IT_ACCOUNTRECEIVABLE-DSCT_PCT1  =
* IT_ACCOUNTRECEIVABLE-DSCT_PCT2  =
* IT_ACCOUNTRECEIVABLE-PYMT_METH  =
* IT_ACCOUNTRECEIVABLE-DUNN_KEY   =
* IT_ACCOUNTRECEIVABLE-DUNN_BLOCK =
* IT_ACCOUNTRECEIVABLE-PMNT_BLOCK =
* IT_ACCOUNTRECEIVABLE-VAT_REG_NO =
* IT_ACCOUNTRECEIVABLE-ALLOC_NMBR =
* it_accountreceivable-item_text  =
* IT_ACCOUNTRECEIVABLE-PARTNER_BK =
* IT_ACCOUNTRECEIVABLE-GL_ACCOUNT =
* it_accountreceivable-comp_code
* it_accountreceivable-bus_area
* it_accountreceivable-pmtmthsupl
* it_accountreceivable-paymt_ref
* it_accountreceivable-scbank_ind
* it_accountreceivable-businessplace
* it_accountreceivable-sectioncode
* it_accountreceivable-branch
* it_accountreceivable-pymt_cur
* it_accountreceivable-pymt_cur_iso
* it_accountreceivable-pymt_amt
* it_accountreceivable-c_ctr_area
* it_accountreceivable-bank_id
* it_accountreceivable-supcountry
* it_accountreceivable-supcountry_iso
* it_accountreceivable-tax_code
* it_accountreceivable-taxjurcode
* it_accountreceivable-tax_date
* it_accountreceivable-sp_gl_ind
* it_accountreceivable-partner_guid = '1465464654'.
* APPEND it_accountreceivable.

ENDFORM.                    "fill_account_accountar

*---------------------------------------------------------------------*
*       FORM fill_ap                                                  *
*---------------------------------------------------------------------*
FORM FILL_ACCOUNT_ACCOUNTAP.

  CLEAR IT_ACCOUNTPAYABLE.
  IT_ACCOUNTPAYABLE-ITEMNO_ACC = IT_ZTISCSDT-BUZEI.
  IT_ACCOUNTPAYABLE-VENDOR_NO  = ZTITCSK-LIFNR.
  IT_ACCOUNTPAYABLE-ALT_PAYEE  = ZTITCSK-EMPFK.
*  it_accountpayable-gl_account = it_ztiscsdt-saknr.
  "CCM : 2023.04.12  ZITCS4HDEV04 - MATNR과 관련 없음 (확인 완료)
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = IT_ZTISCSDT-SAKNR
    IMPORTING
      OUTPUT = IT_ACCOUNTPAYABLE-GL_ACCOUNT.

* it_accountpayable-ref_key_1
* it_accountpayable-ref_key_2
* it_accountpayable-ref_key_3
  IT_ACCOUNTPAYABLE-COMP_CODE  = IT_ZTISCSDT-BUKRS.
  IT_ACCOUNTPAYABLE-BUS_AREA   = IT_ZTISCSDT-GSBER.
*  it_accountpayable-tax_code   = it_ztiscsdt-mwskz.
  IT_ACCOUNTPAYABLE-PMNTTRMS   = ZTITCSK-ZTERM.
  IT_ACCOUNTPAYABLE-BLINE_DATE = ZTITCSK-ZFBDT.
  IT_ACCOUNTPAYABLE-DSCT_DAYS1 = ZTITCSK-ZBD1T.
  IT_ACCOUNTPAYABLE-DSCT_DAYS2 = ZTITCSK-ZBD2T.
  IT_ACCOUNTPAYABLE-NETTERMS   = ZTITCSK-ZBD3T.
  IT_ACCOUNTPAYABLE-DSCT_PCT1  = ZTITCSK-ZBD1P.
  IT_ACCOUNTPAYABLE-DSCT_PCT2  = ZTITCSK-ZBD2P.
  IT_ACCOUNTPAYABLE-PYMT_METH  = ZTITCSK-ZLSCH.
  IT_ACCOUNTPAYABLE-PMTMTHSUPL = ZTITCSK-UZAWE.
  IT_ACCOUNTPAYABLE-PMNT_BLOCK = ZTITCSK-ZLSPR.
* it_accountpayable-scbank_ind
* it_accountpayable-supcountry
* it_accountpayable-supcountry_iso
* it_accountpayable-bllsrv_ind
* it_accountpayable-alloc_nmbr
  IT_ACCOUNTPAYABLE-ITEM_TEXT  = IT_ZTISCSDT-SGTXT.
  IT_ACCOUNTPAYABLE-ALLOC_NMBR = IT_ZTISCSDT-ZUONR.
* it_accountpayable-po_sub_no
* it_accountpayable-po_checkdg
* it_accountpayable-po_ref_no
* it_accountpayable-w_tax_code
  IT_ACCOUNTPAYABLE-BUSINESSPLACE = IT_ZTISCSDT-BUPLA.
* it_accountpayable-sectioncode
* it_accountpayable-instr1
* it_accountpayable-instr2
* it_accountpayable-instr3
* it_accountpayable-instr4
* it_accountpayable-branch
* it_accountpayable-pymt_cur
* it_accountpayable-pymt_amt
* it_accountpayable-pymt_cur_iso
* it_accountpayable-sp_gl_ind

  APPEND IT_ACCOUNTPAYABLE.

ENDFORM.                    "fill_account_accountap

*---------------------------------------------------------------------*
*       FORM fill_account_tax
*---------------------------------------------------------------------*
FORM FILL_ACCOUNT_ACCOUNTTAX.

  CLEAR IT_ACCOUNTTAX.
  IT_ACCOUNTTAX-ITEMNO_ACC = IT_ZTISCSDT-BUZEI.
*  it_accounttax-gl_account = it_ztiscsdt-saknr.
  "CCM : 2023.04.12  ZITCS4HDEV04 - MATNR과 관련 없음 (확인 완료)
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = IT_ZTISCSDT-SAKNR
    IMPORTING
      OUTPUT = IT_ACCOUNTTAX-GL_ACCOUNT.


  IT_ACCOUNTTAX-TAX_CODE   = IT_ZTISCSDT-MWSKZ.
*  it_accounttax-acct_key   = 'VST'.
* IT_ACCOUNTTAX-TAXJURCODE =
* it_accounttax-cond_key   =
* IT_ACCOUNTTAX-TAX_RATE   =
* IT_ACCOUNTTAX-TAX_DATE   =
* IT_ACCOUNTTAX-STAT_CON   =
* IT_ACCOUNTTAX-taxjurcode_deep
* IT_ACCOUNTTAX-taxjurcode_level
  APPEND IT_ACCOUNTTAX.

ENDFORM.                    "fill_account_accounttax

*---------------------------------------------------------------------*
*       FORM fill_account_currencyamount
*---------------------------------------------------------------------*
FORM FILL_ACCOUNT_CURRENCYAMOUNT.

  CLEAR IT_CURRENCYAMOUNT.

  IT_CURRENCYAMOUNT-ITEMNO_ACC   = IT_ZTISCSDT-BUZEI.
  IT_CURRENCYAMOUNT-CURR_TYPE    = '00'.   ">전표통화.
  IT_CURRENCYAMOUNT-CURRENCY     = ZTITCSK-WAERS.
*>> Get CURRENCY ISO CODE.
  SELECT SINGLE *
    FROM TCURC
   WHERE WAERS EQ ZTITCSK-WAERS.
  IF SY-SUBRC EQ 0.
    MOVE TCURC-ISOCD   TO  IT_CURRENCYAMOUNT-CURRENCY_ISO. "ISO 통화코드
  ENDIF.

  IF ZTITCSK-WAERS NE T001-WAERS.
    MOVE  ZTITCSK-KURSF TO  IT_CURRENCYAMOUNT-EXCH_RATE. "직접호가환율
  ENDIF.

**> 총송장금액.
*  IF it_ztiscsdt-shkzg EQ 'H'.
*    it_ztiscsdt-wrbtr = it_ztiscsdt-wrbtr * -1.
*    it_ztiscsdt-fwbas = it_ztiscsdt-fwbas * -1.
*  ENDIF.
*> 총송장금액.
  IF ZTITCSK-VORGANG EQ '1' OR
     ZTITCSK-VORGANG EQ '3'.
    IF IT_ZTISCSDT-SHKZG EQ 'H'.
      IT_ZTISCSDT-WRBTR = IT_ZTISCSDT-WRBTR * -1.
      IT_ZTISCSDT-FWBAS = IT_ZTISCSDT-FWBAS * -1.
    ENDIF.
  ELSE.
    IF IT_ZTISCSDT-SHKZG EQ 'S'.
      IT_ZTISCSDT-WRBTR = IT_ZTISCSDT-WRBTR * -1.
      IT_ZTISCSDT-FWBAS = IT_ZTISCSDT-FWBAS * -1.
    ENDIF.
  ENDIF.

  WRITE IT_ZTISCSDT-WRBTR TO G_TEXT_AMOUNT CURRENCY ZTITCSK-WAERS.
  PERFORM  SET_WRITE_NO_MASK     CHANGING  G_TEXT_AMOUNT.
  MOVE  G_TEXT_AMOUNT  TO  IT_CURRENCYAMOUNT-AMT_DOCCUR."금액

  IF NOT IT_ZTISCSDT-WMWST IS INITIAL.
    WRITE IT_ZTISCSDT-FWBAS TO G_TEXT_AMOUNT CURRENCY ZTITCSK-WAERS.
    PERFORM  SET_WRITE_NO_MASK     CHANGING  G_TEXT_AMOUNT.
    MOVE  G_TEXT_AMOUNT  TO  IT_CURRENCYAMOUNT-AMT_BASE."금액
  ENDIF.

* IT_CURRENCYAMOUNT-DISC_BASE    =
* it_currencyamount-exch_rate_v  =
* it_currencyamount-disc_amt     =
  APPEND IT_CURRENCYAMOUNT.

ENDFORM.                    "fill_account_currencyamount

*---------------------------------------------------------------------*
*       FORM fill_account_criteria
*---------------------------------------------------------------------*
FORM FILL_ACCOUNT_CRITERIA  USING P_ITEMNO
                                  P_FIELDNAME
                                  P_CARACTER.

  CLEAR IT_CRITERIA.
  IT_CRITERIA-ITEMNO_ACC = P_ITEMNO.
  IT_CRITERIA-FIELDNAME  = P_FIELDNAME.
  IT_CRITERIA-CHARACTER  = P_CARACTER.
  APPEND IT_CRITERIA.

ENDFORM.                    "fill_account_criteria

*---------------------------------------------------------------------*
*       FORM fill_account_valuefield
*---------------------------------------------------------------------*
FORM FILL_ACCOUNT_VALUEFIELD.

* CLEAR it_valuefield.
* it_valuefield-itemno_acc = 2.
* it_valuefield-fieldname = 'VV010'.
* it_valuefield-curr_type
* it_valuefield-currency = 'EUR'.
* it_valuefield-currency_iso
* it_valuefield-amt_valcom
* it_valuefield-base_uom
* it_valuefield-base_uom_iso
* it_valuefield-qua_valcom
* append it_valuefield.

ENDFORM.                    "fill_account_valuefield

*---------------------------------------------------------------------*
*       FORM fill_account_extension                                   *
*---------------------------------------------------------------------*
FORM FILL_ACCOUNT_EXTENSION.

* CLEAR it_ext.
* it_ext-field1
* it_ext-field2
* it_ext-field3
* it_ext-field4
* APPEND it_ext.

* DATA: ls_zzz TYPE ZZZ_ACCIT.
* CLEAR it_ext2.
* it_ext2-structure = 'ZZZ_ACCIT'.
*  ls_zzz-posnr = 2.
*  ls_zzz-awref_reb = '123654'.
*  ls_zzz-aworg_reb = '654654'.
*  ls_zzz-grant_nbr = '0022002'.
* MOVE ls_zzz TO it_ext2-valuepart1.
* APPEND it_ext2.

ENDFORM.                    "fill_account_extension

*---------------------------------------------------------------------*
*       FORM fill_account_paymentcard                                 *
*---------------------------------------------------------------------*
FORM FILL_ACCOUNT_PAYMENTCARD.

*  CLEAR it_paymentcard.
*  it_paymentcard-itemno_acc = 1.
*  it_paymentcard-cc_glaccount
*  it_paymentcard-cc_type
*  it_paymentcard-cc_number
*  it_paymentcard-cc_seq_no
*  it_paymentcard-cc_valid_f
*  it_paymentcard-cc_valid_t
*  it_paymentcard-cc_name
*  it_paymentcard-dataorigin
*  it_paymentcard-authamount = '100'.
*  it_paymentcard-currency = 'EUR'.
*  it_paymentcard-currency_iso
*  it_paymentcard-cc_autth_no
*  it_paymentcard-auth_refno
*  it_paymentcard-auth_date
*  it_paymentcard-auth_time
*  it_paymentcard-merchidcl
*  it_paymentcard-point_of_receipt
*  it_paymentcard-terminal
*  it_paymentcard-cctyp = '1'.
*  APPEND it_paymentcard.

ENDFORM.                    "fill_account_paymentcard

*---------------------------------------------------------------------*
*       FORM fill_account_contractitem                                *
*---------------------------------------------------------------------*
FORM FILL_ACCOUNT_CONTRACTITEM.

* CLEAR it_fica_it.
*  it_fica_it-itemno_acc
*  it_fica_it-cont_acct
*  it_fica_it-main_trans
*  it_fica_it-sub_trans
*  it_fica_it-func_area
*  it_fica_it-fm_area
*  it_fica_it-cmmt_item
*  it_fica_it-funds_ctr
*  it_fica_it-fund
* append it_fica_it.

ENDFORM.                    "fill_account_contractitem

*&---------------------------------------------------------------------*
*&      Form  fill_account_re
*&---------------------------------------------------------------------*
FORM FILL_ACCOUNT_RE .

*  CLEAR it_re.
*  it_re-itemno_acc      =
*  it_re-business_entity =
*  it_re-building        =
*  it_re-property        =
*  it_re-rental_object   =
*  it_re-serv_charge_key =
*  it_re-settlement_unit =
*  it_re-contract_no     =
*  APPEND it_re.
*

ENDFORM.                    "fill_account_re
*&---------------------------------------------------------------------*
*&      Form  check_document_status
*&---------------------------------------------------------------------*
*       문서 전기 상태 체크.
*----------------------------------------------------------------------*
FORM CHECK_DOCUMENT_STATUS .

  DATA: L_DDTEXT LIKE G_DDTEXT.

*> 문서상태 Fixed value read.
  PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTILIVST'
                                             SY-LANGU
                                             ZTITCSK-LIVST
                                             G_DDTEXT
                                             C_SUCCESS.
  L_DDTEXT = G_DDTEXT.

*> Status check.
  CASE ZTITCSK-LIVST.
    WHEN C_CHARN.  ">전기대상.
      IF G_MODE EQ C_CHARR.
        MESSAGE E919 WITH G_DDTEXT.
      ENDIF.
    WHEN C_CHARP.  ">전기완료.
      IF G_MODE EQ C_CHARA OR
         G_MODE EQ C_CHARM OR
         G_MODE EQ C_CHARD.
        MESSAGE E919 WITH G_DDTEXT.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.

  MESSAGE S922 WITH L_DDTEXT.

ENDFORM.                    " check_document_status
*&---------------------------------------------------------------------*
*&      Form  set_tree_chosen_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_TREE_CHOSEN_ITEM .

ENDFORM.                    " set_tree_chosen_item
*&---------------------------------------------------------------------*
*&      Module  help_expense_cost  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HELP_EXPENSE_COST INPUT.

  LOOP AT SCREEN.
    IF SCREEN-NAME EQ 'ZTISCSIT-EXPCD'.
      EXIT.
    ENDIF.
  ENDLOOP.

  PERFORM GET_F4_FOR_EXPCD_DYNPRO USING ZTITCSK-BUKRS
                                        ZTITCSK-EXPGR
                                       'ZTISCSIT-EXPCD'.

ENDMODULE.                 " help_expense_cost  INPUT
*&---------------------------------------------------------------------*
*&      Form  get_f4_for_expcd_dynpro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_F4_FOR_EXPCD_DYNPRO USING P_BUKRS
                                   P_EXPGR
                                   P_EXPCD TYPE  HELP_INFO-DYNPROFLD.

  IF SCREEN-INPUT EQ '1'.
    CLEAR : G_DISPLAY.
  ELSE.
    G_DISPLAY = 'X'.
  ENDIF.

  PERFORM GET_DOMAIN_VALUE_TEXT USING 'ZTIEXPGR'
                                      ZTITCSK-EXPGR
                                      G_DDTEXT.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE IT_ZTITIG06
    FROM ZTITIG06
   WHERE BUKRS   EQ   P_BUKRS
     AND EXPGR   EQ   P_EXPGR.

  IF SY-SUBRC NE 0.

    MESSAGE S861 WITH P_BUKRS G_DDTEXT.
    EXIT.
  ENDIF.

  DYNPROG = SY-REPID.
  DYNNR   = SY-DYNNR.

*  WINDOW_TITLE = DD07T-DDTEXT.
  CONCATENATE G_DDTEXT '코드 HELP' INTO G_WINDOW_TITLE
              SEPARATED BY SPACE.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     RETFIELD        = 'OTYPE'
      RETFIELD        = 'EXPCD'
      DYNPPROG        = DYNPROG
      DYNPNR          = DYNNR
      DYNPROFIELD     = P_EXPCD
      WINDOW_TITLE    = G_WINDOW_TITLE
      VALUE_ORG       = 'S'
      DISPLAY         = G_DISPLAY
    TABLES
      VALUE_TAB       = IT_ZTITIG06
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.

ENDFORM.                    " get_f4_for_expcd_dynpro
*&---------------------------------------------------------------------*
*&      Form  get_request_of_import
*&---------------------------------------------------------------------*
*       text
*&---------------------------------------------------------------------*
FORM GET_REQUEST_OF_IMPORT        USING    P_REQNO
                                           P_AMDSQ
                                           P_DOCNM
                                           P_ZTIVRQ04 LIKE ZTIVRQ04.

  CLEAR: P_DOCNM, P_AMDSQ, P_ZTIVRQ04.

  SELECT SINGLE *
    INTO P_ZTIVRQ04
    FROM ZTIVRQ04
   WHERE REQNO  EQ P_REQNO.

  IF SY-SUBRC NE 0.
    MESSAGE E108 WITH P_REQNO.
  ENDIF.

  P_AMDSQ = P_ZTIVRQ04-AMDSQ.

  IF P_ZTIVRQ04-OPNNO IS INITIAL.
    CONCATENATE P_ZTIVRQ04-REQNO '-' P_ZTIVRQ04-AMDSQ INTO P_DOCNM.
  ELSE.
    P_DOCNM = P_ZTIVRQ04-OPNNO.
  ENDIF.

ENDFORM.                    " get_request_of_import
*&---------------------------------------------------------------------*
*&      Form  get_insurance_document_no
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_INSURANCE_DOCUMENT_NO  USING    P_IIPNO
                                         P_AMDSQ
                                         P_DOCNM
                                         P_ZTITIP1 LIKE ZTITIP1.
  CLEAR: P_DOCNM, P_ZTITIP1.

  SELECT SINGLE *
    INTO P_ZTITIP1
    FROM ZTITIP1
   WHERE IIPNO  EQ P_IIPNO
     AND AMDSQ  EQ P_AMDSQ.

  IF SY-SUBRC NE 0.
    MESSAGE E156 WITH P_IIPNO.
  ENDIF.

  IF P_ZTITIP1-ISPNO IS INITIAL.
    CONCATENATE P_ZTITIP1-IIPNO '-' P_ZTITIP1-AMDSQ INTO P_DOCNM.
  ELSE.
    P_DOCNM = P_ZTITIP1-ISPNO.
  ENDIF.

ENDFORM.                    " get_insurance_document_no
*&---------------------------------------------------------------------*
*&      Form  get_bl_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_BL_NUMBER  USING    P_IBLNO
                             P_DOCNM
                             P_ZTITBLK  LIKE ZTITBLK.

  CLEAR: P_DOCNM, P_ZTITBLK.

  SELECT SINGLE *
    INTO P_ZTITBLK
    FROM ZTITBLK
   WHERE IBLNO  EQ P_IBLNO.

  IF SY-SUBRC NE 0.
    MESSAGE E207 WITH P_IBLNO.
  ENDIF.

  IF P_ZTITBLK-BLNUM IS INITIAL.
    CONCATENATE '관리번호:' P_ZTITBLK-IBLNO INTO P_DOCNM.
  ELSE.
    P_DOCNM = P_ZTITBLK-BLNUM.
  ENDIF.

ENDFORM.                    " get_bl_number
*&---------------------------------------------------------------------*
*&      Form  get_custom_clearance
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_CUSTOM_CLEARANCE  USING    P_ICCNO
                                    P_DOCNM
                                    P_ZTITCCK LIKE ZTITCCK.
  CLEAR: P_DOCNM, P_ZTITCCK.

  SELECT SINGLE *
    INTO P_ZTITCCK
    FROM ZTITCCK
   WHERE ICCNO  EQ P_ICCNO.

  IF SY-SUBRC NE 0.
    MESSAGE E400 WITH P_ICCNO.
  ENDIF.

  IF P_ZTITCCK-CDCNO IS INITIAL.
    CONCATENATE '관리번호:' P_ZTITCCK-ICCNO INTO P_DOCNM.
  ELSE.
    P_DOCNM = P_ZTITCCK-CDCNO.
  ENDIF.


ENDFORM.                    " get_custom_clearance
*&---------------------------------------------------------------------*
*&      Form  SUMMARY_INVOICE_AMOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SUMMARY_INVOICE_AMOUNT  USING    P_MSGTY.

  DATA: BEGIN OF LT_CSCTY OCCURS 1,
          CSCTY TYPE ZTICSCTY,
        END   OF LT_CSCTY,

        LV_WMWST   LIKE  G_ZTITCSK-WMWST,  "외화부가세
        LV_WMWST_T LIKE  G_ZTITCSK-WMWST.  "외화부가세


  CLEAR: G_ZTITCSK,
         LV_WMWST , LV_WMWST_T.

*- 2021.12.01 스크린 사이즈에 따른 아이템의 환율변동 제한수정
*  BY 송승규     -[s]
  IF ZTITCSK-WAERS NE ZTITCSK-HWAER.
    LOOP AT IT_TAB INTO ZTISCSIT.
      CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
        EXPORTING
          DATE             = ZTITCSK-WWERT
          FOREIGN_AMOUNT   = ZTISCSIT-WRBTR
          FOREIGN_CURRENCY = ZTITCSK-WAERS
          LOCAL_CURRENCY   = ZTITCSK-HWAER
          RATE             = ZTITCSK-KURSF
        IMPORTING
          EXCHANGE_RATE    = G_TEXT_EXRATE
          FOREIGN_FACTOR   = G_FOREIGN_FACTOR
          LOCAL_AMOUNT     = ZTISCSIT-DMBTR
          FIXED_RATE       = G_FIXED_RATE
        EXCEPTIONS
          OTHERS           = 01.


      CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
        EXPORTING
          DATE             = ZTITCSK-WWERT
          FOREIGN_AMOUNT   = ZTISCSIT-WMWST
          FOREIGN_CURRENCY = ZTITCSK-WAERS
          LOCAL_CURRENCY   = ZTITCSK-HWAER
          RATE             = ZTITCSK-KURSF
        IMPORTING
          EXCHANGE_RATE    = G_TEXT_EXRATE
          FOREIGN_FACTOR   = G_FOREIGN_FACTOR
          LOCAL_AMOUNT     = LV_WMWST
          FIXED_RATE       = G_FIXED_RATE
        EXCEPTIONS
          OTHERS           = 01.

      LV_WMWST_T = LV_WMWST_T + LV_WMWST.
      MODIFY IT_TAB FROM ZTISCSIT TRANSPORTING DMBTR.
    ENDLOOP.
  ENDIF.
*- 2021.12.01 스크린 사이즈에 따른 아이템의 환율변동 제한수정
*  BY 송승규     -[e]




*----  >>  Begin of Loop.
  LOOP AT IT_TAB INTO G_TC_2130_WA.
    ADD G_TC_2130_WA-WRBTR TO G_ZTITCSK-WRBTR.
    ADD G_TC_2130_WA-DMBTR TO G_ZTITCSK-DMBTR.
    ADD G_TC_2130_WA-FWBAS TO G_ZTITCSK-FWBAS.
    ADD G_TC_2130_WA-WMWST TO G_ZTITCSK-WMWST.
    LT_CSCTY-CSCTY = G_TC_2130_WA-CSCTY.
    IF LT_CSCTY-CSCTY EQ C_CHARU.
      LT_CSCTY-CSCTY = C_CHARP.
    ENDIF.
    COLLECT LT_CSCTY.
  ENDLOOP.
*----  >>  End of Loop.

  DESCRIBE TABLE LT_CSCTY LINES G_LINE.
  IF G_LINE EQ 1.
*    READ TABLE lt_cscty INDEX 1.
*    IF sy-subrc EQ 0.
*      IF lt_cscty-cscty EQ c_charf.
*        ztitcsk-ptdcl = c_charf.
*      ELSEIF lt_cscty-cscty EQ c_charv.
*        ztitcsk-ptdcl = c_charv.
*      ELSE.
*        ztitcsk-ptdcl = c_charm.
*      ENDIF.
*    ENDIF.
  ELSEIF G_LINE EQ 0.
    ZTITCSK-PTDCL = C_CHARF.
  ELSE.
    MESSAGE I881.
    CLEAR ZTITCSK-PTDCL.
  ENDIF.

  G_ZTITCSK-WRBTR = G_ZTITCSK-WRBTR + G_ZTITCSK-WMWST.

*- 2021.12.09 외화 부가세 금액 계산
  IF LV_WMWST_T  IS INITIAL.   "외화가 아닌경우
    G_ZTITCSK-DMBTR = G_ZTITCSK-DMBTR + G_ZTITCSK-WMWST.
  ELSE.
    G_ZTITCSK-DMBTR = G_ZTITCSK-DMBTR + LV_WMWST_T.
  ENDIF.

*> 메시지를 출력할 경우.
  IF P_MSGTY NE C_NONE.
    IF G_ZTITCSK-WRBTR NE ZTITCSK-WRBTR.
      ZTITCSK-WRBTR = G_ZTITCSK-WRBTR.
      MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 863.
    ENDIF.
  ENDIF.

  IF G_MODE EQ C_CHARC OR
     G_MODE EQ C_CHARM.
    ZTITCSK-WRBTR = G_ZTITCSK-WRBTR.
    ZTITCSK-WMWST = G_ZTITCSK-WMWST.
    ZTITCSK-DMBTR = G_ZTITCSK-DMBTR.
    ZTITCSK-FWBAS = G_ZTITCSK-FWBAS.
  ENDIF.

ENDFORM.                    " SUMMARY_INVOICE_AMOUNT
*&---------------------------------------------------------------------*
*&      Form  fill_vat_internal_table
*&---------------------------------------------------------------------*
*       부가세 기표시.
*----------------------------------------------------------------------*
FORM FILL_VAT_INTERNAL_TABLE .

  DATA: L_NEWBS  LIKE RF05A-NEWBS.

* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

  REFRESH: BDCDATA.
*> 초기화면.
  READ TABLE IT_ZTISCSDT INDEX 1.

  WRITE IT_ZTISCSDT-WRBTR TO G_TEXT_AMT1 CURRENCY ZTITCSK-WAERS.
  PERFORM  SET_WRITE_NO_MASK     CHANGING  G_TEXT_AMT1.
  MOVE  G_TEXT_AMT1  TO  IT_CURRENCYAMOUNT-AMT_DOCCUR."금액

  IF ZTITCSK-VORGANG EQ '1' OR
     ZTITCSK-VORGANG EQ '3'.
    L_NEWBS = '31'.
  ELSE.
    L_NEWBS = '21'.
  ENDIF.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPMF05A'          '0100',
         ' ' 'BKPF-BLDAT'        ZTITCSK-BLDAT,
         ' ' 'BKPF-BLART'        ZTITCSK-BLART,
         ' ' 'BKPF-BUKRS'        ZTITCSK-BUKRS,
         ' ' 'BKPF-BUDAT'        ZTITCSK-BUDAT,
         ' ' 'BKPF-MONAT'        ZTITCSK-MONAT,
         ' ' 'BKPF-WAERS'        ZTITCSK-WAERS,
         ' ' 'BKPF-XBLNR'        ZTITCSK-XBLNR,
         ' ' 'BKPF-BKTXT'        ZTITCSK-BKTXT,
*         ' ' 'RF05A-NEWBS'       it_ztiscsdt-bschl,
         ' ' 'RF05A-NEWBS'       L_NEWBS,
         ' ' 'RF05A-NEWKO'       ZTITCSK-LIFNR,
         ' ' 'BDC_OKCODE'       '/00'.

*> 일회성 계정.
  IF NOT ZTITCSK-XCPDK IS INITIAL.
    PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPLFCPD'          '0100',
         ' ' 'BSEC-ANRED'        ZTITCSO-FORM_OF_ADDR,
         ' ' 'BSEC-NAME1'        ZTITCSO-NAME,
         ' ' 'BSEC-NAME2'        ZTITCSO-NAME_2,
         ' ' 'BSEC-NAME3'        ZTITCSO-NAME_3,
         ' ' 'BSEC-NAME4'        ZTITCSO-NAME_4,
         ' ' 'BSEC-STRAS'        ZTITCSO-STREET,
         ' ' 'BSEC-PFACH'        ZTITCSO-PO_BOX,
         ' ' 'BSEC-PSTL2'        ZTITCSO-POBX_PCD,
         ' ' 'BSEC-ORT01'        ZTITCSO-CITY,
         ' ' 'BSEC-PSTLZ'        ZTITCSO-POSTL_CODE,
         ' ' 'BSEC-LAND1'        ZTITCSO-COUNTRY,
         ' ' 'BSEC-REGIO'        ZTITCSO-REGION,
         ' ' 'BSEC-BANKL'        ZTITCSO-BANK_NO,
         ' ' 'BSEC-BANKS'        ZTITCSO-BANK_CTRY,
         ' ' 'BSEC-BANKN'        ZTITCSO-BANK_ACCT,
         ' ' 'BSEC-BKONT'        ZTITCSO-CTRL_KEY,
         ' ' 'BSEC-BKREF'        ZTITCSO-BANK_REF,
         ' ' 'BSEC-DTAWS'        ZTITCSO-INSTR_KEY,
         ' ' 'BSEC-DTAMS'        ZTITCSO-DME_IND,
*         ' ' 'BSEG-STCEG'
         ' ' 'BSEC-STCD1'        ZTITCSO-TAX_NO_1,
         ' ' 'BSEC-FITYP'        ZTITCSO-TAX_CATEGORY,
         ' ' 'BSEC-STCD2'        ZTITCSO-TAX_NO_2,
         ' ' 'BSEC-STCDT'        ZTITCSO-TAX_NO_TY,
         ' ' 'BSEC-STCD3'        ZTITCSO-TAX_NO_3,
         ' ' 'BSEC-STKZN'        ZTITCSO-SOLE_PROP,
         ' ' 'BSEC-STCD4'        ZTITCSO-TAX_NO_4,
         ' ' 'BSEC-STKZA'        ZTITCSO-EQUAL_TAX,
         ' ' 'BSEC-J_1KFTBUS'    ZTITCSO-BUS_TYPE,
         ' ' 'BSEC-STKZU'        ZTITCSO-SLS_PUR_TX,
         ' ' 'BSEC-J_1KFTIND'    ZTITCSO-IND_TYPE,
         ' ' 'BSEC-J_1KFREPRE'   ZTITCSO-REP_NAME,
         ' ' 'BDC_OKCODE'        '/00'.
  ENDIF.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPMF05A'          '0302',
*         ' ' 'BSEG-HKONT'        it_ztiscsdt-saknr,
         ' ' 'BSEG-WRBTR'        G_TEXT_AMT1,
         ' ' 'BSEG-MWSKZ'        IT_ZTISCSDT-MWSKZ,
         ' ' 'BSEG-BUPLA'        IT_ZTISCSDT-BUPLA,
         ' ' 'BSEG-GSBER'        IT_ZTISCSDT-GSBER,
         ' ' 'BSEG-ZTERM'        ZTITCSK-ZTERM,
         ' ' 'BSEG-ZFBDT'        ZTITCSK-ZFBDT,
         ' ' 'BSEG-ZLSPR'        ZTITCSK-ZLSPR,
         ' ' 'BSEG-ZLSCH'        ZTITCSK-ZLSCH,
         ' ' 'BSEG-ZUONR'        IT_ZTISCSDT-ZUONR,
         ' ' 'BSEG-SGTXT'        IT_ZTISCSDT-SGTXT.

  IF NOT ZTITCSK-EMPFK IS INITIAL.
    PERFORM BDC_DYNPRO_BUILD USING :
           ' ' 'BSEG-EMPFB'        ZTITCSK-EMPFK.
  ENDIF.

  IF ZTITCSK-VORGANG EQ '1' OR
     ZTITCSK-VORGANG EQ '3'.
    L_NEWBS = '40'.
  ELSE.
    L_NEWBS = '50'.
  ENDIF.


  READ TABLE IT_ZTISCSDT INDEX 2.
  PERFORM BDC_DYNPRO_BUILD USING :
*         ' ' 'RF05A-NEWBS'       it_ztiscsdt-bschl,
         ' ' 'RF05A-NEWBS'       L_NEWBS,
         ' ' 'RF05A-NEWKO'       IT_ZTISCSDT-SAKNR,
         ' ' 'BDC_OKCODE'       '/00'.

*> 부가세 화면.
  WRITE IT_ZTISCSDT-WRBTR TO G_TEXT_AMT1 CURRENCY ZTITCSK-WAERS.
  PERFORM  SET_WRITE_NO_MASK     CHANGING  G_TEXT_AMT1.
  MOVE  G_TEXT_AMT1  TO  IT_CURRENCYAMOUNT-AMT_DOCCUR."금액

  IF NOT IT_ZTISCSDT-FWBAS IS INITIAL.
    WRITE IT_ZTISCSDT-FWBAS TO G_TEXT_AMT2 CURRENCY ZTITCSK-WAERS.
    PERFORM  SET_WRITE_NO_MASK     CHANGING  G_TEXT_AMT2.
    MOVE  G_TEXT_AMT2  TO  IT_CURRENCYAMOUNT-AMT_BASE."금액
  ENDIF.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPMF05A'          '0312',
         ' ' 'BSEG-WRBTR'        G_TEXT_AMT1,
         ' ' 'BSEG-FWBAS'        G_TEXT_AMT2,
         ' ' 'BSEG-MWSKZ'        IT_ZTISCSDT-MWSKZ,
         ' ' 'BSEG-BUPLA'        IT_ZTISCSDT-BUPLA,
         ' ' 'BSEG-GSBER'        IT_ZTISCSDT-GSBER,
         ' ' 'BSEG-ZUONR'        IT_ZTISCSDT-ZUONR,
         ' ' 'BSEG-SGTXT'        IT_ZTISCSDT-SGTXT.

  PERFORM BDC_DYNPRO_BUILD USING :
           ' ' 'BDC_OKCODE'       '=BS'.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPMF05A'          '0700',
         ' ' 'BDC_OKCODE'        '=BU'.

ENDFORM.                    " fill_vat_internal_table
*&---------------------------------------------------------------------*
*&      Form  scr2123_fieldcat_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SCR2123_FIELDCAT_BUILD .

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME = 'ZTISCSHS'
    CHANGING
      CT_FIELDCAT      = IT_FIELDCAT_LVC[].

  LOOP AT IT_FIELDCAT_LVC.
    CASE IT_FIELDCAT_LVC-FIELDNAME.
      WHEN 'BLDAT' OR 'BUDAT' OR 'IVSEQ' OR 'RBLGP'.
        IT_FIELDCAT_LVC-KEY     = C_TRUE.
      WHEN 'BELNR' OR 'GJAHR'.
*        it_fieldcat_lvc-key     = c_true.
        IT_FIELDCAT_LVC-HOTSPOT = C_TRUE.
      WHEN 'CBELNR' OR 'CGJAHR'.
        IT_FIELDCAT_LVC-HOTSPOT = C_TRUE.
      WHEN 'ICSNO' OR 'FLAG' OR 'BUKRS' OR 'VORGANG' OR 'SHKZG'.
        IT_FIELDCAT_LVC-NO_OUT  = C_TRUE.
      WHEN OTHERS.
    ENDCASE.
    MODIFY IT_FIELDCAT_LVC.
  ENDLOOP.

ENDFORM.                    " scr2123_fieldcat_build
*&---------------------------------------------------------------------*
*&      Form  handle_double_click
*&---------------------------------------------------------------------*
FORM HANDLE_DOUBLE_CLICK  USING  P_ROW P_COLUMN.

  IF NOT G_SCR7000_CONTAINER IS INITIAL.
    READ TABLE IT_ZTISCSDTY INDEX P_ROW.
    CHECK SY-SUBRC = 0.
    PERFORM DISPLAY_PURCHASE_ORDER
                USING  IT_ZTISCSDTY-EBELN IT_ZTISCSDTY-EBELP.

  ELSE.
    READ TABLE IT_ZTISCSHS INDEX P_ROW.

    CHECK SY-SUBRC = 0.

    CASE P_COLUMN.
      WHEN 'CBELNR' OR 'CGJAHR' OR 'CBUDAT'.
        IF NOT IT_ZTISCSHS-CBELNR IS INITIAL.
          PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTISCSHS-CBELNR
                                              IT_ZTISCSHS-CGJAHR
                                              ZTITCSK-BUKRS.
        ENDIF.
      WHEN OTHERS.
        IF NOT IT_ZTISCSHS-BELNR IS INITIAL.
          PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTISCSHS-BELNR
                                              IT_ZTISCSHS-GJAHR
                                              ZTITCSK-BUKRS.
        ENDIF.
    ENDCASE.
  ENDIF.

ENDFORM.                    "handle_double_click
*&---------------------------------------------------------------------*
*&      Form  handle_hotspot_click
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK  USING E_ROW_ID    TYPE LVC_S_ROW
                                 E_COLUMN_ID TYPE LVC_S_COL.

  READ TABLE IT_ZTISCSHS INDEX E_ROW_ID-INDEX.

  CHECK SY-SUBRC = 0.

  CASE E_COLUMN_ID-FIELDNAME.
    WHEN 'CBELNR' OR 'CGJAHR' OR 'CBUDAT'.
      IF NOT IT_ZTISCSHS-CBELNR IS INITIAL.
        PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTISCSHS-CBELNR
                                            IT_ZTISCSHS-CGJAHR
                                            ZTITCSK-BUKRS.
      ENDIF.
    WHEN OTHERS.
      IF NOT IT_ZTISCSHS-BELNR IS INITIAL.
        PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTISCSHS-BELNR
                                            IT_ZTISCSHS-GJAHR
                                            ZTITCSK-BUKRS.
      ENDIF.
  ENDCASE.

ENDFORM.                    " handle_hotspot_click
*&---------------------------------------------------------------------*
*&      Module  pbo_scr7000_set_grid  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR7000_SET_GRID OUTPUT.

  IF OK_CODE EQ 'ZTISELECT'.
    SET PF-STATUS '6010'.
  ELSE.
    REFRESH EXCL.
    IF OK_CODE EQ 'ZTIDSTR'.
      MOVE FCOBU TO EXCL-FUNKTION.   APPEND  EXCL.
    ENDIF.
    SET PF-STATUS '6000' EXCLUDING EXCL.
  ENDIF.

  IF G_SCR7000_CONTAINER IS INITIAL.

*> FIELD CATALLOG BUILD
    PERFORM SCR7000_FIELDCAT_BUILD.

* create a custom container control for our ALV Control
    CREATE OBJECT G_SCR7000_CONTAINER
      EXPORTING
        CONTAINER_NAME = 'SCR7000_CONTAINER'.

* create an instance of alv control
    CREATE OBJECT G_SCR7000_GRID
      EXPORTING
        I_PARENT = G_SCR7000_CONTAINER.
*> Set grid handler
*-. Event Receive.
    CREATE OBJECT EVENT_RECEIVER.

* Edit  이벤트 등록
    SET HANDLER :
        EVENT_RECEIVER->HANDLE_DOUBLE_CLICK         FOR G_SCR7000_GRID.
*        event_receiver->handle_hotspot_click        FOR g_scr7000_grid.
*
**
    CALL METHOD G_SCR7000_GRID->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        I_STRUCTURE_NAME = 'ZTISCSDT'
        I_SAVE           = G_VARIANT_SAVE
        IS_VARIANT       = G_VARIANT
        I_DEFAULT        = 'X'
      CHANGING
        IT_FIELDCATALOG  = IT_FIELDCAT_LVC_1[]
        IT_OUTTAB        = IT_ZTISCSDTY[].
  ELSE.

*> FIELD CATALLOG BUILD
    PERFORM SCR7000_FIELDCAT_BUILD.

*    CALL METHOD g_scr7000_grid->get_frontend_fieldcatalog
*      IMPORTING
*        et_fieldcatalog = it_fieldcat_lvc_1[].
*
    CALL METHOD G_SCR7000_GRID->GET_FRONTEND_LAYOUT
      IMPORTING
        ES_LAYOUT = GS_LAYOUT_ALV.

    CALL METHOD CL_GUI_CFW=>FLUSH.
*
    CALL METHOD G_SCR7000_GRID->SET_FRONTEND_FIELDCATALOG
      EXPORTING
        IT_FIELDCATALOG = IT_FIELDCAT_LVC_1[].

    CALL METHOD G_SCR7000_GRID->SET_FRONTEND_LAYOUT
      EXPORTING
        IS_LAYOUT = GS_LAYOUT_ALV.

    GS_STABLE-ROW = 'X'.
    GS_STABLE-COL = 'X'.
    CALL METHOD G_SCR7000_GRID->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = GS_STABLE.

  ENDIF.

ENDMODULE.                 " pbo_scr7000_set_grid  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  scr7000_fieldcat_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SCR7000_FIELDCAT_BUILD .

  REFRESH : IT_FIELDCAT_LVC_1.
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME = 'ZTISCSDT'
    CHANGING
      CT_FIELDCAT      = IT_FIELDCAT_LVC_1[].

  LOOP AT IT_FIELDCAT_LVC_1.
    CLEAR: IT_FIELDCAT_LVC_1-NO_OUT.
    IF ZTISCSIT-CSCRT EQ C_CHARF.
      CASE IT_FIELDCAT_LVC_1-FIELDNAME.
        WHEN 'MANDT' OR 'BUKRS' OR 'ICSNO' OR 'BUZEI' OR
             'ICSSQ' OR 'EXPGR' OR 'EXPCD' OR
             'KNUMV' OR 'STUNR' OR 'ZAEHK' OR 'KSCHL' OR
*             'MWSKZ' OR 'REFNO' OR 'REFIT' OR 'EBELN' OR
*             'EBELP' OR 'MENGE' OR 'MEINS' OR 'BPRME' OR
             'BPRME' OR
             'PEINH' OR 'DMBTR' OR 'TBTKZ' OR 'FLAG'.
          IT_FIELDCAT_LVC_1-NO_OUT  = C_TRUE.
          IT_FIELDCAT_LVC_1-COL_POS  = 0.
        WHEN 'KOART'.
          IT_FIELDCAT_LVC_1-COL_POS  = 1.
          IT_FIELDCAT_LVC_1-KEY  = C_TRUE.
        WHEN 'BSCHL'.
          IT_FIELDCAT_LVC_1-COL_POS  = 2.
          IT_FIELDCAT_LVC_1-KEY  = C_TRUE.
        WHEN 'SHKZG'.
          IT_FIELDCAT_LVC_1-COL_POS  = 3.
          IT_FIELDCAT_LVC_1-KEY  = C_TRUE.
        WHEN 'SAKNR'.
          IT_FIELDCAT_LVC_1-COL_POS  = 4.
          IT_FIELDCAT_LVC_1-KEY  = C_TRUE.
        WHEN 'MAKTX'.
          IT_FIELDCAT_LVC_1-COL_POS  = 5.
          IT_FIELDCAT_LVC_1-COL_OPT  = 'X'.
*          it_fieldcat_lvc_1-key  = c_true.
        WHEN 'WRBTR'.
          IT_FIELDCAT_LVC_1-COL_POS  = 6.
        WHEN 'MWMST'.
          IT_FIELDCAT_LVC_1-COL_POS  = 7.
        WHEN 'FWBAS'.
          IT_FIELDCAT_LVC_1-COL_POS  = 8.
        WHEN 'MWSKZ'.
          IT_FIELDCAT_LVC_1-COL_POS  = 9.
          IT_FIELDCAT_LVC_1-COL_OPT  = 'X'.
        WHEN 'WAERS'.
          IT_FIELDCAT_LVC_1-COL_POS  = 10.
          IT_FIELDCAT_LVC_1-COL_OPT  = 'X'.
        WHEN 'EBELN'.
          IT_FIELDCAT_LVC_1-COL_POS  = 20.
          IT_FIELDCAT_LVC_1-KEY  = C_TRUE.
        WHEN 'EBELP'.
          IT_FIELDCAT_LVC_1-COL_POS  = 21.
          IT_FIELDCAT_LVC_1-KEY  = C_TRUE.
        WHEN 'BUPLA'.
          IT_FIELDCAT_LVC_1-COL_POS  = 22.
          IT_FIELDCAT_LVC_1-COL_OPT  = 'X'.
        WHEN 'GSBER'.
          IT_FIELDCAT_LVC_1-COL_POS  = 23.
          IT_FIELDCAT_LVC_1-COL_OPT  = 'X'.
        WHEN 'ZUONR'.
          IT_FIELDCAT_LVC_1-COL_POS  = 35.
          IT_FIELDCAT_LVC_1-COL_OPT  = 'X'.
        WHEN 'SGTXT'.
          IT_FIELDCAT_LVC_1-COL_POS  = 36.
          IT_FIELDCAT_LVC_1-COL_OPT  = 'X'.
        WHEN OTHERS.
          IT_FIELDCAT_LVC_1-COL_POS  = 0.
          IT_FIELDCAT_LVC_1-NO_OUT  = C_TRUE.
      ENDCASE.
    ELSE.
      CASE IT_FIELDCAT_LVC_1-FIELDNAME.
        WHEN 'BLDAT' OR 'BUDAT' OR 'IVSEQ' OR 'RBLGP'.
          IT_FIELDCAT_LVC_1-KEY     = C_TRUE.
        WHEN 'BELNR' OR 'GJAHR'.
*        it_fieldcat_lvc-key     = c_true.
*          it_fieldcat_lvc_1-hotspot = c_true.
        WHEN 'CBELNR' OR 'CGJAHR'.
          IT_FIELDCAT_LVC_1-HOTSPOT = C_TRUE.
        WHEN 'ICSNO' OR 'FLAG'  OR 'BUKRS' OR 'VORGANG' OR 'SHKZG' OR
             'DMBTR' OR 'FWBAS' OR 'WMWST' OR 'MAKTX'.
          IT_FIELDCAT_LVC_1-NO_OUT  = C_TRUE.
        WHEN 'EBELN'.
          IT_FIELDCAT_LVC_1-COL_POS  = 1.
          IT_FIELDCAT_LVC_1-KEY  = C_TRUE.
        WHEN 'EBELP'.
          IT_FIELDCAT_LVC_1-COL_POS  = 2.
          IT_FIELDCAT_LVC_1-KEY  = C_TRUE.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.

    MODIFY IT_FIELDCAT_LVC_1.
  ENDLOOP.

ENDFORM.                    " scr7000_fieldcat_build
*&---------------------------------------------------------------------*
*&      Form  display_distribution
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_DISTRIBUTION  USING    P_ICSSQ.

  DATA: S_SKAT LIKE SKAT.

  REFRESH : IT_TABY,
            IT_ZTISCSDTY.
  CLEAR: OK-CODE.

  READ TABLE IT_TAB INTO G_TC_2130_WA WITH KEY ICSSQ = P_ICSSQ.

  IF SY-SUBRC NE 0.
    MESSAGE S903.
    EXIT.
  ENDIF.

  APPEND G_TC_2130_WA  TO IT_TABY.
  MOVE-CORRESPONDING G_TC_2130_WA TO ZTISCSIT.

  IF G_MODE EQ C_CHARC OR
     G_MODE EQ C_CHARM.
    CALL FUNCTION 'Z_TI_EXPENCES_DISTRIBUTION'
      EXPORTING
        XEXPGR             = ZTITCSK-EXPGR
      TABLES
        XZTISCSDT          = IT_ZTISCSDTY
        XZTISCSIT          = IT_TABY
      CHANGING
        XZTITCSK           = ZTITCSK
      EXCEPTIONS
        DISTRIBUTION_ERROR = 1
        OTHERS             = 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
    LOOP AT IT_ZTISCSDT WHERE ICSSQ = G_TC_2130_WA-ICSSQ.
      APPEND IT_ZTISCSDT TO IT_ZTISCSDTY.
    ENDLOOP.
  ENDIF.

  DESCRIBE TABLE IT_ZTISCSDTY LINES G_LINE.
  IF G_LINE EQ 0.
    MESSAGE S872.
  ELSE.
    LOOP AT IT_ZTISCSDTY.
      G_TABIX = SY-TABIX.
      IT_ZTISCSDTY-WAERS = ZTITCSK-WAERS.
      CASE IT_ZTISCSDTY-KOART.
        WHEN 'K'.
          IF NOT *LFA1-LIFNR IS INITIAL.
            MOVE *LFA1-NAME1 TO IT_ZTISCSDTY-MAKTX.
          ELSE.
            MOVE LFA1-NAME1 TO IT_ZTISCSDTY-MAKTX.
          ENDIF.
        WHEN 'M'.
*      LOOP AT ydrseg WHERE matnr = xaccit-matnr
*                     and   rblgp = xaccit-zeile.
*        MOVE ydrseg-txz01 TO abtab-maktx.
*        exit.
*      ENDLOOP.
          IF IT_ZTISCSDTY-EBELN IS INITIAL.
            CLEAR: IT_ZTISCSDTY-MAKTX.
          ELSE.
            SELECT SINGLE TXZ01 INTO IT_ZTISCSDTY-MAKTX
                   FROM   EKPO
                   WHERE  EBELN EQ IT_ZTISCSDTY-EBELN
                   AND    EBELP EQ IT_ZTISCSDTY-EBELP.
          ENDIF.

        WHEN OTHERS.
          CALL FUNCTION 'READ_HAUPTBUCH_AND_TEXT'
            EXPORTING
              SACHKONTO            = IT_ZTISCSDTY-SAKNR
              BUCHUNGSKREIS        = ZTITCSK-BUKRS
              SPRACHE              = SY-LANGU
            IMPORTING
              TEXT_WA              = S_SKAT
            EXCEPTIONS
              KONTENPLAN_NOT_FOUND = 4
              SACHKONTO_NOT_FOUND  = 8
              TEXT_NOT_FOUND       = 12.
          IF SY-SUBRC = 0.
            MOVE S_SKAT-TXT50 TO IT_ZTISCSDTY-MAKTX.
          ELSE.
            CLEAR: IT_ZTISCSDTY-MAKTX.
          ENDIF.
      ENDCASE.

      MODIFY IT_ZTISCSDTY INDEX G_TABIX.
    ENDLOOP.

    CALL SCREEN 7000 STARTING AT 1   1
                     ENDING   AT 108 20.
  ENDIF.
  CLEAR: ZTISCSIT.

ENDFORM.                    " display_distribution
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_REF_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_REF_DOCUMENT  USING    P_EXPGR
                                    P_REFNO
                                    P_AMDSQ.

  CHECK NOT P_REFNO IS INITIAL.

  CASE P_EXPGR.
    WHEN C_CHARL.
      SELECT SINGLE AMDSQ
        INTO ZTIVRQ04-AMDSQ
        FROM ZTIVRQ04
       WHERE REQNO   =   P_REFNO.
      IF SY-SUBRC EQ 0.
        PERFORM DISPLAY_IMPORT_DOCUMENT USING P_REFNO
                                              ZTIVRQ04-AMDSQ
                                              '00000'.
      ENDIF.
    WHEN C_CHARI.
      PERFORM DISPLAY_IP_DOCUMENT USING P_REFNO
                                        P_AMDSQ.
    WHEN C_CHARB.
      PERFORM DISPLAY_BL_DOCUMENT USING P_REFNO
                                        '00000'.
    WHEN C_CHARC.
      PERFORM DISPLAY_CC_DOCUMENT USING P_REFNO
                                        '00'.
  ENDCASE.

ENDFORM.                    " DISPLAY_REF_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  document_simulation_fi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOCUMENT_SIMULATION_FI USING P_OK_CODE.
  .

  DATA: S_SKAT LIKE SKAT.

  CLEAR: P_OK_CODE.

  LOOP AT IT_ZTISCSDT.
    G_TABIX = SY-TABIX.
    CASE IT_ZTISCSDT-KOART.
      WHEN 'K'.
        IF NOT *LFA1-LIFNR IS INITIAL.
          MOVE *LFA1-NAME1 TO IT_ZTISCSDT-MAKTX.
        ELSE.
          MOVE LFA1-NAME1 TO IT_ZTISCSDT-MAKTX.
        ENDIF.
      WHEN 'M'.
*      LOOP AT ydrseg WHERE matnr = xaccit-matnr
*                     and   rblgp = xaccit-zeile.
*        MOVE ydrseg-txz01 TO abtab-maktx.
*        exit.
*      ENDLOOP.
        IF IT_ZTISCSDT-EBELN IS INITIAL.
          CLEAR: IT_ZTISCSDT-MAKTX.
        ELSE.
          SELECT SINGLE TXZ01 INTO IT_ZTISCSDT-MAKTX
                 FROM   EKPO
                 WHERE  EBELN EQ IT_ZTISCSDT-EBELN
                 AND    EBELP EQ IT_ZTISCSDT-EBELP.
        ENDIF.

      WHEN OTHERS.
        IF ZTITCSK-PTDCL EQ C_CHARM.
          IF IT_ZTISCSDT-EBELN IS INITIAL.
            CLEAR: IT_ZTISCSDT-MAKTX.
          ELSE.
            SELECT SINGLE TXZ01 INTO IT_ZTISCSDT-MAKTX
                   FROM   EKPO
                   WHERE  EBELN EQ IT_ZTISCSDT-EBELN
                   AND    EBELP EQ IT_ZTISCSDT-EBELP.
          ENDIF.

        ELSE.
          CALL FUNCTION 'READ_HAUPTBUCH_AND_TEXT'
            EXPORTING
              SACHKONTO            = IT_ZTISCSDT-SAKNR
              BUCHUNGSKREIS        = ZTITCSK-BUKRS
              SPRACHE              = SY-LANGU
            IMPORTING
              TEXT_WA              = S_SKAT
            EXCEPTIONS
              KONTENPLAN_NOT_FOUND = 4
              SACHKONTO_NOT_FOUND  = 8
              TEXT_NOT_FOUND       = 12.
          IF SY-SUBRC = 0.
            MOVE S_SKAT-TXT50 TO IT_ZTISCSDT-MAKTX.
          ELSE.
            CLEAR: IT_ZTISCSDT-MAKTX.
          ENDIF.
        ENDIF.
    ENDCASE.
    IT_ZTISCSDT-WAERS = ZTITCSK-WAERS.

    MODIFY IT_ZTISCSDT INDEX G_TABIX.
  ENDLOOP.

  CLEAR: OK-CODE.
  IT_ZTISCSDTY[] = IT_ZTISCSDT[].
  DESCRIBE TABLE IT_ZTISCSDTY LINES G_LINE.

  IF G_LINE GT 0.
    IF ZTITCSK-PTDCL EQ C_CHARM.
      ZTISCSIT-CSCRT = C_CHARP.
    ELSE.
      ZTISCSIT-CSCRT = C_CHARF.
    ENDIF.
    CLEAR: OK-CODE.
    CALL SCREEN 7010 STARTING AT 1   1
                     ENDING   AT 108 20.
    P_OK_CODE = OK-CODE.
  ELSE.
    MESSAGE S872.
  ENDIF.

ENDFORM.                    " document_simulation_fi
*&---------------------------------------------------------------------*
*&      Form  set_one_time_vender_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_ONE_TIME_VENDER_DATA .

  CLEAR: OK-CODE.

  CALL FUNCTION 'Z_TI_GET_ONE_TIME_VENDOR_FIELD'
    EXPORTING
      XZTITCSK = ZTITCSK
      XLFA1    = LFA1
      XMODE    = G_MODE
    CHANGING
      XZTITCSO = ZTITCSO
      XOK_CODE = OK-CODE.

ENDFORM.                    " set_one_time_vender_data
*&---------------------------------------------------------------------*
*&      Form  get_longtext_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LONGTEXT_DATA .

*> Partner Text
  PERFORM  P1000_GET_TEXTID_AND_TEXT USING ZTITCSK+3(14)
                                           C_TEXTOBJECT_HEADER
                                           C_SCR0100
                                           C_TRUE
                                           C_FALSE.

ENDFORM.                    " get_longtext_data
*&---------------------------------------------------------------------*
*&      Form  build_query_factories_class
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUILD_QUERY_FACTORIES_CLASS .

  CALL FUNCTION 'Z_TI_GET_CHARGE_DOC_TO_QUERY'
    IMPORTING
      EX_FACTORY = G_DATABLADE.

ENDFORM.                    " build_query_factories_class

*&---------------------------------------------------------------------*
*&      Form  FI_DOCUMENT_CREATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FI_DOCUMENT_CREATE .


**- [CHM2110-00555] 전기전 세금계산서 매핑이 체크  -[s]
*  IF ZTITCSK-MWSKZ NE 'V0' AND ZTITCSK-BUKRS EQ '3000'   AND
*    ( ZTITCSK-EXPGR EQ 'B' OR ZTITCSK-EXPGR EQ 'C'  ).

*    IF ZTITCSK-INV_SEQ IS INITIAL  AND  SY-TCODE EQ C_CHANGE   .
*      MESSAGE S999  WITH '세금계산서 매핑을 해주십시오.'.
*      EXIT.
*    ENDIF.
*
*    IF SY-TCODE EQ C_CREATE AND OK_CODE EQ 'ZTIPOST'.
*      MESSAGE S999  WITH '비용문서 생성만 가능합니다.(변경후전기) '.
*      EXIT.
*    ENDIF.
*  ENDIF.
*- [CHM2110-00555] 전기전 세금계산서 매핑이 체크  -[e]

  PERFORM  INVOICE_DOCUMENT_CREATE  USING ZTITCSK-EMPFK
                                          ZTITCSK-BUPLA
                                          ZTITCSK-PTDCL.

ENDFORM.                    " FI_DOCUMENT_CREATE
*&---------------------------------------------------------------------*
*&      Form  FI_DOCUMENT_CANCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FI_DOCUMENT_CANCEL .

  PERFORM  INVOICE_DOCUMENT_CANCEL  USING ZTITCSK-PTDCL.

ENDFORM.                    " FI_DOCUMENT_CANCEL

*&---------------------------------------------------------------------*
*&      Form  OTHER_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM OTHER_FUNCTIONS .

  CASE OK_CODE.
    WHEN 'ZTIACDOC'.
      PERFORM ACCOUNT_DOCUMENT_DISPLAY USING ZTITCSK-BUKRS
                                             ZTITCSK-GJAHR
                                             ZTITCSK-BELNR.

    WHEN 'ZTIMMDOC'.
      PERFORM DISPLAY_LIV_DOCUMENT  USING ZTITCSK-BELNR
                                          ZTITCSK-GJAHR
                                          ZTITCSK-BUKRS.

    WHEN 'ZTIDSTR'.
      PERFORM DOCUMENT_SIMULATION_FI USING OK-CODE.

    WHEN 'ZTIONTIME'.  ">일회성 계정.
      PERFORM SET_ONE_TIME_VENDER_DATA.
    WHEN 'ZTICHDOC'.    ">변경문서.
      G_OBJEKT   = 'ZTICSCHDOC'.
      G_OBJEKTID = ZTITCSK+3(14).
      PERFORM DISPLAY_CHANGE_DOCUMENT USING G_OBJEKT
                                            G_OBJEKTID.

*- [CHM2110-00555] 세금계산서 매핑
    WHEN  'ZTITAX'.
      PERFORM CHOOSE_ETAX_UNMATCH .

    WHEN  'ZTITAXC'.
      PERFORM CLEAR_ETAX_MATCH .

    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " OTHER_FUNCTIONS

*&---------------------------------------------------------------------*
*&      Form  BEFORE_TRANSPORT_PAI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BEFORE_TRANSPORT_PAI .

*> Item Amount.
  PERFORM SUMMARY_INVOICE_AMOUNT  USING C_SUCCESS.

ENDFORM.                    " BEFORE_TRANSPORT_PAI
*&---------------------------------------------------------------------*
*&      Module  determine_due_date_scr2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DETERMINE_DUE_DATE_SCR2121 INPUT.

  G_ZTERM = 'X'.

ENDMODULE.                 " determine_due_date_scr2121  INPUT
*&---------------------------------------------------------------------*
*&      Form  check_no_draft_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_ANSWER  text
*----------------------------------------------------------------------*
FORM CHECK_NO_DRAFT_ITEM  USING    P_ANSWER.

  IF ZTITIG00-PSTMT EQ 'F' OR
     ZTITIG00-PSTMT EQ 'B'.
    P_ANSWER = 'J'.
  ELSEIF ZTITIG00-PSTMT EQ 'V'.
    P_ANSWER = 'J'.
  ELSE.
    IF ZTITCSK-PTDCL EQ C_CHARF.
      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
        EXPORTING
          TEXTLINE1 =
                      '배부할 구매오더가 존재하지 않아 회계문서로 전기합니다.'
          TEXTLINE2 = '회계문서로 전기하시겠습니까?'
          TITEL     = '회계기표 처리 확인'
        IMPORTING
          ANSWER    = P_ANSWER.

    ELSE.
      DESCRIBE TABLE GLACCOUNTDATA LINES G_LINE.
      IF G_LINE EQ 0.
        P_ANSWER = C_CHARJ.
      ELSE.
        CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
          EXPORTING
            TEXTLINE1 =
                        '배부할 조건유형이 존재하지 않아 무환부대비가 발생합니다.'
            TEXTLINE2 = '무환부대비 계정으로 전기하시겠습니까?'
            TITEL     = '무환 무대비 기표 확인'
          IMPORTING
            ANSWER    = P_ANSWER.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " check_no_draft_item
*&---------------------------------------------------------------------*
*&      Form  set_distribution_expences
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_DISTRIBUTION_EXPENCES .

  DATA : LT_ZTISCSDT_K LIKE IT_ZTISCSDT,
         LV_BUZEI      LIKE IT_ZTISCSDT-BUZEI,
         LT_TAB        LIKE LINE OF IT_TAB,
         LV_TABIX      LIKE SY-TABIX,

         BEGIN OF LT_COLLECT OCCURS 0,
           GSBER LIKE IT_ZTISCSDT-GSBER,
           WRBTR LIKE IT_ZTISCSDT-WRBTR,
         END OF LT_COLLECT ,

         LV_ADDTAX    LIKE IT_ZTISCSDT-WRBTR,
         LV_TAX_SUM   LIKE IT_ZTISCSDT-WRBTR,
         LV_AP_SUM    LIKE IT_ZTISCSDT-WRBTR,
         LV_WRBTR_TMP LIKE IT_ZTISCSDT-WRBTR.

  CLEAR : LV_ADDTAX, LV_TAX_SUM, LV_AP_SUM.

  CALL FUNCTION 'Z_TI_EXPENCES_DISTRIBUTION'
    EXPORTING
      XEXPGR             = ZTITCSK-EXPGR
    TABLES
      XZTISCSDT          = IT_ZTISCSDT[]
      XZTISCSIT          = IT_TAB[]
    CHANGING
      XZTITCSK           = ZTITCSK
    EXCEPTIONS
      DISTRIBUTION_ERROR = 1
      OTHERS             = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

**- [CHM2110-00555] 엠트론일 경우 AP부분을 사업영역별로 분할  -[s]
*  IF ZTITCSK-BUKRS EQ '3000' AND
*     ( ZTITCSK-EXPGR EQ 'B' OR  ZTITCSK-EXPGR EQ 'C' ).
*
*    CHECK ZTITCSK-PTDCL EQ C_CHARF.  "회계전표처리만
*
*
*    LOOP AT IT_ZTISCSDT WHERE KOART = 'S'.
*      IF IT_ZTISCSDT-SAKNR EQ '0001220101'.
*        LV_ADDTAX  =  IT_ZTISCSDT-WRBTR.
*        CONTINUE.
*      ENDIF.
*
*      LV_AP_SUM  = LV_AP_SUM + IT_ZTISCSDT-WRBTR.
*      MOVE-CORRESPONDING IT_ZTISCSDT TO LT_COLLECT.
*      COLLECT LT_COLLECT.
*
*    ENDLOOP.
*
*
*    "AP 체크
*    READ TABLE IT_ZTISCSDT INTO LT_ZTISCSDT_K WITH KEY KOART = 'K'.
*    CHECK SY-SUBRC EQ 0.
*
*    DESCRIBE TABLE LT_COLLECT LINES SY-TFILL.
*
*    IF SY-TFILL > 1.
*      DELETE IT_ZTISCSDT  WHERE KOART = 'K'.
*
** 부가세:매입세(1220101)계정이 있는 경우는 사업영역별로 차변배부
*      IF LV_ADDTAX IS NOT INITIAL AND LV_AP_SUM IS NOT INITIAL.
*        LOOP AT LT_COLLECT .
*          LV_TABIX = SY-TABIX.
*          LV_WRBTR_TMP =  LT_COLLECT-WRBTR +
*                           ( LV_ADDTAX - LV_TAX_SUM ).
*          AT LAST.
*            EXIT.
*          ENDAT.
*          LV_TAX_SUM =  LV_TAX_SUM +
*                        LV_ADDTAX * ( LT_COLLECT-WRBTR / LV_AP_SUM ).
*          LT_COLLECT-WRBTR =  LT_COLLECT-WRBTR +
*                          LV_ADDTAX * ( LT_COLLECT-WRBTR / LV_AP_SUM ).
*
*          MODIFY LT_COLLECT .
*        ENDLOOP.
*
*        LT_COLLECT-WRBTR = LV_WRBTR_TMP.
*        MODIFY LT_COLLECT INDEX LV_TABIX TRANSPORTING WRBTR.
*      ENDIF.
*
*
*      LOOP AT LT_COLLECT .
*        LT_ZTISCSDT_K-GSBER   = LT_COLLECT-GSBER .
*        LT_ZTISCSDT_K-WRBTR   = LT_COLLECT-WRBTR.
*        APPEND  LT_ZTISCSDT_K  TO IT_ZTISCSDT.
*      ENDLOOP.
*
*    ELSE.
*      READ TABLE LT_COLLECT INDEX 1.
*      IT_ZTISCSDT-GSBER = LT_COLLECT-GSBER.
*      MODIFY IT_ZTISCSDT TRANSPORTING GSBER
*                         WHERE KOART = 'K'.
*    ENDIF.
*
*
*
*    SORT IT_ZTISCSDT  BY BUZEI.
*    LOOP AT IT_ZTISCSDT.
*      ADD 1 TO LV_BUZEI .
*      IT_ZTISCSDT-BUZEI = LV_BUZEI.
*      MODIFY IT_ZTISCSDT TRANSPORTING BUZEI.
*    ENDLOOP.
*
*  ENDIF.
**- [CHM2110-00555] 엠트론일 경우 AP부분을 사업영역별로 분할  -[e]

ENDFORM.                    " set_distribution_expences
*&---------------------------------------------------------------------*
*&      Form  CHOOSE_ETAX_UNMATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHOOSE_ETAX_UNMATCH .


  DATA: L_LIFNR       LIKE LFA1-LIFNR,
        L_SU_ID       LIKE LFA1-STCD2,
        LV_LIFNR      LIKE ZTITCSK-LIFNR,
        LV_COUNT      TYPE N LENGTH 3,
        LV_CHARGE_TOT LIKE ZTITCSK-FWBAS.

  DATA: LR_ISSUE_DATE LIKE TABLE OF RANGE_DATE WITH HEADER LINE.
  DATA: LT_ETAX_AP_HEAD LIKE TABLE OF ZDTV3T_AP_HEAD WITH HEADER LINE.


  SELECT SINGLE STCD2
    INTO  L_SU_ID
    FROM LFA1
    WHERE LIFNR = ZTITCSK-LIFNR.



  LR_ISSUE_DATE-SIGN   = 'I'.
  LR_ISSUE_DATE-OPTION = 'BT'.


  PERFORM SET_ISSUE_DATE IN PROGRAM ZTIR9130_NEW IF FOUND
                        TABLES LR_ISSUE_DATE.

  LR_ISSUE_DATE-HIGH   = SY-DATUM.
  APPEND LR_ISSUE_DATE.


  CALL FUNCTION 'Z_FI_ETAX_PURCH_LIST'
    EXPORTING
      I_BUKRS        = ZTITCSK-BUKRS
      I_LIFNR        = ZTITCSK-LIFNR
      I_SU_ID        = L_SU_ID
      I_MATCH        = ' '
      I_POPUPX       = 'X'
      I_ONLYONE      = 'X'
    TABLES
      I_ISSUE_DATE   = LR_ISSUE_DATE
      O_ETAX_AP_HEAD = LT_ETAX_AP_HEAD.

  CHECK LT_ETAX_AP_HEAD[] IS NOT INITIAL.

  LV_COUNT = LINES( LT_ETAX_AP_HEAD ).

  IF LV_COUNT <> 1 .
    MESSAGE S000 WITH '한개의 매입계산서만 지정 가능합니다.'
      DISPLAY LIKE 'E'.
    EXIT.
  ELSE.

*- [CHM2207-00033] 영세율 반영 및 외화인 경우 원화환산 비교 -[s]
    LV_CHARGE_TOT = ZTITCSK-DMBTR - ZTITCSK-WMWST.

    IF ZTITCSK-PTDCL EQ 'V' AND LV_CHARGE_TOT EQ 0.  "부가세 경우
      LV_CHARGE_TOT = ZTITCSK-DMBTR .
    ENDIF.
*- [CHM2207-00033] 영세율 반영 및 외화인 경우 원화환산 비교 -[e]


    IF LV_CHARGE_TOT NE LT_ETAX_AP_HEAD-CHARGETOTAL.
      MESSAGE I999 WITH '세금계산서 공급가액과 제비용금액이 다릅니다.'.
      EXIT.
    ENDIF.

    ZTITCSK-ISSUE_DATE = ZTITCSK-BUDAT = ZTITCSK-BLDAT =
    LT_ETAX_AP_HEAD-ISSUE_DATE .
    ZTITCSK-BUPLA_TAX  = LT_ETAX_AP_HEAD-BUPLA.
    ZTITCSK-INV_SEQ    = LT_ETAX_AP_HEAD-INV_SEQ    .
    ZTITCSK-DESC_TEXT1 = LT_ETAX_AP_HEAD-DESC_TEXT1  .

    MESSAGE S999 WITH '정상 매핑되었습니다.  '.
  ENDIF.


ENDFORM.                    " CHOOSE_ETAX_UNMATCH
*&---------------------------------------------------------------------*
*&      Form  SET_ZDTV3T_AP_EXT_USE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_ZDTV3T_AP_EXT_USE_DOC .

  CHECK  ZTITCSK-BELNR IS NOT INITIAL    AND
         ZTITCSK-INV_SEQ IS NOT INITIAL  AND
         ( ZTITCSK-EXPGR EQ 'B' OR ZTITCSK-EXPGR EQ 'C'  ) AND
         ZTITCSK-MWSKZ NE 'V0' .


*   전자세금과 연결여부 설정
  UPDATE ZDTV3T_AP_EXT
     SET USE_DOC = 'X'
  WHERE BUKRS      EQ ZTITCSK-BUKRS
    AND ISSUE_DATE EQ ZTITCSK-ISSUE_DATE
    AND BUPLA      EQ ZTITCSK-BUPLA_TAX
    AND INV_SEQ    EQ ZTITCSK-INV_SEQ.


*   전자세금상세에 연결된 전표번호 설정
  UPDATE ZDTV3T_AP_EXT_D
     SET  BELNR = ZTITCSK-BELNR
          ZGJAH = ZTITCSK-BUDAT(4)
          BUDAT = ZTITCSK-BUDAT
          BLDAT = ZTITCSK-BLDAT
          BLART = ZTITCSK-BLART
          MWSKZ = ZTITCSK-MWSKZ
          DMBTR = ZTITCSK-DMBTR
   WHERE BUKRS  = ZTITCSK-BUKRS
     AND ISSUE_DATE = ZTITCSK-ISSUE_DATE
     AND BUPLA      = ZTITCSK-BUPLA_TAX
    AND INV_SEQ     = ZTITCSK-INV_SEQ.



ENDFORM.                    " SET_ZDTV3T_AP_EXT_USE_DOC
*&---------------------------------------------------------------------*
*&      Form  CLEAR_ETAX_MATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CLEAR_ETAX_MATCH .

  CLEAR: ZTITCSK-ISSUE_DATE, ZTITCSK-BUPLA_TAX ,
         ZTITCSK-INV_SEQ   , ZTITCSK-DESC_TEXT1 .


  MESSAGE S999 WITH '매핑이 삭제되었습니다 '.

ENDFORM.                    " CLEAR_ETAX_MATCH
*&---------------------------------------------------------------------*
*&      Form  UNSET_ZDTV3T_AP_EXT_USE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UNSET_ZDTV3T_AP_EXT_USE_DOC .

  CHECK  ZTITCSK-INV_SEQ IS NOT INITIAL  AND
         ( ZTITCSK-EXPGR EQ 'B' OR ZTITCSK-EXPGR EQ 'C'  ) AND
          ZTITCSK-MWSKZ NE 'V0' .


*   전자세금과 연결여부 설정
  UPDATE ZDTV3T_AP_EXT
     SET USE_DOC = SPACE
  WHERE BUKRS      EQ ZTITCSK-BUKRS
    AND ISSUE_DATE EQ ZTITCSK-ISSUE_DATE
    AND BUPLA      EQ ZTITCSK-BUPLA_TAX
    AND INV_SEQ    EQ ZTITCSK-INV_SEQ.


*   전자세금상세에 연결된 전표번호 설정
  UPDATE ZDTV3T_AP_EXT_D
     SET  BELNR = SPACE
          ZGJAH = SPACE
          BUDAT = SPACE
          BLDAT = SPACE
          BLART = SPACE
          MWSKZ = SPACE
          DMBTR = SPACE
   WHERE BUKRS  = ZTITCSK-BUKRS
     AND ISSUE_DATE = ZTITCSK-ISSUE_DATE
     AND BUPLA      = ZTITCSK-BUPLA_TAX
    AND INV_SEQ     = ZTITCSK-INV_SEQ.


  UPDATE ZTITCSK
      SET  ISSUE_DATE      = SPACE
           BUPLA_TAX       = SPACE
           DESC_TEXT1      = SPACE
           INV_SEQ         = SPACE
    WHERE BUKRS EQ ZTITCSK-BUKRS
      AND ICSNO EQ ZTITCSK-ICSNO.


  CLEAR : ZTITCSK-INV_SEQ,  ZTITCSK-BUPLA_TAX,
          ZTITCSK-ISSUE_DATE.



ENDFORM.                    " UNSET_ZDTV3T_AP_EXT_USE_DOC

*&---------------------------------------------------------------------*
*&      Form  CHECK_POST_POSSIBLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CHECK    text
*----------------------------------------------------------------------*
FORM CHECK_POST_POSSIBLE USING P_CHECK.


*- [CHM2110-00555] 전기전 세금계산서 매핑이 체크  -[s]
  IF ZTITCSK-MWSKZ NE 'V0' AND ZTITCSK-BUKRS EQ '3000'   AND
    ( ZTITCSK-EXPGR EQ 'B' OR ZTITCSK-EXPGR EQ 'C'  ).

    IF SY-TCODE EQ C_CREATE .
      MESSAGE S999  WITH '비용문서 생성만 가능합니다.(변경후전기) '.
      P_CHECK = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    "CHECK_POST_POSSIBLE
