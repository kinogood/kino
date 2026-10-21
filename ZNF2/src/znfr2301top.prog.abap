*&---------------------------------------------------------------------*
*&  Include           ZNFR2101TOP
*&---------------------------------------------------------------------*

* TYPE-POOLS
TYPE-POOLS : SLIS.

TABLES: SSCRFIELDS, WWWDATA,
        ZNFT1090,
        ZNFT1000,   ZNFT1001,
        ZNFT1010,   ZNFT1011,
        ZNFT1020,   ZNFT0004.

TYPES TRUXS_T_TEXT_DATA(4096) TYPE C OCCURS 0.

************************************************************************
* GLOBAL Structure & Internal Table
************************************************************************

* ALV LIST
DATA: BEGIN OF GS_OUTTAB,
       OFUTN    LIKE ZNFT1020-NFUTN,   " 선물집행번호
       BUKRS    LIKE ZNFT1020-BUKRS,   " 회사코드
       ENDAT    LIKE ZNFT1020-ENDAT,   " 만기일
       EMENG    LIKE ZNFT1020-EMENG,   " 집행수량
       BIGO3    LIKE ZNFT1040-BIGO4,   " 사유
       H_NO1    LIKE ZNFT1041-H_NO1,   " 항번
       REMON    LIKE ZNFT1041-REMON,   " 요청만기월
       RMENG    LIKE ZNFT1041-RMENG,   " 요청수량
       MEINS    LIKE ZNFT1020-MEINS,   " 단위
       RUDAT    LIKE ZNFT1020-RUDAT,   " 집행일
       FCM      LIKE ZNFT1020-FCM,     " FCM
       NAME1    LIKE LFA1-NAME1,       " FCM 명
       NFKEY    LIKE ZNFT1020-NFKEY,   " 비철구분
       BY_SL    LIKE ZNFT1020-BY_SL,   " Buy/Sell 구분
       BSTXT(10),                      " Buy/Sell
       MITYP    LIKE ZNFT1020-MITYP,   " 집행유형
       MITPT(20),                      " 집행유형내역
       MISPD    LIKE ZNFT1020-MISPD,   " Spread
       MIMON    LIKE ZNFT1020-MIMON,   " 기준월
       PRICE    LIKE ZNFT1020-PRICE,   " 집행단가
       WAERS    LIKE ZNFT1020-WAERS,   " 통화
       REQNO    LIKE ZNFT1020-REQNO,   " 선물요청번호
       H_NO2    LIKE ZNFT1020-H_NO1,   " 선물요청항번
       YNFIN    LIKE ZNFT1011-YNFIN,   " 마감여부
       ENDMM    LIKE ZNFT1011-ENDMM,   " 만기월
       EMENG1   LIKE ZNFT1011-EMENG,   " 요청수량
       MEINS1   LIKE ZNFT1011-MEINS,   " 단위
       RQTYP    LIKE ZNFT1010-RQTYP,   " 요청유형
       RQTPT(20),                      " 요청유형내역
       PRCTR    LIKE ZNFT1000-PRCTR,   "손익센터
       PTEXT    LIKE ZNFT0004-PTEXT,   "손익센터명
       CONNO    LIKE ZNFT1000-CONNO,   " 계약번호
       COTXT    LIKE ZNFT1000-COTXT,   " 계약명
       KUNNR    LIKE ZNFT1000-KUNNR,   " 고객번호
       NCUST    LIKE ZNFT1000-NCUST,   " 고객명
       PRIND(20),                      " 가격구분
       SUJUP(20),                      " 비철수주가
       SETTL(20),                      " 청산입력여부
       SHFNO    LIKE ZNFT1040-SHFNO,   " 만기이동요청번호
       ICON(4),
       BIGO_CHK TYPE CHAR200,         " 해당 데이터 CHECK 결과
       CELLTAB  TYPE LVC_T_STYL,      " Cell 단위 수정 스타일
       COLINFO  TYPE LVC_T_SCOL,      " CELL 색상 지정
      END OF GS_OUTTAB.
DATA: GT_OUTTAB LIKE TABLE OF GS_OUTTAB.

* EXCEL UPLOAD DATA
DATA: BEGIN OF GS_EXCEL,
       OFUTN   LIKE ZNFT1040-OFUTN,   " 신규선물집행번호
       REMON   LIKE ZNFT1041-REMON,   " 만기월
       RMENG   LIKE ZNFT1041-RMENG,   " 요청수량
       BIGO3   LIKE ZNFT1040-BIGO4,   " 사유
       BIGO_CHK TYPE CHAR200,         " 해당 데이터 CHECK 결과
      END OF GS_EXCEL.
DATA: GT_EXCEL LIKE TABLE OF GS_EXCEL.

DATA:GT_RAW_DATA  TYPE TRUXS_T_TEXT_DATA.

