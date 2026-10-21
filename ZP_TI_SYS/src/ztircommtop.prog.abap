************************************************************************
* Title         :  ZTIRCOMMTOP                                         *
*                                                                      *
* Description   : 수입 공용 Top Include                                *
*                 (It does not change!!!)                              *
* Creation Date : 2004/03/11                                           *
*                                                                      *
* Author        : Seog Bong, Kang                                      *
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
   DATA: l_active   TYPE mmpur_bool.
   DATA: l_visible  TYPE c.


************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
   TYPE-POOLS: slis,   "> Globale Type(ALV)
               cntl.   "> Type Controls

************************************************************************
* SAP Include Define                                                   *
************************************************************************
   INCLUDE : <icon>,   ">ASCII 코드로 리스트에 대한 아이콘 글꼴문자.
             <symbol>. ">ASCII 코드로 리스트에 대한 상징글꼴문자 할당.

************************************************************************
* Tables                                                               *
************************************************************************
   TABLES: thead,      ">유효 텍스트 오브젝트.
           ttxob,      ">유효 텍스트 오브젝트.
           ttxid,      ">유효 텍스트 ID.
           ttxit,      ">텍스트 ID의 텍스
           eket,       ">납품일정계약의 일정라인.
           ekkn,       ">구매문서 계정지정.
           t023t,      ">자재그룹내역.
           ztstedis,   ">상태레코드 (수출입 EDI).
           mepotext,   ">인라인 텍스트라인.
           ztstig0,    ">회사관련  EDI 기초자료 관리.
           ztitig00,   ">회사관련 IMG 기초관리.
           ztstig1,   ">사업장 EDI 기초자료 관리.
           ztitig02,   ">수입의뢰문서 유형 정의.
           ztstig6,    ">[TraSys] 관세청 고시 통관환율 유지보수.
           ztstig7,    ">[TraSys] 보세구역 코드.
           ztstigp,    ">선적/도착항 부호(코드)
          *ztstig3,   ">거래상대방 관리.
           ztstig3,    ">거래상대방 관리
           ztitig06,   ">수입비용코드.
           ztstig5,    ">세관코드 대한 공급업체 지정.
           ztitip1,    ">적하 보험  MAIN (APPCIV/CIPADV).
           ztitblk,    ">Bill of Lading Header table
           ztitlg1,    ">수입화물선취보증(신청)서 MAIN (LOGUAR/APPLOG).
           rbkp,       ">문서헤더: 송장수령.
           mkpf,       ">헤더: 자재문서.
           bkpf,       ">회계전표헤더.
           bseg,       ">회계전표세그멘트.
           proj,       ">프로젝트정의.
           prps,       ">WBS (작업분할구조) 요소 마스터 데이타.
           vsproj_cn,  ">버젼: 프로젝트 정의.
           aufk,       ">오더 마스터데이타.
           j_1bbranch,  ">사업장.
           tgsbt,       ">사업영역이름
           vf_kred,     ">LFA1과 LFB1에 대한 데이타베이스 뷰
           t001,        ">Company code.
           t004,        ">계정과목표 디렉토리.
           t005,        ">국가.
           t014,        ">여신관리영역.
           t043,        ">회계담당자 --> 허용그룹.
           t043t,       ">FI 종업원에 대한 허용한도그룹.
           x001,        ">파생회사코드 추가데이타.
           ttxd,        ">조세관할코드구조설명.
           t007a,       ">세금키.
           t074u,       ">특별 G/L지시자 특성.
           tbsl,        ">전기키.
           tbslt,       ">전기키이름.
           t001w,       ">Plant
           t024,        ">구매그룹.
           t024e,       ">구매조직.
           t052,        ">지급조건.
           t052u,       ">지급조건에 관한 고유설명.
           ekko,        ">Purchasing Document : Header
           ekpo,        ">Purchasing Document : Items
           lfa1,        ">구매처마스터 (일반섹션)
          *lfa1,        ">구매처마스터 (일반섹션)
           lfbk,        ">구매처 Bank.
           bnka,        ">은행마스터레코드.
           ztitgrk,     ">수입물품 입고 Header Table
           ztitivk,     ">상업송장 Header table
           t041c.       ">역분개사유.
*           ztivcs00.    ">수입비용처리 table

************************************************************************
* SAP Views                                                            *
************************************************************************
   TABLES: ztivpo00,    ">Purchasing Document : Header + Items
           ztivpo01,    ">구매오더 View(Header + Items)
        ztivrq00,    ">수입의뢰 Views(Header + Items + status):최종회차.
          ztivrq01,    ">수입의뢰 Views(Header + Items + status):회차별.
           ztivbl00,    ">수입 B/L Views(Header + Items)
           ztivcc00,    ">통관 Views
           ztivgr00,    ">입고 Views
           ztiviv00,    ">상업송장 View
           ztiviv01,    ">선급금 View
           ztiviv02,    ">상업송장 Items + B/L Header Views
           ztivpn00.    ">Notice View.

   TABLES: ztismessage, ">오류 매개변수.
           ztisscrcom.  ">수출입시스템 Screen용 Structure(공용)

   TABLES: bapi1093_0,  ">BAPI 환율테이블.
           bapicurx,    ">BAPI에 대한 외화환산모듈구조.
           bapiret1.    ">리턴매개변수

