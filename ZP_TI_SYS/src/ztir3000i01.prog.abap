************************************************************************
* Title         :  ZTIR3000I01                                         *
*                                                                      *
* Description   : 수입 I/V 관리 PAI Include                            *
*                                                                      *
* Creation Date : 2004/02/12                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* 20090129       MMB03                     C20090121_89795             *
*                                         :수입반품process 추가        *
*2014.09.11       조성익          43436 : 복합 BL 사후송금송장 생성 개선
*                                                                      *
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Module  tc_2130_modify  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_2130_modify INPUT.

  MOVE-CORRESPONDING : g_tc_2130_old TO g_tc_2130_wa.

  IF g_menge_request EQ c_true.
    MOVE ztisivit-ivmng TO g_tc_2130_wa-ivmng.

    IF ztisivit-remng IS INITIAL.
      PERFORM  no_input_check USING 'ZTISIVIT' 'IVMNG' c_error.
    ENDIF.

*> 송장처리 가능수량을 초과했을 경우.
    IF ztisivit-ivmng GT ztisivit-ivmngl.
      CLEAR: g_menget.
      WRITE ztisivit-ivmngl TO g_menget(15) UNIT ztisivit-meins.
      CONCATENATE g_menget ztisivit-meins INTO g_menget.
      MESSAGE e301 WITH g_menget.
    ENDIF.

*> 정가 계산.
    CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
      EXPORTING
        peinh = ztisivit-peinh
        bpumz = ztisivit-bpumz
        bpumn = ztisivit-bpumn
        menge = ztisivit-ivmng
        netpr = ztisivit-netpr
      CHANGING
        netwr = ztisivit-netwr.

    g_tc_2130_wa-netwr = ztisivit-netwr.
    g_tc_2130_wa-refwr = ztisivit-netwr.
*    ZTIsivit-refwr     = ZTIsivit-netwr.
  ENDIF.

  IF g_wrbtr_request EQ c_true.
    MOVE ztisivit-refwr TO g_tc_2130_wa-refwr.

    IF g_tc_2130_wa-refwr IS INITIAL.
      g_tc_2130_wa-refwr = g_tc_2130_old-refwr.
    ENDIF.

    IF g_tc_2130_wa-refwr NE g_tc_2130_old-refwr.
      MESSAGE w025 WITH g_index.
    ENDIF.
  ENDIF.

  IF ztisivit-mwskz IS INITIAL.
    ztisivit-mwskz = ztitivk-mwskz.
  ENDIF.

  MOVE: ztisivit-mwskz TO g_tc_2130_wa-mwskz,
        ztisivit-sgtxt TO g_tc_2130_wa-sgtxt.

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
    INDEX g_index.
*    INDEX tc_2130-current_line.

  CLEAR: g_menge_request, g_wrbtr_request.

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
                                USING  ztitivk.
*> 아이템 정보 display
  PERFORM  display_infomation_by_items USING   'TC_2130'
                                               'IT_TAB'
                                               'FLAG'
                                               ztitivk-lifnr
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

  ok_code_old = ok_code.
  CLEAR: ok_code_popup.

*> Input fields check
  IF NOT ok_code EQ 'ZTICOPY'.
    IF ztisscrcom-iblno IS INITIAL AND
      ztisscrcom-blnum IS INITIAL.
      MESSAGE e913.
    ENDIF.

    IF ztisscrcom-iblno IS INITIAL.
      PERFORM  get_bl_int_no_by_bl_number  USING ztisscrcom-blnum
                                               ztisscrcom-iblno
                                               c_false.
    ENDIF.
  ENDIF.

*> 구매오더 Select.
  IF NOT ok_code EQ 'ZTICOPY'.
    PERFORM p3000_set_data_of_screen.

    CLEAR: g_count.

    IF NOT ztisscrcom-iblno IS INITIAL.

* b/l상태 확인.add.
      SELECT SINGLE *
        FROM ztitblk
       WHERE iblno EQ ztisscrcom-iblno.
      IF ztitblk-crlse EQ 'B'.
        MESSAGE ID 'ZMTI00' TYPE 'E' NUMBER 321 WITH '송장'.
      ENDIF.

*{ 기능개선 283274 - 추가_S
*___B/L로 생성된 적하보험 존재 여부 점검
      PERFORM check_insurance_policy USING    ztitblk-iblno
                                     CHANGING g_check.

      IF g_check = 'X'.
        IF sy-calld = 'X'.
          MESSAGE S997 DISPLAY LIKE 'E'
             WITH '적하보험이 생성되지 않았습니다.'
                  'B/L 관리번호 :' ztitblk-iblno.

          LEAVE PROGRAM.
        ELSE.
          MESSAGE E997 WITH '적하보험이 생성되지 않았습니다.'
                            'B/L 관리번호 :' ztitblk-iblno.
        ENDIF.
      ENDIF.
*} 기능개선 283274 - 추가_E

