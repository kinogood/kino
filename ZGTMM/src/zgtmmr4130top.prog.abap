*&---------------------------------------------------------------------*
*& Include ZGTMMR4130TOP
*&---------------------------------------------------------------------*

INCLUDE   <CTLDEF>.
INCLUDE   <LIST>.
INCLUDE   <ICON>.

TYPE-POOLS: SLIS.

*(S)기능 추가 관련(SJM 25.03.18)
DATA : GV_ZUSE LIKE ZGTMMT1000-ZUSE.

DATA : GV_BUKRS TYPE BUKRS,
       GV_MATNR TYPE MATNR,
       GV_L_LAG TYPE LGORT_D,
       GV_W_LAG TYPE LGORT_D.

DATA : GV_ERR,
       GV_DEL,
       GV_PRC,
       GV_RES.

DATA : BEGIN OF GT_LAG OCCURS 0,
         TYPE(1),
         LGORT   LIKE MDSB-LGORT,
       END   OF GT_LAG.

DATA : BEGIN OF GT_MDSB OCCURS 0,
         MATNR   TYPE MATNR,
         WERKS   TYPE WERKS_D,
         LGORT   TYPE LGORT_D,
         CHARG   TYPE CHARG_D,
         XCHPF   TYPE XCHPF,
         MBLNR_F,

         MENGE   TYPE MENGE_D,
         LABST   TYPE LABST,
         LBLAB   TYPE LABST,
         MEINS   TYPE MEINS,
         TAGNR   TYPE ZTAGNR,
*        XPRC    TYPE NETWR,
         TYPE(1),
       END   OF GT_MDSB.

DATA : BEGIN OF GT_CSTK OCCURS 0,
         MATNR   TYPE MATNR,
         WERKS   TYPE WERKS_D,
         LGORT   TYPE LGORT_D,
         CHARG   TYPE CHARG_D,

         MENGE   TYPE MENGE_D,
         MEINS   TYPE MEINS,
         TYPE(1),
       END   OF GT_CSTK.

DATA : BEGIN OF GS_HDR,
         LIFNR          LIKE LFA1-LIFNR,
         NAME1          LIKE LFA1-NAME1,
         WERKS          LIKE T001L-WERKS,
*        LGORT          LIKE T001L-LGORT,
*        LGOBE          LIKE T001L-LGOBE,
         BLOCK(1),
         BLOCK_TXT(132),
         PREIS          TYPE ZGTMM_CV_SCSTOCKHEADER-PREIS,
         SCVAL          TYPE ZGTMM_CV_SCSTOCKHEADER-TOTALSCVALUE,
         ISVAL          TYPE MSEG-DMBTR,
         IAVAL          TYPE MSEG-DMBTR,
         APVAL          TYPE ZGTMM_CV_SCSTOCKHEADER-APVALUE,
         WAERS          TYPE WAERS,
         ORES(3),       "LIKE ZGTMMT4110-ORES,
         REMARK(150),
         XCPT(1),
         QTEXT(200),
       END   OF GS_HDR.

DATA : BEGIN OF GT_MBEW OCCURS 0,
         MATNR LIKE MBEW-MATNR,
         BWKEY LIKE MBEW-BWKEY,
         VPRSV LIKE MBEW-VPRSV,
         VERPR LIKE MBEW-VERPR,
         STPRS LIKE MBEW-STPRS,
         PEINH LIKE MBEW-PEINH,
       END   OF GT_MBEW.

DATA : GV_XPRC TYPE NETWR,
       GV_LPRC TYPE NETWR,
       GV_WPRC TYPE NETWR.

DATA : GT_LBOX TYPE VRM_VALUES.

DATA : BEGIN OF GT_KEY OCCURS 0,
         WERKS    LIKE ZGTMMT4114-PSWRK,
         EBELN    LIKE ZGTMMT4114-EBELN,
         EBELP    LIKE ZGTMMT4114-EBELP,
         MATNR_C  LIKE ZGTMMT4114-MATNR,
         TAGNR    LIKE ZGTMMT4114-TAGNR,
         POSNR    LIKE ZGTMMT4114-POSNR,
         CHARG    LIKE ZGTMMT4114-CHARG,
         ZSEQ     LIKE ZGTMMT4114-ZSEQ,
         CHECK(1),
       END   OF GT_KEY.

DATA : GT_AHDR LIKE ZGTMMT4110 OCCURS 0 WITH HEADER LINE,
       GT_AITM LIKE ZGTMMT4111 OCCURS 0 WITH HEADER LINE,
       GT_ABAT LIKE ZGTMMT4112 OCCURS 0 WITH HEADER LINE,
       GT_AHIS LIKE ZGTMMT4114 OCCURS 0 WITH HEADER LINE.

DATA : GS_CREA LIKE ZGTMMS0001,
       GS_CHNG LIKE ZGTMMS0002.

DATA : BEGIN OF GT_APPV OCCURS 0,
         USRID TYPE ZGTMM_CV_GETUSERNAME-USERID,
*        NAME  TYPE ZGTMM_CV_GETAPUSERLIST-NAME,
         EMAIL TYPE ZGTMM_CV_GETUSERNAME-EMAIL,
       END   OF GT_APPV.

DATA : GV_TEXT TYPE SO_OBJ_DES,
       GT_MTXT TYPE BCSY_TEXT,
       GS_MTXT TYPE SOLI.

DATA : BEGIN OF GT_PO OCCURS 0,
         EBELN   TYPE EBELN,
         EBELP   TYPE EBELP,
         MATNR   LIKE ZGTMMT4114-MATNR,
*        TAGNR   LIKE ZGTMMT4114-TAGNR,
         POSNR   LIKE ZGTMMT4114-POSNR,
         GUBUN   LIKE ZGTMMT4114-GUBUN,

         BDMNG   LIKE ZGTMMT4114-BDMNG,
         ENMNG   LIKE ZGTMMT4114-ENMNG,
         LGORT   LIKE ZGTMMT4114-LGORT,
         CHARG   LIKE ZGTMMT4114-CHARG,
         ZSEQ    LIKE ZGTMMT4114-ZSEQ,
         LOTNO   LIKE ZGTMMT4114-LOTNO,
         TAGNR   LIKE ZGTMMT4114-TAGNR,

         MBLNR   LIKE ZGTMMT4114-MBLNR,
         MJAHR   LIKE ZGTMMT4114-MJAHR,

         ZGUID   LIKE ZGTMMT4110-ZGUID,
         APPSTAT LIKE ZGTMMT4110-APPSTAT,
       END   OF GT_PO.

DATA : GT_POL LIKE GT_PO OCCURS 0 WITH HEADER LINE,
       GT_POW LIKE GT_PO OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF GS_CAP,
         STATS LIKE ICON-ID,
         ZGUID TYPE GUID_32,
         MBLNR LIKE MKPF-MBLNR,
       END   OF GS_CAP.

DATA : BEGIN OF GT_WIF OCCURS 0,
         LGORT LIKE MDSB-LGORT,
         MBLNR LIKE MKPF-MBLNR,
         MJAHR LIKE MKPF-MJAHR,
       END   OF GT_WIF.

DATA : GV_COND TYPE STRING.

DATA : GV_LGUID	TYPE GUID_32,
       GV_WGUID	TYPE GUID_32.

RANGES : GR_GUID FOR ZGTMMT4110-ZGUID.


DEFINE _SET_CON1.
  CLEAR : &1.
  IF &3 IS NOT INITIAL.
    &2 = &3.
    COLLECT &1.
  ENDIF.
END-OF-DEFINITION.

DEFINE _COL_RNG.
  CLEAR : &1.
  IF &2 IS NOT INITIAL.
    &1-SIGN   = GC_I.
    &1-OPTION = GC_EQ.
    &1-LOW    = &2.
    COLLECT &1.
  ENDIF.
END-OF-DEFINITION.


CONSTANTS : GC_A(1)           VALUE 'A',
            GC_E(1)           VALUE 'E',
            GC_I(1)           VALUE 'I',
            GC_J(1)           VALUE 'J',
            GC_L(1)           VALUE 'L',
            GC_N(1)           VALUE 'N',
            GC_O(1)           VALUE 'O',
            GC_W(1)           VALUE 'W',
            GC_X(1)           VALUE 'X',
            GC_0(1)           VALUE '0',
            GC_EQ(2)          VALUE 'EQ',
            GC_MM(2)          VALUE 'MM',
            GC_OD(2)          VALUE 'OD',
            GC_02(2)          VALUE '02',
            GC_CNF(3)         VALUE 'CNF',
            GC_MGI(3)         VALUE 'MGI',
            GC_999(3)         VALUE '999',
            GC_KPCM(4)        VALUE 'KPCM',
            GC_0200(4)        VALUE '0200',
            GC_0300(4)        VALUE '0300',
            GC_0400(4)        VALUE '0400',
            GC_ZPPT0018(8)    VALUE 'ZPPT0018',
            GC_ZGTMMT4114(10) VALUE 'ZGTMMT4114',
            GC_ZGTMMR4130(10) VALUE 'ZGTMMR4130'.
*(E)기능 추가 관련(SJM 25.03.18)

CONSTANTS : GC_TCD_MB01   TYPE T158G-GMCODE VALUE '01', "구매오더입고
            GC_TCD_MB31   TYPE T158G-GMCODE VALUE '02', "생산오더입고
            GC_TCD_MB1A   TYPE T158G-GMCODE VALUE '03', "출고
            GC_TCD_MB1B   TYPE T158G-GMCODE VALUE '04', "이전전기
            GC_TCD_MB1C   TYPE T158G-GMCODE VALUE '05', "기타입고
            GC_TCD_MB11   TYPE T158G-GMCODE VALUE '06', "자재이동
            GC_TCD_MB04   TYPE T158G-GMCODE VALUE '07', "외주가공

            GC_MVT_101(3) VALUE '101',
            GC_MVT_351(3) VALUE '351',
            GC_MVT_541(3) VALUE '541',
            GC_MVT_542(3) VALUE '542'.

TABLES: ZPPT0018,  "SC Item
        ZPPT0001,  "작업실적 테이블(꼬리표)
        ZPPT0038,  "외주 꼬리표 일련번호
        ZPPT0020,  "작업지시 테이블
        ZLET0005,  "[LE] 통문 헤더
        ZLET0006,  "[LE] 통문 Line Item
        ZLET0034,  "[LE] 거래명세서 - 사업장 매핑 (MM용)
        ZPPT0158,
        ZPPT0000,  "PP 공용 테이블
        EBAN,      "구매 요청
        EKKO,      "구매문서헤더
        EKPO,      "구매문서품목
        EKES,      "공급업체확정
        EKET,      "납품일정계약의 일정라인
        EINE,      "구매정보레코드: 구매조직데이타
        MKPF,      "헤더: 자재문서
        MSLB,      "공급업체 특별재고
        LFA1,      "구매처마스터 (일반섹션)
        MDSB,      "예약/종속소요량의 종속소요량 뷰
        MARA,      "일반자재데이타
        MARC,      "자재에 대한 플랜트데이타
        MARD,      "자재에 대한 저장위치데이타
        MCHB,      "뱃치재고
        MAKT,      "자재내역
        IOHEADER.  "

*& 구매요청 정보...
DATA  : BEGIN OF GT_EBAN OCCURS 0,
          WERKS       LIKE EBAN-WERKS,        "플랜트
          BANFN       LIKE EBAN-BANFN,        "요청번호
          BNFPO       LIKE EBAN-BNFPO,        "요청품목
          BSART       LIKE EBAN-BSART,        "구매요청문서유형
          BSTYP       LIKE EBAN-BSTYP,        "구매문서범주
          DISPO       LIKE EBAN-DISPO,        "MRP관리자
          EKGRP       LIKE EBAN-EKGRP,        "구매그룹
          MATNR       LIKE EBAN-MATNR,        "자재번호
          TXZ01       LIKE MARA-ZZMAKTX80,    "자재내역
          MENGE       LIKE EBAN-MENGE,        "요청수량
          MEINS       LIKE EBAN-MEINS,        "구매요청단위
          LFDAT       LIKE EBAN-LFDAT,        "납품일자
          PSTYP       LIKE EBAN-PSTYP,        "구매문서의 품목범주
          EPSTP       LIKE RM06B-EPSTP,       "I.C
          LGORT       LIKE EBAN-LGORT,        "저장위치
          SPART       LIKE MARA-SPART,        "제품군
          LIFNR       LIKE EBAN-LIFNR,        "업체
