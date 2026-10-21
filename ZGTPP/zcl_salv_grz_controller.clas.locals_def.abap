*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section

class lcl_exception_logger definition.

  public section.

    methods constructor
        importing value(r_logger) type ref to if_salv_csq_log.

    methods report_update_view_exception
        importing value(r_exception) type ref to cx_salv_int_no_check.

  protected section.

    data r_logger type ref to if_salv_csq_log.

endclass.
