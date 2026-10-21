*&---------------------------------------------------------------------*
*&  Include           ZNFR2320TOP
*&---------------------------------------------------------------------*

INCLUDE ZNFR2320CLS.

TABLES: ZNFT1000,
        ZNFT1010,
        ZNFT1011,
        ZNFT1020,
        ZNFT1030,
        ZNFT1040,
        ZNFT1041,
        ZNFT1091.

DATA: BEGIN OF GT_MAIN OCCURS 0,
        BUKRS       LIKE ZNFT1040-BUKRS,   "회사코드
        SHFNO       LIKE ZNFT1040-SHFNO,   "만기이동요청번호
        H_NO1       LIKE ZNFT1041-H_NO1,   "항번
        DRSTA       LIKE ZNFT1040-DRSTA,   "만기이동결재상태
        DRSTA_NM    TYPE CHAR10        ,   "결재상태명
        ERDAT       LIKE ZNFT1040-ERDAT,   "만기이동요청일
        YNCAN       LIKE ZNFT1040-YNCAN,   "취소여부
        REMON       LIKE ZNFT1041-REMON,   "요청만기월
        RMENG       LIKE ZNFT1041-RMENG,   "요청수량
        MEINS       LIKE ZNFT1041-MEINS,   "단위
        BIGO4       LIKE ZNFT1040-BIGO4,   "만기이동요청사유
        RUDAT       LIKE ZNFT1041-RUDAT,   "신규집행일
        ENDAT       LIKE ZNFT1041-ENDAT,   "신규만기일
        PRICE       LIKE ZNFT1041-PRICE,   "신규집행단가
        MISPD       LIKE ZNFT1041-MISPD,   "신규Spread
        WAERS       LIKE ZNFT1041-WAERS,   "통화
        NFUTN       LIKE ZNFT1041-NFUTN,   "신규선물집행번호(이동후)
        OFUTN       LIKE ZNFT1040-OFUTN,   "신규선물집행번호(이동전)
        FCM         LIKE ZNFT1020-FCM,     "FCM
        NAME1       LIKE LFA1-NAME1,       "FCM 명
        RUDAT1      LIKE ZNFT1020-RUDAT,   "집행일
        NFKEY       LIKE ZNFT1020-NFKEY,   "비철구분
        BY_SL       LIKE ZNFT1020-BY_SL,   "Buy/Sell
        BSTXT(10),                         "Buy/Sell
        ENDAT1      LIKE ZNFT1020-ENDAT,   "만기일
        MITYP       LIKE ZNFT1020-MITYP,   "집행유형
        MITPT(20),                         "집행유형내역
        MISPD1      LIKE ZNFT1020-MISPD,   "Spread
        MIMON       LIKE ZNFT1020-MIMON,   "기준월
        PRICE1      LIKE ZNFT1020-PRICE,   "집행단가
        EMENG       LIKE ZNFT1020-EMENG,   "집행수량
        CONFM       LIKE ZNFT1020-CONFM,   "선물집행 결재상태
        YNCAN1      LIKE ZNFT1020-YNCAN,   "선물집행 취소여부
        YNFIN       LIKE ZNFT1020-YNFIN,   "선물집행 정산여부
        YNNET       LIKE ZNFT1020-YNNET,   "선물집행 넷팅여부
        PRCTR       LIKE ZNFT1000-PRCTR,   "손익센터
        PTEXT       LIKE ZNFT0004-PTEXT,   "손익센터명
        CONNO       LIKE ZNFT1011-CONNO,   "계약번호
        COTXT       LIKE ZNFT1000-COTXT,   "계약명
        CFUTN       LIKE ZNFT1030-CFUTN,   "신규선물집행(이동후)에 대한 청산선물집행번호
        CFUTN_O     LIKE ZNFT1030-CFUTN,   "신규선물집행(이동전)에 대한 청산선물집행번호
        VKGRP       LIKE ZNFT1000-VKGRP,   "영업그룹
        VTEXT       LIKE ZNFT0003-VTEXT,   "영업그룹명
        KUNNR       LIKE ZNFT1000-KUNNR,   "고객코드
        NCUST       LIKE ZNFT1000-NCUST,   "고객명
        GUBUN       LIKE ZNFT1041-GUBUN,   "생성구분
        SALER       LIKE ZNFT1000-SALER,   "영업담당자
        CRUDAT       LIKE ZNFT1030-RUDAT,   "신규 청산집행일
        CENDAT       LIKE ZNFT1030-ENDAT,   "신규 청산만기일
        CPRICE       LIKE ZNFT1030-PRICE,   "신규 청산집행단가
        CMISPD       LIKE ZNFT1030-MISPD,   "신규 청산Spread
        REQNO        LIKE ZNFT1020-REQNO,
        CHECK,
        MARK,

        F_COL       TYPE LVC_T_SCOL,
        CELLTAB     TYPE LVC_T_STYL,
      END   OF GT_MAIN.

DATA: GS_MAIN       LIKE GT_MAIN.

