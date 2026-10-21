FUNCTION Z_TI_GET_REQ_OF_IMPORT_QUERY.
*"--------------------------------------------------------------------
*"*"로컬인터페이스:
*"       EXPORTING
*"             REFERENCE(EX_FACTORY) TYPE  MMPUR_DATABL_FACTORY
*"--------------------------------------------------------------------

  data: a_factory type ref to lcl_datablade_factory.

  create object a_factory.

  ex_factory = a_factory.

ENDFUNCTION.
