*&---------------------------------------------------------------------*
*&  Include           ZNFR2500F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F4HELP_DIV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f4help_div  USING    pv_div.

  CLEAR   : selectfield, select_value, ld_tabix,   gv_index,
            it_fields,   scr_fields,   feld_table, gt_div.
  REFRESH : it_fields,   scr_fields,   feld_table, gt_div.

*___화면상의 회사코드를 읽는다.
  IF sy-dynnr = '1000'.
    scr_fields-fieldname = 'P_BUKRS'.
    APPEND scr_fields.

    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        dyname     = 'ZNFR2500'
        dynumb     = '1000'
      TABLES
        dynpfields = scr_fields.

    READ TABLE scr_fields WITH KEY fieldname = 'P_BUKRS'.
    p_bukrs = scr_fields-fieldvalue.
  ENDIF.

  IF p_bukrs IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E'
       WITH '회사코드를 입력하시기 바랍니다.'.
    EXIT.
  ENDIF.

  SELECT h1~zcode
         h2~ztext
         INTO CORRESPONDING FIELDS OF TABLE gt_div
    FROM zhrtb103 AS h1
         INNER JOIN zhrtb103t AS h2
            ON h2~zcode EQ h1~zcode
   WHERE h1~zbukrs EQ p_bukrs
     AND h1~activ  EQ 'N'
     AND h2~sprsl EQ sy-langu.

  IF sy-subrc <> 0.
    MESSAGE s003 DISPLAY LIKE 'E'
       WITH '사업부 정보가 존재하지 않습니다.'.
    EXIT.
  ENDIF.

*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  it_fields-tabname    = 'ZHRTB103T'.
  it_fields-fieldname  = 'ZCODE'.
  it_fields-selectflag = 'X'.
  APPEND it_fields.

  it_fields-tabname    = 'ZHRTB103T'.
  it_fields-fieldname  = 'ZTEXT'.
  it_fields-selectflag = ' '.
  APPEND it_fields.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      selectfield                  = selectfield
    IMPORTING
      ind                          = ld_tabix
      select_value                 = select_value
    TABLES
      fields                       = it_fields
      full_table                   = gt_div
    EXCEPTIONS
      full_table_empty             = 1
      no_tablestructure_given      = 2
      no_tablefields_in_dictionary = 3
      more_then_one_selectfield    = 4
      no_selectfield               = 5
      OTHERS                       = 6.

  CHECK NOT ld_tabix IS INITIAL.
  READ TABLE gt_div INDEX ld_tabix.
  IF sy-subrc = 0.
    pv_div = gt_div-zcode.
  ENDIF.

ENDFORM.                    " F4HELP_DIV

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
  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
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

  CLEAR : gs_sort, gt_sort.
  REFRESH gt_sort.

*  GS_SORT-SPOS = 1.
*  GS_SORT-FIELDNAME = 'CONGB'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 2.
*  GS_SORT-FIELDNAME = 'CONSQ'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.

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

  PERFORM set_fieldcat USING:
    'BUKRS'           '회사코드'        '8'      'C'    ' '     ,
    'CONGB'           '결재구분'        '8'      'C'    ' '     ,
    'CONGB_NM'        '결재구분'        '10'     'C'    ' '     ,
    'CONSQ'           '결재순번'        '10'     'C'    ' '     ,
    'CONTX'           '결재권한'        '10'     'L'    ' '     ,
    'IDTYP_NM'        'ID 구분'         '10'     'C'    ' '     ,
    'USRID'           'SAP ID'          '10'     'L'    ' '     ,
    'PERNR'           '사번'            '10'     'C'    ' '     ,
    'ZZ_DIVIS'        '사업부'          '10'     'C'    ' '     ,
    'ZTEXT'           '사업부'          '10'     'L'    ' '     ,
    'ORGEH'           '부서명'          '10'     'C'    ' '     ,
    'ORGTX'           '부서명'          '10'     'L'    ' '     ,
    'SNAME'           '사원명'          '12'     'L'    ' '     ,
    'LVORM'           '삭제여부'        '10'     'C'    ' '     ,
    'PASWD'           '비밀번호'        '32'     'L'    ' '     .

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
    WHEN 'CONGB'.
*      GS_FIELDCAT-NO_OUT     = 'X'.
      gs_fieldcat-edit       = 'X'.
      gs_fieldcat-ref_table  = 'ZNFT1090'.
      gs_fieldcat-ref_field  = 'CONGB'.
    WHEN 'CONGB_NM'.
*      GS_FIELDCAT-EDIT       = 'X'.
    WHEN 'CONSQ'.
      gs_fieldcat-edit       = 'X'.
*    WHEN 'ZZ_DIVIS' OR 'ORGEH'.
*      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'PERNR'.
      gs_fieldcat-edit       = 'X'.
      gs_fieldcat-f4availabl = 'X'.
    WHEN 'PASWD'.
      gs_fieldcat-edit       = 'X'.
      gs_fieldcat-lowercase  = 'X'.
    WHEN 'LVORM'.
      gs_fieldcat-edit       = 'X'.
      gs_fieldcat-checkbox   = 'X'.
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
         lv_index    TYPE i.

  LOOP AT gt_outtab INTO gs_outtab.
    lv_index = sy-tabix.
    REFRESH lt_celltab.
    CLEAR gs_outtab-celltab.
    PERFORM fill_celltab_c CHANGING lt_celltab.
    INSERT LINES OF lt_celltab INTO TABLE gs_outtab-celltab.
    MODIFY gt_outtab FROM gs_outtab INDEX lv_index.
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

