************************************************************************
*                                                                      *
* Title         : ZTIR3110                                             *
*                                                                      *
* Description   : [Report]  수입LC 자금집행보고서                      *
*                                                                      *
* Creation Date : 2004/11/28                                           *
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
REPORT  ZTIR3110
        MESSAGE-ID zmti00
        NO STANDARD PAGE HEADING.

************************************************************************
* User Include Define                                                  *
************************************************************************
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: l_yn    type c.
INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis.    "> Globale Type(ALV)

TYPES: BEGIN OF ty_selt.
TYPES: bukrs       TYPE ztitivk-bukrs,
       OPNBK       type ZTIVRQ00-OPNBK,     ">개설은행
       OPNNO       type ZTIVRQ00-opnno,     ">수입개설번호
       reqty       TYPE ztitrqk-reqty,      ">수입요청 종류
       REQNO       type ZTIVRQ00-reqno,     ">수입요청 관리번호
       name1       TYPE lfa1-name1,         ">은행파트너명
       waers       TYPE ZTIVIV00-waers,      ">통화키
       ivamp       TYPE ZTIVIV00-ivamp,      ">문서통화 - 총처리금액
       hwaer       TYPE ztitrqs-hwaer,      ">현지통화
       dmbtr       TYPE ztitrqs-dmbtr,      ">현지통화금액
       hdmbt       TYPE ztitrqs-dmbtr,      ">비용금
       admbt       TYPE ztitrqs-dmbtr,      ">tr
       bdmbt       TYPE ztitrqs-dmbtr,      ">tr
       cdmbt       TYPE ztitrqs-dmbtr,      ">tr
       ddmbt       TYPE c,                  ">tr
       belnr       TYPE ztitivk-belnr,      ">송장문서의 문서번호
       netdt       TYPE ztitivk-netdt,      ">순액지급 만기일
       reqtyt(65)  TYPE c,
       gjahr       TYPE ztitivk-gjahr,      ">회계연도
       ilcty       type c,                  ">신용장종류
       anbty       type c,                  ">사전/사후 구분자
       ppaid       type c.                  ">선급금 여부
*       ivono       TYPE ztitivk-lifnr,      ">송장 관리번호
*       lifnr       TYPE ztitivk-lifnr,      ">다른 송장발행처
*       opnbk       TYPE ztitivk-opnbk,      ">개설은행 구매처코드

*       ebeln       TYPE ztitivk-ebeln,      ">구매오더
*       blcnt       TYPE ztitblk-blcnt,      ">선적차수
*       opnno       TYPE ztitrqs-opnno,      ">수입개설번호


*       hwaer       TYPE ztitrqs-hwaer,      ">현지통화
*       dmbtr       TYPE ztitrqs-dmbtr,      ">현지통화금액
*       waers       TYPE ztitivk-waers,      ">통화키
*       ivamp       TYPE ztitivk-ivamp,      ">문서통화 - 총처리금액
*       kursf       TYPE ztitivk-kursf,      ">환율
*
*       iblno       TYPE ztitivp-iblno,      ">B/L 관리번호
*       reqno       TYPE ztitivp-reqno,      ">수입요청 관리번호
*       gjahr       TYPE ztitivk-gjahr,      ">회계연도
*       budat       TYPE ztitivk-budat,      ">전표의 전기일
*       bldat       TYPE ztitivk-bldat,      ">전표에서 송장일
*       wwert       TYPE ztitivk-wwert.      ">환산일
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
TABLES: ztitrqs,
        ztitrqk,
        ztitblk,
        ztitivk,
        ztitivp,
        ztstig3,
        ZTIVRQ00,
        ZTIVIV00,
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
       opnbk LIKE ztitivk-opnbk,        ">은행코드
       netdt LIKE ztitivk-netdt,        ">만기일
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
       field_name1(20),
       l_iblno,
       l_ebeln,
       l_reqno.

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK box1 WITH FRAME TITLE text-oo1.
PARAMETERS:
 p_bukrs LIKE ztitivk-bukrs                        "회사
              OBLIGATORY
                    MEMORY ID buk.
SELECT-OPTIONS:
 s_opnbk FOR ztitivk-opnbk,                      "개설은행
 s_netdt FOR ztitivk-netdt.                      "만기일
SELECTION-SCREEN END OF BLOCK box1.

SELECTION-SCREEN BEGIN OF BLOCK box3 WITH FRAME TITLE text-003.
PARAMETERS: p_full RADIOBUTTON GROUP pg3 MODIF ID opn DEFAULT 'X',
            p_list RADIOBUTTON GROUP pg3 MODIF ID opn .
SELECTION-SCREEN END OF BLOCK box3.

*> Report variant
SELECTION-SCREEN: BEGIN OF BLOCK alv WITH FRAME TITLE text-004.
PARAMETERS: alv_def LIKE disvariant-variant." NO-DISPLAY.
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
AT SELECTION-SCREEN ON VALUE-REQUEST FOR alv_def.
  PERFORM exec_alv_f4.

AT SELECTION-SCREEN.
  PERFORM input_field_check.
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
  PERFORM set_fieldcat_build.       ">Set ALV field category
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

*  DATA:

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_selt
    FROM ZTIVRQ00 as q inner join ZTIVIV00 as v
     on  q~mandt   eq  v~mandt
     and q~reqno   eq  v~reqno
     and q~reqit   eq  v~reqit
     and q~ebeln   eq  v~ebeln
     and q~ebelp   eq  v~ebelp
   WHERE q~bukrs EQ p_bukrs
     AND q~opnbk IN s_opnbk
     AND v~netdt IN s_netdt
     AND v~livst EQ 'P'.

  IF sy-subrc NE 0.
    MESSAGE s902.  EXIT.
  ENDIF.

  LOOP AT it_selt INTO gs_selt.
*>수입요청 설명
  case gs_selt-reqty.
    when 'LC'.
       if gs_selt-ilcty eq 'A'.
          gs_selt-reqtyt = '자기자금결재'.
       elseif gs_selt-ilcty eq 'U'.
          gs_selt-reqtyt = 'USANCE 상환'.
       endif.
    when 'TT'.
       if gs_selt-anbty eq 'A' .
         gs_selt-reqtyt = '사후송금'.
       elseif gs_selt-anbty eq 'B'.
         if gs_selt-ppaid eq 'X'.
           gs_selt-reqtyt = '선급금 송금'.
         elseif gs_selt-ppaid eq 'N'.
           gs_selt-reqtyt = '사전송금'.
         endif.
       endif.
    when 'DA' or 'DP'.
       gs_selt-reqtyt = '결재'.
    when 'LO'.
       gs_selt-reqtyt = '내국신용장 결재'.
    when 'PU'.
       gs_selt-reqtyt = '구매확인서 결재'.
    when 'ZZ'.
       gs_selt-reqtyt = '무환 거래'.
  endcase.

*>은행파트너명
    SELECT SINGLE namet
       INTO gs_selt-name1
       FROM ztstig3
       WHERE parti EQ 'B'
         AND epart EQ gs_selt-opnbk.
*endselet.

*>비용
     select single sum( dmbtr )
        into gs_selt-hdmbt
        from ztivcs00
        where refno eq gs_selt-reqno
         and  expgr eq 'L'.



    MOVE-CORRESPONDING : gs_selt TO gs_list.
    APPEND gs_list TO it_list.
    CLEAR : gs_list.                  "> l_iblno, l_ebeln, l_reqno.

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



*은행코드
       'S' 'REF_TABNAME'   'ZTIVRQ00',
       ' ' 'TABNAME'     'IT_LIST',
       ' '  'NO_OUT'     'X',
       ' ' 'FIELDNAME'   'OPNBK',
       'E' 'OUTPUTLEN'   '10',
