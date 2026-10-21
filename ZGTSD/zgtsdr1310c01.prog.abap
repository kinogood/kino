*&---------------------------------------------------------------------*
*& Include          ZGTSDR1310C01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_HANDLER DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.

*  PUBLIC SECTION.
*    METHODS: top_of_page
*      FOR EVENT top_of_page OF cl_gui_alv_grid
*      IMPORTING e_dyndoc_id,
*
*      handle_toolbar
*        FOR EVENT toolbar OF cl_gui_alv_grid
*        IMPORTING e_object e_interactive,
*
*      handle_data_changed
*        FOR EVENT data_changed OF cl_gui_alv_grid
*        IMPORTING er_data_changed sender,
*
*      handle_data_changed_finished
*        FOR EVENT data_changed_finished OF cl_gui_alv_grid
*        IMPORTING e_modified et_good_cells  sender,
*
*      handle_user_command
*        FOR EVENT user_command OF cl_gui_alv_grid
*        IMPORTING e_ucomm,
*
*      handle_hotspot_click
*        FOR EVENT hotspot_click OF cl_gui_alv_grid
*        IMPORTING e_row_id e_column_id es_row_no,
*
*      handle_hotspot_click_200
*        FOR EVENT hotspot_click OF cl_gui_alv_grid
*        IMPORTING e_row_id e_column_id es_row_no,
*
*      handle_double_click
*        FOR EVENT double_click OF cl_gui_alv_grid
*        IMPORTING e_row e_column.
*
*ENDCLASS.                    "LCL_EVENT_RECEIVER DEFINITION
*
**----------------------------------------------------------------------*
**       CLASS LCL_EVENT_HANDLER IMPLEMENTATION
**----------------------------------------------------------------------*
*CLASS lcl_event_handler IMPLEMENTATION.
*
*  METHOD top_of_page.
*    PERFORM make_top_of_page           USING e_dyndoc_id.
*
*  ENDMETHOD.                    "Top_of_page
*
*  METHOD handle_toolbar.
*    PERFORM handle_toolbar             USING  e_object.
*
*  ENDMETHOD.                    "HANDLE_TOOLBAR
*
*  METHOD  handle_data_changed_finished.
*    PERFORM data_changed_finished   USING  E_MODIFIED et_good_cells   sender.
*
*  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED
*
*  METHOD handle_user_command.
*    PERFORM handle_user_command        USING  e_ucomm.
*
*  ENDMETHOD.                           "handle_user_command
*
*  METHOD handle_data_changed.
*    PERFORM data_changed               USING er_data_changed SENDER.
*
*  ENDMETHOD.                    "handle_data_changed
*
*  METHOD handle_double_click.
*    PERFORM handle_double_click_event  USING e_row  e_column.
*
*  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK
*
*  METHOD handle_hotspot_click.
*    perform handle_hotspot_click_event  USING '100'
*                                              E_ROW_ID
*                                              E_COLUMN_ID
*                                              ES_ROW_NO.
*
*  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK
*
*  METHOD handle_hotspot_click_200.
*    perform handle_hotspot_click_event  USING '200'
*                                              E_ROW_ID
*                                              E_COLUMN_ID
*                                              ES_ROW_NO.
*
*  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION
