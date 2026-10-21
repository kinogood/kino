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


  S_ERDAT-LOW = SY-DATLO(6) && |01|.
  S_ERDAT-HIGH = SY-DATLO.
  __RNG S_ERDAT 'I' 'EQ' S_ERDAT-LOW S_ERDAT-HIGH.

  P_IF_RFC = GC_RFC.

  IF GT_RFC[] IS INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE @GT_RFC
      FROM ZGTSDT9010.
  ENDIF.

  DATA : LV_NUM TYPE N LENGTH 2.
  DATA(LT_TAB) = GT_RFC[].
  DELETE LT_TAB WHERE ZTYPE NE 'R'.
  DELETE LT_TAB WHERE ZIFRFC NE P_IF_RFC.
  READ TABLE LT_TAB INTO DATA(LS_TAB) INDEX 1.
  LOOP AT GT_RFC INTO GS_RFC USING KEY K_KEY WHERE ZIFRFC = P_IF_RFC AND ZTYPE = 'F' .
    CLEAR GS_TPOOL.
    DO GC_LOOP TIMES.
      ADD 1 TO LV_NUM.
      CONCATENATE 'ZVALUE' LV_NUM INTO DATA(LV_FLD).
      ASSIGN COMPONENT LV_FLD OF STRUCTURE GS_RFC TO FIELD-SYMBOL(<LFS_VAL>).
      CHECK SY-SUBRC = 0 AND <LFS_VAL> IS NOT INITIAL.

      ASSIGN COMPONENT LV_FLD OF STRUCTURE LS_TAB TO FIELD-SYMBOL(<LFS_VAL2>).
      CHECK SY-SUBRC = 0.

      ASSIGN COMPONENT LV_FLD OF STRUCTURE GS_FLD TO FIELD-SYMBOL(<LFS_VAL3>).
      CHECK SY-SUBRC = 0.

      <LFS_VAL3> = <LFS_VAL2> && '-' && <LFS_VAL>.

    ENDDO.
  ENDLOOP.

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

  DATA : LV_SCR TYPE CHAR20.

  DATA : LV_NUM TYPE N LENGTH 2.
  DATA(LT_TAB) = GT_RFC[].
  DELETE LT_TAB WHERE ZTYPE NE 'R'.
  DELETE LT_TAB WHERE ZIFRFC NE P_IF_RFC.
  READ TABLE LT_TAB INTO DATA(LS_TAB) INDEX 1.
  LOOP AT GT_RFC INTO GS_RFC USING KEY K_KEY WHERE ZIFRFC = P_IF_RFC AND ZTYPE = 'F' .
    CLEAR GS_TPOOL.
    DO GC_LOOP TIMES.
      ADD 1 TO LV_NUM.
      CONCATENATE 'ZVALUE' LV_NUM INTO DATA(LV_FLD).
      CONCATENATE '*' LV_FLD+1 '*' INTO LV_SCR.
      ASSIGN COMPONENT LV_FLD OF STRUCTURE GS_RFC TO FIELD-SYMBOL(<LFS_VAL>).
      CHECK SY-SUBRC = 0 .
      IF <LFS_VAL> IS  INITIAL.
        LOOP AT SCREEN.
          IF SCREEN-NAME CP LV_SCR.
            SCREEN-ACTIVE = 0.
          ELSE.
            SCREEN-ACTIVE = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        CONTINUE.
      ENDIF.
      ASSIGN COMPONENT LV_FLD OF STRUCTURE LS_TAB TO FIELD-SYMBOL(<LFS_VAL2>).
      CHECK SY-SUBRC = 0.
      IF <LFS_VAL2> IS INITIAL.
        LOOP AT SCREEN.
          IF SCREEN-NAME CP LV_SCR.
            SCREEN-ACTIVE = 0.
          ELSE.
            SCREEN-ACTIVE = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
      ENDIF.
      ASSIGN COMPONENT LV_FLD OF STRUCTURE GS_FLD TO FIELD-SYMBOL(<LFS_VAL3>).
      CHECK SY-SUBRC = 0.
      <LFS_VAL3> = <LFS_VAL2> && '-' && <LFS_VAL>.
    ENDDO.
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
  IF P_IF_RFC IS INITIAL.
    MESSAGE S007 WITH %_P_IF_RFC_%_APP_%-TEXT DISPLAY LIKE ZGTSD_E.
    GV_ERROR = ZGTSD_X.
    RETURN.
  ENDIF.

  IF S_ERDAT[] IS INITIAL.
    MESSAGE S007 WITH %_S_ERDAT_%_APP_%-TEXT DISPLAY LIKE ZGTSD_E.
    GV_ERROR = ZGTSD_X.
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
FORM DATA_QUERY.

  RANGES : LR_STAT FOR ZGTSDT9000-ZSTAT.

  CLEAR GV_ERROR. __CLE : GT_S0100.

  "Batch-job 은 인터페이스 실패 건만 재처리
  IF SY-BATCH IS NOT INITIAL.
    __RNG LR_STAT 'I' 'EQ' 'E' ''.
  ELSE.
    CASE 'X'.
      WHEN RB_SU.
        __RNG LR_STAT 'I' 'NE' 'E' ''.
      WHEN RB_FA.
        __RNG LR_STAT 'I' 'EQ' 'E' ''.
    ENDCASE.
  ENDIF.

  SELECT A~*,
         CASE WHEN A~ZERP_STAT <> 'E' THEN @ICON_LED_GREEN
              WHEN A~ZERP_STAT = 'E' THEN @ICON_LED_RED
              ELSE @ICON_LED_INACTIVE END AS ZICON
    FROM ZGTSDT9000 AS A
   WHERE ZIFRFC    EQ @P_IF_RFC
     AND ZVALUE01  IN @VALUE01
     AND ZVALUE02  IN @VALUE02
     AND ZVALUE03  IN @VALUE03
     AND ZVALUE04  IN @VALUE04
     AND ZVALUE05  IN @VALUE05
     AND ZVALUE06  IN @VALUE06
     AND ZVALUE07  IN @VALUE07
     AND ZVALUE08  IN @VALUE08
     AND ZVALUE09  IN @VALUE09
     AND ZVALUE10  IN @VALUE10
     AND ZVALUE11  IN @VALUE11
     AND ZVALUE12  IN @VALUE12
     AND ZVALUE13  IN @VALUE13
     AND ZVALUE14  IN @VALUE14
     AND ZVALUE15  IN @VALUE15
     AND ZVALUE16  IN @VALUE16
     AND ZVALUE17  IN @VALUE17
     AND ZVALUE18  IN @VALUE18
     AND ZVALUE19  IN @VALUE19
     AND ZVALUE20  IN @VALUE20
     AND IFDAT     IN @S_ERDAT
     AND ZERP_STAT IN @LR_STAT
    INTO CORRESPONDING FIELDS OF TABLE @GT_S0100.

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

  GO_SPLIT->SET_ROW_HEIGHT( ID = 1 HEIGHT = 15 ).

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
  PERFORM SET_GRID_LAYOUT USING SPACE SPACE ZGTSD_D.

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
                       ZEBRA      = ZGTSD_X
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
                                                IV_CELLS = ZGTSD_X
                                                IV_CELLC = ZGTSD_X ).

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
      'S' 'FIELDNAME'   'ZICON',
      ' ' 'COLTEXT'     TEXT-F01,
      ' ' 'ICON'        'X',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'ZIFRFC',
      ' ' 'COLTEXT'     TEXT-F02,
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'ZSYSTEM_ID',
      ' ' 'COLTEXT'     TEXT-F03,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'ZIFKEY',
      ' ' 'COLTEXT'     TEXT-F00,
      'E' 'OUTPUTLEN'   '20'.


  DATA : LV_NUM TYPE N LENGTH 2.
  DATA(LT_TAB) = GT_RFC[].
  DELETE LT_TAB WHERE ZTYPE NE 'T'.
  DELETE LT_TAB WHERE ZIFRFC NE P_IF_RFC.
  READ TABLE LT_TAB INTO DATA(LS_TAB) INDEX 1.
  LOOP AT GT_RFC INTO GS_RFC USING KEY K_KEY WHERE ZIFRFC = P_IF_RFC AND ZTYPE = 'F' .
    CLEAR GS_TPOOL.
    DO GC_LOOP TIMES.
      ADD 1 TO LV_NUM.
      CONCATENATE 'ZVALUE' LV_NUM INTO DATA(LV_FLD).
      ASSIGN COMPONENT LV_FLD OF STRUCTURE GS_RFC TO FIELD-SYMBOL(<LFS_VAL>).
      CHECK SY-SUBRC = 0 AND <LFS_VAL> IS NOT INITIAL.

      ASSIGN COMPONENT LV_FLD OF STRUCTURE LS_TAB TO FIELD-SYMBOL(<LFS_VAL2>).
      CHECK SY-SUBRC = 0 AND <LFS_VAL2> IS NOT INITIAL.

      PERFORM RESET_FIELD_CATALOG TABLES GT_FCAT USING :
           'S' 'FIELDNAME'   LV_FLD,
           ' ' 'COLTEXT'     <LFS_VAL2>,
           'E' 'OUTPUTLEN'   '20'.
    ENDDO.
  ENDLOOP.


  PERFORM RESET_FIELD_CATALOG TABLES GT_FCAT USING :
      'S' 'FIELDNAME'   'ZSTAT',
      ' ' 'COLTEXT'     TEXT-F15,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'ZMESSAGE',
      ' ' 'COLTEXT'     TEXT-F16,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'ZERP_STAT',
      ' ' 'COLTEXT'     TEXT-F17,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'ZERP_MESSAGE',
      ' ' 'COLTEXT'     TEXT-F18,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'IFDAT',
      ' ' 'COLTEXT'     TEXT-F19,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'IFTIM',
      ' ' 'COLTEXT'     TEXT-F20,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'IFNAM',
      ' ' 'COLTEXT'     TEXT-F21,
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

  IF PV_FLAG = ZGTSD_S.  "Start
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

  IF PV_FLAG = ZGTSD_E.  "End
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
                LO_EVENT->HANDLE_DBL_CLICK             FOR PO_SENDER.
