*&---------------------------------------------------------------------*
*&  Include           ZNFR2290TOP
*&---------------------------------------------------------------------*

* Tables
TABLES: ZNFT1000,
        ZNFT1020,
        ZNFT1030.

************************************************************************
* GLOBAL Structure & Internal Table
************************************************************************
* ALV LIST
DATA: BEGIN OF GS_OUTTAB,
      CHECK    TYPE CHAR01,
*     -----------------------------------------------------
      BUKRS    LIKE ZNFT1020-BUKRS,
      BUKRS_NM TYPE CHAR10,
      NFUTN    LIKE ZNFT1020-NFUTN,
      FCM      LIKE ZNFT1020-FCM,
      FCM_NM   LIKE LFA1-NAME1,
      RUDAT    LIKE ZNFT1020-RUDAT,
      GUBUN    TYPE CHAR01,
      GUBUN_NM TYPE CHAR04,
      BY_SL    LIKE ZNFT1020-BY_SL,
      BY_SL_NM TYPE CHAR10,
      ENDAT    LIKE ZNFT1020-ENDAT,
      MITYP    LIKE ZNFT1020-MITYP,
      MITYP_NM TYPE CHAR10,
      MISPD    LIKE ZNFT1020-MISPD,
      MIMON    LIKE ZNFT1020-MIMON,
      PRICE    LIKE ZNFT1020-PRICE,
      WAERS    LIKE ZNFT1020-WAERS,
      EMENG    LIKE ZNFT1020-EMENG,
      MEINS    LIKE ZNFT1020-MEINS,
      MISUS    LIKE ZNFT1020-MISUS,
      BIGO4    LIKE ZNFT1020-BIGO4,
*     -----------------------------------------------------
      NFKEY    LIKE ZNFT1030-NFKEY,
*     -----------------------------------------------------
      CELLTAB  TYPE LVC_T_STYL,     " Cell 단위 수정 스타일
      COLINFO  TYPE LVC_T_SCOL.     " CELL 색상 지정
DATA: END OF GS_OUTTAB.
DATA: GT_OUTTAB LIKE TABLE OF GS_OUTTAB.

* ALV LIST
DATA: BEGIN OF GS_OUTTAB_N,
      CHECK    TYPE CHAR01,
*     -----------------------------------------------------
      BUKRS    LIKE ZNFT1020-BUKRS,
      BUKRS_NM TYPE CHAR10,
      NFUTN    LIKE ZNFT1020-NFUTN,
      FCM      LIKE ZNFT1020-FCM,
      FCM_NM   LIKE LFA1-NAME1,
      RUDAT    LIKE ZNFT1020-RUDAT,
      BY_SL    LIKE ZNFT1020-BY_SL,
      ENDAT    LIKE ZNFT1020-ENDAT,
      MITYP    LIKE ZNFT1020-MITYP,
      MISPD    LIKE ZNFT1020-MISPD,
      MIMON    LIKE ZNFT1020-MIMON,
      PRICE    LIKE ZNFT1020-PRICE,
      WAERS    LIKE ZNFT1020-WAERS,
      EMENG    LIKE ZNFT1020-EMENG,
      MEINS    LIKE ZNFT1020-MEINS,
      MISUS    LIKE ZNFT1020-MISUS,
      BIGO4    LIKE ZNFT1020-BIGO4,
*     -----------------------------------------------------
      NFKEY    LIKE ZNFT1020-NFKEY,
      YNCAN    LIKE ZNFT1030-YNCAN,
      CONFM    LIKE ZNFT1030-CONFM,
*     -----------------------------------------------------
      CELLTAB  TYPE LVC_T_STYL,     " Cell 단위 수정 스타일
      COLINFO  TYPE LVC_T_SCOL.     " CELL 색상 지정
DATA: END OF GS_OUTTAB_N.
DATA: GT_OUTTAB_N LIKE TABLE OF GS_OUTTAB_N.

* ALV LIST
DATA: BEGIN OF GS_OUTTAB_C,
      CHECK    TYPE CHAR01,
