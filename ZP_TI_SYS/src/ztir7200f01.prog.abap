************************************************************************
* Title         :  ZTIR7200F01                                         *
*                                                                      *
* Description   : 수입 인수증관리 Subroutine Include                   *
*                                                                      *
* Creation Date : 2003/07/11                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
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
*&      Form  DISPLAY_CC_ORDER
*&---------------------------------------------------------------------*
FORM DISPLAY_CC_ORDER  USING    P_NODE_KEY.

*  READ TABLE it_ztisccit WITH KEY INDEX = p_node_key(10).
*  IF sy-subrc EQ 0.
*    PERFORM  display_cc_document    USING it_ztisccit-iccno.
*  ELSE.
*    MESSAGE s903.
*  ENDIF.
*
ENDFORM.                    " DISPLAY_cc_ORDER
*&---------------------------------------------------------------------*
*&      Form  set_request_of_import_data
*&---------------------------------------------------------------------*
*       수입의뢰 아이템을 생성함.
*----------------------------------------------------------------------*
FORM SET_REQUEST_OF_IMPORT_DATA TABLES P_IT_TAB    LIKE IT_TAB
                                USING  P_ZTIVPO00 STRUCTURE ZTIVPO00
                                       P_ZTITRQK STRUCTURE ZTITRQK
                                       P_ZTITRQS STRUCTURE ZTITRQS
                                       P_PO_WA    STRUCTURE IT_PO.

  MOVE-CORRESPONDING P_ZTIVPO00 TO : P_IT_TAB, P_ZTITRQK, P_ZTITRQS.

*  MOVE: p_po_wa-rqmng  TO p_it_tab-blmng,
*        p_po_wa-rqmngs TO p_it_tab-blmngs,
*        p_po_wa-rqmngl TO p_it_tab-blmngl.
*
*  MOVE: sy-uname TO p_it_tab-cnam,
*        sy-datlo TO p_it_tab-cdat,
*        sy-timlo TO p_it_tab-ctme,
*        sy-uname TO p_it_tab-unam,
*        sy-datlo TO p_it_tab-udat,
*        sy-timlo TO p_it_tab-utme.
*
*  APPEND p_it_tab.
*
**>아이템 번호를 생성함.
*  PERFORM set_item_number_build TABLES p_it_tab
*                                USING  ZTITBLK.
*
*  PERFORM get_others_text_by_master_data.
*
ENDFORM.                    " set_request_of_import_data
*&---------------------------------------------------------------------*
*&      Form  set_good_receipt_data
*&---------------------------------------------------------------------*
*       B/L 아이템을 생성함.
*----------------------------------------------------------------------*
FORM SET_GOOD_RECEIPT_DATA      TABLES P_IT_TAB   LIKE IT_TAB
                                USING  P_ZTIVCC00 STRUCTURE ZTIVCC00
                                       P_ZTITGRK STRUCTURE ZTITGRK
*                                       p_ztisccit STRUCTURE
*it_ztisccit.
                                       P_ZTISCCIT.
  CLEAR: P_IT_TAB.

  MOVE-CORRESPONDING P_ZTIVCC00 TO : P_IT_TAB, P_ZTITGRK.

  MOVE: P_ZTIVCC00-ICCNO  TO P_ZTITGRK-ICCNO.
  MOVE: P_ZTIVCC00-IBLNO  TO P_ZTITGRK-IBLNO.


*  MOVE: p_ztisccit-grmng  TO p_it_tab-grmng,
*        p_ztisccit-grmngs TO p_it_tab-grmngs,
*        p_ztisccit-grmngl TO p_it_tab-grmngl.
*
*  MOVE: sy-uname TO p_it_tab-cnam,
*        sy-datlo TO p_it_tab-cdat,
*        sy-timlo TO p_it_tab-ctme,
*        sy-uname TO p_it_tab-unam,
*        sy-datlo TO p_it_tab-udat,
*        sy-timlo TO p_it_tab-utme.

*  IF NOT  p_it_tab-ebeln IS INITIAL.
** 구매오더 정보 Read.
*    SELECT SINGLE menge werks lgort matnr txz01
*                  loekz elikz bprme bpumz bpumn umrez
*                  umren netpr peinh uebto uebtk untto
*    INTO CORRESPONDING FIELDS OF p_it_tab
*      FROM ekpo
*     WHERE ebeln  EQ  p_it_tab-ebeln
*       AND ebelp  EQ  p_it_tab-ebelp.
**> 수입의뢰 정보 Read.
*    IF NOT p_it_tab-reqno IS INITIAL.
*      SELECT SINGLE rqmng
*        INTO p_it_tab-rqmng
*        FROM ZTIvrq00
*       WHERE reqno   EQ  p_it_tab-reqno
*         AND reqit   EQ  p_it_tab-reqit.
*
*      SELECT  SUM( blmng ) INTO p_it_tab-blmngs FROM ZTIvbl00
*       WHERE  reqno       EQ  p_it_tab-reqno
*         AND  reqit       EQ  p_it_tab-reqit
*         AND NOT ( iblno  EQ  p_it_tab-iblno
*         AND       iblit  EQ  p_it_tab-iblit ).
***> 초과납품허용치.
**        if not ZTItblit-UEBTO is initial.
**           ZTItblit-rqmng = ZTItblit-rqmng +
**                          ( ZTItblit-rqmng * ZTItblit-UEBTO ) / 100.
**        endif.
**        if not ZTItblit-UEBTK is initial.
**
**        endif.
*      p_it_tab-blmngl =  p_it_tab-rqmng - p_it_tab-blmngs.
*    ENDIF.
*
*    IF p_it_tab-blmngl LE 0.
*      p_it_tab-blmngl = 0.
*    ENDIF.
*  ENDIF.
*  IF NOT p_it_tab-rsnum IS INITIAL.
**RSPOS
**RSART
*  ENDIF.
*
  APPEND P_IT_TAB.
*
**>아이템 번호를 생성함.
*  PERFORM set_item_number_build TABLES p_it_tab
*                                USING  p_ZTITBLK.
*
  PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.

ENDFORM.                    " set_good_receipt_data

*&---------------------------------------------------------------------*
*&      Form  get_and_check_po_data
*&---------------------------------------------------------------------*
*       Get 구매오더 데이타.
*----------------------------------------------------------------------*
FORM GET_AND_CHECK_PO_DATA  USING    P_ICCNO
                                     P_ICCIT
                                     P_MODIFY
                                     P_ZTIVCC00 STRUCTURE ZTIVCC00
                                     P_COUNT.

  CLEAR: P_ZTIVCC00.

  SELECT SINGLE * INTO P_ZTIVCC00
    FROM ZTIVCC00
   WHERE ICCNO EQ P_ICCNO
     AND ICCIT EQ P_ICCIT.

  IF SY-SUBRC EQ 0.
**>Vendor 체크.
*    IF ZTITGRK-lifnr     NE p_ZTIvCC00-lifnr AND
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
*
*> Lock Object
    PERFORM  SET_CC_LOCK_OBJECT  USING P_ICCNO
                                       '00'
                                       P_ICCIT
                                       C_LOCK
                                       C_SUCCESS
                                       P_MODIFY.
  ELSE.
    MESSAGE S019(06) WITH P_ICCNO.
    P_MODIFY = C_TRUE.
    EXIT.
  ENDIF.

ENDFORM.                    " get_and_check_po_data
*&---------------------------------------------------------------------*
*&      Form  get_and_check_cc_data
*&---------------------------------------------------------------------*
*       Get 통관 데이타.
*----------------------------------------------------------------------*
FORM GET_AND_CHECK_CC_DATA  USING    P_ICCNO
                                     P_ICCIT
                                     P_MODIFY
                                     P_ZTIVCC00 STRUCTURE ZTIVCC00
                                     P_COUNT.

  CLEAR: P_ZTIVCC00.

  SELECT SINGLE * INTO P_ZTIVCC00
    FROM ZTIVCC00
   WHERE ICCNO EQ P_ICCNO
     AND ICCIT EQ P_ICCIT.

  IF SY-SUBRC EQ 0.
**>Vendor 체크.
*    IF ZTITBLK-lifnr     NE p_ZTIvrq00-lifnr AND
*       NOT ZTITBLK-lifnr IS INITIAL.
*      MESSAGE s205 WITH p_ZTIvrq00-lifnr ZTITBLK-lifnr.
*      p_modify = c_true.
*      EXIT.
*    ENDIF.
**통화키 체크.
*    IF ZTITBLK-waers    NE  p_ZTIvrq00-waers AND
*       p_count           GT  c_zero.
*      MESSAGE s206 WITH p_ZTIvrq00-waers ZTITBLK-waers.
*      p_modify = c_true.
*    ENDIF.
**>기타 체크 로직.
*
*> Lock Object
    PERFORM  SET_CC_LOCK_OBJECT  USING P_ICCNO
                                       '00'
                                       P_ICCIT
                                       C_LOCK
                                       C_SUCCESS
                                       P_MODIFY.
  ELSE.
    MESSAGE S019(06) WITH P_ICCNO.
    P_MODIFY = C_TRUE.
    EXIT.
  ENDIF.

ENDFORM.                    " get_and_check_cc_data

*&---------------------------------------------------------------------*
*&      Form  p3000_set_data_of_screen
*&---------------------------------------------------------------------*
FORM P3000_SET_DATA_OF_SCREEN .

  CHECK : SY-TCODE EQ C_CREATE    OR
          SY-TCODE EQ C_CREATE_D  OR
          SY-TCODE EQ C_REVERSE1.

* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

*> Initializaton By Program
  PERFORM  SET_INITIAL_VALUE.

  CLEAR:  GT_CONTROL-TEXTLINES[], GT_CONTROL-TEXTTYPES[].
*
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

  DATA: L_IF_NULL TYPE REF TO IF_MESSAGE_OBJ_MM.

* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

**> 전표증빙일.
*  IF ztitgrk-bldat IS INITIAL.
*    PERFORM set_return_message USING 'ZTITGRK' 'BLDAT' c_error.
*  ENDIF.
**> 전표의 전기일.
*  IF ztitgrk-budat IS INITIAL.
*    PERFORM set_return_message USING 'ZTITGRK' 'BUDAT' c_error.
*  ENDIF.

*  LOOP AT it_tab INTO g_tc_2130_wa.
*    g_tabix = sy-tabix.
***> 입고수량..
**    IF g_tc_2130_wa-grmng IS INITIAL.
**      MESSAGE s513 WITH g_tabix 'G/R Qty.'.
**      PERFORM set_return_message_fill USING c_error.
**    ENDIF.
***> 저장위치.
**    IF g_tc_2130_wa-lgort IS INITIAL.
**      MESSAGE s513 WITH g_tabix '저장위치'.
**      PERFORM set_return_message_fill USING c_error.
**    ENDIF.
*    IF NOT g_tc_2130_wa-loekz IS INITIAL.
*      MESSAGE s170 WITH g_tabix g_tc_2130_wa-ebeln
*                                g_tc_2130_wa-ebelp.
*      PERFORM set_return_message_fill USING c_error.
*    ENDIF.
*
*  ENDLOOP.

