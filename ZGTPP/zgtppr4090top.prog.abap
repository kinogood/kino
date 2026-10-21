*&---------------------------------------------------------------------*
*& Include          ZGTPPR4090TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES                                                               *
*----------------------------------------------------------------------*
TABLES: MARC,
        ZGTPPT1120, "//	공정 및 물자 스크랩 코드 관리(GAON)
        ZGTPPT1130, "//	탈피 후 스크랩 자재 관리(GAON)
        ZGTPPT1140, "//	생산 스크랩 코드 관리(GAON)
        ZGTPPT4110, "//	스크랩 계근실적(GAON)
        ZGTPPT4120, "//	스크랩 탈피 후 환산량(군포)(GAON)
        ZGTPPT4130, "// 스크랩 계근 실적 상세 (GAON)
        ZGTPPT4140, "// 설비-작업장 Mapping (GAON)
        ZGTPPT4141, "// CS 설비 List (GAON)
        SSCRFIELDS. "// 선택화면 필드.

*----------------------------------------------------------------------*
* CONSTANTS                                                            *
*----------------------------------------------------------------------*
CONSTANTS: BEGIN OF GC_FCODE,
             ONLI       TYPE SY-UCOMM VALUE 'ONLI',
             BACK       TYPE SY-UCOMM VALUE 'BACK',
             EXIT       TYPE SY-UCOMM VALUE 'EXIT',
             CANCEL     TYPE SY-UCOMM VALUE 'CANCEL',
             SAVE       TYPE SY-UCOMM VALUE 'SAVE',
             DELETE     TYPE SY-UCOMM VALUE 'DELETE',
             DETAIL     TYPE SY-UCOMM VALUE 'DETAIL',
             DISPLAY    TYPE SY-UCOMM VALUE 'DISPLAY',
             FIXED_COL  TYPE SY-UCOMM VALUE 'FIXED_COL',
             FC01       TYPE SY-UCOMM VALUE 'FC01',
             DISP_SCRAT TYPE SY-UCOMM VALUE 'DISP_SCRAT',
             INSERT_ROW TYPE SY-UCOMM VALUE 'INSERT_ROW',
             DELETE_ROW TYPE SY-UCOMM VALUE 'DELETE_ROW',
           END OF GC_FCODE.

CONSTANTS: BEGIN OF GC_HANDLE,
             LIST     TYPE SLIS_HANDL VALUE '0001',
             WEIGHING TYPE SLIS_HANDL VALUE '0002',
           END OF GC_HANDLE.

CONSTANTS: BEGIN OF GC_WERKS,
             6500 TYPE T001W-WERKS VALUE '6500',
             6600 TYPE T001W-WERKS VALUE '6600',
           END OF GC_WERKS.

CONSTANTS: BEGIN OF GC_LGORT,
             2190 TYPE T001L-LGORT VALUE '2190',
             2390 TYPE T001L-LGORT VALUE '2390',
           END OF GC_LGORT.

CONSTANTS: BEGIN OF GC_BWART,
             309 TYPE MSEG-BWART VALUE '309',
             Z31 TYPE MSEG-BWART VALUE 'Z31',
             Z41 TYPE MSEG-BWART VALUE 'Z41',
           END OF GC_BWART.

CONSTANTS: BEGIN OF GC_CODEGRP,
             4050 TYPE ZGTPPT1010-CODEGRP VALUE '4050', "// 발생부서.
             4060 TYPE ZGTPPT1010-CODEGRP VALUE '4060', "// 스크랩사유.
             4070 TYPE ZGTPPT1010-CODEGRP VALUE '4070', "// 스크랩코드.
             4080 TYPE ZGTPPT1010-CODEGRP VALUE '4080', "// 코스트센터.
             4090 TYPE ZGTPPT1010-CODEGRP VALUE '4090', "// 공정
           END OF GC_CODEGRP.

CONSTANTS: BEGIN OF GC_CS_ARBPL,
             DCM   TYPE ZGTPPT4110-CS_ARBPL VALUE 'DCM' , "// DCM
             PCT   TYPE ZGTPPT4110-CS_ARBPL VALUE 'PCT' , "// 절단실
             ETCPM TYPE ZGTPPT4110-CS_ARBPL VALUE 'ETCPM' , "// 기타 생산관리
           END OF GC_CS_ARBPL.

CONSTANTS: BEGIN OF GC_DISPLAY,
             ALL    TYPE CHAR10 VALUE 'ALL',
             SINGLE TYPE CHAR10 VALUE 'SINGLE',
           END OF GC_DISPLAY.

CONSTANTS: BEGIN OF GC_TABLE,
             ZGTPPT4110 TYPE RSTABLE-TABNAME VALUE 'ZGTPPT4110',
             ZGTPPT4140 TYPE RSTABLE-TABNAME VALUE 'ZGTPPT4140',
           END OF GC_TABLE.