* item을 저장하기 위한 테이블.
   DATA : BEGIN OF it_po OCCURS 0,
          box        TYPE c,
          index(10)  TYPE n,
          ebeln      LIKE ekpo-ebeln,
          ebelp      LIKE ekpo-ebelp,
          menge      LIKE ekpo-menge,
          meins      LIKE ekpo-meins,
          bstyp      LIKE ekko-bstyp,
          zterm      LIKE ekko-zterm,
          frgrl      LIKE ekko-frgrl,
          bsart      LIKE ekko-bsart,
          hloekz     LIKE ekko-loekz,  ">헤더 삭제지시자.
          loekz      LIKE ekpo-loekz,  ">아이템 삭제지시자.
          elikz      LIKE ekpo-elikz,  ">납품완료 지시자.
          rqmng      LIKE ztitrqp-rqmng,
          rqmngs     LIKE ztisrqit-rqmngs,
          rqmngl     LIKE ztisrqit-rqmngl,
          END   OF it_po.

   DATA : it_po_wa   LIKE it_po.

*> 구매오더번호.
   DATA : BEGIN OF it_ponum OCCURS 0,
          ebeln      LIKE ekpo-ebeln.
   DATA : END   OF it_ponum.

*>> FUNCTION CODES FOR TABSTRIP
   CONSTANTS: BEGIN OF c_tabstrip,
                tab1 LIKE sy-ucomm VALUE 'TABSTRIP_FC1',
                tab2 LIKE sy-ucomm VALUE 'TABSTRIP_FC2',
                tab3 LIKE sy-ucomm VALUE 'TABSTRIP_FC3',
                tab4 LIKE sy-ucomm VALUE 'TABSTRIP_FC4',
                tab5 LIKE sy-ucomm VALUE 'TABSTRIP_FC5',
                tab6 LIKE sy-ucomm VALUE 'TABSTRIP_FC6',
                tab7 LIKE sy-ucomm VALUE 'TABSTRIP_FC7',
                tab8 LIKE sy-ucomm VALUE 'TABSTRIP_FC8',
                tab9 LIKE sy-ucomm VALUE 'TABSTRIP_FC9',
              END OF c_tabstrip.

*>> DATA FOR TABSTRIP 'TABSTRIP'
   CONTROLS:  tabstrip TYPE TABSTRIP.

*>> Table control Columns 조정용.
   DATA: gs_cols                  TYPE  cxtab_column.

*> 서브화면을 위한 구조.
   DATA:      BEGIN OF g_tabstrip,
                subscreen   LIKE sy-dynnr,
                prog        LIKE sy-repid,
                pressed_tab LIKE sy-ucomm VALUE c_tabstrip-tab1,
              END OF g_tabstrip.

*> 상수들 정의.
   CONSTANTS: c_column1(1)        TYPE c               VALUE '1',
              c_column2(1)        TYPE c               VALUE '2',
              c_header(1)         TYPE c               VALUE 'H',
              c_textedit          LIKE mepotext-editor VALUE '1',
              c_inline            LIKE mepotext-editor VALUE '2',
              c_sapscript         LIKE mepotext-editor VALUE '3',
              c_common_prog       LIKE sy-repid
                                  VALUE 'SAPLZ_TI_COMMON_FUNCTIONS',
              c_text_prog         LIKE sy-repid
                                  VALUE 'SAPLZ_TS_WORD_PROCESSING'.
*> Text Editor를 위한 구조.
   DATA: BEGIN OF gt_control OCCURS 0,
           object         LIKE ttxob-tdobject,
           tree_handle    TYPE cntl_handle,
           current_node   LIKE treev_node-node_key,
           previous_node  LIKE treev_node-node_key,
           editor_type    LIKE mepotext-editor,
           editor_handle  TYPE REF TO cl_gui_textedit,
*        event_receiver TYPE REF TO lcl_event_receiver,
           items          TYPE STANDARD TABLE OF mtreeitm
                               INITIAL SIZE 0,
           texttypes      TYPE mmpur_texttypes OCCURS 0,
           textlines      TYPE mmpur_textlines OCCURS 0,
           textlines_ch   TYPE mmpur_textlines OCCURS 0,
           dynnr          TYPE sydynnr,
           doubleclick    TYPE xfeld,
           ignore_okcode  TYPE xfeld,
         END OF gt_control.

*> Text Editor를 위한 변수.
   DATA: g_textobject        LIKE ttxob-tdobject,
         g_textid            LIKE ttxid-tdid,
         g_doctype           LIKE ekko-bstyp,
         g_textname          LIKE thead-tdname,
         g_okcode            LIKE sy-ucomm,
         g_editor_screen     LIKE sy-dynnr,
         gs_proj             LIKE proj,
         gs_vsproj_cn        LIKE vsproj_cn,
         g_item_no           LIKE ekpo-ebelp,
         g_previous_node     LIKE treev_node-node_key.

