************************************************************************
* Title         :  ZTIR7000F01                                         *
*                                                                      *
* Description   : 수입 계산서 관리 Subroutine Include                  *
*                                                                      *
* Creation Date : 2003/08/12                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* 2014-03-27   ZLSGMM(hjkim)    R3TK9A0F7X  CSR 2014031800051 기능개선 *
* 2021-03-24   ZLSGMM           CHM2103-00178 구매처 지급조건 및 지급방법 변경*
*2022-06-07    ZLSGMM           CHM2205-00386  다중생성         *
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  get_and_check_po_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_AND_CHECK_BL_DATA  USING    P_IBLNO
                             P_IBLIT
                             P_MODIFY
                             P_ZTIVBL00 STRUCTURE ZTIVBL00
                             P_COUNT.

  CLEAR: ZTIVBL00.

  SELECT SINGLE * INTO P_ZTIVBL00
    FROM ZTIVBL00
   WHERE IBLNO EQ P_IBLNO
     AND IBLIT EQ P_IBLIT.

  IF SY-SUBRC EQ 0.
*>Vendor 체크.
    IF ZTITVAK-LIFNR     NE P_ZTIVBL00-LIFNR AND
       NOT ZTITVAK-LIFNR IS INITIAL.
      MESSAGE S306 WITH P_ZTIVBL00-LIFNR ZTITVAK-LIFNR.
      P_MODIFY = C_TRUE.
      EXIT.
    ENDIF.
*통화키 체크.
    IF ZTITVAK-WAERS    NE  P_ZTIVBL00-WAERS AND
       P_COUNT           GT  C_ZERO.
      MESSAGE S307 WITH P_ZTIVBL00-WAERS ZTITVAK-WAERS.
      P_MODIFY = C_TRUE.
    ENDIF.

*> 사전송금 체크
    IF NOT P_ZTIVBL00-REQNO IS INITIAL.
      SELECT SINGLE *
        FROM ZTITRQK
       WHERE REQNO EQ P_ZTIVBL00-REQNO.
      IF SY-SUBRC NE 0.
        MESSAGE S323.
        P_MODIFY = C_TRUE.
        EXIT.
      ENDIF.
      IF ZTITRQK-REQTY EQ 'TT' AND
         ZTITRQK-ANBTY EQ 'B'.
        MESSAGE S324.
        P_MODIFY = C_TRUE.
        EXIT.
      ENDIF.
    ENDIF.

*> Lock Object
    PERFORM  SET_BL_LOCK_OBJECT  USING P_IBLNO
                                       P_IBLIT
                                       C_LOCK
                                       C_SUCCESS
                                       P_MODIFY.
  ELSE.
    MESSAGE S019(06) WITH P_IBLNO.
    P_MODIFY = C_TRUE.
    EXIT.
  ENDIF.

ENDFORM.                    " get_and_check_po_data
*&---------------------------------------------------------------------*
*&      Form  p3000_set_data_of_screen
*&---------------------------------------------------------------------*
FORM P3000_SET_DATA_OF_SCREEN .

  IF SY-TCODE EQ C_CREATE OR
     SY-TCODE EQ C_CREATE_D.

    REFRESH: IT_TAB, IT_ZTITVAH, IT_ZTISRQIT.

    CLEAR: ZTITVAK,
          *ZTITVAK,
           ZTITVAP,
           ZTITBLK,
           ZTITBLP,
           IT_TAB,
           LFA1,
          *LFA1,
           W_LFA1,
           W_LFA1_BANK,
           T001,
           T024,
           T024E.

    CLEAR:  GT_CONTROL-TEXTLINES[], GT_CONTROL-TEXTTYPES[].

    MOVE  : '세금계산서'   TO    ZTITVAK-BKTXT,
             C_CHAR1       TO    ZTITVAK-VORGANG,
*             c_chari       TO    ztitvak-prpyn,
             C_CHARN       TO    ZTITVAK-LIVST,
             'RE'          TO    ZTITVAK-BLART,
             SY-DATLO      TO    ZTITVAK-BUDAT,  ">송장일.
             SY-DATLO      TO    ZTITVAK-BLDAT.
  ELSE.
*> 변경 문서 관리를 위한 이전데이타를 Move.
    ZTITVAK-VATNO   = *ZTITVAK-VATNO.
  ENDIF.

ENDFORM.                    " p3000_set_data_of_screen
*&---------------------------------------------------------------------*
*&      Form  check_for_sub_document_exist
*&---------------------------------------------------------------------*
*  삭제시 후속 문서의 존재여부를 확인함..
*----------------------------------------------------------------------*
FORM CHECK_FOR_SUB_DOCUMENT_EXIST.

  LOOP AT IT_TAB INTO G_TC_2130_WA.
    PERFORM CHECK_IV_SUB_DOCUMENT_EXIST
                             USING   G_TC_2130_WA-VATNO
                                     G_TC_2130_WA-RBLGP
                                     C_ERROR
                                     G_SUBRC.
  ENDLOOP.

ENDFORM.                    " check_for_sub_document_exist


*&---------------------------------------------------------------------*
*&      Form  check_for_document_field
*&---------------------------------------------------------------------*
*  필드들의 오류 값들을 체크하여 공통 nternal table에 저장함.
*----------------------------------------------------------------------*
FORM CHECK_FOR_DOCUMENT_FIELD USING P_MODE.
*
  DATA: L_IF_NULL TYPE REF TO IF_MESSAGE_OBJ_MM.

* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

  CLEAR: G_LINE.

*> 총 처리금액.
  IF ZTITVAK-WRBTR IS INITIAL.
    PERFORM SET_RETURN_MESSAGE USING 'ZTITVAK' 'WRBTR' C_ERROR.
  ENDIF.
*> 헤더 텍스트.
  IF ZTITVAK-BKTXT IS INITIAL.
    PERFORM SET_RETURN_MESSAGE USING 'ZTITVAK' 'IVAMP' C_ERROR.
  ENDIF.
**> 유보금이 존재할 경우.
*  IF NOT ztitvak-rtchg IS INITIAL.
*    READ TABLE it_ztitivv INDEX 2.
*    IF sy-subrc EQ 0.
*      IF it_ztitivv-zterm IS INITIAL.
*        MESSAGE s316.
*        PERFORM set_return_message_fill USING c_error.
*      ENDIF.
*    ENDIF.
*  ENDIF.
*
  DATA: BEGIN OF LT_MWSKZ OCCURS 1,
          MWSKZ TYPE MWSKZ,
        END   OF LT_MWSKZ.

  CLEAR: G_COUNT, LT_MWSKZ, LT_MWSKZ[].
*> 품목 체크.
  LOOP AT IT_TAB INTO G_TC_2130_WA.
    ADD 1 TO G_COUNT.
    IF G_TC_2130_WA-IVMNG IS INITIAL.
      MESSAGE S133 WITH G_TC_2130_WA-RBLGP '수량'.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.
    IF G_TC_2130_WA-REFWR IS INITIAL.
      MESSAGE S133 WITH G_TC_2130_WA-RBLGP '금액'.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.
    IF G_TC_2130_WA-MWSKZ IS INITIAL.
      MESSAGE S133 WITH G_TC_2130_WA-RBLGP '세금코드'.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.
    MOVE G_TC_2130_WA-MWSKZ TO LT_MWSKZ-MWSKZ.
    COLLECT LT_MWSKZ.
  ENDLOOP.

  IF G_COUNT EQ 0.
    MESSAGE S001.
    PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
  ELSE.
    DESCRIBE TABLE LT_MWSKZ LINES G_LINE.
    CASE G_LINE.
      WHEN 0.
*        MESSAGE s001.
      WHEN 1.
        READ TABLE LT_MWSKZ INDEX 1.
        IF NOT LT_MWSKZ-MWSKZ IS INITIAL.
          IF ZTITVAK-MWSKZ NE LT_MWSKZ-MWSKZ.
            MESSAGE S885.
            PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
          ENDIF.
        ENDIF.
      WHEN OTHERS.
        MESSAGE S885.
        PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDCASE.
  ENDIF.

*> 오류정보가 존재시 메시지 상자 POPUP.
  G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                          IM_BUSINESS_OBJ          = L_IF_NULL
                          IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

  IF G_LINE GT 0.
    CALL METHOD G_MESSAGE_HANDLER->SHOW(
        IM_POPUP  = C_TRUE
        IM_AMODAL = C_FALSE ).
  ELSE.
    MESSAGE S911.
  ENDIF.

ENDFORM.                    " check_for_document_field
*&---------------------------------------------------------------------*
*&      Form  p8000_save_master_data
*&---------------------------------------------------------------------*
FORM P8000_SAVE_MASTER_DATA USING P_MODE.

*
*> 공통테이블 적용.
  IF G_MODE      EQ C_CHARY AND
     OK_CODE_OLD EQ 'ZTISAVE'.
    P_MODE = 'Y'.
  ENDIF.

  PERFORM P8100_SAVE_COMMON_DATA  TABLES IT_TAB
                                  USING  ZTITVAK
                                         G_SUBRC
                                         P_MODE.
  IF G_SUBRC NE C_ZERO.
    MESSAGE A912.   EXIT.
  ENDIF.

*> Long Text 저장 루틴.
  PERFORM SAVE_LONG_TEXT USING ZTITVAK+3(10)
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
    MESSAGE S702 WITH ZTITVAK-VATNO.
  ELSE.
    SET PARAMETER ID 'ZTIVATNO' FIELD ZTITVAK-VATNO.
*    IF NOT ztitvak-ivnum IS INITIAL.
*      SET PARAMETER ID 'ZTIIVNUM' FIELD ztitvak-ivnum.
*    ENDIF.
    MESSAGE S701 WITH ZTITVAK-VATNO.
  ENDIF.
*> Commit work.
  COMMIT WORK.
*  COMMIT WORK AND WAIT.


ENDFORM.                    " p8000_save_master_data
*&---------------------------------------------------------------------*
*&      Form  p8100_save_common_data
*&---------------------------------------------------------------------*
FORM P8100_SAVE_COMMON_DATA  TABLES  PT_TAB     STRUCTURE G_TC_2130_WA
                             USING   P_ZTITVAK STRUCTURE ZTITVAK
                                     P_SUBRC    LIKE      SY-SUBRC
                                     P_MODE.

  DATA: L_LCONO TYPE ZTIREQNO.

  CLEAR: P_SUBRC, L_LCONO.

  IF SY-TCODE EQ C_CREATE OR  SY-TCODE EQ C_CREATE_D.

    CALL FUNCTION 'Z_TI_GET_NUMBER_NEXT'
      EXPORTING
        ZMPTY    = C_VA
*       BUKRS    =
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
    L_LCONO = P_ZTITVAK-VATNO.
  ENDIF.

*  IF sy-tcode EQ c_create_a.
*    ADD 1 TO l_amdsq.
*  ENDIF.

  IF  P_ZTITVAK-CNAM IS INITIAL.
    MOVE: SY-UNAME   TO   P_ZTITVAK-CNAM,
          SY-DATLO   TO   P_ZTITVAK-CDAT,
          SY-TIMLO   TO   P_ZTITVAK-CTME.
  ENDIF.

  MOVE: SY-MANDT   TO   P_ZTITVAK-MANDT,
        L_LCONO    TO   P_ZTITVAK-VATNO,
        SY-UNAME   TO   P_ZTITVAK-UNAM,
        SY-DATLO   TO   P_ZTITVAK-UDAT,
        SY-TIMLO   TO   P_ZTITVAK-UTME.

*> 전기시.
  IF P_MODE EQ 'H'.
    MOVE: INVOICEDOCNUMBER TO P_ZTITVAK-BELNR,
          C_CHARP          TO P_ZTITVAK-LIVST.
  ELSEIF P_MODE EQ 'R'.
    MOVE: SPACE            TO P_ZTITVAK-BELNR,
          C_CHARN          TO P_ZTITVAK-LIVST.
  ENDIF.

  IF OK_CODE_OLD EQ 'ZTIDELETE'.
*> Header table delete.
    DELETE FROM ZTITVAK WHERE VATNO EQ ZTITVAK-VATNO.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.
*> Item table delete
    DELETE FROM ZTITVAP WHERE VATNO EQ ZTITVAK-VATNO.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.
*> 이력 table delete
    DELETE FROM ZTITVAH WHERE VATNO EQ ZTITVAK-VATNO.

**> 분할금액 table delete
*    DELETE FROM ztitivv WHERE vatno EQ ztitvak-vatno.
*
    EXIT.
  ELSE.
*> Header table modify.
    MODIFY ZTITVAK FROM P_ZTITVAK.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.
*> Items table modify.
    DELETE FROM ZTITVAP WHERE VATNO EQ P_ZTITVAK-VATNO.
    REFRESH : XZTITVAP.
    LOOP AT IT_TAB INTO G_TC_2130_WA.
      MOVE-CORRESPONDING G_TC_2130_WA TO XZTITVAP.
      XZTITVAP-MANDT = P_ZTITVAK-MANDT.
      XZTITVAP-VATNO = P_ZTITVAK-VATNO.
      XZTITVAP-RBLGP = SY-TABIX.
      APPEND XZTITVAP.
    ENDLOOP.

    MODIFY ZTITVAP FROM TABLE XZTITVAP.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.

**> 분할금액 table modify.
*    REFRESH : xztitivv.
*    DELETE FROM ztitivv WHERE vatno EQ ztitvak-vatno.
*    DESCRIBE TABLE it_ztitivv  LINES g_line.
*    IF g_line GT 0.
*      LOOP AT it_ztitivv.
*        it_ztitivv-mandt = p_ztitvak-mandt.
*        it_ztitivv-vatno = p_ztitvak-vatno.
*        MODIFY it_ztitivv.
*        MOVE-CORRESPONDING it_ztitivv TO xztitivv.
*        xztitvap-mandt = p_ztitvak-mandt.
*        xztitvap-vatno = p_ztitvak-vatno.
*        APPEND xztitivv.
*      ENDLOOP.
*
*      MODIFY ztitivv FROM TABLE it_ztitivv.
*    ENDIF.

*> 전기이력 table modify.
    IF P_MODE EQ 'H'.
      CLEAR: ZTITVAH.
      SELECT MAX( IVSEQ )
        INTO ZTITVAH-IVSEQ
        FROM ZTITVAH
       WHERE VATNO    EQ   P_ZTITVAK-VATNO.

      ADD 1 TO  ZTITVAH-IVSEQ.
      IF P_ZTITVAK-VORGANG EQ C_CHAR1 OR
         P_ZTITVAK-VORGANG EQ C_CHAR3.
        MOVE 'H'                 TO     ZTITVAH-SHKZG.
      ELSE.
        MOVE 'S'                 TO     ZTITVAH-SHKZG.
      ENDIF.
      MOVE : SY-MANDT             TO     ZTITVAH-MANDT,
             P_ZTITVAK-BLDAT     TO     ZTITVAH-BUDAT,
             P_ZTITVAK-BUDAT     TO     ZTITVAH-BLDAT,
             P_ZTITVAK-VATNO     TO     ZTITVAH-VATNO,
             P_ZTITVAK-WAERS     TO     ZTITVAH-WAERS,
*             p_ZTITVAK-dmbtr     TO     ZTITVAH-dmbtr,
             P_ZTITVAK-BLART     TO     ZTITVAH-BLART,
*             p_ztitvak-ivamp     TO     ZTITVAH-ivamp,
             P_ZTITVAK-VORGANG   TO     ZTITVAH-VORGANG,
             SY-UNAME             TO     ZTITVAH-CNAM,
             SY-DATLO             TO     ZTITVAH-CDAT,
             SY-TIMLO             TO     ZTITVAH-CTME,
             FISCALYEAR           TO     ZTITVAH-GJAHR,
             INVOICEDOCNUMBER     TO     ZTITVAH-BELNR,
             ''                   TO     ZTITVAH-CBUDAT,
             ''                   TO     ZTITVAH-CGJAHR,
             ''                   TO     ZTITVAH-CBELNR.
      INSERT ZTITVAH.
      IF SY-SUBRC NE 0.
        ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
      ENDIF.
*> 전기 취소.
    ELSEIF P_MODE EQ 'R'.
      CLEAR: ZTITVAH.
      SELECT MAX( IVSEQ )
        INTO ZTITVAH-IVSEQ
        FROM ZTITVAH
       WHERE VATNO    EQ   P_ZTITVAK-VATNO.

      SELECT SINGLE *
        FROM ZTITVAH
       WHERE VATNO    EQ   P_ZTITVAK-VATNO
         AND IVSEQ    EQ   ZTITVAH-IVSEQ.

      IF SY-SUBRC EQ 0.
        MOVE: ZTISSCRCOM-STGRD          TO ZTITVAH-STGRD,
              ZTISSCRCOM-CBUDAT         TO ZTITVAH-CBUDAT,
              FISCALYEAR_REVERSAL       TO ZTITVAH-CGJAHR,
              INVOICEDOCNUMBER_REVERSAL TO ZTITVAH-CBELNR,
              SY-UNAME                  TO ZTITVAH-CNAM,
              SY-DATLO                  TO ZTITVAH-CDAT,
              SY-TIMLO                  TO ZTITVAH-CTME.
        MODIFY ZTITVAH.
        IF SY-SUBRC NE 0.
          ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
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

  IF ZTITVAK-BUKRS IS INITIAL.
    CLEAR: T001.
  ELSE.
    SELECT SINGLE * FROM T001
     WHERE BUKRS EQ ZTITVAK-BUKRS.
    IF SY-SUBRC EQ 0.
      SELECT SINGLE *
        FROM T005
       WHERE LAND1 EQ T001-LAND1.
      SELECT SINGLE *
        FROM ZTITIG00
       WHERE BUKRS EQ T001-BUKRS.
      IF SY-SUBRC NE 0.
        MESSAGE E035 WITH T001-BUKRS.
      ENDIF.
    ENDIF.
  ENDIF.

* 구매조직 SELECT ( T024E )
  IF ZTITVAK-EKORG IS INITIAL.
    CLEAR T024E.
  ELSE.
    CALL FUNCTION 'T024E_SINGLE_READ'
      EXPORTING
        T024E_EKORG = ZTITVAK-EKORG
      IMPORTING
        WT024E      = T024E
      EXCEPTIONS
        NOT_FOUND   = 1
        OTHERS      = 2.

    IF SY-SUBRC NE 0.
      IF SY-CALLD NE C_TRUE.
        MESSAGE W001(MH) WITH ZTITVAK-EKORG.
      ENDIF.
    ENDIF.
  ENDIF.

* 구매그룹 SELECT ( T024 )
  IF ZTITVAK-EKGRP IS INITIAL.
    CLEAR T024.
  ELSE.
    CALL FUNCTION 'MM_ARRANG_PURCHASE_GRP_SELECT'
      EXPORTING
        PURCHASE_GROUP           = ZTITVAK-EKGRP
      IMPORTING
        E_T024                   = T024
      EXCEPTIONS
        PURCHASE_GROUP_NOT_FOUND = 1
        OTHERS                   = 2.

    IF SY-SUBRC NE 0.
      IF SY-CALLD NE C_TRUE.
        MESSAGE W030(MN) WITH ZTITVAK-EKGRP.
      ENDIF.
    ENDIF.
  ENDIF.

  PERFORM  GET_IMPORT_VENDORS_TEXT  USING C_SUCCESS.

ENDFORM.                    " GET_OTHERS_TEXT_BY_MASTER_DATA

*&---------------------------------------------------------------------*
*&      Form  GET_VATBLIL_DOCUMENT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_VATBIL_DOCUMENT_DATA
                             TABLES P_IT_ZTISRQIT  STRUCTURE IT_ZTISRQIT
                             USING  P_REQNO
                                    P_AMDSQ
                                    P_MTYPE
                                    P_MSGTY.

  REFRESH IT_REQNO.  CLEAR IT_REQNO.

  SELECT MAX( AMDSQ )
    INTO P_AMDSQ
    FROM ZTITRQS
   WHERE REQNO EQ P_REQNO.

*  IF p_reqit IS INITIAL.
  CALL FUNCTION 'Z_TI_GET_REQUEST_OF_IMPORT'
    EXPORTING
      REQNO     = P_REQNO
      AMDSQ     = P_AMDSQ
*     reqit     = p_reqit
    IMPORTING
      ZTITRQK   = ZTITRQK
      ZTITRQS   = ZTITRQS
    TABLES
      ZTITRQP   = P_IT_ZTISRQIT
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF SY-SUBRC NE 0.
    MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 217 WITH P_REQNO P_AMDSQ.
  ENDIF.

*>수입의뢰문서의 종류/상태를 검증.
  PERFORM CHECK_REQUEST_OF_IMPORT.

*>수입의뢰문서의 잔량를 검증.
  PERFORM GET_AVAILABLE_LC_ITEM TABLES P_IT_ZTISRQIT
                                       IT_REQNO
                                USING  P_MSGTY
                                       C_FALSE.

ENDFORM.                    " get_vatbil_document_data
*&---------------------------------------------------------------------*
*&      Form  GET_LC_DOCUMENT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LC_DOCUMENT_DATA     TABLES   P_IT_LC   STRUCTURE IT_REQIT_TMP
                              USING    P_REQNO
                                       P_AMDSQ
                                       P_MTYPE
                                       P_MSGTY.
  CHECK: NOT P_REQNO IS INITIAL.

  REFRESH IT_REQNO.  CLEAR IT_REQNO.
  CALL FUNCTION 'Z_TI_GET_REQUEST_OF_IMPORT'
    EXPORTING
      REQNO     = P_REQNO
      AMDSQ     = P_AMDSQ
    IMPORTING
      ZTITRQK   = ZTITRQK
      ZTITRQS   = ZTITRQS
    TABLES
      ZTITRQP   = P_IT_LC
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF SY-SUBRC NE 0.
    MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 217 WITH P_REQNO P_AMDSQ.
  ENDIF.

  PERFORM GET_AVAILABLE_LC_ITEM TABLES P_IT_LC
                                       IT_REQNO
                                USING  P_MSGTY
                                       C_FALSE.

* 수입의뢰상태 확인.add.
  IF ZTITRQK-OPNBK IS INITIAL.
    MESSAGE ID 'ZMTI00' TYPE 'E' NUMBER 322 WITH ZTITRQK-REQNO.
  ENDIF.

*> 회사별 프로세스 정의 테이블 검색.
  SELECT SINGLE *
    FROM ZTITIG00
   WHERE BUKRS EQ ZTITRQK-BUKRS.
  IF SY-SUBRC NE 0.
    MESSAGE E035 WITH ZTITRQK-BUKRS.
  ENDIF.

ENDFORM.                    " get_lc_document_data

*&---------------------------------------------------------------------*
*&      Form  get_available_lc_item
*&---------------------------------------------------------------------*
*       B/L을 입력할 수입의뢰 잔량을 체크함.
*----------------------------------------------------------------------*
FORM GET_AVAILABLE_LC_ITEM  TABLES   PT_ZTISRQIT STRUCTURE IT_ZTISRQIT
                                     PT_REQNO    STRUCTURE IT_REQNO
                            USING    P_MSGTY
                                     P_DEL_MODE.
  DATA: L_BLMNG  LIKE ZTITBLP-BLMNG.

  CLEAR: G_COUNT, G_CNT.

  LOOP AT PT_ZTISRQIT.
    G_TABIX = SY-TABIX.
    CLEAR: L_BLMNG.

    IF NOT PT_ZTISRQIT-EBELN IS INITIAL.
      SELECT  SUM( IVMNG ) INTO PT_ZTISRQIT-IVMNGS
        FROM  ZTITVAP
       WHERE  EBELN  = PT_ZTISRQIT-EBELN
         AND  EBELP  = PT_ZTISRQIT-EBELP
         AND  REQNO  = PT_ZTISRQIT-REQNO
         AND  REQIT  = PT_ZTISRQIT-REQIT.

      PT_ZTISRQIT-IVMNG =  PT_ZTISRQIT-RQMNG - PT_ZTISRQIT-IVMNGS.

      IF PT_ZTISRQIT-IVMNG LE C_ZERO.
        IF P_DEL_MODE EQ C_TRUE.
          DELETE PT_ZTISRQIT INDEX G_TABIX.
          CONTINUE.
        ELSE.
          PT_ZTISRQIT-IVMNG = 0.
        ENDIF.
      ELSE.
        ADD 1 TO G_CNT.
      ENDIF.

      PT_ZTISRQIT-IVMNGL =  PT_ZTISRQIT-IVMNG.

*> Tree용 Internal table modify.
      ADD 1 TO G_COUNT.
      PT_ZTISRQIT-INDEX = G_COUNT.
      MODIFY PT_ZTISRQIT INDEX G_TABIX.

*> 수입의뢰관리번호별 collect.
      MOVE PT_ZTISRQIT-REQNO TO PT_REQNO-REQNO.
      COLLECT PT_REQNO.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE PT_ZTISRQIT LINES G_LINE.
  IF G_LINE EQ 0.
    MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 902.
    EXIT.
  ENDIF.

  IF G_CNT EQ 0.
    MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 103.
  ENDIF.

ENDFORM.                    " get_available_lc_item
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

  L_OBJECTID(10) = ZTITVAK+3(10).

  L_TCODE        = SY-TCODE.
  L_UTIME        = SY-TIMLO.
  L_UDATE        = SY-DATLO.
  L_USERNAME     = SY-UNAME.

  IF G_MODE EQ C_CHARC.  ">생성모드일 경우.
    REFRESH : YZTITVAP.
  ENDIF.

  LOOP AT XZTITVAP.
    XZTITVAP-KZ = L_UPD.
    MODIFY XZTITVAP.
  ENDLOOP.


*  CALL FUNCTION 'ZTILCCHDOC_WRITE_DOCUMENT' IN UPDATE TASK
  CALL FUNCTION 'ZTIVACHDOC_WRITE_DOCUMENT'
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
      N_ZTITVAK               = ZTITVAK
      O_ZTITVAK               = *ZTITVAK
      UPD_ZTITVAK             = L_UPD
      UPD_ZTITVAP             = L_UPD
*     upd_ztitivv             = l_upd
    TABLES
      ICDTXT_ZTIVACHDOC       = LT_CDTXT
      XZTITVAP                = XZTITVAP
      YZTITVAP                = YZTITVAP.
*      xztitivv                     = xztitivv
*      yztitivv                     = yztitivv.
*

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
*                       FROM ZTItig04
*                       WHERE epart EQ ZTITRQK-opnbk ).
*    ENDIF.
    DESCRIBE TABLE IT_PRTCTL LINES G_LINE.
    IF G_LINE EQ C_ZERO.
      CLEAR: IT_PRTCTL.
      MOVE: T001-LAND1    TO    IT_PRTCTL-LAND1,
            SY-LANGU      TO    IT_PRTCTL-SPRAS.
      APPEND IT_PRTCTL.
    ENDIF.
  ENDIF.

*> Get Output Paramenters
  PERFORM GET_OUTPUT_INFORMATION TABLES IT_PRTCTL
                                 USING  G_ANSWER.
  IF G_ANSWER EQ C_Y.

    LOOP AT IT_PRTCTL WHERE FLAG EQ C_TRUE.
**> Get SMARTFORM NAME
*      PERFORM p7000_set_smart_form_name USING 'IV'
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

  LOOP AT IT_TAB INTO G_TC_2130_WA.
*> 정가 계산.
*    IF ztitvak-prpyn EQ c_chari.
    CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
      EXPORTING
        PEINH = G_TC_2130_WA-PEINH
        BPUMZ = G_TC_2130_WA-BPUMZ
        BPUMN = G_TC_2130_WA-BPUMN
        MENGE = G_TC_2130_WA-IVMNG
        NETPR = G_TC_2130_WA-NETPR
      CHANGING
        NETWR = G_TC_2130_WA-NETWR.

    IF SY-DYNNR           EQ C_SCR0100.
      IF G_TC_2130_WA-NETWR NE G_TC_2130_WA-REFWR.
        G_TC_2130_WA-NETWR = G_TC_2130_WA-REFWR.
      ENDIF.
    ENDIF.

    IF G_TC_2130_WA-REFWR IS INITIAL OR
       SY-DYNNR           EQ C_SCR0100.
      G_TC_2130_WA-REFWR = G_TC_2130_WA-NETWR.
    ENDIF.
*    ENDIF.
*>Get 플랜트명 및 사업장코드.
    IF NOT G_TC_2130_WA-WERKS IS INITIAL.
      SELECT SINGLE NAME1 J_1BBRANCH
        INTO (G_TC_2130_WA-NAME1, G_TC_2130_WA-BUPLA)
        FROM T001W
       WHERE WERKS  EQ  G_TC_2130_WA-WERKS.
    ELSE.
      CLEAR: G_TC_2130_WA-NAME1, G_TC_2130_WA-BUPLA.
    ENDIF.

*>Get 저장위치명.
    IF NOT G_TC_2130_WA-LGORT IS INITIAL.
      SELECT SINGLE LGOBE
        INTO (G_TC_2130_WA-LGOBE)
        FROM T001L
       WHERE WERKS  EQ  G_TC_2130_WA-WERKS
         AND LGORT  EQ  G_TC_2130_WA-LGORT.
    ELSE.
      CLEAR G_TC_2130_WA-LGOBE.
    ENDIF.

*>Get 납품일.
    CLEAR: L_EINDT.
    SELECT MIN( EINDT ) INTO L_EINDT
      FROM EKET
     WHERE EBELN EQ G_TC_2130_WA-EBELN
       AND EBELP EQ G_TC_2130_WA-EBELP.

    IF L_EINDT IS INITIAL.
      CLEAR G_TC_2130_WA-EEIND.
    ELSE.
      WRITE L_EINDT TO G_TC_2130_WA-EEIND.
    ENDIF.
    MODIFY IT_TAB FROM G_TC_2130_WA.
  ENDLOOP.

ENDFORM.                    " SET_OTHERS_FIELDS_BY_ITEMS
*&---------------------------------------------------------------------*
*&      Form  get_Import_vendors_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_IMPORT_VENDORS_TEXT USING P_MSGTY.

  IF ZTITVAK-LIFNR IS INITIAL.
    CLEAR: LFA1.
  ELSE.
    SELECT SINGLE * FROM LFA1
     WHERE LIFNR EQ ZTITVAK-LIFNR.
    IF SY-SUBRC NE 0.
      PERFORM MESSAGE_NOT_FOUND_VENDOR USING 'ZTITVAK'
                                             'LIFNR'
                                             P_MSGTY.
    ENDIF.
  ENDIF.
*->CSR 2014031800051 엠트론_원화일 경우 개설은행 공란으로 함
  IF ZTITVAK-BUKRS = '3000' AND ZTITVAK-WAERS = 'KRW'.
    EXIT.
  ENDIF.
*<-CSR 2014031800051 엠트론_원화일 경우 개설은행 공란으로 함
  IF ZTITBLK-BLDTY NE 'A'.
    IF ZTITVAK-OPNBK IS INITIAL.
      PERFORM NO_INPUT_CHECK USING 'ZTITVAK' 'OPNBK' C_ERROR.
    ENDIF.
    SELECT SINGLE *
      FROM ZTSTIG3
     WHERE PARTI EQ C_CHARB
       AND EPART EQ ZTITVAK-OPNBK
       AND BUKRS EQ ZTITVAK-BUKRS.
    IF SY-SUBRC NE 0.
      IF SY-DYNNR EQ C_SCR0100 OR
         SY-DYNNR EQ C_SCR0200.
        MESSAGE S918 WITH ZTITVAK-OPNBK.
      ELSE.
        MESSAGE E918 WITH ZTITVAK-OPNBK.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_Import_vendors_text
*&---------------------------------------------------------------------*
*&      Form  check_iv_sub_document_exist
*&---------------------------------------------------------------------*
*       하위문서 존재여부 체크.
*----------------------------------------------------------------------*
FORM CHECK_IV_SUB_DOCUMENT_EXIST  USING    P_VATNO
                                           P_RBLGP
                                           P_MSGTY
                                           P_SUBRC.
  DATA: L_COUNT TYPE I.

  CLEAR: P_SUBRC.

  CHECK NOT P_VATNO IS INITIAL.

**> Notice 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ztitpnp
*   WHERE vatno   EQ  p_vatno
*     AND rblgp   EQ  p_rblgp.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER '109' WITH 'Notice'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.

ENDFORM.                    " check_iv_sub_document_exist
*&---------------------------------------------------------------------*
*&      Form  SET_INITIAL_VALUE
*&---------------------------------------------------------------------*
FORM SET_INITIAL_VALUE .

*> 문서 종류.
  G_DOCUMENT = C_VA.

  REFRESH: IT_TAB, IT_ZTITVAH,
           XZTITVAP, YZTITVAP.

*
  CLEAR :  IT_TAB, IT_ZTITVAH,
           XZTITVAP, YZTITVAP,
           ZTITVAK,     ">수입의뢰 Header
          *ZTITVAK,    ">수입의뢰 Header
           LFA1,
          *LFA1,
           OK_CODE_POPUP.

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
      READ TABLE IT_TAB INTO G_TC_2130_WA INDEX G_FINDLINE.
      IF SY-SUBRC NE 0.
        EXIT.
      ENDIF.
      CHECK OK_CODE EQ 'ZTISELECT'.   ">문서선택.

      CASE G_FIELDNAME.

        WHEN 'ZTISVAIT-REQNO' OR 'ZTISVAIT-REQIT'.
          PERFORM DISPLAY_IMPORT_DOCUMENT USING G_TC_2130_WA-REQNO
                                                G_TC_2130_WA-REQIT
                                                '00000'.
        WHEN 'ZTISVAIT-EBELN' OR 'ZTISVAIT-EBELP'.
          PERFORM DISPLAY_PURCHASE_ORDER USING G_TC_2130_WA-EBELN
                                               G_TC_2130_WA-EBELP.
        WHEN 'ZTISVAIT-MATNR'.
          PERFORM DISPLAY_MATERIAL_MASTER USING G_TC_2130_WA-MATNR
                                                G_TC_2130_WA-WERKS
                                                G_TC_2130_WA-LGORT.
      ENDCASE.
    ENDIF.
  ELSE.
    GET CURSOR FIELD G_FIELDNAME.
    IF SY-SUBRC EQ 0.
      G_FINDSCR = SY-DYNNR.
      CHECK OK_CODE EQ 'ZTISELECT'.   ">문서선택.

      CASE G_FIELDNAME.
        WHEN 'ZTITVAK-LIFNR'.
          PERFORM DISPLAY_VENDOR_MASTER USING ZTITVAK-LIFNR
                                              ZTITVAK-EKORG.
        WHEN 'ZTITVAK-BELNR'.
          PERFORM DISPLAY_LIV_DOCUMENT  USING ZTITVAK-BELNR
                                              ZTITVAK-GJAHR
                                              ZTITVAK-BUKRS.
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
                            USING    P_ZTITVAK STRUCTURE ZTITVAK.

  DATA: L_LPONR LIKE P_ZTITVAK-LPONR.

  IF G_MODE EQ C_CHARC.
    CLEAR: L_LPONR.
    LOOP AT P_IT_TAB.
      ADD 1 TO L_LPONR.
      MOVE L_LPONR TO P_IT_TAB-RBLGP.
      MODIFY P_IT_TAB.
    ENDLOOP.
    MOVE L_LPONR TO P_ZTITVAK-LPONR.
  ELSE.
    CLEAR: G_LINES.
    LOOP AT P_IT_TAB.
      IF NOT P_IT_TAB-RBLGP IS INITIAL.
        PERFORM CHECK_IV_SUB_DOCUMENT_EXIST USING P_IT_TAB-VATNO
                                                  P_IT_TAB-RBLGP
                                                  C_NONE
                                                  G_SUBRC.
        IF G_SUBRC NE C_ZERO.
          ADD 1 TO G_LINES.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF G_LINES GT C_ZERO.
      CLEAR: L_LPONR.
      LOOP AT P_IT_TAB.
        IF P_IT_TAB-REQIT IS INITIAL.
          ADD 1 TO P_ZTITVAK-LPONR.
          MOVE P_ZTITVAK-LPONR TO P_IT_TAB-RBLGP.
        ENDIF.
        MODIFY P_IT_TAB.
      ENDLOOP.
    ELSE.
      CLEAR: L_LPONR.
      LOOP AT P_IT_TAB.
        ADD 1 TO L_LPONR.
        MOVE L_LPONR TO P_IT_TAB-RBLGP.
        MODIFY P_IT_TAB.
      ENDLOOP.
      MOVE L_LPONR TO P_ZTITVAK-LPONR.
    ENDIF.
  ENDIF.
  CLEAR: L_LPONR.
  LOOP AT P_IT_TAB.
    IF P_IT_TAB-RBLGP GT L_LPONR.
      MOVE P_IT_TAB-RBLGP TO L_LPONR.
    ENDIF.
  ENDLOOP.
  MOVE L_LPONR TO P_ZTITVAK-LPONR.

ENDFORM.                    " set_item_number_build
*&---------------------------------------------------------------------*
*&      Form  set_function_by_BUSINESS
*&---------------------------------------------------------------------*
FORM SET_FUNCTION_BY_BUSINESS .

  IF G_DOCUMENT EQ C_VA.
    IF ZTITVAK-LIVST NE C_CHARP.
      MOVE 'ZTIACDOC'     TO FTAB-FCODE.   APPEND FTAB. ">후속문서.
      MOVE 'ZTIMMDOC'     TO FTAB-FCODE.   APPEND FTAB. ">송장문서.
    ENDIF.
  ENDIF.

  IF G_DOCUMENT EQ C_GR.
    IF ZTITGRK-IGRST NE C_CHARG.
      MOVE 'ZTIACDOC'     TO FTAB-FCODE.   APPEND FTAB. ">후속문서.
      MOVE 'ZTIMMDOC'     TO FTAB-FCODE.   APPEND FTAB. ">송장문서.
    ENDIF.
  ENDIF.

ENDFORM.                    " set_function_by_BUSINESS
*&---------------------------------------------------------------------*
*&      Form  read_iv_item_data
*&---------------------------------------------------------------------*
FORM READ_IV_ITEM_DATA  CHANGING P_IT_TAB  LIKE IT_TAB.

  CLEAR G_TC_2130_WA.
  LOOP AT P_IT_TAB INTO G_TC_2130_WA.
*     p/o정보.
    SELECT SINGLE WERKS NAME1 LGORT MATNR TXZ01
           LOEKZ ELIKZ BPRME BPUMZ BPUMN
           UMREZ UMREN NETPR PEINH UEBTO UEBTK UNTTO
*        INTO (p_it_tab-werks, p_it_tab-name1, p_it_tab-lgort,
*              p_it_tab-matnr, p_it_tab-txz01,
*              p_it_tab-loekz, p_it_tab-elikz, p_it_tab-bprme,
*              p_it_tab-bpumz, p_it_tab-bpumn, p_it_tab-umrez,
*              p_it_tab-umren, p_it_tab-netpr, p_it_tab-peinh,
*              p_it_tab-uebto, p_it_tab-uebtk, p_it_tab-untto)
      INTO  CORRESPONDING FIELDS OF G_TC_2130_WA
      FROM  ZTIVPO00
     WHERE  EBELN  = G_TC_2130_WA-EBELN
       AND  EBELP  = G_TC_2130_WA-EBELP.

**     bl 정보 수량.
*    SELECT  SINGLE blmng
*      INTO  g_tc_2130_wa-menge
*      FROM  ztitblp
*     WHERE  iblno  = g_tc_2130_wa-iblno
*       AND  iblit  = g_tc_2130_wa-iblit.
*
*     i/v 누적수량.
*    SELECT  SUM( remng ) INTO g_tc_2130_wa-ivmngs FROM ZTITVAP
*     WHERE  iblno  = g_tc_2130_wa-iblno
*       AND  iblit  = g_tc_2130_wa-iblit.
*
**     i/v 가능수량.
*    g_tc_2130_wa-ivmngl = g_tc_2130_wa-menge - g_tc_2130_wa-ivmngs.
*

    MODIFY P_IT_TAB FROM G_TC_2130_WA INDEX SY-TABIX.
  ENDLOOP.

ENDFORM.                    " read_iv_item_data
*&---------------------------------------------------------------------*
*&      Form  SET_INVOICE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_INVOICE_DATA .

  TABLES: TCURC.
*  DATA  : l_pkchg LIKE ztitvak-pkchg.
  DATA  : L_REMNG LIKE G_TC_2130_WA-REMNG.
  DATA  : L_ITEM  LIKE ITEMDATA.
*  DATA  : l_LBLNI LIKE ESSR-LBLNI.

  G_ANSWER = C_CHARY.

  FREE:  ITEMDATA,      TAXDATA,          WITHTAXDATA,
         RETURN,        ACCOUNTINGDATA,   VENDORITEMSPLITDATA,
         GLACCOUNTDATA, MATERIALDATA.


  CLEAR: HEADERDATA,    INVOICEDOCNUMBER, FISCALYEAR,
         ADDRESSDATA,
         ITEMDATA,      TAXDATA,          WITHTAXDATA,
         RETURN,        ACCOUNTINGDATA,   VENDORITEMSPLITDATA,
         GLACCOUNTDATA, MATERIALDATA.

*iso code용.
  SELECT SINGLE *
    FROM TCURC
   WHERE WAERS EQ ZTITVAK-WAERS.

***>>>>>>>>>>>>header data
  IF ZTITVAK-VORGANG EQ C_CHAR1 OR ZTITVAK-VORGANG EQ C_CHAR3 .
    MOVE C_TRUE  TO HEADERDATA-INVOICE_IND."지시자: 송장전기
  ELSE.
    MOVE C_FALSE  TO HEADERDATA-INVOICE_IND.
  ENDIF.

  MOVE  ZTITVAK-BLART TO  HEADERDATA-DOC_TYPE.  "전표유형
  MOVE  ZTITVAK-BLDAT TO  HEADERDATA-DOC_DATE.  "전표증빙일
  MOVE  ZTITVAK-BUDAT TO  HEADERDATA-PSTNG_DATE."전표의 전기일
  MOVE  ZTITVAK-XBLNR TO  HEADERDATA-REF_DOC_NO."참조전표번호
  MOVE  ZTITVAK-BUKRS TO  HEADERDATA-COMP_CODE. "회사코드
*  MOVE  ZTITVAK-lifnr TO  headerdata-diff_inv.  "다른 송장발행처
  MOVE  ZTITVAK-APVEN TO  HEADERDATA-DIFF_INV.  "다른 송장발행처
  MOVE  ZTITVAK-WAERS TO  HEADERDATA-CURRENCY.  "통화키
  MOVE  TCURC-ISOCD   TO  HEADERDATA-CURRENCY_ISO."ISO 통화코드

  IF ZTITVAK-WAERS NE T001-WAERS.
    MOVE  ZTITVAK-KURSF TO  HEADERDATA-EXCH_RATE. "직접호가환율*
*    headerdata-EXCH_RATE_V."간접호가환율
  ENDIF.
  WRITE : ZTITVAK-WRBTR TO G_TEXT_AMOUNT CURRENCY ZTITVAK-WAERS.
  PERFORM SET_WRITE_NO_MASK   USING G_TEXT_AMOUNT.
  MOVE  G_TEXT_AMOUNT TO  HEADERDATA-GROSS_AMOUNT."총송장금액
*  headerdata-CALC_TAX_IND."세금을 자동으로 계산
  MOVE  ZTITVAK-ZTERM TO  HEADERDATA-PMNTTRMS.  "지급조건키
  MOVE  ZTITVAK-ZFBDT TO  HEADERDATA-BLINE_DATE."만기계산기준일

**************************************************************
*> SB, Kang [ 05/03/11 ] : 지급조건키만 넘기도록 수정
*>    Why? Standard에서 양쪽의 값이 들어오면 오류발생함.
**************************************************************
*  MOVE  ZTITVAK-zbd1t TO  headerdata-dsct_days1."현금할인기간 1
*  MOVE  ZTITVAK-zbd2t TO  headerdata-dsct_days2."현금 할인기간 2
*  MOVE  ZTITVAK-zbd3t TO  headerdata-netterms.  "순액지급조건기간
*  MOVE  ZTITVAK-zbd1p TO  headerdata-dsct_pct1. "현금할인율 1
*  MOVE  ZTITVAK-zbd2p TO  headerdata-dsct_pct2. "현금할인율 1
**************************************************************

*  headerdata-IV_CATEGORY."물류송장검증 문서의 원본
  MOVE  ZTITVAK-BKTXT TO  HEADERDATA-HEADER_TXT."전표헤더텍스트
  MOVE  ZTITVAK-ZLSPR TO  HEADERDATA-PMNT_BLOCK."지급보류키

*>비계획운송비용.
*  CLEAR l_pkchg.
*  l_pkchg  =
*  ztitvak-pkchg + ztitvak-hdchg + ztitvak-otchg.
*  ZTITVAK-pkchg + ZTITVAK-hdchg + ZTITVAK-otchg + ZTITVAK-rtchg.
*  WRITE : l_pkchg TO g_text_amount CURRENCY ztitvak-waers.
*  PERFORM set_write_no_mask   USING g_text_amount.
*  MOVE  g_text_amount TO  headerdata-del_costs."비계획운송비용
*  headerdata-DEL_COSTS_TAXC."운송비용 세금코드
*  headerdata-DEL_COSTS_TAXJ."운송비용에 대한 조세관할코드
  MOVE  SY-UNAME       TO  HEADERDATA-PERSON_EXT."외부시스템 사용자.
  MOVE  ZTITVAK-ZLSCH TO  HEADERDATA-PYMT_METH. "지급방법
  MOVE  ZTITVAK-UZAWE TO  HEADERDATA-PMTMTHSUPL."지급방법보충
  MOVE  ZTITVAK-BELNR TO  HEADERDATA-INV_DOC_NO."송장문서문서번호
*  headerdata-SCBANK_IND."중앙은행지시자
*  headerdata-SUPCOUNTRY."공급국가
*  headerdata-BLLSRV_IND."서비스지시자 (해외지급)
  MOVE  ZTITVAK-XBLNR TO  HEADERDATA-REF_DOC_NO_LONG."참조전표번호
*  headerdata-DSCT_AMOUNT."문서통화의 현금할인액
*  headerdata-PO_SUB_NO."POR 서명자번호
*  headerdata-PO_CHECKDG."POR 점검숫자
*  headerdata-PO_REF_NO."POR 참조번호
*  headerdata-PAYEE_PAYER."수취인 / 지급인
*  headerdata-PARTNER_BK."거래처은행유형


*-{ 기능개선 161906 - 거래은행 로직 삭제
**>거래은행에 대한 단축키.
*  SELECT SINGLE *
*      FROM ZTSTIG3
*     WHERE PARTI EQ C_CHARB
*       AND EPART EQ ZTITVAK-OPNBK
*       AND BUKRS EQ ZTITVAK-BUKRS.
*  IF SY-SUBRC      EQ 0 AND
*     NOT ZTSTIG3-HBKID IS INITIAL.
*    MOVE ZTSTIG3-HBKID TO HEADERDATA-HOUSEBANKID.
*  ENDIF.
*-} 기능개선 161906

  MOVE ZTITVAK-ZUONR TO HEADERDATA-ALLOC_NMBR.       "지정번호
*  headerdata-PAYMT_REF."지급참조
*  headerdata-INV_REF_NO."송장참조: 송장참조를 위한 문서번호
*  headerdata-INV_YEAR."관련송장의 회계연도 (대변메모)
*  headerdata-INV_REC_DATE."송장수령일
*  headerdata-PLANNING_LEVEL."계획레벨
*  headerdata-PLANNING_DATE."계획일
*  headerdata-FIXEDTERMS."고정지급조건
  MOVE  ZTITVAK-GSBER TO  HEADERDATA-BUS_AREA.  "사업영역
*  headerdata-LOT_NUMBER."전표 로트번호
  MOVE  ZTITVAK-SGTXT TO  HEADERDATA-ITEM_TEXT. "항목텍스트

**> 분할금액이 있을 경우.
*  DESCRIBE TABLE it_ztitivv LINES g_line.
*  CLEAR: g_count.
*  IF g_line GT 0.
**  IF NOT ZTITVAK-rtchg IS INITIAL.
*    LOOP AT it_ztitivv.
*      WRITE : it_ztitivv-splam TO g_text_amount CURRENCY ztitvak-waers.
*      PERFORM set_write_no_mask   USING g_text_amount.
*      MOVE: it_ztitivv-split TO vendoritemsplitdata-split_key,
*            g_text_amount    TO vendoritemsplitdata-split_amount,
*            it_ztitivv-zlsch TO vendoritemsplitdata-pymt_meth,
*            it_ztitivv-mwskz TO vendoritemsplitdata-tax_code,
*            it_ztitivv-uzawe TO vendoritemsplitdata-pmtmthsupl,
*            it_ztitivv-zterm TO vendoritemsplitdata-pmnttrms.
*      APPEND vendoritemsplitdata.
*    ENDLOOP.
*  ENDIF.
*
*>>>>>>>>>>>>>>>item.
  LOOP AT IT_TAB INTO G_TC_2130_WA WHERE EBELN NE SPACE.
*    CALL FUNCTION 'ME_READ_HISTORY'
*      EXPORTING
*        ebeln                    = g_tc_2130_wa-ebeln
*        EBELP                    = g_tc_2130_wa-ebelp
*        webre                    =
**       I_BYPASSING_BUFFER       =
**       I_REFRESH_BUFFER         =
**     TABLES
**       XEKBE                    =
**       XEKBES                   =
**       XEKBEZ                   =
**       XEKBNK                   =
**       XEKBZ                    =
*              .
*

*    MOVE g_tc_2130_wa-rblgp TO  itemdata-invoice_doc_item.
    "송장문서의 문서품목
    MOVE G_TC_2130_WA-EBELN TO ITEMDATA-PO_NUMBER.  "구매오더번호.
    MOVE G_TC_2130_WA-EBELP TO ITEMDATA-PO_ITEM.    "구매문서 품목번호.
    MOVE G_TC_2130_WA-LFBNR TO ITEMDATA-REF_DOC.    "참조문서의 문서번호
    MOVE G_TC_2130_WA-LFGJA TO ITEMDATA-REF_DOC_YEAR. "현재기간 회계연도
    MOVE G_TC_2130_WA-LFPOS TO ITEMDATA-REF_DOC_IT.   "참조문서품목
    MOVE G_TC_2130_WA-TBTKZ TO ITEMDATA-DE_CRE_IND.   "후속 차변/대변
    MOVE G_TC_2130_WA-MWSKZ TO ITEMDATA-TAX_CODE.     "세금코드
*        itemdata-TAXJURCODE"세금계산 관할구역 - 조세관할코드



*    WRITE : g_tc_2130_wa-refwr TO g_text_amount CURRENCY ZTITVAK-waers.
    WRITE : G_TC_2130_WA-REFWR TO G_TEXT_AMOUNT CURRENCY ZTITVAK-WAERS.
    PERFORM SET_WRITE_NO_MASK   USING G_TEXT_AMOUNT.
    MOVE G_TEXT_AMOUNT         TO  ITEMDATA-ITEM_AMOUNT."전표통화금액
*> 송장처리수량 = 송장수량 - 선급수량.
*    l_remng = g_tc_2130_wa-remng - g_tc_2130_wa-ppmng.
*    l_remng = g_tc_2130_wa-IVMNG.
    L_REMNG = G_TC_2130_WA-IVMNG.
    IF L_REMNG LE C_ZERO.
      CONTINUE.
    ENDIF.

    WRITE : L_REMNG            TO G_TEXT_AMOUNT UNIT XZTITVAP-MEINS.
    PERFORM SET_WRITE_NO_MASK   USING G_TEXT_AMOUNT.
    MOVE G_TEXT_AMOUNT         TO  ITEMDATA-QUANTITY.   "수량
    MOVE G_TC_2130_WA-MEINS    TO  ITEMDATA-PO_UNIT.    "오더단위
*        itemdata-PO_UNIT_ISO"ISO 코드 오더단위

    SELECT SINGLE PEINH BPRME
      FROM EKPO
      INTO (ITEMDATA-PO_PR_QNT,ITEMDATA-PO_PR_UOM)
     WHERE EBELN EQ G_TC_2130_WA-EBELN
       AND EBELP EQ G_TC_2130_WA-EBELP.
*    MOVE    itemdata-PO_PR_QNT"구매오더가격단위의 수량
*    MOVE    itemdata-PO_PR_UOM"오더가격단위 BPRME

*        itemdata-PO_PR_UOM_ISO"ISO 코드의 구매오더 가격단위
*    MOVE XZTITVAP-kschl TO  itemdata-cond_type.  "조건유형
*    MOVE XZTITVAP-stunr TO  itemdata-cond_st_no. "단계번호
*    MOVE XZTITVAP-zaehk TO  itemdata-cond_count. "조건카운터
*        itemdata-SHEET_NO"입력서번호
    MOVE G_TC_2130_WA-SGTXT TO  ITEMDATA-ITEM_TEXT.  "항목텍스트
*        itemdata-FINAL_INV"최종송장지시자
*        itemdata-SHEET_ITEM"라인번호
*        itemdata-GRIR_CLEAR_SRV
*                      "외부서비스에 대한 GR/IR 전기의 반제지시자
*        itemdata-FREIGHT_VEN"구매처 또는 채권자 계정번호

***** 서비스 오더에 대한 로직.
*   입력서 번호 찾기.
    SELECT SINGLE LBLNI
      FROM ESSR
      INTO ITEMDATA-SHEET_NO
     WHERE EBELN EQ G_TC_2130_WA-EBELN
       AND EBELP EQ G_TC_2130_WA-EBELP.

*   입력서 번호가 있으면 수량/단위 clear.
    IF NOT ITEMDATA-SHEET_NO IS INITIAL.
      CLEAR : ITEMDATA-QUANTITY, ITEMDATA-PO_UNIT,
              ITEMDATA-PO_PR_QNT,ITEMDATA-PO_PR_UOM.
    ENDIF.
