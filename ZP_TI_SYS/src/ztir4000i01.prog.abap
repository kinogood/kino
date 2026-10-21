************************************************************************
* Title         :  ZTIR0000I01                                         *
*                                                                      *
* Description   : 수입 C/C 관리 PAI Include                            *
*                                                                      *
* Creation Date : 2003/08/18                                           *
*                                                                      *
* Author        : Seung Jun, Lee                                       *
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

  MOVE-CORRESPONDING ztisccit TO g_tc_2130_wa.

*  IF g_tc_2130_wa-rqmng GT g_tc_2130_wa-rqmngl.
*    CLEAR: g_menget.
*    WRITE g_tc_2130_wa-rqmngl TO g_menget(15) UNIT g_tc_2130_wa-meins.
*    CONCATENATE g_menget g_tc_2130_wa-meins INTO g_menget.
*    MESSAGE e005 WITH g_menget.
*  ENDIF.

*> 정가 계산.
  CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
    EXPORTING
      peinh = g_tc_2130_wa-peinh
      bpumz = g_tc_2130_wa-bpumz
      bpumn = g_tc_2130_wa-bpumn
      menge = g_tc_2130_wa-ccmng
      netpr = g_tc_2130_wa-netpr
    CHANGING
      netwr = g_tc_2130_wa-netwr.

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
                                USING  ztitcck.
*> 아이템 정보 display
  PERFORM  display_infomation_by_items USING   'TC_2130'
                                               'IT_TAB'
                                               'FLAG'
                                               ztitcck-lifnr
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

*  CHECK: g_mode EQ c_charc OR
*         g_mode EQ c_charm.
*
*  IF ZTITRQK-reqty IS INITIAL.
*    PERFORM no_input(sapfmmex) USING 'ZTITRQK' 'REQTY'.
*  ELSE.
*    PERFORM check_domain_values USING 'ZTIREQTY'
*                                      ZTITRQK-reqty.
**> 수입의뢰 종류가 변경된 경우.
*    IF ZTIsscrcom-reqty NE ZTITRQK-reqty.
*      PERFORM get_domain_value_text
*                  USING
*                     'ZTIREQTY'
*                     ZTITRQK-reqty
*                     g_text32.
*      MESSAGE w112 WITH g_text32.
*      ZTIsscrcom-reqty = ZTITRQK-reqty.
*    ENDIF.
*  ENDIF.

ENDMODULE.                 " check_type_of_request  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr0100_check_input_fields  INPUT
*&---------------------------------------------------------------------*
MODULE pai_scr0100_check_input_fields INPUT.
*> EXIT확인.
  PERFORM  check_program_exit_command.

*>>
  IF ztisscrcom-iblno IS INITIAL AND
     ztisscrcom-blnum IS INITIAL AND
     ztisscrcom-icrno IS INITIAL.
    MESSAGE e913.
  ENDIF.

  IF ztisscrcom-icrno IS INITIAL.
    IF ztisscrcom-iblno IS INITIAL.
      PERFORM  get_bl_int_no_by_bl_number  USING ztisscrcom-blnum
                                                 ztisscrcom-iblno
                                                 c_false.
    ENDIF.
  ELSE.

  ENDIF.

  IF ztisscrcom-iblno IS INITIAL AND
     ztisscrcom-blnum IS INITIAL AND
     ztisscrcom-icrno IS INITIAL.
    MESSAGE e913.
  ENDIF.

*> Set Initial fields
  PERFORM p3000_set_data_of_screen.

  CLEAR: g_count.
  IF NOT ztisscrcom-iblno IS INITIAL.
    CLEAR: ztisscrcom-iblit.
* b/l상태 확인.add.
    SELECT SINGLE * FROM ztitblk
     WHERE iblno EQ ztisscrcom-iblno.
    IF ztitblk-crlse EQ 'B'.
      MESSAGE ID 'ZMTI00' TYPE 'E' NUMBER 321 WITH '수입신고'.
    ENDIF.

    PERFORM get_bl_document_data    TABLES it_bl
                                    USING  ztisscrcom-iblno
                                           ztisscrcom-iblit
                                           c_error
                                           c_error.
  ENDIF.
  IF ztitig00-ccrqm NE c_charn.
    PERFORM  get_custom_imprt_req.
  ELSE.
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
                                                ztitcck
                                                ztitccp
                                                it_bl.
    ENDLOOP.
  ENDIF.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM p1102_authorization_check USING ztitcck-bukrs.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*>아이템 기타 정보 Read.
  PERFORM set_others_fields_by_items.
