************************************************************************
* Title         : ZTII_COMMON_PART_T01                                 *
*                                                                      *
* Description   : 수입 공용 Top Include                                *
*                                                                      *
* Creation Date : 2004/02/11                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
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

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************

************************************************************************
* SAP Include Define                                                   *
************************************************************************

************************************************************************
* Tables                                                               *
************************************************************************

************************************************************************
* SAP Views                                                            *
************************************************************************


************************************************************************
* Controls                                                             *
************************************************************************
*>> DATA FOR TABSTRIP 'TABSTRIP'
*CONTROLS:  tabstrip TYPE TABSTRIP.
*
*CONTROLS: main TYPE TABSTRIP,
*          detail TYPE TABSTRIP.
CONTROLS: item_detail TYPE TABSTRIP,
          req_item_detail TYPE TABSTRIP,
          header_detail TYPE TABSTRIP,
          req_header_detail TYPE TABSTRIP.
*

************************************************************************
* CONSTANTS                                                            *
************************************************************************
*>> FUNCTION CODES FOR TABSTRIP

*CONSTANTS: BEGIN OF c_tabstrip,
*             tab1  LIKE sy-ucomm VALUE 'TABSTRIP_FC01',
*             tab2  LIKE sy-ucomm VALUE 'TABSTRIP_FC02',
*             tab3  LIKE sy-ucomm VALUE 'TABSTRIP_FC03',
*             tab4  LIKE sy-ucomm VALUE 'TABSTRIP_FC04',
*             tab5  LIKE sy-ucomm VALUE 'TABSTRIP_FC05',
*             tab6  LIKE sy-ucomm VALUE 'TABSTRIP_FC06',
*             tab7  LIKE sy-ucomm VALUE 'TABSTRIP_FC07',
*             tab8  LIKE sy-ucomm VALUE 'TABSTRIP_FC08',
*             tab9  LIKE sy-ucomm VALUE 'TABSTRIP_FC09',
*             tab10 LIKE sy-ucomm VALUE 'TABSTRIP_FC10',
*             tab11 LIKE sy-ucomm VALUE 'TABSTRIP_FC11',
*             tab12 LIKE sy-ucomm VALUE 'TABSTRIP_FC12',
*             tab13 LIKE sy-ucomm VALUE 'TABSTRIP_FC13',
*             tab14 LIKE sy-ucomm VALUE 'TABSTRIP_FC14',
*             tab15 LIKE sy-ucomm VALUE 'TABSTRIP_FC15',
*             tab16 LIKE sy-ucomm VALUE 'TABSTRIP_FC16',
*             tab17 LIKE sy-ucomm VALUE 'TABSTRIP_FC17',
*             tab18 LIKE sy-ucomm VALUE 'TABSTRIP_FC18',
*             tab19 LIKE sy-ucomm VALUE 'TABSTRIP_FC19',
*             tab20 LIKE sy-ucomm VALUE 'TABSTRIP_FC20',
*           END OF c_tabstrip.
*
**> 상수 정의(Screen Number).
*CONSTANTS:c_scr0100 LIKE sy-dynnr VALUE '0100', ">text screen Header
*          c_scr0120 LIKE sy-dynnr VALUE '0120', ">text screen Items
*          c_scr0200 LIKE sy-dynnr VALUE '0200', ">text screen Items
*          c_scr0300 LIKE sy-dynnr VALUE '0300', ">text screen Items
*          c_scr2000 LIKE sy-dynnr VALUE '2000', ">Main screen Level 1
*          c_scr2100 LIKE sy-dynnr VALUE '2100', ">Main screen  Level 2
*          c_scr2101 LIKE sy-dynnr VALUE '2101', ">Main screen  Level 2
*          c_scr2110 LIKE sy-dynnr VALUE '2110', ">Header        Level 3
*          c_scr2120 LIKE sy-dynnr VALUE '2120', ">Header Tab    Level 3
*c_scr2121 LIKE sy-dynnr VALUE '2121', ">Header Detail  Level 4
*c_scr2122 LIKE sy-dynnr VALUE '2122', ">Header Detail  Level 4
*c_scr2123 LIKE sy-dynnr VALUE '2123', ">Header Detail  Level 4
*c_scr2124 LIKE sy-dynnr VALUE '2124', ">Header Detail  Level 4
*c_scr2125 LIKE sy-dynnr VALUE '2125', ">Header Detail  Level 4
*c_scr2126 LIKE sy-dynnr VALUE '2126', ">Header Detail  Level 4
*c_scr2127 LIKE sy-dynnr VALUE '2127', ">Header Detail  Level 4
*c_scr2128 LIKE sy-dynnr VALUE '2128', ">Header Detail  Level 4
*c_scr2129 LIKE sy-dynnr VALUE '2129', ">Header Detail  Level 4
*          c_scr2130 LIKE sy-dynnr VALUE '2130', ">Item   tab    Level 3
*c_scr2131 LIKE sy-dynnr VALUE '2131', ">Item   Detail  Level 4
*c_scr2132 LIKE sy-dynnr VALUE '2132', ">Item   Detail  Level 4
*c_scr2133 LIKE sy-dynnr VALUE '2133', ">Item   Detail  Level 4
*c_scr2134 LIKE sy-dynnr VALUE '2134', ">Item   Detail  Level 4
*c_scr2135 LIKE sy-dynnr VALUE '2135', ">Item   Detail  Level 4
*c_scr2136 LIKE sy-dynnr VALUE '2136', ">Item   Detail  Level 4
*c_scr2137 LIKE sy-dynnr VALUE '2137', ">Item   Detail  Level 4
*c_scr2138 LIKE sy-dynnr VALUE '2138', ">Item   Detail  Level 4
*c_scr2139 LIKE sy-dynnr VALUE '2139', ">Item   Detail  Level 4
*          c_scr2140 LIKE sy-dynnr VALUE '2140', ">Item   table  Level 3
*          c_scr2141 LIKE sy-dynnr VALUE '2141', ">Item   table  Level 3
*          c_scr2142 LIKE sy-dynnr VALUE '2142', ">Item   table  Level 3
*          c_scr2143 LIKE sy-dynnr VALUE '2143', ">Item   table  Level 3
*          c_scr2144 LIKE sy-dynnr VALUE '2144', ">Item   table  Level 3
*          c_scr2145 LIKE sy-dynnr VALUE '2145', ">Item   table  Level 3
*          c_scr2146 LIKE sy-dynnr VALUE '2146', ">Item   table  Level 3
*          c_scr2147 LIKE sy-dynnr VALUE '2147', ">Item   table  Level 3
*          c_scr2148 LIKE sy-dynnr VALUE '2148', ">Item   table  Level 3
*          c_scr2149 LIKE sy-dynnr VALUE '2149', ">Item   table  Level 3
*          c_scr2200 LIKE sy-dynnr VALUE '2200', ">EDI screen Level 1
*
*          c_scr2210 LIKE sy-dynnr VALUE '2210', ">EDI screen Level 2:LC
*          c_scr2211 LIKE sy-dynnr VALUE '2211', ">EDI screen Level 2:LC
*          c_scr2212 LIKE sy-dynnr VALUE '2212', ">EDI screen Level 2:LC
*          c_scr2213 LIKE sy-dynnr VALUE '2213', ">EDI screen Level 2:LC
*          c_scr2214 LIKE sy-dynnr VALUE '2214', ">EDI screen Level 2:LC
*          c_scr2215 LIKE sy-dynnr VALUE '2215', ">EDI screen Level 2:LC
*          c_scr2216 LIKE sy-dynnr VALUE '2216', ">EDI screen Level 2:LC
*          c_scr2217 LIKE sy-dynnr VALUE '2217', ">EDI screen Level 2:LC
*          c_scr2218 LIKE sy-dynnr VALUE '2218', ">EDI screen Level 2:LC
*          c_scr2219 LIKE sy-dynnr VALUE '2219', ">EDI screen Level 2:LC
*
*          c_scr2220 LIKE sy-dynnr VALUE '2220', ">EDI screen Level 2:PU
*          c_scr2230 LIKE sy-dynnr VALUE '2230', ">EDI screen Level 2:LO
*          c_scr2235 LIKE sy-dynnr VALUE '2235', ">EDI screen Level 2:LO
*          c_scr2240 LIKE sy-dynnr VALUE '2240', ">EDI screen Level 2:TT
*
*          c_scr6000 LIKE sy-dynnr VALUE '6000', ">차입생성화면.
*
*          c_scr7000 LIKE sy-dynnr VALUE '7000', ">배부화면.
*
*          c_scr9998 LIKE sy-dynnr VALUE '9998', ">button screen
*          c_scr9999 LIKE sy-dynnr VALUE '9999'. ">Dummy screen  Level 3
*
**> 상수 정의(문자집합).
*CONSTANTS:
*           c_chara     TYPE c        VALUE 'A',
*           c_charb     TYPE c        VALUE 'B',
*           c_charc     TYPE c        VALUE 'C',
*           c_chard     TYPE c        VALUE 'D',
*           c_chare     TYPE c        VALUE 'E',
*           c_charf     TYPE c        VALUE 'F',
*           c_charg     TYPE c        VALUE 'G',
*           c_charh     TYPE c        VALUE 'H',
*           c_chari     TYPE c        VALUE 'I',
*           c_charj     TYPE c        VALUE 'J',
*           c_chark     TYPE c        VALUE 'K',
*           c_charl     TYPE c        VALUE 'L',
*           c_charm     TYPE c        VALUE 'M',
*           c_charn     TYPE c        VALUE 'N',
*           c_charo     TYPE c        VALUE 'O',
*           c_charp     TYPE c        VALUE 'P',
*           c_charq     TYPE c        VALUE 'Q',
*           c_charr     TYPE c        VALUE 'R',
*           c_chars     TYPE c        VALUE 'S',
*           c_chart     TYPE c        VALUE 'T',
*           c_charu     TYPE c        VALUE 'U',
*           c_charv     TYPE c        VALUE 'V',
*           c_charw     TYPE c        VALUE 'W',
*           c_charx     TYPE c        VALUE 'X',
*           c_chary     TYPE c        VALUE 'Y',
*           c_charz     TYPE c        VALUE 'Z',
*           c_char0     TYPE c        VALUE '0',
*           c_char1     TYPE c        VALUE '1',
*           c_char2     TYPE c        VALUE '2',
*           c_char3     TYPE c        VALUE '3',
*           c_char4     TYPE c        VALUE '4',
*           c_char5     TYPE c        VALUE '5',
*           c_char6     TYPE c        VALUE '6',
*           c_char7     TYPE c        VALUE '7',
*           c_char8     TYPE c        VALUE '8',
*           c_char9     TYPE c        VALUE '9',
*           c_char*     TYPE c        VALUE '*',
*           c_char$     TYPE c        VALUE '$',
*           c_char-     TYPE c        VALUE '-',
*           c_char_plus TYPE c        VALUE '+'.
*
*CONSTANTS: c_true      TYPE c        VALUE 'X',
*           c_false     TYPE c        VALUE space,
*           c_error     TYPE c        VALUE 'E',
*           c_warning   TYPE c        VALUE 'W',
*           c_success   TYPE c        VALUE 'S',
*           c_info      TYPE c        VALUE 'I',
*           c_abend     TYPE c        VALUE 'A',
*           c_none      TYPE c        VALUE 'N',
*           c_lock      TYPE c        VALUE 'L',
*           c_unlock    TYPE c        VALUE 'U',
*           c_zero      TYPE i        VALUE 0,
*           c_one       TYPE i        VALUE 1,
*           c_bstyp     TYPE bstyp    VALUE 'F',
*           c_lc        TYPE zmireqty VALUE 'LC',
*           c_lo        TYPE zmireqty VALUE 'LO',
*           c_pu        TYPE zmireqty VALUE 'PU',
*           c_tt        TYPE zmireqty VALUE 'TT',
*           c_da        TYPE zmireqty VALUE 'DA',
*           c_dp        TYPE zmireqty VALUE 'DP',
*           c_bl        TYPE zmireqty VALUE 'BL',
*           c_iv        TYPE zmireqty VALUE 'IV',
*           c_ip        TYPE zmireqty VALUE 'IP',
*           c_lg        TYPE zmireqty VALUE 'LG',
*           c_cc        TYPE zmireqty VALUE 'CC',
*           c_gr        TYPE zmireqty VALUE 'GR',
*           c_pn        TYPE zmireqty VALUE 'PN',
*           c_bs        TYPE zmireqty VALUE 'BS',
*           c_bi        TYPE zmireqty VALUE 'BI',
*           c_bo        TYPE zmireqty VALUE 'BO',
*           c_cs        TYPE zmireqty VALUE 'CS',
*           c_blart     TYPE blart    VALUE 'RE',
*           c_mwskz     TYPE mwskz    VALUE 'ZZ',
*           c_zlspr     TYPE dzlspr   VALUE 'M',
*           c_app700_r  TYPE tdsfname VALUE
*                                    'Z_IT_APP700_PRINT_OF_REQUEST',
*           c_inf700_r  TYPE tdsfname VALUE
*                                    'Z_IT_INF700_PRINT_OF_REQUEST',
*           c_app707_r  TYPE tdsfname VALUE
*                                    'Z_IT_APP707_PRINT_OF_REQUEST',
*           c_inf707_r  TYPE tdsfname VALUE
*                                    'Z_IT_INF707_PRINT_OF_REQUEST',
*           c_locapp_r  TYPE tdsfname VALUE
*                                    'Z_IT_LOCAPP_PRINT_OF_REQUEST',
*           c_locadv_r  TYPE tdsfname VALUE
*                                    'Z_IT_LOCADV_PRINT_OF_REQUEST',
*           c_locamr_r  TYPE tdsfname VALUE
*                                    'Z_IT_LOCAMR_PRINT_OF_REQUEST',
*           c_locama_r  TYPE tdsfname VALUE
*                                    'Z_IT_LOCAMA_PRINT_OF_REQUEST',
*           c_apppcr_r  TYPE tdsfname VALUE
*                                    'Z_IT_APPPCR_PRINT_OF_REQUEST',
*           c_payord_r  TYPE tdsfname VALUE
*                                    'Z_IT_PAYORD_PRINT_OF_REQUEST',
*           c_pcrlic_r  TYPE tdsfname VALUE
*                                    'Z_IT_PCRLIC_PRINT_OF_REQUEST',
*           c_debadv_r  TYPE tdsfname VALUE
*                                    'Z_IT_DEBADV_PRINT_OF_REQUEST',
*           c_loguar_r  TYPE tdsfname VALUE
*                                    'Z_IT_LOGUAR_PRINT_OF_REQUEST',
*           c_logua1_r  TYPE tdsfname VALUE
*                                    'Z_IT_LOGUAR_PRINT_OF_REQUEST1',
*           c_applog_r  TYPE tdsfname VALUE
*                                    'Z_IT_APPLOG_PRINT_OF_REQUEST',
*           c_applo1_r  TYPE tdsfname VALUE
*                                    'Z_IT_APPLOG_PRINT_OF_REQUEST1',
*           c_release_r  TYPE tdsfname VALUE
*                                    'Z_IT_RELEASE_NOTE',
*           c_ocean     TYPE zmifwdty VALUE 'O',
*           c_air       TYPE zmifwdty VALUE 'A',
*           c_etc       TYPE zmifwdty VALUE 'Z',
*           c_y         TYPE c        VALUE 'Y',
*           c_n         TYPE c        VALUE 'N',
*           c_a         TYPE c        VALUE 'A',
*           c_after     TYPE zmianbty VALUE 'A',  ">사전.
*           c_before    TYPE zmianbty VALUE 'B'.  ">사후.
*
************************************************************************
**
** DATA Declarations
**
************************************************************************
**
*TYPES:  BEGIN OF typ_tab_30,
*              tabstrip1      TYPE string40,
*              tabstrip2      TYPE string40,
*              tabstrip3      TYPE string40,
*              tabstrip4      TYPE string40,
*              tabstrip5      TYPE string40,
*              tabstrip6      TYPE string40,
*              tabstrip7      TYPE string40,
*              tabstrip8      TYPE string40,
*              tabstrip9      TYPE string40,
*              tabstrip10     TYPE string40,
*              tabstrip11     TYPE string40,
*              tabstrip12     TYPE string40,
*              tabstrip13     TYPE string40,
*              tabstrip14     TYPE string40,
*              tabstrip15     TYPE string40,
*              tabstrip16     TYPE string40,
*              tabstrip17     TYPE string40,
*              tabstrip18     TYPE string40,
*              tabstrip19     TYPE string40,
*              tabstrip20     TYPE string40,
*              tabstrip21     TYPE string40,
*              tabstrip22     TYPE string40,
*              tabstrip23     TYPE string40,
*              tabstrip24     TYPE string40,
*              tabstrip25     TYPE string40,
*              tabstrip26     TYPE string40,
*              tabstrip27     TYPE string40,
*              tabstrip28     TYPE string40,
*              tabstrip29     TYPE string40,
*              tabstrip30     TYPE string40,
*           END OF typ_tab_30.
*
*DATA: dyn_2001 TYPE typ_tab_30.
*