*     -----------------------------------------------------
      BUKRS    LIKE ZNFT1030-BUKRS,
      BUKRS_NM TYPE CHAR10,
      CFUTN    LIKE ZNFT1030-CFUTN,
      FCM      LIKE ZNFT1030-FCM,
      FCM_NM   LIKE LFA1-NAME1,
      RUDAT    LIKE ZNFT1030-RUDAT,
      BY_SL    LIKE ZNFT1030-BY_SL,
      ENDAT    LIKE ZNFT1030-ENDAT,
      MITYP    LIKE ZNFT1030-MITYP,
      MISPD    LIKE ZNFT1030-MISPD,
      MIMON    LIKE ZNFT1030-MIMON,
      PRICE    LIKE ZNFT1030-PRICE,
      WAERS    LIKE ZNFT1030-WAERS,
      EMENG    LIKE ZNFT1030-EMENG,
      MEINS    LIKE ZNFT1030-MEINS,
      MISUS    LIKE ZNFT1030-MISUS,
      BIGO4    LIKE ZNFT1030-BIGO4,
*     -----------------------------------------------------
      NFKEY    LIKE ZNFT1030-NFKEY,
      YNCAN    LIKE ZNFT1030-YNCAN,
      CONFM    LIKE ZNFT1030-CONFM,
*     -----------------------------------------------------
      CELLTAB  TYPE LVC_T_STYL,     " Cell 단위 수정 스타일
      COLINFO  TYPE LVC_T_SCOL.     " CELL 색상 지정
DATA: END OF GS_OUTTAB_C.
DATA: GT_OUTTAB_C LIKE TABLE OF GS_OUTTAB_C.

************************************************************************
* GLOBAL VARIABLE
************************************************************************
DATA: GV_FCODE LIKE SY-UCOMM,
      OK_CODE  LIKE SY-UCOMM,
      OK_SAVE  LIKE SY-UCOMM.

DATA: GV_CHANGE TYPE CHAR01,
      GV_ANSWER TYPE CHAR01,
      GV_ERROR  TYPE CHAR01,
      GV_SAVED  TYPE CHAR01,
      GV_INIT1  TYPE CHAR01,
      GV_INIT2  TYPE CHAR01.

DATA: GV_PRICE TYPE ZPRICE2.

DATA: GV_CNT TYPE I.

DATA: GV_WAERS  LIKE T001-WAERS,    "Currency
      GV_LAND1  LIKE T001-LAND1,    "Country
      GV_BUTXT  LIKE T001-BUTXT,    "Company Name
      GV_KTOPL  LIKE T001-KTOPL,    "Chart of Account
      GV_KOKRS  LIKE TKA02-KOKRS.   "Controlling Area

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

* FCM
DATA: BEGIN OF GT_FCM OCCURS 0,
        LIFNR       LIKE ZNFT0021-LIFNR,
        NAME1       LIKE LFA1-NAME1,
      END   OF GT_FCM.



************************************************************************
* ALV GLOBAL VARIABLE
************************************************************************
CLASS : LCL_EVT_RECEIVER DEFINITION DEFERRED.

DATA: GRF_CONTAINER      TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GRF_CONTAINER_NAME TYPE SCRFNAME VALUE 'CONTAINER_1100',
      GRF_GRID           TYPE REF TO CL_GUI_ALV_GRID,
      GRF_EVENT_RECEIVER TYPE REF TO LCL_EVT_RECEIVER.

DATA: GT_EXCLUDE  TYPE UI_FUNCTIONS,
      GT_SORT     TYPE LVC_T_SORT,  GS_SORT     TYPE LVC_S_SORT,
      GT_FIELDCAT TYPE LVC_T_FCAT,  GS_FIELDCAT TYPE LVC_S_FCAT,
      GS_LAYOUT   TYPE LVC_S_LAYO,  GS_VARIANT  TYPE DISVARIANT,
      GT_ROWS     TYPE LVC_T_ROW,   GS_ROWS     TYPE LVC_S_ROW,
      GT_COLS     TYPE LVC_T_COL,   GS_COLS     TYPE LVC_S_COL,
      GT_F4       TYPE LVC_T_F4,    GS_F4       TYPE LVC_S_F4,
      GT_CELLTAB  TYPE LVC_T_STYL,  GS_CELLTAB  TYPE LVC_S_STYL,
      GT_STYL     TYPE LVC_T_STYL,  GS_STBL     TYPE LVC_S_STBL,
      GT_FILTER   TYPE LVC_T_FILT.

* Grid Line variable
DATA: GS_ROW_ID TYPE LVC_S_ROW,
      GS_COL_ID TYPE LVC_S_COL,
      GS_VALUE(10).

DATA: GS_ROW  TYPE LVC_S_ROW,
      GS_COL  TYPE LVC_S_COL,
      GS_ROID TYPE LVC_S_ROID.

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
*    PERFORM ALV_EVENT_DATA_CHANGED USING ER_DATA_CHANGED.
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