**만기일
*       'S' 'REF_TABNAME'   'ZTITIVK',
*       ' ' 'TABNAME'     'IT_LIST',
**       ' ' 'SELTEXT_M'   '세관',
*       ' ' 'FIELDNAME'    'NETDT',
**       ' ' 'NO_OUT'       'X',
*       'E' 'OUTPUTLEN'   '10',

*은행명

       'S' 'REF_TABNAME'   'LFA1',
       ' ' 'SELTEXT_M'   '은행명',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'NAME1',
       'E' 'OUTPUTLEN'   '15',

*수입요청종류 텍스트
       'S' 'TABNAME'     'IT_LIST',
       ' ' 'SELTEXT_M'   '수입요청종류',
       ' ' 'FIELDNAME'    'REQTYT',
*       ' ' 'CFIELDNAME'   'CCUAKC',
*       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'   '30',

*수입개설번호
       'S' 'REF_TABNAME'   'ZTITRQS',
       ' ' 'TABNAME'     'IT_LIST',
*       ' ' 'SELTEXT_M'   '부가세',
       ' ' 'FIELDNAME'    'OPNNO',
*       ' ' 'CFIELDNAME'   'CCUAKC',
*       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'   '20',
*


*수입요청 종류코드
       'S' 'REF_TABNAME'   'ZTITRQK',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'SELTEXT_M'   '구분',
       ' ' 'FIELDNAME'    'REQTY',
*       ' ' 'CFIELDNAME'   'CCUAKC',
*       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'   '4',


*외화통화
       'S' 'TABNAME'     'IT_LIST',
       ' ' 'REF_TABNAME'   'ZTIVIV00',
       ' ' 'SELTEXT_M'   '통화',
       ' ' 'FIELDNAME'    'WAERS',
       'E' 'OUTPUTLEN'   '3',
*외화금액
       'S' 'SELTEXT_M'   '외화금액',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'IVAMP',
       ' ' 'CFIELDNAME'   'WAERS',
       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'    '15',

*원화통화
       'S' 'TABNAME'     'IT_LIST',
       ' ' 'SELTEXT_M'   '통화',
       ' ' 'FIELDNAME'    'HWAER',
       'E' 'OUTPUTLEN'   '3',
*원화금액
       'S' 'SELTEXT_M'   '원화금액',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'DMBTR',
       ' ' 'CFIELDNAME'   'HWAER',
       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'    '15',

*전표
       'S' 'SELTEXT_M'   '회계전표',
       ' ' 'REF_TABNAME'   'ZTITIVK',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'BELNR',
       'E' 'OUTPUTLEN'    '10',

*비용금액
       'S' 'SELTEXT_M'   '지출금액',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'CDMBT',
       ' ' 'CFIELDNAME'   'HWAER',
       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'    '15',

*비용금액
       'S' 'SELTEXT_M'   '비  용',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'HDMBT',
       ' ' 'CFIELDNAME'   'HWAER',
       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'    '15',

*대체입금
       'S' 'SELTEXT_M'   '대체입금',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'ADMBT',
       ' ' 'CFIELDNAME'   'HWAER',
       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'    '15',

*차  액
       'S' 'SELTEXT_M'   '차  액',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'BDMBT',
       ' ' 'CFIELDNAME'   'HWAER',
       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'    '15',
*비  고
       'S' 'SELTEXT_M'   '비  고',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'DDMBT',
*       ' ' 'CFIELDNAME'   'HWAER',
       ' ' 'DO_SUM'        'X',

       'E' 'OUTPUTLEN'    '15'.

**환율
**       'S' 'REF_TABNAME'   'ZTITIVK',
**       ' ' 'TABNAME'     'IT_LIST',
**       ' ' 'SELTEXT_M'   '관세사',
**       ' ' 'FIELDNAME'    'KURSF',
**       ' ' 'NO_OUT'       'X',
**       'E' 'OUTPUTLEN'   '9'.


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
  st_sort-fieldname = 'OPNBK'.
  st_sort-tabname   = 'IT_LIST'.
