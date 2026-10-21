************************************************************************
* Title         :  ZTIR8000F01                                         *
*                                                                      *
* Description   : 수입 Notice 관리 Subroutine Include                  *
*                                                                      *
* Creation Date : 2003/08/12                                           *
*                                                                      *
* Author        : Seog bong, Kang                                      *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* dd-mmm-yyyy  xxxxxxxxxxxxxxx  DVPK9xxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  *
*                                                                      *
*                                                                      *
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  set_request_of_import_data
*&---------------------------------------------------------------------*
FORM SET_REQUEST_OF_IMPORT_DATA TABLES P_IT_TAB    LIKE IT_TAB
                                USING  P_ZTIVIV00 STRUCTURE ZTIVIV00
                                       P_ZTITPNK  STRUCTURE ZTITPNK
                                       P_IV_WA    STRUCTURE IT_ZTISPNIT.

*  MOVE-CORRESPONDING p_ZTIvpo00 TO : p_it_tab, p_ZTITRQK, p_ZTITRQS.
*
*
*  MOVE: p_po_wa-rqmng  TO p_it_tab-rqmng,
*        p_po_wa-rqmngs TO p_it_tab-rqmngs,
*        p_po_wa-rqmngl TO p_it_tab-rqmngl.

  MOVE-CORRESPONDING P_ZTIVIV00 TO : P_IT_TAB, P_ZTITPNK.

  ZTITPNK-WAER1 = P_ZTIVIV00-WAERS.
  ZTITPNK-INTSC = P_ZTIVIV00-WAERS.
*  MOVE: p_ZTITPNK-waers TO ZTITPNK-waer1.

*   p/o정보.
  SELECT SINGLE WERKS NAME1 LGORT MATNR TXZ01
                LOEKZ ELIKZ BPRME BPUMZ BPUMN
                UMREZ UMREN NETPR PEINH UEBTO UEBTK UNTTO
    INTO (P_IT_TAB-WERKS, P_IT_TAB-NAME1, P_IT_TAB-LGORT,
          P_IT_TAB-MATNR, P_IT_TAB-TXZ01,
          P_IT_TAB-LOEKZ, P_IT_TAB-ELIKZ, P_IT_TAB-BPRME,
          P_IT_TAB-BPUMZ, P_IT_TAB-BPUMN, P_IT_TAB-UMREZ,
          P_IT_TAB-UMREN, P_IT_TAB-NETPR, P_IT_TAB-PEINH,
          P_IT_TAB-UEBTO, P_IT_TAB-UEBTK, P_IT_TAB-UNTTO)
    FROM  ZTIVPO00
   WHERE  EBELN  = P_IV_WA-EBELN
     AND  EBELP  = P_IV_WA-EBELP.

  MOVE: P_IV_WA-REMNG  TO P_IT_TAB-REMNG,
        P_IV_WA-PNMNG  TO P_IT_TAB-PNMNG,
        P_IV_WA-PNMNGS TO P_IT_TAB-PNMNGS,
        P_IV_WA-NETWRS TO P_IT_TAB-NETWRS,
        P_IV_WA-NETWR  TO P_IT_TAB-NETWR,
        P_IV_WA-PNMNGS TO P_IT_TAB-PNMNGS,
        P_IV_WA-PNMNGL TO P_IT_TAB-PNMNGL.

  IF NOT P_IV_WA-IVONO IS INITIAL.
    SELECT SINGLE REFWR
      INTO P_IT_TAB-REFWR
      FROM ZTITIVP
     WHERE IVONO  EQ  P_IV_WA-IVONO
       AND RBLGP  EQ  P_IV_WA-RBLGP.
  ENDIF.
**> 정가 계산.
*  CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
*    EXPORTING
*      peinh = p_it_tab-peinh
*      bpumz = p_it_tab-bpumz
*      bpumn = p_it_tab-bpumn
*      menge = p_it_tab-pnmng
*      netpr = p_it_tab-netpr
*    CHANGING
*      netwr = p_it_tab-netwr.

  MOVE: SY-UNAME TO P_IT_TAB-CNAM,
        SY-DATLO TO P_IT_TAB-CDAT,
        SY-TIMLO TO P_IT_TAB-CTME,
        SY-UNAME TO P_IT_TAB-UNAM,
        SY-DATLO TO P_IT_TAB-UDAT,
        SY-TIMLO TO P_IT_TAB-UTME.

  APPEND P_IT_TAB.

*>아이템 번호를 생성함.
  PERFORM SET_ITEM_NUMBER_BUILD TABLES P_IT_TAB
                                USING  P_ZTITPNK.

  PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.

ENDFORM.                    " set_request_of_import_data

*&---------------------------------------------------------------------*
*&      Form  set_request_of_import_data_1
*&---------------------------------------------------------------------*
FORM SET_REQUEST_OF_IMPORT_DATA_1
                             TABLES P_IT_TAB    LIKE IT_TAB
                             USING  P_ZTIVRQ00  STRUCTURE ZTIVRQ00
                                    P_ZTITPNK  STRUCTURE ZTITPNK
                                    P_IV_WA     STRUCTURE IT_ZTISRQIT.

  DATA: L_NETWR TYPE NETWR.

  MOVE-CORRESPONDING P_ZTIVRQ00 TO : P_IT_TAB, P_ZTITPNK.

  ZTITPNK-WAER1 = P_ZTIVRQ00-WAERS.

*   p/o정보.
  SELECT SINGLE WERKS NAME1 LGORT MATNR TXZ01
                LOEKZ ELIKZ BPRME BPUMZ BPUMN
                UMREZ UMREN NETPR PEINH UEBTO UEBTK UNTTO
    INTO (P_IT_TAB-WERKS, P_IT_TAB-NAME1, P_IT_TAB-LGORT,
          P_IT_TAB-MATNR, P_IT_TAB-TXZ01,
          P_IT_TAB-LOEKZ, P_IT_TAB-ELIKZ, P_IT_TAB-BPRME,
          P_IT_TAB-BPUMZ, P_IT_TAB-BPUMN, P_IT_TAB-UMREZ,
          P_IT_TAB-UMREN, P_IT_TAB-NETPR, P_IT_TAB-PEINH,
          P_IT_TAB-UEBTO, P_IT_TAB-UEBTK, P_IT_TAB-UNTTO)
    FROM  ZTIVPO00
   WHERE  EBELN  = P_IV_WA-EBELN
     AND  EBELP  = P_IV_WA-EBELP.

  MOVE: P_IV_WA-RQMNG  TO P_IT_TAB-RQMNG,
        P_IV_WA-NETWRS TO P_IT_TAB-NETWRS,
        P_IV_WA-PNMNG  TO P_IT_TAB-PNMNG,
        P_IV_WA-PNMNGS TO P_IT_TAB-PNMNGS,
        P_IV_WA-PNMNGL TO P_IT_TAB-PNMNGL.

*> 정가 계산.
  CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
    EXPORTING
      PEINH = P_IT_TAB-PEINH
      BPUMZ = P_IT_TAB-BPUMZ
      BPUMN = P_IT_TAB-BPUMN
      MENGE = P_IT_TAB-RQMNG
      NETPR = P_IT_TAB-NETPR
    CHANGING
      NETWR = L_NETWR.

  P_IT_TAB-REFWR = L_NETWR.

  CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
    EXPORTING
      PEINH = P_IT_TAB-PEINH
      BPUMZ = P_IT_TAB-BPUMZ
      BPUMN = P_IT_TAB-BPUMN
      MENGE = P_IT_TAB-PNMNG
      NETPR = P_IT_TAB-NETPR
    CHANGING
      NETWR = L_NETWR.

  P_IT_TAB-NETWR = L_NETWR.

  MOVE: SY-UNAME TO P_IT_TAB-CNAM,
        SY-DATLO TO P_IT_TAB-CDAT,
        SY-TIMLO TO P_IT_TAB-CTME,
        SY-UNAME TO P_IT_TAB-UNAM,
        SY-DATLO TO P_IT_TAB-UDAT,
        SY-TIMLO TO P_IT_TAB-UTME.

  APPEND P_IT_TAB.

*>아이템 번호를 생성함.
  PERFORM SET_ITEM_NUMBER_BUILD TABLES P_IT_TAB
                                USING  P_ZTITPNK.

  PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.

ENDFORM.                    " set_request_of_import_data_1

*&---------------------------------------------------------------------*
*&      Form  p3000_set_data_of_screen
*&---------------------------------------------------------------------*
FORM P3000_SET_DATA_OF_SCREEN .

  IF SY-TCODE EQ C_CREATE OR
     SY-TCODE EQ C_CREATE_D.

    REFRESH: IT_TAB.

    CLEAR: ZTITPNK,
           ZTITPNP,
           IT_TAB,
           LFA1,
          *LFA1,
           W_LFA1,
           W_LFA1_BANK,
           ZTSTIG3,
           T001,
           T024,
           T024E.

    CLEAR:  GT_CONTROL-TEXTLINES[], GT_CONTROL-TEXTTYPES[].

    CLEAR: G_MODIFY.

  ELSE.
*> 변경 문서 관리를 위한 이전데이타를 Move.
    ZTITPNK-PNTNO   = *ZTITPNK-PNTNO.
  ENDIF.

* Message preparations
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

ENDFORM.                    " check_for_sub_document_exist


*&---------------------------------------------------------------------*
*&      Form  check_for_document_field
*&---------------------------------------------------------------------*
*  필드들의 오류 값들을 체크하여 공통 nternal table에 저장함.
*----------------------------------------------------------------------*
FORM CHECK_FOR_DOCUMENT_FIELD USING P_MODE.

  DATA: L_IF_NULL    TYPE REF TO IF_MESSAGE_OBJ_MM.

* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.
*
*> 품목 확인.
  IF G_MODE EQ C_CHARC OR
     G_MODE EQ C_CHARM.
    CLEAR: G_COUNT.
    LOOP AT IT_TAB INTO G_TC_2130_WA.
      ADD 1 TO G_COUNT.
      IF G_TC_2130_WA-NETWR IS INITIAL.
        MESSAGE S133 WITH G_TC_2130_WA-PNTIT 'Notice 금액'.
        PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
      ENDIF.
      IF G_TC_2130_WA-PNMNG IS INITIAL.
        MESSAGE S133 WITH G_TC_2130_WA-PNTIT '수량'.
        PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
      ENDIF.
      IF G_TC_2130_WA-PNMNG GT G_TC_2130_WA-PNMNGL.
        MESSAGE S134 WITH G_TC_2130_WA-PNTIT 'Notice'.
        PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
      ENDIF.
    ENDLOOP.

    IF G_COUNT EQ 0.
      MESSAGE S135.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.
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

*>Switches on the local update task.
  SET UPDATE TASK LOCAL.

*> 공통테이블 적용.
  IF G_MODE      EQ C_CHARY AND
     OK_CODE_OLD EQ 'ZTISAVE'.
    P_MODE = 'Y'.
  ENDIF.

  IF ZTITRQK-REQTY EQ C_LC    AND
     ZTITRQK-ILCTY EQ C_CHARU AND
     ZTITRQS-UMTCU EQ C_TRUE  AND
     ZTITRQS-PAGRT NE '2AB'.
    IF ( G_MODE EQ C_CHARC OR
         G_MODE EQ C_CHARM OR
         G_MODE EQ C_CHARP ).
      SPOP-TEXTLINE1 = '해당 금액에 대해 차입정보를 생성합니다.'.
      CALL SCREEN  6020 STARTING AT 01    01.
    ELSE.
      OK-CODE = 'ZTIOKAY'.
    ENDIF.
  ELSE.
    OK-CODE = 'ZTIOKAY'.
  ENDIF.

  IF OK-CODE EQ 'ZTIOKAY'.
    PERFORM P8100_SAVE_COMMON_DATA  TABLES IT_TAB
                                    USING  ZTITPNK
                                           G_SUBRC
                                           P_MODE.
    IF G_SUBRC NE C_ZERO.
      IF ZTITRQK-REQTY EQ C_LC    AND
         ZTITRQK-ILCTY EQ C_CHARU AND
         ZTITRQS-UMTCU EQ C_TRUE  AND
         ZTITRQS-PAGRT NE '2AB'.
        MESSAGE A912.   EXIT.
      ELSE.
        EXIT.
      ENDIF.
    ENDIF.

*> Long Text 저장 루틴.
    PERFORM SAVE_LONG_TEXT USING ZTITPNK+3(10)
                                 C_TEXTOBJECT_HEADER
                                 G_SUBRC.

    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE A912.   EXIT.
    ENDIF.

*> Change document setting.
    PERFORM P8120_CHANGE_DOCUMENT.
*> Commit work.
    COMMIT WORK.
*> Set parameter ID
    IF OK_CODE_OLD EQ 'ZTIDELETE'.
      MESSAGE S802 WITH ZTITPNK-PNTNO.
    ELSE.
      SET PARAMETER ID 'ZTIPNTNO' FIELD ZTITPNK-PNTNO.
      MESSAGE S803 WITH ZTITPNK-PNTNO.
    ENDIF.
  ENDIF.

ENDFORM.                    " p8000_save_master_data
*&---------------------------------------------------------------------
*&      Form  p8100_save_common_data
*&---------------------------------------------------------------------
FORM P8100_SAVE_COMMON_DATA  TABLES  PT_TAB     STRUCTURE G_TC_2130_WA
                             USING   P_ZTITPNK STRUCTURE ZTITPNK
                                     P_SUBRC    LIKE      SY-SUBRC
                                     P_MODE.

  DATA: L_LCONO   TYPE ZTIREQNO,
        L_ZTITPNH LIKE ZTITPNH,
        L_SUBRC   LIKE SY-SUBRC.

*  REFRESH :  it_msg.

  CLEAR: P_SUBRC, L_LCONO.

  IF G_TCODE EQ C_CREATE OR  G_TCODE EQ C_CREATE_D.
    IF P_ZTITPNK-PNTNO IS INITIAL.
      CALL FUNCTION 'Z_TI_GET_NUMBER_NEXT'
        EXPORTING
          ZMPTY    = 'PN'
*         BUKRS    =
        IMPORTING
          LCONO    = L_LCONO
        EXCEPTIONS
          NOT_TYPE = 1
          OTHERS   = 2.

      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      P_ZTITPNK-PNTNO = L_LCONO.
    ELSE.
      L_LCONO = P_ZTITPNK-PNTNO.
    ENDIF.
  ELSE.
    L_LCONO = P_ZTITPNK-PNTNO.
  ENDIF.
*>------------------------------------------------------------------
*> 2. 차입마스터 BDC Call  --> Usnace이고 이종통화가 아닌 경우
*>------------------------------------------------------------------
  IF P_MODE EQ C_CHARP.
    IF ZTITRQK-REQTY EQ C_LC    AND
       ZTITRQK-ILCTY EQ C_CHARU AND
       ZTITRQS-PAGRT NE '2AB'.
      IF P_ZTITPNK-BELNR IS INITIAL.

      ELSE.
        PERFORM  CALL_LOAN_MASTER_MODIFY   TABLES  PT_TAB
                                           USING   P_ZTITPNK
                                                   P_SUBRC
                                                   P_MODE.
*        IF p_subrc NE 0.
*          ROLLBACK WORK.   MOVE 4  TO p_subrc.     EXIT.
*        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
*>------------------------------------------------------------------
*> 3. 차입마스터 BDC Call  --> Usnace이고 이종통화일 경우
*>------------------------------------------------------------------
  IF ZTITRQK-REQTY EQ C_LC    AND
     ZTITRQK-ILCTY EQ C_CHARU AND
     ZTITRQS-UMTCU EQ C_TRUE  AND
     ZTITRQS-PAGRT NE '2AB'   .
    PERFORM  CALL_LOAN_MASTER_MODIFY   TABLES  PT_TAB
                                       USING   P_ZTITPNK
                                               P_SUBRC
                                               P_MODE.
    IF P_SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.
  ENDIF.

*> 생성 및 변경일시 등 정보 갱신.
  IF  P_ZTITPNK-CNAM IS INITIAL.
    MOVE: SY-UNAME   TO   P_ZTITPNK-CNAM,
          SY-DATLO   TO   P_ZTITPNK-CDAT,
          SY-TIMLO   TO   P_ZTITPNK-CTME.
  ENDIF.

  MOVE: SY-MANDT   TO   P_ZTITPNK-MANDT,
        L_LCONO    TO   P_ZTITPNK-PNTNO,
        SY-UNAME   TO   P_ZTITPNK-UNAM,
        SY-DATLO   TO   P_ZTITPNK-UDAT,
        SY-TIMLO   TO   P_ZTITPNK-UTME.

*> 삭제버튼 클릭시 .
  IF OK_CODE_OLD EQ 'ZTIDELETE'.
*> Header table delete.
    DELETE FROM ZTITPNK WHERE PNTNO EQ ZTITPNK-PNTNO.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.
*> Item table delete
    DELETE FROM ZTITPNP WHERE PNTNO EQ ZTITPNK-PNTNO.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.
*> Item table delete
    DELETE FROM ZTITPNH WHERE PNTNO EQ ZTITPNK-PNTNO.
    EXIT.
  ELSE.
*> Header table modify.
    MODIFY ZTITPNK FROM P_ZTITPNK.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.
*> Items table modify.
    DELETE FROM ZTITPNP WHERE PNTNO EQ P_ZTITPNK-PNTNO.
    REFRESH : XZTITPNP.
    LOOP AT IT_TAB INTO G_TC_2130_WA.
      MOVE-CORRESPONDING G_TC_2130_WA TO XZTITPNP.
      XZTITPNP-MANDT = P_ZTITPNK-MANDT.
      XZTITPNP-PNTNO = P_ZTITPNK-PNTNO.
      APPEND XZTITPNP.
    ENDLOOP.

    MODIFY ZTITPNP FROM TABLE XZTITPNP.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
    ENDIF.
*> 차입생성시.
    IF P_MODE EQ C_CHARP.
      IF NOT P_ZTITPNK-BELNR IS INITIAL.
*> Max Seq.
        SELECT MAX( IVSEQ )
          INTO ZTITPNH-IVSEQ
          FROM ZTITPNH
         WHERE PNTNO   EQ P_ZTITPNK-PNTNO.

        SELECT SINGLE *
          INTO L_ZTITPNH
          FROM ZTITPNH
         WHERE PNTNO   EQ P_ZTITPNK-PNTNO
           AND IVSEQ   EQ ZTITPNH-IVSEQ.
        L_SUBRC = SY-SUBRC.

        ADD 1 TO ZTITPNH-IVSEQ.

        MOVE: SY-MANDT         TO ZTITPNH-MANDT, ">클라이언트
              P_ZTITPNK-PNTNO TO ZTITPNH-PNTNO, ">Notice 관리번호
              P_ZTITPNK-BELNR TO ZTITPNH-BELNR, ">송장문서의 문서번호
              P_ZTITPNK-GJAHR TO ZTITPNH-GJAHR, ">회계연도
              P_ZTITPNK-BUKRS TO ZTITPNH-BUKRS, ">회사코드
              SY-UNAME         TO ZTITPNH-CNAM, ">작성인
              SY-DATLO         TO ZTITPNH-CDAT, ">생성일
              SY-TIMLO         TO ZTITPNH-CTME, ">생성시간
              SY-UNAME         TO ZTITPNH-UNAM, ">최종변경인
              SY-DATLO         TO ZTITPNH-UDAT, ">변경일
              SY-TIMLO         TO ZTITPNH-UTME. ">최종변경시간
        IF L_SUBRC EQ 0.
          IF L_ZTITPNH-CBELNR IS INITIAL.
*            MODIFY ZTITPNH.
          ELSE.
            INSERT ZTITPNH.
          ENDIF.
        ELSE.
          INSERT ZTITPNH.
        ENDIF.

      ENDIF.
    ELSEIF P_MODE EQ C_CHARR.
      MOVE:
           SY-UNAME         TO ZTITPNH-UNAM, ">최종변경인
           SY-DATLO         TO ZTITPNH-UDAT, ">변경일
           SY-TIMLO         TO ZTITPNH-UTME. ">최종변경시간
      MODIFY ZTITPNH.
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

  IF ZTITPNK-RE_BELNR IS INITIAL.
    CASE ZTITRQK-REQTY.
      WHEN 'LO' OR 'PU'.
      WHEN OTHERS.
        SELECT BELNR GJAHR
          INTO (ZTITPNK-RE_BELNR, ZTITPNK-RE_GJAHR)
          FROM ZTITIVK UP TO 1 ROWS
           FOR ALL ENTRIES IN IT_TAB
         WHERE IVONO EQ IT_TAB-IVONO
           AND BELNR NE SPACE.
        ENDSELECT.
    ENDCASE.
  ENDIF.

  IF ZTITPNK-BUKRS IS INITIAL.
    CLEAR: T001.
  ELSE.
    SELECT SINGLE * FROM T001
     WHERE BUKRS EQ ZTITPNK-BUKRS.
  ENDIF.

  SELECT SINGLE *
    FROM ZTITIG38
   WHERE BUKRS EQ ZTITPNK-BUKRS.

* 구매조직 SELECT ( T024E )
  IF ZTITPNK-EKORG IS INITIAL.
    CLEAR T024E.
  ELSE.
    CALL FUNCTION 'T024E_SINGLE_READ'
      EXPORTING
        T024E_EKORG = ZTITPNK-EKORG
      IMPORTING
        WT024E      = T024E
      EXCEPTIONS
        NOT_FOUND   = 1
        OTHERS      = 2.

    IF SY-SUBRC NE 0.
      IF SY-CALLD NE C_TRUE.
        MESSAGE W001(MH) WITH ZTITPNK-EKORG.
      ENDIF.
    ENDIF.
  ENDIF.

* 구매그룹 SELECT ( T024 )
  IF ZTITPNK-EKGRP IS INITIAL.
    CLEAR T024.
  ELSE.
    CALL FUNCTION 'MM_ARRANG_PURCHASE_GRP_SELECT'
      EXPORTING
        PURCHASE_GROUP           = ZTITPNK-EKGRP
      IMPORTING
        E_T024                   = T024
      EXCEPTIONS
        PURCHASE_GROUP_NOT_FOUND = 1
        OTHERS                   = 2.

    IF SY-SUBRC NE 0.
      IF SY-CALLD NE C_TRUE.
        MESSAGE W030(MN) WITH ZTITPNK-EKGRP.
      ENDIF.
    ENDIF.
  ENDIF.

