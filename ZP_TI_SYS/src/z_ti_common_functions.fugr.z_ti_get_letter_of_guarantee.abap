FUNCTION z_ti_get_letter_of_guarantee.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(ILGNO) TYPE  ZTIILGNO OPTIONAL
*"     REFERENCE(IBLNO) TYPE  ZTIIBLNO DEFAULT SPACE
*"     REFERENCE(GMODE) TYPE  C
*"  EXPORTING
*"     REFERENCE(ZTITBLK) TYPE  ZTITBLK
*"     REFERENCE(ZTITLG1) TYPE  ZTITLG1
*"  TABLES
*"      ZTITBLP STRUCTURE  ZTISBLIT
*"      ZTITBLC STRUCTURE  VZTITBLC OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------

*> L/G Table
  IF NOT ilgno IS INITIAL.
    SELECT SINGLE *
      FROM ztitlg1
     WHERE ilgno = ilgno.

    IF sy-subrc  NE  0 AND gmode NE 'C'.
      MESSAGE e601 WITH ilgno RAISING not_found.
    ENDIF.
  ENDIF.

  IF NOT iblno IS INITIAL AND gmode EQ 'C'.
    ztitlg1-iblno = iblno.
  ENDIF.

*> B/L Table
  SELECT SINGLE *
    FROM ztitblk
   WHERE iblno = ztitlg1-iblno.

  IF sy-subrc  NE  0.
    MESSAGE e200 WITH ztitlg1-iblno RAISING not_found.
  ENDIF.

* b/l상태 확인.add.
  IF ztitblk-crlse EQ 'B'.
    MESSAGE ID 'ZMTI00' TYPE 'E' NUMBER 321 WITH '송장'.
  ENDIF.

*>B/L Items table
  SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitblp
    FROM ztitblp
   WHERE iblno  EQ ztitlg1-iblno.

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
   WHERE iblno  EQ ztitlg1-iblno.

ENDFUNCTION.
