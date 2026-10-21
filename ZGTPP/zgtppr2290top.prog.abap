*&--------------------------------------------------------------------*
*& Include          ZGTPPR2290TOP
*&--------------------------------------------------------------------*
*---------------------------------------------------------------------*
* TABLES
*---------------------------------------------------------------------*
TABLES : aufk, zedt0011, zgtppt2010, afpo, resb, afko, zppt0107, t001w,
         crhd, zgtsdt1103.

*---------------------------------------------------------------------*
* CONSTANTS
*---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TYPES                                                                *
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_s_result,
         sel     TYPE sy-tabix,
         total   TYPE sy-tabix,
         success TYPE sy-tabix,
         error   TYPE sy-tabix,
         invalid TYPE abap_bool,
         message TYPE char100,
       END OF ty_s_result.

TYPES: BEGIN OF ty_s_schedule,
         field TYPE string,
         gstrp TYPE afko-gstrp,
         gltrp TYPE afko-gltrp,
       END OF ty_s_schedule.

*---------------------------------------------------------------------*
* DATA: Variable
*---------------------------------------------------------------------*
DATA: gv_ok_code  LIKE sy-ucomm,
      gv_ok_code2 LIKE sy-ucomm,
      gv_ok_code3 LIKE sy-ucomm,
      gv_ok_code4 LIKE sy-ucomm,
      gv_ok_code5 LIKE sy-ucomm,
      gv_ok_code6 LIKE sy-ucomm,
      gv_error,
      gv_ok,
      gv_stop,
      gv_answer   TYPE c.

DATA : gv_cnt(2),
       gv_cnt2(2),
       gv_cnt3(2).

DATA : gv_message(100),
       gv_message2(100).

DATA : gv_all(2),
       gv_yes(2),
       gv_no(2).

DATA : gv_matkl  LIKE mara-matkl,
       gv_matkl2 LIKE mara-matkl,
       gv_matnr  LIKE mara-matnr,
       gv_matnr2 LIKE mara-matnr,
       gv_matnr3 LIKE mara-matnr,
       gv_matnr4 LIKE mara-matnr,
       gv_maktx3 LIKE makt-maktx,
       gv_maktx4 LIKE makt-maktx,
       gv_mandt  LIKE sy-mandt,
*- Start 2025.06.02
       gv_menge  LIKE bapi_pp_order_create-quantity,
*- End 2025.06.02
       gv_jobs   TYPE i.

DATA : gv_s_day LIKE sy-datum,
       gv_e_day LIKE sy-datum.

DATA : gv_zzorigin LIKE aufk-zzorigin,
       gv_aufnr    LIKE aufk-aufnr.

CONSTANTS : gc_l TYPE c VALUE 'L',
            gc_x TYPE c VALUE 'X'.

RANGES : gr_dispo FOR zgtcvordsyval-dispo.

*---------------------------------------------------------------------*
* DATA: Structure. (Field strings : Working area)
*---------------------------------------------------------------------*
* 생산 오더 관련
DATA : BEGIN OF gs_aufnr,
         werks        LIKE zgtcvordsyval-werks,        "// 플랜트
         pdcaproccode LIKE zgtcvordsyval-pdcaproccode, "// 공정
         pdcaprocname LIKE zgtcvordsyval-pdcaprocname, "// 공정명
         auart        LIKE zgtcvordsyval-auart,        "// 오더유형
         aufnr        LIKE zgtcvordsyval-aufnr,        "// 생산오더
         gstrp        LIKE zgtcvordsyval-gstrp,        "// 시작일
         gltrp        LIKE zgtcvordsyval-gltrp,        "// 종료일
         gamng        LIKE zgtcvordsyval-gamng,        "// 오더수량
         meins        LIKE zgtcvordsyval-meins,        "// 단위
         matnr        LIKE zgtcvordsyval-matnr,        "// 생산자재
         maktx        LIKE zgtcvordsyval-maktx,        "// 자재명
         zzorigin     LIKE zgtcvordsyval-zzorigin,     "// Origin
         grpnr        LIKE zgtppt2000-grpnr,           "// 조장구성표
         kdauf        LIKE zgtppt2010-dmord,           "// 주문번호
         kdpos        LIKE zgtcvordsyval-kdpos,        "// 주문품목
         kunnr        LIKE zgtcvordsyval-kunnr,        "// 판매처
         name1        LIKE zgtcvordsyval-name1,        "// 판매처명
         ktext        LIKE zgtcvordsyval-ktext,        "// 작업설비
         terkz        LIKE zgtcvordsyval-terkz,        "// 일정 계획 유형
         cuobj        LIKE zgtcvordsyval-cuobj,
       END OF gs_aufnr.
