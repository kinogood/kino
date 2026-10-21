************************************************************************
*                                                                      *
* Title         : ZTIR0160                                             *
*                                                                      *
* Description   : [Report]  기간/은행별 L/C 개설현황                   *
*                                                                      *
* Creation Date : 2004/07/23                                           *
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
REPORT  ztir0160
        MESSAGE-ID zmti00
        NO STANDARD PAGE HEADING.
************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis.    "> Globale Type(ALV)
TYPES: int13 TYPE i.
TYPES: chr20(30) TYPE c.
*SELLECT TYPE
TYPES: BEGIN OF ty_selt.
TYPES: reqno LIKE ztivrq04-reqno,
       amdsq LIKE ztivrq04-amdsq,
       opnno LIKE ztivrq04-opnno,
       opnbk LIKE ztivrq04-opnbk,
       ilcty LIKE ztivrq04-ilcty,
       opndt LIKE ztivrq04-opndt,
       usamt LIKE ztivrq04-usamt,
       ucurr LIKE ztivrq04-ucurr,
       reqty LIKE ztivrq04-reqty,
       pagrt LIKE ztivrq04-pagrt.
TYPES: END OF ty_selt.

*월별금액 LIST TYPE
TYPES: BEGIN OF ty_list.
TYPES: opnbk LIKE ztivrq04-opnbk,     "은행.
       ilcty LIKE ztivrq04-ilcty,     "결제조건.
       reqty LIKE ztivrq04-reqty,
       pagrt LIKE ztivrq04-pagrt,
       atext TYPE chr20,
       waers LIKE ztivrq04-waers,     "통화.
       mon01 LIKE ztivrq04-usamt,     "금액.
       mon02 LIKE ztivrq04-usamt,
       mon03 LIKE ztivrq04-usamt,
       mon04 LIKE ztivrq04-usamt,
       mon05 LIKE ztivrq04-usamt,
       mon06 LIKE ztivrq04-usamt,
       mon07 LIKE ztivrq04-usamt,
       mon08 LIKE ztivrq04-usamt,
       mon09 LIKE ztivrq04-usamt,
       mon10 LIKE ztivrq04-usamt,
       mon11 LIKE ztivrq04-usamt,
       mon12 LIKE ztivrq04-usamt,
       usamt LIKE ztivrq04-usamt.
TYPES: END OF ty_list.

*ALV용 출력 TYPE
TYPES: BEGIN OF ty_alvt.
INCLUDE TYPE ty_list.
TYPES: namet LIKE ztstig3-namet,         "은행명
       color TYPE slis_t_specialcol_alv.
TYPES: END OF ty_alvt.

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
TABLES: ztivrq04,
        bkpf,
        dfies,      ">DD Interface: Table Fields for DDIF_FIELDINFO_GET
        ztstig3.
TABLES: icon.
************************************************************************
* Internal Tables  & Structure
************************************************************************
*SELECT용
DATA: it_selt TYPE STANDARD TABLE OF ty_selt,
      gs_selt TYPE ty_selt,
      ls_selt TYPE ty_selt.
DATA: it_popt TYPE STANDARD TABLE OF ty_selt,
      gs_popt TYPE ty_selt,
      ls_popt TYPE ty_selt.
*월별금액용
DATA: it_list TYPE STANDARD TABLE OF ty_list,
      gs_list TYPE ty_list,
      ls_list TYPE ty_list.
*ALV출력용
DATA: it_alvt TYPE STANDARD TABLE OF ty_alvt,
      gs_alvt TYPE ty_alvt,
      ls_alvt TYPE ty_alvt.
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
* User Include Define                                                  *
************************************************************************
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: l_yn    type c.
INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

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
 p_bukrs LIKE ztivrq04-bukrs                        "회사
              OBLIGATORY
                    MEMORY ID buk ,
 p_gjahr LIKE bkpf-gjahr                            "회계연도
             OBLIGATORY
                   MEMORY ID gjr DEFAULT sy-datlo(4).

* s_opndt FOR ztivrq04-opndt.        "일자
SELECTION-SCREEN : SKIP,
                    ULINE.
