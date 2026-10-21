************************************************************************
* Title         :  ZTIR6000F01                                         *
*                                                                      *
* Description   : L/G 관리  Subroutine Include                         *
*                                                                      *
* Creation Date : 2004/02/21                                           *
*                                                                      *
* Author        : Seung Jun, LEE                                       *
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
*&      Form  get_and_check_bl_data
*&---------------------------------------------------------------------*
*       Get 구매오더 데이타.
*----------------------------------------------------------------------*
FORM get_and_check_bl_data  USING    p_iblno
                                     p_iblit
                                     p_modify
                                     p_ztivbl00 STRUCTURE ztivbl00
                                     p_count.

  CLEAR: ztivbl00.

  SELECT SINGLE * INTO p_ztivbl00
    FROM ztivbl00
   WHERE iblno EQ p_iblno
     AND iblit EQ p_iblit.

  IF sy-subrc EQ 0.

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
*    PERFORM  set_po_lock_object  USING p_ebeln
*                                       p_ebelp
*                                       c_lock
*                                       c_success
*                                       p_modify.
  ELSE.
    MESSAGE s019(06) WITH p_iblno.
    p_modify = c_true.
    EXIT.
  ENDIF.

ENDFORM.                    " get_po_data

*&---------------------------------------------------------------------*
*&      Form  p3000_set_data_of_screen
*&---------------------------------------------------------------------*
FORM p3000_set_data_of_screen .

  REFRESH: it_tab.

  CLEAR: ztitlg1,
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

* Message preparations
  PERFORM  set_message_preparations.


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

  PERFORM  set_return_mandatory     USING  :
                                      'ZTITLG1-GAPNM'   c_error,   "
                                      'ZTITLG1-GBENM'   c_error,   "
                                      'ZTITLG1-GNONM'   c_error,   "
                                      'ZTITLG1-GTCNM'   c_error,
                                      'ZTITLG1-GIVAT'   c_error,
                                      'ZTITLG1-GIVATC'  c_error,
                                      'ZTITLG1-GLCNO'   c_error,
                                      'ZTITLG1-GBLNO'   c_error,
                                      'ZTITLG1-GVSLN'   c_error,
                                      'ZTITLG1-GARDT'   c_error,
                                      'ZTITLG1-GBLDT'   c_error,
                                      'ZTITLG1-GALDT'   c_error,
                                      'ZTITLG1-GIBCD'   c_error,
                                      'ZTITLG1-GIBNM'   c_error,
                                      'ZTITLG1-IGOT1'   c_error.

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
*&      Form  p8000_save_master_data
*&---------------------------------------------------------------------*
FORM p8000_save_master_data USING p_mode.

*> 공통테이블 적용.
  IF g_mode      EQ c_chary AND
     ok_code_old EQ 'ZTISAVE'.
    p_mode = 'Y'.
  ENDIF.

  PERFORM p8100_save_common_data  TABLES it_tab
                                  USING  ztitlg1
                                         g_subrc
                                         p_mode.
  IF g_subrc NE c_zero.
    MESSAGE a912.   EXIT.
  ENDIF.

*> Long Text 저장 루틴.
  PERFORM save_long_text USING ztitlg1+3(10)
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
      MESSAGE s201 WITH ztitlg1-ilgno.
    ELSE.
      SET PARAMETER ID 'ZTIILGNO'  FIELD ztitlg1-ilgno.
      SET PARAMETER ID 'ZTIIBLNO'  FIELD ztitlg1-iblno.
      SET PARAMETER ID 'ZTIBLNUM'  FIELD ztitblk-blnum.
      MESSAGE s202 WITH ztitlg1-ilgno.
    ENDIF.
  ENDIF.

ENDFORM.                    " p8000_save_master_data
*&---------------------------------------------------------------------*
*&      Form  p8100_save_common_data
*&---------------------------------------------------------------------*
FORM p8100_save_common_data  TABLES  pt_tab     STRUCTURE g_tc_2130_wa
                             USING   p_ztitlg1 STRUCTURE ztitlg1
                                     p_subrc    LIKE      sy-subrc
                                     p_mode.

  DATA: l_ilgno     TYPE ztireqno,
        l_docty(9)  TYPE c,
        l_reqty     TYPE ztireqty.

  CLEAR: p_subrc, l_ilgno.
  l_reqty = 'LG'.

  IF sy-tcode EQ c_create OR  sy-tcode EQ c_create_d.

    CALL FUNCTION 'Z_TI_GET_NUMBER_NEXT'
      EXPORTING
        zmpty          = l_reqty
*   BUKRS          =
     IMPORTING
        lcono          = l_ilgno
     EXCEPTIONS
       not_type       = 1
       OTHERS         = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    l_ilgno = p_ztitlg1-ilgno.
  ENDIF.

  IF  p_ztitlg1-cnam IS INITIAL.
    MOVE: sy-uname   TO   p_ztitlg1-cnam,
          sy-datlo   TO   p_ztitlg1-cdat,
          sy-timlo   TO   p_ztitlg1-ctme.
  ENDIF.

  MOVE: sy-mandt   TO   p_ztitlg1-mandt,
        l_ilgno    TO   p_ztitlg1-ilgno,
        sy-uname   TO   p_ztitlg1-unam,
        sy-datlo   TO   p_ztitlg1-udat,
        sy-timlo   TO   p_ztitlg1-utme.

  MOVE: 'APPLOG-'         TO  p_ztitlg1-recno,
        p_ztitlg1+3(10)   TO  p_ztitlg1-recno+7(10).

  CASE p_mode.
    WHEN 'Q'.     ">의뢰.
      MOVE: c_charc    TO  p_ztitlg1-docst,
            space      TO  p_ztitlg1-sndst,
            sy-uname   TO  p_ztitlg1-appun,
            sy-datlo   TO  p_ztitlg1-appdt,
            sy-timlo   TO  p_ztitlg1-apptm.
    WHEN '1'.     ">의뢰취소.
      MOVE: space      TO  p_ztitlg1-docst,
            space      TO  p_ztitlg1-sndst,
            sy-uname   TO  p_ztitlg1-appun,
            sy-datlo   TO  p_ztitlg1-appdt,
            sy-timlo   TO  p_ztitlg1-apptm.

    WHEN 'A'.     ">접수.
      MOVE: c_chara    TO  p_ztitlg1-docst,
            space      TO  p_ztitlg1-sndst,
            sy-uname   TO  p_ztitlg1-accun,
            sy-datlo   TO  p_ztitlg1-accdt,
            sy-timlo   TO  p_ztitlg1-acctm.
    WHEN 'E'.     ">접수취소.
      MOVE: c_charr    TO  p_ztitlg1-docst,
            space      TO  p_ztitlg1-sndst,
            sy-uname   TO  p_ztitlg1-accun,
            sy-datlo   TO  p_ztitlg1-accdt,
            sy-timlo   TO  p_ztitlg1-acctm.
    WHEN 'Y'.     ">신청서만 저장.
      IF p_ztitlg1-accun IS INITIAL.
        MOVE: c_charw    TO  p_ztitlg1-docst,
              space      TO  p_ztitlg1-sndst,
              sy-uname   TO  p_ztitlg1-accun,
              sy-datlo   TO  p_ztitlg1-accdt,
              sy-timlo   TO  p_ztitlg1-acctm.
      ENDIF.
      MOVE: c_charw    TO  p_ztitlg1-docst.
