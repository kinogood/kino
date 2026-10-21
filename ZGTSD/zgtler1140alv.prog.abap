*&---------------------------------------------------------------------*
*& Include          ZGTLER1140ALV
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form create_alv_grid
*&---------------------------------------------------------------------*
FORM create_alv_grid
       USING  pi_screen
              po_container  TYPE REF TO cl_gui_custom_container
*              po_container  TYPE REF TO cl_gui_docking_container
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
*    PERFORM create_dock_container   USING  po_container.

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
*& Form create_dock_container
*&---------------------------------------------------------------------*
FORM create_dock_container  USING  po_container
                                   TYPE REF TO cl_gui_docking_container.

**
  CREATE OBJECT po_container
    EXPORTING
      parent                      = cl_gui_container=>default_screen
      repid                       = sy-repid
      dynnr                       = sy-dynnr
      side                        = cl_gui_docking_container=>dock_at_top
      extension                   = 3000
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_grid
*&---------------------------------------------------------------------*
FORM create_grid  USING  po_container
*                            TYPE REF TO cl_gui_docking_container
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
      ps_layout = VALUE #( sel_mode   = 'B'
                           zebra      = ' '
                           cwidth_opt = 'X'
                           no_rowmark = 'X'
                           ctab_fname = 'ALV_COL' ).

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
*  PERFORM set_sort_field_dtl   USING: pt_sort 'KUNNR' 'X' '' ''.

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
*  _clear: lt_fieldcat.
*  PERFORM get_field_catalog       USING    gt_out[]
*                                  CHANGING lt_fieldcat.
*  CHECK: lt_fieldcat[] IS NOT INITIAL.

  DATA(ls_0007) = VALUE #( gt_0007[ iv_type = gv_iv_type ] OPTIONAL ).
  IF ls_0007 IS NOT INITIAL.

    CASE ls_0007-disp.
      WHEN 'SD'.
        PERFORM set_field_catalog_sd    USING  pi_screen
                                               pt_fcat
                                               ls_0007-disp.

      WHEN 'MM'.
        PERFORM set_field_catalog_mm    USING  pi_screen
                                               pt_fcat
                                               ls_0007-disp.

      WHEN 'FI'.
        PERFORM set_field_catalog_fi    USING  pi_screen
                                               pt_fcat
                                               ls_0007-disp.

      WHEN 'ETC'.
        PERFORM set_field_catalog_etc   USING  pi_screen
                                               pt_fcat
                                               ls_0007-disp.

    ENDCASE.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_field_catalog
*&---------------------------------------------------------------------*
*FORM get_field_catalog  USING    pt_table     TYPE table
*                        CHANGING pt_fieldcat  TYPE lvc_t_fcat.
*
***
*  _clear: pt_fieldcat.
*  pt_fieldcat = zgtsd_cl_common=>get_field_catalog( it_table = pt_table
*                                                    iv_cells = 'X'
*                                                    iv_cellc = 'X' ).
*
*ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_field_catalog_sd
*&---------------------------------------------------------------------*
FORM set_field_catalog_sd  USING    pi_screen
                                    pt_fcat      TYPE lvc_t_fcat
                                    pi_disp.

**
  _clear: pt_fcat.
  PERFORM set_field_catalog_detail
          TABLES  pt_fcat
*                Screen No / Disp / Fieldname / Just / OutputLen / ColText
          USING: pi_screen  pi_disp  'CHK'          'L'  '1'   ' ' ,
                 pi_screen  pi_disp  'WADAT'        'L'  '10'  '출고일자',
                 pi_screen  pi_disp  'NAME1'        'L'  '30'  '납품처명',
                 pi_screen  pi_disp  'IV_NO'        'L'  '10'  '거래명세서 번호',
                 pi_screen  pi_disp  'ARKTX'        'L'  '40'  '자재내역',
                 pi_screen  pi_disp  'COLOR'        'L'  '5'   '색상',
                 pi_screen  pi_disp  'GJOSA'        'R'  '18'  '납품수량',
                 pi_screen  pi_disp  'JOJAN'        'R'  '5'   '조장',
                 pi_screen  pi_disp  'JOJSU'        'R'  '13'  '조장수',
                 pi_screen  pi_disp  'VGBEL'        'L'  '10'  '주문번호',
                 pi_screen  pi_disp  'VGPOS'        'L'  '6'   '품목',
                 pi_screen  pi_disp  'PACKC'        'L'  '8'   '포장재유형',
                 pi_screen  pi_disp  'PACKG_T'      'L'  '10'  '포장재',
                 pi_screen  pi_disp  'OUT_YN'       'L'  '8'   '통문유무',
                 pi_screen  pi_disp  'IV_TYPE'      'L'  '8'   '통문유형',
                 pi_screen  pi_disp  'IV_TDES'      'L'  '10'  '통문유형명',
                 pi_screen  pi_disp  'VBELN'        'L'  '10'  '납품번호',
                 pi_screen  pi_disp  'POSNR'        'L'  '6'   '품목',
                 pi_screen  pi_disp  'TKNUM'        'L'  '12'  '선적번호',
                 pi_screen  pi_disp  'MATNR'        'L'  '18'  '자재',
                 pi_screen  pi_disp  'VRKME'        'L'  '3'   '단위',
                 pi_screen  pi_disp  'LFIMG'        'R'  '18'  '출고확정수량',
                 pi_screen  pi_disp  'TDLNR_T'      'L'  '12'  '운송사',
                 pi_screen  pi_disp  'TRUCK_NO'     'L'  '12'  '차량번호',
                 pi_screen  pi_disp  'DRIVER_NM'    'L'  '15'  '운송기사',
                 pi_screen  pi_disp  'DRIVER_TELNO' 'L'  '15'  '운전자전화번호',
                 pi_screen  pi_disp  'KUNNR'        'L'  '10'  '납품처코드',
                 pi_screen  pi_disp  'IV_DATE'      'L'  '10'  '통문번호 발행일',
                 pi_screen  pi_disp  'WBSTA'        'C'  '10'  '출고전기'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_field_catalog_detail
