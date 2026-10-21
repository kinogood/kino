*----------------------------------------------------------------------*
*   INCLUDE LMEQUERYCD1                                                *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       CLASS lcl_datablade_factory DEFINITION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 class lcl_datablade_factory definition.
   public section.
     interfaces: if_datablade_factory_mm.
   protected section.
     methods:    create_abap_query
                             importing
                                     im_handle     type slis_handl
                                     im_query_name type c
                                     im_variant    type c optional
                             returning value(re_abap_query) type
                                     ref to cl_abap_query_mm.

 endclass.

*---------------------------------------------------------------------*
*       CLASS lcl_abap_query_setupv DEFINITION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*
*class lcl_abap_query_setupv definition inheriting from
*          CL_BASIC_MODEL_VIEW_MM.
*
*  PUBLIC SECTION.
*
*    METHODS:  set_model            REDEFINITION.
*    METHODS:  execute              REDEFINITION.
*
*  PROTECTED SECTION.
*
*    METHODS:  transport_from_model REDEFINITION,
*              transport_from_dynp    REDEFINITION.
*
*endclass.

*---------------------------------------------------------------------*
*       CLASS lcl_sap_sql_query_setupv DEFINITION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 class lcl_sap_sql_query_setupv definition inheriting from
           cl_basic_model_view_mm.
 endclass.

*---------------------------------------------------------------------*
*       CLASS lcl_abap_query DEFINITION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*class lcl_abap_query        definition.
*
*  public section.
*    interfaces: if_datablade_mm, if_serializable_mm, if_model_mm.
*
*    methods constructor    importing  im_query_name type aqadef-quname
*                                      im_workspace  type aqadef-wsid
*                                        default 'X'
*                                      im_usergroup  type aqadef-bgname
*                                        default '/SAPQUERY/ME'
*                                      im_variant    type aqadef-vari
*                                                          optional.
*
*
*    methods set_via_screen importing im_via_screen type c.
*
*    methods get_data exporting ex_data type rs38r.
*    methods set_data importing im_data type rs38r.
*
*    data: gl_via_screen type c.
*
*  private section.
*
*    methods: create_report.
*
*    data: workspace type aqadef-wsid.
*    data: usergroup type aqadef-bgname.
*    data: query_name type AQADEF-QUNAME.
*    data: variant    type AQADEF-VARI.
*    data: repname    type AQADEF-PGNAME.
*
*endclass.

*---------------------------------------------------------------------*
*       CLASS lcl_sap_sql_sel DEFINITION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 class lcl_sap_sql_sel      definition.

   public section.
     interfaces: if_datablade_mm.

     methods constructor    importing  im_user_name type sy-uname
                                       im_memory type c optional.

   private section.

     data: my_user_name    type sy-uname,
           my_memory_flag(1) type c,
           my_abap_query   type ref to cl_abap_query_mm.

 endclass.

*---------------------------------------------------------------------*
*       CLASS lcl_parked_pos_query DEFINITION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
* class lcl_parked_pos_query           definition.

*   public section.
*     interfaces: if_datablade_mm.

*     methods constructor    importing  im_user_name type sy-uname.

*   private section.

*     data: l_user_name type sy-uname.

* endclass.
*---------------------------------------------------------------------*
*       CLASS lcl_sel_requisitions DEFINITION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
* class lcl_sel_requisitions definition.
*
*   public section.
*     interfaces: if_datablade_mm.
*
* endclass.


*---------------------------------------------------------------------*
*       CLASS lcl_query_controller DEFINITION
*---------------------------------------------------------------------*
*       moved to class builder                                        *
*---------------------------------------------------------------------*
*
*class lcl_query_controller   definition inheriting from
*                                     cl_controller_mm.
*
*  public section.
*
*    interfaces: if_serializable_mm, if_subject_mm.
*
*    methods constructor    importing  im_table_model type ref to
*                                          cl_table_model_mm
*                                      im_name    type string40
*                                      im_factory type ref to
*                                       if_datablade_factory_mm.
*
*    methods execute redefinition.
*    methods  can_handle_fcode redefinition.
*    methods: new  importing im_classid type mmpur_databl_classid,
*             setup importing im_blade type ref to
*                             if_datablade_mm,
*             remove_datablade importing im_datablade type ref to
*                             if_datablade_mm.
*
*    methods: create_context_menu
*                              returning value(re_menu) type
*                                 ref to cl_ctmenu.
*  private section.
*
*    methods select importing im_index type sy-tabix
*                   exporting ex_blade type ref to if_datablade_mm.
*
*    data: my_factory          type ref to if_datablade_factory_mm.
*    data: my_datablades       type ref to if_datablade_mm occurs 0.
*    data: a_table_model       type ref to cl_table_model_mm.
*    data: my_index            type sy-tabix.
*    data: my_name             type string40.
*    data: my_fcode_prefix     type SYSUUID_C.
*
*endclass.

 class lcl_abap_query_setup_cmd      definition.

   public section.
     interfaces: if_simple_command_mm.
     methods:    constructor importing im_abap_query type ref to
                                                cl_abap_query_mm.
   private section.

     data: my_abap_query type ref to cl_abap_query_mm.

 endclass.

*---------------------------------------------------------------------*
*       CLASS lcl_abap_query_setup_cmd IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 class lcl_abap_query_setup_cmd  implementation.

   method constructor.
     my_abap_query = im_abap_query.
   endmethod.
   method if_simple_command_mm~execute.
     call method my_abap_query->set_via_screen( 'X' ).
   endmethod.

 endclass.
