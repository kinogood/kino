*&---------------------------------------------------------------------*
*&  Include           ZNFR2670TOP
*&---------------------------------------------------------------------*

TYPE-POOLS : SLIS.

TABLES : ZNFT1020, ZNFT1030, ZNFT1080.

************************************************************************
* GLOBAL Structure & Internal Table
************************************************************************
DATA: BEGIN OF GS_OUTTAB_T,            " TOP
        NFKEY    LIKE ZNFT1020-NFKEY ,
        CASE1    LIKE ZNFT1080-CREDT , " Case 1
        CASE2    LIKE ZNFT1080-CREDT , " Case 2
        CASE3    LIKE ZNFT1080-CREDT , " Case 3
        CASE4    LIKE ZNFT1080-CREDT , " Case 4
        CASE5    LIKE ZNFT1080-CREDT , " Case 5
        CASE6    LIKE ZNFT1080-CREDT , " Case 6
        WAERS    LIKE ZNFT1080-WAERS , "
        CELLTAB  TYPE LVC_T_STYL     , " Cell 단위 수정 스타일
        COLINFO  TYPE LVC_T_SCOL     , " CELL 색상 지정
      END OF GS_OUTTAB_T.
DATA: GT_OUTTAB_T LIKE TABLE OF GS_OUTTAB_T.

DATA: BEGIN OF GS_OUTTAB_B,            " BOTTOM
        BUKRS    LIKE ZNFT1020-BUKRS ,
        FCM      LIKE ZNFT1020-FCM   ,
        FCM_NM   LIKE LFA1-NAME1     ,
        CREDT    LIKE ZNFT1080-CREDT , " Credit
        CASE1    LIKE ZNFT1020-PRICE , " Case 1
        CASE2    LIKE ZNFT1020-PRICE , " Case 2
        CASE3    LIKE ZNFT1020-PRICE , " Case 3
        CASE4    LIKE ZNFT1020-PRICE , " Case 4
        CASE5    LIKE ZNFT1020-PRICE , " Case 5
        CASE6    LIKE ZNFT1020-PRICE , " Case 6
        WAERS    LIKE ZNFT1020-WAERS , "
        CELLTAB  TYPE LVC_T_STYL     , " Cell 단위 수정 스타일
        COLINFO  TYPE LVC_T_SCOL     , " CELL 색상 지정
      END OF GS_OUTTAB_B.
DATA: GT_OUTTAB_B LIKE TABLE OF GS_OUTTAB_B.

DATA: BEGIN OF GS_OUTTAB_NF,            " BOTTOM : 계산용 IT
        BUKRS    LIKE ZNFT1020-BUKRS ,
        FCM      LIKE ZNFT1020-FCM   ,
        PRICE    LIKE ZNFT1020-PRICE ,
        WAERS    LIKE ZNFT1020-WAERS ,
        EMENG    LIKE ZNFT1020-EMENG ,
        MEINS    LIKE ZNFT1020-MEINS ,
        CELLTAB  TYPE LVC_T_STYL     , " Cell 단위 수정 스타일
        COLINFO  TYPE LVC_T_SCOL     , " CELL 색상 지정
      END OF GS_OUTTAB_NF.
DATA: GT_OUTTAB_NF LIKE TABLE OF GS_OUTTAB_NF.

DATA: BEGIN OF GS_OUTTAB_F,            " SCR 1200
        STATS    TYPE CHAR01         , " 저장관련 FLAG
        BUKRS    LIKE ZNFT1080-BUKRS ,
        FCM      LIKE ZNFT1080-FCM   ,
        FCM_NM   LIKE LFA1-NAME1     ,
        CREDT    LIKE ZNFT1080-CREDT , " Credit
        WAERS    LIKE ZNFT1080-WAERS , " 통화
        CELLTAB  TYPE LVC_T_STYL     , " Cell 단위 수정 스타일
        COLINFO  TYPE LVC_T_SCOL     , " CELL 색상 지정
      END OF GS_OUTTAB_F.
DATA: GT_OUTTAB_F LIKE TABLE OF GS_OUTTAB_F.

DATA: GS_ZNFT1081 TYPE ZNFT1081.
DATA: GT_ZNFT1081 TYPE TABLE OF ZNFT1081.

DATA: GV_BUKRS    LIKE ZNFT1080-BUKRS,
      GV_FRDAT    LIKE SY-DATUM,
      GV_TODAT    LIKE SY-DATUM.

RANGES: GR_ENDAT  FOR  ZNFT1020-ENDAT,
        GR_FCM    FOR  ZNFT1020-FCM.
