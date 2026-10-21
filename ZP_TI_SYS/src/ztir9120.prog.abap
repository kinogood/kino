************************************************************************
* Title         :  ZTIR9120                                           *
*                                                                      *
* Description   : [Report] 적하부보내역관리                            *
*                                                                      *
* Creation Date : 2004/02/18                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
***********************************************************************
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
REPORT  ztir9120       MESSAGE-ID zmti00
                       NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis,   "> Globale Type(ALV)
            kkblo.  "> Generic list types

TYPES:  BEGIN OF ty_list,
*        INCLUDE STRUCTURE ZTIVIP01.
      box(1)  TYPE c,
      icon(4) TYPE c,
      errmd   TYPE c,
      iipno   LIKE ztivip01-iipno,  "I/P 관리번호
      amdsq   LIKE ztivip01-amdsq,  "배서차수
      reqno   LIKE ztivip01-reqno,  "수입의뢰 관리번호
      reqty   LIKE ztivip01-reqty,  "수입의뢰 종류
      opnno   LIKE ztivip01-opnno,  "수입개설번호
      tapdt   LIKE ztivip01-tapdt,  "신청일자.
      opamt   LIKE ztivip01-opamt,  "개설금액
      opndt   LIKE ztivip01-opndt,  "개설일자
      bupla   LIKE ztivip01-bupla,  "개설일자
      inscp   LIKE ztitip1-inscp,   "보험회사(EDI 코드).
      lifnr   LIKE ztstig3-lifnr,   "보험회사(SAP 코드)
      namet   LIKE ztstig3-namet,   "보험사명.
      docst   LIKE ztivip01-docst,  "상태.
      waers   LIKE ztivip01-waers,  "통화키
      pspnr   LIKE ztivip01-pspnr,  "hull no.
      iivat   LIKE ztivip01-iivat,  "송장금액.
      iivatc  LIKE ztivip01-iivatc, "통화.
      iwart   LIKE ztitip1-iwart,   "희망이익률.
      iajrt   LIKE ztitip1-iajrt,   "환률.
      itprt   LIKE ztivip01-itprt,  "요율.
      itpac   LIKE ztivip01-itpa1,  "계산필드.
      itpa1   LIKE ztivip01-itpa1,  "ADVS:Total Premium
      itpa1c  LIKE ztivip01-itpa1c, "ADVS:Total Premium 통화
      itoat   LIKE ztivip01-itoat,  "ADVH:Total 보험금액
      itoatc  LIKE ztivip01-itoatc, "ADVH:Total 보험금액 통화
*      inscp   LIKE ZTIVIP01-inscp,  "보험회사코드
      icpnm   LIKE ztivip01-icpnm,  "ADVH:손해보험회사 상호
      ispno   LIKE ztivip01-ispno,  "ADVH:보험증권번호
      iopdt   LIKE ztivip01-iopdt,  "APP:보험개시일
      iisdt   LIKE ztivip01-iisdt,  "증권발급일
      ishnm   LIKE ztivip01-ishnm,  "선적항 도시/지역명
      ilpnm   LIKE ztivip01-ilpnm,  "최종목적지 도시/지역명
      livst   LIKE ztitcsk-livst,   "전기여부.
      expcd   LIKE ztitcsp-expcd,   "비용코드.
      icsno   LIKE ztitcsk-icsno,   "비용문서번호.
      belnr   LIKE ztitcsk-belnr,   "회계전표.
      bukrs   LIKE ztitcsk-bukrs,   "회사코드,
      cnam    LIKE ztivip01-cnam,   "작성인
      cdat    LIKE ztivip01-cdat,   "생성일
      ctme    LIKE ztivip01-ctme,   "생성시간
      unam    LIKE ztivip01-unam,   "최종변경인
      udat    LIKE ztivip01-udat,   "변경일
      utme    LIKE ztivip01-utme,   "최종변경시간
      END   OF ty_list.

DATA: gs_list1 TYPE  ty_list.

TYPES:  BEGIN OF ty_list1.
        INCLUDE STRUCTURE gs_list1.
TYPES:  celltab TYPE lvc_t_styl.            " Cell단위 수정 스타일
TYPES:  END   OF ty_list1.

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

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: ztitip1,      ">적하 보험  MAIN (APPCIV/CIPADV)
        ztitcsk,      ">수입비용문서 Header table
        ztisscrcom,    ">수출입시스템 Screen용 Structure(공용)
        icon.          ">아이콘테이블

TABLES: t001,          ">회사코드
        t005,          ">국가
        lfa1,          ">구매처마스터 (일반섹션)
        ztitig00,     ">[TraSys] 회사별 프로세스 정의.
        ztitig07,     ">[TraSys]  제비용 일괄전기 Default Value관리.
        ztitcsp,      ">수입비용문서 비용항목 table
        ztivcs00,      ">수입비용 Views
        ztitig06,      ">수입비용코드
        vf_kred.       ">LFA1과 LFB1에 대한 데이타베이스 뷰

TABLES: bapi1093_0,    ">BAPI 환율테이블
        bapicurx,      ">BAPI에 대한 외화환산모듈구조
        bapiret1.      ">리턴매개변수

************************************************************************
* SAP Views                                                            *
************************************************************************
TABLES: ztivip01.      ">적하보험 Views

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
DATA: it_list  TYPE STANDARD TABLE OF ty_list1,
      it_temp  TYPE STANDARD TABLE OF ty_list,
      gs_list  TYPE ty_list1.


DATA: BEGIN OF it_vendor  OCCURS 2,
      lifnr    TYPE lifnr,
      END   OF it_vendor.

DATA: BEGIN OF it_ztstig3  OCCURS 2.
        INCLUDE STRUCTURE ztstig3.
DATA: END   OF it_ztstig3.

*> 비용코드.
DATA: BEGIN OF it_ztitig06  OCCURS 2.
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
DATA: gs_stable     TYPE lvc_s_stbl.
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
      g_process           TYPE c,
      g_count             TYPE i,
      g_cnt               TYPE i,
      g_wrbtr             TYPE wrbtr,
      g_wmwst             TYPE wmwst,
      ok_code             LIKE sy-ucomm,
      g_line              TYPE i,
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
* Message 처리를 위한 Macro                                            *
************************************************************************
DATA: g_message_handler   TYPE REF TO cl_message_handler_mm.

************************************************************************
* Message 처리를 위한 Macro                                            *
************************************************************************
DATA: g_dummy(72).

DEFINE zti_message.
  g_tabix = sy-tabix.
  g_subrc = sy-subrc.

  message id &2 type &1 number &3 with &4 &5 &6 &7 into g_dummy.

  call method cl_message_mm=>create
    exporting
      im_msgid         = &2
      im_msgty         = &1
      im_msgno         = &3
      im_msgv1         = sy-msgv1
      im_msgv2         = sy-msgv2
      im_msgv3         = sy-msgv3
      im_msgv4         = sy-msgv4
      im_force_collect = 'X'
    exceptions
      failure          = 01
      dialog           = 02.
  if sy-subrc = 1 or sy-subrc = 2.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  endif.
  sy-subrc = g_subrc.
  sy-tabix = g_tabix.

END-OF-DEFINITION.

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK dbsel WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_bukrs  FOR ztivip01-bukrs   "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk ,
  s_ekorg  FOR ztivip01-ekorg ,   "구매조직.
  s_ekgrp  FOR ztivip01-ekgrp ,   "구매그룹.
  s_reqno  FOR ztivip01-reqno   "수입의뢰 관리번호.
                              MEMORY ID ztireqno,
  s_iipno  FOR ztivip01-iipno   "수입의뢰 관리번호.
                              MEMORY ID ztiiipno,
  s_amdsq  FOR ztivip01-amdsq   "Amend 차수.
                              MEMORY ID ztiamseq,
  s_inscp  FOR ztivip01-inscp ,   "보험회사.
  s_iopno  FOR ztivip01-iopno ,   "포괄증권번호.
  s_iisdt  FOR ztivip01-iisdt ,   "증권발급일.
  s_ispno  FOR ztivip01-ispno ,   "증권번호.
  s_reqty  FOR ztivip01-reqty ,   "수입의뢰 종류.
  s_ilcty  FOR ztivip01-ilcty ,   "신용장 종류.
  s_lifnr  FOR ztivip01-lifnr ,   "공급업체 계정번호.
  s_opnno  FOR ztivip01-opnno ,   "수입개설번호
  s_opndt  FOR ztivip01-opndt ,   "개설일자.
  s_zterm  FOR ztivip01-zterm ,   "지급조건키.
  s_inco1  FOR ztivip01-inco1 ,   "인도조건 (파트 1).
  s_fwdty  FOR ztivip01-fwdty ,   "운송 방법.
  s_fland  FOR ztivip01-fland ,   "선적국가.
  s_cnam   FOR ztivip01-cnam  ,   "작성인.
  s_cdat   FOR ztivip01-cdat  ,   "생성일.
  s_unam   FOR ztivip01-unam  ,   "최종변경인.
  s_udat   FOR ztivip01-udat  .   "변경일.

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

*> 지급조건 HELP(Low values)
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_zterm-low.
  PERFORM get_f4_for_zterm(ztir0000) USING s_zterm-low.
*> 지급조건 HELP(High values)
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_zterm-high.
  PERFORM get_f4_for_zterm(ztir0000) USING s_zterm-high.

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

  SET TITLEBAR 'T1000' WITH '현황 List'(t10).

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
*&      Form  p3000_field_category_build
*&---------------------------------------------------------------------*
FORM p3000_field_category_build .

  DATA ls_fcat TYPE lvc_s_fcat.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
       EXPORTING
            i_structure_name = 'ZTIVIP01'
*            i_client_never_display = 'X'
       CHANGING
            ct_fieldcat      = it_fieldcat_g[].

  PERFORM 3010_insert_field_category USING :
                  'S' 'FIELDNAME'   'ICON',
                  ' ' 'COLTEXT'     'ICON',
                  ' ' 'EMPHASIZE'   'K41',     "열강조
                  ' ' 'ICON'        'X',
                  'E' 'OUTPUTLEN'   '04',

                  'S' 'FIELDNAME'   'ITPAC',
                  ' ' 'COLTEXT'     '보험료 계산',
                  ' ' 'CFIELDNAME'  'ITPA1C',
*                  ' ' 'CTABNAME'    'ZTITIP1',
                  'E' 'OUTPUTLEN'   '17',

                  'S' 'REF_TABLE'     'ZTSTIG3',
                  ' ' 'FIELDNAME'     'LIFNR',
                  ' ' 'OUTPUTLEN'     12,
                  ' ' 'HOTSPOT'       'X',       " Double Click 효과
                  'E' 'KEY'           ' ',

                  'S' 'REF_TABLE'     'ZTSTIG3',
                  ' ' 'FIELDNAME'     'NAMET',
                  ' ' 'OUTPUTLEN'     20,
                  ' ' 'HOTSPOT'       'X',       " Double Click 효과
                  'E' 'KEY'           ' '.

  LOOP AT it_fieldcat_g INTO gs_fieldcat_g.
    CLEAR: gs_fieldcat_g-key,
           gs_fieldcat_g-tech,
           gs_fieldcat_g-no_out.

    CASE gs_fieldcat_g-fieldname.
      WHEN 'ICON'.
        gs_fieldcat_g-col_pos = 1.
        gs_fieldcat_g-key     = 'X'.
      WHEN 'IIPNO'. "I/P 관리번호
        gs_fieldcat_g-col_pos = 2.
        gs_fieldcat_g-hotspot = 'X'.
        gs_fieldcat_g-key     = 'X'.
      WHEN 'AMDSQ'. "배서차수
        gs_fieldcat_g-col_pos = 3.
        gs_fieldcat_g-hotspot = 'X'.
        gs_fieldcat_g-key     = 'X'.
      WHEN 'REQNO'. "수입의뢰 관리번호
        gs_fieldcat_g-col_pos = 4.
        gs_fieldcat_g-hotspot = 'X'.
        gs_fieldcat_g-no_out = 'X'.
      WHEN 'OPNNO'. "수입개설번호
        gs_fieldcat_g-col_pos = 5.
        gs_fieldcat_g-hotspot = 'X'.
*      WHEN 'TAPDT'. "신청일자.
*        gs_fieldcat_g-col_pos = 6.
      WHEN 'PSPNR'.   "hull no.
        gs_fieldcat_g-col_pos = 7.
      WHEN 'NAMET'. "보험회사명
        gs_fieldcat_g-col_pos = 8.
*      WHEN 'BOX'. "BOX  clear ls_fcat.
*        gs_fieldcat_g-fieldname = 'BOX'.
*        gs_fieldcat_g-checkbox = 'X'.
*        gs_fieldcat_g-edit = 'X'.
*        gs_fieldcat_g-outputlen = 5.
*        gs_fieldcat_g-col_pos = 6.
*      WHEN 'DOCST'.
*        gs_fieldcat_g-col_pos = 7.
*      WHEN 'OPAMT'. "개설금액
*        gs_fieldcat_g-col_pos = 8.
*      WHEN 'OPNDT'. "개설일자
*        gs_fieldcat_g-col_pos = 9.
*      WHEN 'WAERS'. "통화키
*        gs_fieldcat_g-col_pos = 10.
**        p_fieldcat-tech    = 'X'.

      WHEN 'IIVATC'.   "송장금액.
        gs_fieldcat_g-col_pos = 10.
      WHEN 'IIVAT'.   "송장금액.
        gs_fieldcat_g-col_pos = 11.
      WHEN 'IWART'.   "희망이익률.
        gs_fieldcat_g-col_pos = 12.
      WHEN 'IAJRT'.   "환률.
        gs_fieldcat_g-col_pos = 13.
      WHEN 'ITPRT'.   "요율.
        gs_fieldcat_g-col_pos = 14.
      WHEN 'ITPAC'.   "계산필드.
        gs_fieldcat_g-col_pos = 15.
      WHEN 'ITPA1'.   "Total Premium
        gs_fieldcat_g-edit       = 'X'.
        gs_fieldcat_g-checktable = '!'.
        gs_fieldcat_g-do_sum     = 'X'.
        gs_fieldcat_g-col_pos    = 16.
      WHEN 'ITPA1C'. "ADVH:TOTAL 보험금액 통화
*        gs_fieldcat_g-edit       = 'X'.
*        gs_fieldcat_g-checktable = '!'.  "do not check foreign keys
        gs_fieldcat_g-col_pos = 17.
*      WHEN 'ITOAT'. "ADVH:TOTAL 보험금액
*        gs_fieldcat_g-edit       = 'X'.
*        gs_fieldcat_g-checktable = '!'.  "do not check foreign keys
*        gs_fieldcat_g-col_pos = 20.
*      WHEN 'ITOATC'. "ADVH:TOTAL 보험금액 통화
*        gs_fieldcat_g-edit       = 'X'.
*        gs_fieldcat_g-checktable = '!'.  "do not check foreign keys
*        gs_fieldcat_g-col_pos = 21.
*        p_fieldcat-tech    = 'X'.
*      WHEN 'INSCP'. "보험회사코드
*        gs_fieldcat_g-col_pos = 22.
*      WHEN 'ICPNM'. "ADVH:손해보험회사 상호
*        gs_fieldcat_g-col_pos = 23.
*      WHEN 'IBTCD'. "APP:기본조건 코드
*        gs_fieldcat_g-col_pos = 24.
*        gs_fieldcat_g-tech    = 'X'.
*      WHEN 'IBTTE'. "APP:기본조건 TEXT
*        gs_fieldcat_g-col_pos = 25.
      WHEN 'ISPNO'. "ADVH:보험증권번호
        gs_fieldcat_g-col_pos = 26.
      WHEN 'IOPDT'. "APP:보험개시일
        gs_fieldcat_g-col_pos = 27.
      WHEN 'IISDT'. "증권발급일
        gs_fieldcat_g-col_pos = 28.
      WHEN 'ISHNM'. "선적항 도시/지역명
        gs_fieldcat_g-col_pos = 29.
      WHEN 'ILPNM'. "최종목적지 도시/지역명
        gs_fieldcat_g-col_pos = 30.
      WHEN OTHERS.
        gs_fieldcat_g-col_pos = gs_fieldcat_g-col_pos + 100.
        gs_fieldcat_g-no_out = 'X'.
    ENDCASE.
    MODIFY it_fieldcat_g FROM gs_fieldcat_g.
  ENDLOOP.

ENDFORM.                    " 3000_field_category_build
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
        FROM ztivip01
        WHERE bukrs  IN s_bukrs  "회사코드.
          AND docst  EQ 'O'      "상태
          AND iipno  IN s_iipno  "적하부보 관리번호.
          AND reqno  IN s_reqno  "수입의뢰 관리번호.
          AND amdsq  IN s_amdsq  "Amend 차수
          AND reqty  IN s_reqty  "수입의뢰 종류.
          AND ilcty  IN s_ilcty  "신용장 종류.
          AND lifnr  IN s_lifnr  "공급업체 계정번호.
          AND inscp  IN s_inscp  "보험회사.
          AND iopno  IN s_iopno  "포괄증권번호.
          AND iisdt  IN s_iisdt  "증권발급일.
          AND ispno  IN s_ispno  "증권번호.
          AND ekorg  IN s_ekorg  "구매조직.
          AND ekgrp  IN s_ekgrp  "구매그룹.
          AND opnno  IN s_opnno  "수입개설번호
          AND opndt  IN s_opndt  "개설일자.
          AND zterm  IN s_zterm  "지급조건키.
          AND inco1  IN s_inco1  "인도조건 (파트 1).
          AND fwdty  IN s_fwdty  "운송 방법.
          AND fland  IN s_fland  "선적국가.
          AND cnam   IN s_cnam   "작성인.
          AND cdat   IN s_cdat   "생성일.
          AND unam   IN s_unam   "최종변경인.
          AND udat   IN s_udat.   "변경일.

  IF sy-subrc NE 0.
    MESSAGE s902.   EXIT.
  ENDIF.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_ztstig3
    FROM ztstig3
     FOR ALL ENTRIES IN it_temp
   WHERE parti  EQ  'P'
     AND epart  EQ  it_temp-inscp.

  REFRESH: it_list.
  LOOP AT it_temp INTO gs_list1.
    g_tabix = sy-tabix.
    MOVE-CORRESPONDING gs_list1 TO gs_list.

    READ TABLE it_ztstig3 WITH KEY epart  = gs_list-inscp.
    IF sy-subrc EQ 0.
      MOVE: it_ztstig3-lifnr  TO  gs_list-lifnr,
            it_ztstig3-namet  TO  gs_list-namet.
    ENDIF.

