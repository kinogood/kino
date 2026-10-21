*&---------------------------------------------------------------------*
*&  Include           LZ_TI_COMMON_FUNCTIONSCB1                        *
*&---------------------------------------------------------------------*


*----------------------------------------------------------------------*
* CALLBACK HANDLE_ITEM_DBL_CLK                                         *
*----------------------------------------------------------------------*
callback handle_item_dbl_clk.

  DATA: l_node     LIKE treev_node,
        l_node_key LIKE treev_node-node_key,
        l_tabix    LIKE sy-tabix.

  CALL FUNCTION 'TREEV_GET_EP_ITEM_DBL_CLK'
    EXPORTING
      handle                            = g_tree_handle
*   NO_FLUSH                          =
   IMPORTING
     node_key                          = l_node_key
*   ITEM_NAME                         =
   EXCEPTIONS
     failed                            = 1
     instance_not_found                = 2
     not_allowed_for_simple_tree       = 3
     cntl_system_error                 = 4
     no_item_selection                 = 5
     OTHERS                            = 6.

  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  PERFORM display_selected_node_info USING l_node_key.

endcallback.

*----------------------------------------------------------------------*
* CALLBACK HANDLE_NODE_DBL_CLK                                         *
*----------------------------------------------------------------------*
callback handle_node_dbl_clk.

  DATA: l_node     LIKE treev_node,
        l_node_key LIKE treev_node-node_key,
        l_tabix    LIKE sy-tabix.

  CALL FUNCTION 'TREEV_GET_EP_ITEM_DBL_CLK'
    EXPORTING
      handle                            = g_tree_handle
*   NO_FLUSH                          =
   IMPORTING
     node_key                          = l_node_key
*   ITEM_NAME                         =
   EXCEPTIONS
     failed                            = 1
     instance_not_found                = 2
     not_allowed_for_simple_tree       = 3
     cntl_system_error                 = 4
     no_item_selection                 = 5
     OTHERS                            = 6.

  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  PERFORM display_selected_node_info USING l_node_key.

endcallback.


*&---------------------------------------------------------------------*
*&      Form  ZTIL01_GET_ZTIVPO01
*&---------------------------------------------------------------------*
FORM ztil01_get_ztivpo01  USING  name         LIKE ldbn-ldbnode
                                 ls_ztivpo01  LIKE ztivpo01
                                 mode         TYPE c
                                 selected     TYPE c.

  DATA: l_netwr TYPE netwr,
        l_rqmng TYPE ztirqmng.

  MOVE-CORRESPONDING ls_ztivpo01 TO ztivpo01.

*> 구매오더 레벨.
  CLEAR: it_dochis.
  MOVE: 'P'                TO     it_dochis-doccl,
        ls_ztivpo01-ebeln  TO     it_dochis-docnb,
        ls_ztivpo01-bedat  TO     it_dochis-docdt,
        ls_ztivpo01-netwr  TO     it_dochis-docat,
        ls_ztivpo01-waers  TO     it_dochis-waers,
*        g_node_seq         TO     it_dochis-nodekey,
        ls_ztivpo01-name1  TO     it_dochis-docnm,
        space              TO     it_dochis-relatkey.

  READ TABLE it_dochis INTO g_dochis_tm
                       WITH KEY doccl    = it_dochis-doccl
                                docnb    = it_dochis-docnb
                                relatkey = it_dochis-relatkey.
  IF sy-subrc EQ 0.
    it_dochis-nodekey = g_dochis_tm-nodekey.
*    it_dochis-docat   = 0.
  ELSE.
    ADD 1 TO g_node_seq.
    it_dochis-nodekey = g_node_seq.
  ENDIF.

*> Temp structure로 Move.
  MOVE-CORRESPONDING it_dochis TO g_dochis_po.
  COLLECT it_dochis.

*>수입의뢰 이력조회.
  CLEAR: it_dochis.

  CASE ls_ztivpo01-reqty.
    WHEN 'LC'.
      CASE ls_ztivpo01-ilcty.
        WHEN 'A'.   ">At sight
          MOVE: '0'   TO     it_dochis-doccl.
        WHEN 'U'.   ">Usance
          MOVE: '1'   TO     it_dochis-doccl.
        WHEN 'M'.   ">Mixed payment
          MOVE: '2'   TO     it_dochis-doccl.
        WHEN OTHERS.
          MOVE: 'M'   TO     it_dochis-doccl.
      ENDCASE.
    WHEN 'TT'.
      IF ls_ztivpo01-anbty EQ 'A'.   ">사후송금.
        IF ls_ztivpo01-rpaid EQ 'X'. ">유보금.
          MOVE: '7'   TO     it_dochis-doccl.
        ELSE.
          MOVE: '9'   TO     it_dochis-doccl.
        ENDIF.
      ELSE.
        IF ls_ztivpo01-ppaid EQ 'X'. ">선급금.
          MOVE: '6'   TO     it_dochis-doccl.
        ELSE.
          MOVE: '8'   TO     it_dochis-doccl.
        ENDIF.
      ENDIF.
    WHEN 'LO'.
      MOVE: '3'   TO     it_dochis-doccl.
    WHEN 'PU'.
      IF ls_ztivpo01-setyn EQ 'X'.
        MOVE: '5'   TO     it_dochis-doccl.
      ELSE.
        MOVE: '4'   TO     it_dochis-doccl.
      ENDIF.
    WHEN 'DA'.
      MOVE: 'Q'   TO     it_dochis-doccl.
    WHEN 'DP'.
      MOVE: 'W'   TO     it_dochis-doccl.
  ENDCASE.

  IF ls_ztivpo01-amdsq IS INITIAL.
