*&---------------------------------------------------------------------*
*& Include          ZGTPPR1000S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : s_kind FOR zgtppt1000-module_kind,
                             s_code_g FOR zgtppt1000-codegrp.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  SELECTION-SCREEN COMMENT /1(79) text-s01.
  SELECTION-SCREEN COMMENT /1(79) text-s02.
  SELECTION-SCREEN COMMENT /1(79) text-s03.
  SELECTION-SCREEN COMMENT /1(79) text-s04.
  SELECTION-SCREEN COMMENT /1(79) text-s05.
SELECTION-SCREEN END OF BLOCK b2.
