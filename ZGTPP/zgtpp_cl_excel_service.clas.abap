class ZGTPP_CL_EXCEL_SERVICE definition
  public
  final
  create public .

public section.

  constants GC_FILE_FILTER type STRING value 'Excel(*.xls, *.xlsx)|*.xls;*.xlsx|All files|*.*' ##NO_TEXT.
  constants GC_EXTENSION type STRING value 'XLSX' ##NO_TEXT.
  constants GC_UPLOAD type CHAR01 value 'U' ##NO_TEXT.
  constants GC_DOWNLOAD type CHAR01 value 'D' ##NO_TEXT.
  class-data GV_FILE type STRING .

  methods SAVE_DOCUMENT .
  methods DOWNLOAD_SPREADSHEET
    importing
      !IT_DATA type STANDARD TABLE
      !IT_FCAT type LVC_T_FCAT optional
      !IV_SHEET_NAME type CHAR30 optional
      !IV_TOP type I optional
    raising
      CX_BCS .
  class-methods FILE_EXECUTE .
  methods CONSTRUCTOR .
  class-methods GET_INSTANCE
    importing
      !IV_MODE type CHAR01 default 'D'
      !IV_FILE type STRING optional
      !IS_WWWDATA type WWWDATATAB optional
    returning
      value(RR_EXCEL) type ref to ZGTPP_CL_EXCEL_SERVICE
    raising
      CX_BCS .
  methods READ_SPREADSHEET
    importing
      !IV_SHEET_NAME type CHAR30 optional
      !IV_TOP type I default 2
      !IV_LEFT type I default 1
    exporting
      !ET_DATA type STANDARD TABLE
      !ET_RETURN type BAPIRET2_TAB
    raising
      CX_BCS .
  methods DESTROY_DOCUMENT .
  class-methods DOWNLOAD_WEB_OBJECT
    importing
      !IS_KEY type WWWDATATAB
      !IV_FILE type STRING optional
      !IV_FILE_EXECUTE type ABAP_BOOL default 'X' .
protected section.
private section.

  data GR_CONTROL type ref to I_OI_CONTAINER_CONTROL .
  data GR_CONTAINER type ref to CL_GUI_CUSTOM_CONTAINER .
  constants GC_CONTAINER type CHAR20 value 'CONTAINER' ##NO_TEXT.
  data GR_DOCUMENT_PROXY type ref to I_OI_DOCUMENT_PROXY .
  data GR_SPREADSHEET type ref to I_OI_SPREADSHEET .
  data GR_MERGE type ref to I_OI_MAIL_MERGE .
  data GR_ERROR type ref to I_OI_ERROR .
  constants GC_APPL_NAME type CHAR20 value 'EXCEL' ##NO_TEXT.
  data GV_DOCUMENT_URL type CHAR1024 .
  class-data GV_MODE type CHAR01 .
  class-data GS_WWWDATA type WWWDATATAB .
  data GT_DATA_FIELD type LVC_T_RFCFIELDS .
  data GT_HEADER_FIELD type LVC_T_RFCFIELDS .
  data GT_TITLE_FIELD type LVC_T_RFCFIELDS .
  data GV_TOP type I .
  data GV_LINES type I .
  data GV_COLUMNS type I .
  data:
    gt_numc_field type table of i .
  data GS_NUMC_FIELD type I .
  constants GC_TITLE_RANGE type CHAR50 value 'TITLE_RANGE' ##NO_TEXT.
  constants GC_DATA_RANGE type CHAR50 value 'DATA_RANGE' ##NO_TEXT.
  data GR_DATA type ref to DATA .
  data GR_TITLE type ref to DATA .
  constants GC_DOCUMENT_TYPE type CHAR20 value 'Excel.Sheet' ##NO_TEXT.
  constants GC_INTLEN type I value 50 ##NO_TEXT.
  class-data GV_FILENAME type STRING .
  class-data GV_PATH type STRING .
  constants GC_HEADER_RANGE type CHAR50 value 'HEADER_RANGE' ##NO_TEXT.

  methods BUILD_MESSAGE
    importing
      !IR_ERROR type ref to I_OI_ERROR
    raising
      CX_BCS .
  class-methods FILE_EXIST
    raising
      CX_BCS .
  class-methods FILE_VALIDATION_CHECK
    importing
      !IV_FILE type STRING
    raising
      CX_BCS .
  class-methods RAISE_EXCEPTION
    importing
      !IV_MESSAGE type STRING
    raising
      CX_BCS .
  methods BUILD_FIELD_TABLE .
  methods CREATE_DATA_ITAB
    importing
      !IT_DATA type STANDARD TABLE
      !IT_FCAT type LVC_T_FCAT .
  class-methods FILE_SAVE_DIALOG .
  methods SET_CELL_STYLES .
  methods SET_DATA_RANGES
    raising
      CX_BCS .
  methods TRANSFER_DATA_TO_EXCEL
    raising
      CX_BCS .
  class-methods FILE_OPEN_DIALOG .
  methods BUILD_FIELD_TABLE_HEADER
    importing
      !IT_DATA type STANDARD TABLE .