*>화면상의 Text를 Master Data 등에서 Read.
  PERFORM get_others_text_by_master_data.
*>Set bl data ---> cc data.
  IF ztitig00-ccrqm EQ c_charn.
    PERFORM move_bl_fields_to_cc_fields.
  ENDIF.
************************************************************************
*>관세청 고시환율을 구함.
  PERFORM  get_custom_exchange_rate.
*>란/행 Refresh
  PERFORM  set_row_columns_refresh.
*>관세금액 등 계산.
  PERFORM  calc_customs_amount.
*>송장금액 체크.
  PERFORM check_open_amount.
*> 기타 Master 조회.
  PERFORM  get_import_vendors_text  USING c_success.

  IF ztitig00-ccrqm NE c_charn.
    PERFORM  set_cc_lock_object  USING ztitcck-iccno
                                       '00'
                                       '00000'
                                       c_lock
                                       c_error
                                       g_modify.

*> Document History 조회.
    PERFORM get_document_history   TABLES it_dochis
                                   USING  'CR'
                                          ztitcck-iccno
                                          ztitcck-iccsq
                                          g_history.
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
                                               ztitrqs+3(12).

  IF ztitig00-ccdcl IS INITIAL.
    g_tabstrip-pressed_tab = c_tabstrip-tab4.
  ENDIF.

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


*  CLEAR: g_count.
*  IF ZTIsscrcom-reqno IS INITIAL.
*    PERFORM  get_request_no_by_po_number USING ZTIsscrcom-ebeln
*                                               ZTIsscrcom-reqno
*                                               ZTIsscrcom-amdsq
*                                               c_false.
*  ENDIF.
*
*  IF ZTIsscrcom-reqno IS INITIAL.
*    PERFORM  get_request_no_by_open_number USING ZTIsscrcom-opnno
*                                                 ZTIsscrcom-reqno
*                                                 ZTIsscrcom-amdsq
*                                                 c_false.
*  ENDIF.

  IF NOT ztisscrcom-iccno IS INITIAL.
    CALL FUNCTION 'Z_TI_GET_CUSTOM_IMPORT'
      EXPORTING
        iccno     = ztisscrcom-iccno
        iccsq     = ztisscrcom-iccsq
      IMPORTING
        ztitcck   = ztitcck
      TABLES
        ztitccp   = it_tab
        ztitcc1   = xztitcc1
        ztitcc2   = xztitcc2
        ztitcc3   = xztitcc3
        ztitcc4   = xztitcc4 "기능개선 XXXXX
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
    IF ztitcck-bukrs <> a_bukrs.
      MESSAGE e998 WITH ztitcck-bukrs  '권한이 없습니다!'..
    ENDIF.
    endif.
** JS전선 회사코드 2007/04 KSH --------------------------------------

    g_tc_2211_itab[] = xztitcc1[].


*> 변경 문서 관리를 위한 이전데이타를 Move.
     *ztitcck   = ztitcck.

    yztitcc1[] = xztitcc1[].
    yztitcc2[] = xztitcc2[].
    yztitcc3[] = xztitcc3[].
    yztitcc4[] = xztitcc4[]. "기능개선 XXXXX

*> 변경 문서 관리를 위한 이전데이타를 Move (Item Data).
    REFRESH: xztitccp, yztitccp.
    LOOP AT it_tab INTO g_tc_2130_wa.
      MOVE-CORRESPONDING g_tc_2130_wa TO : xztitccp,
                                           yztitccp.
      APPEND : xztitccp, yztitccp.
    ENDLOOP.

    REFRESH: g_tc_2211_itab, g_tc_2212_itab, g_tc_2212_1_itab.
    LOOP AT xztitcc1.
      MOVE-CORRESPONDING xztitcc1 TO g_tc_2211_wa.
      APPEND g_tc_2211_wa TO g_tc_2211_itab.
    ENDLOOP.

    LOOP AT xztitcc2.
      MOVE-CORRESPONDING xztitcc2 TO g_tc_2212_wa.
      APPEND g_tc_2212_wa TO g_tc_2212_itab.
    ENDLOOP.

    LOOP AT xztitcc3.
      MOVE-CORRESPONDING xztitcc3 TO g_tc_2212_1_wa.
      APPEND g_tc_2212_1_wa TO g_tc_2212_1_itab.
    ENDLOOP.

