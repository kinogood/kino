*&---------------------------------------------------------------------*
*& Include          ZGTPPR3180TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES                                                               *
*----------------------------------------------------------------------*
TABLES: MARC,
        AFKO,
        PLAF,
        RESB,
        VBPA,
        VBAP,
        VBEP,
        ZPPT0107,
        ZGTPPT3420,
        ZGTPPT3421,
        ZGTPPT3422,
        ZGTPPT2010,
        SSCRFIELDS. " 선택화면의 필드.

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
             CREATE     TYPE SY-UCOMM VALUE 'CREATE',
             CHANGE     TYPE SY-UCOMM VALUE 'CHANGE',
             DELETE     TYPE SY-UCOMM VALUE 'DELETE',
             MAT_REQ    TYPE SY-UCOMM VALUE 'MAT_REQ',
             REQ_COMP   TYPE SY-UCOMM VALUE 'REQ_COMP',
             REQ_BAS_FT TYPE SY-UCOMM VALUE 'REQ_BAS_FT',
             INDV_REQ   TYPE SY-UCOMM VALUE 'INDV_REQ',
             COMP_CHK   TYPE SY-UCOMM VALUE 'COMP_CHK',
             FERT_REQ   TYPE SY-UCOMM VALUE 'FERT_REQ',
             SELECT     TYPE SY-UCOMM VALUE 'SELECT',
             UNSELECT   TYPE SY-UCOMM VALUE 'UNSELECT',
           END OF GC_FCODE.

CONSTANTS: BEGIN OF GC_ORDTY,
             PRD TYPE CHAR04 VALUE 'PRD',
             PLN TYPE CHAR04 VALUE 'PLN',
           END OF GC_ORDTY.

CONSTANTS: BEGIN OF GC_GCATG,
             SALES_ORDER      TYPE CHAR10 VALUE '판매오더',
             PRODUCTION_ORDER TYPE CHAR10 VALUE 'SM오더',
             PLANED_ORDER     TYPE CHAR10 VALUE '계획오더',
             MANUAL_ORDER     TYPE CHAR10 VALUE '수작업 오더',
             MANUAL_WORK      TYPE CHAR10 VALUE '수작업',
             MTO              TYPE CHAR10 VALUE '판매오더',
           END OF GC_GCATG.

CONSTANTS: BEGIN OF GC_HANDLE,
             MREQ TYPE SLIS_HANDL VALUE '0001',
             LIST TYPE SLIS_HANDL VALUE '0002',
             COMP TYPE SLIS_HANDL VALUE '0003',
             SMAT TYPE SLIS_HANDL VALUE '0004',
             SPAC TYPE SLIS_HANDL VALUE '0005',
           END OF GC_HANDLE.

CONSTANTS GC_TABLE TYPE RSTABLE-TABNAME VALUE 'ZGTPPT3420'.

*----------------------------------------------------------------------*
* TYPES                                                                *
*----------------------------------------------------------------------*
TYPES: BEGIN OF TY_S_PACKING_MAT,
         MATNR   TYPE MARA-MATNR,
         MAKTX   TYPE MAKT-MAKTX,
         MEINS   TYPE MARA-MEINS,
         LGPRO   TYPE MARC-LGPRO,
         IS_DRUM TYPE ABAP_BOOL,
       END OF TY_S_PACKING_MAT.

TYPES: TY_T_PACKING_MAT TYPE TABLE OF TY_S_PACKING_MAT WITH DEFAULT KEY.