*&        flief       LIKE eban-flief,        "확정업체
          NAME1       LIKE LFA1-NAME1,        "업체명
          NAME2       LIKE KNA1-NAME1,        "납선명
          NAME3       LIKE KNA1-NAME1,        "납지
          EMLIF       LIKE EKPO-EMLIF,        "직납업체
          MENGE_A     LIKE EBAN-MENGE,        "외주지시수량
          LENGTH      TYPE ATWRT,             "개별길이
          FACTOR      TYPE ATWRT,             "조장수

          LENGTH_V    LIKE ZPPT0001-MGVRG,    "개별길이
          FACTOR_V    LIKE ZPPT0001-FOSTCNT,  "조장수

          PACKING_CAT TYPE ATWRT,             "포장재 유형
          PACKING     TYPE ATWRT,             "포장재
          MENGE_B     LIKE EBAN-MENGE,        "구매요청잔량
          LOSSR       LIKE ZPPT0018-LOSSR,    "업체Loss율
          LOSSF,                              "Loss율 적용여부
          EBELN       LIKE EBAN-EBELN,        "구매오더번호
          EBELP       LIKE EBAN-EBELP,        "구매오더 Item
          BSMNG       LIKE EBAN-BSMNG,        "오더수량
          AEDAT       LIKE EKKO-AEDAT,        "구매오더 생성일
          ERDAT       LIKE EKPO-AEDAT,        "구매오더 변경일
          FLAG1(4),                           "이전전기여부
          FLAG2(4),                           "통문증발행여부
          EBTYP       LIKE EKES-EBTYP,        "확정범주
          EINDT       LIKE EKES-EINDT,        "확정납품일
          MENGE_C     LIKE EKES-MENGE,        "확정수량
          MTART       LIKE MARA-MTART,        "자재유형
          MATKL       LIKE MARA-MATKL,        "자재그룹
          DPCBT       LIKE MARA-DPCBT,        "
          CHARG       LIKE MDSB-CHARG,        "배치번호
          AUFNR       LIKE ZPPT0001-AUFNR,    "오더번호
          LTEXT1      LIKE TLINE-TDLINE,      "구매오더 품목 텍스트
          LTEXT2      LIKE TLINE-TDLINE,      "판매오더 텍스트
          VBELN       LIKE VBAP-VBELN,        "영업문서
          POSNR       LIKE VBAP-POSNR,        "영업문서품목
          GLMNG       LIKE EKET-GLMNG,        "납품수량
          BEDAT       LIKE EKKO-BEDAT,        "구매증빙일

          ZZIDEN_CODE LIKE MARA-ZZIDEN_CODE,  "절연선심식별
          TAG_F(4),                           "꼬리표발행여부
          CUOBJ       LIKE EKPO-CUOBJ,        "구성 (내부오브젝트번호)
          CHG_SRV     LIKE EKPO-CHG_SRV,      "구성변경
          KZKFG       LIKE EKPO-KZKFG,        "구성오리진
          MEINS_A     LIKE EKPO-MEINS,        "구매오더단위
          BUKRS       TYPE MSEG-BUKRS,
          EKORG       LIKE T024E-EKORG,       "구매조직
          ZCERTI      TYPE ZMMT0155,          "인증구분
          CHECK(1),                           "체크필드
          RECST(1),                           "레코드상태('I','M','D')
          NPURC(4),                           "신규 발주여부
*(S)기능 추가 관련(SJM 25.03.18)
          STATS_L     LIKE ICON-ID,           "승인상태(배치 관리자재)
          STATS_W     LIKE ICON-ID,           "승인상태(배치 미관리자재)
          ZGUID_L     TYPE GUID_32,           "ZGUID(배치 관리자재)
          ZGUID_W     TYPE GUID_32,           "ZGUID(배치 미관리자재)
*         ZGUID(64),                          "ZGUID(배치 관리자재)+ZGUID(배치 미관리자재)
*(E)기능 추가 관련(SJM 25.03.18)


*[S] 조장구성표번호, 완제품, 내역 필드추가 / 박우진 2026.09.20
          GRPCD       LIKE ZPPT0136-GRPCD,      "조장구성표
          MATNR_F     LIKE ZPPT0136-MATNR_F,    "완제품코드
          MAKTX       LIKE ZPPT0136-MAKTX,      "완제품명
*[E] 조장구성표번호, 완제품, 내역 필드추가

          F_COL       TYPE LVC_T_SCOL,
          CELLTAB     TYPE LVC_T_STYL,        "Cell단위 수정 스타일
        END   OF GT_EBAN.

DATA  : GT_EBAN_N   LIKE GT_EBAN OCCURS 0
                    WITH HEADER LINE.

DATA  : GT_EBAN_TMP LIKE GT_EBAN OCCURS 0
                    WITH HEADER LINE.

DATA  : GV_LENGTH      TYPE ATWRT,             "개별길이
        GV_FACTOR      TYPE ATWRT,             "조장수
        GV_PACKING_CAT TYPE ATWRT,        "포장재유형
        GV_PACKING     TYPE ATWRT,             "포장재
        GV_SPART       LIKE MARA-SPART,        "제품군
        GV_MATKL       LIKE MARA-MATKL,        "자재그룹
        GF_PSTYP       LIKE EKPO-PSTYP.        "구매문서의 품목범주

*& 길이관리 사급자재 정보...
DATA  : BEGIN OF GT_MDSB_L OCCURS 0,
          IV_NO       LIKE ZLET0005-IV_NO,    "통문번호
          MBLNR       LIKE MKPF-MBLNR,        "자재문서
          ZEILE       LIKE MSEG-ZEILE,        "자재문서 품목 번호
          WERKS       LIKE EBAN-WERKS,        "플랜트
          MATNR       LIKE EKPO-MATNR,        "입고반제품 Code
          EBELN       LIKE EKPO-EBELN,        "구매오더번호
          EBELP       LIKE EKPO-EBELP,        "구매오더 Item,
          BSART       LIKE EBAN-BSART,        "구매요청문서유형
          BSTYP       LIKE EBAN-BSTYP,        "구매문서범주
          MENGE       LIKE EKPO-MENGE,        "구매오더수량
          MEINS       LIKE MARA-MEINS,        "기본단위
          AUSME       LIKE MARC-AUSME,        "출고단위
          ERFME       LIKE MDSB-ERFME,        "입력단위
          MATNR_C     LIKE MDSB-MATNR,        "출고반제품 Code
          MAKTX_C     LIKE MAKT-MAKTX,        "자재명
          BDMNG       LIKE ZPPT0018-BDMNG,    "소요량
          ERFMG       LIKE MDSB-ERFMG,        "입력단위수량
          LABST       LIKE MARD-LABST,        "플랜트재고
          LBLAB       LIKE MSLB-LBLAB,        "SC가용재고
          LGORT       LIKE MDSB-LGORT,        "저장위치
          CHARG       LIKE MDSB-CHARG,        "배치번호
          TAGNR       LIKE ZPPT0011-TAGNR,    "꼬리표번호
          LIFNR       LIKE EBAN-LIFNR,        "업체
          MATKL       LIKE MARA-MATKL,        "자재그룹
          XCHPF       LIKE MARA-XCHPF,        "뱃치관리
          POSNR       LIKE MDSB-POSNR,        "BOM품목번호
          SERNR       LIKE MDSB-SERNR,        "BOM전개번호
          MJAHR       LIKE MKPF-MJAHR,        "자재문서년도
          BUDAT       LIKE MKPF-BUDAT,        "전표의 전기일
          CPUDT       LIKE MKPF-CPUDT,        "회계전표 입력일
          LOTNO       LIKE ZPPT0018-LOTNO,    "LOT No.
          ENMNG       LIKE ZPPT0018-ENMNG,    "출고수량

