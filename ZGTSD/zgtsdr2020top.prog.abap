*&---------------------------------------------------------------------*
*& Include          ZGTSDR2020TOP
*&---------------------------------------------------------------------*
TYPE-POOLS:ESP1,TUMLS,ICON,SLIS.
TYPE-POOLS:VRM.

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES: SSCRFIELDS,
        VBAK,VBPA,
        LIKP,LIPS,
        ZGTSDT9130,
        ZGTSDS1100.


*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS: GC_VKORG_6000 TYPE VKORG   VALUE '6000',
           GC_WAERS_KRW  TYPE WAERS   VALUE 'KRW',
           GC_VTWEG_10   TYPE VTWEG   VALUE '10',
           GC_PARVW_VE   TYPE PARVW   VALUE 'VE',
           GC_LFART_ZLF3 TYPE LFART   VALUE 'ZLF3',
           GC_LIFSK_G4   TYPE LIFSK   VALUE 'G4',
           GC_KSCHL_ZRMR TYPE KSCHL   VALUE 'ZRMR',
           GC_LGORT_3499 TYPE LGORT   VALUE '3499'.


*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* STRUCTURE
*----------------------------------------------------------------------*
DATA: GS_BAPIRET2 TYPE BAPIRET2.




*----------------------------------------------------------------------*
* INTERNAL TABLE
*----------------------------------------------------------------------*
DATA: BEGIN OF GT_LIST OCCURS 0,
        SEL(1),
        ST_FINSH    LIKE ICON-ID,
*        ST_SPLIT   LIKE ICON-ID,
        ST_PICK     LIKE ICON-ID,
        ST_PGI      LIKE ICON-ID,
        ST_BILL     LIKE ICON-ID,
        VBELN_VA    LIKE VBAK-VBELN,
        VBELN_VL    LIKE LIKP-VBELN,
        ZDOSPLIT(1),                    "납품분할여부
*        VBELN_VLSP LIKE LIKP-VBELN,
*        ST_VLSP    LIKE ICON-ID,
        KUNAG       LIKE LIKP-KUNAG,
        KUNAG_TX    LIKE ADRC-NAME1,
        ERDAT       LIKE LIKP-ERDAT,
        FKDAT       LIKE VBRK-FKDAT,
        NETWR_VF    LIKE VBRK-NETWR,
        WADAT_IST   LIKE LIKP-WADAT_IST,
        NETWR_INI   LIKE VBAP-NETWR,      "최초금액
        NETWR_JSJA  LIKE VBAP-NETWR,      "적송잔액
        WAERK       LIKE LIKP-WAERK,
        KUNNR       LIKE LIKP-KUNNR,
        KUNNR_TX    LIKE ADRC-NAME1,
        LFART       LIKE LIKP-LFART,
        AUART       LIKE VBAK-AUART,
        BSTNK       LIKE VBAK-BSTNK,
        VSTEL       LIKE LIKP-VSTEL,
        VSTEL_TX    LIKE TVSTT-VTEXT,
        VKORG       LIKE LIKP-VKORG,
        VTWEG       LIKE LIPS-VTWEG,
        SPART       LIKE VBAK-SPART,
        VKBUR       LIKE LIPS-VKBUR,
        VKBUR_TX    LIKE TVKBT-BEZEI,
        VKGRP       LIKE LIPS-VKGRP,
        VKGRP_TX    LIKE TVGRT-BEZEI,
        MESSAGE     LIKE BAPIRET2-MESSAGE,

        KOSTK       TYPE LIKP-KOSTK,       "PICKING
        WBSTK       TYPE LIKP-WBSTK,       "자재이동상태(PGI)
        FKSTK       TYPE LIKP-FKSTK,       "청구상태
        LIFSK       TYPE LIKP-LIFSK,       "납품보류

        WAERK_VF    TYPE VBRK-WAERK,
        SPLIT_DO(1),
        SPMON       TYPE S001-SPMON,
        FI_CLOSE(1),

        RSLT(1),

        CELLTAB     TYPE  LVC_T_STYL, "CELL STYLE
      END OF GT_LIST.
DATA: GS_LIST LIKE GT_LIST.

DATA: BEGIN OF GT_SPLIT OCCURS 0,
        SEL(1),
        ST_FINSH   LIKE ICON-ID,
