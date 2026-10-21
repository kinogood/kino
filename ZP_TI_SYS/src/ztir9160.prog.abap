************************************************************************
*                                                                      *
* Title         : ZTIR9160                                             *
*                                                                      *
* Description   : [Report] 보세창고입출비용 일괄전기                   *
*                                                                      *
* Creation Date : 2004/12/27                                           *
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
PROGRAM   ztir9160
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
INCLUDE: <icon>,
        <symbol>.
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
        t001w,     ">Plants/Branches
        t001k,     ">Valuation area
        ztitblk,   ">[Import] Bill of Lading Header table
        ztitblp,   ">[Import] Bill of Lading Items table
        ztitgrk,   ">수입물품 입고 Header Table
        dfies,
        ztitig07,
        ztitbik.   ">반입신고 Header table

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
** JS전선 회사코드 2007/04 BY-MH.LEE -----------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
** JS전선 회사코드 2007/04 ---------------------------
    c_save(1)   TYPE  c             VALUE 'A'.


************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK box1 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_bukrs  FOR ztitblk-bukrs 	           "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk
                    MODIF  ID iog ,
  s_bindt  FOR ztitbik-bindt MODIF ID iog,       "반입일
  s_blocc  FOR ztitbik-blocc MODIF ID iog,       "보세구역
  s_truck   FOR ztitbik-truck  MODIF ID iog.       "운송사

SELECTION-SCREEN END OF BLOCK box1.

SELECTION-SCREEN BEGIN OF BLOCK box2 WITH FRAME TITLE text-002.
PARAMETERS: p_step1 RADIOBUTTON GROUP ab1 ,              "입고운송료.
            p_step2 RADIOBUTTON GROUP ab1,               "입고하차료.
            p_step3 RADIOBUTTON GROUP ab1 DEFAULT 'X'.   "출고상차료.
SELECTION-SCREEN END OF BLOCK box2.
SELECTION-SCREEN BEGIN OF BLOCK box3 WITH FRAME TITLE text-004.
PARAMETERS: p_post1 RADIOBUTTON GROUP ab3 ,              " 미 전기 list.
            p_post2 RADIOBUTTON GROUP ab3,               " 기 전기 list.
            p_posta RADIOBUTTON GROUP ab3 DEFAULT 'X'.   "전체
SELECTION-SCREEN ULINE.

PARAMETERS: p_full RADIOBUTTON GROUP ab2 DEFAULT 'X',
            p_list RADIOBUTTON GROUP ab2.
SELECTION-SCREEN END OF BLOCK box3.

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
       l_cost(1),
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

  SET TITLEBAR 'T1000' WITH '보세창고입출비용 일괄전기 '.
** JS전선 회사코드 2007/04 BY-MH.LEE -----------------
*  FREE: s_bukrs.    CLEAR: s_bukrs.
*  s_bukrs-sign   = 'I'.
*  s_bukrs-option = 'EQ'.
*  s_bukrs-low    = c_bukrs.
*  APPEND s_bukrs.
** JS전선 회사코드 -----------------------------------
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

* 비용종류
  IF p_step1 = 'X'.
    l_cost = '1'.
  ELSEIF p_step2 EQ 'X'.
    l_cost = '2'.
  ELSEIF p_step3 EQ 'X'.
    l_cost = '3'.
  ENDIF.


** 일괄전기용 비용항목 체크z
*  SELECT *
*    FROM ztitig07
*    WHERE cstct EQ L_cost.
*  ENDSELECT.
*  IF sy-subrc <> 0.
*    MESSAGE e877.
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
  RANGES: lr_bdldt   FOR   ztitbdk-bdldt OCCURS 1.

  DATA:   l_count    TYPE  i.
  DATA:   l_iblno(10)    TYPE  c.
  DATA:   l_price    TYPE f.
  DATA: l_ddtext LIKE dd07t-ddtext,
        l_txz01  LIKE ekpo-txz01.


  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_fwdfm>.
  FIELD-SYMBOLS: <l_ddtext>.
  FIELD-SYMBOLS: <l_belnr>.
  FIELD-SYMBOLS: <l_wrbtr>.
  FIELD-SYMBOLS: <l_iblno>.
  FIELD-SYMBOLS: <l_cdrdt>,
                 <l_volum>,
                 <l_voleh>,
                 <l_pname>,
                 <l_werks>,
                 <l_meins>,
                 <l_biwet>.
