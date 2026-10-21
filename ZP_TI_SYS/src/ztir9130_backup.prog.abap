************************************************************************
* Title         :  ZTIR9130                                            *
*                                                                      *
* Description   : [Report] B/L  관련비용 관리                          *
*                                                                      *
* Creation Date : 2004/02/14                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*                                                                      *
* Inputs        :                                                      *
*                                                                      *
* Outputs       :                                                      *
*                                                                      *
************************************************************************
*                                                                      *
* Processing Steps:                                                    *
* 1.                                                                   *
* 2.                                                                   *
*                                                                      *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* dd-mmm-yyyy  xxxxxxxxxxxxxxx  DVPK9xxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  *
*                                                                      *
*                                                                      *
************************************************************************
REPORT  ztir9130       MESSAGE-ID zmti00
                       NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis,   "> Globale Type(ALV)
            kkblo.  "> Generic list types

TYPES:  BEGIN OF ty_list.
        INCLUDE STRUCTURE ztisblcs.
TYPES : celltab TYPE lvc_t_styl.            " Cell단위 수정 스타일
TYPES:  END   OF ty_list.

************************************************************************
* SAP Include Define                                                   *
************************************************************************
INCLUDE : <icon>,
          <symbol>,
          zts_reuse_bdc_subroutine_f00.
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: l_yn    type c.
INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

*---------------------------------------------------------------------*
*> Message dialog box용                                               *
*---------------------------------------------------------------------*
DATA: BEGIN OF it_msg  OCCURS 0.
        INCLUDE STRUCTURE ztismessage.
DATA: END   OF it_msg.

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: ztitcsk,
        ztisscrcom,
        ztitcso, ">one time vendor.
        icon.

TABLES: t001,
        t005,
        lfa1,
       *lfa1,
        ztitig00,     ">[TraSys] 회사별 프로세스 정의.
        ztitig07,     ">[TraSys]  제비용 일괄전기 Default Value관리.
        vf_kred,
        ztitrqk,
        ztitrqs,
        ztitcsp,
        ztivcs00,
        ztitig06,
        ztitblk,
        ztitblp,
        ztivbl00,
        ztisblcs.

TABLES: bapi1093_0,
        bapicurx,
        bapiret1.

************************************************************************
* SAP Views                                                            *
************************************************************************
TABLES: ztivip01.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
** 진로산업 Change 2007/04 --------------------------------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
** 진로산업 Change 2007/04 --------------------------------------
    c_tcode     LIKE sy-tcode       VALUE 'ZTIR913'.
************************************************************************
* Internal Tables                                                      *
************************************************************************
*> Select용.
DATA: it_list  TYPE STANDARD TABLE OF ty_list,
      it_seld  TYPE STANDARD TABLE OF ty_list,
      it_temp  TYPE STANDARD TABLE OF ty_list,
      gs_list  TYPE ty_list.

DATA: BEGIN OF it_vendor  OCCURS 2,
      lifnr    TYPE lifnr,
      END   OF it_vendor.

*> 비용코드.
DATA: BEGIN OF it_ztitig06  OCCURS 2.
        INCLUDE STRUCTURE ztisig06.
DATA: END   OF it_ztitig06.

*> 수취인 HELP용.
DATA : dynprog  LIKE sy-repid,
       dynnr    LIKE sy-dynnr,
       g_window_title(60),
       g_display.

DATA : BEGIN OF xlfza OCCURS 0,
       lifnr   LIKE lfza-lifnr,
       bukrs   LIKE lfza-bukrs,
       empfk   LIKE lfza-empfk,
       name1   LIKE lfa1-name1.
DATA : END   OF xlfza.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
* Fieldcatalog Grid
DATA: it_fieldcat_g TYPE lvc_t_fcat,
      gs_fieldcat_g LIKE LINE OF it_fieldcat_g.

*icon
DATA: g_lights_name TYPE lvc_cifnm VALUE 'ICON'.

* Button exclude.
DATA : it_exclude   TYPE ui_functions.

* Layout GRID.
DATA: gs_layout_g   TYPE lvc_s_layo.
DATA: gs_stable     TYPE lvc_s_stbl.

* PRINT GRID.
DATA:  gs_print_g   TYPE lvc_s_prnt.
DATA : gs_sort_g    TYPE lvc_s_sort.
DATA : it_sort_g    TYPE lvc_t_sort.
DATA : gs_filter_g  TYPE lvc_s_filt.
DATA : it_filter_g  TYPE lvc_t_filt.
DATA:  gs_f4        TYPE lvc_s_f4.      " F4 필드 관련
DATA:  it_f4        TYPE lvc_t_f4.
DATA:  ws_f4        TYPE ddshretval.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
DATA: custom_container TYPE REF TO cl_gui_custom_container,
      g_grid           TYPE REF TO cl_gui_alv_grid.

DATA: g_repid             LIKE sy-repid.

DATA: gs_variante         LIKE disvariant,
      gs_def_variante     LIKE disvariant,
      g_variant_exit(1)   TYPE c,
      g_variant_save(1)   TYPE c,
      g_variant_def(1)    TYPE c.

DATA: g_tabix             LIKE sy-tabix,
      g_index             LIKE sy-index,
      g_subrc             LIKE sy-subrc,
      g_answer            TYPE c,
      g_process           TYPE c,
      g_count             TYPE i,
      g_cnt               TYPE i,
      g_wrbtr             TYPE wrbtr,
      g_wmwst             TYPE wmwst,
      g_fwbas             TYPE fwbas,
      ok_code             LIKE sy-ucomm,
      g_success           TYPE i,
      g_error             TYPE i,
      g_line              TYPE i,
      g_linen(3)          TYPE n,
      g_out_text(70)      TYPE c.
DATA: ok-code             LIKE sy-datum.

* Possible Entry
DATA : it_values TYPE TABLE OF seahlpres,
       it_fields TYPE TABLE OF dfies,
       gs_value  TYPE seahlpres,
       gs_field  TYPE dfies,

*       ls_f4     TYPE ddshretval,
       gs_modi   TYPE lvc_s_modi.

* define fields and field-symbols for data-update
FIELD-SYMBOLS : <f4tab> TYPE lvc_t_modi.

* POSSIBLE ENTRY HEADER TEXT
DATA : BEGIN OF it_field_tab OCCURS 0.
        INCLUDE STRUCTURE dfies.
DATA : END OF it_field_tab.

CLASS lcl_event_receiver DEFINITION DEFERRED.

DATA: event_receiver TYPE REF TO lcl_event_receiver.

************************************************************************
* CLASSES: Definition                                                  *
************************************************************************
CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_hotspot_click
         FOR EVENT hotspot_click OF cl_gui_alv_grid
              IMPORTING e_row_id
                        e_column_id
                        es_row_no,

      handle_data_changed
         FOR EVENT data_changed OF cl_gui_alv_grid
             IMPORTING er_data_changed,

      handle_data_changed_finished
          FOR EVENT data_changed_finished OF cl_gui_alv_grid
              IMPORTING e_modified sender,

      handle_double_click
           FOR EVENT double_click OF cl_gui_alv_grid
               IMPORTING e_row e_column,

      handle_button_click
           FOR EVENT button_click OF cl_gui_alv_grid
               IMPORTING es_col_id es_row_no,

      handle_user_command
           FOR EVENT user_command OF cl_gui_alv_grid
               IMPORTING e_ucomm,

      handle_before_user_command
            FOR EVENT before_user_command OF cl_gui_alv_grid
                IMPORTING e_ucomm,

      handle_after_user_command
            FOR EVENT after_user_command OF cl_gui_alv_grid
                IMPORTING e_ucomm,

      handle_context_menu_request
           FOR EVENT context_menu_request OF cl_gui_alv_grid
               IMPORTING e_object,

      handle_toolbar
           FOR EVENT toolbar OF cl_gui_alv_grid
               IMPORTING e_object e_interactive,
*               IMPORTING sender e_object e_interactive,

      handle_print_top_of_page
           FOR EVENT print_top_of_page OF cl_gui_alv_grid,

      handle_print_top_of_list
           FOR EVENT print_top_of_list OF cl_gui_alv_grid,

      handle_print_end_of_page
           FOR EVENT print_end_of_page OF cl_gui_alv_grid,

      handle_print_end_of_list
           FOR EVENT print_end_of_list OF cl_gui_alv_grid,

      handle_top_of_page
           FOR EVENT top_of_page OF cl_gui_alv_grid
               IMPORTING e_dyndoc_id,

      handle_end_of_list
           FOR EVENT end_of_list OF cl_gui_alv_grid
               IMPORTING e_dyndoc_id,

      handle_on_f4 FOR EVENT onf4 OF cl_gui_alv_grid
       IMPORTING sender
                 e_fieldname
                 e_fieldvalue
                 es_row_no
                 er_event_data
                 et_bad_cells
                 e_display.

    TYPES : ddshretval_table TYPE TABLE OF ddshretval.

    METHODS : handle_my_f4
          IMPORTING sender         TYPE REF TO cl_gui_alv_grid
                    et_bad_cells   TYPE lvc_t_modi
                    es_row_no      TYPE lvc_s_roid
                    er_event_data  TYPE REF TO cl_alv_event_data
                    e_display      TYPE c
                    e_fieldname    TYPE lvc_fname
          EXPORTING gt_f4          TYPE ddshretval_table.

ENDCLASS.                    "lcl_event_receiver DEFINITION

************************************************************************
* CLASSES: IMPLEMENTATION                                              *
************************************************************************
CLASS lcl_event_receiver IMPLEMENTATION.

  METHOD handle_hotspot_click.
    PERFORM handle_hotspot_click IN PROGRAM (g_repid)
                                 USING e_row_id e_column_id.
  ENDMETHOD.                    "hotspot_click

  METHOD handle_data_changed.
    PERFORM handle_data_changed IN PROGRAM (g_repid)
                                USING er_data_changed.
  ENDMETHOD.                    "handle_data_changed

  METHOD handle_data_changed_finished.
    PERFORM  handle_data_changed_finished IN PROGRAM (g_repid)
                  USING e_modified sender.
  ENDMETHOD.                    "handle_data_changed_finished

  METHOD handle_double_click.
    PERFORM  handle_double_click IN PROGRAM (g_repid)
                                 USING e_row e_column.
  ENDMETHOD.                    "handle_double_click

  METHOD handle_button_click.
    PERFORM  handle_button_click IN PROGRAM (g_repid)
                                 USING es_col_id es_row_no.
  ENDMETHOD.                    "handle_button_click

  METHOD handle_user_command.
    PERFORM  handle_user_command_grid IN PROGRAM (g_repid)
                                      USING e_ucomm.
  ENDMETHOD.                    "handle_user_command

  METHOD handle_before_user_command.
    PERFORM  handle_before_user_comm IN PROGRAM (g_repid)
                                     USING e_ucomm.
  ENDMETHOD.                    "handle_before_user_command

  METHOD handle_after_user_command.
    PERFORM  handle_after_user_comm IN PROGRAM (g_repid)
                                    USING e_ucomm.
  ENDMETHOD.                    "handle_after_user_command

  METHOD handle_context_menu_request.
    PERFORM  handle_context_menu IN PROGRAM (g_repid)
                                 USING e_object.
  ENDMETHOD.                    "handle_context_menu_request

  METHOD handle_toolbar.
    PERFORM  handle_toolbar IN PROGRAM (g_repid)
*                            USING e_object.
                            USING  e_object e_interactive.
  ENDMETHOD.                    "handle_toolbar

  METHOD handle_print_top_of_page.
    PERFORM  handle_print_top_of_page IN PROGRAM (g_repid).
  ENDMETHOD.                    "handle_print_top_of_page

  METHOD handle_print_top_of_list.
    PERFORM  handle_print_top_of_list IN PROGRAM (g_repid).
  ENDMETHOD.                    "handle_print_top_of_list

  METHOD handle_print_end_of_page.
    PERFORM  handle_print_end_of_page IN PROGRAM (g_repid).
  ENDMETHOD.                    "handle_print_end_of_page

  METHOD handle_print_end_of_list.
    PERFORM  handle_print_end_of_list IN PROGRAM (g_repid).
  ENDMETHOD.                    "handle_print_end_of_list

  METHOD handle_top_of_page.
    PERFORM  handle_top_of_page IN PROGRAM (g_repid)
                       USING e_dyndoc_id.
  ENDMETHOD.                    "handle_top_of_page

  METHOD handle_end_of_list.
    PERFORM  handle_end_of_list IN PROGRAM (g_repid)
                       USING e_dyndoc_id.
  ENDMETHOD.                    "handle_end_of_list

  METHOD handle_on_f4.
    PERFORM handle_on_f4 IN PROGRAM (g_repid)
                       USING sender
                             e_fieldname
                             e_fieldvalue
                             es_row_no
                             er_event_data
                             et_bad_cells
                             e_display.
  ENDMETHOD.                    "handle_on_f4

  METHOD handle_my_f4.
    PERFORM handle_my_f4 IN PROGRAM (g_repid)
                        TABLES gt_f4
                        USING sender
                              et_bad_cells
                              es_row_no
                              er_event_data
                              e_display
                              e_fieldname.
  ENDMETHOD.                    "handle_my_f4

ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK dbsel WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_bukrs  FOR ztitrqk-bukrs                "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk
                    MODIF  ID iog ,
  s_ekorg  FOR ztitblk-ekorg MODIF ID iog,  "구매조직.
  s_ekgrp  FOR ztitblk-ekgrp MODIF ID iog,  "구매그룹.
  s_iblno  FOR ztitblk-iblno MODIF ID iog	   "B/L 관리번호.
                              MEMORY ID ztiiblno,
  s_blnum  FOR ztitblk-blnum MODIF ID iog,  "B/L 번호.
  s_bldty  FOR ztitblk-bldty MODIF ID iog,  "문서종류.
  s_rptty  FOR ztitblk-rptty MODIF ID iog,  "수입신고구분.
  s_lifnr  FOR ztitblk-lifnr MODIF ID iog,  "공급업체 계정번호.
  s_bletd  FOR ztitblk-bletd MODIF ID iog,  "ETD(출발 예정 시각).
  s_bleta  FOR ztitblk-bleta MODIF ID iog,  "ETA(도착 예정 시각).
  s_fwdty  FOR ztitblk-fwdty MODIF ID iog,  "운송 방법.
  s_lponr  FOR ztitblk-lponr MODIF ID iog,  "최종품목번호.
  s_waers  FOR ztitblk-waers MODIF ID iog,  "통화키.
  s_cnam   FOR ztitrqs-cnam  MODIF ID iog,  "작성인.
  s_cdat   FOR ztitrqs-cdat  MODIF ID iog,  "생성일.
  s_unam   FOR ztitrqs-unam  MODIF ID iog,  "최종변경인.
  s_udat   FOR ztitrqs-udat  MODIF ID iog.  "변경일.