*&          iv_no     LIKE zlet0005-iv_no,    "통문번호
          IV_DATE     LIKE ZLET0005-IV_DATE,  "통문증발행일
          IV_PRINT_YN LIKE ZLET0005-IV_PRINT_YN, "통문증발행여부
          OUT_YN      LIKE ZLET0005-OUT_YN,   "통문여부
          MBLNR_F,                          "이전전기여부

          FLAG1(4),                         "이전전기여부(ICON)
          FLAG2(4),                         "통문증발행여부(ICON)

          CHECK(1),                         "체크필드
          RECST(1),                         "레코드상태('I','M','D')
*(S)기능 추가 관련(SJM 25.03.18)
          STATS       LIKE ICON-ID,           "승인상태(배치 관리자재)
          ZGUID       TYPE GUID_32,           "ZGUID(배치 관리자재)
*(E)기능 추가 관련(SJM 25.03.18)
          F_COL       TYPE LVC_T_SCOL,
          CELLTAB     TYPE LVC_T_STYL,        "Cell단위 수정 스타일
        END   OF GT_MDSB_L.

DATA  : BEGIN OF GT_MDSB_L3 OCCURS 0,
          IV_NO       LIKE ZLET0005-IV_NO,    "통문번호
          MBLNR       LIKE MKPF-MBLNR,        "자재문서
          ZEILE       LIKE MSEG-ZEILE,
          WERKS       LIKE EBAN-WERKS,        "플랜트
          MATNR       LIKE EKPO-MATNR,        "입고반제품 Code
          EBELN       LIKE EKPO-EBELN,        "구매오더번호
          EBELP       LIKE EKPO-EBELP,        "구매오더 Item,
          BSART       LIKE EBAN-BSART,        "구매요청문서유형
          BSTYP       LIKE EBAN-BSTYP,        "구매문서범주
          MENGE       LIKE EKPO-MENGE,        "구매오더수량
          MEINS       LIKE MARA-MEINS,        "기본단위
          AUSME       LIKE MARC-AUSME,        "출고단위
          ERFME       LIKE MDSB-ERFME,        "입력단위
          MATNR_C     LIKE MDSB-MATNR,        "출고반제품 Code
          MAKTX_C     LIKE MAKT-MAKTX,        "자재명
          BDMNG       LIKE MDSB-BDMNG,        "소요량
          ERFMG       LIKE MDSB-ERFMG,        "입력단위수량
          LABST       LIKE MARD-LABST,        "플랜트재고
          LBLAB       LIKE MSLB-LBLAB,        "SC가용재고
          LGORT       LIKE MDSB-LGORT,        "저장위치
          CHARG       LIKE MDSB-CHARG,        "배치번호
          TAGNR       LIKE ZPPT0011-TAGNR,    "꼬리표번호
          LIFNR       LIKE EBAN-LIFNR,        "업체
          MATKL       LIKE MARA-MATKL,        "자재그룹
          XCHPF       LIKE MARA-XCHPF,        "뱃치관리
          POSNR       LIKE MDSB-POSNR,        "BOM품목번호
*&          sernr     LIKE mdsb-sernr,        "BOM전개번호
          MJAHR       LIKE MKPF-MJAHR,        "자재문서년도
          BUDAT       LIKE MKPF-BUDAT,        "전표의 전기일
          CPUDT       LIKE MKPF-CPUDT,        "회계전표 입력일
          LOTNO       LIKE ZPPT0018-LOTNO,    "LOT No.
          ENMNG       LIKE ZPPT0018-ENMNG,    "출고수량
          SERNR       LIKE MDSB-SERNR,        "BOM전개번호
          IV_DATE     LIKE ZLET0005-IV_DATE,  "통문증발행일
          IV_PRINT_YN LIKE ZLET0005-IV_PRINT_YN, "통문증발행여부
          OUT_YN      LIKE ZLET0005-OUT_YN,   "통문여부
          MBLNR_F,                          "이전전기여부

          FLAG1(4),                         "이전전기여부(ICON)
          FLAG2(4),                         "통문증발행여부(ICON)

          CHECK(1),                         "체크필드
          RECST(1),                         "레코드상태('I','M','D')
        END   OF GT_MDSB_L3.

DATA  : GT_MDSB_L3T LIKE GT_MDSB_L3  OCCURS 0 WITH HEADER LINE.
DATA  : GT_MDSB_L3A LIKE GT_MDSB_L3  OCCURS 0 WITH HEADER LINE.

