*----------------------------------------------------------------------*
*   INCLUDE LMEQUERYCI1                                                *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       CLASS lcl_datablade_factory IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 CLASS lcl_datablade_factory IMPLEMENTATION.

   METHOD if_datablade_factory_mm~create_datablade.

     CASE im_classid.
       WHEN 'SDOC_QUERY'.
        re_datablade = create_abap_query( im_query_name =
        'ZTIQUERY_LC_01'
                         im_variant = ' '
                         im_handle  = '0001' ).
       WHEN OTHERS.

     ENDCASE.

     IF NOT re_datablade IS INITIAL.
       re_datablade->class_id = im_classid.
     ENDIF.

   ENDMETHOD. "if_datablade_factory_mm~create_datablade

   METHOD if_datablade_factory_mm~create_datablade_setupview.
     DATA: l_abap_query TYPE REF TO cl_abap_query_mm.
     DATA: l_pos_by_user_query TYPE REF TO lcl_sap_sql_sel.

   ENDMETHOD. "if_datablade_factory_mm~create_datablade_setupview

   METHOD if_datablade_factory_mm~create_datablade_setupcommand.
     DATA: l_abap_query TYPE REF TO cl_abap_query_mm.
     DATA: l_pos_by_user_query TYPE REF TO lcl_sap_sql_sel.
     DATA: l_cmd1 TYPE REF TO lcl_abap_query_setup_cmd.

     mmpur_dynamic_cast l_abap_query im_blade.

     IF NOT l_abap_query IS INITIAL.
       CREATE OBJECT l_cmd1 EXPORTING im_abap_query = l_abap_query.
       re_command = l_cmd1.
     ENDIF.

     mmpur_dynamic_cast l_pos_by_user_query im_blade.

     IF NOT l_pos_by_user_query IS INITIAL.
     ENDIF.

   ENDMETHOD. "if_datablade_factory_mm~create_datablade_setupcommand

   METHOD if_datablade_factory_mm~get_available_datablades.
     DATA: l_wa LIKE LINE OF re_meta_table.

     l_wa-classid = 'SDOC_QUERY'.
     l_wa-label   = text-003.
     APPEND l_wa TO re_meta_table.

   ENDMETHOD. "if_datablade_factory_mm~get_available_datablades

   METHOD create_abap_query.
     DATA: l_abap_query TYPE REF TO cl_abap_query_mm,
           l_query_name TYPE aqadef-quname,
           l_vari       TYPE aqadef-vari.

     l_query_name =  im_query_name.
     l_vari       =  im_variant.

     CREATE OBJECT l_abap_query EXPORTING
                                 im_handle     = im_handle
                                 im_usergroup  = 'ZTIQUERY'
                                 im_query_name = l_query_name.
*                                 im_variant    = l_vari.

     re_abap_query = l_abap_query.
   ENDMETHOD.                    "create_abap_query

 ENDCLASS.                    "lcl_datablade_factory IMPLEMENTATION

*---------------------------------------------------------------------*
*       CLASS lcl_abap_query_setupv IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*
*class lcl_abap_query_setupv implementation.
*  METHOD   TRANSPORT_FROM_MODEL.
*    data: l_query type ref to lcl_abap_query.
*
*    IF MY_MODEL IS INITIAL.
*      CLEAR RS38R.
*    ELSE.
*      L_query ?= MY_MODEL.
*      CALL METHOD L_query->GET_DATA IMPORTING EX_DATA = rs38r.
*    ENDIF.
*  ENDMETHOD.
*
*  METHOD EXECUTE.
*    data: l_query type ref to lcl_abap_query.
*    if im_fcode eq 'QUERYVARIANTE'.
*      L_query ?= MY_MODEL.
*      CALL METHOD L_query->set_via_screen
*                    exporting im_via_screen = 'X'.
*      set screen 0.
*      leave screen.
*    ENDIF.
*  ENDMETHOD.
*
*  METHOD TRANSPORT_FROM_DYNP.
*
*    data: l_query type ref to lcl_abap_query.
*
*    IF MY_MODEL IS INITIAL.
*    ELSE.
*      L_query ?= MY_MODEL.
*      CALL METHOD L_query->SET_DATA EXPORTING IM_DATA = rs38r.
*    ENDIF.
*
*  ENDMETHOD.
*
*  METHOD SET_MODEL.
*
*    data: l_query type ref to lcl_abap_query.
*
*    mmpur_dynamic_cast l_query im_model.
*
*    if not l_query is initial.
*
*      call method super->set_model( im_model ).
*
*    endif.
*  endmethod.
*
*endclass.

