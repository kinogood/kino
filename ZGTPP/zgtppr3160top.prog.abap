*&---------------------------------------------------------------------*
*& Include          ZGTPPR3160TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES                                                               *
*----------------------------------------------------------------------*
TABLES: zgtppt3360,
        sscrfields. " 선택화면의 필드.

*----------------------------------------------------------------------*
* CONSTANTS                                                            *
*----------------------------------------------------------------------*
CONSTANTS: BEGIN OF gc_fcode,
             onli   TYPE sy-ucomm VALUE 'ONLI',
             back   TYPE sy-ucomm VALUE 'BACK',
             exit   TYPE sy-ucomm VALUE 'EXIT',
             cancel TYPE sy-ucomm VALUE 'CANCEL',
             save   TYPE sy-ucomm VALUE 'SAVE',
             fc01   TYPE sy-ucomm VALUE 'FC01',
             rework TYPE sy-ucomm VALUE 'REWORK',
           END OF gc_fcode.

*----------------------------------------------------------------------*
* TYPES                                                                *
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_s_list,
         al_stat_icon  TYPE char10,                    "// 주문 할당 상태
         tr_stat_icon  TYPE char10,                    "// 재고 이전 상태
         chk_stat_icon TYPE char10,                    "// 점검 상태
         tr_mblnr      TYPE zgtppt3360-tr_mblnr,       "// 재고 이전 자재문서번호
         stat_msg      TYPE zgtppt3360-stat_msg,       "// 처리 메시지
         chk_msg       TYPE zgtppt3360-chk_msg,        "// 점검 메시지
         updrq         TYPE zgtppt3360-updrq,          "// LINK업데이트요청번호
         upd_type      TYPE zgtppt3360-upd_type,       "// 처리 구분
         upd_type_txt  TYPE char40,                    "// 구분 내역
         werks         TYPE zgtppt3360-werks,          "// 플랜트
         name1         TYPE t001w-name1,               "// 플랜트 내역
         tagnr         TYPE zgtppt3360-tagnr,          "// 꼬리표번호
         zcut_ord_no   TYPE zgtppt3360-zcut_ord_no,    "// 절단지시번호
         zcut_ord_item TYPE zgtppt3360-zcut_ord_item,  "// 절단지시항번
         dlvrq         TYPE zgtppt3360-dlvrq,          "// 출하요청번호
         vbeln         TYPE zgtppt3360-vbeln,          "// 판매오더번호
         posnr         TYPE zgtppt3360-posnr,          "// 판매오더항번
         kwmeng        TYPE zgtppt3360-kwmeng,         "// 출하요청수량
         vrkme         TYPE zgtppt3360-vrkme,          "// 수량단위
         crdat         TYPE zgtppt3360-crdat,          "// 생성일자
         crtim         TYPE zgtppt3360-crtim,          "// 생성시간
         crnam         TYPE zgtppt3360-crnam,          "// 생성자
         chdat         TYPE zgtppt3360-chdat,          "// 변경일자
         chtim         TYPE zgtppt3360-chtim,          "// 변경시간
         chnam         TYPE zgtppt3360-chnam,          "// 변경자
         al_stat       TYPE zgtppt3360-al_stat,        "// 주문 할당 상태
         tr_stat       TYPE zgtppt3360-tr_stat,        "// 재고 이전 상태
         chk_stat      TYPE zgtppt3360-chk_stat,       "// 점검 상태
         sel           TYPE abap_bool,
         return        TYPE bapiret2_tab,
       END OF ty_s_list.

TYPES: BEGIN OF ty_s_result,
         sel     TYPE sy-tabix,
         total   TYPE sy-tabix,
         success TYPE sy-tabix,
         error   TYPE sy-tabix,
         invalid TYPE abap_bool,
       END OF ty_s_result.

*----------------------------------------------------------------------*
* DATA                                                                 *
*----------------------------------------------------------------------*
DATA gr_list TYPE REF TO zgtpp_cl_list.
DATA gt_list TYPE TABLE OF ty_s_list.

DATA gt_upd_type TYPE RANGE OF zgtppt3360-upd_type.
DATA gv_where  TYPE string.
DATA gs_result TYPE ty_s_result.

DATA gv_mode    TYPE char10.
DATA gt_exclude TYPE ui_functions.
DATA gv_saved   TYPE abap_bool.
DATA gv_okcode  TYPE sy-ucomm.
DATA gv_tpar1   TYPE syst_msgv.
