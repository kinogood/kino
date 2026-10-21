*&---------------------------------------------------------------------*
*& Include          ZGTSDR1300TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   TABLES
*----------------------------------------------------------------------*
TABLES : VBAK,
         VBAP,
         VBPA,
         VBKD,
         LIKP,
         LIPS,
         VBCOM,
         S006,
         T179T,
         VTTK,
         VBUK,
         VBEP,
         ZSD0098T,
         T052U.

*----------------------------------------------------------------------*
*   DATA
*----------------------------------------------------------------------*
** 최종 리스트 INTERNAL TABLE
DATA : BEGIN OF G_ITAB_T OCCURS 0,
         VBELN          LIKE  VBAK-VBELN,           "영업문서
         POSNR          LIKE  VBAP-POSNR,           "품목번호
         AUART          LIKE  VBAK-AUART,           "주문유형
         KUNNR          LIKE  VBAK-KUNNR,           "고객
         NAME1          LIKE  KNA1-NAME1,           "고객명
         KUNNR_SH       LIKE  VBPA-KUNNR,           "인도처
         NAME1_SH       LIKE  KNA1-NAME1,           "인도처명
*-- 기능개선 211276 - 지급처, 구매오더번호 추가 {
         KUNNR_PY       LIKE  VBPA-KUNNR,           "지급처
         NAME1_PY       LIKE  KNA1-NAME1,           "지급처명
*-- } 기능개선 211276_2017.11.07
         MATNR          LIKE  VBAP-MATNR,           "자재
         MAKTX          LIKE  MAKT-MAKTX,           "자재내역
         PRODH          LIKE  VBAP-PRODH,           "제품계층구조
         WERKS          LIKE  VBAP-WERKS,           "플랜트
         VKORG          LIKE  VBAK-VKORG,           "영업조직
         VTWEG          LIKE  VBAK-VTWEG,           "유통경로
         VDATU          LIKE  VBAK-VDATU,           "납품요청일
         KWMENG         LIKE  VBAP-KWMENG,          "오더수량
         KBMENG         LIKE  VBAP-KBMENG,          "확정수량
         ABGRU          LIKE  VBAP-ABGRU,           "거절사유
         BEZEI          LIKE  TVAGT-BEZEI,          "거절사유NAME
         VBELN_VL       LIKE  LIKP-VBELN,           "납품번호
         POSNR_VL       LIKE  LIPS-POSNR,           "납품품목
         TKNUM          LIKE  VTTK-TKNUM,           "선적번호
         VBELN_GI       LIKE  VBFA-VBELN,           "출고전기번호
         LFIMG          LIKE  LIPS-LFIMG,           "납품수량
         RFMNG          LIKE  VBFA-RFMNG,           "피킹수량
         WADAT_IST      LIKE  LIKP-WADAT_IST,       "출고전기일
         VBELN_VF       LIKE  VBRK-VBELN,           "빌링번호
         SPART          LIKE  VBAK-SPART,           "제품군
         VKBUR          LIKE  VBAK-VKBUR,           "사업장
         VKGRP          LIKE  VBAK-VKGRP,           "영업그룹
         LIFNR          LIKE  VBPA-LIFNR,           "영업사원
*-> CCM : 27.07.2023 11:36:08 / ZLSGSD3
         ENAME          LIKE  ZZPA0001-ENAME,       "기능개선 323173 - 추가
