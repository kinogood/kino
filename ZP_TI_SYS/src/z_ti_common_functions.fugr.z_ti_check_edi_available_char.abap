FUNCTION Z_TI_CHECK_EDI_AVAILABLE_CHAR.
*"--------------------------------------------------------------------
*"*"로컬인터페이스:
*"       IMPORTING
*"             VALUE(IN_STRING)
*"       EXPORTING
*"             REFERENCE(EX_SUBRC) TYPE  SUBRC
*"             REFERENCE(EX_FDPOS) TYPE  SYFDPOS
*"--------------------------------------------------------------------
  DATA: l_datatype            TYPE dd01v-datatype,
        l_data(100)           TYPE c.

  DATA: l_available_char(200) TYPE c VALUE
'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz/-?:().,''+{} '.

  CLEAR: ex_subrc, ex_fdpos.

  l_data = in_string.
  CALL FUNCTION 'Z_TI_NUMBER_CHECK'
    EXPORTING
      string_in  = l_data
    IMPORTING
      string_out = l_data
      htype      = l_datatype.

  IF l_datatype EQ 'CHAR'.
    IF in_string CO l_available_char.
      ex_subrc = 0.
    ELSE.
      ex_subrc = 4.
    ENDIF.

    ex_fdpos = sy-fdpos.
  ENDIF.

ENDFUNCTION.