*& 중량관리 사급자재 정보(구매오더별)...
DATA  : BEGIN OF GT_MDSB_W1 OCCURS 0,
          WERKS       LIKE EBAN-WERKS,        "플랜트
          MATNR       LIKE EKPO-MATNR,        "입고반제품 Code
          EBELN       LIKE EKPO-EBELN,        "구매오더번호
          EBELP       LIKE EKPO-EBELP,        "구매오더 Item,
          BSART       LIKE EBAN-BSART,        "구매요청문서유형
          BSTYP       LIKE EBAN-BSTYP,        "구매문서범주
          MENGE       LIKE EKPO-MENGE,        "구매오더수량
          MEINS       LIKE EKPO-MEINS,        "기본단위
          AUSME       LIKE MARC-AUSME,        "출고단위
          ERFME       LIKE MDSB-ERFME,        "입고단위
          MATNR_C     LIKE MDSB-MATNR,        "출고반제품 Code
          MAKTX_C     LIKE MAKT-MAKTX,        "자재명
          BDMNG       LIKE MDSB-ERFMG,        "소요량
          BDMNG_A     LIKE MDSB-BDMNG,        "소요량(Loss율적용)
          ERFMG       LIKE MDSB-ERFMG,        "입력단위수량
          ERFMG_A     LIKE MDSB-ERFMG,        "입력단위수량(Loss율적용)
          LOTNO       LIKE ZPPT0018-LOTNO,    "LOT No.
          CHARG       LIKE MDSB-CHARG,        "배치번호
          TAGNR       LIKE ZPPT0011-TAGNR,    "꼬리표번호
          LGORT       LIKE MDSB-LGORT,        "저장위치

          IV_NO       LIKE ZLET0005-IV_NO,    "통문번호
          IV_DATE     LIKE ZLET0005-IV_DATE,  "통문증발행일
          IV_PRINT_YN LIKE ZLET0005-IV_PRINT_YN, "통문증발행여부
          OUT_YN      LIKE ZLET0005-OUT_YN,   "통문여부
          MBLNR_F,                          "이전전기여부
          LIFNR       LIKE EBAN-LIFNR,        "업체

*&          check(1),                         "체크필드
*&          recst(1),                         "레코드상태('I','M','D')
          F_COL       TYPE LVC_T_SCOL,
          CELLTAB     TYPE LVC_T_STYL,        "Cell단위 수정 스타일
        END   OF GT_MDSB_W1.

*& 중량관리 사급자재 정보(자재별)...
DATA  : BEGIN OF GT_MDSB_W2 OCCURS 0,
          IV_NO       LIKE ZLET0005-IV_NO,    "통문번호
          MBLNR       LIKE MKPF-MBLNR,        "자재문서
          ZEILE       LIKE MSEG-ZEILE,
          WERKS       LIKE EBAN-WERKS,        "플랜트
          MATNR_C     LIKE MDSB-MATNR,        "출고반제품 Code
          LABST       LIKE MARD-LABST,        "플랜트재고
          LBLAB       LIKE MSLB-LBLAB,        "SC가용재고
          MEINS       LIKE MARA-MEINS,        "기본단위
          AUSME       LIKE MARC-AUSME,        "출고단위
          ERFME       LIKE MDSB-ERFME,        "입고단위
          BDMNG       LIKE MDSB-ERFMG,        "소요량
          BDMNG_A     LIKE MDSB-BDMNG,        "소요량(Loss율적용)
          ERFMG       LIKE MDSB-ERFMG,        "입력단위수량
          ERFMG_A     LIKE MDSB-ERFMG,        "입력단위수량(Loss율적용)
          ENMNG       LIKE MDSB-ENMNG,        "업체불출량
          RVMNG       LIKE MDSB-ENMNG,        "예약수량
          LOTNO       LIKE ZPPT0018-LOTNO,    "Lot No.
          CHARG       LIKE MDSB-CHARG,        "배치번호
          TAGNR       LIKE ZPPT0011-TAGNR,    "꼬리표번호
          LGORT       LIKE MDSB-LGORT,        "저장위치

*&          mblnr     LIKE mkpf-mblnr,        "자재문서
          MJAHR       LIKE MKPF-MJAHR,        "자재문서년도
          BUDAT       LIKE MKPF-BUDAT,        "전표의 전기일
          CPUDT       LIKE MKPF-CPUDT,        "회계전표 입력일

*&          iv_no     LIKE zlet0005-iv_no,    "통문번호
          IV_DATE     LIKE ZLET0005-IV_DATE,  "통문증발행일
          IV_PRINT_YN LIKE ZLET0005-IV_PRINT_YN, "통문증발행여부
          OUT_YN      LIKE ZLET0005-OUT_YN,   "통문여부
          MBLNR_F,                          "이전전기여부
          LIFNR       LIKE EBAN-LIFNR,        "업체

          FLAG1(4),                         "이전전기여부(ICON)
          FLAG2(4),                         "통문증발행여부(ICON)

          CHECK(1),                         "체크필드
          RECST(1),                         "레코드상태('I','M','D')
*(S)기능 추가 관련(SJM 25.03.18)
          STATS       LIKE ICON-ID,           "승인상태(배치 미관리자재)
          ZGUID       TYPE GUID_32,           "ZGUID(배치 미관리자재)
*(E)기능 추가 관련(SJM 25.03.18)
          F_COL       TYPE LVC_T_SCOL,
          CELLTAB     TYPE LVC_T_STYL,        "Cell단위 수정 스타일
        END   OF GT_MDSB_W2.

DATA  : BEGIN OF GT_MDSB_W3 OCCURS 0,
          WERKS       LIKE EBAN-WERKS,        "플랜트
          MATNR_C     LIKE MDSB-MATNR,        "출고반제품 Code
          BDMNG       LIKE MDSB-ERFMG,        "소요량
          BDMNG_A     LIKE MDSB-BDMNG,        "소요량(Loss율적용)
          ERFMG       LIKE MDSB-ERFMG,        "입력단위수량
          ERFMG_A     LIKE MDSB-ERFMG,        "입력단위수량(Loss율적용)
          MEINS       LIKE MARA-MEINS,        "기본단위
          ERFME       LIKE MDSB-ERFME,        "입고단위
          AUSME       LIKE MARC-AUSME,        "출고단위
          LBLAB       LIKE MSLB-LBLAB,        "SC가용재고
          LOTNO       LIKE ZPPT0018-LOTNO,    "Lot No.
          LGORT       LIKE MDSB-LGORT,        "저장위치
          LIFNR       LIKE EBAN-LIFNR,        "업체
          TAGNR       LIKE ZPPT0011-TAGNR,    "꼬리표번호
          CHARG       LIKE MDSB-CHARG,        "배치번호

          MBLNR       LIKE MKPF-MBLNR,        "자재문서
          MJAHR       LIKE MKPF-MJAHR,        "자재문서년도
          BUDAT       LIKE MKPF-BUDAT,        "전표의 전기일
          CPUDT       LIKE MKPF-CPUDT,        "회계전표 입력일

          IV_NO       LIKE ZLET0005-IV_NO,    "통문번호
          IV_DATE     LIKE ZLET0005-IV_DATE,  "통문증발행일
          IV_PRINT_YN LIKE ZLET0005-IV_PRINT_YN, "통문증발행여부
          OUT_YN      LIKE ZLET0005-OUT_YN,    "통문여부
          MBLNR_F,                           "이전전기여부
        END   OF GT_MDSB_W3.

