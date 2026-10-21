************************************************************************
* Title         :  ZTIR4000F01                                         *
*                                                                      *
* Description   : 수입 C/C 관리 Subroutine Include                     *
*                                                                      *
* Creation Date : 2004/02/16                                           *
*                                                                      *
* Author        : Seung Jun, Lee                                       *
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
                                USING  P_ZTIVBL00 STRUCTURE ZTIVBL00
                                       P_ZTITCCK STRUCTURE ZTITCCK
                                       P_ZTITCCP STRUCTURE ZTITCCP
                                       P_BL_WA    STRUCTURE IT_BL.

  MOVE-CORRESPONDING P_ZTIVBL00 TO : P_IT_TAB, P_ZTITCCK.


*>구매오더 참조일 경우.
  IF NOT P_BL_WA-EBELN IS INITIAL.
    SELECT SINGLE WERKS NAME1 LGORT MATNR TXZ01 NETWR
                  LOEKZ ELIKZ BPRME BPUMZ BPUMN
                  UMREZ UMREN NETPR PEINH UEBTO UEBTK UNTTO
      INTO (P_IT_TAB-WERKS, P_IT_TAB-NAME1, P_IT_TAB-LGORT,
            P_IT_TAB-MATNR, P_IT_TAB-TXZ01, P_IT_TAB-NETWR,
            P_IT_TAB-LOEKZ, P_IT_TAB-ELIKZ, P_IT_TAB-BPRME,
            P_IT_TAB-BPUMZ, P_IT_TAB-BPUMN, P_IT_TAB-UMREZ,
            P_IT_TAB-UMREN, P_IT_TAB-NETPR, P_IT_TAB-PEINH,
            P_IT_TAB-UEBTO, P_IT_TAB-UEBTK, P_IT_TAB-UNTTO)
      FROM  ZTIVPO00
     WHERE  EBELN  = P_BL_WA-EBELN
       AND  EBELP  = P_BL_WA-EBELP.
  ELSE.


  ENDIF.

  MOVE: P_BL_WA-BLMNG  TO P_IT_TAB-MENGE,
        P_BL_WA-CCMNGS TO P_IT_TAB-CCMNGS,
        P_BL_WA-CCMNGL TO P_IT_TAB-CCMNGL,
        P_BL_WA-CCMNGL TO P_IT_TAB-CCMNG.

  MOVE: SY-UNAME TO P_IT_TAB-CNAM,
        SY-DATLO TO P_IT_TAB-CDAT,
        SY-TIMLO TO P_IT_TAB-CTME,
        SY-UNAME TO P_IT_TAB-UNAM,
        SY-DATLO TO P_IT_TAB-UDAT,
        SY-TIMLO TO P_IT_TAB-UTME.

  APPEND P_IT_TAB.

*>아이템 번호를 생성함.
  PERFORM SET_ITEM_NUMBER_BUILD TABLES P_IT_TAB
                                USING  P_ZTITCCK.

  PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.

ENDFORM.                    " set_request_of_import_data
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
*>문서유형 체크.
*    READ TABLE it_ZTItig02 WITH KEY bsart = p_ZTIvpo00-bsart
*                                    zterm = p_ZTIvpo00-zterm
*                                    BINARY SEARCH.
*    IF sy-subrc NE 0.
*      MESSAGE s002 WITH p_ZTIvpo00-bsart p_ZTIvpo00-zterm.
*      p_modify = c_true.
*      EXIT.
*    ELSE.
*      IF it_ZTItig02-reqty  NE ZTITRQK-reqty.
*        IF p_count          GT c_zero.
*          MESSAGE s004 WITH it_ZTItig02-reqty ZTITRQK-reqty.
*          p_modify = c_true.
*          EXIT.
*        ELSE.
*          MOVE it_ZTItig02-reqty TO ZTITRQK-reqty.
*        ENDIF.
*      ENDIF.
*    ENDIF.
**>Vendor 체크.
*    IF ZTITRQK-lifnr     NE p_ZTIvpo00-lifnr AND
*       NOT ZTITRQK-lifnr IS INITIAL.
*      MESSAGE s003 WITH p_ZTIvpo00-lifnr ZTITRQK-lifnr.
*      p_modify = c_true.
*      EXIT.
*    ENDIF.
**통화키 체크.
*    IF ZTITRQS-waers    NE  p_ZTIvpo00-waers AND
*       p_count           GT  c_zero.
*      MESSAGE s006 WITH p_ZTIvpo00-waers ZTITRQS-waers.
*      p_modify = c_true.
*    ENDIF.

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

ENDFORM.                    " get_bl_data
*&---------------------------------------------------------------------*
*&      Form  p3000_set_data_of_screen
*&---------------------------------------------------------------------*
FORM P3000_SET_DATA_OF_SCREEN .

  IF SY-TCODE EQ C_CREATE OR
     SY-TCODE EQ C_CREATE_D.

* Message preparations
    PERFORM  SET_MESSAGE_PREPARATIONS.

    CLEAR: ZTITCCK,
           ZTITCCP,
           ZTITCC1,
           ZTITCC2,
           ZTITCC3,
           ZTITBLK,
           ZTITBLP,
           ZTITRQK,
           ZTITRQS,
           ZTISRQIT,
           ZTITRQP,
           IT_TAB,
           LFA1,
          *LFA1,
           W_LFA1,
           W_LFA1_BANK,
           T001,
           T024,
           T024E.

    CLEAR:  GT_CONTROL-TEXTLINES[], GT_CONTROL-TEXTTYPES[].

*    MOVE  : '수입상업송장' TO    ZTItivhd-bktxt,
*             sy-datum      TO    ZTItivhd-civdt.  ">개설희망일자.
  ELSE.
*> 변경 문서 관리를 위한 이전데이타를 Move.
    ZTITCCK-ICCNO   = *ZTITCCK-ICCNO.
  ENDIF.

ENDFORM.                    " p3000_set_data_of_screen
*&---------------------------------------------------------------------*
*&      Form  check_for_sub_document_exist
*&---------------------------------------------------------------------*
*  삭제시 후속 문서의 존재여부를 확인함..
*----------------------------------------------------------------------*
FORM CHECK_FOR_SUB_DOCUMENT_EXIST.

  DATA: L_COUNT TYPE I.

  LOOP AT IT_TAB INTO G_TC_2130_WA.
    PERFORM CHECK_CC_SUB_DOCUMENT_EXIST
                             USING   G_TC_2130_WA-ICCNO
                                     G_TC_2130_WA-ICCIT
                                     C_ERROR
                                     G_SUBRC.
  ENDLOOP.
*> 비용문서 체크.
  SELECT COUNT( * )
    INTO L_COUNT
    FROM ZTITCSP
   WHERE EXPGR  EQ  C_CHARC
     AND REFNO  EQ  ZTITCCK-ICCNO.

  IF L_COUNT GT 0.
    MESSAGE ID 'ZMTI00' TYPE C_ERROR NUMBER '109' WITH '수입제비용'.
  ENDIF.

ENDFORM.                    " check_for_sub_document_exist
*&---------------------------------------------------------------------*
*&      Form  check_for_document_field
*&---------------------------------------------------------------------*
*  필드들의 오류 값들을 체크하여 공통 nternal table에 저장함.
*----------------------------------------------------------------------*
FORM CHECK_FOR_DOCUMENT_FIELD USING P_MODE.

  DATA: L_IF_NULL TYPE REF TO IF_MESSAGE_OBJ_MM.

* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.


  IF ZTITCCK-CDUTX IS INITIAL.
    MESSAGE W925 WITH ' ' '관세'.
  ENDIF.

  IF ZTITCCK-CADTX IS INITIAL.
    MESSAGE W925 WITH ' ' '부가세'.
  ENDIF.

  IF ZTITCCK-CCHCG IS INITIAL.
    MESSAGE W925 WITH ' ' '관세사 수수료'.
  ENDIF.

*> 수리번호.
  IF ZTITCCK-CDCNO IS INITIAL.
    PERFORM SET_RETURN_MESSAGE USING 'ZTITCCK' 'CDCNO' C_ERROR.
  ENDIF.
*> 수리일자.
  IF ZTITCCK-CDRDT IS INITIAL.
    PERFORM SET_RETURN_MESSAGE USING 'ZTITCCK' 'CDRDT' C_ERROR.
  ENDIF.
*> 결제방법.
  IF ZTITCCK-CPYME IS INITIAL.
    PERFORM SET_RETURN_MESSAGE USING 'ZTITCCK' 'CPYME' C_ERROR.
  ENDIF.
*> 징수형태.
  IF ZTITCCK-CARTY IS INITIAL.
    PERFORM SET_RETURN_MESSAGE USING 'ZTITCCK' 'CARTY' C_ERROR.
  ENDIF.
*> 신고일.
  IF ZTITCCK-CDCDT IS INITIAL.
    PERFORM SET_RETURN_MESSAGE USING 'ZTITCCK' 'CDCDT' C_ERROR.
  ENDIF.
*> 신고세관.
  IF ZTITCCK-CDCOR IS INITIAL.
    PERFORM SET_RETURN_MESSAGE USING 'ZTITCCK' 'CDCOR' C_ERROR.
  ENDIF.

*> 신고자(관세사).
*--> [가온] 수입신고필증 관세사 필수 X
  IF ZTITCCK-BUKRS = '6000'.
  ELSE.
    IF ZTITCCK-STATE IS INITIAL.
      PERFORM SET_RETURN_MESSAGE USING 'ZTITCCK' 'STATE' C_ERROR.
    ENDIF.
  ENDIF.
*<-- [가온] 수입신고필증 관세사 필수 X

*> 품목데이타 검증.
  CLEAR: G_LINE.
  LOOP AT IT_TAB INTO G_TC_2130_WA.
    IF G_TC_2130_WA-STAWN IS INITIAL.
      MESSAGE S133 WITH G_TC_2130_WA-ICCIT 'H/S code'.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.
    IF G_TC_2130_WA-CCMNG IS INITIAL.
      MESSAGE S133 WITH G_TC_2130_WA-ICCIT '수량'.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.
    IF G_TC_2130_WA-CCMNG GT G_TC_2130_WA-CCMNGL.
      MESSAGE S134 WITH G_TC_2130_WA-ICCIT '수입신고수리'.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.
    IF G_TC_2130_WA-NDFTY IS INITIAL OR
       G_TC_2130_WA-NDFTY EQ C_CHARA.
      IF G_TC_2130_WA-REFWR IS INITIAL.
        MESSAGE S133 WITH G_TC_2130_WA-ICCIT '금액'.
        PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
      ENDIF.
    ENDIF.
    IF NOT G_TC_2130_WA-LOEKZ IS INITIAL.
      MESSAGE S170 WITH G_TC_2130_WA-ICCIT G_TC_2130_WA-EBELN
                                           G_TC_2130_WA-EBELP.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.
  ENDLOOP.

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
*  SET UPDATE TASK LOCAL.

*> 공통테이블 적용.
  IF G_MODE      EQ C_CHARY AND
     OK_CODE_OLD EQ 'ZTISAVE'.
    P_MODE = 'Y'.
  ENDIF.

  PERFORM P8100_SAVE_COMMON_DATA  TABLES IT_TAB
                                  USING  ZTITCCK
                                         G_SUBRC
                                         P_MODE.
  IF G_SUBRC NE C_ZERO.
    MESSAGE A912.   EXIT.
  ENDIF.

*> Long Text 저장 루틴.
  PERFORM SAVE_LONG_TEXT USING ZTITCCK+3(12)
                               C_TEXTOBJECT_HEADER
                               G_SUBRC.

  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    MESSAGE A912.   EXIT.
  ENDIF.

*> 기존 EDI Data clearing.
  PERFORM  P8111_EDI_TABLE_CLEAR USING ZTITCCK
                                       G_SUBRC.

*> EDI 란행 사항 저장로직.
  PERFORM P8110_SAVE_IMPRES  USING ZTITCCK
                                   G_SUBRC.

  IF G_SUBRC NE C_ZERO.
    MESSAGE A912.   EXIT.
  ELSE.
*> Change document setting.
    PERFORM P8120_CHANGE_DOCUMENT.
*> 반출정보 자동 생성 지시자.
    IF ZTITIG00-BOIND EQ C_TRUE.
      IF OK_CODE_OLD EQ 'ZTIDELETE'.
        DELETE FROM ZTITBOK WHERE IBLNO EQ ZTITCCK-IBLNO.
      ELSE.
        PERFORM  CREATE_BONDED_AREA_OUT.
      ENDIF.
    ENDIF.
*> Commit work.
    COMMIT WORK.
*> Set parameter ID
    IF OK_CODE_OLD EQ 'ZTIDELETE'.
      MESSAGE S111 WITH ZTITCCK-ICCNO ZTITCCK-ICCSQ.
    ELSE.
      SET PARAMETER ID 'ZTIICCNO' FIELD ZTITCCK-ICCNO.
      SET PARAMETER ID 'ZTIICCSQ' FIELD ZTITCCK-ICCSQ.
      IF NOT ZTITCCK-CDCNO IS INITIAL.
        SET PARAMETER ID 'ZTICDCNO' FIELD ZTITCCK-CDCNO.
      ENDIF.
      MESSAGE S105 WITH ZTITCCK-ICCNO ZTITCCK-ICCSQ.
    ENDIF.
  ENDIF.

ENDFORM.                    " p8000_save_master_data
*&---------------------------------------------------------------------*
*&      Form  p8100_save_common_data
*&---------------------------------------------------------------------*
FORM P8100_SAVE_COMMON_DATA  TABLES  PT_TAB     STRUCTURE G_TC_2130_WA
                             USING   P_ZTITCCK  STRUCTURE ZTITCCK
                                     P_SUBRC    LIKE      SY-SUBRC
                                     P_MODE.

  DATA: L_LCONO TYPE ZTIREQNO,
        L_ICCSQ TYPE ZTIICCSQ.

  CLEAR: P_SUBRC, L_LCONO.

  IF ( SY-TCODE EQ C_CREATE OR  SY-TCODE EQ C_CREATE_D )
       AND P_ZTITCCK-ICCNO IS INITIAL.
    IF ZTITIG00-CCRQM EQ C_CHARN.
      CALL FUNCTION 'Z_TI_GET_NUMBER_NEXT'
        EXPORTING
          ZMPTY    = 'CC'
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
      L_ICCSQ = '00'.
    ELSE.
      L_LCONO = P_ZTITCCK-ICCNO.
      L_ICCSQ = P_ZTITCCK-ICCSQ.
    ENDIF.
  ELSE.
    L_LCONO = P_ZTITCCK-ICCNO.
    L_ICCSQ = P_ZTITCCK-ICCSQ.
  ENDIF.

  IF  P_ZTITCCK-CNAM IS INITIAL.
    MOVE: SY-UNAME   TO   P_ZTITCCK-CNAM,
          SY-DATLO   TO   P_ZTITCCK-CDAT,
          SY-TIMLO   TO   P_ZTITCCK-CTME.
  ENDIF.

  MOVE: SY-MANDT   TO   P_ZTITCCK-MANDT,
        L_LCONO    TO   P_ZTITCCK-ICCNO,
        L_ICCSQ    TO   P_ZTITCCK-ICCSQ,
        C_CHARO    TO   P_ZTITCCK-DOCST,
        SY-UNAME   TO   P_ZTITCCK-UNAM,
        SY-DATLO   TO   P_ZTITCCK-UDAT,
        SY-TIMLO   TO   P_ZTITCCK-UTME.

  IF OK_CODE_OLD EQ 'ZTIDELETE'.
