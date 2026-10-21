************************************************************************
* Title         :  ZTIR7010                                            *
*                                                                      *
* Description   : [Report] 세금계산서 처리 현황 LIST                   *
*                                                                      *
* Creation Date : 2005/10/31                                           *
*                                                                      *
* Author        : Soo Ho, Yoon                                       *
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
REPORT  ztir7010       MESSAGE-ID zmti00
                       NO STANDARD PAGE HEADING.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE zts_reuse_alvforms_t00.  "> AVL 공용 Data 선언.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPES: BEGIN OF ty_header,
*INCLUDE    STRUCTURE     ztivva00.
        box(1)      TYPE c,
        vatno       LIKE ztitvak-vatno,  "관리번호
        netdt       LIKE ztitvak-netdt,  "만기일
        lifnr       LIKE ztitvak-lifnr,
        waers       LIKE ztitvak-waers,
        refwr       LIKE ztivva00-refwr,   "송장값
        zterm       LIKE ztivva00-zterm,  "지급조건
        ztermt(40)  TYPE c,
        zlspr       LIKE ztivva00-zlspr,   "지급보류
        zlsprt(20)  TYPE c,
        name1       LIKE lfa1-name1.
TYPES: END OF ty_header.

TYPES: BEGIN OF ty_item.
INCLUDE     TYPE        ty_header.
TYPES:  rblgp      LIKE ztitvap-rblgp,  "품목
        ebeln      LIKE ztitvap-ebeln,
        reqno      LIKE ztitvap-reqno,
        reqit      LIKE ztitvap-reqit,
        ebelp      LIKE ztitvap-ebelp,
        cnam       LIKE ztitvap-cnam,
        unam       LIKE ztitvap-unam.


*INCLUDE     STRUCTURE   ztitvap.
TYPES: END OF ty_item.


TYPES: BEGIN OF ty_list.
INCLUDE             TYPE        ty_item.
TYPES:      color   TYPE slis_t_specialcol_alv.
TYPES: END OF ty_list.

*> Select용.
TYPES: BEGIN OF ty_tab.
INCLUDE     TYPE        ty_item.
TYPES: END OF ty_tab.

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
        ztitblp,
        ztitvak,
        ztitvap.

************************************************************************
* SAP Views                                                            *
************************************************************************
TABLES: ztivpo00,    ">Purchasing Document : Header + Items
        ztivrq00,    ">수입의뢰 Views(Header + Items + status)
        ztivva00.    ">세금계산 Header + Items
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
SELECTION-SCREEN BEGIN OF BLOCK dbsel WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_bukrs  FOR ztitvak-bukrs                   "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk
                    MODIF  ID iog ,
  s_ekorg  FOR ztitvak-ekorg MODIF  ID iog,    "구매조직
  s_ekgrp  FOR ztitvak-ekgrp MODIF  ID iog,    "구매그룹
  s_ebeln  FOR ztitvap-ebeln MODIF  ID iog,    "구매전표
  s_lifnr  FOR ztitvak-lifnr MODIF  ID iog,    "구매처
  s_vatno  FOR ztitvak-vatno MODIF  ID iog,    "세금계산서 관리번호
  s_reqno  FOR ztitvap-reqno MODIF  ID iog,    "수입의뢰번호
  s_vorga  FOR ztitvak-vorgang MODIF ID iog,   "트랜잭션/이벤트
  s_blart  FOR ztitvak-blart MODIF  ID iog,    "전표유형
  s_bupla  FOR ztitvak-bupla MODIF  ID iog,    "사업장
  s_gsber  FOR ztitvak-gsber MODIF  ID iog.    "업영역
