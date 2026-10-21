************************************************************************
*                                                                      *
* Title         : ZTIR4100                                             *
*                                                                      *
* Description   : [Report] 확정신고 Due List.                          *
*                                                                      *
* Creation Date : 2005/01/17                                           *
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
PROGRAM   ztir4100
          MESSAGE-ID zmti00
          NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis.   "> Globale Type(ALV)

************************************************************************
* User Included                                                        *
************************************************************************
INCLUDE zts_reuse_bdc_subroutine_f00.
INCLUDE:  <symbol>.
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
TABLES: t001,      ">Company Codes.
        t001w,     ">Plants/Branches.
        t001k,     ">Valuation area.
        ztitccp,   ">수입신고필증 품목 테이블.
        ztitcck,   ">수입신고필증  MAIN (IMPREQ/IMPRES).
        ztitcrk,   ">[Import] 수입신고  의뢰 MAIN (IMPREQ)
        dfies,
        ztivcc00.   ">반입신고 Header table.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
** JS전선 회사코드 2007/04 --------------------------------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
** JS전선 회사코드 2007/04 --------------------------------------
    c_save(1)   TYPE  c             VALUE 'A'.


************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK box1 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_bukrs  FOR ztitcck-bukrs                    "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk
                    MODIF  ID iog ,
  s_ekorg  FOR ztitcck-ekorg  MODIF  ID iog,   "구매조직
  s_ekgrp  FOR ztitcck-ekgrp  MODIF  ID iog,   "구매그룹
  s_ebeln  FOR ztitccp-ebeln  MODIF  ID iog,   "구매전표번호
  s_iccno  FOR ztitcck-iccno  MODIF  ID iog,   "통관관리번호
  s_rsnum  FOR ztitccp-rsnum  MODIF  ID iog,   "예약/종속소요량
  s_reqno  FOR ztitccp-reqno  MODIF  ID iog,   "수입의뢰 관리번호
  s_iblno  FOR ztitccp-iblno  MODIF  ID iog,   "B/L 관리번호
  s_lifnr  FOR ztitcck-lifnr  MODIF  ID iog,   "구매처채권자계정
  s_cdcno  FOR ztitcck-cdcno  MODIF  ID iog,   "(RES)신고(수리)번호
  s_cdrdt  FOR ztitcck-cdrdt  MODIF  ID iog,   "(RES)신고수리일
  s_cdcdt  FOR ztitcck-cdcdt  MODIF  ID iog,   "(RES)신고일
  s_cblno  FOR ztitcck-cblno  MODIF  ID iog,   "B/L(AWB)번호
  s_ccano  FOR ztitcck-ccano  MODIF  ID iog,   "화물관리번호
  s_cdcor  FOR ztitcck-cdcor  MODIF  ID iog,   "신고세관
  s_cdcch  FOR ztitcck-cdcch  MODIF  ID iog,   "신고과
  s_stawn  FOR ztitccp-stawn  MODIF  ID iog,   "해외무역 상품코드
  s_cinco  FOR ztitcck-cinco  MODIF  ID iog,   "인도조건
  s_cnam   FOR ztitccp-cnam   MODIF  ID iog,   "작성인
  s_cdat   FOR ztitccp-cdat   MODIF  ID iog,   "생성일
  s_ctme   FOR ztitccp-ctme   MODIF  ID iog,   "생성시간
  s_unam   FOR ztitccp-unam   MODIF  ID iog,   "최종변경인
  s_udat   FOR ztitccp-udat   MODIF  ID iog,   "변경일
  s_utme   FOR ztitccp-utme   MODIF  ID iog.   "최종변경시간

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
       line_cnt(02)    TYPE  n,
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

  SET TITLEBAR 'T1000' WITH '확정신고 '.

** JS전선 회사코드 2007/04 --------------------------------------
*  FREE: s_bukrs.    CLEAR: s_bukrs.
*  s_bukrs-sign   = 'I'.
*  s_bukrs-option = 'EQ'.
*  s_bukrs-low    = c_bukrs.
*  APPEND s_bukrs.
** JS전선 회사코드 2007/04 --------------------------------------

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