TYPES:   BEGIN OF typ_dyn_4000,
              button(64),
         END OF typ_dyn_4000.

DATA:    dyn_4000            TYPE typ_dyn_4000.

**>> Table control Columns 조정용.
*DATA: gs_cols                  TYPE  cxtab_column.
*
**> 서브화면을 위한 구조.
*DATA: BEGIN OF g_tabstrip,
*        subscreen      LIKE sy-dynnr,
*        prog           LIKE sy-repid,
*        pressed_tab    LIKE sy-ucomm VALUE c_tabstrip-tab1,
*      END OF g_tabstrip.
*
*DATA: g_repid          TYPE sy-repid,
*      g_dynnr          TYPE sy-dynnr,
*      g_call_subscreen TYPE sy-dynnr,
*      g_call_prog      TYPE sy-repid,
*      g_call_button    TYPE c,
*      g_old_top_line   TYPE i          VALUE 1,
*      g_answer         TYPE c,
*      g_mode           TYPE c,
*      g_document       TYPE zmireqty,
*      g_pspnr_chk      TYPE c,
*      g_modify         TYPE c,
*      g_return_code    TYPE i,
*      g_button1        TYPE c,
*      g_level          TYPE i,
*      g_ddtext         LIKE dd07v-ddtext,
*      g_edi_screen     TYPE c,
*      g_tabix          LIKE sy-tabix,
*      g_index          LIKE sy-index,
*      g_mod            TYPE i,
*      g_count          TYPE i,
*      g_count_1        TYPE i,
*      g_line           TYPE i,
*      g_system_cnt     TYPE i,
*      g_find           TYPE i,
*      g_findscr        LIKE sy-dynnr,
*      g_findline       TYPE i,
*      g_fieldname(20)  TYPE c,
*      g_fieldgroup(12) TYPE c,
*      g_tree_mode      TYPE c,
*      g_lfa1           LIKE lfa1,
*      g_lfa1_bank      LIKE lfa1,
*      g_wrbtr_request  TYPE c,
*      g_menge_request  TYPE c,
*      g_wrbtr          LIKE zmitrqst-opamt,
*      g_dmbtr          LIKE zmitrqst-opamt,
*      g_blmngl         LIKE zmisblit-blmngl,
*      g_blmngl_1       LIKE zmisblit-blmngl,
*      g_ppamt          LIKE zmitrqst-ppamt,
*      g_meins          TYPE meins,
*      g_netwr          TYPE netwr,
*      g_bldty          TYPE zmibldty,
*      g_menget(18)     TYPE c,
*      g_wrbtr1(21)     TYPE c,
*      g_wrbtr2(21)     TYPE c,
*      g_text10(10)     TYPE c,
*      g_text12(12)     TYPE c,
*      g_text15(15)     TYPE c,
*      g_text20(20)     TYPE c,
*      g_text32(32)     TYPE c,
*      g_subrc          LIKE sy-subrc,
*      g_ucomm          LIKE sy-ucomm,
*      g_tcode          LIKE sy-tcode,
*      g_tcode1         LIKE sy-tcode,
*      ok_code          LIKE sy-ucomm,
*      ok_code_popup    LIKE sy-ucomm,
*      ok_code_old      LIKE sy-ucomm,
*      g_linen(3)       TYPE n,
*      g_out_text(70)   TYPE c.
*
*DATA: g_indxkey        LIKE indx-srtfd VALUE 'ZITTCODE',
*      gs_indx          TYPE indx.
*
**> 전표전기용.
*DATA: g_monat          LIKE bkpf-monat, "Save field for input period
*      g_flag,
*      g_egrkz          LIKE t007a-egrkz.
*
**> Change document용.
*DATA: g_objekt         LIKE cdhdr-objectclas,
*      g_objektid       LIKE cdhdr-objectid.
*
**> Button 처리용.
*TYPES:BEGIN OF typ_dyn_9998,
*        button(64),
*      END OF typ_dyn_9998.
*
*DATA: g_dyn_9998      TYPE typ_dyn_9998.
*
*
*DATA: ok-code         TYPE syucomm,
*      g_tree_init     TYPE c.
*
DATA: call_subscreen      TYPE        sy-dynnr,
      call_prog           TYPE        sy-repid,
      call_view           TYPE REF TO cl_screen_view_mm,
      call_view_stack     TYPE REF TO cl_screen_view_mm OCCURS 0,
      global_framework    TYPE REF TO cl_framework_mm,
      global_help_view    TYPE REF TO cl_screen_view_mm,
      global_help_prog    TYPE        sy-repid.


************************************************************************
* Internal Tables                                                      *
************************************************************************
**> Functions Invisible용 Internal table
*DATA: BEGIN OF ftab OCCURS 0,
*        fcode LIKE rsmpe-func,
*      END   OF ftab.
