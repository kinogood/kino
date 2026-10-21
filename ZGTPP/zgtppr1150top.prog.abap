*&---------------------------------------------------------------------*
*& Include          ZGTPPR1150TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES                                                               *
*----------------------------------------------------------------------*
TABLES: zgtppt1120, "//	공정 및 물자 스크랩 코드 관리(GAON)
        zgtppt1130, "//	탈피 후 스크랩 자재 관리(GAON)
        zgtppt1140, "//	생산 스크랩 코드 관리(GAON)
        sscrfields. "// 선택화면 필드.

*----------------------------------------------------------------------*
* CONSTANTS                                                            *
*----------------------------------------------------------------------*
CONSTANTS: BEGIN OF gc_fcode,
             onli       TYPE sy-ucomm VALUE 'ONLI',
             back       TYPE sy-ucomm VALUE 'BACK',
             exit       TYPE sy-ucomm VALUE 'EXIT',
             cancel     TYPE sy-ucomm VALUE 'CANCEL',
             save       TYPE sy-ucomm VALUE 'SAVE',
             fc01       TYPE sy-ucomm VALUE 'FC01',
             insert_row TYPE sy-ucomm VALUE 'INSERT_ROW',
             delete_row TYPE sy-ucomm VALUE 'DELETE_ROW',
           END OF gc_fcode.

CONSTANTS: BEGIN OF gc_werks,
             6500 TYPE t001w-werks VALUE '6500',
             6600 TYPE t001w-werks VALUE '6600',
           END OF gc_werks.

CONSTANTS: BEGIN OF gc_codegrp,
             4070 TYPE zgtppt1010-codegrp VALUE '4070', "// 스크랩코드.
           END OF gc_codegrp.

CONSTANTS: BEGIN OF gc_table,
             zgtppt1120 TYPE rstable-tabname VALUE 'ZGTPPT1120',
             zgtppt1130 TYPE rstable-tabname VALUE 'ZGTPPT1130',
             zgtppt1140 TYPE rstable-tabname VALUE 'ZGTPPT1140',
           END OF gc_table.

CONSTANTS: BEGIN OF gc_handle,
             t1120 TYPE slis_handl VALUE '0001',
             t1130 TYPE slis_handl VALUE '0002',
             t1140 TYPE slis_handl VALUE '0003',
           END OF gc_handle.

CONSTANTS gc_duplication TYPE lvc_fname VALUE 'ZZDUPLICATION'.

CONSTANTS: BEGIN OF gc_tcode,
             zgtppr1150v TYPE sy-tcode VALUE 'ZGTPPR1150V',
           END OF gc_tcode.

*----------------------------------------------------------------------*
* TYPES                                                                *
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_s_t1120,
         werks   TYPE zgtppt1120-werks,     "// 플랜트
         spgcd   TYPE zgtppt1120-spgcd,     "// SPG코드
         lgort   TYPE zgtppt1120-lgort,     "// 생산저장위치
         scgrp   TYPE zgtppt1120-scgrp,     "// 스크랩 코드(분류)
         sctxt   TYPE zgtppt1120-sctxt,     "// 스크랩 분류 내역
         opgrp   TYPE zgtppt1120-opgrp,     "// 공정(자재)그룹
         matnr   TYPE zgtppt1120-matnr,     "// 생산 스크랩코드
         maktx   TYPE zgtppt1120-maktx,     "// 자재내역
         werks_m TYPE zgtppt1120-werks_m,   "// 물자플랜트
         lgort_m TYPE zgtppt1120-lgort_m,   "// 물자저장위치
         matnr_m TYPE zgtppt1120-matnr_m,   "// 물자 스크랩코드
         maktx_m TYPE zgtppt1120-maktx_m,   "// 자재내역
         status  TYPE char10,               "// 상태
         message TYPE char50,               "// 메시지
         crdat   TYPE zgtppt1120-crdat,     "// 생성일
         crtim   TYPE zgtppt1120-crtim,     "// 생성시간
         crnam   TYPE zgtppt1120-crnam,     "// 생성자
         chdat   TYPE zgtppt1120-chdat,     "// 변경일
         chtim   TYPE zgtppt1120-chtim,     "// 변경시간
         chnam   TYPE zgtppt1120-chnam,     "// 변경자
         return  TYPE bapiret2_tab,
         style   TYPE lvc_t_styl,
         init    TYPE abap_bool,
         dupli   TYPE abap_bool,
         sel     TYPE abap_bool,
       END OF ty_s_t1120.

TYPES: BEGIN OF ty_s_t1130,
         werks   TYPE zgtppt1130-werks,   "// 플랜트
         spgcd   TYPE zgtppt1130-spgcd,   "// SPG 코드
         lgort   TYPE zgtppt1130-lgort,   "// 저장위치
         scgrp   TYPE zgtppt1130-scgrp,   "// 스크랩 코드(분류)
         sctxt   TYPE zgtppt1130-sctxt,   "// 스크랩 분류 내역
         matnr_t TYPE zgtppt1130-matnr_t, "// 탈피후 스크랩코드
         maktx_t TYPE zgtppt1130-maktx_t, "// 탈피 후 스크랩 자재 내역
         useyn   TYPE zgtppt1130-useyn,   "// 사용여부
         scrat   TYPE zgtppt1130-scrat,   "// 환산율(%)
         status  TYPE char10,             "// 상태
         message TYPE char50,             "// 메시지
         crdat   TYPE zgtppt1130-crdat,   "// 생성일
         crtim   TYPE zgtppt1130-crtim,   "// 생성시간
         crnam   TYPE zgtppt1130-crnam,   "// 생성자
         chdat   TYPE zgtppt1130-chdat,   "// 변경일
         chtim   TYPE zgtppt1130-chtim,   "// 변경시간
         chnam   TYPE zgtppt1130-chnam,   "// 변경자
         return  TYPE bapiret2_tab,
         style   TYPE lvc_t_styl,
         init    TYPE abap_bool,
         dupli   TYPE abap_bool,
         sel     TYPE abap_bool,
       END OF ty_s_t1130.

