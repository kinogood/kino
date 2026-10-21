*&---------------------------------------------------------------------*
*& Include          ZGTPPR2380S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.

  PARAMETERS : P_WERKS TYPE WERKS_D OBLIGATORY DEFAULT '6600'.

  SELECT-OPTIONS : S_MATNR FOR MARC-MATNR.

SELECTION-SCREEN END OF BLOCK B1.
