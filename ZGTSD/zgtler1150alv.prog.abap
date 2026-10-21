*&---------------------------------------------------------------------*
*& Include          ZGTLER1150ALV
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form create_alv_grid
*&---------------------------------------------------------------------*
FORM create_alv_grid
       USING  pi_screen
              po_container  TYPE REF TO cl_gui_custom_container
              po_grid       TYPE REF TO cl_gui_alv_grid
              pt_fcat       TYPE lvc_t_fcat
              pt_toolbar    TYPE ui_functions
              pt_sort       TYPE lvc_t_sort
              ps_layout     TYPE lvc_s_layo
              ps_variant    TYPE disvariant.

**
  IF po_container IS INITIAL.
*   1. Set container.
    PERFORM create_costom_container USING  po_container
                                           pi_screen.
*   2. Set Grid.
    PERFORM create_grid             USING  po_container
                                           po_grid.
*   3. Set ALV attributes.
    PERFORM make_alv_attributes     USING  pi_screen
                                           po_grid
                                           pt_fcat
                                           pt_toolbar
                                           pt_sort
                                           ps_layout
                                           ps_variant .

  ELSE.
    PERFORM refresh_alv             USING  po_grid.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form refresh_alv
*&---------------------------------------------------------------------*
FORM refresh_alv  USING    po_grid   TYPE REF TO cl_gui_alv_grid.

  DATA: ls_scroll           TYPE lvc_s_stbl.

**
  CLEAR: ls_scroll.
  ls_scroll-row = 'X'.
  ls_scroll-col = 'X'.

  CALL METHOD po_grid->refresh_table_display
    EXPORTING
      i_soft_refresh = ' '
      is_stable      = ls_scroll.     "화면 라인 Refresh

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_costom_container
*&---------------------------------------------------------------------*
FORM create_costom_container  USING  po_container
                                     TYPE REF TO cl_gui_custom_container
                                     pi_screen.

  DATA: lv_sname TYPE scrfname.

**
  CLEAR: lv_sname.
  IF pi_screen = '100'.
    lv_sname = 'CC01'.
  ENDIF.

  CREATE OBJECT po_container
    EXPORTING
      container_name = lv_sname.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_grid
*&---------------------------------------------------------------------*
FORM create_grid  USING  po_container
                            TYPE REF TO cl_gui_custom_container
                         po_grid
                            TYPE REF TO cl_gui_alv_grid.

**
  CREATE OBJECT po_grid
    EXPORTING
      i_parent          = po_container
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_alv_attributes
*&---------------------------------------------------------------------*
FORM make_alv_attributes  USING  pi_screen
                                 po_grid     TYPE REF TO cl_gui_alv_grid
                                 pt_fcat     TYPE lvc_t_fcat
                                 pt_toolbar  TYPE ui_functions
                                 pt_sort     TYPE lvc_t_sort
                                 ps_layout   TYPE lvc_s_layo
                                 ps_variant  TYPE disvariant.

**
* 1. Set Layout
  PERFORM set_alv_layout         USING  pi_screen
                                        ps_layout.

* 2. Set Sort.
  PERFORM set_sort_field         USING  pi_screen
                                        pt_sort.

* 3. Set Toolbar excluding.
  PERFORM set_excluding_toolbar  USING  pi_screen
                                        pt_toolbar.

* 4. Set Fieldcatalog.
  PERFORM set_fieldcatalog       USING  pi_screen
                                        pt_fcat.

* 5. Set Event.
  PERFORM set_event              USING  pi_screen
                                        po_grid.

* 6. Set variant.
  PERFORM set_variant            USING  pi_screen
                                        ps_variant.

* 7. Alv display
  PERFORM alv_first_display      USING  pi_screen
                                        po_grid
                                        pt_fcat
                                        pt_toolbar
                                        pt_sort
                                        ps_layout
                                        ps_variant .
**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_alv_layout
*&---------------------------------------------------------------------*
FORM set_alv_layout  USING    pi_screen
                              ps_layout  TYPE lvc_s_layo.

**
  CLEAR ps_layout.
  CASE pi_screen.
    WHEN '100'.
      ps_layout = VALUE #( sel_mode   = 'D'
                           zebra      = ' '
                           cwidth_opt = 'X'
                           totals_bef = 'X' ).
*                           no_rowmark = 'X'
*                           ctab_fname = 'ALV_SCOL'
*                           stylefname = 'ALV_STYL' ).

    WHEN OTHERS.

  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_sort_field
*&---------------------------------------------------------------------*
FORM set_sort_field  USING    pi_screen
                              pt_sort    TYPE lvc_t_sort.

**
  _clear: pt_sort.
  PERFORM set_sort_field_dtl   USING: pt_sort 'VKGRP_TXT' 'X' '' 'X'.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_sort_field_dtl
