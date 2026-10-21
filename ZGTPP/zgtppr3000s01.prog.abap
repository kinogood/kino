*&---------------------------------------------------------------------*
*& Include          ZGTPPR3000S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001.

  PARAMETERS     : p_werks LIKE affw-werks OBLIGATORY
                   MEMORY ID wrk. "플랜트
  SELECT-OPTIONS : s_dispo FOR afko-dispo, "MRP 관리자(모품목)
                   s_aufnr FOR affw-aufnr, "생산오더번호
                   s_matnr FOR affw-matnr, "품목 코드
                   s_bstnk FOR vbak-bstnk MODIF ID ds1, "제조지시번호
                   s_gong  FOR zedt0011-gong_cd NO-EXTENSION NO INTERVALS.

SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-002.

  SELECT-OPTIONS : s_lgort  FOR affw-lgort, "저장위치
                   s_matnr2 FOR affw-matnr, "자재코드
                   s_bwart  FOR affw-bwart, "이동유형
                   s_dispo2 FOR affw-dispo, "MRP 관리자(자품목)
                   s_ersda  FOR affw-ersda, "오류 발생일자
                   s_budat  FOR affw-budat. "전기일자

SELECTION-SCREEN END OF BLOCK bl2.

SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE TEXT-003.

  PARAMETERS : p_chk AS CHECKBOX.

SELECTION-SCREEN END OF BLOCK bl3.

SELECTION-SCREEN BEGIN OF BLOCK bl4 WITH FRAME TITLE TEXT-004.

  PARAMETERS p_layo LIKE disvariant-variant.

SELECTION-SCREEN END OF BLOCK bl4.

SELECTION-SCREEN BEGIN OF BLOCK bl5 WITH FRAME TITLE TEXT-005.

  SELECTION-SCREEN : COMMENT /2(60) TEXT-006.
  SELECTION-SCREEN : COMMENT /2(60) TEXT-007.

SELECTION-SCREEN END OF BLOCK bl5.
*- 레이아웃 탐색도움말
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_layo.
  PERFORM select_alv_variant CHANGING p_layo.
