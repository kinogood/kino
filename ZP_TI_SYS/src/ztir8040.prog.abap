************************************************************************
*                                                                      *
* Title         : ZTIR8040                                             *
*                                                                      *
* Description   : [Report] 유보금 Due List                             *
*                                                                      *
* Creation Date : 2003/10/15                                           *
*                                                                      *
* Author        : Seung Jun, Lee                                       *
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
PROGRAM   ztir8040
          MESSAGE-ID zmti00
          NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis.   "> Globale Type(ALV)

************************************************************************
* User Included                                                        *
************************************************************************
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
        t161,      ">Purchasing Document Types
        t134,      ">Material Types
        t134t,     ">Material Types Descriptions
        t024d,     ">MRP controllers
        mara,      ">General Material Data
        marc,      ">Plant Data for Material
        mard,      ">Storage Location Data for Material
        mslb,      ">Special Stocks with Vendor
        mbew,      ">Material Valuation
        march,     ">Plant Data for Material: History
        mardh,     ">Storage Location Data for Material: History
        mslbh,     ">Special Stocks with Vendor: History
        mbewh,     ">Material Valuation: History
        mkpf,      ">Header: Material Document
        mseg,      ">Document Segment: Material
        makt,      ">Material Descriptions
        marm,      ">Units of Measure for Material
        lfa1  ,    ">Vendor Master (General Section)
        lfb1  ,    ">Vendor Master (Company Code)
        t024e ,    ">Purchasing Organizations
        t024  ,    ">Purchasing Groups
        t163b ,    ">TEXT
        t163c ,    ">TEXT
        t685t ,    ">TEXT
        ekbz  ,    ">History per Purchasing Document: Delivery Costs
        ekbe  ,    ">History per Purchasing Document
        ekko,      ">Purchasing Document Header
        ekpo  ,    ">Purchasing Document Items
        ekkn,      ">Account Assignment in Purchasing Document
        dfies .    ">DD Interface: Table Fields for DDIF_FIELDINFO_GET

TABLES: ztitblk,
        ztitblp,
        ztitivk,
        ztitrqs,
        ztitpnk.

TYPES: BEGIN OF ty_list.
        INCLUDE STRUCTURE ztisalvret.
TYPES: box        TYPE c,
       color      TYPE slis_t_specialcol_alv.
TYPES: END OF ty_list.

DATA: it_list      TYPE STANDARD TABLE OF ty_list,
      gs_list      TYPE ty_list,
      ls_list      TYPE ty_list.

*> 유보금 .
DATA: BEGIN OF it_ztispnit OCCURS 0.
        INCLUDE STRUCTURE ztispnit.
DATA: END   OF it_ztispnit.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
DATA: l_count TYPE i.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
    c_save(1)   TYPE  c             VALUE 'A'.
** JS전선 회사코드 2007/04 --------------------------------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000'.   ">Company code
** JS전선 회사코드 2007/04 --------------------------------------
************************************************************************
* Internal Tables                                                      *
************************************************************************

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

***********************************************************************
* SELECT-OPTIONS / PARAMETERS
***********************************************************************
SELECTION-SCREEN BEGIN OF BLOCK dbsel WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_bukrs  FOR ztitblk-bukrs
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk
                    MODIF  ID iog ,
  s_ekorg  FOR ztitblk-ekorg MODIF ID iog,                  "4구매조직.
  s_ekgrp  FOR ztitblk-ekgrp MODIF ID iog,                  "3구매그룹.
  s_iblno  FOR ztitblk-iblno MODIF ID iog      "B/L 관리번호.
                              MEMORY ID ztiiblno,
  s_ivnum  FOR ztitivk-ivnum MODIF ID iog,     "Invoce Number.
  s_ivono  FOR ztitivk-ivono MODIF ID iog,     "Invoice 관리번호.
  s_lifnr  FOR ztitblk-lifnr MODIF ID iog,     "10공급업체 계정번호.
  s_cnam   FOR ztitblk-cnam  MODIF ID iog,                  "12작성인.
  s_cdat   FOR ztitblk-cdat  MODIF ID iog,                  "8생성일.
  s_unam   FOR ztitblk-unam  MODIF ID iog,     "12최종변경인.
  s_udat   FOR ztitblk-udat  MODIF ID iog.                  "8변경일.
SELECTION-SCREEN END OF BLOCK dbsel.

SELECTION-SCREEN BEGIN OF BLOCK dbsel2 WITH FRAME TITLE text-003.
PARAMETERS: p_full RADIOBUTTON GROUP ab2 DEFAULT 'X',
            p_list RADIOBUTTON GROUP ab2.
