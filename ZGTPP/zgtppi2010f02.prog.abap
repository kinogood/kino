*&---------------------------------------------------------------------*
*& Include          ZGTPPI2010F02
*&---------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*&      Form  2100_exclude_tb_functions
*&--------------------------------------------------------------------*
FORM 2100_exclude_tb_functions  USING p_tabname.
*  툴바의 버튼중 나타내지 않을 버튼을 지정한다.
  FIELD-SYMBOLS : <table> TYPE ui_functions.

  DATA : lv_exclude   TYPE ui_func.
  DATA : lv_table_name LIKE feld-name.

  CONCATENATE p_tabname '[]' INTO  lv_table_name.
  ASSIGN     (lv_table_name)    TO <table>.

  PERFORM 2110_append_exclude_functions
        TABLES <table>
*        USING : cl_gui_alv_grid=>mc_fc_excl_all. " ** 툴바 모두제거 **
         USING :
                cl_gui_alv_grid=>mc_fc_loc_undo, " 실행취소
                cl_gui_alv_grid=>mc_fc_auf,      " 소계확장 &AUF
                cl_gui_alv_grid=>mc_fc_average,  " &AVERAGE
                cl_gui_alv_grid=>mc_fc_call_abc, " &ABC
                cl_gui_alv_grid=>mc_fc_loc_copy,          " 행 카피.
                cl_gui_alv_grid=>mc_fc_loc_copy_row,      " 행 카피.
                cl_gui_alv_grid=>mc_fc_loc_cut,           " 가위.
                cl_gui_alv_grid=>mc_fc_loc_delete_row,    " 행삭제.
                cl_gui_alv_grid=>mc_fc_loc_insert_row,    " 행삽입.
                cl_gui_alv_grid=>mc_fc_loc_append_row,    " 라인생성.
                cl_gui_alv_grid=>mc_fc_loc_paste,         " 겹쳐쓰기.
                cl_gui_alv_grid=>mc_fc_loc_paste_new_row. " 겹쳐쓰기.

ENDFORM.                    " 2100_exclude_tb_functions
*&---------------------------------------------------------------------*
*&      Form  2110_append_exclude_functions
*&---------------------------------------------------------------------*
FORM 2110_append_exclude_functions  TABLES p_table
                                    USING p_value.
  DATA : lv_exclude TYPE ui_func.
  lv_exclude = p_value.
  APPEND lv_exclude TO p_table.