TYPES: BEGIN OF TY_S_PROD,
         SEL          TYPE CHAR01,                     "// 선택
         EXREQ        TYPE CHAR01,                     "// 청구 제외
         STATUS       TYPE CHAR10,                     "// 처리 상태
         WERKS        TYPE T001L-WERKS,                "// 플랜트
         SPGCD        TYPE ZPPT0107-SPGCD,             "// SPG코드
         IDNRK        TYPE RESB-MATNR,                 "// 소요자재
         IDNTX        TYPE MAKT-MAKTX,                 "// 자재내역
         BDMNG        TYPE RESB-BDMNG,                 "// 총 소요 수량
         MEINS        TYPE RESB-MEINS,                 "// 소요 단위
         REQMN        TYPE RESB-BDMNG,                 "// 총 소요 수량
         AUSCH        TYPE RESB-AUSCH,                 "// 구성품목 스크랩(%)
         REQDAT       TYPE ZGTPPT3420-REQDAT,          "// 입고 요청일
         LGORT        TYPE T001L-LGORT,                "// 현장 저장위치
         LGFSB        TYPE MARC-LGFSB,                 "//
         ORDNO        TYPE ZGTPPT2000-ORDNO,           "// 주문번호
         ORDPO        TYPE ZGTPPT2000-POSNR,           "// 주문번호 항목
         KUNNR        TYPE ZGTPPT2000-KUNNR,           "// 납품처
         NAME1        TYPE KNA1-NAME1,                 "// 납품처 내역
         EDATU        TYPE VBEP-EDATU,                 "// 납기
         GRPNR        TYPE ZGTPPT2010-GRPNR,           "// 조장구성표
         GUBUN        TYPE ZGTPPT3421-GUBUN,           "// 구분
         ORDNR        TYPE ZGTPPT2010-ORDNR,           "// 생산,계획오더
         ORDNR_I      TYPE ICON-ID,
         PDCAPROCCODE TYPE ZGTCVORDSYVAL-PDCAPROCCODE, "// 공정코드
         PLDAT        TYPE AFKO-GSTRS,                 "// 생산계획일
         EBELN        TYPE EKPO-EBELN,
         EBELP        TYPE EKPO-EBELP,
         MATNR        TYPE ZGTPPT2000-MATNR,           "// 생산자재
         MAKTX        TYPE ZGTPPT2000-MAKTX,           "// 자재 내역
         RSNUM        TYPE RESB-RSNUM,                 "// 예약번호
         RSPOS        TYPE RESB-RSPOS,                 "// 예약품목
         BDTER        TYPE RESB-BDTER,                 "// 소요일자
         RQMON        TYPE ZGTPPT3421-RQMON, "//작업요청월
         ZWKREQ       TYPE ZGTPPT3421-ZWKREQ, " //작업요청번호
         MESSAGE      TYPE CHAR100,                    "// 메시지
         REQNO        TYPE ZGTPPT3421-REQNO,           "// 청구번호
         POSNR        TYPE ZGTPPT3421-POSNR,           "// 청구품목번호
         DISPO        TYPE MARC-DISPO,                 "// MRP 관리자
         ORDTY        TYPE CHAR04,                     "// 오더유형
         ZZKDAUF      TYPE AUFK-ZZKDAUF,               "// 판매오더번호(MTS)
         ZZKDPOS      TYPE AUFK-ZZKDPOS,               "// 판매오더품목(MTS)
         EXCEPT       TYPE ABAP_BOOL,
         STYLE        TYPE LVC_T_STYL,
         RETURN       TYPE BAPIRET2_TAB,
       END OF TY_S_PROD.

TYPES: BEGIN OF TY_S_COMP_SCRAP,
         ORDNO TYPE ZGTPPT2000-ORDNO, "// 주문번호
         IDNRK TYPE RESB-MATNR,       "// 소요자재
         AUSCH TYPE RESB-AUSCH,       "// 구성품목 스크랩(%)
         TABIX TYPE SY-TABIX,
       END OF TY_S_COMP_SCRAP.

