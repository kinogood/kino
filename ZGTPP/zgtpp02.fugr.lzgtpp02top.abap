FUNCTION-POOL zgtpp02  MESSAGE-ID zgtpp00.

* INCLUDE LZGTPP02D...                       " Local class definition
TYPES ty_t_lgort TYPE RANGE OF mchb-lgort.
TYPES ty_t_vbeln TYPE RANGE OF vbap-vbeln.
TYPES ty_t_posnr TYPE RANGE OF vbap-posnr.
TYPES ty_t_charg TYPE RANGE OF mchb-charg.

TYPES: BEGIN OF ty_s_import_para,
         werks TYPE range_t_werks,
         lgort TYPE ty_t_lgort,
         vbeln TYPE ty_t_vbeln,
         posnr TYPE ty_t_posnr,
         matnr TYPE range_t_matnr,
         charg TYPE ty_t_charg,
       END OF ty_s_import_para.

TYPES: BEGIN OF ty_s_slord,
         vbeln TYPE vbap-vbeln,
         posnr TYPE vbap-posnr,
         etenr TYPE vbep-etenr,
         cuobj TYPE vbap-cuobj,
         wmeng TYPE vbep-wmeng,
         vrkme TYPE vbep-vrkme,
         edatu TYPE vbep-edatu,
         kunnr TYPE vbak-kunnr,
         vkorg TYPE vbak-vkorg,
         vtweg TYPE vbak-vtweg,
         spart TYPE vbak-spart,
         vkgrp TYPE vbak-vkgrp,
         vkbur TYPE vbak-vkbur,
       END OF ty_s_slord.

TYPES: ty_t_zppt0001 TYPE TABLE OF zppt0001 WITH DEFAULT KEY.

DATA gt_zppt0001 TYPE ty_t_zppt0001.
DATA gt_mchb  TYPE TABLE OF mchb.
DATA gt_mska  TYPE TABLE OF mska.
DATA gt_slord TYPE TABLE OF ty_s_slord.

DATA gs_zgtppt2190 TYPE zgtppt2190.
DATA gs_zgtppt3360 TYPE zgtppt3360.
DATA gs_zgtpps1001 TYPE zgtpps1001.
DATA gs_zlet0401   TYPE zlet0401.

DATA : gv_ok_code3 LIKE sy-ucomm,
       gv_matkl2   LIKE mara-matkl,
       gv_matnr2   LIKE mara-matnr,
       gv_werks    LIKE t001w-werks,
       gv_jobs     TYPE i.

DATA : gt_matnr LIKE TABLE OF zgtpps0001.
*- 탐색도움말 관련
DATA: gt_fldtab TYPE dfies      OCCURS 0 WITH HEADER LINE,
      gt_rtntab LIKE ddshretval OCCURS 0 WITH HEADER LINE,
      gt_dselc  LIKE dselc OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------*
* CLASS                                                                *
*----------------------------------------------------------------------*
CLASS lcx_exception DEFINITION INHERITING FROM cx_static_check.
  PUBLIC SECTION.
    INTERFACES if_t100_dyn_msg.
ENDCLASS.