ENDFORM.                    " 2110_append_exclude_functions
*&--------------------------------------------------------------------*
*&      Form  2200_fill_field_category
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM 2200_fill_field_category.

  CLEAR   gt_fieldcat.

  IF p_r2 = 'X'. "로그 조회

    PERFORM 2210_fill_field_category USING :
          'S' 'FIELDNAME'   'ZIFKEY',
          ' ' 'COLTEXT'     TEXT-011, "인터페이스키
          ' ' 'FIX_COLUMN'  'X',
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '21'.

  ENDIF.

  PERFORM 2210_fill_field_category USING :
          'S' 'FIELDNAME'   'ICON',
          ' ' 'COLTEXT'     TEXT-012, "전송 상태
          ' ' 'FIX_COLUMN'  'X',
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'ZMESSAGE',
          ' ' 'COLTEXT'     TEXT-013, "결과 메시지
          ' ' 'JUST'              'L',
          ' ' 'FIX_COLUMN'  'X',
          'E' 'OUTPUTLEN'   '11',

           'S' 'FIELDNAME'   'ZSYSTEM_ID',
          ' ' 'COLTEXT'     TEXT-014, "수신시스템
          ' ' 'JUST'              'C',
          ' ' 'FIX_COLUMN'  'X',
          'E' 'OUTPUTLEN'   '10',

           'S' 'FIELDNAME'   'ZSYSTEM_ID_DESC',
          ' ' 'COLTEXT'     TEXT-015, "시스템 내역
          ' ' 'JUST'              'C',
          ' ' 'FIX_COLUMN'  'X',
          'E' 'OUTPUTLEN'   '11',

          'S' 'FIELDNAME'   'WERKS',
          ' ' 'COLTEXT'     TEXT-016, "플랜트
          ' ' 'JUST'              'C',
          ' ' 'FIX_COLUMN'  'X',
          'E' 'OUTPUTLEN'   '6',

          'S' 'FIELDNAME'   'AUFNR',
          ' ' 'COLTEXT'     TEXT-017, "생산오더번호
          ' ' 'JUST'              'C',
          ' ' 'FIX_COLUMN'  'X',
          'E' 'OUTPUTLEN'   '12',

          'S' 'FIELDNAME'   'AUART',
          ' ' 'COLTEXT'     TEXT-018, "생산오더유형
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '12',

          'S' 'FIELDNAME'   'STATUS',
          ' ' 'COLTEXT'     TEXT-019, "오더 상태
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'DISPO',
          ' ' 'COLTEXT'     TEXT-020, "MRP 관리자
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'FEVOR',
          ' ' 'COLTEXT'     TEXT-021, "생산 감독자
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '11',

          'S' 'FIELDNAME'   'GAMNG',
          ' ' 'COLTEXT'     TEXT-022, "생산오더수량
          ' ' 'REF_TABLE'   'AFKO',
          ' ' 'REF_FIELD'   'GAMNG',
          ' ' 'JUST'              'R',
          'E' 'OUTPUTLEN'   '12',

          'S' 'FIELDNAME'   'GASMG',
          ' ' 'COLTEXT'     TEXT-023, "오더불량수량
          ' ' 'REF_TABLE'   'AFKO',
          ' ' 'REF_FIELD'   'GASMG',
          ' ' 'JUST'              'R',
          'E' 'OUTPUTLEN'   '12',

          'S' 'FIELDNAME'   'GMEIN',
          ' ' 'COLTEXT'     TEXT-024, "오더단위
          ' ' 'REF_TABLE'   'AFKO',
          ' ' 'REF_FIELD'   'GMEIN',
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'SBMNG',
          ' ' 'COLTEXT'     TEXT-025, "기준수량
          ' ' 'REF_TABLE'   'AFPO',
          ' ' 'REF_FIELD'   'SBMNG',
          ' ' 'JUST'              'R',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'SBMEH',
          ' ' 'COLTEXT'     TEXT-026, "기본단위
          ' ' 'REF_TABLE'   'AFKO',
          ' ' 'REF_FIELD'   'SBMEH',
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'GSTRP',
          ' ' 'COLTEXT'     TEXT-027, "기본시작일
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'GLTRP',
          ' ' 'COLTEXT'     TEXT-028, "기본종료일
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'GSTRS',
          ' ' 'COLTEXT'     TEXT-029, "일정계획시작일
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '14',

          'S' 'FIELDNAME'   'GSUZS',
          ' ' 'COLTEXT'     TEXT-030, "일정계획시작시간
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '16',

          'S' 'FIELDNAME'   'GLTRS',
          ' ' 'COLTEXT'     TEXT-031, "일정계획종료일
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '14',

          'S' 'FIELDNAME'   'GLUZS',
          ' ' 'COLTEXT'     TEXT-032, "일정계획종료시간
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '16',

          'S' 'FIELDNAME'   'KDAUF',
          ' ' 'COLTEXT'     TEXT-033, "판매오더
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'KDPOS',
          ' ' 'COLTEXT'     TEXT-034, "판매오더아이템
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '14',

          'S' 'FIELDNAME'   'LOEKZ',
          ' ' 'COLTEXT'     TEXT-035, "삭제지시자
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'ZZPRIORITY',
          ' ' 'COLTEXT'     TEXT-036, "작업 우선순위
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '13',

          'S' 'FIELDNAME'   'ZZORIGIN',
          ' ' 'COLTEXT'     TEXT-037, "기존 생산오더
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '13',

          'S' 'FIELDNAME'   'ZZFOLLOWING',
          ' ' 'COLTEXT'     TEXT-038, "후속 생산오더
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '13',

