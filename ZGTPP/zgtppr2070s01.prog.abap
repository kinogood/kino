*&---------------------------------------------------------------------*
*& Include          ZGTPPR2070S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN FUNCTION KEY 1.
SELECTION-SCREEN FUNCTION KEY 2.
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(30) TEXT-002 FOR FIELD p_werks. "플랜트
    SELECTION-SCREEN POSITION 33.
    PARAMETERS: p_werks LIKE marc-werks OBLIGATORY MEMORY ID wrk.
    SELECTION-SCREEN POSITION 47.
    PARAMETERS: p_name1 LIKE t001w-name1 MODIF ID m1."플랜트 내역
  SELECTION-SCREEN END   OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(30) TEXT-003 FOR FIELD p_spgcd. "SPG
    SELECTION-SCREEN POSITION 33.
    PARAMETERS: p_spgcd LIKE zppt0107-spgcd OBLIGATORY MEMORY ID zspg.
    SELECTION-SCREEN POSITION 47.
    PARAMETERS: p_descr LIKE zppt0107-descr MODIF ID m1. "SPG 내역
  SELECTION-SCREEN END   OF LINE.

  SELECT-OPTIONS : s_spec  FOR zgtppt2120-spec,   "규격
                   s_matnf FOR zgtppt2120-matnr,  "완제품 코드
                   s_matnh FOR zgtppt2120-idnrk,  "반제품 코드
                   s_zstat FOR zgtppt2120-zstate. "확인 상태

  PARAMETERS : p_call NO-DISPLAY.

SELECTION-SCREEN END   OF BLOCK bl1.
