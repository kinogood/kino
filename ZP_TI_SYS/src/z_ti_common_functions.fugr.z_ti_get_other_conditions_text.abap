FUNCTION Z_TI_GET_OTHER_CONDITIONS_TEXT.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IM_DISPLAY) TYPE  C DEFAULT SPACE
*"  EXPORTING
*"     VALUE(P_ANSWER) TYPE  C
*"  TABLES
*"      XZTISIG51 STRUCTURE  ZTISIG51 OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------
  DATA: l_text32(32)   TYPE c.

  CLEAR: p_answer.

  SELECT  *
    INTO  CORRESPONDING FIELDS OF TABLE xztisig51
    FROM  ztitig51.

  IF sy-subrc NE 0.
    MESSAGE e042 WITH '기타 부가조건' RAISING not_found.
  ENDIF.

  FREE : t_fieldcat.  CLEAR: t_fieldcat.
  IF IM_DISPLAY EQ 'X'.
    mfc 'XZTISIG51'  'BOX'      'ZTISIG51' 'BOX'   'X' '' ''.
  ELSE.
    mfc 'XZTISIG51'  'BOX'      'ZTISIG51' 'BOX'   ' ' '' ''.
  ENDIF.
  mfc 'XZTISIG51'  'OUTSQ'    'ZTISIG51' 'OUTSQ' '' '' ''.
  mfc 'XZTISIG51'  'LTEXT'    'ZTISIG51' 'LTEXT' '' '' ''.
  mfc 'XZTISIG51'  'BASTX'    'ZTISIG51' 'BASTX' '' '' ''.

  g_title = '기타 부가조건 선택화면'.

  REFRESH: extab.

*  APPEND '&NT1'      TO extab.
*  APPEND '&ALL'      TO extab.
*  APPEND '&SAL'      TO extab.
*  APPEND '&IC1'      TO extab.
*  APPEND '&ETA'      TO extab.

  dyname = 'SAPLZ_TI_COMMON_FUNCTIONS'.

  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title                 = g_title
      i_selection             = 'X'
      i_allow_no_selection    = 'X'
      i_zebra                 = 'X'
      i_checkbox_fieldname    = 'BOX'
      i_linemark_fieldname    = 'BOX'
      i_scroll_to_sel_line    = 'X'
      i_tabname               = 'XZTISIG51'
      it_fieldcat             = t_fieldcat[]
      is_private              = gs_private
      i_screen_start_column   = 1
      i_screen_start_line     = 1
*      i_screen_end_column     = 100
*      i_screen_end_line       = 20
      it_excluding            = extab
      i_callback_program      = dyname
*      i_callback_user_command = 'USER_POPUP_COMMAND1'
    IMPORTING
      es_selfield             = gs_selfield
      e_exit                  = g_exit
    TABLES
      t_outtab                = xztisig51[]
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  IF sy-subrc EQ 0.
    IF g_exit IS INITIAL.
      p_answer = 'Y'.
    ELSE.
      p_answer = 'N'.
    ENDIF.
  ENDIF.

ENDFUNCTION.