*> 선택한 비용코드를 추가함.
    LOOP AT it_ztitig06 WHERE box = 'X'.
*> 기존처리된 비용여부 판단.
      SELECT SINGLE *
        FROM ztivcs00
       WHERE bukrs   EQ  t001-bukrs
         AND expgr   EQ  'I'
         AND expcd   EQ  it_ztitig06-expcd
         AND refno   EQ  gs_list-iipno
         AND amdsq   EQ  gs_list-amdsq.

      IF sy-subrc EQ 0.
        IF p_step1 EQ 'X'.
          CONTINUE.
        ENDIF.
*> 비용문서 MOVE
*        MOVE-CORRESPONDING ZTIvcs00 TO gs_list.
        MOVE: ztivcs00-livst    TO     gs_list-livst,
              ztivcs00-icsno    TO     gs_list-icsno,
              ztivcs00-bukrs    TO     gs_list-bukrs,
              ztivcs00-belnr    TO     gs_list-belnr.
      ELSE.
        IF p_step2 EQ 'X'.
          CONTINUE.
        ENDIF.
      ENDIF.

*> 비용코드.
      MOVE it_ztitig06-expcd    TO     gs_list-expcd.

*> 적하보험료일 경우.
      IF it_ztitig06-cstcl EQ 'I'.
*> Get exchange rate
        CLEAR: bapiret1, bapi1093_0.
        CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
          EXPORTING
            rate_type  = 'M'
            from_curr  = gs_list-itoatc
            to_currncy = gs_list-itpa1c
            date       = gs_list-iisdt
          IMPORTING
            exch_rate  = bapi1093_0
            return     = bapiret1.
*      IF bapiret1-type EQ c_error.
*          MESSAGE ID bapiret1-id TYPE bapiret1-type
*                  NUMBER bapiret1-number
*                  WITH bapiret1-message_v1 bapiret1-message_v2
*                       bapiret1-message_v3 bapiret1-message_v4.
*      ENDIF.

        IF gs_list-iajrt IS INITIAL.
          IF bapi1093_0-exch_rate_v IS INITIAL.
            gs_list-iajrt  = bapi1093_0-exch_rate.
          ELSE.
            gs_list-iajrt  = bapi1093_0-exch_rate_v.
          ENDIF.
        ENDIF.

*   보험료 계산. (송장금액 * 희망이익률):보험료 * 환률 * 보험요율.
        CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERN_9'
          EXPORTING
            currency        = gs_list-itoatc
            amount_internal = gs_list-itoat
          IMPORTING
            amount_external = bapicurx-bapicurx.

*      iivat   LIKE ztivip01-iivat,  "송장금액.
*      iivatc  LIKE ztivip01-iivatc, "통화.
*      iwart   LIKE ztitip1-iwart,   "희망이익률.
*      iajrt   LIKE ztitip1-iajrt,   "환률.
*      itprt   LIKE ztivip01-itprt,  "요율.

        gs_list-itpac = bapicurx-bapicurx *  gs_list-iajrt *
                      ( bapi1093_0-to_factor / bapi1093_0-from_factor ).

        gs_list-itpac = gs_list-itpac * gs_list-itprt.

        bapicurx-bapicurx = gs_list-itpac.

        CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERN_9'
          EXPORTING
            currency             = gs_list-itpa1c
            amount_external      = bapicurx-bapicurx
            max_number_of_digits = 18
          IMPORTING
            amount_internal      = gs_list-itpac.

*    gs_list-ITPAC = ( gs_list-IIVAT * gs_list-IWART )
*                    * gs_list-IAJRT * gs_list-ITPRT  .

      ENDIF.

*> 기존처리된 비용여부 판단.
      CASE gs_list-livst.
        WHEN 'P'.
          gs_list-icon = icon_green_light.
        WHEN 'N'.
          gs_list-icon = icon_yellow_light.
        WHEN OTHERS.
          IF gs_list-itpac <> gs_list-itpa1.
            gs_list-icon = icon_red_light.
          ELSE.
            IF gs_list-itpa1 EQ 0.
              gs_list-icon = icon_red_light.
            ELSE.
              gs_list-icon = icon_yellow_light.
            ENDIF.
          ENDIF.
*          gs_list-icon = icon_red_light.
      ENDCASE.
      APPEND gs_list TO it_list.
    ENDLOOP.
  ENDLOOP.

*> 데이타가 존재하지 않을 경우.
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
*      -->P_1100   text
*      -->P_1101   text
*      -->P_1102   text
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
*>
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
  MOVE 'ZTIT105'            TO ls_toolbar-function.
  MOVE icon_price           TO ls_toolbar-icon.
  MOVE '수정'(111)          TO ls_toolbar-quickinfo.
  MOVE '보험료수정'(112)    TO ls_toolbar-text.
  MOVE space                TO ls_toolbar-disabled.
  APPEND ls_toolbar         TO r_object->mt_toolbar.

* append an icon to show 적하보험문서
  CLEAR ls_toolbar.
  MOVE 0                    TO ls_toolbar-butn_type.
  MOVE 'ZTIT901'            TO ls_toolbar-function.
  MOVE icon_financing       TO ls_toolbar-icon.
  MOVE '전기'(113)          TO ls_toolbar-quickinfo.
  MOVE '전기'(113)          TO ls_toolbar-text.
  MOVE space                TO ls_toolbar-disabled.
  APPEND ls_toolbar         TO r_object->mt_toolbar.

** append an icon to show 적하보험문서
*  CLEAR ls_toolbar.
*  MOVE 0                    TO ls_toolbar-butn_type.
*  MOVE 'ZTIT901S'           TO ls_toolbar-function.
*  MOVE icon_simulate        TO ls_toolbar-icon.
*  MOVE '시뮬레이션'(114)    TO ls_toolbar-quickinfo.
*  MOVE '시뮬레이션'(114)    TO ls_toolbar-text.
*  MOVE space                TO ls_toolbar-disabled.
*  APPEND ls_toolbar         TO r_object->mt_toolbar.

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
      WHEN 'ITPA1'.                    "> 보험료.
        READ TABLE it_list   INTO  gs_list
                             INDEX ls_mod_cells-row_id .
        IF gs_list-itpac  EQ  ls_mod_cells-value .

          CALL METHOD er_data_changed->modify_cell
            EXPORTING
              i_row_id    = ls_mod_cells-row_id
              i_fieldname = 'ICON'
              i_value     = icon_yellow_light.
        ELSE.
          CALL METHOD er_data_changed->modify_cell
            EXPORTING
              i_row_id    = ls_mod_cells-row_id
              i_fieldname = 'ICON'
              i_value     = icon_red_light.
        ENDIF.
    ENDCASE.
  ENDLOOP.

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
  CHECK sy-subrc EQ 0.
  PERFORM display_ip_document(ztir0000)
                                     USING gs_list-iipno
                                           gs_list-amdsq.
ENDFORM.                    "handle_double_click
*&---------------------------------------------------------------------*
*&      Form  handle_hotspot_click
*&---------------------------------------------------------------------*
FORM handle_hotspot_click  USING e_row_id    TYPE lvc_s_row
                                 e_column_id TYPE lvc_s_col.

  READ TABLE it_list INTO gs_list INDEX e_row_id-index.
  CHECK sy-subrc EQ 0.

  CASE e_column_id-fieldname.
    WHEN 'IIPNO' OR 'AMDSQ'.
      PERFORM display_ip_document(ztir0000)
                                      USING gs_list-iipno
                                            gs_list-amdsq.
    WHEN 'REQNO' OR 'OPNNO'.
      PERFORM  display_import_document(ztir0000)
                                      USING gs_list-reqno
                                            space
                                            space.
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

* Message preparations
  PERFORM  set_message_preparations(ztir0000).

  REFRESH: bdcdata.
  CLEAR: session.
  ctu_params-dismode  = 'E'. ">처리모드
  ctu_params-updmode  = 'S'. ">갱신모드
  ctu_params-cattmode = ' '. ">CATT 모드...
  ctu_params-defsize  = ' '. ">기본화면 크기
  ctu_params-racommit = 'X'.
  ctu_params-nobinpt  = ' ' .
  ctu_params-nobiend  = ' '.

  CLEAR g_count.

  IF r_ucomm EQ 'ZTIT105' OR
     r_ucomm EQ 'ZTIT901' OR
     r_ucomm EQ 'ZTIT901S'.
    PERFORM  get_selected_row  TABLES lt_row_no.
  ENDIF.

  CHECK g_count GT 0.

* Message preparations
  PERFORM  set_message_preparations.

  CASE r_ucomm.
    WHEN 'ZTIT105'.
*> 보험료 정보를 Update.
      PERFORM  modify_insurance_table.
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
      CLEAR: g_count, g_wrbtr, g_wmwst.
      REFRESH: it_vendor.

*> 데이타 체크.
      LOOP AT it_list INTO gs_list WHERE box = 'X'.
        CLEAR: gs_list-errmd.

        MOVE: gs_list-lifnr  TO  it_vendor-lifnr.
        COLLECT it_vendor.
*> 전기상태.
        IF NOT gs_list-icsno IS INITIAL.
          gs_list-errmd = 'X'.
          IF NOT gs_list-belnr IS INITIAL.
            MESSAGE s132 WITH gs_list-iipno gs_list-amdsq '전기'.
          ELSE.
            MESSAGE s132 WITH gs_list-iipno gs_list-amdsq '생성'.
          ENDIF.
          PERFORM set_return_message_fill USING 'E'.
        ENDIF.

        IF gs_list-lifnr IS INITIAL.
          gs_list-errmd = 'X'.
          MESSAGE s160 WITH gs_list-iipno gs_list-amdsq '보험회사'.
          PERFORM set_return_message_fill USING 'E'.
        ENDIF.

        IF gs_list-itpa1c IS INITIAL AND
           gs_list-errmd  IS INITIAL.
          gs_list-errmd = 'X'.
          MESSAGE s160 WITH gs_list-iipno gs_list-amdsq '통화단위'.
          PERFORM set_return_message_fill USING 'E'.
        ENDIF.

        IF gs_list-itpa1  IS INITIAL AND
           gs_list-errmd  IS INITIAL.
          gs_list-errmd = 'X'.
          MESSAGE s160 WITH gs_list-iipno gs_list-amdsq '보험료'.
          PERFORM set_return_message_fill USING 'E'.
        ENDIF.

        ADD gs_list-itpa1 TO g_wrbtr.
        ADD 0             TO g_wmwst.
        MODIFY it_list FROM gs_list.
      ENDLOOP.

*> 합계전표일 경우 Vendor 등을 체크함.
      IF ztisscrcom-monsc EQ 'S'.
        DESCRIBE TABLE it_vendor LINES g_line.
        CASE g_line.
          WHEN 0.
            MESSAGE s158.
            PERFORM set_return_message_fill USING 'E'.
          WHEN 1.
          WHEN OTHERS.
            MESSAGE s159.
            PERFORM set_return_message_fill USING 'E'.
        ENDCASE.
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

