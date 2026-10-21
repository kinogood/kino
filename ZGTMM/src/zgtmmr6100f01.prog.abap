*&---------------------------------------------------------------------*
*& Include          ZGTSDI0001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INITIALIZATION .
  P_WERKS = GC_WERKS.
  P_VDATU = SY-DATLO.
  GV_EDIT = GC_X.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_SCREEN .

  LOOP AT SCREEN.
    CASE SCREEN-GROUP1.

      WHEN 'M1'.
        SCREEN-INPUT = 0.
    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_INPUT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_INPUT_DATA .

  CLEAR GV_ERROR.

  "기본 필수입력 필드 체크
  IF P_WERKS IS INITIAL.
    MESSAGE S008 WITH %_P_WERKS_%_APP_%-TEXT DISPLAY LIKE GC_E.
    GV_ERROR = GC_X.
    RETURN.
  ENDIF.

  IF S_MATNR[] IS INITIAL. "
    MESSAGE S008 WITH %_S_MATNR_%_APP_%-TEXT DISPLAY LIKE GC_E.
    GV_ERROR = GC_X.
    RETURN.
  ENDIF.

  IF P_VDATU IS INITIAL.
    "Pgm.ZGTMMR6200에서 호출시 메세지 Text 변경(PSJ 25.03.18)
    DATA : LV_TXT(10).
    LV_TXT = SWITCH #( P_CALLD WHEN 'X' THEN '납품일자'(P01)
                                        ELSE %_P_VDATU_%_APP_%-TEXT ).

    MESSAGE S008 WITH LV_TXT DISPLAY LIKE GC_E.
    GV_ERROR = GC_X.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM AUTHORITY_CHECK .

*  "권한 체크
*  ZGTSD_CL_COMMON=>AUTHORITY_CHECK( EXPORTING IV_OBJECT     = 'VKO'
*                                              IV_AUTH_FIELD = CONV XUFIELD( |VKORG| )
*                                              IV_AUTH_VAL   = CONV XUVAL( P_VKORG )
*                                    IMPORTING EV_MTYPE      = DATA(LV_MTYPE)
*                                              EV_MSGTX      = DATA(LV_MSGTX) ).
*  IF LV_MTYPE = GC_E.
*    MESSAGE S001(00) WITH LV_MSGTX DISPLAY LIKE GC_E.
*    LEAVE LIST-PROCESSING.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_QUERY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DATA_QUERY .

  CLEAR GV_ERROR. __CLE : GT_S0100, GT_CHG, GR_MATNR, GR_LIFNR.

  GR_MATNR[] = S_MATNR[].
  GR_LIFNR[] = S_LIFNR[].

  SELECT A~*, NAME1, MAKTX INTO CORRESPONDING FIELDS OF TABLE @GT_S0100
    FROM EORD AS A LEFT OUTER JOIN LFA1 AS B
      ON A~LIFNR = B~LIFNR
    LEFT OUTER JOIN MAKT AS C
      ON A~MATNR = C~MATNR
     AND C~SPRAS = @SY-LANGU
   WHERE A~WERKS = @P_WERKS
     AND A~MATNR IN @S_MATNR
     AND A~LIFNR IN @S_LIFNR
     AND A~VDATU <= @P_VDATU
     AND A~BDATU >= @P_VDATU.

  LOOP AT GT_S0100 INTO GS_S0100.
    GS_S0100-STATU = ICON_LED_YELLOW.
    MODIFY GT_S0100 FROM GS_S0100.
  ENDLOOP.

**********************************************************************
  "데이타 건수 메시지 출력
  IF GT_S0100 IS NOT INITIAL.
    MESSAGE S003 WITH |{ LINES( GT_S0100 ) NUMBER = USER }|. "& 건 검색되었습니다.
  ELSE.
    MESSAGE S002.                                           "조회할 데이타가 없습니다.
    GV_ERROR = GC_X.                                        "데이타 없으면 출력 X
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_ALV_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GO_CON
*&      <-- GO_GRID
*&---------------------------------------------------------------------*
FORM INIT_ALV_0100  CHANGING PO_DCON TYPE REF TO CL_GUI_DOCKING_CONTAINER
                             PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  "Create Main Container
  PERFORM CREATE_DOC_CONTAINER CHANGING PO_DCON.

  "Split
  GO_SPLIT = NEW #( PARENT = PO_DCON ROWS = 2 COLUMNS = 1 ).

  GO_CON_TOP       = GO_SPLIT->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
  DATA(LO_CON_BTT) = GO_SPLIT->GET_CONTAINER( ROW = 2 COLUMN = 1 ).

  GO_SPLIT->SET_ROW_HEIGHT( ID = 1 HEIGHT = 10 ).

  "Create Object
  GO_DOCU = NEW #( STYLE = 'ALV_GRID' ).  "Top-Of-Page

  PERFORM CREATE_ALV USING    LO_CON_BTT
                     CHANGING PO_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_DOC_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CREATE_DOC_CONTAINER CHANGING PO_DCON TYPE REF TO CL_GUI_DOCKING_CONTAINER.

  CREATE OBJECT PO_DCON
    EXPORTING
      PARENT                      = CL_GUI_CONTAINER=>DEFAULT_SCREEN
      REPID                       = SY-REPID
      DYNNR                       = SY-DYNNR
      SIDE                        = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
      EXTENSION                   = 3000
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5
      OTHERS                      = 6.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CREATE_ALV CHANGING PO_CON
                         PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  CREATE OBJECT PO_GRID
    EXPORTING
      I_PARENT          = PO_CON
    EXCEPTIONS
      ERROR_CNTL_CREATE = 1
      ERROR_CNTL_INIT   = 2
      ERROR_CNTL_LINK   = 3
      ERROR_DP_CREATE   = 4
      OTHERS            = 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ATTRIBUTES_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_ATTRIBUTES_0100 .

  "Layout 지정
  PERFORM SET_GRID_LAYOUT USING GC_X SPACE ZGTSD_D.

  "Field Catalog
  PERFORM SET_FIELDCATALOG.

  "Toolbar 제외
  PERFORM EXCLUDE_TOOLBAR TABLES GT_TOOLBAR.

  "Event Handler 등록
  PERFORM CREATE_EVENT_RECEIVER USING GO_GRID.

  "F4 필드 등록
  PERFORM REGISTER_F4_FIELDS.

  "SORT
  PERFORM SET_ALV_SORT CHANGING GT_SORT.

  "Top-Of-Page Event 등록
  PERFORM SET_TOP_OF_PAGE_EVENT.

  "ALV Grid Display
  PERFORM SET_TABLE_FOR_FIRST_DISPLAY USING GO_GRID
                                            GT_S0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_GRID_LAYOUT USING PV_CWOPT
                           PV_STYLEFNAME
                           PV_SEL_MODE.

  CLEAR GS_LAYOUT.
  GS_LAYOUT = VALUE #( SEL_MODE   = PV_SEL_MODE
                       ZEBRA      = GC_X
                       CWIDTH_OPT = PV_CWOPT
                       STYLEFNAME = PV_STYLEFNAME ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_FIELDCATALOG .

  "Get Field Catalog
  PERFORM GET_FIELD_CATALOG USING GT_S0100 CHANGING GT_FCAT.

  "Set Field Catalog
  PERFORM SET_FIELDCATALOG_MAIN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_FIELD_CATALOG USING PT_TABLE TYPE TABLE
                    CHANGING PT_FCAT TYPE LVC_T_FCAT.

  REFRESH PT_FCAT.

  PT_FCAT = ZGTSD_CL_COMMON=>GET_FIELD_CATALOG( IT_TABLE = PT_TABLE
                                                IV_CELLS = GC_X
                                                IV_CELLC = GC_X ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG_MAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCATALOG_MAIN .


  SORT GT_FCAT BY FIELDNAME.

  PERFORM RESET_FIELD_CATALOG TABLES GT_FCAT USING :
      'S' 'FIELDNAME'   'STATU',
      ' ' 'COLTEXT'     TEXT-F01,
      ' ' 'ICON'        'X',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'WERKS',
      ' ' 'COLTEXT'     TEXT-F02,
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'MATNR',
      ' ' 'COLTEXT'     TEXT-F03,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'MAKTX',
      ' ' 'COLTEXT'     TEXT-F04,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'ZEORD',
      ' ' 'COLTEXT'     TEXT-F05,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'FLIFN',
      ' ' 'COLTEXT'     TEXT-F06,
      ' ' 'CHECKBOX'    'X',
      ' ' 'EDIT'        'X',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'LIFNR',
      ' ' 'COLTEXT'     TEXT-F07,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'NAME1',
      ' ' 'COLTEXT'     TEXT-F08,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'VDATU',
      ' ' 'COLTEXT'     TEXT-F09,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'BDATU',
      ' ' 'COLTEXT'     TEXT-F10,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'EKORG',
      ' ' 'COLTEXT'     TEXT-F11,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'NOTKZ',
      ' ' 'COLTEXT'     TEXT-F12,
      ' ' 'CHECKBOX'    'X',
      ' ' 'EDIT'        'X',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'AUTET',
      ' ' 'COLTEXT'     TEXT-F13,
      ' ' 'EDIT'        'X',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'EBELN',
      ' ' 'COLTEXT'     TEXT-F14,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'EBELP',
      ' ' 'COLTEXT'     TEXT-F15,
      'E' 'OUTPUTLEN'   '10'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM RESET_FIELD_CATALOG TABLES PT_FCAT TYPE LVC_T_FCAT
                         USING  PV_FLAG
                                PV_FNAME
                                PV_VALUE.

  STATICS : LS_FCAT   TYPE LVC_S_FCAT,
            LV_COLPOS TYPE LVC_COLPOS,
            LV_TABIX  TYPE SYTABIX.

  IF PV_FLAG = 'S'.  "Start
    CLEAR LS_FCAT.
    READ TABLE PT_FCAT INTO LS_FCAT WITH KEY FIELDNAME = PV_VALUE BINARY SEARCH.
    CHECK SY-SUBRC = 0.
    LV_TABIX = SY-TABIX.

    LV_COLPOS = LV_COLPOS + 1.

    LS_FCAT-TECH    = SPACE.
    LS_FCAT-COL_POS = LV_COLPOS.
  ENDIF.

  CASE PV_FNAME.
    WHEN 'COLTEXT'.   "Text
      LS_FCAT-COLTEXT  = PV_VALUE.
      LS_FCAT-REPTEXT  = PV_VALUE.
      LS_FCAT-SELTEXT  = PV_VALUE.
      LS_FCAT-TOOLTIP  = PV_VALUE.
    WHEN OTHERS.
      ASSIGN COMPONENT PV_FNAME OF STRUCTURE LS_FCAT TO FIELD-SYMBOL(<LV_VALUE>).
      CHECK SY-SUBRC = 0.
      <LV_VALUE> = PV_VALUE.
  ENDCASE.

  IF PV_FLAG = GC_E.  "End
    MODIFY PT_FCAT FROM LS_FCAT INDEX LV_TABIX.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*----------------------------------------------------------------------*
FORM EXCLUDE_TOOLBAR TABLES PT_EXCLUDE TYPE UI_FUNCTIONS.

  REFRESH PT_EXCLUDE.

  APPEND : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO            TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_DATA_SAVE           TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_LOC_COPY            TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW        TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_LOC_CUT             TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW      TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW      TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW        TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW      TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE           TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW   TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_REFRESH             TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_CHECK               TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_PRINT               TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_VIEWS               TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_GRAPH               TO PT_EXCLUDE,
           CL_GUI_ALV_GRID=>MC_FC_INFO                TO PT_EXCLUDE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_EVENT_RECEIVER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CREATE_EVENT_RECEIVER USING PO_SENDER TYPE REF TO CL_GUI_ALV_GRID.

  "Create Event
  DATA(LO_EVENT) = NEW LCL_EVENT_RECEIVER( ).

  CASE PO_SENDER.
    WHEN GO_GRID.
      SET HANDLER : LO_EVENT->HANDLE_TOP_OF_PAGE FOR PO_SENDER.
  ENDCASE.

  SET HANDLER : LO_EVENT->HANDLE_HOTSPOT_CLICK         FOR PO_SENDER,
                LO_EVENT->HANDLE_DATA_CHANGED          FOR PO_SENDER,
                LO_EVENT->HANDLE_DBL_CLICK             FOR PO_SENDER.
*                LO_EVENT->HANDLE_TOOLBAR               FOR PO_SENDER,
*                LO_EVENT->HANDLE_USER_COMMAND          FOR PO_SENDER,
*                LO_EVENT->HANDLE_ON_F4                 FOR PO_SENDER.
*               LO_EVENT->HANDLE_DATA_CHANGED_FINISHED FOR PO_SENDER.

*  "Data Changed Event
  PO_SENDER->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
  PO_SENDER->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_ENTER ).

