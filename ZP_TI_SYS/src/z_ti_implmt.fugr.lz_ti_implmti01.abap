*----------------------------------------------------------------------*
***INCLUDE LZ_TI_IMPLMTI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  set_update_data_scr2901  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_update_data_scr2901 INPUT.

  IF ztivigt1-tdobf IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTIVIGT1' 'TDOBF'.
  ENDIF.
  IF ztivigt1-tdidf IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTIVIGT1' 'TDIDF'.
  ENDIF.

  IF ztivigt1-tdobt IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTIVIGT1' 'TDOBT'.
  ENDIF.
  IF ztivigt1-tdidt IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTIVIGT1' 'TDIDT'.
  ENDIF.

  IF  ztivigt1-cnam IS INITIAL.
    MOVE: sy-uname   TO   ztivigt1-cnam,
          sy-datlo   TO   ztivigt1-cdat,
          sy-timlo   TO   ztivigt1-ctme.
  ENDIF.

  MOVE: sy-uname   TO  ztivigt1-unam,
        sy-datlo   TO  ztivigt1-udat,
        sy-timlo   TO  ztivigt1-utme.

ENDMODULE.                 " set_update_data_scr2901  INPUT
*&---------------------------------------------------------------------*
*&      Module  help_source_text_object  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE help_source_text_object INPUT.

  PERFORM get_f4_for_tdobt_dynpro.

ENDMODULE.                 " help_source_text_object  INPUT
*&---------------------------------------------------------------------*
*&      Module  set_update_data_scr0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_update_data_scr0200 INPUT.

  IF ztitig02-bstyp IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG02' 'BSTYP'.
  ENDIF.

  IF ztitig02-bsart IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG02' 'BSART'.
  ENDIF.

  IF ztitig02-zterm IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG02' 'ZTERM'.
  ENDIF.

  IF ztitig02-reqty IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG02' 'REQTY'.
  ENDIF.

  IF ztitig02-reqty EQ 'TT'.
    IF ztitig02-aftyn IS INITIAL.
      PERFORM no_input(sapfmmex) USING 'ZTITIG02' 'AFTYN'.
    ENDIF.
  ELSE.
    CLEAR: ztitig02-aftyn.
  ENDIF.

  IF  ztitig02-cnam IS INITIAL.
    MOVE: sy-uname   TO   ztitig02-cnam,
          sy-datlo   TO   ztitig02-cdat,
          sy-timlo   TO   ztitig02-ctme.
  ENDIF.

  MOVE: sy-uname   TO  ztitig02-unam,
        sy-datlo   TO  ztitig02-udat,
        sy-timlo   TO  ztitig02-utme.

ENDMODULE.                 " set_update_data_scr0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  set_update_data_scr0600  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_update_data_scr0600 INPUT.

  IF ztitig06-bukrs IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG06' 'BUKRS'.
  ENDIF.
  IF ztitig06-expgr IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG06' 'EXPGR'.
  ENDIF.
  IF ztitig06-expcd IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG06' 'EXPCD'.
  ENDIF.
  IF ztitig06-exptx IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG06' 'EXPTX'.
  ENDIF.
  IF ztitig06-saknr IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG06' 'SAKNR'.
  ENDIF.
  IF ztitig06-cscty IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG06' 'CSCTY'.
  ELSEIF ztitig06-cscty EQ 'P'.
    IF ztitig06-kschl IS INITIAL.
      PERFORM no_input(sapfmmex) USING 'ZTITIG06' 'KSCHL'.
    ENDIF.
  ELSE.
    CLEAR: ztitig06-kschl.
  ENDIF.

  IF  ztitig06-cnam IS INITIAL.
    MOVE: sy-uname   TO   ztitig06-cnam,
          sy-datlo   TO   ztitig06-cdat,
          sy-timlo   TO   ztitig06-ctme.
  ENDIF.

  MOVE: sy-uname   TO  ztitig06-unam,
        sy-datlo   TO  ztitig06-udat,
        sy-timlo   TO  ztitig06-utme.

ENDMODULE.                 " set_update_data_scr0600  INPUT
*&---------------------------------------------------------------------*
*&      Module  set_update_data_scr0011  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_update_data_scr0011 INPUT.

  IF ztitig00-bukrs IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG00' 'BUKRS'.
  ENDIF.

  IF ztitig00-ccrqm IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG00' 'CCRQM'.
  ENDIF.

  IF ztitig00-blpcs IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG00' 'BLPCS'.
  ENDIF.

  IF ztitig00-sjpap IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG00' 'SJPAP'.
  ENDIF.

  IF ztitig00-pstmt IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG00' 'PSTMT'.
  ENDIF.

  IF  ztitig00-cnam IS INITIAL.
    MOVE: sy-uname   TO   ztitig00-cnam,
          sy-datlo   TO   ztitig00-cdat,
          sy-timlo   TO   ztitig00-ctme.
  ENDIF.

  MOVE: sy-uname   TO  ztitig00-unam,
        sy-datlo   TO  ztitig00-udat,
        sy-timlo   TO  ztitig00-utme.

ENDMODULE.                 " set_update_data_scr0011  INPUT
*&---------------------------------------------------------------------*
*&      Module  help_payment_term_scr0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE help_payment_term_scr0200 INPUT.

  LOOP AT SCREEN.
    IF screen-name EQ 'ZTITIG02-ZTERM'.
      EXIT.
    ENDIF.
  ENDLOOP.

  PERFORM get_f4_for_zterm_dynpro USING ztitig02-zterm.

ENDMODULE.                 " help_payment_term_scr0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  set_update_data_scr1011  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_update_data_scr1011 INPUT.

  IF ztivig10-land1 IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTIVIG10' 'LAND1'.
  ENDIF.

  IF ztivig10-land1 IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTIVIG10' 'FWDCD'.
  ENDIF.

  IF  ztivig10-cnam IS INITIAL.
    MOVE: sy-uname   TO   ztivig10-cnam,
          sy-datlo   TO   ztivig10-cdat,
          sy-timlo   TO   ztivig10-ctme.
  ENDIF.

  MOVE: sy-uname   TO  ztivig10-unam,
        sy-datlo   TO  ztivig10-udat,
        sy-timlo   TO  ztivig10-utme.

ENDMODULE.                 " set_update_data_scr1011  INPUT
*&---------------------------------------------------------------------*
*&      Module  set_update_data_scr1100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_update_data_scr1100 INPUT.

  IF ztitig11-land1 IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG11' 'LAND1'.
  ENDIF.

  IF ztitig11-fwddy IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG11' 'FWDDY'.
  ENDIF.

  IF  ztitig11-cnam IS INITIAL.
    MOVE: sy-uname   TO   ztitig11-cnam,
          sy-datlo   TO   ztitig11-cdat,
          sy-timlo   TO   ztitig11-ctme.
  ENDIF.

  MOVE: sy-uname   TO  ztitig11-unam,
        sy-datlo   TO  ztitig11-udat,
        sy-timlo   TO  ztitig11-utme.

ENDMODULE.                 " set_update_data_scr1100  INPUT
*&---------------------------------------------------------------------*
*&      Module  set_update_data_scr3801  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_update_data_scr3801 INPUT.

  IF ztitig38-bukrs IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG38' 'BUKRS'.
  ENDIF.

  IF  ztitig38-cnam IS INITIAL.
    MOVE: sy-uname   TO   ztitig38-cnam,
          sy-datlo   TO   ztitig38-cdat,
          sy-timlo   TO   ztitig38-ctme.
  ENDIF.

  MOVE: sy-uname   TO  ztitig38-unam,
        sy-datlo   TO  ztitig38-udat,
        sy-timlo   TO  ztitig38-utme.

ENDMODULE.                 " set_update_data_scr3801  INPUT
*&---------------------------------------------------------------------*
*&      Module  set_update_data_scr0700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_update_data_scr0700 INPUT.

  IF ztitig07-bukrs IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG07' 'BUKRS'.
  ENDIF.

  IF ztitig07-cstct IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG07' 'CSTCT'.
  ENDIF.

