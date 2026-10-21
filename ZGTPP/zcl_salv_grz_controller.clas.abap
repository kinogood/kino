class ZCL_SALV_GRZ_CONTROLLER definition
  public
  final
  create public .

public section.

*"* public components of class ZCL_SALV_GRZ_CONTROLLER
*"* do not include other source files here!!!
  interfaces IF_SALV_GRZ_CONTROLLER .
  interfaces IF_SALV_GUI_GRID_BRIDGE_CALLS .

  aliases FILTER_TABLE
    for IF_SALV_GUI_GRID_BRIDGE_CALLS~FILTER_TABLE .
  aliases GET_SELECTED_ROWS
    for IF_SALV_GUI_GRID_BRIDGE_CALLS~GET_SELECTED_ROWS .
  aliases MAINTAIN_VARIANT
    for IF_SALV_GUI_GRID_BRIDGE_CALLS~MAINTAIN_VARIANT .
  aliases ON_BEFORE_SEND
    for IF_SALV_GUI_GRID_BRIDGE_CALLS~ON_BEFORE_SEND .
  aliases PREPARE_EXPORT
    for IF_SALV_GUI_GRID_BRIDGE_CALLS~PREPARE_EXPORT .
  aliases REFRESH_TABLE_DISPLAY
    for IF_SALV_GUI_GRID_BRIDGE_CALLS~REFRESH_TABLE_DISPLAY .
  aliases SOFT_REFRESH_TABLE_DISPLAY
    for IF_SALV_GUI_GRID_BRIDGE_CALLS~SOFT_REFRESH_TABLE_DISPLAY .
  aliases SORT_TABLE
    for IF_SALV_GUI_GRID_BRIDGE_CALLS~SORT_TABLE .

  data MT_FITER_T type LVC_T_FILT .

  methods CONSTRUCTOR
    importing
      !R_MASTER type ref to CL_GUI_ALV_GRID .
protected section.
*"* protected components of class ZCL_SALV_GRZ_CONTROLLER
*"* do not include other source files here!!!
private section.

  types:
*"* private components of class ZCL_SALV_GRZ_CONTROLLER
*"* do not include other source files here!!!
    begin of ys_ui_view_list,
      handle       type        if_salv_gru_view_ctrl=>y_handle,
      visible      type        abap_bool,
      version      type        if_salv_gru_view_ctrl=>y_version,
      r_ui_view    type ref to if_salv_gru_view_ctrl,
      r_parent     type ref to cl_gui_container,
      r_exception_logger type ref to lcl_exception_logger, " optional
    end of ys_ui_view_list .
  types:
    yt_ui_view_list type table of ys_ui_view_list .

  data T_UI_VIEW_LIST type YT_UI_VIEW_LIST .
  interface IF_SALV_GRM_VMODEL_CTRL load .
  data T_VMODEL_LIST type IF_SALV_GRM_VMODEL_CTRL=>YT_VMODEL_LIST .
  data R_CONFIG_CONTROLLER type ref to IF_ALV_CML_CONFIG_CONTROLLER .
  data R_CONFIGURATION type ref to IF_ALV_CML_CONFIGURATION .
  data R_DATA_SOURCE type ref to IF_SALV_GRM_DATA_SOURCE .
  data R_TABLE_MODEL type ref to IF_SALV_GRM_TABLE_MODEL .
  data R_MASTER type ref to CL_GUI_ALV_GRID .
  interface IF_ALV_RM_GRID_BRIDGE load .
  data ACTUAL_METHOD_SIGNATURE type IF_ALV_RM_GRID_BRIDGE=>YS_METHOD_INVOKER .
  data R_LOG type ref to IF_SALV_CSQ_LOG .
  data R_CURRENT_EXCEPTION_LOGGER type ref to LCL_EXCEPTION_LOGGER .
  class-data R_APPLICATION_LOG type ref to IF_SALV_CSQ_LOG .
  class-data INSTANCE_NUMBER type I .
  data CALL_LEVEL type I .
  type-pools ABAP .
  data UPDATE_DELAYED type ABAP_BOOL .
  data R_LOG_POPUP_HANDLE type BALLOGHNDL .
  data R_LOG_DISPLAY_PROFILE type BAL_S_PROF .
  constants:
    begin of c_task,
               dispatch        type salv_csqt_task value 'DISPATCH',
               call_method     type salv_csqt_task value 'CALL METHOD',
               action          type salv_csqt_task value 'ACTION',
               update_frontend type salv_csqt_task value 'UPDATE FRONTEND',
               set_visible     type salv_csqt_task value 'SET_VISIBLE',
               update          type salv_csqt_task value 'UPDATE',
               event           type salv_csqt_task value 'EVENT',
             end of c_task .
  constants:
    begin of c_event,
               crystal_display_failed type string value 'CRYSTAL_DISPLAY_FAILED',
               crystal_rpt_uploaded   type string value 'CRYSTAL_RPT_UPLOADED',
               excel_display_failed   type string value 'EXCEL_DISPLAY_FAILED',
    end of c_event .
  constants:
    begin of c_handle_text,
               grid      type string value 'GRID',
               toolbar   type string value 'TOOLBAR',
               excel     type string value 'EXCEL',
               crystal   type string value 'CRYSTAL',
               graphics  type string value 'GRAPHICS',
               topoflist type string value 'TOP_OF_LIST',
               endoflist type string value 'END_OF_LIST',
    end of c_handle_text .

  methods CLOSE_GRAPHICS .
  methods DISPLAY_GRAPHICS .
  methods DISPLAY_MESSAGES .
  methods FREE .
  methods GET_CURRENT_CELL
    exporting
      !E_ROW type I
      !E_VALUE type C
      !E_COL type I
      !ES_ROW_ID type LVC_S_ROW
      !ES_COL_ID type LVC_S_COL
      !ES_ROW_NO type LVC_S_ROID .
  methods GET_CURRENT_VMODEL_AND_VIEW
    exporting
      !ES_VMODEL type IF_SALV_GRM_VMODEL_CTRL=>YS_VMODEL_LIST
      !ES_VIEW type YS_UI_VIEW_LIST .
  methods GET_LOG_HANDLE
    returning
      value(R_LOG) type ref to IF_SALV_CSQ_LOG .
  methods GET_SELECTED_CELLS
    exporting
      !ET_CELL type LVC_T_CELL .
  methods GET_SELECTED_CELLS_ID
    exporting
      !ET_CELLS type LVC_T_CENO .
  methods GET_SELECTED_COLUMNS
    exporting
      !ET_INDEX_COLUMNS type LVC_T_COL .
  methods INIT_CONTROLLER .
  methods LOAD_VARIANT
    importing
      !I_INIT_ONLY type ABAP_BOOL default ABAP_FALSE
    exporting
      !E_NO_VARIANT_LOADED type CHAR1 .
  methods LOG_TASK_BEGIN
    importing
      !I_TASK type CSEQUENCE
      !I_TEXT type CSEQUENCE optional
      !I_DATA type ANY optional .
  methods LOG_TASK_END
    importing
      !I_TASK type CSEQUENCE
      !I_DATA type ANY optional .
  methods LOG_UPDATE_TASK_BEGIN
    importing
      !I_TASK type CSEQUENCE
      !I_DATA type YS_UI_VIEW_LIST .
  methods ON_CLOSE_GRAPHICS
    for event CLOSE_GRAPHICS of IF_SALV_GRU_VIEW_GRAPHICS .
  methods ON_CRYSTAL_DISPLAY_FAILED
    for event DISPLAY_FAILED of IF_SALV_GRU_VIEW_CRYSTAL
    importing
      !R_VIEW_ERROR .
  methods ON_CRYSTAL_RPT_UPLOADED
    for event DATA_UPLOADED of IF_SALV_GRU_VIEW_CRYSTAL
    importing
      !DATA
      !NAME
      !TYPE
      !VERSION .
  methods ON_EXCEL_DISPLAY_FAILED
    for event DISPLAY_FAILED of IF_SALV_GRU_VIEW_EXCEL .
  methods PERFORM_ACTION
    importing
      !ACTION type SYUCOMM .
  methods SAVE_VARIANT
    importing
      value(I_DIALOG) type CHAR01 default 'X'
    exporting
      value(E_EXIT) type CHAR01 .
  methods SELECT_VARIANT
    exceptions
      CANCELED
      NOT_FOUND .
  methods SET_CRYSTAL_VIEW_PAIR
    importing
      !R_PARENT type ref to CL_GUI_CONTAINER .
  methods SET_EXCEL_VIEW_PAIR
    importing
      !R_PARENT type ref to CL_GUI_CONTAINER .
  methods SET_FIXED_COLS
    importing
      !COLS type I .
  methods SET_FRONTEND
    importing
      !FRONTEND type LVC_FRONT .
  methods SET_GRAPHICS_VIEW_PAIR .
  methods SET_GRID_VIEW_PAIR .
  methods SET_HTML_HEADER
    importing
      !IT_HEADER type SLIS_T_LISTHEADER .
  methods SET_TOOLBAR
    importing
      !I_INTERACTIVE type ABAP_BOOL .
  methods SET_TOOLBAR_PAIR .
  methods SET_VISIBILITY_FLAGS
    importing
      !HANDLE type IF_SALV_GRM_VMODEL_CTRL=>Y_HANDLE .
  METHODS set_view
    IMPORTING
      !i_frontend TYPE lvc_front .
  methods UPDATE_FRONTEND .
  methods UPDATE_FRONTEND_INTERNAL .
  methods UPDATE_IMMEDIATELY
    returning
      value(UPDATE) type ABAP_BOOL .
  methods UPDATE_TOOLBAR .
