*&---------------------------------------------------------------------*
*&  Include           ZNFR2510TOP
*&---------------------------------------------------------------------*

TYPE-POOLS : SLIS.

TABLES: ZNFT1000, ZNFT1001,
        ZNFT1010, ZNFT1011,
        ZNFT1020, ZNFT1021,
        ZNFT1090, ZNFT1091.

************************************************************************
* GLOBAL Structure & Internal Table
************************************************************************
DATA: BEGIN OF GS_NFNUM,
      NFNUM LIKE ZNFT1091-NFNUM,
      END OF GS_NFNUM.
DATA: GT_NFNUM_A LIKE TABLE OF GS_NFNUM.
DATA: GT_NFNUM_B LIKE TABLE OF GS_NFNUM.
DATA: GT_NFNUM_C LIKE TABLE OF GS_NFNUM.
DATA: GT_NFNUM_D LIKE TABLE OF GS_NFNUM.
DATA: GT_NFNUM_E LIKE TABLE OF GS_NFNUM.
DATA: GT_NFNUM_F LIKE TABLE OF GS_NFNUM.
DATA: GT_NFNUM_G LIKE TABLE OF GS_NFNUM.

* ALV LIST
DATA: BEGIN OF GS_LIST,
      REQ_TYPE TYPE CHAR01,
      REQ_LIST TYPE CHAR50,
      REQ_CNT  TYPE P DECIMALS 0,
      CELLTAB  TYPE LVC_T_STYL,      " Cell 단위 수정 스타일
      COLINFO  TYPE LVC_T_SCOL.      " CELL 색상 지정
DATA: END OF GS_LIST.
DATA: GT_LIST LIKE TABLE OF GS_LIST.

DATA: BEGIN OF GS_REQNO,
        REQNO LIKE ZNFT1010-REQNO,
      END OF GS_REQNO.
DATA: GT_REQNO LIKE TABLE OF GS_REQNO.

DATA: BEGIN OF GT_PERNR OCCURS 0,
        PERNR     LIKE PA0105-PERNR,
      END   OF GT_PERNR.

************************************************************************
* GLOBAL VARIABLE
************************************************************************
DATA: OK_CODE TYPE SY-UCOMM,
      OK_SAVE TYPE SY-UCOMM,
      GV_CODE TYPE SY-UCOMM.

DATA: GV_ANSWER TYPE CHAR01,
      GV_ERROR  TYPE CHAR01.

************************************************************************
*  A = 선물요청승인
*  B = 만기이동요청승인
*  C = 만기이동집행승인
*  D = 신규선물집행승인
*  E = 청산선물집행승인
*  F = 신규/청산선물집행수정승인
DATA: GV_TYPE TYPE CHAR01. " 호출유형
************************************************************************

DATA: GV_CNT   TYPE I.
DATA: GV_PERNR TYPE PERNR_D.
DATA: GV_UNAME TYPE SY-UNAME.

************************************************************************
* ALV GLOBAL VARIABLE
************************************************************************
CLASS : LCL_EVT_RECEIVER DEFINITION DEFERRED.

DATA: GRF_CONTAINER_H      TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GRF_CONTAINER_NAME_H TYPE SCRFNAME VALUE 'CONTAINER_1100',
      GRF_GRID_H           TYPE REF TO CL_GUI_ALV_GRID,
      GRF_EVENT_RECEIVER_H TYPE REF TO LCL_EVT_RECEIVER.

DATA: GT_EXCLUDE_H  TYPE UI_FUNCTIONS,
      GT_SORT_H     TYPE LVC_T_SORT,  GS_SORT_H     TYPE LVC_S_SORT,
      GT_FIELDCAT_H TYPE LVC_T_FCAT,  GS_FIELDCAT_H TYPE LVC_S_FCAT,
      GS_LAYOUT_H   TYPE LVC_S_LAYO,  GS_VARIANT_H  TYPE DISVARIANT,
      GT_ROWS_H     TYPE LVC_T_ROW,   GS_ROWS_H     TYPE LVC_S_ROW,
      GT_COLS_H     TYPE LVC_T_COL,   GS_COLS_H     TYPE LVC_S_COL,
      GT_F4_H       TYPE LVC_T_F4,    GS_F4_H       TYPE LVC_S_F4,
      GT_CELLTAB_H  TYPE LVC_T_STYL,  GS_CELLTAB_H  TYPE LVC_S_STYL,
      GT_STYL_H     TYPE LVC_T_STYL,  GS_STBL_H     TYPE LVC_S_STBL,
      GT_FILTER_H   TYPE LVC_T_FILT.

* Grid Line variable
DATA: GS_ROW_ID_H TYPE LVC_S_ROW,
      GS_COL_ID_H TYPE LVC_S_COL.

DATA: GS_ROW_H  TYPE LVC_S_ROW,
      GS_COL_H  TYPE LVC_S_COL,
      GS_ROID_H TYPE LVC_S_ROID.

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
    PERFORM ALV_EVENT_HOTSPOT_CLICK USING E_ROW_ID E_COLUMN_ID.
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
