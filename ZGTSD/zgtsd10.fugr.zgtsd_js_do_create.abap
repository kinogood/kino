FUNCTION ZGTSD_JS_DO_CREATE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_LFART) TYPE  LFART OPTIONAL
*"     VALUE(I_WADAT) TYPE  WADAT OPTIONAL
*"  EXPORTING
*"     VALUE(E_TYPE) TYPE  BAPI_MTYPE
*"     VALUE(E_MSG) TYPE  BAPI_MSG
*"  TABLES
*"      IT_DATA STRUCTURE  ZGTSDS0031
*"----------------------------------------------------------------------

*-01. CHECK
  IF NOT ( I_LFART IS NOT INITIAL AND
           I_WADAT IS NOT INITIAL     ).
    E_TYPE = GC_E.
    E_MSG  = TEXT-M31.
    EXIT.
  ENDIF.
  IF I_LFART NE GC_LFART_ZLF AND
     I_LFART NE GC_LFART_ZLF3.
    E_TYPE = GC_E.
    E_MSG  = TEXT-M33.
    EXIT.
  ENDIF.

  "CHECK IT_DATA
  PERFORM CHECK_JS_DO_CREATE TABLES IT_DATA
                              USING I_LFART.
  IF LINE_EXISTS( IT_DATA[ MTYPE = GC_E ] ).
    E_TYPE = GC_E.
    E_MSG  = VALUE #( IT_DATA[ MTYPE = GC_E ]-MSG )."TEXT-M38.
    E_MSG  = |{ TEXT-M38 }:{ E_MSG }|.
    EXIT.
  ENDIF.
  IF LINE_EXISTS( IT_DATA[ MTYPE = GC_S ] ).
    E_TYPE = GC_E.
    E_MSG  = TEXT-M40.
    EXIT.
  ENDIF.

*-02. DO 생성
  PERFORM RUN_JS_DO_CREATE TABLES IT_DATA
                            USING I_LFART I_WADAT.

  E_TYPE = GC_S.

ENDFUNCTION.
