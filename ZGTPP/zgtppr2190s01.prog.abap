*&---------------------------------------------------------------------*
*& Include          ZGTPPR2190S01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Section Screen                                                       *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-t01.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(31) TEXT-001 FOR FIELD p_werks.
    PARAMETER p_werks TYPE zgtppt2270-werks DEFAULT gc_werks-6500
                                            OBLIGATORY
                                            MEMORY ID wrk
                                            MATCHCODE OBJECT zgthpp_werks.
    SELECTION-SCREEN COMMENT 40(30) p_name1 MODIF ID txt.
  SELECTION-SCREEN END OF LINE.

  PARAMETER p_spmon TYPE spmon DEFAULT sy-datum+0(6) OBLIGATORY.
  SELECT-OPTIONS s_equcd FOR zgtppt2270-equcd.
SELECTION-SCREEN END OF BLOCK blk1.

SELECTION-SCREEN FUNCTION KEY 1.
SELECTION-SCREEN FUNCTION KEY 2.

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

*---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST                                *
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_spmon.
  PERFORM f4_spmon.
