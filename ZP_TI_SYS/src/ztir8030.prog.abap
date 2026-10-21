************************************************************************
*                                                                      *
* Title         : ZTIR8030                                             *
*                                                                      *
* Description   : [Report] 외화자금 일보 List                          *
*                                                                      *
* Creation Date : 2003/11/25                                           *
*                                                                      *
* Author        : Seog Bong, Kang                                      *
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
PROGRAM   ztir8030
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
*> T/T 검색조건용 Internal table
DATA: BEGIN OF it_rqtab OCCURS 0,
        tecdt TYPE ztittt1-tecdt.
        INCLUDE STRUCTURE ztivrq04.
DATA: END OF it_rqtab.

*> Release Note 검색조건용 Internal table
DATA: BEGIN OF it_rntab OCCURS 0.
        INCLUDE STRUCTURE ztitivk.
DATA: END OF it_rntab.

*> Payment Notice 검색조건용 Internal table
DATA: BEGIN OF it_pntab OCCURS 0.
        INCLUDE STRUCTURE ztitpnk.
DATA: END OF it_pntab.

*> Main Internal table
DATA: BEGIN OF it_tab OCCURS 0.
        INCLUDE STRUCTURE ztisfund.
DATA: END OF it_tab.

DATA: BEGIN OF it_ig3 OCCURS 0.
        INCLUDE STRUCTURE ztstig3.
DATA: END OF it_ig3.

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
        t71cb,     ">보상 조정.
        ekbz  ,    ">History per Purchasing Document: Delivery Costs
        ekbe  ,    ">History per Purchasing Document
        ekko,      ">Purchasing Document Header
        ekpo  ,    ">Purchasing Document Items
        ekkn,      ">Account Assignment in Purchasing Document
        dfies ,    ">DD Interface: Table Fields for DDIF_FIELDINFO_GET
        ztivcs00.  ">수입비용 Views

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
SELECTION-SCREEN BEGIN OF BLOCK box1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS:
         s_bukrs  FOR  ztivcs00-bukrs   ">회사코드.
                  NO-EXTENSION NO INTERVALS OBLIGATORY
                  MEMORY ID  buk
                  MODIF  ID iog ,
         s_zfbdt  FOR  ztivcs00-zfbdt   ">계산기준일.
                  OBLIGATORY.
  SELECTION-SCREEN ULINE.
  PARAMETERS: p_full RADIOBUTTON GROUP ab2 DEFAULT 'X',
              p_list RADIOBUTTON GROUP ab2.
SELECTION-SCREEN END OF BLOCK box1.

*> Report variant
SELECTION-SCREEN: BEGIN OF BLOCK alv WITH FRAME TITLE TEXT-003.
  PARAMETERS: alv_def LIKE disvariant-variant.
SELECTION-SCREEN: END OF BLOCK alv.


************************************************************************
* Internal Tables                                                      *
************************************************************************
*> 공급업체명
DATA : BEGIN OF xlfa1 OCCURS 0,
         lifnr LIKE   lfa1-lifnr,
         name1 LIKE   lfa1-name1.
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

DATA: s_variant LIKE  disvariant,
      s_var_usr LIKE  disvariant.

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
DATA: fc      TYPE slis_t_fieldcat_alv,
      fc1     TYPE slis_t_fieldcat_alv,
      fcs     TYPE slis_fieldcat_alv,
      it_sort TYPE slis_t_sortinfo_alv.

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
FIELD-SYMBOLS: <fs>  TYPE any,
               <fsl> TYPE any,
               <fss> TYPE any.

FIELD-SYMBOLS: <gt_table> TYPE table.

************************************************************************
* MACRO DEFINE                                                         *
************************************************************************
DEFINE ac.
  CLEAR:  fcs, fc_struct.
  fc_struct         = &1.
  fcs-tabname        = fc_struct-tabname.
  fcs-fieldname      = fc_struct-fieldname.
  fcs-ref_tabname    = fc_struct-ref_tabname.
  fcs-ref_fieldname  = fc_struct-ref_fieldname.
  fcs-no_out         = fc_struct-no_out.

  CASE fc_struct-cqindicator.
    WHEN 'C'.
      fcs-cfieldname = fc_struct-cqfield.
    WHEN 'Q'.
      fcs-qfieldname = fc_struct-cqfield.
  ENDCASE.
  APPEND fcs TO fc.
