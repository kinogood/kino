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
* Date         Programmer   Transport#  Description                    *
*----------------------------------------------------------------------*
* 2011-01-04   MMB03        HS코드 추가                                *
* 2019.04.19   권민선       [기능개선_275072]비용지급처, 비용지급처명  *
*                                            공급업체, 공급업체명 추가 *
*2020.08.11    이원형       Company 별 구매처 적용 로직 추가
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
      ebeln   LIKE ztivip01-ebeln,
      tapdt   LIKE ztivip01-tapdt,  "신청일자.
      opamt   LIKE ztivip01-opamt,  "개설금액
      opndt   LIKE ztivip01-opndt,  "개설일자
* 2011/01/04
      ihscd   LIKE ztivip01-ihscd,  "HS코드
*

      inscp   LIKE ztitip1-inscp,   "보험회사(EDI 코드).
      lifnr   LIKE ztstig3-lifnr,   "보험회사(SAP 코드)
      namet   LIKE ztstig3-namet,   "보험사명.
*--{기능개선_275072 - 추가
      lifnr2  LIKE lfa1-lifnr,      "공급업체.
      name2   LIKE lfa1-name1,      "공급업체명.
*--}기능개선_275072 - 2019.04.19
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
      icpnm   LIKE ztivip01-icpnm,  "ADVH:손해보험회사 상호
      ispno   LIKE ztivip01-ispno,  "ADVH:보험증권번호
      iopdt   LIKE ztivip01-iopdt,  "APP:보험개시일
      iisdt   LIKE ztivip01-iisdt,  "증권발급일
      ishnm   LIKE ztivip01-ishnm,  "선적항 도시/지역명
      ilpnm   LIKE ztivip01-ilpnm,  "최종목적지 도시/지역명
      lifre   LIKE ztivip01-lifre,  "다른 송장 발행처 "기능개선_275072
      livst   LIKE ztitcsk-livst,   "전기여부.
      expcd   LIKE ztitcsp-expcd,   "비용코드.
      icsno   LIKE ztitcsk-icsno,   "비용문서번호.
      belnr   LIKE ztitcsk-belnr,   "회계전표.
      bukrs   LIKE ztitcsk-bukrs,   "회사코드,
      bupla   LIKE ztivip01-bupla,
      cnam    LIKE ztivip01-cnam,   "작성인
      cdat    LIKE ztivip01-cdat,   "생성일
      ctme    LIKE ztivip01-ctme,   "생성시간
      unam    LIKE ztivip01-unam,   "최종변경인
      udat    LIKE ztivip01-udat,   "변경일
      utme    LIKE ztivip01-utme,   "최종변경시간
      exptx   LIKE ztislccs-exptx,
      docnm   LIKE ztislccs-docnm,
      refno   LIKE ztislccs-refno,
      dmbtr   LIKE ztislccs-dmbtr,
      wrbtr   LIKE ztivip01-itpa1,
      fwbas   LIKE ztislccs-fwbas,
      wmwst   LIKE ztislccs-wmwst,
      mwskz   LIKE ztislccs-mwskz,
      cstyp   LIKE ztislccs-cstyp,
      vorgang LIKE ztislccs-vorgang,
      blart   LIKE ztislccs-blart,
      hwaer   LIKE ztislccs-hwaer,
      zfbdt   LIKE ztislccs-zfbdt,
      kschl   LIKE ztislccs-kschl,
      cscty   LIKE ztislccs-cscty,
      cstcl   LIKE ztislccs-cstcl,
      ccuky   LIKE ztislccs-ccuky,
      moacg   LIKE ztislccs-moacg,
      kursf   LIKE ztislccs-kursf,
      pcdra   LIKE ztislccs-pcdra,
      apday   LIKE ztislccs-apday,
      apfrd   LIKE ztislccs-apfrd,
      apend   LIKE ztislccs-apend,
      finno   LIKE ztislccs-finno,
      fbseq   LIKE ztislccs-fbseq,
      END   OF ty_list.

DATA: gs_disp1 TYPE  ty_list.

TYPES:  BEGIN OF ty_list1.
        INCLUDE STRUCTURE gs_disp1.
TYPES:  celltab TYPE lvc_t_styl.            " Cell단위 수정 스타일
TYPES:  END   OF ty_list1.

************************************************************************
* SAP Include Define                                                   *
************************************************************************
INCLUDE : <icon>,
          <symbol>,
          zts_reuse_bdc_subroutine_f00.
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: l_yn    TYPE c.
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
        ekpo,
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
** JS전선 회사코드 2007/04 BY-MH.LEE -----------------
*CONSTANTS:
*    c_bukrs     LIKE t001-bukrs     VALUE '1000'.   ">Company code
** JS전선 회사코드 2007/04 ---------------------------
************************************************************************
* Internal Tables                                                      *
************************************************************************
*> Select용.
DATA: it_disp  TYPE STANDARD TABLE OF ty_list1,
      it_temp  TYPE STANDARD TABLE OF ty_list,
      gs_disp  TYPE ty_list1.


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
DATA: it_dispheader       TYPE slis_t_listheader.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
DATA: g_splitter            TYPE REF TO cl_gui_splitter_container,
      g_custom_container    TYPE REF TO cl_gui_custom_container,
      g_custom_container_1  TYPE REF TO cl_gui_container,
      g_grid                TYPE REF TO cl_gui_alv_grid,
* Docking Container
      g_docking             TYPE REF TO cl_gui_docking_container.

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

DATA : g_bukrs TYPE bukrs.


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

INCLUDE zti_reuse_forms_for_fi_posting.

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK dbsel WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_bukrs  FOR ztivip01-bukrs   "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk ,

  s_ebeln  FOR ztivip01-ebeln ,   "구매오더
  s_ekorg  FOR ztivip01-ekorg ,   "구매조직.
  s_ekgrp  FOR ztivip01-ekgrp ,   "구매그룹.
  s_bupla  FOR ztivip01-bupla,                  "사업장.
  s_mwskz  FOR ztitcsk-mwskz,                  "세금코드.
  s_knttp  FOR ekpo-knttp,
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
  DESCRIBE TABLE it_disp LINES g_line.
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
                  'S' 'FIELDNAME'   'BOX',
                  ' ' 'CHECKBOX'    'X',
                  'E' 'OUTPUTLEN'   '01',

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

                  'S' 'FIELDNAME'    'WRBTR',
                  ' ' 'CFIELDNAME'   'ITPA1C',
                  'E' 'OUTPUTLEN'    '17',

                  'S' 'REF_TABLE'     'ZTSTIG3',
                  ' ' 'FIELDNAME'     'LIFNR',
                  ' ' 'OUTPUTLEN'     12,
                  ' ' 'HOTSPOT'       'X',       " Double Click 효과
                  'E' 'KEY'           ' ',

                  'S' 'REF_TABLE'     'ZTSTIG3',
                  ' ' 'FIELDNAME'     'NAMET',
                  ' ' 'OUTPUTLEN'     20,
*                  ' ' 'HOTSPOT'       'X',       " Double Click 효과
                  'E' 'KEY'           ' ',

                  'S' 'FIELDNAME'   'LIFNR2',
                  ' ' 'COLTEXT'     '공급업체',
                  ' ' 'CFIELDNAME'  'LIFNR',
*                  ' ' 'CTABNAME'    'LFA1',
                  'E' 'OUTPUTLEN'   '10',

                  'S' 'FIELDNAME'   'NAME2',
                  ' ' 'COLTEXT'     '공급업체명',
                  ' ' 'CFIELDNAME'  'NAME1',
