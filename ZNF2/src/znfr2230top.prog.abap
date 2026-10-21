*&---------------------------------------------------------------------*
*&  Include           ZNFR2230TOP
*&---------------------------------------------------------------------*

INCLUDE ZNFR2230CLS.

TABLES: ZNFT1000,
        ZNFT1020,
        ZNFT1030.

DATA: BEGIN OF GT_MAIN OCCURS 0.
        INCLUDE STRUCTURE ZNFT1020.
DATA:   CHECK,
        BSTXT(10),                              "Buy/Sell
        NCIND,                                  "신규/청산구분
        NCTXT(10),                              "신규/청산 텍스트
        CFMTX(20),                              "결재상태 내역
        NAME1       LIKE LFA1-NAME1,            "FCM 명
        NFUTN1      LIKE ZNFT1030-NFUTN,        "청산-신규선물집행번호
        RUDAT1      LIKE ZNFT1020-RUDAT,        "청산-신규선물집행일
        ENDMM       LIKE ZNFT1011-ENDMM,        "만기월
        REQTY       LIKE ZNFT1011-EMENG,        "요청수량
        REQME       LIKE ZNFT1011-MEINS,        "단위
        RQTYP       LIKE ZNFT1010-RQTYP,        "요청유형
        RQTPT(20),                              "요청유형내역
        CONNO       LIKE ZNFT1011-CONNO,        "계약번호
        COTXT       LIKE ZNFT1000-COTXT,        "계약명
        PRCTR       LIKE ZNFT1000-PRCTR,        "손익센터
        PTEXT       LIKE ZNFT0004-PTEXT,        "손익센터명
        KUNNR       LIKE ZNFT1000-KUNNR,        "고객번호
        NCUST       LIKE ZNFT1000-NCUST,        "고객명
        SALER       LIKE ZNFT1000-SALER,        "영업담당자
        PRIND(20),                              "가격구분
        SUJUP(20),                              "비철수주가

        F_COL       TYPE LVC_T_SCOL,
        CELLTAB     TYPE LVC_T_STYL,
      END   OF GT_MAIN.

DATA: GT_1020       LIKE ZNFT1020 OCCURS 0 WITH HEADER LINE,
      GT_1030       LIKE ZNFT1030 OCCURS 0 WITH HEADER LINE.

DATA: GS_MAIN       LIKE GT_MAIN.

DATA: GV_WAERS      LIKE T001-WAERS,     "Currency
      GV_LAND1      LIKE T001-LAND1,     "Country
      GV_BUTXT      LIKE T001-BUTXT,     "Company Name
      GV_KTOPL      LIKE T001-KTOPL,     "Chart of Account
      GV_KOKRS      LIKE TKA02-KOKRS.    "Controlling Area

DATA: GV_ANSWER,
      GV_ERROR.

RANGES: GR_BY_SL    FOR  ZNFT1020-BY_SL.

DATA: OK_CODE       LIKE SY-UCOMM,
      OK_SAVE       LIKE SY-UCOMM.

*___Change Doc. 용
DATA: YZNFT1020     LIKE ZNFT1020,
      YZNFT1030     LIKE ZNFT1030.

*___F4 Help용 변수
DATA: SELECTFIELD   LIKE  HELP_INFO-FIELDNAME,
      IT_FIELDS     LIKE  HELP_VALUE OCCURS 1 WITH HEADER LINE,
      SELECT_VALUE  LIKE  HELP_INFO-FLDVALUE,
      LD_TABIX      LIKE  SY-TABIX,
      GV_INDEX      LIKE  SY-INDEX.

DATA: SCR_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE,
      FELD_TABLE LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

*___손익센터
DATA: BEGIN OF GT_PRCTR OCCURS 0,
        PRCTR       LIKE ZNFT0003-PRCTR,
        PTEXT       LIKE ZNFT0003-PTEXT,
      END OF GT_PRCTR.

*___FCM
DATA: BEGIN OF GT_FCM OCCURS 0,
        LIFNR       LIKE ZNFT0021-LIFNR,
        NAME1       LIKE LFA1-NAME1,
      END   OF GT_FCM.

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
