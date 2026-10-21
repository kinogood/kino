*&---------------------------------------------------------------------*
*& Include          ZGTSDR0060C01
*&---------------------------------------------------------------------*
*-----------------------------------------------------------------------
*-- ALV 전역 변수 선언
*-----------------------------------------------------------------------
CLASS lcl_event_handler DEFINITION DEFERRED.

DATA : go_dock_cont_0100 TYPE REF TO cl_gui_docking_container,

       go_splt_0100      TYPE REF TO cl_gui_splitter_container,

       go_gui_cont_head  TYPE REF TO cl_gui_container,
       go_gui_cont_item  TYPE REF TO cl_gui_container,

       go_event_handler  TYPE REF TO lcl_event_handler,

       go_grid_head      TYPE REF TO cl_gui_alv_grid,
       go_grid_item      TYPE REF TO cl_gui_alv_grid.

*-----------------------------------------------------------------------
*-- Class ALV Lcl Event 정의
*-----------------------------------------------------------------------
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS handle_toolbar
      FOR EVENT toolbar      OF cl_gui_alv_grid
      IMPORTING sender
                e_object
                e_interactive.

    METHODS handle_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING sender
                e_ucomm.

    METHODS handle_data_changed
      FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING sender
                er_data_changed
                e_onf4
                e_ucomm.

    METHODS handle_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING sender
                e_row
                e_column
                es_row_no.

ENDCLASS.

*-----------------------------------------------------------------------
*-- Class ALV Lcl Event 구현
*-----------------------------------------------------------------------
CLASS lcl_event_handler IMPLEMENTATION.

*-- ToolBar
  METHOD handle_toolbar.
*    PERFORM toolbar_pros            USING    sender
*                                             e_object
*                                             e_interactive.
  ENDMETHOD.

*-- user_command
  METHOD handle_user_command.
*    PERFORM user_command_pros USING sender
*                                    e_ucomm.
  ENDMETHOD.

*-- Data change
  METHOD handle_data_changed.
*    PERFORM data_changed USING sender
*                               er_data_changed
*                               e_onf4
*                               e_ucomm.
  ENDMETHOD.
*-- Double Click
  METHOD handle_double_click.
    PERFORM double_click_0100       USING    sender
                                             e_row
                                             e_column
                                             es_row_no.

  ENDMETHOD.
ENDCLASS.
