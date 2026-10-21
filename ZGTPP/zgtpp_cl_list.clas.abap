class ZGTPP_CL_LIST definition
  public
  final
  create public .

public section.

  interfaces ZGTPP_IF_LIST .

  aliases CREATE_DOCKING_CONTAINER
    for ZGTPP_IF_LIST~CREATE_DOCKING_CONTAINER .
  aliases CREATE_SPLITTER_CONTAINER
    for ZGTPP_IF_LIST~CREATE_SPLITTER_CONTAINER .
  aliases DISPLAY
    for ZGTPP_IF_LIST~DISPLAY .
  aliases DISPLAY_MESSAGE
    for ZGTPP_IF_LIST~DISPLAY_MESSAGE .
  aliases FREE
    for ZGTPP_IF_LIST~FREE .
  aliases INITIALIZE
    for ZGTPP_IF_LIST~INITIALIZE .
  aliases LIST_SPECIFIC_SETTING
    for ZGTPP_IF_LIST~LIST_SPECIFIC_SETTING .
  aliases POPUP_DISPLAY
    for ZGTPP_IF_LIST~POPUP_DISPLAY .
  aliases REFRESH
    for ZGTPP_IF_LIST~REFRESH .
  aliases SET_BASIC_ATTRIBUTE
    for ZGTPP_IF_LIST~SET_BASIC_ATTRIBUTE .
  aliases SET_DISPLAY_VARIANT
    for ZGTPP_IF_LIST~SET_DISPLAY_VARIANT .
  aliases SET_EDIT_EVENT
    for ZGTPP_IF_LIST~SET_EDIT_EVENT .
  aliases SET_HANDLER
    for ZGTPP_IF_LIST~SET_HANDLER .
  aliases SET_LIST_HEADER
    for ZGTPP_IF_LIST~SET_LIST_HEADER .
  aliases F4
    for ZGTPP_IF_LIST~F4 .
  aliases FIELD_CATALOG
    for ZGTPP_IF_LIST~FIELD_CATALOG .
  aliases LAYOUT
    for ZGTPP_IF_LIST~LAYOUT .
  aliases POPUP
    for ZGTPP_IF_LIST~POPUP .
  aliases SORT
    for ZGTPP_IF_LIST~SORT .

  data MV_DYNNR type DYNNR .
  data MV_REPID type REPID .
  data MV_DEFAULT type ABAP_BOOL .
  data MR_GRID type ref to CL_GUI_ALV_GRID .
  data MT_FCAT type LVC_T_FCAT .
  data MT_SORT type LVC_T_SORT .
  data MT_FILTER type LVC_T_FILT .
  data MT_F4 type LVC_T_F4 .
  data MS_LAYOUT type LVC_S_LAYO .
  data MR_SALV_TABLE type ref to CL_SALV_TABLE .
  data MT_EXCLUDING type UI_FUNCTIONS .
  data MS_VARIANT type DISVARIANT .
  data MV_EXTENSION type I .
  data MR_DATA type ref to DATA .
  data MV_RATIO type I .

  methods FIRST_DISPLAY
    changing
      !CT_DATA type TABLE .
  methods WUBGUI_IS_RUNNING
    returning
      value(RV_RESULT) type ABAP_BOOL .
  methods TABLE_TO_FIELDCATALOG
    importing
      value(IV_CFIELD) type CHAR01 default 'X'
      value(IV_CL_ABAP_TABLEDESCR) type CHAR01 default 'X' .
  methods GET_ELEMENTS
    importing
      !IT_COMP type CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE
    returning
      value(RT_COMP) type CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE .
  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA mr_docking_container TYPE REF TO cl_gui_docking_container .
    DATA mr_splitter_container TYPE REF TO cl_gui_splitter_container .
    DATA mr_top_container TYPE REF TO cl_gui_container .
    DATA mr_alv_container TYPE REF TO cl_gui_container .
    DATA mr_dialog_container TYPE REF TO cl_gui_dialogbox_container .

ENDCLASS.