*> 오류정보가 존재시 메시지 상자 POPUP.
  G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                          IM_BUSINESS_OBJ          = L_IF_NULL
                          IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

  IF G_LINE GT 0.
    CALL METHOD G_MESSAGE_HANDLER->SHOW( IM_POPUP = C_TRUE
      IM_AMODAL = C_FALSE ).
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
                                  USING  ZTITACK
                                         G_SUBRC
                                         P_MODE.
  IF G_SUBRC NE C_ZERO.
    MESSAGE A912.   EXIT.
  ENDIF.

*> Long Text 저장 루틴.
  PERFORM SAVE_LONG_TEXT USING ZTITACK+3(10)
                               C_TEXTOBJECT_HEADER
                               G_SUBRC.

  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    MESSAGE A912.   EXIT.
  ELSE.
*> Change document setting.
    PERFORM P8120_CHANGE_DOCUMENT.
*> Commit work.
    COMMIT WORK.
*> Set parameter ID
    IF OK_CODE_OLD EQ 'ZTIDELETE'.
      MESSAGE S201 WITH ZTITACK-ACDNO.
    ELSE.
      SET PARAMETER ID 'ZTIACDNO'  FIELD ZTITACK-ACDNO.
      MESSAGE S202 WITH ZTITACK-ACDNO.
    ENDIF.
  ENDIF.

ENDFORM.                    " p8000_save_master_data
*&---------------------------------------------------------------------*
*&      Form  p8100_save_common_data
*&---------------------------------------------------------------------*
FORM P8100_SAVE_COMMON_DATA  TABLES  PT_TAB     STRUCTURE G_TC_2130_WA
                             USING   P_ZTITACK  STRUCTURE ZTITACK
                                     P_SUBRC    LIKE      SY-SUBRC
                                     P_MODE.

  DATA: L_ACDNO     TYPE ZTIACDNO,
        L_REQTY     TYPE ZTIREQTY,
        L_GRSEQ     TYPE ZTIGRSEQ,
        L_RESG1     TYPE ZTIRESG1.

  CLEAR: P_SUBRC, L_ACDNO.
  L_REQTY = G_DOCUMENT.

  IF ( SY-TCODE EQ C_CREATE OR  SY-TCODE EQ C_CREATE_D  OR
       SY-TCODE EQ C_NO_DRAFT_DUE_LIST ) AND
     P_ZTITACK-ACDNO IS INITIAL.

    CALL FUNCTION 'Z_TI_GET_NUMBER_NEXT'
      EXPORTING
        ZMPTY          = L_REQTY
*   BUKRS          =
     IMPORTING
        LCONO          = L_ACDNO
     EXCEPTIONS
       NOT_TYPE       = 1
       OTHERS         = 2.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
    L_ACDNO = P_ZTITACK-ACDNO.
  ENDIF.

  IF  P_ZTITACK-CNAM IS INITIAL.
    MOVE: SY-UNAME   TO   P_ZTITACK-CNAM,
          SY-DATLO   TO   P_ZTITACK-CDAT,
          SY-TIMLO   TO   P_ZTITACK-CTME.
  ENDIF.

  MOVE: SY-MANDT        TO   P_ZTITACK-MANDT,
        L_ACDNO         TO   P_ZTITACK-ACDNO,
*        P_ZTITACK-ACDNO TO   P_ZTITACK-ACCNO, "기능개선 96084 삭제
        SY-UNAME        TO   P_ZTITACK-UNAM,
        SY-DATLO        TO   P_ZTITACK-UDAT,
        SY-TIMLO        TO   P_ZTITACK-UTME.

*-{기능개선 96084 추가 - 인수증 발급번호 채번룰 변경
  DATA : LV_ACCNO LIKE ZTITACK-ACCNO,
         LV_ACCNO_CON LIKE ZTITACK-ACCNO,
         LV_ACCNO_MAX LIKE ZTITACK-ACCNO,
         LV_NUMC(5) TYPE C.

  CLEAR : LV_ACCNO, LV_ACCNO_CON, LV_ACCNO_MAX, LV_NUMC.

  IF P_ZTITACK-ACCNO IS INITIAL.

    IF ZTITACK-BUKRS EQ '1000'.
      CONCATENATE 'LOCRCT' 'LOVE8888-' P_ZTITACK-ISSDT+2(6) '%'
      INTO LV_ACCNO_CON.

      SELECT SINGLE MAX( ACCNO )
        INTO LV_ACCNO_MAX
        FROM ZTITACK
         WHERE ACCNO LIKE LV_ACCNO_CON.

      IF LV_ACCNO_MAX IS NOT INITIAL.
        LV_NUMC = LV_ACCNO_MAX+23(5) + '1'.
"CCM : 2023.04.12  ZITCS4HDEV04 - MATNR과 관련 없음 (확인 완료)
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = LV_NUMC
          IMPORTING
            OUTPUT = LV_NUMC.

        CONCATENATE 'LOCRCT' 'LOVE8888-' P_ZTITACK-ISSDT+2(6) LV_NUMC
        INTO LV_ACCNO.
      ELSE.
        CONCATENATE 'LOCRCT' 'LOVE8888-' P_ZTITACK-ISSDT+2(6) '00001'
        INTO LV_ACCNO.
      ENDIF.

    ELSEIF ZTITACK-BUKRS EQ '3000'.
      CONCATENATE 'LOCRCT' 'LSM9123-' P_ZTITACK-ISSDT+2(6) '%'
      INTO LV_ACCNO_CON.

      SELECT SINGLE MAX( ACCNO )
        INTO LV_ACCNO_MAX
        FROM ZTITACK
         WHERE ACCNO LIKE LV_ACCNO_CON.

      IF LV_ACCNO_MAX IS NOT INITIAL.
        LV_NUMC = LV_ACCNO_MAX+23(5) + '1'.
"CCM : 2023.04.12  ZITCS4HDEV04 - MATNR과 관련 없음 (확인 완료)
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = LV_NUMC
          IMPORTING
            OUTPUT = LV_NUMC.

        CONCATENATE 'LOCRCT' 'LSM9123-' P_ZTITACK-ISSDT+2(6) LV_NUMC
        INTO LV_ACCNO.
      ELSE.
        CONCATENATE 'LOCRCT' 'LSM9123-' P_ZTITACK-ISSDT+2(6) '00001'
        INTO LV_ACCNO.
      ENDIF.

    ELSEIF ZTITACK-BUKRS EQ '5000'.  "LSEVK 추가
      CONCATENATE 'LOCRCT' 'LSEVK7-' P_ZTITACK-ISSDT+2(6) '%'
      INTO LV_ACCNO_CON.

      SELECT SINGLE MAX( ACCNO )
        INTO LV_ACCNO_MAX
        FROM ZTITACK
         WHERE ACCNO LIKE LV_ACCNO_CON.

      IF LV_ACCNO_MAX IS NOT INITIAL.
        LV_NUMC = LV_ACCNO_MAX+23(5) + '1'.
"CCM : 2023.04.12  ZITCS4HDEV04 - MATNR과 관련 없음 (확인 완료)
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = LV_NUMC
          IMPORTING
            OUTPUT = LV_NUMC.

        CONCATENATE 'LOCRCT' 'LSEVK7-' P_ZTITACK-ISSDT+2(6) LV_NUMC
        INTO LV_ACCNO.
      ELSE.
        CONCATENATE 'LOCRCT' 'LSEVK7-' P_ZTITACK-ISSDT+2(6) '00001'
        INTO LV_ACCNO.
      ENDIF.

    ENDIF.

    MOVE LV_ACCNO TO P_ZTITACK-ACCNO.
  ENDIF.
*-}기능개선 96084

  CLEAR : P_ZTITACK-ELDFN.

  IF OK_CODE_OLD EQ 'ZTIDELETE'.
*> Header table delete.
    DELETE FROM ZTITACK WHERE ACDNO EQ P_ZTITACK-ACDNO.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.
*> Item table delete
    DELETE FROM ZTITACP WHERE ACDNO EQ P_ZTITACK-ACDNO.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.
*> 회계문서 table delete
    DELETE FROM ZTITACF WHERE ACDNO EQ P_ZTITACK-ACDNO.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.
*> Segment #1 table delete
    DELETE FROM ZTITAC1 WHERE ACDNO EQ P_ZTITACK-ACDNO.
*    IF sy-subrc NE 0.
*      ROLLBACK WORK.   MOVE 4  TO p_subrc.     EXIT.
*    ENDIF.
    EXIT.
  ELSE.
*> Header table modify.
    MODIFY ZTITACK FROM P_ZTITACK.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.
*> Items table modify.
    DELETE FROM ZTITACP WHERE ACDNO EQ P_ZTITACK-ACDNO.
    REFRESH : XZTITACP.
    LOOP AT IT_TAB INTO G_TC_2130_WA.
      MOVE-CORRESPONDING G_TC_2130_WA TO XZTITACP.
      XZTITACP-MANDT = P_ZTITACK-MANDT.
      XZTITACP-ACDNO = P_ZTITACK-ACDNO.
      XZTITACP-UNAM  = SY-UNAME.
      XZTITACP-UDAT  = SY-DATLO.
      XZTITACP-UTME  = SY-TIMLO.
      APPEND XZTITACP.
    ENDLOOP.

    MODIFY ZTITACP FROM TABLE XZTITACP.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.

*> 회계문서 table modify.
    DELETE FROM ZTITACF WHERE ACDNO EQ P_ZTITACK-ACDNO.
    REFRESH : XZTITACF.
    LOOP AT IT_ZTISACF.
      MOVE-CORRESPONDING IT_ZTISACF TO XZTITACF.
      XZTITACF-MANDT = P_ZTITACK-MANDT.
      XZTITACF-ACDNO = P_ZTITACK-ACDNO.
      APPEND XZTITACF.
    ENDLOOP.

    MODIFY ZTITACF FROM TABLE XZTITACF.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.

*> Segment #1 table modify.
    DELETE FROM ZTITAC1 WHERE ACDNO EQ P_ZTITACK-ACDNO.
    REFRESH : XZTITAC1.
    CLEAR L_RESG1.
    LOOP AT XZTITACP.
      ADD 1 TO L_RESG1.
      XZTITAC1-MANDT  = P_ZTITACK-MANDT.
      XZTITAC1-RESG1  = L_RESG1.
      XZTITAC1-ACDNO  = P_ZTITACK-ACDNO.
      XZTITAC1-COMNO  = XZTITACP-STAWN.
      XZTITAC1-REQIT  = XZTITACP-REQIT.
      XZTITAC1-CSTD1  = XZTITACP-TXZ01.
