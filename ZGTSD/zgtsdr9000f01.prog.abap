*&---------------------------------------------------------------------*
*& Include          ZGTSDR0030F01
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

    CASE SCREEN-NAME.
      WHEN 'P_VA02'.
        %_P_VA02_%_APP_%-TEXT = '거부사유 제거'.
*      WHEN 'P_CHK'.
*        %_P_CHK_%_APP_%-TEXT = '수정'.

    ENDCASE.

    CASE SCREEN-GROUP1.
      WHEN 'UU1'.
        CASE SY-UNAME.
          WHEN 'ZGSISD02' OR 'ZGSIDEV05' or 'ZGSISD07' or 'ZGSISD08'.
            SCREEN-ACTIVE = 1.
          WHEN OTHERS.
            SCREEN-ACTIVE = 0.
        ENDCASE.
        MODIFY SCREEN.
    ENDCASE.


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

  IF P_PARA IS NOT INITIAL.
    CASE SY-UNAME.
      WHEN 'ZGSIDEV05' OR 'ZGSISD02' or 'ZGSISD07' or 'ZGSISD08'.
        PERFORM EDIT_PGM.
    ENDCASE.
  ENDIF.

  IF P_VA02 IS NOT INITIAL AND S_VBELN[] IS NOT INITIAL.
    PERFORM CALL_SO_REJECT_RELEASE.
    GV_ERROR = 'X'.
  ENDIF.

*  PERFORM MAKE_MIG_1011.

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

  SELECT * INTO TABLE @DATA(LT_MIG)
    FROM ZGTSDT9062
   WHERE VBELN_O IN @S_VBELN
     AND LOEKZ EQ @SPACE.

  DATA(LT_FOR) = LT_MIG[].
  SORT LT_FOR BY VBELN_O POSNR_O.
  DELETE ADJACENT DUPLICATES FROM LT_FOR COMPARING VBELN_O POSNR_O.
  IF LT_FOR[] IS NOT INITIAL.
    WITH +AMT  AS ( SELECT KNUMV, KPOSN, SUM( KBETR ) AS KBETR
                      FROM PRCD_ELEMENTS
                     WHERE KSCHL = 'ZPR0'
                     GROUP BY KNUMV, KPOSN )
    SELECT B~VBELN AS VBELN_O, B~POSNR AS POSNR_O, B~ZDRUM,
           A~VKBUR, A~VKGRP, A~KUNNR,A~BSTNK, B~MATNR, B~STDAT,
           B~ARKTX, B~WERKS, B~KWMENG, B~VRKME, C~KBETR, B~NETWR,
           B~WAERK, E~BSTKD_E, D~VBELV, D~POSNV,
           F~VBELN_N, POSNR_N, F~STAT, F~LOEKZ, F~JOBNO, F~FLAG
      FROM @LT_FOR AS F INNER JOIN VBAP AS B
        ON F~VBELN_O = B~VBELN
       AND F~POSNR_O = B~POSNR
      INNER JOIN VBAK AS A
        ON A~VBELN = B~VBELN
     INNER JOIN VBKD AS E
        ON B~VBELN = E~VBELN
       AND B~POSNR = E~POSNR
      LEFT OUTER JOIN +AMT AS C
        ON A~KNUMV = C~KNUMV
       AND B~POSNR = C~KPOSN
     LEFT OUTER JOIN VBFA AS D
        ON B~VBELN = D~VBELN
       AND B~POSNR = D~POSNN

      INTO CORRESPONDING FIELDS OF TABLE @GT_S0100.

  ENDIF.

  LOOP AT GT_S0100 INTO GS_S0100.

    IF GS_S0100-VBELN_N IS NOT INITIAL.
      GS_S0100-ICON = ICON_LED_GREEN.
    ELSE.
      GS_S0100-ICON = ICON_LED_INACTIVE.
    ENDIF.

    CASE GS_S0100-WAERK.
      WHEN 'KRW' OR 'JPY' OR 'VND'.
        GS_S0100-KBETR = GS_S0100-KBETR / 100.
    ENDCASE.

    MODIFY GT_S0100 FROM GS_S0100.
  ENDLOOP.

  "데이타 건수 메시지 출력
  IF GT_S0100 IS NOT INITIAL.
    MESSAGE S009 WITH |{ LINES( GT_S0100 ) NUMBER = USER }|. "& 건 검색되었습니다.
  ELSE.
    MESSAGE S010.                                           "조회할 데이타가 없습니다.
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

