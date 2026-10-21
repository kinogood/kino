*&---------------------------------------------------------------------*
*& Include          ZGTPPR4100TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES                                                               *
*----------------------------------------------------------------------*
TABLES: ZPPT0600,   "// 재고실사 결과 테이블.
        ZPPT0610,   "// 재고실사 차이 전기 결과.
        SSCRFIELDS. "// 선택화면의 필드.

*----------------------------------------------------------------------*
* CONSTANTS                                                            *
*----------------------------------------------------------------------*
CONSTANTS: BEGIN OF GC_FCODE,
             ONLI       TYPE SY-UCOMM VALUE 'ONLI',
             BACK       TYPE SY-UCOMM VALUE 'BACK',
             EXIT       TYPE SY-UCOMM VALUE 'EXIT',
             CANCEL     TYPE SY-UCOMM VALUE 'CANCEL',
             SAVE       TYPE SY-UCOMM VALUE 'SAVE',
             FC01       TYPE SY-UCOMM VALUE 'FC01',
             POST       TYPE SY-UCOMM VALUE 'POST',
             SCRAP      TYPE SY-UCOMM VALUE 'SCRAP',
             CNCL_POST  TYPE SY-UCOMM VALUE 'CNCL_POST',
             CNCL_SCRAP TYPE SY-UCOMM VALUE 'CNCL_SCRAP',
           END OF GC_FCODE.

CONSTANTS: BEGIN OF GC_HANDLE,
             POST   TYPE SLIS_HANDL VALUE '0001',
             RESULT TYPE SLIS_HANDL VALUE '0002',
           END OF GC_HANDLE.

*----------------------------------------------------------------------*
* TYPES                                                                *
*----------------------------------------------------------------------*
TYPES: BEGIN OF TY_S_LIST,
         STAT      TYPE CHAR10,             "// 처리 상태, 취소 상태
         STAT_MSG  TYPE CHAR100,            "// 처리 메시지
         ITEM_NO   TYPE ZPPT0610-ITEM_NO,   "// 처리 결과 항번
         ITEM_TYPE TYPE ZPPT0610-ITEM_TYPE, "// 처리 유형
         ITYPE_TXT TYPE CHAR20,             "// 처리 유형
         IBLNR     TYPE ZPPT0610-IBLNR,     "// 재고실사문서번호
         MBLNR     TYPE ZPPT0610-MBLNR,     "// 자재문서번호
         INSMM     TYPE ZPPT0610-INSMM,     "// 재고실사년월
         WERKS     TYPE ZPPT0610-WERKS,     "// 플랜트
         NAME1     TYPE T001W-NAME1,        "// 플랜트내역
         LGORT     TYPE ZPPT0610-LGORT,     "// 저장위치
         LGOBE     TYPE T001L-LGOBE,        "// 저장위치내역
         SEQNO     TYPE ZPPT0610-SEQNO,     "// 순번
         MATNR     TYPE ZPPT0610-MATNR,     "// 자재코드
         MAKTX     TYPE MAKT-MAKTX,         "// 자재내역

         CHARG     TYPE ZPPT0600-CHARG,     "// 배치번호
         TAGNR     TYPE ZPPT0600-TAGNR,     "// 꼬리표번호
         VBELN     TYPE ZPPT0600-VBELN,     "// 판매오더번호
         POSNR     TYPE ZPPT0600-POSNR,     "// 판매오더품목

         CHECK     TYPE CHAR10,             "// 조정 대상
         LABST     TYPE ZPPT0600-MENGE,     "// 전산수량
         MENGE     TYPE ZPPT0600-MENGE,     "// 재고조정수량
         MEINS     TYPE ZPPT0600-MEINS,     "// 단위

         ERFMG     TYPE MATDOC-ERFMG,       "// 처리수량
         ERFME     TYPE MATDOC-ERFME,       "// 처리단위
         CRDAT     TYPE ZPPT0610-CRDAT,     "// 생성일자
         CRTIM     TYPE ZPPT0610-CRTIM,     "// 생성시간
         CRNAM     TYPE ZPPT0610-CRNAM,     "// 생성자

         DISPO     TYPE MARC-DISPO,
         DSTR      TYPE ABAP_BOOL,
         SEL       TYPE ABAP_BOOL,
       END OF TY_S_LIST.

