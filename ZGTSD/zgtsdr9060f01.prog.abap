*&---------------------------------------------------------------------*
*& Include          ZGTSDR9060F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form screen_output_1000
*&---------------------------------------------------------------------*
*& Screen 1000 출력 정보 제어
*&---------------------------------------------------------------------*
FORM screen_output_1000 .

  LOOP AT SCREEN.
*-- 필수필드 정보 구성
    IF screen-group1 EQ 'G01' OR screen-group1 EQ 'G02'.
      screen-required   = '2'.
    ENDIF.

*-- S/O 생성 / 조회 Radio Buttion 기준 화면 정보 구성
    CASE abap_true.
      WHEN p_crte.          " 생성
        IF screen-group1 EQ 'G01' OR screen-group1 EQ 'G03' OR screen-group1 EQ 'G05'.
          screen-active = 0.
        ENDIF.
      WHEN p_search.        " 조회
        IF screen-group1 EQ 'G02' OR screen-group1 EQ 'G04' OR screen-group1 EQ 'G05'.
          screen-active = 0.
        ENDIF.
      WHEN p_del.           " 삭제
        IF screen-group1 EQ 'G01' OR screen-group1 EQ 'G02' OR screen-group1 EQ 'G03' OR
           screen-group1 EQ 'G04'.
          screen-active = 0.
        ENDIF.

      WHEN p_rej.           " As-Is 판매오더 거부사유 처리
        IF screen-group1 EQ 'G01' OR screen-group1 EQ 'G03' OR screen-group1 EQ 'G04' OR
           screen-group1 EQ 'G05'.
          screen-active = 0.
        ENDIF.
    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form chk_req_value_for_vkorg
*&---------------------------------------------------------------------*
*& 영업조직 필수값 체크
*&---------------------------------------------------------------------*
*&      --> PV_VKORG    : 영업조직 조회조건 입력 값 정보
*&---------------------------------------------------------------------*
FORM chk_req_value_for_vkorg  USING    pv_vkorg.

  CHECK sy-ucomm EQ 'ONLI'    AND
        p_search EQ abap_true AND
        pv_vkorg IS INITIAL.

*-- 조회조건 없이 실행시 오류 메세지 구성
  MESSAGE e278(00) WITH '영업 조직'(e01).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form chk_req_value_for_werks
*&---------------------------------------------------------------------*
*& 플랜트 필수값 체크
*&---------------------------------------------------------------------*
*&      --> PV_WERKS     : 플랜트 조회조건 입력 값 정보
*&---------------------------------------------------------------------*
FORM chk_req_value_for_werks  USING    pv_werks.

  CHECK sy-ucomm EQ 'ONLI'    AND
        p_search EQ abap_true AND
        pv_werks IS INITIAL.

*-- 조회조건 없이 실행시 오류 메세지 구성
  MESSAGE e278(00) WITH '플랜트'(e02).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form chk_req_value_for_spart
*&---------------------------------------------------------------------*
*& 제품군 필수값 체크
*&---------------------------------------------------------------------*
*&      --> PV_SPART    : 제품군 조회조건 입력 값 정보
*&---------------------------------------------------------------------*
FORM chk_req_value_for_spart  USING    pv_spart.

  CHECK sy-ucomm EQ 'ONLI'    AND
        p_search EQ abap_true AND
        pv_spart IS INITIAL.

*-- 조회조건 없이 실행시 오류 메세지 구성
  MESSAGE e278(00) WITH '제품군'(e03).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form chk_req_value_for_vstel
*&---------------------------------------------------------------------*
*& 출하지점 필수값 체크
*&---------------------------------------------------------------------*
*&      --> PV_VSTEL    : 출하지점 조회조건 입력값 정보
*&---------------------------------------------------------------------*
FORM chk_req_value_for_vstel  USING    pv_vstel.

  CHECK sy-ucomm EQ 'ONLI'    AND
        p_search EQ abap_true AND
        pv_vstel IS INITIAL.

*-- 조회조건 없이 실행시 오류 메세지 구성
  MESSAGE e278(00) WITH '출하지점'(e04).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form chk_req_value_for_fname
*&---------------------------------------------------------------------*
*& File Path 필수값 체크
*&---------------------------------------------------------------------*
*&      --> PV_FNAME    : File Path 입력값 정보
*&---------------------------------------------------------------------*
FORM chk_req_value_for_fname  USING    pv_fname.

  CHECK sy-ucomm EQ 'ONLI'    AND
        p_crte   EQ abap_true AND
        pv_fname IS INITIAL.

*-- 피일명 정보 없이 실행시 오류 메세지 구성
  MESSAGE e005(fs_ech_file_ui).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form upload_file_path_dialog
*&---------------------------------------------------------------------*
*& 파일명 / 파일 경로 정보 선택 Dialog  구성
*&---------------------------------------------------------------------*
*&      <-- PV_FNAME  : 선택 파일명 / 경로 정보 리턴
*&---------------------------------------------------------------------*
FORM upload_file_path_dialog  CHANGING pv_fname  TYPE localfile.

  DATA: lv_default_path TYPE string,
        lt_files        TYPE filetable,
        lv_subrc        TYPE sysubrc,
        lv_act          TYPE i.

*-- 기본 경로 정보 구성
  CALL METHOD cl_gui_frontend_services=>directory_get_current
    CHANGING
      current_directory = lv_default_path.

*-- Excel 파일명 / 파일경로 정보 선택 Dialog 창 구현
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title      = 'File Upload'
      default_filename  = space
      file_filter       = cl_gui_frontend_services=>filetype_excel
      initial_directory = lv_default_path
    CHANGING
      file_table        = lt_files
      rc                = lv_subrc
      user_action       = lv_act.

  CHECK lv_act NE 9.
*-- 취소 수행이 아닌 경우 선택 된 파일경로 정보 리턴
  READ TABLE lt_files INDEX 1 INTO DATA(ls_files).
  CHECK sy-subrc EQ 0.
  pv_fname = ls_files-filename.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form upload_excel_file
*&---------------------------------------------------------------------*
*& 해당 Excel 파일 업로드 수행
*&---------------------------------------------------------------------*
*&      <-- PV_EFLAG    : 오류 발생시 'X' 리턴
*&---------------------------------------------------------------------*
FORM upload_excel_file  CHANGING pv_eflag TYPE char01.

  CLEAR : pv_eflag.

  CASE abap_true.
    WHEN p_mapp.            " Mapping 정보 업로드
      PERFORM upload_mapp           CHANGING gt_mapp
                                             pv_eflag.

    WHEN p_tobe.            " TO_BE 데이터 생성
      PERFORM upload_tobe           CHANGING gt_tobe
                                             pv_eflag.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_data
*&---------------------------------------------------------------------*
*& 조회조건 기준 값 Select 수행
*&---------------------------------------------------------------------*
*&      <-- PV_EFLAG    : 오류 발생시 'X' 리턴
*&---------------------------------------------------------------------*
FORM select_data CHANGING pv_eflag TYPE char01.

  CLEAR pv_eflag.

  CASE abap_true.
    WHEN p_so.              " Open S/O
      PERFORM select_so_data        CHANGING gt_open_so
                                             pv_eflag.

    WHEN p_do OR p_ship.    " Open D/O, Open Shipment
      PERFORM select_do_data        CHANGING gt_open_do
                                             pv_eflag.

    WHEN p_hu.              " Open HU
      PERFORM select_hu_data        CHANGING gt_open_hu
                                             pv_eflag.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_so_data
*&---------------------------------------------------------------------*
*& Open S/O 정보 Select 수행
*&---------------------------------------------------------------------*
*&      <-- PT_OPEN_SO    : Open S/O 조회정보 리턴
*&      <-- PV_EFLAG      : 조회 정보 없을경우 'X' 리턴
*&---------------------------------------------------------------------*
FORM select_so_data  CHANGING pt_open_so  TYPE gty_t_open_so
                              pv_eflag    TYPE char01.

  CLEAR : pt_open_so.

  SELECT a~auart,  a~bstnk,  a~vbeln,  a~waerk,
         b~posnr,  b~matnr,  b~arktx,  b~kwmeng,  b~vrkme,  b~lfsta,
         c~bstkd_e,
         d~kbetr,  d~kwert,

         a~kunnr AS soldto,
         e~kunnr AS shipto

    FROM vbak AS a INNER JOIN vbap AS b
                      ON a~vbeln EQ b~vbeln

                   INNER JOIN vbkd AS c
                      ON b~vbeln EQ c~vbeln
                     AND b~posnr EQ c~posnr

                   INNER JOIN prcd_elements AS d
                      ON a~knumv EQ d~knumv
                     AND b~posnr EQ d~kposn

                   INNER JOIN vbpa AS e
                      ON a~vbeln EQ e~vbeln

   WHERE a~vkorg   EQ @p_vkorg
     AND a~spart   EQ @p_spart
     AND b~werks   EQ @p_werks
     AND b~lfsta   IN ( @gc_lfsta-a, @gc_lfsta-b )
     AND b~abgru   EQ @abap_false
     AND c~bstkd_e NE @abap_false
     AND d~kschl   EQ @gc_kschl-zpr0
     AND e~parvw   EQ @gc_parvw-we
     AND a~erdat   IN @s_erdat

   INTO CORRESPONDING FIELDS OF TABLE @pt_open_so.

  IF sy-subrc NE 0.
    pv_eflag = abap_true.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_do_data
*&---------------------------------------------------------------------*
*& Open D/O / Open Shipment 정보 Select 수행
*&---------------------------------------------------------------------*
*&      <-- PT_OPEN_DO    : Open D/O / Open Shipment 조회 정보 리턴
*&      <-- PV_EFLAG      : 조회 정보 없을경우 'X' 리턴
*&---------------------------------------------------------------------*
FORM select_do_data  CHANGING pt_open_do  TYPE gty_t_open_do
                              pv_eflag    TYPE char01.

  DATA : lr_trsta TYPE RANGE OF trsta.

  CLEAR : pt_open_do,
        lr_trsta.

*-- Open D/O , Open Shipment 기준 조회조건 구성
  CASE abap_true.
    WHEN p_do.
      lr_trsta[]  = VALUE #(
                            ( sign = gc_sign-i option = gc_optn-eq low = gc_trsta-a )
                            ( sign = gc_sign-i option = gc_optn-eq low = gc_trsta-b )
                           ).
    WHEN p_ship.
      APPEND VALUE #(
                      sign   = gc_sign-i
                      option = gc_optn-eq
                      low    = gc_trsta-c
                    ) TO lr_trsta.
  ENDCASE.


  SELECT b~vgbel,  b~vgpos,  b~vbeln,  b~posnr,  b~matnr,
         b~arktx,  b~vrkme,  b~lfimg,  b~erdat,
         c~bstkd_e,
         d~bstnk,  e~name1,

         e~kunnr AS soldto,
         f~kunnr AS shipto

    FROM likp AS a INNER JOIN lips AS b
                      ON a~vbeln EQ b~vbeln

                   INNER JOIN vbkd AS c
                      ON b~vgbel EQ c~vbeln
                     AND b~vgpos EQ c~posnr

                   INNER JOIN vbak AS d
                      ON b~vgbel EQ d~vbeln

                   INNER JOIN kna1 AS e
                      ON d~kunnr EQ e~kunnr

                   INNER JOIN vbpa AS f
                      ON d~vbeln EQ f~vbeln

   WHERE b~werks EQ @p_werks
     AND b~spart EQ @p_spart
     AND a~vstel EQ @p_vstel
     AND d~vkorg EQ @p_vkorg
     AND b~kosta IN ( @gc_kosta-a, @gc_kosta-b )
     AND a~trsta IN @lr_trsta
     AND f~parvw EQ @gc_parvw-we
     AND a~erdat IN @s_erdat

    INTO CORRESPONDING FIELDS OF TABLE @pt_open_do.

  IF sy-subrc NE 0.
    pv_eflag = abap_true.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_hu_data
*&---------------------------------------------------------------------*
*& Open HU 조회정보 Select
*&---------------------------------------------------------------------*
*&      <-- PT_OPEN_HU  : Open HU 조회 정보 리턴
*&      <-- PV_EFLAG      : 조회 정보 없을경우 'X' 리턴
*&---------------------------------------------------------------------*
FORM select_hu_data  CHANGING pt_open_hu  TYPE gty_t_open_hu
                              pv_eflag    TYPE char01.

  DATA : lv_venum TYPE venum,
         lv_vepos TYPE vepos,
         lv_matnr TYPE matnr.

  CLEAR : pt_open_hu,
          lv_venum, lv_vepos, lv_matnr.

  SELECT a~exidv,
         CASE WHEN b~venum IS NOT NULL THEN b~venum
              ELSE @lv_venum
         END AS venum,

         CASE WHEN b~vepos IS NOT NULL THEN b~vepos
              ELSE @lv_vepos
         END AS vepos,

         CASE WHEN b~matnr IS NOT NULL THEN b~matnr
              ELSE @lv_matnr
         END AS matnr,

         CASE WHEN b~charg IS NOT NULL THEN b~charg
              ELSE @abap_false
         END AS charg,

         CASE WHEN b~werks IS NOT NULL THEN b~werks
              ELSE @abap_false
         END AS werks,

         CASE WHEN b~lgort IS NOT NULL THEN b~lgort
              ELSE @abap_false
         END AS lgort

    FROM vekp AS a LEFT OUTER JOIN vepo AS b
                           ON a~venum EQ b~venum
   WHERE a~vstel EQ @p_vstel
     AND a~vkorg EQ @p_vkorg
     AND b~werks EQ @p_werks
     AND a~erdat IN @s_erdat

     AND ( b~vbeln IS INITIAL OR
           b~vbeln EQ @abap_false )

    INTO CORRESPONDING FIELDS OF TABLE @pt_open_hu.

  IF sy-subrc NE 0.
    pv_eflag = abap_true.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form clear_alv_info
*&---------------------------------------------------------------------*
*& Class ALV 선언 정보 & 해당 변수 초기화
*&---------------------------------------------------------------------*
FORM clear_alv_info .

  CALL METHOD go_dock_cont_0100->free.

  CLEAR : go_dock_cont_0100, go_event_handler,
          go_gui_cont_0100,  go_grid_0100.

  CALL METHOD cl_gui_cfw=>flush.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_class_alv_info_0100
*&---------------------------------------------------------------------*
*& Screen 0100 Class ALV 구성
*&---------------------------------------------------------------------*
FORM init_class_alv_info_0100 .

  IF go_dock_cont_0100 IS NOT BOUND.
*-- ALV Docking Container & ALV Grid 정보 구성
    PERFORM crte_objt_grid_0100     CHANGING go_dock_cont_0100
                                             go_grid_0100.

*-- Layout 구성
    PERFORM set_layout_0100         CHANGING gs_layo_0100.

*-- 예외 Toolbar 정보 구성
    PERFORM set_exclude_0100        CHANGING gt_excl_0100.

*-- Fieldcatalog 정보 구성
    PERFORM set_fcat_f_0100         CHANGING gt_fcat_0100.

*-- ALV Event 정보 구성
    PERFORM set_event_handler       USING    go_grid_0100
                                    CHANGING go_event_handler.
*-- ALV Display
    PERFORM disp_alv_grid_0100      USING    go_grid_0100.
  ELSE.
*-- ALV Refresh 수행
    PERFORM refresh_alv_disp        USING    go_grid_0100
                                             abap_true.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form crte_objt_grid_0100
*&---------------------------------------------------------------------*
*&  Screen 0100 Class ALV Docking Container & Grid 정보 생성
*&---------------------------------------------------------------------*
*&      <-- PO_DOCK_CONT  : 해당 Docking Container 생성 정보 리턴
*&      <-- PO_GRID_0100  : ALV Grid 생성 정보 리턴
*&---------------------------------------------------------------------*
FORM crte_objt_grid_0100  CHANGING po_dock_cont TYPE REF TO cl_gui_docking_container
                                   po_grid_0100 TYPE REF TO cl_gui_alv_grid.

*-- 1. Docking Container 생성
  CREATE OBJECT po_dock_cont
    EXPORTING
      repid     = sy-cprog
      dynnr     = sy-dynnr
      side      = po_dock_cont->dock_at_top
      extension = 1500.

*-- 2. Grid 정보 구성
  CREATE OBJECT po_grid_0100
    EXPORTING
      i_parent = po_dock_cont.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_0100
*&---------------------------------------------------------------------*
*& Screen 0100 ALV Layout 정보 구성
*&---------------------------------------------------------------------*
*&      <-- PS_LAYOUT   : 해당 Layout 구성 정보 리턴
*&---------------------------------------------------------------------*
FORM set_layout_0100  CHANGING ps_layout TYPE lvc_s_layo.

  CLEAR ps_layout.

  CASE abap_true.
    WHEN p_crte OR p_del OR p_rej.
      ps_layout = VALUE #(
                          excp_fname = 'STAT'
                          excp_led   = abap_true

                          cwidth_opt = abap_true
                          sel_mode   = |C|
                          zebra      = abap_true
                         ).

    WHEN OTHERS.
      ps_layout = VALUE #(
                          cwidth_opt = abap_true
                          sel_mode   = |C|
                          zebra      = abap_true
                         ).
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_exclude_0100
*&---------------------------------------------------------------------*
*& Screen 0100 ALV Toolbar 예외 버튼 정보 구성
*&---------------------------------------------------------------------*
*&      <-- PT_EXCLUDE  : 예외 정보 리턴
*&---------------------------------------------------------------------*
FORM set_exclude_0100  CHANGING pt_exclude TYPE ui_functions.

  PERFORM add_exclude_toolbar       TABLES   pt_exclude[]
                                    USING  : cl_gui_alv_grid=>mc_fc_loc_undo,
                                             cl_gui_alv_grid=>mc_fc_auf,
                                             cl_gui_alv_grid=>mc_fc_check,
                                             cl_gui_alv_grid=>mc_fc_loc_paste,
                                             cl_gui_alv_grid=>mc_fc_loc_copy,
                                             cl_gui_alv_grid=>mc_fc_average,
                                             cl_gui_alv_grid=>mc_fc_graph,
                                             cl_gui_alv_grid=>mc_fc_info,
                                             cl_gui_alv_grid=>mc_fc_loc_copy_row,
                                             cl_gui_alv_grid=>mc_fc_loc_cut,
                                             cl_gui_alv_grid=>mc_fc_loc_delete_row,
                                             cl_gui_alv_grid=>mc_fc_loc_insert_row,
                                             cl_gui_alv_grid=>mc_fc_loc_append_row,
                                             cl_gui_alv_grid=>mc_fc_loc_paste,
                                             cl_gui_alv_grid=>mc_fc_loc_paste_new_row,
                                             cl_gui_alv_grid=>mc_fc_refresh.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_exclude_toolbar
*&---------------------------------------------------------------------*
*& Class ALV Toolbar 예외 버튼 정보 추가
*&---------------------------------------------------------------------*
*&      <-- PT_EXCLUDE  : 해당 예외 버튼 정보 추가
*&      --> PV_VALUE    : 예외 버튼 정보
*&---------------------------------------------------------------------*
FORM add_exclude_toolbar  TABLES   pt_exclude
                          USING    pv_value.

  DATA : ls_excl TYPE ui_func.

  ls_excl = pv_value.

  APPEND ls_excl TO pt_exclude.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat_f_0100
*&---------------------------------------------------------------------*
*& Screen 0100 ALV Fieldcatalog 정보 구성
*&---------------------------------------------------------------------*
*&      <-- PT_FCAT  : 해당 Fieldcatalog 정보 리턴
*&---------------------------------------------------------------------*
FORM set_fcat_f_0100  CHANGING pt_fcat TYPE lvc_t_fcat.

*-- 1. 해당 Internal Table 정보 기준 Fieldcatlog 정보 구성
  CASE abap_true.
    WHEN p_search.          " 조회
      CASE abap_true.
        WHEN p_so.          " Open S/O
          PERFORM init_fcat_from_itab        USING    gt_open_so
                                             CHANGING pt_fcat.
          PERFORM into_fcat_from_open_so     CHANGING pt_fcat.

        WHEN p_do OR p_ship." Open D/O , Open Shipment
          PERFORM init_fcat_from_itab        USING    gt_open_do
                                             CHANGING pt_fcat.
          PERFORM into_fcat_from_open_do     CHANGING pt_fcat.
        WHEN p_hu.          " Open HU
          PERFORM init_fcat_from_itab        USING    gt_open_hu
                                             CHANGING pt_fcat.
          PERFORM into_fcat_from_open_hu     CHANGING pt_fcat.
      ENDCASE.

    WHEN p_crte.            " 생성
      CASE abap_true.
        WHEN p_mapp.        " Mapping 정보 업로드
          PERFORM init_fcat_from_itab        USING    gt_mapp
                                             CHANGING pt_fcat.
          PERFORM init_fcat_from_mapp        CHANGING pt_fcat.
        WHEN p_tobe.        " To-Be 데이터 생성
          PERFORM init_fcat_from_itab        USING    gt_tobe
                                             CHANGING pt_fcat.
          PERFORM init_fcat_from_tobe        CHANGING pt_fcat.
      ENDCASE.

    WHEN p_del.             " 조회/삭제
      CASE abap_true.
        WHEN p_del_m.       " Mapping 정보 조회/삭제
          PERFORM init_fcat_from_itab        USING    gt_mapp
                                             CHANGING pt_fcat.
        WHEN p_del_t.       " To-Be 데이터 조회/삭제
          PERFORM init_fcat_from_itab        USING    gt_tobe
                                             CHANGING pt_fcat.
        WHEN p_del_o.       " 판매오더 조회/삭제
          PERFORM init_fcat_from_itab        USING    gt_tobe
                                             CHANGING pt_fcat.
          PERFORM init_fcat_from_tobe        CHANGING pt_fcat.
      ENDCASE.

    WHEN p_rej.             " As-Is 판매오더 거부사유 처리
      PERFORM init_fcat_from_itab            USING    gt_rej_ord
                                             CHANGING pt_fcat.
      PERFORM init_fcat_from_rej             CHANGING pt_fcat.
  ENDCASE.

*-- 2. 추가 정보 구성

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_fcat_from_itab
*&---------------------------------------------------------------------*
*& 해당 Internal Table 정보 기준 LVC Fieldcatalog 정보 구성
*&---------------------------------------------------------------------*
*&      --> PT_TAB   : 해당 Internal Table 정보
*&      <-- PT_FCAT  : 해당 Fieldcatalog 정보 리턴
*&---------------------------------------------------------------------*
FORM init_fcat_from_itab  USING    pt_tab   TYPE STANDARD TABLE
                          CHANGING pt_fcat  TYPE lvc_t_fcat.

  LOOP AT cl_salv_ddic=>get_by_data( pt_tab ) INTO DATA(ls_dfies).
    DATA(ls_fcat) = CORRESPONDING lvc_s_fcat( ls_dfies MAPPING key = keyflag ).

    ls_fcat-col_pos     = sy-tabix.             " ALV 출력 열 기본값 구성

    IF ls_fcat-datatype EQ 'CLNT'.              " Client 필드 구성
      ls_fcat-tech      = abap_true.
    ENDIF.

*-- 참조 필드 정보 구성
    IF ls_dfies-lfieldname IS NOT INITIAL.
      ls_fcat-ref_table = ls_dfies-precfield.
      ls_fcat-ref_field = ls_dfies-lfieldname.
    ELSE.
      ls_fcat-ref_table = ls_dfies-reftable.
      ls_fcat-ref_field = ls_dfies-reffield.
    ENDIF.

*-- 수량 / 금액 필드 정보 구성
    IF ls_dfies-reftable EQ ls_dfies-precfield AND
       ls_dfies-reffield IS NOT INITIAL.
      CASE ls_fcat-datatype.
        WHEN 'CURR'.        " 금액
          ls_fcat-cfieldname = ls_dfies-reffield.
        WHEN 'QUAN'.        " 수량
          ls_fcat-qfieldname = ls_dfies-reffield.
      ENDCASE.
    ENDIF.

*-- 누락 필드명 정보 구성
    IF ls_fcat-coltext   IS INITIAL AND
       ls_fcat-reptext   IS INITIAL AND
       ls_fcat-scrtext_l IS INITIAL AND
       ls_fcat-scrtext_m IS INITIAL AND
       ls_fcat-scrtext_s IS INITIAL.
      ls_fcat-coltext = ls_dfies-fieldtext.
    ENDIF.

    IF ls_dfies-lfieldname IS NOT INITIAL.
      CLEAR ls_fcat-rollname.
    ENDIF.
    APPEND ls_fcat TO pt_fcat.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_event_handler
*&---------------------------------------------------------------------*
*& Screen 0100 Class ALV Event 정보 구성
*&---------------------------------------------------------------------*
*&      --> PO_GRID   : 해당 ALV Grid 정보
*&      <-- PO_EVENT  : 해당 ALV Event 구현 정보 리턴
*&---------------------------------------------------------------------*
FORM set_event_handler  USING    po_grid  TYPE REF TO cl_gui_alv_grid
                        CHANGING po_event TYPE REF TO lcl_event_handler.

  IF po_event IS NOT BOUND.
    CREATE OBJECT po_event.
  ENDIF.

*-- ALV Grid 별 Event 정보 구성
  CASE po_grid.
    WHEN go_grid_0100.
      SET HANDLER po_event->handle_hotspot_click    FOR po_grid.
    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form disp_alv_grid_0100
*&---------------------------------------------------------------------*
*& Screen 0100 ALV Display
*&---------------------------------------------------------------------*
*&      --> PO_GRID  : 해당 ALV Grid 정보
*&---------------------------------------------------------------------*
FORM disp_alv_grid_0100  USING    po_grid TYPE REF TO cl_gui_alv_grid.

  CLEAR : gs_vari_0100.
*-- Haader ALV Varient 기본 정보 구성
  gs_vari_0100 = VALUE #(
                          report   = sy-cprog
                          username = sy-uname
                        ).

*-- ALV Display 수행
  CASE abap_true.
    WHEN p_search.          " 조회
      CASE abap_true.
        WHEN p_so.          " Open S/O
          PERFORM set_first_disp    USING    po_grid
                                             gt_open_so[].

        WHEN p_do OR p_ship." Open D/O , Open Shipment
          PERFORM set_first_disp    USING    po_grid
                                             gt_open_do[].
        WHEN p_hu.          " Open HU
          PERFORM set_first_disp    USING    po_grid
                                             gt_open_hu[].
      ENDCASE.

    WHEN p_crte.            " 생성
      CASE abap_true.
        WHEN p_mapp.        " Mapping 정보 업로드
          PERFORM set_first_disp    USING    po_grid
                                             gt_mapp[].
        WHEN p_tobe.        " To-Be 데이터 생성
          PERFORM set_first_disp    USING    po_grid
                                             gt_tobe[].
      ENDCASE.

    WHEN p_del.             " 조회/삭제
      CASE abap_true.
        WHEN p_del_m.       " Mapping 정보 조회/삭제
          PERFORM set_first_disp    USING    po_grid
                                             gt_mapp[].
        WHEN p_del_t.       " To-Be 데이터 조회/삭제
          PERFORM set_first_disp    USING    po_grid
                                             gt_tobe[].
        WHEN p_del_o.       " 판매오더 조회/삭제
          PERFORM set_first_disp    USING    po_grid
                                             gt_tobe[].
      ENDCASE.

    WHEN p_rej.             " As-Is 판매오더 거부사유 처리
      PERFORM set_first_disp        USING    po_grid
                                             gt_rej_ord[].
  ENDCASE.

*-- 생성 / 조회 기준 Edit 기능 구성
  CALL METHOD po_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_alv_disp
*&---------------------------------------------------------------------*
*& Class ALV Refresh 수행
*&---------------------------------------------------------------------*
*&      --> PO_GRID  : 해당 ALV Grid 정보
*&      --> PV_RESET : 해당 Layout Re Set Flag
*&---------------------------------------------------------------------*
FORM refresh_alv_disp  USING    po_grid  TYPE REF TO cl_gui_alv_grid
                                pv_reset TYPE char01.

  DATA : ls_stbl   TYPE lvc_s_stbl,

         ls_layout TYPE lvc_s_layo.

  ls_stbl = VALUE #(
                    row = abap_true
                    col = abap_true
                   ).

  IF pv_reset EQ abap_true.
*-- Layout Re Set 수행시
    CALL METHOD po_grid->get_frontend_layout
      IMPORTING
        es_layout = ls_layout.

    ls_layout-cwidth_opt = abap_true.

    CALL METHOD po_grid->set_frontend_layout
      EXPORTING
        is_layout = ls_layout.

  ENDIF.

  CALL METHOD po_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stbl
    EXCEPTIONS
      finished  = 1
      OTHERS    = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_first_disp
*&---------------------------------------------------------------------*
*&  해당 Internal Table ALV 화면 출력 수행
*&---------------------------------------------------------------------*
*&      --> PO_GRID  : 해당 ALV Grid 정보
*&---------------------------------------------------------------------*
FORM set_first_disp  USING    po_grid  TYPE REF TO cl_gui_alv_grid
                              pt_table TYPE STANDARD TABLE.

  CALL METHOD po_grid->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layo_0100
      it_toolbar_excluding = gt_excl_0100
      is_variant           = gs_vari_0100
      i_save               = 'A'
    CHANGING
      it_outtab            = pt_table[]
      it_fieldcatalog      = gt_fcat_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form upload_mapp
*&---------------------------------------------------------------------*
*& Mapping 정보 Upload 수행
*&---------------------------------------------------------------------*
*&      <-- PT_MAPP     : Upload 정보 ALV 출력 정보 리턴
*&      <-- PV_EFLAG    : 오류 발생시 'X' 리턴
*&---------------------------------------------------------------------*
FORM upload_mapp  CHANGING pt_mapp   TYPE gty_t_mapp
                           pv_eflag  TYPE char01.

  DATA : lt_excel     TYPE isu_price_excel_tab,
         lt_excl_mapp TYPE gty_t_excel_mapp,
         ls_excl_mapp TYPE gty_excel_mapp,

         lt_fcat      TYPE lvc_t_fcat,

         lv_point     TYPE char01,
         lv_value     TYPE char50.

  CLEAR : lt_excel, lt_excl_mapp, lt_fcat,
          lv_point.
*-----------------------------------------------------------------------
*-- 1. Excel File 정보 기준 Upload 수행
*-----------------------------------------------------------------------
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_fname
      i_begin_col             = 1
      i_begin_row             = 3
      i_end_col               = 17
      i_end_row               = 65535
    TABLES
      intern                  = lt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc NE 0.
    pv_eflag = abap_true.
    EXIT.
  ENDIF.

*-----------------------------------------------------------------------
*-- 2. Upload Excel 정보 기준 Internal Table 에 값 구성
*-----------------------------------------------------------------------
*-- Deciaml 유형 기준 자릿수 표시 정보 제어
  CASE gv_decimal.
    WHEN abap_true.         " 소수점 '.'
      lv_point = |,|.
    WHEN OTHERS.            " 소수점 ','
      lv_point = |.|.
  ENDCASE.

*-- 2-1. 해당 Excel Upload 양식 기준 필드 정보 구성
  PERFORM init_fcat_from_itab        USING    lt_excl_mapp
                                     CHANGING lt_fcat.

*-- 2-2. Internal Table 에 Excel Upload 정보 구성
  LOOP AT lt_excel INTO DATA(ls_excel).
    ASSIGN COMPONENT ls_excel-col OF STRUCTURE ls_excl_mapp TO FIELD-SYMBOL(<lv_fld>).

    READ TABLE lt_fcat INDEX ls_excel-col
                       INTO DATA(ls_fcat).
    IF sy-subrc EQ 0.
*-- ABAP 유형별 값 구성
      CASE ls_fcat-inttype.
        WHEN 'P'.           " 수량 / 금액 유형
          REPLACE ALL OCCURRENCES OF lv_point IN ls_excel-value WITH space.
          CONDENSE ls_excel-value.
        WHEN 'D'.           " Date 유형
          REPLACE ALL OCCURRENCES OF |-| IN ls_excel-value WITH space.
          CONDENSE ls_excel-value.
      ENDCASE.

*-- Conversion Exit 정보 기준 값 구성
      IF ls_fcat-convexit IS NOT INITIAL.
        DATA(lv_fname) = |CONVERSION_EXIT_| && ls_fcat-convexit && |_INPUT|.

        CALL FUNCTION lv_fname
          EXPORTING
            input  = ls_excel-value
          IMPORTING
            output = <lv_fld>.
      ELSE.
        <lv_fld> = ls_excel-value.
      ENDIF.

    ENDIF.

    AT END OF row.
      APPEND ls_excl_mapp TO lt_excl_mapp.
      CLEAR ls_excl_mapp.
    ENDAT.
  ENDLOOP.

*-----------------------------------------------------------------------
*-- 3. Excel Upload 정보 기준 ALV 출력 정보 구성
*-----------------------------------------------------------------------
  IF lt_excl_mapp[] IS INITIAL.
    pv_eflag = abap_true.
    EXIT.
  ENDIF.

  SORT : lt_excl_mapp BY zpjno_o job_no_o vbeln_o.

  PERFORM init_mapp_alv_f_excel     USING    lt_excl_mapp
                                    CHANGING pt_mapp
                                             pv_eflag.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_initialization
*&---------------------------------------------------------------------*
*& Initialization 정보 구성
*&---------------------------------------------------------------------*
FORM set_initialization .

  CLEAR : gv_decimal.
*-- User ID 기준 Deciaml Point 정보 구성
  CALL FUNCTION '/OSP/GET_DECIMAL_NOTATION'
    EXPORTING
      i_uname             = sy-uname
    IMPORTING
      ev_decimal_notation = gv_decimal.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form upload_tobe
*&---------------------------------------------------------------------*
*& To-Be 정보 Upload 수행
*&---------------------------------------------------------------------*
*&      <-- PT_TOBE     : Upload 정보 ALV 출력 정보 리턴
*&      <-- PV_EFLAG    : 오류 발생시 'X' 리턴
*&---------------------------------------------------------------------*
FORM upload_tobe  CHANGING pt_tobe   TYPE gty_t_tobe
                           pv_eflag  TYPE char01.

  DATA : lt_excel     TYPE isu_price_excel_tab,
         lt_excl_tobe TYPE gty_t_excel_tobe,
         ls_excl_tobe TYPE gty_excel_tobe,

         lt_fcat      TYPE lvc_t_fcat,

         lv_point     TYPE char01,
         lv_value     TYPE char50.

  CLEAR : lt_excel, lt_excl_tobe, lt_fcat,
          lv_point.
*-----------------------------------------------------------------------
*-- 1. Excel File 정보 기준 Upload 수행
*-----------------------------------------------------------------------
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_fname
      i_begin_col             = 1
      i_begin_row             = 3
      i_end_col               = 36
      i_end_row               = 65535
    TABLES
      intern                  = lt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc NE 0.
    pv_eflag = abap_true.
    EXIT.
  ENDIF.

*-----------------------------------------------------------------------
*-- 2. Upload Excel 정보 기준 Internal Table 에 값 구성
*-----------------------------------------------------------------------
*-- Deciaml 유형 기준 자릿수 표시 정보 제어
  CASE gv_decimal.
    WHEN abap_true.         " 소수점 '.'
      lv_point = |,|.
    WHEN OTHERS.            " 소수점 ','
      lv_point = |.|.
  ENDCASE.

*-- 2-1. 해당 Excel Upload 양식 기준 필드 정보 구성
  PERFORM init_fcat_from_itab        USING    lt_excl_tobe
                                     CHANGING lt_fcat.

*-- 2-2. Internal Table 에 Excel Upload 정보 구성
  LOOP AT lt_excel INTO DATA(ls_excel).
    ASSIGN COMPONENT ls_excel-col OF STRUCTURE ls_excl_tobe TO FIELD-SYMBOL(<lv_fld>).

    READ TABLE lt_fcat INDEX ls_excel-col
                       INTO DATA(ls_fcat).
    IF sy-subrc EQ 0.
*-- ABAP 유형별 값 구성
      CASE ls_fcat-inttype.
        WHEN 'P'.           " 수량 / 금액 유형
          REPLACE ALL OCCURRENCES OF lv_point IN ls_excel-value WITH space.
          CONDENSE ls_excel-value.
        WHEN 'D'.           " Date 유형
          REPLACE ALL OCCURRENCES OF |-| IN ls_excel-value WITH space.
          CONDENSE ls_excel-value.
      ENDCASE.

*-- Conversion Exit 정보 기준 값 구성
      IF ls_fcat-convexit IS NOT INITIAL.
        DATA(lv_fname) = |CONVERSION_EXIT_| && ls_fcat-convexit && |_INPUT|.

        CALL FUNCTION lv_fname
          EXPORTING
            input  = ls_excel-value
          IMPORTING
            output = <lv_fld>.
      ELSE.
        <lv_fld> = ls_excel-value.
      ENDIF.

    ENDIF.

    AT END OF row.
      APPEND ls_excl_tobe TO lt_excl_tobe.
      CLEAR ls_excl_tobe.
    ENDAT.
  ENDLOOP.

*-----------------------------------------------------------------------
*-- 3. Excel Upload 정보 기준 ALV 출력 정보 구성
*-----------------------------------------------------------------------
  IF lt_excl_tobe[] IS INITIAL.
    pv_eflag = abap_true.
    EXIT.
  ENDIF.

  SORT lt_excl_tobe BY zpjno job_no posnr.

  PERFORM init_tobe_alv_f_excel     USING    lt_excl_tobe
                                    CHANGING pt_tobe
                                             pv_eflag.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_mapping_data
*&---------------------------------------------------------------------*
*& As-Is To-Be Mapping Excel 업로드 정보 저장 수행
*&---------------------------------------------------------------------*
FORM save_mapping_data .

  DATA : lt_0066   TYPE gty_t_0066_u,
         ls_0066   TYPE gty_0066_u,

         lt_9060   TYPE gty_t_9060,
         ls_9060   TYPE gty_9060,

         lv_answer TYPE char01.

  PERFORM popup_to_confirm          USING    'Mapping 데이터 저장'(t04)
                                             'ASIS vs. TOBE 판매오더 Mapping 정보를 저장하시겠습니까?'(m01)
                                    CHANGING lv_answer.
  IF lv_answer NE '1'.
    MESSAGE s050.
    EXIT.
  ENDIF.

*-----------------------------------------------------------------------
*-- Mapping 저장 수행
*-----------------------------------------------------------------------
  SELECT SINGLE @abap_true
    FROM @gt_mapp AS a
   WHERE a~stat EQ @gc_led-red

    INTO @DATA(lv_flag).

  IF sy-subrc EQ 0.
*-- Red LED 정보 있을경우 오류 메세지 구성 & Exit
    MESSAGE s000 WITH 'Mapping 정보가 일치하지 않습니다.'(m02)
                 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 기존 저장 정보 Select - Time Stamp
  WITH +key_info AS ( SELECT a~zpjno_o, a~job_no_o, a~vbeln_o, a~posnr_o
                        FROM @gt_mapp AS a
                       WHERE a~stat EQ @gc_led-green
                       GROUP BY a~zpjno_o, a~job_no_o, a~vbeln_o, a~posnr_o )

    SELECT a~zpjno,    a~job_no_o,  a~vbeln,   a~posnr,
           a~ernam,    a~erdat,     a~erzeit,  a~erdatlo,
           a~ertimlo,  a~ertcode,   a~erempno

      FROM zgtsdt9060 AS a INNER JOIN +key_info AS b
                              ON a~zpjno    EQ b~zpjno_o
                             AND a~job_no_o EQ b~job_no_o
                             AND a~vbeln    EQ b~vbeln_o
                             AND a~posnr    EQ b~posnr_o
     ORDER BY a~zpjno, a~job_no_o, a~vbeln, a~posnr

      INTO TABLE @DATA(lt_9060_t).

*-- Table : ZGTSDT0066 Key 정보 기준 해당 정보 Select
  WITH +key_info AS ( SELECT a~job_no_n, a~posnr_n, a~qcode
                        FROM @gt_mapp AS a
                       WHERE a~stat EQ @gc_led-green
                       GROUP BY a~job_no_n, a~posnr_n, a~qcode )

    SELECT a~zsystem_id,  a~job_no,    a~posnr,   a~qcode

      FROM zgtsdt0066 AS a INNER JOIN +key_info AS b
                              ON a~job_no EQ b~job_no_n
                             AND a~posnr  EQ b~posnr_n
                             AND a~qcode  EQ b~qcode
     WHERE a~zsystem_id EQ @gc_sysid-kbdm

     ORDER BY a~zsystem_id, a~job_no, a~posnr, a~qcode

      INTO TABLE @DATA(lt_0066_t).

*-- 저장 정보 구성
  LOOP AT gt_mapp INTO DATA(ls_mapp).
    CLEAR : ls_9060, ls_0066.

*-- AS-IS Vs TO-BE Mapping
    ls_9060 = VALUE #(
                      zpjno    = ls_mapp-zpjno_o
                      job_no_o = ls_mapp-job_no_o
                      vbeln    = ls_mapp-vbeln_o
                      posnr    = ls_mapp-posnr_o
                      matnr    = ls_mapp-matnr_o
                      arktx    = ls_mapp-arktx_o
                      kwmeng   = ls_mapp-kwmeng_o
                      vrkme    = ls_mapp-vrkme_o
                      netpr    = ls_mapp-netpr_o
                      netwr    = ls_mapp-netwr_o
                      waerk    = ls_mapp-waerk_o
                      mkey     = ls_mapp-zpjno_o && ls_mapp-job_no_o && ls_mapp-posnr_o
                     ).
    READ TABLE lt_9060_t WITH KEY zpjno    = ls_9060-zpjno
                                  job_no_o = ls_9060-job_no_o
                                  vbeln    = ls_9060-vbeln
                                  posnr    = ls_9060-posnr
                         INTO DATA(ls_9060_t).
    IF sy-subrc EQ 0.
      ls_9060 = VALUE #( BASE ls_9060
                          ernam   = ls_9060_t-ernam
                          erdat   = ls_9060_t-erdat
                          erzeit  = ls_9060_t-erzeit
                          erdatlo = ls_9060_t-erdatlo
                          ertimlo = ls_9060_t-ertimlo
                          ertcode = ls_9060_t-ertcode
                          erempno = ls_9060_t-erempno

                          aenam   = sy-uname
                          aedat   = sy-datum
                          aezeit  = sy-uzeit
                          aedatlo = sy-datlo
                          aetimlo = sy-timlo
                       ).
    ELSE.
      ls_9060 = VALUE #( BASE ls_9060
                          ernam   = sy-uname
                          erdat   = sy-datum
                          erzeit  = sy-uzeit
                          erdatlo = sy-datlo
                          ertimlo = sy-timlo
                       ).
    ENDIF.

    APPEND : ls_9060 TO lt_9060.

*-- 판매오더 품목-견적품 Mapping 정보
    READ TABLE lt_0066_t WITH KEY zsystem_id = gc_sysid-kbdm
                                  job_no     = ls_mapp-job_no_n
                                  posnr      = ls_mapp-posnr_n
                                  qcode      = ls_mapp-qcode
                         TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      ls_0066 = VALUE #(
                        zsystem_id      = gc_sysid-kbdm
                        job_no          = ls_mapp-job_no_n
                        posnr           = ls_mapp-posnr_n
                        qcode           = ls_mapp-qcode

                        mkey            = ls_9060-mkey
                        qprice          = ls_mapp-qprice
                        conf_price      = ls_mapp-netpr_o
                        qwaerk          = ls_mapp-qwaerk

                        aenam           = sy-uname
                        aedat           = sy-datum
                        aezeit          = sy-uzeit
                        aedatlo         = sy-datlo
                        aetimlo         = sy-timlo

                        ind-mkey        = '01'
                        ind-qprice      = '01'
                        ind-conf_price  = '01'
                        ind-qwaerk      = '01'

                        ind-aenam       = '01'
                        ind-aedat       = '01'
                        ind-aezeit      = '01'
                        ind-aedatlo     = '01'
                        ind-aetimlo     = '01'
                       ).
      APPEND ls_0066 TO lt_0066.
    ENDIF.

  ENDLOOP.

*-- 9060 저장 수행
  TRY.
      MODIFY : zgtsdt9060 FROM TABLE lt_9060.

    CATCH cx_sy_open_sql_db INTO DATA(lo_sql).
      DATA(lv_msg) = lo_sql->get_text( ).
      ROLLBACK WORK.
  ENDTRY.

  IF lv_msg IS INITIAL AND lt_0066[] IS NOT INITIAL.
*-- Table : ZGTSDT0066 Update 수행
    TRY.
        UPDATE zgtsdt0066 FROM TABLE @lt_0066
                          INDICATORS SET STRUCTURE ind.
      CATCH cx_sy_open_sql_db INTO lo_sql.
        lv_msg = lo_sql->get_text( ).
        ROLLBACK WORK.
    ENDTRY.
  ENDIF.

  IF lv_msg IS INITIAL.
    COMMIT WORK AND WAIT.
    MESSAGE s011.
  ELSE.
    MESSAGE s012 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form popup_to_confirm
*&---------------------------------------------------------------------*
*& Pop-Up 창 수행
*&---------------------------------------------------------------------*
*&      --> PV_TITLE     : Popup 창 제목
*&      --> PV_QUESTION  : Popup 질의 내용 정보
*&      <-- PV_ANSWER    : 선택 정보 리턴
*&---------------------------------------------------------------------*
FORM popup_to_confirm  USING    pv_title
                                pv_question
                       CHANGING pv_answer    TYPE char01.

  CLEAR pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = pv_title
      text_question         = pv_question
      text_button_1         = 'Yes'
      text_button_2         = 'No'
      display_cancel_button = abap_false
    IMPORTING
      answer                = pv_answer
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form del_mapping_data
*&---------------------------------------------------------------------*
*& As-Is vs. To-Be 판매오더 Mapping 정보 삭제 수행
*&---------------------------------------------------------------------*
FORM del_mapping_data .

  DATA : lt_9060   TYPE gty_t_9060,
         lt_0066   TYPE gty_t_0066_u,

         lv_answer TYPE char01.

*-----------------------------------------------------------------------
*-- To-Be 저장정보 유무 확인
*-----------------------------------------------------------------------
  WITH +key_info AS ( SELECT a~job_no_n, a~posnr_n
                        FROM @gt_mapp AS a
                       GROUP BY a~job_no_n, a~posnr_n )

    SELECT SINGLE @abap_true
      FROM zgtsdt0065 AS a INNER JOIN +key_info AS b
                              ON a~job_no EQ b~job_no_n
                             AND a~posnr  EQ b~posnr_n
     WHERE a~zsystem_id EQ @gc_sysid-kbdm

      INTO @DATA(lv_flag).

  IF sy-subrc EQ 0.
    MESSAGE s000 WITH 'To-Be 저장정보가 있습니다.'(e19)
                 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  PERFORM popup_to_confirm          USING    'Mapping 데이터 삭제'(t05)
                                             'ASIS vs. TOBE 판매오더 Mapping 정보를 삭제하시겠습니까?'(m03)
                                    CHANGING lv_answer.
  IF lv_answer NE '1'.
    MESSAGE s050.
    EXIT.
  ENDIF.

*-----------------------------------------------------------------------
*-- ALV 화면 정보 기준 삭제 정보 구성
*-----------------------------------------------------------------------
*-- ALV 정보 기준 Table : ZGTSDT9060 삭제 Key 정보 Select
  WITH +key_info AS ( SELECT a~zpjno_o, a~job_no_o, a~vbeln_o, a~posnr_o
                        FROM @gt_mapp AS a
                       GROUP BY a~zpjno_o, a~job_no_o, a~vbeln_o, a~posnr_o )

    SELECT a~zpjno,    a~job_no_o,  a~vbeln,   a~posnr

      FROM zgtsdt9060 AS a INNER JOIN +key_info AS b
                              ON a~zpjno    EQ b~zpjno_o
                             AND a~job_no_o EQ b~job_no_o
                             AND a~vbeln    EQ b~vbeln_o
                             AND a~posnr    EQ b~posnr_o
     ORDER BY a~zpjno, a~job_no_o, a~vbeln, a~posnr

      INTO CORRESPONDING FIELDS OF TABLE @lt_9060.

*-- ALV 정보 기준 Table : ZGTSDT0066 삭제 Key 정보 Select
  WITH +key_info AS ( SELECT a~job_no_n, a~posnr_n, a~qcode
                        FROM @gt_mapp AS a
                       GROUP BY a~job_no_n, a~posnr_n, a~qcode )

    SELECT a~zsystem_id,  a~job_no,  a~posnr,  a~qcode

      FROM zgtsdt0066 AS a INNER JOIN +key_info AS b
                              ON a~job_no EQ b~job_no_n
                             AND a~posnr  EQ b~posnr_n
                             AND a~qcode  EQ b~qcode
     WHERE a~zsystem_id EQ @gc_sysid-kbdm
       AND a~mkey       IS NOT INITIAL

      INTO TABLE @DATA(lt_66_key).

*-- Table : ZGTSDT0066 MKEY 정보 삭제 정보 구성

  LOOP AT lt_66_key INTO DATA(ls_66_key).
    APPEND VALUE #(
                    zsystem_id  = ls_66_key-zsystem_id
                    job_no      = ls_66_key-job_no
                    posnr       = ls_66_key-posnr
                    qcode       = ls_66_key-qcode

                    mkey        = abap_false

                    aenam       = sy-uname
                    aedat       = sy-datum
                    aezeit      = sy-uzeit
                    aedatlo     = sy-datlo
                    aetimlo     = sy-timlo
                    aetcode     = sy-tcode

                    ind-mkey    = '01'
                    ind-aenam   = '01'
                    ind-aezeit  = '01'
                    ind-aedatlo = '01'
                    ind-aetimlo = '01'
                    ind-aetcode = '01'
                  ) TO lt_0066.

  ENDLOOP.

*-- 해당 정보 없을경우 오류 메세지 구성
  IF lt_9060[] IS INITIAL OR
     lt_0066[] IS INITIAL.

    MESSAGE s000 WITH '삭제할 데이터가 존재하지 않습니다.'(e07).
    EXIT.
  ENDIF.

*-----------------------------------------------------------------------
*-- 해당 Table 삭제 처리
*-----------------------------------------------------------------------
  IF lt_9060[] IS NOT INITIAL.
    TRY.
        DELETE : zgtsdt9060 FROM TABLE @lt_9060.
      CATCH cx_sy_open_sql_db INTO DATA(lo_sql).
        DATA(lv_msg) = lo_sql->get_text( ).
        ROLLBACK WORK.
    ENDTRY.
  ENDIF.

  IF lv_msg    IS INITIAL AND
     lt_0066[] IS NOT INITIAL.
    TRY.
        UPDATE zgtsdt0066 FROM TABLE @lt_0066
                          INDICATORS SET STRUCTURE ind.
      CATCH cx_sy_open_sql_db INTO lo_sql.
        lv_msg = lo_sql->get_text( ).
        ROLLBACK WORK.
    ENDTRY.
  ENDIF.

  IF lv_msg IS INITIAL.
    COMMIT WORK AND WAIT.
    MESSAGE s013.
  ELSE.
    MESSAGE s014 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_to_be_data
*&---------------------------------------------------------------------*
*& To-Be 정보 저장 수행
*&---------------------------------------------------------------------*
FORM save_to_be_data .

  DATA : lt_0065   TYPE gty_t_0065,
         ls_0065   TYPE gty_0065,

         lv_answer TYPE char01.

  PERFORM popup_to_confirm          USING    'To-Be 데이터 저장'(t06)
                                             'To-Be 데이터를 저장하시겠습니까?'(m04)
                                    CHANGING lv_answer.
  IF lv_answer NE '1'.
    MESSAGE s050.
    EXIT.
  ENDIF.

*-----------------------------------------------------------------------
*-- TO-BE 저장 정보 구성
*-----------------------------------------------------------------------
  SELECT SINGLE @abap_true
    FROM @gt_tobe AS a
   WHERE a~stat EQ @gc_led-red

    INTO @DATA(lv_flag).

  IF sy-subrc EQ 0.
*-- Red LED 정보 있을경우 오류 메세지 구성 & Exit
    MESSAGE s000 WITH 'To-Be 정보 확인 필요합니다.'(m07)
                 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 이전 저장 정보 Select
  WITH +key_info AS ( SELECT a~mreqno, a~zpjno, a~job_no, a~posnr
                        FROM @gt_tobe AS a
                       GROUP BY a~mreqno, a~zpjno, a~job_no, a~posnr )

    SELECT a~zsystem_id,  a~mreqno,   a~zpjno,   a~job_no,  a~posnr,
           a~ernam,       a~erdat,    a~erzeit,  a~erdatlo,
           a~ertimlo,     a~ertcode,  a~erempno

      FROM zgtsdt0065 AS a INNER JOIN +key_info AS b
                              ON a~job_no EQ b~job_no
                             AND a~posnr  EQ b~posnr

     WHERE a~zsystem_id EQ @gc_sysid-kbdm
       AND a~zstat      EQ @gc_zstat-m
     ORDER BY a~zsystem_id, a~mreqno, a~zpjno, a~job_no, a~posnr

      INTO TABLE @DATA(lt_0065_t).

*-- 저장 정보 구성S
  LOOP AT gt_tobe INTO DATA(ls_tobe).
    CLEAR ls_0065.

    ls_0065 = VALUE #(
                       zsystem_id    = gc_sysid-kbdm
                       mreqno        = ls_tobe-mreqno
                       zpjno         = ls_tobe-zpjno
                       job_no        = ls_tobe-job_no
                       posnr         = ls_tobe-posnr
                       item_key      = ls_tobe-item_key
                       zdelv_date    = ls_tobe-zdelv_date
                       matnr         = ls_tobe-matnr
                       maktx         = ls_tobe-maktx
                       werks         = ls_tobe-werks
                       kwmeng        = ls_tobe-kwmeng
                       meins         = ls_tobe-meins
                       ord_len       = ls_tobe-ord_len
                       ord_wgt       = ls_tobe-ord_wgt
                       voltage_cd    = ls_tobe-voltage_cd
                       prod_type     = ls_tobe-prod_type
                       wire_cnt      = ls_tobe-wire_cnt
                       amphere       = ls_tobe-amphere
                       cond_mtrl     = ls_tobe-cond_mtrl
                       duct_mtrl_est = ls_tobe-duct_mtrl_est
                       ground_type   = ls_tobe-ground_type
                       ipgrade       = ls_tobe-ipgrade
                       condtw        = ls_tobe-condtw
                       grspec        = ls_tobe-grspec
                       stdname       = ls_tobe-stdname
                       serialno      = ls_tobe-serialno
                       ecoptype      = ls_tobe-ecoptype
                       n_wire_type   = ls_tobe-n_wire_type
                       brkmd         = ls_tobe-brkmd
                       framph        = ls_tobe-framph
                       opmthd        = ls_tobe-opmthd
                       phtap         = ls_tobe-phtap
                       chr_key       = ls_tobe-chr_key
                       ojob_no       = ls_tobe-ojob_no

                       zstat         = ls_tobe-zstat
                     ).

    READ TABLE lt_0065_t WITH KEY zsystem_id = ls_0065-zsystem_id
                                  mreqno     = ls_0065-mreqno
                                  zpjno      = ls_0065-zpjno
                                  job_no     = ls_0065-job_no
                                  posnr      = ls_0065-posnr
                         INTO DATA(ls_0065_t).
    IF sy-subrc EQ 0.
      ls_0065 = VALUE #( BASE ls_0065
                          ernam   = ls_0065_t-ernam
                          erdat   = ls_0065_t-erdat
                          erzeit  = ls_0065_t-erzeit
                          erdatlo = ls_0065_t-erdatlo
                          ertimlo = ls_0065_t-ertimlo
                          ertcode = ls_0065_t-ertcode
                          erempno = ls_0065_t-erempno

                          aenam   = sy-uname
                          aedat   = sy-datum
                          aezeit  = sy-uzeit
                          aedatlo = sy-datlo
                          aetimlo = sy-timlo
                       ).
    ELSE.
      ls_0065 = VALUE #( BASE ls_0065
                          ernam   = sy-uname
                          erdat   = sy-datum
                          erzeit  = sy-uzeit
                          erdatlo = sy-datlo
                          ertimlo = sy-timlo
                       ).
    ENDIF.

    APPEND ls_0065 TO lt_0065.

  ENDLOOP.

  CHECK lt_0065[] IS NOT INITIAL.
*-----------------------------------------------------------------------
*-- 저장 수행
*-----------------------------------------------------------------------
  TRY.
      MODIFY zgtsdt0065 FROM TABLE lt_0065.
    CATCH cx_sy_open_sql_db INTO DATA(lo_sql).
      DATA(lv_msg) = lo_sql->get_text( ).
      ROLLBACK WORK.
  ENDTRY.

  IF lv_msg IS INITIAL.
*-- 저장 성공인 경우 ALV 화면 기준 저장 상태값 값 구성
    ls_tobe-save_stat = icon_led_green.

    MODIFY gt_tobe FROM ls_tobe TRANSPORTING save_stat
                   WHERE stat      NE gc_led-red
                     AND save_stat EQ icon_led_inactive.

    COMMIT WORK AND WAIT.
    MESSAGE s011.
  ELSE.
    MESSAGE s012 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_del_data
*&---------------------------------------------------------------------*
*& 삭제 대상 Upload Data 조회
*&---------------------------------------------------------------------*
*&      <-- PV_EFLAG  : 오류 발생시 'X' 리턴
*&---------------------------------------------------------------------*
FORM select_del_data  CHANGING pv_eflag  TYPE char01.

  CLEAR : pv_eflag,
          gt_mapp, gt_tobe.

  CASE abap_true.
    WHEN p_del_m.           " Mapping 조회/삭제
      PERFORM select_saved_mapp_data.

    WHEN p_del_t.           " To-Be 조회/삭제
      PERFORM select_saved_tobe_data.

    WHEN p_del_o.           " 판매오더 조회/삭제
      PERFORM select_crted_order_data.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form del_to_be_data
*&---------------------------------------------------------------------*
*& To-Be 정보 삭제 수행
*&---------------------------------------------------------------------*
FORM del_to_be_data .

  DATA : lt_0065   TYPE gty_t_0065,

         lv_answer TYPE char01.

*-----------------------------------------------------------------------
*-- DB Table 기준 판매오더 생성여부 확인
*-----------------------------------------------------------------------
  WITH +key_info AS ( SELECT a~mreqno, a~zpjno, a~job_no, a~posnr
                        FROM @gt_tobe AS a
                       GROUP BY a~mreqno, a~zpjno, a~job_no, a~posnr )

    SELECT a~vbeln,  a~posnr,  a~werks,  a~matnr

      FROM zgtsdt0065 AS a INNER JOIN +key_info AS b
                              ON a~zsystem_id EQ @gc_sysid-kbdm
                             AND a~mreqno     EQ b~mreqno
                             AND a~zpjno      EQ b~zpjno
                             AND a~job_no     EQ b~job_no
                             AND a~posnr      EQ b~posnr

     WHERE a~vbeln IS NOT INITIAL

      INTO TABLE @DATA(lt_chk).

  IF sy-subrc EQ 0.
*-- 생성된 판매오더 정보 있을경우 해당 판매오더 제고 여부 확인
    SELECT SINGLE @abap_true
      FROM mska AS a INNER JOIN @lt_chk AS b
                        ON a~werks EQ b~werks
                       AND a~matnr EQ b~matnr
                       AND a~vbeln EQ b~vbeln
                       AND a~posnr EQ b~posnr
     WHERE a~kalab NE 0

      INTO @DATA(lv_flag).

    IF sy-subrc EQ 0.
      MESSAGE s000 WITH '판매오더 재고가 존재합니다.'(e17)
                   DISPLAY LIKE 'E'.
    ELSE.
      MESSAGE s000 WITH '생성된 판매오더 정보가 있습니다'(e14)
                   DISPLAY LIKE 'E'.
      lv_flag = abap_true.

    ENDIF.
  ENDIF.

  IF lv_flag EQ abap_true.
    EXIT.
  ENDIF.

  PERFORM popup_to_confirm          USING    'To-Be 데이터 삭제'(t07)
                                             'TO-BE 데이터를 삭제하시겠습니까?'(m05)
                                    CHANGING lv_answer.
  IF lv_answer NE '1'.
    MESSAGE s050.
    EXIT.
  ENDIF.

*-----------------------------------------------------------------------
*-- ALV 화면 정보 기준 삭제 정보 구성
*-----------------------------------------------------------------------
*-- ALV 정보 기준 Table : ZGTSDT0065 삭제 Key 정보 Select
  WITH +key_info AS ( SELECT a~mreqno, a~zpjno, a~job_no, a~posnr
                        FROM @gt_tobe AS a
                       GROUP BY a~mreqno, a~zpjno, a~job_no, a~posnr )

    SELECT a~zsystem_id,  a~mreqno,  a~zpjno,  a~job_no,  a~posnr

      FROM zgtsdt0065 AS a INNER JOIN +key_info AS b
                              ON a~zsystem_id EQ @gc_sysid-kbdm
                             AND a~mreqno     EQ b~mreqno
                             AND a~zpjno      EQ b~zpjno
                             AND a~job_no     EQ b~job_no
                             AND a~posnr      EQ b~posnr
     WHERE a~vbeln IS INITIAL
     ORDER BY a~zsystem_id, a~mreqno, a~zpjno, a~job_no, a~posnr

      INTO CORRESPONDING FIELDS OF TABLE @lt_0065.

*-- 해당 정보 없을경우 오류 메세지 구성
  IF lt_0065[] IS INITIAL.

    MESSAGE s000 WITH '삭제할 데이터가 존재하지 않습니다.'(e07).
    EXIT.
  ENDIF.

*-----------------------------------------------------------------------
*-- 해당 Table 삭제 처리
*-----------------------------------------------------------------------
  TRY.
      DELETE zgtsdt0065 FROM TABLE @lt_0065.
    CATCH cx_sy_open_sql_db INTO DATA(lo_sql).
      DATA(lv_msg) = lo_sql->get_text( ).
      ROLLBACK WORK.
  ENDTRY.

  IF lv_msg IS INITIAL.
    COMMIT WORK AND WAIT.
    MESSAGE s013.
  ELSE.
    MESSAGE s014 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form crte_so_to_be
*&---------------------------------------------------------------------*
*& To-BE 판매오더 생성 수행
*&---------------------------------------------------------------------*
FORM crte_so_to_be .

  DATA : ls_header      TYPE bapisdhd1,
         ls_headerx     TYPE bapisdhd1x,
         ls_ord_view    TYPE order_view,

         lt_return      TYPE bapiret2_tt,
         ls_return      TYPE bapiret2,

         lt_item        TYPE bapisditm_tt,
         lt_itemx       TYPE crmt_bapisditmx_t,
         lt_schd        TYPE wiso_t_schdl,
         lt_schdx       TYPE oij_bapischdlx_t,
         lt_parnr       TYPE vlc_bapiparnr_t,
         lt_cond        TYPE vlc_bapicond_t,
         lt_condx       TYPE crmt_bapicondx_t,
         lt_cfgs_ref    TYPE bapicucfg_t,
         lt_cfgs_inst   TYPE bapicuins_t,
         lt_cfgs_part   TYPE bapicuprt_t,
         lt_cfgs_val    TYPE bapicuval_t,
         lt_extn_in     TYPE bapiparex_t,

         lt_sdhd_asis   TYPE wiso_t_sdhd,
         lt_sdit_asis   TYPE wiso_t_sdit,
         lt_sditst_asis TYPE bapisditstt,
         lt_schd_asis   TYPE bapisdhedutab,
         lt_sdbu_asis   TYPE gty_t_sdbu,
         lt_sdpart_asis TYPE bapisdpartt,
         lt_cond_asis   TYPE bapisdcondt,
         lt_curefm_asis TYPE cod_t_bapicurefm,
         lt_cuvalm_asis TYPE cod_t_bapicuvalm,

         lt_cfgs        TYPE gty_t_cfgs,
         lt_quote       TYPE gty_t_quote,

         lt_tobe        TYPE gty_t_tobe,
         ls_tobe        TYPE gty_tobe,

         lv_cfg_id      TYPE cux_cfg_id,
         lv_vbeln       TYPE vbeln_va,

         lv_answer      TYPE char01.

  lt_tobe[] = CORRESPONDING #( gt_tobe[] ).

*-- 판매오더 생성된 리스트는 제외
  DELETE lt_tobe WHERE vbeln IS NOT INITIAL.

  SORT lt_tobe BY zpjno job_no vbeln posnr.
*-----------------------------------------------------------------------
*-- ALV 출력 리스트 기준 TO-BE 생성 가능 여부 확인
*-----------------------------------------------------------------------
  IF lt_tobe[] IS INITIAL.
    MESSAGE s000 WITH '판매오더 생성 가능 정보가 없습니다.'(e22)
                 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  SELECT SINGLE @abap_true
    FROM @lt_tobe AS a
   WHERE a~stat      EQ @gc_led-red
      OR a~save_stat NE @icon_led_green

    INTO @DATA(lv_flag).

  IF sy-subrc EQ 0.
    MESSAGE s000 WITH 'TO-BE 데이터가 정상적으로 저장되지 않았습니다.'(e08)
                 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  PERFORM popup_to_confirm          USING    'To-Be 판매오더 생성'(t08)
                                             'To-Be 판매오더를 생성하시겠습니까?'(m06)
                                    CHANGING lv_answer.
  IF lv_answer NE '1'.
    MESSAGE s050.
    EXIT.
  ENDIF.

*-----------------------------------------------------------------------
*-- 1. 판매오더 생성 정보 구성
*-----------------------------------------------------------------------
*-- 1-1. 품목-견적품 Mapping 정보 기준 Conditions 추가 정보 Select
  WITH +key_info AS ( SELECT a~job_no, a~posnr
                        FROM @lt_tobe AS a
                       GROUP BY a~job_no, a~posnr )

    SELECT a~job_no,  a~posnr,  a~qprice,  a~qqty,
           a~qwaerk
      FROM zgtsdt0066 AS a INNER JOIN +key_info AS b
                              ON a~job_no EQ b~job_no
                             AND a~posnr  EQ b~posnr

     ORDER BY a~job_no, a~posnr

      INTO TABLE @lt_quote.

*-- 1-2. 공통코드 정보 기준 주문속성 해당 필드 정보 Select
  SELECT a~fld_04 AS charc,           " To-Be 특성명
         a~fld_06 AS charc_a,         " As-Is 특성명
         a~fld_03 AS fname            " To-Be 특성 정보 필드명
    FROM zgtppt1010 AS a
   WHERE a~module_kind EQ 'SD'
     AND a~codegrp     EQ '0063'
     AND a~fld_01      EQ @gc_sysid-kbdm

    INTO TABLE @lt_cfgs.


*-- 1-3. Item 정보 기준 자재 추가 정보 Select
  WITH +mat_key AS ( SELECT a~werks, a~matnr
                       FROM @lt_tobe AS a
                      GROUP BY a~werks, a~matnr )

    SELECT a~werks,  a~matnr,  a~stdpd,
           c~meins,  c~mtart

      FROM marc AS a INNER JOIN +mat_key AS b
                        ON a~werks EQ b~werks
                       AND a~matnr EQ b~matnr

                     INNER JOIN mara AS c
                        ON a~matnr EQ c~matnr

     ORDER BY a~werks, a~matnr

      INTO TABLE @DATA(lt_mat_info).

*-- 1-4. To-Be 연결정보 기준 As-Is 판매오더 정보 Select
  WITH +job_no AS ( SELECT a~job_no, a~posnr
                      FROM @lt_tobe AS a
                     GROUP BY a~job_no, a~posnr )

    SELECT a~job_no,  c~vbeln

      FROM zgtsdt0066 AS a INNER JOIN +job_no AS b
                              ON a~job_no EQ b~job_no
                             AND a~posnr  EQ b~posnr

                           INNER JOIN zgtsdt9060 AS c
                              ON a~mkey EQ c~mkey

     GROUP BY a~job_no, c~vbeln

      INTO TABLE @DATA(lt_asis).

*-----------------------------------------------------------------------
*-- 2. 제조지시 번호 기준 판매오더 생성 수행
*-----------------------------------------------------------------------

  ls_ord_view = VALUE #(
                        header     = abap_true            " Header
                        business   = abap_true            " Business
                        partner    = abap_true            " Partner
                       ).

  LOOP AT lt_tobe INTO DATA(ls_key)
                  GROUP BY ( zpjno  = ls_key-zpjno
                             job_no = ls_key-job_no
                             size   = GROUP SIZE
                             index  = GROUP INDEX )
                  ASSIGNING FIELD-SYMBOL(<itm_grp>).

*-- 2-1. As-Is 판매오더 정보 구성
    READ TABLE lt_asis WITH KEY job_no = <itm_grp>-job_no
                       INTO DATA(ls_asis).

    PERFORM get_sd_ordr_detail      USING    ls_asis-vbeln
                                             ls_ord_view
                                    CHANGING lt_sdhd_asis
                                             lt_sdit_asis
                                             lt_sditst_asis
                                             lt_schd_asis
                                             lt_sdbu_asis
                                             lt_sdpart_asis
                                             lt_cond_asis
                                             lt_curefm_asis
                                             lt_cuvalm_asis.

    CHECK lt_sdhd_asis[] IS NOT INITIAL.

    CLEAR : ls_header,   ls_headerx,   ls_tobe,
            lt_return,   lt_item,      lt_itemx,     lt_parnr,
            lt_cond,     lt_condx,     lt_schd,      lt_schdx,
            lt_cfgs_ref, lt_cfgs_inst, lt_cfgs_part, lt_cfgs_val,
            lt_extn_in,
            lv_vbeln,    lv_cfg_id.


*-- 2-2. As_Is 기준 To-Be 판매오더 Header 정보 구성
    PERFORM init_sd_header_info     USING    lt_sdhd_asis
                                             lt_sdbu_asis
                                             <itm_grp>-job_no
                                    CHANGING ls_header
                                             ls_headerx.

*-- 2-3. As_Is 기준 To-Be 판매오더 Partner 정보 구성
    PERFORM init_sd_partner_info    USING    lt_sdpart_asis
                                    CHANGING lt_parnr.

*-- 2-4. Header 추가 Z필드 값 구성
    PERFORM init_extn_head_info     USING    <itm_grp>-zpjno
                                    CHANGING lt_extn_in.

    READ TABLE lt_sdhd_asis INDEX 1 INTO DATA(ls_sdhd_asis).

    LOOP AT GROUP <itm_grp> ASSIGNING FIELD-SYMBOL(<ls_itm_lst>).
      ADD 1 TO lv_cfg_id.

      READ TABLE lt_mat_info WITH KEY werks = <ls_itm_lst>-werks
                                      matnr = <ls_itm_lst>-matnr
                             INTO DATA(ls_mat_info).
      CONDENSE ls_mat_info-stdpd.

