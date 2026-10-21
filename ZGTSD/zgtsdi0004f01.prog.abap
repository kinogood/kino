*&---------------------------------------------------------------------*
*& Include          ZGTSDI0001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM initialization .
*  s_targ-low = gc_kpcm.
*  __rng s_targ 'I' 'EQ' s_targ-low s_targ-high.

  s_erdat-low = sy-datlo.
  s_erdat-high = sy-datlo.
  __rng s_erdat 'I' 'EQ' s_erdat-low s_erdat-high.
  s_erdat2[] = s_erdat[].
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_screen .

  LOOP AT SCREEN.
    CASE screen-name.
      WHEN 'S_TARG-LOW'.
        screen-required = 2.
      WHEN OTHERS.
    ENDCASE.

    CASE screen-group1.

      WHEN 'M1'.
        IF rb_disp = gc_x.
          screen-active = 0.
        ENDIF.
      WHEN 'M2'.
        IF rb_send = gc_x.
          screen-active = 0.
        ENDIF.
    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_INPUT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_input_data .

  CLEAR gv_error.

  "기본 필수입력 필드 체크

*  IF rb_disp = gc_x AND s_targ[] IS INITIAL.
*    IF s_targ[] IS INITIAL. "
*      MESSAGE s007 WITH %_s_targ_%_app_%-text DISPLAY LIKE zgtsd_e.
*      gv_error = zgtsd_x.
*      RETURN.
*    ENDIF.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM authority_check .

*  "권한 체크
*  ZGTSD_CL_COMMON=>AUTHORITY_CHECK( EXPORTING IV_OBJECT     = 'VKO'
*                                              IV_AUTH_FIELD = CONV XUFIELD( |VKORG| )
*                                              IV_AUTH_VAL   = CONV XUVAL( P_VKORG )
*                                    IMPORTING EV_MTYPE      = DATA(LV_MTYPE)
*                                              EV_MSGTX      = DATA(LV_MSGTX) ).
*  IF LV_MTYPE = GC_E.
*    MESSAGE S001(00) WITH LV_MSGTX DISPLAY LIKE GC_E.
*    LEAVE LIST-PROCESSING.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_QUERY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM data_query .

*VBELN
*POSNR
*KUNNR
*ROUTE
*BRGEW
*NTGEW
*GEWEI
  DATA : lv_brgew LIKE lips-brgew,
         lv_ntgew LIKE lips-ntgew,
         lv_gewei LIKE lips-gewei.

  DATA : BEGIN OF lt_itab OCCURS 0 .
  DATA : vbeln LIKE lips-vbeln,
         posnr LIKE lips-posnr,
         kunnr LIKE likp-kunnr,
         route LIKE likp-route,
         brgew LIKE lips-brgew,
         ntgew LIKE lips-ntgew,
         gewei LIKE lips-gewei.

  DATA : END OF lt_itab.
  DATA : lt_deliv LIKE TABLE OF gs_s0100,
         ls_head  TYPE zgtsdt1007,
         ls_item  TYPE zgtsdt1008.

  RANGES : lr_targ  FOR zgtsdt1002-zsystem_id,
           lr_tplst FOR vttk-tplst,
           lr_tknum FOR vttk-tknum,
           lr_werks FOR vbap-werks.
  DATA : lv_zifkey LIKE zgtsdt1015-zifkey.
  CLEAR gv_error.
  __cle : gt_s0100, gt_head, gt_item.

  CASE gc_x.
    WHEN rb_t1.
      gv_tar = gc_kpcm.
    WHEN rb_10.
      gv_tar = gc_kscm.

*[S] 한미소
      WHEN rb_11.
        gv_tar = gc_kmom.
*[E] 한미소
  ENDCASE.
  __rng lr_targ 'I' 'EQ' gv_tar ''.



  SELECT DISTINCT @zgtsd_i AS sign, @zgtsd_eq AS option, zdesi AS low
    FROM zlet0201
   WHERE zcodh = 'SO03'
     AND zcodi = @gv_tar
    INTO CORRESPONDING FIELDS OF TABLE @lr_tplst.

  CHECK sy-subrc = 0.

  IF rb_send = gc_x.

*  생성/변경일자 기준 변경된 선적문서 가져오기
    SELECT h~tknum
      INTO TABLE @DATA(LT_vttk)
      FROM vttk AS h
      INNER JOIN vttp AS i
        ON h~tknum EQ i~tknum
     WHERE ( h~erdat IN @s_erdat OR
             h~aedat IN @s_erdat OR
             i~erdat IN @s_erdat )
       AND h~tknum IN @s_tknum
       AND h~tplst IN @lr_tplst.

    SORT lt_vttk.
    DELETE ADJACENT DUPLICATES FROM lt_vttk COMPARING ALL FIELDS.

    IF lt_Vttk[] IS INITIAL  AND s_tknum[] IS NOT INITIAL..
      "삭제된 선적

      LOOP AT s_tknum.
        s_tknum-low = |{ s_tknum-low ALPHA = OUT }|.
        MODIFY s_tknum.
      ENDLOOP.

      SELECT SINGLE MAX( zifkey )
        INTO lv_zifkey
      FROM zgtsdt1015
      WHERE tknum IN s_tknum
       AND zstat = '00'.
      CHECK sy-subrc = 0 .

      SELECT *
      INTO CORRESPONDING FIELDS OF TABLE gt_head
      FROM zgtsdt1015
      WHERE  zifkey = lv_zifkey.

      SELECT *
       INTO CORRESPONDING FIELDS OF TABLE gt_item
       FROM zgtsdt1016
       WHERE  zifkey = lv_zifkey.

      LOOP AT gt_head.
        gt_head-reqtyp = 'D'."삭제
        MODIFY gt_head. CLEAR : gt_head.
      ENDLOOP.

      lr_tknum[] = VALUE #( FOR ls_tmp2 IN gt_head
                     ( sign = 'I'
                       option = 'EQ'
                       low = ls_tmp2-tknum
                       high = '' ) ).



    ELSE.
      CHECK lt_vttk[] IS NOT INITIAL.
      lr_tknum[] = VALUE #( FOR ls_tmp IN lt_vttk
                     ( sign = 'I'
                       option = 'EQ'
                       low = ls_tmp-tknum
                       high = '' ) ).

      "HEAD
      SELECT
        CAST( dtdis AS CHAR ) AS dtdis ,
        CAST( dtabf AS CHAR ) AS dtabf ,
        tknum, tplst, shtyp, vsart, vsbed, bfart,
        add06, sdabw, tdlnr, exti1, exti2, tpbez,
        signi
        INTO CORRESPONDING FIELDS OF TABLE @gt_head
        FROM vttk
        WHERE tknum IN @lr_tknum.

      "ITEM
      SELECT vttp~vbeln,lips~posnr,likp~kunag AS kunnr,
        likp~route, vttp~tknum
