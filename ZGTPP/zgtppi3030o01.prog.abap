*&---------------------------------------------------------------------*
*& Include          ZGTPPI1030O01
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

  SET PF-STATUS 'STATUS_100' EXCLUDING gt_ucomm.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_INSTANCE_CONTROLS OUTPUT
*&---------------------------------------------------------------------*
MODULE create_instance_controls OUTPUT.

  PERFORM create_and_init_controls.

ENDMODULE.