*                  ' ' 'CTABNAME'    'LFA1',
                  'E' 'OUTPUTLEN'   '10'.

  LOOP AT it_fieldcat_g INTO gs_fieldcat_g.
    CLEAR: gs_fieldcat_g-key,
           gs_fieldcat_g-tech,
           gs_fieldcat_g-no_out.

    CASE gs_fieldcat_g-fieldname.
      WHEN 'BOX'.
        gs_fieldcat_g-col_pos   = 0.
        gs_fieldcat_g-coltext   = '선택'.
        gs_fieldcat_g-col_opt   = 'X'.
*       gs_fieldcat_g-checkbox  = 'X'.
        gs_fieldcat_g-edit      = 'X'.
        gs_fieldcat_g-key       = 'X'.
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
      WHEN 'NAMET'. "보험회사명
        gs_fieldcat_g-coltext = '보험회사명'.
        gs_fieldcat_g-col_pos = 8.
      WHEN 'IIVATC'.   "송장금액.
        gs_fieldcat_g-col_pos = 10.
      WHEN 'IIVAT'.    "송장금액.
        gs_fieldcat_g-col_pos = 11.
      WHEN 'IWART'.   "희망이익률.
        gs_fieldcat_g-col_pos = 12.
      WHEN 'IAJRT'.   "환률.
        gs_fieldcat_g-col_pos = 13.
      WHEN 'ITPRT'.   "요율.
        gs_fieldcat_g-col_pos = 14.
      WHEN 'ITPAC'.   "계산필드.
        gs_fieldcat_g-col_pos = 15.
      WHEN 'WRBTR'.   "Total Premium
        gs_fieldcat_g-edit       = 'X'.
        gs_fieldcat_g-checktable = '!'.
        gs_fieldcat_g-do_sum     = 'X'.
        gs_fieldcat_g-coltext    = '공급가액'.
        gs_fieldcat_g-col_pos    = 16.
      WHEN 'ITPA1C'. "ADVH:TOTAL 보험금액 통화
        gs_fieldcat_g-col_pos = 17.
      WHEN 'PSPNR'.   "hull no.
        gs_fieldcat_g-col_pos = 18.
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
*--{기능개선_275072 - 추가
      WHEN 'LIFNR'. "보험회사명
        gs_fieldcat_g-coltext = '비용지급처'.
        gs_fieldcat_g-no_out = 'X'.
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

  DATA: l_itpa1    TYPE ztiitpa1,
        l_amdsq    LIKE gs_disp-amdsq,
        old_itpa1  TYPE ztiitpa1.


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
          AND ebeln  IN s_ebeln  "구매오더
          AND docst  EQ 'O'      "상태
          AND iipno  IN s_iipno  "적하부보 관리번호.
          AND reqno  IN s_reqno  "수입의뢰 관리번호.
          AND bupla  IN s_bupla  "사업장.
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

*>
  SELECT *
        APPENDING CORRESPONDING FIELDS OF TABLE it_temp
        FROM ztitip1
        WHERE bukrs  IN s_bukrs  "회사코드.
          AND ebeln  IN s_ebeln  "구매오더
          AND docst  EQ 'O'      "상태
          AND iipno  IN s_iipno  "적하부보 관리번호.
          AND reqno  EQ space    "수입의뢰 관리번호.
          AND amdsq  IN s_amdsq  "Amend 차수
          AND inscp  IN s_inscp  "보험회사.
          AND iopno  IN s_iopno  "포괄증권번호.
          AND iisdt  IN s_iisdt  "증권발급일.
          AND ispno  IN s_ispno  "증권번호.
          AND ekorg  IN s_ekorg  "구매조직.
          AND ekgrp  IN s_ekgrp  "구매그룹.
          AND cnam   IN s_cnam   "작성인.
          AND cdat   IN s_cdat   "생성일.
          AND unam   IN s_unam   "최종변경인.
          AND udat   IN s_udat.  "변경일.

  DESCRIBE TABLE it_temp LINES g_line.
  IF g_line EQ 0.
    MESSAGE s902.   EXIT.
  ENDIF.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_ztstig3
    FROM ztstig3
     FOR ALL ENTRIES IN it_temp
   WHERE parti  EQ  'P'
     AND epart  EQ  it_temp-inscp
     AND bukrs  IN s_bukrs.

  REFRESH: it_disp.
  LOOP AT it_temp INTO gs_disp1.
    g_tabix = sy-tabix.
    MOVE-CORRESPONDING gs_disp1 TO gs_disp.

*--{기능개선_275072 - 추가
   gs_disp-lifnr2 = gs_disp-lifnr.
   SELECT SINGLE name1
     INTO gs_disp-name2
     FROM lfa1
    WHERE lifnr = gs_disp-lifnr2.
*--}기능개선_275072 - 2019.04.19

    READ TABLE it_ztstig3 WITH KEY epart  = gs_disp-inscp.
    IF sy-subrc EQ 0.
      MOVE: it_ztstig3-lifnr  TO  gs_disp-lifnr,
            it_ztstig3-namet  TO  gs_disp-namet.
    ENDIF.


*>>>>>>> 계정지정범주 로직 추가....
    SELECT *
      FROM ekpo UP TO 1 ROWS
     WHERE ebeln EQ gs_disp-ebeln
       AND knttp IN s_knttp.
    ENDSELECT.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.


*> 선택한 비용코드를 추가함.
    LOOP AT it_ztitig06 WHERE box = 'X'.
*> 기존처리된 비용여부 판단.
      SELECT SINGLE *
        FROM ztivcs00
       WHERE bukrs   EQ  t001-bukrs
         AND expgr   EQ  'I'
         AND expcd   EQ  it_ztitig06-expcd
         AND refno   EQ  gs_disp-iipno
         AND amdsq   EQ  gs_disp-amdsq.

      IF sy-subrc EQ 0.
        IF p_step1 EQ 'X'.
          CONTINUE.
        ENDIF.
*> 비용문서 MOVE
*        MOVE-CORRESPONDING ZTIvcs00 TO gs_disp.
        MOVE: ztivcs00-livst    TO     gs_disp-livst,
              ztivcs00-icsno    TO     gs_disp-icsno,
              ztivcs00-bukrs    TO     gs_disp-bukrs,
              ztivcs00-belnr    TO     gs_disp-belnr.
      ELSE.
        IF p_step2 EQ 'X'.
          CONTINUE.
        ENDIF.
      ENDIF.

*> 비용코드.
      MOVE t001-waers          TO  gs_disp-hwaer.

      MOVE: it_ztitig06-expcd  TO  gs_disp-expcd,
            it_ztitig06-exptx  TO  gs_disp-exptx,
            it_ztitig06-rsbtr  TO  gs_disp-wrbtr,
            it_ztitig06-blart  TO  gs_disp-blart,
            '1'                TO  gs_disp-vorgang,
            'P'                TO  gs_disp-cstyp,
            t001-waers         TO  gs_disp-waers,
            it_ztitig06-mwskz  TO  gs_disp-mwskz,
            it_ztitig06-kschl  TO  gs_disp-kschl,
            it_ztitig06-cscty  TO  gs_disp-cscty,
*            it_ztitig06-cscrt  TO  GS_DISP-CSCRT,
            it_ztitig06-cstcl  TO  gs_disp-cstcl.

*> 적하보험료 차액 계산.
      SELECT SINGLE dftam
        INTO l_itpa1
        FROM ztitip4
       WHERE iipno  EQ  gs_disp-iipno
         AND amdsq  EQ  gs_disp-amdsq.
      IF NOT l_itpa1 IS INITIAL.
        gs_disp-itpa1 = l_itpa1.
      ELSE.
        IF NOT gs_disp-amdsq IS INITIAL.
          l_amdsq = gs_disp-amdsq - 1.
          SELECT SINGLE itpa1
            INTO old_itpa1
            FROM ztitip1
           WHERE iipno  EQ  gs_disp-iipno
             AND amdsq  EQ  l_amdsq.
          gs_disp-itpa1 = old_itpa1 - gs_disp-itpa1.
        ENDIF.
      ENDIF.

*> 적하보험료일 경우.
      IF NOT gs_disp-amdsq IS INITIAL.
        gs_disp-itpac = gs_disp-itpa1.
      ELSE.
        IF it_ztitig06-cstcl EQ 'I'.
*> Get exchange rate
          CLEAR: bapiret1, bapi1093_0.
          CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
            EXPORTING
              rate_type  = 'M'
              from_curr  = gs_disp-itoatc
              to_currncy = gs_disp-itpa1c
              date       = gs_disp-iisdt
            IMPORTING
              exch_rate  = bapi1093_0
              return     = bapiret1.
*      IF bapiret1-type EQ c_error.
*          MESSAGE ID bapiret1-id TYPE bapiret1-type
*                  NUMBER bapiret1-number
*                  WITH bapiret1-message_v1 bapiret1-message_v2
*                       bapiret1-message_v3 bapiret1-message_v4.
*      ENDIF.


          IF gs_disp-itoatc = t001-waers.
            gs_disp-iajrt = 1.
          ELSE.
            IF gs_disp-iajrt IS INITIAL.
              IF bapi1093_0-exch_rate_v IS INITIAL.
                gs_disp-iajrt  = bapi1093_0-exch_rate.
              ELSE.
                gs_disp-iajrt  = bapi1093_0-exch_rate_v.
              ENDIF.
            ENDIF.
          ENDIF.


*   보험료 계산. (송장금액 * 희망이익률):보험료 * 환률 * 보험요율.
          CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERN_9'
            EXPORTING
              currency        = gs_disp-itoatc
              amount_internal = gs_disp-itoat
            IMPORTING
              amount_external = bapicurx-bapicurx.

*      iivat   LIKE ztivip01-iivat,  "송장금액.
*      iivatc  LIKE ztivip01-iivatc, "통화.
*      iwart   LIKE ztitip1-iwart,   "희망이익률.
*      iajrt   LIKE ztitip1-iajrt,   "환률.
*      itprt   LIKE ztivip01-itprt,  "요율.

          gs_disp-itpac = bapicurx-bapicurx *  gs_disp-iajrt *
                      ( bapi1093_0-to_factor / bapi1093_0-from_factor ).

*        gs_disp-itpac = gs_disp-itpac * gs_disp-itprt.
          bapicurx-bapicurx = gs_disp-itpac.

          CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERN_9'
            EXPORTING
              currency             = gs_disp-itpa1c
              amount_external      = bapicurx-bapicurx
              max_number_of_digits = 18
            IMPORTING
              amount_internal      = gs_disp-itpac.

*>>>-> 10원단위 이하 절사....
          gs_disp-itpac = ( TRUNC( gs_disp-itpac * 10 ) ) / 10.

*    gs_disp-ITPAC = ( gs_disp-IIVAT * gs_disp-IWART )
*                    * gs_disp-IAJRT * gs_disp-ITPRT  .

        ENDIF.
      ENDIF.

*> 기존처리된 비용여부 판단.
      CASE gs_disp-livst.
        WHEN 'P'.
          gs_disp-icon = icon_green_light.
        WHEN 'N'.
          gs_disp-icon = icon_yellow_light.
        WHEN OTHERS.
          IF gs_disp-itpac <> gs_disp-itpa1.
            gs_disp-icon = icon_red_light.
          ELSE.
            IF gs_disp-itpa1 EQ 0.
              gs_disp-icon = icon_red_light.
            ELSE.
              gs_disp-icon = icon_yellow_light.
            ENDIF.
          ENDIF.
*          gs_disp-icon = icon_red_light.
      ENDCASE.

      gs_disp-refno = gs_disp-iipno.      " 증권관리번호
      gs_disp-docnm = gs_disp-ispno.      " 보험증권번호
      gs_disp-wrbtr = gs_disp-itpa1.      " 공급가액

      APPEND gs_disp TO it_disp.
    ENDLOOP.
  ENDLOOP.

*> 데이타가 존재하지 않을 경우.
  DESCRIBE TABLE it_disp LINES g_line.
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

*  IF g_custom_container IS INITIAL.
*
**   create a custom container control for our alv control
*    CREATE OBJECT g_custom_container
*        EXPORTING
*            container_name = 'CUSTOMER_CONTAINER_0100'.
*
*    CREATE OBJECT g_splitter
*                  EXPORTING parent = g_custom_container
*                            rows    = 1
*                            columns = 1.
*
*    CALL METHOD g_splitter->get_container
*                      EXPORTING row      = 1
*                                column   = 1
*                      RECEIVING container = g_custom_container_1.

  IF g_grid IS INITIAL.
* create the docking container
    CREATE OBJECT g_docking
      EXPORTING
        repid     = sy-repid
        dynnr     = sy-dynnr
        side      = g_docking->dock_at_left
        extension = 9999.

*   Create an Instance of ALV Control
    CREATE OBJECT g_grid
      EXPORTING
        i_parent = g_docking.

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
        it_outtab           = it_disp.

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

* append an icon to refresh
  CLEAR ls_toolbar.
  MOVE 0                    TO ls_toolbar-butn_type.
  MOVE 'REFRESH'            TO ls_toolbar-function.
  MOVE icon_refresh         TO ls_toolbar-icon.
  MOVE 'REFRESH'(120)    TO ls_toolbar-quickinfo.
  MOVE space                TO ls_toolbar-disabled.
  APPEND ls_toolbar         TO r_object->mt_toolbar.

* append an icon
  CLEAR ls_toolbar.
  MOVE 0                    TO ls_toolbar-butn_type.
  MOVE 'SELECT'             TO ls_toolbar-function.
  MOVE icon_select_all      TO ls_toolbar-icon.
  MOVE '모두 선택'(121)    TO ls_toolbar-quickinfo.
  MOVE space                TO ls_toolbar-disabled.
  APPEND ls_toolbar         TO r_object->mt_toolbar.

* append an icon
  CLEAR ls_toolbar.
  MOVE 0                    TO ls_toolbar-butn_type.
  MOVE 'DESELECT'           TO ls_toolbar-function.
  MOVE icon_deselect_all    TO ls_toolbar-icon.
  MOVE '선택 해제'(122)    TO ls_toolbar-quickinfo.
  MOVE space                TO ls_toolbar-disabled.
  APPEND ls_toolbar         TO r_object->mt_toolbar.

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
  MOVE '비용전기'(115)      TO ls_toolbar-quickinfo.
  MOVE '비용전기'(115)      TO ls_toolbar-text.
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
         ls_cells     TYPE lvc_s_modi,
         l_itpa1      LIKE ztitip1-itpa1,
         l_box        TYPE c.

  LOOP AT er_data_changed->mt_good_cells INTO ls_mod_cells.
    CASE ls_mod_cells-fieldname.
      WHEN 'WRBTR'.                 "> 보험료.
        READ TABLE it_disp   INTO  gs_disp
                             INDEX ls_mod_cells-row_id .
        IF gs_disp-itpac  EQ  ls_mod_cells-value .

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

* 공급가액을 입력한 경우 Checkbox Marking
        CALL METHOD er_data_changed->get_cell_value
          EXPORTING
            i_row_id    = ls_mod_cells-row_id
            i_fieldname = 'WRBTR'
          IMPORTING
            e_value     = l_itpa1.

        IF l_itpa1 IS INITIAL.
          l_box = ' '.
        ELSE.
          l_box = 'X'.
        ENDIF.

        CALL METHOD er_data_changed->modify_cell
          EXPORTING
            i_row_id    = ls_mod_cells-row_id
            i_fieldname = 'BOX'
            i_value     = l_box.

    ENDCASE.
  ENDLOOP.

ENDFORM.                    "handle_data_changed

*&---------------------------------------------------------------------*
*&      Form  handle_data_changed_finished
*&---------------------------------------------------------------------*
FORM  handle_data_changed_finished   USING p_modified
                                           p_sender.

*  DATA lt_rows     TYPE lvc_t_row.
*  DATA l_row_id    TYPE lvc_s_row.
*  DATA l_col_id    TYPE lvc_s_col.
*  DATA ls_stable   TYPE lvc_s_stbl.
*  DATA l_control   TYPE REF TO cl_gui_control.
*  DATA l_row_no    TYPE lvc_s_roid.
*  DATA lt_roid     TYPE lvc_t_roid.
*  DATA l_row       TYPE i.
*  DATA l_col       TYPE i.
*  DATA l_end_pos   TYPE i.
*  DATA l_start_pos TYPE i.
*
*  CHECK NOT p_modified IS INITIAL.
*
** keep in mind selected rows
*  REFRESH lt_rows.
*  CALL METHOD g_grid->get_selected_rows
*    IMPORTING
*      et_index_rows = lt_rows.
*
*  IF lt_rows[] IS INITIAL.
*    CALL METHOD g_grid->get_focus
*      IMPORTING
*        control           = l_control
*      EXCEPTIONS
*        cntl_error        = 1
*        cntl_system_error = 2
*        OTHERS            = 3.
** Flush now to avoid a system_pointer_pending dump.
*    CALL METHOD cl_gui_cfw=>flush.
*    IF sy-subrc = 0 AND
*       l_control = g_grid.
*      CALL METHOD g_grid->get_current_cell
*        IMPORTING
*          es_row_no = l_row_no
*          es_row_id = l_row_id
*          es_col_id = l_col_id
*          e_row     = l_row
*          e_col     = l_col.
*
** Flush now to avoid a system_pointer_pending dump.
*      CALL METHOD cl_gui_cfw=>flush.
*    ENDIF.
*  ENDIF.
*
*  CALL METHOD g_grid->refresh_table_display
*    EXPORTING
*      is_stable = ls_stable.
*
*  IF lt_rows[] IS INITIAL.
*    CALL METHOD g_grid->set_focus
*      EXPORTING
*        control = l_control.
** Flush now to avoid a system_pointer_pending dump.
*    CALL METHOD cl_gui_cfw=>flush.
*
*    IF sy-subrc  = 0       AND
*       l_control = g_grid.
*
*      l_start_pos = 1.
*      l_end_pos   = 1.
*
*      APPEND l_row_no TO lt_roid.
*
*      CALL METHOD g_grid->set_selected_rows
*        EXPORTING
**          IT_INDEX_ROWS            =
*          it_row_no                = lt_roid
**          IS_KEEP_OTHER_SELECTIONS =
*          .
*
** Flush now to avoid a system_pointer_pending dump.
*      CALL METHOD cl_gui_cfw=>flush.
*    ENDIF.
*  ELSE.
** reset selected rows
*    CALL METHOD g_grid->set_selected_rows
*      EXPORTING
*        it_index_rows = lt_rows.
*  ENDIF.
**   flush
*  CALL METHOD cl_gui_cfw=>flush.
*
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

  READ TABLE it_disp INTO gs_disp INDEX p_row.
  CHECK sy-subrc EQ 0.
  PERFORM display_ip_document(ztir0000)
                                     USING gs_disp-iipno
                                           gs_disp-amdsq.
ENDFORM.                    "handle_double_click
*&---------------------------------------------------------------------*
*&      Form  handle_hotspot_click
*&---------------------------------------------------------------------*
FORM handle_hotspot_click  USING e_row_id    TYPE lvc_s_row
                                 e_column_id TYPE lvc_s_col.

  READ TABLE it_disp INTO gs_disp INDEX e_row_id-index.
  CHECK sy-subrc EQ 0.

  CASE e_column_id-fieldname.
    WHEN 'IIPNO' OR 'AMDSQ'.
      PERFORM display_ip_document(ztir0000)
                                      USING gs_disp-iipno
                                            gs_disp-amdsq.
    WHEN 'REQNO' OR 'OPNNO'.
      PERFORM  display_import_document(ztir0000)
                                      USING gs_disp-reqno
                                            space
                                            space.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    "_hotspot_click
*&---------------------------------------------------------------------*
*&      Form  handle_user_command_grid
*&---------------------------------------------------------------------*
FORM handle_user_command_grid USING r_ucomm.

  DATA: l_valid           TYPE c,
        lt_row_no         TYPE lvc_t_roid WITH HEADER LINE.
  DATA: l_subrc           LIKE sy-subrc,
        l_text_amout(20)  TYPE c,
        l_plus_cnt        TYPE i,
        l_minus_cnt       TYPE i.

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

  CALL METHOD cl_gui_cfw=>set_new_ok_code
    EXPORTING
      new_code = r_ucomm.

*  IF r_ucomm EQ 'ZTIT105' OR
*     r_ucomm EQ 'ZTIT901' OR
*     r_ucomm EQ 'ZTIT901S'.
*    PERFORM  get_selected_row  TABLES lt_row_no.
  IF r_ucomm EQ 'SELECT'.
    PERFORM  set_selected_row USING 'X'.
    EXIT.
  ELSEIF r_ucomm EQ 'DESELECT'.
    PERFORM  set_selected_row USING ' '.
    EXIT.
  ELSEIF r_ucomm EQ 'REFRESH'.
    PERFORM refresh_confirm USING g_answer.
    CHECK g_answer = 'J'.
    PERFORM p2000_data_selections.
    PERFORM p3000_field_category_build.
    PERFORM p3800_field_attribute_change.
    PERFORM p9000_refresh_display.
  ENDIF.

*  CHECK g_count GT 0.
*
** Message preparations
*  PERFORM  set_message_preparations.
*
*  CASE r_ucomm.
*    WHEN 'ZTIT105'.
**> 보험료 정보를 Update.
*      PERFORM  modify_insurance_table.
*    WHEN 'ZTIT901'.
**> 전표전기 종류 선택 함수(월합계산서 or 개별전표)
*      IF g_count EQ 1.
*        ztisscrcom-monsc = 'S'.
*      ELSE.
*        CALL FUNCTION 'Z_TI_COST_DOCUMENT_TYPE_POPUP'
*          IMPORTING
*            p_answer = g_answer
*            p_monsc  = ztisscrcom-monsc.
*
*        CHECK g_answer EQ 'Y'.
*      ENDIF.
*      CLEAR: g_count, g_wrbtr, g_wmwst.
*      REFRESH: it_vendor.
*
**> 데이타 체크.
*      CLEAR: l_plus_cnt, l_minus_cnt.
*      LOOP AT it_disp INTO gs_disp WHERE box = 'X'.
*        CLEAR: gs_disp-errmd.
*
**> 음수/양수 체크.
*        IF gs_disp-itpa1 GT 0.
*          ADD 1 TO l_plus_cnt.
*        ELSEIF gs_disp-itpa1 LT 0.
*          ADD 1 TO l_minus_cnt.
*        ENDIF.
*
*        MOVE: gs_disp-lifnr  TO  it_vendor-lifnr.
*        COLLECT it_vendor.
**> 전기상태.
*        IF NOT gs_disp-icsno IS INITIAL.
*          gs_disp-errmd = 'X'.
*          IF NOT gs_disp-belnr IS INITIAL.
*            MESSAGE s132 WITH gs_disp-iipno gs_disp-amdsq '전기'.
*          ELSE.
*            MESSAGE s132 WITH gs_disp-iipno gs_disp-amdsq '생성'.
*          ENDIF.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF gs_disp-lifnr IS INITIAL.
*          gs_disp-errmd = 'X'.
*          MESSAGE s160 WITH gs_disp-iipno gs_disp-amdsq '보험회사'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF gs_disp-itpa1c IS INITIAL AND
*           gs_disp-errmd  IS INITIAL.
*          gs_disp-errmd = 'X'.
*          MESSAGE s160 WITH gs_disp-iipno gs_disp-amdsq '통화단위'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF gs_disp-itpa1  IS INITIAL AND
*           gs_disp-errmd  IS INITIAL.
*          gs_disp-errmd = 'X'.
*          MESSAGE s160 WITH gs_disp-iipno gs_disp-amdsq '보험료'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        ADD gs_disp-itpa1 TO g_wrbtr.
*        ADD 0             TO g_wmwst.
*        MODIFY it_disp FROM gs_disp.
*      ENDLOOP.
*
**> 합계전표일 경우 Vendor 등을 체크함.
*      IF ztisscrcom-monsc EQ 'S'.
*
*        DESCRIBE TABLE it_vendor LINES g_line.
*        CASE g_line.
*          WHEN 0.
*            MESSAGE s158.
*            PERFORM set_return_message_fill USING 'E'.
*          WHEN 1.
*          WHEN OTHERS.
*            MESSAGE s159.
*            PERFORM set_return_message_fill USING 'E'.
*        ENDCASE.
*
**> 음수/양수를 동시 전기못하도록 수정.
*        IF l_minus_cnt GT 0 AND
*           l_plus_cnt  GT 0.
*          MESSAGE s148 WITH l_minus_cnt.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
**> Error Message Display.
*        PERFORM display_error_message.
*        CHECK g_line EQ 0.
*      ENDIF.
*
**> 전기확인용 대화화면 Call
*      CLEAR: ok_code.
**> 전기용 HEADER DATA Fill
*      PERFORM   fill_default_header_data.
**> 확인 대화상자 Call
*      CALL SCREEN '0200' STARTING AT 1 8.
*      IF ok_code EQ 'ABBR'.
*        MESSAGE s900.
*        EXIT.
*      ELSEIF ok_code EQ 'SIMU'.
*        ctu_params-dismode  = 'E'. ">처리모드
*      ENDIF.
*      CLEAR: g_success, g_error.
*
**> 보험료 정보를 Update.
*      PERFORM  modify_insurance_table.
**> 보험료 전기.
*      IF ztisscrcom-monsc EQ 'S'.
*        PERFORM execute_collective_posting.
*      ELSE.
*        PERFORM execute_individual_posting.
*      ENDIF.
*  ENDCASE.
*
**> Error Message Display.
*  PERFORM display_error_message.
**> 검색조건에 해당하는 데이타를 Select.
*  CHECK g_success GT 0.
*  PERFORM p2000_data_selections.
*  PERFORM p3000_field_category_build.
*  PERFORM p3800_field_attribute_change.
**  PERFORM p9000_refresh_display.
*  CALL METHOD g_grid->refresh_table_display.
*
ENDFORM.                    "handle_user_command_grid
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
                cl_gui_alv_grid=>mc_fc_loc_paste_new_row, " 겹쳐쓰기.
                cl_gui_alv_grid=>mc_fc_refresh.           " Refresh.

*                cl_gui_alv_grid=>mc_fc_maintain_variant,
*                cl_gui_alv_grid=>mc_fc_maximum,
*                cl_gui_alv_grid=>mc_fc_minimum,
*                cl_gui_alv_grid=>mc_fc_pc_file,
*                cl_gui_alv_grid=>mc_fc_print,
*                cl_gui_alv_grid=>mc_fc_print_back,
*                cl_gui_alv_grid=>mc_fc_print_prev,
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
  gs_layout_g-no_rowmove = 'X'.
  gs_layout_g-no_rowmark = 'X'.
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
*>---------------------------------------------------------------------
*> 보험료수정
*>---------------------------------------------------------------------
    WHEN 'ZTIT105'.
      PERFORM  modify_insurance_table.

*>---------------------------------------------------------------------
*> 비용전기.
*>---------------------------------------------------------------------
    WHEN 'ZTIT901'.
      PERFORM  get_selected_row  TABLES gt_row_no.

      CHECK g_count GT 0.
*> Clearing
      PERFORM  set_posting_data_initial.

*> 전기유형 선택.
      PERFORM  get_posting_type   USING g_count
                                        ztisscrcom-monsc  g_answer.
      CHECK g_answer EQ 'Y'.

*> 전기용 데이타 Collect.
      PERFORM build_posting_data.
*> Error Message Display.
      PERFORM display_error_message.
      CHECK g_line EQ 0.

*> 전기확인용 대화화면 Call
      CLEAR: ok_code.
*> 전기용 HEADER DATA Fill
      PERFORM   fill_posting_data.

*> 비용전기용 공통 함수.
      PERFORM   build_fi_document USING 'I'
                                        ztisscrcom-monsc.

      CHECK g_success GT 0.
*> 검색조건에 해당하는 데이타를 Select.
      PERFORM p2000_data_selections.
      PERFORM p3000_field_category_build.
      PERFORM p3800_field_attribute_change.
      PERFORM p9000_refresh_display.
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
         ' ' 'ZTISSCRCOM-IIPNO'  gs_disp-iipno,
         ' ' 'ZTISSCRCOM-AMSEQ'  gs_disp-amdsq,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.
*> 세부화면.
  WRITE gs_disp-wrbtr TO l_text_amout CURRENCY gs_disp-itpa1c.
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
    MESSAGE s202 WITH gs_disp-iipno.
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

*  DATA: l_valid TYPE c.
*
*  CALL METHOD g_grid->check_changed_data
*    IMPORTING
*      e_valid = l_valid.
*
*  IF l_valid EQ 'X'.
*    CALL METHOD g_grid->get_selected_rows
*      IMPORTING
*        et_row_no = pt_row_no[].
*
*    IF pt_row_no[] IS INITIAL.
*      MESSAGE s909.
*      EXIT.
*    ENDIF.
*
*    CLEAR gs_disp-box.
*    MODIFY it_disp FROM gs_disp TRANSPORTING box WHERE box = 'X'.
*
*    LOOP AT pt_row_no.
*      IF pt_row_no-row_id GT 0.
*        READ TABLE it_disp INTO gs_disp INDEX pt_row_no-row_id.
*        IF sy-subrc EQ 0.
*          ADD 1 TO g_count.
*          IF gs_disp-box NE 'X'.
*            gs_disp-box = 'X'.
*          ENDIF.
*          MODIFY it_disp FROM gs_disp INDEX pt_row_no-row_id.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.

  CLEAR: g_count.
  LOOP AT it_disp INTO gs_disp WHERE box = 'X'.
    ADD 1 TO g_count.
  ENDLOOP.
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
*> 일괄전기 확인메시지 사용시.
*      IF ztitig00-pstcm EQ 'X'.
      CALL FUNCTION 'Z_TI_POPUP_TO_CONFIRM_MESSAGE'
        EXPORTING
          xmode       = 'P'
          im_document = 'CS'
        IMPORTING
          answer      = g_answer.
      IF g_answer NE 'Y'.
        ok_code = 'ABBR'.
      ENDIF.
*      ENDIF.
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
      IF ztitcsk-iname IS INITIAL.
        PERFORM  check_mandatory_input(ztir0000)
                             USING  'ZTITCSK-INAME' 'E'.
      ENDIF.
      IF ztitcsk-hkont IS INITIAL.
        PERFORM  check_mandatory_input(ztir0000)
                             USING  'ZTITCSK-HKONT' 'E'.
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

  LOOP AT it_disp INTO gs_disp WHERE box = 'X'.
    EXIT.
  ENDLOOP.

  SELECT SINGLE *
    FROM ztitig07
   WHERE bukrs EQ t001-bukrs
     AND cstct EQ 'H'.

  IF ztisscrcom-monsc EQ 'S'.
    IF g_wrbtr LT 0.
      ztitcsk-vorgang = '2'.
      g_wrbtr = g_wrbtr * -1.
      g_wmwst = g_wmwst * -1.
    ELSE.
      ztitcsk-vorgang = '1'.
    ENDIF.
  ENDIF.

  MOVE: sy-datlo         TO    ztitcsk-budat,
        sy-datlo         TO    ztitcsk-bldat,
        sy-datlo         TO    ztitcsk-zfbdt,
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
        gs_disp-ispno    TO    ztitcsk-xblnr,
        gs_disp-lifnr    TO    ztitcsk-lifnr,
        gs_disp-itpa1c   TO    ztitcsk-waers,
        g_wrbtr          TO    ztitcsk-wrbtr,
        g_wmwst          TO    ztitcsk-wmwst.

  IF ztitcsk-bupla IS INITIAL.
    ztitcsk-bupla  =  gs_disp-bupla.
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
   WHERE lifnr  EQ  gs_disp-lifnr.

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
         screen-name EQ 'ZTITCSK-SGTXT' OR
         screen-name EQ 'ZTITCSK-VORGANG'.
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
**&---------------------------------------------------------------------
**
**&      Form  DISPLAY_ERROR_MESSAGE
**&---------------------------------------------------------------------
**
**       text
**----------------------------------------------------------------------
**
*FORM display_error_message .
*
*  DATA: l_if_null TYPE REF TO if_message_obj_mm.
*
**> 오류정보가 존재시 메시지 상자 POPUP.
*  g_line = g_message_handler->get_severity_bo(
*                          im_business_obj          = l_if_null
*                          im_include_child_objects = 'X' ).
*
*  IF g_line GT 0.
*    CALL METHOD g_message_handler->show( im_popup = 'X'
*      im_amodal = ' ' ).
*  ENDIF.
*
*ENDFORM.                    " DISPLAY_ERROR_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  modify_insurance_table
*&---------------------------------------------------------------------*
*>      보험료 정보를 Update.
*----------------------------------------------------------------------*
FORM modify_insurance_table .

  DATA l_subrc LIKE sy-subrc.

  LOOP AT it_disp INTO gs_disp WHERE box   EQ 'X'
                                 AND errmd EQ space.
    g_tabix = sy-tabix.

    SELECT SINGLE *
      FROM ztitip1
     WHERE iipno   EQ  gs_disp-iipno
       AND amdsq   EQ  gs_disp-amdsq.

    IF gs_disp-wrbtr EQ ztitip1-itpa1.
      MESSAGE s161 WITH gs_disp-iipno gs_disp-amdsq.
      PERFORM set_return_message_fill USING 'W'.
    ELSE.
      IF gs_disp-amdsq IS INITIAL.
*> build BDC data
        PERFORM build_ip_changed_bdcdata.
*> Call transaction
        PERFORM bdc_transaction        USING 'ZTIT105' l_subrc.
*> build Message internal table.
        PERFORM build_changed_message  USING l_subrc.

        IF l_subrc NE 0.
          gs_disp-errmd = 'X'.
        ENDIF.
      ELSE.
        MESSAGE s149 WITH gs_disp-iipno gs_disp-amdsq.
        PERFORM set_return_message_fill USING 'W'.
      ENDIF.
    ENDIF.
    MODIFY it_disp FROM gs_disp INDEX g_tabix.
  ENDLOOP.

ENDFORM.                    " modify_insurance_table
*&---------------------------------------------------------------------*
*&      Form  execute_individual_posting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
*       text
*----------------------------------------------------------------------*
FORM build_individual_posting_data .

  DATA: l_text_amout(20).
  DATA  l_date(10)        TYPE c.

  REFRESH: bdcdata.

  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR9000'          '0100',
         ' ' 'ZTISSCRCOM-BUKRS'  ztitcsk-bukrs,
         ' ' 'ZTISSCRCOM-BUDAT'  ztitcsk-budat,
         ' ' 'ZTISSCRCOM-BLDAT'  ztitcsk-bldat,
         ' ' 'ZTISSCRCOM-LIFNR'  gs_disp-lifnr,
         ' ' 'ZTISSCRCOM-EXPGR'  'I',
*         ' ' 'ZTISSCRCOM-CSTYP'  ZTISSCRCOM-CSTYP
         ' ' 'ZTISSCRCOM-BLART'  ztitcsk-blart,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.

*> 세부화면.
  IF gs_disp-itpa1 LT 0.
    gs_disp-itpa1 = gs_disp-itpa1 * -1.
    ztitcsk-vorgang = '2'.
  ELSE.
    ztitcsk-vorgang = '1'.
  ENDIF.

  CLEAR: l_date.
  IF NOT ztitcsk-zfbdt IS INITIAL.
    WRITE ztitcsk-zfbdt TO l_date.
  ENDIF.

  WRITE gs_disp-itpa1 TO l_text_amout CURRENCY gs_disp-itpa1c.
  PERFORM    set_write_no_mask(ztir9000)
                                    CHANGING  l_text_amout.

  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR9000'          '2000',
         ' ' 'ZTITCSK-VORGANG' ztitcsk-vorgang,
         ' ' 'ZTITCSK-CSTYP'   ztitcsk-cstyp,
         ' ' 'ZTITCSK-INAME'   ztitcsk-iname,
         ' ' 'ZTITCSK-HKONT'   ztitcsk-hkont,
         ' ' 'ZTITCSK-EMPFK'   ztitcsk-empfk,
         ' ' 'ZTITCSK-ZFBDT'  l_date,
*         ' ' 'ZTITCSK-BUPLA'  ztitcsk-bupla,
*         ' ' 'ZTITCSK-GSBER'  ztitcsk-gsber,
         ' ' 'ZTITCSK-ZLSPR'   ztitcsk-zlspr,
         ' ' 'ZTITCSK-UZAWE'   ztitcsk-uzawe,
         ' ' 'ZTITCSK-ZLSCH'   ztitcsk-zlsch,
         ' ' 'ZTITCSK-ZTERM'   ztitcsk-zterm,
         ' ' 'ZTITCSK-MWSKZ'   ztitcsk-mwskz,
         ' ' 'ZTITCSK-XBLNR'   ztitcsk-xblnr,
         ' ' 'ZTITCSK-BKTXT'   ztitcsk-bktxt,
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
*         ' ' 'ZTITCSK-XBLNR'  gs_disp-ispno,
*         ' ' 'ZTITCSK-BKTXT'  ztitcsk-bktxt,
*         ' ' 'ZTITCSK-SGTXT'  ZTITCSK-sgtxt,
         ' ' 'ZTISCSIT-EXPCD(01)'  gs_disp-expcd,
         ' ' 'ZTISCSIT-IIPNO(01)'  gs_disp-iipno,
         ' ' 'ZTISCSIT-AMSEQ(01)'  gs_disp-amdsq,
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
  LOOP AT it_disp INTO gs_disp WHERE box = 'X'
                                 AND errmd EQ space.
    ADD 1 TO g_cnt.
    ADD gs_disp-itpa1 TO g_wrbtr.
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
  DATA  l_date(10)        TYPE c.

  REFRESH: bdcdata.

  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR9000'          '0100',
         ' ' 'ZTISSCRCOM-BUKRS'  ztitcsk-bukrs,
         ' ' 'ZTISSCRCOM-BUDAT'  ztitcsk-budat,
         ' ' 'ZTISSCRCOM-BLDAT'  ztitcsk-bldat,
         ' ' 'ZTISSCRCOM-LIFNR'  gs_disp-lifnr,
         ' ' 'ZTISSCRCOM-EXPGR'  'I',
*         ' ' 'ZTISSCRCOM-CSTYP'  ZTISSCRCOM-CSTYP
         ' ' 'ZTISSCRCOM-BLART'  ztitcsk-blart,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.

**> 세부화면.
*  WRITE g_wrbtr TO l_text_amout CURRENCY ztitcsk-waers.
*  PERFORM    set_write_no_mask(ztir9000)
*                                    CHANGING  l_text_amout.

  CLEAR: l_date.
  IF NOT ztitcsk-zfbdt IS INITIAL.
    WRITE ztitcsk-zfbdt TO l_date.
  ENDIF.

  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR9000'          '2000',
         ' ' 'ZTITCSK-VORGANG' ztitcsk-vorgang,
         ' ' 'ZTITCSK-CSTYP'   ztitcsk-cstyp,
         ' ' 'ZTITCSK-INAME'   ztitcsk-iname,
         ' ' 'ZTITCSK-HKONT'   ztitcsk-hkont,
*         ' ' 'ZTITCSK-BUPLA'   ztitcsk-bupla,
*         ' ' 'ZTITCSK-GSBER'   ztitcsk-gsber,
         ' ' 'ZTITCSK-ZFBDT'  l_date,
         ' ' 'ZTITCSK-EMPFK'   ztitcsk-empfk,
         ' ' 'ZTITCSK-ZLSPR'   ztitcsk-zlspr,
         ' ' 'ZTITCSK-UZAWE'   ztitcsk-uzawe,
         ' ' 'ZTITCSK-ZLSCH'   ztitcsk-zlsch,
         ' ' 'ZTITCSK-ZTERM'   ztitcsk-zterm,
         ' ' 'ZTITCSK-MWSKZ'   ztitcsk-mwskz,
         ' ' 'ZTITCSK-XBLNR'   ztitcsk-xblnr,
         ' ' 'ZTITCSK-BKTXT'   ztitcsk-bktxt.
*         ' ' 'ZTITCSK-XBLNR'   ztitcsk-xblnr,
*         ' ' 'ZTITCSK-BKTXT'   ztitcsk-bktxt.
**         ' ' 'ZTITCSK-SGTXT'   ZTITCSK-sgtxt.

  IF NOT ztitig00-chkbp IS INITIAL.
    PERFORM bdc_dynpro_build USING :
         ' ' 'ZTITCSK-BUPLA'  ztitcsk-bupla.
  ENDIF.
  IF NOT ztitig00-chkba IS INITIAL.
    PERFORM bdc_dynpro_build USING :
         ' ' 'ZTITCSK-GSBER'  ztitcsk-gsber.
  ENDIF.

  CLEAR: g_count.
  LOOP AT it_disp INTO gs_disp WHERE box = 'X'
                                 AND errmd EQ space.
    ADD 1 TO g_count.

    IF ztitcsk-vorgang EQ '2'.
      gs_disp-itpa1 = gs_disp-itpa1 * -1.
    ENDIF.

    WRITE gs_disp-itpa1 TO l_text_amout CURRENCY gs_disp-itpa1c.
    PERFORM    set_write_no_mask(ztir9000)
                                      CHANGING  l_text_amout.

    IF g_count EQ 1.
      PERFORM bdc_dynpro_build USING :
             ' ' 'ZTISCSIT-EXPCD(01)'  gs_disp-expcd,
             ' ' 'ZTISCSIT-IIPNO(01)'  gs_disp-iipno,
             ' ' 'ZTISCSIT-AMSEQ(01)'  gs_disp-amdsq,
             ' ' 'ZTISCSIT-WRBTR(01)'  l_text_amout,
             ' ' 'ZTISCSIT-MWSKZ(01)'  ztitcsk-mwskz.
*             ' ' 'ZTISCSIT-WMWST(01)'  '0',
*             ' ' 'ZTISCSIT-FWBAS(01)'  '0'.
      l_icssq = 1.
    ELSE.
      PERFORM bdc_dynpro_build USING :
             'X' 'ZTIR9000'          '2000',
             ' ' 'ZTISCSIT-EXPCD(02)'  gs_disp-expcd,
             ' ' 'ZTISCSIT-IIPNO(02)'  gs_disp-iipno,
             ' ' 'ZTISCSIT-AMSEQ(02)'  gs_disp-amdsq,
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
*****************************************
    LOOP AT it_ztitig06 WHERE NOT mwskz IN s_mwskz.
      DELETE it_ztitig06.
    ENDLOOP.
    DESCRIBE TABLE it_ztitig06 LINES g_line.
    IF g_line EQ 0.
      MESSAGE e874 WITH '적하부보'.
    ENDIF.
*****************************************
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
  lfa1-name1    = vf_kred-name1.

  IF ztitcsk-zterm IS INITIAL.
    ztitcsk-zterm = vf_kred-zterm.
  ENDIF.

  IF sy-dynnr EQ '0100'.
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
        e_zschf = ztitcsk-zlspr
        e_zfbdt = ztitcsk-zfbdt.
  ELSE.
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
        e_zbd3t = ztitcsk-zbd3t.
*      e_zlsch = ztitcsk-zlsch
*      e_zschf = ZTITCSK-zlspr
*      e_zfbdt = ztitcsk-zfbdt.
  ENDIF.

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

  LOOP AT it_disp INTO gs_disp.
    l_index = sy-tabix.
*> 전표가 입력되었을 경우 입력 불가능
    IF gs_disp-icsno IS INITIAL.
      p_mode = 'W'.
    ELSE.
      p_mode = 'O'.
    ENDIF.

    REFRESH lt_celltab.

    PERFORM p3810_fill_celltab USING    p_mode
                               CHANGING lt_celltab.

    CLEAR gs_disp-celltab.
    INSERT LINES OF lt_celltab  INTO TABLE gs_disp-celltab.
    MODIFY it_disp FROM gs_disp INDEX l_index.
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

    IF gs_fieldcat_g-fieldname = 'WRBTR' OR          " 금액.
       gs_fieldcat_g-fieldname = 'BOX'.
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
*&      Form  set_selected_row
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_selected_row  USING  p_mark.
  CLEAR: g_count.

  LOOP AT it_disp INTO gs_disp.
    gs_disp-box = p_mark.
    MODIFY it_disp FROM gs_disp.

    IF p_mark = 'X'.
      g_count = g_count + 1.
    ENDIF.
  ENDLOOP.

  IF g_count <> 0.
    MESSAGE s883 WITH g_count.
  ENDIF.

  CALL METHOD g_grid->refresh_table_display.

ENDFORM.                    " set_selected_row
*&---------------------------------------------------------------------*
*&      Form  refresh_confirm
*&---------------------------------------------------------------------*
FORM refresh_confirm  USING    p_ans.
  DATA: l_cancel_display.

  DATA: BEGIN OF pop,
        titel      LIKE spop-titel,
        diagnose1  LIKE spop-diagnose1,
        diagnose2  LIKE spop-diagnose2,
        diagnose3  LIKE spop-diagnose3,
        textline1  LIKE spop-textline1,
        textline2  LIKE spop-textline2,
        textline3  LIKE spop-textline3,
        option1    LIKE spop-varoption1,
        option2    LIKE spop-varoption2,
        default,             "defaultoption fuer Confirm_step
        answer,
  END OF pop.

  CLEAR : pop, l_cancel_display.

  MOVE: '입력된 데이타가 손실됩니다.'     TO pop-diagnose1,
        '진행하시겠습니까?'               TO pop-textline1,
        '확인'                            TO pop-titel.

  CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
         EXPORTING
              diagnosetext1 = pop-diagnose1
*             diagnosetext2 = pop-diagnose2
*             DIAGNOSETEXT3 = ' '
              textline1      = pop-textline1
              textline2      = pop-textline2
              titel          = pop-titel
*             START_COLUMN   = 25
*             START_ROW      = 6
              cancel_display = l_cancel_display
         IMPORTING
              answer        = pop-answer
         EXCEPTIONS
              OTHERS        = 1.

  p_ans = pop-answer.
ENDFORM.                    " refresh_confirm
*&---------------------------------------------------------------------*
*&      Form  p9000_refresh_display
*&---------------------------------------------------------------------*
FORM p9000_refresh_display .
  CALL METHOD g_grid->refresh_table_display.
ENDFORM.                    " p9000_refresh_display
*&---------------------------------------------------------------------*
*&      Form  build_posting_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_posting_data .

*> 데이타 체크.
  LOOP AT it_disp INTO gs_disp WHERE box = 'X'.

    g_tabix  =  sy-tabix.

    CLEAR: gs_disp-errmd.

*> 전기여부체크.
    IF NOT gs_disp-icsno IS INITIAL.
      gs_disp-errmd = 'X'.
      IF NOT gs_disp-belnr IS INITIAL.
        MESSAGE s160 WITH gs_disp-reqno gs_disp-amdsq '전기'.
      ELSE.
        MESSAGE s160 WITH gs_disp-reqno gs_disp-amdsq '생성'.
      ENDIF.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 전표유형.
    IF gs_disp-blart IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s160 WITH gs_disp-reqno gs_disp-amdsq '전표유형'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 공급업체.
    IF gs_disp-lifnr IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s160 WITH gs_disp-reqno gs_disp-amdsq '공급업체'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 사업장.
    IF gs_disp-bupla IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s160 WITH gs_disp-reqno gs_disp-amdsq '사업장'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 세금코드
    IF gs_disp-mwskz IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s160 WITH gs_disp-reqno gs_disp-amdsq '세금코드'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 전기유형.
    IF gs_disp-cstyp IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s160 WITH gs_disp-reqno gs_disp-amdsq '전기 유형'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 트랜잭션유형.
    IF gs_disp-vorgang IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s160 WITH gs_disp-reqno gs_disp-amdsq '트랜잭션유형'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 금액.
    IF gs_disp-wrbtr IS INITIAL AND
       gs_disp-wmwst IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s160 WITH gs_disp-reqno gs_disp-amdsq  '비용'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 과세표준액.
    IF NOT gs_disp-wmwst IS INITIAL AND
           gs_disp-fwbas IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s160 WITH gs_disp-reqno gs_disp-amdsq '과세표준액'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 통화금액.
    IF gs_disp-waers IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s160 WITH gs_disp-reqno gs_disp-amdsq '통화'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

    IF gs_disp-errmd IS INITIAL.
      ADD 1 TO ztisscrcom-itcnt.
      CLEAR: it_collect.
*> 공급업체+세금코드+사업장별 Collect.
      MOVE: gs_disp-lifnr   TO  it_collect-lifnr.
      MOVE: gs_disp-blart   TO  it_collect-blart.
      MOVE: gs_disp-mwskz   TO  it_collect-mwskz.
      MOVE: gs_disp-bupla   TO  it_collect-bupla.
      MOVE: gs_disp-wrbtr   TO  it_collect-wrbtr.
      MOVE: gs_disp-dmbtr   TO  it_collect-dmbtr.
      MOVE: gs_disp-wmwst   TO  it_collect-wmwst.
      MOVE: gs_disp-fwbas   TO  it_collect-fwbas.
      MOVE: gs_disp-hwaer   TO  it_collect-hwaer.
      MOVE: gs_disp-waers   TO  it_collect-waers.
      MOVE: gs_disp-cstyp   TO  it_collect-cstyp.
      MOVE: gs_disp-vorgang TO  it_collect-vorgang.
*      MOVE: gs_disp-payda   TO  it_collect-zfbdt.
      COLLECT it_collect.
    ENDIF.
    MODIFY it_disp FROM gs_disp INDEX g_tabix.
  ENDLOOP.
ENDFORM.                    " build_posting_data
*&---------------------------------------------------------------------*
*&      Form  fill_posting_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fill_posting_data .

  DATA: l_icsno(5)     TYPE n,
        l_icssq        TYPE ztiicssq.

  CLEAR: l_icsno.
************************************************************************
*> 일괄전기일 경우...
************************************************************************
  IF ztisscrcom-monsc EQ 'S'.
    LOOP AT it_collect.
      ADD 1 TO l_icsno.
*> Header data Move
      PERFORM set_header_data_by_collect USING l_icsno  'I'.

*---> Item data Move
      CLEAR: l_icssq.
      LOOP AT it_disp INTO gs_disp
                       WHERE lifnr   EQ it_collect-lifnr
                         AND bupla   EQ it_collect-bupla
                         AND mwskz   EQ it_collect-mwskz
                         AND waers   EQ it_collect-waers
                         AND hwaer   EQ it_collect-hwaer
                         AND blart   EQ it_collect-blart
                         AND cstyp   EQ it_collect-cstyp
                         AND vorgang EQ it_collect-vorgang
                         AND zfbdt   EQ it_collect-zfbdt
                         AND box     EQ 'X'
                         AND errmd   EQ space.

        CLEAR: it_ztitcsp.
        ADD 1 TO l_icssq.

        PERFORM set_item_data   USING l_icsno  l_icssq  'I'.
      ENDLOOP.
    ENDLOOP.
  ELSE.
************************************************************************
*> 개별전기일 경우...
************************************************************************
    LOOP AT it_disp INTO gs_disp WHERE box   EQ 'X'
                                   AND errmd EQ space.
      ADD 1 TO l_icsno.
*> Header data Move
      PERFORM set_header_data_by_individual USING l_icsno  'I'.
*---> Item data Move
      CLEAR: l_icssq.
      ADD 1 TO l_icssq.
      PERFORM set_item_data   USING l_icsno  l_icssq  'I'.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " fill_posting_data
*&---------------------------------------------------------------------*
*&      Form  p3800_set_title_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM p3800_set_title_text .

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

ENDFORM.                    " p3800_set_title_text
