*&---------------------------------------------------------------------*
*& Include          ZGTMMR4270F02
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form F_CREATE_ALV_OBJECT_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE_ALV_OBJECT_100.
  DATA:
    LO_SPLIT  TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
    LO_CNTR_T TYPE REF TO CL_GUI_CONTAINER,
    LO_CNTR_M TYPE REF TO CL_GUI_CONTAINER,
    LO_CNTR_B TYPE REF TO CL_GUI_CONTAINER.

  GO_CONT_100 = NEW #( CONTAINER_NAME = 'CON100' ).

  "Split Container
  LO_SPLIT = NEW #( PARENT  = GO_CONT_100
                    ROWS    = 3
                    COLUMNS = 1 ).

  LO_CNTR_T = LO_SPLIT->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
  LO_CNTR_M = LO_SPLIT->GET_CONTAINER( ROW = 2 COLUMN = 1 ).
  LO_CNTR_B = LO_SPLIT->GET_CONTAINER( ROW = 3 COLUMN = 1 ).

  "ALV Obj.
  GO_GRID_100_T = NEW #( I_PARENT = LO_CNTR_T ).
  GO_GRID_100_M = NEW #( I_PARENT = LO_CNTR_M ).
  GO_GRID_100_B = NEW #( I_PARENT = LO_CNTR_B ).


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
   GT_EXCL_100_T[],
   GT_EXCL_100_M[],
   GT_EXCL_100_B[].

  GT_EXCL_100_T[] = GT_EXCL_100_M[] = GT_EXCL_100_B[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
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
FORM F_SET_LAYO_100.

  CLEAR:
    GS_LAYO_100_T,
    GS_LAYO_100_M,
    GS_LAYO_100_B.

  GS_LAYO_100_T-SEL_MODE = GC_A.
*  GS_LAYO_100_T-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO_100_T-ZEBRA = ABAP_TRUE.
  GS_LAYO_100_T-SMALLTITLE = ABAP_TRUE.
  GS_LAYO_100_T-STYLEFNAME = 'ZSTYLE'.
  GS_LAYO_100_T-NO_ROWMOVE = ABAP_TRUE.
  GS_LAYO_100_T-NO_ROWINS = ABAP_TRUE.

  GS_LAYO_100_B = GS_LAYO_100_M = GS_LAYO_100_T.

*"업체명(NAME1) && ' 드럼 실적'
*EX) 용남목재 드럼 실적"
  SELECT SINGLE
    NAME1
    FROM LFA1
    WHERE LIFNR EQ @P_LIFNR
    INTO @DATA(LV_NAME1).
  GS_LAYO_100_T-GRID_TITLE = |{ LV_NAME1 } { TEXT-AT1 }|.

  GS_LAYO_100_M-GRID_TITLE = TEXT-AT2.
  GS_LAYO_100_B-GRID_TITLE = TEXT-AT3.

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
    GS_VARI_100_T,
    GS_VARI_100_M,
    GS_VARI_100_B.

  GS_VARI_100_T-REPORT = SY-REPID.
  GS_VARI_100_T-USERNAME = SY-UNAME.
  GS_VARI_100_T-HANDLE = 'ALD1'.

  GS_VARI_100_M-REPORT = SY-REPID.
  GS_VARI_100_M-USERNAME = SY-UNAME.
  GS_VARI_100_M-HANDLE = 'ALD2'.

  GS_VARI_100_B-REPORT = SY-REPID.
  GS_VARI_100_B-USERNAME = SY-UNAME.
  GS_VARI_100_B-HANDLE = 'ALD3'.

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

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_DAY CHANGING GT_FCAT_100_T.
  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_ITEM CHANGING GT_FCAT_100_M.
  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_PO CHANGING GT_FCAT_100_B.

  PERFORM F_ADJ_FCAT_100_T.
  PERFORM F_ADJ_FCAT_100_M.
  PERFORM F_ADJ_FCAT_100_B.

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

  GO_GRID_100_T->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
  GO_GRID_100_M->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
  GO_GRID_100_B->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).

*
  CREATE OBJECT GCL_EVENT_100_T.
  CREATE OBJECT GCL_EVENT_100_M.
  CREATE OBJECT GCL_EVENT_100_B.

  SET HANDLER:
    GCL_EVENT_100_T->HANDLE_HOTSPOT_CLICK FOR GO_GRID_100_T,
    GCL_EVENT_100_T->HANDLE_DOUBLE_CLICK FOR GO_GRID_100_T,
    GCL_EVENT_100_T->HANDLE_TOOLBAR FOR GO_GRID_100_T,
    GCL_EVENT_100_T->HANDLE_USER_COMMAND FOR GO_GRID_100_T,
    GCL_EVENT_100_T->HANDLE_DATA_CHANGED_FINISHED FOR GO_GRID_100_T.

  SET HANDLER:
    GCL_EVENT_100_M->HANDLE_DOUBLE_CLICK FOR GO_GRID_100_M,
    GCL_EVENT_100_M->HANDLE_TOOLBAR FOR GO_GRID_100_M,
    GCL_EVENT_100_M->HANDLE_USER_COMMAND FOR GO_GRID_100_M,
    GCL_EVENT_100_M->HANDLE_DATA_CHANGED_FINISHED FOR GO_GRID_100_M.

  SET HANDLER:
    GCL_EVENT_100_B->HANDLE_HOTSPOT_CLICK FOR GO_GRID_100_B,
    GCL_EVENT_100_B->HANDLE_DATA_CHANGED_FINISHED FOR GO_GRID_100_B.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_SORT_100_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*FORM F_SET_ALV_SORT_100_T .