*> deleted Inbound delivery
*> 면장생성시 인바운드 납품생성 로직.
    IF ZTITIG00-INBMT EQ 'C0'.
      LOOP AT XZTITCCP WHERE VBELN NE SPACE.
        PERFORM  DELETE_INB_DELETED USING XZTITCCP-VBELN
                                          G_SUBRC.
        IF G_SUBRC EQ 0.
          CLEAR: XZTITCCP-VBELN.
          MODIFY XZTITCCP.
        ENDIF.
      ENDLOOP.
    ENDIF.

*> Header table delete.
    DELETE FROM ZTITCCK WHERE ICCNO EQ P_ZTITCCK-ICCNO
                          AND ICCSQ EQ P_ZTITCCK-ICCSQ.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
    ENDIF.
*> Item table delete
    DELETE FROM ZTITCCP WHERE ICCNO EQ P_ZTITCCK-ICCNO
                          AND ICCSQ EQ P_ZTITCCK-ICCSQ.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
    ENDIF.

    UPDATE ZTITCRK SET DOCST = C_CHARY
      WHERE ICCNO = P_ZTITCCK-ICCNO
        AND ICCSQ = P_ZTITCCK-ICCSQ.
    EXIT.
  ELSE.
*> Header table modify.
    MODIFY ZTITCCK FROM P_ZTITCCK.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
    ENDIF.
*> Items table modify.
    REFRESH : XZTITCCP.
    LOOP AT IT_TAB INTO G_TC_2130_WA.
      MOVE-CORRESPONDING G_TC_2130_WA TO XZTITCCP.
      XZTITCCP-MANDT = P_ZTITCCK-MANDT.
      XZTITCCP-ICCNO = P_ZTITCCK-ICCNO.
      XZTITCCP-ICCSQ = P_ZTITCCK-ICCSQ.
*      xZTITRQP-reqit = sy-tabix.
      APPEND XZTITCCP.
    ENDLOOP.

    UPDATE ZTITCRK SET DOCST = C_CHARO
      WHERE ICCNO = P_ZTITCCK-ICCNO
        AND ICCSQ = P_ZTITCCK-ICCSQ.

*> Inbound delivery create.
    IF P_ZTITCCK-DOCST EQ C_CHARO.
*> 면장생성시 인바운드 납품생성 로직.
      IF ZTITIG00-INBMT EQ 'C0'.
        PERFORM GET_INB_DELIVERY_ORDER.
        IF NOT XEKPO_SHORT[] IS INITIAL.
* get inbound delivery type from T163G
          PERFORM GET_DELIVERY_TYPE USING '2'.

*- read and analyse inbound deliveries --------------------------------*
          CLEAR COUNT.
          LOOP AT XZTITCCP WHERE EBELN NE SPACE.
            LOOP AT XEKPO_SHORT WHERE EBELN = XZTITCCP-EBELN
                                  AND EBELP = XZTITCCP-EBELP.

              CLEAR: BBP_INBD_L, IT_INB, IT_RETURN.
              REFRESH: IT_INB, IT_RETURN.
*-----> header
              IF XZTITCCP-VBELN IS INITIAL.
                PERFORM CREATE_INBOUND_DELIVERY.
              ELSE.
                PERFORM MODIFY_INBOUND_DELIVERY.
              ENDIF.
            ENDLOOP.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.

    DELETE FROM ZTITCCP WHERE ICCNO EQ P_ZTITCCK-ICCNO
                          AND ICCSQ EQ P_ZTITCCK-ICCSQ.
    MODIFY ZTITCCP FROM TABLE XZTITCCP.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
    ENDIF.

  ENDIF.

ENDFORM.                    " p8100_save_common_data
*&---------------------------------------------------------------------*
*&      Form  p8110_save_impres
*&---------------------------------------------------------------------*
FORM P8110_SAVE_IMPRES   USING  P_ZTITCCK STRUCTURE ZTITCCK
                                P_SUBRC.
  CLEAR P_SUBRC.
*> 삭제 모드일 경우.
  IF OK_CODE_OLD EQ 'ZTIDELETE'.
    EXIT.
  ELSE.

*> 란 table modify.
    LOOP AT XZTITCC1.
      MOVE: P_ZTITCCK-MANDT   TO   XZTITCC1-MANDT,
            P_ZTITCCK-ICCNO   TO   XZTITCC1-ICCNO,
            P_ZTITCCK-ICCSQ   TO   XZTITCC1-ICCSQ.
      MODIFY XZTITCC1 INDEX SY-TABIX.
    ENDLOOP.

    MODIFY ZTITCC1 FROM TABLE XZTITCC1.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
    ENDIF.

*> 란 규격table modify.
    LOOP AT XZTITCC2.
      MOVE: P_ZTITCCK-MANDT   TO   XZTITCC2-MANDT,
            P_ZTITCCK-ICCNO   TO   XZTITCC2-ICCNO,
            P_ZTITCCK-ICCSQ   TO   XZTITCC2-ICCSQ.
      MODIFY XZTITCC2 INDEX SY-TABIX.
    ENDLOOP.

    MODIFY ZTITCC2 FROM TABLE XZTITCC2.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
    ENDIF.

*> 란 table modify.
    LOOP AT XZTITCC3.
      MOVE: P_ZTITCCK-MANDT   TO   XZTITCC3-MANDT,
            P_ZTITCCK-ICCNO   TO   XZTITCC3-ICCNO,
            P_ZTITCCK-ICCSQ   TO   XZTITCC3-ICCSQ.
      MODIFY XZTITCC3 INDEX SY-TABIX.
    ENDLOOP.

    MODIFY ZTITCC3 FROM TABLE XZTITCC3.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
    ENDIF.


*-> 기능개선 XXXXX_요건(4G) 테이블 저장
    REFRESH : XZTITCC4.
    LOOP AT G_TC_2212_2_ITAB INTO G_TC_2212_2_WA.
      MOVE-CORRESPONDING G_TC_2212_2_WA TO XZTITCC4.
      XZTITCC4-MANDT = P_ZTITCCK-MANDT.
      XZTITCC4-ICCNO = P_ZTITCCK-ICCNO. "통관관리번호
      XZTITCC4-ICCSQ = P_ZTITCCK-ICCSQ. "수입신고 차수
      XZTITCC4-Z9010 = P_ZTITCCK-ICCNO. "통관관리번호-의뢰문서번호(4G)
      XZTITCC4-Z9020 = P_ZTITCCK-ICCNO. "신고번호(4G)
      APPEND XZTITCC4.
    ENDLOOP.
    IF SY-SUBRC EQ 0.
      MODIFY ZTITCC4 FROM TABLE XZTITCC4.
      IF SY-SUBRC NE 0.
        ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
      ENDIF.
    ENDIF.
*<- 기능개선 XXXXX
  ENDIF.

ENDFORM.                    " p8110_save_impres
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
      ZTITCCK              = ZTITCCK
    IMPORTING
      DOCUMENT_OUTPUT_INFO = G_DOCUMENT_OUTPUT_INFO
      JOB_OUTPUT_INFO      = G_JOB_OUTPUT_INFO
      JOB_OUTPUT_OPTIONS   = G_JOB_OUTPUT_OPTIONS
    TABLES
      ZTITCC1              = XZTITCC1
      ZTITCC2              = XZTITCC2
      ZTITCC3              = XZTITCC3
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

  IF ZTITCCK-BUKRS IS INITIAL.
    CLEAR: T001.
  ELSE.
    SELECT SINGLE * FROM T001
     WHERE BUKRS EQ ZTITCCK-BUKRS.

    IF SY-SUBRC EQ 0.
      SELECT SINGLE *
        FROM ZTSTIG0
       WHERE BUKRS EQ ZTITCCK-BUKRS.

      SELECT SINGLE *
        FROM ZTITIG00
       WHERE BUKRS EQ ZTITCCK-BUKRS.
      IF SY-SUBRC NE 0.
        MESSAGE E035 WITH ZTITCCK-BUKRS.
      ENDIF.
    ENDIF.
  ENDIF.
* 구매조직 SELECT ( T024E )
  IF ZTITCCK-EKORG IS INITIAL.
    CLEAR T024E.
  ELSE.
    CALL FUNCTION 'T024E_SINGLE_READ'
      EXPORTING
        T024E_EKORG = ZTITCCK-EKORG
      EXCEPTIONS
        NOT_FOUND   = 1
        OTHERS      = 2.

    IF SY-SUBRC NE 0.
      IF SY-CALLD NE C_TRUE.
        MESSAGE W001(MH) WITH ZTITCCK-EKORG.
      ENDIF.
    ENDIF.
  ENDIF.

* 구매그룹 SELECT ( T024 )
  IF ZTITCCK-EKGRP IS INITIAL.
    CLEAR T024.
  ELSE.
    CALL FUNCTION 'MM_ARRANG_PURCHASE_GRP_SELECT'
      EXPORTING
        PURCHASE_GROUP           = ZTITCCK-EKGRP
      IMPORTING
        E_T024                   = T024
      EXCEPTIONS
        PURCHASE_GROUP_NOT_FOUND = 1
        OTHERS                   = 2.

    IF SY-SUBRC NE 0.
      IF SY-CALLD NE C_TRUE.
        MESSAGE W030(MN) WITH ZTITCCK-EKGRP.
      ENDIF.
    ENDIF.
  ENDIF.

*> 기타 Master 조회.
  PERFORM  GET_IMPORT_VENDORS_TEXT  USING C_SUCCESS.

ENDFORM.                    " GET_OTHERS_TEXT_BY_MASTER_DATA

*&---------------------------------------------------------------------*
*&      Form  GET_BL_DOCUMENT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_BL_DOCUMENT_DATA  TABLES      P_IT_BL   STRUCTURE IT_BL
                              USING    P_IBLNO
                                       P_IBLIT
                                       P_MTYPE
                                       P_MSGTY.

  REFRESH IT_BLNUM.  CLEAR IT_BLNUM.
  IF P_IBLIT IS INITIAL.
    SELECT *
           INTO CORRESPONDING FIELDS OF TABLE P_IT_BL
           FROM ZTIVBL00
           WHERE IBLNO  EQ P_IBLNO.
  ELSE.
    SELECT *
           INTO CORRESPONDING FIELDS OF TABLE P_IT_BL
           FROM ZTIVBL00
           WHERE IBLNO  EQ P_IBLNO
           AND   IBLIT  EQ P_IBLIT.
  ENDIF.

  IF SY-SUBRC NE 0.
    IF P_IBLIT IS INITIAL.
      MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 216 WITH P_IBLNO.
    ELSE.
      MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 216 WITH P_IBLNO P_IBLIT.
    ENDIF.
  ENDIF.

  PERFORM GET_AVAILABLE_BL_ITEM TABLES P_IT_BL
                                       IT_BLNUM
                              USING    P_MSGTY
                                       C_FALSE.

ENDFORM.                    " GET_BL_DOCUMENT_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_available_bl_ITEM
*&---------------------------------------------------------------------*
FORM GET_AVAILABLE_BL_ITEM  TABLES   P_IT_BL    STRUCTURE IT_BL
                                     P_IT_BLNUM STRUCTURE IT_BLNUM
                            USING    P_MTYPE
                                     P_DELETE.

  CLEAR: G_TABIX, G_COUNT, G_CNT.
  LOOP AT P_IT_BL.

    G_TABIX = SY-TABIX.

*   p/o정보.
*    select single WERKS NAME1 LGORT LGOBE MATNR TXZ01 NETWR
*                  EEIND UMSON LOEKZ ELIKZ BPRME BPUMZ BPUMN
*                  UMREZ UMREN NETPR PEINH UEBTO UEBTK UNTTO BUPLA
*      into (it_tab-WERKS, it_tab-NAME1, it_tab-LGORT, it_tab-LGOBE,
*            it_tab-MATNR, it_tab-TXZ01, it_tab-NETWR, it_tab-EEIND,
*             it_tab-UMSON, it_tab-LOEKZ, it_tab-ELIKZ, it_tab-BPRME,
*            it_tab-BPUMZ, it_tab-BPUMN, it_tab-UMREZ, it_tab-UMREN,
*            it_tab-NETPR, it_tab-PEINH, it_tab-UEBTO, it_tab-UEBTK,
*            it_tab-UNTTO, it_tab-BUPLA)
*      FROM  ZTIvpo00
*     WHERE  ebeln  = p_it_bl-ebeln
*       AND  ebelp  = p_it_bl-ebelp.


*   bl 정보 수량.
    SELECT  SINGLE BLMNG
      INTO  P_IT_BL-MENGE
      FROM  ZTITBLP
     WHERE  IBLNO  = P_IT_BL-IBLNO
       AND  IBLIT  = P_IT_BL-IBLIT.

    P_IT_BL-BLMNG  = P_IT_BL-MENGE.

*   i/v 누적수량.
    SELECT  SUM( CCMNG )
      INTO  P_IT_BL-CCMNGS
      FROM  ZTITCCP
     WHERE  IBLNO  = P_IT_BL-IBLNO
       AND  IBLIT  = P_IT_BL-IBLIT.

*   i/v 가능수량.
    P_IT_BL-CCMNGL =  P_IT_BL-MENGE - P_IT_BL-CCMNGS.

    IF P_IT_BL-CCMNGL LE C_ZERO.
      IF P_DELETE EQ C_TRUE.
        DELETE P_IT_BL INDEX G_TABIX.
        CONTINUE.
      ELSE.
        P_IT_BL-BLMNG = 0.
      ENDIF.
    ELSE.
      ADD 1 TO G_CNT.
    ENDIF.

    ADD 1 TO G_COUNT.
    P_IT_BL-INDEX = G_COUNT.
    MODIFY P_IT_BL INDEX G_TABIX.

    MOVE P_IT_BL-IBLNO TO P_IT_BLNUM-IBLNO.
    COLLECT P_IT_BLNUM.

  ENDLOOP.

  DESCRIBE TABLE P_IT_BL LINES G_LINE.
  IF G_LINE EQ 0.
    MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 902.
    EXIT.
  ENDIF.

  IF G_CNT EQ 0.
*    MESSAGE ID 'ZMTI00' TYPE c_warning NUMBER 103.
    MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 103.
  ENDIF.

ENDFORM.                    " GET_available_bl_ITEM
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

  L_OBJECTID(12) = ZTITCCK+3(12).

  L_TCODE        = SY-TCODE.
  L_UTIME        = SY-TIMLO.
  L_UDATE        = SY-DATLO.
  L_USERNAME     = SY-UNAME.

  IF G_MODE EQ C_CHARC.  ">생성모드일 경우.
    REFRESH : YZTITCCP.
  ENDIF.

  LOOP AT XZTITCCP.
    XZTITCCP-KZ = L_UPD.
    MODIFY XZTITCCP.
  ENDLOOP.

  LOOP AT XZTITCC1.
    XZTITCCP-KZ = L_UPD.
    MODIFY XZTITCC1.
  ENDLOOP.

  LOOP AT XZTITCC2.
    XZTITCCP-KZ = L_UPD.
    MODIFY XZTITCC2.
  ENDLOOP.

  LOOP AT XZTITCC3.
    XZTITCCP-KZ = L_UPD.
    MODIFY XZTITCC3.
  ENDLOOP.

