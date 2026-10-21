*&---------------------------------------------------------------------*
*& Include          ZGTPPI3090F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form 2100_exclude_tb_functions
*&---------------------------------------------------------------------*
FORM 2100_exclude_tb_functions USING p_tabname.
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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form 2110_append_exclude_functions
*&---------------------------------------------------------------------*
FORM 2110_append_exclude_functions TABLES p_table
                                    USING p_value.

  DATA : lv_exclude TYPE ui_func.
  lv_exclude = p_value.
  APPEND lv_exclude TO p_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form 2200_fill_field_category
*&---------------------------------------------------------------------*
FORM 2200_fill_field_category .

  CLEAR   gt_fieldcat.

  IF p_r2 = 'X'. "처리 모드 : 로그 조회

    PERFORM 2210_fill_field_category USING :
          'S' 'FIELDNAME'   'ZIFKEY',
          ' ' 'COLTEXT'     TEXT-008, "인터페이스키
          ' ' 'FIX_COLUMN'  'X',
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '21'.

  ENDIF.

  PERFORM 2210_fill_field_category USING :
        'S' 'FIELDNAME'   'ICON',
        ' ' 'COLTEXT'     TEXT-009, "전송 상태
        ' ' 'FIX_COLUMN'  'X',
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '8',

        'S' 'FIELDNAME'   'ZMESSAGE',
        ' ' 'COLTEXT'     TEXT-010, "결과 메시지
        ' ' 'JUST'              'L',
        ' ' 'FIX_COLUMN'  'X',
        'E' 'OUTPUTLEN'   '11',

        'S' 'FIELDNAME'   'ZSYSTEM_ID',
        ' ' 'COLTEXT'     TEXT-011, "수신시스템
        ' ' 'JUST'              'C',
        ' ' 'FIX_COLUMN'  'X',
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'ZSYSTEM_ID_DESC',
        ' ' 'COLTEXT'     TEXT-012, "시스템 내역
        ' ' 'JUST'              'C',
        ' ' 'FIX_COLUMN'  'X',
        'E' 'OUTPUTLEN'   '11',

      'S' 'FIELDNAME'   'JOBLS',
      ' ' 'COLTEXT'     TEXT-013, "MES 요청번호
      ' ' 'JUST'              'C',
      ' ' 'FIX_COLUMN'  'X',
      'E' 'OUTPUTLEN'   '12',

     'S' 'FIELDNAME'   'JOB_NO',
     ' ' 'COLTEXT'     TEXT-014, "제조지시번호
     ' ' 'JUST'              'C',
     ' ' 'FIX_COLUMN'  'X',
     'E' 'OUTPUTLEN'   '12',

     'S' 'FIELDNAME'   'ZJOB_NAME',
     ' ' 'COLTEXT'     TEXT-015, "제조지시내역
     ' ' 'JUST'              'L',
     'E' 'OUTPUTLEN'   '24',

     'S' 'FIELDNAME'   'LINE_NO',
     ' ' 'COLTEXT'     TEXT-016, "라인번호
     ' ' 'JUST'              'C',
     'E' 'OUTPUTLEN'   '8',

     'S' 'FIELDNAME'   'SERIAL_INFO',
     ' ' 'COLTEXT'     TEXT-017, "시리얼정보
     ' ' 'JUST'              'C',
     'E' 'OUTPUTLEN'   '10',

     'S' 'FIELDNAME'   'PRCSS_SEQ',
     ' ' 'COLTEXT'     TEXT-018, "공정순번
     ' ' 'JUST'              'C',
     'E' 'OUTPUTLEN'   '8',

     'S' 'FIELDNAME'   'PRCSS_SUB_SEQ',
     ' ' 'COLTEXT'     TEXT-019, "SUB순번
     ' ' 'JUST'              'C',
     'E' 'OUTPUTLEN'   '7',

     'S' 'FIELDNAME'   'ZMODE',
     ' ' 'COLTEXT'     TEXT-020, "처리모드
     ' ' 'JUST'              'C',
     'E' 'OUTPUTLEN'   '8',

     'S' 'FIELDNAME'   'WERKS',
     ' ' 'COLTEXT'     TEXT-021, "플랜트
     ' ' 'JUST'              'C',
     'E' 'OUTPUTLEN'   '6',

     'S' 'FIELDNAME'   'OPER_CODE',
     ' ' 'COLTEXT'     TEXT-022, "공정코드
     ' ' 'JUST'              'C',
     'E' 'OUTPUTLEN'   '8',

     'S' 'FIELDNAME'   'OPER_NAME',
     ' ' 'COLTEXT'     TEXT-023, "공정명
     ' ' 'JUST'              'L',
     'E' 'OUTPUTLEN'   '20',

     'S' 'FIELDNAME'   'OPER_MATNR',
     ' ' 'COLTEXT'     TEXT-024, "생산품목코드
     ' ' 'JUST'              'C',
     'E' 'OUTPUTLEN'   '18',

     'S' 'FIELDNAME'   'MAKTX',
     ' ' 'COLTEXT'     TEXT-025, "생산품목내역
     ' ' 'JUST'              'L',
     'E' 'OUTPUTLEN'   '24',

     'S' 'FIELDNAME'   'MENGE',
     ' ' 'COLTEXT'     TEXT-026, "생산수량
     ' ' 'REF_TABLE'   'ZGTPPT3160',
     ' ' 'REF_FIELD'   'MENGE',
     ' ' 'JUST'              'R',
     'E' 'OUTPUTLEN'   '13',

     'S' 'FIELDNAME'   'MEINS',
     ' ' 'COLTEXT'     TEXT-027, "단위
     ' ' 'REF_TABLE'   'ZGTPPT3160',
     ' ' 'REF_FIELD'   'MEINS',
     ' ' 'JUST'              'C',
     'E' 'OUTPUTLEN'   '4'.

  IF p_r2 = 'X'. "로그 조회

    PERFORM 2210_fill_field_category USING :
         'S' 'FIELDNAME'   'BESKZ',
         ' ' 'COLTEXT'     TEXT-071, "외주 전환 처리
         ' ' 'JUST'              'C',
         'E' 'OUTPUTLEN'   '14'.

  ENDIF.

  PERFORM 2210_fill_field_category USING :
       'S' 'FIELDNAME'   'IDNLF',
       ' ' 'COLTEXT'     TEXT-028, "외주공정 자재그룹
       ' ' 'JUST'              'C',
       'E' 'OUTPUTLEN'   '17',

       'S' 'FIELDNAME'   'BSTMG',
       ' ' 'COLTEXT'     TEXT-029, "외주가공 수량
       ' ' 'REF_TABLE'   'ZGTPPT3160',
       ' ' 'REF_FIELD'   'BSTMG',
       ' ' 'JUST'              'R',
       'E' 'OUTPUTLEN'   '13',

       'S' 'FIELDNAME'   'BSTME',
       ' ' 'COLTEXT'     TEXT-030, "외주가공 단위
       ' ' 'REF_TABLE'   'ZGTPPT3160',
       ' ' 'REF_FIELD'   'BSTME',
       ' ' 'JUST'              'C',
       'E' 'OUTPUTLEN'   '4',

       'S' 'FIELDNAME'   'NETWR',
       ' ' 'COLTEXT'     TEXT-031, "외주가공 금액
       ' ' 'JUST'              'R',
       'E' 'OUTPUTLEN'   '13'.

  IF p_r2 = 'X'. "로그 조회

    PERFORM 2210_fill_field_category USING :
          'S' 'FIELDNAME'   'IFDAT',
          ' ' 'COLTEXT'     TEXT-032, "전송일자
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'IFTIM',
          ' ' 'COLTEXT'     TEXT-033, "전송시간
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'IFNAM',
          ' ' 'COLTEXT'     TEXT-034, "전송자
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '10'.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form 2210_fill_field_category
*&---------------------------------------------------------------------*
FORM 2210_fill_field_category USING p_gub p_fname p_con.

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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form 2300_change_display_attribute
*&---------------------------------------------------------------------*
FORM 2300_change_display_attribute CHANGING p_fcatlayo TYPE lvc_s_layo.
** General display options
  p_fcatlayo-zebra      = 'X'.
