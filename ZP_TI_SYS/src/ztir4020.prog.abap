************************************************************************
*                                                                      *
* Title         : ZTIR4020                                             *
*                                                                      *
* Description   : [Report]  제세(관세) 납부 현황                       *
*                                                                      *
* Creation Date : 2004/10/26                                           *
*                                                                      *
* Author        : Soo Ho, Yoon                                         *
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
REPORT  ztir4020
        MESSAGE-ID zmti00
        NO STANDARD PAGE HEADING.
************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis.    "> Globale Type(ALV)

TYPES: BEGIN OF ty_selt.
TYPES: cdrdt LIKE ztitcck-cdrdt,     "신고수리일
       payda LIKE ztitcck-payda,     "납부예정일
       ebeln LIKE ztitblp-ebeln,     "P/O No
       blcnt LIKE ztitblk-blcnt,     "B/L 차수.
       iccno LIKE ztitcck-iccno,     "통관관리번
       iccsq LIKE ztitcck-iccsq,     "차수
       cdcno LIKE ztitcck-cdcno,     "신고번호
       cdcor LIKE ztitcck-cdcor,     "세관
       state LIKE ztitcck-state,     "관세사
       werks LIKE ztitblp-werks,     "플랜트
       bupla LIKE t001w-j_1bbranch,  "사업장
       cdutx LIKE ztitcck-cdutx,     "관세
       csptx LIKE ztitcck-csptx,     "특소세
       caltx LIKE ztitcck-caltx,     "주세
       ctrtx LIKE ztitcck-ctrtx,     "교통세
       cintx LIKE ztitcck-cintx,     "교육세
       cagtx LIKE ztitcck-cagtx,     "농특세
       clttx LIKE ztitcck-clttx,     "신고지연가산세
       cadtx LIKE ztitcck-cadtx,     "부가세
       sumtx LIKE ztitcck-ctotl,     "합계
       otrtx LIKE ztitcck-ctotl,     "관세외 합
       ctsak LIKE ztitcck-ctsak,     "부가세과표
       iblno LIKE ztitblk-iblno,     "B/L관리번호
       blnum LIKE ztitblk-blnum,     "B/L번호.
       carty LIKE ztitcck-carty,     "징수형태
       expcd LIKE ztitblp-werks,     "관세비용코드
       ccuakc LIKE ztitcck-ccuakc,   "통화.
       sdrlt LIKE ztitblk-sdrlt,     "선적서류송부처
       belnr LIKE ztivcs00-belnr,    "A/P 전표번호
       cartyt(30) TYPE c.            "징수형태text
TYPES: END OF ty_selt.

* LIST TYPE
TYPES: BEGIN OF ty_list.
INCLUDE TYPE ty_selt.
TYPES:  color TYPE slis_t_specialcol_alv.
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
        ztivcs00,
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
       cdcor LIKE ztitcck-cdcor,     "세관
       state LIKE ztitcck-state,     "관세사
       bupla LIKE t001w-j_1bbranch,  "사업장
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
PARAMETERS:
 p_bukrs LIKE ztetcck-bukrs                        "회사
              OBLIGATORY
                    MEMORY ID buk ,
 p_expcd LIKE ztivcs00-expcd NO-DISPLAY.         "수입비용코드

SELECT-OPTIONS:

 s_payda FOR ztitcck-payda,                      "납부예정일
 s_cdrdt FOR ztitcck-cdrdt,                      "수입신고수리일
 s_state FOR ztitcck-state,                      "관세사
 s_cdcor FOR ztitcck-cdcor,                      "세관
 s_werks FOR ztitblp-werks,                      "플랜트
 s_sdrlt FOR ztitblk-sdrlt.                      "선적서류 송부처
* s_ FOR ztitcck-,                      "보세구역

SELECTION-SCREEN END OF BLOCK box1.

SELECTION-SCREEN BEGIN OF BLOCK box2 WITH FRAME TITLE text-002.
PARAMETERS: p_int1 RADIOBUTTON GROUP pg1 DEFAULT 'X',
            p_int2 RADIOBUTTON GROUP pg1 .
