*&---------------------------------------------------------------------*
*& Include          ZGTPPR2190C01
*&---------------------------------------------------------------------*
CLASS lcl_list_handler DEFINITION.
  PUBLIC SECTION.
    INTERFACES zgtpp_if_list_handler.
ENDCLASS.

CLASS lcl_list_handler IMPLEMENTATION.
  METHOD zgtpp_if_list_handler~handle_field_catalog.
    PERFORM handle_field_catalog USING sender.
  ENDMETHOD.

  METHOD zgtpp_if_list_handler~handle_layout.
    PERFORM handle_layout USING sender.
  ENDMETHOD.

  METHOD zgtpp_if_list_handler~handle_toolbar.
    PERFORM handle_toolbar USING sender e_object.
  ENDMETHOD.

  METHOD zgtpp_if_list_handler~handle_user_command.
    PERFORM handle_user_command USING sender e_ucomm.
  ENDMETHOD.

  METHOD zgtpp_if_list_handler~handle_double_click.
    PERFORM handle_double_click USING sender es_row_no e_column.
  ENDMETHOD.

  METHOD zgtpp_if_list_handler~handle_data_changed.
    PERFORM handle_data_changed USING sender er_data_changed e_ucomm.
  ENDMETHOD.

  METHOD zgtpp_if_list_handler~handle_data_changed_finished.
    PERFORM handle_data_changed_fini USING sender et_good_cells e_modified.
  ENDMETHOD.
ENDCLASS.

CLASS lcx_exception DEFINITION INHERITING FROM cx_static_check.
  PUBLIC SECTION.
    INTERFACES if_t100_dyn_msg.
ENDCLASS.
