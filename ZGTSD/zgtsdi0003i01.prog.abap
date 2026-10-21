*&---------------------------------------------------------------------*
*& Include          ZGTSDI0001I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  CLEAR : gv_saveok.

  gv_saveok = gv_okcode.
  CLEAR gv_okcode.

  CASE gv_saveok.
    WHEN 'EXIT' OR 'CANC' OR 'CANL' OR 'BACK'.
      CASE sy-dynnr.
        WHEN '0100'.
*          PERFORM FREE_OBJECT.

        WHEN '0200'.

      ENDCASE.

      LEAVE TO SCREEN 0.

  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CLEAR : gv_saveok.

  gv_saveok = gv_okcode.
  CLEAR gv_okcode.

  CASE gv_saveok.
    WHEN 'SEND'.
      IF Rb_10 = 'X'.
        PERFORM send_if_batchjob.
      ELSE.
        PERFORM send_if USING space.
      ENDIF.
    WHEN 'R_SEND'.
      IF Rb_10 = 'X'.
        PERFORM send_if_batchjob.
      ELSE.
        PERFORM send_if USING gc_x.
      ENDIF.
  ENDCASE.

ENDMODULE.
