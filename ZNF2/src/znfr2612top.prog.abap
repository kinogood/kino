*&---------------------------------------------------------------------*
*&  Include           ZNFR2612TOP
*&---------------------------------------------------------------------*
TYPE-POOLS : SLIS.

TABLES: ZNFT1000, ZNFT1011, ZNFT1020, ZNFT1051, ZNFT1055, ZNFT1041,
        LFA1.

************************************************************************
* GLOBAL Structure & Internal Table
************************************************************************

* ALV LIST :
DATA: BEGIN OF GS_OUTTAB,
  ICON(4),
  CHECK,
  BUKRS    LIKE ZNFT1051-BUKRS,
  NFCTR    LIKE ZNFT1000-NFCTR,
  NFCTR_NM LIKE ZNFT0005-NTEXT,
  PRCTR    LIKE ZNFT1000-PRCTR,
  PRCTR_NM LIKE ZNFT0004-PTEXT,
  VKGRP    LIKE ZNFT1000-VKGRP,
  VKGRP_NM LIKE ZNFT0003-VTEXT,
  KUNNR    LIKE ZNFT1000-KUNNR,
  NCUST    LIKE ZNFT1000-NCUST,
  REQNO    LIKE ZNFT1051-REQNO,
*C20130911_02959 start
  CONNO    LIKE ZNFT1011-CONNO,
  COTXT    LIKE ZNFT1000-COTXT,
*C20130911_02959 end
  H_NO1    LIKE ZNFT1051-H_NO1,
  RQTYP    LIKE ZNFT1010-RQTYP,
  RQTYP_NM TYPE CHAR20,
  NFUTN    LIKE ZNFT1051-NFUTN,
  CFUTN    LIKE ZNFT1051-NFUTN,
  NBY_SL   LIKE ZNFT1051-NBY_SL,

* 최상위 집행번호 추가 by 박우진 (2026.08.10).
  SUPREME  LIKE ZNFT1051-NFUTN,   "최상위 집행번호
  B_NFUTN  LIKE ZNFT1051-NFUTN,   " Buy  집행번호
  S_NFUTN  LIKE ZNFT1051-NFUTN,   " Sell 집행번호
  FCM      LIKE ZNFT1051-FCM  ,
  FCM_NM   LIKE LFA1-NAME1    ,
  N_RUDAT  LIKE ZNFT1020-RUDAT,
  C_RUDAT  LIKE ZNFT1030-RUDAT,
  B_RUDAT  LIKE ZNFT1020-RUDAT,   " Buy  집행일
  S_RUDAT  LIKE ZNFT1030-RUDAT,   " Sell 집행일
  ENDAT    LIKE ZNFT1051-ENDAT,
  EMENG    LIKE ZNFT1051-EMENG,
  MEINS    LIKE ZNFT1051-MEINS,
  NFKEY    LIKE ZNFT1051-NFKEY,
  KPRLO    LIKE ZNFT1051-KPRLO,
  KAERS    LIKE ZNFT1051-KAERS,
  UPRLO    LIKE ZNFT1051-UPRLO,
  UAERS    LIKE ZNFT1051-UAERS,
  KURSF    LIKE ZNFT1051-KURSF,
  ZBELNR LIKE ZNFT1051-ZBELNR,
  ZGJAHR LIKE ZNFT1051-ZGJAHR,
*  YBELNR LIKE ZNFT1051-YBELNR,
*  YGJAHR LIKE ZNFT1051-YGJAHR,
  AENAM  LIKE ZNFT1051-AENAM,
  AEDAT   LIKE ZNFT1051-AEDAT,
  AEZET   LIKE ZNFT1051-AEZET,
                                 " ### BUY ###
  NMISPD   LIKE ZNFT1051-NMISPD, " 매입SPREAD : BUY-NMISPD /SELL-CMISPD
  NPRICE   LIKE ZNFT1051-NPRICE, " 단가       : BUY-NPRICE /SELL-CPRICE
  N_FEE    LIKE ZNFT1051-N_FEE,  " 수수료     : BUY-N_FEE / SELL-C_FEE
                                 " ### SELL ###
  CMISPD   LIKE ZNFT1051-CMISPD, " 매입SPREAD : BUY-NMISPD /SELL-CMISPD
  CPRICE   LIKE ZNFT1051-CPRICE, " 단가       : BUY-NPRICE /SELL-CPRICE
  C_FEE    LIKE ZNFT1051-C_FEE , " 수수료     : BUY-N_FEE / SELL-C_FEE

                                 " ### BUY ###
  B_MISPD  LIKE ZNFT1051-NMISPD,
  B_FEE    LIKE ZNFT1051-N_FEE ,
  B_PRICE  LIKE ZNFT1051-NPRICE,
  BUY_AMT  TYPE DMBTR,           " 금액(BUY)  : EMENG * (PRICE+SPREAD)
                                 " ### SELL ###
  S_MISPD  LIKE ZNFT1051-CMISPD,
  S_PRICE  LIKE ZNFT1051-CPRICE,
  S_FEE    LIKE ZNFT1051-C_FEE ,
  SELL_AMT TYPE DMBTR,           " 금액(SELL) : EMENG * (PRICE+SPREAD)

  WAERS    LIKE ZNFT1051-WAERS ,