SELECTION-SCREEN ULINE.
SELECT-OPTIONS:
  s_budat  FOR ztitvak-budat MODIF  ID iog,   "전표의 전기일
  s_bldat  FOR ztitvak-bldat MODIF  ID iog,   "전표에서 송장일
  s_zterm  FOR ztitvak-zterm MODIF  ID iog,   "지급조건키
  s_zfbdt  FOR ztitvak-zfbdt MODIF  ID iog,   "만기계산기준일
  s_netdt  FOR ztitvak-netdt MODIF  ID iog,   "순액지급 만기일
  s_mwskz  FOR ztitvak-mwskz MODIF  ID iog,   "부가가치세코드
  s_waers  FOR ztitvak-waers MODIF  ID iog,   "통화키
  s_wwert  FOR ztitvak-wwert MODIF  ID iog,   "환산일
  s_livst  FOR ztitvak-livst MODIF  ID iog,   "송장처리 상태
  s_xblnr  FOR ztitvak-xblnr MODIF  ID iog,   "6참조전표번호
  s_bktxt  FOR ztitvak-bktxt MODIF  ID iog,   "5전표헤더텍스트
  s_zlspr  FOR ztitvak-zlspr MODIF  ID iog,   "지급보류키
  s_zlsch  FOR ztitvak-zlsch MODIF  ID iog,   "지급방법
  s_uzawe  FOR ztitvak-uzawe MODIF  ID iog,   "지급방법보충
  s_belnr  FOR ztitvak-belnr MODIF  ID iog,   "10송장문서의 문서번호
  s_gjahr  FOR ztitvak-gjahr MODIF  ID iog,                 "4회계연도
  s_lponr  FOR ztitvak-lponr MODIF  ID iog,   "6최종품목번호
  s_cnam   FOR ztitvap-cnam  MODIF  ID iog,                 "12작성인
  s_cdat   FOR ztitvap-cdat  MODIF  ID iog,                 "8생성일
  s_ctme   FOR ztitvap-ctme  MODIF  ID iog,                 "6생성시간
  s_unam   FOR ztitvap-unam  MODIF  ID iog,   "12최종변경인
  s_udat   FOR ztitvap-udat  MODIF  ID iog,                 "8변경일
  s_utme   FOR ztitvap-utme  MODIF  ID iog.   "6최종변경시간
SELECTION-SCREEN END OF BLOCK dbsel.

SELECTION-SCREEN BEGIN OF BLOCK lists WITH FRAME TITLE text-002.
PARAMETERS: p_vari LIKE disvariant-variant.
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
*> Read default layout (description only, w/o field catalog)
  PERFORM  p1000_alv_fields_initial.
*> Report initialization
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

*> 지급조건 HELP(Low values)
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_zterm-low.
  PERFORM get_f4_for_zterm(ztir0000) USING s_zterm-low.
*> 지급조건 HELP(High values)
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_zterm-high.
  PERFORM get_f4_for_zterm(ztir0000) USING s_zterm-high.

************************************************************************
* START-OF-SELECTION Event                                             *
************************************************************************
START-OF-SELECTION.
*> 검색조건에 해당하는 데이타를 Select.
  PERFORM p2000_data_selections.
*> Header table과 List(Items) table를 만듬.
  PERFORM p2100_header_and_list_build.

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

  SET TITLEBAR 'T1000' WITH '현황 List'(t10).

ENDFORM.                    " p1001_initialization

*&---------------------------------------------------------------------*
*&      Form  p1100_check_input_values
*&---------------------------------------------------------------------*
FORM p1100_check_input_values .

  TABLES: dfies.

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

* Vendor
  READ TABLE s_lifnr INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT lifnr INTO (l_lifnr)
                 FROM lfb1 UP TO 1 ROWS WHERE lifnr IN s_lifnr
                                        AND   bukrs IN s_bukrs.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'LFA1' 'LIFNR' sy-langu
                                  CHANGING dfies g_subrc.
      SET CURSOR FIELD 'S_LIFNR-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.
  ENDIF.

* Purchase Organization
  READ TABLE s_ekorg INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT ekorg INTO (l_ekorg)
                 FROM t024e UP TO 1 ROWS WHERE ekorg IN s_ekorg.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'T024E' 'EKORG' sy-langu
                                  CHANGING dfies g_subrc.
      SET CURSOR FIELD 'S_EKORG-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.
  ENDIF.

* Purchase GROUP
  READ TABLE s_ekgrp INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT ekgrp INTO (l_ekgrp)
                 FROM t024 UP TO 1 ROWS WHERE ekgrp IN s_ekgrp.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'T024' 'EKGRP' sy-langu
                                  CHANGING dfies g_subrc.
      SET CURSOR FIELD 'S_EKGRP-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.
  ENDIF.

ENDFORM.                    " p1100_check_input_values

*&---------------------------------------------------------------------*
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
FORM p2000_data_selections .

  DATA: l_rqmng  LIKE ztitrqp-rqmng.

  CLEAR: g_count, it_tab, it_header, it_list.
  REFRESH : it_tab, it_header, it_list.