*> 회사별 프로세스 정의 테이블 검색.
      SELECT SINGLE *
        FROM ztitig00
       WHERE bukrs EQ ztitblk-bukrs.
      IF sy-subrc NE 0.
        MESSAGE e035 WITH ztitblk-bukrs.
      ENDIF.
      PERFORM get_bl_document_data TABLES  it_bl
                                           it_ztitig02
                                    USING  ztisscrcom-iblno
                                           ztisscrcom-iblit
                                           c_error
                                           c_error.
    ENDIF.
    LOOP AT it_bl.
      CLEAR: g_modify, ztivbl00.
      DESCRIBE TABLE it_tab LINES g_count_1.
      PERFORM  get_and_check_bl_data   USING  it_bl-iblno
                                              it_bl-iblit
                                              g_modify
                                              ztivbl00
                                              g_count_1.
*> PO data Move
      PERFORM set_request_of_import_data TABLES it_tab
                                         USING  ztivbl00
                                                ztitivk
                                                ztitivp
                                                it_bl.
    ENDLOOP.
    DESCRIBE TABLE it_tab LINES g_line.
    IF g_line EQ 0.
      MESSAGE e103.
    ENDIF.
  ELSE.
    PERFORM p3000_set_data_of_screen.
*    MESSAGE e000 WITH '선급금'(s03).
    CALL SCREEN 7000 STARTING AT 01 01
                      ENDING  AT 32 04 .

    IF ok_code_popup NE 'FCOPY'.
      EXIT.
    ELSE.
      LOOP AT it_reqit_tmp.
        MOVE-CORRESPONDING it_reqit_tmp TO it_ztisrqit.
        APPEND it_ztisrqit.
      ENDLOOP.
    ENDIF.
  ENDIF.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM p1102_authorization_check USING ztitivk-bukrs.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*>아이템 기타 정보 Read.
  PERFORM set_others_fields_by_items.
*>화면상의 Text를 Master Data 등에서 Read.
  PERFORM get_others_text_by_master_data.
*>Set Defalut values
  PERFORM set_invoice_default_values.
*>송장금액 체크.
  PERFORM check_open_amount.

ENDMODULE.                 " pai_scr0100_check_input_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_scr0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_scr0100 INPUT.

  IF ok_code_old = 'ZTICOPY'.
    IF ok_code_popup NE 'FCOPY'.
      EXIT.
    ENDIF.
  ENDIF.


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

*> Input fields check

  IF ztisscrcom-ivono IS INITIAL AND
     ztisscrcom-iblno IS INITIAL AND
     ztisscrcom-blnum IS INITIAL AND
     ztisscrcom-ivnum IS INITIAL.
    MESSAGE e913.
  ENDIF.

*> I/V Select.
  PERFORM p3000_set_data_of_screen.

  CLEAR: g_count.
*> Invoice 번호로 Invoice 관리번호 찾을 경우.
  IF ztisscrcom-ivono IS INITIAL AND
     NOT ztisscrcom-ivnum IS INITIAL.
    PERFORM  get_invoice_by_iv_number     USING ztisscrcom-ivono
                                                ztisscrcom-ivnum
                                                c_false.
  ENDIF.
*> B/L 관리번호로 Invoice 관리번호 찾을 경우.
  IF ztisscrcom-ivono IS INITIAL AND
     NOT ztisscrcom-iblno IS INITIAL.
    PERFORM  get_invoice_by_bl_int_no     USING ztisscrcom-ivono
                                                ztisscrcom-iblno
                                                c_false.
  ENDIF.
*> B/L Number로 Invoice 관리번호 찾을 경우.
  IF ztisscrcom-ivono IS INITIAL AND
     NOT ztisscrcom-blnum IS INITIAL.
    PERFORM  get_invoice_by_bl_number     USING ztisscrcom-ivono
                                                ztisscrcom-blnum
                                                c_false.
  ENDIF.

  IF NOT ztisscrcom-ivono IS INITIAL.
*>Get 송장 문서.
    CALL FUNCTION 'Z_TI_GET_INVOICE_DOCUMENT'
      EXPORTING
        ivono     = ztisscrcom-ivono
      IMPORTING
        ztitivk   = ztitivk
      TABLES
        ztitivp   = it_tab
        ztitivh   = it_ztitivh
        ztitivv   = it_ztitivv
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

*      perform read_iv_item_data changing it_tab.


    SELECT * FROM ztivbl00
      INTO CORRESPONDING FIELDS OF TABLE it_bl
      FOR ALL ENTRIES IN it_tab
     WHERE iblno EQ it_tab-iblno
       AND iblit EQ it_tab-iblit.

    PERFORM get_available_bl_item TABLES it_bl
                                         it_blnum
                                  USING  c_success
                                         c_false.