END-OF-DEFINITION.

DEFINE ac_1.
  CLEAR: fcs, fc_struct.
*  FC_STRUCT         = &1.
  fcs-tabname        = &1.
  fcs-fieldname      = &2.
  fcs-ref_tabname    = &3.
  fcs-ref_fieldname  = &4.
  fcs-no_out         = &5.

  CASE &6.
    WHEN 'C'.
      fcs-cfieldname = &7.
    WHEN 'Q'.
      fcs-qfieldname = &7.
  ENDCASE.
  APPEND fcs TO fc.

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
  g_out_text = TEXT-905.
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM set_progress_bar USING g_out_text g_line1.
  PERFORM set_fieldcat_build.       ">Set ALV field category
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

  SET TITLEBAR 'T1000' WITH '상태별 수입의뢰'.

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

  DATA: l_bukrs   LIKE t001-bukrs.

* Company code
  SELECT bukrs INTO (l_bukrs)
               FROM t001 UP TO 1 ROWS WHERE bukrs IN s_bukrs.
  ENDSELECT.
  IF sy-subrc <> 0.
    PERFORM get_ftext(rddfie00) USING 'T001' 'BUKRS' sy-langu
                                CHANGING dfies g_subrc.
    SET CURSOR FIELD 'S_BUKRS-LOW'.
    MESSAGE e348(m7) WITH TEXT-102.
  ENDIF.

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

  DATA:  l_count     TYPE  i.

  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.

*> PROGRESS Display.
  g_line1    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_line1.

*> Company code select.
  SELECT  *
    FROM  t001 UP TO 1 ROWS
    WHERE bukrs IN s_bukrs.
  ENDSELECT.

  REFRESH: it_tab, it_ig3.

* 거래상대방 발췌.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_ig3
    FROM ztstig3
   WHERE parti  EQ  'B'
     AND bukrs  EQ s_bukrs-low.

*> 수입의뢰 데이타 select.( 전신환 송금건만 ).
  PERFORM  get_telegraphic_transfer_data.

*> Release Note 건만.
  PERFORM  get_release_note_data.

*> Payment Notice 건만.
  PERFORM  get_payment_notice_data.

*> Fill Others Text Fields.
  PERFORM  get_others_fields_text.

*> 해당 데이타 존재하는 여부 체크.
  DESCRIBE TABLE it_tab LINES g_line.
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

*> Create field catagory table
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
*     I_PROGRAM_NAME         =
*     I_INTERNAL_TABNAME     =
      i_structure_name       = 'ZTISFUND'
*     I_CLIENT_NEVER_DISPLAY = 'X'
*     I_INCLNAME             =
*     I_BYPASSING_BUFFER     =
*     I_BUFFER_ACTIVE        =
    CHANGING
      ct_fieldcat            = fc1
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

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
*  gs_layout-box_fieldname     = 'BOX'.
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
*     I_STRUCTURE_NAME         =
*     IT_EXCLUDING             =
*     IT_SPECIAL_GROUPS        =
*     IT_FILTER                =
*     IS_SEL_HIDE              =
*     I_DEFAULT                = 'X'
*     I_SAVE                   = ' '
*     IS_VARIANT               =
      it_events                = events[]
      it_event_exit            = exit[]
*     IS_PRINT                 =
*     IS_REPREP_ID             =
*     I_SCREEN_START_COLUMN    = 0
*     I_SCREEN_START_LINE      = 0
*     I_SCREEN_END_COLUMN      = 0
*     I_SCREEN_END_LINE        = 0
      it_fieldcat              = fc_detail[]
      it_sort                  = it_sort
