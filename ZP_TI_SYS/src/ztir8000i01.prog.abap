************************************************************************
* Title         :  ZTIR8000I01                                         *
*                                                                      *
* Description   : 수입 Notice 관리 PAI Include                         *
*                                                                      *
* Creation Date : 2004/02/12                                           *
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
*&      Module  tc_2130_modify  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_2130_modify INPUT.

  MOVE-CORRESPONDING ztispnit TO g_tc_2130_wa.

  IF g_tc_2130_wa-pnmng GT g_tc_2130_wa-pnmngl.
    CLEAR: g_menget.
    WRITE g_tc_2130_wa-pnmngl TO g_menget(15) UNIT g_tc_2130_wa-meins.
    CONCATENATE g_menget g_tc_2130_wa-meins INTO g_menget.
    MESSAGE e807 WITH g_menget.
  ENDIF.

*> 정가 계산.
  IF g_tc_2130_wa-netwr IS INITIAL.
    CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
      EXPORTING
        peinh = g_tc_2130_wa-peinh
        bpumz = g_tc_2130_wa-bpumz
        bpumn = g_tc_2130_wa-bpumn
        menge = g_tc_2130_wa-pnmng
        netpr = g_tc_2130_wa-netpr
      CHANGING
        netwr = g_tc_2130_wa-netwr.
  ENDIF.

  IF g_tc_2130_wa-refwr IS INITIAL.
    CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
      EXPORTING
        peinh = g_tc_2130_wa-peinh
        bpumz = g_tc_2130_wa-bpumz
        bpumn = g_tc_2130_wa-bpumn
        menge = g_tc_2130_wa-pnmng
        netpr = g_tc_2130_wa-netpr
      CHANGING
        netwr = g_netwr.
    g_tc_2130_wa-refwr = g_netwr.
  ENDIF.

  IF g_tc_2130_wa-cnam IS INITIAL.
    MOVE: sy-uname TO g_tc_2130_wa-cnam,
          sy-datlo TO g_tc_2130_wa-cdat,
          sy-timlo TO g_tc_2130_wa-ctme.
  ENDIF.

  MOVE: sy-uname TO g_tc_2130_wa-unam,
        sy-datlo TO g_tc_2130_wa-udat,
        sy-timlo TO g_tc_2130_wa-utme.

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
*>아이템 번호를 생성함.
  PERFORM set_item_number_build TABLES it_tab
                                USING  ztitpnk.
*> 아이템 정보 display
  PERFORM  display_infomation_by_items USING   'TC_2130'
                                               'IT_TAB'
                                               'FLAG'
                                               ztitpnk-lifnr
                                       CHANGING ok_code.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.

ENDMODULE.                 " tc_2130_user_command  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr0100_check_input_fields  INPUT
*&---------------------------------------------------------------------*
MODULE pai_scr0100_check_input_fields INPUT.
*> EXIT확인.
  PERFORM  check_program_exit_command.

*> call이 되었을 경우.
  IF sy-calld EQ c_true.
    IF NOT g_tcode  IS INITIAL.
*      MESSAGE a003(ok).
*    ELSE.
      IF sy-tcode EQ c_due_list_lo OR
         g_tcode1 EQ c_due_list_lo OR
         g_tcode1 EQ c_due_list_rt.

        MOVE: 'ZTICOPY' TO ok_code,
              'ZTICOPY' TO sy-ucomm.
      ENDIF.
    ENDIF.
  ENDIF.

*> Input fields check
  IF NOT ok_code EQ 'ZTICOPY'.
    IF ztisscrcom-ivono IS INITIAL AND
       ztisscrcom-ivnum IS INITIAL AND
       ztisscrcom-ebeln IS INITIAL AND
       ztisscrcom-reqno IS INITIAL AND
       ztisscrcom-iblno IS INITIAL AND
       ztisscrcom-blnum IS INITIAL AND
       ztisscrcom-opnno IS INITIAL.
      MESSAGE e913.
    ENDIF.
  ENDIF.

  PERFORM p3000_set_data_of_screen.

  CLEAR: g_count.

*> 구매오더 Select.
  IF NOT ok_code EQ 'ZTICOPY'.
    IF NOT ztisscrcom-ivnum IS INITIAL AND
           ztisscrcom-ivono IS INITIAL.
*  > Invoce Number로 송장관리번호를 Get
      PERFORM  get_invoice_by_iv_number     USING ztisscrcom-ivono
                                                  ztisscrcom-ivnum
                                                  c_false.
    ENDIF.

    IF NOT ztisscrcom-blnum IS INITIAL AND
           ztisscrcom-ivono IS INITIAL.
