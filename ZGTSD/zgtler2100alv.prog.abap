*&---------------------------------------------------------------------*
*& Include          ZGTLER2100ALV
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form create_grid
*&---------------------------------------------------------------------*
FORM create_grid
     USING  pi_screen
            po_main_dock  TYPE REF TO cl_gui_docking_container.

**
  CASE pi_screen.
    WHEN '100'.
      PERFORM create_main_screen_alv   USING  pi_screen
                                              po_main_dock.
  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_main_screen_alv
*&---------------------------------------------------------------------*
FORM create_main_screen_alv
     USING  pi_screen
            po_main_dock  TYPE REF TO cl_gui_docking_container.

**
  IF po_main_dock IS INITIAL.
*   1. Create container.
    PERFORM create_dock_container   USING  po_main_dock.

*   2. Split Container.
    PERFORM split_container_grid    USING  po_main_dock
                                           go_split
                                           go_cont_h
                                           go_cont_i
                                           go_grid_h
                                           go_grid_i.

*   3. Set ALV attributes - Header.
    PERFORM make_alv_attributes     USING  pi_screen
                                           'H'
                                           go_grid_h
                                           gt_fcat_h
                                           gt_toolbar_h
                                           gt_sort_h
                                           gs_layout_h
                                           gs_variant_h .

*   3. Set ALV attributes - Item.
    PERFORM make_alv_attributes     USING  pi_screen
                                           'I'
                                           go_grid_i
                                           gt_fcat_i
                                           gt_toolbar_i
                                           gt_sort_i
                                           gs_layout_i
                                           gs_variant_i .

  ELSE.
    PERFORM refresh_alv             USING: go_grid_h,
                                           go_grid_i.
    PERFORM set_split_cont_height   USING  go_split.

  ENDIF.

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
*& Form split_container_grid
*&---------------------------------------------------------------------*
FORM split_container_grid
     USING    po_main_dock  TYPE REF TO cl_gui_docking_container
              po_split      TYPE REF TO cl_gui_splitter_container
              po_cont_h     TYPE REF TO cl_gui_container
              po_cont_i     TYPE REF TO cl_gui_container
              po_grid_h     TYPE REF TO cl_gui_alv_grid
              po_grid_i     TYPE REF TO cl_gui_alv_grid.

**
* Split.
  CREATE OBJECT po_split
    EXPORTING
      parent  = po_main_dock
      rows    = 2
      columns = 1.

* Set Container 1.
  CALL METHOD po_split->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = po_cont_h.

* Set Container 2.
  CALL METHOD po_split->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = po_cont_i.

* Set Grid 1.
  CREATE OBJECT po_grid_h
    EXPORTING
      i_parent = po_cont_h.

* Set Grid 2.
  CREATE OBJECT po_grid_i
    EXPORTING
      i_parent = po_cont_i.

  PERFORM set_split_cont_height   USING  po_split.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_alv_attributes
*&---------------------------------------------------------------------*
FORM make_alv_attributes  USING    pi_screen
                                   pi_type
                                   po_grid     TYPE REF TO cl_gui_alv_grid
                                   pt_fcat     TYPE lvc_t_fcat
                                   pt_toolbar  TYPE ui_functions
                                   pt_sort     TYPE lvc_t_sort
                                   ps_layout   TYPE lvc_s_layo
                                   ps_variant  TYPE disvariant.

**
* 1. Set Layout
  PERFORM set_alv_layout         USING  pi_screen
                                        pi_type
                                        ps_layout.

* 2. Set Sort.
  PERFORM set_sort_field         USING  pi_screen
                                        pi_type
                                        pt_sort.

* 3. Set Toolbar excluding.
  PERFORM set_excluding_toolbar  USING  pi_screen
                                        pi_type
                                        pt_toolbar.

* 4. Set Fieldcatalog.
  PERFORM set_fieldcatalog       USING  pi_screen
                                        pi_type
                                        pt_fcat.

* 6. Set Search Help.
  PERFORM set_f4                 USING  pi_screen
                                        pi_type
                                        po_grid.

* 6. Set Event.
  PERFORM set_event              USING  pi_screen
                                        pi_type
                                        po_grid.

* 7. Set variant.
  PERFORM set_variant            USING  pi_screen
                                        pi_type
                                        ps_variant.

