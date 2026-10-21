*&---------------------------------------------------------------------*
*&  Include           ZNFR2670F01
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  CREATE_OBJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_OBJECT .

* Create Object : GRF_CONTAINER
  CREATE OBJECT GRF_CONTAINER_T
    EXPORTING
      CONTAINER_NAME = GRF_CONTAINER_NAME_T.

  CREATE OBJECT GRF_CONTAINER_B
    EXPORTING
      CONTAINER_NAME = GRF_CONTAINER_NAME_B.

* Create Object : GRF_GRID
  CREATE OBJECT GRF_GRID_T
    EXPORTING
      I_PARENT      = GRF_CONTAINER_T
      I_APPL_EVENTS = 'X'.

  CREATE OBJECT GRF_GRID_B
    EXPORTING
      I_PARENT      = GRF_CONTAINER_B
      I_APPL_EVENTS = 'X'.

ENDFORM.                    " CREATE_OBJECT

*&---------------------------------------------------------------------*
*&      Form  CREATE_OBJECT_F
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_OBJECT_F.

* Create Object : GRF_CONTAINER
  CREATE OBJECT GRF_CONTAINER_F
    EXPORTING
      CONTAINER_NAME = GRF_CONTAINER_NAME_F.

* Create Object : GRF_GRID
  CREATE OBJECT GRF_GRID_F
    EXPORTING
      I_PARENT      = GRF_CONTAINER_F
      I_APPL_EVENTS = 'X'.

ENDFORM.                    " CREATE_OBJECT_F

*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_TB_FUNCTIONS_T
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_EXCLUDE  text
*----------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS_T CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.

  DATA : LS_EXCLUDE TYPE UI_FUNC.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.

ENDFORM.                    " EXCLUDE_TB_FUNCTIONS_T

*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_TB_FUNCTIONS_B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_EXCLUDE  text
*----------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS_B CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.

  DATA : LS_EXCLUDE TYPE UI_FUNC.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.

ENDFORM.                    " EXCLUDE_TB_FUNCTIONS_B

*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_TB_FUNCTIONS_F
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_EXCLUDE  text
*----------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS_F CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.

  DATA : LS_EXCLUDE TYPE UI_FUNC.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.

ENDFORM.                    " EXCLUDE_TB_FUNCTIONS_F

*&---------------------------------------------------------------------*
*&      Form  SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_LAYOUT .

  GS_LAYOUT_T-SEL_MODE   = 'A'.
  GS_LAYOUT_T-ZEBRA      = 'X'.
*  GS_LAYOUT_T-CWIDTH_OPT = 'X'.
  GS_LAYOUT_T-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT_T-NO_ROWINS  = 'X'.

  GS_LAYOUT_B-SEL_MODE   = 'A'.
  GS_LAYOUT_B-ZEBRA      = 'X'.
*  GS_LAYOUT_B-CWIDTH_OPT = 'X'.
  GS_LAYOUT_B-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT_B-NO_ROWINS  = 'X'.

ENDFORM.                    " SET_GRID_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  SET_GRID_LAYOUT_F
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_LAYOUT_F.

  GS_LAYOUT_F-SEL_MODE   = 'A'.
  GS_LAYOUT_F-ZEBRA      = 'X'.
*  GS_LAYOUT_F-CWIDTH_OPT = 'X'.
  GS_LAYOUT_F-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT_F-NO_ROWINS  = 'X'.

ENDFORM.                    " SET_GRID_LAYOUT_F

*&---------------------------------------------------------------------*
*&      Form  SET_GRID_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_SORT .

  CLEAR : GS_SORT_T, GT_SORT_T.
  REFRESH GT_SORT_T.

*  GS_SORT_T-SPOS = 1.
*  GS_SORT_T-FIELDNAME = 'NFUTN'.
*  GS_SORT_T-UP = 'X'.
*  GS_SORT_T-COMP = 'X'.
*  GS_SORT_T-SUBTOT = 'X'.
*  APPEND GS_SORT_T TO GT_SORT_T.

  CLEAR : GS_SORT_B, GT_SORT_B.
  REFRESH GT_SORT_B.

*  GS_SORT_B-SPOS = 1.
*  GS_SORT_B-FIELDNAME = 'FCM'.
*  GS_SORT_B-UP = 'X'.
*  GS_SORT_B-COMP = 'X'.
*  GS_SORT_B-SUBTOT = 'X'.
*  APPEND GS_SORT_B TO GT_SORT_B.

ENDFORM.                    " SET_GRID_SORT

*&---------------------------------------------------------------------*
*&      Form  SET_GRID_SORT_F
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_SORT_F.

  CLEAR : GS_SORT_F, GT_SORT_F.
  REFRESH GT_SORT_F.

*  GS_SORT_F-SPOS = 1.
*  GS_SORT_F-FIELDNAME = 'FCM'.
*  GS_SORT_F-UP = 'X'.
*  GS_SORT_F-COMP = 'X'.
*  GS_SORT_F-SUBTOT = 'X'.
*  APPEND GS_SORT_F TO GT_SORT_F.

ENDFORM.                    " SET_GRID_SORT_F

*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_FIELDCATALOG .

  PERFORM SET_FIELDCAT_T USING:
    'NFKEY'    '비철구분'       '6'    'C'   ' '     ,
    'CASE1'    'Case 1'         '12'   'R'   ' '     ,
    'CASE2'    'Case 2'         '12'   'R'   ' '     ,
    'CASE3'    'Case 3'         '12'   'R'   ' '     ,
    'CASE4'    'Case 4'         '12'   'R'   ' '     ,
    'CASE5'    'Case 5'         '12'   'R'   ' '     ,
    'CASE6'    'Case 6'         '12'   'R'   ' '     ,
    'WAERS'    '통화'           '5'    'C'   ' '     .

  PERFORM SET_FIELDCAT_B USING:
    'BUKRS'    '회사코드'         '10'   'C'   ' '     ,
    'FCM'      'FCM'              '5'    'C'   'ALPHA' ,
    'FCM_NM'   'FCM명'            '35'   'L'   ' '     ,
    'CREDT'    '설정 Credit'      '10'   'R'   ' '     ,
    'CASE1'    'Case 1'           '12'   'R'   ' '     ,
    'CASE2'    'Case 2'           '12'   'R'   ' '     ,
    'CASE3'    'Case 3'           '12'   'R'   ' '     ,
    'CASE4'    'Case 4'           '12'   'R'   ' '     ,
    'CASE5'    'Case 5'           '12'   'R'   ' '     ,
    'CASE6'    'Case 6'           '12'   'R'   ' '     ,
    'WAERS'    '통화'             '5'    'C'   ' '     .

ENDFORM.                    " SET_GRID_FIELDCATALOG

*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT_T
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_T  USING  P_FIELDNAME
                          P_COLTEXT
                          P_OUTPUTLEN
                          P_JUST
                          P_CONVEXIT.

  CLEAR GS_FIELDCAT_T.

  GS_FIELDCAT_T-FIELDNAME  = P_FIELDNAME .
  GS_FIELDCAT_T-COLTEXT    = P_COLTEXT   .
  GS_FIELDCAT_T-OUTPUTLEN  = P_OUTPUTLEN .
  GS_FIELDCAT_T-JUST       = P_JUST      .
  GS_FIELDCAT_T-CONVEXIT   = P_CONVEXIT  .

  CASE P_FIELDNAME.
    WHEN 'CASE1' OR 'CASE2' OR 'CASE3' OR
         'CASE4' OR 'CASE5' OR 'CASE6'.
      GS_FIELDCAT_T-REF_TABLE  = 'ZNFT1080'.
      GS_FIELDCAT_T-REF_FIELD  = 'CREDT'.
      GS_FIELDCAT_T-CFIELDNAME = 'WAERS'.
      GS_FIELDCAT_T-EDIT       = 'X'.
    WHEN 'WAERS'.
*      GS_FIELDCAT_T-NO_OUT     = 'X'.
  ENDCASE.
  APPEND GS_FIELDCAT_T TO GT_FIELDCAT_T.

ENDFORM.                    " SET_FIELDCAT_T

*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT_B
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_B  USING  P_FIELDNAME
                          P_COLTEXT
                          P_OUTPUTLEN
                          P_JUST
                          P_CONVEXIT.

  CLEAR GS_FIELDCAT_B.

  GS_FIELDCAT_B-FIELDNAME  = P_FIELDNAME .
  GS_FIELDCAT_B-COLTEXT    = P_COLTEXT   .
  GS_FIELDCAT_B-OUTPUTLEN  = P_OUTPUTLEN .
  GS_FIELDCAT_B-JUST       = P_JUST      .
  GS_FIELDCAT_B-CONVEXIT   = P_CONVEXIT  .

  CASE P_FIELDNAME.
    WHEN 'BUKRS'.
      GS_FIELDCAT_B-NO_OUT     = 'X'.
    WHEN 'CREDT'.
      GS_FIELDCAT_B-REF_TABLE  = 'ZNFT1080'.
      GS_FIELDCAT_B-REF_FIELD  = 'CREDT'.
      GS_FIELDCAT_B-CFIELDNAME = 'WAERS'.
    WHEN 'CASE1' OR 'CASE2' OR 'CASE3' OR
       'CASE4' OR 'CASE5' OR 'CASE6'.
      GS_FIELDCAT_B-REF_TABLE  = 'ZNFT1020'.
      GS_FIELDCAT_B-REF_FIELD  = 'PRICE'.
      GS_FIELDCAT_B-CFIELDNAME = 'WAERS'.
      GS_FIELDCAT_B-DO_SUM     = 'X'.
    WHEN 'WAERS'.
