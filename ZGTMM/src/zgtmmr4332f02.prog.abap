*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR4332F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& FORM SET_COLUMNS
*&---------------------------------------------------------------------*
FORM set_columns USING it_col  TYPE tt_col
                       io_cols TYPE REF TO cl_salv_columns_table.

  DATA lo_col TYPE REF TO cl_salv_column_table.

  LOOP AT it_col ASSIGNING FIELD-SYMBOL(<ls_col>).
    TRY.
        lo_col ?= io_cols->get_column( <ls_col>-name ).
        " 텍스트가 지정된 컬럼은 숨김 여부와 무관하게 헤더 텍스트를 세팅
        " (숨김 컬럼도 사용자가 레이아웃에서 추가할 때 이름이 보이도록)
        IF <ls_col>-text IS NOT INITIAL.
          lo_col->set_short_text( CONV #( <ls_col>-text ) ).
          lo_col->set_medium_text( CONV #( <ls_col>-text ) ).
          lo_col->set_long_text( <ls_col>-text ).
        ENDIF.
        IF <ls_col>-hide = gc_x.
          lo_col->set_visible( abap_false ).
        ENDIF.
        IF <ls_col>-link = gc_x.
          lo_col->set_cell_type( if_salv_c_cell_type=>hotspot ).
        ENDIF.
        IF <ls_col>-name = 'ICON'.
          lo_col->set_icon( if_salv_c_bool_sap=>true ).
        ENDIF.
      CATCH cx_salv_not_found.
        CONTINUE.
    ENDTRY.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DISPLAY_SUM
*&---------------------------------------------------------------------*
FORM display_sum.

  DATA: lo_salv TYPE REF TO cl_salv_table,
        lt_col  TYPE tt_col.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = lo_salv
                              CHANGING  t_table      = gt_sum ).

      lo_salv->get_functions( )->set_all( abap_true ).
      lo_salv->get_columns( )->set_optimize( abap_true ).
      lo_salv->get_display_settings( )->set_list_header( '납품서 유형별 입고현황 - 유형/기간 요약' ).

      lt_col = VALUE #(
        ( name = 'TYP_TXT'  text = '유형' )
        ( name = 'WERKS'    text = '플랜트' )
        ( name = 'PERIOD'   text = '기간' )
        ( name = 'DELCNT'   text = '납품서수' )
        ( name = 'ITEMCNT'  text = '품목수' )
        ( name = 'DELQTY'   text = '납품수량' )
        ( name = 'GRQTY'    text = '입고수량' )
        ( name = 'OPENQTY'  text = '미입고수량' )
        ( name = 'GRRATE'   text = '입고율(%)' )
        ( name = 'CNT_FULL' text = '완료' )
        ( name = 'CNT_PART' text = '부분' )
        ( name = 'CNT_OPEN' text = '미입고' )
        ( name = 'CNT_ERR'  text = '오류' )
        ( name = 'CNT_OVER' text = '초과' )
        ( name = 'CNT_CANC' text = '취소' )
        ( name = 'TYP_SEQ'  hide = gc_x ) ).
      DATA(lo_cols) = lo_salv->get_columns( ).
      PERFORM set_columns USING lt_col lo_cols.
      DATA(lt_fn1) = VALUE lvc_t_fnam( ( 'DELQTY' ) ( 'GRQTY' ) ( 'OPENQTY' ) ).
      PERFORM set_int_decimals USING gt_sum lt_fn1 lo_cols.

      " 유형은 정렬만 하고 소계는 생성하지 않음 (같은 값 반복 표시 안 함). 총계(합계행)는 유지
      lo_salv->get_sorts( )->add_sort( columnname = 'TYP_SEQ' ).
      lo_salv->get_sorts( )->add_sort( columnname = 'TYP_TXT' ).
      DATA(lo_aggr) = lo_salv->get_aggregations( ).
      DATA(lt_sum_col) = VALUE lvc_t_fnam( ( 'DELCNT' ) ( 'ITEMCNT' )
                                           ( 'DELQTY' ) ( 'GRQTY' )
                                           ( 'OPENQTY' ) ( 'CNT_FULL' )
                                           ( 'CNT_PART' ) ( 'CNT_OPEN' )
                                           ( 'CNT_ERR' ) ( 'CNT_OVER' )
                                           ( 'CNT_CANC' ) ).
      LOOP AT lt_sum_col ASSIGNING FIELD-SYMBOL(<lv_sc>).
        lo_aggr->add_aggregation( columnname = <lv_sc> ).
      ENDLOOP.

      lo_salv->display( ).
    CATCH cx_salv_msg cx_salv_not_found cx_salv_data_error cx_salv_existing INTO DATA(lx_err).
      MESSAGE lx_err->get_text( ) TYPE 'E'.
  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADD_HIDDEN_COLS
