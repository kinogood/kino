************************************************************************
* Title         :  ZTIR4800F01                                         *
*                                                                      *
* Description   : 보세구역 반출 관리  Subroutine Include               *
*                                                                      *
* Creation Date : 2004/12/21                                           *
*                                                                      *
* Author        : Seog Bong, KANG                                      *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************

*&---------------------------------------------------------------------*
*&      Form  get_and_check_po_data
*&---------------------------------------------------------------------*
*       Get 구매오더 데이타.
*----------------------------------------------------------------------*
FORM get_and_check_po_data  USING    p_ebeln
                                     p_ebelp
                                     p_modify
                                     p_ztivpo00 STRUCTURE ztivpo00
                                     p_count.

*  CLEAR: p_ZTIvpo00.
*
*  SELECT SINGLE * INTO p_ZTIvpo00
*    FROM ZTIvpo00
*   WHERE ebeln EQ p_ebeln
*     AND ebelp EQ p_ebelp.
*
*  IF sy-subrc EQ 0.
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
*
**> Lock Object
*    PERFORM  set_po_lock_object  USING p_ebeln
*                                       p_ebelp
*                                       c_lock
*                                       c_success
*                                       p_modify.
*  ELSE.
*    MESSAGE s019(06) WITH p_ebeln.
*    p_modify = c_true.
*    EXIT.
*  ENDIF.

ENDFORM.                    " get_and_check_po_data

*&---------------------------------------------------------------------*
*&      Form  p3000_set_data_of_screen
*&---------------------------------------------------------------------*
FORM p3000_set_data_of_screen .

* Message preparations
  PERFORM  set_message_preparations.

  REFRESH: it_tab.

  CLEAR: ztitbsk,
         ztitbik,
         ztitbok,
        *ztitbok,
         ztitblk,
         ztitblp,
         ztitrqk,
         ztitrqs,
         ztisrqit,
         ztitrqp,
         it_tab,
         lfa1,
        *lfa1,
         w_lfa1,
         w_lfa1_bank,
         t001,
         t024,
         t024e.

  CLEAR:  gt_control-textlines[], gt_control-texttypes[].


*  MOVE  : '수입상업송장' TO    ZTItivhd-bktxt,
*           sy-datum      TO    ZTItivhd-civdt.  ">개설희망일자.

ENDFORM.                    " p3000_set_data_of_screen
*&---------------------------------------------------------------------*
*&      Form  check_for_sub_document_exist
*&---------------------------------------------------------------------*
*  삭제시 후속 문서의 존재여부를 확인함..
*----------------------------------------------------------------------*
FORM check_for_sub_document_exist.

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
FORM check_for_document_field USING p_mode.

  DATA: l_if_null    TYPE REF TO if_message_obj_mm.

* Message preparations
  PERFORM  set_message_preparations.

**> 수입의뢰종류.
*  IF ZTITBLK-rptty IS INITIAL.
*    PERFORM set_return_message USING 'ZTITBLK' 'RPTTY' c_error.
*  ENDIF.
**> 송장금액.
*  IF ZTITBLK-ivamt IS INITIAL.
*    PERFORM set_return_message USING 'ZTITBLK' 'IVAMT' c_error.
*  ENDIF.
**> 선기명.
*  IF ZTITBLK-rptty IS INITIAL.
*    PERFORM set_return_message USING 'ZTITBLK' 'IVSLN' c_error.
*  ENDIF.
**> ETD.
*  IF ZTITBLK-bletd IS INITIAL.
*    PERFORM set_return_message USING 'ZTITBLK' 'BLETD' c_error.
*  ENDIF.
**> ETA.
*  IF ZTITBLK-bleta IS INITIAL.
*    PERFORM set_return_message USING 'ZTITBLK' 'BLETA' c_error.
*  ENDIF.


*> 오류정보가 존재시 메시지 상자 POPUP.
  g_line = g_message_handler->get_severity_bo(
                          im_business_obj          = l_if_null
                          im_include_child_objects = c_true ).

  IF g_line GT 0.
    CALL METHOD g_message_handler->show( im_popup = c_true
      im_amodal = c_false ).
  ELSE.
    MESSAGE s911.
  ENDIF.

ENDFORM.                    " check_for_document_field
*&---------------------------------------------------------------------*
*&      Form  set_tree_chosen_item
*&---------------------------------------------------------------------*
FORM set_tree_chosen_item .
*  DATA: l_chosen TYPE c.
*
*  LOOP AT it_ZTIsrqit.
*    READ TABLE it_tab INTO g_tc_2130_wa
*                      WITH KEY reqno = it_ZTIsrqit-reqno
*                               reqit = it_ZTIsrqit-reqit.
**                                                 BINARY SEARCH.
*    IF sy-subrc EQ 0.
*      l_chosen = c_true.
*    ELSE.
*      l_chosen = c_false.
*    ENDIF.
*
*    g_node_key  = it_ZTIsrqit-index.
*    g_item_name = 'Column1'.
*
*    CALL METHOD g_tree->item_set_chosen
*      EXPORTING
*        node_key  = g_node_key
*        item_name = g_item_name
*        chosen    = l_chosen
*      EXCEPTIONS
*        OTHERS    = 0.
*    IF sy-subrc NE 0.
*
*    ENDIF.
*  ENDLOOP.

ENDFORM.                    " set_tree_chosen_item
*&---------------------------------------------------------------------*
*&      Form  p8000_save_master_data
*&---------------------------------------------------------------------*
FORM p8000_save_master_data USING p_mode.

*> 공통테이블 적용.
  IF g_mode      EQ c_chary AND
     ok_code_old EQ 'ZTISAVE'.
    p_mode = 'Y'.
  ENDIF.

  PERFORM p8100_save_common_data  TABLES it_tab
                                  USING  ztitbdk
                                         g_subrc
                                         p_mode.
  IF g_subrc NE c_zero.
    MESSAGE a912.   EXIT.
  ENDIF.

*> Long Text 저장 루틴.
  PERFORM save_long_text USING ztitbdk+3(13)
                               c_textobject_header
                               g_subrc.

  IF sy-subrc NE 0.
    ROLLBACK WORK.
    MESSAGE a912.   EXIT.
  ELSE.
*> Change document setting.
    PERFORM p8120_change_document.
*> Commit work.
    COMMIT WORK.
*> Set parameter ID
    IF ok_code_old EQ 'ZTIDELETE'.
      MESSAGE s482 WITH ztitbdk-iccno ztitbdk-bdseq.
    ELSE.
      SET PARAMETER ID 'ZTIICCNO'  FIELD ztitbdk-iccno.
      SET PARAMETER ID 'ZTIBDSEQ'  FIELD ztitbdk-bdseq.
      MESSAGE s481 WITH ztitbdk-iccno ztitbdk-bdseq.
    ENDIF.
  ENDIF.

ENDFORM.                    " p8000_save_master_data
*&---------------------------------------------------------------------*
*&      Form  p8100_save_common_data
*&---------------------------------------------------------------------*
FORM p8100_save_common_data  TABLES  pt_tab     STRUCTURE g_tc_2130_wa
                             USING   p_ztitbdk  STRUCTURE ztitbdk
                                     p_subrc    LIKE      sy-subrc
                                     p_mode.

  DATA: l_iccno TYPE ztiiccno,
        l_bdseq TYPE ztibdseq,
        l_reqty TYPE ztireqty.

  CLEAR: p_subrc, l_iccno.
  l_reqty = 'BD'.

  l_iccno = p_ztitbdk-iccno.
  l_bdseq = p_ztitbdk-bdseq.

  IF  p_ztitbdk-cnam IS INITIAL.
    MOVE: sy-uname   TO   p_ztitbdk-cnam,
          sy-datlo   TO   p_ztitbdk-cdat,
          sy-timlo   TO   p_ztitbdk-ctme.
  ENDIF.

  MOVE: sy-mandt   TO   p_ztitbdk-mandt,
        l_iccno    TO   p_ztitbdk-iccno,
        l_bdseq    TO   p_ztitbdk-bdseq,
        sy-uname   TO   p_ztitbdk-unam,
        sy-datlo   TO   p_ztitbdk-udat,
        sy-timlo   TO   p_ztitbdk-utme.

  IF ok_code_old EQ 'ZTIDELETE'.