*----------------------------------------------------------------------*
* TYPES                                                                *
*----------------------------------------------------------------------*
TYPES: BEGIN OF TY_S_MATDOC.
         INCLUDE TYPE BAPI2017_GM_HEAD_RET.
TYPES:   BWART TYPE MSEG-BWART,
         BUDAT TYPE MKPF-BUDAT,
         DEL   TYPE ABAP_BOOL,
       END OF TY_S_MATDOC.

TYPES: TY_T_MATDOC TYPE TABLE OF TY_S_MATDOC WITH DEFAULT KEY.

TYPES: BEGIN OF TY_S_LIST,
         SCPNR          TYPE ZGTPPT4110-SCPNR,       "// 계근번호
         WERKS          TYPE ZGTPPT4110-WERKS,       "// 플랜트
         SPGCD          TYPE ZGTPPT4110-SPGCD,       "// SPG코드
         LGORT          TYPE ZGTPPT4110-LGORT,       "// 저장위치
         INDEPT_DDLB    TYPE CHAR30,                 "// 발생부서 DDLB
         INDEPT         TYPE ZGTPPT4110-INDEPT,      "// 발생부서
         DEPTXT         TYPE ZGTPPT4110-DEPTXT,      "// 부서명/반납자
         CS_ARBPL       TYPE ZGTPPT4110-CS_ARBPL,    "// CS 설비코드
         OPCOD          TYPE ZGTPPT4110-OPCOD,       "// 발생공정
         SCGRP_DDLB     TYPE CHAR30,                 "// 스크랩분류 코드 DDLB
         SCGRP          TYPE ZGTPPT4110-SCGRP,       "// 스크랩분류 코드
         SCTXT          TYPE ZGTPPT4110-SCTXT,       "// 코드내역
         CNMAT          TYPE ZGTPPT4110-CNMAT,       "// 재질
         MATNR          TYPE ZGTPPT4110-MATNR,       "// 생산 스크랩 코드
         MAKTX          TYPE ZGTPPT4110-MAKTX,       "// 생산 스크랩 내역
         SCPQT          TYPE ZGTPPT4110-SCPQT,       "// 스크랩 중량
         MEINS          TYPE ZGTPPT4110-MEINS,       "// 계근 단위
         SCPREASON_DDLB TYPE CHAR30,                 "// SCRAP 사유 DDLB
         SCPREASON      TYPE ZGTPPT4110-SCPREASON,   "// SCRAP 사유
         SCPDAT         TYPE ZGTPPT4110-SCPDAT,      "// 계근일자
         WERKS_M        TYPE ZGTPPT4110-WERKS_M,     "// 물자 플랜트
         LGORT_M        TYPE ZGTPPT4110-LGORT_M,     "// 물자 저장위치
         MATNR_M        TYPE ZGTPPT4110-MATNR_M,     "// 물자 스크랩 코드
         MAKTX_M        TYPE ZGTPPT4110-MAKTX_M,     "// 물자 스크랩 내역
         STATUS         TYPE CHAR10 ,                "// Status
         MESSAGE        TYPE CHAR100,                "// 메시지
         MBLNR_309      TYPE ZGTPPT4110-MBLNR_309,   "// 스크랩 대체 자재문서
         MBLNR_Z31      TYPE ZGTPPT4110-MBLNR_Z31,   "// 탈피 전 자재(물자) 출고 자재문서
         MBLNR_Z41      TYPE ZGTPPT4110-MBLNR_Z41,   "// 탈피 후 자재(물자) 입고 자재문서
         MBLNR_309_C    TYPE ZGTPPT4110-MBLNR_309_C, "// 스크랩 대체 취소
         MBLNR_Z31_C    TYPE ZGTPPT4110-MBLNR_Z31_C, "// 물자 스크랩 출고 취소
         MBLNR_Z41_C    TYPE ZGTPPT4110-MBLNR_Z41_C, "// 탈피 후 자재 입고  취소
         MJAHR          TYPE ZGTPPT4110-MJAHR,       "// 자재 문서 연도
         CRDAT          TYPE ZGTPPT4110-CRDAT,       "// 처리일자
         CRTIM          TYPE ZGTPPT4110-CRTIM,       "// 처리시간
         CRNAM          TYPE ZGTPPT4110-CRNAM,       "// 처리자
         CHDAT          TYPE ZGTPPT4110-CHDAT,       "// 변경일
         CHTIM          TYPE ZGTPPT4110-CHTIM,       "// 변경시간
         CHNAM          TYPE ZGTPPT4110-CHNAM,       "// 변경인
         MATDOC         TYPE TY_T_MATDOC,
         RETURN         TYPE BAPIRET2_TAB,
         CLICKED        TYPE ABAP_BOOL,
         STYLE          TYPE LVC_T_STYL,
         INIT           TYPE ABAP_BOOL,
         SEL            TYPE ABAP_BOOL,
         DEL            TYPE ABAP_BOOL,
       END OF TY_S_LIST.

