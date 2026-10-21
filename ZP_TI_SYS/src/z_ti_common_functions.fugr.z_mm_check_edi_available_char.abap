FUNCTION Z_MM_CHECK_EDI_AVAILABLE_CHAR.
*"--------------------------------------------------------------------
*"*"로컬인터페이스:
*"  IMPORTING
*"     VALUE(IN_STRING)
*"  EXPORTING
*"     REFERENCE(EX_SUBRC) TYPE  SUBRC
*"     REFERENCE(EX_FDPOS) TYPE  SYFDPOS
*"--------------------------------------------------------------------
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date       Programmer   Transport#            Description            *
*----------------------------------------------------------------------*
* 2017/11/24  신재호   기능개선 213478 구매승인서 특수문자 체크 추가   *
*----------------------------------------------------------------------*

  DATA: l_datatype            TYPE dd01v-datatype,
        l_data(100)           TYPE c.

  DATA: l_available_char(12) TYPE c VALUE '~!@#$^&*_{}?'.

  CLEAR: ex_subrc, ex_fdpos.

  l_data = in_string.

  CALL FUNCTION 'Z_TI_NUMBER_CHECK'
    EXPORTING
      string_in  = l_data
    IMPORTING
      string_out = l_data
      htype      = l_datatype.

  IF l_datatype EQ 'CHAR'.
    IF in_string CA l_available_char.
      ex_subrc = 4.
    ELSE.
      ex_subrc = 0.
    ENDIF.

    ex_fdpos = sy-fdpos.
  ENDIF.

ENDFUNCTION.
