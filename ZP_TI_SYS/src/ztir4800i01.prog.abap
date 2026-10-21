************************************************************************
* Title         : ZTIR4800I01                                          *
*                                                                      *
* Description   : 보세구역 반출관리 PAI Module Include                 *
*                                                                      *
* Creation Date : 2004/12/21                                           *
*                                                                      *
* Author        : Seog Bong, KANG                                      *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*&---------------------------------------------------------------------*
*&      Module  tc_2130_modify  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_2130_modify INPUT.

  MOVE-CORRESPONDING ztisbdit TO g_tc_2130_wa.
*
  IF g_tc_2130_wa-bdqty GT g_tc_2130_wa-bdqtyl.
    CLEAR: g_menget.
    WRITE g_tc_2130_wa-bdqtyl TO g_menget(15) UNIT g_tc_2130_wa-meins.
    CONCATENATE g_menget g_tc_2130_wa-meins INTO g_menget.
    MESSAGE e484 WITH g_menget.
  ENDIF.
*
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
                                USING  ztitbdk.
*> 아이템 정보 display
  PERFORM  display_infomation_by_items USING   'TC_2130'
                                               'IT_TAB'
                                               'FLAG'
                                               ztitrqk-lifnr
                                       CHANGING ok_code.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.

ENDMODULE.                 " tc_2130_user_command  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_type_of_request  INPUT
*&---------------------------------------------------------------------*
*  개설요청 문서 종류 체크
*----------------------------------------------------------------------*
MODULE check_type_of_request INPUT.

  CHECK: g_mode EQ c_charc OR
         g_mode EQ c_charm.

  IF ztitrqk-reqty IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITRQK' 'REQTY'.
  ELSE.
    PERFORM check_domain_values USING 'ZTIREQTY'
                                      ztitrqk-reqty.
*> 수입의뢰 종류가 변경된 경우.
    IF ztisscrcom-reqty NE ztitrqk-reqty.
      PERFORM get_domain_value_text
                  USING
                     'ZTIREQTY'
                     ztitrqk-reqty
                     g_text32.
      MESSAGE w112 WITH g_text32.
      ztisscrcom-reqty = ztitrqk-reqty.
    ENDIF.
  ENDIF.

ENDMODULE.                 " check_type_of_request  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr0100_check_input_fields  INPUT
*&---------------------------------------------------------------------*
MODULE pai_scr0100_check_input_fields INPUT.
*> EXIT확인.
  PERFORM  check_program_exit_command.

  IF ztisscrcom-iccno IS INITIAL AND
     ztisscrcom-iblno IS INITIAL AND
     ztisscrcom-blnum IS INITIAL.
    MESSAGE e913.
  ENDIF.

  CLEAR: g_count.
  IF ztisscrcom-iccno IS INITIAL.
    IF ztisscrcom-iblno IS INITIAL.
      PERFORM  get_iccno_by_bl_number  USING ztisscrcom-blnum
                                             ztisscrcom-iccno
                                             ztisscrcom-iccsq
                                             c_false.
    ELSE.
      PERFORM  get_iccno_by_iblno      USING ztisscrcom-iblno
                                             ztisscrcom-iccno
                                             ztisscrcom-iccsq
                                             c_false.
    ENDIF.
  ENDIF.

  IF ztisscrcom-iblno IS INITIAL AND
     ztisscrcom-blnum IS INITIAL AND
     ztisscrcom-iccno IS INITIAL.
    MESSAGE e913.
  ENDIF.

  IF NOT ztisscrcom-iccno IS INITIAL.
    SELECT SINGLE *
      FROM ztitcck
     WHERE iccno EQ ztisscrcom-iccno
       AND iccsq EQ ( SELECT MAX( iccsq )
                        FROM ztitcck
                       WHERE iccno EQ ztisscrcom-iccno ).
    IF sy-subrc <> 0.
      MESSAGE e441 WITH ztisscrcom-iccno.
    ENDIF.
    SELECT SINGLE *
      FROM ztitblk
     WHERE iblno EQ ztitcck-iblno.
    IF sy-subrc NE 0.
      MESSAGE e200 WITH ztisscrcom-iblno.
    ELSE.
      IF ztitblk-rptty NE c_charn.
        MESSAGE e248 WITH ztisscrcom-iblno.
      ENDIF.
    ENDIF.

    SELECT SINGLE *
      FROM ztitbik
     WHERE ibino EQ ( SELECT max( ibino )
                        FROM ztitbik
                       WHERE iblno EQ ztitcck-iblno ).
    IF sy-subrc NE 0.
      MESSAGE e611 WITH ztisscrcom-iblno.
    ENDIF.

*>문서 초기값 Setting
    PERFORM set_document_initial_value.
*>업무영역별 Status Check.
    PERFORM check_document_status.
*>아이템 기타 정보 Read.
    PERFORM set_others_fields_by_items.
*>화면상의 Text를 Master Data 등에서 Read.
    PERFORM get_others_text_by_master_data.
*>아이템 번호를 생성함.
    PERFORM set_item_number_build TABLES it_tab
                                  USING  ztitbdk.

*>조회모드가 아닌 경우 Lock.
    IF g_mode NE c_chars.
      PERFORM set_bd_lock_object   USING ztitbdk-iccno
                                         ztitbdk-bdseq
                                         c_lock
                                         c_error
                                         g_modify.
    ENDIF.
