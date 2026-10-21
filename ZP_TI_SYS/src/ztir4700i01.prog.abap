************************************************************************
* Title         :  ZTIR6000I01                                         *
*                                                                      *
* Description   : L/G 관리  Subroutine Include                         *
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
  CASE ok_code.
    WHEN 'ZTIBACK' OR 'ZTIEXIT' OR 'ZTICANCEL'.
      PERFORM  call_others_transaction  USING   c_charx
                                                sy-tcode
                                                c_true
                                                c_true.
    WHEN 'ZTICREATE'.
      LEAVE TO TRANSACTION c_create.
    WHEN 'ZTICHANGE'.
      LEAVE TO TRANSACTION c_change.
    WHEN 'ZTIDISPLAY'.
      LEAVE TO TRANSACTION c_display.
  ENDCASE.

  IF ztisscrcom-ibino IS INITIAL.
    MESSAGE e913.
  ENDIF.

*  CLEAR: g_count.
*  IF ZTIsscrcom-iblno IS INITIAL.
*    PERFORM  get_bl_int_no_by_bl_number  USING ZTIsscrcom-blnum
*                                               ZTIsscrcom-iblno
*                                               c_false.
*  ENDIF.

  IF NOT ztisscrcom-ibino IS INITIAL.
    CALL FUNCTION 'Z_TI_GET_BO_BILL_OF_LADING'
      EXPORTING
        ibino     = ztisscrcom-ibino
        gmode     = g_mode
      IMPORTING
        ztitblk  = ztitblk
        ztitbsk  = ztitbsk
        ztitbik  = ztitbik
        ztitbok  = ztitbok
      TABLES
        ztitblp  = it_tab
*        ZTItblct  = xZTItblct
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

*>문서 초기값 Setting
    PERFORM set_document_initial_value.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
    PERFORM p1102_authorization_check USING ztitbok-bukrs.
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
    IF NOT ztitbok-iblno IS INITIAL.
      PERFORM get_document_history   TABLES it_dochis
                                     USING  c_bl
                                            ztitbok-iblno
                                            '00'
                                            g_history.
    ENDIF.
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
                                               ztitbok+3(10).

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

  IF ztisscrcom-ibono IS INITIAL.
    MESSAGE e913.
  ENDIF.

  IF NOT ztisscrcom-ibono IS INITIAL.
    CALL FUNCTION 'Z_TI_GET_BO_BILL_OF_LADING'
      EXPORTING
        ibono     = ztisscrcom-ibono
        gmode     = g_mode
      IMPORTING
        ztitblk  = ztitblk
        ztitbsk  = ztitbsk
        ztitbik  = ztitbik
        ztitbok  = ztitbok
      TABLES
        ztitblp  = it_tab
*        ZTItblct  = xZTItblct
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      MESSAGE e604 WITH ztisscrcom-ibino.
*2003.12.20. 메시지 변경.
    ENDIF.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> authorization
    PERFORM get_authorization_bukrs.
    IF l_yn NE 'A'.
      IF ztitbok-bukrs <> a_bukrs.
        MESSAGE e998 WITH ztitbok-bukrs  '권한이 없습니다!'..
      ENDIF.
    ENDIF.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*> 변경 문서 관리를 위한 이전데이타를 Move.
     *ztitbok   = ztitbok.

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
                                          ztitbok-ibono
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
*&      Module  check_bonded_transfer_number  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_bonded_transfer_number INPUT.

ENDMODULE.                 " check_bonded_transfer_number  INPUT
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
*&      Module  pai_scr2121_input_value_check  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_scr2121_input_value_check INPUT.

  CHECK: g_mode EQ c_charc OR  ">생성.
         g_mode EQ c_charm.    ">변경.

*> 필수 항목 체크.
*  PERFORM  check_mandatory_input     USING  :
*                                    'ZTITBIK-BLNUM'  c_error,
*                                    'ZTITBIK-BGMNO'  c_error,
*                                    'ZTITBIK-BUKRS'  c_error,
*                                    'ZTITBIK-BLOCC'  c_error,
*                                    'ZTITBIK-BPKCN'  c_error,
*                                    'ZTITBIK-BPKCNU' c_error,
*                                    'ZTITBIK-BIWET'  c_error,
*                                    'ZTITBIK-MEINS'  c_error,
*                                    'ZTITBIK-BINDT'  c_error,
*                                    'ZTITBIK-TXZ01'  c_error,
*                                    'ZTITBIK-BIDDT'  c_error.
*> 회사코드 Select.
  SELECT SINGLE *
    FROM t001
   WHERE bukrs EQ ztitbik-bukrs.

ENDMODULE.                 " pai_scr2121_input_value_check  INPUT
