************************************************************************
*                                                                      *
* Title         : ZTIR4030                                             *
*                                                                      *
* Description   : [Report]  수입물동량 현황                            *
*                                                                      *
* Creation Date : 2004/12/10                                           *
*                                                                      *
* Author        : Jong Pil, Park                                       *
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
REPORT  ztir4030
        MESSAGE-ID zmti00
        NO STANDARD PAGE HEADING.
************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis.    "> Globale Type(ALV)

TYPES: BEGIN OF ty_selt.
TYPES:
       werks  LIKE ztivcc03-werks,     "플랜트
       pname  LIKE t001w-name1,        "플랜트
       count  TYPE i,                  "건수
       BRGEW  LIKE ztivcc03-BRGEW,     "총중량
       GEWEI LIKE ztivcc03-GEWEI,    "총중량단위
       ccuau  LIKE ztivcc03-ccuau,     "과세가격합계(USD)
       ccuauc LIKE ztivcc03-ccuauc,    "과세가격합계(USD)통화
       ccuak  LIKE ztivcc03-ccuak,     "과세가격합계(KRW)
       ccuakc LIKE ztivcc03-ccuakc,    "과세가격합계(KRW)통화
       cdutx  LIKE ztivcc03-cdutx,     "관세
       csptx  LIKE ztivcc03-csptx,     "특소세
       caltx  LIKE ztivcc03-caltx,     "주세
       ctrtx  LIKE ztivcc03-ctrtx,     "교통세
       cintx  LIKE ztivcc03-cintx,     "교육세
       cagtx  LIKE ztivcc03-cagtx,     "농특세
       clttx  LIKE ztivcc03-clttx,     "신고지연가산세
       cadtx  LIKE ztivcc03-cadtx,     "부가세
       sumtx  LIKE ztivcc03-ctotl,     "합계
       otrtx  LIKE ztivcc03-ctotl,     "관세외 합
       ctnq2  type i,                  "컨테이너수2
       ctnq4  type i,                  "컨테이너수4
       tport  LIKE ztivcc03-tport,     "도착항
       pltrn  LIKE ztivcc03-pltrn,     "도착항명
       cdcor  LIKE ztivcc03-cdcor,     "세관.
       cddec  LIKE dd07d-ddtext,       "세관명
       sdrlt  LIKE ztivcc03-sdrlt,     "송부처
       sdrltn LIKE dd07d-ddtext,       "송부처명
       rptty  LIKE ztivcc03-rptty,     "신고형태
       rpttyn LIKE dd07d-ddtext.       "신고형태명
TYPES: END OF ty_selt.

* LIST TYPE
TYPES: BEGIN OF ty_list,
       ebeln LIKE ztivcc03-ebeln,     "P/O No
       iblno LIKE ztivcc03-iblno,     "B/L관리번호
       blnum LIKE ztivcc03-blnum,     "B/L번호.
       cdcno LIKE ztivcc03-cdcno,     "신고번호
       bldty LIKE ztivcc03-bldty.     "유무환구분
INCLUDE TYPE ty_selt.
*TYPES:  color TYPE slis_t_specialcol_alv.
TYPES: END OF ty_list.

****at line-selection****alv용
DATA: BEGIN OF fc_struct,
        tabname(7),
        fieldname(9),
        ref_tabname(7),
        ref_fieldname(6),
        no_out(1),
        cqindicator(1),
        cqfield(6),
      END OF fc_struct.

*>ALV POPUP.
DATA: gs_private  TYPE slis_data_caller_exit,
      gs_selfield TYPE slis_selfield,
      t_fieldcat  TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      g_exit(1)   TYPE c,
      dyname      LIKE d020s-prog,
*      L_TITLE     TYPE SY-TITLE.
      g_title(99) TYPE c,
      extab TYPE slis_t_extab.

DEFINE mfc.
  clear: t_fieldcat, fc_struct.
  t_fieldcat-tabname        = &1.
  t_fieldcat-fieldname      = &2.
  t_fieldcat-ref_tabname    = &3.
  t_fieldcat-ref_fieldname  = &4.
  t_fieldcat-no_out         = &5.

  case &6.
    when 'C'.
      t_fieldcat-cfieldname = &7.
    when 'Q'.
      t_fieldcat-qfieldname = &7.
  endcase.
  append t_fieldcat.
