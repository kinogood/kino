*&---------------------------------------------------------------------*
*&  Include           ZNFR2120TOP
*&---------------------------------------------------------------------*

INCLUDE ZNFR2120CLS.

TABLES: ZNFT1000,
        ZNFT1001,
        ZNFT1010,
        ZNFT1011.

DATA: BEGIN OF GT_MAIN OCCURS 0,
        CHECK,
        BUKRS       LIKE ZNFT1010-BUKRS,    "회사코드
        REQNO       LIKE ZNFT1010-REQNO,    "요청번호
        H_NO1       LIKE ZNFT1011-H_NO1,    "항번
        NFCTR       LIKE ZNFT1000-NFCTR,    "사업부
        NTEXT       LIKE ZNFT0005-NTEXT,    "사업부명
        PRCTR       LIKE ZNFT1000-PRCTR,    "손익센터
        PTEXT       LIKE ZNFT0004-PTEXT,    "손익센터명
        VKGRP       LIKE ZNFT1000-VKGRP,    "영업그룹
        VTEXT       LIKE ZNFT0003-VTEXT,    "영업그룹명
        NFKEY       LIKE ZNFT1011-NFKEY,    "NF Key
        BY_SL       LIKE ZNFT1011-BY_SL,    "BUY/SELL
        BSTXT(10),                          "Buy/Sell Text
        ENDMM       LIKE ZNFT1011-ENDMM,    "만기월
        EMENG       LIKE ZNFT1011-EMENG,    "요청수량
        MEINS       LIKE ZNFT1011-MEINS,    "단위
        RQTYP       LIKE ZNFT1010-RQTYP,    "요청유형
        RQTXT(20),                          "요청유형 텍스트
        CONNO       LIKE ZNFT1011-CONNO,    "계약번호
        COTXT       LIKE ZNFT1000-COTXT,    "계약명
        COTYP       LIKE ZNFT1000-COTYP,    "계약유형
        CTPTX(20),                          "계약유형 텍스트
        KUNNR       LIKE ZNFT1000-KUNNR,    "고객코드
        NCUST       LIKE ZNFT1000-NCUST,    "고객명
        SALER       LIKE ZNFT1000-SALER,    "영업담당자
        PRIND(20),                          "가격구분
        SUJUP(20),                          "비철수주가
        EMENG1      LIKE ZNFT1001-EMENG,    "수주량
        ERNAM       LIKE ZNFT1011-ERNAM,    "요청자
        ERDAT       LIKE ZNFT1011-ERDAT,    "생성일
        RSTAT       LIKE ZNFT1010-RSTAT,    "결재상태
        RSTXT(20),                          "결재상태내역
        CARRY,                              "선물집행여부
        STTLE,                              "선물청산여부
        BIGO4       LIKE ZNFT1011-BIGO4,    "비고
        YNFIN       LIKE ZNFT1011-YNFIN,    "마감여부
        WHYDE       LIKE ZNFT1011-WHYDE,    "변경사유
        CONNO_O     LIKE ZNFT1011-CONNO,    "계약번호
        YNFIN_O     LIKE ZNFT1011-YNFIN,    "마감여부
        WHYDE_O     LIKE ZNFT1011-WHYDE,    "변경사유

        F_COL       TYPE LVC_T_SCOL,
        CELLTAB     TYPE LVC_T_STYL,
      END   OF GT_MAIN.

DATA: GV_WAERS      LIKE T001-WAERS,    "Currency
      GV_LAND1      LIKE T001-LAND1,    "Country
      GV_BUTXT      LIKE T001-BUTXT,    "Company Name
      GV_KTOPL      LIKE T001-KTOPL,    "Chart of Account
      GV_KOKRS      LIKE TKA02-KOKRS.   "Controlling Area

DATA: GV_CHANGE,
      GV_ANSWER,
      GV_ERROR.

RANGES: GR_RQTYP    FOR  ZNFT1010-RQTYP,
        GR_YNFIN    FOR  ZNFT1011-YNFIN.

DATA: OK_CODE       LIKE SY-UCOMM,
      OK_SAVE       LIKE SY-UCOMM.

*___Change Doc 관리용
DATA: YZNFT1010     LIKE ZNFT1010,
      XGT_1011      LIKE YZNFT1011 OCCURS 0 WITH HEADER LINE,
      YGT_1011      LIKE YZNFT1011 OCCURS 0 WITH HEADER LINE.

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

*___계약번호
DATA: BEGIN OF GT_CONNO OCCURS 0,
        COTYP       LIKE ZNFT1000-COTYP,  "계약유형
        NFCTR       LIKE ZNFT1000-NFCTR,  "사업부
        PRCTR       LIKE ZNFT1000-PRCTR,  "손익센터
        VKGRP       LIKE ZNFT1000-VKGRP,  "영업그룹
        CONNO       LIKE ZNFT1000-CONNO,  "계약번호
        ERDAT       LIKE ZNFT1000-ERDAT,  "생성일
        COTXT       LIKE ZNFT1000-COTXT,  "계약명(PJT명)
        KUNNR       LIKE ZNFT1000-KUNNR,  "고객코드
        NCUST       LIKE ZNFT1000-NCUST,  "고객명
        SUJUD       LIKE ZNFT1000-SUJUD,  "수주일
        SALER       LIKE ZNFT1000-SALER,  "영업담당자
        NFKEY       LIKE ZNFT1001-NFKEY,  "비철구분
        PRIND(20),                        "가격구분
        SUJUP(20),                        "비철수주가격
        SUJUQ(20),                        "수주량
        EMENG       LIKE ZNFT1001-EMENG,  "수주량
        MEINS       LIKE ZNFT1001-MEINS,  "단위
      END   OF GT_CONNO.

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