*      xztitac1-CSTD2  =
*      xztitac1-CSTD3  =
*      xztitac1-CSTD4  =
*      xztitac1-CSTD5  =
      XZTITAC1-TOQUN  = XZTITACP-ACMNG.
      XZTITAC1-TOQUNM = XZTITACP-MEINS.
      XZTITAC1-TOQUS  = XZTITACP-ACMNG.
      XZTITAC1-TOQUSM = XZTITACP-MEINS.
      XZTITAC1-NETPRC = P_ZTITACK-ACAMTC.
      XZTITAC1-REAMT  = XZTITACP-REFWR.
      XZTITAC1-REAMTC = P_ZTITACK-ACAMTC.
      XZTITAC1-REAMS  = XZTITACP-REFWR.
      XZTITAC1-REAMSC = P_ZTITACK-ACAMTC.
      XZTITAC1-EBELN  = XZTITACP-EBELN.
      XZTITAC1-EBELP  = XZTITACP-EBELP.
      XZTITAC1-MATNR  = XZTITACP-MATNR.
      XZTITAC1-MAKTX  = XZTITACP-TXZ01.
      XZTITAC1-PEINH  = XZTITACP-PEINH.
      XZTITAC1-BPRME  = XZTITACP-BPRME.
      XZTITAC1-NETPR  = XZTITACP-NETPR.

      APPEND XZTITAC1.
    ENDLOOP.
    IF SY-SUBRC EQ 0.
      MODIFY ZTITAC1 FROM TABLE XZTITAC1.
      IF SY-SUBRC NE 0.
        ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
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
*            ARCHIVE_INDEX      =
*            ARCHIVE_INDEX_TAB  =
*            ARCHIVE_PARAMETERS =
*            MAIL_APPL_OBJ      = MAIL_APPL_OBJ
*            MAIL_RECIPIENT     = MAIL_RECIPIENT
*            MAIL_SENDER        = MAIL_SENDER
            USER_SETTINGS      = SPACE
            CONTROL_PARAMETERS = G_CONTROL_PARAMETERS
            OUTPUT_OPTIONS     = G_OUTPUT_OPTIONS
            ZTITACK            = ZTITACK
      IMPORTING
            DOCUMENT_OUTPUT_INFO = G_DOCUMENT_OUTPUT_INFO
            JOB_OUTPUT_INFO      = G_JOB_OUTPUT_INFO
            JOB_OUTPUT_OPTIONS   = G_JOB_OUTPUT_OPTIONS
      TABLES
            ZTITAC1              = IT_ZTISAC1
       EXCEPTIONS
            FORMATTING_ERROR   = 1
            INTERNAL_ERROR     = 2
            SEND_ERROR         = 3
            USER_CANCELED      = 4.

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

  IF ZTITACK-BUKRS IS INITIAL.
    CLEAR: T001.
  ELSE.
    SELECT SINGLE * FROM T001
     WHERE BUKRS EQ ZTITACK-BUKRS.
    IF SY-SUBRC EQ 0.
      SELECT SINGLE *
        FROM ZTITIG00
       WHERE BUKRS EQ ZTITACK-BUKRS.
      IF SY-SUBRC NE 0.
        MESSAGE E035 WITH ZTITACK-BUKRS.
      ENDIF.
    ENDIF.
  ENDIF.
* 구매조직 SELECT ( T024E )
  IF ZTITACK-EKORG IS INITIAL.
    CLEAR T024E.
  ELSE.
    CALL FUNCTION 'T024E_SINGLE_READ'
      EXPORTING
        T024E_EKORG = ZTITACK-EKORG
      IMPORTING
        WT024E      = T024E
      EXCEPTIONS
        NOT_FOUND   = 1
        OTHERS      = 2.

    IF SY-SUBRC NE 0.
      IF SY-CALLD NE C_TRUE.
        MESSAGE W001(MH) WITH ZTITACK-EKORG.
      ENDIF.
    ENDIF.
  ENDIF.

* 구매그룹 SELECT ( T024 )
  IF ZTITACK-EKGRP IS INITIAL.
    CLEAR T024.
  ELSE.
    CALL FUNCTION 'MM_ARRANG_PURCHASE_GRP_SELECT'
      EXPORTING
        PURCHASE_GROUP           = ZTITACK-EKGRP
      IMPORTING
        E_T024                   = T024
      EXCEPTIONS
        PURCHASE_GROUP_NOT_FOUND = 1
        OTHERS                   = 2.

    IF SY-SUBRC NE 0.
      IF SY-CALLD NE C_TRUE.
        MESSAGE W030(MN) WITH ZTITACK-EKGRP.
      ENDIF.
    ENDIF.
  ENDIF.

*> Vender master check
  PERFORM  GET_IMPORT_VENDORS_TEXT  USING C_SUCCESS.

ENDFORM.                    " GET_OTHERS_TEXT_BY_MASTER_DATA
*&---------------------------------------------------------------------*
*&      Form  get_used_payment_term
*&---------------------------------------------------------------------*
FORM GET_USED_PAYMENT_TERM  TABLES   P_IT_ZTITIG02 STRUCTURE ZTITIG02
                            USING    P_SUBRC  P_TYPE.

  CLEAR: P_SUBRC.

  SELECT BSART ZTERM REQTY SETYN FROM  ZTITIG02
    INTO CORRESPONDING FIELDS OF TABLE P_IT_ZTITIG02.

  P_SUBRC = SY-SUBRC.

  IF P_SUBRC NE 0.
    MESSAGE ID 'ZMMI' TYPE P_TYPE NUMBER 001.
    EXIT.
  ENDIF.

ENDFORM.                    " get_used_payment_term
*&---------------------------------------------------------------------*
*&      Form  p8120_change_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P8120_CHANGE_DOCUMENT .

  DATA: L_OBJECTID              TYPE CDHDR-OBJECTID,
        L_TCODE                 TYPE CDHDR-TCODE,
        L_UTIME                 TYPE CDHDR-UTIME,
        L_UDATE                 TYPE CDHDR-UDATE,
        L_USERNAME              TYPE CDHDR-USERNAME,
        L_CDOC_UPD_OBJECT       TYPE CDHDR-CHANGE_IND,
        L_UPD_ICDTXT            TYPE CHAR1,
        L_UPD                   TYPE CHAR1,
*        l_upd                   TYPE char1,
        LT_CDTXT                TYPE STANDARD TABLE OF CDTXT
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

  L_OBJECTID(10) = ZTITACK+3(10).

  L_TCODE        = SY-TCODE.
  L_UTIME        = SY-TIMLO.
  L_UDATE        = SY-DATLO.
  L_USERNAME     = SY-UNAME.

  IF G_MODE EQ C_CHARC.  ">생성모드일 경우.
    REFRESH : YZTITACP,
              YZTITAC1,
              YZTITACF.
  ENDIF.
*
  LOOP AT XZTITACP.
    XZTITACP-KZ = L_UPD.
    MODIFY XZTITACP.
  ENDLOOP.

  LOOP AT XZTITACF.
    XZTITACF-KZ = L_UPD.
    MODIFY XZTITACF.
  ENDLOOP.

  LOOP AT XZTITAC1.
    XZTITAC1-KZ = L_UPD.
    MODIFY XZTITAC1.
  ENDLOOP.

  CALL FUNCTION 'ZTIACCHDOC_WRITE_DOCUMENT'
    EXPORTING
        OBJECTID                      = L_OBJECTID
        TCODE                         = L_TCODE
        UTIME                         = L_UTIME
        UDATE                         = L_UDATE
        USERNAME                      = L_USERNAME
*   PLANNED_CHANGE_NUMBER         = ' '
        OBJECT_CHANGE_INDICATOR       = L_CDOC_UPD_OBJECT
*   PLANNED_OR_REAL_CHANGES       = ' '
*   NO_CHANGE_POINTERS            = ' '
*   UPD_ICDTXT_ZTIBLCHDOC         = ' '
      N_ZTITACK                    = ZTITACK
      O_ZTITACK                    = *ZTITACK
      UPD_ZTITACK                  = L_UPD
      UPD_ZTITACP                  = L_UPD
      UPD_ZTITAC1                  = L_UPD
      UPD_ZTITACF                  = L_UPD
    TABLES
      ICDTXT_ZTIACCHDOC            = LT_CDTXT
      XZTITACP                     = XZTITACP
      YZTITACP                     = YZTITACP
      XZTITACF                     = XZTITACF
      YZTITACF                     = YZTITACF
      XZTITAC1                     = XZTITAC1
      YZTITAC1                     = YZTITAC1.

*
ENDFORM.                    " p8120_change_document
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
    IF G_MODE EQ C_CHARC OR
       G_MODE EQ C_CHARM OR
       G_MODE EQ C_CHARY OR
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
*&      Form  call_print_process
*&---------------------------------------------------------------------*
FORM CALL_PRINT_PROCESS .

*> GET OUTPUT OPTIONS
  IF IT_PRTCTL[] IS INITIAL.
    REFRESH : IT_PRTCTL.
    CLEAR: IT_PRTCTL.
    IF NOT ZTITACK-OPNBK IS INITIAL.   ">Openning bank.
      SELECT LIFNR NAME1 LAND1 SPRAS TELFX ADRNR
      INTO CORRESPONDING FIELDS OF TABLE IT_PRTCTL
      FROM LFA1
      WHERE LIFNR IN ( SELECT LIFNR
                       FROM ZTSTIG3
                       WHERE EPART EQ ZTITACK-OPNBK
                         AND BUKRS IN S_BUKRS ).
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
      PERFORM P7000_SET_SMART_FORM_NAME USING G_DOCUMENT
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
*    MODIFY it_tab FROM g_tc_2130_wa.
  ENDLOOP.

ENDFORM.                    " SET_OTHERS_FIELDS_BY_ITEMS
*&---------------------------------------------------------------------*
*&      Form  get_Import_vendors_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_IMPORT_VENDORS_TEXT USING P_MSGTY.

  IF ZTITACK-LIFNR IS INITIAL.
    CLEAR: LFA1.
  ELSE.
    SELECT SINGLE * FROM LFA1
     WHERE LIFNR EQ ZTITACK-LIFNR.
    IF SY-SUBRC NE 0.
      PERFORM MESSAGE_NOT_FOUND_VENDOR USING 'ZTITACK'
                                             'LIFNR'
                                             P_MSGTY.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_Import_vendors_text
*&---------------------------------------------------------------------*
*&      Form  check_gr_sub_document_exist
*&---------------------------------------------------------------------*
*       하위문서 존재여부 체크.
*----------------------------------------------------------------------*
FORM CHECK_GR_SUB_DOCUMENT_EXIST  USING    P_IGRNO
                                           P_ICCIT
                                           P_MSGTY
                                           P_SUBRC.
  DATA: L_COUNT TYPE I.

  CLEAR: P_SUBRC.

  CHECK NOT P_IGRNO IS INITIAL.

