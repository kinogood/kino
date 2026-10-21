*&---------------------------------------------------------------------*
*&  Include           ZLER0056TOP                                      *
*&---------------------------------------------------------------------*

*-----------------------------------------------------------------------
*-- Tables
*-----------------------------------------------------------------------
TABLES : SSCRFIELDS,
         LIPS,     "SD 문서: 납품: 품목데이타
         LIKP,     "SD 문서: 납품 헤더데이타
         VBAK,     "영업문서: 헤더데이타
         VBUK,     "영업문서: 헤더상태와 관리데이타
         VBUP,     "영업문서: 품목상태
         VTTK,     "선적헤더
         VTTP,     "운송품목
         KNA1,     "고객마스터의 일반데이타
         USR21,    "사용자이름 주소키 지정
         ADRP,     "사원 (근무처주소서비스)
         T001W,    "플랜트/분기
         MCH1,     "Batch (플랜트간 Batch 관리일 경우)
         LFA1,     "구매처마스터 (일반섹션)
         EKPO,     "구매문서품목
         T001L,
         ZLET0005, "[LE] 통문 헤더
         ZLET0006, "[LE] 통문 Line Item
         ZLET0033,
         ZLET0034,
         ZGTPPT1010,
         ZGTSDT0066,
         VBKD.     "영업문서: 비지니스데이타

*-----------------------------------------------------------------------
*-- Include
*-----------------------------------------------------------------------
INCLUDE <ICON>.

*-----------------------------------------------------------------------
*-- Types
*-----------------------------------------------------------------------
TYPE-POOLS: SLIS, KKBLO, ICON.

TYPES  : BEGIN OF GTY_LIST,
           KUNNR     TYPE KUNWE,                " 납품처
           WADAT_IST TYPE WADAT_IST,            " 실제 출고일
           ROUTE     TYPE ROUTE,                " 운송 경로
           LFART     TYPE LFART,                " 납품유형
           VSART     TYPE VSARTTR,              " 출하 유형
           VBTYP     TYPE VBTYPL,               " 문서 범주
           VSTEL     TYPE VSTEL,                " 출하 지점
           KUNAG     TYPE KUNAG,                " 판매처
           VBELN     TYPE VBELN_VL,             " 납품문서
           POSNR     TYPE POSNR_VL,             " 납품품목
           WERKS     TYPE WERKS_D,              " 플랜트
           MATNR     TYPE MATNR,                " 자재코드
           ARKTX     TYPE ARKTX,                " 품목내역
           LFIMG     TYPE LFIMG,                " 판매수량
           VRKME     TYPE VRKME,                " 판매단위
           CHARG     TYPE CHARG_D,              " 배치번호
           MEINS     TYPE MEINS,                " 단위
           VGBEL     TYPE VGBEL,                " 참조문서 - 판매문서
           VGPOS     TYPE VGPOS,                " 참조문서 품목 - 판매문서
           UMVKZ     TYPE UMVKZ,                " SKU 환산 분자
           UMVKN     TYPE UMVKN,                " SKU 환산 분모
           VKBUR     TYPE VKBUR,                " 영업팀
           VKGRP     TYPE VKGRP,                " 영업 그룹
           VTWEG     TYPE VTWEG,                " 유통 경로

           TKNUM     TYPE TKNUM,                " 선적번호
           EXTI2     TYPE EXTI2,                " 외부 ID 2
           EXTI1     TYPE EXTI1,                " 외부 ID 1
           TPBEZ     TYPE TPBEZ,                " 선적 내역
           SHTYP     TYPE SHTYP,                " 선적 유형
           TDLNR     TYPE TDLNR,                " 운송중개인 번호
           SDABW     TYPE SDABW,                " 특별 처리 지시자

           IV_NO     TYPE CHAR10,               " 거래명세서 번호
           IV_DATE   TYPE DATS,                 " 거래명세서 발행일자
         END OF GTY_LIST,

         GTY_T_LIST TYPE TABLE OF GTY_LIST WITH EMPTY KEY.

*-----------------------------------------------------------------------
*-- Data
*-----------------------------------------------------------------------
*/ LONG TEXT - SE75
DATA : GT_TLINE LIKE TLINE OCCURS 0 WITH HEADER LINE.

DATA : GV_OBJECT_ID(4),
       GV_OBJECT(10),
       GV_EXIT TYPE C.

