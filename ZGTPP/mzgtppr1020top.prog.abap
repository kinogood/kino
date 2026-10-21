*&---------------------------------------------------------------------*
*& Include MZGTPPR1020TOP                                     모듈풀    *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  sapmzgtppr1020 MESSAGE-ID zgtpp00.
TABLES: makt,
        mara,
        marc,
        zgtppt1030.


CONTROLS: tc_200          TYPE TABLEVIEW USING SCREEN '0200'.

DATA: gv_idx     TYPE i,
      gv_saveflg TYPE char04.

DATA: BEGIN OF gw_sel,
        werks TYPE marc-werks,
        name1 TYPE t001w-name1,
        spgcd TYPE zgtppt1030-spgcd,
        procd TYPE zgtppt1030-procd,
      END   OF gw_sel.

DATA: BEGIN OF gt_data  OCCURS 0.
        INCLUDE STRUCTURE     zgtppt1030.
DATA:   index LIKE sy-index,             "인덱스
        chk   TYPE c,
        del   TYPE c,
        flag  TYPE char4,
      END   OF gt_data.

DATA  : gs_cols      LIKE LINE OF tc_200-cols.

DATA : BEGIN OF gt_upload OCCURS 0,
         werks     LIKE zgtppt1030-werks,
         spgcd     LIKE zgtppt1030-spgcd,
         procd     LIKE zgtppt1030-procd,
         matnr     LIKE zgtppt1030-matnr,
         matkl     LIKE zgtppt1030-matkl,
         zcustomer LIKE zgtppt1030-zcustomer,
         a_scrap   LIKE zgtppt1030-a_scrap,
         c_scrap1  LIKE zgtppt1030-c_scrap1,
         c_scrap6  LIKE zgtppt1030-c_scrap6,
       END  OF gt_upload.

DATA: gv_field(30),
      gv_lilli     LIKE sy-lilli,
      gw_data      LIKE gt_data,
      gw_cols      LIKE LINE OF tc_200-cols,
      gt_save      LIKE gt_data OCCURS 0 WITH HEADER LINE,
      gt_cols      LIKE gw_cols OCCURS 0 WITH HEADER LINE,
      gv_cnt       LIKE sy-index,
      gv_okcode    LIKE sy-ucomm,
      ok_code      LIKE sy-ucomm,
      gv_index     LIKE sy-index,
      gv_procd     LIKE zppt0042-procd.

DATA: gt_fldtab     TYPE dfies      OCCURS 0 WITH HEADER LINE,
      gt_rtntab     LIKE ddshretval OCCURS 0 WITH HEADER LINE,
      gt_dynpread   LIKE dynpread   OCCURS 0 WITH HEADER LINE,
      gt_dynpupdate TYPE dynpread   OCCURS 0 WITH HEADER LINE,
      gt_down       LIKE gt_upload  OCCURS 0 WITH HEADER LINE.
