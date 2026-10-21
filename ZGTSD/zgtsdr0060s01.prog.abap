*&---------------------------------------------------------------------*
*& Include          ZGTSDR0060S01
*&---------------------------------------------------------------------*
*-- 조회조건
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-t01.
  PARAMETERS    : p_vkorg TYPE tvko-vkorg          MODIF ID g01,
                  p_zpjno TYPE zsd0106t-zpjno,
                  p_spart TYPE mara-spart          MODIF ID g02.

  SELECT-OPTIONS : s_jobno FOR  zgtsdt0065-job_no,

                   s_erdt1 FOR  zgtsdt0065-erdat   MODIF ID d01,
                   s_erdt2 FOR  zgtsdt0065-aedat   MODIF ID d02.

SELECTION-SCREEN END OF BLOCK bl1.

*-- 시작업 생산요청 생성 / 조회
SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-t02.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS   : p_crte   RADIOBUTTON GROUP r1   DEFAULT 'X'
                                                   USER-COMMAND r01.
    SELECTION-SCREEN COMMENT (20) FOR FIELD p_crte.

    PARAMETERS   : p_search RADIOBUTTON GROUP r1.
    SELECTION-SCREEN COMMENT (20) FOR FIELD p_search.

  SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK bl2.

*-- 조회 Opt
SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE TEXT-t03.
  PARAMETERS     : p_batch AS CHECKBOX             MODIF ID g03.

  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS   : p_all   RADIOBUTTON GROUP r2    DEFAULT 'X'
                                                   USER-COMMAND r02
                                                   MODIF ID g04.
    SELECTION-SCREEN COMMENT (15) FOR FIELD p_all  MODIF ID g04.

    PARAMETERS   : p_succs RADIOBUTTON GROUP r2    MODIF ID g04.
    SELECTION-SCREEN COMMENT (15) FOR FIELD p_succs
      MODIF ID g04.

    PARAMETERS   : p_fail  RADIOBUTTON GROUP r2    MODIF ID g04.
    SELECTION-SCREEN COMMENT (15) FOR FIELD p_fail MODIF ID g04.

  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK bl3.
