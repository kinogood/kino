*&---------------------------------------------------------------------*
*&  Include           ZGTPPR1120O01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  status_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS 'MENU100'.
  SET TITLEBAR  'TITLE100' WITH gv_tpar1.

ENDMODULE.                 " status_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  initial_container_of_alv  OUTPUT
*&---------------------------------------------------------------------*
MODULE initial_container_of_alv OUTPUT.
  IF gs_container IS INITIAL.
    PERFORM create_and_init_alv  CHANGING gt_data[]
                                          gt_fieldcat
                                          gs_layout.
  ENDIF.
ENDMODULE.                 " initial_container_of_alv  OUTPUT
