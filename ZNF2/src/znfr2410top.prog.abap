*&---------------------------------------------------------------------*
*&  Include           ZNFR2410TOP
*&---------------------------------------------------------------------*

INCLUDE ZNFR2410CLS.

CONSTANTS: GC_TCODE1  LIKE SY-TCODE       VALUE 'ZNF2R2410',  "자동생성
           GC_TCODE2  LIKE SY-TCODE       VALUE 'ZNF2R2410R', "생성취소
           GC_PRCTR   LIKE ZNFT1000-PRCTR VALUE '0000010101'. "손익센터

TABLES: ZNFT1020,
        ZNFT1030,
        ZNFT1050.

DATA: BEGIN OF GT_MAIN OCCURS 0,
        BUKRS       LIKE ZNFT1020-BUKRS,     "회사코드
        ENDAT       LIKE ZNFT1020-ENDAT,     "만기일
        FCM         LIKE ZNFT1020-FCM,       "FCM
        NAME1       LIKE LFA1-NAME1,         "FCM 명
        NFKEY       LIKE ZNFT1020-NFKEY,     "비철구분
        NFCNT       TYPE I,                  "신규건수
        BMENG       LIKE ZNFT1020-EMENG,     "Buy 수량
        SMENG       LIKE ZNFT1020-EMENG,     "Sell 수량
        MEINS       LIKE ZNFT1020-MEINS,     "단위
        NCCHK(4),                            "오류확인
        NETIG(4),                            "넷팅생성
        CONFM(4),                            "손익확정
        TRWON(4),                            "원화환산
        CREFI(4),                            "전표생성
        CHECK,
        MARK,

        F_COL       TYPE LVC_T_SCOL,
        CELLTAB     TYPE LVC_T_STYL,
      END   OF GT_MAIN.

DATA: GS_MAIN       LIKE GT_MAIN.

DATA: BEGIN OF GT_DETL OCCURS 0,
        ICON(4),                            "상태
        BUKRS       LIKE ZNFT1020-BUKRS,    "회사코드
        CONNO       LIKE ZNFT1011-CONNO,    "계약번호
        COTXT       LIKE ZNFT1000-COTXT,    "계약명
        COTYP       LIKE ZNFT1000-COTYP,    "계약유형
        COTPT(20),                          "계약유형내역
        CSTAT       LIKE ZNFT1000-CSTAT,    "계약상태
        CSTXT(20),                          "계약상태내역
        KUNNR       LIKE ZNFT1000-KUNNR,    "고객코드
        NAMAG       LIKE KNA1-NAME1,        "고객명
        NFKEY2      LIKE ZNFT1001-NFKEY,    "계약비철구분
        FILE,                               "파일첨부여부
        REQNO       LIKE ZNFT1020-REQNO,    "선물요청번호
        H_NO1       LIKE ZNFT1020-H_NO1,    "선물요청항번
        NFUTN       LIKE ZNFT1020-NFUTN,    "신규선물집행번호
        NFKEY       LIKE ZNFT1020-NFKEY,    "신규비철구분
        RUDAT       LIKE ZNFT1020-RUDAT,    "신규집행일
        FCM         LIKE ZNFT1020-FCM,      "신규FCM
        NAMLF       LIKE LFA1-NAME1,        "신규FCM 명
        BY_SL       LIKE ZNFT1020-BY_SL,    "신규 Buy/Sell
        BSTXT(10),                          "신규 Buy/Sell
        ENDAT       LIKE ZNFT1020-ENDAT,    "신규만기일
        MITYP       LIKE ZNFT1020-MITYP,    "신규집행유형
        MITPT(20),                          "신규집행유형내역
        MISPD       LIKE ZNFT1020-MISPD,    "신규Spread
        MIMON       LIKE ZNFT1020-MIMON,    "신규매입기준월
        PRICE       LIKE ZNFT1020-PRICE,    "신규집행단가
        WAERS       LIKE ZNFT1020-WAERS,    "신규통화
        EMENG       LIKE ZNFT1020-EMENG,    "신규집행수량
        MEINS       LIKE ZNFT1020-MEINS,    "신규단위
        MISUS       LIKE ZNFT1020-MISUS,    "신규수수료여부
        CONFM       LIKE ZNFT1020-CONFM,    "신규결재상태
        CFMTX(20),                          "신규결재상태내역
        YNCAN       LIKE ZNFT1020-YNCAN,    "신규취소여부
        YNFIN       LIKE ZNFT1020-YNFIN,    "신규정산여부
        CFUTN       LIKE ZNFT1030-NFUTN,    "청산선물집행번호
        NFKEY1      LIKE ZNFT1030-NFKEY,    "청산비철구분
        RUDAT1      LIKE ZNFT1030-RUDAT,    "청산집행일
        FCM1        LIKE ZNFT1030-FCM,      "청산FCM
        BY_SL1      LIKE ZNFT1030-BY_SL,    "청산 Buy/Sell
        BSTXT1(10),                         "청산 Buy/Sell
        ENDAT1      LIKE ZNFT1030-ENDAT,    "청산만기일
        MITYP1      LIKE ZNFT1030-MITYP,    "청산집행유형
        MIMON1      LIKE ZNFT1030-MIMON,    "청산매입기준월
        PRICE1      LIKE ZNFT1030-PRICE,    "청산집행단가
        WAERS1      LIKE ZNFT1030-WAERS,    "청산통화
        EMENG1      LIKE ZNFT1030-EMENG,    "청산집행수량
        MEINS1      LIKE ZNFT1030-MEINS,    "청산단위
        MISUS1      LIKE ZNFT1030-MISUS,    "청산수수료여부
        PRCTR       LIKE ZNFT1000-PRCTR,    "손익센터
        PTEXT       LIKE ZNFT0004-PTEXT,    "손익센터명
        CONFM1      LIKE ZNFT1030-CONFM,    "청산결재상태
        YNCAN1      LIKE ZNFT1030-YNCAN,    "청산취소여부
        YNFIN1      LIKE ZNFT1030-YNFIN,    "청산정산여부
        MESSAGE(200),

        F_COL       TYPE LVC_T_SCOL,
        CELLTAB     TYPE LVC_T_STYL,
      END   OF GT_DETL.