*// Modified by ZGODEV06 on 2026-01-21 {
          'S' 'FIELDNAME'   'zzbundle',
          ' ' 'COLTEXT'     TEXT-f01, "묶음 생산오더.
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '12',
          'S' 'FIELDNAME'   'ZZPOSNR',
          ' ' 'COLTEXT'     TEXT-f02, "묶음 생산오더 항번.
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '10',
          'S' 'FIELDNAME'   'ZZKDAUF',
          ' ' 'COLTEXT'     TEXT-f03, "판매오더번호(MTS).
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '10',
          'S' 'FIELDNAME'   'ZZKDPOS',
          ' ' 'COLTEXT'     TEXT-f04, "판매오더품목(MTS).
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '10',
          'S' 'FIELDNAME'   'ZZYUSCD',
          ' ' 'COLTEXT'     TEXT-f05, "영업소.
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '6',
          'S' 'FIELDNAME'   'ZTEXT',
          ' ' 'COLTEXT'     TEXT-f06, "특기사항.
          'E' 'OUTPUTLEN'   '50'.
*// }

  IF p_r2 = 'X'. "로그 조회

    PERFORM 2210_fill_field_category USING :
          'S' 'FIELDNAME'   'IFDAT',
          ' ' 'COLTEXT'     TEXT-039, "전송일자
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'IFTIM',
          ' ' 'COLTEXT'     TEXT-040, "전송시간
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'IFNAM',
          ' ' 'COLTEXT'     TEXT-041, "전송자
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '10'.

  ENDIF.

ENDFORM.                    "2200_fill_field_category
*&---------------------------------------------------------------------*
*&      Form  2210_fill_field_category
*&---------------------------------------------------------------------*
FORM 2210_fill_field_category  USING p_gub p_fname p_con.

  IF p_gub = 'S'.
    CLEAR gs_fcat.
  ENDIF.
* 속성 MOVE
  DATA ls_col(40).
  FIELD-SYMBOLS <fs>.
  CONCATENATE 'GS_FCAT-' p_fname  INTO ls_col.
  ASSIGN      (ls_col)         TO       <fs>.
  MOVE         p_con           TO       <fs>.

  IF p_gub = 'E'.
    APPEND gs_fcat TO gt_fieldcat.
  ENDIF.

ENDFORM.                    " 2210_fill_field_category
*&---------------------------------------------------------------------*
*&      Form  2300_change_display_attribute
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GS_FCATLAYO  text
*----------------------------------------------------------------------*
FORM 2300_change_display_attribute  CHANGING p_fcatlayo TYPE lvc_s_layo.
** General display options
  p_fcatlayo-zebra      = 'X'.
* Selection modes for SEL_MODE
* 'A' : Column and row selection
* 'B' : Simple selection, list box
* 'C' : Multiple selection, list box
* 'D' : Cell selection
  p_fcatlayo-sel_mode = 'D'.

ENDFORM.                    " 2300_change_display_attribute
*&---------------------------------------------------------------------*
*&      Form  2500_grid_display_part
*&---------------------------------------------------------------------*
FORM 2500_grid_display_part .

  IF p_r1 = 'X'. "전송
*   화면에 Display함.
    CALL METHOD g_grid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_fcatlayo
        it_toolbar_excluding = gt_exclude
        i_save               = 'A'   " 전체가능유형
        is_variant           = gv_alv_variant
        " 선택 메뉴 display
      CHANGING
        it_outtab            = gt_disp_head[]
        it_sort              = gt_sort
        it_fieldcatalog      = gt_fieldcat[].

  ELSE.
