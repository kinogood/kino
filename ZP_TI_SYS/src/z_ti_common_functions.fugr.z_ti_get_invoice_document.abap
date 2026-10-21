FUNCTION z_ti_get_invoice_document.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(IVONO) TYPE  ZTIIVONO
*"  EXPORTING
*"     REFERENCE(ZTITIVK) TYPE  ZTITIVK
*"  TABLES
*"      ZTITIVP STRUCTURE  ZTISIVIT
*"      ZTITIVV STRUCTURE  ZTISIVVS OPTIONAL
*"      ZTITIVH STRUCTURE  ZTISIVHS OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------

  SELECT SINGLE *
    FROM ztitivk
   WHERE ivono EQ ivono.

  IF sy-subrc NE 0.
    MESSAGE e300 WITH ivono RAISING not_found.
  ENDIF.

  SELECT * FROM ztitivp
    INTO CORRESPONDING FIELDS OF TABLE ztitivp
   WHERE ivono EQ ivono.

  LOOP AT ztitivp.

    IF NOT ztitivp-ebeln IS INITIAL.
*     p/o정보.
      SELECT SINGLE werks name1 lgort matnr txz01
             loekz elikz bprme bpumz bpumn
             umrez umren netpr peinh uebto uebtk untto
          INTO (ztitivp-werks, ztitivp-name1, ztitivp-lgort,
                ztitivp-matnr, ztitivp-txz01,
                ztitivp-loekz, ztitivp-elikz, ztitivp-bprme,
                ztitivp-bpumz, ztitivp-bpumn, ztitivp-umrez,
                ztitivp-umren, ztitivp-netpr, ztitivp-peinh,
                ztitivp-uebto, ztitivp-uebtk, ztitivp-untto)
*        INTO  CORRESPONDING FIELDS OF ZTITIVP
        FROM  ztivpo00
       WHERE  ebeln  = ztitivp-ebeln
         AND  ebelp  = ztitivp-ebelp.

      IF ztitivp-iblno IS INITIAL.
*> 수입의뢰 정보 수량.
        SELECT SINGLE rqmng
          INTO ztitivp-menge
          FROM ztivrq00
         WHERE reqno EQ ztitivp-reqno
           AND reqit EQ ztitivp-reqit.

*> I/V 누적수량.
        SELECT  SUM( remng )
          INTO ztitivp-ivmngs
          FROM ztiviv00
         WHERE  reqno  EQ ztitivp-reqno
           AND  reqit  EQ ztitivp-reqit
           AND  prpyn  NE 'I'                ">Invoice 만 Select.
           AND  NOT ( ivono  = ztitivp-ivono
           AND        rblgp  = ztitivp-rblgp ).

      ELSE.
*> B/L 정보 수량.
        SELECT  SINGLE blmng
          INTO  ztitivp-menge
          FROM  ztitblp
         WHERE  iblno  = ztitivp-iblno
           AND  iblit  = ztitivp-iblit.

*> I/V 누적수량.
        SELECT  SUM( remng ) INTO ztitivp-ivmngs
          FROM ztiviv00
         WHERE  iblno  = ztitivp-iblno
           AND  iblit  = ztitivp-iblit
           AND  prpyn  = 'I'                ">Invoice 만 Select.
           AND NOT ( ivono  = ztitivp-ivono
           AND       rblgp  = ztitivp-rblgp ).

      ENDIF.
*> i/v 가능수량.
      ztitivp-ivmngl = ztitivp-menge - ztitivp-ivmngs.
      IF ztitivp-ivmngl LT 0.
        ztitivp-ivmngl = 0.
      ENDIF.

    ENDIF.
    MODIFY ztitivp INDEX sy-tabix.
  ENDLOOP.

*> 분할금액.
  SELECT * FROM ztitivv
    INTO CORRESPONDING FIELDS OF TABLE ztitivv
   WHERE ivono EQ ivono.

*> 전기이력.
  SELECT * FROM ztitivh
    INTO CORRESPONDING FIELDS OF TABLE ztitivh
   WHERE ivono EQ ivono.

ENDFUNCTION.
