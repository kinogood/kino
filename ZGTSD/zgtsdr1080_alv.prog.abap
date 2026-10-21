*&---------------------------------------------------------------------*
*&  Include           ZGTSDR1080_ALV                                     *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_LAYOUT
*&---------------------------------------------------------------------*
FORM SET_LAYOUT  CHANGING CS_LAYO TYPE SLIS_LAYOUT_ALV.
*... Display options
  CS_LAYO-COLWIDTH_OPTIMIZE      = 'X'.
  CS_LAYO-NO_COLHEAD             = SPACE.
  CS_LAYO-NO_HOTSPOT             = SPACE.
  CS_LAYO-ZEBRA                  = 'X'  .
  CS_LAYO-NO_VLINE               = SPACE.
  CS_LAYO-CELL_MERGE             = SPACE.
  CS_LAYO-NO_MIN_LINESIZE        = SPACE.
  CS_LAYO-MIN_LINESIZE           = SPACE.
  CS_LAYO-MAX_LINESIZE           = SPACE.
  CS_LAYO-WINDOW_TITLEBAR        = SPACE.
  CS_LAYO-NO_ULINE_HS            = SPACE.
*... Edit
  CS_LAYO-EDIT                   = SPACE.
  CS_LAYO-EDIT_MODE              = SPACE.
*... Exceptions
*  cs_layo-lights_fieldname       = 'LIGHT'.
*  cs_layo-lights_tabname         = g_tabname_header.
  CS_LAYO-LIGHTS_ROLLNAME        = SPACE.
  CS_LAYO-LIGHTS_CONDENSE        = SPACE.
*... Sums
  CS_LAYO-NO_SUMCHOICE           = SPACE.
  CS_LAYO-NO_TOTALLINE           = SPACE.
  CS_LAYO-TOTALS_BEFORE_ITEMS    = SPACE.
  CS_LAYO-TOTALS_ONLY            = SPACE.
  CS_LAYO-TOTALS_TEXT            = SPACE.
  CS_LAYO-NO_SUBCHOICE           = SPACE.
  CS_LAYO-NO_SUBTOTALS           = SPACE.
  CS_LAYO-SUBTOTALS_TEXT         = SPACE.
  CS_LAYO-NUMC_SUM               = SPACE.
  CS_LAYO-NO_UNIT_SPLITTING      = SPACE.
*... Interaction
*  cs_layo-box_fieldname          = 'MARK'.
*  cs_layo-box_tabname            = g_tabname_header.
*  cs_layo-box_rollname           = space.
  CS_LAYO-EXPAND_FIELDNAME       = 'EXPAND'.
  CS_LAYO-HOTSPOT_FIELDNAME      = SPACE.
  CS_LAYO-NO_INPUT               = SPACE.
  CS_LAYO-F2CODE                 = SPACE.
  CS_LAYO-CONFIRMATION_PROMPT    = SPACE.
  CS_LAYO-KEY_HOTSPOT            = SPACE.
  CS_LAYO-FLEXIBLE_KEY           = 'X'.
  CS_LAYO-REPREP                 = SPACE.
  CS_LAYO-GROUP_BUTTONS          = SPACE.
  CS_LAYO-NO_KEYFIX              = SPACE.
  CS_LAYO-GET_SELINFOS           = 'X'.
  CS_LAYO-GROUP_CHANGE_EDIT      = 'X'.
  CS_LAYO-NO_SCROLLING           = SPACE.
  CS_LAYO-EXPAND_ALL             = SPACE.
  CS_LAYO-NO_AUTHOR              = SPACE.
*... Detailed screen
  CS_LAYO-DETAIL_POPUP           = 'X'.
  CS_LAYO-DETAIL_INITIAL_LINES   = SPACE.
  CS_LAYO-DETAIL_TITLEBAR        = SPACE.
*... PF-status
  CS_LAYO-DEF_STATUS             = SPACE.