*  IF ztitig07-blart IS INITIAL.
*    PERFORM no_input(sapfmmex) USING 'ZTITIG07' 'BLART'.
*  ENDIF.
*
*  IF ztitig07-mwskz IS INITIAL.
*    PERFORM no_input(sapfmmex) USING 'ZTITIG07' 'MWSKZ'.
*  ENDIF.

  IF  ztitig07-cnam IS INITIAL.
    MOVE: sy-uname   TO   ztitig07-cnam,
          sy-datlo   TO   ztitig07-cdat,
          sy-timlo   TO   ztitig07-ctme.
  ENDIF.

  MOVE: sy-uname   TO  ztitig07-unam,
        sy-datlo   TO  ztitig07-udat,
        sy-timlo   TO  ztitig07-utme.

ENDMODULE.                 " set_update_data_scr0700  INPUT
*&---------------------------------------------------------------------*
*&      Module  set_update_data_scr0800  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_update_data_scr0800 INPUT.

  IF ztivig08-land1 IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTIVIG08' 'LAND1'.
  ENDIF.

  IF ztivig08-fwdty IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTIVIG08' 'FWDTY'.
  ENDIF.

  IF ztivig08-expvz IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTIVIG08' 'EXPVZ'.
  ENDIF.

  IF  ztivig08-cnam IS INITIAL.
    MOVE: sy-uname   TO   ztivig08-cnam,
          sy-datlo   TO   ztivig08-cdat,
          sy-timlo   TO   ztivig08-ctme.
  ENDIF.

  MOVE: sy-uname   TO  ztivig08-unam,
        sy-datlo   TO  ztivig08-udat,
        sy-timlo   TO  ztivig08-utme.

ENDMODULE.                 " set_update_data_scr0800  INPUT

*&---------------------------------------------------------------------*
*&      Module  help_payment_term_scr0700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE help_payment_term_scr0700 INPUT.

  LOOP AT SCREEN.
    IF screen-name EQ 'ZTITIG07-ZTERM'.
      EXIT.
    ENDIF.
  ENDLOOP.

  PERFORM get_f4_for_zterm_dynpro(ztir9000) USING ztitig07-zterm.

ENDMODULE.                 " help_payment_term_scr0700  INPUT
*&---------------------------------------------------------------------*
*&      Module  set_update_data_scr3900  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_update_data_scr3900 INPUT.

  IF ztivig39-gsber IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTIVIG39' 'GSBER'.
  ENDIF.

  IF ztivig39-kostl IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTIVIG39' 'KOSTL'.
  ENDIF.

  IF  ztivig39-cnam IS INITIAL.
    MOVE: sy-uname   TO   ztivig39-cnam,
          sy-datlo   TO   ztivig39-cdat,
          sy-timlo   TO   ztivig39-ctme.
  ENDIF.

  MOVE: sy-uname   TO  ztivig39-unam,
        sy-datlo   TO  ztivig39-udat,
        sy-timlo   TO  ztivig39-utme.

ENDMODULE.                 " set_update_data_scr3900  INPUT
*&---------------------------------------------------------------------*
*&      Module  SET_UPDATE_DATA_SCR130  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_update_data_scr130 INPUT.




  IF  ztitig13-lifnr IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG13' 'LIFNR'.
  ENDIF.

  IF  ztitig13-tbban  IS INITIAL.
    PERFORM no_input(sapfmmex) USING 'ZTITIG13' 'TBBAN'.
  ENDIF.
  IF  ztitig13-cnam IS INITIAL.
    MOVE: sy-uname   TO   ztitig13-cnam,
          sy-datlo   TO   ztitig13-cdat,
          sy-timlo   TO   ztitig13-ctme.
  ENDIF.

  MOVE: sy-uname   TO  ztitig13-unam,
        sy-datlo   TO  ztitig13-udat,
        sy-timlo   TO  ztitig13-utme.



ENDMODULE.                 " SET_UPDATE_DATA_SCR130  INPUT
