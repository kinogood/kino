FUNCTION-POOL ZNF2100  MESSAGE-ID ZNF2.


*----------------------------------------------------------------------*
* TYPE-POOLS
*----------------------------------------------------------------------*
TYPE-POOLS: SLIS,   ICON.



*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES: ZNFT1002.


*----------------------------------------------------------------------*
* VARIABLES
*----------------------------------------------------------------------*
DATA: GV_FCODE LIKE SY-UCOMM,
      GV_INDEX LIKE SY-TABIX,
      GV_READ  TYPE CHAR01.

DATA: GV_FLAG1,
      GV_FLAG2,
      GV_FLAG3,
      GV_FLAG4,
      GV_FLAG5,
      GV_FLAG6,
      GV_FLAG7,
      GV_FLAG8,
      GV_FLAG9,
      GV_FLAG10.

DATA  : LT_FILE      TYPE FILETABLE,
        LV_RC        TYPE I,
        LV_FNAME     TYPE STRING.

*----------------------------------------------------------------------*
* STRUCTURE
*----------------------------------------------------------------------*
DATA: BEGIN OF GS_ZNFT1002.
        INCLUDE STRUCTURE ZNFT1002.
DATA: FILEP  LIKE ZNFT1002-LINK1,
      END   OF GS_ZNFT1002.