ENDCLASS.



CLASS ZGTPP_CL_EXCEL_SERVICE IMPLEMENTATION.


  method BUILD_FIELD_TABLE.
    data lr_tabledescr type ref to cl_abap_tabledescr.
    data lr_structure  type ref to cl_abap_structdescr.
    data lt_components type abap_component_tab.
    data lv_tabname type dd02l-tabname.
    data lv_offset1 type i.
    data lv_offset2 type i.
    data ls_field   type rfc_fields.
    data ls_component type abap_compdescr.
    field-symbols <lt_data>  type standard table.

    assign gr_data->* to <lt_data>.

    lr_tabledescr ?= cl_abap_datadescr=>describe_by_data( <lt_data> ).
    lr_structure  ?= lr_tabledescr->get_table_line_type( ).

    gv_columns = lines( lr_structure->components ).
    gv_lines   = lines( <lt_data> ).

    search lr_structure->absolute_name for '\TYPE='.
    if sy-subrc is initial.
      sy-fdpos = sy-fdpos + strlen( '\TYPE=' ).
      lv_tabname = lr_structure->absolute_name+sy-fdpos.
    else.
      lv_tabname = 'UNKNOWN'.
    endif.

    clear: gt_data_field, gt_title_field.

    loop at lr_structure->components into ls_component.
      clear ls_field.
      move-corresponding ls_component to ls_field.
      ls_field-tabname   = lv_tabname.
      ls_field-fieldname = ls_component-name.

      case ls_component-type_kind.
        when 'D' or 'T'.
          ls_field-exid = 'C'.

        when others.
          ls_field-exid = ls_component-type_kind.
      endcase.

      if ls_field-exid ne 'P'.
        ls_field-intlength = ls_component-length / cl_abap_char_utilities=>charsize.
      else.
        ls_field-intlength = ls_component-length.
      endif.

      ls_field-position  = sy-tabix.
      ls_field-offset    = lv_offset1.
      lv_offset1         = lv_offset1 + ls_field-intlength.
      append ls_field to gt_data_field.

      ls_field-exid       = 'C'.
      ls_component-length = gc_intlen.
      ls_field-intlength  = gc_intlen. "ls_component-length / cl_abap_char_utilities=>charsize.
      ls_field-offset     = lv_offset2.
      lv_offset2          = lv_offset2 + ls_field-intlength.
      append ls_field to gt_title_field.
    endloop.

  endmethod.


  METHOD BUILD_FIELD_TABLE_HEADER.

    DATA LR_TABLEDESCR TYPE REF TO CL_ABAP_TABLEDESCR.
    DATA LR_STRUCTURE  TYPE REF TO CL_ABAP_STRUCTDESCR.
    DATA LT_COMPONENTS TYPE ABAP_COMPONENT_TAB.
    DATA LV_TABNAME TYPE DD02L-TABNAME.
    DATA LV_OFFSET1 TYPE I.
    DATA LV_OFFSET2 TYPE I.
    DATA LS_FIELD   TYPE RFC_FIELDS.
    DATA LS_COMPONENT TYPE ABAP_COMPDESCR.
    FIELD-SYMBOLS <LT_DATA>  TYPE STANDARD TABLE.