************************************************************************
* GLOBAL VARIABLE
************************************************************************
DATA: OK_CODE TYPE SY-UCOMM,
      OK_SAVE TYPE SY-UCOMM,
      GV_CODE TYPE SY-UCOMM.

DATA: GV_ANSWER TYPE CHAR01,
      GV_ERROR  TYPE CHAR01.

DATA: GV_WAERS      LIKE T001-WAERS,     "Currency
      GV_LAND1      LIKE T001-LAND1,     "Country
      GV_BUTXT      LIKE T001-BUTXT,     "Company Name
      GV_KTOPL      LIKE T001-KTOPL,     "Chart of Account
      GV_KOKRS      LIKE TKA02-KOKRS.    "Controlling Area

DATA: GV_CNT  TYPE I.

************************************************************************
* F4 Help용 변수
************************************************************************
DATA: SELECTFIELD   LIKE  HELP_INFO-FIELDNAME,
      IT_FIELDS     LIKE  HELP_VALUE OCCURS 1 WITH HEADER LINE,
      SELECT_VALUE  LIKE  HELP_INFO-FLDVALUE,
      LD_TABIX      LIKE  SY-TABIX,
      GV_INDEX      LIKE  SY-INDEX.

DATA: SCR_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE,
      FELD_TABLE LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

************************************************************************
* ALV GLOBAL VARIABLE
************************************************************************
CLASS : LCL_EVT_RECEIVER     DEFINITION DEFERRED,
        LCL_EVT_RECEIVER_FCM DEFINITION DEFERRED.

* ======================================================================
* 비철구분 관련 ALV
* ======================================================================
DATA: GRF_CONTAINER_T      TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GRF_CONTAINER_NAME_T TYPE SCRFNAME VALUE 'CONTAINER_1100T',
      GRF_GRID_T           TYPE REF TO CL_GUI_ALV_GRID,
      GRF_EVENT_RECEIVER_T TYPE REF TO LCL_EVT_RECEIVER.

DATA: GT_EXCLUDE_T  TYPE UI_FUNCTIONS,
      GT_SORT_T     TYPE LVC_T_SORT,  GS_SORT_T     TYPE LVC_S_SORT,
      GT_FIELDCAT_T TYPE LVC_T_FCAT,  GS_FIELDCAT_T TYPE LVC_S_FCAT,
      GS_LAYOUT_T   TYPE LVC_S_LAYO,  GS_VARIANT_T  TYPE DISVARIANT,
      GT_ROWS_T     TYPE LVC_T_ROW,   GS_ROWS_T     TYPE LVC_S_ROW,
      GT_COLS_T     TYPE LVC_T_COL,   GS_COLS_T     TYPE LVC_S_COL,
      GT_F4_T       TYPE LVC_T_F4,    GS_F4_T       TYPE LVC_S_F4,
      GT_CELLTAB_T  TYPE LVC_T_STYL,  GS_CELLTAB_T  TYPE LVC_S_STYL,
      GT_STYL_T     TYPE LVC_T_STYL,  GS_STBL_T     TYPE LVC_S_STBL,
      GT_FILTER_T   TYPE LVC_T_FILT.

* Grid Line variable
DATA: GS_ROW_ID_T TYPE LVC_S_ROW,
      GS_COL_ID_T TYPE LVC_S_COL,
      GS_VALUE_T  TYPE CHAR10.

DATA: GS_ROW_T  TYPE LVC_S_ROW,
      GS_COL_T  TYPE LVC_S_COL,
      GS_ROID_T TYPE LVC_S_ROID.

* ======================================================================
* 시뮬레이션 결과 ALV
* ======================================================================
DATA: GRF_CONTAINER_B      TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GRF_CONTAINER_NAME_B TYPE SCRFNAME VALUE 'CONTAINER_1100B',
      GRF_GRID_B           TYPE REF TO CL_GUI_ALV_GRID,
      GRF_EVENT_RECEIVER_B TYPE REF TO LCL_EVT_RECEIVER.

DATA: GT_EXCLUDE_B  TYPE UI_FUNCTIONS,
      GT_SORT_B     TYPE LVC_T_SORT,  GS_SORT_B     TYPE LVC_S_SORT,
      GT_FIELDCAT_B TYPE LVC_T_FCAT,  GS_FIELDCAT_B TYPE LVC_S_FCAT,
      GS_LAYOUT_B   TYPE LVC_S_LAYO,  GS_VARIANT_B  TYPE DISVARIANT,
      GT_ROWS_B     TYPE LVC_T_ROW,   GS_ROWS_B     TYPE LVC_S_ROW,
      GT_COLS_B     TYPE LVC_T_COL,   GS_COLS_B     TYPE LVC_S_COL,
      GT_F4_B       TYPE LVC_T_F4,    GS_F4_B       TYPE LVC_S_F4,
      GT_CELLTAB_B  TYPE LVC_T_STYL,  GS_CELLTAB_B  TYPE LVC_S_STYL,
      GT_STYL_B     TYPE LVC_T_STYL,  GS_STBL_B     TYPE LVC_S_STBL,
      GT_FILTER_B   TYPE LVC_T_FILT.

