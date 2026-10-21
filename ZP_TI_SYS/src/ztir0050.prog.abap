************************************************************************
*                                                                      *
* Title         : ZTIR0050                                             *
*                                                                      *
* Description   : [Report] Forwarder 지정 프로그램                     *
*                                                                      *
* Creation Date : 2004/04/27                                           *
*                                                                      *
* Author        : Seog Bong, Kang                                      *
*                                                                      *
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
* 2023.04.13   ZITCS4HDEV04                ABAP Language version       *
*                                          Standard ABAP으로 변경      *
*                                                                      *
************************************************************************
PROGRAM   ztir0050
          MESSAGE-ID zmti00
          NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis.   "> Globale Type(ALV)

************************************************************************
* User Included                                                        *
************************************************************************
INCLUDE <icon>.
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: l_yn    type c.
INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: ztitrqk,
        ztitrqs,
        ztitpnk,
        ztislc04,
        ztitig10,
        ztstig3,
        sscrfields,
        dfies .    ">DD Interface: Table Fields for DDIF_FIELDINFO_GET

************************************************************************
* Internal Tables                                                      *
************************************************************************
TYPES: BEGIN OF ty_list.
        INCLUDE STRUCTURE ztivrq04.
TYPES: color      TYPE slis_t_specialcol_alv.
TYPES: END OF ty_list.

DATA: it_list      TYPE STANDARD TABLE OF ty_list,
      gs_list      TYPE ty_list,
      ls_list      TYPE ty_list.

DATA: BEGIN OF it_ztivrq04 OCCURS 0.
        INCLUDE STRUCTURE ztivrq04.
DATA: END OF it_ztivrq04.

*-----------------------------------------------------------------------
*> 포워더 관리 테이블 컨트롤용.
*-----------------------------------------------------------------------
*  data declaration for tablecontrol 'TC_2000' definition of ddic-table
TABLES:   ztitlc4.

* type for the data of tablecontrol 'TC_2000'
TYPES: BEGIN OF t_tc_2000.
        INCLUDE STRUCTURE ztislc04.
TYPES: END OF t_tc_2000.

* internal table for tablecontrol 'TC_2000'
DATA:     g_tc_2000_itab   TYPE t_tc_2000 OCCURS 0,
          g_tc_2000_wa     TYPE t_tc_2000. "work area
DATA:     g_tc_2000_copied.           "copy flag

* declaration of tablecontrol 'TC_2000' itself
CONTROLS: tc_2000 TYPE TABLEVIEW USING SCREEN 2000.

* lines of tablecontrol 'TC_2000'
DATA:     g_tc_2000_lines  LIKE sy-loopc.

*> 선적국가별 포워더.
DATA: BEGIN OF it_ztitig10 OCCURS 10.
        INCLUDE STRUCTURE ztivig10.
DATA: END   OF it_ztitig10.

DATA: BEGIN OF ftab OCCURS 0,
        fcode LIKE rsmpe-func,
      END   OF ftab.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
DATA: l_count TYPE i.


***********************************************************************
* SELECT-OPTIONS / PARAMETERS
***********************************************************************
SELECTION-SCREEN BEGIN OF BLOCK dbsel WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_bukrs  FOR ztitrqk-bukrs                   "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk,
  s_ekorg  FOR ztitrqk-ekorg,                  "구매조직.
  s_ekgrp  FOR ztitrqk-ekgrp,                  "구매그룹.
  s_reqno  FOR ztitrqk-reqno                   "수입의뢰 관리번호.
                    MEMORY ID ztireqno,
  s_amdsq  FOR ztitrqs-amdsq                   "Amend 차수.
                    MEMORY ID ztiamdsq,
  s_reqty  FOR ztitrqk-reqty,                  "수입의뢰 종류.
  s_ilcty  FOR ztitrqk-ilcty,                  "신용장 종류.
  s_lifnr  FOR ztitrqk-lifnr,                  "공급업체 계정번호.
  s_reqdt  FOR ztitrqs-reqdt MODIF ID req,     "개설희망일자.
  s_appun  FOR ztitrqs-appun MODIF ID req,     "개설의뢰 요청자.
  s_appdt  FOR ztitrqs-appdt MODIF ID req,     "개설의뢰 요청일.
  s_accun  FOR ztitrqs-accun MODIF ID apy,     "요청접수 담당자.
  s_accdt  FOR ztitrqs-accdt MODIF ID apy,     "요청접수일자.
  s_sndun  FOR ztitrqs-sndun MODIF ID sed,     "개설신청자.
  s_snddt  FOR ztitrqs-snddt MODIF ID sed,     "개설신청일.
  s_rcvun  FOR ztitrqs-rcvun MODIF ID opn,     "개설등록자.
  s_rcvdt  FOR ztitrqs-rcvdt MODIF ID opn,     "개설등록일자.
  s_pspnr  FOR ztitrqk-pspnr.                  "프로젝트코드.
*> 리스트 현황.
SELECTION-SCREEN ULINE.
PARAMETERS: p_step1 RADIOBUTTON GROUP ab1,
            p_step2 RADIOBUTTON GROUP ab1 DEFAULT 'X',
            p_step3 RADIOBUTTON GROUP ab1.
*> 기타 검색 조건.
SELECTION-SCREEN ULINE.
SELECT-OPTIONS:
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
SELECTION-SCREEN END OF BLOCK dbsel.

SELECTION-SCREEN BEGIN OF BLOCK dbsel2 WITH FRAME TITLE text-004.
PARAMETERS: p_full RADIOBUTTON GROUP ab2 DEFAULT 'X',
            p_list RADIOBUTTON GROUP ab2.
SELECTION-SCREEN END OF BLOCK dbsel2.

SELECTION-SCREEN: BEGIN OF BLOCK alv WITH FRAME TITLE text-003.
PARAMETERS: alv_def LIKE disvariant-variant.
SELECTION-SCREEN: END OF BLOCK alv.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
** JS전선 회사코드 2007/04 KSH --------------------------------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
** JS전선 회사코드 2007/04 KSH --------------------------------------
    c_save(1)   TYPE  c             VALUE 'A'.

************************************************************************
* Internal Tables                                                      *
************************************************************************
*> 공급업체명
DATA : BEGIN OF xlfa1 OCCURS 0,
       lifnr           LIKE   lfa1-lifnr,
       name1           LIKE   lfa1-name1.
DATA : END   OF xlfa1.


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
       g_disp_mode(1)  TYPE   c,
       g_fieldgroup(12) TYPE c,
       g_find          TYPE i,
       g_findscr       LIKE sy-dynnr,
       g_findline      TYPE i,
       g_fieldname(20) TYPE c,
       g_count         TYPE i,
       ok_code         LIKE sy-ucomm,
       line_cnt(02)    TYPE n,
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
*> 사용자 Input values Check
  PERFORM check_input_values.
*> 사용자 레이아웃 Input values Check
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
  PERFORM create_dynamic_table.    ">
  PERFORM get_data_for_display.    ">data select

************************************************************************
*                                                                      *
* END-OF-SELECTION Event                                               *
*                                                                      *
************************************************************************
END-OF-SELECTION.
*>--------------------------------------------------------
*> PROGRESS INDICATOR DISPLAY.
*>  4.  LIST DISPLAY
*>--------------------------------------------------------
  CHECK g_line NE 0.
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

  SET TITLEBAR 'T1000'.

