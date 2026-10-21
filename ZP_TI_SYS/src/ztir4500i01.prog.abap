************************************************************************
* Title         :  ZTIR4500I01                                         *
*                                                                      *
* Description   : 반입예정정보 PAI Module Include                      *
*                                                                      *
* Creation Date : 2003/08/21                                           *
*                                                                      *
* Author        : Seung Jun, LEE                                       *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&      Module  tc_2130_modify  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_2130_modify INPUT.

*  MOVE-CORRESPONDING ZTIsrqit TO g_tc_2130_wa.
*
*  IF g_tc_2130_wa-rqmng GT g_tc_2130_wa-rqmngl.
*    CLEAR: g_menget.
*    WRITE g_tc_2130_wa-rqmngl TO g_menget(15) UNIT g_tc_2130_wa-meins.
*    CONCATENATE g_menget g_tc_2130_wa-meins INTO g_menget.
*    MESSAGE e005 WITH g_menget.
*  ENDIF.
*
**> 정가 계산.
*  CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
*    EXPORTING
*      peinh = g_tc_2130_wa-peinh
*      bpumz = g_tc_2130_wa-bpumz
*      bpumn = g_tc_2130_wa-bpumn
*      menge = g_tc_2130_wa-rqmng
*      netpr = g_tc_2130_wa-netpr
*    CHANGING
*      netwr = g_tc_2130_wa-netwr.
*
*  IF g_tc_2130_wa-cnam IS INITIAL.
*    MOVE: sy-uname TO g_tc_2130_wa-cnam,
*          sy-datlo TO g_tc_2130_wa-cdat,
*          sy-timlo TO g_tc_2130_wa-ctme.
*  ENDIF.
*
*  MOVE: sy-uname TO g_tc_2130_wa-unam,
*        sy-datlo TO g_tc_2130_wa-udat,
*        sy-timlo TO g_tc_2130_wa-utme.
*
*  MODIFY  it_tab
*    FROM  g_tc_2130_wa
*    INDEX tc_2130-current_line.

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
**> table control functions ( 삭제, 추가, 선택, 해제, 이동 등 )
*  PERFORM  user_ok_tc USING    'TC_2130'
*                               'IT_TAB'
*                               'FLAG'
*                      CHANGING ok_code.
**>아이템 번호를 생성함.
*  PERFORM set_item_number_build TABLES it_tab
*                                USING  ZTITBLK.
**> 아이템 정보 display
*  PERFORM  display_infomation_by_items USING   'TC_2130'
*                                               'IT_TAB'
*                                               'FLAG'
*                                               ZTITRQK-lifnr
*                                       CHANGING ok_code.
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

  IF ztisscrcom-iblno IS INITIAL AND
     ztisscrcom-blnum IS INITIAL.
    MESSAGE e913.
  ENDIF.

  CLEAR: g_count.
  IF ztisscrcom-iblno IS INITIAL.
    PERFORM get_bl_intno_by_bl_number   USING ztisscrcom-blnum
                                              ztisscrcom-iblno
                                              c_false.
  ENDIF.

  IF NOT ztisscrcom-iblno IS INITIAL.
    CALL FUNCTION 'Z_TI_GET_BS_BILL_OF_LADING'
      EXPORTING
        iblno     = ztisscrcom-iblno
        gmode     = g_mode
      IMPORTING
        ztitblk  = ztitblk
        ztitbsk  = ztitbsk
      TABLES
        ztitblp  = it_tab
*        ZTITBLC  = xZTITBLC
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

    IF sy-subrc <> 0.
      IF ztisscrcom-blnum IS INITIAL.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ELSE.
        MESSAGE w451 WITH ztisscrcom-blnum.
      ENDIF.
    ENDIF.

*> IMG Checking.
    SELECT SINGLE *
      FROM ztitig00
     WHERE bukrs  EQ  ztitblk-bukrs.
    IF sy-subrc EQ 0.
      IF ztitig00-bsmtu EQ c_false.
        MESSAGE e450 WITH ztitblk-bukrs.
      ENDIF.
    ELSE.
      MESSAGE e035 WITH ztitblk-bukrs.
    ENDIF.

* 보세운송.
    IF NOT ( ztitblk-rptty EQ 'B' OR
             ztitblk-rptty EQ 'N' ).
      MESSAGE e225.
    ENDIF.

*> 기생성 체크.
    IF NOT ztitblk-iblno IS INITIAL.
      SELECT SINGLE *
        INTO gs_ztitbsk
        FROM ztitbsk
       WHERE iblno  EQ  ztitblk-iblno.
      IF sy-subrc EQ 0.
        MESSAGE e452 WITH ztitblk-iblno.
      ENDIF.
    ENDIF.

*>초기값 Setting
    PERFORM set_bonded_area_schedule.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
    PERFORM p1102_authorization_check USING ztitbsk-bukrs.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*>업무영역별 Status Check.
    PERFORM check_document_status.
*>아이템 기타 정보 Read.
    PERFORM set_others_fields_by_items.
*>화면상의 Text를 Master Data 등에서 Read.
    PERFORM get_others_text_by_master_data.

