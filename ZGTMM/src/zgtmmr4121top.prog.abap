*&---------------------------------------------------------------------*
*& Include ZGTMMR4121TOP
*&---------------------------------------------------------------------*

TABLES : T001W, LFM1, MKPF.


DATA : GT_RTAB LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF GT_HLIST OCCURS 0,
         ZGUID       TYPE ZGTMM_CV_SCAPPLIST-ZGUID,       "GUID
         ZGITYPE     TYPE ZGTMM_CV_SCAPPLIST-ZGITYPE,     "초과불출유형
         BUKRS       TYPE ZGTMM_CV_SCAPPLIST-BUKRS,       "회사코드
         WERKS       TYPE ZGTMM_CV_SCAPPLIST-WERKS,       "플랜트
         LGORT       TYPE ZGTMM_CV_SCAPPLIST-LGORT,       "저장위치
         LGOBE       TYPE ZGTMM_CV_SCAPPLIST-LGOBE,       "저장위치명

         LIFNR       TYPE ZGTMM_CV_SCAPPLIST-LIFNR,       "외주업체
         NAME1       TYPE ZGTMM_CV_SCAPPLIST-NAME1,       "업체명
         PREIS       TYPE ZGTMM_CV_SCAPPLIST-PREIS,       "보증금액
         SCVAL       TYPE ZGTMM_CV_SCAPPLIST-SCVAL,       "외주재고액
         ISVAL       TYPE ZGTMM_CV_SCAPPLIST-ISVAL,       "출고처리액
         REVAL       TYPE ZGTMM_CV_SCAPPLIST-REVAL,       "출고가용액
         IVVAL       TYPE ZGTMM_CV_SCAPPLIST-IVVAL,       "당월IV금액
         WAERS       TYPE ZGTMM_CV_SCAPPLIST-WAERS,       "통화
         ORES        TYPE ZGTMM_CV_SCAPPLIST-ORES,        "초과사유
         OREST       TYPE ZGTMM_CV_SCAPPLIST-OREST,       "초과사유명
         OETC        TYPE ZGTMM_CV_SCAPPLIST-OETC,        "비고

         APPSTAT     TYPE ZGTMM_CV_SCAPPLIST-APPSTAT,     "승인상태
         REJRES      TYPE ZGTMM_CV_SCAPPLIST-REJRES,      "반려사유
         REJREST     TYPE ZGTMM_CV_SCAPPLIST-REJREST,     "반려사유명
         RETC        TYPE ZGTMM_CV_SCAPPLIST-RETC,        "비고(반려)

         MJAHR       TYPE ZGTMM_CV_SCAPPLIST-MJAHR,       "연도
         MBLNR       TYPE ZGTMM_CV_SCAPPLIST-MBLNR,       "자재문서번호
         IV_NO       TYPE ZGTMM_CV_SCAPPLIST-IV_NO,       "통문번호

         ERDAT       TYPE ZGTMM_CV_SCAPPLIST-ERDAT,       "상신일
         ERDAT_LOCAL TYPE ZGTMM_CV_SCAPPLIST-ERDAT_LOCAL, "상신일(LOCAL)
         ERTIM       TYPE ZGTMM_CV_SCAPPLIST-ERTIM,       "상신시간
         ERTIM_LOCAL TYPE ZGTMM_CV_SCAPPLIST-ERTIM_LOCAL, "상신시간(LOCAL)
         ERNAM       TYPE ZGTMM_CV_SCAPPLIST-ERNAM,       "품의자
         REQNAME     TYPE ZGTMM_CV_SCAPPLIST-REQNAME,     "품의자명
         AEDAT       TYPE ZGTMM_CV_SCAPPLIST-AEDAT,       "승인일
         AEDAT_LOCAL TYPE ZGTMM_CV_SCAPPLIST-AEDAT_LOCAL, "승인일(LOCAL)
         AETIM       TYPE ZGTMM_CV_SCAPPLIST-AETIM,       "승인시간
         AETIM_LOCAL TYPE ZGTMM_CV_SCAPPLIST-AETIM_LOCAL, "승인시간(LOCAL)
         AENAM       TYPE ZGTMM_CV_SCAPPLIST-AENAM,       "승인자
         APPNAME     TYPE ZGTMM_CV_SCAPPLIST-APPNAME,     "승인자명

         APPROVER1   TYPE ZGTMM_CV_SCAPPLIST-APPROVER1,   "승인자1
         APPROVER2   TYPE ZGTMM_CV_SCAPPLIST-APPROVER2,   "승인자2
         BLDAT       TYPE ZGTMM_CV_SCAPPLIST-BLDAT,       "전기일
         BUDAT       TYPE ZGTMM_CV_SCAPPLIST-BUDAT,	      "증빙일
         CPUDT       TYPE ZGTMM_CV_SCAPPLIST-CPUDT,       "입력일
         USNAM       TYPE ZGTMM_CV_SCAPPLIST-USNAM,       "입력자
       END   OF GT_HLIST.