*      lips~BRGEW,lips~NTGEW,
*      lips~GEWEI
        INTO CORRESPONDING FIELDS OF TABLE @gt_item
        FROM vttp AS vttp
        INNER JOIN lips AS lips
          ON vttp~vbeln EQ lips~vbeln
        INNER JOIN likp AS likp
          ON lips~vbeln EQ likp~vbeln
        WHERE tknum IN @lr_tknum
        AND lips~uecha = ' '..

    ENDIF.


    "tms정보
    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_tms
      FROM zlet0905
      WHERE tknum IN lr_tknum
      AND gubun = 'E'
      AND reqtyp = 'C'.

    LOOP AT gt_head.
      READ TABLE gt_tms WITH KEY tknum = gt_head-tknum.
      IF sy-subrc = 0 .
        gt_head-z003 = gt_tms-z003.
        gt_head-z007 = gt_tms-z007.
        gt_head-z008 = gt_tms-z008.
        gt_head-z009 = gt_tms-z009.
        gt_head-z010 = gt_tms-z010.
      ENDIF.

      IF gt_head-reqtyp <> 'D'.
        SELECT SINGLE mandt
          INTO sy-mandt
          FROM zgtsdt1015
          WHERE tknum = gt_head-tknum
          AND zsystem_id = gv_tar
          AND reqtyp = 'C'
          AND zstat = '00'.

        IF sy-subrc = 0.
          gt_head-reqtyp = 'U'. " 변경
        ELSE.
          gt_head-reqtyp = 'C'."생성
        ENDIF.
      ENDIF.

      MODIFY gt_head. CLEAR : gt_head.
    ENDLOOP.
*
    LOOP AT gt_item.
      CLEAR :lv_brgew, lv_ntgew, lv_gewei.

      SELECT SINGLE SUM( brgew ) SUM( ntgew ) gewei
        INTO ( lv_brgew , lv_ntgew , lv_gewei )
        FROM  lips
        WHERE vbeln = gt_item-vbeln
        AND ( posnr = gt_item-posnr OR
              uecha = gt_item-posnr )
        GROUP BY gewei.

      WRITE lv_brgew TO gt_item-brgew.
      WRITE lv_NTGEW TO gt_item-ntgew.
      gt_item-gewei = lv_gewei.

      MODIFY gt_item. CLEAR : gt_item.
    ENDLOOP.


  ELSE.

    LOOP AT s_tknum.
      s_tknum-low = |{ s_tknum-low ALPHA = OUT }|.
      MODIFY s_tknum.
    ENDLOOP.

    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE gt_head
      FROM zgtsdt1015
      WHERE tknum IN s_tknum
      AND zsystem_id IN lr_targ
      AND ifdat IN s_erdat2.

    SELECT *
     INTO CORRESPONDING FIELDS OF TABLE gt_item
     FROM zgtsdt1016
     WHERE tknum IN s_tknum
     AND zsystem_id IN lr_targ
     AND ifdat IN s_erdat2.

  ENDIF.


***********************************************************************
**ALV 화면 데이터
***********************************************************************
  LOOP AT gt_head.
    CLEAR gs_s0100.
    MOVE-CORRESPONDING gt_head TO gs_s0100.

    gs_s0100-statu = icon_led_inactive.

    CASE gc_x.
      WHEN rb_t1.
        gs_s0100-zsystem_id = gc_kpcm.
        gs_s0100-system_nm  = TEXT-s06.
      WHEN rb_10.
        gs_s0100-zsystem_id = gc_kscm.
        gs_s0100-system_nm  = TEXT-s12.
*[S] 한미소
      WHEN rb_11.
        gs_s0100-zsystem_id = gc_kmom.
        gs_s0100-system_nm  = TEXT-s15.
*[E] 한미소

    ENDCASE.
    CASE gs_s0100-zstat.
      WHEN '00' OR '0'.
        gs_s0100-statu = icon_led_green.
      WHEN OTHERS.
        gs_s0100-statu = icon_led_red.
    ENDCASE.

    gs_s0100-msg   = gs_s0100-zmessage.
    APPEND gs_s0100 TO gt_s0100.
  ENDLOOP.


***********************************************************************
** 결과조회 상태
***********************************************************************
  IF rb_disp = 'X'.
    CASE gc_x.
      WHEN rb_su.
        DELETE gt_s0100 WHERE zstat NE '00' AND zstat NE '0'.
      WHEN rb_fa.
        DELETE gt_s0100 WHERE zstat = '00' OR zstat = '0'.
    ENDCASE.
  ENDIF.



***********************************************************************
*  "데이타 건수 메시지 출력
  IF gt_s0100 IS NOT INITIAL.
    MESSAGE s009 WITH |{ lines( gt_s0100 ) NUMBER = USER }|. "& 건 검색되었습니다.
  ELSE.
    MESSAGE s010.                                           "조회할 데이타가 없습니다.
    gv_error = gc_x.                                        "데이타 없으면 출력 X
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_ALV_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GO_CON
*&      <-- GO_GRID
*&---------------------------------------------------------------------*
FORM init_alv_0100  CHANGING po_dcon TYPE REF TO cl_gui_docking_container
                             po_grid TYPE REF TO cl_gui_alv_grid.

  "Create Main Container
  PERFORM create_doc_container CHANGING po_dcon.

  "Split
  go_split = NEW #( parent = po_dcon rows = 2 columns = 1 ).

  go_con_top       = go_split->get_container( row = 1 column = 1 ).
  DATA(lo_con_btt) = go_split->get_container( row = 2 column = 1 ).

  go_split->set_row_height( id = 1 height = 15 ).

  "Create Object
  go_docu = NEW #( style = 'ALV_GRID' ).  "Top-Of-Page

  PERFORM create_alv USING    lo_con_btt
                     CHANGING po_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_DOC_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_doc_container CHANGING po_dcon TYPE REF TO cl_gui_docking_container.

  CREATE OBJECT po_dcon
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

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_alv CHANGING po_con
                         po_grid TYPE REF TO cl_gui_alv_grid.

  CREATE OBJECT po_grid
    EXPORTING
      i_parent          = po_con
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ATTRIBUTES_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_attributes_0100 .

  "Layout 지정
  PERFORM set_grid_layout USING space space zgtsd_d.

  "Field Catalog
  PERFORM set_fieldcatalog.

  "Toolbar 제외
  PERFORM exclude_toolbar TABLES gt_toolbar.

  "Event Handler 등록
  PERFORM create_event_receiver USING go_grid.

  "F4 필드 등록
  PERFORM register_f4_fields.

  "SORT
*  PERFORM SET_ALV_SORT CHANGING GT_SORT.

  "Top-Of-Page Event 등록
  PERFORM set_top_of_page_event.

  "ALV Grid Display
  PERFORM set_table_for_first_display USING go_grid
                                            gt_s0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_grid_layout USING pv_cwopt
                           pv_stylefname
                           pv_sel_mode.

  CLEAR gs_layout.
  gs_layout = VALUE #( sel_mode   = pv_sel_mode
                       zebra      = zgtsd_x
                       cwidth_opt = pv_cwopt
                       stylefname = pv_stylefname ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_fieldcatalog .

  "Get Field Catalog
  PERFORM get_field_catalog USING gt_s0100 CHANGING gt_fcat.

  "Set Field Catalog
  PERFORM set_fieldcatalog_main.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_field_catalog USING pt_table TYPE table
                    CHANGING pt_fcat TYPE lvc_t_fcat.

  REFRESH pt_fcat.

  pt_fcat = zgtsd_cl_common=>get_field_catalog( it_table = pt_table
                                                iv_cells = zgtsd_z
                                                iv_cellc = zgtsd_z ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG_MAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcatalog_main .


  SORT gt_fcat BY fieldname.

  IF rb_disp = gc_x.
    PERFORM reset_field_catalog TABLES gt_fcat USING :
        'S' 'FIELDNAME'   'ZIFKEY',
        ' ' 'COLTEXT'     TEXT-f00,
        ' ' 'ICON'        'X',
        ' ' 'OUTPUTLEN'   '10',
        'E' 'KEY'         'X'.
  ENDIF.

  PERFORM reset_field_catalog TABLES gt_fcat USING :
      'S' 'FIELDNAME'   'STATU',
      ' ' 'COLTEXT'     TEXT-f01,
      ' ' 'ICON'        'X',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'ZMESSAGE',
      ' ' 'COLTEXT'     TEXT-f02,
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'ZSYSTEM_ID',
      ' ' 'COLTEXT'     TEXT-f03,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'SYSTEM_NM',
      ' ' 'COLTEXT'     TEXT-f04,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'TKNUM',
      ' ' 'COLTEXT'     TEXT-f05,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'TPLST',
      ' ' 'COLTEXT'     TEXT-f06,
      'E' 'OUTPUTLEN'   '8',

      'S' 'FIELDNAME'   'SHTYP',
      ' ' 'COLTEXT'     TEXT-f07,
      'E' 'OUTPUTLEN'   '8',

      'S' 'FIELDNAME'   'VSART',
      ' ' 'COLTEXT'     '출하유형',
      'E' 'OUTPUTLEN'   '8',

      'S' 'FIELDNAME'   'VSBED',
      ' ' 'COLTEXT'     '출하조건',
      'E' 'OUTPUTLEN'   '4',

      'S' 'FIELDNAME'   'BFART',
      ' ' 'COLTEXT'     '서비스레벨',
      'E' 'OUTPUTLEN'   '8',

      'S' 'FIELDNAME'   'ADD06',
      ' ' 'COLTEXT'     '인도조건',
      'E' 'OUTPUTLEN'   '4',

      'S' 'FIELDNAME'   'SDABW',
      ' ' 'COLTEXT'     '차량유형',
      'E' 'OUTPUTLEN'   '4',

      'S' 'FIELDNAME'   'TDLNR',
      ' ' 'COLTEXT'     '운송사코드',
      'E' 'OUTPUTLEN'   '4',

      'S' 'FIELDNAME'   'EXTI1',
      ' ' 'COLTEXT'     '차량번호',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'EXTI2',
      ' ' 'COLTEXT'     '기사명',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'TPBEZ',
      ' ' 'COLTEXT'     '기사전화번호',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'SIGNI',
      ' ' 'COLTEXT'     '컨테이너',
      'E' 'OUTPUTLEN'   '20'.

  IF rb_disp = gc_x.
    PERFORM reset_field_catalog TABLES gt_fcat USING :
        'S' 'FIELDNAME'   'IFDAT',
        ' ' 'COLTEXT'     TEXT-f22,
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'IFTIM',
        ' ' 'COLTEXT'     TEXT-f23,
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'IFNAM',
        ' ' 'COLTEXT'     TEXT-f24,
        'E' 'OUTPUTLEN'   '10'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM reset_field_catalog TABLES pt_fcat TYPE lvc_t_fcat
                         USING  pv_flag
                                pv_fname
                                pv_value.

  STATICS : ls_fcat   TYPE lvc_s_fcat,
            lv_colpos TYPE lvc_colpos,
            lv_tabix  TYPE sytabix.

  IF pv_flag = zgtsd_s.  "Start
    CLEAR ls_fcat.
    READ TABLE pt_fcat INTO ls_fcat WITH KEY fieldname = pv_value BINARY SEARCH.
    CHECK sy-subrc = 0.
    lv_tabix = sy-tabix.

    lv_colpos = lv_colpos + 1.

    ls_fcat-tech    = space.
    ls_fcat-col_pos = lv_colpos.
  ENDIF.

  CASE pv_fname.
    WHEN 'COLTEXT'.   "Text
      ls_fcat-coltext  = pv_value.
      ls_fcat-reptext  = pv_value.
      ls_fcat-seltext  = pv_value.
      ls_fcat-tooltip  = pv_value.
    WHEN OTHERS.
      ASSIGN COMPONENT pv_fname OF STRUCTURE ls_fcat TO FIELD-SYMBOL(<lv_value>).
      CHECK sy-subrc = 0.
      <lv_value> = pv_value.
  ENDCASE.

  IF pv_flag = zgtsd_e.  "End
    MODIFY pt_fcat FROM ls_fcat INDEX lv_tabix.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*----------------------------------------------------------------------*
FORM exclude_toolbar TABLES pt_exclude TYPE ui_functions.

  REFRESH pt_exclude.

  APPEND : cl_gui_alv_grid=>mc_fc_loc_undo            TO pt_exclude,
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
           cl_gui_alv_grid=>mc_fc_info                TO pt_exclude.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_EVENT_RECEIVER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM create_event_receiver USING po_sender TYPE REF TO cl_gui_alv_grid.

  "Create Event
  DATA(lo_event) = NEW lcl_event_receiver( ).

  CASE po_sender.
    WHEN go_grid.
      SET HANDLER : lo_event->handle_top_of_page FOR po_sender.
  ENDCASE.

  SET HANDLER : lo_event->handle_hotspot_click         FOR po_sender,
                lo_event->handle_dbl_click             FOR po_sender.
*                LO_EVENT->HANDLE_TOOLBAR               FOR PO_SENDER,
*                LO_EVENT->HANDLE_USER_COMMAND          FOR PO_SENDER,
*                LO_EVENT->HANDLE_ON_F4                 FOR PO_SENDER.
*               LO_EVENT->HANDLE_DATA_CHANGED          FOR PO_SENDER,
*               LO_EVENT->HANDLE_DATA_CHANGED_FINISHED FOR PO_SENDER.

*  "Data Changed Event
*  PO_SENDER->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
*  PO_SENDER->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_ENTER ).

