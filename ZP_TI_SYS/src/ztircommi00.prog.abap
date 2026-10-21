************************************************************************
* Title         :  ZTIRCOMMI00                                         *
*                                                                      *
* Description   : 수입 공용 PAI Module Include                         *
*                                                                      *
* Creation Date : 2004/02/11                                           *
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
*&      Module  FCODE_EXIT_SCR2000  INPUT
*&---------------------------------------------------------------------*
MODULE fcode_exit_scr2000 INPUT.

  PERFORM  call_others_transaction  USING   c_charx
*  PERFORM  call_others_transaction  USING   g_mode
                                            sy-tcode
                                            c_true
                                            c_true.

ENDMODULE.                 " FCODE_EXIT_SCR2000  INPUT

*&---------------------------------------------------------------------*
*&      Module  TABSTRIP_ACTIVE_TAB_GET INPUT
*&---------------------------------------------------------------------*
*& INPUT MODULE FOR TS 'TABSTRIP'. DO NOT CHANGE THIS LINE!            *
*& GETS ACTIVE TAB                                                     *
*&---------------------------------------------------------------------*
MODULE tabstrip_active_tab_get INPUT.

  ok_code = sy-ucomm.

  CASE ok_code.
    WHEN c_tabstrip-tab1.
      g_tabstrip-pressed_tab = c_tabstrip-tab1.
    WHEN c_tabstrip-tab2.
      g_tabstrip-pressed_tab = c_tabstrip-tab2.
    WHEN c_tabstrip-tab3.
      g_tabstrip-pressed_tab = c_tabstrip-tab3.
    WHEN c_tabstrip-tab4.
      g_tabstrip-pressed_tab = c_tabstrip-tab4.
    WHEN c_tabstrip-tab5.
      g_tabstrip-pressed_tab = c_tabstrip-tab5.
    WHEN c_tabstrip-tab6.
      g_tabstrip-pressed_tab = c_tabstrip-tab6.
    WHEN c_tabstrip-tab7.
      g_tabstrip-pressed_tab = c_tabstrip-tab7.
    WHEN c_tabstrip-tab8.
      g_tabstrip-pressed_tab = c_tabstrip-tab8.
    WHEN c_tabstrip-tab9.
      g_tabstrip-pressed_tab = c_tabstrip-tab9.
    WHEN OTHERS.
  ENDCASE.

  IF g_tabstrip-subscreen EQ c_scr0100 AND
     g_tabstrip-prog      EQ c_text_prog.
    READ TABLE gt_control WITH KEY object = c_textobject_header.
    IF sy-subrc EQ 0.
      it_texttypes[] = gt_control-texttypes[].
      it_all_lines[] = gt_control-textlines[].
    ENDIF.

    CALL FUNCTION 'Z_TS_TEXT_IMP_SUBSCREEN'
      EXPORTING
        im_textobject = c_textobject_header
      TABLES
        ext_texttypes = it_texttypes
        ext_textlines = it_all_lines.

    READ TABLE gt_control WITH KEY object = c_textobject_header.
    IF sy-subrc EQ 0.
      g_tabix = sy-tabix.
      gt_control-texttypes[] = it_texttypes[].
      gt_control-textlines[] = it_all_lines[].
      MODIFY gt_control INDEX g_tabix.
    ENDIF.
  ENDIF.

ENDMODULE.                    "TABSTRIP_ACTIVE_TAB_GET INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr2000_get_ok_code  INPUT
*&---------------------------------------------------------------------*
MODULE pai_scr2000_get_ok_code INPUT.

  ok_code_old = ok_code.

ENDMODULE.                 " pai_scr2000_get_ok_code  INPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr0100_Initialization  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_scr0100_initialization OUTPUT.

  PERFORM  p1000_set_initial_data.

ENDMODULE.                 " pbo_scr0100_Initialization  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pai_get_fcode_scr2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_get_fcode_scr2000 INPUT.

  CALL METHOD cl_framework_mm=>get_instance
    IMPORTING
      ex_instance = g_fw.

  CALL METHOD g_fw->set_fcode
    EXPORTING
      im_fcode = sy-ucomm.

  CLEAR ok-code.

ENDMODULE.                 " pai_get_fcode_scr2000  INPUT
*&---------------------------------------------------------------------*
*&      Module  fcode_work_on_scr2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fcode_work_on_scr2000 INPUT.

  IF sy-ucomm EQ 'ZTIBACK' OR
     sy-ucomm EQ 'ZTIEXIT' OR
     sy-ucomm EQ 'ZTICANCEL'.
