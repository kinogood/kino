*&---------------------------------------------------------------------*
*& Include          ZGTPPR3080S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-t01.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(31) FOR FIELD p_sysid.
    PARAMETERS :   p_sysid TYPE zgtetarget           MODIF ID r01.
    SELECTION-SCREEN COMMENT 47(40) gv_systx.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(31) FOR FIELD p_if_no.
    PARAMETERS :   p_if_no TYPE char10               MODIF ID r01.
    SELECTION-SCREEN COMMENT 47(40) gv_iftxt.

  SELECTION-SCREEN END OF LINE.

  SELECT-OPTIONS : s_serno FOR  zgtppsif_rh-zserno,
                   s_ifdat FOR  zgtppsift-ifdat      MODIF ID r01,
                   s_iftim FOR  zgtppsift-iftim.

SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-t02.
  SELECTION-SCREEN COMMENT /1(70) TEXT-m01.
  SELECTION-SCREEN COMMENT /1(70) TEXT-m02.
SELECTION-SCREEN END OF BLOCK bl2.

SELECTION-SCREEN FUNCTION KEY 1.