*  "Set Ready for Input
*  GO_GRID->SET_READY_FOR_INPUT( SWITCH #( GV_EDIT WHEN ZGTSD_X THEN 1 ELSE 0 ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REGISTER_F4_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM register_f4_fields .

  DATA : lt_f4   TYPE lvc_t_f4,
         lt_fcat TYPE TABLE OF lvc_s_fcat
                 WITH NON-UNIQUE SORTED KEY key_mode
                 COMPONENTS f4availabl fieldname.

  lt_fcat = gt_fcat.
  LOOP AT lt_fcat INTO DATA(ls_fcat) USING KEY key_mode
                  WHERE f4availabl = zgtsd_x.
    lt_f4 = VALUE #( BASE lt_f4 ( fieldname  = ls_fcat-fieldname
                                  register   = zgtsd_x
                                  chngeafter = zgtsd_x ) ).
  ENDLOOP.

  go_grid->register_f4_for_fields( EXPORTING it_f4 = lt_f4 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TOP_OF_PAGE_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_top_of_page_event .

  CHECK go_docu IS BOUND.

  go_docu->initialize_document( background_color = cl_dd_area=>col_textarea ).

  CALL METHOD go_grid->list_processing_events(
      i_event_name = slis_ev_top_of_page
      i_dyndoc_id  = go_docu ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_table_for_first_display USING po_sender TYPE REF TO cl_gui_alv_grid
                                       pt_data TYPE table.
  DATA : lv_handl TYPE slis_handl.



  "레이아웃 Variant 구분자
  PERFORM set_variant_handle USING po_sender CHANGING lv_handl.

  DELETE gt_fcat WHERE tech = zgtsd_x. "불필요한 필드 제외

  "Formatted Output Table is Sent to Control
  CALL METHOD po_sender->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout
      is_variant           = VALUE #( report = sy-repid
                                      handle = lv_handl )
      i_save               = zgtsd_a
      it_toolbar_excluding = gt_toolbar
    CHANGING
      it_fieldcatalog      = gt_fcat
      it_sort              = gt_sort[]
      it_outtab            = pt_data[].




ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT_HANDLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_variant_handle USING po_sender TYPE REF TO cl_gui_alv_grid
                         CHANGING pv_handl.

  CLEAR pv_handl.
  CASE po_sender.
    WHEN go_grid. "Main
      pv_handl = 1.
    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DBL_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM handle_dbl_click  USING    pv_row     TYPE lvc_s_row
                                pv_column  TYPE lvc_s_col.

*  CHECK pv_row-rowtype EQ space.
*  READ TABLE gt_s0100 INTO gs_s0100 INDEX pv_row-index.
*  CHECK sy-subrc = 0 .
*
*  CASE pv_column.
*    WHEN 'VBELN'.
*      CHECK gs_s0100-vbeln IS NOT INITIAL.
*      SET PARAMETER ID: 'VL' FIELD   gs_s0100-vbeln.
*      CALL TRANSACTION  'VL03N' AND SKIP FIRST SCREEN.
*
**    WHEN .
*    WHEN OTHERS.
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_SORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_SORT
*&---------------------------------------------------------------------*
FORM set_alv_sort  CHANGING pt_sort TYPE lvc_t_sort.

  CLEAR : pt_sort[].

  PERFORM set_sort_field USING: pt_sort 'VBELN' gc_x '' '',
                                pt_sort 'AEDAT_H' gc_x '' '',
                                pt_sort 'AEZET_H' gc_x '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_SORT
*&      --> P_
*&      --> GC_X
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_sort_field  USING pt_sort TYPE lvc_t_sort
                           pv_fldname
                           pv_up
                           pv_down
                           pv_subtot.

  APPEND VALUE #( spos      = lines( pt_sort ) + 1
                  fieldname = pv_fldname
                  up        = pv_up
                  down      = pv_down
                  subtot    = pv_subtot ) TO pt_sort.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_top_of_page USING po_docu TYPE REF TO cl_dd_document
                                  po_sender.
  DATA : lv_text TYPE sdydo_text_element.

  CHECK po_sender = go_grid "Main
    AND po_docu IS BOUND.

  "Set Column Width
  po_docu->add_table( EXPORTING no_of_columns = 3 border = '0' IMPORTING table = DATA(lo_table) ).

  lo_table->add_column( EXPORTING width = '20%' IMPORTING column = DATA(lo_col_key) ).
  lo_table->add_column( EXPORTING width = '3%' IMPORTING column = DATA(lo_col_sep) ).
  lo_table->add_column( EXPORTING width = '77%' IMPORTING column = DATA(lo_col_val) ).
  lo_table->new_row( ).

  "Set Column Style
  lo_table->set_column_style( col_no = 1 sap_emphasis = cl_dd_document=>strong sap_align = 'LEFT' ).
  lo_table->set_column_style( col_no = 3 sap_emphasis = cl_dd_document=>medium sap_align = 'LEFT' ).

  "Add Text
*  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
*                                ZGTSD_S %_S_VBELN_%_APP_%-TEXT 'S_VBELN[]'.

  PERFORM add_text_common USING lo_col_key lo_col_sep lo_col_val lo_table
                                zgtsd_s %_s_erdat_%_app_%-text 'S_ERDAT[]'.
  CASE gc_x.
    WHEN rb_send.
      PERFORM add_text_common USING lo_col_key lo_col_sep lo_col_val lo_table
                                    zgtsd_p TEXT-s01 TEXT-s03.
      CASE gc_x.
        WHEN rb_t1.
          PERFORM add_text_common USING lo_col_key lo_col_sep lo_col_val lo_table
                                        zgtsd_p TEXT-s02 TEXT-s06.
