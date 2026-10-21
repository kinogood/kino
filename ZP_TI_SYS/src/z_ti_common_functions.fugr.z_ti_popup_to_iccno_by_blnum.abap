FUNCTION Z_TI_POPUP_TO_ICCNO_BY_BLNUM.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(XBLNUM) TYPE  ZTIBLNUM
*"  EXPORTING
*"     VALUE(XICCNO) TYPE  ZTIICCNO
*"     VALUE(XICCSQ) TYPE  ZTIICCSQ
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------
  CLEAR: xiccno, xiccsq.

  REFRESH : it_iccno. CLEAR: it_iccno.
  SELECT  iccno iccsq cdrdt cdcno lifnr cpyatc cpyat bukrs
          ekorg ekgrp cnam  cdat
    INTO  CORRESPONDING FIELDS OF TABLE it_iccno
    FROM  ztitcck
   WHERE  iblno in ( select iblno
                       from ztitblk
                      where blnum eq xblnum ).

  IF sy-subrc NE 0.
    MESSAGE e917 RAISING not_found.
  ENDIF.
*      iccno   LIKE ztitcck-iccno,    "통관관리번호.
*      CDCNO   LIKE ztitcck-CDCNO,    "신고(수리)번호.
*      lifnr   LIKE ztitcck-lifnr,    "공급업체 계정번호.
*      CPYATc  like ztitcck-CPYATc,   "통화.
*      CPYAT   LIKE ztitcck-CPYAT,    "송장처리금액.
*      bukrs   LIKE ztitcck-bukrs,	   "회사코드.
*      ekorg   LIKE ztitcck-ekorg,	   "구매조직.
*      ekgrp   LIKE ztitcck-ekgrp,	   "구매그룹.
*      cnam    LIKE ztitcck-cnam,     "생성인.
*      cdat    LIKE ztitcck-cdat,     "생성일.
*      name1   LIKE lfa1-name1,                              "이름1.

  FREE : t_fieldcat.  CLEAR: t_fieldcat.
  mfc 'IT_ICCNO'   'ICCNO'    'ZTITCCK'  'ICCNO' '' '' ''.
  mfc 'IT_ICCNO'   'ICCSQ'    'ZTITCCK'  'ICCSQ' '' '' ''.
*  mfc 'IT_ICCNO'   'BLDTY'    'ZTIVRQ00' 'BLDTY' '' '' ''.
*  mfc 'IT_ICCNO'   'LIFNR'    'ZTIVRQ00' 'LIFNR' '' '' ''.
*  mfc 'IT_ICCNO'   'BLETA'    'ZTIVRQ00' 'BLETA' '' '' ''.
*  mfc 'IT_ICCNO'   'BLETD'    'ZTIVRQ00' 'BLETD' '' '' ''.
*  mfc 'IT_ICCNO'   'CNAM'     'ZTIVRQ00' 'CNAM'  '' '' ''.
*  mfc 'IT_ICCNO'   'CDAT'     'ZTIVRQ00' 'CDAT'  '' '' ''.
*
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
      i_tabname               = 'IT_ICCNO'
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
      t_outtab                = it_iccno[]
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  READ TABLE it_iccno INDEX gs_selfield-tabindex.

  IF sy-subrc EQ 0.
    MOVE : it_iccno-iccno TO xiccno.
    MOVE : it_iccno-iccsq TO xiccsq.
  ELSE.
    MESSAGE s906(ZMTI00).
  ENDIF.

ENDFUNCTION.