*&  컬럼 목록(ct_col)에 없는 구조 필드는 모두 숨김 컬럼으로 추가
*&---------------------------------------------------------------------*
FORM add_hidden_cols USING    io_struc TYPE REF TO cl_abap_structdescr
                     CHANGING ct_col   TYPE tt_col.

  LOOP AT io_struc->get_components( ) ASSIGNING FIELD-SYMBOL(<ls_comp>).
    IF NOT line_exists( ct_col[ name = <ls_comp>-name ] ).
      APPEND VALUE #( name = <ls_comp>-name hide = gc_x ) TO ct_col.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DISPLAY_ITEM
*&  납품 문서별 입고/이전전기 대사(모드 ②): 납품서 품목 1행
*&   pv_kind 'I' = 납품 명세서(INV), 'S' = 매입/매출보관품(IVS)
*&  (더블클릭: 입고 전표/라벨 팝업)
*&---------------------------------------------------------------------*
FORM display_item USING pv_kind TYPE c.

  DATA: lo_salv    TYPE REF TO cl_salv_table,
        lo_handler TYPE REF TO lcl_handler,
        lt_col     TYPE tt_col,
        ls_row     TYPE ty_item,
        lv_hide    TYPE c LENGTH 1.

  CLEAR gt_view.
  IF pv_kind = 'I'.
    gt_view = VALUE #( FOR ls_i IN gt_item WHERE ( deltype IS INITIAL ) ( ls_i ) ).
  ELSE.
    gt_view = VALUE #( FOR ls_i IN gt_item WHERE ( deltype IS NOT INITIAL ) ( ls_i ) ).
  ENDIF.
  CHECK gt_view IS NOT INITIAL.

  IF p_chk IS INITIAL.
    lv_hide = gc_x. "대사플래그 컬럼은 점검대상 조회 시에만 표시
  ENDIF.

  CREATE OBJECT lo_handler.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = lo_salv
                              CHANGING  t_table      = gt_view ).

      lo_salv->get_functions( )->set_all( abap_true ).
      lo_salv->get_columns( )->set_optimize( abap_true ).
      lo_salv->get_columns( )->set_color_column( 'COLCELL' ).
      lo_salv->get_display_settings( )->set_list_header(
        COND #( WHEN pv_kind = 'I'
                THEN '납품서 입고/이전처리 현황 - 납품 명세서 (더블클릭: 입고 전표/라벨)'
                ELSE '납품서 입고/이전처리 현황 - 매입/매출보관품 (더블클릭: 입고 전표/라벨)' ) ).

      " 컬럼 표시 순서 = 아래 나열 순서 (set_column_position 으로 적용)
      lt_col = VALUE #(
        ( name = 'ICON'       text = '상태' )
        ( name = 'BUDAT'      text = 'G-pro 발행일' )
        ( name = 'LAST_GR'    text = '전기일' )
        ( name = 'PROC_TXT'   text = '처리유형' )
        ( name = 'WERKS'      text = '플랜트' )
        ( name = 'LGORT'      text = '저장위치' )
        ( name = 'LIFNR'      text = '공급업체' )
        ( name = 'NAME1'      text = '공급업체명' )
        ( name = 'DELNO'      text = '납품서번호' )
        ( name = 'DELITEM'    text = '납품서항번' )
        ( name = 'MATNR'      text = '자재코드' link = gc_x )
        ( name = 'MAKTX'      text = '자재명' )
        ( name = 'EBELN'      text = '구매오더' link = gc_x )
        ( name = 'EBELP'      text = '항번' )
        ( name = 'VBELN_PO'   text = '(구)판매오더' link = gc_x )
        ( name = 'POSNR_PO'   text = '항번' )
        ( name = 'VBELN_GR'   text = '(신)판매오더' link = gc_x )
        ( name = 'POSNR_GR'   text = '항번' )
        ( name = 'JOJANG'     text = '조장(기준)' )
        ( name = 'MEINS'      text = '단위' ) ).

      IF pv_kind = 'I'.
        APPEND LINES OF VALUE tt_col(
          ( name = 'PODRUM'     text = 'Po(드럼수)' )
          ( name = 'POQTY'      text = 'PO(조장) 계' )
          ( name = 'DELDRUM'    text = '납품 문서 입고대상(드럼수)' )
          ( name = 'DELQTY'     text = '납품문서 입고대상 (조장)계' )
          ( name = 'GRDRUM'     text = '납품서 기준 입고(드럼수)' )
          ( name = 'GRQTY_STD'  text = '납품서 기준 입고(조장)계' )
          ( name = 'OPENDRUM'   text = '납품서 기준 미처리(드럼수)' )
          ( name = 'OPENQTY'    text = '납품서 기준 미처리(조장)계' )
          ( name = 'GRRATE'     text = '납품서 기준 완료율(%)' )
          ( name = 'POTOT_DRUM' text = 'PO 대비 누적 입고(드럼수)' )
          ( name = 'POTOT_QTY'  text = 'PO 대비 누적 입고(조장)' )
          ( name = 'POOPN_DRUM' text = 'PO대비 미입고(드럼수)' )
          ( name = 'POOPN_QTY'  text = 'PO대비 미입고(조장)' ) ) TO lt_col.
      ELSE.
        APPEND LINES OF VALUE tt_col(
          ( name = 'DELDRUM'    text = '보관품이전전기(드럼수)' )
          ( name = 'DELQTY'     text = '보관품이전전기(조장)계' )
          ( name = 'STKDRUM'    text = '납품서 기준 이전전기(드럼수)' )
          ( name = 'GRQTY_STK'  text = '납품서 기준 이전전기(조장)계' )
          ( name = 'OPENDRUM'   text = '납품서 기준 미처리(드럼수)' )
          ( name = 'OPENQTY'    text = '납품서 기준 미처리(조장)계' )
          ( name = 'GRRATE'     text = '납품서 기준 완료율(%)' ) ) TO lt_col.
      ENDIF.
      APPEND VALUE #( name = 'CHK_TXT' text = '대사플래그' hide = lv_hide ) TO lt_col.

      DATA(lt_vis) = lt_col. "화면 순서 대상 (숨김 컬럼 제외)
      DATA(lo_struc) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( ls_row ) ).
      PERFORM add_hidden_cols USING lo_struc CHANGING lt_col.

      DATA(lo_cols) = lo_salv->get_columns( ).
      PERFORM set_columns USING lt_col lo_cols.
      DATA(lt_fn2) = VALUE lvc_t_fnam( ( 'JOJANG' ) ( 'DELQTY' ) ( 'DELDRUM' ) ( 'POQTY' ) ( 'PODRUM' ) ( 'GRQTY_STD' ) ( 'GRDRUM' )
                                          ( 'GRQTY_STK' ) ( 'STKDRUM' ) ( 'OPENQTY' ) ( 'OPENDRUM' )
                                          ( 'POTOT_DRUM' ) ( 'POTOT_QTY' ) ( 'POOPN_DRUM' ) ( 'POOPN_QTY' ) ).
      PERFORM set_int_decimals USING gt_view lt_fn2 lo_cols.

      LOOP AT lt_vis ASSIGNING FIELD-SYMBOL(<ls_pos>).
        TRY.
            lo_cols->set_column_position( columnname = <ls_pos>-name position = sy-tabix ).
          CATCH cx_salv_not_found cx_salv_existing.
            CONTINUE.
        ENDTRY.
      ENDLOOP.

      " 납품서번호 순 정렬 (소계 없음, 품목 순서는 ITEMSEQ 로 사전 정렬). 총계(합계행)는 유지
      lo_salv->get_sorts( )->add_sort( columnname = 'DELNO' ).
      DATA(lo_aggr) = lo_salv->get_aggregations( ).
      " PO 수량/드럼수는 같은 PO 품목이 납품서마다 반복되므로 합계에서 제외
      DATA(lt_sum_col) = VALUE lvc_t_fnam( ( 'DELQTY' ) ( 'GRQTY_STD' ) ( 'GRQTY_STK' )
                                           ( 'OPENQTY' ) ( 'DELDRUM' )
                                           ( 'GRDRUM' ) ( 'STKDRUM' ) ( 'OPENDRUM' ) ).
      LOOP AT lt_sum_col ASSIGNING FIELD-SYMBOL(<lv_sc>).
        lo_aggr->add_aggregation( columnname = <lv_sc> ).
      ENDLOOP.

      DATA(lo_events) = lo_salv->get_event( ).
      SET HANDLER lo_handler->on_dbl_item FOR lo_events.
      SET HANDLER lo_handler->on_link_item FOR lo_events.

      lo_salv->display( ).
    CATCH cx_salv_msg cx_salv_not_found cx_salv_data_error cx_salv_existing INTO DATA(lx_err).
      MESSAGE lx_err->get_text( ) TYPE 'E'.
  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DISPLAY_DETAIL