*         ENAME     LIKE  PA0001-ENAME,         "기능개선 323173 - 추가
*<-
         ERNAM          LIKE  VBAK-ERNAM,           "사용자ID
         NETPR          LIKE  VBAP-NETPR,           "단가
         WAERK          LIKE  VBAP-WAERK,           "통화키
         KNUMV          LIKE  VBAK-KNUMV,           "문서조건번호
         VRKME          LIKE  VBAP-VRKME,           "판매단위
         ERDAT          LIKE  VBAK-ERDAT,           "레코드생성일
         ERZET          LIKE  VBAK-ERZET,           "입력시간
         ADRNR          LIKE  VBPA-ADRNR,           "주소번호
         PSTYV          LIKE  VBAP-PSTYV,           "Item Category
         PROD1(40),                            "제품계층구조1
         PROD2(40),                            "제품계층구조2
         PROD3(40),                            "제품계층구조3
         VSTEL          LIKE  VBAP-VSTEL,           "출하지점
         BRGEW          LIKE  VBAP-BRGEW,           "중량
         MATKL          LIKE  VBAP-MATKL,           "자재그룹
         KODAT          LIKE  LIKP-KODAT,           "납품생성일
         LDDAT          LIKE  LIKP-LDDAT,           "적하일
         ETENR          LIKE  VBEP-ETENR,           "일정라인
         EDATU          LIKE  VBEP-EDATU,           "주문도착일(시스템납품일)
         EZEIT          LIKE  VBEP-EZEIT,           "주문도착시간
         MBDAT          LIKE  VBEP-MBDAT,           "자재가용일
         LFDAT          LIKE  LIKP-LFDAT,           "납품도착일
         LFUHR          LIKE  LIKP-LFUHR,           "납품도착시간
         WADAT          LIKE  LIKP-WADAT,           "계획G.I
         FKDAT          LIKE  VBRK-FKDAT,           "대금청구일
         ERDAT2         LIKE  VTTK-ERDAT,           "선적생성일
         NETWR          LIKE  VBAP-NETWR,           "오더금액
         DIFF_DATE      TYPE  I,                    "오더확정차이일
         AUGRU          LIKE  VBAK-AUGRU,           "오더사유
         BEZEI2         LIKE  TVAUT-BEZEI,          "오더사유TEXT
         KUNNR_SB       LIKE  VBPA-KUNNR,           "특별재고파트너
         LTRMP          LIKE  AFPO-LTRMP,           "생산계획일
         LTRMI          LIKE  AFPO-LTRMI,           "입고일
         LGORT          LIKE  LIPS-LGORT,           "저장위치
         BSTKD          LIKE  VBKD-BSTKD,           "FILE번호
         KOSTK          LIKE  VBUK-KOSTK,           "피킹관련성
         KOSTK_TEXT(19),                       "피킹설명
         TKNUM_SEA      LIKE  VTTK-TKNUM,           "해상선적번호
         TKNUM2         LIKE  VTTP-TKNUM,           "준비구간선적번호
         TPNUM2         LIKE  VTTP-TPNUM,           "준비구간선적품목번호
         FKNUM          LIKE  VFKP-FKNUM,           "선적비용번호
         ERZET2         LIKE  LIKP-ERZET,           "납품생성시간
         SIGNI          LIKE  VTTK-SIGNI,           "차량번호
         WBSTK          LIKE  VBUK-WBSTK,           "전체상품이동상태
         ROUTE          LIKE  LIKP-ROUTE,           "운송경로
         TPLST          LIKE  VTTK-TPLST,           "운송계획지점
         LFART          LIKE  LIKP-LFART,           "납품유형
         ERZET3         LIKE  VTTK-ERZET,           "선적생성시간
         UZDIS          LIKE  VTTK-UZDIS,           "계획시간
         UAREG          LIKE  VTTK-UAREG,           "체크인시간
         BTGEW          LIKE  LIKP-BTGEW,           "납품중량
         CPUTM          LIKE  MKPF-CPUTM,           "G/I시간
         VKBUR_TEXT     LIKE TVKBT-BEZEI,          "사업장명
         VKGRP_TEXT     LIKE TVGRT-BEZEI,          "영업그룹명
         WERKS_TEXT     LIKE T001W-NAME1,          "플랜트명
         VSTEL_TEXT     LIKE TVSTT-VTEXT,          "출하지점명
         ROUTE_TEXT     LIKE TVROT-BEZEI,          "운송경로명
         KUNNR_SB_TEXT  LIKE KNA1-NAME1,        "특별재고파트너명

         ZPJNO          LIKE VBAK-ZPJNO,            "프로젝트No
         ZPTXT          LIKE ZSD0106T-ZPTXT,        "프로젝트명
         SPART2         LIKE VBAP-SPART,            "품목별제품군

         CUOBJ          LIKE VBAP-CUOBJ,            "조장수특성값
         VALUE1         LIKE CUXE1CUVAL-VALUE,      "조장수
         VALUE2         LIKE CUXE1CUVAL-VALUE,      "개별길이
         VALUE3         LIKE CUXE1CUVAL-VALUE,      "색상
         VALUE4         LIKE CUXE1CUVAL-VALUE,      "입회검사유무
         VALUE5         LIKE CUXE1CUVAL-VALUE,      "절연선심식별
         VALUE6         LIKE CUXE1CUVAL-VALUE,      "튜브 인쇄사양 SRM2404-07578

         VALUE7         LIKE CUXE1CUVAL-VALUE,      "STRIPE
         VALUE8         LIKE CUXE1CUVAL-VALUE,      "띄줄수

         ORDID          LIKE ZSD0098T-ORDID,        "생산오더번호
         SOSTAT         LIKE ZSD0098T-SOSTAT,       "판매오더시작일
         SOEND          LIKE ZSD0098T-SOEND,        "판매오더종료일
         OPRTX          LIKE ZSD0098T-OPRTX,        "공정진행Status
         OPSTAT         LIKE ZSD0098T-SOSTAT,       "현공정오더시작일
         OPEND          LIKE ZSD0098T-SOEND,        "현공정오더완료일
         CHARG          LIKE ZSD0098T-CHARG,        "Batch
         CHARG_V        LIKE VBAP-CHARG,               "오더배치번호 CHM2009-00236
         MENGE          LIKE ZSD0098T-MENGE,        "입고수량
         BUDAT          LIKE MKPF-BUDAT,            "입고일

         DPTEN          LIKE VTTK-DPTEN,            "선적종료계획
         UPTEN          LIKE VTTK-UPTEN,            "선적종료계획시간

         ZLFIMG         LIKE ZLET0002-LFIMG,        "절단지시수량
         JISIDAT        LIKE ZLET0002-JISIDAT,      "절단지시일
         CUTSDAT        LIKE ZLET0002-CUTSDAT,      "절단완료일