END-OF-DEFINITION.
************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: ztitcck,
        ztitblp,
        ztitblk,
        ztivcc03,
        t001,
        t001w,
        dfies.

TABLES: icon.
************************************************************************
* Internal Tables  & Structure
************************************************************************
*SELECT용
DATA: it_selt TYPE STANDARD TABLE OF ty_selt,
      gs_selt TYPE ty_selt,
      ls_selt TYPE ty_selt.

DATA: it_list TYPE STANDARD TABLE OF ty_list,
      gs_list TYPE ty_list,
      ls_list TYPE ty_list.

DATA: BEGIN OF it_subtotal OCCURS 0,
       werks LIKE ztivcc03-werks,     "플랜트
       count TYPE i,
      END   OF it_subtotal.

DATA: t_alv_list TYPE ty_list.

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

DATA : s_variant      LIKE  disvariant,
       s_var_usr      LIKE  disvariant.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
** JS전선 회사코드 2007/04 KSH --------------------------------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
** JS전선 회사코드 2007/04 KSH --------------------------------------
    c_save(1)   TYPE  c             VALUE 'A'.
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

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK box1 WITH FRAME TITLE text-oo1.

SELECT-OPTIONS:
  s_bukrs  FOR ztivcc03-bukrs 	               "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk ,
 s_cdrdt FOR ztivcc03-cdrdt,                      "수입신고수리일
 s_badat FOR ztivcc03-badat,                       "보세운송일
 s_tport FOR ztivcc03-tport,                      "도착항
 s_rptty FOR ztivcc03-rptty,                      "신고구분
 s_sdrlt FOR ztivcc03-sdrlt,                      "선적서류 송부처
 s_cdcor FOR ztivcc03-cdcor,                      "세관
 s_state FOR ztivcc03-state,                      "관세사
 s_werks FOR ztivcc03-werks,                      "플랜트
 s_bavar FOR ztivcc03-bavar,                      "보세구역
 s_bldty FOR ztivcc03-bldty,                      "무환형태
 s_impty FOR ztivcc03-impty.                      "자재구분
SELECTION-SCREEN END OF BLOCK box1.

SELECTION-SCREEN BEGIN OF BLOCK box2 WITH FRAME TITLE text-002.
PARAMETERS: p_int1 RADIOBUTTON GROUP pg1 DEFAULT 'X',
            p_int2 RADIOBUTTON GROUP pg1 ,
            p_int3 RADIOBUTTON GROUP pg1,
            p_int4 RADIOBUTTON GROUP pg1.
*SELECTION-SCREEN END OF BLOCK box2.
SELECTION-SCREEN ULINE.
*SELECTION-SCREEN BEGIN OF BLOCK box3 WITH FRAME TITLE text-003.
PARAMETERS: p_full RADIOBUTTON GROUP pg3 MODIF ID opn DEFAULT 'X',
            p_list RADIOBUTTON GROUP pg3 MODIF ID opn .
SELECTION-SCREEN END OF BLOCK box2.

*> Report variant
SELECTION-SCREEN: BEGIN OF BLOCK alv WITH FRAME TITLE text-004.
PARAMETERS: alv_def LIKE disvariant-variant." NO-DISPLAY.
SELECTION-SCREEN: END OF BLOCK alv.

************************************************************************
* User Include Define                                                  *
************************************************************************
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: l_yn    type c.
INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

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
  g_line1 = 100.
  g_out_text = text-905.
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM set_colorize_build.       ">Set color
  PERFORM set_sort_field.           ">Set ALV sort fields
  PERFORM set_fieldcat_build.      ">Set ALV field category
  PERFORM display_alv_list.         ">Call ALV Functions

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

************************************************************************
*                                                                      *
* END-OF-PAGE Event                                                    *
*                                                                      *
************************************************************************
END-OF-PAGE.

************************************************************************
*                                                                      *
* TOP-OF-PAGE Event                                                    *
*                                                                      *
************************************************************************
TOP-OF-PAGE.

************************************************************************
*                                                                      *
* TOP-OF-PAGE DURING LINE-SELECTION Event                              *
*                                                                      *
************************************************************************
TOP-OF-PAGE DURING LINE-SELECTION.

************************************************************************
*                                                                      *
* S U B R O U T I N E S                                                *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  set_initial_data
*&---------------------------------------------------------------------*
FORM set_initial_data .

  DATA: l_bukrs LIKE t001-bukrs.
