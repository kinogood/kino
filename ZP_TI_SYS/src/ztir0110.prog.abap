************************************************************************
*                                                                      *
* Title         : ZTIR0110                                             *
*                                                                      *
* Description   : [Report] 통화별 L/C OPEN 현황 Report                 *
*                                                                      *
* Creation Date : 2004/10/11                                           *
*                                                                      *
* Author        : Soo Ho, Yoon.                                        *
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
*                                                                      *
*                                                                      *
************************************************************************
PROGRAM   ztir0110
          MESSAGE-ID zmti00
          NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis.   "> Globale Type(ALV)
TYPES: int13 TYPE i.
TYPES: BEGIN OF ty_selt.
TYPES: bukrs  LIKE  ztivrq04-bukrs,
*       werks  LIKE  t001w-werks,  "플랜트
       reqno  LIKE  ztivrq04-reqno,   "관리번호
       amdsq  LIKE  ztivrq04-amdsq,   "회차
       reqty  LIKE  ztivrq04-reqty,   "요청종류
       ilcty  LIKE  ztivrq04-ilcty,   "신용장종류
       reqdt  LIKE  ztivrq04-reqdt,   "희망일
       snddt  LIKE  ztivrq04-snddt,   "신청일
       opndt  LIKE  ztivrq04-opndt,   "개설일
       opnno  LIKE  ztivrq04-opnno,   "개설번호
       waers  LIKE  ztivrq04-waers,
       opamt  LIKE  ztivrq04-opamt.
TYPES: END OF ty_selt.

TYPES: BEGIN OF ty_col.
TYPES: waers  LIKE  ztitrqs-waers,
       buscl  LIKE  ztitrqs-buscl,
       opamt  LIKE  ztitrqs-opamt, "
       usamt  LIKE  ztitrqs-usamt.
TYPES: END OF ty_col.

TYPES: BEGIN OF ty_col2.
TYPES: waers  LIKE  ztitrqs-waers,
       opamt  LIKE  ztitrqs-opamt, "
       usamt  LIKE  ztitrqs-usamt.
TYPES: END OF ty_col2.

TYPES: BEGIN OF ty_lcst.
        INCLUDE STRUCTURE ztitrqs.
TYPES: END OF ty_lcst.

*TYPES: BEGIN OF ty_disp.
*        INCLUDE STRUCTURE zmispohis.
*TYPES: box        TYPE c,
*       color      TYPE slis_t_specialcol_alv.
*TYPES: END OF ty_disp.

************************************************************************
* User Included                                                        *
************************************************************************
*INCLUDE zmi_reuse_bdc_subroutine_f00.
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: l_yn    type c.
INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: t001,      ">Company Codes
        dfies,
        ztislcw,
        ztivrq04.  ">수입의뢰 Views(Header + Items) : 최종회차별

TABLES: icon,
        s031,
        bapi1093_0,
        bapicurx,
        bapiret1.

************************************************************************
* Internal Tables  & Structure
************************************************************************
DATA: it_selt TYPE STANDARD TABLE OF ty_selt,
      gs_selt TYPE ty_selt,
      ls_selt TYPE ty_selt.

*DATA: it_list      TYPE STANDARD TABLE OF ty_list,
*      gs_list      TYPE ty_list,
*      ls_list      TYPE ty_list.

DATA: it_col       TYPE STANDARD TABLE OF ty_col,
      gs_col       TYPE ty_col,
      ls_col       TYPE ty_col.

DATA: it_col2       TYPE STANDARD TABLE OF ty_col2,
      gs_col2       TYPE ty_col2,
      ls_col2       TYPE ty_col2.

DATA: it_lcst       TYPE STANDARD TABLE OF ty_lcst,
      gs_lcst       TYPE ty_lcst,
      ls_lcst       TYPE ty_lcst.

*DATA: it_disp      TYPE STANDARD TABLE OF ty_disp,
*      gs_disp      TYPE ty_disp,
*      ls_disp      TYPE ty_disp.



DATA: it_fieldcat_g TYPE lvc_t_fcat,
      gs_fieldcat_g LIKE LINE OF it_fieldcat_g.


*>ALV평션 Dyanmic Table 구조체
DATA: BEGIN OF dyst,
      bukrs           LIKE  t001,
