************************************************************************
*                                                                      *
* Title         : ZTIR2210                                             *
*                                                                      *
* Description   : [Report] 컨테이너 운송의뢰 현황                      *
*                                                                      *
* Creation Date : 2004/12/08                                           *
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
PROGRAM   ztir2210
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
        ztitbik.   ">반입신고 Header table

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
** JS전선 회사코드 2007/04 KSH --------------------------------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
** JS전선 회사코드 2007/04 KSH --------------------------------------
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
  s_truck  FOR ztitblk-truck MODIF ID iog,       "운송업체
  s_werks  FOR ztitblk-werks MODIF ID iog,       "플랜트
  s_ebeln  FOR ztitblp-ebeln MODIF ID iog,       "구매전표번호.
  s_blnum  FOR ztitblk-blnum MODIF ID iog,       "B/L 번호.
  s_iblno  FOR ztitblk-iblno MODIF ID iog	       "B/L 관리번호.
                              MEMORY ID ztiiblno,
  s_inbdt  FOR ztitblk-inbdt MODIF ID iog,       "입항일.
  s_badat  FOR ztitblk-badat MODIF ID iog,       "보세운송일
  s_tdrdt  FOR ztitblk-tdrdt MODIF ID iog,       "운송요청일.
  s_tport  FOR ztitblk-tport MODIF ID iog,       "도착항
  s_sdrlt  FOR ztitblk-sdrlt MODIF ID iog.       "송부처.
SELECTION-SCREEN END OF BLOCK box1.

SELECTION-SCREEN BEGIN OF BLOCK box2 WITH FRAME TITLE text-002.
PARAMETERS: p_step1 RADIOBUTTON GROUP ab1 DEFAULT 'X',
            p_step2 RADIOBUTTON GROUP ab1.
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

  SET TITLEBAR 'T1000' WITH '컨테이너 운송의뢰'.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*  FREE: s_bukrs.    CLEAR: s_bukrs.
*  s_bukrs-sign   = 'I'.
*  s_bukrs-option = 'EQ'.
*  s_bukrs-low    = c_bukrs.
*  APPEND s_bukrs.
** JS전선 회사코드 2007/04 KSH --------------------------------------

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
  SELECT bukrs INTO (l_bukrs)
               FROM t001 UP TO 1 ROWS WHERE bukrs IN s_bukrs.
  ENDSELECT.
  IF sy-subrc <> 0.
    PERFORM get_ftext(rddfie00) USING 'T001' 'BUKRS' sy-langu
                                CHANGING dfies g_subrc.
    SET CURSOR FIELD 'S_BUKRS-LOW'.
    MESSAGE e348(m7) WITH dfies-scrtext_m.
  ENDIF.

* Vendor
*  READ TABLE s_lifnr INDEX 1 TRANSPORTING NO FIELDS.
*  IF sy-subrc = 0.
*    SELECT lifnr INTO (l_lifnr)
*                 FROM lfb1 UP TO 1 ROWS WHERE lifnr IN s_lifnr
*                                        AND   bukrs IN s_bukrs.
*    ENDSELECT.
*    IF sy-subrc <> 0.
*      PERFORM get_ftext(rddfie00) USING 'LFA1' 'LIFNR' sy-langu
*                                  CHANGING dfies g_subrc.
*      SET CURSOR FIELD 'S_LIFNR-LOW'.
*      MESSAGE e348(m7) WITH dfies-scrtext_m.
*    ENDIF.
*  ENDIF.
*
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

  DATA:   l_count    TYPE  i.
  RANGES: lr_bldst   FOR   ztitblk-bldst OCCURS 1.

  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.

  REFRESH : <gt_table>.
*> PROGRESS Display.
  g_line1    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_line1.


*> 수입의뢰 데이타 select.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE <gt_table>
    FROM ztitblk
       WHERE bukrs  IN s_bukrs   "회사코드.
         AND truck  IN s_truck   "TRUCK
         AND werks  IN s_werks   "플랜트
         AND ebeln  IN s_ebeln    "구매오더.
         AND blnum  IN s_blnum    "BL번호
         AND iblno  IN s_iblno    "BL관리번호
         AND inbdt  IN  s_inbdt   "입항일
         AND badat  IN s_badat    "보세운송일
         AND tdrdt  IN  s_tdrdt   "운송요청일
         AND tport  IN s_tport    "도착항
         AND sdrlt  IN s_sdrlt    "송부처
         AND fwdfm  IN ('T' , 'F'). "운송형태

  IF sy-subrc NE 0.
    MESSAGE s902.
  ENDIF.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.