TYPES: BEGIN OF TY_S_WEIGHING,
         SCPNR       TYPE ZGTPPT4120-SCPNR,     "// 계근번호
         INDEPT_DDLB TYPE CHAR30,               "// 발생부서 DDLB
         CS_ARBPL    TYPE ZGTPPT4110-CS_ARBPL,  "// CS 설비코드
         SCGRP_DDLB  TYPE CHAR30,               "// 스크랩분류 코드 DDLB
         MATNR_T1    TYPE ZGTPPT4120-MATNR_T1,  "// 환원자재1
         MAKTX1      TYPE MAKT-MAKTX,           "// 자재내역
         SCRAT1      TYPE ZGTPPT4120-SCRAT1,    "// 환산율
         MENGE1      TYPE ZGTPPT4120-MENGE1,    "// 입고수량
         MATNR_T2    TYPE ZGTPPT4120-MATNR_T2,  "// 환원자재2
         MAKTX2      TYPE MAKT-MAKTX,           "// 자재내역
         SCRAT2      TYPE ZGTPPT4120-SCRAT2,    "// 환산율
         MENGE2      TYPE ZGTPPT4120-MENGE2,    "// 입고수량
         MATNR_T3    TYPE ZGTPPT4120-MATNR_T3,  "// 환원자재3
         MAKTX3      TYPE MAKT-MAKTX,           "// 자재내역
         SCRAT3      TYPE ZGTPPT4120-SCRAT3,    "// 환산율
         MENGE3      TYPE ZGTPPT4120-MENGE3,    "// 입고수량
         MATNR_T4    TYPE ZGTPPT4120-MATNR_T4,  "// 환원자재4
         MAKTX4      TYPE MAKT-MAKTX,           "// 자재내역
         SCRAT4      TYPE ZGTPPT4120-SCRAT4,    "// 환산율
         MENGE4      TYPE ZGTPPT4120-MENGE4,    "// 입고수량
         MEINS       TYPE ZGTPPT4120-MEINS,     "// 입고단위
         RETURN      TYPE BAPIRET2_TAB,
         SEL         TYPE ABAP_BOOL,
       END OF TY_S_WEIGHING.

TYPES: BEGIN OF TY_S_DETAIL,
         SCPNR    TYPE ZGTPPT4130-SCPNR,     "// 계근번호
         WERKS    TYPE ZGTPPT4130-WERKS,     "// 플랜트
         SPGCD    TYPE ZGTPPT4130-SPGCD,     "// SPG코드
         CS_ARBPL TYPE ZGTPPT4130-CS_ARBPL,  "// CS 설비코드
         ARBPL    TYPE ZGTPPT4130-ARBPL,     "// 발생설비
         KTEXT    TYPE CRTX-KTEXT,           "// 설비내역
         OPCOD    TYPE ZGTPPT4130-OPCOD,     "// 발생공정
         MATNR    TYPE ZGTPPT4130-MATNR,     "// 생산 스크랩 코드
         MAKTX    TYPE ZGTPPT4130-MAKTX,     "// 생산 스크랩 내역
         WERKS_M  TYPE ZGTPPT4130-WERKS_M,   "// 물자 플랜트
         LGORT_M  TYPE ZGTPPT4130-LGORT_M,   "// 물자 저장위치
         MATNR_M  TYPE ZGTPPT4130-MATNR_M,   "// 물자 스크랩 코드
         SCPQT    TYPE ZGTPPT4130-SCPQT,     "// 스크랩중량
         MEINS    TYPE ZGTPPT4130-MEINS,     "// 스크랩중량 단위
       END OF TY_S_DETAIL.

TYPES: BEGIN OF TY_S_SCRAP,
         SCPNR    TYPE ZGTPPT4130-SCPNR,    "// 계근번호
         WERKS    TYPE ZGTPPT4130-WERKS,    "// 플랜트
         SPGCD    TYPE ZGTPPT4130-SPGCD,    "// SPG코드
         CS_ARBPL TYPE ZGTPPT4130-CS_ARBPL, "// CS 설비코드
         MATKL    TYPE ZGTPPT1140-MATKL,    "// 자재그룹
         MATNR    TYPE ZGTPPT4130-MATNR,    "// 생산 스크랩 코드
         MAKTX    TYPE ZGTPPT4130-MAKTX,    "// 생산 스크랩 내역
         WERKS_M  TYPE ZGTPPT4130-WERKS_M,  "// 물자 플랜트
         LGORT_M  TYPE ZGTPPT4130-LGORT_M,  "// 물자 저장위치
         MATNR_M  TYPE ZGTPPT4130-MATNR_M,  "// 물자 스크랩 코드
         SCPQT    TYPE ZGTPPT4130-SCPQT,    "// 스크랩중량
         MENGE    TYPE ZGTPPT4130-SCPQT,    "// 수량
         MEINS    TYPE ZGTPPT4130-MEINS,    "// 스크랩중량 단위
       END OF TY_S_SCRAP.

