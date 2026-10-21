*&---------------------------------------------------------------------*
*& Include          ZGTSDR1210TOP
*&---------------------------------------------------------------------*
TYPE-POOLS:ESP1,TUMLS,ICON,SLIS.

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES: SSCRFIELDS,
        VBAK,S001,BP3100.


*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS: GC_VKORG_6000  TYPE VKORG   VALUE '6000',
           GC_WAERS_KRW   TYPE WAERS   VALUE 'KRW',
           GC_KTOKD_0003  TYPE KTOKD   VALUE '0003',
           GC_KTOKD_0001  TYPE KTOKD   VALUE '0001',
           GC_OBJECTCLAS  TYPE CDHDR-OBJECTCLAS VALUE 'BUPA_FS06',
           GC_ROLE_UKM000 TYPE BU_PARTNERROLE VALUE 'UKM000',
           GC_COMMTYP_200 TYPE UKM_TOTALS-COMM_TYP VALUE '200',
           GC_ADDTYPE_10  TYPE BP3100-ADDTYPE VALUE '10',
           GC_ADDTYPE_50  TYPE BP3100-ADDTYPE VALUE '50',
           GC_DATATYPE_01 TYPE BP3100-DATA_TYPE VALUE '01'.

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* STRUCTURE
*----------------------------------------------------------------------*
DATA: BEGIN OF GS_TOTALSDISPLAY.
        INCLUDE STRUCTURE UKM_S_TOTALS_DISPLAY.
DATA:   CREDIT_SGMNT_TXT LIKE UKMCRED_SGM0T-CREDIT_SGMNT_TXT,
        NAME_LAST        LIKE BUS000FLDS-DESCRIP,
        MSG_NAME_LAST    LIKE BUS000FLDS-DESCRIP,
        STATISTICAL_VAL  LIKE UKMCOMM_TYPES-STATISTICAL_VAL,
      END OF GS_TOTALSDISPLAY.

*----------------------------------------------------------------------*
* INTERNAL TABLE
*----------------------------------------------------------------------*
DATA: BEGIN OF GT_LIST OCCURS 0,
        VKBUR         LIKE  VBAK-VKBUR,
        VKBUR_TX      LIKE  TVKBT-BEZEI,
        VKGRP         LIKE  VBAK-VKGRP,
        VKGRP_TX      LIKE  TVGRT-BEZEI,
        CRITER        LIKE  BP3100-CRITER,
        PARTNER       LIKE  BP3100-PARTNER,
        KUNNR         LIKE  KNA1-KUNNR,
        KUNNR_TX      LIKE  ADRC-NAME1,
        AMNT_TOT      LIKE  ACCCR_PA-ERLOS,            "총여신
        CREDIT_LIMIT  LIKE  UKMBP_CMS_SGM-CREDIT_LIMIT, "여신한도
        AMNT_10       LIKE  ACCCR_PA-ERLOS,            "유효담보
        AMNT_50       LIKE  ACCCR_PA-ERLOS,            "운영한도
        AMOUNT_TOT    LIKE  ACCCR_PA-ERLOS,            "사용여신
        AMOUNT        LIKE  ACCCR_PA-ERLOS,            "매출환산
        AMOUNT_AR     LIKE  ACCCR_PA-ERLOS,            "채권
        CREDIT_REMAIN LIKE  ACCCR_PA-ERLOS,            "여신잔액
        XCRITICAL     LIKE  UKMBP_CMS_SGM-XCRITICAL,

        CURR          TYPE  BP3100-CURR,
        DFTVAL        TYPE  BUT050-DFTVAL,
        KTOKD         TYPE  KNA1-KTOKD,
        CELLTAB       TYPE  LVC_T_STYL, "CELL STYLE
      END OF GT_LIST.
DATA: GS_LIST LIKE GT_LIST.


DATA: GT_TOTALSDISPLAY LIKE TABLE OF GS_TOTALSDISPLAY.

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

DATA: GV_TITLE(50).

DATA: GV_TABIX LIKE SY-TABIX,
      GV_INDEX TYPE SY-TABIX.

DATA: GV_VKORG TYPE VKORG.

DATA: GV_DATEFR TYPE BP3100-DATEFR,
      GV_DATETO TYPE BP3100-DATETO.

DATA: GV_DATEFR_BF TYPE BP3100-DATEFR,
      GV_DATETO_BF TYPE BP3100-DATETO.

DATA: GV_PUNIT  TYPE BP3100-AMNT.

*----------------------------------------------------------------------*
* FIELD-SYMBOLS
*----------------------------------------------------------------------*
*FIELD-SYMBOLS:


*----------------------------------------------------------------------*
* RANGES
*----------------------------------------------------------------------*
RANGES: GR_VKBUR_ECL FOR VBAK-VKBUR,
        GR_VKGRP_ECL FOR VBAK-VKGRP,
        GR_XFELD     FOR BP3100-XFELD.

RANGES: GR_PARTNER_S FOR UKMBP_CMS_SGM-PARTNER,
        GR_SEGMT_S   FOR UKMBP_CMS_SGM-CREDIT_SGMNT,
        GR_COMTYP_S  FOR UKM_TOTALS-COMM_TYP.

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

CONSTANTS:
  GC_SA TYPE C VALUE 'a',
  GC_SB TYPE C VALUE 'b',
  GC_SC TYPE C VALUE 'c',
  GC_SD TYPE C VALUE 'd',
  GC_SE TYPE C VALUE 'e',
  GC_SF TYPE C VALUE 'f',
  GC_SG TYPE C VALUE 'g',
  GC_SH TYPE C VALUE 'h',
  GC_SI TYPE C VALUE 'i',
  GC_SJ TYPE C VALUE 'j',
  GC_SK TYPE C VALUE 'k',
  GC_SL TYPE C VALUE 'l',
  GC_SM TYPE C VALUE 'm',
  GC_SN TYPE C VALUE 'n',
  GC_SO TYPE C VALUE 'o',
  GC_SP TYPE C VALUE 'p',
  GC_SQ TYPE C VALUE 'q',
  GC_SR TYPE C VALUE 'r',
  GC_SS TYPE C VALUE 's',
  GC_ST TYPE C VALUE 't',
  GC_SU TYPE C VALUE 'u',
  GC_SV TYPE C VALUE 'v',
  GC_SW TYPE C VALUE 'w',
  GC_SX TYPE C VALUE 'x',
  GC_SY TYPE C VALUE 'y',
  GC_SZ TYPE C VALUE 'z'.
