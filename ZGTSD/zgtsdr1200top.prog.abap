*&---------------------------------------------------------------------*
*& Include          ZGTSDR1200TOP
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
           GC_OBJECTCLAS  TYPE CDHDR-OBJECTCLAS VALUE 'BUPA_FS06',
           GC_ROLE_UKM000 TYPE BU_PARTNERROLE VALUE 'UKM000',
           GC_ADDTYPE_10  TYPE BP3100-ADDTYPE VALUE '10',
           GC_DATATYPE_01 TYPE BP3100-DATA_TYPE VALUE '01'.

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
        VKBUR          LIKE  VBAK-VKBUR,                  "영업팀
        VKBUR_TX       LIKE  TVKBT-BEZEI,
        VKGRP          LIKE  VBAK-VKGRP,                  "영업그룹
        VKGRP_TX       LIKE  TVGRT-BEZEI,
        CRITER         LIKE  BP3100-CRITER,               "여신세그먼트
        PARTNER        LIKE  BP3100-PARTNER,              "BP
        KUNNR          LIKE  KNA1-KUNNR,                  "판매처
        KUNNR_TX       LIKE  ADRC-NAME1,
        ADDTYPE        LIKE  BP3100-ADDTYPE,              "정보범주
        ADDTYPE_TX     LIKE  UKM_INFOCAT0T-INFOCATEGORY_TXT,
        MULGUN(20),                                       "물건
        DATA_TYPE      LIKE  BP3100-DATA_TYPE,            "정보유형
        DATA_TYPE_TX   LIKE  UKM_INFOTYP0T-INFOTYPE_TXT,
        AMNT           LIKE  BP3100-AMNT,                 "유효담보
        DATEFR         LIKE  BP3100-DATEFR,               "시작일
        DATETO         LIKE  BP3100-DATETO,               "종료일
        ZZGUR_AGY      LIKE  BP3100-ZZGUR_AGY,            "보증기관
        ZZAREA         LIKE  BP3100-ZZAREA,               "지역
        ZZSQUARE       LIKE  BP3100-ZZSQUARE,             "M2
        ZZCOLSEC_AMT   LIKE  BP3100-ZZCOLSEC_AMT,         "근저당설정액
        ZZCOLSEC_PRI   LIKE  BP3100-ZZCOLSEC_PRI,         "근저당순위
        ZZCOLSEC_SET   LIKE  BP3100-ZZCOLSEC_SET,         "근저당설정일
        ZZCOLSEC_AMT_P LIKE  BP3100-ZZCOLSEC_AMT_P,       "선순위금액
        ZZREALEST_AMT  LIKE  BP3100-ZZREALEST_AMT,        "부동산시세
        UDATE          LIKE  CDHDR-UDATE,                 "입력일자
        ZZADDRESS      LIKE  BP3100-ZZADDRESS,            "상세주소
        TEXT           LIKE  BP3100-TEXT,                 "비고
        CHG_TEXT(10),                                     "비교년월변동내역
        XFELD          LIKE  BP3100-XFELD,                "관련

        MANDT          TYPE BP3100-MANDT,
        COUNTER        TYPE BP3100-COUNTER,               "카운터
        CURR           TYPE BP3100-CURR,                  "통화키
        TABKEY         TYPE CDPOS-TABKEY,                 "변경이력TABLE KEY
        OBJECTID       TYPE CDHDR-OBJECTID,

        CELLTAB        TYPE LVC_T_STYL, "CELL STYLE
      END OF GT_LIST.

DATA: GS_LIST LIKE GT_LIST.

DATA: GT_MAIN LIKE TABLE OF GS_LIST.


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
