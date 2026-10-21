************************************************************************
* Title         :  ZTIR9110                                            *
*                                                                      *
* Description   : [Report] 수입요청 관련비용 관리                      *
*                                                                      *
* Creation Date : 2004/02/13                                           *
*                                                                      *
* Author        : Seog Bong, Kang                                      *
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
REPORT  ztir9110       MESSAGE-ID zmti00
                       NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis,   "> Globale Type(ALV)
            kkblo.  "> Generic list types

TYPES:  BEGIN OF ty_list.
        INCLUDE STRUCTURE ztislccs.
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
TABLES: ztitcsk,      ">수입제비용 헤더.
        ztisscrcom,   ">수출입시스템 Screen용 Structure(공용)
        ztislccs,     ">수입의뢰 관련비용 관리 ALV용.
       *ztislccs,     ">수입의뢰 관련비용 관리 ALV용.
        ekpo,
        icon.         ">아이콘테이블.

TABLES: t001,         ">회사코드.
        t005,         ">국가코드.
        lfa1,         ">구매처마스터 (일반섹션).
        ztitig00,     ">[TraSys] 회사별 프로세스 정의.
        ztitig07,     ">[TraSys]  제비용 일괄전기 Default Value관리.
        ztitrqk,      ">수입의뢰(개설) 공통 헤더 테이블.
        ztitrqs,      ">수입의뢰(개설) 공통 상태 테이블.
        ztitcsp,      ">수입비용문서 비용항목 table.
        ztivcs00,     ">수입비용 Views.
        ztitig06,     ">수입비용코드.
        vf_kred.      ">LFA1과 LFB1에 대한 데이타베이스 뷰.

TABLES: bapi1093_0,   ">BAPI 환율테이블.
        bapicurx,     ">BAPI에 대한 외화환산모듈구조.
        bapiret1.     ">리턴매개변수.

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
DATA: it_disp  TYPE STANDARD TABLE OF ty_list,
      it_temp  TYPE STANDARD TABLE OF ty_list,
      gs_disp  TYPE ty_list.

DATA: BEGIN OF it_vendor  OCCURS 2,
      lifnr    TYPE lifnr,
      END   OF it_vendor.

*> 거래상대방(은행)
DATA: BEGIN OF it_ztstig3  OCCURS 2.
        INCLUDE STRUCTURE ztstig3.
DATA: END   OF it_ztstig3.

*> 비용코드.
DATA: BEGIN OF it_ztitig06  OCCURS 2.
        INCLUDE STRUCTURE ztisig06.
DATA: END   OF it_ztitig06.

DATA:    BEGIN OF excl OCCURS 25,
           funktion(10),
         END OF excl.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
DATA sender_chg TYPE REF TO cl_gui_alv_grid.

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

*> ZTIR9110 [Report] 수입요청 관련비용 관리.
INCLUDE zti_reuse_forms_for_fi_posting.

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK dbsel WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_bukrs  FOR ztitrqk-bukrs                   "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk,
  s_ebeln  FOR ztitrqs-ebeln,                  "구매조직.
  s_ekorg  FOR ztitrqk-ekorg,                  "구매조직.
  s_ekgrp  FOR ztitrqk-ekgrp,                  "구매그룹.
  s_reqno  FOR ztitrqk-reqno                   "수입의뢰 관리번호.
                    MEMORY ID ztireqno,
  s_amdsq  FOR ztitrqs-amdsq                   "Amend 차수.
                    MEMORY ID ztiamdsq,
  s_reqty  FOR ztitrqk-reqty,                  "수입의뢰 종류.
  s_bupla  FOR ztitrqs-bupla,                  "사업장.
  s_mwskz  FOR ztitcsk-mwskz,                  "세금코드.
  s_knttp  FOR ekpo-knttp,
  s_ilcty  FOR ztitrqk-ilcty,                  "신용장 종류.
  s_lifnr  FOR ztitrqk-lifnr,                  "공급업체 계정번호.
  s_lifre  FOR ztitrqk-lifre,                  "다른 송장발행처.
  s_offer  FOR ztitrqk-offer,                  "오퍼상(Offer).
  s_opnbk  FOR ztitrqk-opnbk MODIF ID sed,     "개설은행.
  s_zterm  FOR ztitrqs-zterm,                  "지급조건키.
  s_waers  FOR ztitrqs-waers,                  "개설통화.
  s_inco1  FOR ztitrqs-inco1,                  "인도조건 (파트 1).
  s_exdat  FOR ztitrqs-exdat,                  "유효기일.
  s_lsdat  FOR ztitrqs-lsdat,                  "최종선적일자.
  s_fland  FOR ztitrqs-fland,                  "선적국가.
  s_fport  FOR ztitrqs-fport,                  "선적항.
  s_opnno  FOR ztitrqs-opnno MODIF ID opn,     "수입개설번호
  s_opndt  FOR ztitrqs-opndt MODIF ID opn,     "개설일자.
  s_cnam   FOR ztitrqs-cnam,                   "작성인.
  s_cdat   FOR ztitrqs-cdat,                   "생성일.
  s_unam   FOR ztitrqs-unam,                   "최종변경인.
  s_udat   FOR ztitrqs-udat.                   "변경일.
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
  PERFORM p1000_alv_fields_initial.
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

  SET TITLEBAR 'T1000'.

  GET PARAMETER ID 'BUK' FIELD s_bukrs-low.
  s_bukrs-sign = 'I'.
  s_bukrs-option = 'EQ'.
  IF NOT s_bukrs-low IS INITIAL.
    APPEND s_bukrs.
  ENDIF.

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
      i_structure_name       = 'ZTISLCCS'
      i_client_never_display = 'X'
    CHANGING
      ct_fieldcat            = it_fieldcat_g[].

  LOOP AT it_fieldcat_g INTO gs_fieldcat_g.
    CLEAR: gs_fieldcat_g-key.

    CASE gs_fieldcat_g-fieldname.
      WHEN 'BOX'.
        gs_fieldcat_g-key       = 'X'.
        gs_fieldcat_g-coltext   = '선택'.
        gs_fieldcat_g-col_opt   = 'X'.
        gs_fieldcat_g-checkbox  = 'X'.
        gs_fieldcat_g-col_pos   = 1.
        gs_fieldcat_g-edit      = 'X'.
      WHEN 'ICON'.
        gs_fieldcat_g-key       = 'X'.
        gs_fieldcat_g-coltext   = '전기'.
        gs_fieldcat_g-col_opt   = 'X'.
        gs_fieldcat_g-col_pos   = 2.
      WHEN 'LIFNR'.
        gs_fieldcat_g-key       = 'X'.
        gs_fieldcat_g-col_opt   = 'X'.
        gs_fieldcat_g-col_pos   = 3.
      WHEN 'NAME1'.
        gs_fieldcat_g-key       = 'X'.
        gs_fieldcat_g-coltext   = '거래은행'.
        gs_fieldcat_g-col_opt   = 'X'.
        gs_fieldcat_g-col_pos   = 4.
      WHEN 'EXPTX'.
        gs_fieldcat_g-key       = 'X'.
        gs_fieldcat_g-col_opt   = 'X'.
        gs_fieldcat_g-col_pos   = 5.
      WHEN 'OPNNO'.
        gs_fieldcat_g-hotspot   = 'X'.
        gs_fieldcat_g-col_opt   = 'X'.
        gs_fieldcat_g-col_pos   = 6.
