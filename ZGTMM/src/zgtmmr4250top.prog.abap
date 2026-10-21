*&---------------------------------------------------------------------*
*& Include ZGTMMR4250TOP
*&---------------------------------------------------------------------*

TABLES : MARA.


DATA : GV_CDATE LIKE SY-DATLO,
       GV_WERKS TYPE WERKS_D.

DATA : GV_CHG,
       GV_ERR,
       GV_REF,
       GV_ANS.

DATA : GV_FNM TYPE LVC_FNAME,
       GV_ROW TYPE LVC_INDEX,
       GV_NUM TYPE NUMC2.


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
         W00           LIKE ZGTMMT4221-W0,            "W0
         W01           LIKE ZGTMMT4221-W1,            "W1
         W02           LIKE ZGTMMT4221-W2,            "W2
         W03           LIKE ZGTMMT4221-W3,            "W3
         W04           LIKE ZGTMMT4221-W4,            "W4
         W05           LIKE ZGTMMT4221-W5,            "W5
         W06           LIKE ZGTMMT4221-W6,            "W6
         W07           LIKE ZGTMMT4221-W7,            "W7
         W08           LIKE ZGTMMT4221-W8,            "W8
         W09           LIKE ZGTMMT4221-W9,            "W9
         W10           LIKE ZGTMMT4221-W10,           "W10
         W11           LIKE ZGTMMT4221-W11,           "W11
         W12           LIKE ZGTMMT4221-W12,           "W12
         W13           LIKE ZGTMMT4221-W13,           "W13
         W14           LIKE ZGTMMT4221-W14,           "W14
         W15           LIKE ZGTMMT4221-W15.           "W15
         INCLUDE STRUCTURE ZGTMMS0000.
DATA :   DAILYLAST(1),                                "최종데이터
         CHG(1),
         STYLE         TYPE LVC_T_STYL,
         C_COL         TYPE LVC_T_SCOL,
         R_COL(4),
       END   OF GT_LIST.

DATA : GS_ELST LIKE GT_LIST,
       GS_FLST LIKE GT_LIST,
       GS_LLST LIKE GT_LIST.


DATA : GV_CNT TYPE I.

DATA : GT_STYL TYPE LVC_T_STYL,
       GT_SCOL TYPE LVC_T_SCOL.

DATA : GV_OKCODE LIKE SY-UCOMM.

DATA : GV_MON LIKE SY-DATUM,
       GV_SUN LIKE SY-DATUM.

DATA : GT_M20 LIKE ZGTMMT4220 OCCURS 0 WITH HEADER LINE,
       GT_M21 LIKE ZGTMMT4221 OCCURS 0 WITH HEADER LINE.

DATA : GS_CREA LIKE ZGTMMS0001,
       GS_CHNG LIKE ZGTMMS0002.


CONSTANTS : GC_A(1)        VALUE 'A',
            GC_B(1)        VALUE 'B',
            GC_C(1)        VALUE 'C',
            GC_D(1)        VALUE 'D',
            GC_E(1)        VALUE 'E',
            GC_F(1)        VALUE 'F',
            GC_G(1)        VALUE 'G',
            GC_H(1)        VALUE 'H',
            GC_I(1)        VALUE 'I',
            GC_J(1)        VALUE 'J',
            GC_K(1)        VALUE 'K',
            GC_L(1)        VALUE 'L',
            GC_X(1)        VALUE 'X',
            GC_1(1)        VALUE '1',
            GC_2(1)        VALUE '2',
            GC_6(1)        VALUE '6',
            GC_W0(2)       VALUE 'W0',
            GC_W1(2)       VALUE 'W1',
            GC_CHG(3)      VALUE 'CHG',
            GC_W00(3)      VALUE 'W00',
            GC_W01(3)      VALUE 'W01',
            GC_C200(4)     VALUE 'C200',
            GC_C700(4)     VALUE 'C700',
            GC_C_COL(5)    VALUE 'C_COL',
            GC_R_COL(5)    VALUE 'R_COL',
            GC_STYLE(5)    VALUE 'STYLE',
            GC_P_VERSN(7)  VALUE 'P_VERSN',
            GC_TOTALQTY(8) VALUE 'TOTALQTY'.


*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
"향후 권한 연동하여 User별 Defalut 값 관리시 Display 필드로 변경(WERKS)
SELECTION-SCREEN BEGIN OF BLOCK BK1 WITH FRAME TITLE TEXT-S01.
  PARAMETERS : P_CDATE LIKE SY-DATLO OBLIGATORY,
               P_WERKS TYPE WERKS_D  OBLIGATORY.
  PARAMETERS : P_VERSN TYPE CHAR26 AS LISTBOX VISIBLE LENGTH 20
                                      USER-COMMAND VER.

  SELECT-OPTIONS : S_MATNR FOR MARA-MATNR.
SELECTION-SCREEN END   OF BLOCK BK1.
