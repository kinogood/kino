FUNCTION ZGTSD_JS_CANCEL_GOOD_ISSUE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(E_TYPE) TYPE  BAPI_MTYPE
*"     VALUE(E_MSG) TYPE  BAPI_MSG
*"  TABLES
*"      IT_DATA STRUCTURE  ZGTSDS0021
*"----------------------------------------------------------------------

*-01. CHECK
  IF IT_DATA[] IS INITIAL.
    E_TYPE = GC_E.
    E_MSG  = TEXT-M06.
    EXIT.
  ENDIF.

  LOOP AT IT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>).
    PERFORM CANCEL_DO CHANGING <FS_DATA>.
  ENDLOOP.

  E_TYPE = GC_S.


ENDFUNCTION.
