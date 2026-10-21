************************************************************************
* Title         :  ZTIR7400F01                                         *
*                                                                      *
* Description   : 수입 기납증/분증 관리 Subroutine Include             *
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
                                USING  P_ZTIVRQ00 STRUCTURE ZTIVRQ00
                                       P_ZTITTXK STRUCTURE ZTITTXK
*                                       p_ztisccit STRUCTURE
*it_ztisccit.
                                       P_ZTISCCIT.
  CLEAR: P_IT_TAB.

  MOVE-CORRESPONDING P_ZTIVRQ00 TO : P_IT_TAB, P_ZTITTXK.

  MOVE: P_ZTIVRQ00-REQNO  TO P_ZTITTXK-REQNO.

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
FORM GET_AND_CHECK_PO_DATA  USING    P_REQNO
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
**>Vendor 체크.
*    IF ZTITTXK-lifnr     NE p_ZTIVRQ00-lifnr AND
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
    PERFORM  SET_LC_LOCK_OBJECT  USING P_REQNO
                                       P_ZTIVRQ00-AMDSQ
                                       P_REQIT
                                       C_LOCK
                                       C_SUCCESS
                                       P_MODIFY.
  ELSE.
    MESSAGE S019(06) WITH P_REQNO.
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
                                     P_ZTIVRQ00 STRUCTURE ZTIVRQ00
                                     P_COUNT.

*  CLEAR: p_ztivrq00.
*
*  SELECT SINGLE * INTO p_ztivrq00
*    FROM ztivrq00
*   WHERE iccno EQ p_iccno
*     AND iccit EQ p_iccit.
*
*  IF sy-subrc EQ 0.
***>Vendor 체크.
**    IF ZTITBLK-lifnr     NE p_ZTIvrq00-lifnr AND
**       NOT ZTITBLK-lifnr IS INITIAL.
**      MESSAGE s205 WITH p_ZTIvrq00-lifnr ZTITBLK-lifnr.
**      p_modify = c_true.
**      EXIT.
**    ENDIF.
***통화키 체크.
**    IF ZTITBLK-waers    NE  p_ZTIvrq00-waers AND
**       p_count           GT  c_zero.
**      MESSAGE s206 WITH p_ZTIvrq00-waers ZTITBLK-waers.
**      p_modify = c_true.
**    ENDIF.
***>기타 체크 로직.
**
**> Lock Object
*    PERFORM  set_cc_lock_object  USING p_iccno
*                                       p_iccit
*                                       c_lock
*                                       c_success
*                                       p_modify.
*  ELSE.
*    MESSAGE s019(06) WITH p_iccno.
*    p_modify = c_true.
*    EXIT.
*  ENDIF.
*
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

  REFRESH: IT_TAB, IT_TAXNO.

  CLEAR: ZTITTXK,
        *ZTITTXK,
*         ztitacp,
*         ztitac1,
*         ztitacf,
         IT_TAB,
         IT_TAXNO,
         LFA1,
        *LFA1,
         W_LFA1,
         W_LFA1_BANK,
         T001,
         T024,
         T024E.

  CLEAR:  GT_CONTROL-TEXTLINES[], GT_CONTROL-TEXTTYPES[].

*
ENDFORM.                    " p3000_set_data_of_screen
*&---------------------------------------------------------------------*
*&      Form  check_for_sub_document_exist
*&---------------------------------------------------------------------*
*  삭제시 후속 문서의 존재여부를 확인함..
*----------------------------------------------------------------------*
FORM CHECK_FOR_SUB_DOCUMENT_EXIST.

  DATA: L_COUNT TYPE I.

*  LOOP AT it_tab INTO g_tc_2130_wa.
*    PERFORM check_bl_sub_document_exist
*                             USING   g_tc_2130_wa-iblno
*                                     g_tc_2130_wa-iblit
*                                     c_error
*                                     g_subrc.
*  ENDLOOP.

*> 비용문서 체크.
  SELECT COUNT( * )
    INTO L_COUNT
    FROM ZTITCSP
   WHERE EXPGR  EQ  C_CHART
     AND REFNO  EQ  ZTITTXK-TAXNO.

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


  DESCRIBE TABLE IT_TAB LINES G_LINE.
  IF G_LINE LE 0.
    MESSAGE S135.
    PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
  ENDIF.

**> 전표증빙일.
*  IF ztittxk-bldat IS INITIAL.
*    PERFORM set_return_message USING 'ZTITTXK' 'BLDAT' c_error.
*  ENDIF.
**> 전표의 전기일.
*  IF ztittxk-budat IS INITIAL.
*    PERFORM set_return_message USING 'ZTITTXK' 'BUDAT' c_error.
*  ENDIF.

  LOOP AT IT_TAB INTO G_TC_2130_WA.
    G_TABIX = SY-TABIX.
*> 기납증수량..
    IF G_TC_2130_WA-RPTNO IS INITIAL.
      MESSAGE S513 WITH G_TABIX '신고(증명)번호'.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.

*> 기납증수량..
    IF G_TC_2130_WA-CSSEQ IS INITIAL.
      MESSAGE S513 WITH G_TABIX '란 번호'.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.

*> 기납증수량..
    IF G_TC_2130_WA-TXMNG IS INITIAL.
      MESSAGE S513 WITH G_TABIX '기납증 Qty.'.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.


*> 관세금액..
    IF G_TC_2130_WA-CUAMT IS INITIAL.
      MESSAGE S513 WITH G_TABIX '관세금액'.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.
*> 과세가격 - 원화.
    IF G_TC_2130_WA-TXPKR IS INITIAL.
      MESSAGE S513 WITH G_TABIX '과세가격 - 원화'.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.
  ENDLOOP.

*--------------------------------------------------------------------
*> 전기용 배부내역.  .
*--------------------------------------------------------------------
  DATA : IT_EKBE         LIKE EKBE       OCCURS 0 WITH HEADER LINE.
  DATA : IT_EKAB         LIKE EKAB       OCCURS 0 WITH HEADER LINE.

  DATA: L_TXMNG     LIKE IT_ZTISTXD-TXMNG,
        L_TXMNG_OLD LIKE IT_ZTISTXD-TXMNG,
        L_TXMNG_YET LIKE IT_ZTISTXD-TXMNG,
        L_TXMNG_T   LIKE IT_ZTISTXD-TXMNG,
        L_TXAMTS    LIKE IT_ZTISTXD-TXAMTS,
        L_MENGE     LIKE EKBE-MENGE,
        L_MENGE_S   LIKE EKBE-MENGE,
        L_MENGE_H   LIKE EKBE-MENGE,
        L_MENGE_T   LIKE EKBE-MENGE,
        L_END.

  REFRESH : IT_ZTISTXD.
  CLEAR: IT_ZTISTXD.

  IF NOT ZTITTXK-TAXNO IS INITIAL.
    DELETE FROM ZTITTXD WHERE TAXNO EQ ZTITTXK-TAXNO.
  ENDIF.

  REFRESH : XZTITTXP.
  LOOP AT IT_TAB INTO G_TC_2130_WA.
    MOVE-CORRESPONDING G_TC_2130_WA TO XZTITTXP.
    APPEND XZTITTXP.
  ENDLOOP.

  LOOP AT XZTITTXP.
    SELECT SINGLE * FROM EKKO
            WHERE EBELN EQ XZTITTXP-EBELN.

    IF EKKO-BSTYP EQ 'K'.   ">일괄계약일 경우.
      SELECT * INTO TABLE IT_EKAB
               FROM EKAB
              WHERE KONNR EQ XZTITTXP-EBELN
                AND KTPNR EQ XZTITTXP-EBELP.

      SELECT * INTO TABLE IT_EKBE          " 입고.
               FROM EKBE
                FOR ALL ENTRIES IN IT_EKAB
              WHERE EBELN EQ IT_EKAB-EBELN
                AND EBELP EQ IT_EKAB-EBELP
                AND VGABE EQ '1'
                AND BEWTP EQ 'E'
                AND SHKZG EQ 'S'.
    ELSE.
      SELECT * INTO TABLE IT_EKBE         " 입고.
               FROM EKBE
              WHERE EBELN EQ XZTITTXP-EBELN
                AND EBELP EQ XZTITTXP-EBELP
                AND VGABE EQ '1'
                AND BEWTP EQ 'E'
                AND SHKZG EQ 'S'.

      IF SY-SUBRC <> 0.
        IF XZTITTXP-EBELN LT '4504235026'.
          SELECT * INTO TABLE IT_EKBE         " 입고.
           FROM ZEKBE
          WHERE EBELN EQ XZTITTXP-EBELN
            AND EBELP EQ XZTITTXP-EBELP
            AND VGABE EQ '1'
            AND BEWTP EQ 'E'
            AND SHKZG EQ 'S'.
        ENDIF.
      ENDIF.

    ENDIF.

    LOOP AT IT_EKBE.
      G_TABIX = SY-TABIX.

*>입고건 중 송장 처리분.
      CLEAR: L_MENGE, L_MENGE_S, L_MENGE_H.

      SELECT SUM( MENGE ) INTO L_MENGE_S
        FROM EKBE
       WHERE EBELN EQ IT_EKBE-EBELN
         AND EBELP EQ IT_EKBE-EBELP
         AND VGABE EQ '2'
         AND BEWTP EQ 'Q'
         AND SHKZG EQ 'S'
         AND LFGJA EQ IT_EKBE-LFGJA
         AND LFBNR EQ IT_EKBE-BELNR
         AND LFPOS EQ IT_EKBE-LFPOS.

      IF SY-SUBRC <> 0 AND XZTITTXP-EBELN LT '4504235026'.
        SELECT SUM( MENGE ) INTO L_MENGE_S
               FROM ZEKBE
              WHERE EBELN EQ IT_EKBE-EBELN
                AND EBELP EQ IT_EKBE-EBELP
                AND VGABE EQ '2'
                AND BEWTP EQ 'Q'
                AND SHKZG EQ 'S'
                AND LFGJA EQ IT_EKBE-LFGJA
                AND LFBNR EQ IT_EKBE-BELNR
                AND LFPOS EQ IT_EKBE-LFPOS.
      ENDIF.

      SELECT SUM( MENGE ) INTO L_MENGE_H
        FROM EKBE
       WHERE EBELN EQ IT_EKBE-EBELN
         AND EBELP EQ IT_EKBE-EBELP
         AND VGABE EQ '2'
         AND BEWTP EQ 'Q'
         AND SHKZG EQ 'H'
         AND LFGJA EQ IT_EKBE-LFGJA
         AND LFBNR EQ IT_EKBE-BELNR
         AND LFPOS EQ IT_EKBE-LFPOS.

      IF SY-SUBRC <> 0 AND XZTITTXP-EBELN LT '4504235026'.
        SELECT SUM( MENGE ) INTO L_MENGE_H
          FROM ZEKBE
         WHERE EBELN EQ IT_EKBE-EBELN
           AND EBELP EQ IT_EKBE-EBELP
           AND VGABE EQ '2'
           AND BEWTP EQ 'Q'
           AND SHKZG EQ 'H'
           AND LFGJA EQ IT_EKBE-LFGJA
           AND LFBNR EQ IT_EKBE-BELNR
           AND LFPOS EQ IT_EKBE-LFPOS.
      ENDIF.

      L_MENGE = L_MENGE_S - L_MENGE_H.

      IF L_MENGE GT 0.
        MOVE L_MENGE TO IT_EKBE-MENGE.
        MODIFY IT_EKBE INDEX G_TABIX.
        ADD L_MENGE TO L_MENGE_T.
      ELSE.
        DELETE IT_EKBE INDEX G_TABIX.
        CONTINUE.
      ENDIF.
    ENDLOOP.

    CLEAR: L_TXMNG_OLD, L_TXMNG_YET, L_TXMNG_T,
           L_TXAMTS, L_END.

*>    자재문서별 처리 잔량 구하기.
    LOOP AT IT_EKBE.
      IF L_END EQ 'Y'.
        EXIT.
      ENDIF.

      SELECT SUM( TXMNG ) INTO L_TXMNG_OLD
        FROM ZTITTXD
       WHERE GJAHR EQ IT_EKBE-GJAHR
         AND BELNR EQ IT_EKBE-BELNR
         AND BUZEI EQ IT_EKBE-BUZEI.

      L_TXMNG_YET = IT_EKBE-MENGE - L_TXMNG_OLD.

