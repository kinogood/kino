*&---------------------------------------------------------------------*
*& Include          ZGTLER1150O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  DATA: lt_ucomm  TYPE TABLE OF sy-ucomm.

**
  _clear: lt_ucomm.

  CASE 'X'.
    WHEN rb_new.    " 신규발행
      APPEND: 'REVERSE' TO lt_ucomm.
*              'DOWN'    TO lt_ucomm.

      SET TITLEBAR  '0100'.

    WHEN rb_re.     " 재발행
      APPEND: 'REVERSE' TO lt_ucomm.

      SET TITLEBAR  '0110'.

    WHEN rb_canc.   " 취소
      APPEND: 'PREVIEW' TO lt_ucomm,
              'PRINT'   TO lt_ucomm.

      SET TITLEBAR  '0120'.

  ENDCASE.

  SET PF-STATUS '0100'  EXCLUDING lt_ucomm.

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
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

**
  SET PF-STATUS '0200'.
  SET TITLEBAR  '0200'   WITH gv_title.

**

ENDMODULE.
