************************************************************************
* Title         :  ZTIR9140                                            *
*                                                                      *
* Description   : [Report] 통관 비용 관리                              *
*                                                                      *
* Creation Date : 2004/02/18                                           *
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
REPORT  ztir9140       MESSAGE-ID zmti00
                       NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis,   "> Globale Type(ALV)
            kkblo.  "> Generic list types

TYPES:  BEGIN OF ty_list.
        INCLUDE STRUCTURE ztiscccs.
*      표현fields를 위한 보조 fields.
TYPES:  errmd   TYPE c,
        cstcl  LIKE  ztitig06-cstcl,
*        blart  LIKE  ztitig06-blart,
        zterm  LIKE  ztitig07-zterm,
        zlspr  LIKE  ztitig07-zlspr,
        zlsch  LIKE  ztitig07-zlsch,
        uzawe  LIKE  ztitig07-uzawe,
        state  LIKE  ztitcck-state,  "신고자.
        epart  LIKE  ztstig3-epart,  "관세사에 해당하는 edi partner.
        parti  LIKE  ztstig3-parti,  "H=edi partner group.
        lifcc  LIKE  ztstig3-lifnr,  "=LIFNR관세사 계정.
        namcc  LIKE  ztstig3-namet,  "text.
        cdcor  LIKE  ztitcck-cdcor,  "신고세관
        lifor  LIKE  ztsvig5-lifnr,  "ZTSVIG5-CDCOR에 해당하는 계정.
        namor  LIKE  ztsvig5-name1,  "text
        cpyatc LIKE  ztitcck-cpyatc, "결제금액 통화
        cpyat  LIKE  ztitcck-cpyat,  "결제금액
        ccuakc LIKE  ztitcck-ccuakc, "과세가격합계통화
        ccuak  LIKE  ztitcck-ccuak,  "과세가격합계
        ccuauc LIKE  ztitcck-ccuauc, "과세가격합계통화
        ccuau  LIKE  ztitcck-ccuau,  "과세가격합계
        cdutx  LIKE  ztitcck-cdutx,  "관세
        csptx  LIKE  ztitcck-csptx,  "특소세
        caltx  LIKE  ztitcck-caltx,  "주세
        ctrtx  LIKE  ztitcck-ctrtx,  "교통세
        cintx  LIKE  ztitcck-cintx,  "교육세
        cagtx  LIKE  ztitcck-cagtx,  "농특세
        cadtx  LIKE  ztitcck-cadtx,  "부가세
        ctsak  LIKE  ztitcck-ctsak,  "부가세과세과표
        clttx  LIKE  ztitcck-clttx,  "신고지연가산세
        ctotl  LIKE  ztitcck-ctotl,  "합계
        cchcg  LIKE  ztitcck-cchcg,  "관세사 수수료
        expgr  LIKE  ztiscsit-expgr, "비용그룹
        pspnr  LIKE  ztitcck-pspnr,  "프로젝트 정의
        csdrt  LIKE  ztitcck-csdrt,  "란 관세율
        docst  LIKE  ztitcck-docst,  "문서상태
*        bukrs  LIKE  ztitcck-bukrs,  "회사코드
        ekorg  LIKE  ztitcck-ekorg,  "구매조직
        ekgrp  LIKE  ztitcck-ekgrp,  "구매그룹
*        mwskz  LIKE  ztitcsk-mwskz,  "세금코드.
        cdadt  LIKE  ztitcck-cdadt,  "수입신고 의뢰일자
        cdrno  LIKE  ztitcck-cdrno,  "신고의뢰번호
        cnam   LIKE  ztitcck-cnam,
        cdat   LIKE  ztitcck-cdat,
        unam   LIKE  ztitcck-unam,
        udat   LIKE  ztitcck-udat,
        cdcch  LIKE  ztitcck-cdcch,  "신고과
        celltab TYPE lvc_t_styl,     "Cell단위 수정 스타일
        coltab  TYPE lvc_t_scol,
      END   OF ty_list.

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
TABLES: ztitcck,
        ztitcsk,
        ztitig00,     ">[TraSys] 회사별 프로세스 정의.
        ztitig07,     ">[TraSys]  제비용 일괄전기 Default Value관리.
        ztitcsp,
        ztiscsit,
        ztiscccs,
        ztisscrcom,
        t001,
        t005,
        lfa1,
        icon,
        vf_kred.

TABLES: bapi1093_0,
        bapicurx,
        bapiret1.

************************************************************************
* SAP Views                                                            *
************************************************************************

************************************************************************
* CONSTANTS                                                            *
************************************************************************
** 진로산업 Change 2007/04 --------------------------------------
*CONSTANTS:
*    c_bukrs     LIKE t001-bukrs     VALUE '1000'.   ">Company code
** 진로산업 Change 2007/04 --------------------------------------
************************************************************************
* Internal Tables                                                      *
************************************************************************
*> Select용.
DATA: it_list  TYPE STANDARD TABLE OF ty_list,
      gs_list  TYPE ty_list.
DATA: it_disp  TYPE STANDARD TABLE OF ty_list,
      gs_disp  TYPE ty_list.

DATA: BEGIN OF it_vendor  OCCURS 2,
      lifnr    TYPE lifnr,
      END   OF it_vendor.

*> 거래상대방(은행)
DATA: BEGIN OF it_ztstig3  OCCURS 0.
        INCLUDE STRUCTURE ztstig3.
DATA: END   OF it_ztstig3.

*> 비용코드.
DATA: BEGIN OF it_ztitig06  OCCURS 0.
        INCLUDE STRUCTURE ztisig06.
DATA: END   OF it_ztitig06.


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
* PRINT GRID.
DATA:  gs_print_g   TYPE lvc_s_prnt.
DATA : gs_sort_g    TYPE lvc_s_sort.
DATA : it_sort_g    TYPE lvc_t_sort.
DATA : gs_filter_g  TYPE lvc_s_filt.
DATA : it_filter_g  TYPE lvc_t_filt.

DATA: it_fieldcat         TYPE slis_t_fieldcat_alv.
DATA: it_xheader          TYPE slis_t_listheader WITH HEADER LINE.
DATA: it_color            TYPE slis_t_specialcol_alv WITH HEADER LINE.
DATA: it_sort             TYPE slis_t_sortinfo_alv.
DATA: it_filter           TYPE slis_t_filter_alv.
DATA: it_gruppen          TYPE slis_t_sp_group_alv WITH HEADER LINE.
DATA: it_events           TYPE slis_t_event.
DATA: it_event_exit       TYPE slis_t_event_exit WITH HEADER LINE.
DATA: it_listheader       TYPE slis_t_listheader.

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
      g_count             TYPE i,
      g_cnt               TYPE i,
      g_fwbas             TYPE fwbas,
      g_wrbtr             TYPE wrbtr,
      g_wmwst             TYPE wmwst,
      g_line              TYPE i,
      g_gubun             TYPE c,
      ok_code             LIKE sy-ucomm,
      g_success           TYPE i,
      g_error             TYPE i,
      g_linen(3)          TYPE n,
      g_out_text(70)      TYPE c.

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
               IMPORTING e_dyndoc_id.

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
    PERFORM  handle_top_of_page IN PROGRAM (g_repid) USING e_dyndoc_id.
  ENDMETHOD.                    "handle_top_of_page

  METHOD handle_end_of_list.
    PERFORM  handle_end_of_list IN PROGRAM (g_repid) USING e_dyndoc_id.
  ENDMETHOD.                    "handle_end_of_list

ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK dbsel WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_bukrs  FOR ztitcck-bukrs                    "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk
                    MODIF  ID iog ,
  s_ekorg  FOR ztitcck-ekorg  MODIF  ID iog,    "구매조직
  s_ekgrp  FOR ztitcck-ekgrp  MODIF  ID iog,    "구매그룹
  s_bupla  FOR ztitcck-bupla  MODIF  ID iog,    "사업장.
  s_iccno  FOR ztitcck-iccno  MODIF  ID iog     "통관관리번호
                              MEMORY ID ztiiccno,
  s_cdcno  FOR ztitcck-cdcno  MODIF  ID iog,    "(RES)신고(수리)번호
  s_cdrdt  FOR ztitcck-cdrdt  MODIF  ID iog,    "(RES)신고수리일
  s_payda  FOR ztitcck-payda  MODIF  ID iog,    "납부예정일자.
  s_carty  FOR ztitcck-carty  MODIF  ID iog,    "징수형태.
  s_lifnr  FOR ztitcck-lifnr  MODIF  ID iog,    "구매처채권자계정
  s_cdhdt  FOR ztitcck-cdhdt  MODIF  ID iog,    "신고희망일자(CCYYMMDD)
  s_cdadt  FOR ztitcck-cdadt  MODIF  ID iog,    "수입신고 의뢰
  s_cdcdt  FOR ztitcck-cdcdt  MODIF  ID iog,    "(RES)신고일
  s_cdrno  FOR ztitcck-cdrno  MODIF  ID iog,    "(RES)신고의뢰번호
  s_state  FOR ztitcck-state  MODIF  ID iog,    "신고자
  s_cdcor  FOR ztitcck-cdcor  MODIF  ID iog,    "신고세관
  s_cdcch  FOR ztitcck-cdcch  MODIF  ID iog,    "신고과
  s_cimty  FOR ztitcck-cimty  MODIF  ID iog,    "수입자구분
  s_cdapn  FOR ztitcck-cdapn  MODIF  ID iog,    "신고의뢰자 상호
  s_cimnm  FOR ztitcck-cimnm  MODIF  ID iog,    "수입자상호
  s_ccono  FOR ztitcck-ccono  MODIF  ID iog,    "무역업등록번호
  s_cnam   FOR ztitcck-cnam  ,                  "작성인.
  s_cdat   FOR ztitcck-cdat  ,                  "생성일.
  s_unam   FOR ztitcck-unam  ,                  "최종변경인.
  s_udat   FOR ztitcck-udat  .                  "변경일.

