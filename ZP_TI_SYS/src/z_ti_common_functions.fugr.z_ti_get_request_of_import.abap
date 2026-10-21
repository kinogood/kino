FUNCTION z_ti_get_request_of_import.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(REQNO) TYPE  ZTIREQNO
*"     VALUE(AMDSQ) TYPE  ZTIAMDSQ
*"     VALUE(REQIT) TYPE  ZTIREQIT OPTIONAL
*"  EXPORTING
*"     VALUE(ZTITRQK) TYPE  ZTITRQK
*"     VALUE(ZTITRQS) TYPE  ZTITRQS
*"     VALUE(ZTITLC1) TYPE  ZTITLC1
*"     VALUE(ZTITLC5) TYPE  ZTITLC5
*"     VALUE(ZTITLO1) TYPE  ZTITLO1
*"     VALUE(ZTITPC1) TYPE  ZTITPC1
*"     VALUE(ZTITTT1) TYPE  ZTITTT1
*"     VALUE(ZTITDAK) TYPE  ZTITDAK
*"  TABLES
*"      ZTITRQP STRUCTURE  ZTISRQIT OPTIONAL
*"      ZTITLC2 STRUCTURE  VZTITLC2 OPTIONAL
*"      ZTITLC3 STRUCTURE  VZTITLC3 OPTIONAL
*"      ZTITLC4 STRUCTURE  ZTISLC04 OPTIONAL
*"      ZTITPC2 STRUCTURE  VZTITPC2 OPTIONAL
*"      ZTITPC3 STRUCTURE  VZTITPC3 OPTIONAL
*"      ZTITTT2 STRUCTURE  VZTITTT2 OPTIONAL
*"      ZTITTT3 STRUCTURE  VZTITTT3 OPTIONAL
*"      ZTITTT4 STRUCTURE  ZTISTT4 OPTIONAL
*"      ZTITDAS STRUCTURE  ZTITDAS OPTIONAL
*"      ZTITDAC STRUCTURE  ZTITDAC OPTIONAL
*"      ZTITDAD STRUCTURE  ZTITDAD OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------
  TABLES : rkwa.
  DATA: l_ppmng    LIKE ztitrqp-ppmng,
        ls_proj    LIKE proj.

*> 수입의뢰 공통 테이블.
  SELECT SINGLE *
    FROM ztitrqk
   WHERE reqno = reqno.

  IF sy-subrc  NE  0.
    MESSAGE e108 WITH reqno RAISING not_found.
  ENDIF.

  SELECT SINGLE *
    FROM ztitrqs
   WHERE reqno = reqno
     AND amdsq = amdsq.

  IF sy-subrc  NE  0.
    MESSAGE e137 WITH reqno amdsq RAISING not_found.
  ENDIF.

  IF reqit IS INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitrqp
      FROM ztitrqp
     WHERE reqno  EQ reqno
       AND amdsq  EQ amdsq.
  ELSE.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitrqp
      FROM ztitrqp
     WHERE reqno  EQ reqno
       AND amdsq  EQ amdsq
       AND reqit  EQ reqit.
    IF sy-subrc  NE  0.
      MESSAGE e138 WITH reqno reqit RAISING not_found.
    ENDIF.
  ENDIF.

  LOOP AT ztitrqp.
*> 위탁자재 수입의뢰일 경우.
    IF ztitrqp-ebeln IS INITIAL.