*-> 기능개선 XXXXX : CHANGE DOCUMENT
  LOOP AT XZTITCC4.
    XZTITCCP-KZ = L_UPD.
    MODIFY XZTITCC4.
  ENDLOOP.
*<- 기능개선 XXXXX

  CALL FUNCTION 'ZTICCCHDOC_WRITE_DOCUMENT'
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
*     UPD_ICDTXT_ZTICCCHDOC   = ' '
      UPD_ZTITCC1             = L_UPD
      UPD_ZTITCC2             = L_UPD
      UPD_ZTITCC3             = L_UPD
      N_ZTITCCK               = ZTITCCK
      O_ZTITCCK               = *ZTITCCK
      UPD_ZTITCCK             = L_UPD
      UPD_ZTITCCP             = L_UPD
    TABLES
      ICDTXT_ZTICCCHDOC       = LT_CDTXT
      XZTITCC1                = XZTITCC1
      YZTITCC1                = YZTITCC1
      XZTITCC2                = XZTITCC2
      YZTITCC2                = YZTITCC2
      XZTITCC3                = XZTITCC3
      YZTITCC3                = YZTITCC3
      XZTITCC4                = XZTITCC4 "기능개선 XXXXX
      YZTITCC4                = YZTITCC4 "기능개선 XXXXX
      XZTITCCP                = XZTITCCP
      YZTITCCP                = YZTITCCP.


ENDFORM.                    " p8120_change_document
*&---------------------------------------------------------------------*
*&      Form  call_print_process
*&---------------------------------------------------------------------*
FORM CALL_PRINT_PROCESS .

*> GET OUTPUT OPTIONS
  IF IT_PRTCTL[] IS INITIAL.
    REFRESH : IT_PRTCTL.
    CLEAR: IT_PRTCTL.
    IF NOT ZTITCCK-LIFNR IS INITIAL.   ">Openning bank.
      SELECT LIFNR NAME1 LAND1 SPRAS TELFX ADRNR
      INTO CORRESPONDING FIELDS OF TABLE IT_PRTCTL
      FROM LFA1
      WHERE LIFNR IN ( SELECT LIFNR
                       FROM ZTSTIG3
                       WHERE EPART EQ ZTITCCK-LIFNR ).
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
      G_SSF_NAME = 'Z_TI_IMPDEC_PRINT_OF_REQUEST'.">수입신고서.


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
*> 정가 계산.
    CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
      EXPORTING
        PEINH = G_TC_2130_WA-PEINH
        BPUMZ = G_TC_2130_WA-BPUMZ
        BPUMN = G_TC_2130_WA-BPUMN
        MENGE = G_TC_2130_WA-CCMNG
        NETPR = G_TC_2130_WA-NETPR
      CHANGING
        NETWR = G_TC_2130_WA-NETWR.

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

  IF ZTITCCK-LIFNR IS INITIAL.
    CLEAR: LFA1.
  ELSE.
    SELECT SINGLE * FROM LFA1
     WHERE LIFNR EQ ZTITCCK-LIFNR.
    IF SY-SUBRC NE 0.
      PERFORM MESSAGE_NOT_FOUND_VENDOR USING 'ZTITCCK'
                                             'LIFNR'
                                             P_MSGTY.
    ENDIF.
  ENDIF.
*> 관세사 코드.
  CLEAR: ZTSTIG3.
  IF NOT ZTITCCK-STATE IS INITIAL.
    PERFORM  GET_EDI_PARTNER USING  ZTITCCK-STATE
                                    'H'
                                    ZTSTIG3
                                    C_WARNING.
  ENDIF.
*> 세관 코드.
  CLEAR: ZTSVIG5.
  IF NOT ZTITCCK-CDCOR IS INITIAL.
    PERFORM  GET_CUSTOM_PARTNER USING  ZTITCCK-CDCOR
                                       ZTSVIG5
                                       C_WARNING.
  ENDIF.

ENDFORM.                    " get_Import_vendors_text
*&---------------------------------------------------------------------*
*&      Form  check_cc_sub_document_exist
*&---------------------------------------------------------------------*
*       하위문서 존재여부 체크.
*----------------------------------------------------------------------*
FORM CHECK_CC_SUB_DOCUMENT_EXIST  USING    P_ICCNO
                                           P_ICCIT
                                           P_MSGTY
                                           P_SUBRC.
  DATA: L_COUNT TYPE I.

  CLEAR: P_SUBRC.

  CHECK NOT P_ICCNO IS INITIAL.

*> 반출문서 문서 체크.
  SELECT COUNT( * ) INTO L_COUNT
    FROM ZTITBDP
   WHERE ICCNO   EQ  P_ICCNO
     AND ICCIT   EQ  P_ICCIT.
  IF L_COUNT GT C_ZERO.
    IF P_MSGTY NE C_NONE.
      MESSAGE ID 'ZMTI00' TYPE P_MSGTY
              NUMBER '109' WITH '보세구역 반출'.
    ENDIF.
    P_SUBRC = 4.
    EXIT.
  ENDIF.

*> G/R 문서 체크.
  SELECT COUNT( * ) INTO L_COUNT
    FROM ZTITGRP
   WHERE ICCNO   EQ  P_ICCNO
     AND ICCIT   EQ  P_ICCIT.
  IF L_COUNT GT C_ZERO.
    IF P_MSGTY NE C_NONE.
      MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER '109' WITH 'G/R'.
    ENDIF.
    P_SUBRC = 4.
    EXIT.
  ENDIF.

ENDFORM.                    " check_cc_sub_document_exist
*&---------------------------------------------------------------------*
*&      Form  SET_INITIAL_VALUE
*&---------------------------------------------------------------------*
FORM SET_INITIAL_VALUE .

*> 문서 종류.
  G_DOCUMENT = C_CC.

*  REFRESH: it_tab, it_msg, it_po, it_ZTItig02, it_ponum,
*           xZTItlc02, yZTItlc02,
*           xZTItlc03, yZTItlc03,
*           xZTItpc02, yZTItpc02,
*           xZTItpc03, yZTItpc03,
*           xZTITRQP, yZTITRQP,
*           xZTIttt02, yZTIttt02.
*
*  CLEAR:   it_tab, it_msg, it_po, it_ZTItig02, it_ponum,
*           xZTItlc02, yZTItlc02,
*           xZTItlc03, yZTItlc03,
*           xZTItpc02, yZTItpc02,
*           xZTItpc03, yZTItpc03,
*           xZTITRQP, yZTITRQP,
*           xZTIttt02, yZTIttt02,
*           ZTITRQK,    ">수입의뢰 Header
*          *ZTITRQK,    ">수입의뢰 Header
*           ZTITRQS,    ">수입의뢰 Status
*          *ZTITRQS,    ">수입의뢰 Status
*           ZTITRQP,    ">수입의뢰 Items
*           ZTItlo01,    ">LOCAL  L/C MAIN (LOCAPP/LOCAMR)
*          *ZTItlo01,    ">LOCAL  L/C MAIN (LOCAPP/LOCAMR)
*           ZTItpc01,    ">구매확인서 MAIN (APPPCR/PCRLIC)
*          *ZTItpc01,    ">구매확인서 MAIN (APPPCR/PCRLIC)
*           ZTItpc02,    ">구매확인서 ITEM (근거서류)
*          *ZTItpc02,    ">구매확인서 ITEM (근거서류)
*           ZTItpc03,    ">구매확인서 ITEM (물품내역)
*          *ZTItpc03,    ">구매확인서 ITEM (물품내역)
*           ZTItlc01,    ">MASTER L/C MAIN (APP700/APP707)
*          *ZTItlc01,    ">MASTER L/C MAIN (APP700/APP707)
*           ZTItlc02,    ">MASTER L/C ITEM (Long text)
*          *ZTItlc02,    ">MASTER L/C ITEM (Long text)
*           ZTIttt01,    ">지급지시서 T/T MAIN (PAYORD)
*          *ZTIttt01,    ">지급지시서 T/T MAIN (PAYORD)
*           ZTIttt02,    ">지급지시서 T/T ITEM (입금관련서류)
*          *ZTIttt02,    ">지급지시서 T/T ITEM (입금관련서류)
*           lfa1,
*          *lfa1,
*           w_lfa1,
*           w_lfa1_bank,
*           it_msg.

  CLEAR: G_CCNUM_CHK1, G_CCNUM_CHK2.

ENDFORM.                    " SET_INITIAL_VALUE
*&---------------------------------------------------------------------*
*&      Form  double_click_event
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK_EVENT .

  DATA: L_AMDSQ   TYPE ZTIAMDSQ.

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
        WHEN 'ZTISCCIT-EBELN' OR 'ZTISCCIT-EBELP'.
          PERFORM DISPLAY_PURCHASE_ORDER USING G_TC_2130_WA-EBELN
                                               G_TC_2130_WA-EBELP.
        WHEN 'ZTISCCIT-IBLNO' OR 'ZTISCCIT-IBLIT'.
          PERFORM DISPLAY_BL_DOCUMENT    USING G_TC_2130_WA-IBLNO
                                               G_TC_2130_WA-IBLIT.
        WHEN 'ZTISCCIT-REQNO' OR 'ZTISCCIT-REQIT'.
          CHECK NOT G_TC_2130_WA-REQNO IS INITIAL.
          SELECT MAX( AMDSQ )
            INTO L_AMDSQ
            FROM ZTITRQS
           WHERE REQNO  EQ G_TC_2130_WA-REQNO.
          PERFORM DISPLAY_IMPORT_DOCUMENT USING G_TC_2130_WA-REQNO
                                                L_AMDSQ
                                                G_TC_2130_WA-REQIT.
        WHEN 'ZTISCCIT-MATNR'.
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
        WHEN 'ZTITCCK-LIFNR'.
          PERFORM DISPLAY_VENDOR_MASTER USING ZTITCCK-LIFNR
                                              ZTITCCK-EKORG.
      ENDCASE.
    ENDIF.
  ENDIF.

ENDFORM.                    " double_click_event
*&---------------------------------------------------------------------*
*&      Module  pai_scr2210_sub1_subscreen  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_SCR2210_SUB1_SUBSCREEN INPUT.

  CALL FUNCTION 'Z_TI_OTHERS_TEXT_IMPORT'
    EXPORTING
      LCITY  = C_CHAR7
      MODE   = G_MODE
    TABLES
      IT_TAB = IT_LCTEXT.

ENDMODULE.                 " pai_scr2210_sub1_subscreen  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr2210_sub2_subscreen  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_SCR2210_SUB2_SUBSCREEN INPUT.

  CALL FUNCTION 'Z_TI_OTHERS_TEXT_IMPORT'
    EXPORTING
      LCITY  = C_CHAR8
      MODE   = G_MODE
    TABLES
      IT_TAB = IT_LCTEXT.

ENDMODULE.                 " pai_scr2210_sub2_subscreen  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr2210_sub3_subscreen  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_SCR2210_SUB3_SUBSCREEN INPUT.

  CALL FUNCTION 'Z_TI_OTHERS_TEXT_IMPORT'
    EXPORTING
      LCITY  = C_CHAR9
      MODE   = G_MODE
    TABLES
      IT_TAB = IT_LCTEXT.

ENDMODULE.                 " pai_scr2210_sub3_subscreen  INPUT
*&---------------------------------------------------------------------*
*&      Form  p8111_edi_table_clear
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P8111_EDI_TABLE_CLEAR  USING    P_ZTITCCK STRUCTURE ZTITCCK
                                     P_SUBRC.

  CLEAR: P_SUBRC.

*> 수입신고필증 란 테이블.
  DELETE FROM ZTITCC1 WHERE ICCNO EQ P_ZTITCCK-ICCNO
                        AND ICCSQ EQ P_ZTITCCK-ICCSQ.

*> 수입신고필증 규격테이블.
  DELETE FROM ZTITCC2 WHERE ICCNO EQ P_ZTITCCK-ICCNO
                        AND ICCSQ EQ P_ZTITCCK-ICCSQ.


*> 수입신고필증 요건테이블.
  DELETE FROM ZTITCC3 WHERE ICCNO EQ P_ZTITCCK-ICCNO
                        AND ICCSQ EQ P_ZTITCCK-ICCSQ.

*  IF sy-subrc NE 0.
*    ROLLBACK WORK.   MOVE sy-subrc  TO p_subrc.     EXIT.
*  ENDIF.

ENDFORM.                    " p8111_edi_table_clear
*&---------------------------------------------------------------------*
*&      Form  set_item_number_build
*&---------------------------------------------------------------------*
*       아이템 번호를 생성함.
*----------------------------------------------------------------------*
FORM SET_ITEM_NUMBER_BUILD  TABLES   P_IT_TAB   LIKE      IT_TAB
                            USING    P_ZTITCCK STRUCTURE ZTITCCK.

  DATA: L_LPONR LIKE P_ZTITCCK-LPONR.

  IF G_MODE EQ C_CHARC.
    CLEAR: L_LPONR.
    LOOP AT P_IT_TAB.
      ADD 1 TO L_LPONR.
      MOVE L_LPONR TO P_IT_TAB-ICCIT.
      MODIFY P_IT_TAB.
    ENDLOOP.
    MOVE L_LPONR TO P_ZTITCCK-LPONR.
  ELSE.
    CLEAR: G_LINES.
    LOOP AT P_IT_TAB.
      IF NOT P_IT_TAB-ICCIT IS INITIAL.
        PERFORM CHECK_CC_SUB_DOCUMENT_EXIST USING P_IT_TAB-ICCNO
                                                  P_IT_TAB-ICCIT
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
        IF P_IT_TAB-ICCIT IS INITIAL.
          ADD 1 TO P_ZTITCCK-LPONR.
          MOVE P_ZTITCCK-LPONR TO P_IT_TAB-ICCIT.
        ENDIF.
        MODIFY P_IT_TAB.
      ENDLOOP.
    ELSE.
      CLEAR: L_LPONR.
      LOOP AT P_IT_TAB.
        ADD 1 TO L_LPONR.
        MOVE L_LPONR TO P_IT_TAB-ICCIT.
        MODIFY P_IT_TAB.
      ENDLOOP.
      MOVE L_LPONR TO P_ZTITCCK-LPONR.
    ENDIF.
  ENDIF.
  CLEAR: L_LPONR.
  LOOP AT P_IT_TAB.
    IF P_IT_TAB-ICCIT GT L_LPONR.
      MOVE P_IT_TAB-ICCIT TO L_LPONR.
    ENDIF.
  ENDLOOP.
  MOVE L_LPONR TO P_ZTITCCK-LPONR.

ENDFORM.                    " set_item_number_build
*&---------------------------------------------------------------------*
*&      Form  set_function_by_BUSINESS
*&---------------------------------------------------------------------*
FORM SET_FUNCTION_BY_BUSINESS .

  CASE SY-DYNNR.
    WHEN C_SCR2000.
      DELETE FTAB
        WHERE FCODE EQ 'ZTIEDI'.
    WHEN OTHERS.
  ENDCASE.

  IF ZTITIG00-CCDCL IS INITIAL.
    MOVE 'ZTIEDI'     TO FTAB-FCODE.   APPEND FTAB. ">EDI.
  ENDIF.

