*&---------------------------------------------------------------------*
*&  Include           ZNFR2110TOP
*&---------------------------------------------------------------------*
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
************************************************************************
* 2012/08/23   MMB04(HDY)     변경근거 : C20120821_68215               *
*----------------------------------------------------------------------*
* Comment : 수주금액의 통화값 변경
************************************************************************

CONSTANTS: GC_TCODE1 LIKE SY-TCODE VALUE 'ZNF2R2110',
           GC_TCODE2 LIKE SY-TCODE VALUE 'ZNF2R2111'.

TABLES: ZNFT1000,
        ZNFT1010,
        ZNFT1011,
        ZZPA0001,
        ZPA0105.

DATA: BEGIN OF GT_MAIN OCCURS 0,
        CHECK,
        BUKRS     LIKE ZNFT1010-BUKRS,    "회사코드
        REQNO     LIKE ZNFT1010-REQNO,    "요청번호
        H_NO1     LIKE ZNFT1011-H_NO1,    "항번
        YNFIN     LIKE ZNFT1011-YNFIN,    "마감여부
        NFKEY     LIKE ZNFT1011-NFKEY,    "NF Key
        BY_SL     LIKE ZNFT1011-BY_SL,    "Buy/Sell
        BSTXT(10),                          "Buy/Sell Text
        ENDMM     LIKE ZNFT1011-ENDMM,    "만기월
        EMENG     LIKE ZNFT1011-EMENG,    "요청수량
        MEINS     LIKE ZNFT1011-MEINS,    "단위
        RQTYP     LIKE ZNFT1010-RQTYP,    "요청유형
        RQTXT(20),                          "요청유형 텍스트
        CONNO     LIKE ZNFT1011-CONNO,    "계약번호
        COTXT     LIKE ZNFT1000-COTXT,    "계약명
        COTYP     LIKE ZNFT1000-COTYP,    "계약유형
        CTPTX(20),                          "계약유형 텍스트
        KUNNR     LIKE ZNFT1000-KUNNR,    "고객코드
        NCUST     LIKE ZNFT1000-NCUST,    "고객명
        SALER     LIKE ZNFT1000-SALER,    "영업담당자
        PRIND(20),                          "가격구분
        SUJUP(20),                          "비철수주가
        ERNAM     LIKE ZNFT1010-ERNAM,    "요청자
        ERDAT     LIKE ZNFT1010-ERDAT,    "생성일
        RSTAT     LIKE ZNFT1010-RSTAT,    "결재상태
        RSTXT(20),                          "결재상태내역
        PERNR     LIKE ZNFT1091-PERNR,    "승인자사번
*        ENAME       LIKE PA0001-ENAME,      "승인자명
        ENAME     LIKE ZZPA0001-ENAME,    "승인자명 - PA0001 대체
        NFCTR     LIKE ZNFT1000-NFCTR,    "사업부
        NTEXT     LIKE ZNFT0005-NTEXT,    "사업부명
        ZPJNO     LIKE ZNFT1000-ZPJNO,    "프로젝트번호
        PRCTR     LIKE ZNFT1000-PRCTR,    "손익센터
        PTEXT     LIKE ZNFT0004-PTEXT,    "손익센터명
        VKGRP     LIKE ZNFT1000-VKGRP,    "영업그룹
        VTEXT     LIKE ZNFT0003-VTEXT,    "영업그룹명
        WHYDE     LIKE ZNFT1011-WHYDE,    "변경사유(마감사유)
        NFUTN     LIKE ZNFT1020-NFUTN,    "신규집행번호
        RUDAT     LIKE ZNFT1020-RUDAT,    "집행일
        FCM       LIKE ZNFT1020-FCM,      "FCM(거래선)
        SUJUD     LIKE ZNFT1000-SUJUD,    "수주일
        PRICE1    LIKE ZNFT1000-PRICE,    "수주금액
**** HDY 20120823 START [20120821_68215]
**** 수주금액 통화 확인 변수 선언
        WAERS1    LIKE ZNFT1000-WAERS,    "수주금액 통화