*      GS_FIELDCAT_B-NO_OUT     = 'X'.
  ENDCASE.
  APPEND GS_FIELDCAT_B TO GT_FIELDCAT_B.

ENDFORM.                    " SET_FIELDCAT_B

*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FIELDCATALOG_F
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_FIELDCATALOG_F.

  PERFORM SET_FIELDCAT_F USING:
    'BUKRS'    '회사코드'    '10'   'C'   ' '     ,
    'FCM'      'FCM'         '10'   'C'   'ALPHA' ,
    'FCM_NM'   'FCM명'       '18'   'L'   ' '     ,
    'CREDT'    'Credit'      '10'   'R'   ' '     ,
    'WAERS'    '통화'        '5'    'C'   ' '     .

ENDFORM.                    " SET_GRID_FIELDCATALOG_F

*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT_F
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_F  USING  P_FIELDNAME
                          P_COLTEXT
                          P_OUTPUTLEN
                          P_JUST
                          P_CONVEXIT.

  CLEAR GS_FIELDCAT_F.

  GS_FIELDCAT_F-FIELDNAME  = P_FIELDNAME .
  GS_FIELDCAT_F-COLTEXT    = P_COLTEXT   .
  GS_FIELDCAT_F-OUTPUTLEN  = P_OUTPUTLEN .
  GS_FIELDCAT_F-JUST       = P_JUST      .
  GS_FIELDCAT_F-CONVEXIT   = P_CONVEXIT  .

  CASE P_FIELDNAME.
    WHEN 'BUKRS'.
      GS_FIELDCAT_F-NO_OUT     = 'X'.
    WHEN 'FCM'.
*      GS_FIELDCAT_F-EDIT       = 'X'.
*      GS_FIELDCAT_F-F4AVAILABL = 'X'.
    WHEN 'CREDT'.
      GS_FIELDCAT_F-REF_TABLE  = 'ZNFT1080'.
      GS_FIELDCAT_F-REF_FIELD  = 'CREDT'.
      GS_FIELDCAT_F-CFIELDNAME = 'WAERS'.
      GS_FIELDCAT_F-EDIT       = 'X'.
    WHEN 'WAERS'.
*      GS_FIELDCAT_F-NO_OUT     = 'X'.
  ENDCASE.
  APPEND GS_FIELDCAT_F TO GT_FIELDCAT_F.

ENDFORM.                    " SET_FIELDCAT_F

*&---------------------------------------------------------------------*
*&      Form  SET_CELL_ATTRIBUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE .

* 각 셀의 특성 제어
  DATA : LT_CELLTAB_T TYPE LVC_T_STYL,
         LT_CELLTAB_B TYPE LVC_T_STYL,
         LT_CELLTAB_F TYPE LVC_T_STYL,
         LV_INDEX    TYPE I.

  CLEAR LV_INDEX.
  LOOP AT GT_OUTTAB_T INTO GS_OUTTAB_T.
    LV_INDEX = SY-TABIX.
    REFRESH LT_CELLTAB_T.
    CLEAR GS_OUTTAB_T-CELLTAB.
    INSERT LINES OF LT_CELLTAB_T INTO TABLE GS_OUTTAB_T-CELLTAB.
    MODIFY GT_OUTTAB_T FROM GS_OUTTAB_T INDEX LV_INDEX.
    CLEAR LV_INDEX.
  ENDLOOP.

  CLEAR LV_INDEX.
  LOOP AT GT_OUTTAB_B INTO GS_OUTTAB_B.
    LV_INDEX = SY-TABIX.
    REFRESH LT_CELLTAB_B.
    CLEAR GS_OUTTAB_B-CELLTAB.
    INSERT LINES OF LT_CELLTAB_B INTO TABLE GS_OUTTAB_B-CELLTAB.
    MODIFY GT_OUTTAB_B FROM GS_OUTTAB_B INDEX LV_INDEX.
    CLEAR LV_INDEX.
  ENDLOOP.

ENDFORM.                    " SET_CELL_ATTRIBUTE

*&---------------------------------------------------------------------*
*&      Form  SET_CELL_ATTRIBUTE_F
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_F.

* 각 셀의 특성 제어
  DATA : LT_CELLTAB_F TYPE LVC_T_STYL,
         LV_INDEX    TYPE I.

  CLEAR LV_INDEX.
  LOOP AT GT_OUTTAB_F INTO GS_OUTTAB_F.
    LV_INDEX = SY-TABIX.
    REFRESH LT_CELLTAB_F.
    CLEAR GS_OUTTAB_F-CELLTAB.
    INSERT LINES OF LT_CELLTAB_F INTO TABLE GS_OUTTAB_F-CELLTAB.
    MODIFY GT_OUTTAB_F FROM GS_OUTTAB_F INDEX LV_INDEX.
    CLEAR LV_INDEX.
  ENDLOOP.

ENDFORM.                    " SET_CELL_ATTRIBUTE_F

*&---------------------------------------------------------------------*
*&      Form  SET_EVENT_HANDLER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_EVENT_HANDLER .

* DATA가 변경될 경우
  CALL METHOD GRF_GRID_T->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GRF_GRID_B->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CREATE OBJECT GRF_EVENT_RECEIVER_T.
  SET HANDLER :
    GRF_EVENT_RECEIVER_T->HANDLE_DATA_CHANGED FOR GRF_GRID_T.

  CREATE OBJECT GRF_EVENT_RECEIVER_B.
  SET HANDLER :
    GRF_EVENT_RECEIVER_B->HANDLE_DOUBLE_CLICK FOR GRF_GRID_B.

ENDFORM.                    " SET_EVENT_HANDLER

*&---------------------------------------------------------------------*
*&      Form  SET_EVENT_HANDLER_F
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_EVENT_HANDLER_F.

* DATA가 변경될 경우
  CALL METHOD GRF_GRID_F->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CREATE OBJECT GRF_EVENT_RECEIVER_F.
  SET HANDLER :
    GRF_EVENT_RECEIVER_F->HANDLE_DATA_CHANGED FOR GRF_GRID_F,
    GRF_EVENT_RECEIVER_F->HANDLE_ON_F4        FOR GRF_GRID_F.

ENDFORM.                    " SET_EVENT_HANDLER_F

*&---------------------------------------------------------------------*
*&      Form  SET_F4_HELP_REGISTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_F4_HELP_REGISTER .

  CLEAR   : GS_F4_T.  REFRESH : GT_F4_T.

** FieldName별 소트해서 APPEND
*  GS_F4_T-FIELDNAME = 'CONNO'.
*  GS_F4_T-REGISTER  = 'X'.
*  APPEND GS_F4_T TO GT_F4_T.
*
*  CALL METHOD GRF_GRID_T->REGISTER_F4_FOR_FIELDS
*    EXPORTING
*      IT_F4 = GT_F4_T.

  CLEAR   : GS_F4_B.  REFRESH : GT_F4_B.

** FieldName별 소트해서 APPEND
*  GS_F4_B-FIELDNAME = 'CONNO'.
*  GS_F4_B-REGISTER  = 'X'.
*  APPEND GS_F4_B TO GT_F4_B.
*
*  CALL METHOD GRF_GRID_B->REGISTER_F4_FOR_FIELDS
*    EXPORTING
*      IT_F4 = GT_F4_B.

ENDFORM.                    " SET_F4_HELP_REGISTER

*&---------------------------------------------------------------------*
*&      Form  SET_F4_HELP_REGISTER_F
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_F4_HELP_REGISTER_F.

  CLEAR   : GS_F4_F.  REFRESH : GT_F4_F.

* FieldName별 소트해서 APPEND
  GS_F4_F-FIELDNAME = 'FCM'.
  GS_F4_F-REGISTER  = 'X'.
  APPEND GS_F4_F TO GT_F4_F.

  CALL METHOD GRF_GRID_F->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = GT_F4_F.

ENDFORM.                    " SET_F4_HELP_REGISTER_F

