*&---------------------------------------------------------------------*
*& Include          ZGTMMR4390F02
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form F_CREATE_ALV_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE_ALV_OBJECT .

  GO_CONT = NEW #( CONTAINER_NAME = 'CON100' ).
  GO_GRID = NEW #( I_PARENT = GO_CONT ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_EXCL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_EXCL .

  GT_EXCL[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
                       ( CL_GUI_ALV_GRID=>MC_MB_EXPORT )
                       ( CL_GUI_ALV_GRID=>MC_FC_REFRESH )
                       ( CL_GUI_ALV_GRID=>MC_FC_INFO ) ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_LAYO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_LAYO .

  CLEAR:
    GS_LAYO.

  GS_LAYO-SEL_MODE   = GC_A.
  GS_LAYO-ZEBRA      = ABAP_TRUE.
  GS_LAYO-CWIDTH_OPT  = GC_A.
  GS_LAYO-NO_ROWMOVE = ABAP_TRUE.
  GS_LAYO-NO_ROWINS = ABAP_TRUE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_VARI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_VARI .

  CLEAR:
    GS_VARI.

  GS_VARI-REPORT = SY-REPID.
  GS_VARI-HANDLE = 'AL01'.
  GS_VARI-USERNAME = SY-UNAME.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CREATE_FCAT_BY_ITAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_ITAB
*&      <-- PT_FCAT
*&---------------------------------------------------------------------*
FORM F_CREATE_FCAT_BY_ITAB  USING    PT_ITAB TYPE ANY TABLE
                            CHANGING PT_FCAT TYPE LVC_T_FCAT.

  DATA :
    LO_TABDESCR  TYPE REF TO CL_ABAP_TABLEDESCR,
    LO_STRUDESCR TYPE REF TO CL_ABAP_STRUCTDESCR,
    LT_DFIES     TYPE DDFIELDS.

  LO_TABDESCR ?= CL_ABAP_TABLEDESCR=>DESCRIBE_BY_DATA( PT_ITAB ).
  LO_STRUDESCR ?= LO_TABDESCR->GET_TABLE_LINE_TYPE( ).
  LT_DFIES = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUDESCR ) .

  PT_FCAT[] = CORRESPONDING #( LT_DFIES MAPPING
                                   KEY = KEYFLAG
                                   COLTEXT   = FIELDTEXT
                            EXCEPT ROLLNAME ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_FCAT_COLTXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> TEXT_H01