*> 변경 문서 관리를 위한 이전데이타를 Move.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> authorization
    PERFORM get_authorization_bukrs.
    IF l_yn NE 'A'.
      IF ztitivk-bukrs <> a_bukrs.
        MESSAGE e998 WITH ztitivk-bukrs  '권한이 없습니다!'..
      ENDIF.
    ENDIF.
** JS전선 회사코드 2007/04 KSH --------------------------------------

     *ztitivk   = ztitivk.

    yztitivp[] = xztitivp[].

*> 변경 문서 관리를 위한 이전데이타를 Move (Item Data).
    REFRESH: xztitivp, yztitivp.
    LOOP AT it_tab INTO g_tc_2130_wa.
      MOVE-CORRESPONDING g_tc_2130_wa TO : xztitivp,
                                           yztitivp.
      APPEND : xztitivp, yztitivp.
*> 송장--->B/L 번호..
      IF ztitivk-prpyn EQ c_chari.
        ztitblk-iblno = xztitivp-iblno.
      ENDIF.
    ENDLOOP.

*> 변경 문서 관리를 위한 이전데이타를 Move (금액분할).
    REFRESH: xztitivv, yztitivv.
    LOOP AT it_ztitivv.
      MOVE-CORRESPONDING it_ztitivv TO : xztitivv,
                                         yztitivv.
      APPEND : xztitivv, yztitivv.

    ENDLOOP.

*> 송장--->B/L 번호..
    IF ztitivk-prpyn EQ c_chari.
      SELECT SINGLE *
        FROM ztitblk
       WHERE iblno EQ ztitblk-iblno.
    ENDIF.

*>업무영역별 Status Check.
    PERFORM check_document_status.
*>아이템 기타 정보 Read.
    PERFORM set_others_fields_by_items.
*>화면상의 Text를 Master Data 등에서 Read.
    PERFORM get_others_text_by_master_data.
*>조회모드가 아닌 경우 Lock.
    IF g_mode NE c_chars.
      PERFORM set_iv_lock_object   USING ztitivk-ivono
                                         '00000'
                                         c_lock
                                         c_error
                                         g_modify.
    ENDIF.
*> Document History 조회.
    DESCRIBE TABLE it_ztitivh LINES g_line.
    IF g_line GT 0.
      g_history_post = c_true.
    ELSE.
      CLEAR g_history_post.
    ENDIF.

*> Document History 조회.
    PERFORM get_document_history   TABLES it_dochis
                                   USING  g_document
                                          ztitivk-ivono
                                          '00'
                                          g_history.
    ztisscrcom-reqty = c_iv.
  ELSE.
    MESSAGE e902.
  ENDIF.

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
*&      Module  tc_2123_modify  INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2123'. do not change this line!
*> modify table
*&---------------------------------------------------------------------*
MODULE tc_2123_modify INPUT.

  MOVE-CORRESPONDING ztisivvs TO g_tc_2123_wa.

  MODIFY it_ztitivv
    FROM g_tc_2123_wa
    INDEX tc_2123-current_line.

  IF sy-subrc NE 0.
    APPEND g_tc_2123_wa TO it_ztitivv.
  ENDIF.

ENDMODULE.                    "TC_2123_modify INPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2123_mark  INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2123'. do not change this line!
*> mark table
*&---------------------------------------------------------------------*
MODULE tc_2123_mark INPUT.
  IF tc_2123-line_sel_mode = 1 AND
     ztisivvs-flag = 'X'.
    LOOP AT it_ztitivv INTO g_tc_2123_wa
      WHERE flag = 'X'.
      g_tc_2123_wa-flag = ''.
      MODIFY it_ztitivv
        FROM g_tc_2123_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tc_2123_wa-flag = 'X'.
  ENDIF.
  MODIFY it_ztitivv
    FROM g_tc_2123_wa
    INDEX tc_2123-current_line
    TRANSPORTING flag.
ENDMODULE.                    "TC_2123_mark INPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2123_user_command  INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2123'. do not change this line!
*> process user command
*&---------------------------------------------------------------------*
MODULE tc_2123_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_2123'
                              'IT_ZTITIVV'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.

ENDMODULE.                    "TC_2123_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_check_input_value_scr2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_check_input_value_scr2121 INPUT.

  IF ok_code_old = 'ZTICOPY'.
    IF ok_code_popup NE 'FCOPY'.
      EXIT.
    ENDIF.
  ENDIF.

**> Input fields check
*  IF NOT ok_code EQ 'ZTICOPY'.
*
  CHECK NOT ( g_mode EQ 'S' OR
              g_mode EQ 'D' OR
              g_mode EQ 'R' ).
*> 송장일자.
  IF ztitivk-civdt IS INITIAL.
    PERFORM no_input_check USING 'ZTITIVK' 'CIVDT' c_error.
  ENDIF.
