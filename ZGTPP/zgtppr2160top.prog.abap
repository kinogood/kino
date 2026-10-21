*&---------------------------------------------------------------------*
*& Include          ZGTPPR2160TOP
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
             ONLI          TYPE SY-UCOMM VALUE 'ONLI',
             BACK          TYPE SY-UCOMM VALUE 'BACK',
             EXIT          TYPE SY-UCOMM VALUE 'EXIT',
             CANCEL        TYPE SY-UCOMM VALUE 'CANCEL',
             SAVE          TYPE SY-UCOMM VALUE 'SAVE',
             FC01          TYPE SY-UCOMM VALUE 'FC01',
             FC02          TYPE SY-UCOMM VALUE 'FC02',
             FIXED_COL     TYPE SY-UCOMM VALUE 'FIXED_COL',
             NO_ALLOC      TYPE SY-UCOMM VALUE 'NO_ALLOC',      "// 주문 할당 불가.
             OM_ASSIGN     TYPE SY-UCOMM VALUE 'OM_ASSIGN',     "// (임시) 할당 완료.
             SEL_STOCK     TYPE SY-UCOMM VALUE 'SEL_STOCK',     "// 재고 선택.
             SEL_STD_LEN   TYPE SY-UCOMM VALUE 'SEL_STD_LEN',   "// 재고 자동 선택(정조장).
             WKORD         TYPE SY-UCOMM VALUE 'WKORD',         "// 주문 할당&절단 지시.
             SEL_STOCK_CNC TYPE SY-UCOMM VALUE 'SEL_STOCK_CNC', "// 재고 선택 취소.
             UNDO          TYPE SY-UCOMM VALUE 'UNDO',          "// 주문 할당&절단 지시 취소.
             RESEND        TYPE SY-UCOMM VALUE 'RESEND',        "// 절단 지시 재전송.
             CANCEL_ALLOC  TYPE SY-UCOMM VALUE 'CANCEL_ALLOC',  "// 주문 할당 취소.
             XC_UPD        TYPE SY-UCOMM VALUE 'XC_UPD',        "// 삭제/완료 업데이트.
             INSERT_ROW    TYPE SY-UCOMM VALUE 'INSERT_ROW',
             DELETE_ROW    TYPE SY-UCOMM VALUE 'DELETE_ROW',
           END OF GC_FCODE.

CONSTANTS: BEGIN OF GC_HANDLE,
             SLORD  TYPE SLIS_HANDL VALUE '0001',
             STOCK  TYPE SLIS_HANDL VALUE '0002',
             WKORD  TYPE SLIS_HANDL VALUE '0003',
             RESULT TYPE SLIS_HANDL VALUE '0004',
             REWRK  TYPE SLIS_HANDL VALUE '0005',
             T2420  TYPE SLIS_HANDL VALUE '0006',
             T2430  TYPE SLIS_HANDL VALUE '0007',
           END OF GC_HANDLE.

CONSTANTS: BEGIN OF GC_WERKS,
             6500 TYPE T001W-WERKS VALUE '6500',
             6600 TYPE T001W-WERKS VALUE '6600',
           END OF GC_WERKS.

CONSTANTS: BEGIN OF GC_TABLE,
             ZGTPPT2420 TYPE RSTABLE-TABNAME VALUE 'ZGTPPT2420',
             ZGTPPT2430 TYPE RSTABLE-TABNAME VALUE 'ZGTPPT2430',
           END OF GC_TABLE.

CONSTANTS: BEGIN OF GC_TCODE,
             ZGTPPR2160 TYPE SY-TCODE VALUE 'ZGTPPR2160', "// [GT] 주문 할당 및 절단 지시 .
             ZGTPPR2161 TYPE SY-TCODE VALUE 'ZGTPPR2161', "// [GT] 주문 할당 및 절단 지시(상품).
             ZGTPPR2169 TYPE SY-TCODE VALUE 'ZGTPPR2169', "// [GT] 삭제/완료 업데이트.
           END OF GC_TCODE.

CONSTANTS GC_DUPLICATION TYPE LVC_FNAME VALUE 'ZZDUPLICATION'.

*----------------------------------------------------------------------*
* TYPES                                                                *
*----------------------------------------------------------------------*
TYPES: BEGIN OF TY_S_STOCK,
         STATUS        TYPE CHAR10,
         MATNR         TYPE MARA-MATNR,
         MAKTX         TYPE MAKT-MAKTX,
         CHARG         TYPE MCHB-CHARG,
         LABST1        TYPE ZGTPPS1006-LABST1,        "// 재고 수량.
         LABST2_ORGN   TYPE ZGTPPS1006-LABST2,        "// 초기 기할당 수량.
         LABST2        TYPE ZGTPPS1006-LABST2,        "// 기할당 수량.
         LABST3        TYPE ZGTPPS1006-LABST3,        "// 미할당 수량.
         MEINS         TYPE ZGTPPS1006-MEINS,         "// 단위.
         WELENG        TYPE ZGTPPS1005-WELENG,        "// 조장.
         WECNT         TYPE ZGTPPS1005-WECNT,         "// 조장수.
         ZCUT_YN       TYPE ZGTPPS1005-ZCUT_YN,       "// 절단 필요.
         ZCUT_CNT      TYPE ZGTPPS1005-ZCUT_CNT,      "// 절단 조장수.
         ZREW_YN       TYPE ZGTPPS1005-ZREW_YN,       "// 재권취 필요.
         ZEXCLUDE      TYPE ZGTPPS1005-ZEXCLUDE,      "// 재고 비활성.
         LGORT         TYPE MARD-LGORT,
         LGOBE         TYPE T001L-LGOBE,
         LWEDT         TYPE MCHA-LWEDT,               "// 생산일자.
         WERKS         TYPE ZGTPPS1005-WERKS,         "// 플랜트.
         ZASSIGN_NO    TYPE ZGTPPT2180-ZASSIGN_NO,    "// 주문 할당 번호.
         ZASSIGN_ITEM  TYPE ZGTPPT2180-ZASSIGN_ITEM,  "// 주문 할당 항번.
         ZORD_TYPE     TYPE ZGTPPT2180-ZORD_TYPE,     "// 지시 유형.
         ZORD_TYPE_TXT TYPE DD07T-DDTEXT,
         GUID          TYPE GUID,
         STOCK_GUID    TYPE GUID,
         RETURN        TYPE BAPIRET2_TAB,
       END OF TY_S_STOCK.

TYPES: TY_T_STOCK TYPE TABLE OF TY_S_STOCK WITH DEFAULT KEY
                                           WITH NON-UNIQUE SORTED KEY SKEY1 COMPONENTS GUID.

TYPES: TY_T_CONFG TYPE TABLE OF CONF_OUT WITH DEFAULT KEY
                                         WITH NON-UNIQUE SORTED KEY SKEY1 COMPONENTS ATNAM.

TYPES: BEGIN OF TY_S_SLORD,
         SEL          TYPE CHAR10,
         VBELN        TYPE VBAP-VBELN,
         POSNR        TYPE VBAP-POSNR,
         MATNR        TYPE VBAP-MATNR,
         MAKTX        TYPE MAKT-MAKTX,
         ZZSPEC_NO    TYPE MARA-ZZSPEC_NO,
         COLOR        TYPE CHAR30,            "// 색상(Base)
         COLOR_DETAIL TYPE CHAR30,            "// 색상(상세)
         COLOR_STRIPE TYPE CHAR30,            "// 색상(Stripe)
         COLOR_STR_NO TYPE CHAR30,            "// 색상(Stripe)수
         MTART        TYPE MARA-MTART,
         MATKL        TYPE MARA-MATKL,
         ERDAT        TYPE VBAK-ERDAT,
         EDATU        TYPE VBEP-EDATU,
         DRDAT        TYPE ZLET0400-DRDAT,    "// 출하요청일자
         ETENR        TYPE VBEP-ETENR,
         SHORTAGE     TYPE CHAR10,            "// 재고부족.
         STDLN        TYPE CHAR10,            "// 정조장 대응 가능.
         WEMENG       TYPE VBEP-WMENG,        "// 납품수량.
         VRKME        TYPE VBEP-VRKME,        "// 단위.
         WELENG       TYPE ZGTPPT2170-WELENG, "// 조장.
         WECNT        TYPE ZGTPPT2170-WECNT,  "// 조장 수.
         ALCMN        TYPE VBEP-WMENG,        "// 기할당 수량.
         ALCNT        TYPE ZGTPPT2170-WECNT,  "// 기할당 조장 수.
         KALAB        TYPE MSKA-KALAB,        "// 판매오더 재고.
         ZZCUT_REQ    TYPE AUFK-ZZCUT_REQ,    "// 특별사유 절단요청.
         KUNNR        TYPE VBAK-KUNNR,
         NAME1        TYPE KNA1-NAME1,
         ZZYUSCD      TYPE ZGTEYUSCD,         "// 영업소
         VKORG        TYPE VBAK-VKORG,
         VTWEG        TYPE VBAK-VTWEG,
         SPART        TYPE VBAK-SPART,
         VKGRP        TYPE VBAK-VKGRP,
         VKBUR        TYPE VBAK-VKBUR,
         SKID_YN      TYPE CHAR30,            "// SKIP유무.
         DRUM_GUBUN   TYPE CHAR30,            "// 드럼구분.
         PACKAGE      TYPE CHAR30,            "// 포장구분.
         FLANGE_PROT  TYPE CHAR30,            "// 악판골판지.
         PRINT        TYPE CHAR30,            "// 프린트.
         NEW_DRUM     TYPE CHAR30,            "// 신드럼사용.
         WRAP_PACKING TYPE CHAR30,            "// 랩포장.
         LIFSP        TYPE VBEP-LIFSP,
         FEVOR        TYPE MARC-FEVOR,
         CUOBJ        TYPE VBAP-CUOBJ,
         CUOBF        TYPE MARA-CUOBF,
         WERKS        TYPE MARD-WERKS,
         LGORT        TYPE MARD-LGORT,
         MEINS        TYPE MARA-MEINS,
         ZASSIGN_NO   TYPE ZGTPPT2170-ZASSIGN_NO,
         ZASSIGN_TYPE TYPE ZGTPPT2170-ZASSIGN_TYPE,
         ZUPT_STAT    TYPE ZGTPPT2170-ZUPT_STAT,
         ZUPT_MSG     TYPE ZGTPPT2170-ZUPT_MSG,
         KDAUF        TYPE AUFK-KDAUF,
         KDPOS        TYPE AUFK-KDPOS,
         ZZKDAUF      TYPE AUFK-ZZKDAUF,
         XCHAR        TYPE MARC-XCHAR,
         DPCBT        TYPE MARC-DPCBT,
         PK_DRUM      TYPE CHAR30,           "//드럼코드
         CONFG        TYPE TY_T_CONFG,
         STOCK        TYPE TY_T_STOCK,
       END OF TY_S_SLORD.

TYPES: BEGIN OF TY_S_WKORD,
         STATUS        TYPE CHAR10,
         ZCUT_ORD_NO   TYPE ZGTPPT2190-ZCUT_ORD_NO,
         ZCUT_ORD_ITEM TYPE ZGTPPT2190-ZCUT_ORD_ITEM,
         ZORD_TYPE     TYPE ZGTPPT2180-ZORD_TYPE,
         ZORD_TYPE_TXT TYPE DD07T-DDTEXT,
         ZCUT_STATUS   TYPE CHAR10,
         VBELN         TYPE ZGTPPT2170-VBELN,
         POSNR         TYPE ZGTPPT2170-POSNR,
         MATNR         TYPE ZGTPPT2170-MATNR,
         MAKTX         TYPE MAKT-MAKTX,
         F_CHARG       TYPE ZGTPPT2180-F_CHARG,
         LABST3        TYPE ZGTPPT2180-LABST3,
         ZCUT_LEN      TYPE ZGTPPT2190-ZCUT_LEN,
         MEINS         TYPE ZGTPPT2180-MEINS,
         ZCUT_YN       TYPE ZGTPPT2180-ZCUT_YN,
         ZREW_YN       TYPE ZGTPPT2180-ZREW_YN,
         ZEXCLUDE      TYPE ZGTPPT2180-ZEXCLUDE,
         T_CHARG       TYPE ZGTPPT2190-T_CHARG,
         ZCUT_CNT      TYPE ZGTPPT2190-ZCUT_CNT,
         DRMAT         TYPE MARA-MATNR,
         DRTXT         TYPE MAKT-MAKTX,
         DRMEI         TYPE MARA-MEINS,
         LGORT         TYPE ZGTPPS1006-LGORT,
         MULTI_YN      TYPE ZGTPPT2190-MULTI_YN, "다중할당여부
         WERKS         TYPE ZGTPPS1006-WERKS,
         ZASSIGN_NO    TYPE ZGTPPT2180-ZASSIGN_NO,
         ZASSIGN_ITEM  TYPE ZGTPPT2180-ZASSIGN_ITEM,
         REF_VBELN     TYPE VBAP-VBELN,
         REF_POSNR     TYPE VBAP-POSNR,
         GUID          TYPE GUID,
         STOCK_GUID    TYPE GUID,
         SEL           TYPE ABAP_BOOL,
         RETURN        TYPE BAPIRET2_TAB,
         BATCH_IDX     TYPE SY-TABIX,
       END OF TY_S_WKORD.

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
         SHREQ          TYPE CHAR10,                "출하요청
         ETENR          TYPE ZGTPPT2170-ETENR,
         EDATU          TYPE ZGTPPT2170-EDATU,
         WEMENG         TYPE ZGTPPT2170-WEMENG,
         WELENG         TYPE ZGTPPT2170-WELENG,
         WECNT          TYPE ZGTPPT2170-WECNT,
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
         MULTI_YN       TYPE ZGTPPT2190-MULTI_YN, "다중할당여부
         CRDAT          TYPE ZGTPPT2190-CRDAT,
         CRTIM          TYPE ZGTPPT2190-CRTIM,
         CRNAM          TYPE ZGTPPT2190-CRNAM,
         ZUPT_STAT      TYPE ZGTPPT2170-ZUPT_STAT,
         ZUPT_MSG       TYPE ZGTPPT2170-ZUPT_MSG,
         F_CHARG_ORG    TYPE ZGTPPT2180-F_CHARG_ORG, "배치번호(기존)
         SEL            TYPE ABAP_BOOL,
         RETURN         TYPE BAPIRET2_TAB,
         CHK_CUTMBLNR   TYPE CHAR1,     "취소 절단전표 체크
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
         SHREQ         TYPE CHAR10,
         EDATU         TYPE ZGTPPT2170-EDATU,
         DRDAT         TYPE ZLET0400-DRDAT,    "// 출하요청일자
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
         ZEXCLUDE      TYPE ZGTPPT2180-ZEXCLUDE,
         Z413          TYPE CHAR10,
         F_CHARG_ORG   TYPE ZGTPPT2180-F_CHARG_ORG, "배치번호(기존)
         CRDAT         TYPE ZGTPPT2180-CRDAT,
         CRTIM         TYPE ZGTPPT2180-CRTIM,
         CRNAM         TYPE ZGTPPT2180-CRNAM,
         ZUPT_STAT     TYPE ZGTPPT2170-ZUPT_STAT,
         ZUPT_MSG      TYPE ZGTPPT2170-ZUPT_MSG,
         WERKS         TYPE ZGTPPT2170-WERKS,
         SEL           TYPE ABAP_BOOL,
         RETURN        TYPE BAPIRET2_TAB,
       END OF TY_S_ALLOC.

TYPES: BEGIN OF TY_S_FIXED_LEN,
         WERKS TYPE MARC-WERKS,
         MATNR TYPE MARC-MATNR,
         CHARG TYPE MCHB-CHARG,
         AUFNR TYPE AUFK-AUFNR,
         VBELN TYPE VBAP-VBELN,
         POSNR TYPE VBAP-POSNR,
       END OF TY_S_FIXED_LEN.

TYPES: BEGIN OF TY_S_KLAH,
         MATNR TYPE MCH1-MATNR,
         CHARG TYPE MCH1-CHARG,
         CLASS TYPE KLAH-CLASS,
       END OF TY_S_KLAH.

TYPES: TY_T_ZGTPPT2170 TYPE TABLE OF ZGTPPT2170 WITH DEFAULT KEY
                                                WITH NON-UNIQUE SORTED KEY SKEY1 COMPONENTS ZASSIGN_NO.

TYPES TY_T_ZASSIGN_TYPE TYPE RANGE OF ZGTPPT2170-ZASSIGN_TYPE.

TYPES: BEGIN OF TY_S_T2420,
         WERKS      TYPE ZGTPPT2420-WERKS,     "// 플랜트
         NAME1      TYPE T001W-NAME1,          "// 플랜트 내역
         FROM_DRUM  TYPE ZGTPPT2420-FROM_DRUM, "// 전환 전 드럼코드
         FROM_MAKTX TYPE MAKT-MAKTX,           "// 전환 전 드럼내역
         TO_DRUM    TYPE ZGTPPT2420-TO_DRUM,   "// 전환 후 드럼코드
         TO_MAKTX   TYPE MAKT-MAKTX,           "// 전환 후 드럼내역
         STATUS     TYPE CHAR10,               "// 상태
         MESSAGE    TYPE CHAR50,               "// 메시지
         CRDAT      TYPE ZGTPPT2420-CRDAT,     "// 생성일
         CRTIM      TYPE ZGTPPT2420-CRTIM,     "// 생성시간
         CRNAM      TYPE ZGTPPT2420-CRNAM,     "// 생성자
         CHDAT      TYPE ZGTPPT2420-CHDAT,     "// 변경일
         CHTIM      TYPE ZGTPPT2420-CHTIM,     "// 변경시간
         CHNAM      TYPE ZGTPPT2420-CHNAM,     "// 변경자
         RETURN     TYPE BAPIRET2_TAB,
         STYLE      TYPE LVC_T_STYL,
         INIT       TYPE ABAP_BOOL,
         DUPLI      TYPE ABAP_BOOL,
         SEL        TYPE ABAP_BOOL,
       END OF TY_S_T2420.

TYPES: BEGIN OF TY_S_T2430,
         WERKS    TYPE ZGTPPT2430-WERKS,    "// 플랜트
         NAME1    TYPE T001W-NAME1,         "// 플랜트 내역
         MATNR    TYPE ZGTPPT2430-MATNR,    "// 품목코드
         MAKTX    TYPE MAKT-MAKTX,          "// 품목내역
         F_LENGTH TYPE ZGTPPT2430-F_LENGTH, "// 기준 조장길이(시작)
         T_LENGTH TYPE ZGTPPT2430-T_LENGTH, "// 기준 조장길이(종료)
         DRUMNR   TYPE ZGTPPT2430-DRUMNR,   "// 드럼코드
         DAKTX    TYPE MAKT-MAKTX,          "// 드럼내역
         STATUS   TYPE CHAR10,              "// 상태
         MESSAGE  TYPE CHAR50,              "// 메시지
         CRDAT    TYPE ZGTPPT2420-CRDAT,    "// 생성일
         CRTIM    TYPE ZGTPPT2420-CRTIM,    "// 생성시간
         CRNAM    TYPE ZGTPPT2420-CRNAM,    "// 생성자
         CHDAT    TYPE ZGTPPT2420-CHDAT,    "// 변경일
         CHTIM    TYPE ZGTPPT2420-CHTIM,    "// 변경시간
         CHNAM    TYPE ZGTPPT2420-CHNAM,    "// 변경자
         RETURN   TYPE BAPIRET2_TAB,
         STYLE    TYPE LVC_T_STYL,
         INIT     TYPE ABAP_BOOL,
         DUPLI    TYPE ABAP_BOOL,
         SEL      TYPE ABAP_BOOL,
       END OF TY_S_T2430.

TYPES: BEGIN OF TY_S_DRUM_CODE,
         SUL_NO    TYPE ZESUL_NO,
         REVNO     TYPE ZEREV_SEQ,
         ZZYUSCD   TYPE ZGTEYUSCD,
         JOJANG    TYPE CHAR6,
         DRUM_CODE TYPE CHAR6,
       END OF TY_S_DRUM_CODE.

TYPES: BEGIN OF TY_S_RESULT,
         SEL     TYPE SY-TABIX,
         TOTAL   TYPE SY-TABIX,
         SUCCESS TYPE SY-TABIX,
         ERROR   TYPE SY-TABIX,
         INVALID TYPE ABAP_BOOL,
         Z413    TYPE ABAP_BOOL,
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

DATA GR_SLORD   TYPE REF TO ZGTPP_CL_LIST.
DATA GR_STOCK   TYPE REF TO ZGTPP_CL_LIST.
DATA GR_WKORD   TYPE REF TO ZGTPP_CL_LIST.
DATA GR_CUTTING TYPE REF TO ZGTPP_CL_LIST.
DATA GR_ALLOC   TYPE REF TO ZGTPP_CL_LIST.

DATA GR_TABMT   TYPE REF TO ZGTPP_CL_LIST.

DATA GT_SLORD   TYPE TABLE OF TY_S_SLORD WITH NON-UNIQUE SORTED KEY SKEY1 COMPONENTS VBELN POSNR.
DATA GT_STOCK   TYPE TY_T_STOCK.
DATA GT_WKORD   TYPE TABLE OF TY_S_WKORD WITH NON-UNIQUE SORTED KEY SKEY1 COMPONENTS REF_VBELN REF_POSNR
                                         WITH NON-UNIQUE SORTED KEY SKEY2 COMPONENTS STOCK_GUID.
DATA GT_CUTTING TYPE TABLE OF TY_S_CUTTING.
DATA GT_ALLOC   TYPE TABLE OF TY_S_ALLOC.
DATA GT_FXLEN   TYPE TABLE OF TY_S_FIXED_LEN.

DATA GT_T2420 TYPE TABLE OF TY_S_T2420.
DATA GT_T2430 TYPE TABLE OF TY_S_T2430.

DATA GS_SLORD TYPE TY_S_SLORD.

DATA GT_MATNR TYPE RANGE OF MARA-MATNR.
DATA GT_LINK_DETAIL TYPE TABLE OF ZGTPPS1005.
DATA GT_LINK_STOCK  TYPE TABLE OF ZGTPPS1006.

DATA GT_KLAH  TYPE TABLE OF TY_S_KLAH.
DATA GS_T001W TYPE T001W.
DATA GT_T001L TYPE HASHED TABLE OF T001L WITH UNIQUE KEY WERKS LGORT.
DATA GS_T001L TYPE T001L.
DATA GT_DD07V TYPE TABLE OF DD07V.

DATA GR_CONV TYPE REF TO ZGTPP_CL_CONV.
DATA GR_DATA TYPE REF TO DATA.

DATA GT_ZGTPPT2420 TYPE TABLE OF ZGTPPT2420.
DATA GT_ZGTPPT2430 TYPE TABLE OF ZGTPPT2430.

DATA GS_ZGTPPS1001 TYPE ZGTPPS1001.

DATA: GT_XMSG TYPE TCDAT_MSG_LIST,
      WA_XMSG TYPE TCDAT_MSG.

DATA GV_MSGV LIKE SY-MSGV1.

DATA GV_TABMT TYPE STRING.

DATA GV_XC TYPE ZGTPPT2170-LOEKZ.

DATA GV_STIME TYPE TIMESTAMP.

DATA GS_RESULT  TYPE TY_S_RESULT.
DATA GV_MODE    TYPE CHAR10.
DATA GT_EXCLUDE TYPE UI_FUNCTIONS.
DATA GT_STYLE   TYPE LVC_T_STYL.
DATA GV_SAVED   TYPE ABAP_BOOL.
DATA GV_OKCODE  TYPE SY-UCOMM.
DATA GV_OKCODE2 TYPE SY-UCOMM.
DATA GV_TPAR1   TYPE SYST_MSGV.
DATA GV_TPAR2   TYPE SYST_MSGV.
DATA GV_CUT_ITEM TYPE ZGTPPT2190-ZCUT_ORD_ITEM.
DATA GV_ASS_ITEM TYPE ZGTPPT2190-ZASSIGN_ITEM.

DATA: GV_OBJECT   LIKE AUSP-OBJEK,
      GT_SCLASS   TYPE TABLE OF SCLASS,
      GT_CLOBJDAT TYPE TABLE OF CLOBJDAT.

DATA: BEGIN OF GS_ORG_LEN,
        F_CHARG    TYPE CHARG_D,
        ORG_LENGTH TYPE ZGTEORG_LENGTH,
        DB_CHK(1),
      END OF GS_ORG_LEN.
DATA: GT_ORG_LEN LIKE TABLE OF GS_ORG_LEN.
