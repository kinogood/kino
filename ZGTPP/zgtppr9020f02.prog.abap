*&---------------------------------------------------------------------*
*&  Include           ZPPR1000F02                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  exclude_of_toolbar_button
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0173   text
*----------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_BUTTON  USING  PV_TABNAME.
  DATA : LV_TAB_NAME             LIKE  FELD-NAME.
  FIELD-SYMBOLS : <TABLE>        TYPE  UI_FUNCTIONS.

  CONCATENATE PV_TABNAME '[]'    INTO  LV_TAB_NAME.
  ASSIGN     (LV_TAB_NAME)         TO <TABLE>.

*& 제거할 버튼 지정
  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON
   TABLES <TABLE>
   USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO, " 실행취소&LOCAL&UNDO
            CL_GUI_ALV_GRID=>MC_FC_AUF,      " 소계확장 &AUF
            CL_GUI_ALV_GRID=>MC_FC_AVERAGE,  " &AVERAGE
*            cl_gui_alv_grid=>mc_fc_back_classic,
*            cl_gui_alv_grid=>mc_fc_call_abc, " &ABC
*            cl_gui_alv_grid=>mc_fc_call_chain,
*            cl_gui_alv_grid=>mc_fc_call_crbatch,
*            cl_gui_alv_grid=>mc_fc_call_crweb,
*            cl_gui_alv_grid=>mc_fc_call_lineitems,
*            cl_gui_alv_grid=>mc_fc_call_master_data,
*            cl_gui_alv_grid=>mc_fc_call_more,
*            cl_gui_alv_grid=>mc_fc_call_report,
*            cl_gui_alv_grid=>mc_fc_call_xint,
*            cl_gui_alv_grid=>mc_fc_call_xxl,
*            cl_gui_alv_grid=>mc_fc_col_invisible,
*            cl_gui_alv_grid=>mc_fc_col_optimize,
*            cl_gui_alv_grid=>mc_fc_current_variant,
*            cl_gui_alv_grid=>mc_fc_data_save,
*            cl_gui_alv_grid=>mc_fc_delete_filter,
*            cl_gui_alv_grid=>mc_fc_deselect_all,
*            cl_gui_alv_grid=>mc_fc_detail,
*            cl_gui_alv_grid=>mc_fc_expcrdata,
*            cl_gui_alv_grid=>mc_fc_expcrdesig,
*            cl_gui_alv_grid=>mc_fc_expcrtempl,
*            cl_gui_alv_grid=>mc_fc_expmdb,
*            cl_gui_alv_grid=>mc_fc_extend,
*            cl_gui_alv_grid=>mc_fc_f4,
*            cl_gui_alv_grid=>mc_fc_filter,
*            cl_gui_alv_grid=>mc_fc_find,
*            cl_gui_alv_grid=>mc_fc_fix_columns,
            CL_GUI_ALV_GRID=>MC_FC_GRAPH,
*            cl_gui_alv_grid=>mc_fc_help,
*            cl_gui_alv_grid=>mc_fc_info,
*            cl_gui_alv_grid=>mc_fc_load_variant,
*            cl_gui_alv_grid=>mc_fc_loc_copy,          " 행 카피.
*            cl_gui_alv_grid=>mc_fc_html,
            CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,      " 열 카피.
            CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,           " 가위.
            CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,    " 행삭제.
            CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,    " 행삽입.
            CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW,
            CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,    " 라인생성.
            CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,         " 겹쳐쓰기.
            CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW. " 겹쳐쓰기.
