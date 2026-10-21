*&---------------------------------------------------------------------*
*& Include ZGTMMR4111TOP
*&---------------------------------------------------------------------*

TABLES : LFA1, MKPF, SSCRFIELDS.


DATA : GS_FKEY TYPE SMP_DYNTXT.

DATA : BEGIN OF GT_HORP OCCURS 0, "ZGTMM_CV_SCSTOCKITEM_SUM
         BUKRS        LIKE T001-BUKRS,       "회사코드
         BUTXT        LIKE T001-BUTXT,       "회사명
         WERKS        LIKE MSLB-WERKS,       "플랜트
         PLANTNAME    LIKE T001W-NAME1,      "플랜트명
         LIFNR        LIKE MSLB-LIFNR,       "공급업체
         VENDORNAME   LIKE LFA1-NAME1,       "업체명
         MATNR        LIKE MSLB-MATNR,       "자재
         MAKTX        LIKE MAKT-MAKTX,       "자재명
         XPCBT        LIKE MCH1-XPCBT,       "단일배치
         CHARG        LIKE MSLB-CHARG,       "배치
         TAGNR        LIKE ZPPT0001-TAGNR,   "꼬리표
         LBLAB        LIKE MSLB-LBLAB,       "가용재고수량
         REQTY        LIKE MSEG-MENGE,       "환입수량
         MEINS        LIKE MSEG-MEINS,       "단위
         TOTALSCVALUE LIKE MSEG-SALK3,       "재고금액
         WAERS        LIKE MSEG-WAERS,       "통화
         TYPE         LIKE BAPIRET2-TYPE,    "상태
         MESSAGE      LIKE BAPIRET2-MESSAGE, "메시지 텍스트

         ERR(1),
         STYLE        TYPE LVC_T_STYL,
         COLOR        TYPE LVC_T_SCOL,
       END   OF GT_HORP.


DATA : BEGIN OF GT_HORD OCCURS 0, "ZGTMM_CV_MVT542_VENDOR_H
         MJAHR   LIKE MATDOC-MJAHR,  "연도
         MBLNR   LIKE MATDOC-MBLNR,  "자재문서번호
         BUKRS   LIKE MATDOC-BUKRS,  "회사코드
         BUKRS_N LIKE T001-BUTXT,    "회사명
         WERKS   LIKE MATDOC-WERKS,  "플랜트
         WERKS_N LIKE T001W-NAME1,   "플랜트명
         LGORT   LIKE MATDOC-LGORT,  "저장위치
         LGORT_N LIKE T001L-LGOBE,   "저장위치명
         LIFNR   LIKE MATDOC-LIFNR,  "공급업체
         LIFNR_N LIKE LFA1-NAME1,    "업체명
         BUDAT   LIKE MATDOC-BUDAT,  "전기일
         BLDAT   LIKE MATDOC-BLDAT,  "증빙일
         CPUDT   LIKE MATDOC-CPUDT,  "입력일
         CPUTM   LIKE MATDOC-CPUTM,
         USNAM   LIKE MATDOC-USNAM,  "담당자
         BKTXT   LIKE MATDOC-BKTXT,  "비고
       END   OF GT_HORD.

DATA : BEGIN OF GT_IORD OCCURS 0, "ZGTMM_CV_MVT542_VENDOR
         MJAHR LIKE MATDOC-MJAHR, "연도
         MBLNR LIKE MATDOC-MBLNR, "자재문서번호
         ZEILE LIKE MATDOC-ZEILE, "항번
         MATNR LIKE MATDOC-MATNR, "자재코드
         MAKTX LIKE MAKT-MAKTX,   "자재명
         CHARG LIKE MATDOC-CHARG, "배치번호
         MENGE LIKE MATDOC-MENGE, "출고수량
         MEINS LIKE MATDOC-MEINS, "단위
       END   OF GT_IORD.


DATA : GV_OKCODE LIKE SY-UCOMM,
       GV_TITLE  TYPE STRING.

DATA : GT_RTAB LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

DATA : GT_EXCD TYPE TABLE OF FCODE.

DATA : GV_CNT TYPE I.

DATA : GV_ERR,
       GV_REF,
       GV_XOSR.

