*&---------------------------------------------------------------------*
*& Include          ZGTPPR2200S01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Section Screen                                                       *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-t01.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETER p_manadd RADIOBUTTON  GROUP g1 USER-COMMAND u1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (20) TEXT-c11 FOR FIELD p_manadd.
    PARAMETER p_slsref RADIOBUTTON GROUP g1.
    SELECTION-SCREEN COMMENT (25) TEXT-c12 FOR FIELD p_slsref.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK blk1.

SELECTION-SCREEN BEGIN OF BLOCK blk2 WITH FRAME TITLE TEXT-t02.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(31) TEXT-001 FOR FIELD p_werks.
    PARAMETER p_werks TYPE zgtppt4110-werks MEMORY ID wrk MATCHCODE OBJECT zgthpp_werks.
    SELECTION-SCREEN COMMENT 40(30) p_name1 MODIF ID txt.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(31) TEXT-002 FOR FIELD p_spgcd.
    PARAMETER p_spgcd TYPE zgtppt4110-spgcd MEMORY ID zspg MATCHCODE OBJECT zh_pp_spgcd.
    SELECTION-SCREEN COMMENT 40(30) p_descr MODIF ID txt.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK blk2.

*---------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT                                          *
*---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM at_selection_screen_output.

*---------------------------------------------------------------------*
* AT SELECTION-SCREEN                                                 *
*---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM at_selection_screen.