*            cl_gui_alv_grid=>mc_fc_maintain_variant,
*            cl_gui_alv_grid=>mc_fc_maximum,
*            cl_gui_alv_grid=>mc_fc_minimum,
*            cl_gui_alv_grid=>mc_fc_pc_file,
*            cl_gui_alv_grid=>mc_fc_print,
*            cl_gui_alv_grid=>mc_fc_print_back,
*            cl_gui_alv_grid=>mc_fc_print_prev,
*            cl_gui_alv_grid=>mc_fc_refresh,
*            cl_gui_alv_grid=>mc_fc_reprep,
*            cl_gui_alv_grid=>mc_fc_save_variant,
*            cl_gui_alv_grid=>mc_fc_select_all,
*            cl_gui_alv_grid=>mc_fc_send,
*            cl_gui_alv_grid=>mc_fc_separator,
*            cl_gui_alv_grid=>mc_fc_sort,
*            cl_gui_alv_grid=>mc_fc_sort_asc,
*            cl_gui_alv_grid=>mc_fc_sort_dsc,
*            cl_gui_alv_grid=>mc_fc_subtot,
*            cl_gui_alv_grid=>mc_mb_sum,
*            cl_gui_alv_grid=>mc_fc_sum.
*            cl_gui_alv_grid=>mc_fc_to_office,
*            cl_gui_alv_grid=>mc_fc_to_rep_tree,
*            cl_gui_alv_grid=>mc_fc_unfix_columns,
*            cl_gui_alv_grid=>mc_fc_views,
*            cl_gui_alv_grid=>mc_fc_view_crystal,
*            cl_gui_alv_grid=>mc_fc_view_excel,
*            cl_gui_alv_grid=>mc_fc_view_grid,
*            cl_gui_alv_grid=>mc_fc_word_processo.

ENDFORM.                    " exclude_of_toolbar_button
*&---------------------------------------------------------------------*
*&      Form  add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<TABLE>  text
*      -->P_CL_GUI_ALV_GRID=>MC_FC_LOC_UND  text
*----------------------------------------------------------------------*
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   PT_TABLE
                                 USING    PV_VALUE.

  DATA: LV_EXCLUDE TYPE UI_FUNC.

  LV_EXCLUDE = PV_VALUE.
*& 결과적으로 GT_EXCLUDE에 제거할 버튼 저장
  APPEND LV_EXCLUDE TO PT_TABLE.

ENDFORM.                    " add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*&      Form  set_field_catalogs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_FIELD_CATALOGS .
  REFRESH GT_FIELDCAT.
  CLEAR GT_FIELDCAT.

  PERFORM   FILL_FIELD_CATALOGS
   TABLES   GT_FIELDCAT
    USING:

           'S' 'FIELDNAME'        'WERKS',
           ' ' 'COLTEXT'          '플랜트',
           ' ' 'JUST'             'C',
           ' ' 'KEY'              'X',
           ' ' 'NO_ZERO'          'X',
           'E' 'OUTPUTLEN'        '04',

           'S' 'FIELDNAME'        'LGORT',
           ' ' 'COLTEXT'          '저장위치(거래처코드)',
           ' ' 'JUST'             'C',
           ' ' 'KEY'              'X',
           'E' 'OUTPUTLEN'        '10',

           'S' 'FIELDNAME'        'NAME1',
           ' ' 'COLTEXT'          '저장위치(거래처코드)내역',
           ' ' 'JUST'             'L',
           ' ' 'KEY'              'X',
           'E' 'OUTPUTLEN'        '35',

           'S' 'FIELDNAME'        'MATNR',
           ' ' 'COLTEXT'          '자재코드',
           ' ' 'JUST'             'C',
*           ' ' 'KEY'              'X',
           'E' 'OUTPUTLEN'        '18',

           'S' 'FIELDNAME'        'MAKTX',
           ' ' 'COLTEXT'          '자재내역',
           ' ' 'JUST'             'L',
*           ' ' 'KEY'              'X',
           'E' 'OUTPUTLEN'        '40',

           'S' 'FIELDNAME'        'MTART',
           ' ' 'COLTEXT'          '자재유형',
           ' ' 'JUST'             'C',
*           ' ' 'KEY'              'X',
           'E' 'OUTPUTLEN'        '04',

           'S' 'FIELDNAME'        'CHARG',
           ' ' 'COLTEXT'          '배치번호',
           ' ' 'JUST'             'C',
