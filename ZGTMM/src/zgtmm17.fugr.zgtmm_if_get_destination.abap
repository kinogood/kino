FUNCTION ZGTMM_IF_GET_DESTINATION.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_ZIFNO) TYPE  ZGTEIFNO
*"  EXPORTING
*"     REFERENCE(E_ZDEST) TYPE  ZDEST
*"----------------------------------------------------------------------

  CLEAR E_ZDEST.

  DATA LV_GUBUN TYPE ZIFDEST-GUBUN.

  SELECT SINGLE FLD_02
    FROM ZGTPPT1010
    WHERE MODULE_KIND EQ 'MM'
    AND CODEGRP EQ '0600'
    AND FLD_01 EQ @I_ZIFNO
    INTO @LV_GUBUN.

  IF LV_GUBUN IS INITIAL.
    LV_GUBUN = 'IS'.
  ENDIF.

  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      GUBUN                 = LV_GUBUN
    IMPORTING
      DEST_NAME             = E_ZDEST
    EXCEPTIONS
      DESTINATION_NOT_FOUND = 1
      OTHERS                = 2.
  IF SY-SUBRC NE 0.
    CLEAR E_ZDEST.
  ENDIF.

ENDFUNCTION.