*  FIELD-SYMBOLS: <ls_table>.

  FIELD-SYMBOLS: <l_field3>.
  FIELD-SYMBOLS: <l_field4>.
  FIELD-SYMBOLS: <l_field5>.
  FIELD-SYMBOLS: <l_field6>.
  FIELD-SYMBOLS: <l_field7>.
  FIELD-SYMBOLS: <l_field8>.
  FIELD-SYMBOLS: <l_field9>.
  FIELD-SYMBOLS: <l_field10>.
  FIELD-SYMBOLS: <l_field11>.
  DATA: l_ddtext LIKE dd07t-ddtext,
        l_txz01  LIKE ekpo-txz01.

  LOOP AT <gt_table> INTO <ls_table>.
    g_tabix = sy-tabix.
    ASSIGN COMPONENT 'TRUCK' OF STRUCTURE
                        <ls_table> TO <l_field1>.

    ASSIGN COMPONENT 'NAME1' OF STRUCTURE
                        <ls_table> TO <l_field2>.

    ASSIGN COMPONENT 'RPTTY' OF STRUCTURE
                        <ls_table> TO <l_field3>.

    ASSIGN COMPONENT 'DDTEXT' OF STRUCTURE
                        <ls_table> TO <l_field4>.

    ASSIGN COMPONENT 'WERKS' OF STRUCTURE
                        <ls_table> TO <l_field5>.

    ASSIGN COMPONENT 'PNAME' OF STRUCTURE
                        <ls_table> TO <l_field6>.

    ASSIGN COMPONENT 'TXZ01' OF STRUCTURE
                        <ls_table> TO <l_field7>.

    ASSIGN COMPONENT 'IBLNO' OF STRUCTURE
                        <ls_table> TO <l_field8>.         "B/L 관리번호

    ASSIGN COMPONENT 'FWDFM' OF STRUCTURE
                        <ls_table> TO <l_field9>.         "운송형태

    ASSIGN COMPONENT 'CTNQ2' OF STRUCTURE
                        <ls_table> TO <l_field10>.         "컨테이너수2

    ASSIGN COMPONENT 'CTNQ4' OF STRUCTURE
                        <ls_table> TO <l_field11>.         "컨테이너수4

**>운송업체 필드가 NULL 이면 삭제
    IF <l_field1> IS INITIAL.
      DELETE <gt_table> INDEX g_tabix.
      CONTINUE.
    ENDIF.

*>운송형태가 'T'이면서 CTNQ2 OR CONQ4 필드가 NULL 이면 삭제
    IF <l_field9> EQ 'T' AND ( <l_field10> IS INITIAL
        OR <l_field11> IS INITIAL ).
      DELETE <gt_table> INDEX g_tabix.
      CONTINUE.
    ENDIF.
*>미입고LIST 선택시 삭제 항목들.
    IF p_step2 EQ 'X'.
      SELECT SINGLE *
        FROM ztitbik
        WHERE iblno EQ <l_field8>.
      IF sy-subrc EQ 0.
        DELETE <gt_table> INDEX g_tabix.
        CLEAR ztitbik.
        CONTINUE.
      ELSE.
        SELECT SINGLE *
          FROM ztitgrk
           WHERE iblno EQ  <l_field8>
           AND   igrst EQ 'G'.
        IF sy-subrc EQ 0.
          DELETE <gt_table> INDEX g_tabix.
          CLEAR ztitgrk.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.

*>TRUCKER 명
    SELECT SINGLE name1
       INTO <l_field2>
       FROM lfa1
       WHERE lifnr EQ <l_field1>.

*>신고형태
    PERFORM  get_domain_value_text(ztir0000) USING 'ZTIRPTTY'
                                                   <l_field3>
                                                   <l_field4>.

*>PLANT 명
    SELECT SINGLE name1
       INTO <l_field6>
       FROM t001w
       WHERE werks EQ <l_field5>.

*>대표품명
    SELECT txz01
      INTO <l_field7>
      FROM ztitblp UP TO 1 ROWS
     WHERE iblno EQ  <l_field8>.
    ENDSELECT.

*    IF sy-subrc NE 0.
*      DELETE <gt_table> INDEX g_tabix.
*      CONTINUE.
*    ENDIF.

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
  ac 'ITAB   EBELN ZTITBLK                      EBELN '.     "구매오더
  ac 'ITAB   SMAMT ZTITBLK                      SMAMT  CWAERS '.
  "B/L금액
  ac 'ITAB   WAERS ZTITBLK                      WAERS  '.   "통화
  ac 'ITAB   EKGRP ZTITBLK                      EKGRP  '.   "구매그룹
  ac 'ITAB   BLNUM ZTITBLK                      BLNUM '.     "B/L 번호
  ac 'ITAB   INBDT ZTITBLK                      INBDT'.      "실입항일
*> 공급업체.
  ac 'ITAB   FWDCD ZTITBLK                      TRUCK X'.     "포워더
  ac 'ITAB   FWDTX ZTITBLK                      FWDTX  '.     "포워더명