* Selection modes for SEL_MODE
* 'A' : Column and row selection
* 'B' : Simple selection, list box
* 'C' : Multiple selection, list box
* 'D' : Cell selection
  p_fcatlayo-sel_mode = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form 2500_grid_display_part
*&---------------------------------------------------------------------*
FORM 2500_grid_display_part .
*   화면에 Display함.
  IF p_r1 = 'X'. "처리 모드 : 전송

    CALL METHOD g_grid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_fcatlayo
        it_toolbar_excluding = gt_exclude
        i_save               = 'A'   " 전체가능유형
        is_variant           = gv_alv_variant
        " 선택 메뉴 display
      CHANGING
        it_outtab            = gt_header[]
        it_sort              = gt_sort
        it_fieldcatalog      = gt_fieldcat[].

  ELSEIF p_r2 = 'X'. "처리 모드 : 로그 조회

    CALL METHOD g_grid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_fcatlayo
        it_toolbar_excluding = gt_exclude
        i_save               = 'A'   " 전체가능유형
        is_variant           = gv_alv_variant
        " 선택 메뉴 display
      CHANGING
        it_outtab            = gt_header2[]
        it_sort              = gt_sort
        it_fieldcatalog      = gt_fieldcat[].

  ENDIF.

ENDFORM.
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

  IF p_r2 = 'X'. "처리 모드 : 로그 조회

    PERFORM 2210_fill_field_category USING :
          'S' 'FIELDNAME'   'ZIFKEY',
          ' ' 'COLTEXT'     TEXT-008, "인터페이스키
          ' ' 'FIX_COLUMN'  'X',
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '21'.

  ENDIF.

  PERFORM 2210_fill_field_category USING :
        'S' 'FIELDNAME'   'ZSYSTEM_ID',
        ' ' 'COLTEXT'     TEXT-011, "수신시스템
        ' ' 'JUST'              'C',
        ' ' 'FIX_COLUMN'  'X',
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'ZSYSTEM_ID_DESC',
        ' ' 'COLTEXT'     TEXT-012, "시스템 내역
        ' ' 'JUST'              'C',
        ' ' 'FIX_COLUMN'  'X',
        'E' 'OUTPUTLEN'   '11',

        'S' 'FIELDNAME'   'JOBLS',
        ' ' 'COLTEXT'     TEXT-013, "MES 요청번호
        ' ' 'JUST'              'C',
        ' ' 'FIX_COLUMN'  'X',
        'E' 'OUTPUTLEN'   '12',

        'S' 'FIELDNAME'   'WERKS',
        ' ' 'COLTEXT'     TEXT-021, "플랜트
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '6',

        'S' 'FIELDNAME'   'I_MODE',
        ' ' 'COLTEXT'     TEXT-020, "처리모드
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '8',

        'S' 'FIELDNAME'   'JOB_NO',
        ' ' 'COLTEXT'     TEXT-014, "제조지시번호
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '12',

        'S' 'FIELDNAME'   'ZJOB_NAME',
        ' ' 'COLTEXT'     TEXT-015, "제조지시내역
        ' ' 'JUST'              'L',
        'E' 'OUTPUTLEN'   '24',

        'S' 'FIELDNAME'   'LINE_NO',
        ' ' 'COLTEXT'     TEXT-016, "라인번호
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '8',

        'S' 'FIELDNAME'   'SERIAL_NO',
        ' ' 'COLTEXT'     TEXT-017, "시리얼정보
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'BSTYP',
        ' ' 'COLTEXT'     TEXT-037, "구매문서범주
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '12',

        'S' 'FIELDNAME'   'EKORG',
        ' ' 'COLTEXT'     TEXT-038, "구매조직
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '8',

        'S' 'FIELDNAME'   'EKGRP',
        ' ' 'COLTEXT'     TEXT-039, "구매그룹
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '8',

        'S' 'FIELDNAME'   'AFNAM',
        ' ' 'COLTEXT'     TEXT-040, "요청자 이름
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '11',

        'S' 'FIELDNAME'   'PSTYP',
        ' ' 'COLTEXT'     TEXT-041, "품목범주
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '8',

        'S' 'FIELDNAME'   'EINDT',
        ' ' 'COLTEXT'     TEXT-042, "납품일
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'MATKL',
        ' ' 'COLTEXT'     TEXT-043, "자재그룹
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '9',

        'S' 'FIELDNAME'   'MATNR',
        ' ' 'COLTEXT'     TEXT-044, "자재번호
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '18',

        'S' 'FIELDNAME'   'TXZ01',
        ' ' 'COLTEXT'     TEXT-045, "내역
        ' ' 'JUST'              'L',
        'E' 'OUTPUTLEN'   '24',

        'S' 'FIELDNAME'   'MENGE',
        ' ' 'COLTEXT'     TEXT-046, "구매요청수량
        ' ' 'REF_TABLE'   'ZGTMMT6210',
        ' ' 'REF_FIELD'   'MENGE',
        ' ' 'JUST'              'R',
        'E' 'OUTPUTLEN'   '13',

        'S' 'FIELDNAME'   'MEINS',
        ' ' 'COLTEXT'     TEXT-047, "구매요청단위
        ' ' 'REF_TABLE'   'ZGTMMT6210',
        ' ' 'REF_FIELD'   'MEINS',
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '4',

        'S' 'FIELDNAME'   'LGORT',
        ' ' 'COLTEXT'     TEXT-048, "저장위치
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '8',

        'S' 'FIELDNAME'   'EMLIF',
        ' ' 'COLTEXT'     TEXT-049, "공급업체
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'KUNNR',
        ' ' 'COLTEXT'     TEXT-072, "고객번호
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'KNTTP',
        ' ' 'COLTEXT'     TEXT-050, "계정지정범주
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '12',

        'S' 'FIELDNAME'   'ABLAD',
        ' ' 'COLTEXT'     TEXT-051, "하적지점
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '8',

        'S' 'FIELDNAME'   'SAKTO',
        ' ' 'COLTEXT'     TEXT-052, "G/L계정번호
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '11',

        'S' 'FIELDNAME'   'KOSTL',
        ' ' 'COLTEXT'     TEXT-053, "코스트센터
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'SOBKZ',
        ' ' 'COLTEXT'     TEXT-054, "특별 재고 지시자
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '16',

        'S' 'FIELDNAME'   'VBELN',
        ' ' 'COLTEXT'     TEXT-055, "판매 관리 문서 번호
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '19',

        'S' 'FIELDNAME'   'VBELP',
        ' ' 'COLTEXT'     TEXT-056, "판매 문서 항목
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '14',

        'S' 'FIELDNAME'   'FLIEF',
        ' ' 'COLTEXT'     TEXT-057, "고정 공급업체
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '13',

        'S' 'FIELDNAME'   'UMSON',
        ' ' 'COLTEXT'     TEXT-058, "무상 품목
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '9',

        'S' 'FIELDNAME'   'EXPRC',
        ' ' 'COLTEXT'     TEXT-059, "외주공정 단가사용
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '17',

        'S' 'FIELDNAME'   'IDNLF',
        ' ' 'COLTEXT'     TEXT-060, "외주공정 자재그룹
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '17',

        'S' 'FIELDNAME'   'BSTMG',
        ' ' 'COLTEXT'     TEXT-061, "외주가공 수량
        ' ' 'REF_TABLE'   'ZGTMMT6210',
        ' ' 'REF_FIELD'   'BSTMG',
        ' ' 'JUST'              'R',
        'E' 'OUTPUTLEN'   '13',

        'S' 'FIELDNAME'   'BSTME',
        ' ' 'COLTEXT'     TEXT-062, "외주가공 단위
        ' ' 'REF_TABLE'   'ZGTMMT6210',
        ' ' 'REF_FIELD'   'BSTME',
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '4',

        'S' 'FIELDNAME'   'WAERS',
        ' ' 'COLTEXT'     TEXT-063, "통화 키
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '7',

        'S' 'FIELDNAME'   'NETPR',
        ' ' 'COLTEXT'     TEXT-064, "외주가공 단가
        ' ' 'REF_TABLE'   'ZGTMMT6210',
        ' ' 'REF_FIELD'   'NETPR',
        ' ' 'JUST'              'R',
        'E' 'OUTPUTLEN'   '13',

        'S' 'FIELDNAME'   'PEINH',
        ' ' 'COLTEXT'     TEXT-065, "가격 단위
        ' ' 'REF_TABLE'   'ZGTMMT6210',
        ' ' 'REF_FIELD'   'PEINH',
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '4',

        'S' 'FIELDNAME'   'NETWR',
        ' ' 'COLTEXT'     TEXT-066, "외주가공 금액
        ' ' 'JUST'              'R',
        'E' 'OUTPUTLEN'   '13',

        'S' 'FIELDNAME'   'INFNR',
        ' ' 'COLTEXT'     TEXT-067, "외주가공 정보레코드
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '19'.

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
*& Form set_table_for_first_display1
*&---------------------------------------------------------------------*
FORM set_table_for_first_display1 .

  gs_variant-handle = '0001'.
  gs_variant-report = sy-repid.

  IF p_r1 = 'X'. "처리 모드 : 전송

    CALL METHOD gc_alv_grid1->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        is_layout            = gs_layout
        i_save               = 'A'
        it_toolbar_excluding = gt_exclude
      CHANGING
        it_fieldcatalog      = gt_fieldcat[]
        it_sort              = gt_sort[]
        it_outtab            = gt_jejo_c[].

  ELSE. "처리 모드 : 로그 조회

    CALL METHOD gc_alv_grid1->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        is_layout            = gs_layout
        i_save               = 'A'
        it_toolbar_excluding = gt_exclude
      CHANGING
        it_fieldcatalog      = gt_fieldcat[]
        it_sort              = gt_sort[]
        it_outtab            = gt_jejo_c2[].

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_grid_fcat2
*&---------------------------------------------------------------------*
FORM set_grid_fcat2 .

  CLEAR   : gv_pos.
  REFRESH : gt_fieldcat.

  CLEAR   gt_fieldcat.

  IF p_r2 = 'X'. "처리 모드 : 로그 조회

    PERFORM 2210_fill_field_category USING :
          'S' 'FIELDNAME'   'ZIFKEY',
          ' ' 'COLTEXT'     TEXT-008, "인터페이스키
          ' ' 'FIX_COLUMN'  'X',
          ' ' 'JUST'              'C',
          'E' 'OUTPUTLEN'   '21'.

  ENDIF.

  PERFORM 2210_fill_field_category USING :
        'S' 'FIELDNAME'   'ZSYSTEM_ID',
        ' ' 'COLTEXT'     TEXT-011, "수신시스템
        ' ' 'JUST'              'C',
        ' ' 'FIX_COLUMN'  'X',
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'ZSYSTEM_ID_DESC',
        ' ' 'COLTEXT'     TEXT-012, "시스템 내역
        ' ' 'JUST'              'C',
        ' ' 'FIX_COLUMN'  'X',
        'E' 'OUTPUTLEN'   '11',

        'S' 'FIELDNAME'   'JOBLS',
        ' ' 'COLTEXT'     TEXT-013, "MES 요청번호
        ' ' 'JUST'              'C',
        ' ' 'FIX_COLUMN'  'X',
        'E' 'OUTPUTLEN'   '12',

        'S' 'FIELDNAME'   'MES_CMP',
        ' ' 'COLTEXT'     TEXT-068, "MES 요청 구성품번호
        ' ' 'JUST'              'C',
        ' ' 'FIX_COLUMN'  'X',
        'E' 'OUTPUTLEN'   '19',

        'S' 'FIELDNAME'   'WERKS',
        ' ' 'COLTEXT'     TEXT-021, "플랜트
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '6',

        'S' 'FIELDNAME'   'I_MODE',
        ' ' 'COLTEXT'     TEXT-020, "처리모드
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '8',

        'S' 'FIELDNAME'   'JOB_NO',
        ' ' 'COLTEXT'     TEXT-014, "제조지시번호
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '12',

        'S' 'FIELDNAME'   'ZJOB_NAME',
        ' ' 'COLTEXT'     TEXT-015, "제조지시내역
        ' ' 'JUST'              'L',
        'E' 'OUTPUTLEN'   '24',

        'S' 'FIELDNAME'   'MATNR',
        ' ' 'COLTEXT'     TEXT-044, "자재번호
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '18',

        'S' 'FIELDNAME'   'MAKTX',
        ' ' 'COLTEXT'     TEXT-045, "내역
        ' ' 'JUST'              'L',
        'E' 'OUTPUTLEN'   '24',

        'S' 'FIELDNAME'   'BDMNG',
        ' ' 'COLTEXT'     TEXT-069, "소요량
        ' ' 'REF_TABLE'   'ZGTMMT6211',
        ' ' 'REF_FIELD'   'BDMNG',
        ' ' 'JUST'              'R',
        'E' 'OUTPUTLEN'   '13',

        'S' 'FIELDNAME'   'MEINS',
        ' ' 'COLTEXT'     TEXT-070, "기본 단위
        ' ' 'REF_TABLE'   'ZGTMMT6211',
        ' ' 'REF_FIELD'   'MEINS',
        ' ' 'JUST'              'C',
        'E' 'OUTPUTLEN'   '9'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_table_for_first_display2