*    l_rqmng = ls_ZTIvpo01-rqmng - ls_ZTIvpo01-ppmng.
**> 정가 계산.
*    CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
*      EXPORTING
*        peinh = ls_ZTIvpo01-peinh
*        bpumz = ls_ZTIvpo01-bpumz
*        bpumn = ls_ZTIvpo01-bpumn
*        menge = l_rqmng
*        netpr = ls_ZTIvpo01-netpr
*      CHANGING
*        netwr = l_netwr.
    l_netwr = ls_ztivpo01-netwrr - ls_ztivpo01-ppamt.

    MOVE: ls_ztivpo01-reqno   TO     it_dochis-docnb,
*        ls_ZTIvpo01-BEDAT  to     it_dochis-docdt,
          l_netwr             TO     it_dochis-docat,
          ls_ztivpo01-waers   TO     it_dochis-waers,
          ls_ztivpo01-opnno   TO     it_dochis-docnm,
*          g_node_seq          TO     it_dochis-nodekey,
          g_dochis_po-nodekey TO     it_dochis-relatkey.
  ELSE.
    MOVE: ls_ztivpo01-amdsq   TO     it_dochis-docnb,
*        ls_ZTIvpo01-BEDAT  to     it_dochis-docdt,
          l_netwr             TO     it_dochis-docat,
          ls_ztivpo01-waers   TO     it_dochis-waers,
          ls_ztivpo01-opnno   TO     it_dochis-docnm,
*          g_node_seq          TO     it_dochis-nodekey,
          g_dochis_lc-nodekey TO     it_dochis-relatkey.
*         g_dochis_po-nodekey TO     it_dochis-relatkey.
  ENDIF.

  IF NOT ls_ztivpo01-opndt IS INITIAL.
    MOVE ls_ztivpo01-opndt TO it_dochis-docdt.
  ELSE.
    IF NOT ls_ztivpo01-snddt IS INITIAL.
      MOVE ls_ztivpo01-snddt TO it_dochis-docdt.
    ELSE.
      MOVE ls_ztivpo01-reqdt TO it_dochis-docdt.
    ENDIF.
  ENDIF.

  READ TABLE it_dochis INTO g_dochis_tm
                       WITH KEY doccl    = it_dochis-doccl
                                docnb    = it_dochis-docnb
                                relatkey = it_dochis-relatkey.
  IF sy-subrc EQ 0.
    it_dochis-nodekey = g_dochis_tm-nodekey.
  ELSE.
    ADD 1 TO g_node_seq.
    it_dochis-nodekey = g_node_seq.
  ENDIF.

  IF g_docty EQ 'LC'.
    IF ls_ztivpo01-reqno EQ g_docno AND
       ls_ztivpo01-amdsq EQ g_amdsq.
      g_set_nodekey = it_dochis-nodekey.
    ENDIF.
  ENDIF.
*> Temp structure로 Move.
  MOVE-CORRESPONDING it_dochis TO g_dochis_lc.

  COLLECT it_dochis.

*> AMEND 회차.
  SELECT *
    FROM ztivpo01
   WHERE reqno    EQ   ls_ztivpo01-reqno
     AND amdsq    NE   ls_ztivpo01-amdsq
     AND ebeln    EQ   ls_ztivpo01-ebeln
     AND ebelp    EQ   ls_ztivpo01-ebelp
     ORDER BY amdsq.

*    l_rqmng = ZTIvpo01-rqmng - ZTIvpo01-ppmng.
*
**> 정가 계산.
*    CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
*      EXPORTING
*        peinh = ZTIvpo01-peinh
*        bpumz = ZTIvpo01-bpumz
*        bpumn = ZTIvpo01-bpumn
*        menge = l_rqmng
*        netpr = ZTIvpo01-netpr
*      CHANGING
*        netwr = l_netwr.
    l_netwr = ztivpo01-netwrr - ztivpo01-ppamt.


    MOVE: ztivpo01-reqno  TO     it_dochis-docnb,
          ztivpo01-amdsq  TO     it_dochis-amdsq,
*        ls_ZTIvpo01-BEDAT  to     it_dochis-docdt,
          l_netwr          TO     it_dochis-docat,
          ztivpo01-waers   TO     it_dochis-waers,
          ztivpo01-opnno   TO     it_dochis-docnm,
*          g_node_seq          TO     it_dochis-nodekey,
          g_dochis_lc-nodekey TO     it_dochis-relatkey.
*         g_dochis_po-nodekey TO     it_dochis-relatkey.

    IF NOT ztivpo01-opndt IS INITIAL.
      MOVE ztivpo01-opndt TO it_dochis-docdt.
    ELSE.
      IF NOT ztivpo01-snddt IS INITIAL.
        MOVE ztivpo01-snddt TO it_dochis-docdt.
      ELSE.
        MOVE ztivpo01-reqdt TO it_dochis-docdt.
      ENDIF.
    ENDIF.

    READ TABLE it_dochis INTO g_dochis_tm
                         WITH KEY doccl    = it_dochis-doccl
                                  docnb    = it_dochis-docnb
                                  amdsq    = it_dochis-amdsq.