***************************************************************
* 20080709 simcho by 박혁세K
* 수입개설 명의인 주소 저장 변수
***************************************************************
   DATA : g_eoad1(35),
          g_eoad2(35),
          g_telno(35).

*> Text data를 저장하는 Internal table.
   DATA: BEGIN OF it_line OCCURS 0.
           INCLUDE STRUCTURE tline.
   DATA: END   OF it_line.

*> Text ID를 저장하는 Internal table.
   DATA: BEGIN OF xttxid OCCURS 0.
           INCLUDE STRUCTURE ttxid.
   DATA: END   OF xttxid.

*> 구매오더: 텍스트편집기 사용.
   DATA: g_editor LIKE mepotext-editor.

*> 전체 ID를 저장하기 위한 구조.
   DATA: gt_inline_header LIKE mepotext OCCURS 0 WITH HEADER LINE.

*> 상수 정의(Screen Number).
   CONSTANTS:c_scr0100 LIKE sy-dynnr VALUE '0100', ">text screen Header
             c_scr0101 LIKE sy-dynnr VALUE '0101', ">text screen Header
             c_scr0120 LIKE sy-dynnr VALUE '0120', ">text screen Items
             c_scr0200 LIKE sy-dynnr VALUE '0200', ">text screen Items
             c_scr0300 LIKE sy-dynnr VALUE '0300', ">text screen Items
             c_scr0400 LIKE sy-dynnr VALUE '0400', ">text screen Items
             c_scr2000 LIKE sy-dynnr VALUE '2000', ">Main screen Level 1
            c_scr2100 LIKE sy-dynnr VALUE '2100', ">Main screen  Level 2
            c_scr2101 LIKE sy-dynnr VALUE '2101', ">Main screen  Level 2
           c_scr2110 LIKE sy-dynnr VALUE '2110', ">Header        Level 3
           c_scr2111 LIKE sy-dynnr VALUE '2111', ">Header        Level 3
           c_scr2120 LIKE sy-dynnr VALUE '2120', ">Header Tab    Level 3
          c_scr2121 LIKE sy-dynnr VALUE '2121', ">Header Detail  Level 4
          c_scr2122 LIKE sy-dynnr VALUE '2122', ">Header Detail  Level 4
          c_scr2123 LIKE sy-dynnr VALUE '2123', ">Header Detail  Level 4
          c_scr2124 LIKE sy-dynnr VALUE '2124', ">Header Detail  Level 4
          c_scr2125 LIKE sy-dynnr VALUE '2125', ">Header Detail  Level 4
          c_scr2126 LIKE sy-dynnr VALUE '2126', ">Header Detail  Level 4
          c_scr2127 LIKE sy-dynnr VALUE '2127', ">Header Detail  Level 4
          c_scr2128 LIKE sy-dynnr VALUE '2128', ">Header Detail  Level 4
          c_scr2129 LIKE sy-dynnr VALUE '2129', ">Header Detail  Level 4
           c_scr2130 LIKE sy-dynnr VALUE '2130', ">Item   tab    Level 3
          c_scr2131 LIKE sy-dynnr VALUE '2131', ">Item   Detail  Level 4
          c_scr2132 LIKE sy-dynnr VALUE '2132', ">Item   Detail  Level 4
          c_scr2133 LIKE sy-dynnr VALUE '2133', ">Item   Detail  Level 4
          c_scr2134 LIKE sy-dynnr VALUE '2134', ">Item   Detail  Level 4
          c_scr2135 LIKE sy-dynnr VALUE '2135', ">Item   Detail  Level 4
          c_scr2136 LIKE sy-dynnr VALUE '2136', ">Item   Detail  Level 4
          c_scr2137 LIKE sy-dynnr VALUE '2137', ">Item   Detail  Level 4
          c_scr2138 LIKE sy-dynnr VALUE '2138', ">Item   Detail  Level 4
          c_scr2139 LIKE sy-dynnr VALUE '2139', ">Item   Detail  Level 4
           c_scr2140 LIKE sy-dynnr VALUE '2140', ">Item   table  Level 3
           c_scr2141 LIKE sy-dynnr VALUE '2141', ">Item   table  Level 3
           c_scr2142 LIKE sy-dynnr VALUE '2142', ">Item   table  Level 3
           c_scr2143 LIKE sy-dynnr VALUE '2143', ">Item   table  Level 3
           c_scr2144 LIKE sy-dynnr VALUE '2144', ">Item   table  Level 3
           c_scr2145 LIKE sy-dynnr VALUE '2145', ">Item   table  Level 3
           c_scr2146 LIKE sy-dynnr VALUE '2146', ">Item   table  Level 3
           c_scr2147 LIKE sy-dynnr VALUE '2147', ">Item   table  Level 3
           c_scr2148 LIKE sy-dynnr VALUE '2148', ">Item   table  Level 3
           c_scr2149 LIKE sy-dynnr VALUE '2149', ">Item   table  Level 3
             c_scr2200 LIKE sy-dynnr VALUE '2200', ">EDI screen Level 1

           c_scr2210 LIKE sy-dynnr VALUE '2210', ">EDI screen Level 2:LC
           c_scr2211 LIKE sy-dynnr VALUE '2211', ">EDI screen Level 2:LC
           c_scr2212 LIKE sy-dynnr VALUE '2212', ">EDI screen Level 2:LC
           c_scr2213 LIKE sy-dynnr VALUE '2213', ">EDI screen Level 2:LC
           c_scr2214 LIKE sy-dynnr VALUE '2214', ">EDI screen Level 2:LC
           c_scr2215 LIKE sy-dynnr VALUE '2215', ">EDI screen Level 2:LC
           c_scr2216 LIKE sy-dynnr VALUE '2216', ">EDI screen Level 2:LC
           c_scr2217 LIKE sy-dynnr VALUE '2217', ">EDI screen Level 2:LC
           c_scr2218 LIKE sy-dynnr VALUE '2218', ">EDI screen Level 2:LC
           c_scr2219 LIKE sy-dynnr VALUE '2219', ">EDI screen Level 2:LC

           c_scr2220 LIKE sy-dynnr VALUE '2220', ">EDI screen Level 2:PU
           c_scr2230 LIKE sy-dynnr VALUE '2230', ">EDI screen Level 2:LO
           c_scr2235 LIKE sy-dynnr VALUE '2235', ">EDI screen Level 2:LO
           c_scr2240 LIKE sy-dynnr VALUE '2240', ">EDI screen Level 2:TT
           c_scr6000 LIKE sy-dynnr VALUE '6000', ">차입생성화면.
           c_scr7000 LIKE sy-dynnr VALUE '7000', ">배부화면.
           c_scr9998 LIKE sy-dynnr VALUE '9998', ">button screen
           c_scr9999 LIKE sy-dynnr VALUE '9999', ">Dummy screen  Level 3
           c_scr2065 LIKE sy-dynnr VALUE '2065'. ">EDI TEXT SUB SCREEN

