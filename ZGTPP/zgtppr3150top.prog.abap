*&---------------------------------------------------------------------*
*& Include          ZGTPPR3150TOP
*&---------------------------------------------------------------------*
TABLES: ZGTPPT3320, ZGTPPT3330, AUFK, SSCRFIELDS, MARA, MARC.

INCLUDE <CL_ALV_CONTROL>.   " ALV Control (Ex. Fonts, Styles)

* CLASS ZCL_EVENT_RECIEVER DEFINITION
CLASS ZCL_EVENT_RECIEVER DEFINITION DEFERRED.

DATA: BEGIN OF GS_3320,
        WERKS         LIKE ZGTPPT3320-WERKS,  "플랜트
        NAME1         LIKE T001W-NAME1,       "플랜트내역
        F_MATN        LIKE MARA-MATNR,        "전환전품목코드
        F_MAKTX       LIKE MAKT-MAKTX,        "전환전품목내역
        F_LGORT       LIKE T001L-LGORT,       "전환전품목창고
        F_LGOBE       LIKE T001L-LGOBE,       "전환전창고내역
        T_MATN        LIKE MARA-MATNR,        "전환후품목코드
        T_MAKTX       LIKE MAKT-MAKTX,        "전환후품목내역
        T_LGORT       LIKE T001L-LGORT,       "전환후품목창고
        T_LGOBE       LIKE T001L-LGOBE,       "전환후창고내역
        ADD_GI        LIKE ZGTPPT3320-ADD_GI, "추가투입
        BOM_STAT      LIKE ICON-ID,           "BOM상태
        ROUT_STAT     LIKE ICON-ID,           "라우팅상태
        PVER_STAT     LIKE ICON-ID,           "생산버전상태
        PROC_MSG(100),                        "처리메시지

        STLNR         LIKE MAST-STLNR,        "BOM번호
        STLAL         LIKE MAST-STLAL,        "대체BOM
        STLAN         LIKE MAST-STLAN,        "BOM용도
        PLNTY         LIKE MAPL-PLNTY,        "태스크리스크유형
        PLNNR         LIKE MAPL-PLNNR,        "라우팅그룹번호
        PLNAL         LIKE MAPL-PLNAL,        "그룹카운터
        DATUV         LIKE MAPL-DATUV,        "라우팅효력시작일

        CELL_STY      TYPE LVC_T_STYL,        "cell style
      END OF GS_3320.
DATA: GT_3320   LIKE TABLE OF GS_3320,
      GT_3320_B LIKE TABLE OF GS_3320.  "BOM ITEM용

DATA: BEGIN OF GS_PROC,
        WERKS         LIKE ZGTPPT3320-WERKS,  "플랜트
        NAME1         LIKE T001W-NAME1,       "플랜트내역
        F_MATN        LIKE MARA-MATNR,        "전환전품목코드
        F_MAKTX       LIKE MAKT-MAKTX,        "전환전품목내역
        F_LGORT       LIKE T001L-LGORT,       "전환전품목창고
        F_LGOBE       LIKE T001L-LGOBE,       "전환전창고내역
        F_LABST       LIKE MARD-LABST,        "전환전품목재고
        T_MATN        LIKE MARA-MATNR,        "전환후품목코드
        T_MAKTX       LIKE MAKT-MAKTX,        "전환후품목내역
        T_LGORT       LIKE T001L-LGORT,       "전환후품목창고
        T_LGOBE       LIKE T001L-LGOBE,       "전환후창고내역
        T_LABST       LIKE MARD-LABST,        "전환후품목재고
        PSTD_STAT     LIKE ICON-ID,           "생산기준정보상태
        AUART         LIKE AUFK-AUART,        "오더유형
        ZMESSAGE(100),                        "메시지
        1ST_STAT      LIKE ICON-ID,           "오더상태
        AUFNR         LIKE ZGTPPT3330-AUFNR,  "생산오더번호
        PSMNG         LIKE AFPO-PSMNG,        "전환 품목 수량
        MEINS         LIKE MARA-MEINS,        "전환 품목 단위
        2ND_STAT      LIKE ICON-ID,           "투입상태
        F_MBLNR       LIKE MSEG-MBLNR,        "전환 전 품목 투입
        3RD_STAT      LIKE ICON-ID,           "입고상태
        T_MBLNR       LIKE MSEG-MBLNR,        "전환 후 품목 입고
        4TH_STAT      LIKE ICON-ID,           "확정상태
        RUECK         LIKE AFRU-RUECK,        "확정번호
        BUDAT         LIKE MKPF-BUDAT,        "전기일자
        CRDAT         LIKE ZGTPPT3330-CRDAT,  "생성일자
        CRTIM         LIKE ZGTPPT3330-CRTIM,  "생성시간
        CRNAM         LIKE ZGTPPT3330-CRNAM,  "생성자

        F_MJAHR       LIKE MSEG-MJAHR,
        T_MJAHR       LIKE MSEG-MJAHR,
        RMZHL         LIKE AFRU-RMZHL,
        GSTRP         LIKE AFKO-GSTRP,
        ADD_GI        LIKE ZGTPPT3320-ADD_GI, "추가투입

        CELL_STY      TYPE LVC_T_STYL,        "cell style
      END OF GS_PROC.