CLASS ZGTPP_CL_LIST IMPLEMENTATION.


  METHOD first_display.

    mr_grid->set_table_for_first_display( EXPORTING  i_bypassing_buffer            = abap_true
                                                     is_variant                    = ms_variant
                                                     i_save                        = 'A'
                                                     i_default                     = mv_default
                                                     is_layout                     = ms_layout
                                                     it_toolbar_excluding          = mt_excluding
                                          CHANGING   it_fieldcatalog               = mt_fcat
                                                     it_sort                       = mt_sort
                                                     it_filter                     = mt_filter
                                                     it_outtab                     = ct_data
                                          EXCEPTIONS invalid_parameter_combination = 1
                                                     program_error                 = 2
                                                     too_many_lines                = 3 ).

    IF sy-subrc IS NOT INITIAL.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.


  METHOD get_elements.
    DATA: lt_comp   TYPE cl_abap_structdescr=>component_table,
          ls_comp   LIKE LINE OF lt_comp,
          lt_comp_d LIKE lt_comp,
          lt_comp_r LIKE lt_comp,
          ls_comp_d LIKE ls_comp,
          lo_stru   TYPE REF TO cl_abap_structdescr,
          lv_index  TYPE sy-index.

    lt_comp[] = it_comp[].

    LOOP AT lt_comp INTO ls_comp WHERE as_include = 'X'.
      lv_index = sy-tabix.
      DELETE lt_comp.
      lo_stru ?= ls_comp-type.
      lt_comp_d = lo_stru->get_components( ).            "Recursive Point
      lt_comp_r = me->get_elements( lt_comp_d ).

      LOOP AT lt_comp_r INTO ls_comp_d.
        INSERT ls_comp_d INTO lt_comp INDEX lv_index.
        lv_index = lv_index + 1.
        CLEAR ls_comp_d.
      ENDLOOP.
      CLEAR : ls_comp, lt_comp_r[].
    ENDLOOP.

    rt_comp = lt_comp.

  ENDMETHOD.


  METHOD table_to_fieldcatalog.
    FIELD-SYMBOLS: <ls_wa>  TYPE any,
                   <ls_cp>  TYPE any,
                   <lt_tab> TYPE STANDARD TABLE.

    DATA: lo_sref      TYPE REF TO data,
          lo_cref      TYPE REF TO data,
          lo_table     TYPE REF TO data,
          lo_stru      TYPE REF TO cl_abap_structdescr,
          lo_clss      TYPE REF TO cl_abap_classdescr,
          lo_elem      TYPE REF TO cl_abap_elemdescr,
          lo_tab       TYPE REF TO cl_abap_tabledescr,
          lt_comp      TYPE cl_abap_structdescr=>component_table,
          lt_comp_     LIKE lt_comp,
          ls_comp      LIKE LINE OF lt_comp,
          lv_hlpid     TYPE string,
          lv_sname     TYPE string,
          ls_fcat      TYPE lvc_s_fcat,
          ls_dfies     TYPE dfies,
          lt_tab       TYPE TABLE OF string,
          lv_refstruct TYPE swcontdef-refstruct,
          lv_reffield  TYPE swcontdef-reffield,
          ls_dd04v     TYPE dd04v,
          lv_len       TYPE i,
          lv_col_pos   TYPE i.

*    CREATE DATA lo_table LIKE it_tab.
    ASSIGN mr_data->* TO <lt_tab>.

    lo_tab  ?= cl_abap_typedescr=>describe_by_data( <lt_tab> ).
    lo_stru ?= lo_tab->get_table_line_type( ).

    lo_clss ?= cl_abap_typedescr=>describe_by_object_ref( lo_stru ).
    IF lo_clss->get_relative_name( ) <> 'CL_ABAP_STRUCTDESCR'.
*      RAISE not_a_structure.
      RETURN.
    ENDIF.

    lt_comp_ = lo_stru->get_components( ).
    LOOP AT lt_comp_ INTO ls_comp.
      lo_clss ?= cl_abap_typedescr=>describe_by_object_ref( ls_comp-type ).
      IF lo_clss->get_relative_name( ) = 'CL_ABAP_TABLEDESCR'.
        ".. Deep Structure 관련 수정
