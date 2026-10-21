*&---------------------------------------------------------------------*
*&  Include           ZGTPPR1170F01                                    *
*&---------------------------------------------------------------------*
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

  SELECT gong_gr    gong_nm    gong_cd
    INTO TABLE lt_procd
    FROM zedt0011
   WHERE gong_cd <> space.

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
*&      Form  read_data_from_tables
*&---------------------------------------------------------------------*
FORM read_data_from_tables.
  SELECT a~matnr    a~beskz    a~sobsl
         f~maktx    e~mtart   c~andat
         d~bmeng    d~bmein    d~datuv   c~stlnr
         c~/sapmp/fix_as_j AS  fix_as_j  c~posnr
         c~stlkn
    INTO CORRESPONDING FIELDS OF TABLE gt_temp
    FROM marc AS a  INNER JOIN mara AS e
                            ON a~matnr = e~matnr
                    INNER JOIN mast AS b
                            ON a~matnr = b~matnr  AND
                               a~werks = b~werks
                    INNER JOIN stas AS g
                            ON b~stlnr = g~stlnr  AND
                               b~stlal = g~stlal
                    INNER JOIN stpo AS c
                            ON g~stlty = c~stlty  AND
                               g~stlnr = c~stlnr  AND
                               g~stlkn = c~stlkn
                    INNER JOIN stko AS d
                            ON b~stlnr = d~stlnr  AND
                               b~stlal = d~stlal
                    INNER JOIN makt AS f
                            ON a~matnr = f~matnr
   WHERE a~werks  = gp_werks
     AND a~dispo IN gr_dispo
     AND a~matnr IN gs_matnr
     AND a~lvorm  = space
     AND e~mtart IN gs_mtart
     AND e~spart IN gs_spart
     AND e~matkl IN gr_matkl
     AND e~lvorm  = space
     AND b~stlan  = gp_stlan          " 1:생산, 6:원가
     AND d~stlst IN gr_stlst
     AND f~spras  = sy-langu
     AND a~mmsta NE 'ZD'     "2026.06.26 KSW
     AND a~beskz NE 'F'.
ENDFORM.                    " read_data_from_tables

*&---------------------------------------------------------------------*
*&      Form  setting_data_for_ranges
*&---------------------------------------------------------------------*
FORM setting_data_for_ranges.
  CLEAR: gr_dispo, gr_dispo[], gr_matkl, gr_matkl[],
         gr_stlst, gr_stlst[].

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

  IF gp_new = 'X'.                " 신규이면
    gr_stlst-sign = 'E'.         " 제외
    gr_stlst-option = 'EQ'.
    gr_stlst-low = 1.            " 활성화제외
    APPEND gr_stlst.
  ELSEIF gp_ext = 'X'.            " 신규가 아니면
    gr_stlst-sign = 'I'.         " 포함
    gr_stlst-option = 'EQ'.
    gr_stlst-low = 1.            " BOM상태가 활성화 인것만
    APPEND gr_stlst.
  ENDIF.

  gv_scroll-row = 'X'.
  gv_scroll-col = 'X'.

  gw_bdcparams-dismode  = 'N'.   " 처리모드
  gw_bdcparams-updmode  = 'L'.   " 갱신세션
  gw_bdcparams-cattmode = ' '.   " CATT모드
  gw_bdcparams-defsize  = 'X'.   " 기본화면
  gw_bdcparams-racommit = 'X'.   " COMMAND 이후 지속
  gw_bdcparams-nobinpt  = 'X'.   " BI 세션
ENDFORM.                    " setting_data_for_ranges

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
ENDFORM.                    " function_get_classification

*&---------------------------------------------------------------------*
*&      Form  prepare_data_for_process
*&---------------------------------------------------------------------*
FORM prepare_data_for_process.
  IF gp_stlan <> '1'  AND
     gp_stlan <> '6'.
    MESSAGE s001 WITH '생산/원가 BOM만 가능합니다.'.
    RETURN.
  ENDIF.

  PERFORM setting_data_for_ranges.
  PERFORM read_data_from_tables.

* 1901 플랜트 구매 자재는 제외
  IF gp_werks = '1901'.
    PERFORM exclude_external.
  ENDIF.
  IF gt_temp[] IS INITIAL.
    MESSAGE s012.
    RETURN.
  ENDIF.

*  IF gp_werks eq '1901'.
*
*  PERFORM EXCLUDE_EXTERNAL.  "외부구매 제외
*
*  ENDIF.

*& 플랜트/SPG/공정에 관리하는 특성을 읽는다.
  PERFORM read_data_from_zppt0030.

  LOOP AT gt_temp.
    gt_coll-matnr = gt_temp-matnr.
    gt_coll-maktx = gt_temp-maktx.
    gt_coll-mtart = gt_temp-mtart.
    gt_coll-andat = gt_temp-andat.
    gt_coll-bmein = gt_temp-bmein.
    gt_coll-datuv = gt_temp-datuv.

    WRITE: gt_temp-bmeng  TO gt_coll-bmeng NO-GROUPING.
    gt_coll-stcnt = 1.

    IF gt_temp-fix_as_j > 0.
      gt_coll-lccnt = 1.
    ENDIF.

    COLLECT gt_coll.
  ENDLOOP.

*& 각 자재의 특성값을 읽는다.
  LOOP AT gt_coll.
    PERFORM function_get_classification  USING gt_coll-matnr.

    LOOP AT gt_atnam.
      CLEAR: gt_ausp.

      READ TABLE gt_ausp  WITH KEY atnam = gt_atnam-atnam.

      CONCATENATE 'GT_DATA-ATWRT' gt_atnam-seqno  INTO gv_atwrt.
      ASSIGN (gv_atwrt)  TO <atwrt>.
      <atwrt> = gt_ausp-atwrt.
    ENDLOOP.

    MOVE-CORRESPONDING gt_coll TO gt_data.

    APPEND gt_data.
  ENDLOOP.

  SORT gt_data  BY matnr.

  PERFORM create_search_atwrt_data.    " 생산 제조표준을 읽는다.

  CALL SCREEN '0100'.