*&---------------------------------------------------------------------*
FORM set_field_catalog_detail  TABLES   pt_fcat TYPE lvc_t_fcat
                               USING    pi_screen
                                        pi_disp
                                        pi_fieldname
                                        pi_just
                                        pi_outputlen
                                        pi_desc.

  DATA: ls_fcat  TYPE lvc_s_fcat.

**
  gv_pos = gv_pos + 1.

  CLEAR: ls_fcat.
  ls_fcat-col_pos   = gv_pos.
  ls_fcat-fieldname = pi_fieldname.
  ls_fcat-just      = pi_just.
  ls_fcat-outputlen = pi_outputlen.
  ls_fcat-coltext   = pi_desc.
  ls_fcat-scrtext_s = pi_desc.
  ls_fcat-scrtext_m = pi_desc.
  ls_fcat-scrtext_l = pi_desc.
  ls_fcat-reptext   = pi_desc.

  CASE pi_screen.
    WHEN '100'.
      ls_fcat-tabname   = 'GT_OUT'.

* Key Field / Check Box / edit
      IF ls_fcat-fieldname = 'CHK'.
        ls_fcat-key      = 'X'.
        ls_fcat-checkbox = 'X'.
        ls_fcat-edit     = 'X'.
      ENDIF.

** Fix column
*      IF ls_fcat-fieldname = 'CHK' OR
*         ls_fcat-fieldname = 'IV_NO'.
*        ls_fcat-fix_column = 'X'.
*      ENDIF.

* Color Set
      IF ls_fcat-fieldname = 'IV_NO'.
        ls_fcat-emphasize = 'C410'.
      ENDIF.

* No Zero
      IF ls_fcat-fieldname = 'MATNR' OR
         ls_fcat-fieldname = 'KUNNR' OR
         ls_fcat-fieldname = 'GJOSA' OR
         ls_fcat-fieldname = 'LFIMG' .
        ls_fcat-no_zero = 'X'.
      ENDIF.

* Convert Text
      IF ls_fcat-fieldname = 'MTR_UNIT'.
        ls_fcat-convexit = 'CUNIT'.
      ENDIF.

* Qfield
      CASE pi_disp.
        WHEN 'SD' .
          IF ls_fcat-fieldname = 'GJOSA' OR
             ls_fcat-fieldname = 'LFIMG' .
            ls_fcat-qfieldname ='VRKME'.
          ENDIF.

        WHEN 'MM'.
          IF ls_fcat-fieldname = 'LFIMG' .
            ls_fcat-qfieldname ='MTR_UNIT'.
          ENDIF.

        WHEN 'FI'.
          IF ls_fcat-fieldname = 'CHK'.
            ls_fcat-emphasize = 'C301'.
          ENDIF.

          IF ls_fcat-fieldname = 'LFIMG' .
            ls_fcat-qfieldname ='MTR_UNIT'.
          ENDIF.

          IF ls_fcat-fieldname = 'DMBTR'.
            ls_fcat-currency  = 'KRW'.
          ENDIF.

        WHEN 'ETC'.
          IF ls_fcat-fieldname = 'LFIMG' .
            ls_fcat-qfieldname ='MTR_UNIT'.
          ENDIF.

          IF ls_fcat-fieldname = 'DMBTR'.
            ls_fcat-currency  = 'KRW'.
          ENDIF.

      ENDCASE.

    WHEN OTHERS.

  ENDCASE.

  APPEND ls_fcat TO pt_fcat.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_field_catalog_mm
*&---------------------------------------------------------------------*
FORM set_field_catalog_mm  USING    pi_screen
                                    pt_fcat      TYPE lvc_t_fcat
                                    pi_disp.

**
  _clear: pt_fcat.
  PERFORM set_field_catalog_detail
          TABLES  pt_fcat