*     I_DEFAULT                = 'X'
*     IS_VARIANT               = VARIANT_DETAIL
      is_variant               = alv_variant
      i_save                   = c_save
      is_layout                = gs_layout
      is_print                 = alv_print
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
*     ES_EXIT_CAUSED_BY_USER   =
    TABLES
      t_outtab                 = it_tab.

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
*  CASE 'X'.
*    WHEN p_step1.  ">의뢰대상
*      APPEND 'ZTIT002'  TO extab.
*      APPEND 'ZTIT005'  TO extab.
*    WHEN p_step2. ">신청대상
*      APPEND 'ZTIT002'  TO extab.
*      APPEND 'ZTIT005'  TO extab.
*    WHEN p_step3. ">개설의뢰 진행 중
*      APPEND 'ZTIT002'  TO extab.
*      APPEND 'ZTIT005'  TO extab.
*  ENDCASE.

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
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.

  CASE r_ucomm.
    WHEN 'DISPLAY' OR '&IC1'.    " AUF DOPPELKLICK REAGIERIEN

      CHECK rs_selfield-tabindex GT 0.

      READ TABLE it_tab  INDEX rs_selfield-tabindex.
      IF sy-subrc NE 0.
        MESSAGE s906.            EXIT.
      ENDIF.

      CASE   rs_selfield-fieldname.
        WHEN   'BELNR'.
          "회계
          PERFORM  display_fb03_document(ztir0000)
                                       USING it_tab-belnr.

        WHEN  OTHERS.
          CASE it_tab-fndty.
            WHEN 'B' OR 'A'.   ">사전/사후 송금.
              PERFORM  display_import_document(ztir0000)
                                        USING it_tab-refno
                                              ''
                                              space.
            WHEN 'R'.   ">Release Note.
              PERFORM  display_civ_document(ztir0000)
                                        USING it_tab-refno.

            WHEN 'S' OR 'U' OR 'P'.   ">At Sight or Usnace or 선취이자
              PERFORM  display_pn_document(ztir0000)
                                        USING it_tab-refno.
          ENDCASE.
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
  st_sort-spos = '00'.
  st_sort-fieldname = 'LIFNR'.
  st_sort-tabname   = 'IT_TAB'.
  st_sort-up        = 'X'.
*  ST_SORT-GROUP     = 'X'.
  st_sort-subtot    = 'X'.
*  ST_SORT-EXPA      = 'X'.
  APPEND st_sort TO it_sort.

  CLEAR  st_sort.
  st_sort-spos = '01'.
  st_sort-fieldname = 'NAME1'.
  st_sort-tabname   = 'IT_TAB'.
  st_sort-up        = 'X'.
*  ST_SORT-GROUP     = 'X'.
  st_sort-subtot    = 'X'.
*  ST_SORT-EXPA      = 'X'.
  APPEND st_sort TO it_sort.

  CLEAR  st_sort.
  st_sort-spos = '02'.
  st_sort-fieldname = 'DDISPO'.
  st_sort-tabname   = 'IT_TAB'.
  st_sort-up        = 'X'.
*  ST_SORT-GROUP     = 'X'.
  st_sort-subtot    = 'X'.
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

  SET TITLEBAR 'T1000'.

  REFRESH header.

  header-typ = 'H'.
  header-info = '외자 자금일보'.
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
*&      Form  SET_INITAIL_IP_BATCHDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_initail_ip_batchdata .

ENDFORM.                    " SET_INITAIL_IP_BATCHDATA
*&---------------------------------------------------------------------*
*&      Form  get_Telegraphic_Transfer_data
*&---------------------------------------------------------------------*
*       전신환 송금 데이타 내역 발췌.
*----------------------------------------------------------------------*
FORM get_telegraphic_transfer_data .

  DATA: BEGIN OF it_iblno OCCURS 0,
          iblno TYPE ztiiblno,
          iblit TYPE ztiiblit,
        END   OF it_iblno.

*> 수입의뢰(전신환 송금) 데이타 발췌.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_rqtab
    FROM ztivrq04 AS r INNER JOIN ztittt1 AS t
      ON r~reqno  EQ t~reqno
   WHERE r~bukrs  IN  s_bukrs
     AND t~tecdt  IN  s_zfbdt
     AND r~reqty  EQ  'TT'.

  IF sy-subrc EQ 0.
    LOOP AT it_rqtab.
      MOVE: it_rqtab-anbty   TO  it_tab-fndty,
            it_rqtab-opamt   TO  it_tab-refam,
            it_rqtab-waers   TO  it_tab-waers,
            it_rqtab-reqno   TO  it_tab-refno,
            it_rqtab-opnno   TO  it_tab-docnm,
            it_rqtab-tecdt   TO  it_tab-ddispo,
            it_rqtab-sndun   TO  it_tab-uname,
            it_rqtab-unam    TO  it_tab-uname,
            it_rqtab-bukrs   TO  it_tab-bukrs,
            it_rqtab-pspnr   TO  it_tab-pspnr.