*> 보험료 정보를 Update.
      PERFORM  modify_insurance_table.
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
  PERFORM p3000_field_category_build.
  PERFORM p3800_field_attribute_change.
*  PERFORM p9000_refresh_display.
  CALL METHOD g_grid->refresh_table_display.

ENDFORM.                    "handle_user_command_grid
*&---------------------------------------------------------------------*
*&      Form  set_return_message_FILL
*&---------------------------------------------------------------------*
FORM set_return_message_fill USING p_msgty.

*> build message
  zti_message p_msgty sy-msgid sy-msgno
              sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

ENDFORM.                    " set_return_message_FILL
*&---------------------------------------------------------------------*
*&      Form  p3210_exclude_table_build
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

ENDFORM.                    " p3210_exclude_table_build
*&---------------------------------------------------------------------*
*&      Form  p3700_layout_build
*&---------------------------------------------------------------------*
FORM p3700_layout_build .

** General display options
  gs_layout_g-cwidth_opt = 'X'.
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

ENDFORM.                    " p3700_layout_build
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
*&      Form  BUILD_IP_CHANGED_BDCDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_ip_changed_bdcdata .

  DATA: l_text_amout(20).

  REFRESH: bdcdata.
  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR1000'          '0200',
         ' ' 'ZTISSCRCOM-IIPNO'  gs_list-iipno,
         ' ' 'ZTISSCRCOM-AMSEQ'  gs_list-amdsq,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.
*> 세부화면.
  WRITE gs_list-itpa1 TO l_text_amout CURRENCY gs_list-itpa1c.
  PERFORM    set_write_no_mask(ztir9000)
                                    CHANGING  l_text_amout.

  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR1000'          '2000',
         ' ' 'ZTITIP1-ITPA1'    l_text_amout,
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.

  PERFORM bdc_dynpro_build USING :
         'X' 'SAPLSPO1'          '0300',
         ' ' 'BDC_OKCODE'       '=YES'.

ENDFORM.                    " BUILD_IP_CHANGED_BDCDATA
*&---------------------------------------------------------------------*
*&      Form  build_changed_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_changed_message  USING    p_subrc.

  IF p_subrc EQ 0.
    MESSAGE s202 WITH gs_list-iipno.
    PERFORM set_return_message_fill USING sy-msgty.
  ELSE.
    LOOP AT messtab WHERE msgtyp EQ 'E'.
      sy-msgno = messtab-msgnr.
      zti_message messtab-msgtyp messtab-msgid sy-msgno
          messtab-msgv1 messtab-msgv2 messtab-msgv3 messtab-msgv4.
    ENDLOOP.
    IF sy-subrc NE 0.
      MESSAGE s926.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.
  ENDIF.

ENDFORM.                    " build_changed_message
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
*> 개별전표일 경우.
  IF ztisscrcom-monsc EQ 'I'.

*> 일괄전표일 경우.
  ELSE.

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
*&      Form  FILL_DEFAULT_HEADER_DATA
*&---------------------------------------------------------------------*
FORM fill_default_header_data .

  LOOP AT it_list INTO gs_list WHERE box = 'X'.
    EXIT.
  ENDLOOP.

  SELECT SINGLE *
    FROM ztitig07
   WHERE bukrs EQ t001-bukrs
     AND cstct EQ 'H'.

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
        gs_list-ispno    TO    ztitcsk-xblnr,
        gs_list-lifnr    TO    ztitcsk-lifnr,
        gs_list-itpa1c   TO    ztitcsk-waers,
        g_wrbtr          TO    ztitcsk-wrbtr,
        g_wmwst          TO    ztitcsk-wmwst.

  IF ztitcsk-bupla IS INITIAL.
    ztitcsk-bupla = gs_list-bupla.
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
                                         'I'
                                 CHANGING ztitcsk-bktxt.

  SELECT SINGLE *
    FROM lfa1
   WHERE lifnr  EQ  gs_list-lifnr.

*> 입력된 값 체크.
  PERFORM  check_input_value.

ENDFORM.                    " FILL_DEFAULT_HEADER_DATA
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
*&      Form  DISPLAY_ERROR_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_error_message .

  DATA: l_if_null TYPE REF TO if_message_obj_mm.

*> 오류정보가 존재시 메시지 상자 POPUP.
  g_line = g_message_handler->get_severity_bo(
                          im_business_obj          = l_if_null
                          im_include_child_objects = 'X' ).

  IF g_line GT 0.
    CALL METHOD g_message_handler->show( im_popup = 'X'
      im_amodal = ' ' ).
  ENDIF.

ENDFORM.                    " DISPLAY_ERROR_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  modify_insurance_table
*&---------------------------------------------------------------------*
*>      보험료 정보를 Update.
*----------------------------------------------------------------------*
FORM modify_insurance_table .

  DATA l_subrc LIKE sy-subrc.

  LOOP AT it_list INTO gs_list WHERE box   EQ 'X'
                                 AND errmd EQ space.
    g_tabix = sy-tabix.

    SELECT SINGLE *
      FROM ztitip1
     WHERE iipno   EQ  gs_list-iipno
       AND amdsq   EQ  gs_list-amdsq.

    IF gs_list-itpa1 EQ ztitip1-itpa1.
      MESSAGE s161 WITH gs_list-iipno gs_list-amdsq.
      PERFORM set_return_message_fill USING 'W'.
    ELSE.
*> build BDC data
      PERFORM build_ip_changed_bdcdata.
*> Call transaction
      PERFORM bdc_transaction        USING 'ZTIT105' l_subrc.
*> build Message internal table.
      PERFORM build_changed_message  USING l_subrc.

      IF l_subrc NE 0.
        gs_list-errmd = 'X'.
      ENDIF.
    ENDIF.
    MODIFY it_list FROM gs_list INDEX g_tabix.
  ENDLOOP.