*  "Split
*  GO_SPLIT = NEW #( PARENT = PO_DCON ROWS = 2 COLUMNS = 1 ).
*
*  GO_CON_TOP       = GO_SPLIT->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
*  DATA(LO_CON_BTT) = GO_SPLIT->GET_CONTAINER( ROW = 2 COLUMN = 1 ).
*
*  GO_SPLIT->SET_ROW_HEIGHT( ID = 1 HEIGHT = 15 ).
*
*  "Create Object
*  GO_DOCU = NEW #( STYLE = 'ALV_GRID' ).  "Top-Of-Page

  PERFORM CREATE_ALV USING    PO_DCON
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
      'S' 'FIELDNAME'   'ICON',
      ' ' 'COLTEXT'     '상태',
      ' ' 'ICON'        'X',
      ' ' 'HOTSPOT'     'X',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'POSNR_O',
      ' ' 'COLTEXT'     'AS-IS S/O 항번',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'VBELN_O',
      ' ' 'COLTEXT'     'AS-IS S/O',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'POSNR_O',
      ' ' 'COLTEXT'     'AS-IS S/O 항번',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'VBELN_N',
      ' ' 'COLTEXT'     'NEW S/O',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

*      'S' 'FIELDNAME'   'POSNR_N',
*      ' ' 'COLTEXT'     'NEW S/O 항번',
*      ' ' 'OUTPUTLEN'   '10',
*      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'VKBUR',
      ' ' 'COLTEXT'     '영업팀',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'VKGRP',
      ' ' 'COLTEXT'     '영업그룹',
      ' ' 'ICON'        'X',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'KUNNR',
      ' ' 'COLTEXT'     '판매처',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'MATNR',
      ' ' 'COLTEXT'     '자재',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'ARKTX',
      ' ' 'COLTEXT'     '오더내역',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'WERKS',
      ' ' 'COLTEXT'     '플랜트',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'KWMENG',
      ' ' 'QFIELDNAME'  'VRKME',
      ' ' 'COLTEXT'     '수량',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'VRKME',
      ' ' 'COLTEXT'     '단위',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'KBETR',
      ' ' 'COLTEXT'     '단가',
      ' ' 'CFIELDNAME'  'WAERK',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'NETWR',
      ' ' 'COLTEXT'     '금액',
      ' ' 'CFIELDNAME'  'WAERK',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'WAERK',
      ' ' 'COLTEXT'     '통화키',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'BSTKD_E',
      ' ' 'COLTEXT'     '제조번호',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'VBELV',
      ' ' 'COLTEXT'     '적송S/O',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'POSNV',
      ' ' 'COLTEXT'     '적송S/O품목',
      'E' 'OUTPUTLEN'   '20'.

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

  LO_TABLE->ADD_COLUMN( EXPORTING WIDTH = '35%' IMPORTING COLUMN = DATA(LO_COL_KEY) ).
  LO_TABLE->ADD_COLUMN( EXPORTING WIDTH = '3%' IMPORTING COLUMN = DATA(LO_COL_SEP) ).
  LO_TABLE->ADD_COLUMN( EXPORTING WIDTH = '62%' IMPORTING COLUMN = DATA(LO_COL_VAL) ).
  LO_TABLE->NEW_ROW( ).

  "Set Column Style
  LO_TABLE->SET_COLUMN_STYLE( COL_NO = 1 SAP_EMPHASIS = CL_DD_DOCUMENT=>STRONG SAP_ALIGN = 'LEFT' ).
  LO_TABLE->SET_COLUMN_STYLE( COL_NO = 3 SAP_EMPHASIS = CL_DD_DOCUMENT=>MEDIUM SAP_ALIGN = 'LEFT' ).

  "Add Text
*  PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE         "영업조직
*                                ZGTSD_P %_P_VKORG_%_APP_%-TEXT P_VKORG.


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

  DATA : LT_MSG TYPE RS_T_MSG.

  CHECK PO_SENDER = GO_GRID. "Main

  CASE PS_COLUMN-FIELDNAME.

    WHEN 'ICON'.

      READ TABLE GT_S0100 INTO DATA(LS_MAIN) INDEX PS_ROW_NO-ROW_ID.
      CHECK SY-SUBRC = 0.
      CHECK LS_MAIN-MSGPOP[] IS NOT INITIAL.
      LT_MSG[] = LS_MAIN-MSGPOP[].

      CALL FUNCTION 'RSDC_SHOW_MESSAGES_POPUP'
        EXPORTING
          I_T_MSG           = LT_MSG
          I_TXT             = '업로드 에러 메세지'
          I_WITH_S_ON_EMPTY = RS_C_TRUE
          I_ONE_MSG_DIRECT  = ''
          I_ONE_MSG_TYPE_S  = RS_C_TRUE.

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
    WHEN 'VBELN_O'.
      CHECK GS_S0100-VBELN_O IS NOT INITIAL.
      SET PARAMETER ID: 'AUN'    FIELD   GS_S0100-VBELN_O.
      CALL TRANSACTION  'VA03' AND SKIP FIRST SCREEN.
    WHEN 'VBELN_N'.
      CHECK GS_S0100-VBELN_N IS NOT INITIAL.
      SET PARAMETER ID: 'AUN'    FIELD   GS_S0100-VBELN_N.
      CALL TRANSACTION  'VA03' AND SKIP FIRST SCREEN.
    WHEN 'VBELV'.
      CHECK GS_S0100-VBELV IS NOT INITIAL.
      SET PARAMETER ID: 'AUN'    FIELD   GS_S0100-VBELV.
      CALL TRANSACTION  'VA03' AND SKIP FIRST SCREEN.
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

*  PERFORM SET_SORT_FIELD USING: PT_SORT 'VBELN' GC_X '' '',
*                                PT_SORT 'UDATE' GC_X '' '',
*                                PT_SORT 'UTIME' GC_X '' ''.

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
*& Form CALL_BAPI_SO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_BAPI_SO .

  DATA : LS_DAT TYPE ZGTSDS0000.

  DATA(LT_DO) = GT_S0100[].
  SORT LT_DO BY BSTKD_E.
  DELETE ADJACENT DUPLICATES FROM LT_DO COMPARING BSTKD_E.
  DELETE LT_DO WHERE ICON NE ICON_LED_INACTIVE.
  IF LT_DO IS INITIAL.
    MESSAGE S015 DISPLAY LIKE GC_E. EXIT.
  ENDIF.

  LOOP AT LT_DO INTO DATA(LS_DO).

    CLEAR GS_S0100.
    READ TABLE GT_S0100 INTO GS_S0100 WITH KEY BSTKD_E = LS_DO-BSTKD_E.
    CHECK SY-SUBRC = 0.


    __CLE : GT_ITEMS_IN, GT_ITEMS_INX, GT_PARTNERS,
            GT_SCH_IN, GT_SCH_INX, GT_COND_IN,
            GT_COND_INX, GT_EXTENSIONIN, GT_CFGS_REF, GT_CFGS_INST,
            GT_CFGS_PART, GT_CFGS_VAL, GT_RETURN.

    CLEAR : GS_HEADER_IN, GS_HEADER_INX, GV_VBELN.

    PERFORM SET_ORDER_HEADER.
    PERFORM SET_ORDER_PARTNERS.
    PERFORM SET_ORDER_ITEMS.

    CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
      EXPORTING
        ORDER_HEADER_IN      = GS_HEADER_IN
        ORDER_HEADER_INX     = GS_HEADER_INX
      IMPORTING
        SALESDOCUMENT        = GV_VBELN
      TABLES
        RETURN               = GT_RETURN
        ORDER_ITEMS_IN       = GT_ITEMS_IN
        ORDER_ITEMS_INX      = GT_ITEMS_INX
        ORDER_PARTNERS       = GT_PARTNERS
        ORDER_SCHEDULES_IN   = GT_SCH_IN
        ORDER_SCHEDULES_INX  = GT_SCH_INX
        ORDER_CONDITIONS_IN  = GT_COND_IN
        ORDER_CONDITIONS_INX = GT_COND_INX.

    IF GV_VBELN IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      GS_S0100-ICON = ICON_LED_RED.
      DELETE GT_RETURN WHERE TYPE NE 'E' AND TYPE NE 'W'.
      GS_S0100-MSGPOP[] = CORRESPONDING #( GT_RETURN[] MAPPING MSGTY = TYPE
                                                               MSGID = ID
                                                               MSGNO = NUMBER
                                                               MSGV1 = MESSAGE_V1
                                                               MSGV2 = MESSAGE_V2
                                                               MSGV3 = MESSAGE_V3
                                                               MSGV4 = MESSAGE_V4 ).
    ELSE.

      GS_S0100-ICON    = ICON_LED_GREEN.
      GS_S0100-VBELN_N = GV_VBELN.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.

      DO 20 TIMES.
        SELECT SINGLE MANDT INTO @SY-MANDT
          FROM VBAK
         WHERE VBELN = @GV_VBELN.
        IF SY-SUBRC NE 0.
          WAIT UP TO '0.5' SECONDS.
        ELSE.

          ZGTSD_CL_COMMON=>SET_TIMESTAMP( EXPORTING IV_GUBUN = ZGTSD_A
                                          CHANGING  CS_TIMESTAMP = LS_DAT ).

          LOOP AT GT_S0100 INTO DATA(LS_S0100) WHERE BSTKD_E = LS_DO-BSTKD_E.

            UPDATE ZGTSDT9062
               SET VBELN_N = GV_VBELN
                   POSNR_N = LS_S0100-POSNR_O
                   AEDAT   = LS_DAT-AEDAT
                   AEZEIT  = LS_DAT-AEZEIT
                   AENAM   = LS_DAT-AENAM
             WHERE VBELN_O = LS_S0100-VBELN_O
               AND POSNR_O = LS_S0100-POSNR_O.
            COMMIT WORK.
          ENDLOOP.
        ENDIF.
      ENDDO.

    ENDIF.

    MODIFY GT_S0100 FROM GS_S0100 TRANSPORTING MSGPOP ICON VBELN_N
     WHERE BSTKD_E = LS_DO-BSTKD_E.
    CLEAR LS_DO.
  ENDLOOP.

  MESSAGE S011.
  "Refresh Grid
  PERFORM REFRESH_TABLE_DISPLAY USING GO_GRID SPACE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ORDER_HEADER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ORDER_HEADER.

  SELECT SINGLE * INTO @DATA(LS_VBAK) FROM VBAK WHERE VBELN = @GS_S0100-VBELN_O.
  SELECT SINGLE * INTO @DATA(LS_VBKD) FROM VBKD WHERE VBELN = @GS_S0100-VBELN_O.

  CLEAR GS_HEADER_IN.
  GS_HEADER_IN-ORDCOMB_IN  = ''.
  GS_HEADER_IN-DOC_TYPE    = LS_VBAK-AUART.    "Sales Document Type
  GS_HEADER_IN-SALES_ORG   = LS_VBAK-VKORG.    "Sales Organization
  GS_HEADER_IN-DISTR_CHAN  = LS_VBAK-VTWEG.    "Distribution Channel
  GS_HEADER_IN-DIVISION    = LS_VBAK-SPART.    "Division
  GS_HEADER_IN-SALES_GRP   = LS_VBAK-VKGRP.    "Sales Group
  GS_HEADER_IN-SALES_OFF   = LS_VBAK-VKBUR.    "Sales Office
  GS_HEADER_IN-REQ_DATE_H  = SY-DATLO."LS_VBAK-VDATU.    "납품요청일
  GS_HEADER_IN-PURCH_DATE  = SY-DATLO."LS_VBAK-BSTDK.    "PO일자