** 진로산업 Change 2007/04 --------------------------------------
*  FREE: s_bukrs.    CLEAR: s_bukrs.
*  s_bukrs-sign   = 'I'.
*  s_bukrs-option = 'EQ'.
*  s_bukrs-low    = c_bukrs.
*  APPEND s_bukrs.
** 진로산업 Change 2007/04 --------------------------------------

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
*&      Form  CLEARING_WORK_AREA
*&---------------------------------------------------------------------*
FORM clearing_work_area.

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

  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.
  FIELD-SYMBOLS: <l_field3>.

  REFRESH : <gt_table>.

  DATA:  l_count     TYPE  i,
         l_reqno     TYPE ztireqno,
         l_opamt     LIKE ztitrqs-opamt.

  REFRESH: it_ztivrq04.

*> PROGRESS Display.
  g_line1    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_line1.

*> 수입의뢰 데이타 select.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE <gt_table>
    FROM ztivrq04
   WHERE bukrs  IN  s_bukrs        "회사코드.
     AND ekorg  IN  s_ekorg        "구매조직.
     AND ekgrp  IN  s_ekgrp        "구매그룹.
     AND reqty  NE  'LO'
     AND reqty  NE  'PU'
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
     AND pspnr  IN  s_pspnr        "공사번호.
     AND reqdt  IN  s_reqdt        "개설희망일자.
     AND appun  IN  s_appun        "개설의뢰 요청자.
     AND appdt  IN  s_appdt        "개설의뢰 요청일.
     AND accun  IN  s_accun        "요청접수 담당자.
     AND accdt  IN  s_accdt        "요청접수일자.
     AND sndun  IN  s_sndun        "개설신청자.
     AND snddt  IN  s_snddt        "개설신청일.
     AND rcvun  IN  s_rcvun        "개설등록자.
     AND rcvdt  IN  s_rcvdt        "개설등록일자.
     AND opnno  IN  s_opnno        "수입개설번호
     AND opndt  IN  s_opndt        "개설일자.
     AND cnam   IN  s_cnam         "작성인.
     AND cdat   IN  s_cdat         "생성일.
     AND unam   IN  s_unam         "최종변경인.
     AND udat   IN  s_udat.        "변경일

  IF sy-subrc NE 0.
    MESSAGE s902.
  ENDIF.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.

  LOOP AT <gt_table> INTO <ls_table>.
    g_tabix = sy-tabix.
    ASSIGN COMPONENT 'LIFNR' OF STRUCTURE
                        <ls_table> TO <l_field2>.
    ASSIGN COMPONENT 'NAME1' OF STRUCTURE
                        <ls_table> TO <l_field1>.
    IF sy-subrc EQ 0.
      SELECT SINGLE name1
        INTO <l_field1>
        FROM lfa1
       WHERE lifnr  EQ  <l_field2>.
    ENDIF.

    ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                        <ls_table> TO <l_field1>.
    IF sy-subrc EQ 0.
      ASSIGN COMPONENT 'FWDAS' OF STRUCTURE
                          <ls_table> TO <l_field2>.
      ASSIGN COMPONENT 'ICON'  OF STRUCTURE
                          <ls_table> TO <l_field3>.
      SELECT reqno
        INTO l_reqno
        FROM ztitlc4 UP TO 1 ROWS
       WHERE reqno EQ <l_field1>.
      ENDSELECT.
      IF sy-subrc EQ 0.
        <l_field2> = 'X'.
        <l_field3> = icon_green_light.
      ELSE.
        <l_field2> = space.
        <l_field3> = icon_red_light.
      ENDIF.
    ENDIF.

    CASE 'X'.
      WHEN p_step1.
        IF <l_field2> EQ space.
          DELETE <gt_table> INDEX g_tabix.
          CONTINUE.
        ENDIF.
      WHEN p_step2.
        IF <l_field2> EQ 'X'.
          DELETE <gt_table> INDEX g_tabix.
          CONTINUE.
        ENDIF.
      WHEN p_step3.

    ENDCASE.

    MODIFY <gt_table> FROM <ls_table>.

  ENDLOOP.