SELECTION-SCREEN END OF BLOCK dbsel2.

SELECTION-SCREEN: BEGIN OF BLOCK alv WITH FRAME TITLE text-002.
PARAMETERS: alv_def LIKE disvariant-variant.
SELECTION-SCREEN: END OF BLOCK alv.

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

  SET TITLEBAR 'T1000' WITH '유보금 Notice'.

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

  DATA:  l_count     TYPE  i,
         l_opamt     LIKE ztitrqs-opamt.

*> PROGRESS Display.
  g_line1    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_line1.

*> B/L 데이타 select.
  SELECT p~iblno h~pspnr h~bukrs h~ekorg h~ekgrp h~lifnr
         h~rtchg h~ppamt h~ivamt h~waers h~ivamp AS smamt
    INTO CORRESPONDING FIELDS OF TABLE it_list
    FROM ztitivp AS p INNER JOIN ztiviv00 AS h
      ON p~iblno  EQ h~iblno
   WHERE h~bukrs  IN  s_bukrs
     AND p~iblno  IN  s_iblno
     AND h~ekorg  IN  s_ekorg
     AND h~ekgrp  IN  s_ekgrp
     AND h~lifnr  IN  s_lifnr
     AND h~ivono  IN s_ivono
     AND h~ivnum  IN s_ivnum
     AND h~rtchg  NE 0
     AND h~cnam   IN  s_cnam
     AND h~cdat   IN  s_cdat
     AND h~unam   IN  s_unam
     AND h~udat   IN  s_udat
   GROUP BY p~iblno h~pspnr h~bukrs h~ekorg h~ekgrp h~lifnr
         h~rtchg h~ppamt h~ivamt h~waers  h~ivamp.
  IF sy-subrc NE 0.
    MESSAGE s902.
    EXIT.
  ENDIF.

  LOOP AT it_list INTO gs_list.

    g_tabix = sy-tabix.

*>  유보금 전기 누적 수량.
    CLEAR: l_opamt.
    SELECT  SUM( pntam )
      INTO  l_opamt
      FROM  ztitpnk
     WHERE  iblno  EQ gs_list-iblno
       AND  rpaid  EQ 'X'.

*>  유보금 가능 수량.
    gs_list-rtchgs =  gs_list-rtchg - l_opamt.

    IF gs_list-rtchgs LE 0.
      DELETE it_list INDEX g_tabix.
      CONTINUE.
    ENDIF.

    SELECT SINGLE blnum
      INTO gs_list-blnum
      FROM ztitblk
     WHERE iblno EQ gs_list-iblno.


    SELECT SINGLE name1
      INTO gs_list-name1
      FROM lfa1
     WHERE lifnr EQ gs_list-lifnr .

    CLEAR ztitblp.
    SELECT *
      FROM ztitblp UP TO 1 ROWS
     WHERE iblno = gs_list-iblno.
    ENDSELECT.

    MOVE: ztitblp-matnr TO gs_list-matnr,
          ztitblp-txz01 TO gs_list-txz01,
          ztitblp-stawn TO gs_list-stawn,
          ztitblp-ebeln TO gs_list-ebeln,
          ztitblp-reqno TO gs_list-reqno.

    IF NOT gs_list-reqno IS INITIAL.

      CLEAR ztitrqs.
      SELECT SINGLE *
        FROM ztitrqs
       WHERE reqno EQ gs_list-reqno.

      MOVE: ztitrqs-opnno TO gs_list-opnno,
            ztitrqs-opndt TO gs_list-opndt,
            ztitrqs-zterm TO gs_list-zterm,
            ztitrqs-opamt TO gs_list-opamt.
    ENDIF.

*    PERFORM  get_domain_value_text(ZTIr0000) USING 'ZTIEDITY'
*                                                  gs_list-edity
*                                                  gs_list-edityx.

    MODIFY it_list FROM gs_list.
  ENDLOOP.

  DESCRIBE TABLE it_list LINES g_line.
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

  CLEAR  fcs.
  fcs-tabname   = 'IT_LIST'.
  fcs-fieldname = 'BOX'.
  APPEND  fcs TO fc1.

