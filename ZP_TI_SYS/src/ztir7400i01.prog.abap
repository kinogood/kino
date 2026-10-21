************************************************************************
* Title         :  ZTIR7400I01                                         *
*                                                                      *
* Description   : 수입 기납증/분증 관리 PAI Include                    *
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
*&      Module  tc_2130_modify  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_2130_modify INPUT.

*  IF ztistxit-txmng GT ztistxit-txmngl.
*    WRITE : ztistxit-txmngl TO g_menget UNIT ztistxit-meins.
*    MESSAGE e134 WITH ztistxit-taxit g_menget.
*  ENDIF.

  MOVE-CORRESPONDING ztistxit TO g_tc_2130_wa.

  MODIFY  it_tab
    FROM  g_tc_2130_wa
    INDEX tc_2130-current_line.

ENDMODULE.                 " tc_2130_modify  INPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_mark  INPUT
*&---------------------------------------------------------------------*
MODULE tc_2130_mark INPUT.

  MODIFY it_tab
    FROM g_tc_2130_wa
    INDEX tc_2130-current_line
    TRANSPORTING flag.

ENDMODULE.                 " tc_2130_mark  INPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_user_command  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_2130_user_command INPUT.

  ok_code = sy-ucomm.
*> table control functions ( 삭제, 추가, 선택, 해제, 이동 등 )
  PERFORM  user_ok_tc USING    'TC_2130'
                               'IT_TAB'
                               'FLAG'
                      CHANGING ok_code.
*> 아이템 정보 display
  PERFORM  display_infomation_by_items USING   'TC_2130'
                                               'IT_TAB'
                                               'FLAG'
                                               ztittxk-lifnr
                                       CHANGING ok_code.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.

ENDMODULE.                 " tc_2130_user_command  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_type_of_request  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr0100_check_input_fields  INPUT
*&---------------------------------------------------------------------*
MODULE pai_scr0100_check_input_fields INPUT.

*> EXIT확인.
  PERFORM  check_program_exit_command.

**> call이 되었을 경우.
*  IF sy-calld EQ c_true.
*    IF NOT g_tcode  IS INITIAL.
**      MESSAGE a003(ok).
**    ELSE.
*      IF sy-tcode EQ c_no_draft_due_list OR
*         g_tcode1 EQ c_no_draft_due_list.
*        MOVE: 'ZTICOPY' TO ok_code,
*              'ZTICOPY' TO sy-ucomm.
*      ENDIF.
*    ENDIF.
*  ENDIF.

*> Input fields check
  IF NOT ok_code EQ 'ZTICOPY'.
    IF ztisscrcom-ebeln IS INITIAL AND
       ztisscrcom-reqno IS INITIAL AND
       ztisscrcom-opnno IS INITIAL.
      MESSAGE e913.
    ENDIF.
  ENDIF.

*  IF NOT zmisscrcom-ebeln IS INITIAL.
  PERFORM p3000_set_data_of_screen.

  CLEAR: g_count.
  IF NOT ok_code EQ 'ZTICOPY'.
    IF ztisscrcom-reqno IS INITIAL.
      PERFORM  get_request_no_by_po_number1 USING ztisscrcom-ebeln
                                                  ztisscrcom-reqno
                                                  ztisscrcom-amdsq
                                                  c_false.
    ENDIF.
    IF ztisscrcom-reqno IS INITIAL.
      PERFORM  get_request_no_by_open_number1 USING ztisscrcom-opnno
                                                    ztisscrcom-reqno
                                                    ztisscrcom-amdsq
                                                    c_false.
    ENDIF.
    IF NOT ztisscrcom-reqno IS INITIAL.
      PERFORM get_lc_document_data TABLES it_ztisrqit
                                   USING  ztisscrcom-reqno
                                          ztisscrcom-amdsq
                                          '00000'
                                          c_error
                                          c_error.
      LOOP AT it_ztisrqit.
        CLEAR: g_modify, ztivrq00.
        DESCRIBE TABLE it_tab LINES g_count_1.
        PERFORM  get_and_check_lc_data   USING  it_ztisrqit-reqno
                                                it_ztisrqit-amdsq
                                                it_ztisrqit-reqit
                                                g_modify
                                                ztivrq00
                                                g_count_1
                                                c_error.
*> L/C data Move
        PERFORM set_tax_document_data      TABLES it_tab
                                           USING  ztivrq00
                                                  ztittxk
                                                  it_ztisrqit.
      ENDLOOP.
    ELSE.
