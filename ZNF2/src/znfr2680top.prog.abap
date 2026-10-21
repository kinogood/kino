*&---------------------------------------------------------------------*
*&  Include           ZNFR2680TOP
*&---------------------------------------------------------------------*

TYPE-POOLS : SLIS.

TABLES: ZNFT0001,
        ZNFT1000, ZNFT1010, ZNFT1011,
        ZNFT1020, ZNFT1030.

************************************************************************
* GLOBAL Structure & Internal Table
************************************************************************
DATA: BEGIN OF GS_OUTTAB,
        GUBUN    TYPE CHAR12         , " 평가구분
        BUKRS    LIKE ZNFT1020-BUKRS ,
        PRCTR    LIKE ZNFT1000-PRCTR , " 손익센터
        PRCTR_NM LIKE ZNFT0004-PTEXT , "
        RQTYP    LIKE ZNFT1010-RQTYP ,
        RQTYP_NM TYPE CHAR20         ,
        NFKEY    LIKE ZNFT1020-NFKEY ,
        CONNO    LIKE ZNFT1000-CONNO , " 계약번호
        COTXT    LIKE ZNFT1000-COTXT , " 계약명
        BY_SL    LIKE ZNFT1020-BY_SL ,
        BY_SL_NM TYPE CHAR10         ,
        NFUTN    LIKE ZNFT1020-NFUTN , " ZNFT1030-CFUTN
        RUDAT    LIKE ZNFT1020-RUDAT , " 집행일
        FCM      LIKE ZNFT1020-FCM   , " FCM
        NAME1    LIKE LFA1-NAME1     , " FCM 명
        ENDAT    LIKE ZNFT1020-ENDAT , " 만기일
        GUBUN1   TYPE CHAR08         , " 신규/청산구분
        MITYP    LIKE ZNFT1020-MITYP , " 집행유형
        MITYP_NM TYPE CHAR10         ,
        MISPD    LIKE ZNFT1020-MISPD , " Spread
        PRICE    LIKE ZNFT1020-PRICE , " 단가
        WAERS    LIKE ZNFT1020-WAERS , "
        EMENG    LIKE ZNFT1020-EMENG , " 수량
        MEINS    LIKE ZNFT1020-MEINS , "
        AMT_T    TYPE ZPRICE2        , " (단가+Spread) * 수량
        AMT_S    TYPE ZPRICE2        , " 시뮬레이션단가
        AMT_C    TYPE ZPRICE2        , " 선물평가손익
        CSTAT    LIKE ZNFT1000-CSTAT ,
        CSTAT_NM TYPE CHAR10         ,
        CELLTAB  TYPE LVC_T_STYL     , " Cell 단위 수정 스타일
        COLINFO  TYPE LVC_T_SCOL     , " CELL 색상 지정
      END OF GS_OUTTAB.
DATA: GT_OUTTAB LIKE TABLE OF GS_OUTTAB.

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

DATA: GV_LINE TYPE SY-TABIX,
      GV_CNT  TYPE I.

DATA: GV_R01 TYPE CHAR01,
      GV_R02 TYPE CHAR01,
*     시뮬레이션 가격
      GV_CU_PRICE_S TYPE ZCASH_O,
      GV_AL_PRICE_S TYPE ZCASH_O,
      GV_PB_PRICE_S TYPE ZCASH_O,
      GV_NI_PRICE_S TYPE ZCASH_O,
*     오피셜 가격
      GV_CU_PRICE_O TYPE ZCASH_O,
      GV_AL_PRICE_O TYPE ZCASH_O,
      GV_PB_PRICE_O TYPE ZCASH_O,
      GV_NI_PRICE_O TYPE ZCASH_O.


DATA: GV_BUKRS    LIKE ZNFT1080-BUKRS,
      GV_FRDAT    LIKE SY-DATUM,
      GV_TODAT    LIKE SY-DATUM.

DATA: GV_CURSOR(30).

DATA: GV_DATE_1 TYPE SY-DATUM,
      GV_DATE_7 TYPE SY-DATUM.

RANGES: S_ENDAT FOR ZNFT1020-ENDAT,
        S_RQTYP FOR ZNFT1010-RQTYP.

***********************************************************************
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
