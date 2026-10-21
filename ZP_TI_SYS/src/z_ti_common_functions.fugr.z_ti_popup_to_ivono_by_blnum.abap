FUNCTION Z_TI_POPUP_TO_IVONO_BY_BLNUM.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(XBLNUM) TYPE  ZTIBLNUM
*"  EXPORTING
*"     VALUE(XIVONO) TYPE  ZTIIVONO
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------
  CLEAR: XIVONO.

  REFRESH : IT_IVONO. CLEAR: IT_IVONO.
  SELECT IVONO IVNUM PRPYN LIVST LIFNR
         IVAMP BUKRS EKORG EKGRP CIVDT
         CNAM  CDAT
    INTO  CORRESPONDING FIELDS OF TABLE IT_IVONO
    FROM  ZTIVIV02
   WHERE  BLNUM EQ XBLNUM.

  IF SY-SUBRC NE 0.
    MESSAGE E917 RAISING NOT_FOUND.
  ENDIF.

  SORT IT_IVONO BY IVONO IVNUM.
  DELETE ADJACENT DUPLICATES FROM IT_IVONO COMPARING ALL FIELDS.

  LOOP AT IT_IVONO.
    SELECT SINGLE NAME1
      INTO IT_IVONO-NAME1
      FROM LFA1
     WHERE LIFNR EQ IT_IVONO-LIFNR.
    MODIFY IT_IVONO.
  ENDLOOP.

  FREE : T_FIELDCAT.  CLEAR: T_FIELDCAT.
  MFC 'IT_IVONO'   'IVONO'    'ZTITIVK' 'IVONO' ' ' '' ''.
  MFC 'IT_IVONO'   'IVNUM'    'ZTITIVK' 'IVNUM' 'X' '' ''.
  MFC 'IT_IVONO'   'LIFNR'    'ZTITIVK' 'LIFNR' ' ' '' ''.
  MFC 'IT_IVONO'   'NAME1'    'LFA1'     'NAME1' ' ' '' ''.
  MFC 'IT_IVONO'   'IVAMP'    'ZTITIVK' 'IVAMT' ' ' '' ''.
  MFC 'IT_IVONO'   'PRPYN'    'ZTITIVK' 'PRPYN' ' ' '' ''.
  MFC 'IT_IVONO'   'LIVST'    'ZTITIVK' 'LIVST' ' ' '' ''.
  MFC 'IT_IVONO'   'CNAM'     'ZTITIVK' 'CNAM'  ' ' '' ''.
  MFC 'IT_IVONO'   'CDAT'     'ZTITIVK' 'CDAT'  ' ' '' ''.

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
  PERFORM GET_FTEXT(RDDFIE00) USING    'ZTITBLK' 'BLNUM' SY-LANGU
                               CHANGING DFIES G_SUBRC.

  IF G_SUBRC EQ 0.
    CONCATENATE DFIES-SCRTEXT_M ':' XBLNUM INTO G_TITLE.
  ELSE.
    G_TITLE = XBLNUM.
  ENDIF.
  REFRESH: EXTAB.

  APPEND '&NT1'      TO EXTAB.
  APPEND '&ALL'      TO EXTAB.
  APPEND '&SAL'      TO EXTAB.
*  APPEND '&IC1'      TO extab.
*  APPEND '&ETA'      TO extab.
*
  DYNAME = 'SAPLZ_TI_COMMON_FUNCTIONS'.

  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      I_TITLE                 = G_TITLE
*      i_selection             = 'X'
      I_ALLOW_NO_SELECTION    = 'X'
      I_ZEBRA                 = 'X'
*      i_checkbox_fieldname    = 'BOX'
*      i_linemark_fieldname    = 'BOX'
      I_SCROLL_TO_SEL_LINE    = 'X'
      I_TABNAME               = 'IT_IVONO'
      IT_FIELDCAT             = T_FIELDCAT[]
      IS_PRIVATE              = GS_PRIVATE
*      i_screen_start_column   = 2
*      i_screen_start_line     = 4
*      i_screen_end_column     = 100
*      i_screen_end_line       = 20
      IT_EXCLUDING            = EXTAB
      I_CALLBACK_PROGRAM      = DYNAME
*      i_callback_user_command = 'USER_POPUP_COMMAND1'
    IMPORTING
      ES_SELFIELD             = GS_SELFIELD
      E_EXIT                  = G_EXIT
    TABLES
      T_OUTTAB                = IT_IVONO[]
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.

  READ TABLE IT_IVONO INDEX GS_SELFIELD-TABINDEX.

  IF SY-SUBRC EQ 0.
    MOVE : IT_IVONO-IVONO TO XIVONO.
  ELSE.
    MESSAGE S906(ZMTI00).
  ENDIF.

ENDFUNCTION.