ENDFORM.                    " prepare_data_for_process

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
     AND a~remfl  = 'X'           " 길이관련 특성항목
     AND c~spras  = sy-langu.

  SORT gt_atnam  BY seqno.

  CLEAR: gv_200cols, gv_num2, gr_atnam[].

  READ TABLE gt_temp  INDEX 1.

*& 해당 자재의 설계특성치를 읽어온다.
  PERFORM function_get_classification  USING gt_temp-matnr.

  LOOP AT gt_atnam.
    gv_num2 = gv_num2 + 1.

    IF gt_atnam-atbez IS INITIAL.
      CLEAR: gt_ausp.
      READ TABLE gt_ausp  WITH KEY atnam = gt_atnam-atnam.

      gt_atnam-atbez = gt_ausp-atbez.
    ENDIF.

    gt_atnam-seqno = gv_num2.

    MODIFY gt_atnam.

    gv_200cols = gv_200cols + 1.

*&  관리하는 특성을 Range에 넣고 나중에 데이타 읽을 조건으로 쓴다.
    gr_atnam-sign = 'I'.
    gr_atnam-option = 'EQ'.
    gr_atnam-low = gt_atnam-atnam.
    APPEND gr_atnam.
  ENDLOOP.
ENDFORM.                    " read_data_from_zppt0030

*&---------------------------------------------------------------------*
*&      Form  create_and_init_100
*&---------------------------------------------------------------------*
FORM create_and_init_100  CHANGING pt_data   LIKE gt_data[]
                                   pt_fieldcat TYPE lvc_t_fcat
                                   ps_layout   TYPE lvc_s_layo.
  DATA: lt_sort    TYPE lvc_t_sort,
        lt_exclude TYPE ui_functions.

  REFRESH: pt_fieldcat, lt_exclude, lt_sort.

  CREATE OBJECT gs_contain_100
    EXPORTING
      container_name = gc_contain_100.

  CREATE OBJECT gs_grid1
    EXPORTING
      i_parent = gs_contain_100.

*&  선택버튼을 비활성화 한다.
  ps_layout-no_rowmark = 'X'.
  ps_layout-cwidth_opt = 'X'.
  ps_layout-stylefname = 'CELLTAB'.
  ps_layout-ctab_fname = 'COLOR'.

  gs_variant-report    = sy-repid.

  PERFORM build_fieldcat_100    CHANGING pt_fieldcat.
  PERFORM set_cell_attributes_100.
  PERFORM exclude_tb_functions  CHANGING lt_exclude.

  CALL METHOD gs_grid1->set_table_for_first_display
    EXPORTING
      is_layout            = ps_layout
      it_toolbar_excluding = lt_exclude
      is_variant           = gs_variant
      i_save               = 'A'
    CHANGING
      it_fieldcatalog      = pt_fieldcat
      it_sort              = lt_sort
      it_outtab            = pt_data.

  CALL METHOD gs_grid1->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  CREATE OBJECT gs_event_receiver.

  SET HANDLER: gs_event_receiver->handle_data_changed FOR gs_grid1,
               gs_event_receiver->handle_toolbar1     FOR gs_grid1,
               gs_event_receiver->handle_user_command FOR gs_grid1.

  CALL METHOD gs_grid1->set_toolbar_interactive.
ENDFORM.                               " CREATE_AND_INIT_100

*&---------------------------------------------------------------------*
*&      Form  create_and_init_200
*&---------------------------------------------------------------------*
FORM create_and_init_200  CHANGING pt_tail     LIKE gt_tail[]
                                   pt_fieldcat TYPE lvc_t_fcat
                                   ps_layout   TYPE lvc_s_layo.
  DATA: lt_sort    TYPE lvc_t_sort,
        lt_exclude TYPE ui_functions.

  REFRESH: pt_fieldcat, lt_exclude, lt_sort.

  CREATE OBJECT gs_contain_200
    EXPORTING
      container_name = gc_contain_200.

  CREATE OBJECT gs_grid2
    EXPORTING
      i_parent = gs_contain_200.

*&  선택버튼을 비활성화 한다.
  ps_layout-no_rowmark = 'X'.
  ps_layout-cwidth_opt = 'X'.
  ps_layout-stylefname = 'CELLTAB'.
  ps_layout-ctab_fname = 'COLOR'.

  gs_variant-report    = sy-repid.

  PERFORM build_fieldcat_200    CHANGING pt_fieldcat.
  PERFORM set_cell_attributes_200.
  PERFORM exclude_tb_functions  CHANGING lt_exclude.

  CALL METHOD gs_grid2->set_table_for_first_display
    EXPORTING
      is_layout            = ps_layout
      it_toolbar_excluding = lt_exclude
      is_variant           = gs_variant
      i_save               = 'A'
    CHANGING
      it_fieldcatalog      = pt_fieldcat
      it_sort              = lt_sort
      it_outtab            = pt_tail.

  CALL METHOD gs_grid2->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  CREATE OBJECT gs_event_receiver.

  SET HANDLER: gs_event_receiver->handle_data_changed FOR gs_grid2,
               gs_event_receiver->handle_toolbar2     FOR gs_grid2,
               gs_event_receiver->handle_user_command FOR gs_grid2.

  CALL METHOD gs_grid2->set_toolbar_interactive.
ENDFORM.                               " CREATE_AND_INIT_200

