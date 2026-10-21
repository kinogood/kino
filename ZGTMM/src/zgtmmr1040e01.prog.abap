*&---------------------------------------------------------------------*
*& Include          ZGTMMR1040E01
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
  "상단 버튼
  PERFORM F_AT_SELECTION_SCREEN.
"권한
  PERFORM CHECK_AUTH.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  "초기화면 설정
  PERFORM F_SET_SCREEN_ATTR_1000.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON P_BUKRS.
  PERFORM F_AT_SCREEN_ON_BUKRS.

AT SELECTION-SCREEN ON P_EKORG.
  PERFORM F_AT_SCREEN_ON_EKORG.

AT SELECTION-SCREEN ON P_WERKS.
  PERFORM F_AT_SCREEN_ON_WERKS.

AT SELECTION-SCREEN ON P_LIFNR.
  PERFORM F_AT_SCREEN_ON_LIFNR.

AT SELECTION-SCREEN ON P_YEAR.
  PERFORM F_AT_SCREEN_ON_YEAR.

AT SELECTION-SCREEN ON P_FILE.
  PERFORM F_AT_SCREEN_ON_FILE.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE. "파일 경로
  PERFORM F_F4_FILE USING P_FILE.

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
