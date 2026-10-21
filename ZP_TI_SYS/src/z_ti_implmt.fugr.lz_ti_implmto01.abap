*----------------------------------------------------------------------*
***INCLUDE LZ_TI_IMPLMTO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  get_text_id_desc_scr2901  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_text_id_desc_scr2901 OUTPUT.

  IF NOT ztivigt1-tdobf IS INITIAL AND
     NOT ztivigt1-tdidf IS INITIAL.

    SELECT SINGLE *
      INTO ttxit
      FROM ttxit
     WHERE tdobject = ztivigt1-tdobf
       AND tdid     = ztivigt1-tdidf
       AND tdspras  = sy-langu.
  ENDIF.

  IF NOT ztivigt1-tdobt IS INITIAL AND
     NOT ztivigt1-tdidt IS INITIAL.
    SELECT SINGLE *
      INTO *ttxit
      FROM ttxit
     WHERE tdobject = ztivigt1-tdobt
       AND tdid     = ztivigt1-tdidt
       AND tdspras  = sy-langu.
  ENDIF.

ENDMODULE.                 " get_text_id_desc_scr2901  OUTPUT