*-- 2-5. ALV 화면 정보 기준 Item 정보 구성
      APPEND VALUE #(
                      itm_number = <ls_itm_lst>-posnr               " 품목번호
                      item_categ = gc_pstyv-zbis                    " 아이템 카테코리
                      material   = <ls_itm_lst>-matnr               " 자재코드
                      plant      = <ls_itm_lst>-werks               " 플랜트
                      target_qty = <ls_itm_lst>-kwmeng              " 수량
                      target_qu  = ls_mat_info-meins                " 수량 단위
                      po_itm_no  = <ls_itm_lst>-posnr               " 기초구매오더 품목번호
                    ) TO lt_item.

      APPEND VALUE #(
                      itm_number = <ls_itm_lst>-posnr               " 품목번호
                      item_categ = abap_true                        " 아이템 카테고리
                      material   = abap_true                        " 자재코드
                      plant      = abap_true                        " 플랜트
                      target_qty = abap_true                        " 수량
                      target_qu  = abap_true                        " 수량 단위
                      po_itm_no  = abap_true
                    ) TO lt_itemx.

*-- 2-6. ALV 화면 정보 기준 스케쥴 정보 구성
      APPEND VALUE #(
                      itm_number = <ls_itm_lst>-posnr               " 품목번호
                      sched_line = 1                                " 일정 라인 번호
                      req_date   = <ls_itm_lst>-zdelv_date          " 일정 라인 일자
                      date_type  = gc_prgrs-1                       " 일자 유형
                      req_qty    = <ls_itm_lst>-kwmeng              " 오더 수량
                    ) TO lt_schd.

      APPEND VALUE #(
                      itm_number = <ls_itm_lst>-posnr               " 품목번호
                      sched_line = 1                                " 일정 라인 번호
                      req_date   = COND #( WHEN <ls_itm_lst>-zdelv_date IS NOT INITIAL THEN abap_true
                                           ELSE abap_true )         " 일정 라인 일자
                      date_type  = abap_true                        " 일자 유형
                      req_qty    = abap_true                        " 오더 수량
                    ) TO lt_schdx.


*-- 2-6. 견적품 단가, 수량 정보 기준 Condition 정보 구성
      IF ls_sdhd_asis-sd_doc_cat EQ gc_vbtyp-c.
*        판매오더 인 경우 Condition 정보 구성
        PERFORM init_sd_cond_info   USING    <ls_itm_lst>
                                             lt_quote
                                    CHANGING lt_cond
                                             lt_condx.
      ENDIF.

*-- 2-7. 속성 정보 구성
      IF ls_mat_info-mtart EQ gc_mtart-fert.
        PERFORM init_sd_cfgs_info   USING    <ls_itm_lst>
                                             lt_cfgs
                                             ls_mat_info-stdpd
                                             lv_cfg_id
                                    CHANGING lt_cfgs_ref
                                             lt_cfgs_inst
                                             lt_cfgs_val.
      ENDIF.
    ENDLOOP.

    CASE ls_sdhd_asis-sd_doc_cat.
      WHEN gc_vbtyp-c.
*-- 2-8-1. 제조지시 번호 기준 판매오더 생성 BAPI 수행
        CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
          EXPORTING
            order_header_in      = ls_header
            order_header_inx     = ls_headerx
          IMPORTING
            salesdocument        = lv_vbeln
          TABLES
            return               = lt_return
            order_items_in       = lt_item
            order_items_inx      = lt_itemx
            order_partners       = lt_parnr
            order_schedules_in   = lt_schd
            order_schedules_inx  = lt_schdx
            order_conditions_in  = lt_cond
            order_conditions_inx = lt_condx
            order_cfgs_ref       = lt_cfgs_ref
            order_cfgs_inst      = lt_cfgs_inst
            order_cfgs_part_of   = lt_cfgs_part
            order_cfgs_value     = lt_cfgs_val
            extensionin          = lt_extn_in.

      WHEN gc_vbtyp-b.
*-- 2-8-2. 제조지시 번호 기준 견적오더 생성 BAPI 수행
        CALL FUNCTION 'BAPI_QUOTATION_CREATEFROMDATA2'
          EXPORTING
            quotation_header_in     = ls_header
            quotation_header_inx    = ls_headerx
          IMPORTING
            salesdocument           = lv_vbeln
          TABLES
            return                  = lt_return
            quotation_items_in      = lt_item
            quotation_items_inx     = lt_itemx
            quotation_partners      = lt_parnr
            quotation_schedules_in  = lt_schd
            quotation_schedules_inx = lt_schdx
            quotation_cfgs_ref      = lt_cfgs_ref
            quotation_cfgs_inst     = lt_cfgs_inst
            quotation_cfgs_part_of  = lt_cfgs_part
            quotation_cfgs_value    = lt_cfgs_val
            extensionin             = lt_extn_in.

    ENDCASE.

*-----------------------------------------------------------------------
*-- 3. 판매오더 생성 결과 기준 DB 저장 수행
*-----------------------------------------------------------------------
    IF lv_vbeln IS NOT INITIAL.
*-- 3-1. 생성 성공인 경우 성공 메세지 Read
      READ TABLE lt_return WITH KEY type   = 'S'
                                    id     = 'V1'
                                    number = '311'
                           INTO ls_return.
      IF sy-subrc NE 0.
        READ TABLE lt_return WITH KEY type = 'S'
                             INTO ls_return.
      ENDIF.
    ELSE.
*-- 3-2. 생성 실패인 경우 Rollback Work
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      READ TABLE lt_return WITH KEY type = 'E'
                           INTO ls_return.
    ENDIF.

*-- 3-4. 판매오더 생성 결과 DB 저장 수행
    TRY.
        UPDATE : zgtsdt0065 SET vbeln   = lv_vbeln
                                zstat   = ls_return-type
                                zmsg    = ls_return-message

                                aenam   = sy-uname
                                aedat   = sy-datum
                                aezeit  = sy-uzeit
                                aedatlo = sy-datlo
                                aetimlo = sy-timlo
                                aetcode = sy-tcode
                            WHERE zpjno  EQ <itm_grp>-zpjno
                              AND job_no EQ <itm_grp>-job_no,

                 zgtsdt0066 SET vbeln   = lv_vbeln

                                aenam   = sy-uname
                                aedat   = sy-datum
                                aezeit  = sy-uzeit
                                aedatlo = sy-datlo
                                aetimlo = sy-timlo
                                aetcode = sy-tcode
                          WHERE job_no EQ <itm_grp>-job_no.

      CATCH cx_sy_open_sql_db INTO DATA(lo_sql_db).
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.        "--> DB Update 실패시 Rollback Work 수행

        DATA(lv_msg) = lo_sql_db->get_text( ).
        ls_return-type    = |E|.
        ls_return-message = lv_msg.

    ENDTRY.

    IF ls_return-type EQ 'S' AND
       lv_msg         IS INITIAL.
*-- 처리결과 기준 Rollback Work 가 아닌 경우 Commit Work
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_false.
    ENDIF.
*-----------------------------------------------------------------------
*-- 4. 처리결과 ALV 화면 반영
*-----------------------------------------------------------------------
    ls_tobe-stat  = COND #( WHEN ls_return-type EQ 'E' THEN gc_led-red
                            WHEN ls_return-type EQ 'S' THEN gc_led-green ).
    ls_tobe-zmsg  = ls_return-message.
    ls_tobe-vbeln = lv_vbeln.

    MODIFY gt_tobe FROM ls_tobe
                   TRANSPORTING vbeln stat zmsg
                   WHERE zpjno  EQ <itm_grp>-zpjno
                     AND job_no EQ <itm_grp>-job_no
                     AND vbeln  IS INITIAL.
    CLEAR lv_msg.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_sd_ordr_detail
*&---------------------------------------------------------------------*
*& 판매오더 기준 해당 오더 정보 확인
*&---------------------------------------------------------------------*
*&      --> PV_VBELN    : 판매오더 번호 정보
*&      --> PS_ORD_VIEW : 판매오더 정보 확인 항목 정보
*&      <-- PT_SDHD     : 판매오더 Header 정보 리턴
*&      <-- PT_SDIT     : 판매오더 Item 정보 리턴
*&      <-- PT_SDITST   : 판매오더 Item Status 정보 리턴
*&      <-- PT_SDBU     : 판매오더 비즈니스 정보 리턴
*&      <-- PT_PART     : 판매오더 파트너 정보 리턴
*&      <-- PT_COND     : 판매오더 Conditions 정보 리턴
*&      <-- PT_CUREFM   : 구성정보 참조 오더항목 정보 리턴
*&      <-- PT_CUVALM   : 품목기준 구성 특성값 정보 리턴
*&---------------------------------------------------------------------*
FORM get_sd_ordr_detail  USING    pv_vbeln    TYPE vbeln_va
                                  ps_ord_view TYPE order_view
                         CHANGING pt_sdhd     TYPE wiso_t_sdhd
                                  pt_sdit     TYPE wiso_t_sdit
                                  pt_sditst   TYPE bapisditstt
                                  pt_schd     TYPE bapisdhedutab
                                  pt_sdbu     TYPE gty_t_sdbu
                                  pt_part     TYPE bapisdpartt
                                  pt_cond     TYPE bapisdcondt
                                  pt_curefm   TYPE cod_t_bapicurefm
                                  pt_cuvalm   TYPE cod_t_bapicuvalm..

  DATA : lt_sd_key   TYPE mds_sales_key_tab.

  CLEAR : pt_sdhd, pt_sdit, pt_sdbu, pt_part, pt_cond, pt_curefm, pt_cuvalm,
          pt_schd, pt_sditst,
          lt_sd_key.

  CHECK pv_vbeln IS NOT INITIAL.

  APPEND VALUE #(
                  vbeln          = pv_vbeln               " 판매오더 번호
                ) TO lt_sd_key.

*-- 정보 기준 판매오더 정보 Get BAPI 수행
  CALL FUNCTION 'BAPISDORDER_GETDETAILEDLIST'
    EXPORTING
      i_bapi_view           = ps_ord_view
    TABLES
      sales_documents       = lt_sd_key
      order_headers_out     = pt_sdhd
      order_items_out       = pt_sdit
      order_statusitems_out = pt_sditst
      order_schedules_out   = pt_schd
      order_business_out    = pt_sdbu
      order_partners_out    = pt_part
      order_conditions_out  = pt_cond
      order_cfgs_curefs_out = pt_curefm
      order_cfgs_cuvals_out = pt_cuvalm.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_sd_header_info
*&---------------------------------------------------------------------*
*& 판매오더 Header 정보 구성
*&---------------------------------------------------------------------*
*&      --> PT_SDHD_ASIS  : As-Is Header 정보
*&      --> PT_SDBU_ASIS  : As-IS 비즈니스 정보
*&      --> PV_JOB_NO     : To-Be 제조지시 번호
*&      <-- PS_HEADER    : 판매오더 Header 정보 리턴
*&      <-- PS_HEADERX   : 판매오더 Header 입력 필드 정보 리턴
*&---------------------------------------------------------------------*
FORM init_sd_header_info  USING    pt_sdhd_asis   TYPE wiso_t_sdhd
                                   pt_sdbu_asis   TYPE gty_t_sdbu
                                   pv_job_no      TYPE zgte_bd_jobno
                          CHANGING ps_header      TYPE bapisdhd1
                                   ps_headerx     TYPE bapisdhd1x.

  CONSTANTS : lc_1740 TYPE vkbur VALUE '1740',
              lc_1710 TYPE vkbur VALUE '1710',

              lc_175  TYPE vkgrp VALUE '175',
              lc_172  TYPE vkgrp VALUE '172'.

  READ TABLE pt_sdhd_asis INDEX 1 INTO DATA(ls_sdhd).
  READ TABLE pt_sdbu_asis INDEX 1 INTO DATA(ls_sdbu).

*-- Header 정보 구성
  ps_header = VALUE #(
                       doc_type    = ls_sdhd-doc_type               " 오더 유형
                       sales_org   = ls_sdhd-sales_org              " 영업조직
                       distr_chan  = ls_sdhd-distr_chan             " 유통 경로
                       division    = ls_sdhd-division               " 제품군
                       sales_grp   = COND #( WHEN ls_sdhd-sales_grp EQ lc_175  THEN lc_172
                                             ELSE ls_sdhd-sales_grp
                                           )                        " 영업 그룹
                       sales_off   = COND #( WHEN ls_sdhd-sales_off EQ lc_1740 THEN lc_1710
                                             ELSE ls_sdhd-sales_off
                                           )                        " 영업팀
                       req_date_h  = ls_sdhd-req_date_h             " 납품요청일
                       purch_date  = ls_sdhd-purch_date             " 고객 구매오더일
                       doc_date    = ls_sdhd-doc_date               " 증빙일
                       purch_no_c  = pv_job_no                      " 제조지시번호
                       price_date  = ls_sdbu-price_date             " 가격결정일
                       incoterms1  = ls_sdbu-incoterms1             " 인코텀스(파트 1)
                       pmnttrms    = ls_sdbu-pmnttrms               " 지급 조건 키
                       incoterms2l = ls_sdbu-incoterms2l            " 인도조건(파트2)
                       currency    = ls_sdhd-currency               " SD 통화단위
                     ).

*-- Header 입력 필드 정보 구성
  ps_headerx = VALUE #(
                       updateflag  = 'I'                            " 갱신지시자
                       doc_type    = COND #( WHEN ps_header-doc_type    IS NOT INITIAL THEN abap_true
                                             ELSE abap_false )      " 오더 유형
                       sales_org   = COND #( WHEN ps_header-sales_org   IS NOT INITIAL THEN abap_true
                                             ELSE abap_false )      " 영업조직
                       distr_chan  = COND #( WHEN ps_header-distr_chan  IS NOT INITIAL THEN abap_true
                                             ELSE abap_false )      " 유통 경로
                       division    = COND #( WHEN ps_header-division    IS NOT INITIAL THEN abap_true
                                             ELSE abap_false )      " 제품군
                       sales_grp   = COND #( WHEN ps_header-sales_grp   IS NOT INITIAL THEN abap_true
                                             ELSE abap_false )      " 영업 그룹
                       sales_off   = COND #( WHEN ps_header-sales_off   IS NOT INITIAL THEN abap_true
                                             ELSE abap_false )      " 영업팀
                       req_date_h  = COND #( WHEN ps_header-req_date_h  IS NOT INITIAL THEN abap_true
                                             ELSE abap_false )      " 납품요청일
                       purch_date  = COND #( WHEN ps_header-purch_date  IS NOT INITIAL THEN abap_true
                                             ELSE abap_false )      " 고객 구매오더일
                       doc_date    = COND #( WHEN ps_header-doc_date    IS NOT INITIAL THEN abap_true
                                             ELSE abap_false )      " 증빙일
                       purch_no_c  = COND #( WHEN ps_header-purch_no_c  IS NOT INITIAL THEN abap_true
                                             ELSE abap_false )      " 제조지시번호
                       price_date  = COND #( WHEN ps_header-price_date  IS NOT INITIAL THEN abap_true
                                             ELSE abap_false )      " 가격결정일
                       incoterms1  = COND #( WHEN ps_header-incoterms1  IS NOT INITIAL THEN abap_true
                                             ELSE abap_false )      " 인코텀스(파트 1)
                       pmnttrms    = COND #( WHEN ps_header-pmnttrms    IS NOT INITIAL THEN abap_true
                                             ELSE abap_false )      " 지급 조건 키
                       incoterms2l = COND #( WHEN ps_header-incoterms2l IS NOT INITIAL THEN abap_true
                                             ELSE abap_false )      " 인도조건(파트2)
                       currency    = COND #( WHEN ps_header-currency    IS NOT INITIAL THEN abap_true
                                             ELSE abap_false )      " SD 통화단위
                      ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_sd_partner_info
*&---------------------------------------------------------------------*
*& 판매오더 Partner 정보 구성
*&---------------------------------------------------------------------*
*&      --> PT_PART_ASIS  : As-Is 기준 파트너 정보
*&      <-- PT_PARNR      : 판매오더 파트너 정보 리턴
*&---------------------------------------------------------------------*
FORM init_sd_partner_info  USING    pt_part_asis  TYPE bapisdpartt
                           CHANGING pt_parnr      TYPE vlc_bapiparnr_t.

*-- As-Is 판매오더 정보 기준 파트너 정보 구성
  LOOP AT pt_part_asis INTO DATA(ls_part_asis).
    APPEND VALUE #(
                    partn_role  = ls_part_asis-partn_role
                    partn_numb  = COND #( WHEN ls_part_asis-customer  IS NOT INITIAL THEN ls_part_asis-customer
                                          WHEN ls_part_asis-vendor_no IS NOT INITIAL THEN ls_part_asis-vendor_no )
                  ) TO pt_parnr.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_sd_cond_info
*&---------------------------------------------------------------------*
*& Item & 견적품 수량 단가 정보 기준 Condition 정보 구성
*&---------------------------------------------------------------------*
*&      --> PS_ITEM   : ALV 기준 To-Be Item 정보
*&      --> PT_QUOTE  : 견적품 단가 / 수량 정보
*&      <-- PT_COND   : 판매오더 Conditions 정보 리턴
*&      <-- PT_CONDX  : 판매오더 Conditions 입력 필드 정보 리턴
*&---------------------------------------------------------------------*
FORM init_sd_cond_info  USING    ps_item   TYPE gty_tobe
                                 pt_quote  TYPE gty_t_quote
                        CHANGING pt_cond   TYPE vlc_bapicond_t
                                 pt_condx  TYPE crmt_bapicondx_t.

  DATA : lv_quote_val TYPE bapikbetr1,
         lv_cond_val  TYPE bapikbetr1,
         lv_waerk     TYPE waerk.

  CONSTANTS : lc_zpr0 TYPE kscha VALUE 'ZPR0',  " 수기가격
              lc_zib0 TYPE kscha VALUE 'ZIB0'.  " 품목금액할인(정가)

*-- 품목기준 견적품 가격 계산
  WITH +amount AS ( SELECT a~qprice * a~qqty AS amt,
                           a~qwaerk
                      FROM @pt_quote AS a
                     WHERE a~job_no EQ @ps_item-job_no
                       AND a~posnr  EQ @ps_item-posnr )

    SELECT SINGLE SUM( a~amt ),
                  a~qwaerk

      FROM +amount AS a
     GROUP BY a~qwaerk

      INTO ( @lv_quote_val, @lv_waerk ).

  lv_cond_val = COND #( WHEN ps_item-kwmeng NE 0 THEN lv_quote_val / ps_item-kwmeng
                        ELSE 0 ).

  CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
    EXPORTING
      i_runit     = '0.01'
      i_value     = lv_cond_val
    IMPORTING
      e_value_rnd = lv_cond_val.

*-- ZPR0 Condition 정보 구성 - 견적품 금액 & Item 수량 기준 Set 금액 정보 구성 -
  APPEND VALUE #(
                  itm_number = ps_item-posnr
                  cond_type  = lc_zpr0
                  cond_value = lv_cond_val
                  currency   = lv_waerk
                ) TO pt_cond.

  APPEND VALUE #(
                  itm_number = ps_item-posnr
                  cond_type  = lc_zpr0
                  cond_value = abap_true
                  currency   = abap_true
                ) TO pt_condx.

  CHECK ( lv_quote_val - ( lv_cond_val * ps_item-kwmeng ) ) NE 0.

*-- Set 가준
  APPEND VALUE #(
                  itm_number = ps_item-posnr
                  cond_type  = lc_zib0
                  cond_value = ( lv_quote_val - ( lv_cond_val * ps_item-kwmeng ) )
                  currency   = lv_waerk
                ) TO pt_cond.

  APPEND VALUE #(
                  itm_number = ps_item-posnr
                  cond_type  = lc_zib0
                  cond_value = abap_true
                  currency   = abap_true
                ) TO pt_condx.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_MAPP_alv_f_excel
*&---------------------------------------------------------------------*
*& Mapping 정보 Excel Upload 정보 기준 ALV 출력 정보 구성
*&---------------------------------------------------------------------*
*&      --> PT_EXCL_MAPP  : Excel Upload 정보
*&      <-- PT_MAPP       : ALV 출력 정보 리턴
*&      <-- PV_EFLAG      : 오류 정보 있을경우 'X' 리턴
*&---------------------------------------------------------------------*
FORM init_mapp_alv_f_excel  USING    pt_excl_mapp  TYPE gty_t_excel_mapp
                            CHANGING pt_mapp       TYPE gty_t_mapp
                                     pv_eflag      TYPE char01.

  DATA : ls_mapp   TYPE gty_mapp,
         " ls_ord_view    TYPE order_view,
         "  ls_sdhd_asis   TYPE bapisdhd,

         lt_sd_key TYPE mds_sales_key_tab.
*         lt_sdhd_asis   TYPE wiso_t_sdhd,
*         lt_sdit_asis   TYPE wiso_t_sdit,
*         lt_sditst_asis TYPE bapisditstt,
*         lt_schd_asis   TYPE bapisdhedutab,
*         lt_sdbu_asis   TYPE gty_t_sdbu,
*         lt_sdpart_asis TYPE bapisdpartt,
*         lt_cond_asis   TYPE bapisdcondt,
*         lt_curefm_asis TYPE cod_t_bapicurefm,
*         lt_cuvalm_asis TYPE cod_t_bapicuvalm.

**-- As-Is 판매오더 정보 구성
*  ls_ord_view = VALUE #(
*                        header     = abap_true            " Header
*                        item       = abap_true            " Item
*                        status_i   = abap_true            " Item Status
*                       ).

*-- As-Is 판매문서 기준 특성 정보 Select
  WITH +so_key AS ( SELECT a~vbeln_o
                      FROM @pt_excl_mapp AS a
                     GROUP BY a~vbeln_o )

    SELECT a~vbeln,  c~kposn,  c~kbetr,  c~kwert

      FROM vbak AS a INNER JOIN +so_key AS b
                        ON a~vbeln EQ b~vbeln_o

                     INNER JOIN konv AS c
                        ON a~knumv EQ c~knumv

     WHERE c~kschl EQ @gc_kschl-zpr0            " 수기가격

     ORDER BY a~vbeln, c~kposn

      INTO TABLE @DATA(lt_cond_db).

*-- As-Is 판매문서 정보 Select
  WITH +so_key AS ( SELECT a~vbeln_o, a~posnr_o
                      FROM @pt_excl_mapp AS a
                     GROUP BY a~vbeln_o, a~posnr_o )

    SELECT a~vbeln,  a~posnr,  a~cuobj,  a~lfrel,  a~lfsta,
           c~waerk

      FROM vbap AS a INNER JOIN +so_key AS b
                        ON a~vbeln EQ b~vbeln_o
                       AND a~posnr EQ b~posnr_o

                     INNER JOIN vbak AS c
                        ON a~vbeln EQ c~vbeln

     ORDER BY a~vbeln, a~posnr

      INTO TABLE @DATA(lt_asis_so).

*-- ZGTSDT0066 Key 정보 기준 중복 정보 체크
  WITH +key_cnt AS ( SELECT a~job_no_n, a~posnr_n, a~qcode,
                            COUNT( * ) AS cnt
                       FROM @pt_excl_mapp AS a
                      GROUP BY a~job_no_n, a~posnr_n, a~qcode )

    SELECT a~job_no_n AS job_no,
           a~posnr_n  AS posnr,
           a~qcode, a~cnt

      FROM +key_cnt AS a

      INTO TABLE @DATA(lt_66_key_cnt).

*-----------------------------------------------------------------------
*-- ALV 출력 정보 구성
*-----------------------------------------------------------------------
  LOOP AT pt_excl_mapp INTO DATA(ls_mapp_key)
                       GROUP BY ( zpjno_o  = ls_mapp_key-zpjno_o
                                  job_no_o = ls_mapp_key-job_no_o
                                  vbeln_o  = ls_mapp_key-vbeln_o
                                  size     = GROUP SIZE )
                       ASSIGNING FIELD-SYMBOL(<excl_mapp>).
