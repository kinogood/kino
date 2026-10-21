FUNCTION Z_TI_POPUP_TO_IVONO_BY_IBLNO.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(XIBLNO) TYPE  ZTIIBLNO
*"  EXPORTING
*"     VALUE(XIVONO) TYPE  ZTIIVONO
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------
  CLEAR: xivono.

  REFRESH : it_ivono. CLEAR: it_ivono.
  SELECT ivono ivnum prpyn livst lifnr
         ivamp bukrs ekorg ekgrp civdt
         cnam  cdat
    INTO  CORRESPONDING FIELDS OF TABLE it_ivono
    FROM  ZTIviv02
   WHERE  iblno EQ xiblno.

  IF sy-subrc NE 0.
    MESSAGE e917 RAISING not_found.
  ENDIF.

  LOOP AT it_ivono.
    SELECT SINGLE name1
      INTO it_ivono-name1
      FROM lfa1
     WHERE lifnr EQ it_ivono-lifnr.
    MODIFY it_ivono.
  ENDLOOP.

  FREE : t_fieldcat.  CLEAR: t_fieldcat.
  mfc 'IT_IVONO'   'IVONO'    'ZTITIVK' 'IVONO' ' ' '' ''.
  mfc 'IT_IVONO'   'IVNUM'    'ZTITIVK' 'IVNUM' 'X' '' ''.
  mfc 'IT_IVONO'   'LIFNR'    'ZTITIVK' 'LIFNR' ' ' '' ''.
  mfc 'IT_IVONO'   'NAME1'    'LFA1'     'NAME1' ' ' '' ''.
  mfc 'IT_IVONO'   'IVAMT'    'ZTITIVK' 'IVAMT' ' ' '' ''.
  mfc 'IT_IVONO'   'PRPYN'    'ZTITIVK' 'PRPYN' ' ' '' ''.
  mfc 'IT_IVONO'   'LIVST'    'ZTITIVK' 'LIVST' ' ' '' ''.
  mfc 'IT_IVONO'   'CNAM'     'ZTITIVK' 'CNAM'  ' ' '' ''.
  mfc 'IT_IVONO'   'CDAT'     'ZTITIVK' 'CDAT'  ' ' '' ''.

*  LOOP AT t_fieldcat.
*    IF t_fieldcat-fieldname EQ 'MICON'.
*      t_fieldcat-icon = 'X'.
*      t_fieldcat-seltext_l = 'Status'.
*      t_fieldcat-seltext_m = 'Status'.
*      t_fieldcat-seltext_s = 'Status'.
*      t_fieldcat-ddictxt   = 'S'.
*      t_fieldcat-just = 'C'.
*      t_fieldcat-outputlen = 7.
*    ELSEIF t_fieldcat-fieldname EQ 'MSGTX'.
*      t_fieldcat-outputlen = 70.
**      t_fieldcat-hotspot = 'X'.
*    ELSEIF t_fieldcat-fieldname EQ 'MSGTY'.
*      t_fieldcat-just = 'C'.
*    ENDIF.
*    MODIFY t_fieldcat INDEX sy-tabix.
*  ENDLOOP.
*
  PERFORM get_ftext(rddfie00) USING    'ZTITBLK' 'IBLNO' sy-langu
                               CHANGING dfies g_subrc.

  IF g_subrc EQ 0.
    CONCATENATE dfies-scrtext_m ':' xiblno INTO g_title.
  ELSE.
    g_title = xiblno.
  ENDIF.
  REFRESH: extab.

  APPEND '&NT1'      TO extab.
  APPEND '&ALL'      TO extab.
  APPEND '&SAL'      TO extab.
*  APPEND '&IC1'      TO extab.
*  APPEND '&ETA'      TO extab.
*
  dyname = 'SAPLZ_TI_COMMON_FUNCTIONS'.

  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title                 = g_title
*      i_selection             = 'X'
      i_allow_no_selection    = 'X'
      i_zebra                 = 'X'
*      i_checkbox_fieldname    = 'BOX'
*      i_linemark_fieldname    = 'BOX'
      i_scroll_to_sel_line    = 'X'
      i_tabname               = 'IT_IVONO'
      it_fieldcat             = t_fieldcat[]
      is_private              = gs_private
*      i_screen_start_column   = 2
*      i_screen_start_line     = 4
*      i_screen_end_column     = 100
*      i_screen_end_line       = 20
      it_excluding            = extab
      i_callback_program      = dyname
*      i_callback_user_command = 'USER_POPUP_COMMAND1'
    IMPORTING
      es_selfield             = gs_selfield
      e_exit                  = g_exit
    TABLES
      t_outtab                = it_ivono[]
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  READ TABLE it_ivono INDEX gs_selfield-tabindex.

  IF sy-subrc EQ 0.
    MOVE : it_ivono-ivono TO xivono.
  ELSE.
    MESSAGE s906(ZMTI00).
  ENDIF.

ENDFUNCTION.
