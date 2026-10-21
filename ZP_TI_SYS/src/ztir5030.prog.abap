************************************************************************
* Title         :  ZTIR5030                                            *
*                                                                      *
* Description   : [Report] 무환 Sample 물대(잡이익) 처리               *
*                                                                      *
* Creation Date : 2004/12/27                                           *
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
* 1.                                                                   *
* 2.                                                                   *
*                                                                      *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* dd-mmm-yyyy  xxxxxxxxxxxxxxx  DVPK9xxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  *
*                                                                      *
*                                                                      *
************************************************************************
REPORT  ztir5030       MESSAGE-ID zmti00
                       NO STANDARD PAGE HEADING.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE zts_reuse_alvforms_t00.  "> AVL 공용 Data 선언.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPES: BEGIN OF ty_header,
            box(1)      TYPE c,
            iccno       LIKE ztitcck-iccno,    "통관관리번호.
            lifnr       LIKE ztitblk-lifnr,    "거래처.
            name1       LIKE lfa1-name1,       "거래처명.
            iblno       LIKE ztitblk-iblno,    "b/l관리번호.
            blnum       LIKE ztitblk-blnum.    "b/l 번호.

TYPES: END OF ty_header.

TYPES: BEGIN OF ty_item.
INCLUDE     TYPE        ty_header.
TYPES :     iblit       LIKE ztitblp-iblit,    " 품목번호.
            txz01       LIKE ztitblp-txz01,    " 내역
            ccuak       LIKE ztitccp-ccuak,    "과세가격합계(KRW).
            ccuakc      LIKE ztitcck-ccuakc ,   "통화.
            werks       LIKE ztitblp-werks,    "플랜트.
            name2       LIKE t001w-name1.       "플랜트명.

TYPES: END OF ty_item.


TYPES: BEGIN OF ty_list.
INCLUDE             TYPE        ty_item.
TYPES:      color   TYPE slis_t_specialcol_alv.
TYPES: END OF ty_list.

*> Select용.
TYPES: BEGIN OF ty_tab.
INCLUDE     TYPE        ty_item.
TYPES: END OF ty_tab.

*> TYPE FOR THE DATA OF '수입물품 미통관 아이템'
TYPES: BEGIN OF t_ztisccit.
        INCLUDE STRUCTURE ztisccit.
TYPES: box        TYPE c,
       index(10)  TYPE n,
       END OF t_ztisccit.

*> INTERNAL TABLE FOR TABLECONTROL '수입아이템'
DATA:     it_ztisccit         TYPE t_ztisccit OCCURS 0 WITH HEADER LINE,
          g_ztisccit_wa       TYPE t_ztisccit.           ">work area

************************************************************************
* SAP Include Define                                                   *
************************************************************************

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: t001,
        t001w,
        ztitig02,
        lfa1,
        mara,
        ztitrqk,
        ztitrqs,
        ztitrqp,
        ztitblk,
        ztitblp,
        ztitivk,
        ztitivp,
        ztitcck,
        ztitccp,
        ztitgrk,
        ztitbik,
        ztitgrp.

************************************************************************
* SAP Views                                                            *
************************************************************************
TABLES: ztivpo00,    ">Purchasing Document : Header + Items
        ztivrq00.    ">수입의뢰 Views(Header + Items + status)

************************************************************************
* CONSTANTS                                                            *
************************************************************************
** JS전선 회사코드 2007/04 --------------------------------------
*CONSTANTS:
*    c_bukrs     LIKE t001-bukrs     VALUE '1000'.   ">Company code
** JS전선 회사코드 2007/04 --------------------------------------
************************************************************************
* Internal Tables                                                      *
************************************************************************
*DATA : BEGIN OF it_ZTItig02 OCCURS 0.
*        INCLUDE STRUCTURE ZTItig02.
*DATA : END   OF it_ZTItig02.
*
DATA: it_ztitig02  TYPE ztitig02  OCCURS 0 WITH HEADER LINE.
DATA: it_list      TYPE ty_list   OCCURS 0 WITH HEADER LINE.
DATA: it_header    TYPE ty_header OCCURS 0 WITH HEADER LINE.
DATA: it_tab       TYPE ty_tab    OCCURS 0 WITH HEADER LINE.