**> B/L 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ZTItblit
*   WHERE reqno   EQ  p_reqno
*     AND reqit   EQ  p_reqit.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMMI' TYPE p_msgty NUMBER '109' WITH 'B/L'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.
*
**> 선급금 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ZTItivit
*   WHERE reqno   EQ  p_reqno
*     AND reqit   EQ  p_reqit.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMMI' TYPE p_msgty NUMBER '109' WITH '선급금'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.
*
ENDFORM.                    " check_gr_sub_document_exist
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

**> 통관 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ZTITCCP
*   WHERE iblno   EQ  p_iblno
*     AND iblit   EQ  p_iblit.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMMI' TYPE p_msgty NUMBER '109' WITH 'B/L'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.
*
**> L/G 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ZTItlg01
*   WHERE iblno   EQ  p_iblno.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMMI' TYPE p_msgty NUMBER '109' WITH 'L/G'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.
*
**> 반입예정정보 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ZTItbshd
*   WHERE iblno   EQ  p_iblno.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMMI' TYPE p_msgty NUMBER '109' WITH '반입예정정보'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.
*
**> 반입정보 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ZTItbihd
*   WHERE iblno   EQ  p_iblno.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMMI' TYPE p_msgty NUMBER '109' WITH '반입정보'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.
*
**> 반출정보 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ZTItbohd
*   WHERE iblno   EQ  p_iblno.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMMI' TYPE p_msgty NUMBER '109' WITH '반출정보'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.
*
**> 송장 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ZTItivit
*   WHERE iblno   EQ  p_iblno
*     AND iblit   EQ  p_iblit.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMMI' TYPE p_msgty NUMBER '109' WITH '선급금'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.
*
ENDFORM.                    " check_cc_sub_document_exist

*&---------------------------------------------------------------------*
*&      Form  SET_INITIAL_VALUE
*&---------------------------------------------------------------------*
FORM SET_INITIAL_VALUE .

*> 문서 종류.
  G_DOCUMENT = C_AC.

* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

  REFRESH: IT_TAB,
           XZTITACF, YZTITACF,
           XZTITACP, YZTITACP,
           XZTITAC1, YZTITAC1.

  CLEAR:   IT_TAB,
           ZTITACK,    ">인수증 Header
          *ZTITACK,    ">인수증 Header
           XZTITACF,
           YZTITACF,
           XZTITACP,
           YZTITACP,
           XZTITAC1,
           YZTITAC1,
           LFA1,
          *LFA1,
           W_LFA1,
           W_LFA1_BANK,
           IT_ACDNO,
           T001,
           T024,
           T024E.

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
        WHEN 'ZTISACIT-EBELN' OR 'ZTISACIT-EBELP'.
          PERFORM DISPLAY_PURCHASE_ORDER USING G_TC_2130_WA-EBELN
                                               G_TC_2130_WA-EBELP.
        WHEN 'ZTISACIT-REQNO' OR 'ZTISACIT-REQIT'.
          SELECT SINGLE AMDSQ
            INTO ZTIVRQ00-AMDSQ
            FROM ZTIVRQ00
           WHERE REQNO  EQ  G_TC_2130_WA-REQNO
             AND REQIT  EQ  G_TC_2130_WA-REQIT.
          IF SY-SUBRC EQ 0.
            PERFORM DISPLAY_IMPORT_DOCUMENT USING G_TC_2130_WA-REQNO
                                                  ZTIVRQ00-AMDSQ
                                                  G_TC_2130_WA-REQIT.
          ENDIF.
        WHEN 'ZTISGRIT-MATNR'.
          PERFORM DISPLAY_MATERIAL_MASTER USING G_TC_2130_WA-MATNR
                                                G_TC_2130_WA-WERKS
                                                G_TC_2130_WA-LGORT.
        WHEN 'ZTISGRIT-VBELN' OR 'ZTISGRIT-POSNR'.
*          PERFORM display_inb_document    USING g_tc_2130_wa-vbeln.
      ENDCASE.
    ENDIF.
  ELSE.
    GET CURSOR FIELD G_FIELDNAME.
    IF SY-SUBRC EQ 0.
      G_FINDSCR = SY-DYNNR.
      CHECK OK_CODE EQ 'ZTISELECT'.   ">문서선택.

      CASE G_FIELDNAME.
        WHEN 'ZTITACK-VATNO'.
          PERFORM DISPLAY_VA_DOCUMENT USING ZTITACK-VATNO.
        WHEN 'ZTITACK-LIFNR'.
          PERFORM DISPLAY_VENDOR_MASTER USING ZTITACK-LIFNR
                                              SPACE.
        WHEN 'ZTITACK-REQNO' OR 'ZTITACK-AMDSQ'.
          PERFORM DISPLAY_IMPORT_DOCUMENT USING ZTITACK-REQNO
                                                ZTITACK-AMDSQ
                                                '00000'.
      ENDCASE.
    ENDIF.
  ENDIF.

ENDFORM.                    " double_click_event
*&---------------------------------------------------------------------*
*&      Form  set_function_by_BUSINESS
*&---------------------------------------------------------------------*
FORM SET_FUNCTION_BY_BUSINESS .

  CASE G_MODE.
    WHEN C_CHARC OR C_CHARM.
    WHEN OTHERS.
      MOVE 'ZTILOCIN'     TO FTAB-FCODE.   APPEND FTAB. ">저장위치.
  ENDCASE.

  IF SY-DYNNR EQ C_SCR0100 OR
     SY-DYNNR EQ C_SCR0200.
    MOVE 'ZTILOCIN'     TO FTAB-FCODE.   APPEND FTAB. ">저장위치.
  ENDIF.

  IF G_DOCUMENT EQ C_GR.
    IF ZTITGRK-IGRST NE C_CHARG.
      MOVE 'ZTIACDOC'     TO FTAB-FCODE.   APPEND FTAB. ">후속문서.
      MOVE 'ZTIMMDOC'     TO FTAB-FCODE.   APPEND FTAB. ">송장문서.
    ENDIF.
    IF ZTITGRK-IGRST EQ C_CHARN OR
       ZTITGRK-IGRST EQ C_CHARG.
      MOVE 'ZTICHECK'     TO FTAB-FCODE.   APPEND FTAB. ">점검.
    ENDIF.
  ENDIF.

ENDFORM.                    " set_function_by_BUSINESS
*&---------------------------------------------------------------------*
*&      Form  check_request_of_custom
*&---------------------------------------------------------------------*
*  수입통관문서의 종류/상태를 검증.
*----------------------------------------------------------------------*
FORM CHECK_REQUEST_OF_CUSTOM .
  DATA: L_DDTEXT LIKE G_DDTEXT.

*  CASE ZTITRQK-reqty.
*    WHEN c_pu OR c_lo.
**> 수입의뢰 종류 Fixed value read.
*      PERFORM  ddic_domain_value_text_read USING 'ZTIREQTY'
*                                                 sy-langu
*                                                 ZTITRQK-reqty
*                                                 g_ddtext
*                                                 c_success.
*      l_ddtext = g_ddtext.
*      MESSAGE e203 WITH l_ddtext.
*    WHEN OTHERS.
**> 선급금일 경우.
*      IF NOT ZTITRQK-ppaid IS INITIAL.
*        MESSAGE e204 WITH '선급금'.
*      ENDIF.
**> 유보금일 경우.
*      IF NOT ZTITRQK-rpaid IS INITIAL.
*        MESSAGE e204 WITH '유보금'.
*      ENDIF.
*  ENDCASE.

ENDFORM.                    " check_request_of_custom
*&---------------------------------------------------------------------*
*&      Form  get_available_lc_item
*&---------------------------------------------------------------------*
*       인수증을 입력할 L/C 잔량을 체크함.
*----------------------------------------------------------------------*
FORM GET_AVAILABLE_LC_ITEM  "TABLES   pt_ztisccit STRUCTURE it_ztisccit
*                                     pt_iccno    STRUCTURE it_iccno
                            TABLES   PT_ZTISCCIT
                                     PT_ICCNO
                            USING    P_MSGTY
                                     P_DEL_MODE.
  DATA: L_CCMNG  LIKE ZTITCCP-CCMNG,
        BEGIN OF LT_GRMNG OCCURS 5,
                 SHKZG  LIKE  ZTISGRIT-SHKZG,
                 GRMNG  LIKE  ZTISGRIT-GRMNG,
        END   OF LT_GRMNG.

  CLEAR: G_COUNT, G_CNT.

  LOOP AT PT_ZTISCCIT.
    G_TABIX = SY-TABIX.
    CLEAR: L_CCMNG.
    REFRESH LT_GRMNG.
    IF OK_CODE EQ 'ZTICOPY'.
*      SELECT shkzg grmng
*        INTO CORRESPONDING FIELDS OF TABLE lt_grmng
*        FROM ztivgr00
*       WHERE iblno   EQ pt_ztisccit-iblno
*         AND iccit   EQ pt_ztisccit-iccit.
*         AND RPTTY   NE
    ELSE.
*      SELECT shkzg grmng
*        INTO CORRESPONDING FIELDS OF TABLE lt_grmng
*        FROM ztivgr00
*       WHERE iccno   EQ pt_ztisccit-iccno
*         AND iccit   EQ pt_ztisccit-iccit.
**         AND ( igrst EQ 'G'
**          OR   igrst EQ 'R' ).
    ENDIF.

*    LOOP AT lt_grmng.
*      IF lt_grmng-shkzg EQ 'S'.
*        l_ccmng = l_ccmng + lt_grmng-grmng.
*      ELSEIF lt_grmng-shkzg EQ 'H'.
*        l_ccmng = l_ccmng - lt_grmng-grmng.
*      ENDIF.
*    ENDLOOP.
*
*    pt_ztisccit-grmngs = l_ccmng.
*    IF pt_ztisccit-grmngs LT 0.
*      pt_ztisccit-grmngs = 0.
*    ENDIF.
*
*    pt_ztisccit-grmng =  pt_ztisccit-ccmng - pt_ztisccit-grmngs.
*
*    IF pt_ztisccit-grmng LE c_zero.
*      IF p_del_mode EQ c_true.
*        DELETE pt_ztisccit INDEX g_tabix.
*        CONTINUE.
*      ELSE.
*        pt_ztisccit-grmng = 0.
*      ENDIF.
*    ELSE.
*      ADD 1 TO g_cnt.
*    ENDIF.
*
*    pt_ztisccit-grmngl =  pt_ztisccit-grmng.
*
**> Tree용 Internal table modify.
*    ADD 1 TO g_count.
*    pt_ztisccit-index = g_count.
*    MODIFY pt_ztisccit INDEX g_tabix.
*
**> 수입의뢰관리번호별 collect.
*    MOVE pt_ztisccit-iccno TO pt_iccno-iccno.
*    COLLECT pt_iccno.
  ENDLOOP.
