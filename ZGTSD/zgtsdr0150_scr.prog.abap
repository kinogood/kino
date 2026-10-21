*&---------------------------------------------------------------------*
*& Include          ZGTSDR0150_SCR
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-T01.
  SELECT-OPTIONS: "S_VKORG FOR VBAK-VKORG DEFAULT '1000' NO INTERVALS NO-EXTENSION,
*                  S_VTWEG FOR VBAK-VTWEG,
                  "S_SPART FOR VBAK-SPART NO INTERVALS NO-EXTENSION, "DEFAULT '60',
                  S_WERKS FOR VBAP-WERKS DEFAULT '1306', "OBLIGATORY,
                  S_VKBUR FOR VBAK-VKBUR, "OBLIGATORY,
                  "S_VKGRP FOR VBAK-VKGRP,
                  "S_KUNNR FOR VBAK-KUNNR,
*                  S_LFDAT FOR LIKP-LFDAT,
                  S_JOBNO FOR ZGTEDT2121-ZJOB_NO,
                  S_ZPJNO FOR ZSD0106T-ZPJNO,
                  S_CRDAT FOR ZGTEDT2121-CRDAT OBLIGATORY,
                  S_ERDAT FOR ZSD0106T-ERDAT.
SELECTION-SCREEN END OF BLOCK BLK1.