*... Display variants
  CS_LAYO-HEADER_TEXT            = SPACE.
  CS_LAYO-ITEM_TEXT              = SPACE.
  CS_LAYO-DEFAULT_ITEM           = SPACE.
*... colour
  CS_LAYO-INFO_FIELDNAME         = SPACE.
  CS_LAYO-COLTAB_FIELDNAME       = SPACE.    "'COLOR'.
*... others
  CS_LAYO-LIST_APPEND            = SPACE.

ENDFORM.                    " SET_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_ALV
*&---------------------------------------------------------------------*
FORM USER_COMMAND USING  P_UCOMM    LIKE SY-UCOMM
                         P_SELFIELD TYPE SLIS_SELFIELD.

  CASE  P_UCOMM .
    WHEN 'ZKRW'.
      PERFORM CONVERT_WONGHWA_AMT.
    WHEN 'ZF01'.
      PERFORM CALL_BILLING_SCREEN.
  ENDCASE.
  P_SELFIELD-REFRESH = 'X'.

ENDFORM.                    "pf-status
*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM ALV_DISPLAY_DATA .
  CLEAR : G_LIST_TOP_OF_PAGE_T[].
  PERFORM : ALVPRN_BASIC.
  PERFORM : ALVPRN_HEADER USING G_LIST_TOP_OF_PAGE_T[].
  PERFORM : ALV_HIERSEQ_FIELD_SET USING 'GT_HEADER' "Field 특성 설정
                                        'GT_ITEMS'.
  PERFORM ALV_HIERSEQ_DISPLAY TABLES GT_HEADER
                                     GT_ITEMS.

ENDFORM.                    " ALV_DISPLAY_DATA
*&---------------------------------------------------------------------*
*&      Form  ALVPRN_BASIC
*&---------------------------------------------------------------------*
FORM ALVPRN_BASIC .
*... FORM문 발췌함수
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      I_LIST_TYPE = 0
    IMPORTING
      ET_EVENTS   = G_EVENTS_T.

*... FORM문   생성
  PERFORM  FORM_SETTING USING:
           SLIS_EV_PF_STATUS_SET  C_STATUS_SET,
           SLIS_EV_USER_COMMAND   C_USER_COMMAND,
           SLIS_EV_TOP_OF_PAGE    C_TOP_OF_PAGE.

*... PROGRAM  ID
  G_PROGRAM = SY-REPID.
  G_VARIANT_S-REPORT = SY-REPID.

  G_TABNAME_HEADER = 'GT_HEADER'.
  G_TABNAME_ITEM   = 'GT_ITEMS'.
  G_SAVE = 'A'.

*... Header/Item Key
  CLEAR G_KEYINFO_S.

  G_KEYINFO_S-HEADER01 = 'ZLCNO'.
  G_KEYINFO_S-ITEM01   = 'ZLCNO'.
  G_KEYINFO_S-HEADER02 = 'ZUONR'.
  G_KEYINFO_S-ITEM02   = 'ZUONR'.
  G_VARIANT_S-VARIANT  = ' '.         "레이아웃

ENDFORM.                    " ALVPRN_BASIC
*&---------------------------------------------------------------------*
*&      Form  FORM_SETTING
*&---------------------------------------------------------------------*
FORM FORM_SETTING  USING P_COM P_FORM.

*... 해당  FORM발췌
  DATA : L_EVENT_S    TYPE  SLIS_ALV_EVENT.
  READ TABLE    G_EVENTS_T  WITH KEY  NAME = P_COM
                            INTO L_EVENT_S.
*... FORM 생성
  IF   SY-SUBRC EQ 0.
    MOVE     P_FORM      TO   L_EVENT_S-FORM.
    MODIFY   G_EVENTS_T  FROM L_EVENT_S INDEX SY-TABIX.
  ENDIF.

