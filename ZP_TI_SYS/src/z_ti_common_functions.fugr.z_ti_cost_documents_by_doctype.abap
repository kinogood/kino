FUNCTION z_ti_cost_documents_by_doctype.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(XBUKRS) TYPE  BUKRS
*"     VALUE(XDOCNO) TYPE  ZTIREQNO
*"     VALUE(XAMDNO) TYPE  ZTIAMDSQ OPTIONAL
*"     VALUE(XDOCTY) TYPE  ZTIREQTY
*"  EXPORTING
*"     VALUE(XDATA) TYPE  C
*"  TABLES
*"      XCOST STRUCTURE  ZTISCOSTDOC OPTIONAL
*"----------------------------------------------------------------------
  DATA: l_expgr      TYPE     ztiexpgr.

  REFRESH: it_costdoc, xcost.
  CLEAR:   it_costdoc, xdata, xcost.

  CASE xdocty.
    WHEN 'LC'.  ">수입의뢰.
      l_expgr = 'L'.
    WHEN 'IP'.  ">적하보험.
      l_expgr = 'I'.
    WHEN 'BL'.  ">B/L
      l_expgr = 'B'.
    WHEN 'CC'.  ">통관.
      l_expgr = 'C'.
    WHEN 'TX'.  ">관세전가.
      l_expgr = 'T'.
    WHEN OTHERS.
      EXIT.
  ENDCASE.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_costdoc
    FROM ztivcs00
   WHERE bukrs   EQ   xbukrs
     AND expgr   EQ   l_expgr
     AND refno   EQ   xdocno
     AND amdsq   EQ   xamdno.

  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

  LOOP AT it_costdoc.
    SELECT SINGLE exptx
      INTO it_costdoc-exptx
      FROM ztitig06
     WHERE bukrs EQ it_costdoc-bukrs
       AND expgr EQ it_costdoc-expgr
       AND expcd EQ it_costdoc-expcd.

    SELECT SINGLE name1
      INTO it_costdoc-name1
      FROM lfa1
     WHERE lifnr EQ it_costdoc-lifnr.

    MODIFY it_costdoc.

  ENDLOOP.

  DESCRIBE TABLE it_costdoc LINES g_line.
  IF g_line EQ 0.
    xdata = c_false.
  ELSE.
    xdata = c_true.
  ENDIF.

  xcost[] = it_costdoc[].

ENDFUNCTION.