* 8. Alv display
  PERFORM alv_first_display      USING  pi_screen
                                        pi_type
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
                              pi_type
                              ps_layout  TYPE lvc_s_layo.

**
  CLEAR ps_layout.
  CASE pi_screen.
    WHEN '100'.
      ps_layout = VALUE #( sel_mode   = 'B'
                           zebra      = ' '
                           cwidth_opt = 'X'
                           no_rowmark = 'X' ).
*                           ctab_fname = 'ALV_COL' ).

    WHEN OTHERS.

  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_sort_field
*&---------------------------------------------------------------------*
FORM set_sort_field  USING    pi_screen
                              pi_type
                              pt_sort    TYPE lvc_t_sort.

**
  _clear: pt_sort.
  CASE pi_screen.
    WHEN '100'.
      IF     pi_type = 'H'.
        PERFORM set_sort_field_dtl   USING: pt_sort 'VBELN' 'X' '' ''.

      ELSEIF pi_type = 'I'.
        PERFORM set_sort_field_dtl   USING: pt_sort 'VBELN' 'X' '' 'X',
                                            pt_sort 'POSNR ' 'X' '' ''.

      ENDIF.

    WHEN OTHERS.
  ENDCASE.

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
                                     pi_type
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
                                pi_type
                                pt_fcat    TYPE lvc_t_fcat.

**
  CASE pi_screen.
    WHEN '100'.
      IF     pi_type = 'H'.
        PERFORM get_field_catalog         USING    gt_head[]
                                          CHANGING pt_fcat.
        PERFORM maintain_fieldcatalog_h   USING    pt_fcat.

      ELSEIF pi_type = 'I'.
        PERFORM get_field_catalog         USING    gt_item[]
                                          CHANGING pt_fcat.
        PERFORM maintain_fieldcatalog_i   USING    pt_fcat.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form GET_FIELD_CATALOG
*&---------------------------------------------------------------------*
FORM get_field_catalog  USING    pt_table     TYPE table
                        CHANGING pt_fieldcat  TYPE lvc_t_fcat.

**
  _clear: pt_fieldcat.
  pt_fieldcat = zgtsd_cl_common=>get_field_catalog( it_table = pt_table ).

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form maintain_fieldcatalog_h
*&---------------------------------------------------------------------*
FORM maintain_fieldcatalog_h  USING    pt_fcat    TYPE lvc_t_fcat.

**
  CHECK: pt_fcat[] IS NOT INITIAL.

  IF rb1 = 'X'.
    DATA(lv_edit) = 'X'.
  ELSE.
    CLEAR: lv_edit.
  ENDIF.

  LOOP AT pt_fcat ASSIGNING FIELD-SYMBOL(<lfs_fcat>).

    CLEAR: <lfs_fcat>-tech.

    CASE <lfs_fcat>-fieldname.
      WHEN 'CHECKBOX'.      " Check box
        <lfs_fcat>-coltext  = TEXT-a01.
        <lfs_fcat>-checkbox = 'X'.
        <lfs_fcat>-just     = 'C'.
        <lfs_fcat>-key      = 'X'.
        <lfs_fcat>-edit     = 'X'.

      WHEN 'VBELN     '.    " 납품번호
        <lfs_fcat>-coltext  = TEXT-a02.
        <lfs_fcat>-key      = 'X'.

      WHEN 'VSTEL     '.    " 출하지점/입고지점
        <lfs_fcat>-coltext  = TEXT-a03.

      WHEN 'LFDAT     '.    " 납품일
        <lfs_fcat>-coltext  = TEXT-a04.

      WHEN 'KODAT     '.    " 피킹일
        <lfs_fcat>-coltext  = TEXT-a05.

      WHEN 'ROUTE     '.    " 운송경로
        <lfs_fcat>-coltext  = TEXT-a06.

      WHEN 'KUNNR     '.    " 납품처
        <lfs_fcat>-coltext  = TEXT-a07.

      WHEN 'KUNAG     '.    " 판매처
        <lfs_fcat>-coltext  = TEXT-a08.

      WHEN 'SERKS'.         " 입고 플랜트
        <lfs_fcat>-coltext  = TEXT-a34.
        IF rb2 = 'X'.
          <lfs_fcat>-tech     = 'X'.
        ENDIF.

      WHEN 'SGORT'.         " 입고 저장위치
        <lfs_fcat>-coltext  = TEXT-a09.
        <lfs_fcat>-edit     = lv_edit.
        <lfs_fcat>-f4availabl = 'X'.
        IF rb2 = 'X'.
          <lfs_fcat>-tech     = 'X'.
        ENDIF.