ENDFORM.                    " modify_insurance_table
*&---------------------------------------------------------------------*
*&      Form  execute_individual_posting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM execute_individual_posting .
  DATA: l_subrc   LIKE sy-subrc.

  LOOP AT it_list INTO gs_list WHERE box = 'X'
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
*       text
*----------------------------------------------------------------------*
FORM build_individual_posting_data .

  DATA: l_text_amout(20).

  REFRESH: bdcdata.

  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR9000'          '0100',
         ' ' 'ZTISSCRCOM-BUKRS'  ztitcsk-bukrs,
         ' ' 'ZTISSCRCOM-BUDAT'  ztitcsk-budat,
         ' ' 'ZTISSCRCOM-BLDAT'  ztitcsk-bldat,
         ' ' 'ZTISSCRCOM-LIFNR'  gs_list-lifnr,
         ' ' 'ZTISSCRCOM-EXPGR'  'I',
*         ' ' 'ZTISSCRCOM-CSTYP'  ZTISSCRCOM-CSTYP
         ' ' 'ZTISSCRCOM-BLART'  ztitcsk-blart,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.

*> 세부화면.
  WRITE gs_list-itpa1 TO l_text_amout CURRENCY gs_list-itpa1c.
  PERFORM    set_write_no_mask(ztir9000)
                                    CHANGING  l_text_amout.

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
         ' ' 'ZTITCSK-BKTXT'  ztitcsk-bktxt,
*         ' ' 'ZTITCSK-BUDAT'
*         ' ' 'ZTITCSK-BLART'
*         ' ' 'ZTITCSK-BLDAT'
*         ' ' 'ZTITCSK-BUPLA'  ZTITCSK-bupla,
*         ' ' 'ZTITCSK-GSBER'  ZTITCSK-gsber,
*         ' ' 'ZTITCSK-ZLSPR'  ZTITCSK-zlspr,
*         ' ' 'ZTITCSK-AKONT'
*         ' ' 'ZTITCSK-ZLSCH'  ZTITCSK-zlsch,
*         ' ' 'ZTITCSK-ZTERM'  ztitcsk-zterm,
*         ' ' 'ZTITCSK-WRBTR'  l_text_amout,
*         ' ' 'ZTITCSK-WAERS'
*         ' ' 'ZTITCSK-MWSKZ'  ZTITCSK-mwskz,
*         ' ' 'ZTITCSK-WMWST'  '0',
*         ' ' 'ZTITCSK-FWBAS'  '0',
*         ' ' 'ZTITCSK-XBLNR'  gs_list-ispno,
*         ' ' 'ZTITCSK-BKTXT'  ztitcsk-bktxt,
*         ' ' 'ZTITCSK-SGTXT'  ZTITCSK-sgtxt,
         ' ' 'ZTISCSIT-EXPCD(01)'  gs_list-expcd,
         ' ' 'ZTISCSIT-IIPNO(01)'  gs_list-iipno,
         ' ' 'ZTISCSIT-AMSEQ(01)'  gs_list-amdsq,
         ' ' 'ZTISCSIT-WRBTR(01)'  l_text_amout,
         ' ' 'ZTISCSIT-MWSKZ(01)'  ztitcsk-mwskz.
*         ' ' 'ZTISCSIT-WMWST(01)'  '0',
*         ' ' 'ZTISCSIT-FWBAS(01)'  '0'.

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

ENDFORM.                    " build_individual_posting_data
*&---------------------------------------------------------------------*
*&      Form  execute_collective_posting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM execute_collective_posting .

  DATA: l_subrc   LIKE sy-subrc.

  REFRESH: bdcdata.
  CLEAR: g_cnt, g_wrbtr.

*> 전기할 품목의 Counter.
  LOOP AT it_list INTO gs_list WHERE box = 'X'
                                 AND errmd EQ space.
    ADD 1 TO g_cnt.
    ADD gs_list-itpa1 TO g_wrbtr.
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
        l_icssq           TYPE ztiicssq.

  REFRESH: bdcdata.

  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR9000'          '0100',
         ' ' 'ZTISSCRCOM-BUKRS'  ztitcsk-bukrs,
         ' ' 'ZTISSCRCOM-BUDAT'  ztitcsk-budat,
         ' ' 'ZTISSCRCOM-BLDAT'  ztitcsk-bldat,
         ' ' 'ZTISSCRCOM-LIFNR'  gs_list-lifnr,
         ' ' 'ZTISSCRCOM-EXPGR'  'I',
*         ' ' 'ZTISSCRCOM-CSTYP'  ZTISSCRCOM-CSTYP
         ' ' 'ZTISSCRCOM-BLART'  ztitcsk-blart,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.

*> 세부화면.
  WRITE g_wrbtr TO l_text_amout CURRENCY ztitcsk-waers.
  PERFORM    set_write_no_mask(ztir9000)
                                    CHANGING  l_text_amout.

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
*         ' ' 'ZTITCSK-XBLNR'  ztitcsk-xblnr,
*         ' ' 'ZTITCSK-BKTXT'  ztitcsk-bktxt.
**         ' ' 'ZTITCSK-SGTXT'  ZTITCSK-sgtxt.

  IF NOT ztitig00-chkbp IS INITIAL.
    PERFORM bdc_dynpro_build USING :
         ' ' 'ZTITCSK-BUPLA'  ztitcsk-bupla.
  ENDIF.
  IF NOT ztitig00-chkba IS INITIAL.
    PERFORM bdc_dynpro_build USING :
         ' ' 'ZTITCSK-GSBER'  ztitcsk-gsber.
  ENDIF.

  CLEAR: g_count.
  LOOP AT it_list INTO gs_list WHERE box = 'X'
                                 AND errmd EQ space.
    ADD 1 TO g_count.

    WRITE gs_list-itpa1 TO l_text_amout CURRENCY gs_list-itpa1c.
    PERFORM    set_write_no_mask(ztir9000)
                                      CHANGING  l_text_amout.

    IF g_count EQ 1.
      PERFORM bdc_dynpro_build USING :
             ' ' 'ZTISCSIT-EXPCD(01)'  gs_list-expcd,
             ' ' 'ZTISCSIT-IIPNO(01)'  gs_list-iipno,
             ' ' 'ZTISCSIT-AMSEQ(01)'  gs_list-amdsq,
             ' ' 'ZTISCSIT-WRBTR(01)'  l_text_amout,
             ' ' 'ZTISCSIT-MWSKZ(01)'  ztitcsk-mwskz.
