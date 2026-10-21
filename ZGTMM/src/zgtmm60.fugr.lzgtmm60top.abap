FUNCTION-POOL ZGTMM60.                      "MESSAGE-ID ..


DATA : GV_SYSTEM_ID LIKE ZGTMMT9000-SYSTEM_ID,
       GV_ZIFKEY    LIKE ZGTMMT9000-ZIFKEY.

DATA : GV_ZGRCD TYPE ZGTE_BD_ZGRCD,
       GV_JOBNO TYPE ZGTE_BD_JOBNO,
       GV_WERKS TYPE WERKS_D.

DATA : GV_RST TYPE BAPI_MTYPE,
       GV_MSG TYPE BAPI_MSG,
       GV_ERR,
       GV_CHK.

DATA : GV_SEQ TYPE I.

DATA : GT_OTN LIKE ZGTMMSIF0068 OCCURS 0 WITH HEADER LINE.

DATA : GT_9000 LIKE ZGTMMT9000 OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF GS_XGR,
         ZIFKEY LIKE ZGTMMT6030-ZIFKEY,
         MBLNR1 LIKE ZGTMMT6030-MBLNR1,
         MJAHR1 LIKE ZGTMMT6030-MJAHR1,
         MBLNR2 LIKE ZGTMMT6030-MBLNR2,
         MJAHR2 LIKE ZGTMMT6030-MJAHR2,
         IV_NO  LIKE ZGTMMT6040-IV_NO,
       END   OF GS_XGR.

DATA : GT_CGR LIKE GS_XGR OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF GS_PIV,
         IV_NO        LIKE ZLET0005-IV_NO,
         IV_CANCEL_YN LIKE ZLET0005-IV_CANCEL_YN,
         OUT_YN       LIKE ZLET0005-OUT_YN,
       END   OF GS_PIV.

DATA : GV_BUDAT LIKE MKPF-BUDAT.

DATA : BEGIN OF GS_MDOC,
         MBLNR1 LIKE ZGTMMT6030-MBLNR1,
         MJAHR1 LIKE ZGTMMT6030-MJAHR1,
         MBLNR2 LIKE ZGTMMT6030-MBLNR2,
         MJAHR2 LIKE ZGTMMT6030-MJAHR2,
         IV_NO  LIKE ZGTMMT6040-IV_NO,
       END   OF GS_MDOC.

DATA : GS_MHDR  LIKE BAPI2017_GM_HEAD_01,
       GS_CHDR  LIKE BAPI2017_GM_HEAD_02,
       GS_MCOD  LIKE BAPI2017_GM_CODE,
       GS_MHDRT LIKE BAPI2017_GM_HEAD_RET,
       GT_MITM  LIKE BAPI2017_GM_ITEM_CREATE OCCURS 0 WITH HEADER LINE,
       GT_DITM  LIKE BAPI2017_GM_ITEM_CREATE OCCURS 0 WITH HEADER LINE,
       GT_RTN   LIKE BAPIRET2                OCCURS 0 WITH HEADER LINE.

DATA : GS_CREA LIKE ZGTMMS0001,
       GS_CHNG LIKE ZGTMMS0002.

DATA : GT_LE05 LIKE ZLET0005 OCCURS 0 WITH HEADER LINE,
       GT_LE06 LIKE ZLET0006 OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF GT_CLS OCCURS 0,
         ATFOR LIKE CABN-ATFOR,
         ATNAM LIKE CABN-ATNAM,
         ATFLV LIKE IBSYMBOL-ATFLV,
         ATFLB LIKE IBSYMBOL-ATFLB,
         ATWRT LIKE IBSYMBOL-ATWRT,
       END   OF GT_CLS.

DATA : GV_MATNR LIKE MARA-MATNR.


CONSTANTS : GC_B(1)                 VALUE 'B',
            GC_C(1)                 VALUE 'C',
            GC_D(1)                 VALUE 'D',
            GC_E(1)                 VALUE 'E',
            GC_I(1)                 VALUE 'I',
            GC_L(1)                 VALUE 'L',
            GC_M(1)                 VALUE 'M',
            GC_O(1)                 VALUE 'O',
            GC_Q(1)                 VALUE 'Q',
            GC_R(1)                 VALUE 'R',
            GC_S(1)                 VALUE 'S',
            GC_T(1)                 VALUE 'T',
            GC_V(1)                 VALUE 'V',
            GC_X(1)                 VALUE 'X',
            GC_CL(2)                VALUE 'CL',
            GC_CP(2)                VALUE 'CP',
            GC_EQ(2)                VALUE 'EQ',
            GC_01(2)                VALUE '01',
            GC_04(2)                VALUE '04',
            GC_B01(3)               VALUE 'B01',
            GC_E03(3)               VALUE 'E03',
            GC_ZZZ(3)               VALUE 'ZZZ',
            GC_101(3)               VALUE '101',
            GC_413(3)               VALUE '413',
            GC_541(3)               VALUE '541',
            GC_543(3)               VALUE '543',
            GC_738(3)               VALUE '738',
            GC_ROH(3)               VALUE 'ROH',
            GC_FERT(4)              VALUE 'FERT',
            GC_HAWA(4)              VALUE 'HAWA',
            GC_ROH1(4)              VALUE 'ROH1',
            GC_ROH2(4)              VALUE 'ROH2',
            GC_0001(4)              VALUE '0001',
            GC_0007(4)              VALUE '0007',
            GC_2530(4)              VALUE '2530',
            GC_000000(6)            VALUE '000000',
            GC_99991231(8)          VALUE '99991231',
            GC_PD_NBD_CM_LENGTH(16) VALUE 'PD_NBD_CM_LENGTH',
            GC_PD_NBD_CM_WEIGHT(16) VALUE 'PD_NBD_CM_WEIGHT'.


