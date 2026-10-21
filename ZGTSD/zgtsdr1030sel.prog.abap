*&---------------------------------------------------------------------*
*& Include          ZGTSDR1030SEL
*&---------------------------------------------------------------------*
** 조회조건.
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_vkorg	FOR zgtsdt1030-vkorg  NO-EXTENSION NO INTERVALS,
                  s_vtweg	FOR zgtsdt1030-vtweg  NO-EXTENSION NO INTERVALS,
                  s_spart	FOR zgtsdt1030-spart  NO-EXTENSION NO INTERVALS,
                  s_vkbur	FOR zgtsdt1030-vkbur  NO-EXTENSION NO INTERVALS
                                                OBLIGATORY,
                  s_spmon	FOR zgtsdt1030-spmon  NO-EXTENSION NO INTERVALS
                                                OBLIGATORY,
                  s_kunnr	FOR zgtsdt1030-kunnr.

* 가격 단위.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(31)  TEXT-003 .
*   From
    PARAMETERS: p_kpein	LIKE zgtsdt1030-kpein.
    SELECTION-SCREEN COMMENT 47(10) TEXT-004 .
*   단위
    PARAMETERS: p_kmein	LIKE zgtsdt1030-kmein.
  SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN: END OF BLOCK b1.

** 실행모드.
SELECTION-SCREEN: BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
* 생성.
  PARAMETERS: rb_crt RADIOBUTTON GROUP rg1
                     USER-COMMAND ucomm DEFAULT 'X',
* 조회.
              rb_dis RADIOBUTTON GROUP rg1.
SELECTION-SCREEN: END OF BLOCK b2.