************************************************************************
* DATA Declarations                                                    *
************************************************************************

************************************************************************
** RANGES
************************************************************************
*RANGES:

***********************************************************************
* FIELD-GROUPS
***********************************************************************
*FIELD-GROUPS:

***********************************************************************
* FIELD-SYMBOLS
***********************************************************************
*FIELD-SYMBOLS:

************************************************************************
* MACRO DEFINE                                                         *
************************************************************************

************************************************************************
* CLASSES: Definition                                                  *
************************************************************************

************************************************************************
* CLASSES: IMPLEMENTATION
*
************************************************************************

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK box1 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_bukrs  FOR ztitrqk-bukrs                   "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk
                    MODIF  ID iog ,
  s_blnum  FOR ztitblk-blnum MODIF ID iog,     "B/L 번호.
  s_iblno  FOR ztitblk-iblno MODIF ID iog      "B/L 관리번호.
                              MEMORY ID ztiiblno,
  s_bidnr  FOR ztitbik-bidnr MODIF ID iog,      "반입신고번호.
  s_cdrdt  FOR ztitcck-cdrdt MODIF ID iog,      "신고수리일.
  s_bleta  FOR ztitblk-bleta MODIF ID iog,
  "ETA(도착 예정 시각)
  s_werks  FOR ztitblk-werks MODIF ID iog,                  "대표 플랜트
  s_txz01  FOR ztitblp-txz01 MODIF ID iog
                              MEMORY ID bes.    "내역.

SELECTION-SCREEN END OF BLOCK box1.

SELECTION-SCREEN BEGIN OF BLOCK box2 WITH FRAME TITLE text-002.
PARAMETERS: p_ab1 RADIOBUTTON GROUP ab1 DEFAULT 'X',
            p_ab2 RADIOBUTTON GROUP ab1.
SELECTION-SCREEN END OF BLOCK box2.


SELECTION-SCREEN BEGIN OF BLOCK lists WITH FRAME TITLE text-002.
PARAMETERS: p_vari LIKE disvariant-variant,
            p_item TYPE c AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK lists.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE zts_reuse_alvforms_f00.  "> AVL 공용 Subroutines.
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: l_yn    type c.
INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* INITIALIZATION Event                                                 *
************************************************************************
INITIALIZATION.
  PERFORM p1000_alv_fields_initial.
  PERFORM p1001_initialization.

************************************************************************
* AT SELECTION-SCREEN Events                                           *
************************************************************************
AT SELECTION-SCREEN.
*> 사용자 Input values Check
  PERFORM p1100_check_input_values.
*> 사용자 레이아웃 Input values Check
  PERFORM p1101_check_variant_value.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM p1102_authorization_check USING s_bukrs-low.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*> 레이아웃 HELP
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM p1102_f4_for_variant.

************************************************************************
* START-OF-SELECTION Event                                             *
************************************************************************
START-OF-SELECTION.
*> 검색조건에 해당하는 데이타를 Select.
  PERFORM p2000_data_selections.
*> Header table과 List(Items) table를 만듬.
  PERFORM p2100_header_and_list_build.
*> 품목을 조회하지 않음.
  PERFORM p2001_item_clear USING p_item.
************************************************************************
* END-OF-SELECTION Event                                               *
************************************************************************
END-OF-SELECTION.
  DESCRIBE TABLE it_tab LINES g_line.
  IF NOT g_line IS INITIAL.
*> PROGRESS Display.
    g_linen    = 90.
    g_out_text = '리스트를 구성 중입니다 %99999%%'(p03).
    REPLACE '%99999%'(p99) WITH g_linen INTO g_out_text.
    PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.

    PERFORM 3000_field_category_build.
    PERFORM 3100_set_color_infomation.
    PERFORM 3200_key_infomation_build.
    PERFORM 3300_event_exit_table_build.
    PERFORM 3400_comment_build.
    PERFORM 3500_sort_table_build.
    PERFORM 3600_event_table_build USING : slis_ev_top_of_page,
                                           slis_ev_pf_status_set,
                                           slis_ev_user_command.
    PERFORM 3700_layout_build.
    PERFORM 3910_call_alv_hierseq.
  ENDIF.