*> Document History 조회.
    PERFORM get_document_history   TABLES it_dochis
                                   USING  'CC'
                                          ztitbdk-iccno
                                          '00'
                                          g_history.

  ELSE.
    MESSAGE e902.
  ENDIF.

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
                                               ztitbdk+3(13).

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

  IF ztisscrcom-iccno IS INITIAL.
    MESSAGE e913.
  ENDIF.

  IF NOT ztisscrcom-iccno IS INITIAL.
    IF ztisscrcom-bdseq IS INITIAL.
      SELECT MAX( bdseq )
        INTO ztisscrcom-bdseq
        FROM ztitbdk
       WHERE iccno EQ ztisscrcom-iccno.
    ENDIF.
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

*> 변경 문서 관리를 위한 이전데이타를 Move.
     *ztitbdk   = ztitbdk.

*> 변경 문서 관리를 위한 이전데이타를 Move (Item Data).
    REFRESH: xztitbdp, yztitbdp.
    LOOP AT it_tab INTO g_tc_2130_wa.
      MOVE-CORRESPONDING g_tc_2130_wa TO : xztitbdp,
                                           yztitbdp.
      APPEND : xztitbdp, yztitbdp.
    ENDLOOP.

*>업무영역별 Status Check.
    PERFORM check_document_status.
*>아이템 기타 정보 Read.
    PERFORM set_others_fields_by_items.
*>화면상의 Text를 Master Data 등에서 Read.
    PERFORM get_others_text_by_master_data.
*>조회모드가 아닌 경우 Lock.
    IF g_mode NE c_chars.
      PERFORM set_bd_lock_object   USING ztitbdk-iccno
                                         ztitbdk-bdseq
                                         c_lock
                                         c_error
                                         g_modify.
    ENDIF.
*> Document History 조회.
    PERFORM get_document_history   TABLES it_dochis
                                   USING  'CC'
                                          ztitbdk-iccno
                                          '00'
                                          g_history.
    ztisscrcom-reqty = 'BO'.
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

*  DATA: l_ddtext LIKE g_ddtext.
*
**> 문서상태 Fixed value read.
*  PERFORM  ddic_domain_value_text_read USING 'ZTIDOCST'
*                                             sy-langu
*                                             ZTITRQS-docst
*                                             g_ddtext
*                                             c_success.
*  l_ddtext = g_ddtext.
*
**> Status check.
*  CASE ZTITRQS-docst.
*    WHEN space.  ">의뢰대상.
*      IF g_mode EQ c_chara OR
*         g_mode EQ c_chary OR
*         g_mode EQ c_charo.
*        MESSAGE e919 WITH g_ddtext.
*      ENDIF.
*    WHEN 'C'.    ">수입의뢰.
*      IF g_mode EQ c_chary OR g_mode EQ c_charo.
*        MESSAGE e919 WITH g_ddtext.
*      ENDIF.
*      IF g_mode EQ c_charm.
*        MESSAGE w921 WITH g_ddtext.
*      ENDIF.
*    WHEN 'A'.    ">접수완료.
*      IF g_mode EQ c_charm OR g_mode EQ c_chard OR
*         g_mode EQ c_charo.
*        MESSAGE e919 WITH g_ddtext.
*      ENDIF.
*      IF g_mode EQ c_chara.
*        MESSAGE w921 WITH g_ddtext.
*      ENDIF.
*    WHEN 'Y'.    ">개설신청.
*      IF g_mode EQ c_charm OR g_mode EQ c_chard OR
*         g_mode EQ c_chara.
*        MESSAGE e919 WITH g_ddtext.
*      ENDIF.
*      IF g_mode EQ c_chary OR g_mode EQ c_charo.
*        IF NOT ZTITRQS-sndst IS INITIAL.
**> EDI 송수신 상태 Fixed value read.
*          PERFORM  ddic_domain_value_text_read
*                                      USING 'ZTISNDST'
*                                             sy-langu
*                                             ZTITRQS-sndst
*                                             g_ddtext
*                                             c_success.
*          IF g_mode EQ c_chary.
*            IF ZTITRQS-sndst EQ c_charw.
*              MESSAGE w920 WITH g_ddtext.
*            ELSE.
*              MESSAGE e919 WITH g_ddtext.
*            ENDIF.
*          ENDIF.
*          IF g_mode EQ c_charo.
*            MESSAGE w920 WITH g_ddtext.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    WHEN 'O'.    ">개설완료.
*      IF g_mode EQ c_charm OR g_mode EQ c_chard OR
*         g_mode EQ c_chara OR g_mode EQ c_chary.
*        MESSAGE e919 WITH g_ddtext.
*      ENDIF.
*    WHEN 'R'.    ">접수반려.
*      IF g_mode EQ c_chary OR g_mode EQ c_charo.
*        MESSAGE e919 WITH g_ddtext.
*      ENDIF.
*    WHEN OTHERS.
*  ENDCASE.
*
*  MESSAGE s922 WITH l_ddtext.
*
*  IF ZTITRQK-dcend EQ 'X'.
*    MESSAGE s923.
*  ENDIF.

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
*&      Module  pai_scr2121_check_input  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_scr2121_check_input INPUT.

ENDMODULE.                 " pai_scr2121_check_input  INPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_disable_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_2130_disable_field_attr OUTPUT.

  CHECK : g_mode EQ c_charc OR
          g_mode EQ c_charm .

  LOOP AT SCREEN.
    IF screen-name EQ 'G_TC_2130_WA-FLAG'.
      screen-input     = c_char1.
      screen-invisible = c_char0.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " tc_2130_disable_field_attr  OUTPUT