*    CLEAR ls_sdhd_asis.
*
*    PERFORM get_sd_ordr_detail      USING    <excl_mapp>-vbeln_o
*                                             ls_ord_view
*                                    CHANGING lt_sdhd_asis
*                                             lt_sdit_asis
*                                             lt_sditst_asis
*                                             lt_schd_asis
*                                             lt_sdbu_asis
*                                             lt_sdpart_asis
*                                             lt_cond_asis
*                                             lt_curefm_asis
*                                             lt_cuvalm_asis.
*-- As-Is Header 정보 Read
*    READ TABLE lt_sdhd_asis INDEX 1 INTO ls_sdhd_asis.

    LOOP AT GROUP <excl_mapp> ASSIGNING FIELD-SYMBOL(<ls_excl_mapp>).
      CLEAR : ls_mapp.

      ls_mapp = CORRESPONDING #( <ls_excl_mapp> ).

*-- Table : ZGTSDT0066 Key 정보 기준 중복 확인
      SELECT SINGLE @abap_true
        FROM @lt_66_key_cnt AS a
       WHERE a~job_no EQ @ls_mapp-job_no_n
         AND a~posnr  EQ @ls_mapp-posnr_n
         AND a~qcode  EQ @ls_mapp-qcode
         AND a~cnt    GT 1

        INTO @DATA(lv_chk).

      IF sy-subrc EQ 0.
        ls_mapp-stat    = gc_led-red.
        ls_mapp-zmsg    = '판매오더 품목-견적품 Mapping 정보 Key 중복 확인'.
      ENDIF.

*-- 해당 As-Is 판매오더 품목 기준 Read
      READ TABLE lt_asis_so WITH KEY vbeln = ls_mapp-vbeln_o
                                     posnr = ls_mapp-posnr_o
                            INTO DATA(ls_asis_so).
      IF sy-subrc NE 0.
        CLEAR ls_asis_so.
      ENDIF.

*-- As-Is 품목 Condition 정보 기준 단가 / 금액 정보 구성
      READ TABLE lt_cond_db WITH KEY vbeln = ls_mapp-vbeln_o
                                     kposn = ls_mapp-posnr_o
                            INTO DATA(ls_cond_db).
      IF sy-subrc EQ 0.
        ls_mapp-netpr_o = ls_mapp-qprice = ls_cond_db-kbetr.
        ls_mapp-netwr_o = ls_mapp-qamt   = ls_cond_db-kwert.

        ls_mapp-waerk_o = ls_mapp-qwaerk = ls_asis_so-waerk.
*        ls_mapp-waerk_o = ls_mapp-qwaerk = ls_sdhd_asis-currency.

      ENDIF.

      IF ls_asis_so-lfrel IS NOT INITIAL AND
         ls_mapp-stat     NE gc_led-red.
*-- As-Is 판매오더 품목 기준 거부사유 여부 확인
        ls_mapp-stat    = gc_led-red.
        ls_mapp-zmsg    = 'As-Is 판매오더 거부사유 확인 하십시요.'(e09).
      ENDIF.

*      READ TABLE lt_sdit_asis WITH KEY doc_number = ls_mapp-vbeln_o
*                                       itm_number = ls_mapp-posnr_o
*                              INTO DATA(ls_sdit_asis).
*
*      IF sy-subrc                EQ 0 AND
*         ls_sdit_asis-rea_for_re IS NOT INITIAL.
**-- As-Is 판매오더 품목 기준 거부사유 여부 확인
*        ls_mapp-stat    = gc_led-red.
*        ls_mapp-zmsg    = 'As-Is 판매오더 거부사유 확인 하십시요.'(e09).
*      ENDIF.

*-- As-Is 판매오더 품목 기준 처리완료 여부 확인
      IF ls_asis_so-lfsta EQ gc_lfsta-c AND
         ls_mapp-stat     NE gc_led-red.
        ls_mapp-stat    = gc_led-red.
        ls_mapp-zmsg    = '처리완료 된 판매오더 입니다.'(e16).
      ENDIF.
*      READ TABLE lt_sditst_asis WITH KEY sd_doc     = ls_mapp-vbeln_o
*                                         itm_number = ls_mapp-posnr_o
*                                         deliv_stat = gc_lfsta-c
*                                TRANSPORTING NO FIELDS.
*      IF sy-subrc     EQ 0 AND
*         ls_mapp-stat NE gc_led-red.
*        ls_mapp-stat    = gc_led-red.
*        ls_mapp-zmsg    = '처리완료 된 판매오더 입니다.'(e16).
*      ENDIF.

*-- 견적품 정보 As-Is 판매오더 특성정보 대비 확인
      IF ls_mapp-stat NE gc_led-red.
        PERFORM chk_mapp_charc_info_i
                                    USING    ls_asis_so-cuobj  "ls_sdit_asis-config
                                    CHANGING ls_mapp.
      ENDIF.

      IF ls_mapp-stat NE gc_led-red.
*-- Mapping 상태 정보 구성 - Row 기준 수량 & 단위 정보 확인
        ls_mapp-stat    = COND #( WHEN ls_mapp-kwmeng_o NE ls_mapp-qqty  THEN gc_led-red
                                  WHEN ls_mapp-vrkme_o  NE ls_mapp-qunit THEN gc_led-red ).

        ls_mapp-zmsg    = COND #( WHEN ls_mapp-kwmeng_o NE ls_mapp-qqty  THEN '수량 정보가 일치하지 않습니다.'(e05)
                                  WHEN ls_mapp-vrkme_o  NE ls_mapp-qunit THEN '수량 단위가 일치하지 않습니다.'(e06) ).
      ENDIF.

      ls_mapp-stat      = COND #( WHEN ls_mapp-stat IS NOT INITIAL THEN ls_mapp-stat
                                  ELSE gc_led-green ).

      APPEND ls_mapp TO pt_mapp.
    ENDLOOP.
  ENDLOOP.

*  LOOP AT pt_excl_mapp INTO DATA(ls_excl_mapp).
*    CLEAR : ls_mapp.
*
*    ls_mapp = CORRESPONDING #( ls_excl_mapp ).
*
**-- As-Is 판매오더 정보 구성
*
*    PERFORM get_sd_ordr_detail      USING    ls_mapp-vbeln_o
*                                    CHANGING lt_sdhd_asis
*                                             lt_sdit_asis
*                                             lt_schd_asis
*                                             lt_sdbu_asis
*                                             lt_sdpart_asis
*                                             lt_cond_asis
*                                             lt_curefm_asis
*                                             lt_cuvalm_asis.
*
**-- As-Is 판매오더 품목 기준 거부사유 여부 확인
*    READ TABLE lt_sdit_asis WITH KEY doc_number = ls_mapp-vbeln_o
*                                     itm_number = ls_mapp-posnr_o
*                                     rea_for_re = gc_abgru-08
*                            TRANSPORTING NO FIELDS.
*    IF sy-subrc EQ 0.
*      ls_mapp-stat   = gc_led-red.
*      ls_mapp-zmsg   = 'As-Is 판매오더 거부사유 확인 하십시요.'(e09).
*    ENDIF.
*
**-- As-Is 품목 Condition 정보 기준 단가 / 금액 정보 구성
*    READ TABLE lt_cond_asis WITH KEY sd_doc     = ls_mapp-vbeln_o
*                                     itm_number = ls_mapp-posnr_o
*                                     cond_type  = gc_kschl-zpr0
*                            INTO DATA(ls_cond).
*    IF sy-subrc EQ 0.
*
*      PERFORM bapi_curr_conv_int  : USING    ls_cond-sdcurrency
*                                             ls_cond-cond_value
*                                    CHANGING ls_mapp-netpr_o,
*
*                                    USING    ls_cond-sdcurrency
*                                             ls_cond-cond_value
*                                    CHANGING ls_mapp-qprice,
*
*                                    USING    ls_cond-sdcurrency
*                                             ls_cond-condvalue
*                                    CHANGING ls_mapp-netwr_o,
*
*                                    USING    ls_cond-sdcurrency
*                                             ls_cond-condvalue
*                                    CHANGING ls_mapp-qamt.
*
*      ls_mapp-waerk_o = ls_mapp-qwaerk = ls_cond-sdcurrency.
*
*    ENDIF.
*
**-- 견적품 정보 As-Is 판매오더 특성정보 대비 확인
*    IF ls_mapp-stat NE gc_led-red.
*      PERFORM chk_mapp_charc_info   USING    lt_curefm_asis
*                                             lt_cuvalm_asis
*                                    CHANGING ls_mapp.
*    ENDIF.
*
*    IF ls_mapp-stat NE gc_led-red.
**-- Mapping 상태 정보 구성 - Row 기준 수량 & 단위 정보 확인
*      ls_mapp-stat   = COND #( WHEN ls_mapp-kwmeng_o NE ls_mapp-qqty  THEN gc_led-red
*                               WHEN ls_mapp-vrkme_o  NE ls_mapp-qunit THEN gc_led-red ).
*
*      ls_mapp-zmsg   = COND #( WHEN ls_mapp-kwmeng_o NE ls_mapp-qqty  THEN '수량 정보가 일치하지 않습니다.'(e05)
*                               WHEN ls_mapp-vrkme_o  NE ls_mapp-qunit THEN '수량 단위가 일치하지 않습니다.'(e06) ).
*    ENDIF.
*
*    ls_mapp-stat     = COND #( WHEN ls_mapp-stat IS NOT INITIAL THEN ls_mapp-stat
*                               ELSE gc_led-green ).
*
*    APPEND ls_mapp TO pt_mapp.
*  ENDLOOP.

  IF pt_mapp[] IS INITIAL.
    pv_eflag = abap_true.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_sd_ordr_detail_mult
*&---------------------------------------------------------------------*
*& 여러개의 판매오더 정보 확인 BAPI 수행
*&---------------------------------------------------------------------*
*&      --> PT_SD_KEY  : 해당 판매오더 정보
*&      <-- PT_SDHD    : 판매오더 Header 정보 리턴
*&      <-- PT_SDIT    : 판매오더 Item 정보 리턴
*&      <-- PT_SDBU_   : 판매오더 비즈니스 정보 리턴
*&      <-- PT_PART    : 판매오더 파트너 정보 리턴
*&      <-- PT_COND    : 판매오더 Conditions 정보 리턴
*&      <-- PT_CUREFM  : 구성정보 참조 오더항목 정보 리턴
*&      <-- PT_CUVALM  : 품목기준 구성 특성값 정보 리턴
*&---------------------------------------------------------------------*
FORM get_sd_ordr_detail_mult  USING    pt_sd_key TYPE mds_sales_key_tab
                              CHANGING pt_sdhd   TYPE wiso_t_sdhd
                                       pt_sdit   TYPE wiso_t_sdit
                                       pt_sdbu   TYPE gty_t_sdbu
                                       pt_part   TYPE bapisdpartt
                                       pt_cond   TYPE bapisdcondt
                                       pt_curefm TYPE cod_t_bapicurefm
                                       pt_cuvalm TYPE cod_t_bapicuvalm.


  DATA : ls_ord_view TYPE order_view.

  CLEAR : pt_sdhd, pt_sdit, pt_sdbu, pt_part,
          ls_ord_view.

  CHECK pt_sd_key[] IS NOT INITIAL.

*-- 조회 판매오더 정보 구성
  ls_ord_view = VALUE #(
                        header    = abap_true             " Header
                        item      = abap_true             " Item
                        business  = abap_true             " Business
                        partner   = abap_true             " Partner
                        sdcond    = abap_true             " Condition
                        configure = abap_true             " Configuration
                       ).

*-- 정보 기준 판매오더 정보 Get BAPI 수행
  CALL FUNCTION 'BAPISDORDER_GETDETAILEDLIST'
    EXPORTING
      i_bapi_view           = ls_ord_view
    TABLES
      sales_documents       = pt_sd_key
      order_headers_out     = pt_sdhd
      order_items_out       = pt_sdit
      order_business_out    = pt_sdbu
      order_partners_out    = pt_part
      order_conditions_out  = pt_cond
      order_cfgs_curefs_out = pt_curefm
      order_cfgs_cuvals_out = pt_cuvalm.

  SORT : pt_sdhd   BY doc_number,
         pt_sdit   BY doc_number itm_number,
         pt_sdbu   BY sd_doc itm_number,
         pt_part   BY sd_doc itm_number,
         pt_cond   BY sd_doc itm_number cond_st_no,
         pt_curefm BY sd_doc posex,
         pt_cuvalm BY operation sd_doc config_id inst_id.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form chk_mapp_charc_info
*&---------------------------------------------------------------------*
*& Mapping Upload 정보 특성값 정합성 확인
*&---------------------------------------------------------------------*
*&      --> PT_CUREFM  : 특성 정보 기준 오더항목/인스턴스 정보
*&      --> PT_CUVALM  : 특성 구성값 정보
*&      <-- PS_MAPP    : Mapping Upload 정보 & 정합성 체크 정보 리턴
*&---------------------------------------------------------------------*
FORM chk_mapp_charc_info  USING    pt_curefm  TYPE cod_t_bapicurefm
                                   pt_cuvalm  TYPE cod_t_bapicuvalm
                          CHANGING ps_mapp    TYPE gty_mapp.

  CONSTANTS : lc_qcode TYPE cu_charc VALUE 'PD_BD_PROD_NAME',
              lc_qname TYPE cu_charc VALUE 'PD_BD_PROD_NAME_01'.

*-- As-Is 판매오더 정보 기준 Mapping 정보 견적품 값 정합성 확인
  READ TABLE pt_curefm WITH KEY sd_doc = ps_mapp-vbeln_o
                                posex  = ps_mapp-posnr_o
                       INTO DATA(ls_curefm).
  IF sy-subrc NE 0.
    ps_mapp-stat = gc_led-red.
    ps_mapp-zmsg = 'Mapping 견적품 특성정보 확인'(e10).
    EXIT.
  ENDIF.

*-- 견적품 코드 확인
  READ TABLE pt_cuvalm WITH KEY operation = ls_curefm-operation
                                sd_doc    = ls_curefm-sd_doc
                                config_id = ls_curefm-config_id
                                inst_id   = ls_curefm-inst_id
                                charc     = lc_qcode
                       INTO DATA(ls_cuvalm).
  IF NOT ( sy-subrc        EQ 0 AND
           ls_cuvalm-value EQ ps_mapp-qcode ).
    ps_mapp-stat = gc_led-red.
    ps_mapp-zmsg = 'Mapping 견적품코드 특성정보 확인'(e11).
  ENDIF.

  CHECK ps_mapp-stat NE gc_led-red.

*-- 견적품명 확인
  READ TABLE pt_cuvalm WITH KEY operation = ls_curefm-operation
                                sd_doc    = ls_curefm-sd_doc
                                config_id = ls_curefm-config_id
                                inst_id   = ls_curefm-inst_id
                                charc     = lc_qname
                       INTO ls_cuvalm.
  IF NOT ( sy-subrc        EQ 0 AND
           ls_cuvalm-value EQ ps_mapp-qname ).
    ps_mapp-stat = gc_led-red.
    ps_mapp-zmsg = 'Mapping 견적품명 특성정보 확인'(e12).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_tobe_alv_f_excel
*&---------------------------------------------------------------------*
*& To-Be 정보 Excel Upload 정보 기준 ALV 출력 정보 구성
*&---------------------------------------------------------------------*
*&      --> PT_EXCL_TOBE  : Excel Upload 정보
*&      <-- PT_TOBE       : ALV 출력 정보 리턴
*&      <-- PV_EFLAG      : 오류 정보 있을경우 'X' 리턴
*&---------------------------------------------------------------------*
FORM init_tobe_alv_f_excel  USING    pt_excl_tobe  TYPE gty_t_excel_tobe
                            CHANGING pt_tobe       TYPE gty_t_tobe
                                     pv_eflag      TYPE char01.

  DATA : ls_tobe      TYPE gty_tobe,
*         ls_ord_view    TYPE order_view,

         lt_sd_key    TYPE mds_sales_key_tab,
*         lt_sdhd_asis   TYPE wiso_t_sdhd,
         lt_sdit_asis TYPE wiso_t_sdit,
*         lt_sditst_asis TYPE bapisditstt,
*         lt_schd_asis   TYPE bapisdhedutab,
*         lt_sdbu_asis   TYPE gty_t_sdbu,
*         lt_sdpart_asis TYPE bapisdpartt,
*         lt_cond_asis   TYPE bapisdcondt,
*         lt_curefm_asis TYPE cod_t_bapicurefm,
*         lt_cuvalm_asis TYPE cod_t_bapicuvalm,

         lt_cfgs      TYPE gty_t_cfgs,
         lt_cfgs_mapp TYPE gty_t_cfgs_mapp,
         lt_asis      TYPE gty_t_asis.

*-----------------------------------------------------------------------
*-- ALV 출력 & 정합성 확인 정보 구성
*-----------------------------------------------------------------------
*-- 자재마스터 정보 Select
  WITH +mat_no AS ( SELECT a~werks, a~matnr
                      FROM @pt_excl_tobe AS a
                     GROUP BY a~werks, a~matnr )

    SELECT a~werks, a~matnr,  a~stdpd,  c~maktx
      FROM marc AS a INNER JOIN +mat_no AS b
                        ON a~werks EQ b~werks
                       AND a~matnr EQ b~matnr

                     INNER JOIN makt AS c
                        ON a~matnr EQ c~matnr
                       AND c~spras EQ @sy-langu

     ORDER BY a~werks, a~matnr

      INTO TABLE @DATA(lt_mat).

*-- To-Be 연결정보 기준 As-Is 판매오더 정보 Select
  WITH +job_no AS ( SELECT a~job_no, a~posnr
                      FROM @pt_excl_tobe AS a
                     GROUP BY a~job_no, a~posnr )

    SELECT a~job_no,  a~posnr AS posnr_t,
           c~vbeln,   c~posnr

      FROM zgtsdt0066 AS a INNER JOIN +job_no AS b
                              ON a~job_no EQ b~job_no
                             AND a~posnr  EQ b~posnr

                           INNER JOIN zgtsdt9060 AS c
                              ON a~mkey EQ c~mkey

     ORDER BY a~job_no, a~posnr, c~vbeln, c~posnr

      INTO CORRESPONDING FIELDS OF TABLE @lt_asis.

  WITH +so_key AS ( SELECT a~vbeln, a~posnr
                      FROM @lt_asis AS a
                     GROUP BY a~vbeln, a~posnr )

    SELECT a~vbeln  AS doc_number,
           a~posnr  AS itm_number,
           a~vrkme  AS sales_unit,
           a~abgru  AS rea_for_re,
           a~kwmeng AS req_qty,

           a~cuobj  AS config

      FROM vbap AS a INNER JOIN +so_key AS b
                        ON a~vbeln EQ b~vbeln
                       AND a~posnr EQ b~posnr

     ORDER BY a~vbeln, a~posnr

      INTO CORRESPONDING FIELDS OF TABLE @lt_sdit_asis.

*-- As-Is / To-Be 주문 특성 정보 Select
  SELECT a~fld_04 AS charc,           " To-Be 특성명
         a~fld_06 AS charc_a,         " As-Is 특성명
         a~fld_03 AS fname            " To-Be 특성 정보 필드명
    FROM zgtppt1010 AS a
   WHERE a~module_kind EQ 'SD'
     AND a~codegrp     EQ '0063'
     AND a~fld_01      EQ @gc_sysid-kbdm
     AND a~fld_06      IS NOT INITIAL

    INTO TABLE @lt_cfgs.

*-- AS_IS / To-Be 특성 코드 Mapping 정보 Select
  SELECT a~fld_04 AS atnam_a,
         a~fld_05 AS atwrt_a,
         a~fld_06 AS atnam_t,
         a~fld_07 AS atwrt_t

    FROM zgtppt1010 AS a
   WHERE a~module_kind EQ 'SD'
     AND a~codegrp     EQ '0064'
     AND a~fld_01      EQ @gc_sysid-kbdm

   INTO TABLE @lt_cfgs_mapp.

*-- 판매오더 생성된 To-Be 저장 정보 Select
  WITH +key_info AS ( SELECT a~mreqno, a~zpjno, a~job_no, a~posnr
                        FROM @pt_excl_tobe AS a
                       GROUP BY a~mreqno, a~zpjno, a~job_no, a~posnr )

    SELECT a~zsystem_id,  a~mreqno,  a~zpjno,  a~job_no,
           a~posnr,       a~vbeln,   a~zstat,  a~zmsg

      FROM zgtsdt0065 AS a INNER JOIN +key_info AS b
                              ON a~zsystem_id EQ @gc_sysid-kbdm
                             AND a~mreqno     EQ b~mreqno
                             AND a~zpjno      EQ b~zpjno
                             AND a~job_no     EQ b~job_no
                             AND a~posnr      EQ b~posnr
     WHERE a~vbeln IS NOT INITIAL

    ORDER BY a~zsystem_id, a~mreqno, a~zpjno, a~job_no, a~posnr

     INTO TABLE @DATA(lt_saved_65).

**-- As-Is 판매오더 정보 구성
*  ls_ord_view = VALUE #(
*                        header     = abap_true            " Header
*                        item       = abap_true            " Item
*                       ).

*-----------------------------------------------------------------------
*-- ALV 출력 정보 구성
*-----------------------------------------------------------------------
  LOOP AT pt_excl_tobe INTO DATA(ls_tobe_key)
                       GROUP BY ( zpjno  = ls_tobe_key-zpjno
                                  job_no = ls_tobe_key-job_no )
                       ASSIGNING FIELD-SYMBOL(<excl_tobe>).

*-- 제조지시 번호 기준 As-Is 판매오더 정보 Read
    READ TABLE lt_asis WITH KEY job_no = <excl_tobe>-job_no
                       INTO DATA(ls_asis).
    IF sy-subrc NE 0.
      CLEAR ls_asis.
    ENDIF.
*
**-- As-Is 판매오더 정보 구성
*    PERFORM get_sd_ordr_detail      USING    ls_asis-vbeln
*                                             ls_ord_view
*                                    CHANGING lt_sdhd_asis
*                                             lt_sdit_asis
*                                             lt_sditst_asis
*                                             lt_schd_asis
*                                             lt_sdbu_asis
*                                             lt_sdpart_asis
*                                             lt_cond_asis
*                                             lt_curefm_asis
*                                             lt_cuvalm_asis.

    LOOP AT GROUP <excl_tobe> ASSIGNING FIELD-SYMBOL(<ls_excl_tobe>).
      CLEAR : ls_tobe.

*-- Excel Upload 기준 값 기본 구성
      ls_tobe = CORRESPONDING #( <ls_excl_tobe> ).

      ls_tobe-vbeln_o   = ls_asis-vbeln.                  " As-Is 판매문서
      ls_tobe-zstat     = gc_zstat-m.                     " Migration Flag 값 구성
      ls_tobe-save_stat = icon_led_inactive.              " To-Be 저장  상태 기본값

*-- 자재 정보 Read
      READ TABLE lt_mat WITH KEY werks = ls_tobe-werks
                                 matnr = ls_tobe-matnr
                        INTO DATA(ls_mat).
      IF sy-subrc NE 0.
        CLEAR ls_mat.
      ENDIF.

      ls_tobe-maktx     = ls_mat-maktx.

*-- As-Is 저장 정보 - Table : ZGTSDT9060, ZGTSDT0066 - 유무 확인
      READ TABLE lt_asis WITH KEY job_no  = ls_tobe-job_no
                                  posnr_t = ls_tobe-posnr
                         TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        ls_tobe-stat    = gc_led-red.
        ls_tobe-zmsg    = 'As-Is, Mapping 정보가 없습니다.'(e15).
      ENDIF.

      IF ls_tobe-stat NE gc_led-red.
*-- 동일한 Key 정보 기준 판매오더 생성된 정보 확인
        SELECT SINGLE a~vbeln
          FROM @lt_saved_65 AS a
         WHERE a~zsystem_id EQ @gc_sysid-kbdm
           AND a~mreqno     EQ @ls_tobe-mreqno
           AND a~zpjno      EQ @ls_tobe-zpjno
           AND a~job_no     EQ @ls_tobe-job_no
           AND a~posnr      EQ @ls_tobe-posnr

         INTO @ls_tobe-vbeln.

        IF sy-subrc EQ 0.
          ls_tobe-stat  = gc_led-red.
          ls_tobe-zmsg  = '생성된 판매오더 정보가 있습니다'(e14).
        ENDIF.
      ENDIF.

      IF ls_tobe-stat NE gc_led-red AND
         ls_tobe-kwmeng EQ 0.
        ls_tobe-stat    = gc_led-red.
        ls_tobe-zmsg    = '수량이 없습니다.'.
      ENDIF.