*  GS_HEADER_IN-PURCH_NO_C  = GS_S0100-BSTKD_E.    "영업오더의PO번호(PURCH_NO_C)
  GS_HEADER_IN-PURCH_NO_C  = LS_VBAK-BSTNK..    "영업오더의PO번호(PURCH_NO_C)
  GS_HEADER_IN-PRICE_DATE  = SY-DATLO."LS_VBKD-PRSDT.    "가격결정일
  GS_HEADER_IN-INCOTERMS1  = LS_VBKD-INCO1.    "인코텀스
  GS_HEADER_IN-PMNTTRMS    = LS_VBKD-ZTERM.    "지급조건(코드)
*  GS_HEADER_IN-INCOTERMS2L = LS_VBKD-INCO2_L.  "인도조건(코드)
  GS_HEADER_IN-DOC_DATE    = SY-DATLO.         "'증빙일
  GS_HEADER_IN-CREATED_BY  = LS_VBAK-ERNAM.    "생성자
  GS_HEADER_IN-CURRENCY    = LS_VBAK-WAERK.
  IF LS_VBAK-PS_PSP_PNR IS NOT INITIAL.
    GS_HEADER_IN-WBS_ELEM    = LS_VBAK-PS_PSP_PNR. "작업 분석 구조 요소(WBS 요소)
    GS_HEADER_INX-WBS_ELEM = 'X'.
  ENDIF.

  CALL FUNCTION 'CONVERSION_EXIT_AUART_INPUT'
    EXPORTING
      INPUT  = GS_HEADER_IN-DOC_TYPE
    IMPORTING
      OUTPUT = GS_HEADER_IN-DOC_TYPE.

  CLEAR GS_HEADER_INX.
  GS_HEADER_INX-UPDATEFLAG = 'I'.
  GS_HEADER_INX-ORDCOMB_IN = 'X'.
  GS_HEADER_INX-DOC_TYPE   = 'X'.
  GS_HEADER_INX-SALES_ORG  = 'X'.
  GS_HEADER_INX-DISTR_CHAN = 'X'.
  GS_HEADER_INX-DIVISION   = 'X'.
  GS_HEADER_INX-SALES_GRP  = 'X'.
  GS_HEADER_INX-SALES_OFF  = 'X'.
  GS_HEADER_INX-PURCH_DATE = 'X'.
  GS_HEADER_INX-PURCH_NO_C = 'X'.
  GS_HEADER_INX-REQ_DATE_H = 'X'.
  GS_HEADER_INX-PRICE_DATE  = 'X'.
  GS_HEADER_INX-INCOTERMS1  = 'X'.
  GS_HEADER_INX-PMNTTRMS  = 'X'.