*      WHEN 'PSPNR'.
*        gs_fieldcat_g-hotspot   = 'X'.
*        gs_fieldcat_g-just      = 'L'.
      WHEN 'REQTX'.
        gs_fieldcat_g-coltext   = '문서유형'.
        gs_fieldcat_g-col_pos   = 7.
      WHEN 'EBELN'.
        gs_fieldcat_g-col_pos   = 8.
      WHEN 'WRBTR'.
        gs_fieldcat_g-coltext   = '공급가액'.
        gs_fieldcat_g-checktable = '!'.
        gs_fieldcat_g-do_sum     = 'X'.
        gs_fieldcat_g-edit       = 'X'.
        gs_fieldcat_g-col_pos   = 9.

      WHEN 'HWAER'.
        gs_fieldcat_g-checktable = '!'.
        gs_fieldcat_g-do_sum     = 'X'.
        gs_fieldcat_g-edit       = 'X'.
        gs_fieldcat_g-col_pos   = 10.
      WHEN 'MWSKZ'.
        gs_fieldcat_g-col_opt   = 'X'.
        gs_fieldcat_g-col_pos   = 11.
      WHEN 'BLART'.
        gs_fieldcat_g-coltext   = '전표유형'.
        gs_fieldcat_g-col_opt   = 'X'.
        gs_fieldcat_g-col_pos   = 12.
      WHEN 'ICSNO'  OR 'BELNR'.
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
    FROM ztivrq04
   WHERE bukrs  IN  s_bukrs        "회사코드.
     AND ebeln  IN  s_ebeln        "구매오더.
     AND ekorg  IN  s_ekorg        "구매조직.
     AND ekgrp  IN  s_ekgrp        "구매그룹.
     AND bupla  IN  s_bupla        "사업장.
     AND reqno  IN  s_reqno        "수입의뢰 관리번호.
     AND amdsq  IN  s_amdsq        "Amend 차수.
     AND reqty  IN  s_reqty        "수입의뢰 종류.
     AND ilcty  IN  s_ilcty        "신용장 종류.
     AND lifnr  IN  s_lifnr        "공급업체 계정번호.
     AND lifre  IN  s_lifre        "다른 송장발행처.
     AND offer  IN  s_offer        "오퍼상(Offer).
     AND opnbk  IN  s_opnbk        "개설은행.
     AND zterm  IN  s_zterm        "지급조건키.
     AND waers  IN  s_waers        "개설통화.
     AND inco1  IN  s_inco1        "인도조건 (파트 1).
     AND exdat  IN  s_exdat        "유효기일.
     AND lsdat  IN  s_lsdat        "최종선적일자.
     AND fland  IN  s_fland        "선적국가.
     AND fport  IN  s_fport        "선적항.
     AND opnno  IN  s_opnno        "수입개설번호
     AND opndt  IN  s_opndt        "개설일자.
     AND cnam   IN  s_cnam         "작성인.
     AND cdat   IN  s_cdat         "생성일.
     AND unam   IN  s_unam         "최종변경인.
     AND udat   IN  s_udat         "변경일
     AND docst  EQ  'O'.

  IF sy-subrc NE 0.
    MESSAGE s902.   EXIT.
  ENDIF.
*> 거래상대방 테이블.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_ztstig3
    FROM ztstig3
     FOR ALL ENTRIES IN it_disp
   WHERE parti  EQ  'B'
     AND epart  EQ  it_disp-opnbk.

  REFRESH: it_disp.
  LOOP AT it_temp INTO gs_disp.
    gs_disp-waers1 = gs_disp-waers.
*> 거래상대방 .
    READ TABLE it_ztstig3 WITH KEY epart  = gs_disp-opnbk.
    IF sy-subrc EQ 0.
      MOVE: it_ztstig3-lifnr  TO  gs_disp-lifnr,
            it_ztstig3-namet  TO  gs_disp-name1.
    ENDIF.

*> 문서 종류.
    CASE gs_disp-reqty.
      WHEN 'LC'.
        gs_disp-reqtx = '수입신용장'.
      WHEN 'TT'.
        gs_disp-reqtx = '전신환송금'.
      WHEN 'LO'.
        gs_disp-reqtx = '내국신용장'.
      WHEN 'PU'.
        gs_disp-reqtx = '구매확인서'.
      WHEN 'DA'.
        gs_disp-reqtx = 'D/A'.
      WHEN 'DP'.
        gs_disp-reqtx = 'D/P'.
    ENDCASE.

*> 대표 PO
    SELECT ebeln
      INTO gs_disp-ebeln
      FROM ztitrqp UP TO 1 ROWS
     WHERE reqno  EQ  gs_disp-reqno
       AND amdsq  EQ  gs_disp-amdsq.
    ENDSELECT.

*>>>>>>> 계정지정범주 로직 추가....
    SELECT *
      FROM ekpo UP TO 1 ROWS
     WHERE ebeln EQ gs_disp-ebeln
       AND knttp IN s_knttp.
      CONTINUE.
    ENDSELECT.

*> 선택한 비용코드를 추가함.
    LOOP AT it_ztitig06 WHERE box = 'X'.
*> 문서종류 체크.
      IF NOT it_ztitig06-reqty IS INITIAL.
        IF it_ztitig06-reqty NE gs_disp-reqty.
          CONTINUE.
        ENDIF.
      ENDIF.
*> 통화단위.
      MOVE t001-waers  TO  gs_disp-hwaer.

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

      CLEAR: ztivcs00.
      SELECT *
        FROM ztivcs00 UP TO 1 ROWS
       WHERE bukrs   EQ  t001-bukrs
         AND expgr   EQ  it_ztitig06-expgr
         AND expcd   EQ  it_ztitig06-expcd
         AND refno   EQ  gs_disp-reqno
         AND amdsq   EQ  gs_disp-amdsq.
      ENDSELECT.
      IF sy-subrc EQ 0.
        IF p_step1 EQ 'X'.
          CONTINUE.
        ENDIF.
*> 비용문서 MOVE
        MOVE-CORRESPONDING ztivcs00 TO gs_disp.
        MOVE: ztivcs00-wrbtr        TO gs_disp-wrbtr,
              ztivcs00-waers        TO gs_disp-hwaer.
      ELSE.
        IF p_step2 EQ 'X'.
          CONTINUE.
        ENDIF.
*> At sight일 경우도 Term charge가 발생함.
*        IF GS_DISP-cstcl EQ 'T'.
*          IF GS_DISP-ilcty EQ 'U'.
*            MOVE GS_DISP-tmchg TO GS_DISP-wrbtr.
*          ELSE.
*            CONTINUE.
*          ENDIF.
*        ENDIF.
      ENDIF.

*> 기존처리된 비용여부 판단.
      CASE gs_disp-livst.
        WHEN 'P'.
          gs_disp-icon = icon_green_light.
        WHEN 'N'.
          gs_disp-icon = icon_yellow_light.
        WHEN OTHERS.
          gs_disp-icon = icon_red_light.
      ENDCASE.

      gs_disp-refno = gs_disp-reqno.
      gs_disp-docnm = gs_disp-opnno.

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
  SET TITLEBAR  'T1000'.

  PERFORM create_and_init_controls_0100.

ENDMODULE.                 " pbo_scr0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  create_and_init_controls_0100
*&---------------------------------------------------------------------*
FORM create_and_init_controls_0100 .

  IF g_grid IS INITIAL.
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