*      MOVE: c_chary    TO  p_ZTITRQS-docst,
*            space      TO  p_ZTITRQS-sndst,
*            sy-uname   TO  p_ZTITRQS-sndun,
*            sy-datlo   TO  p_ZTITRQS-snddt,
*            sy-timlo   TO  p_ZTITRQS-sndtm.
    WHEN 'I'.     ">신청.
      IF p_ztitlg1-accun IS INITIAL.
        MOVE: c_chary    TO  p_ztitlg1-docst,
              space      TO  p_ztitlg1-sndst,
              sy-uname   TO  p_ztitlg1-accun,
              sy-datlo   TO  p_ztitlg1-accdt,
              sy-timlo   TO  p_ztitlg1-acctm.
      ENDIF.
      MOVE: c_chary    TO  p_ztitlg1-docst,
            space      TO  p_ztitlg1-sndst,
            sy-uname   TO  p_ztitlg1-sndun,
            sy-datlo   TO  p_ztitlg1-snddt,
            sy-timlo   TO  p_ztitlg1-sndtm.
*> EDI record create
      IF g_edi_answer EQ c_y.
*> EDI record create
        l_docty = 'APPLOG2AZ'.
        ztstedis-sncnt =  p_ztitlg1-sncnt.
        PERFORM  build_edi_status_record USING ztstedis-sncnt
                                               l_docty
                                               p_ztitlg1-bukrs
                                               p_ztitlg1-ilgno
                                               '00'
                                               p_ztitlg1-recid
                                               p_ztitlg1-recnm
                                               p_ztitlg1-recno
                                               p_subrc.
        IF p_subrc NE 0.
          ROLLBACK WORK.      EXIT.
        ENDIF.
        p_ztitlg1-sncnt = ztstedis-sncnt.
        p_ztitlg1-reqmt = c_chare.
      ELSE.
        p_ztitlg1-reqmt = c_charm.
      ENDIF.

    WHEN 'F'.     ">신청취소.
      MOVE: c_charw    TO  p_ztitlg1-docst,
            space      TO  p_ztitlg1-sndst,
            sy-uname   TO  p_ztitlg1-accun,
            sy-datlo   TO  p_ztitlg1-accdt,
            sy-timlo   TO  p_ztitlg1-acctm.

*> EDI record delete
      IF NOT p_ztitlg1-sncnt IS INITIAL.
        PERFORM  delete_edi_status_record USING p_ztitlg1-sncnt
                                                p_subrc.
*         IF p_subrc NE 0.
*           ROLLBACK WORK.      exit.
*         ENDIF.
        CLEAR: p_subrc.
      ENDIF.

      CLEAR: p_ztitlg1-sncnt, p_ztitlg1-reqmt.

    WHEN 'O'.     ">개설.
      MOVE: c_charo    TO  p_ztitlg1-docst,
            sy-uname   TO  p_ztitlg1-rcvun,
            sy-datlo   TO  p_ztitlg1-rcvdt,
            sy-timlo   TO  p_ztitlg1-rcvtm.
      IF p_ztitlg1-sndst EQ c_chars.
        MOVE c_chars   TO  p_ztitlg1-sndst.
      ELSE.
        MOVE c_charm   TO  p_ztitlg1-sndst.
      ENDIF.
    WHEN 'N'.     ">개설취소.
      MOVE: c_charn    TO  p_ztitlg1-docst,
            space      TO  p_ztitlg1-sndst,
            sy-uname   TO  p_ztitlg1-rcvun,
            sy-datlo   TO  p_ztitlg1-rcvdt,
            sy-timlo   TO  p_ztitlg1-rcvtm.
    WHEN 'G'.
*      MOVE: c_true     TO  p_ZTITLG1-dcend.
  ENDCASE.

  IF ok_code_old EQ 'ZTIDELETE'.
*> Header table delete.
    DELETE FROM ztitlg1 WHERE ilgno EQ p_ztitlg1-ilgno.
    IF sy-subrc NE 0.
      ROLLBACK WORK.   MOVE sy-subrc  TO p_subrc.     EXIT.
    ENDIF.
    EXIT.
  ELSE.
*> Header table modify.
    MODIFY ztitlg1 FROM p_ztitlg1.
    IF sy-subrc NE 0.
      ROLLBACK WORK.   MOVE sy-subrc  TO p_subrc.     EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    " p8100_save_common_data
*&---------------------------------------------------------------------*
*&      Form  call_smartforms_functioins
*&---------------------------------------------------------------------*
FORM call_smartforms_functioins USING p_func_mod_name.

  CALL FUNCTION p_func_mod_name
       EXPORTING