*  st_sort-up        = 'X'.
*  ST_SORT-GROUP     = 'X'.
*  st_sort-subtot    = 'X'.
*  ST_SORT-EXPA      = 'X'.
  APPEND st_sort TO it_sort.

  CLEAR  st_sort.
  st_sort-spos = '02'.
  st_sort-fieldname = 'OPNNO'.
  st_sort-tabname   = 'IT_LIST'.
*  st_sort-up        = 'X'.
*  ST_SORT-GROUP     = 'X'.
*  st_sort-subtot    = 'X'.
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
  header-info = '수입L/C 자금집행보고서'.
*  IF p_int1 EQ 'X'.
*    CONCATENATE '사후납부' header-info INTO header-info
*                                       SEPARATED BY space.
*  ELSE.
*    CONCATENATE '월별납부' header-info INTO header-info
*                                       SEPARATED BY space.
*  ENDIF.
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
*&      Form  input_field_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM input_field_check .

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

*  SELECT expcd
*    INTO p_expcd
*    FROM ztitig06 UP TO 1 ROWS
*   WHERE bukrs  EQ  p_bukrs
*     AND expgr  EQ  'C'
*     AND cstcl  EQ  '1'.
*  ENDSELECT.
*  IF sy-subrc <> 0.
*    MESSAGE e878 WITH p_bukrs.
*  ENDIF.

ENDFORM.                    " input_field_check

*---------------------------------------------------------------------*
*       Form  SUBTOTAL_TEXT                                           *
*---------------------------------------------------------------------*
*FORM subtotal_text USING my_listhead LIKE t_alv_list
*                         my_subtotal TYPE slis_subtot_text.
*
*  DATA: l_count(10)  TYPE c,
*        l_text40(40) TYPE c.
*
*  FIELD-SYMBOLS: <l_fs>.
**  DATA: l_vendor(10) TYPE c.
*
*  CLEAR my_subtotal-display_text_for_subtotal.
*
*
*
*  CASE my_subtotal-criteria.
*    WHEN 'STATE'.  ">관세사.
*      SELECT SINGLE namet
*        INTO my_subtotal-display_text_for_subtotal
*        FROM ztstig3
*       WHERE parti  EQ  'H'
*         AND epart  EQ  my_listhead-state.
*      ASSIGN my_listhead-state TO <l_fs>.
*      MOVE-CORRESPONDING my_listhead TO t_alv_list.
*    WHEN 'CDCOR'.  ">세관.
*      PERFORM get_domain_value_text
*                  USING
*                     'ZTSCDCOR'
*                     my_listhead-cdcor
*                     l_text40.
*      my_subtotal-display_text_for_subtotal = l_text40.
*      ASSIGN my_listhead-cdcor TO <l_fs>.
*    WHEN 'BUPLA'.  ">사업장.
*      SELECT SINGLE name
*        INTO my_subtotal-display_text_for_subtotal
*        FROM j_1bbranch
*       WHERE bukrs  EQ  p_bukrs
*         AND branch EQ  my_listhead-bupla.
*      ASSIGN my_listhead-bupla TO <l_fs>.
*    WHEN OTHERS.
*      EXIT.
*  ENDCASE.
*
*  READ TABLE it_subtotal WITH KEY cdcor  = t_alv_list-cdcor
*                                  STATE  = t_alv_list-state
*                                  bupla  = t_alv_list-bupla.
*
*  IF sy-subrc EQ 0.
*    WRITE : it_subtotal-count TO l_count.
*  ELSE.
*    CLEAR: l_count.
*    l_count+09 = 0.
*  ENDIF.
*
*  CONCATENATE <l_fs>
*              my_subtotal-display_text_for_subtotal
*              l_count '건'
*              INTO my_subtotal-display_text_for_subtotal
*              SEPARATED BY space.

*ENDFORM.                    "SUBTOTAL_TEXT
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