* DATA가 변경될 경우
  CALL METHOD grf_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CREATE OBJECT grf_event_receiver.
  SET HANDLER :
    grf_event_receiver->handle_data_changed          FOR grf_grid,
    grf_event_receiver->handle_data_changed_finished FOR grf_grid,
    grf_event_receiver->handle_on_f4                 FOR grf_grid.

*  EDITE 가능상태
*  CALL METHOD GRF_GRID->SET_READY_FOR_INPUT
*    EXPORTING
*      I_READY_FOR_INPUT = 1.

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

* FieldName별 소트해서 APPEND
  gs_f4-fieldname = 'PERNR'.
  gs_f4-register  = 'X'.
  APPEND gs_f4 TO gt_f4.

  CALL METHOD grf_grid->register_f4_for_fields
    EXPORTING
      it_f4 = gt_f4.

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
      i_bypassing_buffer            = 'X'
      i_default                     = 'X'
      i_save                        = 'A'
      is_variant                    = gs_variant
      is_layout                     = gs_layout
      it_toolbar_excluding          = gt_exclude
    CHANGING
      it_fieldcatalog               = gt_fieldcat[]
      it_filter                     = gt_filter
      it_outtab                     = gt_outtab[]
      it_sort                       = gt_sort[]
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
*&      Form  DATA_ADD_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_add_row .

  CLEAR gs_outtab.

  DATA: lv_cnt TYPE i.

  gs_outtab-stats   = 'I'.
  gs_outtab-bukrs   = p_bukrs.

  APPEND gs_outtab TO gt_outtab.

ENDFORM.                    " DATA_ADD_ROW

*&---------------------------------------------------------------------*
*&      Form  GET_DATA_ID_TYPE
*&---------------------------------------------------------------------*
FORM get_data_id_type USING pv_fname TYPE any.

  DATA lt_values TYPE vrm_values.

  FIELD-SYMBOLS <lfs_value> TYPE vrm_value.

  APPEND INITIAL LINE TO lt_values ASSIGNING <lfs_value>.
  <lfs_value>-key  = '1'.
  <lfs_value>-text = '공용'.

  APPEND INITIAL LINE TO lt_values ASSIGNING <lfs_value>.
  <lfs_value>-key  = '2'.
  <lfs_value>-text = '개인'.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = pv_fname
      values = lt_values.

ENDFORM.                    "GET_DATA_ID_TYPE

*&---------------------------------------------------------------------*
*&      Form  DATA_SELECT_ZNFT1090
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_select_znft1090 .

  DATA: lv_tabix TYPE sy-tabix.
  DATA: lv_class LIKE usr02-class.

  SELECT z1~bukrs
         z1~congb
         z1~consq
         z1~pernr
         z1~paswd
         z1~lvorm
         z1~erdat
         z1~erzet
         z1~ernam
         z1~aedat
         z1~aezet
         z1~aenam
**         P2~ZZ_ESSGB
**         P2~USRID
         p1~zz_divis  " 사업부
         z2~ztext
         p1~orgeh     " 부서
         t1~orgtx
         p1~sname     " 이름
*        Key값 수정시 삭제후 저장하기 위한 비교 Key값
         z1~bukrs AS bukrs_b
         z1~congb AS congb_b
         z1~consq AS consq_b
         z1~pernr AS pernr_b
         INTO CORRESPONDING FIELDS OF TABLE gt_outtab
    FROM znft1090 AS z1
         INNER JOIN zzpa0001 AS p1
            ON p1~pernr EQ z1~pernr
         INNER JOIN zhrtb103t AS z2
            ON z2~zcode EQ p1~zz_divis
         INNER JOIN t527x AS t1
            ON t1~orgeh EQ p1~orgeh
**         INNER JOIN PA0105 AS P2
**            ON P2~PERNR EQ Z1~PERNR
   WHERE z1~bukrs EQ p_bukrs
     AND z2~sprsl EQ sy-langu
     AND t1~begda LE sy-datum
     AND t1~endda GE sy-datum
     AND t1~sprsl EQ sy-langu
     AND p1~begda LE sy-datum
     AND p1~endda GE sy-datum
**     AND P2~BEGDA LE SY-DATUM
**     AND P2~ENDDA GE SY-DATUM
**     AND P2~SUBTY EQ '0001'
     AND p1~zz_divis IN s_divis
     AND z1~congb    IN s_congb
     AND z1~pernr    IN s_pernr
     AND z1~lvorm    IN s_lvorm.

  IF sy-subrc EQ 0.
    IF gt_outtab IS NOT INITIAL.
      SORT gt_outtab BY bukrs comm congb consq pernr.
      LOOP AT gt_outtab INTO gs_outtab.
        lv_tabix = sy-tabix.