*             ' ' 'ZTISCSIT-WMWST(01)'  '0',
*             ' ' 'ZTISCSIT-FWBAS(01)'  '0'.
      l_icssq = 1.
    ELSE.
      PERFORM bdc_dynpro_build USING :
             'X' 'ZTIR9000'          '2000',
             ' ' 'ZTISCSIT-EXPCD(02)'  gs_list-expcd,
             ' ' 'ZTISCSIT-IIPNO(02)'  gs_list-iipno,
             ' ' 'ZTISCSIT-AMSEQ(02)'  gs_list-amdsq,
             ' ' 'ZTISCSIT-WRBTR(02)'  l_text_amout,
             ' ' 'ZTISCSIT-MWSKZ(02)'  ztitcsk-mwskz.
*             ' ' 'ZTISCSIT-WMWST(02)'  '0',
*             ' ' 'ZTISCSIT-FWBAS(02)'  '0'.
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

ENDFORM.                    " build_collective_posting_data
*&---------------------------------------------------------------------*
*&      Form  get_f4_for_expcd_dynpro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_f4_for_expcd_dynpro USING p_bukrs
                                   p_expgr
                                   p_expcd TYPE  help_info-dynprofld.

*> 비용코드 HELP
  DATA : BEGIN OF it_ztitig06 OCCURS 0,
                  expcd      LIKE ztitig06-expcd,
                  exptx      LIKE ztitig06-exptx,
                  mwskz      LIKE ztitig06-mwskz,
                  kschl      LIKE ztitig06-kschl,
                  cscty      LIKE ztitig06-cscty,
                  saknr      LIKE ztitig06-saknr,
         END   OF it_ztitig06.
*> HELP용.
  DATA : dynprog  LIKE sy-repid,
         dynnr    LIKE sy-dynnr,
         g_ddtext LIKE dd07v-ddtext,
         g_window_title(60),
         g_display.

  CLEAR: g_display.
  PERFORM get_domain_value_text(ztir0000)
                                USING 'ZTIEXPGR'
                                      ztitcsk-expgr
                                      g_ddtext.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_ztitig06
    FROM ztitig06
   WHERE bukrs   EQ   p_bukrs
     AND expgr   EQ   p_expgr.

  IF sy-subrc NE 0.
    MESSAGE s861 WITH p_bukrs g_ddtext.
    EXIT.
  ENDIF.

  dynprog = sy-repid.
  dynnr   = sy-dynnr.

*  WINDOW_TITLE = DD07T-DDTEXT.
  CONCATENATE g_ddtext '코드 HELP' INTO g_window_title
              SEPARATED BY space.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
           EXPORTING
*                RETFIELD        = 'OTYPE'
                retfield        = 'EXPCD'
                dynpprog        = dynprog
                dynpnr          = dynnr
                dynprofield     = p_expcd
                window_title    = g_window_title
                value_org       = 'S'
                display         = g_display
           TABLES
                value_tab       = it_ztitig06
           EXCEPTIONS
                parameter_error = 1
                no_values_found = 2
                OTHERS          = 3.

  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

ENDFORM.                    " get_f4_for_expcd_dynpro
*&---------------------------------------------------------------------*
*&      Form  p1101_check_input_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p1101_check_input_value .

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
     AND cstct EQ 'H'.

  SELECT SINGLE *
    FROM t005
   WHERE land1 EQ t001-land1.

  IF g_answer IS INITIAL.
    CALL FUNCTION 'Z_TI_EXPENCES_CODE_BY_GROUP'
      EXPORTING
        xbukrs    = t001-bukrs
        xexpgr    = 'I'
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
    PERFORM set_return_message_fill USING sy-msgty.
  ELSE.
    LOOP AT messtab WHERE msgtyp EQ 'E'.
      sy-msgno = messtab-msgnr.
      zti_message messtab-msgtyp messtab-msgid sy-msgno
          messtab-msgv1 messtab-msgv2 messtab-msgv3 messtab-msgv4.
    ENDLOOP.
    IF sy-subrc NE 0.
      MESSAGE s926.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.
  ENDIF.

ENDFORM.                    " build_posted_message
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
*      e_zlsch = ztitcsk-zlsch
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
*&      Form  p3800_field_attribute_change
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

ENDFORM.                    " p3800_field_attribute_change
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

    IF gs_fieldcat_g-fieldname = 'ITPA1'.         " 금액.
*       gs_fieldcat_g-fieldname = 'HWAER'.
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
*&      Form  p3500_sort_table_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p3500_sort_table_build .

  CLEAR gs_sort_g.
  gs_sort_g-spos      = '01'.
  gs_sort_g-fieldname = 'LIFNR'.
  gs_sort_g-up        = 'X'.
  gs_sort_g-subtot    = 'X'.
*  gs_sort_g-LEVEL     =  1.
*  gs_sort_g-GROUP     = 'X'.
  APPEND gs_sort_g TO it_sort_g.

*  CLEAR gs_sort_g.
*  gs_sort_g-spos      = '02'.
*  gs_sort_g-fieldname = 'EXPCD'.
*  gs_sort_g-up        = 'X'.
*  gs_sort_g-subtot    = 'X'.
**  gs_sort_g-LEVEL     =  1.
**  gs_sort_g-GROUP     = 'X'.
*  APPEND gs_sort_g TO it_sort_g.

ENDFORM.                    " p3500_sort_table_build
*&---------------------------------------------------------------------*
*&      Form  set_message_preparations
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_message_preparations .

  CALL METHOD cl_message_handler_mm=>get_handler
    IMPORTING
      ex_handler = g_message_handler.

  CALL METHOD g_message_handler->set_config_for_mepo( ).
  CALL METHOD g_message_handler->remove_all( ).
  CALL METHOD g_message_handler->cleanup( ).

ENDFORM.                    " set_message_preparations
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
