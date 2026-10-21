FUNCTION z_ti_get_vatbil_document.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(I_VATNO) TYPE  ZTIVATNO
*"  EXPORTING
*"     REFERENCE(ZTITVAK) TYPE  ZTITVAK
*"  TABLES
*"      ZTITVAP STRUCTURE  ZTISVAIT
*"      ZTITVAH STRUCTURE  ZTISVAHS OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------

  SELECT SINGLE *
    FROM ztitvak
   WHERE vatno EQ i_vatno.

  IF sy-subrc NE 0.
    MESSAGE e700 WITH i_vatno RAISING not_found.
  ENDIF.

  SELECT * FROM ztitvap
    INTO CORRESPONDING FIELDS OF TABLE ztitvap
   WHERE vatno EQ i_vatno.

  LOOP AT ztitvap.
    g_tabix = sy-tabix.

    IF NOT ztitvap-ebeln IS INITIAL.
*     p/o정보.
      SELECT SINGLE werks name1 lgort matnr txz01
             loekz elikz bprme bpumz bpumn
             umrez umren netpr peinh uebto uebtk untto
             menge
          INTO (ztitvap-werks, ztitvap-name1, ztitvap-lgort,
                ztitvap-matnr, ztitvap-txz01,
                ztitvap-loekz, ztitvap-elikz, ztitvap-bprme,
                ztitvap-bpumz, ztitvap-bpumn, ztitvap-umrez,
                ztitvap-umren, ztitvap-netpr, ztitvap-peinh,
                ztitvap-uebto, ztitvap-uebtk, ztitvap-untto,
                ztitvap-menge)
        FROM  ztivpo00
       WHERE  ebeln  = ztitvap-ebeln
         AND  ebelp  = ztitvap-ebelp.
    ENDIF.

    IF NOT ztitvap-reqno IS INITIAL.
      SELECT single rqmng
        INTO ztitvap-rqmng
        FROM ztivrq00
       WHERE reqno EQ ztitvap-reqno
         AND reqit EQ ztitvap-reqit.
      ENDIF.

      MODIFY ztitvap INDEX g_tabix.
    ENDLOOP.

**> 분할금액.
*  SELECT * FROM ztitivv
*    INTO CORRESPONDING FIELDS OF TABLE ztitivv
*   WHERE ivono EQ ivono.

*> 전기이력.
    SELECT * FROM ztitvah
      INTO CORRESPONDING FIELDS OF TABLE ztitvah
     WHERE vatno EQ i_vatno.

  ENDFUNCTION.