*&  납품 문서별 상세 조회(모드 ③): 입고/이전전기 전표·라벨 1건 = 1행
*&   배치번호 / 꼬리표번호(드럼라벨번호) 표시. MES 라벨 테이블에 기록된 건만 대상
*&---------------------------------------------------------------------*
FORM display_detail.

  DATA: lo_salv    TYPE REF TO cl_salv_table,
        lo_handler TYPE REF TO lcl_handler,
        lt_col  TYPE tt_col,
        ls_row  TYPE ty_det,
        lt_dtl  TYPE STANDARD TABLE OF ty_dtl,
        lv_found TYPE abap_bool.

  CLEAR gt_det.

  LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<ls_it>).
    CLEAR: lt_dtl, lv_found.
    PERFORM get_dtl USING <ls_it>-delno <ls_it>-delitem CHANGING lt_dtl.

    LOOP AT lt_dtl ASSIGNING FIELD-SYMBOL(<ls_d>).
      " 최종 문서 기준: 취소됨/역분개/전표없음은 입고가 아니므로 표시하지 않음
      IF <ls_d>-state_txt <> '정상'.
        CONTINUE.
      ENDIF.
      IF s_label[] IS NOT INITIAL AND <ls_d>-dr_label NOT IN s_label.
        CONTINUE.
      ENDIF.
      IF s_charg[] IS NOT INITIAL AND <ls_d>-charg NOT IN s_charg.
        CONTINUE.
      ENDIF.

      lv_found = abap_true.
      CLEAR ls_row.
      ls_row-icon      = <ls_it>-icon.
      ls_row-colcell   = <ls_it>-colcell.
      ls_row-budat     = <ls_it>-budat.
      ls_row-gr_budat  = <ls_d>-budat.
      ls_row-proc_txt  = <ls_it>-proc_txt.
      ls_row-src       = <ls_d>-src.
      ls_row-werks     = <ls_it>-werks.
      ls_row-lgort     = <ls_it>-lgort.
      ls_row-lifnr     = <ls_it>-lifnr.
      ls_row-name1     = <ls_it>-name1.
      ls_row-delno     = <ls_it>-delno.
      ls_row-delitem   = <ls_it>-delitem.
      ls_row-matnr     = <ls_it>-matnr.
      ls_row-maktx     = <ls_it>-maktx.
      ls_row-ebeln     = <ls_it>-ebeln.
      ls_row-ebelp     = <ls_it>-ebelp.
      ls_row-vbeln_po  = <ls_it>-vbeln_po.
      ls_row-posnr_po  = <ls_it>-posnr_po.
      ls_row-vbeln_gr  = COND #( WHEN <ls_d>-so IS NOT INITIAL THEN <ls_d>-so ELSE <ls_it>-vbeln_gr ).
      ls_row-posnr_gr  = COND #( WHEN <ls_d>-so IS NOT INITIAL THEN <ls_d>-soitm ELSE <ls_it>-posnr_gr ).
      ls_row-charg     = <ls_d>-charg.
      ls_row-dr_label  = <ls_d>-dr_label.
      ls_row-meins     = <ls_it>-meins.
      ls_row-mblnr     = <ls_d>-mblnr.
      ls_row-mjahr     = <ls_d>-mjahr.
      ls_row-state_txt = <ls_d>-state_txt.
      ls_row-zstat_txt = <ls_d>-zstat_txt.

      ls_row-qty  = <ls_d>-qty.
      ls_row-drum = COND #( WHEN <ls_d>-dr_label IS NOT INITIAL THEN 1
                            WHEN <ls_it>-jojang > 0 THEN <ls_d>-qty / <ls_it>-jojang
                            ELSE 1 ).
      APPEND ls_row TO gt_det.
    ENDLOOP.

    " 유효(정상) 입고 문서가 없는 납품서 품목: 전표·전기일·배치·꼬리표 없이 품목 행만 표시 (미입고)
    IF lv_found = abap_false AND s_label[] IS INITIAL AND s_charg[] IS INITIAL.
      CLEAR ls_row.
      ls_row-icon     = <ls_it>-icon.
      ls_row-colcell  = <ls_it>-colcell.
      ls_row-budat    = <ls_it>-budat.
      " 처리유형1 은 입고 예정 방식이라 미입고 행에는 표시하지 않음
      ls_row-werks    = <ls_it>-werks.
      ls_row-lgort    = <ls_it>-lgort.
      ls_row-lifnr    = <ls_it>-lifnr.
      ls_row-name1    = <ls_it>-name1.
      ls_row-delno    = <ls_it>-delno.
      ls_row-delitem  = <ls_it>-delitem.
      ls_row-matnr    = <ls_it>-matnr.
      ls_row-maktx    = <ls_it>-maktx.
      ls_row-ebeln    = <ls_it>-ebeln.
      ls_row-ebelp    = <ls_it>-ebelp.
      ls_row-vbeln_po = <ls_it>-vbeln_po.
      ls_row-posnr_po = <ls_it>-posnr_po.
      ls_row-vbeln_gr = <ls_it>-vbeln_gr.
      ls_row-posnr_gr = <ls_it>-posnr_gr.
      ls_row-meins    = <ls_it>-meins.
      APPEND ls_row TO gt_det.
    ENDIF.
  ENDLOOP.

  IF gt_det IS INITIAL.
    MESSAGE '조회 결과가 없습니다.' TYPE 'S' DISPLAY LIKE 'W'.
    RETURN.
  ENDIF.
  SORT gt_det BY delno delitem src dr_label mblnr.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = lo_salv
                              CHANGING  t_table      = gt_det ).

      lo_salv->get_functions( )->set_all( abap_true ).
      lo_salv->get_columns( )->set_optimize( abap_true ).
      lo_salv->get_columns( )->set_color_column( 'COLCELL' ).
      lo_salv->get_display_settings( )->set_list_header(
        '납품서 입고/이전처리 현황 - 납품 문서별 상세 (배치/꼬리표)' ).

      lt_col = VALUE #(
        ( name = 'ICON'      text = '상태' )
        ( name = 'BUDAT'     text = 'G-PRO발행일' )
        ( name = 'GR_BUDAT'  text = '전기일' )
        ( name = 'PROC_TXT'  text = '처리유형1' )
        ( name = 'SRC'       text = '처리유형2' )
        ( name = 'WERKS'     text = '플랜트' )
        ( name = 'LGORT'     text = '저장위치' )
        ( name = 'LIFNR'     text = '공급업체' )
        ( name = 'NAME1'     text = '공급업체명' )
        ( name = 'DELNO'     text = '납품서번호' )
        ( name = 'DELITEM'   text = '납품서항번' )
        ( name = 'MATNR'     text = '자재코드' link = gc_x )
        ( name = 'MAKTX'     text = '자재명' )
        ( name = 'EBELN'     text = '구매오더' link = gc_x )
        ( name = 'EBELP'     text = '항번' )
        ( name = 'VBELN_PO'  text = '(구)판매오더' link = gc_x )
        ( name = 'POSNR_PO'  text = '항번' )
        ( name = 'VBELN_GR'  text = '(신)판매오더' link = gc_x )
        ( name = 'POSNR_GR'  text = '항번' )
        ( name = 'CHARG'     text = '배치번호' )
        ( name = 'DR_LABEL'  text = '꼬리표번호' )
        ( name = 'MEINS'     text = '단위' )
        ( name = 'DRUM'      text = '납품서기준입고(드럼수)' )
        ( name = 'QTY'       text = '납품서기준입고(조장)계' )
        ( name = 'MBLNR'     text = '전표번호' link = gc_x )
        ( name = 'STATE_TXT' text = '전표상태' )
        ( name = 'ZSTAT_TXT' text = '처리상태' )
        ( name = 'MJAHR'     hide = gc_x )
        ( name = 'COLCELL'   hide = gc_x ) ).
      DATA(lo_cols) = lo_salv->get_columns( ).
      PERFORM set_columns USING lt_col lo_cols.
      DATA(lt_fn4) = VALUE lvc_t_fnam( ( 'DRUM' ) ( 'QTY' ) ).
      PERFORM set_int_decimals USING gt_det lt_fn4 lo_cols.

      LOOP AT lt_col ASSIGNING FIELD-SYMBOL(<ls_pos>).
        TRY.
            lo_cols->set_column_position( columnname = <ls_pos>-name position = sy-tabix ).
          CATCH cx_salv_not_found cx_salv_existing.
            CONTINUE.
        ENDTRY.
      ENDLOOP.

      CREATE OBJECT lo_handler.
      DATA(lo_events) = lo_salv->get_event( ).
      SET HANDLER lo_handler->on_link_det FOR lo_events.

      DATA(lo_aggr) = lo_salv->get_aggregations( ).
      lo_aggr->add_aggregation( columnname = 'DRUM' ).
      lo_aggr->add_aggregation( columnname = 'QTY' ).

      lo_salv->display( ).
    CATCH cx_salv_msg cx_salv_not_found cx_salv_data_error cx_salv_existing INTO DATA(lx_err).
      MESSAGE lx_err->get_text( ) TYPE 'E'.
  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GET_DTL
