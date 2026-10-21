*&---------------------------------------------------------------------*
*&  Include           ZNFR2510TOP
*&---------------------------------------------------------------------*

TYPE-POOLS : SLIS.

TABLES: ZNFT1000, ZNFT1001,
        ZNFT1010, ZNFT1011,
        ZNFT1020, ZNFT1021,
        ZNFT1090, ZNFT1091,
        PA0105  ,
        CDHDR,    CDPOS.

************************************************************************
* GLOBAL Structure & Internal Table
************************************************************************
DATA: BEGIN OF GS_NFNUM,
      NFNUM LIKE ZNFT1091-NFNUM,
      END OF GS_NFNUM.
DATA: GT_NFNUM_F LIKE TABLE OF GS_NFNUM.

* ALV LIST : 신규/청산 선물집행 수정승인
DATA: BEGIN OF GS_OUTTAB_F,
      NFUTN    LIKE ZNFT1020-NFUTN,  " ZNFT1030-CFUTN
      AUDAT    LIKE ZNFT1091-ERDAT,  " 승인요청일
      RUDAT    LIKE ZNFT1020-RUDAT,
      FCM      LIKE ZNFT1020-FCM,
      FCM_NM   LIKE LFA1-NAME1    ,
      BY_SL    LIKE ZNFT1020-BY_SL,
      BY_SL_NM TYPE CHAR20        ,
      ENDAT    LIKE ZNFT1020-ENDAT,
      MITYP    LIKE ZNFT1020-MITYP,
      MISPD    LIKE ZNFT1020-MISPD,
      MIMON    LIKE ZNFT1020-MIMON,
      PRICE    LIKE ZNFT1020-PRICE,
      WAERS    LIKE ZNFT1020-WAERS,
      EMENG    LIKE ZNFT1020-EMENG,
      MEINS    LIKE ZNFT1020-MEINS,
      MISUS    LIKE ZNFT1020-MISUS,
      NFKEY    LIKE ZNFT1020-NFKEY,
      RQTYP    LIKE ZNFT1010-RQTYP,
      CONNO    LIKE ZNFT1000-CONNO,
      PRCTR    LIKE ZNFT1000-PRCTR,
      PTEXT    LIKE ZNFT0003-PTEXT,
      COTXT    LIKE ZNFT1000-COTXT,
      NCUST    LIKE ZNFT1000-NCUST,
      PRIND    TYPE CHAR20,           " 가격구분
      SUJUP    TYPE CHAR20,           " 비철수주가격
      CHECK    TYPE CHAR01,
      GUBUN    TYPE CHAR04,          " 구분
      BIGO4    LIKE ZNFT1020-BIGO4,
      YNCAN    LIKE ZNFT1020-YNCAN,
      RESON    LIKE ZNFT1020-RESON,
      AEDAT    LIKE ZNFT1020-AEDAT,
      AEZET    LIKE ZNFT1020-AEZET,
      AENAM    LIKE ZNFT1020-AENAM,
      ANAME    LIKE ADRP-NAME_LAST,
      ERDAT    LIKE ZNFT1020-ERDAT,
      ERZET    LIKE ZNFT1020-ERZET,
      ERNAM    LIKE ZNFT1020-ERNAM,
      ENAME    LIKE ADRP-NAME_LAST,
      CELLTAB  TYPE LVC_T_STYL,      " Cell 단위 수정 스타일
      COLINFO  TYPE LVC_T_SCOL.      " CELL 색상 지정
DATA: END OF GS_OUTTAB_F.
DATA: GT_OUTTAB_F LIKE TABLE OF GS_OUTTAB_F.

DATA: GS_ZNFT1020 TYPE ZNFT1020.
DATA: GT_ZNFT1020 LIKE TABLE OF GS_ZNFT1020.

DATA: GS_ZNFT1030 TYPE ZNFT1030.
DATA: GT_ZNFT1030 LIKE TABLE OF GS_ZNFT1030.

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

DATA: GV_CHANGE_YN TYPE CHAR01.

************************************************************************
*  A = 선물요청승인
*  B = 만기이동요청승인
*  C = 만기이동집행승인
*  D = 신규선물집행승인
*  E = 청산선물집행승인
*  F = 신규/청산선물집행수정승인
DATA: GV_TYPE TYPE CHAR01. " 호출유형
************************************************************************

DATA: GV_CNT   TYPE I,
      GV_H_CNT TYPE I.

DATA: GV_PERNR  TYPE PERNR_D,
      GV_ENAME  TYPE EMNAM,
      GV_PASSWD TYPE FIEB_ENCRYPTED_PASSWD,
      GV_CONSQ  TYPE ZCONSQ.

DATA: GV_UNAME TYPE SY-UNAME.

* PERNR 권한등급 ( A:신규, B:청산, C:신규+청산 )
DATA: GV_AUTH TYPE CHAR01.

************************************************************************
* ALV GLOBAL VARIABLE
************************************************************************
CLASS : LCL_EVT_RECEIVER DEFINITION DEFERRED.

DATA: GRF_CONTAINER      TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GRF_CONTAINER_NAME TYPE SCRFNAME VALUE 'CONTAINER_1200',
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
*    PERFORM ALV_EVENT_HOTSPOT_CLICK USING E_ROW_ID E_COLUMN_ID.
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
