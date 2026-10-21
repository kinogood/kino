*&---------------------------------------------------------------------*
*&  Include           ZNFR2640TOP
*&---------------------------------------------------------------------*

TYPE-POOLS : SLIS.

TABLES: ZNFT1000, ZNFT1001,
        ZNFT0003, ZNFT0004, ZNFT0005,
        ZNFT1020,
        VBAK    , VBAP    .

************************************************************************
* GLOBAL Structure & Internal Table
************************************************************************
* ALV LIST :
DATA: BEGIN OF GS_OUTTAB,
        CHECK    TYPE CHAR01        ,
        BUKRS    LIKE ZNFT1000-BUKRS,
        BUKRS_NM LIKE T001-BUTXT    ,
        NFCTR    LIKE ZNFT1000-NFCTR,  " 사업부
        NFCTR_NM TYPE ZNFT0005-NTEXT,
        PRCTR    LIKE ZNFT1000-PRCTR,  " 손익센터
        PRCTR_NM TYPE ZNFT0004-PTEXT,
        VKGRP    LIKE ZNFT1000-VKGRP,  " 영업부서
        VKGRP_NM TYPE ZNFT0003-VTEXT,
        CONNO    LIKE ZNFT1000-CONNO,  " 계약번호
        COTXT    LIKE ZNFT1000-COTXT,  " 계약명
        KUNNR    LIKE ZNFT1000-KUNNR,  " 고객코드
        NCUST    LIKE ZNFT1000-NCUST,  " 고객명
        NFKEY    LIKE ZNFT1001-NFKEY,  " 비철구분
        EMENG    LIKE ZNFT1001-EMENG,  " 요청수량
        MEINS    LIKE ZNFT1001-MEINS,  " 단위
        CU_V_Q   LIKE VBAP-KWMENG   ,  " 판매오더 CU량
        CU_N_Q   LIKE ZNFT1001-EMENG,  " 선물집행 CU량
        CELLTAB  TYPE LVC_T_STYL    ,  " Cell 단위 수정 스타일
        COLINFO  TYPE LVC_T_SCOL    .  " CELL 색상 지정
DATA: END OF GS_OUTTAB.
DATA: GT_OUTTAB LIKE TABLE OF GS_OUTTAB.

DATA: BEGIN OF GS_OUTTAB_V,
        VBELN    LIKE VBAP-VBELN    ,
        POSNR    LIKE VBAP-POSNR    ,
        MATNR    LIKE VBAP-MATNR    ,
        ARKTX    LIKE VBAP-ARKTX    ,
        CU_V_Q   LIKE VBAP-KWMENG   ,
        MEINS    LIKE VBAP-MEINS    ,
        CONNO    LIKE ZNFT1000-CONNO,
        COTXT    LIKE ZNFT1000-COTXT,
        CELLTAB  TYPE LVC_T_STYL    ,  " Cell 단위 수정 스타일
        COLINFO  TYPE LVC_T_SCOL    .  " CELL 색상 지정
DATA: END OF GS_OUTTAB_V.
DATA: GT_OUTTAB_V LIKE TABLE OF GS_OUTTAB_V.

DATA: BEGIN OF GS_OUTTAB_Z,
        NFUTN    LIKE ZNFT1020-NFUTN,
        RUDAT    LIKE ZNFT1020-RUDAT,
        FCM      LIKE ZNFT1020-FCM  ,
        FCM_NM   LIKE LFA1-NAME1    ,
        NFKEY    LIKE ZNFT1020-NFKEY,
        BY_SL    LIKE ZNFT1020-BY_SL,
        BYSL_NM  TYPE CHAR10        ,
        ENDAT    LIKE ZNFT1020-ENDAT,
        MITYP    LIKE ZNFT1020-MITYP,
        MISPD    LIKE ZNFT1020-MISPD,
        MIMON    LIKE ZNFT1020-MIMON,
        PRICE    LIKE ZNFT1020-PRICE,
        WAERS    LIKE ZNFT1020-WAERS,
        EMENG    LIKE ZNFT1020-EMENG,
        MEINS    LIKE ZNFT1020-MEINS,
        RUDAT1   LIKE ZNFT1030-RUDAT,
        FCM1     LIKE ZNFT1030-FCM  ,
        FCM_NM1  LIKE LFA1-NAME1    ,
        NFKEY1   LIKE ZNFT1030-NFKEY,
        BY_SL1   LIKE ZNFT1030-BY_SL,
        BYSL_NM1 TYPE CHAR10        ,
        ENDAT1   LIKE ZNFT1030-ENDAT,
        MITYP1   LIKE ZNFT1030-MITYP,
        MISPD1   LIKE ZNFT1030-MISPD,
        MIMON1   LIKE ZNFT1030-MIMON,
        PRICE1   LIKE ZNFT1030-PRICE,
        WAERS1   LIKE ZNFT1030-WAERS,
        EMENG1   LIKE ZNFT1030-EMENG,
        MEINS1   LIKE ZNFT1030-MEINS,
        CELLTAB  TYPE LVC_T_STYL    ,  " Cell 단위 수정 스타일
        COLINFO  TYPE LVC_T_SCOL    .  " CELL 색상 지정
