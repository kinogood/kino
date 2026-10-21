*&---------------------------------------------------------------------*
*& Include          ZGTSDR1080_CHECK_SEL
*&---------------------------------------------------------------------*

SELECT-OPTIONS : s_wadat FOR likp-wadat_ist OBLIGATORY  NO-EXTENSION.
SELECT-OPTIONS : s_auart FOR vbak-auart.
PARAMETERS : p_vkorg LIKE vbak-vkorg OBLIGATORY MEMORY ID vko DEFAULT 1000.
SELECT-OPTIONS : s_vtweg FOR vbak-vtweg NO-EXTENSION NO INTERVALS.
SELECT-OPTIONS : s_kunnr FOR vbak-kunnr.
SELECT-OPTIONS : s_payer FOR vbak-kunnr.
SELECT-OPTIONS : s_vkgrp FOR vbak-vkgrp.
SELECT-OPTIONS : s_vbeln FOR lips-vbeln.
*SELECT-OPTIONS : s_fkdat FOR vbrk-fkdat.
SELECT-OPTIONS : s_KDKG4 FOR vbkd-kdkg4.
SELECT-OPTIONS : s_fksta FOR vbup-fksta OBLIGATORY DEFAULT 'C'
                                NO INTERVALS,
                   s_absta FOR vbup-absta NO INTERVALS.
SELECT-OPTIONS : s_spart FOR vbak-spart MEMORY ID spa,
                   s_vkbur FOR vbak-vkbur.
