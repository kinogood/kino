FUNCTION z_ti_get_bs_bill_of_lading.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(IBSNO) TYPE  ZTIIBSNO OPTIONAL
*"     REFERENCE(IBLNO) TYPE  ZTIIBLNO DEFAULT SPACE
*"     REFERENCE(GMODE) TYPE  C
*"  EXPORTING
*"     REFERENCE(ZTITBLK) TYPE  ZTITBLK
*"     REFERENCE(ZTITBSK) TYPE  ZTITBSK
*"  TABLES
*"      ZTITBLP STRUCTURE  ZTISBLIT
*"      ZTITBLC STRUCTURE  VZTITBLC OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------

*> BS Table
  IF NOT ibsno IS INITIAL.
    SELECT SINGLE *
      FROM ztitbsk
     WHERE ibsno = ibsno.

    IF sy-subrc  NE  0 AND gmode NE 'C'.
      MESSAGE e601 WITH ibsno RAISING not_found.
    ENDIF.
  ENDIF.

  IF NOT iblno IS INITIAL AND gmode EQ 'C'.
    ztitbsk-iblno = iblno.
  ENDIF.

*> B/L Table
  CHECK NOT ztitbsk-iblno IS INITIAL.

  SELECT SINGLE *
    FROM ztitblk
   WHERE iblno = ztitbsk-iblno.

  IF sy-subrc  NE  0.
    MESSAGE e200 WITH ztitbsk-iblno RAISING not_found.
  ENDIF.


*>B/L Items table
  SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitblp
    FROM ztitblp
   WHERE iblno  EQ ztitbsk-iblno.

  LOOP AT ztitblp.
    IF NOT ztitblp-ebeln IS INITIAL.
* 구매오더 정보 Read.
      SELECT SINGLE menge werks lgort matnr txz01
                    loekz elikz bprme bpumz bpumn umrez
                    umren netpr peinh uebto uebtk untto
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

        SELECT  SUM( blmng ) INTO ztitblp-blmngs FROM ztivbl00
         WHERE  reqno       EQ  ztitblp-reqno
           AND  reqit       EQ  ztitblp-reqit
           AND NOT ( iblno  EQ  ztitblp-iblno
           AND       iblit  EQ  ztitblp-iblit ).
**> 초과납품허용치.
*        if not ZTITBLP-UEBTO is initial.
*           ZTITBLP-rqmng = ZTITBLP-rqmng +
*                          ( ZTITBLP-rqmng * ZTITBLP-UEBTO ) / 100.
*        endif.
*        if not ZTITBLP-UEBTK is initial.
*
*        endif.
        ztitblp-blmngl =  ztitblp-rqmng - ztitblp-blmngs.
      ENDIF.

      IF ztitblp-blmngl LE 0.
        ztitblp-blmngl = 0.
      ENDIF.
    ENDIF.
    IF NOT ztitblp-rsnum IS INITIAL.
*RSPOS
*RSART
    ENDIF.
    MODIFY ztitblp.
  ENDLOOP.

*>B/L Container table
  SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitblc
    FROM ztitblc
   WHERE iblno  EQ ztitbsk-iblno.

ENDFUNCTION.