*                                  relatkey = it_dochis-relatkey.
*                                  nodekey  = it_dochis-relatkey.
    IF sy-subrc EQ 0.
      it_dochis-nodekey   = g_dochis_tm-nodekey.
      it_dochis-relatkey  = g_dochis_tm-relatkey.
      COLLECT it_dochis.
    ELSE.
      ADD 1 TO g_node_seq.
      it_dochis-nodekey = g_node_seq.
      APPEND it_dochis.
    ENDIF.

    IF g_docty EQ 'LC'.
      IF ztivpo01-reqno EQ g_docno AND
         ztivpo01-amdsq EQ g_amdsq.
        g_set_nodekey = it_dochis-nodekey.
      ENDIF.
    ENDIF.
*> Temp structure로 Move.
    MOVE-CORRESPONDING it_dochis TO g_dochis_lc.

  ENDSELECT.
*
ENDFORM.                               " ZTIL01_GET_ZTIVPO01
*&---------------------------------------------------------------------*
*&      Form  ZTIL01_GET_ZTITIP1
*&---------------------------------------------------------------------*
FORM ztil01_get_ztitip1  USING  name         LIKE ldbn-ldbnode
                                 ls_ztitip1  LIKE ztitip1
                                 mode         TYPE c
                                 selected     TYPE c.

  DATA: l_relatkey LIKE it_dochis-relatkey,
        l_subrc    LIKE sy-subrc.
*  add 1 to g_node_seq.

*> 적하보험 레벨.
  MOVE-CORRESPONDING ls_ztitip1 TO ztitip1.

*> 적하보험 레벨.
  CLEAR: it_dochis.
  MOVE: 'I'                    TO     it_dochis-doccl,
        ls_ztitip1-iipno      TO     it_dochis-docnb,
        ls_ztitip1-amdsq      TO     it_dochis-amdsq,
        ls_ztitip1-iisdt      TO     it_dochis-docdt,
        ls_ztitip1-iivatc     TO     it_dochis-waers,
        ls_ztitip1-iivat      TO     it_dochis-docat,
        g_node_seq             TO     it_dochis-nodekey,
        ls_ztitip1-ispno      TO     it_dochis-docnm,
        g_dochis_lc-nodekey    TO     it_dochis-relatkey.

  READ TABLE it_dochis INTO g_dochis_tm
                       WITH KEY doccl    = it_dochis-doccl
                                docnb    = it_dochis-docnb
                                amdsq    = it_dochis-amdsq.
*                                relatkey = it_dochis-relatkey.
  IF sy-subrc EQ 0.
    it_dochis-nodekey   = g_dochis_tm-nodekey.
    it_dochis-relatkey  = g_dochis_tm-relatkey.
    l_subrc             = 0.
  ELSE.
    l_subrc             = 4.
    ADD 1 TO g_node_seq.
    it_dochis-nodekey = g_node_seq.
  ENDIF.

  l_relatkey =  g_node_seq.

  IF g_docty EQ 'IP'.
    IF ls_ztitip1-iipno EQ g_docno AND
       ls_ztitip1-amdsq EQ g_amdsq.
      g_set_nodekey = it_dochis-nodekey.
    ENDIF.
  ENDIF.

  IF l_subrc NE 0.
    COLLECT it_dochis.
  ENDIF.

  SELECT *
    FROM ztitip1
   WHERE iipno   EQ   ls_ztitip1-iipno
     AND amdsq   NE   '00'.
*     AND amdsq   NE   ls_ZTITIP1-amdsq.

    MOVE: 'I'                 TO     it_dochis-doccl,
          ztitip1-iipno      TO     it_dochis-docnb,
          ztitip1-amdsq      TO     it_dochis-amdsq,
          ztitip1-iisdt      TO     it_dochis-docdt,
          ztitip1-iivatc     TO     it_dochis-waers,
          ztitip1-iivat      TO     it_dochis-docat,
          g_node_seq          TO     it_dochis-nodekey,
          ztitip1-ispno      TO     it_dochis-docnm,
          l_relatkey          TO     it_dochis-relatkey.
*          g_dochis_lc-nodekey TO     it_dochis-relatkey.

    READ TABLE it_dochis INTO g_dochis_tm
                         WITH KEY doccl    = it_dochis-doccl
                                  docnb    = it_dochis-docnb
                                  amdsq    = it_dochis-amdsq.
*                                relatkey = it_dochis-relatkey.
    IF sy-subrc EQ 0.
      it_dochis-nodekey   = g_dochis_tm-nodekey.
      it_dochis-relatkey  = g_dochis_tm-relatkey.
      l_subrc             = 0.
    ELSE.
      ADD 1 TO g_node_seq.
      it_dochis-nodekey   = g_node_seq.
      l_subrc             = 4.
    ENDIF.

    IF g_docty EQ 'IP'.
      IF ztitip1-iipno EQ g_docno AND
         ztitip1-amdsq EQ g_amdsq.
        g_set_nodekey = it_dochis-nodekey.
      ENDIF.
    ENDIF.
    IF l_subrc NE 0.
      COLLECT it_dochis.
    ENDIF.
  ENDSELECT.

