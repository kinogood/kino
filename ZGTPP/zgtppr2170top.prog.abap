*&---------------------------------------------------------------------*
*& Include          ZGTPPR2170TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES                                                               *
*----------------------------------------------------------------------*
TABLES: MARA, MARC, MARD, VBAK, VBAP, VBEP, MATDOC,
        ZGTPPT2170, "// 주문 할당 관리 Header.
        ZGTPPT2180, "// 주문 할당 관리 Detail.
        ZGTPPT2190, "// 절단/권취 작업 지시 관리.
        ZGTPPT2191, "// 절단/권취 작업 지시 관리 - BOM.
        ZGTPPT2420, "// (군포) 합판드럼 지정 규칙
        ZGTPPT2430, "// (전주) 목드럼 지정 규칙
        ZPPT0107,
        SSCRFIELDS. " 선택화면의 필드.

*----------------------------------------------------------------------*
* CONSTANTS                                                            *
*----------------------------------------------------------------------*
CONSTANTS: BEGIN OF GC_FCODE,
             ONLI      TYPE SY-UCOMM VALUE 'ONLI',
             BACK      TYPE SY-UCOMM VALUE 'BACK',
             EXIT      TYPE SY-UCOMM VALUE 'EXIT',
             CANCEL    TYPE SY-UCOMM VALUE 'CANCEL',
             SAVE      TYPE SY-UCOMM VALUE 'SAVE',
             FIXED_COL TYPE SY-UCOMM VALUE 'FIXED_COL',
           END OF GC_FCODE.

CONSTANTS: BEGIN OF GC_HANDLE,
             CUTTING TYPE SLIS_HANDL VALUE '0001',
             ALLOC   TYPE SLIS_HANDL VALUE '0002',
           END OF GC_HANDLE.

*----------------------------------------------------------------------*
* TYPES                                                                *
*----------------------------------------------------------------------*

TYPES: BEGIN OF TY_S_CUTTING,
         STATUS         TYPE CHAR10,
         ZCUT_ORD_NO    TYPE ZGTPPT2190-ZCUT_ORD_NO,
         ZCUT_ORD_ITEM  TYPE ZGTPPT2190-ZCUT_ORD_ITEM,
         ZORD_TYPE      TYPE ZGTPPT2180-ZORD_TYPE,
         ZORD_TYPE_TXT  TYPE DD07T-DDTEXT,
         LOEKZ          TYPE ZGTPPT2190-LOEKZ,      "절단지시취소지시자
         PRINT_STAT     TYPE ZGTPPT2190-PRINT_STAT, "라벨발행완료
         PRINT_STAT_TXT TYPE CHAR10,                "라벨발행
         ZGR_STAT       TYPE CHAR10,
         ZASSIGN_NO     TYPE ZGTPPT2170-ZASSIGN_NO,
         ZASSIGN_ITEM   TYPE ZGTPPT2180-ZASSIGN_ITEM,
         ZASSIGN_TYPE   TYPE ZGTPPT2170-ZASSIGN_TYPE,
         WERKS          TYPE ZGTPPT2170-WERKS,
         VBELN          TYPE ZGTPPT2170-VBELN,
         POSNR          TYPE ZGTPPT2170-POSNR,
         ETENR          TYPE ZGTPPT2170-ETENR,
         EDATU          TYPE ZGTPPT2170-EDATU,
         WEMENG         TYPE ZGTPPT2170-WEMENG,
         WELENG         TYPE ZGTPPT2170-WELENG,
         WECNT          TYPE ZGTPPT2170-WECNT,
         SHREQ          TYPE CHAR10,                "출하요청
         MATNR          TYPE ZGTPPT2170-MATNR,
         MAKTX          TYPE MAKT-MAKTX,
         LGORT          TYPE ZGTPPT2180-LGORT,
         F_CHARG        TYPE ZGTPPT2180-F_CHARG,
         LABST1         TYPE ZGTPPT2180-LABST1,
         LABST2         TYPE ZGTPPT2180-LABST2,
         LABST3         TYPE ZGTPPT2180-LABST3,
         ZCUT_YN        TYPE ZGTPPT2180-ZCUT_YN,
         ZREW_YN        TYPE ZGTPPT2180-ZREW_YN,
         ZEXCLUDE       TYPE ZGTPPT2180-ZEXCLUDE,
         ZCUT_LEN       TYPE ZGTPPT2190-ZCUT_LEN,
         VRKME          TYPE ZGTPPT2170-VRKME,
         T_CHARG        TYPE ZGTPPT2190-T_CHARG,
         ZCUT_CNT       TYPE ZGTPPT2190-ZCUT_CNT,
         ZCUT_MBLNR     TYPE ZGTPPT2190-ZCUT_MBLNR,
         ZCUT_MJAHR     TYPE ZGTPPT2190-ZCUT_MJAHR,
         ZCUT_ZEILE     TYPE ZGTPPT2190-ZCUT_ZEILE,
         A_CHARG        TYPE MATDOC-CHARG,          "배치번호(실제)
         ZCUT_BUDAT     TYPE MATDOC-BUDAT,          "절단전기일자
         ZCUT_RLEN      TYPE MATDOC-ERFMG,          "절단실제조장
         ZCUT_SCRAP     TYPE MATDOC-MENGE,          "절단스크랩
         ZCUT_LEN_STAT  TYPE CHAR10,                "절단조장(지시=실제)
         ORG_LENGTH     TYPE ZGTPPT2190-ORG_LENGTH, "원조장
         DRMAT          TYPE ZGTPPT2191-MATNR,
         DRTXT          TYPE MAKT-MAKTX,
         ZDR_MBLNR      TYPE ZGTPPT2191-ZDR_MBLNR,
         ZDR_MJAHR      TYPE ZGTPPT2191-ZDR_MJAHR,
         ZDR_ZEILE      TYPE ZGTPPT2191-ZDR_ZEILE,
         SOBKZ          TYPE ZGTPPT2190-SOBKZ,
         F_CHARG_ORG    TYPE ZGTPPT2180-F_CHARG_ORG, "배치번호(기존)
         MULTI_YN       TYPE ZGTPPT2190-MULTI_YN,  "다중할당여부
         CRDAT          TYPE ZGTPPT2190-CRDAT,
         CRTIM          TYPE ZGTPPT2190-CRTIM,
         CRNAM          TYPE ZGTPPT2190-CRNAM,
         ZUPT_STAT      TYPE ZGTPPT2170-ZUPT_STAT,
         ZUPT_MSG       TYPE ZGTPPT2170-ZUPT_MSG,
         SEL            TYPE ABAP_BOOL,
         RETURN         TYPE BAPIRET2_TAB,
       END OF TY_S_CUTTING.