*-- 주문길이 정보 정합성 확인
      IF ls_tobe-stat NE gc_led-red.
        PERFORM chk_ord_len_f_asis_i
                                    USING    lt_asis
                                             lt_sdit_asis
                                    CHANGING ls_tobe.
      ENDIF.

*-- As-Is 특성정보 기준 To-Be 특성정보 값 확인
      IF ls_tobe-stat NE gc_led-red.

        PERFORM chk_cfgs_asis_data_i
                                    USING    lt_asis
                                             lt_sdit_asis
                                             lt_cfgs
                                             lt_cfgs_mapp
                                             ls_mat-stdpd
                                    CHANGING ls_tobe.


      ENDIF.

      IF ls_tobe-stat IS INITIAL.
        ls_tobe-stat = gc_led-yellow.
      ENDIF.

      APPEND ls_tobe TO pt_tobe.

    ENDLOOP.
  ENDLOOP.

*  LOOP AT pt_excl_tobe INTO DATA(ls_excl_tobe).
*    CLEAR : ls_tobe.
*
**-- Excel Upload 기준 값 기본 구성
*    ls_tobe = CORRESPONDING #( ls_excl_tobe ).
*
*    ls_tobe-zstat     = gc_zstat-m.                       " Migration Flag 값 구성
*    ls_tobe-save_stat = icon_led_inactive.                " To-Be 저장  상태 기본값
*
**-- 자재내역 정보 구성
*    READ TABLE lt_makt WITH KEY matnr = ls_tobe-matnr
*                       INTO DATA(ls_makt).
*    IF sy-subrc EQ 0.
*      ls_tobe-maktx = ls_makt-maktx.
*    ENDIF.
*
**-- 제조지시 번호 기준 As-Is 판매오더 정보 Read
*    READ TABLE lt_asis WITH KEY job_no = ls_tobe-job_no
*                       INTO DATA(ls_asis).
*    IF sy-subrc NE 0.
*      CLEAR ls_asis.
*    ENDIF.
*
*    ls_ord_view = VALUE #(
*                          header     = abap_true            " Header
*                          item       = abap_true            " Item
*                         ).
*
**-- As-Is 판매오더 정보 구성
*    PERFORM get_sd_ordr_detail      USING    ls_asis-vbeln
*                                             ls_ord_view
*                                    CHANGING lt_sdhd_asis
*                                             lt_sdit_asis
*                                             lt_schd_asis
*                                             lt_sdbu_asis
*                                             lt_sdpart_asis
*                                             lt_cond_asis
*                                             lt_curefm_asis
*                                             lt_cuvalm_asis.
*
**-- 동일한 Key 정보 기준 판매오더 생성된 정보 확인
*    SELECT SINGLE a~vbeln
*      FROM @lt_saved_65 AS a
*     WHERE a~zsystem_id EQ @gc_sysid-kbdm
*       AND a~mreqno     EQ @ls_tobe-mreqno
*       AND a~zpjno      EQ @ls_tobe-zpjno
*       AND a~job_no     EQ @ls_tobe-job_no
*       AND a~posnr      EQ @ls_tobe-posnr
*
*     INTO @ls_tobe-vbeln.
*
*    IF sy-subrc EQ 0.
*      ls_tobe-stat = gc_led-red.
*      ls_tobe-zmsg = '생성된 판매오더 정보가 있습니다'(e14).
*    ENDIF.
*
**-- 주문길이 정보 정합성 확인
*    IF ls_tobe-stat NE gc_led-red.
*      PERFORM chk_ord_len_f_asis    USING    ls_asis-vbeln
*                                             lt_sdit_asis
*                                    CHANGING ls_tobe.
*    ENDIF.
*
**-- As-Is 특성정보 기준 To-Be 특성정보 값 확인
*    IF ls_tobe-stat NE gc_led-red.
*
*      PERFORM chk_cfgs_asis_data    USING    ls_asis-vbeln
*                                             lt_cfgs
*                                             lt_sdit_asis
*                                             lt_curefm_asis
*                                             lt_cuvalm_asis
*                                    CHANGING ls_tobe.
*
*
*    ENDIF.
*
*    IF ls_tobe-stat IS INITIAL.
*      ls_tobe-stat = gc_led-yellow.
*    ENDIF.
*
*    APPEND ls_tobe TO pt_tobe.
*  ENDLOOP.

  IF pt_tobe[] IS INITIAL.
    pv_eflag = abap_true.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form chk_ord_len_f_asis
*&---------------------------------------------------------------------*
*& As-Is 판매오더 품목 정보 기준 To-Be Set 길이( M ) 확인
*&---------------------------------------------------------------------*
*&      --> PV_VBELN  : As-Is 판매오더 번호 정보
*&      --> PT_SDIT   : As-Is 판매오더 Item 정보
*&      <-- PS_TOBE   : To-Be 정보 & 오류 정보 리턴
*&---------------------------------------------------------------------*
FORM chk_ord_len_f_asis  USING    pv_vbeln  TYPE vbeln_va
                                  pt_sdit   TYPE wiso_t_sdit
                         CHANGING ps_tobe   TYPE gty_tobe.

  DATA : lt_sdit TYPE TABLE OF bapisdit WITH EMPTY KEY.

  lt_sdit[] = CORRESPONDING #( pt_sdit[] ).

*-- As-Is 품목 기준 총 길이 합 과 To-Be 주문길이 값 확인
  WITH +as_is   AS ( SELECT a~vbeln, a~posnr
                       FROM zgtsdt9060 AS a INNER JOIN zgtsdt0066 AS b
                                               ON a~mkey EQ b~mkey
                      WHERE b~zsystem_id EQ @gc_sysid-kbdm
                        AND b~job_no     EQ @ps_tobe-job_no
                        AND b~posnr      EQ @ps_tobe-posnr
                      GROUP BY a~vbeln, a~posnr ),

       +ord_len AS ( SELECT SUM( a~req_qty ) AS ord_len
                       FROM @lt_sdit AS a INNER JOIN +as_is AS b
                                             ON a~doc_number EQ b~vbeln
                                            AND a~itm_number EQ b~posnr
                      WHERE a~sales_unit EQ @gc_unit-m
                        AND a~rea_for_re IS INITIAL )

    SELECT SINGLE a~ord_len
      FROM +ord_len AS a
      INTO @DATA(lv_ord_len).

*-- 주문길이 비교하여 다를 경우 오류 메세지 처리
  ps_tobe-stat = COND #( WHEN lv_ord_len NE ps_tobe-ord_len THEN gc_led-red
                         ELSE abap_false ).
  ps_tobe-zmsg = COND #( WHEN ps_tobe-stat EQ gc_led-red THEN '주문길이가 As-Is 값과 다릅니다.'(e13)
                         ELSE abap_false ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form chk_cfgs_asis_data
*&---------------------------------------------------------------------*
*& As-Is 특성정보 대비 To-Be Upload 특성값 확인
*&---------------------------------------------------------------------*
*&      --> PV_VBELN  : As-Is 판매오더 번호 정보
*&      --> PT_CFGS    : As-Is & To-Be 특성명 & 해당 필드명 정보
*&      <-- PT_SDIT    : As-Is 판매오더 Item 정보 리턴
*&      --> PT_CUREFM  : As-Is 특성 참조오더항목/인스턴스
*&      --> PT_CUVALM  : As-Is 특성 값 정보
*&      <-- PS_TOBE    : To-Be 특성 정보 & 오류 정보 리턴
*&---------------------------------------------------------------------*
FORM chk_cfgs_asis_data  USING    pv_vbeln   TYPE vbeln_va
                                  pt_cfgs    TYPE gty_t_cfgs
                                  pt_sdit    TYPE wiso_t_sdit
                                  pt_curefm  TYPE cod_t_bapicurefm
                                  pt_cuvalm  TYPE cod_t_bapicuvalm
                         CHANGING ps_tobe    TYPE gty_tobe.

  DATA : lt_sdit     TYPE TABLE OF bapisdit WITH EMPTY KEY,

         lv_tobe_val TYPE cux_value40.

  lt_sdit[] = CORRESPONDING #( pt_sdit[] ).

*-- As-Is 주문취소 되지 않은 해당 품목 정보 Select

  WITH +as_is   AS ( SELECT a~vbeln, a~posnr
                       FROM zgtsdt9060 AS a INNER JOIN zgtsdt0066 AS b
                                               ON a~mkey EQ b~mkey
                      WHERE b~zsystem_id EQ @gc_sysid-kbdm
                        AND b~job_no     EQ @ps_tobe-job_no
                        AND b~posnr      EQ @ps_tobe-posnr
                      GROUP BY a~vbeln, a~posnr )

    SELECT SINGLE a~itm_number
      FROM @lt_sdit AS a INNER JOIN +as_is AS b
                            ON a~doc_number EQ b~vbeln
                           AND a~itm_number EQ b~posnr
     WHERE a~rea_for_re IS INITIAL

      INTO @DATA(lv_posnr).

*-- 해당 As-Is 판매오더 & 품목 정보 기준 특성값 정보 Key 구성
  READ TABLE pt_curefm WITH KEY sd_doc = pv_vbeln
                                posex  = lv_posnr
                       INTO DATA(ls_curefm).

*-- 특성 필드 정보 기준 해당 특성값 확인
  LOOP AT pt_cfgs INTO DATA(ls_cfgs).

    ASSIGN COMPONENT : ls_cfgs-fname OF STRUCTURE ps_tobe TO FIELD-SYMBOL(<lv_value>).
    CHECK <lv_value> IS ASSIGNED AND
          <lv_value> IS NOT INITIAL.

    lv_tobe_val = |{ <lv_value> ALPHA = OUT }|.
    CONDENSE lv_tobe_val.

*-- As-Is To-Be 특성명 맵핑 정보 기준 해당 값 Read
    READ TABLE pt_cuvalm WITH KEY operation = ls_curefm-operation
                                  sd_doc    = ls_curefm-sd_doc
                                  config_id = ls_curefm-config_id
                                  inst_id   = ls_curefm-inst_id
                                  charc     = ls_cfgs-charc_a
                         INTO DATA(ls_cuvalm).

    IF lv_tobe_val NE ls_cuvalm-value OR
       sy-subrc NE 0.
*-- 특성값이 다를 경우 오류 정보 구성
      ps_tobe-stat = gc_led-red.
      ps_tobe-zmsg = |As-Is 대비 특성| && ls_cfgs-fname && |값 확인 하십시요.'|.
      EXIT.
    ENDIF.

    UNASSIGN <lv_value>.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_sd_cfgs_info
*&---------------------------------------------------------------------*
*& 품목별 특성정보 구성
*&---------------------------------------------------------------------*
*&      --> PS_ITM_LST    : Item 정보
*&      --> PT_CFGS       : 공통코드 기준 특성 필드 연결 정보
*&      --> PV_STDPD      : 구성형 자재 정보
*&      --> PV_CFG_ID     : 특성 Config ID 정보
*&      <-- PT_CFGS_REF   : 특성 구성 정보 리턴
*&      <-- PT_CFGS_INST  : 특성 구성 인스턴스 정보 리턴
*&      <-- PT_CFGS_VAL   : 특성 값 정보 리턴
*&---------------------------------------------------------------------*
FORM init_sd_cfgs_info  USING    ps_itm_lst    TYPE gty_tobe
                                 pt_cfgs       TYPE gty_t_cfgs
                                 pv_stdpd      TYPE stdpd
                                 pv_cfg_id     TYPE cux_cfg_id
                        CHANGING pt_cfgs_ref   TYPE bapicucfg_t
                                 pt_cfgs_inst  TYPE bapicuins_t
                                 pt_cfgs_val   TYPE bapicuval_t.

  DATA : ls_cfgs_val TYPE bapicuval,
         lv_inst_id  TYPE cu_inst_id,
         lv_tobe_val TYPE cux_value40.

  lv_inst_id = 1.

*-- 특성 구성 정보 구성
  APPEND VALUE #(
                  posex      = ps_itm_lst-posnr           " 품목번호
                  config_id  = pv_cfg_id                  " Config ID
                  root_id    = lv_inst_id                 " 인스턴스 번호
                  sce        = ' '                        " 구성 유형
                  kbname     = pv_stdpd                   " 구성형 자재번호
                  kbversion  = '001'                      " 런타임 버전
                ) TO pt_cfgs_ref.

*--특성 구성 인스턴스 정보 구성
  APPEND VALUE #(
                  config_id  = pv_cfg_id                  " Config ID
                  inst_id    = lv_inst_id                 " 인스턴스 번호
                  obj_type   = 'MARA'                     " 오브젝트 참조 정보
                  class_type = '300'                      " 클래스 Type
                  obj_key    = pv_stdpd                   " 오브젝트 키
                ) TO pt_cfgs_inst.

*-- 특성 값 정보 구성
  LOOP AT pt_cfgs INTO DATA(ls_cfgs).
    CLEAR ls_cfgs_val.
    ASSIGN COMPONENT ls_cfgs-fname OF STRUCTURE ps_itm_lst TO FIELD-SYMBOL(<lv_val>).
    IF <lv_val> IS ASSIGNED AND
       <lv_val> IS NOT INITIAL.
      lv_tobe_val = |{ <lv_val> ALPHA = OUT }|.

      CONDENSE lv_tobe_val.

      ls_cfgs_val = VALUE #(
                            config_id  = pv_cfg_id        " Config ID
                            inst_id    = lv_inst_id       " 인스턴스 번호
                            charc      = ls_cfgs-charc    " 특성명
                            value      = lv_tobe_val      " 특성 값
                           ).

      APPEND ls_cfgs_val TO pt_cfgs_val.

      UNASSIGN <lv_val>.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_extn_head_info
*&---------------------------------------------------------------------*
*& 판매오더 추가 필드 - Extension - 정보 구성
*&---------------------------------------------------------------------*
*&      --> PV_ZPJNO      : 프로젝트 번호
*&      <-- PT_EXTN_IN    : 추가필드 정보 리턴
*&---------------------------------------------------------------------*
FORM init_extn_head_info  USING    pv_zpjno   TYPE zpjno
                          CHANGING pt_extn_in TYPE bapiparex_t.

  DATA : ls_bape_vbak  TYPE bape_vbak,
         ls_bape_vbakx TYPE bape_vbakx,

         ls_extn_in    TYPE bapiparex.

  CLEAR : ls_bape_vbak, ls_bape_vbakx.
*-----------------------------------------------------------------------
*-- 입력 필드 정보 값 대입
*-----------------------------------------------------------------------
*-- 입력 값 구성
  ls_bape_vbak  = VALUE #(
                           zpjno  = pv_zpjno    " 프로젝트 번호
                           zcstat = |N|         " 선물대상 유무 비대상 고정
                         ).
*-- 입력필드 정보 구성
  ls_bape_vbakx = VALUE #(
                          zpjno  = abap_true    " 프로젝트 번호
                          zcstat = abap_true    " 선물대상
                         ).

*-----------------------------------------------------------------------
*-- 추가 필드 입력 전체 정보 구성
*-----------------------------------------------------------------------
*-- 생성 정보 구성
  CLEAR ls_extn_in.
  ls_extn_in-structure = 'BAPE_VBAK'.
  ls_extn_in+30        = ls_bape_vbak.

  APPEND ls_extn_in TO pt_extn_in.

*-- 생성 필드 정보 구성
  CLEAR ls_extn_in.
  ls_extn_in-structure = 'BAPE_VBAKX'.
  ls_extn_in+30        = ls_bape_vbakx.

  APPEND ls_extn_in TO pt_extn_in.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form hotspot_click_0100
*&---------------------------------------------------------------------*
*& Screen 0100 Class ALV Hotspot Clieck Event 구성
*&---------------------------------------------------------------------*
*&      --> PO_SENDER     : 해당 ALV Grid 정보
*&      --> PS_ROW_ID     : 해당 Row 정보
*&      --> PS_COLUMN_ID  : 해당 필드명 정보
*&---------------------------------------------------------------------*
FORM hotspot_click_0100  USING    po_sender     TYPE REF TO cl_gui_alv_grid
                                  ps_row_id     TYPE lvc_s_row
                                  ps_column_id  TYPE lvc_s_col.

  DATA : lv_vbeln TYPE vbeln_va.

  CLEAR lv_vbeln.

  CASE po_sender.
    WHEN go_grid_0100.
      IF p_tobe EQ abap_true OR
         p_del  EQ abap_true.
*-- To-Be 생성인 경우 생성 판매오더 조회 T-Code : VA03 수행
        READ TABLE gt_tobe INDEX ps_row_id-index
                           INTO DATA(ls_tobe).
        CASE ps_column_id-fieldname.
          WHEN 'VBELN'.
            IF ls_tobe-vbeln IS NOT INITIAL.
              lv_vbeln = ls_tobe-vbeln.
            ENDIF.

          WHEN 'VBELN_O'.
            IF ls_tobe-vbeln_o IS NOT INITIAL.
              lv_vbeln = ls_tobe-vbeln_o.
            ENDIF.
        ENDCASE.

        IF lv_vbeln IS NOT INITIAL.
          SET PARAMETER ID 'AUN' FIELD lv_vbeln.
          CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

        ENDIF.
      ENDIF.

      IF p_rej EQ abap_true.
        READ TABLE gt_rej_ord INDEX ps_row_id-index
                              INTO DATA(ls_rej).

        IF ls_rej-vbeln IS NOT INITIAL.
          lv_vbeln = ls_rej-vbeln.
        ENDIF.

        IF lv_vbeln IS NOT INITIAL.
          SET PARAMETER ID 'AUN' FIELD lv_vbeln.
          CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

        ENDIF.
      ENDIF.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_fcat_from_tobe
*&---------------------------------------------------------------------*
*& To-Be 생성 Fieldcatalog 추가 정보 구성
*&---------------------------------------------------------------------*
*&      <-- PT_FCAT  : Fieldcatalog 추가정보 리턴
*&---------------------------------------------------------------------*
FORM init_fcat_from_tobe  CHANGING pt_fcat  TYPE lvc_t_fcat.

*-- 추가 정보 구성
  LOOP AT pt_fcat ASSIGNING FIELD-SYMBOL(<ls_fcat>).

    CASE <ls_fcat>-fieldname.
      WHEN 'SAVE_STAT'.
        IF p_tobe EQ abap_true.
          <ls_fcat>-icon    = abap_true.
        ELSE.
          <ls_fcat>-no_out  = abap_true.
        ENDIF.

      WHEN 'VBELN'.
        <ls_fcat>-hotspot   = abap_true.
        <ls_fcat>-emphasize = 'C500'.

      WHEN 'ZMSG'.
        <ls_fcat>-coltext   = '결과메세지'(f01).
        <ls_fcat>-scrtext_l = '결과메세지'(f01).
        <ls_fcat>-scrtext_m = '결과메세지'(f01).
        <ls_fcat>-scrtext_s = '결과메세지'(f01).

      WHEN 'KWMENG'.
        <ls_fcat>-qfieldname = 'MEINS'.

      WHEN 'VBELN_O'.
        IF p_del_o EQ abap_true.
          <ls_fcat>-no_out    = abap_true.
        ELSE.
          <ls_fcat>-hotspot   = abap_true.
          <ls_fcat>-emphasize = 'C510'.
          <ls_fcat>-coltext   = 'As-Is판매문서'(f13).
          <ls_fcat>-scrtext_l = 'As-Is판매문서'(f13).
          <ls_fcat>-scrtext_m = 'As-Is판매문서'(f13).
          <ls_fcat>-scrtext_s = 'As-Is판매문서'(f13).
        ENDIF.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_fcat_from_mapp
*&---------------------------------------------------------------------*
*& Mapping 생성 Fieldcatalog 추가 정보 구성
*&---------------------------------------------------------------------*
*&      <-- PT_FCAT  : Fieldcatalog 추가정보 리턴
*&---------------------------------------------------------------------*
FORM init_fcat_from_mapp  CHANGING pt_fcat  TYPE lvc_t_fcat.
*-- 추가 정보 구성
  LOOP AT pt_fcat ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CASE <ls_fcat>-fieldname.
      WHEN 'ZPJNO_O'.
        <ls_fcat>-coltext   = 'ASIS 프로젝트'(f02).
        <ls_fcat>-scrtext_l = 'ASIS 프로젝트'(f02).
        <ls_fcat>-scrtext_m = 'ASIS 프로젝트'(f02).
        <ls_fcat>-scrtext_s = 'ASIS 프로젝트'(f02).

      WHEN 'JOB_NO_O'.
        <ls_fcat>-coltext   = 'ASIS 제조지시번호'(f03).
        <ls_fcat>-scrtext_l = 'ASIS 제조지시번호'(f03).
        <ls_fcat>-scrtext_m = 'ASIS 제조지시번호'(f03).
        <ls_fcat>-scrtext_s = 'ASIS 제조지시번호'(f03).

      WHEN 'VBELN_O'.
        <ls_fcat>-coltext   = 'ASIS 판매오더'(f04).
        <ls_fcat>-scrtext_l = 'ASIS 판매오더'(f04).
        <ls_fcat>-scrtext_m = 'ASIS 판매오더'(f04).
        <ls_fcat>-scrtext_s = 'ASIS 판매오더'(f04).

      WHEN 'POSNR_O'.
        <ls_fcat>-coltext   = 'ASIS 품목'(f05).
        <ls_fcat>-scrtext_l = 'ASIS 품목'(f05).
        <ls_fcat>-scrtext_m = 'ASIS 품목'(f05).
        <ls_fcat>-scrtext_s = 'ASIS 품목'(f05).

      WHEN 'MATNR_O'.
        <ls_fcat>-coltext   = 'ASIS 자재코드'(f06).
        <ls_fcat>-scrtext_l = 'ASIS 자재코드'(f06).
        <ls_fcat>-scrtext_m = 'ASIS 자재코드'(f06).
        <ls_fcat>-scrtext_s = 'ASIS 자재코드'(f06).

      WHEN 'ARKTX_O'.
        <ls_fcat>-coltext   = 'ASIS 자재내역'(f07).
        <ls_fcat>-scrtext_l = 'ASIS 자재내역'(f07).
        <ls_fcat>-scrtext_m = 'ASIS 자재내역'(f07).
        <ls_fcat>-scrtext_s = 'ASIS 자재내역'(f07).

      WHEN 'KWMENG_O'.
        <ls_fcat>-coltext   = 'ASIS 수량'(f08).
        <ls_fcat>-scrtext_l = 'ASIS 수량'(f08).
        <ls_fcat>-scrtext_m = 'ASIS 수량'(f08).
        <ls_fcat>-scrtext_s = 'ASIS 수량'(f08).
        <ls_fcat>-qfieldname = 'VRKME_O'.

      WHEN 'VRKME_O'.
        <ls_fcat>-coltext   = 'ASIS 단위'(f09).
        <ls_fcat>-scrtext_l = 'ASIS 단위'(f09).
        <ls_fcat>-scrtext_m = 'ASIS 단위'(f09).
        <ls_fcat>-scrtext_s = 'ASIS 단위'(f09).

      WHEN 'NETPR_O'.
        <ls_fcat>-coltext   = 'ASIS 단가'(f10).
        <ls_fcat>-scrtext_l = 'ASIS 단가'(f10).
        <ls_fcat>-scrtext_m = 'ASIS 단가'(f10).
        <ls_fcat>-scrtext_s = 'ASIS 단가'(f10).
        <ls_fcat>-cfieldname = 'WAERK_O'.

      WHEN 'NETWR_O'.
        <ls_fcat>-coltext   = 'ASIS 금액'(f11).
        <ls_fcat>-scrtext_l = 'ASIS 금액'(f11).
        <ls_fcat>-scrtext_m = 'ASIS 금액'(f11).
        <ls_fcat>-scrtext_s = 'ASIS 금액'(f11).
        <ls_fcat>-cfieldname = 'WAERK_O'.

      WHEN 'WAERK_O'.
        <ls_fcat>-coltext   = 'ASIS 통화'(f12).
        <ls_fcat>-scrtext_l = 'ASIS 통화'(f12).
        <ls_fcat>-scrtext_m = 'ASIS 통화'(f12).
        <ls_fcat>-scrtext_s = 'ASIS 통화'(f12).

      WHEN 'ZPJNO_N'.
        <ls_fcat>-emphasize = 'C500'.

      WHEN 'ZMSG'.
        <ls_fcat>-coltext   = '결과메세지'(f01).
        <ls_fcat>-scrtext_l = '결과메세지'(f01).
        <ls_fcat>-scrtext_m = '결과메세지'(f01).
        <ls_fcat>-scrtext_s = '결과메세지'(f01).

      WHEN 'QQTY'.
        <ls_fcat>-qfieldname = 'QUNIT'.

      WHEN 'QPRICE' OR 'QAMT'.
        <ls_fcat>-cfieldname = 'QWAERK'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_curr_conv_int