*            ARCHIVE_INDEX      =
*            ARCHIVE_INDEX_TAB  =
*            ARCHIVE_PARAMETERS =
*            MAIL_APPL_OBJ      = MAIL_APPL_OBJ
*            MAIL_RECIPIENT     = MAIL_RECIPIENT
*            MAIL_SENDER        = MAIL_SENDER
            user_settings      = space
            control_parameters = g_control_parameters
            output_options     = g_output_options
            ztitlg1           = ztitlg1
*            SUMMARY            = ZMMKR_RTC_ERS_LIST
*            SDATE              = GW_SDATE
*            TITLE              = TEXT-T01
*            TITLE              = 'ERS LIST'
       IMPORTING
            document_output_info = g_document_output_info
            job_output_info      = g_job_output_info
            job_output_options   = g_job_output_options
*       TABLES
*            I_ITEM             = XITAB
*            SUBTOTAL           = SITAB
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
     WHERE bukrs EQ ztitblk-bukrs.
    IF sy-subrc EQ 0.
      SELECT SINGLE *
        FROM t005
       WHERE land1 EQ t001-land1.
    ELSE.
      MESSAGE e011 WITH ztitblk-bukrs.
    ENDIF.
    SELECT SINGLE *
      FROM ztstig0
     WHERE bukrs EQ t001-bukrs.
    IF sy-subrc NE 0.
      MESSAGE e012 WITH t001-bukrs.
    ENDIF.
  ENDIF.

* 구매조직 SELECT ( T024E )
  IF ztitblk-ekorg IS INITIAL.
    CLEAR t024e.
  ELSE.
    CALL FUNCTION 'T024E_SINGLE_READ'
      EXPORTING
        t024e_ekorg = ztitblk-ekorg
      IMPORTING
        wt024e      = t024e
      EXCEPTIONS
        not_found   = 1
        OTHERS      = 2.

    IF sy-subrc NE 0.
      IF sy-calld NE c_true.
        MESSAGE w001(mh) WITH ztitblk-ekorg.
      ENDIF.
    ENDIF.
  ENDIF.

* 구매그룹 SELECT ( T024 )
  IF ztitblk-ekgrp IS INITIAL.
    CLEAR t024.
  ELSE.
    CALL FUNCTION 'MM_ARRANG_PURCHASE_GRP_SELECT'
      EXPORTING
        purchase_group           = ztitblk-ekgrp
      IMPORTING
        e_t024                   = t024
      EXCEPTIONS
        purchase_group_not_found = 1
        OTHERS                   = 2.

    IF sy-subrc NE 0.
      IF sy-calld NE c_true.
        MESSAGE w030(mn) WITH ztitblk-ekgrp.
      ENDIF.
    ENDIF.
  ENDIF.
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

  l_objectid(10) = ztitlg1+3(10).

  l_tcode        = sy-tcode.
  l_utime        = sy-timlo.
  l_udate        = sy-datlo.
  l_username     = sy-uname.

*  IF g_mode EQ c_charc.  ">생성모드일 경우.
*    REFRESH : yZTITBLP, yZTITBLC.
*  ENDIF.

  CALL FUNCTION 'ZTILGCHDOC_WRITE_DOCUMENT'
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
        n_ztitlg1                    = ztitlg1
        o_ztitlg1                    = *ztitlg1
        upd_ztitlg1                  = l_upd
    TABLES
      icdtxt_ztilgchdoc             = lt_cdtxt.

ENDFORM.                    " p8120_change_document
*&---------------------------------------------------------------------*
*&      Form  call_print_process
*&---------------------------------------------------------------------*
FORM call_print_process .

*  BREAK-POINT.

*> GET OUTPUT OPTIONS
  IF it_prtctl[] IS INITIAL.
    REFRESH : it_prtctl.
    CLEAR: it_prtctl.
*    IF NOT ZTITRQK-opnbk IS INITIAL.   ">Openning bank.
*      SELECT lifnr name1 land1 spras telfx adrnr
*      INTO CORRESPONDING FIELDS OF TABLE it_prtctl
*      FROM lfa1
*      WHERE lifnr IN ( SELECT lifnr
*                       FROM ZTSTIG3
*                       WHERE epart EQ ZTITRQK-opnbk ).
*    ENDIF.
    DESCRIBE TABLE it_prtctl LINES g_line.
    IF g_line EQ c_zero.
      CLEAR: it_prtctl.
      MOVE: t001-land1    TO    it_prtctl-land1,
            sy-langu      TO    it_prtctl-spras,
            c_char1       TO    it_prtctl-prtty,
            c_char1       TO    it_prtctl-docty.
      APPEND it_prtctl.
    ENDIF.
  ENDIF.

*> Get Output Paramenters
  PERFORM get_output_information TABLES it_prtctl
                                 USING  g_answer.
  IF g_answer EQ c_y.

    LOOP AT it_prtctl WHERE flag EQ c_true.
*> Get SMARTFORM NAME
      PERFORM p7000_set_smart_form_name USING 'LG'
                                              '00'
                                              it_prtctl-docty
                                              g_ssf_name.
      IF g_ssf_name EQ c_loguar_r.
        IF ztitlg1-gblty EQ 'BM'.
          g_ssf_name = c_logua1_r.
        ELSE.
          g_ssf_name = c_loguar_r.
        ENDIF.
      ELSE.
        IF ztitlg1-gblty EQ 'BM'.
          g_ssf_name = c_applo1_r.
        ELSE.
          g_ssf_name = c_applog_r.
        ENDIF.
      ENDIF.

*> GET THE SMART FORM'S FUNCTION MODULE
      PERFORM get_smart_form_name    USING  g_ssf_name
                                            g_func_mod_name.

*> Set Output Paramenters
      PERFORM set_output_information USING it_prtctl.
*> Call SmartForms functions
      PERFORM call_smartforms_functioins USING g_func_mod_name.
*> Call SmartForms functions
      PERFORM exec_external_sending USING it_prtctl.
    ENDLOOP.
  ELSE.
    MESSAGE s900.
  ENDIF.