*
*ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DISPLAY_ALV_100_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DISPLAY_ALV_100.

  CALL METHOD GO_GRID_100_T->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_100_T
      IT_TOOLBAR_EXCLUDING = GT_EXCL_100_T[]
      IS_VARIANT           = GS_VARI_100_T
      I_SAVE               = GV_ASAVE_100_T
    CHANGING
      IT_OUTTAB            = GT_DAY[]
      IT_FIELDCATALOG      = GT_FCAT_100_T[]
      IT_SORT              = GT_SORT_100_T[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL METHOD GO_GRID_100_M->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_100_M
      IT_TOOLBAR_EXCLUDING = GT_EXCL_100_M[]
      IS_VARIANT           = GS_VARI_100_M
      I_SAVE               = GV_ASAVE_100_M
    CHANGING
      IT_OUTTAB            = GT_ITEM[]
      IT_FIELDCATALOG      = GT_FCAT_100_M[]
      IT_SORT              = GT_SORT_100_M[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL METHOD GO_GRID_100_B->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_100_B
      IT_TOOLBAR_EXCLUDING = GT_EXCL_100_B[]
      IS_VARIANT           = GS_VARI_100_B
      I_SAVE               = GV_ASAVE_100_B
    CHANGING
      IT_OUTTAB            = GT_PO[]
      IT_FIELDCATALOG      = GT_FCAT_100_B[]
      IT_SORT              = GT_SORT_100_B[]
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
*&      --> GO_GRID_100_T
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
*& Form F_ADJ_FCAT_100_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_100_T .

  LOOP AT GT_FCAT_100_T ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.

      WHEN 'STATUS'. ""점검
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 4.
      WHEN 'ZSTAT'. ""상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 4.
      WHEN 'BUKRS'. ""회사코드
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'EKORG'. ""구매조직
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'LIFNR'. ""공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'SPMON'. ""작업 월
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'ZDATE'. ""작업 일자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT4271'.
        <LS_FCAT>-REF_FIELD = 'ZDATE'.
      WHEN 'EMP_TIME'. ""직원 작업시간
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 11.
      WHEN 'DLAB_TIME'. ""일용공 작업시간
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 11.
      WHEN 'OVER_TIME'. ""잔업시간
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 11.
      WHEN 'MEINH'. ""시간 단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>."
      WHEN 'MJAHR'. ""문서 연도
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'MBLNR'. ""문서 번호(신)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'MBLNR_G'. ""문서 번호(고)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H64 CHANGING <LS_FCAT>."
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'MESSAGE'. ""메시지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 40.
      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.



    "수정 가능
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ZDATE' OR 'EMP_TIME' OR 'DLAB_TIME' OR 'OVER_TIME' .
        <LS_FCAT>-EDIT = GV_EDIT.
    ENDCASE.

  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT_100_M
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_100_M .

  LOOP AT GT_FCAT_100_M ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'. ""점검
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 4.
      WHEN 'ZSTAT'. ""상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 4.
      WHEN 'EKORG'. ""구매조직
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'LIFNR'. ""공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'ZDATE'. ""작업 일자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'DRM_TYPE'. ""드럼 구분
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'DRM_SG_TYPE'. ""신/고드럼 여부
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H17 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MATNR'. ""자재번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 12.
        <LS_FCAT>-INTLEN = 40.
        <LS_FCAT>-REF_TABLE = 'MARA'.
        <LS_FCAT>-REF_FIELD = 'MATNR'.
        <LS_FCAT>-CHECKTABLE = '!'.
      WHEN 'MAKTX'. ""자재내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 20.
      WHEN 'DRM_COUNT'. ""드럼 입고 수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H20 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'BPRME'.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'DRM_NETPR'. ""드럼 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H21 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'DRM_PRICE'. ""드럼 입고 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H22 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'PO_COUNT'. ""PO지정 수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H23 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'BPRME'.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'BOARD_COUNT'. ""골판지 조립
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H24 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'BPRME'.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'BOARD_NETPR'. ""골판지 조립 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H25 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'BOARD_PRICE'. ""골판지 조립 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H26 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MARK_COUNT'. ""마킹(합계)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H27 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'BPRME'.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'MARK_NETPR'. ""신드럼 마킹 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H28 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MARK_PRICE'. ""신드럼 마킹 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H29 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MARK_N_COUNT'. ""일반 마킹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H30 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'BPRME'.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'MARK_N_NETPR'. ""기본 마킹 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H31 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MARK_N_PRICE'. ""기본 마킹 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H32 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MARK_H_COUNT'. ""한전 마킹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H33 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'BPRME'.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'MARK_H_NETPR'. ""한전 마킹 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H34 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MARK_H_PRICE'. ""한전 마킹 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H35 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'DIS_COUNT'. ""고드럼 해체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H36 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'BPRME'.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'DIS_NETPR'. ""고드럼 해체 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H37 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'DIS_PRICE'. ""고드럼 해체 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H38 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'WAERS'. ""통화키
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H39 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MEINS'. ""단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H40 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = GC_C.
      WHEN 'PEINH'. ""가격 단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H41 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'BPRME'. ""조건 단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H42 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MESSAGE'. ""메시지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 30.

      WHEN 'DRM_LV'.
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H72 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 5.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

    "수정 가능
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'MATNR' OR 'DRM_COUNT' OR 'BOARD_COUNT' OR 'MARK_COUNT'  OR 'MARK_H_COUNT' OR 'DIS_COUNT'.
        <LS_FCAT>-EDIT = GV_EDIT.
    ENDCASE.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT_100_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_100_B .

  LOOP AT GT_FCAT_100_B ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'. ""점검
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 4.
      WHEN 'ZSTAT'. ""상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 4.
      WHEN 'EBELN'. ""PO 번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H43 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
      WHEN 'EBELP'. ""항번
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H44 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 3.
      WHEN 'BUKRS'. ""회사 코드
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'LIFNR'. ""공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'MATNR'. ""자재코드
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H45 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 12.
      WHEN 'TXZ01'. ""내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H46 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 20.
      WHEN 'ERNAM'. ""생성자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H47 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'AEDAT'. ""생성일
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H48 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'EINDT'. ""납품요청일
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H49 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'VBELN'. ""판매오더
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H50 CHANGING <LS_FCAT>."
        <LS_FCAT>-EMPHASIZE = 'C500'.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'KUNNR'. ""고객
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H51 CHANGING <LS_FCAT>."
        <LS_FCAT>-EMPHASIZE = 'C500'.
      WHEN 'NAME1'. ""고객명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H52 CHANGING <LS_FCAT>."
        <LS_FCAT>-EMPHASIZE = 'C500'.
      WHEN 'NETPR'. ""PO 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H53 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'UEBTO'. ""초과납품(%)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H54 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 8.
      WHEN 'UEBTK'. ""무제한
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H55 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'MENGE'. ""PO 수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H56 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-EMPHASIZE = 'C300'.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'WEMNG'. ""입고완료 수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H57 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-EMPHASIZE = 'C300'.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'REMAIN_QNT'. ""잔여수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H58 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-EMPHASIZE = 'C300'.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'REMAIN_MAX_QNT'. ""잔여수량(최대)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H59 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'ENTRY_QNT'. ""입고수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H60 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'MEINS'. ""오더 단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H61 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = GC_C.
      WHEN 'WAERS'. ""통화키
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H39 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ELIKZ'. ""납품 완료 지시자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H62 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'LOEKZ'. ""삭제 지시자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H63 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MESSAGE'. ""메시지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 25.
      WHEN 'LGORT'. ""저장위치
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H65 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

    "수정 가능
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ENTRY_QNT'.
        <LS_FCAT>-EDIT = GV_EDIT.
    ENDCASE.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_HOTSPOT_CLICK_100_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_ROW_NO_ROW_ID
*&      --> E_COLUMN_ID
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM F_HOTSPOT_CLICK_100_T  USING PS_ROW_ID TYPE INT4
                                               PS_COLUMN TYPE LVC_S_COL
                                               PO_SENDER.

  CHECK PS_ROW_ID IS NOT INITIAL.
  READ TABLE GT_DAY ASSIGNING FIELD-SYMBOL(<LS_DAY>) INDEX PS_ROW_ID.
  CHECK SY-SUBRC EQ 0.
  CASE PS_COLUMN-FIELDNAME.
    WHEN 'MBLNR'. "자재문서(신)

      IF <LS_DAY>-MBLNR IS NOT INITIAL.
        CALL FUNCTION 'MIGO_DIALOG'
          EXPORTING
            I_MBLNR = <LS_DAY>-MBLNR
            I_MJAHR = <LS_DAY>-MJAHR.
      ENDIF.
    WHEN 'MBLNR_G'. "자재문서(고)

      IF <LS_DAY>-MBLNR_G IS NOT INITIAL.
        CALL FUNCTION 'MIGO_DIALOG'
          EXPORTING
            I_MBLNR = <LS_DAY>-MBLNR_G
            I_MJAHR = <LS_DAY>-MJAHR.
      ENDIF.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DOUBLE_CLICK_100_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_ROW_NO_ROW_ID
*&---------------------------------------------------------------------*
FORM F_DOUBLE_CLICK_100_T  USING  PV_ROW_ID.

  CHECK PV_ROW_ID GT 0.
*  저장되지 않은 상세 실적이 있습니다. 계속 진행하시겠습니까?
*
  DATA LV_ANS TYPE C LENGTH 1.
  SELECT SINGLE @ABAP_TRUE
    FROM @GT_ITEM AS ZZ
    WHERE ZZ~ZCHG EQ @ABAP_TRUE
    INTO @DATA(LV_CHK).

  IF LV_CHK EQ ABAP_TRUE.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR      = TEXT-TT3 "확인
        TEXT_QUESTION = TEXT-Q02
      IMPORTING
        ANSWER        = LV_ANS.
    CHECK LV_ANS EQ GC_1.
  ENDIF.

  READ TABLE GT_DAY ASSIGNING FIELD-SYMBOL(<LS_DAY>) INDEX PV_ROW_ID.
  CHECK SY-SUBRC EQ 0.

  "드럼 실적/PO 설정
  PERFORM F_SET_ITEM_DATA_100 USING <LS_DAY>.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DOUBLE_CLICK_100_M
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_ROW_NO_ROW_ID
*&---------------------------------------------------------------------*
FORM F_DOUBLE_CLICK_100_M  USING  PV_ROW_ID.

  CHECK PV_ROW_ID GT 0.
  READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>) INDEX PV_ROW_ID.
  CHECK SY-SUBRC EQ 0.

  CHECK <LS_ITEM>-MATNR IS NOT INITIAL AND <LS_ITEM>-ZDUPL EQ SPACE.

  "초기화
  CLEAR:
    GS_ITEM,
    GT_PO[].

  "값 설정
  GS_ITEM = <LS_ITEM>.
  GT_PO[] = CORRESPONDING #( <LS_ITEM>-IT_PO[] ).


*"구매오더 지정 - 자재번호 (자재내역)
*EX) 구매오더 지정 - 1001 (H14-3)
*
*자재번호, 자재 내역은 GT_ITEM의 SELECTED ROW - MATNR / MAKTX 값"
  DATA LV_MATNR TYPE C LENGTH 40.
  LV_MATNR = |{ <LS_ITEM>-MATNR ALPHA = OUT  }|.
  CONDENSE LV_MATNR.

  GS_LAYO_100_B-GRID_TITLE = |{ TEXT-AT3 } - { LV_MATNR }({ <LS_ITEM>-MAKTX })|.
  CALL METHOD GO_GRID_100_B->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO_100_B.

  "ALV Refresh
  PERFORM F_REFRESH_ALV USING GO_GRID_100_B.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_TOOLBAR_100_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&---------------------------------------------------------------------*
FORM F_TOOLBAR_100_T  USING  PR_OBJ TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

  CHECK GV_EDIT EQ ABAP_TRUE. "수정 모드인 경우만

  DATA : LS_TBAR TYPE STB_BUTTON.

  DEFINE _SET_TBAR.
    CLEAR : LS_TBAR.

    LS_TBAR-BUTN_TYPE = &1.
    LS_TBAR-FUNCTION   = &2.
    LS_TBAR-ICON           = &3.
    LS_TBAR-TEXT          = &4.
    LS_TBAR-QUICKINFO = &4.

    APPEND LS_TBAR TO PR_OBJ->MT_TOOLBAR.
  END-OF-DEFINITION.

  _SET_TBAR 3 SPACE SPACE SPACE.
  _SET_TBAR 0 'INSR'  ICON_INSERT_ROW   TEXT-BT1.
  _SET_TBAR 0 'DELE' ICON_DELETE_ROW  TEXT-BT2.
  _SET_TBAR 0 'SAVE' ICON_SYSTEM_SAVE TEXT-BT3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_TOOLBAR_100_M
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&---------------------------------------------------------------------*
FORM F_TOOLBAR_100_M  USING  PR_OBJ TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

  CHECK GV_EDIT EQ ABAP_TRUE. "수정 모드인 경우만

  DATA : LS_TBAR TYPE STB_BUTTON.

  DEFINE _SET_TBAR.
    CLEAR : LS_TBAR.

    LS_TBAR-BUTN_TYPE = &1.
    LS_TBAR-FUNCTION   = &2.
    LS_TBAR-ICON           = &3.
    LS_TBAR-TEXT          = &4.
    LS_TBAR-QUICKINFO = &4.

    APPEND LS_TBAR TO PR_OBJ->MT_TOOLBAR.
  END-OF-DEFINITION.

  _SET_TBAR 3 SPACE SPACE SPACE.

  CHECK GS_DAY-STATUS NE ICON_LED_RED.

  _SET_TBAR 0 'INSR'  ICON_INSERT_ROW   TEXT-BT1.
  _SET_TBAR 0 'DELE' ICON_DELETE_ROW  TEXT-BT2.
  _SET_TBAR 0 'SAVE' ICON_SYSTEM_SAVE TEXT-BT3.
  _SET_TBAR 3 SPACE SPACE SPACE.
  IF GS_DAY-STATUS EQ ICON_LED_GREEN.
    _SET_TBAR 0 'BTGR' ICON_ALLOW TEXT-BT4.
  ELSEIF GS_DAY-STATUS EQ ICON_LED_YELLOW.
    _SET_TBAR 0 'BTCA' ICON_REJECT TEXT-BT5.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_USER_COMMAND_100_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND_100_T  USING PV_UCOMM TYPE SY-UCOMM.

  CASE PV_UCOMM.
    WHEN 'INSR'. "행 추가
      PERFORM F_INSERT_ROW_100_T.
    WHEN 'DELE'. "행 삭제
      PERFORM F_DELETE_ROW_100_T.
    WHEN 'SAVE'.
      PERFORM F_SAVE_DATA_100_T.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_INSERT_ROW_100_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_INSERT_ROW_100_T .

  DATA LV_CHECK TYPE C LENGTH 1.
  CALL METHOD GO_GRID_100_T->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  SELECT SINGLE
    EKORG
    FROM T024E
    WHERE BUKRS EQ @P_BUKRS
    INTO @DATA(LV_EKORG).

  INSERT VALUE #( ZSTAT = ICON_CREATE
                             BUKRS = P_BUKRS
                             EKORG = LV_EKORG
                             WERKS = P_WERKS
                             LIFNR = P_LIFNR
                             MEINH = 'H'
                             ZNEW = ABAP_TRUE
                             ZCHG = ABAP_TRUE ) INTO GT_DAY INDEX 1.



  "데이터 점검
  DATA LT_DUPL TYPE TY_T_KEY_DAY.
  READ TABLE GT_DAY ASSIGNING FIELD-SYMBOL(<LS_DAY>) INDEX 1.
  PERFORM F_CHECK_VALUES_GT_DAY USING LT_DUPL CHANGING <LS_DAY>.

  PERFORM F_REFRESH_ALV USING GO_GRID_100_T.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DELETE_ROW_100_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DELETE_ROW_100_T .

  DATA:
    LV_ROW_ID  TYPE INT4,
    LV_DEL_CNT TYPE INT4,
    LV_CHECK   TYPE C LENGTH 1,
    LT_ROW_ID  TYPE LVC_T_ROID.

  CALL METHOD GO_GRID_100_T->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID_100_T->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_ID.

  DELETE LT_ROW_ID WHERE ROW_ID LE 0.
  CHECK LT_ROW_ID[] IS NOT INITIAL.

  CLEAR LV_CHECK.
  LOOP AT LT_ROW_ID ASSIGNING FIELD-SYMBOL(<LS_ROW_ID>).
    LV_ROW_ID = <LS_ROW_ID>-ROW_ID - LV_DEL_CNT.
    READ TABLE GT_DAY ASSIGNING FIELD-SYMBOL(<LS_DAY>) INDEX LV_ROW_ID.
    CHECK SY-SUBRC EQ 0.

    IF <LS_DAY>-ZSTAT EQ ICON_CREATE.

      "더블클릭으로 선택 된 Key 가 같으면 (중복인 경우 제외)
      IF GS_DAY-BUKRS EQ <LS_DAY>-BUKRS
        AND GS_DAY-WERKS EQ <LS_DAY>-WERKS
        AND GS_DAY-LIFNR EQ <LS_DAY>-LIFNR
        AND GS_DAY-ZDATE EQ <LS_DAY>-ZDATE
        AND <LS_DAY>-ZDUPL EQ SPACE.

        "입력한 실적 삭제
        DELETE GT_ITEM WHERE EKORG EQ <LS_DAY>-EKORG
        AND WERKS EQ <LS_DAY>-WERKS
        AND LIFNR EQ <LS_DAY>-LIFNR
        AND ZDATE EQ <LS_DAY>-ZDATE.

        "PO 삭제
        CLEAR:
          GS_ITEM,
          GT_PO[]. "전체 삭제

        GS_LAYO_100_M-GRID_TITLE = TEXT-AT2.
        CALL METHOD GO_GRID_100_M->SET_FRONTEND_LAYOUT
          EXPORTING
            IS_LAYOUT = GS_LAYO_100_M.

        GS_LAYO_100_B-GRID_TITLE = TEXT-AT3.
        CALL METHOD GO_GRID_100_B->SET_FRONTEND_LAYOUT
          EXPORTING
            IS_LAYOUT = GS_LAYO_100_B.

        LV_CHECK = ABAP_TRUE.
      ENDIF.

      DELETE GT_DAY INDEX LV_ROW_ID.
      LV_DEL_CNT += 1.
      CONTINUE.
    ELSE.
      "마감완료/입고완료/실적존재 인 경우 삭제 불가
      CHECK <LS_DAY>-ZCLSD EQ SPACE
      AND  <LS_DAY>-ZGR EQ SPACE
      AND  <LS_DAY>-ZCNF EQ SPACE.

      <LS_DAY>-ZSTAT = ICON_DELETE.
      <LS_DAY>-ZCHG = ABAP_TRUE.
    ENDIF.

  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_100_T.
  IF LV_CHECK EQ ABAP_TRUE.
    PERFORM F_REFRESH_ALV USING GO_GRID_100_M.
    PERFORM F_REFRESH_ALV USING GO_GRID_100_B.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DATA_CHANGED_FIN_100_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM F_DATA_CHANGED_FIN_100_T  USING    PV_MODIFIED TYPE CHAR01
                                     PT_GOOD_CELLS TYPE LVC_T_MODI.

  CHECK PV_MODIFIED EQ ABAP_TRUE.

  DATA:
    LV_CHECK TYPE C LENGTH 1,
    LT_DUPL  TYPE TY_T_KEY_DAY.

  FIELD-SYMBOLS <LS_DAY> TYPE TY_DAY.

  SELECT
    ZZ~ZDATE
    FROM @GT_DAY AS ZZ
    GROUP BY ZZ~ZDATE
    HAVING SUM( 1 ) GT 1
    ORDER BY ZZ~ZDATE
    INTO TABLE @LT_DUPL.

  "마감 기간 조회
  PERFORM F_GET_CLOSED_PERIOD.

  LOOP AT PT_GOOD_CELLS ASSIGNING  FIELD-SYMBOL(<LS_G0>)
                                                                GROUP BY ( ROW_ID = <LS_G0>-ROW_ID )
                                                                ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    READ TABLE GT_DAY ASSIGNING <LS_DAY> INDEX <LS_GROUP>-ROW_ID.
    CHECK SY-SUBRC EQ 0.


    "상태 설정
    IF <LS_DAY>-ZNEW EQ SPACE.
      <LS_DAY>-ZSTAT = ICON_CHANGE.
    ELSE.
      <LS_DAY>-ZSTAT = ICON_CREATE.
    ENDIF.

    <LS_DAY>-ZCHG = ABAP_TRUE.

    CLEAR LV_CHECK.
    LOOP AT GROUP <LS_GROUP> ASSIGNING FIELD-SYMBOL(<LS_CELLS>).
      IF <LS_CELLS>-FIELDNAME EQ 'ZDATE'.
        LV_CHECK  = ABAP_TRUE.
        EXIT.
      ENDIF.
    ENDLOOP.

    "작업일자 입력/변경 시 데이터 조회
    IF LV_CHECK EQ ABAP_TRUE.
      PERFORM F_SET_DATA_GT_DAY_LINE CHANGING <LS_DAY>.
    ENDIF.


    "데이터 점검
    PERFORM F_CHECK_VALUES_GT_DAY USING LT_DUPL CHANGING <LS_DAY>.

  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_100_T.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_USER_COMMAND_100_M
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND_100_M  USING PV_UCOMM TYPE SY-UCOMM.

  CASE PV_UCOMM.
    WHEN 'INSR'. "행 추가
      PERFORM F_INSERT_ROW_100_M.
    WHEN 'DELE'. "행 삭제
      PERFORM F_DELETE_ROW_100_M.
    WHEN 'SAVE'. "저장
      PERFORM F_SAVE_DATA_100_M.
    WHEN 'BTGR'. "입고
      PERFORM F_RUN_GR.
    WHEN 'BTCA'. "입고 취소
      PERFORM F_RUN_MBST.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_INSERT_ROW_100_M
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_INSERT_ROW_100_M .

  DATA LV_CHECK TYPE C LENGTH 1.
  CALL METHOD GO_GRID_100_M->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CHECK GS_DAY-ZCLSD EQ SPACE
      AND GS_DAY-ZDATE IS NOT INITIAL. "마감된 기간이 아닌 경우만


  SELECT SINGLE
    WAERS
    FROM T001
    WHERE BUKRS EQ @P_BUKRS
    INTO @DATA(LV_WAERS).

  INSERT VALUE #( ZSTAT = ICON_CREATE
                             EKORG = GS_DAY-EKORG
                             WERKS = GS_DAY-WERKS
                             LIFNR = GS_DAY-LIFNR
                             ZDATE = GS_DAY-ZDATE
                             WAERS = LV_WAERS
*                             MEINS = 'EA'
*                             BPRME = 'EA'
                             ZNEW = ABAP_TRUE
                             ZCHG = ABAP_TRUE ) INTO GT_ITEM INDEX 1.

  "데이터 점검

  READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>) INDEX 1.

  IF GS_DAY-ZGR EQ ABAP_TRUE.
    <LS_ITEM>-ZSTYLE[] = VALUE #( ( FIELDNAME = 'DRM_COUNT' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
  ENDIF.

  DATA:
    LT_DUPL  TYPE TY_T_KEY_ITEM,
    LT_FNAME TYPE TY_T_FNAME.

  PERFORM F_CHECK_VALUES_GT_ITEM USING LT_DUPL LT_FNAME CHANGING <LS_ITEM>.

  PERFORM F_REFRESH_ALV USING GO_GRID_100_M.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_VALUES_GT_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_DUPL
*&      <-- <LS_ITEM>
*&---------------------------------------------------------------------*
FORM F_CHECK_VALUES_GT_ITEM  USING  PT_DUPL TYPE TY_T_KEY_ITEM
                                                                  PT_FNAME TYPE TY_T_FNAME
                             CHANGING CS_ITEM LIKE GS_ITEM.

  DATA:
    LV_MSG TYPE BAPI_MSG,
    LT_MSG TYPE STANDARD TABLE OF TY_MSG_T.

  ""점검 설정
  CS_ITEM-STATUS = ICON_LED_GREEN. "기본 녹색 설정
  CS_ITEM-MESSAGE = SPACE.

*  필수값 누락             "행추가 시, 자재코드 입력 안한 경우
*GT_ITEM-MATNR IS INITIAL"      오류: 자재코드 누락
*"단가 미등록 자재
*(목드럼 외 자재코드도 여기서 걸러짐)"             "자재코드가 해당 연도 단가 리스트에 존재하지 않는 경우
*
*SELECT SINGLE @abap_true
*  INTO @DATA(lv_exists)
*  FROM ZGTMMT1042
* WHERE WERKS = GT_ITEM-WERKS
*     AND ZYEAR = GT_ITEM-ZDATE(4)
*     AND LIFNR = GT_ITEM-LIFNR
*     AND MATNR = GT_ITEM-MATNR"      오류: 단가 미존재
*자재코드 중복              "GT_ITEM 안에서 MATNR 중복
*(행추가 후, 기존에 ITAB에 있던 MATNR 입력한 경우)"      오류: 자재코드 중복
*실적 수량이 하나도 없는 경우             "DRM_COUNT, MARK_COUNT, BOARD_COUNT, DIS_COUNT
*전체 다 NULL인 경우"     오류: 실적 미존재

  CLEAR CS_ITEM-ZDUPL.

  "오류
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'MATNR' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
*필수값 누락             "행추가 시, 자재코드 입력 안한 경우
*GT_ITEM-MATNR IS INITIAL"      오류: 자재코드 누락
    IF CS_ITEM-MATNR IS INITIAL.
      CS_ITEM-STATUS = ICON_LED_RED.
      IF LV_MSG IS NOT INITIAL.
        LV_MSG = |{ LV_MSG }, { TEXT-E04 }|. "자재코드 누락
      ELSE.
        LV_MSG = TEXT-E04. "자재코드 누락
      ENDIF.

    ELSE.
*자재코드 중복              "GT_ITEM 안에서 MATNR 중복
*(행추가 후, 기존에 ITAB에 있던 MATNR 입력한 경우)"      오류: 자재코드 중복
      READ TABLE PT_DUPL WITH KEY MATNR = CS_ITEM-MATNR
                                          BINARY SEARCH TRANSPORTING NO FIELDS.
      IF SY-SUBRC EQ 0.
        CS_ITEM-ZDUPL = ABAP_TRUE.
        CS_ITEM-STATUS = ICON_LED_RED.

        IF LV_MSG IS NOT INITIAL.
          LV_MSG = |{ LV_MSG }, { TEXT-E05 }|. "자재코드 중복
        ELSE.
          LV_MSG = TEXT-E05. "자재코드 중복
        ENDIF.

      ENDIF.
    ENDIF.
  ENDIF.

*  "단가 미등록 자재
*(목드럼 외 자재코드도 여기서 걸러짐)"             "자재코드가 해당 연도 단가 리스트에 존재하지 않는 경우
*SELECT SINGLE @abap_true
*  INTO @DATA(lv_exists)
*  FROM ZGTMMT1042
* WHERE WERKS = GT_ITEM-WERKS
*     AND ZYEAR = GT_ITEM-ZDATE(4)
*     AND LIFNR = GT_ITEM-LIFNR
*     AND MATNR = GT_ITEM-MATNR"      오류: 단가 미존재

  IF CS_ITEM-DRM_NETPR IS INITIAL.
    CS_ITEM-STATUS = ICON_LED_RED.

    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }, { TEXT-E06 }|. "단가 미존재
    ELSE.
      LV_MSG = TEXT-E06. "단가 미존재
    ENDIF.
  ENDIF.
*
*실적 수량이 하나도 없는 경우             "DRM_COUNT, MARK_COUNT, BOARD_COUNT, DIS_COUNT
*전체 다 NULL인 경우"     오류: 실적 미존재
  IF CS_ITEM-DRM_COUNT IS INITIAL AND CS_ITEM-MARK_COUNT IS INITIAL AND CS_ITEM-BOARD_COUNT IS INITIAL AND CS_ITEM-DIS_COUNT IS INITIAL.
    CS_ITEM-STATUS = ICON_LED_RED.

    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }, { TEXT-E07 }|. "실적 미존재
    ELSE.
      LV_MSG = TEXT-E07. "실적 미존재
    ENDIF.
  ENDIF.

  "오류 메세지 추가
  IF LV_MSG IS NOT INITIAL.
    "오류:
    LV_MSG = |{ TEXT-E08 } { LV_MSG } |.
    LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = LV_MSG  ) ).

    CLEAR LV_MSG.
  ENDIF.


  "구매오더
  IF CS_ITEM-DRM_SG_TYPE EQ GC_S.
    CLEAR LV_MSG.
*  PO에 입고가능한 수량이 부족             "GT_ITEM-DRM_COUNT
*> SUM(GT_PO_ALL의 해당 자재 REMAIN_MAX_QNT)"      구매오더: 생성 필요
    SELECT SUM( ZZ~REMAIN_MAX_QNT )
      FROM @CS_ITEM-IT_PO AS ZZ
      INTO @DATA(LV_AQTY).
    IF LV_AQTY LT CS_ITEM-DRM_COUNT .
      CS_ITEM-STATUS = ICON_LED_RED.
      IF LV_MSG IS NOT INITIAL.
        LV_MSG = |{ LV_MSG }, { TEXT-E09 }|. "생성 필요
      ELSE.
        LV_MSG = TEXT-E09. "생성 필요
      ENDIF.
    ELSE.

*드럼 입고수량 <> PO 지정 수량  GT_ITEM-DRM_COUNT > GT_ITEM-PO_COUNT      구매오더: 미지정
      IF CS_ITEM-DRM_COUNT GT CS_ITEM-PO_COUNT.
        CS_ITEM-STATUS = ICON_LED_RED.
        IF LV_MSG IS NOT INITIAL.
          LV_MSG = |{ LV_MSG }, { TEXT-E10 }|. "미지정
        ELSE.
          LV_MSG = TEXT-E10. "미지정
        ENDIF.
      ENDIF.

*GT_ITEM-DRM_COUNT < GT_ITEM-PO_COUNT     구매오더: 초과 지정
      IF CS_ITEM-DRM_COUNT LT CS_ITEM-PO_COUNT.
        CS_ITEM-STATUS = ICON_LED_RED.
        IF LV_MSG IS NOT INITIAL.
          LV_MSG = |{ LV_MSG }, { TEXT-E11 }|. "초과 지정
        ELSE.
          LV_MSG = TEXT-E11. "초과 지정
        ENDIF.
      ENDIF.
    ENDIF.
*
*    "GT_ITEM-STATUS에 오류 CASE 하나 추가
*--> GT_ITEM-IT_PO에서 점검값 오류인데 ENTRY_QNT 값 존재하는 경우 빨간불
*--> 오류메시지) '구매오더: 오류 존재'"
    SELECT SINGLE
      @ABAP_TRUE
      FROM @CS_ITEM-IT_PO AS ZZ
      WHERE ZZ~STATUS EQ @ICON_LED_RED
      AND ZZ~ENTRY_QNT IS NOT INITIAL
      INTO @DATA(LV_PO_ERR).
    IF SY-SUBRC EQ 0.
      CS_ITEM-STATUS = ICON_LED_RED.
      IF LV_MSG IS NOT INITIAL.
        LV_MSG = |{ LV_MSG }, { TEXT-E20 }|. "오류 존재'
      ELSE.
        LV_MSG = TEXT-E20. "오류 존재'
      ENDIF.
    ENDIF.

    "오류 메세지 추가
    IF LV_MSG IS NOT INITIAL.
      "오류:
      LV_MSG = |{ TEXT-E12 } { LV_MSG } |.
      LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = LV_MSG  ) ).

      CLEAR LV_MSG.
    ENDIF.

  ENDIF.

*고드럼에 마킹 실적 존재              GT_ITEM-DRM_SG_TYPE = 'S' 인데 DIS_COUNT > 0      신드럼: 고드럼 해체 불가
*신드럼에 고드럼 해체 실적 존재              GT_ITEM-DRM_SG_TYPE = 'G' 인데 MARK_COUNT > 0     고드럼: 마킹 불가
  CASE CS_ITEM-DRM_SG_TYPE.
    WHEN GC_S.
      IF CS_ITEM-DIS_COUNT GT 0.
        CS_ITEM-STATUS = ICON_LED_RED.
        LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = TEXT-E13 ) ) .
      ENDIF.
    WHEN GC_G.
      IF CS_ITEM-MARK_COUNT GT 0.
        CS_ITEM-STATUS = ICON_LED_RED.
        LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = TEXT-E14 ) ) .
      ENDIF.
  ENDCASE.

