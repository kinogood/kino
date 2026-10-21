************************************************************************
*                                                                      *
* Title         : ZTIR9210                                             *
*                                                                      *
* Description   : [Report] 계산서(FINBIL) 수신데이타 현황(수입)        *
*                                                                      *
* Creation Date : 2004/02/07                                           *
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
*   1.                                                                 *
*                                                                      *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
*                                                                      *
*                                                                      *
************************************************************************
PROGRAM   ztir9210
          MESSAGE-ID zmti00
          NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis.   "> Globale Type(ALV)

************************************************************************
* User Included                                                        *
************************************************************************
INCLUDE: zts_reuse_bdc_subroutine_f00,
         <icon>.
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: l_yn    type c.
INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* Internal Tables                                                      *
************************************************************************

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: t001,      ">Company Codes
        lfa1  ,    ">Vendor Master (General Section)
        lfb1  ,    ">Vendor Master (Company Code)
        t005  ,    ">국가.
        ztitrqs,
        ztitig00,  ">
        ztstig3,   ">[TraSys] Define EDI Partner
        ztitig07,  ">[TraSys] 제비용 일괄전기 Default Value관리.
        dfies ,    ">DD Interface: Table Fields for DDIF_FIELDINFO_GET
        ztssfbk,   ">[TraSys] 계산서(FINBIL) Header Structure
        ztstfbk,   ">[TraSys] 계산서(FINBIL) Header Table
        ztstfbp,   ">[TraSys] 계산서(FINBIL) Items Table
        ztivcs00,  ">비용 Views
        ztsvfb00,  ">[TraSys] FINBIL 문서 Views
        ztitcsk,   ">비용 Header
        ztisscrcom, ">
        vf_kred,   ">
        skat.      ">G/L 계정 마스터레코드 (계정과목표: 내역)

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
    c_save(1)   TYPE  c             VALUE 'A'.

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK box1 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
       s_bukrs  FOR ztstfbk-bukrs   "회사코드
                    MEMORY ID  buk ,
       s_finno  FOR ztstfbk-finno,  "계산서 문서번호.
       s_refno  FOR ztstfbk-refno,  "참조문서 번호.
       s_epart  FOR ztstfbk-epart,  "EDI 파트너.
       s_bilgb  FOR ztstfbk-bilgb,  "계산서 구분.
       s_tradt  FOR ztstfbk-tradt,  "계좌입금일.
       s_recdt  FOR ztstfbk-recdt,  "접수일자.
       s_cnam   FOR ztstfbk-cnam,   "작성인
       s_cdat   FOR ztstfbk-cdat,   "생성일
       s_ctme   FOR ztstfbk-ctme.   "작성시간.

SELECTION-SCREEN ULINE.
PARAMETERS: p_step1 RADIOBUTTON GROUP ab1 DEFAULT 'X',
            p_step2 RADIOBUTTON GROUP ab1,
            p_step3 RADIOBUTTON GROUP ab1.
SELECTION-SCREEN ULINE.
PARAMETERS: p_full RADIOBUTTON GROUP ab2 DEFAULT 'X',
            p_list RADIOBUTTON GROUP ab2.
SELECTION-SCREEN END OF BLOCK box1.

*> Report variant
SELECTION-SCREEN: BEGIN OF BLOCK alv WITH FRAME TITLE text-003.
PARAMETERS: alv_def LIKE disvariant-variant.
SELECTION-SCREEN: END OF BLOCK alv.

************************************************************************
* Internal Tables                                                      *
************************************************************************
DATA: BEGIN OF it_ztsvfb00  OCCURS 2.
        INCLUDE STRUCTURE   ztsvfb00.
DATA: END   OF it_ztsvfb00.

DATA: BEGIN OF it_vendor  OCCURS 2,
      lifnr    TYPE lifnr,
      END   OF it_vendor.

DATA: BEGIN OF it_waers  OCCURS 2,
      waers    TYPE waers,
      END   OF it_waers.

DATA: BEGIN OF it_bupla  OCCURS 2,
      bupla    TYPE bupla,
      END   OF it_bupla.

DATA: BEGIN OF it_ztstfbk  OCCURS 2.
        INCLUDE STRUCTURE   ztstfbk.
DATA: END   OF it_ztstfbk.

*> 공급업체명
DATA : BEGIN OF xlfa1 OCCURS 0,
       lifnr           LIKE   lfa1-lifnr,
       name1           LIKE   lfa1-name1.
DATA : END   OF xlfa1.
*> 비용항목.
DATA : BEGIN OF it_ztstfbc OCCURS 0.
        INCLUDE STRUCTURE ztstfbc.
DATA : END   OF it_ztstfbc.

DATA : BEGIN OF it_ztitig06 OCCURS 0.
        INCLUDE STRUCTURE ztitig06.
DATA : END   OF it_ztitig06.

*> 비용헤더.
DATA : BEGIN OF it_ztssfbk OCCURS 0.
        INCLUDE STRUCTURE ztssfbk.
DATA : END   OF it_ztssfbk.

*> FINBIL 문서번호.
DATA : BEGIN OF it_finno OCCURS 0,
       finno    TYPE ztsfinno.
DATA : END   OF it_finno.

DATA:    BEGIN OF excl OCCURS 25,
           funktion(10),
         END OF excl.

DATA : g_message_handler   TYPE REF TO cl_message_handler_mm.


DATA: it_fieldcat_g TYPE lvc_t_fcat,
      gs_fieldcat_g LIKE LINE OF it_fieldcat_g.

*---------------------------------------------------------------------*
*> Message dialog box용                                               *
*---------------------------------------------------------------------*
DATA: BEGIN OF it_msg  OCCURS 0.
        INCLUDE STRUCTURE ztismessage.
DATA: END   OF it_msg.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
*---------------------------------------------------------------------
* Accumulators
*---------------------------------------------------------------------
*DATA:
*  BEGIN OF A,
*
*  END OF A.
*
*
*----------------------------------------------------------------------
* Switches
*----------------------------------------------------------------------
DATA: BEGIN OF fc_struct,
        tabname(7),
        fieldname(6),
        ref_tabname(29),
        ref_fieldname(6),
        no_out(1),
        cqindicator(1),
        cqfield(6),
      END OF fc_struct.

DATA: s_variant      LIKE  disvariant,
      s_var_usr      LIKE  disvariant.

*----------------------------------------------------------------------
* Work fields
*----------------------------------------------------------------------
DATA : g_line          TYPE   i,             "Line counter
       g_subrc         LIKE   sy-subrc,      "Return code
       g_tabix         LIKE   sy-tabix,      "table index
       g_line1(3)      TYPE   n,             "LINE COUNT
       g_out_text(70)  TYPE   c,             "text field(display)
       g_err_mode      TYPE   c,
       g_answer        TYPE   c,
       g_success       TYPE   i,
       g_error         TYPE   i,
       g_cnt           TYPE   i,
       g_count         TYPE   i,
       g_wrbtr         TYPE   wrbtr,
       g_wmwst         TYPE   wmwst,
       line_cnt(02)    TYPE   n,
       ok_code         LIKE   sy-ucomm,
       field_name(20),
       field_name1(20).

* Global variables for handling ALV functionality
DATA: alv_keyinfo      TYPE slis_keyinfo_alv.
DATA: alv_variant      LIKE disvariant.
DATA: gs_layout        TYPE slis_layout_alv.
DATA: alv_repid        LIKE sy-repid.
DATA: alv_print        TYPE slis_print_alv.
DATA: st_sort          TYPE slis_sortinfo_alv.

DATA: alv_detail_func(30).
DATA: fc       TYPE slis_t_fieldcat_alv,
      fc1      TYPE slis_t_fieldcat_alv,
      fcs      TYPE slis_fieldcat_alv,
      it_sort  TYPE slis_t_sortinfo_alv.

************************************************************************
* RANGES
************************************************************************
*RANGES:
*   XXXT FOR XXX-XXX OCCURS 1.

***********************************************************************
* FIELD-GROUPS
***********************************************************************
*FIELD-GROUPS:

***********************************************************************
* FIELD-SYMBOLS
***********************************************************************
FIELD-SYMBOLS: <fs>  TYPE ANY,
               <fsl> TYPE ANY,
               <fss> TYPE ANY.

