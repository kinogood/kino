*&---------------------------------------------------------------------*
*& Include          ZGTMMR4150TOP
*&---------------------------------------------------------------------*

DATA : BEGIN OF GT_HLIST OCCURS 0,
         BUKRS LIKE MSEG-BUKRS,
         WERKS LIKE MSEG-WERKS,
         MJAHR LIKE MSEG-MJAHR,
         MBLNR LIKE MSEG-MBLNR,
         EMLIF LIKE MSEG-EMLIF,
         DMBTR LIKE MSEG-DMBTR,
         WAERS LIKE MSEG-WAERS,
       END   OF GT_HLIST.

DATA : BEGIN OF GT_ILIST OCCURS 0,
         MATNR LIKE MSEG-MATNR,
         MENGE LIKE MSEG-MENGE,
         MEINS LIKE MSEG-MEINS,
         EMLIF LIKE MSEG-EMLIF,
         DMBTR LIKE MSEG-DMBTR,
         WAERS LIKE MSEG-WAERS,
       END   OF GT_ILIST.

DATA : BEGIN OF GS_SHDR,
*        LIFNR        TYPE ZGTMM_CV_SCSTOCKHEADER-LIFNR,
         PREIS        TYPE ZGTMM_CV_SCSTOCKHEADER-PREIS,
         TOTALSCVALUE TYPE ZGTMM_CV_SCSTOCKHEADER-TOTALSCVALUE,
         APVALUE      TYPE ZGTMM_CV_SCSTOCKHEADER-APVALUE,
         WAERS        TYPE ZGTMM_CV_SCSTOCKHEADER-WAERS,
       END   OF GS_SHDR.

DATA : GT_SHDR LIKE ZGTMMT4110 OCCURS 0 WITH HEADER LINE,
       GT_SITM LIKE ZGTMMT4111 OCCURS 0 WITH HEADER LINE.

DATA : GS_CREA LIKE ZGTMMS0001,
       GS_CHNG LIKE ZGTMMS0002.

DATA : GV_REVAL LIKE MSEG-DMBTR.


CONSTANTS : GC_A(1)           VALUE 'A',
            GC_D(1)           VALUE 'D',
            GC_O(1)           VALUE 'O',
            GC_X(1)           VALUE 'X',
            GC_02(2)          VALUE '02',
            GC_003(3)         VALUE '003',
            GC_101(3)         VALUE '101',
            GC_ZGTMMR4020(10) VALUE 'ZGTMMR4020'.
