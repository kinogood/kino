*&---------------------------------------------------------------------*
*& Include          ZGTPPR3010O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  CLEAR : gt_ucomm, gt_ucomm[].
* 백로그 삭제 취소 기능은 삭제 내역 조회일때만 표시
  IF p_del NE 'X'.
    APPEND 'RESTORE' TO gt_ucomm.
  ENDIF.

  SET PF-STATUS 'STATUS_100' EXCLUDING gt_ucomm.

  IF p_del EQ 'X'.
    SET TITLEBAR 'TITLE_100_1'.
  ELSE.
    SET TITLEBAR 'TITLE_100_2'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_INSTANCE_CONTROLS OUTPUT
*&---------------------------------------------------------------------*
MODULE create_instance_controls OUTPUT.

  PERFORM create_and_init_controls.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  SET PF-STATUS '200'.
  SET TITLEBAR '200'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0200 OUTPUT
*&---------------------------------------------------------------------*
MODULE create_alv_0200 OUTPUT.

  IF go_grid_0200 IS NOT BOUND.
    PERFORM set_object_grid_0200.
    PERFORM event_handler_register2 USING go_grid_0200.
    PERFORM set_layout_grid_0200.
    PERFORM set_fieldcat_grid_0200.
    PERFORM exclude_of_toolbar_grid_0200.
    PERFORM call_grid_0200_display.
  ENDIF.

ENDMODULE.