*> Header table delete.
    DELETE FROM ztitbdk WHERE iccno EQ p_ztitbdk-iccno
                          AND bdseq EQ p_ztitbdk-bdseq.
    IF sy-subrc NE 0.
      ROLLBACK WORK.   MOVE sy-subrc  TO p_subrc.     EXIT.
    ENDIF.
*> Items table delete.
    DELETE FROM ztitbdp WHERE iccno EQ p_ztitbdk-iccno
                          AND bdseq EQ p_ztitbdk-bdseq.
    IF sy-subrc NE 0.
      ROLLBACK WORK.   MOVE sy-subrc  TO p_subrc.     EXIT.
    ENDIF.
  ELSE.
*> Header table modify.
    MODIFY ztitbdk FROM p_ztitbdk.
    IF sy-subrc NE 0.
      ROLLBACK WORK.   MOVE sy-subrc  TO p_subrc.     EXIT.
    ENDIF.
*> Items table modify.
    DELETE FROM ztitbdp WHERE iccno EQ p_ztitbdk-iccno
                          AND bdseq EQ p_ztitbdk-bdseq.
    REFRESH : xztitbdp.
    LOOP AT it_tab INTO g_tc_2130_wa.
      MOVE-CORRESPONDING g_tc_2130_wa TO xztitbdp.
      xztitbdp-mandt = p_ztitbdk-mandt.
      xztitbdp-iccno = p_ztitbdk-iccno.
      xztitbdp-bdseq = p_ztitbdk-bdseq.
*      xZTITRQP-reqit = sy-tabix.
      APPEND xztitbdp.
    ENDLOOP.
    MODIFY ztitbdp FROM TABLE xztitbdp.
    IF sy-subrc NE 0.
      ROLLBACK WORK.   MOVE sy-subrc  TO p_subrc.     EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    " p8100_save_common_data
*&---------------------------------------------------------------------*
*&      Form  GET_OTHERS_TEXT_BY_MASTER_DATA
*&---------------------------------------------------------------------*
*       화면상의 Text를 Master Data 등에서 Read.
*----------------------------------------------------------------------*
FORM get_others_text_by_master_data .

* 회사코드명.
  IF ztitblk-bukrs IS INITIAL.
    CLEAR: t001.
  ELSE.
    SELECT SINGLE * FROM t001
     WHERE bukrs EQ ztitbdk-bukrs.
  ENDIF.

** 구매조직 SELECT ( T024E )
*  IF ztitblk-ekorg IS INITIAL.
*    CLEAR t024e.
*  ELSE.
*    CALL FUNCTION 'T024E_SINGLE_READ'
*      EXPORTING
*        t024e_ekorg = ztitblk-ekorg
*      IMPORTING
*        wt024e      = t024e
*      EXCEPTIONS
*        not_found   = 1
*        OTHERS      = 2.
*
*    IF sy-subrc NE 0.
*      IF sy-calld NE c_true.
*        MESSAGE w001(mh) WITH ztitblk-ekorg.
*      ENDIF.
*    ENDIF.
*  ENDIF.
*
** 구매그룹 SELECT ( T024 )
*  IF ztitblk-ekgrp IS INITIAL.
*    CLEAR t024.
*  ELSE.
*    CALL FUNCTION 'MM_ARRANG_PURCHASE_GRP_SELECT'
*      EXPORTING
*        purchase_group           = ztitblk-ekgrp
*      IMPORTING
*        e_t024                   = t024
*      EXCEPTIONS
*        purchase_group_not_found = 1
*        OTHERS                   = 2.
*
*    IF sy-subrc NE 0.
*      IF sy-calld NE c_true.
*        MESSAGE w030(mn) WITH ztitblk-ekgrp.
*      ENDIF.
*    ENDIF.
*  ENDIF.
*> Vender master check
  PERFORM  get_import_vendors_text  USING c_success.

ENDFORM.                    " GET_OTHERS_TEXT_BY_MASTER_DATA
*&---------------------------------------------------------------------*
*&      Form  get_used_payment_term
*&---------------------------------------------------------------------*
FORM get_used_payment_term  TABLES   p_it_ztitig02 STRUCTURE ztitig02
                            USING    p_subrc  p_type.

  CLEAR: p_subrc.

  SELECT bsart zterm reqty setyn FROM  ztitig02
    INTO CORRESPONDING FIELDS OF TABLE p_it_ztitig02.

  p_subrc = sy-subrc.

  IF p_subrc NE 0.
    MESSAGE ID 'ZMTI00' TYPE p_type NUMBER 001.
    EXIT.
  ENDIF.

ENDFORM.                    " get_used_payment_term
*&---------------------------------------------------------------------*
*&      Form  GET_available_PO_ITEM
*&---------------------------------------------------------------------*
FORM get_available_po_item  TABLES   p_it_po    STRUCTURE it_po
                                     p_it_ponum STRUCTURE it_ponum
                            USING    p_mtype
                                     p_delete.

  DATA: l_rqmng  LIKE ztitrqp-rqmng.
**
  CLEAR: g_count, g_cnt.

  LOOP AT p_it_po.
    g_tabix = sy-tabix.
    CLEAR: l_rqmng.

    SELECT  SUM( rqmng ) INTO p_it_po-rqmngs FROM ztivrq00
     WHERE  ebeln  = p_it_po-ebeln
       AND  ebelp  = p_it_po-ebelp.

    p_it_po-rqmng =  p_it_po-menge - p_it_po-rqmngs.

    IF p_it_po-rqmng LE c_zero.
      IF p_delete EQ c_true.
        DELETE p_it_po INDEX g_tabix.
        CONTINUE.
      ELSE.
        p_it_po-rqmng = 0.
      ENDIF.
    ELSE.
      ADD 1 TO g_cnt.
    ENDIF.

    p_it_po-rqmngl =  p_it_po-rqmng.

    ADD 1 TO g_count.
    p_it_po-index = g_count.
    MODIFY p_it_po INDEX g_tabix.

    MOVE p_it_po-ebeln TO p_it_ponum-ebeln.
    COLLECT p_it_ponum.
  ENDLOOP.

  DESCRIBE TABLE p_it_po LINES g_line.
  IF g_line EQ 0.
    MESSAGE ID 'ZMTI00' TYPE p_mtype NUMBER 902.
    EXIT.
  ENDIF.

  IF g_cnt EQ 0.
*    MESSAGE ID 'ZMTI00' TYPE c_warning NUMBER 103.
    MESSAGE ID 'ZMTI00' TYPE p_mtype NUMBER 103.
  ENDIF.

ENDFORM.                    " GET_available_PO_ITEM
*&---------------------------------------------------------------------*
*&      Form  p8120_change_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM p8120_change_document .

  DATA: l_objectid              TYPE cdhdr-objectid,
        l_tcode                 TYPE cdhdr-tcode,
        l_utime                 TYPE cdhdr-utime,
        l_udate                 TYPE cdhdr-udate,
        l_username              TYPE cdhdr-username,
        l_cdoc_upd_object       TYPE cdhdr-change_ind,
        l_upd_icdtxt            TYPE char1,
        l_upd                   TYPE char1,