ENDFORM.                    " call_print_process
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

  IF ztitblk-lifnr IS INITIAL.
    CLEAR: lfa1.
  ELSE.
    SELECT SINGLE * FROM lfa1
     WHERE lifnr EQ ztitblk-lifnr.
    IF sy-subrc NE 0.
      PERFORM message_not_found_vendor USING 'ZTITBLK'
                                             'LIFNR'
                                              p_msgty.
    ENDIF.
  ENDIF.

  CLEAR: ztstig3.
  IF NOT ztitlg1-opnbk IS INITIAL.
    PERFORM  get_edi_partner USING  ztitlg1-opnbk
                                    'B'
                                    ztstig3
                                    c_error.
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
*&      Form  check_bl_sub_document_exist
*&---------------------------------------------------------------------*
*       하위문서 존재여부 체크.
*----------------------------------------------------------------------*
FORM check_bl_sub_document_exist  USING    p_iblno
                                           p_iblit
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
*    FROM ZTITLG1
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
*    FROM ZTItbshd
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
*    FROM ZTItbihd
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
*    FROM ZTItbohd
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

ENDFORM.                    " check_lc_sub_document_exist

*&---------------------------------------------------------------------*
*&      Form  SET_INITIAL_VALUE
*&---------------------------------------------------------------------*
FORM set_initial_value .

*> 문서 종류.
  g_document = c_lg.

  REFRESH: it_tab, it_po, it_ponum,
           g_tc_2122_itab.

  CLEAR:   it_tab, it_po, it_ponum,
           ztitblk,    ">B/L Header
           ztitlg1,    " L/G
          *ztitlg1,
           g_tc_2122_itab,
           lfa1,
          *lfa1,
           w_lfa1,
           w_lfa1_bank.

* Message preparations
  PERFORM  set_message_preparations.


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
                            USING    p_ztitblk STRUCTURE ztitblk.

*  DATA: l_lponr LIKE p_ZTITBLK-lponr.
*
*  IF g_mode EQ c_charc.
*    CLEAR: l_lponr.
*    LOOP AT p_it_tab.
*      ADD 1 TO l_lponr.
*      MOVE l_lponr TO p_it_tab-iblit.
*      MODIFY p_it_tab.
*    ENDLOOP.
*    MOVE l_lponr TO p_ZTITBLK-lponr.
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
*          ADD 1 TO p_ZTITBLK-lponr.
*          MOVE p_ZTITBLK-lponr TO p_it_tab-iblit.
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
*      MOVE l_lponr TO p_ZTITBLK-lponr.
*    ENDIF.
*  ENDIF.
*  CLEAR: l_lponr.
*  LOOP AT p_it_tab.
*    IF p_it_tab-iblit GT l_lponr.
*      MOVE p_it_tab-iblit TO l_lponr.
*    ENDIF.
*  ENDLOOP.
*  MOVE l_lponr TO p_ZTITBLK-lponr.

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
  CASE sy-tcode.
    WHEN c_create OR c_create_d OR c_create_a OR          ">생성.
         c_change.                                        ">변경.
      IF ztitrqs-docst EQ 'C'.
        MOVE 'ZTIREQUEST'     TO ftab-fcode.   APPEND ftab. ">의뢰.
      ELSE.
        MOVE 'ZTIREQCANC'     TO ftab-fcode.   APPEND ftab. ">취소.
      ENDIF.
    WHEN c_acceptance.                                      ">접수.
      IF ztitrqs-docst EQ 'A'.
        MOVE 'ZTIACCEPT'      TO ftab-fcode.   APPEND ftab. ">접수.
      ENDIF.
      IF ztitrqs-docst EQ 'R'.
        MOVE 'ZTIRETURN'      TO ftab-fcode.   APPEND ftab. ">접수.
      ENDIF.
    WHEN c_apply.                                          ">개설관리.
      IF ztitrqs-docst EQ 'O'.
        MOVE 'ZTIRECVC'      TO ftab-fcode.   APPEND ftab. ">접수.
      ELSE.
        MOVE 'ZTIRECVC'      TO ftab-fcode.   APPEND ftab. ">접수.
      ENDIF.
    WHEN c_open.
      IF ztitrqs-docst NE 'O'.
        MOVE 'ZTISENDC'      TO ftab-fcode.   APPEND ftab. ">개설취소.
      ENDIF.
      IF ztitrqk-dcend EQ 'X'.
        MOVE 'ZTICLOSE'      TO ftab-fcode.   APPEND ftab. ">종료.
      ELSE.
        MOVE 'ZTICLOSEC'     TO ftab-fcode.   APPEND ftab. ">종료취소.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
*  IF ZTITRQK-reqty EQ c_da OR
*     ZTITRQK-reqty EQ c_dp.
*    MOVE 'ZTIEDI'       TO ftab-fcode.   APPEND ftab. ">EDI 문서.
*  ENDIF.

ENDFORM.                    " set_function_by_BUSINESS
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
*&      Form  initial_value_setting
*&---------------------------------------------------------------------*
FORM initial_value_setting .

  DATA: l_ebeln LIKE ztitblp-ebeln,
        l_reqty TYPE ztireqty,
        l_reqno TYPE ztireqno,
        l_ilcty TYPE ztiilcty.

*            선적항
  MOVE :  ztitblk-fland  TO  ztitlg1-gshcd,
          ztitblk-pllod  TO  ztitlg1-gshnm,
*            도착항
          ztitblk-tland  TO  ztitlg1-gldcd,
          ztitblk-pltrn  TO  ztitlg1-gldnm,
*            선기명/항차
          ztitblk-ivsln  TO  ztitlg1-gvsln,
          ztitblk-gcarn  TO  ztitlg1-gcarn,
*            도착예정일
          ztitblk-bleta  TO  ztitlg1-gardt,
*            송장금액
          ztitblk-ivamt  TO  ztitlg1-givat,
          ztitblk-waers  TO  ztitlg1-givatc.