*STATUS
  SET TITLEBAR 'T1000'.

  GET PARAMETER ID 'BUK' FIELD l_bukrs.

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


ENDFORM.                    " set_initial_data
*&---------------------------------------------------------------------*
*&      Form  set_alv_init
*&---------------------------------------------------------------------*
FORM set_alv_init .
  FREE:  it_sort, fc.
  CLEAR: alv_keyinfo, gs_layout, alv_print, fc.
* PRINTING SETTINGS
  gs_layout-get_selinfos = 'X'.
  gs_layout-group_change_edit = 'X'.

  alv_print-no_print_selinfos = 'X'.
  alv_print-no_coverpage = 'X'.
  alv_print-no_print_listinfos = 'X'.

ENDFORM.                    " set_alv_init
*&---------------------------------------------------------------------*
*&      Form  clearing_work_area
*&---------------------------------------------------------------------*
FORM clearing_work_area .

  IF p_full EQ 'X'.
    alv_detail_func = 'REUSE_ALV_GRID_DISPLAY'.
  ELSE.
    alv_detail_func = 'REUSE_ALV_LIST_DISPLAY'.
  ENDIF.

ENDFORM.                    " clearing_work_area
*&---------------------------------------------------------------------*
*&      Form  get_data_for_display
*&---------------------------------------------------------------------*
FORM get_data_for_display .



  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_list
    FROM ztivcc03
     WHERE bukrs IN s_bukrs
       AND cdrdt IN s_cdrdt
       AND badat IN s_badat
       AND tport IN s_tport
       AND crety IN s_rptty
       AND sdrlt IN s_sdrlt
       AND cdcor IN s_cdcor
       AND state IN s_state
       AND werks IN s_werks
       AND bavar IN s_bavar
       AND bldty IN s_bldty
       AND impty IN s_impty.

  IF sy-subrc NE 0.
    MESSAGE s902.  EXIT.
  ENDIF.

  LOOP AT it_list INTO gs_list.

    CLEAR gs_selt.
    PERFORM get_data_list_tab.
    MOVE-CORRESPONDING : gs_list TO gs_selt.

    CASE 'X'.
      WHEN p_int1.   ">Port별.
        CLEAR: gs_selt-cdcor,
               gs_selt-cddec,
               gs_selt-sdrlt,
               gs_selt-sdrltn,
               gs_selt-rptty,
               gs_selt-rpttyn.
      WHEN p_int2.   ">세관별.
        CLEAR: gs_selt-tport,
               gs_selt-pltrn,
               gs_selt-sdrlt,
               gs_selt-sdrltn,
               gs_selt-rptty,
               gs_selt-rpttyn.
      WHEN p_int3.   ">무환/Ship Back별.
        CLEAR: gs_selt-tport,
               gs_selt-pltrn,
               gs_selt-cdcor,
               gs_selt-cddec,
               gs_selt-rptty,
               gs_selt-rpttyn.
      WHEN p_int4.   ">신고형태별.
        CLEAR: gs_selt-tport,
               gs_selt-pltrn,
               gs_selt-cdcor,
               gs_selt-cddec,
               gs_selt-sdrlt,
               gs_selt-sdrltn.
    ENDCASE.
*>도착항명
    SELECT single portk
        INTO gs_selt-pltrn
        from ztstigp
        WHERE land1 EQ 'KR'
        AND  portc EQ gs_selt-tport.

*>세관명
    PERFORM  get_domain_value_text(ztir0000) USING 'ZTICDCOR'
                                                   gs_selt-CDCOR
                                                   gs_selt-CDDEC.
*>무환/Ship Back별
    PERFORM  get_domain_value_text(ztir0000) USING 'ZITSDRLT'
                                                   gs_selt-SDRLT
                                                   gs_selt-SDRLTN.
*>신고형태별
    PERFORM  get_domain_value_text(ztir0000) USING 'ZTIRPTTY'
                                                   gs_selt-RPTTY
                                                   gs_selt-RPTTYN.

      COLLECT gs_selt INTO it_selt.



        MODIFY it_list FROM gs_list.
      ENDLOOP.

      DESCRIBE TABLE it_selt LINES g_line.
      IF g_line EQ 0.
        MESSAGE s902.
      ENDIF.

    ENDFORM.                    " get_data_for_display
