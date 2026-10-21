*&---------------------------------------------------------------------*
*& Include          ZGTPPR4130TOP
*&---------------------------------------------------------------------*
TABLES: ZGTPPT4160, ZGTPPT4170, ZPPT0600, ZPPT0601, ZPPT0001,
        SSCRFIELDS, MARA, MARC, MATDOC.

INCLUDE <CL_ALV_CONTROL>.   " ALV Control (Ex. Fonts, Styles)

* CLASS ZCL_EVENT_RECIEVER DEFINITION
CLASS ZCL_EVENT_RECIEVER DEFINITION DEFERRED.

DATA: BEGIN OF GS_DATA,
        WERKS       LIKE ZPPT0601-WERKS,        "플랜트
        NAME1       LIKE T001W-NAME1,           "플랜트내역
        INSMM       LIKE ZPPT0601-INSMM,        "재고년월
        LGORT       LIKE ZPPT0601-LGORT,        "저장위치
        LGOBE       LIKE T001L-LGOBE,           "저장위치내역
        MATNR       LIKE ZPPT0601-MATNR,        "자재코드
        MAKTX       LIKE MAKT-MAKTX,            "자재내역
        CHARG       LIKE ZPPT0601-CHARG,        "배치번호
        TAGNR       LIKE ZPPT0001-TAGNR,        "꼬리표번호
        PHY_INV(1),                             "실사대상
        SCAN_YN(1),                             "스캔여부
*        REP_TAGNR   LIKE ZPPT0001-TAGNR,        "대체가능꼬리표번호
        VBELN       LIKE ZPPT0601-VBELN,        "판매오더번호
        POSNR       LIKE ZPPT0601-POSNR,        "판매오더품목
        MEINS       LIKE ZPPT0601-MEINS,        "기본단위
        LABST       LIKE ZPPT0601-LABST,        "장부재고(가용)
        INSME       LIKE ZPPT0601-INSME,        "장부재고(품질)
        SPEME       LIKE ZPPT0601-SPEME,        "장부재고(보류)
        MENGE       LIKE ZPPT0600-MENGE,        "실사재고
        DIFF        LIKE ZPPT0600-MENGE,        "차이량
        DIFF_ABS    LIKE ZPPT0600-MENGE,        "차이량(절대값)
        HIS_901(1),                             "보관품이력
        HIS_561(1),                             "기초재고이력
*        HIS_PDA(1),                             "과거PDA스캔이력
        COMPARE(40),                            "비교
        CHK_RESULT  LIKE ZGTPPT4170-CHK_RESULT, "점검결과
        REMARK      LIKE ZGTPPT4170-REMARK,     "비고
      END OF GS_DATA.
DATA: GT_DATA LIKE TABLE OF GS_DATA.

DATA: BEGIN OF GS_0601,
        WERKS LIKE ZPPT0601-WERKS,
        INSMM LIKE ZPPT0601-INSMM,
        LGORT LIKE ZPPT0601-LGORT,
        MATNR LIKE ZPPT0601-MATNR,
        CHARG LIKE ZPPT0601-CHARG,
        VBELN LIKE ZPPT0601-VBELN,
        POSNR LIKE ZPPT0601-POSNR,
        MEINS LIKE ZPPT0601-MEINS,
        LABST LIKE ZPPT0601-LABST,
        INSME LIKE ZPPT0601-INSME,
        SPEME LIKE ZPPT0601-SPEME,
        TAGNR LIKE ZPPT0001-TAGNR,
        DPCBT LIKE MARC-DPCBT,
      END OF GS_0601.
DATA: GT_0601 LIKE TABLE OF GS_0601.

DATA: BEGIN OF GS_PDA,
        INSMM LIKE ZGTPPT4160-INSMM,
        WERKS LIKE ZGTPPT4160-WERKS,
        LGORT LIKE ZGTPPT4160-LGORT,
        TAGNR LIKE ZGTPPT4160-TAGNR,
        CHARG LIKE ZPPT0001-CHARG,
        MATNR LIKE ZPPT0001-MATNR,
        DPCBT LIKE MARC-DPCBT,
      END OF GS_PDA.
DATA: GT_PDA LIKE TABLE OF GS_PDA.

