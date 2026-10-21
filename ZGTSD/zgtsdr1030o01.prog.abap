*&---------------------------------------------------------------------*
*& Include          ZGTSDR1030O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  DATA: lt_ucomm  TYPE TABLE OF sy-ucomm.

**
  _clear: lt_ucomm.
  IF rb_dis = 'X'.
    APPEND: 'SAVE' TO lt_ucomm.
  ENDIF.

  SET PF-STATUS '0100' EXCLUDING lt_ucomm.
  SET TITLEBAR  '0100'.

**

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module CREATE_GRID_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE create_grid_0100 OUTPUT.

**
  PERFORM create_grid   USING  '100'
                               go_docking.
**

ENDMODULE.