*&---------------------------------------------------------------------*
*&      Form  display_alv_list
*&---------------------------------------------------------------------*
FORM display_alv_list .

  DATA: fc_detail TYPE slis_fieldcat_alv OCCURS 0 WITH HEADER LINE.
  DATA: variant_detail      LIKE disvariant.
  DATA: exit     TYPE slis_event_exit   OCCURS 0 WITH HEADER LINE.
  DATA: events   TYPE slis_alv_event    OCCURS 0 WITH HEADER LINE.
  DATA: groups   TYPE slis_sp_group_alv OCCURS 0 WITH HEADER LINE.


  CASE 'X'.
    WHEN p_int1.
      SET TITLEBAR 'T1100' WITH 'Port 별'.
    WHEN p_int2.
      SET TITLEBAR 'T1100' WITH '세관 별'.
    WHEN p_int3.
      SET TITLEBAR 'T1100' WITH '무환,SHIP-BACK 별'.
    WHEN p_int4.
      SET TITLEBAR 'T1100' WITH '신고형태 별'.
  ENDCASE.


* The detail ALV may modify the list (sorting). If returned to the
* base list, the original list needs to be restored.
  REFRESH fc_detail.
  LOOP AT it_fieldcat INTO gs_fieldcat.
    MOVE-CORRESPONDING gs_fieldcat TO fc_detail.
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

  events-name = slis_ev_subtotal_text.
  events-form = slis_ev_subtotal_text.
  APPEND events.

*> ALV reuse function call..
  CALL FUNCTION  alv_detail_func
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
        t_outtab                 = it_selt[].

ENDFORM.                    " display_alv_list
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

*  SET TITLEBAR 'T1000'.
  SET PF-STATUS 'STANDARD' EXCLUDING extab.

ENDFORM.                    " SET_ALV_STATUS
*&---------------------------------------------------------------------*
*&      Form  set_fieldcat_build
*&---------------------------------------------------------------------*
FORM set_fieldcat_build .
  CASE 'X'.
    WHEN p_int1.
      PERFORM 3010_fill_field_category USING :
           'S' 'TABNAME'     'IT_SELT',
           ' ' 'SELTEXT_M'   '도착항',
           ' ' 'FIELDNAME'    'TPORT',
*           ' ' 'NO_OUT'        'X',
           'E' 'OUTPUTLEN'   '6',

           'S' 'TABNAME'     'IT_SELT',
           ' ' 'SELTEXT_M'   '도착항',
           ' ' 'FIELDNAME'    'PLTRN',
*           ' ' 'NO_OUT'        'X',
           'E' 'OUTPUTLEN'   '16'.
    WHEN p_int2.
      PERFORM 3010_fill_field_category USING :
           'S' 'TABNAME'     'IT_SELT',
           ' ' 'SELTEXT_M'   '세관',
           ' ' 'FIELDNAME'    'CDCOR',
*           ' ' 'NO_OUT'        'X',
           'E' 'OUTPUTLEN'   '6',

           'S' 'TABNAME'     'IT_SELT',
           ' ' 'SELTEXT_M'   '세관명',
           ' ' 'FIELDNAME'    'CDDEC',
*           ' ' 'NO_OUT'        'X',
           'E' 'OUTPUTLEN'   '16'.

    WHEN p_int3.
      PERFORM 3010_fill_field_category USING :
           'S' 'TABNAME'     'IT_SELT',
           ' ' 'SELTEXT_M'   '송부처',
           ' ' 'FIELDNAME'    'SDRLT',
*           ' ' 'NO_OUT'        'X',
           'E' 'OUTPUTLEN'   '6',

           'S' 'TABNAME'     'IT_SELT',
           ' ' 'SELTEXT_M'   '송부처명',
           ' ' 'FIELDNAME'    'SDRLTN',
*           ' ' 'NO_OUT'        'X',
           'E' 'OUTPUTLEN'   '16'.
    WHEN p_int4.
      PERFORM 3010_fill_field_category USING :
           'S' 'TABNAME'     'IT_SELT',
           ' ' 'SELTEXT_M'   '신고형태',
           ' ' 'FIELDNAME'    'RPTTY',