*&---------------------------------------------------------------------*
*&      Form  build_fieldcat_100
*&---------------------------------------------------------------------*
FORM build_fieldcat_100  CHANGING pt_fieldcat TYPE lvc_t_fcat.
  DATA: lv_200   TYPE numc2,
        ls_fcat  LIKE lvc_s_fcat,
        lv_atwrt TYPE zppt0031-atwrt.

  CLEAR: ls_fcat, lv_200.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZPPS011'
    CHANGING
      ct_fieldcat      = pt_fieldcat.

  LOOP AT pt_fieldcat INTO ls_fcat.
    CASE ls_fcat-fieldname(5).
      WHEN 'CHK'.
        ls_fcat-key = 'X'.
        ls_fcat-checkbox = 'X'.
        ls_fcat-edit = 'X'.
        ls_fcat-coltext = '선택'.
        ls_fcat-outputlen = 4.
      WHEN 'MTART'.
        ls_fcat-key = 'X'.
      WHEN 'MATNR'.
        ls_fcat-key = 'X'.
      WHEN 'ATWRT'.
        IF ls_fcat-fieldname+5(2) > gv_200cols.
          DELETE pt_fieldcat  INDEX sy-tabix.
          CONTINUE.
        ENDIF.

        lv_200 = lv_200 + 1.
        ls_fcat-emphasize = 'C400'.

        READ TABLE gt_atnam  WITH KEY seqno = lv_200.

        CONCATENATE: '【' lv_200 '】' gt_atnam-atbez  INTO lv_atwrt.
        ls_fcat-coltext = lv_atwrt.
      WHEN 'BMENG'.
        ls_fcat-coltext = '기준수량'.
      WHEN 'BMEIN'.
        ls_fcat-coltext = '단위'.
      WHEN 'STCNT'.
        ls_fcat-coltext = '컨포넌트 수'.
      WHEN 'LCCNT'.
        ls_fcat-coltext = '컨포넌트 여장 등록수'.
    ENDCASE.

    MODIFY pt_fieldcat FROM ls_fcat.
  ENDLOOP.
ENDFORM.                    " build_fieldcat_100

*&---------------------------------------------------------------------*
*&      Form  build_fieldcat_200
*&---------------------------------------------------------------------*
FORM build_fieldcat_200  CHANGING pt_fieldcat TYPE lvc_t_fcat.
  DATA: lv_210  TYPE numc2,
        lv_220  TYPE numc2,
        lv_230  TYPE numc2,
        ls_fcat LIKE lvc_s_fcat.

  CLEAR: ls_fcat, lv_210, lv_220, lv_230.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZPPS012'
    CHANGING
      ct_fieldcat      = pt_fieldcat.

  LOOP AT pt_fieldcat INTO ls_fcat.
    CASE ls_fcat-fieldname(5).
      WHEN 'CHK'.
        ls_fcat-key = 'X'.
        ls_fcat-checkbox = 'X'.
        ls_fcat-edit = 'X'.
        ls_fcat-coltext = '선택'.
        ls_fcat-outputlen = 4.
      WHEN 'POSNR'.
        ls_fcat-key = 'X'.
        ls_fcat-emphasize = 'C100'.
      WHEN 'POSTP'.
        ls_fcat-key = 'X'.
        ls_fcat-coltext = '범주'.
        ls_fcat-emphasize = 'C100'.
      WHEN 'IDNRK'.
        ls_fcat-key = 'X'.
        ls_fcat-coltext = '구성부품'.
        ls_fcat-emphasize = 'C100'.
      WHEN 'MAKTX'.
        ls_fcat-coltext = '구성부품 내역'.
      WHEN 'MATNR'.
        ls_fcat-coltext = '자재번호'.
        ls_fcat-emphasize = 'C410'.
      WHEN 'MENGE'.
        ls_fcat-coltext = '수량'.
      WHEN 'MEINS'.
        ls_fcat-coltext = '단위'.
      WHEN 'CALCM'.
        ls_fcat-coltext = '길이방식'.
      WHEN 'FHANK'.
        ls_fcat-coltext = '최대생산 길이'.
      WHEN 'WKSRT'.
        ls_fcat-coltext = '작업여장(시작)'.
      WHEN 'WKMGN'.
        ls_fcat-coltext = '작업여장'.
      WHEN 'WKEND'.
        ls_fcat-coltext = '작업여장(종료)'.
      WHEN 'AUSCH'.
        ls_fcat-coltext = '컨포넌트 스크랩율'.
      WHEN 'DPCBT'.
        ls_fcat-coltext = 'Batch여부'.
      WHEN 'MESSA'.
        ls_fcat-coltext = '처리결과'.

*// Modified by ZGODEV06 on 2026-01-21 {
*     WHEN 'ESCRP' OR 'BEIKZ'.
*       DELETE pt_fieldcat  INDEX sy-tabix.
*       CONTINUE.

      WHEN 'BEIKZ'.
        ls_fcat-coltext = '자재공급지시자'.
        ls_fcat-just    = 'C'.
        ls_fcat-edit    = 'X'.
        ls_fcat-ref_table = 'RC29P'.
        ls_fcat-ref_field = 'BEIKZ'.

      WHEN 'ESCRP'.
        DELETE pt_fieldcat  INDEX sy-tabix.
        CONTINUE.
*// }
    ENDCASE.

    MODIFY pt_fieldcat FROM ls_fcat.
  ENDLOOP.
ENDFORM.                    " build_fieldcat_100

*&---------------------------------------------------------------------*
*&      Form  set_cell_attributes_100
*&---------------------------------------------------------------------*
FORM set_cell_attributes_100.
  DATA: lv_tabix           TYPE i.

  LOOP AT gt_data.
    CLEAR: gt_celltab[], gt_color[].

    lv_tabix = sy-tabix.

    PERFORM initial_color  CHANGING gt_color.
*    PERFORM initial_style  CHANGING gt_celltab.

*    CLEAR: gt_data-celltab[], gt_data-color[].
*
*    INSERT LINES OF gt_celltab INTO TABLE gt_data-celltab.
*    INSERT LINES OF gt_color   INTO TABLE gt_data-color.
*
*    MODIFY gt_data  INDEX lv_tabix.
  ENDLOOP.
