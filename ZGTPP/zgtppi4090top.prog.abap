*&---------------------------------------------------------------------*
*& Include          ZGTPPI4090TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES                                                               *
*----------------------------------------------------------------------*
TABLES: MARC, MARD,
        ZGTPPT4090,  "// 재고실사 대상 확정 송신 이력.
        ZGTPPT4100,  "// 재고실사 대상 확정 송신 이력 - 꼬리표.
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
             SEND   TYPE SY-UCOMM VALUE 'SEND',
             RESEND TYPE SY-UCOMM VALUE 'RESEND',
             DETAIL TYPE SY-UCOMM VALUE 'DETAIL',
           END OF GC_FCODE.

CONSTANTS: BEGIN OF GC_HANDLE,
             HEADER TYPE SLIS_HANDL VALUE '0001',
             DETAIL TYPE SLIS_HANDL VALUE '0002',
           END OF GC_HANDLE.

*----------------------------------------------------------------------*
* TYPES                                                                *
*----------------------------------------------------------------------*
TYPES: BEGIN OF TY_S_DETAIL,
         ZIFKEY TYPE ZGTPPT4100-ZIFKEY, "// 인터페이스키
         INSMM  TYPE ZGTPPT4100-INSMM,  "// 재고실사년월
         WERKS  TYPE ZGTPPT4100-WERKS,  "// 플랜트
         NAME1  TYPE T001W-NAME1,       "// 플랜트내역
         LGORT  TYPE ZGTPPT4100-LGORT,  "// 저장위치
         LGOBE  TYPE T001L-LGOBE,       "// 저장위치내역
         ZCOUNT TYPE ZGTPPT4100-ZCOUNT, "// 차수
         MATNR  TYPE ZGTPPT4100-MATNR,  "// 자재코드
         MAKTX  TYPE MAKT-MAKTX,        "// 자재내역
         SEQNO  TYPE ZGTPPT4100-SEQNO,  "// 순번
         CHARG  TYPE ZGTPPT4100-CHARG,  "// 배치번호
         TAGNR  TYPE ZPPT0602-TAGNR,    "// 꼬리표번호
         MGVRG  TYPE ZGTPPT4100-MGVRG,  "// 총수량
         REMAIN TYPE ZGTPPT4100-REMAIN, "// 잔량
         MEINS  TYPE ZGTPPT4100-MEINS,  "// 기본단위
         MATKL  TYPE MARA-MATKL,
       END OF TY_S_DETAIL.

TYPES: TY_T_DETAIL TYPE TABLE OF TY_S_DETAIL WITH DEFAULT KEY
                                             WITH NON-UNIQUE SORTED KEY SKEY1 COMPONENTS ZIFKEY INSMM WERKS LGORT MATNR CHARG.

TYPES: BEGIN OF TY_S_HEADER,
         ZIFKEY       TYPE ZGTPPT4090-ZIFKEY,     "// 인터페이스키
         STATUS       TYPE CHAR10,                "// 전송상태
         ZSTAT        TYPE ZGTPPT4090-ZSTAT,      "// 전송상태
         ZMESSAGE     TYPE ZGTPPT4090-ZMESSAGE,   "// 결과 메시지
         ZSYSTEM_ID   TYPE ZGTPPT4090-ZSYSTEM_ID, "// 송신 대상 시스템
         ZSYSTEM_DESC TYPE CHAR20,                "// 시스템 내역
         INSMM        TYPE ZPPT0601-INSMM,        "// 재고실사년월
         WERKS        TYPE ZPPT0601-WERKS,        "// 플랜트
         NAME1        TYPE T001W-NAME1,           "// 플랜트내역
         LGORT        TYPE ZPPT0601-LGORT,        "// 저장위치
         LGOBE        TYPE T001L-LGOBE,           "// 저장위치내역
         ZCOUNT       TYPE ZGTPPT4090-ZCOUNT,     "// 차수
         MATNR        TYPE ZPPT0601-MATNR,        "// 자재코드
         MAKTX        TYPE MAKT-MAKTX,            "// 자재내역
         SEQNO        TYPE ZGTPPT4090-SEQNO,      "// 순번
         CHARG        TYPE ZPPT0601-CHARG,        "// 배치번호
         ITYPE        TYPE ZPPT0601-ITYPE,        "// 재고구분
         ITYPE_TXT    TYPE CHAR40,                "// 구분명
         MENGE        TYPE ZGTPPT4090-MENGE,      "// 재고수량
         MEINS        TYPE ZGTPPT4090-MEINS,      "// 재고 단위
         SPGCD        TYPE ZPPT0601-SPGCD,        "// SPG
         VBELN        TYPE ZPPT0601-VBELN,        "// 판매문서번호
         POSNR        TYPE ZPPT0601-POSNR,        "// 판매문서항번
         SDATE        TYPE ZPPT0601-SDATE,        "// 대상선정일
         DETAIL       TYPE TY_T_DETAIL,
       END OF TY_S_HEADER.