*> 상수 정의(문자집합).
   CONSTANTS:
              c_chara     TYPE c        VALUE 'A',
              c_charb     TYPE c        VALUE 'B',
              c_charc     TYPE c        VALUE 'C',
              c_chard     TYPE c        VALUE 'D',
              c_chare     TYPE c        VALUE 'E',
              c_charf     TYPE c        VALUE 'F',
              c_charg     TYPE c        VALUE 'G',
              c_charh     TYPE c        VALUE 'H',
              c_chari     TYPE c        VALUE 'I',
              c_charj     TYPE c        VALUE 'J',
              c_chark     TYPE c        VALUE 'K',
              c_charl     TYPE c        VALUE 'L',
              c_charm     TYPE c        VALUE 'M',
              c_charn     TYPE c        VALUE 'N',
              c_charo     TYPE c        VALUE 'O',
              c_charp     TYPE c        VALUE 'P',
              c_charq     TYPE c        VALUE 'Q',
              c_charr     TYPE c        VALUE 'R',
              c_chars     TYPE c        VALUE 'S',
              c_chart     TYPE c        VALUE 'T',
              c_charu     TYPE c        VALUE 'U',
              c_charv     TYPE c        VALUE 'V',
              c_charw     TYPE c        VALUE 'W',
              c_charx     TYPE c        VALUE 'X',
              c_chary     TYPE c        VALUE 'Y',
              c_charz     TYPE c        VALUE 'Z',
              c_char0     TYPE c        VALUE '0',
              c_char1     TYPE c        VALUE '1',
              c_char2     TYPE c        VALUE '2',
              c_char3     TYPE c        VALUE '3',
              c_char4     TYPE c        VALUE '4',
              c_char5     TYPE c        VALUE '5',
              c_char6     TYPE c        VALUE '6',
              c_char7     TYPE c        VALUE '7',
              c_char8     TYPE c        VALUE '8',
              c_char9     TYPE c        VALUE '9',
              c_char*     TYPE c        VALUE '*',
              c_char$     TYPE c        VALUE '$',
              c_char-     TYPE c        VALUE '-',
              c_char_plus TYPE c        VALUE '+'.

   CONSTANTS: c_true      TYPE c        VALUE 'X',
              c_false     TYPE c        VALUE space,
              c_error     TYPE c        VALUE 'E',
              c_warning   TYPE c        VALUE 'W',
              c_success   TYPE c        VALUE 'S',
              c_info      TYPE c        VALUE 'I',
              c_abend     TYPE c        VALUE 'A',
              c_none      TYPE c        VALUE 'N',
              c_lock      TYPE c        VALUE 'L',
              c_unlock    TYPE c        VALUE 'U',
              c_zero      TYPE i        VALUE 0,
              c_one       TYPE i        VALUE 1,
              c_bstypf    TYPE bstyp    VALUE 'F',
              c_bstypl    TYPE bstyp    VALUE 'L',
              c_lc        TYPE ztireqty VALUE 'LC',  ">Master L/C
              c_lo        TYPE ztireqty VALUE 'LO',  ">Local L/C
              c_pu        TYPE ztireqty VALUE 'PU',  ">구매확인서.
              c_tt        TYPE ztireqty VALUE 'TT',  ">전신환송금.
              c_da        TYPE ztireqty VALUE 'DA',  ">D/A
              c_dp        TYPE ztireqty VALUE 'DP',  ">D/P
              c_zz        TYPE ztireqty VALUE 'ZZ',  ">기타.
              c_bl        TYPE ztireqty VALUE 'BL',  ">선적서류.
              c_iv        TYPE ztireqty VALUE 'IV',  ">상업송장.
              c_ip        TYPE ztireqty VALUE 'IP',  ">적하보험.
              c_lg        TYPE ztireqty VALUE 'LG',  ">L/G
              c_cr        TYPE ztireqty VALUE 'CR',  ">수입신고의뢰.
              c_cc        TYPE ztireqty VALUE 'CC',  ">수입면허필증.
              c_gr        TYPE ztireqty VALUE 'GR',  ">입고.
              c_pn        TYPE ztireqty VALUE 'PN',  ">Notice
              c_bs        TYPE ztireqty VALUE 'BS',  ">반입예정정보.
              c_bi        TYPE ztireqty VALUE 'BI',  ">반입정보.
              c_bo        TYPE ztireqty VALUE 'BO',  ">반출정보.
              c_bd        TYPE ztireqty VALUE 'BD',  ">보세구역반출.
              c_cs        TYPE ztireqty VALUE 'CS',  ">비용문서.
              c_va        TYPE ztireqty VALUE 'VA',  ">세금계산서.
              c_ac        TYPE ztireqty VALUE 'AC',  ">인수증.
              c_tx        TYPE ztireqty VALUE 'TX',  ">기납증.
              c_blart     TYPE blart    VALUE 'RE',
              c_mwskz     TYPE mwskz    VALUE 'PP',
              c_zlspr     TYPE dzlspr   VALUE 'A',
