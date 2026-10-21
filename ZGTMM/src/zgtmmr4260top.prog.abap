*&---------------------------------------------------------------------*
*& Include ZGTMMR4260TOP
*&---------------------------------------------------------------------*

DATA : BEGIN OF GT_LIST OCCURS 0,
         WERKS   LIKE ZPPT0001-WERKS, "플랜트
         MATNR   LIKE ZPPT0001-MATNR, "자재코드
         CHARG   LIKE ZPPT0001-CHARG, "배치번호
         TAGNR   LIKE ZPPT0001-TAGNR, "꼬리표
         LIFNR   LIKE MSLB-LIFNR,     "공급업체
         GRINDAT LIKE MKPF-BUDAT,     "전기일
       END   OF GT_LIST.

DATA : GT_F045 LIKE ZGTMMSIF0045 OCCURS 0 WITH HEADER LINE.

DATA : GV_ERR,
       GV_ANS,
       GV_MSG(100),
       GV_CNT TYPE I.

DATA : GV_OKCODE LIKE SY-UCOMM.

*DATA: GV_REF.


CONSTANTS : GC_A(1)  VALUE 'A',
            GC_D(1)  VALUE 'D',
            GC_E(1)  VALUE 'E',
            GC_I(1)  VALUE 'I',
            GC_S(1)  VALUE 'S',
            GC_X(1)  VALUE 'X',
            GC_1(1)  VALUE '1',
            GC_2(1)  VALUE '2',
            GC_BT(2) VALUE 'BT'.


*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BK1 WITH FRAME TITLE TEXT-S01.
  SELECT-OPTIONS : S_BUDAT FOR SY-DATLO OBLIGATORY    "SC 재고 이전일
                                        NO-EXTENSION.
SELECTION-SCREEN END   OF BLOCK BK1.

SELECTION-SCREEN BEGIN OF BLOCK BK2 WITH FRAME TITLE TEXT-S02.
  PARAMETERS : P_SND AS CHECKBOX.
SELECTION-SCREEN END   OF BLOCK BK2.
