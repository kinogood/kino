FUNCTION z_ti_get_custom_import_req.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(ICCNO) TYPE  ZTIICCNO OPTIONAL
*"     VALUE(ICCSQ) TYPE  ZTIICCSQ OPTIONAL
*"  EXPORTING
*"     VALUE(ZTITCRK) TYPE  ZTITCRK
*"  TABLES
*"      ZTITCRP STRUCTURE  ZTISCRIT OPTIONAL
*"      ZTITCR1 STRUCTURE  VZTITCR1 OPTIONAL
*"      ZTITCR2 STRUCTURE  VZTITCR2 OPTIONAL
*"      ZTITCR3 STRUCTURE  VZTITCR3 OPTIONAL
*"      ZTITCR5 STRUCTURE  VZTITCR5 OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------

*> 수입신고 공통 테이블.
  SELECT SINGLE *
    INTO ztitcrk
    FROM ztitcrk
   WHERE iccno = iccno
     AND iccsq = iccsq.

  IF sy-subrc  NE  0.
    MESSAGE e430 WITH iccno iccsq RAISING not_found.
  ENDIF.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitcrp
    FROM ztitcrp
   WHERE iccno  EQ iccno
     AND iccsq  EQ iccsq.

  LOOP AT ztitcrp.

    IF NOT ztitcrp-ebeln IS INITIAL.
*     p/o정보.
      SELECT SINGLE werks name1 lgort matnr txz01
             loekz elikz bprme bpumz bpumn
             umrez umren netpr peinh uebto uebtk untto
             knttp repos wepos
          INTO (ztitcrp-werks, ztitcrp-name1, ztitcrp-lgort,
                ztitcrp-matnr, ztitcrp-txz01,
                ztitcrp-loekz, ztitcrp-elikz, ztitcrp-bprme,
                ztitcrp-bpumz, ztitcrp-bpumn, ztitcrp-umrez,
                ztitcrp-umren, ztitcrp-netpr, ztitcrp-peinh,
                ztitcrp-uebto, ztitcrp-uebtk, ztitcrp-untto,
                ztitcrp-knttp, ztitcrp-repos, ztitcrp-wepos)
*        INTO  CORRESPONDING FIELDS OF ZTITIVP
        FROM  ztivpo00
       WHERE  ebeln  = ztitcrp-ebeln
         AND  ebelp  = ztitcrp-ebelp.

    ELSEIF NOT ztitcrp-rsnum IS INITIAL.
      SELECT SINGLE werks lgort matnr bdmng
          INTO (ztitcrp-werks, ztitcrp-lgort,
                ztitcrp-matnr, ztitcrp-bdmng)
*        INTO CORRESPONDING FIELDS OF ZTITCRp
        FROM  ztivrs00
       WHERE  rsnum  = ztitcrp-rsnum
         AND  rspos  = ztitcrp-rspos
         AND  rsart  = ztitcrp-rsart.
    ELSE.
      SELECT SINGLE werks lgort matnr txz01 netpr peinh
                    meins refwr
          INTO (ztitcrp-werks, ztitcrp-lgort,
                ztitcrp-matnr, ztitcrp-txz01,
                ztitcrp-netpr, ztitcrp-peinh,
                ztitcrp-meins, ztitcrp-refwr)
*        INTO CORRESPONDING FIELDS OF ZTITCRp
        FROM  ztitblp
       WHERE  iblno  = ztitcrp-iblno
         AND  iblit  = ztitcrp-iblit.
    ENDIF.

*   B/L 정보 수량.
    SELECT  SINGLE blmng refwr
      INTO  (ztitcrp-blmng, ztitcrp-refwr)
      FROM  ztitblp
     WHERE  iblno  = ztitcrp-iblno
       AND  iblit  = ztitcrp-iblit.

*   통관 누적수량.
    SELECT  SUM( ccmng ) INTO ztitcrp-ccmngs
      FROM  ztitcrp
     WHERE  iblno  = ztitcrp-iblno
       AND  iblit  = ztitcrp-iblit
       AND NOT ( iccno = ztitcrp-iccno
       AND       iccit = ztitcrp-iccit ).

*   통관 가능수량.
    ztitcrp-menge  = ztitcrp-blmng .
    ztitcrp-ccmngl = ztitcrp-menge - ztitcrp-ccmngs.
    IF ztitcrp-ccmngl LE 0.
      ztitcrp-ccmngl = 0.
    ENDIF.

    MODIFY ztitcrp INDEX sy-tabix.
  ENDLOOP.

*> edi 관련 Table.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitcr1
    FROM ztitcr1
   WHERE iccno  EQ iccno
     AND iccsq  EQ iccsq.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitcr2
    FROM ztitcr2
   WHERE iccno  EQ iccno
     AND iccsq  EQ iccsq.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitcr3
    FROM ztitcr3
   WHERE iccno  EQ iccno
     AND iccsq  EQ iccsq.

*-> 기능개선 XXXXX
  SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitcr5
    FROM ztitcr5
   WHERE iccno  EQ iccno
     AND iccsq  EQ iccsq.
*<- 기능개선 XXXXX

ENDFUNCTION.