ENDFORM.                    " FORM_SETTING
*&---------------------------------------------------------------------*
*&      Form  ALVPRN_HEADER
*&---------------------------------------------------------------------*
FORM ALVPRN_HEADER  USING   P_LIST_TOP_OF_PAGE_T TYPE
                            SLIS_T_LISTHEADER.

  DATA: L_LINE_S TYPE SLIS_LISTHEADER,
        L_INFO   TYPE SLIS_LISTHEADER-INFO.

  DATA: L_NAME1  LIKE KNA1-NAME1.

*... LIST HEADING LINE: TYPE H
  CLEAR: L_LINE_S, L_INFO.
  L_LINE_S-TYP  = 'H'.
*... L_LINE_S-KEY:  NOT USED FOR THIS TYPE
  L_LINE_S-INFO = '[ L/C별 리스트조회 ]'.
  APPEND L_LINE_S TO P_LIST_TOP_OF_PAGE_T.

*... 저장정보
*  concatenate '창고:' gv_lgnum '(' t300t-lnumt ')'
*              into l_line_s-info separated by space.
*  l_line_s-typ  = 'S'.
*  l_line_s-key  = '저장정보 -'.
*  append l_line_s to p_list_top_of_page_t.


ENDFORM.                    " ALVPRN_HEADER
*&---------------------------------------------------------------------*
*&      Form  ALV_HIERSEQ_FIELD_SET
*&---------------------------------------------------------------------*
FORM ALV_HIERSEQ_FIELD_SET  USING    P_HEAD_NAME
                                     P_ITEM_NAME.

  CLEAR   : G_FIELD_T, G_FIELDCAT_T, G_FIELDCAT_S.
  REFRESH : G_FIELD_T, G_FIELDCAT_T.

*... FIELD발췌
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = G_PROGRAM
      I_INTERNAL_TABNAME = P_HEAD_NAME
      I_INCLNAME         = G_PROGRAM
      I_BYPASSING_BUFFER = 'X'
      I_BUFFER_ACTIVE    = 'X'
    CHANGING
      CT_FIELDCAT        = G_FIELD_T[].

*... FIELD발췌
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = G_PROGRAM
      I_INTERNAL_TABNAME = P_ITEM_NAME
      I_INCLNAME         = G_PROGRAM
      I_BYPASSING_BUFFER = 'X'
      I_BUFFER_ACTIVE    = 'X'
    CHANGING
      CT_FIELDCAT        = G_FIELD_T[].

  PERFORM FIELD_LAYOUT_SETTING USING P_HEAD_NAME
                                     P_ITEM_NAME.



ENDFORM.                    " ALV_HIERSEQ_FIELD_SET
*&---------------------------------------------------------------------*
*&      Form  ALV_HIERSEQ_DISPLAY
*&---------------------------------------------------------------------*
FORM ALV_HIERSEQ_DISPLAY  TABLES   P_HEAD_T
                                   P_ITEM_T.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = G_PROGRAM
      IS_LAYOUT          = G_LAYOUT_S
      IT_FIELDCAT        = G_FIELDCAT_T[]
      I_SAVE             = G_SAVE
      IS_VARIANT         = G_VARIANT_S
      IT_EVENTS          = G_EVENTS_T[]
      I_TABNAME_HEADER   = G_TABNAME_HEADER
      I_TABNAME_ITEM     = G_TABNAME_ITEM
      IS_KEYINFO         = G_KEYINFO_S
      I_BUFFER_ACTIVE    = 'X'
      I_BYPASSING_BUFFER = 'X'
    TABLES
      T_OUTTAB_HEADER    = P_HEAD_T
      T_OUTTAB_ITEM      = P_ITEM_T.