DATA: GT_PROC LIKE TABLE OF GS_PROC,
      GT_PROX LIKE TABLE OF GS_PROC.   "추가투입용

*- BDC
DATA: BDCDATA   LIKE BDCDATA    OCCURS 0 WITH HEADER LINE,
      MESSTAB   LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE,
      GS_PARAMS TYPE CTU_PARAMS.

DATA: GO_CONTAIN_0100 TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA: GO_GRID_0100 TYPE REF TO CL_GUI_ALV_GRID.
DATA: GO_EVTR_0100 TYPE REF TO ZCL_EVENT_RECIEVER.
DATA: GS_VARIANT_0100 TYPE DISVARIANT.
DATA: GS_LAYOUT_0100 TYPE LVC_S_LAYO.
DATA: GT_EXCLUDE_0100 TYPE UI_FUNCTIONS.
DATA: GT_FIELDCAT_0100 TYPE LVC_T_FCAT.

DATA: GO_CONTAIN_0200 TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA: GO_GRID_0200 TYPE REF TO CL_GUI_ALV_GRID.
DATA: GS_VARIANT_0200 TYPE DISVARIANT.
DATA: GS_LAYOUT_0200 TYPE LVC_S_LAYO.
DATA: GT_EXCLUDE_0200 TYPE UI_FUNCTIONS.
DATA: GT_FIELDCAT_0200 TYPE LVC_T_FCAT.

DATA: GV_DYNTXT TYPE SMP_DYNTXT.

DATA: GT_UCOMM TYPE TABLE OF SY-UCOMM.

DATA: GV_TIMESTAMP TYPE TIMESTAMPL,
      GV_ZSEQNO    TYPE N LENGTH 10.

DATA: GV_OK_CODE TYPE SYUCOMM,
      GV_DBCNT   TYPE CHAR10.

DATA: GV_REPID TYPE SYREPID,
      GV_VALID TYPE CHAR01,
      GV_INDEX TYPE SY-TABIX,
      GV_TEXT  TYPE CHAR255.

CONSTANTS: GC_C    TYPE CHAR1           VALUE 'C',
           GC_D    TYPE CHAR1           VALUE 'D',
           GC_E    TYPE CHAR1           VALUE 'E',
           GC_F    TYPE CHAR1           VALUE 'F',
           GC_I    TYPE CHAR1           VALUE 'I',
           GC_L    TYPE CHAR1           VALUE 'L',
           GC_M    TYPE CHAR1           VALUE 'M',
           GC_N    TYPE CHAR1           VALUE 'N',
           GC_O    TYPE CHAR1           VALUE 'O',
           GC_P    TYPE CHAR1           VALUE 'P',
           GC_R    TYPE CHAR1           VALUE 'R',
           GC_S    TYPE CHAR1           VALUE 'S',
           GC_W    TYPE CHAR1           VALUE 'W',
           GC_X    TYPE CHAR1           VALUE 'X',
           GC_Y    TYPE CHAR1           VALUE 'Y',
           GC_ALL  TYPE CHAR1           VALUE '*',
           GC_BT   TYPE CHAR2           VALUE 'BT',
           GC_101  TYPE BWART           VALUE '101',
           GC_261  TYPE BWART           VALUE '261',
           GC_PP01 TYPE AUFART          VALUE 'PP01'.