*> Program 종료.
  PERFORM  p9000_program_exit.

****************u*******************************************************
*
* TOP-OF-PAGE Event                                                    *
************************************************************************
TOP-OF-PAGE.

************************************************************************
* END-OF-PAGE Event                                                    *
************************************************************************
END-OF-PAGE.

************************************************************************
* TOP-OF-PAGE DURING LINE-SELECTION Event                              *
************************************************************************
TOP-OF-PAGE DURING LINE-SELECTION.


************************************************************************
* AT LINE-SELECTION Event                                              *
************************************************************************
AT LINE-SELECTION.


************************************************************************
* AT USER-COMMAND Event                                                *
************************************************************************
AT USER-COMMAND.

*eject
************************************************************************
*                                                                      *
* S U B R O U T I N E S                                                *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
FORM p1001_initialization .

  SET TITLEBAR 'T1000' WITH  ' List'.

ENDFORM.                    " p1001_initialization

*&---------------------------------------------------------------------*
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
FORM p2000_data_selections .

  DATA: l_rqmng  LIKE ztitrqp-rqmng.

  CLEAR: g_count, it_tab, it_ztitig02, it_header, it_list.
  REFRESH : it_tab, it_ztitig02, it_header, it_list.
*> PROGRESS Display.
  g_linen    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_linen INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.

*> B/L 데이타 select.



  SELECT d~iccno c~lifnr c~iblno c~blnum a~iblit
         a~txz01 b~ccuak a~werks d~ccuakc
        INTO CORRESPONDING FIELDS OF TABLE it_tab
        FROM ( ( ( ztitblp AS a INNER JOIN ztitccp AS b
          ON  a~iblno EQ b~iblno
          AND a~iblit EQ b~iblit ) INNER JOIN ztitblk AS c
                          ON a~iblno EQ c~iblno ) INNER JOIN ztitcck AS
                          d
                                       ON b~iccno EQ d~iccno )
         WHERE c~bukrs  IN s_bukrs   "회사코드.
           AND c~blnum  IN s_blnum  "b/l 번호.
           AND c~iblno  IN s_iblno  "b/l 관리번호.
           AND d~cdrdt  IN s_cdrdt  "신고 수리일.
           AND c~bleta  IN s_bleta  "eta
           AND c~werks  IN s_werks  "플랜트.
           AND a~txz01  IN s_txz01  "내역.
           AND a~ndfty  EQ 'S'.

  IF sy-subrc NE 0.
    MESSAGE s902.
  ENDIF.

  DATA : l_ppmng LIKE ztitivp-ppmng.

  CLEAR: g_tabix, g_count, g_cnt.
  LOOP AT it_tab.
    g_tabix = sy-tabix.

*   공급업체.
    SELECT SINGLE name1 INTO it_tab-name1
      FROM lfa1
     WHERE lifnr EQ it_tab-lifnr.
*   플랜트
    SELECT SINGLE name1 INTO it_tab-name2
      FROM t001w
     WHERE werks EQ it_tab-werks.

    ADD 1 TO g_count.

    MODIFY it_tab INDEX g_tabix.
  ENDLOOP.

  IF g_count EQ 0.
    MESSAGE s902.
  ENDIF.


ENDFORM.                    " p2000_data_selections
*&---------------------------------------------------------------------*
*&      Form  3000_field_category_build
*&---------------------------------------------------------------------*
FORM 3000_field_category_build .

*----------------------------------------------------------------------*
* 필드명과 Output Length등을 사용자의 입맛에 맞게 바꿈.
*----------------------------------------------------------------------*
  PERFORM 3010_fill_field_category USING :
*>>>>>>HEADER
"BOX.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   ' ',
          ' ' 'FIELDNAME'     'BOX',
          ' ' 'HOTSPOT'       ' ',
          'E' 'KEY'           ' ',

"CC 관리번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITCCK',
          ' ' 'FIELDNAME'     'ICCNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"공급업체.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'LIFNR',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '10',