*            p_int3 RADIOBUTTON GROUP pg1.
SELECTION-SCREEN END OF BLOCK box2.

SELECTION-SCREEN BEGIN OF BLOCK box3 WITH FRAME TITLE text-003.
PARAMETERS: p_full RADIOBUTTON GROUP pg3 MODIF ID opn DEFAULT 'X',
            p_list RADIOBUTTON GROUP pg3 MODIF ID opn .
SELECTION-SCREEN END OF BLOCK box3.

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
DATA: l_yn    type c.
  PERFORM p1102_authorization_check USING p_bukrs.
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

  RANGES : lr_carty FOR ztitcck-carty OCCURS 2.

  CLEAR: lr_carty, g_line, it_subtotal.

  REFRESH: it_subtotal.

  lr_carty-sign   = 'I'.
  lr_carty-option = 'EQ'.
  CASE 'X'.
*>사후납부
    WHEN p_int1.
      lr_carty-low    = '13'.   APPEND lr_carty.
      lr_carty-low    = '33'.   APPEND lr_carty.
*>월별납부
    WHEN p_int2.
      lr_carty-low    = '43'.   APPEND lr_carty.
  ENDCASE.

 SELECT a~cdrdt a~iccno a~iccsq a~cdcno a~cdcor a~state a~cdutx a~csptx
        a~caltx a~ctrtx a~cintx a~cagtx a~clttx a~cadtx a~ctsak a~carty
        a~payda b~iblno b~sdrlt b~blnum b~blcnt a~ccuakc
   INTO CORRESPONDING FIELDS OF TABLE it_selt
   FROM ztitcck AS a JOIN ztitblk AS b
     ON a~iblno EQ b~iblno
  WHERE a~bukrs EQ p_bukrs
    AND a~payda IN s_payda
    AND a~cdrdt IN s_cdrdt
    AND a~state IN s_state
    AND a~cdcor IN s_cdcor
    AND b~sdrlt IN s_sdrlt
    AND a~carty IN lr_carty.

  IF sy-subrc NE 0.
    MESSAGE s902.  EXIT.
  ENDIF.

  LOOP AT it_selt INTO gs_selt.
*>사후납부
    CLEAR gs_list.
    PERFORM get_data_list_tab.
    MOVE-CORRESPONDING : gs_selt TO gs_list.
*>사후정산제외
    IF gs_list-carty EQ '33'.
      CONTINUE.
    ENDIF.

*domain_value_text
    PERFORM get_domain_value_text(ztir0000)
                                   USING  'ZTICARTY' "도메인명
                                   gs_list-carty      "필드명
                                   gs_list-cartyt.    "텍스트명
    APPEND gs_list TO it_list.

    CLEAR: it_subtotal.
    MOVE-CORRESPONDING : gs_selt TO it_subtotal.
    it_subtotal-count = 1.
    COLLECT it_subtotal.


  ENDLOOP.



  DESCRIBE TABLE it_list LINES g_line.
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

  IF p_int1 EQ 'X'.
    SET TITLEBAR 'T1100' WITH '사후납부'.
  ELSE.
    SET TITLEBAR 'T1100' WITH '월별납부'.
  ENDIF.

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
        t_outtab                 = it_list.

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

  PERFORM 3010_fill_field_category USING :

*       'S' 'SELTEXT_M'   '신고 수리일',
       'S' 'REF_TABNAME'   'ZTITCCK',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'    'CDRDT',
       'E' 'OUTPUTLEN'   '10',

*       'S' 'SELTEXT_M'   '신고 수리일',
       'S' 'REF_TABNAME'   'ZTITCCK',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'    'PAYDA',
       'E' 'OUTPUTLEN'   '10',

*       'S' 'SELTEXT_M'   'P/O No',
       'S' 'REF_TABNAME'   'ZTITBLP',
       ' ' 'TABNAME'     'IT_LISTT',
       ' ' 'FIELDNAME'   'EBELN',
       'E' 'OUTPUTLEN'   '10',

       'S' 'SELTEXT_M'   '차수',