*                LO_EVENT->HANDLE_TOOLBAR               FOR PO_SENDER,
*                LO_EVENT->HANDLE_USER_COMMAND          FOR PO_SENDER,
*                LO_EVENT->HANDLE_ON_F4                 FOR PO_SENDER.
*               LO_EVENT->HANDLE_DATA_CHANGED          FOR PO_SENDER,
*               LO_EVENT->HANDLE_DATA_CHANGED_FINISHED FOR PO_SENDER.

*  "Data Changed Event
*  PO_SENDER->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
*  PO_SENDER->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_ENTER ).

*  "Set Ready for Input
*  GO_GRID->SET_READY_FOR_INPUT( SWITCH #( GV_EDIT WHEN ZGTSD_X THEN 1 ELSE 0 ) ).

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
                  WHERE F4AVAILABL = ZGTSD_X.
    LT_F4 = VALUE #( BASE LT_F4 ( FIELDNAME  = LS_FCAT-FIELDNAME
                                  REGISTER   = ZGTSD_X
                                  CHNGEAFTER = ZGTSD_X ) ).
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

  DELETE GT_FCAT WHERE TECH = ZGTSD_X. "불필요한 필드 제외

  "Formatted Output Table is Sent to Control
  CALL METHOD PO_SENDER->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT
      IS_VARIANT           = VALUE #( REPORT = SY-REPID
                                      HANDLE = LV_HANDL )
      I_SAVE               = ZGTSD_A
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
    WHEN 'VBELN'.
      CHECK GS_S0100-ZVALUE05 IS NOT INITIAL.
      SET PARAMETER ID: 'AUN' FIELD   GS_S0100-ZVALUE05.
      CALL TRANSACTION  'VA03' AND SKIP FIRST SCREEN.

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

  PERFORM SET_SORT_FIELD USING: "PT_SORT 'VBELN' GC_X '' '',
                                PT_SORT 'IFDAT' GC_X '' '',
                                PT_SORT 'IFTIM' GC_X '' ''.

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
  DATA : LV_TEXT TYPE SDYDO_TEXT_ELEMENT,
         LV_SCR  TYPE CHAR40.

  CHECK PO_SENDER = GO_GRID "Main
    AND PO_DOCU IS BOUND.

  "Set Column Width
  PO_DOCU->ADD_TABLE( EXPORTING NO_OF_COLUMNS = 3 BORDER = '0' IMPORTING TABLE = DATA(LO_TABLE) ).

  LO_TABLE->ADD_COLUMN( EXPORTING WIDTH = '20%' IMPORTING COLUMN = DATA(LO_COL_KEY) ).
  LO_TABLE->ADD_COLUMN( EXPORTING WIDTH = '3%' IMPORTING COLUMN = DATA(LO_COL_SEP) ).
  LO_TABLE->ADD_COLUMN( EXPORTING WIDTH = '77%' IMPORTING COLUMN = DATA(LO_COL_VAL) ).
  LO_TABLE->NEW_ROW( ).

  "Set Column Style
  LO_TABLE->SET_COLUMN_STYLE( COL_NO = 1 SAP_EMPHASIS = CL_DD_DOCUMENT=>STRONG SAP_ALIGN = 'LEFT' ).
  LO_TABLE->SET_COLUMN_STYLE( COL_NO = 3 SAP_EMPHASIS = CL_DD_DOCUMENT=>MEDIUM SAP_ALIGN = 'LEFT' ).

  "Add Text
  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
                                ZGTSD_P %_P_IF_RFC_%_APP_%-TEXT P_IF_RFC.

  DATA : LV_NUM TYPE N LENGTH 2.
  DATA(LT_TAB) = GT_RFC[].
  DELETE LT_TAB WHERE ZTYPE NE 'T'.
  DELETE LT_TAB WHERE ZIFRFC NE P_IF_RFC.
  READ TABLE LT_TAB INTO DATA(LS_TAB) INDEX 1.
  LOOP AT GT_RFC INTO GS_RFC USING KEY K_KEY WHERE ZIFRFC = P_IF_RFC AND ZTYPE = 'F' .
    CLEAR GS_TPOOL.
    DO GC_LOOP TIMES.
      ADD 1 TO LV_NUM.
      CONCATENATE 'ZVALUE' LV_NUM INTO DATA(LV_FLD).
      ASSIGN COMPONENT LV_FLD OF STRUCTURE GS_RFC TO FIELD-SYMBOL(<LFS_VAL>).
      CHECK SY-SUBRC = 0 AND <LFS_VAL> IS NOT INITIAL.

      ASSIGN COMPONENT LV_FLD OF STRUCTURE LS_TAB TO FIELD-SYMBOL(<LFS_VAL2>).
      CHECK SY-SUBRC = 0 AND <LFS_VAL2> IS NOT INITIAL.

      CONCATENATE LV_FLD+1 '[]' INTO LV_SCR.
      PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
                                    ZGTSD_S <LFS_VAL2> LV_SCR.
    ENDDO.
  ENDLOOP.
