FUNCTION z_ti_get_other_document_text.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IM_DISPLAY) TYPE  C DEFAULT SPACE
*"  EXPORTING
*"     VALUE(P_ANSWER) TYPE  C
*"  TABLES
*"      XZTISIG52 STRUCTURE  ZTISIG52 OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------
  DATA: l_text32(32)   TYPE c.

  CLEAR: p_answer.

  SELECT  *
    INTO  CORRESPONDING FIELDS OF TABLE xztisig52
    FROM  ztitig52.

  IF sy-subrc NE 0.
    MESSAGE e042 WITH '기타 추가문서' RAISING not_found.
  ENDIF.

  FREE : t_fieldcat.  CLEAR: t_fieldcat.
  IF IM_DISPLAY EQ 'X'.
    mfc 'XZTISIG52'  'BOX'      'ZTISIG52' 'BOX'   'X' '' ''.
  ELSE.
    mfc 'XZTISIG52'  'BOX'      'ZTISIG52' 'BOX'   ' ' '' ''.
  ENDIF.
  mfc 'XZTISIG52'  'OUTSQ'    'ZTISIG52' 'OUTSQ' '' '' ''.
  mfc 'XZTISIG52'  'LTEXT'    'ZTISIG52' 'LTEXT' '' '' ''.
  mfc 'XZTISIG52'  'BASTX'    'ZTISIG52' 'BASTX' '' '' ''.
  mfc 'XZTISIG52'  'TXTCL'    'ZTISIG52' 'TXTCL' '' '' ''.

  g_title = '기타 추가문서 선택화면'.

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
      i_tabname               = 'XZTISIG52'
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
      t_outtab                = xztisig52[]
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
