*&---------------------------------------------------------------------*
*& Include          ZGTSDR9061S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-t01.
  PARAMETERS     : p_vkorg TYPE vbak-vkorg      OBLIGATORY,
                   p_auart TYPE vbak-auart      OBLIGATORY,
                   p_spart TYPE vbak-spart      OBLIGATORY.

  SELECT-OPTIONS : s_erdat FOR  vbak-erdat      OBLIGATORY.

SELECTION-SCREEN END OF BLOCK bl1.
