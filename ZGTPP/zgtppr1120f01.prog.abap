*&---------------------------------------------------------------------*
*&  Include           ZGTPPR1120F01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  function_for_confirm
*&---------------------------------------------------------------------*
FORM function_for_confirm  USING p_title
                                 p_text1
                                 p_text2
                        CHANGING p_answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      titel     = p_title
      textline1 = p_text1
      textline2 = p_text2
    IMPORTING
      answer    = p_answer.
ENDFORM.                    " function_for_confirm

*&---------------------------------------------------------------------*
*&      Form  read_data_from_zppt0030
*&---------------------------------------------------------------------*
FORM read_data_from_zppt0030.

  SELECT a~seqno    a~atnam    a~sngle    a~multi
         a~inclu    a~range    c~atbez
    INTO CORRESPONDING FIELDS OF TABLE gt_atnam
    FROM zppt0030 AS a  INNER JOIN cabn AS b
                                ON a~atnam = b~atnam
                        INNER JOIN cabnt AS c
                                ON b~atinn = c~atinn
   WHERE a~werks  = gp_werks
     AND a~spgcd  = gv_spgcd
     AND a~procd  = gp_procd
     AND a~stdtm  = 'X'
     AND c~spras  = sy-langu.

  SELECT a~seqno    a~atnam    a~sngle    a~multi
         a~inclu    a~range    c~atbez
    INTO CORRESPONDING FIELDS OF TABLE gt_btnam
    FROM zppt0030 AS a  INNER JOIN cabn AS b
                                ON a~atnam = b~atnam
                        INNER JOIN cabnt AS c
                                ON b~atinn = c~atinn
   WHERE a~werks  = gp_werks
     AND a~spgcd  = gv_spgcd
     AND a~procd  = gp_procd
     AND a~remfl  = 'X'
     AND c~spras  = sy-langu.

  SELECT a~seqno    a~atnam    a~sngle    a~multi
         a~inclu    a~range    c~atbez
    INTO CORRESPONDING FIELDS OF TABLE gt_ctnam
    FROM zppt0030 AS a  INNER JOIN cabn AS b
                                ON a~atnam = b~atnam
                        INNER JOIN cabnt AS c
                                ON b~atinn = c~atinn
   WHERE a~werks  = gp_werks
     AND a~spgcd  = gv_spgcd
     AND a~procd  = gp_procd
     AND a~spdfl  = 'X'
     AND c~spras  = sy-langu.

  SORT: gt_atnam  BY seqno,
        gt_btnam  BY seqno,
        gt_ctnam  BY seqno.

  DESCRIBE TABLE: gt_atnam  LINES gv_210cols,
                  gt_btnam  LINES gv_220cols,
                  gt_ctnam  LINES gv_230cols.

ENDFORM.                    " read_data_from_zppt0030

*&---------------------------------------------------------------------*
*&      Form  fill_head_to_tc_200
*&---------------------------------------------------------------------*
FORM fill_head_to_tc_200.
  CLEAR: gv_num2, gr_atnam[], gr_btnam[], gr_ctnam[].

  READ TABLE gt_mapl  INDEX 1.

  PERFORM function_get_classification  USING gt_mapl-matnr.

  LOOP AT gt_atnam.
    gv_num2 = gv_num2 + 1.
    gt_atnam-seqno = gv_num2.

    IF gt_atnam-atbez IS INITIAL.
      CLEAR: gt_ausp.
      READ TABLE gt_ausp  WITH KEY atnam = gt_atnam-atnam
                                  BINARY SEARCH.
      gt_atnam-atbez = gt_ausp-atbez.
    ENDIF.

    MODIFY gt_atnam.

    gr_atnam-sign = 'I'.
    gr_atnam-option = 'EQ'.
    gr_atnam-low = gt_atnam-atnam.
    APPEND gr_atnam.
  ENDLOOP.

  CLEAR: gv_num2.

  LOOP AT gt_btnam.
    gv_num2 = gv_num2 + 1.
    gt_btnam-seqno = gv_num2.

    IF gt_btnam-atbez IS INITIAL.
      CLEAR: gt_ausp.
      READ TABLE gt_ausp  WITH KEY atnam = gt_btnam-atnam
                                  BINARY SEARCH.
      gt_btnam-atbez = gt_ausp-atbez.
    ENDIF.

    MODIFY gt_btnam.

    gr_btnam-sign = 'I'.
    gr_btnam-option = 'EQ'.
    gr_btnam-low = gt_btnam-atnam.
    APPEND gr_btnam.
  ENDLOOP.

  CLEAR: gv_num2.

  LOOP AT gt_ctnam.
    gv_num2 = gv_num2 + 1.
    gt_ctnam-seqno = gv_num2.

    IF gt_ctnam-atbez IS INITIAL.
      CLEAR: gt_ausp.
      READ TABLE gt_ausp  WITH KEY atnam = gt_ctnam-atnam
                                  BINARY SEARCH.
      gt_ctnam-atbez = gt_ausp-atbez.
    ENDIF.

    MODIFY gt_ctnam.

    gr_ctnam-sign = 'I'.
    gr_ctnam-option = 'EQ'.
    gr_ctnam-low = gt_ctnam-atnam.
    APPEND gr_ctnam.
  ENDLOOP.
ENDFORM.                    " fill_head_to_tc_200

*&---------------------------------------------------------------------*
*&      Form  read_data_from_tables
*&---------------------------------------------------------------------*
FORM read_data_from_tables.

*& C20081223_76506
*& 2008.12.24 삭제 자재 제외

  SELECT a~matnr    c~maktx    d~plnty    d~plnnr
         d~plnal    d~zkriz    a~dispo    b~dpcbt
         a~beskz    a~sobsl    a~dispo    a~werks
    INTO CORRESPONDING FIELDS OF TABLE gt_mapl
    FROM marc AS a  INNER JOIN mara AS b
                            ON a~matnr = b~matnr
                    INNER JOIN makt AS c
                            ON a~matnr = c~matnr
                     LEFT JOIN mapl AS d
                            ON a~werks = d~werks  AND
                               a~matnr = d~matnr  AND
                               d~plnty = 'N'      AND
                               d~loekz = space
   WHERE a~werks  = gp_werks
     AND a~dispo IN gr_dispo
     AND a~matnr IN gs_matnr
     AND b~spart IN gs_spart
     AND b~mtart IN gs_mtart
     AND b~matkl IN gr_matkl
     AND a~lvorm  = space
     AND b~lvorm  = space
     AND c~spras  = sy-langu
     AND a~mmsta NE 'ZD'     "2026.06.16 KSW
     AND a~beskz NE 'F'.

  IF gp_new = 'X'.                  " 신규
    DELETE gt_mapl  WHERE NOT plnnr IS INITIAL.
  ELSEIF gp_ext = 'X'.              " 등록
    DELETE gt_mapl  WHERE plnnr IS INITIAL.
  ENDIF.
ENDFORM.                    " read_data_from_tables

*&---------------------------------------------------------------------*
*&      Form  read_data_from_plpo
*&---------------------------------------------------------------------*
FORM read_data_from_plpo.
  DATA: BEGIN OF lt_data  OCCURS 0,
          basmn TYPE zpps010-basmn,
          meins TYPE zpps010-meins,
          ruezt TYPE zpps010-ruezt,
          optim TYPE zpps010-optim,
          wktim TYPE zpps010-wktim,
          meinh TYPE zpps010-meinh,
          plnfl TYPE zpps010-plnfl,
          zaehl TYPE zpps010-zaehl,
          vornr TYPE zpps010-vornr,
          arbpl TYPE zpps010-arbpl,
          tuhnk TYPE zpps010-fhank,
          fhank TYPE zpps010-fhank,
          qmmgn TYPE zpps010-qmmgn,
          aznor TYPE kako-aznor,      " 개별생산능력수
          rdrnp TYPE zppt0041-rdrnp,
          usr05 TYPE plpo-usr05,
          use05 TYPE plpo-use05,
        END   OF lt_data.

  LOOP AT gt_mapl  INTO gw_mapl.
    CLEAR: gw_data, lt_data, lt_data[].

    MOVE-CORRESPONDING gw_mapl TO gw_data.

    PERFORM read_bom_prod_version.         " 생산버젼을 읽는다.

    IF gw_mapl-plnnr IS NOT INITIAL.
      SELECT a~bmsch AS basmn      a~meinh AS meins
             a~vgw01 AS ruezt      a~vgw02 AS optim
             a~vgw06 AS wktim      a~vge01 AS meinh
             b~plnfl    b~zaehl    a~vornr    e~arbpl
             a~/sapmp/max_fertl AS fhank
             a~/sapmp/fix_as_j  AS qmmgn
             a~/sapmp/max_fertl AS tuhnk
             a~usr04 AS rdrnp
             a~splim AS aznor
             a~usr05
             a~use05
        INTO CORRESPONDING FIELDS OF TABLE lt_data
        FROM plpo AS a  INNER JOIN plas AS b
                                ON a~plnty = b~plnty  AND
                                   a~plnnr = b~plnnr  AND
                                   a~plnkn = b~plnkn  AND
                                   a~zaehl = b~zaehl
                        INNER JOIN crhd AS e
                                ON a~arbid = e~objid
                        INNER JOIN crtx AS f
                                ON e~objty = f~objty  AND
                                   e~objid = f~objid
                        INNER JOIN plfl AS g
                                ON b~plnty = g~plnty    AND
                                   b~plnnr = g~plnnr    AND
                                   b~plnal = g~plnal    AND
                                   b~plnfl = g~plnfl    AND
                                   g~loekz = space
       WHERE a~plnty  = gw_mapl-plnty
         AND a~plnnr  = gw_mapl-plnnr
         AND b~plnal  = gw_mapl-plnal
         AND b~loekz  = space
         AND e~objty  = 'A'             " 작업장
         AND f~spras  = sy-langu.

      gw_data-indi = '등록'.

      LOOP AT lt_data.
        MOVE-CORRESPONDING lt_data TO gw_data.
        APPEND gw_data TO gt_data.
      ENDLOOP.
    ELSE.
      gw_data-indi = '신규'.
      APPEND gw_data TO gt_data.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " read_data_from_plpo

*&---------------------------------------------------------------------*
*&      Form  setting_data_for_ranges
*&---------------------------------------------------------------------*
FORM setting_data_for_ranges.
  CLEAR: gr_dispo, gr_matkl, gr_dispo[], gr_matkl[].

  gr_matkl-sign = 'I'.
  gr_matkl-option = 'CP'.
  CONCATENATE '+++-' gp_procd '*'  INTO gr_matkl-low.
  APPEND gr_matkl.

  gr_dispo-sign = 'I'.

  IF gp_dispo+2(1) = '*'.
    gr_dispo-option = 'CP'.
  ELSE.
    gr_dispo-option = 'EQ'.
  ENDIF.

  gr_dispo-low = gp_dispo.
  APPEND gr_dispo.

  gv_spgcd = gp_dispo(2).

  IF ( gp_werks = '1202' OR
       gp_werks = '1404' ) AND
     gp_dispo(2) = 'TB' AND
     gp_procd = 'CRL'.
    gv_crlyn = 'X'.
  ENDIF.

  gw_bdcparams-dismode  = 'N'.   " 처리모드
  gw_bdcparams-updmode  = 'L'.   " 갱신세션
  gw_bdcparams-cattmode = ' '.   " CATT모드
  gw_bdcparams-defsize  = 'X'.   " 기본화면
  gw_bdcparams-racommit = ' '.   " COMMAND 이후 지속
  gw_bdcparams-nobinpt  = ' '.   " BI 세션

  gs_scroll-row = 'X'.
  gs_scroll-col = 'X'.

ENDFORM.                    " setting_data_for_ranges

*&---------------------------------------------------------------------*
*&      Form  pov_for_procd
*&---------------------------------------------------------------------*
FORM pov_for_procd.
  DATA: BEGIN OF lt_procd OCCURS 0,
          progr TYPE zedt0011-gong_gr,
          pronm TYPE zedt0011-gong_nm,
          procd TYPE zedt0011-gong_cd,
        END   OF lt_procd.

  REFRESH: gt_dynpupdate, gt_dynpread, gt_rtntab.
  CLEAR:   gt_dynpupdate, gt_dynpread, gt_rtntab.

  PERFORM dynp_values_read.

*// Modified by ZGODEV06 on 2026-04-09 {
*  SELECT gong_gr    gong_nm    gong_cd
*    INTO TABLE lt_procd
*    FROM zedt0011
*   WHERE gong_cd <> space.

  DATA lv_werks TYPE t001w-werks.
  DATA lv_dispo TYPE marc-dispo.
  DATA lt_spgcd TYPE RANGE OF zppt0107-spgcd.

  lv_werks = VALUE #( gt_dynpread[ fieldname = 'GP_WERKS' ]-fieldvalue OPTIONAL ).
  lv_dispo = VALUE #( gt_dynpread[ fieldname = 'GP_DISPO' ]-fieldvalue OPTIONAL ).

  lt_spgcd = VALUE #( sign = 'I' option = 'CP' ( low = |{ lv_dispo+0(2) }*| ) ).

  SELECT DISTINCT zt03~gong_gr AS progr,
                  zt03~gong_nm AS pronm,
                  zt03~gong_cd AS procd
    INTO CORRESPONDING FIELDS OF TABLE @lt_procd
    FROM zppt0107 AS zt01
    JOIN t001w
      ON zt01~werks EQ t001w~werks
    JOIN t001k
      ON t001w~bwkey EQ t001k~bwkey
    JOIN zedt0010 AS zt02
      ON t001k~bukrs EQ zt02~bukrs
     AND zt01~spart  EQ zt02~spart
    JOIN zedt0011 AS zt03
      ON zt02~gong_cd EQ zt03~gong_cd
   WHERE zt01~werks   EQ @lv_werks
     AND zt01~spgcd   IN @lt_spgcd
     AND zt02~gong_cd NE @space
   ORDER BY zt03~gong_gr, zt03~gong_nm, zt03~gong_cd.
*// }

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield     = 'OTYPE'
      dynpprog     = sy-cprog
      dynpnr       = sy-dynnr
      window_title = '공정코드 선택'
      value_org    = 'S'
    TABLES
      value_tab    = lt_procd
      return_tab   = gt_rtntab.

  READ TABLE gt_rtntab INDEX 1.

  gp_procd = gt_rtntab-fieldval.

ENDFORM.                    " pov_for_procd

*&---------------------------------------------------------------------*
*&      Form  function_get_classification
*&---------------------------------------------------------------------*
FORM function_get_classification  USING pv_matnr.
  DATA: lv_klart  TYPE ausp-klart,
        lv_object TYPE ausp-objek.

  CLEAR: lv_klart, lv_object, gt_ausp[].

  lv_klart = '001'.
  lv_object = pv_matnr.

  CALL FUNCTION 'Z_PP_GET_CLASSIFICATION'
    EXPORTING
      if_klart          = lv_klart
      if_object         = lv_object
      if_werks          = gp_werks
      if_spgcd          = gv_spgcd
      if_procd          = gp_procd
    TABLES
      it_atwrt          = gt_ausp
    EXCEPTIONS
      no_classification = 1
      OTHERS            = 2.

  SORT gt_ausp  BY atnam.
ENDFORM.                    " function_get_classification

*&---------------------------------------------------------------------*
*&      Form  prepare_data_for_process
*&---------------------------------------------------------------------*
FORM prepare_data_for_process.

  PERFORM setting_data_for_ranges.
  PERFORM read_data_from_zppt0030.             " 특성값

  IF gt_atnam[] IS INITIAL.
    MESSAGE s000 WITH '공정별 관리특성을 입력하지 않았습니다.'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  PERFORM read_data_from_tables.

* 2014.06.16 CSR:기능개선_19544 풍세공장은 구매자재 제외
  IF gp_werks EQ '1901'.
    PERFORM exclude_external.
  ENDIF.

  IF gt_mapl[] IS INITIAL.
    MESSAGE s020.
    LEAVE LIST-PROCESSING.
  ENDIF.

  SORT gt_mapl BY matnr plnnr plnal.

*& 작업대상 특성치를 가공한다.
  PERFORM fill_head_to_tc_200.

  LOOP AT gt_mapl  INTO gw_mapl.
    gv_tabix = sy-tabix.

    PERFORM function_get_classification  USING gw_mapl-matnr.

    LOOP AT gt_atnam.         " 가능설비
      CLEAR: gt_ausp.

      READ TABLE gt_ausp  WITH KEY atnam = gt_atnam-atnam
                                  BINARY SEARCH.

      CONCATENATE 'GW_MAPL-ATWRT' gt_atnam-seqno  INTO gv_atwrt.
      ASSIGN (gv_atwrt)  TO <atwrt>.
      <atwrt> = gt_ausp-atwrt.

      IF gt_atnam-atnam = 'MS_CA_RW_STD_PRODUCT_NAME'  OR
         gt_atnam-atnam = 'MS_CA_RW_STD_PRODUCT_NAMES'.
        READ TABLE gt_ausp  WITH KEY atnam =
                'MS_CA_RW_STD_PRODUCT_NAMES' BINARY SEARCH.

        IF sy-subrc = 0.
          CONCATENATE gt_ausp-atwrt gt_ausp-btwrt INTO gw_mapl-atwrt99
                                             SEPARATED BY '  '.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT gt_btnam.        " 길이관련
      CLEAR: gt_ausp.

      READ TABLE gt_ausp  WITH KEY atnam = gt_btnam-atnam
                                  BINARY SEARCH.

      CONCATENATE 'GW_MAPL-BTWRT' gt_btnam-seqno  INTO gv_atwrt.
      ASSIGN (gv_atwrt)  TO <atwrt>.
      <atwrt> = gt_ausp-atwrt.

      IF gt_btnam-atnam = 'MS_CA_RW_STD_PRODUCT_NAME'  OR
         gt_btnam-atnam = 'MS_CA_RW_STD_PRODUCT_NAMES'.
        READ TABLE gt_ausp  WITH KEY atnam =
                'MS_CA_RW_STD_PRODUCT_NAMES' BINARY SEARCH.

        IF sy-subrc = 0.
          CONCATENATE gt_ausp-atwrt gt_ausp-btwrt INTO gw_mapl-btwrt99
                                             SEPARATED BY '  '.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT gt_ctnam.        " 선속관련
      CLEAR: gt_ausp.

      READ TABLE gt_ausp  WITH KEY atnam = gt_ctnam-atnam
                                  BINARY SEARCH.

      CONCATENATE 'GW_MAPL-CTWRT' gt_ctnam-seqno  INTO gv_atwrt.
      ASSIGN (gv_atwrt)  TO <atwrt>.
      <atwrt> = gt_ausp-atwrt.

      IF gt_ctnam-atnam = 'MS_CA_RW_STD_PRODUCT_NAME'  OR
         gt_ctnam-atnam = 'MS_CA_RW_STD_PRODUCT_NAMES'.
        READ TABLE gt_ausp  WITH KEY atnam =
                'MS_CA_RW_STD_PRODUCT_NAMES' BINARY SEARCH.

        IF sy-subrc = 0.
          CONCATENATE gt_ausp-atwrt gt_ausp-btwrt INTO gw_mapl-ctwrt99
                                             SEPARATED BY '  '.
        ENDIF.
      ENDIF.
    ENDLOOP.

*    ENDIF.

    MODIFY gt_mapl INDEX gv_tabix FROM gw_mapl.
  ENDLOOP.

  PERFORM create_search_atwrt_data.
  PERFORM read_data_from_plpo.          " 라우팅정보를 읽는다

  SORT gt_data  BY matnr plnnr plnal plnfl vornr.

ENDFORM.                    " prepare_data_for_process

*&---------------------------------------------------------------------*
*&      Form  create_search_atwrt_data
*&---------------------------------------------------------------------*
FORM create_search_atwrt_data.
  CLEAR: gt_0031[], gt_0035[], gt_0034[], gt_0036[],
         gt_0040[], gt_0041[].

  PERFORM read_data_from_zppt0031.
  PERFORM read_data_from_zppt0035.
  PERFORM read_data_from_zppt0034.
  PERFORM read_data_from_zppt0036.
  PERFORM read_data_from_zppt0040.
  PERFORM read_data_from_zppt0041.

  SORT: gt_0031  BY seqno plnal plnfl vornr index,
        gt_0035  BY seqno plnal plnfl vornr,
        gt_0034  BY seqno index,
        gt_0036  BY seqno arbpl,
        gt_0040  BY seqno index,
        gt_0041  BY seqno arbpl.

  PERFORM edit_data_atwrt_210.
  PERFORM edit_data_atwrt_220.
  PERFORM edit_data_atwrt_230.

  SORT gt_atwrt  BY sort01 sort02 sort03 sort04 sort05 sort06 sort07
                    sort08 sort09 sort10 sort11 sort12 sort13 sort14
                    sort15 sort16 sort17 sort04 sort18 sort19 sort20
                    plnal  plnfl  vornr.

  SORT gt_btwrt  BY sort01 sort02 sort03 sort04 sort05 sort06 sort07
                    sort08 sort09 sort10 sort11 sort12 sort13 sort14
                    sort15 sort16 sort17 sort04 sort18 sort19 sort20
                    fhank.

  SORT gt_ctwrt  BY sort01 sort02 sort03 sort04 sort05 sort06 sort07
                    sort08 sort09 sort10 sort11 sort12 sort13 sort14
                    sort15 sort16 sort17 sort04 sort18 sort19 sort20.

ENDFORM.                    " create_search_atwrt_data

*&---------------------------------------------------------------------*
*&      Form  simulation_suitable_stdtm
*&---------------------------------------------------------------------*
FORM simulation_suitable_stdtm.

  DATA : BEGIN OF lt_comp OCCURS 0,
           matnr TYPE mara-matnr,
           plnal TYPE plas-plnal,
           plnfl TYPE plas-plnfl,
         END   OF lt_comp.

  DATA : BEGIN OF lt_comp1 OCCURS 0,
           vornr TYPE plpo-vornr,
           arbpl TYPE crhd-arbpl,
         END   OF lt_comp1.

  DATA : BEGIN OF lt_comp3 OCCURS 0,
           matnr TYPE mara-matnr,
           plnal TYPE plas-plnal,
           plnfl TYPE plas-plnfl,
           vornr TYPE plpo-vornr,
           mark  TYPE c,
         END   OF lt_comp3.

  DATA : lt_comp4 LIKE lt_comp3 OCCURS 0 WITH HEADER LINE.

  READ TABLE gt_data  WITH KEY chk  = 'X'
                               flag = space.
  IF sy-subrc <> 0.
    MESSAGE s000 WITH '시뮬레이션할 자료가 없습니다.'.
    RETURN.
  ENDIF.

  DATA lv_answer TYPE char01.

  PERFORM  popup_to_confirm USING TEXT-c01 lv_answer.

  CHECK lv_answer EQ '1'.

  gt_temp[] = gt_data[].

  LOOP AT gt_data  INTO gw_data
                  WHERE chk  = 'X'
                    AND flag = space.
    gv_tabix = sy-tabix.
    gw_data-flag = 'ERROR'.

    IF gw_data-indi = '등록'.
      PERFORM read_routing_atwrt.       " 변경등록시
    ELSE.
      PERFORM read_new_routing_atwrt.   " 신규등록시
    ENDIF.
  ENDLOOP.

  CLEAR: gt_temp[], gt_comp[].

  SORT gt_data  BY matnr plnnr plnal plnfl vornr.

*& 2010.02.17 CSR : C20100210_10492
*& 에러가 아닌 시뮬레이션 자료중 자재코드,그룹카운터,순서만 복사
  CLEAR : lt_comp, lt_comp[], lt_comp3, lt_comp3[].

  LOOP AT gt_data WHERE flag = 'GOOD'.
    MOVE-CORRESPONDING gt_data TO lt_comp.
    APPEND lt_comp.
    MOVE-CORRESPONDING gt_data TO lt_comp3.
    APPEND lt_comp3.
  ENDLOOP.

  SORT lt_comp BY matnr plnal plnfl.

  DELETE ADJACENT DUPLICATES FROM lt_comp COMPARING matnr plnal plnfl.

*& 자재코드,그룹카운터,순서에 해당하는 공정별 설비로 중복 여부 체크
  LOOP AT lt_comp.

    CLEAR : lt_comp1, lt_comp1[].

    LOOP AT gt_data WHERE matnr = lt_comp-matnr
                      AND plnal = lt_comp-plnal
                      AND plnfl = lt_comp-plnfl.
      MOVE-CORRESPONDING gt_data TO lt_comp1.
      APPEND lt_comp1.
    ENDLOOP.

    LOOP AT lt_comp1.

      LOOP AT gt_data WHERE matnr = lt_comp-matnr
                        AND plnal = lt_comp-plnal
                        AND plnfl <> lt_comp-plnfl
                        AND vornr = lt_comp1-vornr
                        AND arbpl = lt_comp1-arbpl.

        READ TABLE lt_comp3 WITH KEY matnr = lt_comp-matnr
                                     plnal = lt_comp-plnal
                                     plnfl = gt_data-plnfl
                                     vornr = lt_comp1-vornr.
        IF sy-subrc  EQ 0.
          lt_comp3-mark = 'X'.
          MODIFY lt_comp3 INDEX sy-tabix.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

  SORT lt_comp3 BY matnr plnal plnfl vornr.

  CLEAR : lt_comp4, lt_comp4[].

  lt_comp4[] = lt_comp3[].

  LOOP AT lt_comp3 WHERE mark = 'X'.

    READ TABLE lt_comp4  WITH KEY matnr = lt_comp3-matnr
                                  plnal = lt_comp3-plnal
                                  plnfl = lt_comp3-plnfl
                                  mark = ' '.

    IF sy-subrc EQ 0.  "공정중 중복된게 하나라도 있으면
      lt_comp3-mark = ' '.
      MODIFY lt_comp3.
    ENDIF.
  ENDLOOP.

  LOOP AT lt_comp3 WHERE mark = 'X'.

    LOOP AT gt_data WHERE matnr = lt_comp3-matnr.

      gt_data-flag = 'ERROR'.
      gt_data-message = '순서내 중복 작업장이 존재합니다.'.
      MODIFY gt_data.

    ENDLOOP.
  ENDLOOP.

  SORT gt_data  BY matnr plnnr plnal plnfl vornr.

ENDFORM.                    " simulation_suitable_stdtm

*&---------------------------------------------------------------------*
*&      Form  read_data_from_zppt0031
*&---------------------------------------------------------------------*
FORM read_data_from_zppt0031.
  SELECT a~atnam    a~seqno    a~plnal    a~plnfl
         a~vornr    a~atwrt    b~seqno AS index
    INTO TABLE gt_0031
    FROM zppt0031 AS a  INNER JOIN zppt0030 AS b
                                ON a~werks = b~werks  AND
                                   a~procd = b~procd  AND
                                   a~spgcd = b~spgcd  AND
                                   a~atnam = b~atnam
   WHERE a~werks  = gp_werks
     AND a~procd  = gp_procd
     AND a~spgcd  = gv_spgcd
     AND a~atnam IN gr_atnam.
ENDFORM.                    " read_data_from_zppt0031

*&---------------------------------------------------------------------*
*&      Form  read_data_from_zppt0035
*&---------------------------------------------------------------------*
FORM read_data_from_zppt0035.
  SELECT a~seqno    a~plnal    a~plnfl    a~vornr
         a~verid    a~arbpl    c~ktext    "d~aznor
    INTO TABLE gt_0035
    FROM zppt0035 AS a  INNER JOIN crhd AS b
                                ON a~arbpl = b~arbpl  AND
                                   a~werks = b~werks
                        INNER JOIN crtx AS c
                                ON b~objty = c~objty  AND
                                   b~objid = c~objid
*                        INNER JOIN kako AS d
*                                ON b~kapid = d~kapid
   WHERE a~werks  = gp_werks
     AND a~procd  = gp_procd
     AND a~spgcd  = gv_spgcd
     AND c~spras  = sy-langu.
ENDFORM.                    " read_data_from_zppt0035