DATA : BEGIN OF GT_HLIST_CUR OCCURS 0,
         STATUS    LIKE ICON-ID,                          "상태
         BUKRS     TYPE ZGTMM_CV_SCSTOCKDAILYH-BUKRS,     "회사코드
         ZDATE     TYPE ZGTMM_CV_SCSTOCKDAILYH-ZDATE,     "전기일
         SUPPLIER  TYPE ZGTMM_CV_SCSTOCKDAILYH-SUPPLIER,  "업체
         BPNAME    TYPE ZGTMM_CV_SCSTOCKDAILYH-BPNAME,    "업체명
         PREIS     TYPE ZGTMM_CV_SCSTOCKDAILYH-PREIS,     "보증보험금액
         TSTOCKVAL TYPE ZGTMM_CV_SCSTOCKDAILYH-TSTOCKVAL, "외주재고액
         REMAINVAL TYPE ZGTMM_CV_SCSTOCKDAILYH-REMAINVAL, "한도금액
         WAERS     TYPE ZGTMM_CV_SCSTOCKDAILYH-WAERS,     "통화
         PERCT     TYPE P DECIMALS 2,
       END     OF GT_HLIST_CUR.

DATA : BEGIN OF GT_HLIST_HIS OCCURS 0,
         KEY_FIELD(50),
         ZGUID       TYPE ZGTMM_CV_SCAPPLIST-ZGUID,       "GUID
         ZGITYPE     TYPE ZGTMM_CV_SCAPPLIST-ZGITYPE,     "초과불출유형
         BUKRS       TYPE ZGTMM_CV_SCAPPLIST-BUKRS,       "회사코드
         WERKS       TYPE ZGTMM_CV_SCAPPLIST-WERKS,       "플랜트
         LGORT       TYPE ZGTMM_CV_SCAPPLIST-LGORT,       "저장위치
         LGOBE       TYPE ZGTMM_CV_SCAPPLIST-LGOBE,       "저장위치명

         LIFNR       TYPE ZGTMM_CV_SCAPPLIST-LIFNR,       "외주업체
         NAME1       TYPE ZGTMM_CV_SCAPPLIST-NAME1,       "업체명
         PREIS       TYPE ZGTMM_CV_SCAPPLIST-PREIS,       "보증금액
         SCVAL       TYPE ZGTMM_CV_SCAPPLIST-SCVAL,       "외주재고액
         ISVAL       TYPE ZGTMM_CV_SCAPPLIST-ISVAL,       "출고처리액
         REVAL       TYPE ZGTMM_CV_SCAPPLIST-REVAL,       "출고가용액
         IVVAL       TYPE ZGTMM_CV_SCAPPLIST-IVVAL,       "당월IV금액
         WAERS       TYPE ZGTMM_CV_SCAPPLIST-WAERS,       "통화
         ORES        TYPE ZGTMM_CV_SCAPPLIST-ORES,        "초과사유
         OREST       TYPE ZGTMM_CV_SCAPPLIST-OREST,       "초과사유명
         OETC        TYPE ZGTMM_CV_SCAPPLIST-OETC,        "비고

         APPSTAT     TYPE ZGTMM_CV_SCAPPLIST-APPSTAT,     "승인상태
         REJRES      TYPE ZGTMM_CV_SCAPPLIST-REJRES,      "반려사유
         REJREST     TYPE ZGTMM_CV_SCAPPLIST-REJREST,     "반려사유명
         RETC        TYPE ZGTMM_CV_SCAPPLIST-RETC,        "비고(반려)

         MJAHR       TYPE ZGTMM_CV_SCAPPLIST-MJAHR,       "연도
         MBLNR       TYPE ZGTMM_CV_SCAPPLIST-MBLNR,       "자재문서번호
         IV_NO       TYPE ZGTMM_CV_SCAPPLIST-IV_NO,       "통문번호

         ERDAT       TYPE ZGTMM_CV_SCAPPLIST-ERDAT,       "상신일
         ERDAT_LOCAL TYPE ZGTMM_CV_SCAPPLIST-ERDAT_LOCAL, "상신일(LOCAL)
         ERTIM       TYPE ZGTMM_CV_SCAPPLIST-ERTIM,       "상신시간
         ERTIM_LOCAL TYPE ZGTMM_CV_SCAPPLIST-ERTIM_LOCAL, "상신시간(LOCAL)
         ERNAM       TYPE ZGTMM_CV_SCAPPLIST-ERNAM,       "품의자
         REQNAME     TYPE ZGTMM_CV_SCAPPLIST-REQNAME,     "품의자명
         AEDAT       TYPE ZGTMM_CV_SCAPPLIST-AEDAT,       "승인일
         AEDAT_LOCAL TYPE ZGTMM_CV_SCAPPLIST-AEDAT_LOCAL, "승인일(LOCAL)
         AETIM       TYPE ZGTMM_CV_SCAPPLIST-AETIM,       "승인시간
         AETIM_LOCAL TYPE ZGTMM_CV_SCAPPLIST-AETIM_LOCAL, "승인시간(LOCAL)
         AENAM       TYPE ZGTMM_CV_SCAPPLIST-AENAM,       "승인자
         APPNAME     TYPE ZGTMM_CV_SCAPPLIST-APPNAME,     "승인자명

         APPROVER1   TYPE ZGTMM_CV_SCAPPLIST-APPROVER1,   "승인자1
         APPROVER2   TYPE ZGTMM_CV_SCAPPLIST-APPROVER2,   "승인자2
         BLDAT       TYPE ZGTMM_CV_SCAPPLIST-BLDAT,       "전기일
         BUDAT       TYPE ZGTMM_CV_SCAPPLIST-BUDAT,	      "증빙일
         CPUDT       TYPE ZGTMM_CV_SCAPPLIST-CPUDT,       "입력일
         USNAM       TYPE ZGTMM_CV_SCAPPLIST-USNAM,       "입력자
         COUNT       TYPE I,                              "초과불출횟수
       END   OF GT_HLIST_HIS.

