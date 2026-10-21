*&---------------------------------------------------------------------*
*& Include          ZGTLER1160SCR
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : S_ERDAT FOR ZGTSDT9140-ERDAT OBLIGATORY,
                   S_DLVRQ FOR ZGTSDT9140-DLVRQ,
                   S_CHANG FOR ZGTSDT9140-CHANGENR.

SELECTION-SCREEN END OF BLOCK B1 .