TYPES: BEGIN OF TY_S_ALLOC,
         STATUS        TYPE CHAR10,
         ZASSIGN_TYPE  TYPE ZGTPPT2170-ZASSIGN_TYPE,
         ZTYPE_DESC    TYPE DD07T-DDTEXT,
         ZASSIGN_NO    TYPE ZGTPPT2180-ZASSIGN_NO,
         ZASSIGN_ITEM  TYPE ZGTPPT2180-ZASSIGN_ITEM,
         LOEKZ         TYPE ZGTPPT2170-LOEKZ,
         ZORD_TYPE     TYPE ZGTPPT2180-ZORD_TYPE,
         ZORD_TYPE_TXT TYPE DD07T-DDTEXT,
         ZSTAT         TYPE CHAR10,
         VBELN         TYPE ZGTPPT2170-VBELN,
         POSNR         TYPE ZGTPPT2170-POSNR,
         ETENR         TYPE ZGTPPT2170-ETENR,
         SHREQ         TYPE CHAR10,                 "출하요청
         EDATU         TYPE ZGTPPT2170-EDATU,
         DRDAT         TYPE ZLET0400-DRDAT,         "출하요청일자
         WEMENG        TYPE ZGTPPT2170-WEMENG,
         VRKME         TYPE ZGTPPT2170-VRKME,
         WELENG        TYPE ZGTPPT2170-WELENG,
         WECNT         TYPE ZGTPPT2170-WECNT,
         MATNR         TYPE ZGTPPT2170-MATNR,
         MAKTX         TYPE MAKT-MAKTX,
         ZZSPEC_NO     TYPE MARA-ZZSPEC_NO,
         F_CHARG       TYPE ZGTPPT2180-F_CHARG,
         LGORT         TYPE ZGTPPT2180-LGORT,
         LGOBE         TYPE T001L-LGOBE,
         LABST3        TYPE ZGTPPT2180-LABST3,
         MEINS         TYPE MARA-MEINS,
         ZCUT_YN       TYPE ZGTPPT2180-ZCUT_YN,
         ZCUT_CNT      TYPE ZGTPPT2180-ZCUT_CNT,
         ZREW_YN       TYPE ZGTPPT2180-ZREW_YN,
         F_CHARG_ORG   TYPE ZGTPPT2180-F_CHARG_ORG, "배치번호(기존)
         ZEXCLUDE      TYPE ZGTPPT2180-ZEXCLUDE,
         MENGE413      TYPE MATDOC-MENGE,         "413처리수량
         CRDAT         TYPE ZGTPPT2180-CRDAT,
         CRTIM         TYPE ZGTPPT2180-CRTIM,
         CRNAM         TYPE ZGTPPT2180-CRNAM,
         ZUPT_STAT     TYPE ZGTPPT2170-ZUPT_STAT,
         ZUPT_MSG      TYPE ZGTPPT2170-ZUPT_MSG,
         WERKS         TYPE ZGTPPT2170-WERKS,
         SEL           TYPE ABAP_BOOL,
         RETURN        TYPE BAPIRET2_TAB,
       END OF TY_S_ALLOC.

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
DATA GR_DOCKING_CONTAINER  TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA GR_SPLITTER_CONTAINER TYPE REF TO CL_GUI_SPLITTER_CONTAINER.
DATA GR_TOP_CONTAINER      TYPE REF TO CL_GUI_CONTAINER.
DATA GR_BOTTOM_CONTAINER   TYPE REF TO CL_GUI_CONTAINER.
DATA GR_LEFT_CONTAINER     TYPE REF TO CL_GUI_CONTAINER.
DATA GR_RIGHT_CONTAINER    TYPE REF TO CL_GUI_CONTAINER.

DATA GR_CUTTING TYPE REF TO ZGTPP_CL_LIST.
DATA GR_ALLOC   TYPE REF TO ZGTPP_CL_LIST.

DATA GT_CUTTING TYPE TABLE OF TY_S_CUTTING.
DATA GT_ALLOC   TYPE TABLE OF TY_S_ALLOC.

DATA GS_T001W TYPE T001W.
DATA GT_DD07V TYPE TABLE OF DD07V.

DATA GR_CONV TYPE REF TO ZGTPP_CL_CONV.

DATA GS_RESULT  TYPE TY_S_RESULT.
DATA GV_MODE    TYPE CHAR10.
DATA GT_EXCLUDE TYPE UI_FUNCTIONS.
DATA GT_STYLE   TYPE LVC_T_STYL.
DATA GV_SAVED   TYPE ABAP_BOOL.
DATA GV_OKCODE  TYPE SY-UCOMM.
DATA GV_TPAR1   TYPE SYST_MSGV.
DATA GV_TPAR2   TYPE SYST_MSGV.