** 진로산업 Change 2007/04 --------------------------------------
*              c_bukrs     TYPE bupla    VALUE '1100',
** 진로산업 Change 2007/04 --------------------------------------
              c_bupla     TYPE bupla    VALUE '1000',
              c_gsber1    TYPE gsber    VALUE '1000',
              c_gsber2    TYPE gsber    VALUE '2000',
              c_locrct_r  TYPE tdsfname VALUE
                                       'Z_TI_LOCRCT',
              c_app700_r  TYPE tdsfname VALUE
                                       'Z_TI_APP700_PRINT_OF_REQUEST',
              c_inf700_r  TYPE tdsfname VALUE
                                       'Z_TI_INF700_PRINT_OF_REQUEST',
              c_app707_r  TYPE tdsfname VALUE
                                       'Z_TI_APP707_PRINT_OF_REQUEST',
              c_inf707_r  TYPE tdsfname VALUE
                                       'Z_TI_INF707_PRINT_OF_REQUEST',
              c_locapp_r  TYPE tdsfname VALUE
                                       'Z_TI_LOCAPP_PRINT_OF_REQUEST',
              c_locadv_r  TYPE tdsfname VALUE
                                       'Z_TI_LOCADV_PRINT_OF_REQUEST',
              c_locamr_r  TYPE tdsfname VALUE
                                       'Z_TI_LOCAMR_PRINT_OF_REQUEST',
              c_locama_r  TYPE tdsfname VALUE
                                       'Z_TI_LOCAMA_PRINT_OF_REQUEST',
              c_apppcr_r  TYPE tdsfname VALUE
                                       'Z_TI_APPPCR_PRINT_OF_REQUEST',
              c_payord_r  TYPE tdsfname VALUE
                                       'Z_TI_PAYORD_PRINT_OF_REQUEST',
              c_debadv_r  TYPE tdsfname VALUE
                                       'Z_TI_DEBADV_PRINT_OF_REQUEST',
              c_pcrlic_r  TYPE tdsfname VALUE
                                       'Z_TI_PCRLIC_PRINT_OF_REQUEST',
              c_loguar_r  TYPE tdsfname VALUE
                                       'Z_TI_LOGUAR_PRINT_OF_REQUEST',
              c_logua1_r  TYPE tdsfname VALUE
                                       'Z_TI_LOGUAR_PRINT_OF_REQUEST1',
              c_applog_r  TYPE tdsfname VALUE
                                       'Z_TI_APPLOG_PRINT_OF_REQUEST',
              c_applo1_r  TYPE tdsfname VALUE
                                       'Z_TI_APPLOG_PRINT_OF_REQUEST1',
              c_release_r  TYPE tdsfname VALUE
                                       'Z_TI_RELEASE_NOTE',