*           b/l number
  IF ztitblk-fwdty EQ 'A'.
    MOVE:  'AWB'   TO  ztitlg1-gblty,
           '2BB'   TO  ztitlg1-galcd.
  ELSE.
    MOVE: 'BM'    TO  ztitlg1-gblty,
          '2AZ'   TO  ztitlg1-galcd.
  ENDIF.

  MOVE  : 'AAC'           TO  ztitlg1-glcty,
          ztitblk-bldat  TO  ztitlg1-gbldt,
          ztitblk-blnum  TO  ztitlg1-gblno,
          ztitblk-bipkg  TO  ztitlg1-gpkgn,
          ztitblk-bpkty  TO  ztitlg1-gpkgnu,
          sy-datlo        TO  ztitlg1-galdt,
          '9'             TO  ztitlg1-rectr,
          'AB'            TO  ztitlg1-recas.

  SELECT ebeln
    FROM ztitblp UP TO 1 ROWS
    INTO  l_ebeln
   WHERE iblno EQ ztitlg1-iblno
     AND ebeln NE space.
  ENDSELECT.

  IF sy-subrc EQ 0.
    SELECT opnbk opnno opndt reqty reqno ilcty
      INTO (ztitlg1-opnbk, ztitlg1-glcno, ztitlg1-glcdt,
           l_reqty, l_reqno, l_ilcty)
      FROM ztivpo01 UP TO 1 ROWS
     WHERE ebeln EQ l_ebeln.
    ENDSELECT.
  ENDIF.

*******************************************************
* 20110706 김민지S긴급요청으로 처리 후 주석처리
* 20120723 전승훈S긴급요청으로 처리 후 주석처리
* 수입패키지 기본 로직에 이상있어 보
*******************************************************
  IF sy-subrc EQ 0.
    if l_ebeln = '4501558382'.
    SELECT opnbk opnno opndt reqty reqno ilcty
      INTO (ztitlg1-opnbk, ztitlg1-glcno, ztitlg1-glcdt,
           l_reqty, l_reqno, l_ilcty)
      FROM ztivpo01 UP TO 1 ROWS
     WHERE ebeln EQ l_ebeln
       and ebelp EQ '00020'.
*        and opnno = 'M42R01107EU00281'.
*       and REQNO = '1000002954'.
    ENDSELECT.
    else.
    SELECT opnbk opnno opndt reqty reqno ilcty
      INTO (ztitlg1-opnbk, ztitlg1-glcno, ztitlg1-glcdt,
           l_reqty, l_reqno, l_ilcty)
      FROM ztivpo01 UP TO 1 ROWS
     WHERE ebeln EQ l_ebeln.
    ENDSELECT.
    endif.
  ENDIF.
********************************************************

**> 결제기간.
  CASE l_reqty.
    WHEN c_lc.
      IF l_ilcty EQ 'A'.
        ztitlg1-gpydc = '2AA'.
      ELSEIF l_ilcty EQ 'U'.
        ztitlg1-gpydc = '2AB'.
      ENDIF.

      SELECT SINGLE pate1
        INTO ztitlg1-gpydt
        FROM ztitlc1
       WHERE reqno EQ l_reqno
         AND amdsq EQ ( SELECT lstas
                          FROM ztitrqk
                         WHERE reqno EQ l_reqno ).

    WHEN c_tt.
      ztitlg1-gpydc = '2AL'.
    WHEN c_da.
      ztitlg1-gpydc = '2AC'.
    WHEN c_dp.
      ztitlg1-gpydc = '2AD'.
  ENDCASE.

*> 회사코드.
  CALL FUNCTION 'Z_TS_GET_COMPANY_EDI_DATA'
    EXPORTING
      bukrs           = ztitlg1-bukrs
*        appct           = ZTITBLK-appct
   IMPORTING
*     yZTSTIG0        =
     nztstig0         = ztstig0
     xt001            = t001
   EXCEPTIONS
     not_found       = 1
     OTHERS          = 2 .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
    MESSAGE ID sy-msgid TYPE c_warning  NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CLEAR: ztstig3.
  IF NOT ztitlg1-opnbk IS INITIAL.
    PERFORM  get_edi_partner USING  ztitlg1-opnbk
                                    'B'
                                    ztstig3
                                    c_error.
  ENDIF.

*GAPNM	신청인 상호
*GAPAD1	신청인 주소
*GAPAD2	신청인 주소
*
*GNONM	명의인 상호
*GNOPR	명의인 대표자
*GNOID	명의인 전자서명
*
*GIBCD	발급은행 코드
*GIBNM	발급은행명
*GIBBR	발급은행 지점명

*> 화물표시.

*> 상품명세.
*ZTITLG1-IGOT1

ENDFORM.                    " initial_value_setting
*&---------------------------------------------------------------------*
*&      Form  applications_print
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM applications_print .

  CASE g_mode.
    WHEN c_chary OR c_charo.
*> 공용 대화상자(메시지 통일).
      CALL FUNCTION 'Z_TI_POPUP_TO_CONFIRM_MESSAGE'
        EXPORTING
          xmode  = c_charz
        IMPORTING
          answer = g_answer.
    WHEN OTHERS.
*      CASE ZTITRQS-docst.
*        WHEN c_charw OR c_chary OR c_charn OR c_charo.
      g_answer = c_y.
*        WHEN OTHERS.
**> 문서상태 Fixed value read.
*          PERFORM  ddic_domain_value_text_read USING 'ZTIDOCST'
*                                                     sy-langu
*                                                     ZTITRQS-docst
*                                                     g_ddtext
*                                                     c_success.
*
*          MESSAGE s114 WITH ZTITRQS-reqno ZTITRQS-amdsq g_ddtext.
*
*          g_answer = c_n.
*      ENDCASE.
  ENDCASE.

  IF g_answer EQ c_y.
    IF g_mode EQ c_chary OR
       g_mode EQ c_charo.
      PERFORM check_for_document_field USING g_mode.
      IF g_line EQ c_zero.
*>Switches on the local update task.
        SET UPDATE TASK LOCAL.
*>Data Save.
        PERFORM p8000_save_master_data USING g_mode.
        CHECK g_subrc EQ c_zero.
      ENDIF.
    ENDIF.
    PERFORM  call_print_process.
  ENDIF.