SELECTION-SCREEN ULINE.

PARAMETERS: p_step1 RADIOBUTTON GROUP ab1 DEFAULT 'X',
            p_step2 RADIOBUTTON GROUP ab1,
            p_step3 RADIOBUTTON GROUP ab1.
SELECTION-SCREEN END OF BLOCK dbsel.

SELECTION-SCREEN BEGIN OF BLOCK lists WITH FRAME TITLE text-002.
PARAMETERS: p_vari LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK lists.

************************************************************************
* INITIALIZATION Event                                                 *
************************************************************************
INITIALIZATION.
*> Read default layout (description only, w/o field catalog)
  PERFORM p1000_alv_fields_initial.
*> Initializaton By Program
  PERFORM p1001_initialization.

************************************************************************
* AT SELECTION-SCREEN Events                                           *
************************************************************************
AT SELECTION-SCREEN.
*> 사용자 Input values Check
  PERFORM p1101_check_input_value.
*> 사용자 레이아웃 Input values Check
  PERFORM p1101_check_variant_value.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM p1102_authorization_check USING s_bukrs-low.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*> 레이아웃 HELP
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM p1102_f4_for_variant.

************************************************************************
* START-OF-SELECTION Event                                             *
************************************************************************
START-OF-SELECTION.
  CHECK g_answer EQ 'Y'.
*> 검색조건에 해당하는 데이타를 Select.
  PERFORM p2000_data_selections.

************************************************************************
* END-OF-SELECTION Event                                               *
************************************************************************
END-OF-SELECTION.
  CHECK g_answer EQ 'Y'.
  DESCRIBE TABLE it_list LINES g_line.
  IF NOT g_line IS INITIAL.
*> PROGRESS Display.
    g_linen    = 90.
    g_out_text = '리스트를 구성 중입니다 %99999%%'(p03).
    REPLACE '%99999%'(p99) WITH g_linen INTO g_out_text.
    PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.

*> Dynamic Data Table build
    PERFORM p3000_field_category_build.
    PERFORM p3210_exclude_table_build   USING 'IT_EXCLUDE'.
    PERFORM p3500_sort_table_build .
    PERFORM p3700_layout_build.
    PERFORM p3800_field_attribute_change.
    CALL SCREEN 0100.
  ENDIF.

************************************************************************
* TOP-OF-PAGE Event                                                    *
************************************************************************
TOP-OF-PAGE.
************************************************************************
* END-OF-PAGE Event                                                    *
************************************************************************
END-OF-PAGE.
************************************************************************
* TOP-OF-PAGE DURING LINE-SELECTION Event                              *
************************************************************************
TOP-OF-PAGE DURING LINE-SELECTION.
************************************************************************
* AT LINE-SELECTION Event                                              *
************************************************************************
AT LINE-SELECTION.
************************************************************************
* AT USER-COMMAND Event                                                *
************************************************************************
AT USER-COMMAND.

************************************************************************
*                                                                      *
* S U B R O U T I N E S                                                *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  p1000_alv_fields_initial
*&---------------------------------------------------------------------*
FORM p1000_alv_fields_initial.

  CLEAR: gs_variante, gs_def_variante.

  MOVE sy-repid TO : g_repid ,
                     gs_variante-report,
                     gs_def_variante-report.

  CALL FUNCTION 'LVC_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = g_variant_save
    CHANGING
      cs_variant = gs_def_variante
    EXCEPTIONS
      not_found  = 2.

  IF sy-subrc = 0 .
    p_vari = gs_def_variante-variant.
  ENDIF.

ENDFORM.                    " p1000_alv_fields_initial
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
FORM p1001_initialization .

  SET TITLEBAR 'T1000'.

*  GET PARAMETER ID 'BUK' FIELD s_bukrs-low.
*  s_bukrs-sign = 'I'.
*  s_bukrs-option = 'EQ'.
*  IF NOT s_bukrs-low IS INITIAL.
*    APPEND s_bukrs.
*  ENDIF.

  CLEAR: g_answer.

ENDFORM.                    " p1001_initialization
*&---------------------------------------------------------------------*
*&      Form  p1101_check_variant_value
*&---------------------------------------------------------------------*
FORM p1101_check_variant_value .

  CHECK g_answer EQ 'Y'.

  IF NOT p_vari IS INITIAL.
    MOVE gs_variante TO gs_def_variante.
    MOVE p_vari TO gs_def_variante-variant.
    CALL FUNCTION 'LVC_VARIANT_EXISTENCE_CHECK'
      EXPORTING
        i_save        = g_variant_save
      CHANGING
        cs_variant    = gs_def_variante
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        program_error = 3
        OTHERS        = 4.
    IF sy-subrc <> 0 AND NOT p_vari IS INITIAL.
      MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    IF p_vari IS INITIAL.
      CLEAR gs_variante-variant.
    ELSE.
      gs_variante-variant = p_vari.
    ENDIF.

  ELSE.
    CLEAR gs_variante.
    gs_variante-report = g_repid.
  ENDIF.

ENDFORM.                    " p1101_check_variant_value
*&---------------------------------------------------------------------*
*&      Form  p1102_f4_for_variant
*&---------------------------------------------------------------------*
FORM p1102_f4_for_variant .

  CLEAR gs_variante.
  MOVE g_repid TO gs_variante-report.

  CALL FUNCTION 'LVC_VARIANT_F4'
    EXPORTING
      is_variant = gs_variante
      i_save     = g_variant_save
    IMPORTING
      e_exit     = g_variant_exit
      es_variant = gs_def_variante
    EXCEPTIONS
      not_found  = 1
      OTHERS     = 2.

  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF g_variant_exit = space.
      p_vari = gs_def_variante-variant.
    ENDIF.
  ENDIF.

ENDFORM.                    " p1102_f4_for_variant
*&---------------------------------------------------------------------*
*&      Form  P3000_field_category_build
*&---------------------------------------------------------------------*
FORM p3000_field_category_build .

  DATA ls_fcat TYPE lvc_s_fcat.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZTISBLCS'
      i_internal_tabname     = 'IT_LIST'
*      i_client_never_display = 'X'
    CHANGING
      ct_fieldcat            = it_fieldcat_g[].

  LOOP AT it_fieldcat_g INTO gs_fieldcat_g.
    CLEAR: gs_fieldcat_g-key.
    CASE gs_fieldcat_g-fieldname.
      WHEN 'ICON'.
        gs_fieldcat_g-key       = 'X'.
        gs_fieldcat_g-coltext   = '전기'.
        gs_fieldcat_g-col_opt   = 'X'.
*      WHEN 'IBLNO'.
*        gs_fieldcat_g-key       = 'X'.
      WHEN 'BLNUM'.
        gs_fieldcat_g-key       = 'X'.
        gs_fieldcat_g-hotspot   = 'X'.
        gs_fieldcat_g-col_opt   = 'X'.
      WHEN 'BLDTX'.
        gs_fieldcat_g-coltext   = '유형'.
        gs_fieldcat_g-col_opt   = 'X'.
*      WHEN 'RPTTX'.
*        gs_fieldcat_g-coltext   = '보세운송'.
*        gs_fieldcat_g-col_opt   = 'X'.
*      WHEN 'PSPNR'.
*        gs_fieldcat_g-hotspot   = 'X'.
*        gs_fieldcat_g-just      = 'L'.
      WHEN 'EXPCD' OR 'EXPTX'.
        gs_fieldcat_g-col_opt   = 'X'.
      WHEN 'EBELN'.
        gs_fieldcat_g-col_opt   = 'X'.
      WHEN 'BLCNT'.
        gs_fieldcat_g-col_opt   = 'X'.
      WHEN 'WRBTR' OR 'WMWST' OR 'FWBAS'.
        gs_fieldcat_g-do_sum     = 'X'.
        gs_fieldcat_g-edit       = 'X'.
        gs_fieldcat_g-col_opt   = space.
        gs_fieldcat_g-outputlen = 10.
      WHEN 'MWSKZ'.
*        gs_fieldcat_g-checktable = '!'.
        gs_fieldcat_g-edit       = 'X'.
        gs_fieldcat_g-col_opt    = 'X'.
        gs_fieldcat_g-f4availabl = 'X'.
      WHEN 'BUPLA'.
        gs_fieldcat_g-no_out    = 'X'.
      WHEN 'NAME'.
        gs_fieldcat_g-outputlen = 18.
        gs_fieldcat_g-coltext   = '사업장'.
      WHEN 'WRBTRA' OR  'WMWSTA' OR 'FWBASA'.
*        gs_fieldcat_g-COL_OPT   = SPACE.
      WHEN 'ICSNO'  OR 'BELNR'  OR
           'HWAER'  OR 'WAERSA'.
        gs_fieldcat_g-col_opt   = space.
      WHEN OTHERS.
        gs_fieldcat_g-no_out = 'X'.
    ENDCASE.
    MODIFY it_fieldcat_g FROM gs_fieldcat_g.
  ENDLOOP.

ENDFORM.                    " P3000_field_category_build
*&---------------------------------------------------------------------*
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
FORM p2000_data_selections .

*> PROGRESS Display.
  g_linen    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_linen INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.

*> 수입의뢰 데이타 select.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_temp
    FROM ztitblk AS k
   INNER JOIN j_1bbranch AS b
      ON k~bukrs EQ b~bukrs
     AND k~bupla EQ b~branch
   INNER JOIN J_1BBRANCHT AS C
      ON B~BUKRS      EQ C~BUKRS
     AND B~BRANCH     EQ C~BRANCH
     AND B~BUPLA_TYPE EQ C~BUPLA_TYPE
   WHERE k~bukrs  IN  s_bukrs     "회사코드.
     AND k~iblno  IN  s_iblno
     AND k~blnum  IN  s_blnum
     AND k~bldty  IN  s_bldty
     AND k~rptty  IN  s_rptty
     AND k~ekorg  IN  s_ekorg
     AND k~ekgrp  IN  s_ekgrp
     AND k~lifnr  IN  s_lifnr
     AND k~bletd  IN  s_bletd
     AND k~bleta  IN  s_bleta
     AND k~fwdty  IN  s_fwdty
     AND k~lponr  IN  s_lponr
     AND k~waers  IN  s_waers
     AND k~cnam   IN  s_cnam
     AND k~cdat   IN  s_cdat
     AND k~unam   IN  s_unam
     AND k~udat   IN  s_udat.

  IF sy-subrc NE 0.
    MESSAGE s902.   EXIT.
  ENDIF.

  REFRESH: it_list.
  LOOP AT it_temp INTO gs_list.

    PERFORM get_domain_value_text(ztir0000)  USING  'ZTIBLDTY'
                                                gs_list-bldty
                                                gs_list-bldtx.


    PERFORM get_domain_value_text(ztir0000)  USING  'ZTIRPTTY'
                                                gs_list-rptty
                                                gs_list-rpttx.

*> 대표 PO
    SELECT ebeln
      INTO gs_list-ebeln
      FROM ztitblp UP TO 1 ROWS
     WHERE iblno  EQ  gs_list-iblno.
    ENDSELECT.

*>  선택한 비용코드를 추가함.
    LOOP AT it_ztitig06 WHERE box = 'X'.
*> 계산절차.
      MOVE t005-kalsm  TO  gs_list-kalsm.
*> 통화단위.
      MOVE t001-waers  TO  gs_list-hwaer.

      MOVE: it_ztitig06-expcd  TO  gs_list-expcd,
            it_ztitig06-exptx  TO  gs_list-exptx,
            it_ztitig06-rsbtr  TO  gs_list-wrbtr,
            it_ztitig06-mwskz  TO  gs_list-mwskz,
            it_ztitig06-cstcl  TO  gs_list-cstcl.

      CLEAR: ztivcs00.
      SELECT *
        FROM ztivcs00 UP TO 1 ROWS
       WHERE bukrs   EQ  t001-bukrs
         AND expgr   EQ  it_ztitig06-expgr
         AND expcd   EQ  it_ztitig06-expcd
         AND refno   EQ  gs_list-iblno.
      ENDSELECT.

      IF sy-subrc EQ 0.
        IF p_step1 EQ 'X'.
          CONTINUE.
        ENDIF.
*> 비용문서 MOVE
        MOVE :
          ztivcs00-icsno  TO gs_list-icsno,  "수입비용 문서번호
          ztivcs00-icssq  TO gs_list-icssq,  "비용문서의 품목
          ztivcs00-belnr  TO gs_list-belnr,  "회계전표번호
          ztivcs00-gjahr  TO gs_list-gjahr,  "회계연도
          ztivcs00-monat  TO gs_list-monat,  "회계기간
          ztivcs00-wrbtr  TO gs_list-wrbtra, "전표통화금액
          ztivcs00-waers  TO gs_list-waersa, "통화키
          ztivcs00-wmwst  TO gs_list-wmwsta, "전표통화세액
          ztivcs00-fwbas  TO gs_list-fwbasa, "전표통화과세표준액
          ztivcs00-livst  TO gs_list-livst,  "송장처리 상태
          ztivcs00-wrbtr  TO gs_list-wrbtr,  "전표통화금액
          ztivcs00-waers  TO gs_list-hwaer,  "통화키
          ztivcs00-wmwst  TO gs_list-wmwst,  "전표통화세액
          ztivcs00-fwbas  TO gs_list-fwbas,  "전표통화과세표준액
          ztivcs00-livst  TO gs_list-livst,  "송장처리 상태
          ztivcs00-mwskz  TO gs_list-mwskz,  "세금코드.
          ztivcs00-kursf  TO gs_list-kursf.  "환율
*          ZTIvcs00-MONCT  to gs_list-MONCT,  "개월수
*          ZTIvcs00-BGNDT  to gs_list-BGNDT,  "시작일자
*          ZTIvcs00-EXPDT  to gs_list-EXPDT.  "만기일자
      ELSE.
        IF p_step2 EQ 'X'.
          CONTINUE.
        ENDIF.
        CLEAR ztivcs00.
      ENDIF.

*> 기존처리된 비용여부 판단.
      CASE gs_list-livst.
        WHEN 'P'.
          gs_list-icon = icon_green_light.
        WHEN 'N'.
          gs_list-icon = icon_yellow_light.
        WHEN OTHERS.
          gs_list-icon = icon_red_light.
      ENDCASE.

      APPEND gs_list TO it_list.
    ENDLOOP.
  ENDLOOP.
*
  DESCRIBE TABLE it_list LINES g_line.
  IF g_line EQ 0.
    MESSAGE s902.   EXIT.
  ENDIF.

ENDFORM.                    " p2000_data_selections
*&---------------------------------------------------------------------*
*&      Form  3010_insert_field_category
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 3010_insert_field_category  USING  p_section
                                        p_fname
                                        p_value.

  DATA l_col(40).
  FIELD-SYMBOLS <l_fs>.

  IF p_section = 'S'.
    CLEAR gs_fieldcat_g.
  ENDIF.

* 속성 MOVE
  CONCATENATE 'GS_FIELDCAT_G-' p_fname  INTO l_col.

  ASSIGN      (l_col)         TO       <l_fs>.
  MOVE         p_value        TO       <l_fs>.

  IF p_section = 'E'.
    INSERT gs_fieldcat_g INTO it_fieldcat_g INDEX 1.
  ENDIF.
*  IF p_section = 'E'.
*    APPEND gs_fieldcat_g TO it_fieldcat_g.
*  ENDIF.
ENDFORM.                    " 3010_insert_field_category


*&---------------------------------------------------------------------*
*&      Module  pbo_scr0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_scr0100 OUTPUT.

  SET PF-STATUS 'STATUS100'.
  SET TITLEBAR  'T1000'.

  PERFORM create_and_init_controls_0100.

ENDMODULE.                 " pbo_scr0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  create_and_init_controls_0100
*&---------------------------------------------------------------------*
FORM create_and_init_controls_0100 .

  IF custom_container IS INITIAL.
*   create a custom container control for our alv control
    CREATE OBJECT custom_container
        EXPORTING
            container_name = 'CUSTOMER_CONTAINER_0100'.

*   Create an Instance of ALV Control
    CREATE OBJECT g_grid
          EXPORTING i_parent      = custom_container.

    CALL METHOD g_grid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_g
        is_variant           = gs_variante
        it_toolbar_excluding = it_exclude
        is_print             = gs_print_g
        i_save               = 'A'   " 전체가능유형.
*                                       'U'   " 특정사용자전용.
*                                       'X'   " 광역 전용.
*                                       ' '   " 저장안함.
*                 i_default            = 'X'   " 레이아웃 사전셋팅 허용.
*  LAYOUT   Standard   BCALV_GRID_09  참조.
*  is_variant 레이아웃선택/변경/저장/관리 enable
      CHANGING
        it_sort             = it_sort_g
        it_filter           = it_filter_g
        it_fieldcatalog     = it_fieldcat_g[]
        it_outtab           = it_list.

    CALL METHOD cl_gui_control=>set_focus
      EXPORTING
        control = g_grid.

* set editable cells to ready for input
    CALL METHOD g_grid->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.

*?.Optionally register ENTER to raise event DATA_CHANGED.
*   (Per default the user may check data by using the check icon).
    CALL METHOD g_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter.

    CREATE OBJECT event_receiver.

    SET HANDLER :
          event_receiver->handle_toolbar               FOR g_grid,
          event_receiver->handle_double_click          FOR g_grid,
          event_receiver->handle_hotspot_click         FOR g_grid,
          event_receiver->handle_user_command          FOR g_grid,
          event_receiver->handle_data_changed_finished FOR g_grid,
          event_receiver->handle_data_changed          FOR g_grid.

    PERFORM p3201_f4_field_build.

*>.Call method 'set_toolbar_interactive' to raise event TOOLBAR.
    CALL METHOD g_grid->set_toolbar_interactive.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*// TITLE 지정
    PERFORM p3800_set_title_text.
** JS전선 회사코드 2007/04 KSH --------------------------------------
  ENDIF.


ENDFORM.                    " create_and_init_controls_0100
*&---------------------------------------------------------------------*
*&      Form  handle_toolbar
*&---------------------------------------------------------------------*
FORM handle_toolbar USING r_object TYPE REF TO cl_alv_event_toolbar_set
                          r_interactive.
*0    Button (normal)
*1    Menu and default button
*2    Menu
*3    Separator
*4    Radio button
*5    Checkbox
*6    Menu entry

  DATA: ls_toolbar  TYPE stb_button.

* append a separator to normal toolbar
  CLEAR  ls_toolbar.
  MOVE 3                    TO ls_toolbar-butn_type.
  APPEND ls_toolbar         TO r_object->mt_toolbar.
*
* append an icon to show 전기버튼
  IF sy-tcode EQ c_tcode.
    CLEAR ls_toolbar.
    MOVE 0                    TO ls_toolbar-butn_type.
    MOVE 'ZTIT901'            TO ls_toolbar-function.
    MOVE icon_financing       TO ls_toolbar-icon.
    MOVE ' 전기 '(113)        TO ls_toolbar-quickinfo.
    MOVE ' 전기 '(113)        TO ls_toolbar-text.
    MOVE space                TO ls_toolbar-disabled.
    APPEND ls_toolbar         TO r_object->mt_toolbar.
  ELSE.
* append an icon to show 전기버튼
    CLEAR ls_toolbar.
    MOVE 0                    TO ls_toolbar-butn_type.
    MOVE 'ZTIT902'            TO ls_toolbar-function.
    MOVE icon_financing       TO ls_toolbar-icon.
    MOVE ' 그룹별 일괄전기 '  TO ls_toolbar-quickinfo.
    MOVE ' 그룹별 일괄전기 '  TO ls_toolbar-text.
    MOVE space                TO ls_toolbar-disabled.
    APPEND ls_toolbar         TO r_object->mt_toolbar.
  ENDIF.

ENDFORM.                    " handle_toolbar


*&--------------------------------------------------------------------*
*&      Form  handle_data_changed
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM  handle_data_changed  USING er_data_changed
                           TYPE REF TO cl_alv_changed_data_protocol.
  DATA : ls_mod_cells TYPE lvc_s_modi,
         ls_cells     TYPE lvc_s_modi,
         ls_change    TYPE c,
         l_wrbtr      TYPE wrbtr,
         l_wmwst      TYPE wmwst,
         l_fwbas      TYPE fwbas,
         l_mwskz      TYPE hwaer,
         l_hwaer      TYPE hwaer.

*> 변경된 Cells 검증.
  LOOP AT er_data_changed->mt_good_cells INTO ls_mod_cells.

    CLEAR ls_change.

    READ TABLE it_list   INTO  gs_list
                 INDEX ls_mod_cells-row_id .
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.

    CASE ls_mod_cells-fieldname.
      WHEN 'WRBTR'.     ">금액.
        PERFORM  get_input_value   USING   l_wrbtr
                                           l_wmwst
                                           l_fwbas
                                           l_mwskz
                                           l_hwaer
                                           er_data_changed
                                           ls_mod_cells.
        IF l_wrbtr IS INITIAL AND
           l_wmwst IS INITIAL.
          MESSAGE e864.
        ENDIF.
      WHEN 'WMWST'.     ">세액.
        PERFORM  get_input_value   USING   l_wrbtr
                                           l_wmwst
                                           l_fwbas
                                           l_mwskz
                                           l_hwaer
                                           er_data_changed
                                           ls_mod_cells.
        IF l_wrbtr IS INITIAL AND
           l_wmwst IS INITIAL.
          MESSAGE e864.
        ENDIF.

      WHEN 'FWBAS'.     ">과세표준액.
        PERFORM  get_input_value   USING   l_wrbtr
                                           l_wmwst
                                           l_fwbas
                                           l_mwskz
                                           l_hwaer
                                           er_data_changed
                                           ls_mod_cells.


      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

*  LOOP AT er_data_changed->mt_good_cells INTO ls_mod_cells.
*    CASE ls_mod_cells-fieldname.
*      WHEN 'ITPA1'.                    "
*
*        READ TABLE it_list   INTO  gs_list
*                             INDEX ls_mod_cells-row_id .
*        IF gs_list-itpac  EQ  ls_mod_cells-value .
*
*          CALL METHOD er_data_changed->modify_cell
*            EXPORTING
*              i_row_id    = ls_mod_cells-row_id
*              i_fieldname = 'ICON'
*              i_value     = icon_green_light.
*        ELSE.
*          CALL METHOD er_data_changed->modify_cell
*            EXPORTING
*              i_row_id    = ls_mod_cells-row_id
*              i_fieldname = 'ICON'
*              i_value     = icon_red_light.
*        ENDIF.
*    ENDCASE.
*  ENDLOOP.

ENDFORM.                    "handle_data_changed

*&---------------------------------------------------------------------*
*&      Form  handle_data_changed_finished
*&---------------------------------------------------------------------*
FORM  handle_data_changed_finished   USING p_modified
                                           p_sender.

  DATA lt_rows     TYPE lvc_t_row.
  DATA l_row_id    TYPE lvc_s_row.
  DATA l_col_id    TYPE lvc_s_col.
  DATA ls_stable   TYPE lvc_s_stbl.
  DATA l_control   TYPE REF TO cl_gui_control.
  DATA l_row_no    TYPE lvc_s_roid.
  DATA lt_roid     TYPE lvc_t_roid.
  DATA l_row       TYPE i.
  DATA l_col       TYPE i.
  DATA l_end_pos   TYPE i.
  DATA l_start_pos TYPE i.

  CHECK NOT p_modified IS INITIAL.

* keep in mind selected rows
  REFRESH lt_rows.
  CALL METHOD g_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_rows.

  IF lt_rows[] IS INITIAL.
    CALL METHOD g_grid->get_focus
      IMPORTING
        control           = l_control
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3.
* Flush now to avoid a system_pointer_pending dump.
    CALL METHOD cl_gui_cfw=>flush.
    IF sy-subrc = 0 AND
       l_control = g_grid.
      CALL METHOD g_grid->get_current_cell
        IMPORTING
          es_row_no = l_row_no
          es_row_id = l_row_id
          es_col_id = l_col_id
          e_row     = l_row
          e_col     = l_col.

* Flush now to avoid a system_pointer_pending dump.
      CALL METHOD cl_gui_cfw=>flush.
    ENDIF.
  ENDIF.

  CALL METHOD g_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

  IF lt_rows[] IS INITIAL.
    CALL METHOD g_grid->set_focus
      EXPORTING
        control = l_control.
* Flush now to avoid a system_pointer_pending dump.
    CALL METHOD cl_gui_cfw=>flush.

    IF sy-subrc  = 0       AND
       l_control = g_grid.

      l_start_pos = 1.
      l_end_pos   = 1.

      APPEND l_row_no TO lt_roid.

      CALL METHOD g_grid->set_selected_rows
        EXPORTING
*          IT_INDEX_ROWS            =
          it_row_no                = lt_roid
*          IS_KEEP_OTHER_SELECTIONS =
          .

* Flush now to avoid a system_pointer_pending dump.
      CALL METHOD cl_gui_cfw=>flush.
    ENDIF.
  ELSE.
* reset selected rows
    CALL METHOD g_grid->set_selected_rows
      EXPORTING
        it_index_rows = lt_rows.
  ENDIF.
*   flush
  CALL METHOD cl_gui_cfw=>flush.

ENDFORM.                    "handle_data_changed_finished

*&---------------------------------------------------------------------*
*&      Form  handle_double_click
*&---------------------------------------------------------------------*
FORM handle_double_click  USING  p_row p_column.

  DATA: l_datatype    LIKE dd01v-datatype.

  CALL FUNCTION 'Z_TI_NUMBER_CHECK'
    EXPORTING
      string_in  = p_row
    IMPORTING
      string_out = p_row
      htype      = l_datatype.

  CHECK l_datatype EQ 'NUMC'.

  READ TABLE it_list INTO gs_list INDEX p_row.
  IF sy-subrc EQ 0.

    CASE p_column.
      WHEN 'ICSNO' OR 'ICSSQ'.
        PERFORM display_cs_document(ztir0000)
                                           USING gs_list-icsno
                                                 gs_list-bukrs.
      WHEN 'BELNR'.
        PERFORM display_liv_document(ztir9000)
                                           USING gs_list-belnr
                                                   gs_list-gjahr
                                                   gs_list-bukrs.
      WHEN 'BLNUM' OR 'IBLNO'.
        PERFORM display_bl_document(ztir0000)
                                           USING gs_list-iblno
                                                 space.
      WHEN 'EBELN'.
        PERFORM display_purchase_order(ztir0000)
                                           USING gs_list-ebeln
                                                 '00000'.
      WHEN OTHERS.
        PERFORM display_bl_document(ztir0000)
                                           USING gs_list-iblno
                                                 '00000'.
    ENDCASE.
  ELSE.
    MESSAGE s903.
  ENDIF.

