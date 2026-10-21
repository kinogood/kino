*&---------------------------------------------------------------------*
*& Include          ZGTLER2100C01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_HANDLER DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.

  PUBLIC SECTION.
    METHODS: handle_toolbar
      FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object e_interactive,

      handle_data_changed
        FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed,

      handle_data_changed_finished
        FOR EVENT data_changed_finished OF cl_gui_alv_grid
        IMPORTING e_modified et_good_cells  sender,

      handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,

      handle_hotspot_click
        FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id es_row_no,

      handle_double_click
        FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row e_column,

      handle_on_f4
        FOR EVENT onf4 OF cl_gui_alv_grid
        IMPORTING e_fieldname
                  e_fieldvalue
                  es_row_no
                  er_event_data
                  et_bad_cells
                  e_display.

ENDCLASS.                    "LCL_EVENT_RECEIVER DEFINITION

*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_HANDLER IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD handle_toolbar.

  ENDMETHOD.                    "HANDLE_TOOLBAR

  METHOD  handle_data_changed_finished.
*    PERFORM data_changed_finished   USING  et_good_cells   sender.

  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED

  METHOD handle_user_command.

  ENDMETHOD.                           "handle_user_command

  METHOD handle_data_changed.
    PERFORM data_changed  USING er_data_changed.

  ENDMETHOD.                    "handle_data_changed

  METHOD handle_double_click.

  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK

  METHOD handle_hotspot_click.

  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

  METHOD handle_on_f4.
    PERFORM handle_on_f4  USING  e_fieldname
                                 e_fieldvalue
                                 es_row_no
                                 er_event_data
                                 et_bad_cells
                                 e_display.

  ENDMETHOD.

ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION
