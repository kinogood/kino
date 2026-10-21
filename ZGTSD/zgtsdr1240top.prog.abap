*&---------------------------------------------------------------------*
*& Include          ZGTSDR1240TOP
*&---------------------------------------------------------------------*
TYPE-POOLS:ESP1,TUMLS,ICON,SLIS.

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES: SSCRFIELDS,
        VBAK,
        BUT050,
        BURS_JOEL_MAIN.


*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS:
  GC_VKORG_6000     TYPE VKORG          VALUE '6000',
  GC_KTOKD_0001     TYPE KTOKD          VALUE '0001',
  GC_KTOKD_0003     TYPE KTOKD          VALUE '0003',
  GC_ROLE_UKM000    TYPE BU_PARTNERROLE VALUE 'UKM000',
  GC_RELTYP_UKM001  TYPE BU_RELTYP      VALUE 'UKM001',
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
DATA: BEGIN OF GT_LIST OCCURS 0,
        SEL(1),
        STAT1         LIKE  ICON-ID,                   "BP 여신확장
        STAT2         LIKE  ICON-ID,                   "BP RELATION

        KUNNR1        LIKE KNA1-KUNNR,                 "내수고객
        PARTNER1      LIKE BUT050-PARTNER1,            "내수BP
        KUNNR1_TX     LIKE ADRC-NAME1,                 "내수고객명
        CHECK_RULE1   LIKE UKMBP_CMS-CHECK_RULE,       "내수점검규칙
        CREDIT_SGMNT1 LIKE UKMBP_CMS_SGM-CREDIT_SGMNT, "내수CREDIT SEGM

        KUNNR2        LIKE KNA1-KUNNR,                 "로컬지급처
        PARTNER2      LIKE BUT050-PARTNER2,            "로컬BP
        KUNNR2_TX     LIKE ADRC-NAME1,                 "로컬지급처명
        CHECK_RULE2   LIKE UKMBP_CMS-CHECK_RULE,       "로컬점검규칙
        CREDIT_SGMNT2 LIKE UKMBP_CMS_SGM-CREDIT_SGMNT, "로컬CREDIT SEGM
        MESSAGE       LIKE BAPIRET2-MESSAGE,

        FLAG_C(1),                                     "여신영역
        FLAG_S(1),                                     "여신세그먼트
        FLAG_R(1),                                     "내수-로컬 연결
        FLAG_X(1),                                     "오류
        RSLT(1),
        CELLTAB       TYPE  LVC_T_STYL, "CELL STYLE
      END OF GT_LIST.
DATA: GS_LIST LIKE GT_LIST.



DATA GT_DIRECTED_TYPES  TYPE BURS_RELATIONSHIP-DIRECTED_TYPE_TABLE.
DATA GT_DROPDOWN_VALUES TYPE BUS_SCREEN-DROPDOWN_VALUES.
CONSTANTS:
  BEGIN OF GC_TYPE,
    UNSPECIFIED  TYPE BUS_PARTNER-TYPE VALUE ' ',
    PERSON       TYPE BUS_PARTNER-TYPE VALUE '1',
    ORGANIZATION TYPE BUS_PARTNER-TYPE VALUE '2',
    GROUP        TYPE BUS_PARTNER-TYPE VALUE '3',
  END OF GC_TYPE,

  BEGIN OF GC_DIRECTION,
    NONE TYPE BURS_RELATIONSHIP-DIRECTION VALUE 'N',
    FROM TYPE BURS_RELATIONSHIP-DIRECTION VALUE 'F',
    TO   TYPE BURS_RELATIONSHIP-DIRECTION VALUE 'T',
  END OF GC_DIRECTION.

DATA: GT_ZGTSDT9041 TYPE TABLE OF ZGTSDT9041.

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

DATA: GV_RELTYP TYPE BU_RELTYP.

*----------------------------------------------------------------------*
* FIELD-SYMBOLS
*----------------------------------------------------------------------*
*FIELD-SYMBOLS:


*----------------------------------------------------------------------*
* RANGES
*----------------------------------------------------------------------*
RANGES:
        GR_SGMNT FOR UKM_KKBER2SGM-CREDIT_SGMNT.


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