ENDFORM.                    "handle_double_click
*&---------------------------------------------------------------------*
*&      Form  handle_hotspot_click
*&---------------------------------------------------------------------*
FORM handle_hotspot_click  USING e_row_id    TYPE lvc_s_row
                                 e_column_id TYPE lvc_s_col.

  READ TABLE it_list INTO gs_list INDEX e_row_id-index.
  IF sy-subrc NE 0.
    MESSAGE s903.   EXIT.
  ENDIF.

  CASE e_column_id-fieldname.
    WHEN 'BLNUM' OR 'IBLNO'.
      PERFORM display_bl_document(ztir0000)
                                    USING gs_list-iblno
                                               space.
    WHEN 'PSPNR'.
      PERFORM  display_project_master(ztir0000)
                                      USING gs_list-pspnr.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    "_hotspot_click
*&---------------------------------------------------------------------*
*&      Form  handle_user_command_grid
*&---------------------------------------------------------------------*
FORM handle_user_command_grid USING r_ucomm.

  DATA: l_valid TYPE c,
        lt_row_no TYPE lvc_t_roid WITH HEADER LINE.
  DATA: l_subrc   LIKE sy-subrc,
        l_text_amout(20).

  REFRESH: bdcdata, it_msg.
  CLEAR: session.
  ctu_params-dismode  = 'N'. ">처리모드
  ctu_params-updmode  = 'S'. ">갱신모드
  ctu_params-cattmode = ' '. ">CATT 모드...
  ctu_params-defsize  = ' '. ">기본화면 크기
  ctu_params-racommit = 'X'.
  ctu_params-nobinpt  = ' ' .
  ctu_params-nobiend  = ' '.

  CLEAR g_count.

  IF r_ucomm EQ 'ZTIT105' OR
     r_ucomm EQ 'ZTIT901' OR
     r_ucomm EQ 'ZTIT902' OR
     r_ucomm EQ 'ZTIT901S'.
    PERFORM  get_selected_row  TABLES lt_row_no.
  ENDIF.

  CHECK g_count GT 0.

  CASE r_ucomm.
    WHEN 'ZTIT901' or 'ZTIT902'.
*> 전표전기 종류 선택 함수(월합계산서 or 개별전표)
      IF g_count EQ 1.
        ztisscrcom-monsc = 'S'.
      ELSE.
        CALL FUNCTION 'Z_TI_COST_DOCUMENT_TYPE_POPUP'
          IMPORTING
            p_answer = g_answer
            p_monsc  = ztisscrcom-monsc.

        CHECK g_answer EQ 'Y'.
      ENDIF.
      CLEAR: g_count, g_wrbtr, g_wmwst,g_fwbas.
      REFRESH: it_vendor.

*> 데이타 체크.
      LOOP AT it_list INTO gs_list WHERE box = 'X'.
        CLEAR: gs_list-errmd.

*> 전기상태.
        IF NOT gs_list-icsno IS INITIAL.
          gs_list-errmd = 'X'.
          IF NOT gs_list-belnr IS INITIAL.
            MESSAGE s231 WITH gs_list-iblno '전기'.
          ELSE.
            MESSAGE s231 WITH gs_list-iblno '생성'.
          ENDIF.
          PERFORM set_return_message_fill USING 'E'.
        ENDIF.

        IF gs_list-hwaer  IS INITIAL AND
           gs_list-errmd  IS INITIAL.
          gs_list-errmd = 'X'.
          MESSAGE s224 WITH gs_list-iblno '통화단위'.
          PERFORM set_return_message_fill USING 'E'.
        ENDIF.

        IF ( gs_list-wrbtr  IS INITIAL   AND
             gs_list-wmwst  IS INITIAL ) AND
           gs_list-errmd  IS INITIAL.
          gs_list-errmd = 'X'.
          MESSAGE s232 WITH gs_list-iblno '비용금액'.
          PERFORM set_return_message_fill USING 'E'.
        ENDIF.

        IF gs_list-mwskz  IS INITIAL AND
           gs_list-errmd  IS INITIAL.
          gs_list-errmd = 'X'.
          MESSAGE s224 WITH gs_list-iblno '세금코드'.
          PERFORM set_return_message_fill USING 'E'.
        ENDIF.
*
        ADD gs_list-wrbtr TO g_wrbtr.
        ADD gs_list-wmwst TO g_wrbtr.
        ADD gs_list-wmwst TO g_wmwst.
        ADD gs_list-fwbas TO g_fwbas.

        MODIFY it_list FROM gs_list.
      ENDLOOP.

*> 합계전표일 경우 Vendor 등을 체크함.
      IF ztisscrcom-monsc EQ 'S'.
*> Error Message Display.
        PERFORM display_error_message.
        CHECK g_line EQ 0.
      ENDIF.

*> 전기확인용 대화화면 Call
      CLEAR: ok_code.
*> 전기용 HEADER DATA Fill
      PERFORM   fill_default_header_data.
*> 확인 대화상자 Call
      CALL SCREEN '0200' STARTING AT 1 8.
      IF ok_code EQ 'ABBR'.
        MESSAGE s900.
        EXIT.
      ELSEIF ok_code EQ 'SIMU'.
        ctu_params-dismode  = 'E'. ">처리모드
      ENDIF.
      CLEAR: g_success, g_error.

      IF ztisscrcom-monsc EQ 'S'.
        PERFORM execute_collective_posting.
      ELSE.
        PERFORM execute_individual_posting.
      ENDIF.
  ENDCASE.

*> Error Message Display.
  PERFORM display_error_message.
  IF g_success GT 0.
*> 검색조건에 해당하는 데이타를 Select.
    PERFORM p2000_data_selections.
    PERFORM p3000_field_category_build.
    PERFORM p3800_field_attribute_change.
    PERFORM p9000_refresh_display.
  ENDIF.

ENDFORM.                    "handle_user_command_grid
*&---------------------------------------------------------------------*
*&      Form  handle_on_f4
*&---------------------------------------------------------------------*
FORM handle_on_f4 USING sender         TYPE REF TO cl_gui_alv_grid
                        e_fieldname    TYPE lvc_fname
                        e_fieldvalue   TYPE lvc_value
                        es_row_no      TYPE lvc_s_roid
                        er_event_data  TYPE REF TO cl_alv_event_data
                        et_bad_cells   TYPE lvc_t_modi
                        e_display      TYPE char01.

  DATA : gt_f4 TYPE TABLE OF ddshretval.

* now I call my personal f4-help
  CALL METHOD event_receiver->handle_my_f4
    EXPORTING
      sender        = sender
      es_row_no     = es_row_no
      er_event_data = er_event_data
      et_bad_cells  = et_bad_cells
      e_display     = e_display
      e_fieldname   = e_fieldname
    IMPORTING
      gt_f4         = gt_f4.

* assign the cell table fieldsymbol to the dereferenced data table and
* fill the table.
  ASSIGN er_event_data->m_data->* TO <f4tab>.

  READ TABLE gt_f4 INTO ws_f4 INDEX 1.

  CHECK NOT ws_f4 IS INITIAL.

  CASE ws_f4-fieldname.
    WHEN 'MWSKZ'.
      PERFORM set_on_f4_mwskz_part USING es_row_no-row_id.
  ENDCASE.

* to avoid standard f4-help.
  er_event_data->m_event_handled = 'X'.

ENDFORM.                    " handle_on_f4
*&---------------------------------------------------------------------*
*&      Form  SET_on_f4_MWSKZ_part
*&---------------------------------------------------------------------*
FORM set_on_f4_mwskz_part USING es_row_no_row_id.

*  ls_modi-row_id    = es_row_no_row_id.
*  ls_modi-fieldname = 'MWSKZ'.
*  ls_modi-value     = ls_f4-fieldval.
*  APPEND ls_modi TO <f4tab>.
*
*  gt_display-meins = ls_f4-fieldval.   " Un
*
** 입력받은 값으로 다른 셀의 값을 변경시 기술 .......................
*  READ TABLE gt_display INDEX es_row_no_row_id.
*
**  ls_modi-fieldname = 'xxxxx'.
**  .................
**  APPEND ls_modi TO <f4tab>.
**
**  gt_display-xxxx = ls_modi-value.
ENDFORM.                    " SET_on_f4_MWSKZ_part
*&---------------------------------------------------------------------*
*&      Form  HANDLE_my_f4
*&---------------------------------------------------------------------*
FORM handle_my_f4 TABLES lt_f4    STRUCTURE ddshretval
                   USING sender        TYPE REF TO cl_gui_alv_grid
                         et_bad_cells  TYPE lvc_t_modi
                         es_row_no     TYPE lvc_s_roid
                         er_event_data TYPE REF TO cl_alv_event_data
                         e_display     TYPE c
                         e_fieldname   TYPE lvc_fname.

  DATA : gs_display  LIKE LINE OF it_list,
         lt_fcat     TYPE lvc_t_fcat,
         ls_fieldcat TYPE lvc_s_fcat,
         l_tabname   TYPE dd03v-tabname,
         l_fieldname TYPE dd03v-fieldname,
         l_help_valu TYPE help_info-fldvalue,
         lt_bad_cell TYPE lvc_t_modi,
         lp_wa       TYPE REF TO data.

  FIELD-SYMBOLS : <l_field_value> TYPE ANY,
                  <ls_wa>         TYPE ANY.

  CLEAR   : gs_value, it_values, gs_field, it_fields.
  REFRESH :           it_values,           it_fields.

  CALL METHOD sender->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = lt_fcat.

  READ TABLE it_list INDEX es_row_no-row_id INTO gs_display.
  CREATE DATA lp_wa LIKE LINE OF it_list.
  ASSIGN lp_wa->* TO <ls_wa>.
  <ls_wa> = gs_display.

  READ TABLE lt_fcat WITH KEY fieldname = e_fieldname
                     INTO ls_fieldcat.

  MOVE ls_fieldcat-ref_table TO l_tabname.
  MOVE ls_fieldcat-fieldname TO l_fieldname.

  ASSIGN COMPONENT ls_fieldcat-fieldname
                 OF STRUCTURE gs_display TO <l_field_value>.

  WRITE <l_field_value> TO l_help_valu.

  PERFORM f4_set IN PROGRAM bcalv_f4
                 USING sender
                       lt_fcat
                       lt_bad_cell
                       es_row_no-row_id
                       <ls_wa>.

* FILL INTERNAL TABLE FOR POSSIBLE ENTRY
  CASE e_fieldname.
    WHEN 'MWSKZ'.
      PERFORM handle_mwskz_f4_part.
  ENDCASE.

* 4. INTERNAL TABLE 로 POSSIBLE ENTRY 띄우기.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = e_fieldname
    TABLES
      field_tab       = it_fields
      value_tab       = it_values
      return_tab      = lt_f4[]
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " handle_my_f4

*&---------------------------------------------------------------------*
*&      Form  HANDLE_MWSKZ_f4_part
*&---------------------------------------------------------------------*
FORM handle_mwskz_f4_part.

  DATA : BEGIN OF lt_t006a OCCURS 0,    " UNIT
           msehi LIKE t006a-msehi,
           msehl LIKE t006a-msehl,
         END OF lt_t006a.

* 1. 데이터 가져오기.
  CLEAR   lt_t006a.
  REFRESH lt_t006a.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_t006a
    FROM t006a
   WHERE spras = sy-langu.

*  LOOP AT lt_t006a.
*    ls_value-string = lt_t006a-msehi.
*    APPEND ls_value TO lt_values.
*    ls_value-string = lt_t006a-msehl.
*    APPEND ls_value TO lt_values.
*  ENDLOOP.
*
** 3. INTERNAL TABLE HEADER 만들기(title 정의)
*  CLEAR ls_field.
*  ls_field-fieldname = 'MEINS'.    " 반드시 인터널 필드명과 동일하게
*  ls_field-intlen    =  3.
*  ls_field-leng      =  3.
*  ls_field-outputlen =  3.
*  ls_field-scrtext_s = 'Un'.
*  ls_field-scrtext_m = 'Un'.
*  ls_field-scrtext_l = 'Un'.
*  ls_field-reptext   = 'Un'.
*  APPEND ls_field TO lt_fields.
*
*  CLEAR ls_field.
*  ls_field-fieldname = 'MSEHL'.
*  ls_field-intlen    =  30.
*  ls_field-leng      =  30.
*  ls_field-outputlen =  30.
*  ls_field-scrtext_s = 'TEXT'.
*  ls_field-scrtext_m = 'TEXT'.
*  ls_field-scrtext_l = 'TEXT'.
*  ls_field-reptext   = 'TEXT'.
*  APPEND ls_field TO lt_fields.
ENDFORM.                    " HANDLE_MWSKZ_f4_part
*&---------------------------------------------------------------------*
*&      Form  set_return_message_FILL
*&---------------------------------------------------------------------*
FORM set_return_message_fill USING p_msgty.

  MOVE:  sy-msgid  TO  it_msg-msgid,
         p_msgty   TO  it_msg-msgty,
         sy-msgno  TO  it_msg-msgno,
         sy-msgv1  TO  it_msg-msgv1,
         sy-msgv2  TO  it_msg-msgv2,
         sy-msgv3  TO  it_msg-msgv3,
         sy-msgv4  TO  it_msg-msgv4.

  COLLECT it_msg.