ENDFORM.                    " set_cell_attributes_100

*&---------------------------------------------------------------------*
*&      Form  set_cell_attributes_200
*&---------------------------------------------------------------------*
FORM set_cell_attributes_200.
  DATA: lv_tabix           TYPE i.

  LOOP AT gt_tail.
    CLEAR: gt_celltab[], gt_color[].

    lv_tabix = sy-tabix.

    PERFORM initial_color  CHANGING gt_color.
*    PERFORM initial_style  CHANGING gt_celltab.

    CLEAR: gt_tail-celltab[], gt_tail-color[].

*    INSERT LINES OF gt_celltab INTO TABLE gt_tail-celltab.
    INSERT LINES OF gt_color   INTO TABLE gt_tail-color.

    MODIFY gt_tail  INDEX lv_tabix.
  ENDLOOP.
ENDFORM.                    " set_cell_attributes_200

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

  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND ls_exclude TO pt_exclude.

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
*&      Form  initial_style
*&---------------------------------------------------------------------*
FORM initial_style  CHANGING pt_celltab TYPE lvc_t_styl.
  DATA: lv_tabix   TYPE i,
        ls_celltab TYPE lvc_s_styl.

  ls_celltab-fieldname = 'CHK'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE pt_celltab.
ENDFORM.                    " initial_style

*&---------------------------------------------------------------------*
*&      Form  initial_color
*&---------------------------------------------------------------------*
FORM initial_color  CHANGING pt_color TYPE lvc_t_scol.
  DATA: lv_tabix TYPE i,
        ls_color TYPE lvc_s_scol.

  IF gt_tail-dpcbt = space.
    ls_color-color-int = 0.
  ELSE.
    ls_color-color-int = 1.
  ENDIF.

  ls_color-fname = 'IDNRK'.
  ls_color-color-col = 2.

  INSERT ls_color  INTO TABLE pt_color.

  IF gt_tail-flag <> space.
    IF gt_tail-flag = 'ERROR'.
      ls_color-color-col = 6.
    ELSEIF gt_tail-flag = 'GOOD'.
      IF gt_tail-message IS INITIAL.
        ls_color-color-col = 1.
      ELSE.
        ls_color-color-col = 3.
      ENDIF.
    ELSE.
      ls_color-color-col = 5.
    ENDIF.

    ls_color-fname = 'POSNR'.
    ls_color-color-int = 1.

    INSERT ls_color  INTO TABLE pt_color.
  ENDIF.
ENDFORM.                    " initial_color

*&---------------------------------------------------------------------*
*&      Form  read_data_for_detail
*&---------------------------------------------------------------------*
FORM read_data_for_detail.

  CLEAR: gt_tail[].

  LOOP AT gt_data  WHERE chk = 'X'.
    PERFORM read_data_from_bom.
  ENDLOOP.

*// Modified by ZGODEV06 on 2026-05-28 {
  PERFORM adjust_detail.
*// }

  PERFORM read_stlkz_from_stpo.          " 구성부품 포함여부

ENDFORM.                    " read_data_for_detail

*&---------------------------------------------------------------------*
*&      Form  read_data_from_bom
*&---------------------------------------------------------------------*
FORM read_data_from_bom.
  DATA: lw_save                  LIKE gt_save.

  gt_save[] = gt_temp[].

  DELETE gt_save  WHERE matnr <> gt_data-matnr.

  IF gp_stlan = '1'.                          "생산일경우

    LOOP AT gt_save  INTO lw_save.
      SELECT a~posnr    a~postp    a~idnrk    p~matnr
             d~maktx    a~menge    a~meins    a~datuv
             a~/sapmp/fix_as_j  AS wkmgn      b~dpcbt
             a~/sapmp/max_fertl AS fhank      b~matkl
             a~/sapmp/fix_as_e  AS wksrt      b~spart
             a~/sapmp/fix_as_l  AS wkend      c~dispo
             a~/sapmp/met_lrch  AS calcm      h~dispo AS dispo1
             a~ausch    a~beikz    e~scrap    p~stlal
             a~lgort
        APPENDING CORRESPONDING FIELDS OF TABLE gt_tail
        FROM mast AS p  INNER JOIN stas AS g
                                ON p~stlnr = g~stlnr  AND
                                   p~stlal = g~stlal
                        INNER JOIN stpo AS a
                                ON g~stlty = a~stlty  AND
                                   g~stlnr = a~stlnr  AND
                                   g~stlkn = a~stlkn
                        INNER JOIN mara AS b
                                ON a~idnrk = b~matnr
                        INNER JOIN marc AS c
                                ON a~idnrk = c~matnr  AND
                                   p~werks = c~werks
                        INNER JOIN marc AS h
                                ON p~matnr = h~matnr  AND
                                   p~werks = h~werks
                        INNER JOIN makt AS d
                                ON a~idnrk = d~matnr
                         LEFT JOIN zppt0042 AS e
                                ON e~werks = gp_werks  AND
                                   e~spgcd = gv_spgcd  AND
                                   e~procd = gp_procd  AND
                                   a~idnrk = e~matnr
       WHERE p~matnr  = lw_save-matnr
         AND a~stlkn  = lw_save-stlkn
         AND a~posnr  = lw_save-posnr
         AND b~lvorm  = space
         AND c~lvorm  = space
         AND h~lvorm  = space
         AND p~werks  = gp_werks
         AND p~stlan  = gp_stlan
         AND g~stlty  = 'M'
         AND d~spras  = sy-langu.
    ENDLOOP.

  ELSEIF gp_stlan = '6'.                                "원가일경우

    LOOP AT gt_save  INTO lw_save.

      SELECT a~posnr    a~postp    a~idnrk    p~matnr
            d~maktx    a~menge    a~meins    a~datuv
            a~/sapmp/fix_as_j  AS wkmgn      b~dpcbt
            a~/sapmp/max_fertl AS fhank      b~matkl
            a~/sapmp/fix_as_e  AS wksrt      b~spart
            a~/sapmp/fix_as_l  AS wkend      c~dispo
            a~/sapmp/met_lrch  AS calcm      h~dispo AS dispo1
            a~ausch    a~beikz    e~scrap2 AS scrap
            p~stlal    a~lgort
       APPENDING CORRESPONDING FIELDS OF TABLE gt_tail
       FROM mast AS p  INNER JOIN stas AS g
                               ON p~stlnr = g~stlnr  AND
                                  p~stlal = g~stlal
                       INNER JOIN stpo AS a
                               ON g~stlty = a~stlty  AND
                                  g~stlnr = a~stlnr  AND
                                  g~stlkn = a~stlkn
                       INNER JOIN mara AS b
                               ON a~idnrk = b~matnr
                       INNER JOIN marc AS c
                               ON a~idnrk = c~matnr  AND
                                  p~werks = c~werks
                       INNER JOIN marc AS h
                               ON p~matnr = h~matnr  AND
                                  p~werks = h~werks
                       INNER JOIN makt AS d
                               ON a~idnrk = d~matnr
                        LEFT JOIN zppt0042 AS e
                               ON e~werks = gp_werks  AND
                                  e~spgcd = gv_spgcd  AND
                                  e~procd = gp_procd  AND
                                  a~idnrk = e~matnr
      WHERE p~matnr  = lw_save-matnr
        AND a~stlkn  = lw_save-stlkn
        AND a~posnr  = lw_save-posnr
        AND b~lvorm  = space
        AND c~lvorm  = space
        AND h~lvorm  = space
        AND p~werks  = gp_werks
        AND p~stlan  = gp_stlan
        AND g~stlty  = 'M'
        AND d~spras  = sy-langu.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " read_data_from_bom