*           ' ' 'KEY'              'X',
           'E' 'OUTPUTLEN'        '10',

           'S' 'FIELDNAME'        'PRCTR',
           ' ' 'COLTEXT'          '손익센터',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '10',

           'S' 'FIELDNAME'        'SEQUENCE',
           ' ' 'COLTEXT'          '순번',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '03',

           'S' 'FIELDNAME'        'MBLNR',
           ' ' 'COLTEXT'          '자재문서번호',
           ' ' 'JUST'             'C',
           ' ' 'NO_ZERO'          'X',
           'E' 'OUTPUTLEN'        '10',

           'S' 'FIELDNAME'        'STOCKT',
           ' ' 'COLTEXT'          '재고유형',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '01',

           'S' 'FIELDNAME'        'STTEXT',
           ' ' 'COLTEXT'          '재고유형내역',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '40',

           'S' 'FIELDNAME'        'STOCKMBE',
           ' ' 'COLTEXT'          '마감전 수량',
           ' ' 'JUST'             'R',
           ' ' 'NO_ZERO'          'X',
           ' ' 'DECIMALS_O'       '1',
           'E' 'OUTPUTLEN'        '13',

           'S' 'FIELDNAME'        'STOCKM',
           ' ' 'COLTEXT'          '마감후 수량',
           ' ' 'JUST'             'R',
           ' ' 'NO_ZERO'          'X',
           ' ' 'DECIMALS_O'       '1',
           'E' 'OUTPUTLEN'        '13',

           'S' 'FIELDNAME'        'STOPM',
           ' ' 'COLTEXT'          '체류일 수량',
           ' ' 'JUST'             'R',
           ' ' 'NO_ZERO'          'X',
           ' ' 'DECIMALS_O'       '1',
           'E' 'OUTPUTLEN'        '13',

           'S' 'FIELDNAME'        'MENGE',
           ' ' 'COLTEXT'          '자재문서 수량',
           ' ' 'JUST'             'R',
           ' ' 'NO_ZERO'          'X',
           ' ' 'DECIMALS_O'       '1',
           'E' 'OUTPUTLEN'        '13',

           'S' 'FIELDNAME'        'MEINS',
           ' ' 'COLTEXT'          '단위',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '03'.


  READ TABLE S_PWERK WITH KEY LOW = '3501'.    "동박일 경우

  IF SY-SUBRC EQ 0.

    PERFORM   FILL_FIELD_CATALOGS
     TABLES   GT_FIELDCAT
      USING:
           'S' 'FIELDNAME'        'STOCKMC',
           ' ' 'COLTEXT'          '마감후 수량(환산)',
           ' ' 'JUST'             'R',
           ' ' 'NO_ZERO'          'X',
           ' ' 'DECIMALS_O'       '1',
           'E' 'OUTPUTLEN'        '13',

           'S' 'FIELDNAME'        'STOPMC',
           ' ' 'COLTEXT'          '체류일 수량(환산)',
           ' ' 'JUST'             'R',
           ' ' 'NO_ZERO'          'X',
           ' ' 'DECIMALS_O'       '1',
           'E' 'OUTPUTLEN'        '13',

           'S' 'FIELDNAME'        'MEINSC',
           ' ' 'COLTEXT'          '단위',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '03'.
  ENDIF.

  PERFORM   FILL_FIELD_CATALOGS
   TABLES   GT_FIELDCAT
    USING:

         'S' 'FIELDNAME'        'BRANCHG',
         ' ' 'COLTEXT'          '분류',
         ' ' 'JUST'             'C',
         'E' 'OUTPUTLEN'        '01',

         'S' 'FIELDNAME'        'STOPDATE',
         ' ' 'COLTEXT'          '체류일',
         ' ' 'JUST'             'C',
         'E' 'OUTPUTLEN'        '05',

         'S' 'FIELDNAME'        'BUDAT',
         ' ' 'COLTEXT'          '전기일',
         ' ' 'JUST'             'C',
         ' ' 'NO_ZERO'          'X',
         'E' 'OUTPUTLEN'        '08',

         'S' 'FIELDNAME'        'MDATE',
         ' ' 'COLTEXT'          '생성일',
         ' ' 'JUST'             'C',
         'E' 'OUTPUTLEN'        '08',

         'S' 'FIELDNAME'        'STPRS',
         ' ' 'COLTEXT'          '단가',
         ' ' 'JUST'             'R',
         'E' 'OUTPUTLEN'        '11',

         'S' 'FIELDNAME'        'MONEY',
         ' ' 'COLTEXT'          '금액',
         ' ' 'JUST'             'R',
         'E' 'OUTPUTLEN'        '18',

         'S' 'FIELDNAME'        'STPRSAF',
         ' ' 'COLTEXT'          '결산 후 단가',
         ' ' 'JUST'             'R',
         'E' 'OUTPUTLEN'        '11',

         'S' 'FIELDNAME'        'MONEYAF',
         ' ' 'COLTEXT'          '결산 후 금액',
         ' ' 'JUST'             'R',
         'E' 'OUTPUTLEN'        '18',

         'S' 'FIELDNAME'        'MSHARE',
         ' ' 'COLTEXT'          '점유율(%)',
         ' ' 'JUST'             'C',
         'E' 'OUTPUTLEN'        '07',

         'S' 'FIELDNAME'        'BWART',
         ' ' 'COLTEXT'          '이동유형',
         ' ' 'JUST'             'C',
         'E' 'OUTPUTLEN'        '03',

         'S' 'FIELDNAME'        'BKLAS',
         ' ' 'COLTEXT'          '평가유형',
         ' ' 'JUST'             'C',
         'E' 'OUTPUTLEN'        '04',

          'S' 'FIELDNAME'        'BKBEZ',
         ' ' 'COLTEXT'          '평가유형내역',
         ' ' 'JUST'             'C',
         'E' 'OUTPUTLEN'        '25'.