SELECT-OPTIONS:
 s_ekorg FOR ztivrq04-ekorg,                      "구매그룹
 s_ekgrp FOR ztivrq04-ekgrp,                      "구매조직
 s_opnbk FOR ztivrq04-opnbk,                      "개설은행
 s_reqty FOR ztivrq04-reqty,
 s_ilcty FOR ztivrq04-ilcty,                      "문서종류
* s_docst FOR ztivrq04-docst,                      "문서상태
 s_appct FOR ztivrq04-appct.                      "수입자
SELECTION-SCREEN END OF BLOCK box1.

SELECTION-SCREEN BEGIN OF BLOCK box2 WITH FRAME TITLE text-002.
PARAMETERS: p_int1 RADIOBUTTON GROUP pg1,
            p_int2 RADIOBUTTON GROUP pg1 DEFAULT 'X',
            p_int3 RADIOBUTTON GROUP pg1.
SELECTION-SCREEN END OF BLOCK box2.

SELECTION-SCREEN BEGIN OF BLOCK box3 WITH FRAME TITLE text-003.
PARAMETERS: p_full RADIOBUTTON GROUP pg3 MODIF ID opn ,
            p_list RADIOBUTTON GROUP pg3 MODIF ID opn DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK box3.

*> Report variant
SELECTION-SCREEN: BEGIN OF BLOCK alv WITH FRAME TITLE text-004.
PARAMETERS: alv_def LIKE disvariant-variant. "no-display.
SELECTION-SCREEN: END OF BLOCK alv.


************************************************************************
* INITIALIZATION Event                                                 *
************************************************************************
INITIALIZATION.
  PERFORM  set_initial_data.
  PERFORM  set_alv_init.             ">Initialize ALV variable

************************************************************************
* AT SELECTION-SCREEN Events                                           *
************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR alv_def.
  PERFORM exec_alv_f4.
******************************
AT SELECTION-SCREEN.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM p1102_authorization_check USING p_bukrs.
** JS전선 회사코드 2007/04 KSH --------------------------------------
  PERFORM alv_variant_check.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    CHECK screen-group1 = 'OPN' .
    screen-invisible = '1'.
    MODIFY SCREEN.
  ENDLOOP.

************************************************************************
* START-OF-SELECTION Event                                             *
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
*STATUS
  SET TITLEBAR 'T1000' ."WITH '기간/은행별 L/C개설현황'.
*SET PF-STATUS 'T1000'. "생략 ALV펑션으로 대신함.

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

*년도 금액을 월별로 나누어주기위한 <FS>
  FIELD-SYMBOLS: <fs_mon> ."LIKE ztivrq04-usamt.
  DATA: f_mon(13)  TYPE c.
  DATA: f_pre(11)  VALUE 'GS_LIST-MON'.

**************연도 변수
  RANGES: lr_opndt FOR ztivrq04-opndt OCCURS 1.
  lr_opndt-sign = 'I'.
  lr_opndt-option = 'BT'.
  CONCATENATE p_gjahr '0101' INTO lr_opndt-low .
  CONCATENATE p_gjahr '1231' INTO lr_opndt-high .
  APPEND  lr_opndt.

*ZTIVRQ04 DATA를 IT_SELT에 담음
  SELECT reqno amdsq opnno opnbk ilcty opndt usamt ucurr reqty pagrt
           FROM ztivrq04
           INTO CORRESPONDING FIELDS OF TABLE it_selt
           WHERE bukrs EQ p_bukrs     "회사코드
           AND   opndt IN lr_opndt    "개설날짜
           AND   ekorg IN s_ekorg     "개설그룹
           AND   ekgrp IN s_ekgrp     "개설조직
           AND   opnbk IN s_opnbk     "개설은행
           AND   reqty IN s_reqty              "YSH 2004.0827
           AND   ilcty IN s_ilcty     "문서종류
*           AND   docst IN s_docst     "문서상태
           AND   appct IN s_appct     "수입자
*           AND   reqty  EQ  'LC'
           AND   docst  EQ  'O'.      "완료상태