*** 동량 추가
         CU_QTY         LIKE  VBAP-BRGEW,           "동량
         AL_QTY         LIKE  VBAP-BRGEW,           "AL량

* 현재재고를 가져오기 위한 추가 변수
         SOBKZ          LIKE  VBAP-SOBKZ,           "특별재고지시자
         XCHPF          LIKE  VBAP-XCHPF,           "배치지시자
         CLABS          LIKE  MCHB-CLABS,           "현재고
         N_CLABS(20)    TYPE C,                   "현재고 수량을 N TYPE

         MARK,
*__  JS전선 호선반영
         ZPROJECT       LIKE VBAK-ZPROJECT,         "호선

* CSR Number : C20080218_18635 필드 추가
         ZZMAKTX80      LIKE  MARA-ZZMAKTX80,       "상세 품명 FIELD
* CSR Number : C20080218_18635

* CSR Number : C20081226_77528 드럼 번호 필드 추가
         EMPST          LIKE  VBKD-EMPST,       "드럼번호 FIELD
* CSR Number : C20081226_77528
         PACKING_DM     LIKE ZEDT0230-PACKING_DM,  "드럼포장재_hoi
         PACKING_DM_NM  LIKE MAKT-MAKTX,
*-{기능개선175813_추가
         KDMAT          LIKE VBAP-KDMAT,        "고객자재
         BSTKD_E        LIKE VBKD-BSTKD_E,      "납품처 구매오더번호
*-}기능개선175813_2016.12.29
         SOTEXT(100),          "기능개선178174 "오더 텍스트