*마킹 수량 < 한전 마킹 수량             MARK_COUNT < MARK_H_COUNT     한전 마킹: 초과 지정
  IF CS_ITEM-MARK_COUNT LT CS_ITEM-MARK_H_COUNT.
    CS_ITEM-STATUS = ICON_LED_RED.
    LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = TEXT-E15 ) ) .
  ENDIF.


  "메세지 설정
  LOOP AT LT_MSG ASSIGNING FIELD-SYMBOL(<LS_MSG>).
    IF CS_ITEM-MESSAGE IS NOT INITIAL.
      CS_ITEM-MESSAGE = |{ CS_ITEM-MESSAGE }, { <LS_MSG>-MESSAGE }|.
    ELSE.
      CS_ITEM-MESSAGE = <LS_MSG>-MESSAGE.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DATA_CHANGED_FIN_100_M
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM F_DATA_CHANGED_FIN_100_M  USING    PV_MODIFIED TYPE CHAR01
                                     PT_GOOD_CELLS TYPE LVC_T_MODI.

  CHECK PV_MODIFIED EQ ABAP_TRUE.

  DATA:
    LV_CHECK TYPE C LENGTH 1,
    LT_DUPL  TYPE TY_T_KEY_ITEM,
    LT_FNAME TYPE TY_T_FNAME.

  FIELD-SYMBOLS <LS_ITEM> LIKE GS_ITEM.

  SELECT
    ZZ~MATNR
    FROM @GT_ITEM AS ZZ
    GROUP BY ZZ~MATNR
    HAVING SUM( 1 ) GT 1
    ORDER BY ZZ~MATNR
    INTO TABLE @LT_DUPL.

  LOOP AT PT_GOOD_CELLS ASSIGNING  FIELD-SYMBOL(<LS_G0>)
                                                                GROUP BY ( ROW_ID = <LS_G0>-ROW_ID )
                                                                ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    READ TABLE GT_ITEM ASSIGNING <LS_ITEM> INDEX <LS_GROUP>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    "상태 설정
    IF <LS_ITEM>-ZNEW EQ SPACE.
      <LS_ITEM>-ZSTAT = ICON_CHANGE.
    ELSE.
      <LS_ITEM>-ZSTAT = ICON_CREATE.
    ENDIF.
    <LS_ITEM>-ZCHG = ABAP_TRUE.

    CLEAR LV_CHECK.

    CLEAR LT_FNAME[].
    LOOP AT GROUP <LS_GROUP> ASSIGNING FIELD-SYMBOL(<LS_CELLS>).
      LT_FNAME = VALUE #( BASE LT_FNAME ( FNAME = <LS_CELLS>-FIELDNAME ) ).
    ENDLOOP.

    "데이터 설정
    PERFORM F_SET_VALUES_GT_ITEM USING LT_FNAME CHANGING <LS_ITEM>.

    "데이터 점검
    PERFORM F_CHECK_VALUES_GT_ITEM USING LT_DUPL LT_FNAME CHANGING <LS_ITEM>.

  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_100_M.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DELETE_ROW_100_M
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DELETE_ROW_100_M .

  DATA:
    LV_ROW_ID  TYPE INT4,
    LV_DEL_CNT TYPE INT4,
    LV_CHECK   TYPE C LENGTH 1,
    LT_ROW_ID  TYPE LVC_T_ROID.

  CALL METHOD GO_GRID_100_M->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID_100_M->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_ID.

  DELETE LT_ROW_ID WHERE ROW_ID LE 0.
  CHECK LT_ROW_ID[] IS NOT INITIAL.

  CLEAR LV_CHECK.
  LOOP AT LT_ROW_ID ASSIGNING FIELD-SYMBOL(<LS_ROW_ID>).
    LV_ROW_ID = <LS_ROW_ID>-ROW_ID - LV_DEL_CNT.
    READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>) INDEX LV_ROW_ID.
    CHECK SY-SUBRC EQ 0.

    IF <LS_ITEM>-ZSTAT EQ ICON_CREATE.

      "더블클릭 한 자재코드랑 같으면
      IF GS_ITEM-MATNR EQ <LS_ITEM>-MATNR
        AND <LS_ITEM>-ZDUPL EQ SPACE.
        "PO 삭제
        CLEAR GT_PO[]. "전체 삭제

        GS_LAYO_100_B-GRID_TITLE = TEXT-AT3.
        CALL METHOD GO_GRID_100_B->SET_FRONTEND_LAYOUT
          EXPORTING
            IS_LAYOUT = GS_LAYO_100_B.

        LV_CHECK = ABAP_TRUE.
      ENDIF.

      DELETE GT_ITEM INDEX LV_ROW_ID.
      LV_DEL_CNT += 1.
      CONTINUE.

    ELSE.
      CASE GS_DAY-STATUS.
        WHEN ICON_LED_GREEN.
          <LS_ITEM>-ZSTAT = ICON_DELETE.
          <LS_ITEM>-ZCHG = ABAP_TRUE.
        WHEN ICON_LED_YELLOW.
          IF <LS_ITEM>-DRM_COUNT IS INITIAL.
            <LS_ITEM>-ZSTAT = ICON_DELETE.
            <LS_ITEM>-ZCHG = ABAP_TRUE.
          ENDIF.
      ENDCASE.
    ENDIF.
  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_100_M.

  IF LV_CHECK EQ ABAP_TRUE.
    PERFORM F_REFRESH_ALV USING GO_GRID_100_B.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SAVE_DATA_100_M
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SAVE_DATA_100_M .

  DATA:
    LV_ROW_ID  TYPE INT4,
    LV_DEL_CNT TYPE INT4,
    LV_CHECK   TYPE C LENGTH 1.

  CALL METHOD GO_GRID_100_M->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID_100_B->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CHECK GS_DAY-ZDATE IS NOT INITIAL.

  "<--2026.06.18 저장에서는 오류 체크 안하는 것으로 변경. 입고시 체크
*'오류가 존재하여  저장할 수 없습니다.' TYPE S DISPLAY LIKE E"
*  SELECT SINGLE @ABAP_TRUE
*    FROM @GT_ITEM AS ZZ
*    WHERE ZZ~ZCHG EQ @ABAP_TRUE "변경 건 중
*    AND ZZ~STATUS EQ @ICON_LED_RED "오류 아이콘인 데이터가 존재
*    AND ZZ~ZSTAT NE @ICON_DELETE
*    INTO @DATA(LV_CHK).
*  IF SY-SUBRC EQ 0.
*    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E03.
*    EXIT.
*  ENDIF.
  "2026.06.18 저장에서는 오류 체크 안하는 것으로 변경. 입고시 체크-->

*"GT_ITEM 저장/입고 기능 실행 시
*ZGTMMT4271 존재여부 체크, 없는 경우 오류메시지
*""일 실적(작업시간)이 저장되지 않은 작업일입니다."""

  SELECT SINGLE @ABAP_TRUE
    FROM ZGTMMT4271
    WHERE BUKRS EQ @GS_DAY-BUKRS
    AND EKORG EQ @GS_DAY-EKORG
    AND WERKS EQ @GS_DAY-WERKS
    AND LIFNR EQ @GS_DAY-LIFNR
    AND ZDATE EQ @GS_DAY-ZDATE
    INTO @DATA(LV_ZCHK).
  IF SY-SUBRC NE 0.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E19.
    EXIT.
  ENDIF.

  "POP UP TO CONFIRM
*일 상세 실적을 저장 하시겠습니까? (예/아니오)"
  DATA LV_ANS TYPE C LENGTH 1.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT3 "확인
      TEXT_QUESTION = TEXT-Q03
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.

  "CBO Table 저장
  PERFORM F_SAVE_DATA_ZGTMMT4272.

  "저장 후 ALV 적용
  PERFORM F_SET_ALV_DATA_AFTER_SAVE_ITEM.

  "헤더 설정
  DATA LT_DUPL TYPE TY_T_KEY_DAY.
  READ TABLE GT_DAY ASSIGNING FIELD-SYMBOL(<LS_DAY>) WITH KEY ZDATE = GS_DAY-ZDATE.
  "데이터 점검
  PERFORM F_CHECK_VALUES_GT_DAY USING LT_DUPL CHANGING <LS_DAY>.
  PERFORM F_REFRESH_ALV USING GO_GRID_100_T.

*	실패: TYPE S DISPLAY LIKE E 저장에 실패했습니다.
*	성공: TYPE S 저장에 성공했습니다.
  MESSAGE S000 WITH TEXT-M02.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_HOTSPOT_CLICK_100_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_ROW_NO_ROW_ID
*&      --> E_COLUMN_ID
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM F_HOTSPOT_CLICK_100_B  USING PS_ROW_ID TYPE INT4
                                               PS_COLUMN TYPE LVC_S_COL
                                               PO_SENDER.

  CHECK PS_ROW_ID IS NOT INITIAL.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'EBELN'. "구매오더
      READ TABLE GT_PO ASSIGNING FIELD-SYMBOL(<LS_PO>) INDEX PS_ROW_ID.
      CHECK SY-SUBRC EQ 0.
      IF <LS_PO>-EBELN IS NOT INITIAL.
        CALL FUNCTION 'ME_DISPLAY_PURCHASE_DOCUMENT'
          EXPORTING
            I_EBELN = <LS_PO>-EBELN
            I_EBELP = <LS_PO>-EBELP.
      ENDIF.


  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DATA_CHANGED_FIN_100_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM F_DATA_CHANGED_FIN_100_B  USING   PV_MODIFIED TYPE CHAR01
                                     PT_GOOD_CELLS TYPE LVC_T_MODI.

  CHECK PV_MODIFIED EQ ABAP_TRUE.

  FIELD-SYMBOLS <LS_PO> TYPE TY_PO.
  DATA LV_CHECK TYPE C LENGTH 1.

  LOOP AT PT_GOOD_CELLS ASSIGNING  FIELD-SYMBOL(<LS_G0>)
                                                                GROUP BY ( ROW_ID = <LS_G0>-ROW_ID )
                                                                ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    READ TABLE GT_PO ASSIGNING <LS_PO> INDEX <LS_GROUP>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    <LS_PO>-ZSTAT = ICON_CHANGE.

    "데이터 점검
    PERFORM F_CHECK_VALUES_GT_PO CHANGING <LS_PO>.

    "데이터 설정
*    CHECK <LS_PO>-STATUS NE ICON_LED_RED. "오류가 아닌 경우 적용
    PERFORM F_SET_VALUES_GT_PO USING <LS_PO> CHANGING LV_CHECK.

  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_100_B.
  IF LV_CHECK EQ ABAP_TRUE.
    PERFORM F_REFRESH_ALV USING GO_GRID_100_M.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_RUN_GR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_RUN_GR .

  DATA:
    LV_ROW_ID TYPE INT4,
    LV_CHECK  TYPE C LENGTH 1.

  CALL METHOD GO_GRID_100_M->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID_100_B->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CHECK GS_DAY-ZDATE IS NOT INITIAL.

*'오류가 존재하여 입고처리 할 수 없습니다.' TYPE S DISPLAY LIKE E"
  SELECT SINGLE @ABAP_TRUE
    FROM @GT_ITEM AS ZZ
    WHERE ZZ~STATUS EQ @ICON_LED_RED "오류 아이콘인 데이터가 존재
    INTO @DATA(LV_CHK).
  IF SY-SUBRC EQ 0.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E17.
    EXIT.
  ENDIF.

*"GT_ITEM 저장/입고 기능 실행 시
*ZGTMMT4271 존재여부 체크, 없는 경우 오류메시지
*""일 실적(작업시간)이 저장되지 않은 작업일입니다."""

  SELECT SINGLE @ABAP_TRUE
    FROM ZGTMMT4271
    WHERE BUKRS EQ @GS_DAY-BUKRS
    AND EKORG EQ @GS_DAY-EKORG
    AND WERKS EQ @GS_DAY-WERKS
    AND LIFNR EQ @GS_DAY-LIFNR
    AND ZDATE EQ @GS_DAY-ZDATE
    INTO @DATA(LV_ZCHK).
  IF SY-SUBRC NE 0.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E19.
    EXIT.
  ENDIF.

  "CBO Table 저장
  PERFORM F_SAVE_DATA_ZGTMMT4272.

  "저장 후 ALV 적용
  PERFORM F_SET_ALV_DATA_AFTER_SAVE_ITEM.