*>Get 신용장 번호.
  IF ZTITPNK-OPNNO IS INITIAL AND
     NOT ZTITPNK-REQNO IS INITIAL.
    SELECT OPNNO OPNBK
      INTO (ZTITPNK-OPNNO, ZTITPNK-NTCBK)
      FROM ZTIVRQ04 UP TO 1 ROWS
     WHERE REQNO EQ ZTITPNK-REQNO.
    ENDSELECT.
  ENDIF.

  CLEAR: ZTIVRQ04, ZTITRQK.
  IF NOT ZTITPNK-REQNO IS INITIAL.
    SELECT SINGLE *
      FROM ZTITRQK
     WHERE REQNO  EQ ZTITPNK-REQNO.

    SELECT SINGLE *
      FROM ZTIVRQ04
     WHERE REQNO  EQ ZTITPNK-REQNO.

    MOVE-CORRESPONDING  ZTIVRQ04 TO ZTITRQS.
  ENDIF.

*>Get B/L 번호 .
  IF ZTITPNK-BLNUM IS INITIAL AND
     NOT ZTITPNK-IBLNO IS INITIAL.
    SELECT SINGLE BLNUM
      INTO ZTITPNK-BLNUM
      FROM ZTITBLK
     WHERE IBLNO EQ ZTITPNK-IBLNO.
  ENDIF.

*> Usance 임시계정.
  IF ZTITPNK-SAKNR IS INITIAL.
    ZTITPNK-SAKNR = ZTITIG38-SAKNR.
  ENDIF.

  PERFORM  GET_IMPORT_VENDORS_TEXT  USING C_SUCCESS.

ENDFORM.                    " GET_OTHERS_TEXT_BY_MASTER_DATA

*&---------------------------------------------------------------------*
*&      Form  get_available_rq_item
*&---------------------------------------------------------------------*
FORM GET_AVAILABLE_RQ_ITEM  TABLES   P_IT_IV    STRUCTURE IT_ZTISRQIT
                            USING    P_MTYPE
                                     P_DELETE.

  CLEAR: G_TABIX, G_COUNT, G_CNT.
  LOOP AT P_IT_IV.
    G_TABIX = SY-TABIX.
*> Get P/O 정보.
    IF NOT P_IT_IV-EBELN IS INITIAL.
      SELECT SINGLE WERKS LGORT MATNR TXZ01
                    LOEKZ ELIKZ BPRME BPUMZ BPUMN
                    UMREZ UMREN NETPR PEINH UEBTO UEBTK
                    UNTTO
        INTO (P_IT_IV-WERKS, P_IT_IV-LGORT,
              P_IT_IV-MATNR, P_IT_IV-TXZ01,
              P_IT_IV-LOEKZ, P_IT_IV-ELIKZ,
              P_IT_IV-BPRME, P_IT_IV-BPUMZ, P_IT_IV-BPUMN,
              P_IT_IV-UMREZ, P_IT_IV-UMREN, P_IT_IV-NETPR,
              P_IT_IV-PEINH, P_IT_IV-UEBTO, P_IT_IV-UEBTK,
              P_IT_IV-UNTTO)
        FROM  ZTIVPO00
       WHERE  EBELN  = P_IT_IV-EBELN
         AND  EBELP  = P_IT_IV-EBELP.

      SELECT  PS_PSP_PNR
        INTO  P_IT_IV-PS_PSP_PNR
        FROM  EKKN UP TO 1 ROWS
       WHERE  EBELN  = P_IT_IV-EBELN
         AND  EBELP  = P_IT_IV-EBELP.
*         AND  zekkn  = '01'.
      ENDSELECT.
    ENDIF.

*> 누적수량.
    SELECT  SUM( PNMNG ) SUM( NETWR )
      INTO  (P_IT_IV-PNMNGS, P_IT_IV-NETWRS)
      FROM  ZTITPNP
     WHERE  REQNO  = P_IT_IV-REQNO
       AND  REQIT  = P_IT_IV-REQIT
       AND  NOT ( PNTNO  = P_IT_IV-PNTNO
       AND        PNTIT  = P_IT_IV-PNTIT ).

*> Notice 가능수량.
    P_IT_IV-PNMNG =  P_IT_IV-RQMNG - P_IT_IV-PNMNGS.

    IF P_IT_IV-PNMNG LE C_ZERO.
      IF P_DELETE EQ C_TRUE.
        DELETE P_IT_IV INDEX G_TABIX.
        CONTINUE.
      ELSE.
        P_IT_IV-PNMNG = 0.
      ENDIF.
    ELSE.
      ADD 1 TO G_CNT.
    ENDIF.

    ADD 1 TO G_COUNT.
*    p_it_iv-index   = g_count.
    P_IT_IV-PNMNGL  = P_IT_IV-PNMNG.

*> 정가 계산.
    CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
      EXPORTING
        PEINH = P_IT_IV-PEINH
        BPUMZ = P_IT_IV-BPUMZ
        BPUMN = P_IT_IV-BPUMN
        MENGE = P_IT_IV-PNMNG
        NETPR = P_IT_IV-NETPR
      CHANGING
        NETWR = P_IT_IV-NETWR.

    MODIFY P_IT_IV INDEX G_TABIX.
  ENDLOOP.

  DESCRIBE TABLE P_IT_IV LINES G_LINE.
  IF G_LINE EQ 0.
    MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 902.
    EXIT.
  ENDIF.

  IF G_CNT EQ 0.
*    MESSAGE ID 'ZMTI00' TYPE c_warning NUMBER 103.
    MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 103.
  ENDIF.

ENDFORM.                    " get_available_rq_item
*&---------------------------------------------------------------------*
*&      Form  get_available_iv_item
*&---------------------------------------------------------------------*
FORM GET_AVAILABLE_IV_ITEM  TABLES   P_IT_IV    STRUCTURE IT_ZTISPNIT
                            USING    P_MTYPE
                                     P_DELETE.

  CLEAR: G_TABIX, G_COUNT, G_CNT.
  LOOP AT P_IT_IV.

    G_TABIX = SY-TABIX.

*> Get P/O 정보.
    IF NOT P_IT_IV-EBELN IS INITIAL.
      SELECT SINGLE WERKS LGORT MATNR TXZ01
                    LOEKZ ELIKZ BPRME BPUMZ BPUMN
                    UMREZ UMREN NETPR PEINH UEBTO UEBTK
                    UNTTO
        INTO (P_IT_IV-WERKS, P_IT_IV-LGORT,
              P_IT_IV-MATNR, P_IT_IV-TXZ01,
              P_IT_IV-LOEKZ, P_IT_IV-ELIKZ,
              P_IT_IV-BPRME, P_IT_IV-BPUMZ, P_IT_IV-BPUMN,
              P_IT_IV-UMREZ, P_IT_IV-UMREN, P_IT_IV-NETPR,
              P_IT_IV-PEINH, P_IT_IV-UEBTO, P_IT_IV-UEBTK,
              P_IT_IV-UNTTO)
        FROM  ZTIVPO00
       WHERE  EBELN  = P_IT_IV-EBELN
         AND  EBELP  = P_IT_IV-EBELP.

      SELECT  SINGLE PS_PSP_PNR
        INTO  P_IT_IV-PS_PSP_PNR
        FROM  EKKN
       WHERE  EBELN  = P_IT_IV-EBELN
         AND  EBELP  = P_IT_IV-EBELP
         AND  ZEKKN  = '01'.
    ENDIF.
*> 송장 수량.
    SELECT  SINGLE REMNG REFWR
      INTO  (P_IT_IV-REMNG, P_IT_IV-REFWR)
      FROM  ZTITIVP
     WHERE  IVONO  = P_IT_IV-IVONO
       AND  RBLGP  = P_IT_IV-RBLGP.

*> 누적수량.
    SELECT  SUM( PNMNG ) SUM( NETWR )
      INTO  (P_IT_IV-PNMNGS, P_IT_IV-NETWRS)
      FROM  ZTITPNP
     WHERE  IVONO  = P_IT_IV-IVONO
       AND  RBLGP  = P_IT_IV-RBLGP
       AND  NOT ( PNTNO  = P_IT_IV-PNTNO
       AND        PNTIT  = P_IT_IV-PNTIT ).

*> Notice 가능수량.
    P_IT_IV-PNMNG =  P_IT_IV-REMNG - P_IT_IV-PNMNGS.
    P_IT_IV-NETWR =  P_IT_IV-REFWR - P_IT_IV-NETWRS.

    IF P_IT_IV-NETWR LE C_ZERO.
      P_IT_IV-NETWR = 0.
    ENDIF.

    IF P_IT_IV-PNMNG LE C_ZERO.
      IF P_DELETE EQ C_TRUE.
        DELETE P_IT_IV INDEX G_TABIX.
        CONTINUE.
      ELSE.
        P_IT_IV-PNMNG = 0.
      ENDIF.
    ELSE.
      ADD 1 TO G_CNT.
    ENDIF.

    ADD 1 TO G_COUNT.
    P_IT_IV-INDEX   = G_COUNT.
    P_IT_IV-PNMNGL  = P_IT_IV-PNMNG.

**> 정가 계산.
*    CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
*      EXPORTING
*        peinh = p_it_iv-peinh
*        bpumz = p_it_iv-bpumz
*        bpumn = p_it_iv-bpumn
*        menge = p_it_iv-pnmng
*        netpr = p_it_iv-netpr
*      CHANGING
*        netwr = p_it_iv-netwr.

    MODIFY P_IT_IV INDEX G_TABIX.
  ENDLOOP.

  DESCRIBE TABLE P_IT_IV LINES G_LINE.
  IF G_LINE EQ 0.
    MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 902.
    EXIT.
  ENDIF.

  IF G_CNT EQ 0.
*    MESSAGE ID 'ZMTI00' TYPE c_warning NUMBER 103.
    MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 103.
  ENDIF.

ENDFORM.                    " get_available_iv_item
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

  L_OBJECTID(12) = ZTITPNK+3(10).

  L_TCODE        = SY-TCODE.
  L_UTIME        = SY-TIMLO.
  L_UDATE        = SY-DATLO.
  L_USERNAME     = SY-UNAME.

  IF G_MODE EQ C_CHARC.  ">생성모드일 경우.
    REFRESH : YZTITPNP.
  ENDIF.

  LOOP AT XZTITPNP.
    XZTITPNP-KZ = L_UPD.
    MODIFY XZTITPNP.
  ENDLOOP.

  CALL FUNCTION 'ZTIPNCHDOC_WRITE_DOCUMENT'
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
      N_ZTITPNK               = ZTITPNK
      O_ZTITPNK               = *ZTITPNK
      UPD_ZTITPNK             = L_UPD
      UPD_ZTITPNP             = L_UPD
    TABLES
      ICDTXT_ZTIPNCHDOC       = LT_CDTXT
      XZTITPNP                = XZTITPNP
      YZTITPNP                = YZTITPNP.

ENDFORM.                    " p8120_change_document
*&---------------------------------------------------------------------*
*&      Form  call_print_process
*&---------------------------------------------------------------------*
FORM CALL_PRINT_PROCESS .

*> GET OUTPUT OPTIONS
  IF IT_PRTCTL[] IS INITIAL.
    REFRESH : IT_PRTCTL.
    CLEAR: IT_PRTCTL.
    IF NOT ZTITRQK-OPNBK IS INITIAL.   ">Openning bank.
      SELECT LIFNR NAME1 LAND1 SPRAS TELFX ADRNR
      INTO CORRESPONDING FIELDS OF TABLE IT_PRTCTL
      FROM LFA1
      WHERE LIFNR IN ( SELECT LIFNR
                       FROM ZTSTIG3
                       WHERE EPART EQ ZTITRQK-OPNBK ).
    ENDIF.
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
*> Get SMARTFORM NAME
      PERFORM P7000_SET_SMART_FORM_NAME USING ZTITRQK-REQTY
                                              '00'
                                              IT_PRTCTL-DOCTY
                                              G_SSF_NAME.
*> GET THE SMART FORM'S FUNCTION MODULE
      PERFORM GET_SMART_FORM_NAME    USING  G_SSF_NAME
                                            G_FUNC_MOD_NAME.

*> Set Output Paramenters
      PERFORM SET_OUTPUT_INFORMATION USING IT_PRTCTL.
*> Call SmartForms functions
      PERFORM CALL_SMARTFORMS_FUNCTIOINS USING G_FUNC_MOD_NAME.
*> Call SmartForms functions
      PERFORM EXEC_EXTERNAL_SENDING USING IT_PRTCTL.
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
    IF NOT G_TC_2130_WA-EBELN IS INITIAL.
      IF G_REQTY EQ C_LC.
        READ TABLE IT_ZTISPNIT WITH KEY EBELN = G_TC_2130_WA-EBELN
                                        EBELP = G_TC_2130_WA-EBELP.
        IF SY-SUBRC EQ 0.
          MOVE : IT_ZTISPNIT-WERKS TO G_TC_2130_WA-WERKS,
                 IT_ZTISPNIT-LGORT TO G_TC_2130_WA-LGORT,
                 IT_ZTISPNIT-MATNR TO G_TC_2130_WA-MATNR,
                 IT_ZTISPNIT-TXZ01 TO G_TC_2130_WA-TXZ01,
                 IT_ZTISPNIT-LOEKZ TO G_TC_2130_WA-LOEKZ,
                 IT_ZTISPNIT-ELIKZ TO G_TC_2130_WA-ELIKZ,
                 IT_ZTISPNIT-BPRME TO G_TC_2130_WA-BPRME,
                 IT_ZTISPNIT-BPUMZ TO G_TC_2130_WA-BPUMZ,
                 IT_ZTISPNIT-BPUMN TO G_TC_2130_WA-BPUMN,
                 IT_ZTISPNIT-UMREZ TO G_TC_2130_WA-UMREZ,
                 IT_ZTISPNIT-UMREN TO G_TC_2130_WA-UMREN,
                 IT_ZTISPNIT-NETPR TO G_TC_2130_WA-NETPR,
                 IT_ZTISPNIT-PEINH TO G_TC_2130_WA-PEINH,
                 IT_ZTISPNIT-UEBTO TO G_TC_2130_WA-UEBTO,
                 IT_ZTISPNIT-UEBTK TO G_TC_2130_WA-UEBTK,
                 IT_ZTISPNIT-UNTTO TO G_TC_2130_WA-UNTTO.
        ENDIF.
      ELSEIF G_REQTY EQ C_LO.
        READ TABLE IT_ZTISRQIT WITH KEY EBELN = G_TC_2130_WA-EBELN
                                        EBELP = G_TC_2130_WA-EBELP.
        IF SY-SUBRC EQ 0.
          MOVE : IT_ZTISRQIT-WERKS TO G_TC_2130_WA-WERKS,
                 IT_ZTISRQIT-LGORT TO G_TC_2130_WA-LGORT,
                 IT_ZTISRQIT-MATNR TO G_TC_2130_WA-MATNR,
                 IT_ZTISRQIT-TXZ01 TO G_TC_2130_WA-TXZ01,
                 IT_ZTISRQIT-LOEKZ TO G_TC_2130_WA-LOEKZ,
                 IT_ZTISRQIT-ELIKZ TO G_TC_2130_WA-ELIKZ,
                 IT_ZTISRQIT-BPRME TO G_TC_2130_WA-BPRME,
                 IT_ZTISRQIT-BPUMZ TO G_TC_2130_WA-BPUMZ,
                 IT_ZTISRQIT-BPUMN TO G_TC_2130_WA-BPUMN,
                 IT_ZTISRQIT-UMREZ TO G_TC_2130_WA-UMREZ,
                 IT_ZTISRQIT-UMREN TO G_TC_2130_WA-UMREN,
                 IT_ZTISRQIT-NETPR TO G_TC_2130_WA-NETPR,
                 IT_ZTISRQIT-PEINH TO G_TC_2130_WA-PEINH,
                 IT_ZTISRQIT-UEBTO TO G_TC_2130_WA-UEBTO,
                 IT_ZTISRQIT-UEBTK TO G_TC_2130_WA-UEBTK,
                 IT_ZTISRQIT-UNTTO TO G_TC_2130_WA-UNTTO.
        ENDIF.
      ENDIF.
    ENDIF.
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

  IF ZTITPNK-LIFNR IS INITIAL.
    CLEAR: LFA1.
  ELSE.
    SELECT SINGLE * FROM LFA1
     WHERE LIFNR EQ ZTITPNK-LIFNR.
    IF SY-SUBRC NE 0.
      PERFORM MESSAGE_NOT_FOUND_VENDOR USING 'ZTITPNK'
                                             'LIFNR'
                                             P_MSGTY.
    ENDIF.
  ENDIF.
*
  CLEAR: ZTSTIG3.
  IF NOT ZTITPNK-NTCBK IS INITIAL.
    PERFORM  GET_EDI_PARTNER USING  ZTITPNK-NTCBK
                                    'B'
                                    ZTSTIG3
                                    C_ERROR.
  ENDIF.

  IF ZTITPNK-SSUCH IS INITIAL.
    ZTITPNK-SSUCH = ZTSTIG3-SSUCH.
  ENDIF.

  CLEAR: BUT000.
  IF NOT ZTITPNK-SSUCH IS INITIAL.
    PERFORM  GET_CFM_PARTNER_MASTER USING  ZTITPNK-SSUCH
                                           BUT000
                                           C_ERROR.
  ENDIF.

ENDFORM.                    " get_Import_vendors_text
*&---------------------------------------------------------------------*
*&      Form  check_pn_sub_document_exist
*&---------------------------------------------------------------------*
*       하위문서 존재여부 체크.
*----------------------------------------------------------------------*
FORM CHECK_PN_SUB_DOCUMENT_EXIST  USING    P_PNTNO
                                           P_PNTIT
                                           P_MSGTY
                                           P_SUBRC.
  DATA: L_COUNT TYPE I.

  CLEAR: P_SUBRC.

  CHECK NOT P_PNTNO IS INITIAL.

**> B/L 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ZTITBLP
*   WHERE reqno   EQ  p_reqno
*     AND reqit   EQ  p_reqit.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER '109' WITH 'B/L'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.

*> 선급금 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ZTITIVP
*   WHERE iblno   EQ  p_iblno
*     AND iblit   EQ  p_iblit.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER '109' WITH '선급금'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.

ENDFORM.                    " check_pn_sub_document_exist
*&---------------------------------------------------------------------*
*&      Form  SET_INITIAL_VALUE
*&---------------------------------------------------------------------*
FORM SET_INITIAL_VALUE .

*> 문서 종류.
  G_DOCUMENT = C_PN.

  REFRESH: IT_TAB,
           XZTITPNP, YZTITPNP.

  CLEAR:   IT_TAB,
           XZTITPNP, YZTITPNP,
           ZTITPNK,    ">Notice Header
          *ZTITPNK,    ">Notice Header
           LFA1,
          *LFA1,
           W_LFA1,
           W_LFA1_BANK.

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
      READ TABLE IT_TAB INTO G_TC_2130_WA INDEX G_FINDLINE.
      IF SY-SUBRC NE 0.
        EXIT.
      ENDIF.
      CHECK OK_CODE EQ 'ZTISELECT'.   ">문서선택.

      CASE G_FIELDNAME.
        WHEN 'ZTISPNIT-EBELN' OR 'ZTISPNIT-EBELP'.
          PERFORM DISPLAY_PURCHASE_ORDER USING G_TC_2130_WA-EBELN
                                               G_TC_2130_WA-EBELP.
        WHEN 'ZTISPNIT-REQNO' OR 'ZTISPNIT-REQIT'.
          IF NOT G_TC_2130_WA-REQNO IS INITIAL.

            SELECT SINGLE AMDSQ
              INTO ZTIVRQ00-AMDSQ
              FROM ZTIVRQ00
             WHERE REQNO   =   G_TC_2130_WA-REQNO
               AND REQIT   =   G_TC_2130_WA-REQIT.

            PERFORM DISPLAY_IMPORT_DOCUMENT USING G_TC_2130_WA-REQNO
                                                  ZTIVRQ00-AMDSQ
                                                  G_TC_2130_WA-LGORT.
          ENDIF.
        WHEN 'ZTISPNIT-MATNR'.
          PERFORM DISPLAY_MATERIAL_MASTER USING G_TC_2130_WA-MATNR
                                                G_TC_2130_WA-WERKS
                                                G_TC_2130_WA-LGORT.
        WHEN 'ZTISPNIT-IBLNO' OR 'ZTISPNIT-IBLIT'.
          PERFORM DISPLAY_BL_DOCUMENT     USING G_TC_2130_WA-IBLNO
                                                G_TC_2130_WA-IBLIT.
        WHEN 'ZTISPNIT-IVONO'.
          PERFORM DISPLAY_CIV_DOCUMENT    USING G_TC_2130_WA-IVONO.

      ENDCASE.
    ENDIF.
  ELSE.
    GET CURSOR FIELD G_FIELDNAME.
    IF SY-SUBRC EQ 0.
      G_FINDSCR = SY-DYNNR.
      CHECK OK_CODE EQ 'ZTISELECT'.   ">문서선택.

      CASE G_FIELDNAME.
        WHEN 'ZTITPNK-LIFNR'.
          PERFORM DISPLAY_VENDOR_MASTER   USING ZTITPNK-LIFNR
                                                ZTITPNK-EKORG.
        WHEN 'ZTITPNK-XRANL'.
          PERFORM DISPLAY_LOAN_MASTER     USING ZTITPNK-XRANL
                                                ZTITPNK-BUKRS.
        WHEN 'ZTITPNK-REQNO' OR 'ZTITPNK-OPNNO'.
          IF NOT ZTITPNK-REQNO IS INITIAL.
            SELECT SINGLE AMDSQ
              INTO ZTIVRQ04-AMDSQ
              FROM ZTIVRQ04
             WHERE REQNO   EQ   ZTITPNK-REQNO.

            PERFORM DISPLAY_IMPORT_DOCUMENT USING ZTITPNK-REQNO
                                                  ZTIVRQ04-AMDSQ
                                                  '00000'.
          ENDIF.
        WHEN 'ZTITPNK-IBLNO' OR 'ZTITPNK-BLNUM'.
          PERFORM DISPLAY_BL_DOCUMENT USING ZTITPNK-IBLNO
                                           '00000'.
        WHEN 'ZTITPNK-BELNR' OR 'ZTITPNK-GJAHR'.
          PERFORM DISPLAY_LIV_DOCUMENT  USING ZTITPNK-BELNR
                                              ZTITPNK-GJAHR
                                              ZTITPNK-BUKRS.
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
                            USING    P_ZTITPNK STRUCTURE ZTITPNK.

  DATA: L_LPONR LIKE P_ZTITPNK-LPONR.

  IF G_MODE EQ C_CHARC.
    CLEAR: L_LPONR.
    LOOP AT P_IT_TAB.
      ADD 1 TO L_LPONR.
      MOVE L_LPONR TO P_IT_TAB-PNTIT.
      MODIFY P_IT_TAB.
    ENDLOOP.
    MOVE L_LPONR TO P_ZTITPNK-LPONR.
  ELSE.
    CLEAR: G_LINES.
    LOOP AT P_IT_TAB.
      IF NOT P_IT_TAB-PNTIT IS INITIAL.
        PERFORM CHECK_PN_SUB_DOCUMENT_EXIST USING P_IT_TAB-IVONO
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
        IF P_IT_TAB-PNTIT IS INITIAL.
          ADD 1 TO P_ZTITPNK-LPONR.
          MOVE P_ZTITPNK-LPONR TO P_IT_TAB-PNTIT.
        ENDIF.
        MODIFY P_IT_TAB.
      ENDLOOP.
    ELSE.
      CLEAR: L_LPONR.
      LOOP AT P_IT_TAB.
        ADD 1 TO L_LPONR.
        MOVE L_LPONR TO P_IT_TAB-PNTIT.
        MODIFY P_IT_TAB.
      ENDLOOP.
      MOVE L_LPONR TO P_ZTITPNK-LPONR.
    ENDIF.
  ENDIF.
  CLEAR: L_LPONR.
  LOOP AT P_IT_TAB.
    IF P_IT_TAB-PNTIT GT L_LPONR.
      MOVE P_IT_TAB-PNTIT TO L_LPONR.
    ENDIF.
  ENDLOOP.
  MOVE L_LPONR TO P_ZTITPNK-LPONR.