*      CLEAR:rkwa.
*
*      SELECT SINGLE *
*        FROM rkwa
*       WHERE mblnr   = ZTITRQP-mblnr
*         AND mjahr   = ZTITRQP-mjahr
*         AND zeile   = ZTITRQP-zeile.
*
*      MOVE: 1          TO ZTITRQP-peinh,
*            1          TO ZTITRQP-bpumz,
*            1          TO ZTITRQP-bpumn,
*            rkwa-bstmg TO ZTITRQP-menge,
*            rkwa-bstme TO ZTITRQP-meins,
*            rkwa-werks TO ZTITRQP-werks,
*            rkwa-matnr TO ZTITRQP-matnr.
*
*      SELECT SINGLE ps_psp_pnr aufnr
*        INTO (ZTITRQP-ps_psp_pnr, ZTITRQP-nplnr)
*        FROM mseg
*       WHERE mblnr   = ZTITRQP-mblnr
*         AND mjahr   = ZTITRQP-mjahr
*         AND zeile   = ZTITRQP-zeile.
*      IF ZTITRQP-ps_psp_pnr IS INITIAL.
*        IF rkwa-bstmg EQ 0.
*          ZTITRQP-netpr = 0.
*        ELSE.
*          ZTITRQP-netpr = rkwa-wrbtr / rkwa-bstmg.
*        ENDIF.
*      ELSE.
*        PERFORM get_parent_wbs_element(ZTIr0000)
*                                       USING ZTITRQP-ps_psp_pnr
*                                             ls_proj.
*        MOVE: ls_proj-pspnr   TO ZTITRQP-ps_psp_pnr.
*
*        SELECT SINGLE netpr
*          INTO ZTITRQP-netpr
*          FROM zmmt0003
*         WHERE lifnr EQ ZTITRQK-lifnr
*           AND matnr EQ ZTITRQP-matnr
*           AND pspid EQ ZTITRQP-ps_psp_pnr
*           AND sdate LE rkwa-budat
*           AND edate GE rkwa-budat.
*        ZTITRQP-netwr = ZTITRQP-netpr * rkwa-bstmg.
*      ENDIF.
*
*      IF NOT ZTITRQP-nplnr IS INITIAL.
*        PERFORM get_wbs_element_by_network(ZTIr0000)
*                                       USING ZTITRQP-nplnr
*                                             ls_proj.
*        MOVE: ls_proj-pspnr   TO ZTITRQP-ps_psp_pnr.
*      ENDIF.
*
*      SELECT  SUM( rqmng )
*        INTO  ZTITRQP-rqmngs
*        FROM  ZTIvrq00
*       WHERE  mblnr  = ZTITRQP-mblnr
*         AND  mjahr  = ZTITRQP-mjahr
*         AND  zeile  = ZTITRQP-zeile
*         AND NOT ( reqno  EQ  ZTITRQP-reqno
*         AND       reqit  EQ  ZTITRQP-reqit ).
*
*      ZTITRQP-rqmngl =  ZTITRQP-menge - ZTITRQP-rqmngs.
*      IF ZTITRQP-rqmngl LE 0.
*        ZTITRQP-rqmngl = 0.
*      ENDIF.
*
*      SELECT SINGLE maktx
*        INTO ZTITRQP-txz01
*        FROM makt
*       WHERE matnr  EQ  ZTITRQP-matnr
*         AND spras  EQ  sy-langu.
*
*      ZTITRQP-repos = ZTITRQP-wepos = 'X'.
    ELSEIF NOT ztitrqp-iblno IS INITIAL.
      SELECT SINGLE menge werks lgort matnr txz01
                    loekz elikz bprme bpumz bpumn umrez
                    umren netpr peinh uebto uebtk untto
                    repos wepos
      INTO CORRESPONDING FIELDS OF ztitrqp
        FROM ekpo
       WHERE ebeln  EQ  ztitrqp-ebeln
         AND ebelp  EQ  ztitrqp-ebelp.

      SELECT SINGLE blmng
        INTO ztitrqp-menge
        FROM ztitblp
       WHERE iblno  EQ  ztitrqp-iblno
         AND iblit  EQ  ztitrqp-iblit.

      SELECT  SUM( rqmng ) SUM( netwr )
        INTO (ztitrqp-rqmngs, ztitrqp-rqamts)
        FROM ztitrqp
       WHERE  iblno  EQ  ztitrqp-iblno
         AND  iblit  EQ  ztitrqp-iblit
         AND NOT ( reqno  EQ  ztitrqp-reqno
         AND       reqit  EQ  ztitrqp-reqit ).

      ztitrqp-rqmngl =  ztitrqp-menge - ztitrqp-rqmngs.

    ELSE.
      SELECT SINGLE menge werks lgort matnr txz01
                    loekz elikz bprme bpumz bpumn umrez
                    umren netpr peinh uebto uebtk untto
                    repos wepos
      INTO CORRESPONDING FIELDS OF ztitrqp
        FROM ekpo
       WHERE ebeln  EQ  ztitrqp-ebeln
         AND ebelp  EQ  ztitrqp-ebelp.
*
      IF ztitrqp-ppmng EQ 0.
        SELECT  SUM( rqmng ) SUM( ppmng ) SUM( netwr )
          INTO (ztitrqp-rqmngs, l_ppmng, ztitrqp-rqamts)
          FROM ztivrq00
         WHERE  ebeln  EQ  ztitrqp-ebeln
           AND  ebelp  EQ  ztitrqp-ebelp
           AND NOT ( reqno  EQ  ztitrqp-reqno
           AND       reqit  EQ  ztitrqp-reqit ).
*         AND  ppaid  NE  'X'
*         AND  rpaid  NE  'X' .
        ztitrqp-rqmngl =  ztitrqp-menge -
                          ( ztitrqp-rqmngs - l_ppmng ).
      ELSE.
        SELECT  SUM( rqmng ) SUM( ppmng )
          INTO (ztitrqp-rqmngs, l_ppmng)
          FROM ztivrq00
         WHERE  ebeln  EQ  ztitrqp-ebeln
           AND  ebelp  EQ  ztitrqp-ebelp
           AND NOT ( reqno  EQ  ztitrqp-reqno
           AND       reqit  EQ  ztitrqp-reqit )
           AND  ppaid  NE  'X'
           AND  rpaid  NE  'X' .
        ztitrqp-rqmngl =  ztitrqp-menge -
                          ( ztitrqp-rqmngs - l_ppmng ).
      ENDIF.

      IF ztitrqp-rqmngl LE 0.
        ztitrqp-rqmngl = 0.
      ENDIF.
    ENDIF.
