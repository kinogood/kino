*&---------------------------------------------------------------------*
*&  Include           ZFIR0581CLASS
*&---------------------------------------------------------------------*
****************************************************************
* LOCAL CLASSES: Definition
****************************************************************
*===============================================================
* class lcl_event_receiver: local class to
*                         define and handle own functions.
*
* Definition:
* ~~~~~~~~~~~

*----------------------------------------------------------------------*
*       CLASS lcl_event_receiver DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*

class lcl_event_receiver definition.
  public section.
    methods:
*-- 입력값체크
    handle_data_changed
            for event data_changed of cl_gui_alv_grid
                importing er_data_changed
                          e_onf4
                          e_onf4_before
                          e_onf4_after,
*-- 데이터 변경 후 이벤트
    handle_data_changed_finished
            for event data_changed_finished of cl_gui_alv_grid
                importing e_modified
                          et_good_cells,
    handle_toolbar
        for event toolbar of cl_gui_alv_grid
            importing e_object e_interactive,
    handle_user_command
        for event user_command of cl_gui_alv_grid
            importing e_ucomm.
endclass.                    "lcl_event_receiver DEFINITION

*===============================================================

****************************************************************
* LOCAL CLASSES: Implementation
****************************************************************
*===============================================================
* class lcl_event_receiver (Implementation)
class lcl_event_receiver implementation.
*----------------------------------------------------------------------*
*   HANDLE_DATA_CHANGED
*----------------------------------------------------------------------*
  method handle_data_changed.

  endmethod.                    "HANDLE_DATA_CHANGED
*----------------------------------------------------------------------*
*   HANDLE_DATA_CHANGED_FINISHED
*   - Raw 단위 변경 사항 이벤트 발생
*----------------------------------------------------------------------*
  method handle_data_changed_finished.
*-- 강제로 화면 PBO, PAI 수행
    call method cl_gui_cfw=>set_new_ok_code
      exporting
        new_code = 'ETC'.
  endmethod.                    "HANDLE_DATA_CHANGED_FINISHED
*----------------------------------------------------------------------*
*  handle_toolbar
*----------------------------------------------------------------------*
  method handle_toolbar.
    data: ls_toolbar type stb_button.
    clear ls_toolbar.
    move 3 to ls_toolbar-butn_type.
    append ls_toolbar to e_object->mt_toolbar.
    clear ls_toolbar.
    move 'COPY' to ls_toolbar-function.
    move icon_system_paste to ls_toolbar-icon.
    move '복사'(113) to ls_toolbar-quickinfo.
    move '복사'(114) to ls_toolbar-text.
    append ls_toolbar to e_object->mt_toolbar.

    move 'ADD' to ls_toolbar-function.
    move icon_insert_multiple_lines to ls_toolbar-icon.
    move '추가'(113) to ls_toolbar-quickinfo.
    move '추가'(114) to ls_toolbar-text.
    append ls_toolbar to e_object->mt_toolbar.

    move 'DEL' to ls_toolbar-function.
    move icon_delete_row to ls_toolbar-icon.
    move '삭제'(113) to ls_toolbar-quickinfo.
    move '삭제'(114) to ls_toolbar-text.
    append ls_toolbar to e_object->mt_toolbar.
  endmethod.                    "handle_toolbar
*----------------------------------------------------------------------*
*  handle_user_command
*----------------------------------------------------------------------*
  method handle_user_command.
    clear g_subrc.
    case e_ucomm.
      when 'ADD'.
        perform add_data_line.
      when 'DEL'.
        perform delete_data_line.
      when 'COPY'.
        perform copy_data_line.
    endcase.
**-- 강제로 화면 PBO, PAI 수행
    call method cl_gui_cfw=>set_new_ok_code
      exporting
        new_code = 'ETC'.
  endmethod.                           "handle_user_command
endclass.                    "lcl_event_receiver IMPLEMENTATION
data  event_receiver type ref to lcl_event_receiver.