*  > B/L Number로 송장관리번호를 Get
      PERFORM  get_invoice_by_bl_number     USING ztisscrcom-ivono
                                                  ztisscrcom-blnum
                                                  c_false.
    ENDIF.

    IF NOT ztisscrcom-iblno IS INITIAL AND
           ztisscrcom-ivono IS INITIAL.
*  > B/L관리번호로 송장관리번호를 Get
      PERFORM  get_invoice_by_bl_int_no     USING ztisscrcom-ivono
                                                  ztisscrcom-iblno
                                                  c_false.
    ENDIF.

*  > B/L
    IF NOT ztisscrcom-ivono IS INITIAL.
      CALL FUNCTION 'Z_TI_GET_INVOICE_DOCUMENT'
        EXPORTING
          ivono     = ztisscrcom-ivono
        IMPORTING
          ztitivk   = ztitivk
        TABLES
          ztitivp   = it_ztisivit
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      REFRESH: it_ztispnit.
      CLEAR: g_count.
      LOOP AT it_ztisivit.
        CLEAR: it_ztispnit.
        ADD 1 TO g_count.
        MOVE-CORRESPONDING it_ztisivit TO it_ztispnit.
        MOVE : g_count TO it_ztispnit-index,
               c_true  TO it_ztispnit-box.
        APPEND it_ztispnit.
      ENDLOOP.
    ELSE.
      EXIT.
    ENDIF.

*  >가용한 Invoice 품목 검증.
    PERFORM get_available_iv_item TABLES it_ztispnit
                                  USING  c_success
                                         c_false.

*  >송장문서의 종류/상태를 검증.
    PERFORM check_invoice_doc_status.

    LOOP AT it_ztispnit.
      CLEAR: g_modify, ztiviv00.
      DESCRIBE TABLE it_tab LINES g_count_1.
*  > Get Invoice Items data
      PERFORM  get_and_check_iv_data   USING  it_ztispnit-ivono
                                              it_ztispnit-rblgp
                                              g_modify
                                              ztiviv00
                                              g_count_1.
      IF g_modify EQ c_true.
        CONTINUE.
      ENDIF.
*  > Invoice data Move
      PERFORM set_request_of_import_data TABLES it_tab
                                         USING  ztiviv00
                                                ztitpnk
                                                it_ztispnit.
    ENDLOOP.
  ELSE.
    IF g_tcode1 EQ c_due_list_rt.
************************************************************************
*-------------------< 유보금 Notice Due List >---------------------*
************************************************************************
      PERFORM  set_request_by_retention.
    ELSE.
************************************************************************
*-------------------< 내국신용장 Notice Due List >---------------------*
************************************************************************
      PERFORM  set_request_by_local_lc.
    ENDIF.
  ENDIF.
*  CHECK g_modify IS INITIAL.
  DESCRIBE TABLE it_tab LINES g_line.
  IF g_line EQ 0.
    MESSAGE e821.
  ENDIF.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM p1102_authorization_check USING ztitpnk-bukrs.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*>아이템 기타 정보 Read.
  PERFORM  set_others_fields_by_items.
*>화면상의 Text를 Master Data 등에서 Read.
  PERFORM  get_others_text_by_master_data.
*>금액 체크.
  PERFORM  check_open_amount.

  IF ztitpnk-procp IS INITIAL.
    ztitpnk-procp   = 'C'.  "Default '후취'
  ENDIF.
  ztitpnk-belnr = space.
  ztitpnk-gjahr = space.

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
                                               ztitrqs+3(12).

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

*> Input fields check

  IF ztisscrcom-pntno IS INITIAL.
    MESSAGE e913.
  ENDIF.

*> I/V Select.
  PERFORM p3000_set_data_of_screen.

  CLEAR: g_count.

  IF NOT ztisscrcom-pntno IS INITIAL.
    CALL FUNCTION 'Z_TI_GET_PAYMENT_NOTICE'
      EXPORTING
        xpntno    = ztisscrcom-pntno
      IMPORTING
        ztitpnk   = ztitpnk
      TABLES
        ztitpnp   = it_tab
        ztispnhs  = it_ztispnhs
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> authorization
    PERFORM get_authorization_bukrs.
    IF l_yn NE 'A'.
    IF ztitpnk-bukrs <> a_bukrs.
      MESSAGE e998 WITH ztitpnk-bukrs  '권한이 없습니다!'..
    ENDIF.
    endif.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*> 변경 문서 관리를 위한 이전데이타를 Move.
     *ztitpnk   = ztitpnk.
