*&---------------------------------------------------------------------*
*& Include          ZGTLER2100O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  DATA: lt_ucomm  TYPE TABLE OF sy-ucomm.

**
  _clear: lt_ucomm.
  IF rb1 = 'X'.
    APPEND: 'GT' TO lt_ucomm.

  ELSE.
    APPEND: 'GI'    TO lt_ucomm,
            'SGORT' TO lt_ucomm.

  ENDIF.

  SET PF-STATUS '100' EXCLUDING lt_ucomm.
  SET TITLEBAR '100'.

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

*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS '200'.
  SET TITLEBAR '200'.
ENDMODULE.
