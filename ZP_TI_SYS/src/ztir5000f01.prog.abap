************************************************************************
* Title         :  ZTIR5000F01                                         *
*                                                                      *
* Description   : 수입 입고관리 Subroutine Include                     *
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
* 2009.10.19      MMB03    C20091014_40571                        *
*                         :공조 수입상품 중 일련번호 관리와            *
*                          공급자 배치를 별도로 입력할 수 있도록 적용  *
*----------------------------------------------------------------------*
* 2012.03.12      MMB03    C20120222_56033                        *
*                         :송장 미처리 건에 대한 입고 제어처리         *
*----------------------------------------------------------------------*
* 2013.06.26   MMB04(HDY)  C20130625_56259                        *
*                         :스탠다드 입고처리 된 내역 유지보수 테이블   *
*                          관리하여 due list 조회시 제외               *
*----------------------------------------------------------------------*
* 2015.04.01     신재호   [기능개선 74119]
*                         :광섬유 입고 시 배치번호 채번 룰 변경
************************************************************************

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_CC_ORDER
*&---------------------------------------------------------------------*
FORM display_cc_order  USING    p_node_key.

  READ TABLE it_ztisccit WITH KEY index = p_node_key(10).
  IF sy-subrc EQ 0.
    PERFORM  display_cc_document    USING it_ztisccit-iccno
                                          it_ztisccit-iccsq.
  ELSE.
    MESSAGE s903.
  ENDIF.

ENDFORM.                    " DISPLAY_cc_ORDER
*&---------------------------------------------------------------------*
*&      Form  set_request_of_import_data
*&---------------------------------------------------------------------*
*       수입의뢰 아이템을 생성함.
*----------------------------------------------------------------------*
FORM set_request_of_import_data TABLES p_it_tab    LIKE it_tab
                                USING  p_ztivpo00 STRUCTURE ztivpo00
                                       p_ztitrqk STRUCTURE ztitrqk
                                       p_ztitrqs STRUCTURE ztitrqs
                                       p_po_wa    STRUCTURE it_po.

  MOVE-CORRESPONDING p_ztivpo00 TO : p_it_tab, p_ztitrqk, p_ztitrqs.

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
FORM set_good_receipt_data      TABLES p_it_tab   LIKE it_tab
                                USING  p_ztivcc00 STRUCTURE ztivcc00
                                       p_ztitgrk STRUCTURE ztitgrk
                                       p_ztisccit STRUCTURE it_ztisccit.
  CLEAR: p_it_tab.

  MOVE-CORRESPONDING p_ztivcc00 TO : p_it_tab, p_ztitgrk.

  MOVE: p_ztivcc00-iccno  TO p_ztitgrk-iccno.
  MOVE: p_ztivcc00-iblno  TO p_ztitgrk-iblno.

  PERFORM  set_gr_initial_data  USING p_ztitgrk.

  MOVE: p_ztisccit-grmng  TO p_it_tab-grmng,
        p_ztisccit-grmngs TO p_it_tab-grmngs,
        p_ztisccit-grmngl TO p_it_tab-grmngl.

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
  APPEND p_it_tab.
*
**>아이템 번호를 생성함.
*  PERFORM set_item_number_build TABLES p_it_tab
*                                USING  p_ZTITBLK.
*
  PERFORM get_others_text_by_master_data.

ENDFORM.                    " set_good_receipt_data

*&---------------------------------------------------------------------*
*&      Form  get_and_check_po_data
*&---------------------------------------------------------------------*
*       Get 구매오더 데이타.
*----------------------------------------------------------------------*
FORM get_and_check_po_data  USING    p_iccno
                                     p_iccsq
                                     p_iccit
                                     p_modify
                                     p_ztivcc00 STRUCTURE ztivcc00
                                     p_count.

  CLEAR: p_ztivcc00.

  SELECT SINGLE * INTO p_ztivcc00
    FROM ztivcc00
   WHERE iccno EQ p_iccno
     AND iccsq EQ p_iccsq
     AND iccit EQ p_iccit.

  IF sy-subrc EQ 0.
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
    PERFORM  set_cc_lock_object  USING p_iccno
                                       p_iccsq
                                       p_iccit
                                       c_lock
                                       c_success
                                       p_modify.
  ELSE.
    MESSAGE s019(06) WITH p_iccno.
    p_modify = c_true.
    EXIT.
  ENDIF.

ENDFORM.                    " get_and_check_po_data
*&---------------------------------------------------------------------*
*&      Form  get_and_check_cc_data
*&---------------------------------------------------------------------*
*       Get 통관 데이타.
*----------------------------------------------------------------------*
FORM get_and_check_cc_data  USING    p_iccno
                                     p_iccsq
                                     p_iccit
                                     p_modify
                                     p_ztivcc00 STRUCTURE ztivcc00
                                     p_count.

  CLEAR: p_ztivcc00.

  SELECT SINGLE * INTO p_ztivcc00
    FROM ztivcc00
   WHERE iccno EQ p_iccno
     AND iccit EQ p_iccit.

  IF sy-subrc EQ 0.
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
    PERFORM  set_cc_lock_object  USING p_iccno
                                       p_iccsq
                                       p_iccit
                                       c_lock
                                       c_success
                                       p_modify.
  ELSE.
    MESSAGE s019(06) WITH p_iccno.
    p_modify = c_true.
    EXIT.
  ENDIF.

ENDFORM.                    " get_and_check_cc_data

*&---------------------------------------------------------------------*
*&      Form  p3000_set_data_of_screen
*&---------------------------------------------------------------------*
FORM p3000_set_data_of_screen .

  CHECK : sy-tcode EQ c_create    OR
          sy-tcode EQ c_create_d  OR
          sy-tcode EQ c_reverse1.

* Message preparations
  PERFORM  set_message_preparations.

  REFRESH: it_tab, it_iccno.

  CLEAR: ztitgrk,
        *ztitgrk,
         ztitgrp,
         ztitgrh,
         it_tab,
         it_iccno,
         lfa1,
        *lfa1,
         w_lfa1,
         w_lfa1_bank,
         t001,
         t024,
         t024e.

  CLEAR:  gt_control-textlines[], gt_control-texttypes[].

  MOVE : sy-datlo     TO     ztitgrk-budat,
         sy-datlo     TO     ztitgrk-bldat.
*
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

ENDFORM.                    " check_for_sub_document_exist


*&---------------------------------------------------------------------*
*&      Form  check_for_document_field
*&---------------------------------------------------------------------*
*  필드들의 오류 값들을 체크하여 공통 nternal table에 저장함.
*----------------------------------------------------------------------*
FORM check_for_document_field USING p_mode.

  DATA: l_if_null TYPE REF TO if_message_obj_mm.

* Message preparations
  PERFORM  set_message_preparations.

* 20051024 simcho 입고전 관세처리 여부 체크
  DATA : lv_icsno LIKE ztivcs00-icsno.

  SELECT SINGLE icsno INTO lv_icsno
    FROM ztivcs00
   WHERE refno =  ztitgrk-iccno
     AND expcd IN ('TR4','TRF', 'TRS' ,'TRT'). "관세비용 체크

  IF sy-subrc <> 0.
*    PERFORM set_return_message USING
*                          'ZTITGRK' '관세처리되지 않았습니다' c_info.
*    MESSAGE ID 'ZMTI00' TYPE c_warning NUMBER '999'
*                   WITH '관세처리가 되지 않았습니다.전기하시겠습니까?'.

  ENDIF.
* simcho end

*> 전표증빙일.
  IF ztitgrk-bldat IS INITIAL.
    PERFORM set_return_message USING 'ZTITGRK' 'BLDAT' c_error.
  ENDIF.
*> 전표의 전기일.
  IF ztitgrk-budat IS INITIAL.
    PERFORM set_return_message USING 'ZTITGRK' 'BUDAT' c_error.
  ENDIF.

  LOOP AT it_tab INTO g_tc_2130_wa.
    g_tabix = sy-tabix.
*> 입고수량..
    IF g_tc_2130_wa-grmng IS INITIAL.
      MESSAGE s513 WITH g_tabix 'G/R Qty.'.
      PERFORM set_return_message_fill USING c_error.
    ENDIF.
*> 저장위치.
    IF g_tc_2130_wa-knttp EQ c_charp.
      CLEAR: g_tc_2130_wa-lgort .
      MODIFY it_tab FROM g_tc_2130_wa.
    ELSE.
      IF g_tc_2130_wa-lgort IS INITIAL.
        MESSAGE s513 WITH g_tabix '저장위치'.
        PERFORM set_return_message_fill USING c_error.
      ENDIF.
    ENDIF.
    IF NOT g_tc_2130_wa-loekz IS INITIAL.
      MESSAGE s170 WITH g_tabix g_tc_2130_wa-ebeln
                                g_tc_2130_wa-ebelp.
      PERFORM set_return_message_fill USING c_error.
    ENDIF.
*> 생산일.
    IF g_tc_2130_wa-batchx NE c_true.
      IF NOT g_tc_2130_wa-mhdhb IS INITIAL AND
         g_tc_2130_wa-hsdat IS INITIAL.
        MESSAGE s513 WITH g_tabix '생산일'.
        PERFORM set_return_message_fill USING c_error.
      ENDIF.
    ENDIF.
  ENDLOOP.

*> 오류정보가 존재시 메시지 상자 POPUP.
  g_line = g_message_handler->get_severity_bo(
                          im_business_obj          = l_if_null
                          im_include_child_objects = c_true ).

  IF g_line GT 0.
    CALL METHOD g_message_handler->show(
        im_popup  = c_true
        im_amodal = c_false ).
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
                                  USING  ztitgrk
                                         g_subrc
                                         p_mode.
  IF g_subrc NE c_zero.
    MESSAGE a912.   EXIT.
  ENDIF.

*> Long Text 저장 루틴.
  PERFORM save_long_text USING ztitgrk+3(10)
                               c_textobject_header
                               g_subrc.

  IF sy-subrc NE 0.
    ROLLBACK WORK.
    MESSAGE a912.   EXIT.
  ELSE.
*> Change document setting.
    PERFORM p8120_change_document.
*> Set parameter ID
    IF ok_code_old EQ 'ZTIDELETE'.
*> Commit work.
      COMMIT WORK.
      MESSAGE s201 WITH ztitgrk-igrno.
    ELSE.
*> Commit work.
      COMMIT WORK.
      SET PARAMETER ID 'ZTIIGRNO'  FIELD ztitgrk-igrno.
      MESSAGE s202 WITH ztitgrk-igrno.
*> Exporting Memory
      EXPORT ztitgrk TO MEMORY ID 'ZTIR5000'.

************************************************************************
*> Batch data Modified
************************************************************************
      IF p_mode EQ c_charh OR
         p_mode EQ c_charr.
        PERFORM set_zmmt0024_table  USING p_mode.

*-{ 기능개선 127661 - 꼬리표 생성 기능 추가
        PERFORM set_zppt0001_table   TABLES it_tab
                                     USING  ztitgrk
                                            p_mode.
*-} 기능개선 127661

      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " p8000_save_master_data
*&---------------------------------------------------------------------*
*&      Form  p8100_save_common_data
*&---------------------------------------------------------------------*
FORM p8100_save_common_data  TABLES  pt_tab     STRUCTURE g_tc_2130_wa
                             USING   p_ztitgrk  STRUCTURE ztitgrk
                                     p_subrc    LIKE      sy-subrc
                                     p_mode.

  DATA: l_igrno   TYPE ztireqno,
        l_reqty   TYPE ztireqty,
        l_ztitgrh LIKE ztitgrh,
        l_grseq   TYPE ztigrseq.

  CLEAR: p_subrc, l_igrno.
  l_reqty = g_document.

*-> 자체개선 104998_플랜트 3204 체크
  DATA: l_connector(1).
  CLEAR l_connector.

  READ TABLE pt_tab INDEX 1.
  IF sy-subrc = 0.
    IF pt_tab-werks = '3204'.
      l_connector = 'Y'.
    ENDIF.
  ENDIF.
*<- 자체개선 104998_플랜트 3204 체크

  IF ( sy-tcode EQ c_create OR  sy-tcode EQ c_create_d  OR
       sy-tcode EQ c_no_draft_due_list ) AND
     p_ztitgrk-igrno IS INITIAL.

    CALL FUNCTION 'Z_TI_GET_NUMBER_NEXT'
      EXPORTING
        zmpty    = l_reqty
*       BUKRS    =
      IMPORTING
        lcono    = l_igrno
      EXCEPTIONS
        not_type = 1
        OTHERS   = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    l_igrno = p_ztitgrk-igrno.
  ENDIF.

  IF  p_ztitgrk-cnam IS INITIAL.
    MOVE: sy-uname   TO   p_ztitgrk-cnam,
          sy-datlo   TO   p_ztitgrk-cdat,
          sy-timlo   TO   p_ztitgrk-ctme.
  ENDIF.

  MOVE: sy-mandt   TO   p_ztitgrk-mandt,
        l_igrno    TO   p_ztitgrk-igrno,
        sy-uname   TO   p_ztitgrk-unam,
        sy-datlo   TO   p_ztitgrk-udat,
        sy-timlo   TO   p_ztitgrk-utme.

*> 전기시.
  IF p_mode EQ c_charh.
    MOVE: materialdocument              TO p_ztitgrk-mblnr,
          matdocumentyear               TO p_ztitgrk-mjahr.
    IF g_system_cnt EQ 0.
      MOVE c_charg                      TO p_ztitgrk-igrst.
    ELSE.
      MOVE c_charn                      TO p_ztitgrk-igrst.
    ENDIF.
  ELSEIF p_mode EQ c_charn.
    MOVE: materialdocument              TO p_ztitgrk-qblnr,
          matdocumentyear               TO p_ztitgrk-qjahr,
          c_charg                       TO p_ztitgrk-igrst.
*  ELSEIF p_mode EQ c_charc.
*    MOVE: goodsmvt_pstng_date           TO p_ztitgrk-cbudat,
*          c_charn                       TO p_ztitgrk-igrst.
*    CLEAR: p_ztitgrk-qblnr, p_ztitgrk-qjahr.
  ELSEIF p_mode EQ c_charr.
    MOVE: goodsmvt_headret-mat_doc      TO p_ztitgrk-cmblnr,
          goodsmvt_headret-doc_year     TO p_ztitgrk-cmjahr,
          goodsmvt_pstng_date           TO p_ztitgrk-cbudat,
          c_charr                       TO p_ztitgrk-igrst.
    CLEAR: p_ztitgrk-mblnr, p_ztitgrk-mjahr.
  ENDIF.

  IF ok_code_old EQ 'ZTIDELETE'.
*> Header table delete.
    DELETE FROM ztitgrk WHERE igrno EQ p_ztitgrk-igrno.
    IF sy-subrc NE 0.
      ROLLBACK WORK.   MOVE 4  TO p_subrc.     EXIT.
    ENDIF.
*> Item table delete
    DELETE FROM ztitgrp WHERE igrno EQ p_ztitgrk-igrno.
    IF sy-subrc NE 0.
      ROLLBACK WORK.   MOVE 4  TO p_subrc.     EXIT.
    ENDIF.
*> 이력 table delete
    DELETE FROM ztitgrh WHERE igrno EQ p_ztitgrk-igrno.
*> Batch table delete
    DELETE FROM ztitgrb WHERE igrno EQ p_ztitgrk-igrno.

*->자체개선 104998_입고관리번호-외포장 정보 테이블 삭제
    DATA: BEGIN OF lt_t3012 OCCURS 0.
            INCLUDE STRUCTURE zppt3012.
    DATA: END OF lt_t3012.

    IF l_connector = 'Y'.
      PERFORM upd_table_zppt3012 USING p_ztitgrk-igrno
                                       'D' "D = 삭제 또는 역분개
                                       ''  "자재문서 자리
                                       ''  "자재문서 년도 자리
                                       ''. "전기일
      DELETE FROM ztitgrpx WHERE igrno EQ p_ztitgrk-igrno.
    ENDIF.
*<-자체개선 104998
**    IF sy-subrc NE 0.
*      ROLLBACK WORK.   MOVE 4  TO p_subrc.     EXIT.
*    ENDIF.
    EXIT.
  ELSE.
*> Header table modify.
    MODIFY ztitgrk FROM p_ztitgrk.
    IF sy-subrc NE 0.
      ROLLBACK WORK.   MOVE 4  TO p_subrc.     EXIT.
    ENDIF.
*> Items table modify.
    DELETE FROM ztitgrp WHERE igrno EQ p_ztitgrk-igrno.
    REFRESH : xztitgrp.
    LOOP AT it_tab INTO g_tc_2130_wa.
      MOVE-CORRESPONDING g_tc_2130_wa TO xztitgrp.
      xztitgrp-mandt = p_ztitgrk-mandt.
      xztitgrp-igrno = p_ztitgrk-igrno.
      APPEND xztitgrp.
    ENDLOOP.

    MODIFY ztitgrp FROM TABLE xztitgrp.
    IF sy-subrc NE 0.
      ROLLBACK WORK.   MOVE 4  TO p_subrc.     EXIT.
    ENDIF.

*> Items Batch table modify.
    REFRESH g_tc_7000_save.
    DELETE FROM ztitgrb WHERE igrno EQ p_ztitgrk-igrno.
    LOOP AT g_tc_7000_itab INTO g_tc_7000_wa.
      g_tc_7000_wa-mandt = p_ztitgrk-mandt.
      g_tc_7000_wa-igrno = p_ztitgrk-igrno.
      APPEND g_tc_7000_wa TO g_tc_7000_save.
    ENDLOOP.
    MODIFY ztitgrb FROM TABLE g_tc_7000_save.

*-> 자체개선 104998_ZPPT3012 테이블 외포장 번호 Modify
    IF l_connector = 'Y'.
      DATA: lt_7000 LIKE LINE OF g_tc_7000_temp OCCURS 0
                                                WITH HEADER LINE.

      DATA : BEGIN OF xztitgrpx OCCURS 0.
               INCLUDE STRUCTURE ztitgrpx.
      DATA : END   OF xztitgrpx.

      CLEAR: lt_7000, lt_7000[],
             xztitgrpx, xztitgrpx[].

      IF g_tc_7000_itab[] IS INITIAL.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_7000
          FROM ztitgrpx
         WHERE igrno = p_ztitgrk-igrno .
      ELSE. "최초 생성
        lt_7000[] = g_tc_7000_itab[].
        SORT lt_7000 BY iccit exidv1.
        DELETE ADJACENT DUPLICATES FROM lt_7000 COMPARING iccit exidv1.
      ENDIF.

      LOOP AT lt_7000.
        xztitgrpx-igrno  = p_ztitgrk-igrno  .
        xztitgrpx-iccit  = lt_7000-iccit  .
        xztitgrpx-exidv1 = lt_7000-exidv1 .
        xztitgrpx-mblnr  = materialdocument  .
        xztitgrpx-mjahr  = matdocumentyear   .
        APPEND xztitgrpx. CLEAR xztitgrpx.
      ENDLOOP.

      MODIFY ztitgrpx FROM TABLE xztitgrpx.

      IF p_ztitgrk-igrst = 'G'.
        PERFORM upd_table_zppt3012 USING p_ztitgrk-igrno
                                         'C' "D = 삭제 또는 역분개
                                         materialdocument "자재문서
                                         matdocumentyear  "자재문서 년도
                                         p_ztitgrk-budat. "전기일
      ELSE.
        PERFORM upd_table_zppt3012 USING p_ztitgrk-igrno
                                         'D' "D = 삭제 또는 역분개
                                         ''  "자재문서 자리
                                         ''  "자재문서 년도 자리
                                         ''. "전기일
      ENDIF.
    ENDIF.
*<- 자체개선 104998
*-----------------------------------------------------------------------
*> 이력 table modify.
*> 전기시.
*-----------------------------------------------------------------------
    IF p_mode EQ c_charh.
      CLEAR: ztitgrh.

      MOVE-CORRESPONDING p_ztitgrk TO ztitgrh.

      CLEAR: ztitgrh-cmblnr, l_ztitgrh-cmjahr, l_ztitgrh-cbudat.

      SELECT MAX( grseq )
        INTO ztitgrh-grseq
        FROM ztitgrh
       WHERE igrno    EQ   p_ztitgrk-igrno.

      ADD 1 TO  ztitgrh-grseq.

      MOVE : sy-uname             TO     ztitgrh-cnam,
             sy-datlo             TO     ztitgrh-cdat,
             sy-timlo             TO     ztitgrh-ctme,
             sy-uname             TO     ztitgrh-unam,
             sy-datlo             TO     ztitgrh-udat,
             sy-timlo             TO     ztitgrh-utme.

      INSERT ztitgrh.

      IF sy-subrc NE 0.
        ROLLBACK WORK.   MOVE 4 TO p_subrc.     EXIT.
      ENDIF.
*>
    ELSEIF p_mode EQ c_charn.
      SELECT SINGLE *
        INTO l_ztitgrh
        FROM ztitgrh
       WHERE igrno    EQ   p_ztitgrk-igrno
         AND grseq    EQ ( SELECT MAX( grseq )
                             FROM ztitgrh
                            WHERE igrno EQ p_ztitgrk-igrno ).
      IF sy-subrc EQ 0.
        MOVE : p_ztitgrk-qblnr     TO     l_ztitgrh-qblnr,
               p_ztitgrk-qjahr     TO     l_ztitgrh-qjahr,
               c_charg              TO     l_ztitgrh-igrst,
               sy-uname             TO     l_ztitgrh-unam,
               sy-datlo             TO     l_ztitgrh-udat,
               sy-timlo             TO     l_ztitgrh-utme.
        MODIFY ztitgrh FROM l_ztitgrh.
        IF sy-subrc NE 0.
          ROLLBACK WORK.   MOVE 4 TO p_subrc.     EXIT.
        ENDIF.
      ENDIF.
*> 전기 취소시.
    ELSEIF p_mode EQ c_charc.
      SELECT SINGLE *
        INTO l_ztitgrh
        FROM ztitgrh
       WHERE igrno    EQ   p_ztitgrk-igrno
         AND grseq    EQ ( SELECT MAX( grseq )
                             FROM ztitgrh
                            WHERE igrno EQ p_ztitgrk-igrno ).
      IF sy-subrc EQ 0.
        MOVE: goodsmvt_headret-mat_doc      TO l_ztitgrh-cqblnr,
              goodsmvt_headret-doc_year     TO l_ztitgrh-cqjahr,
              goodsmvt_pstng_date           TO l_ztitgrh-cbudat,
              c_charn                       TO l_ztitgrh-igrst,
              sy-uname                      TO l_ztitgrh-unam,
              sy-datlo                      TO l_ztitgrh-udat,
              sy-timlo                      TO l_ztitgrh-utme.

        MODIFY ztitgrh FROM l_ztitgrh.

        IF sy-subrc NE 0.
          ROLLBACK WORK.   MOVE 4  TO p_subrc.     EXIT.
        ENDIF.
      ENDIF.

    ELSEIF p_mode EQ c_charr.
      SELECT SINGLE *
        INTO l_ztitgrh
        FROM ztitgrh
       WHERE igrno    EQ   p_ztitgrk-igrno
         AND grseq    EQ ( SELECT MAX( grseq )
                             FROM ztitgrh
                            WHERE igrno EQ p_ztitgrk-igrno ).
      IF sy-subrc EQ 0.
        MOVE: goodsmvt_headret-mat_doc      TO l_ztitgrh-cmblnr,
              goodsmvt_headret-doc_year     TO l_ztitgrh-cmjahr,
              goodsmvt_pstng_date           TO l_ztitgrh-cbudat,
              c_charr                       TO l_ztitgrh-igrst,
              sy-uname                      TO l_ztitgrh-unam,
              sy-datlo                      TO l_ztitgrh-udat,
              sy-timlo                      TO l_ztitgrh-utme.

        MODIFY ztitgrh FROM l_ztitgrh.

        IF sy-subrc NE 0.
          ROLLBACK WORK.   MOVE 4  TO p_subrc.     EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " p8100_save_common_data
*&---------------------------------------------------------------------*
*&      Form  call_smartforms_functioins
*&---------------------------------------------------------------------*
FORM call_smartforms_functioins USING p_func_mod_name.

  CALL FUNCTION p_func_mod_name
    EXPORTING
*     ARCHIVE_INDEX        =
*     ARCHIVE_INDEX_TAB    =
*     ARCHIVE_PARAMETERS   =
*     MAIL_APPL_OBJ        = MAIL_APPL_OBJ
*     MAIL_RECIPIENT       = MAIL_RECIPIENT
*     MAIL_SENDER          = MAIL_SENDER
      user_settings        = space
      control_parameters   = g_control_parameters
      output_options       = g_output_options
*     LFA1                 = LFA1
*     SUMMARY              = ZMMKR_RTC_ERS_LIST
*     SDATE                = GW_SDATE
*     TITLE                = TEXT-T01
*     TITLE                = 'ERS LIST'
    IMPORTING
      document_output_info = g_document_output_info
      job_output_info      = g_job_output_info
      job_output_options   = g_job_output_options
*       TABLES
*     I_ITEM               = XITAB
*     SUBTOTAL             = SITAB
    EXCEPTIONS
      formatting_error     = 1
      internal_error       = 2
      send_error           = 3
      user_canceled        = 4.

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

  IF ztitgrk-bukrs IS INITIAL.
    CLEAR: t001.
  ELSE.
    SELECT SINGLE * FROM t001
     WHERE bukrs EQ ztitgrk-bukrs.
  ENDIF.

*>
  SELECT SINGLE *
    FROM ztitblk
   WHERE iblno EQ ztitgrk-iblno.

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
    MESSAGE ID 'ZMMI' TYPE p_type NUMBER 001.
    EXIT.
  ENDIF.

ENDFORM.                    " get_used_payment_term
*&---------------------------------------------------------------------*
*&      Form  p8120_change_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p8120_change_document .

  DATA: l_objectid        TYPE cdhdr-objectid,
        l_tcode           TYPE cdhdr-tcode,
        l_utime           TYPE cdhdr-utime,
        l_udate           TYPE cdhdr-udate,
        l_username        TYPE cdhdr-username,
        l_cdoc_upd_object TYPE cdhdr-change_ind,
        l_upd_icdtxt      TYPE char1,
        l_upd             TYPE char1,
*        l_upd                   TYPE char1,
        lt_cdtxt          TYPE STANDARD TABLE OF cdtxt
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

  l_objectid(10) = ztitgrk+3(10).

  l_tcode        = sy-tcode.
  l_utime        = sy-timlo.
  l_udate        = sy-datlo.
  l_username     = sy-uname.

  IF g_mode EQ c_charc.  ">생성모드일 경우.
    REFRESH : yztitgrp.
  ENDIF.

  LOOP AT xztitgrp.
    xztitgrp-kz = l_upd.
    MODIFY xztitgrp.
  ENDLOOP.

  CALL FUNCTION 'ZTIGRCHDOC_WRITE_DOCUMENT'
    EXPORTING
      objectid                = l_objectid
      tcode                   = l_tcode
      utime                   = l_utime
      udate                   = l_udate
      username                = l_username
