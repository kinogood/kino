FUNCTION z_ti_cost_posted_by_documents.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IM_BUKRS) TYPE  BUKRS
*"     VALUE(IM_REFNO) TYPE  ZTIREFNO
*"     VALUE(IM_AMDSQ) TYPE  ZTIAMDSQ OPTIONAL
*"     VALUE(IM_EXPGR) TYPE  ZTIEXPGR
*"  EXPORTING
*"     VALUE(EX_SUBRC) LIKE  SY-SUBRC
*"  TABLES
*"      ET_BELNR STRUCTURE  ACCBELNR OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------


  REFRESH: et_belnr.
  CLEAR: et_belnr, ex_subrc.


  SELECT  *
    INTO  CORRESPONDING FIELDS OF TABLE it_ztitig06
    FROM  ztitig06 AS h INNER JOIN t001 AS c
      ON  h~bukrs EQ c~bukrs
   WHERE  h~bukrs EQ im_bukrs
     AND  h~expgr EQ im_expgr.

  IF sy-subrc NE 0.
    MESSAGE e874 RAISING not_found.
  ENDIF.




ENDFUNCTION.