*& 업체 체크용...
DATA  : BEGIN OF GT_LIFNR OCCURS 0,
          LIFNR LIKE EBAN-LIFNR,        "업체
        END   OF GT_LIFNR.

*& ALV Global Field
DATA  : ALV_VARIANT        LIKE DISVARIANT,
        ALV_VARIANT1       LIKE DISVARIANT,
        ALV_VARIANT2       LIKE DISVARIANT,
        ALV_REPID          LIKE SY-REPID,
        G_EXIT             TYPE C,
        GS_LIST_COMMENTARY TYPE SLIS_T_LISTHEADER.

DATA: GT_FIELDS      LIKE HELP_VALUE  OCCURS 0 WITH HEADER LINE.
* ALV Attribute
DATA  : GT_EXCLUDE     TYPE UI_FUNCTIONS,    "Tool Bar Button저장
        GT_EXCLUDE_L   TYPE UI_FUNCTIONS,    "Tool Bar Button저장
        GT_EXCLUDE_W1  TYPE UI_FUNCTIONS,    "Tool Bar Button저장
        GT_EXCLUDE_W2  TYPE UI_FUNCTIONS,    "Tool Bar Button저장

        GS_FIELDCAT    TYPE LVC_S_FCAT,      "필드 속성 Set
        GT_FIELDCAT    TYPE LVC_T_FCAT,      "필드 속성 저장
        GT_FIELDCAT_L  TYPE LVC_T_FCAT,      "필드 속성 저장
        GT_FIELDCAT_W1 TYPE LVC_T_FCAT, "필드 속성 저장
        GT_FIELDCAT_W2 TYPE LVC_T_FCAT, "필드 속성 저장
        GS_F4          TYPE LVC_S_F4,                        "F4 필드
        GT_F4          TYPE LVC_T_F4,
        GS_LAYOCAT     TYPE LVC_S_LAYO,      "Grid 속성 저장(Display)
        GS_LAYOCAT_L   TYPE LVC_S_LAYO,      "Grid 속성 저장(Display)
        GS_LAYOCAT_W1  TYPE LVC_S_LAYO,      "Grid 속성 저장(Display)
        GS_LAYOCAT_W2  TYPE LVC_S_LAYO,      "Grid 속성 저장(Display)

        GS_SORT        TYPE LVC_S_SORT,
        GS_SORT_L      TYPE LVC_S_SORT,
        GS_SORT_W1     TYPE LVC_S_SORT,
        GS_SORT_W2     TYPE LVC_S_SORT,

        GV_REPID       LIKE SY-REPID,
        GV_TITLE       TYPE LVC_TITLE,
        GV_TITLE_L     TYPE LVC_TITLE,
        GV_TITLE_W     TYPE LVC_TITLE,

        GV_CONTAINER   TYPE SCRFNAME VALUE 'CC_CONTAINER_0100',
        GV_CONTAINER1  TYPE SCRFNAME VALUE 'CC_CONTAINER_0200',
        GT_SORT        TYPE LVC_T_SORT,
        GT_SORT_L      TYPE LVC_T_SORT,
        GT_SORT_W1     TYPE LVC_T_SORT,
        GT_SORT_W2     TYPE LVC_T_SORT,
        GT_ROWS        TYPE LVC_T_ROW  WITH HEADER LINE,

        LS_COL         TYPE SY-TABIX,
        L_SCROLL       TYPE LVC_S_STBL.

DATA  : F_COLOR TYPE LVC_T_SCOL WITH HEADER LINE,
        T_COL   TYPE LVC_S_COLO.

*& Drop-Down List Box List.
DATA  : GT_DROPDOWN TYPE LVC_T_DROP,
        GS_DROPDOWN TYPE LVC_S_DROP.

DATA  :GT_PFSTATUS  TYPE TABLE OF SY-UCOMM.
*& CLASS Reference 정의
CLASS : LCL_EVENT_HANDLER      DEFINITION DEFERRED,
        LCL_EVENT_HANDLER_L    DEFINITION DEFERRED,
        LCL_EVENT_HANDLER_W1   DEFINITION DEFERRED,
        LCL_EVENT_HANDLER_W2   DEFINITION DEFERRED,
        LCL_ALV_GRID           DEFINITION DEFERRED.

DATA  : GCL_CUSTOM_CONTAINER   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
        GCL_CUSTOM_CONTAINER1  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
        GCL_SPLITTER_CONTAINER TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
        GCL_CONTAINER_L        TYPE REF TO CL_GUI_CONTAINER,
        GCL_CONTAINER_W1       TYPE REF TO CL_GUI_CONTAINER,
        GCL_CONTAINER_W2       TYPE REF TO CL_GUI_CONTAINER,

        GCL_GRID               TYPE REF TO LCL_ALV_GRID,
        GCL_GRID_L             TYPE REF TO LCL_ALV_GRID,
        GCL_GRID_W1            TYPE REF TO LCL_ALV_GRID,
        GCL_GRID_W2            TYPE REF TO LCL_ALV_GRID,
        GCL_EVENT_HANDLER      TYPE REF TO LCL_EVENT_HANDLER,
        GCL_EVENT_HANDLER_L    TYPE REF TO LCL_EVENT_HANDLER_L,
        GCL_EVENT_HANDLER_W1   TYPE REF TO LCL_EVENT_HANDLER_W1,
        GCL_EVENT_HANDLER_W2   TYPE REF TO LCL_EVENT_HANDLER_W2.

