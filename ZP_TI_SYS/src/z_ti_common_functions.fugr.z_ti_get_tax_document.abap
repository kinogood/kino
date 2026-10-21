FUNCTION z_ti_get_tax_document.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(IM_TAXNO) TYPE  ZTITAXNO
*"  EXPORTING
*"     REFERENCE(EX_ZTITTXK) TYPE  ZTITTXK
*"     REFERENCE(EX_SUBRC) LIKE  SY-SUBRC
*"  TABLES
*"      ET_ZTITTXP STRUCTURE  ZTISTXIT OPTIONAL
*"      ET_ZTITTXR STRUCTURE  ZTISTXR OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------
  REFRESH: ET_ZTITTXP, ET_ZTITTXR.
  ex_subrc = 4.

*> 인수증 Table
  SELECT SINGLE *
    INTO ex_ztittxk
    FROM ztittxk
   WHERE taxno = im_taxno.

  IF sy-subrc  NE  0.
    MESSAGE e742 WITH im_taxno RAISING not_found.
  ELSE.
    ex_subrc = 0.
  ENDIF.

*> 기납증 Items table
  SELECT * INTO CORRESPONDING FIELDS OF TABLE et_ztittxp
    FROM ztittxp
   WHERE taxno  EQ im_taxno.

  LOOP AT et_ztittxp.

* 구매오더 아이템 Read.
    SELECT SINGLE menge werks lgort matnr txz01 AS txttx menge
                  loekz elikz bprme bpumz bpumn umrez
                  umren netpr peinh uebto uebtk untto
                  repos wepos
    INTO CORRESPONDING FIELDS OF et_ztittxp
      FROM ekpo
     WHERE ebeln  EQ  et_ztittxp-ebeln
       AND ebelp  EQ  et_ztittxp-ebelp.

*> 수입의뢰 정보 Read.
    IF NOT et_ztittxp-reqno IS INITIAL.
      SELECT SINGLE rqmng netwr
        INTO (et_ztittxp-rqmng, et_ztittxp-rqamt)
        FROM ztivrq00
       WHERE reqno   EQ  et_ztittxp-reqno
         AND reqit   EQ  et_ztittxp-reqit.
    ENDIF.

    SELECT SUM( TXMNG )
      INTO et_ztittxp-TXMNGS
      FROM ZTITTXP
     WHERE REQNO  EQ  et_ztittxp-REQNO
       AND REQIT  EQ  et_ztittxp-REQIT
       AND TAXNO  NE  eX_ZTITTXK-TAXNO.
    et_ztittxp-TXMNGL = et_ztittxp-RQMNG - et_ztittxp-TXMNGS.

    MODIFY et_ztittxp.
  ENDLOOP.

*> 기납증  계산근거(을) table
  SELECT * INTO CORRESPONDING FIELDS OF TABLE et_ztittxr
    FROM ztittxr
   WHERE taxno  EQ im_taxno.

ENDFUNCTION.