*/ 제품특성
*{ 자체개선 44157 - 추가
DATA: GT_CHAR1 LIKE CONF_OUT    OCCURS 0 WITH HEADER LINE.
*} 자체개선 44157 - 추가

**/ BDC
DATA : GT_BDCDATA LIKE BDCDATA  OCCURS 0 WITH HEADER LINE.

DATA : GV_SAVEVIEW TYPE C,
       GV_VALID    TYPE C,
       GT_ROW_NO   TYPE LVC_T_ROID WITH HEADER LINE.

*DATA: BEGIN OF gt_list OCCURS 0,
*        icon             LIKE icon-internal,
*        iv_no            LIKE  zlet0005-iv_no,
*        vkbur            LIKE  lips-vkbur,      "영업팀
*        vkgrp            LIKE  lips-vkgrp,      "영업그룹
*        kunnr            LIKE likp-kunnr,       "납품처
*        kunnr_t          LIKE kna1-name1,   "남품처명
*        kunag            LIKE  likp-kunag,      "판매처
*        kunag_t          LIKE kna1-name1,    "판매처명
*        vbeln            LIKE  lips-vbeln,      "납품번호
*        posnr            LIKE  lips-posnr,      "납품품목
*        tknum            LIKE  vttk-tknum,       "선적번호
*        vsart            LIKE  likp-vsart,       "출하유형
*        vbtyp            LIKE  likp-vbtyp,       "SD 문서범주
*        vstel            LIKE  likp-vstel,       "출하지점
*        lfart            LIKE  likp-lfart,       "납품유형
**       vkbur    LIKE  lips-vkbur,      "영업팀
**       vkgrp    LIKE  lips-vkgrp,      "영업그룹
*        vtweg            LIKE  lips-vtweg,      "유통경로
*        wadat_ist        LIKE  likp-wadat,    "출고일자
*        vgbel            LIKE  lips-vgbel,       "주문번호
*        vgpos            LIKE  lips-vgpos,       "품목
*        werks            LIKE  lips-werks,
*        matnr            LIKE  lips-matnr,       "자재
*        arktx            LIKE  lips-arktx,       "자재내역
*        charg            LIKE  lips-charg,       "배치
*        lfimg            LIKE  lips-lfimg,       "납품수량
*        vrkme            LIKE  lips-vrkme,       "단위
*        meins            LIKE  lips-meins,       "기본단위
*        umvkz            LIKE  lips-umvkz,
*        umvkn            LIKE  lips-umvkn,
*        empst            LIKE  vbkd-empst,       "드럼 by song
*        iv_type          LIKE  zlet0005-iv_type, "통문유형
*        iv_type_nm(40),                 "통문유형명
*        iv_date          LIKE  zlet0005-iv_date, "통문증발행일자
*        length           TYPE p DECIMALS 3,
*        length_so        TYPE p DECIMALS 3,
**       charg_cnt  TYPE i,
*        exti2            LIKE  vttk-exti2,       "운전자명
*        exti1            LIKE  vttk-exti1,       "차량번호
*        sdabw            LIKE  vttk-sdabw,       "운임톤수
*        tdlnr            LIKE  vttk-tdlnr,       "운송사
*        tdlnr_t          LIKE  lfa1-name1,       "운송사
*        tpbez            LIKE  kna1-name1,       "운송기사전화번호
**       prdid(30),     "제품군(G)
**       prod(30),    "견적품명(G/P)
**       volt(30),      "전압(G)
**       wire(30),      "상(G/P)
**       gnd(30),      "접지구분(G)
**       amp(30),     "전류세기(G)
**       cond(30),     "도체재질(G)
**       duct(30),      "덕트재질(G)
**       ipdeg(30),    "IP등급(G)
**       pole(30),    "극수(P)
**       brea(30),     "차단기모델(P)
**       frame(30),     "프레임용(P)
**       trip(30),       "트립용량(P)
*        prdid(30),     "제품구분(D)
*        prod(30),      "견적품명코드(A/B/C/D)
*        prod_cd(30),   "견적품명(A/B/C/D)
*        volt(30),      "전압(D)
*        wire(30),      "상(C/D)
*        wire_desc(30), "상(C/D)명
*        gnd(30),       "접지구분(D)
*        amp(30),       "전류세기()
*        cond(30),      "도체재질(D)
*        duct(30),      "덕트재질(D)
*        ipdeg(30),     "IP등급(D)
*        pole(30),      "극수(A/B)
*        brea(30),      "차단기모델(A/B)
*        frame(30),     "프레임용(A/B)
*        trip(30),       "트립용량(A/B)
*        ipdeg_name(30), "IP등급(D)  PD_BD_IP_GRADE(desc)
*        frame_sub(30),"서브프레임용량(B) PD_BD_AMPHERE_FRAME_SUB(desc)
*        pole_sub(30), "서브차단기극수(B) PD_BD_POLE_CNT_SUB(desc)
*        brea_sub(30), "서브차단기모델(B) PD_BD_BREAKER_MODEL_SUB(desc)
*        trip_sub(30), "서브트립용량(B)   PD_BD_AMPHERE_TRIP_SUB(desc)
*        circuit(30),  "회로수(B)         PD_BD_CIRCUIT_CNT(desc)
*        circuit_per(30),"회로당차단기수(B) PD_BD_CIRCUIT_PER_MCCB(desc)
*        wire_type(30), "N상구분(C/D)       PD_BD_N_WIRE_TYPE
*        wire_combine(30),"선식(C/D)      WIRE+WIRE_COMBINE
*        gp_flag,       "General/PH_BOX 구분
*        diff,
*        chk,
*      END OF gt_list.

