*&---------------------------------------------------------------------*
*& Include          ZGTPPR2330TOP
*&---------------------------------------------------------------------*
TYPE-POOLS : SLIS.
INCLUDE <CL_ALV_CONTROL>.

*----------------------------------------------------------------------*
* TABLES                                                               *
*----------------------------------------------------------------------*
TABLES: AUFK, AFKO, AFPO, VBAK, VBAP, MARC, EKPO, EBAN,
        SSCRFIELDS. " 선택화면의 필드.

*----------------------------------------------------------------------*
* CONSTANTS                                                            *
*----------------------------------------------------------------------*
CONSTANTS: BEGIN OF GC_FCODE,
             ONLI   TYPE SY-UCOMM VALUE 'ONLI',
             BACK   TYPE SY-UCOMM VALUE 'BACK',
             EXIT   TYPE SY-UCOMM VALUE 'EXIT',
             CANCEL TYPE SY-UCOMM VALUE 'CANCEL',
             SAVE   TYPE SY-UCOMM VALUE 'SAVE',
             FC01   TYPE SY-UCOMM VALUE 'FC01',
             CHANGE TYPE SY-UCOMM VALUE 'CHANGE',
           END OF GC_FCODE.

CONSTANTS: BEGIN OF GC_HANDLE,
             AUFK TYPE SLIS_HANDL VALUE '0001',
             LIST TYPE SLIS_HANDL VALUE '0002',
           END OF GC_HANDLE.

CONSTANTS: BEGIN OF GC_WERKS,
             6500 TYPE T001W-WERKS VALUE '6500',
             6600 TYPE T001W-WERKS VALUE '6600',
           END OF GC_WERKS.

*----------------------------------------------------------------------*
* TYPES                                                                *
*----------------------------------------------------------------------*
TYPES: BEGIN OF TY_S_ORDER,
         CHECKED TYPE CHAR01,     "// 선택
         WERKS   TYPE AUFK-WERKS, "// 플랜트
         ORDTP   TYPE CHAR10,     "// 오더범주
         ORDNR   TYPE AUFK-AUFNR, "// 오더번호
         ITMNO   TYPE EKPO-EBELP, "// 항번
         MATNR   TYPE AFPO-MATNR, "// 품목코드
         MAKTX   TYPE MAKT-MAKTX, "// 품목내역
         PSMNG   TYPE AFPO-PSMNG, "// 오더수량
         MEINS   TYPE AFPO-MEINS, "// 단위
         IDNRK   TYPE AFPO-MATNR, "// 목드럼 코드
         IDNTX   TYPE MAKT-MAKTX, "// 목드럼 내역
         RSNUM   TYPE RESB-RSNUM, "// 예약번호
         RSPOS   TYPE RESB-RSPOS, "// 예약번호 품목
         ERFMG   TYPE RESB-ERFMG,  " 목드럼 수량
         ERFME   TYPE RESB-ERFME,  " 목드럼 단위
         CUOBJ   TYPE AFPO-CUOBJ,
         VKORG   TYPE VBAK-VKORG,
         VKGRP   TYPE VBAK-VKGRP,
         STATUS  TYPE CHAR10,     "// 처리상태
         MESSAGE TYPE CHAR100,    "// 처리 메시지
       END OF TY_S_ORDER.

TYPES: BEGIN OF TY_S_LIST,
         CHECKED    TYPE CHAR1,                   "// 선택
         DRUM_CODE  TYPE ZGTEDSIF0038-DRUM_CODE,  "// 드럼코드
         MAKTX      TYPE ZGTEDSIF0038-MAKTX,      "// 드럼 내역
         FLANG      TYPE ZGTEDSIF0038-FLANG,      "// 약경
         DONG       TYPE ZGTEDSIF0038-DONG,       "// 동경
         NAEP       TYPE ZGTEDSIF0038-NAEP,       "// 내폭
         SIDANGU    TYPE ZGTEDSIF0038-SIDANGU,    "// 시단구
         DRUM_MATNR TYPE MARA-MATNR,              "// 드럼 자재코드
         DRUM_TXT   TYPE ZGTEDSIF0038-MAKTX,      "// 드럼 자재내역
         LABST      TYPE MARD-LABST,              "// 재고수량
         MENGE      TYPE MARD-LABST,              "// 소요량
         MEINS      TYPE MARA-MEINS,              "// 재고단위
         WERKS      TYPE RESB-WERKS,              "// 플랜트
         MATNR      TYPE RESB-MATNR,              "// 자재
       END OF TY_S_LIST.

