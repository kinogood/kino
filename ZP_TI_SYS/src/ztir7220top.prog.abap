*&---------------------------------------------------------------------*
*&  Include           ZNFR2000TOP
*&---------------------------------------------------------------------*

* TYPE-POOLS
TYPE-POOLS : SLIS.

TABLES : SSCRFIELDS.

TABLES : ZTITACK,    "[Import] 인수증 Table
         ZTITACP,    "[Import] 인수증 Items table
         ZTITIG00,
         ZTSTEDIS,   "상태레코드(수출입 EDI)
         ZTSTIG0,    "회사관련 EDI 기초자료 관리
         DFIES.

************************************************************************
* GLOBAL Structure & Internal Table
************************************************************************

* ALV LIST
DATA: BEGIN OF GS_OUTTAB.
        INCLUDE STRUCTURE ZTITACK.
DATA: ELDFN_NM TYPE CHAR20,
      CHECK    TYPE CHAR01,
      CELLTAB  TYPE LVC_T_STYL,      " Cell 단위 수정 스타일
      COLINFO  TYPE LVC_T_SCOL.      " CELL 색상 지정
DATA: END OF GS_OUTTAB.
DATA: GT_OUTTAB LIKE TABLE OF GS_OUTTAB.

* LOCK OBJECT CHECK용도
DATA: BEGIN OF GS_ACDNO,
        ACDNO LIKE ZTITACK-ACDNO,
      END OF GS_ACDNO.
DATA: GT_ACDNO LIKE TABLE OF GS_ACDNO.

************************************************************************
* GLOBAL VARIABLE
************************************************************************
DATA: OK_CODE   TYPE SY-UCOMM,
      OK_SAVE   TYPE SY-UCOMM,
      GV_CODE   TYPE SY-UCOMM.

DATA: GV_CNT    TYPE I,
      G_MODIFY  TYPE C,
      GV_TITLE(50).

DATA: g_subrc   LIKE sy-subrc.

DATA: GV_ANSWER TYPE CHAR01,
      GV_ERROR  TYPE CHAR01.

DATA: XGT_1000  LIKE ZNFT1000,
      YGT_1000  LIKE ZNFT1000.


************************************************************************
* CONSTANTS
************************************************************************
CONSTANTS: C_LOCK      TYPE C        VALUE 'L',
           C_UNLOCK    TYPE C        VALUE 'U',
           C_ERROR     TYPE C        VALUE 'E',
           C_TRUE      TYPE C        VALUE 'X'.

CONSTANTS: GC_TCODE_A  LIKE SY-TCODE VALUE 'ZTIR722A',  "1차승인(구매)
           GC_TCODE_B  LIKE SY-TCODE VALUE 'ZTIR722B',  "접수
           GC_TCODE_C  LIKE SY-TCODE VALUE 'ZTIR722C'.  "최종승인(재무)


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
* F4 Help용 변수
************************************************************************
RANGES : R_ELDFN FOR ZTITACK-ELDFN.


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