*&  2010.06.10 EDI문서 출력 영문양식 추가
              c_debadv2_r  TYPE tdsfname VALUE
                                       'Z_TI_DEBADV_PRINT_OF_REQUEST2',
              c_inf7002_r  TYPE tdsfname VALUE
                                       'Z_TI_INF700_PRINT_OF_REQUEST2',
*&  2026.07.13 가온전용 양식추가
              c_inf7003_r  TYPE tdsfname VALUE
                                       'Z_TI_INF700_PRINT_OF_REQUEST3',
              c_ocean     TYPE ztifwdty VALUE 'O',
              c_air       TYPE ztifwdty VALUE 'A',
              c_etc       TYPE ztifwdty VALUE 'Z',
              c_y         TYPE c        VALUE 'Y',
              c_n         TYPE c        VALUE 'N',
              c_a         TYPE c        VALUE 'A',
              c_after     TYPE ztianbty VALUE 'A',  ">사전.
              c_before    TYPE ztianbty VALUE 'B'.  ">사후.

   DATA: BEGIN OF ftab OCCURS 0,
           fcode LIKE rsmpe-func,
         END   OF ftab.

   DATA : g_texttypes LIKE mmpur_texttypes OCCURS 0 WITH HEADER LINE,
          g_textlines LIKE mmpur_textlines OCCURS 0 WITH HEADER LINE.

   DATA: it_texttypes   TYPE mmpur_t_texttypes,
         it_textlines   TYPE mmpur_t_textlines,
         it_all_lines   TYPE mmpur_t_textlines.

   DATA: g_call_subscreen TYPE sy-dynnr,
         g_call_prog      TYPE sy-repid,
         g_call_button    TYPE c,
         g_subviews       TYPE mmpur_subviews,
         g_class_view     LIKE LINE OF g_subviews,
         g_ncr_obkey      LIKE swotobjid-objkey,
         g_ncr_objtype    LIKE swotobjid-objtype,
         g_old_top_line   TYPE i          VALUE 1,
         g_answer_dist    TYPE c,
         g_answer         TYPE c,
         g_edi_answer     TYPE c,
         g_mode           TYPE c,
         g_display1       TYPE c,
         g_document       TYPE ztireqty,
         g_edi_func(30)   TYPE c,
         g_pspnr_chk      TYPE c,
         g_document_type(20),
         g_docno          TYPE char10,
         g_modify         TYPE c,
         g_return_code    TYPE i,
         g_button1        TYPE c,
         g_level          TYPE i,
         g_ddtext         LIKE dd07v-ddtext,
         g_edi_screen     TYPE c,
         g_tabix          LIKE sy-tabix,
         g_tabix1         LIKE sy-tabix,
         g_index          LIKE sy-index,
         g_mod            TYPE i,
         g_count          TYPE i,
         g_count_1        TYPE i,
         g_line           TYPE i,
         g_system_cnt     TYPE i,
         g_find           TYPE i,
         g_findscr        LIKE sy-dynnr,
         g_findline       TYPE i,
         g_fieldname(20)  TYPE c,
         g_fieldgroup(12) TYPE c,
         g_zterm_modify   TYPE c,
         g_tree_mode      TYPE c,
         g_fcode_dropped  TYPE sysuuid_c,
         g_table_model    TYPE REF TO cl_table_model_mm,
         w_lfa1           LIKE lfa1,
         w_lfa1_bank      LIKE lfa1,
         g_wrbtr_request  TYPE c,
         g_menge_request  TYPE c,
         g_wrbtr          LIKE ztitrqs-opamt,
         g_refwr          LIKE ztitpnp-refwr,
         g_dmbtr          LIKE ztitrqs-opamt,
         g_blmngl         LIKE ztisblit-blmngl,
         g_blmngl_1       LIKE ztisblit-blmngl,
         g_ppamt          LIKE ztitrqs-ppamt,
         g_meins          TYPE meins,
         g_netwr          TYPE netwr,
         g_bldty          TYPE ztibldty,
         g_menget(18)     TYPE c,
         g_wrbtr1(21)     TYPE c,
         g_wrbtr2(21)     TYPE c,
         g_text10(10)     TYPE c,
         g_text12(12)     TYPE c,
         g_text15(15)     TYPE c,
         g_text20(20)     TYPE c,
         g_text32(32)     TYPE c,
         g_subrc          LIKE sy-subrc,
         g_ucomm          LIKE sy-ucomm,
         g_tcode          LIKE sy-tcode,
         g_tcode1         LIKE sy-tcode,
         ok_code          LIKE sy-ucomm,
         ok_code_popup    LIKE sy-ucomm,
         ok_code_old      LIKE sy-ucomm,
         g_rblgp          TYPE rblgp,
         g_linen(3)       TYPE n,
         g_out_text(70)   TYPE c,
         g_msg01(300),
         g_msg02(300),
         g_check.   "로컬LC, 구매확인서 식별자포함여부체크 구분자

   DATA: g_indxkey        LIKE indx-srtfd VALUE 'ZTITCODE',
         gs_indx          TYPE indx.

