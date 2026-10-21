FUNCTION z_ti_get_bo_bill_of_lading.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(IBINO) TYPE  ZTIIBINO OPTIONAL
*"     REFERENCE(IBONO) TYPE  ZTIIBONO OPTIONAL
*"     REFERENCE(IBLNO) TYPE  ZTIIBLNO DEFAULT SPACE
*"     REFERENCE(GMODE) TYPE  C
*"  EXPORTING
*"     REFERENCE(ZTITBLK) TYPE  ZTITBLK
*"     REFERENCE(ZTITBSK) TYPE  ZTITBSK
*"     REFERENCE(ZTITBIK) TYPE  ZTITBIK
*"     REFERENCE(ZTITBOK) TYPE  ZTITBOK
*"  TABLES
*"      ZTITBLP STRUCTURE  ZTISBLIT
*"      ZTITBLC STRUCTURE  VZTITBLC OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------

* BO table.
  IF NOT ibono IS INITIAL. " 변경.
    SELECT SINGLE *
      FROM ztitbok
     WHERE ibono = ibono.

    IF sy-subrc  NE  0 AND gmode NE 'C'.
      MESSAGE e601 WITH ibono RAISING not_found.
    ENDIF.
  ELSE.
    ztitbok-ibino = ibino.
  ENDIF.

*> BI Table
  SELECT SINGLE *
    FROM ztitbik
   WHERE ibino = ztitbok-ibino.
  IF sy-subrc NE 0.
    IF gmode EQ 'C'.
      MESSAGE e603 WITH ztitbok-ibino.

    ENDIF.
  ENDIF.
  IF gmode EQ 'C'.
    IF ztitbik-iblno IS INITIAL.
      MESSAGE e453 WITH ztitbik-ibino.
    ENDIF.
  ENDIF.

*> BS Table
  IF NOT ztitbik-ibsno IS INITIAL.
    SELECT SINGLE *
      FROM ztitbsk
     WHERE ibsno = ztitbik-ibsno.
  ENDIF.

*> B/L Table
  IF NOT ztitbik-iblno IS INITIAL.
    SELECT SINGLE *
      FROM ztitblk
     WHERE iblno = ztitbik-iblno.
    IF sy-subrc  NE  0.
      MESSAGE e200 WITH ztitbsk-iblno RAISING not_found.
    ENDIF.
*>B/L Items table
    SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitblp
      FROM ztitblp
     WHERE iblno  EQ ztitbik-iblno.

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

      ENDIF.
      MODIFY ztitblp.
    ENDLOOP.

*>B/L Container table
    SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitblc
      FROM ztitblc
     WHERE iblno  EQ ztitbik-iblno.
  ENDIF.


ENDFUNCTION.