*> 변경 문서 관리를 위한 이전데이타를 Move (Item Data).
    LOOP AT it_tab INTO g_tc_2130_wa.
      MOVE-CORRESPONDING g_tc_2130_wa TO : xztitpnp,
                                           yztitpnp.
      APPEND : xztitpnp, yztitpnp.

    ENDLOOP.

    SELECT SINGLE reqty
      INTO g_reqty
      FROM ztitrqk
     WHERE reqno EQ ztitpnk-reqno.
    IF g_reqty EQ c_lc.
      SELECT * FROM ztiviv00
        INTO CORRESPONDING FIELDS OF TABLE it_ztispnit
        FOR ALL ENTRIES IN it_tab
       WHERE ivono EQ it_tab-ivono
         AND rblgp EQ it_tab-rblgp.
*
      PERFORM get_available_iv_item TABLES it_ztispnit
                                    USING  c_success
                                           c_false.
    ELSEIF g_reqty EQ c_lo.
      SELECT * FROM ztivrq00
        INTO CORRESPONDING FIELDS OF TABLE it_ztisrqit
        FOR ALL ENTRIES IN it_tab
       WHERE reqno EQ it_tab-reqno
         AND reqit EQ it_tab-reqit.

      PERFORM get_available_rq_item TABLES it_ztisrqit
                                    USING  c_success
                                           c_false.
    ENDIF.
*>아이템 기타 정보 Read.
    PERFORM set_others_fields_by_items.

*>화면상의 Text를 Master Data 등에서 Read.
    PERFORM get_others_text_by_master_data.

*>업무영역별 Status Check.
    PERFORM check_document_status.

*>조회모드가 아닌 경우 Lock.
    IF g_mode NE c_chars.
      PERFORM set_pn_lock_object   USING ztitpnk-pntno
                                         '00000'
                                         c_lock
                                         c_error
                                         g_modify.
    ENDIF.

*> Document History 조회.
    PERFORM get_document_history   TABLES it_dochis
                                   USING  g_document
                                          ztitpnk-pntno
                                          '00'
                                          g_history.
    ztisscrcom-reqty = g_document.
*> 전기이력.
    DESCRIBE TABLE it_ztispnhs LINES g_line.
    IF g_line EQ 0.
      CLEAR: g_history_post.
    ELSE.
      g_history_post = c_true.
    ENDIF.

  ELSE.
    MESSAGE e902.
  ENDIF.

ENDMODULE.                 " pai_scr0200_check_input_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr2121_check_input_fields  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_scr2121_check_input_fields INPUT.

  CHECK : g_mode EQ c_charc OR
          g_mode EQ c_charm.

*>
  IF ztitpnk-saknr IS INITIAL.
    ztitpnk-saknr = ztitig38-saknr.
  ENDIF.

*> 통지일자.
  IF ztitpnk-pntdt IS INITIAL.
    ztitpnk-pntdt = sy-datlo.
  ENDIF.
  IF ztitpnk-hwaer IS INITIAL.
    ztitpnk-hwaer = t001-waers.
  ENDIF.
  IF ztitpnk-hwaer IS INITIAL.
    ztitpnk-hwaer = t001-waers.
  ENDIF.

  IF ztitpnk-intsc IS INITIAL.
    ztitpnk-intsc = ztitpnk-waers.
  ENDIF.
*> Invoice amount
  IF ztitpnk-waers IS INITIAL.
    ztitpnk-waers = ztitpnk-waer1.
  ENDIF.

  IF ztitpnk-chgoc IS INITIAL.
    ztitpnk-chgoc = t001-waers.
  ENDIF.

*> 이종통화 FX
  IF ztitrqs-umtcu EQ c_true.
    ztitpnk-waers = 'USD'.
    IF ztitpnk-pntam IS INITIAL.
      PERFORM  get_deff_currency_conv_rate.
    ENDIF.
  ELSE.
    CLEAR: ztitpnk-bnrat.
    ztitpnk-waers = ztitpnk-waers.
    IF ztitpnk-pntam IS INITIAL.
      ztitpnk-pntam  = ztitpnk-refwr.
    ENDIF.
  ENDIF.

  ztitpnk-intsc = ztitpnk-waers.
*> 필수 항목 체크.
  PERFORM  check_mandatory_input  USING  :
                                  'ZTITPNK-NTCBK' c_error,
                                  'ZTITPNK-SSUCH' c_error,
                                  'ZTITPNK-LIFNR' c_error,
*                                  'ZTITPNK-PSPNR' c_warning,
                                  'ZTITPNK-WAERS' c_error,
                                  'ZTITPNK-REFWR' c_error,
                                  'ZTITPNK-WAER1' c_error.
  IF ztitrqk-reqty EQ c_lc.
    IF ztitrqk-ilcty EQ 'U' AND
       ztitrqs-pagrt EQ '2AA'.