*> Create field catagory table
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name   = 'ZTISALVRET'
      i_internal_tabname = 'IT_LIST'
    CHANGING
      ct_fieldcat        = fc[].

  fc1[] = fc[].

  CLEAR  fcs.
  fcs-tabname   = 'IT_LIST'.
  fcs-fieldname = 'COLOR'.
  fcs-ref_tabname = 'SLIS_T_SPECIALCOL_ALV'.
  fcs-no_out      = 'X'.
  APPEND  fcs TO fc1.

  LOOP AT fc1 INTO fcs.
    CLEAR: fcs-key .
    CASE fcs-fieldname.
      WHEN 'COLOR'.
        fcs-no_out  = 'X'.
      WHEN 'IBLNO'.
        fcs-col_pos = 1.
        fcs-key     = 'X'.
        fcs-hotspot  = 'X'.
      WHEN 'BLNUM'.
        fcs-col_pos = 2.
      WHEN 'LIFNR'.
        fcs-col_pos = 3.
      WHEN 'NAME1'.
        fcs-col_pos = 4.
        fcs-seltext_l = '공급업체명'.
        fcs-seltext_m = '공급업체명'.
        fcs-seltext_s = '명'.
      WHEN 'WAERS'.
        fcs-col_pos = 5.
      WHEN 'RTCHG'.
        fcs-col_pos = 6.
      WHEN 'RTCHGS'.
        fcs-col_pos = 7.
      WHEN 'PPAMT'.
        fcs-col_pos = 8.
        fcs-no_out  = 'X'.
      WHEN 'SMAMT'.
        fcs-col_pos = 9.
      WHEN 'IVAMT'.
        fcs-col_pos = 10.
        fcs-no_out  = 'X' .
      WHEN 'EBELN'.
        fcs-col_pos = 11.
        fcs-seltext_l = '대표구매전표'.
        fcs-seltext_m = '대표구매전표'.
        fcs-seltext_s = '대표구매전표'.
        fcs-hotspot  = 'X'.
      WHEN 'PSPNR'.
        fcs-col_pos = 12.
      WHEN 'MATNR'.
        fcs-col_pos = 13.
        fcs-seltext_l = '대표자재문서'.
        fcs-seltext_m = '대표자재문서'.
        fcs-seltext_s = '대표자재문서'.
        fcs-hotspot  = 'X'.
      WHEN 'TXZ01'.
        fcs-col_pos = 14.
      WHEN 'REQNO'.
        fcs-col_pos = 15.
        fcs-hotspot  = 'X'.
      WHEN 'OPNNO'.
        fcs-seltext_l = '원 수입개설번호'.
        fcs-seltext_m = '원 L/C번호'.
        fcs-seltext_s = 'L/C번호'.
        fcs-col_pos = 16.
      WHEN 'OPNDT'.
        fcs-col_pos = 17.
      WHEN 'OPAMT'.
        fcs-col_pos = 18.
      WHEN 'BLDTY'.
        fcs-no_out  = 'X'.
      WHEN 'BUKRS'.
        fcs-no_out  = 'X'.
      WHEN 'EKORG'.
        fcs-no_out  = 'X'.
      WHEN 'EKGRP'.
        fcs-no_out  = 'X'.
      WHEN 'BLETD'.
        fcs-col_pos = 19.
      WHEN 'BLETA'.
        fcs-col_pos = 20.
      WHEN 'STAWN'.
        fcs-col_pos = 32.
        fcs-no_out  = 'X'.
      WHEN 'ZTERM'.
        fcs-col_pos = 43.
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

  SET TITLEBAR 'T1000' WITH '유보금'.

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
        t_outtab                 = it_list.

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

*  APPEND 'ZTIT002'  TO extab.
  APPEND 'ZTIT005'  TO extab.
  SET PF-STATUS 'STANDARD' EXCLUDING extab.

  SET TITLEBAR 'T1000' WITH '유보금 Notice'.

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


  CASE r_ucomm.
*    WHEN 'ZTIT005'.

    WHEN 'ZTIT002'.
      CLEAR: l_count.
      LOOP AT it_list INTO gs_list WHERE box = 'X'.
        ADD 1 TO l_count.
        SELECT  *
          INTO  CORRESPONDING FIELDS OF TABLE it_ztispnit
          FROM  ztivbl00
         WHERE  iblno  EQ  gs_list-iblno.

      ENDLOOP.
      CASE l_count.
        WHEN 0.
          MESSAGE s006(0k).   EXIT.
        WHEN 1.
          CLEAR: l_count.
          LOOP AT it_ztispnit.
*            MOVE: it_ZTIspnit-blmng    TO it_ZTIspnit-rqmng,
*                  it_ZTIspnit-blmng    TO it_ZTIspnit-rqmngl,
*                  it_ZTIspnit-blmng    TO it_ZTIspnit-rqmngs.
            MODIFY it_ztispnit.
          ENDLOOP.
        WHEN OTHERS.
          MESSAGE s929.       EXIT.
      ENDCASE.
