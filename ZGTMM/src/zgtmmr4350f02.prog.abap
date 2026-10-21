*&---------------------------------------------------------------------*
*& Include          ZGTMMR4350F02
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

  CLEAR GT_EXCL_100[].

  GT_EXCL_100[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
*                       ( CL_GUI_ALV_GRID=>MC_MB_EXPORT )
                       ( CL_GUI_ALV_GRID=>MC_FC_REFRESH )
                       ( CL_GUI_ALV_GRID=>MC_FC_INFO ) ).

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

  CLEAR GS_LAYO_100.
  GS_LAYO_100-SEL_MODE = GC_A.
*  GS_LAYO_100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO_100-ZEBRA = ABAP_TRUE.
  GS_LAYO_100-NO_ROWMOVE = ABAP_TRUE.
  GS_LAYO_100-NO_ROWINS = ABAP_TRUE.
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

  CLEAR GS_VARI_100.

  GS_VARI_100-REPORT = SY-REPID.
  GS_VARI_100-USERNAME = SY-UNAME.

  IF P_NEW EQ ABAP_TRUE.
    GS_VARI_100-HANDLE = 'ROHD'.
  ELSE.
    GS_VARI_100-HANDLE = 'ROHN'.
  ENDIF.


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

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_ROH CHANGING GT_FCAT_100.
  PERFORM F_ADJ_FCAT_100.

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
*& Form F_ADJ_FCAT_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_100 .

  LOOP AT GT_FCAT_100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'. "상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'WERKS'. "플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'WERKS_TEXT'. "플랜트명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 15.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'BUDAT'. "입고 일자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'VLABELNO'. "라벨번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 15.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'MENGE'. "수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 12.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT9460'.
        <LS_FCAT>-REF_FIELD = 'MENGE'.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-EDIT = COND #( WHEN P_DISP = 'X' THEN 'X' ELSE '' ).
      WHEN 'MEINS'. "단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 7.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT9460'.
        <LS_FCAT>-REF_FIELD = 'MEINS'.
        <LS_FCAT>-EDIT = 'X'.
      WHEN 'LANCHAR'. "광특성
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."
        <LS_FCAT>-EDIT = 'X'.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'EBELN'. "구매 오더
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
        <LS_FCAT>-EDIT = COND #( WHEN P_DISP = 'X' THEN 'X' ELSE '' ).
        <LS_FCAT>-OUTPUTLEN = 12.

      WHEN 'EBELP'. "구매 오더 품목
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 7.
        <LS_FCAT>-EDIT = COND #( WHEN P_DISP = 'X' THEN 'X' ELSE '' ).

      WHEN 'LIFNR'. "공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 12.

      WHEN 'LIFNR_TEXT'. "공급업체명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 20.

      WHEN 'MATNR'. "자재 번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 18.

      WHEN 'TXZ01'. "자재 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 25.

      WHEN 'ERDAT'. "생성일
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 11.

      WHEN 'ERNAM'. "생성자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 11.

      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'VLABELNO' OR 'MENGE' OR 'MEINS' OR 'LANCHAR'.
        <LS_FCAT>-EDIT = P_NEW.
    ENDCASE.

    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'. "상태
        <LS_FCAT>-TECH = P_DISP.
      WHEN 'WERKS' OR 'WERKS_TEXT' OR 'BUDAT' OR 'EBELN' OR 'EBELP' OR 'LIFNR' OR 'LIFNR_TEXT' OR 'MATNR'
        OR 'TXZ01' OR 'ERDAT' OR 'ERNAM'.
        <LS_FCAT>-TECH = P_NEW.
    ENDCASE.

  ENDLOOP.


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

*  DATA:
*    LT_F4 TYPE LVC_T_F4,
*    LS_F4 TYPE LVC_S_F4.
*
*  LS_F4-FIELDNAME  = 'LGORT'.
*  LS_F4-REGISTER     = 'X'.
*  LS_F4-GETBEFORE  = 'X'.
*  LS_F4-CHNGEAFTER = 'X'.
*  APPEND LS_F4 TO LT_F4.
*
*  CALL METHOD GO_GRID_100->REGISTER_F4_FOR_FIELDS
*    EXPORTING
*      IT_F4 = LT_F4.

  GO_GRID_100->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
  GO_GRID_100->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_ENTER ).

  CREATE OBJECT GO_EVENT.
*  SET HANDLER GO_EVENT->HANDLE_HOTSPOT_CLICK FOR GO_GRID_100.
  SET HANDLER GO_EVENT->HANDLE_DATA_CHANGED FOR GO_GRID_100.
  SET HANDLER GO_EVENT->HANDLE_DATA_CHANGED_FINISHED FOR GO_GRID_100.
*  SET HANDLER GO_EVENT->HANDLE_ON_F4 FOR GO_GRID_100.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_DISPLAY_ALV_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DISPLAY_ALV_100 .

  CALL METHOD GO_GRID_100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_100
      IT_TOOLBAR_EXCLUDING = GT_EXCL_100[]
      IS_VARIANT           = GS_VARI_100
      I_SAVE               = GV_ASAVE_100
    CHANGING
      IT_OUTTAB            = GT_ROH[]
      IT_FIELDCATALOG      = GT_FCAT_100[]
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
*&      --> GO_GRID_100
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
*& Form F_CREATE_ALV_OBJECT_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE_ALV_OBJECT_200 .
  GO_CONT_200 = NEW #( CONTAINER_NAME = 'CON200' ).
  GO_GRID_200 = NEW #( I_PARENT = GO_CONT_200 ).
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

  CLEAR GT_EXCL_200[].

  GT_EXCL_200[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
*                       ( CL_GUI_ALV_GRID=>MC_MB_EXPORT )
                       ( CL_GUI_ALV_GRID=>MC_FC_REFRESH )
                       ( CL_GUI_ALV_GRID=>MC_FC_INFO ) ).

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

  CLEAR GS_LAYO_200.
  GS_LAYO_200-SEL_MODE = GC_A.
*  GS_LAYO_200-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO_200-ZEBRA = ABAP_TRUE.
  GS_LAYO_200-NO_ROWMOVE = ABAP_TRUE.
  GS_LAYO_200-NO_ROWINS = ABAP_TRUE.
  GS_LAYO_200-STYLEFNAME = 'ZSTYLE'.

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

  CLEAR GS_VARI_200.

  GS_VARI_200-REPORT = SY-REPID.
  GS_VARI_200-USERNAME = SY-UNAME.

  IF P_NEW EQ ABAP_TRUE.
    GS_VARI_200-HANDLE = 'EXWD'.
  ELSE.
    GS_VARI_200-HANDLE = 'EXWN'.
  ENDIF.

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

  IF P_NEW EQ ABAP_TRUE.
    PERFORM F_CREATE_FCAT_BY_ITAB USING GT_EXW_IN CHANGING GT_FCAT_200.
  ELSE.
    PERFORM F_CREATE_FCAT_BY_ITAB USING GT_EXW CHANGING GT_FCAT_200.
  ENDIF.

  PERFORM F_ADJ_FCAT_200.

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
      WHEN 'STATUS'. "상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'WERKS'. "플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'WERKS_TEXT'. "플랜트명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 15.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'BUDAT'. "출고 일자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H17 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'LOTNO'. "LOT번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 15.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'MENGE'. "납품수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H24 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 12.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT9461'.
        <LS_FCAT>-REF_FIELD = 'MENGE'.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'MEINS'. "단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 7.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT9461'.
        <LS_FCAT>-REF_FIELD = 'MEINS'.

      WHEN 'EBELN'. "구매 오더
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 12.

      WHEN 'EBELP'. "구매 오더 품목
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 7.

      WHEN 'LIFNR'. "공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 12.

      WHEN 'LIFNR_TEXT'. "공급업체명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 20.

      WHEN 'MATNR'. "자재 번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 18.

      WHEN 'TXZ01'. "자재 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 25.

      WHEN 'KUNNR2'. "납품처명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 25.

      WHEN 'TRANS'. "운송사
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H20 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 20.

      WHEN 'TRUCK_NO'. "차량번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H21 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 20.

      WHEN 'GRADE'. "등급
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H22 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 7.

      WHEN 'ERDAT'. "생성일
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 11.

      WHEN 'ERNAM'. "생성자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 11.

      WHEN 'MAKTX'. "자재명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H23 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 30.

      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

    CASE <LS_FCAT>-FIELDNAME.
      WHEN   'MAKTX' OR 'LOTNO'. "'KUNNR2' OR
        <LS_FCAT>-EDIT = P_NEW.

      WHEN 'EBELN' OR 'EBELP' OR 'BUDAT' OR 'MENGE' OR 'MEINS' OR
                  'KUNNR2' OR 'TRANS' OR 'TRUCK_NO' OR 'GRADE'.
        <LS_FCAT>-EDIT = 'X'.
    ENDCASE.

    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS' OR 'MAKTX'. "상태
        <LS_FCAT>-TECH = P_DISP.
      WHEN 'WERKS' OR 'WERKS_TEXT' OR 'EBELN' OR 'EBELP' OR 'LIFNR' OR 'LIFNR_TEXT' OR 'MATNR'
        OR 'TXZ01' OR 'ERDAT' OR 'ERNAM'.
        <LS_FCAT>-TECH = P_NEW.
    ENDCASE.

  ENDLOOP.

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

*  DATA:
*    LT_F4 TYPE LVC_T_F4,
*    LS_F4 TYPE LVC_S_F4.
*
*  LS_F4-FIELDNAME  = 'LGORT'.
*  LS_F4-REGISTER     = 'X'.
*  LS_F4-GETBEFORE  = 'X'.
*  LS_F4-CHNGEAFTER = 'X'.
*  APPEND LS_F4 TO LT_F4.
*
*  CALL METHOD GO_GRID_100->REGISTER_F4_FOR_FIELDS
*    EXPORTING
*      IT_F4 = LT_F4.

  GO_GRID_200->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
  GO_GRID_200->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_ENTER ).

  CREATE OBJECT GO_EVENT.
*  SET HANDLER GO_EVENT->HANDLE_HOTSPOT_CLICK FOR GO_GRID_200.
  SET HANDLER GO_EVENT->HANDLE_DATA_CHANGED FOR GO_GRID_200.
  SET HANDLER GO_EVENT->HANDLE_DATA_CHANGED_FINISHED FOR GO_GRID_200.
*  SET HANDLER GO_EVENT->HANDLE_ON_F4 FOR GO_GRID_200.


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
      IT_OUTTAB            = GT_EXW[]
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
  CASE ABAP_TRUE.
    WHEN P_ROH.
      PERFORM F_DATA_CHANGED_1 USING PR_DATA_CHANGED.
      PERFORM F_REFRESH_ALV USING GO_GRID_100.

    WHEN P_EXW.
      PERFORM F_DATA_CHANGED_2 USING PR_DATA_CHANGED.
      PERFORM F_REFRESH_ALV USING GO_GRID_200.

    WHEN OTHERS.
  ENDCASE.

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

    READ TABLE GT_ROH  INTO DATA(LS_LIST) INDEX LS_MOD_CELLS-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    CASE LS_MOD_CELLS-FIELDNAME.

*      WHEN 'EBELN'. "판매처
*        SELECT SINGLE EBELN, EBELP, WERKS, MATNR, TXZ01
*          FROM EKPO
*          WHERE EBELN = @LS_MOD_CELLS-VALUE
*          INTO @DATA(LS_EBELN).
*
*        IF SY-SUBRC = 0.
*          LS_LIST-EBELN = LS_EBELN-EBELN.
*          LS_LIST-WERKS = LS_EBELN-WERKS.
*          LS_LIST-MATNR = LS_EBELN-MATNR.
*          LS_LIST-TXZ01 = LS_EBELN-TXZ01.
*        ELSE.
*          CLEAR : LS_LIST-EBELN, LS_LIST-EBELP, LS_LIST-WERKS,
*                       LS_LIST-MATNR, LS_LIST-TXZ01.
*        ENDIF.
*
*      WHEN 'EBELP'.
*        IF LS_LIST-EBELN IS NOT INITIAL.
*          SELECT SINGLE EBELN, EBELP, WERKS, MATNR, TXZ01
*          FROM EKPO
*          WHERE EBELN = @LS_LIST-EBELN
*              AND EBELP = @LS_MOD_CELLS-VALUE
*          INTO @DATA(LS_EBELP).
*
*          IF SY-SUBRC = 0.
*            LS_LIST-EBELP = LS_EBELP-EBELP.
*            LS_LIST-MATNR = LS_EBELP-MATNR.
*            LS_LIST-TXZ01 = LS_EBELP-TXZ01.
*          ELSE.
*            CLEAR : LS_LIST-EBELN, LS_LIST-EBELP, LS_LIST-WERKS,
*                         LS_LIST-MATNR, LS_LIST-TXZ01.
*          ENDIF.
*
*        ELSE.
*          CLEAR : LS_LIST-EBELN, LS_LIST-EBELP, LS_LIST-WERKS,
*                       LS_LIST-MATNR, LS_LIST-TXZ01.
*        ENDIF.

      WHEN 'BUDAT'.
        LS_LIST-BUDAT = LS_MOD_CELLS-VALUE.

      WHEN 'MENGE'.
        LS_LIST-MENGE = LS_MOD_CELLS-VALUE.

      WHEN 'MEINS'.
        LS_LIST-MEINS = LS_MOD_CELLS-VALUE.

      WHEN 'LANCHAR'.
        LS_LIST-LANCHAR = LS_MOD_CELLS-VALUE.

      WHEN OTHERS.
    ENDCASE.

    MODIFY GT_ROH FROM LS_LIST INDEX LS_MOD_CELLS-ROW_ID.
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

    READ TABLE GT_EXW  INTO DATA(LS_LIST) INDEX LS_MOD_CELLS-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    CASE LS_MOD_CELLS-FIELDNAME.
*      WHEN 'EBELN'. "판매처
*        SELECT SINGLE EBELN, EBELP, WERKS, MATNR, TXZ01
*          FROM EKPO
*          WHERE EBELN = @LS_MOD_CELLS-VALUE
*          INTO @DATA(LS_EKPO).
*
*        IF SY-SUBRC = 0.
*          LS_LIST-EBELN = LS_EKPO-EBELN.
*          LS_LIST-WERKS = LS_EKPO-WERKS.
*          LS_LIST-MATNR = LS_EKPO-MATNR.
*          LS_LIST-TXZ01 = LS_EKPO-TXZ01.
*        ELSE.
*          CLEAR : LS_LIST-EBELN, LS_LIST-EBELP,
*                       LS_LIST-MATNR, LS_LIST-WERKS, LS_LIST-TXZ01.
*        ENDIF.
*
*      WHEN 'EBELP'.
*        IF LS_LIST-EBELN IS NOT INITIAL.
*          CLEAR LS_EKPO.
*          SELECT SINGLE EBELN, EBELP, WERKS, MATNR
*          FROM EKPO
*          WHERE EBELN = @LS_LIST-EBELN
*              AND EBELP = @LS_MOD_CELLS-VALUE
*          INTO @DATA(LV_EBELP).
*
*          IF SY-SUBRC = 0.
*            LS_LIST-EBELP = LV_EBELP.
*          ELSE.
*            CLEAR : LS_LIST-EBELN, LS_LIST-EBELP.
*          ENDIF.
*
*        ELSE.
*          CLEAR : LS_LIST-EBELN, LS_LIST-EBELP.
*        ENDIF.

      WHEN 'BUDAT'.
        LS_LIST-BUDAT = LS_MOD_CELLS-VALUE.

      WHEN 'MENGE'.
        LS_LIST-MENGE = LS_MOD_CELLS-VALUE.

      WHEN 'MEINS'.
        LS_LIST-MEINS = LS_MOD_CELLS-VALUE.

      WHEN 'TRANS'.
        LS_LIST-TRANS = LS_MOD_CELLS-VALUE.

      WHEN 'TRUCK_NO'.
        LS_LIST-TRUCK_NO = LS_MOD_CELLS-VALUE.

      WHEN 'GRADE'.
        LS_LIST-GRADE = LS_MOD_CELLS-VALUE.

      WHEN OTHERS.
    ENDCASE.

    MODIFY GT_EXW FROM LS_LIST INDEX LS_MOD_CELLS-ROW_ID.
  ENDLOOP.


ENDFORM.