TYPES: TY_T_ZGTPPSIF0058 TYPE TABLE OF ZGTPPSIF0058 WITH DEFAULT KEY,
       TY_T_ZGTPPSIF0059 TYPE TABLE OF ZGTPPSIF0059 WITH DEFAULT KEY.

TYPES: BEGIN OF TY_S_PHY_INV,
         LIST  TYPE TY_T_ZGTPPSIF0058,
         TAGNR TYPE TY_T_ZGTPPSIF0059,
       END OF TY_S_PHY_INV.

TYPES: BEGIN OF TY_S_RESULT,
         SEL      TYPE SY-TABIX,
         TOTAL    TYPE SY-TABIX,
         SUCCESS  TYPE SY-TABIX,
         ERROR    TYPE SY-TABIX,
         INVALID  TYPE ABAP_BOOL,
         ZSTAT    TYPE ZO_RESULT,
         ZMESSAGE TYPE ZO_MESSAGE,
         SYS_MSG  TYPE CHAR255,
       END OF TY_S_RESULT.

*----------------------------------------------------------------------*
* DATA                                                                 *
*----------------------------------------------------------------------*
DATA GR_DOCKING_CONTAINER  TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA GR_SPLITTER_CONTAINER TYPE REF TO CL_GUI_SPLITTER_CONTAINER.
DATA GR_TOP_CONTAINER      TYPE REF TO CL_GUI_CONTAINER.
DATA GR_BOTTOM_CONTAINER   TYPE REF TO CL_GUI_CONTAINER.

DATA GR_HEADER TYPE REF TO ZGTPP_CL_LIST.
DATA GT_HEADER TYPE TABLE OF TY_S_HEADER.

DATA GR_DETAIL TYPE REF TO ZGTPP_CL_LIST.
DATA GT_DETAIL TYPE TABLE OF TY_S_DETAIL.

DATA GT_ZGTPPT4090 TYPE TABLE OF ZGTPPT4090.
DATA GT_ZGTPPT4100 TYPE TABLE OF ZGTPPT4100.

DATA GS_PHY_INV TYPE TY_S_PHY_INV.

DATA GT_WERKS TYPE RANGE OF MARC-WERKS.
DATA GT_ZSTAT TYPE RANGE OF ZGTPPT2200-ZSTAT.

DATA GT_DDLB  TYPE VRM_VALUES.
DATA GV_SYSTX TYPE CHAR40.

DATA GS_RESULT TYPE TY_S_RESULT.

DATA GT_ZGTPPT1010 TYPE TABLE OF ZGTPPT1010.

DATA GV_MODE    TYPE CHAR10.
DATA GT_EXCLUDE TYPE UI_FUNCTIONS.
DATA GV_SAVED   TYPE ABAP_BOOL.
DATA GV_OKCODE  TYPE SY-UCOMM.
DATA GV_TPAR1   TYPE SYST_MSGV.
DATA GV_EXEC(1).
