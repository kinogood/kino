*&---------------------------------------------------------------------*
*&  Include           ZSDR1040O01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  modify_screen  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen OUTPUT.

  CHECK r01 EQ 'X'.

  LOOP AT SCREEN.
    IF  screen-group1 = 'GR1'.
      screen-input = 0.
    ENDIF.

    IF screen-group2 = 'HID'.
      screen-active = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " modify_screen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  modify_screen  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen_0300 OUTPUT.

  CHECK g_activetab = 'PUSH2'.



  LOOP AT SCREEN.
    IF sy-ucomm EQ 'CHAN' AND
       screen-group1 = 'GR1'.
      screen-input = 1.
    ENDIF.

    IF screen-group2 EQ 'HID'.
      screen-active = 0.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.



ENDMODULE.                 " modify_screen  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  read_text  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE read_text OUTPUT.

  PERFORM read_notepad.

ENDMODULE.                 " read_text  OUTPUT
