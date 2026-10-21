FUNCTION z_ti_popup_to_igrno_by_iblno.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(XIBLNO) TYPE  ZTIIBLNO
*"  EXPORTING
*"     VALUE(XIGRNO) TYPE  ZTIIGRNO
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------
  CLEAR: xigrno.

  REFRESH : it_igrno. CLEAR: it_igrno.
  SELECT    igrno iccno  grseq iblno
            lifnr bukrs  bldat budat cnam   cdat
            igrst igrty  bwart
    INTO  CORRESPONDING FIELDS OF TABLE it_igrno
    FROM  ztitgrk
   WHERE  iblno EQ xiblno.

  IF sy-subrc NE 0.
    MESSAGE e917 RAISING not_found.
  ENDIF.

  FREE : t_fieldcat.  CLEAR: t_fieldcat.
  mfc 'IT_IGRNO'   'IGRNO'    'ZTITGRK' 'IGRNO' '' '' ''.
  mfc 'IT_IGRNO'   'ICCNO'    'ZTITGRK' 'ICCNO' '' '' ''.
  mfc 'IT_IGRNO'   'GRSEQ'    'ZTITGRK' 'GRSEQ' '' '' ''.
  mfc 'IT_IGRNO'   'IBLNO'    'ZTITGRK' 'IBLNO' '' '' ''.
*  mfc 'IT_IGRNO'   'BLDTY'    'ZTITGRK' 'BLDTY' '' '' ''.
  mfc 'IT_IGRNO'   'LIFNR'    'ZTITGRK' 'LIFNR' '' '' ''.
  mfc 'IT_IGRNO'   'BLDAT'    'ZTITGRK' 'BLDAT' '' '' ''.
  mfc 'IT_IGRNO'   'BUDAT'    'ZTITGRK' 'BUDAT' '' '' ''.
  mfc 'IT_IGRNO'   'IGRST'    'ZTITGRK' 'IGRST' '' '' ''.
  mfc 'IT_IGRNO'   'IGRTY'    'ZTITGRK' 'IGRTY' '' '' ''.
  mfc 'IT_IGRNO'   'BWART'    'ZTITGRK' 'BWART' '' '' ''.

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
  PERFORM get_ftext(rddfie00) USING    'ZTITGRK' 'IBLNO' sy-langu
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
      i_tabname               = 'IT_IGRNO'
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
      t_outtab                = it_igrno[]
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  READ TABLE it_igrno INDEX gs_selfield-tabindex.

  IF sy-subrc EQ 0.
    MOVE : it_igrno-igrno TO xigrno.
  ELSE.
    MESSAGE s906(ZMTI00).
  ENDIF.

ENDFUNCTION.