ENDFORM.                               " ZTIL01_GET_ZTITIP1
*&---------------------------------------------------------------------*
*&      Form  ZTIL01_GET_ZTIVIV01
*&---------------------------------------------------------------------*
* 선급금.
*----------------------------------------------------------------------*
FORM ztil01_get_ztiviv01  USING  name         LIKE ldbn-ldbnode
                                 ls_ztiviv01  LIKE ztiviv01
                                 mode         TYPE c
                                 selected     TYPE c.

*  add 1 to g_node_seq.

  MOVE-CORRESPONDING ls_ztiviv01 TO ztiviv01.

*> I/V 레벨.
  CLEAR: it_dochis.
  MOVE: 'Z'                   TO     it_dochis-doccl,
        ls_ztiviv01-ivono     TO     it_dochis-docnb,
        ls_ztiviv01-civdt     TO     it_dochis-docdt,
        ls_ztiviv01-refwr     TO     it_dochis-docat,
        ls_ztiviv01-waers     TO     it_dochis-waers,
        g_node_seq            TO     it_dochis-nodekey,
        ls_ztiviv01-ivnum     TO     it_dochis-docnm,
        g_dochis_lc-nodekey   TO     it_dochis-relatkey.

  READ TABLE it_dochis INTO g_dochis_tm
                       WITH KEY doccl    = it_dochis-doccl
                                docnb    = it_dochis-docnb
                                relatkey = it_dochis-relatkey.
  IF sy-subrc EQ 0.
    it_dochis-nodekey = g_dochis_tm-nodekey.
  ELSE.
    ADD 1 TO g_node_seq.
    it_dochis-nodekey = g_node_seq.
  ENDIF.

  IF g_docty EQ 'IV'.
    IF ls_ztiviv01-ivono EQ g_docno.
      g_set_nodekey = it_dochis-nodekey.
    ENDIF.
  ENDIF.

  COLLECT it_dochis.

ENDFORM.                               " ZTIL01_GET_ZTIVIV01
*&---------------------------------------------------------------------*
*&      Form  ZTIL01_GET_ZTIVBL00
*&---------------------------------------------------------------------*
FORM ztil01_get_ztivbl00  USING  name         LIKE ldbn-ldbnode
                                 ls_ztivbl00  LIKE ztivbl00
                                 mode         TYPE c
                                 selected     TYPE c.

  DATA: l_blmng   TYPE ztiblmng.
*  add 1 to g_node_seq.

  MOVE-CORRESPONDING ls_ztivbl00 TO ztivbl00.
*  break-point.
*> B/L 레벨.
  CLEAR: it_dochis.
  MOVE: 'B'                 TO     it_dochis-doccl,
        ls_ztivbl00-iblno   TO     it_dochis-docnb,
        ls_ztivbl00-bldat   TO     it_dochis-docdt,
        ls_ztivbl00-refwr   TO     it_dochis-docat,
        ls_ztivbl00-waers   TO     it_dochis-waers,
        g_node_seq          TO     it_dochis-nodekey,
        ls_ztivbl00-blnum   TO     it_dochis-docnm,
        g_dochis_lc-nodekey TO     it_dochis-relatkey.

*> 선급금액 누락시킴.
*  it_dochis-docat = it_dochis-docat -  ls_ztivbl00-ppamt.

**> 정가 계산.
*    CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
*      EXPORTING
*        peinh = ZTIvpo01-peinh
*        bpumz = ZTIvpo01-bpumz
*        bpumn = ZTIvpo01-bpumn
*        menge = l_rqmng
*        netpr = ZTIvpo01-netpr
*      CHANGING
*        netwr = l_netwr.

  READ TABLE it_dochis INTO g_dochis_tm
                       WITH KEY doccl    = it_dochis-doccl
                                docnb    = it_dochis-docnb
                                relatkey = it_dochis-relatkey.
  IF sy-subrc EQ 0.
    it_dochis-nodekey = g_dochis_tm-nodekey.
  ELSE.
    ADD 1 TO g_node_seq.
    it_dochis-nodekey = g_node_seq.
  ENDIF.

  IF g_docty EQ 'BL'.
    IF ls_ztivbl00-iblno EQ g_docno.
      g_set_nodekey = it_dochis-nodekey.
    ENDIF.
  ENDIF.

  g_dochis_bl = it_dochis.

  COLLECT it_dochis.

ENDFORM.                               " ZTIL01_GET_ZTIVBL00
*&---------------------------------------------------------------------*
*&      Form  ZTIL01_GET_ZTIVIV00
*&---------------------------------------------------------------------*
* 송장.
*----------------------------------------------------------------------*
FORM ztil01_get_ztiviv00  USING  name         LIKE ldbn-ldbnode
                                 ls_ztiviv00  LIKE ztiviv00
                                 mode         TYPE c
                                 selected     TYPE c.

*  add 1 to g_node_seq.

  MOVE-CORRESPONDING ls_ztiviv00 TO ztiviv00.

*> I/V 레벨.
  CLEAR: it_dochis.
  MOVE: 'V'                   TO     it_dochis-doccl,
        ls_ztiviv00-ivono     TO     it_dochis-docnb,
        ls_ztiviv00-civdt     TO     it_dochis-docdt,