SELECTION-SCREEN ULINE.
PARAMETERS: p_step1 RADIOBUTTON GROUP ab1 DEFAULT 'X',
            p_step2 RADIOBUTTON GROUP ab1,
            p_step3 RADIOBUTTON GROUP ab1.
SELECTION-SCREEN ULINE.
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
  DESCRIBE TABLE it_disp LINES g_line.
  IF NOT g_line IS INITIAL.
*> PROGRESS Display.
    g_linen    = 90.
    g_out_text = '리스트를 구성 중입니다 %99999%%'(p03).
    REPLACE '%99999%'(p99) WITH g_linen INTO g_out_text.
    PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.

*> Dynamic Data Table build
    PERFORM 3000_field_category_build.
    PERFORM 3210_exclude_table_build   USING 'IT_EXCLUDE'.
    PERFORM 3500_sort_table_build.
    PERFORM 3700_layout_build.
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

*  REFRESH it_sort.               CLEAR it_sort.
*  REFRESH it_fieldcat.           CLEAR it_fieldcat.
*  REFRESH it_xheader.            CLEAR it_xheader.
*  REFRESH it_color.              CLEAR it_color.
*  REFRESH it_gruppen.            CLEAR it_gruppen.
*  REFRESH it_events .            CLEAR it_events.
*  REFRESH it_event_exit .        CLEAR it_event_exit.
*  REFRESH it_listheader .        CLEAR it_listheader.
*
* PRINT default SETTINGS
*  CLEAR gs_print.
*  gs_print-no_print_listinfos = c_charx.
*  gs_print-no_coverpage       = c_charx.
*  gs_print-no_print_listinfos = c_charx.

ENDFORM.                    " p1000_alv_fields_initial
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
FORM p1001_initialization .

  SET TITLEBAR 'T1000' WITH ' 현황 List'(t10).

ENDFORM.                    " p1001_initialization
*&---------------------------------------------------------------------*
*&      Form  p1101_check_variant_value
*&---------------------------------------------------------------------*
FORM p1101_check_variant_value .

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
*&      Form  3000_field_category_build
*&---------------------------------------------------------------------*
FORM 3000_field_category_build .

  DATA ls_fcat TYPE lvc_s_fcat.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name   = 'ZTISCCCS'
      i_internal_tabname = 'IT_LIST'
    CHANGING
      ct_fieldcat        = it_fieldcat_g[].

  LOOP AT it_fieldcat_g INTO gs_fieldcat_g.
    CLEAR: gs_fieldcat_g-key,
           gs_fieldcat_g-tech,
           gs_fieldcat_g-no_out.
*
    CASE gs_fieldcat_g-fieldname.
      WHEN 'BOX'.
        gs_fieldcat_g-no_out  = 'X'.
      WHEN 'ICON'.
        gs_fieldcat_g-col_pos = 1.
        gs_fieldcat_g-coltext = 'ICON'.
        gs_fieldcat_g-key     = 'X'.
      WHEN 'CDCNO'. "
        gs_fieldcat_g-col_pos = 4.
        gs_fieldcat_g-key     = 'X'.
      WHEN 'ICCNO'.   "
        gs_fieldcat_g-col_pos = 2.
        gs_fieldcat_g-hotspot = 'X'.
        gs_fieldcat_g-key     = 'X'.
      WHEN 'ICCSQ'.   "
        gs_fieldcat_g-col_pos = 3.
*        gs_fieldcat_g-hotspot = 'X'.
        gs_fieldcat_g-key     = 'X'.
*      WHEN 'CARTY'.   "
*        gs_fieldcat_g-col_pos = 4.
*      WHEN 'PAYDA'.   "
*        gs_fieldcat_g-col_pos = 5.
**        gs_fieldcat_g-hotspot = 'X'.
**        gs_fieldcat_g-key     = 'X'.
      WHEN 'WRBTR'.   "
        gs_fieldcat_g-edit       = 'X'.
        gs_fieldcat_g-checktable = '!'.
        gs_fieldcat_g-do_sum     = 'X'.
      WHEN 'WMWST'.   "
        gs_fieldcat_g-edit       = 'X'.
        gs_fieldcat_g-checktable = '!'.
        gs_fieldcat_g-do_sum     = 'X'.
      WHEN 'FWBAS'.   "
        gs_fieldcat_g-edit       = 'X'.
        gs_fieldcat_g-checktable = '!'.
        gs_fieldcat_g-do_sum     = 'X'.
      WHEN 'WAERS'.   "
        gs_fieldcat_g-edit       = 'X'.
        gs_fieldcat_g-checktable = '!'.
      WHEN 'LIFNX'.
        gs_fieldcat_g-outputlen  = 20.
      WHEN 'EXPTX'.
        gs_fieldcat_g-outputlen  = 10.
*      WHEN OTHERS.
*        gs_fieldcat_g-col_pos = gs_fieldcat_g-col_pos + 100.
*        gs_fieldcat_g-no_out = 'X'.
    ENDCASE.
    MODIFY it_fieldcat_g FROM gs_fieldcat_g.
  ENDLOOP.

ENDFORM.                    " 3000_field_category_build
*&---------------------------------------------------------------------*
*&      Form  p3800_field_attribute_change
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p3800_field_attribute_change .

* 각 셀의 특성 제어
  DATA : lt_celltab TYPE lvc_t_styl,
         lt_coltab  TYPE lvc_t_scol,
         l_index    TYPE i,
         p_mode(01).

  LOOP AT it_disp INTO gs_disp.
    l_index = sy-tabix.
*> 전표가 입력되었을 경우 입력 불가능
    IF gs_list-icsno IS INITIAL.
      p_mode = 'W'.
    ELSE.
      p_mode = 'O'.
    ENDIF.

    REFRESH: lt_celltab, lt_coltab.

    PERFORM p3810_fill_celltab USING    p_mode
                               CHANGING lt_celltab.
*> Field별 색상 정의.
    PERFORM p3810_fill_color   CHANGING p_mode
                                        lt_coltab.

    CLEAR: gs_disp-celltab[], gs_disp-coltab[].
    INSERT LINES OF lt_celltab  INTO TABLE gs_disp-celltab.
    INSERT LINES OF lt_coltab   INTO TABLE gs_disp-coltab.
    MODIFY it_disp FROM gs_disp INDEX l_index.
  ENDLOOP.

ENDFORM.                    " p3800_field_attribute_change

*&---------------------------------------------------------------------*
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
FORM p2000_data_selections .

  DATA: ls_ztitcck TYPE ztitcck,
        l_iccsq    TYPE ztiiccsq.

*> PROGRESS Display.
  g_linen    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_linen INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.

*> 수입의뢰 데이타 select.
  SELECT *
        INTO CORRESPONDING FIELDS OF TABLE it_list
        FROM ztitcck
        WHERE bukrs  IN  s_bukrs
          AND iccno  IN  s_iccno
          AND cdcno  IN  s_cdcno
          AND cdrdt  IN  s_cdrdt
          AND payda  IN  s_payda
          AND carty  IN  s_carty
          AND cdrdt  IN  s_cdrdt
          AND bupla  IN  s_bupla
          AND lifnr  IN  s_lifnr
          AND ekorg  IN  s_ekorg
          AND ekgrp  IN  s_ekgrp
          AND cdhdt  IN  s_cdhdt
          AND cdadt  IN  s_cdadt
          AND cdcdt  IN  s_cdcdt
          AND cdrno  IN  s_cdrno
          AND state  IN  s_state
          AND cdcor  IN  s_cdcor
          AND cdcch  IN  s_cdcch
          AND cimty  IN  s_cimty
          AND cdapn  IN  s_cdapn
          AND cimnm  IN  s_cimnm
          AND ccono  IN  s_ccono
          AND cnam   IN  s_cnam    "작성인.
          AND cdat   IN  s_cdat    "생성일.
          AND unam   IN  s_unam    "최종변경인.
          AND udat   IN  s_udat.   "변경일.

  IF sy-subrc NE 0.
    MESSAGE s902.   EXIT.
  ENDIF.

  REFRESH: it_disp.

  LOOP AT it_list INTO gs_list.

    IF gs_list-iccsq EQ '00'.
      CLEAR: ls_ztitcck.
    ELSE.
      l_iccsq = gs_list-iccsq - 1.
      SELECT SINGLE *
        INTO ls_ztitcck
        FROM ztitcck
       WHERE iccno EQ gs_list-iccno
         AND iccsq EQ l_iccsq.
    ENDIF.

*   각각의 문서에서 해당하는 데이터의 필드 가져오기.
    LOOP AT it_ztitig06 WHERE box = 'X'.
      IF it_ztitig06-cstcl EQ 'Z'.
*        "관세사.계정/명.
        SELECT SINGLE lifnr namet
          FROM ztstig3
          INTO (gs_list-lifcc, gs_list-namcc)
         WHERE epart EQ gs_list-state
           AND parti EQ 'H'.

        gs_list-lifnr =  gs_list-lifcc.
        gs_list-lifnx =  gs_list-namcc.
      ELSE.