*> 전표전기용.
   DATA: g_monat          LIKE bkpf-monat, "Save field for input period
         g_flag,
         g_egrkz          LIKE t007a-egrkz.

*> Change document용.
   DATA: g_objekt         LIKE cdhdr-objectclas,
         g_objektid       LIKE cdhdr-objectid.

   TYPES:   BEGIN OF typ_dyn_9998,
                 button(64),
            END OF typ_dyn_9998.

   DATA:    g_dyn_9998      TYPE typ_dyn_9998.


   DATA: ok-code          TYPE syucomm,
         tree_init        TYPE c.

*> ALV용 변수 선언.
   CONSTANTS:
         c_save(1)        TYPE  c              VALUE 'A',
         c_top_of_page    TYPE  slis_formname  VALUE 'TOP_OF_PAGE',
         c_pf_status_set  TYPE  slis_formname  VALUE 'SET_STATUS',
         c_user_command   TYPE  slis_formname  VALUE 'USER_COMMAND'.

*> 구매오더번호 추가용.
   DATA : BEGIN OF it_pokey OCCURS 0.
           INCLUDE STRUCTURE ztispokey.
   DATA : END   OF it_pokey.

*> 변경이력용.
   DATA: BEGIN OF it_amend_fields  OCCURS 0.
           INCLUDE STRUCTURE ztisamendfid.
   DATA: END   OF it_amend_fields.

   DATA: BEGIN OF it_dd07t         OCCURS 0.
           INCLUDE STRUCTURE dd07t.
   DATA: END   OF it_dd07t.

*---------------------------------------------------------------------*
*> SAP SMARTFORM
*---------------------------------------------------------------------*
   DATA: g_ssf_name             TYPE tdsfname,
         g_func_mod_name        TYPE rs38l_fnam,
         g_output_options       TYPE ssfcompop,
         g_control_parameters   TYPE ssfctrlop.

   DATA: g_mail_recipient       LIKE  swotobjid,
         g_mail_sender          LIKE  swotobjid,
         g_mail_appl_obj        LIKE  swotobjid,
         g_document_output_info TYPE  ssfcrespd,
         g_job_output_info      TYPE  ssfcrescl,
         g_job_output_options   TYPE  ssfcresop,
*      g_ip_mailaddr          TYPE  ppfdmailad,
         g_ip_mailaddr          TYPE  so_name,
         g_param                LIKE  ssfpp.

   DATA : g_cnt                 TYPE i,
          g_index_cnt           TYPE count,
          g_addr1_val           LIKE addr1_val,
          g_close_flag(1),
          g_open_flag(1),
          g_lines               LIKE tline OCCURS 1 WITH HEADER LINE,
          g_name                LIKE thead-tdname,
          g_tddevice            TYPE tddevice,
          page_flag(1).

   DATA : BEGIN OF it_prtctl  OCCURS 0.
           INCLUDE STRUCTURE ztisprtctl.
   DATA : END   OF it_prtctl.

   DATA : BEGIN OF it_ztsprtctl  OCCURS 0.
           INCLUDE STRUCTURE ztssprtctl.
   DATA : END   OF it_ztsprtctl.

*>[Export] Output document shedding of blood justice
   DATA : BEGIN OF it_prt_doc  OCCURS 0.
           INCLUDE STRUCTURE ztss_prt_documents.
   DATA : END   OF it_prt_doc.


*> pdf file
   CONSTANTS: c_acrobat_reader_key(64) TYPE c VALUE
                                       'SOFTWARE\ADOBE\ACROBAT\EXE',
              c_printer                TYPE tddevice VALUE 'PRINTER',
              c_screen                 TYPE tddevice VALUE 'SCREEN',
              c_telefax                TYPE tddevice VALUE 'TELEFAX',
              c_mail                   TYPE tddevice VALUE 'MAIL',
              c_pdf                    TYPE tddevice VALUE 'PDF',
              c_url(30)                TYPE c        VALUE
                                       '@ustcax00.kcc.com'.

   DATA: g_pdf                         TYPE STANDARD TABLE OF tline,
         g_size                        TYPE i,
         g_reg_value(128)              TYPE c.

   DATA: g_mail_appl_obj_tab           TYPE TABLE OF swotobjid
                                            WITH HEADER LINE.

*----------------------------------------------------------------------
*> Docking Container
*----------------------------------------------------------------------
   DATA docking TYPE REF TO cl_gui_docking_container.

   DATA g_init    TYPE c.
   DATA g_repid   TYPE sy-repid.
   DATA g_dynnr   TYPE sy-dynnr.