*        ls_ztiviv00-refwr     TO     it_dochis-docat,
        ls_ztiviv00-ivamti    TO     it_dochis-docat,
        ls_ztiviv00-waers     TO     it_dochis-waers,
        g_node_seq            TO     it_dochis-nodekey,
        ls_ztiviv00-ivnum     TO     it_dochis-docnm,
        g_dochis_bl-nodekey   TO     it_dochis-relatkey.

  READ TABLE it_dochis INTO g_dochis_tm
                       WITH KEY doccl    = it_dochis-doccl
                                docnb    = it_dochis-docnb
                                relatkey = it_dochis-relatkey.
  IF sy-subrc EQ 0.
    it_dochis-nodekey = g_dochis_tm-nodekey.
  ELSE.
    ADD 1 TO g_node_seq.
    it_dochis-nodekey = g_node_seq.
  ENDIF.

  IF g_docty EQ 'IV'.
    IF ls_ztiviv00-ivono EQ g_docno.
      g_set_nodekey = it_dochis-nodekey.
    ENDIF.
  ENDIF.

  g_dochis_iv = it_dochis.

  COLLECT it_dochis.

ENDFORM.                               " ZTIL01_GET_ZTIVIV00
*&---------------------------------------------------------------------*
*&      Form  ZTIL01_GET_ZTIVPN00
*&---------------------------------------------------------------------*
*       NOTICE.
*----------------------------------------------------------------------*
FORM ztil01_get_ztivpn00  USING  name         LIKE ldbn-ldbnode
                                 ls_ztivpn00  LIKE ztivpn00
                                 mode         TYPE c
                                 selected     TYPE c.

*  add 1 to g_node_seq.

  MOVE-CORRESPONDING ls_ztivpn00 TO ztivpn00.

*> Notice 레벨.
  CLEAR: it_dochis.
  MOVE: 'Y'                   TO     it_dochis-doccl,
        ls_ztivpn00-pntno     TO     it_dochis-docnb,
        ls_ztivpn00-pntdt     TO     it_dochis-docdt,
        ls_ztivpn00-netwr     TO     it_dochis-docat,
        ls_ztivpn00-waers     TO     it_dochis-waers,
        g_node_seq            TO     it_dochis-nodekey,
        ls_ztivpn00-blnum     TO     it_dochis-docnm,
        g_dochis_iv-nodekey   TO     it_dochis-relatkey.

  READ TABLE it_dochis INTO g_dochis_tm
                       WITH KEY doccl    = it_dochis-doccl
                                docnb    = it_dochis-docnb
                                relatkey = it_dochis-relatkey.
  IF sy-subrc EQ 0.
    it_dochis-nodekey = g_dochis_tm-nodekey.
  ELSE.
    ADD 1 TO g_node_seq.
    it_dochis-nodekey = g_node_seq.
  ENDIF.

  IF g_docty EQ 'PN'.
    IF ls_ztivpn00-pntno EQ g_docno.
      g_set_nodekey = it_dochis-nodekey.
    ENDIF.
  ENDIF.

  COLLECT it_dochis.

ENDFORM.                               " ZTIL01_GET_ZTIVPN00

*&---------------------------------------------------------------------*
*&      Form  ZTIL01_GET_ZTITLG1
*&---------------------------------------------------------------------*
* L/G.
*----------------------------------------------------------------------*
FORM ztil01_get_ztitlg1  USING  name         LIKE ldbn-ldbnode
                                 ls_ztitlg1  LIKE ztitlg1
                                 mode         TYPE c
                                 selected     TYPE c.

  DATA: l_subrc LIKE sy-subrc.

  MOVE-CORRESPONDING ls_ztitlg1 TO ztitlg1.

*> L/G 레벨.
  CLEAR: it_dochis.
  MOVE: 'L'                   TO     it_dochis-doccl,
        ls_ztitlg1-ilgno     TO     it_dochis-docnb,
        ls_ztitlg1-glgdt     TO     it_dochis-docdt,
        ls_ztitlg1-givat     TO     it_dochis-docat,
        ls_ztitlg1-givatc    TO     it_dochis-waers,
        g_node_seq            TO     it_dochis-nodekey,
        ls_ztitlg1-glgno     TO     it_dochis-docnm,
        g_dochis_bl-nodekey   TO     it_dochis-relatkey.

  READ TABLE it_dochis INTO g_dochis_tm
                       WITH KEY doccl    = it_dochis-doccl
                                docnb    = it_dochis-docnb
                                relatkey = it_dochis-relatkey.
  IF sy-subrc EQ 0.
    it_dochis-nodekey = g_dochis_tm-nodekey.
    l_subrc = 4.
  ELSE.
    l_subrc = 0.
    ADD 1 TO g_node_seq.
    it_dochis-nodekey = g_node_seq.
  ENDIF.

  IF g_docty EQ 'LG'.
    IF ls_ztitlg1-iblno EQ g_docno.
      g_set_nodekey = it_dochis-nodekey.
    ENDIF.
  ENDIF.

  IF l_subrc EQ 0.
    COLLECT it_dochis.
  ENDIF.

ENDFORM.                               " ZTIL01_GET_ZTITLG1
*&---------------------------------------------------------------------*
*&      Form  ZTIL01_GET_ZTITBSK
*&---------------------------------------------------------------------*
*       반입예정정보.
*----------------------------------------------------------------------*
FORM ztil01_get_ztitbsk  USING  name         LIKE ldbn-ldbnode
                                 ls_ztitbsk  LIKE ztitbsk
                                 mode         TYPE c
                                 selected     TYPE c.

  DATA: l_subrc LIKE sy-subrc.

  MOVE-CORRESPONDING ls_ztitbsk TO ztitbsk.