*&  품목별 입고 전표(101) / MES 라벨(311) 상세 행 생성 (팝업·상세 모드 공용)
*&---------------------------------------------------------------------*
FORM get_dtl USING    pv_delno   TYPE zgtmmt9410-delno
                      pv_delitem TYPE zgtmmt9410-delitem
             CHANGING ct_dtl     TYPE STANDARD TABLE.

  DATA: lt_dtl    TYPE STANDARD TABLE OF ty_dtl,
        lv_delqty TYPE ty_qty,
        lv_poqty  TYPE ty_qty,
        ls_dtl    TYPE ty_dtl.

  " 구매입고(101): MATDOC 납품서번호 기준 (취소/역분개 전표 포함하여 상태 표시)
  SELECT a~mblnr, a~mjahr, a~zeile, a~budat, a~erfmg, a~erfme, a~cancelled, a~reversal_movement,
         a~ebeln, a~ebelp, m~mat_kdauf, m~mat_kdpos, m~charg
    FROM zgtmm_cv_get_matdoc AS a
    INNER JOIN matdoc AS m
       ON m~mblnr = a~mblnr
      AND m~mjahr = a~mjahr
      AND m~zeile = a~zeile
    " 납품서 키 비교는 요약 모드(ZGTMM_CV_DELIV_GR_101 조인)와 동일하게 DB 측 컬럼 간 조인으로 처리
    INNER JOIN zgtmm_cv_deliv_base AS b
       ON b~delno   = a~delno
      AND b~delitem = a~delitem
    WHERE b~delno   = @pv_delno
      AND b~delitem = @pv_delitem
    INTO TABLE @DATA(lt_std).

  " 납품예정수량: 조회 결과(ALV)의 해당 납품서 품목 값
  READ TABLE gt_item ASSIGNING FIELD-SYMBOL(<ls_item>)
       WITH KEY delno = pv_delno delitem = pv_delitem.
  IF sy-subrc = 0.
    lv_delqty = <ls_item>-delqty.
    lv_poqty  = <ls_item>-poqty.
  ENDIF.

  LOOP AT lt_std ASSIGNING FIELD-SYMBOL(<ls_std>).
    CLEAR ls_dtl.
    ls_dtl-src   = '101'.
    ls_dtl-ebeln = <ls_std>-ebeln.
    ls_dtl-ebelp = <ls_std>-ebelp.
    ls_dtl-delqty = lv_delqty.
    ls_dtl-poqty  = lv_poqty.
    ls_dtl-mblnr = <ls_std>-mblnr.
    ls_dtl-mjahr = <ls_std>-mjahr.
    ls_dtl-zeile = <ls_std>-zeile.
    ls_dtl-budat = <ls_std>-budat.
    ls_dtl-qty   = <ls_std>-erfmg.
    ls_dtl-unit  = <ls_std>-erfme.
    ls_dtl-so    = <ls_std>-mat_kdauf.
    ls_dtl-soitm = <ls_std>-mat_kdpos.
    ls_dtl-charg = <ls_std>-charg.
    ls_dtl-state_txt = COND #( WHEN <ls_std>-cancelled = gc_x THEN '취소됨'
                               WHEN <ls_std>-reversal_movement = gc_x THEN '역분개'
                               ELSE '정상' ).
    APPEND ls_dtl TO lt_dtl.
  ENDLOOP.

  " MES 재고이전(311): 9425 -> 9000(상태) -> 9423(전표) -> MATDOC
  SELECT p~dr_label_no, p~ebeln, p~ebelp, s~zstat, r~mblnr, r~mjahr,
         m~zeile, m~budat, m~erfmg, m~erfme, m~cancelled, m~reversal_movement,
         m~mat_kdauf, m~mat_kdpos, m~charg
    FROM zgtmmt9425 AS p
    INNER JOIN zgtmmt9000 AS s
       ON s~zifkey    = p~zifkey
      AND s~system_id = p~system_id
      AND s~zifno     = @gc_zifno_dr
    LEFT OUTER JOIN zgtmmt9423 AS r
       ON r~zifkey      = p~zifkey
      AND r~system_id   = p~system_id
      AND r~ebeln       = p~ebeln
      AND r~ebelp       = p~ebelp
      AND r~dr_label_no = p~dr_label_no
    LEFT OUTER JOIN matdoc AS m
       ON m~mblnr = r~mblnr
      AND m~mjahr = r~mjahr
      AND m~bwart = '311'
      AND m~shkzg = 'S'
    WHERE p~delno   = @pv_delno
      AND p~delitem = @pv_delitem
    INTO TABLE @DATA(lt_stk).

  LOOP AT lt_stk ASSIGNING FIELD-SYMBOL(<ls_stk>).
    DATA(lv_zstat_txt) = COND ty_ztxt( WHEN <ls_stk>-zstat = 'S' THEN '성공'
                                              WHEN <ls_stk>-zstat = 'E' THEN '실패'
                                              ELSE '미확정' ).

    " 라벨 입고 전표가 구매입고(101) 전표이면 101 행에 라벨 정보를 붙이고 별도 행은 만들지 않음
    IF <ls_stk>-mblnr IS NOT INITIAL.
      READ TABLE lt_dtl ASSIGNING FIELD-SYMBOL(<ls_101>)
           WITH KEY src = '101' mblnr = <ls_stk>-mblnr mjahr = <ls_stk>-mjahr
                    dr_label = space.
      IF sy-subrc = 0.
        <ls_101>-dr_label  = <ls_stk>-dr_label_no.
        <ls_101>-zstat_txt = lv_zstat_txt.
        CONTINUE.
      ENDIF.
    ENDIF.

    CLEAR ls_dtl.
    ls_dtl-src       = COND #( WHEN <ls_stk>-zeile IS INITIAL AND <ls_stk>-mblnr IS NOT INITIAL
                               THEN 'MES' ELSE '311' ).
    ls_dtl-dr_label  = <ls_stk>-dr_label_no.
    ls_dtl-ebeln     = <ls_stk>-ebeln.
    ls_dtl-ebelp     = <ls_stk>-ebelp.
    ls_dtl-delqty    = lv_delqty.
    ls_dtl-poqty     = lv_poqty.
    ls_dtl-zstat_txt = lv_zstat_txt.
    ls_dtl-mblnr = <ls_stk>-mblnr.
    ls_dtl-mjahr = <ls_stk>-mjahr.
    ls_dtl-zeile = <ls_stk>-zeile.
    ls_dtl-budat = <ls_stk>-budat.
    ls_dtl-qty   = <ls_stk>-erfmg.
    ls_dtl-unit  = <ls_stk>-erfme.
    ls_dtl-so    = <ls_stk>-mat_kdauf.
    ls_dtl-soitm = <ls_stk>-mat_kdpos.
    ls_dtl-charg = <ls_stk>-charg.
    ls_dtl-state_txt = COND #( WHEN <ls_stk>-mblnr IS INITIAL THEN '전표없음'
                               WHEN <ls_stk>-cancelled = gc_x THEN '취소됨'
                               WHEN <ls_stk>-reversal_movement = gc_x THEN '역분개'
                               ELSE '정상' ).
    APPEND ls_dtl TO lt_dtl.
  ENDLOOP.

  SORT lt_dtl BY src dr_label mblnr mjahr zeile.
  ct_dtl = lt_dtl.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SHOW_DOCS
