*&---------------------------------------------------------------------*
*&  Include           ZNFR2200TOP
*&---------------------------------------------------------------------*

CONTROLS: TC1       TYPE TABLEVIEW USING SCREEN 100.

TABLES: ZNFT0074.

DATA: BEGIN OF GT_MAIN OCCURS 0,
        CHECK,
        ZFLAG       LIKE ZNFT0074-ZFLAG,   "처리유형
        ZCOMP(10),                         "처리유형텍스트
        BUKRS       LIKE ZNFT1021-BUKRS,   "회사코드
        ZEPRO       LIKE ZNFT1021-ZEPRO,   "e-Pro 번호
        FCM         LIKE ZNFT1021-FCM,     "FCM 거래선
        NAME1       LIKE LFA1-NAME1,       "FCM 거래선명
        NFKEY       LIKE ZNFT1021-NFKEY,   "NF Key
        RUDAT       LIKE ZNFT1021-RUDAT,   "집행일
        BY_SL       LIKE ZNFT1021-BY_SL,   "Buy/Sell
        ENDAT       LIKE ZNFT1021-ENDAT,   "만기일
        MITYP       LIKE ZNFT1021-MITYP,   "집행유형
        MISPD       LIKE ZNFT1021-MISPD,   "Spread
        MIMON       LIKE ZNFT1021-MIMON,   "기준월
        PRICE       LIKE ZNFT1021-PRICE,   "집행단가
        WAERS       LIKE ZNFT1021-WAERS,   "통화
        EMENG       LIKE ZNFT1021-EMENG,   "집행수량
        MEINS       LIKE ZNFT1021-MEINS,   "단위
        MISUS       LIKE ZNFT1021-MISUS,   "수수료여부
        ZNOTE       LIKE ZNFT1021-ZNOTE,   "비고
      END   OF GT_MAIN.

DATA: GS_MAIN       LIKE GT_MAIN.

DATA: GT_0074       LIKE ZNFT0074 OCCURS 0 WITH HEADER LINE,
      GT_1021       LIKE ZNFT1021 OCCURS 0 WITH HEADER LINE.

DATA: GV_CURSOR(30),
      GV_CURLIN     TYPE I.

DATA: GV_ANSWER,
      GV_ERROR.

RANGES: GR_ZFLAG    FOR  ZNFT0074-ZFLAG,
        GR_BY_SL    FOR  ZNFT0074-BY_SL.

DATA: OK_CODE       LIKE SY-UCOMM,
      OK_SAVE       LIKE SY-UCOMM.

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