*&---------------------------------------------------------------------*
FORM set_table_for_first_display2 .

  gs_variant-handle = '0001'.
  gs_variant-report = sy-repid.

  IF p_r1 = 'X'. "처리 모드 : 전송

    CALL METHOD gc_alv_grid2->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        is_layout            = gs_layout
        i_save               = 'A'
        it_toolbar_excluding = gt_exclude
      CHANGING
        it_fieldcatalog      = gt_fieldcat[]
        it_sort              = gt_sort[]
        it_outtab            = gt_jejo_i[].

  ELSE. "처리 모드 : 로그 조회

    CALL METHOD gc_alv_grid2->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        is_layout            = gs_layout
        i_save               = 'A'
        it_toolbar_excluding = gt_exclude
      CHANGING
        it_fieldcatalog      = gt_fieldcat[]
        it_sort              = gt_sort[]
        it_outtab            = gt_jejo_i2[].

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click
*&---------------------------------------------------------------------*
FORM double_click USING pv_row pv_column.

  CASE pv_column.
    WHEN OTHERS.

      PERFORM get_detail_data_double_click USING pv_row pv_column..

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_object_grid_0100
*&---------------------------------------------------------------------*
FORM set_object_grid_0100 .

  CREATE OBJECT go_docking_container
    EXPORTING
      repid                       = sy-repid
      dynnr                       = sy-dynnr
      extension                   = 10000
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5.
*화면 분할
  CREATE OBJECT go_splitter
    EXPORTING
      parent  = go_docking_container
      rows    = 1
      columns = 1.