*        l_upd                   TYPE char1,
        lt_cdtxt                TYPE STANDARD TABLE OF cdtxt
                                     INITIAL SIZE 0.

  CASE sy-tcode.
    WHEN c_create OR c_create_d.
      l_cdoc_upd_object = 'I'.
      l_upd_icdtxt      = ' '.
      l_upd             = ' '.
*      l_upd_eban        = ' '.
*      l_upd_ebkn        = ' '.
    WHEN OTHERS.
      l_cdoc_upd_object = 'U'.
      l_upd_icdtxt      = 'U'.
      l_upd             = 'U'.
*      l_upd_eban        = 'U'.
*      l_upd_ebkn        = 'U'.
  ENDCASE.

  IF ok_code_old EQ 'ZTIDELETE'.
    l_cdoc_upd_object = 'D'.
    l_upd_icdtxt      = 'D'.
    l_upd             = 'D'.
*    l_upd_eban        = 'D'.
*    l_upd_ebkn        = 'D'.
  ENDIF.

  l_objectid(13) = ztitbok+3(13).

  l_tcode        = sy-tcode.
  l_utime        = sy-timlo.
  l_udate        = sy-datlo.
  l_username     = sy-uname.

*  IF g_mode EQ c_charc.  ">생성모드일 경우.
*    REFRESH : yZTITBLP, yZTItblct.
*  ENDIF.

  CALL FUNCTION 'ZTIBDCHDOC_WRITE_DOCUMENT'
    EXPORTING
        objectid                      = l_objectid
        tcode                         = l_tcode
        utime                         = l_utime
        udate                         = l_udate
        username                      = l_username
*   PLANNED_CHANGE_NUMBER         = ' '
        object_change_indicator       = l_cdoc_upd_object
*   PLANNED_OR_REAL_CHANGES       = ' '
*   NO_CHANGE_POINTERS            = ' '
*   UPD_ICDTXT_ZTIBLCHDOC         = ' '
        n_ztitbdk                    = ztitbdk
        o_ztitbdk                    = *ztitbdk
        upd_ztitbdk                  = l_upd
        upd_ztitbdp                  = l_upd
    TABLES
      icdtxt_ztibdchdoc             = lt_cdtxt
      xztitbdp                      = xztitbdp
      yztitbdp                      = yztitbdp .

ENDFORM.                    " p8120_change_document
*&---------------------------------------------------------------------*
*&      Form  SET_OTHERS_FIELDS_BY_ITEMS
*&---------------------------------------------------------------------*
*       아이템의 기타 필드들을 fill
*----------------------------------------------------------------------*
FORM set_others_fields_by_items .


*  DATA: l_eindt  LIKE eket-eindt.
*
*  LOOP AT it_tab INTO g_tc_2130_wa.
**> 정가 계산.
*    CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
*      EXPORTING
*        peinh = g_tc_2130_wa-peinh
*        bpumz = g_tc_2130_wa-bpumz
*        bpumn = g_tc_2130_wa-bpumn
*        menge = g_tc_2130_wa-blmng
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
*    IF NOT g_tc_2130_wa-ebeln IS INITIAL.
*      CLEAR: l_eindt.
*      SELECT MIN( eindt ) INTO l_eindt
*        FROM eket
*       WHERE ebeln EQ g_tc_2130_wa-ebeln
*         AND ebelp EQ g_tc_2130_wa-ebelp.
*
*      IF l_eindt IS INITIAL.
*        CLEAR g_tc_2130_wa-eeind.
*      ELSE.
*        WRITE l_eindt TO g_tc_2130_wa-eeind.
*      ENDIF.
*    ENDIF.
*    MODIFY it_tab FROM g_tc_2130_wa.
*  ENDLOOP.

ENDFORM.                    " SET_OTHERS_FIELDS_BY_ITEMS
*&---------------------------------------------------------------------*
*&      Form  get_Import_vendors_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_import_vendors_text USING p_msgty.

  IF ztitbdk-truck IS INITIAL.
    CLEAR: lfa1.
  ELSE.
    SELECT SINGLE * FROM lfa1
     WHERE lifnr EQ ztitbdk-truck.
    IF sy-subrc NE 0.
      PERFORM message_not_found_vendor USING 'ZTITBDK'
                                             'TRUCK'
                                              p_msgty.
    ENDIF.
  ENDIF.

  IF ztitbdk-werksz IS INITIAL.
    CLEAR: t001w.
  ELSE.
    SELECT SINGLE * FROM t001w
     WHERE werks EQ ztitbdk-werksz.
    IF sy-subrc NE 0.

    ENDIF.
  ENDIF.


*  IF NOT ZTITBLK-fwdcd IS INITIAL.
*    SELECT SINGLE * INTO *lfa1
*     FROM  lfa1
*     WHERE lifnr EQ ZTITBLK-fwdcd.
*    IF sy-subrc NE 0.
*      PERFORM message_not_found_vendor USING 'ZTITBLK'
*                                             'FWDCD'
*                                             p_msgty.
*    ELSE.
*      IF ZTITBLK-fwdtx IS INITIAL.
*        MOVE: *lfa1-name1 TO ZTITBLK-fwdtx.
*      ENDIF.
*    ENDIF.
*  ENDIF.

ENDFORM.                    " get_Import_vendors_text
*&---------------------------------------------------------------------*
*&      Form  check_lc_sub_document_exist
*&---------------------------------------------------------------------*
*       하위문서 존재여부 체크.
*----------------------------------------------------------------------*
FORM check_lc_sub_document_exist  USING    p_reqno
                                           p_reqit
                                           p_msgty
                                           p_subrc.
*  DATA: l_count TYPE i.
*
*  CLEAR: p_subrc.
*
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
*
**> 선급금 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ZTITIVP
*   WHERE reqno   EQ  p_reqno
*     AND reqit   EQ  p_reqit.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER '109' WITH '선급금'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.

ENDFORM.                    " check_lc_sub_document_exist
*&---------------------------------------------------------------------*
*&      Form  check_bd_sub_document_exist
*&---------------------------------------------------------------------*
*       하위문서 존재여부 체크.
*----------------------------------------------------------------------*
FORM check_bd_sub_document_exist  USING    p_iccno
                                           p_bdseq
                                           p_ibdsq
                                           p_msgty
                                           p_subrc.
*  DATA: l_count TYPE i.
*
*  CLEAR: p_subrc.
*
**> 통관 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ZTItccit
*   WHERE iblno   EQ  p_iblno
*     AND iblit   EQ  p_iblit.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER '109' WITH 'B/L'.
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
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER '109' WITH 'L/G'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.
*
**> 반입예정정보 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ZTITBSK
*   WHERE iblno   EQ  p_iblno.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER '109' WITH '반입예정정보'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.
*
**> 반입정보 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ZTITBIK
*   WHERE iblno   EQ  p_iblno.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER '109' WITH '반입정보'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.
*
**> 반출정보 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ZTITBOK
*   WHERE iblno   EQ  p_iblno.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER '109' WITH '반출정보'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.
*
**> 송장 문서 체크.
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

ENDFORM.                    " check_bd_sub_document_exist

*&---------------------------------------------------------------------*
*&      Form  SET_INITIAL_VALUE
*&---------------------------------------------------------------------*
FORM set_initial_value .

*> 문서  종류.
  g_document = c_bd.

* Message preparations
  PERFORM  set_message_preparations.

  REFRESH: it_tab, it_po, it_ponum.

  CLEAR:   it_tab, it_po, it_ponum,
           ztitblk,    ">B/L Header
           ztitbsk,    " b/s
           ztitbik,
           ztitbok,
          *ztitbok,
           ztitbdk,
          *ztitbdk,
           ztitbdp,
           lfa1,
          *lfa1,
           w_lfa1,
           w_lfa1_bank.

