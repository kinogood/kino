*&---------------------------------------------------------------------*
*& Include          ZGTSDR0012O01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
module status_0100 output.
  set pf-status '0100'.
  set titlebar '0100'.
endmodule.

*&---------------------------------------------------------------------*
*&      Module  DISPLAY_ALV_0100  OUTPUT
*&---------------------------------------------------------------------*
module display_alv_0100 output.

  if go_con is initial.
    create object go_con
      exporting
        repid     = sy-repid
        dynnr     = sy-dynnr
        extension = 3000.

    create object go_grid
      exporting
        i_parent = go_con.

    perform set_layout.
    perform set_fieldcat.
    perform set_exclude.
    perform register_event.

    call method go_grid->set_table_for_first_display
      exporting
        is_layout            = gs_layout
        it_toolbar_excluding = gt_exclude
      changing
        it_outtab            = gt_alv
        it_fieldcatalog      = gt_fcat.

  else.
    gs_stbl-row = 'X'.
    gs_stbl-col = 'X'.
    call method go_grid->refresh_table_display
      exporting
        is_stable = gs_stbl
      exceptions
        finished  = 1
        others    = 2.
  endif.

endmodule.
*&---------------------------------------------------------------------*
*& Module INIT_OBJECT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module init_object output.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.
endmodule.