*        "세관.계정/명.
        SELECT SINGLE lifnr
          FROM ztstig5
          INTO gs_list-lifor
         WHERE cdcor EQ gs_list-cdcor.

        SELECT SINGLE name1
          FROM lfa1
          INTO gs_list-namor
         WHERE lifnr EQ gs_list-lifor.

        gs_list-lifnr =  gs_list-lifor.
        gs_list-lifnx =  gs_list-namor.
      ENDIF.

      CASE it_ztitig06-cstcl.
        WHEN 'B'.
          IF gs_list-carty NE '33'.
            CONTINUE.
          ENDIF.
        WHEN 'C'.
          IF gs_list-carty NE '13'.
            CONTINUE.
          ENDIF.
        WHEN 'D'.
          IF gs_list-carty NE '43'.
            CONTINUE.
          ENDIF.
        WHEN '1'.
      ENDCASE.

      CASE it_ztitig06-cstcl.
        WHEN 'Z'. "관세사 수수료 cchcg.
*        "금액/통화."wmwst/세액, fwbas/과세표준액미사용.
          MOVE: gs_list-cchcg   TO  gs_list-wrbtr,
                gs_list-cchcg   TO  gs_list-fwbas,
                gs_list-ccuakc  TO  gs_list-waers.
*세액.
          CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERN_9'
            EXPORTING
              currency        = 'KRW'
              amount_internal = gs_list-wrbtr
            IMPORTING
              amount_external = bapicurx-bapicurx.

          bapicurx-bapicurx = TRUNC( bapicurx-bapicurx / 10 ).
*          bapicurx-bapicurx = bapicurx-bapicurx * 10.

          CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERN_9'
            EXPORTING
              currency             = 'KRW'
              amount_external      = bapicurx-bapicurx
              max_number_of_digits = 18
            IMPORTING
              amount_internal      = gs_list-wmwst.

        WHEN '1' OR 'B' OR 'C' OR 'D'. "관세 cdutx.

*        "금액/통화."wmwst/세액, fwbas/과세표준액미사용.
          MOVE: gs_list-cdutx   TO  gs_list-wrbtr,
                gs_list-ccuakc  TO  gs_list-waers.
          gs_list-wrbtr = gs_list-wrbtr - ls_ztitcck-cdutx.
        WHEN '2'. "통관부가세cadtx.
*        "금액/통화."wmwst/세액, fwbas/과세표준액미사용.
          MOVE: 0               TO  gs_list-wrbtr,
*                gs_list-cadtx   TO  gs_list-wrbtr,
                gs_list-cadtx   TO  gs_list-wmwst,
                gs_list-ccuakc  TO  gs_list-waers,
                gs_list-ctsak   TO  gs_list-fwbas.

          gs_list-wmwst = gs_list-wmwst - ls_ztitcck-cdutx.
          gs_list-fwbas = gs_list-fwbas - ls_ztitcck-ctsak.

        WHEN '3'. "특소세csptx
*        "금액/통화."wmwst/세액, fwbas/과세표준액미사용.
          MOVE: gs_list-csptx   TO  gs_list-wrbtr,
                gs_list-ccuakc  TO  gs_list-waers.
          gs_list-wrbtr = gs_list-wrbtr - ls_ztitcck-csptx.

        WHEN '4'. "주세 caltx
*        "금액/통화."wmwst/세액, fwbas/과세표준액미사용.
          MOVE: gs_list-caltx   TO  gs_list-wrbtr,
                gs_list-ccuakc  TO  gs_list-waers.
          gs_list-wrbtr = gs_list-wrbtr - ls_ztitcck-caltx.

        WHEN '5'. "교통세 ctrtx
*        "금액/통화."wmwst/세액, fwbas/과세표준액미사용.
          MOVE: gs_list-ctrtx   TO  gs_list-wrbtr,
                gs_list-ccuakc  TO  gs_list-waers.
          gs_list-wrbtr = gs_list-wrbtr - ls_ztitcck-ctrtx.

        WHEN '6'. "교육세 cintx
*        "금액/통화."wmwst/세액, fwbas/과세표준액미사용.
          MOVE: gs_list-cintx   TO  gs_list-wrbtr,
                gs_list-ccuakc  TO  gs_list-waers.
          gs_list-wrbtr = gs_list-wrbtr - ls_ztitcck-cintx.

        WHEN '7'. "농특세 cagtx
*        "금액/통화."wmwst/세액, fwbas/과세표준액미사용.
          MOVE: gs_list-cagtx   TO  gs_list-wrbtr,
                gs_list-ccuakc  TO  gs_list-waers.
          gs_list-wrbtr = gs_list-wrbtr - ls_ztitcck-cagtx.

        WHEN '8'. "신고지연가산세 clttx
*        "금액/통화."wmwst/세액, fwbas/과세표준액미사용.
          MOVE: gs_list-clttx   TO  gs_list-wrbtr,
                gs_list-ccuakc  TO  gs_list-waers.
          gs_list-wrbtr = gs_list-wrbtr - ls_ztitcck-clttx.
      ENDCASE.

*> 금액이 존재하지 않을 경우.
      IF gs_list-wrbtr IS INITIAL AND
         gs_list-wmwst IS INITIAL.
        CONTINUE.
      ENDIF.

      MOVE it_ztitig06-expcd TO gs_list-expcd.
      MOVE it_ztitig06-cstcl TO gs_list-cstcl.

*     수입비용코드/명
      SELECT SINGLE  exptx mwskz
        INTO (gs_list-exptx, gs_list-mwskz)
        FROM ztitig06
       WHERE expgr EQ 'C'
         AND expcd EQ it_ztitig06-expcd.

* 수입비용문서 : 비용 코드별로는 업무적으로 하나씩만 존재.
      SELECT SINGLE icsno wrbtr wmwst fwbas
        INTO (gs_list-icsno,  gs_list-wrbtra,
              gs_list-wmwsta,  gs_list-fwbasa)
        FROM ztitcsp
       WHERE refno EQ gs_list-iccno
         AND amdsq EQ gs_list-iccsq
         AND expcd EQ it_ztitig06-expcd.

      SELECT SINGLE belnr gjahr monat waers
        INTO (gs_list-belnr,  gs_list-gjahr,
              gs_list-monat,  gs_list-waersa)
        FROM ztitcsk
       WHERE icsno EQ gs_list-icsno.
* 비용문서생성시 yellow / 전기문서 생성시 green.
      IF gs_list-icsno IS INITIAL.
        gs_list-icon = icon_red_light.
      ELSE.
        IF gs_list-belnr IS INITIAL.
          gs_list-icon = icon_yellow_light.
        ELSE.
          gs_list-icon = icon_green_light.
        ENDIF.
      ENDIF.

      IF gs_list-belnr IS INITIAL.
        IF p_step2 EQ 'X'.
          CLEAR : gs_list-lifnr, gs_list-lifnx,
                  gs_list-wmwst, gs_list-fwbas,
                  gs_list-expcd, gs_list-exptx, gs_list-wrbtr,
                  gs_list-waers, gs_list-icsno, gs_list-wrbtra,
                  gs_list-wmwsta,gs_list-fwbasa,gs_list-belnr,
                  gs_list-gjahr, gs_list-monat, gs_list-waersa.
          CONTINUE.
        ENDIF.
      ELSE.
        IF p_step1 EQ 'X'.
          CLEAR : gs_list-lifnr, gs_list-lifnx,
                  gs_list-wmwst, gs_list-fwbas,
                  gs_list-expcd, gs_list-exptx, gs_list-wrbtr,
                  gs_list-waers, gs_list-icsno, gs_list-wrbtra,
                  gs_list-wmwsta,gs_list-fwbasa,gs_list-belnr,
                  gs_list-gjahr, gs_list-monat, gs_list-waersa.
          CONTINUE.
        ENDIF.
      ENDIF.

      IF gs_list-waers IS INITIAL.
        gs_list-waers = 'KRW'.
      ENDIF.
      IF gs_list-waersa IS INITIAL.
        gs_list-waersa = 'KRW'.
      ENDIF.

      APPEND gs_list TO it_disp.
      CLEAR : gs_list-lifnr, gs_list-lifnx,
              gs_list-wmwst, gs_list-fwbas,
              gs_list-expcd, gs_list-exptx, gs_list-wrbtr,
              gs_list-waers, gs_list-icsno, gs_list-wrbtra,
              gs_list-wmwsta,gs_list-fwbasa,gs_list-belnr,
              gs_list-gjahr, gs_list-monat, gs_list-waersa.
    ENDLOOP.

    MODIFY  it_list FROM gs_list.

  ENDLOOP.

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
  SET TITLEBAR  'T1000' WITH '현황 List'(t10).

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
        it_outtab           = it_disp."it_list

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
          event_receiver->handle_data_changed          FOR g_grid,
          event_receiver->handle_data_changed_finished FOR g_grid,
          event_receiver->handle_double_click          FOR g_grid,
          event_receiver->handle_hotspot_click         FOR g_grid,
          event_receiver->handle_user_command          FOR g_grid.

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

* append an icon to show 적하보험문서
  CLEAR ls_toolbar.
  MOVE 0                    TO ls_toolbar-butn_type.
  MOVE 'ZTIT402'            TO ls_toolbar-function.
  MOVE icon_price           TO ls_toolbar-icon.
  MOVE '수정'               TO ls_toolbar-quickinfo.
  MOVE '통관비용 수정'      TO ls_toolbar-text.
  MOVE space                TO ls_toolbar-disabled.
  APPEND ls_toolbar         TO r_object->mt_toolbar.

* append an icon to show 적하보험문서
  CLEAR ls_toolbar.
  MOVE 0                    TO ls_toolbar-butn_type.
  MOVE 'ZTIT901'            TO ls_toolbar-function.
  MOVE icon_financing       TO ls_toolbar-icon.
  MOVE '전기'               TO ls_toolbar-quickinfo.
  MOVE '전기'               TO ls_toolbar-text.
  MOVE space                TO ls_toolbar-disabled.
  APPEND ls_toolbar         TO r_object->mt_toolbar.

