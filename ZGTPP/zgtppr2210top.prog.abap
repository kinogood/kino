*&---------------------------------------------------------------------*
*& Include          ZGTPPR2210TOP
*&---------------------------------------------------------------------*
TABLES: ZGTPPT2310, ZGTPPT2320, ZGTPPT2360, SSCRFIELDS.

INCLUDE <CL_ALV_CONTROL>.   " ALV Control (Ex. Fonts, Styles)
INCLUDE <ICON>.             " Icons

* CLASS ZCL_EVENT_RECIEVER DEFINITION
CLASS ZCL_EVENT_RECIEVER DEFINITION DEFERRED.

DATA: BEGIN OF GS_TOP,
        SEL        LIKE ICON-ID,               "선택
        WERKS      LIKE ZGTPPT2310-WERKS,      "플랜ㅌ
        NAME1      LIKE T001W-NAME1,           "플랜트내역
        SPGCD      LIKE ZGTPPT2310-SPGCD,      "SPG
        DESCR      LIKE ZPPT0107-DESCR,        "SPG내역
        SPMON      LIKE ZGTPPT2310-SPMON,      "판매년월
        VDATU      LIKE ZGTPPT2310-VDATU,      "기준일자
        ZVERS_NO   LIKE ZGTPPT2310-ZVERS_NO,   "산출버전번호
        ZVERS_DESC LIKE ZGTPPT2310-ZVERS_DESC, "산출버전내역
        CRDAT      LIKE ZGTPPT2310-CRDAT,      "생성일자
        CRTIM      LIKE ZGTPPT2310-CRTIM,      "생성시간
        CRNAM      LIKE ZGTPPT2310-CRNAM,      "생성자

        CAL_CHK(1), "데이터 산출 체크
      END OF GS_TOP.
DATA: GT_TOP LIKE TABLE OF GS_TOP.

DATA: BEGIN OF GS_BOTTOM,
        ZREQ_NO         LIKE ZGTPPT2320-ZREQ_NO,    "산출대상번호
        ZREQ_TYPE       LIKE ZGTPPT2320-ZREQ_TYPE,  "산출구분
        ZREQ_TYPENM(30),                "산출구분명
        VBELN           LIKE ZGTPPT2320-VBELN,      "판매오더번호
        POSNR           LIKE ZGTPPT2320-POSNR,      "판매오더품목
        AUFNR           LIKE ZGTPPT2320-AUFNR,      "생산오더번호(제품)
        ZMANUAL_NO      LIKE ZGTPPT2320-ZMANUAL_NO, "수기등록번호
        PMATN           LIKE ZGTPPT2320-PMATN,      "산출품목코드
        PMAKT           LIKE MAKT-MAKTX,            "산출품목내역
        PMENG           LIKE ZGTPPT2320-PMENG,      "산출수량
        PMEIN           LIKE ZGTPPT2320-PMEIN,      "산출단위
        ZOPER_SEQ       LIKE ZGTPPT2360-ZOPER_SEQ,  "공정순번
        ARBPL           LIKE ZGTPPT2360-ARBPL,      "작업장
        KTEXT           LIKE CRTX-KTEXT,            "작업장내역
        MATNR           LIKE ZGTPPT2360-MATNR,      "공정품목코드
        MAKTX           LIKE MAKT-MAKTX,            "공정품목내역
        MENGE           LIKE ZGTPPT2360-MENGE,      "공정수량
        MEINS           LIKE ZGTPPT2360-MEINS,      "수량단위
        ZTIME           LIKE ZGTPPT2360-ZTIME,      "소요시간
        ZUNIT           LIKE ZGTPPT2360-ZUNIT,      "시간단위
      END OF GS_BOTTOM.
DATA: GT_BOTTOM LIKE TABLE OF GS_BOTTOM.