DATA: END OF GS_OUTTAB_Z.
DATA: GT_OUTTAB_Z LIKE TABLE OF GS_OUTTAB_Z.

DATA: BEGIN OF GS_CONNO,
        CONNO    LIKE ZNFT1000-CONNO,  " 계약번호
      END OF GS_CONNO.
DATA: GT_CONNO LIKE TABLE OF GS_CONNO.

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

* 사업부
DATA: BEGIN OF GT_NFCTR OCCURS 0,
        NFCTR LIKE ZNFT0005-NFCTR,
        NTEXT LIKE ZNFT0005-NTEXT,
      END OF GT_NFCTR.

* 손익센터
DATA: BEGIN OF GT_PRCTR OCCURS 0,
        PRCTR LIKE ZNFT0003-PRCTR,
        PTEXT LIKE ZNFT0003-PTEXT,
      END OF GT_PRCTR.

* 영업그룹
DATA: BEGIN OF GT_VKGRP OCCURS 0,
        VKGRP LIKE ZNFT0003-VKGRP,
        VTEXT LIKE ZNFT0003-VTEXT,
      END OF GT_VKGRP.

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

* RANGES 변수
RANGES : R_CONNO FOR ZNFT1000-CONNO.

************************************************************************
* ALV GLOBAL VARIABLE
************************************************************************

* ### Main ###
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


* ### Sub ###
DATA: GRF_CONTAINER_D      TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GRF_CONTAINER_NAME_D TYPE SCRFNAME VALUE 'CONTAINER_1200',
      GRF_GRID_D           TYPE REF TO CL_GUI_ALV_GRID,
      GRF_EVENT_RECEIVER_D TYPE REF TO LCL_EVT_RECEIVER.

DATA: GT_EXCLUDE_D  TYPE UI_FUNCTIONS,
      GT_SORT_D     TYPE LVC_T_SORT,  GS_SORT_D     TYPE LVC_S_SORT,
      GT_FIELDCAT_D TYPE LVC_T_FCAT,  GS_FIELDCAT_D TYPE LVC_S_FCAT,
      GS_LAYOUT_D   TYPE LVC_S_LAYO,  GS_VARIANT_D  TYPE DISVARIANT,
      GT_ROWS_D     TYPE LVC_T_ROW,   GS_ROWS_D     TYPE LVC_S_ROW,
      GT_COLS_D     TYPE LVC_T_COL,   GS_COLS_D     TYPE LVC_S_COL,
      GT_F4_D       TYPE LVC_T_F4,    GS_F4_D       TYPE LVC_S_F4,
      GT_CELLTAB_D  TYPE LVC_T_STYL,  GS_CELLTAB_D  TYPE LVC_S_STYL,
      GT_STYL_D     TYPE LVC_T_STYL,  GS_STBL_D     TYPE LVC_S_STBL,
      GT_FILTER_D   TYPE LVC_T_FILT.

* Grid Line variable
DATA: GS_ROW_ID_D TYPE LVC_S_ROW,
      GS_COL_ID_D TYPE LVC_S_COL,
      GS_VALUE_D(10).

DATA: GS_ROW_D  TYPE LVC_S_ROW,
      GS_COL_D  TYPE LVC_S_COL,
      GS_ROID_D TYPE LVC_S_ROID.

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
