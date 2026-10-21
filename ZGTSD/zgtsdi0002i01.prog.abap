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

* [GO-SD][26.02.09] 가온전선 로직 분리  - Start.
  IF gv_go = gc_x.
    CLEAR: gv_error.
  ENDIF.
* [GO-SD][26.02.09] 가온전선 로직 분리  - End.

  CASE gv_saveok.
    WHEN 'SEND'.
* [GO-SD][26.02.09] 가온전선 로직 분리  - Start.
      IF gv_go = gc_x.
        PERFORM send_if_go.
      ELSE.
* [GO-SD][26.02.09] 가온전선 로직 분리  - End.
        PERFORM send_if.
      ENDIF.

    WHEN 'R_SEND'.
      PERFORM resend_if.
    WHEN 'R_SEND2'.
* [GO-SD][26.02.09] 가온전선 로직 분리  - Start.
      IF gv_go = gc_x.
        PERFORM send_if_go.
      ELSE.
* [GO-SD][26.02.09] 가온전선 로직 분리  - End.
        PERFORM resend_if2.
      ENDIF.

  ENDCASE.

ENDMODULE.