*     PLANNED_CHANGE_NUMBER   = ' '
      object_change_indicator = l_cdoc_upd_object
*     PLANNED_OR_REAL_CHANGES = ' '
*     NO_CHANGE_POINTERS      = ' '
*     UPD_ICDTXT_ZTIBLCHDOC   = ' '
      n_ztitgrk               = ztitgrk
      o_ztitgrk               = *ztitgrk
      upd_ztitgrk             = l_upd
      upd_ztitgrp             = l_upd
    TABLES
      icdtxt_ztigrchdoc       = lt_cdtxt
      xztitgrp                = xztitgrp
      yztitgrp                = yztitgrp.

ENDFORM.                    " p8120_change_document
*&---------------------------------------------------------------------*
*&      Form  call_print_process
*&---------------------------------------------------------------------*
FORM call_print_process .

*> GET OUTPUT OPTIONS
  IF it_prtctl[] IS INITIAL.
    REFRESH : it_prtctl.
    CLEAR: it_prtctl.
    IF NOT ztitrqk-opnbk IS INITIAL.   ">Openning bank.
      SELECT lifnr name1 land1 spras telfx adrnr
      INTO CORRESPONDING FIELDS OF TABLE it_prtctl
      FROM lfa1
      WHERE lifnr IN ( SELECT lifnr
                       FROM ztstig3
                       WHERE epart EQ ztitrqk-opnbk ).
    ENDIF.
    DESCRIBE TABLE it_prtctl LINES g_line.
    IF g_line EQ c_zero.
      CLEAR: it_prtctl.
      MOVE: t001-land1    TO    it_prtctl-land1,
            sy-langu      TO    it_prtctl-spras.
      APPEND it_prtctl.
    ENDIF.
  ENDIF.

*> Get Output Paramenters
  PERFORM get_output_information TABLES it_prtctl
                                 USING  g_answer.
  IF g_answer EQ c_y.

    LOOP AT it_prtctl WHERE flag EQ c_true.
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
    MESSAGE s900.
  ENDIF.

ENDFORM.                    " call_print_process
*&---------------------------------------------------------------------*
*&      Form  SET_OTHERS_FIELDS_BY_ITEMS
*&---------------------------------------------------------------------*
*       아이템의 기타 필드들을 fill
*----------------------------------------------------------------------*
FORM set_others_fields_by_items .
  DATA: l_eindt  LIKE eket-eindt.

*-{ 기능개선 - FIBER 원자재 통합배치(배치=자재코드) 채번용
  DATA: LV_MATKL_0830 LIKE MARA-MATKL,
        LV_CNT_0830   TYPE I,
        LV_MATNR_EXT  LIKE G_TC_2130_WA-MATNR.
*-}

  LOOP AT it_tab INTO g_tc_2130_wa.
*> 정가 계산.
    IF g_tc_2130_wa-grmng NE c_zero.
      CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
        EXPORTING
          peinh = g_tc_2130_wa-peinh
          bpumz = g_tc_2130_wa-bpumz
          bpumn = g_tc_2130_wa-bpumn
          menge = g_tc_2130_wa-grmng
          netpr = g_tc_2130_wa-netpr
        CHANGING
          netwr = g_tc_2130_wa-netwr.
    ENDIF.

*>Get 플랜트명 및 사업장코드.
    IF NOT g_tc_2130_wa-werks IS INITIAL.
      SELECT SINGLE name1 j_1bbranch
        INTO (g_tc_2130_wa-name1, g_tc_2130_wa-bupla)
        FROM t001w
       WHERE werks  EQ  g_tc_2130_wa-werks.

      SELECT SINGLE mhdrz mhdhb xchpf
        INTO (g_tc_2130_wa-mhdrz, g_tc_2130_wa-mhdhb,
              g_tc_2130_wa-xchpf)
        FROM mara
       WHERE matnr EQ g_tc_2130_wa-matnr.
*>
      SELECT SINGLE maxlz insmk
        INTO (g_tc_2130_wa-maxlz, g_tc_2130_wa-insmk)
        FROM marc
       WHERE matnr EQ g_tc_2130_wa-matnr
         AND werks EQ g_tc_2130_wa-werks.


*-{ 기능개선 - FIBER 원자재 통합배치 자동채번
* [조건] 입고 처리 플랜트(WERKS) + 입고 자재의 자재그룹(MATKL)이
*        공통마스터(ZGTPPT1010, MODULE_KIND='MM', CODEGRP='0830')에
*        등록되어 있으면 배치번호 = 자재코드(MATNR) 값으로 채번
      CLEAR: lv_matkl_0830, lv_cnt_0830, lv_matnr_ext.

      SELECT SINGLE matkl INTO lv_matkl_0830
        FROM mara
       WHERE matnr = g_tc_2130_wa-matnr.

      IF sy-subrc = 0.
        SELECT COUNT(*) INTO lv_cnt_0830
          FROM zgtppt1010
         WHERE module_kind = 'MM'
           AND codegrp     = '0830'
           AND fld_01      = g_tc_2130_wa-werks
           AND fld_02      = lv_matkl_0830.

        IF lv_cnt_0830 > 0.
*         배치번호 = 자재코드(외부표시형식, 선행 0 제거)
          CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
            EXPORTING
              input  = g_tc_2130_wa-matnr
            IMPORTING
              output = lv_matnr_ext.

          g_tc_2130_wa-batch = lv_matnr_ext.
        ENDIF.
      ENDIF.
*-} 기능개선 종료

    ELSE.
      CLEAR: g_tc_2130_wa-name1, g_tc_2130_wa-bupla.
    ENDIF.
*
*>Get 저장위치명.
    IF NOT g_tc_2130_wa-lgort IS INITIAL.
      SELECT SINGLE lgobe
        INTO (g_tc_2130_wa-lgobe)
        FROM t001l
       WHERE werks  EQ  g_tc_2130_wa-werks
         AND lgort  EQ  g_tc_2130_wa-lgort.
    ELSE.
      CLEAR g_tc_2130_wa-lgobe.
    ENDIF.
*>material master.
*>Get 납품일.
    IF NOT g_tc_2130_wa-ebeln IS INITIAL.
      CLEAR: l_eindt.
      SELECT MIN( eindt ) INTO l_eindt
        FROM eket
       WHERE ebeln EQ g_tc_2130_wa-ebeln
         AND ebelp EQ g_tc_2130_wa-ebelp.

      IF l_eindt IS INITIAL.
        CLEAR g_tc_2130_wa-eeind.
      ELSE.
        WRITE l_eindt TO g_tc_2130_wa-eeind.
      ENDIF.
    ENDIF.
    MODIFY it_tab FROM g_tc_2130_wa.
  ENDLOOP.

  DESCRIBE TABLE g_tc_7000_itab LINES g_line.
  IF g_line GT 0.
    LOOP AT g_tc_7000_itab INTO g_tc_7000_wa.
      g_tabix = sy-tabix.
      READ TABLE it_tab INTO g_tc_2130_wa
                        WITH KEY igrno = g_tc_7000_wa-igrno
                                 iccit = g_tc_7000_wa-iccit.
      IF sy-subrc EQ 0.
        MOVE: g_tc_2130_wa-name1 TO g_tc_7000_wa-name1,
              g_tc_2130_wa-mhdrz TO g_tc_7000_wa-mhdrz,
              g_tc_2130_wa-mhdhb TO g_tc_7000_wa-mhdhb,
              g_tc_2130_wa-xchpf TO g_tc_7000_wa-xchpf,
              g_tc_2130_wa-maxlz TO g_tc_7000_wa-maxlz,
              g_tc_2130_wa-insmk TO g_tc_7000_wa-insmk,
              g_tc_2130_wa-lgobe TO g_tc_7000_wa-lgobe.
        MODIFY g_tc_7000_itab FROM g_tc_7000_wa INDEX g_tabix.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " SET_OTHERS_FIELDS_BY_ITEMS
*&---------------------------------------------------------------------*
*&      Form  get_Import_vendors_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_import_vendors_text USING p_msgty.

  IF ztitgrk-lifnr IS INITIAL.
    CLEAR: lfa1.
  ELSE.
    SELECT SINGLE * FROM lfa1
     WHERE lifnr EQ ztitgrk-lifnr.
    IF sy-subrc NE 0.
      PERFORM message_not_found_vendor USING 'ZTITGRK'
                                             'LIFNR'
                                             p_msgty.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_Import_vendors_text
*&---------------------------------------------------------------------*
*&      Form  check_gr_sub_document_exist
*&---------------------------------------------------------------------*
*       하위문서 존재여부 체크.
*----------------------------------------------------------------------*
FORM check_gr_sub_document_exist  USING    p_igrno
                                           p_iccit
                                           p_msgty
                                           p_subrc.
  DATA: l_count TYPE i.

  CLEAR: p_subrc.

  CHECK NOT p_igrno IS INITIAL.

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
FORM check_cc_sub_document_exist  USING    p_iccno
                                           p_iccit
                                           p_msgty
                                           p_subrc.
  DATA: l_count TYPE i.

  CLEAR: p_subrc.

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
FORM set_initial_value .

*> 문서 종류.
  g_document = c_gr.

* Message preparations
  PERFORM  set_message_preparations.

  REFRESH: it_tab, it_po, it_ponum,
           xztitgrp, yztitgrp,
           it_ztisgrhs,
           g_tc_7000_itab.

  CLEAR:   it_tab, it_po,
           xztitgrp, yztitgrp,
           g_tc_7000_itab,
           it_ztisgrhs,
           ztitgrk,    ">B/L Header
          *ztitgrk,    ">B/L Header
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
        WHEN 'ZTISGRIT-EBELN' OR 'ZTISGRIT-EBELP'.
          PERFORM display_purchase_order USING g_tc_2130_wa-ebeln
                                               g_tc_2130_wa-ebelp.
        WHEN 'ZTISGRIT-ICCNO' OR 'ZTISGRIT-ICCIT'.
          PERFORM display_cc_document    USING g_tc_2130_wa-iccno
                                               '00'.

        WHEN 'ZTISGRIT-REQNO' OR 'ZTISGRIT-REQIT'.

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
        WHEN 'ZTISGRIT-MATNR'.
          PERFORM display_material_master USING g_tc_2130_wa-matnr
                                                g_tc_2130_wa-werks
                                                g_tc_2130_wa-lgort.
        WHEN 'ZTISGRIT-VBELN' OR 'ZTISGRIT-POSNR'.
          PERFORM display_inb_document    USING g_tc_2130_wa-vbeln.
      ENDCASE.
    ENDIF.
  ELSE.
    GET CURSOR FIELD g_fieldname.
    IF sy-subrc EQ 0.
      g_findscr = sy-dynnr.
      CHECK ok_code EQ 'ZTISELECT'.   ">문서선택.

      CASE g_fieldname.
        WHEN 'ZTISGRIT-EBELN' OR 'ZTISGRIT-EBELP'.
          PERFORM display_purchase_order USING ztisgrit-ebeln
                                               ztisgrit-ebelp.
        WHEN 'ZTISGRIT-MATNR' OR 'ZTISGRIT-TXZ01' OR
             'ZTISGRIT-WERKS' OR 'ZTISGRIT-NAME1'.
          PERFORM display_material_master USING  ztisgrit-matnr
                                                 ztisgrit-werks
                                                 ztisgrit-lgort.
        WHEN 'ZTITGRK-LIFNR'.
          PERFORM display_vendor_master USING ztitgrk-lifnr
                                              space.
        WHEN 'ZTITGRK-IBLNO'.
          PERFORM display_bl_document   USING ztitgrk-iblno
                                              '00000'.
        WHEN 'ZTITGRK-ICCNO'.
          PERFORM display_cc_document   USING ztitgrk-iccno
                                              '00'.
        WHEN 'ZTITGRK-MBLNR' OR 'ZTITGRK-MJAHR'.
          PERFORM display_material_doc  USING ztitgrk-mblnr
                                              ztitgrk-mjahr
                                              '0000'
                                              ztitgrk-bukrs.
        WHEN 'ZTITGRK-QBLNR' OR 'ZTITGRK-QJAHR'.
          PERFORM display_material_doc  USING ztitgrk-qblnr
                                              ztitgrk-qjahr
                                              '0000'
                                              ztitgrk-bukrs.
        WHEN 'ZTISSCRCOM-MBLNR' OR 'ZTISSCRCOM-MJAHR'.
          PERFORM display_material_doc  USING ztisscrcom-mblnr
                                              ztisscrcom-mjahr
                                              '0000'
                                              ztisscrcom-bukrs.
      ENDCASE.
    ENDIF.
  ENDIF.

ENDFORM.                    " double_click_event
*&---------------------------------------------------------------------*
*&      Form  set_function_by_BUSINESS
*&---------------------------------------------------------------------*
FORM set_function_by_business .

  CASE g_mode.
    WHEN c_charc OR c_charm.
    WHEN OTHERS.
      MOVE 'ZTILOCIN'     TO ftab-fcode.   APPEND ftab. ">저장위치.
  ENDCASE.

  IF sy-dynnr EQ c_scr0100 OR
     sy-dynnr EQ c_scr0200.
    MOVE 'ZTILOCIN'     TO ftab-fcode.   APPEND ftab. ">저장위치.
  ENDIF.

  IF g_document EQ c_gr.
    IF ztitgrk-igrst NE c_charg.
      MOVE 'ZTIACDOC'     TO ftab-fcode.   APPEND ftab. ">후속문서.
      MOVE 'ZTIMMDOC'     TO ftab-fcode.   APPEND ftab. ">송장문서.
    ENDIF.
    IF ztitgrk-igrst EQ c_charn OR
       ztitgrk-igrst EQ c_charg.
      MOVE 'ZTICHECK'     TO ftab-fcode.   APPEND ftab. ">점검.
    ENDIF.
  ENDIF.

ENDFORM.                    " set_function_by_BUSINESS
*&---------------------------------------------------------------------*
*&      Form  check_request_of_custom
*&---------------------------------------------------------------------*
*  수입통관문서의 종류/상태를 검증.
*----------------------------------------------------------------------*
FORM check_request_of_custom .
  DATA: l_ddtext LIKE g_ddtext.

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
*&      Form  get_available_cc_item
*&---------------------------------------------------------------------*
*       G/R을 입력할 통관 잔량을 체크함.
*----------------------------------------------------------------------*
FORM get_available_cc_item  TABLES   pt_ztisccit STRUCTURE it_ztisccit
                                     pt_iccno    STRUCTURE it_iccno
                            USING    p_msgty
                                     p_del_mode.
  DATA: l_ccmng LIKE ztitccp-ccmng,
        BEGIN OF lt_grmng OCCURS 5,
          shkzg LIKE  ztisgrit-shkzg,
          grmng LIKE  ztisgrit-grmng,
        END   OF lt_grmng.

  CLEAR: g_count, g_cnt.

  LOOP AT pt_ztisccit.
    g_tabix = sy-tabix.
    CLEAR: l_ccmng.
    REFRESH lt_grmng.
    IF ok_code EQ 'ZTICOPY'.
      SELECT shkzg grmng
        INTO CORRESPONDING FIELDS OF TABLE lt_grmng
        FROM ztivgr00
       WHERE iblno   EQ pt_ztisccit-iblno
         AND iccit   EQ pt_ztisccit-iccit.
*         AND RPTTY   NE
    ELSE.
      SELECT shkzg grmng
        INTO CORRESPONDING FIELDS OF TABLE lt_grmng
        FROM ztivgr00
       WHERE iccno   EQ pt_ztisccit-iccno
         AND iccit   EQ pt_ztisccit-iccit.
*         AND ( igrst EQ 'G'
*          OR   igrst EQ 'R' ).
    ENDIF.

    LOOP AT lt_grmng.
      IF lt_grmng-shkzg EQ 'S'.
        l_ccmng = l_ccmng + lt_grmng-grmng.
      ELSEIF lt_grmng-shkzg EQ 'H'.
        l_ccmng = l_ccmng - lt_grmng-grmng.
      ENDIF.
    ENDLOOP.

    pt_ztisccit-grmngs = l_ccmng.
    IF pt_ztisccit-grmngs LT 0.
      pt_ztisccit-grmngs = 0.
    ENDIF.

    pt_ztisccit-grmng =  pt_ztisccit-ccmng - pt_ztisccit-grmngs.

    IF pt_ztisccit-grmng LE c_zero.
      IF p_del_mode EQ c_true.
        DELETE pt_ztisccit INDEX g_tabix.
        CONTINUE.
      ELSE.
        pt_ztisccit-grmng = 0.
      ENDIF.
    ELSE.
      ADD 1 TO g_cnt.
    ENDIF.

    pt_ztisccit-grmngl =  pt_ztisccit-grmng.

*> Tree용 Internal table modify.
    ADD 1 TO g_count.
    pt_ztisccit-index = g_count.
    MODIFY pt_ztisccit INDEX g_tabix.

*> 수입의뢰관리번호별 collect.
    MOVE pt_ztisccit-iccno TO pt_iccno-iccno.
    COLLECT pt_iccno.
  ENDLOOP.

  DESCRIBE TABLE pt_ztisccit LINES g_line.
  IF g_line EQ 0.
    MESSAGE ID 'ZMMI' TYPE p_msgty NUMBER 902.
    EXIT.
  ENDIF.

  IF g_cnt EQ 0.
*    MESSAGE ID 'ZMMI' TYPE c_warning NUMBER 103.
    MESSAGE ID 'ZMMI' TYPE p_msgty NUMBER 103.
  ENDIF.

ENDFORM.                    " get_available_cc_item
*&---------------------------------------------------------------------*
*&      Form  display_import_doc_by_node
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_import_doc_by_node  USING    p_node_key.

  READ TABLE it_ztisccit INTO g_ztisccit_wa
                         WITH KEY index = p_node_key(10).
  IF sy-subrc EQ 0.
*    PERFORM  display_import_document USING g_ZTIsrqit_wa-reqno
*                                           g_ZTIsrqit_wa-amdsq
*                                           g_ZTIsrqit_wa-reqit.
  ELSE.
    MESSAGE s903.
  ENDIF.

ENDFORM.                    " display_import_doc_by_node
*&---------------------------------------------------------------------*
*&      Form  set_gr_initial_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_ZTITGRK  text
*----------------------------------------------------------------------*
FORM set_gr_initial_data  USING    p_ztitgrk STRUCTURE ztitgrk.

  DATA : l_ztitblk LIKE ztitblk.

  IF ok_code EQ 'ZTICOPY'.
    CLEAR: p_ztitgrk-iccno.
    READ TABLE it_ztisccit INDEX 1.
    IF sy-subrc EQ 0.
      p_ztitgrk-iblno = it_ztisccit-iblno.
*      p_ztitgrk-iccno = it_ztisccit-iblno.
    ENDIF.
  ELSE.
    p_ztitgrk-iccno = ztitcck-iccno.
    p_ztitgrk-iblno = ztitcck-iblno.
  ENDIF.


  SELECT SINGLE *
    INTO l_ztitblk
    FROM ztitblk
   WHERE iblno  EQ  p_ztitgrk-iblno.

  IF p_ztitgrk-igrty IS INITIAL.
    IF l_ztitblk-bldty EQ c_charo.
      p_ztitgrk-igrty = c_charr.
    ELSE.
      p_ztitgrk-igrty = c_charp.
    ENDIF.
  ENDIF.

  MOVE: l_ztitblk-rptty TO p_ztitgrk-rptty,
        l_ztitblk-iblno TO p_ztitgrk-iblno,
        l_ztitblk-lifnr TO p_ztitgrk-lifnr,
        l_ztitblk-pspnr TO p_ztitgrk-pspnr.

*>이동유형.
  IF p_ztitgrk-bwart IS INITIAL.
    SELECT SINGLE *
      FROM ztitig00
     WHERE bukrs EQ l_ztitblk-bukrs.
    IF p_ztitgrk-igrty = c_charp.
      IF l_ztitblk-bldty EQ 'S'.
        IF g_mode EQ c_charc.
          READ TABLE it_ztisccit INDEX 1.
          IF sy-subrc EQ 0.
            IF it_ztisccit-ebeln IS INITIAL.
              MOVE ztitig00-bwartn   TO p_ztitgrk-bwart.
            ELSE.
              MOVE ztitig00-bwarty   TO p_ztitgrk-bwart.
            ENDIF.
          ELSE.
            MOVE ztitig00-bwartn   TO p_ztitgrk-bwart.
          ENDIF.
        ELSE.
*          MOVE '102'             TO p_ztitgrk-bwart.
        ENDIF.
      ELSE.
        IF g_mode EQ c_charc.
          MOVE ztitig00-bwarty   TO p_ztitgrk-bwart.
        ELSE.
*          MOVE '102'             TO p_ztitgrk-bwart.
        ENDIF.
      ENDIF.
    ELSEIF p_ztitgrk-igrty = c_charr.
      IF g_mode EQ c_charc.
        MOVE '901'             TO p_ztitgrk-bwart.
      ELSE.
        MOVE '902'             TO p_ztitgrk-bwart.
      ENDIF.
    ENDIF.
  ENDIF.

*> 참조전표번호
  IF p_ztitgrk-frbnr IS INITIAL.
    p_ztitgrk-frbnr = ztitcck-cblno.
  ENDIF.
*> 참조전표번호
  IF p_ztitgrk-xblnr IS INITIAL.
    p_ztitgrk-xblnr = p_ztitgrk-iccno.
    CONCATENATE '통관:' p_ztitgrk-xblnr INTO p_ztitgrk-xblnr .
  ENDIF.

  IF p_ztitgrk-waers IS INITIAL.
    p_ztitgrk-waers = l_ztitblk-waers.
  ENDIF.

  IF p_ztitgrk-bukrs IS INITIAL.
    p_ztitgrk-bukrs = l_ztitblk-bukrs.
  ENDIF.

*>입고순번.
  IF p_ztitgrk-grseq IS INITIAL.
    IF p_ztitgrk-iccno IS INITIAL.
      SELECT MAX( grseq )
        INTO p_ztitgrk-grseq
        FROM ztitgrk
       WHERE iblno EQ p_ztitgrk-iblno.
    ELSE.
      SELECT MAX( grseq )
        INTO p_ztitgrk-grseq
        FROM ztitgrk
       WHERE iccno EQ p_ztitgrk-iccno.
    ENDIF.
    ADD 1 TO p_ztitgrk-grseq.
  ENDIF.

*>헤더 텍스트.
  IF p_ztitgrk-bktxt IS INITIAL.
    p_ztitgrk-bktxt = '수입 물품 입고'.
  ENDIF.

ENDFORM.                    " set_gr_initial_data
*&---------------------------------------------------------------------*
*&      Form  MATERIAL_Document_create
*&---------------------------------------------------------------------*
FORM material_document_create .

*> 공용 대화상자(메시지 통일).
  IF ok_code EQ 'ZTIPOST'.
    CALL FUNCTION 'Z_TI_POPUP_TO_CONFIRM_MESSAGE'
      EXPORTING
        xmode  = c_char8
      IMPORTING
        answer = g_answer.

    IF g_answer EQ c_charn.
      EXIT.
    ENDIF.
  ENDIF.

  CLEAR: g_subrc.
  PERFORM  check_for_document_field USING g_mode.
  IF g_cnt EQ 0.
    MESSAGE s911.
  ENDIF.
  IF ok_code EQ 'ZTICHECK'.
    testrun = c_true.
  ELSE.
    testrun = c_false.
  ENDIF.

  IF ztitgrk-mblnr IS INITIAL.
*> Set posting용 데이타 Move
    PERFORM  set_material_doc_data.
*> 전기용 BAPI 함수 Call
    PERFORM  call_bapi_function USING   testrun
                                        g_subrc.
*> 오류가 없을 경우.
    IF g_subrc EQ 0         AND    ">Success
       testrun EQ c_false.
      PERFORM p8000_save_master_data USING 'H'.

      PERFORM set_delivery_complete. "2024.01.11 ZITCS4HDEV01 추가

      MESSAGE s012(migo) WITH materialdocument.
      IF g_system_cnt EQ 0.
        PERFORM p9000_came_to_an_end.
        PERFORM p9000_program_exit.   ">Program Exit.
      ENDIF.
    ELSE.
      EXIT.
    ENDIF.
  ENDIF.

*> 오류가 없을 경우.
  IF g_subrc        EQ 0         AND    ">Success
     testrun        EQ c_false   AND
     g_system_cnt   GT 0         AND
     ztitgrk-qblnr IS INITIAL.
************************************************************************
*> 기기 장비재 로직 변경
*2. 수출입 시스템에서의 기자재 시스템의 구분은
*   자재 그룹이 '1Y'로 시작되는 자재 중 금액을 가진 자재는 시스템,
*   금액이 없는 자재는 아이템으로 구분
*   (기존 Account Assignment Category 'P'에서 'Q'로 변경)
************************************************************************
*************************< Begin of Insert >****************************
    CLEAR: g_subrc.
    PERFORM p8500_exec_mb1a_transaction.
*************************< End   of Insert >****************************
    IF g_subrc EQ 0.
      PERFORM p8000_save_master_data USING 'N'.
      MESSAGE s012(migo) WITH materialdocument.
      PERFORM p9000_came_to_an_end.
      PERFORM p9000_program_exit.   ">Program Exit.
    ELSE.
      MESSAGE e512.
    ENDIF.
  ENDIF.

ENDFORM.                    " MATERIAL_Document_create
*&---------------------------------------------------------------------*
*&      Form  set_material_doc_data
*&---------------------------------------------------------------------*
FORM set_material_doc_data .

  REFRESH : goodsmvt_item, goodsmvt_serialnumber, return.

  CLEAR :   goodsmvt_item, goodsmvt_serialnumber, return,
            materialdocument, matdocumentyear,
            goodsmvt_header,  goodsmvt_code.

*-----------------------------------------------------------------------
*  GOODSMVT_TRANSACTION.
*01:     MB01   : 구매오더에 대한 입고.
*02:     MB31   : 오더에 대한 입고.
*03:     MB1A   : 출고전기.
*04:     MB1B   : 이전전기.
*05:     MB1C   : 기타입고.
*06:     MB11   : 자재이동 입력.
  CASE ztitgrk-bwart.
    WHEN '101' OR '103' OR '105' OR '122' OR '124'.
*         '501' OR '511' OR '951'.
      goodsmvt_code-gm_code = '01'.
      g_mvt_ind = 'B'.        ">>>이동지시자.
    WHEN '501' OR '503' OR '505' OR '511' OR
         '951' OR '901'.
      goodsmvt_code-gm_code = '05'.
      CLEAR : g_mvt_ind.       ">>>이동지시자.
    WHEN OTHERS.