*
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

  ac 'ITAB   BOX   ZTISRQIT                     FLAG  X'.
  ac 'ITAB   FWDAS ZTITRQK                      FWDAS X'.
  ac 'ITAB   ICON  ZTISLCCS                     ICON  '.
  ac 'ITAB   REQNO ZTITRQS                      REQNO '.
  ac 'ITAB   AMDSQ ZTITRQS                      AMDSQ '.
  ac 'ITAB   REQTY ZTITRQK                      REQTY '.
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* 2004.10.20   Sung-ho Maeng                사용여부 check.            *
*----------------------------------------------------------------------*
*  ac 'ITAB   PSPNR ZTITRQK                      PSPNR '.  " 사용안함
*----------------------------< INSERT END >----------------------------*
  ac 'ITAB   LIFNR ZTITRQK                      LIFNR '.
  ac 'ITAB   NAME1 LFA1                         NAME1 '.
  ac 'ITAB   OPAMT ZTITRQS                      OPAMT  CWAERS '.
  ac 'ITAB   WAERS ZTITRQS                      WAERS '.
  ac 'ITAB   USAMT ZTITRQS                      USAMT  CUCURR '.
  ac 'ITAB   UCURR ZTITRQS                      UCURR '.
  ac 'ITAB   ZTERM ZTITRQS                      ZTERM '.
  ac 'ITAB   REQDT ZTITRQS                      REQDT '.
  ac 'ITAB   INCO1 ZTITRQS                      INCO1 '.

*> Create field catagory table
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZTIVRQ04'
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
      WHEN 'REQNO' OR 'AMDSQ'.
        fcs-hotspot = 'X'.
        fcs-key     = 'X'.
      WHEN 'OPAMT' OR 'USAMT'.
        fcs-do_sum = 'X'.
      WHEN 'ICON'.
        fcs-do_sum = 'X'.
        fcs-seltext_l = '지정상태'.
        fcs-seltext_m = '지정상태'.
        fcs-seltext_s = '지정상태'.
        fcs-ddictxt   = 'S'.
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

  SET TITLEBAR 'T1000'.

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

*  gs_layout-colwidth_optimize = 'X'.
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

  SET PF-STATUS 'STANDARD' EXCLUDING extab.

ENDFORM.                    " SET_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  USER_ALV_COMMAND
*&---------------------------------------------------------------------*
FORM user_alv_command USING   r_ucomm      LIKE sy-ucomm
                              rs_selfield  TYPE slis_selfield.
*
  DATA: l_count   TYPE i.
  DATA: l_subrc   LIKE sy-subrc.
  DATA: l_tcode   LIKE sy-tcode.
  DATA: l_reqno   TYPE ztireqno.
  DATA: l_amdsq   TYPE ztiamdsq.
  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_field>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.

  CASE r_ucomm.
    WHEN 'ZTIASSIGN' OR 'ZTIDISPLAY'.
      ASSIGN COMPONENT 'BOX' OF STRUCTURE
                            <ls_table> TO <l_field>.
      ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                            <ls_table> TO <l_field1>.
      ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
                            <ls_table> TO <l_field2>.
      IF sy-subrc EQ 0.
        CLEAR: l_count.
        LOOP AT <gt_table> INTO <ls_table>.
          IF <l_field> EQ 'X'.
            ADD 1 TO l_count.
            l_reqno = <l_field1>.
            l_amdsq = <l_field2>.
          ENDIF.
        ENDLOOP.
        CASE l_count.
          WHEN 1.
          WHEN 0.       MESSAGE s909.  EXIT.
          WHEN OTHERS.  MESSAGE s929.  EXIT.
        ENDCASE.
*> 수입의뢰 헤더 READ.
        SELECT SINGLE *
          FROM ztitrqk
         WHERE reqno EQ l_reqno.
*> 수입의뢰 상태 READ.
        SELECT SINGLE *
          FROM ztitrqs
         WHERE reqno EQ l_reqno
           AND amdsq EQ l_amdsq.