*
*  DESCRIBE TABLE pt_ztisccit LINES g_line.
*  IF g_line EQ 0.
*    MESSAGE ID 'ZMMI' TYPE p_msgty NUMBER 902.
*    EXIT.
*  ENDIF.
*
*  IF g_cnt EQ 0.
**    MESSAGE ID 'ZMMI' TYPE c_warning NUMBER 103.
*    MESSAGE ID 'ZMMI' TYPE p_msgty NUMBER 103.
*  ENDIF.

ENDFORM.                    " get_available_cc_item
*&---------------------------------------------------------------------*
*&      Form  display_import_doc_by_node
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_IMPORT_DOC_BY_NODE  USING    P_NODE_KEY.

*  READ TABLE it_ztisccit INTO g_ztisccit_wa
*                         WITH KEY INDEX = p_node_key(10).
*  IF sy-subrc EQ 0.
**    PERFORM  display_import_document USING g_ZTIsrqit_wa-reqno
**                                           g_ZTIsrqit_wa-amdsq
**                                           g_ZTIsrqit_wa-reqit.
*  ELSE.
*    MESSAGE s903.
*  ENDIF.

ENDFORM.                    " display_import_doc_by_node
*&---------------------------------------------------------------------*
*&      Form  SCR2123_FIELDCAT_BUILD
*&---------------------------------------------------------------------*
FORM SCR2123_FIELDCAT_BUILD .

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME = 'ZTISACF'
    CHANGING
      CT_FIELDCAT      = IT_FIELDCAT_LVC[].

  LOOP AT IT_FIELDCAT_LVC.
    CASE IT_FIELDCAT_LVC-FIELDNAME.
      WHEN 'MBLNR' OR 'MJAHR'.
        IT_FIELDCAT_LVC-KEY     = C_TRUE.
        IT_FIELDCAT_LVC-HOTSPOT = C_TRUE.
      WHEN 'ACDNO' OR 'FLAG'.
        IT_FIELDCAT_LVC-NO_OUT  = C_TRUE.
      WHEN 'HWAER'.
        IT_FIELDCAT_LVC-COL_POS = 11.
      WHEN 'WAERS'.
        IT_FIELDCAT_LVC-COL_POS = 12.
      WHEN 'REEWR'.
        IT_FIELDCAT_LVC-CFIELDNAME = 'HWAER'.
        IT_FIELDCAT_LVC-CURRENCY   = T001-WAERS.
      WHEN OTHERS.
    ENDCASE.
    MODIFY IT_FIELDCAT_LVC.
  ENDLOOP.

ENDFORM.                    " SCR2123_FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*&      Form  handle_double_click
*&---------------------------------------------------------------------*
FORM HANDLE_DOUBLE_CLICK  USING  P_ROW P_COLUMN.

  READ TABLE IT_ZTISACF INDEX P_ROW.

  CHECK SY-SUBRC = 0.

  CASE P_COLUMN.
    WHEN 'MBLNR' OR 'MJAHR'.
      IF NOT IT_ZTISACF-MBLNR IS INITIAL.
        PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTISACF-MBLNR
                                            IT_ZTISACF-MJAHR
                                            ZTITACK-BUKRS.
      ENDIF.
    WHEN OTHERS.
      IF NOT IT_ZTISACF-BELNR IS INITIAL.
        PERFORM DISPLAY_FI_DOCUMENT USING   IT_ZTISACF-BELNR
                                            IT_ZTISACF-GJAHR
                                            ZTITACK-BUKRS.
      ENDIF.
  ENDCASE.

ENDFORM.                    "handle_double_click
*&---------------------------------------------------------------------*
*&      Form  handle_hotspot_click
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK  USING E_ROW_ID    TYPE LVC_S_ROW
                                 E_COLUMN_ID TYPE LVC_S_COL.

  READ TABLE IT_ZTISACF INDEX E_ROW_ID-INDEX.

  CHECK SY-SUBRC = 0.

  CASE E_COLUMN_ID-FIELDNAME.
    WHEN 'MBLNR' OR 'MJAHR'.
      IF NOT IT_ZTISACF-MBLNR IS INITIAL.
        PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTISACF-MBLNR
                                            IT_ZTISACF-MJAHR
                                            ZTITACK-BUKRS.
      ENDIF.
    WHEN OTHERS.
      IF NOT IT_ZTISACF-BELNR IS INITIAL.
        PERFORM DISPLAY_FI_DOCUMENT USING   IT_ZTISACF-BELNR
                                            IT_ZTISACF-GJAHR
                                            ZTITACK-BUKRS.
      ENDIF.
  ENDCASE.

ENDFORM.                    "_hotspot_click
*&---------------------------------------------------------------------*
*&      Form  account_document_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ACCOUNT_DOCUMENT_DISPLAY  USING    P_BUKRS
                                        P_MJAHR
                                        P_MBLNR.

  DATA: L_AWTYP       LIKE  ACCHD-AWTYP,
        L_AWREF       LIKE  ACCHD-AWREF,
        L_AWORG       LIKE  ACCHD-AWORG,
        L_AWSYS       LIKE  ACCHD-AWSYS,
        L_AWTYP_INCL  LIKE  ACCHD-AWTYP,
        L_AWTYP_EXCL  LIKE  ACCHD-AWTYP,
        L_BUKRS       LIKE  ACCIT-BUKRS,
        L_VALUTYP     LIKE  ACCCR-VALUTYP   VALUE '0'.

  CHECK NOT P_MBLNR IS INITIAL.

  L_AWREF = P_MBLNR.
  L_AWORG = P_MJAHR.
  L_AWTYP = 'MKPF'.

  CALL FUNCTION 'AC_DOCUMENT_RECORD'
    EXPORTING
      I_AWTYP      = L_AWTYP
      I_AWREF      = L_AWREF
      I_AWORG      = L_AWORG
*      i_awsys      = L_awsys
    EXCEPTIONS
      NO_REFERENCE = 1
      NO_DOCUMENT  = 2
      OTHERS       = 3.
  CASE SY-SUBRC.
    WHEN 0.
    WHEN 1.
      MESSAGE S008(MICK) WITH P_MBLNR P_MJAHR.
    WHEN OTHERS.
      MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
                          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDCASE.

ENDFORM.                    " account_document_display
*&---------------------------------------------------------------------*
*&      Form  set_cancel_document_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_CANCEL_DOCUMENT_NUMBER  USING    P_ZTISSCRCOM  LIKE ZTISSCRCOM.

  MOVE: ZTITGRK-MBLNR  TO ZTISSCRCOM-MBLNR,
        ZTITGRK-MJAHR  TO ZTISSCRCOM-MJAHR,
        ZTITGRK-BUKRS  TO ZTISSCRCOM-BUKRS,
        ZTITGRK-CBUDAT TO ZTISSCRCOM-CBUDAT.

  IF ZTISSCRCOM-CBUDAT IS INITIAL.
    ZTISSCRCOM-CBUDAT = SY-DATLO.
  ENDIF.

  SPOP-TEXTLINE1 = '해당 입고문서를 취소하시겠습니까?'.

ENDFORM.                    " set_cancel_document_number
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P1001_INITIALIZATION .

  SET TITLEBAR 'T1000' WITH 'Due List'(T10).

  FREE: S_BUKRS.    CLEAR: S_BUKRS.
  S_BUKRS-SIGN   = 'I'.
  S_BUKRS-OPTION = 'EQ'.
  GET PARAMETER ID 'BUK' FIELD S_BUKRS-LOW.

  IF NOT S_BUKRS-LOW IS INITIAL.
*  s_bukrs-low    = c_bukrs.
    APPEND S_BUKRS.
  ENDIF.

ENDFORM.                    " p1001_initialization
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
          ' ' 'REF_TABNAME'   ' ',
          ' ' 'FIELDNAME'     'BOX',
          ' ' 'HOTSPOT'       ' ',
          'E' 'KEY'           ' ',
"전표번호.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTIVAC00',
          ' ' 'FIELDNAME'     'MBLNR',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '10',
"Local L/C Number
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTIVAC00',
          ' ' 'FIELDNAME'     'OPNNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '16',
"개설일자.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTIVAC00',
          'E' 'FIELDNAME'     'OPNDT',
"세금계산서 번호.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITVAK',
          ' ' 'FIELDNAME'     'VATNO',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '12',
"공급업체.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTIVAC00',
          ' ' 'FIELDNAME'     'LIFNR',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '12',
"공급업체명.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTIVAC00',
          ' ' 'FIELDNAME'     'NAME1',
          ' ' 'SELTEXT_S'     '공급업체명',
          ' ' 'SELTEXT_L'     '공급업체명',
          ' ' 'SELTEXT_M'     '공급업체명',
          'E' 'OUTPUTLEN'     '20',
"개설은행.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTIVAC00',
          ' ' 'FIELDNAME'     'NAMET',
          ' ' 'SELTEXT_S'     '개설은행',
          ' ' 'SELTEXT_L'     '개설은행',
          ' ' 'SELTEXT_M'     '개설은행',
          'E' 'OUTPUTLEN'     '20',

"사업장.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTIVAC00',
          ' ' 'FIELDNAME'     'BUPLA',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '3',

"전표통화.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTIVAC00',
          ' ' 'FIELDNAME'     'WAERS',
          ' ' 'HOTSPOT'       ' ',
          'E' 'KEY'           ' ',

************************************************************
*> For TraSys ECC Upgrade By ASEG Co., Ltd.
************************************************************
*> 2009/02/20
*> Started of Modify
************************************************************

*-> Before
*"전표금액.
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTIVAC00',
*          ' ' 'FIELDNAME'     'WTBTRH',
*          ' ' 'CFIELDNAME'    'WAERS',
*          ' ' 'HOTSPOT'       ' ',
*          'E' 'KEY'           ' ',

*->After
*"전표금액.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTIVAC00',
          ' ' 'FIELDNAME'     'WRBTRH',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'HOTSPOT'       ' ',
          'E' 'KEY'           ' ',
************************************************************
*> Ended of Modify
************************************************************

*>>>>>>>>>LIST
"I/V 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTIVAC00',
          ' ' 'FIELDNAME'     'BUZEI',
          ' ' 'HOTSPOT'       'X',
          ' ' 'JUST'          C_CHARL," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
          ' ' 'INTLEN'         10,
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '16',
"구매전표번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTIVAC00',
          ' ' 'FIELDNAME'     'EBELN',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '10',

"구매문서 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTIVAC00',
          ' ' 'FIELDNAME'     'EBELP',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'JUST'          C_CHARL," (R)ight (L)eft (C)ent.
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '10',
*"수입의뢰번호
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTIVAC00',
*          ' ' 'FIELDNAME'     'REQNO',
*          ' ' 'HOTSPOT'       'X',
*
*          'E' 'KEY'           ' ',
**          'E' 'OUTPUTLEN'     '10',
*"수입의뢰 품목번호
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTITCCP',
*          ' ' 'FIELDNAME'     'REQIT',
*          ' ' 'NO_OUT'        'X',
*          ' ' 'HOTSPOT'       ' ',
*          ' ' 'KEY'           ' ',
*          'E' 'OUTPUTLEN'     '5',
*"B/L관리번호
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTITCCP',
*          ' ' 'FIELDNAME'     'IBLNO',
*          ' ' 'HOTSPOT'       'X',
*          ' ' 'KEY'           ' ',
*          'E' 'OUTPUTLEN'     '12',
*"B/L 품목번호
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTITCCP',
*          ' ' 'FIELDNAME'     'IBLIT',
*          ' ' 'HOTSPOT'       ' ',
*          ' ' 'NO_OUT'        'X',
*          ' ' 'KEY'           ' ',
*          'E' 'OUTPUTLEN'     '5',
"자재번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTIVAC00',
          ' ' 'FIELDNAME'     'MATNR',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '12',