**-{기능개선 314430
         SCR_GRADE      LIKE  AUSP-ATWRT,                "등급
         ZTERM          LIKE  VBKD-ZTERM,           "지급(수금) 조건
         TEXT1          LIKE  T052U-TEXT1,          "지급조건 텍스트
         PRCTR          LIKE  VBAP-PRCTR,           "손익센터
         LAND1          LIKE  KNA1-LAND1,           "고객 국가
**-} 기능개선 314430
       END OF G_ITAB_T.

DATA : BEGIN OF G_TMP_T OCCURS 0.
         INCLUDE STRUCTURE G_ITAB_T.
DATA : END OF G_TMP_T.

** 오더 INTERNAL TABLE
DATA : BEGIN OF G_ITSO_T OCCURS 0,
         VBELN     LIKE  VBAK-VBELN,           "영업문서
         POSNR     LIKE  VBAP-POSNR,           "품목번호
         AUART     LIKE  VBAK-AUART,           "주문유형
         KUNNR     LIKE  VBAK-KUNNR,           "고객
         NAME1     LIKE  KNA1-NAME1,           "고객명
         KUNNR_SH  LIKE  VBPA-KUNNR,           "인도처
         NAME1_SH  LIKE  KNA1-NAME1,           "인도처명
*-- 기능개선 211276 - 지급처, 구매오더번호 추가 {
         KUNNR_PY  LIKE  VBPA-KUNNR,           "지급처
         NAME1_PY  LIKE  KNA1-NAME1,           "지급처명
*-- } 기능개선 211276_2017.11.07
         MATNR     LIKE  VBAP-MATNR,           "자재
         MAKTX     LIKE  MAKT-MAKTX,           "자재내역
         PRODH     LIKE  VBAP-PRODH,           "제품계층구조
         WERKS     LIKE  VBAP-WERKS,           "플랜트
         VKORG     LIKE  VBAK-VKORG,           "영업조직
         VTWEG     LIKE  VBAK-VTWEG,           "유통경로
         VDATU     LIKE  VBAK-VDATU,           "납품요청일
         KWMENG    LIKE  VBAP-KWMENG,          "오더수량
         KBMENG    LIKE  VBAP-KBMENG,          "확정수량
         ABGRU     LIKE  VBAP-ABGRU,           "거절사유
         BEZEI     LIKE  TVAGT-BEZEI,          "거절사유 NAME
         SPART     LIKE  VBAK-SPART,           "제품군
         VKBUR     LIKE  VBAK-VKBUR,           "사업장
         VKGRP     LIKE  VBAK-VKGRP,           "영업그룹
         LIFNR     LIKE  VBPA-LIFNR,           "영업사원
         ERNAM     LIKE  VBAK-ERNAM,           "사용자ID
         NETPR     LIKE  VBAP-NETPR,           "단가
         WAERK     LIKE  VBAP-WAERK,           "통화키
         KNUMV     LIKE  VBAK-KNUMV,           "문서조건번호
         VRKME     LIKE  VBAP-VRKME,           "판매단위
         ERDAT     LIKE  VBAK-ERDAT,           "레코드생성일
         ERZET     LIKE  VBAK-ERZET,           "입력시간
         ADRNR     LIKE  VBPA-ADRNR,           "주소번호
         PSTYV     LIKE  VBAP-PSTYV,           "Item Category
         PROD1(40),                            "제품계층구조1
         PROD2(40),                            "제품계층구조2
         PROD3(40),                            "제품계층구조3
         VSTEL     LIKE  VBAP-VSTEL,           "출하지점
         BRGEW     LIKE  VBAP-BRGEW,           "중량
         MATKL     LIKE  VBAP-MATKL,           "자재그룹
         ETENR     LIKE  VBEP-ETENR,           "일정라인
         EDATU     LIKE  VBEP-EDATU,           "주문도착일(시스템납품일)
         EZEIT     LIKE  VBEP-EZEIT,           "주문도착시간
         MBDAT     LIKE  VBEP-MBDAT,           "자재가용일
         NETWR     LIKE  VBAP-NETWR,           "오더금액
         AUGRU     LIKE  VBAK-AUGRU,           "오더사유
         ZPJNO     LIKE  VBAK-ZPJNO,           "프로젝트No
         SPART2    LIKE  VBAP-SPART,           "품목별제품군
         CHARG_V   LIKE VBAP-CHARG,               "오더배치번호 CHM2009-00236

         CUOBJ     LIKE VBAP-CUOBJ,            "조장수특성값

