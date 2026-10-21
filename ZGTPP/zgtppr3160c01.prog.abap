*&---------------------------------------------------------------------*
*& Include          ZGTPPR3160C01
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

  METHOD zgtpp_if_list_handler~handle_print_top_of_list.
    PERFORM handle_print_top_of_list.
  ENDMETHOD.
ENDCLASS.

CLASS lcx_exception DEFINITION INHERITING FROM cx_static_check.
  PUBLIC SECTION.
    INTERFACES if_t100_dyn_msg.
ENDCLASS.
