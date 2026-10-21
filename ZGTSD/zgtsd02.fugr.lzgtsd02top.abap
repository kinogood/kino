FUNCTION-POOL zgtsd02.                      "MESSAGE-ID ..

*-----------------------------------------------------------------------
*-- Constants
*-----------------------------------------------------------------------
*-- Range Sign
CONSTANTS : BEGIN OF gc_sign,
              i TYPE ddsign                     VALUE 'I',
              e TYPE ddsign                     VALUE 'E',
            END OF gc_sign,
*-- Range Option
            BEGIN OF gc_optn,
              eq TYPE ddoption                  VALUE 'EQ',
              ne TYPE ddoption                  VALUE 'NE',
              bt TYPE ddoption                  VALUE 'BT',
              cp TYPE ddoption                  VALUE 'CP',
            END OF gc_optn.

* INCLUDE LZGTSD02D...                       " Local class definition

*----------------------------------------------------------------------*
* DEFINE
*----------------------------------------------------------------------*
DEFINE __CLE.
  CLEAR: &1, &1[].
END-OF-DEFINITION.

DEFINE __RNG.
  &1-SIGN   = &2.
  &1-OPTION = &3.
  &1-LOW    = &4.
  &1-HIGH    = &5.
  APPEND &1. CLEAR &1.
END-OF-DEFINITION.

DEFINE __ALPHA_IN.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = &1
    IMPORTING
      OUTPUT = &2.
END-OF-DEFINITION.

DEFINE __ALPHA_OU.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = &1
    IMPORTING
      OUTPUT = &2.
END-OF-DEFINITION.