*    ASSIGN GR_DATA->* TO <LT_DATA>.

    LR_TABLEDESCR ?= CL_ABAP_DATADESCR=>DESCRIBE_BY_DATA( IT_DATA ).
    LR_STRUCTURE  ?= LR_TABLEDESCR->GET_TABLE_LINE_TYPE( ).

    GV_COLUMNS = LINES( LR_STRUCTURE->COMPONENTS ).
    GV_LINES   = LINES( IT_DATA ).

    SEARCH LR_STRUCTURE->ABSOLUTE_NAME FOR '\TYPE='.
    IF SY-SUBRC IS INITIAL.
      SY-FDPOS = SY-FDPOS + STRLEN( '\TYPE=' ).
      LV_TABNAME = LR_STRUCTURE->ABSOLUTE_NAME+SY-FDPOS.
    ELSE.
      LV_TABNAME = 'UNKNOWN'.
    ENDIF.

    CLEAR: GT_HEADER_FIELD.

    LOOP AT LR_STRUCTURE->COMPONENTS INTO LS_COMPONENT.
      CLEAR LS_FIELD.
      MOVE-CORRESPONDING LS_COMPONENT TO LS_FIELD.
      LS_FIELD-TABNAME   = LV_TABNAME.
      LS_FIELD-FIELDNAME = LS_COMPONENT-NAME.

      CASE LS_COMPONENT-TYPE_KIND.
        WHEN 'D' OR 'T'.
          LS_FIELD-EXID = 'C'.

        WHEN OTHERS.
          LS_FIELD-EXID = LS_COMPONENT-TYPE_KIND.
      ENDCASE.

      IF LS_FIELD-EXID NE 'P'.
        LS_FIELD-INTLENGTH = LS_COMPONENT-LENGTH / CL_ABAP_CHAR_UTILITIES=>CHARSIZE.
      ELSE.
        LS_FIELD-INTLENGTH = LS_COMPONENT-LENGTH.
      ENDIF.

      LS_FIELD-EXID       = 'C'.
      LS_COMPONENT-LENGTH = 50.
      LS_FIELD-INTLENGTH  = 50. "ls_component-length / cl_abap_char_utilities=>charsize.
      LS_FIELD-OFFSET     = LV_OFFSET2.
      LV_OFFSET2          = LV_OFFSET2 + LS_FIELD-INTLENGTH.
      APPEND LS_FIELD TO GT_HEADER_FIELD.
    ENDLOOP.

  ENDMETHOD.


  method BUILD_MESSAGE.
    data lv_message_id type sy-msgid.
    data lv_message_number type sy-msgno.
    data lv_param1 type sy-msgv1.
    data lv_param2 type sy-msgv2.
    data lv_param3 type sy-msgv3.
    data lv_param4 type sy-msgv4.
    data lv_message type string.

    if ir_error is bound.
      gr_error->get_message( importing  message_id     = lv_message_id
                                        message_number = lv_message_number
                                        param1         = lv_param1
                                        param2         = lv_param2
                                        param3         = lv_param3
                                        param4         = lv_param4 ).

      message id lv_message_id type 'E' number lv_message_number
         with lv_param2 lv_param2 lv_param3 lv_param4
         into lv_message.

      raise_exception( lv_message ).
    endif.

  endmethod.


  method CONSTRUCTOR.

    c_oi_container_control_creator=>get_container_control( importing control = gr_control
                                                                     error   = gr_error ).
    if gr_error->has_failed eq abap_true.
      build_message( gr_error ).
    endif.

    gr_control->init_control( exporting r3_application_name      = gc_appl_name
                                        inplace_enabled          = abap_true
                                        inplace_scroll_documents = abap_true
                                        parent                   = cl_gui_container=>screen0
                              importing error                    = gr_error ).

    if gr_error->has_failed eq abap_true.
      build_message( gr_error ).
    endif.

    gr_control->get_document_proxy( exporting document_type  = gc_document_type
                                    importing document_proxy = gr_document_proxy
                                              error          = gr_error ).
    if gr_error->has_failed eq abap_true.
      build_message( gr_error ).
    endif.