*&---------------------------------------------------------------------*
FORM set_sort_field_dtl  USING   pt_sort TYPE lvc_t_sort
                                 pi_fldname
                                 pi_up
                                 pi_down
                                 pi_subtot.

**
  APPEND VALUE #( spos      = lines( pt_sort ) + 1
                  fieldname = pi_fldname
                  up        = pi_up
                  down      = pi_down
                  subtot    = pi_subtot ) TO pt_sort.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_excluding_toolbar
*&---------------------------------------------------------------------*
FORM set_excluding_toolbar  USING    pi_screen
                                     pt_exclude  TYPE ui_functions.

**
  _clear: pt_exclude.

  APPEND: cl_gui_alv_grid=>mc_fc_loc_undo            TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_data_save           TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_loc_copy            TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_loc_copy_row        TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_loc_cut             TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_loc_delete_row      TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_loc_insert_row      TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_loc_move_row        TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_loc_append_row      TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_loc_paste           TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_loc_paste_new_row   TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_refresh             TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_check               TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_print               TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_views               TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_graph               TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_detail              TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_info                TO pt_exclude.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_fieldcatalog
*&---------------------------------------------------------------------*
FORM set_fieldcatalog  USING    pi_screen
                                pt_fcat    TYPE lvc_t_fcat.

  DATA: lt_fieldcat    TYPE lvc_t_fcat.

**
  _clear: lt_fieldcat.
  PERFORM get_field_catalog       USING    gt_list[]
                                  CHANGING lt_fieldcat.

  pt_fcat[] = CORRESPONDING #( lt_fieldcat[] ).

  PERFORM maintain_fieldcatalog   USING    pt_fcat.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_field_catalog
*&---------------------------------------------------------------------*
FORM get_field_catalog  USING    pt_table     TYPE table
                        CHANGING pt_fieldcat  TYPE lvc_t_fcat.

**
  _clear: pt_fieldcat.
  pt_fieldcat = zgtsd_cl_common=>get_field_catalog( it_table = pt_table ).
*                                                    iv_cells = 'X'
*                                                    iv_cellc = 'X' ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form maintain_fieldcatalog
*&---------------------------------------------------------------------*
FORM maintain_fieldcatalog  USING    pt_fcat    TYPE lvc_t_fcat.

**
  CHECK: pt_fcat[] IS NOT INITIAL.

  LOOP AT pt_fcat ASSIGNING FIELD-SYMBOL(<lfs_fcat>).

    CLEAR: <lfs_fcat>-tech.

    CASE <lfs_fcat>-fieldname.
      WHEN 'VKGRP       '.   " 영업그룹
        <lfs_fcat>-coltext = TEXT-a01.

      WHEN 'VKGRP_TXT   '.   " 영업그룹명
        <lfs_fcat>-coltext = TEXT-a02.
        <lfs_fcat>-key     = 'X'.

      WHEN 'IV_NO       '.   " 거래명세서번호
        <lfs_fcat>-coltext = TEXT-a03.
        <lfs_fcat>-key     = 'X'.

      WHEN 'KUNAG_NM    '.   " 판매처명
        <lfs_fcat>-coltext = TEXT-a53.
        <lfs_fcat>-key     = 'X'.

      WHEN 'KUNNR_NM    '.   " 납품처명
        <lfs_fcat>-coltext = TEXT-a04.
