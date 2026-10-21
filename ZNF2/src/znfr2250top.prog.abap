*&---------------------------------------------------------------------*
*&  Include           ZNFR2250TOP
*&---------------------------------------------------------------------*

* Tables
TABLES: ZNFT0004,
        ZNFT1000,
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
      BUKRS_NM LIKE T001-BUTXT,
      NFUTN    LIKE ZNFT1020-NFUTN,
      RUDAT    LIKE ZNFT1020-RUDAT,
      FCM      LIKE ZNFT1020-FCM,
      FCM_NM   LIKE LFA1-NAME1    ,
      NFKEY    LIKE ZNFT1020-NFKEY,
      NFKEY_NM TYPE CHAR20,         " 비철구분
      BY_SL    LIKE ZNFT1020-BY_SL,
      BY_SL_NM TYPE CHAR20,         " Buy-Sell
      ENDAT    LIKE ZNFT1020-ENDAT,
      MITYP    LIKE ZNFT1020-MITYP,
      MITYP_NM TYPE CHAR10,         " 집행유형
      MISPD    LIKE ZNFT1020-MISPD,
      MIMON    LIKE ZNFT1020-MIMON,
      PRICE    LIKE ZNFT1020-PRICE,
      WAERS    LIKE ZNFT1020-WAERS,
      EMENG    LIKE ZNFT1020-EMENG,
      MEINS    LIKE ZNFT1020-MEINS,
      MISUS    LIKE ZNFT1020-MISUS,
      MISUS_NM TYPE CHAR20,         " 수수료
      PRCTR    LIKE ZNFT1000-PRCTR,   "손익센터
      PTEXT    LIKE ZNFT0004-PTEXT,   "손익센터명
      CONFM    LIKE ZNFT1020-CONFM,
      CONFM_NM TYPE CHAR20,         " 결재상태
      BIGO4    LIKE ZNFT1020-BIGO4,
      REQNO    LIKE ZNFT1011-REQNO,
      H_NO1    LIKE ZNFT1011-H_NO1,
      ENDMM    LIKE ZNFT1011-ENDMM,
      EMENG_R  LIKE ZNFT1011-EMENG,
      MEINS_R  LIKE ZNFT1011-MEINS,
      RQTYP    LIKE ZNFT1010-RQTYP,
      RQTYP_NM TYPE CHAR20,         " 요청유형
      CONNO    LIKE ZNFT1000-CONNO,
      COTXT    LIKE ZNFT1000-COTXT,
      KUNNR    LIKE ZNFT1000-KUNNR,
      NCUST    LIKE ZNFT1000-NCUST,
      PRIND    TYPE CHAR20,         " 가격구분
      SUJUP    TYPE CHAR20,         " 비철수주가
*     -----------------------------------------------------
      CELLTAB  TYPE LVC_T_STYL,     " Cell 단위 수정 스타일
      COLINFO  TYPE LVC_T_SCOL.     " CELL 색상 지정
DATA: END OF GS_OUTTAB.
DATA: GT_OUTTAB LIKE TABLE OF GS_OUTTAB.

* ALV LIST
DATA: BEGIN OF GS_DISTRIBUTE,
      CHECK    TYPE CHAR01,
*     -----------------------------------------------------
      NFUTN    LIKE ZNFT1020-NFUTN,
      SEQ      TYPE I,
      EMENG    LIKE ZNFT1020-EMENG,
      MEINS    LIKE ZNFT1020-MEINS,
      BIGO4    LIKE ZNFT1020-BIGO4,
*     -----------------------------------------------------
      CELLTAB  TYPE LVC_T_STYL,     " Cell 단위 수정 스타일
      COLINFO  TYPE LVC_T_SCOL.     " CELL 색상 지정
DATA: END OF GS_DISTRIBUTE.
DATA: GT_DISTRIBUTE LIKE TABLE OF GS_DISTRIBUTE.

************************************************************************
* GLOBAL VARIABLE
************************************************************************
DATA: GV_FCODE LIKE SY-UCOMM,
      OK_CODE  LIKE SY-UCOMM,
      OK_SAVE  LIKE SY-UCOMM.

DATA: GV_CHANGE TYPE CHAR01,
      GV_ANSWER TYPE CHAR01,
      GV_ERROR  TYPE CHAR01,
      GV_SAVED  TYPE CHAR01..

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

* 손익센터
DATA: BEGIN OF GT_PRCTR OCCURS 0,
        PRCTR       LIKE ZNFT0003-PRCTR,
        PTEXT       LIKE ZNFT0003-PTEXT,
      END OF GT_PRCTR.

* FCM
DATA: BEGIN OF GT_FCM OCCURS 0,
        LIFNR       LIKE ZNFT0021-LIFNR,
        NAME1       LIKE LFA1-NAME1,
      END   OF GT_FCM.

DATA: YZNFT1020     LIKE ZNFT1020.

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

************************************************************************
* POP-UP : ALV GLOBAL VARIABLE
************************************************************************

DATA: GRF_CONTAINER_P      TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GRF_CONTAINER_NAME_P TYPE SCRFNAME VALUE 'CONTAINER_1200',
      GRF_GRID_P           TYPE REF TO CL_GUI_ALV_GRID,
      GRF_EVENT_RECEIVER_P TYPE REF TO LCL_EVT_RECEIVER.

DATA: GT_EXCLUDE_P  TYPE UI_FUNCTIONS,
      GT_SORT_P     TYPE LVC_T_SORT,  GS_SORT_P     TYPE LVC_S_SORT,
      GT_FIELDCAT_P TYPE LVC_T_FCAT,  GS_FIELDCAT_P TYPE LVC_S_FCAT,
      GS_LAYOUT_P   TYPE LVC_S_LAYO,  GS_VARIANT_P  TYPE DISVARIANT,
      GT_ROWS_P     TYPE LVC_T_ROW,   GS_ROWS_P     TYPE LVC_S_ROW,
      GT_COLS_P     TYPE LVC_T_COL,   GS_COLS_P     TYPE LVC_S_COL,
      GT_F4_P       TYPE LVC_T_F4,    GS_F4_P       TYPE LVC_S_F4,
      GT_CELLTAB_P  TYPE LVC_T_STYL,  GS_CELLTAB_P  TYPE LVC_S_STYL,
      GT_STYL_P     TYPE LVC_T_STYL,  GS_STBL_P     TYPE LVC_S_STBL,
      GT_FILTER_P   TYPE LVC_T_FILT.

* Grid Line variable
DATA: GS_ROW_ID_P TYPE LVC_S_ROW,
      GS_COL_ID_P TYPE LVC_S_COL.

DATA: GS_ROW_P  TYPE LVC_S_ROW,
      GS_COL_P  TYPE LVC_S_COL,
      GS_ROID_P TYPE LVC_S_ROID.

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
    PERFORM ALV_EVENT_DOUBLE_CLICK USING E_ROW
                                         E_COLUMN
                                         ES_ROW_NO.
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