*&---------------------------------------------------------------------*
*&      Form  simulation_bom_scrap
*&---------------------------------------------------------------------*
FORM simulation_bom_scrap.

*// Modified by ZGODEV06 on 2026-05-28 {
  DATA lv_answer TYPE c.

  gs_grid2->check_changed_data( IMPORTING e_valid = DATA(lv_valid) ).

  IF lv_valid NE abap_true.
    RETURN.
  ENDIF.
*// }

  READ TABLE gt_tail  WITH KEY chk  = 'X'
                               flag = space.
  IF sy-subrc <> 0.
    MESSAGE s001 WITH '시뮬레이션할 자료가 없습니다.'.
    RETURN.
  ENDIF.

  LOOP AT gt_tail  INTO gw_tail
                  WHERE chk = 'X'
                    AND flag = space.
    gv_tabix = sy-tabix.
    gw_tail-flag = 'ERROR'.

    PERFORM search_suitable_atwrt.

    MODIFY gt_tail FROM gw_tail  INDEX gv_tabix.
  ENDLOOP.
ENDFORM.                    " simulation_bom_scrap

*&---------------------------------------------------------------------*
*&      Form  search_suitable_atwrt
*&---------------------------------------------------------------------*
FORM search_suitable_atwrt.
  DATA: lv_rate     TYPE p DECIMALS 2,
        lv_flag     TYPE char6,
        lv_char     TYPE char30,
        lv_char1    TYPE char30,
        lv_char2    TYPE char30,
        lv_atwrt    TYPE zdec16_6,
        lv_value    TYPE zdec16_6,
        lv_chratwrt TYPE char30,
        lv_valatwrt TYPE char30.

  RANGES: lr_atwrt           FOR zppt0034-atwrt.

  READ TABLE gt_data  WITH KEY matnr = gw_tail-matnr.

  LOOP AT gt_atwrt.
    CLEAR: gv_num2, lv_flag.

    DO gv_200cols TIMES.
      gv_num2 = gv_num2 + 1.

      CONCATENATE: 'GT_ATWRT-ATWRT' gv_num2  INTO gv_atwrt,
                   'GT_ATWRT-SNGLE' gv_num2  INTO gv_sngle,
                   'GT_DATA-ATWRT'  gv_num2  INTO gv_value.

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
      ELSEIF <sngle> = '1'.         " 단일값
        IF <atwrt> <> <value>.
          IF <atwrt> <> '~'.
            lv_flag = 'ERROR'.
            EXIT.
          ENDIF.
        ENDIF.
      ELSEIF <sngle> = '3'.    " 포함
        CLEAR: lv_char, lv_char1, lv_char2, lr_atwrt[].

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

        IF NOT <value> IN lr_atwrt.
          IF <atwrt> <> '~'.
            lv_flag = 'ERROR'.
            EXIT.
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
    ENDDO.

    IF lv_flag = space.
      gw_tail-calcm = gt_atwrt-calcm.
      gw_tail-fhank = gt_atwrt-fhank.
      gw_tail-wksrt = gt_atwrt-wksrt.
      gw_tail-wkmgn = gt_atwrt-wkmgn.
      gw_tail-wkend = gt_atwrt-wkend.
      gw_tail-qmmgn = gt_atwrt-qmmgn.
      gw_tail-seqno = gt_atwrt-seqno.
      gw_tail-flag  = 'GOOD'.

*      IF gw_tail-fhank = 0.
*        gw_tail-fhank = 1.
*      ENDIF.

*&     배치관리 여부
      IF gp_stlan = '1'.                  " 생산용 BOM
        IF gw_tail-dpcbt = space.        " Single Unit Btc가 아니면
          IF gw_tail-beikz = 'V'.       " 업체가 자재구매
            gw_tail-ausch = 0.
          ELSE.
            gw_tail-ausch = gw_tail-scrap.
          ENDIF.
        ELSE.                            " Sgl Unit Btc면
          IF gw_tail-calcm = space.
            gw_tail-ausch = gw_tail-scrap.
          ELSE.