*>비용종류에 따른 기준일(반입일,반출일) 검색조건 변경.
  CASE l_cost.
    WHEN '1' OR '2'.

    WHEN '3'.
      LOOP AT s_bindt.
        MOVE : s_bindt TO lr_bdldt.
        APPEND lr_bdldt.
      ENDLOOP.

      REFRESH :s_bindt.
  ENDCASE.



  REFRESH : <gt_table>.
*> PROGRESS Display.
  g_line1    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_line1.


  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE <gt_table>
    FROM ztitbik AS i INNER JOIN ztitbdk AS d
     ON  i~iblno EQ d~iblno
    WHERE i~bukrs  IN s_bukrs    "회사코드.
      AND i~bindt  IN s_bindt    "반입일
      AND i~blocc  IN s_blocc      "보세구역
      AND i~truck  IN s_truck      "운송업자.
      AND d~bdldt  IN lr_bdldt .  "반출일.
  IF sy-subrc NE 0.
    MESSAGE s902.   EXIT.
  ENDIF.


  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.


  ASSIGN COMPONENT 'FWDFM' OF STRUCTURE                 "운송형태
                      <ls_table> TO <l_fwdfm>.
  ASSIGN COMPONENT 'DDTEXT' OF STRUCTURE               "운송형태설명
                      <ls_table> TO <l_ddtext>.
  ASSIGN COMPONENT 'WRBTR' OF STRUCTURE                "비용금액
                      <ls_table> TO <l_wrbtr>.
  ASSIGN COMPONENT 'BELNR' OF STRUCTURE                 "비용
                      <ls_table> TO <l_belnr>.
  ASSIGN COMPONENT 'IBLNO' OF STRUCTURE
                      <ls_table> TO <l_iblno>.         "B/L 관리번호
  ASSIGN COMPONENT 'CDRDT' OF STRUCTURE
                      <ls_table> TO <l_cdrdt>.         "신고수리일.

  ASSIGN COMPONENT 'VOLUM' OF STRUCTURE
                      <ls_table> TO <l_volum>.          "볼륨
  ASSIGN COMPONENT 'VOLEH' OF STRUCTURE
                      <ls_table> TO <l_voleh>.          "중량단위
  ASSIGN COMPONENT 'BIWET' OF STRUCTURE
                      <ls_table> TO <l_biwet>.          "반입중량
  ASSIGN COMPONENT 'MEINS' OF STRUCTURE
                      <ls_table> TO <l_meins>.          "기본단위
  ASSIGN COMPONENT 'WERKS' OF STRUCTURE                  "플랜트
                      <ls_table> TO <l_werks>.
  ASSIGN COMPONENT 'PNAME' OF STRUCTURE                "플랜트명
                      <ls_table> TO <l_pname>.


  LOOP AT <gt_table> INTO <ls_table>.
    g_tabix = sy-tabix.
*>수입신고일.
    SELECT SINGLE cdrdt
        INTO <l_cdrdt>
        FROM ztitcck
       WHERE iblno EQ <l_iblno>.


*>전기 구분.
    IF p_posta NE 'X' .
      SELECT SINGLE belnr
          INTO <l_belnr>
          FROM ztivcs00
         WHERE refno EQ <l_iblno>
          AND  expcd EQ ztitig07-expcd
          AND  expgr EQ ztitig07-expgr.
      IF sy-subrc EQ 0.
        IF p_post1 EQ 'X'.
          DELETE <gt_table> INDEX g_tabix.
          CONTINUE.
        ENDIF.
      ELSE.
        IF p_post2 EQ 'X'.
          DELETE <gt_table> INDEX g_tabix.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.