*&---------------------------------------------------------------------*
*&      Form  read_data_from_zppt0034
*&---------------------------------------------------------------------*
FORM read_data_from_zppt0034.
  SELECT a~atnam    a~seqno    a~arbpl    a~atwrt
         b~seqno AS index
    INTO TABLE gt_0034
    FROM zppt0034 AS a  INNER JOIN zppt0030 AS b
                                ON a~werks = b~werks  AND
                                   a~procd = b~procd  AND
                                   a~spgcd = b~spgcd  AND
                                   a~atnam = b~atnam
   WHERE a~werks  = gp_werks
     AND a~procd  = gp_procd
     AND a~spgcd  = gv_spgcd
     AND a~atnam IN gr_btnam.
ENDFORM.                    " read_data_from_zppt0034

*&---------------------------------------------------------------------*
*&      Form  read_data_from_zppt0036
*&---------------------------------------------------------------------*
FORM read_data_from_zppt0036.
  SELECT seqno    arbpl    fhank    qmmgn tuhnk
    INTO TABLE gt_0036
    FROM zppt0036
   WHERE werks  = gp_werks
     AND procd  = gp_procd
     AND spgcd  = gv_spgcd.
ENDFORM.                    " read_data_from_zppt0035

*&---------------------------------------------------------------------*
*&      Form  read_data_from_zppt0040
*&---------------------------------------------------------------------*
FORM read_data_from_zppt0040.
  SELECT a~atnam    a~seqno    a~arbpl    a~atwrt
         b~seqno AS index
    INTO TABLE gt_0040
    FROM zppt0040 AS a  INNER JOIN zppt0030 AS b
                                ON a~werks = b~werks  AND
                                   a~procd = b~procd  AND
                                   a~spgcd = b~spgcd  AND
                                   a~atnam = b~atnam
   WHERE a~werks  = gp_werks
     AND a~procd  = gp_procd
     AND a~spgcd  = gv_spgcd
     AND a~atnam IN gr_ctnam.
ENDFORM.                    " read_data_from_zppt0040

*&---------------------------------------------------------------------*
*&      Form  read_data_from_zppt0041
*&---------------------------------------------------------------------*
FORM read_data_from_zppt0041.

  SELECT seqno    arbpl    basmn    meins
         ruezt    zflux    optim    rdrnp
         wktim    meinh
    INTO TABLE gt_0041
    FROM zppt0041
   WHERE werks  = gp_werks
     AND procd  = gp_procd
     AND spgcd  = gv_spgcd.

  SELECT zt01~*
    INTO CORRESPONDING FIELDS OF TABLE @gt_t1160
    FROM zgtppt1160 AS zt01
   WHERE werks EQ @gp_werks
     AND procd EQ @gp_procd
     AND spgcd EQ @gv_spgcd
   ORDER BY werks, spgcd, procd, seqno, arbpl.

ENDFORM.                    " read_data_from_zppt0041

*&---------------------------------------------------------------------*
*&      Form  edit_data_atwrt_210
*&---------------------------------------------------------------------*
FORM edit_data_atwrt_210.
  DATA: lv_plnal    TYPE zppt0031-plnal,
        lv_plnfl    TYPE zppt0031-plnfl,
        lv_vornr    TYPE zppt0031-vornr,
        lv_seqno    TYPE zppt0031-seqno,
        lv_atwrt    TYPE zdec16_6,
        lv_chratwrt TYPE char30.

  LOOP AT gt_atnam.
    gt_0031-index = gt_atnam-seqno.
    gt_0031-sngle = gt_atnam-sngle.
    gt_0031-multi = gt_atnam-multi.
    gt_0031-inclu = gt_atnam-inclu.
    gt_0031-range = gt_atnam-range.

    MODIFY gt_0031  TRANSPORTING index
                                 sngle
                                 multi
                                 inclu
                                 range
                           WHERE atnam  = gt_atnam-atnam.
  ENDLOOP.

  READ TABLE gt_0031  INDEX 1.

  lv_seqno = gt_0031-seqno.
  lv_plnal = gt_0031-plnal.
  lv_plnfl = gt_0031-plnfl.
  lv_vornr = gt_0031-vornr.

  LOOP AT gt_0031  INTO gw_0031.
    IF gw_0031-seqno <> lv_seqno  OR
       gw_0031-plnal <> lv_plnal  OR
       gw_0031-plnfl <> lv_plnfl  OR
       gw_0031-vornr <> lv_vornr.

      READ TABLE gt_0035  WITH KEY seqno = gt_atwrt-seqno
                                   plnal = gt_atwrt-plnal
                                   plnfl = gt_atwrt-plnfl
                                   vornr = gt_atwrt-vornr.

      IF sy-subrc = 0.
        MOVE-CORRESPONDING gt_0035 TO gt_atwrt.
      ENDIF.

      APPEND gt_atwrt.

      CLEAR: gt_atwrt.
      lv_seqno = gw_0031-seqno.
      lv_plnal = gw_0031-plnal.
      lv_plnfl = gw_0031-plnfl.
      lv_vornr = gw_0031-vornr.
    ENDIF.

    gt_atwrt-seqno = gw_0031-seqno.
    gt_atwrt-plnal = gw_0031-plnal.
    gt_atwrt-plnfl = gw_0031-plnfl.
    gt_atwrt-vornr = gw_0031-vornr.

    CONCATENATE: 'GT_ATWRT-SORT'  gw_0031-index  INTO gv_sort,
                 'GT_ATWRT-ATWRT' gw_0031-index  INTO gv_atwrt,
                 'GT_ATWRT-SNGLE' gw_0031-index  INTO gv_sngle.

    ASSIGN: (gv_sort)  TO <sort>,
            (gv_atwrt) TO <atwrt>,
            (gv_sngle) TO <sngle>.

    IF gw_0031-sngle = 'X'.
      <sngle> = '1'.
    ELSEIF gw_0031-multi = 'X'.
      <sngle> = '2'.
    ELSEIF gw_0031-inclu = 'X'.
      <sngle> = '3'.
    ELSEIF gw_0031-range = 'X'.
      <sngle> = '4'.
    ENDIF.

    <atwrt> = gw_0031-atwrt.

*&  범위의 경우 '132' 보다 '61'이 더 큰 것으로 되는 것을 방지위해
    IF <sngle>  = '2'  AND    " 범위값이면서 전체 '~'가 아니면
       <atwrt> <> '~'.

*-> CCM 2023.04.12 오바다 - CHAR30 사용
      CLEAR gv_char30.
      gv_char30 = gw_0031-atwrt.
*<- CCM 2023.04.12 오바다
      CALL FUNCTION 'Z_PP_SPLIT_NUM_CHAR'
        EXPORTING
*-> CCM 2023.04.12 오바다 - CHAR30 사용
*         if_source = gw_0031-atwrt
          if_source = gv_char30
*<- CCM 2023.04.12 오바다
        IMPORTING
          if_char   = lv_chratwrt
          if_number = lv_atwrt.

      WRITE: lv_atwrt TO <sort>+0(25) RIGHT-JUSTIFIED.
      <sort>+25(5) = lv_chratwrt(5).
    ELSE.
      <sort>  = gw_0031-atwrt.
    ENDIF.
  ENDLOOP.

  READ TABLE gt_0035  WITH KEY seqno = gt_atwrt-seqno
                               plnal = gt_atwrt-plnal
                               plnfl = gt_atwrt-plnfl
                               vornr = gt_atwrt-vornr.

  IF sy-subrc = 0.
    MOVE-CORRESPONDING gt_0035 TO gt_atwrt.
  ENDIF.

  APPEND gt_atwrt.
ENDFORM.                    " edit_data_atwrt_210

*&---------------------------------------------------------------------*
*&      Form  edit_data_atwrt_220
*&---------------------------------------------------------------------*
FORM edit_data_atwrt_220.
  DATA: lv_seqno    TYPE zppt0034-seqno,
        lv_atwrt    TYPE zdec16_6,
        lv_chratwrt TYPE char30.

  LOOP AT gt_btnam.
    gt_0034-index = gt_btnam-seqno.
    gt_0034-sngle = gt_btnam-sngle.
    gt_0034-multi = gt_btnam-multi.
    gt_0034-inclu = gt_btnam-inclu.
    gt_0034-range = gt_btnam-range.

    MODIFY gt_0034  TRANSPORTING index
                                 sngle
                                 multi
                                 inclu
                                 range
                           WHERE atnam  = gt_btnam-atnam.
  ENDLOOP.

  READ TABLE gt_0034  INDEX 1.

  lv_seqno = gt_0034-seqno.

  LOOP AT gt_0034  INTO gw_0034.
    IF gw_0034-seqno <> lv_seqno.
      READ TABLE gt_0036  WITH KEY seqno = gt_btwrt-seqno
                                   arbpl = gt_btwrt-arbpl
                                  BINARY SEARCH.

      IF sy-subrc = 0.
        MOVE-CORRESPONDING gt_0036 TO gt_btwrt.
      ENDIF.

      APPEND gt_btwrt.

      CLEAR: gt_btwrt.
      lv_seqno = gw_0034-seqno.
    ENDIF.

    gt_btwrt-seqno = gw_0034-seqno.
    gt_btwrt-arbpl = gw_0034-arbpl.

    CONCATENATE: 'GT_BTWRT-sort'  gw_0034-index  INTO gv_sort,
                 'GT_BTWRT-ATWRT' gw_0034-index  INTO gv_atwrt,
                 'GT_BTWRT-SNGLE' gw_0034-index  INTO gv_sngle.

    ASSIGN: (gv_sort)  TO <sort>,
            (gv_atwrt) TO <atwrt>,
            (gv_sngle) TO <sngle>.

    IF gw_0034-sngle = 'X'.
      <sngle> = '1'.
    ELSEIF gw_0034-multi = 'X'.
      <sngle> = '2'.
    ELSEIF gw_0034-inclu = 'X'.
      <sngle> = '3'.
    ELSEIF gw_0034-range = 'X'.
      <sngle> = '4'.
    ENDIF.

    <atwrt> = gw_0034-atwrt.

*&  범위의 경우 '132' 보다 '61'이 더 큰 것으로 되는 것을 방지위해
    IF <sngle>  = '2'  AND    " 범위값이면서 전체 '~'가 아니면
       <atwrt> <> '~'.

*-> CCM 2023.04.12 오바다 - CHAR30 사용
      CLEAR gv_char30.
      gv_char30 = gw_0034-atwrt.
*<- CCM 2023.04.12 오바다

      CALL FUNCTION 'Z_PP_SPLIT_NUM_CHAR'
        EXPORTING
*-> CCM 2023.04.12 오바다 - CHAR30 사용
*         if_source = gw_0034-atwrt
          if_source = gv_char30
*<- CCM 2023.04.12 오바다
        IMPORTING
          if_char   = lv_chratwrt
          if_number = lv_atwrt.

      WRITE: lv_atwrt TO <sort>+0(25) RIGHT-JUSTIFIED.
      <sort>+25(5) = lv_chratwrt(5).
    ELSE.
      <sort>  = gw_0034-atwrt.
    ENDIF.
  ENDLOOP.

  READ TABLE gt_0036  WITH KEY seqno = gt_btwrt-seqno
                               arbpl = gt_btwrt-arbpl
                              BINARY SEARCH.
  IF sy-subrc = 0.
    MOVE-CORRESPONDING gt_0036 TO gt_btwrt.
  ENDIF.

  APPEND gt_btwrt.
ENDFORM.                    " edit_data_atwrt_220

*&---------------------------------------------------------------------*
*&      Form  edit_data_atwrt_230
*&---------------------------------------------------------------------*
FORM edit_data_atwrt_230.
  DATA: lv_seqno    TYPE zppt0040-seqno,
        lv_atwrt    TYPE zdec16_6,
        lv_chratwrt TYPE char30.

  LOOP AT gt_ctnam.
    gt_0040-index = gt_ctnam-seqno.
    gt_0040-sngle = gt_ctnam-sngle.
    gt_0040-multi = gt_ctnam-multi.
    gt_0040-inclu = gt_ctnam-inclu.
    gt_0040-range = gt_ctnam-range.

    MODIFY gt_0040  TRANSPORTING index
                                 sngle
                                 multi
                                 inclu
                                 range
                           WHERE atnam  = gt_ctnam-atnam.
  ENDLOOP.

  READ TABLE gt_0040  INDEX 1.

  lv_seqno = gt_0040-seqno.

  LOOP AT gt_0040  INTO gw_0040.
    IF gw_0040-seqno <> lv_seqno.
      READ TABLE gt_0041  WITH KEY seqno = gt_ctwrt-seqno
                                   arbpl = gt_ctwrt-arbpl
                                  BINARY SEARCH.

      IF sy-subrc = 0.
        MOVE-CORRESPONDING gt_0041 TO gt_ctwrt.

        READ TABLE gt_t1160 INTO DATA(ls_t1160) WITH KEY seqno = gt_ctwrt-seqno
                                                         arbpl = gt_ctwrt-arbpl.
        IF sy-subrc IS INITIAL.
          gt_ctwrt-oprate = ls_t1160-oprate.
        ENDIF.
      ENDIF.

      APPEND gt_ctwrt.

      CLEAR: gt_ctwrt.
      lv_seqno = gw_0040-seqno.
    ENDIF.

    gt_ctwrt-seqno = gw_0040-seqno.
    gt_ctwrt-arbpl = gw_0040-arbpl.

    CONCATENATE: 'GT_CTWRT-SORT'  gw_0040-index  INTO gv_sort,
                 'GT_CTWRT-ATWRT' gw_0040-index  INTO gv_atwrt,
                 'GT_CTWRT-SNGLE' gw_0040-index  INTO gv_sngle.

    ASSIGN: (gv_sort)  TO <sort>,
            (gv_atwrt) TO <atwrt>,
            (gv_sngle) TO <sngle>.

    IF gw_0040-sngle = 'X'.
      <sngle> = '1'.
    ELSEIF gw_0040-multi = 'X'.
      <sngle> = '2'.
    ELSEIF gw_0040-inclu = 'X'.
      <sngle> = '3'.
    ELSEIF gw_0040-range = 'X'.
      <sngle> = '4'.
    ENDIF.

    <atwrt> = gw_0040-atwrt.

*&  범위의 경우 '132' 보다 '61'이 더 큰 것으로 되는 것을 방지위해
    IF <sngle>  = '2'  AND    " 범위값이면서 전체 '~'가 아니면
       <atwrt> <> '~'.
*-> CCM 2023.04.12 오바다 - CHAR30 사용
      CLEAR gv_char30.
      gv_char30 = gw_0040-atwrt.
*<- CCM 2023.04.12 오바다

      CALL FUNCTION 'Z_PP_SPLIT_NUM_CHAR'
        EXPORTING
*-> CCM 2023.04.12 오바다 - CHAR30 사용
*         if_source = gw_0040-atwrt
          if_source = gv_char30
*<- CCM 2023.04.12 오바다
        IMPORTING
          if_char   = lv_chratwrt
          if_number = lv_atwrt.

      WRITE: lv_atwrt TO <sort>+0(25) RIGHT-JUSTIFIED.
      <sort>+25(5) = lv_chratwrt(5).
    ELSE.
      <sort>  = gw_0040-atwrt.
    ENDIF.
  ENDLOOP.

  READ TABLE gt_0041  WITH KEY seqno = gt_ctwrt-seqno
                               arbpl = gt_ctwrt-arbpl
                              BINARY SEARCH.
  IF sy-subrc = 0.
    MOVE-CORRESPONDING gt_0041 TO gt_ctwrt.

    READ TABLE gt_t1160 INTO ls_t1160 WITH KEY seqno = gt_ctwrt-seqno
                                               arbpl = gt_ctwrt-arbpl.
    IF sy-subrc IS INITIAL.
      gt_ctwrt-oprate = ls_t1160-oprate.
    ENDIF.
  ENDIF.

  APPEND gt_ctwrt.

ENDFORM.                    " edit_data_atwrt_230

*&---------------------------------------------------------------------*
*&      Form  search_suitable_atwrt
*&---------------------------------------------------------------------*
FORM search_suitable_atwrt.
  DATA: lv_flag     TYPE char6,
        lv_char     TYPE char30,
        lv_char1    TYPE char30,
        lv_char2    TYPE char30,
        lv_atwrt    TYPE zdec16_6,
        lv_value    TYPE zdec16_6,
        lv_chratwrt TYPE char30,
        lv_valatwrt TYPE char30.

  RANGES: lr_atwrt           FOR zppt0031-atwrt.

  LOOP AT gt_atwrt.
    CLEAR: gv_num2, gw_data-arbpl, lv_flag.

    DO gv_210cols TIMES.
      gv_num2 = gv_num2 + 1.

      CONCATENATE: 'GT_ATWRT-ATWRT' gv_num2  INTO gv_atwrt,
                   'GT_ATWRT-SNGLE' gv_num2  INTO gv_sngle,
                   'GW_DATA-ATWRT'  gv_num2  INTO gv_value.

      ASSIGN: (gv_atwrt) TO <atwrt>,    " 생산특성값
              (gv_sngle) TO <sngle>,
              (gv_value) TO <value>.    " 설계특성값

      IF <sngle> = '2'.            " 범위(자신보다 큰 값만 인정)
        IF <atwrt> <> '~'.
          lv_chratwrt = <atwrt>.
          lv_valatwrt = <value>.

          CALL FUNCTION 'Z_PP_SPLIT_NUM_CHAR'
            EXPORTING
              if_source = lv_chratwrt
            IMPORTING
              if_char   = lv_chratwrt
              if_number = lv_atwrt.

          CALL FUNCTION 'Z_PP_SPLIT_NUM_CHAR'
            EXPORTING
              if_source = lv_valatwrt
            IMPORTING
              if_char   = lv_valatwrt
              if_number = lv_value.

          IF lv_chratwrt <> lv_valatwrt.
            lv_flag = 'ERROR'.
            EXIT.
          ELSE.
            IF lv_atwrt < lv_value.
              lv_flag = 'ERROR'.
              EXIT.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        IF <sngle> = '1'.         " 단일값
          IF <atwrt> <> <value>.
            IF <atwrt> <> '~'.
              lv_flag = 'ERROR'.
              EXIT.
            ENDIF.
          ENDIF.
        ELSEIF <sngle> = '3'.    " 포함
          CLEAR: lv_char, lv_char1, lv_char2, gt_atnam, lr_atwrt[].

          lv_char = <atwrt>.

          DO.
            IF lv_char IS INITIAL.
              EXIT.
            ENDIF.

            SPLIT lv_char AT ','  INTO lv_char1 lv_char2.

            lr_atwrt-sign = 'I'.
            lr_atwrt-option = 'CP'.
            CONCATENATE '*' lv_char1 '*'  INTO lr_atwrt-low.
            APPEND lr_atwrt.

            lv_char = lv_char2.
          ENDDO.

          READ TABLE gt_atnam  WITH KEY seqno = gv_num2
                                         BINARY SEARCH.

          IF gt_atnam-atnam = 'MS_CA_RW_STD_PRODUCT_NAME'  OR
             gt_atnam-atnam = 'MS_CA_RW_STD_PRODUCT_NAMES'.
            IF NOT gw_data-atwrt99 IN lr_atwrt.
              IF <atwrt> <> '~'.
                lv_flag = 'ERROR'.
                EXIT.
              ENDIF.
            ENDIF.
          ELSE.
            IF NOT <value> IN lr_atwrt.
              IF <atwrt> <> '~'.
                lv_flag = 'ERROR'.
                EXIT.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSEIF <sngle> = '4'.    " 일치(OR)
          CLEAR: lv_char, lv_char1, lv_char2, lr_atwrt[].

          lv_char = <atwrt>.

          DO.
            IF lv_char IS INITIAL.
              EXIT.
            ENDIF.

            SPLIT lv_char AT ','  INTO lv_char1 lv_char2.

            lr_atwrt-sign = 'I'.
            lr_atwrt-option = 'EQ'.
            lr_atwrt-low = lv_char1.
            APPEND lr_atwrt.

            lv_char = lv_char2.
          ENDDO.

          IF NOT <value> IN lr_atwrt.
            IF <atwrt> <> '~'.
              lv_flag = 'ERROR'.
              EXIT.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDDO.

    IF lv_flag = space.
      gw_data-seqno = gt_atwrt-seqno.
      gw_data-plnal = gt_atwrt-plnal.
      gw_data-plnfl = gt_atwrt-plnfl.
      gw_data-vornr = gt_atwrt-vornr.
      gw_data-arbpl = gt_atwrt-arbpl.
      gw_data-ktext = gt_atwrt-ktext.
      gw_data-flag210 = 'GOOD'.

      RETURN.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " search_suitable_atwrt

*&---------------------------------------------------------------------*
*&      Form  search_suitable_btwrt
*&---------------------------------------------------------------------*
FORM search_suitable_btwrt.
  DATA: lv_flag     TYPE char6,
        lv_char     TYPE char30,
        lv_char1    TYPE char30,
        lv_char2    TYPE char30,
        lv_atwrt    TYPE zdec16_6,
        lv_value    TYPE zdec16_6,
        lv_chratwrt TYPE char30,
        lv_valatwrt TYPE char30.

  RANGES: lr_atwrt           FOR zppt0031-atwrt.

  LOOP AT gt_btwrt.
    CLEAR: gv_num2, lv_flag.

    DO gv_220cols TIMES.
      gv_num2 = gv_num2 + 1.

      CONCATENATE: 'GT_BTWRT-ATWRT' gv_num2  INTO gv_atwrt,
                   'GT_BTWRT-SNGLE' gv_num2  INTO gv_sngle,
                   'GW_DATA-BTWRT'  gv_num2  INTO gv_value.

      ASSIGN: (gv_atwrt) TO <atwrt>,    " PP 값
              (gv_sngle) TO <sngle>,    " 검색범주
              (gv_value) TO <value>.    " 설계값

      IF <sngle> = '2'.            " 범위(자신보다 큰 값만 인정)
        IF <atwrt> <> '~'.
          lv_chratwrt = <atwrt>.
          lv_valatwrt = <value>.

          CALL FUNCTION 'Z_PP_SPLIT_NUM_CHAR'
            EXPORTING
              if_source = lv_chratwrt
            IMPORTING
              if_char   = lv_chratwrt
              if_number = lv_atwrt.

          CALL FUNCTION 'Z_PP_SPLIT_NUM_CHAR'
            EXPORTING
              if_source = lv_valatwrt
            IMPORTING
              if_char   = lv_valatwrt
              if_number = lv_value.

          IF lv_chratwrt <> lv_valatwrt.
            lv_flag = 'ERROR'.
            EXIT.
          ELSE.
            IF lv_atwrt < lv_value.
              lv_flag = 'ERROR'.
              EXIT.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        IF <sngle> = '1'.         " 단일값
          IF <atwrt> <> <value>.
            IF <atwrt> <> '~'.
              lv_flag = 'ERROR'.
              EXIT.
            ENDIF.
          ENDIF.
        ELSEIF <sngle> = '3'.    " 포함
          CLEAR: lv_char, lv_char1, lv_char2, gt_btnam, lr_atwrt[].

          lv_char = <atwrt>.

          DO.
            IF lv_char IS INITIAL.
              EXIT.
            ENDIF.

            SPLIT lv_char AT ','  INTO lv_char1 lv_char2.

            lr_atwrt-sign = 'I'.
            lr_atwrt-option = 'CP'.
            CONCATENATE '*' lv_char1 '*'  INTO lr_atwrt-low.
            APPEND lr_atwrt.

            lv_char = lv_char2.
          ENDDO.

          READ TABLE gt_btnam  WITH KEY seqno = gv_num2
                                         BINARY SEARCH.

          IF gt_btnam-atnam = 'MS_CA_RW_STD_PRODUCT_NAME'  OR
             gt_btnam-atnam = 'MS_CA_RW_STD_PRODUCT_NAMES'.
            IF NOT gw_data-btwrt99 IN lr_atwrt.
              IF <atwrt> <> '~'.
                lv_flag = 'ERROR'.
                EXIT.
              ENDIF.
            ENDIF.
          ELSE.
            IF NOT <value> IN lr_atwrt.
              IF <atwrt> <> '~'.
                lv_flag = 'ERROR'.
                EXIT.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSEIF <sngle> = '4'.    " 일치(OR)
          CLEAR: lv_char, lv_char1, lv_char2, lr_atwrt[].

          lv_char = <atwrt>.

          DO.
            IF lv_char IS INITIAL.
              EXIT.
            ENDIF.

            SPLIT lv_char AT ','  INTO lv_char1 lv_char2.

            lr_atwrt-sign = 'I'.
            lr_atwrt-option = 'EQ'.
            lr_atwrt-low = lv_char1.
            APPEND lr_atwrt.

            lv_char = lv_char2.
          ENDDO.

          IF NOT <value> IN lr_atwrt.
            IF <atwrt> <> '~'.
              lv_flag = 'ERROR'.
              EXIT.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDDO.

    IF lv_flag = space.
      gw_data-rslt2 = gt_btwrt-seqno.
      gw_data-tuhnk = gt_btwrt-tuhnk.
      gw_data-fhank = gt_btwrt-fhank.
      gw_data-qmmgn = gt_btwrt-qmmgn.
      gw_data-flag220 = 'GOOD'.

      RETURN.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " search_suitable_btwrt

*&---------------------------------------------------------------------*
*&      Form  search_suitable_ctwrt
*&---------------------------------------------------------------------*
FORM search_suitable_ctwrt.
  DATA: lv_flag     TYPE char6,
        lv_char     TYPE char30,
        lv_char1    TYPE char30,
        lv_char2    TYPE char30,
        lv_atwrt    TYPE zdec16_6,
        lv_value    TYPE zdec16_6,
        lv_chratwrt TYPE char30,
        lv_valatwrt TYPE char30.

  RANGES: lr_atwrt           FOR zppt0031-atwrt.

  LOOP AT gt_ctwrt  WHERE arbpl = gw_data-arbpl.
    CLEAR: gv_num2, lv_flag.

    DO gv_230cols TIMES.
      gv_num2 = gv_num2 + 1.

      CONCATENATE: 'GT_CTWRT-ATWRT' gv_num2  INTO gv_atwrt,
                   'GT_CTWRT-SNGLE' gv_num2  INTO gv_sngle,
                   'GW_DATA-CTWRT'  gv_num2  INTO gv_value.

      ASSIGN: (gv_atwrt) TO <atwrt>,
              (gv_sngle) TO <sngle>,
              (gv_value) TO <value>.

      IF <sngle> = '2'.            " 범위(자신보다 큰 값만 인정)
        IF <atwrt> <> '~'.
          lv_chratwrt = <atwrt>.
          lv_valatwrt = <value>.

          CALL FUNCTION 'Z_PP_SPLIT_NUM_CHAR'
            EXPORTING
              if_source = lv_chratwrt
            IMPORTING
              if_char   = lv_chratwrt
              if_number = lv_atwrt.

          CALL FUNCTION 'Z_PP_SPLIT_NUM_CHAR'
            EXPORTING
              if_source = lv_valatwrt
            IMPORTING
              if_char   = lv_valatwrt
              if_number = lv_value.

          IF lv_chratwrt <> lv_valatwrt.
            lv_flag = 'ERROR'.
            EXIT.
          ELSE.
            IF lv_atwrt < lv_value.
              lv_flag = 'ERROR'.
              EXIT.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        IF <sngle> = '1'.         " 단일값
          IF <atwrt> <> <value>.
            IF <atwrt> <> '~'.
              lv_flag = 'ERROR'.
              EXIT.
            ENDIF.
          ENDIF.
        ELSEIF <sngle> = '3'.    " 포함
          CLEAR: lv_char, lv_char1, lv_char2, gt_ctnam, lr_atwrt[].

          lv_char = <atwrt>.

          DO.
            IF lv_char IS INITIAL.
              EXIT.
            ENDIF.

            SPLIT lv_char AT ','  INTO lv_char1 lv_char2.

            lr_atwrt-sign = 'I'.
            lr_atwrt-option = 'CP'.
            CONCATENATE '*' lv_char1 '*'  INTO lr_atwrt-low.
            APPEND lr_atwrt.

            lv_char = lv_char2.
          ENDDO.

          READ TABLE gt_ctnam  WITH KEY seqno = gv_num2
                                         BINARY SEARCH.

          IF gt_ctnam-atnam = 'MS_CA_RW_STD_PRODUCT_NAME'  OR
             gt_ctnam-atnam = 'MS_CA_RW_STD_PRODUCT_NAMES'.
            IF NOT gw_data-ctwrt99 IN lr_atwrt.
              IF <atwrt> <> '~'.
                lv_flag = 'ERROR'.
                EXIT.
              ENDIF.
            ENDIF.
          ELSE.
            IF NOT <value> IN lr_atwrt.
              IF <atwrt> <> '~'.
                lv_flag = 'ERROR'.
                EXIT.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSEIF <sngle> = '4'.    " 일치(OR)
          CLEAR: lv_char, lv_char1, lv_char2, lr_atwrt[].

          lv_char = <atwrt>.

          DO.
            IF lv_char IS INITIAL.
              EXIT.
            ENDIF.

            SPLIT lv_char AT ','  INTO lv_char1 lv_char2.

            lr_atwrt-sign = 'I'.
            lr_atwrt-option = 'EQ'.
            lr_atwrt-low = lv_char1.
            APPEND lr_atwrt.

            lv_char = lv_char2.
          ENDDO.

          IF NOT <value> IN lr_atwrt.
            IF <atwrt> <> '~'.
              lv_flag = 'ERROR'.
              EXIT.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDDO.

    IF lv_flag = space.
      gw_data-rslt3  = gt_ctwrt-seqno.
      gw_data-basmn  = gt_ctwrt-basmn.
      gw_data-meins  = gt_ctwrt-meins.
      gw_data-ruezt  = gt_ctwrt-ruezt.
      gw_data-optim  = gt_ctwrt-optim.
      gw_data-rdrnp  = gt_ctwrt-rdrnp.
      gw_data-usr07  = gt_ctwrt-zflux. "26.06.16 KSW
      gw_data-wktim  = gt_ctwrt-optim * gt_ctwrt-rdrnp.
      gw_data-meinh  = gt_ctwrt-meinh.
      gw_data-usr05  = gt_ctwrt-oprate.
      gw_data-flag230 = 'GOOD'.

      RETURN.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " search_suitable_ctwrt