*  CASE sy-tcode.
*    WHEN c_create OR c_create_d OR c_create_a OR          ">생성.
*         c_change.                                        ">변경.
*      IF ZTITRQS-docst EQ 'C'.
*        MOVE 'ZTIREQUEST'     TO ftab-fcode.   APPEND ftab. ">의뢰.
*      ELSE.
*        MOVE 'ZTIREQCANC'     TO ftab-fcode.   APPEND ftab. ">취소.
*      ENDIF.
*    WHEN c_acceptance.                                      ">접수.
*      IF ZTITRQS-docst EQ 'A'.
*        MOVE 'ZTIACCEPT'      TO ftab-fcode.   APPEND ftab. ">접수.
*      ENDIF.
*      IF ZTITRQS-docst EQ 'R'.
*        MOVE 'ZTIRETURN'      TO ftab-fcode.   APPEND ftab. ">접수.
*      ENDIF.
*    WHEN c_acceptance.                                      ">개설관리.
*      IF ZTITRQS-docst EQ 'O'.
*        MOVE 'ZTIRECVC'      TO ftab-fcode.   APPEND ftab. ">접수.
*      ELSE.
*        MOVE 'ZTIRECVC'      TO ftab-fcode.   APPEND ftab. ">접수.
*      ENDIF.
*    WHEN c_open.
*      IF ZTITRQS-docst NE 'O'.
*        MOVE 'ZTISENDC'      TO ftab-fcode.   APPEND ftab. ">개설취소.
*      ENDIF.
*      IF ZTITRQK-dcend EQ 'X'.
*        MOVE 'ZTICLOSE'      TO ftab-fcode.   APPEND ftab. ">종료.
*      ELSE.
*        MOVE 'ZTICLOSEC'     TO ftab-fcode.   APPEND ftab. ">종료취소.
*      ENDIF.
*    WHEN OTHERS.
*  ENDCASE.
ENDFORM.                    " set_function_by_BUSINESS
*&---------------------------------------------------------------------*
*&      Form  set_cus_edi_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_CUS_EDI_SCREEN  USING    P_CC.

  CASE P_CC.
    WHEN C_CC.                  G_CALL_SUBSCREEN = C_SCR2210.
*       WHEN c_pu.                  g_call_subscreen = c_scr2220.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " set_cus_edi_screen
*&---------------------------------------------------------------------*
*&      Form  get_custom_partner
*&---------------------------------------------------------------------*
*       세관 코드 Select
*----------------------------------------------------------------------*
FORM GET_CUSTOM_PARTNER  USING    P_CDCOR
                                  P_ZTSVIG5
                                  P_MSGTY.

  CHECK : NOT P_CDCOR IS INITIAL.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF P_ZTSVIG5
    FROM ZTSTIG5 AS I INNER JOIN LFA1 AS V
      ON I~LIFNR  EQ  V~LIFNR
   WHERE CDCOR  EQ  P_CDCOR.

  IF SY-SUBRC NE 0.
    MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 927 WITH P_CDCOR.
  ENDIF.

ENDFORM.                    " get_custom_partner
*&---------------------------------------------------------------------*
*&      Form  move_bl_fields_to_cc_fields
*&---------------------------------------------------------------------*
*       Default fields move ( from B/L fields )
*----------------------------------------------------------------------*
FORM MOVE_BL_FIELDS_TO_CC_FIELDS .

  TABLES : ZTIVRQ04.

  DATA: YZTSTIG0        TYPE ZTSTIG0.
  DATA: L_CIPAT         TYPE ZTICIPAT.

  DATA: BEGIN OF LT_IIPNO  OCCURS 0,
          IIPNO TYPE ZTIIIPNO,
          AMDSQ TYPE ZTIAMDSQ,
        END   OF LT_IIPNO.

  CHECK NOT ZTITCCK-IBLNO IS INITIAL.
*> B/L Select.
  SELECT SINGLE *
    FROM ZTITBLK
   WHERE IBLNO  EQ  ZTITCCK-IBLNO.

*> B/L Number
*  IF ztitccK-cblno IS INITIAL.
  ZTITCCK-CBLNO = ZTITBLK-BLNUM.
*  ENDIF.
*> 수입자.
  IF ZTITCCK-CIMTY IS INITIAL.
    IF ZTITBLK-APPCT EQ C_CHARY.
      ZTITCCK-CIMTY = C_CHARA.
      ZTITRQK-APPCT = C_CHARY.
    ELSE.
      ZTITCCK-CIMTY = C_CHARB.
      ZTITRQK-APPCT = C_CHARN.
    ENDIF.
  ENDIF.
  IF ZTITCCK-CIMTY IS INITIAL.
    ZTITCCK-CIMTY = C_CHARA.
    ZTITRQK-APPCT = C_CHARY.
  ENDIF.
*> 수입자를 위해.
  CALL FUNCTION 'Z_TS_GET_COMPANY_EDI_DATA'
    EXPORTING
      BUKRS     = ZTITCCK-BUKRS
      APPCT     = ZTITRQK-APPCT
    IMPORTING
      YZTSTIG0  = YZTSTIG0
      NZTSTIG0  = ZTSTIG0
      XT001     = T001
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
    MESSAGE ID SY-MSGID TYPE C_WARNING  NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*> 세관.
  IF ZTITCCK-CDCOR IS INITIAL.
    ZTITCCK-CDCOR = '010'.
  ENDIF.

  IF ZTITCCK-CDCCH IS INITIAL.
    ZTITCCK-CDCCH  = '10'.
  ENDIF.

*> 입항일자.
  IF ZTITCCK-CALDT IS INITIAL.
    ZTITCCK-CALDT = ZTITBLK-INBDT.
  ENDIF.

*> 수입자.
  IF ZTITCCK-CIMNM IS INITIAL.
    ZTITCCK-CIMNM = ZTSTIG0-NOMNM.
  ENDIF.

*> 납세자.
*> 납세자를 위해.
  READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.
  IF SY-SUBRC EQ 0.
    SELECT SINGLE *
      FROM ZTSTIG1
     WHERE BUKRS  EQ ZTITCCK-BUKRS
       AND BUPLA  EQ G_TC_2130_WA-BUPLA.
    IF SY-SUBRC EQ 0.
      IF ZTITCCK-CDUPN IS INITIAL.
        ZTITCCK-CDUPN  = ZTSTIG1-NOMNM.
        ZTITCCK-CDUAD1 = ZTSTIG1-NOAD1.
        ZTITCCK-CDUAD2 = ZTSTIG1-NOAD2.
        ZTITCCK-CDUNM  = ZTSTIG1-NOMPR.
        ZTITCCK-CCOID  = ZTSTIG1-BUSID.  ">사업자번호.
        ZTITCCK-CCUID  = ZTSTIG1-SELNO.  ">통관고유부호.
        ZTITCCK-CCONO  = ZTSTIG1-TRDID.  ">무역업등록번호.
*        ztitcck-ccuid  = ztstig1-trdid.
        ZTITCCK-BUPLA  = ZTSTIG1-BUPLA.
        ZTITCCK-WERKS  = G_TC_2130_WA-WERKS.
        ZTITCCK-EBELN  = G_TC_2130_WA-EBELN.
      ENDIF.
    ENDIF.
  ELSE.
    IF ZTITCCK-CDUPN IS INITIAL.
      ZTITCCK-CDUPN  = YZTSTIG0-NOMNM.
      ZTITCCK-CDUAD1 = YZTSTIG0-NOAD1.
      ZTITCCK-CDUAD2 = YZTSTIG0-NOAD2.
      ZTITCCK-CDUNM  = YZTSTIG0-NOMPR.
      ZTITCCK-CCONO  = YZTSTIG0-CCONO.
      ZTITCCK-CCOID  = T001-STCEG.
    ENDIF.
  ENDIF.
*> 공급자.
  IF ZTITCCK-CASNM IS INITIAL.
    ZTITCCK-CASNM = LFA1-NAME1.
    ZTITCCK-CASLD = LFA1-LAND1.
  ENDIF.
**> 징수형태.
*  IF ztitccK-carty IS INITIAL.
*    ztitccK-carty = '00'.
*  ENDIF.
*> 통관계획.
  IF ZTITCCK-CCUPL IS INITIAL.
    ZTITCCK-CCUPL = 'D'.
  ENDIF.
*> 신고구분.
  IF ZTITCCK-CRETY IS INITIAL.
    ZTITCCK-CRETY = 'A'.
  ENDIF.
*> 16.거래구분.
  IF ZTITCCK-CSATY IS INITIAL.
    ZTITCCK-CSATY = '11'.
  ENDIF.
*> 17.수입종류___
  IF ZTITCCK-CIPTY IS INITIAL.
    ZTITCCK-CIPTY = 'B'.
  ENDIF.

*> 국내도착항.
  IF ZTITBLK-TPORT IS INITIAL.
    ZTITCCK-CIARP = 'PUS'.
  ELSE.
    ZTITCCK-CIARP = ZTITBLK-TPORT.
  ENDIF.

*> 25.선(기)명.
  IF ZTITCCK-CVSLN IS INITIAL.
    ZTITCCK-CVSLN = ZTITBLK-IVSLN.
  ENDIF.
*> 적출국.
  IF ZTITCCK-COFLD IS INITIAL.
    ZTITCCK-COFLD = ZTITBLK-FLAND.
  ENDIF.
*> 선기국적.
  IF ZTITCCK-CVSLD IS INITIAL.
    ZTITCCK-CVSLD = ZTITBLK-FLAND.
  ENDIF.
*> 20.총중량_.
  IF ZTITCCK-CTOWE IS INITIAL.
    ZTITCCK-CTOWE = ZTITBLK-BRGEW.
  ENDIF.
*> 20.총중량_단위
  IF ZTITCCK-CTOWEU IS INITIAL.
    ZTITCCK-CTOWEU = ZTITBLK-GEWEI.
  ENDIF.
*> 총포장개수
  IF ZTITCCK-CTPKG IS INITIAL.
    ZTITCCK-CTPKG = ZTITBLK-BIPKG.
  ENDIF.
*> 총포장개수
  IF ZTITCCK-CTPKGU IS INITIAL.
    ZTITCCK-CTPKGU = ZTITBLK-BPKTY.
  ENDIF.
*> 운송형태.
  IF ZTITCCK-CTRBO IS INITIAL.
    CASE ZTITBLK-FWDFM.
      WHEN 'F'.
        ZTITCCK-CTRBO = 'FC'.
      WHEN 'L'.
        ZTITCCK-CTRBO = 'LC'.
      WHEN 'B'.
        ZTITCCK-CTRBO = 'BU'.
    ENDCASE.
  ENDIF.
*> 운송수단
  IF ZTITCCK-CTRME IS INITIAL.
    CASE ZTITBLK-FWDTY.
      WHEN 'O'.   ZTITCCK-CTRME = '10'.
      WHEN 'A'.   ZTITCCK-CTRME = '40'.
      WHEN 'Z'.   ZTITCCK-CTRME = '90'.
    ENDCASE.
  ENDIF.
*> 분할여부.
  IF ZTITCCK-CBLDY IS INITIAL.
    ZTITCCK-CBLDY = C_CHARN.
  ENDIF.
*> Incoterms
  IF ZTITCCK-CINCO IS INITIAL.
    ZTITCCK-CINCO = ZTITBLK-INCO1.
  ENDIF.

*> 통화.
  ZTITCCK-CPYATC = ZTITBLK-WAERS.
*> 결제금액.
  ZTITCCK-CPYAT  = ZTITBLK-IVAMT + ZTITBLK-RTCHG.
  ZTITCCK-CCUAKC = T001-WAERS.
  ZTITCCK-CCUAUC = 'USD'.
*> 관세사.
*  IF ztitccK-state IS INITIAL.
*    ztitccK-state = '10028'.
*  ENDIF.
  IF ZTITCCK-CIARP IS INITIAL.
    ZTITCCK-CIARP = ZTITBLK-TPORT.
  ENDIF.

  IF ZTITCCK-CARTY IS INITIAL.
    ZTITCCK-CARTY = ZTITBLK-CSATY.
  ENDIF.
*> 일자.
  IF ZTITCCK-CDADT IS INITIAL.
    ZTITCCK-CDADT = SY-DATLO.
  ENDIF.
  IF ZTITCCK-CDCDT IS INITIAL.
    ZTITCCK-CDCDT = SY-DATLO.
  ENDIF.
  IF ZTITCCK-CDHDT IS INITIAL.
    ZTITCCK-CDHDT = ZTITBLK-CCRDA.
    IF ZTITCCK-CDHDT IS INITIAL.
      ZTITCCK-CDHDT = SY-DATLO.
    ENDIF.
  ENDIF.
*> 반입신고관련.
  SELECT SINGLE *
    FROM ZTITBIK
   WHERE IBLNO  EQ  ZTITBLK-IBLNO.
  IF SY-SUBRC EQ 0.
    IF ZTITCCK-CCANO IS INITIAL.
      CONCATENATE ZTITBIK-BGMNO ZTITBIK-BMSN ZTITBIK-BHSN
                  INTO ZTITCCK-CCANO.
    ENDIF.
    IF ZTITCCK-CILDT IS INITIAL.
      ZTITCCK-CILDT = ZTITBIK-BINDT.
    ENDIF.
  ENDIF.

*> 보험료.
  CLEAR: ZTITCCK-CIPAT.
  REFRESH: LT_IIPNO.
  LOOP AT IT_TAB INTO G_TC_2130_WA.
    SELECT IIPNO MAX( AMDSQ ) AS AMDSQ
      INTO CORRESPONDING FIELDS OF LT_IIPNO
      FROM ZTITIP1
     WHERE EBELN  EQ  G_TC_2130_WA-EBELN
*     WHERE reqno  EQ  g_tc_2130_wa-reqno
     GROUP BY IIPNO.
      COLLECT LT_IIPNO.
    ENDSELECT.
  ENDLOOP.

  DESCRIBE TABLE LT_IIPNO LINES G_LINE.

  IF G_LINE GT 0.
    LOOP AT LT_IIPNO.
      CLEAR: L_CIPAT.
      SELECT SINGLE ITPA1
        INTO L_CIPAT
        FROM ZTITIP1
       WHERE IIPNO  EQ  LT_IIPNO-IIPNO
         AND AMDSQ  EQ  LT_IIPNO-AMDSQ.
      ADD L_CIPAT TO ZTITCCK-CIPATT.
    ENDLOOP.
    ZTITCCK-CIPAT = ZTITCCK-CIPATT.
  ENDIF.

*> 운임.(USD)
  ZTITCCK-CFRATU = ZTITBLK-CFRAT.

  LOOP AT IT_TAB INTO G_TC_2130_WA WHERE EBELN NE SPACE.
    SELECT SINGLE *
      FROM ZTIVRQ04
     WHERE REQNO EQ G_TC_2130_WA-EBELN.
    IF SY-SUBRC EQ 0.
      CASE ZTIVRQ04-REQTY.
        WHEN C_LC.
          IF ZTIVRQ04-ILCTY EQ C_CHARA.
            ZTITCCK-CPYME = 'LS'.
          ELSEIF ZTIVRQ04-ILCTY EQ C_CHARU.
            ZTITCCK-CPYME = 'LU'.
          ENDIF.
        WHEN C_TT.
          ZTITCCK-CPYME = 'TT'.
        WHEN C_DA.
          ZTITCCK-CPYME = 'DP'.
        WHEN C_DP.
          ZTITCCK-CPYME = 'DA'.
        WHEN OTHERS.
          CLEAR ZTITCCK-CPYME.
      ENDCASE.
    ENDIF.

    ZTITCCK-OPNNO = ZTIVRQ04-OPNNO.

    IF ZTITCCK-CREAG1 IS INITIAL.
      ZTITCCK-CREAG1 = ZTITCCK-EBELN.
      IF NOT ZTITCCK-OPNNO IS INITIAL.
        CONCATENATE ZTITCCK-CREAG1 '-' ZTITCCK-OPNNO
               INTO ZTITCCK-CREAG1.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " move_bl_fields_to_cc_fields
