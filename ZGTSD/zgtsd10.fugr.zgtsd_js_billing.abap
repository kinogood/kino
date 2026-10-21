FUNCTION ZGTSD_JS_BILLING.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(E_TYPE) TYPE  BAPI_MTYPE
*"     VALUE(E_MSG) TYPE  BAPI_MSG
*"  TABLES
*"      IT_DATA STRUCTURE  ZGTSDS0033
*"----------------------------------------------------------------------

*-01. CHECK
  IF IT_DATA[] IS INITIAL.
    E_TYPE = GC_E.
    E_MSG  = TEXT-M44.
    EXIT.
  ENDIF.

  "CHECK IT_DATA
  PERFORM CHECK_JS_BILLING TABLES IT_DATA.

*-02. 청구문서 생성
  PERFORM RUN_JS_BILLING TABLES IT_DATA.

  E_TYPE = GC_S.

ENDFUNCTION.
