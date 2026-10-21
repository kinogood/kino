FUNCTION z_ti_number_check.
*"--------------------------------------------------------------------
*"*"로컬인터페이스:
*"       IMPORTING
*"             VALUE(STRING_IN)
*"       EXPORTING
*"             REFERENCE(STRING_OUT)
*"             REFERENCE(HTYPE) LIKE  DD01V-DATATYPE
*"--------------------------------------------------------------------
  DATA: hstring(200).
  DATA: hnum(20) TYPE n.
  DATA: hnum2(20) TYPE n.

  IF string_in CN '1234567890. '.
    htype = 'CHAR'.
    string_out = string_in.
    EXIT.
  ENDIF.
  IF string_in EQ space.
    htype = 'NUMC'.
    string_out = string_in.
    TRANSLATE string_out USING ' 0'.
    EXIT.
  ENDIF.
  MOVE string_in TO hstring.
  WHILE hstring(1) EQ space.
    SHIFT hstring.
  ENDWHILE.
  TRANSLATE hstring USING ' !'.
  IF hstring CS '!'.
    SHIFT hstring BY sy-fdpos PLACES.
    IF hstring CN '! '.
      htype = 'CHAR'.
      string_out = string_in.
      EXIT.
    ELSE.
      MOVE string_in TO hnum.
      MOVE string_in TO string_out.
      MOVE string_out TO hnum2.
      IF hnum NE 0.
        DO.
          SHIFT string_in RIGHT.
          MOVE string_in TO hnum.
          IF hnum = hnum2.
            SHIFT string_out RIGHT.
          ELSE.
            EXIT.
          ENDIF.
        ENDDO.
      ENDIF.
      htype = 'NUMC'.
      TRANSLATE string_out USING ' 0'.
    ENDIF.
  ENDIF.

ENDFUNCTION.