*> 반입예정정보 레벨.
  CLEAR: it_dochis.
  MOVE: 'S'                   TO     it_dochis-doccl,
        ls_ztitbsk-ibsno     TO     it_dochis-docnb,
        ls_ztitbsk-brcdt     TO     it_dochis-docdt,
        ztivbl00-ivamt        TO     it_dochis-docat,
        g_dochis_bl-waers     TO     it_dochis-waers,
        g_node_seq            TO     it_dochis-nodekey,
        ls_ztitbsk-btrno     TO     it_dochis-docnm,
        g_dochis_bl-nodekey   TO     it_dochis-relatkey.

  READ TABLE it_dochis INTO g_dochis_tm
                       WITH KEY doccl    = it_dochis-doccl
                                docnb    = it_dochis-docnb
                                relatkey = it_dochis-relatkey.
  IF sy-subrc EQ 0.
    it_dochis-nodekey = g_dochis_tm-nodekey.
    l_subrc = 4.
  ELSE.
    ADD 1 TO g_node_seq.
    it_dochis-nodekey = g_node_seq.
    l_subrc = 0.
  ENDIF.

  IF g_docty EQ 'BS'.
    IF ls_ztitbsk-ibsno EQ g_docno.
      g_set_nodekey = it_dochis-nodekey.
    ENDIF.
  ENDIF.

  g_dochis_bs = it_dochis.
  IF l_subrc EQ 0.
    COLLECT it_dochis.
  ENDIF.

ENDFORM.                               " ZTIL01_GET_ZTITBSK
*&---------------------------------------------------------------------*
*&      Form  ZTIL01_GET_ZTITBIK
*&---------------------------------------------------------------------*
*       반입신고
*----------------------------------------------------------------------*
FORM ztil01_get_ztitbik  USING  name         LIKE ldbn-ldbnode
                                 ls_ztitbik  LIKE ztitbik
                                 mode         TYPE c
                                 selected     TYPE c.

  DATA: l_subrc LIKE sy-subrc.

  MOVE-CORRESPONDING ls_ztitbik TO ztitbik.

*> 반입정보 레벨.
  CLEAR: it_dochis.
  MOVE: 'U'                   TO     it_dochis-doccl,
        ls_ztitbik-ibino     TO     it_dochis-docnb,
        ls_ztitbik-bindt     TO     it_dochis-docdt,
        ztivbl00-ivamt        TO     it_dochis-docat,
        g_dochis_bs-waers     TO     it_dochis-waers,
        g_node_seq            TO     it_dochis-nodekey,
        ls_ztitbik-bidnr     TO     it_dochis-docnm,
        g_dochis_bs-nodekey   TO     it_dochis-relatkey.

  READ TABLE it_dochis INTO g_dochis_tm
                       WITH KEY doccl    = it_dochis-doccl
                                docnb    = it_dochis-docnb
                                relatkey = it_dochis-relatkey.
  IF sy-subrc EQ 0.
    it_dochis-nodekey = g_dochis_tm-nodekey.
    l_subrc = 4.
  ELSE.
    ADD 1 TO g_node_seq.
    it_dochis-nodekey = g_node_seq.
    l_subrc = 0.
  ENDIF.

  IF g_docty EQ 'BI'.
    IF ls_ztitbik-ibino EQ g_docno.
      g_set_nodekey = it_dochis-nodekey.
    ENDIF.
  ENDIF.

  g_dochis_bi = it_dochis.

  IF l_subrc EQ 0.
    COLLECT it_dochis.
  ENDIF.

ENDFORM.                               " ZTIL01_GET_ZTITBIK
*&---------------------------------------------------------------------*
*&      Form  ZTIL01_GET_ZTITBOK
*&---------------------------------------------------------------------*
*       반출신고
*----------------------------------------------------------------------*
FORM ztil01_get_ztitbok  USING  name         LIKE ldbn-ldbnode
                                 ls_ztitbok  LIKE ztitbok
                                 mode         TYPE c
                                 selected     TYPE c.

  DATA: l_subrc LIKE sy-subrc.

  MOVE-CORRESPONDING ls_ztitbok TO ztitbok.

*> 반출정보 레벨.
  CLEAR: it_dochis.
  MOVE: 'T'                   TO     it_dochis-doccl,
        ls_ztitbok-ibono     TO     it_dochis-docnb,
        ls_ztitbok-boudt     TO     it_dochis-docdt,
        ztivbl00-ivamt        TO     it_dochis-docat,
        g_dochis_bi-waers     TO     it_dochis-waers,
        g_node_seq            TO     it_dochis-nodekey,
        ls_ztitbok-bodnr     TO     it_dochis-docnm,
        g_dochis_bi-nodekey   TO     it_dochis-relatkey.

  READ TABLE it_dochis INTO g_dochis_tm
                       WITH KEY doccl    = it_dochis-doccl
                                docnb    = it_dochis-docnb
                                relatkey = it_dochis-relatkey.
  IF sy-subrc EQ 0.
    it_dochis-nodekey = g_dochis_tm-nodekey.
    l_subrc = 4.
  ELSE.
    ADD 1 TO g_node_seq.
    it_dochis-nodekey = g_node_seq.
    l_subrc = 0.
  ENDIF.

  IF g_docty EQ 'BO'.
    IF ls_ztitbok-ibono EQ g_docno.
      g_set_nodekey = it_dochis-nodekey.
    ENDIF.
  ENDIF.

  IF l_subrc EQ 0.
    COLLECT it_dochis.
  ENDIF.