FIELD-SYMBOLS: <gt_table> TYPE table.

************************************************************************
* MACRO DEFINE                                                         *
************************************************************************
DEFINE ac.
  clear:  fcs, fc_struct.
  fc_struct         = &1.
  fcs-tabname        = fc_struct-tabname.
  fcs-fieldname      = fc_struct-fieldname.
  fcs-ref_tabname    = fc_struct-ref_tabname.
  fcs-ref_fieldname  = fc_struct-ref_fieldname.
  fcs-no_out         = fc_struct-no_out.

  case fc_struct-cqindicator.
    when 'C'.
      fcs-cfieldname = fc_struct-cqfield.
    when 'Q'.
      fcs-qfieldname = fc_struct-cqfield.
  endcase.
  append fcs to fc.
END-OF-DEFINITION.

DEFINE ac_1.
  clear: fcs, fc_struct.
*  FC_STRUCT         = &1.
  fcs-tabname        = &1.
  fcs-fieldname      = &2.
  fcs-ref_tabname    = &3.
  fcs-ref_fieldname  = &4.
  fcs-no_out         = &5.

  case &6.
    when 'C'.
      fcs-cfieldname = &7.
    when 'Q'.
      fcs-qfieldname = &7.
  endcase.
  append fcs to fc.

END-OF-DEFINITION.

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
*                                                                      *
* INITIALIZATION Event                                                 *
*                                                                      *
************************************************************************
INITIALIZATION.
  PERFORM  set_initial_data.
  PERFORM  set_alv_init.             ">Initialize ALV variable

************************************************************************
*                                                                      *
* AT SELECTION-SCREEN Events                                           *
*                                                                      *
************************************************************************
*>The layout determines the list format
AT SELECTION-SCREEN ON VALUE-REQUEST FOR alv_def.
  PERFORM exec_alv_f4.

AT SELECTION-SCREEN.
  PERFORM input_field_check.
  PERFORM alv_variant_check.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM p1102_authorization_check USING s_bukrs-low.
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
*                                                                      *
* START-OF-SELECTION Event                                             *
*                                                                      *
************************************************************************
START-OF-SELECTION.
  PERFORM clearing_work_area.      ">Initialize internal table
  PERFORM set_fieldcat_build.      ">Set ALV field category
  PERFORM create_dynamic_table.    ">Create dynamic Internale table
  PERFORM get_data_for_display.    ">data select

************************************************************************
*                                                                      *
* END-OF-SELECTION Event                                               *
*                                                                      *
************************************************************************
END-OF-SELECTION.
  CHECK g_line NE 0.
*>--------------------------------------------------------
*> PROGRESS INDICATOR DISPLAY.
*>  4.  LIST DISPLAY
*>--------------------------------------------------------
  g_line1 = 100.
  g_out_text = text-905.
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM set_progress_bar USING g_out_text g_line1.
  PERFORM set_colorize_build.       ">Set color
  PERFORM set_sort_field.           ">Set ALV sort fields
  PERFORM display_alv_list.         ">Call ALV Functions

************************************************************************
*                                                                      *
* TOP-OF-PAGE Event                                                    *
*                                                                      *
************************************************************************
TOP-OF-PAGE.

************************************************************************
*                                                                      *
* END-OF-PAGE Event                                                    *
*                                                                      *
************************************************************************
END-OF-PAGE.


************************************************************************
*                                                                      *
* TOP-OF-PAGE DURING LINE-SELECTION Event                              *
*                                                                      *
************************************************************************
TOP-OF-PAGE DURING LINE-SELECTION.


************************************************************************
*                                                                      *
* AT LINE-SELECTION Event                                              *
*                                                                      *
************************************************************************
AT LINE-SELECTION.


************************************************************************
*                                                                      *
* AT USER-COMMAND Event                                                *
*                                                                      *
************************************************************************
AT USER-COMMAND.


*eject
************************************************************************
*                                                                      *
* S U B R O U T I N E S                                                *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  SET_INITIAL_DATA
*&---------------------------------------------------------------------*
FORM set_initial_data.

  SET TITLEBAR 'T1000' WITH '계산서(FINBIL) 수신데이타'.

  alv_repid = sy-repid.
  CLEAR s_variant.
  s_variant-report = sy-repid.

* Get default variant
  s_var_usr = s_variant.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = c_save
    CHANGING
      cs_variant = s_var_usr
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    alv_def =  s_var_usr-variant.
  ENDIF.

ENDFORM.                    " SET_INITIAL_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_PROGRESS_BAR
*&---------------------------------------------------------------------*
FORM set_progress_bar USING   text perc.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = perc
      text       = text.

ENDFORM.                    " SET_PROGRESS_BAR
*&---------------------------------------------------------------------*
*&      Form  INPUT_FIELD_CHECK
*&---------------------------------------------------------------------*
FORM input_field_check.

  DATA: l_bukrs   LIKE t001-bukrs,
        l_werks   LIKE t001w-werks,
        l_matnr   LIKE mara-matnr,
        l_mtart   LIKE t134-mtart,
        l_ebeln   LIKE ekko-ebeln,
        l_lifnr   LIKE lfa1-lifnr,
        l_ekorg   LIKE t024e-ekorg,
        l_ekgrp   LIKE t024-ekgrp.

* Company code
  SELECT *
    FROM t001 UP TO 1 ROWS
   WHERE bukrs IN s_bukrs.
  ENDSELECT.
  IF sy-subrc <> 0.
    PERFORM get_ftext(rddfie00) USING 'T001' 'BUKRS' sy-langu
                                CHANGING dfies g_subrc.
    SET CURSOR FIELD 'S_BUKRS-LOW'.
    MESSAGE e348(m7) WITH dfies-scrtext_m.
  ENDIF.

  SELECT SINGLE *
    FROM ztitig00
   WHERE bukrs EQ t001-bukrs.

  IF sy-subrc NE 0.
    MESSAGE e035 WITH t001-bukrs.
  ENDIF.


  SELECT SINGLE *
    FROM t005
   WHERE land1  EQ  t001-land1.

ENDFORM.                    " INPUT_FIELD_CHECK
*&---------------------------------------------------------------------*
*&      Form  CLEARING_WORK_AREA
*&---------------------------------------------------------------------*
FORM clearing_work_area.

  FREE:  xlfa1.
  CLEAR: xlfa1.

  IF p_full EQ 'X'.
    alv_detail_func = 'REUSE_ALV_GRID_DISPLAY'.
  ELSE.
    alv_detail_func = 'REUSE_ALV_LIST_DISPLAY'.
  ENDIF.

ENDFORM.                    " CLEARING_WORK_AREA
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_FOR_DISPLAY
*&---------------------------------------------------------------------*
FORM get_data_for_display.

  DATA:  l_count     TYPE  i,
         l_cnt       type  i,
         l_ddtext    TYPE  ddtext.
  RANGES: lr_sysyn   FOR   ztstfbc-sysyn OCCURS 1.

  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_icon>.
  FIELD-SYMBOLS: <l_sysyn>.
  FIELD-SYMBOLS: <l_exptx>,
                 <l_alcty>.
  FIELD-SYMBOLS: <ddtext>.

  REFRESH : <gt_table>.
*> PROGRESS Display.
  g_line1    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_line1.

  CLEAR lr_sysyn.
*----------------------------------------------------------------------
*P :	전기완료
*N :	전기대상
*----------------------------------------------------------------------
  CASE 'X'.
    WHEN p_step1. ">전기대상.
      MOVE: 'I'     TO    lr_sysyn-sign,
            'EQ'    TO    lr_sysyn-option.
      MOVE: 'N'     TO    lr_sysyn-low.
      APPEND lr_sysyn .
      MOVE: 'I'     TO    lr_sysyn-sign,
            'EQ'    TO    lr_sysyn-option.
      MOVE: space   TO    lr_sysyn-low.
    WHEN p_step2. ">전기완료.
      MOVE: 'I'     TO    lr_sysyn-sign,
            'EQ'    TO    lr_sysyn-option.
      MOVE: 'Y'     TO    lr_sysyn-low.
      APPEND lr_sysyn.
    WHEN p_step3. ">전체.
      REFRESH lr_sysyn.
  ENDCASE.

