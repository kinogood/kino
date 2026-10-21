*&---------------------------------------------------------------------*
*&  Include           ZNFR2020TOP
*&---------------------------------------------------------------------*

TABLES: ZNFT1000,
        ZNFT1001,
        VBAK.

DATA: BEGIN OF GT_MAIN OCCURS 0,
        CONNO       LIKE ZNFT1000-CONNO,    "계약번호
        COTXT       LIKE ZNFT1000-COTXT,    "계약명
        CSTAT       LIKE ZNFT1000-CSTAT,    "계약상태
        CSTXT(20),                          "계약상태내역
        BUKRS       LIKE ZNFT1000-BUKRS,    "회사코드
        KUNNR       LIKE ZNFT1000-KUNNR,    "고객코드
        NCUST       LIKE ZNFT1000-NCUST,    "고객명
        NFCTR       LIKE ZNFT1000-NFCTR,    "사업부
        NTEXT       LIKE ZNFT0005-NTEXT,    "사업부명
        PRCTR       LIKE ZNFT1000-PRCTR,    "손익센터
        PTEXT       LIKE ZNFT0004-PTEXT,    "손익센터명
        VKGRP       LIKE ZNFT1000-VKGRP,    "영업그룹
        VTEXT       LIKE ZNFT0003-VTEXT,    "영업그룹명
        SALER       LIKE ZNFT1000-SALER,    "영업담당자
        ERDAT       LIKE ZNFT1000-ERDAT,    "생성일
        ERNAM       LIKE ZNFT1000-ERNAM,    "생성인
        NFKEY       LIKE ZNFT1001-NFKEY,    "비철구분
        WAERS       LIKE ZNFT1001-WAERS,    "통화
        EMENG       LIKE ZNFT1001-EMENG,    "계약수주량
        MEINS       LIKE ZNFT1001-MEINS,    "단위
        PRIND(20),                          "가격구분
        SUJUP(20),                          "비철수주가
        VBELN       LIKE VBAP-VBELN,        "판매오더
        POSNR       LIKE VBAP-POSNR,        "판매오더품목
        SPART       LIKE VBAP-SPART,        "제품군
        MATNR       LIKE VBAP-MATNR,        "자재코드
        MAKTX       LIKE MAKT-MAKTX,        "자재명
        KUNAG       LIKE VBAK-KUNNR,        "판매처
        NAMAG       LIKE KNA1-NAME1,        "판매처명
        KUNWE       LIKE VBPA-KUNNR,        "납품처
        NAMWE       LIKE KNA1-NAME1,        "납품처명
        EDATU       LIKE VBEP-EDATU,        "최초납품일자
        VRKME       LIKE VBAP-VRKME,        "오더단위
        KWMENG      LIKE VBAP-KWMENG,       "오더수량
        WAERK       LIKE VBAK-WAERK,        "오더통화
        NETWR       LIKE VBAK-NETWR,        "오더금액
        MAVGW       LIKE /NFM/TVGW-VGW,     "자재비철량
        VGW         LIKE /NFM/TVGW-VGW,     "비철량
        VGE         LIKE /NFM/TVGW-VGW,     "기준수량
        BME         LIKE /NFM/TNES-BME,     "비철단위
        BMEIN       LIKE MARA-MEINS,        "기준단위
        CHECK,
      END   OF GT_MAIN.

DATA: BEGIN OF GT_1001 OCCURS 0,
        CONNO       LIKE ZNFT1000-CONNO,    "계약번호
        COTXT       LIKE ZNFT1000-COTXT,    "계약명
        CSTAT       LIKE ZNFT1000-CSTAT,    "계약상태
        BUKRS       LIKE ZNFT1000-BUKRS,    "회사코드
        KUNNR       LIKE ZNFT1000-KUNNR,    "고객코드
        NCUST       LIKE ZNFT1000-NCUST,    "고객명
        NFCTR       LIKE ZNFT1000-NFCTR,    "사업부
        PRCTR       LIKE ZNFT1000-PRCTR,    "손익센터
        VKGRP       LIKE ZNFT1000-VKGRP,    "영업그룹
        SALER       LIKE ZNFT1000-SALER,    "영업담당자
        ERDAT       LIKE ZNFT1000-ERDAT,    "생성일
        ERNAM       LIKE ZNFT1000-ERNAM,    "생성인
        NFKEY       LIKE ZNFT1001-NFKEY,    "비철구분
        WAERS       LIKE ZNFT1001-WAERS,    "통화
        EMENG       LIKE ZNFT1001-EMENG,    "계약수주량
        MEINS       LIKE ZNFT1001-MEINS,    "단위
      END   OF GT_1001.

DATA: BEGIN OF GT_VBAP OCCURS 0,
        VBELN       LIKE VBAP-VBELN,
        POSNR       LIKE VBAP-POSNR,
        VKORG       LIKE VBAK-VKORG,
        KUNNR       LIKE VBAK-KUNNR,
        MATNR       LIKE VBAP-MATNR,
        ARKTX       LIKE VBAP-ARKTX,
        WERKS       LIKE VBAP-WERKS,
        VTWEG       LIKE VBAK-VTWEG,
        SPART       LIKE VBAP-SPART,
        NETWR       LIKE VBAP-NETWR,
        WAERK       LIKE VBAK-WAERK,
        KWMENG      LIKE VBAP-KWMENG,
        VRKME       LIKE VBAP-VRKME,
        CONNO       LIKE VBAP-CONNO,
      END   OF GT_VBAP.

DATA: BEGIN OF GT_TVGW OCCURS 0.
        INCLUDE STRUCTURE /NFM/TVGW.
DATA:   BME         LIKE /NFM/TNES-BME,
      END   OF GT_TVGW.

DATA: GV_WAERS      LIKE T001-WAERS,    "Currency
      GV_LAND1      LIKE T001-LAND1,    "Country
      GV_BUTXT      LIKE T001-BUTXT,    "Company Name
      GV_KTOPL      LIKE T001-KTOPL,    "Chart of Account
      GV_KOKRS      LIKE TKA02-KOKRS.   "Controlling Area

DATA: GV_TITLE(50),
      GV_ERROR,
      GV_ANSWER.

RANGES: GR_CONNO    FOR  ZNFT1053-CONNO.

*___F4 Help용 변수
DATA: SELECTFIELD   LIKE  HELP_INFO-FIELDNAME,
      IT_FIELDS     LIKE  HELP_VALUE OCCURS 1 WITH HEADER LINE,
      SELECT_VALUE  LIKE  HELP_INFO-FLDVALUE,
      LD_TABIX      LIKE  SY-TABIX,
      LV_INDEX      LIKE  SY-INDEX.

DATA: SCR_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE,
      FELD_TABLE LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

*___사업부
DATA: BEGIN OF GT_NFCTR OCCURS 0,
        NFCTR       LIKE ZNFT0005-NFCTR,
        NTEXT       LIKE ZNFT0005-NTEXT,
      END OF GT_NFCTR.

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
