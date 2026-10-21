*&---------------------------------------------------------------------*
*& Include          ZGTMMR4351F02
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
  CREATE OBJECT GO_CONT
    EXPORTING
      REPID                       = SY-REPID
      DYNNR                       = SY-DYNNR
      EXTENSION                   = 10000
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.

  CREATE OBJECT GO_GRID
    EXPORTING
      I_PARENT      = GO_CONT
      I_APPL_EVENTS = ABAP_TRUE.
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
                       ( CL_GUI_ALV_GRID=>MC_FC_REFRESH ) ).

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

  GS_LAYO-SEL_MODE   = GC_D.
  GS_LAYO-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO-ZEBRA      = ABAP_TRUE.

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
  GS_VARI-HANDLE = 'HD01'.
  GS_VARI-USERNAME = SY-UNAME.

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

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_FIBER CHANGING GT_FCAT.
  PERFORM F_ADJ_FCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_CREATE_FCAT_BY_ITAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_DOC
*&      <-- GT_FCAT
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
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F08 CHANGING <LS_FCAT>.
      WHEN 'VLABELNO'. ""라벨번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F09 CHANGING <LS_FCAT>.
      WHEN 'EBELN'. ""구매오더번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F10 CHANGING <LS_FCAT>.
      WHEN 'EBELP'. ""구매오더품목
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F11 CHANGING <LS_FCAT>.
      WHEN 'BUDAT'. ""전기일자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F12 CHANGING <LS_FCAT>.
      WHEN 'MATNR'. ""자재번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F13 CHANGING <LS_FCAT>.
        <LS_FCAT>-REF_TABLE = 'MARA'.
        <LS_FCAT>-REF_FIELD = 'MATNR'.
      WHEN 'TXZ01'. ""자재내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F14 CHANGING <LS_FCAT>.
      WHEN 'MENGE'. ""수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F15 CHANGING <LS_FCAT>.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-REF_TABLE = 'MSEG'.
        <LS_FCAT>-REF_FIELD = 'MENGE'.
      WHEN 'MEINS'. ""단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F16 CHANGING <LS_FCAT>.
        <LS_FCAT>-REF_TABLE = 'MSEG'.
        <LS_FCAT>-REF_FIELD = 'MEINS'.
      WHEN 'LANCHAR'. ""광특성
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F17 CHANGING <LS_FCAT>.
        <LS_FCAT>-REF_TABLE = 'MSEG'.
        <LS_FCAT>-REF_FIELD = 'BWART'.
      WHEN 'LIFNR'. ""공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F18 CHANGING <LS_FCAT>.
      WHEN 'ZIFNO'. ""I/F No
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F01 CHANGING <LS_FCAT>.
      WHEN 'ZIFKEY'. ""Interface Key
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F02 CHANGING <LS_FCAT>.
      WHEN 'SYSTEM_ID'. ""I/F 시스템
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F03 CHANGING <LS_FCAT>.
      WHEN 'SYSTEM_TXT'. ""시스템 명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F04 CHANGING <LS_FCAT>.
      WHEN 'ZSTAT'. ""송수신상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F05 CHANGING <LS_FCAT>.
      WHEN 'MESSAGE'. ""송수신메세지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F06 CHANGING <LS_FCAT>.
      WHEN 'IFNAM'. ""송수신자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F07 CHANGING <LS_FCAT>.
      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ZIFNO' OR 'ZIFKEY' OR 'SYSTEM_ID' or
           'SYSTEM_TXT' OR 'ZSTAT' OR  'MESSAGE' OR 'IFNAM'.
        <LS_FCAT>-TECH = P_SEND.
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
      IT_OUTTAB            = GT_FIBER[]
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
*&      --> GO_GRID
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