*& BAPI-구매오더 생성 관련 구조 및 테이블 정의...
DATA  : GS_BAPI_HEADER        LIKE BAPIMEPOHEADER,
        GS_BAPI_HEADERX       LIKE BAPIMEPOHEADERX,
        GS_BAPI_VENDOR        LIKE BAPIMEPOADDRVENDOR,
        GS_BAPI_EXPIMPHEADER  LIKE BAPIEIKP,
        GS_BAPI_EXPIMPHEADERX LIKE BAPIEIKPX,
        GT_BAPI_TEXTHEADER    LIKE BAPIMEPOTEXTHEADER OCCURS 0
                              WITH HEADER LINE,
        GT_BAPI_PARTNER       LIKE BAPIEKKOP          OCCURS 0
                              WITH HEADER LINE,
        GT_BAPI_ITEM          LIKE BAPIMEPOITEM       OCCURS 0
                              WITH HEADER LINE,
        GT_BAPI_ITEMX         LIKE BAPIMEPOITEMX      OCCURS 0
                              WITH HEADER LINE,
        GT_BAPI_SCHEDULE      LIKE BAPIMEPOSCHEDULE   OCCURS 0
                              WITH HEADER LINE,
        GT_BAPI_SCHEDULEX     LIKE BAPIMEPOSCHEDULX   OCCURS 0
                              WITH HEADER LINE,
        GT_BAPI_ACCOUNT       LIKE BAPIMEPOACCOUNT    OCCURS 0
                              WITH HEADER LINE,
        GT_BAPI_ACCOUNTX      LIKE BAPIMEPOACCOUNTX   OCCURS 0
                              WITH HEADER LINE,
        GT_BAPI_EXPIMPITEM    LIKE BAPIEIPO           OCCURS 0
                              WITH HEADER LINE,
        GT_BAPI_EXPIMPITEMX   LIKE BAPIEIPOX          OCCURS 0
                              WITH HEADER LINE,
        GT_BAPI_TEXTITEM      LIKE BAPIMEPOTEXT       OCCURS 0
                              WITH HEADER LINE,
        GT_BAPI_COND          LIKE BAPIMEPOCOND       OCCURS 0
                              WITH HEADER LINE,
        GT_BAPI_CONDX         LIKE BAPIMEPOCONDX      OCCURS 0
                              WITH HEADER LINE,
        GT_BAPI_EXTENSIONIN   LIKE BAPIPAREX          OCCURS 0
                              WITH HEADER LINE,
        GT_BAPI_EXTENSIONOUT  LIKE BAPIPAREX          OCCURS 0
                              WITH HEADER LINE,
        GT_RET1               LIKE BAPIRETURN         OCCURS 0
                              WITH HEADER LINE,
        GT_RET2               LIKE BAPIRET2           OCCURS 0
                              WITH HEADER LINE,
        GT_EBAN_DEL           LIKE BAPIEBAND          OCCURS 0
                              WITH HEADER LINE.

*& BAPI-재고관리 관련 구조 및 테이블 정의...
DATA  : GS_BAPI_GM_HEADER       LIKE BAPI2017_GM_HEAD_01,
        GS_BAPI_GM_CODE         LIKE BAPI2017_GM_CODE,
        GS_BAPI_GM_HEADRET      LIKE BAPI2017_GM_HEAD_RET,
        GT_BAPI_GM_ITEM         LIKE BAPI2017_GM_ITEM_CREATE OCCURS 0
                              WITH HEADER LINE,
        GT_BAPI_GM_SERIALNUMBER
                              LIKE BAPI2017_GM_SERIALNUMBER OCCURS 0
                              WITH HEADER LINE,
        GT_BAPI_GM_MATDOCITEM   LIKE BAPI2017_GM_ITEM_04 OCCURS 0
                              WITH HEADER LINE.


DATA  : GV_TESTRUN(1).                         "BAPI 테스트('X')

*& BDC관련 구조 및 테이블 정의...
DATA  : BEGIN OF GT_BDCDATA OCCURS 5.
          INCLUDE STRUCTURE BDCDATA.
DATA  : END   OF GT_BDCDATA.

DATA  : BEGIN OF GT_MSGCOLL OCCURS 1.
          INCLUDE STRUCTURE BDCMSGCOLL.
DATA  : END   OF GT_MSGCOLL.

DATA  : GS_BDCPARAMS LIKE CTU_PARAMS.           "BDC 매개변수

*& 도움말 생성관련 구조 및 테이블정의...
DATA  : GS_SELECTFIELD  LIKE HELP_INFO-FIELDNAME,
        GS_SELECT_VALUE LIKE HELP_INFO-FLDVALUE,
        GT_FIELD        LIKE HELP_VALUE OCCURS 0 WITH HEADER LINE,
        GT_DYNPREAD     LIKE DYNPREAD   OCCURS 0 WITH HEADER LINE,
        GT_DYNPUPDATE   TYPE DYNPREAD   OCCURS 0 WITH HEADER LINE.

*& Message dialog box용                                               *
DATA  : BEGIN OF GT_MSG  OCCURS 0.
          INCLUDE STRUCTURE ZTISMESSAGE.
DATA  : END   OF GT_MSG.

*& WHERE조건 테이블 정의...
DATA  : GT_WTAB(72) OCCURS 100 WITH HEADER LINE,
        GT_UCOMM    TYPE TABLE OF SY-UCOMM.

DATA  : GT_SELTAB    TYPE TABLE OF RSPARAMS,
        GS_SELTAB_WA LIKE LINE  OF GT_SELTAB.

*& RFC 연결을 의한 변수 선언...
DATA  : GV_RFCDEST TYPE RFCDEST,
        GV_RFCLOCL TYPE RFCDEST.

DATA  : GV_INDEX     LIKE SY-INDEX,
        GV_TABIX     LIKE SY-TABIX,
        GV_DBCNT     LIKE SY-DBCNT,
        GV_LILLI     LIKE SY-LILLI,
        GV_SUBRC     LIKE SY-SUBRC,
        GV_ANSWER(1) TYPE C,
        GV_ERROR(1)  TYPE C,
        GV_OKCODE    LIKE SY-UCOMM,
        OK_CODE      LIKE SY-UCOMM.

*& 설계번호 조회용 테이블
DATA  : BEGIN OF GT_SULNO OCCURS 0,
          SUL_NO    LIKE ZEDT1050-SUL_NO,
          REV_SEQ   LIKE ZEDT1050-REV_SEQ,
          GONG_SEQ1 LIKE ZEDT1050-GONG_SEQ,   "전공정 seq
          GONG_SEQ2 LIKE ZEDT1050-GONG_SEQ,   "본공정 seq
        END   OF GT_SULNO.

*& 설계내용 조회
TABLES: ZEDS110,
        ZEDS300,
        ZEDT1050.

DATA  : GT_ROUT TYPE TABLE OF ZEDS004,
        WA_ROUT TYPE ZEDS004,
        GT_WORK TYPE TABLE OF ZEDS005,
        WA_WORK TYPE ZEDS005,
        WA_S041 TYPE ZEDS041,
        GT_S041 TYPE TABLE OF ZEDS041.

