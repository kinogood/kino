*&---------------------------------------------------------------------*
*& Include          ZGTLER1140O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  DATA: lt_ucomm  TYPE TABLE OF sy-ucomm.

**
  _clear: lt_ucomm.
  IF r_com = 'X'.
    APPEND: 'CANC' TO lt_ucomm.

    SET TITLEBAR '100'.

  ELSE.
    APPEND: 'COM'     TO lt_ucomm,
            'DRIVER'  TO lt_ucomm,
            'GI'      TO lt_ucomm.

    SET TITLEBAR '200'.

  ENDIF.

  SET PF-STATUS '100' EXCLUDING lt_ucomm.

**

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module CREATE_GRID_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE create_grid_0100 OUTPUT.

**
  PERFORM create_alv_grid   USING  '100'
                                   go_costom  "go_docking
                                   go_grid
                                   gt_fcat
                                   gt_toolbar
                                   gt_sort
                                   gs_layout
                                   gs_variant.
**

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0300 OUTPUT.

**
  SET PF-STATUS '0300'.
  SET TITLEBAR  '0300'.

**

ENDMODULE.
