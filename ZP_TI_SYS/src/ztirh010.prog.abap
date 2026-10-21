************************************************************************
*                                                                      *
* Title         : ZTIRH010                                             *
*                                                                      *
* Description   : [Report] 수량별 진행관리                             *
*                                                                      *
* Creation Date : 2003/10/08                                           *
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
* Date         Programmer        Transport#  Description               *
*----------------------------------------------------------------------*
* 2010/04/30   MMB03             C20100420_51417
*                               :BL,송장,통관,입고수량 로직 추가
***********************************************************************
**
PROGRAM   ztirh010
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
DATA: l_yn    TYPE c.
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

TABLES : ztispohis,
         ztivpo01,
         ztiviv01,
         ztivbl00,
         ztiviv00,
         ztivpn00,
         ztivcc00,
         ztivgr00.

TYPES: BEGIN OF ty_list.
        INCLUDE STRUCTURE ztispohis.
TYPES: END OF ty_list.

DATA: it_list      TYPE STANDARD TABLE OF ty_list,
      gs_list      TYPE ty_list,
      ls_list      TYPE ty_list.

TYPES: BEGIN OF ty_disp.
        INCLUDE STRUCTURE ztispohis.
TYPES: box        TYPE c,
       color      TYPE slis_t_specialcol_alv.
TYPES: END OF ty_disp.
DATA: it_disp      TYPE STANDARD TABLE OF ty_disp,
      gs_disp      TYPE ty_disp,
      ls_disp      TYPE ty_disp.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
DATA: l_count TYPE i.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
** JS전선 회사코드 2007/04 BY-MH.LEE -----------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
** JS전선 회사코드 2007/04 ---------------------------
    c_save(1)   TYPE  c             VALUE 'A'.

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
***********************************************************************
* SELECT-OPTIONS / PARAMETERS
***********************************************************************

SELECTION-SCREEN BEGIN OF BLOCK dbsel2 WITH FRAME TITLE text-003.
PARAMETERS: p_full RADIOBUTTON GROUP ab2 DEFAULT 'X',
            p_list RADIOBUTTON GROUP ab2.
SELECTION-SCREEN END OF BLOCK dbsel2.

SELECTION-SCREEN: BEGIN OF BLOCK alv WITH FRAME TITLE text-003.
PARAMETERS: alv_def LIKE disvariant-variant.
SELECTION-SCREEN: END OF BLOCK alv.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'LOG'.
      screen-input = 0.
      screen-invisible = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
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
  PERFORM alv_variant_check.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM p1102_authorization_check USING s_bukrs-low.
** JS전선 회사코드 2007/04 KSH --------------------------------------

GET ztivpo01.
  CLEAR: gs_list.
  MOVE: ztivpo01-ebeln   TO gs_list-ebeln,
        ztivpo01-ebelp   TO gs_list-ebelp,
        ztivpo01-menge   TO gs_list-menge,
        ztivpo01-rqmng   TO gs_list-rqmng,
        ztivpo01-meins   TO gs_list-meins,
        ztivpo01-matnr   TO gs_list-matnr,
        ztivpo01-txz01   TO gs_list-txz01.
*        ZTIvpo01-pspnr   TO gs_list-pspnr.

  READ TABLE it_list INTO ls_list WITH KEY ebeln = gs_list-ebeln
                                           ebelp = gs_list-ebelp.
  IF sy-subrc EQ 0.
    gs_list-menge = 0.
  ENDIF.
  COLLECT gs_list INTO it_list.

GET ztivbl00.
  CLEAR: gs_list.
  MOVE: ztivbl00-ebeln   TO gs_list-ebeln,
        ztivbl00-ebelp   TO gs_list-ebelp,
        ztivbl00-blmng   TO gs_list-blmng,
        ztivpo01-meins   TO gs_list-meins,
        ztivpo01-matnr   TO gs_list-matnr,
        ztivpo01-txz01   TO gs_list-txz01.
*        ZTIvpo01-pspnr   TO gs_list-pspnr.

  COLLECT gs_list INTO it_list.


GET ztiviv00.
  CLEAR: gs_list.
  MOVE: ztiviv00-ebeln   TO gs_list-ebeln,
        ztiviv00-ebelp   TO gs_list-ebelp,
        ztiviv00-remng   TO gs_list-remng,
        ztivpo01-meins   TO gs_list-meins,
        ztivpo01-matnr   TO gs_list-matnr,
        ztivpo01-txz01   TO gs_list-txz01.
*               ZTIvpo01-pspnr   to gs_list-pspnr.

  COLLECT gs_list INTO it_list.

GET ztivpn00.
  CLEAR: gs_list.
  MOVE: ztivpn00-ebeln   TO gs_list-ebeln,
        ztivpn00-ebelp   TO gs_list-ebelp,
        ztivpn00-pnmng   TO gs_list-pnmng,
        ztivpo01-meins   TO gs_list-meins,
        ztivpo01-matnr   TO gs_list-matnr,
        ztivpo01-txz01   TO gs_list-txz01.
*        ZTIvpo01-pspnr   TO gs_list-pspnr.

  COLLECT gs_list INTO it_list.

GET ztivcc00.
  CLEAR: gs_list.
  MOVE: ztivcc00-ebeln   TO gs_list-ebeln,
        ztivcc00-ebelp   TO gs_list-ebelp,
        ztivcc00-ccmng   TO gs_list-ccmng,
        ztivpo01-meins   TO gs_list-meins,
        ztivpo01-matnr   TO gs_list-matnr,
        ztivpo01-txz01   TO gs_list-txz01.

*        ZTIvpo01-pspnr   TO gs_list-pspnr.

  COLLECT gs_list INTO it_list.

GET ztivgr00.
  CLEAR: gs_list.
  MOVE: ztivgr00-ebeln   TO gs_list-ebeln,
        ztivgr00-ebelp   TO gs_list-ebelp,
        ztivgr00-grmng   TO gs_list-grmng,
        ztivpo01-meins   TO gs_list-meins,
        ztivpo01-matnr   TO gs_list-matnr,
        ztivpo01-txz01   TO gs_list-txz01.
*        ZTIvpo01-pspnr   TO gs_list-pspnr.

  COLLECT gs_list INTO it_list.
************************************************************************
*                                                                      *
* START-OF-SELECTION Event                                             *
*                                                                      *
************************************************************************
*START-OF-SELECTION.
*  PERFORM clearing_work_area.      ">Initialize internal table
*  PERFORM set_fieldcat_build.      ">Set ALV field category
*  PERFORM get_data_for_display.    ">data select




************************************************************************
*                                                                      *
* END-OF-SELECTION Event                                               *
*                                                                      *
************************************************************************
END-OF-SELECTION.

  PERFORM clearing_work_area.      ">Initialize internal table
  PERFORM set_fieldcat_build.      ">Set ALV field category
  PERFORM get_data_for_display.    ">data select
  CHECK g_line NE 0.
**>--------------------------------------------------------
**> PROGRESS INDICATOR DISPLAY.
**>  4.  LIST DISPLAY
**>--------------------------------------------------------
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

  SET TITLEBAR 'T1000' WITH '수량별진행관리'.

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

  DATA:  l_count     TYPE  i.

*> PROGRESS Display.
  g_line1    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_line1.

  DATA: gs_proj LIKE proj,
        lv_remng LIKE ztiviv00-remng,
        lv_blmng LIKE ztivbl00-blmng,
        lv_ccmng LIKE ztivcc00-ccmng,
        lv_grmng LIKE ztivgr00-grmng.

  LOOP AT it_list INTO gs_list.
    g_tabix  =  sy-tabix.

**********************************************************************
* C20100420_51417
**********************************************************************
* BL수량
    IF gs_list-blmng = 0.

      CLEAR : ztivbl00, lv_blmng.

      SELECT SUM( blmng )
        INTO lv_blmng
        FROM ztivbl00
       WHERE ebeln EQ gs_list-ebeln
         AND ebelp EQ gs_list-ebelp.

      gs_list-blmng = lv_blmng.

    ENDIF.