ENDFORM.                    " handle_toolbar

*&--------------------------------------------------------------------*
*&      Form  handle_data_changed
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->ER_DATA_CHAtext
*---------------------------------------------------------------------*
FORM  handle_data_changed  USING er_data_changed
                           TYPE REF TO cl_alv_changed_data_protocol.
  DATA : ls_mod_cells TYPE lvc_s_modi,
         ls_cells     TYPE lvc_s_modi.


  LOOP AT er_data_changed->mt_good_cells INTO ls_mod_cells.
    CASE ls_mod_cells-fieldname.
      WHEN 'WAERS'.                    "

*        data : L_WRBTR(20) type c. "like ZTITCCK-cdutx.
*
*        READ TABLE it_disp   INTO  gs_disp
*                             INDEX ls_mod_cells-row_id .
*
*        write gs_disp-WRBTR currency gs_disp-waers to L_WRBTR.
*
*        CALL METHOD er_data_changed->modify_cell
*          EXPORTING
*            i_row_id    = ls_mod_cells-row_id
*            i_fieldname = 'WRBTR'
*            i_value     = L_WRBTR.

*        IF gs_list-WRBTR  EQ  ls_mod_cells-value .
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
    ENDCASE.
  ENDLOOP.

** ICON/CHECK BOX 변경
*  PERFORM 1100_icon_checkbox_part.
*  -->  gt_display-icon  = icon_green_light.
*       gt_display-icon  = icon_yellow_light.
*
*  CALL METHOD rr_data_changed->modify_cell
*              EXPORTING i_row_id    = rs_mod_cells-row_id
*                        i_fieldname = 'ICON'
*                        i_value     = gt_display-icon.
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

  READ TABLE it_disp INTO gs_disp INDEX  p_row.

  CASE p_column.
    WHEN 'ICCNO'.
      PERFORM display_cc_document(ztir0000)
                                      USING gs_disp-iccno
                                            gs_disp-iccsq.
    WHEN 'ICSNO'.
      PERFORM display_cs_document(ztir0000)
                                      USING gs_disp-icsno
                                            t001-bukrs.
  ENDCASE.

ENDFORM.                    "handle_double_click
*&---------------------------------------------------------------------*
*&      Form  handle_hotspot_click
*&---------------------------------------------------------------------*
FORM handle_hotspot_click  USING e_row_id    TYPE lvc_s_row
                                 e_column_id TYPE lvc_s_col.

  READ TABLE it_disp INTO gs_disp INDEX e_row_id-index.

  CASE e_column_id-fieldname.
    WHEN 'ICCNO'.
      PERFORM display_cc_document(ztir0000)
                                      USING gs_disp-iccno
                                            gs_disp-iccsq.

    WHEN 'ICSNO'.
** 진로산업 Change 2007/04 --------------------------------------
*      PERFORM display_cs_document(ztir0000)
*                                      USING gs_disp-icsno
*                                      '1000'.
      PERFORM display_cs_document(ztir0000)
                                      USING gs_disp-icsno
                                            gs_disp-bukrs.
** 진로산업 Change 2007/04 --------------------------------------
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
  ctu_params-dismode  = 'N'. ">처리모드n
  ctu_params-updmode  = 'S'. ">갱신모드
  ctu_params-cattmode = ' '. ">CATT 모드...
  ctu_params-defsize  = ' '. ">기본화면 크기
  ctu_params-racommit = 'X'.
  ctu_params-nobinpt  = ' ' .
  ctu_params-nobiend  = ' '.

  CLEAR g_count.
  IF r_ucomm EQ 'ZTIT402' OR
     r_ucomm EQ 'ZTIT901' OR
     r_ucomm EQ 'ZTIT901S'.
    PERFORM  get_selected_row  TABLES lt_row_no.
  ENDIF.
  CHECK g_count GT 0.

  CASE r_ucomm.
    WHEN 'ZTIT402'.
*> 보험료 정보를 Update.
      PERFORM  modify_customs_table.

    WHEN 'ZTIT901'.
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
      CLEAR: g_count, g_wrbtr, g_wmwst, g_fwbas.
      REFRESH: it_vendor.

*> 데이타 체크.
      LOOP AT it_disp INTO gs_disp WHERE box = 'X'.
        CLEAR: gs_disp-errmd.

        MOVE: gs_disp-lifnr  TO  it_vendor-lifnr.
        COLLECT it_vendor.

        IF gs_disp-lifnr IS INITIAL.
          gs_disp-errmd = 'X'.
          MESSAGE s508 WITH gs_disp-iccno 'Vnedor'.
          PERFORM set_return_message_fill USING 'E'.
        ENDIF.

        IF NOT gs_disp-icsno IS INITIAL.
          gs_list-errmd = 'X'.
          IF NOT gs_list-belnr IS INITIAL.
            MESSAGE s132 WITH gs_disp-iccno ' ' '전기'.
          ELSE.
            MESSAGE s132 WITH gs_disp-iccno ' ' '생성'.
          ENDIF.
          PERFORM set_return_message_fill USING 'E'.
        ENDIF.

        IF gs_disp-wrbtr IS INITIAL AND
           gs_disp-wmwst IS INITIAL.
          gs_disp-errmd = 'X'.
          MESSAGE s508 WITH gs_disp-iccno  '통관비용 및 부가세'.
          PERFORM set_return_message_fill USING 'E'.
        ENDIF.

        IF NOT gs_disp-wmwst IS INITIAL AND
               gs_disp-fwbas IS INITIAL.
          gs_disp-errmd = 'X'.
          MESSAGE s508 WITH gs_disp-iccno '과세표준액'.
          PERFORM set_return_message_fill USING 'E'.
        ENDIF.

        IF gs_disp-waers IS INITIAL.
          gs_disp-errmd = 'X'.
          MESSAGE s508 WITH gs_disp-iccno '통화'.
          PERFORM set_return_message_fill USING 'E'.
        ENDIF.

        ADD gs_disp-wrbtr TO g_wrbtr.
        ADD gs_disp-wmwst TO g_wmwst.
        ADD gs_disp-fwbas TO g_fwbas.
        MODIFY it_disp FROM gs_disp.
      ENDLOOP.

*> 합계전표일 경우 Vendor 등을 체크함.
      IF ztisscrcom-monsc EQ 'S'.
        DESCRIBE TABLE it_vendor LINES g_line.
        CASE g_line.
          WHEN 0.
            MESSAGE s509.
            PERFORM set_return_message_fill USING 'E'.
          WHEN 1.
          WHEN OTHERS.
            MESSAGE s510.
            PERFORM set_return_message_fill USING 'E'.
        ENDCASE.
*> Error Message Display.
        PERFORM display_error_message.
        DESCRIBE TABLE it_msg LINES g_line.
        CHECK g_line EQ 0.
      ENDIF.

*> 전기확인용 대화화면 Call
      CLEAR: ok_code.
*> 전기용 HEADER DATA Fill
      PERFORM   fill_default_header_data.
**> 확인 대화상자 Call
      CALL SCREEN '0200' STARTING AT 1 8.
      IF ok_code EQ 'ABBR'.
        MESSAGE s900.
        EXIT.
      ELSEIF ok_code EQ 'SIMU'.
        ctu_params-dismode  = 'E'. ">처리모드
      ENDIF.
      CLEAR: g_success, g_error.

**> 통관비용 정보를 Update.
*      PERFORM modify_customs_table.
      IF ztisscrcom-monsc EQ 'S'.
        PERFORM execute_collective_posting.
      ELSE.
        PERFORM execute_individual_posting.
      ENDIF.
  ENDCASE.

*> Error Message Display.
  PERFORM display_error_message.

*> 검색조건에 해당하는 데이타를 Select.
  CHECK g_success GT 0.
  PERFORM p2000_data_selections.
  PERFORM 3000_field_category_build.
  PERFORM p3800_field_attribute_change.
*  PERFORM p9000_refresh_display.
  CALL METHOD g_grid->refresh_table_display.

ENDFORM.                    "handle_user_command_grid
*&---------------------------------------------------------------------*
*&      Form  3210_exclude_table_build
*&---------------------------------------------------------------------*
FORM 3210_exclude_table_build USING p_tabname.

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

ENDFORM.                    " 3210_exclude_table_build
*&---------------------------------------------------------------------*
*&      Form  3700_layout_build
*&---------------------------------------------------------------------*
FORM 3700_layout_build .

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
  gs_layout_g-ctab_fname = 'COLTAB'.

* 합을 제일 윗라인에 DISPLAY
*  gs_layout_g-totals_bef = 'X'.

ENDFORM.                    " 3700_layout_build
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
*&      Form  3500_sort_table_build
*&---------------------------------------------------------------------*
FORM 3500_sort_table_build .

* it_sort_g    TYPE lvc_t_sort.

*  CLEAR gs_sort_g.
*  gs_sort_g-spos      = '01'.
*  gs_sort_g-fieldname = 'ICCNO'.
*  gs_sort_g-up        = 'X'.
**  gs_sort_g-LEVEL     =  1.
**  gs_sort_g-GROUP     = 'X'.
*  APPEND gs_sort_g TO it_sort_g.
*
*
*  CLEAR gs_sort_g.
*  gs_sort_g-spos      = '02'.
*  gs_sort_g-fieldname = 'CDCNO'.
*  gs_sort_g-up        = 'X'.
*  gs_sort_g-subtot    = 'X'.
*  APPEND gs_sort_g TO it_sort_g.
*
*  CLEAR gs_sort_g.
*  gs_sort_g-spos      = '03'.
*  gs_sort_g-fieldname = 'CDRDT'.
*  gs_sort_g-up        = 'X'.
*  APPEND gs_sort_g TO it_sort_g.
*
  CLEAR gs_sort_g.
  gs_sort_g-spos      = '01'.
  gs_sort_g-fieldname = 'LIFNR'.
  gs_sort_g-up        = 'X'.
  gs_sort_g-subtot    = 'X'.
  APPEND gs_sort_g TO it_sort_g.

  CLEAR gs_sort_g.
  gs_sort_g-spos      = '02'.
  gs_sort_g-fieldname = 'EXPCD'.
  gs_sort_g-up        = 'X'.
  gs_sort_g-subtot    = 'X'.
  APPEND gs_sort_g TO it_sort_g.

  CLEAR gs_sort_g.
  gs_sort_g-spos      = '03'.
  gs_sort_g-fieldname = 'ICCNO'.
  gs_sort_g-up        = 'X'.