ENDFORM.                    " set_return_message_FILL
*&---------------------------------------------------------------------*
*&      Form  P3210_exclude_table_build
*&---------------------------------------------------------------------*
FORM p3210_exclude_table_build USING p_tabname.

*  툴바의 버튼중 나타내지 않을 버튼을 지정한다.
  FIELD-SYMBOLS : <table> TYPE ui_functions.

  DATA : ls_exclude   TYPE ui_func.
  DATA : l_table_name LIKE feld-name.

  CONCATENATE p_tabname '[]' INTO  l_table_name.
  ASSIGN     (l_table_name)    TO <table>.

  PERFORM append_exclude_functions
        TABLES <table>
*        USING : cl_gui_alv_grid=>mc_fc_excl_all. " ** 툴바 모두제거 **
         USING : cl_gui_alv_grid=>mc_fc_loc_undo, " 실행취소 &LOCAL&UNDO
*                cl_gui_alv_grid=>mc_fc_auf,      " 소계확장 &AUF
*                cl_gui_alv_grid=>mc_fc_average,  " &AVERAGE
*                cl_gui_alv_grid=>mc_fc_back_classic,
*                cl_gui_alv_grid=>mc_fc_call_abc, " &ABC
*                cl_gui_alv_grid=>mc_fc_call_chain,
*                cl_gui_alv_grid=>mc_fc_call_crbatch,
*                cl_gui_alv_grid=>mc_fc_call_crweb,
*                cl_gui_alv_grid=>mc_fc_call_lineitems,
*                cl_gui_alv_grid=>mc_fc_call_master_data,
*                cl_gui_alv_grid=>mc_fc_call_more,
*                cl_gui_alv_grid=>mc_fc_call_report,
*                cl_gui_alv_grid=>mc_fc_call_xint,
*                cl_gui_alv_grid=>mc_fc_call_xxl,
*                cl_gui_alv_grid=>mc_fc_col_invisible,
*                cl_gui_alv_grid=>mc_fc_col_optimize,
*                cl_gui_alv_grid=>mc_fc_current_variant,
*                cl_gui_alv_grid=>mc_fc_data_save,
*                cl_gui_alv_grid=>mc_fc_delete_filter,
*                cl_gui_alv_grid=>mc_fc_deselect_all,
*                cl_gui_alv_grid=>mc_fc_detail,
*                cl_gui_alv_grid=>mc_fc_expcrdata,
*                cl_gui_alv_grid=>mc_fc_expcrdesig,
*                cl_gui_alv_grid=>mc_fc_expcrtempl,
*                cl_gui_alv_grid=>mc_fc_expmdb,
*                cl_gui_alv_grid=>mc_fc_extend,
*                cl_gui_alv_grid=>mc_fc_f4,
*                cl_gui_alv_grid=>mc_fc_filter,
*                cl_gui_alv_grid=>mc_fc_find,
*                cl_gui_alv_grid=>mc_fc_fix_columns,
*                cl_gui_alv_grid=>mc_fc_graph,
*                cl_gui_alv_grid=>mc_fc_help,
*                cl_gui_alv_grid=>mc_fc_info,
*                cl_gui_alv_grid=>mc_fc_load_variant,
                cl_gui_alv_grid=>mc_fc_loc_copy,          " 행 카피.
*                cl_gui_alv_grid=>mc_fc_html,
                cl_gui_alv_grid=>mc_fc_loc_copy_row,      " 행 카피.
                cl_gui_alv_grid=>mc_fc_loc_cut,           " 가위.
                cl_gui_alv_grid=>mc_fc_loc_delete_row,    " 행삭제.
                cl_gui_alv_grid=>mc_fc_loc_insert_row,    " 행삽입.
                cl_gui_alv_grid=>mc_fc_loc_move_row,
                cl_gui_alv_grid=>mc_fc_loc_append_row,    " 라인생성.
                cl_gui_alv_grid=>mc_fc_loc_paste,         " 겹쳐쓰기.
                cl_gui_alv_grid=>mc_fc_loc_paste_new_row. " 겹쳐쓰기.
*                cl_gui_alv_grid=>mc_fc_maintain_variant,
*                cl_gui_alv_grid=>mc_fc_maximum,
*                cl_gui_alv_grid=>mc_fc_minimum,
*                cl_gui_alv_grid=>mc_fc_pc_file,
*                cl_gui_alv_grid=>mc_fc_print,
*                cl_gui_alv_grid=>mc_fc_print_back,
*                cl_gui_alv_grid=>mc_fc_print_prev,
*                cl_gui_alv_grid=>mc_fc_refresh,
*                cl_gui_alv_grid=>mc_fc_reprep,
*                cl_gui_alv_grid=>mc_fc_save_variant,
*                cl_gui_alv_grid=>mc_fc_select_all,
*                cl_gui_alv_grid=>mc_fc_send,
*                cl_gui_alv_grid=>mc_fc_separator,
*                cl_gui_alv_grid=>mc_fc_sort,
*                cl_gui_alv_grid=>mc_fc_sort_asc,
*                cl_gui_alv_grid=>mc_fc_sort_dsc,
*                cl_gui_alv_grid=>mc_fc_subtot,
*                cl_gui_alv_grid=>mc_fc_sum,
*                cl_gui_alv_grid=>mc_fc_to_office,
*                cl_gui_alv_grid=>mc_fc_to_rep_tree,
*                cl_gui_alv_grid=>mc_fc_unfix_columns,
*                cl_gui_alv_grid=>mc_fc_views,
*                cl_gui_alv_grid=>mc_fc_view_crystal,
*                cl_gui_alv_grid=>mc_fc_view_excel,
*                cl_gui_alv_grid=>mc_fc_view_grid,
*                cl_gui_alv_grid=>mc_fc_word_processor.

ENDFORM.                    " P3210_exclude_table_build
*&---------------------------------------------------------------------*
*&      Form  P3700_layout_build
*&---------------------------------------------------------------------*
FORM p3700_layout_build .

** General display options
*  gs_layout_g-cwidth_opt = 'X'.
  gs_layout_g-smalltitle = 'X'.
*  gs_layout_g-box_fname  = 'BOX'.
* ICON.
*      gs_layout_g-excp_fname = g_lights_name.

** Grid customizing
* Title between grid control and toolbar(70자 이내)
* GS_LAYOUT_G-grid_title = '프로그램 LIST'.

** Column headers are hidden
* GS_LAYOUT_G-no_headers = 'X'.

** Columns are displayed without horizontal grid lines
* GS_LAYOUT_G-no_hgridln = 'X'.
*
** Cells are not merged when a column is sorted
* GS_LAYOUT_G-no_merging = ' '.

* the button at the beginning of a row is hidden in selection modes
* cell selection ( SEL_MODE = 'D' ) and column/row selection
* ( SEL_MODE = 'A' ).
*  gs_layout_g-no_rowmark = 'A'. "(or 'X')

* Selection modes for SEL_MODE
* 'A' : Column and row selection
* 'B' : Simple selection, list box
* 'C' : Multiple selection, list box
* 'D' : Cell selection
  gs_layout_g-sel_mode = 'C'.
* If this field is set, the toolbar is hidden.
* GS_LAYOUT_G-no_toolbar = 'X'.

* columns are displayed without vertical grid lines
* GS_LAYOUT_G-no_vgridln = 'X'.

* In case of PRINT_END_OF_PAGE, you must set 'reservelns' to
* the number of reserved lines at the end of a page.
* reserve two lines for the PRINT_END_OF_PAGE event
* p_print-reservelns = 2.

* Standard(BCALV_EDIT_01)에서는 다음과 같이 했다.
* Set status of all cells to editable using the layout structure.
* 옵션에 안보이던데... 어째껀 수정모드로 바꾸는 중요한 옵션이다.
*  IF g_mode = c_display.
*    GS_LAYOUT_G-edit = ' '.
*  ELSEIF g_mode = c_edit.
*    GS_LAYOUT_G-edit = 'X'.
*  ENDIF.

* Provide the fieldname of the celltab field by using field
* STYLEFNAME of the layout structure.

  gs_layout_g-stylefname = 'CELLTAB'.

* 합을 제일 윗라인에 DISPLAY
*  gs_layout_g-totals_bef = 'X'.

ENDFORM.                    " P3700_layout_build
*&---------------------------------------------------------------------*
*&      Form  append_exclude_functions
*&---------------------------------------------------------------------*
FORM append_exclude_functions  TABLES p_table
                               USING  p_value.

  DATA : ls_exclude TYPE ui_func.
  ls_exclude = p_value.
  APPEND ls_exclude TO p_table.

ENDFORM.                    " append_exclude_functions
*&---------------------------------------------------------------------*
*&      Module  pai_scr0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_scr0100 INPUT.

  CASE sy-ucomm.
    WHEN 'EXIT' OR 'CANC' OR 'BACK'.
      IF g_grid IS INITIAL.
        CALL METHOD g_grid->free.
      ENDIF.
      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.

ENDMODULE.                 " pai_scr0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  status_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  DATA:    BEGIN OF excl OCCURS 25,
             funktion(10),
           END OF excl.
  REFRESH excl.

  IF ztisscrcom-monsc EQ 'I'.
    MOVE 'SIMU' TO excl-funktion.    APPEND excl.
  ENDIF.

  SET PF-STATUS '0200' EXCLUDING excl.

ENDMODULE.                 " status_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_selected_row  TABLES   pt_row_no TYPE lvc_t_roid.

  DATA: l_valid TYPE c.

  CALL METHOD g_grid->check_changed_data
    IMPORTING
      e_valid = l_valid.

  IF l_valid EQ 'X'.
    CALL METHOD g_grid->get_selected_rows
      IMPORTING
        et_row_no = pt_row_no[].

    IF pt_row_no[] IS INITIAL.
      MESSAGE s909.
      EXIT.
    ENDIF.

    CLEAR gs_list-box.
    MODIFY it_list FROM gs_list TRANSPORTING box WHERE box = 'X'.

    LOOP AT pt_row_no.
      IF pt_row_no-row_id GT 0.
        READ TABLE it_list INTO gs_list INDEX pt_row_no-row_id.
        IF sy-subrc EQ 0.
          ADD 1 TO g_count.
          IF gs_list-box NE 'X'.
            gs_list-box = 'X'.
          ENDIF.
          MODIFY it_list FROM gs_list INDEX pt_row_no-row_id.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF g_count EQ 0.
    MESSAGE s909.
  ENDIF.

ENDFORM.                    " GET_SELECTED_ROW
*&---------------------------------------------------------------------*
*&      Module  user_command_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE ok_code.
    WHEN 'ABBR'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'BU' OR 'BUC' OR 'SIMU'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN OTHERS.
  ENDCASE.
  CLEAR: ok_code.

ENDMODULE.                 " user_command_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_check_fields_scr0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_check_fields_scr0200 INPUT.

  CHECK ok_code NE 'ABBR'.

*> 전기일.
  IF ztitcsk-budat IS INITIAL.
    PERFORM no_input_check(ztir0000) USING 'ZTITCSK' 'BUDAT' 'E'.
  ENDIF.
*> 증빙일.
  IF ztitcsk-bldat IS INITIAL.
    PERFORM no_input_check(ztir0000) USING 'ZTITCSK' 'BLDAT' 'E'.
  ENDIF.

  IF ztitcsk-lifnr IS INITIAL.
    PERFORM no_input_check(ztir0000) USING 'ZTITCSK' 'LIFNR' 'E'.
  ENDIF.

  IF NOT ztitig00-chkbp IS INITIAL.
    IF ztitcsk-bupla IS INITIAL.    ">
*      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'BUPLA'.
      PERFORM  check_mandatory_input(ztir0000)
                             USING  'ZTITCSK-BUPLA' ztitig00-chkbp.
    ENDIF.
  ENDIF.

  IF NOT ztitig00-chkba IS INITIAL.
    IF ztitcsk-gsber IS INITIAL.    ">
*      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'BUPLA'.
      PERFORM  check_mandatory_input(ztir0000)
                            USING  'ZTITCSK-GSBER' ztitig00-chkba.
    ENDIF.
  ENDIF.

*> 입력된 값 체크.
  PERFORM  check_input_value.
*>
  CLEAR : lfa1.
  SELECT SINGLE * INTO lfa1 FROM lfa1
                  WHERE lifnr EQ ztitcsk-lifnr.
  IF sy-subrc NE 0.
    MESSAGE e924 WITH '구매처' ztitcsk-lifnr.
  ENDIF.

*> 지급조건.
  IF ztitcsk-zterm IS INITIAL.
    PERFORM no_input_check(ztir0000) USING 'ZTITCSK' 'ZTERM' 'E'.
  ENDIF.

  IF ztitcsk-cstyp IS INITIAL.
    PERFORM no_input_check(ztir0000) USING 'ZTITCSK' 'CSTYP' 'E'.
  ELSE.
    IF ztitcsk-cstyp EQ 'A'.
*> Get 업무가불 Default value
*      SELECT SINGLE *
*        FROM ztitig07
*       WHERE bukrs EQ ztitcsk-bukrs
*         AND cstct EQ 'L'.
*      IF sy-subrc EQ 0.
*        IF ztitig07-blart NE ztitcsk-blart.
*          MESSAGE w941 WITH ztitcsk-blart ztitig07-blart.
*          ztitcsk-blart = ztitig07-blart.
*        ENDIF.
*      ENDIF.
      IF ztitcsk-iname IS INITIAL.
        PERFORM no_input_check(ztir0000) USING 'ZTITCSK' 'INAME' 'E'.
      ENDIF.
    ENDIF.
  ENDIF.

