*&---------------------------------------------------------------------*
*&  Include           ZNFR2510F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  CREATE_OBJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_object .

* Create Object : GRF_CONTAINER
  CREATE OBJECT grf_container
    EXPORTING
      container_name = grf_container_name.

* Create Object : GRF_GRID
  CREATE OBJECT grf_grid
    EXPORTING
      i_parent      = grf_container
      i_appl_events = 'X'.

ENDFORM.                    " CREATE_OBJECT


*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_EXCLUDE  text
*----------------------------------------------------------------------*
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

ENDFORM.                    " EXCLUDE_TB_FUNCTIONS

*&---------------------------------------------------------------------*
*&      Form  SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_grid_layout .

  CLEAR gs_layout.
  gs_layout-sel_mode   = 'A'.
  gs_layout-zebra      = 'X'.
  gs_layout-cwidth_opt = 'X'.
  gs_layout-stylefname = 'CELLTAB'.
  gs_layout-no_rowins  = 'X'.

ENDFORM.                    " SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_grid_sort .

  CLEAR : gs_sort. REFRESH gt_sort.

  gs_sort-spos = 1.
  gs_sort-fieldname = 'NFUTN'.
  gs_sort-up = 'X'.
  gs_sort-comp = 'X'.
  gs_sort-subtot = 'X'.
  APPEND gs_sort TO gt_sort.

ENDFORM.                    " SET_GRID_SORT

*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_grid_fieldcatalog .

  CLEAR gt_fieldcat.   REFRESH gt_fieldcat.

  PERFORM set_fieldcat USING:
  'CHECK'       '선택'             '10'     'C'    ' '     ,
  'NFUTN'       '선물집행번호'     '12'     'L'    ' '     ,
  'NFKEY'       '비철구분'         '10'     'C'    ' '     ,
  'AUDAT'       '승인요청일'       '10'     'C'    ' '     ,
  'RUDAT'       '집행일'           '10'     'C'    ' '     ,
  'FCM'         'FCM'              '5'      'C'    'ALPHA' ,
  'FCM_NM'      'FCM'              '10'     'L'    ' '     ,
  'BY_SL'       'Buy/Sell'         '10'     'C'    ' '     ,
  'BY_SL_NM'    'Buy/Sell'         '10'     'C'    ' '     ,
  'ENDAT'       '만기일'           '10'     'C'    ' '     ,
  'MITYP'       '집행유형'         '10'     'C'    ' '     ,
  'MISPD'       'Spread'           '10'     'R'    ' '     ,
  'MIMON'       '기준월'           '10'     'C'    ' '     ,
  'PRICE'       '집행단가'         '15'     'R'    ' '     ,
  'WAERS'       '통화'             '5'      'C'    ' '     ,
  'EMENG'       '집행수량'         '14'     'R'    ' '     ,
  'MEINS'       '단위'             '10'     'C'    ' '     ,
  'CONNO'       '계약번호'         '10'     'C'    ' '     ,
  'COTXT'       '계약명'           '20'     'L'    ' '     ,
  'PRCTR'       '손익센터'         '10'     'C'    'ALPHA'     ,
  'PTEXT'       '손익센터명'       '10'     'C'    'ALPHA'     ,
  'SUJUD'       '수주일'           '10'     'C'    ' '     ,
  'CPRICE'      '수주금액'         '10'     'R'    ' '     ,
  'CWAERS'      '통화'             '10'     'C'    ' '     ,
  'PRATE'       '영업이익률(%)'    '10'     'R'    ' '     ,
  'ERATE'       '환율'             '10'     'R'    ' '     ,
  'SALER'       '영업담당자'       '10'     'C'    ' '     ,
  'PRIND'       '가격구분'         '10'     'C'    ' '     ,
  'SUJUP'       '비철수주가'       '10'     'R'    ' '     ,
  'BIGO4'       '비고'             '20'     'L'    ' '     ,
  'FILE_YN'     '첨부파일여부'     '10'     'C'    ' '     ,
  'REQNO'       '선물요청번호'     '10'     'C'    ' '     ,
  'H_NO1'       '항번'             '10'     'C'    ' '     ,
  'ENDMM'       '요청만기월'       '10'     'C'    ' '     ,
  'REMENG'      '요청수량'         '10'     'R'    ' '     ,
  'RMEINS'      '단위'             '10'     'C'    ' '     ,
  'ERDAT'       '요청일'           '10'     'C'    ' '     ,
  'ERZET'       '요청시간'         '6'      'C'    ' '     ,
  'ERNAM'       '요청자'           '10'     'C'    ' '     ,
  'ENAME'       '요청자명'         '10'     'C'    ' '     .

