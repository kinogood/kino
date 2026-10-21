*&---------------------------------------------------------------------*
*& Report ZGTPPU9998
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zgtppu9998.

**********************************************************************
*** Selection Screen ***
PARAMETERS: p_dummy AS CHECKBOX MODIF ID m1. "Dummy Parameter
SELECTION-SCREEN COMMENT /1(50) gv_cmnt.
**********************************************************************


INITIALIZATION.
  gv_cmnt = 'Dummy Program으로 사용 주의'.


AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'M1'.
      screen-output = '0'. "* Hide the "Dummy" field
      screen-active = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


START-OF-SELECTION.
**********************************************************************
*** 하단 로직 추가 ***
  BREAK-POINT.



  BREAK-POINT.
