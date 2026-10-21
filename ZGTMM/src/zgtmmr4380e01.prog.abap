*&---------------------------------------------------------------------*
*& Include          ZGTMMR4380E01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM F_INITIALIZATION.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM F_AT_SELECTION_SCREEN.
  PERFORM CHECK_AUTH.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM F_SET_SCREEN_ATTR_1000.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON P_INSMM.
  PERFORM F_AT_SCREEN_ON_INSMM.

AT SELECTION-SCREEN ON P_WERKS.
  PERFORM F_AT_SCREEN_ON_WERKS.

AT SELECTION-SCREEN ON S_LGORT.
  PERFORM F_AT_SCREEN_ON_LGORT.

AT SELECTION-SCREEN ON P_APPUS.
  PERFORM F_AT_SCREEN_ON_APPUS.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM F_START_OF_SELECTION.

*----------------------------------------------------------------------*
* END-OF-SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.
  PERFORM F_END_OF_SELECTION.
