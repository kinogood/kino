*&---------------------------------------------------------------------*
*& Include          ZGTPPR3160S01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Section Screen                                                       *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-t01.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETER p_rework RADIOBUTTON GROUP g1 USER-COMMAND u1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (20) TEXT-c11 FOR FIELD p_rework.
    PARAMETER p_disp RADIOBUTTON GROUP g1.
    SELECTION-SCREEN COMMENT (20) TEXT-c12 FOR FIELD p_disp.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK blk1.

SELECTION-SCREEN BEGIN OF BLOCK blk2 WITH FRAME TITLE TEXT-t02.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETER p_cut_sc RADIOBUTTON GROUP g2 USER-COMMAND u2 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (20) TEXT-c13 FOR FIELD p_cut_sc.
    PARAMETER p_shp    RADIOBUTTON GROUP g2.
    SELECTION-SCREEN COMMENT (20) TEXT-c14 FOR FIELD p_shp.
    PARAMETER p_shp_sc RADIOBUTTON GROUP g2.
    SELECTION-SCREEN COMMENT (20) TEXT-c15 FOR FIELD p_shp_sc.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK blk2.

SELECTION-SCREEN BEGIN OF BLOCK blk3 WITH FRAME TITLE TEXT-t03.
  PARAMETER p_werks TYPE zgtppt3360-werks.
  SELECT-OPTIONS s_updrq  FOR zgtppt3360-updrq.
  SELECT-OPTIONS s_tagnr  FOR zgtppt3360-tagnr          MODIF ID 101.
  SELECT-OPTIONS s_cut_no FOR zgtppt3360-zcut_ord_no    MODIF ID 100.
  SELECT-OPTIONS s_cut_it FOR zgtppt3360-zcut_ord_item  MODIF ID 100.
  SELECT-OPTIONS s_dlvrq  FOR zgtppt3360-dlvrq          MODIF ID 010.
  SELECT-OPTIONS s_vbeln  FOR zgtppt3360-vbeln          MODIF ID 011.
  SELECT-OPTIONS s_posnr  FOR zgtppt3360-posnr          MODIF ID 011.
  SELECT-OPTIONS s_crdat  FOR zgtppt3360-crdat.
SELECTION-SCREEN END OF BLOCK blk3.

SELECTION-SCREEN BEGIN OF BLOCK blk4 WITH FRAME TITLE TEXT-t04.
  PARAMETER p_batch AS CHECKBOX MODIF ID rew.
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