*-{기능개선_182599 mrp관리자,동/알미늄 동량 추가
  IF S_PWERK-LOW+0(1) EQ '1'.   "LS전선일 경우에

    PERFORM   FILL_FIELD_CATALOGS
     TABLES   GT_FIELDCAT
      USING:

           'S' 'FIELDNAME'        'DISPO',
           ' ' 'COLTEXT'          'MRP관리자',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '10',

           'S' 'FIELDNAME'        'CF_CU',
           ' ' 'COLTEXT'          '환산계수(CU)',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '12',

           'S' 'FIELDNAME'        'C_CU',
           ' ' 'COLTEXT'          '동량(CU)',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '12',

            'S' 'FIELDNAME'       'CF_AL',
           ' ' 'COLTEXT'          '환산계수(AL)',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '12',

            'S' 'FIELDNAME'       'C_AL',
           ' ' 'COLTEXT'          '동량(AL)',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '12',
*}-기능개선_182599

*-{기능개선_205476_추가
           'S' 'FIELDNAME'        'MATNR_S',
           ' ' 'COLTEXT'          '생산 스크랩코드',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '18',

           'S' 'FIELDNAME'        'BRGEW',
           ' ' 'COLTEXT'          '환산계수(KG)',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '12',

           'S' 'FIELDNAME'        'STOCKMSC',
           ' ' 'COLTEXT'          '스크랩 환산중량(KG)',
           ' ' 'JUST'             'R',
           ' ' 'NO_ZERO'          'X',
           ' ' 'DECIMALS_O'       '1',
           'E' 'OUTPUTLEN'        '13',

           'S' 'FIELDNAME'        'STPRS_SC',
           ' ' 'COLTEXT'          '스크랩 단가',
           ' ' 'JUST'             'R',
           'E' 'OUTPUTLEN'        '11',
*-}기능개선_205476_2017.09.05
*20250613
           'S' 'FIELDNAME'        'MAT_KDAUF',
           ' ' 'COLTEXT'          '판매오더번호',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '10',

           'S' 'FIELDNAME'        'MAT_KDPOS',
           ' ' 'COLTEXT'          '판매오더품목',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '6'.
*20250613
  ENDIF.
