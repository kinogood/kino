*&---------------------------------------------------------------------*
*& Report ZGTTEST_003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGTPPR9995.

PARAMETERS : P_TABLE TYPE SE16N_TAB.

CALL FUNCTION 'SE16N_START'
 EXPORTING
   I_TAB                    = P_TABLE
   I_DISPLAY                = 'X'
*   I_EXIT_SELFIELD_FB       = ' '
*   I_SINGLE_TABLE           = ' '
*   I_HANA                   = ' '
*   I_EMERGENCY              = ' '
          .