ENDCLASS.



CLASS ZCL_SALV_GRZ_CONTROLLER IMPLEMENTATION.


method CLOSE_GRAPHICS.

  data: ls_ui_view       type ys_ui_view_list,
        lr_view_graphics type ref to cl_salv_gru_view_graphics.

  read table me->t_ui_view_list into ls_ui_view with key handle = if_salv_grm_vmodel_ctrl=>c_handle-graphics.
  if sy-subrc = 0 and ls_ui_view-visible = abap_true.
    lr_view_graphics ?= ls_ui_view-r_ui_view.
    lr_view_graphics->close_graphics( ).
  endif.

endmethod.


method CONSTRUCTOR.

*...create log handle
  me->r_log = get_log_handle( ).

*...create master
  me->r_master = r_master.

*...create Datasource
  me->r_data_source = cl_salv_gz_factory=>instance->create_data_source_with_facade( r_master       = r_master
                                                                                    r_log_provider = me->r_log ).

*...create Configuration
  me->r_config_controller = cl_salv_gz_factory=>instance->create_config_controller( r_master      = r_master
                                                                                    r_data_source  = me->r_data_source
                                                                                    r_log_provider = me->r_log ).
  me->r_configuration = me->r_config_controller->get_configuration( ).

*...create Table Model
  me->r_table_model = cl_salv_gz_factory=>instance->create_table_model( r_master       = r_master
                                                                        r_log_provider = me->r_log ).

  call_level = 0.
  update_delayed = abap_false.

  me->init_controller( ).

endmethod.


method DISPLAY_GRAPHICS.

  data: ls_ui_view       type ys_ui_view_list,
        lr_view_graphics type ref to cl_salv_gru_view_graphics,
        lt_columns       type lvc_t_col,
        lt_roid          type lvc_t_roid.

* set graphics
  me->set_graphics_view_pair( ).
  read table me->t_ui_view_list into ls_ui_view with key handle = if_salv_grm_vmodel_ctrl=>c_handle-graphics.
  assert sy-subrc = 0.
  lr_view_graphics ?= ls_ui_view-r_ui_view.

* read actual selections
  me->get_selected_columns( importing et_index_columns = lt_columns ).
  me->get_selected_rows( importing et_row_no = lt_roid ).

* prepare graphic display
  lr_view_graphics->prepare_graphic_display( exporting it_index_columns = lt_columns
                                                       it_row_no        = lt_roid ).

endmethod.


method DISPLAY_MESSAGES.

  data lt_messages type if_salv_csq=>yt_message.
  data ls_message type  if_salv_csq=>ys_message.

* Pull messages and display if any message available
  lt_messages = me->r_log->get_message_pool( )->pull_messages( ).
  if lt_messages is initial.
    return.
  endif.

* If just one message available, display it using standard message statement
  if lines( lt_messages ) = 1.
    read table lt_messages index 1 into ls_message.
    if ls_message-msgty = 'I'.
      " information message - display as popup
      message id ls_message-msgid
          type ls_message-msgty
          number ls_message-msgno
          with ls_message-attr1 ls_message-attr2 ls_message-attr3 ls_message-attr4.
    else.
      " any other message display in status line
      message id ls_message-msgid
          type 'S'
          number ls_message-msgno
          display like ls_message-msgty
          with ls_message-attr1 ls_message-attr2 ls_message-attr3 ls_message-attr4.
    endif.
    return.
  endif.

* More messages - display as list in popup
* using application log

*********************************************
* THE FOLLOWING CODE COPIED FROM BW SYSTEM
* FUNCTION MODULE: UPC_LOG_SHOW_POPUP
*********************************************

  data l_number_of_msg type i.
  describe table lt_messages lines l_number_of_msg.
  check l_number_of_msg > 0.

  if me->r_log_popup_handle is initial.
*   create log
    data ls_log type bal_s_log.
    call function 'BAL_LOG_CREATE'
      exporting
        i_s_log      = ls_log
      importing
        e_log_handle = me->r_log_popup_handle
      exceptions
        others       = 1.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      return.
    endif.

  else. "... log exists
*   delete all messages from the log
    call function 'BAL_LOG_MSG_DELETE_ALL'
         exporting
              i_log_handle = me->r_log_popup_handle
         exceptions
              others       = 1
              .
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endif.

* add messages
  data: ls_bal_mesg     type bal_s_msg.
  clear ls_message.
  loop at lt_messages into ls_message.

    ls_bal_mesg-msgid = ls_message-msgid.
    ls_bal_mesg-msgno = ls_message-msgno.
    ls_bal_mesg-msgty = ls_message-msgty.
    ls_bal_mesg-msgv1 = ls_message-attr1.
    ls_bal_mesg-msgv2 = ls_message-attr2.
    ls_bal_mesg-msgv3 = ls_message-attr3.
    ls_bal_mesg-msgv4 = ls_message-attr4.
    call function 'BAL_LOG_MSG_ADD'
         exporting
              i_log_handle = me->r_log_popup_handle
              i_s_msg      = ls_bal_mesg
         exceptions
              others       = 1.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.

  endloop.

* create profile for display
  if me->r_log_display_profile is initial.

*   get a prepared profile
    call function 'BAL_DSP_PROFILE_POPUP_GET'
         importing
              e_s_display_profile = me->r_log_display_profile
         exceptions
              others              = 1.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      return.
    endif.

*   use grid for display if wanted
    me->r_log_display_profile-use_grid  = 'X'.
*   adjust size of pop-up
    me->r_log_display_profile-pop_adjst = 'X'.
*   set report to allow saving of variants
    me->r_log_display_profile-disvariant-report = sy-repid.
  endif.

* call display function module
* We do not specify any filter (like I_S_LOG_FILTER, ...,
* I_T_MSG_HANDLE) since we want to display all logs available
  data lt_handle type bal_t_logh.
  clear lt_handle.
  insert me->r_log_popup_handle into table lt_handle.
  call function 'BAL_DSP_LOG_DISPLAY'
       exporting
            i_t_log_handle      = lt_handle
            i_s_display_profile = me->r_log_display_profile
       exceptions
            others              = 1.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
             with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endmethod.


method FREE.

  data:
    ls_ui_view type ys_ui_view_list.

  loop at me->t_ui_view_list into ls_ui_view.
    ls_ui_view-r_ui_view->free( ).
  endloop.

  data:
    ls_vmodel type if_salv_grm_vmodel_ctrl=>ys_vmodel_list.

  loop at me->t_vmodel_list into ls_vmodel.
    ls_vmodel-r_vmodel->free( ).
  endloop.

  free me->r_config_controller.
  free me->r_configuration.
  free me->r_data_source.
  free me->r_table_model.
  free me->r_master.

endmethod.


method GET_CURRENT_CELL .

  data: ls_vmodel     type if_salv_grm_vmodel_ctrl=>ys_vmodel_list,
        ls_view       type ys_ui_view_list,
        lr_view_grid  type ref to if_salv_gru_view_grid,
        lr_view_excel type ref to if_salv_gru_view_excel.

  clear: e_row,
         e_value,
         e_col,
         es_row_id,
         es_col_id,
         es_row_no.
  me->get_current_vmodel_and_view( importing es_vmodel = ls_vmodel
                                             es_view   = ls_view ).
  case ls_vmodel-handle.
  when if_salv_grm_vmodel_ctrl=>c_handle-grid.
    lr_view_grid ?= ls_view-r_ui_view.
    lr_view_grid->get_current_cell( importing e_row     = e_row
                                              e_value   = e_value
                                              e_col     = e_col
                                              es_row_id = es_row_id
                                              es_col_id = es_col_id
                                              es_row_no = es_row_no ).
  when if_salv_grm_vmodel_ctrl=>c_handle-excel.
    lr_view_excel   ?= ls_view-r_ui_view.
    lr_view_excel->get_current_cell( importing e_row     = e_row
                                               e_value   = e_value
                                               e_col     = e_col
                                               es_row_id = es_row_id
                                               es_col_id = es_col_id
                                               es_row_no = es_row_no ).
  when others.
    " nothing todo
  endcase.