*         MESSAGE E641 WITH P_MVT_TYPE RAISING MVT_ERROR.
  ENDCASE.

  CLEAR: g_line.
  LOOP AT it_tab INTO g_tc_2130_wa.
    g_tabix = sy-tabix.
*> 하위 Batch가 있을 경우.
    IF g_tc_2130_wa-batchx = c_true.
      LOOP AT g_tc_7000_itab INTO g_tc_7000_wa
                             WHERE igrno EQ g_tc_2130_wa-igrno
                               AND iccit EQ g_tc_2130_wa-iccit.
        g_tabix = sy-tabix.
        PERFORM  set_sub_batch_gr_data.
        g_tc_7000_wa-zeile = g_line.
        MODIFY g_tc_7000_itab FROM g_tc_7000_wa INDEX g_tabix.
      ENDLOOP.
    ELSE.
      PERFORM  set_general_gr_data.
      g_tc_2130_wa-zeile = g_line.
      MODIFY it_tab FROM g_tc_2130_wa INDEX g_tabix.
    ENDIF.
  ENDLOOP.

*  GOODSMVT_HEADER.
  MOVE:ztitgrk-budat TO   goodsmvt_header-pstng_date,">전기일.
       ztitgrk-bldat TO   goodsmvt_header-doc_date,  ">증빙일.
       ztitgrk-xblnr TO   goodsmvt_header-ref_doc_no,">참조문서번호.
       ztitgrk-frbnr TO   goodsmvt_header-bill_of_lading, ">B/L No.
       space          TO   goodsmvt_header-gr_gi_slip_no,  "입/출고문서.
       sy-uname       TO   goodsmvt_header-pr_uname,       "
       ztitgrk-bktxt TO   goodsmvt_header-header_txt,    "
*        '1'           TO   GOODSMVT_HEADER-VER_GR_GI_SLIP, "
*        'X'           TO   GOODSMVT_HEADER-VER_GR_GI_SLIPX,"
       ztitgrk-wever TO   goodsmvt_header-ext_wms.">
*        SPACE         TO   GOODSMVT_HEADER-EXT_WMS.        "

ENDFORM.                    " set_material_doc_data
*&---------------------------------------------------------------------*
*&      Form  call_bapi_function
*&---------------------------------------------------------------------*
FORM call_bapi_function  USING    p_testrun LIKE bapi2017_gm_gen-testrun
                                  p_subrc.

  DATA: l_if_null    TYPE REF TO if_message_obj_mm.

*>---------------------------------------------------------------------
*> BEGIN TRANSACTION.
  IF p_testrun EQ c_false.
    SET UPDATE TASK LOCAL.
  ENDIF.
*>---------------------------------------------------------------------

*"----------------------------------------------------------------------


**Q20121031_43475 임시 테스트
*
*  LOOP AT goodsmvt_item.
*    IF goodsmvt_item-material IS NOT INITIAL.
*
*      SELECT SINGLE sernp INTO marc-sernp
*        FROM marc
*        WHERE matnr = goodsmvt_item-material
*          AND werks = goodsmvt_item-plant.
*
*      IF marc-sernp IS NOT INITIAL.
*        LOOP AT goodsmvt_serialnumber.
*          goodsmvt_serialnumber-serialno = goodsmvt_item-batch.
*
*          MODIFY goodsmvt_serialnumber.
*        ENDLOOP.
*      ENDIF.
*    ENDIF.
*
*
*  ENDLOOP.
**Q20121031_43475 임시 테스트


  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header       = goodsmvt_header
      goodsmvt_code         = goodsmvt_code
      testrun               = p_testrun
    IMPORTING
      goodsmvt_headret      = goodsmvt_headret
      materialdocument      = materialdocument
      matdocumentyear       = matdocumentyear
    TABLES
      goodsmvt_item         = goodsmvt_item
      goodsmvt_serialnumber = goodsmvt_serialnumber
      return                = return
    EXCEPTIONS
      OTHERS                = 4.

  p_subrc = sy-subrc.
*> build message
* Message preparations
  PERFORM  set_message_preparations.

  LOOP AT return.
    MESSAGE ID return-id TYPE c_success NUMBER return-number
              WITH   return-message_v1  return-message_v2
                     return-message_v3  return-message_v4.
    PERFORM set_return_message_fill USING return-type.
  ENDLOOP.

*> 전기시 문서번호를 채번하지 못하는 오류의 경우.
  IF p_testrun        EQ c_false AND
     return[]         IS INITIAL AND
     materialdocument IS INITIAL.
    MESSAGE s502.
    PERFORM set_return_message_fill USING return-type.
  ENDIF.

**Q20121031_43475 임시 테스트
*  IF p_testrun        EQ c_true.
*    call function 'BAPI_TRANSACTION_ROLLBACK'.
*  ENDIF.
**Q20121031_43475 임시 테스트


*> Error Message
*> 오류정보가 존재시 메시지 상자 POPUP.
  g_line = g_message_handler->get_severity_bo(
                          im_business_obj          = l_if_null
                          im_include_child_objects = c_true ).

  IF g_line GT 0.
**Q20121031_43475 임시 테스트
*    call function 'BAPI_TRANSACTION_ROLLBACK'.
**Q20121031_43475 임시 테스트

    CALL METHOD g_message_handler->show(
        im_popup  = c_true
        im_amodal = c_false ).
    p_subrc = 4.
  ELSE.
    MESSAGE s911.
    p_subrc = 0.
  ENDIF.

ENDFORM.                    " call_bapi_function
*&---------------------------------------------------------------------*
*&      Form  material_document_cancel
*&---------------------------------------------------------------------*
FORM material_document_cancel.

  PERFORM  set_cancel_document_number USING ztisscrcom.

  CLEAR: ok-code, g_subrc.

  CALL SCREEN  6010 STARTING AT 01    01.

  IF ok-code EQ 'ZTIOKAY'.
    ztitgrk-cbudat = ztisscrcom-cbudat.
    CLEAR: g_subrc.
*> 기기장비재 출고문서 Cancel
    IF NOT ztitgrk-qblnr IS INITIAL.
*> Set posting용 데이타 Move
      PERFORM  set_material_doc_cancel_data USING ztitgrk-qblnr
                                                  ztitgrk-qjahr.
*> 전기용 BAPI 함수 Call
      PERFORM  call_cancel_bapi_function USING   g_subrc
                                                 'O'.
      IF g_subrc EQ 0.
        PERFORM p8000_save_master_data USING 'C'.
        MESSAGE s060(m7) WITH goodsmvt_headret-mat_doc.
      ELSE.
        EXIT.
      ENDIF.
    ENDIF.

*> 입고문서 Cancel
    IF NOT ztitgrk-mblnr IS INITIAL.
      CLEAR: g_subrc.
*> Set posting용 데이타 Move
      PERFORM  set_material_doc_cancel_data USING ztitgrk-mblnr
                                                  ztitgrk-mjahr.
*> 전기용 BAPI 함수 Call
      PERFORM  call_cancel_bapi_function USING   g_subrc
                                                 'I'.
*> 오류가 없을 경우.
      IF g_subrc EQ 0 .    ">Success
        PERFORM p8000_save_master_data USING 'R'.
        MESSAGE s060(m7) WITH goodsmvt_headret-mat_doc.
        PERFORM p9000_came_to_an_end.
        PERFORM p9000_program_exit.   ">Program Exit.
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE s900.
  ENDIF.

ENDFORM.                    " material_document_cancel
*&---------------------------------------------------------------------*
*&      Form  set_material_doc_CANCEL_data
*&---------------------------------------------------------------------*
FORM set_material_doc_cancel_data USING p_mblnr LIKE ztitgrk-mblnr
                                        p_mjahr LIKE ztitgrk-mjahr.

  CLEAR : goodsmvt_headret,
          return,
          goodsmvt_matdocitem.

  REFRESH:return,
          goodsmvt_matdocitem.

  MOVE: p_mblnr           TO materialdocument,
        p_mjahr           TO matdocumentyear,
        sy-uname          TO goodsmvt_pr_uname,
        ztisscrcom-cbudat TO goodsmvt_pstng_date.

  SELECT zeile AS matdoc_item
    INTO CORRESPONDING FIELDS OF TABLE goodsmvt_matdocitem
    FROM mseg
   WHERE mblnr  EQ  materialdocument
     AND mjahr  EQ  matdocumentyear.

ENDFORM.                    " set_material_doc_CANCEL_data
*&---------------------------------------------------------------------*
*&      Form  call_cancel_bapi_function
*&---------------------------------------------------------------------*
FORM call_cancel_bapi_function  USING    p_subrc
                                         p_gubun.

  DATA: l_date(10)     TYPE c.
  DATA: l_if_null TYPE REF TO if_message_obj_mm.

*> BEGIN TRANSACTION.
  SET UPDATE TASK LOCAL.

* Message preparations
  PERFORM  set_message_preparations.

  REFRESH: bdcdata.
  CLEAR: session, goodsmvt_headret.

*  CTU_PARAMS-DISMODE  = 'N'. ">처리모드
*  CTU_PARAMS-UPDMODE  = 'S'. ">갱신모드
*  CTU_PARAMS-CATTMODE = ' '. ">CATT 모드...
*  CTU_PARAMS-DEFSIZE  = ' '. ">기본화면 크기
*  CTU_PARAMS-RACOMMIT = 'X'.
*  CTU_PARAMS-NOBINPT  = 'X' .
*  CTU_PARAMS-NOBIEND  = 'X'.

  WRITE goodsmvt_pstng_date TO l_date.

***************************************************************
* 20081223 simcho by 일련번호
***************************************************************
  DATA : lv_anzsn LIKE ser03-anzsn.

  PERFORM select_senr USING lv_anzsn
                   CHANGING lv_anzsn.
***************************************************************
* 20081223 simcho by 일련번호 관련 BDC
***************************************************************
*  IF LV_ANZSN > 0.
*
*    PERFORM BDC_DYNPRO_BUILD USING :
*           'X' 'SAPMM07M'          '0460',
*           ' ' 'MKPF-BUDAT'        L_DATE,
*           ' ' 'RM07M-MBLNR'       MATERIALDOCUMENT,
*           ' ' 'RM07M-MJAHR'       MATDOCUMENTYEAR,
*           ' ' 'BDC_OKCODE'       '/00'.          " '=SEKL'.
*
*    IF P_GUBUN EQ 'O'.
*      PERFORM BDC_DYNPRO_BUILD USING :
*             'X' 'SAPMM07M'          '0421',
*             ' ' 'BDC_OKCODE'       '=BU'.
*    ELSEIF P_GUBUN EQ 'I'.
*      PERFORM BDC_DYNPRO_BUILD USING :
*             'X' 'SAPMM07M'          '0221',
*             ' ' 'BDC_OKCODE'       '=BU'.
*    ENDIF.
*
*
*    DO LV_ANZSN TIMES.
*      PERFORM BDC_DYNPRO_BUILD USING :
*             'X' 'SAPLIPW1'        '0300',
*             ' ' 'BDC_OKCODE'      '/00'.
*    ENDDO.
****************************************************************
*  ELSE.
*
**> 초기화면.
*    PERFORM BDC_DYNPRO_BUILD USING :
*           'X' 'SAPMM07M'          '0460',
*           ' ' 'MKPF-BUDAT'        L_DATE,
*           ' ' 'RM07M-MBLNR'       MATERIALDOCUMENT,
*           ' ' 'RM07M-MJAHR'       MATDOCUMENTYEAR,
****************************************************************
** 20070612 simcho by 일련번호test
*           ' ' 'BDC_OKCODE'       '/00'.          " '=SEKL'.
****************************************************************
**> 초기화면.
****************************************************************
*
*    IF P_GUBUN EQ 'O'.
*      PERFORM BDC_DYNPRO_BUILD USING :
*             'X' 'SAPMM07M'          '0421',
*             ' ' 'BDC_OKCODE'       '=BU'.
*    ELSEIF P_GUBUN EQ 'I'.
*      PERFORM BDC_DYNPRO_BUILD USING :
*             'X' 'SAPMM07M'          '0221',
*             ' ' 'BDC_OKCODE'       '=BU'.
*    ENDIF.
*  ENDIF.
*
*  SET PARAMETER ID 'MBN' FIELD ''.
*  SET PARAMETER ID 'MJA' FIELD ''.
*
*  PERFORM BDC_TRANSACTION USING 'MBST' P_SUBRC.

  DATA : ls_head    LIKE bapi2017_gm_head_02,
         ls_headret LIKE bapi2017_gm_head_ret,
         lt_return  LIKE bapiret2 OCCURS 0 WITH HEADER LINE.

  CLEAR: ls_head, ls_headret, lt_return, lt_return[].

  ls_head-mat_doc    = materialdocument.
  ls_head-doc_year   = matdocumentyear.
  REPLACE ALL OCCURRENCES OF '.' IN L_date WITH ''.
  ls_head-pstng_date = L_date.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      materialdocument    = ls_head-mat_doc
      matdocumentyear     = ls_head-doc_year
      goodsmvt_pstng_date = ls_head-pstng_date
    IMPORTING
      goodsmvt_headret    = ls_headret
    TABLES
      return              = lt_return.


  IF ls_headret-mat_doc IS NOT INITIAL.

    goodsmvt_headret-mat_doc = ls_headret.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    READ TABLE lt_return WITH KEY type = 'E'.

    IF sy-subrc = 0.

**      GT_MSGCOLL-MSGTYP = 'W'.
*      MESSAGE ID GT_MSGCOLL-MSGID TYPE LT_RETURN-TYPE
*                                NUMBER LT_RETURN-NUMBER
*                                  WITH LT_RETURN-MESSAGE_V1
*                                       LT_RETURN-MESSAGE_V2
*                                       LT_RETURN-MESSAGE_V3
*                                       LT_RETURN-MESSAGE_V4.

      MESSAGE ID lt_return-id TYPE c_success NUMBER lt_return-number
                WITH   lt_return-message_v1  lt_return-message_v2
                       lt_return-message_v3  lt_return-message_v4.
      PERFORM set_return_message_fill USING lt_return-type.

    ENDIF.

  ENDIF.

*  IF P_SUBRC  EQ  C_ZERO.
*    GET PARAMETER ID 'MBN' FIELD GOODSMVT_HEADRET-MAT_DOC.
*    GET PARAMETER ID 'MJA' FIELD GOODSMVT_HEADRET-DOC_YEAR.
*    IF NOT GOODSMVT_HEADRET-MAT_DOC IS INITIAL.
*      P_SUBRC = 0.
*    ELSE.
*      IF SY-CALLD EQ C_TRUE.
*        MESSAGE E870.
*      ELSE.
*        MESSAGE S870.
*        PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
*      ENDIF.
*      P_SUBRC = 4.
*    ENDIF.
*  ELSE.
*    LOOP AT MESSTAB.
*      IF SY-CALLD EQ C_TRUE.
*        MESSAGE ID MESSTAB-MSGID TYPE MESSTAB-MSGTYP
*                  NUMBER MESSTAB-MSGNR
*                  WITH   MESSTAB-MSGV1  MESSTAB-MSGV2
*                         MESSTAB-MSGV3  MESSTAB-MSGV4.
*      ELSE.
*        SY-MSGNO = MESSTAB-MSGNR.
*        ZTI_MESSAGE MESSTAB-MSGTYP MESSTAB-MSGID SY-MSGNO
*            MESSTAB-MSGV1 MESSTAB-MSGV2 MESSTAB-MSGV3 MESSTAB-MSGV4.
*      ENDIF.
*    ENDLOOP.
*    P_SUBRC = 4.
*  ENDIF.

*********************************************************************
** 2008.12.23 공조 일련번호 관리 GR reverse test
*********************************************************************
**  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
**    EXPORTING
**      materialdocument    = materialdocument
**      matdocumentyear     = matdocumentyear
**      goodsmvt_pstng_date = goodsmvt_pstng_date
**      goodsmvt_pr_uname   = goodsmvt_pr_uname
**    IMPORTING
**      goodsmvt_headret    = goodsmvt_headret
**    TABLES
**      goodsmvt_matdocitem = goodsmvt_matdocitem
**      return              = return.
**
**> build message
**  REFRESH it_msg.
**  LOOP AT return.
**    MESSAGE ID return-id TYPE c_success NUMBER return-number
**              WITH   return-message_v1  return-message_v2
**                     return-message_v3  return-message_v4.
**    PERFORM set_return_message_fill USING return-type.
**  ENDLOOP.
**
**> 전기시 문서번호를 채번하지 못하는 오류의 경우.
**  IF return[]                 IS INITIAL AND
**     goodsmvt_headret-mat_doc IS INITIAL.
**    MESSAGE s502.
**    PERFORM set_return_message_fill USING return-type.
**  ENDIF.
*********************************************************************


*
*> Error Message
*> 오류정보가 존재시 메시지 상자 POPUP.
  g_line = g_message_handler->get_severity_bo(
                          im_business_obj          = l_if_null
                          im_include_child_objects = c_true ).

  IF g_line GT 0.
    CALL METHOD g_message_handler->show(
        im_popup  = c_true
        im_amodal = c_false ).
    p_subrc = 4.
  ELSE.
    MESSAGE s911.
    p_subrc = 0.
  ENDIF.

ENDFORM.                    " call_cancel_bapi_function
*&---------------------------------------------------------------------*
*&      Form  SCR2123_FIELDCAT_BUILD
*&---------------------------------------------------------------------*
FORM scr2123_fieldcat_build .

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZTISGRHS'
    CHANGING
      ct_fieldcat      = it_fieldcat_lvc[].

  LOOP AT it_fieldcat_lvc.
    CASE it_fieldcat_lvc-fieldname.
      WHEN 'GRSEQ' OR 'BWART' OR 'BLDAT' OR
           'BUDAT'.
        it_fieldcat_lvc-key     = c_true.
      WHEN 'MBLNR' OR 'MJAHR'.
        it_fieldcat_lvc-key     = c_true.
        it_fieldcat_lvc-hotspot = c_true.
      WHEN 'QBLNR' OR 'QJAHR'.
        it_fieldcat_lvc-key     = c_true.
        it_fieldcat_lvc-hotspot = c_true.
      WHEN 'CQBLNR' OR 'CQJAHR'.
        it_fieldcat_lvc-hotspot = c_true.
      WHEN 'CMBLNR' OR 'CMJAHR'.
        it_fieldcat_lvc-hotspot = c_true.
      WHEN 'IGRNO' OR 'FLAG'.
        it_fieldcat_lvc-no_out  = c_true.
      WHEN 'IGRST'.
        it_fieldcat_lvc-no_out  = c_true.
      WHEN 'GRSTX'.
        it_fieldcat_lvc-scrtext_l = '전표상태'.
        it_fieldcat_lvc-scrtext_m = '전표상태'.
        it_fieldcat_lvc-scrtext_s = '전표상태'.
        it_fieldcat_lvc-outputlen = 10.
        it_fieldcat_lvc-col_pos   = 4.
        it_fieldcat_lvc-key       = c_true.
      WHEN OTHERS.
    ENDCASE.
    MODIFY it_fieldcat_lvc.
  ENDLOOP.

ENDFORM.                    " SCR2123_FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*&      Form  handle_double_click
*&---------------------------------------------------------------------*
FORM handle_double_click  USING  p_row p_column.

  READ TABLE it_ztisgrhs INDEX p_row.

  CHECK sy-subrc = 0.

  CASE p_column.
    WHEN 'CMBLNR' OR 'CMJAHR' OR 'CBUDAT'.
      IF NOT it_ztisgrhs-cmblnr IS INITIAL.
        PERFORM display_material_doc USING  it_ztisgrhs-cmblnr
                                            it_ztisgrhs-cmjahr
                                            '0000'
                                            ztitgrk-bukrs.
      ENDIF.
    WHEN OTHERS.
      IF NOT it_ztisgrhs-mblnr IS INITIAL.
        PERFORM display_material_doc USING  it_ztisgrhs-mblnr
                                            it_ztisgrhs-mjahr
                                            '0000'
                                            ztitgrk-bukrs.
      ENDIF.
  ENDCASE.

ENDFORM.                    "handle_double_click
*&---------------------------------------------------------------------*
*&      Form  handle_hotspot_click
*&---------------------------------------------------------------------*
FORM handle_hotspot_click  USING e_row_id    TYPE lvc_s_row
                                 e_column_id TYPE lvc_s_col.

  READ TABLE it_ztisgrhs INDEX e_row_id-index.

  CHECK sy-subrc = 0.

  CASE e_column_id-fieldname.
    WHEN 'CMBLNR' OR 'CMJAHR' OR 'CBUDAT'.
      IF NOT it_ztisgrhs-cmblnr IS INITIAL.
        PERFORM display_material_doc USING  it_ztisgrhs-cmblnr
                                            it_ztisgrhs-cmjahr
                                            '0000'
                                            ztitgrk-bukrs.
      ENDIF.
    WHEN OTHERS.
      IF NOT it_ztisgrhs-mblnr IS INITIAL.
        PERFORM display_material_doc USING  it_ztisgrhs-mblnr
                                            it_ztisgrhs-mjahr
                                            '0000'
                                            ztitgrk-bukrs.
      ENDIF.
  ENDCASE.

ENDFORM.                    "_hotspot_click
*&---------------------------------------------------------------------*
*&      Form  account_document_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM account_document_display  USING    p_bukrs
                                        p_mjahr
                                        p_mblnr.

  DATA: l_awtyp      LIKE  acchd-awtyp,
        l_awref      LIKE  acchd-awref,
        l_aworg      LIKE  acchd-aworg,
        l_awsys      LIKE  acchd-awsys,
        l_awtyp_incl LIKE  acchd-awtyp,
        l_awtyp_excl LIKE  acchd-awtyp,
        l_bukrs      LIKE  accit-bukrs,
        l_valutyp    LIKE  acccr-valutyp   VALUE '0'.

  CHECK NOT p_mblnr IS INITIAL.

  l_awref = p_mblnr.
  l_aworg = p_mjahr.
  l_awtyp = 'MKPF'.

  CALL FUNCTION 'AC_DOCUMENT_RECORD'
    EXPORTING
      i_awtyp      = l_awtyp
      i_awref      = l_awref
      i_aworg      = l_aworg
*     i_awsys      = L_awsys
    EXCEPTIONS
      no_reference = 1
      no_document  = 2
      OTHERS       = 3.
  CASE sy-subrc.
    WHEN 0.
    WHEN 1.
      MESSAGE s008(mick) WITH p_mblnr p_mjahr.
    WHEN OTHERS.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
                          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDCASE.

ENDFORM.                    " account_document_display
*&---------------------------------------------------------------------*
*&      Form  set_cancel_document_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_cancel_document_number  USING    p_ztisscrcom  LIKE ztisscrcom.

  MOVE: ztitgrk-mblnr  TO ztisscrcom-mblnr,
        ztitgrk-mjahr  TO ztisscrcom-mjahr,
        ztitgrk-bukrs  TO ztisscrcom-bukrs,
        ztitgrk-cbudat TO ztisscrcom-cbudat.

  IF ztisscrcom-cbudat IS INITIAL.
    ztisscrcom-cbudat = sy-datlo.
  ENDIF.

  spop-textline1 = '해당 입고문서를 취소하시겠습니까?'.

ENDFORM.                    " set_cancel_document_number
*&---------------------------------------------------------------------*
*&      Form  set_batch_storage_location
*&---------------------------------------------------------------------*
*       저장위치 일괄지정
*----------------------------------------------------------------------*
FORM set_batch_storage_location .

  LOOP AT it_tab INTO g_tc_2130_wa.
    MOVE-CORRESPONDING g_tc_2130_wa TO ztitgrp.
    EXIT.
  ENDLOOP.
  spop-textline1 = '해당 저장위치로 일괄지정합니다.'.

  CLEAR: ok-code.

  CALL SCREEN  6020 STARTING AT 01    01.

  IF ok-code EQ 'ZTIOKAY'.
    LOOP AT it_tab INTO g_tc_2130_wa.
      g_tabix = sy-tabix.
      IF g_tc_2130_wa-knttp NE c_charp.
        MOVE: ztitgrp-lgort TO g_tc_2130_wa-lgort,
              ztitgrp-batch TO g_tc_2130_wa-batch.
*> Get Locations
        SELECT SINGLE lgobe
          INTO (g_tc_2130_wa-lgobe)
          FROM t001l
         WHERE werks  EQ  g_tc_2130_wa-werks
           AND lgort  EQ  g_tc_2130_wa-lgort.
*> Modify
        MODIFY it_tab FROM g_tc_2130_wa INDEX g_tabix.
      ENDIF.
    ENDLOOP.
  ELSE.
    MESSAGE s900.
  ENDIF.

ENDFORM.                    " set_batch_storage_location
*&---------------------------------------------------------------------*
*&      Form  p8500_exec_mb1a_transaction
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p8500_exec_mb1a_transaction .

  DATA: l_mvt_ind LIKE   goodsmvt_item-mvt_ind,
        l_ekkn    LIKE   ekkn.
  DATA: l_if_null    TYPE REF TO if_message_obj_mm.

  goodsmvt_code-gm_code = '03'.
  CLEAR : l_mvt_ind, g_subrc.


*  GOODSMVT_HEADER.
  MOVE:ztitgrk-budat TO   goodsmvt_header-pstng_date,">전기일.
       ztitgrk-bldat TO   goodsmvt_header-doc_date,  ">증빙일.
       ztitgrk-xblnr TO   goodsmvt_header-ref_doc_no,">참조문서번호.
       ztitgrk-frbnr TO   goodsmvt_header-bill_of_lading, ">B/L No.
       space          TO   goodsmvt_header-gr_gi_slip_no,  "입/출고문서.
       sy-uname       TO   goodsmvt_header-pr_uname,       "
       '기기장비재 출고' TO   goodsmvt_header-header_txt,    "
*        '1'           TO   GOODSMVT_HEADER-VER_GR_GI_SLIP, "
*        'X'           TO   GOODSMVT_HEADER-VER_GR_GI_SLIPX,"
       ztitgrk-wever TO   goodsmvt_header-ext_wms.">
*        SPACE         TO   GOODSMVT_HEADER-EXT_WMS.        "

  REFRESH: goodsmvt_item, goodsmvt_serialnumber.
  CLEAR: g_count, g_subrc,  g_line.
  LOOP AT it_tab INTO g_tc_2130_wa.
    IF g_tc_2130_wa-knttp    EQ c_charq AND
       g_tc_2130_wa-matnr    NE space   AND
       g_tc_2130_wa-repos    EQ c_true  AND
       g_tc_2130_wa-matkl(2) EQ '1Y'.
      ADD 1 TO g_count.