*> 포워더 관리.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE g_tc_2000_itab
          FROM ztitlc4
         WHERE reqno  EQ l_reqno.

        LOOP AT g_tc_2000_itab INTO g_tc_2000_wa.
          SELECT SINGLE name1
            INTO g_tc_2000_wa-name1
            FROM lfa1
           WHERE lifnr EQ g_tc_2000_wa-fwdcd.

          MODIFY ztitlc4 FROM g_tc_2000_wa.
        ENDLOOP.

        IF r_ucomm EQ 'ZTIASSIGN'.
          g_disp_mode = space.
        ELSEIF r_ucomm EQ 'ZTIDISPLAY'.
          g_disp_mode = 'X'.
        ENDIF.

        CLEAR: g_tc_2000_copied.
        CALL SCREEN 2000 STARTING AT 1 1.
        IF g_subrc EQ 0.
          PERFORM get_data_for_display.    ">data select
          rs_selfield-refresh = 'X'.
        ENDIF.
      ENDIF.

    WHEN 'DISPLAY' OR '&IC1'.    " AUF DOPPELKLICK REAGIERIEN
      CHECK rs_selfield-tabindex GT 0.

      READ TABLE <gt_table> INTO <ls_table> INDEX rs_selfield-tabindex.
      IF sy-subrc NE 0.
        MESSAGE s906.            EXIT.
      ENDIF.
      ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                            <ls_table> TO <l_field1>.
      ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
                            <ls_table> TO <l_field2>.

      CASE rs_selfield-fieldname.
        WHEN 'REQNO' OR 'AMDSQ'.
          PERFORM display_import_document(ztir0000)
                               USING <l_field1> <l_field2> '00000'.
        WHEN OTHERS.              ">해당작업수행..
          PERFORM display_import_document(ztir0000)
                               USING <l_field1> <l_field2> '00000'.

      ENDCASE.

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

  CLEAR  st_sort.
  st_sort-spos = '01'.
  st_sort-fieldname = 'REQNO'.
  st_sort-tabname   = 'IT_LIST'.
  st_sort-up        = 'X'.
*  ST_SORT-GROUP     = 'X'.
*  st_sort-subtot    = 'X'.
*  ST_SORT-EXPA      = 'X'.
  APPEND st_sort TO it_sort.
*
  CLEAR  st_sort.
  st_sort-spos = '01'.
  st_sort-fieldname = 'AMDSQ'.
  st_sort-tabname   = 'IT_LIST'.
  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
**  ST_SORT-SUBTOT    = 'X'.
**  ST_SORT-EXPA      = 'X'.
  APPEND st_sort TO it_sort.
*
*  CLEAR  st_sort.
*  st_sort-spos = '03'.
*  st_sort-fieldname = 'EBELN'.
*  st_sort-tabname   = 'ITAB'.
*  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
**  ST_SORT-SUBTOT    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.

ENDFORM.                    " SET_SORT_FIELD

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM top_of_page.

  DATA: l_mode TYPE i.
  DATA: header TYPE slis_listheader OCCURS 0 WITH HEADER LINE.

  REFRESH header.
  header-typ = 'H'.
  header-info = '포워더 지정 현황'.

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

*  FIELD-SYMBOLS: <ls_table>.
*
*  READ TABLE <gt_table> INTO <ls_table>
*                        INDEX rs_selfield-tabindex. "cursorposit.
*  IF sy-subrc EQ 0.
**    MOVE-CORRESPONDING <ls_table> TO xitab.
**
**    READ TABLE organ WITH KEY werks = xitab-werks.
**
**    SET PARAMETER ID 'MAT' FIELD xitab-matnr.
**    SET PARAMETER ID 'BUK' FIELD organ-bukrs.
**    SET PARAMETER ID 'WRK' FIELD xitab-werks.
*    SET PARAMETER ID 'LAG' FIELD ''.
**  SET PARAMETER ID 'MXX' FIELD 'KDEALBSZXVPCFQG'.
*    SET PARAMETER ID 'MXX' FIELD 'KDE'.
*
*    CALL TRANSACTION 'MM03' AND SKIP  FIRST SCREEN.
*  ELSE.
*    MESSAGE s901.
*  ENDIF.