ENDFORM.                    " SET_INITIAL_VALUE
*&---------------------------------------------------------------------*
*&      Form  double_click_event
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM double_click_event .

  CHECK g_fieldname IS INITIAL.

  GET CURSOR LINE g_findline.
  IF sy-subrc EQ 0.
    GET CURSOR FIELD g_fieldname.
    IF sy-subrc EQ 0.
      g_findscr = sy-dynnr.
      READ TABLE it_tab INTO g_tc_2130_wa INDEX g_findline.
      IF sy-subrc NE 0.
        EXIT.
      ENDIF.
      CHECK ok_code EQ 'ZTISELECT'.   ">문서선택.

      CASE g_fieldname.
        WHEN 'ZTISBLIT-EBELN' OR 'ZTISBLIT-EBELP'.
          PERFORM display_purchase_order USING g_tc_2130_wa-ebeln
                                               g_tc_2130_wa-ebelp.
        WHEN 'ZTISBLIT-REQNO' OR 'ZTISBLIT-REQIT'.
          SELECT SINGLE amdsq
            INTO ztivrq00-amdsq
            FROM ztivrq00
           WHERE reqno  EQ  g_tc_2130_wa-reqno
             AND reqit  EQ  g_tc_2130_wa-reqit.
          IF sy-subrc EQ 0.
            PERFORM display_import_document USING g_tc_2130_wa-reqno
                                                  ztivrq00-amdsq
                                                  g_tc_2130_wa-reqit.
          ENDIF.
        WHEN 'ZTISBLIT-MATNR'.
          PERFORM display_material_master USING g_tc_2130_wa-matnr
                                                g_tc_2130_wa-werks
                                                g_tc_2130_wa-lgort.
      ENDCASE.
    ENDIF.
  ELSE.
    GET CURSOR FIELD g_fieldname.
    IF sy-subrc EQ 0.
      g_findscr = sy-dynnr.
      CHECK ok_code EQ 'ZTISELECT'.   ">문서선택.

      CASE g_fieldname.
        WHEN 'ZTITBLK-LIFNR'.
          PERFORM display_vendor_master USING ztitrqk-lifnr
                                              ztitrqk-ekorg.
      ENDCASE.
    ENDIF.
  ENDIF.

ENDFORM.                    " double_click_event
*&---------------------------------------------------------------------*
*&      Form  set_item_number_build
*&---------------------------------------------------------------------*
*       아이템 번호를 생성함.
*----------------------------------------------------------------------*
FORM set_item_number_build  TABLES   p_it_tab   LIKE      it_tab
                            USING    p_ztitbdk  STRUCTURE ztitbdk.

  DATA: l_lponr LIKE p_ztitbdk-lponr.

  IF g_mode EQ c_charc.
    CLEAR: l_lponr.
    LOOP AT p_it_tab.
      ADD 1 TO l_lponr.
      MOVE l_lponr TO p_it_tab-ibdsq.
      MODIFY p_it_tab.
    ENDLOOP.
    MOVE l_lponr TO p_ztitbdk-lponr.
  ELSE.
    CLEAR: g_lines.
    LOOP AT p_it_tab.
      IF NOT p_it_tab-ibdsq IS INITIAL.
        PERFORM check_bd_sub_document_exist USING p_it_tab-iccno
                                                  p_it_tab-bdseq
                                                  p_it_tab-ibdsq
                                                  c_none
                                                  g_subrc.
        IF g_subrc NE c_zero.
          ADD 1 TO g_lines.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF g_lines GT c_zero.
      CLEAR: l_lponr.
      LOOP AT p_it_tab.
        IF p_it_tab-ibdsq IS INITIAL.
          ADD 1 TO p_ztitbdk-lponr.
          MOVE p_ztitbdk-lponr TO p_it_tab-ibdsq.
        ENDIF.
        MODIFY p_it_tab.
      ENDLOOP.
    ELSE.
      CLEAR: l_lponr.
      LOOP AT p_it_tab.
        ADD 1 TO l_lponr.
        MOVE l_lponr TO p_it_tab-ibdsq.
        MODIFY p_it_tab.
      ENDLOOP.
      MOVE l_lponr TO p_ztitbdk-lponr.
    ENDIF.
  ENDIF.
  CLEAR: l_lponr.
  LOOP AT p_it_tab.
    IF p_it_tab-ibdsq GT l_lponr.
      MOVE p_it_tab-ibdsq TO l_lponr.
    ENDIF.
  ENDLOOP.
  MOVE l_lponr TO p_ztitbdk-lponr.

ENDFORM.                    " set_item_number_build
*&---------------------------------------------------------------------*
*&      Form  set_function_by_BUSINESS
*&---------------------------------------------------------------------*
FORM set_function_by_business .
  CASE sy-dynnr.
    WHEN c_scr2000.
      DELETE ftab
        WHERE fcode EQ 'ZTIEDI'.
    WHEN OTHERS.
  ENDCASE.
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
*  IF ZTITRQK-reqty EQ c_da OR
*     ZTITRQK-reqty EQ c_dp.
*    MOVE 'ZTIEDI'       TO ftab-fcode.   APPEND ftab. ">EDI 문서.
*  ENDIF.

ENDFORM.                    " set_function_by_BUSINESS
*&---------------------------------------------------------------------*
*&      Form  check_request_of_import
*&---------------------------------------------------------------------*
*  수입의뢰문서의 종류/상태를 검증.
*----------------------------------------------------------------------*
FORM check_request_of_import .
  DATA: l_ddtext LIKE g_ddtext.

  CASE ztitrqk-reqty.
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
  ENDCASE.

ENDFORM.                    " check_request_of_import
*&---------------------------------------------------------------------*
*&      Form  GET_available_bl_ITEM
*&---------------------------------------------------------------------*
*       입력할  B/L 잔량을 체크함.
*----------------------------------------------------------------------*
FORM get_available_bl_item  TABLES   p_it_bl    STRUCTURE it_bl
                                     p_it_blnum STRUCTURE it_blnum
                            USING    p_mtype
                                     p_delete.

  CLEAR: g_tabix, g_count, g_cnt.
  LOOP AT p_it_bl.

    g_tabix = sy-tabix.

*   bl 정보 수량.
    SELECT  SINGLE blmng
      INTO  p_it_bl-menge
      FROM  ztitblp
     WHERE  iblno  = p_it_bl-iblno
       AND  iblit  = p_it_bl-iblit.

    p_it_bl-blmng  = p_it_bl-menge.

*   i/v 누적수량.
    SELECT  SUM( remng ) INTO p_it_bl-ivmngs FROM ztitivp
     WHERE  iblno  = p_it_bl-iblno
       AND  iblit  = p_it_bl-iblit.

*   i/v 가능수량.
    p_it_bl-ivmngl =  p_it_bl-menge - p_it_bl-ivmngs.

    IF p_it_bl-ivmngl LE c_zero.
      IF p_delete EQ c_true.
        DELETE p_it_bl INDEX g_tabix.
        CONTINUE.
      ELSE.
        p_it_bl-blmng = 0.
      ENDIF.
    ELSE.
      ADD 1 TO g_cnt.
    ENDIF.

    ADD 1 TO g_count.
    p_it_bl-index = g_count.
    MODIFY p_it_bl INDEX g_tabix.

    MOVE p_it_bl-iblno TO p_it_blnum-iblno.
    COLLECT p_it_blnum.

  ENDLOOP.

  DESCRIBE TABLE p_it_bl LINES g_line.
  IF g_line EQ 0.
    MESSAGE ID 'ZMTI00' TYPE p_mtype NUMBER 902.
    EXIT.
  ENDIF.

  IF g_cnt EQ 0.
*    MESSAGE ID 'ZMTI00' TYPE c_warning NUMBER 103.
    MESSAGE ID 'ZMTI00' TYPE p_mtype NUMBER 103.
  ENDIF.