*-> 기능개선 XXXXX_요건확인(4G)
    LOOP AT xztitcc4.
      MOVE-CORRESPONDING xztitcc4 TO g_tc_2212_2_wa.
      APPEND g_tc_2212_2_wa TO g_tc_2212_2_itab.
    ENDLOOP.
*<- 기능개선 XXXXX

*>업무영역별 Status Check.
    PERFORM check_document_status.
*>아이템 기타 정보 Read.
    PERFORM set_others_fields_by_items.
*>화면상의 Text를 Master Data 등에서 Read.
    PERFORM get_others_text_by_master_data.
*>조회모드가 아닌 경우 Lock.
    IF g_mode NE c_chars.
      PERFORM set_cc_lock_object   USING ztitcck-iccno
                                         '00'
                                         '00000'
                                         c_lock
                                         c_error
                                         g_modify.
    ENDIF.

*> Document History 조회.
    PERFORM get_document_history   TABLES it_dochis
                                   USING  g_document
                                          ztitcck-iccno
                                          ztitcck-iccsq
                                          g_history.

*> Cost Document History 조회.
    PERFORM get_cost_document      TABLES it_costdoc
                                   USING  g_document
                                          ztitcck-bukrs
                                          ztitcck-iccno
                                          '00'
                                          g_history_cost.

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

  CALL FUNCTION 'Z_TI_OTHERS_TEXT_EXPORT'
    EXPORTING
      lcity  = c_char7
      mode   = g_mode
    TABLES
      it_tab = it_lctext.

ENDMODULE.                 " pAI_SET_scr2210_sub1_subscreen  INPUT

*&---------------------------------------------------------------------*
*&      Module  pAI_SET_scr2210_sub2_subscreen  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_set_scr2210_sub2_subscreen INPUT.

  g_call_prog        =  c_common_prog.
  g_call_subscreen   =  c_scr0300.

  CALL FUNCTION 'Z_TI_OTHERS_TEXT_EXPORT'
    EXPORTING
      lcity  = c_char8
      mode   = g_mode
    TABLES
      it_tab = it_lctext.

ENDMODULE.                 " pAI_SET_scr2210_sub2_subscreen  INPUT
*&---------------------------------------------------------------------*
*&      Module  pAI_SET_scr2210_sub3_subscreen  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_set_scr2210_sub3_subscreen INPUT.

  g_call_prog        =  c_common_prog.
  g_call_subscreen   =  c_scr0300.

  CALL FUNCTION 'Z_TI_OTHERS_TEXT_EXPORT'
    EXPORTING
      lcity  = c_char9
      mode   = g_mode
    TABLES
      it_tab = it_lctext.

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
*>  input module for tc 'TC_2211'. do not change this line!
*>  modify table
*&---------------------------------------------------------------------*
MODULE tc_2211_modify INPUT.

  MOVE-CORRESPONDING ztitcc1 TO g_tc_2211_wa.
  MODIFY g_tc_2211_itab  FROM  g_tc_2211_wa
                         INDEX tc_2211-current_line.
  IF sy-subrc NE 0.
    APPEND g_tc_2211_wa TO g_tc_2211_itab.
  ENDIF.
*
ENDMODULE.                    "TC_2211_modify INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2211'. do not change this line!
*> mark table
*&---------------------------------------------------------------------*
MODULE tc_2211_mark INPUT.
  IF tc_2211-line_sel_mode = 1 AND
     g_tc_2211_wa-flag = 'X'.
    LOOP AT g_tc_2211_itab INTO g_tc_2211_wa
      WHERE flag = 'X'.
      g_tc_2211_wa-flag = ''.
      MODIFY g_tc_2211_itab
        FROM g_tc_2211_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tc_2211_wa-flag = 'X'.
  ENDIF.
  MODIFY g_tc_2211_itab
    FROM g_tc_2211_wa
    INDEX tc_2211-current_line
    TRANSPORTING flag.
ENDMODULE.                    "TC_2211_mark INPUT

