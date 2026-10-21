*&---------------------------------------------------------------------*
*& Include ZGTMMR6600TOP
*&---------------------------------------------------------------------*

TABLES : ZGTMMT6600.


DATA : BEGIN OF GT_LIST OCCURS 0,
         STATUS      LIKE ICON-ID,                "Msg
         EKORG       LIKE ZGTMMT6600-EKORG,       "구매조직
         WERKS       LIKE ZGTMMT6600-WERKS,       "플랜트
         JOB_NO      LIKE ZGTMMT6600-JOB_NO,      "제조지시번호
         LIFNR       LIKE EKKO-LIFNR,             "공급업체
         NAME1       LIKE LFA1-NAME1,             "공급업체명
         EBELN       LIKE ZGTMMT6600-EBELN,       "구매오더번호
         EBELP       LIKE ZGTMMT6600-EBELP,       "품목
         LOEKZ       LIKE ICON-ID,                "D
         MATNR       LIKE ZGTMMT6600-MATNR,       "자재코드
         TXZ01       LIKE EKPO-TXZ01,             "자재내역
         EINDT       LIKE EKET-EINDT,             "납품일
         NETWR       LIKE EKPO-NETWR,             "금액
         WAERS       LIKE EKKO-WAERS,             "통화
         MENGE       LIKE EKPO-MENGE,             "PO 수량
         MEINS       LIKE EKPO-MEINS,             "OUn
         IBQTY       LIKE EKES-MENGE,             "Inb수량
         WEMNG       LIKE EKET-WEMNG,             "입고수량
         ERNAM       LIKE ZGTMMT6600-ERNAM,       "삭제 요청자
         ERDAT_LOCAL LIKE ZGTMMT6600-ERDAT_LOCAL, "삭제 요청일
         ERTIM_LOCAL LIKE ZGTMMT6600-ERTIM_LOCAL, "삭제 요청시간
         BANFN       LIKE ZGTMMT6600-BANFN,       "구매요청번호
         BNFPO       LIKE ZGTMMT6600-BNFPO,       "품목
         AENAM       LIKE ZGTMMT6600-AENAM,       "삭제 처리자
         AEDAT_LOCAL LIKE ZGTMMT6600-AEDAT_LOCAL, "삭제 처리일
         AETIM_LOCAL LIKE ZGTMMT6600-AETIM_LOCAL, "삭제 처리시간
         JOBLS       LIKE ZGTMMT6600-JOBLS,       "제조지시 요청번호
         CLCRS       LIKE ZGTMMT6600-CLCRS,       "삭제요청 사유

         IDX         LIKE SY-INDEX,
         MSG         TYPE BAL_T_MSG,
         R_COL(4),
       END   OF GT_LIST.

DATA : BEGIN OF GT_EKES OCCURS 0,
         EBELN LIKE EKES-EBELN,
         EBELP LIKE EKES-EBELP,
         MENGE LIKE EKES-MENGE,
       END   OF GT_EKES.

DATA : BEGIN OF GT_XPO OCCURS 0,
         EBELN  LIKE EKPO-EBELN,
         EBELP  LIKE EKPO-EBELP,
         LOEKZ  LIKE ICON-ID,

         STATUS LIKE ICON-ID,
         IDX    LIKE SY-INDEX,
         MSG    TYPE BAL_T_MSG.
         INCLUDE STRUCTURE ZGTMMS0002.
DATA : END   OF GT_XPO.

DATA : GS_XPO LIKE GT_XPO.

DATA : GV_CNT TYPE I.

DATA : GV_OKCODE LIKE SY-UCOMM.

DATA : GV_ERR,
       GV_REF,
       GV_ANS.

DATA : GV_EMSG(20),
       GV_PMSG(30).

DATA : GT_ITM  LIKE BAPIMEPOITEM  OCCURS 0 WITH HEADER LINE,
       GT_ITMX LIKE BAPIMEPOITEMX OCCURS 0 WITH HEADER LINE,
       GT_RTN  LIKE BAPIRET2      OCCURS 0 WITH HEADER LINE.

DATA : GS_CHNG LIKE ZGTMMS0002.

FIELD-SYMBOLS : <GFS_MSG> TYPE BAL_T_MSG.

DATA : GS_HND TYPE BALLOGHNDL.


CONSTANTS : GC_A(1)      VALUE 'A',
            GC_C(1)      VALUE 'C',
            GC_D(1)      VALUE 'D',
            GC_E(1)      VALUE 'E',
            GC_I(1)      VALUE 'I',
            GC_L(1)      VALUE 'L',
            GC_P(1)      VALUE 'P',
            GC_S(1)      VALUE 'S',
            GC_X(1)      VALUE 'X',
            GC_1(1)      VALUE '1',
            GC_EQ(2)     VALUE 'EQ',
            GC_LA(2)     VALUE 'LA',
            GC_C300(4)   VALUE 'C300',
            GC_C500(4)   VALUE 'C500',
            GC_C600(4)   VALUE 'C600',
            GC_0001(4)   VALUE '0001',
            GC_1100(4)   VALUE '1100',
            GC_1306(4)   VALUE '1306',
            GC_R_COL(5)  VALUE 'R_COL',
            GC_STATUS(6) VALUE 'STATUS'.


*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BK1 WITH FRAME TITLE TEXT-S01.
  PARAMETERS     : P_EKORG LIKE ZGTMMT6600-EKORG
                                OBLIGATORY MEMORY ID EKO,
                   P_WERKS LIKE ZGTMMT6600-WERKS
                                OBLIGATORY MEMORY ID WRK.
  SELECT-OPTIONS : S_JOBNO  FOR ZGTMMT6600-JOB_NO,
                   S_EBELN  FOR ZGTMMT6600-EBELN,
                   S_MATNR  FOR ZGTMMT6600-MATNR,
                   S_ERDAT  FOR ZGTMMT6600-ERDAT OBLIGATORY.
SELECTION-SCREEN END   OF BLOCK BK1.