DATA : GT_HLIST_TEMP LIKE TABLE OF GT_HLIST_HIS.
DATA : GS_HLIST_TEMP LIKE LINE OF GT_HLIST_TEMP.

DATA : BEGIN OF GT_ILIST OCCURS 0,
         ZGUID TYPE ZGTMM_CV_SCAPPDETAIL-ZGUID, "GUID
         MATNR TYPE ZGTMM_CV_SCAPPDETAIL-MATNR, "자재코드
         MAKTX TYPE ZGTMM_CV_SCAPPDETAIL-MAKTX, "자재명
         XCHPF TYPE ZGTMM_CV_SCAPPDETAIL-XCHPF, "배치관리여부

         REQTY TYPE ZGTMM_CV_SCAPPDETAIL-REQTY, "총소요량
         SCQTY TYPE ZGTMM_CV_SCAPPDETAIL-SCQTY, "외주재고량
         NEQTY TYPE ZGTMM_CV_SCAPPDETAIL-NEQTY, "필요량
         SLQTY TYPE ZGTMM_CV_SCAPPDETAIL-SLQTY, "창고재고량
         ISQTY TYPE ZGTMM_CV_SCAPPDETAIL-ISQTY, "출하지시량
         MEINS TYPE ZGTMM_CV_SCAPPDETAIL-MEINS, "단위
         ISVAL TYPE ZGTMM_CV_SCAPPDETAIL-ISVAL, "출하지시금액
         SCVAL TYPE ZGTMM_CV_SCAPPDETAIL-SCVAL, "외주재고액
         WAERS TYPE ZGTMM_CV_SCAPPDETAIL-WAERS, "통화
       END   OF GT_ILIST.


DATA : GV_CNT TYPE I.

DATA : GV_OKCODE LIKE SY-UCOMM.


CONSTANTS : GC_A(1)  VALUE 'A',
            GC_D(1)  VALUE 'D',
            GC_E(1)  VALUE 'E',
            GC_I(1)  VALUE 'I',
            GC_S(1)  VALUE 'S',
            GC_X(1)  VALUE 'X',
            GC_BT(2) VALUE 'BT',
            GC_EQ(2) VALUE 'EQ'.

*--> 메일 발송
DATA: GT_MESSAGE            TYPE BCSY_TEXT,
      GV_SEND_RESULT        TYPE C,
      G_RECEIVER            TYPE REF TO IF_RECIPIENT_BCS,
      G_EMAIL               TYPE REF TO CL_BCS,
      G_EMAIL_BODY          TYPE REF TO CL_DOCUMENT_BCS,
      G_SENDER              TYPE REF TO IF_SENDER_BCS,
      G_EXCEPTION           TYPE REF TO CX_BCS,
      GV_ADDRESS            TYPE AD_SMTPADR,
      GT_FTEXT              TYPE LVC_TXTCOL OCCURS 0,
      GV_HDTITLE(40)        TYPE C,
      GV_SUBJECT            TYPE SO_OBJ_DES.

DATA: BEGIN OF GT_RECV OCCURS 0,
        BNAME               LIKE USR21-BNAME,
        SMTP_ADDR           LIKE ADR6-SMTP_ADDR,
      END   OF GT_RECV.
*<-- 메일 발송

*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
"향후 권한 연동하여 User별 Defalut 값 관리시 Display 필드로 변경 예정(BUKRS)
SELECTION-SCREEN BEGIN OF BLOCK BK1 WITH FRAME TITLE TEXT-S01.
  PARAMETERS     : P_BUKRS LIKE T001-BUKRS OBLIGATORY.
  SELECT-OPTIONS : S_WERKS  FOR T001W-WERKS,
                   S_LIFNR  FOR LFM1-LIFNR,
                   S_BUDAT  FOR MKPF-BUDAT OBLIGATORY NO-EXTENSION.
SELECTION-SCREEN END   OF BLOCK BK1.