*    LEAVE TO SCREEN 0.
  ELSE.
    PERFORM alv_tree_dispatcher.
  ENDIF.

ENDMODULE.                 " fcode_work_on_scr2000  INPUT
*&---------------------------------------------------------------------*
*&      Module  event_pai_finished  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE event_pai_finished INPUT.

*> Tree
  IF NOT g_alv_tree IS INITIAL.
    CALL METHOD g_default_view->handle_event( 'BEFORE_TRANSPORT' ).
  ENDIF.

*> Items Value check.
  PERFORM  before_transport_pai  IN PROGRAM (g_repid).

  CHECK ok_code NE 'ODYCD'.

  CASE ok_code.
    WHEN 'ZTIOTHER'.     ">기타 문서.
      PERFORM  call_others_transaction  USING   c_chary
                                                sy-tcode
                                                c_true
                                                c_false.
    WHEN 'ZTICREATE'.    ">생성.
      PERFORM  call_others_transaction  USING   c_chary
                                                c_create
                                                c_true
                                                c_false.
    WHEN 'ZTICHANGE'.   ">변경.
      PERFORM  call_others_transaction  USING   c_chary
                                                c_change
                                                c_true
                                                c_false.
    WHEN 'ZTIDISPLAY'.  ">조회.
      PERFORM  call_others_transaction  USING   c_chary
                                                c_display
                                                c_true
                                                c_false.
    WHEN 'ZTIDELETE'.    ">삭제.
      PERFORM  call_others_transaction  USING   c_chard
                                                c_delete
                                                c_true
                                                c_false.
    WHEN 'ZTISAVE'.     ">저장.
      PERFORM  call_others_transaction  USING   g_mode
                                                c_delete
                                                c_false
                                                c_false.
    WHEN 'ZTIBACK' OR 'ZTIEXIT' OR 'ZTICANCEL'.
      IF g_mode EQ c_chard OR    ">삭제 모드일 경우.
         g_mode EQ c_charr OR    ">취소 모드일 경우.
         g_mode EQ c_chara OR
         g_mode EQ c_chary.
        PERFORM  call_others_transaction  USING   c_chars
                                                  c_delete
                                                  c_false
                                                  c_false.
      ELSE.
        PERFORM  call_others_transaction  USING   g_mode
                                                  c_delete
                                                  c_false
                                                  c_false.
      ENDIF.
    WHEN 'ZTISIMUL' OR 'ZTIPOST'.  ">Simulation/Posting
      PERFORM  fi_document_create IN PROGRAM (g_repid).
    WHEN 'ZTIREVER'.       ">전기취소.
      PERFORM  fi_document_cancel IN PROGRAM (g_repid).
    WHEN 'ZTISHOWMSG'.     ">오류메시지.
      PERFORM  check_for_document_field USING g_mode.
      IF g_cnt EQ 0.
        MESSAGE s911.
      ENDIF.
    WHEN 'ZTICHECK'. ">체크.

*S__ 신용장 변경에 따른 수정 20181010 BY SDW
      PERFORM CHECK_TEXT_EDIT_DATA(ZTIR0000).
*E__ 신용장 변경에 따른 수정 20181010 BY SDW
      PERFORM check_for_document_field USING g_mode.
    WHEN 'ZTISELECT'.   ">문서선택.
*> F2 Funtion key Event시 해당 필드의 정보 display
      PERFORM  double_click_event.
    WHEN 'ZTIPRINT'. ">인쇄미리보기.
      PERFORM  applications_print IN PROGRAM (g_repid).
    WHEN 'METRON' OR 'METROF'.
      IF g_tree_mode EQ c_chary.
        g_tree_mode = c_charn.
      ELSE.
        g_tree_mode = c_chary.
      ENDIF.
    WHEN 'MEV9998ON'. ">헤더 펼치기/닫기.
      IF g_button1 EQ c_y.
        CLEAR: g_button1.
      ELSE.
        g_button1 = c_y.
      ENDIF.
    WHEN OTHERS.
      PERFORM  other_functions IN PROGRAM (g_repid).
  ENDCASE.
*
  CLEAR: g_fcode_dropped, g_table_model.

ENDMODULE.                 " event_pai_finished  INPUT
*&---------------------------------------------------------------------*
*&      Module  set_shopping_basket_pai  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_shopping_basket_pai INPUT.

  CALL METHOD g_shopping_basket->pai( ).

ENDMODULE.                 " set_shopping_basket_pai  INPUT
