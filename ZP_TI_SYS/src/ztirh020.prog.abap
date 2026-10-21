************************************************************************
*                                                                      *
* Title         : ZTIRH020                                             *
*                                                                      *
* Description   : [Report] 품목별 진행관리                             *
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
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
*                                                                      *
*                                                                      *
************************************************************************
PROGRAM   ztirh020
          MESSAGE-ID zmti00
          NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis.   "> Globale Type(ALV)

************************************************************************
* User Included                                                        *
************************************************************************
*INCLUDE ZTI_reuse_bdc_subroutine_f00.
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

TABLES : ztispohrc,
         ztivpo01,
         ztiviv01,
         ztivbl00,
         ztiviv00,
         ztivpn00,
         ztivcc00,
         ztivgr00.

TYPES: BEGIN OF ty_list.
        INCLUDE STRUCTURE ztispohrc.
TYPES: END OF ty_list.

DATA: it_list      TYPE STANDARD TABLE OF ty_list,
      gs_list      TYPE ty_list,
      ls_list      TYPE ty_list.

TYPES: BEGIN OF ty_disp.
        INCLUDE STRUCTURE ztispohrc.
TYPES: box        TYPE c,
       color      TYPE slis_t_specialcol_alv.
TYPES: END OF ty_disp.
DATA: it_disp      TYPE STANDARD TABLE OF ty_disp,
      gs_disp      TYPE ty_disp,
      ls_disp      TYPE ty_disp.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
DATA: l_count TYPE i,
      l_text(40)   TYPE c.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
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
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM p1102_authorization_check USING s_bukrs-low.
** JS전선 회사코드 2007/04 KSH --------------------------------------
  PERFORM alv_variant_check.


GET ztivpo01.
  PERFORM get_event_ztivpo01.

GET ztivbl00.
  PERFORM get_event_ztivbl00.

GET ztiviv00.
  PERFORM get_event_ztiviv00.

GET ztiviv01.
  PERFORM get_event_ztiviv01.

GET ztivcc00.
  PERFORM get_event_ztivcc00.

GET ztivpn00.
  PERFORM get_event_ztivpn00.

GET ztivgr00.
  PERFORM get_event_ztivgr00.

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

  SET TITLEBAR 'T1000' WITH '품목별진행관리'.

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
      i_structure_name   = 'ZTISPOHRC'
      i_internal_tabname = 'IT_LIST'
    CHANGING
      ct_fieldcat        = fc[].

  fc1[] = fc[].

  LOOP AT fc1 INTO fcs.
    CLEAR: fcs-key .
    CASE fcs-fieldname.
      WHEN 'DOCCL'.
        fcs-no_out  = 'X'.
      WHEN 'DOCNB'.
        fcs-hotspot = 'X'.
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


  SET TITLEBAR 'T1000' WITH '품목별 진행관리'.

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

      PERFORM move_itselves_transaction
                            USING   rs_selfield-tabindex
                                    rs_selfield-fieldname.
*
*        WHEN OTHERS.              ">해당작업수행..
*
*          SET PARAMETER ID 'BES' FIELD gs_disp-ebeln.
*          SET PARAMETER ID 'BSP' FIELD gs_disp-ebelp.
*          submit ZTIrh020  and return. "VIA SELECTION-SCREEN

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
*  st_sort-fieldname = 'EBELN'.
*  st_sort-tabname   = 'IT_DISP'.
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

  header-info = '품목별 진행관리'.

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
  DATA: ls_cnt TYPE i.
  LOOP AT it_disp INTO gs_disp.

    ls_cnt = sy-tabix MOD 2.

    IF ls_cnt = 0.
      color-color-col = 1.
      color-color-int = 0.
*      color-color-inv = 1.
      color-fieldname = 'DOCCT'.
      APPEND color.

      color-color-col = 2.
      color-color-int = 0.
      color-fieldname = 'DOCNB'.
      APPEND color.

      color-color-col = 2.
      color-color-int = 0.
      color-fieldname = 'DOCIT'.
      APPEND color.
    ELSE.
      color-color-col = 5.
      color-color-int = 0.
      color-fieldname = 'DOCCT'.
      APPEND color.

      color-color-col = 3.
      color-color-int = 0.
      color-fieldname = 'DOCNB'.
      APPEND color.

      color-color-col = 3.
      color-color-int = 0.
      color-fieldname = 'DOCIT'.
      APPEND color.
    ENDIF.
    gs_disp-color[] = color[].

    MODIFY it_disp FROM gs_disp .

    REFRESH :gs_disp-color,color.
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
*&      Form  get_event_ZTIL01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_event_ztivpo01.
*> 구매오더 레벨.
  ON CHANGE OF ztivpo01-ebeln OR ztivpo01-ebelp.

    CLEAR: gs_list.
    MOVE: 'P'                TO     gs_list-doccl, "수입문서종류
          ztivpo01-ebeln     TO     gs_list-docnb, "수입문서번호
          ztivpo01-ebelp     TO     gs_list-docit, "수입문서품목
          ztivpo01-name1     TO     gs_list-docnm, "관련문서번호
          ztivpo01-menge     TO     gs_list-menge, "수량
          ztivpo01-meins     TO     gs_list-meins, "오더단위
          ztivpo01-bedat     TO     gs_list-docdt, "관련일자
          space              TO     gs_list-othtx. "기타정보
    PERFORM get_domain_value_text(ztir0000)  USING  'ZTIDOCCL'
                                                    gs_list-doccl
                                                    l_text.
    CONCATENATE '.'  l_text INTO l_text.
    MOVE   l_text            TO     gs_list-docct. "수입문서텍스트

    CLEAR l_text.
*  perFORM get_domain_value_text(ZTIr0000)  USING  'ZTIDOCST'
*                                                  ZTIvpo01-DOCST
*                                                  l_text.
*  Move   l_text            to     gs_list-OTHTX. "기타정보
    APPEND gs_list TO it_list.
  ENDON.
**  tree를 위한 node setting.
*  read table it_dochis into g_dochis_tm
*                       with key doccl    = 'P'
*                                docnb    = it_dochis-docnb
*                                relatkey = it_dochis-relatkey.
*  if sy-subrc eq 0.
*    it_dochis-nodekey = g_dochis_tm-nodekey.
*  else.
*    add 1 to g_node_seq.
*    it_dochis-nodekey = g_node_seq.
*  endif.
*
**> Temp structure로 Move.
*  MOVE-CORRESPONDING it_dochis TO g_dochis_po.
*  COLLECT it_dochis.