ENDFORM.                    " set_field_catalogs
*&---------------------------------------------------------------------*
*&      Form  fill_field_catalogs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0309   text
*      -->P_0310   text
*      -->P_0311   text
*----------------------------------------------------------------------*
FORM FILL_FIELD_CATALOGS  TABLES PT_FIELDCAT TYPE LVC_T_FCAT
                          USING  PV_GUB
                                 PV_FNAME
                                 PV_VALUE.

*& 'S' -> Structure에 필드 속성 값 Setting을 Start 시점
*& 'E' -> Structure의 내용을 필드 카타로그 테이블에 저장 시점

  IF PV_GUB = 'S'.
    CLEAR GS_FIELDCAT.
  ENDIF.

*& 출력될 Field 속성을 정의해서 필드 카타로그 테이블에 저장
  DATA LV_FNAME(40).
  FIELD-SYMBOLS <FS> TYPE ANY.
  CONCATENATE 'GS_FIELDCAT-' PV_FNAME INTO LV_FNAME.

  ASSIGN (LV_FNAME) TO <FS>.
  <FS> = PV_VALUE.

  IF PV_GUB = 'E'.
    APPEND GS_FIELDCAT TO PT_FIELDCAT.
  ENDIF.

ENDFORM.                    " fill_field_catalogs
*&---------------------------------------------------------------------*
*&      Form  set_cell_attribute
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE .
*& 각 Cell의 특성 제어
  DATA : LT_STYL     TYPE LVC_T_STYL,
         LT_SCOL     TYPE LVC_T_SCOL,
         LV_INDEX    TYPE I,
         LF_ATNEW(1).

*  loop at gt_tab.
*    clear: lt_styl[], lt_scol[].
*
*    lv_index = sy-tabix.
*
*    perform control_style changing lt_styl.
*    perform control_color changing lt_scol.
*
*    clear: gt_tab-t_styl[], gt_tab-t_scol[].
*
*    insert lines of lt_styl   into table gt_tab-t_styl.
*    insert lines of lt_scol   into table gt_tab-t_scol.
*
*    modify gt_tab. " INDEX lv_index.
*    clear  gt_tab.
*
*  endloop.

ENDFORM.                    " set_cell_attribute
*&---------------------------------------------------------------------*
*&      Form  control_style
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--PT_STYL  text
*----------------------------------------------------------------------*
FORM CONTROL_STYLE CHANGING PT_STYL TYPE LVC_T_STYL.

  DATA : LS_STYL TYPE LVC_S_STYL,
         LV_MODE TYPE RAW4.
  DATA : LS_FIELDCAT   TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT  INTO LS_FIELDCAT.
    LS_STYL-FIELDNAME = LS_FIELDCAT-FIELDNAME.

    CASE LS_FIELDCAT-FIELDNAME.
      WHEN 'AUFNR' OR 'MATNR' OR 'KDAUF'.
        LS_STYL-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED +
                         CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        LS_STYL-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK.
        INSERT LS_STYL INTO TABLE PT_STYL.

      WHEN 'BUTTON' OR 'STOCK'.
        LS_STYL-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
        INSERT LS_STYL   INTO TABLE PT_STYL.

      WHEN  OTHERS.
        LS_STYL-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
        LS_STYL-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.
        INSERT LS_STYL   INTO TABLE PT_STYL.

    ENDCASE.

  ENDLOOP.

ENDFORM.                    " control_style
*&---------------------------------------------------------------------*
*&      Form  control_color
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--PT_SCOL  text
*----------------------------------------------------------------------*
FORM CONTROL_COLOR  CHANGING PT_SCOL TYPE LVC_T_SCOL.

  DATA : LS_STYL TYPE LVC_S_STYL,
         LS_SCOL TYPE LVC_S_SCOL,
         LV_MODE TYPE RAW4.

  DATA : LS_FIELDCAT TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT INTO LS_FIELDCAT.
    LS_SCOL-FNAME = LS_FIELDCAT-FIELDNAME.
    CASE LS_FIELDCAT-FIELDNAME.
      WHEN 'AUFNR' OR 'SEQNO'.
        LS_SCOL-COLOR-COL = 1.
        LS_SCOL-COLOR-INT = 1.

      WHEN  OTHERS.
        LS_SCOL-COLOR-COL = 4.
        LS_SCOL-COLOR-INT = 0.

    ENDCASE.

    INSERT LS_SCOL INTO TABLE PT_SCOL.
  ENDLOOP.