*  GS_HEADER_INX-INCOTERMS2 = = 'X'.
*  GS_HEADER_INX-INCOTERMS2L  = 'X'.
  GS_HEADER_INX-DOC_DATE = 'X'.
*  GS_HEADER_INX-CREATED_BY = 'X'.
  GS_HEADER_INX-CURRENCY = 'X'.

**********************************************************************
*확장 필드 헤더
**********************************************************************
*  CLEAR : GS_BAPE_VBAK, GS_EXTENSIONIN, GS_BAPE_VBAKX, GS_EXTENSIONIN.
*  GS_BAPE_VBAK-CONNO      = LS_VBAK-CONNO.
*
*  GS_BAPE_VBAK-ZPJNO      = LS_VBAK-ZPJNO.
*  GS_BAPE_VBAK-ZCSTAT     = LS_VBAK-ZCSTAT.
*  GS_BAPE_VBAK-ZELOSRT    = LS_VBAK-ZELOSRT.
*  GS_EXTENSIONIN-STRUCTURE  = 'BAPE_VBAK'.
*  GS_EXTENSIONIN-VALUEPART1 = GS_BAPE_VBAK.
*  APPEND GS_EXTENSIONIN TO GT_EXTENSIONIN.
*
*  GS_BAPE_VBAKX-CONNO      = 'X'.
*  GS_BAPE_VBAKX-ZPJNO       = 'X'.
*  GS_BAPE_VBAKX-ZCSTAT       = 'X'.
*  GS_BAPE_VBAKX-ZELOSRT      = 'X'.
*  GS_EXTENSIONIN-STRUCTURE  = 'BAPE_VBAKX'.
*  GS_EXTENSIONIN-VALUEPART1 = GS_BAPE_VBAKX.
*  APPEND GS_EXTENSIONIN TO GT_EXTENSIONIN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ORDER_ITEMS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ORDER_ITEMS .

  DATA : LS_ITEM  TYPE BAPISDITM,
         LS_ITEMX TYPE BAPISDITMX,
         LS_SCH   TYPE BAPISCHDL,
         LS_SCHX  TYPE BAPISCHDLX,
         LS_COND  TYPE BAPICOND,
         LS_CONDX TYPE BAPICONDX.

  SELECT A~*
    INTO TABLE @DATA(LT_VBAP)
    FROM VBAP AS A INNER JOIN VBKD AS B
      ON A~VBELN = B~VBELN
     AND A~POSNR = B~POSNR
   WHERE A~VBELN   = @GS_S0100-VBELN_O
*     AND A~POSNR   = @GS_S0100-POSNR_O
     AND B~BSTKD_E = @GS_S0100-BSTKD_E.

  DATA(LT_ITEM) = GT_S0100[].
  DELETE LT_ITEM WHERE BSTKD_E NE GS_S0100-BSTKD_E.

  LOOP AT LT_ITEM INTO DATA(LS_VBAP).

    CLEAR : LS_ITEM, LS_ITEMX, LS_SCH, LS_SCHX,
            LS_COND, LS_CONDX.

*ITEM
    LS_ITEM-ITM_NUMBER = LS_VBAP-POSNR_O.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT  = LS_VBAP-MATNR
      IMPORTING
        OUTPUT = LS_ITEM-MATERIAL.

    LS_ITEM-PLANT      = LS_VBAP-WERKS.
    LS_ITEM-TARGET_QTY = LS_VBAP-KWMENG.
    LS_ITEM-TARGET_QU  = LS_VBAP-VRKME.
    LS_ITEM-PURCH_NO_S = LS_VBAP-BSTKD_E.
    LS_ITEM-SHORT_TEXT = LS_VBAP-ARKTX.
    LS_ITEM-BATCH      = LS_VBAP-FLAG.

    IF LS_VBAP-STAT IS NOT INITIAL.
      LS_ITEM-STORE_LOC  = '2510'.
    ELSE.
      LS_ITEM-STORE_LOC  = '2550'.
    ENDIF.

    _CUNIT 'I' LS_ITEM-TARGET_QU.
    LS_ITEM-REC_POINT = LS_VBAP-ZDRUM.
    IF GS_HEADER_IN-WBS_ELEM IS NOT INITIAL.
      LS_ITEM-WBS_ELEM  = GS_HEADER_IN-WBS_ELEM. "작업 분석 구조 요소(WBS 요소)
      LS_ITEMX-WBS_ELEM   = 'X'.
    ENDIF.
    APPEND LS_ITEM TO GT_ITEMS_IN.

    LS_ITEMX-ITM_NUMBER = LS_VBAP-POSNR_O.
    LS_ITEMX-MATERIAL   = 'X'.
    LS_ITEMX-PLANT      = 'X'.
    LS_ITEMX-STORE_LOC  = 'X'.
    LS_ITEMX-TARGET_QTY = 'X'.
    LS_ITEMX-TARGET_QU  = 'X'.
    LS_ITEMX-PURCH_NO_S  = 'X'.
    LS_ITEMX-SHORT_TEXT = 'X'.
    LS_ITEMX-BATCH      = 'X'.
    LS_ITEMX-REC_POINT  = 'X'.
    APPEND LS_ITEMX TO GT_ITEMS_INX.

