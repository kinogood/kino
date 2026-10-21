FUNCTION Z_TI_POPUP_TO_ILGNO_BY_BLNUM.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(XBLNUM) TYPE  ZTIBLNUM
*"  EXPORTING
*"     VALUE(XILGNO) TYPE  ZTIILGNO
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------
  CLEAR: xilgno.

  REFRESH : it_iblno. CLEAR: it_iblno.
  SELECT  iblno blnum bldty lifnr bukrs ekorg ekgrp bleta bletd
          cnam  cdat  ilgno
    INTO  CORRESPONDING FIELDS OF TABLE it_iblno
    FROM  ZTIvlg01
   WHERE  blnum EQ xblnum.

  IF sy-subrc NE 0.
    MESSAGE e917 RAISING not_found.
  ENDIF.

  FREE : t_fieldcat.  CLEAR: t_fieldcat.
  mfc 'IT_IBLNO'   'ILGNO'    'ZTITLG1' 'ILGNO' '' '' ''.
  mfc 'IT_IBLNO'   'IBLNO'    'ZTITBLK' 'IBLNO' '' '' ''.
  mfc 'IT_IBLNO'   'BLDTY'    'ZTIVRQ00' 'BLDTY' '' '' ''.
  mfc 'IT_IBLNO'   'LIFNR'    'ZTIVRQ00' 'LIFNR' '' '' ''.
  mfc 'IT_IBLNO'   'BLETA'    'ZTIVRQ00' 'BLETA' '' '' ''.
  mfc 'IT_IBLNO'   'BLETD'    'ZTIVRQ00' 'BLETD' '' '' ''.
  mfc 'IT_IBLNO'   'CNAM'     'ZTIVRQ00' 'CNAM'  '' '' ''.
  mfc 'IT_IBLNO'   'CDAT'     'ZTIVRQ00' 'CDAT'  '' '' ''.

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
  PERFORM get_ftext(rddfie00) USING    'ZTITBLK' 'BLNUM' sy-langu
                               CHANGING dfies g_subrc.

  IF g_subrc EQ 0.
    CONCATENATE dfies-scrtext_m ':' xblnum INTO g_title.
  ELSE.
    g_title = xblnum.
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
      i_tabname               = 'IT_IBLNO'
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
      t_outtab                = it_iblno[]
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  READ TABLE it_iblno INDEX gs_selfield-tabindex.

  IF sy-subrc EQ 0.
    MOVE : it_iblno-ilgno TO xilgno.
  ELSE.
    MESSAGE s906(ZMTI00).
  ENDIF.

ENDFUNCTION.