*&---------------------------------------------------------------------*
*>  input module for tc 'TC_0300'. do not change this line!
*>  process user command
*&---------------------------------------------------------------------*
MODULE tc_2211_user_command INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.

  ok_code = sy-ucomm.

  PERFORM user_ok_tc USING      'TC_2211'
                                'G_TC_2211_ITAB'
                                'FLAG'
                       CHANGING ok_code.
  sy-ucomm = ok_code.

  IF ok_code EQ 'LINE_SELECT'.
*> 기존 데이타 삭제.
    IF NOT ztiscc01-csseq IS INITIAL.
      DELETE g_tc_2211_itab   WHERE csseq = ztiscc01-csseq.
      DELETE g_tc_2212_itab   WHERE csseq = ztiscc01-csseq.
      DELETE g_tc_2212_1_itab WHERE csseq = ztiscc01-csseq.
      DELETE g_tc_2212_2_itab WHERE csseq = ztiscc01-csseq. "기능개선 XXXXX
*> 신규데이타 Insert.
      MOVE-CORRESPONDING ztiscc01 TO g_tc_2211_wa.
      APPEND g_tc_2211_wa TO g_tc_2211_itab.

      LOOP AT g_tc_2212_tmp   INTO g_tc_2212_wa.
        APPEND g_tc_2212_wa TO g_tc_2212_itab.
      ENDLOOP.

      LOOP AT g_tc_2212_1_tmp INTO g_tc_2212_1_wa.
        APPEND g_tc_2212_1_wa TO g_tc_2212_1_itab.
      ENDLOOP.
*-> 기능개선 XXXXX_요건확인서(4G) 신규데이터 INSERT
      LOOP AT g_tc_2212_2_tmp INTO g_tc_2212_2_wa.
        APPEND g_tc_2212_2_wa TO g_tc_2212_2_itab.
      ENDLOOP.
*<- 기능개선 XXXXX
      SORT g_tc_2211_itab BY csseq.
    ENDIF.
*> Temp Table refresh.
    CLEAR: g_tc_2212_copied.
    REFRESH CONTROL 'TC_2212'   FROM SCREEN '2212'.

    CLEAR: g_tc_2212_1_copied.
    REFRESH CONTROL 'TC_2212_1' FROM SCREEN '2212'.

*-> 기능개선 XXXXX_요건확인서(4G) 신규데이터 INSERT
    CLEAR: g_tc_2212_2_copied.
    REFRESH CONTROL 'TC_2212_2' FROM SCREEN '2212'.
*<- 기능개선 XXXXX

    REFRESH: g_tc_2212_tmp, g_tc_2212_1_tmp,
             g_tc_2212_2_tmp. "기능개선 XXXXX.
    CLEAR: ztiscc01, g_csseq.

    GET CURSOR LINE g_findline.
    IF sy-subrc EQ 0.
      g_findline = g_findline + tc_2211-top_line - 1.
      READ TABLE g_tc_2211_itab INTO g_tc_2211_wa INDEX g_findline.
      IF sy-subrc EQ 0.
        g_csseq = g_tc_2211_wa-csseq.
        MOVE-CORRESPONDING: g_tc_2211_wa TO ztiscc01,
                            g_tc_2211_wa TO ztitcc1.

        LOOP AT g_tc_2212_itab INTO g_tc_2212_wa
                               WHERE csseq EQ ztiscc01-csseq.
          APPEND g_tc_2212_wa TO g_tc_2212_tmp.
        ENDLOOP.
        LOOP AT g_tc_2212_1_itab INTO g_tc_2212_1_wa
                               WHERE csseq EQ ztiscc01-csseq.
          APPEND g_tc_2212_1_wa TO g_tc_2212_1_tmp.
        ENDLOOP.
*-> 기능개선 XXXXX_요건확인서(4G) 신규데이터 INSERT
        LOOP AT g_tc_2212_2_itab INTO g_tc_2212_2_wa
                               WHERE csseq EQ ztiscc01-csseq.
          APPEND g_tc_2212_2_wa TO g_tc_2212_2_tmp.
        ENDLOOP.
*<- 기능개선 XXXXX
      ENDIF.
    ENDIF.
    SORT g_tc_2211_itab BY csseq.
  ENDIF.