*> clear item structure
      CLEAR : goodsmvt_item.

      SELECT SINGLE *
        FROM ekpo
       WHERE ebeln EQ g_tc_2130_wa-ebeln
         AND ebelp EQ g_tc_2130_wa-ebelp.

      ADD    1            TO  g_line.

      MOVE:
           g_tc_2130_wa-matnr TO goodsmvt_item-material,
           g_tc_2130_wa-werks TO goodsmvt_item-plant,
           g_tc_2130_wa-lgort TO goodsmvt_item-stge_loc,
           g_tc_2130_wa-batch TO goodsmvt_item-batch,
           '221'              TO goodsmvt_item-move_type,
           space              TO goodsmvt_item-stck_type,
           'Q'                TO goodsmvt_item-spec_stock,
*           ZTITGRK-lifnr     TO goodsmvt_item-vendor,
           space              TO goodsmvt_item-customer,
           space              TO goodsmvt_item-sales_ord,
           space              TO goodsmvt_item-s_ord_item,
           space              TO goodsmvt_item-sched_line,
           space              TO goodsmvt_item-val_type,
           g_tc_2130_wa-grmng TO goodsmvt_item-entry_qnt, " 단위수량.
           g_tc_2130_wa-meins TO goodsmvt_item-entry_uom, " 입력단위.
*         EKPO-BPRME         TO GOODSMVT_ITEM-ENTRY_UOM_ISO,"ISO코드.
*         EKPO-PEINH         TO GOODSMVT_ITEM-PO_PR_QNT,   "가격단위.
*           ekpo-bprme         TO goodsmvt_item-orderpr_un, " 가격단위
*           EKPO-BPRME         TO GOODSMVT_ITEM-ORDERPR_UN_ISO,"ISO 코?
*           g_tc_2130_wa-ebeln TO goodsmvt_item-po_number,     " P/O번호
*           g_tc_2130_wa-ebelp TO goodsmvt_item-po_item,       "품목번호
           space              TO goodsmvt_item-shipping,     "출하지시.
           space              TO goodsmvt_item-comp_ship, "출하지시준수.
*           l_no_more_gr       TO goodsmvt_item-no_more_gr, " 납품완표.
*           g_tc_2130_wa-sgtxt TO goodsmvt_item-item_text,  "품목텍스트.
*           sy-uname           TO goodsmvt_item-gr_rcpt,    "자재수령인.
*           g_tc_2130_wa-ablad TO goodsmvt_item-unload_pt,  "하역지점.
           space              TO goodsmvt_item-costcenter, "코스트센터.
           space              TO goodsmvt_item-orderid,    "오더번호.
           space              TO goodsmvt_item-order_itno,"오더품목번호.
           space              TO goodsmvt_item-calc_motive,"회계지시자.
           space              TO goodsmvt_item-asset_no,  "주요자산번호.
           space              TO goodsmvt_item-sub_number, "자산보조번호
*           g_tc_2130_wa-rsnum TO goodsmvt_item-reserv_no,  "예약/종속NO
*           g_tc_2130_wa-rspos TO goodsmvt_item-res_item,   "예약/종속
*           g_tc_2130_wa-rsart TO goodsmvt_item-res_type,   "레코드유형.
           space              TO goodsmvt_item-withdrawn,  "예약에 대해.
           g_tc_2130_wa-matnr TO goodsmvt_item-move_mat,   "입고자재.
           g_tc_2130_wa-werks TO goodsmvt_item-move_plant, "입고플랜트.
           g_tc_2130_wa-lgort TO goodsmvt_item-move_stloc, "입고SLOG
           g_tc_2130_wa-batch TO goodsmvt_item-move_batch, "입고 batch
           space              TO goodsmvt_item-move_val_type,"batch 이동
           l_mvt_ind          TO goodsmvt_item-mvt_ind,    " 이동지시자
           ztitgrk-grund     TO goodsmvt_item-move_reas,  " 이동사유.
           space              TO goodsmvt_item-rl_est_key, "
           space              TO goodsmvt_item-ref_date,   "정산참조.
           space              TO goodsmvt_item-cost_obj,   "원가집적.
           space              TO goodsmvt_item-profit_segm_no, " 수익.
           space              TO goodsmvt_item-profit_ctr,  " 손익센터.
           space              TO goodsmvt_item-wbs_elem,    "(WBS 요소)
           space              TO goodsmvt_item-network,     " 계정지정.
           space              TO goodsmvt_item-activity,    " 작업번호.
           space              TO goodsmvt_item-part_acct,   "거래처.
*         space              TO GOODSMVT_ITEM-AMOUNT_LC,   "현지통지.
*         space              TO GOODSMVT_ITEM-AMOUNT_SV,   "현지통지.
          space              TO goodsmvt_item-ref_doc_yr,  "Ref회계연도.
          space              TO goodsmvt_item-ref_doc,     "Ref문서번호.
          space              TO goodsmvt_item-ref_doc_it,  "Ref문서품호.
*           g_tc_2130_wa-vfdat TO goodsmvt_item-expirydate,  "수명만기일
*           g_tc_2130_wa-hsdat TO goodsmvt_item-prod_date,  "Batch생산일
           space              TO goodsmvt_item-fund,        "펀드.
           space              TO goodsmvt_item-funds_ctr,   "예산관리센?
           space              TO goodsmvt_item-cmmt_item,   "약정항?
           space              TO goodsmvt_item-val_sales_ord,"판매오더?
           space              TO goodsmvt_item-val_s_ord_item,"오더품?
           space              TO goodsmvt_item-val_wbs_elem, "(WBS 요소)
           space              TO goodsmvt_item-gl_account,   "G/L계정번?
           space              TO goodsmvt_item-ind_propose_quanx, "제?
           space              TO goodsmvt_item-xstob,      "역분개이름.
*           g_tc_2130_wa-stawn TO goodsmvt_item-ean_upc,
*           g_tc_2130_wa-vbeln TO goodsmvt_item-deliv_numb_to_search,
*                                                          " 납품번호.
*           g_tc_2130_wa-posnr TO goodsmvt_item-deliv_item_to_search,
*                                                          " 납품품목.
           space  TO  goodsmvt_item-serialno_auto_numberassignment,
*       g_tc_2130_wa-licha TO goodsmvt_item-vendrbatch,  "공급업체BATCH

           space              TO goodsmvt_item-stge_type,     " 저장유?
           space              TO goodsmvt_item-stge_bin,      " 저장 bin
           space              TO goodsmvt_item-su_pl_stck_1,  "저장단위?
*         W_MENGE            TO GOODSMVT_ITEM-ST_UN_QTYY_1,  "단위별수?
*         EKPO-BPRME         TO GOODSMVT_ITEM-ST_UN_QTYY_1_ISO,  "ISO
           space              TO goodsmvt_item-unittype_1, " 저장단위유?
           space              TO goodsmvt_item-su_pl_stck_2, "저장단위?
           space              TO goodsmvt_item-st_un_qtyy_2, "단위별수?
           space              TO goodsmvt_item-st_un_qtyy_2_iso, "ISO
           space              TO goodsmvt_item-unittype_2,  "저장단위유?
           space              TO goodsmvt_item-stge_type_pc,"이전전?
           space              TO goodsmvt_item-stge_bin_pc, "저장 bin
           space              TO goodsmvt_item-no_pst_chgnt,"변경통?
           space              TO goodsmvt_item-gr_number,   " 입고번?
           space              TO goodsmvt_item-stge_type_st," 재고이전?
           space              TO goodsmvt_item-stge_bin_st, " 재고이전?
           space              TO goodsmvt_item-matdoc_tr_cancel,
                                " 취소예정인 이전요청(TR) 자재문서번?
           space              TO goodsmvt_item-matitem_tr_cancel,
                                " 취소예정인 이전요청(TR) 자재문서번?
           space              TO goodsmvt_item-matitem_tr_cancel,
                                " 취소예정인 이전요청(TR) 자재문서품?
           space              TO goodsmvt_item-matyear_tr_cancel,
                                " 취소될 이전요청의 자재문서연?
           space              TO goodsmvt_item-no_transfer_req,
                                " 지시자: 생성된 이전요청(TR)없?
           space              TO goodsmvt_item-co_busproc,
                                " 비지니스프로세?
           space              TO goodsmvt_item-acttype,     "액티비티유?
*           ZTITGRK-lifnr     TO goodsmvt_item-suppl_vend,  " 공급업?
           space              TO goodsmvt_item-material_external,
                      " 필드 MATERIAL에 대한 긴 자재번호 (차후개발)
           space              TO goodsmvt_item-material_guid,
                      " 필드 MATERIAL에 대한 외부 GUID (차후개발)
           space              TO goodsmvt_item-material_version,
                      " 필드 MATERIAL에 대한 버젼번호 (차후개발)
           space              TO goodsmvt_item-move_mat_external,
                      " 필드 MOVE_에 대한 긴 자재번호 (차후개발)
           space              TO goodsmvt_item-move_mat_guid,
                      " 필드 MOVE_MAT에 대한 외부 GUID (차후개발)
           space              TO goodsmvt_item-move_mat_version.
      " 필드 MOVE_MAT에 대한 버젼번호 (차후개발)
*         SPACE              TO GOODSMVT_ITEM-FUNC_AREA,
*                      " Functional 영역.
*         SPACE              TO GOODSMVT_ITEM-TR_PART_BA,
*                     " 관계사 사업영역.
*          ZTITGRK-bukrs     TO GOODSMVT_ITEM-PAR_COMPCO.
*                     " 반제 회사코드.
*         g_tc_2130_wa-vbeln TO goodsmvt_item-deliv_numb,   " 납품.
*         g_tc_2130_wa-posnr TO goodsmvt_item-deliv_item.   " 납품품목.
*         SPACE              TO GOODSMVT_ITEM-NB_SLIPS,  " GR/GI전표?
*         SPACE              TO GOODSMVT_ITEM-NB_SLIPSX,
*                    " 관련사용자 데이타필드의 갱신정?
*
*         SPACE              TO GOODSMVT_ITEM-GR_RCPTX,
*                    " 관련사용 데이타필드의 갱신정?
*         SPACE              TO GOODSMVT_ITEM-UNLOAD_PTX.
*                    " 관련사용자 데이타필드의 갱신정?
      SELECT ps_psp_pnr
        INTO l_ekkn-ps_psp_pnr
        FROM ekkn
       WHERE ebeln EQ g_tc_2130_wa-ebeln
         AND ebelp EQ g_tc_2130_wa-ebelp.
      ENDSELECT.

      CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
        EXPORTING
          input  = l_ekkn-ps_psp_pnr
        IMPORTING
          output = goodsmvt_item-val_wbs_elem.
*          goodsmvt_item-wbs_elem.
*
*      MOVE: goodsmvt_item-wbs_elem TO goodsmvt_item-val_wbs_elem.

*>> ITEM APPEND
      APPEND goodsmvt_item.

*      goodsmvt_serialnumber-matdoc_itm = g_line.
*      goodsmvt_serialnumber-serialno   = g_line.
*      APPEND   goodsmvt_serialnumber.
    ENDIF.
  ENDLOOP.

  IF g_line GT 0.
*>---------------------------------------------------------------------
*> BEGIN TRANSACTION.
    SET UPDATE TASK LOCAL.
*>---------------------------------------------------------------------

    REFRESH: return.
    CLEAR : materialdocument, matdocumentyear, goodsmvt_headret.
*"----------------------------------------------------------------------

**Q20121031_43475 임시 테스트
*
*  loop at goodsmvt_item.
*    if goodsmvt_item-material is not initial.
*
*      select single sernp into marc-sernp
*        from marc
*        where matnr = goodsmvt_item-material
*          and werks = goodsmvt_item-plant.
*
*      if marc-sernp is not initial.
*        loop at goodsmvt_serialnumber.
*          goodsmvt_serialnumber-serialno = goodsmvt_item-batch.
*
*          modify goodsmvt_serialnumber.
*        endloop.
*      endif.
*    endif.
*
*
*  endloop.
**Q20121031_43475 임시 테스트



    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        goodsmvt_header       = goodsmvt_header
        goodsmvt_code         = goodsmvt_code
*       testrun               = p_testrun
      IMPORTING
        goodsmvt_headret      = goodsmvt_headret
        materialdocument      = materialdocument
        matdocumentyear       = matdocumentyear
      TABLES
        goodsmvt_item         = goodsmvt_item
        goodsmvt_serialnumber = goodsmvt_serialnumber
        return                = return
      EXCEPTIONS
        OTHERS                = 4.

    g_subrc = sy-subrc.
* Message preparations
    PERFORM  set_message_preparations.

*> build message
    LOOP AT return.
      MESSAGE ID return-id TYPE c_success NUMBER return-number
                WITH   return-message_v1  return-message_v2
                       return-message_v3  return-message_v4.
      PERFORM set_return_message_fill USING return-type.
    ENDLOOP.

*> 전기시 문서번호를 채번하지 못하는 오류의 경우.
    IF return[]         IS INITIAL AND
       materialdocument IS INITIAL.
      MESSAGE s502.
      PERFORM set_return_message_fill USING return-type.
    ENDIF.

*> 오류정보가 존재시 메시지 상자 POPUP.
    g_line = g_message_handler->get_severity_bo(
                            im_business_obj          = l_if_null
                            im_include_child_objects = c_true ).

    IF g_line GT 0.
      CALL METHOD g_message_handler->show(
          im_popup  = c_true
          im_amodal = c_false ).
      g_subrc = 4.
      ROLLBACK WORK.
    ELSE.
      MESSAGE s911.
      g_subrc = 0.
    ENDIF.

  ENDIF.

ENDFORM.                    " p8500_exec_mb1a_transaction
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p1001_initialization .

  SET TITLEBAR 'T1000' WITH 'Due List'(t10).

ENDFORM.                    " p1001_initialization
*&---------------------------------------------------------------------*
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p2000_data_selections .

  DATA: l_rqmng LIKE ztitrqp-rqmng,
        l_count TYPE i.

  DATA : lt_ekes LIKE TABLE OF ekes WITH HEADER LINE .

  CLEAR: g_count, it_tab_h, it_ztitig02, it_header, it_list.
  REFRESH : it_tab_h, it_ztitig02, it_header, it_list.
*> PROGRESS Display.
  g_linen    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_linen INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.

*> B/L 데이타 select.

  IF s_vbeln[] IS INITIAL.
    "CCM : 2023.04.12  ZITCS4HDEV04 - 운영팀확인필요(인터널테이블 IT_TAB_H-CFRAT 타입과 ZTITBLK-CFRAT 필드 타입다름)
    SELECT *
          INTO CORRESPONDING FIELDS OF TABLE it_tab_h
          FROM ( ztitcck AS a JOIN ztitccp AS b
                  ON a~iccno  EQ b~iccno
                 AND a~iccsq  EQ b~iccsq
                 AND a~lstas  EQ b~iccsq ) INNER JOIN ztitblk AS c
                                           ON a~iblno EQ c~iblno
         WHERE a~iccno  IN s_iccno  "통관 관리번호.
**** HDY 20130626 START C20130625_56259
**** 스탠다드에서 입고 완료된 통관에 대해서 테이블 유지보수
**** 통관번호 하드코딩 주석처리

*........2010/07/15 단순문의ID:816141
*........C20130109_48932 R.by 오상환
*        C20130109_48969 R.by 오상환
*        C20130129_62102 R.by 오상환
*         AND a~iccno <> '1100018405'
*         AND a~iccno <> '1100031480'
*         AND a~iccno <> '1100031110'
*         AND a~iccno <> '1100031173'
*
**** HDY 20130626 END
           AND a~cdhdt  IN s_cdhdt  "8신고희망일자.
           AND a~cdcdt  IN s_cdcdt  "8신고수리일자.
           AND a~ekorg  IN s_ekorg
           AND a~ekgrp  IN s_ekgrp
           AND a~werks  IN s_werks
           AND c~blnum  IN s_blnum
           AND a~cdcno  IN s_cdcno
           AND a~cdadt  IN s_cdadt  "8수입신고 의뢰일자.
           AND a~cdcor  IN s_cdcor                            "3신고세관
           AND a~cdcch  IN s_cdcch                            "2신고과.
           AND a~cimty  IN s_cimty  "1수입자구분.
           AND a~cdapn  IN s_cdapn  "28신고의뢰자 상호.
           AND a~cimnm  IN s_cimnm  "28수입자상호.
           AND a~ccono  IN s_ccono  "8무역업등록번호.
           AND a~cdupn  IN s_cdupn  "28납세의무자상호.
           AND a~cdunm  IN s_cdunm  "12납세의무자성명.
           AND a~cduad1 IN s_cduad1 "20납세의무자 주소.
           AND a~cduad2 IN s_cduad2 "20납세의무자 주소.
           AND a~cplsg  IN s_cplsg  "3소재지부호.
           AND a~ccoid  IN s_ccoid  "13사업자 등록번호.
           AND a~ccuid  IN s_ccuid  "15통관고유번호.
           AND a~ccbnm  IN s_ccbnm  "28무역대리점상호.
           AND a~ccbid  IN s_ccbid  "7무역대리점부호.
           AND a~casnm  IN s_casnm  "30해외공급자상호.
           AND a~casld  IN s_casld  "3해외공급자국.
           AND a~casid  IN s_casid  "10해외공급자부호.
          AND a~crety  IN s_crety                            "1신고구분.
           AND a~ccupl  IN s_ccupl                            "1통관계.
           AND a~csaty  IN s_csaty                            "2거래구.
           AND a~cipty  IN s_cipty                            "1수입종.
           AND a~cpyme  IN s_cpyme                            "2결제방.
           AND a~carty  IN s_carty                            "2징수형.
           AND a~cildt  IN s_cildt                            "8반입일.
           AND a~cblno  IN s_cblno  "20B/L(AWB)번호.
           AND a~ccano  IN s_ccano  "20화물관리번호.
           AND a~cbldy  IN s_cbldy  "1B/L분할신고여부.
           AND a~cmbln  IN s_cmbln  "20Master B/L No.
           AND a~cispc  IN s_cispc  "8검사(반입)장소 코드.
           AND a~cispl  IN s_cispl  "10검사(반입)장소.
           AND a~ctrme  IN s_ctrme                            "2운송수.
           AND a~ctrbo  IN s_ctrbo                            "3운송용.
           AND a~cofld  IN s_cofld                            "3적출국.
           AND a~ctogi  IN s_ctogi  "4운수기관부호.
           AND a~cspto  IN s_cspto                            "2특송업.
           AND a~caldt  IN s_caldt                            "8입항일.
           AND a~ciarp  IN s_ciarp  "3국내도착항.
           AND a~cvsln  IN s_cvsln  "20선(기)명.
           AND a~cvsld  IN s_cvsld  "3선(기)국적.
          AND a~cinco  IN s_cinco                            "3인도조건.
           AND a~cpyatc IN s_cpyatc "5결제금액 통화.
           AND a~cpyat  IN s_cpyat  "11결제금액.
           AND a~ctoweu IN s_ctoweu "3총중량단위.
           AND a~ctowe  IN s_ctowe                            "15총중량.
           AND a~ctpkg  IN s_ctpkg  "8총포장갯수.
           AND a~ctpkgu IN s_ctpkgu "3총포장갯수단위.
           AND a~ctseq  IN s_ctseq                            "3총란수.
           AND b~iccit  IN s_iccit  "5수입신고 Items Number.
           AND b~ebeln  IN s_ebeln  "10구매전표번호.
           AND b~ebelp  IN s_ebelp  "5구매문서 품목번호.
           AND b~reqno  IN s_reqno  "10수입의뢰 관리번호.
           AND b~reqit  IN s_reqit  "5수입의뢰 품목번호.
           AND b~iblno  IN s_iblno  "10B/L 관리번호.
           AND b~iblit  IN s_iblit  "5B/L 품목번호.
           AND b~ndfty  IN s_ndfty  "1무환품 종류.
           AND b~ccmng  IN s_ccmng  "13통관 수량.
           AND b~refwr  IN s_refwr  "13송장값 (외화).
           AND b~meins  IN s_meins                            "3기본단.
           AND a~lstas  EQ a~iccsq
           AND b~cnam   IN s_cnam                             "12작성인.
           AND b~cdat   IN s_cdat                             "8생성일.
           AND b~ctme   IN s_ctme                             "6생성시.
           AND b~unam   IN s_unam   "12최종변경인.
           AND b~udat   IN s_udat                             "8변경일.
           AND b~utme   IN s_utme.  "6최종변경시간.


    IF sy-subrc NE 0.
      MESSAGE s902.  EXIT.
    ENDIF.


  ELSE.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_ekes
      FROM ekes
     WHERE vbeln  IN s_vbeln.


    IF sy-subrc NE 0.
      MESSAGE s902.  EXIT.
    ENDIF.


    IF lt_ekes[] IS NOT INITIAL.
      "CCM : 2023.04.12  ZITCS4HDEV04 - 운영팀확인필요(인터널테이블 IT_TAB_H-CFRAT 타입과 ZTITBLK-CFRAT 필드 타입다름)
      SELECT *
            INTO CORRESPONDING FIELDS OF TABLE it_tab_h
            FROM ( ztitcck AS a JOIN ztitccp AS b
                    ON a~iccno  EQ b~iccno
                   AND a~iccsq  EQ b~iccsq
                   AND a~lstas  EQ b~iccsq ) INNER JOIN ztitblk AS c
                                             ON a~iblno EQ c~iblno
                 FOR ALL ENTRIES IN lt_ekes
           WHERE  b~ebeln EQ  lt_ekes-ebeln
             AND  b~ebelp EQ  lt_ekes-ebelp
             AND  a~iccno  IN s_iccno  "통관 관리번호.
**** HDY 20130626 START C20130625_56259
**** 스탠다드에서 입고 완료된 통관에 대해서 테이블 유지보수
**** 통관번호 하드코딩 주석처리

*........2010/07/15 단순문의ID:816141
*........C20130109_48932 R.by 오상환
*        C20130109_48969 R.by 오상환
*        C20130129_62102 R.by 오상환
*         AND a~iccno <> '1100018405'
*         AND a~iccno <> '1100031480'
*         AND a~iccno <> '1100031110'
*         AND a~iccno <> '1100031173'
*
**** HDY 20130626 END
             AND a~cdhdt  IN s_cdhdt  "8신고희망일자.
             AND a~cdcdt  IN s_cdcdt  "8신고수리일자.
             AND a~ekorg  IN s_ekorg
             AND a~ekgrp  IN s_ekgrp
             AND a~werks  IN s_werks
             AND c~blnum  IN s_blnum
             AND a~cdcno  IN s_cdcno
             AND a~cdadt  IN s_cdadt  "8수입신고 의뢰일자.
           AND a~cdcor  IN s_cdcor                            "3신고세관
            AND a~cdcch  IN s_cdcch                            "2신고과.
             AND a~cimty  IN s_cimty  "1수입자구분.
             AND a~cdapn  IN s_cdapn  "28신고의뢰자 상호.
             AND a~cimnm  IN s_cimnm  "28수입자상호.
             AND a~ccono  IN s_ccono  "8무역업등록번호.
             AND a~cdupn  IN s_cdupn  "28납세의무자상호.
             AND a~cdunm  IN s_cdunm  "12납세의무자성명.
             AND a~cduad1 IN s_cduad1 "20납세의무자 주소.
             AND a~cduad2 IN s_cduad2 "20납세의무자 주소.
             AND a~cplsg  IN s_cplsg  "3소재지부호.
             AND a~ccoid  IN s_ccoid  "13사업자 등록번호.
             AND a~ccuid  IN s_ccuid  "15통관고유번호.
             AND a~ccbnm  IN s_ccbnm  "28무역대리점상호.
             AND a~ccbid  IN s_ccbid  "7무역대리점부호.
             AND a~casnm  IN s_casnm  "30해외공급자상호.
             AND a~casld  IN s_casld  "3해외공급자국.
             AND a~casid  IN s_casid  "10해외공급자부호.
            AND a~crety  IN s_crety                          "1신고구분.
            AND a~ccupl  IN s_ccupl                          "1통관계.
            AND a~csaty  IN s_csaty                          "2거래구.
            AND a~cipty  IN s_cipty                          "1수입종.
            AND a~cpyme  IN s_cpyme                          "2결제방.
            AND a~carty  IN s_carty                          "2징수형.
            AND a~cildt  IN s_cildt                          "8반입일.
             AND a~cblno  IN s_cblno  "20B/L(AWB)번호.
             AND a~ccano  IN s_ccano  "20화물관리번호.
             AND a~cbldy  IN s_cbldy  "1B/L분할신고여부.
             AND a~cmbln  IN s_cmbln  "20Master B/L No.
             AND a~cispc  IN s_cispc  "8검사(반입)장소 코드.
             AND a~cispl  IN s_cispl  "10검사(반입)장소.
            AND a~ctrme  IN s_ctrme                            "2운송수.
            AND a~ctrbo  IN s_ctrbo                            "3운송용.
            AND a~cofld  IN s_cofld                            "3적출국.
             AND a~ctogi  IN s_ctogi  "4운수기관부호.
            AND a~cspto  IN s_cspto                            "2특송업.
            AND a~caldt  IN s_caldt                            "8입항일.
             AND a~ciarp  IN s_ciarp  "3국내도착항.
             AND a~cvsln  IN s_cvsln  "20선(기)명.
             AND a~cvsld  IN s_cvsld  "3선(기)국적.
          AND a~cinco  IN s_cinco                            "3인도조건.
             AND a~cpyatc IN s_cpyatc "5결제금액 통화.
             AND a~cpyat  IN s_cpyat  "11결제금액.
             AND a~ctoweu IN s_ctoweu "3총중량단위.
           AND a~ctowe  IN s_ctowe                            "15총중량.
             AND a~ctpkg  IN s_ctpkg  "8총포장갯수.
             AND a~ctpkgu IN s_ctpkgu "3총포장갯수단위.
            AND a~ctseq  IN s_ctseq                            "3총란수.
             AND b~iccit  IN s_iccit  "5수입신고 Items Number.
             AND b~ebeln  IN s_ebeln  "10구매전표번호.
             AND b~ebelp  IN s_ebelp  "5구매문서 품목번호.
             AND b~reqno  IN s_reqno  "10수입의뢰 관리번호.
             AND b~reqit  IN s_reqit  "5수입의뢰 품목번호.
             AND b~iblno  IN s_iblno  "10B/L 관리번호.
             AND b~iblit  IN s_iblit  "5B/L 품목번호.
             AND b~ndfty  IN s_ndfty  "1무환품 종류.
             AND b~ccmng  IN s_ccmng  "13통관 수량.
             AND b~refwr  IN s_refwr  "13송장값 (외화).
            AND b~meins  IN s_meins                            "3기본단.
             AND a~lstas  EQ a~iccsq
           AND b~cnam   IN s_cnam                             "12작성인.
            AND b~cdat   IN s_cdat                             "8생성일.
            AND b~ctme   IN s_ctme                             "6생성시.
            AND b~unam   IN s_unam   "12최종변경인.
            AND b~udat   IN s_udat                             "8변경일.
            AND b~utme   IN s_utme.  "6최종변경시간.

      SORT lt_ekes BY ebeln ebelp.
    ENDIF.

  ENDIF.

  IF sy-subrc NE 0.
    MESSAGE s902.  EXIT.
  ENDIF.

