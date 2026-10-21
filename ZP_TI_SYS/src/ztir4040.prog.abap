************************************************************************
*                                                                      *
* Title         : ZTIR4020                                             *
*                                                                      *
* Description   : [Report]  수입관세/부가세/통관료 일계표              *
*                                                                      *
* Creation Date : 2004/12/11                                           *
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
REPORT  ztir4040
        MESSAGE-ID zmti00
        NO STANDARD PAGE HEADING.
************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis.    "> Globale Type(ALV)

TYPES: BEGIN OF ty_selt.
TYPES: bukrs      LIKE ztivcs00-bukrs,
       cdath      LIKE ztivcs00-cdath,     "기준일
       ctmeh      LIKE ztivcs00-ctmeh,     "기준시간
       iname      LIKE ztivcs00-iname,     "담당자
       belnr      LIKE ztivcs00-belnr,     "회계번호
       ebeln      LIKE ztitblk-ebeln,      "P/O No
       blnum      LIKE ztitblk-blnum,      "B/L번호.
       blcnt      LIKE ztitblk-blcnt,      "B/L 차수.
       cdcno      LIKE ztitcck-cdcno,      "신고번호
       carty      LIKE ztitcck-carty,      "징수형태
       cartyt(30) TYPE c,                  "징수형태text
       cdcdt      LIKE ztitcck-cdcdt,      "신고일
       budat      LIKE ztivcs00-budat,     "지불일
       mwskz      LIKE ztivcs00-mwskz,     "세금코드
       expcd      LIKE ztivcs00-expcd,     "수입비용코드
       fwbas      LIKE ztivcs00-fwbas,     "과표액
       lifnr      LIKE ztivcs00-lifnr,     "거래선
       waers      LIKE ztivcs00-waers,     "통화
       wrbtr      LIKE ztivcs00-wrbtr,     "관세 "통관수수료
       wmwst      LIKE ztivcs00-wmwst,     "부가세
       bupla      LIKE ztivcs00-bupla,     "귀속사업장
       refno      LIKE ztivcs00-refno,
       iblno      LIKE ztitcck-iblno,
       unamh      like ztivcs00-unamh,
       udath      like ztivcs00-udath,
       utmeh      like ztivcs00-utmeh,
       iccno      like ztitcck-iccno.
TYPES: END OF ty_selt.

* LIST TYPE
TYPES: BEGIN OF ty_list.
INCLUDE TYPE ty_selt.
TYPES:  color  TYPE slis_t_specialcol_alv,
        wrbtr1 LIKE ztivcs00-wrbtr,             ">관세
        wrbtr2 LIKE ztivcs00-wrbtr,             ">통관수수료
        lifnrt(35)  TYPE c.
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
        lfa1,
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
SELECTION-SCREEN BEGIN OF BLOCK box1 WITH FRAME TITLE text-001.
PARAMETERS:
 p_bukrs LIKE ztetcck-bukrs                        "회사
              OBLIGATORY
                    MEMORY ID buk .
SELECT-OPTIONS:
 s_cdath FOR ztivcs00-cdath,                  "기준일
 s_ctmeh FOR ztivcs00-ctmeh,                  "기준시간
 s_iname FOR ztivcs00-iname.                  "담당자
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
* Get default variant3
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

  SELECT belnr budat mwskz fwbas lifnr wrbtr wmwst
         bupla refno cdath ctmeh waers expcd unamh
         udath utmeh
    INTO CORRESPONDING FIELDS OF TABLE it_selt
    FROM ztivcs00
   WHERE bukrs EQ p_bukrs
     AND cdath IN s_cdath
     AND ctmeh IN s_ctmeh
     AND iname IN s_iname
     AND expgr EQ 'C'.

  IF sy-subrc NE 0.
    MESSAGE s902.  EXIT.
  ENDIF.

  LOOP AT it_selt INTO gs_selt.
*>사후납부
    CLEAR gs_list.

    SELECT SINGLE cdcno carty cdcdt iblno iccno
      INTO CORRESPONDING FIELDS OF gs_selt
      FROM ztitcck
     WHERE iccno EQ gs_selt-refno.


*> P/O No
    SELECT SINGLE ebeln blcnt blnum
      INTO CORRESPONDING FIELDS OF gs_selt
      FROM ztitblk
     WHERE iblno EQ gs_selt-iblno.