*
*
*  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
*                                ZGTSD_S %_S_VBELN_%_APP_%-TEXT 'S_VBELN[]'.

  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
                                ZGTSD_S %_S_ERDAT_%_APP_%-TEXT 'S_ERDAT[]'.


  "Display Document
  PO_DOCU->MERGE_DOCUMENT( ).
  PO_DOCU->DISPLAY_DOCUMENT( EXPORTING
                               REUSE_CONTROL      = ZGTSD_X
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
    WHEN ZGTSD_P. "Parameter
      CHECK PV_VALUE IS NOT INITIAL.
      LV_TEXT = CONV SDYDO_TEXT_ELEMENT( PV_VALUE ).
    WHEN ZGTSD_S. "Select-Option
      ASSIGN (PV_VALUE) TO <LT_SELOPT>.
      CHECK SY-SUBRC = 0.

      CHECK LINES( <LT_SELOPT> ) => 1.

      ASSIGN COMPONENT 'LOW' OF STRUCTURE <LT_SELOPT>[ 1 ] TO FIELD-SYMBOL(<LV_LOW>).
      CHECK SY-SUBRC = 0.
      ASSIGN COMPONENT 'HIGH' OF STRUCTURE <LT_SELOPT>[ 1 ] TO FIELD-SYMBOL(<LV_HIGH>).
      CHECK SY-SUBRC = 0.

      IF <LV_HIGH> IS INITIAL.
        LV_TEXT = <LV_LOW>.
      ELSEIF <LV_LOW> IS INITIAL.
        LV_TEXT = `~ ` &&  <LV_LOW>.
      ELSE.
        LV_TEXT = <LV_LOW> && ` ~ ` &&  <LV_HIGH>.
      ENDIF.
  ENDCASE.

  PO_COL_KEY->ADD_TEXT( TEXT = CONV SDYDO_TEXT_ELEMENT( PV_KEY ) ).
  PO_COL_SEP->ADD_TEXT( TEXT = CONV SDYDO_TEXT_ELEMENT( ZGTSD_COLON ) ).
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

    WHEN 'MATNR'. "자산번호

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

  IF PV_CK = ZGTSD_X AND LV_VALID IS INITIAL.
    GV_ERROR = ZGTSD_X. "오류 Flag
    MESSAGE S029 DISPLAY LIKE ZGTSD_E. "오류 내역이 존재합니다.
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

  PV_MODI  = ZGTSD_X.     "변경 Flag
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
        I_MSGTY     = ZGTSD_E
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

  CHECK PV_MODIFIED = ZGTSD_X
    AND PO_SENDER   = GO_GRID
    AND GT_CHG IS NOT INITIAL.

*  변경사항 반영
  PERFORM UPDATE_EDIT_FIELDS USING GT_CHG.

  "Refresh Grid
  PERFORM REFRESH_TABLE_DISPLAY USING PO_SENDER SPACE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_EDIT_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM UPDATE_EDIT_FIELDS USING PT_CHG TYPE TY_T_CHG.

*  "Set 수정 필드
*  DELETE ADJACENT DUPLICATES FROM PT_CHG USING KEY KEY_MODE COMPARING PSPID.
*
*  LOOP AT PT_CHG INTO DATA(LS_CHG).
*
*    DATA(LS_DATA) = VALUE #( GT_MAIN[ KEY KEY_STUFE
*                               COMPONENTS PSPID = LS_CHG-PSPID
*                                          STUFE = 1 ] OPTIONAL ).
*    CHECK LS_DATA-PSPID IS NOT INITIAL.
*
*    LOOP AT GT_MAIN ASSIGNING FIELD-SYMBOL(<LS_MAIN>) USING KEY KEY_MODE
*                     WHERE PSPID = LS_DATA-PSPID.
*      <LS_MAIN>-Z_IV_PUR       = LS_DATA-Z_IV_PUR.       "자산 매각
*      <LS_MAIN>-Z_IV_ANLKL     = LS_DATA-Z_IV_ANLKL.     "자산 클래스
*      <LS_MAIN>-Z_IV_ANLKL_TXT = LS_DATA-Z_IV_ANLKL_TXT. "자산 클래스 명
*      <LS_MAIN>-Z_KSTAR        = LS_DATA-Z_KSTAR.        "원가요소
*      <LS_MAIN>-Z_KSTAR_TXT    = LS_DATA-Z_KSTAR_TXT.    "원가요소 명
*    ENDLOOP.
*  ENDLOOP.

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
      WHEN ZGTSD_A. "Append
        APPEND LS_TOOLBAR TO PO_OBJECT->MT_TOOLBAR.
      WHEN ZGTSD_I. "Insert
        INSERT LS_TOOLBAR INTO PO_OBJECT->MT_TOOLBAR INDEX 1.
    ENDCASE.
  END-OF-DEFINITION.

  DATA : LS_TOOLBAR TYPE STB_BUTTON.

*  CHECK GV_EDIT = ZGTSD_X.     "수정가능 상태
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
*& Form SEND_IF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_IF USING PV_TYPE.

  DATA : LV_SUBRC   TYPE SY-SUBRC,
         LV_CNT     TYPE I,
         LV_RESULT  TYPE ZO_RESULT,
         LV_DEST    TYPE ZIFDEST-DEST,
         LV_MSG     TYPE ZO_MESSAGE,
         LV_WERKS   TYPE WERKS_D,
         LV_VBELN   TYPE VBELN_VA,
         LV_ZSTATUS TYPE CHAR02,
         LV_ZJOB_NO TYPE CHAR30,
         LV_ABSTK   TYPE C,
         LV_SYSID   TYPE ZGTETARGET,
         LT_TMP     LIKE TABLE OF GS_S0100.

  DATA : LT_HTAB TYPE TABLE OF ZGTSDSIF0060 WITH EMPTY KEY.

  CONSTANTS : LC_ZPGM    TYPE TEXT20 VALUE 'ZGTSDI6010',
              LC_ZMODULE TYPE CHAR02 VALUE 'SD'.

  "Selected Rows
  DATA(LT_ROWS) = ZGTSD_CL_COMMON=>GET_SELECTED_ROWS( EXPORTING
                                                        IO_GRID = GO_GRID
                                                        IV_CK   = ZGTSD_X
                                                      IMPORTING
                                                        EV_SUBRC = LV_SUBRC ).
  CHECK LV_SUBRC IS INITIAL.

  CLEAR GS_S0100.
  MODIFY GT_S0100 FROM GS_S0100 TRANSPORTING SEL WHERE SEL IS NOT INITIAL.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).

    READ TABLE GT_S0100 INTO GS_S0100 INDEX LS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    GS_S0100-SEL = GC_X.
    APPEND GS_S0100 TO LT_TMP.

    MODIFY GT_S0100 FROM GS_S0100 INDEX LS_ROW-INDEX.
  ENDLOOP.

  SORT LT_TMP BY ZSYSTEM_ID.
  DELETE ADJACENT DUPLICATES FROM LT_TMP COMPARING ZSYSTEM_ID.
  IF LINES( LT_TMP ) > 1.
    MESSAGE S000 WITH TEXT-E03 DISPLAY LIKE GC_E.EXIT.
  ELSE.
    READ TABLE LT_TMP INTO DATA(LS_TMP) INDEX 1.
    GV_TAR = LS_TMP-ZSYSTEM_ID.
  ENDIF.

  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      GUBUN                 = 'IS'
    IMPORTING
      DEST_NAME             = LV_DEST
    EXCEPTIONS
      DESTINATION_NOT_FOUND = 1
      OTHERS                = 2.
  IF LV_DEST IS  INITIAL.
    MESSAGE S000 WITH TEXT-E04 DISPLAY LIKE GC_E.EXIT.
  ENDIF.

  CLEAR GV_ANSWER.
  GV_ANSWER = ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-M02 ).
  CHECK GV_ANSWER EQ ZGTSD_J.

  LOOP AT GT_S0100 INTO LS_TMP WHERE SEL = 'X'.

    TRY.

        CASE P_IF_RFC.

          WHEN 'ZGTED_BD_WORK_DATA_STATUS'.

            LV_WERKS   = LS_TMP-ZVALUE03.
            LV_ZJOB_NO = LS_TMP-ZVALUE04.
            LV_VBELN   = LS_TMP-ZVALUE05.
            LV_ZSTATUS = LS_TMP-ZVALUE07.

            CLEAR LV_ABSTK.
            IF LS_TMP-ZVALUE08 = 'U'.
              LV_ABSTK = LS_TMP-ZVALUE06.
            ENDIF.

            CALL FUNCTION 'ZGTED_BD_WORK_DATA_STATUS'
              EXPORTING
                I_ZMODULE  = LC_ZMODULE
                I_ZPROGRAM = LC_ZPGM
                I_ZWERKS   = LV_WERKS
                I_ZJOB_NO  = LV_ZJOB_NO
                I_ZSTATUS  = LV_ZSTATUS
                I_VBELN    = LV_VBELN
                I_ZABSTK   = LV_ABSTK
              IMPORTING
                ZO_RESULT  = LS_TMP-ZSTAT
                ZO_MESSAGE = LS_TMP-ZMESSAGE.

          WHEN 'ZGTSD_IF_O_BD_MFG_INSTR_REQ'.

            __CLE : LT_HTAB.