*>>>>> 내수 구매오더 포함.
      IF NOT ztisscrcom-ebeln IS INITIAL.
        SELECT *
          INTO CORRESPONDING FIELDS OF TABLE it_ztisrqit
          FROM ztivpo00
         WHERE ebeln EQ ztisscrcom-ebeln.
        IF sy-subrc NE 0.
          MESSAGE e145 WITH ztisscrcom-ebeln.
        ENDIF.
        LOOP AT it_ztisrqit.
          it_ztisrqit-rqmng = it_ztisrqit-menge.
          MODIFY it_ztisrqit.
        ENDLOOP.
*>수입의뢰문서의 잔량를 검증.
        PERFORM get_available_lc_item TABLES it_ztisrqit
                                             it_reqno
                                      USING  c_error
                                             c_true.


        LOOP AT it_ztisrqit.
          CLEAR: g_modify, ztivrq00.
          DESCRIBE TABLE it_tab LINES g_count_1.
          ztivrq00-ebeln = it_ztisrqit-ebeln.
          ztivrq00-ebelp = it_ztisrqit-ebelp.
          PERFORM  get_and_check_lc_data   USING  it_ztisrqit-reqno
                                                  it_ztisrqit-amdsq
                                                  it_ztisrqit-reqit
                                                  g_modify
                                                  ztivrq00
                                                  g_count_1
                                                  c_error.
*> L/C data Move
          PERFORM set_tax_document_data      TABLES it_tab
                                             USING  ztivrq00
                                                    ztittxk
                                                    it_ztisrqit.
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDIF.
  DESCRIBE TABLE it_tab LINES g_line.
  IF g_line EQ 0.
    MESSAGE e103.
  ENDIF.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM p1102_authorization_check USING ztittxk-bukrs.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*>아이템 번호를 생성함.
  PERFORM set_item_number_build TABLES it_tab
                                USING  ztittxk.
*>수입문서의 종류/상태를 검증.
  PERFORM check_request_of_custom.
*>아이템 기타 정보 Read.
  PERFORM set_others_fields_by_items.
*>화면상의 Text를 Master Data 등에서 Read.
  PERFORM get_others_text_by_master_data.
*>Create data move
  PERFORM set_header_data_move.

ENDMODULE.                 " pai_scr0100_check_input_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_scr0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_scr0100 INPUT.

*> EXIT확인.
  PERFORM  check_program_exit_command.

*> Text Object 관련 Internal Table Initial.
  PERFORM  get_longtext_data.

*> Create Class Object.
  PERFORM  build_class_object.

*> Generic Object Service.
  PERFORM  set_generic_object_service USING   'ZTIWF_SDOC'
                                               ztitivk+3(10).

  LEAVE TO SCREEN 2000.

*> 10. Save User setting infomation
  PERFORM  set_user_setting_structure.


ENDMODULE.                 " user_command_scr0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr0200_check_input_fields  INPUT
*&---------------------------------------------------------------------*
MODULE pai_scr0200_check_input_fields INPUT.

*> EXIT확인.
  PERFORM  check_program_exit_command.

  IF ztisscrcom-taxno IS INITIAL.
    MESSAGE e913.
  ENDIF.

*  CLEAR: g_count.
*  IF ztisscrcom-taxno IS INITIAL.
*    PERFORM  get_gr_int_no_by_bl_no      USING ztisscrcom-iblno
*                                               ztisscrcom-taxno
*                                               c_false.
*  ENDIF.
*  IF ztisscrcom-taxno IS INITIAL.
*    PERFORM  get_gr_int_no_by_cc_no      USING ztisscrcom-iccno
*                                               ztisscrcom-taxno
*                                               c_false.
*  ENDIF.
*
  IF NOT ztisscrcom-taxno IS INITIAL.
    CALL FUNCTION 'Z_TI_GET_TAX_DOCUMENT'
      EXPORTING
        im_taxno   = ztisscrcom-taxno
      IMPORTING
        ex_ztittxk = ztittxk
        ex_subrc   = g_subrc
      TABLES
        et_ztittxp = it_tab
        et_ztittxr = it_ztistxr
      EXCEPTIONS
        not_found  = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> authorization
    PERFORM get_authorization_bukrs.
    IF l_yn NE 'A'.
    IF ztittxk-bukrs <> a_bukrs.
      MESSAGE e998 WITH ztittxk-bukrs  '권한이 없습니다!'..
    ENDIF.
    endif.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*> 변경 문서 관리를 위한 이전데이타를 Move.
     *ztittxk   = ztittxk.

