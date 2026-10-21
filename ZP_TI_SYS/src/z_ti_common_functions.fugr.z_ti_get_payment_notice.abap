FUNCTION z_ti_get_payment_notice.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(XPNTNO) TYPE  ZTIPNTNO
*"  EXPORTING
*"     REFERENCE(ZTITPNK) TYPE  ZTITPNK
*"  TABLES
*"      ZTITPNP STRUCTURE  ZTISPNIT
*"      ZTISPNHS STRUCTURE  ZTISPNHS OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------

*> Notice Header 테이블.
  SELECT SINGLE *
    FROM ztitpnk
   WHERE pntno = xpntno.

  IF sy-subrc  NE  0.
    MESSAGE e801 WITH xpntno RAISING not_found.
  ENDIF.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitpnp
    FROM ztitpnp
   WHERE pntno  EQ xpntno.

  LOOP AT ztitpnp.
    IF NOT ztitpnp-ebeln IS INITIAL.
      SELECT SINGLE rqmng
        INTO ztitpnp-rqmng
        FROM ztivrq00
       WHERE  reqno  EQ  ztitpnp-reqno
         AND  reqit  EQ  ztitpnp-reqit.

      SELECT SINGLE menge werks lgort matnr txz01
                    loekz elikz bprme bpumz bpumn umrez
                    umren netpr peinh uebto uebtk untto
      INTO CORRESPONDING FIELDS OF ztitpnp
        FROM ekpo
       WHERE ebeln  EQ  ztitpnp-ebeln
         AND ebelp  EQ  ztitpnp-ebelp.

      SELECT  SUM( pnmng ) sum( netwr )
        INTO  (ztitpnp-pnmngs, ztitpnp-netwrs)
        FROM  ztitpnp
       WHERE  reqno  EQ  ztitpnp-reqno
         AND  reqit  EQ  ztitpnp-reqit
         AND NOT ( pntno  EQ  ztitpnp-pntno
         AND       pntit  EQ  ztitpnp-pntit ).

      ztitpnp-pnmngl =  ztitpnp-rqmng - ztitpnp-pnmngs.
      IF ztitpnp-pnmngl LE 0.
        ztitpnp-pnmngl = 0.
      ENDIF.

      SELECT  SINGLE ps_psp_pnr
        INTO  ztitpnp-ps_psp_pnr
        FROM  ekkn
       WHERE  ebeln  = ztitpnp-ebeln
         AND  ebelp  = ztitpnp-ebelp
         AND  zekkn  = '01'.

    ENDIF.
    MODIFY ztitpnp.
  ENDLOOP.

*>이력 탭.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE ztispnhs
    FROM ztitpnh
   WHERE pntno  EQ xpntno.


ENDFUNCTION.