endmethod.                    "get_current_cell


method GET_CURRENT_VMODEL_AND_VIEW.

  loop at me->t_vmodel_list into es_vmodel where visible    = abap_true
                                             and appearance = if_salv_grm_vmodel_ctrl=>c_appearance-is_grouped
                                             and handle    <> if_salv_grm_vmodel_ctrl=>c_handle-graphics .
*                                             and ( handle = if_salv_grm_vmodel_ctrl=>c_handle-grid or
*                                                   handle = if_salv_grm_vmodel_ctrl=>c_handle-excel or
*                                                   handle = if_salv_grm_vmodel_ctrl=>c_handle-crystal ).
    read table me->t_ui_view_list into es_view index sy-tabix.
    exit.
  endloop.
  assert es_vmodel-handle is not initial. "no vmodel found

endmethod.


method GET_LOG_HANDLE.

  data: lr_session_log type ref to if_salv_csq_session_log.

  if me->r_application_log is initial.
    lr_session_log = cl_salv_csq_log=>get_session_log( ).
    me->r_application_log = lr_session_log->create_application_log_simple( component        = 'GUI'
                                                                           application_type = 'GUI' ).
  endif.
  me->instance_number = me->instance_number + 1.
  r_log = me->r_application_log->create_logger(
      component       = 'GRZ'
      instance_handle = |{ me->instance_number }|
      has_message_pool = abap_true ).

endmethod.


method GET_SELECTED_CELLS .

  data: ls_vmodel     type if_salv_grm_vmodel_ctrl=>ys_vmodel_list,
        ls_view       type ys_ui_view_list,
        lr_view_grid  type ref to if_salv_gru_view_grid,
        lr_view_excel type ref to if_salv_gru_view_excel.

  clear et_cell.
  me->get_current_vmodel_and_view( importing es_vmodel = ls_vmodel
                                             es_view   = ls_view ).
  case ls_vmodel-handle.
  when if_salv_grm_vmodel_ctrl=>c_handle-grid.
    lr_view_grid ?= ls_view-r_ui_view.
    et_cell       = lr_view_grid->get_selected_cells( ).
  when if_salv_grm_vmodel_ctrl=>c_handle-excel.
    lr_view_excel   ?= ls_view-r_ui_view.
    et_cell          = lr_view_excel->get_selected_cells( ).
  when others.
    " nothing todo
  endcase.

endmethod.                    "get_selected_cells


method GET_SELECTED_CELLS_ID.

  data: ls_vmodel     type if_salv_grm_vmodel_ctrl=>ys_vmodel_list,
        ls_view       type ys_ui_view_list,
        lr_view_grid  type ref to if_salv_gru_view_grid,
        lr_view_excel type ref to if_salv_gru_view_excel.

  clear et_cells.
  me->get_current_vmodel_and_view( importing es_vmodel = ls_vmodel
                                             es_view   = ls_view ).
  case ls_vmodel-handle.
  when if_salv_grm_vmodel_ctrl=>c_handle-grid.
    lr_view_grid ?= ls_view-r_ui_view.
    et_cells      = lr_view_grid->get_selected_cells_id( ).
  when if_salv_grm_vmodel_ctrl=>c_handle-excel.
    lr_view_excel ?= ls_view-r_ui_view.
    et_cells       = lr_view_excel->get_selected_cells_id( ).
  when others.
    " nothing todo
  endcase.

endmethod.                    "get_selected_cells_id


method GET_SELECTED_COLUMNS .

  data: ls_vmodel     type if_salv_grm_vmodel_ctrl=>ys_vmodel_list,
        ls_view       type ys_ui_view_list,
        lr_view_grid  type ref to if_salv_gru_view_grid,
        lr_view_excel type ref to if_salv_gru_view_excel.

  clear et_index_columns.
  me->get_current_vmodel_and_view( importing es_vmodel = ls_vmodel
                                             es_view   = ls_view ).
  case ls_vmodel-handle.
  when if_salv_grm_vmodel_ctrl=>c_handle-grid.
    lr_view_grid    ?= ls_view-r_ui_view.
    et_index_columns = lr_view_grid->get_selected_columns( ).
  when if_salv_grm_vmodel_ctrl=>c_handle-excel.
    lr_view_excel   ?= ls_view-r_ui_view.
    et_index_columns = lr_view_excel->get_selected_columns( ).
  when others.
    " nothing todo
  endcase.

endmethod.


method IF_SALV_GRZ_CONTROLLER~DISPATCH.

data: l_update           type abap_bool,
      l_exception_number type sysubrc.

  mac_task_begin c_task-dispatch space.
  call_level = call_level + 1.

* call method / perform action
  if s_method_signature is supplied.
*   call method
    mac_task_begin_data c_task-call_method s_method_signature-methodname s_method_signature.
    me->actual_method_signature = s_method_signature.
    l_update = abap_false.
    case s_method_signature-classname.
    when if_alv_rm_grid_bridge=>c_classname-cl_gui_alv_grid.
      call method me->(s_method_signature-methodname)
                      parameter-table s_method_signature-t_ptab
                      exception-table s_method_signature-t_etab.
      l_exception_number = sy-subrc.
      if l_exception_number <> 0 and  s_method_signature-t_etab is not initial.
        clear me->actual_method_signature.
        mac_task_end_data c_task-call_method s_method_signature.
        call_level = call_level - 1.
        mac_task_end c_task-dispatch.
        raise exception type cx_salv_grx_nc_meth_exception
                             exporting exception_number = l_exception_number.
      endif.
      case s_method_signature-methodname.
      when if_alv_rm_grid_bridge=>c_methodname-soft_refresh_table_display or
           if_alv_rm_grid_bridge=>c_methodname-set_fixed_cols.
        l_update = me->update_immediately( ).
      when if_alv_rm_grid_bridge=>c_methodname-set_html_header or
           if_alv_rm_grid_bridge=>c_methodname-display_graphics.
        l_update = abap_true.
      endcase.
    when others.
      assert 1 = 2.
    endcase.
    clear me->actual_method_signature.
    mac_task_end_data c_task-call_method s_method_signature.
  else.
*   action (fcode)
    me->perform_action( action ).
    l_update = me->update_immediately( ).
  endif.

* update frontend if needed
  if call_level > 1 and l_update = abap_true.           "recursive call with update frontend
    l_update = abap_false.                              "delay update frontend
    update_delayed = abap_true.
  elseif call_level = 1 and update_delayed = abap_true. "after recursive call with update frontend
    l_update = abap_true.                               "call delayed update
    update_delayed = abap_false.
  endif.
  if l_update = abap_true.
    me->update_frontend( ).
  endif.

  call_level = call_level - 1.
  mac_task_end c_task-dispatch.

endmethod.


METHOD IF_SALV_GUI_GRID_BRIDGE_CALLS~FILTER_TABLE.

  DATA: LR_CONFIGURATION_OBSERVER TYPE REF TO IF_SALV_GZ_CHANGE_OBSERVER,
        LT_SELECTED_COLUMNS       TYPE LVC_T_COL,
        LS_SELECTED_COLUMN        TYPE LVC_S_COL,
        LS_SELFIELD               TYPE LVC_S_SELF.

  DATA : LR_CONFIG TYPE REF TO CL_ALV_CML_CONFIGURATION.

* get selected column
  IF I_CALLED_BY_CONTEXT_MENU = ABAP_TRUE.
* check whether context of column header is displayed:  YI3K355146
    ME->GET_SELECTED_COLUMNS( IMPORTING ET_INDEX_COLUMNS = LT_SELECTED_COLUMNS ). "more than one column selected?

* check whether context of a cell is displayed  YI3K355146
    IF LT_SELECTED_COLUMNS IS INITIAL.     "context of a cell!
      ME->GET_CURRENT_CELL( IMPORTING ES_ROW_ID = LS_SELFIELD-S_ROW_ID
                                      ES_COL_ID = LS_SELFIELD-S_COL_ID
                                      E_VALUE   = LS_SELFIELD-VALUE ).
      APPEND LS_SELFIELD-S_COL_ID TO LT_SELECTED_COLUMNS.
    ENDIF.
  ELSE.
    ME->GET_SELECTED_COLUMNS( IMPORTING ET_INDEX_COLUMNS = LT_SELECTED_COLUMNS ).
  ENDIF.

* call filter dialog
  LR_CONFIGURATION_OBSERVER = ME->R_CONFIGURATION->IF_SALV_GZ_OBSERVER_FACTORY~CREATE_OBSERVER( ).
  LR_CONFIGURATION_OBSERVER->RESET( ). " needed, otherwise always changes detected
  ME->R_CONFIG_CONTROLLER->CHANGE_FILTER( IT_SELECTED_COLUMNS = LT_SELECTED_COLUMNS
                                          IS_SELFIELD         = LS_SELFIELD ).

  IF LR_CONFIGURATION_OBSERVER->IS_CHANGED( ) = ABAP_FALSE.
    RAISE NO_CHANGE.
  ENDIF.
  ME->R_TABLE_MODEL->APPLY_FILTER( ).

