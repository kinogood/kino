*&---------------------------------------------------------------------*
*& Include          ZGTMMR4300F02
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

  GS_LAYO-SEL_MODE   = GC_D.
  GS_LAYO-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO-ZEBRA      = ABAP_TRUE.
  GS_LAYO-SMALLTITLE = ABAP_TRUE.
  CASE ABAP_TRUE.
    WHEN P_SEND.
      GS_LAYO-GRID_TITLE = TEXT-TT1. "임가공 투입 자재 전송관리
    WHEN P_ILOG.
      GS_LAYO-GRID_TITLE = TEXT-TT2. "Interface 처리 상태
  ENDCASE.

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

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_DOC CHANGING GT_FCAT.
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
      WHEN 'MBLNR'. ""자재문서
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
      WHEN 'MJAHR'. ""자재문서연도
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
      WHEN 'ZEILE'. ""자재문서항목
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
      WHEN 'BUDAT'. ""전기일자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
      WHEN 'MATNR'. ""자재번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'MARA'.
        <LS_FCAT>-REF_FIELD = 'MATNR'.
      WHEN 'ZZMAKTX80'. ""자재내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
      WHEN 'BWART'. ""이동유형
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'MSEG'.
        <LS_FCAT>-REF_FIELD = 'BWART'.
      WHEN 'CHARG'. ""배치번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
      WHEN 'MENGE'. ""수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-REF_TABLE = 'MSEG'.
        <LS_FCAT>-REF_FIELD = 'MENGE'.
      WHEN 'MEINS'. ""단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'MSEG'.
        <LS_FCAT>-REF_FIELD = 'MEINS'.
      WHEN 'EBELN'. ""구매오더번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>."
      WHEN 'EBELP'. ""구매오더품목
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."
      WHEN 'LIFNR'. ""공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
      WHEN 'LIFNR_TXT'. ""공급업체명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."
      WHEN 'TAGNR'. ""꼬리표번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."
      WHEN 'ZIFNO'. ""I/F No
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H17 CHANGING <LS_FCAT>."
      WHEN 'ZIFKEY'. ""Interface Key
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
      WHEN 'SYSTEM_ID'. ""I/F 시스템
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>."
      WHEN 'SYSTEM_TXT'. ""시스템 명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H20 CHANGING <LS_FCAT>."
      WHEN 'ZSTAT'. ""송수신상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H21 CHANGING <LS_FCAT>."
      WHEN 'MESSAGE'. ""송수신메세지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H22 CHANGING <LS_FCAT>."
      WHEN 'IFNAM'. ""송수신자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H23 CHANGING <LS_FCAT>."
      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ZIFNO' OR 'ZIFKEY' OR 'SYSTEM_ID'
            OR 'SYSTEM_TXT' OR 'ZSTAT' OR  'MESSAGE' OR 'IFNAM'.
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

  CREATE OBJECT GO_EVENT.
  SET HANDLER GO_EVENT->HANDLE_HOTSPOT_CLICK FOR GO_GRID.

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

  CLEAR GT_SORT.

  GT_SORT = VALUE #( BASE GT_SORT ( SPOS = 1 FIELDNAME = 'MJAHR' UP = ABAP_TRUE DOWN = SPACE ) ).
  GT_SORT = VALUE #( BASE GT_SORT ( SPOS = 2 FIELDNAME = 'MBLNR' UP = ABAP_TRUE DOWN = SPACE ) ).
  GT_SORT = VALUE #( BASE GT_SORT ( SPOS = 3 FIELDNAME = 'ZEILE' UP = ABAP_TRUE DOWN = SPACE ) ).
  GT_SORT = VALUE #( BASE GT_SORT ( SPOS = 5 FIELDNAME = 'ZIFNO' UP = ABAP_TRUE DOWN = SPACE ) ).

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
      IT_OUTTAB            = GT_DOC[]
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
*& Form F_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_ROW_NO_ROW_ID
*&      --> E_COLUMN_ID
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM F_HOTSPOT_CLICK  USING PS_ROW_ID TYPE INT4
                                               PS_COLUMN TYPE LVC_S_COL
                                               PO_SENDER.

  CHECK PS_ROW_ID IS NOT INITIAL.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'MBLNR'. "자재 문서 번호
      READ TABLE GT_DOC ASSIGNING FIELD-SYMBOL(<LS_DOC>) INDEX PS_ROW_ID.
      CHECK SY-SUBRC EQ 0.

      CALL FUNCTION 'MIGO_DIALOG'
        EXPORTING
          I_MBLNR = <LS_DOC>-MBLNR
          I_MJAHR = <LS_DOC>-MJAHR
          I_ZEILE = <LS_DOC>-ZEILE.

  ENDCASE.

ENDFORM.