*       ' S' 'REF_TABNAME'   'ZTITCCK',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'BLCNT',
       'E' 'OUTPUTLEN'   '4',

*       'S' 'SELTEXT_M'   '신고번호',
       ' S' 'REF_TABNAME'   'ZTITCCK',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'CDCNO',
       'E' 'OUTPUTLEN'    '20',

*>징수형태
       'S' 'SELTEXT_M'   '징수코드',
*       ' S' 'REF_TABNAME'   'ZTITCCK',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'CARTY',
       ' ' 'JUST'        'C',
       'E' 'OUTPUTLEN'    '8',

*>징수형태text
       'S' 'SELTEXT_M'   '징수형태',
*       ' S' 'REF_TABNAME'   'ZTITCCK',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'CARTYT',
       'E' 'OUTPUTLEN'    '27',


       'S' 'TABNAME'     'IT_LIST',
       ' ' 'SELTEXT_M'   '관세외',
       ' ' 'FIELDNAME'    'OTRTX',
       ' ' 'CFIELDNAME'   'CCUAKC',
       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_LISTT',
       ' ' 'SELTEXT_M'   '부가세',
       ' ' 'FIELDNAME'    'CADTX',
       ' ' 'CFIELDNAME'   'CCUAKC',
       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_LIST',
       ' ' 'SELTEXT_M'   '합계',
       ' ' 'FIELDNAME'    'SUMTX',
       ' ' 'CFIELDNAME'   'CCUAKC',
       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_LIST',
       ' ' 'SELTEXT_M'   '부가세과표',
       ' ' 'FIELDNAME'    'CTSAK',
       ' ' 'CFIELDNAME'   'CCUAKC',
       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_LIST',
       ' ' 'SELTEXT_M'   'A/P 전표번호',
       ' ' 'FIELDNAME'    'BELNR',
       'E' 'OUTPUTLEN'   '12',

       'S' 'SELTEXT_M'   '사업장',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'BUPLA',
       ' ' 'NO_OUT'       'X',
       'E' 'OUTPUTLEN'    '6',

       'S' 'TABNAME'     'IT_LIST',
       ' ' 'SELTEXT_M'   '관세사',
       ' ' 'FIELDNAME'    'STATE',
       ' ' 'NO_OUT'       'X',
       'E' 'OUTPUTLEN'   '12',

       'S' 'TABNAME'     'IT_LIST',
       ' ' 'SELTEXT_M'   '세관',
       ' ' 'FIELDNAME'    'CDCOR',
       ' ' 'NO_OUT'       'X',
       'E' 'OUTPUTLEN'   '5'.
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

  REFRESH: it_sort.


  CLEAR  st_sort.
  st_sort-spos = '01'.
  st_sort-fieldname = 'BUPLA'.
  st_sort-tabname   = 'IT_LIST'.
*  st_sort-up        = 'X'.
*  ST_SORT-GROUP     = 'X'.
  st_sort-subtot    = 'X'.
*  ST_SORT-EXPA      = 'X'.
  APPEND st_sort TO it_sort.

  CLEAR  st_sort.
  st_sort-spos = '02'.
  st_sort-fieldname = 'CDCOR'.
  st_sort-tabname   = 'IT_LIST'.
*  st_sort-up        = 'X'.
*  ST_SORT-GROUP     = 'X'.
  st_sort-subtot    = 'X'.
*  ST_SORT-EXPA      = 'X'.
  APPEND st_sort TO it_sort.

  CLEAR  st_sort.
  st_sort-spos = '03'.
  st_sort-fieldname = 'STATE'.
  st_sort-tabname   = 'IT_LIST'.
*  st_sort-up        = 'X'.
*  ST_SORT-GROUP     = 'X'.
  st_sort-subtot    = 'X'.
*  ST_SORT-EXPA      = 'X'.
  APPEND st_sort TO it_sort.


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

  REFRESH header.
  header-typ = 'H'.
  header-info = '제세(관세) 납부 현황'.
  IF p_int1 EQ 'X'.
    CONCATENATE '사후납부' header-info INTO header-info
                                       SEPARATED BY space.
  ELSE.
    CONCATENATE '월별납부' header-info INTO header-info
                                       SEPARATED BY space.
  ENDIF.
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