*  me->R_CONFIG_CONTROLLER->
  LR_CONFIG ?= ME->R_CONFIGURATION.

  LR_CONFIG->IF_ALV_CML_CONFIGURATION~GET_T_FILTER(
    RECEIVING
      VALUE = MT_FITER_T
  ).

ENDMETHOD.


method IF_SALV_GUI_GRID_BRIDGE_CALLS~GET_SELECTED_ROWS .

  data: ls_vmodel     type if_salv_grm_vmodel_ctrl=>ys_vmodel_list,
        ls_view       type ys_ui_view_list,
        lr_view_grid  type ref to if_salv_gru_view_grid,
        lr_view_excel type ref to if_salv_gru_view_excel.

  clear et_index_rows.

  me->get_current_vmodel_and_view( importing es_vmodel = ls_vmodel
                                             es_view   = ls_view ).
  case ls_vmodel-handle.
  when if_salv_grm_vmodel_ctrl=>c_handle-grid.
    lr_view_grid ?= ls_view-r_ui_view.
    et_row_no = lr_view_grid->get_selected_rows( ).
  when if_salv_grm_vmodel_ctrl=>c_handle-excel.
    lr_view_excel   ?= ls_view-r_ui_view.
    et_row_no = lr_view_excel->get_selected_rows( ).
  when others.
    " nothing todo
    exit.
  endcase.
  if et_index_rows is supplied.
    clear et_index_rows.
    r_table_model->map_roid_to_row( exporting it_row_no     = et_row_no
                                    importing et_index_rows = et_index_rows ).
  endif.

endmethod.                    "get_selected_rows


method IF_SALV_GUI_GRID_BRIDGE_CALLS~MAINTAIN_VARIANT .

  data: lr_configuration_observer type ref to if_salv_gz_change_observer,
        lt_tabstrip               type dtc_t_ts,
        lt_selected_columns       type lvc_t_col,
        ls_layout                 type lvc_s_layo.

  lr_configuration_observer = me->r_configuration->if_salv_gz_observer_factory~create_observer( ).
  lr_configuration_observer->reset( ). " needed, otherwise always changes detected

  lt_tabstrip = it_tabstrip.
  if cl_alv_check_third_party=>is_supported( if_alv_z=>c_frontend-crystal ) = abap_false.
    delete lt_tabstrip where ts_ucomm = 'ALV_M_R4_CRYSTAL'.
  endif.
  if cl_alv_check_third_party=>is_supported( if_alv_z=>c_frontend-excel ) = abap_false.
    delete lt_tabstrip where ts_ucomm = 'ALV_M_R4_EXCEL'.
  endif.
  if cl_alv_check_third_party=>is_supported( if_alv_z=>c_frontend-lotus ) = abap_false.
    delete lt_tabstrip where ts_ucomm = 'ALV_M_R4_LOTUS'.
  endif.
  me->get_selected_columns( importing et_index_columns = lt_selected_columns ).
  me->r_config_controller->change_settings( it_tabstrip         = lt_tabstrip
                                            it_selected_columns = lt_selected_columns ).

* if lr_configuration_observer->is_changed( if_alv_cml_configuration=>c_change-view ) = abap_true.
  if lr_configuration_observer->is_changed( ) = abap_true.
    ls_layout = me->r_configuration->get_s_layout( ).
    me->set_view( ls_layout-frontend ).
  else.
    raise no_change.
  endif.

endmethod.                    "maintain_variant


method IF_SALV_GUI_GRID_BRIDGE_CALLS~ON_BEFORE_SEND.

  data:
    lr_view_grid type ref to if_salv_gru_view_grid,
    ls_ui_view type ys_ui_view_list,
    ls_vmodel type if_salv_grm_vmodel_ctrl=>ys_vmodel_list.

  read table me->t_vmodel_list into ls_vmodel with key handle = if_salv_grm_vmodel_ctrl=>c_handle-grid.
  if sy-subrc eq 0.
    read table me->t_ui_view_list into ls_ui_view index sy-tabix.
    if sy-subrc eq 0.
      lr_view_grid ?= ls_ui_view-r_ui_view.
*... get GUI settings
      data : l_gui_type type int4.
      lr_view_grid->get_gui_settings(
                       importing
                         gui_type = l_gui_type ).
*... adapt to classic view
      data: l_classic_view type ui_func.
      case ls_vmodel-handle.
        when if_salv_grm_vmodel_ctrl=>c_handle-grid.
          l_classic_view = if_salv_c_function=>view_grid.
*... fetch data Package
          data : lr_vmodel_grid type ref to if_salv_grm_vmodel_grid.
          lr_vmodel_grid ?= ls_vmodel-r_vmodel.
          lr_vmodel_grid->get_data_package(
                         exporting
                           firstline = firstline
                           lastline  = lastline
                           view      = l_classic_view
                           gui_type  = l_gui_type
                                          ).
        when if_salv_grm_vmodel_ctrl=>c_handle-excel.
          l_classic_view = if_salv_c_function=>view_excel.
        when if_salv_grm_vmodel_ctrl=>c_handle-crystal.
          l_classic_view = if_salv_c_function=>view_crystal.
      endcase.

    endif.
  endif.

*    data: ls_ui_components type if_alv_ru_view=>ys_ui_components.
*    read table me->t_ui_components into ls_ui_components with key
*         handle = if_alv_rm_view=>c_handle-grid.
*    if sy-subrc eq 0.
*      data: lr_alv_view type ref to cl_gui_alv_grid_base_impl.  "if_alv_ru_view_list_integrated.
*      lr_alv_view ?= ls_ui_components-r_ui_view.
*    data: l_methodname type string value 'GET_DATA_PACKAGE'.
*    call method lr_alv_view->(l_methodname)
*                              parameter-table s_method_signature-t_ptab
*                              exception-table s_method_signature-t_etab.
*    do_update = abap_false.
*    endif.

endmethod.


method IF_SALV_GUI_GRID_BRIDGE_CALLS~PREPARE_EXPORT.

data: ls_ui_view type ys_ui_view_list,
      ls_vmodel  type if_salv_grm_vmodel_ctrl=>ys_vmodel_list,
      l_index    type i.

* if an excel view already exist => delete spreadsheet instance

  read table me->t_ui_view_list into ls_ui_view with key handle = if_salv_grm_vmodel_ctrl=>c_handle-excel.
  if sy-subrc <> 0.
    exit.
  endif.
  l_index = sy-tabix.

* excel view exist
  ls_ui_view-r_ui_view->free( ).
  delete me->t_ui_view_list index l_index.
  read table me->t_vmodel_list into ls_vmodel with key handle = if_salv_grm_vmodel_ctrl=>c_handle-excel.
  if sy-subrc = 0.
    l_index = sy-tabix.
    ls_vmodel-r_vmodel->free( ).
    delete me->t_vmodel_list index l_index.
  endif.

endmethod.


method IF_SALV_GUI_GRID_BRIDGE_CALLS~REFRESH_TABLE_DISPLAY.

* synchronize grid data and data for RESET function
  r_config_controller->update_data_for_reset( ).

  if i_soft_refresh is initial.
    me->r_configuration->notify_change( if_alv_cml_configuration=>c_change-service ).
    me->r_data_source->notify_change( if_salv_grm_data_source=>c_change-source ).
    me->r_table_model->notify_change( if_salv_grm_table_model=>c_change-result ).
  endif.

endmethod.                    "refresh_table_display


method IF_SALV_GUI_GRID_BRIDGE_CALLS~SOFT_REFRESH_TABLE_DISPLAY.

*... ALV Fullscreen : No toolbar  -> IS_ACTIVE-method in IF_VMODEL_CTRL
  data: ls_layout type lvc_s_layo.
  ls_layout = me->r_configuration->get_s_layout( ).
  if ls_layout-no_toolbar is initial.
    me->set_toolbar_pair( ).
  endif.

*... Set Scroll Infos to Vmodel -> only relevant for Grid
  data: ls_vmodel type if_salv_grm_vmodel_ctrl=>ys_vmodel_list.
  data: lr_vmodel_grid type ref to if_salv_grm_vmodel_grid.
  read table me->t_vmodel_list into ls_vmodel with key handle = if_salv_grm_vmodel_ctrl=>c_handle-grid.
  if sy-subrc eq 0.
    if ls_vmodel-visible eq abap_true.
      lr_vmodel_grid ?= ls_vmodel-r_vmodel.
      lr_vmodel_grid->set_list_layout_info( s_stable = is_stable s_info = is_info ).
    endif.
  endif.