*  gs_sort_g-LEVEL     =  1.
*  gs_sort_g-GROUP     = 'X'.
  APPEND gs_sort_g TO it_sort_g.

*SPOS	정렬순서
*FIELDNAME	ALV 제어: 내부테이블필드의 필드이름
*UP	단일문자 플래그
*DOWN	단일문자 플래그
*GROUP	제어중단: 페이지구분삽입, 밑줄
*SUBTOT	출력소계
*COMP	단일문자 플래그
*EXPA	단일문자 플래그
*SELTEXT	정렬기준
*OBLIGATORY	단일문자 플래그
*LEVEL	정수
*NO_OUT	단일문자 플래그

ENDFORM.                    " 3500_sort_table_build
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
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
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
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

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_BEARBEITEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_bearbeiten INPUT.
  SET SCREEN 0. LEAVE SCREEN.
ENDMODULE.                 " EXIT_BEARBEITEN  INPUT
*&---------------------------------------------------------------------*
*&      Form  ZTIT905_bdc_data
*&---------------------------------------------------------------------*
FORM ztit905_bdc_data .

  LOOP AT it_disp INTO gs_disp WHERE box = 'X'.

    PERFORM bdc_ztitcck_update USING gs_disp.

    PERFORM bdc_ztitcsk_create USING gs_disp.
    "전기와 생성여부는 내부에서 .

    PERFORM bdc_ztitcsk_update USING gs_disp.
    "전기와 생성여부는 내부에서 .
******************************************************
*      PERFORM bdc_transaction USING 'ZTIT905' g_subrc.

    IF g_subrc EQ 0.

      MESSAGE s202 WITH gs_disp-iccno.

      MOVE:  sy-msgid   TO  it_msg-msgid,
             sy-msgty   TO  it_msg-msgty,
             sy-msgno   TO  it_msg-msgno,
             sy-msgv1   TO  it_msg-msgv1,
             sy-msgv2   TO  it_msg-msgv2,
             sy-msgv3   TO  it_msg-msgv3,
             sy-msgv4   TO  it_msg-msgv4,
             gs_disp-iccno TO  it_msg-refno.
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
               gs_disp-iccno   TO it_msg-refno.
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
               gs_disp-iccno TO  it_msg-refno.
        APPEND it_msg.
      ENDIF.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE it_msg LINES g_line.
  IF g_line GT 0.
    CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
      EXPORTING
        xdocno_show = 'X'
      TABLES
        xmsg        = it_msg.
  ENDIF.

ENDFORM.                    " ZTIT905_bdc_data
*&---------------------------------------------------------------------*
*&      Form  bdc_ZTITCCK_update
*&---------------------------------------------------------------------*
FORM bdc_ztitcck_update  USING    gs_disp TYPE ty_list.

*            PERFORM bdc_dynpro_build USING :
*                   'X' 'ZTIR1000'          '0200',
*                   ' ' 'ZTISSCRCOM-IIPNO'  gs_list-iccno,
*                   ' ' 'ZTISSCRCOM-AMSEQ'  gs_list-amdsq,
*                   ' ' 'BDC_OKCODE'       '=ZTIENTER'.
**> 세부화면.
*           WRITE gs_list-itpa1 TO l_text_amout CURRENCY gs_list-itpa1c.
*            PERFORM    set_write_no_mask(ZTIr9000)
*                                              CHANGING  l_text_amout.
*
*            PERFORM bdc_dynpro_build USING :
*                   'X' 'ZTIR1000'          '2000',
*                   ' ' 'ZTITIP01-ITPA1'    l_text_amout,
*                   ' ' 'BDC_OKCODE'       '=ZTISAVE'.
*
*            PERFORM bdc_dynpro_build USING :
*                   'X' 'SAPLSPO1'          '0300',
*                   ' ' 'BDC_OKCODE'       '=YES'.



ENDFORM.                    " bdc_ZTITCCK_update
*&---------------------------------------------------------------------*
*&      Form  bdc_ZTITCSK_create
*&---------------------------------------------------------------------*
FORM bdc_ztitcsk_create  USING    gs_disp TYPE ty_list.

ENDFORM.                    " bdc_ZTITCSK_create
*&---------------------------------------------------------------------*
*&      Form  bdc_ZTITCSK_update
*&---------------------------------------------------------------------*
FORM bdc_ztitcsk_update  USING    gs_disp TYPE ty_list.

ENDFORM.                    " bdc_ZTITCSK_update
*&---------------------------------------------------------------------*
*&      Form  get_selected_row
*&---------------------------------------------------------------------*
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

    CLEAR gs_disp-box.
    MODIFY it_disp FROM gs_disp TRANSPORTING box WHERE box = 'X'.

    LOOP AT pt_row_no.
      CHECK pt_row_no-row_id > 0.
      ADD 1 TO g_count.
      READ TABLE it_disp INTO gs_disp INDEX pt_row_no-row_id.
      IF gs_disp-box NE 'X'.
        gs_disp-box = 'X'.
      ENDIF.
      MODIFY it_disp FROM gs_disp INDEX pt_row_no-row_id.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " get_selected_row
*&---------------------------------------------------------------------*
*&      Form  modify_customs_table
*&---------------------------------------------------------------------*
FORM modify_customs_table .

  DATA l_subrc LIKE sy-subrc.

  LOOP AT it_disp INTO gs_disp WHERE box   EQ 'X'
                                 AND errmd EQ space.
    SELECT SINGLE *
      FROM ztitcck
     WHERE iccno   EQ  gs_disp-iccno.


    CASE gs_disp-cstcl.
      WHEN 'Z'. "관세사 수수료 cchcg.
        IF gs_disp-wrbtr EQ ztitcck-cchcg.
          MESSAGE s511 WITH gs_disp-iccno '관세사 수수료'.
          PERFORM set_return_message_fill USING 'W'.
        ELSE.
*      > build BDC data
          PERFORM build_cc_changed_bdcdata.
*      > Call transaction
          PERFORM bdc_transaction        USING 'ZTIT402' l_subrc.
*      > build Message internal table.
          PERFORM build_changed_message  USING l_subrc.
          IF l_subrc NE 0.
            gs_disp-errmd = 'X'.
          ENDIF.
        ENDIF.
      WHEN '1'. "관세 cdutx.
        IF gs_disp-wrbtr EQ ztitcck-cdutx.
          MESSAGE s511 WITH gs_disp-iccno '특소세'.
          PERFORM set_return_message_fill USING 'W'.
        ELSE.
*      > build BDC data
          PERFORM build_cc_changed_bdcdata.
*      > Call transaction
          PERFORM bdc_transaction        USING 'ZTIT402' l_subrc.
*      > build Message internal table.
          PERFORM build_changed_message  USING l_subrc.
          IF l_subrc NE 0.
            gs_disp-errmd = 'X'.
          ENDIF.
        ENDIF.
      WHEN '2'. "통관부가세cadtx.
        IF gs_disp-wmwst EQ ztitcck-cadtx AND
           gs_disp-fwbas EQ ztitcck-ctsak.
          MESSAGE s511 WITH gs_disp-iccno '부가세 관련'.
          PERFORM set_return_message_fill USING 'W'.
        ELSE.
*      > build BDC data
          PERFORM build_cc_changed_bdcdata.
*      > Call transaction
          PERFORM bdc_transaction        USING 'ZTIT402' l_subrc.
*      > build Message internal table.
          PERFORM build_changed_message  USING l_subrc.
          IF l_subrc NE 0.
            gs_disp-errmd = 'X'.
          ENDIF.
        ENDIF.
      WHEN '3'. "특소세csptx
        IF gs_disp-wrbtr EQ ztitcck-csptx.
          MESSAGE s511 WITH gs_disp-iccno '특소세'.
          PERFORM set_return_message_fill USING 'W'.
        ELSE.
*      > build BDC data
          PERFORM build_cc_changed_bdcdata.
*      > Call transaction
          PERFORM bdc_transaction        USING 'ZTIT402' l_subrc.
*      > build Message internal table.
          PERFORM build_changed_message  USING l_subrc.
          IF l_subrc NE 0.
            gs_disp-errmd = 'X'.
          ENDIF.
        ENDIF.
      WHEN '4'. "주세 caltx
        IF gs_disp-wrbtr EQ ztitcck-caltx.
          MESSAGE s511 WITH gs_disp-iccno '주세'.
          PERFORM set_return_message_fill USING 'W'.
        ELSE.
*      > build BDC data
          PERFORM build_cc_changed_bdcdata.
*      > Call transaction
          PERFORM bdc_transaction        USING 'ZTIT402' l_subrc.
*      > build Message internal table.
          PERFORM build_changed_message  USING l_subrc.
          IF l_subrc NE 0.
            gs_disp-errmd = 'X'.
          ENDIF.
        ENDIF.
      WHEN '5'. "교통세 ctrtx
        IF gs_disp-wrbtr EQ ztitcck-ctrtx.
          MESSAGE s511 WITH gs_disp-iccno '교통세'.
          PERFORM set_return_message_fill USING 'W'.
        ELSE.
