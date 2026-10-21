*&---------------------------------------------------------------------*
*& Include          ZSDR1005_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS : KKBLO.

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
  TABLES : CTU_PARAMS,             " CALL TRANSACTION OPTION..
           ZKONA,
           VBRK.
*----------------------------------------------------------------------*
* CONTROLS
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* DATA: Variable
*----------------------------------------------------------------------*
DATA : GV_LAST TYPE SY-DATUM.
DATA : GV_SUCCES(1).
DATA : GV_TOTAL_SUM TYPE KONV-KBETR.
*----------------------------------------------------------------------*
* DATA: Internal Table.
*----------------------------------------------------------------------*

  DATA : BEGIN OF GS_ITAB,
           LINE     TYPE I,
           VBELN    TYPE VBRK-VBELN  ,     " 빌링(청구문서)                핫스팟:VF03
           POSNR    TYPE VBRP-POSNR  ,     " 아이템(청구항목)
           KNUMA    TYPE ZKONA-KNUMA ,     " 계약번호                      핫스팟:ZVB03
           BOTEXT   TYPE ZKONA-BOTEXT,     " 계약내역
           DATAB    TYPE ZKONA-DATAB ,     " 계약 효력 시작일
           DATBI    TYPE ZKONA-DATBI ,     " 계약 효력 종료일
           KNUMV    TYPE VBRK-KNUMV  ,     " 문서조건번호 (ALV X)
           KSCHL    TYPE KONV-KSCHL  ,     " 조건유형
           ZRATE(50)                 ,     " 매출금액 비율
           AUBEL    TYPE VBRP-AUBEL  ,     " 판매오더                      핫스팟:VA03
           AUPOS    TYPE VBRP-AUPOS  ,     " 아이템(판매문서항목)
           KUNNR    TYPE VBAK-KUNNR  ,     " 고객                          핫스팟:BP->VD03 변경
           NAME1    TYPE KNA1-NAME1  ,     " 이름
           LIFNR    TYPE VBPA-LIFNR  ,     " 에이전트(공급업체 계정번호)   핫스팟:BP->VD03 변경
           L_NAME1  TYPE LFA1-NAME1  ,     " 이름
           FKDAT    TYPE VBRK-FKDAT  ,     " 매출일자(청구일)
           NETWR    TYPE VBRP-NETWR  ,     " 매출액(청구 항목 정가(전표 통화))
           WAERK    TYPE VBRK-WAERK  ,     " 통화
           KBETR    TYPE KONV-KBETR  ,     " 커미션금액 (합산)
           KWERT    TYPE KONV-KWERT  ,     " 커미션금액 (합산) =통화
           WAERS    TYPE KONV-WAERS  ,     " 통화
           VBELN_SE TYPE VBRK-VBELN  ,     " 정산오더      핫스팟:VA03
           COLTAB   TYPE LVC_T_SCOL.       " Color
  DATA : END OF GS_ITAB.
  DATA : GT_ITAB LIKE TABLE OF GS_ITAB.

  DATA : GT_DATA LIKE TABLE OF GS_ITAB.

  DATA : GT_ZSD0018T TYPE ZSD0018T OCCURS 0 WITH HEADER LINE.


  DATA: BEGIN OF G_ITAB_T OCCURS 0,
          KNUMA LIKE ZKONA-KNUMA,                      " 계약번호
        END OF G_ITAB_T.

**========================
** BDC관련 INTERNAL TABLE
**========================
** MESSAGES OF CALL TRANSACTION
  DATA: G_MSG_T LIKE BDCMSGCOLL
                OCCURS 0 WITH HEADER LINE.

** BDCDATA DECLARE
  DATA: BEGIN OF BDCTAB OCCURS 0.
          INCLUDE STRUCTURE BDCDATA.
  DATA: END OF BDCTAB.

  DATA: BEGIN OF G_BDC_T OCCURS 0,
          MARK,
          VBELN(10),              " 납품문서
          POSNR(6),               " 납품품목
          REMN_QTY(17),           " 납품수량
          KURRF(12),              " 환율(수출에서 사용)
          SUBRC        LIKE SY-SUBRC,    " BDC수행결과
          MESG(70),               " BDC메세지
        END OF G_BDC_T.

  DATA : G_ABRDATE LIKE SY-DATUM.

  RANGES : RA_KNUMA FOR ZKONA-KNUMA.



*----------------------------------------------------------------------*
* DATA: Structure. (Field strings : Working area)
*----------------------------------------------------------------------*


*----------------------------------------------------------------------*
* RANGES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* FIELD-SYMBOLS
*----------------------------------------------------------------------*


*----------------------------------------------------------------------*
* BDC
*----------------------------------------------------------------------*
  DATA: GS_MODE    LIKE CTU_PARAMS,
        GT_BDCDATA LIKE BDCDATA OCCURS 0 WITH HEADER LINE,
        GT_BDCMSG  LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.
*----------------------------------------------------------------------*
* TAB
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS: GC_VKORG_6000 TYPE VKORG   VALUE '6000'.

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