*&---------------------------------------------------------------------*
*&      Form  search_suitable_atwrt_new
*&---------------------------------------------------------------------*
FORM search_suitable_atwrt_new.
  gw_data-seqno = gt_atwrt-seqno.
  gw_data-rslt1 = gt_atwrt-seqno.
  gw_data-plnal = gt_atwrt-plnal.
  gw_data-plnfl = gt_atwrt-plnfl.
  gw_data-vornr = gt_atwrt-vornr.
  gw_data-arbpl = gt_atwrt-arbpl.
  gw_data-ktext = gt_atwrt-ktext.
  gw_data-aznor = gt_atwrt-aznor.
  gw_data-flag210 = 'GOOD'.

  IF gw_data-verid IS INITIAL.
    gw_data-verid = gt_atwrt-verid.
  ENDIF.
ENDFORM.                    " search_suitable_atwrt_new

*&---------------------------------------------------------------------*
*&      Form  create_and_init_alv
*&---------------------------------------------------------------------*
FORM create_and_init_alv CHANGING pt_data   LIKE gt_data[]
                                  pt_fieldcat TYPE lvc_t_fcat
                                  ps_layout   TYPE lvc_s_layo.
  DATA: lt_sort    TYPE lvc_t_sort,
        lt_exclude TYPE ui_functions.

  REFRESH: pt_fieldcat, lt_exclude, lt_sort.

  CREATE OBJECT gs_container
    EXPORTING
      container_name = gc_container.

  CREATE OBJECT gs_grid
    EXPORTING
      i_parent = gs_container.

*&  선택버튼을 비활성화 한다.
  ps_layout-no_rowmark = 'X'.
  ps_layout-cwidth_opt = 'X'.
  ps_layout-ctab_fname = 'COLOR'.
  ps_layout-stylefname = 'CELLTAB'.

  gs_variant-report = sy-repid.

  PERFORM build_fieldcat        CHANGING pt_fieldcat.
  PERFORM set_cell_attributes.
  PERFORM exclude_tb_functions  CHANGING lt_exclude.
*  PERFORM build_sort_key        CHANGING lt_sort.

  CALL METHOD gs_grid->set_table_for_first_display
    EXPORTING
      is_layout            = ps_layout
      it_toolbar_excluding = lt_exclude
      is_variant           = gs_variant
      i_save               = 'A'
    CHANGING
      it_fieldcatalog      = pt_fieldcat
      it_sort              = lt_sort
      it_outtab            = pt_data.

  CALL METHOD gs_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  CREATE OBJECT gs_event_receiver.

  SET HANDLER: gs_event_receiver->handle_data_changed FOR gs_grid,
               gs_event_receiver->handle_toolbar      FOR gs_grid,
               gs_event_receiver->handle_user_command FOR gs_grid.

  CALL METHOD gs_grid->set_row_resize.
  CALL METHOD gs_grid->set_toolbar_interactive.

ENDFORM.                               "CREATE_AND_INIT_ALV

*&---------------------------------------------------------------------*
*&      Form  build_fieldcat
*&---------------------------------------------------------------------*
FORM build_fieldcat  CHANGING pt_fieldcat TYPE lvc_t_fcat.
  DATA: lv_210     TYPE numc2,
        lv_220     TYPE numc2,
        lv_230     TYPE numc2,
        ls_fcat    LIKE lvc_s_fcat,
        lv_atwrt   TYPE zppt0031-atwrt,
        lv_col_pos TYPE lvc_s_fcat-col_pos.

  CLEAR: ls_fcat, lv_210, lv_220, lv_230.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZPPS010'
    CHANGING
      ct_fieldcat      = pt_fieldcat.

  READ TABLE pt_fieldcat INTO ls_fcat WITH KEY fieldname = 'FHANK'.
  IF sy-subrc IS INITIAL.
    INSERT VALUE #( BASE ls_fcat fieldname = 'TUHNK'
                                 ref_table = 'ZPPT0036'
                                 ref_field = 'TUHNK'    ) INTO pt_fieldcat INDEX sy-tabix.
  ENDIF.

  LOOP AT pt_fieldcat INTO ls_fcat.
    CLEAR: lv_atwrt.

    CASE ls_fcat-fieldname(5).
      WHEN 'CHK'.
        ls_fcat-key = 'X'.
        ls_fcat-checkbox = 'X'.
        ls_fcat-edit = 'X'.
        ls_fcat-coltext = '선택'.
        ls_fcat-outputlen = 4.
      WHEN 'MATNR' OR 'INDI'.
        ls_fcat-key = 'X'.
      WHEN 'SEQNO' OR 'DISPO' OR 'FLAG' OR 'ZAEHL'.
        DELETE pt_fieldcat  INDEX sy-tabix.
        CONTINUE.
      WHEN 'ATWRT'.
        IF ls_fcat-fieldname+5(2) > gv_210cols.
          DELETE pt_fieldcat  INDEX sy-tabix.
          CONTINUE.
        ENDIF.

        lv_210 = lv_210 + 1.
        ls_fcat-emphasize = 'C400'.

        READ TABLE gt_atnam  WITH KEY seqno = lv_210.

        CONCATENATE: '【' lv_210 '】' gt_atnam-atbez  INTO lv_atwrt.
        ls_fcat-coltext = lv_atwrt.
      WHEN 'BTWRT'.
        IF ls_fcat-fieldname+5(2) > gv_220cols.
          DELETE pt_fieldcat  INDEX sy-tabix.
          CONTINUE.
        ENDIF.

        lv_220 = lv_220 + 1.
        ls_fcat-emphasize = 'C700'.

        READ TABLE gt_btnam  WITH KEY seqno = lv_220.

        CONCATENATE: '【' lv_220 '】' gt_btnam-atbez  INTO lv_atwrt.
        ls_fcat-coltext = lv_atwrt.
      WHEN 'CTWRT'.
        IF ls_fcat-fieldname+5(2) > gv_230cols.
          DELETE pt_fieldcat  INDEX sy-tabix.
          CONTINUE.
        ENDIF.

        lv_230 = lv_230 + 1.
        ls_fcat-emphasize = 'C500'.

        READ TABLE gt_ctnam  WITH KEY seqno = lv_230.

        CONCATENATE: '【' lv_230 '】' gt_ctnam-atbez  INTO lv_atwrt.
        ls_fcat-coltext = lv_atwrt.
      WHEN 'ARBPL'.
        ls_fcat-edit = 'X'.
        ls_fcat-emphasize = 'C401'.
      WHEN 'PLNAL'.
        ls_fcat-coltext = '그룹카운터'.
        ls_fcat-just = 'R'.
      WHEN 'VERID'.
        ls_fcat-just = 'R'.
      WHEN 'VORNR'.
        ls_fcat-coltext = '소공정'.
        ls_fcat-just = 'R'.
      WHEN 'PLNFL'.
        ls_fcat-coltext = '대체'.
        ls_fcat-just = 'R'.
      WHEN 'BASMN' OR 'MEINS' OR 'RUEZT' OR 'OPTIM' OR
           'WKTIM' OR 'MEINH'.
        ls_fcat-edit = 'X'.
        ls_fcat-emphasize = 'C701'.
        ls_fcat-no_zero = 'X'.

        IF ls_fcat-fieldname = 'MEINS'.
          ls_fcat-coltext = '기본단위'.
        ENDIF.
        IF ls_fcat-fieldname = 'MEINH'.
          ls_fcat-coltext = '시간단위'.
        ENDIF.

      WHEN 'TUHNK'.
        ls_fcat-edit = 'X'.
        ls_fcat-emphasize = 'C501'.
        ls_fcat-no_zero = 'X'.
        ls_fcat-coltext = TEXT-f05.
        ls_fcat-reptext = TEXT-f05.
      WHEN 'FHANK'.
        ls_fcat-edit = 'X'.
        ls_fcat-emphasize = 'C501'.
        ls_fcat-no_zero = 'X'.
        ls_fcat-tech = 'X'.
      WHEN 'QMMGN'.
        ls_fcat-edit = 'X'.
        ls_fcat-emphasize = 'C501'.
        ls_fcat-no_zero = 'X'.
      WHEN 'MESSA'.
        ls_fcat-coltext = '처리결과'.
      WHEN 'RSLT1'.
        ls_fcat-emphasize = 'C400'.
        ls_fcat-coltext = '가능설비'.
      WHEN 'RSLT2'.
        ls_fcat-emphasize = 'C700'.
        ls_fcat-coltext = '길이관리'.
      WHEN 'RSLT3'.
        ls_fcat-emphasize = 'C500'.
        ls_fcat-coltext = '시간관리'.
    ENDCASE.

    MODIFY pt_fieldcat FROM ls_fcat.

    IF lv_col_pos LT ls_fcat-col_pos.
      lv_col_pos = ls_fcat-col_pos.
    ENDIF.
  ENDLOOP.

  lv_col_pos += 1.
  APPEND INITIAL LINE TO pt_fieldcat REFERENCE INTO DATA(lr_fieldcat).
  lr_fieldcat->col_pos    = lv_col_pos.
  lr_fieldcat->fieldname  = 'USR05'.
  lr_fieldcat->coltext    = TEXT-f01.
  lr_fieldcat->edit       = abap_true.
  lr_fieldcat->no_zero    = abap_true.
  lr_fieldcat->ref_field  = 'USR05'.
  lr_fieldcat->ref_table  = 'PLPO'.
  lr_fieldcat->qfieldname = 'USE05'.

  lv_col_pos += 1.
  APPEND INITIAL LINE TO pt_fieldcat REFERENCE INTO lr_fieldcat.
  lr_fieldcat->col_pos    = lv_col_pos.
  lr_fieldcat->fieldname  = 'USE05'.
  lr_fieldcat->coltext    = TEXT-f02.
  lr_fieldcat->edit       = abap_true.
  lr_fieldcat->ref_field  = 'USE05'.
  lr_fieldcat->ref_table  = 'PLPO'.
  lr_fieldcat->tech       = abap_true.

*** 2026.06.16. KSW 필드 추가
  lv_col_pos += 1.
  APPEND INITIAL LINE TO pt_fieldcat REFERENCE INTO lr_fieldcat.
  lr_fieldcat->col_pos    = lv_col_pos.
  lr_fieldcat->fieldname  = 'USR07'.
  lr_fieldcat->coltext    = TEXT-f02.
  lr_fieldcat->edit       = abap_true.
  lr_fieldcat->ref_field  = 'USR07'.
  lr_fieldcat->ref_table  = 'PLPO'.
  lr_fieldcat->tech       = abap_true.
*** 2026.06.16. KSW 필드 추가

  lv_col_pos += 1.
  APPEND INITIAL LINE TO pt_fieldcat REFERENCE INTO lr_fieldcat.
  lr_fieldcat->col_pos    = lv_col_pos.
  lr_fieldcat->fieldname  = 'ARBPL_ICON'.
  lr_fieldcat->coltext    = TEXT-f03.
  lr_fieldcat->outputlen  = 10.
  lr_fieldcat->datatype   = 'CHAR'.
  lr_fieldcat->inttype    = 'C'.
  lr_fieldcat->intlen     = 10.
  lr_fieldcat->just       = 'C'.

  lv_col_pos += 1.
  APPEND INITIAL LINE TO pt_fieldcat REFERENCE INTO lr_fieldcat.
  lr_fieldcat->col_pos    = lv_col_pos.
  lr_fieldcat->fieldname  = 'VERID_ICON'.
  lr_fieldcat->coltext    = TEXT-f04.
  lr_fieldcat->outputlen  = 10.
  lr_fieldcat->datatype   = 'CHAR'.
  lr_fieldcat->intlen     = 10.
  lr_fieldcat->just       = 'C'.

ENDFORM.                    " build_fieldcat

*&---------------------------------------------------------------------*
*&      Form  set_cell_attributes
*&---------------------------------------------------------------------*
FORM set_cell_attributes.
  DATA: lv_tabix           TYPE i.

  LOOP AT gt_data.
    CLEAR: gt_celltab[], gt_color[].

    lv_tabix = sy-tabix.

    PERFORM initial_color  CHANGING gt_color.

    IF gt_data-zaehl < 1   OR
       ( gt_data-plnal = 1  AND
         gt_data-plnfl = 0  AND
         gt_data-vornr = 10 ).
      IF gt_data-indi = '등록'  AND
         gp_new       = 'X'.
        PERFORM initial_style  CHANGING gt_celltab.
      ENDIF.
    ELSE.
      PERFORM initial_style  CHANGING gt_celltab.
    ENDIF.

    CLEAR: gt_data-celltab[], gt_data-color[].

    INSERT LINES OF gt_celltab INTO TABLE gt_data-celltab.
    INSERT LINES OF gt_color   INTO TABLE gt_data-color.

    MODIFY gt_data  INDEX lv_tabix.
  ENDLOOP.
ENDFORM.                    " set_cell_attributes

*&---------------------------------------------------------------------*
*&      Form  exclude_tb_functions
*&---------------------------------------------------------------------*
FORM exclude_tb_functions  CHANGING pt_exclude TYPE ui_functions.
  DATA: ls_exclude             TYPE ui_func.

  ls_exclude = cl_gui_alv_grid=>mc_fc_detail.
  APPEND ls_exclude TO pt_exclude.

*  ls_exclude = cl_gui_alv_grid=>mc_fc_find.
*  APPEND ls_exclude TO pt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_check.
  APPEND ls_exclude TO pt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO pt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO pt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO pt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO pt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO pt_exclude.

*  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
*  APPEND ls_exclude TO pt_exclude.
*
*  ls_exclude = cl_gui_alv_grid=>mc_fc_sort_asc.
*  APPEND ls_exclude TO pt_exclude.
*
*  ls_exclude = cl_gui_alv_grid=>mc_fc_sort_dsc.
*  APPEND ls_exclude TO pt_exclude.
*
  ls_exclude = cl_gui_alv_grid=>mc_fc_print.
  APPEND ls_exclude TO pt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_graph.
  APPEND ls_exclude TO pt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_views.
  APPEND ls_exclude TO pt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_subtot.
  APPEND ls_exclude TO pt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_mb_sum.
  APPEND ls_exclude TO pt_exclude.

*  ls_exclude = cl_gui_alv_grid=>mc_mb_export.
*  APPEND ls_exclude TO pt_exclude.

*  ls_exclude = cl_gui_alv_grid=>mc_mb_filter.
*  APPEND ls_exclude TO pt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO pt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO pt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO pt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO pt_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND ls_exclude TO pt_exclude.
ENDFORM.                    " exclude_tb_functions

*&---------------------------------------------------------------------*
*&      Form  build_sort_key
*&---------------------------------------------------------------------*
FORM build_sort_key  CHANGING pt_sort  TYPE lvc_t_sort.
  DATA: ls_sort               LIKE lvc_s_sort.

  ls_sort-fieldname = 'MATNR'.
  ls_sort-up = 'X'.
  APPEND ls_sort TO pt_sort.

  ls_sort-fieldname = 'MAKTX'.
  ls_sort-up = 'X'.
  APPEND ls_sort TO pt_sort.
ENDFORM.                    " build_sort_key

*&---------------------------------------------------------------------*
*&      Form  initial_style
*&---------------------------------------------------------------------*
FORM initial_style  CHANGING pt_celltab TYPE lvc_t_styl.
  DATA: lv_tabix   TYPE i,
        ls_celltab TYPE lvc_s_styl.

  ls_celltab-fieldname = 'CHK'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.

  ls_celltab-fieldname = 'STLAL'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.
ENDFORM.                    " initial_style

*&---------------------------------------------------------------------*
*&      Form  initial_color
*&---------------------------------------------------------------------*
FORM initial_color  CHANGING pt_color TYPE lvc_t_scol.
  DATA: lv_tabix TYPE i,
        ls_color TYPE lvc_s_scol.

  ls_color-fname = 'INDI'.

  IF gt_data-flag = 'ERROR'.
    ls_color-color-col = 6.
  ELSEIF gt_data-flag = 'GOOD'.
    IF gt_data-message IS INITIAL.
      ls_color-color-col = 4.
    ELSE.
      ls_color-color-col = 3.
    ENDIF.
  ELSEIF gt_data-flag = 'SUCC'.
    ls_color-color-col = 5.
  ENDIF.

  IF gt_data-indi  = '등록'  AND
     gt_data-flag <> 'ERROR'.
    IF gt_data-zaehl < 1   OR
       ( gt_data-plnal = 1  AND
         gt_data-plnfl = 0  AND
         gt_data-vornr = 10 ).
      ls_color-color-col = 2.
    ENDIF.
  ENDIF.

  ls_color-color-int = 1.

  INSERT ls_color  INTO TABLE pt_color.
ENDFORM.                    " initial_color

*&---------------------------------------------------------------------*
*&      Form  change_chk_field
*&---------------------------------------------------------------------*
FORM change_chk_field  USING pv_chk
                             pv_tabix.
  READ TABLE gt_data  INDEX pv_tabix.

  gt_data-chk = pv_chk.
  MODIFY gt_data  TRANSPORTING chk
                         WHERE matnr = gt_data-matnr.
ENDFORM.                    " change_chk_field

*&---------------------------------------------------------------------*
*&      Form  read_routing_atwrt
*&---------------------------------------------------------------------*
FORM read_routing_atwrt.
  DATA: lv_char1 TYPE char10,
        lv_char2 TYPE char10,
        lv_atcnt TYPE i,     " 변경할 라인수
        lv_dtcnt TYPE i,    " 선택한 자료의 라인수
        lt_atwrt LIKE gt_atwrt  OCCURS 0 WITH HEADER LINE,
        lv_plnnr TYPE plas-plnnr.

  CLEAR: lv_atcnt, lv_dtcnt, lt_atwrt, lt_atwrt[], gt_comp[].

  SORT gt_atwrt BY seqno.
  SORT gt_btwrt BY seqno.
  SORT gt_ctwrt BY seqno.

  gw_temp = gw_data.

  PERFORM search_suitable_atwrt.

  IF gw_data-arbpl IS NOT INITIAL.       " 특성조합이 존재하면
    LOOP AT gt_temp  INTO gt_comp
                    WHERE matnr = gw_temp-matnr.
      APPEND gt_comp.
    ENDLOOP.

    LOOP AT gt_atwrt  INTO lt_atwrt
                     WHERE seqno = gw_data-seqno.
      APPEND lt_atwrt.
    ENDLOOP.

    DESCRIBE TABLE lt_atwrt LINES lv_atcnt.
    DESCRIBE TABLE gt_comp  LINES lv_dtcnt.

*&   변경하고자 하는 라우팅의 대체/소공정의 갯수가 시뮬레이션 결과의
*&   대체/소공정의 갯수와 다르면 변경을 할 수 없고 삭제 후 재생성
*& 2008.04.18

    IF gp_seq NE abap_true. "// Modified by ZGODEV06 on 2026-01-16
      IF lv_atcnt <> lv_dtcnt. " AND
*        GP_WERKS  NE '1801' AND      "산특 시뮬레이션 테스트용
*       GP_SEQ IS INITIAL.
        WRITE: lv_atcnt  TO lv_char1 NO-GROUPING LEFT-JUSTIFIED,
               lv_dtcnt  TO lv_char2 NO-GROUPING LEFT-JUSTIFIED.

        CONCATENATE '현재[' lv_char2 ']<=>변경[' lv_char1 ']가 틀리므'
                    '로 순서추가로 작업하세요.'
                                            INTO gt_data-message.
        gt_data-flag = gw_temp-flag.

        MODIFY gt_data TRANSPORTING flag
                                    message
                              WHERE matnr  = gw_temp-matnr
                                AND plnnr  = gw_temp-plnnr
                                AND plnal  = gw_temp-plnal.
        EXIT.
      ENDIF.
    ENDIF. "// Modified by ZGODEV06 on 2026-01-16

    LOOP AT gt_atwrt  WHERE seqno = gw_data-seqno.
      gw_data = gw_temp.

      CLEAR: gw_data-flag210, gw_data-flag220, gw_data-flag230.

      PERFORM search_suitable_atwrt_new.
      PERFORM search_suitable_btwrt.
      PERFORM search_suitable_ctwrt.

      IF gw_data-flag210 = 'GOOD'  AND
         gw_data-flag220 = 'GOOD'  AND
         gw_data-flag230 = 'GOOD'.
        gw_data-flag = 'GOOD'.
      ENDIF.

      gw_data-plnnr1 = gw_data-plnnr.
      gw_data-plnal1 = gw_data-plnal.
      gw_data-modify = 'X'.

      IF gw_data-plnal = 1  AND
         gw_data-plnfl = 0  AND
         gw_data-vornr = 10.
        gw_data-chk = 'X'.
        gw_data-zaehl = 1.
      ELSE.
        gw_data-chk = space.
        gw_data-zaehl = 2.
      ENDIF.

*& 2008,.04.18
      IF gp_seq IS NOT INITIAL.

        CLEAR lv_plnnr.

        SELECT SINGLE plnnr
          INTO lv_plnnr
          FROM plas
         WHERE plnnr = gw_data-plnnr
           AND plnal = gw_data-plnal
           AND plnfl = gw_data-plnfl.

        IF lv_plnnr IS INITIAL.
          "기존 라우팅에 없고 그룹카운터가 있을 경우만

          SELECT SINGLE plnnr
            INTO lv_plnnr
            FROM plas
          WHERE plnnr = gw_data-plnnr
            AND plnal = gw_data-plnal.

          IF lv_plnnr IS NOT INITIAL.

            gw_data-indi = '추가'.
          ENDIF.
        ENDIF.
      ENDIF.

      APPEND gw_data TO gt_data.

    ENDLOOP.

    DELETE gt_data WHERE matnr   = gw_temp-matnr
                     AND modify IS INITIAL.
  ELSE.
    gt_data-flag = gw_temp-flag.

    MODIFY gt_data TRANSPORTING flag
                          WHERE matnr  = gw_temp-matnr
                            AND plnnr  = gw_temp-plnnr
                            AND plnal  = gw_temp-plnal.
  ENDIF.
ENDFORM.                    " read_routing_atwrt

*&---------------------------------------------------------------------*
*&      Form  read_new_routing_atwrt
*&---------------------------------------------------------------------*
FORM read_new_routing_atwrt.
  CLEAR: gw_temp.

  SORT gt_atwrt BY seqno.
  SORT gt_btwrt BY seqno.
  SORT gt_ctwrt BY seqno.

  gw_temp = gw_data.

  PERFORM search_suitable_atwrt.

  IF gw_data-arbpl IS NOT INITIAL.       " 특성조합이 존재하면
    LOOP AT gt_atwrt  WHERE seqno = gw_data-seqno.
      gw_data = gw_temp.

      CLEAR: gw_data-flag210, gw_data-flag220, gw_data-flag230.

      PERFORM search_suitable_atwrt_new.
      PERFORM search_suitable_btwrt.
      PERFORM search_suitable_ctwrt.

      IF gw_data-flag210 = 'GOOD'  AND
         gw_data-flag220 = 'GOOD'  AND
         gw_data-flag230 = 'GOOD'.
        gw_data-flag = 'GOOD'.
      ENDIF.

      IF gw_data-plnal = 1  AND
         gw_data-plnfl = 0  AND
         gw_data-vornr = 10.
        gw_data-zaehl = 1.
        MODIFY gt_data FROM gw_data  INDEX gv_tabix.
      ELSE.
        gw_data-chk = space.
        gw_data-zaehl = 2.

        APPEND gw_data TO gt_data.
      ENDIF.
    ENDLOOP.
  ELSE.
    MODIFY gt_data FROM gw_temp  INDEX gv_tabix.
  ENDIF.
ENDFORM.                    " read_new_routing_atwrt

*&---------------------------------------------------------------------*
*&      Form  prepare_routing_create
*&---------------------------------------------------------------------*
FORM prepare_routing_create.
  DATA: lt_data  LIKE gt_data OCCURS 0 WITH HEADER LINE,
        lv_aznor TYPE kako-aznor,
        lv_vercd TYPE numc4,      " 자작공정
        lv_outcd TYPE numc4,      " 외주공정
        lv_errcd TYPE numc4,      " 오류
        lv_tabix TYPE i.

  READ TABLE gt_data  WITH KEY chk  = 'X'
                               flag = 'GOOD'.
  IF sy-subrc <> 0.
    MESSAGE s000 WITH '라우팅 생성 대상자료가 없습니다.'.
    RETURN.
  ENDIF.

  CLEAR: gw_qpmz, gt_save[], gt_exec[], gt_temp[], lt_data[].

  gt_save[] = gt_data[].

**&  마지막 공정의 공정검사를 설정하기 위해 검사정보를 읽는다.
*  SELECT SINGLE *
*    INTO gw_qpmz
*    FROM qpmz
*   WHERE zaehler  = gp_werks
*     AND mkmnr    = 'ZPP0001'
*     AND werkpm   = gp_werks
*     AND version  = ( SELECT MAX( version )
*                        FROM qpmz
*                       WHERE zaehler  = gp_werks
*                         AND mkmnr    = 'ZPP0001'
*                         AND werkpm   = gp_werks ).
*  IF gw_qpmz IS INITIAL.
*    MESSAGE s000 WITH '검사특성/검사방법을 지정하세요.'.
*    RETURN.
*  ENDIF.

  DATA lv_answer TYPE char01.

  PERFORM  popup_to_confirm USING TEXT-c02 lv_answer.

  CHECK lv_answer EQ '1'.

  LOOP AT gt_data  WHERE chk  = 'X'
                     AND flag = 'GOOD'.
    CLEAR: lv_vercd, lv_outcd, lv_errcd, gt_mkalu[], gt_mkali[].

*&  처리 후 처리여부 체크위해
    lt_data = gt_data.
    APPEND lt_data.

    gt_exec[] = gt_save[].
    DELETE gt_exec  WHERE matnr <> gt_data-matnr.