* 송장수량
    IF gs_list-remng = 0.

      CLEAR : ztiviv00, lv_remng.

      SELECT SUM( remng )
        INTO lv_remng
        FROM ztiviv00
       WHERE ebeln EQ gs_list-ebeln
         AND ebelp EQ gs_list-ebelp.

      gs_list-remng = lv_remng.

    ENDIF.

* 통관수량
    IF gs_list-ccmng = 0.

      CLEAR : ztivcc00, lv_ccmng.

      SELECT SUM( ccmng )
        INTO lv_ccmng
        FROM ztivcc00
       WHERE ebeln EQ gs_list-ebeln
         AND ebelp EQ gs_list-ebelp.

      gs_list-ccmng = lv_ccmng.

    ENDIF.

* 입고수량
    IF gs_list-grmng = 0.

      CLEAR : ztivgr00, lv_grmng.

      SELECT SUM( grmng )
        INTO lv_grmng
        FROM ztivgr00
       WHERE ebeln EQ gs_list-ebeln
         AND ebelp EQ gs_list-ebelp.

      gs_list-grmng = lv_grmng.

    ENDIF.

**********************************************************************

*

    SELECT SINGLE ps_psp_pnr nplnr
      INTO (ekkn-ps_psp_pnr, ekkn-nplnr)
      FROM ekkn
     WHERE ebeln EQ gs_list-ebeln
       AND ebelp EQ gs_list-ebelp
       AND zekkn EQ '01'.
*>
    CLEAR: gs_proj.

    IF NOT ekkn-ps_psp_pnr IS INITIAL.
      PERFORM get_parent_wbs_element(ztir0000)
                                     USING ekkn-ps_psp_pnr
                                           gs_proj.
    ENDIF.
    IF NOT ekkn-nplnr IS INITIAL.
      PERFORM get_wbs_element_by_network(ztir0000)
                                         USING ekkn-nplnr
                                               gs_proj.
    ENDIF.
    gs_list-pspnr = gs_proj-pspnr.

    MODIFY it_list FROM gs_list.
  ENDLOOP.

  DESCRIBE TABLE it_list LINES g_line.
  IF g_line EQ 0.
    MESSAGE s902.
  ENDIF.

  CLEAR it_disp.
  LOOP AT it_list INTO gs_list.
    MOVE-CORRESPONDING gs_list TO gs_disp.
    APPEND gs_disp TO it_disp.
  ENDLOOP.

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
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name   = 'ZTISPOHIS'
      i_internal_tabname = 'IT_LIST'
    CHANGING
      ct_fieldcat        = fc[].

  fc1[] = fc[].

  LOOP AT fc1 INTO fcs.
    CLEAR: fcs-key .
    CASE fcs-fieldname.
      WHEN 'FLAG'.
        fcs-no_out  = 'X'.
      WHEN 'EBELN' OR 'EBELP'.
        fcs-hotspot = 'X'.
        fcs-key     = 'X'.
      WHEN 'MATNR'.
        fcs-hotspot = 'X'.
      WHEN 'PSPNR'.
        fcs-hotspot = 'X'.
      WHEN 'OPAMT' OR 'ITPA1'.
        fcs-do_sum = 'X'.
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


  SET TITLEBAR 'T1000' WITH '상태별 현황'.

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
        t_outtab                 = it_disp.

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

  CASE r_ucomm.
    WHEN 'ZTIT005'.

    WHEN 'ZTIT002'.
