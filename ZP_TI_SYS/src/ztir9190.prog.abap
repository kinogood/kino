************************************************************************
*                                                                      *
* Title         : ZTIR9190                                             *
*                                                                      *
* Description   : [Report] 업무대행 수수료 관리                        *
*                                                                      *
* Creation Date : 2004/11/28                                           *
*                                                                      *
* Author        : Jong Pil, Park                                       *
*                Copyright ⓒ ASEG Co., LTD. All rights reserved.      *
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
PROGRAM   ztir9190
          MESSAGE-ID zmte
          NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis.   "> Globale Type(ALV)

************************************************************************
* User Included                                                        *
************************************************************************
INCLUDE zts_reuse_bdc_subroutine_f00.
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
        t005,      "
        dfies,     "
        ztitig07,  "
        ztitblp,   "
        lfa1,      "
        ztitcsk,   "
        ztitblk,   ">Bill of Lading Header table
        ztitcck,   ">수입신고필증  MAIN (IMPREQ/IMPRES)
        ztivcc03.   ">수입 통관 + B/L Header Views

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
    c_save(1)   TYPE  c             VALUE 'A'.
** JS전선 회사코드 2007/04 BY-MH.LEE -----------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000'.   ">Company code
** JS전선 회사코드 2007/04 ---------------------------
************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK box1 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
               s_bukrs  FOR ztivcc03-bukrs     "회사코드.
                              NO-EXTENSION NO INTERVALS OBLIGATORY
                               MEMORY ID buk,
               s_cdrdt  FOR ztivcc03-cdrdt ,   "기준일
               s_sdrlt  FOR ztivcc03-sdrlt ,   "송부처
               s_werks  FOR ztitblp-werks ,    "플랜트
               s_cdcor  FOR ztivcc03-cdcor .   "세관

SELECTION-SCREEN END OF BLOCK box1.

SELECTION-SCREEN BEGIN OF BLOCK box2 WITH FRAME TITLE text-002.
PARAMETERS:    p_lifnr  LIKE ztitcsk-lifnr ,   "대행업체
               p_blart  LIKE ztitcsk-blart ,   "문서종류
               p_mwskz  LIKE ztitcsk-mwskz ,   "세금코드
               p_hwaer  LIKE ztitcsk-hwaer ,   "현지통화.
               p_dmbtr  LIKE ztitcsk-dmbtr .   "금액

SELECTION-SCREEN ULINE.
PARAMETERS: p_full RADIOBUTTON GROUP ab2 DEFAULT 'X',
            p_list RADIOBUTTON GROUP ab2.
SELECTION-SCREEN END OF BLOCK box2.

*> Report variant
SELECTION-SCREEN: BEGIN OF BLOCK alv WITH FRAME TITLE text-003.
PARAMETERS: alv_def LIKE disvariant-variant.
SELECTION-SCREEN: END OF BLOCK alv.


************************************************************************
* Internal Tables                                                      *
************************************************************************
DATA: BEGIN OF it_bupla  OCCURS 2,
      bupla    TYPE bupla,
      END   OF it_bupla.

*> 공급업체명
DATA : BEGIN OF xlfa1 OCCURS 0,
       lifnr           LIKE   lfa1-lifnr,
       name1           LIKE   lfa1-name1.
DATA : END   OF xlfa1.

DATA : BEGIN OF it_exptx OCCURS 0,
       expcd           LIKE   ztetige-expcd,
       exptx           LIKE   ztetige-exptx.
DATA : END   OF it_exptx.

DATA: BEGIN OF it_ztivcc03 OCCURS 0.
        INCLUDE STRUCTURE ztivcc03.
DATA: END   OF it_ztivcc03.


DATA: it_fieldcat_g TYPE lvc_t_fcat,
      gs_fieldcat_g LIKE LINE OF it_fieldcat_g.

*---------------------------------------------------------------------*
*> Message dialog box용                                               *
*---------------------------------------------------------------------*
DATA: BEGIN OF it_msg  OCCURS 0.
        INCLUDE STRUCTURE ztismessage.
DATA: END   OF it_msg.

DATA : g_message_handler   TYPE REF TO cl_message_handler_mm.

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
       g_wrbtr         TYPE   wrbtr,
       g_wmwst         TYPE   wmwst,
       line_cnt(02)    TYPE  n,
       field_name(20),
       field_name1(20).