*> 필수 항목 체크.
      PERFORM  check_mandatory_input  USING  :
                                      'ZTITPNK-PROCP' c_error,
                                      'ZTITPNK-BGNDT' c_error,
                                      'ZTITPNK-EXPDT' c_error,
                                      'ZTITPNK-PNTDT' c_error,
                                      'ZTITPNK-TSATZ' c_error.
*                                      'ZTITPNK-ITRST' c_error.

*>전환율 계산.
      IF ztitpnk-bnrat IS INITIAL.

      ENDIF.
*    ELSE.
    ELSEIF ztitrqk-ilcty EQ 'A'.
*           ZTITRQS-PAGRT NE '2AA'.
*> 필수 항목 체크.

      PERFORM  check_mandatory_input  USING  :
                                      'ZTITPNK-PNTAM' c_error,
                                      'ZTITPNK-PNTDT' c_error,
                                      'ZTITPNK-STLDT' c_error.
    ENDIF.
  ELSEIF ztitrqk-reqty EQ c_lo.
*> 필수 항목 체크.
    PERFORM  check_mandatory_input  USING  :
                                    'ZTITPNK-PNTAM' c_error,
                                    'ZTITPNK-PNTDT' c_error,
                                    'ZTITPNK-STLDT' c_error,
                                    'ZTITPNK-NGODT' c_error.

  ENDIF.

  IF ztitrqk-ilcty EQ c_charu AND
     ztitrqs-pagrt EQ '2AA'.
    IF ztitpnk-bgndt GE ztitpnk-expdt.
      MESSAGE e819 WITH ztitpnk-expdt ztitpnk-bgndt.
    ENDIF.
    ztitpnk-ndays = ztitpnk-bgndt - ztitpnk-expdt.
  ELSE.
    CLEAR: ztitpnk-ndays.
  ENDIF.

  PERFORM  get_import_vendors_text  USING c_error.

ENDMODULE.                 " pai_scr2121_check_input_fields  INPUT

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
*&      Module  user_command_2120  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_2120 INPUT.

ENDMODULE.                 " user_command_2210  INPUT
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
*&      Module  user_command_2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2121 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.

ENDMODULE.                 " user_command_2121  INPUT
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

  IF ztisscrcom-stgrd  IS INITIAL.
    PERFORM  no_input_check USING 'ZTISSCRCOM' 'STGRD'  c_error.
  ENDIF.

  SELECT SINGLE *
    FROM t041c
   WHERE stgrd   EQ ztisscrcom-stgrd.
  IF sy-subrc    EQ c_zero AND
     t041c-xabwd EQ c_true.
    IF ztisscrcom-cbudat IS INITIAL.
      PERFORM  no_input_check USING 'ZTISSCRCOM' 'CBUDAT' c_error.
    ENDIF.
  ENDIF.

ENDMODULE.                 " check_cancel_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_scr6010  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_scr6010 INPUT.

  CASE ok-code.
    WHEN 'ZTIDISDOC'.
      PERFORM display_liv_document  USING  ztisscrcom-belnr
                                           ztisscrcom-gjahr
                                           ztisscrcom-bukrs.
    WHEN 'ZTIOKAY'.
      LEAVE TO SCREEN 0.
    WHEN 'ZTICANCEL'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

  CLEAR: ok-code.

ENDMODULE.                 " USER_COMMAND_scr6010  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_post_fields  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_post_fields INPUT.

  CHECK ok-code EQ 'ZTIOKAY'.

  IF sy-dynnr EQ c_scr6000.
    IF ztitpnh-budat IS INITIAL.
      PERFORM  no_input_check USING 'ZTITPNH' 'BUDAT' c_error.
    ENDIF.

    IF ztitpnh-bldat  IS INITIAL.
      PERFORM  no_input_check USING 'ZTITPNH' 'BLDAT'  c_error.
    ENDIF.
  ENDIF.

  IF ztitpnh-zfbdt  IS INITIAL.
    PERFORM  no_input_check USING 'ZTITPNH' 'ZFBDT'  c_error.
  ENDIF.

*>> [CHM2402-00485] Banker's usance 차입원금 전기일 수작업 입력 (240327, 김예슬)
  IF P_DBLFZ  IS INITIAL.
*    PERFORM  no_input_check USING 'ZTITPNH' 'ZFBDT'  c_error.
    MESSAGE S000 WITH '차입전기일자를 지정하지 않으면 기준일자로 전기됩니다.'.
  ENDIF.
*<< [CHM2402-00485] Banker's usance 차입원금 전기일 수작업 입력 (240327, 김예슬)

ENDMODULE.                 " check_post_fields  INPUT
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
*&      Module  user_command_2100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2100 INPUT.

ENDMODULE.                 " user_command_2100  INPUT