ENDFORM.                    " set_item_number_build
*&---------------------------------------------------------------------*
*&      Form  set_function_by_business
*&---------------------------------------------------------------------*
FORM SET_FUNCTION_BY_BUSINESS .

  CASE G_MODE.
    WHEN C_CHARC.
      MOVE 'ZTIREVCL'     TO FTAB-FCODE.   APPEND FTAB. ">차입취소.
    WHEN C_CHARM.
      MOVE 'ZTIREVCL'     TO FTAB-FCODE.   APPEND FTAB. ">차입취소.
    WHEN C_CHARD.
      MOVE 'ZTIPOSTL'     TO FTAB-FCODE.   APPEND FTAB. ">차입.
    WHEN C_CHARS.
      MOVE 'ZTIPOSTL'     TO FTAB-FCODE.   APPEND FTAB. ">차입.
      MOVE 'ZTIREVCL'     TO FTAB-FCODE.   APPEND FTAB. ">차입취소.
    WHEN C_CHARR.
      MOVE 'ZTIPOSTL'     TO FTAB-FCODE.   APPEND FTAB. ">차입.
  ENDCASE.

  IF SY-DYNNR EQ C_SCR0100 OR
     SY-DYNNR EQ C_SCR0200.
    MOVE 'ZTIPOSTL'     TO FTAB-FCODE.   APPEND FTAB. ">차입.
    MOVE 'ZTIREVCL'     TO FTAB-FCODE.   APPEND FTAB. ">차입취소.
  ENDIF.

  IF NOT ZTITRQS-UMTCU IS INITIAL OR
         ZTITRQK-ILCTY NE C_CHARU OR
         ZTITRQS-PAGRT EQ '2AB'.
    MOVE 'ZTIPOSTL'     TO FTAB-FCODE.   APPEND FTAB. ">차입.
    MOVE 'ZTIREVCL'     TO FTAB-FCODE.   APPEND FTAB. ">차입취소.
  ENDIF.

  IF ZTITPNK-BELNR IS INITIAL.
    MOVE 'ZTIREVCL'     TO FTAB-FCODE.   APPEND FTAB. ">차입취소.
  ENDIF.

  IF ZTITRQK-REQTY EQ C_LO.
    MOVE 'ZTITRON'        TO FTAB-FCODE.   APPEND FTAB. ">개요펼치기.
    MOVE 'ZTITROFF'       TO FTAB-FCODE.   APPEND FTAB. ">개요닫기.
  ENDIF.

ENDFORM.                    " set_function_by_business
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
  IF ZTITIVK-LIVST NE C_CHARP.
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
*&      Form  display_invoice_by_node
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_INVOICE_BY_NODE  USING    P_NODE_KEY.

  READ TABLE IT_ZTISPNIT WITH KEY INDEX = P_NODE_KEY(10).
  IF SY-SUBRC EQ 0.
    PERFORM  DISPLAY_CIV_DOCUMENT USING IT_ZTISPNIT-IVONO.
  ELSE.
    MESSAGE S903.
  ENDIF.

ENDFORM.                    " display_import_doc_by_node
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
    SELECT SINGLE *
      FROM ZTIVRQ04
     WHERE REQNO  EQ  P_ZTIVIV00-REQNO.

    IF NOT ( ZTIVRQ04-REQTY EQ C_LC OR
             ZTIVRQ04-REQTY EQ C_LO ).
      P_MODIFY = C_TRUE.
*> 수입의뢰 종류 Fixed value read.
      PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIREQTY'
                                                 SY-LANGU
                                                 ZTIVRQ04-REQTY
                                                 G_DDTEXT
                                                 C_SUCCESS.

      MESSAGE S811 WITH G_DDTEXT.
      EXIT.
    ENDIF.

    IF ZTIVRQ04-DOCST NE C_CHARO.
      P_MODIFY = C_TRUE.
*> 문서상태 Fixed value read.
      PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIDOCST'
                                                 SY-LANGU
                                                 ZTIVRQ04-DOCST
                                                 G_DDTEXT
                                                 C_SUCCESS.

      MESSAGE S812 WITH G_DDTEXT.
      EXIT.
    ENDIF.

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
                                       C_ERROR
                                       P_MODIFY.
  ELSE.
    MESSAGE S019(06) WITH P_IVONO.
    P_MODIFY = C_TRUE.
    EXIT.
  ENDIF.

ENDFORM.                    " get_and_check_IV_data
*&---------------------------------------------------------------------*
*&      Form  get_and_check_rq_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_AND_CHECK_RQ_DATA  USING    P_REQNO
                                     P_REQIT
                                     P_MODIFY
                                     P_ZTIVRQ00 STRUCTURE ZTIVRQ00
                                     P_COUNT.

  CLEAR: P_ZTIVRQ00.

  SELECT SINGLE * INTO P_ZTIVRQ00
    FROM ZTIVRQ00
   WHERE REQNO EQ P_REQNO
     AND REQIT EQ P_REQIT.

  IF SY-SUBRC EQ 0.
    SELECT SINGLE *
      FROM ZTIVRQ04
     WHERE REQNO  EQ  P_ZTIVRQ00-REQNO.

    IF NOT ( ZTIVRQ04-REQTY EQ C_LO ).
      P_MODIFY = C_TRUE.
*> 수입의뢰 종류 Fixed value read.
      PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIREQTY'
                                                 SY-LANGU
                                                 ZTIVRQ04-REQTY
                                                 G_DDTEXT
                                                 C_SUCCESS.

      MESSAGE S811 WITH G_DDTEXT.
      EXIT.
    ENDIF.

    IF ZTIVRQ04-DOCST NE C_CHARO.
      P_MODIFY = C_TRUE.
*> 문서상태 Fixed value read.
      PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIDOCST'
                                                 SY-LANGU
                                                 ZTIVRQ04-DOCST
                                                 G_DDTEXT
                                                 C_SUCCESS.

      MESSAGE S812 WITH G_DDTEXT.
      EXIT.
    ENDIF.

*>수입의뢰번호 체크.
    IF P_ZTIVRQ00-REQNO  NE ZTITPNK-REQNO.
      IF P_COUNT         GT C_ZERO.
        MESSAGE S806 WITH P_ZTIVRQ00-REQNO ZTITPNK-REQNO.
        P_MODIFY = C_TRUE.
        EXIT.
      ELSE.
        MOVE P_ZTIVRQ00-REQNO TO ZTITPNK-REQNO.
      ENDIF.
    ENDIF.
*>Get 신용장 번호.
    IF ZTITPNK-OPNNO IS INITIAL AND
       NOT ZTITPNK-REQNO IS INITIAL.
      MOVE: ZTIVRQ00-OPNNO TO ZTITPNK-OPNNO,
            ZTIVRQ00-OPNBK TO ZTITPNK-NTCBK.
    ENDIF.
*> Lock Object
    PERFORM  SET_LC_LOCK_OBJECT  USING ZTIVRQ00-REQNO
                                       ZTIVRQ00-AMDSQ
                                       '00000'
                                       C_LOCK
                                       C_SUCCESS
                                       P_MODIFY.
  ELSE.
    MESSAGE S019(06) WITH P_REQNO.
    P_MODIFY = C_TRUE.
    EXIT.
  ENDIF.

ENDFORM.                    " get_and_check_rq_data

*&---------------------------------------------------------------------*
*&      Form  call_loan_update_bdc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_LOAN_UPDATE_BDC  USING    P_TCODE
                                    P_SUBRC
                                    P_ZTITPNK STRUCTURE ZTITPNK.

  DATA: L_IF_NULL    TYPE REF TO IF_MESSAGE_OBJ_MM.

* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

  CLEAR: P_SUBRC.
*> Parameter id clearing
  SET PARAMETER ID 'RAD' FIELD SPACE.

  PERFORM BDC_TRANSACTION USING P_TCODE P_SUBRC.

  IF P_SUBRC EQ 0.
    GET PARAMETER ID 'RAD' FIELD P_ZTITPNK-XRANL.
    IF OK_CODE_OLD EQ 'ZTIDELETE' OR
       OK_CODE_OLD EQ 'ZTIREVCL'.
      LOOP AT  MESSTAB WHERE ( MSGID = '69'
                         AND   MSGNR = '002' )
                          OR ( MSGID = '67'
                         AND   MSGNR = '807' ).
        SY-MSGNO = MESSTAB-MSGNR.
        ZTI_MESSAGE C_ERROR MESSTAB-MSGID SY-MSGNO
            MESSTAB-MSGV1 MESSTAB-MSGV2 MESSTAB-MSGV3 MESSTAB-MSGV4.

      ENDLOOP.
    ENDIF.
  ELSE.

    LOOP AT MESSTAB WHERE MSGTYP EQ 'E'.
      SY-MSGNO = MESSTAB-MSGNR.
      ZTI_MESSAGE MESSTAB-MSGTYP MESSTAB-MSGID SY-MSGNO
          MESSTAB-MSGV1 MESSTAB-MSGV2 MESSTAB-MSGV3 MESSTAB-MSGV4.
    ENDLOOP.
    IF SY-SUBRC NE 0.
      MESSAGE S926.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.
  ENDIF.

*> 오류정보가 존재시 메시지 상자 POPUP.
  G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                          IM_BUSINESS_OBJ          = L_IF_NULL
                          IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

  IF G_LINE GT 0.
*    CALL METHOD g_message_handler->show( im_popup = c_true
*      im_amodal = c_false ).
    P_SUBRC = 4.
  ELSE.
    P_SUBRC = 0.
  ENDIF.

ENDFORM.                    " call_loan_update_bdc
*&---------------------------------------------------------------------*
*&      Form  call_loan_master_modify
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_LOAN_MASTER_MODIFY  TABLES  PT_TAB     STRUCTURE G_TC_2130_WA
                              USING   P_ZTITPNK  STRUCTURE ZTITPNK
                                      P_SUBRC    LIKE      SY-SUBRC
                                      P_MODE.
  DATA: L_SUBRC    LIKE SY-SUBRC,
        L_DATE(10) TYPE C.

  CLEAR: SESSION.
  CTU_PARAMS-DISMODE  = 'E'. ">처리모드
  CTU_PARAMS-UPDMODE  = 'S'. ">갱신모드
  CTU_PARAMS-CATTMODE = ' '. ">CATT 모드...
  CTU_PARAMS-DEFSIZE  = ' '. ">기본화면 크기
  CTU_PARAMS-RACOMMIT = 'X'.
  CTU_PARAMS-NOBINPT  = ' ' .
  CTU_PARAMS-NOBIEND  = ' '.

  REFRESH: BDCDATA.

*> 차입마스터 생성.
  IF ( G_MODE EQ C_CHARC OR
       G_MODE EQ C_CHARM OR
       G_MODE EQ C_CHARP ).

    IF P_ZTITPNK-XRANL IS INITIAL.
*-----------------------------------------------------------------------
*> 머니마켓 생성관련.
*-----------------------------------------------------------------------
      IF ZTITIG38-USDTC EQ C_CHARM.      ">머니마켓.

        PERFORM BDC_DYNPRO_BUILD USING :
              'X' 'SAPLTM00'          '1000',
              ' ' 'VTMFHA-BUKRS'      P_ZTITPNK-BUKRS,
              ' ' 'VTMFHA-SGSART'     ZTITIG38-GSART,
              ' ' 'VTMFHA-SFHAART'    ZTITIG38-SFHAART,
              ' ' 'VTMFHA-KONTRH'     P_ZTITPNK-SSUCH,
              ' ' 'VTMFHA-WGSCHFT'    P_ZTITPNK-WAERS,
              ' ' 'BDC_OKCODE'       '/00'.

*> build BDC data.
        PERFORM BUILD_MODIFY_BDC_DATA_MARKET USING P_ZTITPNK.
*>
        PERFORM CALL_MARKET_UPDATE_BDC USING  'TM01'
                                               P_SUBRC
                                               P_ZTITPNK.

*-----------------------------------------------------------------------
*> Loan Master 생성관련.
*-----------------------------------------------------------------------
      ELSEIF ZTITIG38-USDTC EQ C_CHARL.  ">Loan.
*> 초기화면.
        PERFORM BDC_DYNPRO_BUILD USING :
               'X' 'SAPMF67A'          '0100',
               ' ' 'VDARL-BUKRS'       P_ZTITPNK-BUKRS,
               ' ' 'VDARL-GSART'       ZTITIG38-GSART,
               ' ' 'RMF67-SSUCH'       P_ZTITPNK-SSUCH,
               ' ' 'RMF67-XRANL'       SPACE,
               ' ' 'BDC_OKCODE'       '/00'.

*> build BDC data.
        PERFORM BUILD_MODIFY_BDC_DATA.

        PERFORM CALL_LOAN_UPDATE_BDC USING  'FN1V'
                                            P_SUBRC
                                            P_ZTITPNK.
*> 지급전기...
        IF P_SUBRC EQ 0.

          REFRESH: BDCDATA.
          PERFORM BDC_DYNPRO_BUILD USING :
                 'X' 'SAPMF67A'          '0100',
                 ' ' 'VDARL-BUKRS'        P_ZTITPNK-BUKRS,
                 ' ' 'RMF67-XRANL'        P_ZTITPNK-XRANL,
                 ' ' 'BDC_OKCODE'         '/00'.

*>> [CHM2402-00485] Banker's usance 차입원금 전기일 수작업 입력 (240327, 김예슬)
*          PERFORM BDC_DYNPRO_BUILD USING :
*                   'X' 'SAPLFVDA'          '0400',
**                 ' ' 'VDBEPP-DDISPO'   ZTITPNK-EXPDT, ">지급일(만기일)
**                 ' ' 'VDBEPP-DDISPO'   ZTITPNK-EXPDT, ">지급일(만기일)
**                 ' ' 'RMF67-XRANL'     p_ztitpnk-XRANL,
*                 ' ' 'BDC_OKCODE'         '=POST'.
          IF P_DBLFZ IS NOT INITIAL.
            PERFORM BDC_DYNPRO_BUILD USING :
                     'X' 'SAPLFVDA'          '0400',
*                 ' ' 'VDBEPP-DDISPO'   ZTITPNK-EXPDT, ">지급일(만기일)
*                 ' ' 'VDBEPP-DDISPO'   ZTITPNK-EXPDT, ">지급일(만기일)
                   ' ' 'VDBEPP-DDISPO'   P_DBLFZ, ">차입원금 전기일
                   ' ' 'VDBEPP-DDISPO'   P_DBLFZ, ">차입원금 전기일
*                 ' ' 'RMF67-XRANL'     p_ztitpnk-XRANL,
                   ' ' 'BDC_OKCODE'       '=POST'   ."'=SAVE'.240522 김예슬
          ELSE.
            PERFORM BDC_DYNPRO_BUILD USING :
                  'X' 'SAPLFVDA'          '0400',
*                 ' ' 'VDBEPP-DDISPO'   ZTITPNK-EXPDT, ">지급일(만기일)
*                 ' ' 'VDBEPP-DDISPO'   ZTITPNK-EXPDT, ">지급일(만기일)
*                 ' ' 'RMF67-XRANL'     p_ztitpnk-XRANL,
                   ' ' 'BDC_OKCODE'       '=POST'   ."'=SAVE'.240522 김예슬
          ENDIF.
*<< [CHM2402-00485] Banker's usance 차입원금 전기일 수작업 입력 (240327, 김예슬)

          PERFORM BDC_DYNPRO_BUILD USING :
                  'X' 'SAPLTRBA'          '0100',
                  ' ' 'BSSPARA-SIMKZ'          'X', "240523, 김예슬 시뮬레이션
                  ' ' 'BDC_OKCODE'         '=ENTER'.

          PERFORM BDC_TRANSACTION USING 'FN5V' L_SUBRC.
          IF L_SUBRC EQ 0.
*          LOOP AT  messtab.
*            sy-msgno = messtab-msgnr.
*            zti_message c_error messtab-msgid sy-msgno
*                messtab-msgv1 messtab-msgv2 messtab-msgv3
*                 messtab-msgv4.
*
*          ENDLOOP.
          ELSE.
            LOOP AT MESSTAB WHERE MSGTYP EQ 'E'.
              SY-MSGNO = MESSTAB-MSGNR.
              ZTI_MESSAGE MESSTAB-MSGTYP MESSTAB-MSGID SY-MSGNO
              MESSTAB-MSGV1 MESSTAB-MSGV2 MESSTAB-MSGV3 MESSTAB-MSGV4.
            ENDLOOP.
            IF SY-SUBRC NE 0.
              MESSAGE S926.
              PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
*> 차입마스터 변경.
    ELSE.
      IF ZTITIG38-USDTC EQ C_CHARM.      ">머니마켓.

        PERFORM BDC_DYNPRO_BUILD USING :
               'X' 'SAPLTM00'          '1010',
               ' ' 'VTMFHA-BUKRS'      P_ZTITPNK-BUKRS,
               ' ' 'VTMFHA-RFHA'       P_ZTITPNK-XRANL,
               ' ' 'BDC_OKCODE'       '/00'.
*> build BDC data.
        PERFORM BUILD_MODIFY_BDC_DATA_MARKET USING P_ZTITPNK.
*>
        PERFORM CALL_MARKET_UPDATE_BDC USING  'TM01'
                                               P_SUBRC
                                               P_ZTITPNK.

      ELSEIF ZTITIG38-USDTC EQ C_CHARL.  ">론.
        PERFORM BDC_DYNPRO_BUILD USING :
               'X' 'SAPMF67A'          '0100',
               ' ' 'VDARL-BUKRS'       P_ZTITPNK-BUKRS,
               ' ' 'RMF67-XRANL'       P_ZTITPNK-XRANL,
               ' ' 'BDC_OKCODE'       '/00'.

*> build BDC data.
        PERFORM BUILD_MODIFY_BDC_DATA.

        PERFORM CALL_LOAN_UPDATE_BDC USING  'FN2V'
                                            P_SUBRC
                                            P_ZTITPNK.
      ENDIF.
    ENDIF.
  ELSE.
*> 차입마스터 삭제.
    IF P_MODE      EQ C_CHARR.
      IF ZTITIG38-USDTC EQ C_CHARM.      ">머니마켓.
        REFRESH: BDCDATA.
        CTU_PARAMS-DISMODE  = 'N'. ">처리모드
        CTU_PARAMS-NOBINPT  = 'X' .
        CTU_PARAMS-NOBIEND  = ' '.

        PERFORM BDC_DYNPRO_BUILD USING :
               'X' 'SAPLTM00'          '1010',
               ' ' 'VTMFHA-BUKRS'      P_ZTITPNK-BUKRS,
               ' ' 'VTMFHA-RFHA'       P_ZTITPNK-XRANL,
               ' ' 'BDC_OKCODE'       '/00'.

        PERFORM BDC_DYNPRO_BUILD USING :
               'X' 'SAPLTM00'          '1100',
               ' ' 'BDC_OKCODE'       '=SAVE'.

        PERFORM CALL_MARKET_UPDATE_BDC USING  'TM07'
                                               P_SUBRC
                                               P_ZTITPNK.

      ELSEIF ZTITIG38-USDTC EQ C_CHARL.  ">론.
        IF POSTINGDATE IS INITIAL.
          CLEAR: L_DATE.
        ELSE.
          WRITE POSTINGDATE TO L_DATE.
        ENDIF.
        REFRESH: BDCDATA.
        CTU_PARAMS-DISMODE  = 'N'. ">처리모드
        CTU_PARAMS-NOBINPT  = 'X' .
        CTU_PARAMS-NOBIEND  = ' '.

        PERFORM BDC_DYNPRO_BUILD USING :
               'X' 'SAPMF68S'          '0100',
               ' ' 'VDARL-BUKRS'        P_ZTITPNK-BUKRS,
               ' ' 'RMF67-XRANL'        P_ZTITPNK-XRANL,
               ' ' 'BDC_OKCODE'         '=ENTER'.

        PERFORM BDC_DYNPRO_BUILD USING :
               'X' 'SAPMSSY0'          '0120',
               ' ' 'BDC_OKCODE'         '=&ALL'.

        PERFORM BDC_DYNPRO_BUILD USING :
               'X' 'SAPMSSY0'          '0120',
               ' ' 'BDC_OKCODE'         '=POST'.

        PERFORM BDC_DYNPRO_BUILD USING :
               'X' 'SAPLTRBA'          '0100',
               ' ' 'BSSBKPF-BUDAT'     L_DATE,
               ' ' 'BSSBKPF-BKTXT'     '수입 Usance전표 반제',
               ' ' 'TZST1-SSTOGRD'     REASONREVERSAL,
               ' ' 'RMF67-JPROT'       SPACE,
               ' ' 'BSSPARA-SIMKZ'     SPACE,
               ' ' 'BDC_OKCODE'         '=ENTER'.

        PERFORM BDC_TRANSACTION USING 'FNM3' L_SUBRC.