*IT_SELT의 금액을 월별로 나누어 IT_LIST에 담는다.
  LOOP AT it_selt INTO gs_selt.
    CLEAR gs_list.
    CONCATENATE f_pre gs_selt-opndt+4(2) INTO f_mon.
    ASSIGN (f_mon) TO <fs_mon>.
    MOVE   gs_selt-usamt TO <fs_mon>.       "월별금액
    MOVE : gs_selt-opnbk TO gs_list-opnbk,  "은행코드
           gs_selt-reqty TO gs_list-reqty,  "lc or ..
           gs_selt-ilcty TO gs_list-ilcty,  "결제조건
           gs_selt-pagrt TO gs_list-pagrt,  "ship..
           gs_selt-ucurr TO gs_list-waers,  "통화
           gs_selt-usamt TO gs_list-usamt.  "금액
    COLLECT gs_list INTO it_list.
  ENDLOOP.

*ALV FUCNTION을 이용하기 위해 COLOR필드가 잇는 IT_ALVT로 옮긴다.
  LOOP AT it_list INTO gs_list.
    CLEAR gs_alvt.
    PERFORM alv_text_case.                      "결제조건표시TEXT
    MOVE-CORRESPONDING gs_list TO gs_alvt.
    APPEND gs_alvt TO it_alvt.
  ENDLOOP.

*은행명을 가져오는 로직.
  LOOP AT it_alvt INTO gs_alvt.
    SELECT SINGLE namet
      INTO gs_alvt-namet
      FROM ztstig3
     WHERE epart EQ gs_alvt-opnbk
       AND parti EQ 'B'.
*   천단위로 나누는 로직.
    PERFORM calc_amount_by_unit CHANGING : gs_alvt-mon01,
                                           gs_alvt-mon02,
                                           gs_alvt-mon03,
                                           gs_alvt-mon04,
                                           gs_alvt-mon05,
                                           gs_alvt-mon06,
                                           gs_alvt-mon07,
                                           gs_alvt-mon08,
                                           gs_alvt-mon09,
                                           gs_alvt-mon10,
                                           gs_alvt-mon11,
                                           gs_alvt-mon12,
                                           gs_alvt-usamt.
*    PERFORM int_number_per1000 USING    gs_alvt-waers  gs_alvt-mon01
*                               CHANGING gs_alvt-mont01.
********백만단위로직
*    PERFORM int_number_permillion USING    gs_alvt-waers gs_alvt-mon01
*                                  CHANGING gs_alvt-mon01m.
    MODIFY it_alvt FROM gs_alvt.
  ENDLOOP.

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

  SET TITLEBAR 'T1000' WITH '기간/은행별 L/C OPEN 현황'.

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
  gs_layout-coltab_fieldname  = 'COLOR'.
  gs_layout-group_change_edit = 'X'.
  gs_layout-f2code            = 'DISPLAY'.

* header.
*  gs_layout-no_colhead        = 'X'.

*  GS_LAYOUT-SUBTOTALS_TEXT = 'TOTAL'.
  gs_layout-totals_text = ' TOTAL'.

  REFRESH exit.
  exit-ucomm = '&OL0'. exit-after = 'X'. APPEND exit.
  exit-ucomm = '&OLX'. APPEND exit.
  exit-ucomm = '&OAD'. APPEND exit.

*> event define.
  REFRESH events.
  events-name = slis_ev_top_of_page.
  events-form = 'TOP_OF_PAGE'.
  APPEND events.

*  events-name = 'TOP_OF_LIST'.
*  events-form = 'TOP_OF_LIST'.
*  APPEND events.

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
        t_outtab                 = it_alvt.

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

  SET TITLEBAR 'T1000'.
  SET PF-STATUS 'STANDARD' EXCLUDING extab.