*// 분기.
    if gs_wwwdata-objid is not initial.
      zpls_excel_service=>download_web_object( is_key          = gs_wwwdata
                                                 iv_file         = gv_file
                                                 iv_file_execute = abap_false ).
    endif.

    gv_document_url = gv_file.
    translate gv_document_url to upper case.

    if gv_document_url(7) ne 'HTTP://' and gv_document_url(7) ne 'FILE://'.
      concatenate 'FILE://' gv_document_url into gv_document_url.
    endif.

    gr_document_proxy->open_document( exporting open_inplace  = abap_true
                                                document_url  = gv_document_url
                                      importing retcode       = data(lv_retcode) ).

    gr_document_proxy->has_spreadsheet_interface( importing is_available = data(lv_is_available) ).

    if lv_is_available is not initial.
      gr_document_proxy->get_spreadsheet_interface( importing sheet_interface = gr_spreadsheet ).
    else.
      gr_document_proxy->create_document( exporting open_inplace = abap_true
                                          importing retcode      = lv_retcode ).

      gr_document_proxy->has_spreadsheet_interface( importing is_available = lv_is_available ).

      if lv_is_available is not initial.
        gr_document_proxy->get_spreadsheet_interface( importing sheet_interface = gr_spreadsheet ).
      endif.
    endif.

    if gr_spreadsheet is not bound.
      message e893(ux) with gv_file into data(lv_message).
      raise_exception( lv_message ).
    endif.

  endmethod.


  method CREATE_DATA_ITAB.
    data lr_tabledescr  type ref to cl_abap_tabledescr.
    data lr_structdescr type ref to cl_abap_structdescr.
    data ls_fcat type lvc_s_fcat.
    data lt_title_fcat type lvc_t_fcat.
    data ls_title_fcat type lvc_s_fcat.
    data lr_line type ref to data.
    data lr_title type ref to data.
    data lr_temp type ref to data.
    field-symbols <lt_data>  type standard table.
    field-symbols <ls_data>  type any.
    field-symbols <ls_temp>  type any.
    field-symbols <ls_dfies> type dfies.
    field-symbols <lt_title> type standard table.
    field-symbols <ls_title> type any.
    field-symbols <lv_filed> type any.

    lr_tabledescr  ?= cl_abap_typedescr=>describe_by_data( it_data ).
    lr_structdescr ?= lr_tabledescr->get_table_line_type( ).
    data(lt_dfies) = cl_salv_data_descr=>read_structdescr( lr_structdescr ).

    if it_fcat is not initial.
      data(lt_fcat) = it_fcat.
      delete lt_fcat where tech eq abap_true.

      loop at lt_fcat assigning field-symbol(<ls_fcat>).
        <ls_fcat>-col_pos = sy-tabix.

        if <ls_fcat>-datatype eq 'NUMC' or
           <ls_fcat>-datatype eq 'CLNT' or
           <ls_fcat>-datatype eq 'TIMS'.
          append <ls_fcat>-col_pos to gt_numc_field.
        endif.

        clear ls_title_fcat.
        ls_title_fcat-col_pos   = <ls_fcat>-col_pos.
        ls_title_fcat-fieldname = <ls_fcat>-fieldname.
        ls_title_fcat-inttype   = 'C'.
        ls_title_fcat-inttype   = 'CHAR'.
        ls_title_fcat-intlen    = gc_intlen.
        ls_title_fcat-coltext   = <ls_fcat>-coltext.

        if ls_title_fcat-coltext is initial.
          ls_title_fcat-coltext = <ls_fcat>-scrtext_m.
          if ls_title_fcat-coltext is initial.
            ls_title_fcat-coltext = <ls_fcat>-reptext.
          endif.
        endif.

        append ls_title_fcat to lt_title_fcat.
      endloop.
    else.
      loop at lt_dfies assigning <ls_dfies>.
        clear ls_fcat.
        move-corresponding <ls_dfies> to ls_fcat.
        ls_fcat-col_pos = sy-tabix.

        case <ls_dfies>-datatype.
          when 'CURR'.
            ls_fcat-cfieldname = <ls_dfies>-precfield.

          when 'QUAN'.
            ls_fcat-qfieldname = <ls_dfies>-precfield.

          when 'NUMC' or 'CLNT' or 'TIMS'.
            append ls_fcat-col_pos to gt_numc_field.
          when others.
        endcase.

        append ls_fcat to lt_fcat.

        clear ls_title_fcat.
        ls_title_fcat-col_pos   = ls_fcat-col_pos.
        ls_title_fcat-fieldname = ls_fcat-fieldname.
        ls_title_fcat-inttype   = 'C'.
        ls_title_fcat-datatype  = 'CHAR'.
        ls_title_fcat-intlen    = gc_intlen.
        ls_title_fcat-coltext   = ls_fcat-coltext.

        if ls_title_fcat-coltext is initial.
          ls_title_fcat-coltext = ls_fcat-scrtext_m.

          if ls_title_fcat-coltext is initial.
            ls_title_fcat-coltext = ls_fcat-reptext.
          endif.
        endif.

        append ls_title_fcat to lt_title_fcat.
      endloop.
    endif.

    if lines( lt_fcat ) ne lines( lt_dfies ).
      cl_alv_table_create=>create_dynamic_table( exporting it_fieldcatalog = lt_fcat
                                                 importing ep_table        = gr_data ).
      assign gr_data->* to <lt_data>.
      create data lr_line like line of <lt_data>.
      assign lr_line->* to <ls_data>.

      create data lr_temp like line of it_data.
      assign lr_temp->* to <ls_temp>.

      loop at it_data into <ls_temp>.
        clear <ls_data>.
        move-corresponding <ls_temp> to <ls_data>.
        append <ls_data> to <lt_data>.
      endloop.
    else.
      get reference of it_data into gr_data.
    endif.

    cl_alv_table_create=>create_dynamic_table( exporting it_fieldcatalog = lt_title_fcat
                                               importing ep_table        = gr_title ).

    assign gr_title->* to <lt_title>.
    create data lr_title like line of <lt_title>.
    assign lr_title->* to <ls_title>.

    loop at lt_title_fcat into ls_title_fcat.
      assign component sy-tabix of structure <ls_title> to <lv_filed>.
      if sy-subrc is initial.
        if ls_title_fcat-coltext is not initial.
          <lv_filed> = ls_title_fcat-coltext.
        else.
          <lv_filed> = ls_title_fcat-reptext.
        endif.
      endif.
    endloop.

    append <ls_title> to <lt_title>.

  endmethod.


  method DESTROY_DOCUMENT.

    if gr_document_proxy is bound.
      gr_document_proxy->close_document(  ).
      gr_document_proxy->release_document(  ).
      free: gr_document_proxy, gr_spreadsheet.
    endif.

    if gr_control is bound.
      gr_control->release_all_documents( ).
      gr_control->destroy_control( ).
    endif.

  endmethod.


  METHOD DOWNLOAD_SPREADSHEET.
    DATA LV_SHEET_NAME TYPE CHAR30.

    TRY .
        IF IV_SHEET_NAME IS INITIAL.
          GR_SPREADSHEET->GET_ACTIVE_SHEET( IMPORTING SHEETNAME = LV_SHEET_NAME
                                                      ERROR     = GR_ERROR  ).
          IF GR_ERROR->HAS_FAILED EQ ABAP_TRUE.
            BUILD_MESSAGE( GR_ERROR ).
          ENDIF.
        ELSE.
          LV_SHEET_NAME = IV_SHEET_NAME.
        ENDIF.

        GR_SPREADSHEET->SELECT_SHEET( EXPORTING NAME  = LV_SHEET_NAME
                                      IMPORTING ERROR = GR_ERROR ).

        IF GR_ERROR->HAS_FAILED EQ ABAP_TRUE.
          BUILD_MESSAGE( GR_ERROR ).
        ENDIF.

      CATCH CX_ROOT INTO DATA(LR_CX_ROOT).
        MESSAGE ID 'OO' TYPE 'E' NUMBER 000
                WITH LR_CX_ROOT->IF_MESSAGE~GET_TEXT( ) INTO DATA(LV_MESSAGE).

        RAISE_EXCEPTION( LV_MESSAGE ).
    ENDTRY.

    IF IV_TOP IS INITIAL.
      GV_TOP = 2.
    ELSE.
      GV_TOP = IV_TOP.
    ENDIF.

