*&---------------------------------------------------------------------*
*& Include          ZGTSDR1260ALV
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form create_grid
*&---------------------------------------------------------------------*
FORM create_grid  USING  pi_screen
                         po_docking  TYPE REF TO cl_gui_docking_container.

**
  IF po_docking IS INITIAL.
*   1. Create container.
    PERFORM create_dock_container   USING  po_docking
                                           go_grid.

*   2. Set ALV attributes - Header.
    PERFORM make_alv_attributes     USING  pi_screen
                                           go_grid
                                           gt_fcat
                                           gt_toolbar
                                           gt_sort
                                           gs_layout
                                           gs_variant.

  ELSE.
    PERFORM refresh_alv             USING: go_grid.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form refresh_alv
*&---------------------------------------------------------------------*
FORM refresh_alv  USING    po_grid   TYPE REF TO cl_gui_alv_grid.

  DATA: ls_scroll  TYPE lvc_s_stbl.

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
*& Form create_dock_container
*&---------------------------------------------------------------------*
FORM create_dock_container  USING  po_container
                                   TYPE REF TO cl_gui_docking_container
                                   po_grid
                                   TYPE REF TO cl_gui_alv_grid.

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

  CREATE OBJECT po_grid
    EXPORTING
      i_parent = po_container.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_alv_attributes
*&---------------------------------------------------------------------*
FORM make_alv_attributes  USING    pi_screen
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
*

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
                           zebra      = 'X'
                           cwidth_opt = 'X'
                           no_rowmark = 'X'
                           ctab_fname = 'COLOR' ).

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
*  PERFORM set_sort_field_dtl   USING: pt_sort 'VBELN' 'X' '' ''.

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

**
  CASE pi_screen.
    WHEN '100'.
      PERFORM get_field_catalog         USING    gt_list[]
                                        CHANGING pt_fcat.

      PERFORM maintain_fieldcatalog     USING    pt_fcat.

    WHEN OTHERS.
  ENDCASE.

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

**

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
      WHEN 'CHECK    '.    " 선택
        <lfs_fcat>-col_pos  = 1.
        <lfs_fcat>-coltext  = TEXT-a01.
        <lfs_fcat>-checkbox = 'X'.
        <lfs_fcat>-just     = 'C'.
        <lfs_fcat>-key      = 'X'.
        <lfs_fcat>-edit     = 'X'.

      WHEN 'STAT     '.    " 상태
        <lfs_fcat>-col_pos  = 2.
        <lfs_fcat>-coltext  = TEXT-a02.
        <lfs_fcat>-just     = 'C'.
        <lfs_fcat>-icon     = 'X'.
        <lfs_fcat>-key      = 'X'.

      WHEN 'NEWCHK   '.    " 신규여부
        <lfs_fcat>-col_pos  = 3.
        <lfs_fcat>-coltext  = TEXT-a03.
        <lfs_fcat>-just     = 'C'.
        <lfs_fcat>-icon     = 'X'.
        <lfs_fcat>-key      = 'X'.

      WHEN 'KUNNR    '.    " 고객코드
        <lfs_fcat>-col_pos  = 4.
        <lfs_fcat>-coltext  = TEXT-a04.
        <lfs_fcat>-key      = 'X'.

      WHEN 'NAME1    '.    " 고객명
        <lfs_fcat>-col_pos  = 5.
        <lfs_fcat>-coltext  = TEXT-a05.
        <lfs_fcat>-key      = 'X'.

      WHEN 'PARTNER  '.    " BP 코드
        <lfs_fcat>-col_pos  = 6.
        <lfs_fcat>-coltext  = TEXT-a06.
        <lfs_fcat>-key      = 'X'.

      WHEN 'RLTYP    '.    " BP Role
        <lfs_fcat>-col_pos  = 7.
        <lfs_fcat>-coltext  = TEXT-a07.

      WHEN 'VKORG    '.    " 영업조직
        <lfs_fcat>-col_pos  = 8.
        <lfs_fcat>-coltext  = TEXT-a08.

      WHEN 'VTWEG    '.    " 유통경로
        <lfs_fcat>-col_pos  = 9.
        <lfs_fcat>-coltext  = TEXT-a09.

      WHEN 'SPART    '.    " 제품군
        <lfs_fcat>-col_pos  = 10.
        <lfs_fcat>-coltext  = TEXT-a10.

      WHEN 'BZIRK    '.    " 영업지역
        <lfs_fcat>-col_pos  = 11.
        <lfs_fcat>-coltext  = TEXT-a11.

      WHEN 'VKBUR    '.    " 사업장
        <lfs_fcat>-col_pos  = 12.
        <lfs_fcat>-coltext  = TEXT-a12.

      WHEN 'VKGRP    '.    " 영업그룹
        <lfs_fcat>-col_pos  = 13.
        <lfs_fcat>-coltext  = TEXT-a13.

      WHEN 'KDGRP    '.    " 고객그룹
        <lfs_fcat>-col_pos  = 14.
        <lfs_fcat>-coltext  = TEXT-a14.

      WHEN 'WAERS    '.    " 통화
        <lfs_fcat>-col_pos  = 15.
        <lfs_fcat>-coltext  = TEXT-a15.

      WHEN 'KURST    '.    " 환율유형
        <lfs_fcat>-col_pos  = 16.
        <lfs_fcat>-coltext  = TEXT-a16.

      WHEN 'KONDA    '.    " 기납증발행여부
        <lfs_fcat>-col_pos  = 17.
        <lfs_fcat>-coltext  = TEXT-a17.

      WHEN 'KALKS    '.    " 고객가격절차
        <lfs_fcat>-col_pos  = 18.
        <lfs_fcat>-coltext  = TEXT-a18.

      WHEN 'PLTYP    '.    " 가격리스트유형
        <lfs_fcat>-col_pos  = 19.
        <lfs_fcat>-coltext  = TEXT-a19.

      WHEN 'VERSG    '.    " 고객 통계 그룹
        <lfs_fcat>-col_pos  = 20.
        <lfs_fcat>-coltext  = TEXT-a20.

      WHEN 'LPRIO    '.    " 납품우선순위
        <lfs_fcat>-col_pos  = 21.
        <lfs_fcat>-coltext  = TEXT-a21.

      WHEN 'KZAZU    '.    " 오더조합
        <lfs_fcat>-col_pos  = 22.
        <lfs_fcat>-coltext  = TEXT-a22.

      WHEN 'VSBED    '.    " 출하조건
        <lfs_fcat>-col_pos  = 23.
        <lfs_fcat>-coltext  = TEXT-a23.

      WHEN 'VWERK    '.    " 납품플랜트
        <lfs_fcat>-col_pos  = 24.
        <lfs_fcat>-coltext  = TEXT-a24.

      WHEN 'PODKZ    '.    " POD 관련
        <lfs_fcat>-col_pos  = 25.
        <lfs_fcat>-coltext  = TEXT-a25.

      WHEN 'PODTG    '.    " POD 타임프레임
        <lfs_fcat>-col_pos  = 26.
        <lfs_fcat>-coltext  = TEXT-a26.

      WHEN 'AUTLF    '.    " 일괄납품
        <lfs_fcat>-col_pos  = 27.
        <lfs_fcat>-coltext  = TEXT-a27.

      WHEN 'KZTLF    '.    " 품목별 분할납품
        <lfs_fcat>-col_pos  = 28.
        <lfs_fcat>-coltext  = TEXT-a28.

      WHEN 'ANTLF    '.    " 최대분할납품
        <lfs_fcat>-col_pos  = 29.
        <lfs_fcat>-coltext  = TEXT-a29.

      WHEN 'UEBTK    '.    " 무제한 초과납품
        <lfs_fcat>-col_pos  = 30.
        <lfs_fcat>-coltext  = TEXT-a30.

      WHEN 'UNTTO    '.    " 미달납품 허용치
        <lfs_fcat>-col_pos  = 31.
        <lfs_fcat>-coltext  = TEXT-a31.

      WHEN 'UEBTO    '.    " 초과납품 허용치
        <lfs_fcat>-col_pos  = 32.
        <lfs_fcat>-coltext  = TEXT-a32.

      WHEN 'INCO1    '.    " 인도조건1
        <lfs_fcat>-col_pos  = 33.
        <lfs_fcat>-coltext  = TEXT-a33.

      WHEN 'INCO2    '.    " 인도조건2
        <lfs_fcat>-col_pos  = 34.
        <lfs_fcat>-coltext  = TEXT-a34.

      WHEN 'ZTERM    '.    " 지급조건
        <lfs_fcat>-col_pos  = 35.
        <lfs_fcat>-coltext  = TEXT-a35.

      WHEN 'KTGRD    '.    " 계정지정그룹
        <lfs_fcat>-col_pos  = 36.
        <lfs_fcat>-coltext  = TEXT-a36.

      WHEN 'TAXKD    '.    " 세금분류
        <lfs_fcat>-col_pos  = 37.
        <lfs_fcat>-coltext  = TEXT-a37.

      WHEN 'KVGR1    '.    " 고객그룹1
        <lfs_fcat>-col_pos  = 38.
        <lfs_fcat>-coltext  = TEXT-a38.

      WHEN 'KVGR2    '.    " 고객그룹2
        <lfs_fcat>-col_pos  = 39.
        <lfs_fcat>-coltext  = TEXT-a39.

      WHEN 'KVGR3    '.    " 고객그룹3
        <lfs_fcat>-col_pos  = 40.
        <lfs_fcat>-coltext  = TEXT-a40.

      WHEN 'KVGR4    '.    " 고객그룹4
        <lfs_fcat>-col_pos  = 41.
        <lfs_fcat>-coltext  = TEXT-a41.

      WHEN 'KVGR5    '.    " 고객그룹5
        <lfs_fcat>-col_pos  = 42.
        <lfs_fcat>-coltext  = TEXT-a42.

      WHEN 'J_1NBOESL'.    " Exchange Key
        <lfs_fcat>-col_pos  = 43.
        <lfs_fcat>-coltext  = TEXT-a43.

      WHEN 'PARVW    '.    " 파트너기능
        <lfs_fcat>-col_pos  = 44.
        <lfs_fcat>-coltext  = TEXT-a44.

      WHEN 'KUNN2    '.    " 번호
        <lfs_fcat>-col_pos  = 45.
        <lfs_fcat>-coltext  = TEXT-a45.

      WHEN 'MESSAGE  '.    " Message
        <lfs_fcat>-col_pos  = 46.
        <lfs_fcat>-coltext  = TEXT-a46.

      WHEN OTHERS.
        <lfs_fcat>-tech     = 'X'.

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


  SET HANDLER go_event_handler->handle_data_changed  FOR po_grid.

  CALL METHOD po_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.                " Ready for Input Status


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