*&---------------------------------------------------------------------*
*&      Form  SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_TABLE_FOR_FIRST_DISPLAY .

  GS_VARIANT_T-HANDLE = '0001'.
  GS_VARIANT_T-REPORT = SY-REPID.

  CALL METHOD GRF_GRID_T->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT                    = GS_VARIANT_T
      IS_LAYOUT                     = GS_LAYOUT_T
      I_SAVE                        = 'A'
      I_DEFAULT                     = 'X'
      IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE_T
    CHANGING
      IT_FIELDCATALOG               = GT_FIELDCAT_T
      IT_SORT                       = GT_SORT_T
      IT_OUTTAB                     = GT_OUTTAB_T
      IT_FILTER                     = GT_FILTER_T
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.

  CALL METHOD GRF_GRID_T->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  GS_VARIANT_B-HANDLE = '0002'.
  GS_VARIANT_B-REPORT = SY-REPID.

  CALL METHOD GRF_GRID_B->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT                    = GS_VARIANT_B
      IS_LAYOUT                     = GS_LAYOUT_B
      I_SAVE                        = 'A'
      I_DEFAULT                     = 'X'
      IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE_B
    CHANGING
      IT_FIELDCATALOG               = GT_FIELDCAT_B
      IT_SORT                       = GT_SORT_B
      IT_OUTTAB                     = GT_OUTTAB_B
      IT_FILTER                     = GT_FILTER_B
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.

  CALL METHOD GRF_GRID_B->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY

*&---------------------------------------------------------------------*
*&      Form  SET_TABLE_FOR_FIRST_DISPLAY_F
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_TABLE_FOR_FIRST_DISPLAY_F.

  GS_VARIANT_F-HANDLE = '0001'.
  GS_VARIANT_F-REPORT = SY-REPID.

  CALL METHOD GRF_GRID_F->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT                    = GS_VARIANT_F
      IS_LAYOUT                     = GS_LAYOUT_F
      I_SAVE                        = 'A'
      I_DEFAULT                     = 'X'
      IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE_F
    CHANGING
      IT_FIELDCATALOG               = GT_FIELDCAT_F
      IT_SORT                       = GT_SORT_F
      IT_OUTTAB                     = GT_OUTTAB_F
      IT_FILTER                     = GT_FILTER_F
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.

  CALL METHOD GRF_GRID_F->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.


ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY_F

*&---------------------------------------------------------------------*
*&      Form  SET_INIT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_INIT_DATA.

  IF GV_BUKRS IS INITIAL.
    GV_BUKRS = '1000'.
  ENDIF.

  CONCATENATE SY-DATLO+0(6) '01' INTO GV_FRDAT.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = SY-DATLO
    IMPORTING
      LAST_DAY_OF_MONTH = GV_TODAT.

  PERFORM SET_ENDAT_RANGES.

ENDFORM.                    " SET_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  INIT_NFKEY_PRICE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INIT_NFKEY_PRICE .

  CLEAR GS_OUTTAB_T. REFRESH GT_OUTTAB_T.

  DATA: LS_ZNFT1081 TYPE ZNFT1081.
  DATA: LT_ZNFT1081 TYPE TABLE OF ZNFT1081.

  CLEAR LS_ZNFT1081. REFRESH LT_ZNFT1081.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_ZNFT1081
    FROM ZNFT1081.

  IF SY-SUBRC EQ 0 AND LT_ZNFT1081 IS NOT INITIAL.

    SORT LT_ZNFT1081 BY NFKEY ZCASE.

    CLEAR GS_OUTTAB_T. REFRESH GT_OUTTAB_T.
    LOOP AT LT_ZNFT1081 INTO LS_ZNFT1081.
      GS_OUTTAB_T-NFKEY = LS_ZNFT1081-NFKEY.
      GS_OUTTAB_T-WAERS = LS_ZNFT1081-WAERS.
      CASE  LS_ZNFT1081-ZCASE.
        WHEN '01'.
          GS_OUTTAB_T-CASE1 = LS_ZNFT1081-PRICE.
          CONTINUE.
        WHEN '02'.
          GS_OUTTAB_T-CASE2 = LS_ZNFT1081-PRICE.
          CONTINUE.
        WHEN '03'.
          GS_OUTTAB_T-CASE3 = LS_ZNFT1081-PRICE.
          CONTINUE.
        WHEN '04'.
          GS_OUTTAB_T-CASE4 = LS_ZNFT1081-PRICE.
          CONTINUE.
        WHEN '05'.
          GS_OUTTAB_T-CASE5 = LS_ZNFT1081-PRICE.
          CONTINUE.
        WHEN '06'.
          GS_OUTTAB_T-CASE6 = LS_ZNFT1081-PRICE.
          APPEND GS_OUTTAB_T TO GT_OUTTAB_T.
      ENDCASE.
    ENDLOOP.

  ELSE.

*   ### 비철구분 설정값이 없을경우 Default 값 세팅

    GS_OUTTAB_T-NFKEY = 'CU'.     GS_OUTTAB_T-WAERS = 'USD'.
    APPEND GS_OUTTAB_T TO GT_OUTTAB_T.

    GS_OUTTAB_T-NFKEY = 'AL'.     GS_OUTTAB_T-WAERS = 'USD'.
    APPEND GS_OUTTAB_T TO GT_OUTTAB_T.

    GS_OUTTAB_T-NFKEY = 'PB'.     GS_OUTTAB_T-WAERS = 'USD'.
    APPEND GS_OUTTAB_T TO GT_OUTTAB_T.

    GS_OUTTAB_T-NFKEY = 'NI'.     GS_OUTTAB_T-WAERS = 'USD'.
    APPEND GS_OUTTAB_T TO GT_OUTTAB_T.

*-{기능개선 186891 - 신규 비철 키 SN 추가
    GS_OUTTAB_T-NFKEY = 'SN'.     GS_OUTTAB_T-WAERS = 'USD'.
    APPEND GS_OUTTAB_T TO GT_OUTTAB_T.
*-}기능개선 186891

  ENDIF.

ENDFORM.                    " INIT_NFKEY_PRICE

*&---------------------------------------------------------------------*
*&      Form  ALV_EVENT_DATA_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM ALV_EVENT_DATA_CHANGED USING
            P_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

*  DATA: LS_MOD_CELLS TYPE LVC_S_MODI,
*        LV_INDEX TYPE I,
*        LV_TABIX TYPE I.
*
*  CLEAR LV_INDEX.
*
*  LOOP AT P_DATA_CHANGED->MT_MOD_CELLS INTO LS_MOD_CELLS.
*    LV_INDEX = LS_MOD_CELLS-ROW_ID.
*
**   Data 가공용 Structure
*    READ TABLE GT_OUTTAB_T INTO GS_OUTTAB_T INDEX LV_INDEX.
*
*    IF SY-SUBRC EQ 0.
*      CASE LS_MOD_CELLS-FIELDNAME.
*        WHEN 'CASE1'.
*          GS_OUTTAB_T-CASE1 = LS_MOD_CELLS-VALUE.
*          MODIFY GT_OUTTAB_T FROM GS_OUTTAB_T INDEX LV_INDEX
*                           TRANSPORTING CASE1.
*        WHEN 'CASE2'.
*          GS_OUTTAB_T-CASE2 = LS_MOD_CELLS-VALUE.
*
*          MODIFY GT_OUTTAB_T FROM GS_OUTTAB_T INDEX LV_INDEX
*                           TRANSPORTING CASE2.
*        WHEN 'CASE3'.
*          GS_OUTTAB_T-CASE3 = LS_MOD_CELLS-VALUE.
*
*          MODIFY GT_OUTTAB_T FROM GS_OUTTAB_T INDEX LV_INDEX
*                           TRANSPORTING CASE3.
*        WHEN 'CASE4'.
*          GS_OUTTAB_T-CASE4 = LS_MOD_CELLS-VALUE.
*
*          MODIFY GT_OUTTAB_T FROM GS_OUTTAB_T INDEX LV_INDEX
*                           TRANSPORTING CASE4.
*        WHEN 'CASE5'.
*          GS_OUTTAB_T-CASE5 = LS_MOD_CELLS-VALUE.
*
*          MODIFY GT_OUTTAB_T FROM GS_OUTTAB_T INDEX LV_INDEX
*                           TRANSPORTING CASE5.
*        WHEN 'CASE6'.
*          GS_OUTTAB_T-CASE6 = LS_MOD_CELLS-VALUE.
*
*          MODIFY GT_OUTTAB_T FROM GS_OUTTAB_T INDEX LV_INDEX
*                           TRANSPORTING CASE6.
*      ENDCASE.
*
*      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
*        EXPORTING
*          I_ROW_ID    = LS_MOD_CELLS-ROW_ID
*          I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
*          I_VALUE     = LS_MOD_CELLS-VALUE.
*
*    ENDIF.
*  ENDLOOP.

ENDFORM.                    " ALV_EVENT_DATA_CHANGED

*&---------------------------------------------------------------------*
*&      Form  ALV_EVENT_DATA_CHANGED_FCM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM ALV_EVENT_DATA_CHANGED_FCM USING
            P_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA: LV_FCM      LIKE ZNFT1080-FCM,
        LV_FCM_Y    LIKE ZNFT1080-FCM,
        LV_FCM_NM_Y LIKE LFA1-NAME1.

  DATA: LS_MOD_CELLS TYPE LVC_S_MODI,
        LV_INDEX TYPE I,
        LV_TABIX TYPE I.

  CLEAR: LV_FCM,
         LV_INDEX, LV_TABIX.

  LOOP AT P_DATA_CHANGED->MT_MOD_CELLS INTO LS_MOD_CELLS.
    LV_INDEX = LS_MOD_CELLS-ROW_ID.