*&  시뮬레이션 결과 적합한 라우팅을 찾지 못했으면
    READ TABLE gt_exec  WITH KEY flag = 'ERROR'.
    IF sy-subrc = 0.
      MESSAGE s000 WITH '자재[' gt_data-matnr '] 오류포함; 처리' '불가능 합니다.'.
      RETURN.
    ENDIF.

    IF gv_crlyn = 'X'.
      PERFORM read_characteristics_for_crl  USING lv_aznor.
    ENDIF.

    LOOP AT gt_exec WHERE plnfl  = 0
                      AND vornr  = 10.
      IF gt_exec-arbpl(3) = 'DUM'.
        lv_outcd = lv_outcd + 1.
        gt_exec-vercd = lv_outcd.
      ELSEIF gt_exec-beskz = 'E'  OR
             gt_exec-beskz = 'X'.
        lv_vercd = lv_vercd + 1.
        gt_exec-vercd = lv_vercd.
      ELSE.
        lv_errcd = lv_errcd + 1.
        gt_exec-vercd = lv_errcd.
      ENDIF.

      IF gv_crlyn = 'X'.
        gt_exec-aznor = lv_aznor.
      ENDIF.

      MODIFY gt_exec  INDEX sy-tabix.
    ENDLOOP.

*&  마지막 소공정의 경우 공정검사를 하기위해 체크
    PERFORM decide_last_work_center.

    IF gt_data-indi = '등록'.
      PERFORM bdc_routing_delete_by_ca02.

      IF gv_error = 0.
        gt_data-indi = '신규'.
        PERFORM bdc_routing_create_by_ca01.
        PERFORM compute_create_routing.
      ENDIF.
    ELSE.
      PERFORM bdc_routing_create_by_ca01.
      PERFORM compute_create_routing.
    ENDIF.

    APPEND LINES OF gt_exec TO gt_temp.
  ENDLOOP.

  LOOP AT gt_temp  INTO gw_data.
    READ TABLE gt_data  WITH KEY matnr = gw_data-matnr
                                 plnal = gw_data-plnal
                                 plnfl = gw_data-plnfl
                                 vornr = gw_data-vornr.
    IF sy-subrc = 0.
      lv_tabix = sy-tabix.

      gt_data-plnnr   = gw_data-plnnr.
      gt_data-plnal   = gw_data-plnal.
      gt_data-verid   = gw_data-verid.
      gt_data-message = gw_data-message.

      gt_data-arbpl_icon = gw_data-arbpl_icon.
      gt_data-verid_icon = gw_data-verid_icon.
      gt_data-arbpl_ind  = gw_data-arbpl_ind.
      gt_data-arbpl_stat = gw_data-arbpl_stat.
      gt_data-verid_ind  = gw_data-verid_ind.
      gt_data-verid_stat = gw_data-verid_stat.

      IF gt_data-message IS INITIAL.
        gt_data-chk  = space.
        gt_data-flag = 'SUCC'.

        IF NOT gt_data-plnnr IS INITIAL.
          gt_data-indi = '등록'.
        ENDIF.
      ENDIF.

      MODIFY gt_data  INDEX lv_tabix.

*// Routing 생성,변경 이력
      PERFORM insert_process_log USING gt_data.
    ENDIF.
  ENDLOOP.

  LOOP AT lt_data.
    gt_data-message = '직무그룹이 생성되지 않았습니다.'.

    MODIFY gt_data  TRANSPORTING message
                    WHERE matnr = lt_data-matnr
                      AND plnnr = space.
  ENDLOOP.

ENDFORM.                    " prepare_routing_create

*&---------------------------------------------------------------------*
*&      Form  prepare_routing_modify
*&---------------------------------------------------------------------*
FORM prepare_routing_modify.
  DATA: lt_data  LIKE gt_data OCCURS 0 WITH HEADER LINE,
        lw_temp  LIKE gt_data,
        lv_aznor TYPE kako-aznor,
        lv_vercd TYPE numc4,      " 자작공정
        lv_outcd TYPE numc4,      " 외주공정
        lv_errcd TYPE numc4,      " 오류
        lv_tabix TYPE i.

  CLEAR: lw_temp, lt_data, lt_data[].

*& 선택된 자료가 있으면 시뮬레이션 결과 오류가 있는지를 확인한다.
  LOOP AT gt_data  INTO lw_temp
                  WHERE chk = 'X'.
    lv_tabix = sy-tabix.

    LOOP AT gt_data  INTO lt_data
                    WHERE matnr = lw_temp-matnr.
      IF lt_data-flag = 'ERROR'.
        lw_temp-chk = space.
        MODIFY gt_data FROM lw_temp INDEX lv_tabix.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  READ TABLE gt_data  WITH KEY chk = 'X'.

  IF sy-subrc <> 0.
    MESSAGE s000 WITH '라우팅 변경 대상자료가 없습니다.'.
    RETURN.
  ENDIF.

  DATA lv_answer TYPE char01.

  PERFORM popup_to_confirm USING TEXT-c03 lv_answer.

  CHECK lv_answer EQ '1'.

  CLEAR: gt_save[], gt_exec[], gt_temp[], lt_data[].

  gt_save[] = gt_data[].

  LOOP AT gt_data WHERE chk  = 'X'.
    CLEAR: lv_vercd, lv_outcd, lv_errcd.

*&  처리 후 처리여부 체크위해
    lt_data = gt_data.
    APPEND lt_data.

    gt_exec[] = gt_save[].
    DELETE gt_exec WHERE matnr <> gt_data-matnr
                     AND plnnr <> gt_data-plnnr.

    IF gv_crlyn = 'X'.
      PERFORM read_characteristics_for_crl USING lv_aznor.
    ENDIF.

    LOOP AT gt_exec WHERE plnfl = 0
                      AND vornr = 10.
      IF gt_exec-arbpl(3) = 'DUM'.
        lv_outcd = lv_outcd + 1.
        gt_exec-vercd = lv_outcd.
      ELSEIF gt_exec-beskz = 'E'  OR
             gt_exec-beskz = 'X'.
        lv_vercd = lv_vercd + 1.
        gt_exec-vercd = lv_vercd.
      ELSE.
        lv_errcd = lv_errcd + 1.
        gt_exec-vercd = lv_errcd.
      ENDIF.

      IF gv_crlyn = 'X'.
        gt_exec-aznor = lv_aznor.
      ENDIF.

      MODIFY gt_exec  INDEX sy-tabix.
    ENDLOOP.

*&  마지막 소공정의 경우 공정검사를 하기위해 체크
    PERFORM decide_last_work_center.

*&  라우팅 변경 BDC 실행
    PERFORM bdc_routing_modify_by_ca02.

    APPEND LINES OF gt_exec TO gt_temp.
  ENDLOOP.

  LOOP AT gt_temp  INTO gw_data.
    READ TABLE gt_data  WITH KEY matnr = gw_data-matnr
                                 plnal = gw_data-plnal
                                 plnfl = gw_data-plnfl
                                 vornr = gw_data-vornr.
    IF sy-subrc = 0.
      lv_tabix = sy-tabix.

      gt_data-plnnr   = gw_data-plnnr.
      gt_data-plnal   = gw_data-plnal.
      gt_data-verid   = gw_data-verid.
      gt_data-message = gw_data-message.

      gt_data-arbpl_icon = gw_data-arbpl_icon.
      gt_data-verid_icon = gw_data-verid_icon.
      gt_data-arbpl_ind  = gw_data-arbpl_ind.
      gt_data-arbpl_stat = gw_data-arbpl_stat.
      gt_data-verid_ind  = gw_data-verid_ind.
      gt_data-verid_stat = gw_data-verid_stat.

      IF gt_data-message IS INITIAL.
        gt_data-chk    = space.
        gt_data-flag   = 'SUCC'.
        gt_data-modify = space.
      ENDIF.

      MODIFY gt_data  INDEX lv_tabix.

*// Routing 생성,변경 이력
      PERFORM insert_process_log USING gt_data.
    ENDIF.
  ENDLOOP.

*& 직무그룹이 생성되지 않았으면
  LOOP AT lt_data.
    gt_data-message = '라우팅이 변경되지 않았습니다.'.

    MODIFY gt_data  TRANSPORTING message
                    WHERE matnr = lt_data-matnr
                      AND plnnr = space.
  ENDLOOP.

ENDFORM.                    " prepare_routing_modify

*&---------------------------------------------------------------------*
*&      Form  append_insert_prod_version
*&---------------------------------------------------------------------*
FORM append_insert_prod_version  CHANGING pv_verid.
  DATA: lt_plko    TYPE plko OCCURS 0 WITH HEADER LINE,
        lv_zaehl   TYPE mkal_aend-zaehl,
        lv_minid   TYPE mkal-verid,
        lv_stlal   TYPE mast-stlal,
        lv_stlalc  TYPE mast-stlal,
        lv_value   TYPE numc4,
        lv_plnid   TYPE numc4,
        lv_verid   TYPE mkal-verid,
        lv_xfeld   TYPE c,
        lv_message TYPE char100.

  DATA: lw_head  LIKE bapimathead,
        lt_plnt  LIKE bapi_marc  OCCURS 0 WITH HEADER LINE,
        lt_plntx LIKE bapi_marcx OCCURS 0 WITH HEADER LINE.

  CLEAR: lv_verid,   lv_value,  lv_minid,   lv_zaehl,  lv_stlal,
         lv_stlal,   lt_plko[], gt_mkalu[], gt_mkali[],
         gt_mkala[], gt_mkald[].

*&  BOM의 대체번호(STLAL)이 라우팅의 대체번호(PLNAL)과 동일한 것이
*&  BOM의 자재연결 테이블인 MAST에 있는지 확인한다.
  SELECT SINGLE stlal
    INTO lv_stlal
    FROM mast
   WHERE matnr  = gt_exec-matnr
     AND werks  = gp_werks
     AND stlal  = gt_exec-plnal.

*&  대체번호가 서로 같은 것이 MAST에 없으면, 가장 적은 BOM
*&  대체번호를 사용하도록 함.
  IF lv_stlal IS INITIAL.
    SELECT MIN( stlal )
      INTO lv_stlal
      FROM mast
     WHERE matnr  = gt_exec-matnr
       AND werks  = gp_werks.

    IF lv_stlal IS INITIAL.
      RETURN.
    ELSE.
      lv_stlalc = lv_stlal.
    ENDIF.
  ELSE.
    lv_stlalc = lv_stlal.
  ENDIF.

*& 2012/04/02 기기사업부 개선 TFT
  IF gv_spgcd EQ 'EC'.

*& 2012/05/16 기기사업부 개선 TFT 기기선 생산버젼 생성 보완
*& 생산버젼이 있는지 조회

    IF gt_exec-plnal EQ '01'.

      SELECT SINGLE verid
        INTO lv_verid
        FROM mkal
       WHERE matnr  = gt_exec-matnr
         AND werks  = gp_werks.
    ELSE.
      SELECT SINGLE verid
        INTO lv_verid
        FROM mkal
       WHERE matnr  = gt_exec-matnr
         AND werks  = gp_werks
         AND alnal  = gt_exec-plnal.
    ENDIF.

*& 2012/05/17 기기사업부 개선 TFT
*& 생산버젼이 없고 그룹카운터가 1이면 신규로 생성
*& 아니면 기존 생산버젼이 있으므로 update
    IF lv_verid IS INITIAL AND gt_exec-plnal = '01'.
      PERFORM  create_mkal CHANGING pv_verid.
    ELSEIF lv_verid IS INITIAL AND
           gt_exec-plnal NE  '01'.
      PERFORM  create_mkal2 CHANGING pv_verid.
    ELSEIF lv_verid IS NOT INITIAL.
      PERFORM  update_mkal CHANGING pv_verid.
    ENDIF.

  ELSE.

*& 2011.07.28 CSR:C20110725_32693
*& 자동차,기기선의 경우 최종대체 BOM으로 생산버젼 생성
* 2013.02.25 CSR:C20130221_77606
* 튜브도 최종대체 BOM으로 생산버젼 생성
    IF gv_spgcd EQ 'AU' OR gv_spgcd EQ 'RC' OR
       gv_spgcd EQ 'TB'.

      SELECT MAX( stlal )
        INTO lv_stlal
        FROM mast
      WHERE matnr = gt_exec-matnr
        AND werks = gp_werks
        AND stlan = '1'.

      SELECT MAX( stlal )
        INTO lv_stlalc
        FROM mast
      WHERE  matnr = gt_exec-matnr
        AND  werks = gp_werks
        AND stlan = '6'.
    ENDIF.

    IF gp_werks = '1901'.   "풍세전선은 bom 대체번호가 가장 큰거 기준

      SELECT MAX( a~stlal )
       INTO lv_stlal
       FROM mast AS a INNER JOIN stko AS b
                        ON a~stlnr = b~stlnr
                       AND a~stlal = b~stlal
     WHERE a~matnr = gt_exec-matnr
       AND a~werks = gp_werks
       AND a~stlan = '1'.

      SELECT MAX( a~stlal )
       INTO lv_stlal
       FROM mast AS a INNER JOIN stko AS b
                        ON a~stlnr = b~stlnr
                       AND a~stlal = b~stlal
     WHERE a~matnr = gt_exec-matnr
       AND a~werks = gp_werks
       AND a~stlan = '6'.
    ENDIF.

*& 계획용 버젼
    lv_plnid = '2999' + gt_exec-vercd.

    IF gt_exec-arbpl(3) = 'DUM'.
      lv_minid = '1999'.               " 외주공정
      lv_plnid = 0.
    ELSEIF gt_exec-beskz = 'E'  OR     " 조달유형
           gt_exec-beskz = 'X'.
      lv_minid = '0999'.
    ELSE.
      lv_minid = '099'.
      lv_plnid = 0.
    ENDIF.

*& 생산용 버젼
    IF gt_exec-verid IS INITIAL.
      lv_verid = lv_minid + gt_exec-vercd.
    ELSE.
      lv_verid = gt_exec-verid.
    ENDIF.

    pv_verid = lv_verid.

    SELECT *
      INTO TABLE gt_mkalu
      FROM mkal
     WHERE matnr  = gt_exec-matnr
       AND werks  = gp_werks
       AND verid  = lv_verid .
*     AND stlal  = gt_exec-plnal.  " comment by djcha 2006.01.20

    IF gt_mkalu[] IS INITIAL.
      SELECT *
        INTO TABLE lt_plko
        FROM plko
       WHERE plnty  = 'N'                " 공정
         AND plnnr  = gt_exec-plnnr
         AND plnal  = gt_exec-plnal.

      SELECT COUNT( * )
        INTO lv_zaehl
        FROM mkal_aend
       WHERE matnr = gt_exec-matnr
         AND werks = gp_werks
         AND verid = lv_verid.

      lv_value = lv_verid.
      lv_zaehl = lv_zaehl + 1.

      LOOP AT lt_plko.
        gt_mkali-matnr = gt_exec-matnr.
        gt_mkali-werks = gp_werks.
        gt_mkali-verid = lv_value.
        gt_mkali-bdatu = '99991231'.
        gt_mkali-adatu = sy-datum.
        gt_mkali-stlal = lv_stlal.
        gt_mkali-stlan = '1'.
        gt_mkali-plnty = 'N'.
        gt_mkali-plnnr = gt_exec-plnnr.
        gt_mkali-alnal = gt_exec-plnal.
        gt_mkali-bstmi = 1.
        gt_mkali-bstma = 9999999.
        gt_mkali-text1 = gv_name1.
        gt_mkali-prdat = sy-datum.
        gt_mkali-prfg_f = '1'.
        gt_mkali-prfg_s = '1'.

        APPEND gt_mkali.

        gt_mkala-matnr = gt_exec-matnr.
        gt_mkala-werks = gp_werks.
        gt_mkala-verid = lv_value.
        gt_mkala-zaehl = lv_zaehl.
        gt_mkala-datuv = sy-datum.
        gt_mkala-datub = '99991231'.
        gt_mkala-andat = sy-datum.
        gt_mkala-annam = sy-uname.
        gt_mkala-vbkz  = 'I'.

        APPEND gt_mkala.

        IF lv_plnid > '2999'.                 " 외주는 계획용 생성 무
          gt_mkali-matnr = gt_exec-matnr.
          gt_mkali-werks = gp_werks.
          gt_mkali-verid = lv_plnid.
          gt_mkali-bdatu = '99991231'.
          gt_mkali-adatu = sy-datum.
          gt_mkali-stlal = lv_stlalc.
          gt_mkali-stlan = '6'.              " 계획용
          gt_mkali-plnty = 'N'.
          gt_mkali-plnnr = gt_exec-plnnr.
          gt_mkali-alnal = gt_exec-plnal.
          gt_mkali-bstmi = 1.
          gt_mkali-bstma = 9999999.
          gt_mkali-text1 = gv_name1.
          gt_mkali-prdat = sy-datum.
          gt_mkali-prfg_f = '1'.
          gt_mkali-prfg_s = '1'.

          APPEND gt_mkali.
        ENDIF.
      ENDLOOP.
    ELSE.
      gt_mkalu-adatu = sy-datum.
      gt_mkalu-plnnr = gt_exec-plnnr.
      gt_mkalu-prdat = sy-datum.

      MODIFY gt_mkalu  TRANSPORTING adatu
                                    plnnr
                                    prdat
                       WHERE matnr <> space.

    ENDIF.
  ENDIF.


  CALL FUNCTION 'CM_FV_PROD_VERS_DB_UPDATE'
    TABLES
      it_mkal_i    = gt_mkali
      it_mkal_u    = gt_mkalu
      it_mkal_d    = gt_mkald
      it_mkal_aend = gt_mkala.

  LOOP AT gt_mkali.
    CLEAR: lw_head, lt_plnt[], lt_plntx[].

    lw_head-material = gt_mkali-matnr.
    lw_head-mrp_view = 'X'.

    lt_plnt-plant = gp_werks.
    APPEND lt_plnt.

    lt_plntx-plant = gp_werks.
    APPEND lt_plntx.

    CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
      EXPORTING
        headdata   = lw_head
        plantdata  = lt_plnt
        plantdatax = lt_plntx.

    CLEAR: lv_xfeld, lv_message.

    PERFORM read_table_gt_ret2  USING lv_xfeld
                                      lv_message.
  ENDLOOP.

  IF lv_xfeld = 'X'.
    PERFORM marking_version_indicator  USING gt_exec-message.
  ENDIF.
ENDFORM.                    " append_insert_prod_version

*&---------------------------------------------------------------------*
*&      Form  read_bom_prod_version
*&---------------------------------------------------------------------*
FORM read_bom_prod_version.
  SELECT SINGLE verid
    INTO gt_data-verid
    FROM mkal
   WHERE matnr  = gw_data-matnr
     AND werks  = gp_werks
     AND plnty  = 'N'
     AND plnnr  = gw_data-plnnr
     AND alnal  = gw_data-plnal
     AND stlan  = '1'.               " BOM 용도 ===> '1' (생산)
ENDFORM.                    " read_bom_prod_version

*&---------------------------------------------------------------------*
*&      Form  decide_last_work_center
*&---------------------------------------------------------------------*
FORM decide_last_work_center.
  DATA: lt_exec  LIKE gt_exec OCCURS 0 WITH HEADER LINE,
        lv_tabix TYPE sy-tabix,
        lv_vornr TYPE resb-vornr.

  CLEAR: lv_tabix, lv_vornr, lt_exec, lt_exec[].

  lt_exec[] = gt_exec[].

*& 소공정이 10번인 것만 작업대상으로한다. 소공정 10번인 것의 그룹카운터
*& 와 순서가 같은 소공정중 가장큰 소공정을 읽어서 VORNR1에 그 값을반영
  LOOP AT gt_exec  INTO gw_temp
                  WHERE vornr = 10.
    CLEAR: lv_tabix.

*&  같은 그룹카운터, 순서의 첫번째 레코드를 읽는다.
    READ TABLE lt_exec  WITH KEY plnal = gw_temp-plnal
                                 plnfl = gw_temp-plnfl
                          BINARY SEARCH.
    IF sy-subrc = 0.
      lv_tabix = sy-tabix.

*&     순차적으로 읽어내려가면서 그룹카운터, 순서가 같은지를 확인한다.
*&     바뀌면 맨마지막으로 읽은 소공정번호를 VORNR1에 반영한다.
      DO.
        READ TABLE lt_exec INDEX lv_tabix.

        IF sy-subrc = 0.
          IF lt_exec-plnal  = gw_temp-plnal  AND
             lt_exec-plnfl  = gw_temp-plnfl.
            lv_vornr = lt_exec-vornr.
            lv_tabix = lv_tabix + 1.
          ELSE.
            EXIT.
          ENDIF.
        ELSE.
          EXIT.
        ENDIF.
      ENDDO.

      gt_exec-vornr1 = lv_vornr.

      MODIFY gt_exec  TRANSPORTING vornr1
                      WHERE plnal = gw_temp-plnal
                        AND plnfl = gw_temp-plnfl.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " decide_last_work_center

*&---------------------------------------------------------------------*
*&      Form  read_characteristics_for_crl
*&---------------------------------------------------------------------*
FORM read_characteristics_for_crl  USING pv_aznor.
  DATA:
*-> CCM 2023.04.12 오바다 - char30
*        lv_unit               TYPE atwrt,
    lv_unit(30),
*        lv_range              TYPE atwrt,
    lv_range(30),
*<- CCM 2023.04.12 오바다
    lv_atflv     TYPE zdec16_6,
    lv_maktx     TYPE atwrt,
    lv_number    TYPE zdec16_6.

  CLEAR: lv_unit, lv_maktx, lv_range, lv_number, lv_atflv, pv_aznor,
         gt_ausp, gt_ausp[].

  CALL FUNCTION 'Z_PP_GET_CLASSIFICATION'
    EXPORTING
      if_klart          = '001'
      if_matnr          = gt_data-matnr
    TABLES
      it_atwrt          = gt_ausp
    EXCEPTIONS
      no_classification = 1
      OTHERS            = 2.

  LOOP AT gt_ausp WHERE atnam = 'PD_AA_STD_PRODUCT_NAME'
                     OR atnam = 'PD_TB_STD_EXP_INNER_DIA'.
    IF gt_ausp-atnam = 'PD_AA_STD_PRODUCT_NAME'.
      lv_maktx = gt_ausp-atwrt.
    ELSE.
      lv_range = gt_ausp-atwrt.
    ENDIF.
  ENDLOOP.

  IF lv_maktx IS INITIAL  OR
     lv_range IS INITIAL.
    EXIT.
  ENDIF.

  CALL FUNCTION 'Z_PP_SPLIT_NUM_UNIT'
    EXPORTING
      if_source = lv_range
    IMPORTING
      if_number = lv_number
      if_char   = lv_unit.

  SELECT SINGLE atflv
    INTO lv_atflv
    FROM zppt0006
   WHERE atnam  = 'PD_AA_STD_PRODUCT_NAME'
     AND atwrt  = lv_maktx
     AND atawe  = lv_unit(4).

  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  IF lv_number >= lv_atflv.
    pv_aznor = 2.
  ENDIF.
ENDFORM.                    " read_characteristics_for_crl

*&---------------------------------------------------------------------*
*&      Form  delete_group_count_by_ca01
*&---------------------------------------------------------------------*
FORM delete_group_count_by_ca01  USING pv_complete.

  READ TABLE gt_data  WITH KEY chk  = 'X'
                               flag = space.
  IF sy-subrc <> 0.
    MESSAGE s000 WITH '삭제 선택한 자료가 없습니다.'.
    RETURN.
  ENDIF.

  DATA lv_answer TYPE char01.

  PERFORM  popup_to_confirm USING TEXT-c04 lv_answer.

  CHECK lv_answer EQ '1'.

  CLEAR: gt_save[], gt_exec[], gt_temp[].

  gt_save[] = gt_data[].

  LOOP AT gt_data REFERENCE INTO DATA(lr_data)
                  WHERE chk  = 'X'
                    AND flag = space.
    CLEAR: gv_error.

    gt_exec[] = gt_save[].
    DELETE gt_exec  WHERE matnr NE lr_data->matnr
                      AND plnnr NE lr_data->plnnr.

    PERFORM bdc_delete_grc_by_ca01 USING lr_data->*.

    IF gv_error IS INITIAL.
      IF pv_complete = 'X'.
        PERFORM bdc_delete_grc_by_ca98 USING lr_data->*.
      ENDIF.

      IF gv_error IS INITIAL.
*& 2012/04/02 기기사업부 개선 tft
*& 튜브/자동차는 기존로직, 기기선은 생산버젼 미삭제
        IF gp_dispo+0(2) NE 'EC'.
*        PERFORM bdc_delete_version_by_c223.

          PERFORM submit_zgtppr1110 USING lr_data->* gc_proc_type-delete.

          MODIFY gt_exec FROM VALUE #( verid      = lr_data->verid
                                       verid_icon = lr_data->verid_icon
                                       verid_ind  = lr_data->verid_ind
                                       verid_stat = lr_data->verid_stat )
                         TRANSPORTING verid verid_icon verid_ind verid_stat
                         WHERE matnr EQ lr_data->matnr
                           AND plnnr EQ lr_data->plnnr.
        ENDIF.

        CHECK gv_error IS INITIAL.

        DELETE gt_data WHERE matnr = lr_data->matnr
                         AND plnnr = lr_data->plnnr.

        MESSAGE s021.
      ENDIF.
    ENDIF.

    APPEND LINES OF gt_exec TO gt_temp.
  ENDLOOP.

  LOOP AT gt_temp  INTO gw_data.
*// Routing 생성,변경 이력
    PERFORM insert_process_log USING gw_data.
  ENDLOOP.

ENDFORM.                    " delete_group_count_by_ca01
*&---------------------------------------------------------------------*
*&      Form  PREPARE_ROUTING_ADD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM prepare_routing_add .
  DATA: lt_data  LIKE gt_data OCCURS 0 WITH HEADER LINE,
        lv_aznor TYPE kako-aznor,
        lv_vercd TYPE numc4,      " 자작공정
        lv_outcd TYPE numc4,      " 외주공정
        lv_errcd TYPE numc4,      " 오류
        lv_tabix TYPE i,
        lv_matnr TYPE mara-matnr,
        lt_temp  LIKE gt_data OCCURS 0 WITH HEADER LINE,
        lv_chk   TYPE c.

  CLEAR : lv_chk.

  lt_temp[] = gt_data[].

  LOOP AT lt_temp  WHERE  indi = '추가' AND
                          flag = 'GOOD'.
    lv_matnr = gt_data-matnr.

    IF sy-subrc <> 0.
      lv_chk = '1'.
      EXIT.
    ELSE.
      READ TABLE gt_data  WITH KEY chk = 'X'
                                    flag = 'GOOD'
                                    matnr = lv_matnr.
      IF sy-subrc <> 0.
        lv_chk = '2'.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF sy-subrc IS NOT INITIAL AND lv_chk IS INITIAL.
    MESSAGE s000 WITH '라우팅 순서추가 대상자료가 없습니다.'.
    RETURN.
  ENDIF.

  IF lv_chk EQ '1'.
    MESSAGE s000 WITH '라우팅 순서추가 대상자료가 없습니다.'.
    RETURN.
*  ELSEIF lv_chk EQ '2'.
*    MESSAGE s000 WITH '라우팅 순서추가 대상자료가 없습니다.'.
*    RETURN.
  ENDIF.

  CLEAR: gw_qpmz, gt_save[], gt_exec[], gt_temp[], lt_data[].

  gt_save[] = gt_data[].

**&  마지막 공정의 공정검사를 설정하기 위해 검사정보를 읽는다.
*  SELECT SINGLE *
*    INTO gw_qpmz
*    FROM qpmz
*   WHERE zaehler  = gp_werks
*     AND mkmnr    = 'ZPP0001'
*     AND werkpm   = gp_werks
*     AND version  = ( SELECT MAX( version )
*                        FROM qpmz
*                       WHERE zaehler  = gp_werks
*                         AND mkmnr    = 'ZPP0001'
*                         AND werkpm   = gp_werks ).

