FUNCTION z_ti_get_bi_bill_of_lading.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IBINO) TYPE  ZTIIBINO OPTIONAL
*"     VALUE(IBSNO) TYPE  ZTIIBSNO OPTIONAL
*"     VALUE(IBLNO) TYPE  ZTIIBLNO DEFAULT SPACE
*"     VALUE(GMODE) TYPE  C OPTIONAL
*"  EXPORTING
*"     VALUE(ZTITBLK) TYPE  ZTITBLK
*"     VALUE(ZTITBSK) TYPE  ZTITBSK
*"     VALUE(ZTITBIK) TYPE  ZTITBIK
*"     VALUE(ZTITIG00) TYPE  ZTITIG00
*"  TABLES
*"      ZTITBLP STRUCTURE  ZTISBLIT OPTIONAL
*"      ZTITBLC STRUCTURE  VZTITBLC OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------
  CLEAR: ztitblk, ztitbsk, ztitbik, ztitig00.

  IF gmode eq 'C'.
    IF NOT iblno IS INITIAL.
*  > B/L Table
      SELECT SINGLE *
        FROM ztitblk
       WHERE iblno = iblno.
      IF sy-subrc  NE  0.
        MESSAGE e200 WITH ztitbsk-iblno RAISING not_found.
      ENDIF.
*  > 회사별 프로세스 정의.
      SELECT SINGLE *
        FROM ztitig00
       WHERE bukrs EQ ztitblk-bukrs.
      IF sy-subrc EQ 0.
        IF ztitig00-bsmtu EQ 'X'.
          SELECT MAX( ibsno )
            INTO ibsno
            FROM ztitbsk
           WHERE iblno EQ iblno.
          IF ibsno IS INITIAL.
            MESSAGE e606 WITH ztitblk-blnum RAISING not_found.
          ENDIF.
        ELSE.
          CLEAR ibsno.
        ENDIF.
      ELSE.
        MESSAGE e035 WITH ztitblk-bukrs.
      ENDIF.
    ENDIF.
  ELSE.
* BI table.
    IF NOT ibino IS INITIAL. " 변경.
      SELECT SINGLE *
        FROM ztitbik
       WHERE ibino = ibino.
      IF sy-subrc NE 0.
        MESSAGE e603 WITH ibino RAISING not_found.
      ENDIF.
      ibsno = ztitbik-ibsno.

      CLEAR: ztitblk.
      IF NOT ztitbik-blasn IS INITIAL AND
         NOT ztitbik-iblno IS INITIAL.
        SELECT SINGLE *
          FROM ztitblk
         WHERE iblno EQ ztitbik-iblno.
      ENDIF.

*  > 회사별 프로세스 정의.
      SELECT SINGLE *
        FROM ztitig00
       WHERE bukrs EQ ztitbik-bukrs.
      IF sy-subrc NE 0.
        MESSAGE e035 WITH ztitbik-bukrs.
      ENDIF.
    ENDIF.
  ENDIF.

*> BS Table
  IF NOT ibsno IS INITIAL.
    SELECT SINGLE *
      FROM ztitbsk
     WHERE ibsno = ibsno.

    IF sy-subrc       NE 0 AND
       ztitig00-bsmtu EQ 'X'.
*      MESSAGE e602 WITH ibsno.
      MESSAGE i602 WITH ibsno.
    ENDIF.
  ENDIF.

*>B/L Items table
  IF NOT ztitblk-iblno IS INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitblp
      FROM ztitblp
     WHERE iblno  EQ ztitblk-iblno.

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
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE ztitblc
      FROM ztitblc
     WHERE iblno  EQ ztitblk-iblno.
  ENDIF.

ENDFUNCTION.