*           ' ' 'NO_OUT'        'X',
           'E' 'OUTPUTLEN'   '6',

           'S' 'TABNAME'     'IT_SELT',
           ' ' 'SELTEXT_M'   '신고형태',
           ' ' 'FIELDNAME'    'RPTTYN',
*           ' ' 'NO_OUT'        'X',
           'E' 'OUTPUTLEN'   '16'.
  ENDCASE.


  PERFORM 3010_fill_field_category USING :

*       'S' 'SELTEXT_M'   '신고 수리일',
       'S' 'REF_TABNAME'   'ZTIVCC03',      "플랜트
       ' ' 'TABNAME'     'IT_SELT',
       ' ' 'FIELDNAME'    'WERKS',
       'E' 'OUTPUTLEN'   '10',

*       'S' 'SELTEXT_M'   'P/O No',
       'S' 'REF_TABNAME'   'ZTIVCC03',       "플랜트명
       ' ' 'SELTEXT_M'   '플랜트명',
       ' ' 'TABNAME'     'IT_SELT',
       ' ' 'FIELDNAME'   'PNAME',
       'E' 'OUTPUTLEN'   '20',


*       ' S' 'REF_TABNAME'   'ZTIVCC03',       "건수
       'S' 'SELTEXT_M'   '건수',
       ' ' 'TABNAME'     'IT_SELT',
       ' ' 'FIELDNAME'   'COUNT',
       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'   '4',

       'S' 'TABNAME'     'IT_SELT',           "중량
       ' ' 'SELTEXT_M'   '중량',
       ' ' 'FIELDNAME'    'BRGEW',
       ' ' 'QFIELDNAME'   'GEWEI',
       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_SELT',           "중량단위
       ' ' 'SELTEXT_M'   '중량단위',
       ' ' 'FIELDNAME'    'GEWEI',
       'E' 'OUTPUTLEN'   '15',

*       'S' 'SELTEXT_M'   '신고번호',
       ' S' 'REF_TABNAME'   'ZTIVCC03',       "과세가격합계(USD)
       ' ' 'SELTEXT_M'   'CIF$',
       ' ' 'SELTEXT_S'   'CIF$',
       ' ' 'SELTEXT_L'   'CIF$',
       ' ' 'TABNAME'     'IT_SELT',
       ' ' 'DO_SUM'        'X',
       ' ' 'FIELDNAME'   'CCUAU',
       ' ' 'CFIELDNAME'   'CCUAUC',
       'E' 'OUTPUTLEN'    '20',


       'S' 'TABNAME'     'IT_SELT',          "과세가격합계통화
       ' ' 'SELTEXT_M'   '통화',
       ' ' 'FIELDNAME'    'CCUAUC',
       'E' 'OUTPUTLEN'   '15',


       'S' 'TABNAME'     'IT_SELT',         "과세가격합계(KRW)
       ' ' 'SELTEXT_M'   '감정가격',
       ' ' 'FIELDNAME'    'CCUAK',
       ' ' 'CFIELDNAME'   'CCUAKC',
       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_SELT',         "과세가격합계(KRW)통화
       ' ' 'SELTEXT_M'   '통화',
       ' ' 'FIELDNAME'    'CCUAKC',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_SELT',         "관세외
       ' ' 'SELTEXT_M'   '관세외',
       ' ' 'FIELDNAME'    'OTRTX',
       ' ' 'CFIELDNAME'   'CCUAKC',
       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_SELT',          "부가세
       ' ' 'SELTEXT_M'   '부가세',
       ' ' 'FIELDNAME'    'CADTX',
       ' ' 'CFIELDNAME'   'CCUAKC',
       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_SELT',          "납부세액계
       ' ' 'SELTEXT_M'   '납부세액계',
       ' ' 'FIELDNAME'    'SUMTX',
       ' ' 'CFIELDNAME'   'CCUAKC',
       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_SELT',
       ' ' 'SELTEXT_M'   '20Cont',
       ' ' 'FIELDNAME'    'CTNQ2',
       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'   '8',

       'S' 'TABNAME'     'IT_SELT',
       ' ' 'SELTEXT_M'   '40Cont',
       ' ' 'FIELDNAME'    'CTNQ4',
       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'   '8'.



*

