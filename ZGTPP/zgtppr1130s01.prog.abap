*&---------------------------------------------------------------------*
*& Include          ZGTPPR1130S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-T01. "검색조건
  SELECT-OPTIONS: S_WERKS FOR ZGTPPT1090-WERKS OBLIGATORY  "플랜트
                          NO-EXTENSION NO INTERVALS,
                  S_SPGCD FOR ZGTPPT1090-SPGCD             "SPG코드
                          NO-EXTENSION NO INTERVALS.
SELECTION-SCREEN END OF BLOCK B1.