*-- 견적품 연결 정보 추가 Internal Table 구성
DATA: BEGIN OF GT_QLIST OCCURS 0,
        ICON             LIKE ICON-INTERNAL,

        IV_NO            LIKE ZLET0005-IV_NO,
        VKBUR            LIKE LIPS-VKBUR,                 "영업팀
        VKGRP            LIKE LIPS-VKGRP,                 "영업그룹
        KUNNR            LIKE LIKP-KUNNR,                 "납품처
        KUNNR_T          LIKE KNA1-NAME1,                 "남품처명
        KUNAG            LIKE LIKP-KUNAG,                 "판매처
        KUNAG_T          LIKE KNA1-NAME1,                 "판매처명
        VBELN            LIKE LIPS-VBELN,                 "납품번호
        POSNR            LIKE LIPS-POSNR,                 "납품품목
        TKNUM            LIKE VTTK-TKNUM,                 "선적번호
        VSART            LIKE LIKP-VSART,                 "출하유형
        VBTYP            LIKE LIKP-VBTYP,                 "SD 문서범주
        VSTEL            LIKE LIKP-VSTEL,                 "출하지점
        LFART            LIKE LIKP-LFART,                 "납품유형
        VTWEG            LIKE LIPS-VTWEG,                 "유통경로
        WADAT_IST        LIKE LIKP-WADAT,                 "출고일자

*-- 견적품 정보 추가 필드 Start
        PROD_CD          LIKE ZGTSDT0066-QCODE,           " 견적품코드
        PROD             LIKE ZGTSDT0066-QNAME,           " 견적품명
        QQTY             LIKE ZGTSDT0066-QQTY,            " 견적품 물량
        QUNIT            LIKE ZGTSDT0066-QUNIT,           " 견적품 단위
        QNAME_PRNT       LIKE ZGTSDT0066-QNAME_PRNT,      " 견적품 출력명
*-- 견적품 정보 추가 필드 End

        VGBEL            LIKE LIPS-VGBEL,                 "주문번호
        VGPOS            LIKE LIPS-VGPOS,                 "품목
        WERKS            LIKE LIPS-WERKS,
        MATNR            LIKE LIPS-MATNR,                 "자재
        ARKTX            LIKE LIPS-ARKTX,                 "자재내역
        CHARG            LIKE LIPS-CHARG,                 "배치
        LFIMG            LIKE LIPS-LFIMG,                 "납품수량
        VRKME            LIKE LIPS-VRKME,                 "단위
        MEINS            LIKE LIPS-MEINS,                 "기본단위
        UMVKZ            LIKE LIPS-UMVKZ,
        UMVKN            LIKE LIPS-UMVKN,
        EMPST            LIKE VBKD-EMPST,                 "드럼 by song
        IV_TYPE          LIKE ZLET0005-IV_TYPE,           "통문유형
        IV_TYPE_NM(40),                                   "통문유형명
        IV_DATE          LIKE ZLET0005-IV_DATE,           "통문증발행일자

        LENGTH           TYPE P DECIMALS 3,
        LENGTH_SO        TYPE P DECIMALS 3,

        EXTI2            LIKE VTTK-EXTI2,                 "운전자명
        EXTI1            LIKE VTTK-EXTI1,                 "차량번호
        SDABW            LIKE VTTK-SDABW,                 "운임톤수
        TDLNR            LIKE VTTK-TDLNR,                 "운송사
        TDLNR_T          LIKE LFA1-NAME1,                 "운송사
        TPBEZ            LIKE KNA1-NAME1,                 "운송기사전화번호

        PRDID(30),        "제품구분(D)