*-- 전송 정보 구성
            APPEND VALUE #( MREQNO    = LS_TMP-ZVALUE01
                            WERKS     = LS_TMP-ZVALUE02
                            ZPJNO     = LS_TMP-ZVALUE03
                            STAT      = LS_TMP-ZVALUE04
                            KUNNR     = LS_TMP-ZVALUE05
                            NAME1     = LS_TMP-ZVALUE06
                            ZPDAT     = LS_TMP-ZVALUE07
                            ZPTXT     = LS_TMP-ZVALUE08
                            PERNR     = LS_TMP-ZVALUE09
                            MAIL_ADDR = LS_TMP-ZVALUE10
                            ENAME     = LS_TMP-ZVALUE11
                            LAND1     = LS_TMP-ZVALUE12 ) TO LT_HTAB.

            CALL FUNCTION 'ZGTSD_IF_O_BD_MFG_INSTR_REQ'
              DESTINATION LV_DEST
              EXPORTING
                I_SYSTEM_ID           = GV_TAR
              IMPORTING
                ZO_RESULT             = LS_TMP-ZSTAT
                ZO_MESSAGE            = LS_TMP-ZMESSAGE
              TABLES
                OT_HTAB               = LT_HTAB
              EXCEPTIONS
                SYSTEM_FAILURE        = 1
                COMMUNICATION_FAILURE = 2
                ILLEGALNAME           = 3
                OTHERS                = 4.

          WHEN OTHERS.

        ENDCASE.

      CATCH CX_ROOT INTO DATA(LO_ERR).

        LS_TMP-ZERP_STAT = 'E'.
        LS_TMP-ZERP_MESSAGE = LO_ERR->GET_LONGTEXT( ).
        LS_TMP-ZICON = ICON_LED_RED.
        MODIFY GT_S0100 FROM LS_TMP.

