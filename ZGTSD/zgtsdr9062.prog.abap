*&---------------------------------------------------------------------*
*& Report ZGTSDR9062
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGTSDR9062 MESSAGE-ID ZGTSD01 NO STANDARD PAGE HEADING..

INCLUDE ZGTSDR9062TOP.
INCLUDE ZGTSDR9062C01. " Class(Event Handler)
INCLUDE ZGTSDR9062SEL. " Selection-Screen
INCLUDE ZGTSDR9062O01. " PBO-Modules
INCLUDE ZGTSDR9062I01. " PAI-Modules
INCLUDE ZGTSDR9062F01. " FORM-Routines


*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM INITIALIZATION.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_SCREEN.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

  "입력값 체크
  PERFORM CHECK_INPUT_DATA.
  CHECK GV_ERROR IS INITIAL.

  "권한 체크
  PERFORM AUTHORITY_CHECK.

  "데이터 구성
  PERFORM DATA_QUERY USING SPACE.

*----------------------------------------------------------------------*
* END-OF-SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.

  CHECK GV_ERROR IS INITIAL.

  IF SY-BATCH  IS INITIAL.
    CALL SCREEN 0100.
  ENDIF.
