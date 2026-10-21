*&---------------------------------------------------------------------*
*& Include          ZGTSDR9062TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES : VBAK, VBAP.
*----------------------------------------------------------------------*
* Class
*----------------------------------------------------------------------*
CLASS : LCL_EVENT_RECEIVER DEFINITION DEFERRED.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS : GC_E TYPE CHAR1 VALUE 'E',
            GC_X TYPE CHAR1 VALUE 'X'.

CONSTANTS : GC_CRLF TYPE C VALUE CL_BCS_CONVERT=>GC_CRLF,
            GC_TAB  TYPE C VALUE CL_BCS_CONVERT=>GC_TAB.




*----------------------------------------------------------------------*
* VARIABLE
*----------------------------------------------------------------------*
DATA : GV_SAVEOK LIKE SY-UCOMM,
       GV_OKCODE LIKE SY-UCOMM,
       GV_ERROR  TYPE CHAR1,
       GV_ANSWER TYPE CHAR1.

*----------------------------------------------------------------------*
* TYPE & STRUCTURE & INTERNAL TABLE
*----------------------------------------------------------------------*
DATA : GT_FCODE   TYPE TABLE OF SY-UCOMM,
       GT_CELLTAB TYPE LVC_T_STYL.

"ALV Default Fields
TYPES : BEGIN OF TY_S_ALVDEF,
          STATU TYPE ICON_D,     "신규/변경/삭제 상태 ICON
          INSRT TYPE CHAR1,      "신규 여부 Flag : 'X' or ' '
          MODI  TYPE CHAR1,      "변경 여부 Flag : 'X' or ' '
          CELLS TYPE LVC_T_STYL, "Cell Style
          CELLC TYPE LVC_T_STYL, "Cell Color
        END OF TY_S_ALVDEF.

TYPES : BEGIN OF TY_S_CHG,
          VKORG TYPE VKORG,
          MATNR TYPE MATNR,
        END OF TY_S_CHG,
        TY_T_CHG TYPE TABLE OF TY_S_CHG
                   WITH NON-UNIQUE SORTED KEY KEY_MODE
                   COMPONENTS VKORG.



"화면 변경 정보
DATA : GT_CHG   TYPE TY_T_CHG.


DATA : GT_9063 TYPE STANDARD TABLE OF ZGTSDT9063 WITH EMPTY KEY,
       WA_9063 TYPE ZGTSDT9063.

DATA : BEGIN OF GS_ALV,
          DUMMY       TYPE CHAR1,
          MREQNO      TYPE ZGTE_MREQNO,
          VBELN       TYPE VBELN_VA,
          POSNR       TYPE POSNR_VA,
          VBELN_VL TYPE VBELN_VL,
          LFIMG_SUM TYPE LFIMG, "납품 총수량 - Batch Split 모음
          MATNR       TYPE MATNR_D,
          WERKS       TYPE WERKS_D,
          MAKTX       TYPE MAKTX,
          KWMENG      TYPE KWMENG, "수량
          VRKME       TYPE VRKME, "단위
          MENGE_2530  TYPE LABST, "2530 재고 - 출고불가
          MENGE_2540  TYPE LABST, "2540 재고 - 출고불가
          MENGE_2550  TYPE LABST, "2550 재고 - 출고가능
          MENGE_3601  TYPE LABST, "3601(HU) 재고 - 출고가능
          LABST       TYPE LABST, "MARD 재고 - 출고가능
          LABST2      TYPE LABST, "MARD 재고 - 출고가능
          STOCK_QTY TYPE KWMENG, "601 수량
          687_DLV_QTY TYPE KWMENG, "687 수량
          DELAY_DLV TYPE CHAR10, "차월 출하 대상
          DELAY_REASON TYPE CHAR40, "사유
*          REM_DLV_QTY TYPE KWMENG,
          BUJOK_MENGE TYPE CHAR10, "부족여부 - ICON_RED / ICON_GREEN으로 조정
          DLV_CHECK TYPE CHAR10,
          ABGRU TYPE ABGRU, "거부사유
          ABGRU_CHECK TYPE CHAR10, "거부사유 여부
          INCLUDE     TYPE TY_S_ALVDEF, "ALV Default Fields
          JIK_NON_CHECK TYPE CHAR10, "재고 Complete 체크여부
          JIKCHUL_CHECK TYPE CHAR10, "직출여부
          POJANG_CHECK TYPE CHAR20, "포장 N/A, N, Y
          POJANG_TEXT TYPE ZMESG,
          GI_AVAIL TYPE CHAR10. "출하 가능
DATA : END OF GS_ALV.

DATA : GT_ALV LIKE TABLE OF GS_ALV,
       WA_ALV LIKE GS_ALV.

*----------------------------------------------------------------------*
*  ALV GRID.
*----------------------------------------------------------------------*

DATA : GT_TOOLBAR TYPE UI_FUNCTIONS.
DATA : GO_CON     TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_GRID    TYPE REF TO CL_GUI_ALV_GRID,
       GT_FCAT    TYPE LVC_T_FCAT,
       GS_FCAT    TYPE LVC_S_FCAT,
       GT_SORT    TYPE LVC_T_SORT,   " ALV Sort
       GS_LAYOUT  TYPE LVC_S_LAYO,
       GO_SPLIT   TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
       GO_CON_TOP TYPE REF TO CL_GUI_CONTAINER,
       GO_DOCU    TYPE REF TO CL_DD_DOCUMENT.



*DATA : GO_EVNT TYPE REF TO LCL_ALV_EVENT_HANDLER. "EVENT
DATA : GS_VARIANT TYPE DISVARIANT.
DATA : GS_STBL TYPE LVC_S_STBL.

DATA : GT_ROW TYPE LVC_T_ROW WITH HEADER LINE,
       GS_ROW LIKE GT_ROW.

*----------------------------------------------------------------------*
* DEFINE
*----------------------------------------------------------------------*
DEFINE __CLE.
  CLEAR: &1, &1[].
END-OF-DEFINITION.

DEFINE __RNG.
  &1-SIGN   = &2.
  &1-OPTION = &3.
  &1-LOW    = &4.
  &1-HIGH    = &5.
  APPEND &1. CLEAR &1.
END-OF-DEFINITION.

DEFINE __ALPHA_IN.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = &1
    IMPORTING
      OUTPUT = &2.
END-OF-DEFINITION.

DEFINE __ALPHA_OU.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = &1
    IMPORTING
      OUTPUT = &2.
END-OF-DEFINITION.
