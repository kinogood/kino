************************************************************************
*                                                                      *
* Title         : ZTIR0060                                             *
*                                                                      *
* Description   : [Report] 은행별 한도관리                             *
*                                                                      *
* Creation Date : 2003/10/23                                           *
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
*                                                                      *
*                                                                      *
************************************************************************
PROGRAM   ztir0060
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
* SAP Tables                                                           *
************************************************************************
TABLES: ztitrqk,
        ztitrqs,
        ztitpnk,
        ztstig3,
        ztitig80,
        ztivig80,
        sscrfields,
        dfies .    ">DD Interface: Table Fields for DDIF_FIELDINFO_GET

************************************************************************
* Internal Tables                                                      *
************************************************************************
TYPES: BEGIN OF ty_list.
        INCLUDE STRUCTURE ztivig80.
TYPES: color      TYPE slis_t_specialcol_alv.
TYPES: END OF ty_list.

DATA: BEGIN OF it_ztitig80 OCCURS 20.
        INCLUDE STRUCTURE ztitig80.
DATA: END OF it_ztitig80.

DATA: BEGIN OF it_ztstig3 OCCURS 20.
        INCLUDE STRUCTURE ztstig3.
DATA: END OF it_ztstig3.

DATA: BEGIN OF it_ztivrq02 OCCURS 20.
        INCLUDE STRUCTURE ztivrq02.
DATA: END OF it_ztivrq02.

DATA: BEGIN OF it_ztitpnk OCCURS 20.
        INCLUDE STRUCTURE ztitpnk.
DATA: END OF it_ztitpnk.

DATA: BEGIN OF it_reqno OCCURS 20,
      reqno    TYPE ztireqno,
      amdsq    TYPE ztiamdsq,
      END OF it_reqno.

DATA: it_list      TYPE STANDARD TABLE OF ty_list,
      gs_list      TYPE ty_list,
      ls_list      TYPE ty_list.
************************************************************************
* DATA Declarations                                                    *
************************************************************************
DATA: l_count TYPE i.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
    c_save(1)   TYPE  c             VALUE 'A'.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000'.   ">Company code
** JS전선 회사코드 2007/04 KSH --------------------------------------

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
       g_answer        TYPE   c,
       g_out_text(70)  TYPE   c,             "text field(display)
       g_err_mode      TYPE   c,
       g_linet(4)      TYPE   c,
       line_cnt(02)    TYPE   n,
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
PARAMETERS:
  p_bukrs  LIKE ztivrq02-bukrs OBLIGATORY MEMORY ID buk ,
  p_date   LIKE sy-datum       OBLIGATORY DEFAULT sy-datum.
SELECTION-SCREEN END OF BLOCK dbsel.

SELECTION-SCREEN BEGIN OF BLOCK dbsel3 WITH FRAME TITLE text-002.
PARAMETERS: p_exe  RADIOBUTTON GROUP ab3 DEFAULT 'X',
            p_rpt  RADIOBUTTON GROUP ab3.
SELECTION-SCREEN END OF BLOCK dbsel3.

SELECTION-SCREEN BEGIN OF BLOCK dbsel2 WITH FRAME TITLE text-004.
PARAMETERS: p_full RADIOBUTTON GROUP ab2 DEFAULT 'X',
            p_list RADIOBUTTON GROUP ab2.
SELECTION-SCREEN END OF BLOCK dbsel2.

SELECTION-SCREEN: BEGIN OF BLOCK alv WITH FRAME TITLE text-003.
PARAMETERS: alv_def LIKE disvariant-variant.
SELECTION-SCREEN: END OF BLOCK alv.
*> 은행한도 유지보수
SELECTION-SCREEN FUNCTION KEY 1.

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
  IF sscrfields-ucomm = 'FC01'.
    CALL TRANSACTION 'ZTII080' AND SKIP FIRST SCREEN.
  ENDIF.
*> 사용자 Input values Check
  PERFORM check_input_values.