*        prod(30),         "견적품명코드(A/B/C/D)
*        prod_cd(30),      "견적품명(A/B/C/D)
        VOLT(30),         "전압(D)
        WIRE(30),         "상(C/D)
        WIRE_DESC(30),    "상(C/D)명
        GND(30),          "접지구분(D)
        AMP(30),          "전류세기()
        COND(30),         "도체재질(D)
        DUCT(30),         "덕트재질(D)
        IPDEG(30),        "IP등급(D)
        POLE(30),         "극수(A/B)
        BREA(30),         "차단기모델(A/B)
        FRAME(30),        "프레임용(A/B)
        TRIP(30),         "트립용량(A/B)
        IPDEG_NAME(30),   "IP등급(D)  PD_BD_IP_GRADE(desc)
        FRAME_SUB(30),    "서브프레임용량(B) PD_BD_AMPHERE_FRAME_SUB(desc)
        POLE_SUB(30),     "서브차단기극수(B) PD_BD_POLE_CNT_SUB(desc)
        BREA_SUB(30),     "서브차단기모델(B) PD_BD_BREAKER_MODEL_SUB(desc)
        TRIP_SUB(30),     "서브트립용량(B)   PD_BD_AMPHERE_TRIP_SUB(desc)
        CIRCUIT(30),      "회로수(B)         PD_BD_CIRCUIT_CNT(desc)
        CIRCUIT_PER(30),  "회로당차단기수(B) PD_BD_CIRCUIT_PER_MCCB(desc)
        WIRE_TYPE(30),    "N상구분(C/D)       PD_BD_N_WIRE_TYPE
        WIRE_COMBINE(30), "선식(C/D)      WIRE+WIRE_COMBINE
        GP_FLAG,          "General/PH_BOX 구분
        DIFF,
        CHK,
      END OF GT_QLIST.

DATA : BEGIN OF  GT_CLASS OCCURS 0,
         OBJEK LIKE KSSK-OBJEK,
         CLASS LIKE KLAH-CLASS,
       END OF GT_CLASS.

DATA: GT_PRNT LIKE GT_QLIST OCCURS 0 WITH HEADER LINE.
DATA: GT_ITEM LIKE GT_QLIST OCCURS 0 WITH HEADER LINE.

DATA: IZLET0005 LIKE ZLET0005 OCCURS 0 WITH HEADER LINE.
DATA: IZLET0006 LIKE ZLET0006 OCCURS 0 WITH HEADER LINE.

DATA: GT_RPRT   LIKE GT_QLIST OCCURS 0 WITH HEADER LINE.


DATA: BEGIN OF GT_BZAREA OCCURS 0,
        BZAREA LIKE ZPBT0018-BZAREA,
        VSTEL  LIKE ZPBT0018-VSTEL,
      END OF GT_BZAREA.

DATA: BEGIN OF WA,
        DRIVER_NM    LIKE ZLET0005-DRIVER_NM,
        TRUCK_NO     LIKE ZLET0005-TRUCK_NO,
        DRIVER_TELNO LIKE ZLET0005-DRIVER_TELNO,
        PRINT_CNT    LIKE ZLET0005-PRINT_CNT,
      END OF WA.

DATA: GV_LIN   TYPE I.
DATA: I_CURSOR_LINE      TYPE I,
      G_CURSOR_FIELD(20).
DATA: GV_FLAG.
DATA: GV_IV_NO  LIKE ZLET0005-IV_NO.
DATA: GV_DRIVER LIKE VTTK-EXTI2,
      GV_TELNO  LIKE VTTK-TPBEZ.
DATA: GV_RETURN.
DATA: GV_MENGE   LIKE EKPO-MENGE.
DATA: LV_BASE(30), LV_DETAIL(30),
      LV_STRIPE(30), LV_STRIPE_NO(30).
DATA: LV_COLOR(50).
DATA: GV_PRINT.
DATA: OK_CODE  LIKE  SY-UCOMM,
      SAVE_OK  TYPE SYUCOMM,
      GV_REPID LIKE SY-REPID.