* inform data source: data changed
  r_data_source->notify_change( if_salv_grm_data_source=>c_change-source ).

endmethod.                    "soft_refresh_table_display


method IF_SALV_GUI_GRID_BRIDGE_CALLS~SORT_TABLE.

  data: lr_configuration_observer type ref to if_salv_gz_change_observer,
        lt_selected_columns       type lvc_t_col,
        l_down                    type abap_bool.

* call sort dialog
  lr_configuration_observer = me->r_configuration->if_salv_gz_observer_factory~create_observer( ).
  lr_configuration_observer->reset( ). " needed, otherwise always changes detected

  me->get_selected_columns( importing et_index_columns = lt_selected_columns ).

  if i_ascending = abap_true.
    l_down = abap_false.
  else.
    l_down = abap_true.
  endif.
  me->r_config_controller->change_sort( it_selected_columns = lt_selected_columns
                                        i_down              = l_down
                                        i_subtotals         = i_subtotals ).
  if lr_configuration_observer->is_changed( ) = abap_false.
    raise no_change.
  endif.

* apply sort
  me->r_table_model->apply_sort( ).

endmethod.


method INIT_CONTROLLER.

data: l_lines    type i,
      ls_vmodel  type if_salv_grm_vmodel_ctrl=>ys_vmodel_list,
      ls_ui_view type ys_ui_view_list.

* delete all existing models and views
  loop at me->t_vmodel_list into ls_vmodel.
    ls_vmodel-r_vmodel->free( ).
  endloop.
  loop at me->t_ui_view_list into ls_ui_view.
    ls_ui_view-r_ui_view->free( ).
  endloop.
  clear: me->t_vmodel_list,
         me->t_ui_view_list.

* create a new grid model and view
  me->set_grid_view_pair( ).
  me->set_view( if_alv_z=>c_frontend-table ).

endmethod.


method LOAD_VARIANT .

">>>> wrong
* this method is ONLY called by method SET_TABLE_FOR_FIRST_DISPLAY of class CL_GUI_ALV_GRID
* therefore an initialization of controller is called here for repeated call of this method
"<<<< wrong

" This method is called in cl_salv_grz_controller->constructor( )
" => no need to call the controller initialization again

" This method is not called when variant handling is switched off
" => init_controller( ) must remain in Constructor( )

  data: lr_configuration_observer type ref to if_salv_gz_change_observer,
        ls_layout                 type lvc_s_layo.

  if if_alv_z=>c_api_version lt '756.02'.  "what about new data structure?
    me->init_controller( ).
  endif.

  e_no_variant_loaded = abap_true.

* only initialization
  if i_init_only = abap_true.
    me->r_config_controller->set_state_for_reset( i_fieldcat_incomplete = abap_true ).
    exit.
  endif.

* load variant
  lr_configuration_observer = me->r_configuration->if_salv_gz_observer_factory~create_observer( ).
  lr_configuration_observer->reset( ). " needed, otherwise always changes detected

  me->r_config_controller->load_variant( exporting  i_dialog  = abap_false
                                                    i_fire_events = abap_false
                                         exceptions not_found     = 1
                                                    cancelled = 2
                                                    others    = 3 ).
  if sy-subrc = 0.
    e_no_variant_loaded = abap_false.
*   if lr_configuration_observer->is_changed( if_alv_cml_configuration=>c_change-view ) = abap_true.
  if lr_configuration_observer->is_changed(  ) = abap_true.
    ls_layout = me->r_configuration->get_s_layout( ).
      if ls_layout-graphics is not initial.
        me->set_graphics_view_pair( ).
      endif.
    me->set_view( ls_layout-frontend ).
    endif.
  endif.

endmethod.


method LOG_TASK_BEGIN.

  data: l_task        type salv_csqt_task,
        l_log_text    type salv_csqt_log_text,
        lr_recordable type ref to if_salv_csq_recordable.

  l_task = i_task.

  if i_text is supplied.
    l_log_text = i_text.
  endif.

  if i_data is supplied.
    if me->r_log->get_trace_level( ) = if_salv_csq_log=>c_trace_level-logging.
      lr_recordable = cl_salv_csq_log=>create_recordable_object( i_data ).
    endif.
  endif.
  me->r_log->log_task_begin( task       = l_task
                             log_text   = l_log_text
                             recordable = lr_recordable ).

endmethod.


method LOG_TASK_END.

  data: l_task        type salv_csqt_task,
        lr_recordable type ref to if_salv_csq_recordable.

  l_task = i_task.
  if i_data is supplied.
    if me->r_log->get_trace_level( ) = if_salv_csq_log=>c_trace_level-logging.
      lr_recordable = cl_salv_csq_log=>create_recordable_object( i_data ).
    endif.
  endif.
  me->r_log->log_task_end( task       = l_task
                           recordable = lr_recordable ).

endmethod.


method LOG_UPDATE_TASK_BEGIN.

  data: l_text type string.

  case i_data-handle.
  when if_salv_grm_vmodel_ctrl=>c_handle-grid.      l_text = c_handle_text-grid.
  when if_salv_grm_vmodel_ctrl=>c_handle-toolbar.   l_text = c_handle_text-toolbar.
  when if_salv_grm_vmodel_ctrl=>c_handle-excel.     l_text = c_handle_text-excel.
  when if_salv_grm_vmodel_ctrl=>c_handle-crystal.   l_text = c_handle_text-crystal.
  when if_salv_grm_vmodel_ctrl=>c_handle-graphics.  l_text = c_handle_text-graphics.
  when if_salv_grm_vmodel_ctrl=>c_handle-topoflist. l_text = c_handle_text-topoflist.
  when if_salv_grm_vmodel_ctrl=>c_handle-endoflist. l_text = c_handle_text-endoflist.
  endcase.

  me->log_task_begin( i_task = i_task
                      i_text = l_text
                      i_data = i_data ).

endmethod.


method ON_CLOSE_GRAPHICS.

  data: ls_vmodel  type if_salv_grm_vmodel_ctrl=>ys_vmodel_list,
        ls_ui_view type ys_ui_view_list,
        l_index    type i.

  read table me->t_vmodel_list into ls_vmodel with key handle = if_salv_grm_vmodel_ctrl=>c_handle-graphics.
  assert sy-subrc = 0.
  l_index = sy-tabix.
  ls_vmodel-visible = abap_false.
  modify me->t_vmodel_list from ls_vmodel index l_index transporting visible.

  read table me->t_ui_view_list into ls_ui_view with key handle = if_salv_grm_vmodel_ctrl=>c_handle-graphics.
  assert sy-subrc = 0.
  l_index = sy-tabix.
  ls_ui_view-visible = abap_false.
  modify me->t_ui_view_list from ls_ui_view index l_index transporting visible.

endmethod.


method ON_CRYSTAL_DISPLAY_FAILED.

  mac_task_begin c_task-event c_event-crystal_display_failed.

  " log exception
  data lr_exception_logger type ref to lcl_crystal_exception_logger.
  create object lr_exception_logger exporting r_logger = me->r_log.
  lr_exception_logger->report_update_view_exception( r_view_error ).

  " switch to grid
  me->perform_action( if_salv_c_function=>view_grid ).
  me->update_frontend( ).

  mac_task_end c_task-event.

endmethod.


method ON_CRYSTAL_RPT_UPLOADED.

data: l_message type string.

  assert type = if_salv_bog_cr_data_controller=>c_data_type-custom_report..

  data: ls_provider type if_alv_z=>ys_template_provider,
        ls_layout   type lvc_s_layo.

  ls_provider-blob                = data.
  ls_provider-blob_format_version = version.
  ls_provider-blob_name           = name.
  ls_provider-source        = if_alv_z=>c_template_source-crystal.
  ls_provider-template_type = if_alv_z=>c_template_type-crystal_custom_report.

  me->r_configuration->set_s_template_provider( ls_provider ).
  me->r_configuration->on_crystal_rpt_uploaded( iv_blob                = ls_provider-blob
                                                iv_blob_format_version = ls_provider-blob_format_version
                                                iv_blob_filename       = |{ ls_provider-blob_name }| ).

  ls_layout = me->r_configuration->get_s_layout( ).
  ls_layout-blob_type = 'C'.
  ls_layout-blob_key  = 'C'.
  me->r_configuration->set_s_layout( ls_layout ).

  me->r_configuration->notify_change( if_alv_cml_configuration=>c_change-template ).

  message s100(salv_gru) with name into l_message.
  me->r_log->report_system_message( ).

  me->update_frontend( ).

endmethod.


method ON_EXCEL_DISPLAY_FAILED.

  data: l_message type string.

  mac_task_begin c_task-event c_event-excel_display_failed.

  message s121(salv_gru) into l_message.
  me->r_log->report_system_message( ).

  me->perform_action( if_salv_c_function=>view_grid ).
  me->update_frontend( ).

  mac_task_end c_task-event.

