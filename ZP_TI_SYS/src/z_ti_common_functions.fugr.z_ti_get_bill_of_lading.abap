FUNCTION z_ti_get_bill_of_lading.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IBLNO) TYPE  ZTIIBLNO OPTIONAL
*"  EXPORTING
*"     VALUE(ZTITBLK) TYPE  ZTITBLK
*"     VALUE(BLAMT) TYPE  ZTIREFWRT
*"     VALUE(XSUBRC) LIKE  SY-SUBRC
*"  TABLES
*"      ZTITBLP STRUCTURE  ZTISBLIT OPTIONAL
*"      ZTITBLC STRUCTURE  VZTITBLC OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------

************************************************************************
*> XSUBRC - 4  : 데이터 없음.
*>          0  : 데이터 존재.
************************************************************************
  DATA: l_netpr   LIKE  ekpo-netpr.

  xsubrc = 4.

*> B/L Table
  SELECT SINGLE *
    FROM ztitblk
   WHERE iblno = iblno.

  IF sy-subrc  NE  0.
    MESSAGE e200 WITH iblno RAISING not_found.
  ENDIF.

*> B/L 금액.
  WRITE: ztitblk-ivamt TO blamt CURRENCY ztitblk-waers.

*>B/L Items table
  SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitblp
    FROM ztitblp
   WHERE iblno  EQ iblno.

  LOOP AT ztitblp.
    IF NOT ztitblp-ebeln IS INITIAL.
* 구매오더 정보 Read.
      SELECT SINGLE menge werks lgort matnr txz01
                    loekz elikz bprme bpumz bpumn umrez
                    umren uebto uebtk untto
                    repos wepos
      INTO CORRESPONDING FIELDS OF ztitblp
        FROM ekpo
       WHERE ebeln  EQ  ztitblp-ebeln
         AND ebelp  EQ  ztitblp-ebelp.
*> 수입의뢰 정보 Read.
      IF NOT ztitblp-reqno IS INITIAL.
        SELECT SINGLE rqmng
          INTO ztitblp-rqmng
          FROM ztivrq00
         WHERE reqno   EQ  ztitblp-reqno
           AND reqit   EQ  ztitblp-reqit.

        SELECT  SUM( blmng )
          INTO  ztitblp-blmngs
          FROM  ztivbl00
         WHERE  reqno       EQ  ztitblp-reqno
           AND  reqit       EQ  ztitblp-reqit
           AND NOT ( iblno  EQ  ztitblp-iblno
           AND       iblit  EQ  ztitblp-iblit ).
*> 초과납품허용치.
        IF NOT ztitblp-uebto IS INITIAL.
          ztitblp-blmngm = ( ztitblp-menge * ztitblp-uebto ) / 100.
        ELSE.
          ztitblp-blmngm = 0.
        ENDIF.

        IF NOT ztitblp-uebtk IS INITIAL.

        ENDIF.
        ztitblp-blmngl =  ztitblp-rqmng - ztitblp-blmngs.
      ELSE.
        SELECT  SUM( blmng )
          INTO  ztitblp-blmngs
          FROM  ztivbl00
         WHERE  ebeln       EQ  ztitblp-ebeln
           AND  ebelp       EQ  ztitblp-ebelp
           AND NOT ( iblno  EQ  ztitblp-iblno
           AND       iblit  EQ  ztitblp-iblit ).
        ztitblp-blmngl =  ztitblp-menge - ztitblp-blmngs.
      ENDIF.

      IF ztitblp-blmngl LE 0.
        ztitblp-blmngl = 0.
      ENDIF.
    ENDIF.
    IF NOT ztitblp-rsnum IS INITIAL.
* 구매오더 정보 Read.
      SELECT SINGLE bdmng werks lgort matnr
      INTO CORRESPONDING FIELDS OF ztitblp
        FROM resb
       WHERE rsnum  EQ  ztitblp-rsnum
         AND rspos  EQ  ztitblp-rspos
         AND rsart  EQ  ztitblp-rsart.

      SELECT  SUM( blmng )
        INTO  ztitblp-blmngs
        FROM  ztivbl00
       WHERE  rsnum       EQ  ztitblp-rsnum
         AND  rspos       EQ  ztitblp-rspos
         AND  rsart       EQ  ztitblp-rsart
         AND NOT ( iblno  EQ  ztitblp-iblno
         AND       iblit  EQ  ztitblp-iblit ).

      ztitblp-menge  =  ztitblp-bdmng.
      ztitblp-blmngl =  ztitblp-menge - ztitblp-blmngs.
    ENDIF.
*>
    IF ztitblp-bpumz IS INITIAL.
      ztitblp-bpumz = ztitblp-bpumn =
      ztitblp-umrez = ztitblp-umren = 1.
    ENDIF.
    IF ztitblp-bprme IS INITIAL.
      ztitblp-bprme = ztitblp-meins.
    ENDIF.

    l_netpr = ( ztitblp-netpr / ztitblp-peinh ) *
              ( ztitblp-bpumz / ztitblp-bpumn ).

    WRITE: ztitblp-refwr TO ztitblp-refwrt CURRENCY ztitblk-waers.
    WRITE: l_netpr        TO ztitblp-netprt CURRENCY ztitblk-waers.

    MODIFY ztitblp.
  ENDLOOP.

*>B/L Container table
  SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitblc
    FROM ztitblc
   WHERE iblno  EQ iblno.

  xsubrc =  0.

ENDFUNCTION.
