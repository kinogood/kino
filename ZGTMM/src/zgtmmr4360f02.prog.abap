*&---------------------------------------------------------------------*
*& Include          ZGTMMR4360F02
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form F_CREATE_ALV_OBJECT_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE_ALV_OBJECT_100 .

  GO_CONT_100 = NEW #( CONTAINER_NAME = 'CON100' ).
  GO_GRID_100 = NEW #( I_PARENT = GO_CONT_100 ).
*                                      I_APPL_EVENTS = 'X' ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_EXCL_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_EXCL_100 .

  CLEAR:
   GT_EXCL_100[].

  GT_EXCL_100[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
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
*& Form F_SET_LAYO_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_LAYO_100 .

  CLEAR:
    GS_LAYO_100.

  GS_LAYO_100-SEL_MODE = GC_A."GC_D.
  GS_LAYO_100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO_100-ZEBRA = ABAP_TRUE.
  GS_LAYO_100-SMALLTITLE = ABAP_TRUE.
*  GS_LAYO_100-NO_ROWMOVE = ABAP_TRUE.
*  GS_LAYO_100-NO_ROWINS = ABAP_TRUE.
  GS_LAYO_100-STYLEFNAME = 'ZSTYLE'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_VARI_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_VARI_100 .

  CLEAR:
    GS_VARI_100.

  GS_VARI_100-REPORT = SY-REPID.
  GS_VARI_100-USERNAME = SY-UNAME.
  GS_VARI_100-HANDLE = COND #( WHEN P_ELC = GC_X AND P_GR = GC_X THEN  'AL01'
                                                     WHEN P_ELC = GC_X AND P_DISP = GC_X THEN 'AL02'
                                                     WHEN P_SCR = GC_X AND P_GR = GC_X THEN 'AL03'
                                                     WHEN P_SCR = GC_X AND P_DISP = GC_X THEN 'AL04'
                                                     ELSE 'AL05' ).

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
    LO_STRUDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  LO_TABDESCR ?= CL_ABAP_TABLEDESCR=>DESCRIBE_BY_DATA( PT_ITAB ).
  LO_STRUDESCR ?= LO_TABDESCR->GET_TABLE_LINE_TYPE( ).

  PT_FCAT[] = CORRESPONDING #( CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUDESCR )
                                 MAPPING
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
*& Form F_SET_FCAT_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_FCAT_100 .

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_LIST CHANGING GT_FCAT_100.
  PERFORM F_ADJ_FCAT_100.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_EVENT_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ALV_EVENT_100 .

  DATA:
    LT_F4 TYPE LVC_T_F4,
    LS_F4 TYPE LVC_S_F4.

  LS_F4-FIELDNAME  = 'LGORT'.
  LS_F4-REGISTER     = 'X'.
  LS_F4-GETBEFORE  = 'X'.
  LS_F4-CHNGEAFTER = 'X'.
  APPEND LS_F4 TO LT_F4.

  CALL METHOD GO_GRID_100->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_F4.

  GO_GRID_100->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
  GO_GRID_100->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_ENTER ).

  CREATE OBJECT GO_EVENT.
  SET HANDLER GO_EVENT->HANDLE_HOTSPOT_CLICK FOR GO_GRID_100.
  SET HANDLER GO_EVENT->HANDLE_DATA_CHANGED FOR GO_GRID_100.
  SET HANDLER GO_EVENT->HANDLE_ON_F4 FOR GO_GRID_100.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DISPLAY_ALV_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DISPLAY_ALV_100 TABLES PT_LIST PT_FCAT.

  CALL METHOD GO_GRID_100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_100
      IT_TOOLBAR_EXCLUDING = GT_EXCL_100[]
      IS_VARIANT           = GS_VARI_100
      I_SAVE               = GV_ASAVE_100
    CHANGING
      IT_OUTTAB            = PT_LIST[] "GT_LIST[]
      IT_FIELDCATALOG  = PT_FCAT[] " GT_FCAT_100[]
      IT_SORT              = GT_SORT_100[]
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
FORM F_REFRESH_ALV  USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

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
*& Form F_ADJ_FCAT_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_100 .

  DATA LV_TXT(10).

  LOOP AT GT_FCAT_100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'. ""상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = COND #( WHEN P_DISP = GC_X THEN GC_X ELSE '' ).
      WHEN 'IFNUM'. ""송수신번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
      WHEN 'BUDAT'. ""입고일자
        CLEAR LV_TXT.
        LV_TXT = COND #( WHEN P_GR = GC_X THEN TEXT-F01      "입고일자
                                     WHEN P_DISP = GC_X THEN TEXT-F11 )."전기일자
        PERFORM F_SET_FCAT_COLTXT USING LV_TXT CHANGING <LS_FCAT>."
      WHEN 'BLDAT'. ""증빙일자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H22 CHANGING <LS_FCAT>."
      WHEN 'MATNR'. ""자재번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
      WHEN 'MAKTX'. ""자재내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
      WHEN 'ERFMG'. ""입고수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'ERFME'.
        <LS_FCAT>-EDIT = COND #( WHEN P_DISP = GC_X THEN '' ELSE GC_X ).
      WHEN 'ERFME'. ""단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
      WHEN 'EBELN'. ""구매오더번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
        <LS_FCAT>-EDIT = COND #( WHEN P_DISP = GC_X THEN '' ELSE GC_X ).
        <LS_FCAT>-F4AVAILABL = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'EBELN'.
        <LS_FCAT>-REF_FIELD = 'EBELN'.
        <LS_FCAT>-CHECKTABLE = '!'.
      WHEN 'EBELP'. ""구매오더품목
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-EDIT = COND #( WHEN P_DISP = GC_X THEN '' ELSE GC_X ).
        <LS_FCAT>-F4AVAILABL = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'EBELN'.
        <LS_FCAT>-REF_FIELD = 'EBELP'.
        <LS_FCAT>-CHECKTABLE = '!'.
      WHEN 'LIFNR'. ""공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
      WHEN 'NAME1'. ""공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>."
      WHEN 'NAME1_W'. ""플랜트명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."
      WHEN 'LGORT'. ""저장위치
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
      WHEN 'LGOBE'. ""저장위치명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."
      WHEN 'POMAT'. ""PO 자재번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
      WHEN 'POMAKTX'. ""PO 자재내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>."
      WHEN 'MBLNR'. ""자재문서번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
      WHEN 'MESSAGE'. ""처리 메세지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = COND #( WHEN P_DISP = GC_X THEN GC_X ELSE '' ).
      WHEN 'ERDAT'. ""생성일자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H20 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = COND #( WHEN P_DISP = GC_X THEN '' ELSE GC_X ).
      WHEN 'ERNAM'. ""생성자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H21 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = COND #( WHEN P_DISP = GC_X THEN '' ELSE GC_X ).
      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CREATE_ALV_OBJECT_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE_ALV_OBJECT_200 .

  GO_CONT_200 = NEW #( CONTAINER_NAME = 'CON200' ).
  GO_GRID_200 = NEW #( I_PARENT = GO_CONT_200 I_APPL_EVENTS = ABAP_TRUE ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_EXCL_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_EXCL_200 .

  CLEAR:
   GT_EXCL_200[].

  GT_EXCL_200[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
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
*& Form F_SET_LAYO_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_LAYO_200 .

  CLEAR:
    GS_LAYO_200.

  GS_LAYO_200-SEL_MODE = GC_D.
  GS_LAYO_200-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO_200-ZEBRA = ABAP_TRUE.
  GS_LAYO_200-SMALLTITLE = ABAP_TRUE.
  GS_LAYO_200-NO_ROWMOVE = ABAP_TRUE.
  GS_LAYO_200-NO_ROWINS = ABAP_TRUE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_VARI_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_VARI_200 .

  CLEAR:
    GS_VARI_200.

  GS_VARI_200-REPORT = SY-REPID.
  GS_VARI_200-USERNAME = SY-UNAME.
  GS_VARI_200-HANDLE = 'AL02'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_FCAT_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_FCAT_200 .

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_SCR_LIST CHANGING GT_FCAT_200.
  PERFORM F_ADJ_FCAT_200.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_EVENT_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ALV_EVENT_200 .

  CALL METHOD GO_GRID_200->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DISPLAY_ALV_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DISPLAY_ALV_200 .

  CALL METHOD GO_GRID_200->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_200
      IT_TOOLBAR_EXCLUDING = GT_EXCL_200[]
      IS_VARIANT           = GS_VARI_200
      I_SAVE               = GV_ASAVE_200
    CHANGING
      IT_OUTTAB            = GT_POP[]
      IT_FIELDCATALOG      = GT_FCAT_200[]
      IT_SORT              = GT_SORT_200[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_200 .

  LOOP AT GT_FCAT_200 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'. ""상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = COND #( WHEN P_DISP = ABAP_TRUE THEN ABAP_TRUE ELSE '' ).
      WHEN 'BUDAT'.
        IF P_DISP = 'X'. "입고일자
          PERFORM F_SET_FCAT_COLTXT USING TEXT-F01 CHANGING <LS_FCAT>."
        ELSE. "납품일자
          PERFORM F_SET_FCAT_COLTXT USING TEXT-F02 CHANGING <LS_FCAT>."
        ENDIF.
      WHEN 'LOTNO'. ""LOT NO.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F10 CHANGING <LS_FCAT>."
      WHEN 'KUNWE'. ""납품처
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F12 CHANGING <LS_FCAT>."
      WHEN 'KUNNR2'. ""납품처명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F04 CHANGING <LS_FCAT>."
      WHEN 'KUNNR'. ""판매처
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F13 CHANGING <LS_FCAT>."
        <LS_FCAT>-EDIT = COND #( WHEN P_DISP = ABAP_TRUE THEN '' ELSE GC_X ).
        <LS_FCAT>-F4AVAILABL = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'KNA1'.
        <LS_FCAT>-REF_FIELD = 'KUNNR'.
      WHEN 'NAME1_K'. "판매처명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F14 CHANGING <LS_FCAT>."
      WHEN 'VGBEL'. ""납품문서번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F05 CHANGING <LS_FCAT>."
        CLEAR <LS_FCAT>-EDIT.
      WHEN 'VGPOS'. ""납품문서품목
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F06 CHANGING <LS_FCAT>."
        CLEAR <LS_FCAT>-EDIT.
      WHEN 'MATNR'. ""자재번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
      WHEN 'MAKTX'. ""자재내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
      WHEN 'ERFMG'. ""납품수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'ERFME'.
      WHEN 'ERFME'. ""단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
      WHEN 'TRANS'. ""운송사 'TRANS_N'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F07 CHANGING <LS_FCAT>."
      WHEN 'TRUCK_NO'. ""차량번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F08 CHANGING <LS_FCAT>."
      WHEN 'GRADE'. ""등급
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F09 CHANGING <LS_FCAT>."
      WHEN 'EBELN'. ""구매오더번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
        <LS_FCAT>-EDIT = COND #( WHEN P_DISP = ABAP_TRUE THEN '' ELSE GC_X ).
*        <LS_FCAT>-F4AVAILABL = ABAP_TRUE.
*        <LS_FCAT>-REF_TABLE = 'EBELN'.
*        <LS_FCAT>-REF_FIELD = 'EBELN'.
      WHEN 'EBELP'. ""구매오더품목
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-EDIT = COND #( WHEN P_DISP = ABAP_TRUE THEN '' ELSE GC_X ).
*        <LS_FCAT>-F4AVAILABL = ABAP_TRUE.
      WHEN 'POMAT'. ""PO 자재번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
      WHEN 'POMAKTX'. ""PO 자재내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>."
      WHEN 'LIFNR'. ""공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
      WHEN 'NAME1'. ""공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>."
      WHEN 'NAME1_W'. ""플랜트명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."
      WHEN 'LGORT'. ""저장위치
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
        <LS_FCAT>-EDIT = COND #( WHEN P_DISP = ABAP_TRUE THEN '' ELSE GC_X ).
        <LS_FCAT>-F4AVAILABL = ABAP_TRUE.
        <LS_FCAT>-CHECKTABLE = '!'.
      WHEN 'LGOBE'. ""저장위치명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."
      WHEN 'MBLNR'. ""자재문서번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
      WHEN 'VBELN'. "판매문서번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F17 CHANGING <LS_FCAT>."
        <LS_FCAT>-EDIT = COND #( WHEN P_DISP = ABAP_TRUE THEN '' ELSE GC_X ).
      WHEN 'POSNR'. "판매문서품목
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F18 CHANGING <LS_FCAT>."
        <LS_FCAT>-EDIT = COND #( WHEN P_DISP = ABAP_TRUE THEN '' ELSE GC_X ).
      WHEN 'GOGRADE'. "가온등급
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F15 CHANGING <LS_FCAT>."
        <LS_FCAT>-EDIT = COND #( WHEN P_DISP = ABAP_TRUE THEN '' ELSE GC_X ).
      WHEN 'ZBIGO4'. "비고
        PERFORM F_SET_FCAT_COLTXT USING TEXT-F16 CHANGING <LS_FCAT>."
      WHEN 'MESSAGE'. ""처리 메세지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = COND #( WHEN P_DISP = ABAP_TRUE THEN GC_X ELSE '' ).
      WHEN 'ERDAT'. ""생성일자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H20 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = COND #( WHEN P_DISP = ABAP_TRUE THEN '' ELSE GC_X ).
      WHEN 'ERNAM'. ""생성자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H21 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = COND #( WHEN P_DISP = ABAP_TRUE THEN '' ELSE GC_X ).
      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

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

  IF P_ELC = GC_X.
    READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<LIST>) INDEX PS_ROW_ID.
    CHECK SY-SUBRC = 0.

    CASE PS_COLUMN-FIELDNAME.
      WHEN 'MBLNR'. "자재 문서 번호
        CHECK <LIST>-MBLNR IS NOT INITIAL.
        IF <LIST>-MJAHR IS INITIAL.
          <LIST>-MJAHR =  <LIST>-BUDAT(4).
        ENDIF.

        CALL FUNCTION 'MIGO_DIALOG'
            EXPORTING
              I_MBLNR = <LIST>-MBLNR
              I_MJAHR = <LIST>-MJAHR.

      WHEN 'EBELN'.
          CHECK <LIST>-EBELN IS NOT INITIAL.

          SET PARAMETER ID 'BES' FIELD <LIST>-EBELN.
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

    ENDCASE.

  ELSEIF P_SCR = GC_X.
    READ TABLE GT_SCR_LIST ASSIGNING FIELD-SYMBOL(<SCR>) INDEX PS_ROW_ID.
    CHECK SY-SUBRC = 0.

    CASE PS_COLUMN-FIELDNAME.
      WHEN 'MBLNR'. "자재 문서 번호
        CHECK <SCR>-MBLNR IS NOT INITIAL.
        IF <SCR>-MJAHR IS INITIAL.
          <SCR>-MJAHR =  <SCR>-BUDAT(4).
        ENDIF.

        CALL FUNCTION 'MIGO_DIALOG'
            EXPORTING
              I_MBLNR = <SCR>-MBLNR
              I_MJAHR = <SCR>-MJAHR.

      WHEN 'EBELN'.
          CHECK <SCR>-EBELN IS NOT INITIAL.

          SET PARAMETER ID 'BES' FIELD <SCR>-EBELN.
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

    ENDCASE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_CREATE_ALV_OBJECT_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE_ALV_OBJECT_400 .

  GO_CONT_400 = NEW #( CONTAINER_NAME = 'CON400' ).
  GO_GRID_400 = NEW #( I_PARENT = GO_CONT_400  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_CREATE_ALV_OBJECT_500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE_ALV_OBJECT_500 .

  GO_CONT_500 = NEW #( CONTAINER_NAME = 'CON500' ).
  GO_GRID_500 = NEW #( I_PARENT = GO_CONT_500  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_EXCL_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_EXCL_400 .
  CLEAR:
   GT_EXCL_400[].

  GT_EXCL_400[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
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
*& Form F_SET_LAYO_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_LAYO_400 .

  CLEAR:
    GS_LAYO_400.

  GS_LAYO_400-SEL_MODE = GC_D.
  GS_LAYO_400-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO_400-ZEBRA = ABAP_TRUE.
  GS_LAYO_400-SMALLTITLE = ABAP_TRUE.
  GS_LAYO_400-NO_ROWMOVE = ABAP_TRUE.
  GS_LAYO_400-NO_ROWINS = ABAP_TRUE.
  GS_LAYO_400-STYLEFNAME = 'ZSTYLE'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_VARI_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_VARI_400 .

  CLEAR:
    GS_VARI_400.

  GS_VARI_400-REPORT = SY-REPID.
  GS_VARI_400-USERNAME = SY-UNAME.
  GS_VARI_400-HANDLE = 'AL04'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_FCAT_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_FCAT_400 .

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_MAN CHANGING GT_FCAT_400.
  PERFORM F_ADJ_FCAT_400.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_EVENT_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ALV_EVENT_400 .

  CALL METHOD GO_GRID_400->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  CREATE OBJECT GO_EVENT.
  SET HANDLER GO_EVENT->HANDLE_HOTSPOT_CLICK FOR GO_GRID_400.
  SET HANDLER GO_EVENT->HANDLE_DATA_CHANGED_FINISHED FOR GO_GRID_400.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DISPLAY_ALV_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DISPLAY_ALV_400 .

  CALL METHOD GO_GRID_400->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_400
      IT_TOOLBAR_EXCLUDING = GT_EXCL_400[]
      IS_VARIANT           = GS_VARI_400
      I_SAVE               = GV_ASAVE_400
    CHANGING
      IT_OUTTAB            = GT_MAN[]
      IT_FIELDCATALOG      = GT_FCAT_400[]
      IT_SORT              = GT_SORT_400[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_400 .
*  LOOP AT GT_FCAT_400 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
*    CASE <LS_FCAT>-FIELDNAME.
*      WHEN 'STATUS'. ""상태
*        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
*        <LS_FCAT>-JUST = GC_C.
*        <LS_FCAT>-ICON = ABAP_TRUE.
*
*      WHEN 'MJAHR'. ""자재문서연도
*        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
*        <LS_FCAT>-JUST = GC_C.
*        <LS_FCAT>-NO_OUT = ABAP_TRUE.
*
*      WHEN 'MBLNR'. ""자재문서번호
*        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>."
*        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
*        <LS_FCAT>-JUST = GC_C.
*
*      WHEN 'ZEILE'. ""자재문서품목
*        CASE ABAP_TRUE.
*          WHEN P_ALL.
*            <LS_FCAT>-TECH = ABAP_TRUE.
*          WHEN P_COM.
*            PERFORM F_SET_FCAT_COLTXT USING TEXT-H25 CHANGING <LS_FCAT>."
*        ENDCASE.
*
*
*      WHEN 'BUDAT'. ""전기일자
*        CASE ABAP_TRUE.
*          WHEN P_ALL.
*            <LS_FCAT>-TECH = ABAP_TRUE.
*          WHEN P_COM.
*            PERFORM F_SET_FCAT_COLTXT USING TEXT-H17 CHANGING <LS_FCAT>."
*        ENDCASE.
*
*      WHEN 'BWART'. ""이동유형
*        CASE ABAP_TRUE.
*          WHEN P_ALL.
*            <LS_FCAT>-TECH = ABAP_TRUE.
*          WHEN P_COM.
*            PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
*            <LS_FCAT>-JUST = GC_C.
*            <LS_FCAT>-REF_TABLE = 'T156T'.
*            <LS_FCAT>-REF_FIELD = 'BWART'.
*        ENDCASE.
*
*      WHEN 'BTEXT'.   "이동유형내역
*        CASE ABAP_TRUE.
*          WHEN P_ALL.
*            <LS_FCAT>-TECH = ABAP_TRUE.
*          WHEN P_COM.
*            PERFORM F_SET_FCAT_COLTXT USING TEXT-H26 CHANGING <LS_FCAT>.
*        ENDCASE.
*
*      WHEN 'WERKS'. ""플랜트
*        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
*        <LS_FCAT>-REF_TABLE = 'T001W'.
*        <LS_FCAT>-REF_FIELD = 'WERKS'.
*        <LS_FCAT>-JUST = GC_C.
*
*      WHEN 'NAME1'.   "플랜트명
*        PERFORM F_SET_FCAT_COLTXT USING TEXT-H27 CHANGING <LS_FCAT>."
*
*      WHEN 'LGORT'. ""From 저장위치
*        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."
*        <LS_FCAT>-REF_TABLE = 'T001L'.
*        <LS_FCAT>-REF_FIELD = 'LGORT'.
*        <LS_FCAT>-JUST = GC_C.
*
*      WHEN 'LGOBE_F'. ""From 저장위치명
*        PERFORM F_SET_FCAT_COLTXT USING TEXT-H32 CHANGING <LS_FCAT>."
*
*      WHEN 'MATNR'. ""자재번호
*        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
*        <LS_FCAT>-REF_TABLE = 'MARA'.
*        <LS_FCAT>-REF_FIELD = 'MATNR'.
*
*      WHEN 'MAKTX'. ""자재내역
*        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
*
*      WHEN 'ERFMG'. ""이전 수량
*        PERFORM F_SET_FCAT_COLTXT USING TEXT-H31 CHANGING <LS_FCAT>."
*        <LS_FCAT>-QFIELDNAME = 'ERFME'.
*        IF P_ALL EQ ABAP_TRUE.
*          <LS_FCAT>-EDIT = ABAP_TRUE.
*        ENDIF.
*
*      WHEN 'ERFME'. ""단위
*        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
*        <LS_FCAT>-JUST = GC_C.
*
*      WHEN 'USNAM'.   "생성자
*        CASE ABAP_TRUE.
*          WHEN P_ALL.
*            <LS_FCAT>-TECH = ABAP_TRUE.
*          WHEN P_COM.
*            PERFORM F_SET_FCAT_COLTXT USING TEXT-H29 CHANGING <LS_FCAT>.
*            <LS_FCAT>-JUST = GC_C.
*        ENDCASE.
*
*      WHEN 'UMLGO'. ""To-저장위치
*        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."
*        <LS_FCAT>-REF_TABLE = 'T001L'.
*        <LS_FCAT>-REF_FIELD = 'LGORT'.
*        <LS_FCAT>-JUST = GC_C.
*        IF P_ALL EQ ABAP_TRUE.
*          <LS_FCAT>-EDIT = ABAP_TRUE.
*        ENDIF.
*
*      WHEN 'LGOBE_T'. ""To 저장위치명
*        PERFORM F_SET_FCAT_COLTXT USING TEXT-H33 CHANGING <LS_FCAT>."
*
*      WHEN 'UMCHA'. ""입고 배치
*        CASE ABAP_TRUE.
*          WHEN P_ALL.
*            <LS_FCAT>-TECH = ABAP_TRUE.
*          WHEN P_COM.
*            PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
*        ENDCASE.
*
*      WHEN 'SMBLN'. ""취소 자재문서번호
*        PERFORM F_SET_FCAT_COLTXT USING TEXT-H28 CHANGING <LS_FCAT>."
*        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
*
*      WHEN 'SJAHR'. ""취소 자재문서연도
*        PERFORM F_SET_FCAT_COLTXT USING TEXT-H30 CHANGING <LS_FCAT>."
*        <LS_FCAT>-NO_OUT = ABAP_TRUE.
*
*      WHEN 'MESSAGE'. ""처리 메시지
*        PERFORM F_SET_FCAT_COLTXT USING TEXT-H20 CHANGING <LS_FCAT>."
*
*      WHEN 'CHARG'. ""배치
*        CASE ABAP_TRUE.
*          WHEN P_ALL.
*            PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
*          WHEN P_COM.
*            <LS_FCAT>-TECH = ABAP_TRUE.
*        ENDCASE.
*
*      WHEN 'LABST'. ""재고수량
*        CASE ABAP_TRUE.
*          WHEN P_ALL.
*            PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>."
*            <LS_FCAT>-QFIELDNAME = 'ERFME'.
*          WHEN P_COM.
*            <LS_FCAT>-TECH = ABAP_TRUE.
*        ENDCASE.
*
*      WHEN OTHERS.
*        <LS_FCAT>-TECH = ABAP_TRUE.
*    ENDCASE.
*  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_DATA_CHANGED_FIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM F_DATA_CHANGED_FIN  USING    PV_MODIFIED TYPE CHAR01
                                     PT_GOOD_CELLS TYPE LVC_T_MODI.

*  CHECK PV_MODIFIED EQ ABAP_TRUE.
*  PERFORM F_REFRESH_ALV USING GO_GRID_100.

*  CASE ABAP_TRUE.
*    WHEN P_ELC.
*    WHEN P_SCR.
*      FIELD-SYMBOLS <LS_MAN> TYPE TY_SCR_LIST.
*
*      LOOP AT PT_GOOD_CELLS ASSIGNING  FIELD-SYMBOL(<LS_G0>)
*                                                                    GROUP BY ( ROW_ID = <LS_G0>-ROW_ID )
*                                                                    ASSIGNING FIELD-SYMBOL(<LS_GROUP>).
*
*        READ TABLE GT_MAN ASSIGNING <LS_MAN> INDEX <LS_GROUP>-ROW_ID.
*        CHECK SY-SUBRC EQ 0.
*
*        " 저장위치 입력시 저장위치 명 할당
*        PERFORM F_SET_CHECK_LGOBE CHANGING <LS_MAN>.
*      ENDLOOP.
*
*      PERFORM F_REFRESH_ALV USING GO_GRID_400.
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM F_DATA_CHANGED  USING    PR_DATA_CHANGED
                                                   TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.
  CASE GC_X.
    WHEN P_SCR.
      PERFORM F_DATA_CHANGED_1 USING PR_DATA_CHANGED.

    WHEN P_ELC.
      PERFORM F_DATA_CHANGED_2 USING PR_DATA_CHANGED.

    WHEN OTHERS.
  ENDCASE.

  PERFORM F_REFRESH_ALV USING GO_GRID_100.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DATA_CHANGED_1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM F_DATA_CHANGED_1  USING    PR_DATA_CHANGED
                                                   TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  LOOP AT  PR_DATA_CHANGED->MT_GOOD_CELLS INTO DATA(LS_MOD_CELLS).

    READ TABLE GT_SCR_LIST  INTO DATA(LS_LIST) INDEX LS_MOD_CELLS-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    CASE LS_MOD_CELLS-FIELDNAME.

      WHEN 'KUNNR'. "판매처
        SELECT SINGLE NAME1
          FROM KNA1
          WHERE KUNNR = @LS_MOD_CELLS-VALUE
          INTO @LS_LIST-NAME1_K.

        IF SY-SUBRC = 0.
          LS_LIST-KUNNR = LS_MOD_CELLS-VALUE.
        ELSE.
          CLEAR : LS_LIST-KUNNR, LS_LIST-NAME1_K.
        ENDIF.

      WHEN 'LGORT'.
        IF LS_MOD_CELLS-VALUE IS INITIAL.
          CLEAR : LS_LIST-LGORT, LS_LIST-LGOBE.

        ELSE.
          SELECT SINGLE  LGOBE
             FROM T001L
             WHERE WERKS = @P_WERKS AND LGORT =  @LS_MOD_CELLS-VALUE
             INTO  @LS_LIST-LGOBE.
        ENDIF.

      WHEN 'GOGRADE'.
        LS_LIST-GOGRADE = LS_MOD_CELLS-VALUE.

      WHEN OTHERS.
    ENDCASE.

    MODIFY GT_SCR_LIST FROM LS_LIST INDEX LS_MOD_CELLS-ROW_ID.
  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DATA_CHANGED_2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM F_DATA_CHANGED_2  USING    PR_DATA_CHANGED
                                                   TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  LOOP AT  PR_DATA_CHANGED->MT_GOOD_CELLS INTO DATA(LS_MOD_CELLS).

    READ TABLE GT_LIST  INTO DATA(LS_LIST) INDEX LS_MOD_CELLS-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    CASE LS_MOD_CELLS-FIELDNAME.
      WHEN 'ERFMG'.
        LS_LIST-ERFMG = LS_MOD_CELLS-VALUE.

      WHEN 'EBELN'.
        LS_LIST-EBELN = LS_MOD_CELLS-VALUE.

      WHEN 'EBELP'.
        LS_LIST-EBELP = LS_MOD_CELLS-VALUE.

      WHEN OTHERS.
    ENDCASE.

    MODIFY GT_LIST FROM LS_LIST INDEX LS_MOD_CELLS-ROW_ID.
  ENDLOOP.


ENDFORM.

**&---------------------------------------------------------------------*
**&      FORM  F_ON_F4
**&---------------------------------------------------------------------*
FORM F_ON_F4  USING E_FIELDNAME    TYPE LVC_FNAME
                  E_FIELDVALUE   TYPE LVC_VALUE
                  ES_ROW_NO      TYPE LVC_S_ROID
                  ER_EVENT_DATA  TYPE REF TO CL_ALV_EVENT_DATA
                  ET_BAD_CELLS   TYPE LVC_T_MODI
                  E_DISPLAY      TYPE CHAR01.

  DATA :
    LT_RETURN TYPE TABLE OF DDSHRETVAL,
    LS_RETURN TYPE DDSHRETVAL,
    LS_MODI   TYPE LVC_S_MODI.

  FIELD-SYMBOLS : <F4TAB> TYPE LVC_T_MODI.
  ASSIGN ER_EVENT_DATA->M_DATA->* TO <F4TAB>.

  CLEAR : LS_RETURN, LT_RETURN.

  IF E_FIELDNAME = 'LGORT'.

    SELECT LGORT, LGOBE
     FROM T001L
     WHERE WERKS = @P_WERKS
     INTO TABLE @DATA(LT_T001L).

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD   = 'LGORT'
        VALUE_ORG  = 'S'
      TABLES
        VALUE_TAB  = LT_T001L
        RETURN_TAB = LT_RETURN.

    IF SY-SUBRC <> 0.
      MESSAGE S000 WITH 'POSSIBLE ENTRY DATA가 없습니다 !!!'.
    ENDIF.

    IF SY-SUBRC = 0 AND LT_RETURN IS NOT INITIAL.
      READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.

      CLEAR : LS_MODI.
      LS_MODI-ROW_ID      = ES_ROW_NO-ROW_ID.
      LS_MODI-FIELDNAME = 'LGORT'.
      LS_MODI-VALUE        = LS_RETURN-FIELDVAL.
      APPEND LS_MODI TO <F4TAB>.
    ENDIF.

  ENDIF.

  ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.

ENDFORM.                                                    " F_ON_F4