*  PERFORM  set_expence_type  USING '2AA'.

*> 입금통지 데이타 select.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_ztstfbk
    FROM ztstfbk
   WHERE finno IN s_finno
     AND bukrs IN s_bukrs
     AND epart IN s_epart
*     AND NOT bilgb IN ('2BA', '2BB', 'ZZZ')
     AND imexi EQ 'I'
     AND tradt IN s_tradt
     AND recdt IN s_recdt
     AND refno IN s_refno
     AND cnam  IN s_cnam
     AND cdat  IN s_cdat
     AND ctme  IN s_ctme.
*     AND sysyn IN lr_sysyn.

  IF sy-subrc NE 0.
    MESSAGE s902.
  ENDIF.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.
  ASSIGN COMPONENT 'SYSYN'  OF STRUCTURE <ls_table> TO <l_sysyn>.
  ASSIGN COMPONENT 'EXPTX'  OF STRUCTURE <ls_table> TO <l_exptx>.
  ASSIGN COMPONENT 'ALCTY'  OF STRUCTURE <ls_table> TO <l_alcty>.

  ASSIGN COMPONENT 'ICON'   OF STRUCTURE <ls_table> TO <l_icon>.


  LOOP AT it_ztstfbk.
    g_tabix = sy-tabix.
    MOVE-CORRESPONDING  it_ztstfbk TO <ls_table>.

    SELECT *
       INTO CORRESPONDING FIELDS OF TABLE it_ztstfbc
       FROM ztstfbc
      WHERE finno EQ it_ztstfbk-finno
        AND sysyn IN lr_sysyn.

    IF sy-subrc NE 0.
      <l_sysyn>  =  'N'.
      <l_icon>   = icon_red_light.
      <l_exptx>  = space.
      APPEND  <ls_table> TO <gt_table>.
      CONTINUE.
    ENDIF.

    CLEAR: l_cnt.
    LOOP AT it_ztstfbc.
      ADD 1 TO l_cnt.
    MOVE-CORRESPONDING  it_ztstfbc TO <ls_table>.
    PERFORM  get_domain_value_text(ztir0000) USING 'ZTSALCTY'
                                                   it_ztstfbc-alcty
                                                   l_ddtext.

      <l_exptx> = l_ddtext.
      IF <l_sysyn> EQ 'Y'.
        <l_icon> = icon_green_light.
      ELSE.
        <l_icon> = icon_red_light.
      ENDIF.
      APPEND  <ls_table> TO <gt_table>.
    ENDLOOP.




  ENDLOOP.

  DESCRIBE TABLE <gt_table> LINES g_line.
  IF g_line EQ 0.
    MESSAGE s902.
  ENDIF.

ENDFORM.                    " GET_DATA_FOR_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  EXEC_ALV_F4
*&---------------------------------------------------------------------*
FORM exec_alv_f4.

  alv_repid = sy-repid.
  CLEAR: alv_variant.
  alv_variant-report = alv_repid.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = alv_variant
      i_save     = 'A'
    IMPORTING
      es_variant = alv_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    alv_def = alv_variant-variant.
  ENDIF.

ENDFORM.                    " EXEC_ALV_F4
*&---------------------------------------------------------------------*
*&      Form  SET_ALV_INIT
*&---------------------------------------------------------------------*
FORM set_alv_init.

  FREE:  it_sort, fc.
  CLEAR: alv_keyinfo, gs_layout, alv_print, fc.

* PRINTING SETTINGS
  gs_layout-get_selinfos = 'X'.
  gs_layout-group_change_edit = 'X'.

  alv_print-no_print_selinfos = 'X'.
  alv_print-no_coverpage = 'X'.
  alv_print-no_print_listinfos = 'X'.

ENDFORM.                    " SET_ALV_INIT
*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT_BUILD
*&---------------------------------------------------------------------*
FORM set_fieldcat_build.

  DATA: color TYPE slis_t_specialcol_alv WITH HEADER LINE.

  FREE : fc.  CLEAR: fc.

*> Create field catagory table
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZTSSFB00'
*      i_structure_name       = 'ZTSTFBC'
      i_client_never_display = 'X'
    CHANGING
      ct_fieldcat            = it_fieldcat_g[].

*>Adjust ALV field category
  PERFORM adjust_fieldcat.         ">Adjust ALV field category

  fc1[] = fc[].



  ac 'ITAB   COLOR SLIS_T_SPECIALCOL_ALV              X'.

  LOOP AT fc1 INTO fcs.
    CLEAR: fcs-key .
    CASE fcs-fieldname.
      WHEN 'BOX'.
        fcs-no_out  = 'X'.
      WHEN 'ICON'.
        fcs-seltext_l = '상태'.
        fcs-seltext_m = '상태'.
        fcs-seltext_s = '상태'.
        fcs-key       = 'X'.
        fcs-col_pos   = '1'.
      WHEN 'FINNO'.
        CLEAR fcs-no_out.
        fcs-key       = 'X'.
        fcs-col_pos   = '2'.
      WHEN 'FBSEQ'.
        CLEAR fcs-no_out.
        fcs-key       = 'X'.
        fcs-col_pos   = '3'.
      WHEN 'ALCTY'.
*        fcs-no_out = 'X'.
        fcs-col_pos   = '4'.
      WHEN 'EXPTX'.
        CLEAR fcs-no_out.
        fcs-col_pos   = '5'.
      WHEN 'PCDRA'.
        CLEAR fcs-no_out.
        fcs-col_pos   = '6'.
      WHEN 'WAERS'.
        CLEAR fcs-no_out.
        fcs-col_pos   = '7'.
      WHEN 'MOACG'.
        fcs-col_pos   = '8'.
      WHEN 'HWAER'.
        fcs-col_pos   = '9'.
      WHEN 'MOACA'.
        fcs-col_pos   = '10'.
        fcs-do_sum    = 'X'.
      WHEN 'KURSF'.
      WHEN 'APDAY'.
      WHEN 'APFRD'.
      WHEN 'APEND'.
      WHEN 'EPART'.
      WHEN 'NAMET'.
      WHEN 'LIFNR'.
      WHEN 'BILGB'.
      WHEN 'BILTX'.
      WHEN 'RFFNO'.
      WHEN 'RFENO'.
      WHEN 'FIBNO'.
      WHEN 'RMKNO'.
      WHEN 'TRADT'.

*      WHEN 'ACEPTX'.
*        CLEAR: fcs-tabname,
*               fcs-ref_tabname.
*
*        fcs-seltext_l = '반영여부'.
*        fcs-seltext_m = '반영여부'.
*        fcs-seltext_s = '반영여부'.
*        fcs-outputlen = 8.
*        fcs-key       = 'X'.
*        fcs-col_pos   = '2'.
*      WHEN 'FINNO'.
*        fcs-hotspot = 'X'.
*        fcs-key     = 'X'.
*        fcs-col_pos   = '3'.
*      WHEN 'IMEXIX'.
*        fcs-seltext_l = '구분'.
*        fcs-seltext_m = '구분'.
*        fcs-seltext_s = '구분'.
*        fcs-col_pos   = '4'.
*      WHEN 'BILGB'.
*        fcs-col_pos   = '5'.
*      WHEN 'BILTX'.
*        fcs-col_pos   = '6'.
*      WHEN 'BANCD'.
*        fcs-col_pos   = '7'.
*      WHEN 'BANNM'.
*        fcs-col_pos   = '8'.
*      WHEN 'WAERS'.
*        fcs-col_pos   = '9'.
*      WHEN 'FPAMT'.
*        fcs-col_pos   = '10'.
*      WHEN 'MOACC'.
*        fcs-col_pos   = '11'.
*      WHEN 'MOACS'.
*        fcs-col_pos   = '12'.
*      WHEN 'EPART'.
*        fcs-no_out  = 'X'.
*      WHEN 'NAMET'.
*        fcs-no_out  = 'X'.
*      WHEN 'BUKRS'.
*      WHEN 'GJAHR'.
*      WHEN 'ICSNO'.
*      WHEN 'REFNO'.
*      WHEN 'PAYSQ'.
*
*      WHEN 'RFFNO'.
*      WHEN 'RFENO'.
*      WHEN 'FIBNO'.
*      WHEN 'RMKNO'.
*      WHEN 'TRADT'.
*      WHEN 'ADVDT'.
*      WHEN 'RECDT'.
      WHEN OTHERS.
        fcs-no_out  = 'X'.
    ENDCASE.
    MODIFY fc1 FROM fcs.
  ENDLOOP.

