*&---------------------------------------------------------------------*
*& Include          ZGTPPR1090TOP
*&---------------------------------------------------------------------*
TABLES: ZGTPPT1080, MARA, MARC, SSCRFIELDS.

INCLUDE <CL_ALV_CONTROL>.

* CLASS ZCL_EVENT_RECIEVER DEFINITION
CLASS ZCL_EVENT_RECIEVER DEFINITION DEFERRED.

DATA: BEGIN OF GS_DATA,
        WERKS    LIKE MARC-WERKS,  "플랜트
        NAME1    LIKE T001W-NAME1, "플랜트내역
        SPART    LIKE MARA-SPART,  "제품군
        VTEXT    LIKE TSPAT-VTEXT, "제품군내역
        MTART    LIKE MARA-MTART,  "자재유형
        MTBEZ    LIKE T134T-MTBEZ, "자재유형내역
        MATKL    LIKE ZGTPPT1080-MATKL,  "자재그룹
        WGBEZ    LIKE ZGTPPT1080-WGBEZ, "자재그룹내역
        STRGR    LIKE MARC-STRGR,  "생산전략
        DISMM    LIKE MARC-DISMM,  "MRP유형
        DISPO    LIKE MARC-DISPO,  "MRP관리자
        DISLS    LIKE MARC-DISLS,  "로트크기유형
        BESKZ    LIKE MARC-BESKZ,  "조달유형
        SOBSL    LIKE MARC-SOBSL,  "특별조달유형
        LGPRO    LIKE MARC-LGPRO,  "생산저장위치
        LGFSB    LIKE MARC-LGFSB,  "외부조달저장위치
        RGEKZ    LIKE MARC-RGEKZ,  "백플러쉬
        MTVFP    LIKE MARC-MTVFP,  "가용성점검
        SBDKZ    LIKE MARC-SBDKZ,  "개별/일괄
        XCHAR    LIKE MARC-XCHAR,  "배치관리
        UEETK    LIKE MARC-UEETK,  "무제한허용
        FEVOR    LIKE MARC-FEVOR,  "생산감독자
        SFCPF    LIKE MARC-SFCPF,  "생산일정프로파일
        DPCBT    LIKE MARC-DPCBT,  "단일단위배치기본값
        KZKUP    LIKE MARC-KZKUP,  "연산품
        DISGR    LIKE MARC-DISGR,  "MRP그룹
        INSMK    LIKE MARC-INSMK,  "검사재고로전기

        CELL_STY TYPE LVC_T_STYL,        "cell style
      END OF GS_DATA.
DATA: GT_DATA LIKE TABLE OF GS_DATA.

DATA: BEGIN OF GS_UPLOAD,
        WERKS(50),
        NAME1(50),
        SPART(50),
        VTEXT(50),
        MTART(50),
        MTBEZ(50),
        MATKL(50),
        WGBEZ(50),
        STRGR(50),
        DISMM(50),
        DISPO(50),
        DISLS(50),
        BESKZ(50),
        SOBSL(50),
        LGPRO(50),
        LGFSB(50),
        RGEKZ(50),
        MTVFP(50),
        SBDKZ(50),
        XCHAR(50),
        UEETK(50),
        FEVOR(50),
        SFCPF(50),
        DPCBT(50),
        KZKUP(50),
        DISGR(50),
        INSMK(50),
      END OF GS_UPLOAD.
DATA: GT_UPLOAD LIKE TABLE OF GS_UPLOAD.

DATA: GO_CONTAIN_0100 TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA: GO_GRID_0100 TYPE REF TO CL_GUI_ALV_GRID.
DATA: GO_EVTR_0100 TYPE REF TO ZCL_EVENT_RECIEVER.
DATA: GS_VARIANT TYPE DISVARIANT.
DATA: GS_LAYOUT_0100 TYPE LVC_S_LAYO.
DATA: GT_EXCLUDE_0100 TYPE UI_FUNCTIONS.
DATA: GT_FIELDCAT_0100 TYPE LVC_T_FCAT.

DATA: GV_DYNTXT TYPE SMP_DYNTXT.

DATA: GV_OK_CODE TYPE SYUCOMM,
      GV_DBCNT   TYPE CHAR10.

DATA: GV_ERROR(1).

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
           C_START_COL TYPE I               VALUE '2',
           C_START_ROW TYPE I               VALUE '7',
           C_END_COL   TYPE I               VALUE '256',
           C_END_ROW   TYPE I               VALUE '65536'.
