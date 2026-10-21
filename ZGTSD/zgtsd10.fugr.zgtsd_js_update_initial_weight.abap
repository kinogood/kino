FUNCTION ZGTSD_JS_UPDATE_INITIAL_WEIGHT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(E_TYPE) TYPE  BAPI_MTYPE
*"     VALUE(E_MSG) TYPE  BAPI_MSG
*"  TABLES
*"      IT_DATA STRUCTURE  ZGTSDS0027
*"----------------------------------------------------------------------

*-01. CHECK
  IF IT_DATA[] IS INITIAL.
    E_TYPE = GC_E.
    E_MSG  = TEXT-M17.
    EXIT.
  ENDIF.

  LOOP AT IT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>).
    PERFORM UPDATE_WEIGHT_DOITEM CHANGING <FS_DATA>.
  ENDLOOP.

  E_TYPE = GC_S.


ENDFUNCTION.