ENDFORM.                    " MATERIAL_MASTER_DISPLAY

*&---------------------------------------------------------------------*
*&      Form  set_colorize_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_colorize_build .

  DATA: color TYPE slis_t_specialcol_alv WITH HEADER LINE.
*> colorize
  LOOP AT it_list INTO gs_list.

*    color-color-col = 4.
*    color-color-int = 0.
*    color-fieldname = 'RTCHG'.
*    APPEND color.
*
*    color-color-col = 5.
*    color-color-int = 0.
*    color-fieldname = 'RTCHGS'.
*    APPEND color.

    gs_list-color[] = color[].

    MODIFY it_list FROM gs_list .
  ENDLOOP.

ENDFORM.                    " set_colorize_build

*&---------------------------------------------------------------------*
*&      Form  SET_INITAIL_IP_BATCHDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_initail_ip_batchdata .

ENDFORM.                    " SET_INITAIL_IP_BATCHDATA
*&---------------------------------------------------------------------*
*&      Form  check_input_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_input_values .

  DATA: l_bukrs   LIKE t001-bukrs.

* Company code
  SELECT bukrs INTO (l_bukrs) UP TO 1 ROWS
               FROM t001 WHERE bukrs IN s_bukrs.
  ENDSELECT.
  IF sy-subrc <> 0.
    PERFORM get_ftext(rddfie00) USING 'T001' 'BUKRS' sy-langu
                                CHANGING dfies g_subrc.
    SET CURSOR FIELD 'P_BUKRS'.
    MESSAGE e348(m7) WITH dfies-scrtext_m.
  ENDIF.

ENDFORM.                    " check_input_values
*&---------------------------------------------------------------------*
*&      Form  adjust_fieldcat
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
              'ZTIVRQ04'                  TO fcs-ref_tabname.
        CLEAR: fcs-key.
        fcs-no_out = 'X'.
        APPEND fcs TO fc.
      ENDIF.
    ENDIF.
    DESCRIBE TABLE fc LINES g_line.
    IF g_line GT 50.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " adjust_fieldcat
*&---------------------------------------------------------------------*
*&      Form  create_dynamic_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
*&      Form  double_click_event
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM double_click_event .

  CHECK g_fieldname IS INITIAL.

  GET CURSOR LINE g_findline.
  IF sy-subrc EQ 0.
    GET CURSOR FIELD g_fieldname.
    IF sy-subrc EQ 0.
      g_findscr  = sy-dynnr.
      g_findline = g_findline + tc_2000-top_line - 1.
    ENDIF.
  ELSE.
    GET CURSOR FIELD g_fieldname.
    IF sy-subrc EQ 0.
      g_findscr = sy-dynnr.
    ENDIF.
  ENDIF.

ENDFORM.                    " double_click_event



*eject
************************************************************************
*                                                                      *
* P B O   M O D U L E                                                  *
*                                                                      *
************************************************************************


*&---------------------------------------------------------------------*
*&      Module  tc_2000_init  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_2000_init OUTPUT.

  FREE ftab.

  MOVE 'BACK'      TO ftab-fcode.   APPEND ftab. ">개요펼치기.

  IF g_disp_mode EQ 'X'.
    MOVE 'BU'      TO ftab-fcode.   APPEND ftab. ">개요펼치기.
  ENDIF.

  SET PF-STATUS '2000' EXCLUDING ftab.

  IF g_tc_2000_copied IS INITIAL.
    g_tc_2000_copied = 'X'.
    REFRESH CONTROL 'TC_2000' FROM SCREEN '2000'.
  ENDIF.

ENDMODULE.                 " tc_2000_init  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2000_get_lines  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_2000_get_lines OUTPUT.