*&  품목별 입고 전표(101) / MES 라벨(311) 상세 팝업
*&---------------------------------------------------------------------*
FORM show_docs USING pv_delno   TYPE zgtmmt9410-delno
                     pv_delitem TYPE zgtmmt9410-delitem.

  DATA: lt_dtl    TYPE STANDARD TABLE OF ty_dtl,
        lv_delqty TYPE ty_qty,
        lv_poqty  TYPE ty_qty,
        ls_dtl    TYPE ty_dtl,
        lt_col    TYPE tt_col,
        lo_salv   TYPE REF TO cl_salv_table.

  PERFORM get_dtl USING pv_delno pv_delitem CHANGING lt_dtl.

  IF lt_dtl IS INITIAL.
    MESSAGE '입고 전표/라벨 내역이 없습니다.' TYPE 'S' DISPLAY LIKE 'W'.
    RETURN.
  ENDIF.

  READ TABLE gt_item ASSIGNING FIELD-SYMBOL(<ls_item>)
       WITH KEY delno = pv_delno delitem = pv_delitem.
  IF sy-subrc = 0.
    lv_delqty = <ls_item>-delqty.
    lv_poqty  = <ls_item>-poqty.
  ENDIF.

  " 납품예정수량 / 구매오더수량은 납품서 품목 단위 값이라 행마다 표시하지 않고
  " 마지막 합계 행에만 표시. 합계 행의 입고(이전)수량은 위 행의 합계
  DATA lv_sum TYPE ty_qty.
  LOOP AT lt_dtl ASSIGNING FIELD-SYMBOL(<ls_row>).
    lv_sum = lv_sum + <ls_row>-qty.
    CLEAR: <ls_row>-delqty, <ls_row>-poqty.
  ENDLOOP.
  CLEAR ls_dtl.
  ls_dtl-src    = '합계'.
  ls_dtl-delqty = lv_delqty.
  ls_dtl-qty    = lv_sum.
  ls_dtl-poqty  = lv_poqty.
  APPEND ls_dtl TO lt_dtl.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = lo_salv
                              CHANGING  t_table      = lt_dtl ).

      lo_salv->get_functions( )->set_all( abap_true ).
      lo_salv->get_columns( )->set_optimize( abap_true ).
      lo_salv->get_display_settings( )->set_list_header(
        |납품서 { pv_delno } / { pv_delitem } 입고 전표·라벨| ).

      lt_col = VALUE #(
        ( name = 'SRC'       text = '구분' )
        ( name = 'DR_LABEL'  text = '드럼라벨번호' )
        ( name = 'CHARG'     text = '배치번호' )
        ( name = 'DELQTY'    text = '납품예정수량' )
        ( name = 'QTY'       text = '입고(이전)수량' )
        ( name = 'POQTY'     text = '구매오더수량' )
        ( name = 'MBLNR'     text = '전표번호' )
        ( name = 'STATE_TXT' text = '전표상태' )
        ( name = 'EBELN'     text = '구매오더'     hide = gc_x )
        ( name = 'EBELP'     text = '구매오더품번' hide = gc_x )
        ( name = 'MJAHR'     text = '연도'         hide = gc_x )
        ( name = 'ZEILE'     text = '항번'         hide = gc_x )
        ( name = 'BUDAT'     text = '전기일'       hide = gc_x )
        ( name = 'UNIT'      text = '단위'         hide = gc_x )
        ( name = 'ZSTAT_TXT' text = '처리상태'     hide = gc_x )
        ( name = 'SO'        text = '판매오더'     hide = gc_x )
        ( name = 'SOITM'     text = '판매오더품번' hide = gc_x ) ).
      DATA(lo_cols) = lo_salv->get_columns( ).
      PERFORM set_columns USING lt_col lo_cols.
      DATA(lt_fn3) = VALUE lvc_t_fnam( ( 'DELQTY' ) ( 'QTY' ) ( 'POQTY' ) ).
      PERFORM set_int_decimals USING lt_dtl lt_fn3 lo_cols.

      " 합계는 SALV 집계 대신 마지막 합계 행으로 직접 표시 (납품예정수량/구매오더수량은 합계 행에만 값이 있음)

      lo_salv->set_screen_popup( start_column = 20 end_column = 170
                                 start_line   = 6  end_line   = 24 ).
      lo_salv->display( ).
    CATCH cx_salv_msg cx_salv_not_found cx_salv_data_error cx_salv_existing INTO DATA(lx_err).
      MESSAGE lx_err->get_text( ) TYPE 'E'.
  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_INT_DECIMALS