*                Screen No / Disp / Fieldname / Just / OutputLen / ColText
          USING: pi_screen  pi_disp  'CHK'          'L'  '1'   ' ' ,
                 pi_screen  pi_disp  'IV_NO'        'L'  '10'  '통문번호',
                 pi_screen  pi_disp  'OUT_YN'       'L'  '8'   '통문유무',
                 pi_screen  pi_disp  'IV_TDES'      'L'  '10'  '통문유형명',
                 pi_screen  pi_disp  'MBLNR'        'L'  '10'  '자재문서',
                 pi_screen  pi_disp  'ZEILE'        'L'  '4'   'ITEM',
                 pi_screen  pi_disp  'MATNR'        'L'  '18'  '자재',
                 pi_screen  pi_disp  'MAKTX'        'L'  '40'  '품명:규격',
                 pi_screen  pi_disp  'LFIMG'        'R'  '18'  '수량',
                 pi_screen  pi_disp  'MTR_UNIT'     'L'  '4'   '단위'.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_field_catalog_fi
*&---------------------------------------------------------------------*
FORM set_field_catalog_fi  USING    pi_screen
                                    pt_fcat      TYPE lvc_t_fcat
                                    pi_disp.

**
  _clear: pt_fcat.
  PERFORM set_field_catalog_detail
          TABLES  pt_fcat
*                Screen No / Disp / Fieldname / Just / OutputLen / ColText
          USING: pi_screen  pi_disp  'CHK'          'L'  '1'   ' ' ,
                 pi_screen  pi_disp  'IV_NO'        'L'  '10'  '거래명세서',
                 pi_screen  pi_disp  'OUT_YN'       'L'  '8'   '통문유무',
                 pi_screen  pi_disp  'IV_TDES'      'L'  '10'  '통문유형명',
                 pi_screen  pi_disp  'ASSET_NO'     'L'  '12'  '자산번호',
                 pi_screen  pi_disp  'KUNNR'        'L'  '10'  '거래처',
                 pi_screen  pi_disp  'NAME1'        'L'  '15'  '거래처명',
                 pi_screen  pi_disp  'PERNR'        'L'  '8'   '사원번호',
                 pi_screen  pi_disp  'ENAME'        'L'  '12'  '요청사원',
                 pi_screen  pi_disp  'ORGTX'        'L'  '25'  '요청부서',
                 pi_screen  pi_disp  'ASSET_NM'     'L'  '20'  '자산명칭',
                 pi_screen  pi_disp  'ASSET_SPEC'   'L'  '20'  '규격/용도',
                 pi_screen  pi_disp  'LFIMG'        'R'  '18'  '수량',
                 pi_screen  pi_disp  'DMBTR'        'R'  '13'  '장부가액',
                 pi_screen  pi_disp  'ASSET_ETC'    'L'  '50'  '기타'.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_field_catalog_etc
*&---------------------------------------------------------------------*
FORM set_field_catalog_etc  USING    pi_screen
                                     pt_fcat      TYPE lvc_t_fcat
                                     pi_disp.

**
  _clear: pt_fcat.
  PERFORM set_field_catalog_detail
          TABLES  pt_fcat
*                Screen No / Disp / Fieldname / Just / OutputLen / ColText
          USING: pi_screen  pi_disp  'CHK'          'L'  '1'   ' ' ,
                 pi_screen  pi_disp  'IV_NO'        'L'  '10'  '거래명세서',
                 pi_screen  pi_disp  'OUT_YN'       'L'  '8'   '통문유무',
                 pi_screen  pi_disp  'IV_TDES'      'L'  '10'  '통문유형명',
                 pi_screen  pi_disp  'WERKS'        'L'  '5'   'PLANT',
                 pi_screen  pi_disp  'WERKS_T'      'L'  '10'  'PLANT명',
                 pi_screen  pi_disp  'KUNNR'        'L'  '10'  '거래처',
                 pi_screen  pi_disp  'NAME1'        'L'  '15'  '거래처명',
                 pi_screen  pi_disp  'PERNR'        'L'  '8'   '사원번호',
                 pi_screen  pi_disp  'ENAME'        'L'  '12'  '요청사원',
                 pi_screen  pi_disp  'ORGTX'        'L'  '25'  '요청부서',
                 pi_screen  pi_disp  'MAKTX'        'L'  '40'  '품명:규격',
                 pi_screen  pi_disp  'LFIMG'        'R'  '18'  '수량',
                 pi_screen  pi_disp  'MTR_UNIT'     'L'  '10'  '단위',
                 pi_screen  pi_disp  'DMBTR'        'R'  '13'  '현지통화금액'.

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

  SET HANDLER go_event_handler->handle_data_changed_finished  FOR po_grid.

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

* 통문유형별 레이아웃 지정 by J.Y.Lee 12/21/2011 C20111215_16791
  DATA(lv_iv_type) = VALUE #( gt_out[ 1 ]-iv_type OPTIONAL ).
  IF lv_iv_type IS NOT INITIAL.
    CONCATENATE '/' lv_iv_type INTO ps_variant-variant.
  ENDIF.

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
          it_outtab            = gt_out[]
          it_fieldcatalog      = pt_fcat[]
          it_sort              = pt_sort[].

    WHEN OTHERS.
  ENDCASE.

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