*       - 결재구분
        PERFORM domain_value_get USING 'ZCONGB'
                                       gs_outtab-congb
                                       gs_outtab-congb_nm.

*       - 결재명 가져오기
        PERFORM get_contx_desc USING gs_outtab-bukrs
                                     gs_outtab-congb
                                     gs_outtab-consq
                                     gs_outtab-contx
                                     gv_error.

*.......개인/공용ID 구분
*       '0001' 타입 ID를 읽어서 USR02-CLASS = 'PUSER'이면
*       개인ID로 인식하고,
*       '0001' 타입 없거나, USR02-CLASS <> 'PUSER'이면
*       '9001' 타입으로 공용ID로 인식함.
        IF gs_outtab-pernr_b IS NOT INITIAL.
          SELECT SINGLE usrid
            INTO gs_outtab-usrid
            FROM pa0105
           WHERE usrty EQ '0001'
             AND begda LE sy-datlo
             AND endda GE sy-datlo
             AND pernr EQ gs_outtab-pernr.

          IF sy-subrc EQ 0.
            SELECT SINGLE class
              INTO lv_class
              FROM usr02
             WHERE bname =  gs_outtab-usrid
               AND gltgv <= sy-datlo
               AND gltgb >= sy-datlo
               AND class =  'PUSER'.

            IF sy-subrc <> 0.
              SELECT SINGLE class
                INTO lv_class
                FROM usr02
               WHERE bname = gs_outtab-usrid
                 AND gltgb = '00000000'
                 AND class = 'PUSER'.

              IF sy-subrc <> 0.
                CLEAR : gs_outtab-usrid.

*...............공용 ID
                SELECT SINGLE usrid
                  INTO gs_outtab-usrid
                  FROM pa0105
                 WHERE pernr =  gs_outtab-pernr
                   AND usrty =  '9001'
                   AND endda >= sy-datlo
                   AND begda <= sy-datlo.

                IF sy-subrc EQ 0.
                  gs_outtab-idtyp_nm = '공용'.
                  gs_outtab-comm     = 'X'.
                ENDIF.
              ELSE.
                gs_outtab-idtyp_nm = '개인'.
              ENDIF.
            ELSE.
              gs_outtab-idtyp_nm = '개인'.
            ENDIF.
          ELSE.
*...........공용 ID
            SELECT SINGLE usrid
              INTO gs_outtab-usrid
              FROM pa0105
             WHERE pernr =  gs_outtab-pernr
               AND usrty =  '9001'
               AND endda >= sy-datlo
               AND begda <= sy-datlo.

            IF sy-subrc EQ 0.
              gs_outtab-idtyp_nm = '공용'.
              gs_outtab-comm     = 'X'.
            ENDIF.
          ENDIF.
        ENDIF.

*.......ID 구분
        CASE p_idtyp.
          WHEN '1'.  " 공용
            IF gs_outtab-comm EQ space.
              DELETE gt_outtab INDEX lv_tabix.
              CONTINUE.
            ENDIF.
          WHEN '2'.  " 개인
            IF gs_outtab-comm EQ 'X'.
              DELETE gt_outtab INDEX lv_tabix.
              CONTINUE.
            ENDIF.
        ENDCASE.

        MODIFY gt_outtab FROM gs_outtab INDEX lv_tabix.
        CLEAR : lv_tabix, gs_outtab.
      ENDLOOP.
      SORT gt_outtab BY bukrs congb consq.
    ELSE.

    ENDIF.
  ELSE.

  ENDIF.

ENDFORM.                    " DATA_SELECT_ZNFT1090

*&---------------------------------------------------------------------*
*&      Form  FILL_CELLTAB_C
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fill_celltab_c CHANGING pt_celltab TYPE lvc_t_styl.

  DATA : ls_celltab TYPE lvc_s_styl,
         l_mode     TYPE raw4.

  DATA : l_fieldcat TYPE lvc_s_fcat.

  LOOP AT gt_fieldcat INTO l_fieldcat.
    ls_celltab-fieldname = l_fieldcat-fieldname.

*   필드 활성화 여부
    CASE ls_celltab-fieldname.
      WHEN 'PASWD'.
*       ID구분이 'X'인경우(공용) : 수정가능
        IF gs_outtab-comm EQ 'X'.
          ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
        ELSE.
          ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
        ENDIF.
    ENDCASE.
    INSERT ls_celltab INTO TABLE pt_celltab.
  ENDLOOP.

ENDFORM.                    " FILL_CELLTAB_C

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
        lv_index TYPE i,
        lv_tabix TYPE i,
        pv_error TYPE char01.

  DATA: lt_lvc_styl TYPE lvc_t_styl,
        ls_lvc_styl TYPE lvc_s_styl.

  DATA: lv_cstat LIKE znft1000-cstat,
        lv_cdate LIKE znft1000-cdate.

  CLEAR:lv_cstat, lv_cdate.

  CLEAR lt_lvc_styl. REFRESH lt_lvc_styl.
  CLEAR lv_index.

  LOOP AT p_data_changed->mt_good_cells INTO ls_mod_cells.
    lv_index = ls_mod_cells-row_id.