ENDFORM.                    " ALV_HIERSEQ_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  FIELD_LAYOUT_SETTING
*&---------------------------------------------------------------------*
FORM FIELD_LAYOUT_SETTING  USING P_HEAD_NAME
                                 P_ITEM_NAME.
  REFRESH  G_FIELDCAT_T.
  PERFORM  FIELD_SETTING USING :
                    'S'   'VKBUR'       ' ',
                    ' '   'SELTEXT_M'   '영업팀',
                    'E'   'DDICTXT'     'M',

                    'S'   'VKGRP'   ' ',
                    ' '   'SELTEXT_M'   '영업그룹',
                    'E'   'DDICTXT'     'M',

                    'S'   'KDKG4'       ' ',
                    ' '   'SELTEXT_M'   '수출구분',
                    'E'   'DDICTXT'     'M',

                    'S'   'KUNNR'       ' ',
                    ' '   'SELTEXT_M'   '고객',
                    'E'   'DDICTXT'     'M',

                    'S'   'NAME1'       ' ',
                    ' '   'SELTEXT_M'   '고객명',
                    'E'   'DDICTXT'     'M',

                    'S'   'ZLCNO'       ' ',
                    ' '   'SELTEXT_M'   'L/C번호',
                    'E'   'DDICTXT'     'M',

                    'S'   'ZUONR'       ' ',
                    ' '   'SELTEXT_M'   'B/L번호',
                    'E'   'DDICTXT'     'M',

                    'S'   'VBELN'       ' ',
                    ' '   'SELTEXT_M'   '미처리문서',
                    'E'   'DDICTXT'     'M',

                    'S'   'POSNR'       ' ',
                    ' '   'SELTEXT_M'   '품목번호',
                    'E'   'DDICTXT'     'M',

                    'S'   'SUMAMT_A'       ' ',
                    ' '   'SELTEXT_M'   'Billing 미처리',
                    ' '   'CFIELDNAME'  'WAERK',
                    'E'   'DDICTXT'     'M',

                    'S'   'SUMAMT_B'       ' ',
                    ' '   'SELTEXT_M'   '전표미생성',
                    ' '   'CFIELDNAME'  'WAERK',
                    'E'   'DDICTXT'     'M',

                    'S'   'SUMAMT_C'       ' ',
                    ' '   'SELTEXT_M'   '전표생성',
                    ' '   'CFIELDNAME'  'WAERK',
                    'E'   'DDICTXT'     'M',

                    'S'   'NETWR_A'       ' ',
                    ' '   'SELTEXT_M'   'Billing 미처리',
                    ' '   'CFIELDNAME'  'WAERK',
                    'E'   'DDICTXT'     'M',

                    'S'   'NETWR_B'       ' ',
                    ' '   'SELTEXT_M'   '전표미생성',
                    ' '   'CFIELDNAME'  'WAERK',
                    'E'   'DDICTXT'     'M',

                    'S'   'NETWR_C'       ' ',
                    ' '   'SELTEXT_M'   '전표생성',
                    ' '   'CFIELDNAME'  'WAERK',
                    'E'   'DDICTXT'     'M',


                    'S'   'POD'       ' ',
                    ' '   'SELTEXT_M'   'POD',
                    'E'   'DDICTXT'     'M',

                    'S'   'WAERK'       ' ',
                    ' '   'SELTEXT_M'   '통화',
                    'E'   'DDICTXT'     'M'.

ENDFORM.                    " FIELD_LAYOUT_SETTING
*&---------------------------------------------------------------------*
*&      Form  FIELD_SETTING
*&---------------------------------------------------------------------*
FORM FIELD_SETTING  USING  P_GUB P_FNAME P_CON.

*... FIELD 속성 READ
  IF   P_GUB =  'S'.
    CLEAR G_FIELDCAT_S.
    READ  TABLE G_FIELD_T  INTO G_FIELDCAT_S
          WITH KEY FIELDNAME  = P_FNAME.
    ADD 1 TO G_COUNT.
    G_FIELDCAT_S-COL_POS = G_COUNT.
    EXIT.
  ENDIF.

*... 속성 MOVE
  DATA L_COL(40).
  FIELD-SYMBOLS <FS>.
  CONCATENATE 'G_FIELDCAT_S-' P_FNAME  INTO L_COL.
  ASSIGN      (L_COL)         TO       <FS>.
  MOVE         P_CON          TO       <FS>.