ENDMODULE.                    "TC_2211_user_command INPUT
*&---------------------------------------------------------------------*
*>  input module for tc 'TC_2212'. do not change this line!
*>  modify table
*&---------------------------------------------------------------------*
MODULE tc_2212_modify INPUT.

  MOVE-CORRESPONDING ztitcc2 TO g_tc_2212_wa.

  MODIFY g_tc_2212_tmp
    FROM g_tc_2212_wa
    INDEX tc_2212-current_line.

  IF sy-subrc NE 0.
    APPEND g_tc_2212_wa TO g_tc_2212_tmp.
  ENDIF.

ENDMODULE.                    "TC_2212_modify INPUT
*&---------------------------------------------------------------------*
*>  input module for tc 'TC_2212_1'. do not change this line!
*>  modify table
*&---------------------------------------------------------------------*
MODULE tc_2212_1_modify INPUT.

  MOVE-CORRESPONDING ztitcc3 TO g_tc_2212_1_wa.

  MODIFY g_tc_2212_1_tmp
    FROM g_tc_2212_1_wa
    INDEX tc_2212_1-current_line.
  IF sy-subrc NE 0.
    APPEND g_tc_2212_1_wa TO g_tc_2212_1_tmp.
  ENDIF.

ENDMODULE.                    "TC_2212_modify INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2212'. do not change this line!
*> mark table
*&---------------------------------------------------------------------*
MODULE tc_2212_mark INPUT.

  IF tc_2212-line_sel_mode = 1 AND
     g_tc_2212_wa-flag = 'X'.
    LOOP AT g_tc_2212_tmp INTO g_tc_2212_wa
      WHERE flag = 'X'.
      g_tc_2212_wa-flag = ''.
      MODIFY g_tc_2212_tmp
        FROM g_tc_2212_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tc_2212_wa-flag = 'X'.
  ENDIF.

  MODIFY g_tc_2212_tmp
    FROM g_tc_2212_wa
    INDEX tc_2212-current_line
    TRANSPORTING flag.

ENDMODULE.                    "TC_2212_mark INPUT

*&---------------------------------------------------------------------*
*>  input module for tc 'TC_2212'. do not change this line!
*>  process user command
*&---------------------------------------------------------------------*
MODULE tc_2212_user_command INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.

  ok_code = sy-ucomm.

  PERFORM user_ok_tc USING    'TC_2212'
                              'G_TC_2212_ITAB'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.

*> 기존 데이타 삭제.
*-> 기능개선 XXXXX : 하단의 ztiscr01 -> ztiscc01으로 일괄 변경(10개)
  CHECK NOT ztiscc01-csseq IS INITIAL.

  DELETE g_tc_2211_itab   WHERE csseq = ztiscc01-csseq.
  DELETE g_tc_2212_itab   WHERE csseq = ztiscc01-csseq.
  DELETE g_tc_2212_1_itab WHERE csseq = ztiscc01-csseq.
  DELETE g_tc_2212_2_itab WHERE csseq = ztiscc01-csseq. "기능개선 XXXXX

  DESCRIBE TABLE g_tc_2212_tmp   LINES ztiscc01-csszn.
  DESCRIBE TABLE g_tc_2212_1_tmp LINES ztiscc01-csndn.

  MOVE-CORRESPONDING ztiscc01 TO g_tc_2211_wa.
  APPEND g_tc_2211_wa TO g_tc_2211_itab.

*> 신규데이타 Insert.
  LOOP AT g_tc_2212_tmp   INTO g_tc_2212_wa.
    APPEND g_tc_2212_wa TO g_tc_2212_itab.
  ENDLOOP.

  CLEAR: g_cdseq.
  LOOP AT g_tc_2212_1_tmp INTO g_tc_2212_1_wa.
    g_tabix = sy-tabix.
    ADD 1 TO g_cdseq.
    g_tc_2212_1_wa-csseq = ztiscc01-csseq.
    g_tc_2212_1_wa-cdseq = g_cdseq.
    MODIFY g_tc_2212_1_tmp FROM g_tc_2212_1_wa INDEX g_tabix.
  ENDLOOP.

  LOOP AT g_tc_2212_1_tmp INTO g_tc_2212_1_wa.
    APPEND g_tc_2212_1_wa TO g_tc_2212_1_itab.
  ENDLOOP.