*> 반제대상이 존재하지 않을 경우.
        IF L_SUBRC NE 0.
          READ TABLE MESSTAB WITH KEY  MSGTYP = 'E'
                                       MSGID  = 'EP'
                                       MSGNR  = '502'.
          IF SY-SUBRC EQ 0.
            L_SUBRC = 0.
          ENDIF.
          READ TABLE MESSTAB WITH KEY  MSGTYP = 'S'
                                       MSGID  = '00'
                                       MSGNR  = '344'.
          IF SY-SUBRC EQ 0.
            L_SUBRC = 0.
          ENDIF.
        ENDIF.
      ENDIF.

      IF L_SUBRC EQ 0.
* Message preparations
        PERFORM  SET_MESSAGE_PREPARATIONS.

        IF ZTITIG38-USDTC EQ C_CHARL.  ">론.
          WRITE SY-DATLO TO L_DATE.
          REFRESH: BDCDATA.
          PERFORM BDC_DYNPRO_BUILD USING :
                 'X' 'SAPMF67A'          '0100',
                 ' ' 'VDARL-BUKRS'       P_ZTITPNK-BUKRS,
                 ' ' 'RMF67-XRANL'       P_ZTITPNK-XRANL,
                 ' ' 'BDC_OKCODE'       '/00'.

          PERFORM BDC_DYNPRO_BUILD USING :
                 'X' 'SAPLFVDJ'          '0100',
                 ' ' 'VDARL-SNICHTAB'    '03',
*                   ' ' 'VDARL-DARCHIV'     sy-datlo,
                 ' ' 'VDARL-DARCHIV'     L_DATE,
                 ' ' 'VDARL-VVSLOEKZ'    '1',
                 ' ' 'BDC_OKCODE'        '=SAVE'.

*          PERFORM call_loan_update_bdc USING  'FN4V'
          PERFORM CALL_LOAN_UPDATE_BDC USING  'FNVW'
                                              P_SUBRC
                                              P_ZTITPNK.
          IF P_SUBRC NE 0.
            READ TABLE MESSTAB WITH KEY  MSGTYP = 'E'
                                         MSGID  = '67'
                                         MSGNR  = '165'.
            IF SY-SUBRC EQ 0.
              P_SUBRC = 0.
            ENDIF.
            READ TABLE MESSTAB WITH KEY  MSGTYP = 'S'
                                         MSGID  = '67'
                                         MSGNR  = '110'.
            IF SY-SUBRC EQ 0.
              P_SUBRC = 0.
            ENDIF.
          ENDIF.
        ENDIF.

        IF P_SUBRC EQ 0.
* Message preparations
          PERFORM  SET_MESSAGE_PREPARATIONS.
          CLEAR P_ZTITPNK-XRANL.
        ENDIF.
      ELSE.
        LOOP AT MESSTAB WHERE MSGTYP EQ 'E'.
          SY-MSGNO = MESSTAB-MSGNR.
          ZTI_MESSAGE MESSTAB-MSGTYP MESSTAB-MSGID SY-MSGNO
              MESSTAB-MSGV1 MESSTAB-MSGV2 MESSTAB-MSGV3 MESSTAB-MSGV4.
        ENDLOOP.
        IF SY-SUBRC NE 0.
          MESSAGE S926.
          PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
        ENDIF.
      ENDIF.
*    IF ok_code_old EQ 'ZTIDELETE'.
    ENDIF.
  ENDIF.

ENDFORM.                    " call_loan_master_modify
*&---------------------------------------------------------------------*
*&      Form  build_modify_bdc_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUILD_MODIFY_BDC_DATA .

  DATA: L_DAYS          TYPE I,
        L_DATE          LIKE SY-DATUM,
        L_DATE_TO       LIKE SY-DATUM,
        L_CHAR18(18)    TYPE C,
        L_ITRST(18)     TYPE C,
        L_CHAR50(50)    TYPE C,
        L_CHAR10(10)    TYPE C,
        L_DATE10(10)    TYPE C,
        L_DATE10_TO(10) TYPE C,
        L_DATE10_EX(10) TYPE C,
        LV_HKTID        TYPE HKTID,
        L_EBELN         TYPE EBELN,
        L_REFER         LIKE VDARL-REFER,
        L_SDTYP         LIKE VDARL-SDTYP,
        L_XALKZ         LIKE VDARL-XALKZ.
  DATA : LV_SSUCH LIKE T012K-HBKID.

*  PERFORM bdc_dynpro_build USING :
*         'X' 'SAPLBUS_LOCATOR'          '3000',
*         ' ' 'BDC_OKCODE'        '=BUS_MAIN_BACK'.
*

*SAPLBUD0

*> 호선번호.
*  IF NOT ZTITPNK-pspnr IS INITIAL.
*    CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
*      EXPORTING
*        input  = ZTITPNK-pspnr
*      IMPORTING
*        output = l_char18.
*  ELSE.
*    CLEAR: l_char18.
*  ENDIF.

  WRITE: ZTITPNK-PSPNR TO L_CHAR18.

*  CASE ztitrqs-buscl.
*    WHEN 'A'.    l_sdtyp   =    '001'.  ">조선.
*    WHEN 'B'.    l_sdtyp   =    '002'.  ">해양.
*    WHEN 'C'.    l_sdtyp   =    '003'.  ">특수선.
*    WHEN 'D'.    l_sdtyp   =    '004'.  ">시설.
*    WHEN OTHERS. l_sdtyp   =    '001'.  ">조선
**    CLEAR: l_sdtyp.
*  ENDCASE.

*> 세부화면 - 기본데이타.
*  l_days = ZTITPNK-expdt - ZTITPNK-bgndt.
  L_DAYS = ZTITPNK-EXPDT - ZTITPNH-ZFBDT.

  SELECT EBELN
    INTO L_EBELN
    FROM ZTITRQP UP TO 1 ROWS
   WHERE REQNO EQ ZTITPNK-REQNO
     AND EBELN NE SPACE.
  ENDSELECT.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPMF67A'          '1000',
*         ' ' 'VDARL-SDTYP'       l_sdtyp,
         ' ' 'VDARL-RKLAMMER'    L_EBELN,
         ' ' 'VDARL-SANTWHR'     ZTITPNK-WAERS.

  IF NOT ZTITIG38-SDTYP IS INITIAL.
    PERFORM BDC_DYNPRO_BUILD USING :
           ' ' 'VDARL-SDTYP'     ZTITIG38-SDTYP.
  ENDIF.

  IF L_DAYS GT 365.    ">장기.
    IF NOT ZTITIG38-STILT IS INITIAL.
      PERFORM BDC_DYNPRO_BUILD USING :
             ' ' 'VDARL-STITEL'      ZTITIG38-STILT.
    ENDIF.
  ELSE.                ">단기.
    IF NOT ZTITIG38-STIST IS INITIAL.
      PERFORM BDC_DYNPRO_BUILD USING :
             ' ' 'VDARL-STITEL'      ZTITIG38-STIST.
    ENDIF.
  ENDIF.
  PERFORM BDC_DYNPRO_BUILD USING :
         ' ' 'BDC_OKCODE'       '=TAB_MD_REF'.

*> 세부화면 - 분석데이타.
*  IF g_mode EQ c_charc.
  IF ZTITPNK-XRANL IS INITIAL.
    CLEAR L_CHAR50.
  ELSE.
    WRITE: SY-DATLO TO L_CHAR50.
    CONCATENATE L_CHAR50 '변경 내역 확인 요망.' INTO L_CHAR50
                SEPARATED BY SPACE.
  ENDIF.

  WRITE ZTITPNK-LIFNR TO L_XALKZ.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPMF67A'          '1000',
         ' ' 'VDARL-ZUOND'       L_CHAR18,
         ' ' 'VDARL-REFER'       ZTITPNK-PNTNO,
         ' ' 'VDARL-MERKM'       ZTITPNK-BLNUM,
         ' ' 'VDARL-XALKZ'       L_XALKZ,
         ' ' 'VDARL-XALLB'       L_CHAR50,
         ' ' 'BDC_OKCODE'        '=TAB_CONDITION'.

*> 세부화면 - 분석데이타.
  WRITE: ZTITPNK-PNTAM TO L_CHAR18 CURRENCY ZTITPNK-WAERS.
  PERFORM    SET_WRITE_NO_MASK     CHANGING  L_CHAR18.
*> 이자율.
  WRITE: ZTITPNK-TSATZ TO L_CHAR10.
  PERFORM    SET_WRITE_NO_MASK     CHANGING  L_CHAR10.
*> 이자금액.
  WRITE ZTITPNK-ITRST  TO L_ITRST CURRENCY ZTITPNK-WAERS.
  PERFORM    SET_WRITE_NO_MASK     CHANGING  L_ITRST.

  L_DATE =  ZTITPNK-BGNDT + 1.
  IF ZTITPNK-PROCP EQ C_CHARP.
*    l_date_to = ZTITPNK-bgndt.
    L_DATE_TO = ZTITPNH-ZFBDT.
  ELSEIF ZTITPNK-PROCP EQ C_CHARC.
    L_DATE_TO = ZTITPNK-EXPDT.
  ENDIF.

  WRITE ZTITPNH-ZFBDT  TO L_DATE10 .
  WRITE L_DATE_TO      TO L_DATE10_TO.
  WRITE ZTITPNK-EXPDT  TO L_DATE10_EX.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPMF67A'             '1000',
         ' ' 'VZZKOKO-KZAHLUNG'     '100',   ">지급율.
         ' ' 'VZZKOKO-STILGART'     '1',     ">상환유형.
         ' ' 'VZZKOKO-SDISEIN'      '1',     ">할인결
         ' ' 'VZZKOKO-SZBMETH'      '2',     ">계산방법.
         ' ' 'VZZKOKO-SEFFMETH'     '1',     ">이자방법.
         ' ' 'RMF67-SINKKOKO'       'X',
         ' ' 'RMF67-XBZUSAGE'       L_CHAR18, ">금액.
         ' ' 'RMF67-XDGUEL_KK'      L_DATE10 ,
         ' ' 'RMF67-XDEFSZ'         L_DATE10_EX,
         ' ' 'RMF67-XDELFZ'         L_DATE10_EX,
*         ' ' 'RMF67-SINKKOKO'       ZTITPNK-expdt,
         ' ' 'VZZKOPO-DGUEL_KP(01)' L_DATE10,
*         ' ' 'VZZKOPO-PKOND(01)'    l_char10,     ">이자율.
         ' ' 'VZZKOPO-DFAELL(01)'   L_DATE10_TO,
         ' ' 'VZZKOPO-DVALUT(01)'   L_DATE10_EX,
         ' ' 'VZZKOPO-BKOND(01)'    L_ITRST,      ">이자금액.
         ' ' 'BDC_OKCODE'           '=PAYR'.

*>> [CHM2404-00673] BP:산업은행 02702 경우, 지급명세 수기 지정 (240520, 김예슬)
*   ASIS : 지급인/BP 02702 산업은행에 대하여 TA 차입원금 생성 시,
*   주거래은행 외화 G/L 계정이 없어서 오류 발생
*   TOBE : 지급인/BP 02702 정보는 유지하고, 02702 로 BP 지정할 경우,
*   주거래은행 코드를 26249 (신한은행) 으로 지정할 수 있도록 로직 추가

** 진로산업 Change 2007/04 --------------------------------------
*  SELECT SINGLE HKTID INTO LV_HKTID
*         FROM T012K
*         WHERE BUKRS  = '1000' AND
*               HBKID  = ZTITPNK-SSUCH+5(5) AND
*               WAERS  = ZTITPNK-WAERS AND
*               BKONT  = 'N'.

*  SELECT SINGLE HKTID INTO LV_HKTID  "-- 기존로직 (240520, 김예슬)
*         FROM T012K
*         WHERE BUKRS  = ZTITPNK-BUKRS AND
*               HBKID  = ZTITPNK-SSUCH+5(5) AND
*               WAERS  = ZTITPNK-WAERS AND
*               BKONT  = 'N'.
** 진로산업 Change 2007/04 --------------------------------------

  LV_SSUCH = ZTITPNK-SSUCH+5(5).

  IF ZTITPNK-SSUCH+5(5) = '02702'.
    CLEAR LV_SSUCH.
    LV_SSUCH = '26249'.
    SELECT SINGLE HKTID INTO LV_HKTID
       FROM T012K
       WHERE BUKRS  = ZTITPNK-BUKRS AND
             HBKID  = '26249'       AND
             WAERS  = ZTITPNK-WAERS AND
             BKONT  = 'N'.
  ELSE. "기존로직 적용
    SELECT SINGLE HKTID INTO LV_HKTID
       FROM T012K
       WHERE BUKRS  = ZTITPNK-BUKRS AND
             HBKID  = ZTITPNK-SSUCH+5(5) AND
             WAERS  = ZTITPNK-WAERS AND
             BKONT  = 'N'.
  ENDIF.
*<< [CHM2404-00673] BP:산업은행 02702 경우, 지급명세 수기 지정 (240520, 김예슬)

*--> [가온] 수입 결제처리 주거래은행 정보 반영
**** ONLY FOR TEST
  IF ZTITPNK-BUKRS = '6000'.
    CLEAR : LV_SSUCH.
    SELECT SINGLE HBKID
      INTO LV_SSUCH
      FROM ZTSTIG3
     WHERE BUKRS = ZTITPNK-BUKRS
       AND SSUCH = ZTITPNK-SSUCH
*       AND LIFNR = ZTITPNK-LIFNR
       AND PARTI = 'B'.

    IF SY-SUBRC = 0.
      CLEAR : LV_HKTID.
      SELECT SINGLE HKTID
        INTO LV_HKTID
        FROM T012K
       WHERE BUKRS  = ZTITPNK-BUKRS
         AND HBKID  = LV_SSUCH
         AND WAERS  = ZTITPNK-WAERS.
*         AND BKONT  = 'N'.
    ENDIF.
  ENDIF.
*<-- [가온] 수입 결제처리 주거래은행 정보 반영
  IF ZTITPNK-BUKRS EQ '6000'.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPLVD_PAYMENT_REQUEST' '1000',
         ' ' 'VTBZVERB-SSIGN(01)'     '+',             ">.
         ' ' 'VTBZVERB-SSIGN(02)'     '-',             ">.
         ' ' 'VTBZVERB-WAERS(01)'     ZTITPNK-WAERS,  ">
         ' ' 'VTBZVERB-WAERS(02)'     ZTITPNK-WAERS,  ">.
         ' ' 'VTBZVERB-HBKID(01)'     LV_SSUCH, "ZTITPNK-SSUCH+5(5),  ">
         ' ' 'VTBZVERB-HBKID(02)'     LV_SSUCH, "ZTITPNK-SSUCH+5(5),  ">
         ' ' 'VTBZVERB-HKTID(01)'     LV_HKTID,  ">
         ' ' 'VTBZVERB-HKTID(02)'     LV_HKTID,  ">
         ' ' 'VTBZVERB-RPZAHL(02)'    ZTITPNK-SSUCH+5(5),  ">
         ' ' 'VTBZVERB-RPBANK(02)'    '600T',  "> 가온의 경우 600T
         ' ' 'VTBZVERB-SPAYRQ(02)'    'X',  ">
         ' ' 'VTBZVERB-ZWELS(02)'     'F',  "> 펌뱅킹
         ' ' 'BDC_OKCODE'             '/00'.
    ELSE.
  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPLVD_PAYMENT_REQUEST' '1000',
         ' ' 'VTBZVERB-SSIGN(01)'     '+',             ">.
         ' ' 'VTBZVERB-SSIGN(02)'     '-',             ">.
         ' ' 'VTBZVERB-WAERS(01)'     ZTITPNK-WAERS,  ">
         ' ' 'VTBZVERB-WAERS(02)'     ZTITPNK-WAERS,  ">.
         ' ' 'VTBZVERB-HBKID(01)'     LV_SSUCH, "ZTITPNK-SSUCH+5(5),  ">
         ' ' 'VTBZVERB-HBKID(02)'     LV_SSUCH, "ZTITPNK-SSUCH+5(5),  ">
         ' ' 'VTBZVERB-HKTID(01)'     LV_HKTID,  ">
         ' ' 'VTBZVERB-HKTID(02)'     LV_HKTID,  ">
         ' ' 'VTBZVERB-RPZAHL(02)'    ZTITPNK-SSUCH+5(5),  ">
*         ' ' 'VTBZVERB-RPBANK(02)'    '1000',  ">
         ' ' 'VTBZVERB-RPBANK(02)'    ZTITPNK-BUKRS,  ">
         ' ' 'VTBZVERB-SPAYRQ(02)'    'X',  ">
         ' ' 'VTBZVERB-ZWELS(02)'     'D',  ">
         ' ' 'BDC_OKCODE'             '/00'.


ENDIF.
  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPLVD_PAYMENT_REQUEST' '1000',
         ' ' 'BDC_OKCODE'             '=BACK'.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPMF67A'             '1000',
         ' ' 'BDC_OKCODE'           '=SAVE'.

ENDFORM.                    " build_modify_bdc_data
*&---------------------------------------------------------------------*
*&      Form  get_cfm_partner_master
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_CFM_PARTNER_MASTER  USING    P_SSUCH   LIKE      ZTITPNK-SSUCH
                                      P_BUT000  STRUCTURE BUT000
                                      P_MSGTY.
  CLEAR: P_BUT000.
  CHECK NOT P_SSUCH IS INITIAL.

  SELECT SINGLE *
    FROM BUT000
   WHERE PARTNER EQ P_SSUCH.

  IF SY-SUBRC NE 0.
    MESSAGE ID 'R1' TYPE P_MSGTY NUMBER 201 WITH P_SSUCH.
  ENDIF.

ENDFORM.                    " get_cfm_partner_master
*&---------------------------------------------------------------------*
*&      Form  check_open_amount
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_OPEN_AMOUNT .

  DATA : L_TEXT_EXRATE(255)    TYPE C,
         L_FOREIGN_FACTOR(255) TYPE C,
         L_FTEXT11(11)         TYPE C,
         L_TTEXT11(11)         TYPE C,
         L_FACTOR              TYPE P,
         L_DATE                TYPE DATUM,
         L_WRBTR               TYPE WRBTR,
         L_NETWR               TYPE NETWR,
         L_RQMNG               TYPE ZTIRQMNG,
         L_PPMNG               TYPE ZTIPPMNG,
         L_FIXED_RATE          LIKE TCURS-SPRED,
         L_LOCAL_AMT           LIKE ZTITRQS-USAMT.  " USD 환산 Amount

  REFRESH: IT_PSPNR.
  CLEAR: G_WRBTR, G_PPAMT, IT_PSPNR, G_REFWR.
  LOOP AT IT_TAB INTO G_TC_2130_WA.

*> 정가 계산.
    IF G_TC_2130_WA-REFWR IS INITIAL.
      CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
        EXPORTING
          PEINH = G_TC_2130_WA-PEINH
          BPUMZ = G_TC_2130_WA-BPUMZ
          BPUMN = G_TC_2130_WA-BPUMN
          MENGE = G_TC_2130_WA-PNMNG
          NETPR = G_TC_2130_WA-NETPR
        CHANGING
          NETWR = G_TC_2130_WA-NETWR.
    ENDIF.
    ADD G_TC_2130_WA-NETWR TO G_WRBTR.
    ADD G_TC_2130_WA-REFWR TO G_REFWR.

    IF NOT G_TC_2130_WA-PS_PSP_PNR IS INITIAL.
      MOVE: G_TC_2130_WA-PS_PSP_PNR TO IT_PSPNR-PSPNR.
      COLLECT IT_PSPNR.
    ENDIF.
    IF G_MODE EQ C_CHARC OR
       G_MODE EQ C_CHARM.
      MODIFY IT_TAB FROM G_TC_2130_WA.
    ENDIF.
  ENDLOOP.

  IF ( G_MODE EQ C_CHARC OR
       G_MODE EQ C_CHARM ).
    IF ZTITPNK-RPAID EQ C_TRUE.
      G_WRBTR = ZTITIVK-RTCHG.
    ELSE.
      ZTITPNK-OTCHG = ZTITIVK-PKCHG + ZTITIVK-HDCHG + ZTITIVK-OTCHG.

      ADD ZTITPNK-OTCHG TO  G_WRBTR.
      G_WRBTR = G_WRBTR - ZTITIVK-RTCHG.
      IF G_WRBTR LT 0.
        G_WRBTR = 0.
      ENDIF.
    ENDIF.

    IF ZTITPNK-PNTAM NE G_WRBTR.
      IF G_MODE   EQ C_CHARC AND
         ( SY-DYNNR EQ C_SCR0100 OR
           SY-DYNNR EQ C_SCR0200 ).
        MESSAGE S810.
      ELSE.
        MESSAGE W810.
      ENDIF.
      ZTITPNK-PNTAM = G_WRBTR.
    ENDIF.

    ZTITPNK-REFWR = G_REFWR.
*    IF ZTITPNK-refwr IS INITIAL.
*      ZTITPNK-refwr = g_wrbtr.
*    ELSE.
*      IF ZTITPNK-refwr NE g_wrbtr.
*        IF g_mode   EQ c_charc AND
*           ( sy-dynnr EQ c_scr0100 OR
*             sy-dynnr EQ c_scr0200 ).
*          MESSAGE s810.
*        ELSE.
*          MESSAGE w810.
*        ENDIF.
*        ZTITPNK-refwr = g_wrbtr.
*      ENDIF.
*    ENDIF.
  ELSE.
    IF ZTITPNK-REFWR NE G_WRBTR.
      MESSAGE I809.
    ENDIF.
  ENDIF.

  ZTITPNK-NDAYS = ZTITPNK-BGNDT - ZTITPNK-EXPDT.

  IF ( G_MODE EQ C_CHARC OR
       G_MODE EQ C_CHARM ).
    IF ZTITRQS-UMTCU EQ C_TRUE.
      ZTITPNK-WAERS = 'USD'.
    ELSE.
      ZTITPNK-WAERS = ZTITPNK-WAER1.
    ENDIF.

    IF ZTITPNK-PNTDT IS INITIAL.
      ZTITPNK-PNTDT = SY-DATLO.
    ENDIF.
    IF ZTITPNK-HWAER IS INITIAL.
      ZTITPNK-HWAER = T001-WAERS.
    ENDIF.
    IF ZTITPNK-WAERS EQ ZTITPNK-HWAER.
      ZTITPNK-DMBTR = ZTITPNK-PNTAM.
      ZTITPNK-KURSF = 1.