*      werks           LIKE  t001w,
*      name1           LIKE  t001w,
      opamt           LIKE  ztivrq04-opamt,
      waers           LIKE  ztivrq04-waers,
      ussum           LIKE  ztivrq04-opamt,
      usper(3)        TYPE  n,
      jpsum           LIKE  ztivrq04-opamt,
      jpper(3)        TYPE  n,
      ecsum           LIKE  ztivrq04-opamt,
      ceper(3)        TYPE  n,
      chsum           LIKE  ztivrq04-opamt,
      chper(3)        TYPE  n,
      ausum           LIKE  ztivrq04-opamt,
      auper(3)        TYPE  n,
      gbsum           LIKE  ztivrq04-opamt,
      gbper(3)        TYPE  n,
      otsum           LIKE  ztivrq04-opamt,
      otper(3)        TYPE  n,
      tosum           LIKE  ztivrq04-opamt,
      toper(3)        TYPE  n,
     END OF   dyst.

*> ALV용.
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

DATA: it_fieldcat TYPE slis_t_fieldcat_alv,
      gs_fieldcat LIKE LINE OF it_fieldcat.
************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
** JS전선 회사코드 2007/04 KSH --------------------------------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
** JS전선 회사코드 2007/04 KSH --------------------------------------
    c_save(1)   TYPE  c             VALUE 'A'.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
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
       line_cnt(02)    TYPE   n,
       field_name(20),
       field_name1(20).

*합계용.
DATA : g_total        TYPE ztitrqs-usamt.

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
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK box1 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_bukrs  FOR ztivrq04-bukrs                   "회사코드.
               NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk ,
  s_opndt  FOR ztivrq04-opndt.     "MODIF ID opn,     "개설일자.
*                OBLIGATORY.       "NO-EXTENSION NO INTERVALS
SELECTION-SCREEN : SKIP,
                   ULINE.
SELECT-OPTIONS:
  s_reqty   FOR ztivrq04-reqty.
*  s_werks   for ztitrq04-werks.              "플랜트
SELECTION-SCREEN END OF BLOCK box1.

SELECTION-SCREEN BEGIN OF BLOCK box2 WITH FRAME TITLE text-002.
PARAMETERS: p_full RADIOBUTTON GROUP ab2 MODIF ID opn,
            p_list RADIOBUTTON GROUP ab2 MODIF ID opn DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK box2.

*SELECTION-SCREEN BEGIN OF BLOCK box3 WITH FRAME TITLE text-004.
*PARAMETERS: p_cur RADIOBUTTON GROUP ab3 ,
*            p_int RADIOBUTTON GROUP ab3 DEFAULT 'X'.
*SELECTION-SCREEN END OF BLOCK box3.

*> Report variant
SELECTION-SCREEN: BEGIN OF BLOCK alv WITH FRAME TITLE text-003.
PARAMETERS: alv_def LIKE disvariant-variant.
SELECTION-SCREEN: END OF BLOCK alv.

************************************************************************
* INITIALIZATION Event                                                 *
************************************************************************
INITIALIZATION.
  PERFORM  set_initial_data.
  PERFORM  set_alv_init.             ">Initialize ALV variable

************************************************************************
* AT SELECTION-SCREEN Events                                           *
************************************************************************
*>The layout determines the list format
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_opndt-low.
*  PERFORM exec_monat_f4.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR alv_def.
  PERFORM exec_alv_f4.
******************************
AT SELECTION-SCREEN.
  PERFORM input_field_check.
  PERFORM alv_variant_check.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM p1102_authorization_check USING s_bukrs-low.
** JS전선 회사코드 2007/04 KSH --------------------------------------
******************************
*AT SELECTION-SCREEN OUTPUT.
*  LOOP AT SCREEN.
*    CHECK screen-group1 = 'OPN'.
*    screen-invisible = '1'.
*    MODIFY SCREEN.
*  ENDLOOP.
************************************************************************
* START-OF-SELECTION Event                                             *
************************************************************************
START-OF-SELECTION.
  PERFORM clearing_work_area.      ">Initialize internal table
  PERFORM set_fieldcat_build.      ">Set ALV field category
  PERFORM create_dynamic_table.    ">Dynamic Internale Table Create
  PERFORM get_data_for_display.    ">data select