DATA: BEGIN OF GS_0600.
        INCLUDE STRUCTURE ZPPT0600.
DATA END OF GS_0600.
DATA: GT_0600 LIKE TABLE OF GS_0600.

*DATA: BEGIN OF GS_REP_TAGNR,
*        INSMM     LIKE ZPPT0600-INSMM,
*        WERKS     LIKE ZPPT0600-WERKS,
*        LGORT     LIKE ZPPT0600-LGORT,
*        MATNR     LIKE ZPPT0600-MATNR,
*        TAGNR     LIKE ZPPT0600-TAGNR,
*        MENGE_ABS LIKE ZPPT0600-MENGE,
*        MENGE     LIKE ZPPT0600-MENGE,
*        ZUSE(1),
*      END OF GS_REP_TAGNR.
*DATA: GT_REP_TAGNR LIKE TABLE OF GS_REP_TAGNR.

DATA: BEGIN OF GS_MBLNR_H,
        WERKS     LIKE MATDOC-WERKS, "플랜트
        LGORT     LIKE MATDOC-LGORT, "저장위치
        MATNR     LIKE MATDOC-MATNR, "자재코드
        MAKTX     LIKE MAKT-MAKTX,   "자재내역
        BWART     LIKE MATDOC-BWART, "이동유형
        BTEXT     LIKE T156HT-BTEXT, "이동유형텍스트
        STOCK_QTY LIKE MATDOC-STOCK_QTY, "수량
        MEINS     LIKE MATDOC-MEINS, "단위
        EBELN     LIKE MATDOC-EBELN, "구매오더
        EBELP     LIKE MATDOC-EBELP, "구매오더품목
        AUFNR     LIKE MATDOC-AUFNR, "생산오더
        KDAUF     LIKE MATDOC-KDAUF, "판매오더
        KDPOS     LIKE MATDOC-KDPOS, "판매오더품목
        BUDAT     LIKE MATDOC-BUDAT, "전기일자
        CPUDT     LIKE MATDOC-CPUDT, "입력일자
        CPUTM     LIKE MATDOC-CPUTM, "입력시간
        USNAM     LIKE MATDOC-USNAM, "입력자
        MBLNR     LIKE MATDOC-MBLNR, "자재문서
        MJAHR     LIKE MATDOC-MJAHR, "자재문서연도
        ZEILE     LIKE MATDOC-ZEILE, "자재문서항목
      END OF GS_MBLNR_H.
DATA: GT_MBLNR_H LIKE TABLE OF GS_MBLNR_H.

DATA: GO_CONTAIN_0100 TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA: GO_GRID_0100 TYPE REF TO CL_GUI_ALV_GRID.
DATA: GO_EVTR_0100 TYPE REF TO ZCL_EVENT_RECIEVER.
DATA: GS_VARIANT_0100 TYPE DISVARIANT.
DATA: GS_LAYOUT_0100 TYPE LVC_S_LAYO.
DATA: GT_EXCLUDE_0100 TYPE UI_FUNCTIONS.
DATA: GT_FIELDCAT_0100 TYPE LVC_T_FCAT.

DATA : GCL_POP  TYPE REF TO CL_RS_ALV_GRID_POPUP.      "POPUP ALV
DATA : GS_LAYOD TYPE LVC_S_LAYO,
       GT_FCATD TYPE LVC_T_FCAT.

DATA: GT_UCOMM TYPE TABLE OF SY-UCOMM.

DATA: GV_OK_CODE TYPE SYUCOMM,
      GV_DBCNT   TYPE CHAR10.

DATA: GV_REPID TYPE SYREPID,
      GV_VALID TYPE CHAR01,
      GV_INDEX TYPE SY-TABIX,
      GV_TEXT  TYPE CHAR255.

DATA: GV_LGORT TYPE LGORT_D,
      GV_CHARG TYPE CHARG_D,
      GV_TAGNR TYPE ZTAGNR.

CONSTANTS: GC_A   TYPE CHAR1           VALUE 'A',
           GC_C   TYPE CHAR1           VALUE 'C',
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
           GC_ALL TYPE CHAR1           VALUE '*',
           GC_EQ  TYPE CHAR2           VALUE 'EQ',
           GC_BT  TYPE CHAR2           VALUE 'BT'.