endmethod.


method PERFORM_ACTION.

  data: ls_ui_view_grid type ys_ui_view_list,
        lr_grid_view    type ref to if_salv_gru_view_grid.

  mac_task_begin c_task-action action.

  case action.

* switch to grid view
  when if_salv_c_function=>view_grid.
    me->set_view( if_alv_z=>c_frontend-table ).

* switch to excel view
  when if_salv_c_function=>view_excel.
    me->set_view( if_alv_z=>c_frontend-excel ).

* switch to crystal view
  when if_salv_c_function=>view_crystal.
    me->set_view( if_alv_z=>c_frontend-crystal ).

  endcase.

  mac_task_end c_task-action.

endmethod.


method SAVE_VARIANT.

* i_dialog must be maintained for saving of variants dark
  me->r_config_controller->save_variant( exporting  i_dialog  = i_dialog    "abap_true YI3K072265
                                                    i_fire_events = abap_true
                                         exceptions cancelled     = 1 ).
  if sy-subrc = 0.
    e_exit = abap_false.
  else.
    e_exit = abap_true.
  endif.

endmethod.


method SELECT_VARIANT.

  data: lr_configuration_observer type ref to if_salv_gz_change_observer,
        ls_layout                 type lvc_s_layo.

  lr_configuration_observer = me->r_configuration->if_salv_gz_observer_factory~create_observer( ).
  lr_configuration_observer->reset( ). " needed, otherwise always changes detected

  me->r_config_controller->load_variant( exporting  i_dialog      = abap_true
                                                    i_fire_events = abap_true
                                         exceptions not_found     = 1
                                                    cancelled     = 2
                                                    others        = 3 ).
  case sy-subrc.
  when 0.
  when 2.
    raise canceled.
  when others.
    raise not_found.
  endcase.

* if lr_configuration_observer->is_changed( if_alv_cml_configuration=>c_change-view ) = abap_true.
  if lr_configuration_observer->is_changed(  ) = abap_true.
    ls_layout = me->r_configuration->get_s_layout( ).
    if ls_layout-graphics is not initial.
      me->set_graphics_view_pair( ).
    endif.
    me->set_view( ls_layout-frontend ).
  endif.

endmethod.


method SET_CRYSTAL_VIEW_PAIR.

  data: lr_configuration_read type ref to if_alv_cml_configuration_read,
        lr_vmodel_crystal     type ref to if_salv_grm_vmodel_crystal,
        ls_vmodel             type if_salv_grm_vmodel_ctrl=>ys_vmodel_list,
        lr_ui_view_crystal    type ref to if_salv_gru_view_crystal,
        ls_ui_view            type ys_ui_view_list.

* check for existing pair
  read table me->t_vmodel_list into ls_vmodel
                               with key handle = if_salv_grm_vmodel_ctrl=>c_handle-crystal.
  if sy-subrc = 0.
    exit.
  endif.

* create View Model
  lr_configuration_read = me->r_configuration.
  lr_vmodel_crystal = cl_salv_gz_factory=>instance->create_vmodel_crystal(
                               r_configuration = lr_configuration_read
                               r_data_source   = me->r_data_source
                               r_table_model   = me->r_table_model
                               r_log_provider  = me->r_log ).

* create entry in table t_view_model_list
  ls_vmodel-current    = abap_false.
  ls_vmodel-handle     = if_salv_grm_vmodel_ctrl=>c_handle-crystal.
  ls_vmodel-visible    = abap_true.
  ls_vmodel-appearance = if_salv_grm_vmodel_ctrl=>c_appearance-is_grouped.
  ls_vmodel-type       = if_salv_grm_vmodel_ctrl=>c_type-crystal.
* ls_vmodel-version    =
  ls_vmodel-r_vmodel   = lr_vmodel_crystal.
  append ls_vmodel to me->t_vmodel_list.

* create UI View
  lr_ui_view_crystal = cl_salv_gz_factory=>instance->create_view_crystal(
                                 r_vmodel_crystal = lr_vmodel_crystal
                                 r_parent         = r_parent
                                 r_log_provider   = me->r_log ).

* register event handles
  set handler on_crystal_rpt_uploaded   for lr_ui_view_crystal.
  set handler on_crystal_display_failed for lr_ui_view_crystal.

* create entry in table t_ui_components
  ls_ui_view-handle    = if_salv_grm_vmodel_ctrl=>c_handle-crystal.
  ls_ui_view-visible   = abap_true.
* ls_ui_view-version   =
  ls_ui_view-r_ui_view = lr_ui_view_crystal.
  ls_ui_view-r_parent  = lr_ui_view_crystal->if_salv_gru_view_ctrl~get_view_parent( ).
  create object ls_ui_view-r_exception_logger type lcl_crystal_exception_logger
      exporting r_logger = me->r_log.
  append ls_ui_view to me->t_ui_view_list.

endmethod.


method SET_EXCEL_VIEW_PAIR.

  data: lr_configuration_read type ref to if_alv_cml_configuration_read,
        lr_listview_service   type ref to if_salv_grm_listview_service,
        lr_vmodel_excel       type ref to if_salv_grm_vmodel_excel,
        ls_vmodel             type if_salv_grm_vmodel_ctrl=>ys_vmodel_list,
        lr_ui_view_excel      type ref to if_salv_gru_view_excel,
        ls_ui_view            type ys_ui_view_list.

* check for existing pair
  read table me->t_vmodel_list into ls_vmodel
                               with key handle = if_salv_grm_vmodel_ctrl=>c_handle-excel.
  if sy-subrc = 0.
    exit.
  endif.

* create ListViewService
  lr_configuration_read = me->r_configuration.
  lr_listview_service = cl_salv_gz_factory=>instance->create_listview_service(
                               r_master        = me->r_master
                               r_configuration = lr_configuration_read
                               r_data_source   = me->r_data_source
                               r_table_model   = me->r_table_model
                               r_log_provider  = me->r_log ).

* create View Model
  lr_vmodel_excel = cl_salv_gz_factory=>instance->create_vmodel_excel(
                               r_listview_service = lr_listview_service
                               r_log_provider     = me->r_log ).

* create entry in table t_view_model_list
  ls_vmodel-current    = abap_false.
  ls_vmodel-handle     = if_salv_grm_vmodel_ctrl=>c_handle-excel.
  ls_vmodel-visible    = abap_true.
  ls_vmodel-appearance = if_salv_grm_vmodel_ctrl=>c_appearance-is_grouped.
  ls_vmodel-type       = if_salv_grm_vmodel_ctrl=>c_type-excel.
* ls_vmodel-version    =
  ls_vmodel-r_vmodel   = lr_vmodel_excel.
  append ls_vmodel to me->t_vmodel_list.

* create UI View
  lr_ui_view_excel = cl_salv_gz_factory=>instance->create_view_excel(
                                 r_vmodel_excel = lr_vmodel_excel
                                 r_parent       = r_parent
                                 r_log_provider = me->r_log ).

* register event handles
  set handler on_excel_display_failed for lr_ui_view_excel.

* init excel view no longer required, in fact it leads to problems! ( wrong UI message )
* LOAD VARIANT, SELECT_VARIANT, EXECUTE_FCODE,... leads to SOFT_REFRESH_TABLE_DISPLAY
* which creates the view with the correct template
*  lr_ui_view_excel->if_salv_gru_view_ctrl~init( ).

* create entry in table t_ui_components
  ls_ui_view-handle    = if_salv_grm_vmodel_ctrl=>c_handle-excel.
  ls_ui_view-visible   = abap_true.
* ls_ui_view-version   =
  ls_ui_view-r_ui_view = lr_ui_view_excel.
  ls_ui_view-r_parent  = lr_ui_view_excel->if_salv_gru_view_ctrl~get_view_parent( ).
  append ls_ui_view to me->t_ui_view_list.

endmethod.


method SET_FIXED_COLS .

*  data: ls_vmodel     type if_salv_grm_vmodel_ctrl=>ys_vmodel_list,
*        ls_view       type YS_UI_VIEW_LIST,
*        lr_view_grid  type ref to if_salv_gru_view_grid,
*        lr_view_excel type ref to if_salv_gru_view_excel.
*
*  me->get_current_vmodel_and_view( importing es_vmodel = ls_vmodel
*                                             es_view   = ls_view ).
*  case ls_vmodel-handle.
*  when if_salv_grm_vmodel_ctrl=>c_handle-grid.
*    lr_view_grid ?= ls_view-r_ui_view.
*    lr_view_grid->set_fixed_cols( cols ).
*  when if_salv_grm_vmodel_ctrl=>c_handle-excel.
*    lr_view_excel   ?= ls_view-r_ui_view.
*    lr_view_excel->set_fixed_cols( cols ).
*  when others.
*    " nothing todo
*  endcase.

  me->r_table_model->notify_change( if_salv_grm_table_model=>c_change-fixed_cols ).