*... DATA  APPEND
  CHECK  P_GUB = 'E'.
*  if g_fieldcat_s-datatype  = 'CURR'.
*    g_fieldcat_s-currency  = 'KRW'.
*  endif.
  APPEND G_FIELDCAT_S TO G_FIELDCAT_T.

ENDFORM.                    " FIELD_SETTING
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       외부(REUSE_ALV_COMMENTARY_WRITE)에서 CALL한 FORM 문
*&---------------------------------------------------------------------*
FORM TOP_OF_PAGE.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
*     i_logo             = 'ENJOYSAP_LOGO'
      IT_LIST_COMMENTARY = G_LIST_TOP_OF_PAGE_T.

ENDFORM.                    "TOP_OF_PAGE
*&------------------------------------------------------------------*
*&      Form  PF_STATUS_SET
*&------------------------------------------------------------------*
*       외부(REUSE_ALV_EVENTS_GET)에서 CALL한 FORM 문이다.
*-------------------------------------------------------------------*
FORM  PF_STATUS_SET USING RT_EXTAB TYPE SLIS_T_EXTAB.

  CLEAR GT_STATUS.   REFRESH GT_STATUS.
  SET  PF-STATUS  'MAIN_ALV' EXCLUDING  RT_EXTAB.

ENDFORM.                    "PF_STATUS_SET
*&---------------------------------------------------------------------*
*&      Form  convert_wonghwa_amt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONVERT_WONGHWA_AMT .

  CLEAR : GT_HEADER, GT_HEADER[],
          GT_ITEMS,  GT_ITEMS[],
          GT_TEMP2, GT_TEMP2[].


  IF GV_CONV2 IS INITIAL.
    GV_CONV2 = 'X'.

    LOOP AT GT_TEMP.
      MOVE-CORRESPONDING GT_TEMP TO GT_TEMP2.
      GT_TEMP2-NETWR_A = GT_TEMP2-NETWR_A * GT_TEMP2-KURRF.
      GT_TEMP2-NETWR_B = GT_TEMP2-NETWR_B * GT_TEMP2-KURRF.
      GT_TEMP2-NETWR_C = GT_TEMP2-NETWR_C * GT_TEMP2-KURRF.
      GT_TEMP2-WAERK = 'KRW'.
      APPEND GT_TEMP2. CLEAR GT_TEMP2.
    ENDLOOP.
  ELSE.
    GV_CONV2 = ' '.

    LOOP AT GT_TEMP.
      MOVE-CORRESPONDING GT_TEMP TO GT_TEMP2.
      GT_TEMP2-NETWR_A = GT_TEMP2-NETWR_A.
      GT_TEMP2-NETWR_B = GT_TEMP2-NETWR_B.
      GT_TEMP2-NETWR_C = GT_TEMP2-NETWR_C.
      APPEND GT_TEMP2. CLEAR GT_TEMP2.
    ENDLOOP.

  ENDIF.

  SORT GT_TEMP2.

  LOOP AT GT_TEMP2.
    MOVE-CORRESPONDING GT_TEMP2 TO GT_HEADER.
    GT_HEADER-SUMAMT_A = GT_TEMP2-NETWR_A.
    GT_HEADER-SUMAMT_B = GT_TEMP2-NETWR_B.
    GT_HEADER-SUMAMT_C = GT_TEMP2-NETWR_C.
    COLLECT GT_HEADER. CLEAR GT_HEADER.
  ENDLOOP.

  LOOP AT GT_TEMP2.
    MOVE-CORRESPONDING GT_TEMP2 TO GT_ITEMS.
    APPEND GT_ITEMS. CLEAR GT_ITEMS.
  ENDLOOP.

  SORT GT_HEADER.
  SORT GT_ITEMS.
  DELETE ADJACENT DUPLICATES FROM GT_HEADER
                             COMPARING ZLCNO ZUONR.

ENDFORM.                    " convert_wonghwa_amt
