*&---------------------------------------------------------------------*
*& Include          ZGTSDR1260C01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_HANDLER DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.

  PUBLIC SECTION.
    METHODS: handle_data_changed
      FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed,

      handle_data_changed_finished
        FOR EVENT data_changed_finished OF cl_gui_alv_grid
        IMPORTING e_modified et_good_cells  sender,

      handle_hotspot_click
        FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id es_row_no,

      handle_double_click
        FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row e_column.

ENDCLASS.                    "LCL_EVENT_RECEIVER DEFINITION

*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_HANDLER IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD  handle_data_changed_finished.
*    PERFORM data_changed_finished   USING  et_good_cells   sender.

  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED

  METHOD handle_data_changed.
*    PERFORM data_changed  USING er_data_changed.

  ENDMETHOD.                    "handle_data_changed

  METHOD handle_double_click.

  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK

  METHOD handle_hotspot_click.

  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION
