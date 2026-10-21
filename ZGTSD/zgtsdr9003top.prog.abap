*&---------------------------------------------------------------------*
*& Include          ZGTSDR9002TOP
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
           GC_OBJID          TYPE WWWDATA-OBJID VALUE 'ZGTSDR9002',
           GC_MTART_MCHA     TYPE MARA-MTART    VALUE 'MCHA',
           GC_ROLE_UKM000    TYPE BU_PARTNERROLE VALUE 'UKM000',
           GC_RISK_CLASS_001 TYPE UKM_RISK_CLASS VALUE '001'.

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* STRUCTURE
*----------------------------------------------------------------------*
*-EXCEL UPLOAD
DATA: BEGIN OF GS_EXCEL,
        VBELN TYPE VBAP-VBELN,                    "판매처
        POSNR TYPE VBAP-POSNR,          "점검규칙
        PSTYV TYPE VBAP-PSTYV,
        LIFSP TYPE VBEP-LIFSP,
      END OF GS_EXCEL.

*----------------------------------------------------------------------*
* INTERNAL TABLE
*----------------------------------------------------------------------*
DATA: BEGIN OF GT_LIST OCCURS 0,
        SEL(1),
        STAT1    LIKE ICON-ID,
        STAT2    LIKE ICON-ID,

        VBELN    LIKE VBAP-VBELN,
*        POSNR    LIKE VBAP-POSNR,
*        MTART    LIKE MARA-MTART,
*        PSTYV_O  LIKE VBAP-PSTYV,
*        LIFSP_O  LIKE VBEP-LIFSP,
*
*        PSTYV    LIKE VBAP-PSTYV,
*        LIFSP    LIKE VBEP-LIFSP,

        MESSAGE  LIKE BAPIRET2-MESSAGE,

        RSLT1(1),
        RSLT2(2),

        CELLTAB  TYPE LVC_T_STYL, "CELL STYLE
      END OF GT_LIST.
DATA: GS_LIST LIKE LINE OF GT_LIST.

DATA: GT_EXCEL LIKE TABLE OF GS_EXCEL.

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
