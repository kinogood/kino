*&---------------------------------------------------------------------*
*& Include          ZGTSDR9990TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES: SSCRFIELDS,
        VBAK.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS: GC_VKORG_6000  TYPE VKORG   VALUE '6000'.


*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* STRUCTURE
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* INTERNAL TABLE
*----------------------------------------------------------------------*
DATA: BEGIN OF GT_VIEWNAME OCCURS 0,
        FCODE(10),
        VIEWNAME LIKE DD02V-TABNAME,
      END OF GT_VIEWNAME.

DATA: GT_SELECTIONS TYPE TABLE OF VIMSELLIST.

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

DATA: GV_VIEWNAME TYPE DD02V-TABNAME,
      GV_CLUSNAME TYPE VCLDIR-VCLNAME,
      GV_ACTION(1).


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

DEFINE ADDSEL.
  CALL FUNCTION 'VIEW_RANGETAB_TO_SELLIST'
    EXPORTING
      FIELDNAME          = &1
      APPEND_CONJUNCTION = 'AND'
    TABLES
      SELLIST            = GT_SELECTIONS
      RANGETAB           = &2[].
END-OF-DEFINITION.
DEFINE ADDPARAM.
  IF &2 IS NOT INITIAL.
    APPEND VALUE #( VIEWFIELD = &1
                    VALUE     = &2
                    AND_OR    = 'AND'
                    OPERATOR  = 'EQ'
                  ) TO GT_SELECTIONS.
  ENDIF.
END-OF-DEFINITION.
