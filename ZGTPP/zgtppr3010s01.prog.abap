*&---------------------------------------------------------------------*
*& Include          ZGTPPR3010S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001.

  PARAMETERS       : p_werks LIKE affw-werks OBLIGATORY
                                 MEMORY ID wrk. "플랜트
  SELECT-OPTIONS : s_dispo  FOR afko-dispo, "MRP 관리자(모품목)
                             s_aufnr  FOR affw-aufnr, "생산오더번호
                             s_matnr FOR affw-matnr, "품목 코드
                             s_gong FOR zedt0011-gong_cd NO-EXTENSION NO INTERVALS.

SELECTION-SCREEN END   OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-002.

  SELECT-OPTIONS : s_lgort FOR affw-lgort, "저장위치
                             s_matnr2 FOR affw-matnr, "자재코드
                             s_dispo2 FOR affw-dispo, "MRP 관리자(자품목)
                             s_bwart FOR affw-bwart, "이동유형
                             s_ersda FOR affw-ersda, "오류 발생일자
                             s_budat FOR affw-budat, "전기일자
                             s_crdat FOR zgtppt3000-crdat. "삭제일자

SELECTION-SCREEN END   OF BLOCK bl2.

SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE TEXT-003.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 2.
    PARAMETERS: p_del            RADIOBUTTON  GROUP gr1  DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 4(24) TEXT-004 FOR FIELD p_del.
    PARAMETERS: p_work          RADIOBUTTON  GROUP gr1.
    SELECTION-SCREEN COMMENT 40(16) TEXT-005 FOR FIELD p_work.
  SELECTION-SCREEN END   OF LINE.

  PARAMETERS p_layo LIKE disvariant-variant.

SELECTION-SCREEN END   OF BLOCK bl3.
*- 레이아웃 탐색도움말
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_layo.
  PERFORM select_alv_variant CHANGING p_layo.
