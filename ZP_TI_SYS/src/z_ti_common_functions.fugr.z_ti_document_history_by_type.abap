FUNCTION z_ti_document_history_by_type.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(XDOCNO) TYPE  ZTIREQNO
*"     VALUE(XAMDNO) TYPE  ZTIAMDSQ OPTIONAL
*"     VALUE(XDOCTY) TYPE  ZTIREQTY
*"  EXPORTING
*"     VALUE(XDATA) TYPE  C
*"  TABLES
*"      XDOCHIS STRUCTURE  ZTISDOCHIS OPTIONAL
*"  EXCEPTIONS
*"      ERROR_IN_LDB_PROCESS
*"----------------------------------------------------------------------
  DATA: it_dochis_tmp  LIKE  it_dochis OCCURS 1.
  DATA: l_prpyn        TYPE  ztiprpyn.

  REFRESH: it_pokey, it_dochis.
  CLEAR:   it_pokey, it_dochis, xdata, g_set_nodekey,
           g_node_seq.

  MOVE: xdocty         TO g_docty,
        xdocno         TO g_docno,
        xamdno         TO g_amdsq,
        '000000000000' TO g_node_seq.

  CASE xdocty.
    WHEN 'LC'.  ">수입의뢰.
*      SELECT ebeln ebelp
      SELECT ebeln
        INTO CORRESPONDING FIELDS OF TABLE it_pokey
        FROM ztivrq01
       WHERE reqno EQ xdocno
         AND amdsq EQ xamdno
       GROUP BY ebeln.
*       GROUP by ebeln ebelp.

    WHEN 'IP'.  ">적하보험.
*      SELECT a~ebeln a~ebelp
      SELECT a~ebeln
        INTO CORRESPONDING FIELDS OF TABLE it_pokey
        FROM ztitrqp AS a JOIN ztitip1 AS b
          ON a~reqno EQ b~reqno
       WHERE b~iipno EQ xdocno
         AND b~amdsq EQ xamdno
       GROUP BY a~ebeln.
*       GROUP by A~ebeln A~ebelp.

    WHEN 'BL'.  ">B/L
*      SELECT ebeln ebelp
      SELECT ebeln
        INTO CORRESPONDING FIELDS OF TABLE it_pokey
        FROM ztivbl00
       WHERE iblno EQ xdocno
       GROUP BY ebeln.

    WHEN 'IV'.  ">상업송장.
*      SELECT ebeln ebelp
      SELECT ebeln
       INTO CORRESPONDING FIELDS OF TABLE it_pokey
       FROM ztiviv00
      WHERE ivono EQ xdocno
      GROUP BY ebeln.

    WHEN 'LG'.  ">L/G
*      SELECT ebeln ebelp
      SELECT ebeln
        INTO CORRESPONDING FIELDS OF TABLE it_pokey
        FROM ztivbl00
       WHERE iblno EQ ( SELECT iblno
                          FROM ztitlg1
                         WHERE ilgno  EQ  xdocno )
       GROUP BY ebeln.

    WHEN 'BS'.  ">반입예정정보.
*      SELECT ebeln ebelp
      SELECT ebeln
        INTO CORRESPONDING FIELDS OF TABLE it_pokey
        FROM ztivbl00
       WHERE iblno EQ ( SELECT iblno
                          FROM ztitbsk
                         WHERE ibsno  EQ  xdocno )
       GROUP BY ebeln.
    WHEN 'BI'.  ">반입신고.
*      SELECT ebeln ebelp
      SELECT ebeln
        INTO CORRESPONDING FIELDS OF TABLE it_pokey
        FROM ztivbl00
       WHERE iblno EQ ( SELECT iblno
                          FROM ztitbik
                         WHERE ibino  EQ  xdocno )
       GROUP BY ebeln.
    WHEN 'BO'.  ">반출신고.
*      SELECT ebeln ebelp
      SELECT ebeln
        INTO CORRESPONDING FIELDS OF TABLE it_pokey
        FROM ztivbl00
       WHERE iblno EQ ( SELECT iblno
                          FROM ztitbok
                         WHERE ibono  EQ  xdocno )
       GROUP BY ebeln.

    WHEN 'CR'.  ">통관의뢰.
