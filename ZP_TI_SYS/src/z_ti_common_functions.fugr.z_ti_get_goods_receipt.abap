FUNCTION z_ti_get_goods_receipt.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(XIGRNO) TYPE  ZTIIGRNO OPTIONAL
*"  EXPORTING
*"     REFERENCE(XZTITGRK) TYPE  ZTITGRK
*"  TABLES
*"      XZTITGRP STRUCTURE  ZTISGRIT OPTIONAL
*"      XZTITGRH STRUCTURE  ZTISGRHS OPTIONAL
*"      XZTITGRB STRUCTURE  ZTISGRB OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------

  REFRESH: xztitgrb, xztitgrh, xztitgrp.

*> 입고 Header Table
  SELECT SINGLE *
    INTO xztitgrk
    FROM ztitgrk
   WHERE igrno = xigrno.

  IF sy-subrc  NE  0.
    MESSAGE e500 WITH xigrno RAISING not_found.
  ENDIF.

*> 입고 Items table
  SELECT * INTO CORRESPONDING FIELDS OF TABLE xztitgrp
    FROM ztitgrp
   WHERE igrno  EQ xigrno.

  LOOP AT xztitgrp.
*    SELECT SINGLE werks lgort
*      INTO (xZTITGRP-werks, xZTITGRP-lgort)
*      FROM ZTITBLP
*     WHERE iblno  EQ xZTITGRP-iblno
*       AND iblit  EQ xZTITGRP-iblit.
    IF NOT xztitgrp-ebeln IS INITIAL.
      SELECT SINGLE name1
             loekz elikz bprme bpumz bpumn
             umrez umren netpr peinh uebto uebtk untto
             knttp repos wepos
          INTO (xztitgrp-name1,
*                xZTITGRP-matnr, xZTITGRP-txz01,
                xztitgrp-loekz, xztitgrp-elikz, xztitgrp-bprme,
                xztitgrp-bpumz, xztitgrp-bpumn, xztitgrp-umrez,
                xztitgrp-umren, xztitgrp-netpr, xztitgrp-peinh,
                xztitgrp-uebto, xztitgrp-uebtk, xztitgrp-untto,
                xztitgrp-knttp, xztitgrp-repos, xztitgrp-wepos)
*        INTO  CORRESPONDING FIELDS OF ZTITIVP
        FROM  ztivpo00
       WHERE  ebeln  = xztitgrp-ebeln
         AND  ebelp  = xztitgrp-ebelp.
    ENDIF.

    SELECT SINGLE ccmng
      INTO xztitgrp-ccmng
      FROM ztitccp
     WHERE iccno EQ xztitgrp-iccno
       AND iccit EQ xztitgrp-iccit.

    SELECT SUM( grmng )
      INTO xztitgrp-grmngs
      FROM ztitgrp
     WHERE iccno EQ xztitgrp-iccno
       AND iccit EQ xztitgrp-iccit
       AND NOT ( igrno EQ xztitgrp-igrno
       AND       iccit EQ xztitgrp-iccit ).

    xztitgrp-grmngl = xztitgrp-ccmng - xztitgrp-grmngs.
    IF xztitgrp-grmngl LT 0.
      xztitgrp-grmngl = 0.
    ENDIF.

*> 자재그룹.
    IF NOT xztitgrp-matnr IS INITIAL.
      SELECT SINGLE matkl
        INTO xztitgrp-matkl
        FROM mara
       WHERE matnr EQ xztitgrp-matnr.
    ENDIF.

    MODIFY xztitgrp.
  ENDLOOP.

*> 입고 이력 table
  SELECT * INTO CORRESPONDING FIELDS OF TABLE xztitgrh
    FROM ztitgrh
   WHERE igrno  EQ xigrno.

*> 입고 Items 하위 Batch table
  SELECT * INTO CORRESPONDING FIELDS OF TABLE xztitgrb
    FROM ztitgrb
   WHERE igrno  EQ xigrno.

ENDFUNCTION.