*   Data 가공용 Structure
    READ TABLE gt_outtab INTO gs_outtab INDEX lv_index.

    IF sy-subrc EQ 0.
      CASE ls_mod_cells-fieldname.
        WHEN 'CONGB'.
          IF gs_outtab-stats NE 'I'.
            gs_outtab-stats = 'U'.
          ENDIF.
          gs_outtab-congb = ls_mod_cells-value.
          PERFORM domain_value_get USING 'ZCONGB'
                                         gs_outtab-congb
                                         gs_outtab-congb_nm.
          MODIFY gt_outtab FROM gs_outtab INDEX lv_index.
        WHEN 'CONSQ'.
          IF gs_outtab-stats NE 'I'.
            gs_outtab-stats = 'U'.
          ENDIF.
          gs_outtab-consq = ls_mod_cells-value.

*         결제순번 TEXT 가져오기

          PERFORM get_contx_desc USING gs_outtab-bukrs
                                       gs_outtab-congb
                                       gs_outtab-consq
                                       gs_outtab-contx
                                       pv_error.
          MODIFY gt_outtab FROM gs_outtab INDEX lv_index.
        WHEN 'PERNR'.
          CLEAR gv_error.
          IF gs_outtab-stats NE 'I'.
            gs_outtab-stats = 'U'.
          ENDIF.
          gs_outtab-pernr = ls_mod_cells-value.
          PERFORM get_pernr_ect_data USING gs_outtab-pernr
                                           gs_outtab-sname
                                           gs_outtab-comm
                                           gs_outtab-idtyp_nm
                                           gs_outtab-usrid
                                           gs_outtab-zz_divis
                                           gs_outtab-ztext
                                           gs_outtab-orgeh
                                           gs_outtab-orgtx
                                           gv_error.
          IF gv_error EQ 'X'.
            MESSAGE i003 DISPLAY LIKE 'E'
               WITH '[' gs_outtab-pernr ']는 잘못된 사원번호 입니다.'.
            EXIT.
          ENDIF.

          MODIFY gt_outtab FROM gs_outtab INDEX lv_index.
        WHEN 'LVORM'.
          IF gs_outtab-stats NE 'I'.
            gs_outtab-stats = 'U'.
          ENDIF.
          gs_outtab-lvorm = ls_mod_cells-value.
          MODIFY gt_outtab FROM gs_outtab INDEX lv_index.
        WHEN 'PASWD'.
          IF gs_outtab-stats NE 'I'.
            gs_outtab-stats = 'U'.
          ENDIF.
          gs_outtab-paswd = ls_mod_cells-value.
          MODIFY gt_outtab FROM gs_outtab INDEX lv_index.
      ENDCASE.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " ALV_EVENT_DATA_CHANGED

*&---------------------------------------------------------------------*
*&      Form  ALV_EVENT_ON_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SENDER  text
*      -->P_E_FIELDNAME  text
*      -->P_E_FIELDVALUE  text
*      -->P_ES_ROW_NO  text
*      -->P_ER_EVENT_DATA  text
*      -->P_ET_BAD_CELLS  text
*      -->P_E_DISPLAY  text
*----------------------------------------------------------------------*
FORM alv_event_on_f4 USING  sender         TYPE REF TO cl_gui_alv_grid
                            e_fieldname    TYPE lvc_fname
                            e_fieldvalue   TYPE lvc_value
                            es_row_no      TYPE lvc_s_roid
                            er_event_data  TYPE REF TO cl_alv_event_data
                            et_bad_cells   TYPE lvc_t_modi
                            e_display      TYPE char01.

  DATA: lv_index TYPE sy-index.

  CASE e_fieldname.
    WHEN 'PERNR'.
      lv_index = es_row_no-row_id.
      READ TABLE gt_outtab INTO gs_outtab INDEX lv_index.
      IF sy-subrc EQ 0.
        PERFORM f4help_pernr USING gs_outtab-pernr.
        IF gs_outtab-pernr IS NOT INITIAL.
          CLEAR gv_error.
          IF gs_outtab-stats NE 'I'.
            gs_outtab-stats = 'U'.
          ENDIF.
          PERFORM get_pernr_ect_data USING gs_outtab-pernr
                                           gs_outtab-sname
                                           gs_outtab-comm
                                           gs_outtab-idtyp_nm
                                           gs_outtab-usrid
                                           gs_outtab-zz_divis
                                           gs_outtab-ztext
                                           gs_outtab-orgeh
                                           gs_outtab-orgtx
                                           gv_error.
          IF gv_error EQ 'X'.
            MESSAGE s003 DISPLAY LIKE 'E'
               WITH gs_outtab-pernr '는 잘못된 사원번호 입니다.'.
            EXIT.
          ENDIF.
          MODIFY gt_outtab FROM gs_outtab INDEX lv_index.
        ENDIF.
      ENDIF.
  ENDCASE.

  er_event_data->m_event_handled = 'X'.

ENDFORM.                    " ALV_EVENT_ON_F4