ENDFORM.                               " ZTIL01_GET_ZTITBOK

*&---------------------------------------------------------------------*
*&      Form  ZTIL01_GET_ZTIVCR00
*&---------------------------------------------------------------------*
*       수입신고의뢰
*----------------------------------------------------------------------*
FORM ztil01_get_ztivcr00  USING  name         LIKE ldbn-ldbnode
                                 ls_ztivcr00  LIKE ztivcr00
                                 mode         TYPE c
                                 selected     TYPE c.

*> add 1 to g_node_seq.
  MOVE-CORRESPONDING ls_ztivcr00 TO ztivcr00.

*> 통관레벨.
  CLEAR: it_dochis.

  MOVE: 'R'                   TO     it_dochis-doccl,
        ls_ztivcr00-iccno     TO     it_dochis-docnb,
        ls_ztivcr00-iccsq     TO     it_dochis-amdsq,
        ls_ztivcr00-cdcdt     TO     it_dochis-docdt,
        ls_ztivcr00-refwr     TO     it_dochis-docat,
        ls_ztivcr00-cpyatc    TO     it_dochis-waers,
        g_node_seq            TO     it_dochis-nodekey,
        ls_ztivcr00-cdrno     TO     it_dochis-docnm,
        g_dochis_bl-nodekey   TO     it_dochis-relatkey.

  IF ls_ztivcr00-iccsq NE '00'.
    MOVE g_dochis_cr-nodekey   TO     it_dochis-relatkey.
  ENDIF.

  READ TABLE it_dochis INTO g_dochis_tm
                       WITH KEY doccl    = it_dochis-doccl
                                docnb    = it_dochis-docnb
                                amdsq    = it_dochis-amdsq
                                relatkey = it_dochis-relatkey.
  IF sy-subrc EQ 0.
    it_dochis-nodekey = g_dochis_tm-nodekey.
  ELSE.
    ADD 1 TO g_node_seq.
    it_dochis-nodekey = g_node_seq.
  ENDIF.

  IF g_docty EQ 'CR'.
    IF ls_ztivcr00-iccno EQ g_docno AND
       ls_ztivcr00-iccsq EQ g_amdsq.
      g_set_nodekey = it_dochis-nodekey.
    ENDIF.
  ENDIF.

  g_dochis_cr = it_dochis.

  COLLECT it_dochis.

ENDFORM.                               " ZTIL01_GET_ZTIVCR00
*&---------------------------------------------------------------------*
*&      Form  ZTIL01_GET_ZTIVCC00
*&---------------------------------------------------------------------*
*       통관
*----------------------------------------------------------------------*
FORM ztil01_get_ztivcc00  USING  name         LIKE ldbn-ldbnode
                                 ls_ztivcc00  LIKE ztivcc00
                                 mode         TYPE c
                                 selected     TYPE c.

*> add 1 to g_node_seq.
  MOVE-CORRESPONDING ls_ztivcc00 TO ztivcc00.

*> 통관레벨.
  CLEAR: it_dochis.
  MOVE: 'C'                   TO     it_dochis-doccl,
        ls_ztivcc00-iccno     TO     it_dochis-docnb,
        ls_ztivcc00-iccsq     TO     it_dochis-amdsq,
        ls_ztivcc00-cdrdt     TO     it_dochis-docdt,
        ls_ztivcc00-refwr     TO     it_dochis-docat,
        ls_ztivcc00-cpyatc    TO     it_dochis-waers,
        g_node_seq            TO     it_dochis-nodekey,
        ls_ztivcc00-cdcno     TO     it_dochis-docnm,
        g_dochis_bl-nodekey   TO     it_dochis-relatkey.

  IF ls_ztivcc00-iccsq NE '00'.
    MOVE g_dochis_cc-nodekey   TO     it_dochis-relatkey.
  ENDIF.


  READ TABLE it_dochis INTO g_dochis_tm
                       WITH KEY doccl    = it_dochis-doccl
                                docnb    = it_dochis-docnb
                                amdsq    = it_dochis-amdsq
                                relatkey = it_dochis-relatkey.
  IF sy-subrc EQ 0.
    it_dochis-nodekey = g_dochis_tm-nodekey.
  ELSE.
    ADD 1 TO g_node_seq.
    it_dochis-nodekey = g_node_seq.
  ENDIF.

  IF g_docty EQ 'CC'.
    IF ls_ztivcc00-iccno EQ g_docno AND
       ls_ztivcc00-iccsq EQ g_amdsq.
      g_set_nodekey = it_dochis-nodekey.
    ENDIF.
  ENDIF.

  g_dochis_cc = it_dochis.

  COLLECT it_dochis.

ENDFORM.                               " ZTIL01_GET_ZTIVCC00

*&---------------------------------------------------------------------*
*&      Form  ZTIL01_GET_ZTIVGR00
*&---------------------------------------------------------------------*
*       입고
*----------------------------------------------------------------------*
FORM ztil01_get_ztivgr00  USING  name         LIKE ldbn-ldbnode
                                 ls_ztivgr00  LIKE ztivgr00
                                 mode         TYPE c
                                 selected     TYPE c.

  MOVE-CORRESPONDING ls_ztivgr00 TO ztivgr00.