*   Data 가공용 Structure
    READ TABLE GT_OUTTAB_F INTO GS_OUTTAB_F INDEX LV_INDEX.

    IF SY-SUBRC EQ 0.
      CASE LS_MOD_CELLS-FIELDNAME.
*        WHEN 'FCM'.
**         이전값
*          LV_FCM_Y    = GS_OUTTAB_F-FCM.
*          LV_FCM_NM_Y = GS_OUTTAB_F-FCM_NM.
*
*          IF LS_MOD_CELLS-VALUE IS NOT INITIAL.
*            LV_FCM = LS_MOD_CELLS-VALUE.
*            PERFORM GET_FCM_CHECK USING GS_OUTTAB_F-BUKRS
*                                        LV_FCM
*                                        GV_ERROR.
*
*            IF GV_ERROR EQ SPACE.
*              GS_OUTTAB_F-STATS = 'S'.
*              GS_OUTTAB_F-FCM = LV_FCM.
*              PERFORM GET_LIFNR_DESC USING GS_OUTTAB_F-FCM
*                                           GS_OUTTAB_F-FCM_NM.
*              MODIFY GT_OUTTAB_F FROM GS_OUTTAB_F INDEX LV_INDEX
*                               TRANSPORTING STATS FCM FCM_NM.
*            ELSE.
*              MESSAGE I003 DISPLAY LIKE 'E'
*                 WITH LS_MOD_CELLS-VALUE '는 잘못된 FCM번호 입니다.'.
*
*              CALL METHOD P_DATA_CHANGED->MODIFY_CELL
*                EXPORTING
*                  I_ROW_ID    = LS_MOD_CELLS-ROW_ID
*                  I_FIELDNAME = 'FCM'
*                  I_VALUE     = LV_FCM_Y.
*
*              CALL METHOD P_DATA_CHANGED->MODIFY_CELL
*                EXPORTING
*                  I_ROW_ID    = LS_MOD_CELLS-ROW_ID
*                  I_FIELDNAME = 'FCM_NM'
*                  I_VALUE     = LV_FCM_NM_Y.
*
*              EXIT.
*            ENDIF.
*          ENDIF.
        WHEN 'CREDT'.
          IF LS_MOD_CELLS-VALUE IS NOT INITIAL.
            GS_OUTTAB_F-STATS = 'S'.
            MODIFY GT_OUTTAB_F FROM GS_OUTTAB_F INDEX LV_INDEX
                             TRANSPORTING STATS CREDT.
*          ELSE.
*            IF GS_OUTTAB_F-CREDT IS INITIAL.
*              GS_OUTTAB_F-STATS = SPACE.
*            ENDIF.
*            MODIFY GT_OUTTAB_F FROM GS_OUTTAB_F INDEX LV_INDEX
*                             TRANSPORTING STATS CREDT.
          ENDIF.

*        CALL METHOD P_DATA_CHANGED->MODIFY_CELL
*          EXPORTING
*            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
*            I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
*            I_VALUE     = LS_MOD_CELLS-VALUE.

      ENDCASE.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " ALV_EVENT_DATA_CHANGED_FCM

*&---------------------------------------------------------------------*
*&      Form  ALV_EVENT_ON_F4_FCM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SENDER  text
*      -->P_E_FIELDNAME  text
*      -->P_E_FIELDVALUE  text
*      -->P_ES_ROW_NO  text
*      -->P_ER_EVENT_DATA  text
*      -->P_ET_BAD_CELLS  text
*      -->P_E_DISPLAY  text
*----------------------------------------------------------------------*
FORM ALV_EVENT_ON_F4_FCM USING     SENDER TYPE REF TO CL_GUI_ALV_GRID
                            E_FIELDNAME   TYPE LVC_FNAME
                            E_FIELDVALUE  TYPE LVC_VALUE
                            ES_ROW_NO     TYPE LVC_S_ROID
                            ER_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                            ET_BAD_CELLS  TYPE LVC_T_MODI
                            E_DISPLAY     TYPE CHAR01.

  DATA: LV_INDEX TYPE SY-INDEX.

  CASE E_FIELDNAME.
    WHEN 'FCM'.
      LV_INDEX = ES_ROW_NO-ROW_ID.
      READ TABLE GT_OUTTAB_F INTO GS_OUTTAB_F INDEX LV_INDEX.
      IF SY-SUBRC EQ 0.
        PERFORM F4HELP_FCM USING GS_OUTTAB_F-FCM.
        IF GS_OUTTAB_F-FCM IS NOT INITIAL.
          CLEAR GV_ERROR.
          IF GS_OUTTAB_F-STATS NE 'I'.
            GS_OUTTAB_F-STATS = 'S'.
          ENDIF.
          PERFORM GET_LIFNR_DESC USING GS_OUTTAB_F-FCM
                                       GS_OUTTAB_F-FCM_NM.
          MODIFY GT_OUTTAB_F FROM GS_OUTTAB_F INDEX LV_INDEX
                           TRANSPORTING FCM FCM_NM.
        ENDIF.
      ENDIF.
  ENDCASE.

  ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.

ENDFORM.                    " ALV_EVENT_ON_F4_FCM

*&---------------------------------------------------------------------*
*&      Form  GET_FCM_CREDIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_FCM_CREDIT .

  CLEAR GS_OUTTAB_B. REFRESH GT_OUTTAB_B.

  DATA: BEGIN OF LS_OUTTAB_NF,            " BOTTOM
          BUKRS    LIKE ZNFT1020-BUKRS ,
          FCM      LIKE ZNFT1020-FCM   ,
          NFKEY    LIKE ZNFT1020-NFKEY ,
          BY_SL    LIKE ZNFT1020-BY_SL ,
          PRICE    LIKE ZNFT1020-PRICE ,
          MISPD    LIKE ZNFT1020-MISPD ,
          WAERS    LIKE ZNFT1020-WAERS ,
          EMENG    LIKE ZNFT1020-EMENG ,
          MEINS    LIKE ZNFT1020-MEINS ,
          AMOUNT   LIKE ZNFT1020-PRICE ,
          CASE1    LIKE ZNFT1020-PRICE , " Case 1 - NFKEY별 선물평가손익
          CASE2    LIKE ZNFT1020-PRICE , " Case 2 - NFKEY별 선물평가손익
          CASE3    LIKE ZNFT1020-PRICE , " Case 3 - NFKEY별 선물평가손익
          CASE4    LIKE ZNFT1020-PRICE , " Case 4 - NFKEY별 선물평가손익
          CASE5    LIKE ZNFT1020-PRICE , " Case 5 - NFKEY별 선물평가손익
          CASE6    LIKE ZNFT1020-PRICE , " Case 6 - NFKEY별 선물평가손익
        END OF LS_OUTTAB_NF.
  DATA: LT_OUTTAB_NF LIKE TABLE OF LS_OUTTAB_NF.

  DATA: LT_OUTTAB_NF_T LIKE TABLE OF LS_OUTTAB_NF,
        LT_OUTTAB_NF1  LIKE TABLE OF LS_OUTTAB_NF,
        LT_OUTTAB_NF2  LIKE TABLE OF LS_OUTTAB_NF.

  DATA: BEGIN OF LS_OUTTAB_B,            " BOTTOM
          BUKRS    LIKE ZNFT1020-BUKRS ,
          FCM      LIKE ZNFT1020-FCM   ,
          FCM_NM   LIKE LFA1-NAME1     ,
          CREDT    LIKE ZNFT1080-CREDT , " Credit
          CASE1    LIKE ZNFT1020-PRICE ,                    " Case 1
          CASE2    LIKE ZNFT1020-PRICE ,                    " Case 2
          CASE3    LIKE ZNFT1020-PRICE ,                    " Case 3
          CASE4    LIKE ZNFT1020-PRICE ,                    " Case 4
          CASE5    LIKE ZNFT1020-PRICE ,                    " Case 5
          CASE6    LIKE ZNFT1020-PRICE ,                    " Case 6
          WAERS    LIKE ZNFT1020-WAERS , "
        END OF LS_OUTTAB_B.
  DATA: LT_OUTTAB_B LIKE TABLE OF LS_OUTTAB_B.

  DATA: LV_TABIX TYPE SY-TABIX.

  DATA: LV_CREDT TYPE ZCREDT,
        LV_T_AMT TYPE ZCREDT.

  CLEAR   : GR_FCM, LS_OUTTAB_NF.
  REFRESH : GR_FCM, LT_OUTTAB_NF, LT_OUTTAB_NF1, LT_OUTTAB_NF2.