*---------------------------------------------------------------------*
*       CLASS lcl_sap_POS_BY_USER_QUERY_setupv IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 CLASS lcl_sap_sql_query_setupv IMPLEMENTATION.

 ENDCLASS.                    "lcl_sap_sql_QUERY_setupv IMPLEMENTATION

*---------------------------------------------------------------------*
*       CLASS lcl_abap_query IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*
*class lcl_abap_query        implementation.
*
*  method constructor.
*    query_name = im_query_name.
*    variant    = im_variant.
*    workspace  = im_workspace.
*    usergroup  = im_usergroup.
*  endmethod.
*
*  method set_via_screen.
*    gl_via_screen = im_via_screen.
*  endmethod.
*
*  method get_data.
*    ex_data-qnum = query_name.
*    ex_data-variant = variant.
*  endmethod.
*
*  method set_data.
*    query_name = im_data-qnum.
*    variant = im_data-variant.
*  endmethod.
*
*  method if_reader_mm~read_string.
*  endmethod.
*
*  method if_reader_mm~read_integer.
*  endmethod.
*
*  method if_reader_mm~read_object.
*  endmethod.
*
*  method if_reader_mm~read_root.
*  endmethod.
*
*  method create_report.
*    data: l_variant like variant.
*
*    if repname is initial.
*      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*           EXPORTING
*                PERCENTAGE = 10
*                TEXT       = 'Erzeuge ABAP Query Report'(002).
*
*      CALL FUNCTION 'RSAQ_CREATE_QUERY_REPORT'
*           EXPORTING
*                WORKSPACE            = workspace
*                USERGROUP            = usergroup
*                QUERY                = query_name
*           IMPORTING
*                REPORTNAME           = repname
*                STD_VARIANT          = l_variant
*           EXCEPTIONS
*                NO_USERGROUP         = 1
*                NO_QUERY             = 2
*                QUERY_LOCKED         = 3
*                GENERATION_CANCELLED = 4
*                OTHERS               = 5.
*      IF SY-SUBRC <> 0.
*        raise not_found.
*      ENDIF.
*
*      if variant is initial.
*        variant = l_variant.
*      endif.
*
*    endif.
*
*  endmethod.
*
*  method if_reader_mm~read_table.
*
*    data: l_dynamic_data type MMQUE_DYNAMIC_STRUCTURE.
*
*    call method create_report.
*
*    check not repname is initial.
*
*    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*         EXPORTING
*              PERCENTAGE = 50
*              TEXT       = 'Starte ABAP Query'(001).
*
* show selection screen?
*    if gl_via_screen is initial.
*      Submit (repname) using selection-set VARIANT and return.
*    else.
*     Submit (repname) via selection-screen using selection-set VARIANT
*                                      and return.
*      clear: gl_via_screen.           "only once !
*    endif.
*
*    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*         EXPORTING
*              PERCENTAGE = 90
*              TEXT       = 'Starte ABAP Query'(001).
*
*    CALL FUNCTION 'MMQUERY_GET_DATA'
*         EXPORTING
*              IM_REPID        = repname
*         IMPORTING
*              EX_DYNAMIC_DATA = l_dynamic_data.
*
*    variant           = l_dynamic_data-variant.
*    ex_fieldcatalog[] = l_dynamic_data-fieldcatalog[].
*    ex_table_ref      = l_dynamic_data-table_pointer.
*
*    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*         EXPORTING
*              PERCENTAGE = 100
*              TEXT       = 'Starte ABAP Query'(001).
*
*  endmethod.
*
*  method if_serializable_mm~read_from.
*    data: l_variant like variant.
*
*    call method im_reader->read_string
*                          exporting im_name = query_name
*                          receiving re_value = l_variant
*                          exceptions not_found = 1.
*
*    if sy-subrc eq 0.
*      variant = l_variant.
*    endif.
*
*  endmethod.
*
*  method if_serializable_mm~write_to.
*    data: l_string type ES_ELEMENT.
*    l_string = variant.
*
*    call method im_writer->write_string( im_name = query_name
*                                         im_value = l_string ).
*  endmethod.
*
*  method if_datablade_mm~get_class_label.
*    re_label = 'ABAP Query'(008).
*  endmethod.
*
*  method if_datablade_mm~get_label.
*    call method create_report.
*    if variant is initial.
*      re_label = if_datablade_mm~get_class_label( ).
*    else.
*      re_label = variant.
*    endif.
*  endmethod.
*endclass.