*  IF gw_qpmz IS INITIAL.
*    MESSAGE s000 WITH '검사특성/검사방법을 지정하세요.'.
*    RETURN.
*  ENDIF.

  DATA lv_answer TYPE char01.

  PERFORM  popup_to_confirm USING TEXT-c05 lv_answer.

  CHECK lv_answer EQ '1'.

  LOOP AT gt_data  WHERE chk  = 'X'
                     AND flag = 'GOOD'.
    CLEAR: lv_vercd, lv_outcd, lv_errcd, gt_mkalu[], gt_mkali[].

*&  처리 후 처리여부 체크위해
    lt_data = gt_data.
    APPEND lt_data.

    gt_exec[] = gt_save[].
    DELETE gt_exec  WHERE matnr <> gt_data-matnr.

    READ TABLE gt_exec  WITH KEY flag = 'ERROR'.

*&  시뮬레이션 결과 적합한 라우팅을 찾지 못했으면
    IF sy-subrc = 0.
      MESSAGE s000 WITH '자재[' gt_data-matnr '] 오류포함; 처리'
                                              '불가능 합니다.'.
      RETURN.
    ENDIF.

    IF gv_crlyn = 'X'.
      PERFORM read_characteristics_for_crl  USING lv_aznor.
    ENDIF.

    LOOP AT gt_exec WHERE plnfl  = 0
                      AND vornr  = 10.
      IF gt_exec-arbpl(3) = 'DUM'.
        lv_outcd = lv_outcd + 1.
        gt_exec-vercd = lv_outcd.
      ELSEIF gt_exec-beskz = 'E'  OR
             gt_exec-beskz = 'X'.
        lv_vercd = lv_vercd + 1.
        gt_exec-vercd = lv_vercd.
      ELSE.
        lv_errcd = lv_errcd + 1.
        gt_exec-vercd = lv_errcd.
      ENDIF.

      IF gv_crlyn = 'X'.
        gt_exec-aznor = lv_aznor.
      ENDIF.

      MODIFY gt_exec  INDEX sy-tabix.
    ENDLOOP.

*&  마지막 소공정의 경우 공정검사를 하기위해 체크
    PERFORM decide_last_work_center.

    PERFORM bdc_routing_add_ca02.
    PERFORM compute_add_routing.

    APPEND LINES OF gt_exec TO gt_temp.
  ENDLOOP.

  LOOP AT gt_temp  INTO gw_data.
    READ TABLE gt_data  WITH KEY matnr = gw_data-matnr
                                 plnal = gw_data-plnal
                                 plnfl = gw_data-plnfl
                                 vornr = gw_data-vornr.
    IF sy-subrc = 0.
      lv_tabix = sy-tabix.

      gt_data-plnnr = gw_data-plnnr.
      gt_data-plnal = gw_data-plnal.
      gt_data-verid = gw_data-verid.
      gt_data-message = gw_data-message.

      gt_data-arbpl_icon = gw_data-arbpl_icon.
      gt_data-verid_icon = gw_data-verid_icon.
      gt_data-arbpl_ind  = gw_data-arbpl_ind.
      gt_data-arbpl_stat = gw_data-arbpl_stat.
      gt_data-verid_ind  = gw_data-verid_ind.
      gt_data-verid_stat = gw_data-verid_stat.

      IF gt_data-message IS INITIAL.
        gt_data-chk  = space.
        gt_data-flag = 'SUCC'.

        IF NOT gt_data-plnnr IS INITIAL.
          gt_data-indi = '등록'.
        ENDIF.
      ENDIF.

      MODIFY gt_data  INDEX lv_tabix.

*// Routing 생성,변경 이력
      PERFORM insert_process_log USING gt_data.
    ENDIF.
  ENDLOOP.

  LOOP AT lt_data.
    gt_data-message = '직무그룹이 생성되지 않았습니다.'.

    MODIFY gt_data  TRANSPORTING message
                    WHERE matnr = lt_data-matnr
                      AND plnnr = space.
  ENDLOOP.

ENDFORM.                    " PREPARE_ROUTING_ADD
*&---------------------------------------------------------------------*
*&      Form  BDC_ROUTING_ADD_CA02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bdc_routing_add_ca02 .
  DATA: lv_idx     TYPE numc2,
        lv_arbpl   TYPE char30,
        lv_steus   TYPE char30,
        lv_ltxa1   TYPE char30,
        lv_basmn   TYPE char17,
        lv_qmmgn   TYPE char17,
        lv_tuhnk   TYPE char17,
        lv_aznor   TYPE char3,
        lv_rdrnp   TYPE char17,
        lv_flg_sel TYPE char30,
        lv_pre_sel TYPE char30,
        lv_mtart   LIKE mara-mtart,
        lv_procd   LIKE gp_procd.

  DATA: BEGIN OF lw_time,
          vgw01 TYPE char11,       " 가동준비시간
          vgw02 TYPE char11,       " 기계시간(가동)
          vgw03 TYPE char11,       " 제조지원
          vgw04 TYPE char11,       " 제조직접
          vgw05 TYPE char11,       " 배부간접
          vgw06 TYPE char11,       " 노무시간
        END   OF lw_time.

  REFRESH: gt_bdcdata, gt_messtab.
  CLEAR:   gt_bdcdata, gt_messtab, gw_temp, lv_idx.

  PERFORM bdc_dynpro      USING 'SAPLCPDI' '1010'.
  PERFORM bdc_field       USING: 'RC27M-MATNR'
                                 gt_data-matnr,
                                 'RC27M-WERKS'
                                 gp_werks,
                                 'RC271-PLNNR'
                                 gt_data-plnnr,
                                 'RC271-STTAG'
                                 sy-datum,
                                 'BDC_OKCODE'
                                 '/00'.        " 공정

  LOOP AT gt_exec  INTO gw_data WHERE indi = '추가'.

    READ TABLE gt_data WITH KEY chk = 'X'
                                matnr = gt_exec-matnr.

    IF sy-subrc NE 0.
      EXIT.
    ENDIF.

    CLEAR: lw_time.

    WRITE: gw_data-basmn  TO lv_basmn NO-GROUPING,
           gw_data-qmmgn  TO lv_qmmgn NO-GROUPING,
           gw_data-tuhnk  TO lv_tuhnk NO-GROUPING,
           gw_data-aznor  TO lv_aznor NO-GROUPING,
           gw_data-rdrnp  TO lv_rdrnp NO-GROUPING.

    WRITE: gw_data-ruezt  TO lw_time-vgw01 NO-GROUPING,
           gw_data-optim  TO lw_time-vgw02 NO-GROUPING,
           gw_data-optim  TO lw_time-vgw03 NO-GROUPING,
           gw_data-optim  TO lw_time-vgw04 NO-GROUPING,
           gw_data-optim  TO lw_time-vgw05 NO-GROUPING,
           gw_data-wktim  TO lw_time-vgw06 NO-GROUPING.

    IF gw_data-vornr = '0010'.
      lv_idx = 1.

      CONCATENATE: 'RC27X-FLG_SEL(' lv_idx ')'  INTO lv_pre_sel,
                   'RC27X-FLG_SEL(' lv_idx ')'  INTO lv_flg_sel.

      IF gw_data-plnfl > 0.
        PERFORM bdc_dynpro     USING 'SAPLCPDI' '1400'.
        PERFORM bdc_field      USING: lv_flg_sel
                                      'X',
                                      'RC27X-ENTRY_ACT'
                                      '1',
                                      'BDC_OKCODE'
                                      '=SEUE'.          " 순서

        PERFORM bdc_dynpro     USING 'SAPLCPDI' '1300'.
        PERFORM bdc_field      USING: 'BDC_OKCODE'
                                      '=ANLG'.         " 신규생성

        PERFORM bdc_dynpro     USING 'SAPLCP03' '1060'.
        PERFORM bdc_field      USING: 'RC275-SEQ_ALT'
                                      'X',             " 대체선택
                                      'BDC_OKCODE'
                                      '=WEIT'.

        PERFORM bdc_dynpro     USING  'SAPLCPDS' '1200'.
*       PERFORM bdc_field      USING  'PLFLD-PLNFL'    gw_data-plnfl.
        PERFORM bdc_field      USING: 'PLFLD-VORNR1'   gw_data-vornr,
                                      'PLFLD-VORNR2'   gw_data-vornr1,
                                      'PLFLD-LOSBS'   '99999999',
                                      'BDC_OKCODE'   '=VOUE'.           " 작업
      ELSE.

        CLEAR : lv_mtart, lv_procd.

        SELECT SINGLE mtart
          INTO lv_mtart
          FROM mara
         WHERE matnr = gw_data-matnr.

        IF lv_mtart = 'MCFE' AND
           gp_procd = 'SHE'.
          lv_procd =  'SHA'.
        ELSE.
          lv_procd = gp_procd.
        ENDIF.

        PERFORM bdc_dynpro  USING 'SAPLCPDA' '1200'.
        PERFORM bdc_field   USING: 'PLKOD-KTEXT'
                                   gw_data-maktx,
                                   'PLKOD-VERWE'
                                   '1',          " 용도
                                   'PLKOD-STATU'
                                   '4',          " 상태
                                   'PLKOD-LOSBS'
                                   '99999999',   " 최대로트수
                                   'PLKOD-PLNME'
                                   gw_data-meins,
                                   'PLKOD-PLNNR_ALT'
                                   lv_procd,     " 직무리스트(공정)
                                   'PLKOD-SLWBEZ'
                                   '100',        " 검사포인트
                                   'PLKOD-PPKZTLZU'
                                   '0',          " 부분로트 지정
                                   'BDC_OKCODE'
                                   '=SEUE'.      " 순서

        PERFORM bdc_dynpro    USING 'SAPLCPDI' '1300'.
        PERFORM bdc_field     USING: 'BDC_OKCODE'
                                     '=VOUE'.    " 작업
      ENDIF.
    ELSE.
      CONCATENATE: 'RC27X-FLG_SEL(' lv_idx ')'  INTO lv_pre_sel.

      lv_idx = lv_idx + 1.

      CONCATENATE: 'RC27X-FLG_SEL(' lv_idx ')'  INTO lv_flg_sel.
    ENDIF.

    CONCATENATE: 'PLPOD-ARBPL(' lv_idx ')'  INTO lv_arbpl,
                 'PLPOD-STEUS(' lv_idx ')'  INTO lv_steus,
                 'PLPOD-LTXA1(' lv_idx ')'  INTO lv_ltxa1.

    PERFORM bdc_dynpro       USING 'SAPLCPDI' '1400'.
    PERFORM bdc_field        USING: lv_arbpl
                                    gw_data-arbpl,
                                    lv_steus
                                    space,
                                    lv_pre_sel
                                    space,
                                    lv_flg_sel
                                    'X'.

    IF gv_crlyn = 'X'  AND
       gw_data-aznor = 2.
    ELSE.
      PERFORM bdc_field     USING: lv_ltxa1
                                   gw_data-ktext.
    ENDIF.

    IF gw_data-vornr = gw_data-vornr1.           " 마지막 소공정이면서

      IF gp_werks = '1302' AND
         ( gw_data-arbpl+0(3) = 'DRY' OR
           gw_data-arbpl+0(3) = 'HRT' OR
           gw_data-arbpl+0(3) = 'DDD' ).  "1302,DRY,HRT,Dumy 일때는 ZP06

        PERFORM bdc_field     USING: lv_steus
                                     'ZP06'.
      ELSE.

        PERFORM bdc_field     USING: lv_steus
                                     'PP04'.
      ENDIF.

    ENDIF.

    PERFORM bdc_field        USING: 'BDC_OKCODE'
                                    '=VOD1'.        " 세부(작업)

    PERFORM bdc_dynpro       USING 'SAPLCPDO' '1200'.

    IF gv_crlyn = 'X'  AND
       gw_data-aznor = 2.
      PERFORM bdc_field     USING: 'PLPOD-KTSCH'
                                   'CRL0001'.
    ENDIF.

    PERFORM bdc_field        USING: 'PLPOD-BMSCH'
                                    lv_basmn,
                                    'PLPOD-MEINH'
                                    gw_data-meins,
                                    'PLPOD-VGW01'
                                    lw_time-vgw01,
                                    'PLPOD-VGE01'
                                    gw_data-meinh,
                                    'PLPOD-VGW02'
                                    lw_time-vgw02,
                                    'PLPOD-VGE02'
                                    gw_data-meinh,
                                    'PLPOD-VGW03'
                                    lw_time-vgw03,
                                    'PLPOD-VGE03'
                                    gw_data-meinh,
                                    'PLPOD-VGW04'
                                    lw_time-vgw04,
                                    'PLPOD-VGE04'
                                    gw_data-meinh,
                                    'PLPOD-VGW05'
                                    lw_time-vgw05,
                                    'PLPOD-VGE05'
                                    gw_data-meinh,
                                    'PLPOD-VGW06'
                                    lw_time-vgw06,
                                    'PLPOD-VGE06'
                                    gw_data-meinh.

    IF gp_procd = 'CLK'  OR
       gp_procd = 'IRD'  OR
       gp_dispo = 'MGF'  OR
       gp_dispo = 'MGH'  OR
       gp_dispo = 'MAF'  OR
       gp_dispo = 'MAH'  OR
       ( gv_crlyn = 'X'  AND
         gw_data-aznor = 2 ).
      PERFORM bdc_field     USING: 'PLPOD-SPMUS'
                                   'X',              " 분할요청
                                   'PLPOD-SPLIM'
                                   lv_aznor.         " 분할수
    ENDIF.

    PERFORM bdc_field        USING: 'PLPOD-UENICHT'
                                    'X',
                                    'PLPOD-CKSELKZ'
                                    'X',              " 원가관련 지시자
                                    'PLPOD-QPPKTABS'
                                    '2',              " 검사지점(평가)
                                    'PLPOD-QKZPRINI'
                                    space,            " 참조유지보수
                                    'PLPOD-QKZPRFREI'
                                    'X',              " 관계없음
                                    'PLPOD-SLWID'     " 사용자 고유필드
                                    'PP00001',
                                    'BDC_OKCODE'
                                    '/00'.

    PERFORM bdc_dynpro       USING  'SAPLCPDO' '  1200'.
    PERFORM bdc_field        USING: 'PLPOD-USR04' lv_rdrnp,
                                     'BDC_OKCODE' '/00'.

    IF gt_data-dpcbt <> space AND gw_data-vornr = gw_data-vornr1.            " 마지막 소공정이면
*// Modified by ZGODEV06 on 2026-01-16 {
*       gw_data-vornr  = gw_data-vornr1.            " 마지막 소공정이면
*      PERFORM bdc_field     USING: 'PLPOD-/SAPMP/MET_LRCH'
*                                   space,
*                                   'PLPOD-/SAPMP/FIX_AS_J'
*                                   lv_qmmgn.

      PERFORM bdc_field       USING 'PLPOD-/SAPMP/FIX_AS_J' lv_qmmgn. "// 검사여장.

      IF gw_data-tuhnk IS NOT INITIAL.
        PERFORM bdc_dynpro    USING  'SAPLCPDO'              '1200'.
        PERFORM bdc_field     USING: 'BDC_OKCODE'            '/00',
                                      'PLPOD-/SAPMP/MET_LRCH' '2'.
        PERFORM bdc_dynpro    USING  'SAPLCPDO'              '1200'.
        PERFORM bdc_field     USING  'PLPOD-/SAPMP/MAX_FERTL' lv_tuhnk. "// TU 만권량.
      ENDIF.
    ELSE.
      PERFORM bdc_dynpro    USING  'SAPLCPDO'              '1200'.
*// }
    ENDIF.

*// Modified by ZGODEV06 on 2026-01-09 {
*    IF gw_data-vornr = gw_data-vornr1.            " 마지막 소공정이면
*      PERFORM bdc_field        USING: 'BDC_OKCODE'  " 공정검사
*                                      '=QMUE'.
*
*      PERFORM bdc_dynpro       USING 'SAPLQPAA' '0150'.
*      PERFORM bdc_field        USING: 'PLMKB-VERWMERKM(01)'
*                                      gw_qpmz-mkmnr,
*                                      'BDC_OKCODE'
*                                     '/00'.
*
*      PERFORM bdc_dynpro       USING 'SAPLQPAA' '1501'.
*      PERFORM bdc_field        USING: 'PLMKB-VERWMERKM'
*                                      gw_qpmz-mkmnr,
*                                     'PLMKB-QPMK_WERKS'
*                                      gw_qpmz-zaehler,
*                                      'PLMKB-MKVERSION'
*                                      gw_qpmz-version,
*                                      'PLMKB-PMETHODE'
*                                      gw_qpmz-pmethode,
*                                      'PLMKB-QMTB_WERKS'
*                                      gw_qpmz-werkpm,
*                                      'PLMKB-PMTVERSION'
*                                      gw_qpmz-verspm,
*                                      'BDC_OKCODE'
*                                      '=ENT1'.
*
*      PERFORM bdc_dynpro       USING 'SAPLQPAA' '1502'.
*      PERFORM bdc_field        USING: 'PLMKB-PMETHODE'
*                                      gw_qpmz-pmethode,
*                                      'PLMKB-QMTB_WERKS'
*                                      gw_qpmz-werkpm,
*                                      'PLMKB-PMTVERSION'
*                                      gw_qpmz-verspm,
*                                      'BDC_OKCODE'
*                                      '=ENT1'.
*
*      PERFORM bdc_dynpro       USING 'SAPLQPAA' '0150'.
*      PERFORM bdc_field        USING: 'BDC_OKCODE'
*                                      '=SVUE'.
*    ELSE.
*// }

    PERFORM bdc_field        USING: 'BDC_OKCODE'    '=BACK'.

*// Modified by ZGODEV06 on 2026-01-09 {
*    ENDIF.
*// }
  ENDLOOP.

ENDFORM.                    " BDC_ROUTING_ADD_CA02
*&---------------------------------------------------------------------*
*&      Form  COMPUTE_ADD_ROUTING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM compute_add_routing .
  DATA: lv_tabix   TYPE sy-tabix,
        lv_verid   TYPE mkal-verid,
        lv_message TYPE char100.

  PERFORM bdc_dynpro      USING 'SAPLCPDI'   '1400'.
  PERFORM bdc_field       USING 'BDC_OKCODE' '=BU'.

  PERFORM bdc_transaction USING 'CA02'.

*& 처리결과를 읽는다.
  PERFORM edit_error_message  USING lv_message.

*& BDC처리시 에러발생 여부 체크
  IF NOT lv_message IS INITIAL.
    gt_data-message = lv_message.
  ELSE.
    COMMIT WORK  AND WAIT.

    READ TABLE gt_messtab  WITH KEY msgtyp = 'S'.
    gt_data-plnnr = gt_messtab-msgv1.
  ENDIF.

  MODIFY gt_exec FROM VALUE #( arbpl_icon = COND #( WHEN lv_message IS INITIAL THEN icon_led_green
                                                    ELSE icon_led_red )
                               arbpl_ind  = gc_proc_type-add_seq
                               arbpl_stat = COND #( WHEN lv_message IS INITIAL THEN gc_result-success
                                                    ELSE gc_result-error ) )
                 TRANSPORTING arbpl_icon arbpl_ind arbpl_stat
                 WHERE matnr EQ gt_data-matnr.

ENDFORM.                    " COMPUTE_ADD_ROUTING
*&---------------------------------------------------------------------*
*&      Form  CREATE_MKAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_mkal CHANGING pv_verid.
  DATA: lt_plko    TYPE plko OCCURS 0 WITH HEADER LINE,
        lv_zaehl   TYPE mkal_aend-zaehl,
        lv_minid   TYPE mkal-verid,
        lv_stlal   TYPE mast-stlal,
        lv_stlalc  TYPE mast-stlal,
        lv_value   TYPE numc4,
        lv_plnid   TYPE numc4,
        lv_verid   TYPE mkal-verid,
        lv_xfeld   TYPE c,
        lv_message TYPE char100.

  DATA: lw_head  LIKE bapimathead,
        lt_plnt  LIKE bapi_marc  OCCURS 0 WITH HEADER LINE,
        lt_plntx LIKE bapi_marcx OCCURS 0 WITH HEADER LINE.

  CLEAR: lv_verid,   lv_value,  lv_minid,   lv_zaehl,  lv_stlal,
         lv_stlal,   lt_plko[], gt_mkalu[], gt_mkali[],
         gt_mkala[], gt_mkald[].

*& 최종 대체 bom 조회
  SELECT MAX( stlal )
    INTO lv_stlal
    FROM mast
  WHERE matnr = gt_exec-matnr
    AND werks = gp_werks
    AND stlan = '1'.

  SELECT MAX( stlal )
    INTO lv_stlalc
    FROM mast
  WHERE  matnr = gt_exec-matnr
    AND  werks = gp_werks
    AND stlan = '6'.

*& 계획용 버젼
  lv_plnid = '2999' + gt_exec-vercd.

  IF gt_exec-arbpl(3) = 'DUM'.
    lv_minid = '1999'.               " 외주공정
    lv_plnid = 0.
  ELSEIF gt_exec-beskz = 'E'  OR     " 조달유형
         gt_exec-beskz = 'X'.
    lv_minid = '0999'.
  ELSE.
    lv_minid = '099'.
    lv_plnid = 0.
  ENDIF.

*& 생산용 버젼
  IF gt_exec-verid IS INITIAL.
    lv_verid = lv_minid + gt_exec-vercd.
  ELSE.
    lv_verid = gt_exec-verid.
  ENDIF.

  pv_verid = lv_verid.

  SELECT *
      INTO TABLE lt_plko
      FROM plko
     WHERE plnty  = 'N'                " 공정
       AND plnnr  = gt_exec-plnnr
       AND plnal  = gt_exec-plnal.

  SELECT COUNT( * )
      INTO lv_zaehl
      FROM mkal_aend
     WHERE matnr = gt_exec-matnr
       AND werks = gp_werks
       AND verid = lv_verid.

  lv_value = lv_verid.
  lv_zaehl = lv_zaehl + 1.

  LOOP AT lt_plko.
    gt_mkali-matnr = gt_exec-matnr.
    gt_mkali-werks = gp_werks.
    gt_mkali-verid = lv_value.
    gt_mkali-bdatu = '99991231'.
    gt_mkali-adatu = sy-datum.
    gt_mkali-stlal = lv_stlal.
    gt_mkali-stlan = '1'.
    gt_mkali-plnty = 'N'.
    gt_mkali-plnnr = gt_exec-plnnr.
    gt_mkali-alnal = gt_exec-plnal.
    gt_mkali-bstmi = 1.
    gt_mkali-bstma = 9999999.
    gt_mkali-text1 = gv_name1.
    gt_mkali-prdat = sy-datum.
    gt_mkali-prfg_f = '1'.
    gt_mkali-prfg_s = '1'.

    APPEND gt_mkali.

    gt_mkala-matnr = gt_exec-matnr.
    gt_mkala-werks = gp_werks.
    gt_mkala-verid = lv_value.
    gt_mkala-zaehl = lv_zaehl.
    gt_mkala-datuv = sy-datum.
    gt_mkala-datub = '99991231'.
    gt_mkala-andat = sy-datum.
    gt_mkala-annam = sy-uname.
    gt_mkala-vbkz  = 'I'.

    APPEND gt_mkala.

    IF lv_plnid > '2999'.                 " 외주는 계획용 생성 무
      gt_mkali-matnr = gt_exec-matnr.
      gt_mkali-werks = gp_werks.
      gt_mkali-verid = lv_plnid.
      gt_mkali-bdatu = '99991231'.
      gt_mkali-adatu = sy-datum.
      gt_mkali-stlal = lv_stlalc.
      gt_mkali-stlan = '6'.              " 계획용
      gt_mkali-plnty = 'N'.
      gt_mkali-plnnr = gt_exec-plnnr.
      gt_mkali-alnal = gt_exec-plnal.
      gt_mkali-bstmi = 1.
      gt_mkali-bstma = 9999999.
      gt_mkali-text1 = gv_name1.
      gt_mkali-prdat = sy-datum.
      gt_mkali-prfg_f = '1'.
      gt_mkali-prfg_s = '1'.

      APPEND gt_mkali.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " CREATE_MKAL
*&---------------------------------------------------------------------*
*&      Form  UPDATE_MKAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_PV_VERID  text
*----------------------------------------------------------------------*
FORM update_mkal  CHANGING pv_verid.
  DATA: lt_plko     TYPE plko OCCURS 0 WITH HEADER LINE,
        lt_mkalt    TYPE mkal OCCURS 0 WITH HEADER LINE,
        lt_mkalt2   TYPE mkal OCCURS 0 WITH HEADER LINE,
        lv_date     TYPE sy-datum,
        lv_zaehl    TYPE mkal_aend-zaehl,
        lv_minid    TYPE mkal-verid,
        lv_stlal    TYPE mast-stlal,
        lv_stlalc   TYPE mast-stlal,
        lv_stlal_t  TYPE mast-stlal,
        lv_stlalc_t TYPE mast-stlal,
        lv_value    TYPE numc4,
        lv_plnid    TYPE numc4,
        lv_verid    TYPE mkal-verid,
        lv_xfeld    TYPE c,
        lv_message  TYPE char100.

  DATA: lw_head  LIKE bapimathead,
        lt_plnt  LIKE bapi_marc  OCCURS 0 WITH HEADER LINE,
        lt_plntx LIKE bapi_marcx OCCURS 0 WITH HEADER LINE.

  CLEAR: lv_verid,   lv_value,  lv_minid,   lv_zaehl,  lv_stlal,
         lv_stlal,   lt_plko[], gt_mkalu[], gt_mkali[],
         gt_mkala[], gt_mkald[], lt_mkalt[], lt_mkalt, lv_date.

*& 최종 대체 bom 조회
  SELECT MAX( stlal )
    INTO lv_stlal
    FROM mast
  WHERE matnr = gt_exec-matnr
    AND werks = gp_werks
    AND stlan = '1'.

  SELECT MAX( stlal )
    INTO lv_stlalc
    FROM mast
  WHERE  matnr = gt_exec-matnr
    AND  werks = gp_werks
    AND stlan = '6'.

* 생산버젼이 있는데 안잠긴 생산버젼의 대체 bom과 최종대체 bom이 동일하면
*라우팅 번호만 업데이트하고 효력시작일은 bom 효력시작일과 라우팅
*효력시작일중
* 가까운 일자로
* 2012/05/17 기존 생산버젼 조회시 라우팅 그룹카운터 조건 추가
  SELECT *
    INTO TABLE lt_mkalt
    FROM mkal
   WHERE matnr  = gt_exec-matnr
     AND werks  = gp_werks
     AND alnal  = gt_exec-plnal.

  lt_mkalt2[] = lt_mkalt[].

* 현재 사용중인 생산버젼에서
  LOOP AT lt_mkalt WHERE matnr = gt_exec-matnr
                     AND werks = gp_werks
                     AND mksp  = space
                     AND stlan = '1'.    "생산

    MOVE-CORRESPONDING lt_mkalt TO gt_mkalu.
*& bom효력시작일과 라우팅 효력시작일중 가까운날짜확인
    PERFORM get_bom_routing_datuv USING gt_exec-matnr
                                        lt_mkalt-stlan
                                        lv_stlal
                               CHANGING lv_date.

    gt_mkalu-adatu = lv_date.
    gt_mkalu-plnnr = gt_exec-plnnr.
    gt_mkalu-alnal = gt_exec-plnal.
    gt_mkalu-prdat = sy-datum.