**** HDY 20120823 END
        EMENG1    LIKE ZNFT1001-EMENG,    "수주량
        PRATE     LIKE ZNFT1000-PRATE,    "영업이익률
        ENDAT     LIKE ZNFT1020-ENDAT,    "만기일
        MITYP     LIKE ZNFT1020-MITYP,    "집행유형
        MITPT(20),                          "집행유형 내역
        WAERS     LIKE ZNFT1020-WAERS,    "통화
        MISPD     LIKE ZNFT1020-MISPD,    "Spread
        MIMON     LIKE ZNFT1020-MIMON,    "기준월
        PRICE     LIKE ZNFT1020-PRICE,    "집행단가
        EMENG2    LIKE ZNFT1020-EMENG,    "집행수량
        CSTAT(10),                          "청산상태
        BIGO4     LIKE ZNFT1011-BIGO4,    "비고
      END   OF GT_MAIN.

DATA: BEGIN OF GT_1011 OCCURS 0,
        BUKRS LIKE ZNFT1010-BUKRS,    "회사코드
        REQNO LIKE ZNFT1010-REQNO,    "요청번호
        H_NO1 LIKE ZNFT1011-H_NO1,    "항번
        YNFIN LIKE ZNFT1011-YNFIN,    "마감여부
        NFKEY LIKE ZNFT1011-NFKEY,    "NF Key
        BY_SL LIKE ZNFT1011-BY_SL,    "BUY_SELL
        ENDMM LIKE ZNFT1011-ENDMM,    "만기월
        EMENG LIKE ZNFT1011-EMENG,    "요청수량
        MEINS LIKE ZNFT1011-MEINS,    "단위
        RQTYP LIKE ZNFT1010-RQTYP,    "요청유형
        CONNO LIKE ZNFT1011-CONNO,    "계약번호
        ERNAM LIKE ZNFT1010-ERNAM,    "요청자
        ERDAT LIKE ZNFT1010-ERDAT,    "생성일
        RSTAT LIKE ZNFT1010-RSTAT,    "결재상태
        WHYDE LIKE ZNFT1011-WHYDE,    "변경사유(마감사유)
        BIGO4 LIKE ZNFT1011-BIGO4,    "비고
        WAERS LIKE ZNFT1020-WAERS,    "통화
      END   OF GT_1011.

DATA: GV_WAERS LIKE T001-WAERS,    "Currency
      GV_LAND1 LIKE T001-LAND1,    "Country
      GV_BUTXT LIKE T001-BUTXT,    "Company Name
      GV_KTOPL LIKE T001-KTOPL,    "Chart of Account
      GV_KOKRS LIKE TKA02-KOKRS.   "Controlling Area

DATA: GV_TRTYP     LIKE T180-TRTYP,
      GV_TITLE(50),
      GV_ERROR.

RANGES: GR_RSTAT    FOR  ZNFT1010-RSTAT,
        GR_RQTYP    FOR  ZNFT1010-RQTYP,
        GR_YNFIN    FOR  ZNFT1011-YNFIN.

*___F4 Help용 변수
DATA: SELECTFIELD  LIKE  HELP_INFO-FIELDNAME,
      IT_FIELDS    LIKE  HELP_VALUE OCCURS 1 WITH HEADER LINE,
      SELECT_VALUE LIKE  HELP_INFO-FLDVALUE,
      LD_TABIX     LIKE  SY-TABIX,
      LV_INDEX     LIKE  SY-INDEX.

DATA: SCR_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE,
      FELD_TABLE LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

*___사업부
DATA: BEGIN OF GT_NFCTR OCCURS 0,
        NFCTR LIKE ZNFT0005-NFCTR,
        NTEXT LIKE ZNFT0005-NTEXT,
      END OF GT_NFCTR.

*___손익센터
DATA: BEGIN OF GT_PRCTR OCCURS 0,
        PRCTR LIKE ZNFT0003-PRCTR,
        PTEXT LIKE ZNFT0003-PTEXT,
      END OF GT_PRCTR.

*___영업그룹
DATA: BEGIN OF GT_VKGRP OCCURS 0,
        VKGRP LIKE ZNFT0003-VKGRP,
        VTEXT LIKE ZNFT0003-VTEXT,
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

DATA: GV_EXTAB TYPE SLIS_EXTAB,
      GV_ITAB  LIKE GS_FIELDCAT-TABNAME,
      GV_POS   LIKE GS_FIELDCAT-COL_POS.
