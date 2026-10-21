FUNCTION z_ti_cut_2bytes_strings.
*"--------------------------------------------------------------------
*"*"로컬인터페이스:
*"       IMPORTING
*"             VALUE(I_STR) TYPE  C
*"             REFERENCE(I_START) TYPE  I
*"             REFERENCE(I_LEN) TYPE  I
*"             REFERENCE(I_EXCLUDE) TYPE  C DEFAULT ' '
*"       EXPORTING
*"             REFERENCE(O_STR) TYPE  C
*"--------------------------------------------------------------------
*-----------------------------------------------------------------------
*            Data Declaration
*-----------------------------------------------------------------------
  DATA: sta TYPE i,    " HEXA location
        flg,           " current 2Byte Pair status
        s_len TYPE i.  " Input String length
  FIELD-SYMBOLS: <str>,             " Hexa Value of input String
                 <xstr> TYPE x.     " Hexa value of 1byte Charater



*-----------------------------------------------------------------------
*            Main Procedure of Function
*-----------------------------------------------------------------------

*--- if Input String doesn't exist, return
  i_str = i_str+i_start.

  s_len = STRLEN( i_str ).
  IF s_len = 0.
    EXIT.
  ENDIF.

*- if Input length is greater than total length, check input length
*  if Input length is smaller than total length, check total length
  IF s_len > i_len.
    s_len = i_len.
  ENDIF.


*--- Begin of correction
  ASSIGN i_str TO <str> TYPE 'X'.
  CLEAR: sta, flg.
  DO s_len TIMES.
    sta = sy-index - 1.

    ASSIGN <str>+sta(1) TO <xstr>.
    IF <xstr> >= '80'.       " 2Byte Character
      IF flg = space.
        flg = 'X'.           " 1st Byte of TWO
      ELSE.
        flg = space.         " 2nd Byte of TWO : Normal Case
      ENDIF.
    ENDIF.
  ENDDO.

*- if valid character is incompletede 2Byte,cut from pre-character
  IF flg = 'X'.           " IF Last character was cut abnormally
    IF i_exclude EQ 'X'.
      s_len = s_len - 1.
    ELSE.
      s_len = s_len + 1.
    ENDIF.
  ENDIF.

  IF s_len EQ 0.
    CLEAR o_str.               "Return Value
  ELSE.
    o_str = i_str(s_len).      "Return Value
  ENDIF.

ENDFUNCTION.