**> 사업영역.
*  IF ZTITCSK-gsber IS INITIAL.
*    PERFORM no_input_check(ZTIr0000) USING 'ZTITCSK' 'GSBER' 'E'.
*  ENDIF.
**> 사용가능한 사업영역 체크.
*  PERFORM  check_business_area(ZTIr0000)
*                                     USING ZTITCSK-gsber.
*
*> 지급조건.
  IF ztitcsk-xblnr IS INITIAL.
    PERFORM no_input_check(ztir0000) USING 'ZTITCSK' 'XBLNR' 'E'.
  ENDIF.

*> 개별전표일 경우.
  IF ztisscrcom-monsc EQ 'I'.

*> 일괄전표일 경우.
  ELSE.

  ENDIF.

*> 일회성 계정.
  IF NOT lfa1-xcpdk IS INITIAL.
    CLEAR : ok-code.
    IF ztitcso IS INITIAL.
      PERFORM set_one_time_vender_data USING   'C'
                                       CHANGING ok-code.
      IF ok-code NE 'ZTIOKAY'.
        MESSAGE s900.
      ENDIF.
    ENDIF.
    IF ztitcso IS INITIAL.
      MESSAGE s266(f5).
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.
  ELSE.
    CLEAR: ztitcso.
  ENDIF.

  IF NOT ztitcsk-empfk IS INITIAL.
    SELECT SINGLE * INTO *lfa1
           FROM lfa1
           WHERE  lifnr EQ ztitcsk-empfk.
  ELSE.
    CLEAR *lfa1.
  ENDIF.

  IF ztisscrcom-monsc EQ 'I'.

  ENDIF.

ENDMODULE.                 " pai_check_fields_scr0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_SCR0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_scr0200 INPUT.
  SET SCREEN 0. LEAVE SCREEN.
ENDMODULE.                 " exit_SCR0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  help_payment_term_scr0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE help_payment_term_scr0200 INPUT.
  LOOP AT SCREEN.
    IF screen-name EQ 'ZTITCSK-ZTERM'.
      EXIT.
    ENDIF.
  ENDLOOP.

  PERFORM get_f4_for_zterm_dynpro(ztir9000) USING ztitcsk-zterm.

ENDMODULE.                 " help_payment_term_scr0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  help_payer_scr0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE help_payer_scr0200 INPUT.

  LOOP AT SCREEN.
    IF screen-name EQ 'ZTITCSK-EMPKF'.
      EXIT.
    ENDIF.
  ENDLOOP.

  SELECT p~bukrs p~lifnr p~empfk h~name1
         INTO CORRESPONDING FIELDS OF TABLE xlfza
         FROM   lfa1 AS h INNER JOIN lfza AS p
         ON     h~lifnr   EQ  p~empfk
         WHERE  p~bukrs   EQ   ztitcsk-bukrs
         AND    p~lifnr   EQ   ztitcsk-lifnr.

  IF sy-subrc NE 0.
    MESSAGE s854 WITH ztitcsk-lifnr.
    EXIT.
  ENDIF.

  dynprog = sy-repid.
  dynnr   = sy-dynnr.

  g_window_title = 'Payee Help'.
  IF screen-input EQ '1'.
    CLEAR: g_display.
  ELSE.
    g_display = 'X'.
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
           EXPORTING
*                RETFIELD        = 'OTYPE'
                retfield        = 'EMPFK'
                dynpprog        = dynprog
                dynpnr          = dynnr
                dynprofield     = 'ZTITCSK-EMPFK'
                window_title    = g_window_title
                value_org       = 'S'
                display         = g_display
           TABLES
                value_tab       = xlfza
           EXCEPTIONS
                parameter_error = 1
                no_values_found = 2
                OTHERS          = 3.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

ENDMODULE.                 " help_payer_scr0200  INPUT

*&---------------------------------------------------------------------*
*&      Form  FILL_DEFAULT_HEADER_DATA
*&---------------------------------------------------------------------*
FORM fill_default_header_data .

  LOOP AT it_list INTO gs_list WHERE box = 'X'.
    EXIT.
  ENDLOOP.

  SELECT SINGLE *
    FROM ztitig07
   WHERE bukrs EQ t001-bukrs
     AND cstct EQ 'F'.

  MOVE: sy-datlo         TO    ztitcsk-budat,
        sy-datlo         TO    ztitcsk-bldat,
*        sy-datlo         TO    ZTITCSK-zfbdt,
        ztitig07-blart   TO    ztitcsk-blart,
        t001-bukrs       TO    ztitcsk-bukrs,
        sy-mandt         TO    ztitcsk-mandt,
        ztitig07-bupla   TO    ztitcsk-bupla,
        ztitig07-gsber   TO    ztitcsk-gsber,
        ztitig07-cstyp   TO    ztitcsk-cstyp,
        ztitig07-zterm   TO    ztitcsk-zterm,
        ztitig07-mwskz   TO    ztitcsk-mwskz,
        ztitig07-zlspr   TO    ztitcsk-zlspr,
        ztitig07-zlsch   TO    ztitcsk-zlsch,
        ztitig07-uzawe   TO    ztitcsk-uzawe,
        gs_list-blnum    TO    ztitcsk-xblnr,
*        gs_list-lifnr    TO    ztitcsk-lifnr,
        gs_list-hwaer   TO    ztitcsk-waers,
        g_wrbtr          TO    ztitcsk-wrbtr,
        g_wmwst          TO    ztitcsk-wmwst.

*
*  MOVE: sy-datlo         TO    ztitcsk-budat,
*        sy-datlo         TO    ztitcsk-bldat,
*        sy-datlo         TO    ztitcsk-zfbdt,
*        'RE'             TO    ztitcsk-blart,
*        t001-bukrs       TO    ztitcsk-bukrs,
*        sy-mandt         TO    ztitcsk-mandt,
*        '130'           TO    ztitcsk-bupla,
**        '0000'           TO    ZTITCSK-zterm,
*        gs_list-mwskz    TO    ztitcsk-mwskz,
**        'B/L 관련비용'   TO    ZTITCSK-bktxt,
**        'B/L 관련비용'   TO    ZTITCSK-sgtxt,
**--> LG전선 테스트를 위해 일시 수정. by MSH,20041121
**        gs_list-blnum    TO    ztitcsk-xblnr,
*        'Test'           TO    ztitcsk-xblnr,
**--> End of Modification.
*        gs_list-hwaer    TO    ztitcsk-waers,
*        g_wrbtr          TO    ztitcsk-wrbtr,
*        g_wmwst          TO    ztitcsk-wmwst,
*        g_fwbas          TO    ztitcsk-fwbas.
*
  IF gs_list-blnum IS INITIAL.
    ztitcsk-xblnr = gs_list-iblno.
  ENDIF.

  SELECT name_text
    INTO ztitcsk-iname
    FROM adrp UP TO 1 ROWS
   WHERE persnumber EQ ( SELECT persnumber
                           FROM usr21
                          WHERE bname EQ sy-uname ).

  ENDSELECT.

  PERFORM  get_domain_value_text(ztir9000)
                                 USING   'ZTIEXPGR'
                                         'B'
                                 CHANGING ztitcsk-bktxt.

ENDFORM.                    " FILL_DEFAULT_HEADER_DATA
*&---------------------------------------------------------------------*
*&      Module  change_field_attribute_scr0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_field_attribute_scr0200 OUTPUT.

  LOOP AT SCREEN.
    IF ztisscrcom-monsc EQ 'I'.
*      IF screen-name EQ 'ZTITCSK-LIFNR' OR
*         screen-name EQ 'LFA1-NAME1'     OR
      IF screen-name EQ 'ZTITCSK-AKONT' OR
         screen-name EQ 'ZTITCSK-WRBTR' OR
         screen-name EQ 'ZTITCSK-WAERS' OR
         screen-name EQ 'ZTITCSK-WMWST' OR
         screen-name EQ 'ZTITCSK-BKTXT' OR
         screen-name EQ 'ZTITCSK-XBLNR' OR
         screen-name EQ 'ZTITCSK-SGTXT'.
        screen-input     = '0'.
        screen-invisible = '1'.
      ENDIF.
    ENDIF.
    IF ztitig00-chkbp IS INITIAL AND
       screen-name EQ 'ZTITCSK-BUPLA'.
      screen-input     = '0'.
      screen-invisible = '1'.
    ENDIF.
    IF ztitig00-chkba IS INITIAL AND
       screen-name EQ 'ZTITCSK-GSBER'.
      screen-input     = '0'.
      screen-invisible = '1'.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " change_field_attribute_scr0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ERROR_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_error_message .

  DESCRIBE TABLE it_msg LINES g_line.
  IF g_line GT 0.
    CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
      EXPORTING
        xdocno_show = ' '
      TABLES
        xmsg        = it_msg.
  ENDIF.

ENDFORM.                    " DISPLAY_ERROR_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  execute_individual_posting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM execute_individual_posting .

  DATA: l_subrc   LIKE sy-subrc.

  LOOP AT it_list INTO gs_list WHERE box = 'X'
                                 AND errmd EQ space.
    CLEAR g_wrbtr.
    ADD gs_list-wmwst TO g_wrbtr.
    ADD gs_list-wrbtr TO g_wrbtr.

*> build BDC data
    PERFORM build_individual_posting_data.
*> Call transaction
    PERFORM bdc_transaction        USING 'ZTIT901' l_subrc.
*> build Message internal table.
    PERFORM build_posted_message   USING l_subrc.
    IF l_subrc EQ 0.
      ADD 1 TO g_success.
    ELSE.
      ADD 1 TO g_error.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " execute_individual_posting
*&---------------------------------------------------------------------*
*&      Form  build_individual_posting_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_individual_posting_data .

  DATA: l_text_amout(20),
        l_text_amouth(20),
        l_text_amout2(20),
        l_text_amout3(20).

  REFRESH: bdcdata.

  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR9000'          '0100',
         ' ' 'ZTISSCRCOM-BUKRS'  ztitcsk-bukrs,
         ' ' 'ZTISSCRCOM-BUDAT'  ztitcsk-budat,
         ' ' 'ZTISSCRCOM-BLDAT'  ztitcsk-bldat,
         ' ' 'ZTISSCRCOM-LIFNR'  ztitcsk-lifnr,
*         ' ' 'ZTISSCRCOM-EMPFK'  ZTITCSK-empfk,
         ' ' 'ZTISSCRCOM-EXPGR'  'B',
*         ' ' 'ZTISSCRCOM-CSTYP'  ZTISSCRCOM-CSTYP
         ' ' 'ZTISSCRCOM-WAERS'  gs_list-waers,
         ' ' 'ZTISSCRCOM-BLART'  ztitcsk-blart,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.

*> 세부화면.
  WRITE gs_list-wrbtr TO l_text_amout  CURRENCY gs_list-hwaer.
  PERFORM    set_write_no_mask(ztir9000)
                                    CHANGING  l_text_amout.
  WRITE g_wrbtr       TO l_text_amouth CURRENCY gs_list-hwaer.
  PERFORM    set_write_no_mask(ztir9000)
                                    CHANGING  l_text_amouth.
  WRITE gs_list-wmwst TO l_text_amout2 CURRENCY gs_list-hwaer.
  PERFORM    set_write_no_mask(ztir9000)
                                    CHANGING  l_text_amout2.
  WRITE gs_list-fwbas TO l_text_amout3 CURRENCY gs_list-hwaer.
  PERFORM    set_write_no_mask(ztir9000)
                                    CHANGING  l_text_amout3.

  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR9000'           '2000',
         ' ' 'ZTITCSK-CSTYP'  ztitcsk-cstyp,
         ' ' 'ZTITCSK-INAME'  ztitcsk-iname,
*         ' ' 'ZTITCSK-BUPLA'  ztitcsk-bupla,
*         ' ' 'ZTITCSK-GSBER'  ztitcsk-gsber,
         ' ' 'ZTITCSK-ZLSPR'  ztitcsk-zlspr,
         ' ' 'ZTITCSK-UZAWE'  ztitcsk-uzawe,
         ' ' 'ZTITCSK-ZLSCH'  ztitcsk-zlsch,
         ' ' 'ZTITCSK-ZTERM'  ztitcsk-zterm,
         ' ' 'ZTITCSK-MWSKZ'  ztitcsk-mwskz,
         ' ' 'ZTITCSK-XBLNR'  ztitcsk-xblnr,
         ' ' 'ZTITCSK-BKTXT'  ztitcsk-bktxt,
