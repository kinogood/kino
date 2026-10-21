*&---------------------------------------------------------------------*
*& Include          ZGTPPR1150C01
*&---------------------------------------------------------------------*
CLASS lcl_list_handler DEFINITION.
  PUBLIC SECTION.
    INTERFACES zgtpp_if_list_handler.
ENDCLASS.

CLASS lcl_list_handler IMPLEMENTATION.
  METHOD zgtpp_if_list_handler~handle_field_catalog.
    PERFORM handle_field_catalog.
  ENDMETHOD.

  METHOD zgtpp_if_list_handler~handle_layout.
    PERFORM handle_layout.
  ENDMETHOD.

  METHOD zgtpp_if_list_handler~handle_toolbar.
    PERFORM handle_toolbar USING e_object.
  ENDMETHOD.

  METHOD zgtpp_if_list_handler~handle_user_command.
    PERFORM handle_user_command USING e_ucomm.
  ENDMETHOD.

  METHOD zgtpp_if_list_handler~handle_data_changed.
    PERFORM handle_data_changed USING er_data_changed e_ucomm.
  ENDMETHOD.

  METHOD zgtpp_if_list_handler~handle_data_changed_finished.
    PERFORM handle_data_changed_fini USING et_good_cells e_modified.
  ENDMETHOD.

  METHOD zgtpp_if_list_handler~handle_f4.
    PERFORM handle_f4.
  ENDMETHOD.

  METHOD zgtpp_if_list_handler~handle_on_f4.
    PERFORM handle_on_f4 USING e_fieldname e_fieldvalue es_row_no
                               er_event_data et_bad_cells e_display.
  ENDMETHOD.

ENDCLASS.

CLASS lcx_exception DEFINITION INHERITING FROM cx_static_check.
  PUBLIC SECTION.
    INTERFACES if_t100_dyn_msg.
ENDCLASS.