*>       자재문서에 처리 잔량이 없는 건은 삭제.
      IF L_TXMNG_YET LE 0.
        CONTINUE.
      ELSE.
        MOVE-CORRESPONDING XZTITTXP TO IT_ZTISTXD.
        MOVE: XZTITTXP-EBELN        TO IT_ZTISTXD-KONNR,
              XZTITTXP-EBELP        TO IT_ZTISTXD-KTPNR,
              XZTITTXP-TXAMTS       TO IT_ZTISTXD-TXAMTS.

        MOVE: IT_EKBE-EBELN  TO IT_ZTISTXD-EBELN,
              IT_EKBE-EBELP  TO IT_ZTISTXD-EBELP,
              IT_EKBE-GJAHR  TO IT_ZTISTXD-GJAHR,
              IT_EKBE-BELNR  TO IT_ZTISTXD-BELNR,
              IT_EKBE-BUZEI  TO IT_ZTISTXD-BUZEI.

        ADD L_TXMNG_YET TO L_TXMNG_T.    " 잔량 SUM ( 배부용 )

        IF L_TXMNG_T GE XZTITTXP-TXMNG.
          IT_ZTISTXD-TXMNG = L_TXMNG_YET -
                            ( L_TXMNG_T - XZTITTXP-TXMNG ).
          L_END = 'Y'.
        ELSE.
          IT_ZTISTXD-TXMNG = L_TXMNG_YET.
        ENDIF.


*>          금액.
        IT_ZTISTXD-TXAMTS = ( IT_ZTISTXD-TXMNG /
                                XZTITTXP-TXMNG )
                              * XZTITTXP-TXMNG.
        ADD IT_ZTISTXD-TXAMTS TO L_TXAMTS.

        IF L_END EQ 'Y'.
          IT_ZTISTXD-TXAMTS = IT_ZTISTXD-TXAMTS -
                                ( L_TXAMTS - XZTITTXP-TXAMTS ).
        ENDIF.

        AT LAST.
          IF L_END NE 'Y'.
            IT_ZTISTXD-TXAMTS = IT_ZTISTXD-TXAMTS -
                               ( L_TXAMTS - XZTITTXP-TXAMTS ).
          ENDIF.
        ENDAT.
        APPEND IT_ZTISTXD.
        CLEAR IT_ZTISTXD.
      ENDIF.
    ENDLOOP.

*    IF sy-subrc NE 0.
*      SELECT SINGLE * FROM ekpo
*              WHERE ebeln EQ xztittxp-ebeln
*                AND ebelp EQ xztittxp-ebelp.
*      IF sy-subrc EQ 0.
*        IF ekpo-webre EQ 'X'.
*          MESSAGE s514 WITH xztittxp-ebeln xztittxp-ebelp.
*          PERFORM set_return_message_fill USING c_error.
*        ELSE.
*          MESSAGE s515 WITH xztittxp-ebeln xztittxp-ebelp.
*          PERFORM set_return_message_fill USING c_error.
*        ENDIF.
*      ENDIF.
*    ENDIF.

  ENDLOOP.