*>비용계산.
    CASE l_cost.
      WHEN '1'.
        IF <l_volum> LE 3.
          <l_wrbtr> = 19500 / 100.
        ELSE.
          <l_wrbtr> = CEIL( <l_volum> ) * ztitig07-price / 100.
          l_price = <l_wrbtr> * 100.
          <l_wrbtr> = TRUNC( l_price / 10 ) * 10.
          <l_wrbtr> = <l_wrbtr> / 100.
        ENDIF.
      WHEN '2'.
        <l_wrbtr> = <l_volum> * ztitig07-frate * ztitig07-price .
        l_price = <l_wrbtr> .
        <l_wrbtr> = TRUNC( l_price * 10 ) * 10.
        <l_wrbtr> = <l_wrbtr> / 100.

      WHEN '3'.
        IF <l_biwet> LT 1 AND <l_meins> NE 'TO'.
          <l_wrbtr> = 3000 / 100.
        ELSE.
          <l_wrbtr> = <l_biwet> * ztitig07-price / 100.
          l_price = <l_wrbtr> * 100.
          <l_wrbtr> = TRUNC( l_price / 10 ) * 10.
          <l_wrbtr> = <l_wrbtr> / 100.
        ENDIF.
    ENDCASE.


*>운송형태
    SELECT SINGLE fwdfm
        INTO <l_fwdfm>
        FROM ztitblk
       WHERE iblno EQ <l_iblno>.

    PERFORM  get_domain_value_text(ztir0000) USING 'ZTIFWDFM'
                                                   <l_fwdfm>
                                                   <l_ddtext>.

*>PLANT 명
    SELECT SINGLE name1
       INTO <l_pname>
       FROM t001w
       WHERE werks EQ <l_werks>.



    IF sy-subrc NE 0.
      DELETE <gt_table> INDEX g_tabix.
      CONTINUE.
    ENDIF.

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
  ac 'ITAB   TRUCK ZTITBIK                      TRUCK'.   "운송업자.
  ac 'ITAB   WERKS ZTITBLK                      WERKS  '.    "플랜트.
  ac 'ITAB   PNAME T001W                        NAME1  '.
  "플랜트명  .
  ac 'ITAB   EBELN ZTITBIK                      EBELN '.     "P/O.
  ac 'ITAB   IBLNO ZTITBIK                      IBLNO X'.
  "B/L관리번호
  ac 'ITAB   BLNUM ZTITBIK                      BLNUM '.     "B/L 번호
  ac 'ITAB   BINDT ZTITBIK                      BINDT  '.     "반입일
  ac 'ITAB   BDLDT ZTITBDK                      BDLDT  '.     "반출일
  ac 'ITAB   BPKCN ZTITBIK                      BPKCN  QBPKCNU'.
  "누계반입포장개수.
  ac 'ITAB   BPKCNUZTITBIK                      BPKCNU  '.
  "포장종류.
  ac 'ITAB   BIWET ZTITBIK                      BIWET  QMEINS'.
  "반입중량.
  ac 'ITAB   MEINS ZTITBIK                      MEINS  '.     "기본단위.
  ac 'ITAB   VOLUM ZTITBLK                      VOLUM  QVOLEH'.   "볼륨.
  ac 'ITAB   VOLEH ZTITBLK                      VOLEH  '.     "볼륨단위.
  ac 'ITAB   BIDNR ZTITBIK                      BIDNR '.
  "반입신고번호.
  ac 'ITAB   FWDFM ZTITBLK                      FWDFM X '.
  "운송형태.
  ac 'ITAB   DDTEXTDD07T                        DDTEXT'.
  "운송형태설명.

  ac 'ITAB   CDRDT ZTITCCK                      CDRDT '.
  "신고수리일.

  ac 'ITAB   WRBTR ZTIVCS00                     WRBTR  '. "전표통화금액.
  ac 'ITAB   BELNR ZTIVCS00                     BELNR  '.
  "회계전표번호.



