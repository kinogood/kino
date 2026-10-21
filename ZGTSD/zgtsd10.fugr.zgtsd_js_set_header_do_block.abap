FUNCTION ZGTSD_JS_SET_HEADER_DO_BLOCK.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(E_TYPE) TYPE  BAPI_MTYPE
*"     VALUE(E_MSG) TYPE  BAPI_MSG
*"  TABLES
*"      IT_DATA STRUCTURE  ZGTSDS0022
*"----------------------------------------------------------------------

*-01. CHECK
  IF IT_DATA[] IS INITIAL.
    E_TYPE = GC_E.
    E_MSG  = TEXT-M12.
    EXIT.
  ENDIF.

  LOOP AT IT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>).
    CASE <FS_DATA>-ZFLAG.
      WHEN GC_X.
        PERFORM SET_DO_BLOCK CHANGING <FS_DATA>.
      WHEN OTHERS.
        PERFORM UNSET_DO_BLOCK CHANGING <FS_DATA>.
    ENDCASE.

  ENDLOOP.

  E_TYPE = GC_S.

ENDFUNCTION.