ENDFORM.                    " GET_available_bl_ITEM
*&---------------------------------------------------------------------*
*&      Form  display_import_doc_by_node
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_import_doc_by_node  USING    p_node_key.

  READ TABLE it_bl WITH KEY INDEX = p_node_key(10).
  IF sy-subrc EQ 0.

    SET PARAMETER ID 'ZTIIBLNO' FIELD it_bl-iblno.
    CALL TRANSACTION 'ZTIT203'  AND SKIP FIRST SCREEN .
*    PERFORM  display_purchase_order USING it_po-ebeln
*                                          it_po-ebelp.
  ELSE.
    MESSAGE s903.
  ENDIF.

ENDFORM.                    " display_import_doc_by_node
*&---------------------------------------------------------------------*
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p2000_data_selections .

  DATA: l_rqmng  LIKE ztitrqp-rqmng.

  CLEAR: g_count, it_tab_h, it_header, it_list.
  REFRESH : it_tab_h, it_header, it_list.
*> PROGRESS Display.
  g_linen    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_linen INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.

*> 통관된 자가장치장 데이타 select.
  SELECT *
        INTO CORRESPONDING FIELDS OF TABLE it_tab_h
        FROM ztivcc04 AS a
       WHERE a~bukrs  IN s_bukrs  "회사코드.
         AND a~iblno  IN s_iblno  "관리번호.
         AND a~blnum  IN s_blnum  "25B/L 번호.
         AND a~bldty  IN s_bldty                            "1문서종류.
         AND a~rptty  IN s_rptty  "1수입신고구분.
         AND a~ekorg  IN s_ekorg                            "4구매조직.
         AND a~ekgrp IN s_ekgrp                             "3구매그룹.
         AND a~lifnr  IN s_lifnr  "10공급업체 계정번호.
         AND a~bletd  IN s_bletd  "8ETD(출발 예정 시각).
         AND a~bleta  IN s_bleta  "8ETA(도착 예정 시각).
         AND a~fwdty  IN s_fwdty  "1운송 방법.
         AND a~iblit  IN s_iblit  "5B/L 품목번호.
         AND a~ebeln  IN s_ebeln  "10구매전표번호.
         AND a~ebelp  IN s_ebelp  "5구매문서 품목번호.
         AND a~reqno  IN s_reqno  "10수입의뢰 관리번호.
         AND a~reqit  IN s_reqit  "5수입의뢰 품목번호.
         AND a~cnam   IN s_cnam                             "12작성인.
         AND a~cdat   IN s_cdat                             "8생성일.
         AND a~ctme   IN s_ctme                             "6생성시간.
         AND a~lstas  EQ a~iccsq
         AND a~rptty  EQ c_charn.  "자가장치장만.
*         AND a~rptty  in (c_charb, c_charn).

  IF sy-subrc NE 0.
    MESSAGE s902.
  ENDIF.

  CLEAR: g_tabix, g_count, g_cnt.
  LOOP AT it_tab_h.

    g_tabix = sy-tabix.

*   CC 누적수량.
    SELECT  SUM( bdqty )
      INTO  it_tab_h-bdqtys
      FROM  ztitbdp
     WHERE  iccno  = it_tab_h-iccno
       AND  iccit  = it_tab_h-iccit.

*   CC 가능수량.
    it_tab_h-bdqtyl =  it_tab_h-ccmng - it_tab_h-bdqtys.

    IF it_tab_h-bdqtyl LE 0.
      it_tab_h-bdqtyl = 0.
      DELETE it_tab_h INDEX g_tabix.
      CONTINUE.
    ENDIF.

*   domain의 value.
    PERFORM get_domain_value_text(ztir0000) USING :
                           'ZTIBLDTY' it_tab_h-bldty  it_tab_h-bldtyx,
                           'ZTIRPTTY' it_tab_h-rptty  it_tab_h-rpttyx,
                           'ZTIFWDTY' it_tab_h-fwdty  it_tab_h-fwdtyx,
                           'ZTINDFTY' it_tab_h-ndfty  it_tab_h-ndftyx.
*   공급업체.
    SELECT SINGLE name1 INTO it_tab_h-name1
      FROM lfa1
     WHERE lifnr EQ it_tab_h-lifnr.

*   p/o정보.
    SELECT  SINGLE menge werks matnr txz01
      INTO  (it_tab_h-pomng, it_tab_h-werks, it_tab_h-matnr,
      it_tab_h-txz01)
      FROM  ztivpo00
     WHERE  ebeln  = it_tab_h-ebeln
       AND  ebelp  = it_tab_h-ebelp.

*   수입의뢰 정보 수량.
    SELECT  SINGLE rqmng
      INTO  it_tab_h-menge
      FROM  ztivrq00
     WHERE  reqno  = it_tab_h-reqno
       AND  reqit  = it_tab_h-reqit.

*   b/l 누적수량.
    SELECT  SUM( blmng )
      INTO  it_tab_h-blmngs
      FROM  ztitblp
     WHERE  reqno  = it_tab_h-reqno
       AND  reqit  = it_tab_h-reqit.

*   b/l 가능수량.
    it_tab_h-blmngl =  it_tab_h-menge - it_tab_h-blmngs.
    MOVE it_tab_h-refwr TO it_tab_h-trefwr.
    ADD 1 TO g_count.

    MODIFY it_tab_h INDEX g_tabix.

  ENDLOOP.

ENDFORM.                    " p2000_data_selections
*&---------------------------------------------------------------------*
*&      Form  p2100_header_and_list_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p2100_header_and_list_build .

  LOOP AT it_tab_h.
    MOVE-CORRESPONDING it_tab_h TO : it_header, it_list.
    COLLECT : it_header.
    APPEND    it_list.
  ENDLOOP.

ENDFORM.                    " p2100_header_and_list_build

*&---------------------------------------------------------------------*
*&      Form  3000_field_category_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 3000_field_category_build .

*----------------------------------------------------------------------*
* 필드명과 Output Length등을 사용자의 입맛에 맞게 바꿈.
*----------------------------------------------------------------------*
  PERFORM 3010_fill_field_category USING :
*>>>>>>HEADER
"BOX.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'FIELDNAME'     'BOX',
          'E' 'KEY'           ' ',
"B/L 관리번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'IBLNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"B/L번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
*          ' ' 'seltext_m'     'BLNUM',
          ' ' 'FIELDNAME'     'BLNUM',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '31',
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
          'E' 'OUTPUTLEN'     '10',
"수입신고구분
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     '신고구분',
          ' ' 'FIELDNAME'     'RPTTYX',
          'E' 'OUTPUTLEN'     '14',
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
          'E' 'OUTPUTLEN'     '16',

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
          'E' 'OUTPUTLEN'     '23',
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
*          ' ' 'REF_TABNAME'   'ZTISCCIT',
          ' ' 'seltext_m'     '통관가능수량',
          ' ' 'FIELDNAME'     'CCMNGL',
          ' ' 'QTABNAME'       'IT_LIST',
          ' ' 'QFIELDNAME'     'MEINS',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'NO_OUT'        ' ',
          'E' 'OUTPUTLEN'     '20',
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
          'E' 'OUTPUTLEN'     '4',

"송장금액.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'seltext_m'     '송장값',
          ' ' 'FIELDNAME'     'REFWR',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'CTABNAME'      'IT_HEADER',
          ' ' 'NO_OUT'        ' ',
          'E' 'OUTPUTLEN'     '20',
"자재내역.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'FIELDNAME'     'TXZ01',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '40',
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
*&      Form  3010_fill_field_category
*&---------------------------------------------------------------------*
FORM 3010_fill_field_category  USING  p_section p_fname p_value.

  DATA l_col(40).
  FIELD-SYMBOLS <l_fs>.

  IF p_section = 'S'.
    CLEAR gs_fieldcat.
  ENDIF.