*-<< 기능개선 154373 - 영업담당자 추가
  SALER    LIKE ZNFT1000-SALER,  " 영업담당자

  YBELNR LIKE ZNFT1055-YBELNR,
  YGJAHR LIKE ZNFT1055-YGJAHR,
  KONWA  LIKE ZNFT1055-KONWA,
  P_KPRLO   LIKE ZNFT1055-KPRLO,
  BUDAT       LIKE ZNFT1055-BUDAT,
  KRATE      LIKE ZNFT1055-KRATE,
  TKRATE      LIKE ZNFT1055-KRATE,
  REMON      LIKE ZNFT1041-REMON,
*->> 기능개선 154373
  CELLTAB  TYPE LVC_T_STYL,      " Cell 단위 수정 스타일
  COLINFO  TYPE LVC_T_SCOL.      " CELL 색상 지정
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

* 영업그룹
DATA: BEGIN OF GT_VKGRP OCCURS 0,
        VKGRP       LIKE ZNFT0003-VKGRP,
        VTEXT       LIKE ZNFT0003-VTEXT,
      END OF GT_VKGRP.

* FCM
DATA: BEGIN OF GT_FCM OCCURS 0,
        LIFNR       LIKE ZNFT0021-LIFNR,
        NAME1       LIKE LFA1-NAME1,
      END   OF GT_FCM.

DATA:  GT_1051       LIKE ZNFT1051 OCCURS 0 WITH HEADER LINE.


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

DATA: GV_BLDAT      LIKE BKPF-BLDAT,
      GV_BUDAT      LIKE BKPF-BUDAT,
      GV_BELNR      LIKE BKPF-BELNR,
      GV_RATIO       LIKE ZNFT1055-KRATE .

* 회사코드관련 정보
DATA: GV_WAERS      LIKE T001-WAERS,    "Currency
      GV_LAND1      LIKE T001-LAND1,    "Country
      GV_BUTXT      LIKE T001-BUTXT,    "Company Name
      GV_KTOPL      LIKE T001-KTOPL,    "Chart of Account
      GV_KOKRS      LIKE TKA02-KOKRS.   "Controlling Area

DATA: GV_UPRLO      LIKE ZNFT1052-UPRLO,     "전체손익(USD)
      GV_UAERS      LIKE ZNFT1052-UAERS,     "통화(USD)
      GV_KPRLO      LIKE ZNFT1052-KPRLO,     "개별손익(KRW)
      GV_KAERS      LIKE ZNFT1052-KAERS,     "통화(KRW)
      GV_LPRLO      LIKE ZNFT1052-KPRLO,     "환산손익(KRW)
      GV_DIFFR      LIKE ZNFT1052-KPRLO.     "차이(KRW)

DATA: GV_FCM        LIKE ZNFT1052-FCM.

DATA: GV_FRDAT      LIKE SY-DATLO,
      GV_TODAT      LIKE SY-DATLO.

* 최상위 번호찾기 by 박우진 (2026.08.10).
DATA: BEGIN OF GT_NFUTN OCCURS 0,
        NFUTN       LIKE ZNFT1020-NFUTN,
      END   OF GT_NFUTN.



*___BDC용 변수
TABLES : CTU_PARAMS.

DATA : BEGIN OF GT_BDCTAB OCCURS 0.
        INCLUDE STRUCTURE BDCDATA.
DATA : END   OF GT_BDCTAB.

DATA : GT_RETMSG LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.

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
      GC_ALV_GRID1          TYPE REF TO CL_GUI_ALV_GRID,
      GT_FILTER   TYPE LVC_T_FILT.

DATA: BEGIN OF GT_EXCL OCCURS 0,
        FCODE       LIKE SY-UCOMM,
      END   OF GT_EXCL.

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