* create the docking container
    CREATE OBJECT g_docking
                  EXPORTING repid     = sy-repid
                            dynnr     = sy-dynnr
                            side      = g_docking->dock_at_left
                            extension = 9999.

*   Create an Instance of ALV Control
    CREATE OBJECT g_grid
          EXPORTING i_parent      = g_docking.

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
* append an icon to refresh
  CLEAR ls_toolbar.
  MOVE 0                    TO ls_toolbar-butn_type.
  MOVE 'REFRESH'            TO ls_toolbar-function.
  MOVE icon_refresh         TO ls_toolbar-icon.
  MOVE 'REFRESH'(120)    TO ls_toolbar-quickinfo.
  MOVE space                TO ls_toolbar-disabled.
  APPEND ls_toolbar         TO r_object->mt_toolbar.

* append an icon to select all
  CLEAR ls_toolbar.
  MOVE 0                    TO ls_toolbar-butn_type.
  MOVE 'SELECT'             TO ls_toolbar-function.
  MOVE icon_select_all      TO ls_toolbar-icon.
  MOVE '모두 선택'(121)    TO ls_toolbar-quickinfo.
  MOVE space                TO ls_toolbar-disabled.
  APPEND ls_toolbar         TO r_object->mt_toolbar.

* append an icon to deselect all
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

* append an icon to posting 비용문서.
  CLEAR ls_toolbar.
  MOVE 0                    TO ls_toolbar-butn_type.
  MOVE 'ZTIT901'            TO ls_toolbar-function.
  MOVE icon_financing       TO ls_toolbar-icon.
  MOVE ' 비용 전기'(113)   TO ls_toolbar-quickinfo.
  MOVE ' 비용 전기'(113)    TO ls_toolbar-text.
  MOVE space                TO ls_toolbar-disabled.
  APPEND ls_toolbar         TO r_object->mt_toolbar.

* append an icon to Term Charge 계산.
  READ TABLE it_ztitig06 WITH KEY cstcl = 'T'.
  IF sy-subrc EQ 0.
    CLEAR ls_toolbar.
    MOVE 0                    TO ls_toolbar-butn_type.
    MOVE 'ZTIT901S'           TO ls_toolbar-function.
    MOVE icon_simulate        TO ls_toolbar-icon.
    MOVE 'Term Charge 시뮬레이션'(115)    TO ls_toolbar-quickinfo.
    MOVE 'Term Charge'(114)   TO ls_toolbar-text.
    MOVE space                TO ls_toolbar-disabled.
    APPEND ls_toolbar         TO r_object->mt_toolbar.
  ENDIF.

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

  DATA : l_wrbtr      TYPE wrbtr,
         l_wmwst      TYPE wmwst,
         l_fwbas      TYPE fwbas,
         l_mwskz      TYPE hwaer,
         l_box        TYPE c,
         l_hwaer      TYPE hwaer.

  LOOP AT er_data_changed->mt_good_cells INTO ls_mod_cells.
    CASE ls_mod_cells-fieldname.
      WHEN 'WRBTR'.     ">금액.
* 금액이 있는경우 Check Box Marking
        READ TABLE it_disp INTO gs_disp
                     INDEX ls_mod_cells-row_id .

        IF sy-subrc NE 0.
          CONTINUE.
        ENDIF.
*> 금액.
        CALL METHOD er_data_changed->get_cell_value
          EXPORTING
            i_row_id    = ls_mod_cells-row_id
            i_fieldname = 'WRBTR'
          IMPORTING
            e_value     = l_wrbtr.
*> Checkbox Update
        IF l_wrbtr = 0.
          CLEAR l_box.
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
*  EXIT.
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
  IF sy-subrc EQ 0.

    CASE p_column.
      WHEN 'ICSNO' OR 'ICSSQ'.
        PERFORM display_cs_document(ztir0000)
                                           USING gs_disp-icsno
                                                 gs_disp-bukrs.
      WHEN 'BELNR'.
        PERFORM display_liv_document(ztir9000)
                                             USING gs_disp-belnr
                                                   gs_disp-gjahr
                                                   gs_disp-bukrs.
      WHEN OTHERS.
        PERFORM display_import_document(ztir0000)
                                           USING gs_disp-reqno
                                                 gs_disp-amdsq
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

  READ TABLE it_disp INTO gs_disp INDEX e_row_id-index.
  IF sy-subrc NE 0.
    MESSAGE s903.   EXIT.
  ENDIF.

  CASE e_column_id-fieldname.
    WHEN 'REQNO' OR 'OPNNO'.
      PERFORM  display_import_document(ztir0000)
                                      USING gs_disp-reqno
                                            gs_disp-amdsq
                                            space.
    WHEN 'PSPNR'.
      PERFORM  display_project_master(ztir0000)
                                      USING gs_disp-pspnr.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    "_hotspot_click
*&---------------------------------------------------------------------*
*&      Form  handle_user_command_grid
*&---------------------------------------------------------------------*
FORM handle_user_command_grid USING r_ucomm.

  CALL METHOD cl_gui_cfw=>set_new_ok_code
    EXPORTING
      new_code = r_ucomm.

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

