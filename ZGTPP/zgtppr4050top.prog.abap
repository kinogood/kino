*&---------------------------------------------------------------------*
*& Include          ZGTPPR4050TOP
*&---------------------------------------------------------------------*
TABLES: MATDOC, EKKO, EKPO, AFPO, RESB, MARA,
        ZGTEDT2121, ZGTSDT0067.

* CLASS ZCL_EVENT_RECIEVER DEFINITION
CLASS ZCL_EVENT_RECIEVER DEFINITION DEFERRED.

DATA: BEGIN OF GS_DATA,
        IN_STAT    LIKE ICON-ID,               "생산투입여부
        WERKS      LIKE MATDOC-WERKS,          "플랜트
        NAME1      LIKE T001W-NAME1,           "플랜트내역
        ZPJT_NO    LIKE ZGTEDT2121-ZPJT_NO,    "프로젝트번호
        ZPTXT      LIKE ZSD0106T-ZPTXT,        "프로젝트내역
        JOB_NO     LIKE ZGTPPT3160-JOB_NO,     "제조지시번호
        JOB_NM     LIKE ZGTEDT2121-ZJOB_NAME,  "제조지시내역
        MATNR      LIKE MATDOC-MATNR,          "자재코드
        MAKTX      LIKE MAKT-MAKTX,            "자재내역
        MTART      LIKE MARA-MTART,            "자재유형
        MTBEZ      LIKE T134T-MTBEZ,           "자재유형내역
        MATKL      LIKE MARA-MATKL,            "자재그룹
        WGBEZ      LIKE T023T-WGBEZ,           "자재그룹내역
        PO_MENGE   LIKE MATDOC-MENGE,          "구매입고수량
        PO_MEINS   LIKE MATDOC-MEINS,          "구매단위
        PRD_MENGE  LIKE MATDOC-MENGE,          "생산투입수량
        PRD_MEINS  LIKE MATDOC-MEINS,          "투입단위
        DIFF_MENGE LIKE MATDOC-MENGE,          "차이수량
        BLD_MENGE  LIKE ZGTPPT3000-ERFMG,      "백로그삭제수량
        BLD_MEINS  LIKE ZGTPPT3000-ERFME,      "백로그단위
      END OF GS_DATA.
DATA: GT_DATA LIKE TABLE OF GS_DATA.

DATA: BEGIN OF GS_PO,
        EBELN    LIKE EKPO-EBELN,            "구매오더번호
        EBELP    LIKE EKPO-EBELP,            "구매오더품목
        ZPJT_NO  LIKE ZGTEDT2121-ZPJT_NO,    "프로젝트번호
        ZPTXT    LIKE ZSD0106T-ZPTXT,        "프로젝트내역
        JOB_NO   LIKE ZGTPPT3160-JOB_NO,     "제조지시번호
        JOB_NM   LIKE ZGTEDT2121-ZJOB_NAME,  "제조지시내역
        MATNR    LIKE MATDOC-MATNR,          "자재코드
        MAKTX    LIKE MAKT-MAKTX,            "자재내역
        PO_MENGE LIKE MATDOC-MENGE,          "구매입고수량
        PO_MEINS LIKE MATDOC-MEINS,          "구매단위
        MBLNR    LIKE MATDOC-MBLNR,          "자재문서번호
        MJAHR    LIKE MATDOC-MJAHR,          "자재문서연도

        WERKS    LIKE MATDOC-WERKS,          "플랜트
        NAME1    LIKE T001W-NAME1,           "플랜트내역
        MTART    LIKE MARA-MTART,            "자재유형
        MTBEZ    LIKE T134T-MTBEZ,           "자재유형내역
        MATKL    LIKE MARA-MATKL,            "자재그룹
        WGBEZ    LIKE T023T-WGBEZ,           "자재그룹내역
        ZEILE    LIKE MATDOC-ZEILE,
      END OF GS_PO.
DATA: GT_OPO LIKE TABLE OF GS_PO WITH EMPTY KEY,
      GT_PO  LIKE TABLE OF GS_PO.

DATA: BEGIN OF GS_PROD,
        AUFNR     LIKE MATDOC-AUFNR,          "생산오더번호
        ZPJT_NO   LIKE ZGTEDT2121-ZPJT_NO,    "프로젝트번호
        ZPTXT     LIKE ZSD0106T-ZPTXT,        "프로젝트내역
        JOB_NO    LIKE ZGTPPT3160-JOB_NO,     "제조지시번호
        JOB_NM    LIKE ZGTEDT2121-ZJOB_NAME,  "제조지시내역
        MATNR     LIKE MATDOC-MATNR,          "자재코드
        MAKTX     LIKE MAKT-MAKTX,            "자재내역
        PRD_MENGE LIKE MATDOC-MENGE,          "투입수량
        PRD_MEINS LIKE MATDOC-MEINS,          "투입단위
        MBLNR     LIKE MATDOC-MBLNR,          "자재문서번호
        MJAHR     LIKE MATDOC-MJAHR,          "자재문서연도

        ZEILE     LIKE MATDOC-ZEILE,
      END OF GS_PROD.
DATA: GT_OPROD LIKE TABLE OF GS_PROD,
      GT_PROD  LIKE TABLE OF GS_PROD.