*> 자가장치장 보세구역 출고 프로세스 사용시.
  IF ztitig00-bdmtu EQ c_true.
    SELECT iblno rptty
      INTO CORRESPONDING FIELDS OF TABLE it_ztitblk
      FROM ztitblk
       FOR ALL ENTRIES IN it_tab_h
     WHERE iblno  EQ  it_tab_h-iblno.
  ENDIF.

  CLEAR: g_tabix, g_count.
  LOOP AT it_tab_h.
    g_tabix = sy-tabix.
**** HDY 20130626 START C20130625_56259
**** 스탠다드에서 입고 완료된 통관에 대해서 테이블 유지보수
**** DEU LIST에 뜨지 않도록
    SELECT SINGLE iccno
       INTO gt_ztitztigr-iccno
       FROM ztitztigr
      WHERE iccno EQ it_tab_h-iccno.
    IF sy-subrc       EQ '0'.
      DELETE it_tab_h INDEX g_tabix.
      CONTINUE.
    ENDIF.
**** HDY 20130626 END

* 20050907 simcho - 박혁세D요청
*> B/L대표PO# 수입신고필증 PO항목으로 변경
    CLEAR ztitccp.
    SELECT SINGLE ebeln  ebelp
      INTO (it_tab_h-ebeln, it_tab_h-ebelp)
      FROM ztitccp
     WHERE iccno = it_tab_h-iccno
       AND iccsq = it_tab_h-iccsq
       AND iccit = it_tab_h-iccit.
********************************************************************
**> CSR : C20120222_56033 Start
********************************************************************
**> 미송장 처리일 경우.
*            IF ztitig00-igrmt EQ 'E'.
    IF p_ivchk = 'X'.
      CLEAR l_count.
      SELECT COUNT( * )
        INTO l_count
        FROM ztiviv00
       WHERE iblno EQ it_tab_h-iblno
         AND iblit EQ it_tab_h-iblit
         AND livst EQ 'P'.
*--> [가온] 사전 TT는 B/L 정보 없기에 PO/ITEM으로 한번 더 체크
**** 밑에서 수량으로 한번 더 체크해서 안전
      IF s_bukrs-low = '6000'.
        IF l_count EQ 0.
          SELECT COUNT( * )
            INTO l_count
            FROM ztiviv00
           WHERE ebeln EQ it_tab_h-ebeln
             AND ebelp EQ it_tab_h-ebelp
             AND livst EQ 'P'.
          IF l_count EQ 0.
            DELETE it_tab_h INDEX g_tabix.
            CONTINUE.
          ENDIF.
        ENDIF.
*<-- [가온] 사전 TT는 B/L 정보 없기에 PO/ITEM으로 한번 더 체크
      ELSE.
        DELETE it_tab_h INDEX g_tabix.
        CONTINUE.
      ENDIF.
    ENDIF.
*            ENDIF.
********************************************************************
**> CSR : C20120222_56033 End
********************************************************************


*> 자가장치장 보세구역 출고 프로세스 사용시.
    IF ztitig00-bdmtu EQ c_true AND
       it_tab_h-bdseq IS INITIAL.
      READ TABLE it_ztitblk WITH KEY iblno = it_tab_h-iblno.
      IF sy-subrc EQ 0.
*> 자가장치장일 경우, 보세구역 출고데이타로 Setting
        IF it_ztitblk-rptty EQ c_charn.
*          BREAK-POINT.
          DELETE it_tab_h INDEX g_tabix.

          SELECT bdqty bdseq ibdsq
            INTO (it_tab_h-ccmng, it_tab_h-bdseq, it_tab_h-ibdsq)
            FROM ztitbdp
           WHERE iccno EQ it_tab_h-iccno
             AND iccit EQ it_tab_h-iccit
             AND iblno EQ it_tab_h-iblno
             AND iblit EQ it_tab_h-iblit.
**> 미송장 처리일 경우.
*            IF ztitig00-igrmt EQ 'E'.
*            SELECT COUNT( * )
*              INTO l_count
*              FROM ztiviv00
*             WHERE iblno EQ it_tab_h-iblno
*               AND iblit EQ it_tab_h-iblit
*               AND livst EQ 'P'.
*            IF l_count EQ 0.
*              DELETE it_tab_h INDEX g_tabix.
*              CONTINUE.
*            ENDIF.
*            ENDIF.
*> CC 누적수량.
            SELECT SUM( grmng )
              INTO it_tab_h-grmngs
              FROM ztitgrp
             WHERE iccno  = it_tab_h-iccno
               AND iccit  = it_tab_h-iccit
               AND bdseq  = it_tab_h-bdseq
               AND ibdsq  = it_tab_h-ibdsq.
*> CC 가능수량.
            it_tab_h-grmngl =  it_tab_h-ccmng - it_tab_h-grmngs.

            IF it_tab_h-grmngl LE 0.
              CONTINUE.
            ENDIF.
            APPEND it_tab_h.
          ENDSELECT.
          CONTINUE.
        ELSE.
*> CC 누적수량.
          SELECT SUM( grmng )
            INTO it_tab_h-grmngs
            FROM ztitgrp
           WHERE iccno  = it_tab_h-iccno
             AND iccit  = it_tab_h-iccit.
*> CC 가능수량.
          it_tab_h-grmngl =  it_tab_h-ccmng - it_tab_h-grmngs.

          IF it_tab_h-grmngl LE 0.
            DELETE it_tab_h INDEX g_tabix.
            CONTINUE.
          ENDIF.
        ENDIF.
      ELSE.
*> 미송장 처리일 경우.
**        IF ztitig00-igrmt EQ 'E'.
*        SELECT COUNT( * )
*          INTO l_count
*          FROM ztiviv00
*         WHERE iblno EQ it_tab_h-iblno
*           AND iblit EQ it_tab_h-iblit
*           AND livst EQ 'P'.
*        IF l_count EQ 0.
*          DELETE it_tab_h INDEX g_tabix.
*          CONTINUE.
*        ENDIF.
*        ENDIF.
*> CC 누적수량.
        SELECT SUM( grmng )
          INTO it_tab_h-grmngs
          FROM ztitgrp
         WHERE iccno  = it_tab_h-iccno
           AND iccit  = it_tab_h-iccit.
*> CC 가능수량.
        it_tab_h-grmngl =  it_tab_h-ccmng - it_tab_h-grmngs.

        IF it_tab_h-grmngl LE 0.
          DELETE it_tab_h INDEX g_tabix.
          CONTINUE.
        ENDIF.
      ENDIF.
    ELSE.
*> CC 누적수량.
      SELECT SUM( grmng )
        INTO it_tab_h-grmngs
        FROM ztitgrp
       WHERE iccno  = it_tab_h-iccno
         AND iccit  = it_tab_h-iccit.
*> CC 가능수량.
      it_tab_h-grmngl =  it_tab_h-ccmng - it_tab_h-grmngs.

      IF it_tab_h-grmngl LE 0.
        DELETE it_tab_h INDEX g_tabix.
        CONTINUE.
      ENDIF.
    ENDIF.
*   p/o정보.
    SELECT  SINGLE menge matnr txz01 wepos
      INTO  (it_tab_h-menge, it_tab_h-matnr, it_tab_h-txz01,
             it_tab_h-wepos)
      FROM  ztivpo00
     WHERE  ebeln  = it_tab_h-ebeln
       AND  ebelp  = it_tab_h-ebelp.

    IF it_tab_h-wepos IS INITIAL.
      DELETE it_tab_h INDEX g_tabix.
      CONTINUE.
    ENDIF.


*-- [기능개선 ______]  인바운드 납품문서 조건추가 -[s]
    READ TABLE lt_ekes WITH KEY ebeln = it_tab_h-ebeln
                                ebelp = it_tab_h-ebelp
                                BINARY SEARCH.
    IF sy-subrc EQ 0.
      it_tab_h-vbeln = lt_ekes-vbeln .
    ENDIF.
*-- [기능개선 ______]  인바운드 납품문서 조건추가 -[e]


    ADD 1 TO g_count.
    MODIFY it_tab_h INDEX g_tabix.
  ENDLOOP.

  DESCRIBE TABLE it_tab_h LINES g_line.
  IF g_line EQ 0.
    MESSAGE s902.  EXIT.
  ENDIF.

ENDFORM.                    " p2000_data_selections
*&---------------------------------------------------------------------*
*&      Form  p2100_header_and_list_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p2100_header_and_list_build .

  LOOP AT it_tab_h.
    MOVE-CORRESPONDING it_tab_h TO : it_header, it_list.
* 20051013 simcho 헤더 환율sum 정보 clear -why? 필드 short dump
* 헤더 환율을 sum할 필요는 없
    CLEAR it_header-cpyrt.
*
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
          ' ' 'REF_TABNAME'   ' ',
          ' ' 'FIELDNAME'     'BOX',
          ' ' 'HOTSPOT'       ' ',
          'E' 'KEY'           ' ',

"CC 관리번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITCCK',
          ' ' 'FIELDNAME'     'ICCNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"CC 관리번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBDK',
          ' ' 'FIELDNAME'     'BDSEQ',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"수리번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITCCK',
          ' ' 'FIELDNAME'     'CDCNO',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '27',
"수리일.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITCCK',
          ' ' 'FIELDNAME'     'CDCDT',
          'E' 'OUTPUTLEN'     '12',
"B/L번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITCCK',
*          ' ' 'seltext_m'     '종류',
          ' ' 'FIELDNAME'     'CBLNO',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '20',
"선기명
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITCCK',
          ' ' 'FIELDNAME'     'CVSLN',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '40',
"화물관리번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITCCK',
*          ' ' 'seltext_m'     '신용장 종류',
          ' ' 'FIELDNAME'     'CCANO',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '20',
"입항일자
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITCCK',
          ' ' 'FIELDNAME'     'CALDT',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'NO_OUT'        'X',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '10',
"선기국적
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITCCK',
*          ' ' 'seltext_m'     '운송방법',
          ' ' 'FIELDNAME'     'CVSLD',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'NO_OUT'        'X',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '10',


*>>>>>>>>>LIST
"I/V 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITCCP',
          ' ' 'FIELDNAME'     'ICCIT',
          ' ' 'HOTSPOT'       'X',
          ' ' 'JUST'          c_charl," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         c_charx,
          ' ' 'INTLEN'         10,
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"구매전표번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLIT',
          ' ' 'FIELDNAME'     'EBELN',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '10',

"구매문서 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLIT',
          ' ' 'FIELDNAME'     'EBELP',

          ' ' 'HOTSPOT'       ' ',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '5',
"수입의뢰번호
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITCCP',
          ' ' 'FIELDNAME'     'REQNO',
          ' ' 'HOTSPOT'       'X',

          'E' 'KEY'           ' ',
*          'E' 'OUTPUTLEN'     '10',
"수입의뢰 품목번호
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITCCP',
          ' ' 'FIELDNAME'     'REQIT',
          ' ' 'NO_OUT'        'X',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '5',
"B/L관리번호
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITCCP',
          ' ' 'FIELDNAME'     'IBLNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '12',
"B/L 품목번호
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITCCP',
          ' ' 'FIELDNAME'     'IBLIT',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'NO_OUT'        'X',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '5',
"자재번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISCCIT',
          ' ' 'FIELDNAME'     'MATNR',
          'E' 'OUTPUTLEN'     '20',

"자재내역.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISCCIT',
          ' ' 'FIELDNAME'     'TXZ01',
          'E' 'OUTPUTLEN'     '40',

"통관수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITCCP',
          ' ' 'FIELDNAME'     'CCMNG',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'NO_OUT'        'X',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'HOTSPOT'       ' ',
          'E' 'KEY'           ' ',
"통관수량
          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTISGRIT',
          ' ' 'FIELDNAME'     'GRMNGL',
          ' ' 'seltext_S'     '입고가능수량',
          ' ' 'seltext_m'     '입고가능수량',
          ' ' 'seltext_L'     '입고가능수량',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'HOTSPOT'       ' ',
          'E' 'OUTPUTLEN'     '16',
"단위
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITCCP',
          ' ' 'FIELDNAME'     'MEINS',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '3'.


*-- [기능개선 ______]  인바운드 납품문서 필드 추가  -[s]
  IF s_vbeln[] IS NOT INITIAL.

    PERFORM 3010_fill_field_category USING :

    'S' 'TABNAME'       'IT_LIST',
    ' ' 'REF_TABNAME'   'EKES',
*          ' ' 'NO_OUT'        'X',
    ' ' 'seltext_L'     '인바운드납품',
    ' ' 'seltext_m'     '인바운드납품',
    ' ' 'seltext_S'     '인바운드납품',
    ' ' 'OUTPUTLEN'     '12',
    ' ' 'FIELDNAME'     'VBELN',
    'E' 'KEY'           ' '.


*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'EKES',
*          ' ' 'NO_OUT'        'X',
*          ' ' 'seltext_L'     '인바운드품목',
*          ' ' 'seltext_m'     '인바운드품목',
*          ' ' 'seltext_S'     '인바운드품목',
*          ' ' 'OUTPUTLEN'     '12',
*          ' ' 'FIELDNAME'     'VBELP',
*          'E' 'KEY'           ' ',
  ENDIF.
*-- [기능개선 ______]  인바운드 납품문서 필드 추가  -[e]

  PERFORM 3010_fill_field_category USING :

"최종변경인
  'S' 'TABNAME'       'IT_LIST',
  ' ' 'REF_TABNAME'   'ZTITCCP',
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
FORM 3200_key_infomation_build .

  CLEAR gs_keyinfo.

  gs_keyinfo-header01 = 'ICCNO'.
  gs_keyinfo-item01   = 'ICCNO'.

*  gs_keyinfo-header02 =  space.
*  gs_keyinfo-item02   = 'ICCIT'.

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
  gs_listheader-info = '입고 Due List'(t13).
*  SHIFT gs_listheader-info RIGHT BY 20 PLACES.
  APPEND gs_listheader TO it_listheader.

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
  ls_sort-fieldname = 'ICCNO'.
  ls_sort-tabname   = 'IT_LIST'.
  ls_sort-up        = 'X'.
* LS_SORT-GROUP     = '*'.             " Seiten- bei Gruppenwechsel
*  ls_sort-group     = 'UL'.            " Underline      -"-
  APPEND ls_sort TO it_sort.

  CLEAR ls_sort.
  ls_sort-spos      = 2.
  ls_sort-fieldname = 'BDSEQ'.
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

  DATA: ls_header TYPE ty_tab.

  CLEAR: ls_header.

  CASE r_ucomm.
    WHEN 'REFE'.
      PERFORM p9000_duelist_refresh USING  rs_selfield.

    WHEN 'ZTIT001'. " 후속기능
*> 전기처리.
      CLEAR : g_line, ls_header.
      LOOP AT it_header WHERE box EQ 'X'.
        ADD 1 TO g_line.
        MOVE-CORRESPONDING it_header TO ls_header.
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
            MOVE-CORRESPONDING it_header TO ls_header.
          ELSEIF rs_selfield-tabname EQ 'IT_LIST'.
            MOVE-CORRESPONDING it_list   TO ls_header.
          ENDIF.
        WHEN 1.
          REFRESH: it_ztisccit.
          EXPORT g_tcode      FROM sy-tcode
                 it_ztisccit  FROM it_ztisccit
                 TO DATABASE indx(zm)  ID   g_indxkey
                                       FROM gs_indx.

          SET PARAMETER ID 'ZTIICCNO' FIELD ls_header-iccno.
          CALL TRANSACTION 'ZTIT501' AND SKIP FIRST SCREEN .
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
        WHEN OTHERS.
          PERFORM  display_cc_document(ztir0000)
                                          USING ls_header-iccno
                                                ls_header-iccsq.


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
*&      Form  get_longtext_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_longtext_data .

*> Partner Text
  PERFORM  p1000_get_textid_and_text USING ztitgrk+3(10)
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

  CALL FUNCTION 'Z_TI_GET_GOODS_RECEIVE_QUERY'
    IMPORTING
      ex_factory = g_datablade.

ENDFORM.                    " build_query_factories_class
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
      i_interface_check       = ' '
      i_callback_program      = g_repid
*     i_callback_pf_status_set       = ' '
*     i_callback_user_command = ' '
      is_layout               = gs_layout
      it_fieldcat             = it_fieldcat[]
*     it_excluding            =
*     IT_SPECIAL_GROUPS       =
      it_sort                 = it_sort
*     IT_FILTER               =
*     IS_SEL_HIDE             =
*     I_SCREEN_START_COLUMN   = 0
*     I_SCREEN_START_LINE     = 0
*     I_SCREEN_END_COLUMN     = 0
*     I_SCREEN_END_LINE       = 0
      i_tabname_header        = 'IT_HEADER'
      i_tabname_item          = 'IT_LIST'
      i_structure_name_header = 'IT_HEADER'
      i_structure_name_item   = 'IT_LIST'
      is_keyinfo              = gs_keyinfo
      i_default               = c_charx
      i_save                  = c_chara
      is_variant              = ls_variant
      it_events               = it_events[]
      it_event_exit           = it_event_exit[]
      is_print                = gs_print
*     IS_REPREP_ID            =
*     I_BYPASSING_BUFFER      =
*     I_BUFFER_ACTIVE         =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER =
*     ES_EXIT_CAUSED_BY_USER  =
    TABLES
      t_outtab_header         = it_header[]
      t_outtab_item           = it_list[]
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

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
*&      Form  FI_DOCUMENT_CREATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fi_document_create .

*> 공용 대화상자(메시지 통일).
  IF ok_code EQ 'ZTIPOST'.
    CALL FUNCTION 'Z_TI_POPUP_TO_CONFIRM_MESSAGE'
      EXPORTING
        xmode  = c_char8
      IMPORTING
        answer = g_answer.

    IF g_answer EQ c_charn.
      EXIT.
    ENDIF.
  ENDIF.

  CLEAR: g_subrc.
  PERFORM  check_for_document_field USING g_mode.
  IF g_line EQ 0.
    MESSAGE s911.
  ELSE.
    EXIT.
  ENDIF.

  IF ok_code EQ 'ZTISIMUL'.
    testrun = c_true.
  ELSE.
    testrun = c_false.
  ENDIF.


  IF gf_post_div IS NOT INITIAL.  "분할입고로직 분기
    PERFORM fi_gr_post_div.
    EXIT.
  ENDIF.

  IF ztitgrk-mblnr IS INITIAL.
*> Set posting용 데이타 Move
    PERFORM  set_material_doc_data.
*> 전기용 BAPI 함수 Call
    PERFORM  call_bapi_function USING   testrun
                                        g_subrc. "자체개선 104998:입고
*> 오류가 없을 경우.
    IF g_subrc EQ 0         AND    ">Success
       testrun EQ c_false.

      IF gv_maxnr IS NOT INITIAL.
* 공조 GHP max 일련번호 update
        UPDATE zppt0808 SET curnr = gv_maxnr
             WHERE werks = '3601'
               AND class = ''.
      ENDIF.

      PERFORM p8000_save_master_data USING 'H'.

      PERFORM set_delivery_complete. "2024.01.11 ZITCS4HDEV01 추가

      MESSAGE s012(migo) WITH materialdocument.
      IF g_system_cnt EQ 0.
        PERFORM p9000_came_to_an_end.
        PERFORM p9000_program_exit.   ">Program Exit.
      ENDIF.
    ELSE.
      EXIT.
    ENDIF.
  ENDIF.

**> 오류가 없을 경우.
*  IF g_subrc        EQ 0         AND    ">Success
*     testrun        EQ c_false   AND
*     g_system_cnt   GT 0         AND
*     zTitgrK-qblnr  IS INITIAL.
************************************************************************
**> 기기 장비재 로직 변경
**2. 수출입 시스템에서의 기자재 시스템의 구분은
**   자재 그룹이 '1Y'로 시작되는 자재 중 금액을 가진 자재는 시스템,
**   금액이 없는 자재는 아이템으로 구분
**   (기존 Account Assignment Category 'P'에서 'Q'로 변경)
************************************************************************
**************************< Begin of Insert >
****************************
*    CLEAR: g_subrc.
*    PERFORM p8500_exec_mb1a_transaction.
**************************< End   of Insert >
****************************
*    IF g_subrc EQ 0.
*      PERFORM p8000_save_master_data USING 'N'.
*      MESSAGE s012(migo) WITH materialdocument.
*      PERFORM p9000_came_to_an_end.
*      PERFORM p9000_program_exit.   ">Program Exit.
*    ELSE.
*      MESSAGE e512.
*    ENDIF.
*  ENDIF.

ENDFORM.                    " FI_DOCUMENT_CREATE

*&---------------------------------------------------------------------*
*&      Form  FI_DOCUMENT_CANCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fi_document_cancel .

  PERFORM  set_cancel_document_number USING ztisscrcom.

  CLEAR: ok-code, g_subrc.

  CALL SCREEN  6010 STARTING AT 01    01.

  IF ok-code EQ 'ZTIOKAY'.
    ztitgrk-cbudat = ztisscrcom-cbudat.
*    CLEAR: g_subrc.
**> 기기장비재 출고문서 Cancel
*    IF NOT zTitgrK-qblnr IS INITIAL.
**> Set posting용 데이타 Move
*      PERFORM  set_material_doc_cancel_data USING zTitgrK-qblnr
*                                                  zTitgrK-qjahr.
**> 전기용 BAPI 함수 Call
*      PERFORM  call_cancel_bapi_function USING   g_subrc
*                                                 'O'.
*      IF g_subrc EQ 0.
*        PERFORM p8000_save_master_data USING 'C'.
*        MESSAGE s060(m7) WITH goodsmvt_headret-mat_doc.
*      ELSE.
*        EXIT.
*      ENDIF.
*    ENDIF.

*> 입고문서 Cancel
    IF NOT ztitgrk-mblnr IS INITIAL.
      CLEAR: g_subrc.
*> Set posting용 데이타 Move
      PERFORM  set_material_doc_cancel_data USING ztitgrk-mblnr
                                                  ztitgrk-mjahr.
*> 전기용 BAPI 함수 Call
      PERFORM  call_cancel_bapi_function USING   g_subrc
                                                 'I'.
*> 오류가 없을 경우.
      IF g_subrc EQ 0 .    ">Success
        PERFORM p8000_save_master_data USING 'R'.
        MESSAGE s060(m7) WITH goodsmvt_headret-mat_doc.
        PERFORM p9000_came_to_an_end.
        PERFORM p9000_program_exit.   ">Program Exit.
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE s900.
  ENDIF.

ENDFORM.                    " FI_DOCUMENT_CANCEL


*&---------------------------------------------------------------------*
*&      Form  OTHER_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM other_functions .

  CASE ok_code.
    WHEN 'ZTIMK03'.     ">공급업체.
      PERFORM display_vendor_master USING ztitgrk-lifnr
                                          ''.
    WHEN 'ZTIACDOC'.    ">회계문서.
      PERFORM account_document_display
                                       USING ztitgrk-bukrs
                                             ztitgrk-mjahr
                                             ztitgrk-mblnr.
    WHEN 'ZTIMMDOC'.    ">자재문서.
      PERFORM display_material_doc  USING ztitgrk-mblnr
                                          ztitgrk-mjahr
                                          '0000'
                                          ztitgrk-bukrs.
    WHEN 'ZTILOCIN'.    ">Locations.
      PERFORM set_batch_storage_location.
    WHEN 'ZTICHDOC'.    ">변경문서.
      g_objekt   = 'ZTIGRCHDOC'.
      g_objektid = ztitgrk+3(10).
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
*&      Form  p1101_check_input_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM p1101_check_input_value .

* Company code
  SELECT *
    INTO t001
    FROM t001 UP TO 1 ROWS WHERE bukrs IN s_bukrs.
  ENDSELECT.
  IF sy-subrc <> 0.
    PERFORM get_ftext(rddfie00) USING 'T001' 'BUKRS' sy-langu
                                CHANGING dfies g_subrc.
    SET CURSOR FIELD 'S_BUKRS-LOW'.
    MESSAGE e348(m7) WITH '회사코드'.
  ENDIF.

  SELECT SINGLE *
    FROM ztitig00
   WHERE bukrs  EQ  t001-bukrs.
  IF sy-subrc NE 0.
    MESSAGE e035 WITH t001-bukrs.
  ENDIF.

ENDFORM.                    " p1101_check_input_value
*&---------------------------------------------------------------------*
*&      Form  get_zmmt0024_table
*&---------------------------------------------------------------------*
*       <자체개선 104998>
*       Structure ZTISGRB에 EXIDV1, ICCSQ 필드 추가 함
*       -> G_TC_7000_TEMP에 영향을 미침
*----------------------------------------------------------------------*
FORM get_zmmt0024_table .

  DATA: l_textline1 TYPE string,
        l_textline2 TYPE string,
        l_titel     TYPE string,
        lv_curnr    TYPE zcurnr,
        lv_nxtnr    TYPE zcurnr.
*-{기능개선 74119 - 광섬유 PREFORM 입고시 ZDATA1 기준으로 배치생성
  DATA : BEGIN OF lt_zmmt0024 OCCURS 0,
           zdata      LIKE zmmt0024-zdata,
           licha      LIKE zmmt0024-zbatch,
           batch      LIKE zmmt0024-charg,
           grmng      LIKE zmmt0024-menge,
           meins      LIKE zmmt0024-meins,
           zdata1(30).
  DATA : END OF lt_zmmt0024.
  CLEAR : lt_zmmt0024 .
*-}기능개선 74119.

  SELECT *
    FROM dd02l UP TO 1 ROWS
   WHERE tabname  EQ g_tabname
     AND as4local EQ c_chara.
  ENDSELECT.
  IF sy-subrc EQ 0.
    SELECT COUNT( * )
      INTO g_count
      FROM (g_tabname)
     WHERE iblno EQ ztisgrit-iblno
       AND ebeln EQ ztisgrit-ebeln
       AND ebelp EQ ztisgrit-ebelp
       AND iblit EQ ztisgrit-iblit
       AND zstat EQ c_charc.

    IF g_count EQ 0 .