*  DATA: l_valid TYPE c,
*        lt_row_no TYPE lvc_t_roid WITH HEADER LINE.
*  DATA: l_subrc   LIKE sy-subrc,
*        l_text_amout(20),
*        l_mark    TYPE c.
*
*  REFRESH: bdcdata, it_msg.
*  CLEAR: session.
*  ctu_params-dismode  = 'E'. ">처리모드
*  ctu_params-updmode  = 'S'. ">갱신모드
*  ctu_params-cattmode = ' '. ">CATT 모드...
*  ctu_params-defsize  = ' '. ">기본화면 크기
*  ctu_params-racommit = 'X'.
*  ctu_params-nobinpt  = ' ' .
*  ctu_params-nobiend  = ' '.
*
*  CLEAR g_count.
*
*  IF r_ucomm EQ 'ZTIT105' OR
*     r_ucomm EQ 'ZTIT901' OR
*     r_ucomm EQ 'ZTIT901S'.
*    PERFORM  get_selected_row  TABLES lt_row_no.
*  ELSEIF r_ucomm EQ 'SELECT'.
*    l_mark = ' '.
*    PERFORM  set_selected_row USING l_mark.
*    EXIT.
*  ELSEIF r_ucomm EQ 'DESELECT'.
*    l_mark = 'X'.
*    PERFORM  set_selected_row USING l_mark.
*    EXIT.
*  ENDIF.
*
*  CHECK g_count GT 0.
*
*  CASE r_ucomm.
**>---------------------------------------------------------------------
**> Term Charge 계산.
**>---------------------------------------------------------------------
*    WHEN 'ZTIT901S'.
*      CASE g_count.
*        WHEN 0.
*          MESSAGE s906.     EXIT.
*        WHEN 1.
*          READ TABLE IT_DISP INTO GS_DISP WITH KEY box = 'X'.
*          g_tabix = sy-tabix.
*          IF sy-subrc EQ 0.
*            IF GS_DISP-cstcl EQ 'T'.
*              MOVE-CORRESPONDING GS_DISP       TO ztislccs.
*              MOVE               GS_DISP-wrbtr TO ztislccs-tmchg.
*               *ztislccs = ztislccs.
**> 확인 대화상자 Call
*              CLEAR: ok_code.
*              CALL SCREEN '0300' STARTING AT 1 1.
*              IF ok_code EQ 'BU'.
*                PERFORM p3000_field_category_build.
*                PERFORM p3800_field_attribute_change.
*                PERFORM p9000_refresh_display.
*                EXIT.
*              ENDIF.
*            ELSE.
*              MESSAGE s024. EXIT.
*            ENDIF.
*          ENDIF.
*        WHEN OTHERS.
*          MESSAGE s929.     EXIT.
*      ENDCASE.
**>---------------------------------------------------------------------
**> 비용전기.
**>---------------------------------------------------------------------
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
*      LOOP AT IT_DISP INTO GS_DISP WHERE box = 'X'.
*        CLEAR: GS_DISP-errmd.
*
*        MOVE: GS_DISP-lifnr  TO  it_vendor-lifnr.
*        COLLECT it_vendor.
*
*        IF NOT GS_DISP-icsno IS INITIAL.
*          GS_DISP-errmd = 'X'.
*          IF NOT GS_DISP-belnr IS INITIAL.
*            MESSAGE s132 WITH GS_DISP-reqno GS_DISP-amdsq '전기'.
*          ELSE.
*            MESSAGE s132 WITH GS_DISP-reqno GS_DISP-amdsq '생성'.
*          ENDIF.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF GS_DISP-lifnr IS INITIAL.
*          GS_DISP-errmd = 'X'.
*          MESSAGE s129 WITH GS_DISP-reqno GS_DISP-amdsq '은행코드'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF GS_DISP-hwaer  IS INITIAL AND
*           GS_DISP-errmd  IS INITIAL.
*          GS_DISP-errmd = 'X'.
*          MESSAGE s129 WITH GS_DISP-reqno GS_DISP-amdsq '통화단위'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF GS_DISP-wrbtr  IS INITIAL AND
*           GS_DISP-errmd  IS INITIAL.
*          GS_DISP-errmd = 'X'.
*          MESSAGE s129 WITH GS_DISP-reqno GS_DISP-amdsq '비용금액'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
**
*        ADD GS_DISP-wrbtr TO g_wrbtr.
*        ADD 0             TO g_wmwst.
*        MODIFY IT_DISP FROM GS_DISP.
*      ENDLOOP.
*
**> 합계전표일 경우 Vendor 등을 체크함.
*      IF ztisscrcom-monsc EQ 'S'.
*        DESCRIBE TABLE it_vendor LINES g_line.
*        CASE g_line.
*          WHEN 0.
*            MESSAGE s022.
*            PERFORM set_return_message_fill USING 'E'.
*          WHEN 1.
*          WHEN OTHERS.
*            MESSAGE s023.
*            PERFORM set_return_message_fill USING 'E'.
*        ENDCASE.
**> Error Message Display.
*        PERFORM display_error_message.
*        DESCRIBE TABLE it_msg LINES g_line.
*        CHECK g_line EQ 0.
*      ENDIF.
*
**> 전기확인용 대화화면 Call
*      CLEAR: ok_code.
**> 전기용 HEADER DATA Fill
*      PERFORM   fill_default_header_data.
**> 확인 대화상자 Call
*      CLEAR: ok_code.
*      CALL SCREEN '0200' STARTING AT 1 8.
*      IF ok_code EQ 'ABBR'.
*        MESSAGE s900.
*        EXIT.
*      ELSEIF ok_code EQ 'SIMU'.
*        ctu_params-dismode  = 'E'. ">처리모드
*      ENDIF.
*      CLEAR: g_success, g_error.
*
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
*  PERFORM p9000_refresh_display.

ENDFORM.                    "handle_user_command_grid
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
                cl_gui_alv_grid=>mc_fc_loc_paste_new_row, " 겹쳐쓰기.
                cl_gui_alv_grid=>mc_fc_refresh.           " REFRESH

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
  gs_layout_g-no_rowmark = 'A'. "(or 'X')

* Selection modes for SEL_MODE
* 'A' : Column and row selection
* 'B' : Simple selection, list box
* 'C' : Multiple selection, list box
* 'D' : Cell selection
*  gs_layout_g-sel_mode = 'C'.
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

  CALL METHOD g_grid->check_changed_data
    IMPORTING
      e_valid = g_valid.

  CLEAR g_count.

  IF sy-ucomm EQ 'ZTIT105' OR
     sy-ucomm EQ 'ZTIT901' OR
     sy-ucomm EQ 'ZTIT901S'.
    PERFORM  get_selected_row  TABLES gt_row_no.
  ENDIF.

  CASE sy-ucomm.
    WHEN 'EXIT' OR 'CANC' OR 'BACK'.
      IF g_grid IS INITIAL.
        CALL METHOD g_grid->free.
      ENDIF.

      SET SCREEN 0.
      LEAVE SCREEN.
*>---------------------------------------------------------------------
*> Term Charge 계산.
*>---------------------------------------------------------------------
    WHEN 'ZTIT901S'.
      CASE g_count.
        WHEN 0.
          MESSAGE s906.     EXIT.
        WHEN 1.
          READ TABLE it_disp INTO gs_disp WITH KEY box = 'X'.
          g_tabix = sy-tabix.
          IF sy-subrc EQ 0.
            IF gs_disp-cstcl EQ 'T'.
              MOVE-CORRESPONDING gs_disp       TO ztislccs.
              MOVE               gs_disp-wrbtr TO ztislccs-tmchg.
               *ztislccs = ztislccs.
*> 확인 대화상자 Call
              CLEAR: ok_code.
              CALL SCREEN '0300' STARTING AT 1 1.
              IF ok_code EQ 'BU'.
                PERFORM p3000_field_category_build.
                PERFORM p3800_field_attribute_change.
                PERFORM p9000_refresh_display.
                EXIT.
              ENDIF.
            ELSE.
              MESSAGE s024. EXIT.
            ENDIF.
          ENDIF.
        WHEN OTHERS.
          MESSAGE s929.     EXIT.
      ENDCASE.

*>---------------------------------------------------------------------
*> 비용전기.
*>---------------------------------------------------------------------
    WHEN 'ZTIT901'.
      CHECK g_count GT 0.
*> Clearing
      PERFORM  set_posting_data_initial.

*> 전기유형 선택.
      PERFORM  get_posting_type   USING g_count
                                        ztisscrcom-monsc  g_answer.
      CHECK g_answer EQ 'Y'.

*> 전기용 데이타 Collect.
      PERFORM  build_posting_data.
*> Error Message Display.
      PERFORM display_error_message.
      CHECK g_line EQ 0.

*> 전기확인용 대화화면 Call
      CLEAR: ok_code.
*> 전기용 HEADER DATA Fill
      PERFORM   fill_posting_data.

*> 비용전기용 공통 함수.
      PERFORM   build_fi_document USING 'L'
                                        ztisscrcom-monsc.

*> 검색조건에 해당하는 데이타를 Select.
*      BREAK-POINT.

      CHECK g_success GT 0.