DATA: BEGIN OF LT_VL OCCURS 0,
        VBELN LIKE LIPS-VBELN,
        POSNR LIKE LIPS-POSNR,
      END OF LT_VL.

DATA: LV_FACTOR_SUM TYPE I.
DATA: LV_FACTOR(30).
DATA: LV_CHARG_CNT     TYPE I,
      LV_CHARG_CNT_SUM TYPE I.
DATA: LV_RETURN.
DATA: LV_SUM  TYPE I. "LIKE lips-lfimg.
DATA: LV_SUM_LFIMG LIKE LIPS-LFIMG.
DATA: LV_UNIT LIKE LIPS-VRKME.

RANGES: R_LFART FOR LIKP-LFART,
        R_VSTEL FOR LIKP-VSTEL,
        R_OUTYN FOR ZLET0005-OUT_YN.
*RANGES: r_werks FOR t001l-werks,
*        r_lgort FOR t001l-lgort.

CONTROLS : TC01  TYPE TABLEVIEW USING SCREEN 0100.

*/ SMARTFORM
DATA: BEGIN OF GT_VL OCCURS 0,
        VBELN LIKE LIKP-VBELN,
      END OF GT_VL.

DATA: LV_SM01 LIKE ZLES014 OCCURS 0 WITH HEADER LINE.
DATA: LV_SM02 LIKE ZLES015 OCCURS 0 WITH HEADER LINE.
DATA: LV_SM03 LIKE ZLES017B OCCURS 0 WITH HEADER LINE.
*___미부착부품 리스트 관리 - Start 2006.06.13
DATA: LV_SM04 LIKE ZLES016B OCCURS 0 WITH HEADER LINE.
*___미부착부품 리스트 관리 - End   2006.06.13

DATA: CONTROL_PARAMETERS TYPE SSFCTRLOP,
      OUTPUT_OPTIONS     TYPE SSFCOMPOP.
DATA: FUNC_NAME          LIKE RS38L-NAME.
DATA: PRINTER            LIKE TSP03D-PADEST.
DATA: OTF LIKE ITCOO OCCURS 0 WITH HEADER LINE.

DATA : GV_OK LIKE ICON-ID VALUE '@0V@',
       GV_NR LIKE ICON-ID VALUE '@77@'.

DATA : X_VBELN TYPE C,
       G01     TYPE C,
       G02     TYPE C VALUE 'X',
       G04     TYPE C,
       X_BATCH TYPE C,
       X_ACSR  TYPE C.

RANGES : S_VSTEL    FOR   LIKP-VSTEL.
DATA P_BZAREA   LIKE  ZLET0033-BZAREA.

*-----------------------------------------------------------------------
*-- Constants
*-----------------------------------------------------------------------
CONSTANTS:
* SALES ORDER
  SO_LENGTH(30)        VALUE 'SAP_LENGTH_VKRME',     "조장
  SO_FACTOR(30)        VALUE 'SAP_MILLCA_FACTOR',    "조장수 "사용안함
  SO_PACKAGING(30)     VALUE 'SAP_MILLCA_PACKAGING', "포장재 코드
  SO_PACKAGING_CAT(30) VALUE 'SAP_MILLCA_PACKAGING_CAT', "포장재 유형
  SO_COLOR(30)         VALUE 'PD_CA_COLOR_BASE',     "색상(BASE)
  SO_COLOR_STRIPE(30)  VALUE 'PD_CA_COLOR_STRIPE',   "색상(STRIPE)
* BATCH
  BA_LENGTH(30)        VALUE 'SAP_MILLCA_LENGTH',    "조장
  BA_FACTOR(30)        VALUE 'SAP_MILLCA_FACTOR',    "조장수
  BA_PACKAGING(30)     VALUE 'SAP_MILLCA_PACKAGING', "포장재 코드
  BA_PACKAGING_CAT(30) VALUE 'SAP_MILLCA_PACKAGING_CAT', "포장재 유형
  BA_COLOR(30)         VALUE 'PD_CA_COLOR_BASE',     "색상
  BA_COLOR_STRIPE(30)  VALUE 'PD_CA_COLOR_STRIPE'.   "색상(STRIPE)

