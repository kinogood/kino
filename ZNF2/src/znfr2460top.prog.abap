*&---------------------------------------------------------------------*
*&  Include           ZNFR2460TOP
*&---------------------------------------------------------------------*

CONSTANTS: GC_TCODE1  LIKE SY-TCODE VALUE 'ZNF2R2460',
           GC_TCODE2  LIKE SY-TCODE VALUE 'ZNF2R2461'.

TABLES: ZNFT1000,
        ZNFT1011.

DATA: BEGIN OF GT_MAIN OCCURS 0.
        INCLUDE STRUCTURE ZNFT1053.
DATA:   EMENG       LIKE ZNFT1051-EMENG,          "집행수량
        EMEIN       LIKE ZNFT1051-MEINS,          "단위
        COTXT       LIKE ZNFT1000-COTXT,          "계약명
        NFCTR       LIKE ZNFT1000-NFCTR,          "사업부
        NTEXT       LIKE ZNFT0005-NTEXT,          "사업부명
        PRCTR       LIKE ZNFT1000-PRCTR,          "손익센터
        PTEXT       LIKE ZNFT0004-PTEXT,          "손익센터명
        VKGRP       LIKE ZNFT1000-VKGRP,          "영업그룹
        VTEXT       LIKE ZNFT0003-VTEXT,          "영업그룹명
        SPART       LIKE VBAK-SPART,              "제품군
        MAKTX       LIKE MAKT-MAKTX,              "자재명
        KUNNR       LIKE VBAK-KUNNR,              "판매처
        NAMAG       LIKE KNA1-NAME1,              "판매처명
        KUNWE       LIKE VBPA-KUNNR,              "납품처
        NAMWE       LIKE KNA1-NAME1,              "납품처명
        KWMENG      LIKE VBAP-KWMENG,             "오더수량
        ORVGW       LIKE ZNFT1053-BLVGW,          "오더비철수량
        FKPRE       LIKE VBRP-FKIMG,              "이전월 대금청구수량
        UPLSM       LIKE ZNFT1053-UPRLO,          "선물손익합계(USD)
        KPLSM       LIKE ZNFT1053-KPRLO,          "선물손익합계(KRW)
        CHECK,
      END   OF GT_MAIN.

DATA: GT_1051       LIKE ZNFT1051 OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF GT_PRLO OCCURS 0,
        CONNO       LIKE ZNFT1051-CONNO,
        NFKEY       LIKE ZNFT1051-NFKEY,
        EMENG       LIKE ZNFT1051-EMENG,
        MEINS       LIKE ZNFT1051-MEINS,
        UPRLO       LIKE ZNFT1051-UPRLO,
        UAERS       LIKE ZNFT1051-UAERS,
        KPRLO       LIKE ZNFT1051-KPRLO,
        KAERS       LIKE ZNFT1051-KAERS,
      END   OF GT_PRLO.

DATA: BEGIN OF GT_VBAP OCCURS 0,
        VBELN       LIKE VBAP-VBELN,
        POSNR       LIKE VBAP-POSNR,
        VKORG       LIKE VBAK-VKORG,
        KUNNR       LIKE VBAK-KUNNR,
        MATNR       LIKE VBAP-MATNR,
        WERKS       LIKE VBAP-WERKS,
        VTWEG       LIKE VBAK-VTWEG,
        SPART       LIKE VBAP-SPART,
        KWMENG      LIKE VBAP-KWMENG,
        VRKME       LIKE VBAP-VRKME,
        CONNO       LIKE VBAP-CONNO,
        FKIMG       LIKE VBRP-FKIMG,    "정산월 대금청구수량
        FKPRE       LIKE VBRP-FKIMG,    "이전월 대금청구수량
      END   OF GT_VBAP.

DATA: BEGIN OF GT_TVGW OCCURS 0.
        INCLUDE STRUCTURE /NFM/TVGW.
DATA:   BME         LIKE /NFM/TNES-BME,
      END   OF GT_TVGW.

DATA: BEGIN OF GT_SOSUM OCCURS 0,
        CONNO       LIKE ZNFT1053-CONNO,
        NFKEY       LIKE ZNFT1053-NFKEY,
        ORVGW       LIKE ZNFT1053-BLVGW,    "오더비철수량
        BLVGW       LIKE ZNFT1053-BLVGW,    "정산월 대금청구비철수량
        BLREM       LIKE ZNFT1053-BLVGW,    "대금청구되지 않은 비철수량
      END   OF GT_SOSUM.

DATA: GV_FRDAT      LIKE SY-DATUM,
      GV_TODAT      LIKE SY-DATUM.

DATA: GV_WAERS      LIKE T001-WAERS,    "Currency
      GV_LAND1      LIKE T001-LAND1,    "Country
      GV_BUTXT      LIKE T001-BUTXT,    "Company Name
      GV_KTOPL      LIKE T001-KTOPL,    "Chart of Account
      GV_KOKRS      LIKE TKA02-KOKRS.   "Controlling Area

DATA: GV_TITLE(50),
      GV_ERROR,
      GV_ANSWER.

RANGES: GR_CONNO    FOR  ZNFT1053-CONNO.

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
