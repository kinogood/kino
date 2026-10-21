*&---------------------------------------------------------------------*
*& Include          ZGTMMR2010E01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM F_INITIALIZATION.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  "초기화면 설정
  PERFORM F_SET_SCREEN_ATTR_1000.

AT SELECTION-SCREEN.
  PERFORM CHECK_AUTH. "권한 체크

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON P_BUKRS.
  PERFORM F_AT_SCREEN_ON_BUKRS.

AT SELECTION-SCREEN ON S_WERKS.
  PERFORM F_AT_SCREEN_ON_WERKS.

AT SELECTION-SCREEN ON S_EKORG.
  PERFORM F_AT_SCREEN_ON_EKORG.

AT SELECTION-SCREEN ON S_EKGRP.
  PERFORM F_AT_SCREEN_ON_EKGRP.

*AT SELECTION-SCREEN ON S_BADAT.
*  PERFORM F_AT_SCREEN_ON_BADAT.

*AT SELECTION-SCREEN ON S_ERNAM.
*  PERFORM F_AT_SCREEN_ON_ERNAM.

AT SELECTION-SCREEN ON S_BANFN.
  PERFORM F_AT_SCREEN_ON_BANFN.

AT SELECTION-SCREEN ON S_MATNR.
  PERFORM F_AT_SCREEN_ON_MATNR.

AT SELECTION-SCREEN ON P_WERKS.
  PERFORM F_AT_SCREEN_ON_P_WERKS.

AT SELECTION-SCREEN ON P_EKORG.
  PERFORM F_AT_SCREEN_ON_P_EKORG.

AT SELECTION-SCREEN ON P_EKGRP.
  PERFORM F_AT_SCREEN_ON_P_EKGRP.


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