*> 구매오더 정가 계산.
    CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
      EXPORTING
        peinh = ztitrqp-peinh
        bpumz = ztitrqp-bpumz
        bpumn = ztitrqp-bpumn
        menge = ztitrqp-menge
        netpr = ztitrqp-netpr
      CHANGING
        netwr = ztitrqp-poamt.


    MODIFY ztitrqp.
  ENDLOOP.


*> 포워더 관리.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitlc4
    FROM ztitlc4
   WHERE reqno  EQ reqno.

  LOOP AT ztitlc4.
    SELECT SINGLE name1
      INTO ztitlc4-name1
      FROM lfa1
     WHERE lifnr EQ ztitlc4-fwdcd.

    MODIFY ztitlc4.
  ENDLOOP.

*> 수입 신용장 관련 Table.
  IF ztitrqk-reqty EQ 'LC'.
    SELECT SINGLE *
      FROM ztitlc1
     WHERE reqno = reqno
       AND amdsq = amdsq.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitlc2
      FROM ztitlc2
     WHERE reqno  EQ reqno
       AND amdsq  EQ amdsq.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitlc3
      FROM ztitlc3
     WHERE reqno  EQ reqno
       AND amdsq  EQ amdsq.

    SELECT SINGLE *
      FROM ztitlc5
     WHERE reqno = reqno
       AND amdsq = amdsq.

  ENDIF.

*> 구매확인서 관련 Table.
  IF ztitrqk-reqty EQ 'PU'.
    SELECT SINGLE *
      FROM ztitpc1
     WHERE reqno = reqno
       AND amdsq = amdsq.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitpc2
      FROM ztitpc2
     WHERE reqno  EQ reqno
       AND amdsq  EQ amdsq.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitpc3
      FROM ztitpc3
     WHERE reqno  EQ reqno
       AND amdsq  EQ amdsq.
  ENDIF.

*> Local L/C 관련 Table.
  IF ztitrqk-reqty EQ 'LO'.
    SELECT SINGLE *
      FROM ztitlo1
     WHERE reqno = reqno
       AND amdsq = amdsq.
  ENDIF.
*> 전신환 송금 관련 Table.
  IF ztitrqk-reqty EQ 'TT'.



    SELECT SINGLE *
      FROM ztitdak
     WHERE dadno EQ ( SELECT MAX( dadno )
                       FROM ztitdak
                      WHERE etcno EQ ztitrqs-recno ).

    IF sy-subrc EQ 0.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitdas
        FROM ztitdas
       WHERE dadno  EQ ztitdak-dadno.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitdad
        FROM ztitdad
       WHERE cadno  EQ ztitdak-dadno.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE ztitdac
        FROM ztitdac
       WHERE cadno  EQ ztitdak-dadno.
    ENDIF.

    SELECT SINGLE *
      FROM ztittt1
     WHERE reqno = reqno.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE ztittt2
      FROM ztittt2
     WHERE reqno  EQ reqno.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE ztittt3
      FROM ztittt3
     WHERE reqno  EQ reqno.

*> 사후송금일 경우.
    IF ztitrqk-anbty EQ 'A'.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE ztittt4
        FROM ztittt4
       WHERE reqno  EQ reqno.

      LOOP AT ztittt4.
        IF ztittt1-payrs EQ 'ACB'.       ">수입대금 결제.
          SELECT SUM( payat )
            INTO ztittt4-payats
            FROM ztittt4
           WHERE reqno NE reqno
             AND cdcno EQ ztittt4-cdcno.
          ztittt4-payatl = ztittt4-payat - ztittt4-payats.
          IF ztittt4-payatl LT 0.
            ztittt4-payatl = 0.
          ENDIF.
        ELSEIF ztittt1-payrs EQ 'ACE'.   ">중계무역방식 결제.
          SELECT SUM( payat )
            INTO ztittt4-payats
            FROM ztittt4
           WHERE reqno NE reqno
             AND ngben EQ ztittt4-ngben.
          ztittt4-payatl = ztittt4-payat - ztittt4-payats.
          IF ztittt4-payatl LT 0.
            ztittt4-payatl = 0.
          ENDIF.
        ENDIF.

        MODIFY ztittt4.
      ENDLOOP.
    ENDIF.

  ENDIF.

ENDFUNCTION.
