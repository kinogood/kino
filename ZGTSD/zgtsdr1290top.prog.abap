*&---------------------------------------------------------------------*
*& Include          ZGTSDR1290TOP
*&---------------------------------------------------------------------*
TYPE-POOLS:ESP1,TUMLS,ICON,SLIS.

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES: SSCRFIELDS,
        KNB1,KNA1,BUT000.


*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS: GC_VKORG_6000    TYPE VKORG   VALUE '6000',
           GC_BUKRS_6000    TYPE BUKRS   VALUE '6000',
           GC_KTOKD_0001    TYPE KTOKD   VALUE '0001',
           GC_KTOKD_9001    TYPE KTOKD   VALUE '9001',
           GC_CRULE_GO_STND TYPE UKM_CHECK_RULE VALUE 'GO_STND',
           GC_ROLE_UKM000 TYPE BU_PARTNERROLE VALUE 'UKM000'.
*           GC_ADDTYPE_50  TYPE BP3100-ADDTYPE VALUE '50',
*           GC_DATATYPE_01 TYPE BP3100-DATA_TYPE VALUE '01'.

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* STRUCTURE
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* INTERNAL TABLE
*----------------------------------------------------------------------*
DATA: BEGIN OF GT_LIST OCCURS 0,
        SEL(1),                        "선택 체크박스
        STAT         LIKE ICON-ID,   "결과 ICON

        KUNNR        LIKE LFA1-KUNNR,
        PARTNER      LIKE BUT000-PARTNER,
        KUNNR_TX     LIKE ADRC-NAME1,
        CHECK_RULE_O LIKE UKMBP_CMS-CHECK_RULE,
        CHECK_RULE_N LIKE UKMBP_CMS-CHECK_RULE,

        MESSAGE      LIKE BAPIRET2-MESSAGE,

        BUKRS        TYPE KNB1-BUKRS,
        KTOKD        TYPE KNA1-KTOKD,
        RSLT(1),

        CELLTAB      TYPE LVC_T_STYL, "CELL STYLE
      END OF GT_LIST.
DATA: GS_LIST LIKE LINE OF GT_LIST.

"LOG
DATA: GT_ZGTSDT9050 TYPE TABLE OF ZGTSDT9050.

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

*----------------------------------------------------------------------*
* FIELD-SYMBOLS
*----------------------------------------------------------------------*
*FIELD-SYMBOLS:


*----------------------------------------------------------------------*
* RANGES
*----------------------------------------------------------------------*
*RANGES:


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


DEFINE __BAPI_TRANSACTION_COMMIT.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
   EXPORTING
     WAIT          = 'X'.
END-OF-DEFINITION.
DEFINE __BAPI_TRANSACTION_ROLLBACK.
  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
END-OF-DEFINITION.
