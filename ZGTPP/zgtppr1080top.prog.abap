*&---------------------------------------------------------------------*
*& Include          ZGTPPR1080TOP
*&---------------------------------------------------------------------*

TABLES: CRHD, SSCRFIELDS.

INCLUDE <CL_ALV_CONTROL>.

DATA: BEGIN OF GS_DATA,
        ZSTAT         LIKE ICON-ID,    "상태
        ZMESSAGE(220),                 "메시지
        ZTYPE(10),                     "유형
        WERKS         LIKE CRHD-WERKS, "플랜트
        ARBPL         LIKE CRHD-ARBPL, "작업장코드
        VERWE         LIKE CRHD-VERWE, "작업장범주
        KTEXT         LIKE CRTX-KTEXT, "작업장내역
        VERAN         LIKE CRHD-VERAN, "책임자
        PLANV         LIKE CRHD-PLANV, "용도
        VGWTS         LIKE CRHD-VGWTS, "표준값키
        STEUS         LIKE CRHD-STEUS, "제어키
        KOSTL         LIKE CRCO-KOSTL, "코스트센터
        LAR01         LIKE CRCO-LSTAR, "액티비티1(유형)
        LEINH01       LIKE CRCO-LEINH, "액티비티1(단위)
        FOR01         LIKE CRCO-FORML, "액티비지1(계산식)
        LAR02         LIKE CRCO-LSTAR, "액티비티2(유형)
        LEINH02       LIKE CRCO-LEINH, "액티비티2(단위)
        FOR02         LIKE CRCO-FORML, "액티비지2(계산식)
        LAR03         LIKE CRCO-LSTAR, "액티비티3(유형)
        LEINH03       LIKE CRCO-LEINH, "액티비티3(단위)
        FOR03         LIKE CRCO-FORML, "액티비지3(계산식)
        LAR04         LIKE CRCO-LSTAR, "액티비티4(유형)
        LEINH04       LIKE CRCO-LEINH, "액티비티4(단위)
        FOR04         LIKE CRCO-FORML, "액티비지4(계산식)
        LAR05         LIKE CRCO-LSTAR, "액티비티5(유형)
        LEINH05       LIKE CRCO-LEINH, "액티비티5(단위)
        FOR05         LIKE CRCO-FORML, "액티비지5(계산식)
        LAR06         LIKE CRCO-LSTAR, "액티비티6(유형)
        LEINH06       LIKE CRCO-LEINH, "액티비티6(단위)
        FOR06         LIKE CRCO-FORML, "액티비지6(계산식)

        DATAB         LIKE CSKS-DATAB,
      END OF GS_DATA.
DATA: GT_DATA LIKE TABLE OF GS_DATA.

DATA: BEGIN OF GS_UPLOAD,
        WERKS(50),
        ARBPL(50),
        VERWE(50),
        KTEXT(50),
        VERAN(50),
        PLANV(50),
        VGWTS(50),
        STEUS(50),
        KOSTL(50),
        LAR01(50),
        LEINH01(50),
        FOR01(50),
        LAR02(50),
        LEINH02(50),
        FOR02(50),
        LAR03(50),
        LEINH03(50),
        FOR03(50),
        LAR04(50),
        LEINH04(50),
        FOR04(50),
        LAR05(50),
        LEINH05(50),
        FOR05(50),
        LAR06(50),
        LEINH06(50),
        FOR06(50),
      END OF GS_UPLOAD.
DATA: GT_UPLOAD LIKE TABLE OF GS_UPLOAD.

DATA: BEGIN OF GS_TC21,
        PAR01 LIKE TC21-PAR01,
        PAR02 LIKE TC21-PAR02,
        PAR03 LIKE TC21-PAR03,
        PAR04 LIKE TC21-PAR04,
        PAR05 LIKE TC21-PAR05,
        PAR06 LIKE TC21-PAR06,
      END OF GS_TC21.

DATA: BEGIN OF GS_TC20T,
        TXT01 LIKE TC20T-TXT,
        TXT02 LIKE TC20T-TXT,
        TXT03 LIKE TC20T-TXT,
        TXT04 LIKE TC20T-TXT,
        TXT05 LIKE TC20T-TXT,
        TXT06 LIKE TC20T-TXT,
      END OF GS_TC20T.

DATA: GO_CONTAIN_0100 TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA: GO_GRID_0100 TYPE REF TO CL_GUI_ALV_GRID.
DATA: GS_VARIANT TYPE DISVARIANT.
DATA: GS_LAYOUT_0100 TYPE LVC_S_LAYO.
DATA: GT_EXCLUDE_0100 TYPE UI_FUNCTIONS.
DATA: GT_FIELDCAT_0100 TYPE LVC_T_FCAT.

*- BDC
DATA: BDCDATA   LIKE BDCDATA    OCCURS 0 WITH HEADER LINE,
      MESSTAB   LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE,
      GS_PARAMS TYPE CTU_PARAMS.

DATA: GV_DYNTXT TYPE SMP_DYNTXT.

DATA: GV_OK_CODE TYPE SYUCOMM,
      GV_DBCNT   TYPE CHAR10.

CONSTANTS: GC_A        TYPE CHAR1           VALUE 'A',
           GC_C        TYPE CHAR1           VALUE 'C',
           GC_D        TYPE CHAR1           VALUE 'D',
           GC_E        TYPE CHAR1           VALUE 'E',
           GC_F        TYPE CHAR1           VALUE 'F',
           GC_I        TYPE CHAR1           VALUE 'I',
           GC_K        TYPE CHAR1           VALUE 'K',
           GC_L        TYPE CHAR1           VALUE 'L',
           GC_M        TYPE CHAR1           VALUE 'M',
           GC_O        TYPE CHAR1           VALUE 'O',
           GC_P        TYPE CHAR1           VALUE 'P',
           GC_R        TYPE CHAR1           VALUE 'R',
           GC_S        TYPE CHAR1           VALUE 'S',
           GC_T        TYPE CHAR1           VALUE 'T',
           GC_W        TYPE CHAR1           VALUE 'W',
           GC_X        TYPE CHAR1           VALUE 'X',
           GC_Y        TYPE CHAR1           VALUE 'Y',
           GC_ALL      TYPE CHAR1           VALUE '*',
           GC_EQ       TYPE CHAR2           VALUE 'EQ',
           GC_BT       TYPE CHAR2           VALUE 'BT',
           C_START_COL TYPE I               VALUE '1',
           C_START_ROW TYPE I               VALUE '4',
           C_END_COL   TYPE I               VALUE '256',
           C_END_ROW   TYPE I               VALUE '65536'.