endmethod.


method SET_FRONTEND.

  data: ls_layout type lvc_s_layo.

  ls_layout = me->r_configuration->get_s_layout( ).
  ls_layout-frontend = frontend.
  me->r_configuration->set_s_layout( ls_layout ).

endmethod.


method SET_GRAPHICS_VIEW_PAIR.

  data: lr_vmodel_graphics type ref to if_salv_grm_vmodel_graphics,
        ls_vmodel           type if_salv_grm_vmodel_ctrl=>ys_vmodel_list,
        lr_ui_view_graphics type ref to if_salv_gru_view_graphics,
        ls_ui_view          type ys_ui_view_list,
        l_index             type i.

* check for existing pair
  read table me->t_vmodel_list into ls_vmodel with key handle = if_salv_grm_vmodel_ctrl=>c_handle-graphics.
  if sy-subrc = 0.
*   set visibility flags and update parent
    l_index = sy-tabix.
    ls_vmodel-visible = abap_true.
    modify me->t_vmodel_list from ls_vmodel index l_index transporting visible.
    read table me->t_ui_view_list into ls_ui_view with key handle = if_salv_grm_vmodel_ctrl=>c_handle-graphics.
    assert sy-subrc = 0.
    l_index = sy-tabix.
    ls_ui_view-visible  = abap_true.
    ls_ui_view-r_parent = ls_ui_view-r_ui_view->get_view_parent( ).
    modify me->t_ui_view_list index l_index from ls_ui_view transporting visible r_parent .
    exit.
  endif.

* create view model
  lr_vmodel_graphics = cl_salv_gz_factory=>instance->create_vmodel_graphics( r_master       = me->r_master
                                                                             r_log_provider = me->r_log ).

* create entry in table t_view_model_list
  ls_vmodel-current    = abap_false.
  ls_vmodel-handle     = if_salv_grm_vmodel_ctrl=>c_handle-graphics.
  ls_vmodel-visible    = abap_true.
  ls_vmodel-appearance = if_salv_grm_vmodel_ctrl=>c_appearance-is_grouped.
  ls_vmodel-type       = if_salv_grm_vmodel_ctrl=>c_type-graphics.
* ls_vmodel-version    =
  ls_vmodel-r_vmodel   = lr_vmodel_graphics.
  append ls_vmodel to me->t_vmodel_list.

* create UI View
  lr_ui_view_graphics = cl_salv_gz_factory=>instance->create_view_graphics( r_vmodel_graphics = lr_vmodel_graphics
                                                                             r_log_provider    = me->r_log ).

* create entry in table t_ui_components
  ls_ui_view-handle    = if_salv_grm_vmodel_ctrl=>c_handle-graphics.
  ls_ui_view-visible   = abap_true.
* ls_ui_view-version   =
  ls_ui_view-r_ui_view = lr_ui_view_graphics.
  ls_ui_view-r_parent  = lr_ui_view_graphics->if_salv_gru_view_ctrl~get_view_parent( ).
  append ls_ui_view to me->t_ui_view_list.

  set handler me->on_close_graphics for lr_ui_view_graphics.

endmethod.


method SET_GRID_VIEW_PAIR.

  data: lr_configuration_read type ref to if_alv_cml_configuration_read,
        lr_listview_service   type ref to if_salv_grm_listview_service,
        lr_vmodel_grid        type ref to if_salv_grm_vmodel_grid,
        ls_vmodel             type if_salv_grm_vmodel_ctrl=>ys_vmodel_list,
        lr_ui_view_grid       type ref to if_salv_gru_view_grid,
        ls_ui_view            type ys_ui_view_list.

* create ListViewService
  lr_configuration_read = me->r_configuration.
  lr_listview_service = cl_salv_gz_factory=>instance->create_listview_service(
                               r_master        = me->r_master
                               r_configuration = lr_configuration_read
                               r_data_source   = me->r_data_source
                               r_table_model   = me->r_table_model
                               r_log_provider  = me->r_log ).

* create View Model
  lr_vmodel_grid = cl_salv_gz_factory=>instance->create_vmodel_grid(
                               r_listview_service = lr_listview_service
                               r_log_provider     = me->r_log ).

* create entry in table t_view_model_list
  ls_vmodel-current    = abap_true .
  ls_vmodel-handle     = if_salv_grm_vmodel_ctrl=>c_handle-grid.
  ls_vmodel-visible    = abap_true.
  ls_vmodel-appearance = if_salv_grm_vmodel_ctrl=>c_appearance-is_grouped.
  ls_vmodel-type       = if_salv_grm_vmodel_ctrl=>c_type-grid.
* ls_vmodel-version    =
  ls_vmodel-r_vmodel   = lr_vmodel_grid.
  append ls_vmodel to me->t_vmodel_list.

* create UI View
  lr_ui_view_grid ?= cl_salv_gz_factory=>instance->create_view_grid(
                                 r_master      = r_master
                                 r_vmodel_grid  = lr_vmodel_grid
                                 r_log_provider = me->r_log ).

* create entry in table t_ui_components
  ls_ui_view-handle    = if_salv_grm_vmodel_ctrl=>c_handle-grid.
  ls_ui_view-visible   = abap_true.
* ls_ui_view-version   =
  ls_ui_view-r_ui_view = lr_ui_view_grid.
  ls_ui_view-r_parent  = lr_ui_view_grid->if_salv_gru_view_ctrl~get_view_parent( ).
  append ls_ui_view to me->t_ui_view_list.

endmethod.


method SET_HTML_HEADER.

  data: ls_vmodel     type if_salv_grm_vmodel_ctrl=>ys_vmodel_list,
        ls_view       type ys_ui_view_list,
        lr_view_excel type ref to if_salv_gru_view_excel.

  me->get_current_vmodel_and_view( importing es_vmodel = ls_vmodel
                                             es_view   = ls_view ).
  case ls_vmodel-handle.
  when if_salv_grm_vmodel_ctrl=>c_handle-excel.
    lr_view_excel ?= ls_view-r_ui_view.
    lr_view_excel->set_header_for_oi( it_header ).
  when others.
    " nothing todo
  endcase.

endmethod.


method SET_TOOLBAR.

data: lr_vmodel_toolbar type ref to if_salv_grm_vmodel_toolbar,
      ls_vmodel         type if_salv_grm_vmodel_ctrl=>ys_vmodel_list.

* call level > 1: update toolbar happens later during update frontend
  if call_level > 1.
    exit.
  endif.

* send interactive flag to vmodel
  read table me->t_vmodel_list into ls_vmodel with key handle = if_salv_grm_vmodel_ctrl=>c_handle-toolbar.
  if sy-subrc <> 0.
    exit.
  endif.
  lr_vmodel_toolbar ?= ls_vmodel-r_vmodel.

* update toolbar
  lr_vmodel_toolbar->set_interactive_flag( i_interactive ).
  me->update_toolbar( ).
  lr_vmodel_toolbar->set_interactive_flag( abap_false ).

endmethod.


method SET_TOOLBAR_PAIR.

  data: lr_configuration_read type ref to if_alv_cml_configuration_read,
        lr_vmodel_toolbar     type ref to if_salv_grm_vmodel_toolbar,
        ls_vmodel             type if_salv_grm_vmodel_ctrl=>ys_vmodel_list,
        lr_ui_view_toolbar    type ref to if_salv_gru_view_toolbar,
        ls_ui_view            type ys_ui_view_list.

* check for existing pair
  read table me->t_vmodel_list into ls_vmodel
                               with key handle = if_salv_grm_vmodel_ctrl=>c_handle-toolbar.
  if sy-subrc = 0.
    exit.
  endif.

* create View Model
  lr_configuration_read = me->r_configuration.
  lr_vmodel_toolbar = cl_salv_gz_factory=>instance->create_vmodel_toolbar(
                               r_configuration = lr_configuration_read
                               r_master        = me->r_master
                               r_log_provider  = me->r_log ).

* create entry in table t_view_model_list
  ls_vmodel-current    = abap_false.
  ls_vmodel-handle     = if_salv_grm_vmodel_ctrl=>c_handle-toolbar.
  ls_vmodel-visible    = abap_true.
  ls_vmodel-appearance = if_salv_grm_vmodel_ctrl=>c_appearance-is_permanent.
  ls_vmodel-type       = if_salv_grm_vmodel_ctrl=>c_type-toolbar.
* ls_vmodel-version    =
  ls_vmodel-r_vmodel   = lr_vmodel_toolbar.
  append ls_vmodel to me->t_vmodel_list.

* create UI View
  lr_ui_view_toolbar = cl_salv_gz_factory=>instance->create_view_toolbar(
                                 r_master         = r_master
                                 r_vmodel_toolbar = lr_vmodel_toolbar
                                 r_log_provider   = me->r_log ).