*>수입의뢰 이력조회.
  ON CHANGE OF ztivpo01-reqno OR ztivpo01-reqit.
    CLEAR: gs_list.
    IF ztivpo01-amdsq EQ ztivpo01-lstas.
      CASE ztivpo01-reqty."수입문서종류
        WHEN 'LC'.
          CASE ztivpo01-ilcty.
            WHEN 'A'.   ">At sight
              MOVE: '0'   TO     gs_list-doccl.
            WHEN 'U'.   ">Usance
              MOVE: '1'   TO     gs_list-doccl.
            WHEN 'M'.   ">Mixed payment
              MOVE: '2'   TO     gs_list-doccl.
            WHEN OTHERS.
              MOVE: 'M'   TO     gs_list-doccl.
          ENDCASE.
        WHEN 'TT'.
          IF ztivpo01-anbty EQ 'A'.   ">사후송금.
            IF ztivpo01-rpaid EQ 'X'. ">유보금.
              MOVE: '7'   TO     gs_list-doccl.
            ELSE.
              MOVE: '9'   TO     gs_list-doccl.
            ENDIF.
          ELSE.
            IF ztivpo01-ppaid EQ 'X'. ">선급금.
              MOVE: '6'   TO     gs_list-doccl.
            ELSE.
              MOVE: '8'   TO     gs_list-doccl.
            ENDIF.
          ENDIF.
        WHEN 'LO'.
          MOVE: '3'   TO     gs_list-doccl.
        WHEN 'PU'.
          IF ztivpo01-setyn EQ 'X'.
            MOVE: '5'   TO     gs_list-doccl.
          ELSE.
            MOVE: '4'   TO     gs_list-doccl.
          ENDIF.
        WHEN 'DA'.
          MOVE: 'Q'   TO     gs_list-doccl.
        WHEN 'DP'.
          MOVE: 'W'   TO     gs_list-doccl.
      ENDCASE.

      MOVE: ztivpo01-reqno     TO     gs_list-docnb, "수입문서번호
            ztivpo01-reqit     TO     gs_list-docit, "수입문서품목
            ztivpo01-opnno     TO     gs_list-docnm, "관련문서번호
            ztivpo01-rqmng     TO     gs_list-menge, "수량
            ztivpo01-meins     TO     gs_list-meins, "오더단위
            ztivpo01-opndt     TO     gs_list-docdt, "관련일자
            space              TO     gs_list-othtx. "기타정보
      PERFORM get_domain_value_text(ztir0000)  USING  'ZTIDOCCL'
                                                      gs_list-doccl
                                                      l_text.
      CONCATENATE '..'  l_text INTO l_text.
      MOVE   l_text            TO     gs_list-docct. "수입문서텍스트
      PERFORM get_domain_value_text(ztir0000)  USING  'ZTIDOCST'
                                                      ztivpo01-docst
                                                      l_text.
      MOVE   l_text            TO     gs_list-othtx. "기타정보
      APPEND gs_list TO it_list.
    ENDIF.
  ENDON.
*  read table it_dochis into g_dochis_tm
*                       with key doccl    = it_dochis-doccl
*                                docnb    = it_dochis-docnb
*                                relatkey = it_dochis-relatkey.
*  if sy-subrc eq 0.
*    it_dochis-nodekey = g_dochis_tm-nodekey.
*  else.
*    add 1 to g_node_seq.
*    it_dochis-nodekey = g_node_seq.
*  endif.
*
*  IF g_docty EQ 'LC'.
*    IF ls_ZTIvpo01-reqno EQ g_docno AND
*       ls_ZTIvpo01-amdsq EQ g_amdsq.
*      g_set_nodekey = it_dochis-nodekey.
*    ENDIF.
*  ENDIF.
**> Temp structure로 Move.
*  MOVE-CORRESPONDING it_dochis TO g_dochis_lc.
*
*  COLLECT it_dochis.

ENDFORM.                    "get_event_ZTIvpo01
*&---------------------------------------------------------------------*
*&      Form  get_event_ZTIL01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_event_ztivbl00.
*> B/L 레벨.
  ON CHANGE OF ztivbl00-iblno OR ztivbl00-iblit.
    CLEAR: gs_list.
    MOVE: 'B'                TO     gs_list-doccl, "수입문서종류
          ztivbl00-iblno     TO     gs_list-docnb, "수입문서번호
          ztivbl00-iblit     TO     gs_list-docit, "수입문서품목
          ztivbl00-blnum     TO     gs_list-docnm, "관련문서번호
          ztivbl00-blmng     TO     gs_list-menge, "수량
          ztivbl00-meins     TO     gs_list-meins, "오더단위
          ztivbl00-bldat     TO     gs_list-docdt, "관련일자
          space              TO     gs_list-othtx. "기타정보
    PERFORM get_domain_value_text(ztir0000)  USING  'ZTIDOCCL'
                                                    gs_list-doccl
                                                    l_text.
    CONCATENATE '...'  l_text INTO l_text.
    MOVE   l_text            TO     gs_list-docct. "수입문서텍스트

*  clear l_text.
*  perFORM get_domain_value_text(ZTIr0000)  USING  'ZTILIVST'
*                                                  ZTIviv00-LIVST
*                                                  l_text.
*  Move   l_text            to     gs_list-OTHTX. "기타정보

    APPEND gs_list TO it_list.
  ENDON.