DATA  : WA_S100 TYPE ZEDS100,
        WA_S110 TYPE ZEDS110,
        GT_S110 TYPE TABLE OF ZEDS110,
        WA_S120 TYPE ZEDS120,
        GT_S120 TYPE TABLE OF ZEDS120,
        WA_S140 TYPE ZEDS140,
        GT_S140 TYPE TABLE OF ZEDS140,
        WA_S150 TYPE ZEDS150,
        GT_S150 TYPE TABLE OF ZEDS150,
        WA_S160 TYPE ZEDS160,
        GT_S160 TYPE TABLE OF ZEDS160,
        WA_S165 TYPE ZEDS165,
        GT_S165 TYPE TABLE OF ZEDS165,
        WA_S170 TYPE ZEDS170,
        GT_S170 TYPE TABLE OF ZEDS170,
        WA_S180 TYPE ZEDS180,
        GT_S180 TYPE TABLE OF ZEDS180,
        WA_S043 TYPE ZEDS043,
        GT_S043 TYPE TABLE OF ZEDS043,
        WA_S044 TYPE ZEDS044 OCCURS 0 WITH HEADER LINE,
        GT_S044 TYPE TABLE OF ZEDS044,

        WA_S042 TYPE ZPPS042,
        GT_S042 TYPE TABLE OF ZPPS042.

TYPES : BEGIN OF TYPE_SRC,
          LINE(132) TYPE C,
        END   OF TYPE_SRC.

TYPE-POOLS: TCDAT.

DATA : WA_THEAD     LIKE THEAD,
       GT_TEXT      TYPE TABLE OF TYPE_SRC,
       WA_TEXT      TYPE TYPE_SRC,
       GT_LONG      LIKE TLINE OCCURS 0 WITH HEADER LINE,
       GT_XMSG      TYPE TCDAT_MSG_LIST,
       WA_XMSG      TYPE TCDAT_MSG,
       GT_MATNR_PRE LIKE TLINE OCCURS 0 WITH HEADER LINE, "전공정자재
       GT_LINE      LIKE TLINE OCCURS 0 WITH HEADER LINE. "설계내용

DATA  : GS_EDITOR     TYPE REF TO C_TEXTEDIT_CONTROL,
        GS_LINK_DYNNR LIKE SY-DYNNR.

CONSTANTS:
  CON_TEXTEDIT_MAXLINELENGTH TYPE I VALUE 178,
  CON_TEXTEDIT_CONTAINER(30) TYPE C VALUE 'CC_TEXTEDITOR'.

*& table to exchange text
DATA  : GS_TEXTEDIT_HEADER     LIKE THEAD.

DATA  : GT_TEXTEDIT_LINES(178) TYPE C OCCURS 0.

INCLUDE ZEDL1000.

DATA : G_BUKRS LIKE T001-BUKRS.
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BL1 WITH FRAME TITLE TEXT-001.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 33.
    PARAMETERS: P_PRBOX  AS   CHECKBOX.
    SELECTION-SCREEN COMMENT  35(08) TEXT-011 FOR FIELD P_PRBOX.

    SELECTION-SCREEN POSITION 47.
    PARAMETERS: P_POBOX  AS   CHECKBOX.
    SELECTION-SCREEN COMMENT  49(08) TEXT-012 FOR FIELD P_POBOX.

    SELECTION-SCREEN POSITION 61.
    PARAMETERS: P_CANCEL AS   CHECKBOX.
    SELECTION-SCREEN COMMENT  63(04) TEXT-013 FOR FIELD P_CANCEL.

    SELECTION-SCREEN POSITION 71.
    PARAMETERS: P_CONF   AS   CHECKBOX.
    SELECTION-SCREEN COMMENT  73(10) TEXT-014 FOR FIELD P_CANCEL.
  SELECTION-SCREEN END   OF LINE.

  SELECTION-SCREEN ULINE.
  PARAMETERS: P_WERKS  LIKE IOHEADER-WERKS    "플랜트
                            OBLIGATORY MEMORY ID WRK.

  SELECT-OPTIONS: S_DISPO   FOR   IOHEADER-DISPO    "MRP관리자
                                  OBLIGATORY MEMORY ID DGR
                                  NO INTERVALS,
                  S_PROCD   FOR   ZPPT0001-PROCD    "공정코드
                                  NO-EXTENSION
                                  NO INTERVALS,
                  S_MATNR   FOR   EBAN-MATNR,       "자재번호
                  S_AEDAT   FOR   EKPO-AEDAT,       "발주일자
                  S_LFDAT   FOR   EBAN-LFDAT,       "납품일자
                  S_LIFNR   FOR   EBAN-LIFNR        "거래처
*&                                OBLIGATORY MEMORY ID vag
                                  NO INTERVALS
                                  MODIF ID AAA,
                  S_EBELN   FOR   EKPO-EBELN        "구매오더
                                  MODIF ID AAA.

SELECTION-SCREEN END   OF BLOCK BL1.

*(S)기능 추가 관련(SJM 25.03.25)
SELECTION-SCREEN BEGIN OF BLOCK BK2 WITH FRAME TITLE TEXT-S02.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : P_ALL RADIOBUTTON GROUP GR1 MODIF ID CNF
                            USER-COMMAND EXE DEFAULT 'X'.
    SELECTION-SCREEN POSITION 6.
    SELECTION-SCREEN COMMENT (15) TEXT-R01 FOR FIELD P_ALL MODIF ID CNF.
    PARAMETERS : P_SBM RADIOBUTTON GROUP GR1 MODIF ID CNF.
    SELECTION-SCREEN POSITION 30.
    SELECTION-SCREEN COMMENT (15) TEXT-R02 FOR FIELD P_SBM MODIF ID CNF.
    PARAMETERS : P_APV RADIOBUTTON GROUP GR1 MODIF ID CNF.
    SELECTION-SCREEN POSITION 54.
    SELECTION-SCREEN COMMENT (15) TEXT-R03 FOR FIELD P_APV MODIF ID CNF.
  SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BK2.
*(S)기능 추가 관련(SJM 25.03.25)

SELECTION-SCREEN BEGIN OF BLOCK BL2 WITH FRAME TITLE TEXT-015.
  PARAMETERS:     P_VARI   LIKE DISVARIANT-VARIANT.
SELECTION-SCREEN END OF BLOCK BL2.