*> 송금은행 정보 발췌.
      READ TABLE it_ig3 WITH KEY epart = it_rqtab-opnbk.
      IF sy-subrc EQ 0.
        MOVE: it_ig3-lifnr  TO  it_tab-lifnr,
              it_ig3-namet  TO  it_tab-name1.
      ENDIF.

*> 회계문서번호.
      IF  it_rqtab-anbty EQ 'B'.      ">사전송금.
        SELECT gjahr belnr bldat budat
          INTO (it_tab-gjahr, it_tab-belnr, it_tab-bldat, it_tab-budat)
          FROM ztiviv00
         WHERE reqno   EQ  it_rqtab-reqno
           AND prpyn   EQ  'P'
         GROUP BY gjahr belnr bldat budat.
        ENDSELECT.
      ELSEIF  it_rqtab-anbty EQ 'A'.  ">사후송금.
        SELECT iblno iblit
          INTO CORRESPONDING FIELDS OF TABLE it_iblno
          FROM ztitrqp
         WHERE reqno  EQ  it_rqtab-reqno.

        "CCM : 2023.04.10  ZITCS4HDEV04 - FOR ALL ENTRIES  + GROUP BY 구문 변경
*        SELECT gjahr belnr bldat budat
*          INTO (it_tab-gjahr, it_tab-belnr, it_tab-bldat, it_tab-budat)
*          FROM ztiviv00
*           FOR ALL ENTRIES IN it_iblno
*         WHERE iblno   EQ it_iblno-iblno
*           AND iblit   EQ it_iblno-iblit
*           AND prpyn   EQ  'I'
*         GROUP BY gjahr belnr bldat budat.
*        ENDSELECT.

        SELECT DISTINCT gjahr belnr bldat budat
          INTO (it_tab-gjahr, it_tab-belnr, it_tab-bldat, it_tab-budat)
          FROM ztiviv00
           FOR ALL ENTRIES IN it_iblno
         WHERE iblno   EQ it_iblno-iblno
           AND iblit   EQ it_iblno-iblit
           AND prpyn   EQ  'I'.
        ENDSELECT.



      ENDIF.
      COLLECT it_tab.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " get_Telegraphic_Transfer_data
*&---------------------------------------------------------------------*
*&      Form  get_others_fields_text
*&---------------------------------------------------------------------*
*       기타 텍스트 정보 발췌.
*----------------------------------------------------------------------*
FORM get_others_fields_text .

  DATA: ls_adrp LIKE   adrp,
        l_awtyp LIKE   bkpf-awtyp,
        l_awkey LIKE   bkpf-awkey.

  LOOP AT it_tab.
    g_tabix = sy-tabix.
*> 사용자 이름 Display.
    CALL FUNCTION 'Z_TI_GET_SY_UNAME_TEXT'
      EXPORTING
        p_uname      = it_tab-uname
      IMPORTING
        p_first_name = ls_adrp-name_first
        p_last_name  = ls_adrp-name_last
      EXCEPTIONS
        not_found    = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      CONCATENATE ls_adrp-name_last ls_adrp-name_first
            INTO  it_tab-chamn
                  SEPARATED BY space.
    ENDIF.
*> Get 회계문서 .
    IF NOT it_tab-belnr IS INITIAL.
      l_awkey       = it_tab-belnr.
      l_awkey+10(4) = it_tab-gjahr.
      l_awtyp       = 'RMRP '.

      CLEAR: it_tab-belnr, it_tab-gjahr.

      SELECT SINGLE belnr gjahr
        INTO (it_tab-belnr, it_tab-gjahr)
        FROM bkpf
       WHERE awtyp  EQ  l_awtyp
         AND awkey  EQ  l_awkey.
    ENDIF.

*> 문서종류 Get
    PERFORM get_domain_value_text(ztir0000) USING  'ZTIFNDTY'
                                                   it_tab-fndty
                                                   it_tab-fndtx.
    MODIFY it_tab INDEX g_tabix.
  ENDLOOP.