* 공정코드 테이블( 조정표 번호 )
DATA : gs_2010 LIKE zgtppt2010.
* 투입 자재 관련
DATA : gs_resb LIKE resb.
* 생산 오더 상태 관련
DATA : BEGIN OF gs_status,
         aufnr      LIKE afko-aufnr,
         stat(4),
         stat_t(10),
       END OF gs_status.
* Display 관련
DATA : BEGIN OF gs_disp,
         werks         LIKE zgtcvordsyval-werks,        "// 플랜트
         pdcaproccode  LIKE zgtcvordsyval-pdcaproccode, "// 공정
         pdcaprocname  LIKE zgtcvordsyval-pdcaprocname, "// 공정명
         auart         LIKE zgtcvordsyval-auart,        "// 오더유형
         aufnr         LIKE zgtcvordsyval-aufnr,        "// 생산오더
         stat_t(10),                                    "// 오더상태
         schpl(1),                                      "// 일정수립
         gstrp         LIKE zgtcvordsyval-gstrp,        "// 시작일
         gltrp         LIKE zgtcvordsyval-gltrp,        "// 종료일
         gamng         LIKE zgtcvordsyval-gamng,        "// 오더수량
         meins         LIKE zgtcvordsyval-meins,        "// 단위
         matnr         LIKE zgtcvordsyval-matnr,        "// 생산자재
         color(10),                                     "// 색상
         maktx         LIKE zgtcvordsyval-maktx,        "// 자재명
         ktext         LIKE zgtcvordsyval-ktext,        "// 작업설비
         scope(10),                                     "// 소요범주
         grpnr         LIKE zgtppt2000-grpnr,           "// 조장구성표
         zzyuscd       LIKE zgtsdt1103-zzyuscd,         "// 영업소
         kdauf         LIKE zgtppt2010-dmord,           "// 주문번호
         kdpos         LIKE zgtcvordsyval-kdpos,        "// 주문품목
         kunnr         LIKE zgtcvordsyval-kunnr,        "// 판매처
         name1         LIKE zgtcvordsyval-name1,        "// 판매처명
         char(4),                                       "// 자재 특성
         orrmk(4),                                      "// 주문특기사항
         wkrmk(4),                                      "// 작업특기사항
         zzorigin      LIKE zgtcvordsyval-zzorigin,     "// Origin
         result(4),                                     "// 처리 상태
         bapi_msg(100),                                 "// 처리 메시지
         sel(1),
         cuobj         LIKE zgtcvordsyval-cuobj,
       END OF gs_disp.
* 처리 관련
DATA : gs_row  TYPE lvc_s_row,
       gs_row2 TYPE lvc_s_row,
       gs_row3 TYPE lvc_s_row.

DATA : BEGIN OF gs_aufnr2,
         aufnr LIKE resb-aufnr,
       END OF gs_aufnr2.
DATA : BEGIN OF gs_popup,
         matnr  LIKE resb-matnr, "원 구성품
         maktx  LIKE makt-maktx, "원 구성품명
         aufnr  LIKE resb-aufnr, "생산오더
         posnr  LIKE resb-posnr, "항목
         erfmg  LIKE resb-erfmg, "투입수량
         erfme  LIKE resb-erfme, "단위
         idnrk  LIKE resb-matnr, "대체자재
         maktx2 LIKE makt-maktx, "대체자재명
       END OF gs_popup.

DATA : BEGIN OF gt_alter OCCURS 0,
         aufnr   LIKE zgtcvordsyval-aufnr,
         suc(2),
         fail(2),
       END OF gt_alter.

DATA : BEGIN OF gs_mseg,
         aufnr LIKE mseg-aufnr,
         matnr LIKE mseg-matnr,
         bwart LIKE mseg-bwart,
         menge LIKE mseg-menge,
       END OF gs_mseg.
