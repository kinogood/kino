*&---------------------------------------------------------------------*
*&  Include           ZNFR2510TOP
*&---------------------------------------------------------------------*

TYPE-POOLS : SLIS.

TABLES: ZNFT1000, ZNFT1001,
        ZNFT1010, ZNFT1011,
        ZNFT1020, ZNFT1021,
        ZNFT1090, ZNFT1091,
        ZZPA0001, ZPA0105,
        PA0105.

************************************************************************
* GLOBAL Structure & Internal Table
************************************************************************
DATA: BEGIN OF GS_NFNUM,
        NFNUM LIKE ZNFT1091-NFNUM,
      END OF GS_NFNUM.
DATA: GT_NFNUM_B LIKE TABLE OF GS_NFNUM.

* ALV LIST : 만기이동 요청승인
DATA: BEGIN OF GS_OUTTAB_B,
        BUKRS    LIKE ZNFT1040-BUKRS,
        SHFNO    LIKE ZNFT1040-SHFNO,  " 만기이동 요청번호
        H_NO1    LIKE ZNFT1041-H_NO1,
        SHFCNT   TYPE I,               " 만기이동차수
        PERNR    LIKE ZNFT1091-PERNR,  " 사번
*      SNAME    LIKE PA0001-SNAME,    " 이름
        SNAME    LIKE ZZPA0001-SNAME,    " 이름 "[MM] HR 테이블 대체 추가
        ERNAM    LIKE ZNFT1091-ERNAM,  " 요청자
        AUDAT    LIKE ZNFT1091-ERDAT,  " 승인요청일
        NFUTN    LIKE ZNFT1020-NFUTN,  " 선물집행번호
        REQNO_R  LIKE ZNFT1011-REQNO,  " 선물요청번호
        H_NO1_R  LIKE ZNFT1011-H_NO1,  " 선물요청항번
        OFUTN    LIKE ZNFT1040-OFUTN,  " 이동전선물집행번호
        NFKEY    LIKE ZNFT1020-NFKEY,  " 비철구분
        RQTYP    LIKE ZNFT1010-RQTYP,
        RQTYP_NM TYPE CHAR20,
        CONNO    LIKE ZNFT1000-CONNO,
        COTXT    LIKE ZNFT1000-COTXT,
        RUDAT    LIKE ZNFT1020-RUDAT,
        BY_SL    LIKE ZNFT1020-BY_SL,
        BY_SL_NM TYPE CHAR20,
        ENDMM    LIKE ZNFT1011-ENDMM,
        EMENG    LIKE ZNFT1020-EMENG,
        MEINS    LIKE ZNFT1020-MEINS,
        MITYP    LIKE ZNFT1020-MITYP,
        MITYP_NM TYPE CHAR20,
        MISPD    LIKE ZNFT1020-MISPD,
        MIMON    LIKE ZNFT1020-MIMON,
        PRICE    LIKE ZNFT1020-PRICE,
        WAERS    LIKE ZNFT1020-WAERS,
        REMON    LIKE ZNFT1041-REMON,  "
        RMENG_R  LIKE ZNFT1041-RMENG,  " 요청수량
        MEINS_R  LIKE ZNFT1041-MEINS,  " 단위
        CHECK    TYPE CHAR01,
        CELLTAB  TYPE LVC_T_STYL,      " Cell 단위 수정 스타일
        COLINFO  TYPE LVC_T_SCOL.      " CELL 색상 지정
DATA: END OF GS_OUTTAB_B.
DATA: GT_OUTTAB_B LIKE TABLE OF GS_OUTTAB_B.

DATA: GS_ZNFT1040 TYPE ZNFT1040.
DATA: GT_ZNFT1040 LIKE TABLE OF GS_ZNFT1040.

DATA: BEGIN OF GT_PERNR OCCURS 0,
*        PERNR LIKE PA0105-PERNR,
        PERNR LIKE ZPA0105-PERNR, "[MM] HR 테이블 대체 추가
      END   OF GT_PERNR.

************************************************************************
* GLOBAL VARIABLE
************************************************************************
DATA: OK_CODE TYPE SY-UCOMM,
      OK_SAVE TYPE SY-UCOMM,
      GV_CODE TYPE SY-UCOMM.

DATA: GV_ANSWER TYPE CHAR01,
      GV_ERROR  TYPE CHAR01.

