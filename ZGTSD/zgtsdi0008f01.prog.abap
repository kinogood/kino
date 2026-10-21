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

*  s_erdat-low = sy-datlo.
*  s_erdat-high = sy-datlo.
*  __rng s_erdat 'I' 'EQ' s_erdat-low s_erdat-high.

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


**___ 전송 대상 찾기

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_dATA
    FROM zsdt_snop_010
    WHERE zzmonth EQ P_month.
*    AND cptype IN s_type
*    AND partner IN s_part
*    AND ( erdat IN s_erdat OR aedat IN s_erdat ).


**********************************************************************
  "데이타 건수 메시지 출력
  IF gt_DATA[] IS  INITIAL.
    MESSAGE s010.                                           "조회할 데이타가 없습니다.
    gv_error = gc_x.                                        "데이타 없으면 출력 X
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM send_data .

  DATA: lv_erdat   LIKE sy-datum,
        lv_erzet   LIKE sy-uzeit,
        lv_ernam   LIKE sy-uname,
        lv_dest    TYPE zifdest-dest,
        lv_result  TYPE zo_result,
        lv_msg     TYPE zo_message2,
        lv_tar     TYPE zgtetarget,
        lv_last    TYPE c,
        lv_zzmonth TYPE zsnopemonth,
        lv_stamp   TYPE timestampl.
**
*
  DATA : lt_LOG TYPE TABLE OF zgtsdt1027 WITH HEADER LINE.
**
**
  CLEAR : gt_result, gt_result[].

  CHECK gt_DATA[] IS NOT INITIAL.
*
  lv_tar = p_targ.
  lv_zzmonth = p_month.

  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      gubun                 = 'IS'
    IMPORTING
      dest_name             = lv_dest
    EXCEPTIONS
      destination_not_found = 1
      OTHERS                = 2.
*
*
*
*
**__ LOG 데이터 생성
*
  lv_erdat = sy-datum.
  lv_erzet = sy-uzeit.
  lv_ernam = sy-uname.
  GET TIME STAMP FIELD lv_stamp.

*
  lt_log[] = VALUE #( FOR ls_head IN gt_DATA
                 ( VALUE #( BASE CORRESPONDING #( ls_head )
                  zifkey = lv_stamp
                  ifdat = lv_erdat
                  iftim = lv_erzet
                  ifnam = lv_ernam  ) )
                  ).

  TRY.
      CALL FUNCTION 'ZGTSD_IF_O_SNOP_010_INFO'
        DESTINATION lv_dest
        EXPORTING
          i_system_id           = lv_tar
          i_zzmonth             = lv_zzmonth
        importing
          zo_result             = lv_result
          zo_message            = lv_msg
        TABLES
          ot_item               = gt_data
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
*
*
*
  "결과 조회를 위한 결과 저장
  lt_log-zresult = lv_result.
  lt_log-zmessage = lv_msg.
  lt_log-zsystem_id = p_targ.
  gv_result = lv_result.
  gv_message = lv_msg.

  MODIFY lt_log TRANSPORTING zresult zmessage zsystem_id
  WHERE zifkey = lv_stamp.

*
**
  IF lt_log[] IS NOT INITIAL.
    MODIFY zgtsdt1027 FROM TABLE lt_log.
    COMMIT WORK.
  ENDIF.


  "lv_result : 성공/실패 플래그(예: 'S'/'E' 또는 'X'/space)
  "lv_msg    : 인터페이스 메시지

  IF lv_msg IS NOT INITIAL AND sy-batch = ' '.
    IF lv_result = '00'.
      MESSAGE lv_msg TYPE 'S'.                 "성공 메시지
    ELSE.
      MESSAGE lv_msg TYPE 'S' DISPLAY LIKE 'E'."오류처럼 표시(팝업/비프)
      "또는 강제 중단이 필요하면
      "MESSAGE lv_msg TYPE 'E'.
    ENDIF.
  ENDIF.

*  WRITE : lv_stamp , lv_result,  lv_msg.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form WRITE_RESULT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM write_result .

  IF gt_DATA[] IS INITIAL.
    WRITE : 'NO_DATA'.
    EXIT.
  ENDIF.

  DATA: lv_lines   TYPE i,
        lv_lines_c TYPE char10.

  DESCRIBE TABLE gt_data LINES lv_lines.

  WRITE lv_lines TO lv_lines_c LEFT-JUSTIFIED.
  CONDENSE lv_lines_c NO-GAPS.

  IF gv_result = '00'.
    WRITE: / '처리결과:', gv_result,
           / '메시지  :', gv_message,
           / '건수    :', lv_lines_c.
  ELSE.
    WRITE: / '처리결과:', gv_result,
           / '오류메시지:', gv_message,
           / '건수      :', lv_lines_c.
  ENDIF.
*
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
*  PERFORM register_f4_fields.

  "SORT
*  PERFORM SET_ALV_SORT CHANGING GT_SORT.

  "Top-Of-Page Event 등록
*  PERFORM set_top_of_page_event.

  "ALV Grid Display
  PERFORM set_table_for_first_display USING go_grid.
*                                            gt_data.

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