* Grid Line variable
DATA: GS_ROW_ID_B TYPE LVC_S_ROW,
      GS_COL_ID_B TYPE LVC_S_COL,
      GS_VALUE_B  TYPE CHAR10.

DATA: GS_ROW_B  TYPE LVC_S_ROW,
      GS_COL_B  TYPE LVC_S_COL,
      GS_ROID_B TYPE LVC_S_ROID.

* ======================================================================
* FCM 관련 ALV
* ======================================================================
DATA: GRF_CONTAINER_F      TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GRF_CONTAINER_NAME_F TYPE SCRFNAME VALUE 'CONTAINER_1200',
      GRF_GRID_F           TYPE REF TO CL_GUI_ALV_GRID,
      GRF_EVENT_RECEIVER_F TYPE REF TO LCL_EVT_RECEIVER_FCM.

DATA: GT_EXCLUDE_F  TYPE UI_FUNCTIONS,
      GT_SORT_F     TYPE LVC_T_SORT,  GS_SORT_F     TYPE LVC_S_SORT,
      GT_FIELDCAT_F TYPE LVC_T_FCAT,  GS_FIELDCAT_F TYPE LVC_S_FCAT,
      GS_LAYOUT_F   TYPE LVC_S_LAYO,  GS_VARIANT_F  TYPE DISVARIANT,
      GT_ROWS_F     TYPE LVC_T_ROW,   GS_ROWS_F     TYPE LVC_S_ROW,
      GT_COLS_F     TYPE LVC_T_COL,   GS_COLS_F     TYPE LVC_S_COL,
      GT_F4_F       TYPE LVC_T_F4,    GS_F4_F       TYPE LVC_S_F4,
      GT_CELLTAB_F  TYPE LVC_T_STYL,  GS_CELLTAB_F  TYPE LVC_S_STYL,
      GT_STYL_F     TYPE LVC_T_STYL,  GS_STBL_F     TYPE LVC_S_STBL,
      GT_FILTER_F   TYPE LVC_T_FILT.

* Grid Line variable
DATA: GS_ROW_ID_F TYPE LVC_S_ROW,
      GS_COL_ID_F TYPE LVC_S_COL,
      GS_VALUE_F  TYPE CHAR10.

DATA: GS_ROW_F  TYPE LVC_S_ROW,
      GS_COL_F  TYPE LVC_S_COL,
      GS_ROID_F TYPE LVC_S_ROID.

*----------------------------------------------------------------------*
*       CLASS lcl_evt_receiver DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER DEFINITION.

  PUBLIC SECTION.
    METHODS : HANDLE_TOOLBAR
                FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
                IMPORTING E_OBJECT
                          E_INTERACTIVE,

              HANDLE_USER_COMMAND
                FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
                IMPORTING E_UCOMM,

              HANDLE_DATA_CHANGED
                FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
                IMPORTING ER_DATA_CHANGED,

              HANDLE_DATA_CHANGED_FINISHED
                FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
                IMPORTING E_MODIFIED
                          ET_GOOD_CELLS,

              HANDLE_HOTSPOT_CLICK
                FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
                IMPORTING E_ROW_ID
                          E_COLUMN_ID,

              HANDLE_DOUBLE_CLICK
                FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
                IMPORTING E_ROW
                          E_COLUMN
                          ES_ROW_NO,

              HANDLE_ON_F4
                FOR EVENT ONF4 OF CL_GUI_ALV_GRID
                IMPORTING SENDER
                          E_FIELDNAME
                          E_FIELDVALUE
                          ES_ROW_NO
                          ER_EVENT_DATA
                          ET_BAD_CELLS
                          E_DISPLAY.

ENDCLASS.  " lcl_evt_receiver
*----------------------------------------------------------------------*
*       CLASS lcl_evt_receiver IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER IMPLEMENTATION.

  METHOD HANDLE_TOOLBAR.
*    perform alv_event_toobar_part using name
*                                        e_object
*                                        e_interactive.
  ENDMETHOD.                    "handle_toolbar

  METHOD HANDLE_USER_COMMAND.