*& 대체bom이 같으면 잠근 생산버젼 삭제 처리
    IF lv_stlal EQ lt_mkalt-stlal.

      READ TABLE lt_mkalt2 WITH KEY verid+0(1) = lt_mkalt-verid+0(1)
                                    mksp = '1'.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING lt_mkalt2 TO gt_mkald.
        APPEND gt_mkald.
      ENDIF.

      APPEND gt_mkalu.

    ELSE. "다르면 잠금 생산버젼에 최종 대체 bom 적용하고 잠금 풀기

      gt_mkalu-mksp  = '1'.
      APPEND gt_mkalu.

      READ TABLE lt_mkalt2 WITH KEY verid+0(1) = lt_mkalt-verid+0(1)
                                    mksp = '1'.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING lt_mkalt2 TO gt_mkalu.
        gt_mkalu-adatu = lv_date.
        gt_mkalu-plnnr = gt_exec-plnnr.
        gt_mkalu-alnal = gt_exec-plnal.
        gt_mkalu-prdat = sy-datum.
        gt_mkalu-mksp  = ' '.
        gt_mkalu-stlal = lv_stlal.
        APPEND gt_mkalu.
      ELSE.
        MOVE-CORRESPONDING lt_mkalt TO gt_mkali.
        gt_mkali-adatu = lv_date.
        gt_mkali-plnnr = gt_exec-plnnr.
        gt_mkali-alnal = gt_exec-plnal.
        gt_mkali-prdat = sy-datum.
        gt_mkali-mksp  = ' '.
        gt_mkali-stlal = lv_stlal.

        IF gt_mkali-verid+3(1) = '1'.
          CONCATENATE gt_mkali-verid+0(3) '0' INTO
                      gt_mkali-verid.
        ELSE.
          CONCATENATE gt_mkali-verid+0(3) '1' INTO
                      gt_mkali-verid.
        ENDIF.

        APPEND gt_mkali.

        SELECT COUNT( * )
          INTO lv_zaehl
          FROM mkal_aend
         WHERE matnr = gt_exec-matnr
           AND werks = gp_werks
           AND verid = gt_mkali-verid.

        lv_zaehl = lv_zaehl + 1.

        gt_mkala-matnr = gt_exec-matnr.
        gt_mkala-werks = gp_werks.
        gt_mkala-verid = gt_mkali-verid.
        gt_mkala-zaehl = lv_zaehl.
        gt_mkala-datuv = lv_date.
        gt_mkala-datub = '99991231'.
        gt_mkala-andat = sy-datum.
        gt_mkala-annam = sy-uname.
        gt_mkala-vbkz  = 'I'.

        APPEND gt_mkala.
      ENDIF.
    ENDIF.
  ENDLOOP.

* 현재 사용중인 생산버젼에서
  LOOP AT lt_mkalt WHERE matnr = gt_exec-matnr
                     AND werks = gp_werks
                     AND mksp  = space
                     AND stlan = '6'.    "원가

    MOVE-CORRESPONDING lt_mkalt TO gt_mkalu.
*& bom효력시작일과 라우팅 효력시작일중 가까운날짜확인
    PERFORM get_bom_routing_datuv USING gt_exec-matnr
                                        lt_mkalt-stlan
                                        lv_stlal
                               CHANGING lv_date.

    gt_mkalu-adatu = lv_date.
    gt_mkalu-plnnr = gt_exec-plnnr.
    gt_mkalu-alnal = gt_exec-plnal.
    gt_mkalu-prdat = sy-datum.

*& 대체bom이 같으면 잠근 생산버젼 삭제 처리
    IF lv_stlal EQ lt_mkalt-stlal.

      READ TABLE lt_mkalt2 WITH KEY verid+0(1) = lt_mkalt-verid+0(1)
                                    mksp = '1'.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING lt_mkalt2 TO gt_mkald.
        APPEND gt_mkald.
      ENDIF.

      APPEND gt_mkalu.

    ELSE. "다르면 잠금 생산버젼에 최종 대체 bom 적용하고 잠금 풀기

      gt_mkalu-mksp  = '1'.
      APPEND gt_mkalu.

      READ TABLE lt_mkalt2 WITH KEY verid+0(1) = lt_mkalt-verid+0(1)
                                    mksp = '1'.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING lt_mkalt2 TO gt_mkalu.
        gt_mkalu-adatu = lv_date.
        gt_mkalu-plnnr = gt_exec-plnnr.
        gt_mkalu-alnal = gt_exec-plnal.
        gt_mkalu-prdat = sy-datum.
        gt_mkalu-mksp  = ' '.
        gt_mkalu-stlal = lv_stlal.
        APPEND gt_mkalu.
      ELSE.
        MOVE-CORRESPONDING lt_mkalt TO gt_mkali.
        gt_mkali-adatu = lv_date.
        gt_mkali-plnnr = gt_exec-plnnr.
        gt_mkali-alnal = gt_exec-plnal.
        gt_mkali-prdat = sy-datum.
        gt_mkali-mksp  = ' '.
        gt_mkali-stlal = lv_stlal.

        IF gt_mkali-verid+3(1) = '1'.
          CONCATENATE gt_mkali-verid+0(3) '0' INTO
                      gt_mkali-verid.
        ELSE.
          CONCATENATE gt_mkali-verid+0(3) '1' INTO
                      gt_mkali-verid.
        ENDIF.

        APPEND gt_mkali.

      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " UPDATE_MKAL
*&---------------------------------------------------------------------*
*&      Form  GET_BOM_ROUTING_DATUV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EXEC_MATNR  text
*      -->P_LV_STLAL  text
*      <--P_LV_DATE  text
*----------------------------------------------------------------------*
FORM get_bom_routing_datuv  USING    p_matnr
                                     p_stlal
                                     p_stlan
                            CHANGING p_date.

  DATA : lv_date   TYPE sy-datum.

  CLEAR : lv_date.

*& bom의 효력시작일과 라우팅 효력시작일을 비교하여 가까운 날짜로
*& 생산버젼 효력시작일로
  SELECT SINGLE datuv
    INTO lv_date
    FROM stko AS a INNER JOIN mast AS b
                      ON a~stlnr = b~stlnr
                     AND a~stlal = b~stlal
   WHERE b~werks = gp_werks
     AND b~matnr = p_matnr
     AND b~stlal = p_stlal
     AND b~stlan = p_stlan.

  IF gv_datuv > lv_date.  "라우팅이 bom보다 크면
    p_date = gv_datuv.
  ELSE.
    p_date = lv_date.
  ENDIF.

ENDFORM.                    " GET_BOM_ROUTING_DATUV
*&---------------------------------------------------------------------*
*&      Form  CREATE_MKAL2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_PV_VERID  text
*----------------------------------------------------------------------*
FORM create_mkal2 CHANGING pv_verid.
  DATA: lt_plko    TYPE plko OCCURS 0 WITH HEADER LINE,
        lv_zaehl   TYPE mkal_aend-zaehl,
        lv_minid   TYPE mkal-verid,
        lv_stlal   TYPE mast-stlal,
        lv_stlalc  TYPE mast-stlal,
        lv_value   TYPE numc4,
        lv_plnid   TYPE numc4,
        lv_verid   TYPE mkal-verid,
        lv_xfeld   TYPE c,
        lv_message TYPE char100.

  DATA: lw_head  LIKE bapimathead,
        lt_plnt  LIKE bapi_marc  OCCURS 0 WITH HEADER LINE,
        lt_plntx LIKE bapi_marcx OCCURS 0 WITH HEADER LINE.

  CLEAR: lv_verid,   lv_value,  lv_minid,   lv_zaehl,  lv_stlal,
         lv_stlal,   lt_plko[], gt_mkalu[], gt_mkali[],
         gt_mkala[], gt_mkald[].

*& 최종 대체 bom 조회
  SELECT MAX( stlal )
    INTO lv_stlal
    FROM mast
  WHERE matnr = gt_exec-matnr
    AND werks = gp_werks
    AND stlan = '1'.

  SELECT MAX( stlal )
    INTO lv_stlalc
    FROM mast
  WHERE  matnr = gt_exec-matnr
    AND  werks = gp_werks
    AND stlan = '6'.

*& 계획용 버젼
  lv_plnid = '2999' + gt_exec-vercd.

  IF gt_exec-arbpl(3) = 'DUM'.
    lv_minid = '1999'.               " 외주공정
    lv_plnid = 0.
  ELSEIF gt_exec-beskz = 'E'  OR     " 조달유형
         gt_exec-beskz = 'X'.
    lv_minid = '0999'.
  ELSE.
    lv_minid = '099'.
    lv_plnid = 0.
  ENDIF.

*& 생산용 버젼
  IF gt_exec-verid IS INITIAL.
    lv_verid = lv_minid + gt_exec-vercd.
  ELSE.
    lv_verid = gt_exec-verid.
  ENDIF.

  pv_verid = lv_verid.

  SELECT *
      INTO TABLE lt_plko
      FROM plko
     WHERE plnty  = 'N'                " 공정
       AND plnnr  = gt_exec-plnnr
       AND plnal  = gt_exec-plnal.

  SELECT COUNT( * )
      INTO lv_zaehl
      FROM mkal_aend
     WHERE matnr = gt_exec-matnr
       AND werks = gp_werks
       AND verid = lv_verid.

  lv_value = lv_verid.
  lv_zaehl = lv_zaehl + 1.

  LOOP AT lt_plko.
    gt_mkali-matnr = gt_exec-matnr.
    gt_mkali-werks = gp_werks.
    gt_mkali-verid = lv_value.
    gt_mkali-bdatu = '99991231'.
    gt_mkali-adatu = sy-datum.
    gt_mkali-stlal = lv_stlal.
    gt_mkali-stlan = '1'.
    gt_mkali-plnty = 'N'.
    gt_mkali-plnnr = gt_exec-plnnr.
    gt_mkali-alnal = gt_exec-plnal.
    gt_mkali-bstmi = 1.
    gt_mkali-bstma = 9999999.
    gt_mkali-text1 = gv_name1.
    gt_mkali-prdat = sy-datum.
    gt_mkali-prfg_f = '1'.
    gt_mkali-prfg_s = '1'.

    APPEND gt_mkali.

    gt_mkala-matnr = gt_exec-matnr.
    gt_mkala-werks = gp_werks.
    gt_mkala-verid = lv_value.
    gt_mkala-zaehl = lv_zaehl.
    gt_mkala-datuv = sy-datum.
    gt_mkala-datub = '99991231'.
    gt_mkala-andat = sy-datum.
    gt_mkala-annam = sy-uname.
    gt_mkala-vbkz  = 'I'.

    APPEND gt_mkala.

    IF lv_plnid > '2999'.                 " 외주는 계획용 생성 무
      gt_mkali-matnr = gt_exec-matnr.
      gt_mkali-werks = gp_werks.
      gt_mkali-verid = lv_plnid.
      gt_mkali-bdatu = '99991231'.
      gt_mkali-adatu = sy-datum.
      gt_mkali-stlal = lv_stlalc.
      gt_mkali-stlan = '6'.              " 계획용
      gt_mkali-plnty = 'N'.
      gt_mkali-plnnr = gt_exec-plnnr.
      gt_mkali-alnal = gt_exec-plnal.
      gt_mkali-bstmi = 1.
      gt_mkali-bstma = 9999999.
      gt_mkali-text1 = gv_name1.
      gt_mkali-prdat = sy-datum.
      gt_mkali-prfg_f = '1'.
      gt_mkali-prfg_s = '1'.

      APPEND gt_mkali.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "CREATE_MKAL2
*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_EXTERNAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM exclude_external .

  DELETE gt_mapl WHERE beskz = 'F'
                   AND sobsl = ' '.

  DELETE gt_mapl WHERE beskz = 'F'
                   AND sobsl <> '30'.

ENDFORM.                    " EXCLUDE_EXTERNAL

*&---------------------------------------------------------------------*
*& Form compare_date_to_wc
*&---------------------------------------------------------------------*
FORM compare_date_to_wc USING p_dat.

  DATA : BEGIN OF lt_arbpl OCCURS 0,
           arbpl TYPE crhd-arbpl,
           werks TYPE crhd-werks,
           begda TYPE crco-begda,
         END OF lt_arbpl.

  CHECK gt_exec[] IS NOT INITIAL.

  SELECT h~arbpl h~werks o~begda
    INTO CORRESPONDING FIELDS OF TABLE lt_arbpl
    FROM crhd AS h INNER JOIN crco AS o
                                          ON h~objty EQ o~objty
                                        AND h~objid EQ o~objid
    FOR ALL ENTRIES IN gt_exec
    WHERE h~arbpl EQ gt_exec-arbpl
        AND h~werks EQ gp_werks.

  DELETE ADJACENT DUPLICATES FROM lt_arbpl.

* 라우팅 내 각 순서 별 라우팅의 코스트센터의 유효 시작일이 1개월 이전 산정된 날 보다
* 이 후인 경우가 없을 때 1개월 이전으로 산정된 날을 라우팅 헤더의 유효 시작일로 한다

  SORT lt_arbpl BY begda DESCENDING.

  READ TABLE lt_arbpl INDEX 1.

  CHECK sy-subrc EQ 0.
  CHECK lt_arbpl-begda GT p_dat.

  CLEAR p_dat.
  p_dat = lt_arbpl-begda.

ENDFORM.

*&---------------------------------------------------------------------*
*&  Include           ZPPU0004BDC                                      *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  routing_create_by_bapi
*&---------------------------------------------------------------------*
FORM routing_create_by_bapi.
  CLEAR: gt_task[], gt_allo[], gt_sequ[], gt_oper[].

  PERFORM fillup_task_header.
  PERFORM fillup_mat_task_ist_assignment.
  PERFORM fillup_sequence.
  PERFORM fillup_operations.
  PERFORM call_bapi_routing_create.
ENDFORM.                    " routing_create_by_bapi

*&---------------------------------------------------------------------*
*&      Form  fillup_task_header
*&---------------------------------------------------------------------*
FORM fillup_task_header.
  gt_task-task_list_usage = '1'.                " 직무리스트용도
  gt_task-plant = gp_werks.                     " 플랜트
  gt_task-task_list_status  = '4'.              " 상태
  gt_task-task_measure_unit = gt_data-meins.    " 단위
  gt_task-lot_size_from = '1'.                  " 최소로트크기
  gt_task-lot_size_to = '99999999'.             " 최대로트크기
  gt_task-old_number_of_task_list = 'INS'.
  gt_task-description = gt_data-maktx.          " 내역
  gt_task-valid_from = sy-datum.                " 유효일자

  APPEND gt_task.
ENDFORM.                    " pro_set_task_header

*&---------------------------------------------------------------------*
*&      Form  fillup_mat_task_ist_assignment
*&---------------------------------------------------------------------*
FORM fillup_mat_task_ist_assignment.
  gt_allo-material = gt_data-matnr.
  gt_allo-plant = gp_werks.
  gt_allo-valid_from = sy-datum.
*  gt_allo-doc_number = g_vbeln.
*  gt_allo-itemnumber = g_posnr.

  APPEND gt_allo.
ENDFORM.                    " fillup_mat_task_ist_assignment

*&---------------------------------------------------------------------*
*&      Form  fillup_sequence
*&---------------------------------------------------------------------*
FORM fillup_sequence.
  LOOP AT gt_exec  WHERE plnfl > 0
                     AND vornr = 10.
    gt_sequ-sequence_no = gt_exec-plnfl.
    gt_sequ-branch_operation = '10'.
    gt_sequ-return_operation = '10'.
    gt_sequ-lot_sz_min = '1'.

    APPEND gt_sequ.
  ENDLOOP.
ENDFORM.                    " fillup_sequence

*&---------------------------------------------------------------------*
*&      Form  fillup_operations
*&---------------------------------------------------------------------*
FORM fillup_operations.
  LOOP AT gt_exec.
    gt_oper-valid_from = sy-datum.
    gt_oper-sequence_no = gt_exec-plnfl.
    gt_oper-activity = gt_exec-vornr.
    gt_oper-work_cntr = gt_exec-arbpl.
    gt_oper-plant = gp_werks.
    gt_oper-description = 'TEXT'. " gt_exec-ktext.

    gt_oper-operation_measure_unit = gt_exec-meins.
    gt_oper-denominator = '1'.
    gt_oper-nominator = '1'.
    gt_oper-base_quantity = gt_exec-basmn.

    gt_oper-std_unit_01 = gt_exec-meinh.
    gt_oper-std_value_01 = gt_exec-ruezt.

    gt_oper-std_unit_02 = gt_exec-meinh.
    gt_oper-std_value_02 = gt_exec-optim.

    gt_oper-std_unit_03 = gt_exec-meinh.
    gt_oper-std_value_03 = gt_exec-optim.

    gt_oper-std_unit_04 = gt_exec-meinh.
    gt_oper-std_value_04 = gt_exec-optim.

    gt_oper-std_unit_05 = gt_exec-meinh.
    gt_oper-std_value_05 = gt_exec-optim.

    gt_oper-std_unit_06 = gt_exec-meinh.
    gt_oper-std_value_06 = gt_exec-wktim.

    APPEND gt_oper.
  ENDLOOP.
ENDFORM.                    " fillup_operations

*&---------------------------------------------------------------------*
*&      Form  call_bapi_routing_create
*&---------------------------------------------------------------------*
FORM call_bapi_routing_create.
  DATA: lv_xfeld          TYPE c.

  CLEAR: gt_ret2[], lv_xfeld.

  CALL FUNCTION 'BAPI_ROUTING_CREATE'
    EXPORTING
      application            = 'PP01'
    IMPORTING
      group                  = gv_group
      groupcounter           = gv_count
    TABLES
      task                   = gt_task
      materialtaskallocation = gt_allo
      sequence               = gt_sequ
      operation              = gt_oper
      return                 = gt_ret2.

  PERFORM read_table_gt_ret2  USING lv_xfeld
                                    gt_data-message.

  LOOP AT gt_exec.
    gt_exec-message = gt_data-message.
    gt_exec-plnnr = gv_group.
    gt_exec-plnal = gv_count.

    MODIFY gt_exec.
  ENDLOOP.
ENDFORM.                    " pro_call_bapi_routing_create

*&---------------------------------------------------------------------*
*&      Form  bdc_routing_create_by_ca01
*&---------------------------------------------------------------------*
FORM bdc_routing_create_by_ca01.
  DATA: lv_idx     TYPE numc2,
        lv_arbpl   TYPE char30,
        lv_steus   TYPE char30,
        lv_ltxa1   TYPE char30,
        lv_basmn   TYPE char17,
        lv_qmmgn   TYPE char17,
        lv_tuhnk   TYPE char17,
        lv_aznor   TYPE char3,
        lv_rdrnp   TYPE char17,
        lv_flg_sel TYPE char30,
        lv_pre_sel TYPE char30,
        lv_mtart   LIKE mara-mtart,
        lv_procd   LIKE gp_procd,
        lv_date    LIKE sy-datum,
        lv_usr05   TYPE char18,
        lv_usr06   TYPE char18,
        lv_usr07   TYPE char18.   "2026.06.16 KSW

  DATA: BEGIN OF lw_time,
          vgw01 TYPE char11,       " 가동준비시간
          vgw02 TYPE char11,       " 기계시간(가동)
          vgw03 TYPE char11,       " 제조지원
          vgw04 TYPE char11,       " 제조직접
          vgw05 TYPE char11,       " 배부간접
          vgw06 TYPE char11,       " 노무시간
        END   OF lw_time.

  REFRESH: gt_bdcdata, gt_messtab.
  CLEAR:   gt_bdcdata, gt_messtab, gw_temp, lv_idx, lv_date.

*& 2012/04/02 기기선의 경우 생산버젼 관리를 위해서 3개월전일로
  IF gp_dispo+0(2) EQ 'EC'.
    CALL FUNCTION 'HR_PT_ADD_MONTH_TO_DATE'
      EXPORTING
        dmm_datin = sy-datum
*[CHM2402-00035]-산업기기 라우팅 유효 시작일 지정 변경
*       DMM_COUNT = '3'
        dmm_count = '1'
*[CHM2402-00035]-2024.02.02 By 오바다
        dmm_oper  = '-'
        dmm_pos   = ' '
      IMPORTING
        dmm_daout = gv_datuv
      EXCEPTIONS
        unknown   = 1
        OTHERS    = 2.

*[CHM2402-00035]-산업기기 라우팅 유효 시작일 지정 변경
*    lv_date = gv_datuv.
    PERFORM compare_date_to_wc USING gv_datuv.
    lv_date = gv_datuv.
*[CHM2402-00035]-2024.02.02 By 오바다
  ELSE.
    lv_date = sy-datum.
  ENDIF.

  PERFORM bdc_dynpro      USING 'SAPLCPDI' '1010'.
  PERFORM bdc_field       USING: 'RC27M-MATNR'
                                 gt_data-matnr,
                                 'RC27M-WERKS'
                                 gp_werks,
                                 'RC271-PLNNR'
                                 space,
                                 'RC271-STTAG'
                                 lv_date,
                                 'BDC_OKCODE'
                                 '=ALUE'.        " 공정

  LOOP AT gt_exec  INTO gw_data.
    CLEAR: lw_time.

    WRITE: gw_data-basmn  TO lv_basmn NO-GROUPING,
           gw_data-qmmgn  TO lv_qmmgn NO-GROUPING,
           gw_data-tuhnk  TO lv_tuhnk NO-GROUPING,
           gw_data-aznor  TO lv_aznor NO-GROUPING,
           gw_data-rdrnp  TO lv_rdrnp NO-GROUPING.

    WRITE: gw_data-ruezt  TO lw_time-vgw01 NO-GROUPING,
           gw_data-optim  TO lw_time-vgw02 NO-GROUPING,
           gw_data-optim  TO lw_time-vgw03 NO-GROUPING,
           gw_data-optim  TO lw_time-vgw04 NO-GROUPING,
           gw_data-optim  TO lw_time-vgw05 NO-GROUPING,
           gw_data-wktim  TO lw_time-vgw06 NO-GROUPING.

    IF gw_data-plnfl = 0  AND
       gw_data-vornr = 10.
      IF gw_data-plnal > 1.
        PERFORM bdc_dynpro   USING 'SAPLCPDI' '1400'.
        PERFORM bdc_field    USING: 'BDC_OKCODE'
                                    '=BACK'.

        PERFORM bdc_dynpro   USING 'SAPLCPDA' '1200'.
        PERFORM bdc_field    USING: 'BDC_OKCODE'
                                     '=ALUE'.        " 공정
      ENDIF.

      IF gt_data-indi = '신규'.
        PERFORM bdc_dynpro      USING 'SAPLCPDI' '1200'.
        PERFORM bdc_field       USING: 'BDC_OKCODE'
                                       '=ANLG'.       " 신규생성
      ELSE.
        PERFORM bdc_dynpro      USING 'SAPLCPDI' '1200'.
        PERFORM bdc_field       USING: 'BDC_OKCODE'
                                       '=SEUE'.      " 순서
      ENDIF.
    ENDIF.

    IF gw_data-vornr = '0010'.
      lv_idx = 1.

      CONCATENATE: 'RC27X-FLG_SEL(' lv_idx ')'  INTO lv_pre_sel,
                   'RC27X-FLG_SEL(' lv_idx ')'  INTO lv_flg_sel.

      IF gw_data-plnfl > 0.
        PERFORM bdc_dynpro     USING 'SAPLCPDI' '1400'.
        PERFORM bdc_field      USING: 'BDC_OKCODE'
                                      '=SEUE'.          " 순서

        PERFORM bdc_dynpro     USING 'SAPLCPDI' '1300'.
        PERFORM bdc_field      USING: 'BDC_OKCODE'
                                      '=ANLG'.         " 신규생성

        PERFORM bdc_dynpro     USING 'SAPLCP03' '1060'.
        PERFORM bdc_field      USING: 'RC275-SEQ_ALT'
                                      'X',             " 대체선택
                                      'BDC_OKCODE'
                                      '=WEIT'.

        PERFORM bdc_dynpro     USING 'SAPLCPDS' '1200'.
        PERFORM bdc_field      USING: 'PLFLD-VORNR1'
                                      gw_data-vornr,
                                      'PLFLD-VORNR2'
                                      gw_data-vornr1,
                                      'PLFLD-LOSBS'
                                      '99999999',
                                      'BDC_OKCODE'
                                      '=VOUE'.           " 작업
      ELSE.
        IF gw_data-indi = '등록'  AND
           gw_data-plnal = 1.
        ELSE.

*& 2009.01.22
*& C20090120_89090
*& MCFE SHE 공정은 직무 리스트번호를 SHA로 수정
          CLEAR : lv_mtart, lv_procd.

          SELECT SINGLE mtart
            INTO lv_mtart
            FROM mara
           WHERE matnr EQ gw_data-matnr.

          IF lv_mtart = 'MCFE' AND
             gp_procd = 'SHE'.
            lv_procd = 'SHA'.
          ELSE.
            lv_procd = gp_procd.
          ENDIF.

          PERFORM bdc_dynpro  USING 'SAPLCPDA' '1200'.
          PERFORM bdc_field   USING: 'PLKOD-KTEXT'
                                     gw_data-maktx,
                                     'PLKOD-VERWE'
                                     '1',          " 용도
                                     'PLKOD-STATU'
                                     '4',          " 상태
                                     'PLKOD-LOSBS'
                                     '99999999',   " 최대로트수
                                     'PLKOD-PLNME'
                                     gw_data-meins,
                                     'PLKOD-PLNNR_ALT'
                                     lv_procd,     " 직무리스트(공정)
                                     'PLKOD-SLWBEZ'
                                     '100',        " 검사포인트
                                     'PLKOD-PPKZTLZU'
                                     '0',          " 부분로트 지정
                                     'BDC_OKCODE'
                                     '=SEUE'.      " 순서
        ENDIF.

        PERFORM bdc_dynpro    USING 'SAPLCPDI' '1300'.
        PERFORM bdc_field     USING: 'BDC_OKCODE'
                                     '=VOUE'.    " 작업
      ENDIF.
    ELSE.
      CONCATENATE: 'RC27X-FLG_SEL(' lv_idx ')'  INTO lv_pre_sel.

      lv_idx = lv_idx + 1.

      CONCATENATE: 'RC27X-FLG_SEL(' lv_idx ')'  INTO lv_flg_sel.
    ENDIF.

    CONCATENATE: 'PLPOD-ARBPL(' lv_idx ')'  INTO lv_arbpl,
                 'PLPOD-STEUS(' lv_idx ')'  INTO lv_steus,
                 'PLPOD-LTXA1(' lv_idx ')'  INTO lv_ltxa1.

    PERFORM bdc_dynpro       USING 'SAPLCPDI' '1400'.
    PERFORM bdc_field        USING: lv_arbpl
                                    gw_data-arbpl,
                                    lv_steus
                                    space,
                                    lv_pre_sel
                                    space,
                                    lv_flg_sel
                                    'X'.

    IF gv_crlyn = 'X'  AND
       gw_data-aznor = 2.
    ELSE.
      PERFORM bdc_field     USING: lv_ltxa1
                                   gw_data-ktext.
    ENDIF.

    IF gw_data-vornr = gw_data-vornr1.           " 마지막 소공정이면서

      IF gp_werks = '1302' AND
         ( gw_data-arbpl+0(3) = 'DRY' OR
           gw_data-arbpl+0(3) = 'HRT' OR
           gw_data-arbpl+0(3) = 'DDD' ).  "1302,DRY,HRT,Dumy 일때는 ZP06

        PERFORM bdc_field     USING: lv_steus
                                     'ZP06'.
      ELSE.

        PERFORM bdc_field     USING: lv_steus
                                     'PP04'.
      ENDIF.

    ENDIF.

    PERFORM bdc_field        USING: 'BDC_OKCODE'
                                    '=VOD1'.        " 세부(작업)

    PERFORM bdc_dynpro       USING 'SAPLCPDO' '1200'.

    IF gv_crlyn = 'X'  AND
       gw_data-aznor = 2.
      PERFORM bdc_field     USING: 'PLPOD-KTSCH'
                                   'CRL0001'.
    ENDIF.

    PERFORM bdc_field        USING: 'PLPOD-BMSCH'  lv_basmn,
                                    'PLPOD-MEINH'  gw_data-meins.

    IF NOT ( gp_werks EQ '6500' AND gw_data-arbpl+0(3) EQ 'DRY' ).
      PERFORM bdc_field        USING: 'PLPOD-VGW01'  lw_time-vgw01,
                                      'PLPOD-VGE01'  gw_data-meinh,
                                      'PLPOD-VGW02'  lw_time-vgw02,
                                      'PLPOD-VGE02'  gw_data-meinh,
                                      'PLPOD-VGW03'  lw_time-vgw03,
                                      'PLPOD-VGE03'  gw_data-meinh,
                                      'PLPOD-VGW04'  lw_time-vgw04,
                                      'PLPOD-VGE04'  gw_data-meinh,
                                      'PLPOD-VGW05'  lw_time-vgw05,
                                      'PLPOD-VGE05'  gw_data-meinh,
                                      'PLPOD-VGW06'  lw_time-vgw06,
                                      'PLPOD-VGE06'  gw_data-meinh.
    ENDIF.

    IF gp_procd = 'CLK'  OR
       gp_procd = 'IRD'  OR
       gp_dispo = 'MGF'  OR
       gp_dispo = 'MGH'  OR
       gp_dispo = 'MAF'  OR
       gp_dispo = 'MAH'  OR
       ( gv_crlyn = 'X'  AND
         gw_data-aznor = 2 ).
      PERFORM bdc_field     USING: 'PLPOD-SPMUS'
                                   'X',              " 분할요청
                                   'PLPOD-SPLIM'
                                   lv_aznor.         " 분할수
    ENDIF.

    PERFORM bdc_field        USING: 'PLPOD-UENICHT'
                                    'X',
                                    'PLPOD-CKSELKZ'
                                    'X',              " 원가관련 지시자
                                    'PLPOD-QPPKTABS'
                                    '2',              " 검사지점(평가)
                                    'PLPOD-QKZPRINI'
                                    space,            " 참조유지보수
                                    'PLPOD-QKZPRFREI'
                                    'X',              " 관계없음
                                    'PLPOD-SLWID'     " 사용자 고유필드
                                    'PP00001',
                                    'BDC_OKCODE'
                                    '/00'.

    PERFORM bdc_dynpro       USING  'SAPLCPDO' '   1200'.
    PERFORM bdc_field        USING: 'PLPOD-USR04'  lv_rdrnp,
                                    'BDC_OKCODE'   '/00'.

