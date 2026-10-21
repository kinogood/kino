*&---------------------------------------------------------------------*
*& Include          ZGTSDR1040SEL
*&---------------------------------------------------------------------*
** 조회조건.
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_vkorg	FOR zgtsdt1040-vkorg  NO-EXTENSION NO INTERVALS,
                  s_vtweg	FOR zgtsdt1040-vtweg  NO-EXTENSION NO INTERVALS,
                  s_spart	FOR zgtsdt1040-spart  NO-EXTENSION NO INTERVALS,
                  s_vkbur	FOR zgtsdt1040-vkbur  NO-EXTENSION NO INTERVALS
                                                OBLIGATORY,
                  s_vkgrp FOR zgtsdt1040-vkgrp  NO-EXTENSION NO INTERVALS
                                                OBLIGATORY,
                  s_spmon FOR zgtsdt1040-spmon  NO-EXTENSION NO INTERVALS
                                                OBLIGATORY,
                  s_kunag	FOR zgtsdt1040-kunag.
SELECTION-SCREEN: END OF BLOCK b1.