*> 전기일자.
*  IF ZTITIVK-bldat IS INITIAL.
  ztitivk-bldat = ztitivk-civdt.
*    PERFORM no_input_check USING 'ZTITIVK' 'BLDAT' c_error.
*  ENDIF.
*> 증빙일자.
  IF ztitivk-budat IS INITIAL.
*    ZTITIVK-budat = ZTITIVK-civdt.
    PERFORM no_input_check USING 'ZTITIVK' 'BUDAT' c_error.
  ENDIF.

**-----> LS전선 Migration관계로 Check logic 제외.by MSH,050501
**  IF ztitivk-opnbk IS INITIAL.
**    PERFORM no_input_check USING 'ZTITIVK' 'OPNBK' c_error.
**  ELSE.
*  SELECT SINGLE *
*    FROM ztstig3
*   WHERE parti EQ c_charb
*     AND epart EQ ztitivk-opnbk.
**    IF sy-subrc NE 0.
**      MESSAGE e918 WITH ztitivk-opnbk.
**    ENDIF.
*  IF ztitig00-sjpap EQ c_charv.
*    ztitivk-apven = ztitivk-lifnr.
*  ELSEIF ztitig00-sjpap EQ c_charb.
*    ztitivk-apven = ztstig3-lifnr.
*  ENDIF.
**  ENDIF.
**-----> End of Modification.
  IF ztitivk-opnbk IS INITIAL.
*******************************************************************
* 2008.01.22 by C20090121_89795
* BL 유형 'B' 수입반품에 대한 사후송금 조건 추가
* CSR : C20090121_89795
*   IF ztitblk-bldty NE 'A'.
*******************************************************************

*** 43436 추가 시작

    CLEAR g_aftyn.
    PERFORM get_aftyn USING ztitivk-ebeln CHANGING g_aftyn.

*** 43436 추가 끝

    IF ztitblk-bldty NE 'A' AND
       ztitblk-bldty NE 'B' AND
       ( ztitblk-bldty NE 'C' OR g_aftyn NE 'A' ). "43436 추가
      PERFORM no_input_check USING 'ZTITIVK' 'OPNBK' c_error.
    ENDIF.
    IF ztitig00-sjpap EQ c_charv.
      ztitivk-apven = ztitivk-lifnr.
    ELSEIF ztitig00-sjpap EQ c_charb.
      ztitivk-apven = ztstig3-lifnr.
    ENDIF.
  ELSE.
    IF NOT ztitivk-opnbk IS INITIAL.
      SELECT SINGLE *
        FROM ztstig3
       WHERE parti EQ c_charb
         AND epart EQ ztitivk-opnbk
         AND bukrs EQ ztitivk-bukrs.
      IF sy-subrc NE 0.
        MESSAGE e918 WITH ztitivk-opnbk.
      ENDIF.
      IF ztitig00-sjpap EQ c_charv.
        ztitivk-apven = ztitivk-lifnr.
      ELSEIF ztitig00-sjpap EQ c_charb.
        ztitivk-apven = ztstig3-lifnr.
      ENDIF.
    ENDIF.
  ENDIF.


  CLEAR ztitivk-gjahr.

  g_monat = ztitivk-monat.

  PERFORM periode_determine USING ztitivk-bukrs
                                  ztitivk-budat
                                  ztitivk-gjahr
                                  ztitivk-monat.

  IF NOT g_monat IS INITIAL
  AND    g_monat NE ztitivk-monat
  AND ( sy-binpt = space AND sy-calld = space ).
    MESSAGE w000(f5) WITH g_monat ztitivk-budat ztitivk-monat.
  ENDIF.

**> 선급금 구분이 선급금일 경우 선급금 % Check.
*  IF ZTITIVK-prpyn EQ c_charp.
*    IF ZTITIVK-pprat IS INITIAL.
*      PERFORM no_input_check USING 'ZTITIVK' 'PPRAT' c_success.
*    ENDIF.
*  ENDIF.

*> 사업장.
  IF ztitivk-bupla IS INITIAL.
    ztitivk-bupla = c_bupla.
    IF ztitivk-bupla IS INITIAL.
      PERFORM no_input_check USING 'ZTITIVK' 'BUPLA' c_error.
    ENDIF.
  ENDIF.

*> 사업영역
*  IF ztitivk-gsber IS INITIAL.
*    PERFORM no_input_check USING 'ZTITIVK' 'GSBER' c_error.
*  ENDIF.

***> 사업영역.
*  IF ZTITIVK-gsber IS INITIAL.
*    PERFORM no_input_check USING 'ZTITIVK' 'GSBER' c_error.
*  ENDIF.
*  IF NOT ( ZTITIVK-gsber EQ c_gsber1 OR
*           ZTITIVK-gsber EQ c_gsber2 ).
*    SET CURSOR FIELD 'ZTITIVK-GSBER'.
*    MESSAGE e876 WITH ZTITIVK-gsber.
*  ENDIF.