ENDFORM.                    " SET_FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_LIST
*&---------------------------------------------------------------------*
FORM display_alv_list.

  DATA: fc_detail TYPE slis_fieldcat_alv OCCURS 0 WITH HEADER LINE.
  DATA: variant_detail      LIKE disvariant.
  DATA: exit     TYPE slis_event_exit   OCCURS 0 WITH HEADER LINE.
  DATA: events   TYPE slis_alv_event    OCCURS 0 WITH HEADER LINE.
  DATA: groups   TYPE slis_sp_group_alv OCCURS 0 WITH HEADER LINE.

  CASE 'X'.
    WHEN p_step1. ">의뢰대상
      SET TITLEBAR 'T1000' WITH '계산서(EDI) - 반영대상 '.
    WHEN p_step2. ">접수대상
      SET TITLEBAR 'T1000' WITH '계산서(EDI) - 반영완료 '.
    WHEN p_step3. ">신청대상
      SET TITLEBAR 'T1000' WITH '계산서(EDI) - 전체현황'.
  ENDCASE.

* The detail ALV may modify the list (sorting). If returned to the
* base list, the original list needs to be restored.
  REFRESH fc_detail.
  LOOP AT fc1 INTO fcs.
    MOVE-CORRESPONDING fcs TO fc_detail.
    CLEAR fc_detail-tabname.
    APPEND fc_detail.
  ENDLOOP.

  CLEAR variant_detail.
  variant_detail-report = alv_repid.
  variant_detail-handle = ' '.

  gs_layout-colwidth_optimize = 'X'.
  gs_layout-zebra             = 'X'.
  gs_layout-box_fieldname     = 'BOX'.
*>color field define.
  gs_layout-coltab_fieldname  = 'COLOR'.
  gs_layout-group_change_edit = 'X'.
  gs_layout-f2code            = 'DISPLAY'.

  REFRESH exit.
  exit-ucomm = '&OL0'. exit-after = 'X'. APPEND exit.
  exit-ucomm = '&OLX'. APPEND exit.
  exit-ucomm = '&OAD'. APPEND exit.

*> event define.
  REFRESH events.
  events-name = slis_ev_top_of_page.
  events-form = 'TOP_OF_PAGE'.
  APPEND events.

*  events-name = slis_ev_subtotal_text.
*  events-form = slis_ev_subtotal_text.
*  APPEND events.
*
*> ALV reuse function call..
  CALL FUNCTION alv_detail_func
      EXPORTING
        i_callback_program       = alv_repid
        i_callback_pf_status_set = 'SET_ALV_STATUS'
        i_callback_user_command  = 'USER_ALV_COMMAND'
*     I_STRUCTURE_NAME               =
*     IT_EXCLUDING                   =
*     IT_SPECIAL_GROUPS              =
*     IT_FILTER                      =
*     IS_SEL_HIDE                    =
*     I_DEFAULT                      = 'X'
*     I_SAVE                         = ' '
*     IS_VARIANT                     =
      it_events                      = events[]
      it_event_exit                  = exit[]
*     IS_PRINT                       =
*     IS_REPREP_ID                   =
*     I_SCREEN_START_COLUMN          = 0
*     I_SCREEN_START_LINE            = 0
*     I_SCREEN_END_COLUMN            = 0
*     I_SCREEN_END_LINE              = 0
        it_fieldcat              = fc_detail[]
        it_sort                  = it_sort
*        I_DEFAULT                = 'X'
*        IS_VARIANT               = VARIANT_DETAIL
        is_variant               = alv_variant
        i_save                   = c_save
        is_layout                = gs_layout
        is_print                 = alv_print
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER        =
*     ES_EXIT_CAUSED_BY_USER         =
      TABLES
        t_outtab                 = <gt_table>.

ENDFORM.                    " DISPLAY_ALV_LIST

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_STATUS
*&---------------------------------------------------------------------*
FORM set_alv_status USING  extab TYPE slis_t_extab.


  APPEND 'ARCHIVE'   TO extab.
  APPEND '&VEXCEL'   TO extab.
  APPEND '&AQW'      TO extab.
  APPEND '&VCRYSTAL' TO extab.
  APPEND '&VGRID'    TO extab.
  APPEND '&EB9'      TO extab.
  APPEND '&CRDESIG'  TO extab.

  CASE 'X'.
    WHEN p_step1. ">반영대상.
    WHEN p_step2. ">반영현황.
      APPEND 'ZTICOPY'  TO extab.
    WHEN p_step3. ">전체현황.
      APPEND 'ZTICOPY'  TO extab.
  ENDCASE.

  SET PF-STATUS 'STANDARD' EXCLUDING extab.

ENDFORM.                    " SET_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  USER_ALV_COMMAND
*&---------------------------------------------------------------------*
FORM user_alv_command USING   r_ucomm      LIKE sy-ucomm
                              rs_selfield  TYPE slis_selfield.
*
  DATA: l_count   TYPE i.
  DATA: l_index   TYPE i.
  DATA: l_subrc   LIKE sy-subrc.
  DATA: l_tcode   LIKE sy-tcode.
  DATA: l_icsno   TYPE ztiicsno,
        l_gjahr   TYPE gjahr.
  DATA: l_if_null TYPE REF TO if_message_obj_mm.

  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_box>,
                 <l_finno>,
                 <l_fbseq>,
                 <l_alcty>,
                 <l_acept>,
                 <l_lifnr>,
                 <l_negno>,
                 <l_rfeno>,
                 <l_refno>,
                 <l_paysq>,
                 <l_imexi>.

  FIELD-SYMBOLS: <l_field>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.
  ASSIGN COMPONENT 'BOX'   OF STRUCTURE <ls_table> TO <l_box>.
  ASSIGN COMPONENT 'FINNO' OF STRUCTURE <ls_table> TO <l_finno>.
  ASSIGN COMPONENT 'FBSEQ' OF STRUCTURE <ls_table> TO <l_fbseq>.
  ASSIGN COMPONENT 'ALCTY' OF STRUCTURE <ls_table> TO <l_alcty>.

  ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <ls_table> TO <l_lifnr>.
  ASSIGN COMPONENT 'ACEPT' OF STRUCTURE <ls_table> TO <l_acept>.
  ASSIGN COMPONENT 'IMEXI' OF STRUCTURE <ls_table> TO <l_imexi>.
  ASSIGN COMPONENT 'NEGNO' OF STRUCTURE <ls_table> TO <l_negno>.
  ASSIGN COMPONENT 'RFENO' OF STRUCTURE <ls_table> TO <l_rfeno>.
  ASSIGN COMPONENT 'REFNO' OF STRUCTURE <ls_table> TO <l_refno>.
  ASSIGN COMPONENT 'PAYSQ' OF STRUCTURE <ls_table> TO <l_paysq>.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_ztitig06
    FROM ztitig06
   WHERE bukrs  EQ  t001-bukrs
     AND expgr  EQ  'L'.

  CASE r_ucomm.
*>----------------------------------------------------------------------
*> SMART FORMS 출력
*>----------------------------------------------------------------------
    WHEN 'DISPLAY' OR '&IC1'.    " AUF DOPPELKLICK REAGIERIEN
      CHECK rs_selfield-tabindex GT 0.

      READ TABLE <gt_table> INTO <ls_table> INDEX rs_selfield-tabindex.
      IF sy-subrc NE 0.
        MESSAGE s906.            EXIT.
      ENDIF.
*>----------------------------------------------------------------------
*> EDI DATA DELETE
*>----------------------------------------------------------------------
    WHEN 'ZTIDELETE'.           ">EDI DATA Delete.
*
      PERFORM finbil_data_delete  USING l_count.
      CHECK g_answer EQ 'J'.
      IF l_count GT 0.
        PERFORM get_data_for_display.    ">data select
        rs_selfield-refresh = 'X'.
        MESSAGE s716 WITH l_count.
      ENDIF.