ENDFORM.                    " SET_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  USER_ALV_COMMAND
*&---------------------------------------------------------------------*
*FORM user_alv_command USING   r_ucomm      LIKE sy-ucomm
*                              rs_selfield  TYPE slis_selfield.
**
*  DATA: l_count   TYPE i.
*  DATA: l_subrc   LIKE sy-subrc.
*  DATA: l_tcode   LIKE sy-tcode.
*
*  CASE r_ucomm.
*    WHEN 'ZTIT002' OR 'ZTIT005' OR 'ZTIT006'.
*    WHEN  'DISPLAY'.
*      IF  rs_selfield-tabindex GT 0.
*        FREE : t_fieldcat.  CLEAR: t_fieldcat.
*        mfc 'XMSG'   'MICON'    'ZTISMESSAGE' 'MICON' '' '' ''.
*        mfc 'XMSG'   'MSGTX'    'ZTISMESSAGE' 'MSGTX' '' '' ''.
*        mfc 'XMSG'   'MSGTY'    'ZTISMESSAGE' 'MSGTY' '' '' ''.
**  IF xdocno_show EQ 'X'.
**    mfc 'XMSG'   'REFNO'    'ZTISMESSAGE' 'REFNO' '' '' ''.
**  ENDIF.
**
*        g_title = '점검 메시지'(001).
*        REFRESH: extab.
*
*        APPEND '&NT1'      TO extab.
*        APPEND '&ALL'      TO extab.
*        APPEND '&SAL'      TO extab.
**  APPEND '&IC1'      TO extab.
**  APPEND '&ETA'      TO extab.
**
*        dyname = 'SAPLZ_TI_COMMON_FUNCTIONS'.
*
*        CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
*          EXPORTING
*            i_title                 = g_title
*            i_selection             = 'X'
**      i_allow_no_selection    = 'X'
*            i_zebra                 = 'X'
**      i_checkbox_fieldname    = 'BOX'
**      i_linemark_fieldname    = 'BOX'
**      i_scroll_to_sel_line    = 'X'
*            i_tabname               = 'XMSG'
*            it_fieldcat             = t_fieldcat[]
*            is_private              = gs_private
*            i_screen_start_column   = 2
*            i_screen_start_line     = 4
*            i_screen_end_column     = 100
*            i_screen_end_line       = 20
*            it_excluding            = extab
*            i_callback_program      = dyname
*            i_callback_user_command = 'USER_POPUP_COMMAND'
*          IMPORTING
*            es_selfield             = gs_selfield
*            e_exit                  = g_exit
*          TABLES
*            t_outtab                =
*          EXCEPTIONS
*            program_error           = 1
*            OTHERS                  = 2.
*        IF sy-subrc <> 0.
*          MESSAGE i000(0k) WITH sy-subrc.
*        ENDIF.
*
*      ELSE.
*        MESSAGE s903.
*      ENDIF.
*
*  ENDCASE.
*  CLEAR: r_ucomm.
*
*ENDFORM.                    " USER_ALV_COMMAND
*&---------------------------------------------------------------------*
*&      Form  set_fieldcat_build
*&---------------------------------------------------------------------*
FORM set_fieldcat_build .

  PERFORM 3010_fill_field_category USING :

       'S' 'SELTEXT_M'   '금융기관',
       ' ' 'TABNAME'     'IT_ALVT',
       ' ' 'FIELDNAME'    'NAMET',                 "은행명
       'E' 'OUTPUTLEN'   '10',