**********

    READ TABLE ITEMDATA INTO L_ITEM
                        WITH KEY PO_NUMBER = ITEMDATA-PO_NUMBER
                                 PO_ITEM   = ITEMDATA-PO_ITEM.
    IF SY-SUBRC EQ 0.
      ITEMDATA-PO_PR_QNT = 0.
    ENDIF.

    COLLECT ITEMDATA.
*    APPEND itemdata.
  ENDLOOP.

  CLEAR: G_COUNT.
  LOOP AT ITEMDATA.
    ADD 1 TO G_COUNT.
    ITEMDATA-INVOICE_DOC_ITEM = G_COUNT.
    MODIFY ITEMDATA.

    CLEAR: TAXDATA.
    MOVE: ITEMDATA-TAX_CODE TO TAXDATA-TAX_CODE,
          0                 TO TAXDATA-TAX_AMOUNT ,
          0                 TO TAXDATA-TAX_BASE_AMOUNT.
    COLLECT TAXDATA.
  ENDLOOP.

*  refresH: materialdata.
*  LOOP AT itemdata.
*    clear: materialdata.
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
*          itemdata-de_cre_ind       to materialdata-DB_CR_IND,
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

*  TABLES: /nfm/torderpos.
*  REFRESH: nfmetallitms.
*  LOOP AT itemdata.
*    SELECT *
*      INTO CORRESPONDING FIELDS OF TABLE nfm_torderpos
*      FROM /nfm/torderpos
*     WHERE blt     EQ c_charb   ">구매오더.
*       AND belnr   EQ itemdata-po_number
*       AND posnr   EQ itemdata-po_item
*       AND bukrs   EQ ZTITVAK-bukrs.
*
*    LOOP AT nfm_torderpos.
*      MOVE: itemdata-invoice_doc_item TO nfmetallitms-data_index,
*            nfm_torderpos-belnr       TO nfmetallitms-doc_number,
*            nfm_torderpos-posnr       TO nfmetallitms-itm_number,
*            nfm_torderpos-bukrs       TO nfmetallitms-compcode,
*            ZTITVAK-gjahr             TO nfmetallitms-fiscyear,
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
*      APPEND nfmetallitms.
*    ENDLOOP.
*  ENDLOOP.
*
*  CLEAR: taxdata.
**  taxdata-tax_code         =  ZTITVAK-mwskz. "부가가치세코드.
*  taxdata-tax_amount       =  0.     "전표통화세액.
*  taxdata-tax_base_amount  =  0.     "문서통화로 표시된 과세표준액.
*  APPEND taxdata.
*
ENDFORM.                    " SET_INVOICE_DATA
*&---------------------------------------------------------------------*
*&      Form  set_cancel_document_number
*&---------------------------------------------------------------------*
FORM SET_CANCEL_DOCUMENT_NUMBER USING P_ZTISSCRCOM STRUCTURE ZTISSCRCOM.
*> Set default value
  PERFORM FILL_ACCOUNT_HEADER_CANCEL USING P_ZTISSCRCOM.

  MOVE: ZTITVAK-BELNR   TO   P_ZTISSCRCOM-BELNR,
        ZTITVAK-GJAHR   TO   P_ZTISSCRCOM-GJAHR,
        ZTITVAK-BUKRS   TO   P_ZTISSCRCOM-BUKRS,
        ZTITVAK-BLART   TO   P_ZTISSCRCOM-BLART,
*        ZTITVAK-lifnr   TO   p_ztisscrcom-lifnr,
        ZTITVAK-APVEN   TO   P_ZTISSCRCOM-LIFNR,
        ZTITVAK-WAERS   TO   P_ZTISSCRCOM-WAERS,
        ZTITVAK-WRBTR   TO   P_ZTISSCRCOM-WRBTR.

  IF P_ZTISSCRCOM-CBUDAT IS   INITIAL.
    MOVE: SY-DATLO       TO   P_ZTISSCRCOM-CBUDAT.
  ENDIF.

  SPOP-TEXTLINE1 = '해당 송장문서를 취소하시겠습니까?'.

ENDFORM.                    " set_cancel_document_number
*&---------------------------------------------------------------------*
*&      Form  check_document_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_DOCUMENT_STATUS .

  DATA: L_DDTEXT LIKE G_DDTEXT.

*> 문서상태 Fixed value read.
  PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTILIVST'
                                             SY-LANGU
                                             ZTITVAK-LIVST
                                             G_DDTEXT
                                             C_SUCCESS.
  L_DDTEXT = G_DDTEXT.

  CASE G_MODE.
    WHEN C_CHARP.    ">전기모드.
      IF ZTITVAK-LIVST EQ C_CHARP.
        MESSAGE E919 WITH G_DDTEXT.
      ENDIF.
    WHEN C_CHARR.    ">취소모드.
      IF ZTITVAK-LIVST EQ C_CHARN.
        MESSAGE E919 WITH G_DDTEXT.
      ENDIF.
    WHEN C_CHARM.    ">변경모드.
      IF ZTITVAK-LIVST EQ C_CHARP.
        MESSAGE E919 WITH G_DDTEXT.
      ENDIF.
    WHEN C_CHARD.    ">삭제모드.
      IF ZTITVAK-LIVST EQ C_CHARP.
        MESSAGE E919 WITH G_DDTEXT.
      ENDIF.
  ENDCASE.

  MESSAGE S922 WITH G_DDTEXT.

ENDFORM.                    " check_document_status
*&---------------------------------------------------------------------*
*&      Form  check_open_amount
*&---------------------------------------------------------------------*
FORM CHECK_OPEN_AMOUNT .
  DATA : L_RATE                TYPE F,
         L_TEXT_EXRATE(255)    TYPE C,
         L_FOREIGN_FACTOR(255) TYPE C,
         L_FACTOR              TYPE P,
         L_AMOUNT              TYPE ZTIOPAMT,
         L_PPAMT               TYPE ZTIPPAM2,
         L_FIXED_RATE          LIKE TCURS-SPRED,
         L_LOCAL_AMT           LIKE ZTITRQS-USAMT.  " USD 환산 Amount

  DATA: L_WEMNG     LIKE EKBES-WEMNG,
        L_REMNG     LIKE EKBES-REMNG,
        L_REMNG_TMP LIKE EKBES-REMNG,
        L_WEWRT     LIKE EKBES-WEWRT,
        L_AREWR     LIKE EKBES-AREWR,
        L_REWRT     LIKE EKBES-REWRT.

  DATA BEGIN OF IEKBES OCCURS 0.
  INCLUDE STRUCTURE EKBES.
  DATA END OF IEKBES.


  IF G_MODE EQ C_CHARC OR
     G_MODE EQ C_CHARM OR
     G_MODE EQ C_CHARP.
*> P/O 총금액 계산.
    PERFORM GET_TOTAL_PO_AMOUNT         TABLES GT_EKPO
                                        USING  ZTISSCRCOM-POAMT.
  ENDIF.

  CLEAR: G_WRBTR, L_PPAMT.
  LOOP AT IT_TAB INTO G_TC_2130_WA.
*>
    IF G_MODE EQ C_CHARC OR
       G_MODE EQ C_CHARM OR
       G_MODE EQ C_CHARP.

      IF ZTITVAK-EBELN IS INITIAL.
        ZTITVAK-EBELN = G_TC_2130_WA-EBELN.
      ENDIF.

      IF ZTITVAK-WERKS IS INITIAL.
        ZTITVAK-WERKS = G_TC_2130_WA-WERKS.
      ENDIF.

      IF ZTITVAK-BUPLA IS INITIAL.
        SELECT SINGLE J_1BBRANCH
          INTO ZTITVAK-BUPLA
          FROM T001W
         WHERE WERKS EQ G_TC_2130_WA-WERKS.
      ENDIF.


*    CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
*      EXPORTING
*        peinh = lt_ekpo-peinh
*        bpumz = lt_ekpo-bpumz
*        bpumn = lt_ekpo-bpumn
*        menge = lt_ekpo-menge
*        netpr = lt_ekpo-netpr
*      CHANGING
*        netwr = lt_ekpo-netwr.
*

**> 전체구매오더 금액 대비 인보이스 품목 금액 비율.
*      IF NOT g_tc_2130_wa-ebeln IS INITIAL.
*        READ TABLE gt_ekpo WITH KEY ebeln = g_tc_2130_wa-ebeln
*                                    ebelp = g_tc_2130_wa-ebelp.
*
*        IF sy-subrc EQ 0.
**--> 구매오더보다 수량이 더클 경우.
*          IF g_tc_2130_wa-ivmng GT g_tc_2130_wa-ivmngi.
*            g_tc_2130_wa-ivmng = g_tc_2130_wa-ivmngi.
*          ENDIF.
*
**
**          IF g_tc_2130_wa-erekz EQ c_true.
***            g_tc_2130_wa-remng = g_tc_2130_wa-ivmngl.
**            CLEAR iekbes. REFRESH iekbes.
**
**            CALL FUNCTION 'ME_READ_HISTORY'
**              EXPORTING
**                ebeln              = g_tc_2130_wa-ebeln
**                ebelp              = g_tc_2130_wa-ebelp
**                webre              = gt_ekpo-webre
**                i_bypassing_buffer = 'X'
**                i_refresh_buffer   = 'X'
**              TABLES
***                xekbe              = iekbe
**                xekbes             = iekbes.
***                xekbez             = iekbez
***                xekbnk             = iekbnk
***                xekbz              = iekbz.
*** Goods receipts
**            CLEAR: l_wemng, l_remng,
**                   l_wewrt, l_arewr, l_rewrt.
**
**            LOOP AT iekbes WHERE zekkn EQ space
**                             AND ebelp EQ  g_tc_2130_wa-ebelp.
**              ADD iekbes-wemng TO l_wemng.  ">입고
**              ADD iekbes-remng TO l_remng.  ">송장처리
**              ADD iekbes-rewrt TO l_rewrt.  ">입고금액
**              ADD iekbes-wewrt TO l_wewrt.  ">송장금액
**              IF iekbes-rewrt <> iekbes-arewr.
**                ADD      iekbes-rewrt TO   l_wewrt.
**                SUBTRACT iekbes-arewr FROM l_wewrt.
**              ENDIF.
**            ENDLOOP.
**            g_tc_2130_wa-IVmng = gt_ekpo-menge - l_remng.
**            IF g_tc_2130_wa-remng GT g_tc_2130_wa-ivmngl.
**              g_tc_2130_wa-remng = g_tc_2130_wa-ivmngl.
**            ENDIF.
***            g_tc_2130_wa-refwr = gt_ekpo-netwr - l_wewrt.
**          ENDIF.
*        ENDIF.
*      ENDIF.

*> Tax code.
      IF G_TC_2130_WA-MWSKZ IS INITIAL.
        G_TC_2130_WA-MWSKZ = ZTITVAK-MWSKZ.
      ENDIF.
      MODIFY IT_TAB FROM G_TC_2130_WA.
    ENDIF.
    ADD G_TC_2130_WA-REFWR TO G_WRBTR.
  ENDLOOP.

*
**  l_amount = g_wrbtr - ztitvak-rtchg - l_ppamt.
*  l_amount = g_wrbtr.
*  IF l_amount LE 0.
**    CLEAR ztitvak-rtchg.
*    l_amount = g_wrbtr.
*    MESSAGE i317.
**    exit.
*  ENDIF.

*  IF ( g_mode EQ c_charc OR
*       g_mode EQ c_charm ).
*    l_amount = g_wrbtr + ztitvak-pkchg + ztitvak-hdchg
*                       + ztitvak-otchg.
**                       + ZTITVAK-rtchg.
**                       + ZTITVAK-ppamt.
*
*    IF ztitvak-ivamt IS INITIAL.
**      ZTITVAK-ivamt = g_wrbtr.
*      ztitvak-ivamt = l_amount.
*    ELSE.
*      IF ztitvak-ivamt NE l_amount.
**      IF ZTITVAK-ivamt NE g_wrbtr.
*        IF sy-dynnr EQ c_scr2000.
*          MESSAGE w308.
*        ENDIF.
**        ZTITVAK-ivamt = g_wrbtr.
*        ztitvak-ivamt = l_amount.
*      ENDIF.
*    ENDIF.
*  ELSE.
**    IF ZTITVAK-ivamt NE g_wrbtr.
*    IF ztitvak-ivamt NE l_amount.
*      MESSAGE s309.
*    ENDIF.
*  ENDIF.
*
*> 송장처리금액.
  ZTITVAK-WRBTR = G_WRBTR.



ENDFORM.                    " check_open_amount

*&---------------------------------------------------------------------*
*&      Form  handle_double_click
*&---------------------------------------------------------------------*
FORM HANDLE_DOUBLE_CLICK  USING  P_ROW P_COLUMN.

  READ TABLE IT_ZTITVAH INDEX P_ROW.

  CHECK SY-SUBRC = 0.

  CASE P_COLUMN.
    WHEN 'CBELNR' OR 'CGJAHR' OR 'CBUDAT'.
      IF NOT IT_ZTITVAH-CBELNR IS INITIAL.
        PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTITVAH-CBELNR
                                            IT_ZTITVAH-CGJAHR
                                            ZTITVAK-BUKRS.
      ENDIF.
    WHEN OTHERS.
      IF NOT IT_ZTITVAH-BELNR IS INITIAL.
        PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTITVAH-BELNR
                                            IT_ZTITVAH-GJAHR
                                            ZTITVAK-BUKRS.
      ENDIF.
  ENDCASE.

ENDFORM.                    "handle_double_click
*&---------------------------------------------------------------------*
*&      Form  handle_hotspot_click
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK  USING E_ROW_ID    TYPE LVC_S_ROW
                                 E_COLUMN_ID TYPE LVC_S_COL.

  READ TABLE IT_ZTITVAH INDEX E_ROW_ID-INDEX.

  CHECK SY-SUBRC = 0.

  CASE E_COLUMN_ID-FIELDNAME.
    WHEN 'CBELNR' OR 'CGJAHR' OR 'CBUDAT'.
      IF NOT IT_ZTITVAH-CBELNR IS INITIAL.
        PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTITVAH-CBELNR
                                            IT_ZTITVAH-CGJAHR
                                            ZTITVAK-BUKRS.
      ENDIF.
    WHEN OTHERS.
      IF NOT IT_ZTITVAH-BELNR IS INITIAL.
        PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTITVAH-BELNR
                                            IT_ZTITVAH-GJAHR
                                            ZTITVAK-BUKRS.
      ENDIF.
  ENDCASE.

ENDFORM.                    " handle_hotspot_click
*&---------------------------------------------------------------------*
*&      Form  scr2124_fieldcat_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SCR2124_FIELDCAT_BUILD .

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME = 'ZTISIVHS'
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
      WHEN 'VATNO' OR 'FLAG'.
        IT_FIELDCAT_LVC-NO_OUT  = C_TRUE.
************************************************************
*> For TraSys ECC Upgrade By ASEG Co., Ltd.
************************************************************
*> 2009/02/24
*> 문서번호 변경.
*> Started of Insert
************************************************************
      WHEN 'IVONO'.
        IT_FIELDCAT_LVC-FIELDNAME = 'VATNO'.
************************************************************
*> Ended of Insert
************************************************************
      WHEN OTHERS.
    ENDCASE.
    MODIFY IT_FIELDCAT_LVC.
  ENDLOOP.

ENDFORM.                    " scr2124_fieldcat_build
*&---------------------------------------------------------------------*
*&      Form  get_and_check_lc_data
*&---------------------------------------------------------------------*
*       Get 구매오더 데이타.
*----------------------------------------------------------------------*
FORM GET_AND_CHECK_LC_DATA  USING    P_REQNO
                                     P_AMDSQ
                                     P_REQIT
                                     P_MODIFY
                                     P_ZTIVRQ00 STRUCTURE ZTIVRQ00
                                     P_COUNT
                                     P_MSGTY.

  CLEAR: P_ZTIVRQ00.

  SELECT SINGLE * INTO P_ZTIVRQ00
    FROM ZTIVRQ00
   WHERE REQNO EQ P_REQNO
     AND AMDSQ EQ P_AMDSQ
     AND REQIT EQ P_REQIT.

*>구매오더 품목 정보..
  SELECT SINGLE *
    FROM EKPO
   WHERE EBELN EQ P_ZTIVRQ00-EBELN
     AND EBELP EQ P_ZTIVRQ00-EBELP.

  MOVE-CORRESPONDING : P_ZTIVRQ00 TO ZTITRQK,
                       P_ZTIVRQ00 TO ZTITRQS.

  IF SY-SUBRC EQ 0.
*>Vendor 체크.
    IF ZTITVAK-REQNO     NE P_ZTIVRQ00-REQNO AND
       NOT ZTITVAK-REQNO IS INITIAL.
      MESSAGE S704 WITH P_ZTIVRQ00-REQNO ZTITVAK-REQNO.
      P_MODIFY = C_TRUE.
      EXIT.
    ENDIF.

*>Vendor 체크.
    IF ZTITVAK-LIFNR     NE P_ZTIVRQ00-LIFNR AND
       NOT ZTITVAK-LIFNR IS INITIAL.
      MESSAGE S311 WITH P_ZTIVRQ00-LIFNR ZTITVAK-LIFNR.
      P_MODIFY = C_TRUE.
      EXIT.
    ENDIF.

*통화키 체크.
    IF ZTITVAK-WAERS    NE  P_ZTIVRQ00-WAERS AND
       P_COUNT           GT  C_ZERO.
      MESSAGE S312 WITH P_ZTIVRQ00-WAERS ZTITVAK-WAERS.
      P_MODIFY = C_TRUE.
    ENDIF.
*>기타 체크 로직.
*    SELECT SUM( IVMNG )
*      INTO
*> Lock Object
    PERFORM  SET_LC_LOCK_OBJECT  USING P_REQNO
                                       P_AMDSQ
                                       P_REQIT
                                       C_LOCK
                                       C_SUCCESS
                                       P_MODIFY.
  ELSE.
    MESSAGE S019(06) WITH P_REQNO.
    P_MODIFY = C_TRUE.
    EXIT.
  ENDIF.