*   화면에 Display함.
    CALL METHOD g_grid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_fcatlayo
        it_toolbar_excluding = gt_exclude
        i_save               = 'A'   " 전체가능유형
        is_variant           = gv_alv_variant
        " 선택 메뉴 display
      CHANGING
        it_outtab            = gt_disp_head2[]
        it_sort              = gt_sort
        it_fieldcatalog      = gt_fieldcat[].

  ENDIF.

ENDFORM.                    " 2500_grid_display_part
*&---------------------------------------------------------------------*
*& Form set_grid_layo1
*&---------------------------------------------------------------------*
FORM set_grid_layo1 .

  CLEAR : gs_layout.

  gs_layout-smalltitle = 'X'.
  gs_layout-sel_mode   = 'A'.              "select multiple lines
*  gs_layout-cwidth_opt = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_grid_fcat1
*&---------------------------------------------------------------------*
FORM set_grid_fcat1 .

  CLEAR   : gv_pos.
  REFRESH : gt_fieldcat.

  CLEAR   gt_fieldcat.

  IF p_r2 = 'X'. "로그 조회

    PERFORM 2210_fill_field_category USING :
          'S' 'FIELDNAME'   'ZIFKEY',
          ' ' 'COLTEXT'     TEXT-011, "인터페이스키
          ' ' 'FIX_COLUMN'  'X',
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '21'.

  ENDIF.

  PERFORM 2210_fill_field_category USING :
          'S' 'FIELDNAME'   'AUFNR',
          ' ' 'COLTEXT'     TEXT-017, "생산오더번호
          ' ' 'JUST'              'C',
          ' ' 'FIX_COLUMN'  'X',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'POSNR',
          ' ' 'COLTEXT'     TEXT-042, "오더품목번호
          ' ' 'JUST'              'C',
          ' ' 'FIX_COLUMN'  'X',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'MATNR',
          ' ' 'COLTEXT'     TEXT-043, "품목코드
          ' ' 'JUST'              'C',
          ' ' 'FIX_COLUMN'  'X',
          'E' 'OUTPUTLEN'   '12',

          'S' 'FIELDNAME'   'MAKTX',
          ' ' 'COLTEXT'     TEXT-043, "품목코드 내역
          ' ' 'JUST'              'L',
          'E' 'OUTPUTLEN'   '30',

          'S' 'FIELDNAME'   'ELIKZ',
          ' ' 'COLTEXT'     TEXT-044, "납품완료 지시자
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '12',

          'S' 'FIELDNAME'   'UEBTO',
          ' ' 'COLTEXT'     TEXT-045, "초과납품(%)
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '11',

          'S' 'FIELDNAME'   'UEBTK',
          ' ' 'COLTEXT'     TEXT-046, "무제한 초과 납품
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '12',

          'S' 'FIELDNAME'   'LGORT',
          ' ' 'COLTEXT'     TEXT-047, "생산품 입고저장위치
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '14',

          'S' 'FIELDNAME'   'MWERT11',
          ' ' 'COLTEXT'     TEXT-048, "기본 조장 길이
          ' ' 'JUST'              'R',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'MWERT12',
          ' ' 'COLTEXT'     TEXT-049, "조장 Additional
          ' ' 'JUST'              'R',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'PSAMG',
          ' ' 'COLTEXT'     TEXT-050, "검사여장
          ' ' 'JUST'              'R',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'PSMNG',
          ' ' 'COLTEXT'     TEXT-051, "품목 지시조장
          ' ' 'JUST'              'R',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'MWERT21',
          ' ' 'COLTEXT'     TEXT-052, "추가 여장
          ' ' 'JUST'              'R',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'MWERT22',
          ' ' 'COLTEXT'     TEXT-053, "입고 보빈 수
          ' ' 'JUST'              'R',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'GRPNR',
          ' ' 'COLTEXT'     TEXT-054, "조장 구성표 번호
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '12',

          'S' 'FIELDNAME'   'CHARG',
          ' ' 'COLTEXT'     TEXT-055, "배치번호
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'VERID',
          ' ' 'COLTEXT'     TEXT-056, "생산버전
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '8',

