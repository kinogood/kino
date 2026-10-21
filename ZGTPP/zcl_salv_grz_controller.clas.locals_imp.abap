*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

class lcl_exception_logger implementation.

  method constructor.
*      importing value(r_logger) type ref to if_salv_csq_log.
    me->r_logger = r_logger.
  endmethod.

  method report_update_view_exception.
*      importing value(r_exception) type ref to cx_salv_int_no_check.
    me->r_logger->report_exception( r_exception ).
  endmethod.

endclass.


class lcl_crystal_exception_logger definition
    inheriting from lcl_exception_logger.

  public section.

    methods report_update_view_exception redefinition.

endclass.

class lcl_crystal_exception_logger implementation.

  method report_update_view_exception.
*      importing value(r_exception) type ref to cx_salv_int_no_check.

    data l_trace_id type string.
    data l_short_text type string.
    data l_msg type string.
    data l_class_name type abap_abstypename.
    data l_error_code type string.
    data lr_viewer_error type ref to cx_salv_bog_cr_viewer_error.
    data l_message type string.
    data l_technical_message type string.
    data l_exception_id type string.

    " exceptions with text that corresponds to controller's reaction
    l_class_name = cl_abap_classdescr=>get_class_name( r_exception ).
    replace first occurrence of '\CLASS=' in l_class_name with space.

    if l_class_name = 'CX_SALV_BOG_NO_COLUMN_DEFINED'
        or l_class_name = 'CX_SALV_BOG_CR_NOT_INSTALLED'
        or l_class_name = 'CX_SALV_BOG_CR_DISABLED'.
      me->r_logger->report_exception( r_exception ).
      return.
    endif.

    " exception from CR viewer that are mapped to concrete error messages
    if l_class_name = 'CX_SALV_BOG_CR_VIEWER_ERROR'.
      lr_viewer_error ?= r_exception.

      case lr_viewer_error->id.

        when 451. " invalid generic report
          " (this could happen most probably because
          "  specific report is used on place of generic one)
          message e015(salv_boqt) into l_msg.
          me->r_logger->report_system_message( ).
          return.

        when 6. " out of memory
          me->r_logger->log_exception( r_exception ).
          l_exception_id = |CR{ lr_viewer_error->id }|.
          l_trace_id = me->r_logger->get_trace_id( ).
          l_technical_message = r_exception->get_text( ).
          message e007(salv_boqt) into l_message
              with l_exception_id l_technical_message l_trace_id.
          me->r_logger->report_system_message( ).
          return.

      endcase.
    endif.

    " exception with (unknown) UI relevant text
    try.
        data r_with_msg type ref to cx_salv_int_ui_msg.
        r_with_msg ?= r_exception.
        me->r_logger->report_exception( r_exception ).

*        message s120(salv_gru) into l_message.
        message s005(salv_boqt) into l_message.
        me->r_logger->report_system_message( ).
        return.

      catch cx_sy_move_cast_error.
    endtry.

    " internal error (without message)

    " log exception
    me->r_logger->log_exception( r_exception ).

    " in case crystal viewer error, provide CR error code
    " otherwise provide class name as error code
    if l_class_name = 'CX_SALV_BOG_CR_VIEWER_ERROR'.
      lr_viewer_error ?= r_exception.
      l_error_code = |CR{ lr_viewer_error->id }|.
    else.
      l_error_code = l_class_name.
    endif.

    l_trace_id = me->r_logger->get_trace_id( ).

    " display standard message
    l_short_text = r_exception->get_text( ).
    message e000(salv_boqt) with l_error_code l_short_text l_trace_id into l_msg.
    me->r_logger->report_system_message( ).


  endmethod.

endclass.