* top 컨테이너
  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_contain_0100.
** bottom 컨테이너
*  CALL METHOD GO_SPLITTER->GET_CONTAINER
*    EXPORTING
*      ROW       = 2
*      COLUMN    = 1
*    RECEIVING
*      CONTAINER = GO_CONTAIN_0101.

  CREATE OBJECT go_grid_0100
    EXPORTING
      i_parent      = go_contain_0100
      i_appl_events = abap_true.

*  CREATE OBJECT go_grid_0101
*    EXPORTING
*      i_parent      = go_contain_0101
*      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0100
*&---------------------------------------------------------------------*
FORM set_layout_grid_0100 .

  CLEAR gs_layout_0100.
  gs_layout_0100-cwidth_opt = abap_true.
  gs_layout_0100-no_rowins = abap_true.
*  GS_LAYOUT_0100-NO_ROWMOVE = ABAP_TRUE.
  gs_layout_0100-smalltitle = abap_true.
  gs_layout_0100-sel_mode   = 'D'.
*  gs_layout_0100-stylefname = 'CELLTAB'.
*  gs_layout_0100-ctab_fname   = 'CELLCOL'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_grid_0100_display
*&---------------------------------------------------------------------*
FORM call_grid_0100_display .
*   화면에 Display함.
  IF p_r1 = 'X'. "처리 모드 : 전송

    CALL METHOD go_grid_0100->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_0100
        it_toolbar_excluding = gt_exclude
        i_save               = 'A'   " 전체가능유형
        is_variant           = gv_alv_variant
        " 선택 메뉴 display
      CHANGING
        it_outtab            = gt_header[]
        it_sort              = gt_sort
        it_fieldcatalog      = gt_fieldcat[].

  ELSEIF p_r2 = 'X'. "처리 모드 : 로그 조회

    CALL METHOD go_grid_0100->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_0100
        it_toolbar_excluding = gt_exclude
        i_save               = 'A'   " 전체가능유형
        is_variant           = gv_alv_variant
        " 선택 메뉴 display
      CHANGING
        it_outtab            = gt_header2[]
        it_sort              = gt_sort
        it_fieldcatalog      = gt_fieldcat[].

  ENDIF.

ENDFORM.