*>조회모드가 아닌 경우 Lock.
    IF g_mode NE c_chars.
      PERFORM set_bl_lock_object   USING ztitblk-iblno
                                         '00000'
                                         c_lock
                                         c_error
                                         g_modify.
    ENDIF.
*> Document History 조회.
    IF NOT ztitbsk-iblno IS INITIAL.
      PERFORM get_document_history   TABLES it_dochis
                                     USING  c_bl
                                            ztitbsk-iblno
                                            '00'
                                            g_history.
    ENDIF.
  ELSE.
    IF ztisscrcom-blnum IS INITIAL.
      PERFORM no_input_check USING 'ZTISSCRCOM' 'BLNUM' c_error.
    ELSE.

    ENDIF.
*    MESSAGE e902.
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
                                               ztitbsk+3(10).

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

  IF ztisscrcom-ibsno IS INITIAL.
    MESSAGE e913.
  ENDIF.

  IF NOT ztisscrcom-ibsno IS INITIAL.
    CALL FUNCTION 'Z_TI_GET_BS_BILL_OF_LADING'
      EXPORTING
        ibsno     = ztisscrcom-ibsno
        gmode     = g_mode
      IMPORTING
        ztitblk  = ztitblk
        ztitbsk  = ztitbsk
      TABLES
        ztitblp  = it_tab
*        ZTITBLC  = xZTITBLC
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      MESSAGE e602 WITH ztisscrcom-ibsno.
*2003.12.20. 메시지 변경.
    ENDIF.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> authorization
    PERFORM get_authorization_bukrs.
    IF l_yn NE 'A'.
    IF ztitbsk-bukrs <> a_bukrs.
      MESSAGE e998 WITH ztitbsk-bukrs  '권한이 없습니다!'..
    ENDIF.
    endif.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*> 변경 문서 관리를 위한 이전데이타를 Move.
     *ztitbsk   = ztitbsk.

*>업무영역별 Status Check.
    PERFORM check_document_status.
*>아이템 기타 정보 Read.
    PERFORM set_others_fields_by_items.
*>화면상의 Text를 Master Data 등에서 Read.
    PERFORM get_others_text_by_master_data.
*>조회모드가 아닌 경우 Lock.
    IF g_mode NE c_chars.
*      PERFORM set_lg_lock_object   USING ZTItlg01-ilgno
*                                         c_lock
*                                         c_error
*                                         g_modify.
    ENDIF.
*> Document History 조회.
    PERFORM get_document_history   TABLES it_dochis
                                   USING  g_document
                                          ztitbsk-ibsno
                                          '00'
                                          g_history.
    ztisscrcom-reqty = 'BS'.
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
*&      Form  tc_2122_modify
*&---------------------------------------------------------------------*
* input module for tc 'TC_2122'. do not change this line!
* modify table
*----------------------------------------------------------------------*
MODULE tc_2122_modify INPUT.

  MOVE-CORRESPONDING ztitblc TO g_tc_2122_wa.

  IF g_tc_2122_wa-cnam IS INITIAL.
    MOVE: sy-uname TO g_tc_2122_wa-cnam,
          sy-datlo TO g_tc_2122_wa-cdat,
          sy-timlo TO g_tc_2122_wa-ctme.
  ENDIF.

  MOVE: sy-uname TO g_tc_2122_wa-unam,
        sy-datlo TO g_tc_2122_wa-udat,
        sy-timlo TO g_tc_2122_wa-utme.

*> Container data Modify.
  MODIFY g_tc_2122_itab
    FROM g_tc_2122_wa
    INDEX tc_2122-current_line.

ENDMODULE.                    "TC_2122_modify INPUT
*&---------------------------------------------------------------------*
*&      Form  tc_2122_mark
*&---------------------------------------------------------------------*
* input module for tc 'TC_2122'. do not change this line!
* mark table
*----------------------------------------------------------------------*
MODULE tc_2122_mark INPUT.
  IF tc_2122-line_sel_mode = 1 AND
     g_tc_2122_wa-flag = 'X'.
    LOOP AT g_tc_2122_itab INTO g_tc_2122_wa
      WHERE flag = 'X'.
      g_tc_2122_wa-flag = ''.
      MODIFY g_tc_2122_itab
        FROM g_tc_2122_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tc_2122_wa-flag = 'X'.
  ENDIF.

  MODIFY g_tc_2122_itab
    FROM g_tc_2122_wa
    INDEX tc_2122-current_line
    TRANSPORTING flag.

ENDMODULE.                    "TC_2122_mark INPUT
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
*&      Module  USER_COMMAND_2122  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2122 INPUT.

  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_2122'
                              'G_TC_2122_ITAB'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
  IF g_mode NE c_chars.
    CLEAR g_count.
    LOOP AT g_tc_2122_itab INTO g_tc_2122_wa.
      ADD 1 TO g_count.
      MOVE g_count TO g_tc_2122_wa-ctnsq.
      MODIFY g_tc_2122_itab FROM g_tc_2122_wa.
    ENDLOOP.
  ENDIF.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.

ENDMODULE.                 " USER_COMMAND_2122  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2100 INPUT.

ENDMODULE.                 " user_command_2100  INPUT