*&---------------------------------------------------------------------*
*& 금액필드 타입 Conversion 수행
*&---------------------------------------------------------------------*
*&      --> PV_CURR    : 통화단위
*&      --> PV_VALUE   : 화면 출력 금액 정보
*&      <-- PV_AMOUNT  : 통화단위 변환 금액 유형 값 리턴
*&---------------------------------------------------------------------*
FORM bapi_curr_conv_int  USING    pv_curr
                                  pv_value
                         CHANGING pv_amt.

  DATA : lv_amt TYPE bapicurr_d.

  lv_amt = pv_value.

  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
    EXPORTING
      currency             = pv_curr
      amount_external      = lv_amt
      max_number_of_digits = 20
    IMPORTING
      amount_internal      = pv_amt.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form into_fcat_from_open_so
*&---------------------------------------------------------------------*
*&  Open S/O 조회 Fieldcatalog 추가 정보 구성
*&---------------------------------------------------------------------*
*&      <-- PT_FCAT  : Fieldcatalog 추가정보 리턴
*&---------------------------------------------------------------------*
FORM into_fcat_from_open_so  CHANGING pt_fcat TYPE lvc_t_fcat.

  LOOP AT pt_fcat ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CASE <ls_fcat>-fieldname.
      WHEN 'KWMENG'.
        <ls_fcat>-qfieldname = 'VRKME'.

      WHEN 'KWERT'.
        <ls_fcat>-cfieldname = 'WAERK'.

    ENDCASE.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form into_fcat_from_open_do
*&---------------------------------------------------------------------*
*&  Open D/O 조회 Fieldcatalog 추가 정보 구성
*&---------------------------------------------------------------------*
*&      <-- PT_FCAT  : Fieldcatalog 추가정보 리턴
*&---------------------------------------------------------------------*
FORM into_fcat_from_open_do  CHANGING pt_fcat TYPE lvc_t_fcat.

  LOOP AT pt_fcat ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CASE <ls_fcat>-fieldname.
      WHEN 'LFIMG'.
        <ls_fcat>-qfieldname = 'VRKME'.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form into_fcat_from_open_hu
*&---------------------------------------------------------------------*
*&  Open DH/U 조회 Fieldcatalog 추가 정보 구성
*&---------------------------------------------------------------------*
*&      <-- PT_FCAT  : Fieldcatalog 추가정보 리턴
*&---------------------------------------------------------------------*
FORM into_fcat_from_open_hu  CHANGING pt_fcat TYPE lvc_t_fcat.

  LOOP AT pt_fcat ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CASE <ls_fcat>-fieldname.
      WHEN 'EXIDV'.
        <ls_fcat>-key       = abap_true.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form chk_mapp_charc_info_i
*&---------------------------------------------------------------------*
*& As-Is 품목정보 기준 해당 특성정보 확인
*&---------------------------------------------------------------------*
*&      --> PV_CONFIG  : 특성 Object 정보
*&      <-- PS_MAPP    : Mapping Upload 정보 & 정합성 체크 정보 리턴
*&---------------------------------------------------------------------*
FORM chk_mapp_charc_info_i  USING    pv_config TYPE cuobj_va
                            CHANGING ps_mapp   TYPE gty_mapp.

  CONSTANTS : lc_qcode TYPE cu_charc VALUE 'PD_BD_PROD_NAME'.

  DATA : lt_conf_out TYPE tt_conf_out,

         lv_atinn    TYPE atinn.

  CHECK pv_config IS NOT INITIAL.

  CLEAR : lt_conf_out.

*-- 해당 Object 정보 기준 특성정보 구성
  CALL FUNCTION 'VC_I_GET_CONFIGURATION'
    EXPORTING
      instance            = pv_config
    TABLES
      configuration       = lt_conf_out
    EXCEPTIONS
      instance_not_found  = 1
      internal_error      = 2
      no_class_allocation = 3
      instance_not_valid  = 4
      OTHERS              = 5.


  READ TABLE lt_conf_out WITH KEY atnam = lc_qcode
                         INTO DATA(ls_conf_out).
*-- 견적품 코드 확인
  IF NOT ( sy-subrc          EQ 0 AND
           ls_conf_out-atwrt EQ ps_mapp-qcode ).
    ps_mapp-stat = gc_led-red.
    ps_mapp-zmsg = 'As-IS:' && ls_conf_out-atwrt && ' ' &&
                   'Mapping 견적품코드 특성정보 확인'(e11).

  ENDIF.

*-- 견적품명 확인
  READ TABLE lt_conf_out WITH KEY atnam = lc_qcode
                         INTO ls_conf_out.
  IF NOT ( sy-subrc          EQ 0 AND
           ls_conf_out-atwtb EQ ps_mapp-qname ).
    ps_mapp-stat = gc_led-red.
    ps_mapp-zmsg = 'As-IS:' && ls_conf_out-atwtb && ' ' &&
                   'Mapping 견적품명 특성정보 확인'(e12).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form chk_ord_len_f_asis_i
*&---------------------------------------------------------------------*
*& As-Is 판매오더 품목 정보 기준 To-Be Set 길이( M ) 확인
*&---------------------------------------------------------------------*
*&      --> TT_ASIS   : As-Is 품목 연결 정보
*&      --> PT_SDIT   : As-Is 판매오더 Item 정보
*&      <-- TS_TOBE   : To-Be 정보 & 오류 정보 리턴
*&---------------------------------------------------------------------*
FORM chk_ord_len_f_asis_i  USING    pt_asis   TYPE gty_t_asis
                                    pt_sdit   TYPE wiso_t_sdit
                           CHANGING ps_tobe   TYPE gty_tobe.

  DATA : lt_sdit    TYPE TABLE OF bapisdit WITH EMPTY KEY,

         lv_ord_len TYPE zgte_bd_ordlen.

  lt_sdit[] = CORRESPONDING #( pt_sdit[] ).

  CLEAR lv_ord_len.

*-- As-Is 품목 기준 총 길이 합 과 To-Be 주문길이 값 확인
  WITH +as_is AS ( SELECT a~vbeln, a~posnr
                     FROM @pt_asis AS a
                    WHERE a~job_no  EQ @ps_tobe-job_no
                      AND a~posnr_t EQ @ps_tobe-posnr
                    GROUP BY a~vbeln, a~posnr )

   SELECT a~vbeln,  a~posnr
     FROM +as_is AS a

    ORDER BY a~vbeln, a~posnr

     INTO TABLE @DATA(lt_as_itm).

  LOOP AT lt_as_itm INTO DATA(ls_as_itm).

    WITH +req_qty AS ( SELECT SUM( a~req_qty ) AS req_qty
                         FROM @lt_sdit AS a
                        WHERE a~doc_number EQ @ls_as_itm-vbeln
                          AND a~itm_number EQ @ls_as_itm-posnr
                          AND a~sales_unit EQ @gc_unit-m
                          AND a~rea_for_re IS INITIAL )

      SELECT SINGLE a~req_qty
        FROM +req_qty AS a

        INTO @DATA(lv_req_qty).
    IF sy-subrc EQ 0.
      ADD lv_req_qty TO lv_ord_len.
    ENDIF.
  ENDLOOP.

*-- 주문길이 비교하여 다를 경우 오류 메세지 처리
  ps_tobe-stat = COND #( WHEN lv_ord_len NE ps_tobe-ord_len THEN gc_led-red
                         ELSE abap_false ).
  ps_tobe-zmsg = COND #( WHEN ps_tobe-stat EQ gc_led-red THEN '주문길이가 As-Is 값과 다릅니다.'(e13)
                         ELSE abap_false ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form chk_cfgs_asis_data_i
*&---------------------------------------------------------------------*
*& As-Is 판매오더 품목 정보 기준 To-Be 특성정보 정합성 체크
*&---------------------------------------------------------------------*
*&      --> TT_ASIS   : As-Is 품목 연결 정보
*&      --> PT_SDIT   : As-Is 판매오더 Item 정보
*&      --> PT_CFGS   : As-Is & To-Be 특성명 & 해당 필드명 정보
*&      --> PT_MAPP   : AS_Is / To-Be 특성코드 Mapping 정보
*&      --> PV_STDPD  : 구성형 자재 정보
*&      <-- TS_TOBE   : To-Be 정보 & 오류 정보 리턴
*&---------------------------------------------------------------------*
FORM chk_cfgs_asis_data_i  USING    pt_asis   TYPE gty_t_asis
                                    pt_sdit   TYPE wiso_t_sdit
                                    pt_cfgs   TYPE gty_t_cfgs
                                    pt_mapp   TYPE gty_t_cfgs_mapp
                                    pv_stdpd  TYPE stdpd
                           CHANGING ps_tobe   TYPE gty_tobe.

  CONSTANTS lc_fcm_bd_50 TYPE stdpd VALUE 'FCM-BD-50'.

  DATA : lr_posnr TYPE RANGE OF posnr_va.

  DATA : lt_sdit     TYPE TABLE OF bapisdit WITH EMPTY KEY,
         lt_conf_out TYPE tt_conf_out,

         lv_tobe_val TYPE cux_value40.

  lt_sdit[] = CORRESPONDING #( pt_sdit[] ).

*-- To-Be 품목 정보 기준 해당 As-Is 품목 Range 정보 구성
  CLEAR : lr_posnr, lt_conf_out.

  WITH +posnr AS ( SELECT a~posnr
                     FROM @pt_asis AS a
                     WHERE a~job_no  EQ @ps_tobe-job_no
                       AND a~posnr_t EQ @ps_tobe-posnr
                     GROUP BY a~posnr )

   SELECT @gc_sign-i  AS sign,
          @gc_optn-eq AS option,
          a~posnr     AS low
     FROM +posnr AS a

     INTO CORRESPONDING FIELDS OF TABLE @lr_posnr.

  CHECK lr_posnr[] IS NOT INITIAL.
*-- 해당 As-Is 품목 정보 기준 특성값 정보 Key 구성
  SELECT SINGLE a~config
    FROM @lt_sdit AS a
   WHERE a~doc_number EQ @ps_tobe-vbeln_o
     AND a~itm_number IN @lr_posnr
     AND a~rea_for_re IS INITIAL           "--> 주문취소 제외

    INTO @DATA(lv_config).

  CHECK lv_config IS NOT INITIAL.

*-- 해당 Object 정보 기준 특성정보 구성
  CALL FUNCTION 'VC_I_GET_CONFIGURATION'
    EXPORTING
      instance            = lv_config
    TABLES
      configuration       = lt_conf_out
    EXCEPTIONS
      instance_not_found  = 1
      internal_error      = 2
      no_class_allocation = 3
      instance_not_valid  = 4
      OTHERS              = 5.

*-- 특성 필드 정보 기준 해당 특성값 확인
  LOOP AT pt_cfgs INTO DATA(ls_cfgs).

    ASSIGN COMPONENT : ls_cfgs-fname OF STRUCTURE ps_tobe TO FIELD-SYMBOL(<lv_value>).
    CHECK <lv_value> IS ASSIGNED.

    lv_tobe_val = |{ <lv_value> ALPHA = OUT }|.
    CONDENSE lv_tobe_val.

*-- As-Is 특성값 변경에 따른 Mapping 정보 Read
    READ TABLE pt_mapp WITH KEY atnam_a = ls_cfgs-charc_a
                                atnam_t = ls_cfgs-charc
                                atwrt_t = lv_tobe_val
                       INTO DATA(ls_mapp).

    IF sy-subrc EQ 0 AND lv_tobe_val IS NOT INITIAL.
*      해당 정보 있는경우 As-Is 값 으로 비교
      lv_tobe_val = ls_mapp-atwrt_a.
      CONDENSE lv_tobe_val.
    ENDIF.

*-- As-Is To-Be 특성명 맵핑 정보 기준 해당 값 Read
    READ TABLE lt_conf_out WITH KEY atnam = ls_cfgs-charc_a
                           INTO  DATA(ls_conf_out).
    IF sy-subrc    NE 0           AND
       lv_tobe_val IS NOT INITIAL AND
       pv_stdpd    NE lc_fcm_bd_50.  "--> 해당 구성형 자재 인 경우 As-Is 값 없어도 정상 반영
      ps_tobe-stat = gc_led-red.
      ps_tobe-zmsg = |해당 To-Be 특성 | && ls_cfgs-fname && | 값이 As-Is 특성정보에 없습니다. As-Is품목: |.

      LOOP AT lr_posnr INTO DATA(ls_posnr).
        CONCATENATE ps_tobe-zmsg ls_posnr-low INTO ps_tobe-zmsg SEPARATED BY space.
      ENDLOOP.

      EXIT.

    ELSEIF sy-subrc EQ 0.

      IF lv_tobe_val NE ls_conf_out-atwrt.
*-- 특성값이 다를 경우 오류 정보 구성
        ps_tobe-stat = gc_led-red.
        ps_tobe-zmsg = |As-Is |  && ls_conf_out-atbez && |:| && ls_conf_out-atwrt &&
                       | To-BE | && ls_cfgs-fname    && | 값 확인 하십시요. As-Is품목 |.
        LOOP AT lr_posnr INTO ls_posnr.
          CONCATENATE ps_tobe-zmsg ls_posnr-low INTO ps_tobe-zmsg SEPARATED BY space.
        ENDLOOP.
        EXIT.
      ENDIF.

    ENDIF.

    CLEAR ls_conf_out.

    UNASSIGN <lv_value>.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_crted_order_data
*&---------------------------------------------------------------------*
*& 생성한 판매오더 조회
*&---------------------------------------------------------------------*
FORM select_crted_order_data .

  DATA : ls_tobe TYPE gty_tobe,

         lt_cfgs TYPE gty_t_cfgs.

*-----------------------------------------------------------------------
*-- 판매오더 정보 Select
*-----------------------------------------------------------------------
*-- Mig. Upload 정보 기준 생성한 To-Be 판매오더 정보 Select
  SELECT a~zsystem_id,  a~job_no,  a~vbeln,  a~posnr

    FROM zgtsdt0066 AS a
   WHERE a~vbeln IS NOT INITIAL       "--> To-Be 오더 생성 리스트
     AND a~mkey  IS NOT INITIAL       "--> 해당 Mig. 생성 리스트

    INTO TABLE @DATA(lt_sd_ord).

  CHECK lt_sd_ord[] IS NOT INITIAL.

*-- To-Be 판매오더 번호 정보 기준 해당 오더 정보 Select
  WITH +sd_ord AS ( SELECT a~vbeln
                      FROM @lt_sd_ord AS a
                     GROUP BY a~vbeln )

    SELECT a~vbeln,  a~bstnk,
           c~posnr,  c~matnr,  c~arktx,  c~werks,  c~kwmeng,  c~vrkme,
           c~cuobj

      FROM vbak AS a INNER JOIN +sd_ord AS b
                        ON a~vbeln EQ b~vbeln

                     INNER JOIN vbap AS c
                        ON a~vbeln EQ c~vbeln

      INTO TABLE @DATA(lt_sales).

*-- To-Be 판매오더 기준 스케쥴 라인 정보 Select
  WITH +sd_key AS ( SELECT a~vbeln, a~posnr
                      FROM @lt_sales AS a )

    SELECT a~vbeln,  a~posnr, a~etenr,  a~edatu,  a~wmeng,  a~vrkme
      FROM vbep AS a INNER JOIN +sd_key AS b
                        ON a~vbeln EQ b~vbeln
                       AND a~posnr EQ b~posnr

     ORDER BY a~vbeln, a~posnr, a~etenr
      INTO TABLE @DATA(lt_schd).

*-- To-Be 판매오더 제조지시 정보 Select
  WITH +key_info AS ( SELECT a~zsystem_id, a~job_no, a~posnr
                        FROM @lt_sd_ord AS a
                       GROUP BY a~zsystem_id, a~job_no, a~posnr )

    SELECT a~zsystem_id,  a~mreqno,    a~zpjno,  a~job_no,  a~posnr,
           a~item_key,    a~job_name,  a~vbeln,  a~chr_key, a~ojob_no

      FROM zgtsdt0065 AS a INNER JOIN +key_info AS b
                              ON a~zsystem_id EQ b~zsystem_id
                             AND a~job_no     EQ b~job_no
                             AND a~posnr      EQ b~posnr
      INTO TABLE @DATA(lt_0065).

*-- As-Is / To-Be 주문 특성 정보 Select
  SELECT a~fld_04 AS charc,           " To-Be 특성명
         a~fld_06 AS charc_a,         " As-Is 특성명
         a~fld_03 AS fname            " To-Be 특성 정보 필드명
    FROM zgtppt1010 AS a
   WHERE a~module_kind EQ 'SD'
     AND a~codegrp     EQ '0063'
     AND a~fld_01      EQ @gc_sysid-kbdm
     AND a~fld_06      IS NOT INITIAL

    INTO TABLE @lt_cfgs.

*-- 판매오더 기준 해당 판매오더 제고 정보 Select
  WITH +mat_info AS ( SELECT a~vbeln, a~posnr, a~werks, a~matnr
                        FROM @lt_sales AS a
                       GROUP BY a~vbeln, a~posnr, a~werks, a~matnr )

    SELECT a~vbeln,  a~posnr,  a~werks,  a~matnr,
           SUM( a~kalab ) AS kalab

      FROM mska AS a INNER JOIN +mat_info AS b
                        ON a~werks EQ b~werks
                       AND a~matnr EQ b~matnr
                       AND a~vbeln EQ b~vbeln
                       AND a~posnr EQ b~posnr

     WHERE a~sobkz EQ 'E'             " 미결오더
     GROUP BY a~vbeln, a~posnr, a~werks, a~matnr
     ORDER BY a~vbeln, a~posnr, a~werks, a~matnr
      INTO TABLE @DATA(lt_mska).

  CHECK lt_sales[] IS NOT INITIAL.
*-----------------------------------------------------------------------
*-- 출력 정보 구성
*-----------------------------------------------------------------------
  LOOP AT lt_sales INTO DATA(ls_sales).

*-- 1번째 스케쥴 라인 정보 Read
    READ TABLE lt_schd WITH KEY vbeln = ls_sales-vbeln
                                posnr = ls_sales-posnr
                                etenr = 1
                       INTO DATA(ls_schd).

*-- Table : ZGTSDT0065 정보 Read
    READ TABLE lt_0065 WITH KEY vbeln = ls_sales-vbeln
                                posnr = ls_sales-posnr
                       INTO DATA(ls_0065).

*-- 출력 판매오더 정보 구성
    ls_tobe = VALUE #( mreqno     = ls_0065-mreqno        " 제조지시요청번호
                       zpjno      = ls_0065-zpjno         " Project No
                       job_no     = ls_sales-bstnk        " 제조지시 번호
                       posnr      = ls_sales-posnr        " 판매 문서 항목
                       item_key   = ls_0065-item_key      " 판매오더 연결 키
                       job_name   = ls_0065-job_name      " 제조지시명
                       zdelv_date = ls_schd-edatu         " 납품일
                       matnr      = ls_sales-matnr        " 자재번호
                       maktx      = ls_sales-arktx        " 자재명
                       werks      = ls_sales-werks        " 플랜트
                       kwmeng     = ls_sales-kwmeng       " 누적 오더 수량
                       meins      = ls_sales-vrkme        " 기본 단위
                       chr_key    = ls_0065-chr_key       " [특성] 조합키
                       ojob_no    = ls_0065-ojob_no       " 이전전기 대상 제조지시번호

                       vbeln      = ls_sales-vbeln        " 판매문서
                     ).

*-- 품목 기준 특성 정보 구성
    PERFORM read_sd_cfgs_info       USING    ls_sales-cuobj
                                             lt_cfgs
                                    CHANGING ls_tobe.

*-- 판매오더 품목 기준 판매오더 재고 여부 확인
    READ TABLE lt_mska WITH KEY vbeln = ls_tobe-vbeln
                                posnr = ls_tobe-posnr
                                werks = ls_tobe-werks
                                matnr = ls_tobe-matnr
                       INTO DATA(ls_mska).
    IF sy-subrc EQ 0 AND ls_mska-kalab NE 0.
      ls_tobe-stat = gc_led-red.
      ls_tobe-zmsg = '판매오더 재고가 존재합니다.'(e17).
    ENDIF.

    APPEND ls_tobe TO gt_tobe.

    CLEAR : ls_tobe, ls_schd, ls_0065.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form read_sd_cfgs_info
*&---------------------------------------------------------------------*
*& 해당 판매오더 특성 정보 구성
*&---------------------------------------------------------------------*
*&      --> PV_CUOBJ  : 해당 특성 정보 Key
*&      --> PT_CFGS   : 특성명 기준 필드 Mapping 정보
*&      <-- PS_TOBE   : 해당 특성 구성 정보 리턴
*&---------------------------------------------------------------------*
FORM read_sd_cfgs_info  USING    pv_cuobj  TYPE cuobj_va
                                 pt_cfgs   TYPE gty_t_cfgs
                        CHANGING ps_tobe   TYPE gty_tobe.

  DATA : lt_conf_out TYPE tt_conf_out.

  CHECK pv_cuobj IS NOT INITIAL.

*-- 해당 Object 정보 기준 특성정보 구성
  CALL FUNCTION 'VC_I_GET_CONFIGURATION'
    EXPORTING
      instance            = pv_cuobj
    TABLES
      configuration       = lt_conf_out
    EXCEPTIONS
      instance_not_found  = 1
      internal_error      = 2
      no_class_allocation = 3
      instance_not_valid  = 4
      OTHERS              = 5.

  CHECK lt_conf_out[] IS NOT INITIAL.

*-- 해당 특성정보 Mapping 정보 기준 해당 필드에 구성
  LOOP AT pt_cfgs INTO DATA(ls_cfgs).
    ASSIGN COMPONENT : ls_cfgs-fname OF STRUCTURE ps_tobe TO FIELD-SYMBOL(<lv_value>).
    CHECK <lv_value> IS ASSIGNED.

    READ TABLE lt_conf_out WITH KEY atnam = ls_cfgs-charc
                           INTO DATA(ls_conf_out).
    CHECK sy-subrc EQ 0.

    <lv_value> = ls_conf_out-atwrt.

    IF <lv_value> IS ASSIGNED.
      UNASSIGN <lv_value>.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form del_so_to_be
*&---------------------------------------------------------------------*
*& To-Be 판매오더 삭제 수행
*&---------------------------------------------------------------------*
FORM del_so_to_be .

  DATA : ls_headerx TYPE bapisdh1x,

         lt_return  TYPE bapiret2_tt,
         ls_return  TYPE bapiret2,

         lt_tobe    TYPE gty_t_tobe,
         ls_tobe    TYPE gty_tobe,

         lv_vbeln   TYPE vbeln_va,
         lv_answer  TYPE char01,

         lv_so_del  TYPE vbeln_va.

  CLEAR lv_so_del.