*         ' ' 'ZTITCSK-BUDAT'
*         ' ' 'ZTITCSK-BLART'
*         ' ' 'ZTITCSK-BLDAT'
*         ' ' 'ZTITCSK-BUPLA'      ZTITCSK-bupla,
*         ' ' 'ZTITCSK-GSBER'      ZTITCSK-gsber,
*         ' ' 'ZTITCSK-ZLSPR'      ZTITCSK-zlspr,
*         ' ' 'ZTITCSK-AKONT'
*         ' ' 'ZTITCSK-ZLSCH'      ZTITCSK-zlsch,
*         ' ' 'ZTITCSK-ZTERM'      ztitcsk-zterm,
**         ' ' 'ZTITCSK-WRBTR'      l_text_amouth,
**         ' ' 'ZTITCSK-WAERS'
*         ' ' 'ZTITCSK-MWSKZ'      ztitcsk-mwskz,
**         ' ' 'ZTITCSK-WMWST'      l_text_amout2,
**         ' ' 'ZTITCSK-FWBAS'      l_text_amout3,
**         ' ' 'ZTITCSK-WMWST'      gs_list-wmwst,
**         ' ' 'ZTITCSK-FWBAS'      gs_list-fwbas,
*         ' ' 'ZTITCSK-XBLNR'      gs_list-blnum,
*         ' ' 'ZTITCSK-BKTXT'      gs_list-exptx,
*         ' ' 'ZTITCSK-EBILL'      ZTITCSK-ebill,
*         ' ' 'ZTITCSK-SGTXT'      gs_list-exptx,
         ' ' 'ZTISCSIT-EXPCD(01)'  gs_list-expcd,
         ' ' 'ZTISCSIT-IBLNO(01)'  gs_list-iblno,
         ' ' 'ZTISCSIT-WRBTR(01)'  l_text_amout,
         ' ' 'ZTISCSIT-MWSKZ(01)'  gs_list-mwskz,
         ' ' 'ZTISCSIT-WMWST(01)'  l_text_amout2,
         ' ' 'ZTISCSIT-FWBAS(01)'  l_text_amout3.

  IF NOT ztitig00-chkbp IS INITIAL.
    PERFORM bdc_dynpro_build USING :
         ' ' 'ZTITCSK-BUPLA'  ztitcsk-bupla.
  ENDIF.
  IF NOT ztitig00-chkba IS INITIAL.
    PERFORM bdc_dynpro_build USING :
         ' ' 'ZTITCSK-GSBER'  ztitcsk-gsber.
  ENDIF.

  IF ok_code EQ 'BUC'.
    PERFORM bdc_dynpro_build USING :
           ' ' 'BDC_OKCODE'       '=ZTISAVE'.
  ELSEIF ok_code EQ 'SIMU'.
    PERFORM bdc_dynpro_build USING :
           ' ' 'BDC_OKCODE'       '=ZTISIMUL'.
  ELSE.
    PERFORM bdc_dynpro_build USING :
           ' ' 'BDC_OKCODE'       '=ZTIPOST'.
  ENDIF.
  IF ok_code NE 'SIMU'.
    PERFORM bdc_dynpro_build USING :
           'X' 'SAPLSPO1'          '0300',
           ' ' 'BDC_OKCODE'       '=YES'.
  ENDIF.

* one-time vendor.
  PERFORM one_time_vendor_bdc USING lfa1-xcpdk
                                    ztitcso.


ENDFORM.                    " build_individual_posting_data
*&---------------------------------------------------------------------*
*&      Form  execute_collective_posting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM execute_collective_posting .

  DATA: l_subrc   LIKE sy-subrc.

  REFRESH: bdcdata.
  CLEAR: g_cnt, g_wrbtr ,g_wmwst, g_fwbas.

*> 전기할 품목의 Counter.
  LOOP AT it_list INTO gs_list WHERE box = 'X'
                                 AND errmd EQ space.
    ADD 1 TO g_cnt.
    ADD gs_list-wrbtr TO g_wrbtr.
    ADD gs_list-wmwst TO g_wrbtr.
    ADD gs_list-wmwst TO g_wmwst.
    ADD gs_list-fwbas TO g_fwbas.

  ENDLOOP.

*> build BDC data
  PERFORM build_collective_posting_data.
  CLEAR: sy.
*> Call transaction
  PERFORM bdc_transaction        USING 'ZTIT901' l_subrc.
*> build Message internal table.
  PERFORM build_posted_message   USING l_subrc.

  IF l_subrc EQ 0.
    ADD 1 TO g_success.
  ELSE.
    ADD 1 TO g_error.
  ENDIF.

ENDFORM.                    " execute_collective_posting
*&---------------------------------------------------------------------*
*&      Form  build_collective_posting_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_collective_posting_data .

  DATA: l_text_amout(20),
        l_text_amout2(20),
        l_text_amout3(20),
        l_icssq           TYPE ztiicssq.

  REFRESH: bdcdata.

  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR9000'          '0100',
         ' ' 'ZTISSCRCOM-BUKRS'  ztitcsk-bukrs,
         ' ' 'ZTISSCRCOM-BUDAT'  ztitcsk-budat,
         ' ' 'ZTISSCRCOM-BLDAT'  ztitcsk-bldat,
         ' ' 'ZTISSCRCOM-LIFNR'  ztitcsk-lifnr,
*         ' ' 'ZTISSCRCOM-EMPFK'  ZTITCSK-empfk,
         ' ' 'ZTISSCRCOM-EXPGR'  'B',
*         ' ' 'ZTISSCRCOM-CSTYP'  ZTISSCRCOM-CSTYP
         ' ' 'ZTISSCRCOM-BLART'  ztitcsk-blart,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.

*> 세부화면.
  WRITE g_wrbtr TO l_text_amout CURRENCY ztitcsk-waers.
  PERFORM    set_write_no_mask(ztir9000)
                                    CHANGING  l_text_amout.
  WRITE g_wmwst TO l_text_amout2 CURRENCY ztitcsk-waers.
  PERFORM    set_write_no_mask(ztir9000)
                                    CHANGING  l_text_amout2.
  WRITE g_fwbas TO l_text_amout3 CURRENCY ztitcsk-waers.
  PERFORM    set_write_no_mask(ztir9000)
                                    CHANGING  l_text_amout3.

  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR9000'          '2000',
         ' ' 'ZTITCSK-CSTYP'  ztitcsk-cstyp,
         ' ' 'ZTITCSK-INAME'  ztitcsk-iname,
*         ' ' 'ZTITCSK-BUPLA'  ztitcsk-bupla,
*         ' ' 'ZTITCSK-GSBER'  ztitcsk-gsber,
         ' ' 'ZTITCSK-ZLSPR'  ztitcsk-zlspr,
         ' ' 'ZTITCSK-UZAWE'  ztitcsk-uzawe,
         ' ' 'ZTITCSK-ZLSCH'  ztitcsk-zlsch,
         ' ' 'ZTITCSK-ZTERM'  ztitcsk-zterm,
         ' ' 'ZTITCSK-MWSKZ'  ztitcsk-mwskz,
         ' ' 'ZTITCSK-XBLNR'  ztitcsk-xblnr,
         ' ' 'ZTITCSK-BKTXT'  ztitcsk-bktxt.

  IF NOT ztitig00-chkbp IS INITIAL.
    PERFORM bdc_dynpro_build USING :
         ' ' 'ZTITCSK-BUPLA'  ztitcsk-bupla.
  ENDIF.
  IF NOT ztitig00-chkba IS INITIAL.
    PERFORM bdc_dynpro_build USING :
         ' ' 'ZTITCSK-GSBER'  ztitcsk-gsber.
  ENDIF.

**         ' ' 'ZTITCSK-BUDAT'
**         ' ' 'ZTITCSK-BLART'
**         ' ' 'ZTITCSK-BLDAT'
**         ' ' 'ZTITCSK-BUPLA'  ZTITCSK-bupla,
**         ' ' 'ZTITCSK-GSBER'  ZTITCSK-gsber,
**         ' ' 'ZTITCSK-ZLSPR'  ZTITCSK-zlspr,
**         ' ' 'ZTITCSK-AKONT'
**         ' ' 'ZTITCSK-ZLSCH'  ZTITCSK-zlsch,
*         ' ' 'ZTITCSK-ZTERM'  ztitcsk-zterm,
**         ' ' 'ZTITCSK-WRBTR'  l_text_amout,
**         ' ' 'ZTITCSK-WAERS'
*         ' ' 'ZTITCSK-MWSKZ'  ztitcsk-mwskz,
**         ' ' 'ZTITCSK-WMWST'  l_text_amout2,
**         ' ' 'ZTITCSK-FWBAS'  l_text_amout3,
*         ' ' 'ZTITCSK-XBLNR'  ztitcsk-xblnr,
*         ' ' 'ZTITCSK-BKTXT'  ztitcsk-bktxt.
**         ' ' 'ZTITCSK-EBILL'  ZTITCSK-ebill.
**         ' ' 'ZTITCSK-SGTXT'  ZTITCSK-sgtxt.
*
  CLEAR: g_count.
  LOOP AT it_list INTO gs_list WHERE box = 'X'
                                 AND errmd EQ space.
    ADD 1 TO g_count.

    WRITE gs_list-wrbtr TO l_text_amout CURRENCY gs_list-hwaer.
    PERFORM    set_write_no_mask(ztir9000)
                                      CHANGING  l_text_amout.
    WRITE gs_list-wmwst TO l_text_amout2 CURRENCY gs_list-hwaer.
    PERFORM    set_write_no_mask(ztir9000)
                                      CHANGING  l_text_amout2.
    WRITE gs_list-fwbas TO l_text_amout3 CURRENCY gs_list-hwaer.
    PERFORM    set_write_no_mask(ztir9000)
                                      CHANGING  l_text_amout3.

    IF g_count EQ 1.
      PERFORM bdc_dynpro_build USING :
             ' ' 'ZTISCSIT-EXPCD(01)'  gs_list-expcd,
             ' ' 'ZTISCSIT-IBLNO(01)'  gs_list-iblno,
             ' ' 'ZTISCSIT-WRBTR(01)'  l_text_amout,
             ' ' 'ZTISCSIT-MWSKZ(01)'  gs_list-mwskz,
             ' ' 'ZTISCSIT-WMWST(01)'  l_text_amout2,
             ' ' 'ZTISCSIT-FWBAS(01)'  l_text_amout3.
      l_icssq = 1.
    ELSE.
      PERFORM bdc_dynpro_build USING :
             'X' 'ZTIR9000'          '2000',
             ' ' 'ZTISCSIT-EXPCD(02)'  gs_list-expcd,
             ' ' 'ZTISCSIT-IBLNO(02)'  gs_list-iblno,
             ' ' 'ZTISCSIT-WRBTR(02)'  l_text_amout,
             ' ' 'ZTISCSIT-MWSKZ(02)'  gs_list-mwskz,
             ' ' 'ZTISCSIT-WMWST(02)'  l_text_amout2,
             ' ' 'ZTISCSIT-FWBAS(02)'  l_text_amout3.
      l_icssq = g_count.
    ENDIF.

    IF g_count NE g_cnt.
      PERFORM bdc_dynpro_build USING :
         ' ' 'ZTITCSP-ICSSQ'   l_icssq,
         ' ' 'BDC_OKCODE'       '=TC_2130_PMVC'.
    ENDIF.

  ENDLOOP.

  IF ok_code EQ 'BUC'.
    PERFORM bdc_dynpro_build USING :
           ' ' 'BDC_OKCODE'       '=ZTISAVE'.
  ELSEIF ok_code EQ 'SIMU'.
    PERFORM bdc_dynpro_build USING :
           ' ' 'BDC_OKCODE'       '=ZTISIMUL'.
  ELSE.
    PERFORM bdc_dynpro_build USING :
           ' ' 'BDC_OKCODE'       '=ZTIPOST'.
  ENDIF.

  IF ok_code NE 'SIMU'.
    PERFORM bdc_dynpro_build USING :
           'X' 'SAPLSPO1'          '0300',
           ' ' 'BDC_OKCODE'       '=YES'.
  ENDIF.

******************************************
* one-time vendor.
  PERFORM one_time_vendor_bdc USING lfa1-xcpdk
                                    ztitcso.
*******************************************


ENDFORM.                    " build_collective_posting_data
*&---------------------------------------------------------------------*
*&      Form  p1101_check_input_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p1101_check_input_value .

  DATA: l_xauto TYPE c.

  CLEAR: g_process.

  READ TABLE s_bukrs INDEX 1.

  SELECT SINGLE *
    FROM t001
   WHERE bukrs IN s_bukrs.
  IF sy-subrc NE 0.
    MESSAGE e011 WITH s_bukrs-low.
  ENDIF.

  SELECT SINGLE *
    FROM ztitig00
   WHERE bukrs EQ t001-bukrs.
  IF sy-subrc NE 0.
    MESSAGE e035 WITH t001-bukrs.
  ENDIF.

  SELECT SINGLE *
    FROM ztitig07
   WHERE bukrs EQ t001-bukrs
     AND cstct EQ 'F'.

  SELECT SINGLE *
    FROM t005
   WHERE land1 EQ t001-land1.

  IF sy-tcode EQ c_tcode.
    l_xauto = space.
  ELSE.
    l_xauto = 'X'.
  ENDIF.

  IF g_answer IS INITIAL.
    CALL FUNCTION 'Z_TI_EXPENCES_CODE_BY_GROUP'
      EXPORTING
        xbukrs    = t001-bukrs
        xexpgr    = 'B'
        xauto     = l_xauto
      IMPORTING
        p_answer  = g_answer
      TABLES
        xztitig06 = it_ztitig06
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

  CHECK g_answer EQ 'Y'.

ENDFORM.                    " p1101_check_input_value
*&---------------------------------------------------------------------*
*&      Form  build_posted_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_posted_message  USING    p_subrc.

  IF p_subrc EQ 0.
    MOVE:  sy-msgid   TO  it_msg-msgid,
           sy-msgty   TO  it_msg-msgty,
           sy-msgno   TO  it_msg-msgno,
           sy-msgv1   TO  it_msg-msgv1,
           sy-msgv2   TO  it_msg-msgv2,
           sy-msgv3   TO  it_msg-msgv3,
           sy-msgv4   TO  it_msg-msgv4,
           gs_list-iblno TO  it_msg-refno.
    APPEND it_msg.
  ELSE.
    LOOP AT messtab WHERE msgtyp EQ 'E'.
      MOVE : messtab-msgtyp  TO it_msg-msgty,
             messtab-msgid   TO it_msg-msgid,
             messtab-msgnr   TO it_msg-msgno,
             messtab-msgv1   TO it_msg-msgv1,
             messtab-msgv2   TO it_msg-msgv2,
             messtab-msgv3   TO it_msg-msgv3,
             messtab-msgv4   TO it_msg-msgv4,
             gs_list-iblno   TO it_msg-refno.
      APPEND it_msg.
    ENDLOOP.
    IF sy-subrc NE 0.
      MESSAGE s926.
      MOVE:  sy-msgid   TO  it_msg-msgid,
             'E'        TO  it_msg-msgty,
             sy-msgno   TO  it_msg-msgno,
             sy-msgv1   TO  it_msg-msgv1,
             sy-msgv2   TO  it_msg-msgv2,
             sy-msgv3   TO  it_msg-msgv3,
             sy-msgv4   TO  it_msg-msgv4,
             gs_list-iblno TO  it_msg-refno.
      APPEND it_msg.
    ENDIF.
  ENDIF.