*        IF i_cl_abap_tabledescr = ' '.
*          DELETE lt_comp_.
*        ENDIF.
      ENDIF.
      CLEAR: ls_comp.
    ENDLOOP.

    lt_comp  = me->get_elements( lt_comp_ ).
    lv_sname = lo_stru->absolute_name.

    CREATE DATA lo_sref TYPE HANDLE lo_stru.
    ASSIGN lo_sref->* TO <ls_wa>.

    LOOP AT lt_comp INTO ls_comp.
      ASSIGN COMPONENT ls_comp-name OF STRUCTURE <ls_wa> TO <ls_cp>.
      DESCRIBE FIELD <ls_cp> HELP-ID lv_hlpid.

      CLEAR: lt_tab.
      SPLIT lv_hlpid AT '-' INTO TABLE lt_tab.
      lv_len = lines( lt_tab ).

      IF lv_len = 2.  ".. Struct + Field
        READ TABLE lt_tab INTO lv_refstruct INDEX 1.
        READ TABLE lt_tab INTO lv_reffield  INDEX 2.

        CALL FUNCTION 'SWP_DDIC_FIELD_INFO_GET'
          EXPORTING
            refstruct            = lv_refstruct
            reffield             = lv_reffield
            language             = sy-langu
          IMPORTING
            field_attributes     = ls_dfies
          EXCEPTIONS
            field_info_not_found = 1
            OTHERS               = 9.
        IF sy-subrc = 0 AND ls_dfies IS NOT INITIAL.
          MOVE-CORRESPONDING ls_dfies TO ls_fcat.
          ls_fcat-ref_table = lv_refstruct.
          ls_fcat-tabname   = ''.
          ls_fcat-tooltip   = ls_fcat-reptext.
          ls_fcat-reptext   = ls_fcat-coltext = ls_fcat-scrtext_l.

          IF lv_reffield <> ls_comp-name.
            ls_fcat-ref_field = lv_reffield.
            ls_fcat-fieldname = ls_comp-name.
          ENDIF.

          CASE ls_dfies-datatype.
            WHEN 'CURR'.
              IF line_exists( lt_comp[ name = ls_dfies-reffield ] ).
                ls_fcat-cfieldname = ls_dfies-reffield.
              ENDIF.
            WHEN 'QUAN'.
              IF line_exists( lt_comp[ name = ls_dfies-reffield ] ).
                ls_fcat-qfieldname = ls_dfies-reffield.
              ENDIF.
            WHEN OTHERS.
          ENDCASE.

          ADD 10 TO lv_col_pos. ls_fcat-col_pos = lv_col_pos.
          APPEND ls_fcat TO mt_fcat.
        ENDIF.
      ELSEIF lv_len = 1.  ".. DataElement
        READ TABLE lt_tab INTO lv_reffield INDEX 1.

        CALL FUNCTION 'DDIF_DTEL_GET'
          EXPORTING
            name          = lv_reffield
            langu         = sy-langu
          IMPORTING
            dd04v_wa      = ls_dd04v
          EXCEPTIONS
            illegal_input = 1
            OTHERS        = 2.
        IF sy-subrc = 0 AND ls_dd04v IS NOT INITIAL.
          MOVE-CORRESPONDING ls_dd04v TO ls_fcat.
          ls_fcat-ref_table = ''.
          ls_fcat-tabname   = ''.
          ls_fcat-reptext   = ls_fcat-coltext = ls_fcat-scrtext_l.

          IF lv_reffield <> ls_comp-name.
            ls_fcat-ref_field = lv_reffield.
            ls_fcat-fieldname = ls_comp-name.
          ENDIF.

          IF ls_fcat-fieldname IS INITIAL.
            ls_fcat-fieldname = ls_comp-name.
          ENDIF.

          ADD 10 TO lv_col_pos. ls_fcat-col_pos = lv_col_pos.
          APPEND ls_fcat TO mt_fcat.
        ENDIF.
      ELSEIF lv_len = 0 AND iv_cfield = 'X'.  ".. Deep structure 관련 수정
        lo_clss ?= cl_abap_typedescr=>describe_by_object_ref( ls_comp-type ).
        IF ( lo_clss->get_relative_name( ) = 'CL_ABAP_TABLEDESCR' OR
             lo_clss->get_relative_name( ) = 'CL_ABAP_STRUCTDESCR' )
         AND iV_cl_abap_tabledescr = 'X'.
          CLEAR: ls_fcat, ls_comp, lv_reffield, lv_refstruct, ls_dd04v, ls_dfies, lo_elem, lt_tab[]. CONTINUE.
        ELSEIF lv_len = 0 AND iv_cfield = 'X'.  ".. Custom Field
          lo_elem ?= ls_comp-type.
          ls_fcat-fieldname = ls_comp-name.
          ls_fcat-inttype = lo_elem->type_kind.
          ls_fcat-intlen = lo_elem->length.
          ls_fcat-decimals = ls_fcat-decimals_o = lo_elem->decimals.
          ls_fcat-outputlen = lo_elem->output_length.
          ADD 10 TO lv_col_pos. ls_fcat-col_pos = lv_col_pos.
          APPEND ls_fcat TO mt_fcat.
        ENDIF.
      ENDIF.

      CLEAR: ls_fcat, ls_comp, lv_reffield, lv_refstruct, ls_dd04v, ls_dfies, lo_elem, lt_tab[].
    ENDLOOP.

  ENDMETHOD.


  METHOD wubgui_is_running.

    CHECK cl_gui_object=>www_active     EQ abap_true AND
          cl_gui_object=>gui_is_running EQ abap_true.

    rv_result = abap_true.

  ENDMETHOD.


  METHOD zgtpp_if_list~create_docking_container.

    TRY.
        IF cl_gui_alv_grid=>offline( ) IS INITIAL.
          mr_docking_container = NEW #( parent    = COND #( WHEN iv_popup EQ abap_true THEN cl_gui_container=>screen1
                                                            ELSE cl_gui_container=>screen0 )
                                        style     = cl_gui_control=>ws_child
                                        lifetime  = cl_gui_control=>lifetime_default
                                        side      = cl_gui_docking_container=>dock_at_bottom
                                        repid     = mv_repid
                                        dynnr     = mv_dynnr
                                        extension = mv_extension ).
        ENDIF.

      CATCH cx_root INTO DATA(lo_root).
        MESSAGE lo_root->get_text( ) TYPE 'I'.
    ENDTRY.

  ENDMETHOD.


  METHOD zgtpp_if_list~create_splitter_container.
    DATA lv_height TYPE i.

    TRY.
        mr_splitter_container = NEW #( parent  = ir_container
                                       rows    = 2
                                       columns = 1 ).

        mr_splitter_container->set_row_mode( mode = mr_splitter_container->mode_absolute ).
        mr_splitter_container->set_border( border = abap_false ).

        DATA(ls_factors) = cl_gui_props_consumer=>create_consumer( )->get_metric_factors( ).

        CASE ls_factors-screen-x.
          WHEN '3840'. lv_height = 35.
          WHEN '2560'. lv_height = 27.
          WHEN '2048'. lv_height = 24.
          WHEN '1920'. lv_height = 18.
          WHEN OTHERS. lv_height = 30.
        ENDCASE.

        mr_splitter_container->set_row_height( id     = 1
                                               height = ( lv_height * 2 + lines( it_list_header ) * lv_height ) ).