*      SELECT ebeln ebelp
      SELECT ebeln
       INTO CORRESPONDING FIELDS OF TABLE it_pokey
       FROM ztivcR00
      WHERE iccno EQ xdocno
       GROUP BY ebeln.

    WHEN 'CC'.  ">통관.
*      SELECT ebeln ebelp
      SELECT ebeln
       INTO CORRESPONDING FIELDS OF TABLE it_pokey
       FROM ztivcc00
      WHERE iccno EQ xdocno
       GROUP BY ebeln.
    WHEN 'GR'.  ">입고.
*      SELECT ebeln ebelp
      SELECT ebeln
       INTO CORRESPONDING FIELDS OF TABLE it_pokey
       FROM ztivgr00
      WHERE igrno EQ xdocno
       GROUP BY ebeln.

    WHEN 'PN'.  ">Notice.
*      SELECT ebeln ebelp
      SELECT ebeln
       INTO CORRESPONDING FIELDS OF TABLE it_pokey
       FROM ztivpn00
      WHERE pntno EQ xdocno
       GROUP BY ebeln.

    WHEN 'XX'.  ">진행관리용.
*      SELECT ebeln ebelp
      SELECT ebeln
       INTO CORRESPONDING FIELDS OF TABLE it_pokey
       FROM ekpo
      WHERE ebeln EQ xdocno
       GROUP BY ebeln.
    when others.
      exit.
  ENDCASE.

  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

*   prepare callbacks for ldb_process:
  PERFORM doc_history_callback_build  TABLES it_callback.

  REFRESH: it_selscreen.
  LOOP AT it_pokey.
*   prepare selection screen table:
    PERFORM doc_history_selection_build TABLES it_selscreen
                                        USING  it_pokey-ebeln
                                               it_pokey-ebelp.
  ENDLOOP.

*   read ldb DDF:
  CALL FUNCTION 'LDB_PROCESS'
       EXPORTING
            ldbname                     = 'ZTIL01'
*              expressions                 = it_dyn_texpr[]
*             DYN_NODE_TYPES              =
       TABLES
            callback                    = it_callback
            selections                  = it_selscreen
       EXCEPTIONS
            ldb_not_reentrant           = 1
            ldb_incorrect               = 2
            ldb_already_running         = 3
            ldb_error                   = 4
            ldb_selections_error        = 5
            ldb_selections_not_accepted = 6
            free_selections_error       = 10
            callback_no_event           = 11
            callback_node_duplicate     = 12
            callback_no_program         = 13
            callback_no_cbform          = 14.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            RAISING error_in_ldb_process.
  ENDIF.

  DESCRIBE TABLE it_dochis LINES g_line.
  IF g_line EQ 0.
    xdata = c_false.
  ELSE.
    xdata = c_true.
    LOOP AT it_dochis.
      IF it_dochis-amdsq IS INITIAL.
        IF it_dochis-doccl EQ 'Z'.
          SELECT SINGLE prpyn
            INTO l_prpyn
            FROM ztitivk
           WHERE ivono EQ it_dochis-docnb.
          PERFORM get_domain_value_text(ztir0000)
                                 USING  'ZTIPRPYN'
                                         l_prpyn
                                         it_dochis-docct.
        ELSE.
          PERFORM get_domain_value_text(ztir0000)
                                 USING  'ZTIDOCCL'
                                         it_dochis-doccl
                                         it_dochis-docct.
        ENDIF.
      ELSE.
        CASE xdocty.
          WHEN 'LC'.  ">수입의뢰.
            it_dochis-docct = 'Amend'.
          WHEN 'IP'.  ">적하보험.
            it_dochis-docct = '적하부보배서'.
          WHEN OTHERS.
            PERFORM get_domain_value_text(ztir0000)
                                   USING  'ZTIDOCCL'
                                           it_dochis-doccl
                                           it_dochis-docct.
            CONCATENATE it_dochis-docct '[정정]' INTO it_dochis-docct.
        ENDCASE.
      ENDIF.
      IF it_dochis-doccl EQ 'P'.
        SELECT SUM( netwr )
          INTO it_dochis-docat
          FROM ekpo
         WHERE ebeln EQ it_dochis-docnb.
      ENDIF.
      MODIFY it_dochis.
    ENDLOOP.
  ENDIF.

  xdochis[] = it_dochis[].

ENDFUNCTION.
