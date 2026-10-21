*&---------------------------------------------------------------------*
*&  Include           ZNFR2580TOP
*&---------------------------------------------------------------------*

TYPE-POOLS : SLIS.

TABLES: ZNFT1000,
        ZNFT1010, ZNFT1011,
        ZNFT1020, ZNFT1030,
        VBAK    , VBAP    , VBEP    .

************************************************************************
* GLOBAL Structure & Internal Table
************************************************************************
DATA: BEGIN OF GS_OUTTAB,
        CHECK    TYPE CHAR01         , " 선택
        SUB_TYP  TYPE CHAR01         ,
        SUBTOT   LIKE ZNFT1000-COTXT , " 계약명
        ENDAT    LIKE ZNFT1020-ENDAT , " 만기일
        GUBUN    TYPE CHAR01         , " 신규 N /청산 C
        GUBUN_NM TYPE CHAR10         , " 신규 / 청산
        BUKRS    LIKE ZNFT1020-BUKRS ,
        PRCTR    LIKE ZNFT1000-PRCTR , " 손익센터
        PRCTR_NM LIKE ZNFT0004-PTEXT , "
        FCM      LIKE ZNFT1020-FCM   , " FCM
        NAME1    LIKE LFA1-NAME1     , " FCM 명
        NFKEY    LIKE ZNFT1020-NFKEY , " 비철구분
        BY_SL    LIKE ZNFT1020-BY_SL , " Buy/Sell
        BSTXT(10)                    , " Buy/Sell
        RQTYP    LIKE ZNFT1010-RQTYP , " 요청유형
        RQTYP_NM TYPE CHAR10         ,
        CONNO    LIKE ZNFT1000-CONNO , " 계약번호
        COTXT    LIKE ZNFT1000-COTXT , " 계약명
        KUNNR    LIKE ZNFT1000-KUNNR , " 고객
        NCUST    LIKE ZNFT1000-NCUST ,
        SUJUD    LIKE ZNFT1000-SUJUD , " 수주일
        EMENG_C  LIKE ZNFT1001-EMENG , " 수주량
        MEINS_C  LIKE ZNFT1001-MEINS , " 단위
        PRIND    TYPE CHAR20         , " 가격구분
        SUJUP    TYPE CHAR20         , " 비철수주가
        PRICE_C  LIKE ZNFT1000-PRICE , " 수주금액
        WAERS_C  LIKE ZNFT1000-WAERS , " 통화
        PRATE    LIKE ZNFT1000-PRATE , " 영업이익률
        ERATE    LIKE ZNFT1000-ERATE , " 환율
        ERDAT    LIKE ZNFT1011-ERDAT , " 선물요청일
        NFUTN    LIKE ZNFT1020-NFUTN , " 선물집행번호
        RUDAT    LIKE ZNFT1020-RUDAT , " 선물집행일
        EMENG_R  LIKE ZNFT1020-EMENG , " 집행수량
        MEINS_R  LIKE ZNFT1020-MEINS , " 단위
        MITYP    LIKE ZNFT1020-MITYP , " 집행유형
        MITYP_NM TYPE CHAR10         ,
        MISPD    LIKE ZNFT1020-MISPD , " Spread
        PRICE_R  LIKE ZNFT1020-PRICE , " 집행단가
        WAERS_R  LIKE ZNFT1020-WAERS , " 통화
        CONFM_YN TYPE CHAR01         , " 확인여부
        CONAM    LIKE ZNFT1020-CONAM , " 확인요청자
        CODAT    LIKE ZNFT1020-CODAT , " 확인요청일
        COZET    LIKE ZNFT1020-COZET , " 확인요청시간
        LCNAM    LIKE ZNFT1020-LCNAM , " 확인자
        LCDAT    LIKE ZNFT1020-LCDAT , " 확인일자
        LCZET    LIKE ZNFT1020-LCZET , " 확인시간
        R_EMENG  LIKE ZNFT1011-EMENG , " 집행수량
        R_MEINS  LIKE ZNFT1011-MEINS , " 단위
        CELLTAB  TYPE LVC_T_STYL     , " Cell 단위 수정 스타일
        COLINFO  TYPE LVC_T_SCOL     . " CELL 색상 지정
DATA: END OF GS_OUTTAB.
DATA: GT_OUTTAB LIKE TABLE OF GS_OUTTAB.

* Change Doc. 용
DATA: YZNFT1020     LIKE ZNFT1020,
      YZNFT1030     LIKE ZNFT1030.

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
************************************************************************
* GLOBAL VARIABLE
************************************************************************
DATA: OK_CODE TYPE SY-UCOMM,
      GV_CODE TYPE SY-UCOMM.

DATA: GV_ANSWER TYPE CHAR01,
      GV_ERROR  TYPE CHAR01.

DATA: GV_CNT  TYPE I.

* 회사코드관련 정보
DATA: GV_WAERS      LIKE T001-WAERS,    "Currency
      GV_LAND1      LIKE T001-LAND1,    "Country
      GV_BUTXT      LIKE T001-BUTXT,    "Company Name
      GV_KTOPL      LIKE T001-KTOPL,    "Chart of Account
      GV_KOKRS      LIKE TKA02-KOKRS.   "Controlling Area

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
