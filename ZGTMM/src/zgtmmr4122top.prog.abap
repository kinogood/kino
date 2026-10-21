*&---------------------------------------------------------------------*
*& Include ZGTMMR4122TOP
*&---------------------------------------------------------------------*

TABLES : LFM1, MKPF.


DATA : BEGIN OF GT_HLIST OCCURS 0,
         STATUS    LIKE ICON-ID,                          "상태
         BUKRS     TYPE ZGTMM_CV_SCSTOCKDAILYH-BUKRS,     "회사코드
         ZDATE     TYPE ZGTMM_CV_SCSTOCKDAILYH-ZDATE,     "전기일
         SUPPLIER  TYPE ZGTMM_CV_SCSTOCKDAILYH-SUPPLIER,  "업체
         BPNAME    TYPE ZGTMM_CV_SCSTOCKDAILYH-BPNAME,    "업체명
         PREIS     TYPE ZGTMM_CV_SCSTOCKDAILYH-PREIS,     "보증보험금액
         TSTOCKVAL TYPE ZGTMM_CV_SCSTOCKDAILYH-TSTOCKVAL, "외주재고액
         REMAINVAL TYPE ZGTMM_CV_SCSTOCKDAILYH-REMAINVAL, "한도금액
         WAERS     TYPE ZGTMM_CV_SCSTOCKDAILYH-WAERS,     "통화
       END     OF GT_HLIST.

DATA : BEGIN OF GT_ILIST OCCURS 0,
         BUKRS           TYPE ZGTMM_CV_SCSTOCKLIST2-BUKRS,     "회사코드
         COMPANYCODENAME TYPE ZGTMM_CV_SCSTOCKLIST2-COMPANYCODENAME, "회사명
         WERKS           TYPE ZGTMM_CV_SCSTOCKLIST2-WERKS,     "플랜트
         PLANTNAME       TYPE ZGTMM_CV_SCSTOCKLIST2-PLANTNAME, "플랜트명
         SUPPLIER        TYPE ZGTMM_CV_SCSTOCKLIST2-SUPPLIER,  "업체
         BPNAME          TYPE ZGTMM_CV_SCSTOCKLIST2-BPNAME,    "업체명
         PERIOD          TYPE ZGTMM_CV_SCSTOCKLIST2-PERIOD,    "기간(YYYYMM)
         ZDATE           TYPE ZGTMM_CV_SCSTOCKLIST2-ZDATE,     "전기일
         MATNR           TYPE ZGTMM_CV_SCSTOCKLIST2-MATNR,     "자재
         MATERIALNAME    TYPE ZGTMM_CV_SCSTOCKLIST2-MATERIALNAME, "자재명
         BATCH           TYPE ZGTMM_CV_SCSTOCKLIST2-BATCH,     "배치
         STPRS           TYPE ZGTMM_CV_SCSTOCKLIST2-STPRS,     "단가(표준/이동)
         PEINH           TYPE ZGTMM_CV_SCSTOCKLIST2-PEINH,     "가격단위
         STOCKQTY        TYPE ZGTMM_CV_SCSTOCKLIST2-STOCKQTY,  "재고수량
         MEINS           TYPE ZGTMM_CV_SCSTOCKLIST2-MEINS,     "단위
         TSTOCKVAL       TYPE ZGTMM_CV_SCSTOCKLIST2-TSTOCKVAL, "외주재고액
         WAERS           TYPE ZGTMM_CV_SCSTOCKLIST2-WAERS,     "통화

         STPRSBASE       TYPE ZGTMM_CV_SCSTOCKLIST2-STPRSBASE, "수량*단가
         EKGRP           TYPE ZGTMM_CV_SCSTOCKLIST2-EKGRP,     "구매그룹
         EKNAM           TYPE ZGTMM_CV_SCSTOCKLIST2-EKNAM,     "구매그룹명
         DISPO           TYPE ZGTMM_CV_SCSTOCKLIST2-DISPO,     "MRP관리자
         DSNAM           TYPE ZGTMM_CV_SCSTOCKLIST2-DSNAM,     "MRP관리자명
         MATKL           TYPE ZGTMM_CV_SCSTOCKLIST2-MATKL,     "자재그룹
       END   OF GT_ILIST.


DATA : GV_CNT TYPE I.

DATA : GV_OKCODE LIKE SY-UCOMM,
       GV_BUDAT  TYPE STRING.


CONSTANTS : GC_D(1)  VALUE 'D',
            GC_E(1)  VALUE 'E',
            GC_H(1)  VALUE 'H',
            GC_I(1)  VALUE 'I',
            GC_S(1)  VALUE 'S',
            GC_X(1)  VALUE 'X',
            GC_0(1)  VALUE '0',
            GC_BT(2) VALUE 'BT',
            GC_EQ(2) VALUE 'EQ'.


*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
"향후 권한 연동하여 User별 Defalut 값 관리시 Display 필드로 변경 예정(BUKRS)
SELECTION-SCREEN BEGIN OF BLOCK BK1 WITH FRAME TITLE TEXT-S01.
  PARAMETERS     : P_BUKRS LIKE T001-BUKRS OBLIGATORY.
  SELECT-OPTIONS : S_LIFNR  FOR LFM1-LIFNR,
                   S_BUDAT  FOR MKPF-BUDAT OBLIGATORY NO-EXTENSION.
SELECTION-SCREEN END   OF BLOCK BK1.