*---------------------------------------------------------------------*
*       CLASS lcl_sap_sql_sel IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 CLASS lcl_sap_sql_sel       IMPLEMENTATION.

   METHOD constructor.
     my_user_name = im_user_name.
     my_memory_flag = im_memory.

     CREATE OBJECT my_abap_query EXPORTING
                               im_handle     = '0001'
                               im_query_name = 'MEPO'
                               im_variant    = 'SAP&MEPOBEST'.

   ENDMETHOD.                    "constructor

   METHOD if_reader_mm~read_string.
   ENDMETHOD.                    "if_reader_mm~read_string

   METHOD if_reader_mm~read_integer.
   ENDMETHOD.                    "if_reader_mm~read_integer

   METHOD if_reader_mm~read_object.
   ENDMETHOD.                    "if_reader_mm~read_object

   METHOD if_reader_mm~read_root.
   ENDMETHOD.                    "if_reader_mm~read_root

   METHOD if_reader_mm~read_table.
*
* select data - max. 5 from sy-user (last used)
*    data: lc_read_max type i value 25.
*    data: l_zaehler   type i.
*    data: lt_ekko type standard table of ekko initial size 0,
*          ls_ekko like line of lt_ekko.
*    data: ls_ekpo type ekpo.
*    data: lt_ekkoekpo type standard table of mequeryekkoekpo
*                     initial size 0,
*          ls_ekkoekpo type mequeryekkoekpo.
*    data: l_structname type dd02l-tabname value 'MEQUERYEKKOEKPO'.
*    data: lt_fieldcatalog type lvc_t_fcat,
*          l_old_lifnr     type ekko-lifnr.
*
*
* intialisation
*    refresh: lt_ekkoekpo,
*             lt_ekko.
* select from ekko
*    SELECT  * from ekko
*       into corresponding fields of table lt_ekko
*            where bstyp eq 'F' and
*                  ernam = l_user_name.
*
*    sort lt_ekko by lifnr bedat descending.
*
* select from ekpo
*    loop at lt_ekko into ls_ekko.
*      if ls_ekko-lifnr ne l_old_lifnr.
*        clear: l_zaehler.
*        l_old_lifnr = ls_ekko-lifnr.
*      endif.
*      add 1 to l_zaehler.
*      check l_zaehler <= lc_read_max.
*      select * from ekpo into ls_ekpo
*         where ebeln = ls_ekko-ebeln.
*        move-corresponding ls_ekko to ls_ekkoekpo.
*        move-corresponding ls_ekpo to ls_ekkoekpo.
*        append ls_ekkoekpo to lt_ekkoekpo.
*      endselect.
*    endloop.
*
*    ex_structname = l_structname.
*    ex_table[]    = lt_ekkoekpo[].
*
*    call function 'LVC_FIELDCATALOG_MERGE'
*         EXPORTING
*              i_structure_name = 'MEQUERYEKKOEKPO'
*         CHANGING
*              ct_fieldcat      = lt_fieldcatalog[].
*
*    ex_fieldcatalog[] = lt_fieldcatalog[].
*
*    create data ex_table_ref like lt_ekkoekpo[].
*
*    field-symbols: <tab> type table.
*    assign ex_table_ref->* to <tab>.
*    <tab>[] = lt_ekkoekpo[].
*
*    data: l_user_name type TVARV_VAL.
*
*    l_user_name = my_user_name.
*
*    call method my_abap_query->refresh_sel_options.
*
*    call method my_abap_query->add_sel_option
*                     exporting im_fieldname = 'EKKO-ERNAM'
*                               im_low       = l_user_name.
*
*    if not my_memory_flag is initial.
*      call method my_abap_query->add_sel_option
*                     exporting im_fieldname = 'EKKO-MEMORY'
*                               im_low       = 'X'
*                     exceptions others = 1.
*    endif.
*
*    call method my_abap_query->if_reader_mm~read_table
*                 exporting  IM_NAME    = 'dummy'
*                 importing  EX_TABLE   = ex_table
*                            EX_STRUCTNAME = ex_structname
*                            EX_FIELDCATALOG = ex_fieldcatalog
*                            EX_TABLE_REF = ex_table_ref
*                 exceptions NOT_FOUND = 1
*                            CANCELLED = 2.
*
*     if sy-subrc eq 1.
*        raise not_found.
*     elseif sy-subrc eq 2.
*        raise cancelled.
*     endif.
*
   ENDMETHOD.                    "if_reader_mm~read_table
*
   METHOD if_datablade_mm~get_class_label.
     re_label = 'Meine Bestellungen'(011).
   ENDMETHOD.                    "if_datablade_mm~get_class_label
*
   METHOD if_datablade_mm~get_label.
     IF my_memory_flag IS INITIAL.
       re_label = 'Meine Bestellungen'(011).
     ELSE.
       re_label = 'Meine vorerfa?en Bestellungen'(010).
     ENDIF.
   ENDMETHOD.                    "if_datablade_mm~get_label
*
   METHOD if_datablade_mm~get_handle.
     re_handle = my_abap_query->if_datablade_mm~get_handle( ).
   ENDMETHOD.                    "if_datablade_mm~get_handle
 ENDCLASS.                    "lcl_sap_sql_sel IMPLEMENTATION