*& 2007.09.11
*& [요청번호] C20070906_31315
*& 1401/OC 광케이블인 경우 길이계산방식이 있고 S/U 배치이더라도
*& 스크랩율 반영
            IF ( gp_werks EQ '1401' OR gp_werks EQ '1301' ) AND
               gr_dispo-low+0(2) EQ 'OC'.
              gw_tail-ausch = gw_tail-scrap.
            ELSE.
              gw_tail-ausch = 0.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.                             " 계획용 BOM
        gw_tail-ausch = gw_tail-scrap.
      ENDIF.

      RETURN.
    ENDIF.

*&     배치관리 여부
*       IF gp_stlan = '1'.                  " 생산용 BOM
*          IF gw_tail-dpcbt = space.
*             IF gw_tail-beikz = 'V'.       " 업체가 자재구매
*                gw_tail-ausch = 0.
*             ELSE.
*                IF gw_tail-calcm = '2'  OR
*                   gw_tail-calcm = space.
*                   lv_rate = ( gw_tail-qmmgn + gw_tail-wkmgn )
*                                             / gw_tail-fhank * 100.
*                   gw_tail-ausch = lv_rate + gw_tail-scrap.
*                ELSEIF gw_tail-calcm = 'Z1'.
*                    lv_rate = ( gw_tail-qmmgn + gw_tail-wksrt +
*                                gw_tail-wkend + ( gw_tail-wkmgn * 2 ) )
*                              / gw_tail-fhank * 100.
*                    gw_tail-ausch = lv_rate + gw_tail-scrap.
*                ENDIF.
*             ENDIF.
*          ELSE.
*             gw_tail-ausch = gw_tail-scrap.
*          ENDIF.
*       ELSE.                             " 계획용 BOM
*          IF gw_tail-calcm = '2'  OR
*             gw_tail-calcm = space.
*             lv_rate = ( gw_tail-qmmgn + gw_tail-wkmgn )
*                                       / gw_tail-fhank * 100.
*             gw_tail-ausch = lv_rate + gw_tail-scrap.
*          ELSEIF gw_tail-calcm = 'Z1'.
*lv_rate = ( gw_tail-qmmgn + gw_tail-wksrt + gw_tail-wkend +
*                       ( gw_tail-wkmgn * 2 ) ) / gw_tail-fhank * 100.
*             gw_tail-ausch = lv_rate + gw_tail-scrap.
*          ENDIF.
*       ENDIF.
*
*       RETURN.
*    ENDIF.
  ENDLOOP.
ENDFORM.                    " search_suitable_atwrt

*&---------------------------------------------------------------------*
*&      Form  create_search_atwrt_data
*&---------------------------------------------------------------------*
FORM create_search_atwrt_data.
  CLEAR: gt_0034[], gt_0036[].

  PERFORM read_data_from_zppt0034.
  PERFORM read_data_from_zppt0036.

  SORT: gt_0034  BY seqno index,
        gt_0036  BY seqno.

  PERFORM edit_data_atwrt_200.

*& 화면에 조회될 내용으로 정렬한다.
  SORT gt_atwrt  BY sort01 sort02 sort03 sort04 sort05 sort06.

ENDFORM.                    " create_search_atwrt_data

*&---------------------------------------------------------------------*
*&      Form  edit_data_atwrt_200
*&---------------------------------------------------------------------*
FORM edit_data_atwrt_200.
  DATA: lv_seqno    TYPE zppt0034-seqno,
        lv_atwrt    TYPE zdec16_6,
        lv_chratwrt TYPE char30.

  CLEAR: gt_atnam, lv_seqno.

  LOOP AT gt_atnam.
    gt_0034-index = gt_atnam-seqno.
    gt_0034-sngle = gt_atnam-sngle.
    gt_0034-multi = gt_atnam-multi.
    gt_0034-inclu = gt_atnam-inclu.
    gt_0034-range = gt_atnam-range.

    MODIFY gt_0034  TRANSPORTING index
                                 sngle
                                 multi
                                 inclu
                                 range
                           WHERE atnam  = gt_atnam-atnam.
  ENDLOOP.

  READ TABLE gt_0034  INDEX 1.

  lv_seqno = gt_0034-seqno.

  LOOP AT gt_0034  INTO gw_0034.
    IF gw_0034-seqno <> lv_seqno.
      READ TABLE gt_0036  WITH KEY seqno = gt_atwrt-seqno
                                  BINARY SEARCH.

      IF sy-subrc = 0.
        MOVE-CORRESPONDING gt_0036 TO gt_atwrt.
      ENDIF.

      APPEND gt_atwrt.

      CLEAR: gt_atwrt.
      lv_seqno = gw_0034-seqno.
    ENDIF.

    gt_atwrt-seqno = gw_0034-seqno.

    CONCATENATE: 'GT_ATWRT-SORT'  gw_0034-index  INTO gv_sort,
                 'GT_ATWRT-ATWRT' gw_0034-index  INTO gv_atwrt,
                 'GT_ATWRT-SNGLE' gw_0034-index  INTO gv_sngle.

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
    IF <sngle>  = '2'  AND             " 범위값이면서 전체 '~'가 아니면
       <atwrt> <> '~'.

      CALL FUNCTION 'Z_PP_SPLIT_NUM_CHAR'
        EXPORTING
*-> CCM 2023.04.12 오바다 - CHAR30 사용
          if_source = CONV char30( gw_0034-atwrt )
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

  READ TABLE gt_0036  WITH KEY seqno = gt_atwrt-seqno
                              BINARY SEARCH.
  IF sy-subrc = 0.
    MOVE-CORRESPONDING gt_0036 TO gt_atwrt.
  ENDIF.

  APPEND gt_atwrt.
ENDFORM.                    " edit_data_atwrt_200

