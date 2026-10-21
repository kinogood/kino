*&---------------------------------------------------------------------*
*&  Include           ZNFR2470_TOP
*&---------------------------------------------------------------------*

TYPE-POOLS : SLIS.

TABLES : ZNFT1000, ZNFT1002,
         ZNFT1010, ZNFT1011,
         ZNFT1020, ZNFT1030.

************************************************************************
* GLOBAL Structure & Internal Table
************************************************************************
* ALV LIST :
DATA: BEGIN OF GS_OUTTAB,
        ICON       TYPE CHAR08        , " 점검상태
        REQ_LOG    TYPE CHAR100       , " 요청미결 로그
        EXE_LOG    TYPE CHAR100       , " 집행미결 로그
*       ===============================
        N_YNCAN    LIKE ZNFT1030-YNCAN,  " 삭제체크용
        N_CONFM    LIKE ZNFT1030-CONFM,  " 삭제체크용
        C_YNCAN    LIKE ZNFT1030-YNCAN,  " 삭제체크용
        C_CONFM    LIKE ZNFT1030-CONFM,  " 삭제체크용
*       ===============================
        BUKRS      LIKE ZNFT1020-BUKRS,
        NFUTN      LIKE ZNFT1020-NFUTN,
        N_NFKEY    LIKE ZNFT1020-NFKEY,
        N_RUDAT    LIKE ZNFT1020-RUDAT,
        N_FCM      LIKE ZNFT1020-FCM  ,
        N_FCM_NM   LIKE LFA1-NAME1    ,
        N_BY_SL    LIKE ZNFT1020-BY_SL,
        N_BY_SL_NM TYPE CHAR10        ,
        N_ENDAT    LIKE ZNFT1020-ENDAT,
        N_MITYP    LIKE ZNFT1020-MITYP,
        N_MITYP_NM TYPE CHAR10        ,
        N_MISPD    LIKE ZNFT1020-MISPD,
        N_MIMON    LIKE ZNFT1020-MIMON,
        N_PRICE    LIKE ZNFT1020-PRICE,
        N_WAERS    LIKE ZNFT1020-WAERS,
        N_EMENG    LIKE ZNFT1020-EMENG,
        N_MEINS    LIKE ZNFT1020-MEINS,
        N_MISUS    LIKE ZNFT1020-MISUS,
        N_CFMTX(20),
*       ===============================
        CFUTN      LIKE ZNFT1030-NFUTN,
        C_NFKEY    LIKE ZNFT1030-NFKEY,
        C_RUDAT    LIKE ZNFT1030-RUDAT,
        C_FCM      LIKE ZNFT1030-FCM  ,
        C_FCM_NM   LIKE LFA1-NAME1    ,
        C_BY_SL    LIKE ZNFT1030-BY_SL,
        C_BY_SL_NM TYPE CHAR10        ,
        C_ENDAT    LIKE ZNFT1030-ENDAT,
        C_MITYP    LIKE ZNFT1030-MITYP,
        C_MITYP_NM TYPE CHAR10        ,
        C_MISPD    LIKE ZNFT1030-MISPD,
        C_MIMON    LIKE ZNFT1030-MIMON,
        C_PRICE    LIKE ZNFT1030-PRICE,
        C_WAERS    LIKE ZNFT1030-WAERS,
        C_EMENG    LIKE ZNFT1030-EMENG,
        C_MEINS    LIKE ZNFT1030-MEINS,
        C_MISUS    LIKE ZNFT1030-MISUS,
        C_CFMTX(20),
*       ===============================
        REQNO      LIKE ZNFT1010-REQNO,
        H_NO1      LIKE ZNFT1011-H_NO1,
        RQTYP      LIKE ZNFT1010-RQTYP,
        RQTYP_NM   TYPE CHAR10        ,
        RSTAT      LIKE ZNFT1010-RSTAT,
        RSTAT_NM   TYPE CHAR10        ,
        EMENG      LIKE ZNFT1011-EMENG,
        ERDAT      LIKE ZNFT1010-ERDAT,
        CONNO      LIKE ZNFT1000-CONNO,
        COTXT      LIKE ZNFT1000-COTXT,
        NFCTR      LIKE ZNFT1000-NFCTR,
        NFCTR_NM   LIKE ZNFT0005-NTEXT,
        COTYP      LIKE ZNFT1000-COTYP,
        COTYP_NM   TYPE CHAR10        ,
        PRCTR      LIKE ZNFT1000-PRCTR,
        PTEXT      LIKE ZNFT0004-PTEXT,
        VKGRP      LIKE ZNFT1000-VKGRP,
        VKGRP_NM   LIKE ZNFT0003-VTEXT,
        KUNNR      LIKE ZNFT1000-KUNNR,
        NCUST      LIKE ZNFT1000-NCUST,
        SALER      LIKE ZNFT1000-SALER,
        CSTAT      LIKE ZNFT1000-CSTAT,
*       ===============================
        CELLTAB  TYPE LVC_T_STYL      ,  " Cell 단위 수정 스타일
        COLINFO  TYPE LVC_T_SCOL      .  " CELL 색상 지정
DATA: END OF GS_OUTTAB.
DATA: GT_OUTTAB LIKE TABLE OF GS_OUTTAB.

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

************************************************************************
* GLOBAL VARIABLE
************************************************************************
DATA: OK_CODE TYPE SY-UCOMM,
      OK_SAVE TYPE SY-UCOMM,
      GV_CODE TYPE SY-UCOMM.

DATA: GV_ANSWER TYPE CHAR01,
      GV_ERROR  TYPE CHAR01.

DATA: GV_LINE TYPE SY-TABIX,
      GV_CNT  TYPE I.

* 회사코드관련 정보
DATA: GV_WAERS      LIKE T001-WAERS,    "Currency
      GV_LAND1      LIKE T001-LAND1,    "Country
      GV_BUTXT      LIKE T001-BUTXT,    "Company Name
      GV_KTOPL      LIKE T001-KTOPL,    "Chart of Account
      GV_KOKRS      LIKE TKA02-KOKRS.   "Controlling Area

RANGES : R_RQTYP FOR ZNFT1010-RQTYP,
         R_YNNET FOR ZNFT1020-YNNET.

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
*    PERFORM ALV_EVENT_TOOBAR_PART USING NAME
*                                        E_OBJECT
*                                        E_INTERACTIVE.
  ENDMETHOD.                    "handle_toolbar

  METHOD HANDLE_USER_COMMAND.
*    PERFORM ALV_EVENT_USER_COMMAND_PART USING NAME
*                                    E_UCOMM.
  ENDMETHOD.                    "handle_user_command

  METHOD HANDLE_DATA_CHANGED.
*    PERFORM ALV_EVENT_DATA_CHANGED USING ER_DATA_CHANGED.
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