*zgtsdt9000 UPDATE
        PERFORM BD_LOG_UPDATE USING LS_TMP.
        PERFORM REFRESH_TABLE_DISPLAY USING GO_GRID SPACE.
        CONTINUE.
    ENDTRY.

    IF LS_TMP-ZSTAT NE '00'.
      LS_TMP-ZERP_STAT = 'E'.
      LS_TMP-ZERP_MESSAGE = '제조지시 상태변경 재처리 실패'.
      LS_TMP-ZICON = ICON_LED_RED.
    ELSE.
      LS_TMP-ZERP_STAT = 'S'.
      LS_TMP-ZERP_MESSAGE = '제조지시 상태변경 재처리 성공'.
      LS_TMP-ZICON = ICON_LED_GREEN.
    ENDIF.

    PERFORM BD_LOG_UPDATE USING  LS_TMP.
    MODIFY GT_S0100 FROM LS_TMP.
  ENDLOOP.

*  IF PV_TYPE IS NOT INITIAL.
*    PERFORM DATA_QUERY.
*  ENDIF.
  PERFORM REFRESH_TABLE_DISPLAY USING GO_GRID SPACE.

  MESSAGE S000 WITH '처리되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_IF_BATCHJOB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_IF_BATCHJOB .

  DATA : LV_SUBRC   TYPE SY-SUBRC,
         LV_ECNT    TYPE I,
         LV_CNT     TYPE I,
         LV_RESULT  TYPE ZO_RESULT,
         LV_DEST    TYPE ZIFDEST-DEST,
         LV_MSG     TYPE ZO_MESSAGE,
         LV_WERKS   TYPE WERKS_D,
         LV_VBELN   TYPE VBELN_VA,
         LV_ZSTATUS TYPE CHAR02,
         LV_ZJOB_NO TYPE CHAR30,
         LV_ABSTK   TYPE C,
         LV_SYSID   TYPE ZGTETARGET,
         LT_TMP     LIKE TABLE OF GS_S0100.

  DATA : LT_HTAB TYPE TABLE OF ZGTSDSIF0060 WITH EMPTY KEY.

  CONSTANTS : LC_ZPGM    TYPE TEXT20 VALUE 'ZGTSDI6010',
              LC_ZMODULE TYPE CHAR02 VALUE 'SD'.

  LT_TMP[] = GT_S0100[].
  DELETE LT_TMP WHERE ZICON NE ICON_LED_RED.
  SORT LT_TMP BY ZSYSTEM_ID.
  DELETE ADJACENT DUPLICATES FROM LT_TMP COMPARING ZSYSTEM_ID.
  IF LINES( LT_TMP ) > 1.
    MESSAGE S000 WITH TEXT-E03 DISPLAY LIKE GC_E.EXIT.
  ELSE.
    READ TABLE LT_TMP INTO DATA(LS_TMP) INDEX 1.
    GV_TAR = LS_TMP-ZSYSTEM_ID.
  ENDIF.

  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      GUBUN                 = 'IS'
    IMPORTING
      DEST_NAME             = LV_DEST
    EXCEPTIONS
      DESTINATION_NOT_FOUND = 1
      OTHERS                = 2.
  IF LV_DEST IS  INITIAL.
    MESSAGE S000 WITH TEXT-E04 DISPLAY LIKE GC_E.EXIT.
  ENDIF.

  LOOP AT GT_S0100 INTO LS_TMP.

    TRY.

        CASE P_IF_RFC.

          WHEN 'ZGTED_BD_WORK_DATA_STATUS'.

            LV_WERKS   = LS_TMP-ZVALUE03.
            LV_ZJOB_NO = LS_TMP-ZVALUE04.
            LV_VBELN   = LS_TMP-ZVALUE05.
            LV_ZSTATUS = LS_TMP-ZVALUE07.

            CLEAR LV_ABSTK.
            IF LS_TMP-ZVALUE08 = 'U'.
              LV_ABSTK = LS_TMP-ZVALUE06.
            ENDIF.

            CALL FUNCTION 'ZGTED_BD_WORK_DATA_STATUS'
              EXPORTING
                I_ZMODULE  = LC_ZMODULE
                I_ZPROGRAM = LC_ZPGM
                I_ZWERKS   = LV_WERKS
                I_ZJOB_NO  = LV_ZJOB_NO
                I_ZSTATUS  = LV_ZSTATUS
                I_VBELN    = LV_VBELN
                I_ZABSTK   = LV_ABSTK
              IMPORTING
                ZO_RESULT  = LS_TMP-ZSTAT
                ZO_MESSAGE = LS_TMP-ZMESSAGE.

          WHEN 'ZGTSD_IF_O_BD_MFG_INSTR_REQ'.

            __CLE : LT_HTAB.