*->  01.02.2024 15:59:26 / ZLSGSD2

         VALUE1    LIKE CUXE1CUVAL-VALUE,      "조장수
         VALUE2    LIKE CUXE1CUVAL-VALUE,      "개별길이
         VALUE3    LIKE CUXE1CUVAL-VALUE,      "색상
         VALUE4    LIKE CUXE1CUVAL-VALUE,      "입회검사유무
         VALUE5    LIKE CUXE1CUVAL-VALUE,      "절연선심식별
         VALUE6    LIKE CUXE1CUVAL-VALUE,      "튜브 인쇄사양 SRM2404-07578

         VALUE7    LIKE CUXE1CUVAL-VALUE,      "STRIPE
         VALUE8    LIKE CUXE1CUVAL-VALUE,      "띄줄수


         SOBKZ     LIKE VBAP-SOBKZ,            "특별재고지시자
         XCHPF     LIKE VBAP-XCHPF,            "배치지시자
*__  JS전선 호선반영
         ZPROJECT  LIKE VBAK-ZPROJECT,         "호선
* CSR Number : C20080218_18635 필드 추가
         ZZMAKTX80 LIKE MARA-ZZMAKTX80,        "상세 품명 FIELD
* CSR Number : C20080218_18635
**-{기능개선 314430
         ZTERM     LIKE  VBKD-ZTERM,           "지급(수금) 조건
         TEXT1     LIKE  T052U-TEXT1,          "지급조건 텍스트
         PRCTR     LIKE  VBAP-PRCTR,           "손익센터
         LAND1     LIKE  KNA1-LAND1,           "고객 국가
**-} 기능개선 314430
         KDMAT     LIKE VBAP-KDMAT,        "고객자재
         SCR_GRADE LIKE AUSP-ATWRT,                "등급
       END OF G_ITSO_T.

** DELIVERY INTERNAL TABLE
DATA : BEGIN OF G_ITDL_T OCCURS 0,
         VBELN_VL  LIKE  LIKP-VBELN,           "납품번호
         POSNR_VL  LIKE  LIPS-POSNR,           "납품품목
         TKNUM     LIKE  VTTK-TKNUM,           "선적번호
         VBELN_GI  LIKE  VBFA-VBELN,           "출고전기번호
         LFIMG     LIKE  LIPS-LFIMG,           "납품수량
         RFMNG     LIKE  VBFA-RFMNG,           "피킹수량
         WADAT_IST LIKE  LIKP-WADAT_IST,       "출고전기일
         VBELN_VF  LIKE  VBRK-VBELN,           "빌링번호
         KODAT     LIKE  LIKP-KODAT,           "납품생성일
         LDDAT     LIKE  LIKP-LDDAT,           "적하일
         LFDAT     LIKE  LIKP-LFDAT,           "납품도착일
         LFUHR     LIKE  LIKP-LFUHR,           "납품도착시간
         WADAT     LIKE  LIKP-WADAT,           "계획G.I
         FKDAT     LIKE  VBRK-FKDAT,           "대금청구일
         LGORT     LIKE  LIPS-LGORT,           "저장위치
         ERZET2    LIKE  LIKP-ERZET,           "납품생성시간
         ROUTE     LIKE  LIKP-ROUTE,           "운송경로
         LFART     LIKE  LIKP-LFART,           "납품유형
         BTGEW     LIKE  LIKP-BTGEW,           "납품중량
         KOSTK     LIKE  LIKP-KOSTK,           "피킹상태
         WBSTK     LIKE  LIKP-WBSTK,           "출고전기상태
       END OF G_ITDL_T.

