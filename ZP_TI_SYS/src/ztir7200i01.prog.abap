************************************************************************
* Title         :  ZTIR7200I01                                         *
*                                                                      *
* Description   : 수입 인수증관리 PAI Include                          *
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

  MOVE-CORRESPONDING ztisacit TO g_tc_2130_wa.

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
                                               ztitgrk-lifnr
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

*> call이 되었을 경우.
  IF sy-calld EQ c_true.
    IF NOT g_tcode  IS INITIAL.
      IF sy-tcode EQ c_create_d OR
         g_tcode1 EQ c_create_d.
        MOVE: 'ZTICOPY' TO ok_code,
              'ZTICOPY' TO sy-ucomm.
      ENDIF.
    ENDIF.
  ENDIF.

**> Input fields check
*  IF NOT ok_code EQ 'ZTICOPY'.
*    IF ztisscrcom-vatno IS INITIAL AND
*       ztisscrcom-ebeln IS INITIAL AND
*       ztisscrcom-reqno IS INITIAL AND
*       ztisscrcom-opnno IS INITIAL.
**    IF ztisscrcom-vatno IS INITIAL.
*      MESSAGE e913.
*    ENDIF.
*  ENDIF.

*  IF NOT zmisscrcom-ebeln IS INITIAL.
  PERFORM p3000_set_data_of_screen.

  CLEAR: g_count.
  IF ok_code EQ 'ZTICOPY'.
*> 세금계산서 문서를 사용하지 않을 경우.
    PERFORM  get_invoice_data.
  ELSE.
**> 세금계산서번호 입력시 로직 --> 향후 추가.
*    IF NOT ztisscrcom-vatno IS INITIAL.
*      PERFORM  get_locrct_by_vat_no USING ztisscrcom-vatno
*                                          ztisscrcom-ebeln
*                                          ztisscrcom-opnno
*                                          ztisscrcom-reqno
*                                          ztisscrcom-amdsq.
*    ENDIF.
  ENDIF.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM p1102_authorization_check USING ztitack-bukrs.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*>수입통관문서의 종류/상태를 검증.
  PERFORM check_request_of_custom.
*>아이템 기타 정보 Read.
  PERFORM set_others_fields_by_items.
*>Set 입고 헤더용 기초 value
  PERFORM  set_ac_initial_data  USING ztitack.

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
                                               ztitack+3(10).

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

  IF ztisscrcom-acdno IS INITIAL AND
     ztisscrcom-accno IS INITIAL AND
     ztisscrcom-opnno IS INITIAL.
    MESSAGE e913.
  ENDIF.

  CLEAR: g_count.
*  IF ztisscrcom-acdno IS INITIAL.
*    PERFORM  get_gr_int_no_by_bl_no      USING ztisscrcom-iblno
*                                               ztisscrcom-igrno
*                                               c_false.
*  ENDIF.
*  IF ztisscrcom-igrno IS INITIAL.
*    PERFORM  get_gr_int_no_by_cc_no      USING ztisscrcom-iccno
*                                               ztisscrcom-igrno
*                                               c_false.
*  ENDIF.
*
  IF NOT ztisscrcom-acdno IS INITIAL.
    CALL FUNCTION 'Z_TI_GET_ACCEPTANCE_DOCUMENT'
      EXPORTING
        im_acdno         = ztisscrcom-acdno
      IMPORTING
        ex_ztitack       = ztitack
*        EX_SUBRC         =
      TABLES
        et_ztitacf       = it_ztisacf
        et_ztitac1       = it_ztisac1
        et_ztitacp       = it_tab
      EXCEPTIONS
        not_found        = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> authorization
    PERFORM get_authorization_bukrs.
    IF l_yn NE 'A'.
    IF ztitack-bukrs <> a_bukrs.
      MESSAGE e998 WITH ztitack-bukrs  '권한이 없습니다!'..
    ENDIF.
    endif.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*> 변경 문서 관리를 위한 이전데이타를 Move.
     *ztitack   = ztitack.
*> Item Data.
    LOOP AT it_tab INTO g_tc_2130_wa.
      MOVE-CORRESPONDING g_tc_2130_wa TO : xztitacp,
                                           yztitacp.
      APPEND : xztitacp, yztitacp.
      MODIFY it_tab FROM g_tc_2130_wa.
    ENDLOOP.
*> 회계문서 Data
    LOOP AT it_ztisacf.
      MOVE-CORRESPONDING it_ztisacf TO : xztitacf,
                                         yztitacf.
      APPEND : xztitacf, yztitacf.
      MODIFY it_ztisacf.
    ENDLOOP.
*> Segment Data
    LOOP AT it_ztisac1.
      MOVE-CORRESPONDING it_ztisac1 TO : xztitac1,
                                         yztitac1.
      APPEND : xztitac1, yztitac1.
      MODIFY it_ztisac1.
    ENDLOOP.

*>업무영역별 Status Check.
    PERFORM check_document_status.

*>아이템 기타 정보 Read.
    PERFORM set_others_fields_by_items.
*>화면상의 Text를 Master Data 등에서 Read.
    PERFORM get_others_text_by_master_data.