*> A/P전표
  SELECT belnr INTO gs_selt-belnr
    FROM ztivcs00 UP TO 1 ROWS
   WHERE refno EQ gs_selt-iccno
     AND amdsq EQ gs_selt-iccsq
     AND expgr EQ 'C'
     AND expcd EQ p_expcd.
  ENDSELECT.

*> P/O No
  SELECT ebeln werks
    INTO CORRESPONDING FIELDS OF gs_selt
    FROM ztitblp UP TO 1 ROWS
   WHERE iblno EQ gs_selt-iblno.
  ENDSELECT.

*> 사업장
  SELECT j_1bbranch
    INTO gs_selt-bupla
    FROM t001w
   WHERE werks EQ gs_selt-werks.
  ENDSELECT.

*>관세외
  gs_selt-otrtx =  gs_selt-cdutx +    "관세
                   gs_selt-csptx +    "특소세
                   gs_selt-caltx +    "주세
                   gs_selt-ctrtx +    "교통세
                   gs_selt-cintx +    "교육세
                   gs_selt-clttx +    "신고지연가산세
                   gs_selt-cagtx .    "농특세
*>합계
  gs_selt-sumtx = gs_selt-otrtx +
                  gs_selt-cadtx .     "부가세

ENDFORM.                    " GET_DATA_LIST_TAB
*&---------------------------------------------------------------------*
*&      Form  input_field_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM input_field_check .

  DATA: l_cstcl TYPE zticstcl.

* Company code
  SELECT SINGLE *
    FROM t001
   WHERE bukrs EQ p_bukrs.
  IF sy-subrc <> 0.
    PERFORM get_ftext(rddfie00) USING 'T001' 'BUKRS' sy-langu
                                CHANGING dfies g_subrc.
    SET CURSOR FIELD 'P_BUKRS'.
    MESSAGE e348(m7) WITH dfies-scrtext_m.
  ENDIF.

  CASE 'X'.
    WHEN p_int1.   l_cstcl = 'C'.  ">사후납부.
    WHEN p_int2.   l_cstcl = 'D'.  ">월별납부.
  ENDCASE.

  SELECT expcd
    INTO p_expcd
    FROM ztitig06 UP TO 1 ROWS
   WHERE bukrs  EQ  p_bukrs
     AND expgr  EQ  'C'
     AND cstcl  EQ  l_cstcl.
  ENDSELECT.
  IF sy-subrc <> 0.
    MESSAGE e878 WITH p_bukrs.
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
    WHEN 'STATE'.  ">관세사.
      SELECT SINGLE namet
        INTO my_subtotal-display_text_for_subtotal
        FROM ztstig3
       WHERE parti  EQ  'H'
         AND epart  EQ  my_listhead-state.
      ASSIGN my_listhead-state TO <l_fs>.
      MOVE-CORRESPONDING my_listhead TO t_alv_list.
    WHEN 'CDCOR'.  ">세관.
      PERFORM get_domain_value_text
                  USING
                     'ZTSCDCOR'
                     my_listhead-cdcor
                     l_text40.
      my_subtotal-display_text_for_subtotal = l_text40.
      ASSIGN my_listhead-cdcor TO <l_fs>.
    WHEN 'BUPLA'.  ">사업장.
      SELECT SINGLE name
        INTO my_subtotal-display_text_for_subtotal
        FROM j_1bbrancht
       WHERE bukrs    EQ p_bukrs
         AND branch   EQ my_listhead-bupla
         AND language EQ sy-langu.
      ASSIGN my_listhead-bupla TO <l_fs>.
    WHEN OTHERS.
      EXIT.
  ENDCASE.

  READ TABLE it_subtotal WITH KEY cdcor  = t_alv_list-cdcor
                                  STATE  = t_alv_list-state
                                  bupla  = t_alv_list-bupla.

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
