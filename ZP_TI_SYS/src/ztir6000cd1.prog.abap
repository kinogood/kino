************************************************************************
* Title         :  ZTIR6000CD1                                         *
*                                                                      *
* Description   : 수입 L/G document용 Classes Definition Include       *
*                                                                      *
* Creation Date : 2004/03/12                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* dd-mmm-yyyy  xxxxxxxxxxxxxxx  DVPK9xxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  *
*                                                                      *
*                                                                      *
*----------------------------------------------------------------------*


*----------------------------------------------------------------------*
* Items View                                                           *
*----------------------------------------------------------------------*
CLASS lcl_item_view DEFINITION.

  PUBLIC SECTION.

    METHODS: constructor,
             get_data      importing   state   type i optional
                           EXPORTING   ex_data TYPE ZTISRQIT
                           EXCEPTIONS  failure,
             SET_DATA      IMPORTING   IM_DATA TYPE ZTISRQIT,
             chp_add_hash_entry
                           IMPORTING   IM_DATA TYPE ZTISRQIT.

  PROTECTED SECTION.
    TYPES:
      BEGIN OF item_hash_entry,
         item   TYPE REF TO cl_po_item_handle_mm,
         data   TYPE ZTISRQIT,
      END OF item_hash_entry .

    DATA : my_item_proposer TYPE REF TO if_dataprovider_mm,
           item_hash_table TYPE HASHED TABLE OF
           item_hash_entry WITH UNIQUE KEY item,
           CHP_HASH_TABLE  TYPE HASHED TABLE OF
           item_hash_entry WITH UNIQUE KEY item.

ENDCLASS.                    "lcl_item_view DEFINITION


*----------------------------------------------------------------------*
* Document View                                                     *
*----------------------------------------------------------------------*
CLASS lcl_document_view DEFINITION INHERITING FROM
                                     cl_composite_screen_view_mm.

  PUBLIC SECTION.

    INTERFACES: if_model_holder_mm.

    CLASS-METHODS class_constructor.

    METHODS set_application
            IMPORTING
              im_application TYPE REF TO lcl_application.


*  Tree
    METHODS handle_tree
                FOR EVENT row_selected OF cl_table_model_tree_view_mm
                IMPORTING sender
                          ex_row_pointer
                          ex_fieldcatalog.
    DATA:
* the actual model - single or aggregate
        my_model               TYPE REF TO if_model_mm READ-ONLY,
* the application object
        my_application         TYPE REF TO lcl_application
                                                     READ-ONLY.

ENDCLASS.                    "lcl_document_view DEFINITION


*---------------------------------------------------------------------*
*       CLASS lcl_shopping_basket DEFINITION
*---------------------------------------------------------------------*
CLASS lcl_shopping_basket   DEFINITION INHERITING FROM
                                 cl_model_control_view_mm.

  PUBLIC SECTION.

    METHODS:   transport_to_model  REDEFINITION,
               set_model           REDEFINITION,
               if_serializable_mm~read_from REDEFINITION,
               if_serializable_mm~write_to  REDEFINITION,
               constructor         IMPORTING im_dynpro TYPE sy-dynnr
                                             im_prog   TYPE sy-repid
                                             im_container_name TYPE c,
               accept_flavor
                       IMPORTING im_flavor TYPE mmpur_flavor.

    METHODS:   handle_data_dropped FOR EVENT
                       event_data_received OF
                       cl_drag_drop_controller_mm
                       IMPORTING ex_table_model sender.

    METHODS:   handle_picture_fcode FOR EVENT
                       event_fcode_received OF
                       cl_drag_drop_controller_mm
                       IMPORTING fcode sender.

    METHODS:   get_dragdrop_controller
                     RETURNING value(re_cnt) TYPE REF TO
                                cl_drag_drop_controller_mm.

  PROTECTED SECTION.
    METHODS:  execute_before_transport   REDEFINITION.
    METHODS:  subject_changed            REDEFINITION,
              build_dynpro_fields        REDEFINITION.
    METHODS:  init_control               REDEFINITION,
              drop_action.

    DATA: my_picture_control       TYPE REF TO cl_gui_picture.
    DATA: my_fcode_dropped         TYPE sysuuid_c.
    DATA: my_table_model           TYPE REF TO cl_table_model_mm.
    DATA: my_drop_enabled          TYPE char1  VALUE c_true.
    DATA: my_drag_drop_msg_obj     TYPE REF TO cl_dragdrop.
    DATA: my_event_receiver        TYPE REF TO
                                   cl_drag_drop_controller_mm.
    DATA: my_flavors               TYPE STANDARD TABLE OF
                                   mmpur_flavor INITIAL SIZE 0.
  PRIVATE SECTION.

ENDCLASS.                    "LCL_SHOPPING_BASKET DEFINITION