ENDFORM.                    " get_others_fields_text
*&---------------------------------------------------------------------*
*&      Form  Get_Release_Note_Data
*&---------------------------------------------------------------------*
*       Release Note 데이타 내역 발췌.
*----------------------------------------------------------------------*
FORM get_release_note_data .

  DATA: l_opnbk LIKE ztitrqk-opnbk,
        l_opnno LIKE ztitrqs-opnno.

*> Release Note 데이타 발췌.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_rntab
    FROM ztitivk
   WHERE bukrs    IN  s_bukrs
     AND civdt    IN  s_zfbdt
     AND prpyn    EQ  'R'.

  IF sy-subrc EQ 0.
    LOOP AT it_rntab.
      MOVE: it_rntab-prpyn   TO  it_tab-fndty,
            it_rntab-ivamp   TO  it_tab-refam,
            it_rntab-waers   TO  it_tab-waers,
            it_rntab-ivono   TO  it_tab-refno,
            it_rntab-ivnum   TO  it_tab-docnm,
            it_rntab-civdt   TO  it_tab-ddispo,
            it_rntab-unam    TO  it_tab-uname,
            it_rntab-bukrs   TO  it_tab-bukrs,
            it_rntab-belnr   TO  it_tab-belnr,
            it_rntab-gjahr   TO  it_tab-gjahr,
            it_rntab-bldat   TO  it_tab-bldat,
            it_rntab-budat   TO  it_tab-budat,
            it_rntab-pspnr   TO  it_tab-pspnr.
*> 수입의뢰 은행 정보 select.
      SELECT opnbk opnno
        INTO (l_opnbk, l_opnno)
        FROM ztivrq04
       WHERE reqno  IN ( SELECT reqno
                           FROM ztitivp
                          WHERE ivono  EQ  it_rntab-ivono ).
      ENDSELECT.
      IF sy-subrc EQ 0.
        MOVE: l_opnno          TO  it_tab-docnm.
*> 송금은행 정보 발췌.
        READ TABLE it_ig3 WITH KEY epart = l_opnbk.
        IF sy-subrc EQ 0.
          MOVE: it_ig3-lifnr  TO  it_tab-lifnr,
                it_ig3-namet  TO  it_tab-name1.
        ENDIF.
      ENDIF.
      COLLECT it_tab.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " Get_Release_Note_Data
*&---------------------------------------------------------------------*
*&      Form  Get_Payment_Notice_Data
*&---------------------------------------------------------------------*
*       Payment Notice 데이타 내역 발췌
*----------------------------------------------------------------------*
FORM get_payment_notice_data .

*> Payment Notice 데이타 발췌(At sight).
  SELECT p~pntam p~waers p~pntno p~opnno p~expdt
         p~unam  p~bukrs p~pspnr p~procp p~ntcbk
         p~itrst p~iblno p~reqno
    INTO CORRESPONDING FIELDS OF TABLE it_pntab
    FROM ztitpnk AS p INNER JOIN ztivrq04 AS r
      ON p~reqno  EQ  r~reqno
     AND r~reqty  EQ  'LC'
     AND r~ilcty  EQ  'A'
   WHERE p~bukrs    IN  s_bukrs
     AND p~stldt    IN  s_zfbdt.

  IF sy-subrc EQ 0.
    LOOP AT it_pntab.
      CLEAR:it_tab.
      MOVE: 'S'              TO  it_tab-fndty,
            it_pntab-pntam   TO  it_tab-refam,
            it_pntab-waers   TO  it_tab-waers,
            it_pntab-pntno   TO  it_tab-refno,
            it_pntab-opnno   TO  it_tab-docnm,
            it_pntab-stldt   TO  it_tab-ddispo,
            it_pntab-unam    TO  it_tab-uname,
            it_pntab-bukrs   TO  it_tab-bukrs,
            it_pntab-pspnr   TO  it_tab-pspnr.
*> 송금은행 정보 발췌.
      READ TABLE it_ig3 WITH KEY epart = it_pntab-ntcbk.
      IF sy-subrc EQ 0.
        MOVE: it_ig3-lifnr  TO  it_tab-lifnr,
              it_ig3-namet  TO  it_tab-name1.
      ENDIF.