** No out
      WHEN 'WADAT     '.    " 출고일
        <lfs_fcat>-tech     = 'X'.
      WHEN 'WADAT_IST '.    "
        <lfs_fcat>-tech     = 'X'.
      WHEN 'RNAME     '.    " 납품처 명
        <lfs_fcat>-tech     = 'X'.
      WHEN 'GNAME     '.    " 판매처 명
        <lfs_fcat>-tech     = 'X'.
      WHEN 'BOX'.
        <lfs_fcat>-tech     = 'X'.
      WHEN 'LIGHTS'.
        <lfs_fcat>-tech     = 'X'.
      WHEN 'EXPAND'.
        <lfs_fcat>-tech     = 'X'.
      WHEN 'ZCSFG'.
        <lfs_fcat>-tech     = 'X'.

    ENDCASE.

    <lfs_fcat>-scrtext_s = <lfs_fcat>-scrtext_m =
    <lfs_fcat>-scrtext_l = <lfs_fcat>-reptext = <lfs_fcat>-coltext.

    <lfs_fcat>-col_opt = 'X'.

  ENDLOOP.

**


ENDFORM.

*&---------------------------------------------------------------------*
*& Form MAINTAIN_FIELDCATALOG_I
*&---------------------------------------------------------------------*
FORM maintain_fieldcatalog_i  USING    pt_fcat    TYPE lvc_t_fcat.

**
  CHECK: pt_fcat[] IS NOT INITIAL.

  IF rb1 = 'X'.
    DATA(lv_edit) = 'X'.
  ELSE.
    CLEAR: lv_edit.
  ENDIF.

  LOOP AT pt_fcat ASSIGNING FIELD-SYMBOL(<lfs_fcat>).

    CLEAR: <lfs_fcat>-tech.

    CASE <lfs_fcat>-fieldname.
      WHEN 'VBELN   '.    "납품번호
        <lfs_fcat>-coltext  = TEXT-a02.
        <lfs_fcat>-key      = 'X'.

      WHEN 'UECHA   '.    "납품항번
        <lfs_fcat>-coltext  = TEXT-a10.
        <lfs_fcat>-key      = 'X'.

      WHEN 'POSNR   '.    "항번ITEM
        <lfs_fcat>-coltext  = TEXT-a11.
        <lfs_fcat>-key      = 'X'.

      WHEN 'ZMBLNR  '.    "자재문서번호
        <lfs_fcat>-coltext   = TEXT-a12.
        <lfs_fcat>-emphasize = 'C500'.
        IF rb2 NE 'X'.
          <lfs_fcat>-tech     = 'X'.
        ENDIF.

      WHEN 'MATNR   '.    "자재번호
        <lfs_fcat>-coltext  = TEXT-a13.
      WHEN 'MAKTX   '.    "자재품명
        <lfs_fcat>-coltext  = TEXT-a14.
      WHEN 'CHARG   '.    "뱃치번호
        <lfs_fcat>-coltext  = TEXT-a15.
      WHEN 'KDAUF   '.    "ZCS 납품번호
        <lfs_fcat>-coltext  = TEXT-a16.
      WHEN 'KDPOS   '.    "ZCS 납품항번
        <lfs_fcat>-coltext  = TEXT-a17.
      WHEN 'WERKS   '.    "플랜트
        <lfs_fcat>-coltext  = TEXT-a18.
      WHEN 'LGORT   '.    "저장위치
        <lfs_fcat>-coltext  = TEXT-a19.
      WHEN 'MEINS   '.    "기본단위
        <lfs_fcat>-coltext  = TEXT-a20.
      WHEN 'LFIMG   '.    "납품수량
        <lfs_fcat>-coltext   = TEXT-a21.
        <lfs_fcat>-just      = 'R'.
        <lfs_fcat>-emphasize = 'C300'.
        <lfs_fcat>-do_sum    = 'X'.
      WHEN 'MENGE   '.    "Picking 수량
        <lfs_fcat>-coltext  = TEXT-a22.
        <lfs_fcat>-just     = 'R'.
        <lfs_fcat>-emphasize = 'C300'.
        <lfs_fcat>-do_sum    = 'X'.
      WHEN 'VRKME   '.    "판매단위
        <lfs_fcat>-coltext  = TEXT-a23.
      WHEN 'VGBEL   '.    "영업문서
        <lfs_fcat>-coltext  = TEXT-a24.
      WHEN 'VGPOS   '.    "영업ITEM
        <lfs_fcat>-coltext  = TEXT-a25.
      WHEN 'NTGEW   '.    "순중량
        <lfs_fcat>-coltext  = TEXT-a26.
        <lfs_fcat>-just     = 'R'.
        <lfs_fcat>-emphasize = 'C300'.
        <lfs_fcat>-do_sum    = 'X'.
      WHEN 'BRGEW   '.    "총중량
        <lfs_fcat>-coltext  = TEXT-a27.
        <lfs_fcat>-just     = 'R'.
        <lfs_fcat>-emphasize = 'C300'.
        <lfs_fcat>-do_sum    = 'X'.
      WHEN 'GEWEI   '.    "중량단위
        <lfs_fcat>-coltext  = TEXT-a28.
      WHEN 'VOLUM   '.    "볼륨
        <lfs_fcat>-coltext  = TEXT-a29.
        <lfs_fcat>-just     = 'R'.
      WHEN 'VOLEH   '.    "부피단위
        <lfs_fcat>-coltext  = TEXT-a30.
      WHEN 'COLOR   '.    "색상
        <lfs_fcat>-coltext  = TEXT-a31.
      WHEN 'JOJAN   '.    "조장
        <lfs_fcat>-coltext  = TEXT-a32.
        <lfs_fcat>-just     = 'R'.
        <lfs_fcat>-emphasize = 'C300'.
        <lfs_fcat>-do_sum    = 'X'.
      WHEN 'JOJSU   '.    "조장수
        <lfs_fcat>-coltext  = TEXT-a33.
        <lfs_fcat>-just     = 'R'.
        <lfs_fcat>-emphasize = 'C300'.
        <lfs_fcat>-do_sum    = 'X'.