*        mo_splitter_container->set_row_sash( id    = 1
*                                             type  = cl_gui_splitter_container=>type_sashvisible
*                                             value = cl_gui_splitter_container=>true ).

        mr_splitter_container->set_row_sash( id    = 1
                                             type  = cl_gui_splitter_container=>type_movable
                                             value = cl_gui_splitter_container=>true ).

        mr_top_container = mr_splitter_container->get_container( row = 1 column = 1 ).
        mr_alv_container = mr_splitter_container->get_container( row = 2 column = 1 ).

      CATCH cx_root INTO DATA(lo_root).
        MESSAGE lo_root->get_text( ) TYPE 'I'.
    ENDTRY.

  ENDMETHOD.


  METHOD zgtpp_if_list~display.

    TRY.
        initialize( EXPORTING ir_container   = ir_container
                              it_list_header = it_list_header
                              is_variant     = is_variant
                              ir_handler     = ir_handler
                              iv_repid       = iv_repid
                              iv_dynnr       = iv_dynnr
                              iv_default     = iv_default
                              iv_popup       = iv_popup
                              iv_extension   = iv_extension
                              iv_rowins      = iv_rowins
                    CHANGING  ct_data        = ct_data ).

        list_specific_setting( ir_handler ).

        set_handler( ir_handler ).

        set_edit_event( ).

        first_display( CHANGING ct_data = ct_data ).

        mr_grid->set_toolbar_interactive( ).