"공급업체명
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'SELTEXT_M'    '공급업체명',
          ' ' 'REF_TABNAME'   'LFA1',
          ' ' 'OUTPUTLEN'     '28',
          'E' 'FIELDNAME'     'NAME1',

"B/L 관리 번호.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'IBLNO',
*          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '17',

"B/L 번호.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'BLNUM',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '17',





*>>>>>>>>>LIST
*"I/V 품목번호.
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTITBLP',
*          ' ' 'FIELDNAME'     'IBLIT',
*          ' ' 'HOTSPOT'       'X',
*          ' ' 'JUST'          c_charl," (R)ight (L)eft (C)ent.
*          ' ' 'LZERO'         c_charx,
*          ' ' 'INTLEN'         10,
*          ' ' 'KEY'           'X',
*          'E' 'OUTPUTLEN'     '12',
"B/L 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'IBLIT',
          'E' 'OUTPUTLEN'     '12',

"내역.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'TXZ01',
          'E' 'OUTPUTLEN'     '27',

*
"금액(원화).
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITCCP',
          ' ' 'FIELDNAME'     'CCUAK',
          ' ' 'CFIELDNAME'     'CCUAKC',
          'E' 'OUTPUTLEN'     '18',
"통화
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITCCK',
          ' ' 'FIELDNAME'     'CCUAKC',

          'E' 'OUTPUTLEN'     '10',
"플랜트.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'WERKS',
          'E' 'OUTPUTLEN'     '6',

"플랜트명.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'T001W',
          ' ' 'SELTEXT_L'    '플랜트명',
          ' ' 'FIELDNAME'     'NAME2',
          'E' 'OUTPUTLEN'     '30'.

ENDFORM.                    " 3000_field_category_build

*&---------------------------------------------------------------------*
*&      Form  3200_KEY_INFOMATION_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM 3200_key_infomation_build .

  CLEAR gs_keyinfo.

  gs_keyinfo-header01 = 'IBLNO'.
  gs_keyinfo-item01   = 'IBLNO'.

*  gs_keyinfo-header02 =  space.
*  gs_keyinfo-item02   = 'ICCIT'.
*
*  GS_KEYINFO-HEADER03 = SPACE.
*  GS_KEYINFO-ITEM03   = 'OBJNR'.

ENDFORM.                    " 3200_KEY_INFOMATION_BUILD
*&---------------------------------------------------------------------*
*&      Form  3100_SET_COLOR_INFOMATION
*&---------------------------------------------------------------------*
FORM 3100_set_color_infomation .

  LOOP AT it_list.

*    CLEAR: LT_RESRC_VW-COLOR_INFO[],
*           GS_COLOR_INFO.
*    ON CHANGE OF LT_RESRC_VW-RESRC.
*      GS_COLOR_INFO-FIELDNAME = 'RESRC'.
*      GS_COLOR_INFO-COLOR-COL = '3'.
*      APPEND GS_COLOR_INFO TO LT_RESRC_VW-COLOR_INFO[].
*      MODIFY LT_RESRC_VW.
*    ENDON.

  ENDLOOP.                             " AT LT_RESRC_VW

ENDFORM.                    " 3100_SET_COLOR_INFOMATION
*&---------------------------------------------------------------------*
*&      Form  3400_COMMENT_BUILD
*&---------------------------------------------------------------------*
FORM 3400_comment_build .

  TABLES : dfies.
  DATA: l_text20(20) TYPE c.

  CLEAR: it_listheader, gs_listheader.
  REFRESH: it_listheader.

* LIST HEADING LINE: TYPE H
  CLEAR gs_listheader.
  gs_listheader-typ  = 'H'.
* gs_listheader-KEY:  NOT USED FOR THIS TYPE
  gs_listheader-info = '무환 Sample 물대(잡이익) 처리 List'.
*  SHIFT gs_listheader-info RIGHT BY 20 PLACES.
  APPEND gs_listheader TO it_listheader.

** JS전선 회사코드 2007/04 KSH --------------------------------------
  DATA: l_butxt LIKE t001-butxt.
  CLEAR: l_butxt.
  SELECT SINGLE butxt FROM t001
                      INTO l_butxt
                     WHERE bukrs EQ s_bukrs-low.

  CLEAR gs_listheader.
  gs_listheader-typ  = 'A'.
  gs_listheader-info = '회사코드 :'.
  CONCATENATE gs_listheader-info s_bukrs-low l_butxt
         INTO gs_listheader-info SEPARATED BY space.
  APPEND gs_listheader TO it_listheader.