*[입고시 고드럼 포함한 경우 팝업 메시지]
*고드럼 입고 저장위치 지정
  SELECT SINGLE @ABAP_TRUE
  FROM @GT_ITEM AS ZZ
  WHERE ZZ~DRM_SG_TYPE EQ @GC_G "고드럼
   AND ZZ~DRM_COUNT IS NOT INITIAL
  INTO @DATA(LV_CHK_SG).
  IF SY-SUBRC EQ 0.
*[고드럼 팝업 저장위치 기본값]
*ZGTPPT1010 테이블
*MODULE_KIND = MM
*CODEGRP = '0720'
*FLD_01 = 플랜트
*FLD_02 = 저장위치

    CLEAR GS_SCR.
    GS_SCR-WERKS = GS_DAY-WERKS.
    SELECT SINGLE
      NAME1
      FROM T001W
      WHERE WERKS EQ @GS_SCR-WERKS
      INTO @GS_SCR-NAME1.

    SELECT SINGLE
      FLD_02
      FROM ZGTPPT1010
      WHERE MODULE_KIND EQ 'MM'
      AND CODEGRP EQ '0720'
      AND FLD_01 EQ @GS_DAY-WERKS
      INTO @GS_SCR-LGORT.

    SELECT SINGLE
      LGOBE
      FROM T001L
      WHERE WERKS EQ @GS_SCR-WERKS
      AND LGORT EQ @GS_SCR-LGORT
      INTO @GS_SCR-LGOBE.

    CALL SCREEN 101 STARTING AT 1 4.
    CHECK GS_SCR-ZOK EQ ABAP_TRUE.
  ENDIF.

  "POP UP TO CONFIRM
*입고처리 하시겠습니까? (예/아니오)"
  DATA LV_ANS TYPE C LENGTH 1.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT3 "확인
      TEXT_QUESTION = TEXT-Q04
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.

  CLEAR LV_CHECK.

  "BAPI 실행
  PERFORM F_RUN_GR_BAPI CHANGING LV_CHECK.

  "2026.07.07 BAPI 성공시에만 PO 할당수량 REFRESH
  IF LV_CHECK EQ GC_S.
    "드럼 실적/PO 설정
    PERFORM F_SET_ITEM_DATA_REFRESH_100 USING GS_DAY.
  ENDIF.

  PERFORM F_REFRESH_ALV USING GO_GRID_100_T.
  PERFORM F_REFRESH_ALV USING GO_GRID_100_M.
  PERFORM F_REFRESH_ALV USING GO_GRID_100_B.

  CHECK LV_CHECK EQ GC_S. "성공한 경우 메세지 처리
  MESSAGE S000 WITH TEXT-SM1.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_RUN_MBST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_RUN_MBST .

  DATA:
    LV_ROW_ID TYPE INT4,
    LV_CHECK  TYPE C LENGTH 1,
    LT_DUPL   TYPE TY_T_KEY_DAY.

  DATA LV_MESSAGE TYPE BAPI_MSG.

  FIELD-SYMBOLS <LS_DAY> TYPE TY_DAY.

  CALL METHOD GO_GRID_100_M->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID_100_B->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.
  "전표가 있는 경우
  CHECK GS_DAY-MBLNR IS NOT INITIAL OR GS_DAY-MBLNR_G IS NOT INITIAL.

  "POP UP TO CONFIRM
*입고취소 하시겠습니까? (예/아니오)"
  DATA LV_ANS TYPE C LENGTH 1.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT3 "확인
      TEXT_QUESTION = TEXT-Q05
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.

  CLEAR LV_CHECK.

  IF GS_DAY-MBLNR IS NOT INITIAL.
    CLEAR LV_MESSAGE.
    PERFORM F_MBST_DOC USING GS_DAY-MBLNR GS_DAY-MJAHR GS_DAY-ZDATE CHANGING LV_CHECK LV_MESSAGE.
    IF LV_CHECK EQ GC_E.
      MESSAGE I000 DISPLAY LIKE GC_E WITH LV_MESSAGE.
*      MESSAGE I000 DISPLAY LIKE GC_E WITH TEXT-ZZ1 GS_DAY-MBLNR GS_DAY-MJAHR . "자재문서 취소 오류
      EXIT.

    ELSE.
      GS_DAY-MBLNR = SPACE.

      "기존 PO 데이터 삭제
      DELETE FROM ZGTMMT4274
        WHERE BUKRS EQ @GS_DAY-BUKRS
        AND EKORG EQ @GS_DAY-EKORG
        AND WERKS EQ @GS_DAY-WERKS
        AND LIFNR EQ @GS_DAY-LIFNR
        AND ZDATE  EQ @GS_DAY-ZDATE.

      "전표번호 저장
      UPDATE ZGTMMT4271 SET
        MBLNR = @SPACE,
        AEDAT = @SY-DATUM,
        AEDAT_LOCAL = @SY-DATLO,
        AETIM = @SY-UZEIT,
        AETIM_LOCAL = @SY-TIMLO,
        AENAM = @SY-UNAME
        WHERE BUKRS EQ @GS_DAY-BUKRS
        AND EKORG EQ @GS_DAY-EKORG
        AND WERKS EQ @GS_DAY-WERKS
        AND LIFNR EQ @GS_DAY-LIFNR
        AND ZDATE  EQ @GS_DAY-ZDATE.

      COMMIT WORK.

      READ TABLE GT_DAY ASSIGNING <LS_DAY> WITH KEY ZDATE = GS_DAY-ZDATE.
      IF SY-SUBRC EQ 0.
        <LS_DAY>-MBLNR = SPACE.
      ENDIF.

    ENDIF.
  ENDIF.

  IF GS_DAY-MBLNR_G IS NOT INITIAL.
    CLEAR LV_MESSAGE.
    PERFORM F_MBST_DOC USING GS_DAY-MBLNR_G  GS_DAY-MJAHR GS_DAY-ZDATE CHANGING LV_CHECK LV_MESSAGE.
    IF LV_CHECK EQ GC_E.
      MESSAGE I000 DISPLAY LIKE GC_E WITH LV_MESSAGE.
*      MESSAGE I000 DISPLAY LIKE GC_E WITH TEXT-ZZ1 GS_DAY-MBLNR_G GS_DAY-MJAHR . "자재문서 취소 오류
      EXIT.
    ELSE.

      GS_DAY-MBLNR_G = SPACE.

      "전표번호 저장
      UPDATE ZGTMMT4271 SET
        MBLNR_G = @SPACE,
        AEDAT = @SY-DATUM,
        AEDAT_LOCAL = @SY-DATLO,
        AETIM = @SY-UZEIT,
        AETIM_LOCAL = @SY-TIMLO,
        AENAM = @SY-UNAME
        WHERE BUKRS EQ @GS_DAY-BUKRS
        AND EKORG EQ @GS_DAY-EKORG
        AND WERKS EQ @GS_DAY-WERKS
        AND LIFNR EQ @GS_DAY-LIFNR
        AND ZDATE  EQ @GS_DAY-ZDATE.

      COMMIT WORK.

      READ TABLE GT_DAY ASSIGNING <LS_DAY> WITH KEY ZDATE = GS_DAY-ZDATE.
      IF SY-SUBRC EQ 0.
        <LS_DAY>-MBLNR_G = SPACE.
      ENDIF.

    ENDIF.
  ENDIF.

  CHECK LV_CHECK NE GC_E.