*> PROGRESS Display.
  g_linen    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_linen INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.

*> I/V 데이타 select.
  SELECT *
        INTO CORRESPONDING FIELDS OF TABLE it_tab
        FROM ztivva00
       WHERE vatno   IN s_vatno
         AND vorgang IN s_vorga   "1트랜잭션/이벤트
         AND bukrs   IN s_bukrs                             "4회사코드
         AND ekorg   IN s_ekorg
         AND ekgrp   IN s_ekgrp
         AND ebeln   IN s_ebeln
         AND lifnr   IN s_lifnr
         AND blart   IN s_blart                             "2전표유형
         AND bupla   IN s_bupla                             "4사업장
         AND gsber   IN s_gsber                             "4사업영역
         AND budat   IN s_budat   "8전표의 전기일
         AND bldat   IN s_bldat   "8전표에서 송장일
         AND zterm   IN s_zterm   "4지급조건키
         AND zfbdt   IN s_zfbdt   "8만기계산기준일
         AND netdt   IN s_netdt   "8순액지급 만기일
         AND mwskz   IN s_mwskz   "2부가가치세코드
         AND waers   IN s_waers                             "5통화키
         AND wwert   IN s_wwert                             "8환산일
         AND xblnr   IN s_xblnr   "참조전표번호
         AND bktxt   IN s_bktxt   "전표헤더텍스트
         AND zlspr   IN s_zlspr   "지급보류키
         AND zlsch   IN s_zlsch   "지급방법
         AND uzawe   IN s_uzawe   "지급방법보충
         AND ebeln   IN s_ebeln   "구매전표
         AND reqno   IN s_reqno   "수입의뢰번호
         AND cnam    IN s_cnam    "작성인
         AND cdat    IN s_cdat    "생성일
         AND ctme    IN s_ctme    "생성시간
         AND unam    IN s_unam    "최종변경인
         AND udat    IN s_udat    "변경일
         AND utme    IN s_utme.   "최종변경시간

  IF sy-subrc NE 0.
    MESSAGE s902.
  ENDIF.

  CLEAR: g_tabix, g_count, g_cnt.
  LOOP AT it_tab.
    g_tabix = sy-tabix.
*   공급업체.
    SELECT SINGLE name1 INTO it_tab-name1
      FROM lfa1
     WHERE lifnr EQ it_tab-lifnr.

*지급방법
    SELECT SINGLE text1
      INTO it_tab-ztermt
      FROM t052u
     WHERE zterm EQ it_tab-zterm
       AND spras EQ sy-langu.

*지급보류
    SELECT SINGLE textl
      INTO it_tab-zlsprt
      FROM t008t
     WHERE zahls EQ it_tab-zlspr
       AND spras EQ sy-langu.

    MODIFY it_tab INDEX g_tabix.

  ENDLOOP.

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
          ' ' 'FIELDNAME'     'BOX',
          'E' 'KEY'           ' ',
"관리번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITVAK',
          ' ' 'FIELDNAME'     'VATNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',

"만기일.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'seltext_m'     '문서종류',
          ' ' 'REF_TABNAME'   'ZTITVAK',
          ' ' 'FIELDNAME'     'NETDT',
          'E' 'OUTPUTLEN'     '12',

"지급조건.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'seltext_m'     '문서종류',
          ' ' 'REF_TABNAME'   'ZTITVAK',
          ' ' 'FIELDNAME'     'ZTERM',
          'E' 'OUTPUTLEN'     '10',

"지급조건 TEXT
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'seltext_m'     '지급조건내역',
*          ' ' 'REF_TABNAME'   'ZTITVAK',
          ' ' 'FIELDNAME'     'ZTERMT',
          'E' 'OUTPUTLEN'     '40',


"지급보류.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'seltext_m'     '문서종류',
          ' ' 'REF_TABNAME'   'ZTITVAK',
          ' ' 'FIELDNAME'     'ZLSPR',
          'E' 'OUTPUTLEN'     '8',

"지급보류TEXT
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'seltext_m'     '지급보류내역',
*          ' ' 'REF_TABNAME'   'ZTITVAK',
          ' ' 'FIELDNAME'     'ZLSPRT',
          'E' 'OUTPUTLEN'     '20',