"자재내역.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTIVAC00',
          ' ' 'FIELDNAME'     'TXZ01',
          'E' 'OUTPUTLEN'     '40',

"인수증 수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTIVAC00',
          ' ' 'FIELDNAME'     'ACMNG',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'NO_OUT'        'X',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'HOTSPOT'       ' ',
          'E' 'KEY'           ' ',
*"통관수량
*          'S' 'TABNAME'       'IT_LIST',
**          ' ' 'REF_TABNAME'   'ZTISGRIT',
*          ' ' 'FIELDNAME'     'GRMNGL',
*          ' ' 'seltext_S'     '입고가능수량',
*          ' ' 'seltext_m'     '입고가능수량',
*          ' ' 'seltext_L'     '입고가능수량',
*          ' ' 'QFIELDNAME'    'MEINS',
*          ' ' 'QTABNAME'      'IT_LIST',
*          ' ' 'HOTSPOT'       ' ',
*          'E' 'OUTPUTLEN'     '16',
"단위
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTIVAC00',
          ' ' 'FIELDNAME'     'MEINS',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '3',
"최종변경인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTIVAC00',
          ' ' 'FIELDNAME'     'UNAM',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'NO_OUT'        'X',
          ' ' 'KEY'           ' ',
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

  GS_KEYINFO-HEADER01 = 'REQNO'.
  GS_KEYINFO-ITEM01   = 'REQNO'.

  GS_KEYINFO-HEADER02 = 'AMDSQ'.
  GS_KEYINFO-ITEM02   = 'AMDSQ'.

  GS_KEYINFO-HEADER03 = 'MJAHR'.
  GS_KEYINFO-ITEM03   = 'MJAHR'.

  GS_KEYINFO-HEADER04 = 'MBLNR'.
  GS_KEYINFO-ITEM04   = 'MBLNR'.

  GS_KEYINFO-HEADER05 = 'VATNO'.
  GS_KEYINFO-ITEM05   = 'VATNO'.
*
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
  GS_LISTHEADER-INFO = '입고 Due List'(T13).
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

  CLEAR LS_SORT.
  LS_SORT-SPOS      = 2.
  LS_SORT-FIELDNAME = 'MBLNR'.
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

  DATA: LS_HEADER TYPE TY_TAB.

  CLEAR: LS_HEADER.

  CASE R_UCOMM.
    WHEN 'REFE'.
      PERFORM P9000_DUELIST_REFRESH USING  RS_SELFIELD.

    WHEN 'ZTIT001'. " 후속기능
*> 전기처리.
      CLEAR : G_LINE, LS_HEADER, IT_AC_KEY, IT_OPNNO, IT_REQNO.
      REFRESH: IT_AC_KEY, IT_OPNNO, IT_REQNO.
      LOOP AT IT_HEADER WHERE BOX EQ 'X'.
        ADD 1 TO G_LINE.
        MOVE-CORRESPONDING : IT_HEADER TO LS_HEADER,
                             IT_HEADER TO IT_AC_KEY,
                             IT_HEADER TO IT_OPNNO,
                             IT_HEADER TO IT_REQNO.
        COLLECT IT_AC_KEY.
        COLLECT IT_OPNNO.
        COLLECT IT_REQNO.
      ENDLOOP.

      CASE G_LINE.
        WHEN 0.
          MESSAGE S909.   EXIT.
        WHEN OTHERS.
          DESCRIBE TABLE IT_OPNNO LINES G_LINE.
          CASE G_LINE.
            WHEN 0.
              MESSAGE S721.    EXIT.
            WHEN 1.
*              SELECT *
*                INTO CORRESPONDING FIELDS OF TABLE it_ztivac00
*                FROM ztivac00
*                 FOR ALL ENTRIES IN it_ac_key
*               WHERE mblnr  EQ  it_ac_key-mblnr
*                 AND bukrs  EQ  it_ac_key-bukrs
*                 AND mjahr  EQ  it_ac_key-mjahr
*                 AND spras  EQ  sy-langu.
*              IF sy-subrc NE 0.
*                MESSAGE s723.   EXIT.
*              ENDIF.
              LOOP AT IT_AC_KEY.
                CALL FUNCTION 'MRM_INVOICE_LOCK'
                  EXPORTING
                    I_BELNR       = IT_AC_KEY-MBLNR
                    I_GJAHR       = IT_AC_KEY-MJAHR
                  EXCEPTIONS
                    ERROR_MESSAGE = 1.

                IF SY-SUBRC <> 0.
*> Global dequeue
                  CALL FUNCTION 'DEQUEUE_ALL'.
*> Error Message display
                  MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
                ENDIF.
              ENDLOOP.
*> 수입 인수증 생성 Dialog Call
              CALL DIALOG 'Z_TI_AC_CREATE'
                AND SKIP FIRST SCREEN
                EXPORTING
                  G_TCODE     FROM SY-TCODE
*                  it_ztivac00 FROM it_ztivac00
                  IT_REQNO    FROM IT_REQNO
                  IT_OPNNO    FROM IT_OPNNO
                  IT_AC_KEY   FROM IT_AC_KEY
                IMPORTING
                  ZTITACK.
*> Global dequeue
              CALL FUNCTION 'DEQUEUE_ALL'.

*> 인수증 번호가 생성되었을 경우만 Refresh......
              IF NOT ZTITACK-ACDNO IS INITIAL.
                PERFORM P9000_DUELIST_REFRESH USING  RS_SELFIELD.
              ENDIF.
            WHEN OTHERS.
              MESSAGE S722 WITH G_LINE.    EXIT.
          ENDCASE.
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
        MOVE-CORRESPONDING IT_HEADER TO LS_HEADER.
      ELSEIF RS_SELFIELD-TABNAME EQ 'IT_LIST'.
        MOVE-CORRESPONDING IT_LIST   TO LS_HEADER.
      ENDIF.

      CASE RS_SELFIELD-FIELDNAME.
        WHEN 'VATNO'.
          PERFORM  DISPLAY_VA_DOCUMENT(ZTIR0000)
                                          USING LS_HEADER-VATNO.

        WHEN 'EBELN'.
          PERFORM  DISPLAY_PURCHASE_ORDER(ZTIR0000)
                                          USING LS_HEADER-EBELN
                                                LS_HEADER-EBELP.
        WHEN 'REQNO' OR 'REQIT' OR 'OPNNO'.
          PERFORM  DISPLAY_IMPORT_DOCUMENT(ZTIR0000)
                                          USING LS_HEADER-REQNO
                                                SPACE
                                                LS_HEADER-REQIT.
*>by YSH(050120)
        WHEN 'MATNR'.
          PERFORM DISPLAY_MATERIAL_MASTER(ZTIR0000)
                                          USING LS_HEADER-MATNR
                                                LS_HEADER-WERKS
                                                SPACE.
        WHEN 'MBLNR'.
          PERFORM DISPLAY_LIV_DOCUMENT(ZTIR0000)
                                        USING    LS_HEADER-MBLNR
                                                 LS_HEADER-MJAHR
                                                 LS_HEADER-BUKRS.

        WHEN 'LIFNR'.
          PERFORM DISPLAY_VENDOR_MASTER(ZTIR0000)
                                          USING LS_HEADER-LIFNR
                                                LS_HEADER-EKORG.
*
*        WHEN 'IBLNO' OR 'IBLIT'.
*          PERFORM  display_bl_document(ztir0000)
*                                          USING ls_header-iblno
*                                                ls_header-iblit.
*        WHEN OTHERS.
*          PERFORM  display_cc_document(ztir0000)
*                                          USING ls_header-iccno.
*
*
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
*&      Form  get_longtext_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LONGTEXT_DATA .

*> Partner Text
  PERFORM  P1000_GET_TEXTID_AND_TEXT USING ZTITACK+3(10)
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

  CALL FUNCTION 'Z_TI_GET_GOODS_RECEIVE_QUERY'
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
            I_INTERFACE_CHECK              = ' '
            I_CALLBACK_PROGRAM       = G_REPID
*            i_callback_pf_status_set       = ' '
*            i_callback_user_command        = ' '
            IS_LAYOUT                = GS_LAYOUT
            IT_FIELDCAT              = IT_FIELDCAT[]
*            it_excluding                   =
*            IT_SPECIAL_GROUPS              =
            IT_SORT                  = IT_SORT
*            IT_FILTER                      =
*            IS_SEL_HIDE                    =
*            I_SCREEN_START_COLUMN          = 0
*            I_SCREEN_START_LINE            = 0
*            I_SCREEN_END_COLUMN            = 0
*            I_SCREEN_END_LINE              = 0
            I_TABNAME_HEADER         = 'IT_HEADER'
            I_TABNAME_ITEM           = 'IT_LIST'
            I_STRUCTURE_NAME_HEADER  = 'IT_HEADER'
            I_STRUCTURE_NAME_ITEM    = 'IT_LIST'
            IS_KEYINFO               = GS_KEYINFO
            I_DEFAULT                = C_CHARX
            I_SAVE                   = C_CHARA
            IS_VARIANT               = LS_VARIANT
            IT_EVENTS                = IT_EVENTS[]
            IT_EVENT_EXIT            = IT_EVENT_EXIT[]
            IS_PRINT                 = GS_PRINT
*            IS_REPREP_ID             =
*            I_BYPASSING_BUFFER       =
*            I_BUFFER_ACTIVE          =
* IMPORTING
*            E_EXIT_CAUSED_BY_CALLER  =
*            ES_EXIT_CAUSED_BY_USER   =
    TABLES
      T_OUTTAB_HEADER                = IT_HEADER[]
      T_OUTTAB_ITEM                  = IT_LIST[]
 EXCEPTIONS
      PROGRAM_ERROR                  = 1
      OTHERS                         = 2.

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
*&      Form  p9000_duelist_refresh
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
    WHEN 'ZTIMK03'.     ">공급업체.
      PERFORM DISPLAY_VENDOR_MASTER USING ZTITACK-LIFNR
                                          ''.