*----------------------------------------------------------------------*
* ZGTMM_BDMES_VENDOR_SEARCH
*----------------------------------------------------------------------*
RANGES : GR_LIFNR FOR LFA1-LIFNR,
         GR_NAME1 FOR LFA1-NAME1.


*----------------------------------------------------------------------*
* ZGTMM_BDMES_STOCK_LIST
*----------------------------------------------------------------------*
RANGES : GR_MATNR FOR VBAP-MATNR,
         GR_VBELN FOR VBAP-VBELN.

DATA : BEGIN OF GT_MAKT OCCURS 0,
         MATNR LIKE MAKT-MATNR,
         MAKTX LIKE MAKT-MAKTX,
       END   OF GT_MAKT.


*----------------------------------------------------------------------*
* ZGTMM_BDMES_GOODS_PO_RECEIPT
*----------------------------------------------------------------------*
DATA : GS_I66 LIKE ZGTMMSIF0066,
       GT_I67 LIKE ZGTMMSIF0067 OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF GT_PCHK OCCURS 0,
         LIFNR  LIKE EKKO-LIFNR,
         EBELN  LIKE EKPO-EBELN,
         EBELP  LIKE EKPO-EBELP,
         BEDNR  LIKE EKPO-BEDNR,
         PSTYP  LIKE EKPO-PSTYP,
         KNTTP  LIKE EKPO-KNTTP,
         HLGORT LIKE EKPO-LGORT,
         EMLIF  LIKE EKPO-EMLIF,
         LBLKZ  LIKE EKPO-LBLKZ,
         ELIKZ  LIKE EKPO-ELIKZ,
         MTART  LIKE EKPO-MTART,
         BSTAE  LIKE EKPO-BSTAE,
         MENGE  LIKE EKET-MENGE,
         WEMNG  LIKE EKET-WEMNG,
         VBELN  LIKE EKKN-VBELN,
         VBELP  LIKE EKKN-VBELP,
         MATNR  LIKE RESB-MATNR,
         WERKS  LIKE RESB-WERKS,
         LGORT  LIKE RESB-LGORT,
         SOBKZ  LIKE RESB-SOBKZ,
         KDAUF  LIKE RESB-KDAUF,
         KDPOS  LIKE RESB-KDPOS,
       END   OF GT_PCHK.

DATA : BEGIN OF GS_PJT,
         ZPJT_NO     LIKE ZGTEDT2121-ZPJT_NO,
         JOB_NO      LIKE ZGTMMT6210-JOB_NO,
         LINE_NO     LIKE ZGTMMT6210-LINE_NO,
         SERIAL_INFO LIKE ZGTMMT6210-SERIAL_INFO,
       END   OF GS_PJT.

DATA : GT_6030 LIKE ZGTMMT6030 OCCURS 0 WITH HEADER LINE.

DATA : GV_DIR.

DATA : GV_LINEID   TYPE MB_LINE_ID,
       GV_LINEID_P TYPE MB_LINE_ID.


*----------------------------------------------------------------------*
* ZGTMM_BDMES_COMP_TF
*----------------------------------------------------------------------*
DATA : GS_I69 LIKE ZGTMMSIF0069,
       GS_I70 LIKE ZGTMMSIF0070,
       GT_I71 LIKE ZGTMMSIF0071 OCCURS 0 WITH HEADER LINE.

DATA : GT_6040 LIKE ZGTMMT6040 OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------*
* ZGTMM_BDMES_ETCPASS_REQ
*----------------------------------------------------------------------*
DATA : GS_I72 LIKE ZGTMMSIF0072,
*      GT_I72 LIKE ZGTMMSIF0072 OCCURS 0 WITH HEADER LINE,
       GT_I73 LIKE ZGTMMSIF0073 OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF GT_I72 OCCURS 0.
         INCLUDE STRUCTURE ZGTMMSIF0072.
DATA :   IFNUM LIKE ZGTMMT6050-IFNUM.
DATA : END   OF GT_I72.

DATA : GT_6050 LIKE ZGTMMT6050 OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF GT_O73 OCCURS 0,
*        LEG_RQNO LIKE ZGTMMT6050-LEG_RQNO, "삭제(박상진E 25.02.04)
         SORT_SEQ LIKE ZGTMMT6050-SORT_SEQ,
         IFNUM    LIKE ZGTMMT6050-IFNUM,
         IV_NO    LIKE ZGTMMT6050-IV_NO,
         IV_SEQ   LIKE ZGTMMT6050-IV_SEQ,
       END   OF GT_O73.

DATA : BEGIN OF GS_XIV,
         ZIFKEY LIKE ZGTMMT6050-ZIFKEY,
         IV_NO  LIKE ZGTMMT6050-IV_NO,
       END   OF GS_XIV.

DATA : GT_CIV LIKE GS_XIV OCCURS 0 WITH HEADER LINE.

DATA : GV_IV_NO LIKE ZGTMMT6050-IV_NO.