*-> 기능개선 XXXXX_요건확인서(4G) 신규데이터 INSERT
  CLEAR G_Z9050.
  SORT g_tc_2212_2_tmp BY ICCNO ICCSQ CSSEQ CMSEQ.

  LOOP AT g_tc_2212_2_tmp INTO g_tc_2212_2_wa. "요건확인(4G).
    ON CHANGE OF g_tc_2212_2_wa-CMSEQ.
      CLEAR G_Z9050.
    ENDON.
    g_tabix = sy-tabix.
    ADD 1 TO G_Z9050.
    IF G_Z9050 > 8.
      MESSAGE '동일 규격번호에 대해 8개를 초과하여 요건을 입력할 수 없습니다.'
        TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
    g_tc_2212_2_wa-csseq = ztiscc01-csseq. "란번호
    g_tc_2212_2_wa-Z9050 = G_Z9050.
    MODIFY g_tc_2212_2_tmp FROM g_tc_2212_2_wa INDEX g_tabix.
  ENDLOOP.

  LOOP AT g_tc_2212_2_tmp INTO g_tc_2212_2_wa.
    APPEND g_tc_2212_2_wa TO g_tc_2212_2_itab.
  ENDLOOP.
*<- 기능개선 XXXXX

  SORT g_tc_2211_itab BY csseq.

ENDMODULE.                    "TC_2212_user_command INPUT

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
*                                             ztitcrk-docst
*                                             g_ddtext
*                                             c_success.
*  l_ddtext = g_ddtext.
**
**> Status check.
*  CASE ztitcrk-docst.
*    WHEN space.  ">의뢰대상.
*    WHEN 'Y'.    ">개설신청.
*      IF g_mode EQ c_charm OR g_mode EQ c_chard OR
*         g_mode EQ c_chara.
*        MESSAGE e919 WITH g_ddtext.
*      ENDIF.
*      IF g_mode EQ c_chary OR g_mode EQ c_charo.
*        IF NOT ztitcrk-sndst IS INITIAL.
**> EDI 송수신 상태 Fixed value read.
*          PERFORM  ddic_domain_value_text_read
*                                      USING 'ZTISNDST'
*                                             sy-langu
*                                             ztitcrk-sndst
*                                             g_ddtext
*                                             c_success.
*          IF g_mode EQ c_chary.
*            IF ztitcrk-sndst EQ c_charw OR
*               ztitcrk-sndst EQ c_charY.
*              MESSAGE w921 WITH g_ddtext.
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
*    WHEN OTHERS.
*  ENDCASE.
*
*  MESSAGE s922 WITH l_ddtext.
*
ENDFORM.                    " check_document_status
*&---------------------------------------------------------------------*
*&      Module  make_ZTITCC1_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE make_ztitcc1_data INPUT.

  CLEAR g_count.

  REFRESH xztitcc1.

  LOOP AT g_tc_2211_itab INTO g_tc_2211_wa.
    ADD 1 TO g_count.
    g_tc_2211_wa-csseq = g_count.
    MODIFY g_tc_2211_itab FROM g_tc_2211_wa.

    MOVE-CORRESPONDING g_tc_2211_wa TO xztitcc1.
    APPEND xztitcc1.
  ENDLOOP.


  IF sy-ucomm EQ 'LINE_SELECT'.
    CLEAR g_csseq.

    GET CURSOR LINE g_findline.
    IF sy-subrc EQ 0.
*        GET CURSOR FIELD g_fieldname.
      g_findline = g_findline + tc_2211-top_line - 1.
      READ TABLE g_tc_2211_itab INTO  g_tc_2211_wa
                                INDEX g_findline.
      IF sy-subrc NE 0.
        EXIT.
      ENDIF.
    ENDIF.
    g_csseq = g_tc_2211_wa-csseq.

*란 사항.
    READ TABLE g_tc_2211_itab INTO g_tc_2211_wa
                              WITH KEY csseq = g_csseq.
    MOVE-CORRESPONDING g_tc_2211_wa TO ztiscc01.
  ENDIF.

ENDMODULE.                 " make_ZTITCC1_data  INPUT
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
*&      Module  check_cc_number_chainged  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_cc_number_chainged INPUT.

  CLEAR: g_ccnum_chk1, g_ccnum_chk2.

