*&---------------------------------------------------------------------*
*& Include          ZGTLER1160F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CREATE_CONTROLS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_CONTROLS .

  G_DOCKING_CONTAINER = NEW #( REPID     = SY-REPID
                               DYNNR     = SY-DYNNR
                               EXTENSION = 500
                               SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_BOTTOM ).
  GRID = NEW #( I_PARENT = G_DOCKING_CONTAINER ).


***--SPLIT
*  G_SPLITTER = NEW #( PARENT = G_DOCKING_CONTAINER ROWS = 2 COLUMNS = 1 ).
*
*  G_SPLITTER->SET_ROW_MODE( MODE = CL_GUI_SPLITTER_CONTAINER=>MODE_ABSOLUTE ).
*  G_SPLITTER->SET_ROW_HEIGHT( ID = 1 HEIGHT = 65 ).
*
*  LCL_PARENT_HTML = G_SPLITTER->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
*  LCL_PARENT_GRID = G_SPLITTER->GET_CONTAINER( ROW = 2 COLUMN = 1 ).
*
*  GRID = NEW #( I_PARENT = LCL_PARENT_GRID ).

*  G_CONTAINER  = G_SPLITTER->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
*  G_CONTAINER2 = G_SPLITTER->GET_CONTAINER( ROW = 2 COLUMN = 1 ).
*
*
*  G_SPLITTER->SET_ROW_MODE( MODE = CL_GUI_SPLITTER_CONTAINER=>MODE_RELATIVE ).
*  G_SPLITTER->SET_ROW_HEIGHT( ID = 1 HEIGHT = 50 ).
*  G_SPLITTER->SET_ROW_HEIGHT( ID = 2 HEIGHT = 50 ).
*
*  GRID  = NEW #( I_PARENT = G_CONTAINER ).
*  GRID2 = NEW #( I_PARENT = L_B_LEFT ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form SET_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EVENT .

  GRID->REGISTER_EDIT_EVENT( EXPORTING I_EVENT_ID =
                                 CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
  GRID->REGISTER_EDIT_EVENT( EXPORTING I_EVENT_ID =
                                 CL_GUI_ALV_GRID=>MC_EVT_ENTER ).

  CREATE OBJECT EVENT_RECEIVER.
*  SET HANDLER EVENT_RECEIVER->HANDLE_TOP_OF_PAGE  FOR GRID.
*  SET HANDLER EVENT_RECEIVER->HANDLE_DOUBLE_CLICK FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK FOR GRID.
*  SET HANDLER EVENT_RECEIVER->HANDLE_DATA_CHANGED_FINISHED FOR GRID.
*  SET HANDLER EVENT_RECEIVER->HANDLE_TOOLBAR      FOR GRID.
*  SET HANDLER EVENT_RECEIVER->HANDLE_USER_COMMAND FOR GRID.
*  SET HANDLER EVENT_RECEIVER->HANDLE_DATA_CHANGED FOR GRID.
*  SET HANDLER EVENT_RECEIVER->HANDLE_ONF4         FOR GRID.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ALV_LAYOUT CHANGING PS_LAYOUT TYPE LVC_S_LAYO.
  PS_LAYOUT-SEL_MODE   = 'A'.
  PS_LAYOUT-ZEBRA      = 'X'.
  PS_LAYOUT-CWIDTH_OPT = 'A'.
*  PS_LAYOUT-STYLEFNAME = 'CELLTAB'.
*  PS_LAYOUT-CTAB_FNAME = 'CELLCOL'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_EXCLUDE
*&---------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS  CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.

  PT_EXCLUDE[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
                          ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                          ( CL_GUI_ALV_GRID=>MC_FC_GRAPH )
                          ( CL_GUI_ALV_GRID=>MC_FC_INFO )
                          ( CL_GUI_ALV_GRID=>MC_FC_DETAIL )
                          ( CL_GUI_ALV_GRID=>MC_FC_REFRESH )
                        ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_VARIANT
*&---------------------------------------------------------------------*
FORM SET_VARIANT  CHANGING PS_VARIANT TYPE DISVARIANT.
  PS_VARIANT-REPORT   = SY-CPROG.
  PS_VARIANT-USERNAME = SY-UNAME.
  PS_VARIANT-HANDLE   = SY-DYNNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIELDCAT_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FIELDCAT_INIT .
  DATA(LO_TABLE) = CAST CL_ABAP_TABLEDESCR( CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( GT_DATA ) ).
  DATA(LO_STRUC) = CAST CL_ABAP_STRUCTDESCR( LO_TABLE->GET_TABLE_LINE_TYPE( ) ).
  DATA(LT_DFIES) = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUC ).

  GT_FIELDCAT = CORRESPONDING #( LT_DFIES MAPPING REF_TABLE = REFTABLE
                                                  REF_FIELD = REFFIELD ).

  DEFINE _FIELDCAT.
    CASE &1-FIELDNAME.
      WHEN &2.
     &1-COLTEXT   = &3.
     &1-CHECKBOX  = &4.
     &1-ICON      = &5.
     &1-HOTSPOT   = &6.
     &1-EDIT      = &7.
     &1-EMPHASIZE = &8.
    ENDCASE.
  END-OF-DEFINITION.


  LOOP AT GT_FIELDCAT ASSIGNING FIELD-SYMBOL(<FS_FCAT>).
*                        FIELDNAME    COLTEXT  CHECKOBX ICON HOTSPOT EDIT EMPHASIZE
    _FIELDCAT :
                <FS_FCAT> 'ERDAT    ' TEXT-F01 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'ERNAM    ' TEXT-F02 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'NAME_TEXT' TEXT-F03 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'CHANGENR ' TEXT-F04 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'DLVRQ    ' TEXT-F05 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'FNAME    ' TEXT-F06 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'DDTEXT   ' TEXT-F07 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'VALUE_OLD' TEXT-F08 ' '      ' '  ' '    ' '   '    '   ,
                <FS_FCAT> 'VALUE_NEW' TEXT-F09 ' '      ' '  ' '    ' '   '    '   .


  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORT .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT .

  S_ERDAT[] = VALUE #( ( SIGN = 'I' OPTION = 'BT' LOW = SY-DATLO+0(6) && '01'  HIGH = SY-DATLO ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
  CLEAR GS_DATA. REFRESH GT_DATA.

  SELECT FROM ZGTSDT9140 AS A INNER JOIN USR21 AS B
                                ON A~ERNAM EQ B~BNAME
                              INNER JOIN ADRP AS C
                            ON B~PERSNUMBER EQ C~PERSNUMBER
         FIELDS A~ERDAT    ,
                A~ERNAM    ,
                A~CHANGENR ,
                A~DLVRQ    ,
                A~FNAME    ,
                A~DDTEXT   ,
                A~VALUE_OLD,
                A~VALUE_NEW,
                C~NAME_TEXT
    WHERE A~ERDAT    IN @S_ERDAT
      AND A~DLVRQ    IN @S_DLVRQ
      AND A~CHANGENR IN @S_CHANG
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.

SORT GT_DATA BY ERDAT ERNAM CHANGENR DLVRQ.

ENDFORM.