ENDFORM.                    " applications_print
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
*       text
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
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p2000_data_selections .

  DATA: l_rqmng  LIKE ztitrqp-rqmng.

  CLEAR: g_count, it_tab_h, it_ztitig02, it_header, it_list.
  REFRESH : it_tab_h, it_ztitig02, it_header, it_list.
*> PROGRESS Display.
  g_linen    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_linen INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.

*> B/L 데이타 select.
  SELECT *
        INTO CORRESPONDING FIELDS OF TABLE it_tab_h
        FROM ( ztitblk AS a JOIN ztitblp AS b
          ON a~iblno EQ b~iblno ) JOIN ekpo AS c
          ON  b~ebeln EQ c~ebeln
          AND b~ebelp EQ c~ebelp
       WHERE a~bukrs  IN s_bukrs  "회사코드.
         AND a~iblno  IN s_iblno
         AND a~blnum  IN s_blnum  "25B/L 번호.
         AND a~lgayn  EQ 'X'     "LG대상여부.
         AND a~bldty  IN s_bldty                            "1문서종류.
         AND a~rptty  IN s_rptty  "1수입신고구분.
         AND c~matkl  IN s_matkl
         AND a~ekorg  IN s_ekorg                            "4구매조직.
         AND a~ekgrp  IN s_ekgrp                            "3구매그룹.
         AND a~lifnr  IN s_lifnr  "10공급업체 계정번호.
         AND a~bletd  IN s_bletd  "8ETD(출발 예정 시각).
         AND a~bleta  IN s_bleta  "8ETA(도착 예정 시각).
         AND a~fwdty  IN s_fwdty  "1운송 방법.
         AND a~lponr  IN s_lponr  "5최종품목번호.
         AND a~waers  IN s_waers                            "5통화키.
         AND a~lgayn  IN s_lgayn  "LG대상여부.
         AND b~iblit  IN s_iblit  "5B/L 품목번호.
         AND b~ndfty  IN s_ndfty  "1무환품 종류.
         AND b~blmng  IN s_blmng  "13B/L 수량.
         AND b~refwr  IN s_refwr  "13송장값 (외화).
         AND b~meins  IN s_meins                            "3기본단위.
         AND b~ebeln  IN s_ebeln  "10구매전표번호.
         AND b~ebelp  IN s_ebelp  "5구매문서 품목번호.
         AND b~reqno  IN s_reqno  "10수입의뢰 관리번호.
         AND b~reqit  IN s_reqit  "5수입의뢰 품목번호.
*         AND b~mblnr  IN s_mblnr  "10자재문서번호.
*         AND b~mjahr  IN s_mjahr  "4자재문서연도.
*         AND b~zeile  IN s_zeile  "4자재문서품목.
         AND b~cnam   IN s_cnam                             "12작성인.
         AND b~cdat   IN s_cdat                             "8생성일.
         AND b~ctme   IN s_ctme                             "6생성시간.
         AND b~unam   IN s_unam   "12최종변경인.
         AND b~udat   IN s_udat                             "8변경일.
         AND b~utme   IN s_utme   "6최종변경시간.
         AND a~crlse  NE 'B'.     "입수경로가 미확인이 아닌것만.


  IF sy-subrc NE 0.
    MESSAGE s902.
  ENDIF.

  CLEAR: g_tabix, g_count, g_cnt.
  LOOP AT it_tab_h.

    g_tabix = sy-tabix.

    SELECT SINGLE *
      FROM ztitlg1
     WHERE iblno EQ it_tab_h-iblno.
    IF sy-subrc EQ 0.
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

**   b/l 누적수량.
*    SELECT  SUM( blmng ) INTO it_tab_h-blmngs FROM ZTITBLP
*     WHERE  reqno  = it_tab_h-reqno
*       AND  reqit  = it_tab_h-reqit.
*
**   b/l 가능수량.
*    it_tab_h-blmngl =  it_tab_h-menge - it_tab_h-blmngs.

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
          'E' 'OUTPUTLEN'     '25',
"문서상태
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     '문서종류',
          ' ' 'FIELDNAME'     'BLDTYX',
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

"ETD
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'BLETD',
          'E' 'OUTPUTLEN'     '10',
"ETA
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
*          ' ' 'seltext_m'     '',
          ' ' 'FIELDNAME'     'BLETA',
          'E' 'OUTPUTLEN'     '10',
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
           ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'FWDTYX',
          'E' 'OUTPUTLEN'     '8',
"수입신고구분
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     '신고구분',
           ' ' 'NO_OUT'        'X',
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
          ' ' 'JUST'          c_charl," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         c_charx,
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
          ' ' 'JUST'          c_charl," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         c_charx,
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '5',
"수입의뢰번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'REQNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '12',
"수입의뢰 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'JUST'          c_charl," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         c_charx,
          ' ' 'FIELDNAME'     'REQIT',
          'E' 'OUTPUTLEN'     '10',
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

"수입의뢰수량
          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'seltext_m'     '수입의뢰수량',
          ' ' 'FIELDNAME'     'MENGE',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '15',
"B/L가능수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
*          ' ' 'seltext_m'     '수입의뢰수량',
          ' ' 'FIELDNAME'     'BLMNGL',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        'X',
          'E' 'KEY'           ' ',
"B/L누적수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
*          ' ' 'seltext_m'     '수입의뢰수량',
          ' ' 'FIELDNAME'     'BLMNGS',
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
*          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'BLMNG',
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
          ' ' 'JUST'          c_charr," (R)ight (L)eft (C)ent.
*          ' ' 'LZERO'         c_charx,
          ' ' 'CTABNAME'      'IT_HEADER',
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
*&      Form  3100_set_color_infomation
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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

ENDFORM.                    " 3100_set_color_infomation
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
  gs_listheader-info = 'L/G Due List'(t13).
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
*  clear ls_variant.
*  ls_variant = p_vari.


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

  DATA: ls_header TYPE ty_list.  "ty_header,

  CLEAR: ls_header.

  CASE r_ucomm.
    WHEN '&REFRESH'.
      PERFORM p9000_duelist_refresh USING  rs_selfield.

    WHEN 'ZTIT001'. " 후속기능
