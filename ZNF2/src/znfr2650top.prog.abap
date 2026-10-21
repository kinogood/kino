*&---------------------------------------------------------------------*
*&  Include           ZNFR2630TOP
*&---------------------------------------------------------------------*

TYPE-POOLS : SLIS.

TABLES: ZNFT1000,
        ZNFT1010, ZNFT1011,
        ZNFT1020, ZNFT1030,
        ZNFT1054.

************************************************************************
* GLOBAL Structure & Internal Table
************************************************************************
* ALV LIST :
DATA: BEGIN OF GS_OUTTAB,
        CHECK    TYPE CHAR01,
        ICON     TYPE CHAR08,
        O_CASH   LIKE ZNFT0001-O_CASH, " 현재시세
        NE_CO    LIKE ZNFT1054-NE_CO , " 신규/청산(N/C)
        NC_NM    TYPE CHAR10,          "
        BUKRS    LIKE ZNFT1020-BUKRS ,
        NFUTN    LIKE ZNFT1020-NFUTN , " ZNFT1030-CFUTN
        SHFCNT   TYPE I,               " 만기이동차수 "기능개선 XXXXXX
        FCM      LIKE ZNFT1020-FCM   , " FCM
        FCM_NM   LIKE LFA1-NAME1     , "
        RUDAT    LIKE ZNFT1020-RUDAT , " 집행일
        NFKEY    LIKE ZNFT1020-NFKEY , " 비철구분
        BY_SL    LIKE ZNFT1020-BY_SL , " BUY-SELL
        BY_SL_NM TYPE CHAR10         ,
        ENDAT    LIKE ZNFT1020-ENDAT , " 만기일
        MITYP    LIKE ZNFT1020-MITYP , " 집행유형
        MITYP_NM TYPE CHAR10         , "
        MISPD    LIKE ZNFT1020-MISPD , " Spread
        MIMON    LIKE ZNFT1020-MIMON , " 기준월
        PRICE    LIKE ZNFT1020-PRICE , " 금액
        WAERS    LIKE ZNFT1020-WAERS , "
        EMENG    LIKE ZNFT1020-EMENG , " 수량
        N_AMT    TYPE ZCREDT         , " 집행금액
        MEINS    LIKE ZNFT1020-MEINS , "
        NFCTR    LIKE ZNFT1000-NFCTR , " 사업부
        NFCTR_NM LIKE ZNFT0005-NTEXT , "
        PRCTR    LIKE ZNFT1000-PRCTR , " 손익센터
        PRCTR_NM LIKE ZNFT0004-PTEXT , "
        VKGRP    LIKE ZNFT1000-VKGRP , " 영업그룹
        VKGRP_NM LIKE ZNFT0003-VTEXT , "
        RQTYP    LIKE ZNFT1010-RQTYP , " 선물요청유형
        RQTYP_NM TYPE CHAR20,          "
        REQNO    LIKE ZNFT1010-REQNO , " 선물요청번호
        H_NO1    LIKE ZNFT1011-H_NO1 , " 선물요청항번
        ERDAT    LIKE ZNFT1011-ERDAT , " 선물요청일
        CONNO    LIKE ZNFT1000-CONNO , " 계약번호
        COTXT    LIKE ZNFT1000-COTXT , " 계약명
        CSTAT    LIKE ZNFT1000-CSTAT , " 계약상태
        CSTAT_NM TYPE CHAR10         , "
*       -- ZNFT1054 저장용 --
        MISUS    LIKE ZNFT1054-MISUS , "
        CONFM    LIKE ZNFT1054-CONFM , "
        CONFM_NM TYPE CHAR20         , "
        YNCAN    LIKE ZNFT1054-YNCAN , "
        YNFIN    LIKE ZNFT1054-YNFIN , "
        ZEPRO    LIKE ZNFT1054-ZEPRO , "
        YNNET    LIKE ZNFT1054-YNNET , "
        OLDFT    LIKE ZNFT1054-OLDFT , "
        COTYP    LIKE ZNFT1054-COTYP , "
        KUNNR    LIKE ZNFT1054-KUNNR , "
        NCUST    LIKE ZNFT1054-NCUST , "
        BIGO4    LIKE ZNFT1054-BIGO4 , "
*       -- ZNFT1054 저장용 --
        CELLTAB  TYPE LVC_T_STYL     , " Cell 단위 수정 스타일
        COLINFO  TYPE LVC_T_SCOL     . " CELL 색상 지정
DATA: END OF GS_OUTTAB.                "
DATA: GT_OUTTAB LIKE TABLE OF GS_OUTTAB.