*  "ICON
*  PERFORM reset_field_catalog TABLES gt_fcat USING:
*    'S' 'FIELDNAME'  'ICON',
*    ' ' 'COLTEXT'    '상태',
*    ' ' 'ICON'       'X',
*    ' ' 'OUTPUTLEN'  '4',
*    'E' 'KEY'        'X'.



  "기본키/마스터
  PERFORM reset_field_catalog TABLES gt_fcat USING:
    'S' 'FIELDNAME'  'ZZMONTH',
    ' ' 'COLTEXT'    '년월',
    ' ' 'OUTPUTLEN'  '6',
    'E' 'KEY'        'X'.

  PERFORM reset_field_catalog TABLES gt_fcat USING:
    'S' 'FIELDNAME'  'CPTYPE',
    ' ' 'COLTEXT'    '유형',
    ' ' 'OUTPUTLEN'  '2',
    'E' 'KEY'        'X'.

  PERFORM reset_field_catalog TABLES gt_fcat USING:
    'S' 'FIELDNAME'  'PARTNER',
    ' ' 'COLTEXT'    'BP',
    ' ' 'OUTPUTLEN'  '6',
    'E' 'KEY'        'X'.

  PERFORM reset_field_catalog TABLES gt_fcat USING:
    'S' 'FIELDNAME'  'MATNR',
    ' ' 'COLTEXT'    '자재',
    ' ' 'OUTPUTLEN'  '10',
    'E' 'KEY'        'X'.

  PERFORM reset_field_catalog TABLES gt_fcat USING:
    'S' 'FIELDNAME'  'MATNR_NM',
    ' ' 'COLTEXT'    '자재내역',
    ' ' 'OUTPUTLEN'  '25',
    'E' 'KEY'        ' '.

  PERFORM reset_field_catalog TABLES gt_fcat USING:
    'S' 'FIELDNAME'  'NAME1',
    ' ' 'COLTEXT'    '이름',
    ' ' 'OUTPUTLEN'  '20',
    'E' 'KEY'        ' '.

  PERFORM reset_field_catalog TABLES gt_fcat USING:
    'S' 'FIELDNAME'  'ZZBRAND',
    ' ' 'COLTEXT'    '브랜드',
    ' ' 'OUTPUTLEN'  '10',
    'E' 'KEY'        ' '.

  PERFORM reset_field_catalog TABLES gt_fcat USING:
    'S' 'FIELDNAME'  'ZZBRAND_NM',
    ' ' 'COLTEXT'    '브랜드명',
    ' ' 'OUTPUTLEN'  '10',
    'E' 'KEY'        ' '.

  PERFORM reset_field_catalog TABLES gt_fcat USING:
    'S' 'FIELDNAME'  'ZZGRADE',
    ' ' 'COLTEXT'    '등급',
    ' ' 'OUTPUTLEN'  '4',
    'E' 'KEY'        ' '.

  PERFORM reset_field_catalog TABLES gt_fcat USING:
    'S' 'FIELDNAME'  'ZZGRADE_NM',
    ' ' 'COLTEXT'    '등급명',
    ' ' 'OUTPUTLEN'  '10',
    'E' 'KEY'        ' '.


  "수량(Q01~Q31) : 단위필드 MEINS 연결 + 합계
  PERFORM set_qty_col TABLES gt_fcat USING 'Q01'  'Q01'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q02'  'Q02'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q03'  'Q03'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q04'  'Q04'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q05'  'Q05'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q06'  'Q06'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q07'  'Q07'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q08'  'Q08'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q09'  'Q09'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q10'  'Q10'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q11'  'Q11'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q12'  'Q12'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q13'  'Q13'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q14'  'Q14'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q15'  'Q15'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q16'  'Q16'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q17'  'Q17'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q18'  'Q18'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q19'  'Q19'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q20'  'Q20'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q21'  'Q21'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q22'  'Q22'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q23'  'Q23'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q24'  'Q24'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q25'  'Q25'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q26'  'Q26'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q27'  'Q27'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q28'  'Q28'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q29'  'Q29'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q30'  'Q30'.
  PERFORM set_qty_col TABLES gt_fcat USING 'Q31'  'Q31'.

  "단위필드
  PERFORM reset_field_catalog TABLES gt_fcat USING:
    'S' 'FIELDNAME'  'MEINS',
    ' ' 'COLTEXT'    '단위',
    ' ' 'OUTPUTLEN'  '3',
    'E' 'KEY'        ' '.
*  "ZRESULT
*  PERFORM reset_field_catalog TABLES gt_fcat USING:
*    'S' 'FIELDNAME'  'ZRESULT',
*    ' ' 'COLTEXT'    '결과',
*    ' ' 'OUTPUTLEN'  '2',
*    'E' 'KEY'        'X'.
*
*  "ZMESSAGE
*  PERFORM reset_field_catalog TABLES gt_fcat USING:
*    'S' 'FIELDNAME'  'ZMESSAGE',
*    ' ' 'COLTEXT'    '메시지',
*    ' ' 'OUTPUTLEN'  '20',
*    'E' 'KEY'        'X'.

ENDFORM.
FORM set_qty_col TABLES pt_fcat TYPE lvc_t_fcat
                 USING  p_fname
                        p_text.

  PERFORM reset_field_catalog TABLES pt_fcat USING:
    'S' 'FIELDNAME'   p_fname,
    ' ' 'COLTEXT'     p_text,
    ' ' 'QFIELDNAME'  'MEINS',
    ' ' 'JUST'        'R',
    ' ' 'DO_SUM'      'X',
    ' ' 'OUTPUTLEN'   '6',
    'E' 'KEY'         ' '.

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

*  SET HANDLER : lo_event->handle_hotspot_click         FOR po_sender,
*                lo_event->handle_dbl_click             FOR po_sender.
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
FORM set_table_for_first_display USING po_sender TYPE REF TO cl_gui_alv_grid.
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
      it_outtab            = gt_data[].

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