DATA: GV_WAERS      LIKE T001-WAERS,    "Currency
      GV_LAND1      LIKE T001-LAND1,    "Country
      GV_BUTXT      LIKE T001-BUTXT,    "Company Name
      GV_KTOPL      LIKE T001-KTOPL,    "Chart of Account
      GV_KOKRS      LIKE TKA02-KOKRS.   "Controlling Area

DATA: BEGIN OF GT_PERNR OCCURS 0,
        PERNR     LIKE PA0105-PERNR,
      END   OF GT_PERNR.

DATA: GV_PERNR      LIKE PA0105-PERNR,
      GV_ENAME      LIKE PA0001-ENAME,
      GV_PASWD      LIKE ZNFT1090-PASWD,
      GV_COMM,
      GV_FLAG.

DATA: GV_INT        TYPE I,
      GV_SAVE,
      GV_ANSWER,
      GV_ERROR.

DATA: GV_CURSOR   TYPE CHAR50,    " 커서위치
          GV_CURLIN     TYPE I.     " 라인번호

* RADIO BUTTON
DATA: RB_1(1),      "Old HCP
      RB_2(1),      "Market Carry
      RB_3(1).      "New HCP

RANGES: GR_BY_SL    FOR   ZNFT1020-BY_SL.

DATA: OK_CODE       LIKE SY-UCOMM,
      OK_SAVE       LIKE SY-UCOMM.

*___Change Doc 관리용
DATA: BEGIN OF GT_1020 OCCURS 0,
        UPDKZ.
        INCLUDE STRUCTURE ZNFT1020.
DATA: END   OF GT_1020.

*--> [CHM2507-00010]
DATA: BEGIN OF GT_1030 OCCURS 0,
        UPDKZ.
        INCLUDE STRUCTURE ZNFT1030.
DATA: END   OF GT_1030.
*<-- [CHM2507-00010]

DATA: BEGIN OF GT_1040 OCCURS 0,
        UPDKZ.
        INCLUDE STRUCTURE ZNFT1040.
DATA: END   OF GT_1040.

DATA: BEGIN OF GT_1041 OCCURS 0,
        UPDKZ.
        INCLUDE STRUCTURE ZNFT1041.
DATA: END   OF GT_1041.

DATA: YZNFT1020     LIKE ZNFT1020,
      YZNFT1030     LIKE ZNFT1030,
      YZNFT1040     LIKE ZNFT1040,
      XGT_1041      LIKE YZNFT1041 OCCURS 0 WITH HEADER LINE,
      YGT_1041      LIKE YZNFT1041 OCCURS 0 WITH HEADER LINE.

*___F4 Help용 변수
DATA: SELECTFIELD   LIKE  HELP_INFO-FIELDNAME,
      IT_FIELDS     LIKE  HELP_VALUE OCCURS 1 WITH HEADER LINE,
      SELECT_VALUE  LIKE  HELP_INFO-FLDVALUE,
      LD_TABIX      LIKE  SY-TABIX,
      GV_INDEX      LIKE  SY-INDEX.

DATA: SCR_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE,
      FELD_TABLE LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

*___FCM
DATA: BEGIN OF GT_FCM OCCURS 0,
        LIFNR       LIKE ZNFT0021-LIFNR,
        NAME1       LIKE LFA1-NAME1,
      END   OF GT_FCM.

*___손익센터
DATA: BEGIN OF GT_PRCTR OCCURS 0,
        PRCTR       LIKE ZNFT0003-PRCTR,
        PTEXT       LIKE ZNFT0003-PTEXT,
      END OF GT_PRCTR.

*___영업그룹
DATA: BEGIN OF GT_VKGRP OCCURS 0,
        VKGRP       LIKE ZNFT0003-VKGRP,
        VTEXT       LIKE ZNFT0003-VTEXT,
      END OF GT_VKGRP.

*___ALV용 변수
DATA: GC_CONTAINER_NAME     TYPE SCRFNAME VALUE 'CONTAINER',
      GC_CUSTOM_CONTAINER   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GC_ALV_GRID           TYPE REF TO CL_GUI_ALV_GRID,
      GC_EVENT_HANDLER      TYPE REF TO LCL_EVENT_HANDLER,
      GS_LAYOUT             TYPE LVC_S_LAYO,
      GT_SORT               TYPE LVC_T_SORT WITH HEADER LINE,
      GT_FIELDCAT           TYPE LVC_T_FCAT WITH HEADER LINE,
      GS_FIELDCAT           TYPE LVC_S_FCAT,
      GS_SCROLL             TYPE LVC_S_STBL,
      GT_COLS               TYPE LVC_T_COL,
      GS_COLS               TYPE LVC_S_COL,
      GT_ROWS               TYPE LVC_T_ROW,
      GS_ROWS               TYPE LVC_S_ROW,
      GT_F4                 TYPE LVC_T_F4,
      GS_F4                 TYPE LVC_S_F4.

DATA: GT_EXCLUDE            TYPE UI_FUNCTIONS,
      GS_VARIANT            TYPE DISVARIANT,
      GV_ITAB               LIKE GS_FIELDCAT-TABNAME,
      GV_POS                LIKE GS_FIELDCAT-COL_POS.
