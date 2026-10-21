*&---------------------------------------------------------------------*
*& Include          ZGTPPR3080TOP
*&---------------------------------------------------------------------*
*-----------------------------------------------------------------------
*-- Tables
*-----------------------------------------------------------------------
TABLES : zgtppt1010,
         zgtppsif_rh, zgtppsift,
         sscrfields.

*-----------------------------------------------------------------------
*-- Types
*-----------------------------------------------------------------------
*-- 전송결과 정보 Types
TYPES : BEGIN OF gty_if_rst,
          ifsys TYPE text50,                         " I/F 수신 시스템
          pross TYPE text40,                         " I/F 항목
          acnt  TYPE text10,                         " 전체 건 수
          scnt  TYPE text10,                         " 성공 건 수
          fcnt  TYPE text10,                         " 실패 건 수
        END OF gty_if_rst.

*-- I/F 수신 해당 Table 정보 Types
TYPES : BEGIN OF gty_tab_info,
          head_tab TYPE tabname,                " Head Table 명
          item_tab TYPE tabname,                " Item Table 명
        END OF gty_tab_info.

*-----------------------------------------------------------------------
*-- Field-Symbols
*-----------------------------------------------------------------------
FIELD-SYMBOLS : <fs_head_tab> TYPE STANDARD TABLE,
                <fs_item_tab> TYPE STANDARD TABLE.

*-----------------------------------------------------------------------
* Internal Table
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
*-- Structure & Values
*-----------------------------------------------------------------------
DATA : gs_if_rst   TYPE gty_if_rst,
       gs_tab_info TYPE gty_tab_info.

DATA : gv_okcode TYPE syucomm,

       gv_eflg   TYPE char01.

*-----------------------------------------------------------------------
*-- ALV Global Values
*-----------------------------------------------------------------------
DATA : gt_fcat_head TYPE lvc_t_fcat,
       gt_fcat_item TYPE lvc_t_fcat,

       gt_sort_head TYPE lvc_t_sort,
       gt_sort_item TYPE lvc_t_sort,

       gt_excl_head TYPE ui_functions,
       gt_excl_item TYPE ui_functions.

DATA : gs_layo_head TYPE lvc_s_layo,
       gs_layo_item TYPE lvc_s_layo,

       gs_varient   TYPE disvariant.

*-----------------------------------------------------------------------
*-- Constants
*-----------------------------------------------------------------------
*-- Range Sign
CONSTANTS : BEGIN OF gc_sign,
              i TYPE ddsign                     VALUE 'I',
              e TYPE ddsign                     VALUE 'E',
            END OF gc_sign,
*-- Range Option
            BEGIN OF gc_optn,
              eq TYPE ddoption                  VALUE 'EQ',
              ne TYPE ddoption                  VALUE 'NE',
              bt TYPE ddoption                  VALUE 'BT',
              cp TYPE ddoption                  VALUE 'CP',
            END OF gc_optn.
