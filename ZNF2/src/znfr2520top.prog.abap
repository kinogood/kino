*&---------------------------------------------------------------------*
*&  Include           ZNFR2510TOP
*&---------------------------------------------------------------------*
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/09/05   MMB04(HDY)     변경근거 : C20120829_73047               *
*----------------------------------------------------------------------*
* Comment : 요청유형 필드 추가
************************************************************************

TYPE-POOLS : SLIS.

TABLES: ZNFT1000, ZNFT1001, ZNFT1002,
        ZNFT1010, ZNFT1011,
        ZNFT1020, ZNFT1021,
        ZNFT1090, ZNFT1091,
        PA0105  .

************************************************************************
* GLOBAL Structure & Internal Table
************************************************************************
DATA: BEGIN OF GS_NFNUM,
      NFNUM LIKE ZNFT1091-NFNUM,
      END OF GS_NFNUM.
DATA: GT_NFNUM_A LIKE TABLE OF GS_NFNUM.

* ALV LIST : 선물 요청승인
DATA: BEGIN OF GS_OUTTAB_A,
      BUKRS    LIKE ZNFT1010-BUKRS,
      REQNO    LIKE ZNFT1010-REQNO,   " 선물요청번호
      H_NO1    LIKE ZNFT1011-H_NO1,
      CONSQ    LIKE ZNFT1091-CONSQ,
      USRID1   LIKE ZNFT1091-USRID,   " 확인자
      USRID2   LIKE ZNFT1091-USRID,   " 접수자
      USRID3   LIKE ZNFT1091-USRID,   " 승인자
      PERNR    LIKE ZNFT1091-PERNR,   " 사번
      SNAME    LIKE PA0001-SNAME,     " 이름
      ERNAM    LIKE ZNFT1091-ERNAM,   " 요청자
**** HDY 20120905 START C20120829_73047
**** 요청유형 내역 필드 추가
      RQTYP       LIKE ZNFT1010-RQTYP,    "요청유형
      RQTXT(20),                          "요청유형 텍스트
**** HDY 20120905 END
      AUDAT    LIKE ZNFT1091-ERDAT,   " 승인요청일
      NFKEY    LIKE ZNFT1011-NFKEY,
      BY_SL    LIKE ZNFT1011-BY_SL,
      BY_SL_NM TYPE CHAR20        ,
      ENDMM    LIKE ZNFT1011-ENDMM,
      EMENG_C  LIKE ZNFT1001-EMENG,   " 수주비철량
      MEINS_C  LIKE ZNFT1001-MEINS,   "
      EMENG    LIKE ZNFT1011-EMENG,
      MEINS    LIKE ZNFT1011-MEINS,
      CONNO    LIKE ZNFT1011-CONNO,
      COTXT    LIKE ZNFT1000-COTXT,
      NFCTR    LIKE ZNFT1000-NFCTR,
      NFCTR_NM LIKE ZNFT0005-NTEXT,
      PRCTR    LIKE ZNFT1000-PRCTR,
      PRCTR_NM LIKE ZNFT0004-PTEXT,
      VKGRP    LIKE ZNFT1000-VKGRP,
      VKGRP_NM LIKE ZNFT0003-VTEXT,
      KUNNR    LIKE ZNFT1000-KUNNR,
      NCUST    LIKE ZNFT1000-NCUST,
      SALER    LIKE ZNFT1000-SALER,
      SUJUD    LIKE ZNFT1000-SUJUD,
      PRATE    LIKE ZNFT1000-PRATE,
      ERATE    LIKE ZNFT1000-ERATE,
      FILE_YN  TYPE CHAR01        ,   " 계약서 - 파일첨부여부
      PRIND    TYPE CHAR20,           " 가격구분
      SUJUP    TYPE CHAR20,           " 비철수주가격
      WAERS    LIKE ZNFT1001-WAERS,
      BIGO4    LIKE ZNFT1001-BIGO4,
      CHECK    TYPE CHAR01,
      CELLTAB  TYPE LVC_T_STYL,      " Cell 단위 수정 스타일
      COLINFO  TYPE LVC_T_SCOL.      " CELL 색상 지정
DATA: END OF GS_OUTTAB_A.
DATA: GT_OUTTAB_A LIKE TABLE OF GS_OUTTAB_A.

DATA: GS_ZNFT1010 TYPE ZNFT1010.
DATA: GT_ZNFT1010 LIKE TABLE OF GS_ZNFT1010.

* 결재순번(CONSQ) 중복체크
DATA: BEGIN OF GS_CONSQ,
        CONSQ LIKE ZNFT1090-CONSQ,
      END OF GS_CONSQ.
DATA: GT_CONSQ LIKE TABLE OF GS_CONSQ.

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

DATA: GV_CNT   TYPE I,
      GV_H_CNT TYPE I.

DATA: GV_PERNR  TYPE PERNR_D,
      GV_ENAME  TYPE EMNAM,
      GV_PASSWD TYPE FIEB_ENCRYPTED_PASSWD,
      GV_CONSQ  TYPE ZCONSQ.

DATA: GV_UNAME TYPE SY-UNAME.

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