*/ PARTNER FUNCTION
CONSTANTS: C_PAR_SP(2) VALUE 'AG',  "판매처
           C_PAR_BP(2) VALUE 'RE',  "청구처
           C_PAR_PY(2) VALUE 'RG',  "지급처
           C_PAR_PE(2) VALUE 'VE',  "영업사원
           C_PAR_SH(2) VALUE 'WE'.  "납품처

*-----------------------------------------------------------------------
*-- Selection Screen
*-----------------------------------------------------------------------
SELECTION-SCREEN FUNCTION KEY 1.
SELECTION-SCREEN: BEGIN OF BLOCK B1 WITH FRAME TITLE T1.
*/ #1
  SELECTION-SCREEN BEGIN OF LINE.
* 신규발행
    PARAMETERS: R01 RADIOBUTTON GROUP G_R1
                    USER-COMMAND UCOMM DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 4(28) TEXT-201 FOR FIELD R01.
* 재발행
    PARAMETERS: R02 RADIOBUTTON GROUP G_R1.
    SELECTION-SCREEN COMMENT 50(15) TEXT-202 FOR FIELD R02.
* 취소
    PARAMETERS: R03 RADIOBUTTON GROUP G_R1.
    SELECTION-SCREEN COMMENT 68(17) TEXT-203 FOR FIELD R03.

  SELECTION-SCREEN END OF LINE.
*/ #2
  SELECTION-SCREEN: BEGIN OF LINE.
    PARAMETERS      : R_TKNUM    RADIOBUTTON GROUP RD1    "선적기준
                      USER-COMMAND UCOMM DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 4(28)  TEXT-001 FOR FIELD R_TKNUM.
    PARAMETERS      : R_VBELN    RADIOBUTTON GROUP RD1.    "납품기준
    SELECTION-SCREEN COMMENT 50(15) TEXT-002 FOR FIELD R_VBELN.
  SELECTION-SCREEN: END OF LINE.
*/ #3
  SELECTION-SCREEN: BEGIN OF LINE.
    PARAMETERS      : R_SO    RADIOBUTTON GROUP RD2    "sales order
                      DEFAULT 'X' USER-COMMAND UCOMM .
    SELECTION-SCREEN COMMENT 4(28)  TEXT-003 FOR FIELD R_SO.
    PARAMETERS      : R_STO   RADIOBUTTON GROUP RD2 .   "STO
    SELECTION-SCREEN COMMENT 50(15) TEXT-004 FOR FIELD R_STO.
    PARAMETERS      : R_ALL   RADIOBUTTON GROUP RD2 .   "all
    SELECTION-SCREEN COMMENT 68(17) TEXT-205 FOR FIELD R_ALL.

  SELECTION-SCREEN: END OF LINE.

*/ 통문대상포함
  PARAMETERS: P_OUT AS CHECKBOX .


SELECTION-SCREEN: END OF BLOCK B1.

* block 2
SELECTION-SCREEN: BEGIN OF BLOCK B2 WITH FRAME TITLE T2.
  SELECT-OPTIONS  : S_WADAT    FOR   LIKP-WADAT_IST OBLIGATORY NO-EXTENSION. "출고일
  SELECT-OPTIONS  : S_VSART    FOR   LIKP-VSART. "출하유형
  SELECT-OPTIONS  : S_ROUTE    FOR   LIKP-ROUTE.        "운송경로
  SELECT-OPTIONS  : S_KUNNR    FOR   LIKP-KUNNR.        "납품처
  SELECT-OPTIONS  : S_VBELN    FOR   LIKP-VBELN.        "아웃바운드 납품
  SELECT-OPTIONS  : S_TKNUM    FOR   VTTK-TKNUM.        "선적번호
  SELECT-OPTIONS  : S_ERNAM    FOR   LIKP-ERNAM.        "납품문서생성인
  SELECT-OPTIONS  : S_IV_NO    FOR   ZLET0005-IV_NO.
  SELECT-OPTIONS  : S_DATE     FOR   ZLET0005-IV_DATE.
SELECTION-SCREEN: END OF BLOCK B2.

* block 3
SELECTION-SCREEN: BEGIN OF BLOCK B3 WITH FRAME TITLE T3.
  SELECT-OPTIONS  : S_VKBUR    FOR   VBAK-VKBUR.            "영업팀
  SELECT-OPTIONS  : S_VKGRP    FOR   VBAK-VKGRP.            "영업그룹
  SELECT-OPTIONS  : S_VTWEG    FOR   VBAK-VTWEG.            "유통경로
SELECTION-SCREEN: END OF BLOCK B3.