ENDFORM.                    " get_and_check_lc_data
*&---------------------------------------------------------------------*
*&      Form  set_prepaid_invoice_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_PREPAID_INVOICE_DATA   TABLES P_IT_TAB   LIKE IT_TAB
                                USING  P_ZTIVRQ00 STRUCTURE ZTIVRQ00
                                       P_ZTITVAK  STRUCTURE ZTITVAK
                                       P_ZTISRQIT STRUCTURE IT_ZTISRQIT.
  CLEAR: P_IT_TAB.

  MOVE-CORRESPONDING P_ZTIVRQ00 TO : P_IT_TAB, P_ZTITVAK.

*  MOVE: p_ztisrqit-remng  TO p_it_tab-remng,
*        p_ztisrqit-remng  TO p_it_tab-ivmng,
*        p_ztisrqit-netwr  TO p_it_tab-refwr,
*        p_ztisrqit-netwr  TO p_it_tab-netwr,
*        p_ztisrqit-ppmng  TO p_it_tab-ppmng,
*        p_ztisrqit-ppamt  TO p_it_tab-ppamt,
*        p_ztisrqit-ivmngs TO p_it_tab-ivmngs,
*        p_ztisrqit-ivmngl TO p_it_tab-ivmngl.

  MOVE: SY-UNAME TO P_IT_TAB-CNAM,
        SY-DATLO TO P_IT_TAB-CDAT,
        SY-TIMLO TO P_IT_TAB-CTME,
        SY-UNAME TO P_IT_TAB-UNAM,
        SY-DATLO TO P_IT_TAB-UDAT,
        SY-TIMLO TO P_IT_TAB-UTME.

  IF NOT  P_IT_TAB-EBELN IS INITIAL.
* 구매오더 정보 Read.
    SELECT SINGLE MENGE WERKS LGORT MATNR TXZ01 MWSKZ
                  LOEKZ ELIKZ BPRME BPUMZ BPUMN UMREZ
                  UMREN NETPR PEINH UEBTO UEBTK UNTTO
    INTO CORRESPONDING FIELDS OF P_IT_TAB
      FROM EKPO
     WHERE EBELN  EQ  P_IT_TAB-EBELN
       AND EBELP  EQ  P_IT_TAB-EBELP.
*> 수입의뢰 정보 Read.
    IF NOT P_IT_TAB-REQNO IS INITIAL.
      SELECT SINGLE RQMNG
        INTO P_IT_TAB-RQMNG
        FROM ZTIVRQ00
       WHERE REQNO   EQ  P_IT_TAB-REQNO
         AND REQIT   EQ  P_IT_TAB-REQIT.

*      SELECT  SUM( remng )
*        INTO p_it_tab-ivmngs
*        FROM  ZTITVAP
*       WHERE  reqno       EQ  p_it_tab-reqno
*         AND  reqit       EQ  p_it_tab-reqit
*         AND NOT ( vatno  EQ  p_it_tab-vatno
*         AND       rblgp  EQ  p_it_tab-rblgp ).
**> 초과납품허용치.
*        if not ZTITBLP-UEBTO is initial.
*           ZTITBLP-rqmng = ZTITBLP-rqmng +
*                          ( ZTITBLP-rqmng * ZTITBLP-UEBTO ) / 100.
*        endif.
*        if not ZTITBLP-UEBTK is initial.
*
*        endif.
*      p_it_tab-ivmngl =  p_it_tab-rqmng - p_it_tab-ivmngs.
*      IF ztitvak-prpyn EQ 'P' OR
*         ztitvak-prpyn EQ 'R'.
*        p_it_tab-ivmng = p_it_tab-remng.
*      ENDIF.
    ENDIF.

*    IF p_it_tab-ivmngl LE 0.
*      p_it_tab-ivmngl = 0.
*    ENDIF.
*> 개설은행 정보.
    SELECT SINGLE OPNBK
      INTO P_ZTITVAK-OPNBK
      FROM ZTIVRQ04
     WHERE REQNO  EQ  P_IT_TAB-REQNO.
    IF SY-SUBRC       EQ 0 AND
       NOT P_ZTITVAK-OPNBK IS INITIAL.
      SELECT SINGLE *
        FROM ZTSTIG3
       WHERE PARTI  EQ  C_CHARB
         AND EPART  EQ  P_ZTITVAK-OPNBK
         AND BUKRS  EQ  P_ZTITVAK-BUKRS.
      IF SY-SUBRC NE 0.
        MESSAGE E918 WITH P_ZTITVAK-OPNBK.
      ENDIF.
      IF ZTITIG00-SJPAP EQ C_CHARV.
        P_ZTITVAK-APVEN = ZTITVAK-LIFNR.
      ELSEIF ZTITIG00-SJPAP EQ C_CHARB.
        P_ZTITVAK-APVEN = ZTSTIG3-LIFNR.
      ENDIF.
    ELSE.
      MESSAGE E322 WITH P_IT_TAB-REQNO.
    ENDIF.
**> 상업송장번호.
*    IF p_ztitvak-ivnum IS INITIAL.
*      p_ztitvak-ivnum = ztitrqs-opnno.
*    ENDIF.
    IF P_ZTITVAK-XBLNR IS INITIAL.
      P_ZTITVAK-XBLNR = ZTITRQS-OPNNO.
    ENDIF.
    IF P_ZTITVAK-SGTXT IS INITIAL.
      P_ZTITVAK-SGTXT = ZTITRQS-OPNNO.
    ENDIF.
  ENDIF.

  APPEND P_IT_TAB.

*>아이템 번호를 생성함.
  PERFORM SET_ITEM_NUMBER_BUILD TABLES P_IT_TAB
                                USING  P_ZTITVAK.

  PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.


ENDFORM.                    " set_prepaid_invoice_data
*&---------------------------------------------------------------------*
*&      Form  set_invoice_default_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_INVOICE_DEFAULT_VALUES .

  IF ZTITVAK-BUKRS IS INITIAL.
** 진로산업 Change 2007/04 --------------------------------------
*    ztitvak-bukrs = c_bukrs.
** 진로산업 Change 2007/04 --------------------------------------
  ENDIF.

  IF ZTITVAK-BUDAT IS INITIAL.
    ZTITVAK-BUDAT = SY-DATLO.
  ENDIF.

  IF ZTITVAK-BUPLA IS INITIAL.
    READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.
    IF SY-SUBRC EQ 0.
      ZTITVAK-BUPLA = G_TC_2130_WA-BUPLA.
    ENDIF.
*    IF ZTITVAK-bupla IS INITIAL.
*      ZTITVAK-bupla = c_bupla.
*    ENDIF.
  ENDIF.

*> Default Value Setting
*  SELECT SINGLE *
*    FROM ztitig07
*   WHERE bukrs EQ ztitvak-bukrs
*     AND cstct EQ c_chara.
*  IF sy-subrc EQ 0.
*    ztitvak-blart = ztitig07-blart.
*    ztitvak-mwskz = ztitig07-mwskz.
*    ztitvak-zlspr = ztitig07-zlspr.
*    ztitvak-zlsch = ztitig07-zlsch.
*    ztitvak-uzawe = ztitig07-uzawe.
*  ENDIF.

*******************  박 태 균 차장님 요청사항 **************************
*1)세금코드 : 디폴트값 “V1”으로
*2)지급조건 : L/C인  경우           -------  PO의 지급조건 그대로
*             구매승인서인 경우     ------- ”G000”을 디폴트로
*3)지급보류 : L/C인 경우            ------- ”E” 기본설정(수입)
*             구매승인서인 경우     ------- “D" 기본설정(회계일반)
*4)지급방법 : L/C인 경우            ------- “E” Local(로칼결제)
*             구매승인서인 경우     ------- “T” Bank Transfer(이체)
*5)지정     : L/C 번호 또는 구매승인서 번호를 넣어 주세요
*******************  박 태 균 차장님 요청사항 **************************
  ZTITVAK-MWSKZ = 'V1'.

  READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.
  IF SY-SUBRC EQ 0.
    SELECT SINGLE *
      FROM ZTITRQS
     WHERE REQNO EQ G_TC_2130_WA-REQNO
       AND AMDSQ EQ ( SELECT MAX( AMDSQ )
                        FROM ZTITRQS
                       WHERE REQNO EQ G_TC_2130_WA-REQNO ).
    IF SY-SUBRC EQ 0.
      IF ZTITRQK-REQTY EQ 'LO'.
        SELECT SINGLE ZTERM
          INTO ZTITVAK-ZTERM
          FROM EKKO
         WHERE EBELN EQ ZTITRQS-EBELN.
        ZTITVAK-ZLSPR = 'E'.
        ZTITVAK-ZLSCH = 'E'.
*        ZTITVAK-UZAWE = ''.
      ELSE.
        ZTITVAK-ZTERM = 'G000'.
        ZTITVAK-ZLSPR = 'D'.
        ZTITVAK-ZLSCH = 'T'.
*        ZTITVAK-UZAWE = ''.
      ENDIF.

*> 엠트론 구매 승인서 경우
*  지급조건 PO의 지급조건 유지
*  지급 방법 	Bank Transfer(펌뱅킹 이체)   "T"

*> CHM2205-00386 구매확인서 지급조건은 구매문서
      IF ZTITRQK-REQTY EQ 'PU' AND ZTITRQK-BUKRS EQ '3000'.
*        IF ZTITRQK-LIFNR EQ '300383' OR ZTITRQK-LIFNR EQ '300241'.

        SELECT SINGLE ZTERM
          INTO ZTITVAK-ZTERM
          FROM EKKO
         WHERE EBELN EQ ZTITRQS-EBELN.

        ZTITVAK-ZLSCH = 'T'.

      ENDIF.

*      ENDIF.
    ENDIF.
  ENDIF.
*> CHM2205-00386 구매확인서 지급조건은 구매문서

  ZTITVAK-ZUONR = ZTITRQS-OPNNO.
*******************  박 태 균 차장님 요청사항 **************************


  IF ZTITVAK-BLART IS INITIAL.
    ZTITVAK-BLART = C_BLART.
  ENDIF.

  IF ZTITVAK-MWSKZ IS INITIAL.
    READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.
    IF SY-SUBRC EQ 0.
      ZTITVAK-MWSKZ = G_TC_2130_WA-MWSKZ.
    ENDIF.
  ENDIF.

  IF ZTITVAK-ZTERM IS INITIAL.
    READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.
    IF SY-SUBRC               EQ 0       AND
       NOT G_TC_2130_WA-REQNO IS INITIAL.
      SELECT SINGLE ZTERM
        INTO ZTITVAK-ZTERM
        FROM ZTIVRQ02
       WHERE REQNO EQ G_TC_2130_WA-REQNO.
    ENDIF.
  ENDIF.


*  IF ZTITVAK-zlspr IS INITIAL.
*    ZTITVAK-zlspr = c_zlspr.
*  ENDIF.

  ZTITVAK-LIVST = C_CHARN.

ENDFORM.                    " set_invoice_default_values
*&---------------------------------------------------------------------*
*&      Form  fill_account_header_cancel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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

ENDFORM.                    " fill_account_header_cancel
*&---------------------------------------------------------------------*
*&      Form  applications_print
*&---------------------------------------------------------------------*
FORM APPLICATIONS_PRINT .

  CALL FUNCTION 'Z_TI_POPUP_TO_CONFIRM_MESSAGE'
    EXPORTING
      XMODE  = C_CHARZ
    IMPORTING
      ANSWER = G_ANSWER.

  IF G_ANSWER EQ C_Y.
    IF G_MODE EQ C_CHARY OR
       G_MODE EQ C_CHARO.
      PERFORM CHECK_FOR_DOCUMENT_FIELD USING G_MODE.
      IF G_LINE EQ C_ZERO.
*>Switches on the local update task.
        SET UPDATE TASK LOCAL.
*>Data Save.
        PERFORM P8000_SAVE_MASTER_DATA USING G_MODE.
        CHECK G_SUBRC EQ C_ZERO.
      ENDIF.
    ENDIF.
    PERFORM  CALL_PRINT_PROCESS.
  ENDIF.


ENDFORM.                    " applications_print
*&---------------------------------------------------------------------*
*&      Form  input_field_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INPUT_FIELD_CHECK .

  DATA: L_BUKRS LIKE T001-BUKRS,
        L_WERKS LIKE T001W-WERKS,
        L_MATNR LIKE MARA-MATNR,
        L_MTART LIKE T134-MTART,
        L_EBELN LIKE EKKO-EBELN,
        L_LIFNR LIKE LFA1-LIFNR,
        L_EKORG LIKE T024E-EKORG,
        L_EKGRP LIKE T024-EKGRP.

* Company code
  SELECT BUKRS INTO (L_BUKRS)
               FROM T001 UP TO 1 ROWS WHERE BUKRS IN S_BUKRS.
  ENDSELECT.
  IF SY-SUBRC <> 0.
    PERFORM GET_FTEXT(RDDFIE00) USING 'T001' 'BUKRS' SY-LANGU
                                CHANGING DFIES G_SUBRC.
    SET CURSOR FIELD 'S_BUKRS-LOW'.
    MESSAGE E348(M7) WITH '회사코드'.
  ENDIF.

* Vendor
  READ TABLE S_LIFNR INDEX 1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    SELECT LIFNR INTO (L_LIFNR)
                 FROM LFB1 UP TO 1 ROWS WHERE LIFNR IN S_LIFNR
                                        AND   BUKRS IN S_BUKRS.
    ENDSELECT.
    IF SY-SUBRC <> 0.
      PERFORM GET_FTEXT(RDDFIE00) USING 'LFA1' 'LIFNR' SY-LANGU
                                  CHANGING DFIES G_SUBRC.
      SET CURSOR FIELD 'S_LIFNR-LOW'.
      MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
    ENDIF.
  ENDIF.

* Purchase Organization
  READ TABLE S_EKORG INDEX 1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    SELECT EKORG INTO (L_EKORG)
                 FROM T024E UP TO 1 ROWS WHERE EKORG IN S_EKORG.
    ENDSELECT.
    IF SY-SUBRC <> 0.
      PERFORM GET_FTEXT(RDDFIE00) USING 'T024E' 'EKORG' SY-LANGU
                                  CHANGING DFIES G_SUBRC.
      SET CURSOR FIELD 'S_EKORG-LOW'.
      MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
    ENDIF.
  ENDIF.

* Purchase GROUP
  READ TABLE S_EKGRP INDEX 1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    SELECT EKGRP INTO (L_EKGRP)
                 FROM T024 UP TO 1 ROWS WHERE EKGRP IN S_EKGRP.
    ENDSELECT.
    IF SY-SUBRC <> 0.
      PERFORM GET_FTEXT(RDDFIE00) USING 'T024' 'EKGRP' SY-LANGU
                                  CHANGING DFIES G_SUBRC.
      SET CURSOR FIELD 'S_EKGRP-LOW'.
      MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
    ENDIF.
  ENDIF.

ENDFORM.                    " input_field_check
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P1001_INITIALIZATION .

  SET TITLEBAR 'T1000'.


ENDFORM.                    " p1001_initialization
*&---------------------------------------------------------------------*
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P2000_DATA_SELECTIONS .

  DATA: L_RQMNG  LIKE ZTITRQP-RQMNG.


  CLEAR: G_COUNT, IT_TAB, IT_ZTITIG02, IT_HEADER, IT_LIST, G_LINE.
  REFRESH : IT_TAB, IT_ZTITIG02, IT_HEADER, IT_LIST.
*> PROGRESS Display.
  G_LINEN    = 30.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'(P01).
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINEN.

*> 수입의뢰 데이타 select.
  SELECT *
        INTO CORRESPONDING FIELDS OF TABLE IT_TAB_H
        FROM ( ZTIVRQ00 AS R INNER JOIN EKKO AS K
          ON  R~EBELN EQ K~EBELN ) INNER JOIN EKPO AS P
          ON  R~EBELN EQ P~EBELN
         AND  R~EBELP EQ P~EBELP
       WHERE K~EBELN  IN S_EBELN  "구매오더.
         AND K~BUKRS  IN S_BUKRS  "회사코드.
         AND K~EKORG  IN S_EKORG  "구매조직.
         AND K~EKGRP  IN S_EKGRP  "구매그룹.
         AND K~LIFNR  IN S_LIFNR  "공급업체 계정번호.
         AND K~BSART  IN S_BSART  "구매문서번호.
         AND R~EBELP  IN S_EBELP
         AND R~REQNO  IN S_REQNO
         AND R~ZTERM  IN S_ZTERM
         AND R~REQTY  IN S_REQTY
         AND R~DOCST  EQ 'O'
         AND R~REQTY  IN ('LO', 'PU')
         AND R~OPNNO  IN S_OPNNO
         AND R~OPNDT  IN S_OPNDT
         AND P~MATNR  IN S_MATNR
         AND P~TXZ01  IN S_TXZ01
         AND P~WERKS  IN S_WERKS
         AND P~MATKL  IN S_MATKL
         AND K~WAERS  IN S_WAERS
         AND R~CNAM   IN S_CNAM   "작성인.
         AND R~CDAT   IN S_CDAT   "생성일.
         AND R~CTME   IN S_CTME   "생성시간.
         AND R~UNAM   IN S_UNAM   "최종변경인.
         AND R~UDAT   IN S_UDAT   "변경일.
         AND R~UTME   IN S_UTME.  "최종변경시간.

  IF SY-SUBRC NE 0.
    MESSAGE S902.   EXIT.
  ENDIF.

*  DATA : l_ppmng LIKE ztitvap-ppmng.

  CLEAR: G_TABIX, G_COUNT, G_CNT.
  LOOP AT IT_TAB_H.
    G_TABIX = SY-TABIX.

    IF IT_TAB_H-REQTY EQ 'LO'.
      SELECT SINGLE LLCTY
        INTO IT_TAB_H-LLCTY
        FROM ZTITLO1
       WHERE REQNO  EQ  IT_TAB_H-REQNO
         AND AMDSQ  EQ  IT_TAB_H-AMDSQ.
    ENDIF.