*******************************************************
* 2008.11.10 simcho by 오민석K
* 공조 GHP입고 시 일련번호 = 배치번호 세팅 logic
* 특성 class FT_AC_GHP : SGP 조회
* 600client
*        READ TABLE gt_xmat
*                     WITH KEY atnam = 'Z_PD_AC_059'  "'PD_AC_059'
*                              ausp1 = 'GP'           "'SGP'
*                      BINARY SEARCH
*                      INTO wa_xmat.
*******************************************************
* 20090901 simcho by 오민석K
* : 공조 GHP특성 제한 조건 해제
*   일괄번호 관리하는 자재일 경우 전체 대상으로 함
*   플랜트 한정 3601
*******************************************************
      DATA : gt_serlv LIKE mara-serlv,
             gt_sernp LIKE marc-sernp,
             gt_chk.

      CLEAR: mara, marc.

      SELECT SINGLE serlv INTO gt_serlv
        FROM mara
       WHERE matnr = ztisgrit-matnr.

      IF gt_serlv IS NOT INITIAL.

        SELECT SINGLE sernp INTO gt_sernp
          FROM marc
         WHERE matnr = ztisgrit-matnr
           AND werks = ztisgrit-werks.

        IF gt_sernp IS NOT INITIAL AND ztisgrit-werks = '3601'.
          gt_chk = 'X'. "공조플랜트 AND 일련번호와 배치번호 동기화 조건
        ENDIF.

      ENDIF.

*      IF ztisgrit-werks+0(1) = '3'.
*
*        DATA: gt_xmat         TYPE TABLE OF zeds461,
*              wa_xmat         TYPE zeds461.


*        CALL FUNCTION 'Z_ED_GET_MATNR_CHAR_VALUE'
*          EXPORTING
*            i_matnr = ztisgrit-matnr
*            i_klart = '001'
*            i_werks = ztisgrit-werks
*          TABLES
*            it_s461 = gt_xmat.
*
*** 600 client용
*        READ TABLE gt_xmat
*                     WITH KEY atnam = 'Z_PD_AC_059'
*                              ausp1 = 'GP'
*                      BINARY SEARCH
*                      INTO wa_xmat.
*
*** 100 client용
**        READ TABLE gt_xmat
**                     WITH KEY atnam = 'PD_AC_059'
**                              ausp1 = 'GP'
**                      BINARY SEARCH
**                      INTO wa_xmat.

*    ENDIF.
*******************************************************
*      IF ztisgrit-matnr EQ '000000000030103801' OR
*         ztisgrit-matnr EQ '000000000030103802' OR
*         ztisgrit-matnr EQ '000000000030103803' OR
*         ztisgrit-matnr EQ '000000000030103804' OR
*         ztisgrit-matnr EQ '000000000030103805' OR
*         ztisgrit-matnr EQ '000000000030103806' OR
*         ztisgrit-matnr EQ '000000000030100191'.
*******************************************************
*      IF wa_xmat IS NOT INITIAL.
      IF gt_chk = 'X'. "공조플랜트 AND 일련번호와 배치번호 동기화 조건
        DESCRIBE TABLE g_tc_7000_temp LINES g_line.
        IF g_line GT 0.
          l_textline1 =
        'Batch/일련번호 데이타가 존재합니다.'.
*        '공조 GHP상품 Upload된 Batch/일련번호 데이타가 존재합니다.'.
          l_textline2 =
          '기존 Batch/일련번호 데이타를 재갱신 하시겠습니까?'.
          l_titel     = '일련번호/배치번사용 확인'.
        ELSE.
          l_textline1 =
          '공조 일괄번호관리 자재가 존재합니다.'.
*          '공조 GHP상품이 존재합니다.'.
          l_textline2 = '일련번호/배치번호를 일괄 생성하시겠습니까?'.
          l_titel     = '일련번호/배치번사용 확인'.
        ENDIF.

*        l_textline1 =
*        '공조 GHP상품이 존재합니다.'.
*        l_textline2 = '일련번호/배치번호를 일괄 생성하시겠습니까?'.
*        l_titel     = '일련번호/배치번사용 확인'.

        CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
          EXPORTING
            textline1      = l_textline1
            textline2      = l_textline2
            titel          = l_titel
            cancel_display = space
          IMPORTING
            answer         = g_answer.

        CHECK g_answer EQ c_charj.

* 배치번호/일련번호 select
        SELECT SINGLE curnr INTO lv_curnr
          FROM zppt0808
         WHERE werks = '3601'
           AND class = ''.

*******************************************
*        DATA: l_message TYPE bapi_msg.
*
*        CALL FUNCTION 'Z_PP_CREATE_MC_NR'
*          EXPORTING
*            i_werks   = ztisgrit-werks  "zpps628-werks
*            i_matnr   = ztisgrit-matnr  "zpps628-matnr
*          IMPORTING
*            e_sernr   = lv_curnr     "zpps628-sernr
*            e_message = l_message.
*
*        IF lv_curnr IS INITIAL.
*          MESSAGE e000 WITH l_message.
*        ENDIF.
*******************************************

        CLEAR: lv_nxtnr.

* 수량만큼 배치분할
        REFRESH  g_tc_7000_temp.
        CLEAR  g_tc_7000_temp.

        IF gv_maxnr IS INITIAL.
          lv_nxtnr = lv_curnr .
        ELSE.
          lv_nxtnr = gv_maxnr .
        ENDIF.

        DO ztisgrit-grmng TIMES.

          lv_nxtnr = lv_nxtnr + 1.

          g_tc_7000_temp-zdata = 'GHP'.
          g_tc_7000_temp-licha = lv_nxtnr.
          g_tc_7000_temp-batch = lv_nxtnr.
          g_tc_7000_temp-grmng = 1.
          g_tc_7000_temp-meins = ztisgrit-meins.
          APPEND g_tc_7000_temp.

        ENDDO.

*        gv_maxnr = lv_nxtnr.

        CLEAR: g_ibcit.
        LOOP AT g_tc_7000_temp INTO g_tc_7000_wa.
          ADD 1 TO g_ibcit.
          PERFORM set_sub_batch_record USING g_ibcit
                                             g_subrc.
          ADD g_tc_7000_wa-grmng TO ztisgrit-menge.
          MODIFY g_tc_7000_temp FROM g_tc_7000_wa.
        ENDLOOP.

        IF sy-subrc EQ 0.
          ztisgrit-ifchk = c_true.
        ENDIF.

        SORT g_tc_7000_temp BY ibcit.

      ELSE. "공조플랜트 AND 일련번호와 배치번호 동기화 조건이 아님
*-> 자체개선 104998
*       G_TC_7000_TEMP 필드 2개 추가: EXIDV1, ICCSQ
        IF sy-sysid = 'R3T'.
          PERFORM get_barcode_scan_data USING ztisgrit .
        ELSE.
          CASE ztisgrit-werks.
            WHEN '3204'. "커넥터일 경우에 바코드 입력기능 추가
              PERFORM get_barcode_scan_data USING ztisgrit .
            WHEN OTHERS. "그외일 경우 서브루틴 종료
              EXIT.
          ENDCASE.
        ENDIF.
*<- 자체개선 104998
      ENDIF.
    ELSE.
      DESCRIBE TABLE g_tc_7000_temp LINES g_line.
      IF g_line GT 0.
        l_textline1 =
        '광섬유 원자재의 Upload된 Batch 데이타가 존재합니다.'.
        l_textline2 =
        '기존데이타를 Upload Batch 데이타로 재갱신 하시겠습니까?'.
        l_titel     = '광섬유 원자재 Batch 재갱신 확인'.
      ELSE.
        l_textline1 =
        '광섬유 원자재의 Upload된 Batch 데이타가 존재합니다.'.
        l_textline2 = 'Upload Batch 데이타를 사용 하시겠습니까?'.
        l_titel     = '광섬유 원자재 Batch 사용 확인'.
      ENDIF.
*    ENDIF.

      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
        EXPORTING
          textline1      = l_textline1
          textline2      = l_textline2
          titel          = l_titel
          cancel_display = space
        IMPORTING
          answer         = g_answer.
*    ENDIF.

      CHECK g_answer EQ c_charj.

      SELECT zdata
             zbatch AS licha
             charg  AS batch
             menge  AS grmng
             meins
        INTO CORRESPONDING FIELDS OF TABLE g_tc_7000_temp
        FROM (g_tabname)
       WHERE iblno EQ ztisgrit-iblno
         AND ebeln EQ ztisgrit-ebeln
         AND ebelp EQ ztisgrit-ebelp
         AND iblit EQ ztisgrit-iblit
         AND zstat EQ c_charc.

*-{기능개선 74119 - 광섬유 PREFORM 입고시 ZDATA1 기준으로 배치생성
      SELECT zdata
             zbatch AS licha
             charg  AS batch
             menge  AS grmng
             meins
             zdata1
        INTO CORRESPONDING FIELDS OF TABLE lt_zmmt0024
        FROM zmmt0024
       WHERE iblno EQ ztisgrit-iblno
         AND ebeln EQ ztisgrit-ebeln
         AND ebelp EQ ztisgrit-ebelp
         AND iblit EQ ztisgrit-iblit
         AND zdata EQ 'PREFORM'
         AND zstat EQ c_charc.

      IF sy-subrc = 0.
        SORT lt_zmmt0024 BY zdata1.
        CLEAR : g_tc_7000_temp, g_tc_7000_temp[].
        LOOP AT lt_zmmt0024.
          MOVE-CORRESPONDING lt_zmmt0024 TO g_tc_7000_temp.
          APPEND g_tc_7000_temp.
        ENDLOOP.
      ENDIF.
*-}기능개선 74119.

      CLEAR: g_ibcit.
      LOOP AT g_tc_7000_temp INTO g_tc_7000_wa.
        ADD 1 TO g_ibcit.
        PERFORM set_sub_batch_record USING g_ibcit
                                           g_subrc.
        ADD g_tc_7000_wa-grmng TO ztisgrit-menge.
        MODIFY g_tc_7000_temp FROM g_tc_7000_wa.
      ENDLOOP.

      IF sy-subrc EQ 0.
        ztisgrit-ifchk = c_true.
      ENDIF.

      SORT g_tc_7000_temp BY ibcit.
    ENDIF.
  ENDIF.
ENDFORM.                    " get_zmmt0024_table
*&---------------------------------------------------------------------*
*&      Form  CHECK_SUB_BATCH_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_sub_batch_data USING p_msgty.

  DATA: l_if_null TYPE REF TO if_message_obj_mm.

* Message preparations
  PERFORM  set_message_preparations.

******************************************************
* 공조 GHP
******************************************************
  CLEAR : g_tc_7000_temp2.
  REFRESH : g_tc_7000_temp2.

  g_tc_7000_temp2[] = g_tc_7000_temp[].

  DELETE g_tc_7000_temp2 WHERE werks <> '3601'.

*  SORT g_tc_7000_temp2 BY licha DESCENDING.
  SORT g_tc_7000_temp2 BY batch DESCENDING.

  READ TABLE g_tc_7000_temp2 INDEX 1.

* 2009.02.11 zppXXXX last number update오류보정
  IF sy-subrc = 0.
    LOOP AT g_tc_7000_temp2.

      IF g_tc_7000_temp2-werks+0(1) = '3'.

        DATA: gt_xmat TYPE TABLE OF zeds461,
              wa_xmat TYPE zeds461.

        CALL FUNCTION 'Z_ED_GET_MATNR_CHAR_VALUE'
          EXPORTING
            i_matnr = ztisgrit-matnr
            i_klart = '001'
            i_werks = ztisgrit-werks
          TABLES
            it_s461 = gt_xmat.

* 600 client용
        READ TABLE gt_xmat
                     WITH KEY atnam = 'Z_PD_AC_059'
                              ausp1 = 'GP'
                      BINARY SEARCH
                      INTO wa_xmat.
** 100 client용
*        READ TABLE gt_xmat
*                     WITH KEY atnam = 'PD_AC_059'
*                              ausp1 = 'GP'
*                      BINARY SEARCH
*                      INTO wa_xmat.
      ENDIF.

      IF wa_xmat IS NOT INITIAL.
*******************************************************
* 20090901 simcho by 오민석K
*******************************************************
*        gv_maxnr =  g_tc_7000_temp2-licha.
        gv_maxnr =  g_tc_7000_temp2-batch.
*******************************************************
      ENDIF.

*  SORT g_tc_7000_temp BY licha DESCENDING.
*
*  READ TABLE g_tc_7000_temp INDEX 1.
*
** 2009.02.11 zppXXXX laste number update오류보정
*  IF g_tc_7000_temp-werks = '3601' .
*    gv_maxnr =  g_tc_7000_temp-licha.
*  ENDIF.
      EXIT.
    ENDLOOP.
  ENDIF.
******************************************************
  SORT g_tc_7000_temp .
*
  LOOP AT g_tc_7000_temp INTO g_tc_7000_wa.
    g_tabix = sy-tabix.
*> 입고수량..
    IF g_tc_7000_wa-grmng IS INITIAL.
      MESSAGE s513 WITH g_tabix 'G/R Qty.'.
      PERFORM set_return_message_fill USING c_error.
    ENDIF.
*> 저장위치.
    IF ztisgrit-knttp EQ c_charp.
      CLEAR: g_tc_7000_wa-lgort .
      MODIFY g_tc_7000_itab FROM g_tc_7000_wa INDEX g_tabix.
    ELSE.
      IF g_tc_7000_wa-lgort IS INITIAL.
        MESSAGE s513 WITH g_tabix '저장위치'.
        PERFORM set_return_message_fill USING c_error.
      ENDIF.
    ENDIF.
    IF NOT g_tc_7000_wa-mhdhb IS INITIAL AND
       g_tc_7000_wa-hsdat IS INITIAL.
      MESSAGE s513 WITH g_tabix '생산일'.
      PERFORM set_return_message_fill USING c_error.
    ENDIF.
  ENDLOOP.
  IF sy-subrc NE 0.
    MESSAGE s518.
    PERFORM set_return_message_fill USING c_error.
  ENDIF.

  IF ztisgrit-erfmg GT ztisgrit-grmngl.
    CLEAR: g_menget.
    WRITE ztisgrit-grmngl TO g_menget(15) UNIT ztisgrit-meins.
    CONCATENATE g_menget ztisgrit-meins INTO g_menget.
    MESSAGE s860 WITH g_menget.
    PERFORM set_return_message_fill USING c_error.
  ENDIF.

*> 오류정보가 존재시 메시지 상자 POPUP.
  g_line = g_message_handler->get_severity_bo(
                          im_business_obj          = l_if_null
                          im_include_child_objects = c_true ).

  IF g_line GT 0.
    CALL METHOD g_message_handler->show(
        im_popup  = c_true
        im_amodal = c_false ).
  ENDIF.

ENDFORM.                    " CHECK_SUB_BATCH_DATA
*&---------------------------------------------------------------------*
*&      Form  set_sub_batch_record
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_sub_batch_record USING p_ibcit
                                p_subrc.

  "가온전선 Fiber자재 입고 자재번호=배치번호 {
  DATA: lv_matkl     LIKE mara-matkl,
        lv_cnt_0830  TYPE i,
        lv_matnr_ext LIKE ztisgrit-matnr.
  " }

  CLEAR: p_subrc.
  IF g_tc_7000_wa-meins NE ztisgrit-meins.
    MESSAGE i516 WITH ztisgrit-ebeln ztisgrit-ebelp
                      ztisgrit-meins g_tc_7000_wa-meins.
    p_subrc = 4.
    EXIT.
  ENDIF.

  ADD g_tc_7000_wa-grmng TO ztisgrit-erfmg.

  g_tc_7000_wa-iccit = ztisgrit-iccit.
  g_tc_7000_wa-ibcit = p_ibcit.
  g_tc_7000_wa-iblno = ztisgrit-iblno.
  g_tc_7000_wa-iblit = ztisgrit-iblit.
  g_tc_7000_wa-iccno = ztisgrit-iccno.
  g_tc_7000_wa-bdseq = ztisgrit-bdseq.
  g_tc_7000_wa-ibdsq = ztisgrit-ibdsq.
**************************************************
* 20090904 simcho by 오민석K
* g_tc_7000_wa-bwart = ztisgrit-bwart.
**************************************************
  IF ztisgrit-bwart IS INITIAL.
    g_tc_7000_wa-bwart = ztitgrk-bwart.
  ELSE.
    g_tc_7000_wa-bwart = ztisgrit-bwart.
  ENDIF.
**************************************************
  g_tc_7000_wa-werks = ztisgrit-werks.

  IF g_tc_7000_wa-lgort IS INITIAL.
    g_tc_7000_wa-lgort = ztisgrit-lgort.
  ENDIF.

  g_tc_7000_wa-ebeln = ztisgrit-ebeln.
  g_tc_7000_wa-ebelp = ztisgrit-ebelp.
  g_tc_7000_wa-reqno = ztisgrit-reqno.
  g_tc_7000_wa-reqit = ztisgrit-reqit.
  g_tc_7000_wa-rsnum = ztisgrit-rsnum.
  g_tc_7000_wa-rspos = ztisgrit-rspos.
  g_tc_7000_wa-rsart = ztisgrit-rsart.
  g_tc_7000_wa-matnr = ztisgrit-matnr.
*  g_tc_7000_wa-meins = ztisgrit-meins.
  g_tc_7000_wa-txz01 = ztisgrit-txz01.

  "{ 가온전선 Fiber자재 입고 자재번호=배치번호
  CLEAR: lv_matkl, lv_cnt_0830, lv_matnr_ext.

  SELECT SINGLE matkl INTO lv_matkl
    FROM mara
   WHERE matnr = g_tc_7000_wa-matnr.

  IF sy-subrc = 0.
    SELECT COUNT(*) INTO lv_cnt_0830
      FROM zgtppt1010
     WHERE module_kind = 'MM'
       AND codegrp     = '0830'
       AND fld_01      = g_tc_7000_wa-werks
       AND fld_02      = lv_matkl.

    IF lv_cnt_0830 > 0.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          input  = g_tc_7000_wa-matnr
        IMPORTING
          output = lv_matnr_ext.

      g_tc_7000_wa-batch = lv_matnr_ext.
    ENDIF.
  ENDIF.
  "} 가온전선 배치 로직

  IF g_tc_7000_wa-batch IS INITIAL.
    g_tc_7000_wa-batch = ztisgrit-batch.
  ENDIF.

  IF g_tc_7000_wa-licha IS INITIAL.
    g_tc_7000_wa-licha = ztisgrit-licha.
  ENDIF.

  IF g_tc_7000_wa-sgtxt IS INITIAL.
    g_tc_7000_wa-sgtxt = ztisgrit-sgtxt.
  ENDIF.

  IF g_tc_7000_wa-vfdat IS INITIAL.
    g_tc_7000_wa-vfdat = ztisgrit-vfdat.
  ENDIF.
  IF g_tc_7000_wa-hsdat IS INITIAL.
    g_tc_7000_wa-hsdat = ztisgrit-hsdat.
  ENDIF.

  g_tc_7000_wa-vbeln = ztisgrit-vbeln.
  g_tc_7000_wa-posnr = ztisgrit-posnr.
  g_tc_7000_wa-stawn = ztisgrit-stawn.

  IF g_tc_7000_wa-ablad IS INITIAL.
    g_tc_7000_wa-ablad = ztisgrit-ablad.
  ENDIF.
  IF g_tc_7000_wa-insmk IS INITIAL.
    g_tc_7000_wa-insmk = ztisgrit-insmk.
  ENDIF.

  g_tc_7000_wa-name1 = ztisgrit-name1.
  IF g_tc_7000_wa-lgobe IS INITIAL.
    g_tc_7000_wa-lgobe = ztisgrit-lgobe.
  ENDIF.
  g_tc_7000_wa-mhdrz = ztisgrit-mhdrz.
  g_tc_7000_wa-mhdhb = ztisgrit-mhdhb.
  g_tc_7000_wa-maxlz = ztisgrit-maxlz.
  g_tc_7000_wa-xchpf = ztisgrit-xchpf.

  IF NOT g_tc_7000_wa-hsdat IS INITIAL.
    g_tc_7000_wa-vfdat = g_tc_7000_wa-hsdat +
                         g_tc_7000_wa-mhdhb.
  ENDIF.

ENDFORM.                    " set_sub_batch_record
*&---------------------------------------------------------------------*
*&      Form  set_general_gr_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_general_gr_data .

  DATA: l_rkpf        LIKE   rkpf.

  CLEAR: ekpo.
  IF NOT g_tc_2130_wa-ebeln IS INITIAL.
    SELECT SINGLE * FROM ekpo
           WHERE ebeln EQ g_tc_2130_wa-ebeln
           AND   ebelp EQ g_tc_2130_wa-ebelp.
  ELSEIF NOT g_tc_2130_wa-rsnum IS INITIAL.

  ENDIF.
*> clear item structure
  CLEAR : goodsmvt_item.

  ADD    1            TO  g_line.

  MOVE:g_tc_2130_wa-matnr TO goodsmvt_item-material,
       g_tc_2130_wa-werks TO goodsmvt_item-plant,
       g_tc_2130_wa-lgort TO goodsmvt_item-stge_loc,
       g_tc_2130_wa-batch TO goodsmvt_item-batch,
       g_tc_2130_wa-bwart TO goodsmvt_item-move_type,
       space              TO goodsmvt_item-stck_type,
       space              TO goodsmvt_item-spec_stock,
       ztitgrk-lifnr      TO goodsmvt_item-vendor,
       space              TO goodsmvt_item-customer,
       space              TO goodsmvt_item-sales_ord,
       space              TO goodsmvt_item-s_ord_item,
       space              TO goodsmvt_item-sched_line,
       space              TO goodsmvt_item-val_type,
       g_tc_2130_wa-grmng TO goodsmvt_item-entry_qnt, " 단위수량.
       g_tc_2130_wa-meins TO goodsmvt_item-entry_uom, " 입력단위.
*         EKPO-BPRME         TO GOODSMVT_ITEM-ENTRY_UOM_ISO,"ISO코드.
*         EKPO-PEINH         TO GOODSMVT_ITEM-PO_PR_QNT,   "가격단위.
       ekpo-bprme         TO goodsmvt_item-orderpr_un,   " 가격단위.
*         EKPO-BPRME         TO GOODSMVT_ITEM-ORDERPR_UN_ISO,"ISO 코?
       ekpo-ebeln         TO goodsmvt_item-po_number,     " P/O번호.
       ekpo-ebelp         TO goodsmvt_item-po_item,       " 품목번호.
       space              TO goodsmvt_item-shipping,      " 출하지시.
       space              TO goodsmvt_item-comp_ship,  "출하지시준수.
       g_no_more_gr       TO goodsmvt_item-no_more_gr, " 납품완표.
       g_tc_2130_wa-sgtxt TO goodsmvt_item-item_text,  "품목텍스트.
       sy-uname           TO goodsmvt_item-gr_rcpt,    "자재수령인.
       g_tc_2130_wa-ablad TO goodsmvt_item-unload_pt,  "하역지점.
       space              TO goodsmvt_item-costcenter, "코스트센터.
       space              TO goodsmvt_item-orderid,    "오더번호.
       space              TO goodsmvt_item-order_itno, "오더품목번호.
       space              TO goodsmvt_item-calc_motive,"회계지시자.
       space              TO goodsmvt_item-asset_no,   "주요자산번호.
       space              TO goodsmvt_item-sub_number, "자산보조번호.
       g_tc_2130_wa-rsnum TO goodsmvt_item-reserv_no,  "예약/종속NO
       g_tc_2130_wa-rspos TO goodsmvt_item-res_item,   "예약/종속ITEM
       g_tc_2130_wa-rsart TO goodsmvt_item-res_type,   "레코드유형.
       space              TO goodsmvt_item-withdrawn,  "예약에 대해.
*       g_tc_2130_wa-matnr TO goodsmvt_item-move_mat,   "입고자재.
*       g_tc_2130_wa-werks TO goodsmvt_item-move_plant, "입고플랜트.
*       g_tc_2130_wa-lgort TO goodsmvt_item-move_stloc, "입고SLOG
*       g_tc_2130_wa-batch TO goodsmvt_item-move_batch, "입고 batch
       space              TO goodsmvt_item-move_val_type,"batch 이동.
       g_mvt_ind          TO goodsmvt_item-mvt_ind,    " 이동지시자.
       ztitgrk-grund     TO goodsmvt_item-move_reas,  " 이동사유.
       space              TO goodsmvt_item-rl_est_key, "
       space              TO goodsmvt_item-ref_date,   "정산참조.
       space              TO goodsmvt_item-cost_obj,   "원가집적.
       space              TO goodsmvt_item-profit_segm_no, " 수익.
       space              TO goodsmvt_item-profit_ctr,  " 손익센터.
       space              TO goodsmvt_item-wbs_elem,    "(WBS 요소)
       space              TO goodsmvt_item-network,     " 계정지정.
       space              TO goodsmvt_item-activity,    " 작업번호.
       space              TO goodsmvt_item-part_acct,   "거래처.
*         space              TO GOODSMVT_ITEM-AMOUNT_LC,   "현지통지.
*         space              TO GOODSMVT_ITEM-AMOUNT_SV,   "현지통지.
       space              TO goodsmvt_item-ref_doc_yr,  "Ref회계연도.
       space              TO goodsmvt_item-ref_doc,     "Ref문서번호.
       space              TO goodsmvt_item-ref_doc_it,  "Ref문서품호.
       g_tc_2130_wa-vfdat TO goodsmvt_item-expirydate,  "수명만기일.
       g_tc_2130_wa-hsdat TO goodsmvt_item-prod_date,   "Batch생산일.
       space              TO goodsmvt_item-fund,        "펀드.
       space              TO goodsmvt_item-funds_ctr,   "예산관리센?
       space              TO goodsmvt_item-cmmt_item,   "약정항?
       space              TO goodsmvt_item-val_sales_ord,"판매오더?
       space              TO goodsmvt_item-val_s_ord_item,"오더품?
       space              TO goodsmvt_item-val_wbs_elem,  "(WBS 요소)
       space              TO goodsmvt_item-gl_account,   "G/L계정번?
       space              TO goodsmvt_item-ind_propose_quanx, "제?
       space              TO goodsmvt_item-xstob,      "역분개이?
*         g_tc_2130_wa-stawn TO goodsmvt_item-ean_upc,    "국제물품번?
       g_tc_2130_wa-vbeln TO goodsmvt_item-deliv_numb_to_search,
                                                      " 납품번호.
       g_tc_2130_wa-posnr TO goodsmvt_item-deliv_item_to_search,
                                                      " 납품품목.
       space  TO  goodsmvt_item-serialno_auto_numberassignment,
       g_tc_2130_wa-licha TO goodsmvt_item-vendrbatch, "공급업체BATCH
       space              TO goodsmvt_item-stge_type,     " 저장유?
       space              TO goodsmvt_item-stge_bin,      " 저장 bin
       space              TO goodsmvt_item-su_pl_stck_1,  "저장단위?