* 저장데이터 ALV
DATA: BEGIN OF GS_OUTTAB_LIST,
        ICON     TYPE CHAR08,
        BUKRS    LIKE ZNFT1054-BUKRS , " 회사코드
        O_CASH   LIKE ZNFT1054-O_CASH, " 현재시세
        ERDAT    LIKE ZNFT1054-ERDAT , " 저장일
        VRSIO    LIKE ZNFT1054-VRSIO , " 저장버전
        ERNAM    LIKE ZNFT1054-ERNAM , " 저장일
        NE_CO    LIKE ZNFT1054-NE_CO , " 신규/청산(N/C)
        NC_NM    TYPE CHAR10,          "
        OPNFN    LIKE ZNFT1054-OPNFN , " 선물집행번호
        FCM      LIKE ZNFT1054-FCM   , " FCM
        FCM_NM   LIKE LFA1-NAME1     , "
        RUDAT    LIKE ZNFT1054-RUDAT , " 집행일
        NFKEY    LIKE ZNFT1054-NFKEY , " 비철구분
        BY_SL    LIKE ZNFT1054-BY_SL , " BUY-SELL
        BY_SL_NM TYPE CHAR10         ,
        ENDAT    LIKE ZNFT1054-ENDAT , " 만기일
        MITYP    LIKE ZNFT1054-MITYP , " 집행유형
        MITYP_NM TYPE CHAR10         , "
        MISPD    LIKE ZNFT1054-MISPD , " Spread
        MIMON    LIKE ZNFT1054-MIMON , " 기준월
        PRICE    LIKE ZNFT1054-PRICE , " 단가
        WAERS    LIKE ZNFT1054-WAERS , "
        EMENG    LIKE ZNFT1054-EMENG , " 수량
        MEINS    LIKE ZNFT1054-MEINS , "
        CONFM    LIKE ZNFT1054-CONFM , " 결재상태
        CONFM_NM TYPE CHAR20         , "
        N_AMT    TYPE ZCREDT         , " 집행금액
        NFCTR    LIKE ZNFT1054-NFCTR , " 사업부
        NFCTR_NM LIKE ZNFT0005-NTEXT , "
        PRCTR    LIKE ZNFT1054-PRCTR , " 손익센터
        PRCTR_NM LIKE ZNFT0004-PTEXT , "
        RQTYP    LIKE ZNFT1054-RQTYP , " 선물요청유형
        RQTYP_NM TYPE CHAR20,          "
        REQNO    LIKE ZNFT1054-REQNO , " 선물요청번호
        H_NO1    LIKE ZNFT1054-H_NO1 , " 선물요청항번
        RQDAT    LIKE ZNFT1054-RQDAT , " 선물요청일
        CONNO    LIKE ZNFT1054-CONNO , " 계약번호
        COTXT    LIKE ZNFT1054-COTXT , " 계약명
        CSTAT    LIKE ZNFT1054-CSTAT , " 계약상태
        CSTAT_NM TYPE CHAR10         , "
        CELLTAB  TYPE LVC_T_STYL     , " Cell 단위 수정 스타일
        COLINFO  TYPE LVC_T_SCOL     . " CELL 색상 지정
DATA: END OF GS_OUTTAB_LIST.                "
DATA: GT_OUTTAB_LIST LIKE TABLE OF GS_OUTTAB_LIST.

************************************************************************
* F4 Help용 변수
************************************************************************
DATA: SELECTFIELD   LIKE  HELP_INFO-FIELDNAME,
      IT_FIELDS     LIKE  HELP_VALUE OCCURS 1 WITH HEADER LINE,
      SELECT_VALUE  LIKE  HELP_INFO-FLDVALUE,
      LD_TABIX      LIKE  SY-TABIX,
      GV_INDEX      LIKE  SY-INDEX.

*& 화면의 값을 이벤트 없이 읽고 변경할때 사용
DATA: SCR_FIELDS LIKE DYNPREAD  OCCURS 0 WITH HEADER LINE,
      FELD_TABLE LIKE DYNPREAD  OCCURS 0 WITH HEADER LINE.

* 사업부
DATA: BEGIN OF GT_NFCTR OCCURS 0,
        NFCTR       LIKE ZNFT0005-NFCTR,
        NTEXT       LIKE ZNFT0005-NTEXT,
      END OF GT_NFCTR.

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

*
DATA: BEGIN OF GT_SAVE OCCURS 0,
        ERDAT       LIKE ZNFT1054-ERDAT,
        ERNAM       LIKE ZNFT1054-ERNAM,
        VRSIO       LIKE ZNFT1054-VRSIO,
      END   OF GT_SAVE.

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

DATA: GV_TCODE TYPE SY-TCODE,
      GV_TITLE TYPE CHAR50  .

* 회사코드관련 정보
DATA: GV_WAERS      LIKE T001-WAERS,    "Currency
      GV_LAND1      LIKE T001-LAND1,    "Country
      GV_BUTXT      LIKE T001-BUTXT,    "Company Name
      GV_KTOPL      LIKE T001-KTOPL,    "Chart of Account
      GV_KOKRS      LIKE TKA02-KOKRS.   "Controlling Area

* RANGES 변수
RANGES : R_BY_SL FOR ZNFT1020-BY_SL,
         R_RQTYP FOR ZNFT1010-RQTYP.

RANGES : R_VRSIO FOR ZNFT1054-VRSIO,
         R_SVDAT FOR ZNFT1054-ERDAT,
         R_SRNAM FOR ZNFT1054-ERNAM.

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