*&      <-- <LS_FCAT>
*&---------------------------------------------------------------------*
FORM F_SET_FCAT_COLTXT  USING  PV_TEXT
                        CHANGING CS_FCAT TYPE LVC_S_FCAT.

  CS_FCAT-SCRTEXT_S  =
  CS_FCAT-SCRTEXT_M  =
  CS_FCAT-SCRTEXT_L  =
  CS_FCAT-COLTEXT    =
  CS_FCAT-SELTEXT    =
  CS_FCAT-TOOLTIP    =
  CS_FCAT-REPTEXT    = PV_TEXT.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_FCAT .

  CLEAR GT_FCAT.

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_LIST CHANGING GT_FCAT.
  PERFORM F_ADJ_FCAT.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT .

  CHECK GT_FCAT[] IS NOT INITIAL.

  LOOP AT GT_FCAT ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'BUKRS'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = GC_X.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'CYEAR'. ""연도
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = COND #( WHEN P_YEAR = GC_X THEN '' ELSE GC_X ).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'CMON'. ""월
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = COND #( WHEN P_MON = GC_X THEN '' ELSE GC_X ).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'CDATE'. "일자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = COND #( WHEN P_DAY = GC_X THEN '' ELSE GC_X ).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MCHECK'. "확정 여부
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H38 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = COND #( WHEN P_MON = GC_X THEN '' ELSE GC_X ).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'EXRATE_TTS'. ""전신환매도환율
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = 'R'.
      WHEN 'EXRATE_TTM'. ""전신환매입환율
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
       <LS_FCAT>-JUST = 'R'.
      WHEN 'CU_CASH'. ""CU-CASH
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
        <LS_FCAT>-EMPHASIZE = 'C300'.
        <LS_FCAT>-CFIELDNAME = 'CU_WAERS'.
         <LS_FCAT>-JUST = 'R'.
      WHEN 'CU_3M'. ""CU-3M
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
        <LS_FCAT>-EMPHASIZE = 'C400'.
        <LS_FCAT>-CFIELDNAME = 'CU_WAERS'.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'CU_WAERS'. ""통화(CU)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = 'C'.
      WHEN 'CU_PREMIUM'. ""프리미엄FEE(CU)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'CU_PRWAERS'.
        <LS_FCAT>-NO_OUT = GC_X.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'CU_PRWAERS'. ""통화(CU/PR)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = GC_X.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'CU_CRAFT'. ""환산요율(CU)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = GC_X.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'CU_MCOST'. ""부대비(CU)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H17 CHANGING <LS_FCAT>."
       <LS_FCAT>-CFIELDNAME = 'CU_MWAERS'.
        <LS_FCAT>-NO_OUT = GC_X.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'CU_MPER'. ""부대비 PER(CU)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = GC_X.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'CU_MUNIT'. ""부대비 단위(CU)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = GC_X.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'CU_MWAERS'. ""부대비 통화(CU)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H20 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = GC_X.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'CU_KURST'. ""환율 유형(CU)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H21 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = GC_X.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'CU_LMC'. ""CU 원화 환산가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H22 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'CU_KWAERS'.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'CU_KWAERS'. "" 원화 통화키
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H39 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = 'C'.
      WHEN 'AL_CASH'. ""AL-CASH
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H23 CHANGING <LS_FCAT>."
        <LS_FCAT>-EMPHASIZE = 'C300'.
        <LS_FCAT>-CFIELDNAME = 'AL_WAERS'.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'AL_3M'. ""AL-3M
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H36 CHANGING <LS_FCAT>."
        <LS_FCAT>-EMPHASIZE = 'C400'.
        <LS_FCAT>-CFIELDNAME = 'AL_WAERS'.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'AL_WAERS'. ""통화(AL)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H24 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = 'C'.
      WHEN 'AL_PREMIUM'. ""프리미엄FEE(AL)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H25 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'AL_PRWAERS'.
        <LS_FCAT>-NO_OUT = GC_X.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'AL_PRWAERS'. ""통화(AL/PR)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H26 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = GC_X.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'AL_CRAFT'. ""환산요율(AL)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H27 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = GC_X.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'AL_MCOST'. ""부대비(AL)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H35 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = GC_X.
       <LS_FCAT>-CFIELDNAME = 'AL_MWAERS'.
       <LS_FCAT>-JUST = 'R'.
      WHEN 'AL_MPER'. ""부대비 PER(AL)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H28 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = GC_X.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'AL_MUNIT'. ""부대비 단위(AL)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H29 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = GC_X.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'AL_MWAERS'. ""부대비 통화(AL)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H20 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = GC_X.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'AL_KURST'. ""환율 유형(AL)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H31 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = GC_X.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'AL_LMC'. ""AL 원화 환산가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H32 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'AL_KWAERS'.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'AL_KWAERS'. "" 원화 통화키
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H39 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PB_CASH'."PB-CASH
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H33 CHANGING <LS_FCAT>."
        <LS_FCAT>-EMPHASIZE = 'C300'.
        <LS_FCAT>-CFIELDNAME = 'PB_WAERS'.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'PB_3M'. ""PB-3M
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H37 CHANGING <LS_FCAT>."
        <LS_FCAT>-EMPHASIZE = 'C400'.
        <LS_FCAT>-CFIELDNAME = 'PB_WAERS'.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'PB_WAERS'. "통화(PB)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H34 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = 'C'.
      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.


  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ALV_EVENT .

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_SORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ALV_SORT .

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DISPLAY_ALV .

  CALL METHOD GO_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO
      IT_TOOLBAR_EXCLUDING = GT_EXCL[]
      IS_VARIANT           = GS_VARI
      I_SAVE               = GV_ASAVE
    CHANGING
      IT_OUTTAB            = GT_LIST[]
      IT_FIELDCATALOG      = GT_FCAT[]
      IT_SORT              = GT_SORT[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_REFRESH_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_HD
*&---------------------------------------------------------------------*
FORM F_REFRESH_ALV  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA LS_STABLE TYPE LVC_S_STBL.
  LS_STABLE-ROW = ABAP_TRUE.
  LS_STABLE-COL = ABAP_TRUE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

ENDFORM.