DATA : BEGIN OF GS_XOSR,
         TXT01(50),
         BUDAT     LIKE SY-DATLO,
         REMARK    TYPE BKTXT,
       END   OF GS_XOSR.

DATA : GS_MHDR  LIKE BAPI2017_GM_HEAD_01,
       GS_MCOD  LIKE BAPI2017_GM_CODE,
       GS_MHDRT LIKE BAPI2017_GM_HEAD_RET,
       GT_MITM  LIKE BAPI2017_GM_ITEM_CREATE OCCURS 0 WITH HEADER LINE,
       GT_RTN   LIKE BAPIRET2                OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF GT_TAG OCCURS 0,
         WERKS  LIKE ZPPT0001-WERKS,
         TAGNR  LIKE ZPPT0001-TAGNR,
         CHARG  LIKE ZPPT0001-CHARG,
         MATNR  LIKE ZPPT0001-MATNR,
         REMAIN LIKE ZPPT0001-REMAIN,
         MEINS  LIKE ZPPT0001-MEINS,
       END   OF GT_TAG.

DATA : GV_REQTY LIKE ZPPT0001-REMAIN.

FIELD-SYMBOLS : <GFS_COL> TYPE LVC_T_SCOL.


CONSTANTS : GC_A(1)           VALUE 'A',
            GC_C(1)           VALUE 'C',
            GC_D(1)           VALUE 'D',
            GC_E(1)           VALUE 'E',
            GC_I(1)           VALUE 'I',
            GC_N(1)           VALUE 'N',
            GC_O(1)           VALUE 'O',
            GC_P(1)           VALUE 'P',
            GC_S(1)           VALUE 'S',
            GC_X(1)           VALUE 'X',
            GC_Y(1)           VALUE 'Y',
            GC_0(1)           VALUE '0',
            GC_2(1)           VALUE '2',
            GC_6(1)           VALUE '6',
            GC_BT(2)          VALUE 'BT',
            GC_MM(2)          VALUE 'MM',
            GC_OD(2)          VALUE 'OD',
            GC_04(2)          VALUE '04',
            GC_HGH(3)         VALUE 'HGH',
            GC_ORP(3)         VALUE 'ORP',
            GC_RMK(3)         VALUE 'RMK',
            GC_VPU(3)         VALUE 'VPU',
            GC_004(3)         VALUE '004',
            GC_005(3)         VALUE '005',
            GC_542(3)         VALUE '542',
            GC_0200(4)        VALUE '0200',
            GC_1000(4)        VALUE '1000',
            GC_COLOR(5)       VALUE 'COLOR',
            GC_STYLE(5)       VALUE 'STYLE',
            GC_TAGNR(5)       VALUE 'TAGNR',
            GC_ZGTMMR4111(10) VALUE 'ZGTMMR4111'.


*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
SELECTION-SCREEN : FUNCTION KEY 1.

"향후 권한 연동하여 User별 Defalut 값 관리시 Display 필드로 변경(BUKRS/WERKS/LGORT)
SELECTION-SCREEN BEGIN OF BLOCK BK1 WITH FRAME TITLE TEXT-S01.
  PARAMETERS     : P_BUKRS LIKE T001-BUKRS,
                   P_WERKS LIKE T001L-WERKS,
                   P_LGORT LIKE T001L-LGORT.
  SELECT-OPTIONS : S_LIFNR  FOR LFA1-LIFNR,
                   S_BUDAT  FOR MKPF-BUDAT MODIF ID ORP.
SELECTION-SCREEN END   OF BLOCK BK1.

SELECTION-SCREEN BEGIN OF BLOCK BK2 WITH FRAME TITLE TEXT-S02.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : P_ORP RADIOBUTTON GROUP GR1 DEFAULT 'X'
                                        USER-COMMAND EXE.
    SELECTION-SCREEN POSITION 6.
    SELECTION-SCREEN COMMENT (15) TEXT-R01 FOR FIELD P_ORP.
    PARAMETERS : P_ORD RADIOBUTTON GROUP GR1.
    SELECTION-SCREEN POSITION 30.
    SELECTION-SCREEN COMMENT (15) TEXT-R02 FOR FIELD P_ORD.
  SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BK2.
