FUNCTION zgtsd_if_i_picking_info.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(SYSTEM_ID) TYPE  CHAR04 OPTIONAL
*"     VALUE(P_STAMP) TYPE  TZNTSTMPL OPTIONAL
*"     VALUE(P_MODE) TYPE  MODE OPTIONAL
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE2
*"  TABLES
*"      IT_ITAB_H STRUCTURE  ZGTSDSIF0020 OPTIONAL
*"      IT_ITAB_I STRUCTURE  ZGTSDSIF0021 OPTIONAL
*"----------------------------------------------------------------------

*___ STATUS
  CLEAR : gv_error, gv_message.
  GET TIME STAMP FIELD gv_stamp.
  gv_erdat = sy-datum.
  gv_erzet = sy-uzeit.
  IF p_mode IS INITIAL.
    gv_mode = 'N'.
  ELSE.
    gv_mode = p_mode.
  ENDIF.

*___ LOG SAVE
  PERFORM save_log TABLES it_itab_h it_itab_i USING 'S' system_id p_stamp.

*___ DATA CHECK.
  PERFORM data_check TABLES it_itab_h it_itab_i.

*___ DATA PROCESSING.
  PERFORM data_processing TABLES  it_itab_h it_itab_i.

*___ LOG_SAVE - RESULT
  PERFORM save_log TABLES it_itab_h it_itab_i USING 'E' system_id p_stamp.

*___ RESULT RETURN
  zo_result = gv_result.
  zo_message = gv_message.


ENDFUNCTION.