*> 사용자 레이아웃 Input values Check
  PERFORM alv_variant_check.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM p1102_authorization_check USING p_bukrs.
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
*                                                                      *
* START-OF-SELECTION Event                                             *
*                                                                      *
************************************************************************
START-OF-SELECTION.
  PERFORM confirm_message_box.
  CHECK g_answer EQ 'Y'.
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

  SET TITLEBAR 'T1000'.

  MOVE '은행한도 유지보수' TO sscrfields-functxt_01.

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
         l_opamt     LIKE ztitrqs-opamt,
         l_ztitig80  LIKE ztitig80.

  REFRESH: it_ztivrq02,
           it_ztstig3,
           it_ztitig80,
           it_reqno.

*> PROGRESS Display.
  g_line1    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_line1.

*> 거래 상대방 테이블 발췌.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_ztstig3
    FROM ztstig3
   WHERE parti EQ 'B'.

*> 기존 등록된 한도테이블 발췌.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_ztitig80
    FROM ztitig80
   WHERE bukrs  EQ  p_bukrs.

  IF p_rpt EQ 'X'.
*> List 용 Internal table
    LOOP AT it_ztitig80.
      MOVE-CORRESPONDING it_ztitig80 TO gs_list.
      READ TABLE it_ztstig3 WITH KEY epart = it_ztitig80-epart.
      IF sy-subrc EQ 0.
        gs_list-namet = it_ztstig3-namet.
      ENDIF.
      APPEND gs_list TO it_list.
    ENDLOOP.

    DESCRIBE TABLE it_list LINES g_line.
    IF g_line EQ 0.
      MESSAGE s902.
    ENDIF.
    EXIT.
  ENDIF.

*>수입의뢰select.
  SELECT reqno MAX( amdsq ) AS amdsq
    INTO CORRESPONDING FIELDS OF TABLE it_reqno
    FROM ztivrq02
   WHERE bukrs  EQ  p_bukrs
     AND opnbk  NE  space
     AND ilcty  NE  space
     AND reqty  EQ  'LC'
     AND docst  EQ  'O'
     AND dcend  EQ  space
   GROUP BY reqno.

  IF sy-subrc EQ 0.
*> 수입의뢰
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE it_ztivrq02
      FROM ztivrq02
       FOR ALL ENTRIES IN it_reqno
     WHERE bukrs  EQ  p_bukrs
       AND reqno  EQ  it_reqno-reqno
       AND amdsq  EQ  it_reqno-amdsq.
*> Notice
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE it_ztitpnk
      FROM ztitpnk
       FOR ALL ENTRIES IN it_reqno
     WHERE bukrs  EQ  p_bukrs
       AND reqno  EQ  it_reqno-reqno
       AND ntcbk  NE  space.
  ELSE.
    MESSAGE s902.
    EXIT.
  ENDIF.
*> 기존 내역 CLEAR.
  LOOP AT it_ztitig80.
    CLEAR: it_ztitig80-opnas, it_ztitig80-opnus,
           it_ztitig80-balas, it_ztitig80-balus,
           it_ztitig80-ntcas, it_ztitig80-ntcus,
           it_ztitig80-setas, it_ztitig80-setus,
           it_ztitig80-atcas, it_ztitig80-atcus,
           it_ztitig80-spsas, it_ztitig80-spsus.
    it_ztitig80-waers = 'USD'.
    it_ztitig80-bukrs = p_bukrs.
    it_ztitig80-mandt = sy-mandt.
    MODIFY it_ztitig80.
  ENDLOOP.

*> 개설금액 내역
  REFRESH: it_list. CLEAR: it_list.
  LOOP AT it_ztivrq02.
    CLEAR: it_ztitig80.
    MOVE: it_ztivrq02-opnbk TO it_ztitig80-epart,
          sy-mandt          TO it_ztitig80-mandt,
          'USD'             TO it_ztitig80-waers,
          p_bukrs           TO it_ztitig80-bukrs.

    READ TABLE it_ztitig80 INTO l_ztitig80
                           WITH KEY epart = it_ztivrq02-opnbk.
    IF sy-subrc EQ 0.
      it_ztitig80-agmdt = l_ztitig80-agmdt.
    ENDIF.

    IF it_ztivrq02-ilcty EQ 'U'.
      MOVE: it_ztivrq02-usamt TO it_ztitig80-opnus,
            'USD'             TO it_ztitig80-waers.
    ELSEIF it_ztivrq02-ilcty EQ 'A'.
      MOVE: it_ztivrq02-usamt TO it_ztitig80-opnas,
            'USD'             TO it_ztitig80-waers.
    ELSE.
      CONTINUE.
    ENDIF.
    COLLECT it_ztitig80.
  ENDLOOP.

