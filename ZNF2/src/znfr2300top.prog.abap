*&---------------------------------------------------------------------*
*&  Include           ZNFR2300TOP
*&---------------------------------------------------------------------*

TABLES: ZNFT0004,
        ZNFT1000,
        ZNFT1010,
        ZNFT1011,
        ZNFT1020,
        ZNFT1030.

DATA: BEGIN OF GT_1020 OCCURS 0.
        INCLUDE STRUCTURE ZNFT1020.
DATA:   CHECK,
        CFUTN       LIKE ZNFT1030-CFUTN, "청산집행번호 /26.09.15 박우진 추가.
        NAME1       LIKE LFA1-NAME1,     "FCM 명
        BSTXT(10),                       "Buy/Sell
        MITPT(20),                       "집행유형명
        YNFIN1      LIKE ZNFT1011-YNFIN, "마감여부
        ENDMM       LIKE ZNFT1011-ENDMM, "만기월
        EMENG1      LIKE ZNFT1011-EMENG, "요청수량
        MEINS1      LIKE ZNFT1011-MEINS, "단위
        RQTYP       LIKE ZNFT1010-RQTYP, "요청유형
        RQTXT(20),                       "요청유형명
        CONNO       LIKE ZNFT1011-CONNO, "계약번호
        COTXT       LIKE ZNFT1000-COTXT, "계약명
        PRCTR       LIKE ZNFT1000-PRCTR, "손익센터
        PTEXT       LIKE ZNFT0004-PTEXT, "손익센터명
        VKGRP       LIKE ZNFT1000-VKGRP, "영업그룹
        VKTXT       LIKE ZNFT0003-VTEXT, "영업그룹명
        KUNNR       LIKE ZNFT1000-KUNNR, "고객코드
        NCUST       LIKE ZNFT1000-NCUST, "고객명
        ZPJNO       LIKE ZNFT1000-ZPJNO, "Project NO
        PRIND(20),                       "가격구분
        SUJUP(20),                       "비철수주가
        SETTL(20),                       "청산입력여부
      END   OF GT_1020.

DATA: GV_WAERS      LIKE T001-WAERS,     "Currency
      GV_LAND1      LIKE T001-LAND1,     "Country
      GV_BUTXT      LIKE T001-BUTXT,     "Company Name
      GV_KTOPL      LIKE T001-KTOPL,     "Chart of Account
      GV_KOKRS      LIKE TKA02-KOKRS.    "Controlling Area

DATA: GV_ANSWER,
      GV_ERROR.

RANGES: GR_BY_SL    FOR  ZNFT1020-BY_SL.

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