DATA : datlo_01(8)        TYPE c.
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
  PERFORM create_dynamic_table.    ">
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
*  PERFORM set_colorize_build.       ">Set color
*  PERFORM set_sort_field.           ">Set ALV sort fields
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

  DATA: l_bukrs    LIKE t001-bukrs,
        l_numc(2)  TYPE n.

  SET TITLEBAR 'T1000' WITH '업무대행 수수료 관리'.

*>> 기준일.
  s_cdrdt-low  = sy-datlo+0(6).
  s_cdrdt-high = sy-datlo+0(6).
  CONCATENATE s_cdrdt-low '01' INTO s_cdrdt-low.

  CALL FUNCTION 'END_OF_MONTH_DETERMINE'
    EXPORTING
      datum  = s_cdrdt-low
    IMPORTING
      tt     = l_numc
    EXCEPTIONS
      OTHERS = 1.

  s_cdrdt-high+6(2)  =   l_numc.
  MOVE :    'I'          TO  s_cdrdt-sign,
            'BT'         TO  s_cdrdt-option.

  APPEND s_cdrdt.

*>> 송부처.
  MOVE :    'I'           TO  s_sdrlt-sign,
            'BT'          TO  s_sdrlt-option,
            'L01'         TO  s_sdrlt-low,
            'L02'         TO  s_sdrlt-high.
  APPEND s_sdrlt.

  GET PARAMETER ID 'BUK'  FIELD  l_bukrs.

** 비용전기 DEFAULT DATA GET.
  CLEAR ztitig07.

  SELECT SINGLE *
    FROM ztitig07
   WHERE bukrs EQ l_bukrs
     AND cstct EQ 'Z'.
  IF sy-subrc EQ 0.
    MOVE: ztitig07-lifnr TO p_lifnr,
          ztitig07-blart TO p_blart,
          ztitig07-mwskz TO p_mwskz,
          ztitig07-waers TO p_hwaer,
          ztitig07-waers TO ztitcsk-hwaer,
          ztitig07-price TO p_dmbtr.
  ENDIF.

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
  SELECT bukrs
    INTO t001
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
    FROM t005
   WHERE land1 EQ t001-land1.
*>
  SELECT SINGLE *
    FROM ztitig07
   WHERE bukrs EQ t001-bukrs
     AND cstct EQ 'Z'.

  IF sy-subrc EQ 0.
    MOVE: ztitig07-lifnr TO p_lifnr,
          ztitig07-blart TO p_blart,
          ztitig07-mwskz TO p_mwskz,
          ztitig07-waers TO p_hwaer,
          ztitig07-waers TO ztitcsk-hwaer,
          ztitig07-price TO p_dmbtr.
  ENDIF.

  SELECT exptx expcd
    INTO CORRESPONDING FIELDS OF TABLE it_exptx
    FROM ztetige
   WHERE bukrs IN s_bukrs
     AND expgr EQ 'N'.

  IF sy-subrc NE 0.
    MESSAGE e701 WITH l_bukrs 'NEGO 관련비용'.
  ENDIF.

  SORT it_exptx BY expcd.


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

  DATA:  l_count         TYPE  i.
  DATA:  l_tabix         LIKE  sy-tabix,
         l_fieldname(10) TYPE  c,
         l_tabixn(2)     TYPE  n.

  RANGES: lr_docst   FOR   ztitrqs-docst OCCURS 1.

  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_field>,
                 <l_curr>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.
  FIELD-SYMBOLS: <l_bldty>.
  FIELD-SYMBOLS: <l_bldtd>,
                 <l_bukrs>,
                 <l_iblno>,
                 <l_iccno>,
                 <l_werks>,
                 <l_bupla>,
                 <l_belnr>,
                 <l_gjahr>.

  REFRESH : <gt_table>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.

  ASSIGN COMPONENT 'WAERS' OF STRUCTURE <ls_table> TO <l_curr>.
  ASSIGN COMPONENT 'BLDTY' OF STRUCTURE <ls_table> TO <l_bldty>.
  ASSIGN COMPONENT 'BLDTD' OF STRUCTURE <ls_table> TO <l_bldtd>.
  ASSIGN COMPONENT 'IBLNO' OF STRUCTURE <ls_table> TO <l_iblno>.
  ASSIGN COMPONENT 'IBLNO' OF STRUCTURE <ls_table> TO <l_iccno>.
  ASSIGN COMPONENT 'WERKS' OF STRUCTURE <ls_table> TO <l_werks>.
  ASSIGN COMPONENT 'BUPLA' OF STRUCTURE <ls_table> TO <l_bupla>.
  ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <ls_table> TO <l_bukrs>.
  ASSIGN COMPONENT 'BELNR' OF STRUCTURE <ls_table> TO <l_belnr>.
  ASSIGN COMPONENT 'GJAHR' OF STRUCTURE <ls_table> TO <l_gjahr>.