*---------------------------------------------------------------------*
*       CLASS lcl_parked_pos_query IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
* class lcl_parked_pos_query            implementation.
*
*   method constructor.
*     l_user_name = im_user_name.
*   endmethod.

*   method if_reader_mm~read_string.
*   endmethod.
*
*   method if_reader_mm~read_integer.
*   endmethod.
*
*   method if_reader_mm~read_object.
*   endmethod.
*
*   method if_reader_mm~read_root.
*   endmethod.
*
*   method if_reader_mm~read_table.
* select data - max. 5 from sy-user (last used)
*     data: lc_read_max type i value 5.
*     data: l_zaehler   type i.
*     data: lt_ekko type standard table of ekko initial size 0,
*           ls_ekko like line of lt_ekko.
*     data: ls_ekpo type ekpo.
*     data: lt_ekkoekpo type standard table of mequeryekkoekpo
*             initial size 0,
*           ls_ekkoekpo type mequeryekkoekpo.
*     data: l_structname type dd02l-tabname value 'MEQUERYEKKOEKPO'.
*     data: lt_fieldcatalog type lvc_t_fcat,
*           l_old_lifnr type ekko-lifnr.

* intialisation
*     refresh: lt_ekkoekpo,
*              lt_ekko.
* select from ekko
*     SELECT  * from ekko
*        into corresponding fields of table lt_ekko
*               where
*                   memory eq 'X' and ernam eq sy-uname.
*
*     sort lt_ekko by bedat descending.
*
* select from ekpo
*     loop at lt_ekko into ls_ekko.
*       if ls_ekko-lifnr ne l_old_lifnr.
*         clear: l_zaehler.
*         l_old_lifnr = ls_ekko-lifnr.
*       endif.
*       add 1 to l_zaehler.
*      check l_zaehler <= lc_read_max.
*      select * from ekpo into ls_ekpo
*          where ebeln = ls_ekko-ebeln.
*         move-corresponding ls_ekko to ls_ekkoekpo.
*         move-corresponding ls_ekpo to ls_ekkoekpo.
*         append ls_ekkoekpo to lt_ekkoekpo.
*       endselect.
*     endloop.
*
*     ex_structname = l_structname.
*     ex_table[]    = lt_ekkoekpo[].
*
*     call function 'LVC_FIELDCATALOG_MERGE'
*          EXPORTING
*              i_structure_name = 'MEQUERYEKKOEKPO'
*          CHANGING
*               ct_fieldcat      = lt_fieldcatalog[].
*
*     ex_fieldcatalog[] = lt_fieldcatalog[].
*
*     create data ex_table_ref like lt_ekkoekpo[].
*
*     field-symbols: <tab> type table.
*     assign ex_table_ref->* to <tab>.
*     <tab>[] = lt_ekkoekpo[].
*
*  endmethod.
*
*   method if_datablade_mm~get_class_label.
*     re_label = 'Vorerfa?e Bestellungen'(007).
*  endmethod.

*  method if_datablade_mm~get_label.
*    re_label = 'Meine vorerfa?en Bestellungen'(010).
*  endmethod.

*   method if_datablade_mm~get_handle.
*     re_handle = 'MYPP'.
*   endmethod.
*endclass.

*---------------------------------------------------------------------*
*       CLASS lcl_sel_requisitions IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
* class lcl_sel_requisitions    implementation.
*
*   method if_reader_mm~read_string.
*  endmethod.
*
*   method if_reader_mm~read_integer.
*   endmethod.
*
*   method if_reader_mm~read_object.
*   endmethod.
*
*   method if_reader_mm~read_root.
*   endmethod.
*
*   method if_reader_mm~read_table.
*
*     data: lt_ebans        type standard table of eban initial size 0,
*           lt_fieldcatalog type lvc_t_fcat.
*     field-symbols: <tab> type table.
*
*     create data ex_table_ref like lt_ebans[].
*
*     assign ex_table_ref->* to <tab>.
*
*     select * from eban into table <tab>
*         where bsmng < eban~menge and
*               ebakz eq space.
*
*     call function 'LVC_FIELDCATALOG_MERGE'
*          EXPORTING
*               i_structure_name = 'EBAN'
*          CHANGING
*               ct_fieldcat      = lt_fieldcatalog[].
*
*     ex_fieldcatalog[] = lt_fieldcatalog[].
*
*   endmethod.
*
*   method if_datablade_mm~get_class_label.
*     re_label = text-006.
*   endmethod.
*+
*+  method if_datablade_mm~get_label.
*+     re_label = text-006.
*   endmethod.
* endclass.