*  CLEAR: gs_list.
*  MOVE: ZTIvbl00-ebeln   TO gs_list-ebeln,
*        ZTIvbl00-ebelp   TO gs_list-ebelp,
*        ZTIvbl00-blmng   TO gs_list-blmng,
*        ZTIvpo01-meins   TO gs_list-meins,
*        ZTIvpo01-matnr   TO gs_list-matnr,
*        ZTIvpo01-txz01   TO gs_list-txz01.
*
*  COLLECT gs_list INTO it_list.
ENDFORM.                    "get_event_ZTIvbl00
*&---------------------------------------------------------------------*
*&      Form  get_event_ZTIL01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_event_ztiviv00.

  ON CHANGE OF ztiviv00-ivono OR ztiviv00-rblgp.
    CLEAR: gs_list.
    MOVE: 'V'                TO     gs_list-doccl, "수입문서종류
          ztiviv00-ivono     TO     gs_list-docnb, "수입문서번호
          ztiviv00-rblgp     TO     gs_list-docit, "수입문서품목
          ztiviv00-ivnum     TO     gs_list-docnm, "관련문서번호
          ztiviv00-remng     TO     gs_list-menge, "수량
          ztiviv00-meins     TO     gs_list-meins, "오더단위
          ztiviv00-civdt     TO     gs_list-docdt, "관련일자
          space              TO     gs_list-othtx. "기타정보
    PERFORM get_domain_value_text(ztir0000)  USING  'ZTIDOCCL'
                                                    gs_list-doccl
                                                    l_text.
    CONCATENATE '....'  l_text INTO l_text.
    MOVE   l_text            TO     gs_list-docct. "수입문서텍스트

    CLEAR l_text.
    PERFORM get_domain_value_text(ztir0000)  USING  'ZTILIVST'
                                                    ztiviv00-livst
                                                    l_text.
    MOVE   l_text            TO     gs_list-othtx. "기타정보

    APPEND gs_list TO it_list.
  ENDON.
*  CLEAR: gs_list.
*  MOVE: ZTIviv00-ebeln   TO gs_list-ebeln,
*        ZTIviv00-ebelp   TO gs_list-ebelp,
*        ZTIviv00-remng   TO gs_list-remng,
*        ZTIvpo01-meins   TO gs_list-meins,
*        ZTIvpo01-matnr   TO gs_list-matnr,
*        ZTIvpo01-txz01   TO gs_list-txz01.
*
*  COLLECT gs_list INTO it_list.
ENDFORM.                    "get_event_ZTIviv00
*&---------------------------------------------------------------------*
*&      Form  get_event_ZTIL01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_event_ztiviv01.
  ON CHANGE OF ztiviv01-ivono OR ztiviv01-rblgp.
    CLEAR: gs_list.
    MOVE: 'Z'                TO     gs_list-doccl, "수입문서종류
          ztiviv01-ivono     TO     gs_list-docnb, "수입문서번호
          ztiviv01-rblgp     TO     gs_list-docit, "수입문서품목
          ztiviv01-ivnum     TO     gs_list-docnm, "관련문서번호
          ztiviv01-remng     TO     gs_list-menge, "수량
          ztiviv01-meins     TO     gs_list-meins, "오더단위
          ztiviv01-civdt     TO     gs_list-docdt. "관련일자
*        space              to     gs_list-OTHTX. "기타정보
    PERFORM get_domain_value_text(ztir0000)  USING  'ZTIDOCCL'
                                                    gs_list-doccl
                                                    l_text.
    CONCATENATE '...'  l_text INTO l_text.
    MOVE   l_text            TO     gs_list-docct. "수입문서텍스트

    CLEAR l_text.
    PERFORM get_domain_value_text(ztir0000)  USING  'ZTILIVST'
                                                    ztiviv01-livst
                                                    l_text.
    MOVE   l_text            TO     gs_list-othtx. "기타정보

    APPEND gs_list TO it_list.
  ENDON.