*> PROGRESS Display.
  g_line1    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_line1.

*    ASSIGN COMPONENT 'REQNO' OF STRUCTURE
*                        <ls_table> TO <l_field5>.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE <gt_table>
    FROM ztivcc03
   WHERE bukrs IN s_bukrs
    AND  cdrdt IN s_cdrdt      "기준일
    AND  sdrlt IN s_sdrlt      "송부처
    AND  cdcor IN s_cdcor  .    "세관

  LOOP AT <gt_table> INTO <ls_table>.
*> Plant data
    SELECT werks
      INTO <l_werks>
      FROM ztitblp UP TO 1 ROWS
     WHERE iblno EQ <l_iblno>.
    ENDSELECT.
    IF sy-subrc EQ 0.
*        SELECT SINGLE
*          FROM t001w AS
    ENDIF.
**> 회계전표번호 Select.
*        SELECT SINGLE belnr gjahr
*          INTO ()
*          FROM ztivcs00
*         WHERE bukrs  EQ  <l_bukrs>
*           AND expgr  EQ  'C'
*           AND refno  EQ  <l_iccno>.
*


    PERFORM  get_domain_value_text(zter0000) USING 'ZTIBLDTY'
                                                   <l_bldty>
                                                   <l_bldtd>.
    MODIFY <gt_table> FROM <ls_table>.
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
  DATA: l_fieldname(10) TYPE c,
        l_seq(2)        TYPE n.

  FREE : fc.  CLEAR: fc.


  ac 'ITAB   BOX   ZTISRQIT                     FLAG  X'.
  "회계문서번호
  ac 'ITAB   BUPLA ZTITBLK                      BUPLA '.
  ac 'ITAB   BUKRS ZTITCSK                      BUKRS '.
  ac 'ITAB   GJAHR ZTITCSK                      GJAHR '.
  ac 'ITAB   BELNR ZTITCSK                      BELNR '.
  "p/o no
  ac 'ITAB   EBELN ZTIVCC03                     EBELN '.
  "b/l 관리 no
  ac 'ITAB   IBLNO ZTIVCC03                     IBLNO '.
  "b/l no
  ac 'ITAB   BLNUM ZTIVCC03                     BLNUM '.
  "신고 수리일
  ac 'ITAB   CDRDT ZTIVCC03                     CDRDT '.
  "통관 관리 no
  ac 'ITAB   ICCNO ZTIVCC03                     ICCNO '.
  "통관 정정 no
  ac 'ITAB   ICCSQ ZTIVCC03                     ICCSQ '.
  "신고번호
  ac 'ITAB   CDCNO ZTIVCC03                     CDCNO '.
  "문서상태
  ac 'ITAB   DOCST DD07D                        DDTEXT '.
  "금 액
  ac 'ITAB   WRBTR ZTITCSK                      WRBTR CWAERS'.
  "통화
  ac 'ITAB   WAERS ZTITCSK                      WAERS '.
  "구 분
  ac 'ITAB   BLDTY ZTIVCC03                     BLDTY '.
  "구 분 설명
  ac 'ITAB   BLDTD DD07D                        DDTEXT '.
  "플랜트
  ac 'ITAB   WERKS ZTITBLP                      WERKS '.
*  "사업장
*  ac 'ITAB   BUPLA DD07D                        DDTEXT '.
*
*
  fc1[] = fc[].
