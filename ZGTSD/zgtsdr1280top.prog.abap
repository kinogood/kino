*&---------------------------------------------------------------------*
*& Include          ZGTSDR1280TOP
*&---------------------------------------------------------------------*
TYPE-POOLS:ESP1,TUMLS,ICON,SLIS.

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES: SSCRFIELDS,
        BUT000,
        LFA1,KNB1,KNVV,KNA1.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS:
  GC_VKORG_6000     TYPE VKORG          VALUE '6000',
  GC_KTOKK_3800     TYPE KTOKK          VALUE '3800',
  GC_BUKRS_6000     TYPE BUKRS          VALUE '6000',
  GC_TYPE_2         TYPE BU_TYPE        VALUE '2',
  GC_VTWEG_50       TYPE VTWEG          VALUE '50',
  GC_SPART_3C       TYPE SPART          VALUE '3C',
  GC_SPART_4C       TYPE SPART          VALUE '4C',
  GC_KTOKD_C120     TYPE KTOKD          VALUE 'C120',
  GC_KTOKD_0001     TYPE KTOKD          VALUE '0001',
  GC_KTOKD_0003     TYPE KTOKD          VALUE '0003',
  GC_ROLE_UKM000    TYPE BU_PARTNERROLE VALUE 'UKM000',
  GC_RLTYP_UKM001   TYPE BU_PARTNERROLE VALUE 'UKM001',
  GC_RLTYP_FLCU00   TYPE BU_PARTNERROLE VALUE 'FLCU00',
  GC_RLTYP_FLCU01   TYPE BU_PARTNERROLE VALUE 'FLCU01',
  GC_BUGROUP_C120   TYPE BU_GROUP       VALUE 'C120',
  GC_AKONT_BP       TYPE AKONT          VALUE '0001140101',
  GC_CHKRULE_LOCAL  TYPE UKM_CHECK_RULE VALUE 'GO_LOCAL',
  GC_CHKRULE_STND   TYPE UKM_CHECK_RULE VALUE 'GO_STND',
  GC_RISK_CLASS_001 TYPE UKM_RISK_CLASS VALUE '001',
  GC_BU_RELTYP      TYPE BURS_JOEL_MAIN-DIRECTED_TYPE_C
                         VALUE 'FUKM001'.


*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* STRUCTURE
*----------------------------------------------------------------------*


*----------------------------------------------------------------------*
* INTERNAL TABLE
*----------------------------------------------------------------------*
DATA: BEGIN OF GT_0100 OCCURS 0,
        SEL(1),
        STAT         LIKE ICON-ID,

        LIFNR        LIKE LFA1-LIFNR,
        TYPE         LIKE BUT000-TYPE,
        BU_GROUP     LIKE BUT000-BU_GROUP,
        RLTYP        LIKE BUT100-RLTYP,
        BUKRS        LIKE KNB1-BUKRS,
        KUNNR        LIKE KNB1-KUNNR,
        NAME1        LIKE ADRC-NAME1,
        NAME2        LIKE ADRC-NAME2,
        SORT1        LIKE ADRC-SORT1,
        POST_CODE1   LIKE ADRC-POST_CODE1,
        CITY1        LIKE ADRC-CITY1,
        STREET       LIKE ADRC-STREET,
        COUNTRY      LIKE ADRC-COUNTRY,
        REGION       LIKE ADRC-REGION,
        LANGU        LIKE ADRC-LANGU,
        TEL_NUMBER   LIKE ADRC-TEL_NUMBER,
        SMTP_ADDR    LIKE ADR6-SMTP_ADDR,
        EXTENSION1   LIKE ADRC-EXTENSION1,
        AKONT        LIKE KNB1-AKONT,
        RISK_CLASS   LIKE UKMBP_CMS-RISK_CLASS,
        MESSAGE      LIKE BAPIRET2-MESSAGE,

        NEW(1),

        PARTNER      TYPE BUT000-PARTNER,
        PARTNER_GUID TYPE BUT000-PARTNER_GUID,
        ADDRNUMBER   TYPE BUT020-ADDRNUMBER,
        KTOKD        TYPE KNA1-KTOKD,
        PARTNER_CU   TYPE BUT000-PARTNER,
        RSLT(1),

        CELLTAB      TYPE LVC_T_STYL, "CELL STYLE
        COLOR        TYPE LVC_T_SCOL,
      END OF GT_0100.
DATA: GS_0100 LIKE LINE OF GT_0100.

DATA: BEGIN OF GT_0200 OCCURS 0,
        SEL(1),
        STAT         LIKE ICON-ID,

        LIFNR        LIKE LFA1-LIFNR,
        RLTYP        LIKE BUT100-RLTYP,
        VKORG        LIKE KNVV-VKORG,
        VTWEG        LIKE KNVV-VTWEG,
        SPART        LIKE KNVV-SPART,
        KUNNR        LIKE KNVV-KUNNR,
        NAME1        LIKE ADRC-NAME1,
        KALKS        LIKE KNVV-KALKS,
        BOKRE        LIKE KNVV-BOKRE,
        PRFRE        LIKE KNVV-PRFRE,
        MESSAGE      LIKE BAPIRET2-MESSAGE,

        PARTNER      TYPE BUT000-PARTNER,
        PARTNER_GUID TYPE BUT000-PARTNER_GUID,
        BUKRS        TYPE KNB1-BUKRS,
        PARTNER_CU   TYPE BUT000-PARTNER,

        RSLT(1),
        NEW(1),

        CELLTAB      TYPE LVC_T_STYL, "CELL STYLE
        COLOR        TYPE LVC_T_SCOL,
      END OF GT_0200.
DATA: GS_0200 LIKE LINE OF GT_0200.


DATA : GT_DATA TYPE CVIS_EI_EXTERN_T,
       GS_DATA TYPE CVIS_EI_EXTERN.

"LOG
DATA: GT_ZGTSDT9040 TYPE TABLE OF ZGTSDT9040.

DATA: GT_TVTA TYPE TABLE OF TVTA.

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
      GV_TITLE3(50).

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

DEFINE __BAPI_TRANSACTION_COMMIT.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
   EXPORTING
     WAIT          = 'X'.
END-OF-DEFINITION.
DEFINE __BAPI_TRANSACTION_ROLLBACK.
  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
END-OF-DEFINITION.