*-- 전송 정보 구성
            APPEND VALUE #( MREQNO    = LS_TMP-ZVALUE01
                            WERKS     = LS_TMP-ZVALUE02
                            ZPJNO     = LS_TMP-ZVALUE03
                            STAT      = LS_TMP-ZVALUE04
                            KUNNR     = LS_TMP-ZVALUE05
                            NAME1     = LS_TMP-ZVALUE06
                            ZPDAT     = LS_TMP-ZVALUE07
                            ZPTXT     = LS_TMP-ZVALUE08
                            PERNR     = LS_TMP-ZVALUE09
                            MAIL_ADDR = LS_TMP-ZVALUE10
                            ENAME     = LS_TMP-ZVALUE11
                            LAND1     = LS_TMP-ZVALUE12 ) TO LT_HTAB.

            CALL FUNCTION 'ZGTSD_IF_O_BD_MFG_INSTR_REQ'
              DESTINATION LV_DEST
              EXPORTING
                I_SYSTEM_ID           = GV_TAR
              IMPORTING
                ZO_RESULT             = LS_TMP-ZSTAT
                ZO_MESSAGE            = LS_TMP-ZMESSAGE
              TABLES
                OT_HTAB               = LT_HTAB
              EXCEPTIONS
                SYSTEM_FAILURE        = 1
                COMMUNICATION_FAILURE = 2
                ILLEGALNAME           = 3
                OTHERS                = 4.

          WHEN OTHERS.

        ENDCASE.

      CATCH CX_ROOT INTO DATA(LO_ERR).

        LS_TMP-ZERP_STAT = 'E'.
        LS_TMP-ZERP_MESSAGE = LO_ERR->GET_LONGTEXT( ).