*>----------------------------------------------------------------------
*> 회계전표 기표...
*>----------------------------------------------------------------------
    WHEN 'ZTICOPY'.           ">회계문서 반영..
      CLEAR: l_count.
      REFRESH: it_vendor, it_waers, it_bupla, it_ztsvfb00.

* Message preparations
      PERFORM  set_message_preparations.
      CLEAR: g_wrbtr.
      LOOP AT <gt_table> INTO <ls_table>.
        IF <l_box> EQ 'X'.
          ADD 1 TO l_count.
          MOVE-CORRESPONDING: <ls_table> TO ztsvfb00.

          SELECT SINGLE *
            INTO ztsvfb00
            FROM ztsvfb00
           WHERE finno  EQ  <l_finno>
             AND fbseq  EQ  <l_fbseq>.

*> 공급업체.
          IF ztsvfb00-lifnr IS INITIAL.
            MESSAGE s915 WITH '은행에 해당하는' '공급업체코드'.
            zti_message 'E' sy-msgid sy-msgno
                        sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            CONTINUE.
          ENDIF.

*>> FINBIL 문서 검증.
          SELECT SINGLE *
            FROM ztstfbk
           WHERE finno  EQ  ztsvfb00-finno.
          IF sy-subrc NE 0.
            MESSAGE s713 WITH ztsvfb00-finno.
            zti_message 'E' sy-msgid sy-msgno
                        sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            CONTINUE.
          ENDIF.
*> 기반영분 데이타 오류.
          IF ztsvfb00-sysyn EQ 'Y'.
            MESSAGE s707 WITH '계산서' ztsvfb00-finno.
            zti_message 'E' sy-msgid sy-msgno
                        sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            CONTINUE.
          ENDIF.

*> 비용코드 검증.
          READ TABLE it_ztitig06 WITH KEY expcd = ztsvfb00-alcty.
          IF sy-subrc NE 0.
            MESSAGE s866 WITH ztsvfb00-alcty.
            zti_message 'E' sy-msgid sy-msgno
                        sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            CONTINUE.
          ENDIF.
*> 금액체크.
          IF ztsvfb00-moaca IS INITIAL.
            PERFORM no_input_check(ztir0000)
                                  USING 'ZTSTFBC' 'MOACA' 'S'.
            zti_message 'E' sy-msgid sy-msgno
                        sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            CONTINUE.
          ENDIF.
*> 통화체크.
          IF ztsvfb00-hwaer IS INITIAL.
            PERFORM no_input_check(ztir0000)
                                  USING 'ZTSTFBC' 'HWAER' 'S'.
            zti_message 'E' sy-msgid sy-msgno
                        sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            CONTINUE.
          ENDIF.
*> 입금의뢰번호.
          CLEAR: ztitrqs.
          SELECT SINGLE *
            FROM ztitrqs
           WHERE opnno  EQ  ztsvfb00-rffno.
          IF sy-subrc NE 0.
            MESSAGE s714 WITH ztsvfb00-finno ztsvfb00-rffno.
            zti_message 'E' sy-msgid sy-msgno
                        sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            CONTINUE.
          ELSE.
            ztsvfb00-rfeno = ztitrqs-reqno.
            ztsvfb00-refno = ztitrqs-reqno.
          ENDIF.

          MOVE-CORRESPONDING ztsvfb00 TO it_ztsvfb00.
          APPEND it_ztsvfb00.

*> 사업장.
*          BREAK-POINT.
          MOVE ztitrqs-bupla TO it_bupla-bupla.
          COLLECT it_bupla.
*> 통화....
          MOVE ztsvfb00-hwaer TO it_waers-waers.
          COLLECT it_waers.
*> Vendor
          MOVE: ztsvfb00-lifnr TO it_vendor-lifnr.
          COLLECT it_vendor.
          ADD ztsvfb00-moaca TO g_wrbtr.
        ENDIF.
      ENDLOOP.
      IF l_count EQ 0.
        MESSAGE s909.    EXIT.
      ENDIF.
*> Error Message Display.
      PERFORM display_error_message.
      CHECK g_line EQ 0.

*> 전표전기 종류 선택 함수(월합계산서 or 개별전표)
      IF l_count EQ 1.
        ztisscrcom-monsc = 'S'.
      ELSE.
        CALL FUNCTION 'Z_TI_COST_DOCUMENT_TYPE_POPUP'
          IMPORTING
            p_answer = g_answer
            p_monsc  = ztisscrcom-monsc.

        CHECK g_answer EQ 'Y'.
        IF ztisscrcom-monsc EQ 'S'.
*> 사업장.
          DESCRIBE TABLE it_bupla LINES g_line.
          CASE g_line.
            WHEN 0.
              MESSAGE s030 WITH '사업장'.
              PERFORM set_return_message_fill USING 'E'.
            WHEN 1.
            WHEN OTHERS.
              MESSAGE s030 WITH '사업장'.
              PERFORM set_return_message_fill USING 'E'.
          ENDCASE.

*> 은행.
          DESCRIBE TABLE it_vendor LINES g_line.
          CASE g_line.
            WHEN 0.
              MESSAGE s022 WITH '은행'.
              PERFORM set_return_message_fill USING 'E'.
            WHEN 1.
            WHEN OTHERS.
              MESSAGE s023 WITH '은행'.
              PERFORM set_return_message_fill USING 'E'.
          ENDCASE.

*> 통화단위.
          DESCRIBE TABLE it_waers LINES g_line.
          CASE g_line.
            WHEN 0.
              MESSAGE s030 WITH '통화단위'.
              PERFORM set_return_message_fill USING 'E'.
            WHEN 1.
            WHEN OTHERS.
              MESSAGE s031 WITH '통화단위'.
              PERFORM set_return_message_fill USING 'E'.
          ENDCASE.
*> Error Message Display.
          PERFORM display_error_message.
          CHECK g_line EQ 0.
        ENDIF.
      ENDIF.

* Message preparations
*> 전기확인용 대화화면 Call
      CLEAR: ok_code.
      PERFORM  set_message_preparations.
*> 전기용 HEADER DATA Fill
      PERFORM   fill_default_header_data.
*> 확인 대화상자 Call
      CLEAR: ok_code.
      CALL SCREEN '0200' STARTING AT 1 8.
      IF ok_code EQ 'ABBR'.
        MESSAGE s900.
        EXIT.
      ELSEIF ok_code EQ 'SIMU'.
        ctu_params-dismode  = 'E'. ">처리모드
      ENDIF.
      CLEAR: g_success, g_error.

      LOOP AT it_ztsvfb00.
        IF <l_box> EQ 'X'.
*> Lock Object.
          CLEAR: l_subrc.
          PERFORM  set_finbil_lock_object USING 'L'
                                                it_ztsvfb00-finno
                                                'S'
                                                l_subrc.
          IF l_subrc NE 0.
            zti_message 'E' sy-msgid sy-msgno
                        sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDLOOP.
*> Error Message Display.
      PERFORM display_error_message.
      IF g_line GT 0.
        CALL FUNCTION 'DEQUEUE_ALL'.
      ENDIF.
      CHECK g_line EQ 0.

      IF ztisscrcom-monsc EQ 'S'.
        PERFORM execute_collective_posting.
      ELSE.
        PERFORM execute_individual_posting.
      ENDIF.
*> Error Message Display.
      PERFORM display_error_message.

*> 검색조건에 해당하는 데이타를 Select.
      CHECK g_success GT 0.
      PERFORM get_data_for_display.    ">data Select.
      CALL FUNCTION 'DEQUEUE_ALL'.
      rs_selfield-refresh = 'X'.
    WHEN OTHERS.

  ENDCASE.
  CLEAR: r_ucomm.

ENDFORM.                    " USER_ALV_COMMAND
*&---------------------------------------------------------------------*
*&      Form  ALV_VARIANT_CHECK
*&---------------------------------------------------------------------*
FORM alv_variant_check.

  alv_variant-report = alv_repid.
  alv_variant-variant = alv_def.
  IF NOT alv_def IS INITIAL.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save     = 'A'
      CHANGING
        cs_variant = alv_variant
      EXCEPTIONS
        OTHERS     = 1.
    IF sy-subrc <> 0.
      MESSAGE e321(m7) WITH alv_def alv_repid.
    ENDIF.
  ENDIF.