*&  컬럼의 모든 값이 정수이면 소수점 이하 표시(0)를 제거 (하나라도 소수가 있으면 유지)
*&---------------------------------------------------------------------*
FORM set_int_decimals USING it_tab  TYPE STANDARD TABLE
                            it_fnam TYPE lvc_t_fnam
                            io_cols TYPE REF TO cl_salv_columns_table.

  DATA: lo_col TYPE REF TO cl_salv_column_table,
        lv_p   TYPE p LENGTH 15 DECIMALS 3,
        lv_int TYPE abap_bool.
  FIELD-SYMBOLS <lv_val> TYPE any.

  LOOP AT it_fnam ASSIGNING FIELD-SYMBOL(<lv_fn>).
    lv_int = abap_true.
    LOOP AT it_tab ASSIGNING FIELD-SYMBOL(<ls_row>).
      ASSIGN COMPONENT <lv_fn> OF STRUCTURE <ls_row> TO <lv_val>.
      CHECK sy-subrc = 0.
      lv_p = <lv_val>.
      IF frac( lv_p ) <> 0.
        lv_int = abap_false.
        EXIT.
      ENDIF.
    ENDLOOP.
    CHECK lv_int = abap_true.
    TRY.
        lo_col ?= io_cols->get_column( <lv_fn> ).
        lo_col->set_decimals( '0' ).
      CATCH cx_salv_not_found.
        CONTINUE.
    ENDTRY.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GOTO_DOC
