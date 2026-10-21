INTERFACE zgtpp_if_list_handler
  PUBLIC .

  METHODS handle_field_catalog DEFAULT IGNORE
    FOR EVENT field_catalog OF zgtpp_cl_list
    IMPORTING
      !sender .
  METHODS handle_layout DEFAULT IGNORE
    FOR EVENT layout OF zgtpp_cl_list
    IMPORTING
      !sender .
  METHODS handle_sort DEFAULT IGNORE
    FOR EVENT sort OF zgtpp_cl_list
    IMPORTING
      !sender .
  METHODS handle_toolbar DEFAULT IGNORE
    FOR EVENT toolbar OF cl_gui_alv_grid
    IMPORTING
      !e_object
      !e_interactive
      !sender .
  METHODS handle_user_command DEFAULT IGNORE
    FOR EVENT user_command OF cl_gui_alv_grid
    IMPORTING
      !e_ucomm
      !sender .
  METHODS handle_double_click DEFAULT IGNORE
    FOR EVENT double_click OF cl_gui_alv_grid
    IMPORTING
      !e_row
      !e_column
      !es_row_no
      !sender .
  METHODS handle_button_click DEFAULT IGNORE
    FOR EVENT button_click OF cl_gui_alv_grid
    IMPORTING
      !es_col_id
      !es_row_no
      !sender .
  METHODS handle_hotspot_click DEFAULT IGNORE
    FOR EVENT hotspot_click OF cl_gui_alv_grid
    IMPORTING
      !e_row_id
      !e_column_id
      !es_row_no
      !sender .
  METHODS handle_data_changed DEFAULT IGNORE
    FOR EVENT data_changed OF cl_gui_alv_grid
    IMPORTING
      !er_data_changed
      !e_onf4
      !e_onf4_before
      !e_onf4_after
      !e_ucomm
      !sender .
  METHODS handle_data_changed_finished DEFAULT IGNORE
    FOR EVENT data_changed_finished OF cl_gui_alv_grid
    IMPORTING
      !e_modified
      !et_good_cells
      !sender .
  METHODS handle_print_top_of_list DEFAULT IGNORE
      FOR EVENT print_top_of_list OF cl_gui_alv_grid .
  METHODS handle_print_end_of_list DEFAULT IGNORE
      FOR EVENT print_end_of_list OF cl_gui_alv_grid .
  METHODS handle_print_top_of_page DEFAULT IGNORE
    FOR EVENT print_top_of_page OF cl_gui_alv_grid
    IMPORTING
      !table_index .
  METHODS handle_print_end_of_page DEFAULT IGNORE
      FOR EVENT print_top_of_page OF cl_gui_alv_grid .
  METHODS handle_top_of_page DEFAULT IGNORE
    FOR EVENT top_of_page OF cl_gui_alv_grid
    IMPORTING
      !e_dyndoc_id
      !table_index .
  METHODS handle_popup DEFAULT IGNORE
    FOR EVENT popup OF zgtpp_cl_list
    IMPORTING
      !ir_salv_table
      !sender .
  METHODS handle_salv_double_click DEFAULT IGNORE
    FOR EVENT double_click OF cl_salv_events_table
    IMPORTING
      !row
      !column
      !sender .
  METHODS handle_f4 DEFAULT IGNORE
    FOR EVENT f4 OF zgtpp_cl_list
    IMPORTING
      !sender .
  METHODS handle_on_f4 DEFAULT IGNORE
    FOR EVENT onf4 OF cl_gui_alv_grid
    IMPORTING
      !sender
      !e_fieldname
      !e_fieldvalue
      !es_row_no
      !er_event_data
      !et_bad_cells
      !e_display .
  METHODS handle_salv_user_command DEFAULT IGNORE
    FOR EVENT added_function OF cl_salv_events_table
    IMPORTING
      !e_salv_function
      !sender .
  METHODS handle_popup_close DEFAULT IGNORE
    FOR EVENT close OF cl_gui_dialogbox_container
    IMPORTING
      !sender .
  METHODS handle_ondrag DEFAULT IGNORE
    FOR EVENT ondrag OF cl_gui_alv_grid
    IMPORTING
      !sender
      !e_row
      !e_column
      !es_row_no
      !e_dragdropobj .
  METHODS handle_ondrop DEFAULT IGNORE
    FOR EVENT ondrop OF cl_gui_alv_grid
    IMPORTING
      !sender
      !e_row
      !e_column
      !es_row_no
      !e_dragdropobj .
  METHODS handle_ondropcomplete DEFAULT IGNORE
    FOR EVENT ondropcomplete OF cl_gui_alv_grid
    IMPORTING
      !sender
      !e_row
      !e_column
      !es_row_no
      !e_dragdropobj .
  METHODS handle_context_menu_request DEFAULT IGNORE
    FOR EVENT context_menu_request OF cl_gui_alv_grid
    IMPORTING
      !sender
      !e_object .
ENDINTERFACE.