************************************************************************
*                                                                      *
* END-OF-SELECTION Event                                               *
*                                                                      *
************************************************************************
END-OF-SELECTION.
*  CHECK g_line NE 0.
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

* STATUS.
  SET TITLEBAR 'T1000' WITH '통화별 L/C OPEN 현황'.

  alv_repid = sy-repid.

* Get default variant
  CLEAR s_variant.
  s_variant-report = sy-repid.
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

  DATA: l_bukrs   LIKE t001-bukrs.
*        l_werks   LIKE t001w-werks,
*        l_matnr   LIKE mara-matnr,
*        l_mtart   LIKE t134-mtart,
*        l_ebeln   LIKE ekko-ebeln,
*        l_lifnr   LIKE lfa1-lifnr,
*        l_ekorg   LIKE t024e-ekorg,
*        l_ekgrp   LIKE t024-ekgrp.

* Company code
  SELECT bukrs INTO (l_bukrs)
               FROM t001 UP TO 1 ROWS WHERE bukrs IN s_bukrs.
  ENDSELECT.
  IF sy-subrc <> 0.
    PERFORM get_ftext(rddfie00) USING 'T001' 'BUKRS' sy-langu
                                CHANGING dfies g_subrc.
    SET CURSOR FIELD 'S_BUKRS-LOW'.
    MESSAGE e348(m7) WITH '회사코드'.
  ENDIF.


ENDFORM.                    " INPUT_FIELD_CHECK
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
  FIELD-SYMBOLS: <l_bukrs>.
*  FIELD-SYMBOLS: <l_werks>.
*  FIELD-SYMBOLS: <l_name1>.
  FIELD-SYMBOLS: <l_opamt>.
  FIELD-SYMBOLS: <l_ussum>.
  FIELD-SYMBOLS: <l_usper>.
  FIELD-SYMBOLS: <l_jpsum>.
  FIELD-SYMBOLS: <l_jpper>.
  FIELD-SYMBOLS: <l_ecsum>.
  FIELD-SYMBOLS: <l_ecper>.
  FIELD-SYMBOLS: <l_chsum>.
  FIELD-SYMBOLS: <l_chper>.
  FIELD-SYMBOLS: <l_ausum>.
  FIELD-SYMBOLS: <l_auper>.
  FIELD-SYMBOLS: <l_gbsum>.
  FIELD-SYMBOLS: <l_gbper>.
  FIELD-SYMBOLS: <l_otsum>.
  FIELD-SYMBOLS: <l_otper>.
  FIELD-SYMBOLS: <l_tosum>.
  FIELD-SYMBOLS: <l_toper>.

  REFRESH : <gt_table>.

*  SELECT  * INTO CORRESPONDING FIELDS OF TABLE <gt_table>
*            FROM     ztivrq04
*           WHERE     bukrs IN  s_bukrs
*             AND     opndt IN  s_opndt
*             AND     reqty IN  s_reqty.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.
  ASSIGN COMPONENT 'BUKRS' OF STRUCTURE
                      <ls_table> TO <l_bukrs>.