** JS전선 회사코드 2007/04 KSH --------------------------------------

* ACTION LINE: TYPE A
  CLEAR gs_listheader.
  gs_listheader-typ  = 'A'.
  gs_listheader-info = '출력일자 :'(t12).
  WRITE: sy-datlo TO l_text20.
  CONCATENATE gs_listheader-info l_text20 INTO gs_listheader-info
              SEPARATED BY space.
  APPEND gs_listheader TO it_listheader.

* STATUS LINE: TYPE S
* CLEAR LS_LINE.
* LS_LINE-TYP  = 'S'.
* LS_LINE-KEY  = 'Kostenrechnungskreis:'.
* LS_LINE-INFO = P_KOKRS.
* APPEND LS_LINE TO LT_TOP_OF_PAGE.

* LS_LINE-KEY  = 'Gesch?tsjahr:_______'.
* LS_LINE-INFO = P_GJAHR.
* APPEND LS_LINE TO LT_TOP_OF_PAGE.

* LS_LINE-KEY  = 'Version:_____________'.
* LS_LINE-INFO = P_VERSN.
* APPEND LS_LINE TO LT_TOP_OF_PAGE.

* ACTION LINE: TYPE A
*  CLEAR LS_LINE.
*  LS_LINE-TYP  = 'A'.
** LS_LINE-KEY:  NOT USED FOR THIS TYPE
*  LS_LINE-INFO = '<Action>'.
*  APPEND LS_LINE TO LT_TOP_OF_PAGE.

ENDFORM.                    " 3400_COMMENT_BUILD
*&---------------------------------------------------------------------*
*&      Form  3500_SORT_TABLE_BUILD
*&---------------------------------------------------------------------*
FORM 3500_sort_table_build .

  DATA: ls_sort TYPE slis_sortinfo_alv.

  CLEAR ls_sort.
  ls_sort-spos      = 1.
  ls_sort-fieldname = 'ICCNO'.
  ls_sort-tabname   = 'IT_HEADER'.
  ls_sort-up        = 'X'.
* LS_SORT-GROUP     = '*'.             " Seiten- bei Gruppenwechsel
*  ls_sort-group     = 'UL'.            " Underline      -"-
  APPEND ls_sort TO it_sort.

ENDFORM.                    " 3500_SORT_TABLE_BUILD
*&---------------------------------------------------------------------*
*&      Form  3700_LAYOUT_build
*&---------------------------------------------------------------------*
FORM 3700_layout_build .

  MOVE: 'BOX'        TO gs_layout-box_fieldname,
        'IT_HEADER'  TO gs_layout-box_tabname.

*  MOVE: '3'          TO gs_layout-no_vline. " 분리자 라인.

ENDFORM.                    " 3700_LAYOUT_build

*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
FORM top_of_page.                                           "#EC CALLED

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = it_listheader[].

ENDFORM.                    "TOP_OF_PAGE

*---------------------------------------------------------------------*
*       Form  USER_COMMAND                                            *
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  DATA: ls_header TYPE ty_tab.

  CLEAR: ls_header.

  CASE r_ucomm.

    WHEN 'ZTIT203'.    "B/L 조회
      LOOP AT it_header WHERE box EQ 'X'.

        SET PARAMETER ID 'ZTIIBLNO' FIELD it_header-iblno.
        CALL TRANSACTION 'ZTIT203' AND SKIP FIRST SCREEN.
      ENDLOOP.

    WHEN 'ZTIT403'.    "통관조회
      LOOP AT it_header WHERE box EQ 'X'.

        SET PARAMETER ID 'ZTIICCNO' FIELD it_header-iccno.
        CALL TRANSACTION 'ZTIT403' AND SKIP FIRST SCREEN.
      ENDLOOP.
    WHEN 'FIDOC'.   "회계문서.

    WHEN 'POSTING'.  "전기.

    WHEN 'CANCEL'.   "전기취소.