ENDFORM.                    " ALV_VARIANT_CHECK
*&---------------------------------------------------------------------*
*&      Form  SET_SORT_FIELD
*&---------------------------------------------------------------------*
FORM set_sort_field.

  REFRESH: it_sort.

  REFRESH: it_sort.

  CLEAR  st_sort.
  st_sort-spos = '01'.
  st_sort-fieldname = 'FINNO'.
  st_sort-tabname   = 'ITAB'.
  st_sort-up        = 'X'.
*  ST_SORT-GROUP     = 'X'.
  st_sort-subtot    = 'X'.
*  ST_SORT-EXPA      = 'X'.
  APPEND st_sort TO it_sort.
*
  CLEAR  st_sort.
  st_sort-spos = '02'.
  st_sort-fieldname = 'FBSEQ'.
  st_sort-tabname   = 'ITAB'.
  st_sort-up        = 'X'.
*  ST_SORT-GROUP     = 'X'.
*  ST_SORT-SUBTOT    = 'X'.
*  ST_SORT-EXPA      = 'X'.
  APPEND st_sort TO it_sort.
*

ENDFORM.                    " SET_SORT_FIELD

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM top_of_page.

  DATA: l_mode TYPE i.
  DATA: header TYPE slis_listheader OCCURS 0 WITH HEADER LINE.

  REFRESH header.

  header-typ = 'H'.
*----------------------------------------------------------------------
*  : 의뢰대상
*C : 수입의뢰
*A : 접수완료
*W : 신청서작성
*Y : 개설신청
*N : 개설취소
*O : 개설완료
*R : 접수반려
*----------------------------------------------------------------------
  CASE 'X'.
    WHEN p_step1.
      header-info = '전기대상 현황'.
    WHEN p_step2.
      header-info = '전기완료 현황'.
    WHEN p_step3.
      header-info = '전체 현황'.
  ENDCASE.

  CLEAR: header-key.
  APPEND header.

** JS전선 회사코드 2007/04 KSH --------------------------------------
  DATA: l_butxt LIKE t001-butxt.
  CLEAR: l_butxt.
  SELECT SINGLE butxt FROM t001
                      INTO l_butxt
                     WHERE bukrs EQ s_bukrs-low.

  header-typ = 'S'.
  header-key = '회사코드 '.
  CONCATENATE s_bukrs-low l_butxt INTO header-info SEPARATED BY space.
  APPEND header.
  CLEAR: header.
** JS전선 회사코드 2007/04 KSH --------------------------------------

  header-typ = 'S'.
  header-key = '출력일자'(106).
  WRITE: sy-datlo TO header-info.
  APPEND header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = header[].

ENDFORM.    ">TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  MATERIAL_MASTER_DISPLAY
*&---------------------------------------------------------------------*
FORM material_master_display USING rs_selfield  TYPE slis_selfield.

  FIELD-SYMBOLS: <ls_table>.

  READ TABLE <gt_table> INTO <ls_table>
                        INDEX rs_selfield-tabindex. "cursorposit.
  IF sy-subrc EQ 0.
*    MOVE-CORRESPONDING <ls_table> TO xitab.
*
*    READ TABLE organ WITH KEY werks = xitab-werks.
*
*    SET PARAMETER ID 'MAT' FIELD xitab-matnr.
*    SET PARAMETER ID 'BUK' FIELD organ-bukrs.
*    SET PARAMETER ID 'WRK' FIELD xitab-werks.
    SET PARAMETER ID 'LAG' FIELD ''.
*  SET PARAMETER ID 'MXX' FIELD 'KDEALBSZXVPCFQG'.
    SET PARAMETER ID 'MXX' FIELD 'KDE'.

    CALL TRANSACTION 'MM03' AND SKIP  FIRST SCREEN.
  ELSE.
    MESSAGE s903.
  ENDIF.

ENDFORM.                    " MATERIAL_MASTER_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  create_dynamic_table
*&---------------------------------------------------------------------*
FORM create_dynamic_table .

  DATA: lp_table        TYPE REF TO data.
  DATA: e_style_fname   TYPE lvc_fname.
  DATA: i_style_table   TYPE c.
  DATA: lt_fieldcat     TYPE lvc_t_fcat.

*create_dynamic_table
  CLEAR lp_table.
  CALL METHOD z_ti_cl_alv_table_create=>create_dynamic_table_grid
    EXPORTING
      it_fieldcatalog = fc
*      i_style_table   = i_style_table
    IMPORTING
      ep_table        = lp_table.

  ASSIGN lp_table->* TO <gt_table>.

ENDFORM.                    " create_dynamic_table
*&---------------------------------------------------------------------*
*&      Form  set_colorize_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_colorize_build .

  FIELD-SYMBOLS: <lt_table> TYPE table.
  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <lt_color>.
  FIELD-SYMBOLS: <ls_color>.
  FIELD-SYMBOLS: <l_field> TYPE table.
  FIELD-SYMBOLS: <l_name>.
  FIELD-SYMBOLS: <l_col>.
  FIELD-SYMBOLS: <l_int>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <lt_table>.

  DATA: color TYPE slis_t_specialcol_alv WITH HEADER LINE.

*> colorize
  LOOP AT <gt_table> INTO <lt_table>.

    ASSIGN COMPONENT 'COLOR' OF STRUCTURE
                             <lt_table> TO <l_field>.

    ASSIGN LOCAL COPY OF INITIAL LINE OF <l_field> TO <ls_color>.

    ASSIGN COMPONENT 'COLOR-COL' OF STRUCTURE
                             <ls_color> TO <l_col>.
    ASSIGN COMPONENT 'COLOR-INT' OF STRUCTURE
                             <ls_color> TO <l_int>.
    ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE
                             <ls_color> TO <l_name>.
    <l_col> = 4.
    <l_int> = 0.
    <l_name> = 'REQTY'.
    APPEND <ls_color> TO <l_field>.

    MODIFY <gt_table> FROM <lt_table>.
  ENDLOOP.

ENDFORM.                    " set_colorize_build
*&---------------------------------------------------------------------*
*&      Form  ADJUST_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM adjust_fieldcat .

  FIELD-SYMBOLS: <ls_table>,
                 <l_field>.

  DATA: lt_fieldcat_g TYPE lvc_t_fcat.

*>Internal table에 존재하지 않는 필드.
  LOOP AT it_fieldcat_g INTO gs_fieldcat_g.
    READ TABLE fc INTO fcs WITH KEY fieldname = gs_fieldcat_g-fieldname.
    IF sy-subrc NE 0.
      IF NOT gs_fieldcat_g-fieldname IS INITIAL AND
         gs_fieldcat_g-fieldname     NE 'MANDT'.
        MOVE-CORRESPONDING  gs_fieldcat_g TO fcs.
        MOVE: gs_fieldcat_g-fieldname     TO fcs-ref_fieldname,
              'ZTSSFB00'                  TO fcs-ref_tabname.
        CLEAR: fcs-key.
*        fcs-no_out = 'X'.
        APPEND fcs TO fc.
      ENDIF.
    ENDIF.
    DESCRIBE TABLE fc LINES g_line.
    IF g_line GT 50.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " ADJUST_fieldcat
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
*&      Form  fill_default_header_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fill_default_header_data.

  READ TABLE it_bupla INDEX 1.

  MOVE: it_bupla-bupla   TO    ztitcsk-bupla.

  SELECT SINGLE *
    FROM ztitig07
   WHERE bukrs EQ t001-bukrs
     AND cstct EQ 'B'.

  MOVE: sy-datlo         TO    ztitcsk-budat,
        sy-datlo         TO    ztitcsk-bldat,
        ztitig07-blart   TO    ztitcsk-blart,
        t001-bukrs       TO    ztitcsk-bukrs,
        sy-mandt         TO    ztitcsk-mandt,