*  "Set Ready for Input
  PO_SENDER->SET_READY_FOR_INPUT( SWITCH #( GV_EDIT WHEN GC_X THEN 1 ELSE 0 ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REGISTER_F4_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM REGISTER_F4_FIELDS .

  DATA : LT_F4   TYPE LVC_T_F4,
         LT_FCAT TYPE TABLE OF LVC_S_FCAT
                 WITH NON-UNIQUE SORTED KEY KEY_MODE
                 COMPONENTS F4AVAILABL FIELDNAME.

  LT_FCAT = GT_FCAT.
  LOOP AT LT_FCAT INTO DATA(LS_FCAT) USING KEY KEY_MODE
                  WHERE F4AVAILABL = GC_X.
    LT_F4 = VALUE #( BASE LT_F4 ( FIELDNAME  = LS_FCAT-FIELDNAME
                                  REGISTER   = GC_X
                                  CHNGEAFTER = GC_X ) ).
  ENDLOOP.

  GO_GRID->REGISTER_F4_FOR_FIELDS( EXPORTING IT_F4 = LT_F4 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TOP_OF_PAGE_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_TOP_OF_PAGE_EVENT .

  CHECK GO_DOCU IS BOUND.

  GO_DOCU->INITIALIZE_DOCUMENT( BACKGROUND_COLOR = CL_DD_AREA=>COL_TEXTAREA ).

  CALL METHOD GO_GRID->LIST_PROCESSING_EVENTS(
      I_EVENT_NAME = SLIS_EV_TOP_OF_PAGE
      I_DYNDOC_ID  = GO_DOCU ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_TABLE_FOR_FIRST_DISPLAY USING PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                                       PT_DATA TYPE TABLE.
  DATA : LV_HANDL TYPE SLIS_HANDL.

  "레이아웃 Variant 구분자
  PERFORM SET_VARIANT_HANDLE USING PO_SENDER CHANGING LV_HANDL.

  DELETE GT_FCAT WHERE TECH = GC_X. "불필요한 필드 제외

  "Formatted Output Table is Sent to Control
  CALL METHOD PO_SENDER->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT
      IS_VARIANT           = VALUE #( REPORT = SY-REPID
                                      HANDLE = LV_HANDL )
      I_SAVE               = 'A'
      IT_TOOLBAR_EXCLUDING = GT_TOOLBAR
    CHANGING
      IT_FIELDCATALOG      = GT_FCAT
      IT_SORT              = GT_SORT[]
      IT_OUTTAB            = PT_DATA[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT_HANDLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_VARIANT_HANDLE USING PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                         CHANGING PV_HANDL.

  CLEAR PV_HANDL.
  CASE PO_SENDER.
    WHEN GO_GRID. "Main
      PV_HANDL = 1.
    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DBL_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM HANDLE_DBL_CLICK  USING    PV_ROW     TYPE LVC_S_ROW
                                PV_COLUMN  TYPE LVC_S_COL.

  CHECK PV_ROW-ROWTYPE EQ SPACE.
  READ TABLE GT_S0100 INTO GS_S0100 INDEX PV_ROW-INDEX.
  CHECK SY-SUBRC = 0 .

  CASE PV_COLUMN.
    WHEN 'MATNR'.
      CHECK GS_S0100-MATNR IS NOT INITIAL.
      SET PARAMETER ID: 'MAT' FIELD   GS_S0100-MATNR.
      CALL TRANSACTION  'MM03' AND SKIP FIRST SCREEN.

*  	WHEN .
    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_SORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_SORT
*&---------------------------------------------------------------------*
FORM SET_ALV_SORT  CHANGING PT_SORT TYPE LVC_T_SORT.

  CLEAR : PT_SORT[].

  PERFORM SET_SORT_FIELD USING: PT_SORT 'WERKS' GC_X '' '',
                                PT_SORT 'MATNR' GC_X '' '',
                                PT_SORT 'ZEORD' GC_X '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_SORT
*&      --> P_
*&      --> GC_X
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_SORT_FIELD  USING PT_SORT TYPE LVC_T_SORT
                           PV_FLDNAME
                           PV_UP
                           PV_DOWN
                           PV_SUBTOT.

  APPEND VALUE #( SPOS      = LINES( PT_SORT ) + 1
                  FIELDNAME = PV_FLDNAME
                  UP        = PV_UP
                  DOWN      = PV_DOWN
                  SUBTOT    = PV_SUBTOT ) TO PT_SORT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_TOP_OF_PAGE USING PO_DOCU TYPE REF TO CL_DD_DOCUMENT
                                  PO_SENDER.
  DATA : LV_TEXT TYPE SDYDO_TEXT_ELEMENT.

  CHECK PO_SENDER = GO_GRID "Main
    AND PO_DOCU IS BOUND.

  "Set Column Width
  PO_DOCU->ADD_TABLE( EXPORTING NO_OF_COLUMNS = 3 BORDER = '0' IMPORTING TABLE = DATA(LO_TABLE) ).

  LO_TABLE->ADD_COLUMN( EXPORTING WIDTH = '30%' IMPORTING COLUMN = DATA(LO_COL_KEY) ).
  LO_TABLE->ADD_COLUMN( EXPORTING WIDTH = '3%' IMPORTING COLUMN = DATA(LO_COL_SEP) ).
  LO_TABLE->ADD_COLUMN( EXPORTING WIDTH = '67%' IMPORTING COLUMN = DATA(LO_COL_VAL) ).
  LO_TABLE->NEW_ROW( ).

  "Set Column Style
  LO_TABLE->SET_COLUMN_STYLE( COL_NO = 1 SAP_EMPHASIS = CL_DD_DOCUMENT=>STRONG SAP_ALIGN = 'LEFT' ).
  LO_TABLE->SET_COLUMN_STYLE( COL_NO = 3 SAP_EMPHASIS = CL_DD_DOCUMENT=>MEDIUM SAP_ALIGN = 'LEFT' ).

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
                                'P' %_P_WERKS_%_APP_%-TEXT P_WERKS.

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
                                'S' %_S_MATNR_%_APP_%-TEXT 'GR_MATNR[]'.

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
                                'S' %_S_LIFNR_%_APP_%-TEXT 'GR_LIFNR[]'.

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
                                'P' %_P_VDATU_%_APP_%-TEXT P_VDATU.

  "Display Document
  PO_DOCU->MERGE_DOCUMENT( ).
  PO_DOCU->DISPLAY_DOCUMENT( EXPORTING
                               REUSE_CONTROL      = GC_X
                               PARENT             = GO_CON_TOP
                             EXCEPTIONS
                               HTML_DISPLAY_ERROR = 1 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_TEXT_COMMON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM ADD_TEXT_COMMON USING PO_COL_KEY TYPE REF TO CL_DD_AREA
                               PO_COL_SEP TYPE REF TO CL_DD_AREA
                               PO_COL_VAL TYPE REF TO CL_DD_AREA
                               PO_TABLE   TYPE REF TO CL_DD_TABLE_ELEMENT
                               PV_FLAG
                               PV_KEY
                               PV_VALUE.
  FIELD-SYMBOLS : <LT_SELOPT> TYPE TABLE.
  DATA LV_TEXT TYPE CHAR255.

  CASE PV_FLAG.
    WHEN 'P'. "Parameter
      CHECK PV_VALUE IS NOT INITIAL.
      LV_TEXT = CONV SDYDO_TEXT_ELEMENT( PV_VALUE ).
    WHEN 'S'. "Select-Option
      ASSIGN (PV_VALUE) TO <LT_SELOPT>.
      CHECK SY-SUBRC = 0.

      CHECK LINES( <LT_SELOPT> ) => 1.

      ASSIGN COMPONENT 'LOW' OF STRUCTURE <LT_SELOPT>[ 1 ] TO FIELD-SYMBOL(<LV_LOW>).
      CHECK SY-SUBRC = 0.
      CASE PV_VALUE.
        WHEN 'GR_MATNR[]' OR 'GR_LIFNR[]'.
          __ALPHA_OU <LV_LOW> <LV_LOW>.
      ENDCASE.

      ASSIGN COMPONENT 'HIGH' OF STRUCTURE <LT_SELOPT>[ 1 ] TO FIELD-SYMBOL(<LV_HIGH>).
      CHECK SY-SUBRC = 0.
      CASE PV_VALUE.
        WHEN 'GR_MATNR[]' OR 'GR_LIFNR[]'.
          __ALPHA_OU <LV_HIGH> <LV_HIGH>.
      ENDCASE.

      IF <LV_HIGH> IS INITIAL.
        LV_TEXT = <LV_LOW>.
      ELSEIF <LV_LOW> IS INITIAL.
        LV_TEXT = `~ ` &&  <LV_LOW>.
      ELSE.
        LV_TEXT = <LV_LOW> && ` ~ ` &&  <LV_HIGH>.
      ENDIF.
  ENDCASE.

  PO_COL_KEY->ADD_TEXT( TEXT = CONV SDYDO_TEXT_ELEMENT( PV_KEY ) ).
  PO_COL_SEP->ADD_TEXT( TEXT = CONV SDYDO_TEXT_ELEMENT( ':' ) ).
  PO_COL_VAL->ADD_TEXT( TEXT = LV_TEXT ).

  PO_TABLE->NEW_ROW( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK USING PS_COLUMN TYPE LVC_S_COL
                                PS_ROW_NO TYPE LVC_S_ROID
                                PO_SENDER.

  CHECK PO_SENDER = GO_GRID. "Main

  CASE PS_COLUMN-FIELDNAME.

    WHEN 'STATU'. "메세지

      READ TABLE GT_S0100 INTO DATA(LS_MAIN) INDEX PS_ROW_NO-ROW_ID.
      CHECK SY-SUBRC = 0.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED USING PO_DATA_CHANGED TYPE REF TO
                                 CL_ALV_CHANGED_DATA_PROTOCOL
                                 PO_SENDER.

  CHECK PO_SENDER = GO_GRID.  "Main

  DATA(LT_MOD_CELLS) = PO_DATA_CHANGED->MT_GOOD_CELLS.
  SORT LT_MOD_CELLS BY ROW_ID FIELDNAME.

  REFRESH GT_CHG.

  LOOP AT LT_MOD_CELLS INTO DATA(LS_MOD_TEMP).

    DATA(LS_MOD_CELLS) = LS_MOD_TEMP.

    AT NEW ROW_ID.
      READ TABLE GT_S0100 INTO DATA(LS_MAIN) INDEX LS_MOD_CELLS-ROW_ID.
      CHECK SY-SUBRC = 0.
    ENDAT.

    "체크사항 점검 및 Set Value
    PERFORM CHECK_VALUE_IN_DATACHD USING    PO_DATA_CHANGED
                                            LS_MOD_CELLS
                                   CHANGING LS_MAIN.

    AT END OF ROW_ID.
      "변경상태 Update
      PERFORM UPDATE_STATU USING    PO_DATA_CHANGED
                                    LS_MOD_CELLS
                           CHANGING LS_MAIN-STATU
                                    LS_MAIN-MODI.
      MODIFY GT_S0100 FROM LS_MAIN INDEX LS_MOD_CELLS-ROW_ID.
      APPEND CORRESPONDING #( LS_MAIN ) TO GT_CHG.
    ENDAT.

  ENDLOOP.

  "Display Protocol
  PO_DATA_CHANGED->DISPLAY_PROTOCOL( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_VALUE_IN_DATACHD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_VALUE_IN_DATACHD USING PO_DATA_CHANGED TYPE REF TO
                                      CL_ALV_CHANGED_DATA_PROTOCOL
                                      PS_MOD_CELLS TYPE LVC_S_MODI
                            CHANGING PS_DATA STRUCTURE GS_S0100.

  CASE PS_MOD_CELLS-FIELDNAME.
    WHEN 'FLIFN'. "고정
      PERFORM CHECK_DATACHD_FLIFN USING PO_DATA_CHANGED
                                        PS_MOD_CELLS
                               CHANGING PS_DATA.

    WHEN 'NOTKZ'. "보류
      PERFORM CHECK_DATACHD_NOTKZ USING PO_DATA_CHANGED
                                        PS_MOD_CELLS
                               CHANGING PS_DATA.
    WHEN 'AUTET'. "MRP
    WHEN OTHERS.
      ASSIGN COMPONENT PS_MOD_CELLS-FIELDNAME OF STRUCTURE PS_DATA TO FIELD-SYMBOL(<LV_VALUE>).
      CHECK SY-SUBRC = 0.
      <LV_VALUE> = PS_MOD_CELLS-VALUE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CHANGED_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_CHANGED_DATA USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID
                              PV_CK.

  CLEAR GV_ERROR.
  CHECK PO_GRID IS BOUND.

  PO_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = DATA(LV_VALID) ).

  IF PV_CK = GC_X AND LV_VALID IS INITIAL.
    GV_ERROR = GC_X. "오류 Flag
    MESSAGE S029 DISPLAY LIKE GC_E. "오류 내역이 존재합니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_STATU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM UPDATE_STATU USING PO_DATA_CHANGED TYPE REF TO
                            CL_ALV_CHANGED_DATA_PROTOCOL
                            PS_MOD_CELLS TYPE LVC_S_MODI
                   CHANGING PV_STATU
                            PV_MODI.

  PV_MODI  = GC_X.     "변경 Flag
  PV_STATU = ICON_CHANGE. "변경 Icon

  PERFORM MODIFY_CELL USING PO_DATA_CHANGED
                            PS_MOD_CELLS-ROW_ID
                            PS_MOD_CELLS-TABIX
                            'STATU'
                            PV_STATU.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CELL_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_CELL_VALUE USING PO_DATA_CHANGED TYPE REF TO
                              CL_ALV_CHANGED_DATA_PROTOCOL
                              PV_ROW_ID
                              PV_FIELDNAME
                     CHANGING PV_VALUE.

  CLEAR PV_VALUE.
  PO_DATA_CHANGED->GET_CELL_VALUE( EXPORTING
                                     I_ROW_ID    = PV_ROW_ID
                                     I_FIELDNAME = PV_FIELDNAME
                                   IMPORTING
                                     E_VALUE     = PV_VALUE ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_PROTOCOL_ENTRY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM ADD_PROTOCOL_ENTRY USING PO_DATA_CHANGED TYPE REF TO
                                CL_ALV_CHANGED_DATA_PROTOCOL
                                PV_MSGID
                                PV_MSGNO
                                PV_MSGV1
                                PV_MSGV2
                                PV_FIELDNAME
                                PV_ROW_ID.

  DATA : LT_DATA TYPE TABLE OF LVC_S_MSG1
                 WITH NON-UNIQUE SORTED KEY KEY_MODE
                 COMPONENTS MSGID MSGNO MSGV1 MSGV2 FIELDNAME ROW_ID.

  LT_DATA = PO_DATA_CHANGED->MT_PROTOCOL.  "기존 동일 오류 제외

  CHECK NOT LINE_EXISTS( LT_DATA[ KEY KEY_MODE COMPONENTS MSGID     = PV_MSGID
                                                          MSGNO     = PV_MSGNO
                                                          MSGV1     = PV_MSGV1
                                                          MSGV2     = PV_MSGV2
                                                          FIELDNAME = PV_FIELDNAME
                                                          ROW_ID    = PV_ROW_ID ] ).

  PO_DATA_CHANGED->ADD_PROTOCOL_ENTRY(
      EXPORTING
        I_MSGID     = PV_MSGID
        I_MSGNO     = PV_MSGNO
        I_MSGTY     = GC_E
        I_MSGV1     = PV_MSGV1
        I_MSGV2     = PV_MSGV2
        I_FIELDNAME = PV_FIELDNAME
        I_ROW_ID    = PV_ROW_ID ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_CELL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_CELL USING PO_DATA_CHANGED TYPE REF TO
                         CL_ALV_CHANGED_DATA_PROTOCOL
                         PV_ROW_ID
                         PV_TABIX
                         PV_FIELDNAME
                         PV_VALUE.

  PO_DATA_CHANGED->MODIFY_CELL( I_ROW_ID    = PV_ROW_ID
                                I_TABIX     = PV_TABIX
                                I_FIELDNAME = PV_FIELDNAME
                                I_VALUE     = PV_VALUE ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED_FINISHED USING PV_MODIFIED
                                            PT_GOOD_CELLS TYPE LVC_T_MODI
                                            PO_SENDER.

  CHECK PV_MODIFIED = GC_X
    AND PO_SENDER   = GO_GRID
    AND GT_CHG IS NOT INITIAL.

  "Refresh Grid
  PERFORM REFRESH_TABLE_DISPLAY USING PO_SENDER SPACE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_TOOLBAR USING PO_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                              PO_SENDER.
  DEFINE _ADD_TOOLBAR.
    LS_TOOLBAR = VALUE #( FUNCTION   = &1
                          ICON       = &2
                          QUICKINFO  = &3
                          TEXT       = &4
                          BUTN_TYPE  = &5 ).

    CASE &6.
      WHEN 'A'. "Append
        APPEND LS_TOOLBAR TO PO_OBJECT->MT_TOOLBAR.
      WHEN 'I'. "Insert
        INSERT LS_TOOLBAR INTO PO_OBJECT->MT_TOOLBAR INDEX 1.
    ENDCASE.
  END-OF-DEFINITION.

  DATA : LS_TOOLBAR TYPE STB_BUTTON.

*  CHECK GV_EDIT = GC_X.     "수정가능 상태
*
*  CASE PO_SENDER.
*    WHEN GO_GRID. "Main
*      _ADD_TOOLBAR SPACE                SPACE            SPACE    SPACE    3 ZPS01_A.
*      _ADD_TOOLBAR ZPS01_UCOMM-AUC_SETL ICON_GENERATE    TEXT-009 TEXT-009 0 ZPS01_A. "AUC 정산규칙(F) 생성
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_TABLE_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM REFRESH_TABLE_DISPLAY USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID
                                  PV_SOFT_REFRESH.

  CHECK PO_GRID IS BOUND.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE      = CONV #( 'XX' )
      I_SOFT_REFRESH = PV_SOFT_REFRESH
    EXCEPTIONS
      FINISHED       = 1
      OTHERS         = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_ON_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_ON_F4 USING PV_FIELDNAME TYPE LVC_FNAME
                            PV_FIELDVALUE  TYPE LVC_VALUE
                            PS_ROW_NO      TYPE LVC_S_ROID
                            PO_EVENT_DATA  TYPE REF TO CL_ALV_EVENT_DATA
                            PV_DISPLAY     TYPE CHAR01
                            PO_SENDER.
  DATA : LV_VALUE TYPE LVC_VALUE.
  FIELD-SYMBOLS : <LT_DATA> TYPE TABLE.

*  CHECK PO_SENDER = GO_GRID. "Main
*
*  PO_EVENT_DATA->M_EVENT_HANDLED = ZPS01_X.
*
*  CASE PV_FIELDNAME.
*    WHEN ZPS01_FNAME-Z_IV_ANLKL.  "자산 클래스
*
*      PERFORM F4_CODE_MASTER USING    ZPS01_ROLLNAME-ZE_IV_ANLKL
*                                      ZPS01_CODE-PSAC02
*                                      PV_DISPLAY
*                             CHANGING LV_VALUE.
*
*    WHEN OTHERS.
*      RETURN.
*  ENDCASE.
*
*  CHECK LV_VALUE IS NOT INITIAL.
*
*  ASSIGN PO_EVENT_DATA->M_DATA->* TO <LT_DATA>.
*  CHECK SY-SUBRC = 0.
*
*  APPEND VALUE LVC_S_MODI( FIELDNAME = PV_FIELDNAME
*                           ROW_ID    = PS_ROW_NO-ROW_ID
*                           VALUE     = LV_VALUE ) TO <LT_DATA>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FREE_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FREE_OBJECT .
* Field Catalog
  CLEAR: GT_FCAT[].

* Grid Clear
  CALL METHOD: GO_GRID->FREE.

  CLEAR: GO_GRID.

* Container Clear
  CALL METHOD: GO_CON->FREE,
               GO_SPLIT->FREE,
               GO_CON_TOP->FREE.

  CLEAR: GO_CON, GO_SPLIT, GO_CON_TOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATACHD_FLIFN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_DATA_CHANGED
*&      --> PS_MOD_CELLS
*&      <-- PS_DATA
*&---------------------------------------------------------------------*
FORM CHECK_DATACHD_FLIFN  USING    PO_DATA_CHANGED TYPE REF TO
                                   CL_ALV_CHANGED_DATA_PROTOCOL
                                   PS_MOD_CELLS TYPE LVC_S_MODI
                          CHANGING PS_DATA      STRUCTURE GS_S0100.

  DATA : LV_SUBRC TYPE SYSUBRC,
         LV_LIFNR TYPE LIFNR,
         LT_DUP   LIKE TABLE OF GS_S0100 WITH NON-UNIQUE SORTED KEY K_KEY COMPONENTS WERKS MATNR FLIFN.

  LT_DUP[] = GT_S0100[].
  ""유효성 체크
  IF PS_MOD_CELLS-VALUE IS NOT INITIAL.

    READ TABLE GT_S0100 INTO DATA(LS_MAIN) INDEX PS_MOD_CELLS-ROW_ID.
    IF LS_MAIN-NOTKZ IS NOT INITIAL.
      ""보류"나 "고정" 지시자를 선택하십시오.
      PERFORM ADD_PROTOCOL_ENTRY USING PO_DATA_CHANGED
                                       'ZGTMM01' '000' SPACE TEXT-E02
                                       PS_MOD_CELLS-FIELDNAME
                                       PS_MOD_CELLS-ROW_ID.
      PS_DATA-FLIFN = LS_MAIN-FLIFN.
      RETURN.
    ENDIF.

    DATA(LT_TMP) = FILTER #( LT_DUP USING KEY K_KEY WHERE WERKS = PS_DATA-WERKS
                                                      AND MATNR = PS_DATA-MATNR
                                                      AND FLIFN = GC_X ).
    DELETE LT_TMP WHERE LIFNR = LS_MAIN-LIFNR.
    IF LINES( LT_TMP ) > 0.
      "이미 고정 공급업체를 설정 하였습니다.
      LOOP AT LT_TMP INTO DATA(LS_TMP) WHERE LIFNR NE LS_MAIN-LIFNR.
        __ALPHA_OU LS_TMP-LIFNR LV_LIFNR.
        CONCATENATE TEXT-E01 '[ ' LV_LIFNR ']' INTO DATA(LV_MSG) SEPARATED BY SPACE.
        EXIT.
      ENDLOOP.

      PERFORM ADD_PROTOCOL_ENTRY USING PO_DATA_CHANGED
                                       'ZGTMM01' '000' SPACE LV_MSG
                                       PS_MOD_CELLS-FIELDNAME
                                       PS_MOD_CELLS-ROW_ID.
      PS_DATA-FLIFN = LS_MAIN-FLIFN.RETURN.
    ENDIF.
  ENDIF.

  PS_DATA-FLIFN = PS_MOD_CELLS-VALUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_DATA .

  DATA : LT_XEORD TYPE TABLE OF EORDU,
         LT_YEORD TYPE TABLE OF EORD,
         LS_EORD  TYPE EORDU,
         LV_LIFNR TYPE LIFNR,
         LT_DUP   LIKE TABLE OF GS_S0100 WITH NON-UNIQUE SORTED KEY K_KEY COMPONENTS WERKS MATNR FLIFN,
         LV_TCNT  TYPE I,
         LV_SCNT  TYPE I,
         LV_ECNT  TYPE I,
         LV_TCNTC TYPE CHAR20,
         LV_SCNTC TYPE CHAR20,
         LV_ECNTC TYPE CHAR20.

  CLEAR    GV_ERROR.

  "Check Changed Data
  PERFORM CHECK_CHANGED_DATA USING GO_GRID ZGTSD_X.
  CHECK GV_ERROR IS INITIAL.

  LT_DUP[] = GT_S0100[].
  DATA(LT_FOR) = GT_S0100[].
  SORT LT_FOR BY WERKS MATNR.
  DELETE ADJACENT DUPLICATES FROM LT_FOR COMPARING WERKS MATNR.
  IF LT_FOR[] IS NOT INITIAL.
    SELECT A~*
      FROM @LT_FOR AS B INNER JOIN EORD AS A
        ON B~WERKS = A~WERKS
       AND B~MATNR = A~MATNR
     WHERE A~WERKS  = @P_WERKS
       AND A~VDATU <= @P_VDATU
       AND A~BDATU >= @P_VDATU
     APPENDING CORRESPONDING FIELDS OF TABLE @LT_DUP.
  ENDIF.
  SORT LT_DUP BY WERKS MATNR ZEORD ASCENDING STATU DESCENDING.
  DELETE ADJACENT DUPLICATES FROM LT_DUP COMPARING WERKS MATNR ZEORD.

  CLEAR GS_S0100.
  MODIFY GT_S0100 FROM GS_S0100 TRANSPORTING SEL WHERE SEL IS NOT INITIAL.

  LOOP AT GT_S0100 INTO GS_S0100 WHERE STATU = ICON_CHANGE.

    IF GS_S0100-FLIFN IS NOT INITIAL AND GS_S0100-NOTKZ IS NOT INITIAL.
      MESSAGE I000 WITH TEXT-E02 DISPLAY LIKE GC_E.
      GV_ERROR = GC_X. RETURN.
    ENDIF.

    DATA(LT_TMP) = FILTER #( LT_DUP USING KEY K_KEY WHERE WERKS = GS_S0100-WERKS
                                                      AND MATNR = GS_S0100-MATNR
                                                      AND FLIFN = GC_X ).
    IF LINES( LT_TMP ) > 1.
      LOOP AT LT_TMP INTO DATA(LS_TMP) WHERE LIFNR NE GS_S0100-LIFNR.
        __ALPHA_OU LS_TMP-LIFNR LV_LIFNR.
        CONCATENATE TEXT-E01 '[ ' LV_LIFNR ']' INTO DATA(LV_MSG) SEPARATED BY SPACE.
        EXIT.
      ENDLOOP.
      MESSAGE I000 WITH LV_MSG DISPLAY LIKE GC_E.
      GV_ERROR = GC_X. RETURN.
    ENDIF.

    GS_S0100-SEL = GC_X.
    MODIFY GT_S0100 FROM GS_S0100.
  ENDLOOP.

  GV_ANSWER = ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-M01 ).
  CHECK GV_ANSWER EQ ZGTSD_J.

  CHECK GV_ERROR IS INITIAL.
  LOOP AT GT_S0100 INTO GS_S0100 WHERE SEL = GC_X.

    ADD 1 TO LV_TCNT.

    CLEAR LS_EORD.
    __CLE : LT_XEORD, LT_YEORD.

    MOVE-CORRESPONDING GS_S0100 TO LS_EORD.
    APPEND LS_EORD TO LT_XEORD.

    CLEAR LS_EORD.
    READ TABLE LT_DUP INTO DATA(LS_DUP) WITH KEY WERKS = GS_S0100-WERKS
                                                 MATNR = GS_S0100-MATNR
                                                 ZEORD = GS_S0100-ZEORD.
    IF SY-SUBRC = 0.
      MOVE-CORRESPONDING LS_DUP TO LS_EORD.
      APPEND LS_EORD TO LT_YEORD.
    ENDIF.

    CALL FUNCTION 'ME_UPDATE_SOURCES_OF_SUPPLY'
      EXPORTING
        I_CHANGEDOCUMENT = 'U'
      TABLES
        XEORD            = LT_XEORD
        YEORD            = LT_YEORD.
    IF SY-SUBRC = 0.
      GS_S0100-STATU = ICON_LED_GREEN.
      ADD 1 TO LV_SCNT.
    ELSE.
      ADD 1 TO LV_ECNT.
      GS_S0100-STATU = ICON_LED_RED.
    ENDIF.

    MODIFY GT_S0100 FROM GS_S0100.

  ENDLOOP.

  __CLE GT_CHG.
  WRITE LV_TCNT TO LV_TCNTC. CONDENSE LV_TCNTC.
  WRITE LV_SCNT TO LV_SCNTC. CONDENSE LV_SCNTC.
  WRITE LV_ECNT TO LV_ECNTC. CONDENSE LV_ECNTC.
  MESSAGE S051(ZGTSD01) WITH LV_TCNT LV_SCNT LV_ECNT.
  PERFORM REFRESH_TABLE_DISPLAY USING GO_GRID SPACE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATACHD_NOTKZ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_DATA_CHANGED
*&      --> PS_MOD_CELLS
*&      <-- PS_DATA
*&---------------------------------------------------------------------*
FORM CHECK_DATACHD_NOTKZ  USING    PO_DATA_CHANGED TYPE REF TO
                                   CL_ALV_CHANGED_DATA_PROTOCOL
                                   PS_MOD_CELLS TYPE LVC_S_MODI
                          CHANGING PS_DATA      STRUCTURE GS_S0100.

  DATA : LV_SUBRC TYPE SYSUBRC,
         LT_DUP   LIKE TABLE OF GS_S0100 WITH NON-UNIQUE SORTED KEY K_KEY COMPONENTS WERKS MATNR FLIFN.

  ""유효성 체크
  IF PS_MOD_CELLS-VALUE IS NOT INITIAL.
    READ TABLE GT_S0100 INTO DATA(LS_MAIN) INDEX PS_MOD_CELLS-ROW_ID.

    IF LS_MAIN-FLIFN IS NOT INITIAL.
      ""보류"나 "고정" 지시자를 선택하십시오
      PERFORM ADD_PROTOCOL_ENTRY USING PO_DATA_CHANGED
                                       'ZGTMM01' '000' SPACE TEXT-E02
                                       PS_MOD_CELLS-FIELDNAME
                                       PS_MOD_CELLS-ROW_ID.
      RETURN.
    ENDIF.
  ENDIF.

  PS_DATA-NOTKZ = PS_MOD_CELLS-VALUE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GUI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GUI.

  "공급업체 복사 기능 추가(PSJ 25.01.17)

  CHECK P_CALLD <> GC_X.

  GT_FCODE[] = VALUE #( ( 'COPY' ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRCS_COPY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRCS_COPY.

  DATA : LV_SUBRC LIKE SY-SUBRC.


  "공급업체 복사 기능 추가(PSJ 25.01.17)

  DATA(LT_ROWS) = ZGTSD_CL_COMMON=>GET_SELECTED_ROWS( EXPORTING
                                                        IO_GRID     = GO_GRID
                                                        IV_CK       = ZGTSD_X
                                                        IV_ONLY_ONE = ZGTSD_X
                                                      IMPORTING
                                                        EV_SUBRC    = LV_SUBRC ).

  CHECK LV_SUBRC IS INITIAL.

  "선택한 공급업체를 복사하시겠습니까?
  GV_ANSWER = ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-M03 ).
  CHECK GV_ANSWER EQ ZGTSD_J.

  READ TABLE LT_ROWS INTO DATA(LS_ROW) INDEX 1.
  READ TABLE GT_S0100 INTO GS_S0100 INDEX LS_ROW-INDEX.
  CHECK SY-SUBRC = 0.

  "보류 공급업체 복사 불가 처리(PSJ 25.05.02)
  IF GS_S0100-NOTKZ = GC_X.
    MESSAGE S145(ZGTMM01) DISPLAY LIKE 'E'. "보류 공급업체는 복사할 수 없습니다.
    EXIT.
  ENDIF.

  SET PARAMETER ID 'ZGTMM_FLIEF' FIELD GS_S0100-LIFNR.

  IF SY-SUBRC = 0.
    MESSAGE S036(ZGTMM01). "& 성공했습니다.
    SET SCREEN 0.
  ELSE.
    MESSAGE S037(ZGTMM01) DISPLAY LIKE 'E'. "& 실패했습니다.
  ENDIF.

ENDFORM.