*        cl_gui_alv_grid=>set_focus( control = MR_GRID ).
*        cl_abap_list_layout=>suppress_toolbar( ).

      CATCH cx_root.

    ENDTRY.

    CALL METHOD cl_gui_cfw=>flush.

  ENDMETHOD.


  METHOD zgtpp_if_list~display_message.
    CONSTANTS lc_arbgb TYPE smesg-arbgb  VALUE 'BL'.
    CONSTANTS lc_txtnr TYPE smesg-txtnr  VALUE '001'.
    CONSTANTS lc_tabname TYPE baltabname VALUE 'SMESGCT'.
    DATA ls_log TYPE bal_s_log.
    DATA ls_log_handle  TYPE balloghndl.
    DATA ls_log_message TYPE bal_s_msg.
    DATA ls_display_profile TYPE bal_s_prof.

    CHECK it_message IS NOT INITIAL.

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log                 = ls_log
      IMPORTING
        e_log_handle            = ls_log_handle
      EXCEPTIONS
        log_header_inconsistent = 1
        OTHERS                  = 2.

    IF sy-subrc IS NOT INITIAL.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    LOOP AT it_message INTO DATA(ls_message).
      CLEAR ls_log_message.

      ls_log_message-msgty = ls_message-type.

      IF ls_message-id IS NOT INITIAL.
        ls_log_message-msgid = ls_message-id.
        ls_log_message-msgno = ls_message-number.
      ELSE.
        ls_log_message-msgid = lc_arbgb.
        ls_log_message-msgno = lc_txtnr.
      ENDIF.

      IF ls_message-message IS NOT INITIAL.
        ls_log_message-msgv1 = ls_message-message.
      ELSE.
        ls_log_message-msgv1 = ls_message-message_v1.
        ls_log_message-msgv2 = ls_message-message_v2.
        ls_log_message-msgv3 = ls_message-message_v3.
        ls_log_message-msgv4 = ls_message-message_v4.
      ENDIF.

      ls_log_message-detlevel        = 2.
      ls_log_message-context-tabname = lc_tabname.
      ls_log_message-context-value   = ls_message-field.

      CALL FUNCTION 'BAL_LOG_MSG_ADD'
        EXPORTING
          i_log_handle     = ls_log_handle
          i_s_msg          = ls_log_message
        EXCEPTIONS
          log_not_found    = 1
          msg_inconsistent = 2
          log_is_full      = 3
          OTHERS           = 4.
    ENDLOOP.

    CALL FUNCTION 'BAL_DSP_PROFILE_NO_TREE_GET'
      IMPORTING
        e_s_display_profile = ls_display_profile
      EXCEPTIONS
        OTHERS              = 1.

    IF sy-subrc IS NOT INITIAL.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    ls_display_profile-title      = TEXT-t01.
    ls_display_profile-use_grid   = abap_true.
    ls_display_profile-cwidth_opt = abap_true.
    ls_display_profile-start_col  = 40.
    ls_display_profile-start_row  = 4.
    ls_display_profile-end_col    = 120.
    ls_display_profile-end_row    = 10.