*.ZNFT0021(선물거래처관리) 수수료가 '0'인 FCM은 사용하지 않는 것으로
* 간주하고 시뮬레이션 대상에서 제외함(Req.by 구영헌C)
  SELECT Z1~FCM AS LOW
    INTO CORRESPONDING FIELDS OF TABLE GR_FCM
    FROM ZNFT1080 AS Z1
   INNER JOIN ZNFT0021 AS Z2
      ON Z2~BUKRS EQ Z1~BUKRS
     AND Z2~LIFNR EQ Z1~FCM
   WHERE Z1~BUKRS  EQ GV_BUKRS
     AND Z2~FEERT1 NE 0.

  IF SY-SUBRC = 0.
    GR_FCM-SIGN   = 'I'.
    GR_FCM-OPTION = 'EQ'.

    MODIFY GR_FCM TRANSPORTING SIGN OPTION
                  WHERE LOW IS NOT INITIAL.
  ELSE.
    MESSAGE I003 DISPLAY LIKE 'E'
       WITH 'FCM별 CREDIT정보가 존재하지 않습니다.'.
    EXIT.
  ENDIF.

* FCM, BY_SL, NFKEY별로 집계 : LT_OUTTAB_NF1 => LT_OUTTAB_NF_T
  SELECT Z1~BUKRS
         Z1~FCM
         Z1~NFKEY
         Z1~BY_SL
         Z1~EMENG
         Z1~MEINS
         Z1~PRICE
         Z1~MISPD
         Z1~WAERS
         INTO CORRESPONDING FIELDS OF TABLE LT_OUTTAB_NF1
    FROM ZNFT1020 AS Z1
   INNER JOIN ZNFT1011 AS Z2
      ON Z2~REQNO EQ Z1~REQNO AND Z2~H_NO1 EQ Z1~H_NO1
   INNER JOIN ZNFT1010 AS Z3
      ON Z3~REQNO EQ Z1~REQNO
   WHERE Z1~FCM   IN GR_FCM
     AND Z1~BUKRS EQ GV_BUKRS
     AND Z1~ENDAT IN GR_ENDAT
     AND Z1~CONFM IN ('3', '7')
     AND Z1~YNCAN EQ SPACE
     AND Z1~YNFIN EQ SPACE
     AND Z1~YNNET EQ SPACE
     AND Z3~RQTYP IN ('1', '2', '3', '5')
     AND Z1~PRICE <> 0.

  IF SY-SUBRC EQ 0 AND LT_OUTTAB_NF1 IS NOT INITIAL.
    CLEAR LS_OUTTAB_NF.
    LOOP AT LT_OUTTAB_NF1 INTO LS_OUTTAB_NF.
      LS_OUTTAB_NF-AMOUNT
        = ( LS_OUTTAB_NF-PRICE + LS_OUTTAB_NF-MISPD )
        * LS_OUTTAB_NF-EMENG.
      APPEND LS_OUTTAB_NF TO LT_OUTTAB_NF_T.
      CLEAR LS_OUTTAB_NF.
    ENDLOOP.
  ENDIF.

* FCM, BY_SL, NFKEY별로 집계 : LT_OUTTAB_NF2 => LT_OUTTAB_NF_T
  SELECT Z1~BUKRS
         Z1~FCM
         Z1~NFKEY
         Z1~BY_SL
         Z1~EMENG
         Z1~MEINS
         Z1~PRICE
         Z1~MISPD
         Z1~WAERS
         INTO CORRESPONDING FIELDS OF TABLE LT_OUTTAB_NF2
    FROM ZNFT1030 AS Z1
         INNER JOIN ZNFT1020 AS Z2
           ON Z2~NFUTN EQ Z1~NFUTN AND Z2~BUKRS EQ Z1~BUKRS
         INNER JOIN ZNFT1011 AS Z3
           ON Z3~REQNO EQ Z2~REQNO AND Z3~H_NO1 EQ Z2~H_NO1
         INNER JOIN ZNFT1010 AS Z4
           ON Z4~REQNO EQ Z2~REQNO
   WHERE Z1~FCM   IN GR_FCM
     AND Z1~BUKRS EQ GV_BUKRS
     AND Z1~ENDAT IN GR_ENDAT
     AND Z1~CONFM IN ('3', '7')
     AND Z1~YNCAN EQ SPACE
     AND Z1~YNFIN EQ SPACE
     AND Z1~YNNET EQ SPACE
     AND Z4~RQTYP IN ('1', '2', '3', '5')
     AND Z1~PRICE <> 0.

  IF SY-SUBRC EQ 0 AND LT_OUTTAB_NF2 IS NOT INITIAL.
    CLEAR LS_OUTTAB_NF.
    LOOP AT LT_OUTTAB_NF2 INTO LS_OUTTAB_NF.
      LS_OUTTAB_NF-AMOUNT
        = ( LS_OUTTAB_NF-PRICE + LS_OUTTAB_NF-MISPD )
        * LS_OUTTAB_NF-EMENG.
      APPEND LS_OUTTAB_NF TO LT_OUTTAB_NF_T.
      CLEAR LS_OUTTAB_NF.
    ENDLOOP.
  ENDIF.

* ---------------------------------------- *
* 취합 및 SUM :
* LT_OUTTAB_NF_T ======> LT_OUTTAB_NF
* ---------------------------------------- *
  IF LT_OUTTAB_NF_T IS NOT INITIAL.
    SORT LT_OUTTAB_NF_T BY FCM NFKEY MEINS WAERS.
    CLEAR LS_OUTTAB_NF.
    LOOP AT LT_OUTTAB_NF_T INTO LS_OUTTAB_NF.
      COLLECT LS_OUTTAB_NF INTO LT_OUTTAB_NF.
    ENDLOOP.
    SORT LT_OUTTAB_NF BY FCM NFKEY MEINS WAERS.
  ENDIF.

* ---------------------------------------- *
* FCM / 비철구분 : 선물평가손익을 계산
* ---------------------------------------- *
  IF LT_OUTTAB_NF IS NOT INITIAL.
    CLEAR LV_TABIX.
    CLEAR LS_OUTTAB_NF.
    LOOP AT LT_OUTTAB_NF INTO LS_OUTTAB_NF.
      LV_TABIX = SY-TABIX.

*     ##### READ : GT_OUTTAB_T #####
      READ TABLE GT_OUTTAB_T INTO GS_OUTTAB_T
        WITH KEY NFKEY = LS_OUTTAB_NF-NFKEY.

      IF LS_OUTTAB_NF-BY_SL EQ 'B'.
*       ### Buy ###
        LS_OUTTAB_NF-CASE1 = ( GS_OUTTAB_T-CASE1 * LS_OUTTAB_NF-EMENG )
                            - LS_OUTTAB_NF-AMOUNT.
        LS_OUTTAB_NF-CASE2 = ( GS_OUTTAB_T-CASE2 * LS_OUTTAB_NF-EMENG )
                            - LS_OUTTAB_NF-AMOUNT.
        LS_OUTTAB_NF-CASE3 = ( GS_OUTTAB_T-CASE3 * LS_OUTTAB_NF-EMENG )
                            - LS_OUTTAB_NF-AMOUNT.
        LS_OUTTAB_NF-CASE4 = ( GS_OUTTAB_T-CASE4 * LS_OUTTAB_NF-EMENG )
                            - LS_OUTTAB_NF-AMOUNT.
        LS_OUTTAB_NF-CASE5 = ( GS_OUTTAB_T-CASE5 * LS_OUTTAB_NF-EMENG )
                            - LS_OUTTAB_NF-AMOUNT.
        LS_OUTTAB_NF-CASE6 = ( GS_OUTTAB_T-CASE6 * LS_OUTTAB_NF-EMENG )
                            - LS_OUTTAB_NF-AMOUNT.
      ELSE.
*       ### Sell ###
        LS_OUTTAB_NF-CASE1 = LS_OUTTAB_NF-AMOUNT
                         - ( GS_OUTTAB_T-CASE1 * LS_OUTTAB_NF-EMENG ).
        LS_OUTTAB_NF-CASE2 = LS_OUTTAB_NF-AMOUNT
                         - ( GS_OUTTAB_T-CASE2 * LS_OUTTAB_NF-EMENG ).
        LS_OUTTAB_NF-CASE3 = LS_OUTTAB_NF-AMOUNT
                         - ( GS_OUTTAB_T-CASE3 * LS_OUTTAB_NF-EMENG ).
        LS_OUTTAB_NF-CASE4 = LS_OUTTAB_NF-AMOUNT
                         - ( GS_OUTTAB_T-CASE4 * LS_OUTTAB_NF-EMENG ).
        LS_OUTTAB_NF-CASE5 = LS_OUTTAB_NF-AMOUNT
                         - ( GS_OUTTAB_T-CASE5 * LS_OUTTAB_NF-EMENG ).
        LS_OUTTAB_NF-CASE6 = LS_OUTTAB_NF-AMOUNT
                         - ( GS_OUTTAB_T-CASE6 * LS_OUTTAB_NF-EMENG ).
      ENDIF.