* 화면에 입력된 값을 읽어들이기 위한 INTERNAL TABLE
DATA : BEGIN OF G_DYNPFIELDS_T OCCURS 0.
         INCLUDE STRUCTURE DYNPREAD.
DATA : END OF G_DYNPFIELDS_T.

* 제품군 POSSIBLE ENTRY ITAB.
DATA : BEGIN OF G_VALUES2_T OCCURS 0,
         SPART LIKE TVTA-SPART,
         VTEXT LIKE TSPAT-VTEXT,
       END OF G_VALUES2_T.

DATA : G_TOTCNT  TYPE I,
       G_CNT     TYPE I,
       G_MSG(50),
       G_RATIO   TYPE I.

DATA : G_LINEN(3)     TYPE N,
       G_OUT_TEXT(70) TYPE C.

* 특별재고 지시자 : MTO, MTS 구분하기 위해 사용
RANGES: R_SOBKZ FOR LIPS-SOBKZ.

*-{기능개선178174 - 추가
* READ_TEXT
DATA: WA_THEAD LIKE THEAD,
      TDTEXT   TYPE TLINE OCCURS 0 WITH HEADER LINE.
*-}기능개선178174_2017.01.12

*{ SRM2404-10815 - 추가_S
DATA: GT_VTTK  LIKE VTTK  OCCURS 0 WITH HEADER LINE,
      GT_TVAUT LIKE TVAUT OCCURS 0 WITH HEADER LINE,
      GT_TVKBT LIKE TVKBT OCCURS 0 WITH HEADER LINE,
      GT_TVGRT LIKE TVGRT OCCURS 0 WITH HEADER LINE,
      GT_TVSTT LIKE TVSTT OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF GT_VBEP OCCURS 0,
        VBELN LIKE VBEP-VBELN,
        POSNR LIKE VBEP-POSNR,
        EDATU LIKE VBEP-EDATU,
      END   OF GT_VBEP.

DATA: BEGIN OF GT_VBPA OCCURS 0,
        VBELN LIKE VBPA-VBELN,
        POSNR LIKE VBPA-POSNR,
        PARVW LIKE VBPA-PARVW,
        KUNNR LIKE VBPA-KUNNR,
        LIFNR LIKE VBPA-LIFNR,
        ADRNR LIKE VBPA-ADRNR,
        NAME1 LIKE KNA1-NAME1,
        NAME2 LIKE LFA1-NAME1,
        NAMAD LIKE ADRC-NAME1,
      END   OF GT_VBPA.

DATA: BEGIN OF GT_AFPO OCCURS 0,
        KDAUF LIKE AFPO-KDAUF,
        KDPOS LIKE AFPO-KDPOS,
        AUFNR LIKE AFPO-AUFNR,
        POSNR LIKE AFPO-POSNR,
        LTRMP LIKE AFPO-LTRMP,
        LTRMI LIKE AFPO-LTRMI,
      END   OF GT_AFPO.

DATA: BEGIN OF GT_VBKD OCCURS 0,
        VBELN   LIKE VBKD-VBELN,
        POSNR   LIKE VBKD-POSNR,
        BSTKD   LIKE VBKD-BSTKD,
        EMPST   LIKE VBKD-EMPST,
        BSTKD_E LIKE VBKD-BSTKD_E,
        ZTERM   LIKE VBKD-ZTERM,
      END   OF GT_VBKD.

DATA: BEGIN OF GT_VTTP OCCURS 0,
        VBELN LIKE VTTP-VBELN,
        TKNUM LIKE VTTP-TKNUM,
        TPNUM LIKE VTTP-TPNUM,
        SHTYP LIKE VTTK-SHTYP,
      END   OF GT_VTTP.

DATA: BEGIN OF GT_VFKP OCCURS 0,
        REBEL LIKE VFKP-REBEL,
        REPOS LIKE VFKP-REPOS,
        FKNUM LIKE VFKP-FKNUM,
      END   OF GT_VFKP.

DATA: BEGIN OF GT_0230 OCCURS 0,
        VBELN      LIKE ZEDT0230-VBELN,
        POSNR      LIKE ZEDT0230-POSNR,
        PACKING_DM LIKE ZEDT0230-PACKING_DM,
        MAKTX      LIKE MAKT-MAKTX,
      END   OF GT_0230.

DATA: BEGIN OF GT_MARA OCCURS 0,
        MATNR     LIKE MARA-MATNR,
        ZZMAKTX80 LIKE MARA-ZZMAKTX80,
        MAKTX     LIKE MAKT-MAKTX,
      END   OF GT_MARA.

DATA: BEGIN OF GT_TVAGT OCCURS 0,
        ABGRU LIKE TVAGT-ABGRU,
        BEZEI LIKE TVAGT-BEZEI,
      END   OF GT_TVAGT.

DATA: BEGIN OF GT_T179T OCCURS 0,
        PRODH LIKE T179T-PRODH,
        VTEXT LIKE T179T-VTEXT,
      END   OF GT_T179T.

DATA: BEGIN OF GT_T052U OCCURS 0,
        ZTERM LIKE T052U-ZTERM,
        TEXT1 LIKE T052U-TEXT1,
      END   OF GT_T052U.

DATA: BEGIN OF GT_KNA1 OCCURS 0,
        KUNNR LIKE KNA1-KUNNR,
        LAND1 LIKE KNA1-LAND1,
      END   OF GT_KNA1.

DATA: BEGIN OF GT_MKPF OCCURS 0,
        MBLNR LIKE MKPF-MBLNR,
        MJAHR LIKE MKPF-MJAHR,
        CPUTM LIKE MKPF-CPUTM,
      END   OF GT_MKPF.

DATA: BEGIN OF GT_T001W OCCURS 0,
        WERKS LIKE T001W-WERKS,
        NAME1 LIKE T001W-NAME1,
      END   OF GT_T001W.

DATA: BEGIN OF GT_TVROT OCCURS 0,
        ROUTE LIKE TVROT-ROUTE,
        BEZEI LIKE TVROT-BEZEI,
      END   OF GT_TVROT.

DATA: BEGIN OF GT_0106 OCCURS 0,
        ZPJNO LIKE ZSD0106T-ZPJNO,
        ZPTXT LIKE ZSD0106T-ZPTXT,
      END   OF GT_0106.

DATA: BEGIN OF GT_GRADE OCCURS 0,
        VBELN     TYPE VBELN,
        POSNR     TYPE POSNR,
        WERKS     TYPE WERKS_D,
        SCR_GRADE TYPE ATWRT,
      END   OF GT_GRADE.

DATA: GT_ORDS    TYPE TABLE OF ZCHARORDS,
      GT_ORDVALS TYPE TABLE OF ZCHARVALS,
      GR_ATNAMO  TYPE TABLE OF EAMPIC_SEL_ATNAM.
*} SRM2404-10815 - 추가_E

DATA: BEGIN OF GT_VTTK_SEA OCCURS 0,
        VBELN LIKE VTTP-VBELN,
        VSBED LIKE LIKP-VSBED,
        TKNUM LIKE VTTK-TKNUM,
        SHTYP LIKE VTTK-SHTYP,
      END OF GT_VTTK_SEA.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS: GC_VKORG_6000 TYPE VKORG   VALUE '6000',
           GC_VTWEG_10   TYPE VTWEG   VALUE '10',
           GC_VTWEG_50   TYPE VTWEG   VALUE '50',
           GC_SPART_3C   TYPE SPART   VALUE '3C',
           GC_SPART_4C   TYPE SPART   VALUE '4C',
           GC_SPART_90   TYPE SPART   VALUE '90'.
CONSTANTS: GC_KRW        TYPE WAERK   VALUE 'KRW'.

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
