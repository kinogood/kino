*&---------------------------------------------------------------------*
*& Include          ZGTSDR1160TOP
*&---------------------------------------------------------------------*
TYPE-POOLS:ESP1,TUMLS,ICON,SLIS.

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES: SSCRFIELDS,
        VBAK,VBAP,
        ZGTSDT1199.


*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS: GC_VKORG_6000  TYPE VKORG   VALUE '6000',
           GC_DOMAIN_TYPE TYPE DD07L-DOMNAME VALUE 'ZGTD_LABEL_TYPE',
           GC_LENGTH      LIKE CABN-ATNAM VALUE 'SAP_LENGTH_VKRME'. "조장
*           GC_VTWEG_10   TYPE VTWEG   VALUE '10',
*           GC_VTWEG_50   TYPE VTWEG   VALUE '50',
*           GC_SPART_3C   TYPE SPART   VALUE '3C',
*           GC_SPART_4C   TYPE SPART   VALUE '4C'.

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* STRUCTURE
*----------------------------------------------------------------------*
DATA: BEGIN OF GS_HEAD,
        VBELN            LIKE VBAP-VBELN,
        POSNR            LIKE VBAP-POSNR,
        MATNR            LIKE VBAP-MATNR,
        MAKTX            LIKE MAKT-MAKTX,
        INDQTY           TYPE P DECIMALS 0,               "조장수
        ZZLABEL_TYPE     TYPE ZGTSDT1199-ZZLABEL_TYPE,    "라벨종류
        ZZLABEL_PRTQT    TYPE ZGTSDT1199-ZZLABEL_PRTQT,   "라벨장수
        ZZLABEL_TITLE1_N TYPE ZGTSDT1199-ZZLABEL_TITLE1_N,"1단TITLE제목
        ZZLABEL_TITLE2_N TYPE ZGTSDT1199-ZZLABEL_TITLE2_N,"2단TITLE제목
        ZZLABEL_TITLE3_N TYPE ZGTSDT1199-ZZLABEL_TITLE3_N,"3단TITLE제목
        ZZLABEL_TITLE4_N TYPE ZGTSDT1199-ZZLABEL_TITLE4_N,"4단TITLE제목
      END OF GS_HEAD.
DATA: *GS_HEAD LIKE GS_HEAD.

DATA: GS_DATA_NEW TYPE ZGTSDS0037,
      GS_DATA_OLD TYPE ZGTSDS0037.

*----------------------------------------------------------------------*
* INTERNAL TABLE
*----------------------------------------------------------------------*
"OUTPUT LIST
DATA: BEGIN OF GT_LIST OCCURS 0,
        STAT     LIKE ICON-ID.
        INCLUDE STRUCTURE ZGTSDT1199.
DATA:
        UPDKZ(1),
        RSLT(1),
        CELLTAB  TYPE LVC_T_STYL,
      END OF GT_LIST.

DATA: GS_LIST LIKE GT_LIST.

"DB
DATA: GT_DATA_DB TYPE TABLE OF ZGTSDT1199.

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

DATA: GV_FNAME(20).

DATA: GV_ERDAT      TYPE SY-DATUM,
      GV_ERZET      TYPE SY-UZEIT,
      GV_TCODE      TYPE SY-TCODE,
      GV_UNAME      TYPE SY-UNAME,
      GV_OBJECTID   TYPE CDHDR-OBJECTID,
      GV_CHANGE_IND TYPE CDHDR-CHANGE_IND.

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