*> 변경 문서 관리를 위한 이전데이타를 Move (Item Data).
    REFRESH: xztittxp, yztittxp.
    LOOP AT it_tab INTO g_tc_2130_wa.
      MOVE-CORRESPONDING g_tc_2130_wa TO : xztittxp,
                                           yztittxp.
      APPEND : xztittxp, yztittxp.
      IF g_tc_2130_wa-txmngl LT 0.
        g_tc_2130_wa-txmngl = 0.
      ENDIF.
      MODIFY it_tab FROM g_tc_2130_wa.
    ENDLOOP.

    REFRESH:  xztittxr, yztittxr.
    LOOP AT it_ztistxr.
      MOVE-CORRESPONDING it_ztistxr TO : xztittxr,
                                         yztittxr.
      APPEND : xztittxr, yztittxr.
      MODIFY it_ztistxr.
    ENDLOOP.

*>업무영역별 Status Check.
    PERFORM check_document_status.

*> 전기이력 Tab 화면의 Visible/Invisible용.
    CLEAR: g_history_post.
    DESCRIBE TABLE it_ztistxh LINES g_line.
    IF g_line GT 0.
      MOVE: c_true TO g_history_post.
    ENDIF.

*>아이템 기타 정보 Read.
    PERFORM set_others_fields_by_items.
*>화면상의 Text를 Master Data 등에서 Read.
    PERFORM get_others_text_by_master_data.
*>조회모드가 아닌 경우 Lock.
    IF g_mode NE c_chars.
      PERFORM set_tx_lock_object   USING ztittxk-taxno
                                         c_lock
                                         c_error
                                         g_modify.
    ENDIF.
*> Document History 조회.
    PERFORM get_document_history   TABLES it_dochis
                                   USING  g_document
                                          ztittxk-taxno
                                          '00'
                                          g_history.

  ELSE.
    MESSAGE e902.
  ENDIF.

*> Cost Document History 조회.
  PERFORM get_cost_document      TABLES it_costdoc
                                 USING  g_document
                                        ztittxk-bukrs
                                        ztittxk-taxno
                                        '00'
                                        g_history_cost.

ENDMODULE.                 " pai_scr0200_check_input_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_SCR2121_CHECK_VENDOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_scr2121_check_vendor INPUT.

  PERFORM  get_import_vendors_text  USING c_error.

ENDMODULE.                 " PAI_SCR2121_CHECK_VENDOR  INPUT

*&---------------------------------------------------------------------*
*&      Module  pAI_SET_scr2210_sub1_subscreen  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_set_scr2210_sub1_subscreen INPUT.

  g_call_prog        =  c_common_prog.
  g_call_subscreen   =  c_scr0300.

ENDMODULE.                 " pAI_SET_scr2210_sub1_subscreen  INPUT

*&---------------------------------------------------------------------*
*&      Module  pAI_SET_scr2210_sub2_subscreen  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_set_scr2210_sub2_subscreen INPUT.

  g_call_prog        =  c_common_prog.
  g_call_subscreen   =  c_scr0300.


ENDMODULE.                 " pAI_SET_scr2210_sub2_subscreen  INPUT
*&---------------------------------------------------------------------*
*&      Module  pAI_SET_scr2210_sub3_subscreen  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_set_scr2210_sub3_subscreen INPUT.

  g_call_prog        =  c_common_prog.
  g_call_subscreen   =  c_scr0300.

ENDMODULE.                 " pAI_SET_scr2210_sub3_subscreen  INPUT

*&---------------------------------------------------------------------*
*&      Module  user_command_2210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2210 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.
ENDMODULE.                 " user_command_2210  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2211  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2211 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.
ENDMODULE.                 " user_command_2211  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2220  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2220 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.
ENDMODULE.                 " user_command_2220  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2230  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2230 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.
ENDMODULE.                 " user_command_2230  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2231  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2231 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.
ENDMODULE.                 " user_command_2231  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2220  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2240 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.
ENDMODULE.                 " user_command_2240  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_SURSOR_POSITION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_sursor_position INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.
ENDMODULE.                 " GET_SURSOR_POSITION  INPUT
*&---------------------------------------------------------------------*
*&      Form  check_document_status
*&---------------------------------------------------------------------*
*       업무영역별 Status Check.
*----------------------------------------------------------------------*
FORM check_document_status .

  DATA: l_ddtext LIKE g_ddtext.

*> 문서상태 Fixed value read.
  PERFORM  ddic_domain_value_text_read USING 'ZTIPOSYN'
                                             sy-langu
                                             ztittxk-posts
                                             g_ddtext
                                             c_success.
  l_ddtext = g_ddtext.

  CASE g_mode.
    WHEN c_charm.    ">변경일 경우.
      IF ztittxk-posts NE c_charn.
        MESSAGE e919 WITH g_ddtext.
      ENDIF.
    WHEN c_chard.    ">삭제일 경우.
      IF ztittxk-posts EQ c_chary.
        MESSAGE e919 WITH g_ddtext.
      ENDIF.