*SCHEDULES
    LS_SCH-ITM_NUMBER = LS_VBAP-POSNR_O.
    LS_SCH-SCHED_LINE = 1.
    LS_SCH-REQ_DATE   = SY-DATLO."LS_VBAP-STDAT.  "품목별 납품요청일
    LS_SCH-REQ_QTY    = LS_VBAP-KWMENG.
    APPEND LS_SCH TO GT_SCH_IN.

    LS_SCHX-ITM_NUMBER = LS_VBAP-POSNR_O.
    LS_SCHX-SCHED_LINE = 1.
    LS_SCHX-REQ_DATE   = 'X'.
    LS_SCHX-REQ_QTY    = 'X'.
    APPEND LS_SCHX TO GT_SCH_INX.

*CONDITION
    LS_COND-ITM_NUMBER  = LS_VBAP-POSNR_O.
    LS_COND-COND_TYPE  = 'ZPR0'.
    CASE LS_VBAP-WAERK.
      WHEN 'KRW' OR 'JPY' OR 'VND'.
        LS_COND-COND_VALUE = LS_VBAP-KBETR * 100.
      WHEN OTHERS.
        LS_COND-COND_VALUE = LS_VBAP-KBETR.
    ENDCASE.

    LS_COND-CURRENCY   = LS_VBAP-WAERK.
    APPEND LS_COND TO GT_COND_IN.

    LS_CONDX-ITM_NUMBER = LS_VBAP-POSNR_O.
    LS_CONDX-COND_TYPE  = 'ZPR0'.
    LS_CONDX-COND_VALUE = 'X'.
    LS_CONDX-CURRENCY   = 'X'.
    APPEND LS_CONDX TO GT_COND_INX.


  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ORDER_PARTNERS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ORDER_PARTNERS .

  DATA : LS_PARTNERS TYPE BAPIPARNR.

  SELECT * INTO TABLE @DATA(LT_VBPA)
    FROM VBPA
   WHERE VBELN = @GS_S0100-VBELN_O.

  LOOP AT LT_VBPA INTO DATA(LS_VBPA).
    CLEAR LS_PARTNERS.

    LS_PARTNERS-PARTN_NUMB  = LS_VBPA-KUNNR.
    LS_PARTNERS-PARTN_ROLE  = LS_VBPA-PARVW.
    PARVW_INPUT  LS_PARTNERS-PARTN_ROLE  LS_PARTNERS-PARTN_ROLE.

    CASE LS_VBPA-PARVW.
      WHEN 'VE'.
        LS_PARTNERS-PARTN_NUMB  = LS_VBPA-LIFNR.
    ENDCASE.
    APPEND LS_PARTNERS TO GT_PARTNERS.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SO_DELETE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SO_DELETE .

  DATA : LV_FLAG         TYPE CHAR01,
         LV_SUBRC        TYPE SY-SUBRC,
         LS_DAT          TYPE ZGTSDS0000,
         LT_TMP          LIKE TABLE OF GS_S0100,
         LS_HEADERX      TYPE BAPISDH1X,
         LS_LOGIC_SWITCH LIKE BAPISDLS,
         LT_RETURN       TYPE ZBAPIRET2TAB,
         LT_ITEM_IN      TYPE CRMT_BAPISDITM_T WITH HEADER LINE,
         LT_ITEM_INX     TYPE CRMT_BAPISDITMX_T WITH HEADER LINE.

  "Selected Rows
  DATA(LT_ROWS) = ZGTSD_CL_COMMON=>GET_SELECTED_ROWS( EXPORTING
                                                        IO_GRID = GO_GRID
                                                        IV_CK   = ZGTSD_X
                                                      IMPORTING
                                                        EV_SUBRC = LV_SUBRC ).
  CHECK LV_SUBRC IS INITIAL.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).

    READ TABLE GT_S0100 INTO GS_S0100 INDEX LS_ROW-INDEX.
    CHECK SY-SUBRC = 0.

    IF GS_S0100-VBELN_N IS INITIAL.
      CONTINUE.
    ENDIF.

    APPEND GS_S0100 TO LT_TMP.
    MODIFY GT_S0100 FROM GS_S0100 INDEX LS_ROW-INDEX.
  ENDLOOP.

  SORT LT_TMP BY VBELN_N.
  DELETE ADJACENT DUPLICATES FROM LT_TMP COMPARING VBELN_N.
  IF LINES( LT_TMP ) = 0.
    MESSAGE S004 DISPLAY LIKE GC_E.EXIT.
  ENDIF.

  LOOP AT LT_TMP INTO DATA(LS_DO).

    CLEAR : LS_HEADERX.
    __CLE : LT_RETURN, LT_ITEM_IN, LT_ITEM_INX.

    LS_HEADERX-UPDATEFLAG = 'D'.

    SELECT VBELN, POSNR INTO TABLE @DATA(LT_VBAP)
      FROM VBAP
     WHERE VBELN = @LS_DO-VBELN_N.

    LOOP AT LT_VBAP INTO DATA(LS_VBAP).
      LT_ITEM_IN-ITM_NUMBER  = LS_VBAP-POSNR.
