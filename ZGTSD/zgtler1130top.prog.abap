*&---------------------------------------------------------------------*
*& Include          ZGTLER1130TOP
*&---------------------------------------------------------------------*



INCLUDE <ICON>.

TYPE-POOLS: SLIS, KKBLO.

TYPE-POOLS VRM.

TABLES : *LFA1, *PA0105, ZLET0106, ZLEV0106, ZLET0107, ZLET0108,
         ZLES042, ZLET0210, ZLET0005, ZLET0007 ,
         ZMMT0152M , ZMMT0139M.


TABLES: LIKP, LIPS,VBAK, VBUK, MARA, TVTKT, /SAPMP/LBA_CUST,
        VTTK, VTTP, VBEP, VBPA,VFKP.

*********************************************************
*            Gloval Table Variance                      *
*********************************************************
*/ GRID1
DATA :  BEGIN OF GT_ALV1 OCCURS 0.
          INCLUDE STRUCTURE LIKP.
DATA :    KUNNR_T     LIKE KNA1-NAME1,   "인도처명
          ORT01(100) ,   "인도처주소1
          STRAS       LIKE KNA1-STRAS,   "인도처주소2
          INCO1_T     LIKE TINCT-BEZEI,  "인도조건명
          KUNAG_T     LIKE KNA1-NAME1,   "판매처명
          LFART_T     LIKE TVLKT-VTEXT,  "납품유형명
          ROUTE_T     LIKE TVROT-BEZEI,  "운송경로명
          VSTEL_T     LIKE TVSTT-VTEXT,  "출하지점명
          VSBED_T     LIKE TVSBT-VTEXT,  "출하조건명
*         TRSTA   LIKE VBUK-TRSTA,   "운송계획상태
          TKNUM       LIKE VTTP-TKNUM,   "선적번호
          TRSTA_YN,                  "운송계획상태 여부 표시
* 해상운송/cy정보/인수자정보/연락처/기타사항
          TKNUM_SEA   LIKE VTTK-TKNUM,
          TEXT1       LIKE VTTK-TEXT1,
          TEXT2       LIKE VTTK-TEXT2,
          TEXT3       LIKE VTTK-TEXT3,
          TEXT4       LIKE VTTK-TEXT4,
*********
          ROUTE2      LIKE VTTK-ROUTE,    "운송경로
          ROUTE_T2    LIKE TVROT-BEZEI,   "운송경로 명
          VGBEL       LIKE LIPS-VGBEL,
          VGPOS       LIKE LIPS-VGPOS,
          VTWEG       LIKE VBAK-VTWEG,
          VKGRP       LIKE VBAK-VKGRP,
          PERNR       LIKE VBPA-PERNR,
          ENAME       LIKE ZZPA0001-ENAME,   "영업사원
          VTWEG_T     LIKE TVTWT-VTEXT,    "유통경로명
          VKGRP_T     LIKE TVGRT-BEZEI,    "영업그룹명
          VKBUR_T     LIKE TVKBT-BEZEI,    "영업팀명
          CITY1       LIKE ZLET0400-CITY1, "납지
          IV_NO       LIKE ZLET0005-IV_NO,
          CARRIER(10),
          GUBUN(10),                   "운송사구분
          STATUS(10),                  "선적생성유
          ZOUT_T(10),
          FLAG,       " ( ' ' =  '미요청, X = '요청완료')
          ICON1(4),
          SEL1,                      "품목조회
          SEL.                       "배차선택

DATA : ALV_COL         TYPE SLIS_T_SPECIALCOL_ALV,
       SEND_STATUS(20),
       SEND_STATUS_L   TYPE ICONNAME,

*-20210126 필드추가 -[s]
       DRIVER_NM       LIKE ZLET0108-DRIVER_NM     , "운전자명
       DRIVER_TELNO    LIKE ZLET0108-DRIVER_TELNO  , "전화번호
       TRUCK_NO        LIKE ZLET0108-TRUCK_NO      , "차량번호
       TDLNR           LIKE ZLET0108-TDLNR         , "운송사
       TRK_TON         TYPE ZLET0105-TRK_TON       , "트럭톤수
