FUNCTION z_ti_get_charge_document.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(XBUKRS) TYPE  BUKRS
*"     REFERENCE(XICSNO) TYPE  ZTIICSNO
*"  EXPORTING
*"     REFERENCE(XZTITCSK) TYPE  ZTITCSK
*"     REFERENCE(XZTITCSO) TYPE  ZTITCSO
*"  TABLES
*"      XZTITCSP STRUCTURE  ZTISCSIT OPTIONAL
*"      XZTITCSD STRUCTURE  ZTITCSD OPTIONAL
*"      XZTITCSH STRUCTURE  ZTITCSH OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------
  CLEAR  : xztitcsk, xztitcsp, xztitcsd, xztitcsh, xztitcso.
  REFRESH: xztitcsp, xztitcsd, xztitcsh.

*> Get 비용헤더.
  SELECT SINGLE *
    INTO xztitcsk
    FROM ztitcsk
   WHERE bukrs EQ xbukrs
     AND icsno EQ xicsno.

  IF sy-subrc NE 0.
    MESSAGE e850 WITH xbukrs xicsno RAISING not_found.
  ENDIF.

  SELECT SINGLE *
    INTO xztitcso
    FROM ztitcso
   WHERE bukrs EQ xbukrs
     AND icsno EQ xicsno.

*>Get 비용항목.
  SELECT *
    FROM ztitcsp
    INTO CORRESPONDING FIELDS OF TABLE xztitcsp
   WHERE bukrs EQ xbukrs
     AND icsno EQ xicsno.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_ztitig06
    FROM ztitig06
   WHERE bukrs EQ xbukrs
     AND expgr EQ xztitcsk-expgr.

  LOOP AT xztitcsp.
    g_tabix = sy-tabix.
    CASE xztitcsp-expgr.
      WHEN 'L'.   ">수입의뢰비용.
        MOVE: xztitcsp-refno TO xztitcsp-reqno.
*> Get 수입번호 .
        PERFORM  get_request_of_import(ztir9000)
                                           USING  xztitcsp-reqno
                                                  xztitcsp-amdsq
                                                  xztitcsp-docnm
                                                  ztivrq04.
      WHEN 'I'.   ">적하보험비용.
        MOVE: xztitcsp-refno TO xztitcsp-iipno.
*> Get 증권번호 .
        PERFORM  get_insurance_document_no(ztir9000)
                                             USING  xztitcsp-iipno
                                                    xztitcsp-amdsq
                                                    xztitcsp-docnm
                                                    ztitip1.

      WHEN 'B'.   ">선적관련비용.
        MOVE: xztitcsp-refno TO xztitcsp-iblno.
*> Get B/L number .
        PERFORM  get_bl_number(ztir9000)
                                           USING  xztitcsp-iblno
                                                  xztitcsp-docnm
                                                  ztitblk.

      WHEN 'C'.   ">수입통관비용
        MOVE: xztitcsp-refno TO xztitcsp-iccno.
*> Get 수리번호 .
        PERFORM  get_custom_clearance(ztir9000)
                                           USING  xztitcsp-iccno
                                                  xztitcsp-docnm
                                                  ztitcck.
      WHEN 'T'.   ">관세전가액.
        MOVE: xztitcsp-refno TO xztitcsp-taxno.
*> Get 접수번호 .
        PERFORM  get_tax_document(ZTIR9000)
                                           USING  xztitcsp-taxno
                                                  xztitcsp-docnm
                                                  ztitTXk.
    ENDCASE.
*> Get 비용설명 텍스트     .
    READ TABLE it_ztitig06 WITH KEY expcd = xztitcsp-expcd.
    IF sy-subrc EQ 0.
      xztitcsp-exptx = it_ztitig06-exptx.
    ENDIF.

    MODIFY xztitcsp INDEX g_tabix.
  ENDLOOP.

*>Get 비용배부내용.
  SELECT *
    FROM ztitcsd
    INTO CORRESPONDING FIELDS OF TABLE xztitcsd
   WHERE bukrs EQ xbukrs
     AND icsno EQ xicsno.

*>Get 비용이력.
  SELECT *
    FROM ztitcsh
    INTO CORRESPONDING FIELDS OF TABLE xztitcsh
   WHERE bukrs EQ xbukrs
     AND icsno EQ xicsno.

ENDFUNCTION.