*    ls_display_profile-grid_title-smalltitle = abap_true.

    IF iv_zeile EQ abap_true.
      ls_display_profile-mess_fcat = VALUE #( BASE ls_display_profile-mess_fcat ( ref_table = lc_tabname
                                                                                  ref_field = 'ZEILE'
                                                                                  col_pos   = '1'
                                                                                  coltext   = '항목'
                                                                                  cltxt_len = 30
                                                                                  outputlen = 30 ) ).
    ENDIF.

    CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
      EXPORTING
        i_s_display_profile  = ls_display_profile
      EXCEPTIONS
        profile_inconsistent = 1
        internal_error       = 2
        no_data_available    = 3
        no_authority         = 4
        OTHERS               = 5.

    IF sy-subrc IS NOT INITIAL.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL FUNCTION 'BAL_LOG_REFRESH'
      EXPORTING
        i_log_handle  = ls_log_handle
      EXCEPTIONS
        log_not_found = 1
        OTHERS        = 2.

    IF sy-subrc IS NOT INITIAL.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.


  METHOD zgtpp_if_list~free.

    IF mr_dialog_container IS BOUND.
      mr_dialog_container->free( EXCEPTIONS cntl_error        = 1
                                            cntl_system_error = 2
                                            OTHERS            = 3 ).
      IF sy-subrc IS NOT INITIAL.
        MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO DATA(lv_message).
      ENDIF.
    ENDIF.

    IF mr_top_container IS BOUND.
      mr_top_container->free( EXCEPTIONS cntl_error        = 1
                                         cntl_system_error = 2
                                         OTHERS            = 3 ).
      IF sy-subrc IS NOT INITIAL.
        MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
      ENDIF.
    ENDIF.

    IF mr_alv_container IS BOUND.
      mr_alv_container->free( EXCEPTIONS cntl_error        = 1
                                         cntl_system_error = 2
                                         OTHERS            = 3 ).
      IF sy-subrc IS NOT INITIAL.
        MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
      ENDIF.
    ENDIF.

    IF mr_splitter_container IS BOUND.
      mr_splitter_container->free( EXCEPTIONS cntl_error        = 1
                                              cntl_system_error = 2
                                              OTHERS            = 3 ).
      IF sy-subrc IS NOT INITIAL.
        MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
      ENDIF.
    ENDIF.

    IF mr_docking_container IS BOUND.
      mr_docking_container->free( EXCEPTIONS cntl_error        = 1
                                             cntl_system_error = 2
                                             OTHERS            = 3 ).
      IF sy-subrc IS NOT INITIAL.
        MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD zgtpp_if_list~initialize.

    mv_repid     = iv_repid.
    mv_dynnr     = iv_dynnr.
    mv_default   = iv_default.
    mv_extension = iv_extension.
    ms_variant   = COND #( WHEN is_variant IS INITIAL THEN VALUE #( report = iv_repid
                                                                    handle = '0000' )
                           ELSE is_variant ).
    mr_data      = REF #( ct_data ).

    TRY.
        IF ir_container IS BOUND.
          IF it_list_header IS INITIAL.
            mr_alv_container ?= ir_container.

            IF ir_container->get_container_type( ) EQ cl_gui_container=>container_type_dialogbox.
              mr_dialog_container ?=  ir_container.
            ENDIF.
          ELSE.
            create_splitter_container( ir_container   = ir_container
                                       it_list_header = it_list_header ).
            set_list_header( it_list_header ).
          ENDIF.
        ELSE.
          create_docking_container( iv_popup ).

          IF it_list_header IS INITIAL.
            mr_alv_container ?= mr_docking_container.
          ELSE.
            create_splitter_container( ir_container   = mr_docking_container
                                       it_list_header = it_list_header ).
            set_list_header( it_list_header ).
          ENDIF.
        ENDIF.

        mr_grid = NEW cl_gui_alv_grid( i_parent      = mr_alv_container
                                       i_shellstyle  = cl_gui_control=>ws_child
                                       i_lifetime    = cl_gui_alv_grid=>lifetime_imode
                                       i_appl_events = abap_true ).

        set_basic_attribute( EXPORTING iv_rowins = iv_rowins
                             CHANGING  ct_data   = ct_data ).

      CATCH cx_root.
        RETURN.
    ENDTRY.

  ENDMETHOD.


  METHOD zgtpp_if_list~list_specific_setting.

    IF ir_handler IS BOUND.
      SET HANDLER ir_handler->handle_field_catalog FOR me.
      RAISE EVENT field_catalog.

      SET HANDLER ir_handler->handle_layout FOR me.
      RAISE EVENT layout.

      SET HANDLER ir_handler->handle_sort FOR me.
      RAISE EVENT sort.

      SET HANDLER ir_handler->handle_f4 FOR me.
      RAISE EVENT f4.
    ENDIF.

  ENDMETHOD.


  METHOD zgtpp_if_list~popup_display.

    TRY .
        cl_salv_table=>factory( IMPORTING r_salv_table = mr_salv_table
                                CHANGING  t_table      = ct_data ).

        mr_salv_table->get_functions( )->set_default( abap_true ).

        mr_salv_table->get_display_settings( )->set_striped_pattern( abap_true ).
        mr_salv_table->get_display_settings( )->set_list_header_size( cl_salv_display_settings=>c_header_size_small ).

        mr_salv_table->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>row_column ).
        mr_salv_table->get_columns( )->set_optimize( abap_true ).

        DATA(lr_events) = mr_salv_table->get_event( ).

        IF ir_handler IS BOUND.
          SET HANDLER ir_handler->handle_popup FOR me.
          RAISE EVENT popup EXPORTING ir_salv_table = mr_salv_table.

          SET HANDLER ir_handler->handle_salv_double_click FOR lr_events.
          SET HANDLER ir_handler->handle_salv_user_command FOR lr_events.
        ENDIF.

        mr_salv_table->display( ).

      CATCH cx_root.

    ENDTRY.

  ENDMETHOD.


  METHOD zgtpp_if_list~refresh.

    IF iv_opt EQ abap_true.
      cl_reca_gui_alv_services=>set_layout_cwidth_opt( mr_grid ).
    ENDIF.

    mr_grid->refresh_table_display( is_stable = VALUE #( row = abap_true
                                                         col = abap_true ) ).

  ENDMETHOD.


  METHOD zgtpp_if_list~set_basic_attribute.