*      > build BDC data
          PERFORM build_cc_changed_bdcdata.
*      > Call transaction
          PERFORM bdc_transaction        USING 'ZTIT402' l_subrc.
*      > build Message internal table.
          PERFORM build_changed_message  USING l_subrc.
          IF l_subrc NE 0.
            gs_disp-errmd = 'X'.
          ENDIF.
        ENDIF.
      WHEN '6'. "교육세 cintx
        IF gs_disp-wrbtr EQ ztitcck-cintx.
          MESSAGE s511 WITH gs_disp-iccno '교육세'.
          PERFORM set_return_message_fill USING 'W'.
        ELSE.
*      > build BDC data
          PERFORM build_cc_changed_bdcdata.
*      > Call transaction
          PERFORM bdc_transaction        USING 'ZTIT402' l_subrc.
*      > build Message internal table.
          PERFORM build_changed_message  USING l_subrc.
          IF l_subrc NE 0.
            gs_disp-errmd = 'X'.
          ENDIF.
        ENDIF.
      WHEN '7'. "농특세 cagtx
        IF gs_disp-wrbtr EQ ztitcck-cagtx.
          MESSAGE s511 WITH gs_disp-iccno '농특세'.
          PERFORM set_return_message_fill USING 'W'.
        ELSE.
*      > build BDC data
          PERFORM build_cc_changed_bdcdata.
*      > Call transaction
          PERFORM bdc_transaction        USING 'ZTIT402' l_subrc.
*      > build Message internal table.
          PERFORM build_changed_message  USING l_subrc.
          IF l_subrc NE 0.
            gs_disp-errmd = 'X'.
          ENDIF.
        ENDIF.
      WHEN '8'. "신고지연가산세 clttx
        IF gs_disp-wrbtr EQ ztitcck-clttx.
          MESSAGE s511 WITH gs_disp-iccno '신고지연가산세'.
          PERFORM set_return_message_fill USING 'W'.
        ELSE.
*      > build BDC data
          PERFORM build_cc_changed_bdcdata.
*      > Call transaction
          PERFORM bdc_transaction        USING 'ZTIT402' l_subrc.
*      > build Message internal table.
          PERFORM build_changed_message  USING l_subrc.
          IF l_subrc NE 0.
            gs_disp-errmd = 'X'.
          ENDIF.
        ENDIF.
    ENDCASE.

    MODIFY it_disp FROM gs_disp.
  ENDLOOP.


ENDFORM.                    " modify_customs_table
*&---------------------------------------------------------------------*
*&      Form  build_ip_changed_bdcdata
*&---------------------------------------------------------------------*
FORM build_cc_changed_bdcdata .

  DATA: l_text_amout(20),
        l_text_amout1(20) .

  REFRESH: bdcdata.
  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR4000'          '0200',
         ' ' 'ZTISSCRCOM-ICCNO'  gs_disp-iccno,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.
*> 세부화면.
  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR4000'          '2000',
         ' ' 'BDC_OKCODE'        '=TABSTRIP_FC2'.

*******************************************
  IF gs_disp-cstcl EQ '2'.    ">부가일 경우.
    WRITE gs_disp-wmwst TO l_text_amout  CURRENCY gs_disp-ccuakc.
    WRITE gs_disp-fwbas TO l_text_amout1 CURRENCY gs_disp-ccuakc.
  ELSE.
    WRITE gs_disp-wrbtr TO l_text_amout CURRENCY gs_disp-ccuakc.
  ENDIF.
  PERFORM    set_write_no_mask(ztir9000)
                                    CHANGING : l_text_amout,
                                               l_text_amout1.

  CASE gs_disp-cstcl.
    WHEN 'Z'. "관세사 수수료 cchcg.
      PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR4000'          '2000',
         ' ' 'ZTITCCK-CCHCG'    l_text_amout,
*         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
    WHEN '1'. "관세 cdutx.
      PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR4000'          '2000',
         ' ' 'ZTITCCK-CDUTX'    l_text_amout,
*         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
    WHEN '2'. "통관부가세cadtx.
      PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR4000'          '2000',
         ' ' 'ZTITCCK-CADTX'    l_text_amout,
         ' ' 'ZTITCCK-CTSAK'    l_text_amout1,
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
    WHEN '3'. "특소세csptx
      PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR4000'          '2000',
         ' ' 'ZTITCCK-CSPTX'    l_text_amout,
*         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
    WHEN '4'. "주세 caltx
      PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR4000'          '2000',
         ' ' 'ZTITCCK-CALTX'    l_text_amout,
*         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
    WHEN '5'. "교통세 ctrtx
      PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR4000'          '2000',
         ' ' 'ZTITCCK-CTRTX'    l_text_amout,
*         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
    WHEN '6'. "교육세 cintx
      PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR4000'          '2000',
         ' ' 'ZTITCCK-CINTX'    l_text_amout,
*         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
    WHEN '7'. "농특세 cagtx
      PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR4000'          '2000',
         ' ' 'ZTITCCK-CAGTX'    l_text_amout,
*         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
    WHEN '8'. "신고지연가산세 clttx
      PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR4000'          '2000',
         ' ' 'ZTITCCK-CLTTX'    l_text_amout,
*         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
  ENDCASE.
*******************************************
*  case gs_disp-expcd.
*    when p_cdutx.
*      WRITE gs_disp-wrbtr TO l_text_amout CURRENCY gs_disp-ccuakc.
*      PERFORM    set_write_no_mask(ZTIr9000)
*                                        CHANGING  l_text_amout.
*      PERFORM bdc_dynpro_build USING :
*         'X' 'ZTIR4000'          '2000',
*         ' ' 'ZTITCCK-CDUTX'    l_text_amout,
**         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
*                                 "통관에서 자동로직 들어가면 삭제.
*         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
*
*    when p_CADTX.
*      WRITE gs_disp-wrbtr TO l_text_amout CURRENCY gs_disp-ccuakc.
*      PERFORM    set_write_no_mask(ZTIr9000)
*                                        CHANGING  l_text_amout.
*      PERFORM bdc_dynpro_build USING :
*         'X' 'ZTIR4000'          '2000',
*         ' ' 'ZTITCCK-CADTX'    l_text_amout,
**         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
*         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
*
*    when p_CCHCG.
*      WRITE gs_disp-wrbtr TO l_text_amout CURRENCY gs_disp-ccuakc.
*      PERFORM    set_write_no_mask(ZTIr9000)
*                                        CHANGING  l_text_amout.
*      PERFORM bdc_dynpro_build USING :
*         'X' 'ZTIR4000'          '2000',
*         ' ' 'ZTITCCK-CCHCG'    l_text_amout,
**         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
*         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
*
*  endcase.

  PERFORM bdc_dynpro_build USING :
         'X' 'SAPLSPO1'          '0300',
         ' ' 'BDC_OKCODE'       '=YES'.

ENDFORM.                    " build_ip_changed_bdcdata
*&---------------------------------------------------------------------*
*&      Form  build_changed_message
*&---------------------------------------------------------------------*
FORM build_changed_message  USING    p_subrc.

  IF p_subrc EQ 0.
****************************************
    CASE gs_disp-cstcl.
      WHEN 'Z'. "관세사 수수료 cchcg.
        MESSAGE s507 WITH gs_disp-iccno '통관수수료'.
      WHEN '1'. "관세 cdutx.
        MESSAGE s507 WITH gs_disp-iccno '관세'.
      WHEN '2'. "통관부가세cadtx.
        MESSAGE s507 WITH gs_disp-iccno '부가세'.
      WHEN '3'. "특소세csptx
        MESSAGE s507 WITH gs_disp-iccno '특소세'.
      WHEN '4'. "주세 caltx
        MESSAGE s507 WITH gs_disp-iccno '주세'.
      WHEN '5'. "교통세 ctrtx
        MESSAGE s507 WITH gs_disp-iccno '교통세'.
      WHEN '6'. "교육세 cintx
        MESSAGE s507 WITH gs_disp-iccno '교육세'.
      WHEN '7'. "농특세 cagtx
        MESSAGE s507 WITH gs_disp-iccno '농특세'.
      WHEN '8'. "신고지연가산세 clttx
        MESSAGE s507 WITH gs_disp-iccno '신고지연가산세'.
    ENDCASE.
******************************************************

    MOVE:  sy-msgid   TO  it_msg-msgid,
           sy-msgty   TO  it_msg-msgty,
           sy-msgno   TO  it_msg-msgno,
           sy-msgv1   TO  it_msg-msgv1,
           sy-msgv2   TO  it_msg-msgv2,
           sy-msgv3   TO  it_msg-msgv3,
           sy-msgv4   TO  it_msg-msgv4,
           gs_disp-iccno TO  it_msg-refno.
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
             gs_disp-iccno   TO it_msg-refno.
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
             gs_disp-iccno TO  it_msg-refno.
      APPEND it_msg.
    ENDIF.
  ENDIF.

ENDFORM.                    " build_changed_message
*&---------------------------------------------------------------------*
*&      Form  set_return_message_fill
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2815   text
*----------------------------------------------------------------------*
FORM set_return_message_fill  USING   p_msgty.

  MOVE:  sy-msgid  TO  it_msg-msgid,
         p_msgty   TO  it_msg-msgty,
         sy-msgno  TO  it_msg-msgno,
         sy-msgv1  TO  it_msg-msgv1,
         sy-msgv2  TO  it_msg-msgv2,
         sy-msgv3  TO  it_msg-msgv3,
         sy-msgv4  TO  it_msg-msgv4.

  COLLECT it_msg.