* 생산오더 선택(조장구성표 출력)
DATA : BEGIN OF gs_grpnr,
         check    TYPE c LENGTH 1,
         grpnr    TYPE char20,
         erdat    LIKE zgtppt2000-erdat,
         gcatg    LIKE zgtppt2000-gcatg,
         ordno    LIKE zgtppt2000-ordno,
         posnr    LIKE zgtppt2000-posnr,
         linno    LIKE zgtppt2000-linno,
         ordno_c  TYPE char30,
         matnr    LIKE zgtppt2000-matnr,
         maktx    LIKE zgtppt2000-maktx,
         wmeng    LIKE zgtppt2000-wmeng,
         inlength LIKE zgtppt2000-inlength,
         infactor LIKE zgtppt2000-infactor,
         meins    LIKE zgtppt2000-meins,
         kunnr    LIKE zgtppt2000-kunnr,
         name1    LIKE kna1-name1,
         edatu    LIKE zgtppt2000-edatu,
         dmordty  LIKE zgtppt2010-dmordty,
         celltab  TYPE lvc_t_styl,
       END OF gs_grpnr.

DATA : gv_stable TYPE lvc_s_stbl VALUE 'XX'.
*- BDC관련 구조 및 테이블 정의.
DATA  : gs_bdcparams LIKE ctu_params.           "BDC 매개변수
*- 대체 자재 변경 탐색도움말 관련
DATA : BEGIN OF gs_1010,
         matnr LIKE mara-matnr,
         maktx LIKE makt-maktx,
       END OF gs_1010.
*- BOM POPUP
DATA : BEGIN OF gs_bom_p,
         aufnr LIKE zgtcvordsyval-aufnr, "기존오더
         gamng LIKE zgtcvordsyval-gamng, "오더수량
         matnr LIKE zgtcvordsyval-matnr, "탈피오더투입자재
         maktx LIKE zgtcvordsyval-maktx, "투입자재명
         menge LIKE zgtcvordsyval-gamng, "투입수량
         meins LIKE zgtcvordsyval-meins, "단위
       END OF gs_bom_p.

*---------------------------------------------------------------------*
* DATA: Internal Table.
*---------------------------------------------------------------------*
* 생산 오더 관련
DATA : gt_aufnr LIKE TABLE OF gs_aufnr.
* 공정코드 테이블( 조정표 번호 )
DATA : gt_2000 TYPE TABLE OF zgtppt2000.
DATA : gt_2010 TYPE TABLE OF zgtppt2010.
* 투입 자재 관련
DATA : gt_resb LIKE TABLE OF resb.
* 생산 오더 상태 관련
DATA : gt_status LIKE TABLE OF gs_status.
* Display 관련
DATA : gt_disp LIKE TABLE OF gs_disp.
* 처리 관련
DATA : gt_row  TYPE lvc_t_row,
       gt_row2 TYPE lvc_t_row,
       gt_row3 TYPE lvc_t_row.
DATA : gt_aufnr2 LIKE TABLE OF gs_aufnr2.
DATA : gt_popup LIKE TABLE OF gs_popup.

DATA : BEGIN OF gt_aufnr3 OCCURS 0,
         aufnr LIKE mseg-aufnr,
       END OF gt_aufnr3.
DATA : BEGIN OF gt_matnr3 OCCURS 0,
         matnr LIKE mseg-matnr,
       END OF gt_matnr3.
DATA : gt_matnr4 LIKE gt_matnr3 OCCURS 0 WITH HEADER LINE.

DATA : gt_mseg LIKE TABLE OF gs_mseg.

DATA : gs_orderdata    LIKE  bapi_pp_order_create,
       gs_return       LIKE bapiret2,
       gv_order_number LIKE bapi_order_key-order_number,
       gv_order_type   LIKE bapi_order_copy-order_type.
* 생산오더 선택(조장구성표 출력)
DATA : gt_grpnr LIKE TABLE OF gs_grpnr.
*- BDC관련 구조 및 테이블 정의.
DATA  : BEGIN OF gt_bdcdata OCCURS 5.
          INCLUDE STRUCTURE bdcdata.
DATA  : END   OF gt_bdcdata.

DATA  : BEGIN OF gt_msgcoll OCCURS 1.
          INCLUDE STRUCTURE bdcmsgcoll.