*  g_TC_2000_lines = sy-loopc.
  IF g_disp_mode EQ 'X'.
    DESCRIBE TABLE g_tc_2000_itab LINES g_line.     " LINE COUNT GET
    g_tc_2000_lines = g_line.                       " LINE DEFINE
    tc_2000-lines   = g_line.
  ELSE.
    DESCRIBE TABLE g_tc_2000_itab LINES g_line.     " LINE COUNT GET
    g_line = g_line + 20.
    g_tc_2000_lines = g_line.                       " LINE DEFINE
    tc_2000-lines   = g_line.
  ENDIF.

ENDMODULE.                 " tc_2000_get_lines  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2000_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_2000_change_field_attr OUTPUT.

  LOOP AT SCREEN.
    IF screen-name EQ 'G_TC_2000_WA-FLAG'.
      screen-input = '1'.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " tc_2000_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2000_move  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_2000_move OUTPUT.

  MOVE-CORRESPONDING : g_tc_2000_wa TO ztitlc4,
                       g_tc_2000_wa TO ztislc04.

ENDMODULE.                 " tc_2000_move  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  change_field_attribute  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_field_attribute OUTPUT.

  LOOP AT  SCREEN .
    CLEAR g_fieldgroup.
    CONCATENATE screen-group1 screen-group2
                screen-group3 screen-group4
           INTO g_fieldgroup.

    IF g_disp_mode EQ 'X'.
      SEARCH g_fieldgroup FOR 'S'.
    ELSE.
      SEARCH g_fieldgroup FOR 'A'.
    ENDIF.
    IF sy-subrc <> 0.
      screen-input = '0'.
    ELSE.
      screen-input = '1'.
    ENDIF.

    IF screen-name EQ 'G_TC_2130_WA-FLAG'.
      screen-input = '1'.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " change_field_attribute  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_position  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_position OUTPUT.

  CHECK NOT g_findscr IS INITIAL.

  CHECK g_findscr EQ sy-dynnr.

  IF g_findline IS INITIAL.
    SET CURSOR FIELD g_fieldname.
  ELSE.
    SET CURSOR FIELD g_fieldname LINE g_findline.
  ENDIF.

  g_subrc = 4.
  CLEAR: ok_code.

ENDMODULE.                 " set_cursor_position  OUTPUT


*eject
************************************************************************
*                                                                      *
* P A I   M O D U L E                                                  *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&      Module  tc_2000_modify  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_2000_modify INPUT.

  IF ztitlc4-land1 IS INITIAL AND
     ztitlc4-fwdcd IS INITIAL AND
     ztitlc4-fwdty IS INITIAL.
  ENDIF.

*> 선적국가.
  IF ztitlc4-land1 IS INITIAL.
    PERFORM no_input_check(ztir0000) USING 'ZTITLC4' 'LAND1' 'E'.
  ENDIF.

*> 포워더 코드.
  IF ztitlc4-fwdcd IS INITIAL.
    PERFORM no_input_check(ztir0000) USING 'ZTITLC4' 'FWDCD' 'E'.
  ENDIF.
  SELECT  SINGLE name1
    INTO  ztislc04-name1
    FROM  lfa1
   WHERE  lifnr  EQ  ztitlc4-fwdcd.
  IF sy-subrc NE 0.
    PERFORM message_not_found_vendor(ztir0000) USING 'ZTITLC4'
                                                     'FWDCD'
                                                     'E'.
  ENDIF.
*> 포워더 관리 테이블 CHECK.
  SELECT SINGLE *
    FROM ztitig10
   WHERE fwdcd  EQ  ztitlc4-fwdcd
     AND land1  EQ  ztitlc4-land1.

  IF sy-subrc NE 0.
    SET CURSOR FIELD 'ZTITLC4-FWDCD'.
    MESSAGE e128 WITH ztitlc4-land1 ztislc04-name1.
  ENDIF.
