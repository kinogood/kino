*&---------------------------------------------------------------------*
*& Include          ZGTPPR2190TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES                                                               *
*----------------------------------------------------------------------*
TABLES: zgtppt2270, "//	설비-작업장 맵핑 관리
        zgtppt2280, "// 공휴일 관리
        zgtppt2290, "// Working Day 관리
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
             fc02       TYPE sy-ucomm VALUE 'FC02',
             insert_row TYPE sy-ucomm VALUE 'INSERT_ROW',
             delete_row TYPE sy-ucomm VALUE 'DELETE_ROW',
             apply      TYPE sy-ucomm VALUE 'APPLY',
           END OF gc_fcode.

CONSTANTS: BEGIN OF gc_werks,
             6500 TYPE t001w-werks VALUE '6500',
             6600 TYPE t001w-werks VALUE '6600',
           END OF gc_werks.

CONSTANTS: BEGIN OF gc_codegrp,
             4070 TYPE zgtppt1010-codegrp VALUE '4070', "// 스크랩코드.
           END OF gc_codegrp.

CONSTANTS: BEGIN OF gc_table,
             zgtppt2270 TYPE rstable-tabname VALUE 'ZGTPPT2270',
             zgtppt2280 TYPE rstable-tabname VALUE 'ZGTPPT2280',
             zgtppt2290 TYPE rstable-tabname VALUE 'ZGTPPT2290',
           END OF gc_table.

CONSTANTS: BEGIN OF gc_handle,
             t2270 TYPE slis_handl VALUE '0001',
             t2280 TYPE slis_handl VALUE '0002',
             t2290 TYPE slis_handl VALUE '0003',
             eqpm  TYPE slis_handl VALUE '0004',
           END OF gc_handle.

CONSTANTS gc_duplication TYPE lvc_fname VALUE 'ZZDUPLICATION'.

*----------------------------------------------------------------------*
* TYPES                                                                *
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_s_t2270,
         werks     TYPE zgtppt2270-werks,     "// 플랜트
         equcd     TYPE zgtppt2270-equcd,     "// 설비코드
         equnm     TYPE zgtppt2270-equnm,     "// 설비내역
         arbpl     TYPE zgtppt2270-arbpl,     "// 작업장코드
         ktext     TYPE crtx-ktext,           "// 작업장내역
         status    TYPE char10,               "// 상태
         message   TYPE char50,               "// 메시지
         crdat     TYPE zgtppt2270-crdat,     "// 생성일
         crtim     TYPE zgtppt2270-crtim,     "// 생성시간
         crnam     TYPE zgtppt2270-crnam,     "// 생성자
         chdat     TYPE zgtppt2270-chdat,     "// 변경일
         chtim     TYPE zgtppt2270-chtim,     "// 변경시간
         chnam     TYPE zgtppt2270-chnam,     "// 변경자
         return    TYPE bapiret2_tab,
         style     TYPE lvc_t_styl,
         init      TYPE abap_bool,
         dupli     TYPE abap_bool,
         sel       TYPE abap_bool,
       END OF ty_s_t2270.

TYPES: BEGIN OF ty_s_t2280,
         werks    TYPE zgtppt2280-werks,     "// 플랜트
         gjahr    TYPE zgtppt2280-gjahr,     "// 년월
         zholiday TYPE zgtppt2280-zholiday,  "// 일자
         zday     TYPE zgtppt2280-zday,      "// 요일
         zholinm  TYPE zgtppt2280-zholinm,   "// 공휴일 내역
         status   TYPE char10,               "// 상태
         message  TYPE char50,               "// 메시지
         crdat    TYPE zgtppt2280-crdat,     "// 생성일
         crtim    TYPE zgtppt2280-crtim,     "// 생성시간
         crnam    TYPE zgtppt2280-crnam,     "// 생성자
         chdat    TYPE zgtppt2280-chdat,     "// 변경일
         chtim    TYPE zgtppt2280-chtim,     "// 변경시간
         chnam    TYPE zgtppt2280-chnam,     "// 변경자
         return   TYPE bapiret2_tab,
         style    TYPE lvc_t_styl,
         init     TYPE abap_bool,
         dupli    TYPE abap_bool,
         sel      TYPE abap_bool,
       END OF ty_s_t2280.

TYPES: BEGIN OF ty_s_t2290,
         werks     TYPE zgtppt2290-werks,     "// 플랜트
         spmon     TYPE zgtppt2290-spmon,     "// 년월
         equcd     TYPE zgtppt2290-equcd,     "// 설비코드
         zworkday  TYPE zgtppt2290-zworkday,  "// 일자
         zday      TYPE zgtppt2280-zday,      "// 요일
         zholinm   TYPE zgtppt2280-zholinm,   "// 공휴일 내역
         zworktime TYPE zgtppt2290-zworktime, "// 근무시간(H)
         weekday   TYPE zgtppt2290-weekday,   "// 달력: 일수
         crdat     TYPE zgtppt2290-crdat,     "// 생성일
         crtim     TYPE zgtppt2290-crtim,     "// 생성시간
         crnam     TYPE zgtppt2290-crnam,     "// 생성자
         chdat     TYPE zgtppt2290-chdat,     "// 변경일
         chtim     TYPE zgtppt2290-chtim,     "// 변경시간
         chnam     TYPE zgtppt2290-chnam,     "// 변경자
         row_color TYPE char4,
       END OF ty_s_t2290.

TYPES: ty_t_t2290 TYPE TABLE OF ty_s_t2290 WITH DEFAULT KEY.

TYPES: BEGIN OF ty_s_equipment,
         equcd TYPE zgtppt2270-equcd,     "// 설비코드
         equnm TYPE zgtppt2270-equnm,     "// 설비내역
         zstat TYPE char10,               "// Working Day 등록여부.
         t2290 TYPE ty_t_t2290,
       END OF ty_s_equipment.

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
DATA gr_docking_container  TYPE REF TO cl_gui_docking_container.
DATA gr_splitter_container TYPE REF TO cl_gui_splitter_container.
DATA gr_left_container     TYPE REF TO cl_gui_container.
DATA gr_right_container    TYPE REF TO cl_gui_container.

DATA gr_list TYPE REF TO zgtpp_cl_list.
DATA gr_eqpm TYPE REF TO zgtpp_cl_list.
DATA gr_data TYPE REF TO data.

DATA gv_list TYPE string.

DATA gt_t2270 TYPE TABLE OF ty_s_t2270.
DATA gt_t2280 TYPE TABLE OF ty_s_t2280 WITH NON-UNIQUE SORTED KEY skey COMPONENTS werks gjahr zholiday.
DATA gt_t2290 TYPE TABLE OF ty_s_t2290.
DATA gt_eqpm  TYPE TABLE OF ty_s_equipment.
DATA gs_eqpm  TYPE ty_s_equipment.

DATA gt_zgtppt1010 TYPE TABLE OF zgtppt1010.

DATA gt_crhd TYPE TABLE OF crhd_v1.

DATA gs_result TYPE ty_s_result.
DATA gs_zgtpps1001 TYPE zgtpps1001.

DATA gv_spmon TYPE char10.

DATA gv_mode    TYPE char10.
DATA gt_exclude TYPE ui_functions.
DATA gt_style   TYPE lvc_t_styl.
DATA gt_style2  TYPE lvc_t_styl.
DATA gv_saved   TYPE abap_bool.
DATA gv_okcode  TYPE sy-ucomm.
DATA gv_tpar1   TYPE syst_msgv.
DATA gv_tpar2   TYPE syst_msgv.
