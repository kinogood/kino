*&---------------------------------------------------------------------*
*& Include          ZGTPPR4100S01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Section Screen                                                       *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-t01.
  PARAMETERS p_werks TYPE zppt0600-werks        MODIF ID obl.
  PARAMETERS p_insmm TYPE zppt0600-insmm        MODIF ID obl.
  SELECT-OPTIONS s_lgort FOR zppt0600-lgort     MODIF ID obl.
  SELECT-OPTIONS s_matnr FOR zppt0610-matnr     MODIF ID dsp.
  SELECT-OPTIONS s_iblnr FOR zppt0610-iblnr     MODIF ID dsp.
  SELECT-OPTIONS s_mblnr FOR zppt0610-mblnr     MODIF ID dsp.
  SELECT-OPTIONS s_crdat FOR zppt0610-crdat     MODIF ID dsp.
SELECTION-SCREEN END OF BLOCK blk1.

SELECTION-SCREEN BEGIN OF BLOCK blk2 WITH FRAME TITLE TEXT-t02.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETER p_post RADIOBUTTON  GROUP g1 USER-COMMAND u1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (20) TEXT-c11 FOR FIELD p_post.
    PARAMETER p_disp RADIOBUTTON GROUP g1.
    SELECTION-SCREEN COMMENT (20) TEXT-c12 FOR FIELD p_disp.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK blk2.

SELECTION-SCREEN BEGIN OF BLOCK blk3 WITH FRAME TITLE TEXT-t03.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETER p_raw RADIOBUTTON  GROUP g2 USER-COMMAND u2 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (20) TEXT-c21 FOR FIELD p_raw.
    PARAMETER p_halb RADIOBUTTON GROUP g2.
    SELECTION-SCREEN COMMENT (20) TEXT-c22 FOR FIELD p_halb.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK blk3.

SELECTION-SCREEN BEGIN OF BLOCK blk4 WITH FRAME TITLE TEXT-t04.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_opt1 AS CHECKBOX DEFAULT 'X'               MODIF ID pst.
    SELECTION-SCREEN COMMENT (15) TEXT-c31 FOR FIELD p_opt1 MODIF ID pst.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_opt2 AS CHECKBOX DEFAULT 'X'               MODIF ID pst.
    SELECTION-SCREEN COMMENT (15) TEXT-c32 FOR FIELD p_opt2 MODIF ID pst.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK blk4.

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
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_insmm.
  PERFORM f4_insmm.