*&---------------------------------------------------------------------*
*&      Form  GET_PERNR_ECT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PV_PERNR     text
*      -->PV_ZZESSGB   text
*      -->PV_IDTYP_NM  text
*      -->PV_USRID     text
*      -->PV_ZZ_DIVIS  text
*      -->PV_ZTEXT     text
*      -->PV_ORGEH     text
*      -->PV_ORGTX     text
*      -->PV_ERROR     text
*----------------------------------------------------------------------*
FORM get_pernr_ect_data  USING pv_pernr
                               pv_sname
                               pv_comm
                               pv_idtyp_nm
                               pv_usrid
                               pv_zz_divis
                               pv_ztext
                               pv_orgeh
                               pv_orgtx
                               pv_error.

  DATA: BEGIN OF ls_pernr_info,
          pernr    LIKE znft1090-pernr,   " 사번
          sname    LIKE zzpa0001-sname,     " 사원명
*          ZZ_ESSGB LIKE PA0105-ZZ_ESSGB,  " ID구분
          idtyp_nm TYPE char04,           " ID구분명
          usrid    LIKE pa0105-usrid,     " SAP ID
          zz_divis LIKE zzpa0001-zz_divis,  " 사업부
          ztext    LIKE zhrtb103t-ztext,  " 사업부명
          orgeh    LIKE zzpa0001-orgeh,     " 부서
          orgtx    LIKE t527x-orgtx,      " 부서명
  END OF ls_pernr_info.

  DATA: lv_comm.

  CLEAR : ls_pernr_info, lv_comm.

*___사용자 ID
  PERFORM get_sapid_per_usrid USING pv_pernr
                                    ls_pernr_info-usrid
                                    lv_comm.

* 사원코드에 해당하는 추가데이터
  SELECT SINGLE
         p1~pernr
         p1~sname     " 이름
*         p2~zz_essgb
         p1~zz_divis  " 사업부
         z1~ztext
         p1~orgeh     " 부서
         t1~orgtx
*         p2~usrid
         INTO CORRESPONDING FIELDS OF ls_pernr_info
    FROM zzpa0001 AS p1
*         INNER JOIN pa0105 AS p2
*            ON p2~pernr EQ p1~pernr
         INNER JOIN t527x AS t1
            ON t1~orgeh EQ p1~orgeh
         INNER JOIN zhrtb103t AS z1
            ON z1~zcode EQ p1~zz_divis
   WHERE p1~begda LE sy-datlo
     AND p1~endda GE sy-datlo
     AND z1~sprsl EQ sy-langu
*     AND p2~begda LE sy-datlo
*     AND p2~endda GE sy-datlo
     AND t1~begda LE sy-datlo
     AND t1~endda GE sy-datlo
     AND t1~sprsl EQ sy-langu
*     AND p2~usrty EQ '0001'
     AND p1~pernr EQ pv_pernr.

  IF sy-subrc EQ 0.
    IF lv_comm EQ 'X'.
      ls_pernr_info-idtyp_nm = '공용'.
    ELSE.
      ls_pernr_info-idtyp_nm = '개인'.
    ENDIF.
*    IF ls_pernr_info-zz_essgb EQ 'X'.
*      ls_pernr_info-idtyp_nm = '공용'.
*    ELSE.
*      ls_pernr_info-idtyp_nm = '개인'.
*    ENDIF.

    pv_pernr    = ls_pernr_info-pernr     .
    pv_sname    = ls_pernr_info-sname     .
    pv_comm     = lv_comm.
*    pv_zz_essgb = ls_pernr_info-zz_essgb  .
    pv_idtyp_nm = ls_pernr_info-idtyp_nm  .
    pv_usrid    = ls_pernr_info-usrid     .

*    IF ls_pernr_info-zz_essgb EQ 'X'.
*
*      SELECT SINGLE usrid INTO ls_pernr_info-usrid
*        FROM pa0105
*       WHERE usrty EQ '9001'
*         AND begda LE sy-datlo
*         AND endda GE sy-datlo
*         AND pernr EQ pv_pernr.
*
*      IF sy-subrc EQ 0.
*        pv_usrid    = ls_pernr_info-usrid.
*      ELSE.
*        CLEAR pv_usrid.
*      ENDIF.
*
*    ENDIF.

    pv_zz_divis = ls_pernr_info-zz_divis .
    pv_ztext    = ls_pernr_info-ztext    .
    pv_orgeh    = ls_pernr_info-orgeh    .
    pv_orgtx    = ls_pernr_info-orgtx    .

  ELSE.
    pv_error = 'X'.
  ENDIF.

ENDFORM.                    " GET_PERNR_ECT_DATA

*&---------------------------------------------------------------------*
*&      Form  F4HELP_PERNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_OUTTAB_PERNR  text
*----------------------------------------------------------------------*
FORM f4help_pernr  USING    pv_pernr.

  CLEAR   : selectfield, select_value, ld_tabix, gv_index,
            it_fields.
  REFRESH : it_fields.

  DATA: BEGIN OF ls_pernr_info,
          pernr    LIKE znft1090-pernr,   " 사번
          sname    LIKE zzpa0001-sname,     " 사원명
          zz_divis LIKE zzpa0001-zz_divis,  " 사업부
          ztext    LIKE zhrtb103t-ztext,  " 사업부명
          orgeh    LIKE zzpa0001-orgeh,     " 부서
          orgtx    LIKE t527x-orgtx,      " 부서명