ENDFORM.                    " control_color
*&---------------------------------------------------------------------*
*&      Form  display_layout_attribute
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOCAT  text
*----------------------------------------------------------------------*
FORM DISPLAY_LAYOUT_ATTRIBUTE  USING  PS_LAYOCAT TYPE LVC_S_LAYO.

*& General display options...
  PS_LAYOCAT-CWIDTH_OPT = 'X'.
*&  ps_layocat-zebra      = 'X'.
  PS_LAYOCAT-SEL_MODE   = 'D'.
*&  ps_layocat-edit       = 'E'.
*&  ps_layocat-no_rowmark = 'X'.           "선택버튼 비활성
*  ps_layocat-stylefname = 'T_STYL'.      "셀스타일
*  ps_layocat-ctab_fname = 'T_SCOL'.      "셀색상
*&  ps_layocat-smalltitle = 'X'.           "작은타이틀.

ENDFORM.                    " display_layout_attribute
*&---------------------------------------------------------------------*
*&      Form  event_handler_register
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER .
*& Edit  이벤트 등록
* IF MC_EVT_MODIFY  -> 바로 수정됨.
  CALL METHOD GCL_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

*& Event Handler 등록
  CREATE OBJECT GCL_EVENT_HANDLER.

  SET HANDLER GCL_EVENT_HANDLER->HANDLE_TOOLBAR
          FOR GCL_GRID.
  SET HANDLER GCL_EVENT_HANDLER->HANDLE_USER_COMMAND
          FOR GCL_GRID.
  SET HANDLER GCL_EVENT_HANDLER->HANDLE_DATA_CHANGED
          FOR GCL_GRID.
  SET HANDLER GCL_EVENT_HANDLER->HANDLE_DATA_CHANGED_FINISHED
          FOR GCL_GRID.
  SET HANDLER GCL_EVENT_HANDLER->HANDLE_DOUBLE_CLICK
          FOR GCL_GRID.
  SET HANDLER GCL_EVENT_HANDLER->HANDLE_AFTER_USER_COMMAND
          FOR GCL_GRID.
  SET HANDLER GCL_EVENT_HANDLER->HANDLE_BUTTON_CLICK
          FOR GCL_GRID.
  SET HANDLER GCL_EVENT_HANDLER->HANDLE_ONF4
          FOR GCL_GRID.

  SET HANDLER GCL_EVENT_HANDLER->HANDLE_TOP_OF_PAGE
          FOR GCL_GRID.

ENDFORM.                    " event_handler_register
*&---------------------------------------------------------------------*
*&      Form  build_sort_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_SORT_FIELD .
*& Sort 필드 설정
*  gs_sort-fieldname = ''.
*  gs_sort-spos      = '1'.
*  gs_sort-up        = 'X'.
*  APPEND gs_sort   TO gt_sort.
*
*  gs_sort-fieldname = ''.
*  gs_sort-spos      = '2'.
*  gs_sort-up        = 'X'.
*  APPEND gs_sort TO gt_sort.

ENDFORM.                    " build_sort_field
*&---------------------------------------------------------------------*
*&      Form  alv_grid_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_GRID_DISPLAY .
  LCL_ALV_GRID=>F_ALV = '1'.

*& Display
  CALL METHOD GCL_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOCAT
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE
      I_SAVE               = 'A'   " 전체가능유형.