ENDMODULE.                 " check_cc_number_chainged  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_cc_number  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_cc_number INPUT.

  CHECK : g_mode EQ c_charc OR
          g_mode EQ c_charm.

  IF g_ccnum_chk1 IS INITIAL.
    IF ztitcck-cdcno IS INITIAL.
      PERFORM no_input_check USING 'ZTITCCK' 'CDCNO' c_warning.
      g_ccnum_chk1 = c_true.
    ENDIF.
  ENDIF.

  IF g_ccnum_chk2 IS INITIAL.
    IF NOT ztitcck-cdcno IS INITIAL.
      SELECT cdcno
        INTO g_ccnum
        FROM ztitcck UP TO 1 ROWS
       WHERE cdcno   EQ   ztitcck-cdcno
         AND iccno   NE   ztitcck-iccno.
      ENDSELECT.

      IF sy-subrc EQ 0.
*        MESSAGE w403 WITH ztitcck-cdcno.
        MESSAGE e404 WITH ztitcck-cdcno.
        g_ccnum_chk2 = c_true.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " check_cc_number  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2100 INPUT.

ENDMODULE.                 " user_command_2100  INPUT
*&---------------------------------------------------------------------*
*&      Module  make_zmTtccK_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE make_ztitcck_data INPUT.

ENDMODULE.                 " make_ztitcck_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2125  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2125 INPUT.
**> F2 Funtion key Event시 해당 필드의 정보 display
*  PERFORM  double_click_event.

ENDMODULE.                 " user_command_2125  INPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2212_1_mark  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_2212_1_mark INPUT.

  IF tc_2212_1-line_sel_mode = 1 AND
     g_tc_2212_1_wa-flag = 'X'.
    LOOP AT g_tc_2212_1_tmp INTO g_tc_2212_1_wa
      WHERE flag = 'X'.
      g_tc_2212_wa-flag = ''.
      MODIFY g_tc_2212_1_tmp
        FROM g_tc_2212_1_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tc_2212_1_wa-flag = 'X'.
  ENDIF.
  MODIFY g_tc_2212_1_tmp
    FROM g_tc_2212_1_wa
    INDEX tc_2212_1-current_line
    TRANSPORTING flag.

ENDMODULE.                 " tc_2212_1_mark  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_INPUT_VALUE_SCR2111  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_input_value_scr2111 INPUT.

  IF ztitcck-cdcno IS INITIAL.
    PERFORM no_input_check USING 'ZTITCCK' 'CDCNO' c_error.
  ENDIF.

  IF ztitcck-cdrdt IS INITIAL.
    PERFORM no_input_check USING 'ZTITCCK' 'CDRDT' c_error.
  ELSE.
    CALL FUNCTION 'Z_TI_CALC_CUSTOMS_PAYMENT_DATE'
      CHANGING
        ch_ztitcck = ztitcck.
  ENDIF.

ENDMODULE.                 " CHECK_INPUT_VALUE_SCR2111  INPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2212_2_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       기능개선 xxxxx
*----------------------------------------------------------------------*
MODULE TC_2212_2_MODIFY INPUT.

  MOVE-CORRESPONDING ztitcc4 TO g_tc_2212_2_wa.

*  if tc_2212_2-current_line gt 0.
  MODIFY g_tc_2212_2_tmp
    FROM g_tc_2212_2_wa
    INDEX tc_2212_2-current_line.
*  endif.
  IF sy-subrc NE 0.
    APPEND g_tc_2212_2_wa TO g_tc_2212_2_tmp.
  ENDIF.
ENDMODULE.                 " TC_2212_2_MODIFY  INPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2212_2_MARK  INPUT
*&---------------------------------------------------------------------*
*       기능개선 xxxxx
*----------------------------------------------------------------------*
MODULE TC_2212_2_MARK INPUT.

  IF tc_2212_2-line_sel_mode = 1 AND
     g_tc_2212_2_wa-flag = 'X'.
    LOOP AT g_tc_2212_2_tmp INTO g_tc_2212_2_wa
      WHERE flag = 'X'.
      g_tc_2212_wa-flag = ''.
      MODIFY g_tc_2212_2_tmp
        FROM g_tc_2212_2_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tc_2212_2_wa-flag = 'X'.
  ENDIF.
  MODIFY g_tc_2212_2_tmp
    FROM g_tc_2212_2_wa
    INDEX tc_2212_2-current_line
    TRANSPORTING flag.

ENDMODULE.                 " TC_2212_2_MARK  INPUT