*  ASSIGN COMPONENT 'WERKS' OF STRUCTURE
*                      <ls_table> TO <l_werks>.
*  ASSIGN COMPONENT 'NAME1' OF STRUCTURE
*                      <ls_table> TO <l_name1>.
  ASSIGN COMPONENT 'OPAMT' OF STRUCTURE
                      <ls_table> TO <l_opamt>.
  ASSIGN COMPONENT 'USSUM' OF STRUCTURE
                      <ls_table> TO <l_ussum>.
  ASSIGN COMPONENT 'USPER' OF STRUCTURE
                      <ls_table> TO <l_usper>.
  ASSIGN COMPONENT 'JPSUM' OF STRUCTURE
                      <ls_table> TO <l_jpsum>.
  ASSIGN COMPONENT 'JPPER' OF STRUCTURE
                      <ls_table> TO <l_jpper>.
  ASSIGN COMPONENT 'ECSUM' OF STRUCTURE
                      <ls_table> TO <l_ecsum>.
  ASSIGN COMPONENT 'ECPER' OF STRUCTURE
                      <ls_table> TO <l_ecper>.
  ASSIGN COMPONENT 'CHSUM' OF STRUCTURE
                      <ls_table> TO <l_chsum>.
  ASSIGN COMPONENT 'CHPER' OF STRUCTURE
                      <ls_table> TO <l_chper>.
  ASSIGN COMPONENT 'AUSUM' OF STRUCTURE
                      <ls_table> TO <l_ausum>.
  ASSIGN COMPONENT 'AUPER' OF STRUCTURE
                      <ls_table> TO <l_auper>.
  ASSIGN COMPONENT 'GBSUM' OF STRUCTURE
                      <ls_table> TO <l_gbsum>.
  ASSIGN COMPONENT 'GBPER' OF STRUCTURE
                      <ls_table> TO <l_gbper>.
  ASSIGN COMPONENT 'OTSUM' OF STRUCTURE
                      <ls_table> TO <l_otsum>.
  ASSIGN COMPONENT 'OTPER' OF STRUCTURE
                      <ls_table> TO <l_otper>.
  ASSIGN COMPONENT 'TOSUM' OF STRUCTURE
                      <ls_table> TO <l_tosum>.
  ASSIGN COMPONENT 'TOPER' OF STRUCTURE
                      <ls_table> TO <l_toper>.

*> PROGRESS Display.
  g_line1    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_line1.

  CLEAR g_total.
  DATA: ls_opndt   LIKE  ztitrqs-opndt,
        ls_opnd2   LIKE  ztitrqs-opndt,
        e_month(6) TYPE n.

*> 수입의뢰 데이타 select.
  SELECT bukrs reqno amdsq reqty
         ilcty reqdt snddt opndt
         opnno opamt waers
    FROM ztivrq04 INTO CORRESPONDING FIELDS OF TABLE it_selt
   WHERE bukrs  IN  s_bukrs        "회사코드.
     AND opndt  IN  s_opndt
     AND reqty  IN  s_reqty.
*     and werks  in  s_werks.

  IF sy-subrc NE 0.
    MESSAGE s902.
    EXIT.
  ENDIF.



  LOOP AT it_selt INTO gs_selt.
    MOVE-CORRESPONDING gs_selt TO <ls_table>.
*     CASE gs_selt-waers.
*      WHEN 'USD'.
*         move gs_selt-opamt to <l_ussum>.
*      WHEN 'JPY'.
*        ASSIGN COMPONENT 'JPSUM' OF STRUCTURE
*                     <ls_table> TO <l_jpsum>.
*      WHEN 'ECU'.
*        ASSIGN COMPONENT 'ECSUM' OF STRUCTURE
*                     <ls_table> TO <l_ecsum>.
*      WHEN 'CHF'.
*        ASSIGN COMPONENT 'CHSUM' OF STRUCTURE
*                     <ls_table> TO <l_chsum>.
*      WHEN 'AUD'.
*        ASSIGN COMPONENT 'AUSUM' OF STRUCTURE
*                     <ls_table> TO <l_ausum>.
*      WHEN 'GBP'.
*        ASSIGN COMPONENT 'GBSUM' OF STRUCTURE
*                     <ls_table> TO <l_gbsum>.
*      WHEN OTHERS.
*        ASSIGN COMPONENT 'OTSUM' OF STRUCTURE
*                     <ls_table> TO <l_otsum>.
*    ENDCASE.

    COLLECT  <ls_table>  INTO <gt_table>.

  ENDLOOP.

*  DESCRIBE TABLE it_list LINES g_line.
*  IF g_line EQ 0.
*    MESSAGE s902.
*  ENDIF.

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
*  DATA: l_zfcd  LIKE ztimimg08-zfcd.

*> Create field catagory table
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZTISLCW'
      i_client_never_display = 'X'
    CHANGING
      ct_fieldcat            = it_fieldcat_g[].

*>Adjust ALV field category
  PERFORM adjust_fieldcat.         ">Adjust ALV field category

  fc1[] = fc[].
**  ac 'ITAB   COLOR SLIS_T_SPECIALCOL_ALV              X'.

  LOOP AT fc1 INTO fcs.
    CLEAR: fcs-key .
    CASE fcs-fieldname.
      WHEN 'BUKRS'.
        fcs-key     = 'X'.