*> 검색조건에 해당하는 데이타를 Select.
      PERFORM p2000_data_selections.
      PERFORM p3000_field_category_build.
      PERFORM p3800_field_attribute_change.
      PERFORM p9000_refresh_display.

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
*      LOOP AT IT_DISP INTO GS_DISP WHERE box = 'X'.
*        CLEAR: GS_DISP-errmd.
*
*        MOVE: GS_DISP-lifnr  TO  it_vendor-lifnr.
*        COLLECT it_vendor.
*
*        IF NOT GS_DISP-icsno IS INITIAL.
*          GS_DISP-errmd = 'X'.
*          IF NOT GS_DISP-belnr IS INITIAL.
*            MESSAGE s132 WITH GS_DISP-reqno GS_DISP-amdsq '전기'.
*          ELSE.
*            MESSAGE s132 WITH GS_DISP-reqno GS_DISP-amdsq '생성'.
*          ENDIF.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF GS_DISP-lifnr IS INITIAL.
*          GS_DISP-errmd = 'X'.
*          MESSAGE s129 WITH GS_DISP-reqno GS_DISP-amdsq '은행코드'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF GS_DISP-hwaer  IS INITIAL AND
*           GS_DISP-errmd  IS INITIAL.
*          GS_DISP-errmd = 'X'.
*          MESSAGE s129 WITH GS_DISP-reqno GS_DISP-amdsq '통화단위'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF GS_DISP-wrbtr  IS INITIAL AND
*           GS_DISP-errmd  IS INITIAL.
*          GS_DISP-errmd = 'X'.
*          MESSAGE s129 WITH GS_DISP-reqno GS_DISP-amdsq '비용금액'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
**
*        ADD GS_DISP-wrbtr TO g_wrbtr.
*        ADD 0             TO g_wmwst.
*        MODIFY IT_DISP FROM GS_DISP.
*      ENDLOOP.
*
**> 합계전표일 경우 Vendor 등을 체크함.
*      IF ztisscrcom-monsc EQ 'S'.
*        DESCRIBE TABLE it_vendor LINES g_line.
*        CASE g_line.
*          WHEN 0.
*            MESSAGE s022.
*            PERFORM set_return_message_fill USING 'E'.
*          WHEN 1.
*          WHEN OTHERS.
*            MESSAGE s023.
*            PERFORM set_return_message_fill USING 'E'.
*        ENDCASE.
**> Error Message Display.
*        PERFORM display_error_message.
*        DESCRIBE TABLE it_msg LINES g_line.
*        CHECK g_line EQ 0.
*      ENDIF.
*
**> 전기확인용 대화화면 Call
*      CLEAR: ok_code.
**> 전기용 HEADER DATA Fill
*      PERFORM   fill_default_header_data.
**> 확인 대화상자 Call
*      CLEAR: ok_code.
*      CALL SCREEN '0200' STARTING AT 1 8.
*      IF ok_code EQ 'ABBR'.
*        MESSAGE s900.
*        EXIT.
*      ELSEIF ok_code EQ 'SIMU'.
*        ctu_params-dismode  = 'E'. ">처리모드
*      ENDIF.
*      CLEAR: g_success, g_error.
*
*      IF ztisscrcom-monsc EQ 'S'.
*        PERFORM execute_collective_posting.
*      ELSE.
*        PERFORM execute_individual_posting.
*      ENDIF.
**  ENDCASE.
*
**> Error Message Display.
*      PERFORM display_error_message.
**> 검색조건에 해당하는 데이타를 Select.
*      CHECK g_success GT 0.
*      PERFORM p2000_data_selections.
*      PERFORM p3000_field_category_build.
*      PERFORM p3800_field_attribute_change.
*      PERFORM p9000_refresh_display.

  ENDCASE.

ENDMODULE.                 " pai_scr0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  status_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  REFRESH excl.

  IF ztisscrcom-monsc EQ 'I'.
    MOVE 'SIMU' TO excl-funktion.    APPEND excl.
  ENDIF.

  SET PF-STATUS '0300' EXCLUDING excl.

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
*    CLEAR GS_DISP-box.
*    MODIFY IT_DISP FROM GS_DISP TRANSPORTING box WHERE box = 'X'.
*
*    LOOP AT pt_row_no.
*      IF pt_row_no-row_id GT 0.
*        READ TABLE IT_DISP INTO GS_DISP INDEX pt_row_no-row_id.
*        IF sy-subrc EQ 0.
*          ADD 1 TO g_count.
*          IF GS_DISP-box NE 'X'.
*            GS_DISP-box = 'X'.
*          ENDIF.
*          MODIFY IT_DISP FROM GS_DISP INDEX pt_row_no-row_id.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*
*  IF g_count EQ 0.
*    MESSAGE s909.
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
**> 일괄전기 확인메시지 사용시.
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

  IF ztitcsk-zfbdt IS INITIAL.
    ztitcsk-zfbdt = ztitcsk-bldat.
  ENDIF.
**> 사업장.
*  IF ztitcsk-bupla IS INITIAL.
*    PERFORM no_input_check(ztir0000) USING 'ZTITCSK' 'BUPLA' 'E'.
*  ENDIF.
*
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
*      break-point.
*      SELECT SINGLE *
*        FROM ztitig07
*       WHERE bukrs EQ ztitcsk-bukrs
*         AND CSTCT EQ 'L'.
*      IF sy-subrc EQ 0.
*        IF ztitig07-blart NE ztitcsk-blart.
*          MESSAGE w941 WITH ztitcsk-blart ztitig07-blart.
*          ztitcsk-blart = ztitig07-blart.
*        ENDIF.
*      ENDIF.
      IF ztitcsk-iname IS INITIAL.
        PERFORM no_input_check(ztir0000) USING 'ZTITCSK' 'INAME' 'E'.
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

  CASE ok_code.
    WHEN 'ABBR'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'BU' OR 'BUC' OR 'SIMU'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN OTHERS.
  ENDCASE.
  CLEAR: ok_code.

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
*&      Form  FILL_DEFAULT_HEADER_DATA
*&---------------------------------------------------------------------*
FORM fill_default_header_data .

  LOOP AT it_disp INTO gs_disp WHERE box = 'X'.
    EXIT.
  ENDLOOP.

  SELECT SINGLE *
    FROM ztitig07
   WHERE bukrs EQ t001-bukrs
     AND cstct EQ 'B'.

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
        gs_disp-opnno    TO    ztitcsk-xblnr,
        gs_disp-lifnr    TO    ztitcsk-lifnr,
        gs_disp-hwaer    TO    ztitcsk-waers,
        g_wrbtr          TO    ztitcsk-wrbtr,
        g_wmwst          TO    ztitcsk-wmwst.

  IF ztitcsk-bupla IS INITIAL.
    MOVE gs_disp-bupla TO ztitcsk-bupla.
  ENDIF.

  SELECT name_text
    INTO ztitcsk-iname
    FROM adrp UP TO 1 ROWS
   WHERE persnumber EQ ( SELECT persnumber
                           FROM usr21
                          WHERE bname EQ sy-uname ).

  ENDSELECT.
*  READ TABLE it_ZTItig06 WITH KEY BOX = 'X'.
*  IF SY-SUBRC EQ 0.
*    MOVE: it_ZTItig06-BLART TO ZTITCSK-blart,
*          it_ZTItig06-MWSKZ TO ZTITCSK-mwskz.
*  ENDIF.
*
  PERFORM  get_domain_value_text(ztir9000)
                                 USING   'ZTIEXPGR'
                                         'L'
                                 CHANGING ztitcsk-bktxt.

*  ZTITCSK-sgtxt = ZTITCSK-bktxt.

  SELECT SINGLE *
    FROM lfa1
   WHERE lifnr  EQ  gs_disp-lifnr.

  CONCATENATE ztitcsk-bktxt '(' lfa1-name1 ')' INTO ztitcsk-bktxt.

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
         ' ' 'ZTISSCRCOM-EXPGR'  'L',