*                                       'U'   " 특정사용자전용.
*                                       'X'   " 광역 전용.
*                                       ' '   " 저장안함.
*     i_default            = 'X'   " 레이아웃 사전셋팅 허용.
*  LAYOUT   Standard   BCALV_GRID_09  참조.
*  is_variant 레이아웃선택/변경/저장/관리 enable
      IS_VARIANT           = ALV_VARIANT  " 선택 메뉴 display
    CHANGING
      IT_OUTTAB            = GT_TAB[]
      IT_SORT              = GT_SORT
      IT_FIELDCATALOG      = GT_FIELDCAT[].

  CALL METHOD GCL_GRID->SET_ROW_RESIZE.

ENDFORM.                    " alv_grid_display

*&---------------------------------------------------------------------*
*&      Form  toolbar_proc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_OBJECT  text
*      -->P_E_INTERACTIVE  text
*----------------------------------------------------------------------*
FORM TOOLBAR_PROC USING R_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                        R_INTERACTIVE.

  DATA : LS_TOOLBAR  TYPE STB_BUTTON.

  MOVE   3                  TO  LS_TOOLBAR-BUTN_TYPE.
  APPEND LS_TOOLBAR         TO  R_OBJECT->MT_TOOLBAR.

  CLEAR LS_TOOLBAR.
  MOVE 'REFRESH'            TO  LS_TOOLBAR-FUNCTION.
  MOVE  ICON_REFRESH        TO  LS_TOOLBAR-ICON.
  MOVE '최신표시'           TO  LS_TOOLBAR-QUICKINFO.
*&  MOVE '최신표시'           TO  ls_toolbar-text.
  MOVE ' '                  TO  LS_TOOLBAR-DISABLED.
  APPEND LS_TOOLBAR         TO  R_OBJECT->MT_TOOLBAR.

ENDFORM.                    " toolbar_proc
*&---------------------------------------------------------------------*
*&      Form  user_command_proc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM USER_COMMAND_PROC  USING R_UCOMM.

  CASE R_UCOMM.
    WHEN 'REFRESH'.
  ENDCASE.

ENDFORM.                    " user_command_proc
*&---------------------------------------------------------------------*
*&      Form  after_user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM AFTER_USER_COMMAND  USING    E_UCOMM.
  CASE E_UCOMM.
    WHEN 'REFRESH'.
      PERFORM REFRESH_GT_TAB_DISPLAY.
    WHEN  OTHERS.
  ENDCASE.
ENDFORM.                    " after_user_command
*&---------------------------------------------------------------------*
*&      Form  data_changed
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_data_changed  text
*      -->P_E_ONF4  text
*----------------------------------------------------------------------*
FORM DATA_CHANGED USING RR_DATA_CHANGED
                               TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                        E_ONF4 TYPE CHAR1.

ENDFORM.                    " data_changed
*&---------------------------------------------------------------------*
*&      Form  data_changed_finished
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_MODIFIED  text
*      -->P_ET_GOOD_CELLS  text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_FINISHED  USING    E_MODIFIED    TYPE CHAR01
                                     ET_GOOD_CELLS TYPE LVC_T_MODI.

  DATA: LS_MOD_CELLS TYPE LVC_S_MODI.
  DATA: LT_LIPS      LIKE GT_TAB OCCURS 0 WITH HEADER LINE.

  IF E_MODIFIED = 'X'.
    CLEAR: GV_TITLE.

    PERFORM SET_CELL_ATTRIBUTE.
    GV_TITLE = '생산오더 릴리즈(기타)'.

*&    CALL METHOD gcl_grid->set_gridtitle
*&      EXPORTING
*&        i_gridtitle = gv_title.

    GS_SCROLL-ROW = 'X'.
    GS_SCROLL-COL = 'X'.

    CALL METHOD GCL_GRID->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = 'X'
        IS_STABLE      = GS_SCROLL.     "현재 그대로 입력한 refresh

    CALL METHOD GCL_GRID->SET_OPTIMIZE_ALL_COLS.

  ENDIF.

ENDFORM.                    " data_changed_finished
*&---------------------------------------------------------------------*
*&      Form  hotspot_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
FORM HOTSPOT_CLICK  USING P_ROW_ID P_COLUMN_ID.