*> 구매오더 이력.
    CLEAR: BKPF-KURSF.
    CASE IT_TAB_H-LLCTY.
      WHEN '2AA'.  ">원화표시 내국신용장.
        BKPF-WAERS = T001-WAERS.
      WHEN '2AB'.  ">외화표시 내국신용장.
        BKPF-WAERS = IT_TAB_H-WAERS.
      WHEN '2AC'.  ">순수원화표시 내국신용장.
        BKPF-WAERS = IT_TAB_H-WAERS.
      WHEN OTHERS.
        BKPF-WAERS = IT_TAB_H-WAERS.
    ENDCASE.

    SELECT SINGLE NETPR PEINH BPRME
      INTO (IT_TAB_H-NETPR, IT_TAB_H-PEINH, IT_TAB_H-BPRME)
      FROM EKPO
     WHERE EBELN EQ IT_TAB_H-EBELN
       AND EBELP EQ IT_TAB_H-EBELP.

    PERFORM GET_GR_HISTORY_TABLE TABLES IT_EK08RN
                                 USING  IT_TAB_H-EBELN
                                        IT_TAB_H-EBELP
                                        IT_TAB_H-WEBRE
                                        BKPF-KURSF
                                        BKPF-WAERS
                                        EKKO
                                        IT_TAB_H-LLCTY.

    LOOP AT IT_EK08RN.
      READ TABLE IT_HEADER WITH KEY REQNO = IT_TAB_H-REQNO.
      IF SY-SUBRC NE 0.
        MOVE-CORRESPONDING IT_TAB_H TO IT_HEADER.
        CASE IT_TAB_H-LLCTY.
          WHEN '2AA'.  ">원화표시 내국신용장.
            IT_HEADER-REQTX = '원화표시'.
          WHEN '2AB'.  ">외화표시 내국신용장.
            IT_HEADER-REQTX = '외화표시'.
          WHEN '2AC'.  ">순수원화표시 내국신용장.
            IT_HEADER-REQTX = '순수원화'.
          WHEN OTHERS.
            IT_HEADER-REQTX = '구매승인'.
        ENDCASE.
*   공급업체.
        SELECT SINGLE NAME1 INTO IT_HEADER-NAME1
          FROM LFA1
         WHERE LIFNR EQ IT_TAB_H-LIFNR.

        APPEND IT_HEADER.
      ENDIF.

      MOVE-CORRESPONDING : IT_TAB_H  TO IT_LIST,
                           IT_EK08RN TO IT_LIST.
*> G/R Base I/V일 경우. ( 입고수량 -  송장수량 )
      IF IT_EK08RN-WEBRE EQ 'X'.
        IT_LIST-IVMNGI  = IT_EK08RN-WEMNG - IT_EK08RN-REMNG.
        IT_LIST-IVMNGS  = IT_EK08RN-REMNG.
      ELSE.
*> G/R Base I/V가 아닐 경우. ( 오더수량 -  송장수량 )
        IT_LIST-IVMNGI  = IT_EK08RN-BSMNG - IT_EK08RN-REMNG.
        IT_LIST-IVMNGS  = IT_EK08RN-REMNG.
      ENDIF.

      IT_LIST-IVMNG = IT_LIST-IVMNGI.
      IT_LIST-GJAHR = IT_EK08RN-LFGJA.
      IT_LIST-BELNR = IT_EK08RN-LFBNR.
      IT_LIST-BUZEI = IT_EK08RN-LFPOS.
      IT_LIST-MWSKZ = IT_EK08RN-MWSKZ.

      IF IT_LIST-BUDAT IS INITIAL.
        IT_LIST-BUDAT = SY-DATLO.
      ENDIF.

      APPEND IT_LIST.

      ADD 1 TO G_LINE.

*      it_header, it_list
    ENDLOOP.


*    MODIFY it_tab_h INDEX g_tabix.
  ENDLOOP.

  IF G_LINE EQ 0.
    MESSAGE S902.
  ENDIF.

ENDFORM.                    " p2000_data_selections
*&---------------------------------------------------------------------*
*&      Form  p2100_header_and_list_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P2100_HEADER_AND_LIST_BUILD .

  LOOP AT IT_TAB_H.
    MOVE-CORRESPONDING IT_TAB_H TO : IT_HEADER, IT_LIST.
    COLLECT : IT_HEADER.
    APPEND    IT_LIST.
  ENDLOOP.

ENDFORM.                    " p2100_header_and_list_build
*&---------------------------------------------------------------------*
*&      Form  p2001_item_clear
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P2001_ITEM_CLEAR  USING    P_ITEM.

  IF P_ITEM NE 'X'.
    REFRESH IT_LIST.
  ENDIF.

ENDFORM.                    " p2001_item_clear
*&---------------------------------------------------------------------*
*&      Form  3000_field_category_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 3000_FIELD_CATEGORY_BUILD .

*----------------------------------------------------------------------*
* 필드명과 Output Length등을 사용자의 입맛에 맞게 바꿈.
*----------------------------------------------------------------------*
  PERFORM 3010_FILL_FIELD_CATEGORY USING :
*>>>>>>HEADER
"수입의뢰 관리번호
*>>>>>>HEADER
"BOX.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   ' ',
          ' ' 'CHECKBOX'      'X',
*          ' ' 'EDIT'          'X',
*          ' ' 'INPUT'         'X',
          ' ' 'FIELDNAME'     'CHKBX',
          ' ' 'HOTSPOT'       'X',       " Double Click 효과
          ' ' 'OUTPUTLEN'     '1',
          'E' 'KEY'           'X',

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQK',
          ' ' 'FIELDNAME'     'REQNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"B/L번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'SELTEXT_M'     '문서종류',
          ' ' 'FIELDNAME'     'REQTX',
          ' ' 'HOTSPOT'       ' ',
          'E' 'OUTPUTLEN'     '18',
"공급업체코드
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'FIELDNAME'     'LIFNR',
          ' ' 'OUTPUTLEN'     6,
          'E' 'HOTSPOT'       'X',

"공급업체명
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'LFA1',
          ' ' 'OUTPUTLEN'     25,
          'E' 'FIELDNAME'     'NAME1',

"개설금액.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'CTABNAME'      'IT_HEADER',
          ' ' 'FIELDNAME'     'OPAMT',
          ' ' 'seltext_m'     '개설금액',
          'E' 'OUTPUTLEN'     '16',
"통화.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'seltext_m'     'Cur',
          ' ' 'FIELDNAME'     'WAERS',
          'E' 'OUTPUTLEN'     '3',
"USD금액.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'FIELDNAME'     'USAMT',
          ' ' 'CFIELDNAME'    'UCURR',
          ' ' 'CTABNAME'      'IT_HEADER',
          'E' 'OUTPUTLEN'     '16',
"USD통화
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'seltext_m'     'USD',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'UCURR',
          'E' 'OUTPUTLEN'     '3',
"LOCAL 금액.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'FIELDNAME'     'DMBTR',
          ' ' 'CFIELDNAME'    'HWAER',
          ' ' 'CTABNAME'      'IT_HEADER',
          'E' 'OUTPUTLEN'     '16',
"LOCAL 통화
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'seltext_m'     'KRW',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'HWAER',
          'E' 'OUTPUTLEN'     '3',
"개설번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'OPNNO',
          ' ' 'OUTPUTLEN'     18,
          'E' 'HOTSPOT'       ' ',
"개설일자
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'OPNDT',
          ' ' 'OUTPUTLEN'     12,
          'E' 'HOTSPOT'       ' ',
"개설일자
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'ZTERM',
          ' ' 'OUTPUTLEN'     6,
          'E' 'HOTSPOT'       ' ',
"회사코드
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'FIELDNAME'     'BUKRS',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '4',
"회사코드
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'FIELDNAME'     'EKORG',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '4',
"회사코드
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'FIELDNAME'     'EKGRP',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '4',
*>>>>>>>>>LIST
"BOX.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'FIELDNAME'     'BOX',
          'E' 'KEY'           ' ',
"B/L 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'FIELDNAME'     'REQIT',
          ' ' 'JUST'          C_CHARL," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
          ' ' 'INTLEN'         10,
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"구매전표번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'EBELN',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '12',
"구매문서 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'EBELP',
          ' ' 'JUST'          C_CHARL," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
*          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '5',
"자재번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'FIELDNAME'     'MATNR',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '07',

"자재내역.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'FIELDNAME'     'TXZ01',
          'E' 'OUTPUTLEN'     '25',
"전기일자
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKBE',
          ' ' 'FIELDNAME'     'BUDAT',
          ' ' 'OUTPUTLEN'     12,
          'E' 'HOTSPOT'       ' ',
"회계번호
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKBE',
          ' ' 'FIELDNAME'     'BELNR',
          ' ' 'HOTSPOT'       'X',
          ' ' 'OUTPUTLEN'     12,
          'E' 'HOTSPOT'       ' ',
"품목번호
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKBE',
          ' ' 'FIELDNAME'     'BUZEI',
          ' ' 'OUTPUTLEN'     7,
          'E' 'HOTSPOT'       ' ',

"수입의뢰수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'FIELDNAME'     'MENGE',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
*          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '15',
*> 단가
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'seltext_m'     '단가',

          ' ' 'FIELDNAME'     'NETPR',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'CTABNAME'      'IT_HEADER',
          'E' 'OUTPUTLEN'     '15',

*> 단가단위.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKPO',
          ' ' 'FIELDNAME'     'PEINH',
          'E' 'OUTPUTLEN'     '6',

"수입의뢰수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
*          ' ' 'seltext_m'     '수입의뢰수량',
          ' ' 'FIELDNAME'     'RQMNG',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
*          ' ' 'NO_OUT'        'X',
          'E' 'KEY'           ' ',
"I/V수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISVAIT',
*          ' ' 'seltext_m'     '수입의뢰수량',
          ' ' 'FIELDNAME'     'IVMNG',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        'X',
          'E' 'KEY'           ' ',
"B/L수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
*          ' ' 'seltext_m'     '수입의뢰수량',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'BLMNG',
          'E' 'KEY'           ' ',
"송장가능수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISVAIT',
          ' ' 'seltext_m'     'I/V가능수량    ',
************************************************************
*> For TraSys ECC Upgrade By ASEG Co., Ltd.
************************************************************
*> 2009/02/16
*> 필드 카탈로그의 필드명 변경
*> Started of Modify
************************************************************
*-> Before
*          ' ' 'FIELDNAME'     'IVMNGL',
*-> After
          ' ' 'FIELDNAME'     'IVMNGI',
************************************************************
*> Ended of Modify
************************************************************
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          'E' 'OUTPUTLEN'     '16',
"기본단위
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'MEINS',
          ' ' 'INTLEN'         10,
          'E' 'OUTPUTLEN'     '4',

"송장금액.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'seltext_m'     '송장값',
          ' ' 'FIELDNAME'     'REFWR',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'JUST'          C_CHARR," (R)ight (L)eft (C)ent.
*          ' ' 'LZERO'         c_charx,
          ' ' 'CTABNAME'      'IT_HEADER',
          'E' 'OUTPUTLEN'     '20',

"자재문서연도
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'MJAHR',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',
"자재문서품목
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'ZEILE',
          ' ' 'NO_OUT'        'X',
*          'E' 'OUTPUTLEN'     '10'.
"작성인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'CNAM',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',
"최종변경인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'UNAM',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10'.



ENDFORM.                    " 3000_field_category_build
*&---------------------------------------------------------------------*
*&      Form  3200_key_infomation_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 3200_KEY_INFOMATION_BUILD .

  CLEAR GS_KEYINFO.

  GS_KEYINFO-HEADER01 = 'REQNO'.
  GS_KEYINFO-ITEM01   = 'REQNO'.

*  gs_keyinfo-header02 =  space.
*  gs_keyinfo-item02   = 'IBLIT'.
*
*  GS_KEYINFO-HEADER03 = SPACE.
*  GS_KEYINFO-ITEM03   = 'OBJNR'.

ENDFORM.                    " 3200_key_infomation_build
*&---------------------------------------------------------------------*
*&      Form  3100_SET_COLOR_INFOMATION
*&---------------------------------------------------------------------*
FORM 3100_SET_COLOR_INFOMATION .

  LOOP AT IT_LIST.

*    CLEAR: LT_RESRC_VW-COLOR_INFO[],
*           GS_COLOR_INFO.
*    ON CHANGE OF LT_RESRC_VW-RESRC.
*      GS_COLOR_INFO-FIELDNAME = 'RESRC'.
*      GS_COLOR_INFO-COLOR-COL = '3'.
*      APPEND GS_COLOR_INFO TO LT_RESRC_VW-COLOR_INFO[].
*      MODIFY LT_RESRC_VW.
*    ENDON.

  ENDLOOP.                             " AT LT_RESRC_VW

ENDFORM.                    " 3100_SET_COLOR_INFOMATION
*&---------------------------------------------------------------------*
*&      Form  3400_COMMENT_BUILD
*&---------------------------------------------------------------------*
FORM 3400_COMMENT_BUILD .

  DATA: L_TEXT20(20) TYPE C.

  CLEAR: IT_LISTHEADER, GS_LISTHEADER.
  REFRESH: IT_LISTHEADER.

* LIST HEADING LINE: TYPE H
  CLEAR GS_LISTHEADER.
  GS_LISTHEADER-TYP  = 'H'.
* gs_listheader-KEY:  NOT USED FOR THIS TYPE
  GS_LISTHEADER-INFO = '세금계산서 Due List'(T13).
*  SHIFT gs_listheader-info RIGHT BY 20 PLACES.
  APPEND GS_LISTHEADER TO IT_LISTHEADER.

** JS전선 회사코드 2007/04 KSH --------------------------------------
  DATA: L_BUTXT LIKE T001-BUTXT.
  CLEAR: L_BUTXT.
  SELECT SINGLE BUTXT FROM T001
                      INTO L_BUTXT
                     WHERE BUKRS EQ S_BUKRS-LOW.

  CLEAR GS_LISTHEADER.
  GS_LISTHEADER-TYP  = 'A'.
  GS_LISTHEADER-INFO = '회사코드 :'.
  CONCATENATE GS_LISTHEADER-INFO S_BUKRS-LOW L_BUTXT
         INTO GS_LISTHEADER-INFO SEPARATED BY SPACE.
  APPEND GS_LISTHEADER TO IT_LISTHEADER.
** JS전선 회사코드 2007/04 KSH --------------------------------------

* ACTION LINE: TYPE A
  CLEAR GS_LISTHEADER.
  GS_LISTHEADER-TYP  = 'A'.
  GS_LISTHEADER-INFO = '출력일자 :'(T12).
  WRITE: SY-DATLO TO L_TEXT20.
  CONCATENATE GS_LISTHEADER-INFO L_TEXT20 INTO GS_LISTHEADER-INFO
              SEPARATED BY SPACE.
  APPEND GS_LISTHEADER TO IT_LISTHEADER.

* STATUS LINE: TYPE S
* CLEAR LS_LINE.
* LS_LINE-TYP  = 'S'.
* LS_LINE-KEY  = 'Kostenrechnungskreis:'.
* LS_LINE-INFO = P_KOKRS.
* APPEND LS_LINE TO LT_TOP_OF_PAGE.

* LS_LINE-KEY  = 'Gesch?tsjahr:_______'.
* LS_LINE-INFO = P_GJAHR.
* APPEND LS_LINE TO LT_TOP_OF_PAGE.

* LS_LINE-KEY  = 'Version:_____________'.
* LS_LINE-INFO = P_VERSN.
* APPEND LS_LINE TO LT_TOP_OF_PAGE.

* ACTION LINE: TYPE A
*  CLEAR LS_LINE.
*  LS_LINE-TYP  = 'A'.
** LS_LINE-KEY:  NOT USED FOR THIS TYPE
*  LS_LINE-INFO = '<Action>'.
*  APPEND LS_LINE TO LT_TOP_OF_PAGE.

ENDFORM.                    " 3400_COMMENT_BUILD
*&---------------------------------------------------------------------*
*&      Form  3500_SORT_TABLE_BUILD
*&---------------------------------------------------------------------*
FORM 3500_SORT_TABLE_BUILD .

  DATA: LS_SORT TYPE SLIS_SORTINFO_ALV.

  CLEAR LS_SORT.
  LS_SORT-SPOS      = 1.
  LS_SORT-FIELDNAME = 'REQNO'.
  LS_SORT-TABNAME   = 'IT_LIST'.
  LS_SORT-UP        = 'X'.
* LS_SORT-GROUP     = '*'.             " Seiten- bei Gruppenwechsel
*  ls_sort-group     = 'UL'.            " Underline      -"-
  APPEND LS_SORT TO IT_SORT.

ENDFORM.                    " 3500_SORT_TABLE_BUILD
*&---------------------------------------------------------------------*
*&      Form  3700_LAYOUT_build
*&---------------------------------------------------------------------*
FORM 3700_LAYOUT_BUILD .

  MOVE: 'BOX'        TO GS_LAYOUT-BOX_FIELDNAME,
        'IT_LIST'    TO GS_LAYOUT-BOX_TABNAME.

*  MOVE: '3'          TO gs_layout-no_vline. " 분리자 라인.

ENDFORM.                    " 3700_LAYOUT_build

*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
FORM TOP_OF_PAGE.                                           "#EC CALLED

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = IT_LISTHEADER[].



ENDFORM.                    "TOP_OF_PAGE