ENDFORM.                    " SET_GRID_FIELDCATALOG

*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT
*&---------------------------------------------------------------------*
FORM set_fieldcat  USING  p_fieldname
                          p_coltext
                          p_outputlen
                          p_just
                          p_convexit.

  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname  = p_fieldname .
  gs_fieldcat-coltext    = p_coltext   .
  gs_fieldcat-outputlen  = p_outputlen .
  gs_fieldcat-just       = p_just      .
  gs_fieldcat-convexit   = p_convexit  .

  CASE p_fieldname.
    WHEN 'CHECK'.
      gs_fieldcat-checkbox   = 'X'.
      gs_fieldcat-edit       = 'X'.
    WHEN 'BY_SL'.
      gs_fieldcat-no_out     = 'X'.
    WHEN 'PRICE'.
      gs_fieldcat-cfieldname = 'WAERS'.
    WHEN 'EMENG'.
      gs_fieldcat-qfieldname = 'MEINS'.
  ENDCASE.

  APPEND gs_fieldcat TO gt_fieldcat.

ENDFORM.                    " SET_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  SET_CELL_ATTRIBUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_cell_attribute .

* 각 셀의 특성 제어
  DATA : lt_celltab TYPE lvc_t_styl,
         l_index    TYPE i.

  LOOP AT gt_outtab_d INTO gs_outtab_d.
    l_index = sy-tabix.
    REFRESH lt_celltab.
    CLEAR gs_outtab_d-celltab.
    PERFORM fill_celltab_c CHANGING lt_celltab.
    INSERT LINES OF lt_celltab INTO TABLE gs_outtab_d-celltab.
    MODIFY gt_outtab_d FROM gs_outtab_d INDEX l_index.
  ENDLOOP.

ENDFORM.                    " SET_CELL_ATTRIBUTE

*&---------------------------------------------------------------------*
*&      Form  SET_EVENT_HANDLER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_event_handler .

  CALL METHOD grf_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CREATE OBJECT grf_event_receiver.
  SET HANDLER :
    grf_event_receiver->handle_data_changed FOR grf_grid,
    grf_event_receiver->handle_double_click FOR grf_grid.

ENDFORM.                    " SET_EVENT_HANDLER


*&---------------------------------------------------------------------*
*&      Form  SET_F4_HELP_REGISTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_f4_help_register .

  CLEAR   : gs_f4.
  REFRESH : gt_f4.

*  FieldName별 소트해서 APPEND
*  GS_F4-FIELDNAME = 'NFUTN'.
*  GS_F4-REGISTER  = 'X'.
*  APPEND GS_F4 TO GT_F4.
*
*  CALL METHOD GRF_GRID->REGISTER_F4_FOR_FIELDS
*    EXPORTING
*      IT_F4 = GT_F4.

ENDFORM.                    " SET_F4_HELP_REGISTER


*&---------------------------------------------------------------------*
*&      Form  SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_table_for_first_display .

  gs_variant-handle = '0001'.
  gs_variant-report = sy-repid.

  CALL METHOD grf_grid->set_table_for_first_display
    EXPORTING
      is_variant                    = gs_variant
      is_layout                     = gs_layout
      i_save                        = 'A'
      i_default                     = 'X'
      it_toolbar_excluding          = gt_exclude
    CHANGING
      it_fieldcatalog               = gt_fieldcat[]
      it_sort                       = gt_sort[]
      it_outtab                     = gt_outtab_d
      it_filter                     = gt_filter
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  CALL METHOD grf_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  GET_REQ_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_req_list .