*       'S' 'SELTEXT_M'   '수입요청종류',
*       ' ' 'TABNAME'     'IT_ALVT',
*       ' ' 'FIELDNAME'   'REQTY',                 "결제조건
*       'E' 'OUTPUTLEN'   '12',
*
*       'S' 'SELTEXT_M'   '결제조건',
*       ' ' 'TABNAME'     'IT_ALVT',
*       ' ' 'FIELDNAME'   'ILCTY',                 "결제조건
*       'E' 'OUTPUTLEN'   '8',
*
*       'S' 'SELTEXT_M'   '신용공여주체',
*       ' ' 'TABNAME'     'IT_ALVT',
*       ' ' 'FIELDNAME'   'PAGRT',                 "결제조건
*       'E' 'OUTPUTLEN'    '12',

       'S' 'SELTEXT_M'   '결제조건',
       ' ' 'TABNAME'     'IT_ALVT',
       ' ' 'FIELDNAME'   'ATEXT',                 "결제조건text
       'E' 'OUTPUTLEN'    '30',

       'S' 'TABNAME'     'IT_ALVT',
       ' ' 'SELTEXT_M'   '1월',
       ' ' 'CTABNAME'    'IT_ALVT',
       ' ' 'CFIELDNAME'  'WAERS',
       ' ' 'FIELDNAME'    'MON01',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_ALVT',
       ' ' 'SELTEXT_M'   '2월',
       ' ' 'CTABNAME'    'IT_ALVT',
       ' ' 'CFIELDNAME'  'WAERS',
       ' ' 'FIELDNAME'    'MON02',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_ALVT',
       ' ' 'SELTEXT_M'   '3월',
       ' ' 'CTABNAME'    'IT_ALVT',
       ' ' 'CFIELDNAME'  'WAERS',
       ' ' 'FIELDNAME'    'MON03',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_ALVT',
       ' ' 'SELTEXT_M'   '4월',
       ' ' 'CTABNAME'    'IT_ALVT',
       ' ' 'CFIELDNAME'  'WAERS',
       ' ' 'FIELDNAME'    'MON04',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_ALVT',
       ' ' 'SELTEXT_M'   '5월',
       ' ' 'CTABNAME'    'IT_ALVT',
       ' ' 'CFIELDNAME'  'WAERS',
       ' ' 'FIELDNAME'    'MON05',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_ALVT',
       ' ' 'SELTEXT_M'   '6월',
       ' ' 'CTABNAME'    'IT_ALVT',
       ' ' 'CFIELDNAME'  'WAERS',
       ' ' 'FIELDNAME'    'MON06',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_ALVT',
       ' ' 'SELTEXT_M'   '7월',
       ' ' 'CTABNAME'    'IT_ALVT',
       ' ' 'CFIELDNAME'  'WAERS',
       ' ' 'FIELDNAME'    'MON07',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_ALVT',
       ' ' 'SELTEXT_M'   '8월',
       ' ' 'CTABNAME'    'IT_ALVT',
       ' ' 'CFIELDNAME'  'WAERS',
       ' ' 'FIELDNAME'    'MON08',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_ALVT',
       ' ' 'SELTEXT_M'   '9월',
       ' ' 'CTABNAME'    'IT_ALVT',
       ' ' 'CFIELDNAME'  'WAERS',
       ' ' 'FIELDNAME'    'MON09',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_ALVT',
       ' ' 'SELTEXT_M'   '10월',
       ' ' 'CTABNAME'    'IT_ALVT',
       ' ' 'CFIELDNAME'  'WAERS',
       ' ' 'FIELDNAME'    'MON10',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_ALVT',
       ' ' 'SELTEXT_M'   '11월',
       ' ' 'CTABNAME'    'IT_ALVT',
       ' ' 'CFIELDNAME'  'WAERS',
       ' ' 'FIELDNAME'    'MON11',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_ALVT',
       ' ' 'SELTEXT_M'   '12월',
       ' ' 'CTABNAME'    'IT_ALVT',
       ' ' 'CFIELDNAME'  'WAERS',
       ' ' 'FIELDNAME'    'MON12',
       'E' 'OUTPUTLEN'   '15',

       'S' 'TABNAME'     'IT_ALVT',
       ' ' 'SELTEXT_M'   '합계',
       ' ' 'CTABNAME'    'IT_ALVT',
       ' ' 'CFIELDNAME'  'WAERS',
       ' ' 'FIELDNAME'    'USAMT',
       'E' 'OUTPUTLEN'   '15'.
*****************************************천단위
*       'S' 'TABNAME'     'IT_ALVT',
*       ' ' 'SELTEXT_M'   '1월',
*       ' ' 'FIELDNAME'    'MONT01',
*       'E' 'OUTPUTLEN'   '15',
*
********************************************백만단위
*       'S' 'TABNAME'     'IT_ALVT',
*       ' ' 'SELTEXT_M'   '1월',
*       ' ' 'FIELDNAME'    'MON01M',
*       'E' 'OUTPUTLEN'   '15',
*  LOOP AT it_fieldcat INTO gs_fieldcat.
*
*    CASE gs_fieldcat-fieldname.
*      WHEN 'MON01' OR 'MON02' OR 'MON03' OR                 "1단위
*           'MON04' OR 'MON05' OR 'MON06' OR
*           'MON07' OR 'MON08' OR 'MON09' OR
*           'MON10' OR 'MON11' OR 'MON12' OR
*           'USAMT'.
*        IF p_int1 EQ 'X'.
*          gs_fieldcat-no_out = ' '.
*        ELSE.
*          gs_fieldcat-no_out = 'X'.
*        ENDIF.
*
*      WHEN OTHERS.
*    ENDCASE.
*
*    MODIFY it_fieldcat FROM gs_fieldcat.
*
*  ENDLOOP.

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
*       text
*----------------------------------------------------------------------*
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
*&      Form  int_number_per1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM int_number_per1000     USING    p_waers
                                     p_amtt
                            CHANGING p_amti.