DATA  : END   OF gt_msgcoll.
*- 탐색도움말 관련
DATA: gt_fldtab TYPE dfies      OCCURS 0 WITH HEADER LINE,
      gt_rtntab LIKE ddshretval OCCURS 0 WITH HEADER LINE,
      gt_dselc  LIKE dselc OCCURS 0 WITH HEADER LINE.
*- 대체 자재 변경 탐색도움말 관련
DATA : gt_1010         LIKE TABLE OF gs_1010,
       gt_field        LIKE help_value OCCURS 0 WITH HEADER LINE,
       gs_selectfield  LIKE help_info-fieldname,
       gs_select_value LIKE help_info-fldvalue.

DATA : gt_matnr   LIKE TABLE OF zgtpps0001.
DATA : gt_matnr2 LIKE TABLE OF zgtpps0002.
*- 탈피 자재 BOM 관련
DATA : gs_topmat TYPE cstmat.
DATA : gt_stb TYPE TABLE OF stpox.
DATA : gt_cscmat TYPE TABLE OF cscmat,
       gs_cscmat TYPE cscmat.
*- BOM POPUP
DATA : gt_bom_p  LIKE TABLE OF gs_bom_p,
       gt_bom_p2 LIKE TABLE OF gs_bom_p.

DATA : BEGIN OF gs_2012 ,
         grpnr TYPE zgtppt2000-grpnr.
         INCLUDE STRUCTURE zgtppt2012.
DATA : END OF gs_2012.
DATA : gt_2012 LIKE TABLE OF gs_2012.

DATA : gt_ordsyval TYPE TABLE OF zgtcvordsyval.

CONSTANTS: gc_line_length  TYPE i VALUE 79.

DATA gr_textedit TYPE REF TO cl_gui_textedit.
DATA gt_ltext TYPE STANDARD TABLE OF tdline.
DATA gs_thead TYPE thead.
DATA gt_exclude TYPE ui_functions.
DATA gv_title TYPE string.

DATA gs_result TYPE ty_s_result.
DATA gs_schedule TYPE ty_s_schedule.

*---------------------------------------------------------------------*
*- ALV 정의
*---------------------------------------------------------------------*
*-/ ALV Global Field
CLASS lcl_event_handler DEFINITION DEFERRED.
DATA : go_container TYPE REF TO cl_gui_custom_container.
DATA : go_docking_container TYPE REF TO cl_gui_docking_container.
DATA : go_splitter TYPE REF TO cl_gui_splitter_container.
DATA : go_event_handler TYPE REF TO lcl_event_handler.
*-----------
*ALV GRID 100
DATA : go_contain_0100 TYPE REF TO cl_gui_container.
DATA : go_grid_0100 TYPE REF TO cl_gui_alv_grid.
DATA : gs_variant TYPE disvariant.
DATA : gs_layout_0100 TYPE lvc_s_layo.
DATA : gt_sort_0100 TYPE lvc_t_sort.
DATA : gt_exclude_0100 TYPE ui_functions.
DATA : gt_fieldcat_0100 TYPE lvc_t_fcat.
DATA : go_object TYPE REF TO cl_alv_event_toolbar_set.
*-----------
* ALV GRID 0101
DATA : go_contain_0101 TYPE REF TO cl_gui_container.
DATA : go_grid_0101 TYPE REF TO cl_gui_alv_grid.
DATA : gs_layout_0101 TYPE lvc_s_layo.
DATA : gt_sort_0101 TYPE lvc_t_sort.
DATA : gt_exclude_0101 TYPE ui_functions.
DATA : gt_fieldcat_0101 TYPE lvc_t_fcat.
* ALV GRID 0220
DATA : go_contain_0220 TYPE REF TO cl_gui_docking_container.
DATA : go_grid_0220 TYPE REF TO cl_gui_alv_grid.
DATA : gs_layout_0220 TYPE lvc_s_layo.
DATA : gt_exclude_0220 TYPE ui_functions.
DATA : gt_fieldcat_0220 TYPE lvc_t_fcat.
* ALV GRID 0400
DATA : go_contain_0400 TYPE REF TO cl_gui_docking_container.
DATA : go_grid_0400 TYPE REF TO cl_gui_alv_grid.
DATA : gs_layout_0400 TYPE lvc_s_layo.
DATA : gt_exclude_0400 TYPE ui_functions.
DATA : gt_fieldcat_0400 TYPE lvc_t_fcat.