DATA: BEGIN OF GT_1020 OCCURS 0,
        NFUTN       LIKE ZNFT1020-NFUTN,
        EMENG       LIKE ZNFT1020-EMENG,
      END   OF GT_1020.

DATA: BEGIN OF GT_1020M OCCURS 0,
        NFUTN       LIKE ZNFT1020-NFUTN,
        ENDMM       LIKE ZNFT1011-ENDMM,
        COUNT       TYPE I,
      END   OF GT_1020M.

************************************************************************
* GLOBAL VARIABLE
************************************************************************
DATA: OK_CODE TYPE SY-UCOMM,
      OK_SAVE TYPE SY-UCOMM.

DATA: GV_FLAG   TYPE CHAR01,         " User별 회사코드 찾는 리턴값
      GV_ERROR  TYPE CHAR01,
      GV_ANSWER TYPE CHAR01.

DATA: GV_PERNR TYPE PERNR_D,
      GV_ENAME TYPE EMNAM,
      GV_KOKRS TYPE TKA02-KOKRS.   "Controlling Area

" Excel Data Check ( Y / N )
DATA: GV_EXCEL_FLAG    TYPE CHAR01 VALUE 'N',
      GV_COMPLETE_SAVE TYPE CHAR01 VALUE 'N',
      GV_COMPLETE_REQ  TYPE CHAR01 VALUE 'N'.

DATA: GV_RNT_MSG TYPE CHAR200.

DATA: GV_CNT TYPE I.

* Excel Data Save Loc.
DATA: GV_SAVE_LOC TYPE LOCALFILE.

*___BDC용 변수
TABLES : CTU_PARAMS.

DATA : BEGIN OF GT_BDCTAB OCCURS 0.
        INCLUDE STRUCTURE BDCDATA.
DATA : END   OF GT_BDCTAB.

DATA : GT_RETMSG LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.

************************************************************************
* F4 Help용 변수
************************************************************************
DATA: SELECTFIELD   LIKE  HELP_INFO-FIELDNAME,
      IT_FIELDS     LIKE  HELP_VALUE OCCURS 1 WITH HEADER LINE,
      SELECT_VALUE  LIKE  HELP_INFO-FLDVALUE,
      LD_TABIX      LIKE  SY-TABIX,
      LV_INDEX      LIKE  SY-INDEX.

DATA: SCR_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE,
      FELD_TABLE LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

*___결재자사번
DATA: BEGIN OF GT_PERNR OCCURS 0,
        PERNR       LIKE ZNFT1090-PERNR,
        ENAME       LIKE PA0001-ENAME,
      END   OF GT_PERNR.

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

DATA: GV_ITAB     LIKE GS_FIELDCAT-TABNAME,
      GV_POS      LIKE GS_FIELDCAT-COL_POS.
*----------------------------------------------------------------------*
*       CLASS lcl_evt_receiver DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER DEFINITION.

  PUBLIC SECTION.
    METHODS : CONSTRUCTOR
                IMPORTING I_NAME TYPE C OPTIONAL,

              HANDLE_TOOLBAR
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

  PRIVATE SECTION.
    DATA : NAME(20) TYPE C.

ENDCLASS.  " lcl_evt_receiver
*----------------------------------------------------------------------*
*       CLASS lcl_evt_receiver IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER IMPLEMENTATION.

  METHOD CONSTRUCTOR.
    ME->NAME = I_NAME.
  ENDMETHOD.                    "constructor

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
    PERFORM ALV_EVENT_DATA_CHG_FINISHED USING E_MODIFIED
                                              ET_GOOD_CELLS.

*   해당 로우 수정후 ERROR이 없을 경우 상태를 변경한다.
    PERFORM ALV_EVENT_DATA_FINISHED_CHECK USING ET_GOOD_CELLS.

  ENDMETHOD.                    "handle_data_changed_finished

  METHOD HANDLE_HOTSPOT_CLICK.
*    perform alv_event_hotspot_click using e_row_id e_column_id.
  ENDMETHOD.                    "handle_hotspot_click

  METHOD HANDLE_DOUBLE_CLICK.
*    PERFORM alv_event_double_click USING e_row
*                                         e_column
*                                         es_row_no.
  ENDMETHOD.                    "handle_double_click

  METHOD HANDLE_ON_F4.
    PERFORM ALV_EVENT_ON_F4 USING SENDER
                                  E_FIELDNAME
                                  E_FIELDVALUE
                                  ES_ROW_NO
                                  ER_EVENT_DATA
                                  ET_BAD_CELLS
                                  E_DISPLAY.

*   해당 로우 수정후 ERROR이 없을 경우 상태를 변경한다.
    PERFORM ALV_EVENT_ON_F4_CHECK USING ES_ROW_NO.

  ENDMETHOD.                    "handle_on_f4

ENDCLASS.  " lcl_dvt_receiver
