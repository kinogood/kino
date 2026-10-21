*&---------------------------------------------------------------------*
*& Include          ZGTMMR6210O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module PBO_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE PBO_0100 OUTPUT.

  CHECK GR_DOCK IS INITIAL.

  SET PF-STATUS '0100'.
  SET TITLEBAR  '0100'.

  PERFORM SET_OBJ.
  PERFORM SET_EXCL.
  PERFORM SET_LAYO.
* PERFORM SET_FCAT.
  PERFORM SET_SORT.
  PERFORM SET_EVNT.
  PERFORM SET_DISP.

ENDMODULE.