*----> 회사마다 비용코드 다르므로 반드시 확인바람.
    CASE gs_selt-expcd.
      WHEN 'TRF'.
        MOVE gs_selt-wrbtr TO gs_list-wrbtr1.
      WHEN 'CCF'.
        MOVE gs_selt-wrbtr TO gs_list-wrbtr2.
    ENDCASE.
*----> End of Modification.

    SELECT SINGLE name1
      INTO gs_list-lifnrt
      FROM lfa1
     WHERE lifnr EQ gs_selt-lifnr.

    MOVE-CORRESPONDING : gs_selt TO gs_list.



*domain_value_text
    PERFORM get_domain_value_text(ztir0000)
                                   USING  'ZTICARTY' "도메인명
                                   gs_list-carty      "필드명
                                   gs_list-cartyt.    "텍스트명



    APPEND gs_list TO it_list.
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


  SET TITLEBAR 'T1000' .

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

*  events-name = slis_ev_subtotal_text.
*  events-form = slis_ev_subtotal_text.
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

       'S' 'TABNAME'     'IT_LIST',
       ' ' 'SELTEXT_M'   '회계번호',
       ' ' 'FIELDNAME'    'BELNR',
       'E' 'OUTPUTLEN'   '10',

*       'S' 'SELTEXT_M'   'P/O No',
       'S' 'REF_TABNAME'   'ZTITBLK',
       ' ' 'TABNAME'     'IT_LISTT',
       ' ' 'FIELDNAME'   'EBELN',
       'E' 'OUTPUTLEN'   '10',

       'S' 'SELTEXT_M'   '차수',
*       ' S' 'REF_TABNAME'   'ZTITCCK',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'BLCNT',
       'E' 'OUTPUTLEN'   '2',

*       'S' 'SELTEXT_M'   '차수',
       ' S' 'REF_TABNAME'   'ZTITBLK',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'BLNUM',
       'E' 'OUTPUTLEN'   '12',

*       'S' 'SELTEXT_M'   '신고번호',
       ' S' 'REF_TABNAME'   'ZTITCCK',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'CDCNO',
       'E' 'OUTPUTLEN'    '12',

*>징수형태
       'S' 'SELTEXT_M'   '징수코드',
*       ' S' 'REF_TABNAME'   'ZTITCCK',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'CARTY',
       ' ' 'JUST'        'C',
       'E' 'OUTPUTLEN'    '2',

*>징수형태text
       'S' 'SELTEXT_M'   '징수형태',
*       ' S' 'REF_TABNAME'   'ZTITCCK',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'CARTYT',
       'E' 'OUTPUTLEN'    '12',

       'S' 'SELTEXT_M'   '신고일',
*       ' S' 'REF_TABNAME'   'ZTITCCK',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'CDCDT',
       'E' 'OUTPUTLEN'    '8',

       'S' 'SELTEXT_M'   '지불일',
*       ' S' 'REF_TABNAME'   'ZTITCCK',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'BUDAT',
       'E' 'OUTPUTLEN'    '8',

*       'S' 'SELTEXT_M'   '세금코드',
       ' S' 'REF_TABNAME'   'ZTIVCS00',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'MWSKZ',
       'E' 'OUTPUTLEN'    '3',

**       'S' 'SELTEXT_M'   '수입비용코드',
*       ' S' 'REF_TABNAME'   'ZTIVCS00',
*       ' ' 'TABNAME'     'IT_LIST',
*       ' ' 'FIELDNAME'   'EXPCD',
*       'E' 'OUTPUTLEN'    '10',

       'S' 'SELTEXT_M'   '과표액',
*       ' S' 'REF_TABNAME'   'ZTITCCK',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'FWBAS',
       ' ' 'CFIELDNAME'  'WAERS',
       'E' 'OUTPUTLEN'    '10',

*       'S' 'SELTEXT_M'   '거래선',
**       ' S' 'REF_TABNAME'   'ZTITCCK',
*       ' ' 'TABNAME'     'IT_LIST',
*       ' ' 'FIELDNAME'   'LIFNR',
*       'E' 'OUTPUTLEN'    '10',

       'S' 'SELTEXT_M'   '거래선',