*   =========================================
*   REQ_TYPE 코드값(Hotsopt용 구분값)
*   =========================================
*   'A' = 선물요청승인
*   'B' = 만기이동요청승인
*   'C' = 만기이동집행승인
*   'D' = 신규선물집행승인
*   'E' = 청산선물집행승인
*   'F' = 신규/청산선물집행수정승인
*   =========================================
  DATA : lv_cnt TYPE i.
  CLEAR: gv_pernr, gv_error.

  CLEAR : gv_pernr, gv_uname.
  CLEAR : gt_pernr. REFRESH gt_pernr[].

  IF p_uname IS NOT INITIAL.
    gv_uname = p_uname.
  ELSE.
    gv_uname = sy-uname.
  ENDIF.

  PERFORM get_usrid_per_sapid TABLES gt_pernr
                               USING gv_uname
                                     gv_pernr.
*   개인아이디 : GV_PERNR // 공용아이디 : GT_PERNR
*   GV_PERNR 과 GT_PERNR은 둘다 가질수 없음
  IF gv_pernr IS NOT INITIAL.
    gt_pernr-pernr = gv_pernr.
    APPEND gt_pernr.
  ENDIF.

  IF gt_pernr[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E'
       WITH gv_uname '에 대한 사번정보가 존재하지 않습니다.'.
    gv_error = 'X'.
    EXIT.
  ENDIF.

* --------------------------------------------------------------------
* 'D' = 신규선물집행승인
* --------------------------------------------------------------------
  CLEAR : gs_nfnum. REFRESH : gt_nfnum_d.
* 신규선물집행권한이 있는지 체크

  IF gt_pernr[] IS NOT INITIAL.
    CLEAR lv_cnt.
    SELECT COUNT(*) INTO lv_cnt
      FROM znft1090 AS z2
           FOR ALL ENTRIES IN gt_pernr
     WHERE z2~bukrs EQ p_bukrs
       AND z2~congb EQ '3'
       AND z2~consq EQ '1'
       AND z2~pernr EQ gt_pernr-pernr
       AND z2~lvorm NE 'X'.

    IF sy-subrc EQ 0 AND lv_cnt GE 1.
      CLEAR gv_h_cnt.
      SELECT COUNT(*) INTO gv_h_cnt
        FROM znft1020
       WHERE bukrs EQ p_bukrs
         AND confm EQ '2'
         AND oldft EQ space
         AND yncan NE 'X'
         AND ynfin NE 'X'
         AND ynnet NE 'X'.

      IF sy-subrc NE 0.
        IF ok_save EQ 'ALLOW' OR ok_save EQ 'REJECT' OR
           ok_save EQ 'CONF'  OR ok_save EQ 'CANC'.
          gv_error = 'X'.
        ELSE.
          gv_error = 'X'.
          MESSAGE s003 DISPLAY LIKE 'E'
             WITH gv_uname
                  '에 대한 집행승인데이터가 존재하지 않습니다.'.
        ENDIF.
      ENDIF.
    ELSE.
      gv_error = 'X'.
      MESSAGE s003 DISPLAY LIKE 'E'
         WITH gv_uname '에 대한 승인권한이 없습니다.'.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE s003 DISPLAY LIKE 'E'
       WITH gv_uname '에 대한 사번정보가 존재하지 않습니다.'.
    EXIT.

  ENDIF.


ENDFORM.                    " GET_REQ_LIST

*&---------------------------------------------------------------------*
*&      Form  ALV_EVENT_DATA_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM alv_event_data_changed USING
            p_data_changed TYPE REF TO cl_alv_changed_data_protocol.

  DATA: ls_mod_cells TYPE lvc_s_modi,
        lv_index     TYPE i,
        lv_tabix     TYPE i.

  DATA: lt_lvc_styl TYPE lvc_t_styl,
        ls_lvc_styl TYPE lvc_s_styl.

  DATA: lv_cstat LIKE znft1000-cstat,
        lv_cdate LIKE znft1000-cdate.

  FIELD-SYMBOLS : <fs_itab> TYPE ANY TABLE.

  CLEAR:lv_cstat, lv_cdate.
  CLEAR lt_lvc_styl. REFRESH lt_lvc_styl.
  CLEAR lv_index.

  CLEAR gs_outtab_d.
  LOOP AT p_data_changed->mt_good_cells INTO ls_mod_cells.
    lv_index = ls_mod_cells-row_id.
*       Data 가공용 Structure
    READ TABLE gt_outtab_d INTO gs_outtab_d INDEX lv_index.
    IF sy-subrc EQ 0.
      CASE ls_mod_cells-fieldname.
        WHEN 'CHECK'.
          IF ls_mod_cells-value EQ 'X'.
            gs_outtab_d-check = 'X'.
            MODIFY gt_outtab_d FROM gs_outtab_d INDEX lv_index
                               TRANSPORTING check.
          ELSE.
            gs_outtab_d-check = space.
            MODIFY gt_outtab_d FROM gs_outtab_d INDEX lv_index
                               TRANSPORTING check.
          ENDIF.
      ENDCASE.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " ALV_EVENT_DATA_CHANGED

*&---------------------------------------------------------------------*
*&      Form  ALV_EVENT_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW  text
*      -->P_E_COLUMN  text
*      -->P_ES_ROW_NO  text
*----------------------------------------------------------------------*
FORM alv_event_double_click USING p_e_row     TYPE lvc_s_row
                                  p_e_column  TYPE lvc_s_col
                                  p_es_row_no TYPE lvc_s_roid.

  READ TABLE gt_outtab_d INTO gs_outtab_d INDEX p_es_row_no-row_id.

  IF sy-subrc EQ 0.

    CASE p_e_column.
      WHEN 'CONNO'.
        IF NOT gs_outtab_d-conno IS INITIAL.
          SET PARAMETER ID 'ZNFCON' FIELD gs_outtab_d-conno.
          CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.
        ELSE.
          MESSAGE '계약번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      WHEN 'NFUTN'.
        PERFORM call_nfutn_pgm USING gs_outtab_d-nfutn.
    ENDCASE.

  ENDIF.

ENDFORM.                    " ALV_EVENT_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  DATA_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LIST_REQ_TYPE  text
*----------------------------------------------------------------------*
FORM data_select.

  PERFORM get_reqno_d.

ENDFORM.                    " DATA_SELECT

*&---------------------------------------------------------------------*
*&      Form  GET_REQNO_D
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_reqno_d .

  DATA: lv_flag TYPE char01.
  DATA: lv_tabix TYPE sy-tabix,
        lv_error TYPE char01.

  SELECT z1~nfutn           " 선물집행번호
         z1~aedat AS audat  " 승인요청일
         z1~reqno
         z1~h_no1
         z1~nfkey
         z1~rudat
         z1~fcm
         z1~by_sl
         z1~endat
         z1~mityp
         z1~mispd
         z1~mimon
         z1~price
         z1~waers
         z1~emeng
         z1~meins
         z3~conno
         z3~cotxt
         z3~prctr
         z3~sujud
         z3~price AS cprice
         z3~waers AS cwaers
         z3~prate
         z3~erate
         z3~saler
         z2~reqno
         z2~h_no1
         z2~endmm
         z2~emeng AS remeng
         z2~meins AS rmeins
         z1~erdat
         z1~erzet
         z1~ernam
*        PRIND     " 가격구분
*        SUJUP     " 비철수주가격
         INTO CORRESPONDING FIELDS OF TABLE gt_outtab_d
    FROM znft1020 AS z1
         INNER JOIN znft1011 AS z2
           ON z2~reqno EQ z1~reqno AND z2~h_no1 EQ z1~h_no1
         INNER JOIN znft1000 AS z3
           ON z3~conno EQ z2~conno
   WHERE z1~bukrs EQ p_bukrs
     AND z1~confm EQ '2'
     AND z1~oldft EQ space
     AND z1~yncan NE 'X'
     AND z1~ynfin NE 'X'
     AND z1~ynnet NE 'X'.

  IF sy-subrc EQ 0 AND gt_outtab_d IS NOT INITIAL.
    SORT gt_outtab_d BY nfutn nfkey.
    CLEAR: lv_tabix, gs_outtab_d.
    LOOP AT gt_outtab_d INTO gs_outtab_d.
      lv_tabix = sy-tabix.

      AT NEW nfutn.
        lv_flag = 'X'.
      ENDAT.

      IF lv_flag = 'X'.
        CLEAR : lv_flag.
      ELSE.
        gs_outtab_d-check = '-'.
      ENDIF.

      PERFORM domain_value_get USING 'ZBY_SL'
                                     gs_outtab_d-by_sl
                                     gs_outtab_d-by_sl_nm.

*     FCM
      PERFORM get_lifnr_desc USING gs_outtab_d-fcm
                                   gs_outtab_d-fcm_nm.

*     손익센터
      PERFORM get_prctr_desc USING p_bukrs
                                   gs_outtab_d-prctr
                                   gs_outtab_d-ptext.

*___생성인이름
      PERFORM get_sapid_name USING gs_outtab_d-ernam
                                   gs_outtab_d-ename.

*   - 가격구분/비철수주가
      PERFORM price_classification USING gs_outtab_d-conno
                                         gs_outtab_d-nfkey
                                         gs_outtab_d-prind
                                         gs_outtab_d-sujup
                                         lv_error.

*     - 첨부파일
      SELECT SINGLE * FROM znft1002 WHERE conno EQ gs_outtab_d-conno.
      IF sy-subrc EQ 0.
        gs_outtab_d-file_yn = 'Y'.
      ELSE.
        gs_outtab_d-file_yn = 'N'.
      ENDIF.

      MODIFY gt_outtab_d FROM gs_outtab_d INDEX lv_tabix.
      CLEAR: lv_tabix, gs_outtab_d.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " GET_REQNO_D

*&---------------------------------------------------------------------*
*&      Form  DATA_ALLOW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_allow .

* 데이터 체크
  CLEAR gv_error.
  PERFORM data_check USING gv_error.
  CHECK gv_error NE 'X'.

* 진행상황 체크
  CLEAR gv_answer.
  PERFORM popup_to_confirm
    USING '승인'
          '해당 데이터를 승인하시겠습니까?'
          '1'
          gv_answer.
  CHECK gv_answer EQ '1'.

* 공용아이디 체크로직
  SELECT SINGLE * FROM pa0105
   WHERE usrty EQ '9001'
     AND usrid EQ gv_uname
     AND endda GE sy-datlo
     AND begda LE sy-datlo.

  IF sy-subrc EQ 0.
    CALL SCREEN 1210 STARTING AT 10 03
                     ENDING   AT 55 06.
    CHECK gv_error NE 'X'.
  ENDIF.


  PERFORM data_allow_d.

ENDFORM.                    " DATA_ALLOW

*&---------------------------------------------------------------------*
*&      Form  DATA_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_check USING pv_error.

  DATA: ls_outtab_d LIKE gs_outtab_d,
        lt_outtab_d LIKE TABLE OF ls_outtab_d.

  LOOP AT gt_outtab_d INTO gs_outtab_d WHERE check EQ 'X'.
    MOVE-CORRESPONDING gs_outtab_d TO ls_outtab_d.
    APPEND ls_outtab_d TO lt_outtab_d.
  ENDLOOP.

  IF lt_outtab_d IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E'
       WITH '승인하실 데이터를 선택하십시오.'.
    pv_error = 'X'.
    EXIT.
  ENDIF.

* 개인아이디인 경우 인터널테이블에서 읽어오기
  IF gv_pernr IS INITIAL AND lines( gt_pernr ) EQ 1.
    READ TABLE gt_pernr INDEX 1.
    IF sy-subrc EQ 0.
      gv_pernr = gt_pernr-pernr.
    ENDIF.
  ENDIF.

* ==========================================================
*   승인권한 점검
* ==========================================================
  DATA: lv_cnt TYPE i.
  CLEAR lv_cnt.

  IF gt_pernr[] IS NOT INITIAL.
    SELECT COUNT(*) INTO lv_cnt
      FROM znft1090 AS z2
           FOR ALL ENTRIES IN gt_pernr
     WHERE z2~pernr EQ gt_pernr-pernr
       AND z2~bukrs EQ p_bukrs
       AND z2~congb EQ '3'
       AND z2~consq EQ '1'
       AND z2~lvorm NE 'X'.

    IF sy-subrc NE 0 OR lv_cnt EQ 0.
      MESSAGE s003 DISPLAY LIKE 'E'
         WITH '승인권한이 없습니다.'.
      pv_error = 'X'.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE s003 DISPLAY LIKE 'E'
       WITH gv_uname '에 대한 사번정보가 존재하지 않습니다.'.
    EXIT.
  ENDIF.

ENDFORM.                    " DATA_CHECK

*&---------------------------------------------------------------------*
*&      Form  DATA_ALLOW_D
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_allow_d .

  DATA: ls_znft1020 TYPE znft1020,
        lt_znft1020 LIKE TABLE OF ls_znft1020.

  CLEAR gs_outtab_d.
  CLEAR ls_znft1020.  REFRESH lt_znft1020.
  CLEAR gs_znft1020.  REFRESH gt_znft1020.

* 개인아이디인 경우 인터널테이블에서 읽어오기
  IF gv_pernr IS INITIAL AND lines( gt_pernr ) EQ 1.
    READ TABLE gt_pernr INDEX 1.
    IF sy-subrc EQ 0.
      gv_pernr = gt_pernr-pernr.
    ENDIF.
  ENDIF.

  LOOP AT gt_outtab_d INTO gs_outtab_d WHERE check EQ 'X'.

    SELECT SINGLE * INTO CORRESPONDING FIELDS OF ls_znft1020
      FROM znft1020
     WHERE nfutn EQ gs_outtab_d-nfutn.

    IF sy-subrc EQ 0.
*     ### 문서변경이력관리용 ###
      APPEND ls_znft1020 TO gt_znft1020.

      ls_znft1020-confm = '3'.
      ls_znft1020-conam = sy-uname. " 결재자 정보
      ls_znft1020-codat = sy-datlo. " 결재자 정보
      ls_znft1020-cozet = sy-timlo. " 결재자 정보
      ls_znft1020-aenam = sy-uname.
      ls_znft1020-aedat = sy-datlo.
      ls_znft1020-aezet = sy-timlo.
      APPEND ls_znft1020 TO lt_znft1020.
    ENDIF.

  ENDLOOP.

  DATA: lv_dbcnt TYPE i.
  CLEAR lv_dbcnt.

  lv_dbcnt = lines( lt_znft1020 ).

  MODIFY znft1020 FROM TABLE lt_znft1020.

  IF sy-subrc EQ 0.
    PERFORM save_change_doc_znft1020.
    MESSAGE s003 DISPLAY LIKE 'S'
       WITH lv_dbcnt '건이 승인 완료되었습니다.'.


    COMMIT WORK.
*--- 간편결재 전송.
    LOOP AT LT_ZNFT1020 INTO LS_ZNFT1020.
      PERFORM SEND_SIMPLE_APPROVAL
      USING LS_ZNFT1020-NFUTN
                P_BUKRS
                '2D'.
    ENDLOOP.

  ELSE.
    MESSAGE s003 DISPLAY LIKE 'E'
       WITH '승인시 저장오류입니다.'.
    ROLLBACK WORK.
    EXIT.
  ENDIF.

ENDFORM.                    " DATA_ALLOW_D

*&---------------------------------------------------------------------*
*&      Form  DATA_REJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_reject .

* 반려관련 데이터 체크
  CLEAR gv_error.
  PERFORM data_check USING gv_error.
  CHECK gv_error NE 'X'.

*   진행상황 체크
  CLEAR gv_answer.
  PERFORM popup_to_confirm
    USING '반려'
          '해당 데이터를 반려하시겠습니까?'
          '1'
          gv_answer.
  CHECK gv_answer EQ '1'.

* 공용아이디 체크로직
  SELECT SINGLE * FROM pa0105
   WHERE usrty EQ '9001'
     AND usrid EQ gv_uname
     AND endda GE sy-datlo
     AND begda LE sy-datlo.

  IF sy-subrc EQ 0.
    CALL SCREEN 1210 STARTING AT 10 03
                     ENDING   AT 55 06.
    CHECK gv_error NE 'X'.
  ENDIF.


  PERFORM data_reject_d.

ENDFORM.                    " DATA_REJECT

*&---------------------------------------------------------------------*
*&      Form  DATA_REJECT_D
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_reject_d .

  DATA: ls_znft1020 TYPE znft1020,
        lt_znft1020 LIKE TABLE OF ls_znft1020.

  CLEAR gs_outtab_d.
  CLEAR ls_znft1020.  REFRESH lt_znft1020.
  CLEAR gs_znft1020.  REFRESH gt_znft1020.

* 개인아이디인 경우 인터널테이블에서 읽어오기
  IF gv_pernr IS INITIAL AND lines( gt_pernr ) EQ 1.
    READ TABLE gt_pernr INDEX 1.
    IF sy-subrc EQ 0.
      gv_pernr = gt_pernr-pernr.
    ENDIF.
  ENDIF.

  LOOP AT gt_outtab_d INTO gs_outtab_d WHERE check EQ 'X'.

    SELECT SINGLE * INTO CORRESPONDING FIELDS OF ls_znft1020
      FROM znft1020
     WHERE nfutn EQ gs_outtab_d-nfutn.

    IF sy-subrc EQ 0.
*     ### 문서변경이력관리용 ###
      APPEND ls_znft1020 TO gt_znft1020.

      ls_znft1020-confm = '4'.
      ls_znft1020-conam = sy-uname. " 결재자 정보
      ls_znft1020-codat = sy-datlo. " 결재자 정보
      ls_znft1020-cozet = sy-timlo. " 결재자 정보
      ls_znft1020-aenam = sy-uname.
      ls_znft1020-aedat = sy-datlo.
      ls_znft1020-aezet = sy-timlo.
      APPEND ls_znft1020 TO lt_znft1020.
    ENDIF.

  ENDLOOP.

  DATA: lv_dbcnt TYPE i.
  CLEAR lv_dbcnt.

  lv_dbcnt = lines( lt_znft1020 ).

  MODIFY znft1020 FROM TABLE lt_znft1020.

  IF sy-subrc EQ 0.
    PERFORM save_change_doc_znft1020.
    MESSAGE s003 DISPLAY LIKE 'S'
       WITH lv_dbcnt '건이 반려되었습니다.'.

    COMMIT WORK.
*--- 간편결재 전송.
    LOOP AT LT_ZNFT1020 INTO LS_ZNFT1020.
      PERFORM SEND_SIMPLE_APPROVAL
      USING LS_ZNFT1020-NFUTN
                P_BUKRS
                '2D'.
    ENDLOOP.
  ELSE.
    MESSAGE s003 DISPLAY LIKE 'E'
       WITH '반려시 저장오류입니다.'.
    ROLLBACK WORK.
    EXIT.
  ENDIF.

ENDFORM.                    " DATA_REJECT_D

*&---------------------------------------------------------------------*
*&      Form  SAVE_CHANGE_DOC_ZNFT1020
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_change_doc_znft1020 .

  DATA: lv_objectid        TYPE cdhdr-objectid,
        lv_tcode           TYPE cdhdr-tcode,
        lv_cdoc_upd_object TYPE cdhdr-change_ind.

  DATA: ls_znft1020n TYPE znft1020,
        ls_znft1020y TYPE znft1020.

  lv_cdoc_upd_object = 'U'.
  lv_tcode    = sy-tcode.

  CLEAR gs_znft1020.
  LOOP AT gt_znft1020 INTO gs_znft1020.

*   변경전 데이터
    MOVE-CORRESPONDING gs_znft1020 TO ls_znft1020y.

*   변경후 데이터
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF ls_znft1020n
      FROM znft1020
     WHERE nfutn EQ gs_znft1020-nfutn.

    lv_objectid = gs_znft1020-nfutn.

    CALL FUNCTION 'ZNFT1020CHDOC_WRITE_DOCUMENT'
      EXPORTING
        objectid     = lv_objectid
        tcode        = lv_tcode
        utime        = sy-timlo
        udate        = sy-datlo
        username     = sy-uname
        n_znft1020   = ls_znft1020n        " 변경후 데이터
        o_znft1020   = ls_znft1020y        " 변경전 데이터
        upd_znft1020 = lv_cdoc_upd_object.

  ENDLOOP.

ENDFORM.                    " SAVE_CHANGE_DOC_ZNFT1020

*&---------------------------------------------------------------------*
*&      Form  DATA_RELOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_reload.

  CLEAR  : gs_nfnum,   gs_outtab_d.
  REFRESH: gt_nfnum_d, gt_outtab_d.

  PERFORM get_req_list.
  CHECK gv_error IS INITIAL.
  PERFORM data_select.

*  GS_STBL-ROW = 'X'.
*  GS_STBL-COL = 'X'.
*
*  CALL METHOD GRF_GRID->REFRESH_TABLE_DISPLAY
*    EXPORTING
*      I_SOFT_REFRESH = ' '
*      IS_STABLE      = GS_STBL.     "화면 라인 Refresh

ENDFORM.                    " DATA_RELOAD

*&---------------------------------------------------------------------*
*&      Form  FILL_CELLTAB_C
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fill_celltab_c  CHANGING pt_celltab TYPE lvc_t_styl.

  DATA : ls_celltab TYPE lvc_s_styl,
         l_mode     TYPE raw4.

  DATA : l_fieldcat TYPE lvc_s_fcat.

  LOOP AT gt_fieldcat INTO l_fieldcat.
    ls_celltab-fieldname = l_fieldcat-fieldname.

*  필드 활성화 여부
    IF l_fieldcat-edit = 'X'.
      IF ls_celltab-fieldname = 'CHECK'.
        IF gs_outtab_d-check = '-'.
          ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
        ELSE.
          ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
        ENDIF.
      ELSE.
        ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
      ENDIF.
    ELSE.
      ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
    ENDIF.
    INSERT ls_celltab INTO TABLE pt_celltab.
  ENDLOOP.

ENDFORM.                    " FILL_CELLTAB_C

*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_all .

  LOOP AT gt_outtab_d INTO gs_outtab_d WHERE check NE '-'.
    IF ok_save = 'ASEL'.
      gs_outtab_d-check = 'X'.
    ELSE.
      CLEAR : gs_outtab_d-check.
    ENDIF.
    MODIFY gt_outtab_d FROM gs_outtab_d TRANSPORTING check.
  ENDLOOP.

ENDFORM.                    " SELECT_ALL

*&---------------------------------------------------------------------*
*&      Form  CALL_NFUTN_PGM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_OUTTAB_D_NFUTN  text
*----------------------------------------------------------------------*
FORM call_nfutn_pgm  USING    pv_nfutn.

  DATA: lt_rspar LIKE rsparams OCCURS 0 WITH HEADER LINE.

  CLEAR   : lt_rspar.
  REFRESH : lt_rspar.

  append_param : lt_rspar 'P_BUKRS' 'P' ' ' ' '  p_bukrs       ' ',
                 lt_rspar 'S_NFUTN' 'S' 'I' 'EQ' pv_nfutn      ' ',
                 lt_rspar 'P_CHK11' 'P' ' ' ' '  'X'           ' ',
                 lt_rspar 'P_CHK12' 'P' ' ' ' '  ' '           ' ',
                 lt_rspar 'P_R01'   'P' ' ' ' '  ' '           ' ',
                 lt_rspar 'P_R02'   'P' ' ' ' '  ' '           ' ',
                 lt_rspar 'P_R03'   'P' ' ' ' '  'X'           ' ',
                 lt_rspar 'P_R11'   'P' ' ' ' '  ' '           ' ',
                 lt_rspar 'P_R12'   'P' ' ' ' '  ' '           ' ',
                 lt_rspar 'P_R13'   'P' ' ' ' '  'X'           ' ',
                 lt_rspar 'P_R21'   'P' ' ' ' '  ' '           ' ',
                 lt_rspar 'P_R22'   'P' ' ' ' '  ' '           ' ',
                 lt_rspar 'P_R23'   'P' ' ' ' '  'X'           ' '.

  SUBMIT znfr2600 WITH SELECTION-TABLE lt_rspar
                   AND RETURN.

ENDFORM.                    " CALL_NFUTN_PGM

*&---------------------------------------------------------------------*
*&      Form  PASWD_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM paswd_check  USING    pv_error.

  IF gv_passwd IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E'
       WITH '비밀번호를 입력하십시오.'.
    pv_error = 'X'.
  ENDIF.

ENDFORM.                    " PASWD_CHECK

*&---------------------------------------------------------------------*
*&      Form  MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_screen .

  IF NOT ( sy-uname EQ 'ZERPMM'  OR sy-uname EQ 'ZLSGMM2' OR
           sy-uname EQ 'ZLSGMM'  OR sy-uname EQ 'ZLSGLSC' OR
           sy-uname EQ 'ZLSGLSM'  OR sy-uname EQ 'ZTEST07').
    LOOP AT SCREEN.
      IF screen-name = 'P_UNAME' OR
        screen-name  = '%_P_UNAME_%_APP_%-TEXT'.
        screen-input     = 0.
        screen-invisible = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " MODIFY_SCREEN
FORM SEND_SIMPLE_APPROVAL  USING    P_EXENO
                                    P_BUKRS
                                    P_TYPE TYPE ZESAZTYPE.


  CALL FUNCTION 'ZSA1_MM_MAKE_SEND_DATA'
    EXPORTING
      I_BUKRS = P_BUKRS
      I_EXENO = P_EXENO
      I_EXTYP = P_TYPE.

ENDFORM.