** Purchase Organization
*  READ TABLE s_ekorg INDEX 1 TRANSPORTING NO FIELDS.
*  IF sy-subrc = 0.
*    SELECT ekorg INTO (l_ekorg)
*                 FROM t024e UP TO 1 ROWS WHERE ekorg IN s_ekorg.
*    ENDSELECT.
*    IF sy-subrc <> 0.
*      PERFORM get_ftext(rddfie00) USING 'T024E' 'EKORG' sy-langu
*                                  CHANGING dfies g_subrc.
*      SET CURSOR FIELD 'S_EKORG-LOW'.
*      MESSAGE e348(m7) WITH dfies-scrtext_m.
*    ENDIF.
*  ENDIF.
*
** Purchase GROUP
*  READ TABLE s_ekgrp INDEX 1 TRANSPORTING NO FIELDS.
*  IF sy-subrc = 0.
*    SELECT ekgrp INTO (l_ekgrp)
*                 FROM t024 UP TO 1 ROWS WHERE ekgrp IN s_ekgrp.
*    ENDSELECT.
*    IF sy-subrc <> 0.
*      PERFORM get_ftext(rddfie00) USING 'T024' 'EKGRP' sy-langu
*                                  CHANGING dfies g_subrc.
*      SET CURSOR FIELD 'S_EKGRP-LOW'.
*      MESSAGE e348(m7) WITH dfies-scrtext_m.
*    ENDIF.
*  ENDIF.

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

  RANGES: lr_blasn   FOR   ztitbik-blasn OCCURS 1.

  DATA: l_count       TYPE  i.
  DATA: l_iblno(10)   TYPE  c.
  DATA: l_iccno(10)   TYPE  c.
  DATA: l_ddtext LIKE dd07t-ddtext,
        l_txz01  LIKE ekpo-txz01.

  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_stawn>.
  FIELD-SYMBOLS: <l_iccno>.
  FIELD-SYMBOLS: <l_iccsq>.

  REFRESH : <gt_table>.
*> PROGRESS Display.
  g_line1    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_line1.

*> 수입의뢰 데이타 select.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE <gt_table>
    FROM ztivcc00
        WHERE bukrs   IN s_bukrs 	"회사코드.
          AND iccno   IN s_iccno	"통관관리번호
          AND lifnr   IN s_lifnr	"구매처,채권자계정
          AND ekorg   IN s_ekorg	"구매조직
          AND ekgrp   IN s_ekgrp	"구매그룹
          AND rsnum   IN s_rsnum	"예약/종속소요량
          AND cdcdt   IN s_cdcdt	"(RES)신고일
          AND cdrdt   IN s_cdrdt	"(RES)신고수리일
          AND reqno   IN s_reqno	"수입의뢰 관리번호
          AND cdcno   IN s_cdcno	"(RES)신고(수리)번호
          AND cblno   IN s_cblno    "B/L(AWB)번호
          AND ccano   IN s_ccano    "화물관리번호
          AND cdcor   IN s_cdcor	"신고세관
          AND cdcch   IN s_cdcch	"신고과
          AND stawn   IN s_stawn	"수입코드번호
          AND cinco   IN s_cinco	"인도조건
          AND cnam    IN s_cnam 	"작성인
          AND cdat    IN s_cdat 	"생성일
          AND ctme    IN s_ctme 	"생성시간
          AND unam    IN s_unam 	"최종변경인
          AND udat    IN s_udat 	"변경일
          AND utme    IN s_utme	"최종변경시간
          AND cfnst   EQ 'H'.     "정정/확정신고구분.

  IF sy-subrc NE 0.
    MESSAGE s902.   EXIT.
  ENDIF.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.
*  FIELD-SYMBOLS: <ls_table>.


  ASSIGN COMPONENT 'STAWN' OF STRUCTURE                "H/S부호.
                      <ls_table> TO <l_stawn>.
  ASSIGN COMPONENT 'ICCNO' OF STRUCTURE                "통관관리번호.
                      <ls_table> TO <l_iccno>.
  ASSIGN COMPONENT 'ICCSQ' OF STRUCTURE                "통관관리번호.
                      <ls_table> TO <l_iccsq>.

  LOOP AT <gt_table> INTO <ls_table>.
    g_tabix = sy-tabix.
    IF l_iccno EQ <l_iccno>.
      DELETE <gt_table> INDEX g_tabix.
      CONTINUE.
    ENDIF.