ENDFORM.                    " set_fieldcat_build
*&---------------------------------------------------------------------*
*&      Form  3010_fill_field_category
*&---------------------------------------------------------------------*
FORM 3010_fill_field_category  USING    p_section p_fname p_value.

  DATA l_col(40).
  FIELD-SYMBOLS <l_fs>.

  IF p_section = 'S'.
    CLEAR gs_fieldcat.
  ENDIF.

* 속성 MOVE
  CONCATENATE 'GS_FIELDCAT-' p_fname  INTO l_col.
  ASSIGN      (l_col)         TO       <l_fs>.
  MOVE         p_value        TO       <l_fs>.

  IF p_section = 'E'.
    APPEND gs_fieldcat TO it_fieldcat.
  ENDIF.

ENDFORM.                    " 3010_fill_field_category
*&---------------------------------------------------------------------*
*&      Form  set_colorize_build
*&---------------------------------------------------------------------*
FORM set_colorize_build .

ENDFORM.                    " set_colorize_build
*&---------------------------------------------------------------------*
*&      Form  set_sort_field
*&---------------------------------------------------------------------*
FORM set_sort_field .


  CASE 'X'.
    WHEN p_int1.
      CLEAR  st_sort.
      st_sort-spos = '01'.
      st_sort-fieldname = 'TPORT'.
      st_sort-tabname   = 'IT_SELT'.
      st_sort-up        = 'X'.
      st_sort-group     = 'X'.
      st_sort-subtot    = 'X'.
*      ST_SORT-EXPA      = 'X'.
      APPEND st_sort TO it_sort.
    WHEN p_int2.
      CLEAR  st_sort.
      st_sort-spos = '01'.
      st_sort-fieldname = 'CDCOR'.
      st_sort-tabname   = 'IT_SELT'.
      st_sort-up        = 'X'.
      st_sort-group     = 'X'.
      st_sort-subtot    = 'X'.
*       ST_SORT-EXPA      = 'X'.
      APPEND st_sort TO it_sort.
    WHEN p_int3.
      CLEAR  st_sort.
      st_sort-spos = '01'.
      st_sort-fieldname = 'SDRLT'.
      st_sort-tabname   = 'IT_SELT'.
      st_sort-up        = 'X'.
      st_sort-group     = 'X'.
      st_sort-subtot    = 'X'.
*     ST_SORT-EXPA      = 'X'.
      APPEND st_sort TO it_sort.
    WHEN p_int4.
      CLEAR  st_sort.
      st_sort-spos = '01'.
      st_sort-fieldname = 'RPTTY'.
      st_sort-tabname   = 'IT_SELT'.
      st_sort-up        = 'X'.
      st_sort-group     = 'X'.
      st_sort-subtot    = 'X'.
*      ST_SORT-EXPA      = 'X'.
      APPEND st_sort TO it_sort.
  ENDCASE.


*
*  CLEAR  st_sort.
*  st_sort-spos = '02'.
*  st_sort-fieldname = 'CDCOR'.
*  st_sort-tabname   = 'IT_LIST'.
**  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
*  st_sort-subtot    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.
*
*  CLEAR  st_sort.
*  st_sort-spos = '03'.
*  st_sort-fieldname = 'STATE'.
*  st_sort-tabname   = 'IT_LIST'.
**  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
*  st_sort-subtot    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.


ENDFORM.                    " set_sort_field
*&---------------------------------------------------------------------*
*&      Form  exec_alv_f4
*&---------------------------------------------------------------------*
FORM exec_alv_f4 .

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

ENDFORM.                    " exec_alv_f4
*&---------------------------------------------------------------------*
*&      Form  alv_variant_check
*&---------------------------------------------------------------------*
FORM alv_variant_check .

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


ENDFORM.                    " alv_variant_check
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM top_of_page.

  DATA: l_mode TYPE i.
  DATA: header TYPE slis_listheader OCCURS 0 WITH HEADER LINE.
  DATA: l_header(20) TYPE c.

  CASE 'X'.
    WHEN p_int1.
      l_header =  'Port 별'.
    WHEN p_int2.
      l_header = '세관 별'.
    WHEN p_int3.
      l_header = '무환,SHIP-BACK 별'.
    WHEN p_int4.
      l_header = '신고형태 별'.
  ENDCASE.

  REFRESH header.
  header-typ = 'H'.
  header-info = '물량현황'.

  CONCATENATE l_header header-info INTO header-info
                                     SEPARATED BY space.

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
*&      Form  GET_DATA_LIST_TAB
*&---------------------------------------------------------------------*
FORM get_data_list_tab .

