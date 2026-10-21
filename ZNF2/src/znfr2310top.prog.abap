*&---------------------------------------------------------------------*
*&  Include           ZNFR2310TOP
*&---------------------------------------------------------------------*

CONSTANTS: GC_TCODE1  LIKE SY-TCODE VALUE 'ZNF2R2310',
           GC_TCODE2  LIKE SY-TCODE VALUE 'ZNF2R2311'.

TABLES: ZNFT1000,
        ZNFT1010,
        ZNFT1011,
        ZNFT1020,
        ZNFT1040,
        ZNFT1041.

DATA: BEGIN OF GT_MAIN OCCURS 0,
        CHECK,
        BUKRS       LIKE ZNFT1040-BUKRS,   "회사코드
        SHFNO       LIKE ZNFT1040-SHFNO,   "만기이동요청번호
        DRSTA       LIKE ZNFT1040-DRSTA,   "결재상태
        DRTXT(20),                         "결재상태내역
        PERNR       LIKE ZNFT1091-PERNR,   "승인자사번
        ENAME       LIKE PA0001-ENAME,     "승인자명
        H_NO1       LIKE ZNFT1041-H_NO1,   "항번
        SHFCNT      TYPE I,                "만기이동차수
        ERDAT       LIKE ZNFT1040-ERDAT,   "만기이동요청일
        REMON       LIKE ZNFT1041-REMON,   "요청만기월
        RMENG       LIKE ZNFT1041-RMENG,   "요청수량
        MEINS       LIKE ZNFT1041-MEINS,   "단위
        BIGO4       LIKE ZNFT1040-BIGO4,   "만기이동요청사유
        NFUTN       LIKE ZNFT1041-NFUTN,   "신규선물집행번호
        RUDAT       LIKE ZNFT1041-RUDAT,   "신규집행일
        ENDAT       LIKE ZNFT1041-ENDAT,   "신규만기일
        MISPD       LIKE ZNFT1041-MISPD,   "신규Spread
        PRICE       LIKE ZNFT1041-PRICE,   "신규집행단가
        WAERS       LIKE ZNFT1041-WAERS,   "통화
        OFUTN       LIKE ZNFT1040-OFUTN,   "선물집행번호
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
        REQNO       LIKE ZNFT1020-REQNO,   "선물요청번호
        H_NO2       LIKE ZNFT1020-H_NO1,   "선물요청항번
        CONNO       LIKE ZNFT1011-CONNO,   "계약번호
        COTXT       LIKE ZNFT1000-COTXT,   "계약명
        PRCTR       LIKE ZNFT1000-PRCTR,   "손익센터
        PTEXT       LIKE ZNFT0004-PTEXT,   "손익센터명
        VKGRP       LIKE ZNFT1000-VKGRP,   "영업그룹
        VTEXT       LIKE ZNFT0003-VTEXT,   "영업그룹명
        KUNNR       LIKE ZNFT1000-KUNNR,   "고객코드
        NCUST       LIKE ZNFT1000-NCUST,   "고객명
        SALER       LIKE ZNFT1000-SALER,   "영업담당자
        CFUTN       LIKE ZNFT1030-CFUTN,   "청산선물집행번호
        ZPJNO       LIKE ZNFT1000-ZPJNO,
      END   OF GT_MAIN.

DATA: GV_WAERS      LIKE T001-WAERS,    "Currency
      GV_LAND1      LIKE T001-LAND1,    "Country
      GV_BUTXT      LIKE T001-BUTXT,    "Company Name
      GV_KTOPL      LIKE T001-KTOPL,    "Chart of Account
      GV_KOKRS      LIKE TKA02-KOKRS.   "Controlling Area

DATA: GV_TRTYP      LIKE T180-TRTYP,
      GV_TITLE(50),
      GV_ERROR.

RANGES: GR_DRSTA    FOR   ZNFT1040-DRSTA.

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
TYPE-POOLS : SLIS.

DATA: GV_USER_COMMAND     TYPE SLIS_FORMNAME VALUE 'USER_COMMAND',
      GV_STATUS_SET       TYPE SLIS_FORMNAME VALUE 'PF_STATUS_SET',
      GV_TOP_OF_PAGE      TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE',
      GV_REPID            LIKE SY-REPID,
      GT_EVENTS           TYPE SLIS_T_EVENT,
      GS_EVENTS_LINE      TYPE SLIS_ALV_EVENT,
      GT_EVENTS_EXIT      TYPE SLIS_T_EVENT_EXIT,
      GS_EVENTS_EXIT_LINE TYPE SLIS_EVENT_EXIT,
      GS_LAYOUT           TYPE SLIS_LAYOUT_ALV,
      GT_FIELDCAT         TYPE SLIS_T_FIELDCAT_ALV,
      GS_FIELDCAT         TYPE SLIS_FIELDCAT_ALV,
      GT_LIST_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER,
      GS_LIST_TOP_OF_PAGE TYPE SLIS_LISTHEADER,
      GV_GRID_SETTINGS    TYPE LVC_S_GLAY,
      GT_SORT             TYPE SLIS_T_SORTINFO_ALV,
      GS_SORT             TYPE SLIS_SORTINFO_ALV,
      GS_VARIANT          TYPE DISVARIANT.

DATA: GV_EXTAB            TYPE SLIS_EXTAB,
      GV_ITAB             LIKE GS_FIELDCAT-TABNAME,
      GV_POS              LIKE GS_FIELDCAT-COL_POS.

*___Macro
DEFINE APPEND_RANGES.
  CLEAR : &1.

  &1-SIGN   = &2.
  &1-OPTION = &3.
  &1-LOW    = &4.
  &1-HIGH   = &5.

  APPEND &1.
END-OF-DEFINITION.