*         W_MENGE            TO GOODSMVT_ITEM-ST_UN_QTYY_1,  "단위별수?
*         EKPO-BPRME         TO GOODSMVT_ITEM-ST_UN_QTYY_1_ISO,  "ISO
       space              TO goodsmvt_item-unittype_1, " 저장단위유?
       space              TO goodsmvt_item-su_pl_stck_2, "저장단위?
       space              TO goodsmvt_item-st_un_qtyy_2, "단위별수?
       space              TO goodsmvt_item-st_un_qtyy_2_iso, "ISO
       space              TO goodsmvt_item-unittype_2,  "저장단위유?
       space              TO goodsmvt_item-stge_type_pc,"이전전?
       space              TO goodsmvt_item-stge_bin_pc, "저장 bin
       space              TO goodsmvt_item-no_pst_chgnt,"변경통?
       space              TO goodsmvt_item-gr_number,   " 입고번?
       space              TO goodsmvt_item-stge_type_st," 재고이전?
       space              TO goodsmvt_item-stge_bin_st, " 재고이전?
       space              TO goodsmvt_item-matdoc_tr_cancel,
                            " 취소예정인 이전요청(TR) 자재문서번?
       space              TO goodsmvt_item-matitem_tr_cancel,
                            " 취소예정인 이전요청(TR) 자재문서번?
       space              TO goodsmvt_item-matitem_tr_cancel,
                            " 취소예정인 이전요청(TR) 자재문서품?
       space              TO goodsmvt_item-matyear_tr_cancel,
                            " 취소될 이전요청의 자재문서연?
       space              TO goodsmvt_item-no_transfer_req,
                            " 지시자: 생성된 이전요청(TR)없?
       space              TO goodsmvt_item-co_busproc,
                            " 비지니스프로세?
       space              TO goodsmvt_item-acttype,     "액티비티유?
       ztitgrk-lifnr     TO goodsmvt_item-suppl_vend,  " 공급업?
       space              TO goodsmvt_item-material_external,
                  " 필드 MATERIAL에 대한 긴 자재번호 (차후개발)
       space              TO goodsmvt_item-material_guid,
                  " 필드 MATERIAL에 대한 외부 GUID (차후개발)
       space              TO goodsmvt_item-material_version,
                  " 필드 MATERIAL에 대한 버젼번호 (차후개발)
       space              TO goodsmvt_item-move_mat_external,
                  " 필드 MOVE_에 대한 긴 자재번호 (차후개발)
       space              TO goodsmvt_item-move_mat_guid,
                  " 필드 MOVE_MAT에 대한 외부 GUID (차후개발)
       space              TO goodsmvt_item-move_mat_version.
  " 필드 MOVE_MAT에 대한 버젼번호 (차후개발)
*         SPACE              TO GOODSMVT_ITEM-FUNC_AREA,
*                      " Functional 영역.
*         SPACE              TO GOODSMVT_ITEM-TR_PART_BA,
*                     " 관계사 사업영역.
*         SPACE              TO GOODSMVT_ITEM-PAR_COMPCO,
*                     " 반제 회사코드.
*         g_tc_2130_wa-vbeln TO goodsmvt_item-deliv_numb,   " 납품.
*         g_tc_2130_wa-posnr TO goodsmvt_item-deliv_item.   " 납품품목.
*         SPACE              TO GOODSMVT_ITEM-NB_SLIPS,  " GR/GI전표?
*         SPACE              TO GOODSMVT_ITEM-NB_SLIPSX,
*                    " 관련사용자 데이타필드의 갱신정?
*
*         SPACE              TO GOODSMVT_ITEM-GR_RCPTX,
*                    " 관련사용 데이타필드의 갱신정?
*         SPACE              TO GOODSMVT_ITEM-UNLOAD_PTX.
*                    " 관련사용자 데이타필드의 갱신정?

*--> [SRM2503-02058] 이동유형 추가 체크
  IF g_tc_2130_wa-bwart IS INITIAL.
    goodsmvt_item-move_type = ztitgrk-bwart.
  ENDIF.
*<-- [SRM2503-02058] 이동유형 추가 체크

*>예약을 참조할 경우.
  IF ztitgrk-igrty EQ c_charr.
    MOVE c_charq TO goodsmvt_item-spec_stock.
    CLEAR: l_rkpf.
    SELECT SINGLE *
      INTO l_rkpf
      FROM rkpf
     WHERE rsnum  EQ  g_tc_2130_wa-rsnum.

    MOVE: l_rkpf-wempf      TO goodsmvt_item-gr_rcpt.     "자재수령인.

    CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
      EXPORTING
        input  = l_rkpf-ps_psp_pnr
      IMPORTING
        output = goodsmvt_item-wbs_elem.
*
*            l_rkpf-ps_psp_pnr TO goodsmvt_item-WBS_ELEM.    "(WBS 요소)
    MOVE: goodsmvt_item-wbs_elem TO goodsmvt_item-val_wbs_elem.
*    ELSE.
************************< Begin of Insert >*****************************
*      IF g_tc_2130_wa-knttp    EQ c_charq AND
*         g_tc_2130_wa-matnr    NE space   AND
*         g_tc_2130_wa-repos    EQ c_true  AND
*         g_tc_2130_wa-matkl(2) EQ '1Y'.
*        MOVE c_charq TO goodsmvt_item-spec_stock.
*      ENDIF.
************************< End   of Insert >*****************************
  ENDIF.

*>> ITEM APPEND
  APPEND goodsmvt_item.

  goodsmvt_serialnumber-matdoc_itm = g_line.
  goodsmvt_serialnumber-serialno   = g_line.
  APPEND   goodsmvt_serialnumber.

ENDFORM.                    " set_general_gr_data
*&---------------------------------------------------------------------*
*&      Form  set_sub_batch_gr_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_sub_batch_gr_data .

  DATA: l_rkpf        LIKE   rkpf.

  CLEAR: ekpo.
  IF NOT g_tc_7000_wa-ebeln IS INITIAL.
    SELECT SINGLE * FROM ekpo
           WHERE ebeln EQ g_tc_7000_wa-ebeln
           AND   ebelp EQ g_tc_7000_wa-ebelp.
  ELSEIF NOT g_tc_7000_wa-rsnum IS INITIAL.

  ENDIF.
*> clear item structure
  CLEAR : goodsmvt_item.

  ADD    1            TO  g_line.

  MOVE:g_tc_7000_wa-matnr TO goodsmvt_item-material,
       g_tc_7000_wa-werks TO goodsmvt_item-plant,
       g_tc_7000_wa-lgort TO goodsmvt_item-stge_loc,
       g_tc_7000_wa-batch TO goodsmvt_item-batch,
       g_tc_7000_wa-bwart TO goodsmvt_item-move_type,
       space              TO goodsmvt_item-stck_type,
       space              TO goodsmvt_item-spec_stock,
       ztitgrk-lifnr      TO goodsmvt_item-vendor,
       space              TO goodsmvt_item-customer,
       space              TO goodsmvt_item-sales_ord,
       space              TO goodsmvt_item-s_ord_item,
       space              TO goodsmvt_item-sched_line,
       space              TO goodsmvt_item-val_type,
       g_tc_7000_wa-grmng TO goodsmvt_item-entry_qnt, " 단위수량.
       g_tc_7000_wa-meins TO goodsmvt_item-entry_uom, " 입력단위.
*         EKPO-BPRME         TO GOODSMVT_ITEM-ENTRY_UOM_ISO,"ISO코드.
*         EKPO-PEINH         TO GOODSMVT_ITEM-PO_PR_QNT,   "가격단위.
       ekpo-bprme         TO goodsmvt_item-orderpr_un,   " 가격단위.
*         EKPO-BPRME         TO GOODSMVT_ITEM-ORDERPR_UN_ISO,"ISO 코?
       ekpo-ebeln         TO goodsmvt_item-po_number,     " P/O번호.
       ekpo-ebelp         TO goodsmvt_item-po_item,       " 품목번호.
       space              TO goodsmvt_item-shipping,      " 출하지시.
       space              TO goodsmvt_item-comp_ship,  "출하지시준수.
       g_no_more_gr       TO goodsmvt_item-no_more_gr, " 납품완표.
       g_tc_7000_wa-sgtxt TO goodsmvt_item-item_text,  "품목텍스트.
       sy-uname           TO goodsmvt_item-gr_rcpt,    "자재수령인.
       g_tc_7000_wa-ablad TO goodsmvt_item-unload_pt,  "하역지점.
       space              TO goodsmvt_item-costcenter, "코스트센터.
       space              TO goodsmvt_item-orderid,    "오더번호.
       space              TO goodsmvt_item-order_itno, "오더품목번호.
       space              TO goodsmvt_item-calc_motive,"회계지시자.
       space              TO goodsmvt_item-asset_no,   "주요자산번호.
       space              TO goodsmvt_item-sub_number, "자산보조번호.
       g_tc_7000_wa-rsnum TO goodsmvt_item-reserv_no,  "예약/종속NO
       g_tc_7000_wa-rspos TO goodsmvt_item-res_item,   "예약/종속ITEM
       g_tc_7000_wa-rsart TO goodsmvt_item-res_type,   "레코드유형.
       space              TO goodsmvt_item-withdrawn,  "예약에 대해.
*       g_tc_7000_wa-matnr TO goodsmvt_item-move_mat,   "입고자재.
*       g_tc_7000_wa-werks TO goodsmvt_item-move_plant, "입고플랜트.
*       g_tc_7000_wa-lgort TO goodsmvt_item-move_stloc, "입고SLOG
*       g_tc_7000_wa-batch TO goodsmvt_item-move_batch, "입고 batch
       space              TO goodsmvt_item-move_val_type,"batch 이동.
       g_mvt_ind          TO goodsmvt_item-mvt_ind,    " 이동지시자.
       ztitgrk-grund     TO goodsmvt_item-move_reas,  " 이동사유.
       space              TO goodsmvt_item-rl_est_key, "
       space              TO goodsmvt_item-ref_date,   "정산참조.
       space              TO goodsmvt_item-cost_obj,   "원가집적.
       space              TO goodsmvt_item-profit_segm_no, " 수익.
       space              TO goodsmvt_item-profit_ctr,  " 손익센터.
       space              TO goodsmvt_item-wbs_elem,    "(WBS 요소)
       space              TO goodsmvt_item-network,     " 계정지정.
       space              TO goodsmvt_item-activity,    " 작업번호.
       space              TO goodsmvt_item-part_acct,   "거래처.
*         space              TO GOODSMVT_ITEM-AMOUNT_LC,   "현지통지.
*         space              TO GOODSMVT_ITEM-AMOUNT_SV,   "현지통지.
       space              TO goodsmvt_item-ref_doc_yr,  "Ref회계연도.
       space              TO goodsmvt_item-ref_doc,     "Ref문서번호.
       space              TO goodsmvt_item-ref_doc_it,  "Ref문서품호.
       g_tc_7000_wa-vfdat TO goodsmvt_item-expirydate,  "수명만기일.
       g_tc_7000_wa-hsdat TO goodsmvt_item-prod_date,   "Batch생산일.
       space              TO goodsmvt_item-fund,        "펀드.
       space              TO goodsmvt_item-funds_ctr,   "예산관리센?
       space              TO goodsmvt_item-cmmt_item,   "약정항?
       space              TO goodsmvt_item-val_sales_ord,"판매오더?
       space              TO goodsmvt_item-val_s_ord_item,"오더품?
       space              TO goodsmvt_item-val_wbs_elem,  "(WBS 요소)
       space              TO goodsmvt_item-gl_account,   "G/L계정번?
       space              TO goodsmvt_item-ind_propose_quanx, "제?
       space              TO goodsmvt_item-xstob,      "역분개이?
*         g_tc_7000_wa-stawn TO goodsmvt_item-ean_upc,    "국제물품번?
       g_tc_7000_wa-vbeln TO goodsmvt_item-deliv_numb_to_search,
                                                      " 납품번호.
       g_tc_7000_wa-posnr TO goodsmvt_item-deliv_item_to_search,
                                                      " 납품품목.
       space  TO  goodsmvt_item-serialno_auto_numberassignment,
       g_tc_7000_wa-licha TO goodsmvt_item-vendrbatch, "공급업체BATCH
       space              TO goodsmvt_item-stge_type,     " 저장유?
       space              TO goodsmvt_item-stge_bin,      " 저장 bin
       space              TO goodsmvt_item-su_pl_stck_1,  "저장단위?
*         W_MENGE            TO GOODSMVT_ITEM-ST_UN_QTYY_1,  "단위별수?
*         EKPO-BPRME         TO GOODSMVT_ITEM-ST_UN_QTYY_1_ISO,  "ISO
       space              TO goodsmvt_item-unittype_1, " 저장단위유?
       space              TO goodsmvt_item-su_pl_stck_2, "저장단위?
       space              TO goodsmvt_item-st_un_qtyy_2, "단위별수?
       space              TO goodsmvt_item-st_un_qtyy_2_iso, "ISO
       space              TO goodsmvt_item-unittype_2,  "저장단위유?
       space              TO goodsmvt_item-stge_type_pc,"이전전?
       space              TO goodsmvt_item-stge_bin_pc, "저장 bin
       space              TO goodsmvt_item-no_pst_chgnt,"변경통?
       space              TO goodsmvt_item-gr_number,   " 입고번?
       space              TO goodsmvt_item-stge_type_st," 재고이전?
       space              TO goodsmvt_item-stge_bin_st, " 재고이전?
       space              TO goodsmvt_item-matdoc_tr_cancel,
                            " 취소예정인 이전요청(TR) 자재문서번?
       space              TO goodsmvt_item-matitem_tr_cancel,
                            " 취소예정인 이전요청(TR) 자재문서번?
       space              TO goodsmvt_item-matitem_tr_cancel,
                            " 취소예정인 이전요청(TR) 자재문서품?
       space              TO goodsmvt_item-matyear_tr_cancel,
                            " 취소될 이전요청의 자재문서연?
       space              TO goodsmvt_item-no_transfer_req,
                            " 지시자: 생성된 이전요청(TR)없?
       space              TO goodsmvt_item-co_busproc,
                            " 비지니스프로세?
       space              TO goodsmvt_item-acttype,     "액티비티유?
       ztitgrk-lifnr     TO goodsmvt_item-suppl_vend,  " 공급업?
       space              TO goodsmvt_item-material_external,
                  " 필드 MATERIAL에 대한 긴 자재번호 (차후개발)
       space              TO goodsmvt_item-material_guid,
                  " 필드 MATERIAL에 대한 외부 GUID (차후개발)
       space              TO goodsmvt_item-material_version,
                  " 필드 MATERIAL에 대한 버젼번호 (차후개발)
       space              TO goodsmvt_item-move_mat_external,
                  " 필드 MOVE_에 대한 긴 자재번호 (차후개발)
       space              TO goodsmvt_item-move_mat_guid,
                  " 필드 MOVE_MAT에 대한 외부 GUID (차후개발)
       space              TO goodsmvt_item-move_mat_version.
  " 필드 MOVE_MAT에 대한 버젼번호 (차후개발)
*         SPACE              TO GOODSMVT_ITEM-FUNC_AREA,
*                      " Functional 영역.
*         SPACE              TO GOODSMVT_ITEM-TR_PART_BA,
*                     " 관계사 사업영역.
*         SPACE              TO GOODSMVT_ITEM-PAR_COMPCO,
*                     " 반제 회사코드.
*         g_tc_7000_wa-vbeln TO goodsmvt_item-deliv_numb,   " 납품.
*         g_tc_7000_wa-posnr TO goodsmvt_item-deliv_item.   " 납품품목.
*         SPACE              TO GOODSMVT_ITEM-NB_SLIPS,  " GR/GI전표?
*         SPACE              TO GOODSMVT_ITEM-NB_SLIPSX,
*                    " 관련사용자 데이타필드의 갱신정?
*
*         SPACE              TO GOODSMVT_ITEM-GR_RCPTX,
*                    " 관련사용 데이타필드의 갱신정?
*         SPACE              TO GOODSMVT_ITEM-UNLOAD_PTX.
*                    " 관련사용자 데이타필드의 갱신정?

*--> [SRM2503-02058] 이동유형 추가 체크
  IF g_tc_7000_wa-bwart IS INITIAL.
    goodsmvt_item-move_type = ztitgrk-bwart.
  ENDIF.
*<-- [SRM2503-02058] 이동유형 추가 체크

*>예약을 참조할 경우.
  IF ztitgrk-igrty EQ c_charr.
    MOVE c_charq TO goodsmvt_item-spec_stock.
    CLEAR: l_rkpf.
    SELECT SINGLE *
      INTO l_rkpf
      FROM rkpf
     WHERE rsnum  EQ  g_tc_7000_wa-rsnum.

    MOVE: l_rkpf-wempf      TO goodsmvt_item-gr_rcpt.     "자재수령인.

    CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
      EXPORTING
        input  = l_rkpf-ps_psp_pnr
      IMPORTING
        output = goodsmvt_item-wbs_elem.
*
*            l_rkpf-ps_psp_pnr TO goodsmvt_item-WBS_ELEM.    "(WBS 요소)
    MOVE: goodsmvt_item-wbs_elem TO goodsmvt_item-val_wbs_elem.
*    ELSE.
************************< Begin of Insert >*****************************
*      IF g_tc_7000_wa-knttp    EQ c_charq AND
*         g_tc_7000_wa-matnr    NE space   AND
*         g_tc_7000_wa-repos    EQ c_true  AND
*         g_tc_7000_wa-matkl(2) EQ '1Y'.
*        MOVE c_charq TO goodsmvt_item-spec_stock.
*      ENDIF.
************************< End   of Insert >*****************************
  ENDIF.

*>> ITEM APPEND
  APPEND goodsmvt_item.

************************************************************************
* 20070612 simcho by 일련번호 부여작업
* g_tc_7000_wa-batch TO goodsmvt_item-batch
************************************************************************
*
*  goodsmvt_serialnumber-matdoc_itm = g_line.
*  goodsmvt_serialnumber-serialno   = g_line.
*  APPEND   goodsmvt_serialnumber.


  goodsmvt_serialnumber-matdoc_itm = g_line.
************************************************************************
* 20090901 simcho by 오민석K
************************************************************************
*  goodsmvt_serialnumber-serialno   = goodsmvt_item-VENDRBATCH.
  goodsmvt_serialnumber-serialno   = goodsmvt_item-batch.
************************************************************************

  APPEND   goodsmvt_serialnumber.


ENDFORM.                    " set_sub_batch_gr_data
*&---------------------------------------------------------------------*
*&      Form  SET_SUB_BATCH_SEQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_sub_batch_seq .

  CLEAR: ztisgrit-erfmg, g_ibcit.
  LOOP AT g_tc_7000_temp INTO g_tc_7000_wa.
    ADD g_tc_7000_wa-grmng TO ztisgrit-erfmg.
    IF g_mode EQ c_charc OR
       g_mode EQ c_charm.
      ADD 1 TO g_ibcit.
      g_tc_7000_wa-ibcit = g_ibcit.
      MODIFY g_tc_7000_temp FROM g_tc_7000_wa.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " SET_SUB_BATCH_SEQ
*&---------------------------------------------------------------------*
*&      Form  SET_ZMMT0024_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_zmmt0024_table USING p_mode.

  DATA: lt_fieldcat_g TYPE lvc_t_fcat,
        ls_fieldcat_g LIKE LINE OF lt_fieldcat_g.

  DATA: lp_table        TYPE REF TO data.
  DATA: e_style_fname   TYPE lvc_fname.
  DATA: i_style_table   TYPE c.
  DATA: lt_fieldcat     TYPE lvc_t_fcat.
  DATA: lt_fc           TYPE slis_t_fieldcat_alv.
  DATA: ls_fcs          TYPE slis_fieldcat_alv.

  DATA: BEGIN OF lt_mseg OCCURS 1,
          zeile LIKE mseg-zeile,
          charg LIKE mseg-charg.
  DATA: END   OF lt_mseg.
*
  FIELD-SYMBOLS: <lt_table> TYPE table.
  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_charg>.
  FIELD-SYMBOLS: <l_zstat>.
  FIELD-SYMBOLS: <l_zdata>.
  FIELD-SYMBOLS: <l_iblno>.
  FIELD-SYMBOLS: <l_ebeln>.
  FIELD-SYMBOLS: <l_ebelp>.
  FIELD-SYMBOLS: <l_zbatch>.

  REFRESH: g_tc_7000_itab.
  LOOP AT g_tc_7000_save INTO g_tc_7000_wa WHERE zdata NE space.
    APPEND g_tc_7000_wa TO g_tc_7000_itab.
  ENDLOOP.
  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

  IF p_mode EQ c_charh.
    DO.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE lt_mseg
        FROM mseg
         FOR ALL ENTRIES IN g_tc_7000_itab
       WHERE mblnr EQ materialdocument
         AND mjahr EQ matdocumentyear
         AND zeile EQ g_tc_7000_itab-zeile.
      IF sy-subrc EQ 0.
        EXIT.
      ELSE.
        GET TIME.
        WAIT UP TO 2 SECONDS.
      ENDIF.
    ENDDO.
  ENDIF.

  SELECT *
    FROM dd02l UP TO 1 ROWS
   WHERE tabname  EQ g_tabname
     AND as4local EQ c_chara.
  ENDSELECT.

  CHECK sy-subrc EQ 0.

*> Create field catagory table
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = g_tabname
      i_client_never_display = ' '
    CHANGING
      ct_fieldcat            = lt_fieldcat_g[].
*>Internal table에 존재하지 않는 필드.
  LOOP AT lt_fieldcat_g INTO ls_fieldcat_g.
    MOVE-CORRESPONDING  ls_fieldcat_g TO ls_fcs.
    CLEAR: ls_fcs-key.
    ls_fcs-no_out = 'X'.
    APPEND ls_fcs TO lt_fc.
  ENDLOOP.

*create_dynamic_table
  CLEAR lp_table.
  CALL METHOD z_ts_cl_alv_table_create=>create_dynamic_table_grid
    EXPORTING
      it_fieldcatalog = lt_fc
*     i_style_table   = i_style_table
    IMPORTING
      ep_table        = lp_table.

  ASSIGN lp_table->* TO <lt_table>.
  CHECK sy-subrc EQ 0.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE <lt_table>
    FROM (g_tabname)
     FOR ALL ENTRIES IN g_tc_7000_itab
   WHERE zdata  EQ g_tc_7000_itab-zdata
     AND iblno  EQ g_tc_7000_itab-iblno
     AND ebeln  EQ g_tc_7000_itab-ebeln
     AND ebelp  EQ g_tc_7000_itab-ebelp
     AND zbatch EQ g_tc_7000_itab-licha.

  ASSIGN LOCAL COPY OF INITIAL LINE OF  <lt_table>  TO <ls_table>.
  ASSIGN COMPONENT 'CHARG' OF STRUCTURE <ls_table>  TO <l_charg>.
  ASSIGN COMPONENT 'ZSTAT' OF STRUCTURE <ls_table>  TO <l_zstat>.
  ASSIGN COMPONENT 'ZDATA' OF STRUCTURE <ls_table>  TO <l_zdata>.
  ASSIGN COMPONENT 'IBLNO' OF STRUCTURE <ls_table>  TO <l_iblno>.
  ASSIGN COMPONENT 'EBELN' OF STRUCTURE <ls_table>  TO <l_ebeln>.
  ASSIGN COMPONENT 'EBELP' OF STRUCTURE <ls_table>  TO <l_ebelp>.
  ASSIGN COMPONENT 'ZBATCH' OF STRUCTURE <ls_table> TO <l_zbatch>.

  LOOP AT <lt_table> INTO <ls_table>.
    g_tabix = sy-tabix.
    IF p_mode EQ c_charh.
      READ TABLE g_tc_7000_itab INTO g_tc_7000_wa
           WITH KEY zdata  = <l_zdata>
                    iblno  = <l_iblno>
                    ebeln  = <l_ebeln>
                    ebelp  = <l_ebelp>
                    licha  = <l_zbatch>.
      IF sy-subrc EQ 0.
        READ TABLE lt_mseg
             WITH KEY zeile = g_tc_7000_wa-zeile.
        IF sy-subrc EQ 0.
          <l_zstat> = c_charr.
          <l_charg> = lt_mseg-charg.
        ENDIF.
      ENDIF.
    ELSEIF p_mode EQ c_charr.
      CLEAR: <l_charg>.
      <l_zstat> = c_charc.
    ENDIF.
    MODIFY <lt_table> FROM <ls_table> INDEX g_tabix.

    UPDATE (g_tabname) SET: zstat = <l_zstat>
                            charg =  <l_charg>
                   WHERE    zdata  = <l_zdata>
                     AND    iblno  = <l_iblno>
                     AND    ebeln  = <l_ebeln>
                     AND    ebelp  = <l_ebelp>
                     AND    zbatch = <l_zbatch>.
  ENDLOOP.

*  BREAK-POINT.
*  UPDATE (g_tabname) FROM TABLE <lt_table>.
*
*  update
*  MODIFY (g_tabname) FROM TABLE <lt_table>.
*
ENDFORM.                    " SET_ZMMT0024_TABLE
*&---------------------------------------------------------------------*
*&      Form  get_authorization_bukrs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_authorization_bukrs .

  PERFORM init_authorization_check USING a_bukrs
                                CHANGING a_bukrs.

ENDFORM.                    " get_authorization_bukrs
*&---------------------------------------------------------------------*
*&      Form  SELECT_SENR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_senr USING i_anzsn
              CHANGING o_anzsn.

  CLEAR ser03.

  SELECT SUM( anzsn ) INTO o_anzsn
    FROM ser03
   WHERE mblnr = materialdocument
     AND mjahr = matdocumentyear.

ENDFORM.                    " SELECT_SENR
*&---------------------------------------------------------------------*
*&      Form  GET_BARCODE_SCAN_DATA
*&---------------------------------------------------------------------*
*       자체개선 104998
*       - 플랜트 3204이고 배치관리 자재일 경우 바코드스캔정보 검색
*       - 바코드 스캔 정보 테이블
*          헤더: ZPPT3012 / 아이템: ZPPT3013
*       - 프로세스
*          1) 해당 자재가 배치관리 자재인지 여부 확인
*          2) ZPPT3012에서 구매오더/품목에 대한 바코드스캔정보 여부 확인
*          3) ZPPT3013에서 배치분할 정보 입력하여 G_TC_7000_TEMP에 입력
*          4) 기타정보 입력 및 마무리 작업
*----------------------------------------------------------------------*
FORM get_barcode_scan_data  USING VALUE(ps_ztisgrit) STRUCTURE ztisgrit.

  DATA: lv_xchpf      TYPE marc-xchpf  , "1)-항과 관련되어 사용
        lt_t3012      TYPE TABLE OF zppt3012
                 WITH HEADER LINE , "2)-항과 관련되어 사용
        lv_compare(2) , "통관수량과 스캔수량 비교 결과(EQ, NE)
        lv_subrc      TYPE sy-subrc.

  DATA: lv_text1 TYPE string,
        lv_text2 TYPE string,
        lv_titel TYPE string.

*1) 배치관리 자재일 경우에만 서브루틴 수행
  SELECT SINGLE xchpf INTO lv_xchpf
    FROM marc
   WHERE matnr = ps_ztisgrit-matnr
     AND werks = ps_ztisgrit-werks .

  CHECK lv_xchpf = 'X'.