*
*  ac 'ITAB   COLOR SLIS_T_SPECIALCOL_ALV              X'.
*
  LOOP AT fc1 INTO fcs.
    CLEAR: fcs-key .
    CASE fcs-fieldname.
      WHEN 'NEGNO'.
        fcs-hotspot = 'X'.
        fcs-key     = 'X'.
      WHEN 'NGBEN'.
        CLEAR: fcs-ref_fieldname,fcs-ref_tabname.
        fcs-seltext_l = 'REFERENCE NO'.
        fcs-outputlen = '12'.
        fcs-seltext_s = fcs-seltext_m = fcs-seltext_l.

      WHEN 'NEGTD'.
        CLEAR: fcs-ref_fieldname,fcs-ref_tabname.
        fcs-seltext_l = '거래구분'.
        fcs-outputlen = '12'.
        fcs-seltext_s = fcs-seltext_m = fcs-seltext_l.
      WHEN 'BLDTY'.
        fcs-no_out = 'X'.
      WHEN 'BLDTD'.
        fcs-outputlen = '12'.
      WHEN 'DOCST'.
        fcs-outputlen = '12'.
      WHEN 'UEBTR'.
        fcs-do_sum = 'X'.
      WHEN 'IBLNO'.
        fcs-no_out = 'X'.
      WHEN 'ICCNO'.
        fcs-no_out = 'X'.
      WHEN 'ICCSQ'.
        fcs-no_out = 'X'.
      WHEN 'GJAHR'.
        fcs-no_out = 'X'.
      WHEN 'DOCST'.
        fcs-outputlen = '12'.
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

  SET TITLEBAR 'T1000' WITH '업무대행 수수료 관리'.

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
*  gs_layout-coltab_fieldname  = 'COLOR'.
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

  SET TITLEBAR 'T1000' WITH '업무대행 수수료 관리'.

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
  DATA: l_index   TYPE i.
  DATA: l_subrc   LIKE sy-subrc.
  DATA: l_tcode   LIKE sy-tcode.
  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_box>.
  FIELD-SYMBOLS: <l_field>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.
  FIELD-SYMBOLS: <l_field3>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.

  CASE r_ucomm.
    WHEN 'DISPLAY' OR '&IC1'.    " AUF DOPPELKLICK REAGIERIEN
      CHECK rs_selfield-tabindex GT 0.

      READ TABLE <gt_table> INTO <ls_table> INDEX rs_selfield-tabindex.
      IF sy-subrc NE 0.
        MESSAGE s906.            EXIT.
      ENDIF.

      ASSIGN COMPONENT 'NEGNO' OF STRUCTURE
                            <ls_table> TO <l_field1>.

      ASSIGN COMPONENT 'PAYSQ' OF STRUCTURE
                            <ls_table> TO <l_field2>.

      SET PARAMETER ID 'ZTENEGNO' FIELD <l_field1>.
      SET PARAMETER ID 'ZTEAPYSQ' FIELD <l_field2>.
      CALL TRANSACTION 'ZTET623' AND SKIP FIRST SCREEN.
    WHEN 'ZTIPOST'.
      CLEAR: l_count.
      REFRESH: it_bupla.
* Message preparations
      PERFORM  set_message_preparations.
      CLEAR: g_wrbtr.
      LOOP AT <gt_table> INTO <ls_table>.
        IF <l_box> EQ 'X'.
          ADD 1 TO l_count.

        ENDIF.
      ENDLOOP.
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

  REFRESH header.

  header-typ = 'H'.
  header-info = '업무대행 수수료 관리 현황'.

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
              'ZTIVIP01'                  TO fcs-ref_tabname.
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

ENDFORM.                    " ADJUST_fieldcat
*&---------------------------------------------------------------------*
*&      Form  SET_INITAIL_IP_BATCHDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_initail_ip_batchdata .

ENDFORM.                    " SET_INITAIL_IP_BATCHDATA
*&---------------------------------------------------------------------*
*&      Form  get_source_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  set_message_preparations
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form set_message_preparations .

  CALL METHOD cl_message_handler_mm=>get_handler
    IMPORTING
      ex_handler = g_message_handler.

  CALL METHOD g_message_handler->set_config_for_mepo( ).
  CALL METHOD g_message_handler->remove_all( ).
  CALL METHOD g_message_handler->cleanup( ).

endform.                    " set_message_preparations
*
