*&---------------------------------------------------------------------*
*& Include          ZGTPPR2020O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR '0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_SCHEDULE OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_alv_schedule OUTPUT.

  IF go_grid_merge IS NOT BOUND.
    PERFORM set_object_grid_0100.
    PERFORM set_layout_grid_0100.
    PERFORM call_grid_0100_display.
  ENDIF.

*  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  IF gv_mode_detail IS INITIAL.
    SET PF-STATUS '0200'.
    SET TITLEBAR '0200'.
  ELSE.
    SET PF-STATUS '0300'.
    SET TITLEBAR '0300'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_alv_0200 OUTPUT.

  IF go_grid_0200 IS NOT BOUND.
    PERFORM set_object_grid_0200.
    PERFORM event_handler_register USING go_grid_0200.
    PERFORM set_layout_grid_0200.
    PERFORM set_fieldcat_grid_0200.
    PERFORM set_cell_attribute_grid_0200 .
    PERFORM exclude_of_toolbar_grid_0200.
    PERFORM call_grid_0200_display.
  ENDIF.

  IF go_grid_merge_201 IS NOT BOUND.
    PERFORM set_object_grid_0201.
    PERFORM set_layout_grid_0201.
    PERFORM call_grid_0201_display.
  ENDIF.

  IF gv_mode_detail = abap_true.
    IF go_grid_0300 IS NOT BOUND.
      PERFORM set_object_grid_0300.
      PERFORM event_handler_register_300 USING go_grid_0300.
      PERFORM set_layout_grid_0300.
      PERFORM set_fieldcat_grid_0300.
      PERFORM set_cell_attribute_grid_0300 .
      PERFORM exclude_of_toolbar_grid_0300.
      PERFORM set_f4_field_grid_0300.
      PERFORM call_grid_0300_display.
    ELSE.
      PERFORM set_cell_attribute_grid_0300 .
      PERFORM refresh_grid_300 USING go_grid_0300.
    ENDIF.
  ENDIF.

  PERFORM set_screen.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  SET PF-STATUS '0300'.
  SET TITLEBAR '0300'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_alv_0300 OUTPUT.

  IF go_grid_0300 IS NOT BOUND.
    PERFORM set_object_grid_0300.
    PERFORM event_handler_register_300 USING go_grid_0300.
    PERFORM set_layout_grid_0300.
    PERFORM set_fieldcat_grid_0300.
    PERFORM set_cell_attribute_grid_0300 .
    PERFORM exclude_of_toolbar_grid_0300.
    PERFORM set_f4_field_grid_0300.
    PERFORM call_grid_0300_display.
  ENDIF.

  IF go_grid_merge_301 IS NOT BOUND.
    PERFORM set_object_grid_0301.
    PERFORM set_layout_grid_0301.
    PERFORM call_grid_0301_display.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0400 OUTPUT.
  SET PF-STATUS '0400'.
  IF gv_create_command = 'CR_ORDER'.
    SET TITLEBAR '0400'.
  ELSEIF gv_create_command = 'CR_SI_ORDER'.
    SET TITLEBAR '0401'.
  ELSEIF gv_create_command = 'CR_RP_ORDER'. "2026.07.22.zlsgpp5.SRM2607-09012.
    SET TITLEBAR '0403'.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0410 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0410 OUTPUT.
  SET PF-STATUS '0410'.
  SET TITLEBAR '0410'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0410 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_alv_0410 OUTPUT.
  IF go_grid_0410 IS NOT BOUND.
    PERFORM set_object_grid_0410.
    PERFORM event_handler_register USING go_grid_0410.
    PERFORM set_layout_grid_0410.
    PERFORM set_fieldcat_grid_0410.
    PERFORM exclude_of_toolbar_grid_0410.
    PERFORM call_grid_0410_display.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0420 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0420 OUTPUT.
  SET PF-STATUS '0420'.
  SET TITLEBAR '0420'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SCREEN_INIT_420 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE screen_init_420 OUTPUT.

  LOOP AT SCREEN.
    CASE gv_gubun.
      WHEN 'FR'.
        IF screen-group1 = 'TO'.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.

      WHEN 'TO'.
        IF screen-group1 = 'FR'.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.

  ENDLOOP.

ENDMODULE.