*// Layout.
    ms_layout = VALUE #( smalltitle = abap_true
                         zebra      = abap_true
                         cwidth_opt = abap_true
                         sel_mode   = 'A' ).

*// Field Catalog.
    table_to_fieldcatalog( ).

*    cl_salv_table=>factory( IMPORTING r_salv_table = DATA(lr_salv_table)
*                            CHANGING  t_table      = ct_data ).
*
*    mt_fcat = cl_salv_controller_metadata=>get_lvc_fieldcatalog( r_columns      = lr_salv_table->get_columns( )
*                                                                 r_aggregations = lr_salv_table->get_aggregations( ) ).

*// Excluding Toolbar.
    mt_excluding = VALUE #( ( cl_gui_alv_grid=>mc_fc_loc_copy )
                            ( cl_gui_alv_grid=>mc_fc_loc_cut )
                            ( cl_gui_alv_grid=>mc_fc_loc_paste )
                            ( cl_gui_alv_grid=>mc_fc_loc_paste_new_row )
                            ( cl_gui_alv_grid=>mc_fc_loc_undo )
                            ( cl_gui_alv_grid=>mc_fc_loc_copy_row ) ).

    IF iv_rowins EQ abap_false.
      mt_excluding = VALUE #( BASE mt_excluding ( cl_gui_alv_grid=>mc_fc_loc_append_row )
                                                ( cl_gui_alv_grid=>mc_fc_loc_insert_row )
                                                ( cl_gui_alv_grid=>mc_fc_loc_delete_row ) ).
    ENDIF.

  ENDMETHOD.


  METHOD zgtpp_if_list~set_edit_event.

