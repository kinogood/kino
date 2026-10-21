FUNCTION Z_TI_GET_SY_UNAME_TEXT.
*"--------------------------------------------------------------------
*"*"로컬인터페이스:
*"       IMPORTING
*"             VALUE(P_UNAME) TYPE  UNAME OPTIONAL
*"       EXPORTING
*"             VALUE(W_ADRP) TYPE  ADRP
*"             VALUE(W_ADR2) TYPE  ADR2
*"             VALUE(P_FIRST_NAME) TYPE  ADRP-NAME_FIRST
*"             VALUE(P_LAST_NAME) TYPE  ADRP-NAME_LAST
*"             VALUE(P_TEL_NO) TYPE  ADR2-TEL_NUMBER
*"       EXCEPTIONS
*"              NOT_FOUND
*"--------------------------------------------------------------------

  TABLES : ADRP, ADR2, USLOGOND, USDEFAULTS, USADDRESS.
  TYPES : USTYP_T_PARAMETERS.

  DATA : LOGONDATA     LIKE    USLOGOND,
         DEFAULTS      LIKE    USDEFAULTS,
         ADDRESS       LIKE    USADDRESS.

  DATA BEGIN OF PARAMETERS OCCURS 20.
          INCLUDE STRUCTURE USPARAM.
  DATA END OF PARAMETERS.

  CLEAR : W_ADRP, W_ADR2.

  CALL FUNCTION 'SUSR_USER_READ'
       EXPORTING
            USER_NAME            = P_UNAME
            WITH_TEXT            = 'X'
       IMPORTING
            USER_LOGONDATA       = LOGONDATA
            USER_DEFAULTS        = DEFAULTS
            USER_ADDRESS         = ADDRESS
       TABLES
            USER_PARAMETERS      = PARAMETERS
       EXCEPTIONS
            USER_NAME_NOT_EXISTS = 1
            INTERNAL_ERROR       = 2
            OTHERS               = 3.

  IF SY-SUBRC NE 0.
     RAISE  NOT_FOUND.
  ENDIF.

*-----------------------------------------------------------------------
* 사원 (중앙주소관리) Table Select...
*-----------------------------------------------------------------------
  SELECT * FROM ADRP
           WHERE PERSNUMBER EQ ADDRESS-PERSNUMBER
           AND   DATE_FROM  <  SY-DATUM.
    EXIT.
  ENDSELECT.

  IF SY-SUBRC NE 0.
     CLEAR : P_LAST_NAME, P_FIRST_NAME.
  ELSE.
     P_LAST_NAME          =    ADRP-NAME_LAST.
     P_FIRST_NAME         =    ADRP-NAME_FIRST.
     W_ADRP               =    ADRP.
  ENDIF.

  SELECT * FROM ADR2
           WHERE PERSNUMBER EQ ADDRESS-PERSNUMBER
           AND   ADDRNUMBER EQ ADDRESS-ADDRNUMBER
           AND   DATE_FROM  <  SY-DATUM.
    EXIT.
  ENDSELECT.

  IF SY-SUBRC NE 0.
     CLEAR : P_TEL_NO.
  ELSE.
     P_TEL_NO = ADR2-TEL_NUMBER.
     W_ADR2               =    ADR2.
  ENDIF.




ENDFUNCTION.
