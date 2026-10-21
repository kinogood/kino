*&---------------------------------------------------------------------*
*& Include          ZGTPPR1160S01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Section Screen                                                       *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-t01.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETER p_prod RADIOBUTTON  GROUP g1 USER-COMMAND u1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (15) TEXT-c11 FOR FIELD p_prod.
    PARAMETER p_hmat RADIOBUTTON GROUP g1.
    SELECTION-SCREEN COMMENT (15) TEXT-c12 FOR FIELD p_hmat.
    PARAMETER p_comp RADIOBUTTON GROUP g1.
    SELECTION-SCREEN COMMENT (15) TEXT-c13 FOR FIELD p_comp.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK blk1.

SELECTION-SCREEN BEGIN OF BLOCK blk2 WITH FRAME TITLE TEXT-t02.
  SELECT-OPTIONS s_werks FOR aufk-werks MEMORY ID wrk OBLIGATORY.
  SELECT-OPTIONS s_matnr FOR afpo-matnr.
  SELECT-OPTIONS s_dispo FOR marc-dispo.
  SELECT-OPTIONS s_auart FOR aufk-auart.
  SELECT-OPTIONS s_aufnr FOR aufk-aufnr.
  SELECT-OPTIONS s_kdauf FOR afpo-kdauf.
  SELECT-OPTIONS s_kdpos FOR afpo-kdpos.
  SELECT-OPTIONS s_idnrk FOR resb-matnr.
  SELECT-OPTIONS s_gstrp FOR afko-gstrp OBLIGATORY.
  SELECT-OPTIONS s_zpjno FOR vbak-zpjno.
  SELECT-OPTIONS s_bstnk FOR vbak-bstnk.
  PARAMETERS p_hlbex AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK blk2.

SELECTION-SCREEN BEGIN OF BLOCK blk3 WITH FRAME TITLE TEXT-t03.
  SELECT-OPTIONS s_intvl FOR sy-index NO-EXTENSION.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT (31) TEXT-001.
    PARAMETERS p_opt_in AS CHECKBOX DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (15) TEXT-c21 FOR FIELD p_opt_in.
    PARAMETERS p_und_in AS CHECKBOX DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (15) TEXT-c22 FOR FIELD p_und_in.
    PARAMETERS p_ovr_in AS CHECKBOX DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (15) TEXT-c23 FOR FIELD p_ovr_in.
    PARAMETERS p_unp_in AS CHECKBOX DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (15) TEXT-c24 FOR FIELD p_unp_in.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK blk3.

SELECTION-SCREEN BEGIN OF BLOCK blk4 WITH FRAME TITLE TEXT-t04.
  PARAMETERS p_vari TYPE disvariant-variant.
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
**---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f4_variant.
