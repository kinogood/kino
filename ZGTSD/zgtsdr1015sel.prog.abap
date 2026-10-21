*&---------------------------------------------------------------------*
*& Include          ZGTSDR1015SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: S_VKORG FOR ZGTSDT1102-VKORG OBLIGATORY MODIF ID Z1
                                               NO-EXTENSION NO INTERVALS,
                  S_VTWEG FOR ZGTSDT1102-VTWEG OBLIGATORY
                                               NO-EXTENSION NO INTERVALS,
                  S_SPART FOR ZGTSDT1102-SPART OBLIGATORY
                                               NO-EXTENSION NO INTERVALS,
                  S_VKGRP FOR ZGTSDT1102-VKGRP OBLIGATORY
                                               NO-EXTENSION NO INTERVALS.
  SELECTION-SCREEN SKIP 1.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT (31) TEXT-002.
    PARAMETERS: P_DEL AS CHECKBOX DEFAULT SPACE.
  SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BL01.
