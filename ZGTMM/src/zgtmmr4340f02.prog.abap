*&---------------------------------------------------------------------*
*& Include          ZGTMMR4340F02
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

  GS_LAYO-SEL_MODE   = GC_A.
*  GS_LAYO-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO-ZEBRA      = ABAP_TRUE.
  GS_LAYO-NO_ROWMOVE = ABAP_TRUE.
  GS_LAYO-NO_ROWINS = ABAP_TRUE.
  GS_LAYO-STYLEFNAME = 'ZSTYLE'.

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

  IF P_DISP EQ ABAP_TRUE.
    PERFORM F_CREATE_FCAT_BY_ITAB USING GT_LIST CHANGING GT_FCAT.
  ELSE.
    PERFORM F_CREATE_FCAT_BY_ITAB USING GT_CREA CHANGING GT_FCAT.
  ENDIF.

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
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'WERKS_TEXT'. ""플랜트명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'LIFNR'. ""외주업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'LIFNR_TEXT'. ""업체명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'EBELN'. ""구매오더번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'ZGTMMT9450'.
        <LS_FCAT>-REF_FIELD = 'EBELN'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-OUTPUTLEN = 12.
      WHEN 'EBELP'. ""구매오더품목
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'ZGTMMT9450'.
        <LS_FCAT>-REF_FIELD = 'EBELP'.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'MATNR'. ""자재번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 15.
      WHEN 'TXZ01'. ""자재내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN 'IDNRK'. ""투입 자재번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 15.
      WHEN 'MAKTX'. ""투입 자재내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN 'CHARG'. ""배치번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 12.
      WHEN 'MENGE'. ""수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>."
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 12.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'MEINS'. ""단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."

        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'ERNAM'. ""등록자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'ERDAT'. ""등록일자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ERDAT' OR 'ERNAM'.
        <LS_FCAT>-TECH = P_CREA.

      WHEN 'EBELN' OR 'EBELP'.
        <LS_FCAT>-EDIT = P_CREA.
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

  GO_GRID->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
  CREATE OBJECT GCL_EVENT.
  SET HANDLER:
    GCL_EVENT->HANDLE_HOTSPOT_CLICK FOR GO_GRID,
    GCL_EVENT->HANDLE_DATA_CHANGED_FINISHED FOR GO_GRID.

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

*&---------------------------------------------------------------------*
*& Form F_DATA_CHANGED_FIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM F_DATA_CHANGED_FIN  USING   PV_MODIFIED TYPE CHAR01
                                     PT_GOOD_CELLS TYPE LVC_T_MODI.

  CHECK PV_MODIFIED EQ ABAP_TRUE.

  LOOP AT PT_GOOD_CELLS ASSIGNING  FIELD-SYMBOL(<LS_G0>)
                                                                GROUP BY ( ROW_ID = <LS_G0>-ROW_ID )
                                                                ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    READ TABLE GT_LIST ASSIGNING  FIELD-SYMBOL(<LS_LIST>) INDEX <LS_GROUP>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    CLEAR:
      <LS_LIST>-MATNR,
      <LS_LIST>-TXZ01.

    SELECT SINGLE
      EP~MATNR,
      EP~TXZ01
      FROM EKPO AS EP
      WHERE EP~EBELN EQ @<LS_LIST>-EBELN
      AND EP~EBELP EQ @<LS_LIST>-EBELP
      INTO ( @<LS_LIST>-MATNR, @<LS_LIST>-TXZ01 ).

  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID.

ENDFORM.
