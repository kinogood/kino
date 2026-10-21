*&---------------------------------------------------------------------*
*&  Include           ZNFR2600TOP
*&---------------------------------------------------------------------*

INCLUDE ZNFR2600CLS.

TABLES: ZNFT1000,
        ZNFT1011,
        ZNFT1020,
        ZNFT1030.

DATA: BEGIN OF GT_MAIN OCCURS 0.
        INCLUDE STRUCTURE ZNFT1020.
DATA:   CHECK,
        NCIND(10),                              "신규/청산구분
        WHYTX(20),                              "취소사유 내역
        CFMTX(20),                              "결재상태 내역
        BSTXT(20),                              "Buy/Sell 내역
        MITPT(20),                              "집행유형 내역
        GJAHR       LIKE ZNFT1051-GJAHR,        "회계연도
        BELNR       LIKE ZNFT1051-BELNR,        "손익전표
        NAME1       LIKE LFA1-NAME1,            "FCM 명
        CFUTN       LIKE ZNFT1020-NFUTN,        "연결선물집행번호

* [S] 만기이동유형 추가 / 박우진 2026.09.17
        MCTYP_NM  TYPE  CHAR10,
* [E] 만기이동유형 추가 / 박우진 2026.09.17


        ENDMM       LIKE ZNFT1011-ENDMM,        "만기월
        REQTY       LIKE ZNFT1011-EMENG,        "요청수량
        REQME       LIKE ZNFT1011-MEINS,        "단위
        RQTYP       LIKE ZNFT1010-RQTYP,        "요청유형
        RQTXT(20),                              "요청유형명
        CONNO       LIKE ZNFT1011-CONNO,        "계약번호
        COTXT       LIKE ZNFT1000-COTXT,        "계약명
        NFCTR       LIKE ZNFT1000-NFCTR,        "사업부
        NTEXT       LIKE ZNFT0005-NTEXT,        "사업부명
        PRCTR       LIKE ZNFT1000-PRCTR,        "손익센터
        PTEXT       LIKE ZNFT0004-PTEXT,        "손익센터명
        VKGRP       LIKE ZNFT1000-VKGRP,        "영업그룹
        VTEXT       LIKE ZNFT0003-VTEXT,        "영업그룹명
        KUNNR       LIKE ZNFT1000-KUNNR,        "고객번호
        NCUST       LIKE ZNFT1000-NCUST,        "고객명
        TOTAL       LIKE ZNFT1020-PRICE,        "집행금액
        PRIND(20),                              "가격구분
        SUJUP(20),                              "비철수주가
        NODE_KEY    TYPE LVC_NKEY,
      END   OF GT_MAIN.

DATA: GT_1020       LIKE ZNFT1020 OCCURS 0 WITH HEADER LINE,
      GT_1030       LIKE ZNFT1030 OCCURS 0 WITH HEADER LINE,
      GT_HIST       LIKE GT_MAIN  OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF GT_NFUTN OCCURS 0,
        NFUTN       LIKE ZNFT1020-NFUTN,
      END   OF GT_NFUTN.

DATA : GV_TYPE(1).

DATA: BEGIN OF GT_CFUTN OCCURS 0,
        CFUTN       LIKE ZNFT1030-CFUTN,
      END   OF GT_CFUTN.

DATA: GV_WAERS      LIKE T001-WAERS,    "Currency
      GV_LAND1      LIKE T001-LAND1,    "Country
      GV_BUTXT      LIKE T001-BUTXT,    "Company Name
      GV_KTOPL      LIKE T001-KTOPL,    "Chart of Account
      GV_KOKRS      LIKE TKA02-KOKRS.   "Controlling Area

DATA: GV_ERROR.

RANGES: GR_BY_SL    FOR  ZNFT1020-BY_SL,
        GR_YNCAN    FOR  ZNFT1020-YNCAN,
        GR_YNFIN    FOR  ZNFT1020-YNFIN,
        GR_YNNET    FOR  ZNFT1030-YNNET.

DATA: BEGIN OF GT_EXCL OCCURS 0,
        FCODE       LIKE SY-UCOMM,
      END   OF GT_EXCL.

DATA: OK_CODE       LIKE SY-UCOMM,
      OK_SAVE       LIKE SY-UCOMM.

*___F4 Help용 변수
DATA: SELECTFIELD   LIKE  HELP_INFO-FIELDNAME,
      IT_FIELDS     LIKE  HELP_VALUE OCCURS 1 WITH HEADER LINE,
      SELECT_VALUE  LIKE  HELP_INFO-FLDVALUE,
      LD_TABIX      LIKE  SY-TABIX,
      LV_INDEX      LIKE  SY-INDEX.

DATA: SCR_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE,
      FELD_TABLE LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

*___FCM
DATA: BEGIN OF GT_FCM OCCURS 0,
        LIFNR       LIKE ZNFT0021-LIFNR,
        NAME1       LIKE LFA1-NAME1,
      END   OF GT_FCM.

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
DATA: GC_CONTAINER_NAME1    TYPE SCRFNAME VALUE 'CONTAINER1',
      GC_CUSTOM_CONTAINER1  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GC_ALV_GRID           TYPE REF TO CL_GUI_ALV_GRID,
      GC_EVENT_HANDLER      TYPE REF TO LCL_EVENT_HANDLER,
      GC_CONTAINER_NAME2    TYPE SCRFNAME VALUE 'CONTAINER2',
      GC_CUSTOM_CONTAINER2  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,

      "[S]박우진 추가 (TREE ALV용)
      GO_EVENT_RECEIVER TYPE REF TO LCL_TREE_EVENT_HANDLER,
      GO_TOOLBAR TYPE REF TO CL_GUI_TOOLBAR,
      "[E]박우진 추가


      GC_ALV_TREE           TYPE REF TO CL_GUI_ALV_TREE,
      GS_HIERARCHY_HEADER   TYPE TREEV_HHDR,
      GT_LIST_COMMENTARY    TYPE SLIS_T_LISTHEADER,
      GC_TOOLBAR            TYPE REF TO CL_GUI_TOOLBAR,
      GC_TREE_EVENT_HANDLER TYPE REF TO LCL_TREE_EVENT_HANDLER,
      GT_NODE_KEY           TYPE LVC_T_NKEY WITH HEADER LINE,
      GT_NODE_EXP           TYPE LVC_T_NKEY WITH HEADER LINE,
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

*___ALV용 변수
DATA: GT_EXCLUDE            TYPE UI_FUNCTIONS,
      GS_VARIANT            TYPE DISVARIANT,
      GV_ITAB               LIKE GS_FIELDCAT-TABNAME,
      GV_POS                LIKE GS_FIELDCAT-COL_POS.
