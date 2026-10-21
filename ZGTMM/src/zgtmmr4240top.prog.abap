*&---------------------------------------------------------------------*
*& Include ZGTMMR4240TOP
*&---------------------------------------------------------------------*

TABLES : MARC.


DATA : GV_CDATE LIKE SY-DATLO,
       GR_WERKS TYPE RANGE OF MARC-WERKS.

DATA : BEGIN OF GT_WERKS OCCURS 0,
         WERKS LIKE T001W-WERKS,
       END   OF GT_WERKS.


DATA : BEGIN OF GT_LIST OCCURS 0, "ZGTMM_CV_SUITABLE_STOCK_W
         TIMESTAMP     LIKE ZGTMMT4220-TIMESTAMP,     "TimeStamp
         BUKRS         LIKE ZGTMMT4220-BUKRS,         "회사코드
         BUKRS_N       LIKE T001-BUTXT,               "회사명
         WERKS         LIKE ZGTMMT4220-WERKS,         "플랜트
         WERKS_N       LIKE T001W-NAME1,              "플랜트명
         MATNR         LIKE ZGTMMT4220-MATNR,         "자재
         MATNR_N       LIKE MAKT-MAKTX,               "자재명
         LT            LIKE ZGTMMT4220-LT,            "LeadTime
         SERVICEFACTOR LIKE ZGTMMT4220-SERVICEFACTOR, "Factor
         REQQTY        LIKE ZGTMMT4221-REQQTY,        "총소요량
         MEINS         LIKE ZGTMMT4221-MEINS,         "단위
         REQ_DAILY     LIKE ZGTMMT4221-REQ_DAILY,     "일소요량
         UNQTY         LIKE ZGTMMT4220-UNQTY,         "창고재고
         BONDEDQTY     LIKE ZGTMMT4220-BONDEDQTY,     "보세재고
         TOTALQTY      LIKE ZGTMMT4220-UNQTY,         "재고합계
         STOCKVAL      LIKE ZGTMMT4220-STOCKVAL,      "현재고액
         WAERS         LIKE ZGTMMT4220-WAERS,         "통화
         F1            LIKE ZGTMMT4220-F1,            "LT/7
         F2            LIKE ZGTMMT4221-F2,            "최종평균
         F1_SQRT       LIKE ZGTMMT4220-F1_SQRT,       "SQRT(LT/7)
         F2_SQRT       LIKE ZGTMMT4221-F2_SQRT,       "표준편차
         SAFTY_QTY     LIKE ZGTMMT4221-SAFTY_QTY,     "안전재고
         SU_QTY        LIKE ZGTMMT4221-SU_QTY,        "적정재고
         SU_QTY_UNDER  LIKE ZGTMMT4221-SU_QTY,        "적정재고(-10%)
         SU_QTY_OVER   LIKE ZGTMMT4221-SU_QTY,        "적정재고(+10%)
         DIFF          LIKE ZGTMMT4220-UNQTY,         "현재고-적정재고
         PLANWEEK      LIKE ZGTMMT4220-PLANWEEK,      "계획주차
         TYPE          LIKE ZGTMMT4221-TYPE,          "라인구분
         TYPENAME      LIKE DD07T-DDTEXT,             "구분명
         W0            LIKE ZGTMMT4221-W0,            "W0
         W1            LIKE ZGTMMT4221-W1,            "W1
         W2            LIKE ZGTMMT4221-W2,            "W2
         W3            LIKE ZGTMMT4221-W3,            "W3
         W4            LIKE ZGTMMT4221-W4,            "W4
         W5            LIKE ZGTMMT4221-W5,            "W5
         W6            LIKE ZGTMMT4221-W6,            "W6
         W7            LIKE ZGTMMT4221-W7,            "W7
         W8            LIKE ZGTMMT4221-W8,            "W8
         W9            LIKE ZGTMMT4221-W9,            "W9
         W10           LIKE ZGTMMT4221-W10,           "W10
         W11           LIKE ZGTMMT4221-W11,           "W11
         W12           LIKE ZGTMMT4221-W12,           "W12
         W13           LIKE ZGTMMT4221-W13,           "W13
         W14           LIKE ZGTMMT4221-W14,           "W14
         W15           LIKE ZGTMMT4221-W15.           "W15
         INCLUDE STRUCTURE ZGTMMS0000.
DATA :   DAILYLAST(1),                                "최종데이터
         R_COL(4),
         C_COL         TYPE LVC_T_SCOL,
       END   OF GT_LIST.

DATA : GV_CNT TYPE I,
       GV_ERR,
       GV_REF.

DATA : GV_FNM TYPE LVC_FNAME.

DATA : GV_OKCODE LIKE SY-UCOMM.


CONSTANTS : GC_A(1)       VALUE 'A',
            GC_B(1)       VALUE 'B',
            GC_C(1)       VALUE 'C',
            GC_D(1)       VALUE 'D',
            GC_F(1)       VALUE 'F',
            GC_G(1)       VALUE 'G',
            GC_H(1)       VALUE 'H',
            GC_I(1)       VALUE 'I',
            GC_J(1)       VALUE 'J',
            GC_L(1)       VALUE 'L',
            GC_X(1)       VALUE 'X',
            GC_2(1)       VALUE '2',
            GC_EQ(2)      VALUE 'EQ',
            GC_C200(4)    VALUE 'C200',
            GC_C700(4)    VALUE 'C700',
            GC_C_COL(5)   VALUE 'C_COL',
            GC_R_COL(5)   VALUE 'R_COL',
            GC_P_VERSN(7) VALUE 'P_VERSN'.


*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
"향후 권한 연동하여 User별 Defalut 값 관리시 Display 필드로 변경(WERKS)
SELECTION-SCREEN BEGIN OF BLOCK BK1 WITH FRAME TITLE TEXT-S01.
  PARAMETERS     : P_CDATE LIKE SY-DATLO OBLIGATORY.
  SELECT-OPTIONS : S_WERKS  FOR MARC-WERKS OBLIGATORY.
  PARAMETERS     : P_VERSN TYPE CHAR26 AS LISTBOX VISIBLE LENGTH 20
                                          USER-COMMAND VER.
  SELECT-OPTIONS : S_MATNR  FOR MARC-MATNR.
SELECTION-SCREEN END   OF BLOCK BK1.