*    WHEN c_charp.   ">전기일 경우.
*      IF ztittxk-igrst EQ c_charg.
*        MESSAGE e919 WITH g_ddtext.
*      ENDIF.
    WHEN c_charr.   ">취소일 경우.
      IF NOT ( ztittxk-posts EQ c_charn ).
        MESSAGE e919 WITH g_ddtext.
      ENDIF.
*    WHEN c_chare.
  ENDCASE.
  MESSAGE s922 WITH l_ddtext.
*
ENDFORM.                    " check_document_status
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2121 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.

ENDMODULE.                 " USER_COMMAND_2121  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_header_line  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_header_line INPUT.

  CHECK: NOT ( g_mode EQ c_chars OR
               g_mode EQ c_chard ).

*> 세관부호.
  IF ztittxk-cdcor IS INITIAL.
    PERFORM no_input_check USING 'ZTITTXK' 'CDCOR' c_error.
  ENDIF.

*> 년도.
  IF ztittxk-byear IS INITIAL.
    ztittxk-byear = sy-datlo+2(2).
    IF ztittxk-byear IS INITIAL.
      PERFORM no_input_check USING 'ZTITTXK' 'BYEAR' c_error.
    ENDIF.
  ENDIF.

*> 연번.
  IF ztittxk-seqn7 IS INITIAL.
    PERFORM no_input_check USING 'ZTITTXK' 'SEQN7' c_error.
  ENDIF.

*> 접수번호 체크.
  CONCATENATE ztittxk-cdcor ztittxk-byear ztittxk-seqn7
              INTO ztittxk-txrno.

  SELECT *
    INTO g_ztittxk_temp
    FROM ztittxk UP TO 1 ROWS
   WHERE taxno NE ztittxk-taxno
     AND txrno EQ ztittxk-txrno.
  ENDSELECT.
  IF sy-subrc EQ 0.
    MESSAGE e740 WITH ztittxk-cdcor ztittxk-byear ztittxk-seqn7.
  ENDIF.

*> 접수일자.
  IF ztittxk-recdt IS INITIAL.
    PERFORM no_input_check USING 'ZTITTXK' 'RECDT' c_error.
  ENDIF.

*> 접수일자.
  IF ztittxk-txdgb IS INITIAL.
    PERFORM no_input_check USING 'ZTITTXK' 'TXDGB' c_error.
  ENDIF.




ENDMODULE.                 " check_header_line  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2101 INPUT.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.

ENDMODULE.                 " user_command_2101  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2100 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.
ENDMODULE.                 " user_command_2100  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2122  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2122 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.
ENDMODULE.                 " user_command_2122  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2123  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2123 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.
ENDMODULE.                 " user_command_2123  INPUT
*&---------------------------------------------------------------------*
*&      Module  fcode_exit_scr6010  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fcode_exit_scr6010 INPUT.

  LEAVE TO SCREEN 0.

ENDMODULE.                 " fcode_exit_scr6010  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_cancel_fields  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_cancel_fields INPUT.

  CHECK ok-code EQ 'ZTIOKAY'.

  IF ztisscrcom-cbudat IS INITIAL.
    PERFORM  no_input_check USING 'ZTISSCRCOM' 'CBUDAT' c_error.
  ENDIF.

ENDMODULE.                 " check_cancel_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_scr6010  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_scr6010 INPUT.

  CASE ok-code.
    WHEN 'ZTIDISDOC'.
      PERFORM display_material_doc  USING  ztisscrcom-mblnr
                                           ztisscrcom-mjahr
                                           '0000'
                                           ztisscrcom-bukrs.
    WHEN 'ZTIOKAY'.
      LEAVE TO SCREEN 0.
    WHEN 'ZTICANCEL'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.
  CLEAR: ok-code.

ENDMODULE.                 " user_command_scr6010  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_fields  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_input_fields INPUT.

  CHECK ok-code EQ 'ZTIOKAY'.

*  IF ZTITTXP-lgort IS INITIAL.
*    PERFORM  no_input_check USING 'ZTITTXP' 'LGORT' c_error.
*  ENDIF.
*  IF ZTITTXP-batch IS INITIAL.
*    PERFORM  no_input_check USING 'ZTITTXP' 'BATCH' W_error.
*  ENDIF.