*      EXIT.
    ENDIF.
  ENDIF.

*> Notice amount.
  CHECK: G_MODE EQ C_CHARC OR
         G_MODE EQ C_CHARM.

  ZTITPNK-UCURR = 'USD'.

  IF ZTITPNK-WAERS EQ ZTITPNK-UCURR.
*  IF ZTITPNK-waer1 EQ ZTITPNK-waers.
    ZTITPNK-USAMT = ZTITPNK-PNTAM.
    ZTITPNK-WKURS = 1.
    EXIT.
  ENDIF.

  IF ZTITPNK-CDAT IS INITIAL.
    ZTITPNK-CDAT = SY-DATLO.
  ENDIF.

*> Get exchange rate
  CLEAR: BAPIRET1, BAPI1093_0.
  CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
    EXPORTING
      RATE_TYPE  = 'M'
      FROM_CURR  = ZTITPNK-WAERS
      TO_CURRNCY = ZTITPNK-UCURR
      DATE       = ZTITPNK-CDAT
    IMPORTING
      EXCH_RATE  = BAPI1093_0
      RETURN     = BAPIRET1.

  IF BAPIRET1-TYPE EQ C_ERROR.
    MESSAGE ID BAPIRET1-ID TYPE BAPIRET1-TYPE NUMBER BAPIRET1-NUMBER
               WITH BAPIRET1-MESSAGE_V1 BAPIRET1-MESSAGE_V2
                    BAPIRET1-MESSAGE_V3 BAPIRET1-MESSAGE_V4.
  ENDIF.

  IF ZTITPNK-WAERS NE ZTITPNK-UCURR.
    IF BAPI1093_0-EXCH_RATE_V IS INITIAL.
      ZTITPNK-WKURS = BAPI1093_0-EXCH_RATE.
    ELSE.
      ZTITPNK-WKURS = BAPI1093_0-EXCH_RATE_V.
    ENDIF.
  ENDIF.

  IF NOT ZTITPNK-WKURS IS INITIAL.
    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERN_9'
      EXPORTING
        CURRENCY        = ZTITPNK-WAERS
        AMOUNT_INTERNAL = ZTITPNK-PNTAM
      IMPORTING
        AMOUNT_EXTERNAL = BAPICURX-BAPICURX.

*  ZTITRQS-usamt = bapicurx-bapicurx *  bapi1093_0-exch_rate *
*                   ( bapi1093_0-to_factor / bapi1093_0-from_factor ).
    ZTITPNK-USAMT = BAPICURX-BAPICURX *  ( 1 / ZTITPNK-WKURS ) *
                    ( BAPI1093_0-TO_FACTOR / BAPI1093_0-FROM_FACTOR ).

    BAPICURX-BAPICURX = ZTITPNK-USAMT.
    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERN_9'
      EXPORTING
        CURRENCY             = ZTITPNK-UCURR
        AMOUNT_EXTERNAL      = BAPICURX-BAPICURX
        MAX_NUMBER_OF_DIGITS = 18
      IMPORTING
        AMOUNT_INTERNAL      = ZTITPNK-USAMT.
  ENDIF.
*
  IF ZTITPNK-ITRST IS INITIAL.
    ZTITPNK-ITRST = ZTITPNK-PNTAM * ( ZTITPNK-TSATZ / 100 ).
  ENDIF.

ENDFORM.                    " check_open_amount
*&---------------------------------------------------------------------*
*&      Form  get_deff_currency_conv_rate
*&---------------------------------------------------------------------*
*       전환율 계산.
*----------------------------------------------------------------------*
FORM GET_DEFF_CURRENCY_CONV_RATE .

  DATA : L_TEXT_EXRATE(255)    TYPE C,
         L_FOREIGN_FACTOR(255) TYPE C,
         L_FTEXT11(11)         TYPE C,
         L_TTEXT11(11)         TYPE C,
         L_FACTOR              TYPE P,
         L_DATE                TYPE DATUM,
         L_WRBTR               TYPE WRBTR,
         L_NETWR               TYPE NETWR,
         L_RQMNG               TYPE ZTIRQMNG,
         L_PPMNG               TYPE ZTIPPMNG,
         L_FIXED_RATE          LIKE TCURS-SPRED,
         L_LOCAL_AMT1          LIKE ZTITRQS-USAMT,  " USD 환산 Amount
         L_LOCAL_AMT2          LIKE ZTITRQS-USAMT.  " USD 환산 Amount

  CHECK NOT  ZTITPNK-BGNDT IS INITIAL.

*> Notice amount.
  PERFORM    CONVERT_TO_LOCAL_CURRENCY(ZTIR0000)
                                       USING    1
                                                ZTITPNK-WAERS
                                                T001-WAERS
                                                ZTITPNK-BGNDT
                                       CHANGING L_LOCAL_AMT1
                                                L_TEXT_EXRATE
                                                L_FIXED_RATE.


  PERFORM    CONVERT_TO_LOCAL_CURRENCY(ZTIR0000)
                                       USING    1
                                                ZTITPNK-WAER1
                                                T001-WAERS
                                                ZTITPNK-BGNDT
                                       CHANGING L_LOCAL_AMT2
                                                L_TEXT_EXRATE
                                                L_FIXED_RATE.
*> 전환율.
  IF ZTITPNK-BNRAT IS INITIAL.
    ZTITPNK-BNRAT = L_LOCAL_AMT2 / L_LOCAL_AMT1.
  ENDIF.
*> Notice 금액.
  IF ZTITPNK-PNTAM IS INITIAL.
    ZTITPNK-PNTAM = ZTITPNK-REFWR * ZTITPNK-BNRAT.
  ENDIF.
ENDFORM.                    " get_deff_currency_conv_rate
*&---------------------------------------------------------------------*
*&      Form  call_usance_clearing_doc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_USANCE_CLEARING_DOC  TABLES  PT_TAB     STRUCTURE G_TC_2130_WA
                               USING   P_ZTITPNK STRUCTURE ZTITPNK
                                       P_SUBRC    LIKE      SY-SUBRC
                                       P_MODE.
  DATA: XKDF(1) TYPE C,             "X Kursdifferenzen im Spiel
        XSKV(1) TYPE C.             "X Skontoverrechnung im Spiel

* ------ Tabelle der Einzelposten --------------------------------------
  DATA:    BEGIN OF POSTAB OCCURS 50,
             XAUTH(1)  TYPE C,                 " Berechtigung?
             XHELL(1)  TYPE C.                 " Hell anzeigen?
             INCLUDE STRUCTURE RFPOS.              " Listanzeigen-Struktur
  INCLUDE RFEPOSC9.                     " Kunden-Sonderfelder
  DATA:      XBKPF(1)  TYPE C,                 " BKPF nachgelesen?
             XBSEG(1)  TYPE C,                 " BSEG nachgelesen?
             XBSEC(1)  TYPE C,                 " BSEC nachgelesen?
             XBSED(1)  TYPE C,                 " BSED nachgelesen?
             XPAYR(1)  TYPE C,                 " PAYR nachgelesen?
             XBSEGC(1) TYPE C,                 " BSEGC nachgelesen?
             XBSBV(1)  TYPE C,                 " BSBV nachgelesen?
             XMOD(1)   TYPE C,                 " POSTAB modifiziert?
           END OF POSTAB.

  DATA YACCNT  LIKE RF05R_ACCT OCCURS 6 WITH HEADER LINE.


  CLEAR: P_SUBRC.

  CLEAR: SESSION.
  CTU_PARAMS-DISMODE  = 'E'. ">처리모드
  CTU_PARAMS-UPDMODE  = 'S'. ">갱신모드
  CTU_PARAMS-CATTMODE = ' '. ">CATT 모드...
  CTU_PARAMS-DEFSIZE  = ' '. ">기본화면 크기
  CTU_PARAMS-RACOMMIT = 'X'.
  CTU_PARAMS-NOBINPT  = 'X' .
  CTU_PARAMS-NOBIEND  = 'X'.

  IF  P_MODE EQ C_CHARP.
*> Setting 반제 BDC data
    PERFORM  BUILD_F_51_BDC_DATA  USING  P_ZTITPNK.
*    break-point.
*> Call transactions
    PERFORM  CALL_F_51_UPDATE_BDC USING  'F-51'
                                         P_SUBRC
                                         P_ZTITPNK.
  ELSE.
    CALL FUNCTION 'READ_DOCUMENT_HEADER'
      EXPORTING
        BELNR     = P_ZTITPNK-BELNR
        BSTAT     = SPACE
        BUKRS     = P_ZTITPNK-BUKRS
        GJAHR     = P_ZTITPNK-GJAHR
        XARCH     = SPACE          "keine Suche im Archiv
      IMPORTING
        E_BKPF    = BKPF
      EXCEPTIONS
        EXIT      = 4
        NOT_FOUND = 8.

    CALL FUNCTION 'GET_CLEARED_ITEMS'
      EXPORTING
        I_BVORG   = BKPF-BVORG
        I_BUKRS   = P_ZTITPNK-BUKRS
        I_BELNR   = P_ZTITPNK-BELNR
        I_GJAHR   = P_ZTITPNK-GJAHR
        I_AUGDT   = '00000000'
        I_RFZEI   = '000'
      IMPORTING
        E_XKDF    = XKDF
        E_XSKV    = XSKV
      TABLES
        T_ITEMS   = POSTAB
        T_ACCNT   = YACCNT
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.

    CASE SY-SUBRC.
      WHEN 1.
        MESSAGE I598(FS) WITH P_ZTITPNK-BELNR P_ZTITPNK-BUKRS
                              P_ZTITPNK-GJAHR.
        EXIT.
      WHEN 2.
        MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        CLEAR: P_ZTITPNK-BELNR, P_ZTITPNK-GJAHR.
        P_ZTITPNK-FBRAX = C_TRUE.
        EXIT.
    ENDCASE.

    CTU_PARAMS-NOBINPT  = 'X' .
    CTU_PARAMS-NOBIEND  = 'X'.

*> 반제용 BDC data Setting.
    PERFORM  BUILD_FBRA_BDC_DATA  USING  P_ZTITPNK.
*> 반제용 BDC Call.
    PERFORM  CALL_FBRA_UPDATE_BDC USING  'FBRA'
                                         P_SUBRC
                                         P_ZTITPNK.
  ENDIF.

ENDFORM.                    " call_usance_clearing_doc
*&---------------------------------------------------------------------*
*&      Form  build_f_51_bdc_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUILD_F_51_BDC_DATA USING P_ZTITPNK  STRUCTURE ZTITPNK.

  TABLES: T021R.

  DATA: L_CHAR18(18) TYPE   C,
        L_LIFNR      TYPE   LIFNR,
        L_RSTGR      LIKE   DF05B-RSTGR.

  DATA: L_FIELDNAME(20) TYPE C,
        L_KOART         TYPE KOART,   ">계정유형.
        L_FELDN         TYPE FNAME_D. ">필드이름.

  DATA: L_INV_DOC_NO TYPE BELNR_D,
        L_FISC_YEAR  TYPE GJAHR.

  REFRESH : BDCDATA, MESSTAB.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPMF05A'          '0122',
         ' ' 'BKPF-BLDAT'        ZTITPNH-BLDAT,
         ' ' 'BKPF-BLART'        ZTITPNH-BLART,
         ' ' 'BKPF-BUKRS'        ZTITPNH-BUKRS,
         ' ' 'BKPF-BUDAT'        ZTITPNH-BUDAT,
         ' ' 'BKPF-WAERS'        ZTITPNH-WAERS,
         ' ' 'RF05A-NEWBS'       '50',
         ' ' 'RF05A-NEWKO'       ZTITPNH-SAKNR,
         ' ' 'BDC_OKCODE'       '/00'.

*> 세부화면 - 분석데이타.(Notice Amount)
*>
  READ TABLE IT_BELNR INDEX 1.
  WRITE: ZTITPNH-IVAMP TO L_CHAR18 CURRENCY P_ZTITPNK-WAERS.
*  WRITE: it_belnr-netwr    TO l_char18 CURRENCY ZTITPNH-waers.
  PERFORM    SET_WRITE_NO_MASK     CHANGING  L_CHAR18.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPMF05A'          '0300',
         ' ' 'BSEG-WRBTR'        L_CHAR18 ,
*         ' ' 'BSEG-GSBER'        ztisscrcom-gsber,
         ' ' 'COBL-GSBER'        ZTISSCRCOM-GSBER,
         ' ' 'BSEG-SGTXT'        'Usance 차입 AP 반제',
         ' ' 'BDC_OKCODE'       '=SL'.

*  PERFORM bdc_dynpro_build USING :
*         'X' 'SAPLKACB'          '0002',
*         ' ' 'BDC_OKCODE'       '=ENTE'.
*
*> [TraSys] 미결항목 선택시 라디오버튼 위치를 찾는 함수
  L_FELDN = 'BELNR'.
*  l_koart = p_agkoa.
*  l_koart = c_chars.

  CALL FUNCTION 'Z_TS_GET_OPEN_SEL_POSITION'
    EXPORTING
      IM_KOART  = L_KOART
      IM_FELDN  = L_FELDN
    IMPORTING
      EX_T021R  = T021R
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  T021R-SELPS = T021R-SELPS + 1.

  CONCATENATE 'RF05A-XPOS1(' T021R-SELPS ')' INTO L_FIELDNAME.

  SELECT SINGLE *
    FROM ZTITIG00
   WHERE BUKRS EQ P_ZTITPNK-BUKRS.
  IF SY-SUBRC EQ 0.
    IF ZTITIG00-SJPAP EQ C_CHARV.
      L_LIFNR = P_ZTITPNK-LIFNR.
    ELSEIF ZTITIG00-SJPAP EQ C_CHARB.
      SELECT SINGLE *
        FROM ZTSTIG3
       WHERE PARTI EQ C_CHARB
         AND EPART EQ ZTITPNK-NTCBK.
      IF SY-SUBRC EQ 0.
        L_LIFNR = ZTSTIG3-LIFNR.
      ENDIF.
    ENDIF.
  ENDIF.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPMF05A'          '0710',
*         ' ' 'RF05A-AGBUK'       p_ztitpnk-bukrs,
         ' ' 'RF05A-AGKON'       L_LIFNR,
*         ' ' 'RF05A-AGKON'       p_ztitpnk-lifnr,
         ' ' 'RF05A-AGKOA'       C_CHARK,
         ' ' L_FIELDNAME         C_TRUE,
         ' ' 'BDC_OKCODE'       '=PA'.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPMF05A'          '0731',
         ' ' 'RF05A-SEL01(01)'   IT_BELNR-BELNR,
         ' ' 'BDC_OKCODE'       '=PA'.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPDF05X'        '3100',
         ' ' 'BDC_OKCODE'      '=PART'.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPDF05X'        '3100',
         ' ' 'RF05A-ABPOS'     '1',
         ' ' 'BDC_OKCODE'      '/00'.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPDF05X'        '3100',
         ' ' 'BDC_SUBSCR'
             'SAPDF05X                                6104PAGE',
         ' ' 'BDC_CURSOR'      'RFOPS_DK-BELNR(01)',
         ' ' 'BDC_OKCODE'      '=Z+'.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPDF05X'        '3100',
         ' ' 'DF05B-PSZAH(01)' L_CHAR18,
         ' ' 'RF05A-AKOBT'     '0',
         ' ' 'BDC_OKCODE'       '=TX'.

*         ' ' 'BDC_OKCODE'       '=BS'.

*
*  PERFORM bdc_dynpro_build USING :
*         'X' 'SAPDF05X'          '3100',
*         ' ' 'BDC_OKCODE'       '=OMX'.
*
*  PERFORM bdc_dynpro_build USING :
*         'X' 'SAPDF05X'          '3100',
*         ' ' 'BDC_CURSOR'        'DF05B-PSSKT(01)',
*         ' ' 'BDC_OKCODE'       '=Z-'.
*
*  PERFORM bdc_dynpro_build USING :
*         'X' 'SAPDF05X'          '3100',
*         ' ' 'BDC_CURSOR'        'DF05B-PSSKT(01)',
*         ' ' 'BDC_OKCODE'       '=Z+'.
*
** Usance bdc오류로 인해 시뮬레이션 버튼 추가 2003.12.12
*  PERFORM bdc_dynpro_build USING :
*         'X' 'SAPDF05X'          '3100',
*         ' ' 'BDC_OKCODE'       '=BS'.
*
** NEXT SCREEN
*  PERFORM bdc_dynpro_build USING :
*      'X' 'SAPMF05A'          '0700',
*      ' ' 'BDC_OKCODE'        '=S--'.         " 전기.
*
  PERFORM BDC_DYNPRO_BUILD USING :
      'X' 'SAPDF05X'          '2001',
      ' ' 'RF05A-AUGTX'       '수입시스템 반제전표',
      ' ' 'BDC_OKCODE'        '=GO'.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPDF05X'        '3100',
         ' ' 'BDC_OKCODE'       '=BS'.

** NEXT SCREEN
*  PERFORM bdc_dynpro_build USING :
*      'X' 'SAPMF05A'          '0300',
*      ' ' 'BSEG-ZUONR'        '수입반제',
*      ' ' 'BSEG-SGTXT'        '수입시스템 반제전표',
*      ' ' 'BDC_OKCODE'        '=BU'.         " 전기.
*
  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPMF05A'         '0750', "'0700', (240528, 김예슬)
         ' ' 'BDC_OKCODE'       '=BU'.

ENDFORM.                    " build_f_51_bdc_data
*&---------------------------------------------------------------------*
*&      Form  call_F_51_update_bdc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_F_51_UPDATE_BDC  USING    P_TCODE
                                    P_SUBRC
                                    P_ZTITPNK STRUCTURE ZTITPNK.

  DATA: L_INV_DOC_NO TYPE BELNR_D,
        L_FISC_YEAR  TYPE GJAHR.

  CLEAR: P_SUBRC.
*> Parameter id clearing
  SET PARAMETER ID 'BLN' FIELD ''.
  SET PARAMETER ID 'GJR' FIELD ''.    " 회계년도.

  PERFORM BDC_TRANSACTION USING P_TCODE P_SUBRC.

  IF P_SUBRC EQ 0.
    GET PARAMETER ID 'BLN' FIELD P_ZTITPNK-BELNR.
    GET PARAMETER ID 'GJR' FIELD P_ZTITPNK-GJAHR.    " 회계년도.

    IF OK_CODE_OLD EQ 'ZTIDELETE'.
      LOOP AT  MESSTAB.
        SY-MSGNO = MESSTAB-MSGNR.
        ZTI_MESSAGE C_ERROR MESSTAB-MSGID SY-MSGNO
            MESSTAB-MSGV1 MESSTAB-MSGV2 MESSTAB-MSGV3 MESSTAB-MSGV4.
      ENDLOOP.
    ENDIF.
  ELSE.
    LOOP AT MESSTAB WHERE MSGTYP EQ 'E'.
      SY-MSGNO = MESSTAB-MSGNR.
      ZTI_MESSAGE MESSTAB-MSGTYP MESSTAB-MSGID SY-MSGNO
          MESSTAB-MSGV1 MESSTAB-MSGV2 MESSTAB-MSGV3 MESSTAB-MSGV4.
    ENDLOOP.
    IF SY-SUBRC NE 0.
      DESCRIBE TABLE MESSTAB LINES G_LINE.
      IF G_LINE GT 1.
        G_LINE = G_LINE - 1.
        READ TABLE MESSTAB INDEX G_LINE.
        SY-MSGNO = MESSTAB-MSGNR.
        ZTI_MESSAGE C_ERROR MESSTAB-MSGID SY-MSGNO
            MESSTAB-MSGV1 MESSTAB-MSGV2 MESSTAB-MSGV3 MESSTAB-MSGV4.
      ELSE.
        MESSAGE S926.
        PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " call_F_51_update_bdc
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_CONFIRM_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM_MESSAGE USING P_MODE.

  IF ZTITRQK-REQTY EQ C_LC     AND
     ZTITRQK-ILCTY EQ C_CHARU  AND
     ZTITRQS-PAGRT NE '2AB'    AND
   ( OK_CODE        EQ 'ZTISAVE' OR
     OK_CODE        EQ 'ZTIDELETE' ).
    CLEAR: OK-CODE.
    IF ZTITPNK-BELNR IS INITIAL.
      IF ZTITPNK-SAKNR IS INITIAL.
        ZTITPNK-SAKNR = ZTITIG38-SAKNR.
      ENDIF.

      MOVE-CORRESPONDING ZTITPNK         TO ZTITPNH.
      MOVE: ZTITIG38-BLART               TO ZTITPNH-BLART,
            SY-DATLO                     TO ZTITPNH-BUDAT,
            ZTITPNK-PNTAM                TO ZTITPNH-IVAMP,
            ZTITPNK-WAERS                TO ZTITPNH-WAERS,
            ZTITPNK-SAKNR                TO ZTITPNH-SAKNR,
            'Usance 전표를 반제합니다.'   TO SPOP-TEXTLINE1.
      CALL SCREEN '6000' STARTING AT 001 001.
*                         ENDING AT x2 y2
    ELSE.
      SPOP-TEXTLINE1 = 'Usance 전표를 반제합니다.'.
      CALL SCREEN '6010' STARTING AT 001 001.
    ENDIF.
    IF OK-CODE EQ 'ZTIOKAY'.
      G_ANSWER = C_CHARY.
    ELSE.
      G_ANSWER = C_CHARN.
    ENDIF.
  ELSE.
    CALL FUNCTION 'Z_TI_POPUP_TO_CONFIRM_MESSAGE'
      EXPORTING
        XMODE  = P_MODE
      IMPORTING
        ANSWER = G_ANSWER.
  ENDIF.