*&---------------------------------------------------------------------*
*&      Form  check_open_amount
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_OPEN_AMOUNT .

*----  >>  Begin of Loop.
  LOOP AT IT_TAB INTO G_TC_2130_WA.
*> 호선 정보 collect.
    IF NOT G_TC_2130_WA-PS_PSP_PNR IS INITIAL.
      MOVE: G_TC_2130_WA-PS_PSP_PNR TO IT_PSPNR-PSPNR.
      COLLECT IT_PSPNR.
    ENDIF.


    IF G_MODE EQ C_CHARC OR
       G_MODE EQ C_CHARM.
      IF ZTITCCK-EBELN IS INITIAL.
        ZTITCCK-EBELN = G_TC_2130_WA-EBELN.
      ENDIF.

      IF ZTITCCK-WERKS IS INITIAL.
        ZTITCCK-WERKS = G_TC_2130_WA-WERKS.
      ENDIF.

      IF ZTITCCK-BUPLA IS INITIAL.
        SELECT SINGLE J_1BBRANCH
          INTO ZTITCCK-BUPLA
          FROM T001W
         WHERE WERKS EQ G_TC_2130_WA-WERKS.
      ENDIF.
      MODIFY IT_TAB FROM G_TC_2130_WA.
    ENDIF.

  ENDLOOP.
*----  >>  End of Loop.
  ZTITCCK-CTOTL =
  ZTITCCK-CDUTX + ZTITCCK-CAGTX + ZTITCCK-CSPTX +
  ZTITCCK-CALTX + ZTITCCK-CTRTX + ZTITCCK-CINTX +
  ZTITCCK-CLTTX + ZTITCCK-CADTX.


ENDFORM.                    " check_open_amount
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P1001_INITIALIZATION .

  SET TITLEBAR 'T1000' WITH 'Due List'(T10).

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
    MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
  ENDIF.

*> 수입 IMG Select.
  SELECT SINGLE *
    FROM ZTITIG00
   WHERE BUKRS EQ L_BUKRS.
  IF SY-SUBRC NE 0.
    MESSAGE E035 WITH L_BUKRS.
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

  DATA: L_RQMNG  LIKE ZTITRQP-RQMNG.
  RANGES LR_BLDST FOR  ZTITBLK-BLDST  OCCURS 1.

  CLEAR: G_COUNT, IT_TAB_H, IT_ZTITIG02, IT_HEADER, IT_LIST.
  REFRESH : IT_TAB_H, IT_ZTITIG02, IT_HEADER, IT_LIST.
*> PROGRESS Display.
  G_LINEN    = 30.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'(P01).
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINEN.

*> 수입신고 미사용일 경우.
  IF ZTITIG00-CCRQM EQ C_CHARN.
*> B/L 상태별로 Select.
    LR_BLDST-SIGN   = C_CHARI.
    LR_BLDST-OPTION = 'EQ'.
    IF ZTITIG00-BLPCS EQ C_CHARA OR
       ZTITIG00-BLPCS EQ C_CHARB.
*>통관요청 사용여부.
      CASE ZTITIG00-CCRPC.
        WHEN C_CHARE.
          LR_BLDST-LOW = C_CHARE.   APPEND LR_BLDST.
          LR_BLDST-LOW = C_CHARF.   APPEND LR_BLDST.
        WHEN C_CHARW.
          LR_BLDST-LOW = C_CHARE.   APPEND LR_BLDST.
          LR_BLDST-LOW = C_CHARF.   APPEND LR_BLDST.
          LR_BLDST-LOW = C_CHARD.   APPEND LR_BLDST.
        WHEN SPACE.
          LR_BLDST-LOW = C_CHARD.   APPEND LR_BLDST.
      ENDCASE.
    ELSE.
      CASE ZTITIG00-CCRPC.
        WHEN C_CHARE.
          LR_BLDST-LOW = C_CHARE.   APPEND LR_BLDST.
          LR_BLDST-LOW = C_CHARF.   APPEND LR_BLDST.
        WHEN C_CHARW.
          LR_BLDST-LOW = C_CHARE.   APPEND LR_BLDST.
          LR_BLDST-LOW = C_CHARF.   APPEND LR_BLDST.
          LR_BLDST-LOW = C_CHARZ.   APPEND LR_BLDST.
        WHEN SPACE.
          LR_BLDST-LOW = C_CHARZ.   APPEND LR_BLDST.
      ENDCASE.
    ENDIF.

*> B/L 데이타 select.
    SELECT *
          INTO CORRESPONDING FIELDS OF TABLE IT_TAB_H
          FROM ZTITBLK AS A JOIN ZTITBLP AS B
            ON A~IBLNO EQ B~IBLNO
         WHERE A~BUKRS  IN S_BUKRS  "회사코드.
           AND A~IBLNO  IN S_IBLNO
           AND A~BLDST  IN LR_BLDST "상태.
           AND A~BLNUM  IN S_BLNUM  "25B/L 번호.
           AND A~BLDTY  IN S_BLDTY                          "1문서종류.
           AND A~RPTTY  IN S_RPTTY  "1수입신고구분.
           AND A~EKORG  IN S_EKORG                          "4구매조직.
           AND A~EKGRP  IN S_EKGRP                          "3구매그룹.
           AND A~LIFNR  IN S_LIFNR  "10공급업체 계정번호.
           AND A~BLETD  IN S_BLETD  "8ETD(출발 예정 시각).
           AND A~BLETA  IN S_BLETA  "8ETA(도착 예정 시각).
           AND A~FWDTY  IN S_FWDTY  "1운송 방법.
           AND A~WAERS  IN S_WAERS                          "5통화키.
           AND A~LGAYN  IN S_LGAYN  "LG대상여부.
           AND B~IBLIT  IN S_IBLIT  "5B/L 품목번호.
           AND B~EBELN  IN S_EBELN  "10구매전표번호.
           AND B~EBELP  IN S_EBELP  "5구매문서 품목번호.
           AND B~REQNO  IN S_REQNO  "10수입의뢰 관리번호.
           AND B~REQIT  IN S_REQIT  "5수입의뢰 품목번호.
           AND B~CNAM   IN S_CNAM                           "12작성인.
           AND B~CDAT   IN S_CDAT                           "8생성일.
           AND B~CTME   IN S_CTME                           "6생성시간.
           AND B~UNAM   IN S_UNAM   "12최종변경인.
           AND B~UDAT   IN S_UDAT                           "8변경일.
           AND B~UTME   IN S_UTME   "6최종변경시간.
           AND A~CRLSE  NE 'B'.     "입수경로가 미확인이 아닌것만.
*> 수입신고를 사용할 경우.
  ELSE.
    SELECT *
          INTO CORRESPONDING FIELDS OF TABLE IT_TAB_H
          FROM ZTITBLK AS A INNER JOIN ZTITBLP AS B
            ON A~IBLNO EQ B~IBLNO
               INNER JOIN ZTITCRP AS C
               ON  B~IBLNO  EQ  C~IBLNO
               AND B~IBLIT  EQ  C~IBLIT
         WHERE A~BUKRS  IN S_BUKRS  "회사코드.
           AND A~IBLNO  IN S_IBLNO
           AND A~BLDST  IN LR_BLDST "상태.
           AND A~BLNUM  IN S_BLNUM  "25B/L 번호.
           AND A~BLDTY  IN S_BLDTY                          "1문서종류.
           AND A~RPTTY  IN S_RPTTY  "1수입신고구분.
           AND A~EKORG  IN S_EKORG                          "4구매조직.
           AND A~EKGRP  IN S_EKGRP                          "3구매그룹.
           AND A~LIFNR  IN S_LIFNR  "10공급업체 계정번호.
           AND A~BLETD  IN S_BLETD  "8ETD(출발 예정 시각).
           AND A~BLETA  IN S_BLETA  "8ETA(도착 예정 시각).
           AND A~FWDTY  IN S_FWDTY  "1운송 방법.
           AND A~WAERS  IN S_WAERS                          "5통화키.
           AND A~LGAYN  IN S_LGAYN  "LG대상여부.
           AND B~IBLIT  IN S_IBLIT  "5B/L 품목번호.
           AND B~EBELN  IN S_EBELN  "10구매전표번호.
           AND B~EBELP  IN S_EBELP  "5구매문서 품목번호.
           AND B~REQNO  IN S_REQNO  "10수입의뢰 관리번호.
           AND B~REQIT  IN S_REQIT  "5수입의뢰 품목번호.
           AND C~CNAM   IN S_CNAM                           "12작성인.
           AND C~CDAT   IN S_CDAT                           "8생성일.
           AND C~CTME   IN S_CTME                           "6생성시간.
           AND C~UNAM   IN S_UNAM   "12최종변경인.
           AND C~UDAT   IN S_UDAT                           "8변경일.
           AND C~UTME   IN S_UTME   "6최종변경시간.
           AND A~CRLSE  NE 'B'.     "입수경로가 미확인이 아닌것만.
  ENDIF.

  IF SY-SUBRC NE 0.
    MESSAGE S902.
  ENDIF.

  CLEAR: G_TABIX, G_COUNT, G_CNT.
  LOOP AT IT_TAB_H.

    G_TABIX = SY-TABIX.

*   CC 누적수량.
*> 수입신고 미사용일 경우.
    IF ZTITIG00-CCRQM EQ C_CHARN.
      SELECT  SUM( CCMNG )
        INTO  IT_TAB_H-CCMNGS
        FROM  ZTITCCP
       WHERE  IBLNO  = IT_TAB_H-IBLNO
         AND  IBLIT  = IT_TAB_H-IBLIT.

*   CC 가능수량.
      IT_TAB_H-CCMNGL =  IT_TAB_H-BLMNG - IT_TAB_H-CCMNGS.

    ELSE.
      SELECT  SUM( CCMNG )
        INTO  IT_TAB_H-CCMNGS
        FROM  ZTITCCP
       WHERE  ICCNO  = IT_TAB_H-ICCNO
         AND  ICCSQ  = IT_TAB_H-ICCSQ
         AND  ICCIT  = IT_TAB_H-ICCIT.

*   CC 가능수량.
      IT_TAB_H-CCMNGL =  IT_TAB_H-CCMNG - IT_TAB_H-CCMNGS.

    ENDIF.

    IF IT_TAB_H-CCMNGL LE 0.
      DELETE IT_TAB_H INDEX G_TABIX.
      CONTINUE.
    ENDIF.

*   domain의 value.
    PERFORM GET_DOMAIN_VALUE_TEXT(ZTIR0000) USING :
                           'ZTIBLDTY' IT_TAB_H-BLDTY  IT_TAB_H-BLDTYX,
                           'ZTIRPTTY' IT_TAB_H-RPTTY  IT_TAB_H-RPTTYX,
                           'ZTIFWDTY' IT_TAB_H-FWDTY  IT_TAB_H-FWDTYX,
                           'ZTINDFTY' IT_TAB_H-NDFTY  IT_TAB_H-NDFTYX.
*   공급업체.
    SELECT SINGLE NAME1 INTO IT_TAB_H-NAME1
      FROM LFA1
     WHERE LIFNR EQ IT_TAB_H-LIFNR.

*   p/o정보.
    SELECT  SINGLE MENGE WERKS MATNR TXZ01
      INTO  (IT_TAB_H-POMNG, IT_TAB_H-WERKS, IT_TAB_H-MATNR,
      IT_TAB_H-TXZ01)
      FROM  ZTIVPO00
     WHERE  EBELN  = IT_TAB_H-EBELN
       AND  EBELP  = IT_TAB_H-EBELP.

    IF IT_TAB_H-REQNO IS NOT INITIAL. "기능개선_XXXX 긴급수정.
*   수입의뢰 정보 수량.
      SELECT  SINGLE RQMNG
        INTO  IT_TAB_H-MENGE
        FROM  ZTIVRQ00
       WHERE  REQNO  = IT_TAB_H-REQNO
         AND  REQIT  = IT_TAB_H-REQIT.

*   b/l 누적수량.
      SELECT  SUM( BLMNG ) INTO IT_TAB_H-BLMNGS FROM ZTITBLP
       WHERE  REQNO  = IT_TAB_H-REQNO
         AND  REQIT  = IT_TAB_H-REQIT.

    ENDIF.

*   b/l 가능수량.
    IT_TAB_H-BLMNGL =  IT_TAB_H-MENGE - IT_TAB_H-BLMNGS.

    MOVE IT_TAB_H-REFWR TO IT_TAB_H-TREFWR.

    ADD 1 TO G_COUNT.

    MODIFY IT_TAB_H INDEX G_TABIX.

  ENDLOOP.

ENDFORM.                    " p2000_data_selections
*&---------------------------------------------------------------------*
*&      Form  p2100_header_and_list_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P2100_HEADER_AND_LIST_BUILD .

  DATA: L_HEADER TYPE TY_HEADER.

  LOOP AT IT_TAB_H.
    MOVE-CORRESPONDING IT_TAB_H TO : IT_HEADER, IT_LIST.
    IF ZTITIG00-CCRQM EQ C_CHARN.
      READ TABLE IT_HEADER INTO L_HEADER
                           WITH KEY IBLNO = IT_TAB_H-IBLNO.
    ELSE.
      READ TABLE IT_HEADER INTO L_HEADER
                           WITH KEY ICCNO = IT_TAB_H-ICCNO.
    ENDIF.
    IF SY-SUBRC NE 0.
      COLLECT : IT_HEADER.
    ENDIF.
    APPEND    IT_LIST.
  ENDLOOP.

ENDFORM.                    " p2100_header_and_list_build
*&---------------------------------------------------------------------*
*&      Form  3000_field_category_build
*&---------------------------------------------------------------------*
FORM 3000_FIELD_CATEGORY_BUILD .

*----------------------------------------------------------------------*
* 필드명과 Output Length등을 사용자의 입맛에 맞게 바꿈.
*----------------------------------------------------------------------*
  PERFORM 3010_FILL_FIELD_CATEGORY USING :
*>>>>>>HEADER
"BOX.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'FIELDNAME'     'BOX',
          'E' 'KEY'           ' '.

  IF ZTITIG00-CCRQM EQ C_CHARN.
    PERFORM 3010_FILL_FIELD_CATEGORY USING :
"B/L 관리번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'IBLNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12'.
  ELSE.
    PERFORM 3010_FILL_FIELD_CATEGORY USING :
"C/C 관리번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITCRK',
          ' ' 'FIELDNAME'     'ICCNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
*>by YSH(050120)
"C/C 차수
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITCRK',
          ' ' 'FIELDNAME'     'ICCSQ',
          ' ' 'seltext_m'     '차수',
*          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '4',


"신고의뢰번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITCRK',
          ' ' 'FIELDNAME'     'CDRNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"B/L 관리번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'IBLNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '12'.
  ENDIF.
  PERFORM 3010_FILL_FIELD_CATEGORY USING :
"B/L번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
*          ' ' 'seltext_m'     'BLNUM',
          ' ' 'FIELDNAME'     'BLNUM',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '14',
"문서상태
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     '문서상태',
          ' ' 'FIELDNAME'     'BLDTYX',
          'E' 'OUTPUTLEN'     '13',