TYPES: BEGIN OF TY_S_SALES,
         SEL           TYPE CHAR01,                   "// 선택
         STATUS        TYPE CHAR10,                   "// 처리 상태
         WERKS         TYPE T001L-WERKS,              "// 플랜트
         SPGCD         TYPE ZPPT0107-SPGCD,           "// SPG코드
         PACK_MAT      TYPE MARC-MATNR,               "// 포장재
         PACK_MAT_TXT  TYPE MAKT-MAKTX,               "// 자재내역
         NEWDRUM       TYPE ZGTPPT3422-NEWDRUM,       "// 신드럼
         IRONDRUM      TYPE ZGTPPT3422-IRONDRUM,      "// 철드럼
         DRUMTITLEMARK TYPE ZGTPPT3422-DRUMTITLEMARK, "// 드럼자판 인쇄유무
         FLANGE_PROT   TYPE ZGTPPT3422-FLANGE_PROT,   "// 악판 골판지 유무
         HANJEON       TYPE ZGTPPT3422-HANJEON,       "// 한전유무
         PACK_METHOD   TYPE CABN-ATNAM,               "// 포장구분
         PACK_TXT      TYPE CAWN-ATWRT,               "// 포장내역
         DRUM_CNT      TYPE I,                        "// 청구 드럼 개수
         MEINS         TYPE MARA-MEINS,               "// 드럼 단위
         SKID_YN       TYPE CAWN-ATWRT,               "// SKID 사용유무
         PW_FACTOR     TYPE I,                        "// 포장목 개수
         DRUM_GUBUN    TYPE CAWN-ATWRT,               "// 드럼 구분
         HAWA_GUBUN    TYPE CAWN-ATWRT,               "// 상품 구분
         PRINT_METHOD  TYPE CAWN-ATWRT,               "// 프린트 방법
         REQDAT        TYPE ZGTPPT3420-REQDAT,        "// 입고 요청일
         LGPRO         TYPE T001L-LGORT,              "// 현장 저장위치
         GRPNR         TYPE CHAR100,
         INFACTOR      TYPE ZGTPPT2000-INFACTOR,
         VBELN         TYPE VBAP-VBELN,               "// 주문번호
         VBELP         TYPE VBAP-POSNR,               "// 주문 품목번호
         KUNNR         TYPE VBPA-KUNNR,               "// 납품처
         NAME1         TYPE KNA1-NAME1,               "// 납품처 내역
         ICON_ORDER    TYPE ICON-ID,
         MATNR         TYPE VBAP-MATNR,               "// 완제품코드
         MAKTX         TYPE MAKT-MAKTX,               "// 제품 내역
         EDATU         TYPE VBEP-EDATU,               "// 납기
         MESSAGE       TYPE CHAR100,                  "// 메시지
         REQNO         TYPE ZGTPPT3420-REQNO,         "// 청구번호
         POSNR         TYPE ZGTPPT3420-POSNR,         "// 청구 품목번호
         BANFN         TYPE ZGTPPT3420-BANFN,         "// 구매요청번호
         BNFPO         TYPE ZGTPPT3420-BNFPO,         "// 구매요청품목번호
         IS_DRUM       TYPE ABAP_BOOL,
         EXCEPT        TYPE ABAP_BOOL,
         STYLE         TYPE LVC_T_STYL,
         RETURN        TYPE BAPIRET2_TAB,
       END OF TY_S_SALES.

TYPES: BEGIN OF TY_S_LIST,
         STATUS   TYPE CHAR10,              "// 처리 상태
         WERKS    TYPE T001L-WERKS,         "// 플랜트
         SPGCD    TYPE ZGTPPT3420-SPGCD,    "// SPG코드
         REQNO    TYPE ZGTPPT3420-REQNO,    "// 청구번호
         POSNR    TYPE ZGTPPT3420-POSNR,    "// 청구 품목 번호
         GRPNR    TYPE CHAR100,
         MATNR    TYPE ZGTPPT3420-MATNR,    "// 청구 자재
         MAKTX    TYPE MAKT-MAKTX,          "// 자재 내역
         LFIMG    TYPE ZGTPPT3420-LFIMG,    "// 청구 수량
         ERFME    TYPE ZGTPPT3420-ERFME,    "// 청구 단위
         REQDAT   TYPE ZGTPPT3420-REQDAT,   "// 입고 요청일
         LGORT_T  TYPE T001L-LGORT,         "// 현장 저장위치
         DRUMFLAG TYPE ZGTPPT3420-DRUMFLAG, "// 드럼자재여부
         BANFN    TYPE ZGTPPT3420-BANFN,    "// 구매요청 번호
         BNFPO    TYPE ZGTPPT3420-BNFPO,    "// 구매요청 품목 번호
         EBELN    TYPE ZGTPPT3420-EBELN,    "// 구매문서 번호
         EBELP    TYPE ZGTPPT3420-EBELP,    "// 구매문서 품목 번호
         LABST    TYPE ZGTPPT3420-LFIMG,    "// 총 재고
         MESSAGE  TYPE CHAR100,             "// 메시지
         ERROR    TYPE ABAP_BOOL,
         SEL      TYPE ABAP_BOOL,
         DEL      TYPE ABAP_BOOL,
         RETURN   TYPE BAPIRET2_TAB,
       END OF TY_S_LIST.

TYPES: BEGIN OF TY_S_INDIVIUAL_REQ,
         MATNR   TYPE MARA-MATNR,         "// 자재코드
         MAKTX   TYPE MAKT-MAKTX,         "// 자재 내역
         LFIMG   TYPE ZGTPPT3420-LFIMG,   "// 청구수량
         ERFME   TYPE ZGTPPT3420-ERFME,   "// 청구단위
         REQDAT  TYPE ZGTPPT3420-REQDAT,  "// 청구요청일
         LGORT_T TYPE ZGTPPT3420-LGORT_T, "// 현장 저장위치
       END OF TY_S_INDIVIUAL_REQ.

TYPES: BEGIN OF TY_S_FERT_BASED_REQ,
         MATNR  TYPE MARA-MATNR,         "// 완제품 코드
         MAKTX  TYPE MAKT-MAKTX,         "// 자재 내역
         BMENG  TYPE STKO-BMENG,         "// 기준수량
         BMEIN  TYPE STKO-BMEIN,         "// 기준단위
         REQDAT TYPE ZGTPPT3420-REQDAT,  "// 청구요청일
         STLAN  TYPE MAST-STLAN,         "// BOM 용도
         STLAL  TYPE MAST-STLAL,         "// 대체 BOM
       END OF TY_S_FERT_BASED_REQ.

TYPES: BEGIN OF TY_S_SMRY_HEADER,
         WERKS  TYPE T001L-WERKS,       "// 플랜트
         REQDAT TYPE ZGTPPT3420-REQDAT, "// 청구요청일
         LGORT  TYPE T001L-LGORT,       "// 현장 저장위치
         LGOBE  TYPE T001L-LGOBE,       "// 현장 저장위치
       END OF TY_S_SMRY_HEADER.

TYPES: BEGIN OF TY_S_COMP,
         STUFE        TYPE STPOX-STUFE,                "// BOM LEVEL
         PDCAPROCCODE TYPE ZGTCVORDSYVAL-PDCAPROCCODE, "// 공정코드
         IDNRK        TYPE STPOX-IDNRK,                "// 구성품목
         MAKTX        TYPE MAKT-MAKTX,                 "// 자재 내역
         MENGE        TYPE STPOX-MENGE,                "// 소요수량
         LFIMG        TYPE STPOX-MENGE,                "// 청구수량
         MEINS        TYPE STPOX-MEINS,                "// 단위
         REQDAT       TYPE ZGTPPT3420-REQDAT,          "// 청구요청일
         LGFSB        TYPE MARC-LGFSB,                 "// 현장저장위치
         SEL          TYPE ABAP_BOOL,
       END OF TY_S_COMP.

TYPES: BEGIN OF TY_S_SUMMARY,
         WERKS         TYPE ZGTPPT3420-WERKS,         "// 플랜트
         SPGCD         TYPE ZGTPPT3420-SPGCD,         "// SPG코드
         MATNR         TYPE ZGTPPT3420-MATNR,         "// 청구 자재
         MAKTX         TYPE MAKT-MAKTX,               "// 자재 내역
         NEWDRUM       TYPE ZGTPPT3422-NEWDRUM,       "// 신드럼
         IRONDRUM      TYPE ZGTPPT3422-IRONDRUM,      "// 철드럼
         DRUMTITLEMARK TYPE ZGTPPT3422-DRUMTITLEMARK, "// 드럼자판 인쇄유무
         FLANGE_PROT   TYPE ZGTPPT3422-FLANGE_PROT,   "// 악판 골판지 유무
         HANJEON       TYPE ZGTPPT3422-HANJEON,       "// 한전유무
         LFIMG         TYPE ZGTPPT3420-LFIMG,         "// 청구 수량
         ERFME         TYPE ZGTPPT3420-ERFME,         "// 청구 단위
         STATUS        TYPE CHAR10,                   "// 처리 상태
         MESSAGE       TYPE CHAR100,                  "// 메시지
         SEL           TYPE ABAP_BOOL,
         RETURN        TYPE BAPIRET2_TAB,
       END OF TY_S_SUMMARY.

TYPES: BEGIN OF TY_S_ZGTPPT2010,
         GRPNR TYPE ZGTPPT2010-GRPNR,
         ORDNR TYPE ZGTPPT2010-ORDNR,
         ORDNO TYPE ZGTPPT2000-ORDNO,
         POSNR TYPE ZGTPPT2000-POSNR,
         KUNNR TYPE ZGTPPT2000-KUNNR,
         WERKS TYPE ZGTPPT2000-WERKS,
         SPGCD TYPE ZGTPPT2000-SPGCD,
         MAKTX TYPE ZGTPPT2000-MAKTX,
         GCATG TYPE ZGTPPT2000-GCATG,
         NAME1 TYPE KNA1-NAME1,
       END OF TY_S_ZGTPPT2010.

TYPES: BEGIN OF TY_S_ZGTPPT2340,
         WERKS  TYPE ZGTPPT2340-WERKS,
         SPGCD  TYPE ZGTPPT2340-SPGCD,
         ORDNR  TYPE ZGTPPT2340-ORDNR,
         MATNR  TYPE ZGTPPT3421-MATNR,
         RQMON  TYPE ZGTPPT2340-RQMON,
         ZWKREQ TYPE ZGTPPT2340-ZWKREQ,
         PLNUM  TYPE ZGTPPT2330-PLNUM,
       END OF TY_S_ZGTPPT2340.

TYPES: BEGIN OF TY_S_CHAR_DETAIL,
         ATNAM    TYPE CABN-ATNAM,
         VAL_DESC TYPE TT_BAPICHARACTVALUESDESCR,
       END OF TY_S_CHAR_DETAIL.

TYPES TY_T_CHAR TYPE TABLE OF ZGTMM_CV_BD_GET_VCOFSO WITH DEFAULT KEY.
TYPES TY_T_ORDSYVAL TYPE TABLE OF ZGTPP_CV_ORDSYVAL WITH DEFAULT KEY.

TYPES TY_T_VBEP TYPE TABLE OF VBEP WITH DEFAULT KEY.
TYPES TY_T_ZGTPPT3421 TYPE TABLE OF ZGTPPT3421 WITH DEFAULT KEY.
TYPES TY_T_ZGTPPT3422 TYPE TABLE OF ZGTPPT3422 WITH DEFAULT KEY.
TYPES TY_T_ZGTPPT2010 TYPE TABLE OF TY_S_ZGTPPT2010 WITH DEFAULT KEY.
TYPES TY_T_ZGTPPT2340 TYPE TABLE OF TY_S_ZGTPPT2340 WITH DEFAULT KEY.

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

DATA GR_MREQ TYPE REF TO ZGTPP_CL_LIST.
DATA GR_LIST TYPE REF TO ZGTPP_CL_LIST.
DATA GR_COMP TYPE REF TO ZGTPP_CL_LIST.
DATA GR_SMRY TYPE REF TO ZGTPP_CL_LIST.

DATA GT_PROD  TYPE TABLE OF TY_S_PROD.
DATA GT_PROD2  TYPE TABLE OF TY_S_PROD.
DATA GT_PROD3  TYPE TABLE OF TY_S_PROD.
DATA GT_SALES TYPE TABLE OF TY_S_SALES.
DATA GT_PACK_MAT TYPE TABLE OF TY_S_SALES.
DATA GT_LIST TYPE TABLE OF TY_S_LIST.
DATA GT_COMP TYPE TABLE OF TY_S_COMP.
DATA GT_SMRY TYPE TABLE OF TY_S_SUMMARY.
DATA GR_DATA TYPE REF TO DATA.

DATA GT_T001L TYPE HASHED TABLE OF T001L WITH UNIQUE KEY WERKS LGORT.
DATA GT_T006  TYPE HASHED TABLE OF T006  WITH UNIQUE KEY MSEHI.
DATA GT_MTART TYPE RANGE OF MARA-MTART.

DATA GS_ZGTPPS1001 TYPE ZGTPPS1001.

DATA GS_INDV_REQ TYPE TY_S_INDIVIUAL_REQ.
DATA GS_FERT_REQ TYPE TY_S_FERT_BASED_REQ.
DATA GS_SUMMARY TYPE TY_S_SMRY_HEADER.

DATA GT_CHAR_DETIAL TYPE TABLE OF TY_S_CHAR_DETAIL.
DATA GT_COMP_SCRAP  TYPE TABLE OF TY_S_COMP_SCRAP.

DATA GT_STYLE TYPE LVC_T_STYL.

DATA GS_RESULT  TYPE TY_S_RESULT.
DATA GV_MODE    TYPE CHAR10.
DATA GT_EXCLUDE TYPE UI_FUNCTIONS.
DATA GV_SAVED   TYPE ABAP_BOOL.
DATA GV_OKCODE  TYPE SY-UCOMM.
DATA GV_OKCODE2  TYPE SY-UCOMM.
DATA GV_OKCODE3 TYPE SY-UCOMM.
DATA GV_TPAR1   TYPE SYST_MSGV.

DATA GV_INCLUDE_SO.

DATA : BEGIN OF GS_HEADER_800,
         MATNR   TYPE MARA-MATNR,         "// 자재코드
         MAKTX   TYPE MAKT-MAKTX,         "// 자재 내역
         LFIMG   TYPE ZGTPPT3420-LFIMG,   "// 청구수량
         ERFME   TYPE ZGTPPT3420-ERFME,   "// 청구단위
         REQDAT  TYPE ZGTPPT3420-REQDAT,  "// 청구요청일
         LGORT_T TYPE ZGTPPT3420-LGORT_T, "// 현장 저장위치
         VBELN   TYPE VBAP-VBELN,
         VBELP   TYPE VBAP-POSNR,
       END OF GS_HEADER_800.


DATA : GT_2000 TYPE TABLE OF ZGTPPT2000.
DATA : GT_2000_FUL TYPE TABLE OF ZGTPPT2000.
DATA : GT_2010 TYPE TABLE OF ZGTPPT2010.
DATA : GT_2330 TYPE TABLE OF ZGTPPT2330.
DATA : GT_2340 TYPE TABLE OF ZGTPPT2340.
DATA : GT_3421 TYPE TABLE OF ZGTPPT3421.
DATA : GT_3422 TYPE TABLE OF ZGTPPT3422.

DATA : BEGIN OF GS_DISP_700,
         GRPNR    LIKE ZGTPPT2010-GRPNR,
         ORDNR    LIKE ZGTPPT2010-ORDNR,
         POSNR    LIKE ZGTPPT2010-POSNR,
         MATNR_DM LIKE ZGTPPT2010-MATNR_DM,
         MAKTX_DM LIKE MAKT-MAKTX,
         MENGE    LIKE MSEG-MENGE,
         MATNR    LIKE ZGTPPT2010-MATNR,
         MAKTX    LIKE MAKT-MAKTX,
       END OF GS_DISP_700.
DATA : GT_DISP_700 LIKE TABLE OF GS_DISP_700.

DATA : BEGIN OF GS_DISP_800,
         RQMON  LIKE ZGTPPT3421-RQMON, "//작업요청월
         ZWKREQ LIKE ZGTPPT3421-ZWKREQ, " //작업요청번호
         MATNR  LIKE ZGTPPT2330-MATNR,
         MAKTX  LIKE MAKT-MAKTX,
         IDNRK  LIKE RESB-MATNR,                 "// 소요자재
         IDNTX  LIKE MAKT-MAKTX,                 "// 자재내역
         BDMNG  LIKE RESB-BDMNG,                 "// 총 소요 수량
         MEINS  LIKE RESB-MEINS,                 "// 소요 단위
         REQMN  LIKE RESB-BDMNG,                 "// 총 소요 수량
         AUSCH  LIKE RESB-AUSCH,                 "// 구성품목 스크랩(%)
         REQDAT LIKE ZGTPPT3420-REQDAT,          "// 입고 요청일
         LGORT  LIKE T001L-LGORT,                "// 현장 저장위치
         LGFSB  LIKE MARC-LGFSB,                 "//
         ORDNO  LIKE ZGTPPT2000-ORDNO,           "// 주문번호
         ORDPO  LIKE ZGTPPT2000-POSNR,           "// 주문번호 항목
         ORDTY  LIKE ZGTPPT2340-ORDTY,                     "// 오더유형
         RSNUM  LIKE RESB-RSNUM,                 "// 예약번호
         RSPOS  LIKE RESB-RSPOS,                 "// 예약품목
         BDTER  LIKE RESB-BDTER,                 "// 소요일자
       END OF GS_DISP_800.
DATA : GT_DISP_800 LIKE TABLE OF GS_DISP_800.

DATA : BEGIN OF GS_CHK_REQNO,
         REQNO TYPE ZGTPPT3420-REQNO,
         POSNR TYPE ZGTPPT3420-POSNR,
       END OF GS_CHK_REQNO.
DATA : GT_CHK_REQNO LIKE TABLE OF GS_CHK_REQNO.

*-----------
*ALV GRID 700
DATA : GO_CONTAIN_0700 TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA : GO_GRID_0700 TYPE REF TO CL_GUI_ALV_GRID.
DATA : GS_LAYOUT_0700 TYPE LVC_S_LAYO.
DATA : GT_SORT_0700 TYPE LVC_T_SORT.
DATA : GT_EXCLUDE_0700 TYPE UI_FUNCTIONS.
DATA : GT_FIELDCAT_0700 TYPE LVC_T_FCAT.

*ALV GRID 800
DATA : GO_CONTAIN_0900 TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA : GO_GRID_0900 TYPE REF TO CL_GUI_ALV_GRID.
DATA : GS_LAYOUT_0900 TYPE LVC_S_LAYO.
DATA : GT_SORT_0900 TYPE LVC_T_SORT.
DATA : GT_EXCLUDE_0900 TYPE UI_FUNCTIONS.
DATA : GT_FIELDCAT_0900 TYPE LVC_T_FCAT.

* BDC 테이블
DATA GS_BDCPARAMS TYPE CTU_PARAMS .
DATA GS_BDCDATA TYPE BDCDATA .
DATA : GT_BDCDATA TYPE TABLE OF BDCDATA .
DATA : GT_MESSTAB TYPE TABLE OF BDCMSGCOLL .

DEFINE __SETTING_BDC_PARAMS.
  CLEAR: gS_BDCPARAMS.
  gS_BDCPARAMS-DISMODE  = 'E'.   " 처리모드
  gS_BDCPARAMS-UPDMODE  = 'S'.   " 갱신세션
*  MS_BDCPARAMS-CATTMODE = ''.   " CATT모드
  gS_BDCPARAMS-DEFSIZE  = 'X'.   " 기본화면
  gS_BDCPARAMS-RACOMMIT = 'X'.   " COMMAND 이후 지속
**  MS_BDCPARAMS-NOBINPT  = ' '.   " BI 세션
END-OF-DEFINITION.

DEFINE __BDC_DYNPRO.
  CLEAR gS_BDCDATA.
  gS_BDCDATA-PROGRAM  = &1.
  gS_BDCDATA-DYNPRO   = &2.
  gS_BDCDATA-DYNBEGIN = 'X'.
  APPEND gS_BDCDATA TO gT_BDCDATA.
END-OF-DEFINITION.

DEFINE __BDC_FIELD.
  CLEAR gS_BDCDATA.
  gS_BDCDATA-FNAM = &1.
  gS_BDCDATA-FVAL = conv #( &2 ).
  APPEND gS_BDCDATA TO gT_BDCDATA.
END-OF-DEFINITION.


DEFINE __BDC_TRANSACTION.
  CALL TRANSACTION &1 USING gT_BDCDATA
                              OPTIONS FROM gS_BDCPARAMS
                            MESSAGES INTO gT_MESSTAB.
END-OF-DEFINITION.
