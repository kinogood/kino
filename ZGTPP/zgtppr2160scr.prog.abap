*&---------------------------------------------------------------------*
*& Include          ZGTPPR2160SCR
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Section Screen                                                       *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-t01.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_wkord RADIOBUTTON GROUP g1 USER-COMMAND u1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (20) TEXT-c11 FOR FIELD p_wkord.
    PARAMETERS p_reslt RADIOBUTTON GROUP g1.
    SELECTION-SCREEN COMMENT (20) TEXT-c12 FOR FIELD p_reslt.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK blk1.

SELECTION-SCREEN BEGIN OF BLOCK blk2 WITH FRAME TITLE TEXT-t02.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_cut RADIOBUTTON GROUP g2 USER-COMMAND u2 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (20) TEXT-c13 FOR FIELD p_cut.
    PARAMETERS p_wnd RADIOBUTTON GROUP g2.
    SELECTION-SCREEN COMMENT (20) TEXT-c14 FOR FIELD p_wnd.
  SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK blk2.

SELECTION-SCREEN BEGIN OF BLOCK blk3 WITH FRAME TITLE TEXT-t03.
  PARAMETERS p_werks TYPE marc-werks.
  SELECT-OPTIONS s_matnr FOR marc-matnr.
SELECTION-SCREEN END OF BLOCK blk3.

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