ENDFORM.                    " build_posted_message
*&---------------------------------------------------------------------*
*&      Form  P3500_sort_table_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p3500_sort_table_build .

  CLEAR gs_sort_g.
  gs_sort_g-spos      = '01'.
  gs_sort_g-fieldname = 'BUPLA'.
  gs_sort_g-up        = 'X'.
  gs_sort_g-subtot    = 'X'.
*  gs_sort_g-LEVEL     =  1.
*  gs_sort_g-GROUP     = 'X'.
  APPEND gs_sort_g TO it_sort_g.

  CLEAR gs_sort_g.
  gs_sort_g-spos      = '02'.
  gs_sort_g-fieldname = 'MWSKZ'.
  gs_sort_g-up        = 'X'.
  gs_sort_g-subtot    = 'X'.
*  gs_sort_g-LEVEL     =  1.
*  gs_sort_g-GROUP     = 'X'.
  APPEND gs_sort_g TO it_sort_g.

  CLEAR gs_sort_g.
  gs_sort_g-spos      = '03'.
  gs_sort_g-fieldname = 'IBLNO'.
  gs_sort_g-up        = 'X'.
*  gs_sort_g-subtot    = 'X'.
*  gs_sort_g-LEVEL     =  1.
*  gs_sort_g-GROUP     = 'X'.
  APPEND gs_sort_g TO it_sort_g.

  CLEAR gs_sort_g.
  gs_sort_g-spos      = '04'.
  gs_sort_g-fieldname = 'EXPCD'.
  gs_sort_g-up        = 'X'.
*  gs_sort_g-subtot    = 'X'.
*  gs_sort_g-LEVEL     =  1.
*  gs_sort_g-GROUP     = 'X'.
  APPEND gs_sort_g TO it_sort_g.


ENDFORM.                    " P3500_sort_table_build
*&---------------------------------------------------------------------*
*&      Form  P3800_field_attribute_change
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p3800_field_attribute_change .

* 각 셀의 특성 제어
  DATA : lt_celltab TYPE lvc_t_styl,
         l_index    TYPE i,
         p_mode(01).

  LOOP AT it_list INTO gs_list.
    l_index = sy-tabix.
*> 전표가 입력되었을 경우 입력 불가능
    IF gs_list-icsno IS INITIAL.
      p_mode = 'W'.
    ELSE.
      p_mode = 'O'.
    ENDIF.

    REFRESH lt_celltab.

    PERFORM p3810_fill_celltab USING    p_mode
                               CHANGING lt_celltab.

    CLEAR gs_list-celltab.
    INSERT LINES OF lt_celltab  INTO TABLE gs_list-celltab.
    MODIFY it_list FROM gs_list INDEX l_index.
  ENDLOOP.

ENDFORM.                    " P3800_field_attribute_change
*&---------------------------------------------------------------------*
*&      Form  P3810_fill_celltab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p3810_fill_celltab  USING    p_mode
                        CHANGING pt_celltab TYPE lvc_t_styl.

  DATA : ls_celltab TYPE lvc_s_styl,
         l_mode     TYPE raw4.

  DATA : BEGIN OF l_fieldcat,
           row_pos(04),
           col_pos(04),
           fieldname(30),
         END OF l_fieldcat.

  LOOP AT it_fieldcat_g INTO gs_fieldcat_g.
    ls_celltab-fieldname = gs_fieldcat_g-fieldname.

    IF gs_fieldcat_g-fieldname = 'WRBTR' OR
*       gs_fieldcat_g-fieldname = 'HWAER' OR
       gs_fieldcat_g-fieldname = 'MWSKZ' OR
       gs_fieldcat_g-fieldname = 'WMWST' OR
       gs_fieldcat_g-fieldname = 'FWBAS'.
      IF p_mode EQ 'W'.
        ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
        INSERT ls_celltab INTO TABLE pt_celltab.
      ELSE.
        ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
        INSERT ls_celltab INTO TABLE pt_celltab.
      ENDIF.
    ELSE.
      ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
      INSERT ls_celltab INTO TABLE pt_celltab.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " P3810_fill_celltab
*&---------------------------------------------------------------------*
*&      Form  P9000_REFRESH_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p9000_refresh_display .

*  CALL METHOD g_grid->get_frontend_layout
*    IMPORTING
*      es_layout = gs_layout_g.
*
*  CALL METHOD cl_gui_cfw=>flush.
*
*  CALL METHOD g_grid->set_frontend_layout
*    EXPORTING
*      is_layout = gs_layout_g.
*
*  CALL METHOD g_grid->set_frontend_fieldcatalog
*    EXPORTING
*      it_fieldcatalog = it_fieldcat_g.

  gs_stable-row = 'X'.
  gs_stable-col = 'X'.

  CALL METHOD g_grid->refresh_table_display
    EXPORTING
      is_stable = gs_stable.

*  CALL METHOD cl_gui_cfw=>flush.

ENDFORM.                    " P9000_REFRESH_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  set_one_time_vender_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_one_time_vender_data USING    g_mode
                              CHANGING ok-code.

  CLEAR: ok-code.

  CALL FUNCTION 'Z_TI_GET_ONE_TIME_VENDOR_FIELD'
    EXPORTING
      xztitcsk = ztitcsk
      xlfa1    = lfa1
      xmode    = g_mode
    CHANGING
      xztitcso = ztitcso
      xok_code = ok-code.

ENDFORM.                    " set_one_time_vender_data
*&---------------------------------------------------------------------*
*&      Form  one_time_vendor_bdc
*&---------------------------------------------------------------------*
FORM one_time_vendor_bdc  USING    p_xcpdk
                                   ztitcso LIKE ztitcso.

  IF NOT p_xcpdk IS INITIAL.
    PERFORM bdc_dynpro_build USING :
           'X' 'SAPLZ_TI_COMMON_FUNCTIONS' '8000',
           ' ' 'ZTITCSO-FORM_OF_ADDR' ztitcso-form_of_addr,
           ' ' 'ZTITCSO-NAME'         ztitcso-name        ,
           ' ' 'ZTITCSO-NAME_2'       ztitcso-name_2      ,
           ' ' 'ZTITCSO-NAME_3'       ztitcso-name_3      ,
           ' ' 'ZTITCSO-NAME_4'       ztitcso-name_4      ,
           ' ' 'ZTITCSO-STREET'       ztitcso-street      ,
           ' ' 'ZTITCSO-PO_BOX'       ztitcso-po_box      ,
           ' ' 'ZTITCSO-POBX_PCD'     ztitcso-pobx_pcd    ,
           ' ' 'ZTITCSO-CITY'         ztitcso-city        ,
           ' ' 'ZTITCSO-POSTL_CODE'   ztitcso-postl_code  ,
           ' ' 'ZTITCSO-COUNTRY'      ztitcso-country     ,
           ' ' 'ZTITCSO-REGION'       ztitcso-region      ,
           ' ' 'ZTITCSO-BANK_NO'      ztitcso-bank_no     ,
           ' ' 'ZTITCSO-BANK_CTRY'    ztitcso-bank_ctry   ,
           ' ' 'ZTITCSO-BANK_ACCT'    ztitcso-bank_acct   ,
           ' ' 'ZTITCSO-CTRL_KEY'     ztitcso-ctrl_key    ,
           ' ' 'ZTITCSO-BANK_REF'     ztitcso-bank_ref    ,
           ' ' 'ZTITCSO-INSTR_KEY'    ztitcso-instr_key   ,
           ' ' 'ZTITCSO-DME_IND'      ztitcso-dme_ind     ,
           ' ' 'ZTITCSO-TAX_NO_1'     ztitcso-tax_no_1    ,
           ' ' 'ZTITCSO-TAX_CATEGORY' ztitcso-tax_category,
           ' ' 'ZTITCSO-TAX_NO_2'     ztitcso-tax_no_2    ,
           ' ' 'ZTITCSO-TAX_NO_TY'    ztitcso-tax_no_ty   ,
           ' ' 'ZTITCSO-TAX_NO_3'     ztitcso-tax_no_3    ,
           ' ' 'ZTITCSO-SOLE_PROP'    ztitcso-sole_prop   ,
           ' ' 'ZTITCSO-TAX_NO_4'     ztitcso-tax_no_4    ,
           ' ' 'ZTITCSO-EQUAL_TAX'    ztitcso-equal_tax   ,
           ' ' 'ZTITCSO-BUS_TYPE'     ztitcso-bus_type    ,
           ' ' 'ZTITCSO-SLS_PUR_TX'   ztitcso-sls_pur_tx  ,
           ' ' 'ZTITCSO-IND_TYPE'     ztitcso-ind_type    ,
           ' ' 'ZTITCSO-REP_NAME'     ztitcso-rep_name    ,
           ' ' 'BDC_OKCODE'          '=ZTIOKAY'.
  ENDIF.


ENDFORM.                    " one_time_vendor_bdc
*&---------------------------------------------------------------------*
*&      Form  get_input_value
*&---------------------------------------------------------------------*
*       해당 Row의 변경가능한 필드값을 Get
*----------------------------------------------------------------------*
FORM get_input_value  USING    p_wrbtr
                               p_wmwst
                               p_fwbas
                               p_mwskz
                               p_hwaer
                               pr_data_changed
                               TYPE REF TO cl_alv_changed_data_protocol
                               ps_mod_cells TYPE lvc_s_modi.

*> 금액.
  CALL METHOD pr_data_changed->get_cell_value
    EXPORTING
      i_row_id    = ps_mod_cells-row_id
      i_fieldname = 'WRBTR'
    IMPORTING
      e_value     = p_wrbtr.
*> 세액.
  CALL METHOD pr_data_changed->get_cell_value
    EXPORTING
      i_row_id    = ps_mod_cells-row_id
      i_fieldname = 'WMWST'
    IMPORTING
      e_value     = p_wmwst.

*> 과세표준액.
  CALL METHOD pr_data_changed->get_cell_value
    EXPORTING
      i_row_id    = ps_mod_cells-row_id
      i_fieldname = 'WMWST'
    IMPORTING
      e_value     = p_wmwst.

*> 과세표준액.
  CALL METHOD pr_data_changed->get_cell_value
    EXPORTING
      i_row_id    = ps_mod_cells-row_id
      i_fieldname = 'MWSKZ'
    IMPORTING
      e_value     = p_mwskz.

ENDFORM.                    " get_input_value
*&---------------------------------------------------------------------*
*&      Form  check_input_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_input_value .

  CALL FUNCTION 'FI_VENDOR_DATA'
    EXPORTING
      i_bukrs = ztitcsk-bukrs
      i_lifnr = ztitcsk-lifnr
    IMPORTING
      e_kred  = vf_kred.

  ztitcsk-xcpdk = vf_kred-xcpdk.

  IF ztitcsk-zterm IS INITIAL.
    ztitcsk-zterm = vf_kred-zterm.
  ENDIF.

  CALL FUNCTION 'FI_TERMS_OF_PAYMENT_PROPOSE'
    EXPORTING
      i_bldat = ztitcsk-bldat
      i_budat = ztitcsk-budat
      i_cpudt = sy-datlo
*      i_zfbdt = ZTITCSK-zfbdt
      i_zterm = ztitcsk-zterm
    IMPORTING
      e_zbd1t = ztitcsk-zbd1t
      e_zbd1p = ztitcsk-zbd1p
      e_zbd2t = ztitcsk-zbd2t
      e_zbd2p = ztitcsk-zbd2p
      e_zbd3t = ztitcsk-zbd3t
      e_zlsch = ztitcsk-zlsch
*      e_zschf = ZTITCSK-zlspr
      e_zfbdt = ztitcsk-zfbdt.

ENDFORM.                    " check_input_value
*&---------------------------------------------------------------------*
*&      Form  P3201_F4_FIELD_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p3201_f4_field_build .
* F4 FIELD 등록.
* 주의할점-필드명을 ABC순으로 기술하여야 함

  gs_f4-fieldname  = 'MWSKZ'.
  gs_f4-register   = 'X'.
  APPEND gs_f4 TO it_f4.

  CALL METHOD g_grid->register_f4_for_fields
    EXPORTING
      it_f4 = it_f4.

ENDFORM.                    " P3201_F4_FIELD_BUILD
*&---------------------------------------------------------------------*
*&      Form  p3800_set_title_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form p3800_set_title_text .

** JS전선 회사코드 2007/04 KSH --------------------------------------
  DATA: l_butxt LIKE t001-butxt,
        l_title TYPE lvc_title.
  CLEAR: l_butxt, l_title.
  SELECT SINGLE butxt FROM t001
                      INTO l_butxt
                     WHERE bukrs EQ s_bukrs-low.

  CONCATENATE '회사코드:' s_bukrs-low l_butxt
         INTO l_title SEPARATED BY space.

  CALL METHOD g_grid->set_gridtitle
    EXPORTING
      i_gridtitle = l_title.
** JS전선 회사코드 2007/04 KSH --------------------------------------

endform.                    " p3800_set_title_text
