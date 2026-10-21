FUNCTION ZGTPP_UTILL_TEXTEDIT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_MODE) TYPE  CHAR01 DEFAULT '1'
*"     VALUE(IV_TITLE) TYPE  SY-TITLE
*"  CHANGING
*"     VALUE(CT_TEXT) TYPE  TCHAR255
*"----------------------------------------------------------------------

  gv_mode = IV_MODE.
  GV_TITLE = IV_TITLE.
  GT_TEXT = CT_TEXT.

  CALL SCREEN '0200' STARTING AT 5 5 ENDING AT 120 14.

  CT_TEXT = GT_TEXT.

ENDFUNCTION.