** No out
      WHEN 'LFDAT   '.    "납품생성일
        <lfs_fcat>-tech     = 'X'.
      WHEN 'KODAT   '.    "피킹일
        <lfs_fcat>-tech     = 'X'.
      WHEN 'WADAT   '.    "출고일
        <lfs_fcat>-tech     = 'X'.
      WHEN 'ROUTE   '.    "Router
        <lfs_fcat>-tech     = 'X'.
      WHEN 'KUNNR   '.    "납품처
        <lfs_fcat>-tech     = 'X'.
      WHEN 'KUNAG   '.    "판매처
        <lfs_fcat>-tech     = 'X'.
      WHEN 'ABLAD   '.    "하역지점
        <lfs_fcat>-tech     = 'X'.
      WHEN 'BOX     '.
        <lfs_fcat>-tech     = 'X'.
      WHEN 'LIGHTS  '.
        <lfs_fcat>-tech     = 'X'.
      WHEN 'EXPAND  '.
        <lfs_fcat>-tech     = 'X'.
      WHEN 'ZCSFG   '.     "ZCS Order N개 여부
        <lfs_fcat>-tech     = 'X'.
      WHEN 'CHECKBOX'.    "Check box
        <lfs_fcat>-tech     = 'X'.

    ENDCASE.

    <lfs_fcat>-scrtext_s = <lfs_fcat>-scrtext_m =
    <lfs_fcat>-scrtext_l = <lfs_fcat>-reptext = <lfs_fcat>-coltext.

    <lfs_fcat>-col_opt = 'X'.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_f4
*&---------------------------------------------------------------------*
FORM set_f4  USING    pi_screen
                      pi_type
                      po_grid     TYPE REF TO cl_gui_alv_grid.