ENDMODULE.                 " check_input_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_scr6020  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_scr6020 INPUT.

  CASE ok-code.
    WHEN 'ZTIOKAY'.
      LEAVE TO SCREEN 0.
    WHEN 'ZTICANCEL'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
  CLEAR: ok-code.

ENDMODULE.                 " user_command_scr6020  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_scr6000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_scr6000 INPUT.

  CASE ok_code.
    WHEN 'ABBR'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'BU' OR 'BUC' OR 'SIMU'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN OTHERS.
  ENDCASE.
  CLEAR: ok_code.

ENDMODULE.                 " exit_scr6000  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_check_fields_scr6000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_check_fields_scr6000 INPUT.

  CHECK ok_code NE 'ABBR'.

*> 전기일.
  IF ztitcsk-budat IS INITIAL.
    PERFORM no_input_check(ztir0000) USING 'ZTITCSK' 'BUDAT' 'E'.
  ENDIF.
*> 증빙일.
  IF ztitcsk-bldat IS INITIAL.
    PERFORM no_input_check(ztir0000) USING 'ZTITCSK' 'BLDAT' 'E'.
  ENDIF.

**> 사업장.
*  IF ztitcsk-bupla IS INITIAL.
*    PERFORM no_input_check(ztir0000) USING 'ZTITCSK' 'BUPLA' 'E'.
*  ENDIF.
  IF NOT ztitig00-chkbp IS INITIAL.
    IF ztitcsk-bupla IS INITIAL.    ">
*      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'BUPLA'.
      PERFORM  check_mandatory_input(ztir0000)
                             USING  'ZTITCSK-BUPLA' ztitig00-chkbp.
    ENDIF.
  ENDIF.

  IF NOT ztitig00-chkba IS INITIAL.
    IF ztitcsk-gsber IS INITIAL.    ">
*      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'BUPLA'.
      PERFORM  check_mandatory_input(ztir0000)
                            USING  'ZTITCSK-GSBER' ztitig00-chkba.
    ENDIF.
  ENDIF.
*> 입력된 값 체크.
  PERFORM  check_input_value_scr6000.

*> 지급조건.
  IF ztitcsk-zterm IS INITIAL.
    PERFORM no_input_check(ztir0000) USING 'ZTITCSK' 'ZTERM' 'E'.
  ENDIF.

  IF ztitcsk-cstyp IS INITIAL.
    PERFORM no_input_check(ztir0000) USING 'ZTITCSK' 'CSTYP' 'E'.
  ELSE.
    IF ztitcsk-cstyp EQ 'A'.
*> Get 업무가불 Default value
*      break-point.
*      SELECT SINGLE *
*        FROM ztitig07
*       WHERE bukrs EQ ztitcsk-bukrs
*         AND CSTCT EQ 'L'.
*      IF sy-subrc EQ 0.
*        IF ztitig07-blart NE ztitcsk-blart.
*          MESSAGE w941 WITH ztitcsk-blart ztitig07-blart.
*          ztitcsk-blart = ztitig07-blart.
*        ENDIF.
*      ENDIF.
      IF ztitcsk-iname IS INITIAL.
        PERFORM no_input_check(ztir0000) USING 'ZTITCSK' 'INAME' 'E'.
      ENDIF.
    ENDIF.
  ENDIF.

**> 사업영역.
*  IF ZTITCSK-gsber IS INITIAL.
*    PERFORM no_input_check(ZTIr0000) USING 'ZTITCSK' 'GSBER' 'E'.
*  ENDIF.
**> 사용가능한 사업영역 체크.
*  PERFORM  check_business_area(ZTIr0000)
*                                     USING ZTITCSK-gsber.
*
*> 개별전표일 경우.
  IF ztisscrcom-monsc EQ 'I'.

*> 일괄전표일 경우.
  ELSE.

  ENDIF.

ENDMODULE.                 " pai_check_fields_scr6000  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_6000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_6000 INPUT.

  CASE ok_code.
    WHEN 'ABBR'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'BU' OR 'BUC' OR 'SIMU'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN OTHERS.
  ENDCASE.
  CLEAR: ok_code.

ENDMODULE.                 " user_command_6000  INPUT
*&---------------------------------------------------------------------*
*&      Module  help_payment_term_scr6000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE help_payment_term_scr6000 INPUT.

  LOOP AT SCREEN.
    IF screen-name EQ 'ZTITCSK-ZTERM'.
      EXIT.
    ENDIF.
  ENDLOOP.

  PERFORM get_f4_for_zterm_dynpro(ztir9000) USING ztitcsk-zterm.

ENDMODULE.                 " help_payment_term_scr6000  INPUT