DATA: BEGIN OF GS_OBOTTOM,
        WERKS       LIKE ZGTPPT2310-WERKS,      "플랜트
        SPGCD       LIKE ZGTPPT2310-SPGCD,      "SPG
        SPMON       LIKE ZGTPPT2310-SPMON,      "판매년월
        VDATU       LIKE ZGTPPT2310-VDATU,      "기준일자
        ZVERS_NO    LIKE ZGTPPT2310-ZVERS_NO,   "산출버전번호
        ZREQ_NO     LIKE ZGTPPT2320-ZREQ_NO,    "산출대상번호
        ZREQ_TYPE   LIKE ZGTPPT2320-ZREQ_TYPE,  "산출구분
        ZREQ_TYPENM TYPE CHAR30,                "산출구분명
        VBELN       LIKE ZGTPPT2320-VBELN,      "판매오더번호
        POSNR       LIKE ZGTPPT2320-POSNR,      "판매오더품목
        AUFNR       LIKE ZGTPPT2320-AUFNR,      "생산오더번호(제품)
        ZMANUAL_NO  LIKE ZGTPPT2320-ZMANUAL_NO, "수기등록번호
        PMATN       LIKE ZGTPPT2320-PMATN,      "산출품목코드
        PMAKT       LIKE MAKT-MAKTX,            "산출품목내역
        PMENG       LIKE ZGTPPT2320-PMENG,      "산출수량
        PMEIN       LIKE ZGTPPT2320-PMEIN,      "산출단위
        ZOPER_SEQ   LIKE ZGTPPT2360-ZOPER_SEQ,  "공정순번
        ARBPL       LIKE ZGTPPT2360-ARBPL,      "작업장
        KTEXT       LIKE CRTX-KTEXT,            "작업장내역
        MATNR       LIKE ZGTPPT2360-MATNR,      "공정품목코드
        MAKTX       LIKE MAKT-MAKTX,            "공정품목내역
        MENGE       LIKE ZGTPPT2360-MENGE,      "공정수량
        MEINS       LIKE ZGTPPT2360-MEINS,      "수량단위
        ZTIME       LIKE ZGTPPT2360-ZTIME,      "소요시간
        ZUNIT       LIKE ZGTPPT2360-ZUNIT,      "시간단위

        DEL(1),
      END OF GS_OBOTTOM.
DATA: GT_OBOTTOM   LIKE TABLE OF GS_OBOTTOM,
      GT_CALBOTTOM LIKE TABLE OF GS_OBOTTOM.

DATA: GS_TOPMAT TYPE CSTMAT,
      GT_STB    TYPE TABLE OF STPOX,
      GT_CSCMAT TYPE TABLE OF CSCMAT.

DATA: GV_PMATN LIKE ZGTPPT2320-PMATN,
      GV_PMENG LIKE ZGTPPT2320-PMENG.

DATA: GO_DOCKING_CONTAINER TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA: GO_SPLITTER TYPE REF TO CL_GUI_SPLITTER_CONTAINER.

*- ALV GRID TOP
DATA: GO_CONTAIN_0100 TYPE REF TO CL_GUI_CONTAINER.
DATA: GO_GRID_0100 TYPE REF TO CL_GUI_ALV_GRID.
DATA: GO_EVTR_0100 TYPE REF TO ZCL_EVENT_RECIEVER.
DATA: GS_VARIANT TYPE DISVARIANT.
DATA: GS_LAYOUT_0100 TYPE LVC_S_LAYO.
DATA: GT_EXCLUDE_0100 TYPE UI_FUNCTIONS.
DATA: GT_FIELDCAT_0100 TYPE LVC_T_FCAT.

*- ALV GRID BOTTOM
DATA: GO_CONTAIN_0101 TYPE REF TO CL_GUI_CONTAINER.
DATA: GO_GRID_0101 TYPE REF TO CL_GUI_ALV_GRID.
DATA: GS_LAYOUT_0101 TYPE LVC_S_LAYO.
DATA: GT_SORT_0101 TYPE LVC_T_SORT.
DATA: GT_EXCLUDE_0101 TYPE UI_FUNCTIONS.
DATA: GT_FIELDCAT_0101 TYPE LVC_T_FCAT.

DATA: GT_UCOMM TYPE TABLE OF SY-UCOMM.

DATA: GV_DYNTXT TYPE SMP_DYNTXT.

DATA: GV_OK_CODE TYPE SYUCOMM,
      GV_DBCNT   TYPE CHAR10.

DATA: GV_VERSNO TYPE ZGTEVERSNO.

CONSTANTS: GC_0   TYPE PSTYP           VALUE '0',
           GC_3   TYPE PSTYP           VALUE '3',
           GC_A   TYPE CHAR1           VALUE 'A',
           GC_C   TYPE CHAR1           VALUE 'C',
           GC_D   TYPE CHAR1           VALUE 'D',
           GC_E   TYPE CHAR1           VALUE 'E',
           GC_F   TYPE CHAR1           VALUE 'F',
           GC_I   TYPE CHAR1           VALUE 'I',
           GC_K   TYPE CHAR1           VALUE 'K',
           GC_L   TYPE CHAR1           VALUE 'L',
           GC_M   TYPE CHAR1           VALUE 'M',
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
