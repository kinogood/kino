*&---------------------------------------------------------------------*
*& Include          ZGTPPR2030S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(30) TEXT-002 FOR FIELD p_werks.
    SELECTION-SCREEN POSITION 33.
    PARAMETERS: p_werks            LIKE marc-werks
                                   OBLIGATORY MEMORY ID wrk.
    SELECTION-SCREEN POSITION 47.
    PARAMETERS: p_name1            LIKE t001w-name1 MODIF ID m1.
  SELECTION-SCREEN END   OF LINE. "플랜트

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(30) TEXT-003 FOR FIELD p_spgcd.
    SELECTION-SCREEN POSITION 33.
    PARAMETERS: p_spgcd            LIKE zppt0107-spgcd
                                   OBLIGATORY MEMORY ID zspg.
    SELECTION-SCREEN POSITION 47.
    PARAMETERS: p_descr            LIKE zppt0107-descr MODIF ID m1.
  SELECTION-SCREEN END   OF LINE. "SPG

  SELECT-OPTIONS : s_auart FOR aufk-auart, "오더 유형
                             s_gong FOR zedt0011-gong_cd, "공정 코드
                             s_aufnr FOR aufk-aufnr, "생산 오더 번호
                             s_kdauf FOR aufk-kdauf, "판매 오더 번호
                             s_grpnr FOR zgtppt2010-grpnr, "조장표 번호
                             s_mat_r FOR afpo-matnr, "생산 자재
                             s_mat_i FOR resb-matnr, "투입 자재
                             s_gstrp FOR afko-gstrp. "기본 시작일

SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-004.

  PARAMETERS : p_check AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN END OF BLOCK b2.