*> Notice 금액 내역
  LOOP AT it_ztitpnk  .
    CLEAR: it_ztitig80.
    READ TABLE it_ztivrq02 WITH KEY reqno = it_ztitpnk-reqno.
    IF sy-subrc NE 0.
      CLEAR: it_ztivrq02.
    ENDIF.

    MOVE: it_ztitpnk-ntcbk TO it_ztitig80-epart,
          sy-mandt          TO it_ztitig80-mandt,
          'USD'             TO it_ztitig80-waers,
          p_bukrs           TO it_ztitig80-bukrs.

    READ TABLE it_ztitig80 INTO l_ztitig80
                           WITH KEY epart = it_ztitpnk-ntcbk.
    IF sy-subrc EQ 0.
      it_ztitig80-agmdt = l_ztitig80-agmdt.
    ENDIF.

    IF it_ztivrq02-ilcty EQ 'U'.
      MOVE: it_ztitpnk-usamt TO it_ztitig80-ntcus,
            'USD'             TO it_ztitig80-waers.
*> 만기일자.
      IF it_ztitpnk-expdt LE p_date.
        MOVE: it_ztitpnk-usamt TO it_ztitig80-setus.
      ENDIF.
    ELSEIF it_ztivrq02-ilcty EQ 'A'.
      MOVE: it_ztitpnk-usamt TO it_ztitig80-ntcas,
            'USD'             TO it_ztitig80-waers.
*> 최종결제일.
      IF it_ztitpnk-stldt LE p_date.
        MOVE: it_ztitpnk-usamt TO it_ztitig80-setas.
      ENDIF.
    ELSE.
      CONTINUE.
    ENDIF.
    COLLECT it_ztitig80.
  ENDLOOP.

*> 여유한도 계산.
  LOOP AT it_ztitig80.
*> 발행잔액.
    it_ztitig80-balas = it_ztitig80-opnas - it_ztitig80-ntcas.
    it_ztitig80-balus = it_ztitig80-opnus - it_ztitig80-ntcus.

*> 인수잔액.
    it_ztitig80-atcas = it_ztitig80-ntcas - it_ztitig80-setas.
    it_ztitig80-atcus = it_ztitig80-ntcus - it_ztitig80-setus.

*> 여유한도.
    it_ztitig80-spsas = it_ztitig80-agmas - it_ztitig80-opnas
                                          + it_ztitig80-setas.
    it_ztitig80-spsus = it_ztitig80-agmus - it_ztitig80-opnus
                                          + it_ztitig80-setus.

    MODIFY it_ztitig80.

*> List 용 Internal table
    MOVE-CORRESPONDING it_ztitig80 TO gs_list.
    READ TABLE it_ztstig3 WITH KEY epart = it_ztitig80-epart.
    IF sy-subrc EQ 0.
      gs_list-namet = it_ztstig3-namet.
    ENDIF.
    APPEND gs_list TO it_list.
  ENDLOOP.

  SET UPDATE TASK LOCAL.

  DELETE FROM ztitig80.

  DESCRIBE TABLE it_list LINES g_line.
  IF g_line EQ 0.
    MESSAGE s902.
  ELSE.
    INSERT ztitig80 FROM TABLE it_ztitig80.
  ENDIF.

  IF sy-subrc EQ 0.
    WRITE g_line TO g_linet.
    MESSAGE s931 WITH g_linet.
    COMMIT WORK.
  ELSE.
    MESSAGE s932.
    ROLLBACK WORK.
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

*  CLEAR  fcs.
*  fcs-tabname   = 'IT_LIST'.
*  fcs-fieldname = 'BOX'.
*  APPEND  fcs TO fc1.
*
*> Create field catagory table
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name   = 'ZTIVIG80'
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
      WHEN 'EPART'.
        fcs-col_pos = 1.
        fcs-key     = 'X'.