*> 개설 의뢰 상태에 따라 ZTIT005(접수) ZTIT006(신청) ZTIT007(개설)
      CLEAR : g_line, ls_header.
      LOOP AT it_header WHERE box EQ 'X'.
        ADD 1 TO g_line.
        MOVE-CORRESPONDING it_header TO it_list.
      ENDLOOP.
      CASE g_line.
        WHEN 0.
          IF rs_selfield-tabname EQ 'IT_HEADER'.
            READ TABLE it_header INDEX rs_selfield-tabindex.
          ELSEIF rs_selfield-tabname EQ 'IT_LIST'.
            READ TABLE it_list INDEX rs_selfield-tabindex.
          ENDIF.
          IF sy-subrc NE 0.
            MESSAGE s003(ok). EXIT.
          ENDIF.
          IF rs_selfield-tabname EQ 'IT_HEADER'.
            MOVE-CORRESPONDING it_header TO it_list.
          ELSEIF rs_selfield-tabname EQ 'IT_LIST'.
            MOVE-CORRESPONDING it_list   TO it_list.
          ENDIF.
        WHEN 1.
          SET PARAMETER ID 'ZTIIBLNO' FIELD it_header-iblno.
          SET PARAMETER ID 'ZTIBLNUM' FIELD space.
          CALL TRANSACTION 'ZTIT601' AND SKIP FIRST SCREEN .
        WHEN OTHERS.
          MESSAGE s035(0k).   EXIT.
      ENDCASE.
      PERFORM p9000_duelist_refresh USING  rs_selfield.

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
        MOVE-CORRESPONDING it_header TO ls_header.
      ELSEIF rs_selfield-tabname EQ 'IT_LIST'.
        MOVE-CORRESPONDING it_list   TO ls_header.
      ENDIF.

      CASE rs_selfield-fieldname.
        WHEN 'EBELN'.
          PERFORM  display_purchase_order(ztir0000)
                                          USING ls_header-ebeln
                                                ls_header-ebelp.
        WHEN 'REQNO' OR 'REQIT'.
          PERFORM  display_import_document(ztir0000)
                                          USING ls_header-reqno
                                                space
                                                ls_header-reqit.

        WHEN 'IBLNO' OR 'IBLIT'.
          PERFORM  display_bl_document(ztir0000)
                                          USING ls_header-iblno
                                                ls_header-iblit.

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
*&      Form  3200_key_infomation_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 3200_key_infomation_build .

  CLEAR gs_keyinfo.

  gs_keyinfo-header01 = 'IBLNO'.
  gs_keyinfo-item01   = 'IBLNO'.

ENDFORM.                    " 3200_key_infomation_build
*&---------------------------------------------------------------------*
*&      Form  3300_event_exit_tab_hle_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 3300_event_exit_tab_hle_build .

  CLEAR: it_event_exit-after.
  it_event_exit-after = 'X'.
  it_event_exit-ucomm = '&OL0'.

  APPEND it_event_exit.
  it_event_exit-ucomm = '&OLX'. APPEND it_event_exit.
  it_event_exit-ucomm = '&OAD'. APPEND it_event_exit.

ENDFORM.                    " 3300_event_exit_tab_hle_build

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
*&      Form  get_longtext_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_longtext_data .

*> Partner Text
  PERFORM  p1000_get_textid_and_text USING ztitlg1+3(10)
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

  CALL FUNCTION 'Z_TI_GET_REQ_OF_IMPORT_QUERY'
    IMPORTING
      ex_factory = g_datablade.

ENDFORM.                    " build_query_factories_class

*&---------------------------------------------------------------------*
*&      Form  OTHER_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM other_functions .

  CASE ok_code.
    WHEN 'ZTIREQUEST'.  ">수입의뢰.
      PERFORM  call_others_transaction  USING   c_charq
                                                c_delete
                                                c_false
                                                c_false.
    WHEN 'ZTIREQCANC'.  ">수입의뢰취소.
      PERFORM  call_others_transaction  USING   c_char1
                                                c_delete
                                                c_false
                                                c_false.
    WHEN 'ZTIACCEPT'.   ">접수.
      PERFORM  call_others_transaction  USING   c_chara
                                                c_delete
                                                c_false
                                                c_false.
    WHEN 'ZTIRETURN'.   ">접수반려.
      PERFORM  call_others_transaction  USING   c_chare
                                                c_delete
                                                c_false
                                                c_false.
    WHEN 'ZTISEND'.     ">EDI 신청.
      PERFORM  call_others_transaction  USING   c_chari
                                                c_delete
                                                c_false
                                                c_false.

    WHEN 'ZTISENDC'.   ">신청취소.
      PERFORM  call_others_transaction  USING   c_charf
                                                c_delete
                                                c_false
                                                c_false.
    WHEN 'ZTIRECVC'.   ">개설취소.
      PERFORM  call_others_transaction  USING   c_charn
                                                c_delete
                                                c_false
                                                c_false.

    WHEN 'ZTICHDOC'.    ">변경문서.
      g_objekt   = 'ZTILGCHDOC'.
      g_objektid = ztitlg1+3(10).
      PERFORM display_change_document USING g_objekt
                                            g_objektid.
    WHEN 'ZTIMK03'.     ">공급업체.
      PERFORM display_vendor_master USING ztitrqk-lifnr
                                          ztitrqk-ekorg.

    WHEN 'ZTIEDI'.
      PERFORM check_opnbk.
      SET SCREEN c_scr2200.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " OTHER_FUNCTIONS

*&---------------------------------------------------------------------*
*&      Form  BEFORE_TRANSPORT_PAI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM before_transport_pai .


ENDFORM.                    " BEFORE_TRANSPORT_PAI
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
*&      Form  3300_event_exit_table_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 3300_event_exit_table_build .

  CLEAR: it_event_exit-after.
  it_event_exit-after = 'X'.
  it_event_exit-ucomm = '&OL0'.

  APPEND it_event_exit.
  it_event_exit-ucomm = '&OLX'. APPEND it_event_exit.
  it_event_exit-ucomm = '&OAD'. APPEND it_event_exit.