*// Create Intenal Table.
    CREATE_DATA_ITAB( IT_DATA = IT_DATA
                      IT_FCAT = IT_FCAT ).

*// Field Table.
    BUILD_FIELD_TABLE( ).

*// Set Data Range
    SET_DATA_RANGES( ).

*// Cell Styles.
    SET_CELL_STYLES( ).

*// Data -> Excel Sheet.
    TRANSFER_DATA_TO_EXCEL( ).

    GR_SPREADSHEET->SET_ZOOM( ZOOM = 85 ).

    GR_SPREADSHEET->FIT_WIDEST( NAME     = SPACE
                                NO_FLUSH = ABAP_TRUE ).

    IF IV_SHEET_NAME IS INITIAL.
      SAVE_DOCUMENT( ).
    ENDIF.

  ENDMETHOD.


  method DOWNLOAD_WEB_OBJECT.
    data lv_subrc type sy-subrc.

    if iv_file is initial.
      file_save_dialog( ).
    else.
      gv_file = iv_file.
    endif.

    check gv_file is not initial.

    call function 'DOWNLOAD_WEB_OBJECT'
      exporting
        key         = is_key
        destination = conv localfile( gv_file )
      importing
        rc          = lv_subrc.

    if lv_subrc is initial and iv_file_execute eq abap_true.
      zpls_excel_service=>file_execute( ).
    endif.

  endmethod.


  method FILE_EXECUTE.

    if gv_filename is not initial.
      call method cl_gui_frontend_services=>execute
        exporting
          document               = gv_filename
          default_directory      = gv_path
        exceptions
          cntl_error             = 1
          error_no_gui           = 2
          bad_parameter          = 3
          file_not_found         = 4
          path_not_found         = 5
          file_extension_unknown = 6
          error_execute_failed   = 7
          synchronous_failed     = 8
          not_supported_by_gui   = 9
          others                 = 10.
    endif.

  endmethod.


  method FILE_EXIST.
    data lv_message type string.

    cl_gui_frontend_services=>file_exist( exporting  file    = gv_file
                                          receiving  result  = data(lv_result)
                                          exceptions cntl_error           = 1
                                                     error_no_gui         = 2
                                                     wrong_parameter      = 3
                                                     not_supported_by_gui = 4 ).

    case gv_mode.
      when gc_upload.
        if sy-subrc is not initial or lv_result eq abap_false.
          lv_message = text-e01.  "// 파일이 존재하지 않습니다.
        endif.

      when gc_download.
        if sy-subrc is initial and lv_result eq abap_true.
          lv_message = text-e02. "// 이미 동일한 파일이 존재합니다.
        endif.
    endcase.

    if lv_message is not initial.
      clear gv_file.
      raise_exception( lv_message ).
    endif.

  endmethod.


  method FILE_OPEN_DIALOG.
    data lt_file_table type filetable.
    data lv_user_action type i.
    data lv_return type i.

    concatenate cl_gui_frontend_services=>filetype_all
                cl_gui_frontend_services=>filetype_excel
           into data(lv_file_filter).

    call method cl_gui_frontend_services=>file_open_dialog
      exporting
        default_extension       = gc_extension
        file_filter             = lv_file_filter
      changing
        file_table              = lt_file_table
        rc                      = lv_return
        user_action             = lv_user_action
      exceptions
        file_open_dialog_failed = 1
        cntl_error              = 2
        error_no_gui            = 3
        not_supported_by_gui    = 4
        others                  = 5.

    if sy-subrc is initial and lv_user_action eq cl_gui_frontend_services=>action_ok.
      read table lt_file_table into data(ls_file_table) index 1.
      if sy-subrc is initial.
        gv_file = ls_file_table-filename.
      endif.
    endif.

  endmethod.


  method FILE_SAVE_DIALOG.
    data lv_default_file type string.
    data lv_user_action  type i.
    data lv_fullpath     type string.

    concatenate cl_gui_frontend_services=>filetype_all
                cl_gui_frontend_services=>filetype_excel
           into data(lv_file_filter).

    lv_default_file = |export_{ sy-datum }_.xlsx|.

    call method cl_gui_frontend_services=>file_save_dialog
      exporting
        default_file_name         = lv_default_file
        default_extension         = gc_extension
        file_filter               = lv_file_filter
        with_encoding             = abap_true
        prompt_on_overwrite       = abap_false
      changing
        filename                  = gv_filename
        path                      = gv_path
        fullpath                  = lv_fullpath
        user_action               = lv_user_action
      exceptions
        cntl_error                = 1
        error_no_gui              = 2
        not_supported_by_gui      = 3
        invalid_default_file_name = 4
        others                    = 5.

    if sy-subrc is initial and lv_user_action eq cl_gui_frontend_services=>action_ok.
      gv_file = lv_fullpath.
    endif.

  endmethod.


  method FILE_VALIDATION_CHECK.

    clear: gv_file, gv_filename, gv_path.

    if iv_file is initial.
      case gv_mode.
        when gc_upload.
          file_open_dialog( ).

        when gc_download.
          file_save_dialog( ).
      endcase.

      if gv_file is initial.
        return.
      endif.
    else.
      gv_file = iv_file.
    endif.

    file_exist(  ).

  endmethod.


  METHOD get_instance.

    gv_mode = iv_mode.
    gs_wwwdata = is_wwwdata.

    file_validation_check( iv_file ).

    IF gv_file IS INITIAL.
      CLEAR gv_mode.
      RETURN.
    ENDIF.

    rr_excel = NEW zgtpp_cl_excel_service( ).

  ENDMETHOD.


  method RAISE_EXCEPTION.

    raise exception type cx_bcs
      exporting
        error_type = cx_bcs=>x_error
        error_text = iv_message.

  endmethod.


  method READ_SPREADSHEET.
    constants lc_range type char120 value 'DATA_RANGE'.
    constants lc_max_row type i value 10000000.
    data lr_tabledescr type ref to cl_abap_tabledescr.
    data lr_structure  type ref to cl_abap_structdescr.
    data lt_components type abap_component_tab.
    data lt_content type soi_generic_table.
    data ls_cell  type soi_generic_item.
    data lr_error type ref to i_oi_error.
    data lt_range_list type soi_range_list.
    data lr_struct  type ref to data.
    data lv_top     type i.
    data lv_left    type i.
    data lv_columns type i.
    data lv_rows    type i value 2000.
    data lv_empty_row type i.
    data lv_init type i.
    data lv_string type string.
    data lv_sheet_name type char30.
    data lr_cx_root type ref to cx_root.
    data lr_cx_conv_error type ref to cx_sy_conversion_error.
    data ls_return  type bapiret2.
    data lv_message type string.
    field-symbols <ls_data>  type any.
    field-symbols <lv_field> type any.

    try .
        if iv_sheet_name is initial.
          gr_spreadsheet->get_active_sheet( importing sheetname = lv_sheet_name
                                                      error     = gr_error  ).
          if gr_error->has_failed eq abap_true.
            build_message( gr_error ).
          endif.
        else.
          lv_sheet_name =  iv_sheet_name.
        endif.

        gr_spreadsheet->select_sheet( exporting name  = lv_sheet_name
                                      importing error = gr_error ).
        if gr_error->has_failed eq abap_true.
          build_message( gr_error ).
        endif.

        lr_tabledescr ?= cl_abap_typedescr=>describe_by_data( et_data ).
        lr_structure  ?= lr_tabledescr->get_table_line_type( ).

        create data lr_struct type handle lr_structure.
        assign lr_struct->* to <ls_data>.

      catch cx_root into lr_cx_root.
        message id 'OO' type 'E' number 000
              with lr_cx_root->if_message~get_text( ) into lv_message.

        raise_exception( lv_message ).
    endtry.

    loop at lr_structure->get_components( ) into data(ls_components).
      if ls_components-as_include eq abap_true.
        lr_structure ?= ls_components-type.
        append lines of lr_structure->get_components( ) to lt_components.
      else.
        append ls_components to lt_components.
      endif.
    endloop.

    lv_top  = iv_top.
    lv_left = iv_left.
    lv_columns = lines( lt_components ).

    do.
      clear: lt_content, lt_range_list.
      gr_spreadsheet->set_selection( exporting top     = lv_top
                                               left    = lv_left
                                               rows    = lv_rows
                                               columns = lv_columns
                                     importing error   = gr_error ).
      if gr_error->has_failed eq abap_true.
        build_message( gr_error ).
      endif.

      gr_spreadsheet->insert_range( exporting columns = lv_columns
                                              rows    = lv_rows
                                              name    = lc_range
                                    importing error   = gr_error ).
      if gr_error->has_failed eq abap_true.
        build_message( gr_error ).
      endif.

      gr_spreadsheet->get_ranges_names( importing ranges = lt_range_list
                                                  error  = gr_error ).
      if gr_error->has_failed eq abap_true.
        build_message( gr_error ).
      endif.

      delete lt_range_list where name ne lc_range.

      gr_spreadsheet->get_ranges_data( importing contents = lt_content
                                                 error    = gr_error
                                       changing  ranges   = lt_range_list ).
      if gr_error->has_failed eq abap_true.
        build_message( gr_error ).
      endif.

      loop at lt_content into ls_cell.
        assign component conv int4( ls_cell-column ) of structure <ls_data> to <lv_field>.

        if sy-subrc is initial.
          try.
              <lv_field> = ls_cell-value.

            catch cx_sy_conversion_error into lr_cx_conv_error.
              clear ls_return.

              read table lt_components into ls_components index conv int4( ls_cell-column ).
              if sy-subrc is initial.
                ls_return-field = ls_components-name.
              endif.

              ls_return-row        = conv int4( ls_cell-row ).
              ls_return-message_v1 = iv_sheet_name.
              ls_return-type       = 'E'.
              ls_return-message    = lr_cx_conv_error->get_text( ).
              append ls_return to et_return.
              continue.
          endtry.
        endif.

        if <lv_field> is initial.
          lv_init = lv_init + 1.
        else.
          lv_string = conv string( <lv_field> ).
          if lv_string is initial.
            lv_init = lv_init + 1.
          endif.
        endif.

        at end of row.
          if lv_columns eq lv_init.
            lv_empty_row = lv_empty_row + 1.
          else.
            append <ls_data> to et_data.
            clear <ls_data>.
          endif.

          clear lv_init.

          if lv_empty_row gt 5.
            return.
          endif.
        endat.
      endloop.

      lv_top = lv_top + lv_rows.

      if lv_empty_row gt 5 or
         lt_content is initial or
         lv_top ge lc_max_row.
        exit.
      endif.
    enddo.

  endmethod.


  method SAVE_DOCUMENT.

    gr_document_proxy->save_document_to_url( exporting url   = gv_document_url
                                             importing error = gr_error ).
    if gr_error->has_failed eq abap_true.
      build_message( gr_error ).
    endif.

    destroy_document( ).

  endmethod.


  METHOD SET_CELL_STYLES.
    CONSTANTS LC_FNAME TYPE CHAR20 VALUE 'NUMC_COL'.
    DATA LV_TYP TYPE I.
    DATA LV_NAME TYPE CHAR20.
    DATA LV_RETCODE TYPE SOI_RET_STRING.
    DATA LV_LINES TYPE SY-TABIX.
    FIELD-SYMBOLS <LV_TYP> TYPE X.

    ASSIGN LV_TYP TO <LV_TYP> CASTING.
    SET BIT 1 OF <LV_TYP> TO 0. "thickness
    SET BIT 2 OF <LV_TYP> TO 1. "thickness
    SET BIT 3 OF <LV_TYP> TO 1. "horizontal lines
    SET BIT 4 OF <LV_TYP> TO 1. "vertical lines
    SET BIT 5 OF <LV_TYP> TO 1. "right margin
    SET BIT 6 OF <LV_TYP> TO 1. "bottom margin
    SET BIT 7 OF <LV_TYP> TO 1. "top margin
    SET BIT 8 OF <LV_TYP> TO 1. "left margin
    LV_TYP = <LV_TYP>(1).

    IF GS_WWWDATA-OBJID IS INITIAL.
      GR_SPREADSHEET->SET_FRAME( RANGENAME = GC_TITLE_RANGE
                                 TYP       = LV_TYP
                                 COLOR     = 1 ).
      GR_SPREADSHEET->SET_COLOR( RANGENAME = GC_TITLE_RANGE
                                 BACK      = '15'
                                 FRONT     = '1'
                                 NO_FLUSH  = 'X' ).
    ENDIF.

    GR_SPREADSHEET->SET_FRAME( RANGENAME = GC_DATA_RANGE
                               TYP       = LV_TYP
                               COLOR     = 1 ).

    LOOP AT GT_NUMC_FIELD INTO GS_NUMC_FIELD.
      WRITE GS_NUMC_FIELD TO LV_NAME LEFT-JUSTIFIED.
      CONCATENATE LC_FNAME LV_NAME INTO LV_NAME.
      CONDENSE LV_NAME NO-GAPS.

      GR_SPREADSHEET->INSERT_RANGE_DIM( EXPORTING NAME     = LV_NAME
                                                  TOP      = GV_TOP
                                                  LEFT     = GS_NUMC_FIELD
                                                  ROWS     = GV_LINES
                                                  COLUMNS  = 1
                                        IMPORTING RETCODE  = LV_RETCODE ).
