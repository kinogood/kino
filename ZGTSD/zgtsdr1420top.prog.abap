*&---------------------------------------------------------------------*
*& Include          ZGTSDR1420TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* TABLES :
*----------------------------------------------------------------------*
TABLES : SSCRFIELDS, VBAK , VBAP, ZGTSDT1410.

**-- TOP
TYPES : BEGIN OF GTY_DATA,
          REQNO     LIKE ZGTSDT1410-REQNO,       "요청번호
          VBELN     LIKE ZGTSDT1410-VBELN,       "판매오더
          POSNR     LIKE ZGTSDT1410-POSNR,       "품목
*          ETENR     LIKE ZGTSDT1410-ETENR,       "일정라인
          MATNR     LIKE VBAP-MATNR,             "자재코드
          ARKTX     LIKE VBAP-ARKTX,             "품명
          ATWRT     LIKE AUSP-ATWRT,             "스펙
          REQDATE   LIKE ZGTSDT1410-REQDATE,    "요청일
          REQTYPE   LIKE ZGTSDT1410-REQTYPE,     "요청구분
          REASON    LIKE ZGTSDT1410-REASON,      "요청사유
          READTL    LIKE ZGTSDT1410-READTL,      "세부원인
          EDATU_N   LIKE ZGTSDT1410-EDATU_N,     "납기정정일
          KWMENG_N  LIKE ZGTSDT1410-KWMENG_N,    "정정수량
          CFMPP     LIKE ZGTSDT1410-CFMPP,       "생관확인
          STATUS_PP TYPE ICON_D,
          CFMMM     LIKE ZGTSDT1410-CFMMM,       "구매확인
          STATUS_MM TYPE ICON_D,
          PSTAT     LIKE ZGTSDT1410-PSTAT,       "처리상태
          STATUS_ST TYPE ICON_D,
          KUNNR     LIKE VBAK-KUNNR,             "판매처
          NAME1     LIKE KNA1-NAME1,             "판매처명
          SM_OM     TYPE C LENGTH 2,             "SM/OM
          FIXMG     LIKE ZGTSDT1410-FIXMG,       "SM/OM
          EDATU     LIKE ZGTSDT1410-EDATU ,      "납기일
          KWMENG    LIKE ZGTSDT1410-KWMENG ,     "수량
          GRQTY     LIKE MATDOC-STOCK_QTY,       "입고
          GIQTY     LIKE MATDOC-STOCK_QTY,       "출고
          REASONX   LIKE ZGTSDT1410-REASONX,     "불가사유
          CFMNAME   LIKE ZGTSDT1410-CFMNAME,     "확인자
          CFMNAME_T LIKE ADRP-NAME_TEXT,


          CFMDATE   LIKE ZGTSDT1410-CFMDATE,     "확인일
          CFMTIME   LIKE ZGTSDT1410-CFMTIME,     "확인시간
          PMVNAME   LIKE ZGTSDT1410-PMVNAME,     "구매전환자
          PMVNAME_T LIKE ADRP-NAME_TEXT,
          PMVDATE   LIKE ZGTSDT1410-PMVDATE,     "구매전환일
          PMVTIME   LIKE ZGTSDT1410-PMVTIME,     "구매전환시간
          STATUS_SM TYPE ICON_D,                 "SM Link
          STATUS_AU TYPE ICON_D,                 "생산오더
          STATUS_PO TYPE ICON_D,                 "구매오더
          UPDRQ     LIKE ZGTSDT1410-UPDRQ,       "SM Link 요청번호
          AUFNR     LIKE ZGTSDT1410-AUFNR,       "생산오더
          AUPOS     LIKE AFPO-POSNR,             "생산오더품목
          EBELN     LIKE ZGTSDT1410-EBELN,       "구매오더
          EBELP     LIKE ZGTSDT1410-EBELP,       "구매오더품목

          MEINS     LIKE MARA-MEINS,
          CELLTAB   TYPE LVC_T_STYL,
          CELLCOL   TYPE LVC_T_SCOL,
        END OF GTY_DATA  ,
        GTTY_DATA TYPE TABLE OF GTY_DATA WITH DEFAULT KEY.

DATA : GS_DATA TYPE GTY_DATA,
       GT_DATA TYPE GTTY_DATA.

DATA GV_MODULE TYPE C LENGTH 2.

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
