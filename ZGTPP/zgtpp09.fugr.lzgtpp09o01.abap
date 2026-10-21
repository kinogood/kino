*----------------------------------------------------------------------*
***INCLUDE LZGTPP09O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module GET_WORK_CENTER_TEXT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE get_work_center_text OUTPUT.

  CLEAR gv_ktext.

  SELECT SINGLE ktext
    INTO @gv_ktext
    FROM crhd_v1
   WHERE werks EQ @zgtppv4140-werks
     AND arbpl EQ @zgtppv4140-arbpl.

ENDMODULE.