*       ' S' 'REF_TABNAME'   'ZTITCCK',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'LIFNRT',
       'E' 'OUTPUTLEN'    '10',


       'S' 'TABNAME'     'IT_LIST',
       ' ' 'SELTEXT_M'   '관세',
       ' ' 'FIELDNAME'    'WRBTR1',
       ' ' 'CFIELDNAME'   'WAERS',
*       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'   '10',

       'S' 'TABNAME'     'IT_LISTT',
       ' ' 'SELTEXT_M'   '부가세',
       ' ' 'FIELDNAME'    'WMWST',
       ' ' 'CFIELDNAME'   'WAERS',
*       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'   '8',

       'S' 'TABNAME'     'IT_LIST',
       ' ' 'SELTEXT_M'   '통관수수료',
       ' ' 'FIELDNAME'    'WRBTR2',
       ' ' 'CFIELDNAME'   'WAERS',
*       ' ' 'DO_SUM'        'X',
       'E' 'OUTPUTLEN'   '10',

       'S' 'SELTEXT_M'   '귀속사업장',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'BUPLA',
*       ' ' 'NO_OUT'       'X',
       'E' 'OUTPUTLEN'    '4',

*SORT
       'S' 'SELTEXT_M'   '기준일',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'CDATH',
       ' ' 'NO_OUT'       'X',
       'E' 'OUTPUTLEN'    '8',

       'S' 'SELTEXT_M'   '기준시간',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'CTMEH',
       ' ' 'NO_OUT'       'X',
       'E' 'OUTPUTLEN'    '8',

       'S' 'SELTEXT_M'   '변경일',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'UDATH',
       ' ' 'NO_OUT'       'X',
       'E' 'OUTPUTLEN'    '8',

       'S' 'SELTEXT_M'   '최종변경인',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'UNAMH',
       ' ' 'NO_OUT'       'X',
       'E' 'OUTPUTLEN'    '8',

       'S' 'SELTEXT_M'   '최종변경시간',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'UTMEH',
       ' ' 'NO_OUT'       'X',
       'E' 'OUTPUTLEN'    '8',

       'S' 'SELTEXT_M'   '통관관리번호',
       ' ' 'TABNAME'     'IT_LIST',
       ' ' 'FIELDNAME'   'ICCNO',
       ' ' 'NO_OUT'       'X',
       'E' 'OUTPUTLEN'    '8'.



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


*  CLEAR  st_sort.
*  st_sort-spos = '01'.
*  st_sort-fieldname = 'CDATH'.
*  st_sort-tabname   = 'IT_LIST'.
**  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
**  st_sort-subtot    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.
*
*  CLEAR  st_sort.
*  st_sort-spos = '02'.
*  st_sort-fieldname = 'CTMEH'.
*  st_sort-tabname   = 'IT_LIST'.
**  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
**  st_sort-subtot    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.

  CLEAR  st_sort.
  st_sort-spos = '01'.
  st_sort-fieldname = 'UNAMH'.
  st_sort-tabname   = 'IT_LIST'.
*  st_sort-up        = 'X'.
*  ST_SORT-GROUP     = 'X'.
*  st_sort-subtot    = 'X'.
*  ST_SORT-EXPA      = 'X'.
  APPEND st_sort TO it_sort.

  CLEAR  st_sort.
  st_sort-spos = '02'.
  st_sort-fieldname = 'UDATH'.
  st_sort-tabname   = 'IT_LIST'.
*  st_sort-up        = 'X'.
*  ST_SORT-GROUP     = 'X'.
*  st_sort-subtot    = 'X'.
*  ST_SORT-EXPA      = 'X'.
  APPEND st_sort TO it_sort.

  CLEAR  st_sort.
  st_sort-spos = '03'.
  st_sort-fieldname = 'UTMEH'.
  st_sort-tabname   = 'IT_LIST'.
*  st_sort-up        = 'X'.
*  ST_SORT-GROUP     = 'X'.
*  st_sort-subtot    = 'X'.
*  ST_SORT-EXPA      = 'X'.
  APPEND st_sort TO it_sort.

  CLEAR  st_sort.
  st_sort-spos = '04'.
  st_sort-fieldname = 'ICCNO'.
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
  header-info = '수입관세/부가세/통관료 일계표'.

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
  IF sy-subrc <> 0.
    MESSAGE e878 WITH p_bukrs.
  ENDIF.

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
