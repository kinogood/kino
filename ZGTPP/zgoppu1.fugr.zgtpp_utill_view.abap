FUNCTION ZGTPP_UTILL_VIEW.
*"----------------------------------------------------------------------
*"*"Global Interface:
*"  IMPORTING
*"     VALUE(IV_TABNAME) TYPE  TABNAME OPTIONAL
*"     VALUE(IV_TITLE) TYPE  SY-TITLE OPTIONAL
*"----------------------------------------------------------------------


* 입력받은 테이블 명으로 데이터를 구한다
  PERFORM READ_DATA.

  call SCREEN '0100'.

ENDFUNCTION.