*> 오류정보가 존재시 메시지 상자 POPUP.
  G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                          IM_BUSINESS_OBJ          = L_IF_NULL
                          IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

  IF G_LINE GT 0.
    CALL METHOD G_MESSAGE_HANDLER->SHOW(
        IM_POPUP  = C_TRUE
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
                                  USING  ZTITTXK
                                         G_SUBRC
                                         P_MODE.
  IF G_SUBRC NE C_ZERO.
    MESSAGE A912.   EXIT.
  ENDIF.

*> Long Text 저장 루틴.
  PERFORM SAVE_LONG_TEXT USING ZTITTXK+3(10)
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
      MESSAGE S201 WITH ZTITTXK-TAXNO.
    ELSE.
      SET PARAMETER ID 'ZTITAXNO'  FIELD ZTITTXK-TAXNO.
      MESSAGE S202 WITH ZTITTXK-TAXNO.
    ENDIF.
  ENDIF.

ENDFORM.                    " p8000_save_master_data
*&---------------------------------------------------------------------*
*&      Form  p8100_save_common_data
*&---------------------------------------------------------------------*
FORM P8100_SAVE_COMMON_DATA  TABLES  PT_TAB     STRUCTURE G_TC_2130_WA
                             USING   P_ZTITTXK STRUCTURE ZTITTXK
                                     P_SUBRC    LIKE      SY-SUBRC
                                     P_MODE.

  DATA: L_TAXNO   TYPE ZTIREQNO,
        L_REQTY   TYPE ZTIREQTY,
        L_ZTITTXH LIKE ZTITTXH,
        L_GRSEQ   TYPE ZTIGRSEQ.

  CLEAR: P_SUBRC, L_TAXNO.
  L_REQTY = G_DOCUMENT.

  IF ( SY-TCODE EQ C_CREATE OR  SY-TCODE EQ C_CREATE_D  OR
       SY-TCODE EQ C_NO_DRAFT_DUE_LIST ) AND
     P_ZTITTXK-TAXNO IS INITIAL.

    CALL FUNCTION 'Z_TI_GET_NUMBER_NEXT'
      EXPORTING
        ZMPTY    = L_REQTY
*       BUKRS    =
      IMPORTING
        LCONO    = L_TAXNO
      EXCEPTIONS
        NOT_TYPE = 1
        OTHERS   = 2.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
    L_TAXNO = P_ZTITTXK-TAXNO.
  ENDIF.

  IF  P_ZTITTXK-CNAM IS INITIAL.
    MOVE: SY-UNAME   TO   P_ZTITTXK-CNAM,
          SY-DATLO   TO   P_ZTITTXK-CDAT,
          SY-TIMLO   TO   P_ZTITTXK-CTME.
  ENDIF.

  MOVE: SY-MANDT   TO   P_ZTITTXK-MANDT,
        L_TAXNO    TO   P_ZTITTXK-TAXNO,
        SY-UNAME   TO   P_ZTITTXK-UNAM,
        SY-DATLO   TO   P_ZTITTXK-UDAT,
        SY-TIMLO   TO   P_ZTITTXK-UTME.

  IF OK_CODE_OLD EQ 'ZTIDELETE'.
*> Header table delete.
    DELETE FROM ZTITTXK WHERE TAXNO EQ P_ZTITTXK-TAXNO.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.
*> Item table delete
    DELETE FROM ZTITTXP WHERE TAXNO EQ P_ZTITTXK-TAXNO.
*    IF sy-subrc NE 0.
*      ROLLBACK WORK.   MOVE 4  TO p_subrc.     EXIT.
*    ENDIF.

*> 전기용 Item table delete
    DELETE FROM ZTITTXD WHERE TAXNO EQ P_ZTITTXK-TAXNO.

    DELETE FROM ZTITTXR WHERE TAXNO EQ P_ZTITTXK-TAXNO.
*> 이력 table delete
    DELETE FROM ZTITTXH WHERE TAXNO EQ P_ZTITTXK-TAXNO.
*    IF sy-subrc NE 0.
*      ROLLBACK WORK.   MOVE 4  TO p_subrc.     EXIT.
*    ENDIF.
    EXIT.
  ENDIF.

*> Header table modify.
  MODIFY ZTITTXK FROM P_ZTITTXK.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
  ENDIF.

*> Items table modify.
  DELETE FROM ZTITTXP WHERE TAXNO EQ P_ZTITTXK-TAXNO.
  REFRESH : XZTITTXP.
  LOOP AT IT_TAB INTO G_TC_2130_WA.
    MOVE-CORRESPONDING G_TC_2130_WA TO XZTITTXP.
    XZTITTXP-MANDT = P_ZTITTXK-MANDT.
    XZTITTXP-TAXNO = P_ZTITTXK-TAXNO.
    APPEND XZTITTXP.
  ENDLOOP.

  MODIFY ZTITTXP FROM TABLE XZTITTXP.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
  ENDIF.

*> 계산근거 table modify.
  REFRESH  XZTITTXR.
  DELETE FROM ZTITTXR WHERE TAXNO EQ P_ZTITTXK-TAXNO.
  LOOP AT IT_TAB INTO G_TC_2130_WA.
    MOVE-CORRESPONDING G_TC_2130_WA TO XZTITTXR.
    XZTITTXR-MANDT = P_ZTITTXK-MANDT.
    XZTITTXR-TAXNO = P_ZTITTXK-TAXNO.
    XZTITTXR-TAXLN = G_TC_2130_WA-CSSEQ.
    COLLECT XZTITTXR.
  ENDLOOP.
  MODIFY ZTITTXR FROM TABLE XZTITTXR.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
  ENDIF.

  DELETE FROM ZTITTXD WHERE TAXNO = P_ZTITTXK-TAXNO.
  LOOP AT IT_ZTISTXD.
    IT_ZTISTXD-MANDT = P_ZTITTXK-MANDT.
    IT_ZTISTXD-TAXNO = P_ZTITTXK-TAXNO.
    MODIFY IT_ZTISTXD.
  ENDLOOP.
  MODIFY ZTITTXD FROM TABLE IT_ZTISTXD.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
*    MOVE 4  TO p_subrc.     EXIT.
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

  IF ZTITTXK-BUKRS IS INITIAL.
    CLEAR: T001.
  ELSE.
    SELECT SINGLE * FROM T001
     WHERE BUKRS EQ ZTITTXK-BUKRS.

    SELECT SINGLE * FROM T005
     WHERE LAND1 EQ T001-LAND1.
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

  L_OBJECTID(10) = ZTITTXK+3(10).

  L_TCODE        = SY-TCODE.
  L_UTIME        = SY-TIMLO.
  L_UDATE        = SY-DATLO.
  L_USERNAME     = SY-UNAME.

  IF G_MODE EQ C_CHARC.  ">생성모드일 경우.
    REFRESH : YZTITTXP.
  ENDIF.
*
  LOOP AT XZTITTXP.
    XZTITTXP-KZ = L_UPD.
    MODIFY XZTITTXP.
  ENDLOOP.

  CALL FUNCTION 'ZTITXCHDOC_WRITE_DOCUMENT'
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
*     UPD_ICDTXT_ZTIBLCHDOC   = ' '
      N_ZTITTXK               = ZTITTXK
      O_ZTITTXK               = *ZTITTXK
      UPD_ZTITTXK             = L_UPD
      UPD_ZTITTXP             = L_UPD
      UPD_ZTITTXR             = L_UPD
    TABLES
      ICDTXT_ZTITXCHDOC       = LT_CDTXT
      XZTITTXP                = XZTITTXP
      YZTITTXP                = YZTITTXP
      XZTITTXR                = XZTITTXR
      YZTITTXR                = YZTITTXR.

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

  LOOP AT IT_TAB INTO G_TC_2130_WA.
    IF G_TC_2130_WA-TXZ01 IS INITIAL.
      SELECT SINGLE TXZ01
        INTO G_TC_2130_WA-TXZ01
        FROM EKPO
       WHERE EBELN EQ G_TC_2130_WA-EBELN
         AND EBELP EQ G_TC_2130_WA-EBELP.
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

  IF ZTITTXK-LIFNR IS INITIAL.
    CLEAR: LFA1.
  ELSE.
    SELECT SINGLE * FROM LFA1
     WHERE LIFNR EQ ZTITTXK-LIFNR.
    IF SY-SUBRC NE 0.
      PERFORM MESSAGE_NOT_FOUND_VENDOR USING 'ZTITTXK'
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
FORM CHECK_GR_SUB_DOCUMENT_EXIST  USING    P_TAXNO
                                           P_ICCIT
                                           P_MSGTY
                                           P_SUBRC.
  DATA: L_COUNT TYPE I.

  CLEAR: P_SUBRC.

  CHECK NOT P_TAXNO IS INITIAL.

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
  G_DOCUMENT = C_TX.

* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

  REFRESH: IT_TAB, IT_PO, IT_PONUM,
*           xztitacp, yZTITTXP,
           IT_ZTISTXH.

  CLEAR:   IT_TAB, IT_PO,
*           xZTITTXP, yZTITTXP,
           IT_ZTISTXH,
           ZTITTXK,    ">기납증 Header
          *ZTITTXK,    ">기납증 Header
           LFA1,
          *LFA1,
           W_LFA1,
           W_LFA1_BANK.

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
        WHEN 'ZTISTXIT-EBELN' OR 'ZTISTXIT-EBELP'.
          PERFORM DISPLAY_PURCHASE_ORDER USING G_TC_2130_WA-EBELN
                                               G_TC_2130_WA-EBELP.
        WHEN 'ZTISTXIT-REQNO' OR 'ZTISTXIT-REQIT'.

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
        WHEN 'ZTISTXIT-MATNR'.
          PERFORM DISPLAY_MATERIAL_MASTER USING G_TC_2130_WA-MATNR
                                                G_TC_2130_WA-WERKS
                                                G_TC_2130_WA-LGORT.
*        WHEN 'ZTISGRIT-VBELN' OR 'ZTISGRIT-POSNR'.
*          PERFORM display_inb_document    USING g_tc_2130_wa-vbeln.
      ENDCASE.
    ENDIF.
  ELSE.
    GET CURSOR FIELD G_FIELDNAME.
    IF SY-SUBRC EQ 0.
      G_FINDSCR = SY-DYNNR.
      CHECK OK_CODE EQ 'ZTISELECT'.   ">문서선택.

      CASE G_FIELDNAME.
        WHEN 'ZTITTXK-LIFNR'.
          PERFORM DISPLAY_VENDOR_MASTER USING ZTITTXK-LIFNR
                                              SPACE.
*        WHEN 'ZTITTXK-IBLNO'.
*          PERFORM display_bl_document   USING ztittxk-iblno
*                                              '00000'.
*        WHEN 'ZTITTXK-ICCNO'.
*          PERFORM display_cc_document   USING ztittxk-iccno.
        WHEN 'ZTITTXK-BELNR' OR 'ZTITTXK-GJAHR'.
          PERFORM DISPLAY_LIV_DOCUMENT  USING ZTITTXK-BELNR
                                              ZTITTXK-GJAHR
                                              ZTITTXK-BUKRS.
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
*      MOVE 'ZTILOCIN'     TO ftab-fcode.   APPEND ftab. ">저장위치.
  ENDCASE.

  IF ZTITTXK-POSTS EQ C_CHARY.
    MOVE 'ZTIPOST'      TO FTAB-FCODE.   APPEND FTAB. ">전기.
    MOVE 'ZTICHECK'     TO FTAB-FCODE.   APPEND FTAB. ">점검.
  ELSE.
    MOVE 'ZTIACDOC'     TO FTAB-FCODE.   APPEND FTAB. ">후속문서.
  ENDIF.
*
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
FORM GET_AVAILABLE_LC_ITEM  TABLES   PT_ZTISRQIT STRUCTURE IT_ZTISRQIT
                                     PT_REQNO    STRUCTURE IT_REQNO
                            USING    P_MSGTY
                                     P_DEL_MODE.

  DATA: L_TXMNG   TYPE ZTITXMNG.

  CLEAR: G_COUNT, G_CNT.

  LOOP AT PT_ZTISRQIT.
    G_TABIX = SY-TABIX.
    CLEAR: L_TXMNG.
    SELECT SUM( TXMNG )
      INTO L_TXMNG
      FROM ZTITTXP
     WHERE  EBELN  = PT_ZTISRQIT-EBELN
       AND  EBELP  = PT_ZTISRQIT-EBELP
       AND  REQNO  = PT_ZTISRQIT-REQNO
       AND  REQIT  = PT_ZTISRQIT-REQIT.
*
    PT_ZTISRQIT-TXMNGS = L_TXMNG.
    IF PT_ZTISRQIT-TXMNGS LT 0.
      PT_ZTISRQIT-TXMNGS = 0.
    ENDIF.

    PT_ZTISRQIT-TXMNG =  PT_ZTISRQIT-RQMNG - PT_ZTISRQIT-TXMNGS.

    IF PT_ZTISRQIT-TXMNG LE C_ZERO.
      IF P_DEL_MODE EQ C_TRUE.
        DELETE PT_ZTISRQIT INDEX G_TABIX.
        CONTINUE.
      ELSE.
        PT_ZTISRQIT-TXMNG = 0.
      ENDIF.
    ELSE.
      ADD 1 TO G_CNT.
    ENDIF.

    PT_ZTISRQIT-TXMNGL =  PT_ZTISRQIT-TXMNG.

*> Tree용 Internal table modify.
    ADD 1 TO G_COUNT.
    PT_ZTISRQIT-INDEX = G_COUNT.
    MODIFY PT_ZTISRQIT INDEX G_TABIX.

*> 수입의뢰관리번호별 collect.
    MOVE PT_ZTISRQIT-REQNO TO PT_REQNO-REQNO.
    COLLECT PT_REQNO.
  ENDLOOP.
*
  DESCRIBE TABLE PT_ZTISRQIT LINES G_LINE.
  IF G_LINE EQ 0.
    MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 902.
    EXIT.
  ENDIF.

  IF G_CNT EQ 0.
*    MESSAGE ID 'ZMMI' TYPE c_warning NUMBER 103.
    MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 103.
  ENDIF.

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
**    PERFORM  display_import_document USING g_ZTISTXIT_wa-reqno
**                                           g_ZTISTXIT_wa-amdsq
**                                           g_ZTISTXIT_wa-reqit.
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
      I_STRUCTURE_NAME = 'ZTISTXH'
    CHANGING
      CT_FIELDCAT      = IT_FIELDCAT_LVC[].

  LOOP AT IT_FIELDCAT_LVC.
    CASE IT_FIELDCAT_LVC-FIELDNAME.
      WHEN 'GRSEQ' OR 'BWART' OR 'BLDAT' OR
           'BUDAT'.
        IT_FIELDCAT_LVC-KEY     = C_TRUE.
      WHEN 'MBLNR' OR 'MJAHR'.
        IT_FIELDCAT_LVC-KEY     = C_TRUE.
        IT_FIELDCAT_LVC-HOTSPOT = C_TRUE.
      WHEN 'QBLNR' OR 'QJAHR'.
        IT_FIELDCAT_LVC-KEY     = C_TRUE.
        IT_FIELDCAT_LVC-HOTSPOT = C_TRUE.
      WHEN 'CQBLNR' OR 'CQJAHR'.
        IT_FIELDCAT_LVC-HOTSPOT = C_TRUE.
      WHEN 'CMBLNR' OR 'CMJAHR'.
        IT_FIELDCAT_LVC-HOTSPOT = C_TRUE.
      WHEN 'TAXNO' OR 'FLAG'.
        IT_FIELDCAT_LVC-NO_OUT  = C_TRUE.
      WHEN 'IGRST'.
        IT_FIELDCAT_LVC-NO_OUT  = C_TRUE.
      WHEN 'GRSTX'.
        IT_FIELDCAT_LVC-SCRTEXT_L = '전표상태'.
        IT_FIELDCAT_LVC-SCRTEXT_M = '전표상태'.
        IT_FIELDCAT_LVC-SCRTEXT_S = '전표상태'.
        IT_FIELDCAT_LVC-OUTPUTLEN = 10.
        IT_FIELDCAT_LVC-COL_POS   = 4.
        IT_FIELDCAT_LVC-KEY       = C_TRUE.
      WHEN OTHERS.
    ENDCASE.
    MODIFY IT_FIELDCAT_LVC.
  ENDLOOP.

ENDFORM.                    " SCR2123_FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*&      Form  handle_double_click
*&---------------------------------------------------------------------*
FORM HANDLE_DOUBLE_CLICK  USING  P_ROW P_COLUMN.

  READ TABLE IT_ZTISTXH INDEX P_ROW.

  CHECK SY-SUBRC = 0.

  CASE P_COLUMN.
    WHEN 'CMBLNR' OR 'CMJAHR' OR 'CBUDAT'.
      IF NOT IT_ZTISTXH-CBELNR IS INITIAL.
        PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTISTXH-CBELNR
                                            IT_ZTISTXH-CGJAHR
                                            ZTITTXK-BUKRS.
      ENDIF.
    WHEN OTHERS.
      IF NOT IT_ZTISTXH-BELNR IS INITIAL.
        PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTISTXH-BELNR
                                            IT_ZTISTXH-GJAHR
                                            ZTITTXK-BUKRS.
      ENDIF.
  ENDCASE.

ENDFORM.                    "handle_double_click
*&---------------------------------------------------------------------*
*&      Form  handle_hotspot_click
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK  USING E_ROW_ID    TYPE LVC_S_ROW
                                 E_COLUMN_ID TYPE LVC_S_COL.

  READ TABLE IT_ZTISTXH INDEX E_ROW_ID-INDEX.

  CHECK SY-SUBRC = 0.

  CASE E_COLUMN_ID-FIELDNAME.
    WHEN 'CMBLNR' OR 'CMJAHR' OR 'CBUDAT'.
      IF NOT IT_ZTISTXH-CBELNR IS INITIAL.
        PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTISTXH-CBELNR
                                            IT_ZTISTXH-CGJAHR
                                            ZTITTXK-BUKRS.
      ENDIF.
    WHEN OTHERS.
      IF NOT IT_ZTISTXH-BELNR IS INITIAL.
        PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTISTXH-BELNR
                                            IT_ZTISTXH-GJAHR
                                            ZTITTXK-BUKRS.
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

  DATA: L_AWTYP      LIKE  ACCHD-AWTYP,
        L_AWREF      LIKE  ACCHD-AWREF,
        L_AWORG      LIKE  ACCHD-AWORG,
        L_AWSYS      LIKE  ACCHD-AWSYS,
        L_AWTYP_INCL LIKE  ACCHD-AWTYP,
        L_AWTYP_EXCL LIKE  ACCHD-AWTYP,
        L_BUKRS      LIKE  ACCIT-BUKRS,
        L_VALUTYP    LIKE  ACCCR-VALUTYP   VALUE '0'.

  CHECK NOT P_MBLNR IS INITIAL.

  L_AWREF = P_MBLNR.
  L_AWORG = P_MJAHR.
  L_AWTYP = 'MKPF'.

  CALL FUNCTION 'AC_DOCUMENT_RECORD'
    EXPORTING
      I_AWTYP      = L_AWTYP
      I_AWREF      = L_AWREF
      I_AWORG      = L_AWORG
*     i_awsys      = L_awsys
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

*  MOVE: ztittxk-mblnr  TO ztisscrcom-mblnr,
*        ztittxk-mjahr  TO ztisscrcom-mjahr,
*        ztittxk-bukrs  TO ztisscrcom-bukrs,
*        ztittxk-cbudat TO ztisscrcom-cbudat.
*
*  IF ztisscrcom-cbudat IS INITIAL.
*    ztisscrcom-cbudat = sy-datlo.
*  ENDIF.
*
*  spop-textline1 = '해당 입고문서를 취소하시겠습니까?'.

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
*"BOX.
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   ' ',
*          ' ' 'FIELDNAME'     'BOX',
*          ' ' 'HOTSPOT'       ' ',       " Double Click 효과
*          'E' 'KEY'           ' ',
"수입의뢰 관리번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQK',
*          ' ' 'seltext_m'     'HEADER Middle TEXT(20)',
          ' ' 'FIELDNAME'     'REQNO',
          ' ' 'HOTSPOT'       'X',       " Double Click 효과
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"Amend 차수
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'seltext_m'     'AMEND',
          ' ' 'FIELDNAME'     'AMDSQ',
          ' ' 'JUST'          C_CHARL,
          ' ' 'LZERO'         C_CHARX,
          ' ' 'HOTSPOT'       'X',       " Double Click 효과
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '10',
"문서상태
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'seltext_m'     '문서상태',
          ' ' 'FIELDNAME'     'DOCSTX',
          ' ' 'JUST'          C_CHARL,
          'E' 'OUTPUTLEN'     '12',

"공급업체코드
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'FIELDNAME'     'LIFNR',
          ' ' 'OUTPUTLEN'     12,
          'E' 'HOTSPOT'       'X',

"공급업체명
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'LFA1',
          ' ' 'OUTPUTLEN'     40,
          'E' 'FIELDNAME'     'NAME1',

"유효기일
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'JUST'          C_CHARR," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
*          ' ' 'seltext_m'     '종류',
          ' ' 'FIELDNAME'     'EXDAT',
          'E' 'OUTPUTLEN'     '13',

"최종선적일자
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'JUST'          C_CHARR," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
*          ' ' 'seltext_m'     '종류',
          ' ' 'FIELDNAME'     'LSDAT',
          'E' 'OUTPUTLEN'     '13',

"수입의뢰 종류
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQK',
          ' ' 'seltext_m'     '종류',
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'REQTY',
          'E' 'OUTPUTLEN'     '4',
"신용장 종류 TEXT
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQK',
          ' ' 'seltext_m'     '신용장 종류',
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'ILCTYX',
          'E' 'OUTPUTLEN'     '13',
"수입개설번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'OPNNO',
*          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '17',
"회사코드
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQK',
          ' ' 'FIELDNAME'     'BUKRS',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '4',
"개설일자
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'OPNDT',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',
"개설은행.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'LFA1',
          ' ' 'seltext_m'     '개설은행',
          ' ' 'FIELDNAME'     'NAMET',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '15',

"Offer상
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'LFA1',
          ' ' 'seltext_m'     'Offer상',
          ' ' 'FIELDNAME'     'NAME4',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '15',
"개설통화
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'WAERS',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '4',
"개설금액.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'OPAMT',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'NO_OUT'        'X',
          'E' 'CTABNAME'      'IT_HEADER',
*          ' ' 'OUTPUTLEN'     '10',
*>>>>>>>>>LIST
"BOX.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   ' ',
          ' ' 'FIELDNAME'     'BOX',
          ' ' 'HOTSPOT'       ' ',       " Double Click 효과
          'E' 'KEY'           ' ',

"수입의뢰 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'FIELDNAME'     'REQIT',
          ' ' 'JUST'          C_CHARL," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
          ' ' 'HOTSPOT'       'X',       " Double Click 효과
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"구매전표번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'FIELDNAME'     'EBELN',
          ' ' 'HOTSPOT'       'X',       " Double Click 효과
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '12',
"구매문서 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'FIELDNAME'     'EBELP',
          ' ' 'JUST'          C_CHARL," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
          ' ' 'HOTSPOT'       ' ',       " Double Click 효과
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '12',
"자재그룹.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKPO',
          ' ' 'FIELDNAME'     'MATKL',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '18',
"자재.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISRQIT',
          ' ' 'FIELDNAME'     'MATNR',
          'E' 'OUTPUTLEN'     '20',
"자재내역.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISRQIT',
          ' ' 'FIELDNAME'     'TXZ01',
          'E' 'OUTPUTLEN'     '40',

"P/O 수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKPO',
          ' ' 'seltext_L'     'P/O 수량',
          ' ' 'seltext_m'     'P/O 수량',
          ' ' 'seltext_S'     'P/O 수량',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'MENGE',
          ' ' 'OUTPUTLEN'     '13',
          'E' 'KEY'           ' ',
"수입의뢰수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'JUST'          C_CHARR," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
          ' ' 'FIELDNAME'     'RQMNG',
          ' ' 'OUTPUTLEN'     '13',
          'E' 'KEY'           ' ',

************************************************************
*> For TraSys ECC Upgrade By ASEG Co., Ltd.
************************************************************
*> 2009/02/16
*> Started of Delete
************************************************************
*"B/L 가능 수량
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTISBLIT',
*          ' ' 'QFIELDNAME'    'MEINS',
*          ' ' 'seltext_L'     'B/L가능수량',
*          ' ' 'seltext_m'     'B/L가능수량',
*          ' ' 'seltext_S'     'B/L가능수량',
*          ' ' 'QTABNAME'      'IT_LIST',
*          ' ' 'JUST'          c_charr," (R)ight (L)eft (C)ent.
*          ' ' 'LZERO'         c_charx,
*          ' ' 'OUTPUTLEN'     '13',
*          ' ' 'FIELDNAME'     'BLMNGL',
*          'E' 'KEY'           ' ',
************************************************************
*> Ended of Delete
************************************************************

"B/L 누적수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        'X',
          ' ' 'seltext_L'     'B/L누적수량',
          ' ' 'seltext_m'     'B/L누적수량',
          ' ' 'seltext_S'     'B/L누적수량',
          ' ' 'OUTPUTLEN'     '13',
          ' ' 'FIELDNAME'     'BLMNGS',
          'E' 'KEY'           ' ',

"기본단위
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'FIELDNAME'     'MEINS',
          'E' 'OUTPUTLEN'     '4',
"작성인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'CNAM',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',

"변경인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQS',
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

  GS_KEYINFO-HEADER01 = 'REQNO'.
  GS_KEYINFO-ITEM01   = 'REQNO'.

  GS_KEYINFO-HEADER02 = 'AMDSQ'.
  GS_KEYINFO-ITEM02   = 'AMDSQ'.

*  GS_KEYINFO-HEADER03 = SPACE.
*  GS_KEYINFO-ITEM03   = 'OBJNR'.

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
  GS_LISTHEADER-INFO = '기납증/분증 Due List'(T13).
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
      CLEAR : G_LINE, LS_HEADER.
      LOOP AT IT_HEADER WHERE BOX EQ 'X'.
        ADD 1 TO G_LINE.
        MOVE-CORRESPONDING IT_HEADER TO LS_HEADER.
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
          IF RS_SELFIELD-TABNAME EQ 'IT_HEADER'.
            MOVE-CORRESPONDING IT_HEADER TO LS_HEADER.
          ELSEIF RS_SELFIELD-TABNAME EQ 'IT_LIST'.
            MOVE-CORRESPONDING IT_LIST   TO LS_HEADER.
          ENDIF.
        WHEN 1.
          SET PARAMETER ID 'ZTIREQNO' FIELD LS_HEADER-REQNO.
          CALL TRANSACTION 'ZTIT741' AND SKIP FIRST SCREEN .
        WHEN OTHERS.
          MESSAGE S035(0K).   EXIT.
      ENDCASE.
      PERFORM P9000_DUELIST_REFRESH USING  RS_SELFIELD.

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
        WHEN 'EBELN'.
          PERFORM  DISPLAY_PURCHASE_ORDER(ZTIR0000)
                                          USING LS_HEADER-EBELN
                                                LS_HEADER-EBELP.
        WHEN 'REQNO' OR 'REQIT'.
          PERFORM  DISPLAY_IMPORT_DOCUMENT(ZTIR0000)
                                          USING LS_HEADER-REQNO
                                                SPACE
                                                LS_HEADER-REQIT.

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
  PERFORM  P1000_GET_TEXTID_AND_TEXT USING ZTITTXK+3(10)
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
*&      Form  p9000_duelist_refresh
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P9000_DUELIST_REFRESH
                 USING P_SELFIELD TYPE SLIS_SELFIELD.

*> 검색조건에 해당하는 데이타를 Select.
  PERFORM P2000_DATA_SELECTIONS.
*> Header table과 List(Items) table를 만듬.
  PERFORM P2101_HEADER_AND_LIST_BUILD.
  DESCRIBE TABLE IT_TABH LINES G_LINE.
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
      PERFORM DISPLAY_VENDOR_MASTER USING ZTITTXK-LIFNR
                                          ''.
    WHEN 'ZTICHDOC'.    ">변경문서.
      G_OBJEKT   = 'ZTITXCHDOC'.
      G_OBJEKTID = ZTITTXK+3(10).
      PERFORM DISPLAY_CHANGE_DOCUMENT USING G_OBJEKT
                                            G_OBJEKTID.
    WHEN 'ZTIACDOC'.    ">회계문서.
      PERFORM DISPLAY_LIV_DOCUMENT
                                       USING ZTITTXK-BELNR
                                             ZTITTXK-GJAHR
                                             ZTITTXK-BUKRS.
*    WHEN 'ZTIMMDOC'.    ">자재문서.
*      PERFORM display_material_doc  USING ztittxk-mblnr
*                                          ztittxk-mjahr
*                                          '0000'
*                                          ztittxk-bukrs.

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
  PERFORM SUMMARY_TAX_AMOUNT  USING C_SUCCESS.

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

ENDFORM.                    " p1101_check_input_value
*&---------------------------------------------------------------------*
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P2000_DATA_SELECTIONS .

  DATA: L_RQMNG LIKE ZTITRQP-RQMNG,
        L_COUNT TYPE I.

  CLEAR: G_COUNT, IT_TABH, IT_HEADER, IT_LIST.
  REFRESH : IT_TABH, IT_HEADER, IT_LIST.
*> PROGRESS Display.
  G_LINEN    = 30.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'(P01).
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINEN.

*> Get 수입가능 구매문서 종류 및 지급조건 .
  PERFORM GET_USED_PAYMENT_TERM(ZTIR0000)  TABLES  IT_ZTITIG02
                                           USING   G_SUBRC C_SUCCESS.
  IF G_SUBRC NE 0.
    EXIT.
  ENDIF.

*> 수입의뢰 데이타 select.
  SELECT *
        INTO CORRESPONDING FIELDS OF TABLE IT_TABH
        FROM ZTIVRQ00 AS A JOIN EKPO AS B
             ON  A~EBELN EQ B~EBELN
             AND A~EBELP EQ B~EBELP
        WHERE A~BUKRS  IN S_BUKRS  "회사코드.
          AND A~REQNO  IN S_REQNO  "수입의뢰 관리번호.
          AND A~LIFNR  IN S_LIFNR  "공급업체 계정번호.
          AND A~LIFRE  IN S_LIFRE  "다른 송장발행처.
          AND A~OFFER  IN S_OFFER  "오퍼상(Offer).
          AND A~OPNBK  IN S_OPNBK  "개설은행.
          AND A~EKORG  IN S_EKORG  "구매조직.
          AND A~EKGRP  IN S_EKGRP  "구매그룹.
          AND A~APPCT  IN S_APPCT  "수입자 구분.
          AND A~OPNNO  IN S_OPNNO  "수입개설번호
          AND A~OPNDT  IN S_OPNDT  "개설일자.
          AND A~ZTERM  IN S_ZTERM  "지급조건키.
          AND A~WAERS  IN S_WAERS  "개설통화.
          AND A~INCO1  IN S_INCO1  "인도조건 (파트 1).
          AND A~INCO2  IN S_INCO2  "인도조건 (파트 2).
          AND A~EDIYN  IN S_EDIYN  "EDI 적용여부.
          AND A~REQDT  IN S_REQDT  "개설희망일자.
          AND A~APPUN  IN S_APPUN  "개설의뢰 요청자.
          AND A~APPDT  IN S_APPDT  "개설의뢰 요청일.
          AND A~APPTM  IN S_APPTM  "개설의뢰 요청시간.
          AND A~ACCUN  IN S_ACCUN  "요청접수 담당자.
          AND A~ACCDT  IN S_ACCDT  "요청접수일자.
          AND A~ACCTM  IN S_ACCTM  "요청접수시간.
          AND A~SNDUN  IN S_SNDUN  "개설신청자.
          AND A~SNDDT  IN S_SNDDT  "개설신청일.
          AND A~SNDTM  IN S_SNDTM  "개설신청시간.
          AND A~RCVUN  IN S_RCVUN  "개설등록자.
          AND A~RCVDT  IN S_RCVDT  "개설등록일자.
          AND A~RCVTM  IN S_RCVTM  "개설등록시간.
          AND A~RECID  IN S_RECID  "수신자 ID.
          AND A~RECNM  IN S_RECNM  "수신자 명.
          AND A~RECNO  IN S_RECNO  "문서번호.
          AND A~DOCST  IN S_DOCST  "문서상태.
          AND A~REQIT  IN S_REQIT  "수입의뢰 품목번호.
          AND A~EBELN  IN S_EBELN  "구매전표번호.
          AND A~EBELP  IN S_EBELP  "구매문서 품목번호.
          AND A~CNAM   IN S_CNAM   "작성인.
          AND A~CDAT   IN S_CDAT   "생성일.
          AND A~CTME   IN S_CTME   "생성시간.
          AND A~UNAM   IN S_UNAM   "최종변경인.
          AND A~UDAT   IN S_UDAT   "변경일.
          AND A~UTME   IN S_UTME   "최종변경시간.
          AND A~DCEND  EQ SPACE    "종료지시자.
*>        수입의뢰 종류 중 LO/PU제외.
          AND ( A~REQTY  EQ 'PU'
          OR    A~REQTY  EQ 'LO' )
          AND A~DOCST  EQ 'O'
          AND B~MATKL  IN S_MATKL.

  IF SY-SUBRC NE 0.
    MESSAGE S902.  EXIT.
  ENDIF.

  CLEAR: G_TABIX, G_COUNT, G_CNT.
  LOOP AT IT_TABH.

    G_TABIX = SY-TABIX.

*>인수증 생성된 것만.
    SELECT SINGLE COUNT(*)
       INTO L_COUNT
       FROM ZTITACK
       WHERE REQNO EQ IT_TABH-REQNO.

    IF SY-SUBRC NE 0.
      DELETE IT_TABH INDEX G_TABIX.
      CONTINUE.
    ENDIF.

*   수입의뢰 수량, 누적수량, 가능수량, p/o수량.
    SELECT  SINGLE MENGE WERKS MATNR TXZ01
      INTO  (IT_TABH-MENGE, IT_TABH-WERKS, IT_TABH-MATNR, IT_TABH-TXZ01)
      FROM  EKPO
     WHERE  EBELN  = IT_TABH-EBELN
       AND  EBELP  = IT_TABH-EBELP.
*
*   누적수량.
    SELECT  SUM( TXMNG )
      INTO  IT_TABH-TXMNGS
      FROM  ZTIVTX00
     WHERE  REQNO  = IT_TABH-REQNO
       AND  REQIT  = IT_TABH-REQIT.
*   가능수량.
    IT_TABH-TXMNGL =  IT_TABH-RQMNG - IT_TABH-TXMNGS.

    IF IT_TABH-TXMNGL LE 0.
      DELETE IT_TABH INDEX G_TABIX.
      CONTINUE.
    ENDIF.

*   domain의 value.
    PERFORM GET_DOMAIN_VALUE_TEXT(ZTIR0000) USING :
                          'ZTIDOCST'  IT_TABH-DOCST  IT_TABH-DOCSTX,
                          'ZTIILCTY'  IT_TABH-ILCTY  IT_TABH-ILCTYX.

*   공급업체등/다른 송장발행처/오퍼상(Offer) lifnr/lifre/offer
    SELECT SINGLE NAME1 INTO IT_TABH-NAME1
      FROM LFA1
     WHERE LIFNR EQ IT_TABH-LIFNR.

    SELECT SINGLE NAME1 INTO IT_TABH-NAME4
      FROM LFA1
     WHERE LIFNR EQ IT_TABH-OFFER.
*   개설은행  opnbk
    SELECT SINGLE NAMET INTO IT_TABH-NAMET
      FROM ZTSTIG3
     WHERE EPART EQ IT_TABH-OPNBK.

    ADD 1 TO G_COUNT.

    MOVE 1 TO IT_TABH-COUNT.

    MODIFY IT_TABH INDEX G_TABIX.
  ENDLOOP.

  IF G_COUNT EQ 0.
    MESSAGE S103.   EXIT.
  ENDIF.


ENDFORM.                    " p2000_data_selections
*&---------------------------------------------------------------------*
*&      Form  p2101_header_and_list_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P2101_HEADER_AND_LIST_BUILD .

  DATA: LS_TEMP TYPE TY_TAB.

  LOOP AT IT_TABH.
    MOVE-CORRESPONDING IT_TABH TO : IT_HEADER, IT_LIST.

    READ TABLE IT_HEADER INTO LS_TEMP WITH KEY REQNO = IT_TABH-REQNO.
    IF SY-SUBRC NE 0.
      APPEND : IT_HEADER.
    ENDIF.
    APPEND    IT_LIST.
  ENDLOOP.

ENDFORM.                    " p2101_header_and_list_build
*&---------------------------------------------------------------------*
*&      Form  set_item_number_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_ITEM_NUMBER_BUILD  TABLES   P_IT_TAB   LIKE      IT_TAB
                            USING    P_ZTITTXK STRUCTURE  ZTITTXK.

  DATA: L_LPONR LIKE P_ZTITTXK-LPONR.

  IF G_MODE EQ C_CHARC.
    CLEAR: L_LPONR.
    LOOP AT P_IT_TAB.
      ADD 1 TO L_LPONR.
      MOVE L_LPONR TO P_IT_TAB-TAXIT.
      MODIFY P_IT_TAB.
    ENDLOOP.
    MOVE L_LPONR TO P_ZTITTXK-LPONR.
*  ELSE.
*    CLEAR: g_lines.
*    LOOP AT p_it_tab.
*      IF NOT p_it_tab-iblit IS INITIAL.
*        PERFORM check_bl_sub_document_exist USING p_it_tab-iblno
*                                                  p_it_tab-iblit
*                                                  c_none
*                                                  g_subrc.
*        IF g_subrc NE c_zero.
*          ADD 1 TO g_lines.
*          EXIT.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*    IF g_lines GT c_zero.
*      CLEAR: l_lponr.
*      LOOP AT p_it_tab.
*        IF p_it_tab-iblit IS INITIAL.
*          ADD 1 TO p_ztitblk-lponr.
*          MOVE p_ztitblk-lponr TO p_it_tab-iblit.
*        ENDIF.
*        MODIFY p_it_tab.
*      ENDLOOP.
*    ELSE.
*      CLEAR: l_lponr.
*      LOOP AT p_it_tab.
*        ADD 1 TO l_lponr.
*        MOVE l_lponr TO p_it_tab-iblit.
*        MODIFY p_it_tab.
*      ENDLOOP.
*      MOVE l_lponr TO p_ztitblk-lponr.
*    ENDIF.
  ENDIF.
  CLEAR: L_LPONR.
  LOOP AT P_IT_TAB.
    IF P_IT_TAB-TAXIT GT L_LPONR.
      MOVE P_IT_TAB-TAXIT TO L_LPONR.
    ENDIF.
  ENDLOOP.
  MOVE L_LPONR TO P_ZTITTXK-LPONR.

ENDFORM.                    " set_item_number_build
*&---------------------------------------------------------------------*
*&      Form  get_lc_document_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_BL_DOCUMENT_DATA  TABLES   P_IT_ZTISRQIT  STRUCTURE IT_ZTISRQIT
                            USING   P_REQNO
                                    P_AMDSQ
                                    P_REQIT        TYPE ZTIREQIT
                                    P_MTYPE
                                    P_MSGTY.

  REFRESH IT_REQNO.  CLEAR IT_REQNO.
*  IF p_reqit IS INITIAL.
  CALL FUNCTION 'Z_TI_GET_REQUEST_OF_IMPORT'
    EXPORTING
      REQNO     = P_REQNO
      AMDSQ     = P_AMDSQ
      REQIT     = P_REQIT
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
*  else.
*
*  ENDIF.

  IF SY-SUBRC NE 0.
    IF P_REQIT IS INITIAL.
      MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 217 WITH P_REQNO P_AMDSQ.
    ELSE.
      MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 217
                        WITH P_REQNO P_AMDSQ P_REQIT.
    ENDIF.
  ENDIF.

*>수입의뢰문서의 종류/상태를 검증.
  PERFORM CHECK_REQUEST_OF_IMPORT.

*>수입의뢰문서의 잔량를 검증.
  PERFORM GET_AVAILABLE_LC_ITEM TABLES P_IT_ZTISRQIT
                                       IT_REQNO
                                USING  P_MSGTY
                                       C_FALSE.

ENDFORM.                    " get_lc_document_data
*&---------------------------------------------------------------------*
*&      Form  check_request_of_import
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_REQUEST_OF_IMPORT .

  DATA: L_DDTEXT LIKE G_DDTEXT.

  CASE ZTITRQK-REQTY.
    WHEN C_PU OR C_LO.
      IF ZTITRQS-DOCST NE 'O'.
*> 수입의뢰 종류 Fixed value read.
        PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIDOCST1'
                                                   SY-LANGU
                                                   ZTITRQS-DOCST
                                                   G_DDTEXT
                                                   C_SUCCESS.
        L_DDTEXT = G_DDTEXT.
        MESSAGE E919 WITH L_DDTEXT.
      ENDIF.
    WHEN OTHERS.
*> 수입의뢰 종류 Fixed value read.
      PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIREQTY'
                                                 SY-LANGU
                                                 ZTITRQK-REQTY
                                                 G_DDTEXT
                                                 C_SUCCESS.
      L_DDTEXT = G_DDTEXT.
      MESSAGE E741 WITH L_DDTEXT.
  ENDCASE.

ENDFORM.                    " check_request_of_import
*&---------------------------------------------------------------------*
*&      Form  get_and_check_lc_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_AND_CHECK_LC_DATA  USING    P_REQNO
                                     P_AMDSQ
                                     P_REQIT
                                     P_MODIFY
                                     P_ZTIVRQ00 STRUCTURE ZTIVRQ00
                                     P_COUNT
                                     P_MSGTY.

*  CLEAR: p_ztivrq00.

  IF NOT P_REQNO IS INITIAL.
    SELECT SINGLE * INTO P_ZTIVRQ00
      FROM ZTIVRQ00
     WHERE REQNO EQ P_REQNO
       AND REQIT EQ P_REQIT.
  ELSE.
    SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF P_ZTIVRQ00
      FROM ZTIVPO00
     WHERE EBELN EQ P_ZTIVRQ00-EBELN
       AND EBELP EQ P_ZTIVRQ00-EBELP.
*    p_ztivrq00-rqmng = p_ztivrq00-menge.
    EXIT.
  ENDIF.

  IF SY-SUBRC EQ 0.
    IF NOT ( P_ZTIVRQ00-REQTY EQ C_PU OR
             P_ZTIVRQ00-REQTY EQ C_LO ).
      IF P_ZTIVRQ00-DOCST NE C_CHARO.
*> 수입의뢰 종류 Fixed value read.
        PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIDOCST1'
                                                   SY-LANGU
                                                   P_ZTIVRQ00-DOCST
                                                   G_DDTEXT
                                                   C_SUCCESS.

        MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 229
                          WITH P_ZTIVRQ00-REQNO G_DDTEXT.
        P_MODIFY = C_TRUE.
        EXIT.
      ENDIF.

      IF P_ZTIVRQ00-PPAID EQ C_TRUE.
        MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 223
                          WITH '선급금' P_ZTIVRQ00-REQNO.
        P_MODIFY = C_TRUE.
        EXIT.
      ENDIF.

      IF ZTIVRQ00-RPAID EQ C_TRUE.
        MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 223
                          WITH '유보금' P_ZTIVRQ00-REQNO.
        P_MODIFY = C_TRUE.
        EXIT.
      ENDIF.
    ENDIF.
*>Vendor 체크.
    IF ZTITTXK-LIFNR     NE P_ZTIVRQ00-LIFNR AND
       NOT ZTITBLK-LIFNR IS INITIAL.
      MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 205
                        WITH P_ZTIVRQ00-LIFNR ZTITTXK-LIFNR.
      P_MODIFY = C_TRUE.
      EXIT.
    ENDIF.
*통화키 체크.
    IF ZTITTXK-WAERS    NE  P_ZTIVRQ00-WAERS AND
       P_COUNT           GT  C_ZERO.
      MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 206
                        WITH P_ZTIVRQ00-WAERS ZTITTXK-WAERS.
      P_MODIFY = C_TRUE.
    ENDIF.
**회사코드
*    IF ZTITBLK-bukrs NE p_ZTIvrq00-bukrs AND
*       p_count        GT  c_zero.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 226
*           WITH '회사코드' p_ZTIvrq00-bukrs ZTITBLK-bukrs.
*      p_modify = c_true.
*    ENDIF.

**구매조직
*    IF ZTITBLK-ekorg NE p_ZTIvrq00-ekorg AND
*       p_count        GT  c_zero.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 206
*         WITH '구매조직' p_ZTIvrq00-ekorg ZTITBLK-ekorg.
*      p_modify = c_true.
*    ENDIF.
**구매그룹
*    IF ZTITBLK-ekgrp NE p_ZTIvrq00-ekgrp AND
*       p_count        GT  c_zero.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 206
*         WITH '구매그룹' p_ZTIvrq00-ekgrp ZTITBLK-ekgrp.
*      p_modify = c_true.
*    ENDIF.
**project정의.
*    IF ZTITBLK-pspnr NE p_ZTIvrq00-pspnr AND
*       p_count        GT  c_zero.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 226
*         WITH '프로젝트' p_ZTIvrq00-pspnr ZTITBLK-pspnr.
*      p_modify = c_true.
*    ENDIF.

**운송방법
*    IF ztitblk-fwdty NE p_ztivrq00-fwdty AND
*       p_count        GT  c_zero.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 226
*         WITH '운송방법' p_ztivrq00-fwdty ztitblk-fwdty.
*      p_modify = c_true.
*    ENDIF.
**인도조건
*    IF ztitblk-inco1 NE  p_ztivrq00-inco1 AND
*       p_count        GT  c_zero.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 226
*                        WITH '인도조건' p_ztivrq00-inco1 ztitblk-inco1.
*      p_modify = c_true.
*      EXIT.
*    ENDIF.
**선적항.
*    IF ( ztitblk-fland NE p_ztivrq00-fland OR
*         ztitblk-fport NE p_ztivrq00-fport ) AND
*       p_count        GT  c_zero.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 009
*                        WITH '선적항'.
*      p_modify = c_true.
*    ENDIF.
**도착항.
*    IF ( ztitblk-tland NE p_ztivrq00-tland OR
*         ztitblk-tport NE p_ztivrq00-tport ) AND
*       p_count        GT  c_zero.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 009
*                        WITH '도착항'.
*      p_modify = c_true.
*    ENDIF.
*
*>기타 체크 로직.

*> Lock Object
    PERFORM  SET_LC_LOCK_OBJECT  USING P_REQNO
                                       P_AMDSQ
                                       P_REQIT
                                       C_LOCK
                                       P_MSGTY
                                       P_MODIFY.
  ELSE.
    MESSAGE ID '06' TYPE P_MSGTY NUMBER 019
                    WITH P_REQNO.
    P_MODIFY = C_TRUE.
    EXIT.
  ENDIF.

ENDFORM.                    " get_and_check_lc_data
*&---------------------------------------------------------------------*
*&      Form  get_lc_document_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LC_DOCUMENT_DATA  TABLES   P_IT_ZTISRQIT  STRUCTURE IT_ZTISRQIT
                            USING   P_REQNO
                                    P_AMDSQ
                                    P_REQIT        TYPE ZTIREQIT
                                    P_MTYPE
                                    P_MSGTY.

  REFRESH IT_REQNO.  CLEAR IT_REQNO.
*  IF p_reqit IS INITIAL.
  CALL FUNCTION 'Z_TI_GET_REQUEST_OF_IMPORT'
    EXPORTING
      REQNO     = P_REQNO
      AMDSQ     = P_AMDSQ
      REQIT     = P_REQIT
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
*  else.
*
*  ENDIF.

  IF SY-SUBRC NE 0.
    IF P_REQIT IS INITIAL.
      MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 217 WITH P_REQNO P_AMDSQ.
    ELSE.
      MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 217
                        WITH P_REQNO P_AMDSQ P_REQIT.
    ENDIF.
  ENDIF.

*>수입의뢰문서의 종류/상태를 검증.
  PERFORM CHECK_REQUEST_OF_IMPORT.

*>수입의뢰문서의 잔량를 검증.
  PERFORM GET_AVAILABLE_LC_ITEM TABLES P_IT_ZTISRQIT
                                       IT_REQNO
                                USING  P_MSGTY
                                       C_FALSE.

ENDFORM.                    " get_lc_document_data
*&---------------------------------------------------------------------*
*&      Form  set_tax_document_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_TAX_DOCUMENT_DATA      TABLES P_IT_TAB   LIKE IT_TAB
                                USING  P_ZTIVRQ00 STRUCTURE ZTIVRQ00
                                       P_ZTITTXK STRUCTURE ZTITTXK
                                       P_ZTISRQIT STRUCTURE IT_ZTISRQIT.
  DATA: L_NETWR               TYPE NETWR.
  DATA: L_RQMNGQ TYPE ZTIRQMNG,
        L_PPMNGQ TYPE ZTIPPMNG,
        L_NETWRQ TYPE NETWR,
        L_REFWR  TYPE REFWR,
        L_PPMNGB TYPE ZTIPPMNG,
        L_PPAMTQ TYPE ZTIPPAM2,
        L_PPAMTB TYPE ZTIPPAM2.

  CLEAR: P_IT_TAB.

  MOVE-CORRESPONDING P_ZTIVRQ00 TO : P_IT_TAB, P_ZTITTXK.

  MOVE: P_ZTISRQIT-TXMNG  TO P_IT_TAB-TXMNG,
        P_ZTISRQIT-TXMNGS TO P_IT_TAB-TXMNGS,
        P_ZTISRQIT-TXMNGL TO P_IT_TAB-TXMNGL,
        P_ZTISRQIT-REPOS  TO P_IT_TAB-REPOS,
        P_ZTISRQIT-WEPOS  TO P_IT_TAB-WEPOS.

  MOVE: SY-UNAME TO P_IT_TAB-CNAM,
        SY-DATLO TO P_IT_TAB-CDAT,
        SY-TIMLO TO P_IT_TAB-CTME,
        SY-UNAME TO P_IT_TAB-UNAM,
        SY-DATLO TO P_IT_TAB-UDAT,
        SY-TIMLO TO P_IT_TAB-UTME.

  IF NOT  P_IT_TAB-EBELN IS INITIAL.

* 구매오더 아이템 Read.
    SELECT SINGLE MENGE WERKS LGORT MATNR TXZ01 AS TXTTX MENGE
                  LOEKZ ELIKZ BPRME BPUMZ BPUMN UMREZ
                  UMREN NETPR PEINH UEBTO UEBTK UNTTO
                  REPOS WEPOS
    INTO CORRESPONDING FIELDS OF P_IT_TAB
      FROM EKPO
     WHERE EBELN  EQ  P_IT_TAB-EBELN
       AND EBELP  EQ  P_IT_TAB-EBELP.

*> 수입의뢰 정보 Read.
    IF NOT P_IT_TAB-REQNO IS INITIAL.
      SELECT SINGLE RQMNG NETWR
        INTO (P_IT_TAB-RQMNG, P_IT_TAB-RQAMT)
        FROM ZTIVRQ00
       WHERE REQNO   EQ  P_IT_TAB-REQNO
         AND REQIT   EQ  P_IT_TAB-REQIT.

*> 선급금 참조 수량 집계.
      SELECT  SUM( TXMNG )
        INTO  (P_IT_TAB-TXMNGS)
        FROM  ZTITTXP
       WHERE  REQNO       EQ  P_IT_TAB-REQNO
         AND  REQIT       EQ  P_IT_TAB-REQIT
         AND NOT ( TAXNO  EQ  P_IT_TAB-TAXNO
         AND       TAXIT  EQ  P_IT_TAB-TAXIT ).

      P_IT_TAB-TXMNGL =  P_IT_TAB-RQMNG - P_IT_TAB-TXMNGS.
      IF P_IT_TAB-TXMNGL LE 0.
        P_IT_TAB-TXMNGL = 0.
      ENDIF.
      P_IT_TAB-TXMNG  =  P_IT_TAB-TXMNGL.
      IF P_IT_TAB-TXMNG LE 0.
        EXIT.
      ENDIF.
    ENDIF.

    APPEND P_IT_TAB.
  ENDIF.

*>아이템 번호를 생성함.
  PERFORM SET_ITEM_NUMBER_BUILD TABLES P_IT_TAB
                                USING  P_ZTITTXK.

  PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.

ENDFORM.                    " set_tax_document_data
*&---------------------------------------------------------------------*
*&      Form  set_header_data_move
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_HEADER_DATA_MOVE .

  CALL FUNCTION 'Z_TS_GET_COMPANY_EDI_DATA'
    EXPORTING
      BUKRS     = ZTITTXK-BUKRS
      APPCT     = C_CHARY
    IMPORTING
*     yZTSTIG0  =
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

*>
  READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.

  IF SY-SUBRC EQ 0.
*    SELECT SINGLE *
*      FROM t001k
*     WHERE bwkey EQ ( SELECT bwkey
*                        FROM t001w
*                       WHERE werks  EQ g_tc_2130_wa-werks ).
    SELECT SINGLE *
      FROM T001W
     WHERE WERKS  EQ G_TC_2130_WA-WERKS.
    IF SY-SUBRC EQ 0.
      SELECT SINGLE *
        FROM ZTSTIG1
       WHERE BUKRS  EQ   ZTITTXK-BUKRS
         AND BUPLA  EQ   T001W-J_1BBRANCH.
    ENDIF.

    ZTITTXK-GDSNM = G_TC_2130_WA-TXZ01.
  ENDIF.

  MOVE: T001-WAERS      TO   ZTITTXK-KRCUR,
        'USD'           TO   ZTITTXK-WAERS,
        SY-UNAME        TO   ZTITTXK-CNAM,
        SY-DATLO        TO   ZTITTXK-CDAT,
        SY-TIMLO        TO   ZTITTXK-CTME,
        SY-UNAME        TO   ZTITTXK-UNAM,
        SY-DATLO        TO   ZTITTXK-UDAT,
        SY-TIMLO        TO   ZTITTXK-UTME,
        C_CHARN         TO   ZTITTXK-POSTS,
        ZTSTIG1-NOMNM   TO   ZTITTXK-SELNM,
        ZTSTIG1-NOMPR   TO   ZTITTXK-SELCN,
        ZTSTIG1-NOAD1   TO   ZTITTXK-SELAD,
        ZTSTIG1-BUSID   TO   ZTITTXK-SELNO,
        ZTSTIG1-SELNO   TO   ZTITTXK-SELCO,
        LFA1-NAME1      TO   ZTITTXK-TRNNM,
        LFA1-STCEG      TO   ZTITTXK-TRNNO,
        LFA1-STRAS      TO   ZTITTXK-TRNAD,
        LFA1-J_1KFREPRE TO   ZTITTXK-TRRNM.
*        lfa1-to   ztittxk-TCCNO.

ENDFORM.                    " set_header_data_move
*&---------------------------------------------------------------------*
*&      Module  check_input_value_scr2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_VALUE_SCR2121 INPUT.

  CHECK : G_MODE EQ C_CHARC OR
          G_MODE EQ C_CHARM OR
          G_MODE EQ C_CHARP.

*ZTITTXK-AGAMT
*ZTITTXK-BASNO
*ZTITTXK-BUYAT
*ZTITTXK-BUYDT
*ZTITTXK-CCMAK
*ZTITTXK-CUAMT
*ZTITTXK-CUSOF
*ZTITTXK-EDAMT
*ZTITTXK-GDSNM
*ZTITTXK-INAMT
*ZTITTXK-INLCD
*ZTITTXK-KRCUR
*ZTITTXK-MEINS
*ZTITTXK-PRENO
*ZTITTXK-PRFDT
*ZTITTXK-PROCD
*ZTITTXK-PROF1
*ZTITTXK-PROF2
*ZTITTXK-STAWN
*ZTITTXK-TCCNO
*ZTITTXK-TRNAD
*ZTITTXK-TRNNM
*ZTITTXK-TRNNO
*ZTITTXK-TRRNM
*ZTITTXK-TXAMTS
*ZTITTXK-TXPKR
*ZTITTXK-TXPUS

**> 관세사.
*  IF ztittxk-cusof IS INITIAL.
*    PERFORM no_input_check USING 'ZTITTXK' 'CUSOF' c_error.
*  ENDIF.

  CLEAR: ZTSTIG3-NAMET.
  IF NOT ZTITTXK-CUSOF IS INITIAL.
    SELECT SINGLE *
      FROM ZTSTIG3
     WHERE PARTI EQ C_CHARH
       AND EPART EQ ZTITTXK-CUSOF.
    IF SY-SUBRC NE 0.
      MESSAGE E918 WITH ZTITTXK-CUSOF.
    ENDIF.
  ENDIF.

**> 기납증 제출번호.
*  IF ztittxk-preno IS INITIAL.
*    PERFORM no_input_check USING 'ZTITTXK' 'PRENO' c_error.
*  ENDIF.

*> 근거서류번호.
  IF ZTITTXK-BASNO IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITTXK' 'BASNO' C_ERROR.
  ENDIF.

*> 증명일자..
  IF ZTITTXK-PRFDT IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITTXK' 'PRFDT' C_ERROR.
  ENDIF.

**> 증명구분.
*  IF ztittxk-procd IS INITIAL.
*    PERFORM no_input_check USING 'ZTITTXK' 'PROCD' c_error.
*  ENDIF.
*
*> 양도일자..
  IF ZTITTXK-BUYDT IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITTXK' 'BUYDT' C_ERROR.
  ENDIF.

*> 관세금액..
  IF ZTITTXK-CUAMT IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITTXK' 'CUAMT' C_ERROR.
  ENDIF.

* 20050728 SIMCHO:박태균C요청으로 필수체크 삭제
*> FOB AMOUNT.
*  IF ztittxk-txpus IS INITIAL.
*    PERFORM no_input_check USING 'ZTITTXK' 'TXPUS' c_error.
*  ENDIF.

*> 원화금액.
  IF ZTITTXK-TXPKR IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITTXK' 'TXPKR' C_ERROR.
  ENDIF.


ENDMODULE.                 " check_input_value_scr2121  INPUT
*&---------------------------------------------------------------------*
*&      Form  summary_tax_amount
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SUMMARY_TAX_AMOUNT  USING    P_MSGTY.

  DATA: L_CUAMT   LIKE ZTITTXP-CUAMT,
        L_INAMT   LIKE ZTITTXP-INAMT,
        L_EDAMT   LIKE ZTITTXP-EDAMT,
        L_AGAMT   LIKE ZTITTXP-AGAMT,
        L_TXAMTS  LIKE ZTITTXP-TXAMTS,
        L_TXPKR   LIKE ZTITTXP-TXPKR,
        L_CUAMTS  LIKE ZTITTXP-CUAMT,
        L_INAMTS  LIKE ZTITTXP-INAMT,
        L_AGAMTS  LIKE ZTITTXP-AGAMT,
        L_EDAMTS  LIKE ZTITTXP-EDAMT,
        L_TXAMTSS LIKE ZTITTXP-TXAMTS,
        L_TXPKRS  LIKE ZTITTXP-TXPKR,
        L_NETWRS  LIKE ZTISTXIT-NETWR,
        L_NETWR   LIKE ZTISTXIT-NETWR,
        L_RATE    TYPE F,
        L_CUAMTX  TYPE C,
        L_INAMTX  TYPE C,
        L_EDAMTX  TYPE C,
        L_AGAMTX  TYPE C,
        L_TXAMTX  TYPE C,
        L_TXPKRX  TYPE C.

  ZTITTXK-TXAMTS =
      ZTITTXK-CUAMT + ZTITTXK-INAMT +
      ZTITTXK-EDAMT + ZTITTXK-AGAMT.

  LOOP AT IT_TAB INTO G_TC_2130_WA.

    IF G_MODE EQ C_CHARC OR
       G_MODE EQ C_CHARM OR
       G_MODE EQ C_CHARP.
      IF ZTITTXK-EBELN IS INITIAL.
        ZTITTXK-EBELN = G_TC_2130_WA-EBELN.
      ENDIF.

      IF ZTITTXK-WERKS IS INITIAL.
        ZTITTXK-WERKS = G_TC_2130_WA-WERKS.
      ENDIF.

      IF ZTITTXK-BUPLA IS INITIAL.
        SELECT SINGLE J_1BBRANCH
          INTO ZTITTXK-BUPLA
          FROM T001W
         WHERE WERKS EQ G_TC_2130_WA-WERKS.
      ENDIF.
    ENDIF.

*> 정가계산.
    CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
      EXPORTING
        PEINH = G_TC_2130_WA-PEINH
        BPUMZ = G_TC_2130_WA-BPUMZ
        BPUMN = G_TC_2130_WA-BPUMN
        MENGE = G_TC_2130_WA-TXMNG
        NETPR = G_TC_2130_WA-NETPR
      CHANGING
        NETWR = G_TC_2130_WA-NETWR.

    ADD : G_TC_2130_WA-CUAMT  TO L_CUAMTS,
          G_TC_2130_WA-INAMT  TO L_INAMTS,
          G_TC_2130_WA-EDAMT  TO L_EDAMTS,
          G_TC_2130_WA-AGAMT  TO L_AGAMTS,
          G_TC_2130_WA-TXAMTS TO L_TXAMTSS,
          G_TC_2130_WA-TXPKR  TO L_TXPKRS,
          G_TC_2130_WA-NETWR  TO L_NETWRS.

    MOVE: ZTITTXK-TXRNO       TO G_TC_2130_WA-RPTNO.

    MODIFY IT_TAB FROM G_TC_2130_WA.
  ENDLOOP.

  IF L_CUAMTS NE ZTITTXK-CUAMT.
    L_CUAMTX = C_TRUE.
  ENDIF.

  IF L_INAMTS NE ZTITTXK-INAMT.
    L_INAMTX = C_TRUE.
  ENDIF.

  IF L_EDAMTS NE ZTITTXK-EDAMT.
    L_EDAMTX = C_TRUE.
  ENDIF.

  IF L_AGAMTS NE ZTITTXK-AGAMT.
    L_AGAMTX = C_TRUE.
  ENDIF.

  IF L_TXAMTSS NE ZTITTXK-TXAMTS.
    L_TXAMTX = C_TRUE.
  ENDIF.

  IF L_TXPKRS NE ZTITTXK-TXPKR.
    L_TXPKRX = C_TRUE.
  ENDIF.

  IF L_CUAMTX EQ C_TRUE OR
     L_INAMTX EQ C_TRUE OR
     L_EDAMTX EQ C_TRUE OR
     L_TXAMTX EQ C_TRUE OR
     L_TXPKRX EQ C_TRUE.
    MESSAGE I743.

    LOOP AT IT_TAB INTO G_TC_2130_WA.
      G_TABIX = SY-TABIX.
      L_RATE  = G_TC_2130_WA-NETWR  /  L_NETWRS.
      G_TC_2130_WA-CUAMT  = L_RATE  * ZTITTXK-CUAMT.
      G_TC_2130_WA-INAMT  = L_RATE  * ZTITTXK-INAMT.
      G_TC_2130_WA-EDAMT  = L_RATE  * ZTITTXK-EDAMT.
      G_TC_2130_WA-AGAMT  = L_RATE  * ZTITTXK-AGAMT.
*      g_tc_2130_wa-txamts = l_rate  * ztittxk-txamts.
      G_TC_2130_WA-TXPKR  = L_RATE  * ZTITTXK-TXPKR.

      G_TC_2130_WA-TXAMTS = G_TC_2130_WA-CUAMT +
                            G_TC_2130_WA-INAMT +
                            G_TC_2130_WA-EDAMT +
                            G_TC_2130_WA-AGAMT.

      ADD : G_TC_2130_WA-CUAMT  TO  L_CUAMT,
            G_TC_2130_WA-INAMT  TO  L_INAMT,
            G_TC_2130_WA-EDAMT  TO  L_EDAMT,
            G_TC_2130_WA-AGAMT  TO  L_AGAMT,
            G_TC_2130_WA-TXAMTS TO  L_TXAMTS,
            G_TC_2130_WA-TXPKR  TO  L_TXPKR.
      MODIFY IT_TAB FROM G_TC_2130_WA.
    ENDLOOP.

    READ TABLE IT_TAB INTO G_TC_2130_WA INDEX G_TABIX.

    G_TC_2130_WA-CUAMT  = G_TC_2130_WA-CUAMT -
                        ( L_CUAMT - ZTITTXK-CUAMT ).
    G_TC_2130_WA-INAMT  = G_TC_2130_WA-INAMT -
                        ( L_INAMT - ZTITTXK-INAMT ).
    G_TC_2130_WA-EDAMT  = G_TC_2130_WA-EDAMT -
                        ( L_EDAMT - ZTITTXK-EDAMT ).
    G_TC_2130_WA-AGAMT  = G_TC_2130_WA-AGAMT -
                        ( L_AGAMT - ZTITTXK-AGAMT ).
    G_TC_2130_WA-TXAMTS = G_TC_2130_WA-TXAMTS -
                        ( L_TXAMTS - ZTITTXK-TXAMTS ).
    G_TC_2130_WA-TXPKR = G_TC_2130_WA-TXPKR -
                        ( L_TXPKR - ZTITTXK-TXPKR ).

    MODIFY IT_TAB FROM G_TC_2130_WA INDEX G_TABIX.

  ENDIF.

ENDFORM.                    " summary_tax_amount
*&---------------------------------------------------------------------*
*&      Form  FI_DOCUMENT_CREATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FI_DOCUMENT_CREATE .

  PERFORM  INVOICE_DOCUMENT_CREATE  USING ''
                                          ZTITTXK-BUPLA
                                          C_CHARM.

ENDFORM.                    " FI_DOCUMENT_CREATE
*&---------------------------------------------------------------------*
*&      Form  invoice_document_create
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INVOICE_DOCUMENT_CREATE  USING P_EMPFK    LIKE ZTITCSK-EMPFK
                                    P_BUPLA    LIKE ZTITCSK-BUPLA
                                    P_PTDCL    LIKE ZTITCSK-PTDCL.

  REFRESH: BDCDATA.

  CLEAR: SESSION.
  CTU_PARAMS-DISMODE  = 'E'. ">처리모드
  CTU_PARAMS-UPDMODE  = 'S'. ">갱신모드
  CTU_PARAMS-CATTMODE = ' '. ">CATT 모드...
  CTU_PARAMS-DEFSIZE  = ' '. ">기본화면 크기
  CTU_PARAMS-RACOMMIT = 'X'.
  CTU_PARAMS-NOBINPT  = ' ' .
  CTU_PARAMS-NOBIEND  = ' '.

*> 공용 대화상자(메시지 통일).
  IF OK_CODE EQ 'ZTIPOST'.
    CALL FUNCTION 'Z_TI_POPUP_TO_CONFIRM_MESSAGE'
      EXPORTING
        XMODE  = C_CHARP
      IMPORTING
        ANSWER = G_ANSWER.

    IF G_ANSWER NE C_CHARY.
      EXIT.
    ENDIF.
  ENDIF.

  IF G_ANSWER EQ C_Y.
    IF G_MODE EQ C_CHARC OR
       G_MODE EQ C_CHARM.
      PERFORM CHECK_FOR_DOCUMENT_FIELD USING G_MODE.
      IF G_LINE EQ C_ZERO.
        MESSAGE S911.
*>Switches on the local update task.
        SET UPDATE TASK LOCAL.
*>Data Save.
        PERFORM P8000_SAVE_MASTER_DATA USING G_MODE.
        CHECK G_SUBRC EQ C_ZERO.
      ELSE.
        EXIT.
      ENDIF.
    ENDIF.
*> 관세전가액 처리.
    PERFORM  CREATE_INVOICE_DOCUMENT.
  ENDIF.

** Message preparations
*  PERFORM  set_message_preparations.
*
**> Set posting용 데이타 Move
*  PERFORM  set_invoice_data.
*
*  IF g_document EQ c_cs.
*    PERFORM  check_no_draft_item IN PROGRAM ztir9000 USING g_answer.
*    CHECK g_answer EQ 'J'.
*  ENDIF.
*
**> 전기용 BAPI 함수 Call
*  CASE p_ptdcl.
*    WHEN c_charm.   ">물류송장검증.
*      PERFORM  call_invoice_create_func USING   g_simulation
*                                                p_empfk
*                                                p_bupla
*                                                g_subrc.
*    WHEN c_charf.    ">회계기표(BAPIs).
*      PERFORM  call_account_create_func USING   g_simulation
*                                                g_subrc.
**> 회계전표 부가세 기표일 경우.
*    WHEN c_charv.
*      PERFORM  call_vat_create_func     USING   g_simulation
*                                                g_subrc.
*  ENDCASE.
*
*  IF g_subrc EQ 0.    ">Success
*    IF g_simulation = c_true.
*      CASE p_ptdcl.
*        WHEN c_charm.   ">물류송장검증.
*          PERFORM document_simulation.
*        WHEN c_charf.   ">회계검증.
*          PERFORM document_simulation_fi IN PROGRAM (g_repid)
*                                         USING ok-code.
*        WHEN c_charv.   ">회계검증.
*          PERFORM document_simulation_fi IN PROGRAM (g_repid)
*                                         USING ok-code.
*        WHEN OTHERS.
*          MESSAGE s869.
*      ENDCASE.
*
*      IF ok-code EQ fcobu.
*        CLEAR: g_simulation.
*        CASE p_ptdcl.
*          WHEN c_charm.   ">물류송장검증.
*            PERFORM  call_invoice_create_func USING   g_simulation
*                                                      p_empfk
*                                                      p_bupla
*                                                      g_subrc.
*
*          WHEN c_charf.    ">회계기표.
*            PERFORM  call_account_create_func USING   g_simulation
*                                                      g_subrc.
**> 회계전표 부가세 기표일 경우.
*          WHEN c_charv.
*            PERFORM  call_vat_create_func     USING   g_simulation
*                                                      g_subrc.
*        ENDCASE.
*
*        IF g_subrc EQ 0.    ">Success
*          PERFORM p8000_save_master_data USING 'H'.
*          CASE p_ptdcl.
*            WHEN c_charm.   ">물류송장검증.
*              MESSAGE s260(m8) WITH invoicedocnumber.
*            WHEN OTHERS.
*              MESSAGE s260(m8) WITH invoicedocnumber.
*          ENDCASE.
*          PERFORM p9000_came_to_an_end.
*          PERFORM p9000_program_exit.   ">Program Exit.
*        ENDIF.
*      ENDIF.
*    ELSE.
**>Data Save.
*      PERFORM p8000_save_master_data USING 'H'.
*      CASE p_ptdcl.
*        WHEN c_charm.   ">물류송장검증.
*          MESSAGE s260(m8) WITH invoicedocnumber.
*        WHEN OTHERS.
*          MESSAGE s260(m8) WITH invoicedocnumber.
*      ENDCASE.
*      PERFORM p9000_came_to_an_end.
*      PERFORM p9000_program_exit.   ">Program Exit.
*    ENDIF.
*  ENDIF.

ENDFORM.                    " INVOICE_DOCUMENT_CREATE
*&---------------------------------------------------------------------*
*&      Form  create_invoice_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CREATE_INVOICE_DOCUMENT .

*> 전기확인용 대화화면 Call
  CLEAR: OK_CODE.
*> 전기용 HEADER DATA Fill
  PERFORM   FILL_DEFAULT_HEADER_DATA.
*> 확인 대화상자 Call
  CLEAR: OK_CODE.
  CALL SCREEN '6000' STARTING AT 1 8.
  IF OK_CODE EQ 'ABBR'.
    MESSAGE S900.
    EXIT.
  ELSEIF OK_CODE EQ 'SIMU'.
    CTU_PARAMS-DISMODE  = 'E'. ">처리모드
  ENDIF.

  PERFORM EXECUTE_COLLECTIVE_POSTING.

  LEAVE TO TRANSACTION SY-TCODE.

ENDFORM.                    " create_invoice_document
*&---------------------------------------------------------------------*
*&      Form  fill_default_header_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_DEFAULT_HEADER_DATA .

  SELECT SINGLE *
    FROM ZTITIG00
   WHERE BUKRS EQ T001-BUKRS.

  SELECT SINGLE *
    FROM ZTITIG07
   WHERE BUKRS EQ T001-BUKRS
     AND CSTCT EQ 'T'.

  SELECT SINGLE *
    FROM ZTIVRQ02
   WHERE REQNO  EQ ZTITTXK-REQNO.

  ZTISSCRCOM-MONSC = 'S'.

  MOVE: SY-DATLO         TO    ZTITCSK-BUDAT,
        SY-DATLO         TO    ZTITCSK-BLDAT,
        ZTITIG07-BLART   TO    ZTITCSK-BLART,
        T001-BUKRS       TO    ZTITCSK-BUKRS,
        SY-MANDT         TO    ZTITCSK-MANDT,
        ZTITIG07-BUPLA   TO    ZTITCSK-BUPLA,
        ZTITIG07-GSBER   TO    ZTITCSK-GSBER,
        ZTITIG07-CSTYP   TO    ZTITCSK-CSTYP,
        ZTITIG07-ZTERM   TO    ZTITCSK-ZTERM,
        ZTITIG07-MWSKZ   TO    ZTITCSK-MWSKZ,
        ZTITIG07-ZLSPR   TO    ZTITCSK-ZLSPR,
        ZTITIG07-ZLSCH   TO    ZTITCSK-ZLSCH,
        ZTITIG07-UZAWE   TO    ZTITCSK-UZAWE,
        ZTIVRQ02-OPNNO   TO    ZTITCSK-XBLNR,
        ZTITTXK-LIFNR    TO    ZTITCSK-LIFNR,
        T001-WAERS       TO    ZTITCSK-WAERS,
        ZTITTXK-TXAMTS   TO    ZTITCSK-WRBTR,
        0                TO    ZTITCSK-WMWST.

  SELECT NAME_TEXT
    INTO ZTITCSK-INAME
    FROM ADRP UP TO 1 ROWS
   WHERE PERSNUMBER EQ ( SELECT PERSNUMBER
                           FROM USR21
                          WHERE BNAME EQ SY-UNAME ).

  ENDSELECT.

  PERFORM  GET_DOMAIN_VALUE_TEXT(ZTIR9000)
                                 USING   'ZTIEXPGR'
                                         'T'
                                 CHANGING ZTITCSK-BKTXT.

*  ZTITCSK-sgtxt = ZTITCSK-bktxt.

  SELECT SINGLE *
    FROM LFA1
   WHERE LIFNR  EQ  ZTITTXK-LIFNR.

  CONCATENATE ZTITCSK-BKTXT '(' LFA1-NAME1 ')' INTO ZTITCSK-BKTXT.

*> 입력된 값 체크.
  PERFORM  CHECK_INPUT_VALUE_SCR6000.

ENDFORM.                    " fill_default_header_data
*&---------------------------------------------------------------------*
*&      Form  check_input_value_SCR6000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_INPUT_VALUE_SCR6000 .

  CALL FUNCTION 'FI_VENDOR_DATA'
    EXPORTING
      I_BUKRS = ZTITCSK-BUKRS
      I_LIFNR = ZTITCSK-LIFNR
    IMPORTING
      E_KRED  = VF_KRED.

  ZTITCSK-XCPDK = VF_KRED-XCPDK.
  IF ZTITCSK-ZTERM IS INITIAL.
    ZTITCSK-ZTERM = VF_KRED-ZTERM.
  ENDIF.

  CALL FUNCTION 'FI_TERMS_OF_PAYMENT_PROPOSE'
    EXPORTING
      I_BLDAT = ZTITCSK-BLDAT
      I_BUDAT = ZTITCSK-BUDAT
      I_CPUDT = SY-DATLO
*     i_zfbdt = ZTITCSK-zfbdt
      I_ZTERM = ZTITCSK-ZTERM
    IMPORTING
      E_ZBD1T = ZTITCSK-ZBD1T
      E_ZBD1P = ZTITCSK-ZBD1P
      E_ZBD2T = ZTITCSK-ZBD2T
      E_ZBD2P = ZTITCSK-ZBD2P
      E_ZBD3T = ZTITCSK-ZBD3T
*     e_zlsch = ztitcsk-zlsch
*     e_zschf = ZTITCSK-zlspr
      E_ZFBDT = ZTITCSK-ZFBDT.

ENDFORM.                    " check_input_value_SCR6000
*&---------------------------------------------------------------------*
*&      Form  execute_collective_posting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM EXECUTE_COLLECTIVE_POSTING .

  DATA: L_SUBRC   LIKE SY-SUBRC.

  REFRESH: BDCDATA.

*> build BDC data
  PERFORM BUILD_COLLECTIVE_POSTING_DATA.
*> Call transaction
  PERFORM BDC_TRANSACTION        USING 'ZTIT901' L_SUBRC.
*> build Message internal table.
  PERFORM BUILD_POSTED_MESSAGE   USING L_SUBRC.
*> Error Message Display.
  PERFORM DISPLAY_MESSAGE.

ENDFORM.                    " execute_collective_posting
*&---------------------------------------------------------------------*
*&      Form  build_collective_posting_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_COLLECTIVE_POSTING_DATA .

  DATA: L_TEXT_AMOUT(20),
        L_ICSSQ           TYPE ZTIICSSQ.

  REFRESH: BDCDATA.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR9000'          '0100',
         ' ' 'ZTISSCRCOM-BUKRS'  ZTITCSK-BUKRS,
         ' ' 'ZTISSCRCOM-BUDAT'  ZTITCSK-BUDAT,
         ' ' 'ZTISSCRCOM-BLDAT'  ZTITCSK-BLDAT,
         ' ' 'ZTISSCRCOM-LIFNR'  ZTITCSK-LIFNR,
         ' ' 'ZTISSCRCOM-EXPGR'  'T',
         ' ' 'ZTISSCRCOM-WAERS'  ZTITCSK-WAERS,
         ' ' 'ZTISSCRCOM-BLART'  ZTITCSK-BLART,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR9000'       '2000',
         ' ' 'ZTITCSK-CSTYP'  ZTITCSK-CSTYP,
         ' ' 'ZTITCSK-INAME'  ZTITCSK-INAME,
*         ' ' 'ZTITCSK-BUPLA'  ztitcsk-bupla,
*         ' ' 'ZTITCSK-GSBER'  ztitcsk-gsber,
         ' ' 'ZTITCSK-ZLSPR'  ZTITCSK-ZLSPR,
         ' ' 'ZTITCSK-UZAWE'  ZTITCSK-UZAWE,
         ' ' 'ZTITCSK-ZLSCH'  ZTITCSK-ZLSCH,
         ' ' 'ZTITCSK-ZTERM'  ZTITCSK-ZTERM,
         ' ' 'ZTITCSK-MWSKZ'  ZTITCSK-MWSKZ,
         ' ' 'ZTITCSK-XBLNR'  ZTITCSK-XBLNR,
         ' ' 'ZTITCSK-BKTXT'  ZTITCSK-BKTXT.
*         ' ' 'ZTITCSK-SGTXT'  ZTITCSK-sgtxt.

  IF NOT ZTITIG00-CHKBP IS INITIAL.
    PERFORM BDC_DYNPRO_BUILD USING :
         ' ' 'ZTITCSK-BUPLA'  ZTITCSK-BUPLA.
  ENDIF.
  IF NOT ZTITIG00-CHKBA IS INITIAL.
    PERFORM BDC_DYNPRO_BUILD USING :
         ' ' 'ZTITCSK-GSBER'  ZTITCSK-GSBER.
  ENDIF.

  WRITE ZTITTXK-TXAMTS TO L_TEXT_AMOUT CURRENCY ZTITCSK-WAERS.
  PERFORM    SET_WRITE_NO_MASK(ZTIR9000)
                                    CHANGING  L_TEXT_AMOUT.
*      SELECT *
*        FROM
  PERFORM BDC_DYNPRO_BUILD USING :
         ' ' 'ZTISCSIT-EXPCD(01)'  ZTITIG07-EXPCD,
         ' ' 'ZTISCSIT-TAXNO(01)'  ZTITTXK-TAXNO,
         ' ' 'ZTISCSIT-WRBTR(01)'  L_TEXT_AMOUT,
         ' ' 'ZTISCSIT-MWSKZ(01)'  ZTITCSK-MWSKZ,
         ' ' 'ZTISCSIT-WMWST(01)'  '0',
         ' ' 'ZTISCSIT-FWBAS(01)'  '0'.

  IF OK_CODE EQ 'BUC'.
    PERFORM BDC_DYNPRO_BUILD USING :
           ' ' 'BDC_OKCODE'       '=ZTISAVE'.
  ELSEIF OK_CODE EQ 'SIMU'.
    PERFORM BDC_DYNPRO_BUILD USING :
           ' ' 'BDC_OKCODE'       '=ZTISIMUL'.
  ELSE.
    PERFORM BDC_DYNPRO_BUILD USING :
           ' ' 'BDC_OKCODE'       '=ZTIPOST'.
  ENDIF.

* one-time vendor인 경우.


  IF OK_CODE NE 'SIMU'.
    PERFORM BDC_DYNPRO_BUILD USING :
           'X' 'SAPLSPO1'          '0300',
           ' ' 'BDC_OKCODE'       '=YES'.
  ENDIF.

ENDFORM.                    " build_collective_posting_data
*&---------------------------------------------------------------------*
*&      Form  build_posted_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUILD_POSTED_MESSAGE  USING    P_SUBRC.

  IF P_SUBRC EQ 0.
    MOVE:  SY-MSGID      TO  IT_MSG-MSGID,
           SY-MSGTY      TO  IT_MSG-MSGTY,
           SY-MSGNO      TO  IT_MSG-MSGNO,
           SY-MSGV1      TO  IT_MSG-MSGV1,
           SY-MSGV2      TO  IT_MSG-MSGV2,
           SY-MSGV3      TO  IT_MSG-MSGV3,
           SY-MSGV4      TO  IT_MSG-MSGV4,
           ZTITTXK-TAXNO TO  IT_MSG-REFNO.
    APPEND IT_MSG.
  ELSE.
    LOOP AT MESSTAB WHERE MSGTYP EQ 'E'.
      MOVE : MESSTAB-MSGTYP  TO IT_MSG-MSGTY,
             MESSTAB-MSGID   TO IT_MSG-MSGID,
             MESSTAB-MSGNR   TO IT_MSG-MSGNO,
             MESSTAB-MSGV1   TO IT_MSG-MSGV1,
             MESSTAB-MSGV2   TO IT_MSG-MSGV2,
             MESSTAB-MSGV3   TO IT_MSG-MSGV3,
             MESSTAB-MSGV4   TO IT_MSG-MSGV4,
             ZTITTXK-TAXNO   TO  IT_MSG-REFNO.
      APPEND IT_MSG.
    ENDLOOP.
    IF SY-SUBRC NE 0.
      MESSAGE S926.
      MOVE:  SY-MSGID      TO  IT_MSG-MSGID,
             'E'           TO  IT_MSG-MSGTY,
             SY-MSGNO      TO  IT_MSG-MSGNO,
             SY-MSGV1      TO  IT_MSG-MSGV1,
             SY-MSGV2      TO  IT_MSG-MSGV2,
             SY-MSGV3      TO  IT_MSG-MSGV3,
             SY-MSGV4      TO  IT_MSG-MSGV4,
             ZTITTXK-TAXNO TO  IT_MSG-REFNO.
      APPEND IT_MSG.
    ENDIF.
  ENDIF.

ENDFORM.                    " build_posted_message
*&---------------------------------------------------------------------*
*&      Form  display_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_MESSAGE .

  DESCRIBE TABLE IT_MSG LINES G_LINE.
  IF G_LINE GT 0.
    IF G_LINE EQ 1.
      READ TABLE IT_MSG INDEX 1.
      IF SY-SUBRC EQ 0.
        IF IT_MSG-MSGTY EQ 'E'.
          MESSAGE ID     IT_MSG-MSGID TYPE 'S'
                  NUMBER IT_MSG-MSGNO
                  WITH   IT_MSG-MSGV1  IT_MSG-MSGV2
                         IT_MSG-MSGV3  IT_MSG-MSGV4.
          G_LINE = 0.
        ELSE.
          MESSAGE ID     IT_MSG-MSGID TYPE 'S'
                  NUMBER IT_MSG-MSGNO
                  WITH   IT_MSG-MSGV1  IT_MSG-MSGV2
                         IT_MSG-MSGV3  IT_MSG-MSGV4.
          G_LINE = 1.
        ENDIF.
      ENDIF.
    ELSE.
      CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
        EXPORTING
          XDOCNO_SHOW = SPACE
        TABLES
          XMSG        = IT_MSG.
    ENDIF.
  ENDIF.

ENDFORM.                    " display_message
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