ENDFORM.                    " 3300_event_exit_table_build
*&---------------------------------------------------------------------*
*&      Form  p9000_duelist_refresh
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
*&      Form  3010_fill_field_category
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 3010_fill_field_category USING p_section p_fname p_value.

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
*&      Form  check_opnbk
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_opnbk .

  CHECK: g_mode EQ c_charc OR
         g_mode EQ c_charm.

  IF ztitlg1-opnbk IS INITIAL.
    MESSAGE  e999(zmti00) WITH '개설은행을 입력하십시오.'.
  ELSE.

    SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF *ztstig3
      FROM ztstig3
     WHERE epart = ztitlg1-opnbk.
    IF sy-subrc EQ '0'.
*      ZTITLG1-gibcd = *ZTSTIG3-epart.
      ztitlg1-gibcd = *ztstig3-ibkcd.
      ztitlg1-gibnm = *ztstig3-namet.
      ztitlg1-recid = *ztstig3-epart.
      MOVE *ztstig3-namet TO ztitlg1-recnm.
    ELSE.
      MESSAGE  e998(zmti00) WITH ztitlg1-opnbk
      '이 거래상대방 관리테이블에 없습니다.'.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'Z_TS_GET_COMPANY_EDI_DATA'
    EXPORTING
      bukrs           = ztitlg1-bukrs
      appct           = 'Y'
   IMPORTING
      yztstig0        = ztstig0
*      nZTSTIG0        = ZTSTIG0
     xt001            = t001
   EXCEPTIONS
     not_found       = 1
     OTHERS          = 2 .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
    MESSAGE ID sy-msgid TYPE c_warning  NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*> applicant
  MOVE: ztstig0-eomns  TO  ztitlg1-gapnm,
        ztstig0-eoad1  TO  ztitlg1-gapad1,
        ztstig0-eoad2  TO  ztitlg1-gapad2.
*> 명의인.
  MOVE: ztstig0-eomns  TO  ztitlg1-gnonm,
        ztstig0-eompr  TO  ztitlg1-gnopr,
        ztstig0-esign  TO  ztitlg1-gnoid.

*>jp, park 추가_050824
  SELECT SINGLE *
      FROM lfa1
     WHERE lifnr EQ ztitblk-lifnr.


*> 송하인.
  MOVE: lfa1-name1  TO  ztitlg1-gbenm,
        lfa1-ort01  TO  ztitlg1-gbead1,
        lfa1-stras  TO  ztitlg1-gbead2.

  READ TABLE it_tab INTO g_tc_2130_wa INDEX 1.
  IF sy-subrc EQ 0.
    MOVE: g_tc_2130_wa-txz01 TO ztitlg1-igot1.
  ENDIF.

  IF NOT g_tc_2130_wa-reqno IS INITIAL.
    SELECT SINGLE *
      FROM ztitrqk
     WHERE reqno EQ g_tc_2130_wa-reqno.
    IF sy-subrc EQ 0.
      IF ztitrqk-reqty EQ c_da OR
         ztitrqk-reqty EQ c_dp.
*> 수하인.
        MOVE: ztstig0-eomns  TO  ztitlg1-gconm,
              ztstig0-eompr  TO  ztitlg1-gcoad1,
              ztstig0-eoad1  TO  ztitlg1-gcoad2.
      ELSE.
        MOVE: *ztstig3-enmt1 TO ztitlg1-gconm.
        CLEAR: ztitlg1-gcoad1, ztitlg1-gcoad2.
      ENDIF.
    ENDIF.
  ENDIF.

  IF NOT ztitblk-fwdtx IS INITIAL.
    MOVE ztitblk-fwdtx TO ztitlg1-gtcnm.
*GTCAD
*GTCID
  ENDIF.

ENDFORM.                    " check_opnbk

*&---------------------------------------------------------------------*
*&      Form  edi_data_sending
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM edi_data_sending .

  DATA: l_imexi   TYPE c,
        l_docno   TYPE char10,
        l_amdsq   TYPE numc2,
        l_docty   TYPE ztstedis-edity,
        l_sncnt   TYPE ztstedis-sncnt.

  CASE ztstig0-fname.
    WHEN 'L'.    ">LG CNS VAN I/F
*>[TraSys] LG CNS VAN용 OutBound 공통모듈 .
      g_edi_func = 'Z_TD_EDI_OUTBOUND_FOR_LGCNS'.
    WHEN 'R'.   ">Ready Korea Package I/F
*>[TraSys] LG CNS VAN용 OutBound 공통모듈 .
      g_edi_func = 'Z_TD_EDI_OUTBOUND_FOR_RK'.
    WHEN OTHERS.
      EXIT.
  ENDCASE.

*> 수출입 구분.
  l_imexi = c_chari.

  l_sncnt  =  ztitlg1-sncnt.
  l_docno  =  ztitlg1-ilgno.
  l_amdsq  =  '00'.

  SELECT SINGLE *
    FROM ztstedis
   WHERE sncnt  EQ  ztitlg1-sncnt.
  IF sy-subrc EQ 0.
    l_docty = ztstedis-edity.
  ENDIF.

*> EDI Sending.

  CALL FUNCTION g_edi_func
    EXPORTING
      im_imexi    = l_imexi
      im_docty    = l_docty
      im_docno    = l_docno
      im_seqno    = l_amdsq
      im_ztstedis = ztstedis
      im_ztstig0  = ztstig0
    IMPORTING
      ex_subrc    = g_subrc
      ex_ztstedis = ztstedis.

  IF g_subrc EQ 0.
    MESSAGE s040.
  ELSE.
    MESSAGE s041.
  ENDIF.

ENDFORM.                    " edi_data_sending
*&---------------------------------------------------------------------*
*&      Form  get_authorization_bukrs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_authorization_bukrs .

  PERFORM init_authorization_check USING a_bukrs
                                CHANGING a_bukrs.

endform.                    " get_authorization_bukrs