ENDFORM.                    " set_return_message_fill
*&---------------------------------------------------------------------*
*&      Form  display_error_message
*&---------------------------------------------------------------------*
FORM display_error_message .

  DESCRIBE TABLE it_msg LINES g_line.
  IF g_line GT 0.
    CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
      EXPORTING
        xdocno_show = ' '
      TABLES
        xmsg        = it_msg.
  ENDIF.

ENDFORM.                    " display_error_message
*&---------------------------------------------------------------------*
*&      Form  fill_default_header_data
*&---------------------------------------------------------------------*
FORM fill_default_header_data .

  LOOP AT it_disp INTO gs_disp WHERE box = 'X'.
    EXIT.
  ENDLOOP.

  SELECT SINGLE *
    FROM ztitig07
   WHERE bukrs EQ t001-bukrs
     AND cstct EQ 'B'.

  IF g_wrbtr LT 0 OR
     g_wmwst LT 0.
    g_wrbtr = - g_wrbtr.
    g_wmwst = - g_wmwst.
    g_fwbas = - g_fwbas.
    ztitcsk-vorgang = '2'.
  ELSE.
    ztitcsk-vorgang = '1'.
  ENDIF.

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
*        ztitig07-mwskz   TO    ztitcsk-mwskz,
        ztitig07-zlspr   TO    ztitcsk-zlspr,
        ztitig07-zlsch   TO    ztitcsk-zlsch,
        ztitig07-uzawe   TO    ztitcsk-uzawe,
        gs_disp-mwskz    TO    ztitcsk-mwskz,
        gs_disp-cdcno    TO    ztitcsk-xblnr,
        gs_disp-lifnr    TO    ztitcsk-lifnr,
        t001-waers       TO    ztitcsk-waers,
        g_wrbtr          TO    ztitcsk-wrbtr,
        g_wmwst          TO    ztitcsk-wmwst,
        g_fwbas          TO    ztitcsk-fwbas.

  PERFORM  get_domain_value_text(ztir9000)
                                 USING   'ZTIEXPGR'
                                         'C'
                                 CHANGING ztitcsk-bktxt.

  SELECT SINGLE *
    FROM lfa1
   WHERE lifnr  EQ  gs_disp-lifnr.
*  if sy-subrc ne 0.
*    message
*  endif.
*
*> 입력된 값 체크.
  PERFORM  check_input_value.

ENDFORM.                    " fill_default_header_data
*&---------------------------------------------------------------------*
*&      Module  change_field_attribute_scr0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_field_attribute_scr0200 OUTPUT.

  LOOP AT SCREEN.
    IF ztisscrcom-monsc EQ 'I'.
      IF screen-name EQ 'ZTITCSK-LIFNR' OR
         screen-name EQ 'LFA1-NAME1'     OR
         screen-name EQ 'ZTITCSK-AKONT' OR
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
*&      Form  execute_collective_posting
*&---------------------------------------------------------------------*
FORM execute_collective_posting .

  DATA: l_subrc   LIKE sy-subrc.

  REFRESH: bdcdata.
  CLEAR: g_cnt, g_wrbtr.

*> 전기할 품목의 Counter.
  LOOP AT it_disp INTO gs_disp WHERE box = 'X'
                                 AND errmd EQ space.
    ADD 1 TO g_cnt.
    ADD gs_disp-wrbtr TO g_wrbtr.
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
FORM build_collective_posting_data .

  DATA: l_text_amout1(20),
        l_text_amout2(20),
        l_text_amout3(20),
        l_sgtxt           TYPE sgtxt,
        l_icssq           TYPE ztiicssq.

  REFRESH: bdcdata.

  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR9000'          '0100',
         ' ' 'ZTISSCRCOM-BUKRS'  ztitcsk-bukrs,
         ' ' 'ZTISSCRCOM-BUDAT'  ztitcsk-budat,
         ' ' 'ZTISSCRCOM-BLDAT'  ztitcsk-bldat,
         ' ' 'ZTISSCRCOM-LIFNR'  gs_disp-lifnr,
         ' ' 'ZTISSCRCOM-EXPGR'  'C',
*         ' ' 'ZTISSCRCOM-CSTYP'  ZTISSCRCOM-CSTYP
         ' ' 'ZTISSCRCOM-BLART'  ztitcsk-blart,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.

**> 세부화면.
*  WRITE g_wrbtr TO l_text_amout CURRENCY ZTITCSK-waers.
*  PERFORM    set_write_no_mask(ZTIr9000)
*                                    CHANGING  l_text_amout.

  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR9000'          '2000',
*         ' ' 'ZTITCSK-BUDAT'
*         ' ' 'ZTITCSK-BLART'
*         ' ' 'ZTITCSK-BLDAT'
         ' ' 'ZTITCSK-VORGANG' ztitcsk-vorgang,
         ' ' 'ZTITCSK-BUPLA'  ztitcsk-bupla,
*         ' ' 'ZTITCSK-GSBER'  ztitcsk-gsber,
         ' ' 'ZTITCSK-ZLSPR'  ztitcsk-zlspr,
*         ' ' 'ZTITCSK-AKONT'
         ' ' 'ZTITCSK-ZLSCH'  ztitcsk-zlsch,
         ' ' 'ZTITCSK-ZTERM'  ztitcsk-zterm,
*         ' ' 'ZTITCSK-WRBTR'  l_text_amout,
*         ' ' 'ZTITCSK-WAERS'
         ' ' 'ZTITCSK-MWSKZ'  ztitcsk-mwskz,
*         ' ' 'ZTITCSK-WMWST'  '0',
*         ' ' 'ZTITCSK-FWBAS'  '0',
         ' ' 'ZTITCSK-XBLNR'  ztitcsk-xblnr,
         ' ' 'ZTITCSK-BKTXT'  ztitcsk-bktxt.
*         ' ' 'ZTITCSK-EBILL'  ZTITCSK-ebill.
*         ' ' 'ZTITCSK-SGTXT'  ZTITCSK-sgtxt.

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

  CLEAR: g_count.
  LOOP AT it_disp INTO gs_disp WHERE box = 'X'
                                 AND errmd EQ space.
    ADD 1 TO g_count.

    IF ztitcsk-vorgang = '2'.
      gs_disp-wrbtr = - gs_disp-wrbtr.
      gs_disp-wmwst = - gs_disp-wmwst.
      gs_disp-fwbas = - gs_disp-fwbas.
    ENDIF.

    WRITE gs_disp-wrbtr TO l_text_amout1 CURRENCY gs_disp-waers.
    WRITE gs_disp-wmwst TO l_text_amout2 CURRENCY gs_disp-waers.
    WRITE gs_disp-fwbas TO l_text_amout3 CURRENCY gs_disp-waers.
    PERFORM    set_write_no_mask(ztir9000)
                                      CHANGING : l_text_amout1,
                                                 l_text_amout2,
                                                 l_text_amout3.

    IF g_count EQ 1.
      PERFORM bdc_dynpro_build USING :
             ' ' 'ZTISCSIT-EXPCD(01)'  gs_disp-expcd,
             ' ' 'ZTISCSIT-ICCNO(01)'  gs_disp-iccno,
             ' ' 'ZTISCSIT-AMSEQ(01)'  gs_disp-iccsq,
             ' ' 'ZTISCSIT-WRBTR(01)'  l_text_amout1,
             ' ' 'ZTISCSIT-MWSKZ(01)'  ztitcsk-mwskz,
             ' ' 'ZTISCSIT-WMWST(01)'  l_text_amout2,
             ' ' 'ZTISCSIT-FWBAS(01)'  l_text_amout3.
      CASE gs_disp-cstcl.
        WHEN 'B' OR 'C' OR 'D'.
          WRITE gs_disp-payda TO l_sgtxt.
          PERFORM bdc_dynpro_build USING :
                 ' ' 'ZTISCSIT-SGTXT(01)'  l_sgtxt.
      ENDCASE.

      l_icssq = 1.
    ELSE.
      PERFORM bdc_dynpro_build USING :
             'X' 'ZTIR9000'          '2000',
             ' ' 'ZTISCSIT-EXPCD(02)'  gs_disp-expcd,
             ' ' 'ZTISCSIT-ICCNO(02)'  gs_disp-iccno,
             ' ' 'ZTISCSIT-AMSEQ(02)'  gs_disp-iccsq,
             ' ' 'ZTISCSIT-WRBTR(02)'  l_text_amout1,
             ' ' 'ZTISCSIT-MWSKZ(02)'  ztitcsk-mwskz,
             ' ' 'ZTISCSIT-WMWST(02)'  l_text_amout2,
             ' ' 'ZTISCSIT-FWBAS(02)'  l_text_amout3.
      CASE gs_disp-cstcl.
        WHEN 'B' OR 'C' OR 'D'.
          WRITE gs_disp-payda TO l_sgtxt.
          PERFORM bdc_dynpro_build USING :
                 ' ' 'ZTISCSIT-SGTXT(02)'  l_sgtxt.
      ENDCASE.

      l_icssq = g_count - 1.
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


ENDFORM.                    " build_collective_posting_data
*&---------------------------------------------------------------------*
*&      Form  build_posted_message
*&---------------------------------------------------------------------*
FORM build_posted_message  USING    p_subrc.

  IF p_subrc EQ 0.
    MOVE:  sy-msgid   TO  it_msg-msgid,
           sy-msgty   TO  it_msg-msgty,
           sy-msgno   TO  it_msg-msgno,
           sy-msgv1   TO  it_msg-msgv1,
           sy-msgv2   TO  it_msg-msgv2,
           sy-msgv3   TO  it_msg-msgv3,
           sy-msgv4   TO  it_msg-msgv4,
           gs_disp-iccno TO  it_msg-refno.
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
             gs_disp-iccno   TO it_msg-refno.
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
             gs_disp-iccno TO  it_msg-refno.
      APPEND it_msg.
    ENDIF.
  ENDIF.