*&---------------------------------------------------------------------*
*&      Form  read_data_from_zppt0034
*&---------------------------------------------------------------------*
FORM read_data_from_zppt0034.
  SELECT a~atnam    a~seqno    a~atwrt    b~seqno AS index
    INTO TABLE gt_0034
    FROM zppt0034 AS a  INNER JOIN zppt0030 AS b
                                ON a~werks = b~werks  AND
                                   a~spgcd = b~spgcd  AND
                                   a~procd = b~procd  AND
                                   a~atnam = b~atnam
   WHERE a~werks  = gp_werks
     AND a~procd  = gp_procd
     AND a~spgcd  = gv_spgcd
     AND a~atnam IN gr_atnam.
ENDFORM.                    " read_data_from_zppt0034

*&---------------------------------------------------------------------*
*&      Form  read_data_from_zppt0036
*&---------------------------------------------------------------------*
FORM read_data_from_zppt0036.
  SELECT seqno    calcm    fhank    wksrt    wkmgn
         wkend    qmmgn
    INTO TABLE gt_0036
    FROM zppt0036
   WHERE werks  = gp_werks
     AND procd  = gp_procd
     AND spgcd  = gv_spgcd.
ENDFORM.                    " read_data_from_zppt0035

*&---------------------------------------------------------------------*
*&      Form  read_stlkz_from_stpo
*&---------------------------------------------------------------------*
FORM read_stlkz_from_stpo.
  DATA: lv_idnrk              TYPE stpo-idnrk.

  LOOP AT gt_tail  INTO gw_tail.
    SELECT SINGLE idnrk
      INTO lv_idnrk
      FROM mast AS a  INNER JOIN stpo AS b
                              ON a~stlnr = b~stlnr
     WHERE a~matnr  = gw_tail-idnrk
       AND a~werks  = gp_werks
       AND a~stlan  = gp_stlan
       AND b~stlty  = 'M'
       AND b~lkenz  = space.

    IF sy-subrc = 0.
      gw_tail-stlkz = 'X'.
    ENDIF.

    IF gw_tail-lgort IS INITIAL.
      IF gw_tail-spart = '90' OR            " 제품군 '90' => 공통
         gw_tail-spart = '95'.
        gw_tail-dispo1+2(1) = 'R'.

        SELECT SINGLE lgort
          INTO gw_tail-lgort
          FROM zppt0057
         WHERE werks  = gp_werks
           AND dispo  = gw_tail-dispo1.
      ELSEIF gp_werks = '1401'  AND
             gw_tail-matkl+4(3) = 'HPT'.
        gw_tail-lgort = '2241'.
      ELSE.
*-. 2006/01/16 by BTY
        IF gp_werks = '1305'  AND
           (  gw_tail-dispo1  = 'DWH' OR
              gw_tail-dispo1  = 'DWF' ).
          gw_tail-lgort  ='2240'.
        ELSE.
          SELECT SINGLE lgort
            INTO gw_tail-lgort
            FROM zppt0057
           WHERE werks  = gp_werks
             AND dispo  = gw_tail-dispo
             AND spart  = gw_tail-spart.

          IF sy-subrc <> 0.
            SELECT SINGLE lgort
              INTO gw_tail-lgort
              FROM zppt0057
             WHERE werks  = gp_werks
               AND dispo  = gw_tail-dispo.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      gw_tail-lgflg = 'X'.        " 저장위치가 등록된 것
    ENDIF.

    IF gw_tail-scrap = 0.

      IF gp_stlan = '1'.           "생산용

        SELECT SINGLE scrap
          INTO gw_tail-scrap
          FROM zppt0042
         WHERE werks  = gp_werks
           AND spgcd  = gp_dispo(2)
           AND procd  = gp_procd
           AND matkl  = gw_tail-matkl.

      ELSEIF gp_stlan = '6'.       "원가용

        SELECT SINGLE scrap2
          INTO gw_tail-scrap
          FROM zppt0042
         WHERE werks  = gp_werks
           AND spgcd  = gp_dispo(2)
           AND procd  = gp_procd
           AND matkl  = gw_tail-matkl.

      ENDIF.
    ENDIF.

    MODIFY gt_tail FROM gw_tail  INDEX sy-tabix.
  ENDLOOP.
ENDFORM.                    " read_stlkz_from_stpo
*&---------------------------------------------------------------------*
*&      Form  CHANGE_PROD_VERSION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_prod_version USING pv_message.

  DATA : BEGIN OF lt_verid OCCURS 0,
           verid  TYPE mkal-verid,      "생산버젼
           stlal  TYPE mkal-stlal,      "BOM번호
           prfg_f TYPE mkal-prfg_s,     "생산버젼 점검결과
           adatu  TYPE mkal-adatu,      "생산버젼 효력 시작일
         END OF lt_verid.

  REFRESH: gt_bdcdata, gt_messtab.

  CLEAR : lt_verid, lt_verid[], gt_bdcdata, gt_messtab.