**> Create field catagory table
*  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
*    EXPORTING
*      i_structure_name       = 'ZTIVBL00'
*      i_client_never_display = 'X'
*    CHANGING
*      ct_fieldcat            = it_fieldcat_g[].

*>Adjust ALV field category
  PERFORM adjust_fieldcat.         ">Adjust ALV field category

  fc1[] = fc[].

  ac 'ITAB   COLOR SLIS_T_SPECIALCOL_ALV              X'.

  LOOP AT fc1 INTO fcs.
    CLEAR: fcs-key .
    CASE fcs-fieldname.
      WHEN 'ICON'.
        fcs-icon     = 'X'.
      WHEN 'BLNUM' OR 'EBELN'
            OR 'IBINO'.
        fcs-hotspot = 'X'.
        fcs-key     = 'X'.
      WHEN 'IBLNO'.
        fcs-hotspot = 'X'.
        fcs-key     = 'X'.
      WHEN 'WRBTR'.
        fcs-currency = 'KRW'.
      WHEN 'SMAMT'.
        fcs-seltext_l     = 'B/L 금액'.
        fcs-seltext_m     = 'B/L 금액'.
        fcs-seltext_s     = 'B/L 금액'.
        CLEAR fcs-ref_fieldname.
      WHEN 'NAME2'.
        fcs-seltext_l     = '거래처명'.
        fcs-seltext_m     = '거래처명'.
        fcs-seltext_s     = '거래처명'.
        fcs-outputlen       = '20'.
        CLEAR fcs-ref_fieldname.
      WHEN 'NAME1'.
        fcs-seltext_l     = '운송사'.
        fcs-seltext_m     = '운송사'.
        fcs-seltext_s     = '운송사'.
        CLEAR fcs-ref_fieldname.
      WHEN 'TXZ01'.
        fcs-seltext_l     = '대표품명'.
        fcs-seltext_m     = '대표품명'.
        fcs-seltext_s     = '대표품명'.
        CLEAR fcs-ref_fieldname.
      WHEN 'WERKS'.
        fcs-seltext_l     = '플랜트'.
        fcs-seltext_m     = '플랜트'.
        fcs-seltext_s     = '플랜트'.
        CLEAR fcs-ref_fieldname.
      WHEN 'PNAME'.
        fcs-seltext_l     = '플랜트명'.
        fcs-seltext_m     = '플랜트명'.
        fcs-seltext_s     = '플랜트명'.
        CLEAR fcs-ref_fieldname.
      WHEN 'DDTEXT'.
        fcs-seltext_l     = '운송형태'.
        fcs-seltext_m     = '운송형태'.
        fcs-seltext_s     = '운송형태'.
        CLEAR fcs-ref_fieldname.
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


  SET TITLEBAR 'T1000' WITH '보세창고입출비용 일괄전기 '.

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
    WHEN p_step1.	">의뢰대상
      APPEND 'ZTIT002'  TO extab.
      APPEND 'ZTIT005'  TO extab.
    WHEN p_step2. ">신청대상
      APPEND 'ZTIT002'  TO extab.
      APPEND 'ZTIT005'  TO extab.

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
        IF r_ucomm EQ 'ZTIT203' OR
           r_ucomm EQ 'ZBIDIS'.
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
        WHEN 'BLNUM' OR 'IBLNO'.
          ASSIGN COMPONENT 'IBLNO' OF STRUCTURE
                                <ls_table> TO <l_field1>.
          SET PARAMETER ID 'ZTIIBLNO' FIELD <l_field1>.
          CALL TRANSACTION 'ZTIT203' AND SKIP FIRST SCREEN.
        WHEN 'EBELN' .
          SET PARAMETER ID 'BES' FIELD space.
          ASSIGN COMPONENT 'EBELN' OF STRUCTURE
                            <ls_table> TO <l_field1>.
          IF NOT <l_field1> IS INITIAL.
            SET PARAMETER ID 'BES' FIELD <l_field1>.
            CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
          ENDIF.
        WHEN 'IBINO' .
          ASSIGN COMPONENT 'IBINO' OF STRUCTURE
                            <ls_table> TO <l_field1>.
          IF NOT <l_field1> IS INITIAL.
            SET PARAMETER ID 'ZTIIBINO' FIELD <l_field1>.
            CALL TRANSACTION 'ZTIT463' AND SKIP FIRST SCREEN.
          ENDIF.
        WHEN OTHERS.              ">해당작업수행..
      ENDCASE.

    WHEN 'ZTIT203'.   " B/L 조회
      LOOP AT <gt_table> INTO <ls_table>.
        IF <l_field1> EQ 'X'.
          ASSIGN COMPONENT 'IBLNO' OF STRUCTURE
                                <ls_table> TO <l_field2>.
          SET PARAMETER ID 'ZTIIBLNO' FIELD <l_field2>.
          CALL TRANSACTION 'ZTIT203' AND SKIP FIRST SCREEN.
        ENDIF.
        IF sy-subrc NE 0.
          MESSAGE s906.            EXIT.
        ENDIF.
      ENDLOOP.

    WHEN 'COSTDOC'.    "반입화면
      ASSIGN COMPONENT 'BOX' OF STRUCTURE
                            <ls_table> TO <l_field1>.
      LOOP AT <gt_table> INTO <ls_table>.
        IF <l_field1> EQ 'X'.
          ASSIGN COMPONENT 'IBINO' OF STRUCTURE
                            <ls_table> TO <l_field1>.
          IF NOT <l_field1> IS INITIAL.
            SET PARAMETER ID 'ZTIIBINO' FIELD <l_field1>.
            CALL TRANSACTION 'ZTIT463' AND SKIP FIRST SCREEN.
          ENDIF.
        ENDIF.
      ENDLOOP.

    WHEN 'DOCPRT'.    "화찰출력
      IF it_ztsprtctl[] IS INITIAL.
        REFRESH : it_ztsprtctl.
        CLEAR: it_ztsprtctl.

        LOOP AT it_ztsprtctl.
          MOVE sy-langu      TO    it_ztsprtctl-spras.
          MODIFY it_ztsprtctl INDEX sy-tabix.
        ENDLOOP.

        DESCRIBE TABLE it_ztsprtctl LINES g_line.
        IF g_line EQ 0.
          CLEAR: it_ztsprtctl.
          MOVE: t001-land1    TO    it_ztsprtctl-land1,
                sy-langu      TO    it_ztsprtctl-spras.
          APPEND it_ztsprtctl.
        ENDIF.
      ENDIF.

      CALL FUNCTION 'Z_TS_OUTPUTS_DOCUMENT_BY_TABLE'
        EXPORTING
          im_imexi            = 'I'
          im_docty            = 'BI'
          im_repid            = 'ZTIR4600'
          im_rread            = 'X'
        IMPORTING
          ex_answer           = l_answer
        TABLES
          ct_prtctl           = it_ztsprtctl
          ct_prt_doc          = it_prt_doc
          ct_docno            = lt_seldoc
        EXCEPTIONS
          no_output_documents = 1
          OTHERS              = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
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
  DATA: l_header(20) TYPE c.
  DATA: header TYPE slis_listheader OCCURS 0 WITH HEADER LINE.

  REFRESH header.

  header-typ = 'H'.
*  CASE 'X'.
*    WHEN p_step1.
*      l_header = 'B/L 지정 '.
*    WHEN p_step2.
*      l_header = 'B/L 미지정 '.
*    WHEN OTHERS.
*      l_header = ' '.
*  ENDCASE.

  header-info = ' 보세창고입출비용 일괄전기'.
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
      ASSIGN COMPONENT 'IBINO' OF STRUCTURE
                            <ls_table> TO <l_field2>.
      pt_docno-docno = <l_field2>.
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