*> 플랜트명
  SELECT SINGLE name1
    INTO gs_list-pname
    FROM t001w
   WHERE werks EQ gs_list-werks.

*>관세외
  gs_list-otrtx =  gs_list-cdutx +    "관세
                   gs_list-csptx +    "특소세
                   gs_list-caltx +    "주세
                   gs_list-ctrtx +    "교통세
                   gs_list-cintx +    "교육세
                   gs_list-clttx +    "신고지연가산세
                   gs_list-cagtx .    "농특세
*>합계
  gs_list-sumtx = gs_list-otrtx +
                  gs_list-cadtx .     "부가세

  gs_list-count = 1.

ENDFORM.                    " GET_DATA_LIST_TAB
*&---------------------------------------------------------------------*
*&      Form  input_field_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM input_field_check .

* Company code
  SELECT SINGLE *
    FROM t001
   WHERE bukrs IN s_bukrs.
  IF sy-subrc <> 0.
    PERFORM get_ftext(rddfie00) USING 'T001' 'BUKRS' sy-langu
                                CHANGING dfies g_subrc.
    SET CURSOR FIELD 'S_BUKRS'.
    MESSAGE e348(m7) WITH dfies-scrtext_m.
  ENDIF.



ENDFORM.                    " input_field_check

*---------------------------------------------------------------------*
*       Form  SUBTOTAL_TEXT                                           *
*---------------------------------------------------------------------*
FORM subtotal_text USING my_listhead LIKE t_alv_list
                         my_subtotal TYPE slis_subtot_text.

  DATA: l_count(10)  TYPE c,
        l_text40(40) TYPE c.

  FIELD-SYMBOLS: <l_fs>.
*  DATA: l_vendor(10) TYPE c.

  CLEAR my_subtotal-display_text_for_subtotal.



  CASE my_subtotal-criteria.

    WHEN 'BUPLA'.  ">사업장.

    WHEN OTHERS.
      EXIT.
  ENDCASE.

*  READ TABLE it_subtotal WITH KEY
*                                  STATE  = t_alv_list-state
*                                  bupla  = t_alv_list-bupla.

  IF sy-subrc EQ 0.
    WRITE : it_subtotal-count TO l_count.
  ELSE.
    CLEAR: l_count.
    l_count+09 = 0.
  ENDIF.

  CONCATENATE <l_fs>
              my_subtotal-display_text_for_subtotal
              l_count '건'
              INTO my_subtotal-display_text_for_subtotal
              SEPARATED BY space.

ENDFORM.                    "SUBTOTAL_TEXT
*&---------------------------------------------------------------------*
*&      Form  CHECK_DOMAIN_VALUES
*&---------------------------------------------------------------------*
*       Domain Text Read
*----------------------------------------------------------------------*
FORM get_domain_value_text  USING  p_domain LIKE  dd07l-domname
                                   p_value
                                   p_text.

  DATA: l_value  LIKE dd07v-domvalue_l,
        l_text   LIKE dd07v-ddtext.

  CLEAR: l_text.

  MOVE: p_value TO l_value.

  CALL FUNCTION 'RV_DOMAIN_VALUE_TEXTS'
    EXPORTING
      domname  = p_domain
      domvalue = l_value
    IMPORTING
      ddtext   = l_text.

  MOVE: l_text TO p_text.

ENDFORM.                    " CHECK_DOMAIN_VALUES
*&---------------------------------------------------------------------*
*&      Form  USER_ALV_COMMAND
*&---------------------------------------------------------------------*
FORM user_alv_command USING   r_ucomm      LIKE sy-ucomm
                              rs_selfield  TYPE slis_selfield.
*
  CASE r_ucomm.
    WHEN 'DISPLAY' OR '&IC1'.    " AUF DOPPELKLICK REAGIERIEN
      CHECK : rs_selfield-tabindex GT 0 AND
              rs_selfield-tabindex LT 99999999999.

*      READ TABLE IT_LIST INDEX rs_selfield-tabindex.
*
*      IF sy-subrc NE 0.
*        MESSAGE s906.            EXIT.
*      ENDIF.

  ENDCASE.
  CLEAR: r_ucomm.

ENDFORM.                    " USER_ALV_COMMAND
