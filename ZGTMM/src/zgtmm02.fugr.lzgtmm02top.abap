FUNCTION-POOL ZGTMM02.                      "MESSAGE-ID ..


DATA : GV_DATE LIKE SY-DATLO.

DATA : GV_FDATE LIKE SY-DATUM,
       GV_TDATE LIKE SY-DATUM.

DATA : GV_TYPE,
       GR_VAL TYPE RANGE OF SALK3.


CONSTANTS : GC_E(1)  VALUE 'E',
            GC_I(1)  VALUE 'I',
            GC_S(1)  VALUE 'S',
            GC_1(1)  VALUE '1',
            GC_9(1)  VALUE '9',
            GC_GE(2) VALUE 'GE'.


DEFINE _CALC_DATE.
  CLEAR : GV_DATE.
  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      DATE      = &1
      DAYS      = &2
      MONTHS    = &3
      SIGNUM    = &4
      YEARS     = &5
    IMPORTING
      CALC_DATE = GV_DATE.
END-OF-DEFINITION.