* create entry in table t_ui_components
  ls_ui_view-handle    = if_salv_grm_vmodel_ctrl=>c_handle-toolbar.
  ls_ui_view-visible   = abap_true.
* ls_ui_view-version   =
  ls_ui_view-r_ui_view = lr_ui_view_toolbar.
  ls_ui_view-r_parent  = lr_ui_view_toolbar->if_salv_gru_view_ctrl~get_view_parent( ).
  append ls_ui_view to me->t_ui_view_list.

endmethod.


method SET_VIEW.

  data: ls_ui_view_grid type ys_ui_view_list,
        lr_view_grid    type ref to if_salv_gru_view_grid.

  read table me->t_ui_view_list into ls_ui_view_grid with key handle = if_salv_grm_vmodel_ctrl=>c_handle-grid.
  assert sy-subrc = 0. " internal error
  lr_view_grid ?= ls_ui_view_grid-r_ui_view.

  data(l_frontend) = i_frontend.
  if cl_gui_object=>www_active = 'X' or     "YI3K628237
     cl_gui_object=>javabean = 'X'.         "no Excel inplace or Crystal in WEBGUI and JAVA!
    if l_frontend = if_alv_z=>c_frontend-excel.
        message s121(salv_gru).
        l_frontend = if_alv_z=>c_frontend-table.
    elseif l_frontend = if_alv_z=>c_frontend-crystal.
        message s120(salv_gru).
        l_frontend = if_alv_z=>c_frontend-table.
    endif.
  endif.

  case l_frontend.
    when if_alv_z=>c_frontend-table.
      me->set_visibility_flags( if_salv_grm_vmodel_ctrl=>c_handle-grid ).
      me->set_frontend( if_alv_z=>c_frontend-table ).
      me->r_table_model->set_next_view( if_salv_c_function=>view_grid ).
      lr_view_grid->set_view( if_salv_c_function=>view_grid ).

    when if_alv_z=>c_frontend-excel.
      set_excel_view_pair( ls_ui_view_grid-r_parent ).
      me->set_visibility_flags( if_salv_grm_vmodel_ctrl=>c_handle-excel ).
      me->set_frontend( if_alv_z=>c_frontend-excel ).
      me->r_table_model->set_next_view( if_salv_c_function=>view_excel ).
      lr_view_grid->set_view( if_salv_c_function=>view_excel ).

    when if_alv_z=>c_frontend-crystal.
      set_crystal_view_pair( ls_ui_view_grid-r_parent ).
      me->set_visibility_flags( if_salv_grm_vmodel_ctrl=>c_handle-crystal ).
      me->set_frontend( if_alv_z=>c_frontend-crystal ).
      me->r_table_model->set_next_view( if_salv_c_function=>view_crystal ).
      lr_view_grid->set_view( if_salv_c_function=>view_crystal ).
      me->close_graphics( ).
  endcase.

endmethod.


method SET_VISIBILITY_FLAGS.

  data: l_visible type abap_bool.

 field-symbols: <ls_vmodel>  type if_salv_grm_vmodel_ctrl=>ys_vmodel_list,
                <ls_ui_view> type ys_ui_view_list.

  loop at me->t_vmodel_list assigning <ls_vmodel> where appearance = if_salv_grm_vmodel_ctrl=>c_appearance-is_grouped
                                                    and handle    <> if_salv_grm_vmodel_ctrl=>c_handle-graphics.
    read table me->t_ui_view_list assigning <ls_ui_view> index sy-tabix.
    if sy-subrc = 0.
      if <ls_vmodel>-handle = handle.
        l_visible = abap_true.
      else.
        l_visible = abap_false.
      endif.
      <ls_ui_view>-visible = l_visible.
      <ls_vmodel>-current = l_visible.
      <ls_vmodel>-visible = l_visible.
    endif.
  endloop.

endmethod.


method UPDATE_FRONTEND.

  data: l_exc type ref to cx_salv_int_no_check.

  mac_task_begin c_task-update_frontend space.

  try.
    me->update_frontend_internal( ).
  catch cx_salv_int_no_check into l_exc.
    if me->r_current_exception_logger is not initial.
      me->r_current_exception_logger->report_update_view_exception( l_exc ).
    else.
      me->r_log->report_exception( l_exc ).
    endif.
    me->perform_action( if_salv_c_function=>view_grid ).
    me->update_frontend_internal( ).
  endtry.

  mac_task_end c_task-update_frontend.

  display_messages( ).

endmethod.


method UPDATE_FRONTEND_INTERNAL.

  data: ls_ui_view type ys_ui_view_list.

*  ...Phase 1 : Update Frontend
* ...keep an eye on the sequence : Toolbar, View(s) : Grid, Excel,..., Graphics
  loop at me->t_ui_view_list into ls_ui_view where visible = abap_true
                                               and handle <> if_salv_grm_vmodel_ctrl=>c_handle-graphics.
    mac_update_task_begin c_task-update ls_ui_view.
    me->r_current_exception_logger = ls_ui_view-r_exception_logger.
    ls_ui_view-r_ui_view->update( ).
    mac_task_end c_task-update.
  endloop.

*...raise After_Refresh Event
  me->R_MASTER->_get_grid_facade( )->events( )->raise_evt_after_refresh( ).

  read table me->t_ui_view_list into ls_ui_view with key visible = abap_true
                                                         handle  = if_salv_grm_vmodel_ctrl=>c_handle-graphics.
  if sy-subrc eq 0.
    mac_update_task_begin c_task-update ls_ui_view.
    me->r_current_exception_logger = ls_ui_view-r_exception_logger.
    ls_ui_view-r_ui_view->update( ).
    mac_task_end c_task-update.
  endif.

*...Toolbarhandling Height
  data: l_toolbar_height_in_pixel type if_salv_gru_view_ctrl=>y_height.
  data: lr_toolbar type ref to if_salv_gru_view_toolbar.
  read table me->t_ui_view_list into ls_ui_view with key
                                     handle = if_salv_grm_vmodel_ctrl=>c_handle-toolbar.
  if sy-subrc eq 0.
    lr_toolbar ?= ls_ui_view-r_ui_view.
* YI3K488957 adapt toolbar height to screen resolution/Excel/Crystal View
*    l_toolbar_height_in_pixel = lr_toolbar->get_size_in_pixel( ).
    l_toolbar_height_in_pixel = cl_gui_cfw=>compute_metric_from_dynp(
                       metric = cl_gui_control=>METRIC_PIXEL
                       x_or_y = 'Y'
                       in = 1 ).
  else.
    l_toolbar_height_in_pixel = 0.
  endif.

*...Phase 2 : Set Visiblity and Alignement of View
  loop at me->t_ui_view_list into ls_ui_view. "where visible = abap_false.
    mac_update_task_begin c_task-set_visible ls_ui_view.
    me->r_current_exception_logger = ls_ui_view-r_exception_logger.
    ls_ui_view-r_ui_view->set_visible( visible              = ls_ui_view-visible
                                       reserve_pixel_at_top = l_toolbar_height_in_pixel ).
    mac_task_end c_task-set_visible.
  endloop.

endmethod.


method UPDATE_IMMEDIATELY.

  data: ls_ui_view type ys_ui_view_list.

  update = abap_true.
  loop at me->t_ui_view_list into ls_ui_view where visible = abap_true.
    if ls_ui_view-r_ui_view->delay_update( ) = abap_true.
      update = abap_false.
      exit.
    endif.
  endloop.

endmethod.


method UPDATE_TOOLBAR.

data: ls_ui_view                type ys_ui_view_list,
      l_subrc                   type i,
      l_toolbar_height_in_pixel type if_salv_gru_view_ctrl=>y_height,
      lr_toolbar                type ref to if_salv_gru_view_toolbar.

  read table me->t_ui_view_list into ls_ui_view with key handle = if_salv_grm_vmodel_ctrl=>c_handle-toolbar.
  assert sy-subrc = 0.

* ...Phase 1 : Update Frontend
  if ls_ui_view-visible = abap_true.
    mac_update_task_begin c_task-update ls_ui_view.
    me->r_current_exception_logger = ls_ui_view-r_exception_logger.
    ls_ui_view-r_ui_view->update( ).
    mac_task_end c_task-update.
  endif.

*...Toolbarhandling Height
  lr_toolbar ?= ls_ui_view-r_ui_view.
  l_toolbar_height_in_pixel = lr_toolbar->get_size_in_pixel( ).

*...Phase 2 : Set Visiblity
  mac_update_task_begin c_task-set_visible ls_ui_view.
  me->r_current_exception_logger = ls_ui_view-r_exception_logger.
  ls_ui_view-r_ui_view->set_visible( visible              = ls_ui_view-visible
                                     reserve_pixel_at_top = l_toolbar_height_in_pixel ).
  mac_task_end c_task-set_visible.

endmethod.
ENDCLASS.