ENDFORM.                    "get_event_ZTIviv01
*&---------------------------------------------------------------------*
*&      Form  get_event_ZTIL01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_event_ztivcc00.

  ON CHANGE OF ztivcc00-iccno OR ztivcc00-iccit.
    CLEAR: gs_list.
    MOVE: 'C'                TO     gs_list-doccl, "수입문서종류
          ztivcc00-iccno     TO     gs_list-docnb, "수입문서번호
          ztivcc00-iccit     TO     gs_list-docit, "수입문서품목
          ztivcc00-cdcno     TO     gs_list-docnm, "관련문서번호
          ztivcc00-ccmng     TO     gs_list-menge, "수량
          ztivcc00-meins     TO     gs_list-meins, "오더단위
          ztivcc00-cdadt     TO     gs_list-docdt, "관련일자
          space              TO     gs_list-othtx. "기타정보
    PERFORM get_domain_value_text(ztir0000)  USING  'ZTIDOCCL'
                                                    gs_list-doccl
                                                    l_text.
    CONCATENATE '....'  l_text INTO l_text.
    MOVE   l_text            TO     gs_list-docct. "수입문서텍스트

    CLEAR l_text.
    PERFORM get_domain_value_text(ztir0000)  USING  'ZTIDOCST'
                                                    ztivcc00-docst
                                                    l_text.
    MOVE   l_text            TO     gs_list-othtx. "기타정보

    APPEND gs_list TO it_list.
  ENDON.
*  CLEAR: gs_list.
*  MOVE: ZTIvcc00-ebeln   TO gs_list-ebeln,
*        ZTIvcc00-ebelp   TO gs_list-ebelp,
*        ZTIvcc00-ccmng   TO gs_list-ccmng,
*        ZTIvpo01-meins   TO gs_list-meins,
*        ZTIvpo01-matnr   TO gs_list-matnr,
*        ZTIvpo01-txz01   TO gs_list-txz01.
*
*  COLLECT gs_list INTO it_list.
ENDFORM.                    "get_event_ZTIvcc00
*&---------------------------------------------------------------------*
*&      Form  get_event_ZTIL01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_event_ztivgr00.

  ON CHANGE OF ztivgr00-igrno OR ztivgr00-grseq.
    CLEAR: gs_list.
    MOVE: 'G'                TO     gs_list-doccl, "수입문서종류
          ztivgr00-igrno     TO     gs_list-docnb, "수입문서번호
          ztivgr00-grseq     TO     gs_list-docit, "수입문서품목
          ztivgr00-mblnr     TO     gs_list-docnm, "관련문서번호
          ztivgr00-grmng     TO     gs_list-menge, "수량
          ztivgr00-meins     TO     gs_list-meins, "오더단위
          ztivgr00-budat     TO     gs_list-docdt. "관련일자

    CLEAR l_text.
    PERFORM get_domain_value_text(ztir0000)  USING  'ZTIDOCCL'
                                                    gs_list-doccl
                                                    l_text.
    CONCATENATE '.....'  l_text INTO l_text.
    MOVE   l_text            TO     gs_list-docct. "수입문서텍스트

    CLEAR l_text.
    PERFORM get_domain_value_text(ztir0000)  USING  'ZTIIGRST'
                                                    ztivgr00-igrst
                                                    l_text.
    MOVE   l_text            TO     gs_list-othtx. "기타정보

    APPEND gs_list TO it_list.
  ENDON.
*  CLEAR: gs_list.
*  MOVE: ZTIvgr00-ebeln   TO gs_list-ebeln,
*        ZTIvgr00-ebelp   TO gs_list-ebelp,
*        ZTIvgr00-grmng   TO gs_list-grmng,
*        ZTIvpo01-meins   TO gs_list-meins,
*        ZTIvpo01-matnr   TO gs_list-matnr,
*        ZTIvpo01-txz01   TO gs_list-txz01.
*
*  COLLECT gs_list INTO it_list.
ENDFORM.                    "get_event_ZTIvgr00
*&---------------------------------------------------------------------*
*&      Form  get_event_ZTIL01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_event_ztivpn00.


  ON CHANGE OF ztivpn00-pntno OR ztivpn00-pntit.
    CLEAR: gs_list.
    MOVE: 'Y'                TO     gs_list-doccl, "수입문서종류
          ztivpn00-pntno     TO     gs_list-docnb, "수입문서번호
          ztivpn00-pntit     TO     gs_list-docit, "수입문서품목
