*&---------------------------------------------------------------------*
*& Include          ZGTSDR1015TOP
*&---------------------------------------------------------------------*
TYPE-POOLS:ESP1,TUMLS,ICON,SLIS.

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES: SSCRFIELDS,
        ZGTSDT1102.


*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS: GC_VKORG_6000 TYPE VKORG   VALUE '6000',
           GC_VTWEG_10   TYPE VTWEG   VALUE '10',
           GC_VTWEG_50   TYPE VTWEG   VALUE '50',
           GC_SPART_3C   TYPE SPART   VALUE '3C',
           GC_SPART_4C   TYPE SPART   VALUE '4C'.

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* STRUCTURE
*----------------------------------------------------------------------*

DATA: BEGIN OF GS_NEW,
        VKORG     LIKE ZGTSDT1102-VKORG,
        VTWEG     LIKE ZGTSDT1102-VTWEG,
        SPART     LIKE ZGTSDT1102-SPART,
        VKGRP     LIKE ZGTSDT1102-VKGRP,
        ZTERM     LIKE ZGTSDT1102-ZTERM,
        ZZDEFAULT LIKE ZGTSDT1102-ZZDEFAULT,
        LOEVM     LIKE ZGTSDT1102-LOEVM,
      END OF GS_NEW.

DATA: GS_OLD LIKE GS_NEW.

*----------------------------------------------------------------------*
* INTERNAL TABLE
*----------------------------------------------------------------------*
DATA: BEGIN OF GT_LIST OCCURS 0,
        STAT1     LIKE ICON-ID,
        STAT2     LIKE ICON-ID,
        SEL(1),

        VKORG     LIKE ZGTSDT1102-VKORG,
        VTWEG     LIKE ZGTSDT1102-VTWEG,
        SPART     LIKE ZGTSDT1102-SPART,
        VKGRP     LIKE ZGTSDT1102-VKGRP,
        VKGRP_TX  LIKE TVGRT-BEZEI,
        ZTERM     LIKE ZGTSDT1102-ZTERM,
        ZTERM_TX  LIKE T052U-TEXT1,
        ZZDEFAULT LIKE ZGTSDT1102-ZZDEFAULT,
        LOEVM     LIKE ZGTSDT1102-LOEVM,
        MSG       LIKE BAPIRET2-MESSAGE.
        INCLUDE STRUCTURE ZGTSDS0000.

DATA:   FLAG1(1),                            "DB존재
        FLAG2(1),                            "신규/변경/삭제
        RSLT(1),                             "ERROR
        CELLTAB   TYPE LVC_T_STYL, "CELL STYLE
      END OF GT_LIST.

DATA: GS_LIST LIKE GT_LIST.

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
RANGES: GR_LOEVM  FOR ZGTSDT1102-LOEVM.


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
