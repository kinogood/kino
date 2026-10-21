INTERFACE zgtpp_if_list
  PUBLIC .

  EVENTS field_catalog .
  EVENTS layout .
  EVENTS sort .
  EVENTS popup
    EXPORTING
      VALUE(ir_salv_table) TYPE REF TO cl_salv_table .
  EVENTS f4 .

  CLASS-METHODS display_message
    IMPORTING
      !iv_zeile   TYPE abap_bool OPTIONAL
      !it_message TYPE bapiret2_tab .
  METHODS initialize
    IMPORTING
      !ir_container   TYPE REF TO cl_gui_container OPTIONAL
      !it_list_header TYPE stringtab OPTIONAL
      !is_variant     TYPE disvariant OPTIONAL
      !ir_handler     TYPE REF TO zgtpp_if_list_handler OPTIONAL
      !iv_repid       TYPE sy-repid OPTIONAL
      !iv_dynnr       TYPE sy-dynnr OPTIONAL
      !iv_default     TYPE abap_bool OPTIONAL
      !iv_popup       TYPE abap_bool OPTIONAL
      !iv_rowins      TYPE abap_bool
      !iv_extension   TYPE i OPTIONAL
    CHANGING
      !ct_data        TYPE table .
  METHODS list_specific_setting
    IMPORTING
      !ir_handler TYPE REF TO zgtpp_if_list_handler .
  METHODS display
    IMPORTING
      !ir_container   TYPE REF TO cl_gui_container OPTIONAL
      !ir_handler     TYPE REF TO zgtpp_if_list_handler OPTIONAL
      !is_variant     TYPE disvariant OPTIONAL
      !it_list_header TYPE stringtab OPTIONAL
      !iv_repid       TYPE sy-repid OPTIONAL
      !iv_dynnr       TYPE sy-dynnr OPTIONAL
      !iv_default     TYPE abap_bool OPTIONAL
      !iv_popup       TYPE abap_bool OPTIONAL
      !iv_rowins      TYPE abap_bool OPTIONAL
      !iv_extension   TYPE i DEFAULT 2000
    CHANGING
      !ct_data        TYPE table .
  METHODS refresh
    IMPORTING
      !iv_opt TYPE abap_bool DEFAULT 'X' .
  METHODS set_basic_attribute
    IMPORTING
      !iv_rowins TYPE abap_bool OPTIONAL
    CHANGING
      !ct_data   TYPE table .
  METHODS set_display_variant
    IMPORTING
      !is_variant TYPE disvariant .
  METHODS set_list_header
    IMPORTING
      !it_list_header TYPE stringtab .
  METHODS create_docking_container
    IMPORTING
      !iv_popup TYPE abap_bool OPTIONAL .
  METHODS create_splitter_container
    IMPORTING
      !it_list_header TYPE stringtab OPTIONAL
      !ir_container   TYPE REF TO cl_gui_container .
  METHODS set_handler
    IMPORTING
      !ir_handler TYPE REF TO zgtpp_if_list_handler .
  METHODS popup_display
    IMPORTING
      !ir_handler TYPE REF TO zgtpp_if_list_handler OPTIONAL
    CHANGING
      !ct_data    TYPE table .
  METHODS set_edit_event .
  METHODS free .
ENDINTERFACE.