*    WHEN 'ZTIACDOC'.    ">회계문서.
*      PERFORM account_document_display
*                                       USING ztitgrk-bukrs
*                                             ztitgrk-mjahr
*                                             ztitgrk-mblnr.
*    WHEN 'ZTIMMDOC'.    ">자재문서.
*      PERFORM display_material_doc  USING ztitgrk-mblnr
*                                          ztitgrk-mjahr
*                                          '0000'
*                                          ztitgrk-bukrs.
*
    WHEN 'ZTICHDOC'.    ">변경문서.
      G_OBJEKT   = 'ZTIACCHDOC'.
      G_OBJEKTID = ZTITACK+3(10).
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

*> Item Amount.
*  PERFORM summary_invoice_amount  USING c_success.

ENDFORM.                    " BEFORE_TRANSPORT_PAI
*&---------------------------------------------------------------------*
*&      Form  get_locrct_by_vat_no
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LOCRCT_BY_VAT_NO  USING    P_VATNO
                                    P_EBELN
                                    P_OPNNO
                                    P_REQNO
                                    P_AMDSQ.

ENDFORM.                    " get_locrct_by_vat_no
*&---------------------------------------------------------------------*
*&      Form  get_locrct_by_ebeln
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LOCRCT_BY_EBELN  USING    P_VATNO
                                   P_EBELN
                                   P_OPNNO
                                   P_REQNO
                                   P_AMDSQ.


ENDFORM.                    " get_locrct_by_ebeln
*&---------------------------------------------------------------------*
*&      Form  get_locrct_by_opnno
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LOCRCT_BY_OPNNO  USING    P_VATNO
                                   P_EBELN
                                   P_OPNNO
                                   P_REQNO
                                   P_AMDSQ.


ENDFORM.                    " get_locrct_by_opnno
*&---------------------------------------------------------------------*
*&      Form  get_locrct_by_reqno
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LOCRCT_BY_REQNO  USING    P_VATNO
                                   P_EBELN
                                   P_OPNNO
                                   P_REQNO
                                   P_AMDSQ.
  DATA: L_DDTEXT LIKE G_DDTEXT.

  CHECK  NOT P_REQNO IS INITIAL.

  CLEAR: G_COUNT.
  SELECT  *
    FROM  ZTIVRQ04
   WHERE  REQNO EQ P_REQNO.
    ADD 1 TO G_COUNT.
  ENDSELECT.

  CASE G_COUNT.
    WHEN  0.
      MESSAGE E605 WITH '수입의뢰관리번호' P_REQNO.
    WHEN  1.
      MOVE: ZTIVRQ04-REQNO TO P_REQNO,
            ZTIVRQ04-AMDSQ TO P_AMDSQ.
      EXIT.
    WHEN OTHERS.
  ENDCASE.
  IF SY-SUBRC EQ 0.
    IF ZTIVRQ04-REQTY EQ C_LO.
      IF ZTIVRQ04-DOCST NE C_CHARO.
*> 문서상태 Fixed value read.
        PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIDOCST1'
                                                   SY-LANGU
                                                   ZTIVRQ04-DOCST
                                                   G_DDTEXT
                                                   C_SUCCESS.
        MESSAGE E114 WITH ZTIVRQ04-REQNO ZTIVRQ04-AMDSQ G_DDTEXT.
      ENDIF.
    ELSE.
      MESSAGE E720 WITH ZTIVRQ04-REQTY.
    ENDIF.
  ELSE.
    MESSAGE E605 WITH '수입의뢰관리번호'(X01) P_REQNO.
  ENDIF.

ENDFORM.                    " get_locrct_by_reqno
*&---------------------------------------------------------------------*
*&      Form  p1101_check_input_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P1101_CHECK_INPUT_VALUE .

  DATA: L_BUKRS   LIKE T001-BUKRS,
        L_WERKS   LIKE T001W-WERKS,
        L_MATNR   LIKE MARA-MATNR,
        L_MTART   LIKE T134-MTART,
        L_EBELN   LIKE EKKO-EBELN,
        L_LIFNR   LIKE LFA1-LIFNR,
        L_EKORG   LIKE T024E-EKORG,
        L_EKGRP   LIKE T024-EKGRP.

* Company code
  SELECT *
    FROM T001 UP TO 1 ROWS WHERE BUKRS IN S_BUKRS.
  ENDSELECT.
  IF SY-SUBRC <> 0.
    PERFORM GET_FTEXT(RDDFIE00) USING 'T001' 'BUKRS' SY-LANGU
                                CHANGING DFIES G_SUBRC.
    SET CURSOR FIELD 'S_BUKRS-LOW'.
    MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
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

ENDFORM.                    " p1101_check_input_value
*&---------------------------------------------------------------------*
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P2000_DATA_SELECTIONS .

  DATA: L_MBLNR   LIKE ZTIVAC00-MBLNR.

*> 수입의뢰 데이타 select.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE IT_TAB_H
    FROM ZTIVAC00
   WHERE BUKRS  IN  S_BUKRS        "회사코드.
     AND BUDAT  IN  S_BUDAT        "전기일.
     AND BLDAT  IN  S_BLDAT        "증빙일.
     AND BLART  IN  S_BLART        "전표유형.
     AND EKORG  IN  S_EKORG        "구매조직.
     AND EKGRP  IN  S_EKGRP        "구매그룹.
     AND EBELN  IN  S_EBELN        "구매오더.
     AND REQNO  IN  S_REQNO        "수입의뢰번호.
     AND LIFNR  IN  S_LIFNR        "공급업체.
     AND OPNDT  IN  S_OPNDT        "개설일자.
     AND OPNNO  IN  S_OPNNO        "개설번호.
     AND OPNBK  IN  S_OPNBK        "개설은행.
     AND ZTERM  IN  S_ZTERM        "지급조건.
     AND WAERS  IN  S_WAERS        "통화단위.
     AND CNAM   IN  S_CNAM         "작성인.
     AND CDAT   IN  S_CDAT         "생성일.
     AND UNAM   IN  S_UNAM         "최종변경인.
     AND UDAT   IN  S_UDAT         "변경일
     AND REQTY  EQ  C_LO           "Local L/C만.
     AND BUPLA  IN  S_BUPLA        "사업장.
     AND MATNR  IN  S_MATNR        "자재코드.
     AND WERKS  IN  S_WERKS        "플랜트.
     AND SPRAS  EQ  SY-LANGU       "언어.
     AND STBLG  EQ  SPACE          "취소전표제외.
*     AND vgabe  IN ('2', '3')      "송장만.
     AND VGABE  IN ('2')      "송장만.
*     AND bewtp  IN ('N', 'Q')      "송장만.
     AND BEWTP  IN ('Q')      "송장만.
     AND SHKZG  EQ C_CHARS.        "차변만.

  IF SY-SUBRC NE 0.
    MESSAGE S902.
  ENDIF.

  LOOP AT IT_TAB_H.
    G_TABIX = SY-TABIX.

    MOVE: IT_TAB_H-WRBTR TO IT_TAB_H-WRBTRH,
          IT_TAB_H-DMBTR TO IT_TAB_H-DMBTRH.

    SELECT MBLNR
      INTO L_MBLNR
      FROM ZTITACF UP TO 1 ROWS
     WHERE MJAHR EQ IT_TAB_H-MJAHR
       AND MBLNR EQ IT_TAB_H-MBLNR
       AND BUKRS EQ IT_TAB_H-BUKRS.
    ENDSELECT.
    IF SY-SUBRC EQ 0.
      DELETE IT_TAB_H WHERE MJAHR = IT_TAB_H-MJAHR
                        AND MBLNR = IT_TAB_H-MBLNR
                        AND BUKRS = IT_TAB_H-BUKRS.
      CONTINUE.
    ENDIF.
*> 세금계산서 번호.
    SELECT SINGLE VATNO
      INTO IT_TAB_H-VATNO
      FROM ZTITVAK
     WHERE BUKRS EQ IT_TAB_H-BUKRS
       AND BELNR EQ IT_TAB_H-MBLNR
       AND GJAHR EQ IT_TAB_H-MJAHR.

    MODIFY IT_TAB_H INDEX G_TABIX.

  ENDLOOP.

  DESCRIBE TABLE IT_TAB_H LINES G_LINE.
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

  DATA: L_HEADER  TYPE TY_HEADER.

  REFRESH: IT_HEADER, IT_LIST.
  LOOP AT IT_TAB_H.
    MOVE-CORRESPONDING IT_TAB_H TO : IT_HEADER, IT_LIST.
    READ TABLE IT_HEADER INTO L_HEADER WITH KEY REQNO = IT_HEADER-REQNO
                                                AMDSQ = IT_HEADER-AMDSQ.
    IF SY-SUBRC NE 0.
      COLLECT : IT_HEADER.
    ENDIF.
    APPEND    IT_LIST.
  ENDLOOP.

ENDFORM.                    " p2100_header_and_list_build
*&---------------------------------------------------------------------*
*&      Form  get_invoice_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_INVOICE_DATA .

  DATA: L_MBLNR  LIKE ZTIVAC00-MBLNR,
        LW_TAB   TYPE T_TC_2130.

  READ TABLE IT_OPNNO INDEX 1.
  IF SY-SUBRC NE 0.
    MESSAGE E721.
  ENDIF.

  READ TABLE IT_REQNO INDEX 1.
  IF SY-SUBRC NE 0.
    MESSAGE E721.
  ENDIF.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE IT_ZTIVAC00
    FROM ZTIVAC00
     FOR ALL ENTRIES IN IT_AC_KEY
   WHERE MJAHR  EQ IT_AC_KEY-MJAHR
     AND MBLNR  EQ IT_AC_KEY-MBLNR
     AND BUKRS  EQ IT_AC_KEY-BUKRS
     AND REQTY  EQ  C_LO           "Local L/C만.
     AND SPRAS  EQ  SY-LANGU       "언어.
     AND STBLG  EQ  SPACE          "취소전표제외.
     AND VGABE  IN ('2', '3')      "송장만.
     AND BEWTP  IN ('N', 'Q')      "송장만.
     AND SHKZG  EQ C_CHARS.        "차변만.
  IF SY-SUBRC NE 0.
    MESSAGE E724.
  ENDIF.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE IT_ZTITVAK
    FROM ZTITVAK
     FOR ALL ENTRIES IN IT_AC_KEY
   WHERE BUKRS EQ IT_AC_KEY-BUKRS
     AND BELNR EQ IT_AC_KEY-MBLNR
     AND GJAHR EQ IT_AC_KEY-MJAHR.


*>jp, park(050819) 추가.



  DATA : L_CHECK TYPE I.

  LOOP AT IT_ZTIVAC00.

    SELECT COUNT( * )
      INTO L_CHECK
      FROM ZTITRQP
     WHERE REQNO EQ IT_REQNO-REQNO
      AND  AMDSQ EQ IT_REQNO-AMDSQ
      AND  EBELN EQ IT_ZTIVAC00-EBELN
      AND  EBELP EQ IT_ZTIVAC00-EBELP.
    IF SY-SUBRC <> 0.
      DELETE IT_ZTIVAC00.
      CONTINUE.
    ENDIF.

    MODIFY IT_ZTIVAC00.
  ENDLOOP.