*    LT_ITEM_IN-REASON_REJ  = SPACE.
      APPEND LT_ITEM_IN. CLEAR LT_ITEM_IN.

      LT_ITEM_INX-ITM_NUMBER   = LS_VBAP-POSNR.  "영업문서품목
      LT_ITEM_INX-UPDATEFLAG = 'D'.
*    LT_ITEM_INX-REASON_REJ = 'X'.
      APPEND LT_ITEM_INX. CLEAR LT_ITEM_INX.
    ENDLOOP.

    CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
      EXPORTING
        SALESDOCUMENT    = LS_DO-VBELN_N
        ORDER_HEADER_INX = LS_HEADERX
      TABLES
        RETURN           = LT_RETURN
        ORDER_ITEM_IN    = LT_ITEM_IN
        ORDER_ITEM_INX   = LT_ITEM_INX.

    CLEAR GS_S0100.
    DESCRIBE TABLE LT_RETURN LINES DATA(LV_COUNT).
    READ TABLE LT_RETURN INTO DATA(LS_RET) INDEX LV_COUNT.
    IF LS_RET-TYPE  =  'S'.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
      DO 10 TIMES.
        SELECT SINGLE MANDT INTO SY-MANDT
          FROM VBAP
         WHERE VBELN = LS_DO-VBELN_N.
*           AND ABGRU = SPACE.
        IF SY-SUBRC NE 0.

          ZGTSD_CL_COMMON=>SET_TIMESTAMP( EXPORTING IV_GUBUN = ZGTSD_A
                                          CHANGING  CS_TIMESTAMP = LS_DAT ).

          LOOP AT GT_S0100 INTO DATA(LS_S0100) WHERE VBELN_N = LS_DO-VBELN_N.

            UPDATE ZGTSDT9062
               SET VBELN_N = SPACE
                   POSNR_N = SPACE
                   AEDAT   = LS_DAT-AEDAT
                   AEZEIT  = LS_DAT-AEZEIT
                   AENAM   = LS_DAT-AENAM
             WHERE VBELN_O = LS_S0100-VBELN_O
               AND POSNR_O = LS_S0100-POSNR_O.
            COMMIT WORK.
          ENDLOOP.

          CLEAR : GS_S0100-VBELN_N, GS_S0100-POSNR_N.
          __CLE : GS_S0100-MSGPOP.
          GS_S0100-ICON = ICON_LED_INACTIVE.
        ELSE.
          WAIT UP TO '0.5' SECONDS.
        ENDIF.
      ENDDO.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      GS_S0100-ICON = ICON_LED_RED.
      DELETE GT_RETURN WHERE TYPE NE 'E' AND TYPE NE 'W'.
      GS_S0100-MSGPOP[] = CORRESPONDING #( GT_RETURN[] MAPPING MSGTY = TYPE
                                                               MSGID = ID
                                                               MSGNO = NUMBER
                                                               MSGV1 = MESSAGE_V1
                                                               MSGV2 = MESSAGE_V2
                                                               MSGV3 = MESSAGE_V3
                                                               MSGV4 = MESSAGE_V4 ).
    ENDIF.

    MODIFY GT_S0100 FROM GS_S0100 TRANSPORTING MSGPOP ICON VBELN_N
     WHERE VBELN_N = LS_DO-VBELN_N.

  ENDLOOP.

  MESSAGE S011.
  "Refresh Grid
  PERFORM REFRESH_TABLE_DISPLAY USING GO_GRID SPACE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EDIT_PGM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EDIT_PGM .

  DATA: BEGIN OF ITAB OCCURS 0,
          LINE(500),
        END OF ITAB.

  DATA: LV_PROGRAM(49).
  LV_PROGRAM = P_PARA.
  IF LV_PROGRAM+0(1)  = 'Z'     OR
     LV_PROGRAM+0(1)  = 'Y'     OR
     LV_PROGRAM+0(5)  = 'SAPMZ' OR
     LV_PROGRAM+0(2)  = 'MZ'    OR
     LV_PROGRAM+0(2)  = 'LZ'.
  ELSE.
    MESSAGE S001(ZSD1) DISPLAY LIKE 'W'
       WITH 'Standard 프로그램 수정은 각별히 주의해 주세요!'.
  ENDIF.

  READ REPORT LV_PROGRAM INTO ITAB.

  EDITOR-CALL FOR ITAB.