ENDFORM.                    " build_posted_message
*&---------------------------------------------------------------------*
*&      Form  execute_individual_posting
*&---------------------------------------------------------------------*
FORM execute_individual_posting .

  DATA: l_subrc   LIKE sy-subrc.

  LOOP AT it_disp INTO gs_disp WHERE box = 'X'
                                 AND errmd EQ space.

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
FORM build_individual_posting_data .

  DATA: l_text_amout1(20),
        l_text_amout2(20),
        l_text_amout3(20),
        l_sgtxt             TYPE sgtxt.

  REFRESH: bdcdata.

  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR9000'          '0100',
         ' ' 'ZTISSCRCOM-BUKRS'  ztitcsk-bukrs,
         ' ' 'ZTISSCRCOM-BUDAT'  ztitcsk-budat,
         ' ' 'ZTISSCRCOM-BLDAT'  ztitcsk-bldat,
         ' ' 'ZTISSCRCOM-LIFNR'  gs_disp-lifnr,
         ' ' 'ZTISSCRCOM-EXPGR'  'C',
*         ' ' 'ZTISSCRCOM-CSTYP'  ZTISSCRCOM-CSTYP
         ' ' 'ZTISSCRCOM-BLART'  ztitcsk-blart,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.

*> 세부화면.
  IF gs_disp-wrbtr LT 0 OR
     gs_disp-wmwst LT 0.
    gs_disp-wrbtr = - gs_disp-wrbtr.
    gs_disp-wmwst = - gs_disp-wmwst.
    gs_disp-fwbas = - gs_disp-fwbas.
    ztitcsk-vorgang = '2'.
  ELSE.
    ztitcsk-vorgang = '1'.
  ENDIF.

  WRITE gs_disp-wrbtr TO l_text_amout1 CURRENCY gs_disp-waers.
  WRITE gs_disp-wmwst TO l_text_amout2 CURRENCY gs_disp-waers.
  WRITE gs_disp-fwbas TO l_text_amout3 CURRENCY gs_disp-waers.
  PERFORM    set_write_no_mask(ztir9000)
                                    CHANGING : l_text_amout1,
                                               l_text_amout2,
                                               l_text_amout3.
  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR9000'          '2000',
*         ' ' 'ZTITCSK-BUDAT'
*         ' ' 'ZTITCSK-BLART'
*         ' ' 'ZTITCSK-BLDAT'
*         ' ' 'ZTITCSK-BUPLA'  gs_disp-bupla,
*         ' ' 'ZTITCSK-GSBER'  ZTITCSK-gsber,
         ' ' 'ZTITCSK-VORGANG' ztitcsk-vorgang,
         ' ' 'ZTITCSK-ZLSPR'  ztitcsk-zlspr,
*         ' ' 'ZTITCSK-AKONT'
         ' ' 'ZTITCSK-ZLSCH'  ztitcsk-zlsch,
         ' ' 'ZTITCSK-ZTERM'  ztitcsk-zterm,
*         ' ' 'ZTITCSK-WRBTR'  l_text_amout,
*         ' ' 'ZTITCSK-WAERS'
*         ' ' 'ZTITCSK-MWSKZ'  ZTITCSK-mwskz,
*         ' ' 'ZTITCSK-WMWST'  '0',
*         ' ' 'ZTITCSK-FWBAS'  '0',
         ' ' 'ZTITCSK-XBLNR'  gs_disp-cdcno,
         ' ' 'ZTITCSK-BKTXT'  ztitcsk-bktxt,
*         ' ' 'ZTITCSK-BKTXT'  '통관관련비용',
*         ' ' 'ZTITCSK-EBILL'  ZTITCSK-ebill,
*         ' ' 'ZTITCSK-SGTXT'  '통관관련비용',
         ' ' 'ZTISCSIT-EXPCD(01)'  gs_disp-expcd,
         ' ' 'ZTISCSIT-ICCNO(01)'  gs_disp-iccno,
         ' ' 'ZTISCSIT-AMSEQ(01)'  gs_disp-iccsq,
         ' ' 'ZTISCSIT-WRBTR(01)'  l_text_amout1,
         ' ' 'ZTISCSIT-MWSKZ(01)'  ztitcsk-mwskz,
         ' ' 'ZTISCSIT-WMWST(01)'  l_text_amout2,
         ' ' 'ZTISCSIT-FWBAS(01)'  l_text_amout3.

  IF NOT ztitig00-chkbp IS INITIAL.
    IF NOT gs_disp-BUPLA IS INITIAL.    ">
*      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'BUPLA'.
      PERFORM bdc_dynpro_build USING :
                        ' ' 'ZTITCSK-BUPLA' gs_disp-BUPLA.
    ENDIF.
  ENDIF.

  IF NOT ztitig00-chkba IS INITIAL.
    IF NOT ztitcsk-gsber IS INITIAL.    ">
*      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'BUPLA'.
      PERFORM bdc_dynpro_build USING :
                            ' ' 'ZTITCSK-GSBER' ztitig00-chkba.
    ENDIF.
  ENDIF.

  CASE gs_disp-cstcl.
    WHEN 'B' OR 'C' OR 'D'.
      WRITE gs_disp-payda TO l_sgtxt.
      PERFORM bdc_dynpro_build USING :
             ' ' 'ZTISCSIT-SGTXT(01)'  l_sgtxt.
  ENDCASE.


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


ENDFORM.                    " build_individual_posting_data
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

*> 지급조건.
  IF ztitcsk-zterm IS INITIAL.
    PERFORM no_input_check(ztir0000) USING 'ZTITCSK' 'ZTERM' 'E'.
  ENDIF.

*> 세금코드.
  IF ztitcsk-mwskz IS INITIAL.
    PERFORM no_input_check(ztir0000) USING 'ZTITCSK' 'MWSKZ' 'E'.
  ENDIF.

**> 사업영역.
*  IF ZTITCSK-gsber IS INITIAL.
*    PERFORM no_input_check(ZTIr0000) USING 'ZTITCSK' 'GSBER' 'E'.
*  ENDIF.
**> 사용가능한 사업영역 체크.
*  PERFORM  check_business_area(ZTIr0000)
*                                     USING ZTITCSK-gsber.
*
*> 개별전표일 경우.
  IF ztisscrcom-monsc EQ 'I'.

*> 일괄전표일 경우.
  ELSE.

  ENDIF.

ENDMODULE.                 " pai_check_fields_scr0200  INPUT
*&---------------------------------------------------------------------*
*&      Form  p1101_check_input_value
*&---------------------------------------------------------------------*
FORM p1101_check_input_value .

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

*  SELECT SINGLE *
*    FROM ztitig07
*   WHERE bukrs EQ t001-bukrs
*     AND cstct EQ 'B'.
*
  SELECT SINGLE *
    FROM t005
   WHERE land1 EQ t001-land1.

  IF g_answer IS INITIAL.
    CALL FUNCTION 'Z_TI_EXPENCES_CODE_BY_GROUP'
      EXPORTING
        xbukrs    = t001-bukrs
        xexpgr    = 'C'
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

*  CHECK g_answer EQ 'Y'.


ENDFORM.                    " p1101_check_input_value
*&---------------------------------------------------------------------*
*&      Form  p3810_fill_celltab
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

    IF gs_fieldcat_g-fieldname = 'WRBTR'   OR    " 상품번호
       gs_fieldcat_g-fieldname = 'WMWST'   OR
       gs_fieldcat_g-fieldname = 'FWBAS'.

      CASE gs_disp-cstcl.
        WHEN '2'.    ">부가세.
          IF gs_fieldcat_g-fieldname EQ 'WRBTR'.
            ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
            INSERT ls_celltab INTO TABLE pt_celltab.
          ELSE.
            IF p_mode EQ 'W'.
              ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
              INSERT ls_celltab INTO TABLE pt_celltab.
            ELSE.
              ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
              INSERT ls_celltab INTO TABLE pt_celltab.
            ENDIF.
          ENDIF.
        WHEN 'Z'.    ">관세사 수수료.
          IF p_mode EQ 'W'.
            ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
            INSERT ls_celltab INTO TABLE pt_celltab.
          ELSE.
            ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
            INSERT ls_celltab INTO TABLE pt_celltab.
          ENDIF.
        WHEN OTHERS.
          IF gs_fieldcat_g-fieldname EQ 'WRBTR'.
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
      ENDCASE.
      IF NOT gs_disp-icsno IS INITIAL.
        ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
        INSERT ls_celltab INTO TABLE pt_celltab.
      ENDIF.
    ELSE.
      ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
      INSERT ls_celltab INTO TABLE pt_celltab.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " p3810_fill_celltab
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
*&      Form  p3810_fill_color
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p3810_fill_color  CHANGING p_mode
                                pt_coltab TYPE lvc_t_scol.

* 각 Cell의 특성 제어
  DATA : ls_coltab  TYPE lvc_s_scol.

  CLEAR: pt_coltab[].

  LOOP AT it_fieldcat_g INTO gs_fieldcat_g.
    ls_coltab-fname = gs_fieldcat_g-fieldname.

    CASE ls_coltab-fname.
      WHEN 'ICON' OR 'ICCNO' OR 'ICCSQ' OR 'CDCNO'.
        ls_coltab-color-col = 4.
        ls_coltab-color-int = 1.
      WHEN OTHERS.
        ls_coltab-color-col = 0.
        ls_coltab-color-int = 0.
    ENDCASE.
    INSERT ls_coltab INTO TABLE pt_coltab.

  ENDLOOP.

ENDFORM.                    " p3810_fill_color
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