* Header 설정
  "전표변호

  CHECK GS_DAY-MBLNR EQ SPACE AND GS_DAY-MBLNR_G EQ SPACE.
  GS_DAY-MJAHR = SPACE.
  GS_DAY-ZGR = SPACE.
  GS_DAY-STATUS = ICON_LED_GREEN.
  GS_DAY-ZSTAT = SPACE.
  GS_DAY-MESSAGE = SPACE.


  "데이터 점검
  PERFORM F_CHECK_VALUES_GT_DAY USING LT_DUPL CHANGING GS_DAY.

  "Style 설정
  PERFORM F_SET_ALV_STYLE_GT_DAY CHANGING GS_DAY.

  READ TABLE GT_DAY ASSIGNING <LS_DAY> WITH KEY ZDATE = GS_DAY-ZDATE.
  IF SY-SUBRC EQ 0.
    <LS_DAY> = GS_DAY.
  ENDIF.

  "기존 PO 데이터 삭제
  DELETE FROM ZGTMMT4274
    WHERE BUKRS EQ @GS_DAY-BUKRS
    AND EKORG EQ @GS_DAY-EKORG
    AND WERKS EQ @GS_DAY-WERKS
    AND LIFNR EQ @GS_DAY-LIFNR
    AND ZDATE  EQ @GS_DAY-ZDATE.

  "전표번호 저장
  UPDATE ZGTMMT4271 SET
    MJAHR  = @SPACE,
    MBLNR = @SPACE,
    MBLNR_G = @SPACE,
    AEDAT = @SY-DATUM,
    AEDAT_LOCAL = @SY-DATLO,
    AETIM = @SY-UZEIT,
    AETIM_LOCAL = @SY-TIMLO,
    AENAM = @SY-UNAME
    WHERE BUKRS EQ @GS_DAY-BUKRS
    AND EKORG EQ @GS_DAY-EKORG
    AND WERKS EQ @GS_DAY-WERKS
    AND LIFNR EQ @GS_DAY-LIFNR
    AND ZDATE  EQ @GS_DAY-ZDATE.
  COMMIT WORK.


  "드럼 실적/PO 설정
  PERFORM F_SET_ITEM_DATA_REFRESH_100 USING GS_DAY.

  PERFORM F_REFRESH_ALV USING GO_GRID_100_T.
  PERFORM F_REFRESH_ALV USING GO_GRID_100_M.
  PERFORM F_REFRESH_ALV USING GO_GRID_100_B.

  MESSAGE S000 WITH TEXT-SM2.

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

  DATA:
    LO_SPLIT  TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
    LO_CNTR_T TYPE REF TO CL_GUI_CONTAINER,
    LO_CNTR_M TYPE REF TO CL_GUI_CONTAINER,
    LO_CNTR_B TYPE REF TO CL_GUI_CONTAINER.

  GO_CONT_200 = NEW #( CONTAINER_NAME = 'CON200' ).

  "Split Container
  LO_SPLIT = NEW #( PARENT  = GO_CONT_200
                    ROWS    = 3
                    COLUMNS = 1 ).

  CALL METHOD LO_SPLIT->SET_ROW_HEIGHT( ID = 1 HEIGHT = 20 ).

  LO_CNTR_T = LO_SPLIT->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
  LO_CNTR_M = LO_SPLIT->GET_CONTAINER( ROW = 2 COLUMN = 1 ).
  LO_CNTR_B = LO_SPLIT->GET_CONTAINER( ROW = 3 COLUMN = 1 ).

  "ALV Obj.
  GO_GRID_200_T = NEW #( I_PARENT = LO_CNTR_T ).
  GO_GRID_200_M = NEW #( I_PARENT = LO_CNTR_M ).
  GO_GRID_200_B = NEW #( I_PARENT = LO_CNTR_B ).

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
   GT_EXCL_200_T[],
   GT_EXCL_200_M[],
   GT_EXCL_200_B[].

  GT_EXCL_200_T[] = GT_EXCL_200_M[] = GT_EXCL_200_B[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
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

  CLEAR:
    GS_LAYO_200_T,
    GS_LAYO_200_M,
    GS_LAYO_200_B.

  GS_LAYO_200_T-SEL_MODE = GC_A.
  GS_LAYO_200_T-ZEBRA = SPACE.
  GS_LAYO_200_T-SMALLTITLE = ABAP_TRUE.
  GS_LAYO_200_T-NO_ROWMOVE = ABAP_TRUE.
  GS_LAYO_200_T-NO_ROWINS = ABAP_TRUE.

  GS_LAYO_200_B = GS_LAYO_200_M = GS_LAYO_200_T.

  GS_LAYO_200_T-ZEBRA = ABAP_TRUE.

*"업체명(NAME1) && ' 드럼 실적'
*EX) 용남목재 드럼 실적"
  SELECT SINGLE
    NAME1
    FROM LFA1
    WHERE LIFNR EQ @P_LIFNR
    INTO @DATA(LV_NAME1).
  GS_LAYO_200_T-GRID_TITLE = |{ LV_NAME1 } { TEXT-AT1 }({ P_SPMON+0(4) }.{ P_SPMON+4(2) })|.

  GS_LAYO_200_M-GRID_TITLE = TEXT-AT4.
  GS_LAYO_200_B-GRID_TITLE = |{ TEXT-AT5 } { TEXT-AT6 } { TEXT-AT7 }|.

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
    GS_VARI_200_T,
    GS_VARI_200_M,
    GS_VARI_200_B.

  GS_VARI_200_T-REPORT = SY-REPID.
  GS_VARI_200_T-USERNAME = SY-UNAME.
  GS_VARI_200_T-HANDLE = 'ALM1'.

  GS_VARI_200_M-REPORT = SY-REPID.
  GS_VARI_200_M-USERNAME = SY-UNAME.
  GS_VARI_200_M-HANDLE = 'ALM2'.

  GS_VARI_200_B-REPORT = SY-REPID.
  GS_VARI_200_B-USERNAME = SY-UNAME.
  GS_VARI_200_B-HANDLE = 'ALM3'.

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

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_MON CHANGING GT_FCAT_200_T.
  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_SUM CHANGING GT_FCAT_200_M.
  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_LV CHANGING GT_FCAT_200_B.

  PERFORM F_ADJ_FCAT_200_T.
  PERFORM F_ADJ_FCAT_200_M.
  PERFORM F_ADJ_FCAT_200_B.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT_200_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_200_T .

  LOOP AT GT_FCAT_200_T ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'BUKRS'. ""회사코드
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'EKORG'. ""구매조직
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'LIFNR'. ""공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'SPMON'. ""작업 월
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'SDR_PRICE_SUM'. ""신드럼 입고(합)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H66 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 11.
        <LS_FCAT>-EMPHASIZE = 'C500'.
      WHEN 'GDR_PRICE_SUM'. ""고드럼 입고(합)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H67 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 11.
        <LS_FCAT>-EMPHASIZE = 'C500'.
      WHEN 'BOARD_PRICE_SUM'. ""골판지 조립(합)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H68 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 11.
        <LS_FCAT>-EMPHASIZE = 'C500'.
      WHEN 'MARK_PRICE_SUM'. ""신드럼 마킹(합)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H69 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 11.
        <LS_FCAT>-EMPHASIZE = 'C500'.
      WHEN 'DIS_PRICE_SUM'. ""고드럼 해체(합)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H92 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 11.
        <LS_FCAT>-EMPHASIZE = 'C500'.
      WHEN 'ADJUST'. ""조정 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H70 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 11.
        <LS_FCAT>-EMPHASIZE = 'C300'.
      WHEN 'WAERS'. ""통화 키
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H39 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'TEXT'. ""조정 사유
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H71 CHANGING <LS_FCAT>."
        <LS_FCAT>-INTLEN = <LS_FCAT>-OUTPUTLEN.
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

    "수정 가능
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ADJUST' OR 'TEXT'.
        <LS_FCAT>-EDIT = GV_EDIT.
    ENDCASE.

  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT_200_M
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_200_M .

  LOOP AT GT_FCAT_200_M ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'BUKRS'. ""회사코드
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'EKORG'. ""구매조직
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'LIFNR'. ""공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'SPMON'. ""작업 월
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'DRM_TYPE'. ""일반/특수
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 7.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'DRM_LV'. ""관리 레벨
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H72 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 7.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'SDR_COUNT'. ""신드럼 입고
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H73 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-EMPHASIZE = 'C300'.
      WHEN 'SDR_PRICE'. ""신드럼 입고 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H75 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'SDR_NETPR'. ""신드럼 입고 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H74 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'GDR_COUNT'. ""고드럼 입고(수리)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H76 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-EMPHASIZE = 'C300'.
      WHEN 'GDR_PRICE'. ""고드럼 입고 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H78 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'GDR_NETPR'. ""고드럼 입고 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H77 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'BOARD_COUNT'. ""골판지 조립
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H79 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-EMPHASIZE = 'C300'.
      WHEN 'BOARD_PRICE'. ""골판지 조립 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H81 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'BOARD_NETPR'. ""골판지 조립 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H80 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'MARK_N_COUNT'. ""일반 마킹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H82 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-EMPHASIZE = 'C300'.
      WHEN 'MARK_N_PRICE'. ""일반 마킹 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H84 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'MARK_N_NETPR'. ""일반 마킹 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H83 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'MARK_H_COUNT'. ""한전 마킹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H85 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-EMPHASIZE = 'C300'.
      WHEN 'MARK_H_PRICE'. ""한전 마킹 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H87 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'MARK_H_NETPR'. ""한전 마킹 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H86 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'DIS_COUNT'. ""고드럼 해체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H88 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-EMPHASIZE = 'C300'.
      WHEN 'DIS_NETPR'. ""고드럼 해체 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H89 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'DIS_PRICE'. ""고드럼 해체 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H90 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'MEINS'. ""기본 단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H91 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'WAERS'. ""통화키
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H39 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 5.

      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT_200_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_200_B .

  LOOP AT GT_FCAT_200_B ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'BUKRS'. ""회사코드
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'EKORG'. ""구매조직
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'LIFNR'. ""공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'SPMON'. ""작업 월
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 7.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'DRM_TYPE'. ""드럼 구분
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 7.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'DRM_LV'. ""관리 레벨
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H72 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 7.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'DRM_SG_TYPE'. ""신/고드럼 여부
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H17 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 7.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MATNR'. ""자재번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'MAKTX'. ""자재내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.

        <LS_FCAT>-OUTPUTLEN = 20.
      WHEN 'DRM_COUNT'. ""드럼 입고 실적
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X01 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'DRM_NETPR'. ""드럼 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X02 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'DRM_PRICE'. ""드럼 입고 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X03 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'BOARD_COUNT'. ""골판지 조립
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X04 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'BOARD_NETPR'. ""골판지 조립 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X05 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'BOARD_PRICE'. ""골판지 조립 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X06 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'MARK_N_COUNT'. ""일반 마킹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X07 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'MARK_N_NETPR'. ""일반 마킹 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X08 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'MARK_N_PRICE'. ""일반 마킹 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X09 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'MARK_H_COUNT'. ""한전 마킹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X10 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'MARK_H_NETPR'. ""한전 마킹 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X11 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'MARK_H_PRICE'. ""한전 마킹 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X12 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'DIS_COUNT'. ""고드럼 해체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X13 CHANGING <LS_FCAT>."
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'DIS_NETPR'. ""고드럼 해체 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X14 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'DIS_PRICE'. ""고드럼 해체 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X15 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-OUTPUTLEN = 13.
      WHEN 'WAERS'. ""통화키
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H91 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MEINS'. ""기본 단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H39 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-JUST = GC_C.

      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
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

  GO_GRID_200_T->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).


  CREATE OBJECT GCL_EVENT_200_M.

  SET HANDLER:
    GCL_EVENT_200_M->HANDLE_DOUBLE_CLICK FOR GO_GRID_200_M.

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

  CALL METHOD GO_GRID_200_T->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_200_T
      IT_TOOLBAR_EXCLUDING = GT_EXCL_200_T[]
      IS_VARIANT           = GS_VARI_200_T
      I_SAVE               = GV_ASAVE_200_T
    CHANGING
      IT_OUTTAB            = GT_MON[]
      IT_FIELDCATALOG      = GT_FCAT_200_T[]
      IT_SORT              = GT_SORT_200_T[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL METHOD GO_GRID_200_M->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_200_M
      IT_TOOLBAR_EXCLUDING = GT_EXCL_200_M[]
      IS_VARIANT           = GS_VARI_200_M
      I_SAVE               = GV_ASAVE_200_M
    CHANGING
      IT_OUTTAB            = GT_SUM[]
      IT_FIELDCATALOG      = GT_FCAT_200_M[]
      IT_SORT              = GT_SORT_200_M[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL METHOD GO_GRID_200_B->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_200_B
      IT_TOOLBAR_EXCLUDING = GT_EXCL_200_B[]
      IS_VARIANT           = GS_VARI_200_B
      I_SAVE               = GV_ASAVE_200_B
    CHANGING
      IT_OUTTAB            = GT_LV[]
      IT_FIELDCATALOG      = GT_FCAT_200_B[]
      IT_SORT              = GT_SORT_200_B[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DOUBLE_CLICK_200_M
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_ROW_NO_ROW_ID
*&---------------------------------------------------------------------*
FORM F_DOUBLE_CLICK_200_M  USING  PV_ROW_ID.

  CHECK PV_ROW_ID GT 0.

  READ TABLE GT_SUM ASSIGNING FIELD-SYMBOL(<LS_SUM>) INDEX  PV_ROW_ID.
  CHECK SY-SUBRC EQ 0.

*4-2) 더블클릭 기능 (LV에 해당하는 드럼별 실적 조회)
*	SELECT 결과를 GT_LV에 할당
  CLEAR GT_LV[].

  SELECT
    *
    FROM ZGTMM_CV_DRUM_RESULT_LV AS V1
    WHERE V1~BUKRS EQ @<LS_SUM>-BUKRS
    AND V1~WERKS EQ @<LS_SUM>-WERKS
    AND V1~LIFNR EQ @<LS_SUM>-LIFNR
    AND V1~SPMON EQ @<LS_SUM>-SPMON
    AND V1~DRM_LV EQ @<LS_SUM>-DRM_LV
    AND V1~DRM_TYPE EQ @<LS_SUM>-DRM_TYPE "2026.07.09 조회조건 누락 수정
    INTO CORRESPONDING FIELDS OF TABLE @GT_LV.

  PERFORM F_REFRESH_ALV USING GO_GRID_200_B.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CREATE_ALV_OBJECT_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE_ALV_OBJECT_300 .

  GO_CONT_300 = NEW #( CONTAINER_NAME = 'CON300' ).
  GO_GRID_300 = NEW #( I_PARENT = GO_CONT_300 ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_EXCL_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_EXCL_300 .

  CLEAR:
   GT_EXCL_300[].

  GT_EXCL_300[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
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
*& Form F_SET_LAYO_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_LAYO_300 .

  CLEAR:
    GS_LAYO_300.
  GS_LAYO_300-SEL_MODE = GC_A.
  GS_LAYO_300-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO_300-ZEBRA = ABAP_TRUE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_VARI_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_VARI_300 .

  CLEAR:
    GS_VARI_300.

  GS_VARI_300-REPORT = SY-REPID.
  GS_VARI_300-USERNAME = SY-UNAME.
  GS_VARI_300-HANDLE = 'ALV1'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_FCAT_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_FCAT_300 .

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_DISP CHANGING GT_FCAT_300.
  PERFORM F_ADJ_FCAT_300.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_300 .

  LOOP AT GT_FCAT_300 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'BUKRS'. ""회사코드
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'EKORG'. ""구매조직
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'LIFNR'. ""공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'SPMON'. ""작업 월
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'ZDATE'. ""작업 일자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MATNR'. ""자재번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MAKTX'. ""자재내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'DRM_TYPE'. ""일반/특수
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."
        <LS_FCAT>-EMPHASIZE = 'C500'.
      WHEN 'DRM_GUBUN'. ""드럼구분
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X16 CHANGING <LS_FCAT>."
        <LS_FCAT>-EMPHASIZE = 'C500'.
      WHEN 'DRM_LV'. ""관리레벨
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H72 CHANGING <LS_FCAT>."
        <LS_FCAT>-EMPHASIZE = 'C500'.
      WHEN 'DRM_SIZE'. ""드럼규격
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X17 CHANGING <LS_FCAT>."
        <LS_FCAT>-EMPHASIZE = 'C500'.
      WHEN 'DRM_SG_TYPE'. ""신/고드럼
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H17 CHANGING <LS_FCAT>."
        <LS_FCAT>-EMPHASIZE = 'C500'.
      WHEN 'DRM_COUNT'. ""드럼 입고 실적
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X18 CHANGING <LS_FCAT>."
        <LS_FCAT>-EMPHASIZE = 'C300'.
      WHEN 'DRM_NETPR'. ""드럼 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X19 CHANGING <LS_FCAT>."
      WHEN 'DRM_PRICE'. ""드럼 입고 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X20 CHANGING <LS_FCAT>."
      WHEN 'BOARD_COUNT'. ""골판지 조립 실적
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X21 CHANGING <LS_FCAT>."
        <LS_FCAT>-EMPHASIZE = 'C300'.
      WHEN 'BOARD_NETPR'. ""골판지 조립 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X22 CHANGING <LS_FCAT>."
      WHEN 'BOARD_PRICE'. ""골판지 조립 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X23 CHANGING <LS_FCAT>."
      WHEN 'MARK_COUNT'. ""마킹(합계) 실적
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X24 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-EMPHASIZE = 'C300'.
      WHEN 'MARK_NETPR'. ""마킹(합계) 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X25 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MARK_PRICE'. ""마킹(합계) 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X26 CHANGING <LS_FCAT>."
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MARK_N_COUNT'. ""기본 마킹 실적
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X27 CHANGING <LS_FCAT>."
        <LS_FCAT>-EMPHASIZE = 'C300'.
      WHEN 'MARK_N_NETPR'. ""기본 마킹 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X28 CHANGING <LS_FCAT>."
      WHEN 'MARK_N_PRICE'. ""기본 마킹 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X29 CHANGING <LS_FCAT>."
      WHEN 'MARK_H_COUNT'. ""한전 마킹 실적
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X30 CHANGING <LS_FCAT>."
        <LS_FCAT>-EMPHASIZE = 'C300'.
      WHEN 'MARK_H_NETPR'. ""한전 마킹 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X31 CHANGING <LS_FCAT>."
      WHEN 'MARK_H_PRICE'. ""한전 마킹 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X32 CHANGING <LS_FCAT>."
      WHEN 'DIS_COUNT'. ""고드럼 해체 실적
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X33 CHANGING <LS_FCAT>."
        <LS_FCAT>-EMPHASIZE = 'C300'.
      WHEN 'DIS_NETPR'. ""고드럼 해체 단가
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X34 CHANGING <LS_FCAT>."
      WHEN 'DIS_PRICE'. ""고드럼 해체 금액
        PERFORM F_SET_FCAT_COLTXT USING TEXT-X35 CHANGING <LS_FCAT>."
      WHEN 'WAERS'. ""통화키
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H91 CHANGING <LS_FCAT>."
      WHEN 'MEINS'. ""기본 단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H39 CHANGING <LS_FCAT>."

      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.


    CASE <LS_FCAT>-DATATYPE.
      WHEN 'QUAN'.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'CURR'.
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
    ENDCASE.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DISPLAY_ALV_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DISPLAY_ALV_300 .

  CALL METHOD GO_GRID_300->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_300
      IT_TOOLBAR_EXCLUDING = GT_EXCL_300[]
      IS_VARIANT           = GS_VARI_300
      I_SAVE               = GV_ASAVE_300
    CHANGING
      IT_OUTTAB            = GT_DISP[]
      IT_FIELDCATALOG      = GT_FCAT_300[]
      IT_SORT              = GT_SORT_300[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
