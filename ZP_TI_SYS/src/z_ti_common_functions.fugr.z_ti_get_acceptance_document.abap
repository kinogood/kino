FUNCTION z_ti_get_acceptance_document.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(IM_ACDNO) TYPE  ZTIACDNO
*"  EXPORTING
*"     REFERENCE(EX_ZTITACK) TYPE  ZTITACK
*"     REFERENCE(EX_SUBRC) LIKE  SY-SUBRC
*"  TABLES
*"      ET_ZTITACF STRUCTURE  ZTISACF OPTIONAL
*"      ET_ZTITAC1 STRUCTURE  ZTISAC1 OPTIONAL
*"      ET_ZTITACP STRUCTURE  ZTISACIT OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------

  ex_subrc = 4.

*> 인수증 Table
  SELECT SINGLE *
    INTO ex_ztitack
    FROM ztitack
   WHERE acdno = im_acdno.

  IF sy-subrc  NE  0.
    MESSAGE e725 WITH im_acdno RAISING not_found.
  ENDIF.

*> 인수증 Items table
  SELECT * INTO CORRESPONDING FIELDS OF TABLE et_ztitacp
    FROM ztitacp
   WHERE acdno  EQ im_acdno.

*> 인수증 Segment group 1 Items table
  SELECT * INTO CORRESPONDING FIELDS OF TABLE et_ztitac1
    FROM ztitac1
   WHERE acdno  EQ im_acdno.

*> 회계문서 table
  SELECT * INTO CORRESPONDING FIELDS OF TABLE et_ztitacf
    FROM ztitacf
   WHERE acdno  EQ im_acdno.

  IF sy-subrc EQ 0.
    ex_subrc = 0.
  ENDIF.


ENDFUNCTION.
