FUNCTION ZGTSD_JS_GI.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(E_TYPE) TYPE  BAPI_MTYPE
*"     VALUE(E_MSG) TYPE  BAPI_MSG
*"  TABLES
*"      IT_DATA STRUCTURE  ZGTSDS0032
*"----------------------------------------------------------------------

*-01. CHECK
  IF IT_DATA[] IS INITIAL.
    E_TYPE = GC_E.
    E_MSG  = TEXT-M41.
    EXIT.
  ENDIF.

  "CHECK IT_DATA
  PERFORM CHECK_JS_GI TABLES IT_DATA.

*-02. 출고처리
  PERFORM RUN_JS_GI TABLES IT_DATA.

  E_TYPE = GC_S.

ENDFUNCTION.