"ETD
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'BLETD',
          'E' 'OUTPUTLEN'     '11',
"ETA
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
*          ' ' 'seltext_m'     '',
          ' ' 'FIELDNAME'     'BLETA',
          'E' 'OUTPUTLEN'     '11',
"회사코드
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'BUKRS',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '4',
"운송방법.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     '운송방법',
          ' ' 'FIELDNAME'     'FWDTYX',
          'E' 'OUTPUTLEN'     '12',
"수입신고구분
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     '신고구분',
          ' ' 'FIELDNAME'     'RPTTYX',
          'E' 'OUTPUTLEN'     '12',
"송장금액통화
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'seltext_m'     'Cur',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'WAERS',
          'E' 'OUTPUTLEN'     '3',
"송장금액.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'seltext_m'     '송장값 (외화)',
          ' ' 'FIELDNAME'     'TREFWR',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'CTABNAME'      'IT_HEADER',
          'E' 'OUTPUTLEN'     '20',

*>>>>>>>>>LIST
"B/L 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'IBLIT',
          ' ' 'HOTSPOT'       'X',
*          ' ' 'CONVEXIT'      'ALPHA',
          ' ' 'JUST'          'L',
          ' ' 'LZERO'         'X',
          ' ' 'INTLEN'         10,
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"수입의뢰번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'REQNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '10',
"수입의뢰 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'REQIT',
*          ' ' 'LZERO'         'X',
          'E' 'OUTPUTLEN'     '4',
"구매전표번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'EBELN',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '10',
"구매문서 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'EBELP',
*          ' ' 'LZERO'         'X',
          'E' 'OUTPUTLEN'     '4',
"종류.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'seltext_m'     '유무환',
          ' ' 'FIELDNAME'     'NDFTYX',
          'E' 'OUTPUTLEN'     '13',
"자재번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'FIELDNAME'     'MATNR',
          'E' 'OUTPUTLEN'     '13',
"자재내역.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'FIELDNAME'     'TXZ01',
*          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '26',
"P/O수량
          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'QTABNAME'       'IT_LIST',
          ' ' 'QFIELDNAME'     'MEINS',
          ' ' 'seltext_m'     'P/O 수량',
          ' ' 'FIELDNAME'     'POMNG',
          ' ' 'NO_OUT'        'X',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '15',
"수입의뢰수량
          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'seltext_m'     '수입의뢰수량',
          ' ' 'QTABNAME'       'IT_LIST',
          ' ' 'QFIELDNAME'     'MEINS',
          ' ' 'FIELDNAME'     'MENGE',
          ' ' 'NO_OUT'        'X',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '15',
"B/L가능수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
*          ' ' 'seltext_m'     '수입의뢰수량',
          ' ' 'QTABNAME'       'IT_LIST',
          ' ' 'QFIELDNAME'     'MEINS',
          ' ' 'FIELDNAME'     'BLMNGL',
          ' ' 'NO_OUT'        'X',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'NO_OUT'        'X',
          'E' 'KEY'           ' ',
"B/L누적수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
*          ' ' 'seltext_m'     '수입의뢰수량',
          ' ' 'QTABNAME'       'IT_LIST',
          ' ' 'QFIELDNAME'     'MEINS',
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'BLMNGS',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '22',

"B/L수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
*          ' ' 'seltext_m'     '수입의뢰수량',
          ' ' 'FIELDNAME'     'BLMNG',
          ' ' 'QTABNAME'       'IT_LIST',
          ' ' 'QFIELDNAME'     'MEINS',
          ' ' 'NO_OUT'        'X',
          ' ' 'HOTSPOT'       ' ',
          'E' 'KEY'           ' ',
"cc가능수량
          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTIsccit',
          ' ' 'seltext_m'     '통관가능수량',
          ' ' 'FIELDNAME'     'CCMNGL',
          ' ' 'QTABNAME'       'IT_LIST',
          ' ' 'QFIELDNAME'     'MEINS',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'NO_OUT'        ' ',
          'E' 'OUTPUTLEN'     '22',
"cc누적수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISCCIT',
*          ' ' 'seltext_m'     '수입의뢰수량',
          ' ' 'FIELDNAME'     'CCMNGS',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'NO_OUT'        'X',
          'E' 'KEY'           ' ',
"기본단위
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'MEINS',
          ' ' 'INTLEN'         10,
          'E' 'OUTPUTLEN'     '3',

"송장금액.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'seltext_m'     '송장값',
          ' ' 'FIELDNAME'     'REFWR',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'CTABNAME'      'IT_HEADER',
          ' ' 'NO_OUT'        ' ',
          'E' 'OUTPUTLEN'     '20',
"자재문서번호
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'MBLNR',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',
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
*&      Form  3200_KEY_INFOMATION_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM 3200_KEY_INFOMATION_BUILD .

  CLEAR GS_KEYINFO.

  GS_KEYINFO-HEADER01 = 'IBLNO'.
  GS_KEYINFO-ITEM01   = 'IBLNO'.

  GS_KEYINFO-HEADER02 = 'ICCNO'.
  GS_KEYINFO-ITEM02   = 'ICCNO'.

  GS_KEYINFO-HEADER03 = 'ICCSQ'.
  GS_KEYINFO-ITEM03   = 'ICCSQ'.

ENDFORM.                    " 3200_KEY_INFOMATION_BUILD
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
  GS_LISTHEADER-INFO = '수입신고 Due List'(T13).
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

* STATUS LINE:  TYPE S
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
  LS_SORT-FIELDNAME = 'IBLNO'.
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
        LS_LIST   TYPE TY_LIST,
        L_AMDSQ   TYPE ZTIAMDSQ.

  CLEAR: LS_HEADER, LS_LIST.

  CASE R_UCOMM.
    WHEN '&REFRESH'.
      PERFORM P9000_DUELIST_REFRESH USING  RS_SELFIELD.

    WHEN 'ZTIT001'. " 후속기능
      CLEAR : G_LINE, LS_HEADER.
      LOOP AT IT_HEADER WHERE BOX EQ 'X'.
        ADD 1 TO G_LINE.
        MOVE-CORRESPONDING IT_HEADER TO LS_HEADER.
      ENDLOOP.
      CASE G_LINE.
        WHEN 0.
          MESSAGE S003(OK). EXIT.
        WHEN 1.
          IF IT_HEADER-ICCNO IS INITIAL.
            SET PARAMETER ID 'ZTIICCNO' FIELD SPACE.
            SET PARAMETER ID 'ZTIICCSQ' FIELD '00'.
            SET PARAMETER ID 'ZTIIBLNO' FIELD IT_HEADER-IBLNO.
            SET PARAMETER ID 'ZTIBLNUM' FIELD SPACE.
            CALL TRANSACTION 'ZTIT401' AND SKIP FIRST SCREEN .
          ELSE.
            SET PARAMETER ID 'ZTIICCNO' FIELD IT_HEADER-ICCNO.
            SET PARAMETER ID 'ZTIICCSQ' FIELD IT_HEADER-ICCSQ.
            SET PARAMETER ID 'ZTIIBLNO' FIELD SPACE.
            SET PARAMETER ID 'ZTIBLNUM' FIELD SPACE.
            CALL TRANSACTION 'ZTIT401' AND SKIP FIRST SCREEN .
          ENDIF.
          PERFORM P9000_DUELIST_REFRESH USING  RS_SELFIELD.
        WHEN OTHERS.
          MESSAGE S035(0K).   EXIT.
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
        WHEN 'EBELN'.
          PERFORM  DISPLAY_PURCHASE_ORDER(ZTIR0000)
                                          USING LS_LIST-EBELN
                                                LS_LIST-EBELP.
        WHEN 'REQNO' OR 'REQIT'.
          SELECT MAX( AMDSQ )
            INTO L_AMDSQ
            FROM ZTITRQS
           WHERE REQNO  EQ  LS_LIST-REQNO.
          PERFORM  DISPLAY_IMPORT_DOCUMENT(ZTIR0000)
                                          USING LS_LIST-REQNO
                                                L_AMDSQ
                                                LS_LIST-REQIT.

        WHEN 'IBLNO' OR 'IBLIT'.
          PERFORM  DISPLAY_BL_DOCUMENT(ZTIR0000)
                                          USING LS_LIST-IBLNO
                                                LS_LIST-IBLIT.
*>by YSH(050120)
        WHEN 'ICCNO'.
          PERFORM  DISPLAY_CR_DOCUMENT(ZTIR0000)
                                          USING LS_LIST-ICCNO
                                                LS_LIST-ICCSQ.

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
*&      Form  get_longtext_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LONGTEXT_DATA .

*> Partner Text
  PERFORM  P1000_GET_TEXTID_AND_TEXT USING ZTITCCK+3(10)
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

  CALL FUNCTION 'Z_TI_GET_CLEARANCE_TO_QUERY'
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
*&      Form  p9000_duelist_refresh
*&---------------------------------------------------------------------*
FORM P9000_DUELIST_REFRESH
                 USING P_SELFIELD TYPE SLIS_SELFIELD.

*> 검색조건에 해당하는 데이타를 Select.
  PERFORM P2000_DATA_SELECTIONS.
*> Header table과 List(Items) table를 만듬.
  PERFORM P2100_HEADER_AND_LIST_BUILD.
  DESCRIBE TABLE IT_TAB_H LINES G_LINE.
  IF NOT G_LINE IS INITIAL.
    P_SELFIELD-REFRESH = 'X'.
  ELSE.
*> Program 종료.
    PERFORM  P9000_PROGRAM_EXIT.
  ENDIF.

ENDFORM.                    " p9000_duelist_refresh

*&---------------------------------------------------------------------*
*&      Form  OTHER_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM OTHER_FUNCTIONS .

  CASE OK_CODE.
    WHEN 'ZTIEDI'.      ">EDI 화면으로 이동.
*> Set 문서별 EDI Default value
*       PERFORM set_edi_default_value.
*> EDI Main 화면으로 이동.
      SET SCREEN C_SCR2200.

    WHEN 'ZTICHDOC'.    ">변경문서.
      G_OBJEKT   = 'ZTICCCHDOC'.
      G_OBJEKTID = ZTITCCK+3(12).
      PERFORM DISPLAY_CHANGE_DOCUMENT USING G_OBJEKT
                                            G_OBJEKTID.

*    WHEN 'ZTIACDOC'.
*      PERFORM account_document_display USING ztitcsk-bukrs
*                                             ztitcsk-gjahr
*                                             ztitcsk-belnr.
*
*    WHEN 'ZTIMMDOC'.
*      PERFORM display_liv_document  USING ztitcsk-belnr
*                                          ztitcsk-gjahr
*                                          ztitcsk-bukrs.
*
*    WHEN 'ZTIDSTR'.
*      PERFORM document_simulation_fi USING ok-code.
*
*    WHEN 'ZTIONTIME'.  ">일회성 계정.
*      PERFORM set_one_time_vender_data.
    WHEN 'ZTIRECALC'.
*>관세청 고시환율을 구함.
      PERFORM GET_CUSTOM_EXCHANGE_RATE.
*>란/행 Refresh
      PERFORM SET_ROW_COLUMNS_REFRESH.
*>금액 계산.
      PERFORM CALC_CUSTOMS_AMOUNT.

*---------------------------------------------------------------------
*> 관세 재계산.
*---------------------------------------------------------------------
    WHEN 'ZTICALC'.
*>관세청 고시환율을 구함.
      PERFORM GET_CUSTOM_EXCHANGE_RATE.
*>금액 계산.
      PERFORM CALC_CUSTOMS_AMOUNT.



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
*  PERFORM summary_invoice_amount  USING c_success.

ENDFORM.                    " BEFORE_TRANSPORT_PAI
*&---------------------------------------------------------------------*
*&      Form  GET_CUSTOM_IMPRT_REQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_CUSTOM_IMPRT_REQ .

  DATA : L_CCMNG  TYPE ZTICCMNG.

  IF ZTISSCRCOM-ICRNO IS INITIAL.
    SELECT ICCNO ICCSQ
      INTO (ZTISSCRCOM-ICRNO, ZTISSCRCOM-ICRSQ)
      FROM ZTITCRK UP TO 1 ROWS
     WHERE IBLNO  EQ  ZTISSCRCOM-IBLNO
     ORDER BY ICCNO DESCENDING ICCSQ DESCENDING.
    ENDSELECT.
    IF SY-SUBRC NE 0.
      MESSAGE E432 WITH ZTISSCRCOM-IBLNO.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'Z_TI_GET_CUSTOM_IMPORT_REQ'
    EXPORTING
      ICCNO     = ZTISSCRCOM-ICRNO
      ICCSQ     = ZTISSCRCOM-ICRSQ
    IMPORTING
      ZTITCRK   = ZTITCRK
    TABLES
      ZTITCRP   = XZTITCRP
      ZTITCR1   = XZTITCR1
      ZTITCR2   = XZTITCR2
      ZTITCR3   = XZTITCR3
      ZTITCR5   = XZTITCR5 "기능개선 XXXXX
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  SELECT SINGLE *
    INTO ZTITCCK_TMP
    FROM ZTITCCK
     WHERE ICCNO EQ ZTISSCRCOM-ICRNO
       AND ICCSQ EQ ZTISSCRCOM-ICRSQ.
  IF SY-SUBRC EQ 0.
    MESSAGE E443 WITH ZTISSCRCOM-ICRNO ZTISSCRCOM-ICRSQ.
  ENDIF.

*  CLEAR: g_count.
*  LOOP AT xztitcrp.
*    g_tabix = sy-tabix.
*    SELECT SUM( ccmng )
*      INTO l_ccmng
*      FROM ztitccp
*     WHERE iccno  EQ  xztitcrp-iccno
*       AND iccit  EQ  xztitcrp-iccit
*       AND iccsq  EQ  ztisscrcom-icrsq.
*    IF l_ccmng GE xztitcrp-ccmng.
*      DELETE xztitcrp INDEX g_tabix.
*      CONTINUE.
*    ELSE.
*      ADD 1 TO g_count.
*      xztitcrp-ccmng =  xztitcrp-ccmng - l_ccmng.
*      xztitcrp-ccmngl =  xztitcrp-ccmng.
*      xztitcrp-ccmngs =  l_ccmng.
*      MODIFY xztitcrp INDEX g_tabix.
*    ENDIF.
*  ENDLOOP.
*  IF g_count EQ 0.
*    MESSAGE e443 WITH ztisscrcom-icrno ztisscrcom-icrsq.
*  ENDIF.
*
  IF ZTISSCRCOM-ICRSQ NE '00'.
    ZTISSCRCOM-ICCSQ = ZTISSCRCOM-ICRSQ - 1.
    SELECT SINGLE *
      INTO ZTITCCK_OLD
      FROM ZTITCCK
     WHERE ICCNO EQ ZTISSCRCOM-ICRNO
       AND ICCSQ EQ ZTISSCRCOM-ICCSQ.

    MOVE-CORRESPONDING : ZTITCCK_OLD TO ZTITCCK,
                         ZTITCRK     TO ZTITCCK.
  ELSE.
    MOVE-CORRESPONDING : ZTITCRK     TO ZTITCCK.
  ENDIF.

  REFRESH: XZTITCCP, YZTITCCP.
  LOOP AT XZTITCRP.
    MOVE-CORRESPONDING : XZTITCRP TO G_TC_2130_WA,
                         XZTITCRP TO XZTITCCP.
    APPEND G_TC_2130_WA TO IT_TAB.
    APPEND XZTITCCP.
  ENDLOOP.

  REFRESH: XZTITCC1, YZTITCC1.
  LOOP AT XZTITCR1.
    MOVE-CORRESPONDING XZTITCR1 TO XZTITCC1.
    APPEND XZTITCC1.
  ENDLOOP.

  REFRESH: XZTITCC2, YZTITCC2.
  LOOP AT XZTITCR2.
    MOVE-CORRESPONDING XZTITCR2 TO XZTITCC2.
    APPEND XZTITCC2.
  ENDLOOP.

  REFRESH: XZTITCC3, YZTITCC3.
  LOOP AT XZTITCR3.
    MOVE-CORRESPONDING XZTITCR3 TO XZTITCC3.
    APPEND XZTITCC3.
  ENDLOOP.