*         fcs-no_out = 'X'.
*      WHEN 'OPANT'.
**        fcs-no_out = 'X'.
**        fcs-do_sum = 'X'.
*      WHEN 'WAERS'.
**        fcs-no_out = 'X'.
      WHEN 'USSUM'.
        CLEAR: fcs-ref_fieldname, fcs-ref_tabname.
*        fcs-do_sum = 'X'.
        fcs-seltext_l = 'USD합계'.
        fcs-seltext_s = fcs-seltext_m = fcs-seltext_l.
      WHEN 'JPSUM'.
        CLEAR: fcs-ref_fieldname, fcs-ref_tabname.
        fcs-seltext_l = 'JPY합계'.
        fcs-seltext_s = fcs-seltext_m = fcs-seltext_l.
      WHEN 'ECSUM'.
        CLEAR: fcs-ref_fieldname, fcs-ref_tabname.
        fcs-seltext_l = 'ECU합계'.
        fcs-seltext_s = fcs-seltext_m = fcs-seltext_l.
      WHEN 'CHSUM'.
        CLEAR: fcs-ref_fieldname, fcs-ref_tabname.
        fcs-seltext_l = 'CHF합계'.
        fcs-seltext_s = fcs-seltext_m = fcs-seltext_l.
      WHEN OTHERS.

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

  SET TITLEBAR 'T1000' WITH '통화별 L/C OPEN 현황'.

* The detail ALV may modify the list (sorting). If returned to the
* base list, the original list needs to be restored.
  REFRESH fc_detail.
*  LOOP AT it_fieldcat INTO gs_fieldcat.
*    MOVE-CORRESPONDING gs_fieldcat TO fc_detail.
*    CLEAR fc_detail-tabname.
*    APPEND fc_detail.
*  ENDLOOP.
  LOOP AT fc1 INTO fcs.
    MOVE-CORRESPONDING fcs TO fc_detail.
    CLEAR fc_detail-tabname.
    APPEND fc_detail.
  ENDLOOP.

  CLEAR variant_detail.
  variant_detail-report = alv_repid.
  variant_detail-handle = ' '.

  gs_layout-colwidth_optimize = ' '.
  gs_layout-zebra             = 'X'.
*  gs_layout-box_fieldname     = 'BOX'.

*>color field define.
*  gs_layout-coltab_fieldname  = 'COLOR'.
  gs_layout-group_change_edit = 'X'.
  gs_layout-f2code            = 'DISPLAY'.

* header.
*  gs_layout-no_colhead        = 'X'.

*  GS_LAYOUT-SUBTOTALS_TEXT = 'TOTAL'.
*  gs_layout-totals_text = ' TOTAL'.

  REFRESH exit.
  exit-ucomm = '&OL0'. exit-after = 'X'. APPEND exit.
  exit-ucomm = '&OLX'. APPEND exit.
  exit-ucomm = '&OAD'. APPEND exit.

*> event define.
  REFRESH events.
  events-name = slis_ev_top_of_page.
  events-form = 'TOP_OF_PAGE'.
  APPEND events.
*
*  events-name = 'TOP_OF_LIST'.
*  events-form = 'TOP_OF_LIST'.
*  APPEND events.

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

  APPEND 'ZTIT002'  TO extab.
  APPEND 'ZTIT005'  TO extab.
  APPEND 'ZTIT006'  TO extab.

  APPEND '&OL0'  TO extab.
  APPEND '&OAD'  TO extab.
  APPEND '&AVE'  TO extab.


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

  CASE r_ucomm.
    WHEN 'ZTIT002' OR 'ZTIT005' OR 'ZTIT006'.

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

*  CLEAR  st_sort.
*  st_sort-spos = '01'.
*  st_sort-fieldname = 'REQNO'.
*  st_sort-tabname   = '<GT_TABLE>'.
*  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
*  st_sort-subtot    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.
*
*  CLEAR  st_sort.
*  st_sort-spos = '02'.
*  st_sort-fieldname = 'MTBEZ'.
*  st_sort-tabname   = 'ITAB'.
*  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
**  ST_SORT-SUBTOT    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.
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
  DATA: ls_text(10) TYPE c.
  REFRESH header.
  header-typ = 'H'.
  header-info = '통화별 L/C Open 현황'.

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
  header-key = '출력일자:'(106).
  WRITE: sy-datlo TO header-info.
  APPEND header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = header[].