* 속성 MOVE
  CONCATENATE 'GS_FIELDCAT-' p_fname  INTO l_col.
  ASSIGN      (l_col)         TO       <l_fs>.
  MOVE         p_value        TO       <l_fs>.

  IF p_section = 'E'.
    APPEND gs_fieldcat TO it_fieldcat.
  ENDIF.
ENDFORM.                    " 3010_fill_field_category

*&---------------------------------------------------------------------*
*&      Form  3200_KEY_INFOMATION_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM 3200_key_infomation_build .

  CLEAR gs_keyinfo.

  gs_keyinfo-header01 = 'ICCNO'.
  gs_keyinfo-item01   = 'ICCNO'.

*  gs_keyinfo-header02 =  space.
*  gs_keyinfo-item02   = 'IBLIT'.

*  GS_KEYINFO-HEADER03 = SPACE.
*  GS_KEYINFO-ITEM03   = 'OBJNR'.

ENDFORM.                    " 3200_KEY_INFOMATION_BUILD
*&---------------------------------------------------------------------*
*&      Form  3100_SET_COLOR_INFOMATION
*&---------------------------------------------------------------------*
FORM 3100_set_color_infomation .

  LOOP AT it_list.

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
FORM 3400_comment_build .

  DATA: l_text20(20) TYPE c.

  CLEAR: it_listheader, gs_listheader.
  REFRESH: it_listheader.

* LIST HEADING LINE: TYPE H
  CLEAR gs_listheader.
  gs_listheader-typ  = 'H'.
* gs_listheader-KEY:  NOT USED FOR THIS TYPE
  gs_listheader-info = '수입신고 Due List'(t13).
*  SHIFT gs_listheader-info RIGHT BY 20 PLACES.
  APPEND gs_listheader TO it_listheader.

** JS전선 회사코드 2007/04 KSH --------------------------------------
  DATA: l_butxt LIKE t001-butxt.
  CLEAR: l_butxt.
  SELECT SINGLE butxt FROM t001
                      INTO l_butxt
                     WHERE bukrs EQ s_bukrs-low.

  CLEAR gs_listheader.
  gs_listheader-typ  = 'A'.
  gs_listheader-info = '회사코드 :'.
  CONCATENATE gs_listheader-info s_bukrs-low l_butxt
         INTO gs_listheader-info SEPARATED BY space.
  APPEND gs_listheader TO it_listheader.
** JS전선 회사코드 2007/04 KSH --------------------------------------

* ACTION LINE: TYPE A
  CLEAR gs_listheader.
  gs_listheader-typ  = 'A'.
  gs_listheader-info = '출력일자 :'(t12).
  WRITE: sy-datlo TO l_text20.
  CONCATENATE gs_listheader-info l_text20 INTO gs_listheader-info
              SEPARATED BY space.
  APPEND gs_listheader TO it_listheader.

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
FORM 3500_sort_table_build .

  DATA: ls_sort TYPE slis_sortinfo_alv.

  CLEAR ls_sort.
  ls_sort-spos      = 1.
  ls_sort-fieldname = 'IBLNO'.
  ls_sort-tabname   = 'IT_LIST'.
  ls_sort-up        = 'X'.
* LS_SORT-GROUP     = '*'.             " Seiten- bei Gruppenwechsel
*  ls_sort-group     = 'UL'.            " Underline      -"-
  APPEND ls_sort TO it_sort.

ENDFORM.                    " 3500_SORT_TABLE_BUILD
*&---------------------------------------------------------------------*
*&      Form  3700_LAYOUT_build
*&---------------------------------------------------------------------*
FORM 3700_layout_build .

  MOVE: 'BOX'        TO gs_layout-box_fieldname,
        'IT_HEADER'  TO gs_layout-box_tabname.

*  MOVE: '3'          TO gs_layout-no_vline. " 분리자 라인.

ENDFORM.                    " 3700_LAYOUT_build

*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
FORM top_of_page.                                           "#EC CALLED

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = it_listheader[].



ENDFORM.                    "TOP_OF_PAGE

*---------------------------------------------------------------------*
*       Form  USER_COMMAND                                            *
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  DATA: ls_header TYPE ty_header,
        ls_list   TYPE ty_list,
        l_amdsq   TYPE ztiamdsq.

  CLEAR: ls_header, ls_list.

  CASE r_ucomm.
    WHEN '&REFRESH'.
      PERFORM p9000_duelist_refresh USING  rs_selfield.

    WHEN 'ZTIT001'. " 후속기능
      CLEAR : g_line, ls_header.
      LOOP AT it_header WHERE box EQ 'X'.
        ADD 1 TO g_line.
        MOVE-CORRESPONDING it_header TO ls_header.
      ENDLOOP.
      CASE g_line.
        WHEN 0.
          MESSAGE s003(ok). EXIT.
        WHEN 1.
          SET PARAMETER ID 'ZTIICCNO' FIELD it_header-iccno.
          SET PARAMETER ID 'ZTIBLNUM' FIELD space.
          SET PARAMETER ID 'ZTIIBINO' FIELD space.
          CALL TRANSACTION 'ZTIT481' AND SKIP FIRST SCREEN .
          PERFORM p9000_duelist_refresh USING  rs_selfield.
        WHEN OTHERS.
          MESSAGE s035(0k).   EXIT.
      ENDCASE.

    WHEN '&IC1'.
      IF rs_selfield-tabname EQ 'IT_HEADER'.
        READ TABLE it_header INDEX rs_selfield-tabindex.
      ELSEIF rs_selfield-tabname EQ 'IT_LIST'.
        READ TABLE it_list INDEX rs_selfield-tabindex.
      ENDIF.
      IF sy-subrc NE 0.
        MESSAGE s903. EXIT.
      ENDIF.

      IF rs_selfield-tabname EQ 'IT_HEADER'.
        MOVE-CORRESPONDING it_header TO ls_list.
      ELSEIF rs_selfield-tabname EQ 'IT_LIST'.
        MOVE-CORRESPONDING it_list   TO ls_list.
      ENDIF.

      CASE rs_selfield-fieldname.
        WHEN 'EBELN'.
          PERFORM  display_purchase_order(ztir0000)
                                          USING ls_list-ebeln
                                                ls_list-ebelp.
        WHEN 'REQNO' OR 'REQIT'.
          SELECT MAX( amdsq )
            INTO l_amdsq
            FROM ztitrqs
           WHERE reqno  EQ  ls_list-reqno.
          PERFORM  display_import_document(ztir0000)
                                          USING ls_list-reqno
                                                l_amdsq
                                                ls_list-reqit.

        WHEN 'IBLNO' OR 'IBLIT'.
          PERFORM  display_bl_document(ztir0000)
                                          USING ls_list-iblno
                                                ls_list-iblit.
      ENDCASE.
    WHEN OTHERS.
  ENDCASE.

  CLEAR: r_ucomm.

ENDFORM.                    "USER_COMMAND
*---------------------------------------------------------------------*
*       FORM PF_STATUS_SET                                            *
*---------------------------------------------------------------------*
FORM pf_status_set USING rt_extab TYPE slis_t_extab.

  SET TITLEBAR 'T1000' WITH 'Due List'(t10).

  REFRESH: rt_extab.

  APPEND 'ARCHIVE'   TO rt_extab.
  APPEND '&VEXCEL'   TO rt_extab.
  APPEND '&AQW'      TO rt_extab.
  APPEND '&VCRYSTAL' TO rt_extab.
  APPEND '&VGRID'    TO rt_extab.
  APPEND '&EB9'      TO rt_extab.
  APPEND '&CRDESIG'  TO rt_extab.
  APPEND '&XXL'      TO rt_extab.
  APPEND '&ABC'      TO rt_extab.

  SET PF-STATUS 'STANDARD ' EXCLUDING rt_extab.