*zgtsdt9000 UPDATE
        PERFORM BD_LOG_UPDATE USING LS_TMP.
        CONTINUE.
    ENDTRY.

    IF LS_TMP-ZSTAT NE '00'.
      LS_TMP-ZERP_STAT = 'E'.
      LS_TMP-ZERP_MESSAGE = '제조지시 상태변경 재처리 실패'.
      ADD 1 TO LV_ECNT.
    ELSE.
      LS_TMP-ZERP_STAT = 'S'.
      LS_TMP-ZERP_MESSAGE = '제조지시 상태변경 재처리 성공'.
      ADD 1 TO LV_CNT.
    ENDIF.

    PERFORM BD_LOG_UPDATE USING  LS_TMP.

  ENDLOOP.

  WRITE : /   TEXT-S10, ':', LV_CNT, TEXT-S11, ':', LV_ECNT .
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_IF_RFC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_IF_RFC  USING PV_ID.

  DATA : LT_IFNO TYPE VRM_VALUES.
  IF GT_RFC[] IS NOT INITIAL.
    LOOP AT GT_RFC INTO DATA(LS_RFC) WHERE ZTYPE = 'F'.
      APPEND LS_RFC-ZIFRFC TO LT_IFNO.
    ENDLOOP.
  ELSE.
    APPEND GC_RFC TO LT_IFNO.
  ENDIF.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID     = PV_ID
      VALUES = LT_IFNO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BD_LOG_UPDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_TMP
*&---------------------------------------------------------------------*
FORM BD_LOG_UPDATE  USING    PS_LOG STRUCTURE GS_S0100.

  DATA : LS_9000 TYPE ZGTSDT9000.

  MOVE-CORRESPONDING PS_LOG TO LS_9000.
  LS_9000-ERDAT = SY-DATUM.
  LS_9000-ERZEIT = SY-UZEIT.
  LS_9000-ERNAM = SY-UNAME.
  LS_9000-ERDATLO = SY-DATLO.
  LS_9000-ERTIMLO = SY-TIMLO.
  LS_9000-ERTCODE = SY-TCODE.

  MODIFY ZGTSDT9000 FROM LS_9000.
ENDFORM.
