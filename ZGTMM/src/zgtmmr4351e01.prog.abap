*&---------------------------------------------------------------------*
*& Include          ZGTMMR4351E01
*&---------------------------------------------------------------------*
INITIALIZATION.
  PERFORM F_INITIALIZATION.

AT SELECTION-SCREEN.
  "초기화면 입력 값 점검
  PERFORM F_CHECK_FIELD_VALUE_1000.
  "권한점검
  PERFORM CHECK_AUTH .

AT SELECTION-SCREEN OUTPUT.
  "초기화면 설정
  PERFORM F_SET_SCREEN_ATTR_1000.

START-OF-SELECTION.
  PERFORM F_START_OF_SELECTION.

END-OF-SELECTION.
  PERFORM F_END_OF_SELECTION.