*-> 기능개선 XXXXX : xztitcr5 -> xztitcc4
  REFRESH: XZTITCC4, YZTITCC4.
  LOOP AT XZTITCR5.
    MOVE-CORRESPONDING XZTITCR5 TO XZTITCC4.
    APPEND XZTITCC4.
  ENDLOOP.
*<- 기능개선 XXXXX

  REFRESH: G_TC_2211_ITAB, G_TC_2212_ITAB, G_TC_2212_1_ITAB,
           G_TC_2212_2_ITAB . "기능개선 XXXXX

  LOOP AT XZTITCC1.
    MOVE-CORRESPONDING XZTITCC1 TO G_TC_2211_WA.
    APPEND G_TC_2211_WA TO G_TC_2211_ITAB.
  ENDLOOP.

  LOOP AT XZTITCC2.
    MOVE-CORRESPONDING XZTITCC2 TO G_TC_2212_WA.
    APPEND G_TC_2212_WA TO G_TC_2212_ITAB.
  ENDLOOP.

  LOOP AT XZTITCC3.
    MOVE-CORRESPONDING XZTITCC3 TO G_TC_2212_1_WA.
    APPEND G_TC_2212_1_WA TO G_TC_2212_1_ITAB.
  ENDLOOP.

*-> 기능개선 XXXXX
  LOOP AT XZTITCC4.
    MOVE-CORRESPONDING XZTITCC4 TO G_TC_2212_2_WA.
    APPEND G_TC_2212_2_WA TO G_TC_2212_2_ITAB.
  ENDLOOP.
*<- 기능개선 XXXXX
ENDFORM.                    " GET_CUSTOM_IMPRT_REQ

*&---------------------------------------------------------------------*
*&      Form  applications_print
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM APPLICATIONS_PRINT .
*      PERFORM  p8111_edi_item_table_read.
  CASE G_MODE.
    WHEN C_CHARC OR C_CHARM.
*> 공용 대화상자(메시지 통일).
      CALL FUNCTION 'Z_TI_POPUP_TO_CONFIRM_MESSAGE'
        EXPORTING
          XMODE  = C_CHARZ
        IMPORTING
          ANSWER = G_ANSWER.
    WHEN OTHERS.
      G_ANSWER = C_Y.
  ENDCASE.

  IF G_ANSWER EQ C_Y.
    IF G_MODE EQ C_CHARC OR
       G_MODE EQ C_CHARM.
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
*&      Form  get_custom_exchange_rate
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_CUSTOM_EXCHANGE_RATE .

  DATA: L_DATE      LIKE SY-DATUM,
        L_DATET(10) TYPE C.

  CLEAR: ZTSTIG6, GS_ZTSTIG6_USD.

  L_DATE = ZTITCCK-CDRDT.
  IF L_DATE IS INITIAL.
    L_DATE = SY-DATLO.
  ENDIF.
  WRITE: L_DATE TO L_DATET.

  SELECT SINGLE *
    FROM ZTSTIG6
   WHERE FCURR EQ ZTITCCK-CPYATC
     AND TCURR EQ T001-WAERS
     AND GDATU EQ ( SELECT MAX( GDATU )
                      FROM ZTSTIG6
                     WHERE FCURR EQ ZTITCCK-CPYATC
                       AND TCURR EQ T001-WAERS
                       AND GDATU LE L_DATE ).
  IF SY-SUBRC EQ 0.
    IF ZTITCCK-CPYRT IS INITIAL.
      ZTITCCK-CPYRT = ZTSTIG6-UKURS.
    ENDIF.
  ELSE.
    IF SY-DYNNR EQ C_SCR0100.
      MESSAGE S433 WITH  ZTITCCK-CPYATC L_DATET.
      EXIT.
    ELSE.
      MESSAGE I433 WITH  ZTITCCK-CPYATC L_DATET.
    ENDIF.
  ENDIF.

*> USD 환율.
  IF ZTITCCK-CPYATC EQ 'USD'.
    GS_ZTSTIG6_USD = ZTSTIG6.
  ELSE.
    SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF GS_ZTSTIG6_USD
      FROM ZTSTIG6
     WHERE FCURR EQ 'USD'
       AND TCURR EQ T001-WAERS
       AND GDATU EQ ( SELECT MAX( GDATU )
                        FROM ZTSTIG6
                       WHERE FCURR EQ 'USD'
                         AND TCURR EQ T001-WAERS
                         AND GDATU LE L_DATE ).
    IF SY-SUBRC NE 0.
      IF SY-DYNNR EQ C_SCR0100.
        MESSAGE S433 WITH  'USD' L_DATET.
      ELSE.
        MESSAGE I433 WITH  'USD' L_DATET.
      ENDIF.
    ENDIF.
  ENDIF.
*  ENDIF.

ENDFORM.                    " get_custom_exchange_rate
*&---------------------------------------------------------------------*
*&      Form  calc_customs_amount
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALC_CUSTOMS_AMOUNT .

  DATA: L_CIPAT     TYPE ZTICIPAT,
        L_DATE      TYPE D,
        L_DATET(10) TYPE C,
        L_CCUAK     TYPE ZTICCUAK,
        L_CCUAK_SUM TYPE ZTICCUAK,
        L_CCUAT_SUM TYPE ZTICCUAU,
        L_CDUTX_SUM TYPE ZTICDUTX,
        L_CADTX_SUM TYPE ZTICADTX,
        L_CTSAK_SUM TYPE ZTICTSAK,
        L_CCUAK_H   TYPE ZTICCUAK.

  CHECK NOT ZTSTIG6-UKURS IS INITIAL.

  L_DATE = ZTITCCK-CDRDT.
  IF L_DATE IS INITIAL.
    L_DATE = SY-DATLO.
  ENDIF.
*
*> 외화운임 --> 원화운임 .
*> USD 운임--->원화.
  IF NOT ZTITCCK-CFRATU IS INITIAL AND
         ZTITCCK-CFRAT  IS INITIAL.
    PERFORM  CONVERT_TO_LOCAL_CURRENCY_COM  USING ZTITCCK-CCUAUC
                                                  T001-WAERS
                                                  GS_ZTSTIG6_USD-UKURS
                                                  L_DATE
                                                  ZTITCCK-CFRATU
                                                  ZTITCCK-CFRAT.
  ENDIF.

*> 원화금액으로 환산.(결제금액 원화) --> 해당
  PERFORM  CONVERT_TO_LOCAL_CURRENCY_COM  USING ZTITCCK-CPYATC
                                               T001-WAERS
                                               ZTITCCK-CPYRT
                                               L_DATE
                                               ZTITCCK-CPYAT
                                               L_CCUAK_H.

  LOOP AT G_TC_2211_ITAB INTO G_TC_2211_WA.
    G_TABIX = SY-TABIX.

    CLEAR: L_CCUAK.
    LOOP AT G_TC_2212_ITAB INTO G_TC_2212_WA
                   WHERE CSSEQ EQ G_TC_2211_WA-CSSEQ.
      G_TABIX1 = SY-TABIX.

*> 원화금액으로 환산.(결제금액 원화) --> 해당
      PERFORM  CONVERT_TO_LOCAL_CURRENCY_COM  USING ZTITCCK-CPYATC
                                                    T001-WAERS
                                                    ZTITCCK-CPYRT
                                                    L_DATE
                                                    G_TC_2212_WA-CPYAT
                                                    G_TC_2212_WA-CSQAK.

