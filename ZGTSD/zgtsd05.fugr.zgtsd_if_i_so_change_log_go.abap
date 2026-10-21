FUNCTION zgtsd_if_i_so_change_log_go.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_D365_LOGIN) TYPE  ZSDS_LOG_0000 OPTIONAL
*"     VALUE(I_VBELN) TYPE  VBELN OPTIONAL
*"     VALUE(I_POSNR) TYPE  POSNR OPTIONAL
*"  EXPORTING
*"     VALUE(ES_RETURN) TYPE  ZSDS_LOG_0001
*"  TABLES
*"      ET_RESULT STRUCTURE  ZGTSDSIF2200 OPTIONAL
*"      ET_RESULT_CHAR STRUCTURE  ZGTSDSIF2210 OPTIONAL
*"----------------------------------------------------------------------

  INCLUDE zsdc0000.

  CLEAR: es_return.
  _clear: et_result, et_result_char, gt_mst.

** 1) Data Validation
  PERFORM data_validation     USING    i_vbeln
                                       i_posnr
                                       is_d365_login
                              CHANGING es_return.

** 2) Get Sales Order Change Log
  PERFORM get_so_change_log   TABLES   et_result
                                       et_result_char
                              USING    i_vbeln
                                       i_posnr
                                       is_d365_login
                              CHANGING es_return.

** 3) Set RFC Log
  PERFORM save_log(zcmr0004)  TABLES    gt_ilog
                              USING     gs_hlog
                                        es_return.

ENDFUNCTION.
