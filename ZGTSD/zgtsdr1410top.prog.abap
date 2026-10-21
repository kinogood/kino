*&---------------------------------------------------------------------*
*& Include          ZGTSDR1410TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* TABLES :
*----------------------------------------------------------------------*
TABLES : SSCRFIELDS, VBAK , ZGTSDT1410.

**-- TOP
TYPES : BEGIN OF GTY_DATA,
          CHK(1),                                "선택
          VBELN     LIKE VBAP-VBELN,             "판매오더
          POSNR     LIKE VBAP-POSNR,             "품목
          ETENR     LIKE VBEP-ETENR,             "일정라인
          ARKTX     LIKE VBAP-ARKTX,             "품명
          SPEC      TYPE C LENGTH 20,            "스펙
          EDATU     LIKE VBEP-EDATU,             "납기일
          EDATU_N   LIKE ZGTSDT1410-EDATU_N,     "정정납기일
          KWMENG    LIKE VBEP-WMENG,             "수량
          VRKME     LIKE VBEP-VRKME,             "단위
          KWMENG_N  LIKE ZGTSDT1410-KWMENG_N,    "정정수량
          OM_SM     TYPE C LENGTH 2,             "OM/SM
          UPDRQ     LIKE ZGTPPT3360-UPDRQ ,      "SM Link
          STATUS_SM TYPE ICON_D,                 "SM Link 여부
          AUFNR     LIKE AFPO-AUFNR,             "생산오더
          CO_POSNR  LIKE AFPO-POSNR,             "생산오더품목
          STATUS_AU TYPE ICON_D,                 "생산오더
          EBELN     LIKE EKPO-EBELN,             "구매오더
          EBELP     LIKE EKPO-EBELP,             "구매품목
          STATUS_PO TYPE ICON_D,                 "구매오더여부

          BSTYP     LIKE VBEP-BSTYP,
          FIXMG     LIKE VBAP-FIXMG,
          LIFSP     LIKE VBEP-LIFSP,
          WERKS     LIKE ZGTPPT3360-WERKS,

          CELLTAB   TYPE LVC_T_STYL,
          CELLCOL   TYPE LVC_T_SCOL,
        END OF GTY_DATA  ,
        GTTY_DATA TYPE TABLE OF GTY_DATA WITH DEFAULT KEY.

DATA : GS_DATA TYPE GTY_DATA,
       GT_DATA TYPE GTTY_DATA.

DATA GV_ERROR.

*- ALV COMMON
TYPE-POOLS : KKBLO.
DATA : GS_STBL      TYPE LVC_S_STBL,
       GT_SFIELDCAT TYPE KKBLO_T_FIELDCAT,
       GS_EXCLUDING TYPE LINE OF UI_FUNCTIONS,
       GT_EXCLUDING TYPE UI_FUNCTIONS.

*- ALV1 - top
CLASS: LCL_EVENT_RECEIVER DEFINITION DEFERRED.

DATA : EVENT_RECEIVER      TYPE REF TO LCL_EVENT_RECEIVER.
DATA : GRID                TYPE REF TO CL_GUI_ALV_GRID,
       G_CUSTOM_CONTAINER  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       G_DOCKING_CONTAINER TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       G_SPLITTER          TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
       G_SPLITTER2         TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
       G_CONTAINER         TYPE REF TO CL_GUI_CONTAINER,
       G_CON               TYPE SCRFNAME VALUE 'ALV1',

       LCL_PARENT_HTML     TYPE REF TO CL_GUI_CONTAINER,
       LCL_PARENT_GRID     TYPE REF TO CL_GUI_CONTAINER,
       LCL_DYNDOC_ID       TYPE REF TO CL_DD_DOCUMENT.

DATA : OK_CODE TYPE SYST_UCOMM.

DATA : GS_LAYOUT   TYPE LVC_S_LAYO,
       GT_FIELDCAT TYPE LVC_T_FCAT,
       GS_FIELDCAT TYPE LVC_S_FCAT,
       GT_SORT     TYPE LVC_T_SORT,
       GS_SORT     TYPE LVC_S_SORT,
       GS_VARIANT  TYPE DISVARIANT,
       GT_EXCLUDE  TYPE UI_FUNCTIONS,
       GT_STYL     TYPE LVC_T_STYL,
       GS_STYL     TYPE LVC_S_STYL.