*          ZZ_ESSGB LIKE PA0105-ZZ_ESSGB,  " ID구분
          idtyp_nm TYPE char04,           " ID구분명
          usrid    LIKE zpa0105-usrid,     " SAP ID
  END OF ls_pernr_info.
  DATA: lt_pernr_info LIKE TABLE OF ls_pernr_info.


* 사원코드에 해당하는 추가데이터
  SELECT p1~pernr     " 사원번호
         p1~sname     " 이름
         p1~zz_divis  " 사업부
         z1~ztext
         p1~orgeh     " 부서
         t1~orgtx
*         P2~ZZ_ESSGB
*         P2~USRID
         INTO CORRESPONDING FIELDS OF TABLE lt_pernr_info
    FROM zzpa0001 AS p1
*         INNER JOIN PA0105 AS P2
*            ON P2~PERNR EQ P1~PERNR
         INNER JOIN t527x AS t1
            ON t1~orgeh EQ p1~orgeh
         INNER JOIN zhrtb103t AS z1
            ON z1~zcode EQ p1~zz_divis
   WHERE p1~begda LE sy-datlo
     AND p1~endda GE sy-datlo
     AND z1~sprsl EQ sy-langu
*     AND P2~BEGDA LE SY-DATLO
*     AND P2~ENDDA GE SY-DATLO
     AND t1~begda LE sy-datlo
     AND t1~endda GE sy-datlo
     AND t1~sprsl EQ sy-langu.
*     AND P2~SUBTY EQ '0001'.

  IF sy-subrc NE 0.
    MESSAGE s003 DISPLAY LIKE 'E'
       WITH '사원코드 정보가 존재하지 않습니다.'.
    EXIT.
  ENDIF.

* 아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  it_fields-tabname  = 'ZZPA0001'.    it_fields-fieldname  = 'PERNR'.
  it_fields-selectflag = 'X'.
  APPEND it_fields.

  it_fields-tabname  = 'ZZPA0001'.    it_fields-fieldname  = 'SNAME'.
  it_fields-selectflag = ' '.
  APPEND it_fields.

  it_fields-tabname = 'ZZPA0001'.    it_fields-fieldname  = 'ZZ_DIVIS'.
  it_fields-selectflag = ' '.
  APPEND it_fields.

  it_fields-tabname  = 'ZHRTB103T'. it_fields-fieldname  = 'ZTEXT'.
  it_fields-selectflag = ' '.
  APPEND it_fields.

  it_fields-tabname  = 'ZZPA0001'.    it_fields-fieldname  = 'ORGEH'.
  it_fields-selectflag = ' '.
  APPEND it_fields.

  it_fields-tabname    = 'T527X'.     it_fields-fieldname  = 'ORGTX'.
  it_fields-selectflag = ' '.
  APPEND it_fields.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      selectfield                  = selectfield
    IMPORTING
      ind                          = ld_tabix
      select_value                 = select_value
    TABLES
      fields                       = it_fields
      full_table                   = lt_pernr_info
    EXCEPTIONS
      full_table_empty             = 1
      no_tablestructure_given      = 2
      no_tablefields_in_dictionary = 3
      more_then_one_selectfield    = 4
      no_selectfield               = 5
      OTHERS                       = 6.

  CHECK NOT ld_tabix IS INITIAL.
  CLEAR ls_pernr_info.
  READ TABLE lt_pernr_info INTO ls_pernr_info INDEX ld_tabix.
  IF sy-subrc = 0.
    pv_pernr = ls_pernr_info-pernr.
  ENDIF.

ENDFORM.                    " F4HELP_PERNR

*&---------------------------------------------------------------------*
*&      Form  DATA_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM data_check  USING pv_error.

  DATA: lv_cnt   TYPE i,
        lv_tabix TYPE sy-tabix,
        lv_e_msg TYPE char50.

  CLEAR: pv_error, lv_cnt.

  CALL METHOD grf_grid->check_changed_data.

* 신규 또는 수정건의 필수입력 필드값 체크
  CLEAR: lv_cnt, lv_tabix.
  LOOP AT gt_outtab INTO gs_outtab WHERE stats NE space.

    lv_tabix = sy-tabix.

    IF gs_outtab-bukrs IS INITIAL.
      pv_error = 'X'.
      MESSAGE s003 DISPLAY LIKE 'E'
         WITH '회사코드는 필수입력 필드입니다.'.
      EXIT.
    ENDIF.

    IF gs_outtab-congb IS INITIAL.
      pv_error = 'X'.
      MESSAGE i003 DISPLAY LIKE 'E'
         WITH '결재구분은 필수입력 필드입니다.'.
      EXIT.
    ENDIF.

    IF gs_outtab-consq IS INITIAL.
      pv_error = 'X'.
      MESSAGE i003 DISPLAY LIKE 'E'
         WITH '결재순번은 필수입력 필드입니다.'.
      EXIT.
    ENDIF.