*  IF SY-UCOMM = 'WB_SAVE' OR SY-UCOMM = 'YES'.
  IF SY-SUBRC = 0.
    INSERT REPORT LV_PROGRAM FROM ITAB.
  ENDIF.
  GV_ERROR = 'X'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_SO_REJECT_RELEASE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_SO_REJECT_RELEASE .

  DATA : LS_LOG TYPE ZSDS_LOG_0000,
         LS_RET TYPE ZSDS_LOG_0001,
         LT_TAB TYPE TABLE OF ZGTSDSIF0009 WITH HEADER LINE.

  SELECT ZSEQNO, VBELN, APPROVED_STATUS,
         ERNAM AS APPROVER_ID, ERNAM AS APPROVED_BY
    FROM ZGTSDT1013
   WHERE VBELN IN @S_VBELN
     AND APPROVED_STATUS NE 'C'
     AND ZSEQNO = ( SELECT MAX( ZSEQNO ) FROM ZGTSDT1013
                     WHERE VBELN IN @S_VBELN
                       AND APPROVED_STATUS NE 'C' )
    INTO CORRESPONDING FIELDS OF TABLE @LT_TAB..

  CHECK LT_TAB[] IS NOT INITIAL.
  DATA(LT_BACK) = LT_TAB[].

  LOOP AT LT_TAB.
    UPDATE ZGTSDT1013 SET APPROVED_STATUS = 'P'
     WHERE ZSEQNO = LT_TAB-ZSEQNO
       AND VBELN = LT_TAB-VBELN.

    LS_LOG-ENAME = LT_TAB-APPROVER_ID.
    LS_LOG-SAPID = LT_TAB-APPROVED_BY.
    LT_TAB-APPROVED_STATUS = 'C'.
    MODIFY LT_TAB.
  ENDLOOP.
  COMMIT WORK.

  CALL FUNCTION 'ZGTSD_IF_I_SO_REJECT_RELEASE'
    EXPORTING
      IS_D365_LOGIN = LS_LOG
      I_STATUS      = 'C'
    IMPORTING
      ES_RETURN     = LS_RET
    TABLES
      IT_TAB        = LT_TAB.

  IF LS_RET-MTYPE = 'E'.
    MESSAGE S000 WITH '거부사유 해제 실패 하였습니다.' DISPLAY LIKE ZGTSD_E..
    LOOP AT LT_BACK INTO DATA(LS_BACK).

      UPDATE ZGTSDT1013 SET APPROVED_STATUS = LS_BACK-APPROVED_STATUS
       WHERE ZSEQNO = LS_BACK-ZSEQNO
         AND VBELN = LS_BACK-VBELN.

    ENDLOOP.
    COMMIT WORK.
  ELSE.
    MESSAGE S000 WITH '거부사유 해제 되었습니다.' .
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_MIG_1011
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_MIG_1011 .

  WITH +BASE AS ( SELECT MAX( ZSEQNO ) AS ZSEQNO, VBELN
                    FROM ZGTSDT1011
                   WHERE VBELN IN @S_VBELN
                   GROUP BY VBELN )

  SELECT DISTINCT A~*, B~ZSEQNO AS ZSEQNO,
         'V' AS TRTYP
    FROM ZGTSDT1011 AS A INNER JOIN +BASE AS B
      ON A~ZSEQNO = B~ZSEQNO
     AND A~VBELN  = B~VBELN
     AND A~APPROVED_STATUS NOT IN ('A', 'C')
    INTO TABLE @DATA(LT_VB).


ENDFORM.