*        WHEN RB_T2.
*          PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
*                                        ZGTSD_P TEXT-S02 TEXT-S07.
        WHEN rb_10.
          PERFORM add_text_common USING lo_col_key lo_col_sep lo_col_val lo_table
                                        zgtsd_p TEXT-s02 TEXT-s12.
      ENDCASE.
    WHEN rb_disp.
      PERFORM add_text_common USING lo_col_key lo_col_sep lo_col_val lo_table
                                    zgtsd_p TEXT-s01 TEXT-s04.
      CASE gc_x.
        WHEN rb_all.
          PERFORM add_text_common USING lo_col_key lo_col_sep lo_col_val lo_table
                                        zgtsd_p TEXT-s08 TEXT-s09.
        WHEN rb_su.
          PERFORM add_text_common USING lo_col_key lo_col_sep lo_col_val lo_table
                                        zgtsd_p TEXT-s08 TEXT-s10.
        WHEN rb_fa.
          PERFORM add_text_common USING lo_col_key lo_col_sep lo_col_val lo_table
                                        zgtsd_p TEXT-s08 TEXT-s11.
      ENDCASE.
  ENDCASE.

  "Display Document
  po_docu->merge_document( ).
  po_docu->display_document( EXPORTING
                               reuse_control      = zgtsd_x
                               parent             = go_con_top
                             EXCEPTIONS
                               html_display_error = 1 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_TEXT_COMMON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM add_text_common USING po_col_key TYPE REF TO cl_dd_area
                               po_col_sep TYPE REF TO cl_dd_area
                               po_col_val TYPE REF TO cl_dd_area
                               po_table   TYPE REF TO cl_dd_table_element
                               pv_flag
                               pv_key
                               pv_value.
  FIELD-SYMBOLS : <lt_selopt> TYPE table.
  DATA lv_text TYPE char255.

  CASE pv_flag.
    WHEN zgtsd_p. "Parameter
      CHECK pv_value IS NOT INITIAL.
      lv_text = CONV sdydo_text_element( pv_value ).
    WHEN zgtsd_s. "Select-Option
      ASSIGN (pv_value) TO <lt_selopt>.
      CHECK sy-subrc = 0.

      CHECK lines( <lt_selopt> ) => 1.

      ASSIGN COMPONENT 'LOW' OF STRUCTURE <lt_selopt>[ 1 ] TO FIELD-SYMBOL(<lv_low>).
      CHECK sy-subrc = 0.
      ASSIGN COMPONENT 'HIGH' OF STRUCTURE <lt_selopt>[ 1 ] TO FIELD-SYMBOL(<lv_high>).
      CHECK sy-subrc = 0.

      IF <lv_high> IS INITIAL.
        lv_text = <lv_low>.
      ELSEIF <lv_low> IS INITIAL.
        lv_text = `~ ` &&  <lv_low>.
      ELSE.
        lv_text = <lv_low> && ` ~ ` &&  <lv_high>.
      ENDIF.
  ENDCASE.

  po_col_key->add_text( text = CONV sdydo_text_element( pv_key ) ).
  po_col_sep->add_text( text = CONV sdydo_text_element( zgtsd_colon ) ).
  po_col_val->add_text( text = lv_text ).

  po_table->new_row( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_hotspot_click USING ps_column TYPE lvc_s_col
                                ps_row_no TYPE lvc_s_roid
                                po_sender.

  CHECK po_sender = go_grid. "Main

  CASE ps_column-fieldname.

    WHEN 'MATNR'. "자산번호

      READ TABLE gt_s0100 INTO DATA(ls_main) INDEX ps_row_no-row_id.
      CHECK sy-subrc = 0.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_data_changed USING po_data_changed TYPE REF TO
                                 cl_alv_changed_data_protocol
                                 po_sender.

  CHECK po_sender = go_grid.  "Main

  DATA(lt_mod_cells) = po_data_changed->mt_good_cells.
  SORT lt_mod_cells BY row_id fieldname.

  REFRESH gt_chg.

  LOOP AT lt_mod_cells INTO DATA(ls_mod_temp).

    DATA(ls_mod_cells) = ls_mod_temp.

    AT NEW row_id.
      READ TABLE gt_s0100 INTO DATA(ls_main) INDEX ls_mod_cells-row_id.
      CHECK sy-subrc = 0.
    ENDAT.

    "체크사항 점검 및 Set Value
    PERFORM check_value_in_datachd USING    po_data_changed
                                            ls_mod_cells
                                   CHANGING ls_main.

    AT END OF row_id.
      "변경상태 Update
      PERFORM update_statu USING    po_data_changed
                                    ls_mod_cells
                           CHANGING ls_main-statu
                                    ls_main-modi.
      MODIFY gt_s0100 FROM ls_main INDEX ls_mod_cells-row_id.
      APPEND CORRESPONDING #( ls_main ) TO gt_chg.
    ENDAT.

  ENDLOOP.

  "Display Protocol
  po_data_changed->display_protocol( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_VALUE_IN_DATACHD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_value_in_datachd USING po_data_changed TYPE REF TO
                                      cl_alv_changed_data_protocol
                                      ps_mod_cells TYPE lvc_s_modi
                            CHANGING ps_data STRUCTURE gs_s0100.

  CASE ps_mod_cells-fieldname.

    WHEN OTHERS.
      ASSIGN COMPONENT ps_mod_cells-fieldname OF STRUCTURE ps_data TO FIELD-SYMBOL(<lv_value>).
      CHECK sy-subrc = 0.
      <lv_value> = ps_mod_cells-value.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CHANGED_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_changed_data USING po_grid TYPE REF TO cl_gui_alv_grid
                              pv_ck.

  CLEAR gv_error.
  CHECK po_grid IS BOUND.

  po_grid->check_changed_data( IMPORTING e_valid = DATA(lv_valid) ).

  IF pv_ck = zgtsd_x AND lv_valid IS INITIAL.
    gv_error = zgtsd_x. "오류 Flag
    MESSAGE s029 DISPLAY LIKE zgtsd_e. "오류 내역이 존재합니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_STATU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM update_statu USING po_data_changed TYPE REF TO
                            cl_alv_changed_data_protocol
                            ps_mod_cells TYPE lvc_s_modi
                   CHANGING pv_statu
                            pv_modi.

  pv_modi  = zgtsd_x.     "변경 Flag
  pv_statu = icon_change. "변경 Icon

  PERFORM modify_cell USING po_data_changed
                            ps_mod_cells-row_id
                            ps_mod_cells-tabix
                            'STATU'
                            pv_statu.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CELL_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_cell_value USING po_data_changed TYPE REF TO
                              cl_alv_changed_data_protocol
                              pv_row_id
                              pv_fieldname
                     CHANGING pv_value.

  CLEAR pv_value.
  po_data_changed->get_cell_value( EXPORTING
                                     i_row_id    = pv_row_id
                                     i_fieldname = pv_fieldname
                                   IMPORTING
                                     e_value     = pv_value ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_PROTOCOL_ENTRY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM add_protocol_entry USING po_data_changed TYPE REF TO
                                cl_alv_changed_data_protocol
                                pv_msgid
                                pv_msgno
                                pv_msgv1
                                pv_msgv2
                                pv_fieldname
                                pv_row_id.

  DATA : lt_data TYPE TABLE OF lvc_s_msg1
                 WITH NON-UNIQUE SORTED KEY key_mode
                 COMPONENTS msgid msgno msgv1 msgv2 fieldname row_id.

  lt_data = po_data_changed->mt_protocol.  "기존 동일 오류 제외

  CHECK NOT line_exists( lt_data[ KEY key_mode COMPONENTS msgid     = pv_msgid
                                                          msgno     = pv_msgno
                                                          msgv1     = pv_msgv1
                                                          msgv2     = pv_msgv2
                                                          fieldname = pv_fieldname
                                                          row_id    = pv_row_id ] ).

  po_data_changed->add_protocol_entry(
      EXPORTING
        i_msgid     = pv_msgid
        i_msgno     = pv_msgno
        i_msgty     = zgtsd_e
        i_msgv1     = pv_msgv1
        i_msgv2     = pv_msgv2
        i_fieldname = pv_fieldname
        i_row_id    = pv_row_id ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_CELL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM modify_cell USING po_data_changed TYPE REF TO
                         cl_alv_changed_data_protocol
                         pv_row_id
                         pv_tabix
                         pv_fieldname
                         pv_value.

  po_data_changed->modify_cell( i_row_id    = pv_row_id
                                i_tabix     = pv_tabix
                                i_fieldname = pv_fieldname
                                i_value     = pv_value ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_data_changed_finished USING pv_modified
                                            pt_good_cells TYPE lvc_t_modi
                                            po_sender.

  CHECK pv_modified = zgtsd_x
    AND po_sender   = go_grid
    AND gt_chg IS NOT INITIAL.

*  변경사항 반영
  PERFORM update_edit_fields USING gt_chg.

  "Refresh Grid
  PERFORM refresh_table_display USING po_sender space.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_EDIT_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM update_edit_fields USING pt_chg TYPE ty_t_chg.

*  "Set 수정 필드
*  DELETE ADJACENT DUPLICATES FROM PT_CHG USING KEY KEY_MODE COMPARING PSPID.
*
*  LOOP AT PT_CHG INTO DATA(LS_CHG).
*
*    DATA(LS_DATA) = VALUE #( GT_MAIN[ KEY KEY_STUFE
*                               COMPONENTS PSPID = LS_CHG-PSPID
*                                          STUFE = 1 ] OPTIONAL ).
*    CHECK LS_DATA-PSPID IS NOT INITIAL.
*
*    LOOP AT GT_MAIN ASSIGNING FIELD-SYMBOL(<LS_MAIN>) USING KEY KEY_MODE
*                     WHERE PSPID = LS_DATA-PSPID.
*      <LS_MAIN>-Z_IV_PUR       = LS_DATA-Z_IV_PUR.       "자산 매각
*      <LS_MAIN>-Z_IV_ANLKL     = LS_DATA-Z_IV_ANLKL.     "자산 클래스
*      <LS_MAIN>-Z_IV_ANLKL_TXT = LS_DATA-Z_IV_ANLKL_TXT. "자산 클래스 명
*      <LS_MAIN>-Z_KSTAR        = LS_DATA-Z_KSTAR.        "원가요소
*      <LS_MAIN>-Z_KSTAR_TXT    = LS_DATA-Z_KSTAR_TXT.    "원가요소 명
*    ENDLOOP.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_toolbar USING po_object TYPE REF TO cl_alv_event_toolbar_set
                              po_sender.
  DEFINE _add_toolbar.
    ls_toolbar = VALUE #( function   = &1
                          icon       = &2
                          quickinfo  = &3
                          text       = &4
                          butn_type  = &5 ).

    CASE &6.
      WHEN zgtsd_a. "Append
        APPEND ls_toolbar TO po_object->mt_toolbar.
      WHEN zgtsd_i. "Insert
        INSERT ls_toolbar INTO po_object->mt_toolbar INDEX 1.
    ENDCASE.
  END-OF-DEFINITION.

  DATA : ls_toolbar TYPE stb_button.

*  CHECK GV_EDIT = ZGTSD_X.     "수정가능 상태
*
*  CASE PO_SENDER.
*    WHEN GO_GRID. "Main
*      _ADD_TOOLBAR SPACE                SPACE            SPACE    SPACE    3 ZPS01_A.
*      _ADD_TOOLBAR ZPS01_UCOMM-AUC_SETL ICON_GENERATE    TEXT-009 TEXT-009 0 ZPS01_A. "AUC 정산규칙(F) 생성
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_TABLE_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM refresh_table_display USING po_grid TYPE REF TO cl_gui_alv_grid
                                  pv_soft_refresh.

  CHECK po_grid IS BOUND.

  DATA :  gs_scroll            TYPE lvc_s_stbl.
  gs_scroll-row = 'X'.
  gs_scroll-col = 'X'.
  CALL METHOD po_grid->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = gs_scroll.     "화면 라인 Refresh

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_ON_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_on_f4 USING pv_fieldname TYPE lvc_fname
                            pv_fieldvalue  TYPE lvc_value
                            ps_row_no      TYPE lvc_s_roid
                            po_event_data  TYPE REF TO cl_alv_event_data
                            pv_display     TYPE char01
                            po_sender.
  DATA : lv_value TYPE lvc_value.
  FIELD-SYMBOLS : <lt_data> TYPE table.

*  CHECK PO_SENDER = GO_GRID. "Main
*
*  PO_EVENT_DATA->M_EVENT_HANDLED = ZPS01_X.
*
*  CASE PV_FIELDNAME.
*    WHEN ZPS01_FNAME-Z_IV_ANLKL.  "자산 클래스
*
*      PERFORM F4_CODE_MASTER USING    ZPS01_ROLLNAME-ZE_IV_ANLKL
*                                      ZPS01_CODE-PSAC02
*                                      PV_DISPLAY
*                             CHANGING LV_VALUE.
*
*    WHEN OTHERS.
*      RETURN.
*  ENDCASE.
*
*  CHECK LV_VALUE IS NOT INITIAL.
*
*  ASSIGN PO_EVENT_DATA->M_DATA->* TO <LT_DATA>.
*  CHECK SY-SUBRC = 0.
*
*  APPEND VALUE LVC_S_MODI( FIELDNAME = PV_FIELDNAME
*                           ROW_ID    = PS_ROW_NO-ROW_ID
*                           VALUE     = LV_VALUE ) TO <LT_DATA>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FREE_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM free_object .
* Field Catalog
  CLEAR: gt_fcat[].

* Grid Clear
  CALL METHOD: go_grid->free.

  CLEAR: go_grid.

* Container Clear
  CALL METHOD: go_con->free,
               go_split->free,
               go_con_top->free.

  CLEAR: go_con, go_split, go_con_top.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_IF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM send_if USING pv_type.
*
*  DATA : lv_subrc  TYPE sy-subrc,
*         lv_cnt    TYPE i,
*         lv_result TYPE zo_result,
*         lv_dest   TYPE zifdest-dest,
*         lv_msg    TYPE zo_message,
*         lt_tmp    LIKE TABLE OF gs_s0100,
*         lt_1007   TYPE TABLE OF zgtsdt1007 WITH HEADER LINE,
*         lt_1008   TYPE TABLE OF zgtsdt1008 WITH HEADER LINE,
*         lt_header TYPE TABLE OF zgtsdsif0006 WITH HEADER LINE,
*         lt_item   TYPE TABLE OF zgtsdsif0007 WITH HEADER LINE.
*
*  "Selected Rows
*  DATA(lt_rows) = zgtsd_cl_common=>get_selected_rows( EXPORTING
*                                                        io_grid = go_grid
*                                                        iv_ck   = zgtsd_x
*                                                      IMPORTING
*                                                        ev_subrc = lv_subrc ).
*  CHECK lv_subrc IS INITIAL.
*
*  CLEAR gs_s0100.
*  MODIFY gt_s0100 FROM gs_s0100 TRANSPORTING sel WHERE sel IS NOT INITIAL.
*
*  LOOP AT lt_rows INTO DATA(ls_row).
*
*    READ TABLE gt_s0100 INTO gs_s0100 INDEX ls_row-index.
*    CHECK sy-subrc = 0.
*
*    CASE pv_type.
*      WHEN space.
*        IF gs_s0100-statu NE icon_led_inactive.
*          CONTINUE.
*        ENDIF.
*      WHEN gc_x.
*        IF gs_s0100-statu NE icon_led_inactive AND gs_s0100-statu NE icon_led_red.
*          CONTINUE.
*        ENDIF.
*    ENDCASE.
*
*    gs_s0100-sel = gc_x.
*    APPEND gs_s0100 TO lt_tmp.
*
*    MOVE-CORRESPONDING gs_s0100 TO lt_header.
*    __alpha_ou : gs_s0100-kunnr  lt_header-kunwe,
*                 gs_s0100-vbeln  lt_header-vbeln.
*
*    lt_header-erdat = gs_s0100-erdat_h.
*    lt_header-aedat = gs_s0100-aedat_h.
*    lt_header-aenam = gs_s0100-aenam_h.
*    APPEND lt_header. CLEAR lt_header.
*
*    LOOP AT gt_item INTO DATA(ls_item) USING KEY k_key WHERE vbeln = gs_s0100-vbeln .
*      MOVE-CORRESPONDING ls_item TO lt_item.
*      __alpha_ou : lt_item-matnr  lt_item-matnr,
*                   lt_item-vgbel  lt_item-vgbel,
*                   lt_item-vgpos  lt_item-vgpos,
*                   lt_item-vbeln  lt_item-vbeln,
*                   lt_item-posnr  lt_item-posnr.
*      APPEND lt_item. CLEAR lt_item.
*    ENDLOOP.
*
*    MODIFY gt_s0100 FROM gs_s0100 INDEX ls_row-index.
*  ENDLOOP.
*
*  SORT lt_tmp BY zsystem_id.
*  DELETE ADJACENT DUPLICATES FROM lt_tmp COMPARING zsystem_id.
*  IF lines( lt_tmp ) > 1.
*    MESSAGE s000 WITH TEXT-e03 DISPLAY LIKE gc_e.EXIT.
*  ELSE.
*    READ TABLE lt_tmp INTO DATA(ls_tmp) INDEX 1.
*    gv_tar = ls_tmp-zsystem_id.
*  ENDIF.
*
*  IF lt_header[] IS INITIAL.
*    MESSAGE s003 DISPLAY LIKE gc_e.EXIT.
*  ENDIF.
*
*  IF rb_t1 = 'X'.
*    CALL FUNCTION 'Z_IF_DESTINATION'
*      EXPORTING
*        gubun                 = 'IS'
*      IMPORTING
*        dest_name             = lv_dest
*      EXCEPTIONS
*        destination_not_found = 1
*        OTHERS                = 2.
*  ELSE.
*    CALL FUNCTION 'Z_IF_DESTINATION'
*      EXPORTING
*        gubun                 = 'SD'
*      IMPORTING
*        dest_name             = lv_dest
*      EXCEPTIONS
*        destination_not_found = 1
*        OTHERS                = 2.
*  ENDIF.
*  IF lv_dest IS  INITIAL.
*    MESSAGE s000 WITH TEXT-e04 DISPLAY LIKE gc_e.EXIT.
*  ENDIF.
*
*  CLEAR gv_answer.
*  CASE pv_type.
*    WHEN space.
*      gv_answer = zgtsd_cl_common=>popup_to_comfirm( iv_ucomm = space iv_messa = TEXT-m02 ).
*    WHEN gc_x.
*      gv_answer = zgtsd_cl_common=>popup_to_comfirm( iv_ucomm = space iv_messa = TEXT-m03 ).
*  ENDCASE.
*
*  CHECK gv_answer EQ zgtsd_j.
*
*  TRY.
*
*      CALL FUNCTION 'ZGTSD_IF_O_DELIVERYORDER_INFO'
*        DESTINATION lv_dest
*        EXPORTING
*          i_system_id           = gv_tar
*        IMPORTING
*          zo_result             = lv_result
*          zo_message            = lv_msg
*        TABLES
*          it_le_do_mst          = lt_header
*          it_le_do_dtl          = lt_item
*        EXCEPTIONS
*          system_failure        = 1 MESSAGE lv_msg
*          communication_failure = 2 MESSAGE lv_msg
*          illegalname           = 3
*          OTHERS                = 4.
*      IF sy-subrc NE 0.
*        lv_result = |01|.
*      ENDIF.
*
*    CATCH cx_root INTO DATA(lo_err).
*      MESSAGE s000 WITH lo_err->get_longtext( ) DISPLAY LIKE gc_e.EXIT.
*  ENDTRY.
*
*  LOOP AT gt_s0100 INTO gs_s0100 WHERE sel = gc_x.
*
*    CASE lv_result.
*      WHEN '00' OR '0'.
*        gs_s0100-statu = icon_led_green.
*        gs_s0100-msg = TEXT-m01.
*      WHEN OTHERS.
*        gs_s0100-statu = icon_led_red.
*        IF lv_msg IS INITIAL.
*          lv_result = '01'.
*          gs_s0100-msg = TEXT-e02.
*        ELSE.
*          gs_s0100-msg = lv_msg.
*        ENDIF.
*    ENDCASE.
*
***********************************************************************
**LOG
***********************************************************************
*    CLEAR lt_1007.
*    MOVE-CORRESPONDING gs_s0100 TO lt_1007.
*    GET TIME STAMP FIELD lt_1007-zifkey.
*
*    lt_1007-zsystem_id = gv_tar.
*    lt_1007-zstat      = lv_result.
*    lt_1007-zmessage   = gs_s0100-msg.
*    lt_1007-aedat      = gs_s0100-aedat_h.
*    lt_1007-aezet      = gs_s0100-aezet_h.
*    lt_1007-aenam      = gs_s0100-aenam_h.
*    lt_1007-erdat      = gs_s0100-erdat_h.
*    lt_1007-erzet      = gs_s0100-erzet_h.
*    gs_s0100-ifdat = lt_1007-ifdat = sy-datum.
*    gs_s0100-iftim = lt_1007-iftim = sy-uzeit.
*    gs_s0100-ifnam = lt_1007-ifnam = sy-uname.
*    APPEND lt_1007.
*
*    LOOP AT gt_item INTO ls_item USING KEY k_key WHERE vbeln = gs_s0100-vbeln .
*      MOVE-CORRESPONDING ls_item TO lt_1008.
*      lt_1008-zsystem_id = gv_tar.
*      lt_1008-zstat      = lv_result.
*      lt_1008-zmessage   = gs_s0100-msg.
*      lt_1008-ifdat      = lt_1007-ifdat.
*      lt_1008-iftim      = lt_1007-iftim.
*      lt_1008-ifnam      = lt_1007-ifnam.
*      APPEND lt_1008. CLEAR lt_1008.
*    ENDLOOP.
*
*    MODIFY gt_s0100 FROM gs_s0100.
*  ENDLOOP.
*
*  IF lt_1007[] IS NOT INITIAL.
*    MODIFY zgtsdt1007 FROM TABLE lt_1007.
*  ENDIF.
*
*  IF lt_1008[] IS NOT INITIAL.
*    MODIFY zgtsdt1008 FROM TABLE lt_1008.
*  ENDIF.
*
*  IF pv_type IS NOT INITIAL.
*    PERFORM data_query.
*  ENDIF.

  PERFORM refresh_table_display USING go_grid space.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_IF_BATCHJOB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM send_if_batchjob .
  DATA : lv_subrc  TYPE sy-subrc.
  DATA : lv_result TYPE zo_result,
         lv_dest   TYPE zifdest-dest,
         lv_msg    TYPE zo_message2,
         lv_erdat  LIKE sy-datum,
         lv_erzet  LIKE sy-uzeit,
         lv_stamp  TYPE timestampl,
         lt_1015   TYPE TABLE OF zgtsdt1015 WITH HEADER LINE,
         lt_1016   TYPE TABLE OF zgtsdt1016 WITH HEADER LINE,
         lt_head   TYPE TABLE OF zgtsdsif0016 WITH HEADER LINE,
         lt_item   TYPE TABLE OF zgtsdsif0017 WITH HEADER LINE.


  lv_erdat = sy-datum.
  lv_erzet = sy-uzeit.

  GET TIME STAMP FIELD lv_stamp.
*
  IF sy-batch = ' '.
    DATA(lt_rows) = zgtsd_cl_common=>get_selected_rows( EXPORTING
                                                          io_grid = go_grid
                                                          iv_ck   = zgtsd_x
                                                        IMPORTING
                                                          ev_subrc = lv_subrc ).
    CHECK lv_subrc IS INITIAL.
    CLEAR gs_s0100.
    MODIFY gt_s0100 FROM gs_s0100 TRANSPORTING sel WHERE sel IS NOT INITIAL.
  ENDIF.
  IF  sy-batch = 'X'.
    LOOP AT gt_head .
      __alpha_ou gt_head-tknum gt_head-tknum.
      MOVE-CORRESPONDING gt_head TO lt_head.
      MOVE-CORRESPONDING gt_head TO lt_1015.
      IF rb_disp = ' '.
        lt_1015-zifkey = lv_stamp.
      ENDIF.
      lt_1015-zsystem_id = gv_tar.
      lt_1015-ifdat = lv_erdat.
      lt_1015-iftim = lv_erzet.
      lt_1015-ifnam = sy-uname.
      APPEND lt_head. CLEAR : lt_head.
      APPEND lt_1015. .
    ENDLOOP.

    LOOP AT gt_item .
      __alpha_ou gt_item-tknum gt_item-tknum.
      __alpha_ou gt_item-vbeln gt_item-vbeln.
      __alpha_ou gt_item-posnr gt_item-posnr.
      __alpha_ou gt_item-kunnr gt_item-kunnr.

      MOVE-CORRESPONDING gt_item TO lt_item.
      MOVE-CORRESPONDING gt_item TO lt_1016.
      IF rb_disp = ' '.
        lt_1016-zifkey = lv_stamp.
      ENDIF.
      lt_1016-zsystem_id = gv_tar.
      lt_1016-ifdat = lv_erdat.
      lt_1016-iftim = lv_erzet.
      lt_1016-ifnam = sy-uname.
      APPEND lt_item. CLEAR : LT_item.
      APPEND lt_1016. CLEAR : lt_1016.
    ENDLOOP.
  ELSE.
    LOOP AT lt_rows INTO DATA(ls_row).
      READ TABLE gt_s0100 INTO gs_s0100 INDEX ls_row-index.
      CHECK sy-subrc = 0.

      LOOP AT gt_head WHERE TKNUM CS GS_S0100-TKNUM.
        __alpha_ou gt_head-tknum gt_head-tknum.
        MOVE-CORRESPONDING gt_head TO lt_head.
        MOVE-CORRESPONDING gt_head TO lt_1015.
        IF rb_disp = ' '.
          lt_1015-zifkey = lv_stamp.
        ENDIF.
        lt_1015-zsystem_id = gv_tar.
        lt_1015-ifdat = lv_erdat.
        lt_1015-iftim = lv_erzet.
        lt_1015-ifnam = sy-uname.
        APPEND lt_head. CLEAR : lt_head.
        APPEND lt_1015. .
      ENDLOOP.

      LOOP AT gt_item  WHERE TKNUM CS GS_S0100-TKNUM.
        __alpha_ou gt_item-tknum gt_item-tknum.
        __alpha_ou gt_item-vbeln gt_item-vbeln.
        __alpha_ou gt_item-posnr gt_item-posnr.
        __alpha_ou gt_item-kunnr gt_item-kunnr.

        MOVE-CORRESPONDING gt_item TO lt_item.
        MOVE-CORRESPONDING gt_item TO lt_1016.
        IF rb_disp = ' '.
          lt_1016-zifkey = lv_stamp.
        ENDIF.
        lt_1016-zsystem_id = gv_tar.
        lt_1016-ifdat = lv_erdat.
        lt_1016-iftim = lv_erzet.
        lt_1016-ifnam = sy-uname.
        APPEND lt_item. CLEAR : LT_item.
        APPEND lt_1016. CLEAR : lt_1016.
      ENDLOOP.

    ENDLOOP.
  ENDIF.


  IF lt_head[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE gc_e.EXIT.
  ENDIF.
*
  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      gubun                 = 'IS'
    IMPORTING
      dest_name             = lv_dest
    EXCEPTIONS
      destination_not_found = 1
      OTHERS                = 2.

  IF lv_dest IS  INITIAL.
    MESSAGE s000 WITH TEXT-e04 DISPLAY LIKE gc_e.EXIT.
  ENDIF.

  IF sy-batch = ' '.
    CLEAR gv_answer.
    gv_answer = zgtsd_cl_common=>popup_to_comfirm( iv_ucomm = space iv_messa = TEXT-m02 ).
    CHECK gv_answer EQ zgtsd_j.
  ENDIF.

  TRY.

      CALL FUNCTION 'ZGTSD_IF_O_TKNUM_INFO'
        DESTINATION lv_dest
        EXPORTING
          i_system_id           = gv_tar
        IMPORTING
          zo_result             = lv_result
          zo_message            = lv_msg
        TABLES
          ot_tab_h              = lt_head
          ot_tab_i              = lt_item
        EXCEPTIONS
          system_failure        = 1 MESSAGE lv_msg
          communication_failure = 2 MESSAGE lv_msg
          illegalname           = 3
          OTHERS                = 4.
      IF sy-subrc NE 0.
        lv_result = |01|.
      ENDIF.

    CATCH cx_root INTO DATA(lo_err).
      MESSAGE s000 WITH lo_err->get_longtext( ) DISPLAY LIKE gc_e.EXIT.
  ENDTRY.

  gv_result = lv_result.
  gv_message = lv_msg.
  lt_1015-zstat = lv_result.
  lt_1015-zmessage = lv_msg.
  lt_1016-zstat = lv_result.
  lt_1016-zmessage = lv_msg.
  MODIFY lt_1015 TRANSPORTING zstat zmessage
  WHERE zifkey = lv_stamp.
  MODIFY lt_1016 TRANSPORTING zstat zmessage
  WHERE zifkey = lv_stamp.

  LOOP AT gt_s0100 INTO gs_s0100 .
    gv_tknum = gs_s0100-tknum.

    CASE lv_result.
      WHEN '00' OR '0'.
        gs_s0100-statu = icon_led_green.
        gs_s0100-zmessage = TEXT-m01.
      WHEN OTHERS.
        gs_s0100-statu = icon_led_red.
        IF lv_msg IS INITIAL.
          lv_result = '01'.
          gs_s0100-zmessage = TEXT-e02.
        ELSE.
          gs_s0100-zmessage = lv_msg.
        ENDIF.
    ENDCASE.
    MODIFY gt_s0100 FROM gs_s0100.
  ENDLOOP.



  IF lt_1015[] IS NOT INITIAL.
    MODIFY zgtsdt1015 FROM TABLE lt_1015.
  ENDIF.

  IF lt_1016[] IS NOT INITIAL.
    MODIFY zgtsdt1016 FROM TABLE lt_1016.
  ENDIF.

  IF sy-batch = ' '.
    PERFORM refresh_table_display USING go_grid 'X'.
  ENDIF.
ENDFORM.