*      IF LS_OUTTAB_NF-BY_SL EQ 'B'.
**       ### Buy ###
*        LS_OUTTAB_NF-CASE1 = ( GS_OUTTAB_T-CASE1 - LS_OUTTAB_NF-PRICE )
*                             * LS_OUTTAB_NF-EMENG.
*        LS_OUTTAB_NF-CASE2 = ( GS_OUTTAB_T-CASE2 - LS_OUTTAB_NF-PRICE )
*                             * LS_OUTTAB_NF-EMENG.
*        LS_OUTTAB_NF-CASE3 = ( GS_OUTTAB_T-CASE3 - LS_OUTTAB_NF-PRICE )
*                             * LS_OUTTAB_NF-EMENG.
*        LS_OUTTAB_NF-CASE4 = ( GS_OUTTAB_T-CASE4 - LS_OUTTAB_NF-PRICE )
*                             * LS_OUTTAB_NF-EMENG.
*        LS_OUTTAB_NF-CASE5 = ( GS_OUTTAB_T-CASE5 - LS_OUTTAB_NF-PRICE )
*                             * LS_OUTTAB_NF-EMENG.
*        LS_OUTTAB_NF-CASE6 = ( GS_OUTTAB_T-CASE6 - LS_OUTTAB_NF-PRICE )
*                             * LS_OUTTAB_NF-EMENG.
*      ELSE.
**       ### Sell ###
*        LS_OUTTAB_NF-CASE1 = ( LS_OUTTAB_NF-PRICE - GS_OUTTAB_T-CASE1 )
*                             * LS_OUTTAB_NF-EMENG.
*        LS_OUTTAB_NF-CASE2 = ( LS_OUTTAB_NF-PRICE - GS_OUTTAB_T-CASE2 )
*                             * LS_OUTTAB_NF-EMENG.
*        LS_OUTTAB_NF-CASE3 = ( LS_OUTTAB_NF-PRICE - GS_OUTTAB_T-CASE3 )
*                             * LS_OUTTAB_NF-EMENG.
*        LS_OUTTAB_NF-CASE4 = ( LS_OUTTAB_NF-PRICE - GS_OUTTAB_T-CASE4 )
*                             * LS_OUTTAB_NF-EMENG.
*        LS_OUTTAB_NF-CASE5 = ( LS_OUTTAB_NF-PRICE - GS_OUTTAB_T-CASE5 )
*                             * LS_OUTTAB_NF-EMENG.
*        LS_OUTTAB_NF-CASE6 = ( LS_OUTTAB_NF-PRICE - GS_OUTTAB_T-CASE6 )
*                             * LS_OUTTAB_NF-EMENG.
*      ENDIF.

*     ######################################################
*     FCM별 CASE1,2,3,4,5,6 선물평가손익 집계 : LS_OUTTAB_B
      MOVE-CORRESPONDING LS_OUTTAB_NF TO LS_OUTTAB_B.

*     FCM
      PERFORM GET_LIFNR_DESC USING LS_OUTTAB_B-FCM
                                   LS_OUTTAB_B-FCM_NM.

      COLLECT LS_OUTTAB_B INTO LT_OUTTAB_B.
*     ######################################################

      CLEAR: LV_TABIX, LS_OUTTAB_NF, LS_OUTTAB_B.
    ENDLOOP.
  ENDIF.

* --------------------------------
* 설정 Credit & 잔여 Credit 계산
* --------------------------------
  IF LT_OUTTAB_B IS NOT INITIAL.
    LOOP AT LT_OUTTAB_B INTO LS_OUTTAB_B.

*     ### 설정 Credit 가져오기 ###
      SELECT SINGLE CREDT INTO LV_CREDT
        FROM ZNFT1080 AS Z1
             INNER JOIN ZNFT0021 AS Z2
                ON Z2~BUKRS EQ Z1~BUKRS AND Z2~LIFNR EQ Z1~FCM
       WHERE Z1~BUKRS  EQ GV_BUKRS
         AND Z2~FEERT1 NE 0
         AND Z1~FCM    EQ LS_OUTTAB_B-FCM.

      IF SY-SUBRC EQ 0 AND LV_CREDT IS NOT INITIAL.
        MOVE-CORRESPONDING LS_OUTTAB_B TO GS_OUTTAB_B.
        GS_OUTTAB_B-CREDT = LV_CREDT.
*       ### Case - 잔여 Credit ###
        GS_OUTTAB_B-CASE1 = LV_CREDT + GS_OUTTAB_B-CASE1 .
        GS_OUTTAB_B-CASE2 = LV_CREDT + GS_OUTTAB_B-CASE2 .
        GS_OUTTAB_B-CASE3 = LV_CREDT + GS_OUTTAB_B-CASE3 .
        GS_OUTTAB_B-CASE4 = LV_CREDT + GS_OUTTAB_B-CASE4 .
        GS_OUTTAB_B-CASE5 = LV_CREDT + GS_OUTTAB_B-CASE5 .
        GS_OUTTAB_B-CASE6 = LV_CREDT + GS_OUTTAB_B-CASE6 .
      ELSE.
        GS_OUTTAB_B-FCM    = LS_OUTTAB_B-FCM.
        GS_OUTTAB_B-FCM_NM = LS_OUTTAB_B-FCM_NM.
        GS_OUTTAB_B-CREDT  = 0.
*       ### Case - 잔여 Credit ###
        GS_OUTTAB_B-CASE1  = 0 .
        GS_OUTTAB_B-CASE2  = 0 .
        GS_OUTTAB_B-CASE3  = 0 .
        GS_OUTTAB_B-CASE4  = 0 .
        GS_OUTTAB_B-CASE5  = 0 .
        GS_OUTTAB_B-CASE6  = 0 .
        GS_OUTTAB_B-WAERS  = 'USD'.
      ENDIF.
      APPEND GS_OUTTAB_B TO GT_OUTTAB_B.
    ENDLOOP.
  ENDIF.

  IF GT_OUTTAB_B[] IS NOT INITIAL.
    MESSAGE I003 DISPLAY LIKE 'S'
       WITH '시뮬레이션이 완료되었습니다.'.
  ELSE.
    MESSAGE I003 DISPLAY LIKE 'W'
       WITH '시뮬레이션 데이터가 존재하지 않습니다.'.
  ENDIF.

ENDFORM.                    " GET_FCM_CREDIT

*&---------------------------------------------------------------------*
*&      Form  GET_FCM_CREDTI_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_FCM_CREDTI_DATA .

  DATA: LV_TABIX TYPE SY-TABIX.

*  SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB_F
*    FROM ZNFT1080 AS Z1
*         INNER JOIN ZNFT0021 AS Z2
*            ON Z2~BUKRS EQ Z1~BUKRS AND Z2~LIFNR EQ Z1~FCM
*   WHERE Z1~BUKRS  EQ P_BUKRS
*     AND Z2~FEERT1 NE 0.

  SELECT Z1~BUKRS
         LIFNR AS FCM
         Z2~CREDT
         Z2~WAERS
         INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB_F
    FROM ZNFT0021 AS Z1
         LEFT OUTER JOIN ZNFT1080 AS Z2
            ON Z2~BUKRS EQ Z1~BUKRS AND Z2~FCM EQ Z1~LIFNR
   WHERE Z1~BUKRS  EQ GV_BUKRS
     AND Z1~FEERT1 NE 0.


  IF GT_OUTTAB_F IS NOT INITIAL.
    CLEAR GS_OUTTAB_F.
    LOOP AT GT_OUTTAB_F INTO GS_OUTTAB_F.
      LV_TABIX = SY-TABIX.

*     FCM
      PERFORM GET_LIFNR_DESC USING GS_OUTTAB_F-FCM
                                   GS_OUTTAB_F-FCM_NM.

      GS_OUTTAB_F-WAERS = 'USD'.

      MODIFY GT_OUTTAB_F FROM GS_OUTTAB_F INDEX LV_TABIX.
      CLEAR : LV_TABIX, GS_OUTTAB_F.
    ENDLOOP.
    SORT GT_OUTTAB_F BY FCM.
  ENDIF.

ENDFORM.                    " GET_FCM_CREDTI_DATA

*&---------------------------------------------------------------------*
*&      Form  DATA_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_SAVE .

* 강제로 alv_data_changed 이벤트 실행
  CALL METHOD GRF_GRID_F->CHECK_CHANGED_DATA.

  DATA : LS_ZNFT1080 TYPE ZNFT1080,
         LT_ZNFT1080 TYPE TABLE OF ZNFT1080.

  LOOP AT GT_OUTTAB_F INTO GS_OUTTAB_F WHERE STATS NE SPACE.
    MOVE-CORRESPONDING GS_OUTTAB_F TO LS_ZNFT1080.

    SELECT SINGLE * FROM ZNFT1080
     WHERE BUKRS EQ GV_BUKRS
       AND FCM   EQ GS_OUTTAB_F-FCM.

    IF SY-SUBRC EQ 0.
*     ### UPDATE ###
      LS_ZNFT1080-AENAM = SY-UNAME.
      LS_ZNFT1080-AEDAT = SY-DATLO.
      LS_ZNFT1080-AEZET = SY-TIMLO.
    ELSE.