*        ztitig07-bupla   TO    ztitcsk-bupla,
        ztitig07-gsber   TO    ztitcsk-gsber,
        ztitig07-cstyp   TO    ztitcsk-cstyp,
        ztitig07-mwskz   TO    ztitcsk-mwskz,
        ztitig07-zlspr   TO    ztitcsk-zlspr,
        ztitig07-zlsch   TO    ztitcsk-zlsch,
        ztitig07-uzawe   TO    ztitcsk-uzawe,
        ztsvfb00-rffno   TO    ztitcsk-xblnr,  ">매입추심번호.
        ztsvfb00-lifnr   TO    ztitcsk-lifnr,
        ztsvfb00-hwaer   TO    ztitcsk-waers,
        g_wrbtr          TO    ztitcsk-wrbtr,
        g_wmwst          TO    ztitcsk-wmwst.


  SELECT name_text
    INTO ztitcsk-iname
    FROM adrp UP TO 1 ROWS
   WHERE persnumber EQ ( SELECT persnumber
                           FROM usr21
                          WHERE bname EQ sy-uname ).

  ENDSELECT.
*
  PERFORM  get_domain_value_text(ztir9000)
                                 USING   'ZTIEXPGR'
                                         'L'
                                 CHANGING ztitcsk-bktxt.

  SELECT SINGLE *
    FROM lfa1
   WHERE lifnr  EQ  it_vendor-lifnr.

  CONCATENATE ztitcsk-bktxt '(' lfa1-name1 ')' INTO ztitcsk-bktxt.

*> 입력된 값 체크.
  PERFORM  check_input_value.
*
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
*
ENDMODULE.                 " change_field_attribute_scr0200  OUTPUT
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

*
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
*&      Form  set_return_message_fill
*&---------------------------------------------------------------------*
FORM set_return_message_fill USING p_msgty.

*> build message
  zti_message p_msgty sy-msgid sy-msgno
               sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

ENDFORM.                    " set_return_message_fill
*&---------------------------------------------------------------------*
*&      Form  check_input_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_input_value .

  CHECK NOT ztitcsk-lifnr IS INITIAL.

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
*&      Module  pai_check_fields_scr0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_check_fields_scr0300 INPUT.

  CHECK ok_code NE 'ABBR'.

*> 전기일.
  IF ztitcsk-budat IS INITIAL.
    PERFORM no_input_check(ztir0000) USING 'ZTITCSK' 'BUDAT' 'E'.
  ENDIF.
*> 증빙일.
  IF ztitcsk-bldat IS INITIAL.
    PERFORM no_input_check(ztir0000) USING 'ZTITCSK' 'BLDAT' 'E'.
  ENDIF.

*  IF ZTITCSK-saknr IS INITIAL.
*    PERFORM no_input_check(ZTIr0000) USING 'ZTITCSK' 'SAKNR' 'E'.
*  ELSE.
*    SELECT SINGLE *
*      FROM skat
*     WHERE spras EQ sy-langu
*       AND ktopl EQ t001-ktopl
*       AND saknr EQ ZTITCSK-saknr .
*  ENDIF.
*
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

ENDMODULE.                 " pai_check_fields_scr0300  INPUT
*&---------------------------------------------------------------------*
*&      Form  SET_FINBIL_LOCK_OBJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_finbil_lock_object  USING    p_mode
                                      p_finno
                                      p_msgty
                                      p_subrc.
  CLEAR: p_subrc.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TS_ZTSTFBK'
      EXPORTING
        mandt          = sy-mandt
        finno          = p_finno
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_subrc = 8.
      MESSAGE ID sy-msgid TYPE p_msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TS_ZTSTFBK'
      EXPORTING
        mandt = sy-mandt
        finno = p_finno.
  ENDIF.

ENDFORM.                    " SET_FINBIL_LOCK_OBJECT
*&---------------------------------------------------------------------*
*&      Module  exit_scr0200  INPUT
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

ENDMODULE.                 " exit_scr0200  INPUT
*&---------------------------------------------------------------------*
*&      Form  display_error_message
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
      im_amodal = space ).
  ENDIF.

ENDFORM.                    " display_error_message
*&---------------------------------------------------------------------*
*&      Form  execute_collective_posting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM execute_collective_posting .

  DATA: l_subrc   LIKE sy-subrc.

  REFRESH: bdcdata.
  CLEAR: g_cnt, g_wrbtr.

*> build BDC data
  PERFORM build_collective_posting_data.
  CLEAR: sy.

  CLEAR: ztitcsk.
  FREE MEMORY ID 'ZTIR9000'.
  EXPORT ztitcsk TO MEMORY ID 'ZTIR9000'.
*> Call transaction
  PERFORM bdc_transaction        USING 'ZTIT901' l_subrc.
*> build Message internal table.
  PERFORM build_posted_message   USING l_subrc.
*> Finbil data modify
  PERFORM set_finbil_data_modify.

ENDFORM.                    " execute_collective_posting
*&---------------------------------------------------------------------*
*&      Form  execute_individual_posting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM execute_individual_posting .

  DATA: l_subrc   LIKE sy-subrc.

  LOOP AT it_ztsvfb00.
    MOVE-CORRESPONDING it_ztsvfb00 TO ztsvfb00.
*> build BDC data
    PERFORM build_individual_posting_data.

    CLEAR: ztitcsk.
    FREE MEMORY ID 'ZTIR9000'.
    EXPORT ztitcsk TO MEMORY ID 'ZTIR9000'.

*> Call transaction
    PERFORM bdc_transaction        USING 'ZTIT901' l_subrc.
*> build Message internal table.
    PERFORM build_posted_message   USING l_subrc.
*> Finbil data modify
    PERFORM  set_finbil_data_modify_by_rec USING ztsvfb00.
  ENDLOOP.

ENDFORM.                    " execute_individual_posting
*&---------------------------------------------------------------------*
*&      Form  build_collective_posting_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_collective_posting_data .

  DATA: l_text_amout(20),
        l_icssq           TYPE ztiicssq.

  READ TABLE it_vendor INDEX 1.

  READ TABLE it_waers INDEX 1.

  REFRESH: bdcdata.

  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR9000'          '0100',
         ' ' 'ZTISSCRCOM-BUKRS'  ztitcsk-bukrs,
         ' ' 'ZTISSCRCOM-BUDAT'  ztitcsk-budat,
         ' ' 'ZTISSCRCOM-BLDAT'  ztitcsk-bldat,
         ' ' 'ZTISSCRCOM-LIFNR'  ztitcsk-lifnr,
         ' ' 'ZTISSCRCOM-EXPGR'  'L',
         ' ' 'ZTISSCRCOM-WAERS'  it_waers-waers,
         ' ' 'ZTISSCRCOM-BLART'  ztitcsk-blart,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.

**> 세부화면.
*  WRITE g_wrbtr TO l_text_amout CURRENCY ztitcsk-waers.
*  PERFORM    set_write_no_mask(ztir9000)
*                                    CHANGING  l_text_amout.
*
  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR9000'       '2000',
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
  LOOP AT it_ztsvfb00.
    ADD 1 TO g_count.

    WRITE it_ztsvfb00-moaca TO l_text_amout
                            CURRENCY it_ztsvfb00-hwaer.
    PERFORM    set_write_no_mask(ztir9000)
                                      CHANGING  l_text_amout.

    IF g_count EQ 1.
      PERFORM bdc_dynpro_build USING :
             ' ' 'ZTISCSIT-EXPCD(01)'  it_ztsvfb00-alcty,
             ' ' 'ZTISCSIT-REQNO(01)'  it_ztsvfb00-refno,
             ' ' 'ZTISCSIT-AMDSQ(01)'  '00',
             ' ' 'ZTISCSIT-WRBTR(01)'  l_text_amout,
             ' ' 'ZTISCSIT-MWSKZ(01)'  ztitcsk-mwskz,
             ' ' 'ZTISCSIT-WMWST(01)'  '0',
             ' ' 'ZTISCSIT-FWBAS(01)'  '0'.
      l_icssq = 1.
    ELSE.
      PERFORM bdc_dynpro_build USING :
             'X' 'ZTIR9000'          '2000',
             ' ' 'ZTISCSIT-EXPCD(02)'  it_ztsvfb00-alcty,
             ' ' 'ZTISCSIT-REQNO(02)'  it_ztsvfb00-refno,
             ' ' 'ZTISCSIT-AMDSQ(02)'  '00',
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
*&      Form  build_individual_posting_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_individual_posting_data .

  DATA: l_text_amout(20),
        l_icssq           TYPE ztiicssq.

  REFRESH: bdcdata.

  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR9000'          '0100',
         ' ' 'ZTISSCRCOM-BUKRS'  ztitcsk-bukrs,
         ' ' 'ZTISSCRCOM-BUDAT'  ztitcsk-budat,
         ' ' 'ZTISSCRCOM-BLDAT'  ztitcsk-bldat,
