FUNCTION-POOL ZGTMM03.                      "MESSAGE-ID ..


* Define Macro.......
* Refresh & Clear....
DEFINE CLT.
  REFRESH &1.
  CLEAR   &1.
END-OF-DEFINITION.

* Table Declare......
DEFINE DCL.
  DATA : &1 LIKE &2 OCCURS 0 WITH HEADER LINE.
END-OF-DEFINITION.

* Append & Clear.....
DEFINE APP.
  APPEND &1.
  CLEAR  &1.
END-OF-DEFINITION.


TABLES : ZMMT0129,
         ZMMTI39,
         ZMMTI52,
         EKBE,
         EKES,
         MARA.

RANGES : R_MATNR FOR EKPO-MATNR,
         R_WERKS FOR MARC-WERKS,
         R_DATE  FOR SY-DATUM.

DATA : BEGIN OF IT_EBKN OCCURS 0,
         BANFN      LIKE EBKN-BANFN,
         BNFPO      LIKE EBKN-BNFPO,
         PS_PSP_PNR LIKE EBKN-PS_PSP_PNR,
         NPLNR      LIKE EBKN-NPLNR,
         ABLAD      LIKE EBKN-ABLAD,
         WEMPF      LIKE EBKN-WEMPF,
         AUFNR      LIKE EBKN-AUFNR,
         AUFPL      LIKE EBKN-AUFPL,
         APLZL      LIKE EBKN-APLZL,
         VBELN      LIKE EBKN-VBELN,
         VBELP      LIKE EBKN-VBELP,
       END   OF IT_EBKN.

DATA : BEGIN OF IT_EKKN OCCURS 0,
         EBELN      LIKE EKKN-EBELN,
         EBELP      LIKE EKKN-EBELP,
         PS_PSP_PNR LIKE EKKN-PS_PSP_PNR,
         ABLAD      LIKE EKKN-ABLAD,
         WEMPF      LIKE EKKN-WEMPF,
         AUFNR      LIKE EKKN-AUFNR,
         VBELN      LIKE EKKN-VBELN,
         VBELP      LIKE EKKN-VBELP,
       END   OF IT_EKKN.

DATA : GV_DESC(30).

DATA : W_CHECK TYPE CHAR1,
       W_TXT   TYPE CHAR1.

DATA : W_MSG(100),                     "RFC CALL ERROR MSG...
       W_DEST      LIKE ZIFDEST-DEST.  "DESTINATION..........

*2025.08.05 통합솔루션 전환 IS변경
*CONSTANTS : G_MODULE LIKE ZIFDEST-GUBUN VALUE 'MM',
CONSTANTS : G_MODULE LIKE ZIFDEST-GUBUN VALUE 'IS',
            C_BUKRS  LIKE RBKP-BUKRS    VALUE '1000'.

 TYPES : BEGIN OF ty_cabn_buf,
           atnam LIKE cabn-atnam,
           atinn LIKE cabn-atinn,
           atbez LIKE cabnt-atbez,
         END OF ty_cabn_buf.
 TYPES : BEGIN OF ty_cawn_buf,
           atinn LIKE cawn-atinn,
           atwrt LIKE cawn-atwrt,
           atwtb LIKE cawnt-atwtb,
         END OF ty_cawn_buf.
