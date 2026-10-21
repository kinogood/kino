*&---------------------------------------------------------------------*
*& Include          ZGTSDR2010SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK BL01 WITH FRAME.
  SELECT-OPTIONS: S_VKORG FOR LIKP-VKORG OBLIGATORY NO INTERVALS NO-EXTENSION
                                         MODIF ID ZM1,
                  S_VTWEG FOR LIPS-VTWEG OBLIGATORY NO INTERVALS NO-EXTENSION
                                         MODIF ID ZM1,
                  S_SPART FOR LIPS-SPART NO INTERVALS NO-EXTENSION,
                  S_VKBUR FOR LIPS-VKBUR OBLIGATORY NO INTERVALS MEMORY ID VKB,
                  S_VKGRP FOR LIPS-VKGRP OBLIGATORY NO INTERVALS MEMORY ID VKG,
                  S_WADAT FOR LIKP-WADAT ,
                  S_WADATS FOR LIKP-WADAT_IST,
                  S_LFART FOR LIKP-LFART OBLIGATORY NO INTERVALS NO-EXTENSION,
                  S_KUNNR FOR LIKP-KUNAG NO INTERVALS,
                  S_KUNWE FOR LIKP-KUNNR NO INTERVALS,
                  S_PERNR FOR VBPA-LIFNR NO INTERVALS,
                  S_VBELN FOR VBAK-VBELN NO INTERVALS,
                  S_BSTNK FOR VBAK-BSTNK NO INTERVALS,
                  S_VSTEL FOR LIKP-VSTEL NO INTERVALS,
                  S_LGORT FOR LIPS-LGORT NO INTERVALS,
                  S_MATNR FOR LIPS-MATNR,
                  S_LIFSK FOR LIKP-LIFSK NO INTERVALS.

SELECTION-SCREEN END   OF BLOCK BL01.