*---------------------------------------------------------------------*
*       Form  USER_COMMAND                                            *
*---------------------------------------------------------------------*
FORM USER_COMMAND USING R_UCOMM     LIKE SY-UCOMM
                        RS_SELFIELD TYPE SLIS_SELFIELD.

  DATA: LS_LIST TYPE TY_TAB.

  DATA: L_IVMNG    TYPE ZTIIVMNG,
        L_CHECKBOX TYPE C.

  DATA : BEGIN OF LT_REQNO OCCURS 0,
           REQNO LIKE ZTITRQK-REQNO.
  DATA : END   OF LT_REQNO.

  DATA : BEGIN OF LT_REQIT OCCURS 0,
           REQNO LIKE ZTITRQK-REQNO,
           AMDSQ LIKE ZTITRQS-AMDSQ,
           REQIT LIKE ZTITRQP-REQIT.
  DATA : END   OF LT_REQIT.


  CLEAR: LS_LIST.

  CASE R_UCOMM.
    WHEN '&REFRESH'.
      PERFORM P9000_DUELIST_REFRESH USING  RS_SELFIELD.

    WHEN 'ZTIT001'. " 후속기능
      CLEAR : G_LINE, LS_LIST.
      REFRESH: IT_TEMP, LT_REQNO.
      LOOP AT IT_LIST WHERE BOX EQ 'X'.
        ADD 1 TO G_LINE.
        MOVE-CORRESPONDING : IT_LIST TO LS_LIST,
                             IT_LIST TO IT_TEMP,
                             IT_LIST TO LT_REQNO.
        APPEND IT_TEMP.
        COLLECT: LT_REQNO.
      ENDLOOP.
      CASE G_LINE.
        WHEN 0.
          IF RS_SELFIELD-TABNAME EQ 'IT_HEADER'.
            READ TABLE IT_HEADER INDEX RS_SELFIELD-TABINDEX.
          ELSEIF RS_SELFIELD-TABNAME EQ 'IT_LIST'.
            READ TABLE IT_LIST INDEX RS_SELFIELD-TABINDEX.
          ENDIF.
          IF SY-SUBRC NE 0.
            MESSAGE S003(OK). EXIT.
          ENDIF.
          IF RS_SELFIELD-TABNAME EQ 'HEADER'.
            MOVE-CORRESPONDING IT_HEADER TO LS_LIST.
          ELSEIF RS_SELFIELD-TABNAME EQ 'LIST'.
            MOVE-CORRESPONDING IT_LIST   TO LS_LIST.
          ENDIF.
*        WHEN 1.
*          SET PARAMETER ID 'ZTIIBLNO' FIELD ls_list-iblno.
*          SET PARAMETER ID 'ZTIREQNO' FIELD space.
*          SET PARAMETER ID 'BES'      FIELD space.
*          CALL TRANSACTION 'ZTIT301' AND SKIP FIRST SCREEN .
        WHEN OTHERS.
*          MESSAGE s035(0k).   EXIT.
          DESCRIBE TABLE LT_REQNO LINES G_LINE.
          CASE G_LINE.
            WHEN 0.
              MESSAGE S003(OK). EXIT.
            WHEN 1.
            WHEN OTHERS.
              MESSAGE E009 WITH '수입 의뢰'.
          ENDCASE.
*>Set Default value
          PERFORM P3000_SET_DATA_OF_SCREEN.

          READ TABLE IT_TEMP INDEX 1.
          SELECT SINGLE *
            FROM ZTITRQK
           WHERE REQNO EQ IT_TEMP-REQNO.

          SELECT SINGLE *
            FROM ZTITRQS
           WHERE REQNO EQ IT_TEMP-REQNO
             AND AMDSQ EQ IT_TEMP-AMDSQ.

          MOVE-CORRESPONDING : ZTITRQK TO ZTITVAK,
                               ZTITRQS TO ZTITVAK.
*->CSR 2014031800051 엠트론_원화일 경우 개설은행 공란으로 함
          IF ZTITVAK-BUKRS = '3000' AND ZTITVAK-WAERS = 'KRW'.
            CLEAR ZTITVAK-OPNBK.
          ENDIF.
*<-CSR 2014031800051 엠트론_원화일 경우 개설은행 공란으로 함
          SELECT SINGLE *
            FROM ZTITLO1
           WHERE REQNO EQ IT_TEMP-REQNO
             AND AMDSQ EQ IT_TEMP-AMDSQ.

          CLEAR: G_KURSF.

          LOOP AT IT_TEMP.
            CLEAR: G_MODIFY, ZTIVRQ00.
            DESCRIBE TABLE IT_TAB LINES G_COUNT_1.
            PERFORM  GET_AND_CHECK_LC_DATA   USING  IT_TEMP-REQNO
                                                    IT_TEMP-AMDSQ
                                                    IT_TEMP-REQIT
                                                    G_MODIFY
                                                    ZTIVRQ00
                                                    G_COUNT_1
                                                    C_ERROR.
*> 구매오더 이력.
            CLEAR: BKPF-KURSF.
            IF ZTITRQK-REQTY EQ C_LO.
              CASE ZTITLO1-LLCTY.
                WHEN '2AA'.  ">원화표시 내국신용장.
                  BKPF-WAERS = T001-WAERS.
                WHEN '2AB'.  ">외화표시 내국신용장.
                  BKPF-WAERS = ZTITRQS-WAERS.
                WHEN '2AC'.  ">순수원화표시 내국신용장.
                  BKPF-WAERS = ZTITRQS-WAERS.
                WHEN OTHERS.
                  BKPF-WAERS = ZTITRQS-WAERS.
              ENDCASE.
            ELSE.
              BKPF-WAERS = ZTITRQS-WAERS.
            ENDIF.
*> 입고이력 조회...
            PERFORM GET_GR_HISTORY_TABLE TABLES IT_EK08RN
                                         USING  ZTIVRQ00-EBELN
                                                ZTIVRQ00-EBELP
                                                EKPO-WEBRE
                                                BKPF-KURSF
                                                BKPF-WAERS
                                                EKKO
                                                ZTITLO1-LLCTY.
            CLEAR: L_IVMNG.
            LOOP AT IT_EK08RN.
              IF NOT ( IT_EK08RN-LFGJA EQ IT_TEMP-GJAHR AND
                       IT_EK08RN-LFBNR EQ IT_TEMP-BELNR AND
                       IT_EK08RN-LFPOS EQ IT_TEMP-BUZEI ).
                CONTINUE.
              ENDIF.

              CLEAR: G_TC_2130_WA.
              ADD 1 TO G_RBLGP.
              MOVE-CORRESPONDING : ZTIVRQ00    TO G_TC_2130_WA,
                                   IT_EK08RN   TO G_TC_2130_WA.

              MOVE: EKPO-MENGE                 TO G_TC_2130_WA-MENGE.

*> G/R Base I/V일 경우. ( 입고수량 -  송장수량 )
              IF IT_EK08RN-WEBRE EQ 'X'.
                G_TC_2130_WA-IVMNGI = IT_EK08RN-WEMNG - IT_EK08RN-REMNG.
                G_TC_2130_WA-IVMNGS = IT_EK08RN-REMNG.
              ELSE.
*> G/R Base I/V가 아닐 경우. ( 오더수량 -  송장수량 )
                G_TC_2130_WA-IVMNGI = IT_EK08RN-BSMNG - IT_EK08RN-REMNG.
                G_TC_2130_WA-IVMNGS = IT_EK08RN-REMNG.
              ENDIF.

              "--> [SRM2604-00543] EVK 26.04월 마감 예외처리 - 홍재화K 요청
*              IF IT_EK08RN-EBELN = '4504531407' AND IT_EK08RN-EBELP = '00010'.
*                G_TC_2130_WA-IVMNGI = '127500'.
*              ENDIF.
              "<-- [SRM2604-00543] EVK 26.04월 마감 예외처리 - 홍재화K 요청

              G_TC_2130_WA-IVMNG = G_TC_2130_WA-IVMNGI.
              G_TC_2130_WA-LFGJA = IT_EK08RN-LFGJA.
              G_TC_2130_WA-LFBNR = IT_EK08RN-LFBNR.
              G_TC_2130_WA-LFPOS = IT_EK08RN-LFPOS.
              G_TC_2130_WA-MWSKZ = IT_EK08RN-MWSKZ.

              IF G_TC_2130_WA-BUDAT IS INITIAL.
                G_TC_2130_WA-BUDAT = SY-DATLO.
              ENDIF.
*> G/R Base I/V일 경우. ( 입고금액 -  송장금액 )
              IF IT_EK08RN-WEBRE EQ 'X'.
                G_TC_2130_WA-REFWR  = IT_EK08RN-WEWWR - IT_EK08RN-REFWR.
              ELSE.
*> G/R Base I/V가 아닐 경우. ( 정가수량 -  송장수량 )
                G_TC_2130_WA-REFWR = IT_EK08RN-NETWR - IT_EK08RN-REFWR.
              ENDIF.

              "--> [SRM2604-00543] EVK 26.04월 마감 예외처리 - 홍재화K 요청
*              IF IT_EK08RN-EBELN = '4504531407' AND IT_EK08RN-EBELP = '00010'.
*                G_TC_2130_WA-REFWR = '829018785'.
*              ENDIF.
              "<-- [SRM2604-00543] EVK 26.04월 마감 예외처리 - 홍재화K 요청

*----> 송장수량 더하기..
              ADD G_TC_2130_WA-IVMNG TO L_IVMNG.

*----> 외화표시일 경우 환율 더하기....(가중평균환율을 구하기 위함)
              IF ZTITLO1-LLCTY EQ '2AB'.
                PERFORM GET_FI_DOCUMENT_HEADER USING IT_EK08RN-LFGJA
                                                     IT_EK08RN-LFBNR
                                                     IT_EK08RN-BUKRS
                                                     'MKPF'
                                                     BKPF.
                ADD BKPF-KURSF TO G_KURSF.
              ENDIF.

              APPEND G_TC_2130_WA TO IT_TAB.

            ENDLOOP.

          ENDLOOP.

          DESCRIBE TABLE IT_TAB LINES G_LINE.
          IF G_LINE EQ 0.
            MESSAGE E103.
          ENDIF.

*----> 외화표시일 경우 가중평균환율을 구함.
          IF ZTITLO1-LLCTY EQ '2AB'.
            ZTITVAK-KURSF = G_KURSF / G_LINE.
          ENDIF.

*>아이템 기타 정보 Read.
          PERFORM SET_OTHERS_FIELDS_BY_ITEMS.
*>화면상의 Text를 Master Data 등에서 Read.
          PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.
*>Set Defalut values
          PERFORM SET_INVOICE_DEFAULT_VALUES.
*>송장금액 체크.
          PERFORM CHECK_OPEN_AMOUNT.

*> Text Object 관련 Internal Table Initial.
          PERFORM  GET_LONGTEXT_DATA.

*> Create Class Object.
          PERFORM  BUILD_CLASS_OBJECT.

*> Generic Object Service.
          PERFORM  SET_GENERIC_OBJECT_SERVICE USING   'ZTIWF_SDOC'
                                                       ZTITVAK+3(10).

          CALL SCREEN 2000.

*> 10. Save User setting infomation
          PERFORM  SET_USER_SETTING_STRUCTURE.

          PERFORM P9000_DUELIST_REFRESH USING  RS_SELFIELD.
      ENDCASE.

    WHEN '&IC1'.

      IF RS_SELFIELD-TABNAME EQ 'IT_HEADER'.
        READ TABLE IT_HEADER INDEX RS_SELFIELD-TABINDEX.
      ELSEIF RS_SELFIELD-TABNAME EQ 'IT_LIST'.
        READ TABLE IT_LIST INDEX RS_SELFIELD-TABINDEX.
      ENDIF.
      IF SY-SUBRC NE 0.
        MESSAGE S903. EXIT.
      ENDIF.

      IF RS_SELFIELD-TABNAME EQ 'IT_HEADER'.
        MOVE-CORRESPONDING IT_HEADER TO LS_LIST.
      ELSEIF RS_SELFIELD-TABNAME EQ 'IT_LIST'.
        MOVE-CORRESPONDING IT_LIST   TO LS_LIST.
      ENDIF.

      CASE RS_SELFIELD-FIELDNAME.
        WHEN 'EBELN' OR 'EBELP'.
          PERFORM  DISPLAY_PURCHASE_ORDER(ZTIR0000)
                                          USING LS_LIST-EBELN
                                                LS_LIST-EBELP.
        WHEN 'REQNO' OR 'REQIT'.
          PERFORM  DISPLAY_IMPORT_DOCUMENT(ZTIR0000)
                                          USING LS_LIST-REQNO
                                                SPACE
                                                LS_LIST-REQIT.
        WHEN 'LIFNR'.
          PERFORM DISPLAY_VENDOR_MASTER(ZTIR0000)
                                          USING LS_LIST-LIFNR
                                                LS_LIST-EKORG.
        WHEN 'BELNR'.
          PERFORM DISPLAY_MATERIAL_DOC(ZTIR0000)
                                          USING LS_LIST-BELNR
                                                LS_LIST-GJAHR
                                                LS_LIST-BUZEI
                                                LS_LIST-BUKRS.
        WHEN 'CHKBX'.
          IF NOT IT_HEADER-REQNO IS INITIAL.
            IF IT_HEADER-CHKBX EQ C_TRUE.
              L_CHECKBOX = C_FALSE.
            ELSE.
              L_CHECKBOX = C_TRUE.
            ENDIF.
            IT_HEADER-CHKBX = L_CHECKBOX.
            MODIFY IT_HEADER INDEX RS_SELFIELD-TABINDEX.

            LOOP AT IT_LIST WHERE REQNO EQ IT_HEADER-REQNO.
              IT_LIST-BOX = L_CHECKBOX.
              MODIFY IT_LIST.
            ENDLOOP.
            IF SY-SUBRC EQ 0.
              RS_SELFIELD-COL_STABLE       = 'X'.
              RS_SELFIELD-ROW_STABLE       = 'X'.
              RS_SELFIELD-REFRESH          = 'X'.
            ENDIF.
          ENDIF.
        WHEN OTHERS.
          PERFORM  DISPLAY_IMPORT_DOCUMENT(ZTIR0000)
                                          USING LS_LIST-REQNO
                                                SPACE
                                                LS_LIST-REQIT.
      ENDCASE.
    WHEN OTHERS.
  ENDCASE.

  CLEAR: R_UCOMM.

ENDFORM.                    "USER_COMMAND
*---------------------------------------------------------------------*
*       FORM PF_STATUS_SET                                            *
*---------------------------------------------------------------------*
FORM PF_STATUS_SET USING RT_EXTAB TYPE SLIS_T_EXTAB.

  SET TITLEBAR 'T1000'.

  REFRESH: RT_EXTAB.

  APPEND 'ARCHIVE'   TO RT_EXTAB.
  APPEND '&VEXCEL'   TO RT_EXTAB.
  APPEND '&AQW'      TO RT_EXTAB.
  APPEND '&VCRYSTAL' TO RT_EXTAB.
  APPEND '&VGRID'    TO RT_EXTAB.
  APPEND '&EB9'      TO RT_EXTAB.
  APPEND '&CRDESIG'  TO RT_EXTAB.
  APPEND '&XXL'      TO RT_EXTAB.
  APPEND '&ABC'      TO RT_EXTAB.

  SET PF-STATUS 'STANDARD ' EXCLUDING RT_EXTAB.
*SET PF-STATUS 'ABCD' OF PROGRAM PROG.

ENDFORM.                    "PF_STATUS_SET
*&---------------------------------------------------------------------*
*&      Form  get_longtext_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LONGTEXT_DATA .

*> Partner Text
  PERFORM  P1000_GET_TEXTID_AND_TEXT USING ZTITVAK+3(10)
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

  CALL FUNCTION 'Z_TI_GET_INVOICE_TO_QUERY'
    IMPORTING
      EX_FACTORY = G_DATABLADE.

ENDFORM.                    " build_query_factories_class
*&---------------------------------------------------------------------*
*&      Form  3010_fill_field_category
*&---------------------------------------------------------------------*
FORM 3010_FILL_FIELD_CATEGORY  USING  P_SECTION P_FNAME P_VALUE.

  DATA L_COL(40).
  FIELD-SYMBOLS <L_FS>.

  IF P_SECTION = 'S'.
    CLEAR GS_FIELDCAT.
  ENDIF.

* 속성 MOVE
  CONCATENATE 'GS_FIELDCAT-' P_FNAME  INTO L_COL.
  ASSIGN      (L_COL)         TO       <L_FS>.
  MOVE         P_VALUE        TO       <L_FS>.

  IF P_SECTION = 'E'.
    APPEND GS_FIELDCAT TO IT_FIELDCAT.
  ENDIF.
ENDFORM.                    " 3010_fill_field_category
*&---------------------------------------------------------------------*
*&      Form  3300_EVENT_EXIT_TABLE_BUILD
*&---------------------------------------------------------------------*
FORM 3300_EVENT_EXIT_TABLE_BUILD .

  CLEAR: IT_EVENT_EXIT-AFTER.
  IT_EVENT_EXIT-AFTER = 'X'.
  IT_EVENT_EXIT-UCOMM = '&OL0'.

  APPEND IT_EVENT_EXIT.
  IT_EVENT_EXIT-UCOMM = '&OLX'. APPEND IT_EVENT_EXIT.
  IT_EVENT_EXIT-UCOMM = '&OAD'. APPEND IT_EVENT_EXIT.

ENDFORM.                    " 3300_EVENT_EXIT_TABLE_BUILD

*&---------------------------------------------------------------------*
*&      Form  3910_CALL_ALV_HIERSEQ
*&---------------------------------------------------------------------*
FORM 3910_CALL_ALV_HIERSEQ .

  DATA: LS_VARIANT LIKE DISVARIANT.
  LS_VARIANT-REPORT  = SY-REPID.
  LS_VARIANT-VARIANT = P_VARI.
  G_REPID            = SY-REPID.                  " Callback Program.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      I_INTERFACE_CHECK       = ' '
      I_CALLBACK_PROGRAM      = G_REPID
*     i_callback_pf_status_set       = ' '
*     i_callback_user_command = ' '
      IS_LAYOUT               = GS_LAYOUT
      IT_FIELDCAT             = IT_FIELDCAT[]
*     it_excluding            =
*     IT_SPECIAL_GROUPS       =
      IT_SORT                 = IT_SORT
*     IT_FILTER               =
*     IS_SEL_HIDE             =
*     I_SCREEN_START_COLUMN   = 0
*     I_SCREEN_START_LINE     = 0
*     I_SCREEN_END_COLUMN     = 0
*     I_SCREEN_END_LINE       = 0
      I_TABNAME_HEADER        = 'IT_HEADER'
      I_TABNAME_ITEM          = 'IT_LIST'
      I_STRUCTURE_NAME_HEADER = 'IT_HEADER'
      I_STRUCTURE_NAME_ITEM   = 'IT_LIST'
      IS_KEYINFO              = GS_KEYINFO
      I_DEFAULT               = C_CHARX
      I_SAVE                  = C_CHARA
      IS_VARIANT              = LS_VARIANT
      IT_EVENTS               = IT_EVENTS[]
      IT_EVENT_EXIT           = IT_EVENT_EXIT[]
      IS_PRINT                = GS_PRINT
