*&---------------------------------------------------------------------*
*& Include          ZGTMMR4381TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF TY_ADJ,
    STATUS    TYPE C LENGTH 4, "점검
    RESULT    TYPE C LENGTH 4, "처리 결과
    WERKS     TYPE T001W-WERKS,   "플랜트
    NAME1     TYPE T001W-NAME1,   "플랜트명
    LGORT     TYPE T001L-LGORT,   "저장위치
    LGOBE     TYPE T001L-LGOBE,   "저장위치명
    MATNR     TYPE MARA-MATNR,   "자재번호
    MAKTX     TYPE MAKT-MAKTX,   "자재내역
    CHARG     TYPE MCH1-CHARG,   "배치번호
    LABST     TYPE LABST,   "재고수량
    MEINS     TYPE MARA-MEINS,   "단위
    ADDQTY    TYPE ERFMG,   "추가입고
    CANCELQTY TYPE ERFMG,   "입고취소
    MBLNR     TYPE MBLNR,   "자재문서번호
    MJAHR     TYPE MJAHR,   "자재문서연도
    MESSAGE   TYPE BAPI_MSG, "처리메세지
    ZSTYLE    TYPE LVC_T_STYL,
  END OF TY_ADJ,
  TY_T_ADJ TYPE STANDARD TABLE OF TY_ADJ,

  BEGIN OF TY_DISP,
    RESULT    TYPE C LENGTH 4, "처리 결과
    SMBLN     TYPE MBLNR,   "취소자재문서번호
    MBLNR     TYPE MBLNR,   "자재문서번호
    MJAHR     TYPE MJAHR,   "자재문서연도
    ZEILE     TYPE MATDOC-ZEILE,   "자재문서품목
    BUDAT     TYPE MATDOC-BUDAT,   "전기일자
    CHECK     TYPE C LENGTH 1,   "체크박스
    BWART     TYPE MATDOC-BWART,   "이동유형
    BTEXT     TYPE T156T-BTEXT,   "이동유형내역
    WERKS     TYPE MATDOC-WERKS,   "플랜트
    NAME1     TYPE T001W-NAME1,   "플랜트명
    LGORT     TYPE MATDOC-LGORT,   "저장위치
    LGOBE     TYPE T001L-LGOBE,   "저장위치명
    MATNR     TYPE MATDOC-MATNR,   "자재번호
    MAKTX     TYPE MAKT-MAKTX,   "자재내역
    CHARG     TYPE MCH1-CHARG,   "배치번호
    ERFMG     TYPE MATDOC-ERFMG,   "수량
    ERFME     TYPE MATDOC-ERFME,   "단위
    USNAM     TYPE MATDOC-USNAM,   "생성자
    NAME_TEXT TYPE ADRP-NAME_TEXT,   "생성자명
    MESSAGE   TYPE BAPI_MSG, "처리메세지
    ZSTYLE    TYPE LVC_T_STYL,
  END OF TY_DISP,

  TY_T_DISP TYPE STANDARD TABLE OF TY_DISP.


*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*
DATA:
  GV_MATNR TYPE MARA-MATNR,
  GV_BUDAT TYPE BUDAT.

DATA:
  GV_ERROR  TYPE C LENGTH 1,
*  GV_EDIT   TYPE C LENGTH 1,
  GT_ECOMM  TYPE STANDARD TABLE OF SY-UCOMM,
  GV_OKCODE TYPE SY-UCOMM.

DATA:
  GT_ADJ  TYPE STANDARD TABLE OF TY_ADJ,
  GS_ADJ  TYPE TY_ADJ,

  GT_DISP TYPE STANDARD TABLE OF TY_DISP,
  GS_DISP TYPE TY_DISP.

DATA:
  BEGIN OF GS_SCR_101,
    BUDAT TYPE BUDAT,
    ZCHK  TYPE C LENGTH 1,
  END OF GS_SCR_101,

  BEGIN OF GS_SCR_201,
    BUDAT TYPE BUDAT,
    ZCHK  TYPE C LENGTH 1,
  END OF GS_SCR_201.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS:
  GC_A(1)    VALUE 'A',
  GC_C(1)    VALUE 'C',
  GC_S(1)    VALUE 'S',
  GC_E(1)    VALUE 'E',

  GC_Z21(3)  VALUE 'Z21',
  GC_Z22(3)  VALUE 'Z22',
  GC_SCRP(4) VALUE 'SCRP',

  GC_1(1)    VALUE 1,
  GC_01(2)   VALUE '01',
  GC_04(2)   VALUE '04',
  GC_05(2)   VALUE '05',
  GC_1900(4) VALUE '1900',

  GC_C300(4) VALUE 'C300',  "YELLOW
  GC_C400(4) VALUE 'C400',  "BLUE
  GC_C500(4) VALUE 'C500',  "GREEN
  GC_C600(4) VALUE 'C600',  "RED
  GC_C700(4) VALUE 'C700'.  "ORANGE


*----------------------------------------------------------------------*
* ALV
*----------------------------------------------------------------------*
DATA:
*  GO_CONT_100  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
  GO_CONT_100  TYPE REF TO CL_GUI_DOCKING_CONTAINER,
  GO_GRID_100  TYPE REF TO CL_GUI_ALV_GRID,
  GV_ASAVE_100 TYPE CHAR01 VALUE GC_A,
  GS_LAYO_100  TYPE LVC_S_LAYO,
  GS_VARI_100  TYPE DISVARIANT,
  GT_FCAT_100  TYPE LVC_T_FCAT,
  GT_SORT_100  TYPE LVC_T_SORT,
  GT_EXCL_100  TYPE UI_FUNCTIONS,

  GO_CONT_200  TYPE REF TO CL_GUI_DOCKING_CONTAINER,
  GO_GRID_200  TYPE REF TO CL_GUI_ALV_GRID,
  GV_ASAVE_200 TYPE CHAR01 VALUE GC_A,
  GS_LAYO_200  TYPE LVC_S_LAYO,
  GS_VARI_200  TYPE DISVARIANT,
  GT_FCAT_200  TYPE LVC_T_FCAT,
  GT_SORT_200  TYPE LVC_T_SORT,
  GT_EXCL_200  TYPE UI_FUNCTIONS.



*----------------------------------------------------------------------*
* SCREEN - 1000
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-S01.

  PARAMETERS:
    P_BUKRS TYPE T001-BUKRS MEMORY ID BUK,
    P_WERKS TYPE T001W-WERKS MEMORY ID WRK,
    P_LGORT TYPE T001L-LGORT MEMORY ID LAG.

  SELECT-OPTIONS:
      S_MATNR FOR GV_MATNR,
      S_BUDAT FOR GV_BUDAT MODIF ID DIS.

SELECTION-SCREEN END   OF BLOCK B01.


SELECTION-SCREEN BEGIN OF BLOCK B02 WITH FRAME TITLE TEXT-S02.

  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : P_ADJ RADIOBUTTON GROUP GR1  DEFAULT 'X'
                             USER-COMMAND CM1
                             MODIF ID TCD.
    SELECTION-SCREEN COMMENT (15) TEXT-R01 FOR FIELD P_ADJ
      MODIF ID TCD.

    SELECTION-SCREEN POSITION 20.
    PARAMETERS : P_DISP RADIOBUTTON GROUP GR1
                            MODIF ID TCD .
    SELECTION-SCREEN COMMENT (15) TEXT-R02 FOR FIELD P_DISP
      MODIF ID TCD .
  SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN END   OF BLOCK B02.
