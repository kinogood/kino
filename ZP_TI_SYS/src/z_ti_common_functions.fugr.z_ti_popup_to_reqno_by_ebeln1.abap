FUNCTION Z_TI_POPUP_TO_REQNO_BY_EBELN1.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(XEBELN) TYPE  EBELN
*"  EXPORTING
*"     VALUE(XREQNO) TYPE  ZTIREQNO
*"     VALUE(XAMDSQ) TYPE  ZTIAMDSQ
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------
  CLEAR: xreqno, xamdsq.

  REFRESH : it_reqno. CLEAR: it_reqno.
  SELECT  reqno amdsq reqty lifnr bukrs ekorg ekgrp ekgrp docst
          appun appdt apptm
    INTO  CORRESPONDING FIELDS OF TABLE it_reqno
    FROM  ZTIvrq00
   WHERE  ebeln EQ xebeln
   GROUP  by reqno amdsq reqty lifnr bukrs ekorg ekgrp ekgrp docst
             appun appdt apptm.

  IF sy-subrc NE 0.
    MESSAGE e917 RAISING not_found.
  ENDIF.

  FREE : t_fieldcat.  CLEAR: t_fieldcat.
  mfc 'IT_REQNO'   'REQNO'    'ZTIVRQ00' 'REQNO' '' '' ''.
  mfc 'IT_REQNO'   'AMDSQ'    'ZTIVRQ00' 'AMDSQ' '' '' ''.
  mfc 'IT_REQNO'   'REQTY'    'ZTIVRQ00' 'REQTY' '' '' ''.
  mfc 'IT_REQNO'   'DOCST'    'ZTIVRQ00' 'DOCST' '' '' ''.
  mfc 'IT_REQNO'   'APPUN'    'ZTIVRQ00' 'APPUN' '' '' ''.
  mfc 'IT_REQNO'   'APPDT'    'ZTIVRQ00' 'APPDT' '' '' ''.
  mfc 'IT_REQNO'   'APPTM'    'ZTIVRQ00' 'APPTM' '' '' ''.

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
  PERFORM get_ftext(rddfie00) USING    'EKKO' 'EBELN' sy-langu
                               CHANGING dfies g_subrc.

  IF g_subrc EQ 0.
    CONCATENATE dfies-scrtext_m ':' xebeln INTO g_title.
  ELSE.
    g_title = xebeln.
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
      i_tabname               = 'IT_REQNO'
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
      t_outtab                = it_reqno[]
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  READ TABLE IT_REQNO INDEX gs_selfield-tabindex.

  IF sy-subrc EQ 0.
    MOVE : IT_REQNO-REQNO TO XREQNO,
           IT_REQNO-AMDSQ TO XAMDSQ.
  ELSE.
    MESSAGE s906(ZMTI00).
  ENDIF.

*  IF sy-subrc <> 0.
*    MESSAGE i000(0k) WITH sy-subrc.
*  ENDIF.

ENDFUNCTION.
