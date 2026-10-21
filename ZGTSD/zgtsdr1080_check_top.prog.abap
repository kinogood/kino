*&---------------------------------------------------------------------*
*& Include          ZGTSDR1080_CHECK_TOP
*&---------------------------------------------------------------------*

TABLES : vbrk, lips, likp, VBAK, VBKD.



RANGES : r_xblnr FOR zmseg-xblnr.



DATA :BEGIN OF gt_data OCCURS 0.
DATA :
  vbeln LIKE lips-vbeln,
  posnr LIKE lips-posnr,

  vgbel LIKE lips-vgbel,
  vgpos LIKE lips-vgpos,
  matnr LIKE lips-matnr,
  kunnr LIKE vbak-kunnr,
  lfimg LIKE lips-lfimg,
  LFIMG601   LIKE zmseg-menge,
  LFIMG687   LIKE zmseg-menge,
  etc   LIKE zmseg-menge,
  fkimg LIKE vbrp-fkimg,
  gap1  LIKE zmseg-menge,
  gap2  LIKE zmseg-menge,
  KDKG4 LIKE VBKD-KDKG4.


DATA : END OF GT_dATA.


DATA : BEGIN OF gt_zmseg OCCURS 0 .
DATA :
  mblnr     LIKE zmseg-mblnr,
  mjahr     LIKE zmseg-mjahr,
  zeile     LIKE zmseg-zeile,
  sjahr     LIKE zmseg-sjahr,
  smbln     LIKE zmseg-smbln,
  bwart     LIKE zmseg-bwart,
  mat_kdauf LIKE zmseg-mat_kdauf,
  mat_kdpos LIKE zmseg-mat_kdpos,
  posnr     LIKE lips-posnr,
  uecha     LIKE lips-uecha,
  menge     LIKE zmseg-menge,
  SHKZG     LIKE MATDOC-SHKZG.
DATA : END OF gt_zmseg.

DATA : BEGIN OF gt_SUM OCCURS 0 .
DATA :
  mat_kdauf LIKE zmseg-mat_kdauf,
  mat_kdpos LIKE zmseg-mat_kdpos,
  601       LIKE zmseg-menge,
  687       LIKE zmseg-menge,
  etc       LIKE zmseg-menge,
  fkimg     LIKE vbrp-fkimg.
DATA : END OF gt_SUM.


DATA : BEGIN OF gt_vbrp OCCURS 0 .
DATA  : vbeln LIKE vbrp-vbeln,
        posnr LIKE vbrp-posnr,
        vgbel LIKE vbrp-vgbel,
        vgpos LIKE vbrp-vgpos,
        aubel LIKE vbrp-aubel,
        aupos LIKE vbrp-aupos,
        fkimg LIKE vbrp-fkimg.
DATA : END OF gt_vbrp.

DATA : BEGIN OF lt_zmseg OCCURS 0 .
DATA :
  sjahr LIKE zmseg-sjahr,
  smbln LIKE zmseg-smbln.
DATA : END OF lt_zmseg .