*> 행별 과세가격 - 원화.[
*  (결제외화금액 * 환율) + 운임원화 + 보험료 원화
      IF NOT L_CCUAK_H IS INITIAL.
        G_TC_2212_WA-CSQAK = G_TC_2212_WA-CSQAK +
             ( ZTITCCK-CFRAT * ( G_TC_2212_WA-CSQAK / L_CCUAK_H ) ) +
             ( ZTITCCK-CIPAT * ( G_TC_2212_WA-CSQAK / L_CCUAK_H ) ).

        ADD G_TC_2212_WA-CSQAK TO L_CCUAK.
      ENDIF.
      MODIFY G_TC_2212_ITAB FROM G_TC_2212_WA INDEX G_TABIX1.
    ENDLOOP.

*-------------------------------------------------------------
*> 과세가격 - 미화.
*  ( 과세가격(원화) / 미화 고시환율 ) --> 소수점 이하 절사.
*-------------------------------------------------------------
*> 원화금액으로 환산.(결제금액 원화) --> 해당
    G_TC_2211_WA-CSQAK = L_CCUAK.
    PERFORM  CONVERT_TO_LOCAL_CURRENCY_COM  USING T001-WAERS
                                                  ZTITCCK-CCUAUC
                                                  GS_ZTSTIG6_USD-UKURS
                                                  L_DATE
                                                  L_CCUAK
                                                  G_TC_2211_WA-CSQAT.

    IF ZTITCCK-CINCO EQ 'CIF'.  "CIF 일경우 소수점 1자리에서 반올림
      G_TC_2211_WA-CSQAT = G_TC_2211_WA-CSQAT / 100.
      G_TC_2211_WA-CSQAT = G_TC_2211_WA-CSQAT * 100.
    ELSE.
      G_TC_2211_WA-CSQAT = TRUNC( G_TC_2211_WA-CSQAT ).
    ENDIF.
**-------------------------------------------------------------
**> 관세.  --> 원단위 이하 절사
**  ( 과세가격(원화) * 관세율 ) .
**> 부가세.--> 소수점 이하 절사.
**  ( 과세가격(원화) + 관세(소수점 이하 절사) ) -
**-------------------------------------------------------------
    G_TC_2211_WA-CSDAK = G_TC_2211_WA-CSQAK *
                       ( G_TC_2211_WA-CSDRT / 100 ).

**---> 관세감면율 적용 2001.12.05 KSB MODIFY.
*     IF NOT IT_ZSIDSHS-ZFRDRT IS INITIAL.
*        IT_ZSIDSHS-ZFCUAMT = IT_ZSIDSHS-ZFCUAMT *
*                         ( 1 - ( IT_ZSIDSHS-ZFRDRT / 100 ) ).
*     ENDIF.

*>부가세 계산용(원단위 이하 절사) / 관세(10원단위 이하 절사).
    G_TC_2211_WA-CSDXA = TRUNC( G_TC_2211_WA-CSDAK ).  ">부가세 계산용.

*> 부가세 과세과표.
    G_TC_2211_WA-CSDTA = G_TC_2211_WA-CSDXA + G_TC_2211_WA-CSQAK.
    G_TC_2211_WA-CSDXA = G_TC_2211_WA-CSDTA / 10.
*> 부가세.
    G_TC_2211_WA-CSDXA = TRUNC( G_TC_2211_WA-CSDXA * 10 ) / 10.
*     IT_ZSIDSHS-ZFCUAMT = TRUNC( W_TOT_GAM / 10 ) * 10. ">관세.
*    W_TOT_GAM = IT_ZSIDSHS-ZFCUAMT.

    ADD G_TC_2211_WA-CSQAK TO L_CCUAK_SUM.
    ADD G_TC_2211_WA-CSQAT TO L_CCUAT_SUM.

    ADD G_TC_2211_WA-CSDAK TO L_CDUTX_SUM.  ">관세.
    ADD G_TC_2211_WA-CSDXA TO L_CADTX_SUM.  ">부가세.
    ADD G_TC_2211_WA-CSDTA TO L_CTSAK_SUM.  ">과세과표.

    MODIFY G_TC_2211_ITAB FROM G_TC_2211_WA INDEX G_TABIX.

  ENDLOOP.

  ZTITCCK-CCUAK = L_CCUAK_H + ZTITCCK-CFRAT + ZTITCCK-CIPAT .
  IF L_CCUAK_SUM NE ZTITCCK-CCUAK.
    IF ZTITCCK-CCUAK GT L_CCUAK_SUM.
      ZTITCCK-CCUAK = ZTITCCK-CCUAK - ( ZTITCCK-CCUAK - L_CCUAK_SUM ).
    ELSE.
      ZTITCCK-CCUAK = ZTITCCK-CCUAK + ( L_CCUAK_SUM - ZTITCCK-CCUAK ).
    ENDIF.
  ENDIF.

  IF L_CCUAT_SUM NE ZTITCCK-CCUAU.
    IF ZTITCCK-CCUAU GT L_CCUAT_SUM.
      ZTITCCK-CCUAU = ZTITCCK-CCUAU - ( ZTITCCK-CCUAU - L_CCUAT_SUM ).
    ELSE.
      ZTITCCK-CCUAU = ZTITCCK-CCUAU + ( L_CCUAT_SUM - ZTITCCK-CCUAU ).
    ENDIF.
  ENDIF.

  ZTITCCK-CDUTX = L_CDUTX_SUM.
  ZTITCCK-CADTX = L_CADTX_SUM.
  ZTITCCK-CTSAK = L_CTSAK_SUM.

*> 관세사 수수료.
  MOVE-CORRESPONDING ZTITCCK TO ZTITCRK.
  CALL FUNCTION 'Z_TI_CALC_CUSTOMS_CHARGES'
    CHANGING
      CH_ZTITCRK = ZTITCRK.

  MOVE ZTITCRK-CCHCG TO ZTITCCK-CCHCG.

*> 초기값 Setting.
  READ TABLE G_TC_2211_ITAB INTO G_TC_2211_WA INDEX 1.
  IF SY-SUBRC EQ 0.
    REFRESH: G_TC_2212_TMP, G_TC_2212_1_TMP.
    G_CSSEQ = G_TC_2211_WA-CSSEQ.
    MOVE-CORRESPONDING G_TC_2211_WA TO ZTISCC01.
    LOOP AT G_TC_2212_ITAB INTO G_TC_2212_WA
                           WHERE CSSEQ EQ ZTISCC01-CSSEQ.
      APPEND G_TC_2212_WA TO G_TC_2212_TMP.
    ENDLOOP.
    LOOP AT G_TC_2212_1_ITAB INTO G_TC_2212_1_WA
                           WHERE CSSEQ EQ ZTISCC01-CSSEQ.
      APPEND G_TC_2212_1_WA TO G_TC_2212_1_TMP.
    ENDLOOP.
  ELSE.
    CLEAR G_CSSEQ.
  ENDIF.

ENDFORM.                    " calc_customs_amount
*&---------------------------------------------------------------------*
*&      Form  set_row_columns_refresh
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_ROW_COLUMNS_REFRESH .
  DATA: L_ANSWER TYPE C,
        L_CSSEQ  TYPE ZTICSSEQ,
        L_CMSEQ  TYPE ZTICMSEQ,
        L_DATE   TYPE D.

  IF SY-DYNNR NE C_SCR0100.
    PERFORM  REFRESH_CONFIRM_MESSAGE  USING L_ANSWER.
    CHECK : L_ANSWER EQ 'J'.
  ENDIF.

  REFRESH: G_TC_2211_ITAB,
           G_TC_2212_ITAB,
           G_TC_2212_1_ITAB,
           G_TC_2212_2_ITAB. "기능개선 XXXXX

  L_DATE = ZTITCCK-CDCDT.
  IF L_DATE IS INITIAL.
    L_DATE = SY-DATLO.
  ENDIF.

  SELECT MATNR BRGEW NTGEW GEWEI VOLUM VOLEH
    INTO CORRESPONDING FIELDS OF TABLE IT_MATNR
    FROM MARA
     FOR ALL ENTRIES IN IT_TAB
   WHERE MATNR EQ IT_TAB-MATNR.

  LOOP AT IT_TAB INTO G_TC_2130_WA.

    CLEAR: G_TC_2211_WA,
           G_TC_2212_WA,
           G_TC_2212_1_WA,
           G_TC_2212_2_WA.
*> 란사항 체크.
*    SELECT SINGLE SINGLE
    MOVE: G_TC_2130_WA-STAWN TO G_TC_2211_WA-CSSID,   ">HS Code
          1                  TO G_TC_2211_WA-CSSZN,   ">란 총규격수.
          'USD'              TO G_TC_2211_WA-CSQATC,  ">외화통화.
          T001-WAERS         TO G_TC_2211_WA-CSKRW,   ">원화통화.
          G_TC_2130_WA-REFWR TO G_TC_2211_WA-CPYAT,  ">란 과세가격(외화)
          'KG'               TO G_TC_2211_WA-CSNWTU, ">란 순중량단위
          G_TC_2130_WA-MEINS TO G_TC_2211_WA-CSNODU, ">란 수량단위.
          G_TC_2130_WA-MEINS TO G_TC_2211_WA-CSREDU, ">환급단위.
          G_TC_2130_WA-REFWR TO G_TC_2211_WA-CPYAT,  ">결제금액.
          G_TC_2130_WA-CCMNG TO G_TC_2211_WA-CSNOD.  ">란 수량.

    READ TABLE IT_MATNR WITH KEY MATNR = G_TC_2130_WA-MATNR.
    IF SY-SUBRC EQ 0.
      IF NOT IT_MATNR-GEWEI IS INITIAL.
        MOVE IT_MATNR-GEWEI TO G_TC_2211_WA-CSNWTU.
      ENDIF.
      G_TC_2211_WA-CSNOD = IT_MATNR-NTGEW.

    ENDIF.

*          g_tc_2130_wa-to g_tc_2211_wa-CSCLD,  ">란 원산지국가부호
**g_tc_2130_wa-to g_tc_2211_wa-CSDNM,  ">란 품명.
*g_tc_2130_wa-to g_tc_2211_wa-CSIDN,  ">란 거래품명.
*g_tc_2130_wa-to g_tc_2211_wa-CSDMC,  ">란 상표코드.
*g_tc_2130_wa-to g_tc_2211_wa-CSDMN,  ">란 상표명.
*g_tc_2130_wa-to g_tc_2211_wa-CSQAK,  ">란 과세가격(원화)
*g_tc_2130_wa-to g_tc_2211_wa-CSREDU, ">란 환급물량 단위
*g_tc_2130_wa-to g_tc_2211_wa-CSRED,  ">란 환급물량
*g_tc_2130_wa-to g_tc_2211_wa-CSDUY,  ">란 관세구분
*g_tc_2130_wa-to g_tc_2211_wa-CSNDN,  ">란 총요건수
*g_tc_2130_wa-to g_tc_2211_wa-CSDRT,  ">란 관세율(%)
*g_tc_2130_wa-to g_tc_2211_wa-CSPRX,  ">란 관세단위당세액
*g_tc_2130_wa-to g_tc_2211_wa-CSDAK,  ">란 관세액(원화)
*g_tc_2130_wa-to g_tc_2211_wa-CSDIY,  ">란 감면분납구분
*g_tc_2130_wa-to g_tc_2211_wa-CSDII,  ">란 감면분납부호
*g_tc_2130_wa-to g_tc_2211_wa-CSVRT,  ">란 감면/분납(율)
*g_tc_2130_wa-to g_tc_2211_wa-CSVAK,  ">란 감면액(원화)
*g_tc_2130_wa-to g_tc_2211_wa-CSITX,  ">란 내국세구분
*g_tc_2130_wa-to g_tc_2211_wa-CSIID,  ">란 내국세부호
*g_tc_2130_wa-to g_tc_2211_wa-CSIRT,  ">란 내국세세율(%)
*g_tc_2130_wa-to g_tc_2211_wa-CSIAK,  ">란 내국세액(원화)
*g_tc_2130_wa-to g_tc_2211_wa-CSISX,  ">란 내국세특소세면세부호
*g_tc_2130_wa-to g_tc_2211_wa-CSSRC,  ">란 특수세액계산근거
*g_tc_2130_wa-to g_tc_2211_wa-CSETX,  ">란 교육세구분
*g_tc_2130_wa-to g_tc_2211_wa-CSEAK,  ">란 교육세세액(원화)
*g_tc_2130_wa-to g_tc_2211_wa-CSGTX,  ">란 농특세구분
*g_tc_2130_wa-to g_tc_2211_wa-CSGAK,  ">란 농특세(원화)
*g_tc_2130_wa-to g_tc_2211_wa-CSDTX,  ">란 부가세구분
*g_tc_2130_wa-to g_tc_2211_wa-CSDFI,  ">란 부가세감면부호
*g_tc_2130_wa-to g_tc_2211_wa-CSDTA,  ">란 부가세과세과표(원화)
*g_tc_2130_wa-to g_tc_2211_wa-CSDFA,  ">란 부가세면세과표(원화)
*g_tc_2130_wa-to g_tc_2211_wa-CSDXA,  ">란 부가세(원화)
*g_tc_2130_wa-to g_tc_2211_wa-CSAMO1, ">란 사후확인기관
*g_tc_2130_wa-to g_tc_2211_wa-CSAMO2, ">란 사후확인기관
*g_tc_2130_wa-to g_tc_2211_wa-CSAMO3. ">란 사후확인기관

    COLLECT G_TC_2211_WA INTO G_TC_2211_ITAB.
  ENDLOOP.

  CLEAR: L_CSSEQ.
  LOOP AT G_TC_2211_ITAB INTO G_TC_2211_WA.
    G_TABIX = SY-TABIX.
    ADD 1 TO L_CSSEQ.
    G_TC_2211_WA-CSSEQ = L_CSSEQ.

    SELECT SINGLE TEXT1
      INTO G_TC_2211_WA-CSDNM  ">란 품명.
      FROM T604T
     WHERE SPRAS EQ SY-LANGU
       AND LAND1 EQ T001-LAND1
       AND STAWN EQ G_TC_2211_WA-CSSID.
    IF SY-SUBRC EQ 0.
      G_TC_2211_WA-CSIDN = G_TC_2211_WA-CSDNM. ">란 거래품명.
    ENDIF.

    SELECT SINGLE *
      FROM ZTSTIGH
     WHERE STAWN EQ G_TC_2211_WA-CSSID
       AND GDATU EQ ( SELECT MAX( GDATU )
                        FROM ZTSTIGH
                       WHERE STAWN EQ G_TC_2211_WA-CSSID
                         AND GDATU LE L_DATE ).

    IF SY-SUBRC EQ 0.
      MOVE: ZTSTIGH-TAXCD TO G_TC_2211_WA-CSDUY,
            ZTSTIGH-BSICR TO G_TC_2211_WA-CSDRT.
    ELSE.
      SELECT CSDUY CSDRT
        INTO (G_TC_2211_WA-CSDUY, G_TC_2211_WA-CSDRT)
        FROM ZTITCC1 UP TO 1 ROWS
       WHERE ICCNO EQ ( SELECT MAX( ICCNO )
                          FROM ZTITCC1
                         WHERE CSSID EQ G_TC_2211_WA-CSSID )
         AND CSSID EQ G_TC_2211_WA-CSSID.
      ENDSELECT.
    ENDIF.

    CLEAR: L_CMSEQ.
    LOOP AT IT_TAB INTO G_TC_2130_WA
                   WHERE STAWN EQ G_TC_2211_WA-CSSID.
      ADD 1 TO L_CMSEQ.
      CLEAR: G_TC_2212_WA.
      MOVE: L_CSSEQ                  TO G_TC_2212_WA-CSSEQ,
            L_CMSEQ                  TO G_TC_2212_WA-CMSEQ,
            G_TC_2130_WA-REFWR       TO G_TC_2212_WA-CPYAT, ">외화금액.
            G_TC_2130_WA-TXZ01       TO G_TC_2212_WA-CMTE1,
            G_TC_2130_WA-MEINS       TO G_TC_2212_WA-CMNUMU,
            G_TC_2130_WA-CCMNG       TO G_TC_2212_WA-CMNUM,
            G_TC_2130_WA-ICCIT       TO G_TC_2212_WA-ICCIT,
            G_TC_2130_WA-IBLNO       TO G_TC_2212_WA-IBLNO,
            G_TC_2130_WA-IBLIT       TO G_TC_2212_WA-IBLIT.
      WRITE G_TC_2130_WA-MATNR       TO G_TC_2212_WA-CMRS1.
      APPEND G_TC_2212_WA TO G_TC_2212_ITAB.
    ENDLOOP.

    MODIFY G_TC_2211_ITAB FROM G_TC_2211_WA.
  ENDLOOP.

  DESCRIBE TABLE G_TC_2211_ITAB LINES G_LINE.

  ZTITCCK-CTSEQ = G_LINE.

ENDFORM.                    " set_row_columns_refresh
*&---------------------------------------------------------------------*
*&      Form  refresh_confirm_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM REFRESH_CONFIRM_MESSAGE  USING    P_ANSWER.

  DATA: L_CANCEL_DISPLAY.
*>------------------------------------------------------
*> MESSAGE POPUP용.
*>------------------------------------------------------
  DATA: BEGIN OF LS_POP,
          TITEL     LIKE SPOP-TITEL,
          DIAGNOSE1 LIKE SPOP-DIAGNOSE1,
          DIAGNOSE2 LIKE SPOP-DIAGNOSE2,
          DIAGNOSE3 LIKE SPOP-DIAGNOSE3,
          TEXTLINE1 LIKE SPOP-TEXTLINE1,
          TEXTLINE2 LIKE SPOP-TEXTLINE2,
          TEXTLINE3 LIKE SPOP-TEXTLINE3,
          OPTION1   LIKE SPOP-VAROPTION1,
          OPTION2   LIKE SPOP-VAROPTION2,
          DEFAULT,             "defaultoption fuer Confirm_step
          ANSWER,
        END OF LS_POP.

  CLEAR : LS_POP, P_ANSWER, L_CANCEL_DISPLAY.

  MOVE: '기존에 입력된 란/행 데이타는 손실됩니다.' TO LS_POP-DIAGNOSE1,
        '란/행 사항을 Refresh 하시겠습니까?'       TO LS_POP-TEXTLINE1,
        '란/행 Refresh 확인'                       TO LS_POP-TITEL.


  CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
    EXPORTING
*     DEFAULTOPTION  = 'Y'
      DIAGNOSETEXT1  = LS_POP-DIAGNOSE1
*     DIAGNOSETEXT2  = ls_POP-DIAGNOSE2
*     DIAGNOSETEXT3  = ' '
      TEXTLINE1      = LS_POP-TEXTLINE1
      TEXTLINE2      = LS_POP-TEXTLINE2
      TITEL          = LS_POP-TITEL
*     START_COLUMN   = 25
*     START_ROW      = 6
      CANCEL_DISPLAY = L_CANCEL_DISPLAY
    IMPORTING
      ANSWER         = LS_POP-ANSWER
    EXCEPTIONS
      OTHERS         = 1.

  P_ANSWER = LS_POP-ANSWER.

ENDFORM.                    " refresh_confirm_message
*&---------------------------------------------------------------------*
*&      Module  check_input_values_scr2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_VALUES_SCR2121 INPUT.

  IF G_MODE EQ C_CHARC OR G_MODE EQ C_CHARM.
    CALL FUNCTION 'Z_TI_CALC_CUSTOMS_PAYMENT_DATE'
      CHANGING
        CH_ZTITCCK = ZTITCCK.
  ENDIF.

ENDMODULE.                 " check_input_values_scr2121  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_value_scr2124  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_VALUE_SCR2124 INPUT.

  IF G_MODE EQ C_CHARC OR G_MODE EQ C_CHARM.
    CALL FUNCTION 'Z_TI_CALC_CUSTOMS_PAYMENT_DATE'
      CHANGING
        CH_ZTITCCK = ZTITCCK.
  ENDIF.
ENDMODULE.                 " check_input_value_scr2124  INPUT
*&---------------------------------------------------------------------*
*&      Form  create_bonded_area_out
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CREATE_BONDED_AREA_OUT .

  DATA: L_SUBRC  LIKE  SY-SUBRC.
  DATA: L_IBONO  TYPE  ZTIIBONO.
  DATA: L_IBINO  TYPE  ZTIIBINO.
  DATA: L_BOUDT(10).
  DATA: L_BKTXT  TYPE  BKTXT.

  DATA: L_IF_NULL TYPE REF TO IF_MESSAGE_OBJ_MM.

*  BREAK-POINT.

  SELECT MAX( IBONO )
    INTO L_IBONO
    FROM ZTITBOK
   WHERE IBLNO EQ ZTITCCK-IBLNO.

  CHECK L_IBONO IS INITIAL.

  SELECT MAX( IBINO )
    INTO L_IBINO
    FROM ZTITBIK
   WHERE IBLNO EQ ZTITCCK-IBLNO.

  CHECK NOT L_IBINO IS INITIAL.

  REFRESH: BDCDATA.

  CLEAR: SESSION.
  CTU_PARAMS-DISMODE  = 'E'. ">처리모드
  CTU_PARAMS-UPDMODE  = 'S'. ">갱신모드
  CTU_PARAMS-CATTMODE = ' '. ">CATT 모드...
  CTU_PARAMS-DEFSIZE  = ' '. ">기본화면 크기
  CTU_PARAMS-RACOMMIT = 'X'.
  CTU_PARAMS-NOBINPT  = ' ' .
  CTU_PARAMS-NOBIEND  = ' '.

* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

*> 초기화면.
  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR4700'          '0100',
         ' ' 'ZTISSCRCOM-IBINO'  L_IBINO,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.
*> 세부화면.
  WRITE: ZTITCCK-CDRDT TO L_BOUDT.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR4700'         '2000',
         ' ' 'ZTITBOK-BOUDT'    L_BOUDT,
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
**
  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPLSPO1'         '0300',
         ' ' 'BDC_OKCODE'       '=YES'.
**
  SET PARAMETER ID 'ZTIIBONO'  FIELD SPACE.

  PERFORM BDC_TRANSACTION USING 'ZTIT471' L_SUBRC.

  GET PARAMETER ID 'ZTIIBONO'  FIELD L_IBONO.
*
  IF L_SUBRC EQ 0.
    MESSAGE S470 WITH L_IBONO.
    PERFORM SET_RETURN_MESSAGE_FILL USING SY-MSGTY.
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
  ENDIF.
*
ENDFORM.                    " create_bonded_area_out
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