ENDFORM.                    " POPUP_TO_CONFIRM_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  BUILD_FBRA_BDC_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUILD_FBRA_BDC_DATA USING P_ZTITPNK STRUCTURE ZTITPNK.

  DATA: L_DATE(10)   TYPE C.

  REFRESH : BDCDATA, MESSTAB.

  IF POSTINGDATE IS INITIAL.
    CLEAR L_DATE.
  ELSE.
    WRITE: POSTINGDATE TO L_DATE.
  ENDIF.
* 초기화면 FIELD
  PERFORM BDC_DYNPRO_BUILD USING :
      'X' 'SAPMF05R'    '0100',
      ' ' 'RF05R-AUGBL' P_ZTITPNK-BELNR,      " 역분개할 전표.
      ' ' 'RF05R-BUKRS' P_ZTITPNK-BUKRS,      " Company Code
      ' ' 'RF05R-GJAHR' P_ZTITPNK-GJAHR,      " 회계연도.
      ' ' 'BDC_OKCODE'  '=RAGL'.               " 전기.

* NEXT FIELD
  SELECT *
    FROM BSEG
   WHERE BUKRS  EQ  P_ZTITPNK-BUKRS
     AND BELNR  EQ  P_ZTITPNK-BELNR
     AND GJAHR  EQ  P_ZTITPNK-GJAHR
     AND KTOSL  EQ  'KDF'.
  ENDSELECT.
  IF SY-SUBRC EQ 0.
    PERFORM BDC_DYNPRO_BUILD USING :
           'X' 'SAPLSPO1'    '0300',
           ' ' 'BDC_OKCODE'  '=YES'.         " 전기.
  ELSE.
    PERFORM BDC_DYNPRO_BUILD USING :
           'X' 'SAPLSPO2'    '0100',
           ' ' 'BDC_OKCODE'  '=OPT2'.         " 전기.
  ENDIF.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPMF05R'    '0300',
         ' ' 'RF05R-STGRD' REASONREVERSAL,  " 역분개 사유.
         ' ' 'RF05R-BUDAT' L_DATE,          " Company Code
         ' ' 'BDC_OKCODE'  '=ENTR'.         " 전기.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPMF05R'    '0100',
         ' ' 'BDC_OKCODE'  '/EEEND'.         " 전기.

ENDFORM.                    " BUILD_FBRA_BDC_DATA
*&---------------------------------------------------------------------*
*&      Form  get_account_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_ACCOUNT_DOCUMENT .

  DATA: L_BELNR TYPE   BELNR_D,
        L_GJAHR TYPE   GJAHR,
        L_BLART TYPE   BLART,
        L_WRBTR TYPE   WRBTR,
        L_AWTYP LIKE   BKPF-AWTYP,
        L_AWKEY LIKE   BKPF-AWKEY.

  REFRESH : IT_BELNR.
  LOOP AT IT_TAB INTO G_TC_2130_WA.
    IF NOT G_TC_2130_WA-IVONO IS INITIAL.
      SELECT SINGLE BELNR GJAHR BLART
        INTO (L_BELNR, L_GJAHR, L_BLART)
        FROM ZTITIVK
       WHERE IVONO  EQ  G_TC_2130_WA-IVONO.
      IF NOT L_BELNR IS INITIAL.
        L_AWKEY       = L_BELNR.
        L_AWKEY+10(4) = L_GJAHR.
        L_AWTYP       = 'RMRP '.

        SELECT SINGLE BELNR GJAHR
          INTO (IT_BELNR-BELNR, IT_BELNR-GJAHR)
          FROM BKPF
         WHERE AWTYP  EQ  L_AWTYP
           AND BLART  EQ  L_BLART
           AND AWKEY  EQ  L_AWKEY.
        IF SY-SUBRC  EQ  0.
          SELECT SINGLE REFWR
            INTO IT_BELNR-REFWR
            FROM ZTITIVP
           WHERE IVONO  EQ  G_TC_2130_WA-IVONO
             AND RBLGP  EQ  G_TC_2130_WA-RBLGP.
          IT_BELNR-NETWR = G_TC_2130_WA-NETWR.
          COLLECT IT_BELNR.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE IT_BELNR LINES G_LINE.
  CASE G_LINE.
    WHEN 0.         MESSAGE E813.
    WHEN 1.
      READ TABLE IT_BELNR INDEX 1.
      SELECT SINGLE *
        FROM ZTITIVK
       WHERE IVONO  EQ  IT_BELNR-IVONO.
      IF SY-SUBRC EQ 0.
        IT_BELNR-NETWR = IT_BELNR-NETWR - ZTITIVK-RTCHG.
        MODIFY IT_BELNR INDEX 1.
      ENDIF.
    WHEN OTHERS.    MESSAGE E814 WITH G_LINE.
  ENDCASE.

ENDFORM.                    " get_account_document
*&---------------------------------------------------------------------*
*&      Form  call_fbra_update_bdc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_FBRA_UPDATE_BDC  USING    P_TCODE
                                    P_SUBRC
                                    P_ZTITPNK STRUCTURE ZTITPNK.

  DATA: L_IF_NULL    TYPE REF TO IF_MESSAGE_OBJ_MM.
  DATA: L_INV_DOC_NO TYPE BELNR_D,
        L_FISC_YEAR  TYPE GJAHR.

  CLEAR: SESSION.
  CTU_PARAMS-DISMODE  = 'E'. ">처리모드
  CTU_PARAMS-UPDMODE  = 'S'. ">갱신모드
  CTU_PARAMS-CATTMODE = ' '. ">CATT 모드...
  CTU_PARAMS-DEFSIZE  = ' '. ">기본화면 크기
  CTU_PARAMS-RACOMMIT = 'X'.
  CTU_PARAMS-NOBINPT  = 'X'.
  CTU_PARAMS-NOBIEND  = 'X'.

  CLEAR: P_SUBRC.

*> Parameter id clearing
  SET PARAMETER ID 'BLN' FIELD ''.        " 전표번호.
  SET PARAMETER ID 'GJR' FIELD ''.        " 회계년도.

  PERFORM BDC_TRANSACTION USING P_TCODE P_SUBRC.

  IF P_SUBRC EQ 0.
    GET PARAMETER ID 'BLN' FIELD INVOICEDOCNUMBER_REVERSAL.
    GET PARAMETER ID 'GJR' FIELD FISCALYEAR_REVERSAL.    " 회계년도.

    IF NOT INVOICEDOCNUMBER_REVERSAL IS INITIAL.
      CLEAR: P_ZTITPNK-BELNR, P_ZTITPNK-GJAHR.
      P_ZTITPNK-FBRAX = C_TRUE.
    ELSE.
      MESSAGE S926.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.
  ELSE.
    LOOP AT MESSTAB WHERE MSGTYP EQ 'E'.
      SY-MSGNO = MESSTAB-MSGNR.
      ZTI_MESSAGE MESSTAB-MSGTYP MESSTAB-MSGID SY-MSGNO
          MESSTAB-MSGV1 MESSTAB-MSGV2 MESSTAB-MSGV3 MESSTAB-MSGV4.
    ENDLOOP.
    IF SY-SUBRC NE 0.
      MESSAGE S926.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.
  ENDIF.

*> 오류정보가 존재시 메시지 상자 POPUP.
  G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                          IM_BUSINESS_OBJ          = L_IF_NULL
                          IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

  IF G_LINE GT 0.
    P_SUBRC = 4.
  ENDIF.

ENDFORM.                    " call_fbra_update_bdc
*&---------------------------------------------------------------------*
*&      Form  check_document_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_DOCUMENT_STATUS .

  CASE G_MODE.
    WHEN C_CHARM.    ">변경일 경우.
      IF NOT ZTITPNK-BELNR IS INITIAL.
        MESSAGE E817 WITH ZTITPNK-PNTNO '변경'.
      ENDIF.
    WHEN C_CHARD.    ">삭제일 경우.
      IF ZTITRQS-UMTCU EQ C_TRUE AND
         ZTITRQK-REQTY EQ C_LC.
*        IF NOT ZTITPNK-belnr IS INITIAL OR
*           NOT ZTITPNK-xranl IS INITIAL.
*          MESSAGE w817 WITH ZTITPNK-pntno '삭제'.
*        ENDIF.
      ELSE.
        IF NOT ZTITPNK-BELNR IS INITIAL OR
           NOT ZTITPNK-XRANL IS INITIAL.
          MESSAGE E817 WITH ZTITPNK-PNTNO '삭제'.
        ENDIF.
      ENDIF.

    WHEN C_CHARS.    ">조회일 경우.
    WHEN C_CHARP.    ">전기일 경우.
      IF ZTITRQK-ILCTY NE C_CHARU.
        MESSAGE E815 WITH ZTITPNK-PNTNO.
      ENDIF.
      IF NOT ZTITRQS-UMTCU IS INITIAL.
        MESSAGE E820 WITH ZTITPNK-PNTNO.
      ENDIF.

      IF NOT ZTITPNK-BELNR IS INITIAL AND
         NOT ZTITPNK-XRANL IS INITIAL.
        MESSAGE E818 WITH ZTITPNK-PNTNO.
      ENDIF.
    WHEN C_CHARR.    ">취소일 경우.
      IF ZTITRQK-ILCTY NE C_CHARU.
        MESSAGE E815 WITH ZTITPNK-PNTNO.
      ENDIF.
      IF NOT ZTITRQS-UMTCU IS INITIAL.
        MESSAGE E820 WITH ZTITPNK-PNTNO.
      ENDIF.

      IF ZTITPNK-BELNR IS INITIAL AND
         ZTITPNK-XRANL IS INITIAL.
        MESSAGE E816 WITH ZTITPNK-PNTNO.
      ENDIF.
  ENDCASE.

  MESSAGE S933.

ENDFORM.                    " check_document_status
*&---------------------------------------------------------------------*
*&      Form  call_loan_master_create
*&---------------------------------------------------------------------*
*       반제처리 및 Loan Master 생성.
*----------------------------------------------------------------------*
FORM CALL_LOAN_MASTER_CREATE .

  DATA: L_IF_NULL    TYPE REF TO IF_MESSAGE_OBJ_MM.

* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

  CLEAR: OK-CODE.
*> Getting 반제할 전표번호.
  PERFORM  GET_ACCOUNT_DOCUMENT.

*> Master 정보.
  SELECT SINGLE *
    FROM ZTITIG38
   WHERE BUKRS EQ ZTITPNK-BUKRS.
  IF SY-SUBRC NE 0.
    MESSAGE E822 WITH ZTITPNK-BUKRS.
  ENDIF.

  MOVE-CORRESPONDING ZTITPNK  TO ZTITPNH.
  MOVE: ZTITPNK-PNTAM         TO ZTITPNH-IVAMP,
        ZTITIG38-BLART        TO ZTITPNH-BLART,
        SY-DATLO              TO ZTITPNH-BUDAT,
        SY-DATLO              TO ZTITPNH-BLDAT.

  READ TABLE IT_BELNR INDEX 1.
  MOVE: IT_BELNR-BELNR        TO ZTISSCRCOM-BELNR,
        IT_BELNR-GJAHR        TO ZTISSCRCOM-GJAHR,
        ZTITPNK-BUKRS         TO ZTISSCRCOM-BUKRS.

**> A/P의 사업영역 찾기.
*  select gsber
*    into ztisscrcom-gsber
*    from bseg up to 1 rows
*   where BUKRS eq ztisscrcom-bukrs
*     and BELNR eq ztisscrcom-belnr
*     and GJAHR eq ztisscrcom-gjahr
*     and KOART eq c_chark  ">거래처계정이 아닌것.
*     and SHKZG eq c_charh. ">차변.
*  endselect.

  IF ZTITRQK-REQTY EQ C_LC     AND
     ZTITRQK-ILCTY EQ C_CHARU  AND
     ZTITRQS-PAGRT EQ '2AA'.
    SELECT SINGLE *
      FROM BKPF
     WHERE BUKRS EQ ZTISSCRCOM-BUKRS
       AND BELNR EQ ZTISSCRCOM-BELNR
       AND GJAHR EQ ZTISSCRCOM-GJAHR.
    IF SY-SUBRC EQ 0.
      IF ZTITIG38-ASNBA EQ C_TRUE.
        SELECT GSBER
          INTO ZTISSCRCOM-GSBER
          FROM BSEG UP TO 1 ROWS
         WHERE BUKRS EQ ZTISSCRCOM-BUKRS
           AND BELNR EQ ZTISSCRCOM-BELNR
           AND GJAHR EQ ZTISSCRCOM-GJAHR
           AND KOART NE C_CHARK  ">거래처계정이 아닌것.
           AND SHKZG EQ C_CHARS. ">차변.
        ENDSELECT.
        IF SY-SUBRC EQ 0.
          IF NOT ZTISSCRCOM-GSBER IS INITIAL.
            SELECT SINGLE KOSTL
              INTO ZTISSCRCOM-KOSTL
              FROM ZTITIG39
             WHERE GSBER EQ ZTISSCRCOM-GSBER.
            IF SY-SUBRC NE 0.
              MESSAGE E824 WITH ZTISSCRCOM-GSBER.
            ENDIF.
*>
            SELECT SINGLE GSBER
              INTO ZTISSCRCOM-GSBER
              FROM CSKS
             WHERE KOKRS EQ ZTISSCRCOM-BUKRS
               AND KOSTL EQ ZTISSCRCOM-KOSTL
               AND DATBI GE SY-DATLO.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  SPOP-TEXTLINE1 = '해당 금액에 대해 차입정보를 생성합니다.'.

  CALL SCREEN  6000 STARTING AT 01    01.

  IF OK-CODE EQ 'ZTIOKAY'.
*> Fields check.
    PERFORM  CHECK_FOR_DOCUMENT_FIELD USING G_MODE.
    IF G_LINE EQ 0.
      MESSAGE S911.
    ELSE.
      EXIT.
    ENDIF.
*> A/P 반제처리.
    IF ZTITRQK-REQTY EQ C_LC     AND
       ZTITRQK-ILCTY EQ C_CHARU  AND
       ZTITRQS-PAGRT EQ '2AA'.
*       ZTITRQS-umtcu EQ c_false.
      IF ZTITPNK-BELNR IS INITIAL.
        PERFORM  CALL_USANCE_CLEARING_DOC  TABLES  IT_TAB
                                           USING   ZTITPNK
                                                   G_SUBRC
                                                   C_CHARP.
      ENDIF.
    ENDIF.

    IF G_SUBRC EQ 0 .    ">Success
      PERFORM P8000_SAVE_MASTER_DATA USING C_CHARP.
*> MESSAGE POPUP
*> 오류정보가 존재시 메시지 상자 POPUP.
      G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                              IM_BUSINESS_OBJ          = L_IF_NULL
                              IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

      IF G_LINE GT 0.
        CALL METHOD G_MESSAGE_HANDLER->SHOW(
            IM_POPUP  = C_TRUE
            IM_AMODAL = C_FALSE ).
      ENDIF.

      PERFORM P9000_CAME_TO_AN_END.
      PERFORM P9000_PROGRAM_EXIT.   ">Program Exit.
    ELSE.
*> MESSAGE POPUP
*> 오류정보가 존재시 메시지 상자 POPUP.
      G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                              IM_BUSINESS_OBJ          = L_IF_NULL
                              IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

      IF G_LINE GT 0.
        CALL METHOD G_MESSAGE_HANDLER->SHOW(
            IM_POPUP  = C_TRUE
            IM_AMODAL = C_FALSE ).
      ENDIF.

    ENDIF.
  ELSE.
    MESSAGE S900.   EXIT.
  ENDIF.

ENDFORM.                    " call_loan_master_create
*&---------------------------------------------------------------------*
*&      Form  call_loan_master_cancel
*&---------------------------------------------------------------------*
*       반제취소 처리 및 Loan Master 취소 생성.
*----------------------------------------------------------------------*
FORM CALL_LOAN_MASTER_CANCEL .

  DATA: L_IF_NULL    TYPE REF TO IF_MESSAGE_OBJ_MM.

* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

  CLEAR: OK-CODE.

*> 취소할 전기이력 SELECT.
  SELECT SINGLE *
    FROM ZTITPNH
   WHERE PNTNO  EQ   ZTITPNK-PNTNO
     AND IVSEQ  EQ ( SELECT MAX( IVSEQ )
                       FROM ZTITPNH
                      WHERE PNTNO  EQ  ZTITPNK-PNTNO ).

  MOVE: ZTITPNK-BELNR        TO ZTISSCRCOM-BELNR,
        ZTITPNK-GJAHR        TO ZTISSCRCOM-GJAHR,
        ZTITPNK-BUKRS        TO ZTISSCRCOM-BUKRS,
        ZTITPNH-BLART        TO ZTISSCRCOM-BLART.

  SPOP-TEXTLINE1 = '차입정보를 취소합니다.'.

  CALL SCREEN  6010 STARTING AT 01    01.

  REASONREVERSAL  = ZTISSCRCOM-STGRD.
  POSTINGDATE     = ZTISSCRCOM-CBUDAT.

  IF OK-CODE EQ 'ZTIOKAY'.
*>------------------------------------------------------------------
*> 2. 차입마스터 BDC Call  --> Usnace이고 이종통화가 아닌 경우
*>------------------------------------------------------------------
    IF ZTITRQK-REQTY EQ C_LC    AND
       ZTITRQK-ILCTY EQ C_CHARU AND
       ZTITRQS-PAGRT EQ '2AA'.
      IF NOT ZTITPNK-XRANL IS INITIAL.
        PERFORM  CALL_LOAN_MASTER_MODIFY   TABLES  IT_TAB
                                           USING   ZTITPNK
                                                   G_SUBRC
                                                   C_CHARR.
        IF G_SUBRC NE 0.
*> MESSAGE POPUP
*> 오류정보가 존재시 메시지 상자 POPUP.
          G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                                  IM_BUSINESS_OBJ          = L_IF_NULL
                                  IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

          IF G_LINE GT 0.
            CALL METHOD G_MESSAGE_HANDLER->SHOW(
                IM_POPUP  = C_TRUE
                IM_AMODAL = C_FALSE ).
          ENDIF.
          ROLLBACK WORK.   EXIT.
        ENDIF.
      ENDIF.
*> A/P 반제처리.
*       ZTITRQS-umtcu EQ c_false.
      IF NOT ZTITPNK-BELNR IS INITIAL.
        PERFORM  CALL_USANCE_CLEARING_DOC  TABLES  IT_TAB
                                           USING   ZTITPNK
                                                   G_SUBRC
                                                   C_CHARR.

*        PERFORM  call_account_cancel_func USING ZTIsscrcom-bukrs
*                                                ZTIsscrcom-gjahr
*                                                ZTIsscrcom-belnr
*                                                ZTIsscrcom-blart
*                                                g_subrc.
      ENDIF.
    ENDIF.
    IF G_SUBRC EQ 0.
      ZTITPNH-STGRD  = REASONREVERSAL.
      ZTITPNH-CBUDAT = POSTINGDATE.
      ZTITPNH-CBELNR = INVOICEDOCNUMBER_REVERSAL.
      ZTITPNH-CGJAHR = FISCALYEAR_REVERSAL.
    ENDIF.

*    IF g_subrc EQ 0 .    ">Success
    PERFORM P8000_SAVE_MASTER_DATA USING C_CHARR.
*> MESSAGE POPUP
*> 오류정보가 존재시 메시지 상자 POPUP.
    G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                            IM_BUSINESS_OBJ          = L_IF_NULL
                            IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

    IF G_LINE GT 0.
      CALL METHOD G_MESSAGE_HANDLER->SHOW(
          IM_POPUP  = C_TRUE
          IM_AMODAL = C_FALSE ).
    ELSE.
      PERFORM P9000_CAME_TO_AN_END.
      PERFORM P9000_PROGRAM_EXIT.   ">Program Exit.
    ENDIF.
*    ENDIF.
  ELSE.
    MESSAGE S900.   EXIT.
  ENDIF.

ENDFORM.                    " call_loan_master_cancel
*&---------------------------------------------------------------------*
*&      Form  call_account_cancel_func
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_ACCOUNT_CANCEL_FUNC  USING  P_BUKRS
                                      P_GJAHR
                                      P_BELNR
                                      P_BLART
                                      P_SUBRC.

  TABLES : T003, T020.

  DATA: ARCHBSEG LIKE  BSEG OCCURS 0 WITH HEADER LINE.
  DATA: TACCDN   TYPE TABLE OF ACCDN WITH HEADER LINE.

  DATA: REV     LIKE BAPIACREV,
        REV_KEY LIKE BAPIACHE01-OBJ_KEY,
        REF_KEY LIKE BAPIACHE01-OBJ_KEY.

  DATA : L_NRRANGENR LIKE INRI-NRRANGENR,
         L_OBJECT    LIKE INRI-OBJECT,
         L_RET_CD    LIKE INRI-RETURNCODE,
         L_RET_CODE  LIKE SY-SUBRC,
         L_SUBRC     LIKE SY-SUBRC.

  CLEAR : INVOICEDOCNUMBER_REVERSAL,
          FISCALYEAR_REVERSAL,
          RETURN,
          P_SUBRC.

  IF P_BELNR IS INITIAL.
    EXIT.
  ENDIF.

  SELECT SINGLE *
    FROM T020
   WHERE TCODE EQ 'FB03'.

  CALL FUNCTION 'READ_DOCUMENT_HEADER'
    EXPORTING
      BELNR          = P_BELNR
      BUKRS          = P_BUKRS
      GJAHR          = P_GJAHR
      XBSTV          = 'X'
      XBSTD          = 'X'
      XBSTM          = 'X'
    IMPORTING
      E_BKPF         = BKPF
      E_ARCHIVED     = T020-DYNCL
    TABLES
      T_ACCDN        = TACCDN
    EXCEPTIONS
      EXIT           = 4
      NOT_FOUND      = 8
      ARCHIVE_CANCEL = 12
      OTHERS         = 16.