*     ### INSERT ###
      LS_ZNFT1080-ERNAM = SY-UNAME.
      LS_ZNFT1080-ERDAT = SY-DATLO.
      LS_ZNFT1080-ERZET = SY-TIMLO.
      LS_ZNFT1080-AENAM = SY-UNAME.
      LS_ZNFT1080-AEDAT = SY-DATLO.
      LS_ZNFT1080-AEZET = SY-TIMLO.
    ENDIF.
    APPEND LS_ZNFT1080 TO LT_ZNFT1080.
  ENDLOOP.

  IF LT_ZNFT1080 IS NOT INITIAL.
    MODIFY ZNFT1080 FROM TABLE LT_ZNFT1080.
    IF SY-SUBRC EQ 0.
      COMMIT WORK.
      MESSAGE S003 DISPLAY LIKE 'S'
         WITH '데이터 저장에 성공하였습니다.'.
    ELSE.
      ROLLBACK WORK.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '데이터 저장에 실패하였습니다.'.
    ENDIF.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '저장할 데이터가 없습니다.'.
    EXIT.
  ENDIF.

ENDFORM.                    " DATA_SAVE

*&---------------------------------------------------------------------*
*&      Form  DATA_RELOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_RELOAD .

  PERFORM GET_FCM_CREDTI_DATA.

*  GS_STBL_F-ROW = 'X'.
*  GS_STBL_F-COL = 'X'.
*
*  CALL METHOD GRF_GRID_F->REFRESH_TABLE_DISPLAY
*    EXPORTING
*      I_SOFT_REFRESH = ' '
*      IS_STABLE      = GS_STBL_F.     "화면 라인 Refresh

ENDFORM.                    " DATA_RELOAD
*&---------------------------------------------------------------------*
*&      Form  F4HELP_FCM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_OUTTAB_F_FCM  text
*----------------------------------------------------------------------*
FORM F4HELP_FCM  USING PV_FCM.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX, GV_INDEX,
            IT_FIELDS.
  REFRESH : IT_FIELDS.

  DATA: BEGIN OF LS_FCM,
          LIFNR  LIKE ZNFT0021-LIFNR,
          NAME1 LIKE LFA1-NAME1,
        END OF LS_FCM.
  DATA: LT_FCM LIKE TABLE OF LS_FCM.

  SELECT Z1~LIFNR
         L1~NAME1
         INTO CORRESPONDING FIELDS OF TABLE LT_FCM
    FROM ZNFT0021 AS Z1
         LEFT OUTER JOIN LFA1 AS L1
         ON L1~LIFNR EQ Z1~LIFNR
   WHERE BUKRS EQ GV_BUKRS.

  IF SY-SUBRC NE 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH 'FCM 정보가 존재하지 않습니다.'.
    EXIT.
  ENDIF.

* 아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  IT_FIELDS-TABNAME    = 'ZNFT0021'.  IT_FIELDS-FIELDNAME  = 'LIFNR'.
  IT_FIELDS-SELECTFLAG = 'X'.         APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'LFA1'.      IT_FIELDS-FIELDNAME  = 'NAME1'.
  IT_FIELDS-SELECTFLAG = ' '.         APPEND IT_FIELDS.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      SELECTFIELD                  = SELECTFIELD
    IMPORTING
      IND                          = LD_TABIX
      SELECT_VALUE                 = SELECT_VALUE
    TABLES
      FIELDS                       = IT_FIELDS
      FULL_TABLE                   = LT_FCM
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  CLEAR LS_FCM.
  READ TABLE LT_FCM INTO LS_FCM INDEX LD_TABIX.
  IF SY-SUBRC = 0.
    PV_FCM = LS_FCM-LIFNR.
  ENDIF.

ENDFORM.                    " F4HELP_FCM

*&---------------------------------------------------------------------*
*&      Form  GET_FCM_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_OUTTAB_F_BUKRS  text
*      -->P_GS_OUTTAB_F_FCM  text
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM GET_FCM_CHECK  USING  PV_BUKRS
                           PV_FCM
                           PV_ERROR.

  DATA: LS_ZNFT0021 TYPE ZNFT0021.

  CLEAR: PV_ERROR,
         LS_ZNFT0021.

  SELECT SINGLE * INTO LS_ZNFT0021
    FROM ZNFT0021
   WHERE BUKRS EQ PV_BUKRS
     AND LIFNR EQ PV_FCM.

  IF SY-SUBRC EQ 0.
    PV_ERROR = SPACE.
  ELSE.
    PV_ERROR = 'X'.
  ENDIF.

ENDFORM.                    " GET_FCM_CHECK

*&---------------------------------------------------------------------*
*&      Form  DATA_SAVE_NFKEY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_SAVE_NFKEY .

* 강제로 alv_data_changed 이벤트 실행
  CALL METHOD GRF_GRID_T->CHECK_CHANGED_DATA.

*  DATA: BEGIN OF GS_OUTTAB_T,            " TOP
*          NFKEY    LIKE ZNFT1020-NFKEY ,
*          CASE1    LIKE ZNFT1020-PRICE , " Case 1
*          CASE2    LIKE ZNFT1020-PRICE , " Case 2
*          CASE3    LIKE ZNFT1020-PRICE , " Case 3
*          CASE4    LIKE ZNFT1020-PRICE , " Case 4
*          CASE5    LIKE ZNFT1020-PRICE , " Case 5
*          CASE6    LIKE ZNFT1020-PRICE , " Case 6
*          WAERS    LIKE ZNFT1020-WAERS , "
*          CELLTAB  TYPE LVC_T_STYL     , " Cell 단위 수정 스타일
*          COLINFO  TYPE LVC_T_SCOL     , " CELL 색상 지정
*        END OF GS_OUTTAB_T.

  CLEAR GS_ZNFT1081. REFRESH GT_ZNFT1081.

  CLEAR GS_OUTTAB_T.
  LOOP AT GT_OUTTAB_T INTO GS_OUTTAB_T.

    PERFORM MAKE_GT_ZNFT1081 USING '01'
                                   GS_OUTTAB_T-NFKEY
                                   GS_OUTTAB_T-CASE1
                                   GS_OUTTAB_T-WAERS.

    PERFORM MAKE_GT_ZNFT1081 USING '02'
                                   GS_OUTTAB_T-NFKEY
                                   GS_OUTTAB_T-CASE2
                                   GS_OUTTAB_T-WAERS.

    PERFORM MAKE_GT_ZNFT1081 USING '03'
                                   GS_OUTTAB_T-NFKEY
                                   GS_OUTTAB_T-CASE3
                                   GS_OUTTAB_T-WAERS.

    PERFORM MAKE_GT_ZNFT1081 USING '04'
                                   GS_OUTTAB_T-NFKEY
                                   GS_OUTTAB_T-CASE4
                                   GS_OUTTAB_T-WAERS.

    PERFORM MAKE_GT_ZNFT1081 USING '05'
                                   GS_OUTTAB_T-NFKEY
                                   GS_OUTTAB_T-CASE5
                                   GS_OUTTAB_T-WAERS.

    PERFORM MAKE_GT_ZNFT1081 USING '06'
                                   GS_OUTTAB_T-NFKEY
                                   GS_OUTTAB_T-CASE6
                                   GS_OUTTAB_T-WAERS.

  ENDLOOP.

  CHECK GT_ZNFT1081 IS NOT INITIAL.

  MODIFY ZNFT1081 FROM TABLE GT_ZNFT1081.
  IF SY-SUBRC EQ 0.
    COMMIT WORK.
    MESSAGE S003 DISPLAY LIKE 'S'
       WITH '비철가격을 저장하였습니다.'.
    EXIT.
  ELSE.
    ROLLBACK WORK.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '비철가격 저장에 실패하였습니다.'.
    EXIT.
  ENDIF.


  GS_STBL_T-ROW = 'X'.
  GS_STBL_T-COL = 'X'.

  CALL METHOD GRF_GRID_T->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = ' '
      IS_STABLE      = GS_STBL_T.     "화면 라인 Refresh

ENDFORM.                    " DATA_SAVE_NFKEY

*&---------------------------------------------------------------------*
*&      Form  MAKE_GT_ZNFT1081
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_OUTTAB_T_NFKEY  text
*      -->P_3257   text
*      -->P_GS_OUTTAB_T_CASE6  text
*      -->P_GS_OUTTAB_T_WAERS  text
*----------------------------------------------------------------------*
FORM MAKE_GT_ZNFT1081  USING    PV_CASE
                                PV_NFKEY
                                PV_PRICE
                                PV_WAERS.

  CLEAR GS_ZNFT1081.
  GS_ZNFT1081-ZCASE = PV_CASE .
  GS_ZNFT1081-NFKEY = PV_NFKEY.
  GS_ZNFT1081-PRICE = PV_PRICE.
  GS_ZNFT1081-WAERS = PV_WAERS.
  APPEND GS_ZNFT1081 TO GT_ZNFT1081.