*> 수입신고의뢰 데이타 SELECT.
    <l_iccsq> = <l_iccsq> + 1.
    SELECT SINGLE *
      FROM ztitcrk
     WHERE iccno EQ <l_iccno>
       AND iccsq EQ <l_iccsq>.
    IF sy-subrc EQ 0.
      DELETE <gt_table> INDEX g_tabix.
      CONTINUE.
    ENDIF.

    <l_iccsq> = <l_iccsq> - 1.

    SELECT stawn
       INTO <l_stawn>
       FROM ztivcc00 UP TO 1 ROWS
       WHERE iccno EQ <l_iccno>.
    ENDSELECT.

    l_iccno = <l_iccno>.
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

  FREE : fc.  CLEAR: fc.
  ac 'ITAB   BOX   ZTISRQIT                     FLAG  X'.
  ac 'ITAB   ICCNO ZTIVCC00                     ICCNO  '.
  "통관관리번호
  ac 'ITAB   ICCSQ ZTIVCC00                     ICCSQ  '.
  "통관관리번호  차수
  ac 'ITAB   EBELN ZTIVCC00                     EBELN '.     "구매오더
  ac 'ITAB   CDCNO ZTIVCC00                     CDCNO  '.
  "신고(수리)번호
  ac 'ITAB   CDRDT ZTIVCC00                     CDRDT '.     "신고수리일
  ac 'ITAB   CBLNO ZTIVCC00                     CBLNO'.
  "B/L(AWB)번호
  ac 'ITAB   CINCO ZTIVCC00                     CINCO '.      "인도조건
  ac 'ITAB   STAWN ZTIVCC00                     STAWN '.     "H/S부호.
  ac 'ITAB   CTOWE ZTIVCC00                     CTOWE '.     "총중량
  ac 'ITAB   CTOWEUZTIVCC00                     CTOWEU '.    "총중량단위
  ac 'ITAB   CTPKG ZTIVCC00                     CTPKG  '.    "총포장갯수
  ac 'ITAB   CTPKGUZTIVCC00                     CTPKGU '.
  "총포장갯수단위
  ac 'ITAB   CPYATCZTIVCC00                     CPYATC '.
  "결제금액 통화
  ac 'ITAB   CPYAT ZTIVCC00                     CPYAT  CCPYATC'.
  "결제금액
  ac 'ITAB   CCUAKCZTIVCC00                     CCUAKC'.
  "과세가격합계(KRW)통화
  ac 'ITAB   CCUAK ZTIVCC00                     CCUAK  CCCUAKC'.
  "과세가격합계(KRW)
  ac 'ITAB   CDUTX ZTIVCC00                     CDUTX  CCCUAKC'."관세.
  ac 'ITAB   CSPTX ZTIVCC00                     CSPTX  CCCUAKC'."특소세.
  ac 'ITAB   CALTX ZTIVCC00                     CALTX  CCCUAKC'."주세.
  ac 'ITAB   CTRTX ZTIVCC00                     CTRTX  CCCUAKC'."교통세.
  ac 'ITAB   CINTX ZTIVCC00                     CINTX  CCCUAKC'."농특세.
  ac 'ITAB   CADTX ZTIVCC00                     CADTX  CCCUAKC'."부가세.
  ac 'ITAB   CLTTX ZTIVCC00                     CLTTX  CCCUAKC'.
  "신고지연가산세.
  ac 'ITAB   CTOTL ZTIVCC00                     CTOTL  CCCUAKC'."합계.
*> Create field catagory table
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZTIVBL00'
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

      WHEN 'CBLNO' OR 'EBELN'
            OR 'CDCNO' OR 'ICCNO' OR 'ICCSQ'.
        fcs-hotspot = 'X'.
        fcs-key     = 'X'.
      WHEN 'CDUTX' OR 'CSPTX' OR
           'CALTX' OR 'CTRTX' OR
           'CINTX' OR 'CADTX' OR
           'CLTTX'.
        fcs-outputlen = '14'.
      WHEN 'CCUAKC'.
        CLEAR : fcs-seltext_l,fcs-seltext_m,fcs-seltext_s.
        fcs-seltext_l = '원화'.
        fcs-seltext_m = '원화'.
        fcs-seltext_s = '원화'.
      WHEN 'CCUAK'.
        CLEAR : fcs-seltext_l,fcs-seltext_m,fcs-seltext_s.
        fcs-seltext_l = '과세가격'.
        fcs-seltext_m = '과세가격'.
        fcs-seltext_s = '과세가격'.
        fcs-outputlen = '14'.
      WHEN OTHERS.
*        CLEAR : fcs-no_out.
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


  SET TITLEBAR 'T1000' WITH '확정신고 '.

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
  DATA: l_index   TYPE i.
  DATA: l_answer  TYPE c.
  DATA: l_success TYPE i.
  DATA: l_iblno   TYPE ztiiblno.
  DATA: l_subrc   LIKE sy-subrc.
  DATA: l_tcode   LIKE sy-tcode.

  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_field>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.
  FIELD-SYMBOLS: <l_field3>.

  DATA : BEGIN OF it_prt_doc  OCCURS 0.
          INCLUDE STRUCTURE ztss_prt_documents.
  DATA : END   OF it_prt_doc.

  DATA : BEGIN OF it_ztsprtctl  OCCURS 0.
          INCLUDE STRUCTURE ztssprtctl.
  DATA : END   OF it_ztsprtctl.

  DATA: lt_seldoc LIKE zts_docno OCCURS 0 WITH HEADER LINE.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.