*------- Beleg gefunden, nicht gefunden, archiviert? ------------------*
  CASE SY-SUBRC.
    WHEN 0.
      SET PARAMETER ID 'GJR' FIELD BKPF-GJAHR.
    WHEN 4.
      MESSAGE E429(F5) WITH P_BELNR P_BUKRS.
    WHEN 8.
      MESSAGE E429(F5) WITH P_BUKRS P_BELNR.
    WHEN 12.
      MESSAGE E881(F5) WITH P_BELNR P_BUKRS.
    WHEN OTHERS.
      MESSAGE A370(F5) WITH 'READ_DOCUMENT_HEADER'.
  ENDCASE.

*> 역분개 전표가 있을 경우.
  IF NOT BKPF-STBLG IS INITIAL.
    INVOICEDOCNUMBER_REVERSAL = BKPF-STBLG.
    FISCALYEAR_REVERSAL       = BKPF-STJAH.
    EXIT.
  ENDIF.

  CLEAR: SESSION.
  CTU_PARAMS-DISMODE  = 'A'. ">처리모드
  CTU_PARAMS-UPDMODE  = 'S'. ">갱신모드
  CTU_PARAMS-CATTMODE = ' '. ">CATT 모드...
  CTU_PARAMS-DEFSIZE  = ' '. ">기본화면 크기
  CTU_PARAMS-RACOMMIT = 'X'.
  CTU_PARAMS-NOBINPT  = ' ' .
  CTU_PARAMS-NOBIEND  = ' '.

* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.


  PERFORM BDC_DYNPRO_BUILD  USING :
      'X' 'SAPMF05A'    '0105',
      ' ' 'RF05A-BELNS' P_BELNR,         ">전표번호..
      ' ' 'BKPF-BUKRS'  P_BUKRS,         " Company Code
      ' ' 'RF05A-GJAHS' P_GJAHR,         " ????.
      ' ' 'UF05A-STGRD' REASONREVERSAL,  " ?????.
      ' ' 'BSIS-BUDAT'  POSTINGDATE,     " ?????.
      ' ' 'BSIS-MONAT'  SPACE,           " ????.
      ' ' 'RF05A-VOIDR' SPACE,           " ????????.
      ' ' 'BDC_OKCODE'  '=BU'.           " ??.

  SET PARAMETER ID 'BLN' FIELD ''.        " ????.
  SET PARAMETER ID 'GJR' FIELD ''.        " ????.

  PERFORM BDC_TRANSACTION USING 'FB08' L_SUBRC.

  IF L_SUBRC  EQ  C_ZERO.
    GET PARAMETER ID 'BLN' FIELD INVOICEDOCNUMBER_REVERSAL.
    GET PARAMETER ID 'GJR' FIELD FISCALYEAR_REVERSAL.

    IF INVOICEDOCNUMBER_REVERSAL IS INITIAL OR
       FISCALYEAR_REVERSAL       IS INITIAL.
      IF SY-CALLD EQ C_TRUE.
        MESSAGE E926.
      ENDIF.
      MESSAGE S926.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
      L_SUBRC = 4.
      EXIT.
    ENDIF.
  ELSE.
    LOOP AT MESSTAB WHERE MSGTYP EQ 'E'.
      IF SY-CALLD EQ C_TRUE.
        MESSAGE ID     MESSTAB-MSGID
                TYPE   MESSTAB-MSGTYP
                NUMBER MESSTAB-MSGNR
                WITH   MESSTAB-MSGV1  MESSTAB-MSGV2
                       MESSTAB-MSGV3  MESSTAB-MSGV4.
      ELSE.
        SY-MSGNO = MESSTAB-MSGNR.
        ZTI_MESSAGE MESSTAB-MSGTYP MESSTAB-MSGID SY-MSGNO
            MESSTAB-MSGV1 MESSTAB-MSGV2 MESSTAB-MSGV3 MESSTAB-MSGV4.
      ENDIF.
    ENDLOOP.

    IF SY-SUBRC NE 0.
      DESCRIBE TABLE MESSTAB LINES G_LINE.
      IF G_LINE EQ 0.
        MESSAGE S926.
        PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
      ELSE.
        READ TABLE MESSTAB INDEX G_LINE.
        IF SY-SUBRC EQ 0.
          SY-MSGNO = MESSTAB-MSGNR.
          ZTI_MESSAGE C_ERROR MESSTAB-MSGID SY-MSGNO
              MESSTAB-MSGV1 MESSTAB-MSGV2 MESSTAB-MSGV3 MESSTAB-MSGV4.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  P_SUBRC = L_SUBRC.

ENDFORM.                    " call_account_cancel_func
*&---------------------------------------------------------------------*
*&      Form  scr2123_fieldcat_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SCR2123_FIELDCAT_BUILD .

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME = 'ZTISPNHS'
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
      WHEN 'PNTNO' OR 'FLAG' OR 'BUKRS' OR 'VORGANG' OR 'SHKZG'.
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

  READ TABLE IT_ZTISPNHS INDEX P_ROW.

  CHECK SY-SUBRC = 0.

  CASE P_COLUMN.
    WHEN 'CBELNR' OR 'CGJAHR' OR 'CBUDAT'.
      IF NOT IT_ZTISPNHS-CBELNR IS INITIAL.
        PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTISPNHS-CBELNR
                                            IT_ZTISPNHS-CGJAHR
                                            IT_ZTISPNHS-BUKRS.
      ENDIF.
    WHEN OTHERS.
      IF NOT IT_ZTISPNHS-BELNR IS INITIAL.
        PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTISPNHS-BELNR
                                            IT_ZTISPNHS-GJAHR
                                            IT_ZTISPNHS-BUKRS.
      ENDIF.
  ENDCASE.

ENDFORM.                    "handle_double_click
*&---------------------------------------------------------------------*
*&      Form  handle_hotspot_click
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK  USING E_ROW_ID    TYPE LVC_S_ROW
                                 E_COLUMN_ID TYPE LVC_S_COL.

  READ TABLE IT_ZTISPNHS INDEX E_ROW_ID-INDEX.

  CHECK SY-SUBRC = 0.

  CASE E_COLUMN_ID-FIELDNAME.
    WHEN 'CBELNR' OR 'CGJAHR' OR 'CBUDAT'.
      IF NOT IT_ZTISPNHS-CBELNR IS INITIAL.
        PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTISPNHS-CBELNR
                                            IT_ZTISPNHS-CGJAHR
                                            IT_ZTISPNHS-BUKRS.
      ENDIF.
    WHEN OTHERS.
      IF NOT IT_ZTISPNHS-BELNR IS INITIAL.
        PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTISPNHS-BELNR
                                            IT_ZTISPNHS-GJAHR
                                            IT_ZTISPNHS-BUKRS.
      ENDIF.
  ENDCASE.

ENDFORM.                    " handle_hotspot_click
*&---------------------------------------------------------------------*
*&      Form  set_request_by_local_lc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_REQUEST_BY_LOCAL_LC .

  IF SY-CALLD EQ C_TRUE AND
     G_TCODE1 EQ C_DUE_LIST_LO.
*  >가용한 Invoice 품목 검증.
    PERFORM GET_AVAILABLE_RQ_ITEM TABLES IT_ZTISRQIT
                                  USING  C_SUCCESS
                                         C_FALSE.

    LOOP AT IT_ZTISRQIT.
      CLEAR: G_MODIFY, ZTIVRQ00.
      DESCRIBE TABLE IT_TAB LINES G_COUNT_1.
*  > Get Invoice Items data
      PERFORM  GET_AND_CHECK_RQ_DATA   USING  IT_ZTISRQIT-REQNO
                                              IT_ZTISRQIT-REQIT
                                              G_MODIFY
                                              ZTIVRQ00
                                              G_COUNT_1.
      IF G_MODIFY EQ C_TRUE.
        EXIT.
      ENDIF.
*  > Invoice data Move
      PERFORM SET_REQUEST_OF_IMPORT_DATA_1 TABLES IT_TAB
                                           USING  ZTIVRQ00
                                                  ZTITPNK
                                                  IT_ZTISRQIT.
    ENDLOOP.
  ELSE.

  ENDIF.

  CLEAR: G_MODIFY.

ENDFORM.                    " set_request_by_local_lc
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P1001_INITIALIZATION .

  SET TITLEBAR 'T1000'.

ENDFORM.                    " p1001_initialization
*&---------------------------------------------------------------------*
*&      Form  p1100_check_input_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P1100_CHECK_INPUT_VALUES .

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

ENDFORM.                    " p1100_check_input_values
*&---------------------------------------------------------------------*
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P2000_DATA_SELECTIONS .

  DATA: LS_HEADER  TYPE TY_HEADER.
  DATA: L_RQMNG  LIKE ZTITRQP-RQMNG,
        LV_BKPF  LIKE  BKPF,
        LV_AWKEY LIKE  BKPF-AWKEY,
        LV_AUGBL LIKE  BSEG-AUGBL.


  CLEAR: G_COUNT, IT_TAB_H, IT_HEADER, IT_LIST.
  REFRESH : IT_TAB_H, IT_HEADER, IT_LIST.
*> PROGRESS Display.
  G_LINEN    = 30.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'(P01).
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINEN.

*> I/V 데이타 select.
  SELECT *
        INTO CORRESPONDING FIELDS OF TABLE IT_TAB_H
        FROM ZTIVIV00
       WHERE IVONO  IN S_IVONO   "10송장 관리번호
         AND IVNUM  IN S_IVNUM                              "20송장번호
         AND CIVDT  IN S_CIVDT   "8문서의 송장일
         AND VORGANG  IN S_VORGA "1트랜잭션/이벤트
         AND BUKRS  IN S_BUKRS                              "4회사코드
         AND EKORG  IN S_EKORG                              "4구매조직
         AND EKGRP  IN S_EKGRP                              "3구매그룹
         AND BLART  IN S_BLART                              "2전표유형
         AND BUPLA  IN S_BUPLA                              "4사업장
         AND GSBER  IN S_GSBER                              "4사업영역
         AND BUDAT  IN S_BUDAT   "8전표의 전기일
         AND BLDAT  IN S_BLDAT   "8전표에서 송장일
         AND ZTERM  IN S_ZTERM   "4지급조건키
         AND ZFBDT  IN S_ZFBDT   "8만기계산기준일
         AND NETDT  IN S_NETDT   "8순액지급 만기일
         AND ZBD1T  IN S_ZBD1T   "3현금할인기간 1
         AND ZBD2T  IN S_ZBD2T   "3현금 할인기간 2
         AND ZBD3T  IN S_ZBD3T   "3순액지급조건기간
         AND ZBD1P  IN S_ZBD1P   "5현금할인율 1
         AND ZBD2P  IN S_ZBD2P   "5두번째 현금할인율
         AND MWSKZ  IN S_MWSKZ   "2부가가치세코드
         AND WAERS  IN S_WAERS                              "5통화키
         AND WWERT  IN S_WWERT                              "8환산일
         AND LIVST  EQ 'P'
         AND PRPYN  IN S_PRPYN   "1선급금 구분
         AND PRPYN  EQ 'I'
         AND XBLNR  IN S_XBLNR   "16참조전표번호
         AND BKTXT  IN S_BKTXT   "25전표헤더텍스트
         AND ZLSPR  IN S_ZLSPR   "1지급보류키
         AND ZLSCH  IN S_ZLSCH                              "1지급방법
         AND UZAWE  IN S_UZAWE   "2지급방법보충
         AND BELNR  IN S_BELNR   "10송장문서의 문서번호
         AND GJAHR  IN S_GJAHR                              "4회계연도
         AND RBLGP  IN S_RBLGP                              "5 품목
         AND EBELN  IN S_EBELN                              "10구매전표
         AND EBELP  IN S_EBELP   "5구매문서 품목
         AND REQNO  IN S_REQNO   "10수입의뢰번호
         AND REQIT  IN S_REQIT   "5수입의뢰 품목
         AND IBLNO  IN S_IBLNO   "10B/L 관리번호
         AND IBLIT  IN S_IBLIT   "5B/L 품목번호
         AND TBTKZ  IN S_TBTKZ   "1후속 차변/대변
         AND KSCHL  IN S_KSCHL                              "4조건유형
         AND STUNR  IN S_STUNR                              "3단계번호
         AND ZAEHK  IN S_ZAEHK   "2조건카운터
         AND SGTXT  IN S_SGTXT   "50항목텍스트
         AND CNAM   IN S_CNAM                               "12작성인
         AND CDAT   IN S_CDAT                               "8생성일
         AND CTME   IN S_CTME                               "6생성시간
         AND UNAM   IN S_UNAM    "12최종변경인
         AND UDAT   IN S_UDAT                               "8변경일
         AND UTME   IN S_UTME.   "6최종변경시간

  IF SY-SUBRC NE 0.
    MESSAGE S902.
  ENDIF.

  CLEAR: G_TABIX, G_COUNT, G_CNT.
  LOOP AT IT_TAB_H.

    G_TABIX = SY-TABIX.

* 이미 지급처리된건 제외
    CLEAR: LV_AWKEY,LV_AUGBL,LV_BKPF.
    CONCATENATE IT_TAB_H-BELNR IT_TAB_H-GJAHR INTO LV_AWKEY.

    SELECT SINGLE * FROM BKPF INTO LV_BKPF
           WHERE BUKRS IN S_BUKRS
            AND  AWTYP = 'RMRP'
            AND  AWKEY = LV_AWKEY.

    SELECT SINGLE AUGBL INTO LV_AUGBL
           FROM BSEG
           WHERE BUKRS  = LV_BKPF-BUKRS
            AND  BELNR  = LV_BKPF-BELNR
            AND  GJAHR  = LV_BKPF-GJAHR
            AND  KOART  = 'K'
            AND  AUGBL  <> SPACE.

    IF SY-SUBRC = 0.
      DELETE IT_TAB_H INDEX G_TABIX.
      CONTINUE.
    ENDIF.

    SELECT SINGLE REQTY ILCTY DOCST OPNNO
      INTO (IT_TAB_H-REQTY, IT_TAB_H-ILCTY,
            IT_TAB_H-DOCST, IT_TAB_H-OPNNO)
      FROM ZTIVRQ04
     WHERE REQNO EQ IT_TAB_H-REQNO AND
           OPNNO IN S_OPNNO.

    IF NOT   IT_TAB_H-REQTY EQ 'LC' AND SY-SUBRC <> 0.
      DELETE IT_TAB_H INDEX G_TABIX.
      CONTINUE.
    ENDIF.

    PERFORM GET_DOMAIN_VALUE_TEXT(ZTIR0000) USING :
                           'ZTIREQTY' IT_TAB_H-REQTY  IT_TAB_H-REQTYX,
                           'ZTIILCTY' IT_TAB_H-ILCTY  IT_TAB_H-ILCTYX.

    IF IT_TAB_H-DOCST NE 'O'.
      DELETE IT_TAB_H INDEX G_TABIX.
      CONTINUE.
    ENDIF.


    SELECT SINGLE MATNR TXZ01
      INTO (IT_TAB_H-MATNR, IT_TAB_H-TXZ01)
      FROM EKPO
     WHERE EBELN EQ IT_TAB_H-EBELN
       AND EBELP EQ IT_TAB_H-EBELP.

    SELECT SINGLE BLNUM
      INTO IT_TAB_H-BLNUM
      FROM ZTITBLK
     WHERE IBLNO EQ IT_TAB_H-IBLNO.

*   notice 누적수량.
    SELECT  SUM( PNMNG ) INTO IT_TAB_H-IVMNGS FROM ZTITPNP
     WHERE  IVONO  = IT_TAB_H-IVONO
       AND  RBLGP  = IT_TAB_H-RBLGP.

*   notice 가능수량.
    IT_TAB_H-IVMNGL =  IT_TAB_H-REMNG - IT_TAB_H-IVMNGS.

    IF IT_TAB_H-IVMNGL LE 0.
      DELETE IT_TAB_H INDEX G_TABIX.
      CONTINUE.
    ENDIF.

    SELECT SINGLE NAME1
      INTO IT_TAB_H-NAME1
      FROM LFA1
     WHERE LIFNR EQ IT_TAB_H-LIFNR.

    MOVE IT_TAB_H-REFWR TO IT_TAB_H-TREFWR.

    ADD 1 TO G_COUNT.

    MODIFY IT_TAB_H INDEX G_TABIX.

  ENDLOOP.

  LOOP AT IT_TAB_H.
    MOVE-CORRESPONDING IT_TAB_H TO : IT_HEADER, IT_LIST.
*    READ TABLE it_header INTO ls_header
*                         WITH KEY ivono = it_header-ivono.
*    IF sy-subrc NE 0.
*      APPEND it_header.
*    ENDIF.
    IF SY-TABIX > 1.
      MOVE 0 TO IT_HEADER-ZBD1T.
    ENDIF.

    COLLECT : IT_HEADER.
    APPEND    IT_LIST.
  ENDLOOP.

ENDFORM.                    " p2000_data_selections
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
"BOX.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'FIELDNAME'     'BOX',
          'E' 'KEY'           ' ',
"B/L 관리번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITIVK',
          ' ' 'FIELDNAME'     'IVONO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"B/L번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'BLNUM',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '25',
"문서상태
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     'L/C 종류',
          ' ' 'FIELDNAME'     'ILCTYX',
          'E' 'OUTPUTLEN'     '10',
"공급업체코드
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'FIELDNAME'     'LIFNR',
          ' ' 'OUTPUTLEN'     20,
          'E' 'HOTSPOT'       'X',

"공급업체명
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'LFA1',
          ' ' 'OUTPUTLEN'     50,
          'E' 'FIELDNAME'     'NAME1',

"송장일.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITIVK',
          ' ' 'FIELDNAME'     'CIVDT',
          'E' 'OUTPUTLEN'     '10',
"ilctyx
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITIVK',
*          ' ' 'seltext_m'     '',
          ' ' 'FIELDNAME'     'BUDAT',
          'E' 'OUTPUTLEN'     '10',
"회사코드
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'BUKRS',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '4',
"송장금액통화
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'seltext_m'     'Cur',
          ' ' 'REF_TABNAME'   'ZTITIVK',
          ' ' 'FIELDNAME'     'WAERS',
          'E' 'OUTPUTLEN'     '3',
"송장금액.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'seltext_m'     '송장값 (외화)',
          ' ' 'FIELDNAME'     'TREFWR',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'CTABNAME'      'IT_HEADER',
          'E' 'OUTPUTLEN'     '16',

*>>>>>>>>>LIST
"B/L 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVP',
          ' ' 'FIELDNAME'     'RBLGP',
          ' ' 'HOTSPOT'       'X',
          ' ' 'JUST'          C_CHARL," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
          ' ' 'INTLEN'         10,
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"구매전표번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVP',
          ' ' 'FIELDNAME'     'EBELN',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '12',
"구매문서 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVP',
          ' ' 'FIELDNAME'     'EBELP',
          ' ' 'JUST'          C_CHARL," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '5',
"수입의뢰번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVP',
          ' ' 'FIELDNAME'     'REQNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '12',
"수입의뢰 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVP',
          ' ' 'JUST'          C_CHARL," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
          ' ' 'FIELDNAME'     'REQIT',
          'E' 'OUTPUTLEN'     '10',

"L/C 번호
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTIVRQ04',
          ' ' 'JUST'          C_CHARL," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
          ' ' 'FIELDNAME'     'OPNNO',
          'E' 'OUTPUTLEN'     '20',

"자재번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'FIELDNAME'     'MATNR',
          'E' 'OUTPUTLEN'     '20',

"자재내역.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'FIELDNAME'     'TXZ01',
          'E' 'OUTPUTLEN'     '50',

"I/V수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISIVIT',
*          ' ' 'seltext_m'     'I/V수량',
          ' ' 'FIELDNAME'     'REMNG',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '15',
"NOTICE가능수량
          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTISIVIT',
          ' ' 'seltext_m'     'Notice 가능수량',
          ' ' 'FIELDNAME'     'IVMNGL',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        ' ',
          'E' 'KEY'           ' ',
"IV누적수량
          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTISIVIT',
          ' ' 'seltext_m'     'NOTICE 누적 수량',
          ' ' 'FIELDNAME'     'IVMNGS',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        'X',
          'E' 'KEY'           ' ',
"B/L수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISIVIT',
*          ' ' 'seltext_m'     '수입의뢰수량',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'MRNGE',
          'E' 'KEY'           ' ',
"기본단위
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVP',
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
          'E' 'OUTPUTLEN'     '21',
"자재문서번호
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVP',
          ' ' 'FIELDNAME'     'MBLNR',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',
"자재문서연도
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVP',
          ' ' 'FIELDNAME'     'MJAHR',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',
"자재문서품목
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVP',
          ' ' 'FIELDNAME'     'ZEILE',
          ' ' 'NO_OUT'        'X',
*          'E' 'OUTPUTLEN'     '10'.
"작성인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVP',
          ' ' 'FIELDNAME'     'CNAM',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',
"최종변경인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVP',
          ' ' 'FIELDNAME'     'UNAM',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10'.

ENDFORM.                    " 3000_field_category_build
*&---------------------------------------------------------------------*
*&      Form  3100_set_color_infomation
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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

ENDFORM.                    " 3100_set_color_infomation
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
  GS_LISTHEADER-INFO = 'Notice Due List'(T13).
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

ENDFORM.                    " 3400_COMMENT_BUILD
*&---------------------------------------------------------------------*
*&      Form  3500_SORT_TABLE_BUILD
*&---------------------------------------------------------------------*
FORM 3500_SORT_TABLE_BUILD .

  DATA: LS_SORT TYPE SLIS_SORTINFO_ALV.

  CLEAR LS_SORT.
  LS_SORT-SPOS      = 1.
  LS_SORT-FIELDNAME = 'IVONO'.
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
        'IT_HEADER'  TO GS_LAYOUT-BOX_TABNAME.

*  MOVE: '3'          TO gs_layout-no_vline. " 분리자 라인.
*  clear ls_variant.
*  ls_variant = p_vari.


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

  DATA: LS_HEADER TYPE TY_HEADER,
        LS_LIST   TYPE TY_LIST.

  CLEAR: LS_HEADER, LS_LIST.

  CASE R_UCOMM.
    WHEN '&REFRESH'.
*> 검색조건에 해당하는 데이타를 Select.
      PERFORM P2000_DATA_SELECTIONS.
      DESCRIBE TABLE IT_TAB LINES G_LINE.
      IF NOT G_LINE IS INITIAL.
        RS_SELFIELD-REFRESH = 'X'.
      ELSE.