*---------------------------------------------------------------------*
*     Tree Control                                                    *
*---------------------------------------------------------------------*
   TABLES : mtreesnode_ft.

   CONSTANTS: line_length    TYPE i VALUE 256.

   DATA : gv_xthead_updkz    TYPE i.
   CLASS lcl_application     DEFINITION DEFERRED.
   CLASS cl_gui_cfw          DEFINITION LOAD.
   CLASS cl_gui_column_tree  DEFINITION LOAD.

   TYPES: item_table_type    LIKE STANDARD TABLE OF mtreeitm
                                                 WITH DEFAULT KEY.

   DATA: node                TYPE treev_node,
         item                TYPE mtreeitm.
   DATA: node_table          TYPE treev_ntab,
         item_table          TYPE item_table_type.

   DATA: g_grid              TYPE REF TO cl_gui_alv_grid,
         g_ok_code           TYPE        sy-ucomm.

* Fields on Dynpro
   DATA:   g_event(30),
           g_node_key        TYPE tv_nodekey,
           g_node_key_old    TYPE tv_nodekey,
           g_node_key_new    TYPE tv_nodekey,
           g_node_key_all    TYPE tv_nodekey,
           g_item_name       TYPE tv_itmname,
           g_header_name     TYPE tv_hdrname.

*-----------------------------------------------------------------------
*> 수입이력관련.
*-----------------------------------------------------------------------
   TABLES : ztisdochis.

   DATA: it_dochis      LIKE ztisdochis  OCCURS 0 WITH HEADER LINE,
         it_costdoc     LIKE ztiscostdoc OCCURS 0 WITH HEADER LINE,
         g_history      TYPE c,
         g_history_post TYPE c,
         g_history_cost TYPE c,
         g_tree_handle  TYPE cntl_handle.


   DATA : gv_recno LIKE ztitrqs-recno.

***********************************************************************
* FIELD-SYMBOLS
***********************************************************************
   FIELD-SYMBOLS: <sortfield>.

************************************************************************
* Internal Tables                                                      *
************************************************************************
   DATA: it_fieldcat        TYPE slis_t_fieldcat_alv.
   DATA: it_xheader         TYPE slis_t_listheader     WITH HEADER LINE.
   DATA: it_color           TYPE slis_t_specialcol_alv WITH HEADER LINE.
   DATA: it_sort            TYPE slis_t_sortinfo_alv.
   DATA: it_gruppen         TYPE slis_t_sp_group_alv   WITH HEADER LINE.
   DATA: it_events          TYPE slis_t_event.
   DATA: it_event_exit      TYPE slis_t_event_exit     WITH HEADER LINE.
   DATA: it_listheader      TYPE slis_t_listheader.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
   DATA: gs_keyinfo          TYPE slis_keyinfo_alv.
   DATA: gs_layout           TYPE slis_layout_alv.
   DATA: gs_print            TYPE slis_print_alv.
   DATA: gs_selfield         TYPE slis_selfield.
   DATA: gs_fieldcat         TYPE slis_fieldcat_alv.
   DATA: gs_color_info       TYPE slis_specialcol_alv.
   DATA: gs_listheader       TYPE slis_listheader.

   DATA: gs_variante         LIKE disvariant,
         gs_def_variante     LIKE disvariant,
         g_variant_exit(1)   TYPE c,
         g_variant_save(1)   TYPE c,
         g_variant_def(1)    TYPE c.


************************************************************************
* WorkFlow Event용                                                     *
************************************************************************
   DATA: objtype         LIKE swetypecou-objtype,
         objkey          LIKE sweinstcou-objkey,
         event           LIKE swetypecou-event,
         event_id        LIKE swedumevid-evtid,
         event_container LIKE swcont OCCURS 0 WITH HEADER LINE.


************************************************************************
* search help를 위한 변수                                              *
************************************************************************
   DATA : g_selectfield  LIKE  help_info-fieldname,
         g_fld_tab      LIKE  help_value      OCCURS 1 WITH HEADER LINE,
          g_select_value LIKE  help_info-fldvalue,
          g_ld_tabix     LIKE  sy-tabix,
         g_scr_fields   LIKE  dynpread        OCCURS 0 WITH HEADER LINE.

************************************************************************
* Message 처리를 위한 Macro                                            *
************************************************************************
   DATA: g_dummy(72).

   DEFINE zti_message.
     g_tabix = sy-tabix.
     g_subrc = sy-subrc.

     message id &2 type &1 number &3 with &4 &5 &6 &7 into g_dummy.

     call method cl_message_mm=>create
       exporting
         im_msgid         = &2
         im_msgty         = &1
         im_msgno         = &3
         im_msgv1         = sy-msgv1
         im_msgv2         = sy-msgv2
         im_msgv3         = sy-msgv3
         im_msgv4         = sy-msgv4
         im_force_collect = c_true
       exceptions
         failure          = 01
         dialog           = 02.
     if sy-subrc = 1 or sy-subrc = 2.
       message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

     endif.
     sy-subrc = g_subrc.
     sy-tabix = g_tabix.

   END-OF-DEFINITION.

*>> [CHM2402-00485] Banker's usance 차입원금 전기일 수작업 입력 (240327, 김예슬)
DATA : P_DBLFZ LIKE VDARL-DBLFZ.
*<< [CHM2402-00485] Banker's usance 차입원금 전기일 수작업 입력 (240327, 김예슬)