*-20210126 필드추가 -[e]

*-[CHM2210-00014]  컨테이너차량 관련 필드추가 -[s]
       CTNR_NO1        LIKE ZLET0108-CTNR_NO1  , "전화번호
       CTNR_NO2        LIKE ZLET0108-CTNR_NO2  , "전화번호
       SEAL_NO1        LIKE ZLET0108-SEAL_NO1,
       SEAL_NO2        LIKE ZLET0108-SEAL_NO2,
       CTNR_WT1        LIKE ZLET0108-CTNR_WT1,
       CTNR_WT2        LIKE ZLET0108-CTNR_WT2,

*-[CHM2210-00014]  컨테이너차량 관련 필드추가 -[e]

*-20210126 필드추가 -[s]
       LOGI_STATUS,
       ORD_NUM         LIKE ZLET0108-ORD_NUM,
       ORD_NUM_OLD     LIKE ZLET0108-ORD_NUM,
*-20210126 필드추가 -[e]
       KDKG4           LIKE VBKD-KDKG4,

       END OF GT_ALV1,

       GS_ALV1 LIKE GT_ALV1.

DATA:  UT_ALV1 LIKE GT_ALV1 OCCURS 0 WITH HEADER LINE.

*/ GRID2
DATA :  BEGIN OF GT_ALV2 OCCURS 0.
          INCLUDE STRUCTURE LIPS.
DATA:     LENGTH         TYPE ATWRT, "LIKE zlet0001-length,
          FACTOR(5)      TYPE P DECIMALS 0, " LIKE zlet0001-factor,
          PACKAG         LIKE MARA-MATNR,      "포장재
          TBRGEW         LIKE MARA-BRGEW,      "총중량
          TVOLUM         LIKE MARA-VOLUM,      "포장부피
          GROES          LIKE MARA-GROES,      "단위포장SIZE
          TNTGEW         LIKE MARA-NTGEW,      "총반입중량[기계]
          ZZCOLOR_BASE   LIKE MARA-ZZCOLOR_BASE,
          ZZCOLOR_STRIPE LIKE MARA-ZZCOLOR_STRIPE,
          CUT_YN(10),
          SEL2,                        "재고조회 연결
* [START] CSR NO : C20080801_08252
          ZWDTY          LIKE VBAP-ZWDTY,
* [END]   CSR NO : C20080801_08252
          ITEM_NO        LIKE LIPS-POSNR,

          OUT_WID        LIKE VTRLK-/BEV1/RPMNGLI, "폭/드럼
          PLAN_DIA       LIKE VTRLK-/BEV1/RPMNGLI, "약경/드럼
          DR_WEIGHT      LIKE MARA-NTGEW,          "드럼무게/개
          BRGEW_DR       LIKE MARA-BRGEW,          "총중량(드럼포함)
          MEINS_MM       LIKE MARA-MEINS,
          MEINS_KG       LIKE MARA-MEINS.
DATA :    ALV_COL TYPE SLIS_T_SPECIALCOL_ALV,
        END OF GT_ALV2,
        GS_ALV2 LIKE GT_ALV2.

DATA: BEGIN OF LT_VTTK OCCURS 0,
        TKNUM LIKE VTTK-TKNUM,
        VBELN LIKE VTTP-VBELN,
        SHTYP LIKE VTTK-SHTYP,
        TEXT1 LIKE VTTK-TEXT1,
        TEXT2 LIKE VTTK-TEXT2,
        TEXT3 LIKE VTTK-TEXT3,
        TEXT4 LIKE VTTK-TEXT4,
        ROUTE LIKE VTTK-ROUTE,
      END OF LT_VTTK.
DATA: LT_VTTK1 LIKE LT_VTTK OCCURS 0 WITH HEADER LINE.

DATA: GT_TAB1 LIKE ZLES013 OCCURS 0 WITH HEADER LINE.

DATA:   BEGIN OF GT_XMESG OCCURS 0.
          INCLUDE STRUCTURE MESG.
DATA:     TKNUM LIKE VTTK-TKNUM,
        END   OF GT_XMESG.