*SET PF-STATUS 'ABCD' OF PROGRAM PROG.

ENDFORM.                    "PF_STATUS_SET
*&---------------------------------------------------------------------*
*&      Form  3300_EVENT_EXIT_TABLE_BUILD
*&---------------------------------------------------------------------*
FORM 3300_event_exit_table_build .

  CLEAR: it_event_exit-after.
  it_event_exit-after = 'X'.
  it_event_exit-ucomm = '&OL0'.

  APPEND it_event_exit.
  it_event_exit-ucomm = '&OLX'. APPEND it_event_exit.
  it_event_exit-ucomm = '&OAD'. APPEND it_event_exit.

ENDFORM.                    " 3300_EVENT_EXIT_TABLE_BUILD

*&---------------------------------------------------------------------*
*&      Form  3910_CALL_ALV_HIERSEQ
*&---------------------------------------------------------------------*
FORM 3910_call_alv_hierseq .

  DATA: ls_variant LIKE disvariant.
  ls_variant-report  = sy-repid.
  ls_variant-variant = p_vari.
  g_repid            = sy-repid.                  " Callback Program.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
            i_interface_check              = ' '
            i_callback_program       = g_repid
*            i_callback_pf_status_set       = ' '
*            i_callback_user_command        = ' '
            is_layout                = gs_layout
            it_fieldcat              = it_fieldcat[]
*            it_excluding                   =
*            IT_SPECIAL_GROUPS              =
            it_sort                  = it_sort
*            IT_FILTER                      =
*            IS_SEL_HIDE                    =
*            I_SCREEN_START_COLUMN          = 0
*            I_SCREEN_START_LINE            = 0
*            I_SCREEN_END_COLUMN            = 0
*            I_SCREEN_END_LINE              = 0
            i_tabname_header         = 'IT_HEADER'
            i_tabname_item           = 'IT_LIST'
            i_structure_name_header  = 'IT_HEADER'
            i_structure_name_item    = 'IT_LIST'
            is_keyinfo               = gs_keyinfo
            i_default                = c_charx
            i_save                   = c_chara
            is_variant               = ls_variant
            it_events                = it_events[]
            it_event_exit            = it_event_exit[]
            is_print                 = gs_print
*            IS_REPREP_ID             =
*            I_BYPASSING_BUFFER       =
*            I_BUFFER_ACTIVE          =
* IMPORTING
*            E_EXIT_CAUSED_BY_CALLER  =
*            ES_EXIT_CAUSED_BY_USER   =
    TABLES
      t_outtab_header                = it_header[]
      t_outtab_item                  = it_list[]
 EXCEPTIONS
      program_error                  = 1
      OTHERS                         = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " 3910_CALL_ALV_HIERSEQ
*&---------------------------------------------------------------------*
*&      Form  3600_event_table_build
*&---------------------------------------------------------------------*
FORM 3600_event_table_build  USING  p_name.

  DATA: ls_event TYPE slis_alv_event.

  IF it_events[] IS INITIAL.
    CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
      EXPORTING
        i_list_type = 0
      IMPORTING
        et_events   = it_events.
  ENDIF.

  READ TABLE it_events WITH KEY name = p_name
                       INTO ls_event.
  IF sy-subrc = 0.
    MOVE ls_event-name TO ls_event-form.
    APPEND ls_event TO it_events.
  ENDIF.

ENDFORM.                    " 3600_event_table_build
*&---------------------------------------------------------------------*
*&      Form  get_longtext_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_longtext_data .

*> Partner Text
  PERFORM  p1000_get_textid_and_text USING ztitbdk+3(13)
                                           c_textobject_header
                                           c_scr0100
                                           c_true
                                           c_false.

ENDFORM.                    " get_longtext_data

*&---------------------------------------------------------------------*
*&      Form  build_query_factories_class
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_query_factories_class .

  CALL FUNCTION 'Z_TI_GET_CLEARANCE_TO_QUERY'
    IMPORTING
      ex_factory = g_datablade.

ENDFORM.                    " build_query_factories_class

*&---------------------------------------------------------------------*
*&      Form  p9000_duelist_refresh
*&---------------------------------------------------------------------*
FORM p9000_duelist_refresh
                 USING p_selfield TYPE slis_selfield.

*> 검색조건에 해당하는 데이타를 Select.
  PERFORM p2000_data_selections.
*> Header table과 List(Items) table를 만듬.
  PERFORM p2100_header_and_list_build.
  DESCRIBE TABLE it_tab_h LINES g_line.
  IF NOT g_line IS INITIAL.
    p_selfield-refresh = 'X'.
  ELSE.
*> Program 종료.
    PERFORM  p9000_program_exit.
  ENDIF.

ENDFORM.                    " p9000_duelist_refresh

*&---------------------------------------------------------------------*
*&      Form  OTHER_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM other_functions .

  CASE ok_code.
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
    WHEN 'ZTICHDOC'.    ">변경문서.
      g_objekt   = 'ZTIBOCHDOC'.
      g_objektid = ztitbok+3(10).
      PERFORM display_change_document USING g_objekt
                                            g_objektid.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " OTHER_FUNCTIONS

*&---------------------------------------------------------------------*
*&      Form  BEFORE_TRANSPORT_PAI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM before_transport_pai .

*> Item Amount.
*  PERFORM summary_invoice_amount  USING c_success.

ENDFORM.                    " BEFORE_TRANSPORT_PAI
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM p1001_initialization .

  SET TITLEBAR 'T1000' WITH 'Due List'(t10).

ENDFORM.                    " p1001_initialization
*&---------------------------------------------------------------------*
*&      Form  p1100_check_input_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p1100_check_input_values .

  DATA: l_bukrs   LIKE t001-bukrs,
        l_werks   LIKE t001w-werks,
        l_matnr   LIKE mara-matnr,
        l_mtart   LIKE t134-mtart,
        l_ebeln   LIKE ekko-ebeln,
        l_lifnr   LIKE lfa1-lifnr,
        l_ekorg   LIKE t024e-ekorg,
        l_ekgrp   LIKE t024-ekgrp.

* Company code
  SELECT bukrs INTO (l_bukrs)
               FROM t001 UP TO 1 ROWS WHERE bukrs IN s_bukrs.
  ENDSELECT.
  IF sy-subrc <> 0.
    PERFORM get_ftext(rddfie00) USING 'T001' 'BUKRS' sy-langu
                                CHANGING dfies g_subrc.
    SET CURSOR FIELD 'S_BUKRS-LOW'.
    MESSAGE e348(m7) WITH '회사코드'.
  ENDIF.

* Vendor
  READ TABLE s_lifnr INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT lifnr INTO (l_lifnr)
                 FROM lfb1 UP TO 1 ROWS WHERE lifnr IN s_lifnr
                                        AND   bukrs IN s_bukrs.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'LFA1' 'LIFNR' sy-langu
                                  CHANGING dfies g_subrc.
      SET CURSOR FIELD 'S_LIFNR-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.
  ENDIF.

* Purchase Organization
  READ TABLE s_ekorg INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT ekorg INTO (l_ekorg)
                 FROM t024e UP TO 1 ROWS WHERE ekorg IN s_ekorg.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'T024E' 'EKORG' sy-langu
                                  CHANGING dfies g_subrc.
      SET CURSOR FIELD 'S_EKORG-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.
  ENDIF.