*     IS_REPREP_ID            =
*     I_BYPASSING_BUFFER      =
*     I_BUFFER_ACTIVE         =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER =
*     ES_EXIT_CAUSED_BY_USER  =
    TABLES
      T_OUTTAB_HEADER         = IT_HEADER[]
      T_OUTTAB_ITEM           = IT_LIST[]
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " 3910_CALL_ALV_HIERSEQ
*&---------------------------------------------------------------------*
*&      Form  3600_event_table_build
*&---------------------------------------------------------------------*
FORM 3600_EVENT_TABLE_BUILD  USING  P_NAME.

  DATA: LS_EVENT TYPE SLIS_ALV_EVENT.

  IF IT_EVENTS[] IS INITIAL.
    CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
      EXPORTING
        I_LIST_TYPE = 0
      IMPORTING
        ET_EVENTS   = IT_EVENTS.
  ENDIF.

  READ TABLE IT_EVENTS WITH KEY NAME = P_NAME
                       INTO LS_EVENT.
  IF SY-SUBRC = 0.
    MOVE LS_EVENT-NAME TO LS_EVENT-FORM.
    APPEND LS_EVENT TO IT_EVENTS.
  ENDIF.

ENDFORM.                    " 3600_event_table_build
*&---------------------------------------------------------------------*
*&      Form  p1100_check_input_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P1100_CHECK_INPUT_VALUES .

  DATA: L_BUKRS LIKE T001-BUKRS,
        L_LIFNR LIKE LFA1-LIFNR,
        L_EKORG LIKE T024E-EKORG,
        L_EKGRP LIKE T024-EKGRP.

* Company code
  SELECT *
    FROM T001 UP TO 1 ROWS
   WHERE BUKRS IN S_BUKRS.
  ENDSELECT.
  IF SY-SUBRC <> 0.
    PERFORM GET_FTEXT(RDDFIE00) USING 'T001' 'BUKRS' SY-LANGU
                                CHANGING DFIES G_SUBRC.
    SET CURSOR FIELD 'S_BUKRS-LOW'.
    MESSAGE E348(M7) WITH '회사코드'.
  ENDIF.

*> 수입 IMG Checking.
  SELECT SINGLE *
    FROM ZTITIG00
   WHERE BUKRS EQ T001-BUKRS.
  IF SY-SUBRC NE 0.
    MESSAGE E035 WITH T001-BUKRS.
  ENDIF.


* Vendor
  READ TABLE S_LIFNR INDEX 1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    SELECT LIFNR INTO (L_LIFNR)
                 FROM LFB1 UP TO 1 ROWS WHERE LIFNR IN S_LIFNR
                                        AND   BUKRS IN S_BUKRS.
    ENDSELECT.
    IF SY-SUBRC <> 0.
      PERFORM GET_FTEXT(RDDFIE00) USING 'LFA1' 'LIFNR' SY-LANGU
                                  CHANGING DFIES G_SUBRC.
      SET CURSOR FIELD 'S_LIFNR-LOW'.
      MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
    ENDIF.
  ENDIF.

* Purchase Organization
  READ TABLE S_EKORG INDEX 1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    SELECT EKORG INTO (L_EKORG)
                 FROM T024E UP TO 1 ROWS WHERE EKORG IN S_EKORG.
    ENDSELECT.
    IF SY-SUBRC <> 0.
      PERFORM GET_FTEXT(RDDFIE00) USING 'T024E' 'EKORG' SY-LANGU
                                  CHANGING DFIES G_SUBRC.
      SET CURSOR FIELD 'S_EKORG-LOW'.
      MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
    ENDIF.
  ENDIF.

* Purchase GROUP
  READ TABLE S_EKGRP INDEX 1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    SELECT EKGRP INTO (L_EKGRP)
                 FROM T024 UP TO 1 ROWS WHERE EKGRP IN S_EKGRP.
    ENDSELECT.
    IF SY-SUBRC <> 0.
      PERFORM GET_FTEXT(RDDFIE00) USING 'T024' 'EKGRP' SY-LANGU
                                  CHANGING DFIES G_SUBRC.
      SET CURSOR FIELD 'S_EKGRP-LOW'.
      MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
    ENDIF.
  ENDIF.


ENDFORM.                    " p1100_check_input_values
*&---------------------------------------------------------------------*
*&      Form  p9000_duelist_refresh
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P9000_DUELIST_REFRESH
                 USING P_SELFIELD TYPE SLIS_SELFIELD.

*> 검색조건에 해당하는 데이타를 Select.
  PERFORM P2000_DATA_SELECTIONS.
**> Header table과 List(Items) table를 만듬.
*  PERFORM p2100_header_and_list_build.
  DESCRIBE TABLE IT_TAB_H LINES G_LINE.
  IF NOT G_LINE IS INITIAL.
    P_SELFIELD-REFRESH = 'X'.
  ELSE.
*> Program 종료.
    PERFORM  P9000_PROGRAM_EXIT.
  ENDIF.

ENDFORM.                    " p9000_duelist_refresh

*&---------------------------------------------------------------------*
*&      Form  FI_DOCUMENT_CREATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FI_DOCUMENT_CREATE .

  PERFORM  INVOICE_DOCUMENT_CREATE  USING ' '
                                          ZTITVAK-BUPLA
                                          C_CHARM.

ENDFORM.                    " FI_DOCUMENT_CREATE
*&---------------------------------------------------------------------*
*&      Form  FI_DOCUMENT_CANCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FI_DOCUMENT_CANCEL .

  PERFORM  INVOICE_DOCUMENT_CANCEL  USING C_CHARM.  ">물류송장검증.

ENDFORM.                    " FI_DOCUMENT_CANCEL

*&---------------------------------------------------------------------*
*&      Form  OTHER_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM OTHER_FUNCTIONS .

  CASE OK_CODE.
    WHEN 'ZTIACDOC'.
      PERFORM ACCOUNT_DOCUMENT_DISPLAY USING ZTITVAK-BUKRS
                                             ZTITVAK-GJAHR
                                             ZTITVAK-BELNR.

    WHEN 'ZTIMMDOC'.
      PERFORM DISPLAY_LIV_DOCUMENT  USING ZTITVAK-BELNR
                                          ZTITVAK-GJAHR
                                          ZTITVAK-BUKRS.

*    WHEN 'ZTIDSTR'.
*      PERFORM document_simulation_fi USING ok-code.
*
*    WHEN 'ZTIONTIME'.  ">일회성 계정.
*      PERFORM set_one_time_vender_data.
    WHEN 'ZTIMK03'.     ">공급업체.
      PERFORM DISPLAY_VENDOR_MASTER USING ZTITVAK-LIFNR
                                          ZTITVAK-EKORG.
    WHEN 'ZTICHDOC'.    ">변경문서.
      G_OBJEKT   = 'ZTIIVCHDOC'.
      G_OBJEKTID = ZTITVAK+3(10).
      PERFORM DISPLAY_CHANGE_DOCUMENT USING G_OBJEKT
                                            G_OBJEKTID.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " OTHER_FUNCTIONS

*&---------------------------------------------------------------------*
*&      Form  BEFORE_TRANSPORT_PAI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BEFORE_TRANSPORT_PAI .

*> 개설금액 체크.
  IF G_MODE EQ C_CHARC OR
     G_MODE EQ C_CHARM OR
     G_MODE EQ C_CHARP.

*> Item Amount.
*  PERFORM summary_invoice_amount  USING c_success.
    PERFORM CHECK_OPEN_AMOUNT.
  ENDIF.

ENDFORM.                    " BEFORE_TRANSPORT_PAI
*&---------------------------------------------------------------------*
*&      Form  get_total_po_amount
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_TOTAL_PO_AMOUNT TABLES   LT_EKPO  STRUCTURE GT_EKPO
                         USING    P_POAMT.

  SELECT EBELN EBELP PEINH BPUMZ BPUMN MENGE NETPR WEBRE UEBTO
    INTO CORRESPONDING FIELDS OF TABLE LT_EKPO
    FROM EKPO
     FOR ALL ENTRIES IN IT_TAB
   WHERE EBELN  EQ IT_TAB-EBELN
     AND EBELP  EQ IT_TAB-EBELP.

  CLEAR: P_POAMT.
  LOOP AT LT_EKPO.

    G_TABIX = SY-TABIX.

    LT_EKPO-MENGE = LT_EKPO-MENGE +
                    ( ( LT_EKPO-MENGE * LT_EKPO-UEBTO ) / 100 ).

    CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
      EXPORTING
        PEINH = LT_EKPO-PEINH
        BPUMZ = LT_EKPO-BPUMZ
        BPUMN = LT_EKPO-BPUMN
        MENGE = LT_EKPO-MENGE
        NETPR = LT_EKPO-NETPR
      CHANGING
        NETWR = LT_EKPO-NETWR.

    ADD LT_EKPO-NETWR TO P_POAMT.

    MODIFY LT_EKPO INDEX G_TABIX.

  ENDLOOP.

ENDFORM.                    " get_total_po_amount
*&---------------------------------------------------------------------*
*&      Form  GET_GR_HISTORY_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_GR_HISTORY_TABLE  TABLES   PT_EK08RN STRUCTURE EK08RN
                           USING    P_EBELN
                                    P_EBELP
                                    P_WEBRE
                                    P_KURSF
                                    P_WAERS
                                    P_EKKO   LIKE EKKO
                                    P_LLCTY.
  DATA : BEGIN OF LT_CLT OCCURS 0,
           REMNG LIKE EK08RN-REMNG , "송장수량
           WEMNG LIKE EK08RN-WEMNG,  "입고수량
         END OF  LT_CLT,

         LV_REMNG_M LIKE EK08RN-REMNG,
         LV_DIFF    LIKE EK08RN-REMNG.

  CLEAR:   P_EKKO, PT_EK08RN .
  REFRESH: PT_EK08RN .

  BKPF-KURSF = P_KURSF.
  BKPF-WWERT = SY-DATLO.

  CALL FUNCTION 'ME_READ_HEADER_INVOICE'
    EXPORTING
      EBELN         = P_EBELN
      RE_KURSF      = BKPF-KURSF
      RE_WAERS      = P_WAERS
*     HS_WAERS      = BE_DATA-HWAER
    IMPORTING
      IEKKO         = P_EKKO
    EXCEPTIONS
      ERROR_MESSAGE = 1
      OTHERS        = 2.
* ignore messages (sy-subrc = 1) about wrong rate in case of kufix
  IF SY-SUBRC = 1.
    MESSAGE A008(M8) WITH 'ME_READ_ITEM_INVOICE'.
  ENDIF.

* if exchange rate is fix take PO rate
  IF NOT P_EKKO-KUFIX IS INITIAL.
    BKPF-KURSF = P_EKKO-WKURS.
* currencies have to be the same anyway.
  ENDIF.

  CALL FUNCTION 'ME_READ_ITEM_INVOICE'
    EXPORTING
*     DISPLAY        = ' '
      EBELP          = P_EBELP
      IEKKO          = P_EKKO
      RE_KURSF       = BKPF-KURSF
      RE_WAERS       = BKPF-WAERS
      RE_WWERT       = BKPF-WWERT
*     XEK08R_FLAG    = ' '
*     LFDAT_AB       =
*     LFDAT_BIS      =
*     I_VORGANG      =
*     I_BLDAT        =
*     I_LBLNI        = ' '
*     LFBNR          =
*     LFGJA          =
*     LFPOS          =
*     I_WERKS        =
    TABLES
*     TEKSEL         =
*     XEK08BN        = TAB_EK08BN
      XEK08RN        = PT_EK08RN
*     XEK08BN_CURR   =
*     XEK08RN_CURR   =
*   CHANGING
*     TLIMIT         =
    EXCEPTIONS
      NOT_FOUND_ANY  = 1
      NOT_FOUND_ONE  = 2
      NOT_VALID_ANY  = 3
      NOT_VALID_ONE  = 4
      ENQUEUE_FAILED = 5
      OTHERS         = 6.
  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL FUNCTION 'DEQUEUE_ALL'.



* 엠트론 한정 GR기준 송장처리에서 선급 또는 다른이유로
* 입고수량보다 더 많은 송장수량을 처리한 경우 수량조정
  IF S_BUKRS-LOW  EQ '3000'.

    LOOP AT PT_EK08RN WHERE WEBRE EQ 'X'.
      IF PT_EK08RN-REMNG > PT_EK08RN-WEMNG.
        LV_REMNG_M = LV_REMNG_M +
                     ( PT_EK08RN-REMNG - PT_EK08RN-WEMNG ).
      ENDIF.


      MOVE-CORRESPONDING PT_EK08RN TO LT_CLT.
      COLLECT LT_CLT.
    ENDLOOP.

    "구매품목별 송장수량 >= 입고수량인 경우 대상 제외
    READ TABLE LT_CLT INDEX 1.
    IF SY-SUBRC EQ 0.
      IF LT_CLT-REMNG >= LT_CLT-WEMNG.
        CLEAR : PT_EK08RN, PT_EK08RN[].
        EXIT.
      ENDIF.
    ENDIF.

*     "일부 입고대비 송장수량이 큰 경우 추가 입고분에 반영
    IF LV_REMNG_M > 0.
      LOOP AT PT_EK08RN WHERE WEBRE EQ 'X'.
        IF PT_EK08RN-WEMNG >  PT_EK08RN-REMNG.

          IF LV_REMNG_M = 0.
            CONTINUE.
          ENDIF.
          LV_DIFF = PT_EK08RN-WEMNG - PT_EK08RN-REMNG.

          IF LV_REMNG_M >= LV_DIFF. "추가송장분 삭감
            LV_REMNG_M =  LV_REMNG_M  -  LV_DIFF.
            DELETE PT_EK08RN.
          ELSE.  "추가송장분  < 입고수량일경우
            PT_EK08RN-REMNG =  PT_EK08RN-REMNG + LV_REMNG_M .
            MODIFY PT_EK08RN TRANSPORTING REMNG.
            CLEAR LV_REMNG_M.
          ENDIF.

        ELSE. "송장수량 > 입고수량 삭제 (차액분 LV_REMNG_M에 기누적)
          DELETE PT_EK08RN.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDIF.



  LOOP AT PT_EK08RN.
    G_TABIX = SY-TABIX.

*> G/R Base I/V일 경우. ( 입고수량이 0일 경우 )
    IF PT_EK08RN-WEBRE EQ 'X'.
      IF PT_EK08RN-WEMNG IS INITIAL.
        DELETE PT_EK08RN INDEX G_TABIX.
        CONTINUE.
      ENDIF.
    ELSE.
*> G/R Base I/V가 아닐 경우. ( 오더수량 -  송장수량 )
      IF PT_EK08RN-BPREM EQ PT_EK08RN-BSMNG.
        DELETE PT_EK08RN INDEX G_TABIX.
        CONTINUE.
      ENDIF.
    ENDIF.

*> 송장수량과 입고수량이 같을 경우.
*> G/R Base I/V일 경우. ( 입고수량이 0일 경우 )
    IF PT_EK08RN-WEBRE EQ 'X'.
      IF PT_EK08RN-REMNG = PT_EK08RN-WEMNG.
        DELETE PT_EK08RN INDEX G_TABIX.
        CONTINUE.
      ENDIF.
    ENDIF.

*> 전기일자가 기간에 포함되지 않을 경우.
*> G/R Base I/V가 아닐 경우.
    IF NOT PT_EK08RN-BUDAT IS INITIAL.
      IF NOT PT_EK08RN-BUDAT IN S_BUDAT[].
        DELETE PT_EK08RN INDEX G_TABIX.
        CONTINUE.
      ENDIF.
    ENDIF.

** if not exchange rate is fix take PO rate
*    IF p_ekko-kufix IS INITIAL.
*
*    endif.

  ENDLOOP.


* BKPF-KURSF

*  DATA: lt_rsrange TYPE TABLE OF rsrange,
*        ws_rsrange TYPE rsrange.
*
*  DATA BEGIN OF lt_ekbe OCCURS 0.
*          INCLUDE STRUCTURE ekbe.
*  DATA END OF lt_ekbe.
*
** add auth check on company code.
*  CLEAR: lt_rsrange[].  FREE : lt_rsrange.
*  LOOP AT s_budat.
*    MOVE-CORRESPONDING s_budat TO ws_rsrange.
*    APPEND ws_rsrange TO lt_rsrange.
*  ENDLOOP.
*
** Read data for each PO position and create the output master table
*  REFRESH: lt_ekbe.  CLEAR: lt_ekbe.
*
*  CALL FUNCTION 'Z_TI_ME_READ_HISTORY'
*    EXPORTING
*      ebeln              = p_ebeln
*      ebelp              = p_ebelp
*      webre              = p_webre
*      i_bypassing_buffer = 'X'                              "388267
*      i_refresh_buffer   = 'X'                              "388267
*    TABLES
*      xekbe              = lt_ekbe
**        xekbes             = iekbes
**        xekbez             = iekbez
**        xekbnk             = iekbnk
**        xekbz              = iekbz
*      budat              = Lt_rsrange.
*
*  REFRESH : It_ekbe. CLEAR: It_ekbe.
*  LOOP AT LT_EKBE.
*
*  ENDLOOP.


ENDFORM.                    " GET_GR_HISTORY_TABLE
*&---------------------------------------------------------------------*
*&      Form  check_request_of_import
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_REQUEST_OF_IMPORT .

  DATA: L_DDTEXT LIKE G_DDTEXT.

  CASE ZTITRQK-REQTY.
    WHEN C_PU OR C_LO.
    WHEN OTHERS.
*> 수입의뢰 종류 Fixed value read.
      PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIREQTY'
                                                 SY-LANGU
                                                 ZTITRQK-REQTY
                                                 G_DDTEXT
                                                 C_SUCCESS.
      L_DDTEXT = G_DDTEXT.
      MESSAGE E703 WITH L_DDTEXT.
  ENDCASE.

ENDFORM.                    " check_request_of_import
*&---------------------------------------------------------------------*
*&      Form  get_authorization_bukrs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_AUTHORIZATION_BUKRS .

  PERFORM INIT_AUTHORIZATION_CHECK USING A_BUKRS
                                CHANGING A_BUKRS.

ENDFORM.                    " get_authorization_bukrs
