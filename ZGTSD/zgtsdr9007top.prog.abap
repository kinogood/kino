*&---------------------------------------------------------------------*
*& Include          ZGTSDR9007TOP
*&---------------------------------------------------------------------*
TABLES: VBAP.

INCLUDE <CL_ALV_CONTROL>.   " ALV Control (Ex. Fonts, Styles)

DATA: BEGIN OF GS_ODATA,
        VBELN     LIKE VBAP-VBELN,
        POSNR     LIKE VBAP-POSNR,
        VKGRP_ANA LIKE VBAP-VKGRP_ANA,
      END OF GS_ODATA.
DATA: GT_ODATA LIKE TABLE OF GS_ODATA.

DATA: BEGIN OF GS_DATA,
        VBELN     LIKE VBAP-VBELN,
        VKGRP_ANA LIKE VBAP-VKGRP_ANA,
        ZMSG(100),

        CNT       TYPE I, "품목수
      END OF GS_DATA.
DATA: GT_DATA LIKE TABLE OF GS_DATA.

* BDC
DATA: BDCDATA   LIKE BDCDATA    OCCURS 0 WITH HEADER LINE,
      MESSTAB   LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE,
      GS_PARAMS TYPE CTU_PARAMS.

DATA: GO_CONTAIN_0100 TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA: GO_GRID_0100 TYPE REF TO CL_GUI_ALV_GRID.
*DATA: GO_EVTR_0100 TYPE REF TO ZCL_EVENT_RECIEVER.
DATA: GS_VARIANT_0100 TYPE DISVARIANT.
DATA: GS_LAYOUT_0100 TYPE LVC_S_LAYO.
DATA: GT_EXCLUDE_0100 TYPE UI_FUNCTIONS.
DATA: GT_FIELDCAT_0100 TYPE LVC_T_FCAT.

DATA: GT_UCOMM TYPE TABLE OF SY-UCOMM.

DATA: GV_OK_CODE TYPE SYUCOMM,
      GV_DBCNT   TYPE CHAR10.

DATA: GV_REPID TYPE SYREPID,
      GV_VALID TYPE CHAR01,
      GV_INDEX TYPE SY-TABIX,
      GV_TEXT  TYPE CHAR255.

CONSTANTS: GC_C   TYPE CHAR1           VALUE 'C',
           GC_D   TYPE CHAR1           VALUE 'D',
           GC_E   TYPE CHAR1           VALUE 'E',
           GC_F   TYPE CHAR1           VALUE 'F',
           GC_I   TYPE CHAR1           VALUE 'I',
           GC_L   TYPE CHAR1           VALUE 'L',
           GC_M   TYPE CHAR1           VALUE 'M',
           GC_N   TYPE CHAR1           VALUE 'N',
           GC_O   TYPE CHAR1           VALUE 'O',
           GC_P   TYPE CHAR1           VALUE 'P',
           GC_R   TYPE CHAR1           VALUE 'R',
           GC_S   TYPE CHAR1           VALUE 'S',
           GC_W   TYPE CHAR1           VALUE 'W',
           GC_X   TYPE CHAR1           VALUE 'X',
           GC_Y   TYPE CHAR1           VALUE 'Y',
           GC_ALL TYPE CHAR1           VALUE '*'.
