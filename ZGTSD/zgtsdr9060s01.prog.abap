*&---------------------------------------------------------------------*
*& Include          ZGTSDR9060S01
*&---------------------------------------------------------------------*
*-- 조회조건
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-t01.
  PARAMETERS     : p_vkorg TYPE vbak-vkorg         MODIF ID g01,
                   p_werks TYPE vbap-werks         MODIF ID g01,
                   p_spart TYPE vbak-spart         MODIF ID g01,
                   p_vstel TYPE likp-vstel         MODIF ID g01,

                   p_fname TYPE localfile          MODIF ID g02.

  SELECT-OPTIONS : s_erdat FOR  vbak-erdat         MODIF ID g03.

  PARAMETERS     : p_del_m RADIOBUTTON GROUP r4    DEFAULT 'X'
                                                   USER-COMMAND r01
                                                   MODIF ID g05,
                   p_del_t RADIOBUTTON GROUP r4    MODIF ID g05,
                   p_del_o RADIOBUTTON GROUP r4    MODIF ID g05.
SELECTION-SCREEN END OF BLOCK bl1.

*-- Option 1.
SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-t02.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : p_search RADIOBUTTON GROUP r1  DEFAULT 'X'
                                                USER-COMMAND r01.
    SELECTION-SCREEN COMMENT (20) FOR FIELD p_search.

    PARAMETERS : p_crte   RADIOBUTTON GROUP r1.
    SELECTION-SCREEN COMMENT (20) FOR FIELD p_crte.

    PARAMETERS : p_del    RADIOBUTTON GROUP r1.
    SELECTION-SCREEN COMMENT (20) FOR FIELD p_del.

    PARAMETERS : p_rej    RADIOBUTTON GROUP r1.
    SELECTION-SCREEN COMMENT (20) FOR FIELD p_rej.

  SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK bl2.

*-- Option 2.
SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE TEXT-t03.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : p_so   RADIOBUTTON GROUP r2       DEFAULT 'X'
                                                   USER-COMMAND r01
                                                   MODIF ID g03.
    SELECTION-SCREEN COMMENT (20) FOR FIELD p_so   MODIF ID g03.

    PARAMETERS : p_do   RADIOBUTTON GROUP r2       MODIF ID g03.
    SELECTION-SCREEN COMMENT (20) FOR FIELD p_do   MODIF ID g03.

    PARAMETERS : p_hu   RADIOBUTTON GROUP r2       MODIF ID g03.
    SELECTION-SCREEN COMMENT (20) FOR FIELD p_hu   MODIF ID g03.

    PARAMETERS : p_ship RADIOBUTTON GROUP r2       MODIF ID g03.
    SELECTION-SCREEN COMMENT (20) FOR FIELD p_ship MODIF ID g03.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : p_mapp RADIOBUTTON GROUP r3       DEFAULT 'X'
                                                   USER-COMMAND r01
                                                   MODIF ID g04.
    SELECTION-SCREEN COMMENT (20) FOR FIELD p_mapp MODIF ID g04.

    PARAMETERS : p_tobe RADIOBUTTON GROUP r3       MODIF ID g04.
    SELECTION-SCREEN COMMENT (20) FOR FIELD p_tobe MODIF ID g04.

  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK bl3.