*___상세내역 조회용
DATA: GV_NTEXT LIKE ZNFT0005-NTEXT,
      GV_PTEXT LIKE ZNFT0004-PTEXT,
      GV_VTEXT LIKE ZNFT0003-VTEXT.

DATA: BEGIN OF GT_1001 OCCURS 0,
        CONNO     LIKE ZNFT1001-CONNO,
        NFKEY     LIKE ZNFT1001-NFKEY,
        EMENG     LIKE ZNFT1001-EMENG,
        MEINS     LIKE ZNFT1001-MEINS,
        PRIND(20),
        SUJUP(20),
      END   OF GT_1001.

DATA: BEGIN OF GT_1020 OCCURS 0,
        NFUTN   LIKE ZNFT1020-NFUTN,
        NFKEY   LIKE ZNFT1020-NFKEY,
        BY_SL   LIKE ZNFT1020-BY_SL,
        EMENG   LIKE ZNFT1020-EMENG,
        MEINS   LIKE ZNFT1020-MEINS,
        ENDAT   LIKE ZNFT1020-ENDAT,
        PRICE   LIKE ZNFT1020-PRICE,
        MISPD   LIKE ZNFT1020-MISPD,
        WAERS   LIKE ZNFT1020-WAERS,
        YNFIN   LIKE ZNFT1020-YNFIN,
        CFUTN   LIKE ZNFT1030-CFUTN,
        PRICE_C LIKE ZNFT1030-PRICE,
        MISPD_C LIKE ZNFT1030-MISPD,
        UPRLO   LIKE ZNFT1051-UPRLO,
        UAERS   LIKE ZNFT1051-UAERS,
      END   OF GT_1020.

DATA: GV_NFKEY_CU     LIKE ZNFT1001-NFKEY,
      GV_EMENG_CU     LIKE ZNFT1001-EMENG,
      GV_MEINS_CU     LIKE ZNFT1001-MEINS,
      GV_PRIND_CU(20),
      GV_SUJUP_CU(20),
      GV_NFKEY_AL     LIKE ZNFT1001-NFKEY,
      GV_EMENG_AL     LIKE ZNFT1001-EMENG,
      GV_MEINS_AL     LIKE ZNFT1001-MEINS,
      GV_PRIND_AL(20),
      GV_SUJUP_AL(20),
      GV_NFKEY_PB     LIKE ZNFT1001-NFKEY,
      GV_EMENG_PB     LIKE ZNFT1001-EMENG,
      GV_MEINS_PB     LIKE ZNFT1001-MEINS,
      GV_PRIND_PB(20),
      GV_SUJUP_PB(20),
      GV_NFKEY_NI     LIKE ZNFT1001-NFKEY,
      GV_EMENG_NI     LIKE ZNFT1001-EMENG,
      GV_MEINS_NI     LIKE ZNFT1001-MEINS,
      GV_PRIND_NI(20),
      GV_SUJUP_NI(20).

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
      GV_PASSWD TYPE FIEB_ENCRYPTED_PASSWD.

DATA: GV_UNAME      TYPE SY-UNAME.

************************************************************************
* ALV GLOBAL VARIABLE
************************************************************************
CLASS : LCL_EVT_RECEIVER DEFINITION DEFERRED.

DATA: GRF_CONTAINER        TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GRF_CONTAINER_NAME   TYPE SCRFNAME VALUE 'CONTAINER_1200',
      GRF_GRID             TYPE REF TO CL_GUI_ALV_GRID,
      GRF_EVENT_RECEIVER   TYPE REF TO LCL_EVT_RECEIVER,

      GRF_CONTAINER_1      TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GRF_CONTAINER_NAME_1 TYPE SCRFNAME VALUE 'CONTAINER_1220',
      GRF_GRID_1           TYPE REF TO CL_GUI_ALV_GRID,
      GRF_EVENT_RECEIVER_1 TYPE REF TO LCL_EVT_RECEIVER.

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
DATA: GS_ROW_ID    TYPE LVC_S_ROW,
      GS_COL_ID    TYPE LVC_S_COL,
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

      HANDLE_DOUBLE_CLICK_1
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

  METHOD HANDLE_DOUBLE_CLICK_1.
    PERFORM ALV_EVENT_DOUBLE_CLICK_1 USING E_ROW
                                           E_COLUMN
                                           ES_ROW_NO.
  ENDMETHOD.                    "handle_double_click_1

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