*>수입의뢰 정보.
  MOVE: IT_REQNO-REQNO    TO ZTITACK-REQNO,
        IT_REQNO-AMDSQ    TO ZTITACK-AMDSQ,
        IT_OPNNO-OPNNO    TO ZTITACK-LBANR.

  READ TABLE IT_ZTIVAC00 INDEX 1.
  IF SY-SUBRC EQ 0.
    MOVE: IT_ZTIVAC00-LIFNR TO ZTITACK-LIFNR,
          IT_ZTIVAC00-BUKRS TO ZTITACK-BUKRS,
          IT_ZTIVAC00-EKORG TO ZTITACK-EKORG,
          IT_ZTIVAC00-EKGRP TO ZTITACK-EKGRP,
          IT_ZTIVAC00-OPNNO TO ZTITACK-LBANR,
          IT_ZTIVAC00-OPNDT TO ZTITACK-OPNDT.

    SELECT SINGLE *
      FROM ZTITLO1
     WHERE REQNO  EQ  IT_REQNO-REQNO
       AND AMDSQ  EQ  IT_REQNO-AMDSQ.
    IF SY-SUBRC EQ 0.
      MOVE: ZTITLO1-LOBCD     TO ZTITACK-LOBCD,
            ZTITLO1-LOBNM     TO ZTITACK-OPBNM,
            ZTITLO1-LOBBR     TO ZTITACK-LOBBR,
            IT_ZTIVAC00-OPNBK TO ZTITACK-OPNBK,
*            IT_ZTIVAC00-ESIGN TO ZTITACK-OPBID, "기능개선 96084 삭제
            ZTITLO1-LNOID     TO ZTITACK-OPBID,  "기능개선 96084 추가
            IT_ZTIVAC00-OPAMT TO ZTITACK-OPAMT,
            IT_ZTIVAC00-AKKUR    TO ZTITACK-OEXRT,
            IT_ZTIVAC00-LCDMBTR  TO ZTITACK-OPAMK,
            ZTITLO1-LBENM     TO ZTITACK-VENNM,
*            ZTITLO1-LNONM     TO ZTITACK-ACCNM,
*            ZTITLO1-LNOPR     TO ZTITACK-ACCRE,
*            ZTITLO1-LAPPR1    TO ZTITACK-READ1,
*            ZTITLO1-LAPPR2    TO ZTITACK-READ2,
            SPACE             TO ZTITACK-READ3,
*            ZTITLO1-LNOID     TO ZTITACK-REGNO,
            IT_ZTIVAC00-LSDAT TO ZTITACK-DELDT,
            IT_ZTIVAC00-EXDAT TO ZTITACK-AEXDT,
            SY-UNAME          TO ZTITACK-CNAM,
            SY-DATLO          TO ZTITACK-CDAT,
            SY-TIMLO          TO ZTITACK-CTME,
            SY-UNAME          TO ZTITACK-UNAM,
            SY-DATLO          TO ZTITACK-UDAT,
            SY-TIMLO          TO ZTITACK-UTME.
    ENDIF.

*-{기능개선 96084 삭제 - 전자서명 로직 변경(내국신용장의 전자서명으로..)
*    IF ZTITACK-OPBID IS INITIAL.
*      SELECT SINGLE ESIGN
*        INTO ZTITACK-OPBID
*        FROM ZTSTIG3
*       WHERE PARTI  EQ  C_CHARB
*         AND BUKRS  EQ IT_ZTIVAC00-BUKRS
*         AND EPART  EQ  IT_ZTIVAC00-OPNBK.
*    ENDIF.
*-}기능개선 96084

*> 세금계산서 추가.
    READ TABLE IT_ZTITVAK INDEX 1.
    IF SY-SUBRC EQ 0.
      ZTITACK-VATNO = IT_ZTITVAK-VATNO.
    ENDIF.

*>2/27 KST 수정 : 물품수령인(전선/엠트론)의 상호/대표자명/주소/사업자등록번호를
*>내국신용장 Table 이 아닌 EDI 마스터 Table(ZTSTIG0)에서 가지고 오도록 수정
    IF NOT ZTITACK-BUKRS IS INITIAL.
      SELECT SINGLE NOMNM NOMPR NOAD1 NOAD2 BUSID
        INTO (ZTITACK-ACCNM, ZTITACK-ACCRE, ZTITACK-READ1, ZTITACK-READ2, ZTITACK-REGNO)
        FROM ZTSTIG0
       WHERE BUKRS  EQ ZTITACK-BUKRS.
    ENDIF.

  ENDIF.
*>화면상의 Text를 Master Data 등에서 Read.
  PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.

  LOOP AT IT_ZTIVAC00.
    G_TABIX = SY-TABIX.

    SELECT MBLNR
      INTO L_MBLNR
      FROM ZTITACF UP TO 1 ROWS
     WHERE MJAHR EQ IT_ZTIVAC00-MJAHR
       AND MBLNR EQ IT_ZTIVAC00-MBLNR
       AND BUKRS EQ IT_ZTIVAC00-BUKRS.
    ENDSELECT.
    IF SY-SUBRC EQ 0.
      DELETE IT_TAB_H WHERE MJAHR = IT_ZTIVAC00-MJAHR
                        AND MBLNR = IT_ZTIVAC00-MBLNR
                        AND BUKRS = IT_ZTIVAC00-BUKRS.
      CONTINUE.
    ELSE.
      MODIFY IT_ZTIVAC00 INDEX G_TABIX.
    ENDIF.

    ADD : IT_ZTIVAC00-WRBTR TO ZTITACK-ACAMT,
          IT_ZTIVAC00-DMBTR TO ZTITACK-ACKMT.

    MOVE: IT_ZTIVAC00-BLDAT TO ZTITACK-ACDAT,
          IT_ZTIVAC00-WAERS TO ZTITACK-ACAMTC,
          IT_ZTIVAC00-WAERS TO ZTITACK-OPAMTC,
          T001-WAERS        TO ZTITACK-ACKMTC,
          IT_ZTIVAC00-WAERS TO ZTITACK-TOAMTC,
          IT_ZTIVAC00-KURSF TO ZTITACK-EXCRT.

    READ TABLE IT_TAB INTO LW_TAB
                      WITH KEY EBELN = IT_ZTIVAC00-EBELN
                               EBELP = IT_ZTIVAC00-EBELP
                               ZEKKN = IT_ZTIVAC00-ZEKKN
                               VGABE = IT_ZTIVAC00-VGABE
                               MJAHR = IT_ZTIVAC00-MJAHR
                               MBLNR = IT_ZTIVAC00-MBLNR
                               BUZEI = IT_ZTIVAC00-BUZEI.
    IF SY-SUBRC NE 0.
      MOVE-CORRESPONDING IT_ZTIVAC00 TO LW_TAB.
*      MOVE: IT_ZTIVAC00-
      MOVE: IT_ZTIVAC00-MENGE  TO LW_TAB-ACMNG,
            SY-UNAME           TO LW_TAB-CNAM,
            SY-DATLO           TO LW_TAB-CDAT,
            SY-TIMLO           TO LW_TAB-CTME,
            SY-UNAME           TO LW_TAB-UNAM,
            SY-DATLO           TO LW_TAB-UDAT,
            SY-TIMLO           TO LW_TAB-UTME.
      APPEND LW_TAB TO IT_TAB.
    ENDIF.

    MOVE-CORRESPONDING IT_ZTIVAC00 TO IT_ZTISACF.
    COLLECT IT_ZTISACF.
  ENDLOOP.

*> 회계문서 테이블 View용.
  PERFORM  SET_INVOICE_DOCUMENT_SCREEN.

*> 아이템 Number Setting.
  PERFORM  SET_ITEMS_NUMBER.

ENDFORM.                    " get_invoice_data
*&---------------------------------------------------------------------*
*&      Form  set_ac_initial_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_AC_INITIAL_DATA  USING    P_ZTITACK.


ENDFORM.                    " set_ac_initial_data
*&---------------------------------------------------------------------*
*&      Form  set_invoice_document_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_INVOICE_DOCUMENT_SCREEN .

  DATA: L_BELNR    TYPE   BELNR_D,
        L_GJAHR    TYPE   GJAHR,
        L_WRBTR    TYPE   WRBTR,
        L_AWTYP    LIKE   BKPF-AWTYP,
        L_AWKEY    LIKE   BKPF-AWKEY.

*> 전기이력 Tab 화면의 Visible/Invisible용.
  CLEAR: G_HISTORY_POST.
  DESCRIBE TABLE IT_ZTISACF LINES G_LINE.
  IF G_LINE GT 0.
    MOVE: C_TRUE TO G_HISTORY_POST.
    LOOP AT IT_ZTISACF.
      G_TABIX = SY-TABIX.
      IF IT_ZTISACF-BELNR IS INITIAL.
        L_AWKEY       = IT_ZTISACF-MBLNR.
        L_AWKEY+10(4) = IT_ZTISACF-MJAHR.
        L_AWTYP       = 'RMRP '.

        SELECT SINGLE BELNR GJAHR
          INTO (IT_ZTISACF-BELNR, IT_ZTISACF-GJAHR)
          FROM BKPF
         WHERE AWTYP  EQ  L_AWTYP
           AND AWKEY  EQ  L_AWKEY.

        MODIFY IT_ZTISACF INDEX G_TABIX.
      ENDIF.
      IF IT_ZTISACF-HWAER IS INITIAL.
        MOVE T001-WAERS TO IT_ZTISACF-HWAER.
        MODIFY IT_ZTISACF INDEX G_TABIX.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " set_invoice_document_screen
*&---------------------------------------------------------------------*
*&      Form  set_items_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_ITEMS_NUMBER .

  DATA: L_ACFIT  LIKE ZTITACF-ACFIT,
        L_ACDIT LIKE ZTITACP-ACDIT,
        L_RESG1 LIKE ZTITAC1-RESG1.

  CHECK : G_MODE EQ C_CHARC OR
          G_MODE EQ C_CHARM.


  CLEAR: L_ACFIT.
  LOOP AT IT_ZTISACF.
    ADD 1 TO L_ACFIT.
    IT_ZTISACF-ACFIT = L_ACFIT.
    MODIFY IT_ZTISACF.
  ENDLOOP.

  CLEAR: L_ACDIT.
  LOOP AT IT_TAB INTO G_TC_2130_WA.
    ADD 1 TO L_ACDIT.
    G_TC_2130_WA-ACDIT = L_ACDIT.
    MODIFY IT_TAB FROM G_TC_2130_WA.
  ENDLOOP.

*    CLEAR: g_resg1.
*    LOOP AT it_tab into g_tc_2130_wa.
*      ADD 1 TO g_resg1.
*      g_tc_2130_wa-resg1 = g_resg1.
*      modify it_tab from g_tc_2130_wa.
*    endloop.
*

ENDFORM.                    " set_items_number
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