*        fcs-hotspot  = 'X'.
        fcs-seltext_l = '은행코드'.
        fcs-seltext_m = '은행코드'.
        fcs-seltext_s = '은행코드'.
*        fcs-no_out  = 'X'.
*        clear: fcs-fieldname.
      WHEN 'NAMET'.
        fcs-col_pos   = 2.
        fcs-outputlen = 16.
        fcs-key     = 'X'.
        fcs-seltext_l = '은행명'.
        fcs-seltext_m = '은행명'.
        fcs-seltext_s = '은행명'.
*        clear: fcs-fieldname.
      WHEN 'WAERS'.
        fcs-col_pos = 3.
      WHEN 'AGMAS' OR 'AGMUS' OR 'BALAS' OR 'BALUS' OR
           'ATCAS' OR 'ATCUS' OR 'SPSAS' OR 'SPSUS'.
        fcs-do_sum    = 'X'.
        fcs-outputlen = 16.
      WHEN 'AGMDT'.

      WHEN 'CNAM' OR 'CDAT' OR 'CTME' OR
           'UNAM' OR 'UDAT' OR 'UTME'.
        fcs-no_out  = 'X'.
      WHEN OTHERS.
        fcs-no_out  = 'X'.
        fcs-do_sum  = 'X'.
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
*  gs_layout-box_fieldname     = 'BOX'.
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

*        WHEN 'IBLNO'.
*          PERFORM  display_bl_document(ZTIr0000)
*                                       USING gs_list-iblno
*                                             space.
*        WHEN 'REQNO'.
*          PERFORM  display_import_document(ZTIr0000)
*                                       USING gs_list-reqno
*                                             space
*                                             space.
*        WHEN 'EBELN'.
*          PERFORM  display_purchase_order(ZTIr0000)
*                                          USING GS_list-ebeln
*                                               '00000'.
*
*        WHEN 'MATNR'.
*          PERFORM  display_material_master(ZTIr0000)
*                                       USING gs_list-matnr
*                                             space
*                                             space.
*
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
  st_sort-fieldname = 'EPART'.
  st_sort-tabname   = 'IT_LIST'.
  st_sort-up        = 'X'.
*  ST_SORT-GROUP     = 'X'.
*  st_sort-subtot    = 'X'.
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
  header-info = '수입신용장 한도 현황'.

  CLEAR: header-key.
  APPEND header.

** JS전선 회사코드 2007/04 KSH --------------------------------------
  DATA: l_butxt LIKE t001-butxt.
  CLEAR: l_butxt.
  SELECT SINGLE butxt FROM t001
                      INTO l_butxt
                     WHERE bukrs EQ p_bukrs.

  header-typ = 'S'.
  header-key = '회사코드 '.
  CONCATENATE p_bukrs l_butxt INTO header-info SEPARATED BY space.
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
*&      Form  confirm_message_box
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM confirm_message_box .

  IF p_exe  EQ  'X'.
    CLEAR: g_answer.

    CALL FUNCTION 'Z_TI_POPUP_TO_CONFIRM_MESSAGE'
      EXPORTING
        xmode  = 'L'
      IMPORTING
        answer = g_answer.
  ELSE.
    g_answer = 'Y'.
  ENDIF.

ENDFORM.                    " confirm_message_box
*&---------------------------------------------------------------------*
*&      Form  check_input_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_input_values .

  DATA: l_bukrs   LIKE t001-bukrs.

* Company code
  SELECT bukrs INTO (l_bukrs)
               FROM t001 WHERE bukrs EQ p_bukrs.
  ENDSELECT.
  IF sy-subrc <> 0.
    PERFORM get_ftext(rddfie00) USING 'T001' 'BUKRS' sy-langu
                                CHANGING dfies g_subrc.
    SET CURSOR FIELD 'P_BUKRS'.
    MESSAGE e348(m7) WITH dfies-scrtext_m.
  ENDIF.

ENDFORM.                    " check_input_values