DATA:   BEGIN OF GT_XMESG1 OCCURS 0.
          INCLUDE STRUCTURE MESG.
DATA:     VBELN LIKE LIKP-VBELN,
        END   OF GT_XMESG1.


DATA: G_FIELDCAT_M    TYPE SLIS_T_FIELDCAT_ALV  WITH HEADER LINE.

* 영업팀/영업그룹
DATA: LV_TVKBT LIKE TVKBT OCCURS 0 WITH HEADER LINE,
      LV_TVGRT LIKE TVGRT OCCURS 0 WITH HEADER LINE.


*********************************************************
*            Gloval Variance                      *
*********************************************************
DATA: BEGIN OF WA,
        VBELN         LIKE LIKP-VBELN,
        LDDAT         LIKE SY-DATUM,         "입차요청일
        LDUHR         LIKE SY-UZEIT,         "입차요청시간
*       wadat    like sy-datum,         "출고일
*       wauhr    like sy-uzeit,         "출고시간
        LFDAT         LIKE SY-DATUM,         "도착예정일
        LFUHR         LIKE SY-UZEIT,         "도착예정시간
        TON(10),
*      ton      TYPE p DECIMALS 0,     "톤수제한
*      ton_c(12),                      "톤수제한(CHAR)
        ZTONS         TYPE P DECIMALS 1,     "소요톤수
        ZTEXT         LIKE LIKP-LIFEX,       "추가텍스트
        CARRIER       LIKE ZLET0011-CARRIER, "운송사
        CARRIER_T(30),                  "운송사
        NEMIX(8),                       "혼적불가/가능
        INCO1         LIKE LIKP-INCO1,       "인도조건
        INCO1_T(20),                    "인도조건명
        ANZPK         LIKE LIKP-ANZPK,       "파렛트수
        XABLN         LIKE LIKP-XABLN,       "소요톤수
        TRAID         LIKE LIKP-TRAID,       "운송수단 ID
        ICON1(5),                       "
*       vsbed    like likp-vsbed,       "출하조건
*       trsta    like vbuk-trsta,       "운송계획상태
        ZMSG(100),

* 당사배차
        TPLST         LIKE VTTK-TPLST,        "운송계획지점
        TPLST_T       LIKE TVTKT-BEZEI,
        SHTYP         LIKE VTTK-SHTYP,        "선적유형
        SHTYP_T       LIKE TTDST-BEZEI,
        MSG(80),
      END OF WA.

DATA: OK_CODE    LIKE SY-UCOMM.
DATA: OK_SAVE LIKE SY-UCOMM.
DATA: GV_INDEX   LIKE SY-INDEX.
DATA: GV_INDEX_P   LIKE SY-INDEX.

DATA: GV_CNT     TYPE I.
DATA: GV_FLAG.
DATA: BDC_MODE.
DATA: GV_RETURN.
DATA: GV_ZMSG(200).
DATA: GV_MENGE   LIKE EKPO-MENGE.
DATA: GV_LENGTH  LIKE GT_ALV2-LENGTH.
DATA: GV_TBRGEW   LIKE GT_ALV2-TBRGEW.
DATA: GV_TNTGEW   LIKE GT_ALV2-TNTGEW.
DATA: GV_BRGEW1  LIKE GT_ALV1-BTGEW.
DATA: GV_BRGEW2  LIKE GT_ALV1-BTGEW.
DATA: GV_TVOLUM  LIKE GT_ALV2-TVOLUM.
RANGES: R_SPG   FOR LIKP-VSTEL.
RANGES: R_VBELN FOR LIKP-VBELN.

*-- FLAG
DATA :  GF_REQUEST.  "배송요청

DATA : GV_TKNUM_MULTI LIKE VTTK-TKNUM.
DATA : GV_TITLE10(100).

***********************************************************
* POV DATA SET
***********************************************************
DATA : BEGIN OF FIELDTAB OCCURS 2.
         INCLUDE STRUCTURE HELP_VALUE.
DATA : END OF FIELDTAB.

DATA : BEGIN OF I_HELP_VTAB OCCURS 0.
         INCLUDE STRUCTURE  HELP_VTAB.
