*&---------------------------------------------------------------------*
*& Include          ZGTMMR4350E01
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
    PERFORM CHECK_AUTH. "권한 체크
*  PERFORM F_AT_SELECTION_SCREEN.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM F_SET_SCREEN_ATTR_1000.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON P_BUKRS.
  PERFORM F_AT_SCREEN_ON_BUKRS.

AT SELECTION-SCREEN ON P_WERKS.
  PERFORM F_AT_SCREEN_ON_WERKS.

AT SELECTION-SCREEN ON P_GRDAT.
  PERFORM F_AT_SCREEN_ON_GRDAT.

*AT SELECTION-SCREEN ON P_DLDAT.
*  PERFORM F_AT_SCREEN_ON_DLDAT.

AT SELECTION-SCREEN ON P_EBELN.
  PERFORM F_AT_SCREEN_ON_EBELN.

AT SELECTION-SCREEN ON P_EBELP.
  PERFORM F_AT_SCREEN_ON_EBELP.

AT SELECTION-SCREEN ON S_WERKS.
  PERFORM F_AT_SCREEN_ON_S_WERKS.

AT SELECTION-SCREEN ON S_GRDAT.
  PERFORM F_AT_SCREEN_ON_S_GRDAT.

AT SELECTION-SCREEN ON S_DLDAT.
  PERFORM F_AT_SCREEN_ON_S_DLDAT.

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