*        ZTIvpn00-NTCBK     to     gs_list-DOCNM, "관련문서번호
          ztivpn00-pnmng     TO     gs_list-menge, "수량
          ztivpn00-meins     TO     gs_list-meins, "오더단위
          ztivpn00-pntdt     TO     gs_list-docdt. "관련일자
*        space              to     gs_list-OTHTX. "기타정보
    CLEAR l_text.
    PERFORM get_domain_value_text(ztir0000)  USING  'ZTIDOCCL'
                                                    gs_list-doccl
                                                    l_text.
    CONCATENATE '.....'  l_text INTO l_text.
    MOVE   l_text            TO     gs_list-docct. "수입문서텍스트

    CLEAR l_text.
    PERFORM get_domain_value_text(ztir0000)  USING  'ZTIPROCP'
                                                    ztivpn00-procp
                                                    l_text.
    MOVE   l_text            TO     gs_list-othtx. "기타정보

    CLEAR l_text.
    SELECT SINGLE namet
      INTO l_text
      FROM ztstig3
     WHERE epart EQ ztivpn00-ntcbk.
    MOVE   l_text            TO     gs_list-docnm. "관련문서번호

    APPEND gs_list TO it_list.
  ENDON.
*  CLEAR: gs_list.
*  MOVE: ZTIvpn00-ebeln   TO gs_list-ebeln,
*        ZTIvpn00-ebelp   TO gs_list-ebelp,
*        ZTIvpn00-pnmng   TO gs_list-pnmng,
*        ZTIvpo01-meins   TO gs_list-meins,
*        ZTIvpo01-matnr   TO gs_list-matnr,
*        ZTIvpo01-txz01   TO gs_list-txz01.
*
*  COLLECT gs_list INTO it_list.
ENDFORM.                    "get_event_ZTIvpn00
*&---------------------------------------------------------------------*
*&      Form  move_itselves_transaction
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM move_itselves_transaction  USING    p_row
                                         p_column.
  DATA : l_message(80).

  READ TABLE it_disp INTO gs_disp INDEX p_row.

  CHECK sy-subrc = 0.

  CASE p_column.
    WHEN 'DOCNB'.

      CASE gs_disp-doccl.
        WHEN 'P'.
          PERFORM  display_purchase_order(ztir0000)
                                          USING gs_disp-docnb
                                                gs_disp-docit.
        WHEN '0' OR '1' OR '2' OR '3' OR '4' OR
             '5' OR '6' OR '7' OR '8' OR '9'.

          DATA : l_lstas TYPE ztilstas.
          SELECT SINGLE lstas
            INTO l_lstas
            FROM ztivpo01
           WHERE reqno EQ gs_disp-docnb.

          PERFORM  display_import_document(ztir0000)
                                           USING gs_disp-docnb
                                                l_lstas
                                                 '00000'.

        WHEN 'B'.   "> B/L 문서.
          PERFORM  display_bl_document(ztir0000)
                                          USING gs_disp-docnb
                                                '00000'.
        WHEN 'C'.   "> B/L 문서.
          PERFORM  display_cc_document(ztir0000)
                                          USING gs_disp-docnb
                                                '00'.
        WHEN 'V' OR 'Z'.   "> 송장/선급금 문서.
          PERFORM  display_civ_document(ztir0000)
                                          USING gs_disp-docnb.
        WHEN 'G'.           "> 입고.
          PERFORM  display_gr_document(ztir0000)
                                          USING gs_disp-docnb.

        WHEN OTHERS.
      ENDCASE.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " move_itselves_transaction
