FUNCTION z_ti_get_bonded_area_gi_doc.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IM_ICCNO) TYPE  ZTIICCNO OPTIONAL
*"     VALUE(IM_BDSEQ) TYPE  ZTIBDSEQ OPTIONAL
*"  EXPORTING
*"     VALUE(EX_ZTITBDK) TYPE  ZTITBDK
*"     VALUE(EX_ZTITCCK) TYPE  ZTITCCK
*"     VALUE(EX_ZTITBLK) TYPE  ZTITBLK
*"     VALUE(EX_ZTITBIK) TYPE  ZTITBIK
*"     VALUE(EX_ZTITBOK) TYPE  ZTITBOK
*"     VALUE(EX_ZTITBSK) TYPE  ZTITBSK
*"  TABLES
*"      ET_ZTITBDP STRUCTURE  ZTISBDIT OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------

*> 보세구역 출고 Header Table
  SELECT SINGLE *
    INTO ex_ztitbdk
    FROM ztitbdk
   WHERE iccno = im_iccno
     AND bdseq = im_bdseq.

  IF sy-subrc  NE  0.
    MESSAGE e485 WITH im_iccno im_bdseq RAISING not_found.
  ENDIF.

  SELECT SINGLE *
    INTO ex_ztitblk
    FROM ztitblk
   WHERE iblno EQ ex_ztitbdk-iblno.

  SELECT SINGLE *
    INTO ex_ztitbsk
    FROM ztitbsk
   WHERE ibsno EQ ex_ztitbdk-ibsno.

  SELECT SINGLE *
    INTO ex_ztitbik
    FROM ztitbik
   WHERE ibino EQ ex_ztitbdk-ibino.

  SELECT SINGLE *
    INTO ex_ztitbok
    FROM ztitbok
   WHERE ibono EQ ex_ztitbdk-ibono.

  SELECT SINGLE *
    INTO ex_ztitcck
    FROM ztitcck
   WHERE iccno EQ ex_ztitcck-iccno
     AND iccsq EQ ( SELECT MAX( iccsq )
                      FROM ztitcck
                     WHERE iccno EQ ex_ztitcck-iccno ).

*> 보세구역 출고 Items Table
  SELECT * INTO CORRESPONDING FIELDS OF TABLE et_ztitbdp
    FROM ztitbdp
   WHERE iccno  EQ im_iccno
     AND bdseq  EQ im_bdseq.

  LOOP AT et_ztitbdp.
    SELECT SINGLE ccmng
      INTO et_ztitbdp-ccmng
      FROM ztitccp
     WHERE iccno EQ et_ztitbdp-iccno
       AND iccsq EQ ( SELECT MAX( iccsq )
                        FROM ztitcck
                       WHERE iccno EQ et_ztitbdp-iccno ).

    SELECT SINGLE matnr txz01
      INTO CORRESPONDING FIELDS OF et_ztitbdp
      FROM ztitblp
     WHERE iblno EQ et_ztitbdp-iblno
       AND iblit EQ et_ztitbdp-iblit.

    SELECT SUM( bdqty )
      INTO et_ztitbdp-bdqtys
      FROM ztitbdp
     WHERE iccno EQ et_ztitbdp-iccno
       AND iccit EQ et_ztitbdp-iccit
       AND bdseq NE im_bdseq.

    et_ztitbdp-bdqtyl = et_ztitbdp-ccmng - et_ztitbdp-bdqtys.
    IF et_ztitbdp-bdqtyl LE 0.
      et_ztitbdp-bdqtyl = 0.
      DELETE et_ztitbdp INDEX g_tabix.
      CONTINUE.
    ENDIF.
    et_ztitbdp-bdqty = et_ztitbdp-bdqtyl.
    MODIFY et_ztitbdp.
  ENDLOOP.

ENDFUNCTION.
