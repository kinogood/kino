*&---------------------------------------------------------------------*
*& Include          ZGTLER2100SEL
*&---------------------------------------------------------------------*
* select options
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.

  SELECTION-SCREEN: BEGIN OF LINE.
    PARAMETERS      : rb1    RADIOBUTTON GROUP rg1 USER-COMMAND co1."입고
    SELECTION-SCREEN: COMMENT (15) TEXT-001 FOR FIELD rb1.
    SELECTION-SCREEN POSITION 33.
    PARAMETERS      : rb2    RADIOBUTTON GROUP rg1.      "입고취소
    SELECTION-SCREEN: COMMENT (15) TEXT-002 FOR FIELD rb2.
  SELECTION-SCREEN: END OF LINE.

  SELECT-OPTIONS : s_werks   FOR  likp-werks OBLIGATORY,   " 플랜트
                   s_vstel   FOR  likp-vstel OBLIGATORY,   " 출하/입고지점
                   s_vkorg   FOR  likp-vkorg DEFAULT '6000'
                                             MODIF ID org, " 영업조직
                   s_vbeln   FOR  likp-vbeln,              " 납품문서
                   s_ternr   FOR  likp-vbeln,              " 오더번호
                   s_kunnr   FOR  likp-kunnr,              " 납품처
                   s_kunag   FOR  likp-kunag,              " 판매처
                   s_wadat   FOR  likp-wadat_ist.          " 납품출고일

SELECTION-SCREEN: END OF BLOCK b1.

SELECTION-SCREEN: BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-t02.
  PARAMETERS : p_budat LIKE mkpf-budat,                " 전기일자
               p_exe   AS CHECKBOX       MODIF ID sc1. " 전기일 예외처리
SELECTION-SCREEN: END OF BLOCK b2.