ENDFORM.    ">TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  set_colorize_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_colorize_build .


ENDFORM.                    " set_colorize_build
*&---------------------------------------------------------------------*
*&      Form  EXEC_MONAT_F4
*&---------------------------------------------------------------------*
FORM exec_monat_f4 .

  DATA: BEGIN OF mf_dynpfields OCCURS 1.
          INCLUDE STRUCTURE dynpread.
  DATA: END   OF mf_dynpfields.
  DATA: mf_returncode   LIKE sy-subrc,
        mf_monat        LIKE isellist-month,
        mf_hlp_repid    LIKE sy-repid.

* Wert von Dynpro lesen
  GET CURSOR FIELD mf_dynpfields-fieldname.
  APPEND mf_dynpfields.
  mf_hlp_repid = sy-repid.
  DO 2 TIMES.
    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        dyname               = mf_hlp_repid
        dynumb               = sy-dynnr
      TABLES
        dynpfields           = mf_dynpfields
      EXCEPTIONS
        invalid_abapworkarea = 01
        invalid_dynprofield  = 02
        invalid_dynproname   = 03
        invalid_dynpronummer = 04
        invalid_request      = 05
        no_fielddescription  = 06
        undefind_error       = 07.
    IF sy-subrc = 3.
      mf_hlp_repid = sy-repid.
    ELSE.
      READ TABLE mf_dynpfields INDEX 1.
      TRANSLATE mf_dynpfields-fieldvalue USING '_ '.
      EXIT.
    ENDIF.
  ENDDO.
  IF sy-subrc = 0.
    CALL FUNCTION 'CONVERSION_EXIT_PERI_INPUT'
      EXPORTING
        input         = mf_dynpfields-fieldvalue
      IMPORTING
        output        = mf_monat
      EXCEPTIONS
        error_message = 1.
    IF sy-subrc NE 0.
      EXIT.
    ENDIF.

    IF mf_monat IS INITIAL.
      mf_monat = sy-datlo(6).
    ENDIF.

    CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
      EXPORTING
        actual_month               = mf_monat
      IMPORTING
        selected_month             = mf_monat
        return_code                = mf_returncode
      EXCEPTIONS
        factory_calendar_not_found = 01
        holiday_calendar_not_found = 02
        month_not_found            = 03.
    IF sy-subrc = 0 AND mf_returncode = 0.
      CALL FUNCTION 'CONVERSION_EXIT_PERI_OUTPUT'
        EXPORTING
          input  = mf_monat
        IMPORTING
          output = mf_dynpfields-fieldvalue.

      COLLECT mf_dynpfields.

      CALL FUNCTION 'DYNP_VALUES_UPDATE'
        EXPORTING
          dyname               = mf_hlp_repid
          dynumb               = sy-dynnr
        TABLES
          dynpfields           = mf_dynpfields
        EXCEPTIONS
          invalid_abapworkarea = 01
          invalid_dynprofield  = 02
          invalid_dynproname   = 03
          invalid_dynpronummer = 04
          invalid_request      = 05
          no_fielddescription  = 06
          undefind_error       = 07.
      IF sy-subrc NE 0.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " EXEC_MONAT_F4
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

*Dynamic Creation of ALV Data Table
  CLEAR lp_table.
  CALL METHOD z_ts_cl_alv_table_create=>create_dynamic_table_grid
    EXPORTING
      it_fieldcatalog = fc
*      i_style_table   = i_style_table
    IMPORTING
      ep_table        = lp_table.

  ASSIGN lp_table->* TO <gt_table>.

ENDFORM.                    " create_dynamic_table
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
    IF NOT gs_fieldcat_g-fieldname IS INITIAL AND
       gs_fieldcat_g-fieldname     NE 'MANDT'.
      MOVE-CORRESPONDING  gs_fieldcat_g TO fcs.
      MOVE: gs_fieldcat_g-fieldname     TO fcs-ref_fieldname,
            'ZTISLCW'                   TO fcs-ref_tabname.
      CLEAR: fcs-key.
      APPEND fcs TO fc.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " adjust_fieldcat