TYPES: TY_T_DRUM TYPE TABLE OF ZGTPPS1016 WITH DEFAULT KEY.

TYPES: BEGIN OF TY_S_RESULT,
         SEL     TYPE SY-TABIX,
         TOTAL   TYPE SY-TABIX,
         SUCCESS TYPE SY-TABIX,
         ERROR   TYPE SY-TABIX,
         INVALID TYPE ABAP_BOOL,
         MESSAGE TYPE CHAR100,
       END OF TY_S_RESULT.

*----------------------------------------------------------------------*
* DATA                                                                 *
*----------------------------------------------------------------------*
DATA : BEGIN OF GS_MAIN_DISP_200,
         CHECKED      TYPE CHAR1,                   "// 선택
         WERKS        LIKE AUFK-WERKS, "// 플랜트
         ORDTP        TYPE CHAR10,     "// 오더범주
         AUFNR        LIKE AUFK-AUFNR, "// 오더번호
         POSNR        LIKE AFPO-POSNR, "// 오더품목
         BANFN        LIKE EBAN-BANFN, "// 오더품목
         BNFPO        LIKE EBAN-BNFPO, "// 오더품목
         EBELN        LIKE EKPO-EBELN,
         EBELP        LIKE EKPO-EBELP,
         MATNR        LIKE AFPO-MATNR, "// 품목코드
         MAKTX        LIKE MAKT-MAKTX, "// 품목내역
         PSMNG        LIKE AFPO-PSMNG, "// 오더수량
         INLENGTH     LIKE ZGTPPT2010-INLENGTH, "// 조장
         MEINS        LIKE AFPO-MEINS, "// 단위
         DRUM_TY      TYPE CHAR6,  "드럼타입
* 드럼자재(이전)
         IDNRK        LIKE AFPO-MATNR, "// 목드럼 코드
* 드럼명(이전)
         IDNTX        LIKE MAKT-MAKTX, "// 목드럼 내역
* 드럼자재(변경)
         IDNRK2       LIKE AFPO-MATNR, "// 목드럼 코드
* 드럼자재(변경)
         IDNTX2       LIKE MAKT-MAKTX, "// 목드럼 내역
         ERFMG        LIKE RESB-ERFMG,  " 목드럼 수량
         ERFME        TYPE RESB-ERFME,  " 목드럼 단위
         VBELN        TYPE VBELN,
         POSNR_SO     TYPE VBAP-POSNR,
         STATUS       LIKE ICON-ID,     "// 처리상태
         MESSAGE      LIKE BAPI_ORDER_RETURN-MESSAGE,    "// 처리 메시지
         MILLCALENGTH TYPE ZGTCVORDSYVAL-MILLCALENGTH,
         MILLCAFACTOR TYPE ZGTCVORDSYVAL-MILLCAFACTOR,
         CHK_CBO      TYPE CHAR01,
         CHK_SAVE     TYPE CHAR01,
         CELLTAB      TYPE LVC_T_STYL,
       END OF GS_MAIN_DISP_200.
DATA : GT_MAIN_DISP_200 LIKE TABLE OF GS_MAIN_DISP_200.

DATA: BEGIN OF GS_MAIN_DISP_201,
        CHECKED    TYPE CHAR1,                   "// 선택
        DRUM_CODE  LIKE ZGTEDSIF0038-DRUM_CODE,  "// 드럼코드
        MAKTX      LIKE ZGTEDSIF0038-MAKTX,      "// 드럼 내역
        FLANG      LIKE ZGTEDSIF0038-FLANG,      "// 약경
        DONG       LIKE ZGTEDSIF0038-DONG,       "// 동경
        NAEP       LIKE ZGTEDSIF0038-NAEP,       "// 내폭
        SIDANGU    LIKE ZGTEDSIF0038-SIDANGU,    "// 시단구
        DRUM_MATNR LIKE MARA-MATNR,              "// 드럼 자재코드
        DRUM_TXT   LIKE ZGTEDSIF0038-MAKTX,      "// 드럼 자재내역
        LABST      LIKE MARD-LABST,              "// 재고수량
        MEINS      LIKE MARA-MEINS,              "// 재고단위
        CELLTAB    TYPE LVC_T_STYL,
      END OF GS_MAIN_DISP_201.