*> Program 종료.
        PERFORM  P9000_PROGRAM_EXIT.
      ENDIF.
    WHEN 'ZTIT001'. " 후속기능
*> 개설 의뢰 상태에 따라 ZTIT005(접수) ZTIT006(신청) ZTIT007(개설)
      CLEAR : G_LINE, LS_HEADER.
      LOOP AT IT_HEADER WHERE BOX EQ 'X'.
        ADD 1 TO G_LINE.
        MOVE-CORRESPONDING IT_HEADER TO LS_HEADER.
      ENDLOOP.
      CASE G_LINE.
        WHEN 0.
          MESSAGE S003(OK). EXIT.
        WHEN 1.
          SET PARAMETER ID 'ZTIIVONO' FIELD LS_HEADER-IVONO.
          SET PARAMETER ID 'ZTIIVNUM' FIELD SPACE.
          SET PARAMETER ID 'ZTIIBLNO' FIELD SPACE.
          SET PARAMETER ID 'ZTIBLNUM' FIELD SPACE.
          CALL TRANSACTION 'ZTIT801' AND SKIP FIRST SCREEN .
        WHEN OTHERS.
          MESSAGE S035(0K).   EXIT.
      ENDCASE.
*> 검색조건에 해당하는 데이타를 Select.
      PERFORM P2000_DATA_SELECTIONS.
*> Header table과 List(Items) table를 만듬.
      DESCRIBE TABLE IT_TAB LINES G_LINE.
      IF NOT G_LINE IS INITIAL.
        RS_SELFIELD-REFRESH = 'X'.
      ELSE.
*> Program 종료.
        PERFORM  P9000_PROGRAM_EXIT.
      ENDIF.

    WHEN '&IC1'.

      IF RS_SELFIELD-TABNAME EQ 'IT_HEADER'.
        READ TABLE IT_HEADER INDEX RS_SELFIELD-TABINDEX.
      ELSEIF RS_SELFIELD-TABNAME EQ 'IT_LIST'.
        READ TABLE IT_LIST INDEX RS_SELFIELD-TABINDEX.
      ENDIF.
      IF SY-SUBRC NE 0.
        MESSAGE S903. EXIT.
      ENDIF.

      CLEAR: LS_LIST.
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
        WHEN 'IVONO' OR 'REQNO'.
          PERFORM  DISPLAY_CIV_DOCUMENT(ZTIR0000)
                                          USING LS_LIST-IVONO.
      ENDCASE.
    WHEN OTHERS.
  ENDCASE.

  CLEAR: R_UCOMM.

ENDFORM.                    "USER_COMMAND
*---------------------------------------------------------------------*
*       FORM PF_STATUS_SET                                            *
*---------------------------------------------------------------------*
FORM PF_STATUS_SET USING RT_EXTAB TYPE SLIS_T_EXTAB.

  SET TITLEBAR 'T1000' WITH 'Due List'(T10).

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
*&      Form  3200_key_infomation_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 3200_KEY_INFOMATION_BUILD .

  CLEAR GS_KEYINFO.

  GS_KEYINFO-HEADER01 = 'IVONO'.
  GS_KEYINFO-ITEM01   = 'IVONO'.

ENDFORM.                    " 3200_key_infomation_build
*&---------------------------------------------------------------------*
*&      Form  3300_event_exit_tab_hle_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 3300_EVENT_EXIT_TAB_HLE_BUILD .

  CLEAR: IT_EVENT_EXIT-AFTER.
  IT_EVENT_EXIT-AFTER = 'X'.
  IT_EVENT_EXIT-UCOMM = '&OL0'.

  APPEND IT_EVENT_EXIT.
  IT_EVENT_EXIT-UCOMM = '&OLX'. APPEND IT_EVENT_EXIT.
  IT_EVENT_EXIT-UCOMM = '&OAD'. APPEND IT_EVENT_EXIT.

ENDFORM.                    " 3300_event_exit_tab_hle_build

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
*&      Form  get_longtext_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LONGTEXT_DATA .

*> Partner Text
  PERFORM  P1000_GET_TEXTID_AND_TEXT USING ZTITPNK+3(10)
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

  CALL FUNCTION 'Z_TI_GET_REQ_OF_IMPORT_QUERY'
    IMPORTING
      EX_FACTORY = G_DATABLADE.

ENDFORM.                    " build_query_factories_class

*&---------------------------------------------------------------------*
*&      Form  OTHER_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM OTHER_FUNCTIONS .

  CASE OK_CODE.
    WHEN 'ZTIPOSTL'.       ">차입정보 생성.
      PERFORM  CALL_LOAN_MASTER_CREATE.

    WHEN 'ZTIREVCL'.       ">차입정보 취소.
      PERFORM  CALL_LOAN_MASTER_CANCEL.

    WHEN 'ZTICHDOC'.    ">변경문서.
      G_OBJEKT   = 'ZTIPNCHDOC'.
      G_OBJEKTID = ZTITPNK+3(10).
      PERFORM DISPLAY_CHANGE_DOCUMENT USING G_OBJEKT
                                            G_OBJEKTID.
    WHEN 'ZTIMK03'.     ">공급업체.
      PERFORM DISPLAY_VENDOR_MASTER USING ZTITRQK-LIFNR
                                          ZTITRQK-EKORG.

    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " OTHER_FUNCTIONS

*&---------------------------------------------------------------------*
*&      Form  BEFORE_TRANSPORT_PAI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BEFORE_TRANSPORT_PAI .

*>금액 체크.
  PERFORM  CHECK_OPEN_AMOUNT.

ENDFORM.                    " BEFORE_TRANSPORT_PAI
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
*&      Form  set_request_by_retention
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_REQUEST_BY_RETENTION .

  IF SY-CALLD EQ C_TRUE AND
     G_TCODE1 EQ C_DUE_LIST_RT.
*  > B/L관리번호로 송장관리번호를 Get
    PERFORM  GET_INVOICE_BY_BL_INT_NO     USING ZTISSCRCOM-IVONO
                                                ZTISSCRCOM-IBLNO
                                                C_FALSE.

    IF NOT ZTISSCRCOM-IVONO IS INITIAL.
      CALL FUNCTION 'Z_TI_GET_INVOICE_DOCUMENT'
        EXPORTING
          IVONO     = ZTISSCRCOM-IVONO
        IMPORTING
          ZTITIVK   = ZTITIVK
        TABLES
          ZTITIVP   = IT_ZTISIVIT
        EXCEPTIONS
          NOT_FOUND = 1
          OTHERS    = 2.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      REFRESH: IT_ZTISPNIT.
      CLEAR: G_COUNT.
      LOOP AT IT_ZTISIVIT.
        CLEAR: IT_ZTISPNIT.
        ADD 1 TO G_COUNT.
        MOVE-CORRESPONDING IT_ZTISIVIT TO IT_ZTISPNIT.
        MOVE : G_COUNT TO IT_ZTISPNIT-INDEX,
               C_TRUE  TO IT_ZTISPNIT-BOX.
        APPEND IT_ZTISPNIT.
      ENDLOOP.
    ELSE.
      EXIT.
    ENDIF.

*  >가용한 Invoice 품목 검증.
    PERFORM GET_AVAILABLE_IV_ITEM TABLES IT_ZTISPNIT
                                  USING  C_SUCCESS
                                         C_FALSE.

*  >송장문서의 종류/상태를 검증.
    PERFORM CHECK_INVOICE_DOC_STATUS.

    LOOP AT IT_ZTISPNIT.
      CLEAR: G_MODIFY, ZTIVIV00.
      DESCRIBE TABLE IT_TAB LINES G_COUNT_1.
*  > Get Invoice Items data
      PERFORM  GET_AND_CHECK_IV_DATA   USING  IT_ZTISPNIT-IVONO
                                              IT_ZTISPNIT-RBLGP
                                              G_MODIFY
                                              ZTIVIV00
                                              G_COUNT_1.
      IF G_MODIFY EQ C_TRUE.
        EXIT.
      ENDIF.
*  > Invoice data Move
      PERFORM SET_REQUEST_OF_IMPORT_DATA TABLES IT_TAB
                                         USING  ZTIVIV00
                                                ZTITPNK
                                                IT_ZTISPNIT.
    ENDLOOP.

    MOVE: C_TRUE TO ZTITPNK-RPAID.
  ENDIF.

  CLEAR: G_MODIFY.

ENDFORM.                    " set_request_by_retention
*&---------------------------------------------------------------------*
*&      Form  3010_fill_field_category
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 3010_FILL_FIELD_CATEGORY USING P_SECTION P_FNAME P_VALUE.

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
*&      Form  build_modify_bdc_data_market
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUILD_MODIFY_BDC_DATA_MARKET USING P_ZTITPNK STRUCTURE ZTITPNK.

  DATA: L_FDATE(10)  TYPE  C,
        L_TDATE(10)  TYPE  C,
        L_BDATE(10)  TYPE  C,
        L_RATE10(10) TYPE  C,
        L_CHAR18(18) TYPE  C,
        LS_USR21     LIKE  USR21,
        L_VALCL      LIKE  ZTITIG38-RCOMVALCLL,
        L_ZUOND      LIKE  VTGFHA-ZUOND,
        L_HKONT      LIKE  T012K-HKONT,
        L_HKTID      LIKE  T012K-HKTID.

**> 세부화면 - 기본데이타.
**  l_days = ZTITPNK-expdt - ZTITPNK-bgndt.
*  l_days = ztitpnk-expdt - ztitpnh-zfbdt.
*
  WRITE: P_ZTITPNK-BGNDT TO L_FDATE,
         P_ZTITPNK-EXPDT TO L_TDATE.

  WRITE: P_ZTITPNK-PNTAM TO L_CHAR18 CURRENCY P_ZTITPNK-WAERS.
  PERFORM    SET_WRITE_NO_MASK     CHANGING  L_CHAR18.

*  SELECT SINGLE *
*    INTO ls_usr21
*    FROM usr21
*   WHERE bname EQ sy-uname.
*  IF sy-subrc EQ 0.
*
*  ENDIF.

  WRITE P_ZTITPNK-TSATZ TO L_RATE10.
  PERFORM    SET_WRITE_NO_MASK     CHANGING  L_RATE10.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPLTM00'          '1100',
         ' ' 'VTMHPTBWG-XZBETR'   L_CHAR18,          ">외화금액.
         ' ' 'VTMFHAZU-XBLFZ'     L_FDATE,           ">시작일자.
         ' ' 'VTMFHAZU-XELFZ'     L_TDATE,           ">만기일자.
         ' ' 'VTMFHAZU-XVTRAB'    L_FDATE,           ">시작일자,
         ' ' 'VTMHPTKOND-PKOND'   L_RATE10,          ">이자율.
         ' ' 'VTMHPTKOND-SZBMETH' ZTITIG38-SZBMETH,  ">이자계산방법.
         ' ' 'VTMFHAZU-NORDEXT'   ZTISSCRCOM-KOSTL.  ">코스트 센터.
*         ' ' 'VTMFHAZU-XVTRAB'    '',       ">만기일.
*         ' ' 'BDC_OKCODE'        '=SZBMETH'.

  IF ZTITPNK-PROCP EQ C_CHARP.      ">선취.
    PERFORM BDC_DYNPRO_BUILD USING :
         ' ' 'BDC_OKCODE'        '=CHSE_INTEREST'.

    PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPLTB12'          '0200',
         ' ' 'RTKTZ-XFAELL'       L_FDATE,          ">만기일자.
         ' ' 'BDC_OKCODE'        '=BAC1'.

    PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPLTM00'          '1100',
         ' ' 'BDC_OKCODE'        '=ADMN'.
  ELSEIF ZTITPNK-PROCP EQ C_CHARC.  ">후취.

    PERFORM BDC_DYNPRO_BUILD USING :
         ' ' 'BDC_OKCODE'        '=ADMN'.
  ENDIF.

*> 변경일 경우.
  IF NOT P_ZTITPNK-XRANL IS INITIAL.
    PERFORM BDC_DYNPRO_BUILD USING :
           'X' 'SAPLTM00'          '1100',
           ' ' 'BDC_OKCODE'        '=SAVE'.
    EXIT.
  ENDIF.

  IF P_ZTITPNK-NDAYS GE 365.
    L_VALCL = ZTITIG38-RCOMVALCLL.
  ELSE.
    L_VALCL = ZTITIG38-RCOMVALCLS.
  ENDIF.
*>
  L_ZUOND = P_ZTITPNK-OPNNO.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPLTM00'          '1100',
         ' ' 'VTGFHA-RCOMVALCL'  L_VALCL,     ">장단기구분.
         ' ' 'VTGFHA-ZUOND'      L_ZUOND,     ">지정.
         ' ' 'BDC_OKCODE'        '=PAYM'.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPLTM00'          '1100',
         ' ' 'BDC_OKCODE'        '=FTR0610_017'.

  SELECT SINGLE *
    FROM ZTSTIG3
   WHERE PARTI EQ C_CHARB
     AND EPART EQ P_ZTITPNK-NTCBK.
  IF SY-SUBRC EQ 0.
    SELECT HKTID
      INTO L_HKTID
      FROM T012K UP TO 1 ROWS
     WHERE BUKRS EQ P_ZTITPNK-BUKRS
       AND HBKID EQ ZTSTIG3-HBKID
       AND WAERS EQ P_ZTITPNK-WAERS.
    ENDSELECT.
    IF SY-SUBRC NE 0.
      MESSAGE E823 WITH ZTSTIG3-HBKID P_ZTITPNK-WAERS.
    ENDIF.
  ENDIF.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPLTM00'          '1100',
         ' ' 'VTGZVERB-SSIGN'    ZTITIG38-SSIGNP,
         ' ' 'VTGZVERB-WAERS'    P_ZTITPNK-WAERS,
         ' ' 'VTGZVERB-HBKID'    ZTSTIG3-HBKID,
         ' ' 'VTGZVERB-HKTID'    L_HKTID,
         ' ' 'BDC_OKCODE'        '/00'.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPLTM00'          '1100',
         ' ' 'BDC_OKCODE'        '=FTR0620_006'.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPLTM00'          '1100',
         ' ' 'VTGZVERB-SSIGN'    ZTITIG38-SSIGNM,
         ' ' 'VTGZVERB-WAERS'    P_ZTITPNK-WAERS,
         ' ' 'VTGZVERB-HBKID'    ZTSTIG3-HBKID,
         ' ' 'VTGZVERB-HKTID'    L_HKTID,
         ' ' 'BDC_OKCODE'        '=SAVE'.


*  IF NOT ztitig38-sdtyp IS INITIAL.
*    PERFORM bdc_dynpro_build USING :
*           ' ' 'VDARL-SDTYP'     ztitig38-sdtyp.
*  ENDIF.
*
*  IF l_days GT 365.    ">장기.
*    IF NOT ztitig38-stilt IS INITIAL.
*      PERFORM bdc_dynpro_build USING :
*             ' ' 'VDARL-STITEL'      ztitig38-stilt.
*    ENDIF.
*  ELSE.                ">단기.
*    IF NOT ztitig38-stist IS INITIAL.
*      PERFORM bdc_dynpro_build USING :
*             ' ' 'VDARL-STITEL'      ztitig38-stist.
*    ENDIF.
*  ENDIF.
*  PERFORM bdc_dynpro_build USING :
*         ' ' 'BDC_OKCODE'       '=TAB_MD_REF'.
*
**> 세부화면 - 분석데이타.
**  IF g_mode EQ c_charc.
*  IF ztitpnk-xranl IS INITIAL.
*    CLEAR l_char50.
*  ELSE.
*    WRITE: sy-datlo TO l_char50.

*    CONCATENATE l_char50 '변경 내역 확인 요망.' INTO l_char50
*                SEPARATED BY space.
*  ENDIF.
*
*  WRITE ztitpnk-lifnr TO l_xalkz.
*
*  PERFORM bdc_dynpro_build USING :
*         'X' 'SAPMF67A'          '1000',
*         ' ' 'VDARL-ZUOND'       l_char18,
*         ' ' 'VDARL-REFER'       ztitpnk-pntno,
*         ' ' 'VDARL-MERKM'       ztitpnk-blnum,
*         ' ' 'VDARL-XALKZ'       l_xalkz,
*         ' ' 'VDARL-XALLB'       l_char50,
*         ' ' 'BDC_OKCODE'        '=TAB_CONDITION'.
*
**> 세부화면 - 분석데이타.
*  WRITE: ztitpnk-pntam TO l_char18 CURRENCY ztitpnk-waers.
*  PERFORM    set_write_no_mask     CHANGING  l_char18.
*
*  WRITE: ztitpnk-tsatz TO l_char10.
*  PERFORM    set_write_no_mask     CHANGING  l_char10.
*
*  l_date =  ztitpnk-bgndt + 1.
*  IF ztitpnk-procp EQ c_charp.
**    l_date_to = ZTITPNK-bgndt.
*    l_date_to = ztitpnh-zfbdt.
*  ELSEIF ztitpnk-procp EQ c_charc.
*    l_date_to = ztitpnk-expdt.
*  ENDIF.
*
*  WRITE ztitpnh-zfbdt TO l_date10 .
*  WRITE l_date_to      TO l_date10_to.
*  WRITE ztitpnk-expdt TO l_date10_ex.
*
*  PERFORM bdc_dynpro_build USING :
*         'X' 'SAPMF67A'             '1000',
*         ' ' 'VZZKOKO-KZAHLUNG'     '100',   ">지급율.
*         ' ' 'VZZKOKO-STILGART'     '1',     ">상환유형.
*         ' ' 'VZZKOKO-SDISEIN'      '1',     ">할인결
*         ' ' 'VZZKOKO-SZBMETH'      '2',     ">계산방법.
*         ' ' 'VZZKOKO-SEFFMETH'     '1',     ">이자방법.
*         ' ' 'RMF67-SINKKOKO'       'X',
*         ' ' 'RMF67-XBZUSAGE'       l_char18, ">금액.
*         ' ' 'RMF67-XDGUEL_KK'      l_date10 ,
*         ' ' 'RMF67-XDEFSZ'         l_date10_ex,
*         ' ' 'RMF67-XDELFZ'         l_date10_ex,
**         ' ' 'RMF67-SINKKOKO'       ZTITPNK-expdt,
*         ' ' 'VZZKOPO-DGUEL_KP(01)' l_date10,
*         ' ' 'VZZKOPO-PKOND(01)'    l_char10,
*         ' ' 'VZZKOPO-DFAELL(01)'   l_date10_to,
*         ' ' 'VZZKOPO-DVALUT(01)'   l_date10_ex,
*         ' ' 'BDC_OKCODE'           '=PAYR'.
*
*  PERFORM bdc_dynpro_build USING :
*         'X' 'SAPLVD_PAYMENT_REQUEST' '1000',
*         ' ' 'VTBZVERB-SSIGN(01)'     '+',             ">.
**         ' ' 'VTBZVERB-SSIGN(02)'     '-',             ">.
*         ' ' 'VTBZVERB-WAERS(01)'     ztitpnk-waers,  ">
**         ' ' 'VTBZVERB-WAERS(02)'     ZTITPNK-waers,  ">.
**         ' ' 'VTBZVERB-HBKID(01)'     'SUB',         ">.
**         ' ' 'VTBZVERB-HBKID(02)'     '81S01',
**         ' ' 'VTBZVERB-HKTID(01)'     'T_SUB',
**         ' ' 'VTBZVERB-HKTID(02)'     'US201',
*         ' ' 'BDC_OKCODE'           '/00'.
*
*  PERFORM bdc_dynpro_build USING :
*         'X' 'SAPLVD_PAYMENT_REQUEST' '1000',
*         ' ' 'BDC_OKCODE'             '=BACK'.
*
*  PERFORM bdc_dynpro_build USING :
*         'X' 'SAPMF67A'             '1000',
*         ' ' 'BDC_OKCODE'           '=SAVE'.
*
ENDFORM.                    " build_modify_bdc_data_market
*&---------------------------------------------------------------------*
*&      Form  call_market_update_bdc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_MARKET_UPDATE_BDC  USING  P_TCODE
                                    P_SUBRC
                                    P_ZTITPNK STRUCTURE ZTITPNK.

  DATA: L_IF_NULL    TYPE REF TO IF_MESSAGE_OBJ_MM.

* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

  CLEAR: P_SUBRC.
*> Parameter id clearing
  SET PARAMETER ID 'FAN' FIELD SPACE.

  PERFORM BDC_TRANSACTION USING P_TCODE P_SUBRC.

*  BREAK-POINT.

  IF P_SUBRC EQ 0.
    GET PARAMETER ID 'FAN' FIELD P_ZTITPNK-XRANL.
    IF OK_CODE_OLD EQ 'ZTIDELETE' OR
       OK_CODE_OLD EQ 'ZTIREVCL'.
      LOOP AT MESSTAB WHERE MSGTYP EQ 'E'.
*      LOOP AT  messtab WHERE ( msgid = '69'
*                         AND   msgnr = '002' )
*                          OR ( msgid = '67'
*                         AND   msgnr = '807' ).
        SY-MSGNO = MESSTAB-MSGNR.
        ZTI_MESSAGE C_ERROR MESSTAB-MSGID SY-MSGNO
            MESSTAB-MSGV1 MESSTAB-MSGV2 MESSTAB-MSGV3 MESSTAB-MSGV4.

      ENDLOOP.
    ENDIF.
  ELSE.

    LOOP AT MESSTAB WHERE MSGTYP EQ 'E'.
      SY-MSGNO = MESSTAB-MSGNR.
      ZTI_MESSAGE MESSTAB-MSGTYP MESSTAB-MSGID SY-MSGNO
          MESSTAB-MSGV1 MESSTAB-MSGV2 MESSTAB-MSGV3 MESSTAB-MSGV4.
    ENDLOOP.
    IF SY-SUBRC NE 0.
      MESSAGE S926.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.
  ENDIF.

*> 오류정보가 존재시 메시지 상자 POPUP.
  G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                          IM_BUSINESS_OBJ          = L_IF_NULL
                          IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

  IF G_LINE GT 0.
    CALL METHOD G_MESSAGE_HANDLER->SHOW(
        IM_POPUP  = C_TRUE
        IM_AMODAL = C_FALSE ).
    P_SUBRC = 4.
  ELSE.
    P_SUBRC = 0.
  ENDIF.


ENDFORM.                    " call_market_update_bdc
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
