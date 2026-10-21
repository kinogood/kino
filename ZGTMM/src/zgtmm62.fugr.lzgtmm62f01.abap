*----------------------------------------------------------------------*
***INCLUDE LZGTMM62F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_RST_MSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_RST_MSG USING PV_RST
                       PV_MSG.

  GV_RST = PV_RST.
  GV_MSG = PV_MSG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_NUMBER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      <-- GT_6210_JOBLS
*&---------------------------------------------------------------------*
FORM GET_NUMBER USING PV_RANGE
                      PV_OBJECT
             CHANGING PV_NUMBER.

  CLEAR : PV_NUMBER.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = CONV NRNR( PV_RANGE )
      OBJECT                  = CONV NROBJ( PV_OBJECT )
*     QUANTITY                = '1'
*     SUBOBJECT               = ' '
*     TOYEAR                  = '0000'
*     IGNORE_BUFFER           = ' '
    IMPORTING
      NUMBER                  = PV_NUMBER
*     QUANTITY                =
*     RETURNCODE              =
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TIMESTAMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_TIMESTAMP USING PV_CREA
                         PV_CHNG.

  CLEAR : GS_CREA, GS_CHNG.

  IF PV_CREA = GC_X.
    PERFORM SET_TSTMP USING GS_CREA.
  ENDIF.

  IF PV_CHNG = GC_X.
    PERFORM SET_TSTMP USING GS_CHNG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TSTMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_CREA
*&---------------------------------------------------------------------*
FORM SET_TSTMP USING PS_TIME.

  ASSIGN COMPONENT 1 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_DATUM>).
  ASSIGN COMPONENT 2 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_DATLO>).
  ASSIGN COMPONENT 3 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_UZEIT>).
  ASSIGN COMPONENT 4 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_TIMLO>).
  ASSIGN COMPONENT 5 OF STRUCTURE PS_TIME TO FIELD-SYMBOL(<LFS_UNAME>).

  <LFS_DATUM> = SY-DATUM.
  <LFS_DATLO> = SY-DATLO.
  <LFS_UZEIT> = SY-UZEIT.
  <LFS_TIMLO> = SY-TIMLO.
  <LFS_UNAME> = SY-UNAME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_EXIT_PDATE_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_DATA_ZVALUE08
*&      <-- GT_6210_EINDT
*&---------------------------------------------------------------------*
FORM CONVERSION_EXIT_PDATE_INPUT USING PV_IVAL
                              CHANGING PV_OVAL.

  CLEAR : PV_OVAL.
  CHECK PV_IVAL IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_PDATE_INPUT'
    EXPORTING
      INPUT        = PV_IVAL
    IMPORTING
      OUTPUT       = PV_OVAL
    EXCEPTIONS
      INVALID_DATE = 1
      OTHERS       = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_MATN1_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_DATA_ZVALUE10
*&      <-- GT_6210_MATNR
*&---------------------------------------------------------------------*
FORM CONVERT_MATN1_INPUT USING PV_IVAL
                      CHANGING PV_OVAL.

  CLEAR : PV_OVAL.
  CHECK PV_IVAL IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT        = PV_IVAL
    IMPORTING
      OUTPUT       = PV_OVAL
    EXCEPTIONS
      LENGTH_ERROR = 1
      OTHERS       = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REMOVE_SEP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_DATA_ZVALUE12
*&      <-- GT_6210_MENGE
*&---------------------------------------------------------------------*
FORM REMOVE_SEP USING PV_IVAL
             CHANGING PV_OVAL.

  DATA : LV_VAL TYPE ATSCH.


  CLEAR : PV_OVAL.
  CHECK PV_IVAL IS NOT INITIAL.

  LV_VAL = PV_IVAL.
  CL_CHR_TEMPLATE=>REMOVE_SEPARATOR_SIGN( CHANGING C_TEMPLATE = LV_VAL ).

  PV_OVAL = LV_VAL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_EXIT_CUNIT_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_DATA_ZVALUE13
*&      <-- GT_6210_MEINS
*&---------------------------------------------------------------------*
FORM CONVERSION_EXIT_CUNIT_INPUT USING PV_IVAL
                              CHANGING PV_OVAL.

  CLEAR : PV_OVAL.
  CHECK PV_IVAL IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
    EXPORTING
      INPUT          = PV_IVAL
*     LANGUAGE       = SY-LANGU
    IMPORTING
      OUTPUT         = PV_OVAL
    EXCEPTIONS
      UNIT_NOT_FOUND = 1
      OTHERS         = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_CURRENCY_CONV_TO_INTERNAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_DATA_ZVALUE31
*&      --> GT_DATA_ZVALUE32
*&      <-- GT_6210_WAERS
*&      <-- GT_6210_NETPR
*&---------------------------------------------------------------------*
FORM BAPI_CURRENCY_CONV_TO_INTERNAL USING PV_WAERS_I
                                          PV_NETPR_I
                                 CHANGING PV_WAERS_E
                                          PV_NETPR_E.

  PV_WAERS_E = PV_WAERS_I.
  PERFORM REMOVE_SEP USING PV_NETPR_I
                  CHANGING PV_NETPR_E.
* PV_NETPR_E = PV_NETPR_I.

  CHECK PV_NETPR_E IS NOT INITIAL.

  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
    EXPORTING
      CURRENCY             = PV_WAERS_E
      AMOUNT_EXTERNAL      = CONV BAPICURR_D( PV_NETPR_E )
      MAX_NUMBER_OF_DIGITS = 20
    IMPORTING
      AMOUNT_INTERNAL      = PV_NETPR_E.

ENDFORM.