*>조회모드가 아닌 경우 Lock.
    IF g_mode NE c_chars.
      PERFORM set_ac_lock_object   USING ztitack-acdno
                                         c_lock
                                         c_error
                                         g_modify.
    ENDIF.
*> 회계문서 테이블 View용.
    PERFORM  set_invoice_document_screen.

*> Document History 조회.
    PERFORM get_document_history   TABLES it_dochis
                                   USING  g_document
                                          ztitack-acdno
                                          '00'
                                          g_history.

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

**> 문서상태 Fixed value read.
  PERFORM  ddic_domain_value_text_read USING 'ZTIELDFN'
                                             sy-langu
                                             ztitack-eldfn
                                             g_ddtext
                                             c_success.
  l_ddtext = g_ddtext.

*.변경/삭제일 경우 오류 발생
  IF ( g_mode = c_charm ) OR ( g_mode = c_chard ).
    IF ztitack-eldfn EQ c_chara OR
       ztitack-eldfn EQ c_charb OR
       ztitack-eldfn EQ c_charc.
*       ztitack-eldfn EQ c_charx OR
*       ztitack-eldfn EQ c_chary OR
*       ztitack-eldfn EQ c_charz.
      MESSAGE e919 WITH g_ddtext.
    ENDIF.
  ENDIF.

  MESSAGE s922 WITH l_ddtext.

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

**> 인수증 발급번호.
*  IF ztitack-accno IS INITIAL.
*    PERFORM no_input_check USING 'ZTITACK' 'ACCNO' c_error.
*  ENDIF.
*
*> 인수증 발급일.
  IF ztitack-issdt IS INITIAL.
    PERFORM no_input_check USING 'ZTITACK' 'ISSDT' c_error.
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
*&      Module  CHECK_INPUT_VALUE_SCR2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_input_value_scr2121 INPUT.

  CHECK : g_mode  EQ  c_charc OR
          g_mode  EQ  c_charm OR
          g_mode  EQ  c_chara OR
          g_mode  EQ  c_chary OR
          g_mode  EQ  c_charp.

  IF ztitack-acdat IS INITIAL.
    PERFORM  no_input_check USING 'ZTITACK' 'ACDAT' c_error.
  ENDIF.
*

*ZTITACK-VENNM
*block1
*BLOCK2
*block3
*ZTITACK-ACAMT
*ZTITACK-ACAMTC
*ZTITACK-ACDAT
*ZTITACK-ACKMT
*ZTITACK-ACKMTC
*ZTITACK-AEXDT
*ZTITACK-DELDT
*ZTITACK-EXCRT
*ZTITACK-EXPDT
*ZTITACK-LIFNR
*ZTITACK-LOBBR
*ZTITACK-LOBCD
*ZTITACK-OEXRT
*ZTITACK-OPAMK
*ZTITACK-OPAMT
*ZTITACK-OPAMTC
*ZTITACK-OPBID
*ZTITACK-OPBNM
*ZTITACK-OTCO1
*ZTITACK-OTCO2
*ZTITACK-OTCO3
*ZTITACK-OTCO4
*ZTITACK-OTCO5
*ZTITACK-REFE1
*ZTITACK-REFE2
*ZTITACK-REFE3
*ZTITACK-REFE4
*ZTITACK-REFE5
*ZTITACK-TOAMTC
*ZTITACK-VENNM


ENDMODULE.                 " CHECK_INPUT_VALUE_SCR2121  INPUT
*&---------------------------------------------------------------------*
*&      Module  help_exchange_rate  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE help_exchange_rate INPUT.

  LOOP AT SCREEN.
    IF screen-name EQ 'ZTITACK-EXCRT'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF screen-input EQ '1'.
    l_dispaly = ' '.
  ELSE.
    l_dispaly = c_true.
  ENDIF.

  l_ukurs = ztitack-excrt.


  CALL FUNCTION 'F4_EXCHANGE_RATE'
    EXPORTING
      type_of_rate     = 'M'
      date             = ztitack-issdt
      foreign_currency = ztitack-acamtc
      local_currency   = ztitack-ackmtc
      display_only     = l_dispaly
    CHANGING
      kurs             = l_ukurs
    EXCEPTIONS
      OTHERS           = 0.

  ztitack-excrt = l_ukurs.

ENDMODULE.                 " help_exchange_rate  INPUT

*&---------------------------------------------------------------------*
*&      Module  help_exchange_rate1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE help_exchange_rate1 INPUT.

  LOOP AT SCREEN.
    IF screen-name EQ 'ZTITACK-OEXRT'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF screen-input EQ '1'.
    l_dispaly = ' '.
  ELSE.
    l_dispaly = c_true.
  ENDIF.

  l_ukurs = ztitack-oexrt .

  CALL FUNCTION 'F4_EXCHANGE_RATE'
    EXPORTING
      type_of_rate     = 'M'
      date             = ztitack-issdt
      foreign_currency = ztitack-acamtc
      local_currency   = ztitack-ackmtc
      display_only     = l_dispaly
    CHANGING
      kurs             = l_ukurs
    EXCEPTIONS
      OTHERS           = 0.

  ztitack-oexrt = l_ukurs.

ENDMODULE.                 " help_exchange_rate1  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2111  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2111 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.

ENDMODULE.                 " user_command_2111  INPUT