*    IF line_exists( mt_fcat[ edit = abap_true ] ).
    mr_grid->register_edit_event( cl_gui_alv_grid=>mc_evt_modified ).
*    mr_grid->register_edit_event( cl_gui_alv_grid=>mc_evt_enter ).
*    ENDIF.

    IF mt_f4 IS NOT INITIAL.
      mr_grid->register_f4_for_fields( mt_f4 ).
    ENDIF.

*    MR_GRID->activate_display_protocol( abap_false ).

  ENDMETHOD.


  METHOD zgtpp_if_list~set_handler.

    TRY .
        SET HANDLER ir_handler->handle_toolbar       FOR mr_grid.
        SET HANDLER ir_handler->handle_user_command  FOR mr_grid.
        SET HANDLER ir_handler->handle_double_click  FOR mr_grid.
        SET HANDLER ir_handler->handle_button_click  FOR mr_grid.
        SET HANDLER ir_handler->handle_hotspot_click FOR mr_grid.
        SET HANDLER ir_handler->handle_on_f4         FOR mr_grid.
        SET HANDLER ir_handler->handle_data_changed  FOR mr_grid.
        SET HANDLER ir_handler->handle_data_changed_finished FOR mr_grid.

        SET HANDLER ir_handler->handle_print_top_of_list FOR mr_grid.
        SET HANDLER ir_handler->handle_print_end_of_list FOR mr_grid.
        SET HANDLER ir_handler->handle_print_top_of_page FOR mr_grid.
        SET HANDLER ir_handler->handle_print_end_of_page FOR mr_grid.
        SET HANDLER ir_handler->handle_top_of_page       FOR mr_grid.
        SET HANDLER ir_handler->handle_ondrag            FOR mr_grid.
        SET HANDLER ir_handler->handle_ondrop            FOR mr_grid.
        SET HANDLER ir_handler->handle_ondropcomplete    FOR mr_grid.
        SET HANDLER ir_handler->handle_context_menu_request FOR mr_grid.

        IF mr_dialog_container IS BOUND.
          SET HANDLER ir_handler->handle_popup_close FOR mr_dialog_container.
        ENDIF.

      CATCH cx_root.

    ENDTRY.

  ENDMETHOD.


  METHOD zgtpp_if_list~set_list_header.
    DATA(lr_document) = NEW cl_dd_document( style = 'ALV_GRID' background_color = '7' ).

    lr_document->initialize_document( ).
    lr_document->add_table( EXPORTING no_of_columns = 2
                                      with_heading  = abap_false
                                      width         = '100%'
                                      border        = '0'
                            IMPORTING table         = DATA(lr_table) ).

    IF lr_table IS BOUND.
      lr_table->add_column( EXPORTING width  = '7%'
                            IMPORTING column = DATA(lr_col_key) ).
      lr_table->add_column( EXPORTING width  = '93%'
                            IMPORTING column = DATA(lr_col_info) ).
    ENDIF.

    LOOP AT it_list_header INTO DATA(ls_list_header).
      SPLIT ls_list_header AT '$' INTO TABLE DATA(lt_string).

      LOOP AT lt_string INTO DATA(ls_string).
        IF sy-tabix EQ 1.
          lr_col_key->add_text( text = CONV sdydo_text_element( ls_string ) ).
*                                sap_emphasis = 'STRONG' ).
          lr_col_key->new_line( ).
        ELSE.
          lr_col_info->add_text( text = CONV sdydo_text_element( ls_string ) ).
          lr_col_info->new_line( ).
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    lr_document->merge_document( ).
    lr_document->display_document( reuse_control = abap_true
                                   parent        = mr_top_container ).

  ENDMETHOD.
ENDCLASS.