*&  핫스팟 클릭 이동: PO(ME23N) / SO(VA03) / 자재(MM03) / 자재문서(MIGO 조회)
*&---------------------------------------------------------------------*
FORM goto_doc USING pv_kind TYPE c
                    pv_key  TYPE clike
                    pv_year TYPE clike.

  DATA: lv_ebeln TYPE ebeln,
        lv_vbeln TYPE vbeln,
        lv_matnr TYPE matnr,
        lv_mblnr TYPE mblnr,
        lv_mjahr TYPE mjahr.

  CHECK pv_key IS NOT INITIAL.

  CASE pv_kind.
    WHEN 'PO'.
      lv_ebeln = pv_key.
      SET PARAMETER ID 'BES' FIELD lv_ebeln.
      CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
    WHEN 'SO'.
      lv_vbeln = pv_key.
      SET PARAMETER ID 'AUN' FIELD lv_vbeln.
      CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
    WHEN 'MAT'.
      lv_matnr = pv_key.
      SET PARAMETER ID 'MAT' FIELD lv_matnr.
      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
    WHEN 'MIGO'.
      lv_mblnr = pv_key.
      lv_mjahr = pv_year.
      CALL FUNCTION 'MIGO_DIALOG'
        EXPORTING
          i_action            = 'A04'
          i_refdoc            = 'R02'
          i_notree            = 'X'
          i_no_auth_check     = space
          i_skip_first_screen = 'X'
          i_okcode            = 'OK_GO'
          i_mblnr             = lv_mblnr
          i_mjahr             = lv_mjahr.
  ENDCASE.

ENDFORM.
