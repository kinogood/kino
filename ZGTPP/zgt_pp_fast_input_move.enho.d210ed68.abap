"Name: \PR:SAPLMILL_UA1\FO:TCTRL_MILL_PP_POS_INIT\SE:END\EI
ENHANCEMENT 0 ZGT_PP_FAST_INPUT_MOVE.
*
  data : LV_CHK_MULTY type char01.
  IMPORT LV_CHK_MULTY from MEMORY ID 'ZBDC'.

  IF LV_CHK_MULTY eq 'X'.
    IF tctrl_mill_pp_pos-top_line < lf_lines.
      tctrl_mill_pp_pos-top_line = lf_lines.
    ENDIF.
  ENDIF.
ENDENHANCEMENT.