*      ASSIGN COMPONENT 'BOX' OF STRUCTURE
*                               <ls_table> TO <l_field>.
*      CLEAR: l_count.
*      LOOP AT <gt_table> INTO   <ls_table>.
*        IF <l_field> EQ 'X'.
*          ADD 1 TO l_count.
*          l_index = sy-tabix.
*        ENDIF.
*      ENDLOOP.
*      IF l_count NE 1.
*        MESSAGE s035.
*      ELSE.
*        READ TABLE <gt_table> INTO   <ls_table>
*                              INDEX l_index.
*
*        ASSIGN COMPONENT 'REQNO' OF STRUCTURE
*                              <ls_table> TO <l_field1>.
**        ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
**                              <ls_table> TO <l_field2>.
*        SET PARAMETER ID 'ZTIREQNO' FIELD <l_field1>.
**          SET PARAMETER ID 'ZTIAMDSQ' FIELD <l_field2>.
*        CALL TRANSACTION 'ZTIT101' AND SKIP FIRST SCREEN .
*        PERFORM get_data_for_display.    ">data select
*        rs_selfield-refresh = 'X'.
*      ENDIF.

    WHEN 'DISPLAY' OR '&IC1'.    " AUF DOPPELKLICK REAGIERIEN
      CHECK rs_selfield-tabindex GT 0.

      READ TABLE it_disp INTO gs_disp INDEX rs_selfield-tabindex.
      IF sy-subrc NE 0.
        MESSAGE s906.            EXIT.
      ENDIF.

      CASE rs_selfield-fieldname.
        WHEN 'EBELN' OR 'EBELP'.
          PERFORM  display_purchase_order(ztir0000)
                                          USING gs_disp-ebeln
                                                gs_disp-ebelp.

        WHEN 'MATNR'.
          PERFORM display_material_master(ztir0000)
                                          USING    gs_disp-matnr
                                                 space space.

        WHEN 'PSPNR'.
          DATA : ls_pspid LIKE proj-pspid.
          SELECT SINGLE pspid
            INTO ls_pspid
            FROM proj
           WHERE pspnr EQ gs_disp-pspnr.

          SET PARAMETER ID 'PSP' FIELD ls_pspid.
          CALL TRANSACTION 'CJ08' AND SKIP FIRST SCREEN.

        WHEN OTHERS.              ">해당작업수행..

          DATA: seltab     TYPE TABLE OF rsparams,
                seltab_wa  LIKE LINE OF seltab.

          MOVE: 'S_EBELN'           TO seltab_wa-selname,
                'S'                 TO seltab_wa-kind, "SELECT-OPTION
                'I'                 TO seltab_wa-sign,
                'BT'                TO seltab_wa-option,
                 gs_disp-ebeln      TO seltab_wa-low,
                 space              TO seltab_wa-high.
          APPEND seltab_wa TO seltab.

          MOVE: 'S_EBELP'           TO seltab_wa-selname,
                'S'                 TO seltab_wa-kind, "SELECT-OPTION
                'I'                 TO seltab_wa-sign,
                'BT'                TO seltab_wa-option,
                 gs_disp-ebelp      TO seltab_wa-low,
                space               TO seltab_wa-high.
          APPEND seltab_wa TO seltab.

          SUBMIT ztirh020
*                 USING SELECTION-SET 'VARIANT1'
*                 WITH  ARBGB CP 'A*'
                 WITH  SELECTION-TABLE seltab
                 AND RETURN.

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
  st_sort-fieldname = 'EBELN'.
  st_sort-tabname   = 'IT_DISP'.
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

  header-info = '수량별 진행관리'.

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
*&      Form  set_colorize_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_colorize_build .

  DATA: color TYPE slis_t_specialcol_alv WITH HEADER LINE.
*> colorize
  LOOP AT it_disp INTO gs_disp.

    color-color-col = 7.
    color-color-int = 0.
    color-fieldname = 'MATNR'.                              "'TXZ01'
    APPEND color.

*     color-color-COL = 6.
*     color-color-INT = 0.
*     color-FIELDNAME = 'PSPNR'.
*     append color.

    gs_disp-color[] = color[].

    MODIFY it_disp FROM gs_disp .
  ENDLOOP.

ENDFORM.                    " set_colorize_build

*&---------------------------------------------------------------------*
*&      Form  SET_INITAIL_IP_BATCHDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_initail_ip_batchdata .

ENDFORM.                    " SET_INITAIL_IP_BATCHDATA
