FUNCTION-POOL zgtpp00.                  "MESSAGE-ID ..

* INCLUDE LZGTPPIF0001D...                   " Local class definition

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
*- Z_PP_IF_I_SM_BI_P11

TABLES : t001w.

*----------------------------------------------------------------------*
* CONSTANTS                                                            *
*----------------------------------------------------------------------*
CONSTANTS: BEGIN OF gc_werks,
             1302 TYPE t001w-werks VALUE '1302', "// 구미전력.
             1305 TYPE t001w-werks VALUE '1305', "// 구미소재.
             1306 TYPE t001w-werks VALUE '1306', "// 구미부스닥트.
             1802 TYPE t001w-werks VALUE '1802', "// 해저케이블.
             6500 TYPE t001w-werks VALUE '6500', "// 가온전선(군포).
             6600 TYPE t001w-werks VALUE '6600', "// 가온전선(전주).
           END OF gc_werks.

*-----------------------------------------------------------------------
*- ZGTPP_IF_O_STOCK_INFO
*-----------------------------------------------------------------------
DATA : gs_zgtppsif0009 TYPE zgtppsif0009,
       gt_zgtppsif0009 TYPE TABLE OF zgtppsif0009,
       gt_zgtppsif0010 TYPE TABLE OF zgtppsif0010.
DATA : gs_ot_zgtppsif0010 TYPE zgtppsif0010,
       gt_ot_zgtppsif0010 TYPE TABLE OF zgtppsif0010, "MES 전송용 테이블
       gs_it_zgtppsif0010 TYPE zgtppsif0010,
       gt_it_zgtppsif0010 TYPE TABLE OF zgtppsif0010. "History 저장용 테이블