*        <lfs_fcat>-key     = 'X'.
        <lfs_fcat>-no_out  = 'X'.

      WHEN 'ZZYUSCD     '.   " 영업소코드
        <lfs_fcat>-coltext = TEXT-a05.
        <lfs_fcat>-key     = 'X'.

      WHEN 'TKNUM       '.   " 선적번호
        <lfs_fcat>-coltext = TEXT-a06.

      WHEN 'VGBEL       '.   " 주문번호
        <lfs_fcat>-coltext = TEXT-a07.

      WHEN 'VGPOS       '.   " 항번
        <lfs_fcat>-coltext = TEXT-a08.

      WHEN 'MAKTX       '.   " 자재내역
        <lfs_fcat>-coltext = TEXT-a09.

      WHEN 'COLOR       '.   " 색상 ( PD_CA_COLOR_BASE )
        <lfs_fcat>-coltext = TEXT-a10.

      WHEN 'STR         '.   " Str ( PD_CA_COLOR_STRIPE )
        <lfs_fcat>-coltext = TEXT-a57.

      WHEN 'STR_NO      '.   " 띄줄 ( PD_CA_COLOR_STRIPE_NO )
        <lfs_fcat>-coltext = TEXT-a58.

      WHEN 'KGW         '.   " 동량
        <lfs_fcat>-coltext = TEXT-a11.
        <lfs_fcat>-do_sum  = 'X'.

      WHEN 'FIBER_C     '.   " F량 ( PD_CA_FIBER_NO_1ST )
        <lfs_fcat>-coltext = TEXT-a12.
        <lfs_fcat>-no_out  = 'X'.

      WHEN 'FIBER_N     '.   " F량 ( 화면표시용 )
        <lfs_fcat>-coltext = TEXT-a12.
        <lfs_fcat>-do_sum  = 'X'.

      WHEN 'LFIMG       '.   " 납품수량
        <lfs_fcat>-coltext = TEXT-a14.
        <lfs_fcat>-do_sum  = 'X'.

      WHEN 'VRKME       '.   " 단위
        <lfs_fcat>-coltext = TEXT-a15.

      WHEN 'LENGTH      '.   " 조장 ( SAP_LENGTH_VKRME )
        <lfs_fcat>-coltext = TEXT-a16.

      WHEN 'FACTOR      '.   " 조장수 ( SAP_MILLCA_FACTOR )
        <lfs_fcat>-coltext = TEXT-a17.
        <lfs_fcat>-no_out  = 'X'.

      WHEN 'FACTOR_N'.       " 조장수 ( 화면표시용 )
        <lfs_fcat>-coltext = TEXT-a17.
        <lfs_fcat>-do_sum  = 'X'.

      WHEN 'FIXMG       '.   " OS.
        <lfs_fcat>-coltext = TEXT-a18.

      WHEN 'ZGUBUN'.   " 구분
        <lfs_fcat>-coltext = TEXT-a19.

      WHEN 'OUT_WID     '.   " 폭/드럼
        <lfs_fcat>-coltext = TEXT-a20.
        <lfs_fcat>-DECIMALS_O = 0.

      WHEN 'PLAN_DIA    '.   " 약경/드럼
        <lfs_fcat>-coltext = TEXT-a21.
        <lfs_fcat>-DECIMALS_O = 0.

      WHEN 'DR_WEIGHT   '.   " 드럼무게/개
        <lfs_fcat>-coltext = TEXT-a22.
        <lfs_fcat>-DECIMALS_O = 0.

      WHEN 'TOTAL_BRGEW '.   " 총 중량(드럼포함)
        <lfs_fcat>-coltext = TEXT-a23.
        <lfs_fcat>-do_sum  = 'X'.

      WHEN 'BRGEW       '.   " 중량
        <lfs_fcat>-coltext = TEXT-a24.
        <lfs_fcat>-qfieldname = 'GEWEI'.

      WHEN 'GEWEI       '.   " 중량단위
        <lfs_fcat>-coltext = TEXT-a51.

      WHEN 'ROUTE_TXT   '.   " 운송경로명
        <lfs_fcat>-coltext = TEXT-a25.

      WHEN 'WADAT       '.   " 출고요청일
        <lfs_fcat>-coltext = TEXT-a26.

      WHEN 'ERDAT       '.   " 입력일
        <lfs_fcat>-coltext = TEXT-a54.

      WHEN 'CITY1       '.   " 납지
        <lfs_fcat>-coltext = TEXT-a27.

      WHEN 'PACK_GUBUN'.     " 포장구분
        <lfs_fcat>-coltext = TEXT-a55.

      WHEN 'REMARK      '.   " 특기사항
        <lfs_fcat>-coltext = TEXT-a28.

      WHEN 'ZREMARK1'.       " 출하실요청사항
        <lfs_fcat>-coltext = TEXT-a52.

      WHEN 'LGORT       '.   " 저장위치
        <lfs_fcat>-coltext = TEXT-a56.

      WHEN 'VBELN       '.   " 납풉번호
        <lfs_fcat>-coltext = TEXT-a29.

      WHEN 'POSNR       '.   " 항번
        <lfs_fcat>-coltext = TEXT-a30.

      WHEN 'KUNNR       '.   " 납품처
        <lfs_fcat>-coltext = TEXT-a31.
        <lfs_fcat>-no_out  = 'X'.

      WHEN 'KUNAG'.          " 판매처
        <lfs_fcat>-coltext = TEXT-a44.
*        <lfs_fcat>-tech    = 'X'.

      WHEN 'WADAT_IST   '.   " 출고일
        <lfs_fcat>-coltext = TEXT-a32.

      WHEN 'MATNR       '.   " 자재
        <lfs_fcat>-coltext = TEXT-a33.

      WHEN 'TDLNR       '.   " 운송사
        <lfs_fcat>-coltext = TEXT-a34.

      WHEN 'BSTNK       '.   " PO번호
        <lfs_fcat>-coltext = TEXT-a35.

      WHEN 'EXTI1       '.   " 차량번호
        <lfs_fcat>-coltext = TEXT-a36.

      WHEN 'EXTI2       '.   " 운전자명
        <lfs_fcat>-coltext = TEXT-a37.

      WHEN 'TPBEZ       '.   " 전화번호
        <lfs_fcat>-coltext = TEXT-a38.

      WHEN 'SHTYP_TXT   '.   " 선적유형내역
        <lfs_fcat>-coltext = TEXT-a39.

      WHEN 'SHTYP       '.   " 선적유형
        <lfs_fcat>-coltext = TEXT-a40.