*2) 바코드 정보 확인
* -> 팝업창 생성하여 불러올지 여부 확인
  DESCRIBE TABLE g_tc_7000_temp LINES g_line.

  CLEAR lv_compare.
  SELECT * INTO TABLE lt_t3012
    FROM zppt3012
   WHERE werks  = ps_ztisgrit-werks
     AND matnr  = ps_ztisgrit-matnr
     AND import = c_char2   "2:외자
     AND ebeln  = ps_ztisgrit-ebeln
     AND ebelp  = ps_ztisgrit-ebelp
     AND grflag = c_false . "'': 입고안됨

  CLEAR lv_subrc.
  lv_subrc = sy-subrc.

  CASE g_line.
    WHEN 0.
      IF lv_subrc = 0.
        lv_titel = '바코드 배치분할 데이터 사용 확인'.
        lv_text1 = '선택한 자재의 바코드 배치분할 데이타를 찾았습니다.'.
        lv_text2 = '바코드 배치분할 데이터를 불러올까요?'.
      ELSE.

      ENDIF.
    WHEN OTHERS.
      lv_titel = '바코드 배치분할 데이터 갱신 확인'.
      lv_text1 = '기 입력된 바코드 배치분할 데이타가 존재합니다.'.
      lv_text2 = '바코드 배치분할 데이터를 다시 불러올까요??'.
  ENDCASE.

  IF NOT lv_titel IS INITIAL.

    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        titel          = lv_titel
        textline1      = lv_text1
        textline2      = lv_text2
        cancel_display = space
      IMPORTING
        answer         = g_answer.

    CHECK g_answer EQ c_charj.
  ENDIF.

*바코드 확인은 결과는 다음 유형으로 나뉨
  CASE lv_subrc.
* 2-1> 데이터 존재
    WHEN 0.
      DESCRIBE TABLE lt_t3012 LINES sy-tfill.
      IF sy-tfill >= 2. "바코드스캔 정보가 2건 이상일 경우
*      외포장 기준 스캔 데이터를 보여줘 선택하게 함
        PERFORM popup_scan_data TABLES lt_t3012[].
      ENDIF.
      PERFORM compare_qty     TABLES lt_t3012[]
                               USING ps_ztisgrit
                            CHANGING lv_compare.

*      PERFORM UPD_TABLE_ZPPT3012 TABLES LT_T3012[]
*                                  USING ZTITCCK-ICCNO
*                                        ZTITCCK-ICCSQ .

* 2-2> 데이터 없음 -> I TYPE 메시지로 데이터 업음 출력 처리
    WHEN OTHERS.
      MESSAGE '바코드 스캔정보를 찾지 못하였습니다.' TYPE 'I'.
  ENDCASE.


*3) 배치분할 데이터를 ZPPT3013에서 SELECT
  CASE lv_compare.
    WHEN 'EQ'.
      SELECT a~exidv1
             a~charg AS batch
             a~menge AS grmng
             b~meins
        INTO CORRESPONDING FIELDS OF TABLE g_tc_7000_temp
        FROM zppt3013 AS a INNER JOIN mara AS b ON a~matnr = b~matnr
        FOR ALL ENTRIES IN lt_t3012
       WHERE a~werks  = lt_t3012-werks
         AND a~exidv1 = lt_t3012-exidv1
         AND a~matnr  = lt_t3012-matnr .

      CLEAR g_tc_7000_temp.
      IF sy-subrc = 0.
        LOOP AT g_tc_7000_temp.
          g_tc_7000_temp-iccsq = ztitcck-iccsq.
          MODIFY g_tc_7000_temp. CLEAR g_tc_7000_temp.
        ENDLOOP.
      ENDIF.

    WHEN 'NE'.
      MESSAGE '통관수량과 스캔수량이 달라서 불러오기를 취소합니다.'
              TYPE 'I'.
    WHEN OTHERS.
  ENDCASE.


*4) 마무리 작업
  CLEAR: g_ibcit.
  LOOP AT g_tc_7000_temp INTO g_tc_7000_wa.
    ADD 1 TO g_ibcit.
    PERFORM set_sub_batch_record USING g_ibcit
                                       g_subrc.
    ADD g_tc_7000_wa-grmng TO ztisgrit-menge.
    MODIFY g_tc_7000_temp FROM g_tc_7000_wa.
  ENDLOOP.

  IF sy-subrc EQ 0.
    ztisgrit-ifchk = c_true.
  ENDIF.

  SORT g_tc_7000_temp BY ibcit.

ENDFORM.                    " GET_BARCODE_SCAN_DATA
*&---------------------------------------------------------------------*
*&      Form  POPUP_SCAN_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM popup_scan_data  TABLES   pt_t3012 STRUCTURE zppt3012 .

  DATA: ls_fcat TYPE slis_t_fieldcat_alv,
        lt_fcat LIKE LINE OF ls_fcat OCCURS 0 WITH HEADER LINE.

*>ALV POPUP.
  DATA: gs_private  TYPE slis_data_caller_exit,
        gs_selfield TYPE slis_selfield,
        t_fieldcat  TYPE slis_t_fieldcat_alv WITH HEADER LINE,
        g_exit(1)   TYPE c,
        dyname      LIKE d020s-prog,
        g_title(99) TYPE c,
        extab       TYPE slis_t_extab.

  DATA: BEGIN OF lt_popup OCCURS 0,
          werks   LIKE zppt3012-werks,
          exidv1  LIKE zppt3012-exidv1,
          prdif   LIKE zppt3012-prdif,
          exidv2  LIKE zppt3012-exidv2,
          matnr   LIKE zppt3012-matnr,
          menge   LIKE zppt3012-menge,
          huqty   LIKE zppt3012-huqty,
          import  LIKE zppt3012-import,
          ebeln   LIKE zppt3012-ebeln,
          ebelp   LIKE zppt3012-ebelp,
          lifnr   LIKE zppt3012-lifnr,
          mblnr   LIKE zppt3012-mblnr,
          mjahr   LIKE zppt3012-mjahr,
          huflag1 LIKE zppt3012-huflag1,
          huflag2 LIKE zppt3012-huflag2,
          grflag  LIKE zppt3012-grflag,
          hudat1  LIKE zppt3012-hudat1,
          hudat2  LIKE zppt3012-hudat2,
          grdat   LIKE zppt3012-grdat,
          scdat   LIKE zppt3012-scdat,
          sctim   LIKE zppt3012-sctim,
          laeda   LIKE zppt3012-laeda,
          aenam   LIKE zppt3012-aenam,
          box(1),
        END OF lt_popup.

  LOOP AT pt_t3012.
    MOVE-CORRESPONDING pt_t3012 TO lt_popup.
    APPEND lt_popup. CLEAR lt_popup.
  ENDLOOP.

  DATA: l_repid TYPE sy-repid.
  l_repid = sy-repid.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = l_repid
      i_structure_name       = 'ZPPT3012'
      i_inclname             = l_repid
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = lt_fcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  g_title = '복수개의 외포장 번호 발견 됨 '.
  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title               = g_title
      i_selection           = 'X'
      i_zebra               = 'X'
      i_checkbox_fieldname  = 'BOX'
      i_scroll_to_sel_line  = 'X'
      i_tabname             = 'LT_POPUP'
      it_fieldcat           = lt_fcat[]
      is_private            = gs_private
      i_screen_start_column = 1
      i_screen_start_line   = 1
      i_structure_name      = 'LT_POPUP'
      i_callback_program    = sy-repid
*     I_ALLOW_NO_SELECTION  =
*     I_LINEMARK_FIELDNAME  = 'BOX'
*     I_SCREEN_END_COLUMN   = 10
*     I_SCREEN_END_LINE     = 10
*     IT_EXCLUDING          =
*     I_CALLBACK_USER_COMMAND       =
    IMPORTING
      es_selfield           = gs_selfield
      e_exit                = g_exit
    TABLES
      t_outtab              = lt_popup[]
    EXCEPTIONS
      program_error         = 1
      OTHERS                = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CLEAR: pt_t3012, pt_t3012[].

  LOOP AT lt_popup WHERE box = 'X'.
    MOVE-CORRESPONDING lt_popup TO pt_t3012.
    APPEND pt_t3012. CLEAR pt_t3012.
  ENDLOOP.

ENDFORM.                    " POPUP_SCAN_DATA
*&---------------------------------------------------------------------*
*&      Form  COMPARE_QTY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM compare_qty  TABLES   pt_t3012           STRUCTURE zppt3012
                  USING    VALUE(ps_ztisgrit) STRUCTURE ztisgrit
                  CHANGING p_compare.

  DATA: lv_scqty TYPE zppt3012-menge. "바코드 스캔수량 합계

  CLEAR lv_scqty.
  LOOP AT pt_t3012.
    lv_scqty = lv_scqty + pt_t3012-menge.
  ENDLOOP.

  IF lv_scqty = ps_ztisgrit-ccmng.
    p_compare = 'EQ'.
  ELSE.
    p_compare = 'NE'.
  ENDIF.

ENDFORM.                    " COMPARE_QTY
*&---------------------------------------------------------------------*
*&      Form  UPD_TABLE_ZPPT3012
*&---------------------------------------------------------------------*
*       자체개선 104998
*       # P_TMODE
*          -> D: 삭제 또는 역분개
*          -> C: 입고
*       # P_MBLNR : P_TMODE가 C일때만 값이 들어옴
*       # P_MJAHR : P_TMODE가 C일때만 값이 들어옴
*----------------------------------------------------------------------*
FORM upd_table_zppt3012  USING    VALUE(p_igrno)
                                  VALUE(p_tmode)
                                  VALUE(p_mblnr)
                                  VALUE(p_mjahr)
                                  VALUE(p_budat) .

  DATA: BEGIN OF lt_grx OCCURS 0.
          INCLUDE STRUCTURE ztitgrpx .
  DATA: END OF lt_grx.

  DATA: BEGIN OF lt_3012 OCCURS 0.
          INCLUDE STRUCTURE zppt3012 .
  DATA: END OF lt_3012.

  DATA: l_x(1) VALUE 'X'.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_grx
    FROM ztitgrpx
   WHERE igrno = p_igrno.

  CHECK NOT lt_grx[] IS INITIAL.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_3012
    FROM zppt3012
     FOR ALL ENTRIES IN lt_grx
   WHERE werks = '3204'
     AND exidv1 = lt_grx-exidv1 .

  IF p_tmode = 'D'.
    CLEAR l_x.
  ENDIF.

  LOOP AT lt_3012 .
    lt_3012-grflag = l_x.
    lt_3012-mblnr  = p_mblnr .
    lt_3012-mjahr  = p_mjahr .
    lt_3012-grdat  = p_budat .
    lt_3012-laeda  = sy-datum .
    lt_3012-aenam  = sy-uname .

    MODIFY lt_3012. CLEAR lt_3012.
  ENDLOOP.

  MODIFY zppt3012 FROM TABLE lt_3012.

ENDFORM.                    " UPD_TABLE_ZPPT3012
*&---------------------------------------------------------------------*
*&      Form  SET_ZPPT0001_TABLE
*&---------------------------------------------------------------------*
*& 기능개선 127661 - 꼬리표 생성 기능 추가
*& 기능개선 167911 - 플랜트 1401/ 벤더 LSCV일 경우 무조건 꼬리표 생성
*----------------------------------------------------------------------*
FORM set_zppt0001_table   TABLES  pt_tab     STRUCTURE g_tc_2130_wa
                          USING   p_ztitgrk  STRUCTURE ztitgrk
                                  p_mode.

  DATA: BEGIN OF lt_mseg OCCURS 0,
          matnr LIKE mseg-matnr,
          werks LIKE mseg-werks,
          ebeln LIKE mseg-ebeln,
          ebelp LIKE mseg-ebelp,
          aufnr LIKE zppt0001-aufnr,
          menge LIKE mseg-menge,
          meins LIKE mseg-meins,
          lgort LIKE mseg-lgort,
          budat LIKE mkpf-budat,
          cputm LIKE mkpf-cputm,
          usnam LIKE mkpf-usnam,
          zeile LIKE mseg-zeile,
          charg LIKE mseg-charg,
          dispo LIKE marc-dispo,
          matkl LIKE mara-matkl.
  DATA: END   OF lt_mseg.

  DATA : BEGIN OF lt_tab OCCURS 0.
           INCLUDE STRUCTURE g_tc_2130_wa .
  DATA : END   OF lt_tab.

  DATA : BEGIN OF lt_t0001 OCCURS 0.
           INCLUDE STRUCTURE zppt0001 .
  DATA : END   OF lt_t0001.

  DATA : lv_tagnr    TYPE ztagnr,
         lv_spgcd(2), lv_procd(3).

  REFRESH: g_tc_7000_itab, lt_mseg, lt_t0001, lt_tab.
  CLEAR : lv_tagnr, lv_spgcd, lv_procd, lt_mseg, lt_t0001, lt_tab.

*& 꼬리표 생성 대상인지 체크
  IF g_tc_7000_save IS INITIAL. "배치분할 X
    LOOP AT pt_tab.
      SELECT SINGLE * FROM ztittag WHERE werks = pt_tab-werks
                                     AND matnr = pt_tab-matnr
                                     AND lifnr = p_ztitgrk-lifnr.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING pt_tab TO lt_tab.
        APPEND lt_tab. CLEAR lt_tab.
*-<<기능개선 167911 - 플랜트 1401/ 벤더 LSCV일 경우 무조건 꼬리표 생성
      ELSE.
        IF pt_tab-werks = '1401' AND p_ztitgrk-lifnr = '0000201430'.
          MOVE-CORRESPONDING pt_tab TO lt_tab.
          APPEND lt_tab. CLEAR lt_tab.
        ENDIF.
*->>기능개선 167911.
      ENDIF.
    ENDLOOP.

    CHECK lt_tab[] IS NOT INITIAL.

*& 자재 및 배치 정보를 가져옴
    DO.
      SELECT a~matnr
             a~werks
             a~ebeln
             a~ebelp
             a~menge
             a~meins
             a~lgort
             a~budat
             a~cputm
             a~usnam
             a~zeile
             a~charg
             c~dispo
             b~matkl
        INTO CORRESPONDING FIELDS OF TABLE lt_mseg
        FROM matdoc AS a JOIN mara AS b
                           ON a~matnr = b~matnr
                         JOIN marc AS c
                           ON a~matnr = c~matnr
                          AND a~werks = c~werks
           FOR ALL ENTRIES IN lt_tab
             WHERE a~mblnr EQ materialdocument
               AND a~mjahr EQ matdocumentyear
               AND zeile   EQ lt_tab-zeile.

      IF sy-subrc EQ 0.
        EXIT.
      ELSE.
        GET TIME.
        WAIT UP TO 1 SECONDS.
      ENDIF.
    ENDDO.

  ELSE. "배치분할
    LOOP AT g_tc_7000_save INTO g_tc_7000_wa.
      SELECT SINGLE * FROM ztittag WHERE werks = g_tc_7000_wa-werks
                                     AND matnr = g_tc_7000_wa-matnr
                                     AND lifnr = p_ztitgrk-lifnr.
      IF sy-subrc = 0.
        APPEND g_tc_7000_wa TO g_tc_7000_itab.
*-<<기능개선 167911 - 플랜트 1401/ 벤더 LSCV일 경우 무조건 꼬리표 생성
        CLEAR g_tc_7000_wa.
      ELSE.
        IF g_tc_7000_wa-werks = '1401' AND
           p_ztitgrk-lifnr    = '0000201430'.
          APPEND g_tc_7000_wa TO g_tc_7000_itab.
          CLEAR g_tc_7000_wa.
        ENDIF.
*->>기능개선 167911.
      ENDIF.
    ENDLOOP.

    CHECK g_tc_7000_itab[] IS NOT INITIAL.

*& 자재 및 배치 정보를 가져옴
    DO.
      SELECT a~matnr
             a~werks
             a~ebeln
             a~ebelp
             a~menge
             a~meins
             a~lgort
             a~budat
             a~cputm
             a~usnam
             a~zeile
             a~charg
             c~dispo
             b~matkl
        INTO CORRESPONDING FIELDS OF TABLE lt_mseg
        FROM matdoc AS a JOIN mara AS b
                           ON a~matnr = b~matnr
                         JOIN marc AS c
                           ON a~matnr = c~matnr
                          AND a~werks = c~werks
           FOR ALL ENTRIES IN g_tc_7000_itab
             WHERE a~mblnr EQ materialdocument
               AND a~mjahr EQ matdocumentyear
               AND zeile   EQ g_tc_7000_itab-zeile.

      IF sy-subrc EQ 0.
        EXIT.
      ELSE.
        GET TIME.
        WAIT UP TO 1 SECONDS.
      ENDIF.
    ENDDO.
  ENDIF.

  SORT lt_mseg BY zeile.
  DELETE ADJACENT DUPLICATES FROM lt_mseg COMPARING charg.
  CLEAR lt_mseg.

  IF p_mode EQ c_charh. "입고

    LOOP AT lt_mseg.
*& 꼬리표 채번
      lv_spgcd = lt_mseg-dispo+0(2).
      lv_procd = lt_mseg-matkl+4(3).

      CALL FUNCTION 'Z_PP_GET_NEXT_TAGNR'
        EXPORTING
          if_werks = lt_mseg-werks
          if_spgcd = lv_spgcd
          if_matkl = lt_mseg-matkl
          if_aufnr = ' '
        IMPORTING
          if_tagnr = lv_tagnr.

*& 구매오더를 생산오더 필드에 맞게 컨버젼
      "CCM : 2023.04.12  ZITCS4HDEV04 - MATNR과 관련 없음 (확인 완료)
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = lt_mseg-ebeln
        IMPORTING
          output = lt_mseg-aufnr.

*& ZPPT0001 insert
      MOVE-CORRESPONDING lt_mseg TO lt_t0001.
      lt_t0001-tagnr   = lv_tagnr.              "꼬리표번호
      lt_t0001-posnr   = lt_mseg-ebelp.         "품목번호
      lt_t0001-vornr   = '10'.
      lt_t0001-charg   = lt_mseg-charg.         "배치번호
      lt_t0001-mblnr   = materialdocument.      "입고자재문서 번호
      lt_t0001-spgcd   = lv_spgcd.              "SPG코드
      lt_t0001-procd   = lv_procd.              "공정코드
      lt_t0001-mgvrg   = lt_mseg-menge.         "입고수량
      lt_t0001-fostcnt = '1'.                   "조장수
      lt_t0001-remain  = lt_mseg-menge.         "입고수량
      lt_t0001-meins   = lt_mseg-meins.         "단위
      lt_t0001-inspflg = 'OK'.                  "합불판정
      lt_t0001-outflg  = 'Y'.
      lt_t0001-giflg   = 'N'.                   "출고여부
      lt_t0001-grflg   = 'Y'.                   "입고여부
      lt_t0001-lgort   = lt_mseg-lgort.         "입고 저장위치
      lt_t0001-wkdat   = lt_mseg-budat.         "입고일
      lt_t0001-wkindat = lt_mseg-budat.         "입고일
      lt_t0001-wkintim = lt_mseg-cputm.         "입고시간
      lt_t0001-wkinnam = lt_mseg-usnam.         "처리자
      APPEND lt_t0001. CLEAR lt_t0001.

    ENDLOOP.

    INSERT zppt0001 FROM TABLE lt_t0001.

  ELSE. "입고 취소

    LOOP AT lt_mseg.
*& 삭제 대상 꼬리표 ZPPT0001
      SELECT SINGLE *
        FROM zppt0001
        INTO lt_t0001
       WHERE werks EQ lt_mseg-werks
         AND matnr EQ lt_mseg-matnr
         AND charg EQ lt_mseg-charg.

      IF sy-subrc = 0.
        APPEND lt_t0001. CLEAR lt_t0001.
      ENDIF.

*& 꼬리표 삭제
      DELETE FROM zppt0001 WHERE werks EQ lt_mseg-werks
                             AND matnr EQ lt_mseg-matnr
                             AND charg EQ lt_mseg-charg.
    ENDLOOP.

    INSERT zppt1001 FROM TABLE lt_t0001.

  ENDIF.

ENDFORM.                    " SET_ZPPT0001_TABLE
*&---------------------------------------------------------------------*
*&      Form  SET_SCREEN_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_screen_field .


  GET PARAMETER ID 'BUK' FIELD s_bukrs-low .
  LOOP AT SCREEN .
    IF screen-group1 EQ 'INB'.
      IF s_bukrs-low EQ '3000'.
        screen-invisible = 0.
        screen-input     = 1.
      ELSE.
        screen-invisible = 1.
        screen-input     = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " SET_SCREEN_FIELD
*&---------------------------------------------------------------------*
*&      Form  FI_GR_POST_DIV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fi_gr_post_div .

  DATA : lv_mod   LIKE sy-tfill,
         it_tab_t TYPE TABLE OF t_tc_2130 WITH HEADER LINE,
         lt_tabix LIKE sy-tfill.


  IF ztitgrk-mblnr IS NOT INITIAL.
    MESSAGE s999 WITH '전기처리된 입고문서입니다.'.
    EXIT.
  ENDIF.

  IF ztitgrk-igrno IS NOT INITIAL.
    MESSAGE s999 WITH '저장된 입고문서는 분할처리가 불가능합니다.'.
    EXIT.
  ENDIF.

  IF ztitgrk-bukrs NE '3000'.
    MESSAGE s999 WITH '엠트론만 사용가능한 기능입니다.'.
    EXIT.
  ENDIF.


  MOVE it_tab[] TO it_tab_t[].

  LOOP AT it_tab_t .
    IF it_tab_t-grmng <> it_tab_t-menge.
      MESSAGE s999
      WITH '분할처리시 입고수량과 입력수량은 같아야 합니다.'.
      RETURN.
    ENDIF.
  ENDLOOP.


  CLEAR : it_tab , it_tab[].

  LOOP AT it_tab_t.
    lt_tabix = sy-tabix + 1.
    lv_mod = sy-tabix MOD 100.
    APPEND it_tab_t TO  it_tab .
    IF lv_mod EQ 0.
      PERFORM fi_gr_document_div.

      IF g_subrc NE 0.
        EXIT.
      ENDIF.

      CLEAR : it_tab , it_tab[],
              ztitgrk-igrno, ztitgrk-mblnr .
    ENDIF.
  ENDLOOP.

  IF g_subrc NE 0.
    LOOP AT it_tab_t FROM lt_tabix .
      APPEND it_tab_t TO it_tab.
    ENDLOOP.
    CLEAR ztitgrk-mblnr .
    EXIT.
  ENDIF.

  IF it_tab[] IS NOT INITIAL.
    PERFORM fi_gr_document_div.
  ENDIF.

  IF g_system_cnt EQ 0.
    PERFORM p9000_came_to_an_end.
    PERFORM p9000_program_exit.   ">Program Exit.
  ENDIF.


ENDFORM.                    " FI_GR_POST_DIV
*&---------------------------------------------------------------------*
*&      Form  FI_GR_DOCUMENT_DIV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fi_gr_document_div .

*> Set posting용 데이타 Move
  PERFORM  set_material_doc_data.
*> 전기용 BAPI 함수 Call
  PERFORM  call_bapi_function USING   testrun
                                      g_subrc. "자체개선 104998:입고
*> 오류가 없을 경우.
  IF g_subrc EQ 0         AND    ">Success
     testrun EQ c_false.
    PERFORM p8000_save_master_data USING 'H'.
    MESSAGE s012(migo) WITH materialdocument.

    WAIT UP TO 2 SECONDS.
  ENDIF.

ENDFORM.                    " FI_GR_DOCUMENT_DIV
*&---------------------------------------------------------------------*
*& Form SET_DELIVERY_COMPLETE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_delivery_complete .
  DATA  : lt_return   LIKE bapiret2         OCCURS 0 WITH HEADER LINE,
          lt_me_ekpo  TYPE bapimepoitem     OCCURS 0 WITH HEADER LINE,
          lt_me_ekpox TYPE bapimepoitemx    OCCURS 0 WITH HEADER LINE,
          lt_me_sche  LIKE bapimeposchedule OCCURS 0 WITH HEADER LINE,
          lt_me_schex LIKE bapimeposchedulx OCCURS 0 WITH HEADER LINE.

  DATA : BEGIN OF ls_ebeln,
           ebeln LIKE ekko-ebeln,
         END OF ls_ebeln.
  DATA: lt_ebeln LIKE TABLE OF ls_ebeln.

  lt_ebeln = VALUE #( FOR wa IN it_tab
                    ( ebeln = wa-ebeln ) ).
  DELETE lt_ebeln WHERE ebeln IS INITIAL.
  SORT lt_ebeln BY ebeln.
  DELETE ADJACENT DUPLICATES FROM lt_ebeln COMPARING ebeln.

  LOOP AT lt_ebeln INTO ls_ebeln.

    CLEAR : lt_return, lt_return[],
            lt_me_ekpo, lt_me_ekpo[], lt_me_ekpox, lt_me_ekpox[],
            lt_me_sche, lt_me_sche[], lt_me_schex, lt_me_schex[].

    LOOP AT it_tab INTO g_tc_2130_wa WHERE ebeln = ls_ebeln-ebeln.
      SELECT SUM( grmng ) AS grmng
        INTO @DATA(lv_grmng)
        FROM ztitgrp
       WHERE ebeln = @g_tc_2130_wa-ebeln
         AND ebelp = @g_tc_2130_wa-ebelp.

      SELECT SINGLE menge
        INTO @DATA(lv_menge)
        FROM ekpo
       WHERE ebeln = @g_tc_2130_wa-ebeln
         AND ebelp = @g_tc_2130_wa-ebelp.

      IF lv_grmng >= lv_menge.
        lt_me_ekpo-no_more_gr = 'X'.
        lt_me_ekpo-po_item    = g_tc_2130_wa-ebelp.
        APPEND lt_me_ekpo.

        lt_me_ekpox-no_more_gr = 'X'.
        lt_me_ekpox-po_item    = g_tc_2130_wa-ebelp.
        APPEND lt_me_ekpox.
      ENDIF.
    ENDLOOP.

    CALL FUNCTION 'BAPI_PO_CHANGE'
      EXPORTING
        purchaseorder = g_tc_2130_wa-ebeln
      TABLES
        return        = lt_return
        poitem        = lt_me_ekpo
        poitemx       = lt_me_ekpox
        poschedule    = lt_me_sche
        poschedulex   = lt_me_schex.

    READ TABLE lt_return WITH KEY type = 'E'.
    IF sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*      PV_TYPE = ICON_LED_RED.
*      MESSAGE S001 DISPLAY LIKE 'E' WITH GT_RETURN-MESSAGE.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

*      PV_TYPE = ICON_LED_GREEN.
*      READ TABLE LT_RETURN WITH KEY TYPE = 'S'.
*      MESSAGE S001 WITH GT_RETURN-MESSAGE.
    ENDIF.
  ENDLOOP.
ENDFORM.
