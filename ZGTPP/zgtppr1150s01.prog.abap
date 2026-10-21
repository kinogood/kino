*&---------------------------------------------------------------------*
*& Include          ZGTPPR1150S01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Section Screen                                                       *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-t01.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(31) TEXT-001 FOR FIELD p_werks.
    PARAMETER p_werks TYPE zgtppt4110-werks DEFAULT gc_werks-6500 MEMORY ID wrk MATCHCODE OBJECT zgthpp_werks.
    SELECTION-SCREEN COMMENT 40(30) p_name1 MODIF ID txt.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(31) TEXT-002 FOR FIELD p_spgcd.
    PARAMETER p_spgcd TYPE zgtppt4110-spgcd DEFAULT 'GP' MEMORY ID zspg MATCHCODE OBJECT zh_pp_spgcd.
    SELECTION-SCREEN COMMENT 40(30) p_descr MODIF ID txt.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(31) TEXT-003.
    PARAMETER p_t1140 RADIOBUTTON  GROUP g1 USER-COMMAND u1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (24) TEXT-c11 FOR FIELD p_t1140.
    PARAMETER p_t1120 RADIOBUTTON GROUP g1.
    SELECTION-SCREEN COMMENT (24) TEXT-c12 FOR FIELD p_t1120.
    PARAMETER p_t1130 RADIOBUTTON GROUP g1.
    SELECTION-SCREEN COMMENT (24) TEXT-c13 FOR FIELD p_t1130.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK blk1.

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