"공급업체코드
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'FIELDNAME'     'LIFNR',
          ' ' 'OUTPUTLEN'     20,
          'E' 'HOTSPOT'       'X',

"공급업체명
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'LFA1',
          ' ' 'OUTPUTLEN'     50,
          'E' 'FIELDNAME'     'NAME1',


"송장금액통화
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'seltext_m'     'Cur',
          ' ' 'REF_TABNAME'   'ZTITVAK',
          ' ' 'FIELDNAME'     'WAERS',
          'E' 'OUTPUTLEN'     '3',

*"총금액.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'seltext_m'     '송장값',
          ' ' 'FIELDNAME'     'REFWR',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'JUST'          c_charr," (R)ight (L)eft (C)ent.
*          ' ' 'LZERO'         c_charx,
*          ' ' 'CTABNAME'      'IT_HEADER',
          'E' 'OUTPUTLEN'     '20',





*>>>>>>>>>LIST
"I/V 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITVAP',
          ' ' 'FIELDNAME'     'RBLGP',
          ' ' 'HOTSPOT'       'X',
          ' ' 'JUST'          c_charl," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         c_charx,
          ' ' 'INTLEN'         10,
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"구매전표번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITVAP',
          ' ' 'FIELDNAME'     'EBELN',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '12',
*"구매문서 품목번호.
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTITVAP',
*          ' ' 'FIELDNAME'     'EBELP',
*          ' ' 'JUST'          c_charl," (R)ight (L)eft (C)ent.
*          ' ' 'LZERO'         c_charx,
*          ' ' 'NO_OUT'        'X',
*          'E' 'OUTPUTLEN'     '5',

"수입의뢰번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITVAP',
          ' ' 'FIELDNAME'     'REQNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '10',

"수입의뢰 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITVAP',
          ' ' 'JUST'          c_charl," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         c_charx,
          ' ' 'FIELDNAME'     'REQIT',
          'E' 'OUTPUTLEN'     '10',


"송장금액.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'seltext_m'     '송장값',
          ' ' 'FIELDNAME'     'REFWR',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'JUST'          c_charr," (R)ight (L)eft (C)ent.
*          ' ' 'LZERO'         c_charx,
          ' ' 'CTABNAME'      'IT_HEADER',
          'E' 'OUTPUTLEN'     '20',

"작성인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'CNAM',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',
"최종변경인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'UNAM',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10'.






*****************************************************

*  CLEAR  gs_fieldcat.
*  gs_fieldcat-TABNAME   = 'IT_HEADER'.
*  gs_fieldcat-FIELDNAME = 'BOX'.
*  APPEND  gs_fieldcat TO IT_fieldcat.
*
** Build the fieldcat according to DDIC structure SBOOK:
*  call function 'REUSE_ALV_FIELDCATALOG_MERGE'
*       exporting
*            i_structure_name   = 'ZTITIVK'
*            I_INTERNAL_TABNAME = 'IT_HEADER'
*       changing
*            ct_fieldcat      = IT_fieldcat[].
*
*  call function 'REUSE_ALV_FIELDCATALOG_MERGE'
*       exporting
*            i_structure_name   = 'ZTITIVP'
*            I_INTERNAL_TABNAME = 'IT_LIST'
*       changing
*            ct_fieldcat      = IT_fieldcat[].
*
*  DELETE IT_FIELDCAT WHERE TABNAME = 'IT_HEADER'
*                       AND fieldname = 'MANDT'.
*
*  DELETE IT_FIELDCAT WHERE TABNAME = 'IT_LIST'
*                       AND fieldname = 'MANDT'.
*
*  DELETE IT_FIELDCAT WHERE TABNAME = 'IT_LIST'
*                       AND fieldname = 'IVONO'.
*
*  LOOP AT IT_FIELDCAT INTO gs_fieldcat.
*
*     IF   gs_fieldcat-fieldname = 'IVONO'
*       OR gs_fieldcat-fieldname = 'IVNUM'
*       OR gs_fieldcat-fieldname = 'CIVDT'
*       OR gs_fieldcat-fieldname = 'BELNR'
*       OR gs_fieldcat-fieldname = 'RBLGP'
*       OR gs_fieldcat-fieldname = 'EBELP'
*       OR gs_fieldcat-fieldname = 'REQNO'
*       OR gs_fieldcat-fieldname = 'REQIT'
*       OR gs_fieldcat-fieldname = 'IBLNO'.
*
*     ELSE.
*          gs_fieldcat-no_out = 'X'.
*     ENDIF.
*     gs_fieldcat-COL_POS = ' '.
*     MODIFY IT_FIELDCAT FROM gs_fieldcat INDEX SY-TABIX.
*
*  ENDLOOP.

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
*
  gs_keyinfo-header01 = 'VATNO'.
  gs_keyinfo-item01   = 'VATNO'.

  gs_keyinfo-header02 =  space.
  gs_keyinfo-item02   = 'RBLGP'.

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

  DATA: l_text20(20) TYPE c.

  CLEAR: it_listheader, gs_listheader.
  REFRESH: it_listheader.