DATA: GT_1020       LIKE ZNFT1020 OCCURS 0 WITH HEADER LINE,
      GT_1030       LIKE ZNFT1030 OCCURS 0 WITH HEADER LINE,
      GT_1030N      LIKE ZNFT1030 OCCURS 0 WITH HEADER LINE,
      GT_1050       LIKE ZNFT1050 OCCURS 0 WITH HEADER LINE.

DATA: GV_CUPRC      LIKE ZNFT1030-PRICE,    "생성기준가 - CU
      GV_ALPRC      LIKE ZNFT1030-PRICE,    "생성기준가 - AL
      GV_PBPRC      LIKE ZNFT1030-PRICE,    "생성기준가 - PB
      GV_NIPRC      LIKE ZNFT1030-PRICE,    "생성기준가 - NI
      GV_SNPRC      LIKE ZNFT1030-PRICE,    "생성기준가 - SN "189023
      GV_WAERS      LIKE ZNFT1030-WAERS.    "통화

DATA: GV_FRDAT      LIKE SY-DATLO,
      GV_TODAT      LIKE SY-DATLO.

DATA: GV_LWAERS     LIKE T001-WAERS,    "Currency
      GV_LAND1      LIKE T001-LAND1,    "Country
      GV_BUTXT      LIKE T001-BUTXT,    "Company Name
      GV_KTOPL      LIKE T001-KTOPL,    "Chart of Account
      GV_KOKRS      LIKE TKA02-KOKRS.   "Controlling Area

DATA: GV_TRTYP      LIKE T180-TRTYP,
      GV_EFLAG,
      GV_TITLE(50).

DATA: GV_INT        TYPE I,
      GV_ERROR,
      GV_ANSWER.

DATA: BEGIN OF GT_EXCL OCCURS 0,
        FCODE       LIKE SY-UCOMM,
      END   OF GT_EXCL.

DATA: OK_CODE       LIKE SY-UCOMM,
      OK_SAVE       LIKE SY-UCOMM.

*___Change Doc. 용
DATA: YZNFT1020     LIKE ZNFT1020,
      YZNFT1030     LIKE ZNFT1030.

*___ALV용 변수
DATA: GC_CONTAINER_NAME1    TYPE SCRFNAME VALUE 'CONTAINER1',
      GC_CUSTOM_CONTAINER1  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GC_ALV_GRID1          TYPE REF TO CL_GUI_ALV_GRID,
      GC_EVENT_HANDLER1     TYPE REF TO LCL_EVENT_HANDLER,
      GC_CONTAINER_NAME2    TYPE SCRFNAME VALUE 'CONTAINER2',
      GC_CUSTOM_CONTAINER2  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GC_ALV_GRID2          TYPE REF TO CL_GUI_ALV_GRID,
      GC_EVENT_HANDLER2     TYPE REF TO LCL_EVENT_HANDLER,
      GS_LAYOUT             TYPE LVC_S_LAYO,
      GT_SORT               TYPE LVC_T_SORT WITH HEADER LINE,
      GT_FIELDCAT           TYPE LVC_T_FCAT WITH HEADER LINE,
      GT_FIELDCAT2          TYPE LVC_T_FCAT WITH HEADER LINE,
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
