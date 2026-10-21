*&---------------------------------------------------------------------*
*& Include          ZGTSDR1050TOP
*&---------------------------------------------------------------------*
TABLES: ZGTSDT1050.

INCLUDE <CL_ALV_CONTROL>.   " ALV Control (Ex. Fonts, Styles)
INCLUDE <ICON>.             " Icons

* CLASS ZCL_EVENT_RECIEVER DEFINITION
CLASS ZCL_EVENT_RECIEVER DEFINITION DEFERRED.

DATA: BEGIN OF GS_DATA,
        MATNR      LIKE ZGTSDT1050-MATNR,      "자재코드
        MAKTX      LIKE MAKT-MAKTX,            "자재내역
        DANGA      LIKE ZGTSDT1050-DANGA,      "금액
        KUNNR      LIKE ZGTSDT1050-KUNNR,      "판매처
        NAME1      LIKE LFA1-NAME1,            "판매처명
        MEINS      LIKE ZGTSDT1050-MEINS,      "단위
        SPART_GAON LIKE ZGTEDT6800-SPART_GAON, "가온제품제품그룹
        CLRTX      LIKE ZGTEDT6800-CLRTX,      "제품그룹명
        RTMSG(100),
        ID         LIKE ICON-ID,
        WAERS      LIKE ZGTSDT1050-WAERS,      "통화키
        CELL_STY   TYPE LVC_T_STYL,         "cell style
      END OF GS_DATA.
DATA: GT_DATA LIKE TABLE OF GS_DATA.

DATA: GO_CONTAIN_0100 TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA: GO_GRID_0100 TYPE REF TO CL_GUI_ALV_GRID.
DATA: GO_EVTR_0100 TYPE REF TO ZCL_EVENT_RECIEVER.
DATA: GS_VARIANT TYPE DISVARIANT.
DATA: GS_LAYOUT_0100 TYPE LVC_S_LAYO.
DATA: GT_EXCLUDE_0100 TYPE UI_FUNCTIONS.
DATA: GT_FIELDCAT_0100 TYPE LVC_T_FCAT.

DATA: GV_OK_CODE TYPE SYUCOMM,
      GV_DBCNT   TYPE CHAR10,
      GV_REPID   TYPE SYREPID,
      GV_DYNNR   TYPE SY-DYNNR.

CONSTANTS: GC_A TYPE CHAR1           VALUE 'A',
           GC_B TYPE CHAR1           VALUE 'B',
           GC_C TYPE CHAR1           VALUE 'C',
           GC_D TYPE CHAR1           VALUE 'D',
           GC_E TYPE CHAR1           VALUE 'E',
           GC_I TYPE CHAR1           VALUE 'I',
           GC_L TYPE CHAR1           VALUE 'L',
           GC_M TYPE CHAR1           VALUE 'M',
           GC_N TYPE CHAR1           VALUE 'N',
           GC_R TYPE CHAR1           VALUE 'R',
           GC_S TYPE CHAR1           VALUE 'S',
           GC_W TYPE CHAR1           VALUE 'W',
           GC_X TYPE CHAR1           VALUE 'X',
           GC_Y TYPE CHAR1           VALUE 'Y'.
