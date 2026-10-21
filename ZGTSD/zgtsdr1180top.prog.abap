*&---------------------------------------------------------------------*
*& Include          ZGTSDR1180TOP
*&---------------------------------------------------------------------*
TYPE-POOLS:ESP1,TUMLS,ICON,SLIS.

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES: SSCRFIELDS,
        VBAK.


*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS: GC_VKORG_6000     TYPE VKORG   VALUE '6000',
           GC_OBJID          TYPE WWWDATA-OBJID VALUE 'ZGTSDR1180',
           GC_ROLE_UKM000    TYPE BU_PARTNERROLE VALUE 'UKM000',
           GC_ADDTYPE_10     TYPE BP_ADDTYPE     VALUE '10',
           GC_ADDTYPE_50     TYPE BP_ADDTYPE     VALUE '50',
           GC_RISK_CLASS_001 TYPE UKM_RISK_CLASS VALUE '001'.

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* STRUCTURE
*----------------------------------------------------------------------*
*-EXCEL UPLOAD
DATA: BEGIN OF GS_EXCEL,
        KUNNR          TYPE KNA1-KUNNR,
        CHECK_RULE     TYPE UKMBP_CMS-CHECK_RULE,
        CRITER         TYPE BP3100-CRITER,
        ADDTYPE        TYPE BP3100-ADDTYPE,
        DATA_TYPE      TYPE BP3100-DATA_TYPE,
        ZZREALEST_AMT  TYPE ACCCR_PA-ERLOS,
        ZZCOLSEC_AMT   TYPE ACCCR_PA-ERLOS,
        ZZCOLSEC_AMT_P TYPE ACCCR_PA-ERLOS,
        AMNT           TYPE ACCCR_PA-ERLOS,
        CURR           TYPE BP3100-CURR,
        DATEFR         TYPE BP3100-DATEFR,
        DATETO         TYPE BP3100-DATETO,
        ZZCOLSEC_PRI   TYPE BP3100-ZZCOLSEC_PRI,
        ZZCOLSEC_SET   TYPE BP3100-ZZCOLSEC_SET,
        ZZGUR_AGY      TYPE BP3100-ZZGUR_AGY,
        ZZAREA         TYPE BP3100-ZZAREA,
        ZZSQUARE       TYPE BP3100-ZZSQUARE,
        ZZADDRESS      TYPE BP3100-ZZADDRESS,
        ZZS_PLAN       TYPE ACCCR_PA-ERLOS,
        ZZC_PLAN_C     TYPE ACCCR_PA-ERLOS,
        ZZC_PLAN_N     TYPE ACCCR_PA-ERLOS,
      END OF GS_EXCEL.


DATA: BEGIN OF GS_ADD_INFO,
        AMOUNT   TYPE UKM_AMOUNT,
        CURRENCY TYPE WAERS.
        INCLUDE STRUCTURE ZUKM_S_ADD_INFO_GO.
DATA:
      END OF GS_ADD_INFO.

DATA: GS_ADDINFO_OLD LIKE GS_ADD_INFO,
      GS_ADDINFO_NEW LIKE GS_ADD_INFO.
*----------------------------------------------------------------------*
* INTERNAL TABLE
*----------------------------------------------------------------------*
DATA: BEGIN OF GT_LIST OCCURS 0,
        SEL(1),                        "선택 체크박스
        STAT1          LIKE ICON-ID,   "엑셀 업로드 체크 결과 ICON
        STAT2          LIKE ICON-ID,   "BP 여신정보 저장 결과 ICON

        KUNNR          LIKE KNA1-KUNNR,
        KUNNR_TX       LIKE ADRC-NAME1,
        PARTNER        LIKE BUT000-PARTNER,
        CHECK_RULE     LIKE UKMBP_CMS-CHECK_RULE,
        CHECK_RULE_TX  LIKE UKM_CHCK_RULE0T-CHECK_RULE_TXT,
        CRITER         LIKE BP3100-CRITER,
        CRITER_TX      LIKE UKMCRED_SGM0T-CREDIT_SGMNT_TXT,
        ADDTYPE        LIKE BP3100-ADDTYPE,
        ADDTYPE_TX     LIKE UKM_INFOCAT0T-INFOCATEGORY_TXT,
        DATA_TYPE      LIKE BP3100-DATA_TYPE,
        DATA_TYPE_TX   LIKE UKM_INFOTYP0T-INFOTYPE_TXT,
        ZZREALEST_AMT  LIKE ACCCR_PA-ERLOS,
        ZZCOLSEC_AMT   LIKE ACCCR_PA-ERLOS,
        ZZCOLSEC_AMT_P LIKE ACCCR_PA-ERLOS,
        AMNT           LIKE ACCCR_PA-ERLOS,
        CURR           LIKE BP3100-CURR,
        DATEFR         LIKE BP3100-DATEFR,
        DATETO         LIKE BP3100-DATETO,
        ZZCOLSEC_PRI   LIKE BP3100-ZZCOLSEC_PRI,
        ZZCOLSEC_SET   LIKE BP3100-ZZCOLSEC_SET,
        ZZGUR_AGY      LIKE BP3100-ZZGUR_AGY,
        ZZAREA         LIKE BP3100-ZZAREA,
        ZZSQUARE       LIKE BP3100-ZZSQUARE,
        ZZADDRESS      LIKE BP3100-ZZADDRESS,
        ZZS_PLAN       LIKE ACCCR_PA-ERLOS,
        ZZC_PLAN_C     LIKE ACCCR_PA-ERLOS,
        ZZC_PLAN_N     LIKE ACCCR_PA-ERLOS,

        MESSAGE        LIKE BAPIRET2-MESSAGE,

        RSLT1(1),  "엑셀 업로드 체크 결과
        RSLT2(2),  "BP 여신정보 저장 결과

        CELLTAB        TYPE LVC_T_STYL, "CELL STYLE
      END OF GT_LIST.
DATA: GS_LIST LIKE LINE OF GT_LIST.
DATA: GT_UKMBP LIKE TABLE OF GS_LIST.

DATA: GT_EXCEL LIKE TABLE OF GS_EXCEL.


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
  GC_SB TYPE C VALUE 'b',
  GC_SS TYPE C VALUE 's',
  GC_SG TYPE C VALUE 'g'.


DEFINE __BAPI_TRANSACTION_COMMIT.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
   EXPORTING
     WAIT          = 'X'.
END-OF-DEFINITION.
DEFINE __BAPI_TRANSACTION_ROLLBACK.
  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
END-OF-DEFINITION.