*// Modified by ZGODEV06 on 2026-01-21 {
          'S' 'FIELDNAME'   'KDAUF',
          ' ' 'COLTEXT'     TEXT-f11, "판매오더.
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '10',
          'S' 'FIELDNAME'   'KDPOS',
          ' ' 'COLTEXT'     TEXT-f12, "판매오더 품목번호.
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '10',
          'S' 'FIELDNAME'   'ZZBUNDLE',
          ' ' 'COLTEXT'     TEXT-f01, "묶음오더번호.
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '12',
          'S' 'FIELDNAME'   'ZZPOSNR',
          ' ' 'COLTEXT'     TEXT-f02, "묶음오더 품목번호.
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '10',
          'S' 'FIELDNAME'   'ZCAGE',
          ' ' 'COLTEXT'     TEXT-f13, "신선 - Cage.
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '10',
          'S' 'FIELDNAME'   'ZWSEQ',
          ' ' 'COLTEXT'     TEXT-f14, "신선 - 차수.
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '8',
          'S' 'FIELDNAME'   'INSMK',
          ' ' 'COLTEXT'     TEXT-f15, "재고 유형.
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '6',
          'S' 'FIELDNAME'   'ZSPECNO',
          ' ' 'COLTEXT'     TEXT-f16, "SPEC 번호.
          'E' 'OUTPUTLEN'   '20',
          'S' 'FIELDNAME'   'YCOEF',
          ' ' 'COLTEXT'     TEXT-f17, "연입률.
          'E' 'OUTPUTLEN'   '8'.
*// }
*// Modified by ZGSIDEV07 on 2026-07-08 {
*  CASE abap_true.
*    WHEN p_r10 OR p_r11.
      PERFORM 2210_fill_field_category USING :
              'S' 'FIELDNAME'   'MATNR_DM',
              ' ' 'COLTEXT'     TEXT-f18, "드럼 자재코드
              'E' 'OUTPUTLEN'   '18'.
*  ENDCASE.
*// }

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_tb_functions
*&---------------------------------------------------------------------*
FORM exclude_tb_functions CHANGING pt_exclude TYPE ui_functions.

  DATA : ls_exclude TYPE ui_func.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND ls_exclude TO pt_exclude.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_TABLE_FOR_FIRST_DISPLAY1
