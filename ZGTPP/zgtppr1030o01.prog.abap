*&---------------------------------------------------------------------*
*&  Include           ZGTPPR1030O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  status_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'MENU100'.
  SET TITLEBAR 'TITLE100'.

  IF gp_stlan = '6'.
     SET TITLEBAR 'TITLE101'.
  ENDIF.
ENDMODULE.                 " status_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  initial_container_of_100  OUTPUT
*&---------------------------------------------------------------------*
MODULE initial_container_of_100 OUTPUT.
  IF gs_contain_100 IS INITIAL.
     PERFORM create_and_init_100  CHANGING gt_data[]
                                           gt_fldcat100
                                           gs_layout100.
  ENDIF.
ENDMODULE.                 " initial_container_of_100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  initial_container_of_200  OUTPUT
*&---------------------------------------------------------------------*
MODULE initial_container_of_200 OUTPUT.
  IF gs_contain_200 IS INITIAL.
     PERFORM create_and_init_200  CHANGING gt_tail[]
                                           gt_fldcat200
                                           gs_layout200.
  ENDIF.
ENDMODULE.                 " initial_container_of_200  OUTPUT