*    perform alv_event_user_command_part using name
*                                    e_ucomm.
  ENDMETHOD.                    "handle_user_command

  METHOD HANDLE_DATA_CHANGED.
    PERFORM ALV_EVENT_DATA_CHANGED USING ER_DATA_CHANGED.
  ENDMETHOD.                    "handle_data_changed

  METHOD HANDLE_DATA_CHANGED_FINISHED.
*    PERFORM ALV_EVENT_DATA_CHG_FINISHED USING E_MODIFIED
*                                              ET_GOOD_CELLS.
  ENDMETHOD.                    "handle_data_changed_finished

  METHOD HANDLE_HOTSPOT_CLICK.
*    perform alv_event_hotspot_click using e_row_id e_column_id.
  ENDMETHOD.                    "handle_hotspot_click

  METHOD HANDLE_DOUBLE_CLICK.
*    PERFORM ALV_EVENT_DOUBLE_CLICK USING E_ROW
*                                         E_COLUMN
*                                         ES_ROW_NO.
  ENDMETHOD.                    "handle_double_click

  METHOD HANDLE_ON_F4.
*    PERFORM ALV_EVENT_ON_F4 USING SENDER
*                                  E_FIELDNAME
*                                  E_FIELDVALUE
*                                  ES_ROW_NO
*                                  ER_EVENT_DATA
*                                  ET_BAD_CELLS
*                                  E_DISPLAY.
  ENDMETHOD.                    "handle_on_f4

ENDCLASS.  " lcl_dvt_receiver

*----------------------------------------------------------------------*
*       CLASS LCL_EVT_RECEIVER_FCM DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_FCM DEFINITION.

  PUBLIC SECTION.
    METHODS : HANDLE_TOOLBAR
                FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
                IMPORTING E_OBJECT
                          E_INTERACTIVE,

              HANDLE_USER_COMMAND
                FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
                IMPORTING E_UCOMM,

              HANDLE_DATA_CHANGED
                FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
                IMPORTING ER_DATA_CHANGED,

              HANDLE_DATA_CHANGED_FINISHED
                FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
                IMPORTING E_MODIFIED
                          ET_GOOD_CELLS,

              HANDLE_HOTSPOT_CLICK
                FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
                IMPORTING E_ROW_ID
                          E_COLUMN_ID,

              HANDLE_DOUBLE_CLICK
                FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
                IMPORTING E_ROW
                          E_COLUMN
                          ES_ROW_NO,

              HANDLE_ON_F4
                FOR EVENT ONF4 OF CL_GUI_ALV_GRID
                IMPORTING SENDER
                          E_FIELDNAME
                          E_FIELDVALUE
                          ES_ROW_NO
                          ER_EVENT_DATA
                          ET_BAD_CELLS
                          E_DISPLAY.

ENDCLASS.  " LCL_EVT_RECEIVER_FCM
*----------------------------------------------------------------------*
*       CLASS LCL_EVT_RECEIVER_FCM IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_FCM IMPLEMENTATION.

  METHOD HANDLE_TOOLBAR.
*    perform alv_event_toobar_part using name
*                                        e_object
*                                        e_interactive.
  ENDMETHOD.                    "handle_toolbar

  METHOD HANDLE_USER_COMMAND.
*    perform alv_event_user_command_part using name
*                                    e_ucomm.
  ENDMETHOD.                    "handle_user_command

  METHOD HANDLE_DATA_CHANGED.
    PERFORM ALV_EVENT_DATA_CHANGED_FCM USING ER_DATA_CHANGED.
  ENDMETHOD.                    "handle_data_changed

  METHOD HANDLE_DATA_CHANGED_FINISHED.
*    PERFORM ALV_EVENT_DATA_CHG_FINISHED USING E_MODIFIED
*                                              ET_GOOD_CELLS.
  ENDMETHOD.                    "handle_data_changed_finished

  METHOD HANDLE_HOTSPOT_CLICK.
*    perform alv_event_hotspot_click using e_row_id e_column_id.
  ENDMETHOD.                    "handle_hotspot_click

  METHOD HANDLE_DOUBLE_CLICK.
*    PERFORM ALV_EVENT_DOUBLE_CLICK USING E_ROW
*                                         E_COLUMN
*                                         ES_ROW_NO.
  ENDMETHOD.                    "handle_double_click

  METHOD HANDLE_ON_F4.
    PERFORM ALV_EVENT_ON_F4_FCM USING SENDER
                                      E_FIELDNAME
                                      E_FIELDVALUE
                                      ES_ROW_NO
                                      ER_EVENT_DATA
                                      ET_BAD_CELLS
                                      E_DISPLAY.
  ENDMETHOD.                    "handle_on_f4

ENDCLASS.  " lcl_dvt_receiver