*// Modified by ZGODEV06 on 2026-05-15 {
*    IF gw_data-usr05 IS NOT INITIAL AND gw_data-use05 IS NOT INITIAL.
*      WRITE gw_data-usr05 UNIT gw_data-use05 TO lv_usr05.
*      PERFORM bdc_field        USING: 'PLPOD-USR05' lv_usr05,
*                                      'PLPOD-USE05' gw_data-use05.
*    ENDIF.

    lv_usr05 = gw_data-usr05.
    PERFORM bdc_field  USING 'PLPOD-USR05' lv_usr05.

    lv_usr07 = trunc( gw_data-usr07 ).   "2026.06.16 KSW
    PERFORM bdc_field  USING 'PLPOD-USR07' lv_usr07.    "2026.06.16 KSW

    IF  gp_werks EQ '6500' AND gw_data-arbpl+0(3) EQ 'DRY' .
      lv_usr06 = trunc( gw_data-optim ). "/ 가동시간.
      PERFORM bdc_field  USING 'PLPOD-USR06' lv_usr06.
    ENDIF.
*// }


    IF gt_data-dpcbt <> space AND gw_data-vornr = gw_data-vornr1.            " 마지막 소공정이면
*// Modified by ZGODEV06 on 2026-01-16 {
*       gw_data-vornr  = gw_data-vornr1.            " 마지막 소공정이면
*      PERFORM bdc_field     USING: 'PLPOD-/SAPMP/MET_LRCH'
*                                   space,
*                                   'PLPOD-/SAPMP/FIX_AS_J'
*                                   lv_qmmgn.

      PERFORM bdc_field       USING 'PLPOD-/SAPMP/FIX_AS_J' lv_qmmgn. "// 검사여장.

      IF gw_data-tuhnk IS NOT INITIAL.
        PERFORM bdc_dynpro    USING  'SAPLCPDO'              '1200'.
        PERFORM bdc_field     USING: 'BDC_OKCODE'            '/00',
                                      'PLPOD-/SAPMP/MET_LRCH' '2'.
        PERFORM bdc_dynpro    USING  'SAPLCPDO'              '1200'.
        PERFORM bdc_field     USING  'PLPOD-/SAPMP/MAX_FERTL' lv_tuhnk. "// TU 만권량.
      ENDIF.
    ELSE.
      PERFORM bdc_dynpro    USING  'SAPLCPDO'              '1200'.
*// }
    ENDIF.

*// Modified by ZGODEV06 on 2026-01-16{
*    IF gw_data-vornr = gw_data-vornr1.            " 마지막 소공정이면
*      PERFORM bdc_field        USING: 'BDC_OKCODE'  " 공정검사
*                                      '=QMUE'.
*
*      PERFORM bdc_dynpro       USING 'SAPLQPAA' '0150'.
*      PERFORM bdc_field        USING: 'PLMKB-VERWMERKM(01)'
*                                      gw_qpmz-mkmnr,
*                                      'BDC_OKCODE'
*                                     '/00'.
*
*      PERFORM bdc_dynpro       USING 'SAPLQPAA' '1501'.
*      PERFORM bdc_field        USING: 'PLMKB-VERWMERKM'
*                                      gw_qpmz-mkmnr,
*                                     'PLMKB-QPMK_WERKS'
*                                      gw_qpmz-zaehler,
*                                      'PLMKB-MKVERSION'
*                                      gw_qpmz-version,
*                                      'PLMKB-PMETHODE'
*                                      gw_qpmz-pmethode,
*                                      'PLMKB-QMTB_WERKS'
*                                      gw_qpmz-werkpm,
*                                      'PLMKB-PMTVERSION'
*                                      gw_qpmz-verspm,
*                                      'BDC_OKCODE'
*                                      '=ENT1'.
*
*      PERFORM bdc_dynpro       USING 'SAPLQPAA' '1502'.
*      PERFORM bdc_field        USING: 'PLMKB-PMETHODE'
*                                      gw_qpmz-pmethode,
*                                      'PLMKB-QMTB_WERKS'
*                                      gw_qpmz-werkpm,
*                                      'PLMKB-PMTVERSION'
*                                      gw_qpmz-verspm,
*                                      'BDC_OKCODE'
*                                      '=ENT1'.
*
*      PERFORM bdc_dynpro       USING 'SAPLQPAA' '0150'.
*      PERFORM bdc_field        USING: 'BDC_OKCODE'
*                                      '=SVUE'.
*    ELSE.
*// }

    PERFORM bdc_field        USING: 'BDC_OKCODE' '=BACK'.

*// Modified by ZGODEV06 on 2026-01-16 {
*   ENDIF.
*// }

  ENDLOOP.

ENDFORM.                    " bdc_routing_create_by_ca01

*&---------------------------------------------------------------------*
*&      Form  compute_create_routing
*&---------------------------------------------------------------------*
FORM compute_create_routing.
  DATA: lv_tabix   TYPE sy-tabix,
        lv_verid   TYPE mkal-verid,
        lv_message TYPE char100.

  PERFORM bdc_dynpro USING 'SAPLCPDI' ' 1400'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '=BU'.

  PERFORM bdc_transaction USING 'CA01'.

*& 처리결과를 읽는다.
  PERFORM edit_error_message  USING lv_message.

*& BDC처리시 에러발생 여부 체크
  IF NOT lv_message IS INITIAL.
    gt_data-message = lv_message.
  ELSE.
    COMMIT WORK AND WAIT.

    READ TABLE gt_messtab WITH KEY msgtyp = 'S'.
    gt_data-plnnr = gt_messtab-msgv1.

    DO 30 TIMES.
      SELECT MAX( plnal )
        INTO gt_data-plnal
        FROM mapl
       WHERE matnr  = gt_data-matnr
         AND werks  = gp_werks
         AND plnty  = 'N'
         AND plnnr  = gt_data-plnnr
         AND loekz  = space.

      IF sy-subrc = 0.
        EXIT.
      ENDIF.

      WAIT UP TO '0.3' SECONDS.
    ENDDO.
  ENDIF.

  gt_data = VALUE #( BASE gt_data  arbpl_icon = COND #( WHEN lv_message IS INITIAL THEN icon_led_green
                                                        ELSE icon_led_red )
                                   arbpl_ind  = gc_proc_type-create
                                   arbpl_stat = COND #( WHEN lv_message IS INITIAL THEN gc_result-success
                                                        ELSE gc_result-error ) ).

  LOOP AT gt_exec.
    lv_tabix = sy-tabix.

    gt_exec-message    = gt_data-message.
    gt_exec-arbpl_icon = gt_data-arbpl_icon.
    gt_exec-arbpl_ind  = gt_data-arbpl_ind.
    gt_exec-arbpl_stat = gt_data-arbpl_stat.

    IF gt_data-message IS INITIAL.
      gt_exec-plnnr = gt_data-plnnr.
    ENDIF.

    IF gv_spgcd <> 'MA'  AND         " SPG가 권선/제선이 아니면
       gv_spgcd <> 'MG'.             " 생산버젼 생성
      IF gt_exec-plnnr IS NOT INITIAL  AND
         gt_exec-plnfl = 0             AND
         gt_exec-vornr = 10.
*        PERFORM append_insert_prod_version  CHANGING lv_verid.
*        gt_exec-verid = lv_verid.

        IF gt_data-message IS INITIAL.
          PERFORM submit_zgtppr1110 USING gt_data gc_proc_type-create.
        ENDIF.
      ENDIF.
    ENDIF.

    gt_exec-verid      = gt_data-verid.
    gt_exec-verid_icon = gt_data-verid_icon.
    gt_exec-verid_ind  = gt_data-verid_ind.
    gt_exec-verid_stat = gt_data-verid_stat.

    MODIFY gt_exec  INDEX lv_tabix.
  ENDLOOP.

ENDFORM.                    " compute_create_routing

*&---------------------------------------------------------------------*
*&      Form  bdc_routing_modify_by_ca02
*&---------------------------------------------------------------------*
FORM bdc_routing_modify_by_ca02.
  DATA: lv_idx     TYPE numc2,
        lv_arbpl   TYPE char30,
        lv_steus   TYPE char30,
        lv_plnal   TYPE char10,
        lv_plnfl   TYPE char10,
        lv_ltxa1   TYPE char30,
        lv_basmn   TYPE char17,
        lv_qmmgn   TYPE char17,
        lv_tuhnk   TYPE char17,
        lv_aznor   TYPE char3,
        lv_rdrnp   TYPE char17,
        lv_message TYPE char100,
        lv_usr05   TYPE char18,
        lv_usr06   TYPE char18,
        lv_usr07   TYPE char18.   "2026.06.16 KSW

  DATA: BEGIN OF lw_time,
          vgw01 TYPE char11,       " 가동준비시간
          vgw02 TYPE char11,       " 기계시간(가동)
          vgw03 TYPE char11,       " 제조지원
          vgw04 TYPE char11,       " 제조직접
          vgw05 TYPE char11,       " 배부간접
          vgw06 TYPE char11,       " 노무시간
        END   OF lw_time.

  REFRESH: gt_bdcdata, gt_messtab.
  CLEAR:   gt_bdcdata, gt_messtab, gw_temp, lv_idx.

  PERFORM bdc_dynpro      USING 'SAPLCPDI' '1010'.
  PERFORM bdc_field       USING: 'RC27M-MATNR'
                                 gt_data-matnr,
                                 'RC27M-WERKS'
                                 gp_werks,
                                 'RC271-PLNNR'
                                 space,
                                 'RC271-STTAG'
                                 sy-datum,
                                 'BDC_OKCODE'
                                 '=ALUE'.        " 공정

  LOOP AT gt_exec  INTO gw_data
                  WHERE modify = 'X'.
    CLEAR: lw_time.

    WRITE: gw_data-basmn  TO lv_basmn NO-GROUPING,
           gw_data-qmmgn  TO lv_qmmgn NO-GROUPING,
           gw_data-tuhnk  TO lv_tuhnk NO-GROUPING,
           gw_data-aznor  TO lv_aznor NO-GROUPING,
           gw_data-rdrnp  TO lv_rdrnp NO-GROUPING.

    WRITE: gw_data-ruezt  TO lw_time-vgw01 NO-GROUPING,
           gw_data-optim  TO lw_time-vgw02 NO-GROUPING,
           gw_data-optim  TO lw_time-vgw03 NO-GROUPING,
           gw_data-optim  TO lw_time-vgw04 NO-GROUPING,
           gw_data-optim  TO lw_time-vgw05 NO-GROUPING,
           gw_data-wktim  TO lw_time-vgw06 NO-GROUPING.

    WRITE: gw_data-plnal  TO lv_plnal  NO-GROUPING LEFT-JUSTIFIED,
           gw_data-plnfl  TO lv_plnfl  NO-GROUPING LEFT-JUSTIFIED.

    lv_plnfl = lv_plnfl + 1.

* SRM2507-04065 작업장내역 없으면 조회
    IF gw_data-ktext IS INITIAL.
      SELECT SINGLE ktext
          INTO gw_data-ktext
      FROM m_cramn
    WHERE arbpl = gw_data-arbpl
         AND werks = gp_werks.
    ENDIF.
* SRM2507-04065

    PERFORM bdc_dynpro       USING 'SAPLCPDI' '1200'.
    PERFORM bdc_field        USING: 'BDC_OKCODE'
                                    '=MALO'.      " 전체취소

    PERFORM bdc_dynpro       USING 'SAPLCPDI' '1200'.
    PERFORM bdc_field        USING: 'RC27X-ENTRY_ACT'
                                    lv_plnal,
                                    'BDC_OKCODE'
                                    '/00'.

    PERFORM bdc_dynpro       USING 'SAPLCPDI' '1200'.
    PERFORM bdc_field        USING: 'RC27X-FLG_SEL(01)'
                                    'X',
                                    'BDC_OKCODE'
                                    '=SEUE'.      " 순서

    PERFORM bdc_dynpro       USING 'SAPLCPDI' '1300'.
    PERFORM bdc_field        USING: 'BDC_OKCODE'
                                    '=MALO'.      " 전체취소

    PERFORM bdc_dynpro       USING 'SAPLCPDI' '1300'.
    PERFORM bdc_field        USING: 'RC27X-ENTRY_ACT'
                                    lv_plnfl,
                                    'BDC_OKCODE'
                                    '/00'.

    PERFORM bdc_dynpro       USING 'SAPLCPDI' '1300'.
    PERFORM bdc_field        USING: 'RC27X-FLG_SEL(01)'
                                    'X',
                                    'BDC_OKCODE'
                                    '=VOUE'.        " 작업

    PERFORM bdc_dynpro       USING 'SAPLCPDI' '1400'.
    PERFORM bdc_field        USING: 'BDC_OKCODE'
                                    '=OSEA'.

    PERFORM bdc_dynpro       USING 'SAPLCP02' '1010'.
    PERFORM bdc_field        USING: 'RC27H-VORNR'
                                    gw_data-vornr,
                                    'BDC_OKCODE'
                                    '=ENT1'.

    PERFORM bdc_dynpro       USING 'SAPLCPDI' '1400'.
    PERFORM bdc_field        USING: 'RC27X-FLG_SEL(01)'
                                    'X',
                                    'BDC_OKCODE'
                                    '=VOD1'.        " 세부(작업)

    PERFORM bdc_dynpro       USING 'SAPLCPDO' '1200'.
    PERFORM bdc_field        USING: 'PLPOD-ARBPL'
                                    gw_data-arbpl.

    IF gv_crlyn = 'X'  AND
       gw_data-aznor = 2.
      PERFORM bdc_field     USING: 'PLPOD-KTSCH'
                                   'CRL0001'.
    ELSE.
      PERFORM bdc_field     USING: 'PLPOD-LTXA1'
                                   gw_data-ktext.
    ENDIF.

    IF gw_data-vornr = gw_data-vornr1.    " 마지막 소공정이면서

      IF gp_werks = '1302' AND
        ( gw_data-arbpl+0(3) = 'DRY' OR
          gw_data-arbpl+0(3) = 'HRT' OR
          gw_data-arbpl+0(3) = 'DDD' ).  "1302,DRY,HRT,Dumy 일때는 ZP06

        PERFORM bdc_field     USING: 'PLPOD-STEUS'
                                     'ZP06'.
      ELSE.
        PERFORM bdc_field     USING: 'PLPOD-STEUS'
                                  'PP04'.
      ENDIF.

    ENDIF.

    PERFORM bdc_field        USING: 'PLPOD-BMSCH'  lv_basmn,
                                    'PLPOD-MEINH'  gw_data-meins.

    IF NOT ( gp_werks EQ '6500' AND gw_data-arbpl+0(3) EQ 'DRY' ).
      PERFORM bdc_field        USING: 'PLPOD-VGW01'  lw_time-vgw01,
                                      'PLPOD-VGE01'  gw_data-meinh,
                                      'PLPOD-VGW02'  lw_time-vgw02,
                                      'PLPOD-VGE02'  gw_data-meinh,
                                      'PLPOD-VGW03'  lw_time-vgw03,
                                      'PLPOD-VGE03'  gw_data-meinh,
                                      'PLPOD-VGW04'  lw_time-vgw04,
                                      'PLPOD-VGE04'  gw_data-meinh,
                                      'PLPOD-VGW05'  lw_time-vgw05,
                                      'PLPOD-VGE05'  gw_data-meinh,
                                      'PLPOD-VGW06'  lw_time-vgw06,
                                      'PLPOD-VGE06'  gw_data-meinh.
    ENDIF.

    IF gp_procd = 'CLK'  OR
       gp_procd = 'IRD'  OR
       gp_dispo = 'MGF'  OR
       gp_dispo = 'MGH'  OR
       gp_dispo = 'MAF'  OR
       gp_dispo = 'MAH'  OR
       ( gv_crlyn = 'X'  AND
         gw_data-aznor = 2 ).
      PERFORM bdc_field     USING: 'PLPOD-SPMUS'
                                   'X',              " 분할요청
                                   'PLPOD-SPLIM'
                                   lv_aznor.         " 분할수
    ENDIF.

    PERFORM bdc_field        USING: 'PLPOD-UENICHT'
                                    'X',
                                    'PLPOD-CKSELKZ'
                                    'X',              " 원가관련 지시자
                                    'PLPOD-QPPKTABS'
                                    '2',              " 검사지점(평가)
                                    'PLPOD-QKZPRINI'
                                    space,            " 참조유지보수
                                    'PLPOD-QKZPRFREI'
                                    'X',              " 관계없음
                                    'PLPOD-SLWID'     " 사용자 고유필드
                                    'PP00001',
                                    'BDC_OKCODE'
                                    '/00'.

    PERFORM bdc_dynpro       USING 'SAPLCPDO' '1200'.
    PERFORM bdc_field        USING: 'PLPOD-USR04'  lv_rdrnp,
                                    'BDC_OKCODE'   '/00'.


*// Modified by ZGODEV06 on 2026-05-15 {
*    IF  gw_data-usr05 IS NOT INITIAL AND gw_data-use05 IS NOT INITIAL.
*      WRITE gw_data-usr05 UNIT gw_data-use05 TO lv_usr05.
*      PERFORM bdc_field        USING: 'PLPOD-USR05' lv_usr05,
*                                      'PLPOD-USE05' gw_data-use05.
*    ENDIF.

    lv_usr05 = gw_data-usr05.
    PERFORM bdc_field  USING 'PLPOD-USR05' lv_usr05.

    lv_usr07 = trunc( gw_data-usr07 ).   "2026.06.16 KSW
    PERFORM bdc_field  USING 'PLPOD-USR07' lv_usr07.    "2026.06.16 KSW

    IF  gp_werks EQ '6500' AND gw_data-arbpl+0(3) EQ 'DRY' .
      lv_usr06 = trunc( gw_data-optim ). "/ 가동시간.
      PERFORM bdc_field  USING 'PLPOD-USR06' lv_usr06.
    ENDIF.
*// }

    IF gt_data-dpcbt <> space AND gw_data-vornr = gw_data-vornr1.            " 마지막 소공정이면
*// Modified by ZGODEV06 on 2026-01-16 {
*       gw_data-vornr  = gw_data-vornr1.            " 마지막 소공정이면
*      PERFORM bdc_field     USING: 'PLPOD-/SAPMP/MET_LRCH'
*                                   space,
*                                   'PLPOD-/SAPMP/FIX_AS_J'
*                                   lv_qmmgn.

      PERFORM bdc_field       USING 'PLPOD-/SAPMP/FIX_AS_J' lv_qmmgn. "// 검사여장.

      IF gw_data-tuhnk IS NOT INITIAL.
        PERFORM bdc_dynpro    USING  'SAPLCPDO'              '1200'.
        PERFORM bdc_field     USING: 'BDC_OKCODE'            '/00',
                                      'PLPOD-/SAPMP/MET_LRCH' '2'.
        PERFORM bdc_dynpro    USING  'SAPLCPDO'              '1200'.
        PERFORM bdc_field     USING  'PLPOD-/SAPMP/MAX_FERTL' lv_tuhnk. "// TU 만권량.
      ENDIF.
    ELSE.
      PERFORM bdc_dynpro    USING  'SAPLCPDO'              '1200'.
*// }
    ENDIF.

    PERFORM bdc_field        USING: 'BDC_OKCODE'
                                    '=ALUE'.    " 공정
  ENDLOOP.

  PERFORM bdc_dynpro         USING 'SAPLCPDI'   '1200'.
  PERFORM bdc_field          USING 'BDC_OKCODE' '=BU'.

  PERFORM bdc_transaction USING 'CA02'.

*& 처리결과를 읽는다.
  PERFORM edit_error_message  USING lv_message.

*& BDC처리시 에러발생 여부 체크
  IF NOT lv_message IS INITIAL.
    gv_error = 9999.
  ELSE.
    COMMIT WORK  AND WAIT.
    gv_error = 0.
  ENDIF.

  MODIFY gt_exec FROM VALUE #( arbpl_icon = COND #( WHEN lv_message IS INITIAL THEN icon_led_green
                                                    ELSE icon_led_red )
                               arbpl_ind  = gc_proc_type-change
                               arbpl_stat = COND #( WHEN lv_message IS INITIAL THEN gc_result-success
                                                    ELSE gc_result-error ) )
                 TRANSPORTING arbpl_icon arbpl_ind arbpl_stat
                 WHERE matnr EQ gt_data-matnr.

ENDFORM.                    " bdc_routing_modify_by_ca02

*&---------------------------------------------------------------------*
*&      Form  bdc_routing_delete_by_ca02
*&---------------------------------------------------------------------*
FORM bdc_routing_delete_by_ca02.
  DATA: lv_message          TYPE char100.

  REFRESH: gt_bdcdata, gt_messtab.
  CLEAR:   gt_bdcdata, gt_messtab, lv_message.

  PERFORM bdc_dynpro      USING 'SAPLCPDI'      '1010'.
  PERFORM bdc_field       USING: 'RC27M-MATNR'  gt_data-matnr,
                                 'RC27M-WERKS'  gp_werks,
                                 'RC271-PLNNR'  gt_data-plnnr1,
                                 'RC271-PLNAL'  '  ',
                                 'RC271-STTAG'  sy-datum,
                                 'BDC_OKCODE'   '=ALUE'.

  PERFORM bdc_dynpro      USING 'SAPLCPDI' '1200'.
  PERFORM bdc_field       USING: 'BDC_OKCODE'     '=MAAL'.

  PERFORM bdc_dynpro      USING 'SAPLCPDI' '1200'.
  PERFORM bdc_field       USING: 'RC27X-ENTRY_ACT' '1',
                                 'BDC_OKCODE'     '=LOE'.

  PERFORM bdc_dynpro      USING 'SAPLSPO1'        '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'     '=YES'.

  PERFORM bdc_dynpro      USING 'SAPLCPDI'        '1200'.
  PERFORM bdc_field       USING 'BDC_OKCODE'     '=BU'.

  PERFORM bdc_transaction USING 'CA02'.

*& 처리결과를 읽는다.
  PERFORM edit_error_message  USING lv_message.

*& BDC처리시 에러발생 여부 체크
  IF NOT lv_message IS INITIAL.
    gv_error = 9999.
  ELSE.
    COMMIT WORK  AND WAIT.
    gv_error = 0.
  ENDIF.

  MODIFY gt_exec FROM VALUE #( message    = lv_message
                               arbpl_icon = COND #( WHEN gv_error IS INITIAL THEN icon_led_green
                                                    ELSE icon_led_red )
                               arbpl_ind  = gc_proc_type-delete
                               arbpl_stat = COND #( WHEN gv_error IS INITIAL THEN gc_result-success
                                                    ELSE gc_result-error ) )
                 TRANSPORTING message arbpl_icon arbpl_ind arbpl_stat
                 WHERE matnr EQ gt_data-matnr.

ENDFORM.                    " bdc_routing_delete_by_ca02

*&---------------------------------------------------------------------*
*&      Form  bdc_delete_grc_by_ca01
*&---------------------------------------------------------------------*
FORM bdc_delete_grc_by_ca01 USING ps_data LIKE LINE OF gt_data.
  DATA lv_message TYPE char100.

  REFRESH: gt_bdcdata, gt_messtab.
  CLEAR:   gt_bdcdata, gt_messtab, lv_message.

  PERFORM bdc_dynpro  USING  'SAPLCPDI'    '1010'.
  PERFORM bdc_field   USING  'RC27M-MATNR' ps_data-matnr.
  PERFORM bdc_field   USING  'RC27M-WERKS' gp_werks.
  PERFORM bdc_field   USING  'RC271-PLNNR' ps_data-plnnr.
  PERFORM bdc_field   USING  'BDC_OKCODE'  '/00'.
  PERFORM bdc_dynpro  USING  'SAPLCPDI'    '1200'.
  PERFORM bdc_field   USING  'BDC_OKCODE'  '=MAAL'.
  PERFORM bdc_dynpro  USING  'SAPLCPDI'    '1200'.
  PERFORM bdc_field   USING  'BDC_OKCODE'  '=LOE'.
  PERFORM bdc_dynpro  USING  'SAPLSPO1'    '0100'.
  PERFORM bdc_field   USING  'BDC_OKCODE'  '=YES'.
  PERFORM bdc_dynpro  USING  'SAPLCPDI'    '1200'.
  PERFORM bdc_field   USING  'BDC_OKCODE'  '=BU'.

  PERFORM bdc_transaction USING 'CA01'.

*& 처리결과를 읽는다.
  PERFORM edit_error_message  USING lv_message.

*& BDC처리시 에러발생 여부 체크
  IF NOT lv_message IS INITIAL.
    gv_error = 9999.
  ELSE.
    COMMIT WORK  AND WAIT.
    gv_error = 0.
  ENDIF.

  MODIFY gt_exec FROM VALUE #( arbpl_icon = COND #( WHEN lv_message IS INITIAL THEN icon_led_green
                                                    ELSE icon_led_red )
                               arbpl_ind  = gc_proc_type-delete
                               arbpl_stat = COND #( WHEN lv_message IS INITIAL THEN gc_result-success
                                                    ELSE gc_result-error ) )
                 TRANSPORTING arbpl_icon arbpl_ind arbpl_stat
                 WHERE matnr EQ ps_data-matnr
                   AND plnnr EQ ps_data-plnnr.

ENDFORM.                    " bdc_delete_grc_by_ca01

*&---------------------------------------------------------------------*
*&      Form  bdc_delete_grc_by_ca98
*&---------------------------------------------------------------------*
FORM bdc_delete_grc_by_ca98 USING ps_data LIKE LINE OF gt_data.
  DATA: lv_message          TYPE char100.

  REFRESH: gt_bdcdata, gt_messtab.
  CLEAR:   gt_bdcdata, gt_messtab, lv_message.

  PERFORM bdc_dynpro      USING 'RCPREDE2' '1000'.
  PERFORM bdc_field       USING: 'MATNR-LOW'
                                 ps_data-matnr,
                                 'WERKM'
                                 gp_werks,
                                 'PLNTY-LOW'
                                 'N',
                                 'PLNNR-LOW'
                                 ps_data-plnnr,
                                 'BDC_OKCODE'
                                 '=ONLI'.

  PERFORM bdc_dynpro      USING 'SAPLCPRE' '1010'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.

  PERFORM bdc_dynpro      USING 'SAPMSSY0' '0120'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.

  PERFORM bdc_dynpro      USING 'RCPREDE2' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/EE'.

  PERFORM bdc_transaction USING 'CA98'.