*    WHEN 'ZTIT001'. " 후속기능
**> 전기처리.
*      CLEAR : g_line, ls_header.
*      LOOP AT it_header WHERE box EQ 'X'.
*        ADD 1 TO g_line.
*        MOVE-CORRESPONDING it_header TO ls_header.
*      ENDLOOP.
*      CASE g_line.
*        WHEN 0.
*          MESSAGE s006(0k).   EXIT.
*        WHEN 1.
*        WHEN OTHERS.
*          MESSAGE s929.       EXIT.
*      ENDCASE.
*
*      REFRESH: it_ztisccit.
*      LOOP AT it_list WHERE iblno EQ ls_header-iblno.
*        MOVE-CORRESPONDING it_list TO it_ztisccit.
*        APPEND it_ztisccit.
*      ENDLOOP.
*      SORT it_ztisccit BY iccno iccit.
*
**> Call Dialog
*      CALL DIALOG 'Z_TI_GR_CREATE'
*        AND SKIP FIRST SCREEN
*        EXPORTING
*          g_tcode     FROM sy-tcode
*          it_ztisccit FROM it_ztisccit
*        IMPORTING
*          ztitgrk.
**> Refresh.
*      IF NOT ztitgrk-igrno IS INITIAL.
*        PERFORM p9000_duelist_refresh USING  rs_selfield.
*      ENDIF.
*
*    WHEN '&IC1'.
*      IF rs_selfield-tabname EQ 'IT_HEADER'.
*        READ TABLE it_header INDEX rs_selfield-tabindex.
*      ELSEIF rs_selfield-tabname EQ 'IT_LIST'.
*        READ TABLE it_list INDEX rs_selfield-tabindex.
*      ENDIF.
*      IF sy-subrc NE 0.
*        MESSAGE s903. EXIT.
*      ENDIF.
*
*      IF rs_selfield-tabname EQ 'IT_HEADER'.
*        MOVE-CORRESPONDING it_header TO ls_header.
*      ELSEIF rs_selfield-tabname EQ 'IT_LIST'.
*        MOVE-CORRESPONDING it_list   TO ls_header.
*      ENDIF.

      CASE rs_selfield-fieldname.



        WHEN 'IBLNO' OR 'IBLIT'.
          PERFORM  display_bl_document(ztir0000)
                                          USING ls_header-iblno
                                                ls_header-iblit.
        WHEN OTHERS.
          PERFORM  display_bl_document(ztir0000)
                                          USING ls_header-iblno
                                                ls_header-iblit.
      ENDCASE.
    WHEN OTHERS.
  ENDCASE.

  CLEAR: r_ucomm.

ENDFORM.                    "USER_COMMAND
*---------------------------------------------------------------------*
*       FORM PF_STATUS_SET                                            *
*---------------------------------------------------------------------*
FORM pf_status_set USING rt_extab TYPE slis_t_extab.

  SET TITLEBAR 'T1000' WITH ' List'.

  REFRESH: rt_extab.

  APPEND 'ARCHIVE'   TO rt_extab.
  APPEND '&VEXCEL'   TO rt_extab.
  APPEND '&AQW'      TO rt_extab.
  APPEND '&VCRYSTAL' TO rt_extab.
  APPEND '&VGRID'    TO rt_extab.
  APPEND '&EB9'      TO rt_extab.
  APPEND '&CRDESIG'  TO rt_extab.
  APPEND '&XXL'      TO rt_extab.
  APPEND '&ABC'      TO rt_extab.

  SET PF-STATUS 'STANDARD ' EXCLUDING rt_extab.
*SET PF-STATUS 'ABCD' OF PROGRAM PROG.

ENDFORM.                    "PF_STATUS_SET
*&---------------------------------------------------------------------*
*&      Form  p1100_check_input_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p1100_check_input_values .

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




ENDFORM.                    " p1100_check_input_values


*eject
************************************************************************
*                                                                      *
* P B O   M O D U L E                                                  *
*                                                                      *
************************************************************************

*eject
************************************************************************
*                                                                      *
* P A I   M O D U L E                                                  *
*                                                                      *
***********************************************************************