*> 선택된 레코드 찾기.
  PERFORM  get_selected_row  TABLES lt_seldoc
                             USING  l_count.
  IF r_ucomm NE 'DISPLAY'.
    CASE l_count.
      WHEN 0.
        MESSAGE s909.   EXIT.
      WHEN 1.

      WHEN OTHERS.
        IF r_ucomm EQ 'ZCFNRG'.
          MESSAGE s929.  EXIT.
        ENDIF.
    ENDCASE.
  ENDIF.

  CASE r_ucomm.
    WHEN 'DISPLAY' .
      CHECK rs_selfield-tabindex GT 0.
      READ TABLE <gt_table> INTO <ls_table> INDEX rs_selfield-tabindex.
      IF sy-subrc NE 0.
        MESSAGE s906.            EXIT.
      ENDIF.

      CASE rs_selfield-fieldname.
        WHEN 'CBLNO' .
          ASSIGN COMPONENT 'CBLNO' OF STRUCTURE
                                <ls_table> TO <l_field1>.
          SET PARAMETER ID 'ZTIBLNUM' FIELD <l_field1>.
          CALL TRANSACTION 'ZTIT203' AND SKIP FIRST SCREEN.
        WHEN 'EBELN' .
          SET PARAMETER ID 'BES' FIELD space.
          ASSIGN COMPONENT 'EBELN' OF STRUCTURE
                            <ls_table> TO <l_field1>.
          IF NOT <l_field1> IS INITIAL.
            SET PARAMETER ID 'BES' FIELD <l_field1>.
            CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
          ENDIF.
        WHEN 'ICCNO' OR 'CDCNO'  .
          ASSIGN COMPONENT 'ICCNO' OF STRUCTURE
                            <ls_table> TO <l_field1>.
          ASSIGN COMPONENT 'ICCSQ' OF STRUCTURE
                            <ls_table> TO <l_field2>.
          IF NOT <l_field1> IS INITIAL.
            <l_field2> = <l_field2> - 1.
            SET PARAMETER ID 'ZTIICCNO' FIELD <l_field1>.
            SET PARAMETER ID 'ZTIICCSQ' FIELD <l_field2>.
            CALL TRANSACTION 'ZTIT403' AND SKIP FIRST SCREEN.
          ENDIF.
        WHEN OTHERS.              ">해당작업수행..
      ENDCASE.

    WHEN 'ZCFNRG'.   " 확정신고.
      LOOP AT lt_seldoc.
        SET PARAMETER ID 'ZTIICCNO' FIELD lt_seldoc-docno.
        SET PARAMETER ID 'ZTIICCSQ' FIELD lt_seldoc-amdsq.
        CALL TRANSACTION 'ZTIT439' AND SKIP FIRST SCREEN.
      ENDLOOP.
      PERFORM get_data_for_display.    ">data select
      rs_selfield-refresh = 'X'.
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
  st_sort-fieldname = 'ICCNO'.
  st_sort-tabname   = '<GT_TABLE>'.
  st_sort-up        = 'X'.
*  ST_SORT-GROUP     = 'X'.
*  st_sort-subtot    = 'X'.
*  ST_SORT-EXPA      = 'X'.
  APPEND st_sort TO it_sort.


ENDFORM.                    " SET_SORT_FIELD

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM top_of_page.

  DATA: l_mode TYPE i.
  DATA: l_header(20) TYPE c.
  DATA: header TYPE slis_listheader OCCURS 0 WITH HEADER LINE.

  REFRESH header.

  header-typ = 'H'.
  header-info = ' 확정신고 Due List'.
  CONCATENATE l_header header-info INTO header-info.
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
*    READ TABLE organ WITH KEY werks = xitab-werks.
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
              'ZTIVBL00'                  TO fcs-ref_tabname.
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
*&      Form  get_selected_row
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_selected_row TABLES pt_docno  STRUCTURE zts_docno
                      USING  p_count.

  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.
  ASSIGN COMPONENT 'BOX' OF STRUCTURE  <ls_table> TO <l_field1>.
  CLEAR: p_count.
  REFRESH: pt_docno.

  LOOP AT <gt_table> INTO <ls_table>.
    IF <l_field1> EQ 'X'.
      ASSIGN COMPONENT 'ICCNO' OF STRUCTURE
                            <ls_table> TO <l_field2>.
      pt_docno-docno = <l_field2>.
      ASSIGN COMPONENT 'ICCSQ' OF STRUCTURE
                            <ls_table> TO <l_field2>.
      pt_docno-amdsq = <l_field2>.
      APPEND pt_docno.
      ADD 1 TO p_count.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " get_selected_row
*&---------------------------------------------------------------------*
*&      Form  set_return_message_fill
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_return_message_fill USING p_msgty.

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
*       text
*----------------------------------------------------------------------*
FORM display_error_message .

  CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
    EXPORTING
      xdocno_show = ' '
    TABLES
      xmsg        = it_msg.

ENDFORM.                    " display_error_message