*& BOM 활성화 시키는 자재에 대한 기존 생산버젼이 있는지 확인
  SELECT verid stlal adatu prfg_f
    INTO CORRESPONDING FIELDS OF TABLE lt_verid
    FROM mkal
   WHERE werks = gp_werks
     AND matnr = gt_tail-matnr
     AND stlan = gp_stlan
     AND mksp  = space.          "생산버젼이 잠기지 않은경우만


  IF gp_stlan EQ '1'.      "생산일 경우 1xxx만

    DELETE lt_verid WHERE verid+0(1) NE '1'.

  ELSEIF gp_stlan EQ '6'.  "원가일 일경우 3xxx만

    DELETE lt_verid WHERE verid+0(1) NE '3'.

  ENDIF.

  SORT lt_verid BY verid DESCENDING.
  "생산버젼 번호가 가장 큰 경우에 적용

  IF lt_verid[] IS NOT INITIAL.

    READ TABLE lt_verid INDEX 1.

    IF lt_verid-stlal NE gt_tail-stlal OR
    "최신 생산버젼의 대체 BOM이 다른 경우에만 변경
       lt_verid-prfg_f NE '1'.
      "생산버젼이 정상 점검이 아닐 경우
      PERFORM bdc_dynpro      USING 'SAPLCMFV' '1000'.

      PERFORM bdc_field       USING: 'MKAL-WERKS'
                                     gp_werks,
                                     'MKAL-MATNR'
                                     gt_tail-matnr,
                                     'BDC_OKCODE'
                                     '=ESEL'.

      PERFORM bdc_dynpro      USING 'SAPLCMFV' '1001'.
      PERFORM bdc_field       USING:'RANG_MAT-LOW'
                                     gt_tail-matnr,
                                     'RANG_VER-LOW'
                                     lt_verid-verid,
                                     'RANG_SAN-LOW'
                                     gp_stlan,
                                     'BDC_OKCODE'
                                     '=CRET'.

      PERFORM bdc_dynpro      USING 'SAPLCMFV' '1000'.
      PERFORM bdc_field       USING: 'MKAL_EXPAND-ADATU(01)'
                                     sy-datum,
                                     'MKAL_EXPAND-MARK(01)'
                                     'X',
                                     'MKAL_EXPAND-STLAL(01)'
                                     gt_tail-stlal,
                                     'BDC_OKCODE'
                                     '=PRFG'.

      PERFORM bdc_dynpro      USING 'SAPMSSY0' '0120'.
      PERFORM bdc_field       USING:'BDC_OKCODE'
                                     '=BACK'.

      PERFORM bdc_dynpro      USING 'SAPLCMFV' '1000'.
      PERFORM bdc_field       USING:'BDC_OKCODE'
                                     '=SAVE'.

      PERFORM bdc_transaction USING 'C223'.

*&  처리결과를 읽는다.
      PERFORM edit_error_message  USING pv_message.

*& 생산버젼 점검시 오류 발생건 확인
      IF pv_message IS INITIAL.

        SELECT SINGLE *
          FROM mkal
         WHERE werks = gp_werks
           AND matnr = gt_tail-matnr
           AND stlan = gp_stlan
           AND verid = lt_verid-verid
           AND mksp  = space
           AND prfg_f = '1'.

        IF sy-subrc NE 0.
          pv_message = '생산버젼 변경시 오류 발생'.
        ENDIF.
      ENDIF.
    ENDIF.

  ELSE.
*    pv_message = '대체 BOM 적용할 생산버젼이 없습니다.'.
  ENDIF.

ENDFORM.                    " CHANGE_PROD_VERSION
*&---------------------------------------------------------------------*
*&      Form  MMSC_EXTENTION_LGORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_TAIL_MATNR  text
*      -->P_GT_TAIL_LGORT  text
*      -->P_GT_TAIL_FLAG  text
*      -->P_GT_TAIL_MESSAGE  text
*----------------------------------------------------------------------*
FORM mmsc_extention_lgort  USING    p_matnr
                                    p_lgort
                                    p_flag.

  DATA return        LIKE bapiret2.
  DATA headdata      LIKE bapimathead.
  DATA storagedata   LIKE bapi_mard.
  DATA storagedatax  LIKE bapi_mardx.

  CLEAR: headdata, storagedata, storagedatax.

  headdata-material       =  p_matnr.
  headdata-mrp_view       = 'X'.

  storagedata-plant       = gp_werks.
  storagedata-stge_loc    = p_lgort.

  storagedatax-plant      = gp_werks.
  storagedatax-stge_loc   = p_lgort.


  CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
    EXPORTING
      headdata             = headdata
      storagelocationdata  = storagedata
      storagelocationdatax = storagedatax
    IMPORTING
      return               = return.

  IF return-type = 'E'.
    ROLLBACK WORK.

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    p_flag = 'E'.
  ELSE.
    COMMIT WORK.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

  ENDIF.

ENDFORM.                    " MMSC_EXTENTION_LGORT
*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_EXTERNAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM exclude_external .
  DELETE gt_temp WHERE beskz = 'F'
                   AND sobsl = ' '.

  DELETE gt_temp WHERE beskz = 'F'
                   AND sobsl <> '30'.
ENDFORM.                    " EXCLUDE_EXTERNAL
*&---------------------------------------------------------------------*
*& Form user_command_fc01
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM user_command_fc01 .

  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      action                       = 'S'
      view_name                    = 'ZGTPPV1170'
    EXCEPTIONS
      client_reference             = 1
      foreign_lock                 = 2
      invalid_action               = 3
      no_clientindependent_auth    = 4
      no_database_function         = 5
      no_editor_function           = 6
      no_show_auth                 = 7
      no_tvdir_entry               = 8
      no_upd_auth                  = 9
      only_show_allowed            = 10
      system_failure               = 11
      unknown_field_in_dba_sellist = 12
      view_not_found               = 13
      maintenance_prohibited       = 14
      OTHERS                       = 15.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form adjust_detail
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM adjust_detail .

  DATA(lt_tail) = gt_tail[].

  SELECT DISTINCT mara~matnr, mara~mtart, zt02~matnr AS zmat
    FROM @lt_tail AS zt01
    JOIN mara
      ON zt01~idnrk EQ mara~matnr
    LEFT JOIN zgtppt1170 AS zt02
      ON zt01~idnrk EQ zt02~matnr
     AND zt02~werks EQ @gp_werks
   ORDER BY mara~matnr
    INTO TABLE @DATA(lt_mat).

  LOOP AT gt_tail REFERENCE INTO DATA(lr_tail).
    READ TABLE lt_mat INTO DATA(ls_mat) WITH KEY matnr = lr_tail->idnrk BINARY SEARCH.

    CHECK sy-subrc IS INITIAL.
    CHECK NOT ( ls_mat-mtart EQ 'MCHF' OR ls_mat-mtart EQ 'HALB' ).

    lr_tail->beikz = COND #( WHEN ls_mat-zmat IS NOT INITIAL THEN space
                                                              ELSE 'V' ).
  ENDLOOP.

ENDFORM.