* Purchase GROUP
  READ TABLE s_ekgrp INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT ekgrp INTO (l_ekgrp)
                 FROM t024 UP TO 1 ROWS WHERE ekgrp IN s_ekgrp.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'T024' 'EKGRP' sy-langu
                                  CHANGING dfies g_subrc.
      SET CURSOR FIELD 'S_EKGRP-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.
  ENDIF.


ENDFORM.                    " p1100_check_input_values
*&---------------------------------------------------------------------*
*&      Form  set_document_initial_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_document_initial_value .

  CLEAR: ztitbdk.

  MOVE-CORRESPONDING ztitcck TO ztitbdk.
  MOVE: ztitbik-ibsno        TO ztitbdk-ibsno,
        ztitbik-ibino        TO ztitbdk-ibino,
        ztitbok-ibono        TO ztitbdk-ibono.

  CLEAR : ztitbdk-cnam, ztitbdk-cdat, ztitbdk-ctme,
          ztitbdk-unam, ztitbdk-udat, ztitbdk-utme.

  SELECT MAX( bdseq )
    INTO ztitbdk-bdseq
    FROM ztitbdk
   WHERE iccno EQ ztitbdk-iccno.

  ADD 1 TO ztitbdk-bdseq.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_tab
    FROM ztitccp
   WHERE iccno EQ ztisscrcom-iccno
     AND iccsq EQ ztisscrcom-iccsq.

  LOOP AT it_tab INTO g_tc_2130_wa.
    g_tabix = sy-tabix.
    SELECT SINGLE matnr txz01
      INTO CORRESPONDING FIELDS OF g_tc_2130_wa
      FROM ztitblp
     WHERE iblno EQ g_tc_2130_wa-iblno
       AND iblit EQ g_tc_2130_wa-iblit.

    SELECT SUM( bdqty )
      INTO g_tc_2130_wa-bdqtys
      FROM ztitbdp
     WHERE iccno EQ g_tc_2130_wa-iccno
       AND iccit EQ g_tc_2130_wa-iccit.

    g_tc_2130_wa-bdqtyl = g_tc_2130_wa-ccmng - g_tc_2130_wa-bdqtys.
    IF g_tc_2130_wa-bdqtyl LE 0.
      g_tc_2130_wa-bdqtyl = 0.
      DELETE it_tab INDEX g_tabix.
      CONTINUE.
    ENDIF.
    g_tc_2130_wa-bdqty = g_tc_2130_wa-bdqtyl.

    MODIFY it_tab FROM g_tc_2130_wa INDEX g_tabix.
  ENDLOOP.

  DESCRIBE TABLE it_tab LINES g_line.
  IF g_line EQ 0.
    MESSAGE e483.
  ENDIF.

ENDFORM.                    " set_document_initial_value

*&---------------------------------------------------------------------*
*&      Form  applications_print
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM applications_print .

  CASE g_mode.
    WHEN c_charc OR c_charm.
*> 공용 대화상자(메시지 통일).
      CALL FUNCTION 'Z_TI_POPUP_TO_CONFIRM_MESSAGE'
        EXPORTING
          xmode  = c_charz
        IMPORTING
          answer = g_answer.
    WHEN OTHERS.
      PERFORM applications_print_out.
  ENDCASE.

  IF g_answer EQ c_y.
    PERFORM check_for_document_field USING g_mode.
    IF g_line EQ c_zero.
*>Switches on the local update task.
      SET UPDATE TASK LOCAL.
*>Data Save.
      PERFORM p8000_save_master_data USING g_mode.
      CHECK g_subrc EQ c_zero.
    ENDIF.
    PERFORM applications_print_out.
  ENDIF.

ENDFORM.                    " applications_print
*&---------------------------------------------------------------------*
*&      Form  applications_print_out
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM applications_print_out .

  DATA: l_docno   TYPE ztsdocno,
        l_amdno   TYPE ztsamdsq,
        l_docty   TYPE string.

*> GET OUTPUT OPTIONS
  IF it_ztsprtctl[] IS INITIAL.
    REFRESH : it_ztsprtctl.
    CLEAR: it_ztsprtctl.

    LOOP AT it_ztsprtctl.
      MOVE sy-langu      TO    it_ztsprtctl-spras.
      MODIFY it_ztsprtctl INDEX sy-tabix.
    ENDLOOP.

    DESCRIBE TABLE it_ztsprtctl LINES g_line.
    IF g_line EQ c_zero.
      CLEAR: it_ztsprtctl.
      MOVE: t001-land1    TO    it_ztsprtctl-land1,
            sy-langu      TO    it_ztsprtctl-spras.
      APPEND it_ztsprtctl.
    ENDIF.
  ENDIF.

*> SmartForm 출력용 공용 함수.
  l_docno = ztitbdk-iccno.
  l_amdno = ztitbdk-bdseq.
  l_docty = g_document.

  CALL FUNCTION 'Z_TS_OUTPUTS_DOCUMENT_BY_TYPE'
    EXPORTING
      im_imexi            = 'I'
      im_docty            = l_docty
      im_docno            = l_docno
      im_amdno            = l_amdno
      im_repid            = sy-repid
    IMPORTING
      ex_answer           = g_answer
    TABLES
      ct_prtctl           = it_ztsprtctl
      ct_prt_doc          = it_prt_doc
    EXCEPTIONS
      no_output_documents = 1
      OTHERS              = 2.

  IF sy-subrc EQ 0.
    IF g_answer NE 'N'.
      MESSAGE s900.
    ELSE.
      MESSAGE s905.
    ENDIF.
  ELSE.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " applications_print_out

*&---------------------------------------------------------------------*
*&      Form  call_smartforms_functioins
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM call_smartforms_functioins
       USING    p_func_mod_name
                p_ssf_name
                p_docty
                p_docno
                p_amdno
                p_rread
       CHANGING p_mail_appl_obj        STRUCTURE g_mail_appl_obj
                p_mail_recipient       STRUCTURE g_mail_recipient
                p_mail_sender          STRUCTURE g_mail_sender
                p_control_parameters   STRUCTURE g_control_parameters
                p_output_options       STRUCTURE g_output_options
                p_document_output_info STRUCTURE g_document_output_info
                p_job_output_info      STRUCTURE g_job_output_info
                p_job_output_options   STRUCTURE g_job_output_options.

  DATA: lt_ztitbik LIKE ztitbik OCCURS 0 WITH HEADER LINE.

  IF p_rread EQ c_true.
    ztisscrcom-iccno = p_docno.
    ztisscrcom-bdseq = p_amdno.

    CALL FUNCTION 'Z_TI_GET_BONDED_AREA_GI_DOC'
      EXPORTING
        im_iccno   = ztisscrcom-iccno
        im_bdseq   = ztisscrcom-bdseq
      IMPORTING
        ex_ztitbdk = ztitbdk
        ex_ztitblk = ztitblk
        ex_ztitbik = ztitbik
        ex_ztitbok = ztitbok
        ex_ztitcck = ztitcck
      TABLES
        et_ztitbdp = it_tab
      EXCEPTIONS
        not_found  = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
  CALL FUNCTION p_func_mod_name
      EXPORTING
*                ARCHIVE_INDEX      =
*                ARCHIVE_INDEX_TAB  =
*                ARCHIVE_PARAMETERS =
           mail_appl_obj      = p_mail_appl_obj
           mail_recipient     = p_mail_recipient
           mail_sender        = p_mail_sender
           user_settings      = space
           control_parameters = p_control_parameters
           output_options     = p_output_options
           ztitbdk            = ztitbdk
      IMPORTING
           document_output_info = p_document_output_info
           job_output_info      = p_job_output_info
           job_output_options   = p_job_output_options
      TABLES
           it_ztitbdp           = it_tab
      EXCEPTIONS
           formatting_error   = 1
           internal_error     = 2
           send_error         = 3
           user_canceled      = 4.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " call_smartforms_functioins