*         ' ' 'ZTISSCRCOM-CSTYP'  ZTISSCRCOM-CSTYP
         ' ' 'ZTISSCRCOM-WAERS'  gs_disp-hwaer,
         ' ' 'ZTISSCRCOM-BLART'  ztitcsk-blart,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.

*> 세부화면.
  WRITE gs_disp-wrbtr TO l_text_amout CURRENCY gs_disp-hwaer.
  PERFORM    set_write_no_mask(ztir9000)
                                    CHANGING  l_text_amout.

  CLEAR: l_date.
  IF NOT ztitcsk-zfbdt IS INITIAL.
    WRITE ztitcsk-zfbdt TO l_date.
  ENDIF.

  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR9000'           '2000',
         ' ' 'ZTITCSK-CSTYP'  ztitcsk-cstyp,
         ' ' 'ZTITCSK-INAME'  ztitcsk-iname,
         ' ' 'ZTITCSK-HKONT'  ztitcsk-hkont,
*         ' ' 'ZTITCSK-BUPLA'  ztitcsk-bupla,
*         ' ' 'ZTITCSK-GSBER'  ztitcsk-gsber,
*         ' ' 'ZTITCSK-ZFBDT'  l_date,
         ' ' 'ZTITCSK-ZLSPR'  ztitcsk-zlspr,
*         ' ' 'ZTITCSK-UZAWE'  ztitcsk-uzawe,
*         ' ' 'ZTITCSK-ZLSCH'  ztitcsk-zlsch,
         ' ' 'ZTITCSK-ZTERM'  ztitcsk-zterm,
         ' ' 'ZTITCSK-MWSKZ'  ztitcsk-mwskz,
*         ' ' 'ZTITCSK-XBLNR'  ztitcsk-xblnr,
*         ' ' 'ZTITCSK-BKTXT'  ztitcsk-bktxt.
         ' ' 'ZTITCSK-XBLNR'      gs_disp-opnno,
*         ' ' 'ZTITCSK-BKTXT'      GS_DISP-exptx,
*         ' ' 'ZTITCSK-SGTXT'      GS_DISP-exptx,
         ' ' 'ZTISCSIT-EXPCD(01)'  gs_disp-expcd,
         ' ' 'ZTISCSIT-REQNO(01)'  gs_disp-reqno,
         ' ' 'ZTISCSIT-AMDSQ(01)'  gs_disp-amdsq,
         ' ' 'ZTISCSIT-WRBTR(01)'  l_text_amout,
         ' ' 'ZTISCSIT-MWSKZ(01)'  ztitcsk-mwskz,
         ' ' 'ZTISCSIT-WMWST(01)'  '0',
         ' ' 'ZTISCSIT-FWBAS(01)'  '0'.

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
    ADD gs_disp-wrbtr TO g_wrbtr.
  ENDLOOP.

*> build BDC data
  PERFORM build_collective_posting_data.
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
        l_icssq           TYPE ztiicssq,
        l_date(10)        TYPE c.

  REFRESH: bdcdata.

  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR9000'          '0100',
         ' ' 'ZTISSCRCOM-BUKRS'  ztitcsk-bukrs,
         ' ' 'ZTISSCRCOM-BUDAT'  ztitcsk-budat,
         ' ' 'ZTISSCRCOM-BLDAT'  ztitcsk-bldat,
         ' ' 'ZTISSCRCOM-LIFNR'  gs_disp-lifnr,
         ' ' 'ZTISSCRCOM-EXPGR'  'L',
         ' ' 'ZTISSCRCOM-WAERS'  ztitcsk-waers,
         ' ' 'ZTISSCRCOM-BLART'  ztitcsk-blart,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.

**> 세부화면.
*  WRITE g_wrbtr TO l_text_amout CURRENCY ZTITCSK-waers.
*  PERFORM    set_write_no_mask(ZTIr9000)
*                                    CHANGING  l_text_amout.

  CLEAR: l_date.
  IF NOT ztitcsk-zfbdt IS INITIAL.
    WRITE ztitcsk-zfbdt TO l_date.
  ENDIF.

  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR9000'       '2000',
         ' ' 'ZTITCSK-CSTYP'  ztitcsk-cstyp,
         ' ' 'ZTITCSK-INAME'  ztitcsk-iname,
         ' ' 'ZTITCSK-HKONT'  ztitcsk-hkont,
*         ' ' 'ZTITCSK-BUPLA'  ztitcsk-bupla,
*         ' ' 'ZTITCSK-GSBER'  ztitcsk-gsber,
*         ' ' 'ZTITCSK-ZFBDT'  l_date,
         ' ' 'ZTITCSK-ZLSPR'  ztitcsk-zlspr,
*         ' ' 'ZTITCSK-UZAWE'  ztitcsk-uzawe,
*         ' ' 'ZTITCSK-ZLSCH'  ztitcsk-zlsch,
         ' ' 'ZTITCSK-ZTERM'  ztitcsk-zterm,
         ' ' 'ZTITCSK-MWSKZ'  ztitcsk-mwskz,
         ' ' 'ZTITCSK-XBLNR'  ztitcsk-xblnr.
*         ' ' 'ZTITCSK-BKTXT'  ztitcsk-bktxt.
*         ' ' 'ZTITCSK-SGTXT'  ZTITCSK-sgtxt.

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

    WRITE gs_disp-wrbtr TO l_text_amout CURRENCY gs_disp-hwaer.
    PERFORM    set_write_no_mask(ztir9000)
                                      CHANGING  l_text_amout.

    IF g_count EQ 1.
      PERFORM bdc_dynpro_build USING :
             ' ' 'ZTISCSIT-EXPCD(01)'  gs_disp-expcd,
             ' ' 'ZTISCSIT-REQNO(01)'  gs_disp-reqno,
             ' ' 'ZTISCSIT-AMDSQ(01)'  gs_disp-amdsq,
             ' ' 'ZTISCSIT-WRBTR(01)'  l_text_amout,
             ' ' 'ZTISCSIT-MWSKZ(01)'  ztitcsk-mwskz,
             ' ' 'ZTISCSIT-WMWST(01)'  '0',
             ' ' 'ZTISCSIT-FWBAS(01)'  '0'.
      l_icssq = 1.
    ELSE.
      PERFORM bdc_dynpro_build USING :
             'X' 'ZTIR9000'          '2000',
             ' ' 'ZTISCSIT-EXPCD(02)'  gs_disp-expcd,
             ' ' 'ZTISCSIT-REQNO(02)'  gs_disp-reqno,
             ' ' 'ZTISCSIT-AMDSQ(02)'  gs_disp-amdsq,
             ' ' 'ZTISCSIT-WRBTR(02)'  l_text_amout,
             ' ' 'ZTISCSIT-MWSKZ(02)'  ztitcsk-mwskz,
             ' ' 'ZTISCSIT-WMWST(02)'  '0',
             ' ' 'ZTISCSIT-FWBAS(02)'  '0'.
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

* one-time vendor인 경우.




  IF ok_code NE 'SIMU'.
    PERFORM bdc_dynpro_build USING :
           'X' 'SAPLSPO1'          '0300',
           ' ' 'BDC_OKCODE'       '=YES'.
  ENDIF.

