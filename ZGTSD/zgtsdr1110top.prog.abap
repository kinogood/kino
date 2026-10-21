*&---------------------------------------------------------------------*
*& Include ZSDR1006TOP                              - Report ZSDR1006
*&---------------------------------------------------------------------*
TYPE-POOLS : KKBLO.

*--------------------------------------------------------------------*
* TABLES
*--------------------------------------------------------------------*
TABLES : ZKONA, ZKONA_ITEM, VBAK, VBRK, ZSD0016T, ZSD0017T, ZSD0018T.

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* DATA: Variable
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* DATA: Structure. (Field strings : Working area)
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* DATA: Internal Table.
*----------------------------------------------------------------------*

  DATA : BEGIN OF GS_ITAB,
           LINE     TYPE I,
           VBELN    TYPE VBRK-VBELN  ,     " 빌링헤더
           POSNR    TYPE VBRP-POSNR  ,     " 빌링아이템
           AUBEL    TYPE VBRP-AUBEL  ,     " S/O헤더
           AUPOS    TYPE VBRP-AUPOS  ,     " S/O아이템
           VKORG    TYPE VBRK-VKORG  ,     " 영업조직
           VTWEG    TYPE VBRK-VTWEG  ,     " 유통경로
           SPART    TYPE VBRK-SPART  ,     " 제품군
           VKBUR    TYPE VBAK-VKBUR  ,     " 영업팀
           BEZEI_1  TYPE TVKBT-BEZEI ,     " 영업팀 내역
           VKGRP    TYPE VBAK-VKGRP  ,     " 영업그룹
           BEZEI_2  TYPE TVGRT-BEZEI ,     " 영업그룹 내역

           KUNAG    TYPE VBRK-KUNAG  ,     " 고객
           NAME1    TYPE KNA1-NAME1  ,     " 이름
           KNUMA    TYPE ZKONA-KNUMA ,     " 계약번호
           BONEM    TYPE ZKONA-BONEM ,     " 에이전트
           L_NAME1  TYPE LFA1-NAME1  ,     " 이름

           NETWR    TYPE VBRP-NETWR  ,     " 품목매출금액
           WAERK    TYPE VBRP-WAERK  ,     " 매출금액단위
           KSCHL    TYPE KONV-KSCHL  ,     " 조건유형
           KWERT    TYPE KONV-KWERT  ,     " 빌링의 커미션 금액
           KBETR    TYPE KONV-KBETR  ,     " 빌링의 커미션 금액
           WAERS    TYPE KONV-WAERS  ,     " 빌링의 커미션 통화
           KNUMV    TYPE VBRK-KNUMV  ,     " 문서조건번호 (ALV X)
           ZRATE(50)                 ,     " 매출금액 비율
           FKDAT    TYPE VBRK-FKDAT  ,     " 매출일자,환율일자(청구일)
           VBELN_SE TYPE ZSD0018T-VBELN_SE," B3오더(정산오더)
           KWERT_K  TYPE ZSD0018T-KWERT_K, " 정산품목의 커미션 금액
           KWAEH    TYPE ZSD0018T-KWAEH,   " 정산품목의 커미션 통화

           BELNR_1  TYPE BKPF-BELNR  ,     " 미지급전표
           WRBTR_1  TYPE ZSD0016T-WRBTR,   " 미지급품목금액
           WAERK_1  TYPE ZSD0016T-WAERK,   " 미지급품목통화
           DMBTR_1  TYPE BSEG-DMBTR  ,     " 미지급전표 총액(원)
           BLDAT_1  TYPE BKPF-BLDAT  ,     " 미지급전표 증빙일
           BUDAT_1  TYPE BKPF-BUDAT  ,     " 미지급전표 전기일
           KURSF_1  TYPE BKPF-KURSF  ,     " 미지급전표 환율

           BELNR_2  TYPE BKPF-BELNR  ,     " 지급전표
           WRBTR_2  TYPE ZSD0017T-WRBTR,   " 지급전표금액
           WAERK_2  TYPE ZSD0017T-WAERK,   " 지급전표통화
           DMBTR_2  TYPE BSEG-DMBTR  ,     " 지급전표금액(원)
           BLDAT_2  TYPE BKPF-BLDAT  ,     " 지급전표 증빙일
           BUDAT_2  TYPE BKPF-BUDAT  ,     " 지급전표 전기일
           KURSF_2  TYPE BKPF-KURSF  ,     " 지급전표 환율
           KRW      TYPE WAERK VALUE 'KRW'.
*           COLTAB   TYPE LVC_T_SCOL.       " Color
  DATA : END OF GS_ITAB.
  DATA : GT_ITAB LIKE TABLE OF GS_ITAB.

  DATA : GT_DATA LIKE TABLE OF GS_ITAB.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS: GC_VKORG_6000 TYPE VKORG   VALUE '6000'.
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


*----------------------------------------------------------------------*
* RANGES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* FIELD-SYMBOLS
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* BDC
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* LONGTEXT
*----------------------------------------------------------------------*