DATA : END OF I_HELP_VTAB.
DATA : BEGIN OF  VALUETAB OCCURS 0,
         VALUE LIKE HELP_VTAB-VALUE,
       END OF  VALUETAB.
DATA: J TYPE I.

DATA: LT_VALI LIKE API_VALI   OCCURS 0 WITH HEADER LINE,
      LT_ATTR LIKE API_CH_ATT OCCURS 0 WITH HEADER LINE.

DATA : GT_HEADER_SEL LIKE TABLE OF GT_ALV1 WITH HEADER LINE,
       GT_ITEM_SEL   LIKE TABLE OF GT_ALV2 WITH HEADER LINE,

       BEGIN OF GT_ALV3 OCCURS 0,
         LOGI_STATUS   TYPE ICONNAME,   "전송상태
         STATUS(10) , "합짐/분할표시
         POSNR_CHK,   "오더 공통내역 표시
         VBELN         LIKE GT_ALV1-VBELN,
         POSNR         LIKE GT_ALV2-POSNR,
         KUNNR         LIKE GT_ALV1-KUNNR,    "납품처
         KUNNR_T       LIKE GT_ALV1-KUNNR_T,  "납품처명
         ORT01(100),
         STRAS         LIKE GT_ALV1-STRAS,    "인도처주소 2
         KUNAG         LIKE GT_ALV1-KUNAG,
         KUNAG_T       LIKE KNA1-NAME1,   "판매처명
         DATLT         LIKE KNA1-DATLT,       "담당자명
         TELF1         LIKE KNA1-TELF1,       "담당자전화번호
         TELF2         LIKE KNA1-TELF2,       "담당자휴대폰번호
         MATNR         LIKE MARA-MATNR,
         ARKTX         LIKE GT_ALV2-ARKTX,
         LFIMG         LIKE GT_ALV2-LFIMG,
         VRKME         LIKE GT_ALV2-VRKME,
         TBRGEW        TYPE P LENGTH 10,
         TVOLUM        LIKE GT_ALV2-TVOLUM,
         GROES         LIKE GT_ALV2-GROES,
         WADAT         LIKE GT_ALV1-WADAT,   "출고예정일
         WAUHR         LIKE GT_ALV1-WAUHR,   "출고시간
         DAY_CHK,  "당일배송
         TRK_TON       TYPE ZTRKTON,   "트럭톤수차종
         TRK_TON_T(30),   "트럭톤수차종
         GEWEI         LIKE MARA-GEWEI,
         NO_CAR(3)     TYPE N,
         ADDRESS(30),
         ADD_LINE_CHK,
         TIMELINE      TYPE ZLET0105-TIMELINE,
         MAP_CANC      TYPE ZLET0105-MAP_CANC,
         NOTE          TYPE ZLET0105-NOTE,
         VBELN_PT      LIKE GT_ALV1-VBELN,
         ATTACH_KEY    TYPE ZLET0105-ATTACH_KEY,
         ATTACH_ICON   TYPE ICONNAME,
         ORD_NUM       LIKE ZLET0108-ORD_NUM,

         ZROUTE        LIKE ZLET0211-ZROUTE,   "운송경로
         ZDEPARTURE    LIKE ZLET0211-ZDEPARTURE , "출발지
         ZDEPARTURET   LIKE ZLET0210-ZDEPARTURET,
         ZARRIVAL      LIKE ZLET0211-ZARRIVAL   ,  "도착지
         ZARRIVALT     LIKE ZLET0210-ZARRIVALT,
         PRICE         LIKE ZLET0210-PRICE,    "금액
         WAERS         LIKE ZLET0210-WAERS,    "통화
         WERKS         LIKE GT_ALV2-WERKS,
         IV_NO         TYPE ZLET0105-IV_NO,   "통문번호
         DRIVER_NM     LIKE ZLET0108-DRIVER_NM     , "운전자명
         DRIVER_TELNO  LIKE ZLET0108-DRIVER_TELNO  , "전화번호
         TRUCK_NO      LIKE ZLET0108-TRUCK_NO      , "차량번호
         ROW_INDEX     LIKE SY-INDEX,
         CELLTAB       TYPE LVC_T_STYL,
       END OF GT_ALV3 ,

       GT_ALV3_SEL LIKE TABLE OF GT_ALV3 WITH HEADER LINE,

       GT_ALV4     LIKE TABLE OF GT_ALV3 WITH HEADER LINE,
       GT_ALV4_SEL LIKE TABLE OF GT_ALV3 WITH HEADER LINE,

       BEGIN OF GT_0005 OCCURS 0,
         IV_NO       LIKE    ZLET0005-IV_NO,
         BZAREA      LIKE    ZLET0005-BZAREA,
         WERKS       LIKE    ZLET0005-WERKS,

         CREATE_DATE LIKE    ZLET0005-CREATE_DATE , "생성일
         PERNR       LIKE    ZLET0005-PERNR,
         ENAME       LIKE    PA0001-ENAME      , "사원명
         KUNNR       LIKE    ZLET0005-KUNNR    , "구매처
         NAME        LIKE    KNA1-NAME1        , " 구매처명
         KUNNR1      LIKE    ZLET0005-KUNNR1   , "납품처
         NAME1       LIKE    KNA1-NAME1        , "납품처명
         KUNNR2      LIKE    ZLET0005-KUNNR2   , "수기고객명
         MAP_CHK               , "기매핑여부
       END OF GT_0005,


       GT_EXCL     LIKE TABLE OF SY-UCOMM WITH HEADER LINE,
       GT_EXCL2    LIKE TABLE OF SY-UCOMM WITH HEADER LINE,
       GT_EXCL3    LIKE TABLE OF SY-UCOMM WITH HEADER LINE,
       GT_EXCL4    LIKE TABLE OF SY-UCOMM WITH HEADER LINE,

       GT_APPROVAL LIKE STANDARD TABLE OF ZMMS0319
                   INITIAL SIZE 0,
       GS_APPROVAL LIKE ZMMS0319.

DATA : GT_0105 TYPE TABLE OF ZLET0105 WITH HEADER LINE.

*- 전송 문자
DATA : BEGIN OF GT_SMS OCCURS 0,
         KEY(100), "출고예정일 + 주소
         ADDRESS(30),
         TRK_TON_T(30),   "트럭톤수차종
         WADAT         LIKE GT_ALV1-WADAT,   "출고예정일
         WAUHR         LIKE GT_ALV1-WAUHR,   "출고시간
         DAY_CHK,
         NO_CAR        TYPE I,
       END OF GT_SMS,

       BEGIN OF GT_SMS_1 OCCURS 0,
         KEY(100), "출고예정일 + 주소
         TRK_TON_T(100),   "트럭톤수차종
         NO_CAR         TYPE I,
         CONTENT(100),
       END OF GT_SMS_1.

*-재고조회
DATA: BEGIN OF GT_STOCK OCCURS 0,
        WERKS      LIKE T001W-WERKS,
        WERKS_TX   LIKE T001W-NAME1,
        LGORT      LIKE T001L-LGORT,
        LGORT_TX   LIKE T001L-LGOBE,
        KUNNR      LIKE VBAK-KUNNR,
        KUNNR_TX   LIKE ADRC-NAME1,
        VBELN      LIKE VBAP-VBELN,
        POSNR      LIKE VBAP-POSNR,
        MATNR      LIKE VBAP-MATNR,
        MATNR_TX   LIKE MAKT-MAKTX,
        MENGE      LIKE MCHB-CLABS,
        LENGTH     LIKE ZLET0401-INDLEN,     "조장
        FACTOR     LIKE ZLET0401-INDQTY,     "조장수
        MEINS      LIKE MARA-MEINS,
        DESC(10),                      "재고상태
        INDMEI     LIKE MARA-MEINS,          "조장수 단위
        ZSORT(1),
      END OF GT_STOCK.

*- 전송 메일메시지

DATA: GV_PERNR_SH         LIKE PA0001-PERNR,  "하차담당자
      GV_PERNR_SH_T(100),
      GV_PERNR_SH_T1(100),
      GV_TDLNR_SH         LIKE VTTK-TDLNR,
      GV_TDLNR_SH_T(100),
      GT_ROWS             TYPE LVC_T_ROW WITH HEADER LINE,
      GV_CHK,
      GV_ANSWER.



*- 메시지전송 관련
DATA : GV_MOBILE      TYPE ZLET0105-MOBILE,
       GV_CALLBACK    TYPE  ZLET0105-CALLBACK,
       GV_CONTENT     TYPE  ZCHAR400,
       GV_CONTENT_CLT TYPE  ZCHAR400,
       GV_ZERET(2),
       GV_ZEMSG(100),
       GV_TOKEN       TYPE STRING,
       GV_DEST        TYPE ZIFDEST-DEST,
       GV_STATUS(2) ,
       GS_BOBJ        TYPE SIBFLPORB.

*- ETC
DATA: GV_TIMELINE     TYPE ZLET0105-TIMELINE,
      GV_TRK_TONT(30),
      GV_PERNR_PG     LIKE PA0001-PERNR,
      GV_ENAME_PG     LIKE PA0001-ENAME.

*- Dropdonw List
DATA : BEGIN OF F4_TAB OCCURS 0,
         FVAL LIKE DD07T-DOMVALUE_L,
         FNAM LIKE DD07T-DDTEXT,
       END OF F4_TAB.


*- 송.수신,참조자 이름. 메일, 문자 정보
DATA : GS_SENDER   LIKE ZLET0106,
       GS_RECEIVER LIKE ZLET0107.

*-- 매핑화면
DATA : GV_SCHK1,
       GV_SCHK2,
       GV_SCHK3,
       GV_SDATE LIKE SY-DATUM.

*-- FLAG
DATA : GF_MAPPING,   "MAPPING
       GF_EDIT,
       GF_ALV_FIRST,
       GF_CALL_FIRST,
       GF_CALL_FIRST_1,
       GF_MAIL_FIRST,
       GF_EXIST,
       GF_NEW,
       GF_MIX_CHG,
       GF_LOGI_ERR,
       GF_ZROUTE_F4,
       GF_ZDEPARTURE_F4,
       GF_ZARRIVAL_F4,
       GF_TRK_TON_F4,
       GF_NREQUEST,
       GF_ZGATING,
       GF_APPRQ,
       GF_ZROUTE,
       GF_SPOT.

* Smartforms Options
DATA: GS_CONTROL_PARAMETERS TYPE SSFCTRLOP,
      GS_OUTPUT_OPTIONS     TYPE SSFCOMPOP.

**------------------------------------------------------
** E-Mail Send 관련
**------------------------------------------------------
DATA: G_EMAIL        TYPE REF TO CL_BCS,
      G_EMAIL_BODY   TYPE REF TO CL_DOCUMENT_BCS,
      G_RECEIVER     TYPE REF TO IF_RECIPIENT_BCS,
      G_SENDER       TYPE REF TO IF_SENDER_BCS,
      GV_ADDRESS     TYPE AD_SMTPADR,
      GV_ADDRESS_MNG TYPE AD_SMTPADR,
      GV_SENDER      LIKE USR02-BNAME,  "발신인
      GV_SEND_RESULT TYPE C,
      G_EXCEPTION    TYPE REF TO CX_BCS,
      GT_BODY        TYPE  BCSY_TEXT,
      GT_EMAIL       TYPE SOMLRECI1 OCCURS 0 WITH HEADER LINE,
      GV_LINE(255) ,
      GV_SUBJECT     TYPE SO_OBJ_DES.

*- CONSTANTS
CONSTANTS :
*            GC_X      VALUE 'X',
*            GC_A      VALUE 'A',
*            GC_C      VALUE 'C',
*            GC_D      VALUE 'D',
*            GC_S      VALUE 'S',
*            GC_I      VALUE 'I',
*            GC_P      VALUE 'P',
            GC_KRW(3) VALUE 'KRW'.

*- ETC
DATA : GV_SCREEN_FILED(30),
       GV_TITLE(100),
       GV_POSNR            LIKE LIPS-POSNR,
       GV_ATTACH_KEY       TYPE ZLET0105-ATTACH_KEY,  "첨부파일키
       GV_ATTACH_CNT       TYPE I.

DATA: G_OBJCONT1 TYPE SOLI_TAB .

DATA: ST_ATTACH_KEY TYPE SMP_DYNTXT .

* Macro Variables
DATA: GV_DOMNAME  LIKE DD07L-DOMNAME,
      GV_VALUE    LIKE DD07L-DOMVALUE_L,
      GS_DD07V_WA LIKE DD07V.

FIELD-SYMBOLS : <FS> TYPE ANY.

*/ LONG TEXT - SE75
DATA: GT_TLINE LIKE TLINE OCCURS 0 WITH HEADER LINE.
*DATA: gv_vbeln LIKE thead-tdname.
DATA: GV_OBJECT_ID(4).
DATA: GV_OBJECT(10).

*/ 제품특성
DATA: GT_CHAR  LIKE ZLES001  OCCURS 0 WITH HEADER LINE.
DATA: GT_CHAR1 LIKE CONF_OUT OCCURS 0 WITH HEADER LINE.

CONSTANTS:
* SALES ORDER
  SO_LENGTH(30)          VALUE 'SAP_LENGTH_VKRME',     "조장
  SO_FACTOR(30)          VALUE 'SAP_MILLCA_FACTOR',   "조장수 "사용안함
  SO_PACKAGING(30)       VALUE 'SAP_MILLCA_PACKAGING', "포장재 코드
  SO_PACKAGING_CAT(30)   VALUE 'SAP_MILLCA_PACKAGING_CAT', "포장재 유형
  SO_COLOR(30)           VALUE 'PD_CA_COLOR_BASE',     "색상(BASE)
  SO_COLOR_STRIPE(30)    VALUE 'PD_CA_COLOR_STRIPE',   "색상(STRIPE)
  SO_GRADE(30)           VALUE 'ZBT_AA_GRADE',         "등급

* BATCH
  BA_LENGTH(30)          VALUE 'SAP_MILLCA_LENGTH',    "조장
  BA_ALLENGTH(30)        VALUE 'BT_AL_LENGTH',         "절단길이
  BA_FACTOR(30)          VALUE 'SAP_MILLCA_FACTOR',    "조장수
  BA_PACKAGING(30)       VALUE 'SAP_MILLCA_PACKAGING', "포장재 코드
  BA_PACKAGING_CAT(30)   VALUE 'SAP_MILLCA_PACKAGING_CAT', "포장재 유형
  BA_COLOR(30)           VALUE 'PD_CA_COLOR_BASE',     "색상
  BA_COLOR_STRIPE(30)    VALUE 'PD_CA_COLOR_STRIPE',   "색상(STRIPE)

  BA_IDEN_CODE(30)       VALUE 'PD_CA_INS_IDEN_CODE', "절연선심식별색상코드

*___전사프로세스 개선_Start 2010.02.23 by SDC24
  BA_BT_AA_GRADE(30)     VALUE 'BT_AA_GRADE',     "SCR 품질등급
  BA_PD_CF_GRADE(30)     VALUE 'PD_CF_GRADE',     "동박제품등급
  BA_PD_CF_GRADE1(30)    VALUE 'PD_CF_GRADE1',  "동박제품등급(08년7월~)
  BA_BT_CX_GRADE(30)     VALUE 'BT_CX_GRADE',       "동축 품질등급
  BA_BT_OF_Q_GRADE(30)   VALUE 'BT_OF_Q_GRADE',     "광섬유 품질등급
  BA_PD_TB_PRINT_APP(30) VALUE 'PD_TB_PRINT_APP',   "튜브 인쇄사양
*___전사프로세스 개선_End   2010.02.23 by SDC24

*{ 자체개선 53028 - 추가
  BA_EG_NO(30)           VALUE 'PD_AM_EG_NO',       "엔진번호
  BA_TM_NO(30)           VALUE 'PD_AM_TM_NO',       "TM번호
  BA_CHASSIS_NO(30)      VALUE 'PD_AM_CHASSIS_NO',  "샤시번호
*} 자체개선 53028 - 추가

*( 기능개선 60400 - 추가
  BA_PD_CA_STATUS(30)    VALUE 'PD_CA_PACKMARK_STATUS'. "포장재상태

*) 기능개선 60400



*/ PARTNER FUNCTION
CONSTANTS: GC_PAR_SP(2) VALUE 'AG',  "판매처
           GC_PAR_BP(2) VALUE 'RE',  "청구처
           GC_PAR_PY(2) VALUE 'RG',  "지급처
           GC_PAR_PE(2) VALUE 'VE',  "영업사원
           GC_PAR_SH(2) VALUE 'WE'.  "납품처

CONSTANTS: GC_VKORG_6000 TYPE VKORG      VALUE '6000',
           GC_LIFSK_G3   TYPE LIKP-LIFSK VALUE 'G3',
           GC_LGORT_3410 TYPE LGORT_D    VALUE '3410',
           GC_LGORT_3420 TYPE LGORT_D    VALUE '3420',
           GC_LGORT_3499 TYPE LGORT_D    VALUE '3499',
           GC_MEINS_KG   TYPE MEINS      VALUE 'KG',
           GC_MEINS_MM   TYPE MEINS      VALUE 'MM'.


RANGES: GR_LGORT FOR T001L-LGORT.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS:
  GC_A TYPE C VALUE 'A',
  GC_B TYPE C VALUE 'B',
  GC_C TYPE C VALUE 'C',
  GC_D TYPE C VALUE 'D',
  GC_E TYPE C VALUE 'E',
  GC_F TYPE C VALUE 'F',
  GC_G TYPE C VALUE 'G',
  GC_H TYPE C VALUE 'H',
  GC_I TYPE C VALUE 'I',
  GC_J TYPE C VALUE 'J',
  GC_K TYPE C VALUE 'K',
  GC_L TYPE C VALUE 'L',
  GC_M TYPE C VALUE 'M',
  GC_N TYPE C VALUE 'N',
  GC_O TYPE C VALUE 'O',
  GC_P TYPE C VALUE 'P',
  GC_Q TYPE C VALUE 'Q',
  GC_R TYPE C VALUE 'R',
  GC_S TYPE C VALUE 'S',
  GC_T TYPE C VALUE 'T',
  GC_U TYPE C VALUE 'U',
  GC_V TYPE C VALUE 'V',
  GC_W TYPE C VALUE 'W',
  GC_X TYPE C VALUE 'X',
  GC_Y TYPE C VALUE 'Y',
  GC_Z TYPE C VALUE 'Z',
  GC_0 TYPE C VALUE '0',
  GC_1 TYPE C VALUE '1',
  GC_2 TYPE C VALUE '2',
  GC_3 TYPE C VALUE '3',
  GC_4 TYPE C VALUE '4',
  GC_5 TYPE C VALUE '5',
  GC_6 TYPE C VALUE '6',
  GC_7 TYPE C VALUE '7',
  GC_8 TYPE C VALUE '8',
  GC_9 TYPE C VALUE '9'.


*&---------------------------------------------------------------------*
* MACRO
*&---------------------------------------------------------------------*
* 레인지 정보 셋팅용
DEFINE %%RA_ITAB_EQ.
  IF &4 IS NOT INITIAL .
    &1-SIGN   = &2.
    &1-OPTION = &3.
    &1-LOW    = &4.
    &1-HIGH   = &5.
    APPEND &1.
    CLEAR: &1.
  ENDIF.
END-OF-DEFINITION.


DEFINE DOMAIN_TEXT.
  CLEAR: GV_DOMNAME,   GV_VALUE,   GS_DD07V_WA.
  GV_DOMNAME = &1.
  GV_VALUE   = &2.
  CALL FUNCTION 'DD_DOMVALUE_TEXT_GET'
    EXPORTING
      DOMNAME  = GV_DOMNAME
      VALUE    = GV_VALUE
    IMPORTING
      DD07V_WA = GS_DD07V_WA.
  &3 = GS_DD07V_WA-DDTEXT.
END-OF-DEFINITION.