*> 회계문서.
      SELECT gjahr belnr bldat budat
        INTO (it_tab-gjahr, it_tab-belnr, it_tab-bldat, it_tab-budat)
        FROM ztiviv00
       WHERE iblno   EQ it_pntab-iblno
         AND prpyn   EQ  'I'
       GROUP BY gjahr belnr bldat budat.
      ENDSELECT.
      COLLECT it_tab.
    ENDLOOP.
  ENDIF.

*> Payment Notice 데이타 발췌(Usance 금액).
  SELECT p~pntam p~waers p~pntno p~opnno p~expdt
         p~unam  p~bukrs p~pspnr p~procp p~ntcbk
         p~itrst p~iblno p~reqno
    INTO CORRESPONDING FIELDS OF TABLE it_pntab
    FROM ztitpnk AS p INNER JOIN ztivrq04 AS r
      ON p~reqno  EQ  r~reqno
     AND r~reqty  EQ  'LC'
     AND r~ilcty  EQ  'U'
   WHERE p~bukrs    IN  s_bukrs
     AND p~expdt    IN  s_zfbdt.

  IF sy-subrc EQ 0.
    LOOP AT it_pntab.
      CLEAR: it_tab.
      MOVE: 'U'              TO  it_tab-fndty,
            it_pntab-pntam   TO  it_tab-refam,
            it_pntab-waers   TO  it_tab-waers,
            it_pntab-pntno   TO  it_tab-refno,
            it_pntab-opnno   TO  it_tab-docnm,
            it_pntab-expdt   TO  it_tab-ddispo,
            it_pntab-unam    TO  it_tab-uname,
            it_pntab-bukrs   TO  it_tab-bukrs,
            it_pntab-pspnr   TO  it_tab-pspnr.

*> 후취 이자 금액.
      IF it_pntab-procp EQ 'C'.
        MOVE it_pntab-itrst TO  it_tab-itrst.
      ENDIF.

*> 송금은행 정보 발췌.
      READ TABLE it_ig3 WITH KEY epart = it_pntab-ntcbk.
      IF sy-subrc EQ 0.
        MOVE: it_ig3-lifnr  TO  it_tab-lifnr,
              it_ig3-namet  TO  it_tab-name1.
      ENDIF.
*> 회계문서.
      SELECT gjahr belnr bldat budat
        INTO (it_tab-gjahr, it_tab-belnr, it_tab-bldat, it_tab-budat)
        FROM ztiviv00
       WHERE iblno   EQ it_pntab-iblno
         AND prpyn   EQ  'I'
       GROUP BY gjahr belnr bldat budat.
      ENDSELECT.
      COLLECT it_tab.
    ENDLOOP.
  ENDIF.

*> Payment Notice 데이타 발췌(Usance 선취이자금액).
  SELECT p~pntam p~waers p~pntno p~opnno p~expdt p~itrst
         p~unam  p~bukrs p~pspnr p~procp p~ntcbk p~bgndt
    INTO CORRESPONDING FIELDS OF TABLE it_pntab
    FROM ztitpnk AS p INNER JOIN ztivrq04 AS r
      ON p~reqno  EQ  r~reqno
     AND r~reqty  EQ  'LC'
     AND r~ilcty  EQ  'U'
   WHERE p~bukrs    IN  s_bukrs
     AND p~bgndt    IN  s_zfbdt
     AND p~procp    EQ  'P'
     AND p~itrst    NE  0.

  IF sy-subrc EQ 0.
    LOOP AT it_pntab.
      CLEAR:it_tab.
      MOVE: 'P'              TO  it_tab-fndty,
            it_pntab-itrst   TO  it_tab-itrst,
            it_pntab-waers   TO  it_tab-waers,
            it_pntab-pntno   TO  it_tab-refno,
            it_pntab-opnno   TO  it_tab-docnm,
            it_pntab-bgndt   TO  it_tab-ddispo,
            it_pntab-unam    TO  it_tab-uname,
            it_pntab-bukrs   TO  it_tab-bukrs,
            it_pntab-pspnr   TO  it_tab-pspnr.

*> 송금은행 정보 발췌.
      READ TABLE it_ig3 WITH KEY epart = it_pntab-ntcbk.
      IF sy-subrc EQ 0.
        MOVE: it_ig3-lifnr  TO  it_tab-lifnr,
              it_ig3-namet  TO  it_tab-name1.
      ENDIF.
      COLLECT it_tab.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " Get_Payment_Notice_Data