DATA : GT_MAIN_DISP_201 LIKE TABLE OF GS_MAIN_DISP_201.

DATA : BEGIN OF GS_AFPO,
         AUFNR TYPE AUFNR,
         POSNR TYPE AFPO-POSNR,
       END OF GS_AFPO.
DATA : GT_AFPO LIKE TABLE OF GS_AFPO.

DATA : BEGIN OF GS_HEADER_201,
         SUL_NO    TYPE ZESUL_NO,
         REV_SEQ   TYPE ZEREV_SEQ,
         JAKNO     TYPE KDKG4,
         JOJANG    TYPE CHAR6,
         DRUM_CODE TYPE CHAR6,
         WERKS     TYPE WERKS_D,
       END OF GS_HEADER_201.

DATA : GT_2010 TYPE TABLE OF ZGTPPT2010.
DATA : GV_USE_LIST.
DATA : GV_SELECTED_LINE TYPE I.
DATA : GV_SELECTED_VALUE TYPE CHAR01.

DATA : GT_2450 TYPE TABLE OF ZGTPPT2450.

* 팝업 결과 변수
DATA : GV_ANSWER TYPE CHAR01.

DATA    GR_DOCKING_CONTAINER  TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA GR_SPLITTER_CONTAINER TYPE REF TO CL_GUI_SPLITTER_CONTAINER.
DATA GR_TOP_CONTAINER      TYPE REF TO CL_GUI_CONTAINER.
DATA GR_BOTTOM_CONTAINER   TYPE REF TO CL_GUI_CONTAINER.

DATA GR_ORDER TYPE REF TO ZGTPP_CL_LIST.
DATA GR_LIST  TYPE REF TO ZGTPP_CL_LIST.

DATA GT_ORDER TYPE TABLE OF TY_S_ORDER.
DATA GT_LIST TYPE TABLE OF TY_S_LIST.

DATA GT_ZGTPPT1010 TYPE TABLE OF ZGTPPT1010.
DATA GT_BDCDATA TYPE TABLE OF BDCDATA.

DATA GS_RESULT TYPE TY_S_RESULT.

DATA GV_MODE    TYPE CHAR10.
DATA GT_EXCLUDE TYPE UI_FUNCTIONS.
DATA GV_CHANGED TYPE ABAP_BOOL.
DATA GV_OKCODE  TYPE SY-UCOMM.
DATA GV_OKCODE2  TYPE SY-UCOMM.
DATA GV_TPAR1   TYPE SYST_MSGV.

*-/ ALV Global Field
CLASS LCL_EVENT_HANDLER DEFINITION DEFERRED.
DATA : GO_EVENT_HANDLER TYPE REF TO LCL_EVENT_HANDLER.

*-----------
DATA : GO_DOCKING_0200  TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA : GO_SPLITTER_0200 TYPE REF TO CL_GUI_SPLITTER_CONTAINER.

*ALV GRID 200
DATA : GO_CONTAIN_0200 TYPE REF TO CL_GUI_CONTAINER.
DATA : GO_GRID_0200 TYPE REF TO CL_GUI_ALV_GRID.
DATA : GS_VARIANT TYPE DISVARIANT.
DATA : GS_LAYOUT_0200 TYPE LVC_S_LAYO.
DATA : GT_SORT_0200 TYPE LVC_T_SORT.
DATA : GT_EXCLUDE_0200 TYPE UI_FUNCTIONS.
DATA : GT_FIELDCAT_0200 TYPE LVC_T_FCAT.

*-----------
* ALV GRID 0101
DATA : GO_CONTAIN_0201 TYPE REF TO CL_GUI_CONTAINER.
DATA : GO_GRID_0201 TYPE REF TO CL_GUI_ALV_GRID.
DATA : GS_LAYOUT_0201 TYPE LVC_S_LAYO.
DATA : GT_SORT_0201 TYPE LVC_T_SORT.
DATA : GT_EXCLUDE_0201 TYPE UI_FUNCTIONS.
DATA : GT_FIELDCAT_0201 TYPE LVC_T_FCAT.