*> 입고레벨.
  CLEAR: it_dochis.
  MOVE: 'G'                   TO     it_dochis-doccl,
        ls_ztivgr00-igrno     TO     it_dochis-docnb,
        ls_ztivgr00-budat     TO     it_dochis-docdt,
        g_dochis_cc-waers     TO     it_dochis-waers,
        g_node_seq            TO     it_dochis-nodekey,
        ls_ztivgr00-bktxt     TO     it_dochis-docnm,
        g_dochis_cc-nodekey   TO     it_dochis-relatkey.
*> 입고금액 select.
  SELECT wrbtr
    INTO it_dochis-docat
    FROM ekbe UP TO 1 ROWS
   WHERE ebeln  EQ  ls_ztivgr00-ebeln
     AND ebelp  EQ  ls_ztivgr00-ebelp
     AND vgabe  EQ  '1'
     AND gjahr  EQ  ls_ztivgr00-mjahr
     AND belnr  EQ  ls_ztivgr00-mblnr.
  ENDSELECT.

  READ TABLE it_dochis INTO g_dochis_tm
                       WITH KEY doccl    = it_dochis-doccl
                                docnb    = it_dochis-docnb
                                relatkey = it_dochis-relatkey.
  IF sy-subrc EQ 0.
    it_dochis-nodekey = g_dochis_tm-nodekey.
  ELSE.
    ADD 1 TO g_node_seq.
    it_dochis-nodekey = g_node_seq.
  ENDIF.

  IF g_docty EQ 'GR'.
    IF ls_ztivgr00-igrno EQ g_docno.
      g_set_nodekey = it_dochis-nodekey.
    ENDIF.
  ENDIF.

  COLLECT it_dochis.

ENDFORM.                               " ZTIL01_GET_ZTIVGR00
*&---------------------------------------------------------------------*
*&      Form  handle_double_click
*&---------------------------------------------------------------------*
FORM handle_double_click  USING  p_row     TYPE lvc_s_row
                                 p_column  TYPE lvc_s_col.

  DATA: l_htype LIKE dd01v-datatype.

  CALL FUNCTION 'Z_TI_NUMBER_CHECK'
    EXPORTING
      string_in        = p_row-index
   IMPORTING
*     STRING_OUT       =
     htype            = l_htype.
  IF l_htype EQ 'CHAR'.
    EXIT.
  ENDIF.

  READ TABLE it_costdoc INDEX p_row-index.

  CHECK sy-subrc = 0.

  CASE p_column.
    WHEN 'REFNO'.
      CASE it_costdoc-expgr.
        WHEN 'L'.
          CLEAR: it_costdoc-amdsq.
          SELECT lstas
            INTO it_costdoc-amdsq
            FROM ztitrqk
           WHERE reqno  EQ it_costdoc-refno.
          ENDSELECT.
          PERFORM  display_import_document(ztir0000)
                                          USING it_costdoc-refno
                                                it_costdoc-amdsq
                                                '00000'.
        WHEN 'I'.   "> 보험 문서.
          PERFORM  display_ip_document(ztir0000)
                                          USING it_costdoc-refno
                                                it_costdoc-amdsq.
        WHEN 'B'.   "> B/L 문서.
          PERFORM  display_bl_document(ztir0000)
                                          USING it_costdoc-refno
                                                '00000'.
        WHEN 'C'.   "> C/C 문서.
          PERFORM  display_cc_document(ztir0000)
                                          USING it_costdoc-refno
                                                it_costdoc-amdsq.
        WHEN 'R'.   "> C/C 문서.
          PERFORM  display_cr_document(ztir0000)
                                          USING it_costdoc-refno
                                                it_costdoc-amdsq.
        WHEN OTHERS.
      ENDCASE.
*    WHEN 'BELNR'.
    WHEN OTHERS.
      PERFORM display_cs_document(ztir0000)
                            USING it_costdoc-icsno
                                  it_costdoc-bukrs.
  ENDCASE.

ENDFORM.                    "handle_double_click
*&---------------------------------------------------------------------*
*&      Form  handle_hotspot_click
*&---------------------------------------------------------------------*
FORM handle_hotspot_click  USING e_row_id    TYPE lvc_s_row
                                 e_column_id TYPE lvc_s_col.

  DATA: l_htype LIKE dd01v-datatype.

  CALL FUNCTION 'Z_TI_NUMBER_CHECK'
    EXPORTING
      string_in        = e_row_id-index
   IMPORTING
*     STRING_OUT       =
     htype            = l_htype.
  IF l_htype EQ 'CHAR'.
    EXIT.
  ENDIF.

  READ TABLE it_costdoc INDEX e_row_id-index.

  CHECK sy-subrc = 0.

  CASE e_column_id-fieldname.
    WHEN 'ICSNO' OR 'ICSSQ'.
      PERFORM display_cs_document(ztir0000)
                            USING it_costdoc-icsno
                                  it_costdoc-bukrs.
    WHEN 'BELNR'.
      PERFORM display_liv_document(ztir9000)
                            USING it_costdoc-belnr
                                  it_costdoc-gjahr
                                  it_costdoc-bukrs.

  ENDCASE.

ENDFORM.                    "handle_hotspot_click
