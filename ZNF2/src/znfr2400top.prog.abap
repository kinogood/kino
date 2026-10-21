*&---------------------------------------------------------------------*
*&  Include           ZNFR2400TOP
*&---------------------------------------------------------------------*

INCLUDE ZNFR2400CLS.

CONSTANTS: GC_TCODE1  LIKE SY-TCODE VALUE 'ZNF2R2400',   "점검 및 확정
           GC_TCODE2  LIKE SY-TCODE VALUE 'ZNF2R2400R'.  "확정 취소

TABLES: ZNFT1020,
        ZNFT1030,
        ZNFT1050.

DATA: BEGIN OF GT_MAIN OCCURS 0,
        CHECK,
        BUKRS       LIKE ZNFT1020-BUKRS,     "회사코드
        ENDAT       LIKE ZNFT1020-ENDAT,     "만기일
        FCM         LIKE ZNFT1020-FCM,       "FCM
        NAME1       LIKE LFA1-NAME1,         "FCM 명
        NFBUY       TYPE I,                  "신규 Buy  건수
        NFSEL       TYPE I,                  "신규 Sell 건수
        CFBUY       TYPE I,                  "청산 Buy  건수
        CFSEL       TYPE I,                  "청산 Sell 건수
        NBMNG       LIKE ZNFT1020-EMENG,     "신규 Buy  수량
        NSMNG       LIKE ZNFT1020-EMENG,     "신규 Sell 수량
        CBMNG       LIKE ZNFT1020-EMENG,     "청산 Buy  수량
        CSMNG       LIKE ZNFT1020-EMENG,     "청산 Sell 수량
        MEINS       LIKE ZNFT1020-MEINS,     "단위
        NCCHK(4),                            "오류확인
        NETIG(4),                            "넷팅생성
        CONFM(4),                            "손익확정
        TRWON(4),                            "원화환산
        CREFI(4),                            "전표생성
      END   OF GT_MAIN.

DATA: BEGIN OF GT_DETL OCCURS 0,
        ICON(4),                             "점검상태
        BUKRS       LIKE ZNFT1020-BUKRS,     "회사코드
        CONNO       LIKE ZNFT1011-CONNO,     "계약번호
        COTXT       LIKE ZNFT1000-COTXT,     "계약명
        COTYP       LIKE ZNFT1000-COTYP,     "계약유형
        COTPT(20),                           "계약유형내역
        CSTAT       LIKE ZNFT1000-CSTAT,     "계약상태
        CSTXT(20),                           "계약상태내역
        KUNNR       LIKE ZNFT1000-KUNNR,     "고객코드
        NAMAG       LIKE KNA1-NAME1,         "고객명
        NFKEY2      LIKE ZNFT1001-NFKEY,     "계약비철구분
        FILE,                                "파일첨부여부
        REQNO       LIKE ZNFT1020-REQNO,     "선물요청번호
        H_NO1       LIKE ZNFT1020-H_NO1,     "선물요청항번
        NFUTN       LIKE ZNFT1020-NFUTN,     "신규 선물집행번호
        NFKEY       LIKE ZNFT1020-NFKEY,     "신규 비철구분
        RUDAT       LIKE ZNFT1020-RUDAT,     "신규 집행일
        FCM         LIKE ZNFT1020-FCM,       "신규 FCM
        NAMLF       LIKE LFA1-NAME1,         "신규 FCM명
        BY_SL       LIKE ZNFT1020-BY_SL,     "신규 Buy/Sell
        BSTXT(10),                           "신규 Buy/Sell
        ENDAT       LIKE ZNFT1020-ENDAT,     "신규 만기일
        MITYP       LIKE ZNFT1020-MITYP,     "신규 집행유형
        MITPT(20),                           "신규 집행유형내역
        MISPD       LIKE ZNFT1020-MISPD,     "신규 Spread
        MIMON       LIKE ZNFT1020-MIMON,     "신규 매입기준월
        PRICE       LIKE ZNFT1020-PRICE,     "신규 집행단가
        WAERS       LIKE ZNFT1020-WAERS,     "신규 통화
        EMENG       LIKE ZNFT1020-EMENG,     "신규 집행수량
        MEINS       LIKE ZNFT1020-MEINS,     "신규 단위
        MISUS       LIKE ZNFT1020-MISUS,     "신규 수수료여부
        CONFM       LIKE ZNFT1020-CONFM,     "신규 결재상태
        CFMTX(20),                           "신규 결재상태내역
        YNCAN       LIKE ZNFT1020-YNCAN,     "신규 취소여부
        YNFIN       LIKE ZNFT1020-YNFIN,     "신규 마감여부
        CFUTN       LIKE ZNFT1030-CFUTN,     "청산 선물집행번호
        NFKEY1      LIKE ZNFT1030-NFKEY,     "청산 비철구분
        RUDAT1      LIKE ZNFT1030-RUDAT,     "청산 집행일
        FCM1        LIKE ZNFT1030-FCM,       "청산 FCM
        NAMLF1      LIKE LFA1-NAME1,         "청산 FCM명
        BY_SL1      LIKE ZNFT1030-BY_SL,     "청산 Buy/Sell
        BSTXT1(10),                          "청산 Buy/Sell
        ENDAT1      LIKE ZNFT1030-ENDAT,     "청산 만기일
        MITYP1      LIKE ZNFT1030-MITYP,     "청산 집행유형
        MITPT1(20),                          "청산 집행유형내역
        MISPD1      LIKE ZNFT1030-MISPD,     "청산 Spread
        MIMON1      LIKE ZNFT1030-MIMON,     "청산 매입기준월
        PRICE1      LIKE ZNFT1030-PRICE,     "청산 집행단가
        WAERS1      LIKE ZNFT1030-WAERS,     "청산 통화
        EMENG1      LIKE ZNFT1030-EMENG,     "청산 집행수량
        MEINS1      LIKE ZNFT1030-MEINS,     "청산 단위
        MISUS1      LIKE ZNFT1030-MISUS,     "청산 수수료여부
        CONFM1      LIKE ZNFT1030-CONFM,     "청산 결재상태
        CFMTX1(20),                          "청산 결재상태내역
        YNCAN1      LIKE ZNFT1030-YNCAN,     "청산 취소여부
        YNFIN1      LIKE ZNFT1030-YNFIN,     "청산 마감여부
        MESSAGE(200),                        "메시지
      END   OF GT_DETL.

DATA: GT_1020       LIKE ZNFT1020 OCCURS 0 WITH HEADER LINE,
      GT_1050       LIKE ZNFT1050 OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF GT_1030 OCCURS 0.
        INCLUDE STRUCTURE ZNFT1030.
DATA:   CHECK,
      END   OF GT_1030.

DATA: GV_FRDAT      LIKE SY-DATLO,
      GV_TODAT      LIKE SY-DATLO.

DATA: GV_TRTYP      LIKE T180-TRTYP,
      GV_TITLE(50).

DATA: GV_ERROR,
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
*      GC_EVENT_HANDLER1     TYPE REF TO LCL_EVENT_HANDLER,
      GC_CONTAINER_NAME2    TYPE SCRFNAME VALUE 'CONTAINER2',
      GC_CUSTOM_CONTAINER2  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GC_ALV_GRID2          TYPE REF TO CL_GUI_ALV_GRID,
      GC_EVENT_HANDLER2     TYPE REF TO LCL_EVENT_HANDLER,
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