*         ' ' 'ZTISSCRCOM-CSTYP'  ztitcsk-cstyp,
         ' ' 'ZTISSCRCOM-LIFNR'  it_ztssfbk-lifnr,
         ' ' 'ZTISSCRCOM-EXPGR'  'L',
         ' ' 'ZTISSCRCOM-WAERS'  ztitcsk-waers,
         ' ' 'ZTISSCRCOM-BLART'  ztitcsk-blart,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.

*> 세부화면.
  WRITE it_ztsvfb00-moaca TO l_text_amout
                          CURRENCY it_ztsvfb00-hwaer.
  PERFORM    set_write_no_mask(ztir9000)
                                    CHANGING  l_text_amout.

  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR9000'       '2000',
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
*         ' ' 'ZTITCSK-SGTXT'  ZTITCSK-sgtxt.
         ' ' 'ZTISCSP-EXPCD(01)'  it_ztsvfb00-alcty,
         ' ' 'ZTISCSP-REQNO(01)'  it_ztsvfb00-rfeno,
         ' ' 'ZTISCSP-AMDSQ(01)'  '00',
*         ' ' 'ZTISCSP-AMSEQ(01)'  it_table-amdsq,
         ' ' 'ZTISCSP-WRBTR(01)'  l_text_amout,
         ' ' 'ZTISCSP-MWSKZ(01)'  ztitcsk-mwskz.

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
*&      Form  finbil_data_delete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM finbil_data_delete  USING p_count.

  DATA: l_count TYPE i.
  DATA: l_if_null TYPE REF TO if_message_obj_mm.

  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_box>,
                 <l_finno>,
                 <l_acept>,
                 <l_negno>,
                 <l_rfeno>,
                 <l_refno>,
                 <l_paysq>,
                 <l_imexi>.

  FIELD-SYMBOLS: <l_field>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.
  ASSIGN COMPONENT 'BOX'   OF STRUCTURE <ls_table> TO <l_box>.
  ASSIGN COMPONENT 'FINNO' OF STRUCTURE <ls_table> TO <l_finno>.
  ASSIGN COMPONENT 'ACEPT' OF STRUCTURE <ls_table> TO <l_acept>.
  ASSIGN COMPONENT 'IMEXI' OF STRUCTURE <ls_table> TO <l_imexi>.
  ASSIGN COMPONENT 'NEGNO' OF STRUCTURE <ls_table> TO <l_negno>.
  ASSIGN COMPONENT 'RFENO' OF STRUCTURE <ls_table> TO <l_rfeno>.
  ASSIGN COMPONENT 'REFNO' OF STRUCTURE <ls_table> TO <l_refno>.
  ASSIGN COMPONENT 'PAYSQ' OF STRUCTURE <ls_table> TO <l_paysq>.

  CLEAR: p_count.

  CALL FUNCTION 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
    EXPORTING
     textline1           = '선택한 계산서 내역들을 삭제합니다.'
     textline2           = '정말로 삭제하시겠습니까?'
      titel               = '삭제확인'
*         DEFAULTOPTION       = 'N'
   IMPORTING
     answer              = g_answer .

  CHECK g_answer EQ 'J'.

  CLEAR: l_count.
  LOOP AT <gt_table> INTO <ls_table>.
    IF <l_box> EQ 'X'.
      ADD 1 TO l_count.
    ENDIF.
  ENDLOOP.
  IF l_count EQ 0.
    MESSAGE s909.    EXIT.
  ENDIF.

* Message preparations
  PERFORM  set_message_preparations.
  CLEAR: l_count.
  LOOP AT <gt_table> INTO <ls_table>.
    IF <l_box> EQ 'X'.

*>> 업무구분 검증.
      IF <l_imexi> NE 'I'.
        MESSAGE s879(zmti00) WITH <l_finno>.
        zti_message 'E' sy-msgid sy-msgno
                    sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        CONTINUE.
      ENDIF.

*>> FINBIL 문서 검증.
      SELECT SINGLE *
        FROM ztstfbk
       WHERE finno  EQ  <l_finno>.
      IF sy-subrc NE 0.
        MESSAGE s890 WITH <l_finno>.
        zti_message 'E' sy-msgid sy-msgno
                    sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        CONTINUE.
      ENDIF.
*> 기반영분 데이타 오류.
      IF <l_acept> EQ 'Y'.
        MESSAGE s707 WITH '계산서' <l_finno>.
        zti_message 'E' sy-msgid sy-msgno
                    sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        CONTINUE.
      ENDIF.
*> Begin transaction.
      SET UPDATE TASK LOCAL.
      DELETE FROM ztstfbk WHERE finno EQ <l_finno>.
      DELETE FROM ztstfbp WHERE finno EQ <l_finno>.
      COMMIT WORK.
      MESSAGE s715 WITH <l_finno>.
      zti_message 'S' sy-msgid sy-msgno
                  sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ADD 1 TO l_count.
*> 검색조건에 해당하는 데이타를 Select.
    ENDIF.
  ENDLOOP.
*> 오류정보가 존재시 메시지 상자 POPUP.
  g_line = g_message_handler->get_severity_bo(
                          im_business_obj          = l_if_null
                          im_include_child_objects = 'X' ).

  IF g_line GT 0.
    CALL METHOD g_message_handler->show( im_popup = 'X'
      im_amodal = space ).
  ENDIF.

  p_count = l_count.

ENDFORM.                    " finbil_data_delete
*&---------------------------------------------------------------------*
*&      Form  set_finbil_data_modify
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_finbil_data_modify .

  clear: ztitcsk.
  IMPORT ztitcsk FROM MEMORY ID 'ZTIR9000'.
  FREE MEMORY ID 'ZTIR9000'.

  IF NOT ztitcsk-icsno IS INITIAL.
    ADD 1 TO g_success.
    LOOP AT it_ztsvfb00.
      MOVE-CORRESPONDING it_ztsvfb00 TO it_ztstfbc.
      MOVE: ztitcsk-icsno TO it_ztstfbc-icsno,
            ztitcsk-belnr TO it_ztstfbc-belnr,
            ztitcsk-gjahr TO it_ztstfbc-gjahr,
            ztitcsk-bukrs TO it_ztstfbc-bukrs,
            'Y'           TO it_ztstfbc-sysyn.
      APPEND it_ztstfbc.
    ENDLOOP.
    SET UPDATE TASK LOCAL.

    MODIFY ztstfbc FROM TABLE it_ztstfbc.
    IF sy-subrc EQ 0.
      COMMIT WORK.
    ELSE.
      ADD 1 TO g_error.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.

ENDFORM.                    " set_finbil_data_modify
*&---------------------------------------------------------------------*
*&      Form  set_finbil_data_modify_by_rec
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_finbil_data_modify_by_rec  USING p_ztsvfb00 STRUCTURE ztsvfb00.

  REFRESH it_ztstfbc.
  IMPORT ztitcsk FROM MEMORY ID 'ZTIR9000'.
  FREE MEMORY ID 'ZTIR9000'.

  IF NOT ztitcsk-icsno IS INITIAL.
    ADD 1 TO g_success.
    MOVE-CORRESPONDING p_ztsvfb00 TO it_ztstfbc.
    MOVE: ztitcsk-icsno TO it_ztstfbc-icsno,
          ztitcsk-belnr TO it_ztstfbc-belnr,
          ztitcsk-gjahr TO it_ztstfbc-gjahr,
          ztitcsk-bukrs TO it_ztstfbc-bukrs,
          'Y'           TO it_ztstfbc-sysyn.
    APPEND it_ztstfbc.
    SET UPDATE TASK LOCAL.

    MODIFY ztstfbc FROM TABLE it_ztstfbc.
    IF sy-subrc EQ 0.
      COMMIT WORK.
    ELSE.
      ADD 1 TO g_error.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.

ENDFORM.                    " set_finbil_data_modify_by_rec