TYPES: BEGIN OF TY_S_AUFK,
         MATNR TYPE MATDOC-MATNR,
         WERKS TYPE MATDOC-WERKS,
         CHARG TYPE MATDOC-CHARG,
         AUFNR TYPE MATDOC-AUFNR,
         MEINS TYPE MATDOC-MEINS,
         MENGE TYPE MATDOC-MENGE,
       END OF TY_S_AUFK.

TYPES: BEGIN OF TY_S_MATDOC,
         MATNR TYPE MATDOC-MATNR,
         WERKS TYPE MATDOC-WERKS,
         MEINS TYPE MATDOC-MEINS,
         MENGE TYPE MATDOC-MENGE,
         COUNT TYPE I,
       END OF TY_S_MATDOC.

TYPES: BEGIN OF TY_S_RESULT,
         SEL      TYPE SY-TABIX,
         TOTAL    TYPE SY-TABIX,
         SUCCESS  TYPE SY-TABIX,
         ERROR    TYPE SY-TABIX,
         INVALID  TYPE ABAP_BOOL,
         MENGECHK TYPE ABAP_BOOL,
         MESSAGE  TYPE CHAR100,
       END OF TY_S_RESULT.

*----------------------------------------------------------------------*
* DATA                                                                 *
*----------------------------------------------------------------------*
DATA GR_LIST TYPE REF TO ZGTPP_CL_LIST.
DATA GT_LIST TYPE TABLE OF TY_S_LIST.

DATA GT_MARD TYPE TABLE OF MARD WITH NON-UNIQUE SORTED KEY SKEY COMPONENTS MATNR WERKS LGORT.
DATA GT_MCHB TYPE TABLE OF MCHB WITH NON-UNIQUE SORTED KEY SKEY COMPONENTS MATNR WERKS LGORT CHARG.
DATA GT_MSKA TYPE TABLE OF MSKA WITH NON-UNIQUE SORTED KEY SKEY COMPONENTS MATNR WERKS LGORT CHARG VBELN POSNR.

DATA GT_MARDH TYPE TABLE OF MARDH WITH NON-UNIQUE SORTED KEY SKEY COMPONENTS MATNR WERKS LGORT.
DATA GT_MCHBH TYPE TABLE OF MCHBH WITH NON-UNIQUE SORTED KEY SKEY COMPONENTS MATNR WERKS LGORT CHARG.
DATA GT_MSKAH TYPE TABLE OF MSKAH WITH NON-UNIQUE SORTED KEY SKEY COMPONENTS MATNR WERKS LGORT CHARG VBELN POSNR.

DATA GT_MATDOC TYPE TABLE OF TY_S_MATDOC.
DATA GT_AUFK TYPE TABLE OF TY_S_AUFK.

DATA GT_MTART TYPE RANGE OF MARA-MTART.
DATA GT_XCHPF TYPE RANGE OF MARA-XCHPF.
DATA GT_DD07T TYPE TABLE OF DD07T.

DATA GT_BDCDATA TYPE TABLE OF BDCDATA.

DATA GV_FROM TYPE SY-DATUM.
DATA GV_TO   TYPE SY-DATUM..

DATA GV_ITEM_TYPE TYPE ZPPT0610-ITEM_TYPE.

DATA GS_RESULT  TYPE TY_S_RESULT.
DATA GV_MODE    TYPE CHAR10.
DATA GT_EXCLUDE TYPE UI_FUNCTIONS.
DATA GV_SAVED   TYPE ABAP_BOOL.
DATA GV_OKCODE  TYPE SY-UCOMM.
DATA GV_TPAR1   TYPE SYST_MSGV.
DATA GV_TPAR2   TYPE SYST_MSGV.
