*&---------------------------------------------------------------------*
*& Include          ZGTPPI3090O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  CLEAR : gt_ucomm, gt_ucomm[].
  IF p_r1 EQ 'X'.
    APPEND 'RESEND' TO gt_ucomm.
    SET TITLEBAR 'TITLE_100_1'.
  ELSE.
    APPEND 'SEND' TO gt_ucomm.
    SET TITLEBAR 'TITLE_100_2'.
  ENDIF.
  APPEND 'DETAIL' TO gt_ucomm.

  SET PF-STATUS 'STATUS_100' EXCLUDING gt_ucomm.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_SCREEN_ATRIBUTE OUTPUT
*&---------------------------------------------------------------------*
MODULE set_screen_atribute OUTPUT.

  IF tabstr-activetab IS INITIAL.
    tabstr-activetab        = 'TAB01'.
    gv_dynnr = '0110'.
  ELSE.
    CLEAR : tabstr-%_scrollposition.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_GRID_CONTROL_100 OUTPUT
*&---------------------------------------------------------------------*
MODULE create_alv_grid_control_100 OUTPUT.

  PERFORM create_alv_grid_100.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_GRID OUTPUT
*&---------------------------------------------------------------------*
MODULE create_alv_grid OUTPUT.

  IF gc_custom_container1 IS INITIAL.

    CREATE OBJECT gc_custom_container1
      EXPORTING
        container_name = gc_container_name1.

    CREATE OBJECT gc_alv_grid1
      EXPORTING
        i_parent      = gc_custom_container1
        i_appl_events = 'X'.

    PERFORM set_grid_layo1.

    PERFORM set_grid_fcat1.

*___필요한 function만 삽입
    PERFORM exclude_tb_functions CHANGING gt_exclude.

**   Edit Event 및  Event Handler 등록
*    PERFORM event_handler_register1.

*   화면 display
    PERFORM set_table_for_first_display1.

  ELSE.

    gs_scroll-row = 'X'.
    gs_scroll-col = 'X'.

    CALL METHOD gc_alv_grid1->refresh_table_display
      EXPORTING
        i_soft_refresh = 'X'
        is_stable      = gs_scroll.     "화면 라인 Refresh

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_GRID_0120 OUTPUT
*&---------------------------------------------------------------------*
MODULE create_alv_grid_0120 OUTPUT.

  IF gc_custom_container2 IS INITIAL.

    CREATE OBJECT gc_custom_container2
      EXPORTING
        container_name = gc_container_name2.

    CREATE OBJECT gc_alv_grid2
      EXPORTING
        i_parent      = gc_custom_container2
        i_appl_events = 'X'.

    PERFORM set_grid_layo1.

    PERFORM set_grid_fcat2.

*___필요한 function만 삽입
    PERFORM exclude_tb_functions CHANGING gt_exclude.

**   Edit Event 및  Event Handler 등록
*    PERFORM event_handler_register1.

*   화면 display
    PERFORM set_table_for_first_display2.

  ELSE.

    gs_scroll-row = 'X'.
    gs_scroll-col = 'X'.

    CALL METHOD gc_alv_grid2->refresh_table_display
      EXPORTING
        i_soft_refresh = 'X'
        is_stable      = gs_scroll.     "화면 라인 Refresh

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_GRID_CONTROL_100_C OUTPUT
*&---------------------------------------------------------------------*
MODULE create_alv_grid_control_100_c OUTPUT.

  PERFORM create_and_init_controls.

ENDMODULE.