TYPES: BEGIN OF ty_s_t1140,
         werks   TYPE zgtppt1140-werks,   "// 플랜트
         spgcd   TYPE zgtppt1140-spgcd,   "// SPG코드
         matkl   TYPE zgtppt1140-matkl,   "// 자재 그룹
         wgbez   TYPE t023t-wgbez,        "// 자재 그룹 내역
         matnr   TYPE zgtppt1140-matnr,   "// 생산 스크랩코드
         maktx   TYPE zgtppt1140-maktx,   "// 자재 내역
         werks_m TYPE zgtppt1140-werks_m, "// 물자 플랜트
         lgort_m TYPE zgtppt1140-lgort_m, "// 물자 저장위치
         matnr_m TYPE zgtppt1140-matnr_m, "// 물자 스크랩 자재코드
         maktx_m TYPE makt-maktx,         "// 자재내역
         status  TYPE char10,             "// 상태
         message TYPE char50,             "// 메시지
         crdat   TYPE zgtppt1140-crdat,   "// 생성일
         crtim   TYPE zgtppt1140-crtim,   "// 생성시간
         crnam   TYPE zgtppt1140-crnam,   "// 생성자
         chdat   TYPE zgtppt1140-chdat,   "// 변경일
         chtim   TYPE zgtppt1140-chtim,   "// 변경시간
         chnam   TYPE zgtppt1140-chnam,   "// 변경자
         return  TYPE bapiret2_tab,
         style   TYPE lvc_t_styl,
         init    TYPE abap_bool,
         dupli   TYPE abap_bool,
         sel     TYPE abap_bool,
       END OF ty_s_t1140.

TYPES: BEGIN OF ty_s_zgtppt1120_db.
         INCLUDE TYPE zgtppt1120.
TYPES:   del TYPE abap_bool,
       END OF ty_s_zgtppt1120_db.

TYPES: BEGIN OF ty_s_zgtppt1130_db.
         INCLUDE TYPE zgtppt1130.
TYPES:   del TYPE abap_bool,
       END OF ty_s_zgtppt1130_db.

TYPES: BEGIN OF ty_s_zgtppt1140_db.
         INCLUDE TYPE zgtppt1140.
TYPES:   del TYPE abap_bool,
       END OF ty_s_zgtppt1140_db.

TYPES ty_t_zgtppt1120_db TYPE TABLE OF ty_s_zgtppt1120_db WITH DEFAULT KEY.
TYPES ty_t_zgtppt1130_db TYPE TABLE OF ty_s_zgtppt1130_db WITH DEFAULT KEY.
TYPES ty_t_zgtppt1140_db TYPE TABLE OF ty_s_zgtppt1140_db WITH DEFAULT KEY.

TYPES: BEGIN OF ty_s_scgrp,
         scgrp TYPE zgtppt1120-scgrp,
         sctxt TYPE zgtppt1120-sctxt,
       END OF ty_s_scgrp.

TYPES: BEGIN OF ty_s_result,
         sel     TYPE sy-tabix,
         total   TYPE sy-tabix,
         success TYPE sy-tabix,
         error   TYPE sy-tabix,
         invalid TYPE abap_bool,
         message TYPE char100,
       END OF ty_s_result.

*----------------------------------------------------------------------*
* DATA                                                                 *
*----------------------------------------------------------------------*
DATA gr_list TYPE REF TO zgtpp_cl_list.
DATA gr_data TYPE REF TO data.

DATA gt_t1120 TYPE TABLE OF ty_s_t1120.
DATA gt_t1130 TYPE TABLE OF ty_s_t1130.
DATA gt_t1140 TYPE TABLE OF ty_s_t1140.

DATA gt_zgtppt1010 TYPE TABLE OF zgtppt1010.

DATA gt_t001w TYPE HASHED TABLE OF t001w WITH UNIQUE KEY werks.
DATA gt_t001l TYPE HASHED TABLE OF t001l WITH UNIQUE KEY werks lgort.
DATA gt_t023t TYPE HASHED TABLE OF t023t WITH UNIQUE KEY mandt spras matkl.

DATA gs_result TYPE ty_s_result.
DATA gs_zgtpps1001 TYPE zgtpps1001.

DATA gv_mode    TYPE char10.
DATA gt_exclude TYPE ui_functions.
DATA gt_style   TYPE lvc_t_styl.
DATA gt_style2  TYPE lvc_t_styl.
DATA gv_saved   TYPE abap_bool.
DATA gv_okcode  TYPE sy-ucomm.
DATA gv_tpar1   TYPE syst_msgv.
DATA gv_tpar2   TYPE syst_msgv.