*        ST_SPLIT   LIKE ICON-ID,
        ST_PICK    LIKE ICON-ID,
        ST_PGI     LIKE ICON-ID,
        ST_BILL    LIKE ICON-ID,
        VBELN_VA   LIKE VBAK-VBELN,   "판매문서
        VBELN_VLSP LIKE LIKP-VBELN,   "분할납품문서
        VBELN_VL   LIKE LIKP-VBELN,   "납품문서(원 DO)
        KUNAG      LIKE LIKP-KUNAG,
        KUNAG_TX   LIKE ADRC-NAME1,
        ERDAT      LIKE LIKP-ERDAT,
        FKDAT      LIKE VBRK-FKDAT,
        NETWR_VF   LIKE VBRP-NETWR,
        WAERK_VF   LIKE LIKP-WAERK,
        KUNNR      LIKE LIKP-KUNNR,
        KUNNR_TX   LIKE ADRC-NAME1,
        LFART      LIKE LIKP-LFART,
        AUART      LIKE VBAK-AUART,
        BSTNK      LIKE VBAK-BSTNK,
        VSTEL      LIKE LIKP-VSTEL,
        VSTEL_TX   LIKE TVSTT-VTEXT,
        VKORG      LIKE LIKP-VKORG,
        VTWEG      LIKE LIPS-VTWEG,
        SPART      LIKE VBAK-SPART,
        VKBUR      LIKE LIPS-VKBUR,
        VKBUR_TX   LIKE TVKBT-BEZEI,
        VKGRP      LIKE LIPS-VKGRP,
        VKGRP_TX   LIKE TVGRT-BEZEI,
        MESSAGE    LIKE BAPIRET2-MESSAGE,

*        SPLIT(1),
        KOSTK      TYPE LIKP-KOSTK,       "PICKING
        WBSTK      TYPE LIKP-WBSTK,       "자재이동상태(PGI)
        FKSTK      TYPE LIKP-FKSTK,       "청구상태
        LIFSK      TYPE LIKP-LIFSK,       "납품보류
        RSLT(1),
        NO_CANC(1),

        CELLTAB    TYPE  LVC_T_STYL, "CELL STYLE
      END OF GT_SPLIT.
DATA: GS_SPLIT LIKE GT_SPLIT.




*-SCREEN 0200
DATA: BEGIN OF GT_ITEM OCCURS 0,
        VBELN_VL   LIKE LIKP-VBELN,
        UECHA      LIKE LIPS-POSNR,
        POSNR_VL   LIKE LIPS-POSNR,
        MATNR      LIKE LIPS-MATNR,
        CHARG      LIKE LIPS-CHARG,
        VRKME      LIKE LIPS-VRKME,
        LFIMG      LIKE LIPS-LFIMG,                "최초수량
        LENGTH_JS  LIKE LIPS-LFIMG,                "조장
        FACTOR_I   LIKE ZGTSDT9120-MILLCA_FACTOR_M, "최초조장수
        FACTOR_B   LIKE ZGTSDT9120-MILLCA_FACTOR_M, "매출조장수
        LFIMG_B    LIKE LIPS-LFIMG,                "매출수량
        NETPR      LIKE VBAP-NETPR,                "단가
        NETWR_BL_I LIKE VBAP-NETWR,                "매출금액
        FACTOR_JS  LIKE ZGTSDT9120-MILLCA_FACTOR_M, "적송조장수
        LFIMG_JS   LIKE LIPS-LFIMG,                "적송잔량
        NETWR_JS_I LIKE VBAP-NETWR,                "잔량금액

        VGBEL      TYPE LIPS-VGBEL,
        VGPOS      TYPE LIPS-VGPOS,
        WAERK      TYPE LIKP-WAERK,

        CELLTAB    TYPE  LVC_T_STYL, "CELL STYLE
      END OF GT_ITEM.
DATA: GS_ITEM LIKE GT_ITEM.

*-분할납품문서
DATA: GT_SPLIT_DO TYPE TABLE OF LEDSPD_FLOW.


DATA: GT_ZGTSDT9130 TYPE TABLE OF ZGTSDT9130,
      GT_BASE       TYPE TABLE OF ZGTSDT9130.
DATA: GT_LIPS  TYPE TABLE OF LIPS.


