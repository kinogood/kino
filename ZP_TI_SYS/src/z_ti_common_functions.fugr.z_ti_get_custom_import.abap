FUNCTION z_ti_get_custom_import.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(ICCNO) TYPE  ZTIICCNO OPTIONAL
*"     VALUE(ICCSQ) TYPE  ZTIICCSQ OPTIONAL
*"  EXPORTING
*"     VALUE(ZTITCCK) TYPE  ZTITCCK
*"  TABLES
*"      ZTITCCP STRUCTURE  ZTISCCIT OPTIONAL
*"      ZTITCC1 STRUCTURE  VZTITCC1 OPTIONAL
*"      ZTITCC2 STRUCTURE  VZTITCC2 OPTIONAL
*"      ZTITCC3 STRUCTURE  VZTITCC3 OPTIONAL
*"      ZTITCC4 STRUCTURE  VZTITCC4 OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------

*> 수입신고 공통 테이블.
  SELECT SINGLE *
    FROM ztitcck
   WHERE iccno = iccno
     AND iccsq = iccsq.

  IF sy-subrc  NE  0.
    MESSAGE e400 WITH iccno iccsq RAISING not_found.
  ENDIF.


  SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitccp
    FROM ztitccp
   WHERE iccno  EQ iccno
     AND iccsq  EQ iccsq.

  LOOP AT ztitccp.

    IF NOT ztitccp-ebeln IS INITIAL.
*     p/o정보.
      SELECT SINGLE werks name1 lgort matnr txz01
             loekz elikz bprme bpumz bpumn
             umrez umren netpr peinh uebto uebtk untto
             knttp repos wepos
          INTO (ztitccp-werks, ztitccp-name1, ztitccp-lgort,
                ztitccp-matnr, ztitccp-txz01,
                ztitccp-loekz, ztitccp-elikz, ztitccp-bprme,
                ztitccp-bpumz, ztitccp-bpumn, ztitccp-umrez,
                ztitccp-umren, ztitccp-netpr, ztitccp-peinh,
                ztitccp-uebto, ztitccp-uebtk, ztitccp-untto,
                ztitccp-knttp, ztitccp-repos, ztitccp-wepos)
*        INTO  CORRESPONDING FIELDS OF ZTITIVP
        FROM  ztivpo00
       WHERE  ebeln  = ztitccp-ebeln
         AND  ebelp  = ztitccp-ebelp.

    ELSEIF NOT ztitccp-rsnum IS INITIAL.
      SELECT SINGLE werks lgort matnr bdmng
          INTO (ztitccp-werks, ztitccp-lgort,
                ztitccp-matnr, ztitccp-bdmng)
*        INTO CORRESPONDING FIELDS OF ZTITCcp
        FROM  ztivrs00
       WHERE  rsnum  = ztitccp-rsnum
         AND  rspos  = ztitccp-rspos
         AND  rsart  = ztitccp-rsart.
    ELSE.
      SELECT SINGLE werks lgort matnr txz01 netpr peinh
                    meins refwr
          INTO (ztitccp-werks, ztitccp-lgort,
                ztitccp-matnr, ztitccp-txz01,
                ztitccp-netpr, ztitccp-peinh,
                ztitccp-meins, ztitccp-refwr)
*        INTO CORRESPONDING FIELDS OF ZTITCcp
        FROM  ztitblp
       WHERE  iblno  = ztitccp-iblno
         AND  iblit  = ztitccp-iblit.
    ENDIF.

*   B/L 정보 수량.
    SELECT  SINGLE blmng refwr
      INTO  (ztitccp-blmng, ztitccp-refwr)
      FROM  ztitblp
     WHERE  iblno  = ztitccp-iblno
       AND  iblit  = ztitccp-iblit.

*   통관 누적수량.
    SELECT  SUM( ccmng ) INTO ztitccp-ccmngs
      FROM  ztitccp
     WHERE  iblno  = ztitccp-iblno
       AND  iblit  = ztitccp-iblit
       AND NOT ( iccno = ztitccp-iccno
       AND       iccit = ztitccp-iccit ).

*   통관 가능수량.
    ztitccp-menge  = ztitccp-blmng .
    ztitccp-ccmngl = ztitccp-menge - ztitccp-ccmngs.
    IF ztitccp-ccmngl LE 0.
      ztitccp-ccmngl = 0.
    ENDIF.

    MODIFY ztitccp INDEX sy-tabix.
  ENDLOOP.

*> edi 관련 Table.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitcc1
    FROM ztitcc1
   WHERE iccno  EQ iccno
     AND iccsq  EQ iccsq.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitcc2
    FROM ztitcc2
   WHERE iccno  EQ iccno
     AND iccsq  EQ iccsq.


  SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitcc3
    FROM ztitcc3
   WHERE iccno  EQ iccno
     AND iccsq  EQ iccsq.

*-> 기능개선 XXXXX
  SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitcc4
    FROM ztitcc4
   WHERE iccno  EQ iccno
     AND iccsq  EQ iccsq.
*<- 기능개선 XXXXX

ENDFUNCTION.