*-----------------------------------------------------------------------
*-- ALV 출력 리스트 기준 삭제 가능 여부 확인
*-----------------------------------------------------------------------
  SELECT SINGLE @abap_true
    FROM @gt_tobe AS a
   WHERE a~stat      EQ @gc_led-red

    INTO @DATA(lv_flag).

  IF sy-subrc EQ 0.
    MESSAGE s000 WITH 'To-Be 판매오더 확인 바랍니다.'(e18)
                 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  PERFORM popup_to_confirm          USING    'To-Be 판매오더 삭제'(t09)
                                             'To-Be 판매오더를 삭제하시겠습니까?'(m08)
                                    CHANGING lv_answer.
  IF lv_answer NE '1'.
    MESSAGE s050.
    EXIT.
  ENDIF.

*-- 판매오더 재고 정보 있는 정보 Select
  WITH +key_info AS ( SELECT a~vbeln, a~posnr, a~werks, a~matnr
                        FROM @gt_tobe AS a
                       GROUP BY a~vbeln, a~posnr, a~werks, a~matnr ),

       +mska     AS ( SELECT a~vbeln, a~posnr, a~werks, a~matnr,
                             SUM( a~kalab ) AS kalab
                        FROM mska AS a INNER JOIN +key_info AS b
                                          ON a~vbeln EQ b~vbeln
                                         AND a~posnr EQ b~posnr
                                         AND a~werks EQ b~werks
                                         AND a~matnr EQ b~matnr
                       WHERE a~sobkz EQ 'E'
                       GROUP BY a~vbeln, a~posnr, a~werks, a~matnr )

    SELECT a~vbeln
      FROM +mska AS a
     WHERE a~kalab GT 0
     GROUP BY a~vbeln

      INTO TABLE @DATA(lt_kalab).

  lt_tobe[] = CORRESPONDING #( gt_tobe[] ).
  SORT lt_tobe BY zpjno job_no vbeln posnr.
*-----------------------------------------------------------------------
*-- 판매오더 삭제 BAPI 수행
*-----------------------------------------------------------------------
  LOOP AT lt_tobe INTO DATA(ls_key)
                  GROUP BY ( zpjno  = ls_key-zpjno
                             job_no = ls_key-job_no
                             vbeln  = ls_key-vbeln
                             size   = GROUP SIZE
                             index  = GROUP INDEX )
                  ASSIGNING FIELD-SYMBOL(<so_lst>).

    CLEAR : ls_headerx, lt_return, ls_return, lv_vbeln,
            ls_tobe.
*-- 판매오더 기준 판매오더 재고 정보 확인
    READ TABLE lt_kalab WITH KEY vbeln = <so_lst>-vbeln
                        TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
*      판매오더 재고 있는경우 오류 메세지 구성
      ls_tobe-stat = gc_led-red.
      ls_tobe-zmsg = '판매오더 재고가 존재합니다.'(e17).

      MODIFY gt_tobe FROM ls_tobe
                     TRANSPORTING stat zmsg
                     WHERE zpjno  EQ <so_lst>-zpjno
                       AND job_no EQ <so_lst>-job_no
                       AND vbeln  EQ <so_lst>-vbeln.

      CONTINUE.
    ENDIF.

*-- 판매오더 삭제 Header 정보 구성
    ls_headerx = VALUE #(
                          updateflag = 'D'
                        ).

    lv_vbeln = <so_lst>-vbeln.

*-- 판매오더 삭제 BAPI 수행
    CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
      EXPORTING
        salesdocument    = lv_vbeln
        order_header_inx = ls_headerx
      TABLES
        return           = lt_return[].

*-----------------------------------------------------------------------
*-- 판매오더 삭제 결과 DB & ALV  화면 반영
*-----------------------------------------------------------------------
    READ TABLE lt_return WITH KEY type = 'S'
                         INTO ls_return.

    IF sy-subrc EQ 0.
*-- 성공인 경우 판매오더 삭제 정보 DB 반영
      TRY.
          UPDATE : zgtsdt0065 SET vbeln   = lv_so_del
                                  zstat   = ls_return-type
                                  zmsg    = ls_return-message

                                  aenam   = sy-uname
                                  aedat   = sy-datum
                                  aezeit  = sy-uzeit
                                  aedatlo = sy-datlo
                                  aetimlo = sy-timlo
                                  aetcode = sy-tcode
                              WHERE zpjno  EQ <so_lst>-zpjno
                                AND job_no EQ <so_lst>-job_no,

                   zgtsdt0066 SET vbeln   = lv_so_del

                                  aenam   = sy-uname
                                  aedat   = sy-datum
                                  aezeit  = sy-uzeit
                                  aedatlo = sy-datlo
                                  aetimlo = sy-timlo
                                  aetcode = sy-tcode
                            WHERE job_no EQ <so_lst>-job_no.

        CATCH cx_sy_open_sql_db INTO DATA(lo_sql_db).
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.        "--> DB Update 실패시 Rollback Work 수행

          DATA(lv_msg) = lo_sql_db->get_text( ).
          ls_return-type    = |E|.
          ls_return-message = lv_msg.
      ENDTRY.

    ELSE.
*-- 실패인 경우 Rollback Work
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      READ TABLE lt_return WITH KEY type = 'E'
                           INTO ls_return.
    ENDIF.

    IF ls_return-type EQ 'S' AND
       lv_msg         IS INITIAL.
*-- 처리결과 기준 Rollback Work 가 아닌 경우 Commit Work
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_false.
    ENDIF.

*-- 처리 결과 ALV 반영
    ls_tobe-stat  = COND #( WHEN ls_return-type EQ 'E' THEN gc_led-red
                            WHEN ls_return-type EQ 'S' THEN gc_led-green ).
    ls_tobe-zmsg  = ls_return-message.
    ls_tobe-vbeln = COND #( WHEN ls_return-type EQ 'S' THEN lv_so_del
                            ELSE ls_tobe-vbeln ).

    MODIFY gt_tobe FROM ls_tobe
                   TRANSPORTING vbeln stat zmsg
                   WHERE zpjno  EQ <so_lst>-zpjno
                     AND job_no EQ <so_lst>-job_no.
    CLEAR lv_msg.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_saved_tobe_data
*&---------------------------------------------------------------------*
*&  저장된 To-Be 정보 Table : ZGTSDT0065 조회
*&---------------------------------------------------------------------*
FORM select_saved_tobe_data .

  DATA : ls_tobe TYPE gty_tobe.

*-----------------------------------------------------------------------
*-- To-Be 저장 정보 Select
*-----------------------------------------------------------------------
*-- Mapping 정보 기준 Key 정보 Select
  SELECT a~zsystem_id,  a~job_no,  a~posnr,
         b~vbeln AS vbeln_o

    FROM zgtsdt0066 AS a INNER JOIN zgtsdt9060 AS b
                            ON a~mkey EQ b~mkey

   WHERE a~mkey  IS NOT INITIAL       "--> 해당 Mig. 생성 리스트

   GROUP BY a~zsystem_id, a~job_no, a~posnr, b~vbeln

    INTO TABLE @DATA(lt_mapp).

  CHECK lt_mapp[] IS NOT INITIAL.

*-- Mapping Key 정보 기준 To-Be 정보 Select
  SELECT a~mreqno,      a~zpjno,          a~job_no,         a~posnr,        a~item_key,  a~job_name,
         a~zdelv_date,  a~matnr,          a~maktx,          a~werks,        a~kwmeng,    a~meins,
         a~ord_len,     a~ord_wgt,        a~voltage_cd,     a~prod_type,    a~wire_cnt,  a~amphere,
         a~cond_mtrl,   a~duct_mtrl_est,  a~ground_type,    a~ipgrade,      a~condtw,    a~grspec,
         a~stdname,     a~serialno,       a~ecoptype,       a~n_wire_type,  a~brkmd,     a~framph,
         a~opmthd,      a~phtap,          a~vbeln,          a~chr_key,      a~ojob_no,   a~zstat,
         a~zmsg,
         b~vbeln_o
    FROM zgtsdt0065 AS a INNER JOIN @lt_mapp AS b
                            ON a~zsystem_id EQ b~zsystem_id
                           AND a~job_no     EQ b~job_no
                           AND a~posnr      EQ b~posnr

    INTO TABLE @DATA(lt_0065).

*-----------------------------------------------------------------------
*-- 출력 정보 구성
*-----------------------------------------------------------------------
  LOOP AT lt_0065 INTO DATA(ls_0065).
    CLEAR ls_tobe.

    ls_tobe = CORRESPONDING #( ls_0065 ).

    ls_tobe-save_stat = COND #( WHEN ls_tobe-vbeln IS NOT INITIAL THEN icon_led_green
                                ELSE icon_led_inactive ).
    ls_tobe-stat      = COND #( WHEN ls_tobe-zstat EQ 'E' THEN gc_led-red
                                ELSE gc_led-green ).

    APPEND ls_tobe TO gt_tobe.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form del_db_to_sel
*&---------------------------------------------------------------------*
*&  Mapping / To-Be 저장 정보 기준 DB 삭제 수행
*&---------------------------------------------------------------------*
FORM del_db_to_sel .

  CASE abap_true.
    WHEN p_del_m.           " Mapping 정보 조회/삭제
      PERFORM del_mapping_data.

    WHEN p_del_t.           " To-Be 데이터 조회/삭제
      PERFORM del_to_be_data.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_saved_mapp_data
*&---------------------------------------------------------------------*
*&  저장된 Mapping 정보 조회
*&---------------------------------------------------------------------*
FORM select_saved_mapp_data .

  DATA : ls_mapp TYPE gty_mapp.

*-----------------------------------------------------------------------
*-- Mapping 저장정보 Select
*-----------------------------------------------------------------------
  SELECT a~zpjno,   a~job_no_o,  a~vbeln,  a~posnr,  a~matnr,  a~arktx,
         a~kwmeng,  a~vrkme,     a~netpr,  a~netwr,  a~waerk,  a~mkey

    FROM zgtsdt9060 AS a

    INTO TABLE @DATA(lt_9060).

  CHECK lt_9060[] IS NOT INITIAL.

  WITH +key_info AS ( SELECT a~mkey
                        FROM @lt_9060 AS a
                       GROUP BY a~mkey )

    SELECT a~zsystem_id,  a~job_no,    a~posnr,  a~qcode,  a~qname,  a~qname_prnt,
           a~qprice,      a~qwaerk,    a~qqty,   a~qunit,  a~vbeln,  a~chr_key,
           a~conf_price,  a~item_key,  a~mkey

      FROM zgtsdt0066 AS a INNER JOIN +key_info AS b
                              ON a~mkey EQ b~mkey

      INTO TABLE @DATA(lt_0066).

*-----------------------------------------------------------------------
*-- ALV 출력 정보 구성
*-----------------------------------------------------------------------
  LOOP AT lt_9060 INTO DATA(ls_9060).
    CLEAR ls_mapp.
    READ TABLE lt_0066 WITH KEY mkey = ls_9060-mkey
                       INTO DATA(ls_0066).

    ls_mapp = VALUE #(
                      zpjno_o    = ls_9060-zpjno          " ASIS 프로젝트
                      job_no_o   = ls_9060-job_no_o       " ASIS 제조지시번호
                      vbeln_o    = ls_9060-vbeln          " ASIS 판매오더
                      posnr_o    = ls_9060-posnr          " ASIS 품목
                      matnr_o    = ls_9060-matnr          " ASIS 자재코드
                      arktx_o    = ls_9060-arktx          " ASIS 자재내역
                      kwmeng_o   = ls_9060-kwmeng         " ASIS 수량
                      vrkme_o    = ls_9060-vrkme          " ASIS 단위
                      netpr_o    = ls_9060-netpr          " ASIS 단가
                      netwr_o    = ls_9060-netwr          " ASIS 금액
                      waerk_o    = ls_9060-waerk          " ASIS 통화

                      zpjno_n    = ls_9060-zpjno          " TOBE 프로젝트
                      job_no_n   = ls_0066-job_no         " TOBE 제조지시번호
                      posnr_n    = ls_0066-posnr          " TOBE 품목
                      vbeln_n    = ls_0066-vbeln          " TOBE 판매오더
                      qcode      = ls_0066-qcode          " TOBE 견적품코드
                      qname      = ls_0066-qname          " TOBE 견적품명
                      qname_prnt = ls_0066-qname_prnt     " TOBE 견적품 출력명
                      qqty       = ls_0066-qqty           " TOBE 수량
                      qunit      = ls_0066-qunit          " TOBE 단위
                      qprice     = ls_0066-qprice         " TOBE 단가
                      qamt       = ls_9060-netwr          " TOBE 금액
                      qwaerk     = ls_0066-qwaerk         " TOBE 통화
                      item_key   = ls_0066-item_key       " ITEM KEY
                     ).
    APPEND ls_mapp TO gt_mapp.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form upload_rej_excel
*&---------------------------------------------------------------------*
*& As-Is 판매오더 거부사유처리
*&---------------------------------------------------------------------*
*&      <-- PV_EFLAG  : 오류 발생시 'X' 리턴
*&---------------------------------------------------------------------*
FORM upload_rej_excel  CHANGING pv_eflag  TYPE char01.

  DATA : lt_excel    TYPE isu_price_excel_tab,
         lt_excl_rej TYPE gty_t_rej_excel,
         ls_excl_rej TYPE gty_rej_excel,

         lt_fcat     TYPE lvc_t_fcat,

         lv_value    TYPE char50.


  CLEAR : pv_eflag,
          gt_rej_ord,
          lt_excel, lt_excl_rej, lt_fcat.
*-----------------------------------------------------------------------
*-- 1. Excel File 정보 기준 Upload 수행
*-----------------------------------------------------------------------
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_fname
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = 2
      i_end_row               = 65535
    TABLES
      intern                  = lt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc NE 0.
    pv_eflag = abap_true.
    EXIT.
  ENDIF.

*-----------------------------------------------------------------------
*-- 2. Upload Excel 정보 기준 Internal Table 에 값 구성
*-----------------------------------------------------------------------
*-- 2-1. 해당 Excel Upload 양식 기준 필드 정보 구성
  PERFORM init_fcat_from_itab        USING    lt_excl_rej
                                     CHANGING lt_fcat.

  LOOP AT lt_excel INTO DATA(ls_excel).
    ASSIGN COMPONENT ls_excel-col OF STRUCTURE ls_excl_rej TO FIELD-SYMBOL(<lv_fld>).

    CHECK <lv_fld> IS ASSIGNED.

    READ TABLE lt_fcat INDEX ls_excel-col
                       INTO DATA(ls_fcat).
    IF sy-subrc EQ 0.
*-- Conversion Exit 정보 기준 값 구성
      IF ls_fcat-convexit IS NOT INITIAL.
        DATA(lv_fname) = |CONVERSION_EXIT_| && ls_fcat-convexit && |_INPUT|.

        CALL FUNCTION lv_fname
          EXPORTING
            input  = ls_excel-value
          IMPORTING
            output = <lv_fld>.
      ELSE.
        <lv_fld> = ls_excel-value.
      ENDIF.
    ENDIF.

    AT END OF row.
      APPEND ls_excl_rej TO lt_excl_rej.
      CLEAR ls_excl_rej.
    ENDAT.
  ENDLOOP.

*-----------------------------------------------------------------------
*-- 3. Excel Upload 정보 기준 ALV 출력 정보 구성
*-----------------------------------------------------------------------
  IF lt_excl_rej[] IS INITIAL.
    pv_eflag = abap_true.
    EXIT.
  ENDIF.

  SORT : lt_excl_rej BY vbeln posnr.

  PERFORM init_rej_alv_f_excel      USING    lt_excl_rej
                                    CHANGING gt_rej_ord
                                             pv_eflag.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_rej_alv_f_excel
*&---------------------------------------------------------------------*
*& As-Is 판매오더 거부사유 정보 Upload 정보 ALV 출력 정보 구성
*&---------------------------------------------------------------------*
*&      --> PT_EXCL_REJ  : Excel Upload 정보
*&      <-- PT_REJ_ORD   : 출력 ALV 정보 리턴
*&      <-- PV_EFLAG     : 오류 발생시 'X' 리턴
*&---------------------------------------------------------------------*
FORM init_rej_alv_f_excel  USING    pt_excl_rej  TYPE gty_t_rej_excel
                           CHANGING pt_rej_ord   TYPE gty_t_rej_ord
                                    pv_eflag     TYPE char01.

  DATA : lv_msg TYPE bapi_msg.

  lv_msg = TEXT-e02.

*-- Excel Upload 정보 기준 As-Is 판매오더 정보 Select
  WITH +key_info AS ( SELECT a~vbeln, a~posnr
                        FROM @pt_excl_rej AS a )

    SELECT a~vbeln,   a~posnr,  a~matnr,  a~arktx,  a~werks,
           a~kwmeng,  a~vrkme,
           c~bstnk,   d~bstkd_e,

           CASE WHEN a~lfsta EQ 'C' THEN @gc_led-red
                ELSE @abap_false
           END AS stat,

           CASE WHEN a~lfsta EQ 'C' THEN @lv_msg
                ELSE @abap_false
           END AS zmsg

      FROM vbap AS a INNER JOIN +key_info AS b
                        ON a~vbeln EQ b~vbeln
                       AND a~posnr EQ b~posnr

                     INNER JOIN vbak AS c
                        ON a~vbeln EQ c~vbeln

                     INNER JOIN vbkd AS d
                        ON a~vbeln EQ d~vbeln
                       AND a~posnr EQ d~posnr

      INTO CORRESPONDING FIELDS OF TABLE @pt_rej_ord.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_fcat_from_rej
*&---------------------------------------------------------------------*
*& As-Is 판매오더 거부사유 처리 Fieldcatalog 추가 정보 구성
*&---------------------------------------------------------------------*
*&      <-- PT_FCAT  : Fieldcatalog 추가정보 리턴
*&---------------------------------------------------------------------*
FORM init_fcat_from_rej  CHANGING pt_fcat  TYPE lvc_t_fcat.

*-- 추가 정보 구성
  LOOP AT pt_fcat ASSIGNING FIELD-SYMBOL(<ls_fcat>).

    CASE <ls_fcat>-fieldname.
      WHEN 'VBELN'.
        <ls_fcat>-hotspot   = abap_true.
        <ls_fcat>-emphasize = 'C500'.

      WHEN 'ZMSG'.
        <ls_fcat>-coltext   = '결과메세지'(f01).
        <ls_fcat>-scrtext_l = '결과메세지'(f01).
        <ls_fcat>-scrtext_m = '결과메세지'(f01).
        <ls_fcat>-scrtext_s = '결과메세지'(f01).

      WHEN 'KWMENG'.
        <ls_fcat>-qfieldname = 'VRKME'.

      WHEN 'BSTNK'.
        <ls_fcat>-coltext   = 'Project No'(f14).
        <ls_fcat>-scrtext_l = 'Project No'(f14).
        <ls_fcat>-scrtext_m = 'Project No'(f14).
        <ls_fcat>-scrtext_s = 'Project No'(f14).

      WHEN 'BSTKD_E'.
        <ls_fcat>-coltext   = '제조지시 번호'(f15).
        <ls_fcat>-scrtext_l = '제조지시 번호'(f15).
        <ls_fcat>-scrtext_m = '제조지시 번호'(f15).
        <ls_fcat>-scrtext_s = '제조지시 번호'(f15).

    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form rej_ord_asis
*&---------------------------------------------------------------------*
*& As-Is 판매오더 거부사유 처리
*&---------------------------------------------------------------------*
FORM rej_ord_asis .

  CONSTANTS lc_rej TYPE abgru VALUE 'Z6'.

  DATA : ls_headerx TYPE bapisdh1x,

         lt_item    TYPE bapisditm_tt,
         lt_itemx   TYPE crmt_bapisditmx_t,

         lt_return  TYPE bapiret2_tt,
         ls_return  TYPE bapiret2,

         ls_rej_ord TYPE gty_rej_ord,

         lv_vbeln   TYPE vbeln_va,
         lv_answer  TYPE char01.

*-----------------------------------------------------------------------
*-- As-Is 판매오더 거부사유 처리 가능 여부 확인
*-----------------------------------------------------------------------
*-- 해당 출하문서 생성 여부 확인
  WITH +sd_info AS ( SELECT a~vbeln, a~posnr
                       FROM @gt_rej_ord AS a
                      GROUP BY a~vbeln, a~posnr )

     SELECT SINGLE @abap_true
       FROM vbap AS a INNER JOIN +sd_info AS b
                         ON a~vbeln EQ b~vbeln
                        AND a~posnr EQ b~posnr
      WHERE a~lfsta EQ 'C'

       INTO @DATA(lv_flag).

  IF sy-subrc EQ 0.
*    출하문서 존재시 오류 메세지 & Exit
    MESSAGE s000 WITH TEXT-e20 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  SELECT SINGLE @abap_true
    FROM @gt_rej_ord AS a
   WHERE a~stat EQ @gc_led-red

    INTO @lv_flag.

  IF sy-subrc EQ 0.
    MESSAGE s000 WITH '오류정보가 존재합니다.'(e21)
                 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  PERFORM popup_to_confirm          USING    'As-Is 판매오더 거부사유 처리'(t10)
                                             'As-Is 판매오더 거부사유 처리 하시겠습니까?'(m09)
                                    CHANGING lv_answer.
  IF lv_answer NE '1'.
    MESSAGE s050.
    EXIT.
  ENDIF.

*-----------------------------------------------------------------------
*-- As-Is 판매오더 거부사유 처리 수행
*-----------------------------------------------------------------------
  LOOP AT gt_rej_ord INTO DATA(ls_ord_lst)
                     GROUP BY ( vbeln = ls_ord_lst-vbeln
                                size  = GROUP SIZE )
                     ASSIGNING FIELD-SYMBOL(<rej_ord>).

    CLEAR : ls_headerx, ls_return, ls_rej_ord, lv_vbeln,
            lt_item, lt_itemx, lt_return.
*-- 해당 판매오더 Header 변경정보 구성
    ls_headerx = VALUE #(
                          updateflag = 'U'
                        ).

    LOOP AT GROUP <rej_ord> ASSIGNING FIELD-SYMBOL(<ls_item>).
*-- Item 정보 기준 거부사유 구성
      APPEND VALUE #(
                      itm_number = <ls_item>-posnr
                      po_itm_no  = <ls_item>-posnr
                      reason_rej = lc_rej
                    ) TO lt_item.

      APPEND VALUE #(
                      itm_number = <ls_item>-posnr
                      updateflag = 'U'
                      po_itm_no  = abap_true
                      reason_rej = abap_true
                    ) TO lt_itemx.
    ENDLOOP.

    lv_vbeln = <rej_ord>-vbeln.

*-- As-Is 판매오더 거부사유 처리 BAPI 수행
    CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
      EXPORTING
        salesdocument    = lv_vbeln
        order_header_inx = ls_headerx
      TABLES
        return           = lt_return[]
        order_item_in    = lt_item[]
        order_item_inx   = lt_itemx[].

*-----------------------------------------------------------------------
*-- 판매오더 삭제 결과 ALV  화면 반영
*-----------------------------------------------------------------------
    READ TABLE lt_return WITH KEY type = 'S'
                         INTO ls_return.
    IF sy-subrc EQ 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_false.

      ls_rej_ord = VALUE #(
                            stat = gc_led-green
                            zmsg = |판매오더| && <rej_ord>-vbeln && |거부처리 되었습니다.|
                          ).

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      READ TABLE lt_return WITH KEY type = 'E'
                           INTO ls_return.

      ls_rej_ord = VALUE #(
                            stat = gc_led-red
                            zmsg = ls_return-message
                          ).
    ENDIF.

    MODIFY gt_rej_ord FROM ls_rej_ord
                      TRANSPORTING stat zmsg
                      WHERE vbeln EQ <rej_ord>-vbeln.
  ENDLOOP.

ENDFORM.