* LIST HEADING LINE: TYPE H
  CLEAR gs_listheader.
  gs_listheader-typ  = 'H'.
* gs_listheader-KEY:  NOT USED FOR THIS TYPE
  gs_listheader-info = '세금계산서 처리 현황 LIST'(t13).
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

*  DATA: ls_sort TYPE slis_sortinfo_alv.
*
*  CLEAR ls_sort.
*  ls_sort-spos      = 1.
*  ls_sort-fieldname = 'IVONO'.
*  ls_sort-tabname   = 'IT_LIST'.
*  ls_sort-up        = 'X'.
** LS_SORT-GROUP     = '*'.             " Seiten- bei Gruppenwechsel
**  ls_sort-group     = 'UL'.            " Underline      -"-
*  APPEND ls_sort TO it_sort.

ENDFORM.                    " 3500_SORT_TABLE_BUILD
*&---------------------------------------------------------------------*
*&      Form  3700_LAYOUT_build
*&---------------------------------------------------------------------*
FORM 3700_layout_build .

  MOVE: 'BOX'        TO gs_layout-box_fieldname,
        'IT_HEADER'  TO gs_layout-box_tabname.

*  MOVE: '3'          TO gs_layout-no_vline. " 분리자 라인.
*  clear ls_variant.
*  ls_variant = p_vari.


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
    WHEN '&REFRESH'.
      PERFORM p9000_duelist_refresh USING  rs_selfield.


    WHEN '&IC1'.

      IF rs_selfield-tabname EQ 'IT_HEADER'.
        READ TABLE it_header INDEX rs_selfield-tabindex.
      ELSEIF rs_selfield-tabname EQ 'IT_LIST'.
        READ TABLE it_list INDEX rs_selfield-tabindex.
      ENDIF.
      IF sy-subrc NE 0.
        MESSAGE s903. EXIT.
      ENDIF.

      IF rs_selfield-tabname EQ 'IT_HEADER'.
        MOVE-CORRESPONDING it_header TO ls_header.
      ELSEIF rs_selfield-tabname EQ 'IT_LIST'.
        MOVE-CORRESPONDING it_list   TO ls_header.
      ENDIF.

      CASE rs_selfield-fieldname.
        WHEN 'EBELN'.
          PERFORM  display_purchase_order(ztir0000)
                                          USING ls_header-ebeln
                                                ls_header-ebelp.
        WHEN 'REQNO' OR 'REQIT'.
          PERFORM  display_import_document(ztir0000)
                                          USING ls_header-reqno
                                                space
                                                ls_header-reqit.

        WHEN 'VATNO' .
          IF ls_header-vatno IS NOT INITIAL.
            SET PARAMETER ID 'ZTIVATNO' FIELD ls_header-vatno.
            CALL TRANSACTION 'ZTIT703' AND SKIP FIRST SCREEN.
          ENDIF.
      ENDCASE.

    WHEN OTHERS.
  ENDCASE.
  CLEAR: r_ucomm.

ENDFORM.                    "USER_COMMAND
*---------------------------------------------------------------------*
*       FORM PF_STATUS_SET                                            *
*---------------------------------------------------------------------*
FORM pf_status_set USING rt_extab TYPE slis_t_extab.

  SET TITLEBAR 'T1000' WITH 'Due List'(t10).

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
  APPEND 'ZTIT002'      TO rt_extab.
  APPEND 'ZTIT004'      TO rt_extab.


  SET PF-STATUS 'STANDARD ' EXCLUDING rt_extab.
*SET PF-STATUS 'ABCD' OF PROGRAM PROG.

ENDFORM.                    "PF_STATUS_SET

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
