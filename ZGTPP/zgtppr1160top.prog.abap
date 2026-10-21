*&---------------------------------------------------------------------*
*& Include          ZGTPPR1160TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES                                                               *
*----------------------------------------------------------------------*
TABLES: aufk,
        afko,
        afpo,
        marc,
        resb,
        vbak,
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
           END OF gc_fcode.

CONSTANTS: BEGIN OF gc_handle,
             prod TYPE slis_handl VALUE '0001',
             hmat TYPE slis_handl VALUE '0002',
             comp TYPE slis_handl VALUE '0003',
           END OF gc_handle.

*----------------------------------------------------------------------*
* TYPES                                                                *
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_s_prod,
         werks     TYPE aufk-werks,           "// 플랜트
         aufnr     TYPE aufk-aufnr,           "// 생산오더
         ordst     TYPE char30,               "// 오더상태
         zpjno     TYPE vbak-zpjno,           "// 프로젝트번호
         zptxt     TYPE zsd0106t-zptxt,       "// 프로젝트내역
         bstnk     TYPE vbak-bstnk,           "// 제조지시번호
         zjob_name TYPE zgtedt2121-zjob_name, "// 제조지시내역
         matnr     TYPE afpo-matnr,           "// 모품목코드
         maktx     TYPE makt-maktx,           "// 모품목 내역
         color     TYPE char30,               "// 색상
         dispo     TYPE marc-dispo,           "// MRP관리자
         gamng     TYPE afko-gamng,           "// 생산오더수량
         wemng     TYPE afko-gamng,           "// 생산입고수량
         gmein     TYPE afko-gmein,           "// 생산단위
         idnrk     TYPE resb-matnr,           "// 자품목코드
         idntx     TYPE makt-maktx,           "// 자품목내역
         erfmg     TYPE resb-erfmg,           "// 소요량(생산오더수량 기준)
         zcumng    TYPE resb-erfmg,           "// 소요량(생산입고수량 기준)
         backlog   TYPE char10,               "// 백 로그 존재여부
         menge     TYPE resb-erfmg,           "// 생산투입수량
         erfme     TYPE resb-erfme,           "// 출고단위
         inpst     TYPE char10,               "// 투입상태
         zqtydif   TYPE resb-bdmng,           "// 차이수량
         zgirate   TYPE p,                    "// 투입율(%)
         stprs     TYPE mbewh-stprs,          "// 표준가
         zamtdif   TYPE mbewh-stprs,          "// 차이금액
         waers     TYPE t001-waers,           "// 통화키
         objnr     TYPE aufk-objnr,
       END OF ty_s_prod.

TYPES: BEGIN OF ty_s_hmat,
         werks   TYPE aufk-werks,  "// 플랜트
         matnr   TYPE afpo-matnr,  "// 모품목코드
         maktx   TYPE makt-maktx,  "// 모품목 내역
         color   TYPE char30,      "// 색상
         dispo   TYPE marc-dispo,  "// MRP관리자
         gamng   TYPE afko-gamng,  "// 생산오더수량
         wemng   TYPE afko-gamng,  "// 생산입고수량
         gmein   TYPE afko-gmein,  "// 생산단위
         idnrk   TYPE resb-matnr,  "// 자품목코드
         idntx   TYPE makt-maktx,  "// 자품목내역
         erfmg   TYPE resb-erfmg,  "// 소요량(생산오더수량 기준)
         zcumng  TYPE resb-erfmg,  "// 소요량(생산입고수량 기준)
         backlog TYPE char10,      "// 백로그 존재여부
         menge   TYPE resb-erfmg,  "// 생산투입수량
         erfme   TYPE resb-erfme,  "// 출고단위
         inpst   TYPE char10,      "// 투입상태
         zqtydif TYPE resb-bdmng,  "// 차이수량
         zgirate TYPE p,           "// 투입율(%)
         stprs   TYPE mbewh-stprs, "// 표준가
         zamtdif TYPE mbewh-stprs, "// 차이금액
         waers   TYPE t001-waers,  "// 통화키
       END OF ty_s_hmat.

TYPES: BEGIN OF ty_s_comp,
         werks   TYPE aufk-werks,  "// 플랜트
         idnrk   TYPE resb-matnr,  "// 자품목코드
         idntx   TYPE makt-maktx,  "// 자품목내역
         erfmg   TYPE resb-erfmg,  "// 소요량(생산오더수량 기준)
         zcumng  TYPE resb-erfmg,  "// 소요량(생산입고수량 기준)
         backlog TYPE char10,      "// 백로그 존재여부
         menge   TYPE resb-erfmg,  "// 생산투입수량
         erfme   TYPE resb-erfme,  "// 출고단위
         inpst   TYPE char10,      "// 투입상태
         zqtydif TYPE resb-bdmng,  "// 차이수량
         zgirate TYPE p,           "// 투입율(%)
         stprs   TYPE mbewh-stprs, "// 표준가
         zamtdif TYPE mbewh-stprs, "// 차이금액
         waers   TYPE t001-waers,  "// 통화키
         gamng   TYPE afko-gamng,  "// 생산오더수량
         wemng   TYPE afko-gamng,  "// 생산입고수량
         gmein   TYPE afko-gmein,  "// 생산단위
       END OF ty_s_comp.

TYPES: BEGIN OF ty_s_status_text,
         objnr TYPE aufk-objnr,
         ordst TYPE char30,
       END OF ty_s_status_text.

TYPES: BEGIN OF ty_s_prod_order,
         aufnr TYPE aufk-aufnr,
       END OF ty_s_prod_order.

*----------------------------------------------------------------------*
* DATA                                                                 *
*----------------------------------------------------------------------*
DATA gr_list TYPE REF TO zgtpp_cl_list.
DATA gr_data TYPE REF TO data.

DATA gt_prod TYPE TABLE OF ty_s_prod.
DATA gt_hmat TYPE TABLE OF ty_s_hmat WITH NON-UNIQUE SORTED KEY skey COMPONENTS werks matnr idnrk.
DATA gt_comp TYPE TABLE OF ty_s_comp WITH NON-UNIQUE SORTED KEY skey COMPONENTS werks idnrk.

DATA gt_stext TYPE TABLE OF ty_s_status_text WITH NON-UNIQUE SORTED KEY skey COMPONENTS objnr.

DATA gt_inpst TYPE RANGE OF char10.

DATA gv_mode    TYPE char10.
DATA gt_exclude TYPE ui_functions.
DATA gv_saved   TYPE abap_bool.
DATA gv_okcode  TYPE sy-ucomm.
DATA gv_tpar1   TYPE syst_msgv.
