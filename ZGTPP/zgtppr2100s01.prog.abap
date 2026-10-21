*&---------------------------------------------------------------------*
*& Include          ZGTPPR2100S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(30) TEXT-002 FOR FIELD p_werks. "플랜트
    SELECTION-SCREEN POSITION 33.
    PARAMETERS: p_werks LIKE zgtppt2100-werks OBLIGATORY MEMORY ID wrk.
    SELECTION-SCREEN POSITION 47.
    PARAMETERS: p_name1 LIKE t001w-name1 MODIF ID m1."플랜트 내역
  SELECTION-SCREEN END   OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(30) TEXT-003 FOR FIELD p_spgcd. "SPG
    SELECTION-SCREEN POSITION 33.
    PARAMETERS: p_spgcd LIKE zgtppt2100-spgcd OBLIGATORY MEMORY ID zspg.
    SELECTION-SCREEN POSITION 47.
    PARAMETERS: p_descr LIKE zppt0107-descr MODIF ID m1. "SPG 내역
  SELECTION-SCREEN END   OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(30) TEXT-010 FOR FIELD p_simty.
    SELECTION-SCREEN POSITION 33.
    PARAMETERS: p_simty LIKE zgtppt2090-simty DEFAULT '2'
                                   OBLIGATORY.
    SELECTION-SCREEN POSITION 47.
    PARAMETERS: p_simdec LIKE dd07t-ddtext MODIF ID m1.
  SELECTION-SCREEN END   OF LINE.

  SELECT-OPTIONS : s_spec  FOR zgtppt2080-spec,   "규격
                   s_pjno  FOR zgtppt2080-zpjno,  "프로젝트 No.
                   s_gong  FOR zedt0011-gong_cd,  "공정코드
                   s_spmon FOR zgtppt2100-zspmon
                   OBLIGATORY NO-EXTENSION. "계획기간(월)

SELECTION-SCREEN END   OF BLOCK bl1.