*
      GR_SPREADSHEET->SET_FORMAT( EXPORTING RANGENAME = LV_NAME
                                            TYP       = 0
                                            CURRENCY  = SPACE
                                  IMPORTING RETCODE   = LV_RETCODE ).
    ENDLOOP.

  ENDMETHOD.


  METHOD SET_DATA_RANGES.

    DATA : LV_TOP TYPE I.

    LV_TOP = 1.


    IF GS_WWWDATA-OBJID IS INITIAL.
      GR_SPREADSHEET->INSERT_RANGE_DIM( EXPORTING NAME     = GC_TITLE_RANGE
                                                  TOP      = LV_TOP
                                                  LEFT     = 1
                                                  ROWS     = 1
                                                  COLUMNS  = GV_COLUMNS
                                        IMPORTING ERROR    = GR_ERROR ).
      IF GR_ERROR->HAS_FAILED EQ ABAP_TRUE.
        BUILD_MESSAGE( GR_ERROR ).
      ENDIF.
    ENDIF.

    GR_SPREADSHEET->INSERT_RANGE_DIM( EXPORTING NAME     = GC_DATA_RANGE
                                                TOP      = GV_TOP
                                                LEFT     = 1
                                                ROWS     = GV_LINES
                                                COLUMNS  = GV_COLUMNS
                                      IMPORTING ERROR    = GR_ERROR ).
    IF GR_ERROR->HAS_FAILED EQ ABAP_TRUE.
      BUILD_MESSAGE( GR_ERROR ).
    ENDIF.

  ENDMETHOD.


  METHOD TRANSFER_DATA_TO_EXCEL.
    FIELD-SYMBOLS <LT_DATA>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <LT_TITLE> TYPE STANDARD TABLE.

    IF GS_WWWDATA-OBJID IS INITIAL.
      ASSIGN GR_TITLE->* TO <LT_TITLE>.

      GR_SPREADSHEET->INSERT_ONE_TABLE( EXPORTING RANGENAME    = GC_TITLE_RANGE
                                                  DATA_TABLE   = <LT_TITLE>
                                                  FIELDS_TABLE = GT_TITLE_FIELD
                                        IMPORTING ERROR        = GR_ERROR ).
      IF GR_ERROR->HAS_FAILED EQ ABAP_TRUE.
        BUILD_MESSAGE( GR_ERROR ).
      ENDIF.
    ENDIF.

    ASSIGN GR_DATA->* TO <LT_DATA>.

    GR_SPREADSHEET->INSERT_ONE_TABLE( EXPORTING RANGENAME    = GC_DATA_RANGE
                                                DATA_TABLE   = <LT_DATA>
                                                FIELDS_TABLE = GT_DATA_FIELD
                                      IMPORTING ERROR        = GR_ERROR ).
    IF GR_ERROR->HAS_FAILED EQ ABAP_TRUE.
      BUILD_MESSAGE( GR_ERROR ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