ENDFORM.                    " hotspot_click
*&---------------------------------------------------------------------*
*&      Form  double_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW  text
*      -->P_E_COLUMN  text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING    E_ROW
                            E_COLUMN.


ENDFORM.                    " double_click
*&---------------------------------------------------------------------*
*&      Form  button_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ES_COL_ID  text
*      -->P_ES_ROW_NO  text
*----------------------------------------------------------------------*
FORM BUTTON_CLICK  USING    PS_COL_ID  TYPE  LVC_S_COL
                            PS_ROW_NO  TYPE  LVC_S_ROID.

ENDFORM.                    " button_click
*&---------------------------------------------------------------------*
*&      Form  onf4_proc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_FIELDNAME  text
*      -->P_E_FIELDVALUE  text
*      -->P_ES_ROW_NO  text
*      -->P_ER_EVENT_DATA  text
*      -->P_ET_BAD_CELLS  text
*      -->P_E_DISPLAY  text
*----------------------------------------------------------------------*
FORM ONF4_PROC  USING   PV_FIELDNAME  TYPE LVC_FNAME
                        PV_FIELDVALUE TYPE LVC_VALUE
                        PS_ROW_NO     TYPE LVC_S_ROID
                        PR_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                        PT_BAD_CELLS  TYPE LVC_T_MODI
                        PV_DISPLAY    TYPE CHAR01.

  FIELD-SYMBOLS <MODI>                TYPE LVC_T_MODI.
  DATA: LS_MODI  TYPE LVC_S_MODI,
        LV_VALUE TYPE STRING.

ENDFORM.                                                    " onf4_proc
*&---------------------------------------------------------------------*
*&      Form  data_input_error
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RR_DATA_CHANGED  text
*      -->P_LS_MOD_CELLS  text
*      -->P_1462   text
*      -->P_1463   text
*      -->P_LS_MOD_CELLS_FIELDNAME  text
*----------------------------------------------------------------------*
FORM DATA_INPUT_ERROR USING RR_DATA_CHANGED TYPE REF TO
                                         CL_ALV_CHANGED_DATA_PROTOCOL
                            PS_MOD_CELLS    TYPE LVC_S_MODI
                            PV_MSGTY
                            PV_MSGV1
                            PV_FIELDNAME.
* Error Message Display
  CALL METHOD RR_DATA_CHANGED->ADD_PROTOCOL_ENTRY
    EXPORTING
      I_MSGID     = '0K'
      I_MSGNO     = '000'
      I_MSGTY     = PV_MSGTY
      I_MSGV1     = PV_MSGV1
      I_MSGV2     = ''
      I_MSGV3     = ''
      I_FIELDNAME = PV_FIELDNAME
      I_ROW_ID    = PS_MOD_CELLS-ROW_ID.

ENDFORM.                    " data_input_error
*&---------------------------------------------------------------------*
*&      Form  refresh_grid_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFRESH_GRID_DISPLAY .
  CLEAR: GV_TITLE.

  PERFORM SET_CELL_ATTRIBUTE.

  GV_TITLE = '생산오더 릴리즈(UTP)'.

*&  CALL METHOD gcl_grid->set_gridtitle
*&    EXPORTING
*&      i_gridtitle = gv_title.

  GS_SCROLL-ROW = 'X'.
  GS_SCROLL-COL = 'X'.

  CALL METHOD GCL_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = GS_SCROLL.     "현재 그대로 입력한 refresh

  CALL METHOD GCL_GRID->SET_OPTIMIZE_ALL_COLS.

ENDFORM.                    " refresh_grid_display
*&---------------------------------------------------------------------*
*&      Form  event_button_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PS_COL_ID  text
*      -->P_PS_ROW_NO  text
*----------------------------------------------------------------------*
FORM EVENT_BUTTON_CLICK  USING    PS_COL_ID  TYPE  LVC_S_COL
                                  PS_ROW_NO  TYPE  LVC_S_ROID.


ENDFORM.                    " event_button_click
*&---------------------------------------------------------------------*
*&      Form  set_drdn_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_DRDN_TABLE .

ENDFORM.                    " set_drdn_table