*   결재명 가져오기
    PERFORM get_contx_desc USING gs_outtab-bukrs
                                 gs_outtab-congb
                                 gs_outtab-consq
                                 gs_outtab-contx
                                 pv_error.

    IF pv_error = 'X'.
      CLEAR lv_e_msg.
      CONCATENATE '결재구분 : ' gs_outtab-congb
                  ', 결재순번 : ' gs_outtab-consq
                  ' 을 잘못 입력하셨습니다.'
             INTO lv_e_msg.
      MESSAGE i003 DISPLAY LIKE 'E'
         WITH lv_e_msg.
      EXIT.
    ENDIF.

*   사원번호 체크
    IF gs_outtab-pernr IS INITIAL.
      pv_error = 'X'.
      MESSAGE i003 DISPLAY LIKE 'E'
         WITH '사원번호는 필수입력 필드입니다.'.
      EXIT.
    ELSE.
      PERFORM get_pernr_ect_data USING gs_outtab-pernr
                                       gs_outtab-sname
                                       gs_outtab-comm
                                       gs_outtab-idtyp_nm
                                       gs_outtab-usrid
                                       gs_outtab-zz_divis
                                       gs_outtab-ztext
                                       gs_outtab-orgeh
                                       gs_outtab-orgtx
                                       pv_error.
      IF pv_error EQ 'X'.
        MESSAGE i003 DISPLAY LIKE 'E'
           WITH gs_outtab-pernr '는 잘못된 사원번호 입니다.'.
        EXIT.
      ENDIF.
    ENDIF.

*   중복데이터 체크
    IF gs_outtab-stats EQ 'I'         AND
       gs_outtab-bukrs IS NOT INITIAL AND
       gs_outtab-congb IS NOT INITIAL AND
       gs_outtab-consq IS NOT INITIAL AND
       gs_outtab-pernr IS NOT INITIAL.

      SELECT SINGLE * FROM znft1090
       WHERE bukrs EQ gs_outtab-bukrs
         AND congb EQ gs_outtab-congb
         AND consq EQ gs_outtab-consq
         AND pernr EQ gs_outtab-pernr.

      IF sy-subrc EQ 0 AND znft1090 IS NOT INITIAL.
        pv_error = 'X'.
        MESSAGE i003 DISPLAY LIKE 'E'
           WITH '중복된 데이터가 존재합니다.'.
        EXIT.
      ENDIF.
    ENDIF.


*   ID구분이 공용인 경우 필수입력
    IF gs_outtab-comm EQ 'X'.
      IF gs_outtab-paswd IS INITIAL.
        pv_error = 'X'.
        MESSAGE i003 DISPLAY LIKE 'E'
           WITH '공용의 경우 비밀번호는 필수입력입니다.'.
        EXIT.
      ENDIF.
    ENDIF.
    ADD 1 TO lv_cnt.
  ENDLOOP.

  IF lv_cnt EQ 0 AND pv_error NE 'X'.
    MESSAGE i003 DISPLAY LIKE 'E'
       WITH '저장할 데이터가 존재하지 않습니다.'.
    pv_error = 'X'.
    EXIT.
  ENDIF.

ENDFORM.                    " DATA_CHECK

*&---------------------------------------------------------------------*
*&      Form  DATA_SAVE_ZNFT1090
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_save_znft1090 USING pv_error.

  DATA: ls_znft1090 TYPE znft1090,
        lt_znft1090 LIKE TABLE OF ls_znft1090.

  DATA: BEGIN OF ls_znft1090d,
          bukrs   LIKE znft1090-bukrs ,
          congb   LIKE znft1090-congb ,
          consq   LIKE znft1090-consq ,
          pernr   LIKE znft1090-pernr ,
          bukrs_b LIKE znft1090-bukrs ,
          congb_b LIKE znft1090-congb ,
          consq_b LIKE znft1090-consq ,
          pernr_b LIKE znft1090-pernr ,
        END OF ls_znft1090d.
  DATA: lt_znft1090d LIKE TABLE OF ls_znft1090d.

  CLEAR gs_outtab.
  LOOP AT gt_outtab INTO gs_outtab WHERE stats NE space.
    MOVE-CORRESPONDING gs_outtab TO ls_znft1090.
    IF gs_outtab-stats EQ 'I'.
      ls_znft1090-erdat = sy-datlo.
      ls_znft1090-erzet = sy-timlo.
      ls_znft1090-ernam = sy-uname.
      ls_znft1090-aedat = sy-datlo.
      ls_znft1090-aezet = sy-timlo.
      ls_znft1090-aenam = sy-uname.
    ELSE.
      ls_znft1090-aedat = sy-datlo.
      ls_znft1090-aezet = sy-timlo.
      ls_znft1090-aenam = sy-uname.
    ENDIF.
    APPEND ls_znft1090  TO lt_znft1090.

    MOVE-CORRESPONDING gs_outtab TO ls_znft1090d.
    APPEND ls_znft1090d TO lt_znft1090d.

    CLEAR : gs_outtab, ls_znft1090, ls_znft1090d.
  ENDLOOP.

  IF sy-subrc EQ 0.
    IF lt_znft1090d IS NOT INITIAL.
      LOOP AT lt_znft1090d INTO ls_znft1090d.