** No out
      WHEN 'FIBER       '.   " F 량 계산.
        <lfs_fcat>-coltext = TEXT-a13.
        <lfs_fcat>-tech    = 'X'.

      WHEN 'WERKS       '.   " 플랜트
        <lfs_fcat>-coltext = TEXT-a41.
        <lfs_fcat>-tech    = 'X'.

      WHEN 'VSTEL'.          " 출하지점
        <lfs_fcat>-coltext = TEXT-a42.
        <lfs_fcat>-tech    = 'X'.

      WHEN 'MTART'.          " 제품유형
        <lfs_fcat>-coltext = TEXT-a43.
        <lfs_fcat>-tech    = 'X'.

*      WHEN 'KUNAG'.          " 판매처
*        <lfs_fcat>-coltext = TEXT-a44.
*        <lfs_fcat>-tech    = 'X'.

      WHEN 'IV_DATE'.        " 통문증발행일자
        <lfs_fcat>-coltext = TEXT-a45.
        <lfs_fcat>-tech    = 'X'.

      WHEN 'LFART'.          " 납품유형
        <lfs_fcat>-coltext = TEXT-a46.
        <lfs_fcat>-tech    = 'X'.

      WHEN 'IV_TYPE'.        " 통문유형
        <lfs_fcat>-coltext = TEXT-a47.
        <lfs_fcat>-tech    = 'X'.

      WHEN 'SDABW'.          " 운임톤수
        <lfs_fcat>-coltext = TEXT-a48.
        <lfs_fcat>-tech    = 'X'.

      WHEN 'EXTENSION1'.   " 수령인
        <lfs_fcat>-coltext = TEXT-a49.
        <lfs_fcat>-tech    = 'X'.

      WHEN 'TEL_NUMBER'.   " 수령인 연락처
        <lfs_fcat>-coltext = TEXT-a50.
        <lfs_fcat>-tech    = 'X'.

      WHEN 'NTGEW       '.   " 순중량
        <lfs_fcat>-tech    = 'X'.

      WHEN 'ROUTE'.
        <lfs_fcat>-tech    = 'X'.

    ENDCASE.

    <lfs_fcat>-scrtext_s = <lfs_fcat>-scrtext_m =
    <lfs_fcat>-scrtext_l = <lfs_fcat>-reptext = <lfs_fcat>-coltext.

    <lfs_fcat>-col_opt = 'X'.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_event
*&---------------------------------------------------------------------*
FORM set_event  USING    pi_screen
                         po_grid     TYPE REF TO cl_gui_alv_grid.

**
  CALL METHOD po_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

* Event Handler
  CREATE OBJECT go_event_handler.

*  SET HANDLER go_event_handler->handle_data_changed_finished  FOR po_grid.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_variant
*&---------------------------------------------------------------------*
FORM set_variant  USING    pi_screen
                           ps_variant  TYPE disvariant.

**
  CLEAR: ps_variant.
  ps_variant-report  = sy-repid.
*
  CALL FUNCTION 'LVC_VARIANT_EXISTENCE_CHECK'
    EXPORTING
      i_save        = 'A'
    CHANGING
      cs_variant    = ps_variant
    EXCEPTIONS
      wrong_input   = 1
      not_found     = 2
      program_error = 3
      OTHERS        = 4.

  IF sy-subrc <> 0.
    CLEAR ps_variant-variant.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form alv_first_display
*&---------------------------------------------------------------------*
FORM alv_first_display  USING  pi_screen
                               po_grid     TYPE REF TO cl_gui_alv_grid
                               pt_fcat     TYPE lvc_t_fcat
                               pt_toolbar  TYPE ui_functions
                               pt_sort     TYPE lvc_t_sort
                               ps_layout   TYPE lvc_s_layo
                               ps_variant  TYPE disvariant.

**
  CHECK: pt_fcat[] IS NOT INITIAL.

  CASE pi_screen.
    WHEN '100'.
      CALL METHOD po_grid->set_table_for_first_display
        EXPORTING
          is_layout            = ps_layout
          it_toolbar_excluding = pt_toolbar
          i_save               = 'A'
          is_variant           = ps_variant
        CHANGING
          it_outtab            = gt_list[]
          it_fieldcatalog      = pt_fcat[]
          it_sort              = pt_sort[].

    WHEN OTHERS.
  ENDCASE.

**

ENDFORM.