*&---------------------------------------------------------------------*
FORM set_table_for_first_display1 .

  gs_variant-handle = '0001'.
  gs_variant-report = sy-repid.

  IF p_r1 = 'X'. "전송

    CALL METHOD gc_alv_grid1->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        is_layout            = gs_layout
        i_save               = 'A'
        it_toolbar_excluding = gt_exclude
      CHANGING
        it_fieldcatalog      = gt_fieldcat[]
        it_sort              = gt_sort[]
        it_outtab            = gt_disp_item[].

  ELSE.

    CALL METHOD gc_alv_grid1->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        is_layout            = gs_layout
        i_save               = 'A'
        it_toolbar_excluding = gt_exclude
      CHANGING
        it_fieldcatalog      = gt_fieldcat[]
        it_sort              = gt_sort[]
        it_outtab            = gt_disp_item2[].

  ENDIF.

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY1
*&---------------------------------------------------------------------*
*& Form set_grid_fcat2
*&---------------------------------------------------------------------*
FORM set_grid_fcat2 .

  CLEAR   : gv_pos.
  REFRESH : gt_fieldcat.

  CLEAR   gt_fieldcat.

  IF p_r2 = 'X'. "로그 조회

    PERFORM 2210_fill_field_category USING :
          'S' 'FIELDNAME'   'ZIFKEY',
          ' ' 'COLTEXT'     TEXT-011, "인터페이스키
          ' ' 'FIX_COLUMN'  'X',
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '21'.

  ENDIF.

  PERFORM 2210_fill_field_category USING :
          'S' 'FIELDNAME'   'AUFNR',
          ' ' 'COLTEXT'     TEXT-017, "생산오더번호
          ' ' 'JUST'              'C',
          ' ' 'FIX_COLUMN'  'X',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'VORNR',
          ' ' 'COLTEXT'     TEXT-057, "작업/액티비티 번호
          ' ' 'JUST'              'C',
          ' ' 'FIX_COLUMN'  'X',
          'E' 'OUTPUTLEN'   '14',

          'S' 'FIELDNAME'   'PLNAL',
          ' ' 'COLTEXT'     TEXT-058, "그룹카운터
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'PLNFL',
          ' ' 'COLTEXT'     TEXT-059, "작업순서
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'LTXA1',
          ' ' 'COLTEXT'     TEXT-060, "작업내역
          ' ' 'JUST'              'L',
          'E' 'OUTPUTLEN'   '18',

          'S' 'FIELDNAME'   'ARBPL',
          ' ' 'COLTEXT'     TEXT-061, "작업장
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '6',

          'S' 'FIELDNAME'   'KTEXT',
          ' ' 'COLTEXT'     TEXT-062, "작업장 내역
          ' ' 'JUST'              'L',
          'E' 'OUTPUTLEN'   '18',

          'S' 'FIELDNAME'   'KTSCH',
          ' ' 'COLTEXT'     TEXT-063, "표준텍스트키
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'STEUS',
          ' ' 'COLTEXT'     TEXT-064, "제어키
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '6',

          'S' 'FIELDNAME'   'SSAVD',
          ' ' 'COLTEXT'     TEXT-065, "최근 계획 시작: 실행(일자)
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'SSAVZ',
          ' ' 'COLTEXT'     TEXT-066, "최근 계획 시작: 실행(시간)
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'SSEDD',
          ' ' 'COLTEXT'     TEXT-067, "최근 계획 종료: 실행(일자)
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'SSEDZ',
          ' ' 'COLTEXT'     TEXT-068, "최근 계획 종료: 실행(시간)
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '20'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_table_for_first_display2
*&---------------------------------------------------------------------*
FORM set_table_for_first_display2 .

  gs_variant-handle = '0001'.
  gs_variant-report = sy-repid.

  IF p_r1 = 'X'. "전송

    CALL METHOD gc_alv_grid2->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        is_layout            = gs_layout
        i_save               = 'A'
        it_toolbar_excluding = gt_exclude
      CHANGING
        it_fieldcatalog      = gt_fieldcat[]
        it_sort              = gt_sort[]
        it_outtab            = gt_disp_rout[].

  ELSE.

    CALL METHOD gc_alv_grid2->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        is_layout            = gs_layout
        i_save               = 'A'
        it_toolbar_excluding = gt_exclude
      CHANGING
        it_fieldcatalog      = gt_fieldcat[]
        it_sort              = gt_sort[]
        it_outtab            = gt_disp_rout2[].

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_grid_fcat3
*&---------------------------------------------------------------------*
FORM set_grid_fcat3 .

  CLEAR   : gv_pos.
  REFRESH : gt_fieldcat.

  CLEAR   gt_fieldcat.
  IF p_r2 = 'X'. "로그 조회

    PERFORM 2210_fill_field_category USING :
          'S' 'FIELDNAME'   'ZIFKEY',
          ' ' 'COLTEXT'     TEXT-011, "인터페이스키
          ' ' 'FIX_COLUMN'  'X',
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '21'.

  ENDIF.

  PERFORM 2210_fill_field_category USING :
          'S' 'FIELDNAME'   'AUFNR',
          ' ' 'COLTEXT'     TEXT-017, "생산오더번호
          ' ' 'JUST'              'C',
          ' ' 'FIX_COLUMN'  'X',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'RSNUM',
          ' ' 'COLTEXT'     TEXT-069, "예약번호
          ' ' 'JUST'              'C',
          ' ' 'FIX_COLUMN'  'X',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'RSPOS',
          ' ' 'COLTEXT'     TEXT-070, "예약아이템번호
          ' ' 'JUST'              'C',
          ' ' 'FIX_COLUMN'  'X',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'MATNR',
          ' ' 'COLTEXT'     TEXT-071, "구성부품
          ' ' 'JUST'              'C',
          ' ' 'FIX_COLUMN'  'X',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'MAKTX',
          ' ' 'COLTEXT'     TEXT-072, "구성부품 내역
          ' ' 'JUST'              'L',
          'E' 'OUTPUTLEN'   '30',

          'S' 'FIELDNAME'   'ERFMG',
          ' ' 'COLTEXT'     TEXT-073, "구성부품수량
          ' ' 'JUST'              'R',
          ' ' 'QFIELDNAME'   'ERFME',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'ERFME',
          ' ' 'COLTEXT'     TEXT-074, "구성부품단위
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'LGORT',
          ' ' 'COLTEXT'     TEXT-075, "출고위치
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'CHARG',
          ' ' 'COLTEXT'     TEXT-076, "배치번호
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'XLOEK',
          ' ' 'COLTEXT'     TEXT-077, "삭제 지시자
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'RGEKZ',
          ' ' 'COLTEXT'     TEXT-078, "백플러쉬 지시자
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '10'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_table_for_first_display3
*&---------------------------------------------------------------------*
FORM set_table_for_first_display3 .

  gs_variant-handle = '0001'.
  gs_variant-report = sy-repid.

  IF p_r1 = 'X'. "전송

    CALL METHOD gc_alv_grid3->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        is_layout            = gs_layout
        i_save               = 'A'
        it_toolbar_excluding = gt_exclude
      CHANGING
        it_fieldcatalog      = gt_fieldcat[]
        it_sort              = gt_sort[]
        it_outtab            = gt_disp_bom[].

  ELSE.

    CALL METHOD gc_alv_grid3->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        is_layout            = gs_layout
        i_save               = 'A'
        it_toolbar_excluding = gt_exclude
      CHANGING
        it_fieldcatalog      = gt_fieldcat[]
        it_sort              = gt_sort[]
        it_outtab            = gt_disp_bom2[].

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_grid_fcat4
*&---------------------------------------------------------------------*
FORM set_grid_fcat4 .

  CLEAR   : gv_pos.
  REFRESH : gt_fieldcat.

  CLEAR   gt_fieldcat.

  IF p_r2 = 'X'. "로그 조회

    PERFORM 2210_fill_field_category USING :
          'S' 'FIELDNAME'   'ZIFKEY',
          ' ' 'COLTEXT'     TEXT-011, "인터페이스키
          ' ' 'FIX_COLUMN'  'X',
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '21'.

  ENDIF.

  PERFORM 2210_fill_field_category USING :
          'S' 'FIELDNAME'   'AUFNR',
          ' ' 'COLTEXT'     TEXT-017, "생산오더번호
          ' ' 'JUST'              'C',
          ' ' 'FIX_COLUMN'  'X',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'ATNAM',
          ' ' 'COLTEXT'     TEXT-079, "특성
          ' ' 'JUST'              'C',
          ' ' 'FIX_COLUMN'  'X',
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'ATBEZ',
          ' ' 'COLTEXT'     TEXT-080, "특성내역
          ' ' 'JUST'              'L',
          'E' 'OUTPUTLEN'   '24',

          'S' 'FIELDNAME'   'ATWRT',
          ' ' 'COLTEXT'     TEXT-081, "특성값
          ' ' 'JUST'              'C',
          ' ' 'FIX_COLUMN'  'X',
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'ATWTB',
          ' ' 'COLTEXT'     TEXT-082, "특성값내역
          ' ' 'JUST'              'L',
          'E' 'OUTPUTLEN'   '24'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_table_for_first_display4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_table_for_first_display4 .

  gs_variant-handle = '0001'.
  gs_variant-report = sy-repid.

  IF p_r1 = 'X'. "전송

    CALL METHOD gc_alv_grid4->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        is_layout            = gs_layout
        i_save               = 'A'
        it_toolbar_excluding = gt_exclude
      CHANGING
        it_fieldcatalog      = gt_fieldcat[]
        it_sort              = gt_sort[]
        it_outtab            = gt_disp_char[].

  ELSE.

    CALL METHOD gc_alv_grid4->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        is_layout            = gs_layout
        i_save               = 'A'
        it_toolbar_excluding = gt_exclude
      CHANGING
        it_fieldcatalog      = gt_fieldcat[]
        it_sort              = gt_sort[]
        it_outtab            = gt_disp_char2[].

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click
*&---------------------------------------------------------------------*
FORM double_click USING pv_row pv_column.

  CASE pv_column.
    WHEN 'AUFNR'.

      IF p_r1 = 'X'.
        READ TABLE gt_disp_head INTO gs_disp_head INDEX pv_row.
        SET PARAMETER ID 'ANR' FIELD gs_disp_head-aufnr.
      ELSE.
        READ TABLE gt_disp_head2 INTO gs_disp_head2 INDEX pv_row.
        SET PARAMETER ID 'ANR' FIELD gs_disp_head2-aufnr.
      ENDIF.

      CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

    WHEN OTHERS.

      PERFORM get_detail_data_double_click USING pv_row pv_column..

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_so_date_time
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> S_UDATE
*&      --> S_UTIME
*&---------------------------------------------------------------------*
*** START 2026.07.01 bt ZGISPP03
FORM get_so_date_time  TABLES   p_udate STRUCTURE lr_datum
                                                     p_utime STRUCTURE  lr_uzeit .

  DATA : lv_uzeit   LIKE sy-uzeit,
         lv_predate LIKE sy-datum,
         lv_pretime LIKE sy-uzeit.

  lv_uzeit = sy-uzeit.

  IF lv_uzeit < '000600'.

    CALL FUNCTION 'IGN_TIMESTAMP_PLUSMINUS'
      EXPORTING
        start_date      = sy-datum
        start_time      = lv_uzeit
        forward         = ' '
        backward        = 'X'
        days            = '0'
        hours           = '0'
        minutes         = '6'
        seconds         = '0'
      IMPORTING
        result_date     = lv_predate
        result_time     = lv_pretime
      EXCEPTIONS
        parameter_error = 1
        OTHERS          = 2.

    p_udate-sign   = 'I'.
    p_udate-option = 'EQ'.
    p_udate-low    = lv_predate.
    APPEND p_udate.

    p_utime-sign   = 'I'.
    p_utime-option = 'BT'.
    p_utime-low    = lv_pretime.
    p_utime-high   = '235959'.
    APPEND p_utime.

    p_udate-sign   = 'I'.
    p_udate-option = 'EQ'.
    p_udate-low    = sy-datum.
    APPEND p_udate.

    p_utime-sign   = 'I'.
    p_utime-option = 'BT'.
    p_utime-low    = '000000'.
    p_utime-high   = lv_uzeit.
    APPEND p_utime.

  ELSE.
    p_udate-sign   = 'I'.
    p_udate-option = 'EQ'.
    p_udate-low    = sy-datum.
    APPEND p_udate.

    p_utime-sign   = 'I'.
    p_utime-option = 'BT'.
    p_utime-low    = lv_uzeit - 360.
    p_utime-high   = lv_uzeit.
    APPEND p_utime.
  ENDIF.

ENDFORM.
*** END 2026.07.01 bt ZGISPP03