*> Call Dialog
      CALL DIALOG 'Z_TI_PN_CREATE'
        AND SKIP FIRST SCREEN
        EXPORTING
          g_tcode          FROM sy-tcode
          it_ztisrqit      FROM it_ztispnit
          ztisscrcom-iblno FROM gs_list-iblno
        IMPORTING
          ztitpnk.

      IF NOT ztitpnk-pntno IS INITIAL.
        PERFORM get_data_for_display.    ">data select
      ENDIF.

      IF NOT g_line IS INITIAL.
        rs_selfield-refresh = 'X'.
      ELSE.
*> Program 종료.
        IF NOT sy-calld IS INITIAL.
          LEAVE.
        ELSE.
          LEAVE TO SCREEN 0.
        ENDIF.
      ENDIF.

    WHEN 'DISPLAY' OR '&IC1'.    " AUF DOPPELKLICK REAGIERIEN
      CHECK rs_selfield-tabindex GT 0.

      READ TABLE it_list INTO gs_list INDEX rs_selfield-tabindex.
      IF sy-subrc NE 0.
        MESSAGE s906.            EXIT.
      ENDIF.

      CASE rs_selfield-fieldname.
*              SET PARAMETER ID 'ZTIREQNO' FIELD gs_list-refno.
*              SET PARAMETER ID 'ZTIAMDSQ' FIELD gs_list-amdsq.
*              CALL TRANSACTION 'ZTIT003' AND SKIP FIRST SCREEN.

        WHEN 'IBLNO'.
          PERFORM  display_bl_document(ztir0000)
                                       USING gs_list-iblno
                                             space.
        WHEN 'REQNO'.
          PERFORM  display_import_document(ztir0000)
                                       USING gs_list-reqno
                                             space
                                             space.
        WHEN 'EBELN'.
          PERFORM  display_purchase_order(ztir0000)
                                          USING gs_list-ebeln
                                               '00000'.

        WHEN 'MATNR'.
          PERFORM  display_material_master(ztir0000)
                                       USING gs_list-matnr
                                             space
                                             space.

        WHEN OTHERS.              ">해당작업수행..

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
  st_sort-fieldname = 'IBLNO'.
  st_sort-tabname   = 'IT_LIST'.
  st_sort-up        = 'X'.
*  ST_SORT-GROUP     = 'X'.
  st_sort-subtot    = 'X'.
*  ST_SORT-EXPA      = 'X'.
  APPEND st_sort TO it_sort.
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
  header-info = '유보금 Notcie Due List'.

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

    color-color-col = 4.
    color-color-int = 0.
    color-fieldname = 'RTCHG'.
    APPEND color.

    color-color-col = 5.
    color-color-int = 0.
    color-fieldname = 'RTCHGS'.
    APPEND color.

    gs_list-color[] = color[].

    MODIFY it_list FROM gs_list .
  ENDLOOP.

ENDFORM.                    " set_colorize_build

*&---------------------------------------------------------------------*
*&      Form  input_field_check
*&---------------------------------------------------------------------*
FORM input_field_check .

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
    MESSAGE e348(m7) WITH '회사코드'.
  ENDIF.

* Vendor
  READ TABLE s_lifnr INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT lifnr INTO (l_lifnr)
                 FROM lfb1 UP TO 1 ROWS WHERE lifnr IN s_lifnr
                                        AND   bukrs IN s_bukrs.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'LFA1' 'LIFNR' sy-langu
                                  CHANGING dfies g_subrc.
      SET CURSOR FIELD 'S_LIFNR-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.
  ENDIF.

* Purchase Organization
  READ TABLE s_ekorg INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT ekorg INTO (l_ekorg)
                 FROM t024e UP TO 1 ROWS WHERE ekorg IN s_ekorg.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'T024E' 'EKORG' sy-langu
                                  CHANGING dfies g_subrc.
      SET CURSOR FIELD 'S_EKORG-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.
  ENDIF.

* Purchase GROUP
  READ TABLE s_ekgrp INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT ekgrp INTO (l_ekgrp)
                 FROM t024 UP TO 1 ROWS WHERE ekgrp IN s_ekgrp.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'T024' 'EKGRP' sy-langu
                                  CHANGING dfies g_subrc.
      SET CURSOR FIELD 'S_EKGRP-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.
  ENDIF.

ENDFORM.                    " input_field_check