**
  CASE pi_screen.
    WHEN '100'.
      IF     pi_type = 'H'.
        DATA(lt_f4) = VALUE lvc_t_f4( ( fieldname = 'SGORT'
                                        register  = 'X' ) ).

      ELSEIF pi_type = 'I'.
      ENDIF.

      IF lt_f4[] IS NOT INITIAL.
        CALL METHOD po_grid->register_f4_for_fields
          EXPORTING
            it_f4 = lt_f4[].

      ENDIF.

    WHEN OTHERS.
  ENDCASE.

**
  FREE: lt_f4.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_event
*&---------------------------------------------------------------------*
FORM set_event  USING    pi_screen
                         pi_type
                         po_grid     TYPE REF TO cl_gui_alv_grid.

**
  CALL METHOD po_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

* Event Handler
  CREATE OBJECT go_event_handler.

  IF pi_type = 'H'.
    SET HANDLER go_event_handler->handle_data_changed  FOR po_grid.
    SET HANDLER go_event_handler->handle_on_f4         FOR po_grid.

    CALL METHOD po_grid->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.                " Ready for Input Status
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_variant
*&---------------------------------------------------------------------*
FORM set_variant  USING    pi_screen
                           pi_type
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
                               pi_type
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
      IF     pi_type = 'H'.
        CALL METHOD po_grid->set_table_for_first_display
          EXPORTING
            is_layout            = ps_layout
            it_toolbar_excluding = pt_toolbar
            i_save               = 'A'
            is_variant           = ps_variant
          CHANGING
            it_outtab            = gt_head[]
            it_fieldcatalog      = pt_fcat[]
            it_sort              = pt_sort[].

      ELSEIF pi_type = 'I'.
        CALL METHOD po_grid->set_table_for_first_display
          EXPORTING
            is_layout            = ps_layout
            it_toolbar_excluding = pt_toolbar
            i_save               = 'A'
            is_variant           = ps_variant
          CHANGING
            it_outtab            = gt_item[]
            it_fieldcatalog      = pt_fcat[]
            it_sort              = pt_sort[].

      ENDIF.

    WHEN OTHERS.

  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form handle_on_f4
*&---------------------------------------------------------------------*
FORM handle_on_f4  USING    pi_fieldname
                            pi_fieldvalue
                            ps_row_no      TYPE lvc_s_roid
                            po_event_data  TYPE REF TO cl_alv_event_data
                            pt_bad_cells   TYPE lvc_t_modi
                            pi_display.

**
* STANDARD F4(Search Help)는 무시
  po_event_data->m_event_handled = abap_true.

  CASE pi_fieldname.
    WHEN 'SGORT'.
      PERFORM f4_sgort   USING  ps_row_no-row_id
                                po_event_data
                                pi_fieldname.

  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f4_sgort
*&---------------------------------------------------------------------*
FORM f4_sgort  USING    pi_index
                        po_event_data  TYPE REF TO cl_alv_event_data
                        pi_fieldname.

  DATA: lv_lgort  TYPE lgort_d.

  FIELD-SYMBOLS: <lfs_modi> TYPE lvc_t_modi.

**
  CHECK: pi_index IS NOT INITIAL.

  DATA(lv_werks) = VALUE #( gt_head[ pi_index ]-serks
                            OPTIONAL ).

  CLEAR: lv_lgort.
  PERFORM get_lgort_from_f4  USING    lv_werks
                             CHANGING lv_lgort.

  IF lv_lgort IS NOT INITIAL.

    ASSIGN po_event_data->m_data->* TO <lfs_modi>.

    APPEND VALUE #( row_id    = pi_index
                    fieldname = pi_fieldname
                    value     = lv_lgort
                   ) TO <lfs_modi>.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form data_changed
*&---------------------------------------------------------------------*
FORM data_changed  USING    pr_data_changed  TYPE REF TO cl_alv_changed_data_protocol.

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
*& Form set_split_cont_height
*&---------------------------------------------------------------------*
FORM set_split_cont_height   USING  po_split
                                    TYPE REF TO cl_gui_splitter_container.

**
  CHECK: po_split IS NOT INITIAL.

  IF gt_item[] IS INITIAL.
    CALL METHOD po_split->set_row_height
      EXPORTING
        id     = 1
        height = 100.
  ELSE.
    CALL METHOD po_split->set_row_height
      EXPORTING
        id     = 1
        height = 50.
  ENDIF.

**

ENDFORM.