ENDFORM.                    " build_collective_posting_data
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
     AND cstct EQ 'B'.

  SELECT SINGLE *
    FROM t005
   WHERE land1 EQ t001-land1.

  IF g_answer IS INITIAL.
    CALL FUNCTION 'Z_TI_EXPENCES_CODE_BY_GROUP'
      EXPORTING
        xbukrs    = t001-bukrs
        xexpgr    = 'L'
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
      MESSAGE e874 WITH '수입의뢰'.
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
    MOVE:  sy-msgid   TO  it_msg-msgid,
           sy-msgty   TO  it_msg-msgty,
           sy-msgno   TO  it_msg-msgno,
           sy-msgv1   TO  it_msg-msgv1,
           sy-msgv2   TO  it_msg-msgv2,
           sy-msgv3   TO  it_msg-msgv3,
           sy-msgv4   TO  it_msg-msgv4,
           gs_disp-reqno TO  it_msg-refno.
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
             gs_disp-reqno   TO it_msg-refno.
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
             gs_disp-reqno TO  it_msg-refno.
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

*  CLEAR gs_sort_g.
*  gs_sort_g-spos      = '00'.
*  gs_sort_g-fieldname = 'BOX'.
*  gs_sort_g-down      = 'X'.
*  gs_sort_g-subtot    = 'X'.
*  gs_sort_g-LEVEL     =  1.
*  gs_sort_g-GROUP     = 'X'.
*  APPEND gs_sort_g TO it_sort_g.

  CLEAR gs_sort_g.
  gs_sort_g-spos      = '01'.
  gs_sort_g-fieldname = 'LIFNR'.
  gs_sort_g-up        = 'X'.
  gs_sort_g-subtot    = 'X'.
*  gs_sort_g-LEVEL     =  1.
*  gs_sort_g-GROUP     = 'X'.
  APPEND gs_sort_g TO it_sort_g.

  CLEAR gs_sort_g.
  gs_sort_g-spos      = '02'.
  gs_sort_g-fieldname = 'BUPLA'.
  gs_sort_g-up        = 'X'.
  gs_sort_g-subtot    = 'X'.
*  gs_sort_g-LEVEL     =  1.
*  gs_sort_g-GROUP     = 'X'.
  APPEND gs_sort_g TO it_sort_g.

  CLEAR gs_sort_g.
  gs_sort_g-spos      = '03'.
  gs_sort_g-fieldname = 'MWSKZ'.
  gs_sort_g-up        = 'X'.
  gs_sort_g-subtot    = 'X'.
*  gs_sort_g-LEVEL     =  1.
*  gs_sort_g-GROUP     = 'X'.
  APPEND gs_sort_g TO it_sort_g.

  CLEAR gs_sort_g.
  gs_sort_g-spos      = '04'.
  gs_sort_g-fieldname = 'OPNNO'.
  gs_sort_g-up        = 'X'.
*  gs_sort_g-subtot    = 'X'.
*  gs_sort_g-LEVEL     =  1.
*  gs_sort_g-GROUP     = 'X'.
  APPEND gs_sort_g TO it_sort_g.

  CLEAR gs_sort_g.
  gs_sort_g-spos      = '05'.
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

    IF gs_fieldcat_g-fieldname = 'WRBTR' OR         " 금액.
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

*  gs_stable-row = 'X'.
*  gs_stable-col = 'X'.
*
  CALL METHOD g_grid->refresh_table_display.
*    EXPORTING
*      is_stable = gs_stable.
*
*  CALL METHOD cl_gui_cfw=>flush.

ENDFORM.                    " P9000_REFRESH_DISPLAY
*&---------------------------------------------------------------------*
*&      Module  status_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.

  REFRESH excl.

  IF NOT ztislccs-icsno IS INITIAL.
    MOVE 'BU' TO excl-funktion.    APPEND excl.
  ENDIF.

  SET PF-STATUS '0200' EXCLUDING excl.

  CLEAR: ok_code.

ENDMODULE.                 " status_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pai_check_fields_scr0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_check_fields_scr0300 INPUT.

  CHECK ok_code NE 'ABBR'.

  IF ztislccs-icsno IS INITIAL.
    IF ztislccs-bgndt IS INITIAL.
      PERFORM no_input_check(ztir0000) USING :
                                              'ZTISLCCS' 'BGNDT' 'E'.
    ENDIF.
    IF ztislccs-expdt IS INITIAL.
      PERFORM no_input_check(ztir0000) USING :
                                              'ZTISLCCS' 'EXPDT' 'E'.
    ENDIF.
    IF ztislccs-trate IS INITIAL.
      PERFORM no_input_check(ztir0000) USING :
                                              'ZTISLCCS' 'TRATE' 'E'.
    ENDIF.
    IF ztislccs-iajrt IS INITIAL.
      PERFORM no_input_check(ztir0000) USING :
                                              'ZTISLCCS' 'IAJRT' 'E'.
    ENDIF.
    IF ztislccs-bgndt GE ztislccs-expdt.
      MESSAGE e119 WITH '마감일자' '시작일자'.
    ENDIF.

*> 기간 계산.
    PERFORM  calc_term_month  USING    ztislccs-bgndt
                                       ztislccs-expdt
                                       ztislccs-monct.

*    IF *ZTIslccs-tmchg NE ZTIslccs-tmchg OR
*       *ZTIslccs-tmchg IS INITIAL.
    IF ztislccs-waers1 EQ ztislccs-hwaer.
      ztislccs-iajrt = 1.
       *ztislccs-tmchg = ztislccs-opamt * ( ztislccs-monct / 3 )
                                        * ( ztislccs-trate / 100 ).
      IF ztislccs-tmchg IS INITIAL.
        ztislccs-tmchg = *ztislccs-tmchg.
      ENDIF.
*         *ZTIslccs = ZTIslccs.
      EXIT.
    ENDIF.

*> Get exchange rate
    CHECK *ztislccs-tmchg IS INITIAL.

    CLEAR: bapiret1, bapi1093_0.
    CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
      EXPORTING
        rate_type  = 'M'
        from_curr  = ztislccs-waers1
        to_currncy = ztislccs-hwaer
        date       = ztislccs-bgndt
      IMPORTING
        exch_rate  = bapi1093_0
        return     = bapiret1.

    IF bapiret1-type EQ 'E'.
      MESSAGE ID bapiret1-id TYPE bapiret1-type NUMBER bapiret1-number
                 WITH bapiret1-message_v1 bapiret1-message_v2
                      bapiret1-message_v3 bapiret1-message_v4.
    ENDIF.

    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERN_9'
      EXPORTING
        currency        = ztislccs-waers1
        amount_internal = ztislccs-opamt
      IMPORTING
        amount_external = bapicurx-bapicurx.

     *ztislccs-tmchg = bapicurx-bapicurx * ( ztislccs-monct / 3 )   *
                       ztislccs-iajrt    * ( ztislccs-trate / 100 ) *
                    ( bapi1093_0-to_factor / bapi1093_0-from_factor ).

    bapicurx-bapicurx = *ztislccs-tmchg.
    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERN_9'
      EXPORTING
        currency             = ztislccs-hwaer
        amount_external      = bapicurx-bapicurx
        max_number_of_digits = 18
      IMPORTING
        amount_internal      = *ztislccs-tmchg.
    IF ztislccs-tmchg IS INITIAL.
      ztislccs-tmchg = *ztislccs-tmchg.
    ENDIF.