*> 전표유형.
  IF ztitivk-blart IS INITIAL.
    ztitivk-blart = c_blart.
    IF ztitivk-blart IS INITIAL.
      PERFORM no_input_check USING 'ZTITIVK' 'BLART' c_error.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'FI_POSTING_KEY_DATA'
    EXPORTING
      i_bschl       = '31'
      i_umskz       = space       ">bseg-umskz
    IMPORTING
      e_t074u       = t074u
      e_tbsl        = tbsl
      e_tbslt       = tbslt
    EXCEPTIONS
      error_message = 1.

* 1. PBO: no message if bschl request umskz
  IF sy-subrc = 1.
* (del) if not ( firstcall = 'X'                           "Note 352492
    IF tbsl-xsonu NE space.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH
              sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

*>> VENDOR MASTER DEFINE.
  IF NOT ztitivk-lifnr IS INITIAL.
    CLEAR : lfa1.
    SELECT SINGLE * INTO lfa1 FROM lfa1
                    WHERE lifnr EQ ztitivk-lifnr.
    IF sy-subrc NE 0.
      MESSAGE e924 WITH '구매처' ztitivk-lifnr.
    ENDIF.

    CALL FUNCTION 'FI_VENDOR_DATA'
      EXPORTING
        i_bukrs = ztitivk-bukrs
        i_lifnr = ztitivk-lifnr
      IMPORTING
        e_kred  = vf_kred.

    IF ztitivk-zterm NE vf_kred-zterm.
      IF ztitivk-zterm IS INITIAL.
        ztitivk-zterm = vf_kred-zterm.
*      ELSE.
*        MESSAGE w855 WITH ZTITIVK-zterm
*                          ZTITIVK-lifnr vf_kred-zterm.
      ENDIF.
    ENDIF.
  ENDIF.

*> 지급조건.
  IF NOT ztitivk-zterm IS INITIAL.
    SELECT * FROM t052
             WHERE zterm EQ ztitivk-zterm.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE e839(f5) WITH ztitivk-zterm.
    ENDIF.
  ENDIF.

*> 세금코드.
*  IF ztitivk-mwskz IS INITIAL.
*    READ TABLE it_tab INTO g_tc_2130_wa INDEX 1.
*    IF sy-subrc EQ 0.
*      ztitivk-mwskz = g_tc_2130_wa-mwskz.
*    ENDIF.
*    ztitivk-mwskz = c_mwskz.
*    IF ztitivk-mwskz IS INITIAL.
*      PERFORM no_input_check USING 'ZTITIVK' 'MWSKZ' c_error.
*    ENDIF.
*  ENDIF.
  LOOP AT it_tab INTO g_tc_2130_wa WHERE mwskz NE space.
    ztitivk-mwskz = g_tc_2130_wa-mwskz.
    EXIT.
  ENDLOOP.

*>> TAX CODE CHECK.
  IF NOT ztitivk-lifnr IS INITIAL.
    CALL FUNCTION 'FI_TAX_INDICATOR_CHECK'
      EXPORTING
        i_bukrs  = ztitivk-bukrs
        i_hkont  = vf_kred-akont
        i_koart  = 'K'
        i_mwskz  = ztitivk-mwskz
        i_stbuk  = space
        x_dialog = 'X'
      IMPORTING
        e_egrkz  = g_egrkz.
  ENDIF.

*> 기준일자.
  IF ztitivk-zfbdt IS INITIAL.
*    ztitivk-zfbdt = ztitivk-civdt.
    g_zterm_modify = c_true.
  ENDIF.

  IF g_zterm_modify EQ c_true.
    IF ztitivk-zfbdt IS INITIAL.
      CALL FUNCTION 'FI_TERMS_OF_PAYMENT_PROPOSE'
        EXPORTING
          i_bldat = ztitivk-bldat
          i_budat = ztitivk-budat
          i_zterm = ztitivk-zterm
        IMPORTING
          e_zfbdt = ztitivk-zfbdt
          e_zbd1t = ztitivk-zbd1t
          e_zbd1p = ztitivk-zbd1p
          e_zbd2t = ztitivk-zbd2t
          e_zbd2p = ztitivk-zbd2p
          e_zbd3t = ztitivk-zbd3t
          e_zlsch = ztitivk-zlsch
          e_zschf = ztitivk-zlspr.
    ELSE.
      CALL FUNCTION 'FI_TERMS_OF_PAYMENT_PROPOSE'
        EXPORTING
          i_bldat = ztitivk-bldat
          i_budat = ztitivk-budat
          i_cpudt = sy-datlo
          i_zfbdt = ztitivk-zfbdt
          i_zterm = ztitivk-zterm
        IMPORTING
          e_zbd1t = ztitivk-zbd1t
          e_zbd1p = ztitivk-zbd1p
          e_zbd2t = ztitivk-zbd2t
          e_zbd2p = ztitivk-zbd2p
          e_zbd3t = ztitivk-zbd3t
          e_zlsch = ztitivk-zlsch
*      e_zschf = ZTITIVK-zlspr
          e_zschf = g_zlspr
          e_zfbdt = g_zfbdt.
*
*          e_zschf = ztitivk-zlspr
*          e_zfbdt = ztitivk-zfbdt.
*
      IF NOT g_zfbdt IS INITIAL.
        ztitivk-zfbdt = g_zfbdt.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR: faede.

  faede-shkzg = 'H'.
  faede-koart = 'K'.
  faede-zfbdt = ztitivk-zfbdt.
  faede-zbd1t = ztitivk-zbd1t.
  faede-zbd2t = ztitivk-zbd2t.
  faede-zbd3t = ztitivk-zbd3t.
*  faede-rebzg = space.
*  faede-rebzt = bseg-rebzt.
  faede-bldat = ztitivk-bldat.

  CALL FUNCTION 'DETERMINE_DUE_DATE'
    EXPORTING
      i_faede = faede
    IMPORTING
      e_faede = faede
    EXCEPTIONS
      OTHERS  = 1.

  ztitivk-netdt = faede-netdt.

*> 기준일 기준 환율 Set.
  IF ztitivk-wwert IS INITIAL.
    MOVE ztitivk-zfbdt TO ztitivk-wwert.
  ENDIF.

*  IF ztitivk-kursf IS INITIAL. "기능개선 241468 삭제 - 환율 자동적용
    CLEAR: ztitivk-kursf.

    CALL FUNCTION 'FI_CURRENCY_CHECK'
           EXPORTING
                i_bldat  = ztitivk-bldat
                i_budat  = ztitivk-budat
                i_bukrs  = ztitivk-bukrs
                i_blart  = ztitivk-blart
*              I_KURS2  = BKPF-KURS2
*              I_KURS3  = BKPF-KURS3
                i_kursf  = ztitivk-kursf
                i_waers  = ztitivk-waers
                x_dialog = 'X'          "Warnungen im Dialog!
                i_wwert  = ztitivk-wwert
           IMPORTING
*              E_KURS2  = BKPF-KURS2
*              E_KURS3  = BKPF-KURS3
                e_kursf  = ztitivk-kursf
                e_wwert  = ztitivk-wwert.

    IF ztitivk-kursf LT 0.
      ztitivk-kursf = 0.
    ENDIF.

    IF ztitivk-waers EQ t001-waers.
      ztitivk-kursf = 1.
    ENDIF.
*  ENDIF.

ENDMODULE.                 " pai_check_input_value_scr2121  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_ITEM_AMOUNT_ADJUST_SCR2130  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_item_amount_adjust_scr2130 INPUT.

  g_wrbtr_request = c_true.

ENDMODULE.                 " PAI_ITEM_AMOUNT_ADJUST_SCR2130  INPUT
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
*&      Module  user_command_2122  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2122 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.

ENDMODULE.                 " user_command_2122  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2124  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2124 INPUT.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.

ENDMODULE.                 " user_command_2124  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_vender_split_scr2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_vender_split_scr2121 INPUT.

  CHECK : g_mode EQ c_charc OR
          g_mode EQ c_charm OR
          g_mode EQ c_charp.

*>송장금액 체크.
  PERFORM check_open_amount.

  IF ztitivk-rtchg IS INITIAL.
    REFRESH: it_ztitivv.  CLEAR: it_ztitivv.
  ELSE.
    READ TABLE it_ztitivv INTO gs_ztitivv WITH KEY split = 1.
    g_subrc = sy-subrc.
    gs_ztitivv-split = 1.
    gs_ztitivv-splam = ztitivk-ivamp - ztitivk-rtchg.
    gs_ztitivv-zlsch = ztitivk-zlsch.
    gs_ztitivv-uzawe = ztitivk-uzawe.
    gs_ztitivv-zterm = ztitivk-zterm.
    gs_ztitivv-zlsch = ztitivk-zlsch.
    gs_ztitivv-mwskz = ztitivk-mwskz.

    IF g_subrc EQ 0.
      DELETE it_ztitivv WHERE split = 1.
    ENDIF.
    APPEND gs_ztitivv TO it_ztitivv.

    CLEAR: gs_ztitivv.
    READ TABLE it_ztitivv INTO gs_ztitivv WITH KEY split = 2.
    g_subrc = sy-subrc.
    gs_ztitivv-split = 2.
    gs_ztitivv-splam = ztitivk-rtchg.
    gs_ztitivv-mwskz = ztitivk-mwskz.
    IF g_subrc EQ 0.
      DELETE it_ztitivv WHERE split = 2.
    ENDIF.
    APPEND gs_ztitivv TO it_ztitivv.

    LOOP AT it_ztitivv.
      IF NOT ( it_ztitivv-split EQ 1 OR
               it_ztitivv-split EQ 2 ).
        DELETE it_ztitivv.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " pai_vender_split_scr2121  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_CHECK_INVOICE_NUMBER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_check_invoice_number INPUT.

  CHECK NOT ( g_mode EQ 'S' OR
              g_mode EQ 'D' OR
              g_mode EQ 'R' ).

  IF ztitivk-vorgang IS INITIAL.
    ztitivk-vorgang = c_char1.
  ENDIF.

  IF NOT ( ztitivk-vorgang EQ c_char1 OR
           ztitivk-vorgang EQ c_char3 ).
*> 문서상태 Fixed value read.
    PERFORM  ddic_domain_value_text_read USING 'MRM_VORGANG'
                                               sy-langu
                                               ztitivk-vorgang
                                               g_ddtext
                                               c_success.
    MESSAGE e305 WITH g_ddtext.
  ENDIF.

  IF ztitivk-prpyn IS INITIAL.
    ztitivk-prpyn = c_chari.
  ENDIF.

*  IF ZTITIVK-ivnum IS INITIAL.
*    PERFORM no_input_check USING 'ZTITIVK' 'IVNUM' c_warning.
*  ENDIF.
*  IF NOT ZTITIVK-ivnum IS INITIAL.
*    SELECT COUNT( * )
*      INTO g_count
*      FROM ZTITIVK
*     WHERE ivnum EQ ZTITIVK-ivnum
*       AND ivono NE ZTITIVK-ivono.
*
*    IF g_count GT 0.
*      MESSAGE w304 WITH ZTITIVK-ivnum 'B/L'.
*    ENDIF.
*  ENDIF.

ENDMODULE.                 " PAI_CHECK_INVOICE_NUMBER  INPUT
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
*&      Module  check_iv_number_chainged  INPUT
*&---------------------------------------------------------------------*
MODULE check_iv_number_chainged INPUT.
  CLEAR: g_ivnum_chk1, g_ivnum_chk2.
ENDMODULE.                 " check_iv_number_chainged  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_iv_number  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_iv_number INPUT.

  CHECK : g_mode EQ c_charc OR
          g_mode EQ c_charm.

  IF g_ivnum_chk1 IS INITIAL.
    IF ztitivk-ivnum IS INITIAL.
      PERFORM no_input_check USING 'ZTITIVK' 'IVNUM' c_warning.
      g_ivnum_chk1 = c_true.
    ENDIF.
  ENDIF.

  IF g_ivnum_chk2 IS INITIAL.
    IF NOT ztitivk-ivnum IS INITIAL.
      SELECT ivnum
        INTO g_ivnum
        FROM ztitivk UP TO 1 ROWS
       WHERE ivnum   EQ   ztitivk-ivnum
         AND ivono   NE   ztitivk-ivono.
      ENDSELECT.

      IF sy-subrc EQ 0.
        MESSAGE w310 WITH ztitivk-ivnum.
        g_ivnum_chk2 = c_true.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " check_iv_number  INPUT
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
*&      Module  help_payment_term  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE help_payment_term INPUT.

  LOOP AT SCREEN.
    IF screen-name EQ 'ZTITIVK-ZTERM'.
      EXIT.
    ENDIF.
  ENDLOOP.

  PERFORM get_f4_for_zterm_dynpro USING ztitivk-zterm.


ENDMODULE.                 " help_payment_term  INPUT
*&---------------------------------------------------------------------*
*&      Module  help_payment_term_scr2123  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE help_payment_term_scr2123 INPUT.

  LOOP AT SCREEN.
    IF screen-name EQ 'ZTISIVVS-ZTERM'.
      EXIT.
    ENDIF.
  ENDLOOP.

  PERFORM get_f4_for_zterm_dynpro USING ztisivvs-zterm.

ENDMODULE.                 " help_payment_term_scr2123  INPUT
*&---------------------------------------------------------------------*
*&      Module  fcode_exit_scr7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fcode_exit_scr7000 INPUT.

  LEAVE TO SCREEN 0.

ENDMODULE.                 " fcode_exit_scr7000  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_7000 INPUT.

  CASE ok_code_popup.
    WHEN 'FEXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'FCOPY'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_7000  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_prepaid_document  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_prepaid_document INPUT.

  CHECK ok_code_popup NE 'FEXIT'.

  IF ztisscrcom-reqno IS INITIAL.
    PERFORM no_input_check USING 'ZTISSCRCOM' 'REQNO' c_error.
  ENDIF.
  CLEAR:ztivrq04.
  SELECT SINGLE *
    FROM ztivrq04
   WHERE reqno EQ  ztisscrcom-reqno.

  IF sy-subrc NE 0.
    MESSAGE e108 WITH ztisscrcom-reqno.
  ELSE.
    CASE ztivrq04-reqty.
      WHEN 'LC'.
*        MESSAGE e015.
        MESSAGE w027 WITH ztisscrcom-reqno.
      WHEN 'TT'.
        IF ztivrq04-anbty IS INITIAL.
          MESSAGE e015.
        ENDIF.

        IF ztivrq04-anbty EQ 'A'.
          MESSAGE e172 WITH ztivrq04-reqno.
        ENDIF.

        IF ztivrq04-rpaid EQ c_true.
          MESSAGE e026.
        ENDIF.
*        if ZTIvrq04-docst ne c_charo.
*          message
*        endif.
      WHEN OTHERS.
        MESSAGE e014 WITH ztivrq04-reqty.
    ENDCASE.
    CASE ztivrq04-docst.
      WHEN 'W' OR 'Y' OR 'O' .
      WHEN OTHERS.
*> 문서상태 Fixed value read.
        PERFORM  ddic_domain_value_text_read USING 'ZTIDOCST1'
                                                   sy-langu
                                                   ztivrq04-docst
                                                   g_ddtext
                                                   c_success.
        MESSAGE s922 WITH g_ddtext.
    ENDCASE.
    IF ztivrq04-dcend EQ 'X'.
      MESSAGE e923 WITH ztivrq04-reqno.
    ENDIF.
    REFRESH: it_reqit_tmp, it_tab.
    CLEAR: it_reqit_tmp, it_tab.

    PERFORM get_lc_document_data TABLES it_reqit_tmp
                                 USING  ztivrq04-reqno
                                        ztivrq04-amdsq
                                        c_error
                                        c_error.

    LOOP AT it_reqit_tmp.
      CLEAR: g_modify, ztivrq00.
      DESCRIBE TABLE it_tab LINES g_count_1.
      PERFORM  get_and_check_lc_data   USING  it_reqit_tmp-reqno
                                              it_reqit_tmp-amdsq
                                              it_reqit_tmp-reqit
                                              g_modify
                                              ztivrq00
                                              g_count_1.

*> L/C data Move
      PERFORM set_prepaid_invoice_data   TABLES it_tab
                                         USING  ztivrq00
                                                ztitivk
                                                it_reqit_tmp.
    ENDLOOP.
*> 선급금 구분자.
    CASE ztivrq04-reqty.
      WHEN c_tt.
        ztitivk-prpyn = c_charp.
      WHEN c_lc.
        ztitivk-prpyn = c_charr.
      WHEN OTHERS.
        ztitivk-prpyn = c_charp.
    ENDCASE.

    LOOP AT it_tab INTO g_tc_2130_wa.
      g_tc_2130_wa-ivmng = g_tc_2130_wa-remng.
      MODIFY it_tab FROM g_tc_2130_wa.
    ENDLOOP.

  ENDIF.

ENDMODULE.                 " check_prepaid_document  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_item_amount_scr2130  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_item_amount_scr2130 INPUT.

  g_menge_request = c_true.

ENDMODULE.                 " pai_item_amount_scr2130  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_read_it_tab  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_read_it_tab INPUT.

  IF it_tab[] IS INITIAL.
    EXIT FROM STEP-LOOP.
  ENDIF.

  DESCRIBE TABLE it_tab LINES g_count.
  g_index = g_old_top_line + sy-stepl - 1.
  CHECK g_index LE tc_2130-lines.
  CHECK g_index LE g_count.

  READ TABLE it_tab INTO g_tc_2130_old INDEX g_index.
  IF sy-subrc NE 0.
    MESSAGE e008(m8) WITH 'PAI_READ_IT_TAB'.
  ENDIF.

ENDMODULE.                 " pai_read_it_tab  INPUT
*&---------------------------------------------------------------------*
*&      Module  help_exchange_rate  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE help_exchange_rate INPUT.

  DATA: l_ukurs   TYPE tcurr-ukurs,
        l_dispaly TYPE xfeld.


  LOOP AT SCREEN.
    IF screen-name EQ 'ZTITIVK-KURSF'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF screen-input EQ '1'.
    l_dispaly = ' '.
  ELSE.
    l_dispaly = c_true.
  ENDIF.

  l_ukurs = ztitivk-kursf.


  CALL FUNCTION 'F4_EXCHANGE_RATE'
    EXPORTING
      type_of_rate     = 'M'
      date             = ztitivk-wwert
      foreign_currency = ztitivk-waers
      local_currency   = t001-waers
      display_only     = l_dispaly
    CHANGING
      kurs             = l_ukurs
    EXCEPTIONS
      OTHERS           = 0.

  ztitivk-kursf = l_ukurs.

ENDMODULE.                 " help_exchange_rate  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr2121_check_payment_term  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_scr2121_check_payment_term INPUT.

  g_zterm_modify = c_true.

ENDMODULE.                 " pai_scr2121_check_payment_term  INPUT