*& 처리결과를 읽는다.
  PERFORM edit_error_message  USING lv_message.

*& BDC처리시 에러발생 여부 체크
  IF NOT lv_message IS INITIAL.
    gv_error = 9999.
  ELSE.
    COMMIT WORK  AND WAIT.
    gv_error = 0.
  ENDIF.

  MODIFY gt_exec FROM VALUE #( arbpl_icon = COND #( WHEN lv_message IS INITIAL THEN icon_led_green
                                                    ELSE icon_led_red )
                               arbpl_ind  = gc_proc_type-delete
                               arbpl_stat = COND #( WHEN lv_message IS INITIAL THEN gc_result-success
                                                    ELSE gc_result-error ) )
                 TRANSPORTING arbpl_icon arbpl_ind arbpl_stat
                 WHERE matnr EQ ps_data-matnr
                   AND plnnr EQ ps_data-plnnr.

ENDFORM.                    " bdc_delete_grc_by_ca98

*&---------------------------------------------------------------------*
*&      Form  bdc_delete_version_by_c223
*&---------------------------------------------------------------------*
FORM bdc_delete_version_by_c223.
  DATA: lv_message          TYPE char100.

  REFRESH: gt_bdcdata, gt_messtab.
  CLEAR:   gt_bdcdata, gt_messtab, lv_message.

  PERFORM bdc_dynpro      USING 'SAPLCMFV' '1000'.
  PERFORM bdc_field       USING: 'MKAL-WERKS'
                                 gp_werks,
                                 'MKAL-MATNR'
                                 gw_data-matnr,
                                 'MKAL_ADMIN-DISPO'
                                 gw_data-dispo,
                                 'MKAL-PLNTY'
                                 'N',
                                 'MKAL-PLNNR'
                                 ' ', "GW_DATA-PLNNR,
                                 'BDC_OKCODE'
                                 '=ENTE'.

  PERFORM bdc_dynpro      USING 'SAPLCMFV' '1000'.
  PERFORM bdc_field       USING: 'BDC_OKCODE'
                                 '=MAAL'.

  PERFORM bdc_dynpro      USING 'SAPLCMFV' '1000'.
  PERFORM bdc_field       USING: 'BDC_OKCODE'
                                 '=DELE'.

  PERFORM bdc_dynpro      USING 'SAPLSPO1' '0100'.
  PERFORM bdc_field       USING: 'BDC_OKCODE'
                                 '=YES'.

  PERFORM bdc_dynpro      USING 'SAPLCMFV' '1000'.
  PERFORM bdc_field       USING: 'BDC_OKCODE'
                                 '/EBACK'.

  PERFORM bdc_dynpro      USING 'SAPLSPO1' '0300'.
  PERFORM bdc_field       USING: 'BDC_OKCODE'
                                 '=YES'.

  PERFORM bdc_transaction USING 'C223'.

*& 처리결과를 읽는다.
  PERFORM edit_error_message  USING lv_message.

*& BDC처리시 에러발생 여부 체크
  IF lv_message IS NOT INITIAL.
    gv_error = 9999.
    gt_data-message = lv_message.
  ELSE.
    COMMIT WORK  AND WAIT.
    gv_error = 0.
  ENDIF.

ENDFORM.                    " bdc_delete_version_by_c223

*&---------------------------------------------------------------------*
*&      Form  marking_version_indicator
*&---------------------------------------------------------------------*
FORM marking_version_indicator  USING pv_message.
  REFRESH: gt_bdcdata, gt_messtab.
  CLEAR:   gt_bdcdata, gt_messtab.

  PERFORM bdc_dynpro      USING 'SAPLMGMM' '0060'.
  PERFORM bdc_field       USING: 'RMMG1-MATNR'
                                 gt_exec-matnr,
                                 'BDC_OKCODE'
                                  '=AUSW'.

  PERFORM bdc_dynpro      USING 'SAPLMGMM' '0070'.
  PERFORM bdc_field       USING: 'MSICHTAUSW-KZSEL(01)'
                                 'X',
                                 'BDC_OKCODE'
                                 '=ENTR'.

  PERFORM bdc_dynpro      USING 'SAPLMGMM' '5004'.
  PERFORM bdc_field       USING: 'BDC_OKCODE'
                                 '=SP16'.              " MRP View

  PERFORM bdc_dynpro      USING 'SAPLMGMM' '0081'.
  PERFORM bdc_field       USING: 'RMMG1-WERKS'
                                 gp_werks,
                                 'BDC_OKCODE'
                                 '=ENTR'.

  PERFORM bdc_dynpro      USING 'SAPLMGMM' '5004'.
  PERFORM bdc_field       USING: 'BDC_OKCODE'
                                 '=PB03'.
  " 생산버전 버튼선택

  PERFORM bdc_dynpro      USING 'SAPLMDIA' '0100'.
  PERFORM bdc_field       USING: 'BDC_OKCODE'
                                 '/EABR'.

  PERFORM bdc_dynpro      USING 'SAPLMGMM' '5004'.
  PERFORM bdc_field       USING: 'BDC_OKCODE'
                                 '=BU'.

  PERFORM bdc_transaction USING 'MM02'.

*& 처리결과를 읽는다.
  PERFORM edit_error_message  USING pv_message.

  IF pv_message IS NOT INITIAL.
    pv_message = '버젼지시자 설정시 오류발생 했습니다.'.
  ENDIF.
ENDFORM.                    " marking_version_indicator

*&---------------------------------------------------------------------*
*&      Form  SETTING_BDC_PARAMS
*&---------------------------------------------------------------------*
FORM setting_bdc_params.
  CLEAR: gw_bdcparams.

  gw_bdcparams-dismode  = 'A'.   " 처리모드
  gw_bdcparams-updmode  = 'L'.   " 갱신세션
  gw_bdcparams-cattmode = 'A'.   " CATT모드
  gw_bdcparams-defsize  = 'X'.   " 기본화면
  gw_bdcparams-racommit = 'X'.   " COMMAND 이후 지속
  gw_bdcparams-nobinpt  = ' '.   " BI 세션
ENDFORM.                    " SETTING_BDC_PARAMS

*&---------------------------------------------------------------------*
*&      Form  CALL_BDC_TRANSACTION
*&---------------------------------------------------------------------*
*   T-CODE를 넘겨받는다.
*----------------------------------------------------------------------*
FORM bdc_transaction  USING p_tcode.
  CALL TRANSACTION p_tcode USING gt_bdcdata
                         OPTIONS FROM gw_bdcparams
                   MESSAGES INTO gt_messtab.
ENDFORM.                    " BDC_TRANSACTION

*&---------------------------------------------------------------------*
*&     FORM bdc_dynpro
*&---------------------------------------------------------------------*
FORM bdc_dynpro  USING program dynpro.
  CLEAR gt_bdcdata.
  gt_bdcdata-program  = program.
  gt_bdcdata-dynpro   = dynpro.
  gt_bdcdata-dynbegin = 'X'.
  APPEND gt_bdcdata.
ENDFORM.                    " bdc_dynpro

*&---------------------------------------------------------------------*
*&     FORM bdc_field
*&---------------------------------------------------------------------*
FORM bdc_field  USING fnam fval.
  CLEAR gt_bdcdata.
  gt_bdcdata-fnam = fnam.
  gt_bdcdata-fval = fval.
  APPEND gt_bdcdata.
ENDFORM.                    " bdc_field

*&---------------------------------------------------------------------*
*&      Form  edit_error_message
*&---------------------------------------------------------------------*
FORM edit_error_message  USING p_text.
  CLEAR: p_text.

  LOOP AT gt_messtab  WHERE msgtyp = 'A'
                         OR msgtyp = 'E'
                         OR msgtyp = 'X'.
    PERFORM message_text_build  USING p_text.
    EXIT.
  ENDLOOP.

ENDFORM.                    " edit_error_message

*&---------------------------------------------------------------------*
*&      Form  message_text_build
*&---------------------------------------------------------------------*
FORM message_text_build  USING p_text.
  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      msgid               = gt_messtab-msgid
      msgnr               = gt_messtab-msgnr
      msgv1               = gt_messtab-msgv1
      msgv2               = gt_messtab-msgv2
      msgv3               = gt_messtab-msgv3
      msgv4               = gt_messtab-msgv4
    IMPORTING
      message_text_output = p_text.
ENDFORM.                    " message_text_build

*&---------------------------------------------------------------------*
*&      Form  prodordconf_create
*&---------------------------------------------------------------------*
FORM prodordconf_create.
  CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
    IMPORTING
      return             = gw_ret1
    TABLES
      timetickets        = gt_time
      goodsmovements     = gt_goods
      link_conf_goodsmov = gt_link
      detail_return      = gt_coru.
ENDFORM.                    " prodordconf_create

*&---------------------------------------------------------------------*
*&      Form  prodordconf_create_wo_goodsmvt
*&---------------------------------------------------------------------*
FORM prodordconf_create_wo_goodsmvt.
  CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
    IMPORTING
      return         = gw_ret1
    TABLES
      timetickets    = gt_time
      goodsmovements = gt_goods
      detail_return  = gt_coru.
ENDFORM.                    " prodordconf_create_wo_goodsmvt

*&---------------------------------------------------------------------*
*&      Form  prodordconf_create_testrun
*&---------------------------------------------------------------------*
FORM prodordconf_create_testrun.
  CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
    EXPORTING
      testrun            = 'X'
    IMPORTING
      return             = gw_ret1
    TABLES
      timetickets        = gt_time
      goodsmovements     = gt_goods
      link_conf_goodsmov = gt_link
      detail_return      = gt_coru.
ENDFORM.                    " prodordconf_create_testrun

*&---------------------------------------------------------------------*
*&      Form  prodordconf_create_move_timeevent
*&---------------------------------------------------------------------*
FORM prodordconf_create_timeevent  USING pv_testrun.
  CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TE'
    EXPORTING
      testrun        = pv_testrun
    IMPORTING
      return         = gw_ret1
    TABLES
      timeevents     = gt_event
      goodsmovements = gt_goods
      detail_return  = gt_coru.
ENDFORM.                    " prodordconf_create_timeevent

*&---------------------------------------------------------------------*
*&      Form  check_commit_rollback
*&---------------------------------------------------------------------*
FORM check_commit_rollback  CHANGING p_flag
                                     p_text.
  IF gw_coru IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    p_flag = 'X'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CONCATENATE gw_coru-id gw_coru-number gw_coru-message
                              INTO p_text SEPARATED BY space.
  ENDIF.
ENDFORM.                    " check_commit_rollback

*&---------------------------------------------------------------------*
*&      Form  read_table_gt_ret
*&---------------------------------------------------------------------*
FORM read_table_gt_ret  CHANGING p_flag
                                 p_text.
  CLEAR: gw_coru.

  READ TABLE gt_ret  INDEX 1.

  IF NOT gt_ret[] IS INITIAL.
    MOVE-CORRESPONDING gt_ret TO gw_coru.
  ENDIF.

  PERFORM check_commit_rollback  USING p_flag
                                       p_text.
ENDFORM.                    " read_table_gt_ret2

*&---------------------------------------------------------------------*
*&      Form  read_table_gt_ret1
*&---------------------------------------------------------------------*
FORM read_table_gt_ret1  CHANGING p_flag
                                  p_text.
*&   오류가 있는 경우만 Rollback하고 오류가 없으면 다음 작업에서 일괄
*&   Commit 작업을 위해
  IF gw_coru IS INITIAL.
    p_flag = 'X'.
  ELSE.
    CONCATENATE gw_coru-id gw_coru-number gw_coru-message
                              INTO p_text SEPARATED BY space.
  ENDIF.
ENDFORM.                    " read_table_gt_ret1

*&---------------------------------------------------------------------*
*&      Form  read_table_gt_ret2
*&---------------------------------------------------------------------*
FORM read_table_gt_ret2  CHANGING p_flag
                                  p_text.
  CLEAR: gw_coru.

  READ TABLE gt_ret2  WITH KEY type = 'E'.

  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING gt_ret2 TO gw_coru.
  ENDIF.

  PERFORM check_commit_rollback  USING p_flag
                                       p_text.
ENDFORM.                    " read_table_gt_ret2

*&---------------------------------------------------------------------*
*&      Form  goodsmvt_create
*&---------------------------------------------------------------------*
FORM goodsmvt_create.
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'      " 상품이동 전기
    EXPORTING
      goodsmvt_header  = gw_head
      goodsmvt_code    = gt_code
    IMPORTING
      goodsmvt_headret = gt_headret
    TABLES
      goodsmvt_item    = gt_item
      return           = gt_ret2.
ENDFORM.                    " goodsmvt_create

*&---------------------------------------------------------------------*
*&      Form  goodsmvt_create_testrun
*&---------------------------------------------------------------------*
FORM goodsmvt_create_testrun.
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'      " 상품이동 전기
    EXPORTING
      goodsmvt_header  = gw_head
      goodsmvt_code    = gt_code
      testrun          = 'X'
    IMPORTING
      goodsmvt_headret = gt_headret
    TABLES
      goodsmvt_item    = gt_item
      return           = gt_ret2.
ENDFORM.                    " goodsmvt_create

*&---------------------------------------------------------------------*
*&      Form  reservation_create
*&---------------------------------------------------------------------*
FORM reservation_create.
  CALL FUNCTION 'BAPI_RESERVATION_CREATE'
    EXPORTING
      reservation_header = gw_rkpfc
    IMPORTING
      reservation        = gv_resv_no
    TABLES
      reservation_items  = gt_resbc
      return             = gt_ret.
ENDFORM.                      " reservation_create

*&---------------------------------------------------------------------*
*&      Form  reservation_delete
*&---------------------------------------------------------------------*
FORM reservation_delete.
  CALL FUNCTION 'BAPI_RESERVATION_DELETE'
    EXPORTING
      reservation = gv_resv_no
    TABLES
      return      = gt_ret2.
ENDFORM.                      " reservation_delete

*&---------------------------------------------------------------------
*&      Form  edit_error_message_all
*&---------------------------------------------------------------------
FORM edit_error_message_all  USING pv_keyfield.
  LOOP AT gt_messtab.
    CLEAR: gv_messtext.
    PERFORM message_text_build  USING gv_messtext.

    gt_errmsg-msgid    = gt_messtab-msgid.
    gt_errmsg-msgnr    = gt_messtab-msgnr.
    gt_errmsg-msgtyp   = gt_messtab-msgtyp.
    gt_errmsg-keyfield = pv_keyfield.
    gt_errmsg-message  = gv_messtext.
    APPEND gt_errmsg.
  ENDLOOP.
ENDFORM.                    " edit_error_message_all

*&---------------------------------------------------------------------*
*&      Form  BDC_FOR_SOP_MODIFY
*&---------------------------------------------------------------------*
FORM dynp_values_read.
  REFRESH: gt_dynpread.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname             = sy-cprog
      dynumb             = sy-dynnr
      request            = 'A'
      translate_to_upper = 'X'
    TABLES
      dynpfields         = gt_dynpread.
ENDFORM.                   " DYNP_VALUES_READ

*&---------------------------------------------------------------------*
*&      Form  CALL_FUNCTION_FIELD_UPDATE
*&---------------------------------------------------------------------*
FORM dynp_values_update.
  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = sy-cprog
      dynumb     = sy-dynnr
    TABLES
      dynpfields = gt_dynpupdate.
ENDFORM.                    " DYNP_VALUES_UPDATE

*&---------------------------------------------------------------------*
*&      Form  CALL_FUNCTION_LIST_BOX
*&---------------------------------------------------------------------*
FORM call_function_list_box.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = gv_listbox_name
      values = gt_listbox.
ENDFORM.                    " CALL_FUNCTION_LIST_BOX

*&---------------------------------------------------------------------*
*&      Form  CALL_FUNCTION_LOCKING_CHECK
*&---------------------------------------------------------------------*
FORM call_function_locking_check.
  CALL FUNCTION 'Z_PP_LOCKING_CHECK'
    EXPORTING
      if_werks = gw_pdstd-werks
      if_spgcd = gw_pdstd-spgcd
      if_procd = gw_pdstd-procd
      if_tcode = gw_pdstd-tcode
      if_jobid = gw_pdstd-jobid
    IMPORTING
      if_pernr = gw_pdstd-pernr
      if_erdat = gw_pdstd-erdat
      if_erzet = gw_pdstd-erzet.
ENDFORM.                    " CALL_FUNCTION_LOCKING_CHECK

*&---------------------------------------------------------------------*
*&      Form  check_spg_locking
*&---------------------------------------------------------------------*
FORM check_spg_locking  USING pv_jobid
                              pv_werks
                              pv_spgcd
                              pv_procd.
  CLEAR: gw_pdstd.

  gw_pdstd-werks = pv_werks.
  gw_pdstd-spgcd = pv_spgcd.
  gw_pdstd-procd = pv_procd.
  gw_pdstd-tcode = sy-tcode.
  gw_pdstd-jobid = pv_jobid.

  PERFORM call_function_locking_check.

  IF NOT gw_pdstd-pernr IS INITIAL.
    CONCATENATE '사용자[' gw_pdstd-pernr ']가' INTO gw_pdstd-message.
  ENDIF.
ENDFORM.                    " check_spg_locking
*&---------------------------------------------------------------------*
*& Form start_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM start_of_selection .

  SELECT SINGLE name1 INTO gv_name1 FROM t001w WHERE werks = gp_werks.

  IF gv_name1 IS INITIAL.
    MESSAGE s000 WITH '등록되지 않은 플랜트 입니다.'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'ZPP_DISPO' ID 'WERKS'  FIELD gp_werks
  ID 'DISPO'  FIELD gp_dispo.

  IF sy-subrc <> 0.
    MESSAGE s000 WITH 'MRP관리자[' gp_dispo ']의 작업권한을 확인하세요.'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  PERFORM prepare_data_for_process.

  gv_tpar1 = COND #( WHEN gp_new EQ abap_true THEN TEXT-002
                     WHEN gp_ext EQ abap_true THEN TEXT-003
                     WHEN gp_all EQ abap_true THEN TEXT-004
                     WHEN gp_seq EQ abap_true THEN TEXT-005 ).

  CALL SCREEN '0100'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM initialization .

  CLEAR: gt_data[],  gt_mapl[],  gt_save[],  gv_crlyn,
         gv_210cols, gv_220cols, gv_230cols, gv_name1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form submit_zgtppr1110
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM submit_zgtppr1110  USING ps_data LIKE LINE OF gt_data
                              pv_proc_type.
  DATA lv_verid TYPE mkal-verid.
  DATA lv_to TYPE d.

  lv_to = sy-datum - 365 * 10.

  DATA(lt_matnr) = VALUE range_t_matnr( ( sign  = 'I' option = 'EQ' low = ps_data-matnr ) ).
  DATA(lt_andat) = VALUE range_t_matnr( ( sign  = 'I' option = 'BT' low = lv_to high = sy-datum ) ).
  DATA(lv_r1)    = COND #( WHEN pv_proc_type EQ gc_proc_type-create THEN abap_true ELSE abap_false ).
  DATA(lv_r3)    = COND #( WHEN pv_proc_type EQ gc_proc_type-delete THEN abap_true ELSE abap_false ).

  PERFORM get_prod_version USING ps_data ps_data-verid.

  IF pv_proc_type EQ gc_proc_type-delete AND ps_data-verid IS INITIAL.
    DATA(lv_success) = 'N'.
  ELSE.
    TRY.
        SUBMIT zgtppr1110 WITH p_werks EQ gp_werks
                          WITH p_spgcd EQ gp_dispo+0(2)
                          WITH s_matnr IN lt_matnr
                          WITH p_r1    EQ lv_r1
                          WITH p_r2    EQ space
                          WITH p_r3    EQ lv_r3
                          WITH s_andat IN lt_andat
                          WITH p_batch EQ abap_true
                          AND RETURN.

        WAIT UP TO 1 SECONDS.

        MESSAGE s000 WITH space.

        PERFORM get_prod_version USING ps_data lv_verid.

        lv_success = SWITCH #( pv_proc_type WHEN gc_proc_type-create THEN boolc( lv_verid IS NOT INITIAL )
                                            WHEN gc_proc_type-delete THEN boolc( lv_verid IS INITIAL ) ).

        IF pv_proc_type EQ gc_proc_type-create AND lv_success EQ abap_true.
          ps_data-verid = lv_verid.
        ENDIF.

      CATCH cx_root INTO DATA(lr_root).

    ENDTRY.
  ENDIF.

  ps_data = VALUE #( BASE ps_data verid      = ps_data-verid
                                  verid_icon = COND #( WHEN lv_success EQ abap_true  THEN icon_led_green
                                                       WHEN lv_success EQ abap_false THEN icon_led_red
                                                       ELSE space )
                                  verid_ind  = pv_proc_type
                                  verid_stat = COND #( WHEN lv_success EQ abap_true  THEN gc_result-success
                                                       WHEN lv_success EQ abap_false THEN gc_result-error
                                                       ELSE space  ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form read_routing_atwrt_seq
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM read_routing_atwrt_seq .

  DATA: lv_char1 TYPE char10,
        lv_char2 TYPE char10,
        lv_atcnt TYPE i,     " 변경할 라인수
        lv_dtcnt TYPE i,    " 선택한 자료의 라인수
        lt_atwrt LIKE gt_atwrt  OCCURS 0 WITH HEADER LINE,
        lv_plnnr TYPE plas-plnnr.

  CLEAR: lv_atcnt, lv_dtcnt, lt_atwrt, lt_atwrt[], gt_comp[].

  SORT gt_atwrt BY seqno.
  SORT gt_btwrt BY seqno.
  SORT gt_ctwrt BY seqno.

  gw_temp = gw_data.

  PERFORM search_suitable_atwrt.

  IF gw_data-arbpl IS NOT INITIAL.       " 특성조합이 존재하면
    LOOP AT gt_temp  INTO gt_comp
                    WHERE matnr = gw_temp-matnr.
      APPEND gt_comp.
    ENDLOOP.

    LOOP AT gt_atwrt  INTO lt_atwrt
                     WHERE seqno = gw_data-seqno.
      APPEND lt_atwrt.
    ENDLOOP.

    DESCRIBE TABLE lt_atwrt LINES lv_atcnt.
    DESCRIBE TABLE gt_comp  LINES lv_dtcnt.

    IF lv_atcnt EQ lv_dtcnt.
      EXIT.
    ENDIF.

*&   변경하고자 하는 라우팅의 대체/소공정의 갯수가 시뮬레이션 결과의
*&   대체/소공정의 갯수와 다르면 변경을 할 수 없고 삭제 후 재생성
*& 2008.04.18
*    IF lv_atcnt <> lv_dtcnt. " AND
**        GP_WERKS  NE '1801' AND      "산특 시뮬레이션 테스트용
**       GP_SEQ IS INITIAL.
*      WRITE: lv_atcnt  TO lv_char1 NO-GROUPING LEFT-JUSTIFIED,
*             lv_dtcnt  TO lv_char2 NO-GROUPING LEFT-JUSTIFIED.
*
*      CONCATENATE '현재[' lv_char2 ']<=>변경[' lv_char1 ']가 틀리므'
*                  '로 순서추가로 작업하세요.'
*                                          INTO gt_data-message.
*      gt_data-flag = gw_temp-flag.
*
*      MODIFY gt_data TRANSPORTING flag
*                                  message
*                            WHERE matnr  = gw_temp-matnr
*                              AND plnnr  = gw_temp-plnnr
*                              AND plnal  = gw_temp-plnal.
*      EXIT.
*    ENDIF.

    LOOP AT gt_atwrt  WHERE seqno = gw_data-seqno.
      gw_data = gw_temp.

      CLEAR: gw_data-flag210, gw_data-flag220, gw_data-flag230.

      PERFORM search_suitable_atwrt_new.
      PERFORM search_suitable_btwrt.
      PERFORM search_suitable_ctwrt.

      IF gw_data-flag210 = 'GOOD'  AND
         gw_data-flag220 = 'GOOD'  AND
         gw_data-flag230 = 'GOOD'.
        gw_data-flag = 'GOOD'.
      ENDIF.

      gw_data-plnnr1 = gw_data-plnnr.
      gw_data-plnal1 = gw_data-plnal.
      gw_data-modify = 'X'.

      IF gw_data-plnal = 1  AND
         gw_data-plnfl = 0  AND
         gw_data-vornr = 10.
        gw_data-chk = 'X'.
        gw_data-zaehl = 1.
      ELSE.
        gw_data-chk = space.
        gw_data-zaehl = 2.
      ENDIF.

*& 2008,.04.18
      IF gp_seq IS NOT INITIAL.
        CLEAR lv_plnnr.

        SELECT SINGLE plnnr
          INTO lv_plnnr
          FROM plas
         WHERE plnnr = gw_data-plnnr
           AND plnal = gw_data-plnal
           AND plnfl = gw_data-plnfl.

        IF lv_plnnr IS INITIAL.
          "기존 라우팅에 없고 그룹카운터가 있을 경우만

          SELECT SINGLE plnnr
            INTO lv_plnnr
            FROM plas
           WHERE plnnr = gw_data-plnnr
             AND plnal = gw_data-plnal.

          IF lv_plnnr IS NOT INITIAL.
            gw_data-indi = '추가'.
          ENDIF.
        ENDIF.
      ENDIF.

      APPEND gw_data TO gt_data.
    ENDLOOP.

    DELETE gt_data WHERE matnr   = gw_temp-matnr
                     AND modify IS INITIAL.
  ELSE.
    gt_data-flag = gw_temp-flag.

    MODIFY gt_data TRANSPORTING flag
                          WHERE matnr  = gw_temp-matnr
                            AND plnnr  = gw_temp-plnnr
                            AND plnal  = gw_temp-plnal.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form popup_to_confirm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM popup_to_confirm  USING  pv_question pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = TEXT-t01
      text_question  = pv_question
    IMPORTING
      answer         = pv_answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATE_TIME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_date_time .

  gs_zgtpps1001 = VALUE #( crdat = sy-datum
                           crtim = sy-uzeit
                           crnam = sy-uname
                           chdat = sy-datum
                           chtim = sy-uzeit
                           chnam = sy-uname ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form insert_process_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM insert_process_log  USING  ps_data LIKE LINE OF gt_data.

  gs_zgtppt1110 = CORRESPONDING zgtppt1110( ps_data ).
  gs_zgtppt1110 = CORRESPONDING #( BASE ( gs_zgtppt1110 ) gs_zgtpps1001 ).

  TRY.
      gs_zgtppt1110-guid = cl_system_uuid=>create_uuid_x16_static( ).

    CATCH cx_uuid_error.
  ENDTRY.

  TRY.
      INSERT zgtppt1110 FROM gs_zgtppt1110.
      DATA(lv_subrc) = sy-subrc.

    CATCH cx_root.
      lv_subrc = 4.
  ENDTRY.

  IF lv_subrc IS INITIAL.
    COMMIT WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_process_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM update_process_log  USING  ps_data LIKE LINE OF gt_data.

  gs_zgtppt1110 = VALUE #( BASE gs_zgtppt1110  verid      = ps_data-verid
                                               verid_ind  = ps_data-verid_ind
                                               verid_stat = ps_data-verid_stat ).

  TRY.
      MODIFY zgtppt1110 FROM gs_zgtppt1110.
      DATA(lv_subrc) = sy-subrc.

    CATCH cx_root.
      lv_subrc = 4.
  ENDTRY.

  IF lv_subrc IS INITIAL.
    COMMIT WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_prod_version
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_prod_version  USING  ps_data LIKE LINE OF gt_data
                              pv_verid.

  CLEAR pv_verid.

  SELECT verid
    FROM mkal
   WHERE matnr EQ @ps_data-matnr
     AND werks EQ @ps_data-werks
    INTO TABLE @DATA(lt_mkal).

  pv_verid = VALUE #( lt_mkal[ 1 ]-verid OPTIONAL ).

ENDFORM.