*> 공급업체.
  ac 'ITAB   TRUCK ZTITBLK                      TRUCK X'.     "운송사
  ac 'ITAB   NAME1 LFA1                         NAME1  '.     "운송사명
  ac 'ITAB   RPTTY ZTITBLK                      RPTTY X '.    "신고형태
  ac 'ITAB   DDTEXTDD07T                        DDTEXT'.
  "신고형태 설명
  ac 'ITAB   CTNQ2 ZTITBLK                      CTNQ2  '.
  "컨테이너수
  ac 'ITAB   CTNQ4 ZTITBLK                      CTNQ4  '.
  "컨테이너수
  ac 'ITAB   WERKS ZTITBLK                      WERKS X '.     "플랜트
  ac 'ITAB   PNAME T001W                        NAME1  '.     "플랜트명
  ac 'ITAB   TPORT ZTITBLK                      TPORT  '.     "도착항
  ac 'ITAB   TXZ01 ZTITBLP                      TXZ01  '.     "대표품명.
  ac 'ITAB   FWDFM ZTITBLK                      FWDFM X '.
  "운송형태.


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
      WHEN 'BLNUM' OR 'EBELN'.
        fcs-hotspot = 'X'.
        fcs-key     = 'X'.
      WHEN 'IBLNO'.
        fcs-hotspot = 'X'.
        fcs-key     = 'X'.
      WHEN 'SMAMT'.
        fcs-seltext_l     = 'B/L 금액'.
        fcs-seltext_m     = 'B/L 금액'.
        fcs-seltext_s     = 'B/L 금액'.
        CLEAR fcs-ref_fieldname.
      WHEN 'EKGRP'.
        fcs-seltext_l     = '구매그룹'.
        fcs-seltext_m     = '구매그룹'.
        fcs-seltext_s     = '구매그룹'.
        FCS-OUTPUTLEN       = '12'.
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
      WHEN 'CTNQ2'.
        fcs-seltext_l     = '20FT'.
        fcs-seltext_m     = '20FT'.
        fcs-seltext_s     = '20FT'.
        CLEAR fcs-ref_fieldname.
      WHEN 'CTNQ4'.
        fcs-seltext_l     = '40FT'.
        fcs-seltext_m     = '40FT'.
        fcs-seltext_s     = '40FT'.
        CLEAR fcs-ref_fieldname.
      WHEN 'PNAME'.
        fcs-seltext_l     = 'PLANT'.
        fcs-seltext_m     = 'PLANT'.
        fcs-seltext_s     = 'PLANT'.
        CLEAR fcs-ref_fieldname.
      WHEN 'DDTEXT'.
        fcs-seltext_l     = '신고형태'.
        fcs-seltext_m     = '신고형태'.
        fcs-seltext_s     = '신고형태'.
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


  SET TITLEBAR 'T1000' WITH '컨테이너  운송의뢰 '.



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
  DATA: l_subrc   LIKE sy-subrc.
  DATA: l_tcode   LIKE sy-tcode.
  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_field>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.
  FIELD-SYMBOLS: <l_field3>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.

*  CASE r_ucomm.
*
*    WHEN 'DISPLAY' .
*      CHECK rs_selfield-tabindex GT 0.
*
*      READ TABLE <gt_table> INTO <ls_table> INDEX rs_selfield-tabindex.
*      IF sy-subrc NE 0.
*        MESSAGE s906.            EXIT.
*      ENDIF.
*
*      ASSIGN COMPONENT 'IBLNO' OF STRUCTURE
*                            <ls_table> TO <l_field1>.
*      SET PARAMETER ID 'ZTIIBLNO' FIELD <l_field1>.
*      CALL TRANSACTION 'ZTIT203' AND SKIP FIRST SCREEN.
*  ENDCASE.
  CASE rs_selfield-fieldname.
    WHEN 'BLNUM'.
      READ TABLE <gt_table> INTO <ls_table> INDEX rs_selfield-tabindex.
      IF sy-subrc NE 0.
        MESSAGE s906.            EXIT.
      ENDIF.
      ASSIGN COMPONENT 'IBLNO' OF STRUCTURE
                            <ls_table> TO <l_field1>.
      SET PARAMETER ID 'ZTIIBLNO' FIELD <l_field1>.
      CALL TRANSACTION 'ZTIT203' AND SKIP FIRST SCREEN.
    WHEN 'EBELN' .
      READ TABLE <gt_table> INTO <ls_table> INDEX rs_selfield-tabindex.
      IF sy-subrc NE 0.
        MESSAGE s906.            EXIT.
      ENDIF.
      ASSIGN COMPONENT 'EBELN' OF STRUCTURE
                        <ls_table> TO <l_field1>.
      SET PARAMETER ID 'BES' FIELD <l_field1>.
      CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

    WHEN OTHERS.              ">해당작업수행..
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
*  CASE 'X'.
*    WHEN p_step1.
*      header-info = '운송의뢰LIST 현황'.
*    WHEN p_step2.
*      header-info = '미입고LIST 현황'.
*
*  ENDCASE.
  header-info = '컨테이너 운송의뢰 현황'.
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