* 단위를 EXTERNAL로 변환뒤 1000을 나누고 INT필드에 넣어줌.(자동 반올림).
  CALL FUNCTION 'Z_TI_INT_NUMBER_PER1000'
    EXPORTING
      w_waers = p_waers
      w_opamt = p_amtt
    IMPORTING
      w_int   = p_amti.

ENDFORM.                    " int_number_per1000
*&---------------------------------------------------------------------*
*&      Form  INT_NUMBER_PERMILLION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM int_number_permillion  USING    p_waersm
                                     p_amttm
                            CHANGING p_amtim.
* 단위를 EXTERNAL로 변환뒤 1,000,000을 나누고 INT필드에 넣어줌.(자동 반
**올림).
  CALL FUNCTION 'Z_TI_INT_NUMBER_PER_MILLION'
    EXPORTING
      w_waers = p_waersm
      w_opamt = p_amttm
    IMPORTING
      w_int   = p_amtim.

ENDFORM.                    " INT_NUMBER_PERMILLION
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM top_of_page.

  DATA: l_mode TYPE i.
  DATA: header TYPE slis_listheader OCCURS 0 WITH HEADER LINE.

  REFRESH header.
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
** JS전선 회사코드 2007/04 KSH --------------------------------------

  WRITE: '기간/은행별 L/C 개설 현황'.
*  WRITE: sy-uline.
  SKIP.
** JS전선 회사코드 2007/04 KSH --------------------------------------
  WRITE: '회사코드 :  ', header-info.
** JS전선 회사코드 2007/04 KSH --------------------------------------
  WRITE: /'출력일자 :  ', sy-datlo.
  IF p_int2 EQ 'X'.
    WRITE AT / '단위     :   천미불'. "RIGHT-JUSTIFIED.
  ELSE.
    IF p_int1 EQ 'X'.
      WRITE AT / '단위     :   미불' ."RIGHT-JUSTIFIED.
    ELSE.
      WRITE AT / '단위     :   백만미불'." RIGHT-JUSTIFIED.
    ENDIF.
  ENDIF.

ENDFORM.    ">TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  calc_amount_by_unit
*&---------------------------------------------------------------------*
FORM calc_amount_by_unit  CHANGING p_amount.

  CASE 'X'.
    WHEN p_int1.
      p_amount = p_amount.
    WHEN p_int2.
      p_amount = p_amount / 1000.
    WHEN p_int3.
      p_amount = p_amount / 1000000.
  ENDCASE.

ENDFORM.                    " calc_amount_by_unit
*&---------------------------------------------------------------------*
*&      Form  alv_text_case
*&---------------------------------------------------------------------*
FORM alv_text_case .

  CASE gs_list-reqty.
    WHEN 'LC'.
      IF gs_list-ilcty = 'A'.
        gs_list-atext = 'At Sight'.
      ELSE.
        IF gs_list-pagrt = '2AA'.
          gs_list-atext = 'Banker''s Usance'.
        ELSEIF gs_list-pagrt = '2AB' .
          gs_list-atext = 'Domestic Usance'.
        ELSE.
          gs_list-atext = 'Shipper''s Usance'.
        ENDIF.
      ENDIF.

    WHEN 'TT'.
      gs_list-atext = '전신환송금'.
    WHEN 'LO'.
      gs_list-atext = '내국신용장'.
    WHEN 'PU'.
      gs_list-atext = '구매확인서'.
    WHEN 'DA'.
      gs_list-atext = 'Documents against Acceptance'.
    WHEN 'DP'.
      gs_list-atext = 'Documents against Payment'.
    WHEN 'ZZ'.
      gs_list-atext = 'No-draft Import'.
  ENDCASE.

ENDFORM.                    " alv_text_case

*translate
*ranges
*field-symbols