*       Primary Key 값이 변경된 경우 ( CONGB, CONSQ, PERNR ) 삭제
        IF ( ls_znft1090d-bukrs NE ls_znft1090d-bukrs_b ) OR
           ( ls_znft1090d-congb NE ls_znft1090d-congb_b ) OR
           ( ls_znft1090d-consq NE ls_znft1090d-consq_b ) OR
           ( ls_znft1090d-pernr NE ls_znft1090d-pernr_b ).
          DELETE FROM znft1090
           WHERE bukrs EQ ls_znft1090d-bukrs_b
             AND congb EQ ls_znft1090d-congb_b
             AND consq EQ ls_znft1090d-consq_b
             AND pernr EQ ls_znft1090d-pernr_b.
        ENDIF.
      ENDLOOP.
      MODIFY znft1090 FROM TABLE lt_znft1090.
    ENDIF.
    COMMIT WORK.
  ELSE.
    ROLLBACK WORK.
    pv_error = 'X'.
    CLEAR pv_error.
  ENDIF.

ENDFORM.                    " DATA_SAVE_ZNFT1090
*&---------------------------------------------------------------------*
*&      Form  CHECK_LVORM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_lvorm USING pv_error.

  CLEAR: s_lvorm, s_lvorm[].

  IF p_chk01 IS INITIAL AND p_chk02 IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E'
       WITH '삭제여부를 체크하십시오'.
    pv_error = 'X'.
    EXIT.
  ENDIF.

  IF p_chk01 EQ 'X'.
    s_lvorm-low    = 'X'.
    s_lvorm-high   = ''.
    s_lvorm-sign   = 'I'.
    s_lvorm-option = 'EQ'.
    APPEND s_lvorm.
  ENDIF.

  IF p_chk02 EQ 'X'.
    s_lvorm-low    = ''.
    s_lvorm-high   = ''.
    s_lvorm-sign   = 'I'.
    s_lvorm-option = 'EQ'.
    APPEND s_lvorm.
  ENDIF.

ENDFORM.                    " CHECK_LVORM
*&---------------------------------------------------------------------*
*&      Form  GET_CONTX_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_OUTTAB_BUKRS  text
*      -->P_GS_OUTTAB_CONGB  text
*      -->P_GS_OUTTAB_CONSQ  text
*      -->P_GS_OUTTAB_CONTX  text
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM get_contx_desc  USING   pv_bukrs
                             pv_congb
                             pv_consq
                             pv_contx
                             pv_error.


  CLEAR:  pv_error, pv_contx.

  SELECT SINGLE contx INTO pv_contx
    FROM znft1092
   WHERE bukrs EQ pv_bukrs
     AND congb EQ pv_congb
     AND consq EQ pv_consq.

  IF sy-subrc NE 0 AND pv_contx IS INITIAL.
    pv_error = 'X'.
  ENDIF.

ENDFORM.                    " GET_CONTX_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_CONSQ_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_OUTTAB_BUKRS  text
*      -->P_GS_OUTTAB_CONGB  text
*      -->P_GS_OUTTAB_CONSQ  text
*      -->P_GS_OUTTAB_CONTX  text
*----------------------------------------------------------------------*
FORM get_consq_text  USING    pv_bukrs
                              pv_congb
                              pv_consq
                              pv_contx.

  CLEAR pv_contx.

  SELECT SINGLE contx INTO pv_contx
    FROM znft1092
   WHERE bukrs EQ pv_bukrs
     AND congb EQ pv_congb
     AND consq EQ pv_consq.

ENDFORM.                    " GET_CONSQ_TEXT
*&---------------------------------------------------------------------*
*&      Form  ALV_EVENT_DATA_CHG_FINISHED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ALV_EVENT_DATA_CHG_FINISHED USING E_MODIFIED
                                       ET_GOOD_CELLS TYPE LVC_T_MODI.
  DATA: LS_GOOD_CELLS TYPE LVC_S_MODI.

  DATA: LV_CNT      TYPE I.

  LOOP AT ET_GOOD_CELLS INTO LS_GOOD_CELLS.
    CASE LS_GOOD_CELLS-FIELDNAME.
      WHEN 'PASWD'.
        READ TABLE GT_OUTTAB INTO GS_OUTTAB INDEX LS_GOOD_CELLS-ROW_ID.
        IF SY-SUBRC = 0.
          IF GS_OUTTAB-PASWD CN GC_PWCHAR.
            MESSAGE I003 DISPLAY LIKE 'E'
               WITH '비밀번호는 영문자와 숫자만'
                    '사용하시기 바랍니다.'.

            CLEAR : GS_OUTTAB-PASWD.
          ELSE.
            LV_CNT = STRLEN( GS_OUTTAB-PASWD ).

            IF LV_CNT < 6.
              MESSAGE I003 DISPLAY LIKE 'E'
                 WITH '비밀번호는 6자리 이상으로'
                      '입력하시기 바랍니다.'.

              CLEAR : GS_OUTTAB-PASWD.
            ENDIF.
          ENDIF.

          MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LS_GOOD_CELLS-ROW_ID
                           TRANSPORTING PASWD.
        ENDIF.

    ENDCASE.
  ENDLOOP.

ENDFORM.                    " ALV_EVENT_DATA_CHG_FINISHED