TYPES: TY_T_SCRAP TYPE TABLE OF TY_S_SCRAP WITH DEFAULT KEY.
TYPES: TY_T_ZGTPPT4130 TYPE TABLE OF ZGTPPT4130 WITH DEFAULT KEY.

TYPES: BEGIN OF TY_S_INDEPT,
         VALUE TYPE ZGTPPT4110-INDEPT,
         TEXT  TYPE CRTX-KTEXT,
       END OF TY_S_INDEPT.

TYPES: BEGIN OF TY_S_OPCOD,
         VALUE TYPE ZGTPPT4110-OPCOD,
         TEXT  TYPE CRTX-KTEXT,
       END OF TY_S_OPCOD.

TYPES: BEGIN OF TY_S_CRHD,
         WERKS TYPE CRHD-WERKS,
         ARBPL TYPE CRHD-ARBPL,
         KTEXT TYPE CRTX-KTEXT,
       END OF TY_S_CRHD.

TYPES: BEGIN OF TY_S_SCPREASON,
         VALUE TYPE ZGTPPT4110-SCPREASON,
         TEXT  TYPE CRTX-KTEXT,
       END OF TY_S_SCPREASON.

TYPES: BEGIN OF TY_S_AFRU,
         WERKS   TYPE CRHD-WERKS,
         ARBPL   TYPE CRHD-ARBPL,
         BUDAT   TYPE AFRU-BUDAT,
         LMNGA   TYPE AFRU-LMNGA,
         QLENGTH TYPE ZGTCVORDSYVAL-QLENGTH,
       END OF TY_S_AFRU.

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

DATA GR_LIST TYPE REF TO ZGTPP_CL_LIST.
DATA GT_LIST TYPE TABLE OF TY_S_LIST.

DATA GR_WEIGHING TYPE REF TO ZGTPP_CL_LIST.
DATA GT_WEIGHING TYPE TABLE OF TY_S_WEIGHING.

DATA GR_DETAIL TYPE REF TO ZGTPP_CL_LIST.
DATA GT_DETAIL TYPE TABLE OF TY_S_DETAIL.

DATA GT_ZGTPPT1010 TYPE TABLE OF ZGTPPT1010.
DATA GT_ZGTPPT1120 TYPE TABLE OF ZGTPPT1120.
DATA GT_ZGTPPT1130 TYPE TABLE OF ZGTPPT1130 WITH NON-UNIQUE SORTED KEY SKEY1
                                                            COMPONENTS WERKS SPGCD LGORT SCGRP.
DATA GT_ZGTPPT1140 TYPE TABLE OF ZGTPPT1140.

DATA GT_ZGTPPT4140 TYPE TABLE OF ZGTPPT4140.
DATA GT_ZGTPPT4141 TYPE HASHED TABLE OF ZGTPPT4141 WITH UNIQUE KEY WERKS CS_ARBPL.

DATA GT_T001L TYPE HASHED TABLE OF T001L WITH UNIQUE KEY WERKS LGORT.

DATA GT_INDEPT TYPE TABLE OF TY_S_INDEPT.
DATA GT_OPCOD  TYPE TABLE OF TY_S_OPCOD.
DATA GT_CRHD   TYPE TABLE OF TY_S_CRHD.
DATA GT_SCPREASON TYPE TABLE OF TY_S_SCPREASON.

DATA GS_RESULT TYPE TY_S_RESULT.
DATA GT_DROP TYPE LVC_T_DRAL.
DATA GS_ZGTPPS1001 TYPE ZGTPPS1001.

DATA GT_AFRU TYPE TABLE OF TY_S_AFRU.

DATA GV_MODE    TYPE CHAR10.
DATA GT_EXCLUDE TYPE UI_FUNCTIONS.
DATA GT_STYLE   TYPE LVC_T_STYL.
DATA GV_SAVED   TYPE ABAP_BOOL.
DATA GV_OKCODE  TYPE SY-UCOMM.
DATA GV_TPAR1   TYPE SYST_MSGV.

DATA GV_JOBS TYPE I.
DATA GT_RETURN1  TYPE TABLE OF BAPIRET2.
DATA GS_HEADRET1 TYPE BAPI2017_GM_HEAD_RET.