*-FM  'WS_DELIVERY_UPDATE_2'
DATA: GS_VBKOK TYPE VBKOK,
      GT_VBPOK TYPE TABLE OF VBPOK,
      GS_VBPOK TYPE VBPOK,
      GT_PROT  TYPE TABLE OF PROTT.

*-BAPI 'BAPI_BILLINGDOC_CREATEMULTIPLE'
DATA : GT_BDATAIN TYPE TABLE OF BAPIVBRK,
       GS_BDATAIN TYPE BAPIVBRK,
       GT_CONDTIN	TYPE TABLE OF BAPIKOMV,
       GS_CONDTIN	TYPE BAPIKOMV,
       GT_SUCCESS TYPE TABLE OF BAPIVBRKSUCCESS,
       GS_SUCCESS TYPE BAPIVBRKSUCCESS,
       GT_RETURN  TYPE TABLE OF BAPIRET1.

*___BDC용 변수
TABLES : CTU_PARAMS.

DATA : BEGIN OF GT_BDCTAB OCCURS 0.
         INCLUDE STRUCTURE BDCDATA.
DATA : END   OF GT_BDCTAB.

DATA : GT_RETMSG LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------*
* VARIABLES
*----------------------------------------------------------------------*
DATA: OK_CODE TYPE SY-UCOMM,
      SAVE_OK TYPE SY-UCOMM.

DATA: GV_ERROR,
      GV_CHK,
      GV_TYPE,
      GV_EDIT,
      GV_ANSWER.

DATA: GV_TITLE(50),
      GV_TITLE1(50),
      GV_TITLE2(50),
      GV_TITLE3(50),
      GV_TITLE4(50).


DATA: GV_TABIX LIKE SY-TABIX,
      GV_INDEX TYPE SY-TABIX.

DATA: GV_VKORG TYPE VKORG.

DATA: GV_SUBSCR_10 LIKE SY-DYNNR VALUE '0110',
      GV_SUBSCR_20 LIKE SY-DYNNR VALUE '0120'.

DATA: GV_FLAG_C10(1).

DATA: GV_POSNR TYPE LIPS-POSNR.

DATA: GV_DISP(1).

*----------------------------------------------------------------------*
* FIELD-SYMBOLS
*----------------------------------------------------------------------*
*FIELD-SYMBOLS:


*----------------------------------------------------------------------*
* RANGES
*----------------------------------------------------------------------*
RANGES: GR_FKDAT FOR VBRK-FKDAT.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS:
  GC_A TYPE C VALUE 'A',
  GC_B TYPE C VALUE 'B',
  GC_C TYPE C VALUE 'C',
  GC_D TYPE C VALUE 'D',
  GC_E TYPE C VALUE 'E',
  GC_F TYPE C VALUE 'F',
  GC_G TYPE C VALUE 'G',
  GC_H TYPE C VALUE 'H',
  GC_I TYPE C VALUE 'I',
  GC_J TYPE C VALUE 'J',
  GC_K TYPE C VALUE 'K',
  GC_L TYPE C VALUE 'L',
  GC_M TYPE C VALUE 'M',
  GC_N TYPE C VALUE 'N',
  GC_O TYPE C VALUE 'O',
  GC_P TYPE C VALUE 'P',
  GC_Q TYPE C VALUE 'Q',
  GC_R TYPE C VALUE 'R',
  GC_S TYPE C VALUE 'S',
  GC_T TYPE C VALUE 'T',
  GC_U TYPE C VALUE 'U',
  GC_V TYPE C VALUE 'V',
  GC_W TYPE C VALUE 'W',
  GC_X TYPE C VALUE 'X',
  GC_Y TYPE C VALUE 'Y',
  GC_Z TYPE C VALUE 'Z',
  GC_0 TYPE C VALUE '0',
  GC_1 TYPE C VALUE '1',
  GC_2 TYPE C VALUE '2',
  GC_3 TYPE C VALUE '3',
  GC_4 TYPE C VALUE '4',
  GC_5 TYPE C VALUE '5',
  GC_6 TYPE C VALUE '6',
  GC_7 TYPE C VALUE '7',
  GC_8 TYPE C VALUE '8',
  GC_9 TYPE C VALUE '9'.

DEFINE __BAPI_TRANSACTION_COMMIT.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
   EXPORTING
     WAIT          = 'X'.
END-OF-DEFINITION.
DEFINE __BAPI_TRANSACTION_ROLLBACK.
  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
END-OF-DEFINITION.
