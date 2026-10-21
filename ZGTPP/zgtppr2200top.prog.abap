*&---------------------------------------------------------------------*
*& Include          ZGTPPR2200TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES                                                               *
*----------------------------------------------------------------------*
TABLES: zgtppt2300, "//	RCCP 수기 등록 관리.
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

CONSTANTS: BEGIN OF gc_table,
             zgtppt2300 TYPE rstable-tabname VALUE 'ZGTPPT2300',
           END OF gc_table.

CONSTANTS: BEGIN OF gc_handle,
             0001 TYPE slis_handl VALUE '0001',
             0002 TYPE slis_handl VALUE '0002',
           END OF gc_handle.

CONSTANTS gc_duplication TYPE lvc_fname VALUE 'ZZDUPLICATION'.

*----------------------------------------------------------------------*
* TYPES                                                                *
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_s_list,
         zmanual_no TYPE zgtppt2300-zmanual_no, "// 수기 등록 번호
         zexclude   TYPE char10,                "// 주문 제외
         zinclude   TYPE char10,                "// 주문 추가
         vbeln      TYPE zgtppt2300-vbeln,      "// 판매오더번호
         posnr      TYPE zgtppt2300-posnr,      "// 판매오더품목
         matnr      TYPE zgtppt2300-matnr,      "// 품목코드
         maktx      TYPE makt-maktx,            "// 품목내역
         menge      TYPE zgtppt2300-menge,      "// 수주수량
         meins      TYPE zgtppt2300-meins,      "// 수량단위
         vdatu      TYPE zgtppt2300-vdatu,      "// 납기일자
         kunnr      TYPE vbak-kunnr,            "// 거래처코드
         name1      TYPE kna1-name1,            "// 거래처명
         werks      TYPE zgtppt2300-werks,
         spgcd      TYPE zgtppt2300-spgcd,
         crdat      TYPE zgtppt2300-crdat,
         crtim      TYPE zgtppt2300-crtim,
         crnam      TYPE zgtppt2300-crnam,
         chdat      TYPE zgtppt2300-chdat,
         chtim      TYPE zgtppt2300-chtim,
         chnam      TYPE zgtppt2300-chnam,
         status     TYPE char10,
         message    TYPE char30,
         return     TYPE bapiret2_tab,
         init       TYPE abap_bool,
         dupli      TYPE abap_bool,
         sel        TYPE abap_bool,
       END OF ty_s_list.

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
DATA gt_list TYPE TABLE OF ty_s_list.

DATA gt_zmanual_type TYPE RANGE OF zgtppt2300-zmanual_type.

DATA gs_zgtpps1001 TYPE zgtpps1001.
DATA gs_result TYPE ty_s_result.

DATA gv_mode    TYPE char10.
DATA gt_exclude TYPE ui_functions.
DATA gt_style   TYPE lvc_t_styl.
DATA gv_saved   TYPE abap_bool.
DATA gv_okcode  TYPE sy-ucomm.
DATA gv_tpar1   TYPE syst_msgv.
DATA gv_tpar2   TYPE syst_msgv.