*> 운송방법.
  IF ztitlc4-fwdty IS INITIAL.
    PERFORM no_input_check(ztir0000) USING 'ZTITLC4' 'FWDTY' 'E'.
  ENDIF.

  MOVE-CORRESPONDING ztitlc4 TO g_tc_2000_wa.
  MOVE ztislc04-name1         TO g_tc_2000_wa-name1.

  MODIFY g_tc_2000_itab
    FROM g_tc_2000_wa
    INDEX tc_2000-current_line.

  IF sy-subrc NE 0.
    APPEND g_tc_2000_wa TO g_tc_2000_itab.
  ENDIF.

ENDMODULE.                 " tc_2000_modify  INPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2000_mark  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_2000_mark INPUT.

  IF tc_2000-line_sel_mode = 1 AND
     g_tc_2000_wa-flag = 'X'.
    LOOP AT g_tc_2000_itab INTO g_tc_2000_wa
      WHERE flag = 'X'.
      g_tc_2000_wa-flag = ''.
      MODIFY g_tc_2000_itab
        FROM g_tc_2000_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tc_2000_wa-flag = 'X'.
  ENDIF.

  MODIFY g_tc_2000_itab
    FROM g_tc_2000_wa
    INDEX tc_2000-current_line
    TRANSPORTING flag.

ENDMODULE.                 " tc_2000_mark  INPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2000_user_command  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_2000_user_command INPUT.

*> 순번 build.
  CLEAR: g_count.
  LOOP AT g_tc_2000_itab INTO g_tc_2000_wa.
    ADD 1 TO g_count.
    g_tc_2000_wa-fwdsq = g_count.
    g_tc_2000_wa-reqno = ztitrqk-reqno.
    MODIFY g_tc_2000_itab FROM g_tc_2000_wa.
  ENDLOOP.

  ok_code = sy-ucomm.
  PERFORM user_ok_tc(ztir0000) USING    'TC_2000'
                                        'G_TC_2000_ITAB'
                                        'FLAG'
                               CHANGING ok_code.
  sy-ucomm = ok_code.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.

  CASE ok_code.
    WHEN 'TC_2000_DISPLAY'.
      PERFORM display_import_document(ztir0000)
                           USING ztitrqs-reqno ztitrqs-amdsq '00000'.

    WHEN 'ABBR'.
      g_subrc = 4.
      MESSAGE s900.
      LEAVE TO SCREEN 0.
    WHEN 'BU'.
*> 포워더 정보.
      SET UPDATE TASK LOCAL.
      DELETE FROM ztitlc4 WHERE reqno EQ ztitrqs-reqno.
      CLEAR: g_count.
      LOOP AT g_tc_2000_itab INTO g_tc_2000_wa.
        ADD 1 TO g_count.
        g_tc_2000_wa-mandt = ztitrqs-mandt.
        g_tc_2000_wa-reqno = ztitrqs-reqno.
        g_tc_2000_wa-fwdsq = g_count.
        MODIFY g_tc_2000_itab FROM g_tc_2000_wa.
      ENDLOOP.
      IF sy-subrc EQ 0.
        MODIFY ztitlc4  FROM TABLE g_tc_2000_itab.
        IF sy-subrc NE 0.
          ROLLBACK WORK.   MESSAGE e912.
        ENDIF.
      ELSE.
        ROLLBACK WORK.     MESSAGE e030.
      ENDIF.
      COMMIT WORK.
      MESSAGE s105 WITH ztitrqs-reqno ztitrqs-amdsq.
      g_subrc = 0.
      LEAVE TO SCREEN 0.
    WHEN 'BACK'.
      g_subrc = 4.
      MESSAGE s900.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
  CLEAR: ok_code.
ENDMODULE.                 " tc_2000_user_command  INPUT
*&---------------------------------------------------------------------*
*&      Module  fcode_exit_scr2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fcode_exit_scr2000 INPUT.

  g_subrc = 4.
  MESSAGE s900.
  LEAVE TO SCREEN 0.

ENDMODULE.                 " fcode_exit_scr2000  INPUT