ENDFORM.                    " MAKE_GT_ZNFT1081
*&---------------------------------------------------------------------*
*&      Form  DATA_CHECK_FCM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM DATA_CHECK_FCM  USING    PV_ERROR.

  LOOP AT GT_OUTTAB_F INTO GS_OUTTAB_F WHERE STATS NE SPACE.

    IF GS_OUTTAB_F-FCM IS INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH 'FCM 코드를 입력하십시오.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

    IF GS_OUTTAB_F-CREDT IS INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '[' GS_OUTTAB_F-FCM
              '] 코드의 Credit정보를 입력하십시오.'.
      PV_ERROR = 'X'.
      EXIT.
    ELSE.
      IF GS_OUTTAB_F-CREDT < 0.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '[' GS_OUTTAB_F-FCM
                '] 코드의 Credit에 음수값이 입력되었습니다.'.
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ENDIF.

  ENDLOOP.


ENDFORM.                    " DATA_CHECK_FCM
*&---------------------------------------------------------------------*
*&      Form  DATA_DOWNLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_DOWNLOAD .
  DATA : BEGIN OF LT_FILE OCCURS 0,
           TEXT  TYPE STRING,
         END   OF LT_FILE.

  DATA : LV_FILE     TYPE LOCALFILE,
         LV_FILENAME TYPE STRING.

  DATA : TABULATOR_HEX(2) TYPE X VALUE 9,
         TABULATOR TYPE C.

  DATA: LV_CREDT(30),
        LV_CASE1(30),
        LV_CASE2(30),
        LV_CASE3(30),
        LV_CASE4(30),
        LV_CASE5(30),
        LV_CASE6(30).

  CLEAR : LV_FILE.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      MASK             = ',*.xls,*.*.'
      MODE             = 'S'
    IMPORTING
      FILENAME         = LV_FILE
    EXCEPTIONS
      INV_WINSYS       = 01
      NO_BATCH         = 02
      SELECTION_CANCEL = 03
      SELECTION_ERROR  = 04.

  IF LV_FILE IS NOT INITIAL.
    IF LV_FILE NS '.xls'.
      CONCATENATE LV_FILE '.xls' INTO LV_FILE.
    ENDIF.

    LV_FILENAME = LV_FILE.

    CALL METHOD CL_ABAP_CONV_IN_CE=>UCCP
      EXPORTING
        UCCP = TABULATOR_HEX
      RECEIVING
        CHAR = TABULATOR.

    IF GT_OUTTAB_T[] IS INITIAL AND
       GT_OUTTAB_B[] IS INITIAL.
      MESSAGE S001 DISPLAY LIKE 'E'
         WITH '다운로드할 데이터가 없습니다.'.
      EXIT.
    ENDIF.

    CLEAR   : LT_FILE.
    REFRESH : LT_FILE.

*___Download Header 1
    CONCATENATE '비철구분'             TABULATOR
                'Case 1'               TABULATOR
                'Case 2'               TABULATOR
                'Case 3'               TABULATOR
                'Case 4'               TABULATOR
                'Case 5'               TABULATOR
                'Case 6'               TABULATOR
                '통화'
           INTO LT_FILE-TEXT.

    APPEND LT_FILE.

    LOOP AT GT_OUTTAB_T INTO GS_OUTTAB_T.
      WRITE : GS_OUTTAB_T-CASE1 TO LV_CASE1 CURRENCY GS_OUTTAB_T-WAERS
                                            NO-GROUPING,
              GS_OUTTAB_T-CASE2 TO LV_CASE2 CURRENCY GS_OUTTAB_T-WAERS
                                            NO-GROUPING,
              GS_OUTTAB_T-CASE3 TO LV_CASE3 CURRENCY GS_OUTTAB_T-WAERS
                                            NO-GROUPING,
              GS_OUTTAB_T-CASE4 TO LV_CASE4 CURRENCY GS_OUTTAB_T-WAERS
                                            NO-GROUPING,
              GS_OUTTAB_T-CASE5 TO LV_CASE5 CURRENCY GS_OUTTAB_T-WAERS
                                            NO-GROUPING,
              GS_OUTTAB_T-CASE6 TO LV_CASE6 CURRENCY GS_OUTTAB_T-WAERS
                                            NO-GROUPING.

      PERFORM FRONT_SIGN USING : LV_CASE1, LV_CASE2, LV_CASE3,
                                 LV_CASE4, LV_CASE5, LV_CASE6.

      CONDENSE : LV_CASE1, LV_CASE2, LV_CASE3,
                 LV_CASE4, LV_CASE5, LV_CASE6.

      CONCATENATE GS_OUTTAB_T-NFKEY      TABULATOR
                  LV_CASE1               TABULATOR
                  LV_CASE2               TABULATOR
                  LV_CASE3               TABULATOR
                  LV_CASE4               TABULATOR
                  LV_CASE5               TABULATOR
                  LV_CASE6               TABULATOR
                  GS_OUTTAB_T-WAERS
             INTO LT_FILE-TEXT.

      APPEND LT_FILE.
    ENDLOOP.

    DO 3 TIMES.
      CLEAR : LT_FILE.

      APPEND LT_FILE.
    ENDDO.

*___Download Header 2
    CLEAR : LT_FILE.

    CONCATENATE 'FCM'                  TABULATOR
                'FCM 명'               TABULATOR
                '설정 Credit'          TABULATOR
                'Case 1'               TABULATOR
                'Case 2'               TABULATOR
                'Case 3'               TABULATOR
                'Case 4'               TABULATOR
                'Case 5'               TABULATOR
                'Case 6'               TABULATOR
                '통화'
           INTO LT_FILE-TEXT.

    APPEND LT_FILE.

    LOOP AT GT_OUTTAB_B INTO GS_OUTTAB_B.
      WRITE : GS_OUTTAB_B-CREDT TO LV_CREDT CURRENCY GS_OUTTAB_B-WAERS
                                            NO-GROUPING,
              GS_OUTTAB_B-CASE1 TO LV_CASE1 CURRENCY GS_OUTTAB_B-WAERS
                                            NO-GROUPING,
              GS_OUTTAB_B-CASE2 TO LV_CASE2 CURRENCY GS_OUTTAB_B-WAERS
                                            NO-GROUPING,
              GS_OUTTAB_B-CASE3 TO LV_CASE3 CURRENCY GS_OUTTAB_B-WAERS
                                            NO-GROUPING,
              GS_OUTTAB_B-CASE4 TO LV_CASE4 CURRENCY GS_OUTTAB_B-WAERS
                                            NO-GROUPING,
              GS_OUTTAB_B-CASE5 TO LV_CASE5 CURRENCY GS_OUTTAB_B-WAERS
                                            NO-GROUPING,
              GS_OUTTAB_B-CASE6 TO LV_CASE6 CURRENCY GS_OUTTAB_B-WAERS
                                            NO-GROUPING.

      PERFORM FRONT_SIGN USING : LV_CASE1, LV_CASE2, LV_CASE3,
                                 LV_CASE4, LV_CASE5, LV_CASE6,
                                 LV_CREDT.

      CONDENSE : LV_CASE1, LV_CASE2, LV_CASE3,
                 LV_CASE4, LV_CASE5, LV_CASE6,
                 LV_CREDT.

      CONCATENATE GS_OUTTAB_B-FCM        TABULATOR
                  GS_OUTTAB_B-FCM_NM     TABULATOR
                  LV_CREDT               TABULATOR
                  LV_CASE1               TABULATOR
                  LV_CASE2               TABULATOR
                  LV_CASE3               TABULATOR
                  LV_CASE4               TABULATOR
                  LV_CASE5               TABULATOR
                  LV_CASE6               TABULATOR
                  GS_OUTTAB_B-WAERS
             INTO LT_FILE-TEXT.

      APPEND LT_FILE.
    ENDLOOP.

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        FILENAME                        = LV_FILENAME
        FILETYPE                        = 'ASC'
        CODEPAGE                        = '4103'
        WRITE_BOM                       = 'X'
      TABLES
        DATA_TAB                        = LT_FILE
      EXCEPTIONS
        FILE_WRITE_ERROR                = 1
        OTHERS                          = 2.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
    MESSAGE S007.
  ENDIF.

ENDFORM.                    " DATA_DOWNLOAD
*&---------------------------------------------------------------------*
*&      Form  SET_ENDAT_RANGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_ENDAT_RANGES .

  CLEAR   : GR_ENDAT.
  REFRESH : GR_ENDAT.

  IF GV_TODAT IS NOT INITIAL.
    APPEND_RANGES GR_ENDAT 'I' 'BT' GV_FRDAT GV_TODAT.
  ELSEIF GV_FRDAT IS NOT INITIAL.
    APPEND_RANGES GR_ENDAT 'I' 'EQ' GV_FRDAT GV_TODAT.
  ENDIF.

ENDFORM.                    " SET_ENDAT_RANGES
*&---------------------------------------------------------------------*
*&      Form  FRONT_SIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRONT_SIGN  USING    PV_VALUE.

  CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
    CHANGING
      VALUE         = PV_VALUE.

ENDFORM.                    " FRONT_SIGN