DATA: BEGIN OF GS_SUM,
        WERKS   LIKE MATDOC-WERKS,          "플랜트
        NAME1   LIKE T001W-NAME1,           "플랜트내역
        ZPJT_NO LIKE ZGTEDT2121-ZPJT_NO,    "프로젝트번호
        ZPTXT   LIKE ZSD0106T-ZPTXT,        "프로젝트내역
        JOB_NO  LIKE ZGTPPT3160-JOB_NO,     "제조지시번호
        JOB_NM  LIKE ZGTEDT2121-ZJOB_NAME,  "제조지시내역
        MATNR   LIKE MATDOC-MATNR,          "자재코드
        MAKTX   LIKE MAKT-MAKTX,            "자재내역
        MTART   LIKE MARA-MTART,            "자재유형
        MTBEZ   LIKE T134T-MTBEZ,           "자재유형내역
        MATKL   LIKE MARA-MATKL,            "자재그룹
        WGBEZ   LIKE T023T-WGBEZ,           "자재그룹내역
        SMENGE  TYPE MENG15,                "수량SUM
        MEINS   LIKE MATDOC-MEINS,          "단위
      END OF GS_SUM.
DATA: GT_PO_SUM   LIKE TABLE OF GS_SUM,
      GT_PROD_SUM LIKE TABLE OF GS_SUM.

DATA: BEGIN OF GS_BLD,
        JOB_NO  LIKE ZGTPPT3160-JOB_NO,
        WEBLNR  TYPE WEBLNR,
        WEBLPOS TYPE CIM_COUNT,
        MATNR   TYPE MATNR,
        BWART	  TYPE BWART,
        ERFMG	  TYPE ERFMG,
        ERFME	  TYPE ERFME,
        AUFNR	  TYPE AUFNR,
      END OF GS_BLD.
DATA: GT_BLD LIKE TABLE OF GS_BLD.

DATA: BEGIN OF GS_BLD_SUM,
        JOB_NO LIKE ZGTPPT3160-JOB_NO,
        MATNR  TYPE MATNR,
        SERFMG TYPE MENG15,
        ERFME  TYPE ERFME,
      END OF GS_BLD_SUM.
DATA: GT_BLD_SUM LIKE TABLE OF GS_BLD_SUM.

DATA: GO_DOCKING_CONTAINER TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA: GO_SPLITTER TYPE REF TO CL_GUI_SPLITTER_CONTAINER.
DATA: GO_SPLITTER2 TYPE REF TO CL_GUI_SPLITTER_CONTAINER.
DATA: GO_EVTR TYPE REF TO ZCL_EVENT_RECIEVER.

*- ALV GRID TOP
DATA: GO_CONTAIN_0100 TYPE REF TO CL_GUI_CONTAINER.
DATA: GO_GRID_0100 TYPE REF TO CL_GUI_ALV_GRID.
DATA: GS_VARIANT TYPE DISVARIANT.
DATA: GS_LAYOUT_0100 TYPE LVC_S_LAYO.
DATA: GT_SORT_0100 TYPE LVC_T_SORT.
DATA: GT_EXCLUDE_0100 TYPE UI_FUNCTIONS.
DATA: GT_FIELDCAT_0100 TYPE LVC_T_FCAT.

*- ALV GRID BOTTOM
DATA: GO_CONTAIN_0200 TYPE REF TO CL_GUI_CONTAINER.

*- ALV GRID BOTTOM LEFT
DATA: GO_CONTAIN_0101 TYPE REF TO CL_GUI_CONTAINER.
DATA: GO_GRID_0101 TYPE REF TO CL_GUI_ALV_GRID.
DATA: GS_LAYOUT_0101 TYPE LVC_S_LAYO.
DATA: GT_SORT_0101 TYPE LVC_T_SORT.
DATA: GT_EXCLUDE_0101 TYPE UI_FUNCTIONS.
DATA: GT_FIELDCAT_0101 TYPE LVC_T_FCAT.

*- ALV GRID BOTTOM RIGHT
DATA: GO_CONTAIN_0102 TYPE REF TO CL_GUI_CONTAINER.
DATA: GO_GRID_0102 TYPE REF TO CL_GUI_ALV_GRID.
DATA: GS_LAYOUT_0102 TYPE LVC_S_LAYO.
DATA: GT_SORT_0102 TYPE LVC_T_SORT.
DATA: GT_EXCLUDE_0102 TYPE UI_FUNCTIONS.
DATA: GT_FIELDCAT_0102 TYPE LVC_T_FCAT.

DATA: GT_UCOMM TYPE TABLE OF SY-UCOMM.

DATA: GV_OK_CODE TYPE SYUCOMM,
      GV_DBCNT   TYPE CHAR10.

CONSTANTS: GC_C    TYPE CHAR1            VALUE 'C',
           GC_D    TYPE CHAR1            VALUE 'D',
           GC_E    TYPE CHAR1            VALUE 'E',
           GC_F    TYPE CHAR1            VALUE 'F',
           GC_I    TYPE CHAR1            VALUE 'I',
           GC_K    TYPE CHAR1            VALUE 'K',
           GC_L    TYPE CHAR1            VALUE 'L',
           GC_P    TYPE CHAR1            VALUE 'P',
           GC_R    TYPE CHAR1            VALUE 'R',
           GC_S    TYPE CHAR1            VALUE 'S',
           GC_W    TYPE CHAR1            VALUE 'W',
           GC_X    TYPE CHAR1            VALUE 'X',
           GC_Y    TYPE CHAR1            VALUE 'Y',
           GC_EQ   TYPE CHAR2            VALUE 'EQ',
           GC_BT   TYPE CHAR2            VALUE 'BT',
           GC_101  TYPE BWART            VALUE '101',
           GC_261  TYPE BWART            VALUE '261',
           GC_ROH1 TYPE MTART            VALUE 'ROH1',
           GC_KBDM TYPE ZGTETARGET       VALUE 'KBDM',
           GC_MDOC TYPE NSDM_RECORD_TYPE VALUE 'MDOC'.
