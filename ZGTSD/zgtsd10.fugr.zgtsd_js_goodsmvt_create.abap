FUNCTION ZGTSD_JS_GOODSMVT_CREATE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(E_TYPE) TYPE  BAPI_MTYPE
*"     VALUE(E_MSG) TYPE  BAPI_MSG
*"  TABLES
*"      IT_DATA STRUCTURE  ZGTSDS0029
*"----------------------------------------------------------------------

*-01. CHECK
  IF IT_DATA[] IS INITIAL.
    E_TYPE = GC_E.
    E_MSG  = TEXT-M27.
    EXIT.
  ENDIF.

  PERFORM CHECK_JS_GOODSMVT_CREATE TABLES IT_DATA.

*-DO 별도 창고이동
  PERFORM RUN_JS_GOODSMVT_CREATE TABLES IT_DATA.

  E_TYPE = GC_S.

ENDFUNCTION.