*    ENDIF.

*     *ZTIslccs = ZTIslccs.
  ENDIF.

ENDMODULE.                 " pai_check_fields_scr0300  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_field_attribute_scr0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_field_attribute_scr0300 OUTPUT.

  LOOP AT SCREEN.
    IF NOT screen-group1 IS INITIAL.
      IF ztislccs-icsno IS INITIAL..
        screen-input     = '1'.
      ELSE.
        screen-input     = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " change_field_attribute_scr0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

  CASE ok_code.
    WHEN 'ABBR'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'BU'.
      IF ztislccs-icsno IS INITIAL.
        SELECT SINGLE *
          FROM ztitrqs
         WHERE reqno    EQ  ztislccs-reqno
           AND amdsq    EQ  ztislccs-amdsq.

        MOVE: ztislccs-monct  TO ztitrqs-monct,
              ztislccs-bgndt  TO ztitrqs-bgndt,
              ztislccs-expdt  TO ztitrqs-expdt,
              ztislccs-trate  TO ztitrqs-trate,
              ztislccs-iajrt  TO ztitrqs-iajrt,
              ztislccs-tmchg  TO ztitrqs-tmchg,
              ztislccs-tmchg  TO gs_disp-tmchg,
              ztislccs-tmchg  TO gs_disp-wrbtr,
              ztislccs-monct  TO gs_disp-monct,
              ztislccs-bgndt  TO gs_disp-bgndt,
              ztislccs-expdt  TO gs_disp-expdt,
              ztislccs-trate  TO gs_disp-trate,
              ztislccs-iajrt  TO gs_disp-iajrt.
        MODIFY ztitrqs.
        IF sy-subrc EQ 0.
          MODIFY it_disp FROM gs_disp INDEX g_tabix.
        ENDIF.
      ENDIF.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN OTHERS.
  ENDCASE.
  CLEAR:ok_code.

ENDMODULE.                 " user_command_0300  INPUT
*&---------------------------------------------------------------------*
*&      Form  CALC_TERM_MONTH
*&---------------------------------------------------------------------*
*       Term 계산
*----------------------------------------------------------------------*
FORM calc_term_month  USING    p_bgndt
                               p_expdt
                               p_monct.

  DATA: l_bgndt   LIKE sy-datum,
        l_day     TYPE i.


  l_day = p_expdt - p_bgndt.

  p_monct = l_day / 30.

ENDFORM.                    " CALC_TERM_MONTH
*&---------------------------------------------------------------------*
*&      Form  CHECK_INPUT_VALUE
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

  lfa1-name1    = vf_kred-name1.

  ztitcsk-xcpdk = vf_kred-xcpdk.
  IF ztitcsk-zterm IS INITIAL.
    ztitcsk-zterm = vf_kred-zterm.
  ENDIF.

*  break-point.

*  if ZTITCSK-zfbdt is initial.
  IF sy-dynnr EQ '0100'.
    CALL FUNCTION 'FI_TERMS_OF_PAYMENT_PROPOSE'
      EXPORTING
        i_bldat = ztitcsk-bldat
        i_budat = ztitcsk-budat
        i_cpudt = sy-datlo
*        i_zfbdt = ZTITCSK-zfbdt
        i_zterm = ztitcsk-zterm
      IMPORTING
        e_zbd1t = ztitcsk-zbd1t
        e_zbd1p = ztitcsk-zbd1p
        e_zbd2t = ztitcsk-zbd2t
        e_zbd2p = ztitcsk-zbd2p
        e_zbd3t = ztitcsk-zbd3t
        e_zlsch = ztitcsk-zlsch
        e_zschf = ztitcsk-zlspr
        e_zfbdt = ztitcsk-zfbdt .
  ELSE.
    CALL FUNCTION 'FI_TERMS_OF_PAYMENT_PROPOSE'
      EXPORTING
        i_bldat = ztitcsk-bldat
        i_budat = ztitcsk-budat
        i_cpudt = sy-datlo
        i_zfbdt = ztitcsk-zfbdt
        i_zterm = ztitcsk-zterm
      IMPORTING
        e_zbd1t = ztitcsk-zbd1t
        e_zbd1p = ztitcsk-zbd1p
        e_zbd2t = ztitcsk-zbd2t
        e_zbd2p = ztitcsk-zbd2p
        e_zbd3t = ztitcsk-zbd3t.
*        e_zlsch = ztitcsk-zlsch
*        e_zschf = ZTITCSK-zlspr
*        e_zfbdt = ztitcsk-zfbdt .
*
  ENDIF.

ENDFORM.                    " CHECK_INPUT_VALUE
*&---------------------------------------------------------------------*
*&      Form  SET_SELECTED_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_MARK  text
*----------------------------------------------------------------------*
FORM set_selected_row  USING    p_mark.

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


  IF g_count <> 0.
    MESSAGE s883 WITH g_count.
  ENDIF.

  CALL METHOD g_grid->refresh_table_display.

ENDFORM.                    " SET_SELECTED_ROW
*&---------------------------------------------------------------------*
*&      Form  refresh_confirm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM refresh_confirm USING p_ans.
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
        MESSAGE s132 WITH gs_disp-reqno gs_disp-amdsq '전기'.
      ELSE.
        MESSAGE s132 WITH gs_disp-reqno gs_disp-amdsq '생성'.
      ENDIF.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 전표유형.
    IF gs_disp-blart IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s129 WITH gs_disp-reqno gs_disp-amdsq '전표유형'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 공급업체.
    IF gs_disp-lifnr IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s129 WITH gs_disp-reqno gs_disp-amdsq '공급업체'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 사업장.
    IF gs_disp-bupla IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s129 WITH gs_disp-reqno gs_disp-amdsq '사업장'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 트랜잭션유형.
    IF gs_disp-mwskz IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s129 WITH gs_disp-reqno gs_disp-amdsq '세금코드'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 전기유형.
    IF gs_disp-cstyp IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s129 WITH gs_disp-reqno gs_disp-amdsq '전기 유형'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 트랜잭션유형.
    IF gs_disp-vorgang IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s129 WITH gs_disp-reqno gs_disp-amdsq '트랜잭션유형'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 금액.
    IF gs_disp-wrbtr IS INITIAL AND
       gs_disp-wmwst IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s129 WITH gs_disp-reqno gs_disp-amdsq  '비용'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 과세표준액.
    IF NOT gs_disp-wmwst IS INITIAL AND
           gs_disp-fwbas IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s129 WITH gs_disp-reqno gs_disp-amdsq '과세표준액'.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

*> 통화금액.
    IF gs_disp-waers IS INITIAL.
      gs_disp-errmd = 'X'.
      MESSAGE s129 WITH gs_disp-reqno gs_disp-amdsq '통화'.
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
*  -->  p1        text
*  <--  p2        text
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
      PERFORM set_header_data_by_collect USING l_icsno  'L'.

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
                         AND box   EQ 'X'
                         AND errmd EQ space.

        CLEAR: it_ztitcsp.
        ADD 1 TO l_icssq.

        PERFORM set_item_data   USING l_icsno  l_icssq  'L'.
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
      PERFORM set_header_data_by_individual USING l_icsno  'L'.
*---> Item data Move
      CLEAR: l_icssq.
      ADD 1 TO l_icssq.
      PERFORM set_item_data   USING l_icsno  l_icssq  'L'.
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
