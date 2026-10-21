*&---------------------------------------------------------------------*
*&  Include           ZNFR2210TOP
*&---------------------------------------------------------------------*

INCLUDE ZNFR2210CLS.

CONTROLS: TC1       TYPE TABLEVIEW USING SCREEN 300.

TABLES: ZNFT1000,   ZNFT1002,
        ZNFT1010,
        ZNFT1011,
        ZNFT1020,
        ZNFT1021.

DATA: BEGIN OF GT_1011 OCCURS 0,
        CHECK,
        BUKRS       LIKE ZNFT1010-BUKRS,        "회사코드
        REQNO       LIKE ZNFT1010-REQNO,        "요청번호
        H_NO1       LIKE ZNFT1011-H_NO1,        "항번
        ERDAT       LIKE ZNFT1010-ERDAT,        "요청일
        NFCTR       LIKE ZNFT1000-NFCTR,        "사업부
        NTEXT       LIKE ZNFT0005-NTEXT,        "사업부명
        PRCTR       LIKE ZNFT1000-PRCTR,        "손익센터
        PTEXT       LIKE ZNFT0004-PTEXT,        "손익센터명
        VKGRP       LIKE ZNFT1000-VKGRP,        "영업그룹
        VTEXT       LIKE ZNFT0003-VTEXT,        "영업그룹명
        NFKEY       LIKE ZNFT1011-NFKEY,        "NF Key
        BY_SL       LIKE ZNFT1011-BY_SL,        "Buy/Sell
        BSTXT(10),                              "Buy/Sell Text
        ENDMM       LIKE ZNFT1011-ENDMM,        "만기월
        EMENG       LIKE ZNFT1011-EMENG,        "요청수량
        TMENG       LIKE ZNFT1020-EMENG,        "집행수량
        MEINS       LIKE ZNFT1011-MEINS,        "단위
        RQTYP       LIKE ZNFT1010-RQTYP,        "요청유형
        RQTXT(20),                              "요청유형 텍스트
        CONNO       LIKE ZNFT1011-CONNO,        "계약번호
        COTXT       LIKE ZNFT1000-COTXT,        "계약명
        KUNNR       LIKE ZNFT1000-KUNNR,        "고객번호
        NCUST       LIKE ZNFT1000-NCUST,        "고객명
        SUJUD       LIKE ZNFT1000-SUJUD ,
        PRICE       LIKE ZNFT1000-PRICE ,
        WAERS       LIKE ZNFT1000-WAERS ,
        PRATE       LIKE ZNFT1000-PRATE ,
        SALER       LIKE ZNFT1000-SALER ,
        ERATE       LIKE ZNFT1000-ERATE ,
        FILE_YN     TYPE CHAR01         ,       " 첨부파일 여부
        PRIND(20),                              "가격구분
        SUJUP(20),                              "비철수주가
        BIGO4       LIKE ZNFT1011-BIGO4,        "비고
      END   OF GT_1011.

DATA: BEGIN OF GT_1020 OCCURS 0.
        INCLUDE STRUCTURE ZNFT1020.
DATA:   NAME1       LIKE LFA1-NAME1,            "FCM 명
        BSTXT(10),                              "Buy/Sell Text
        CFMTX(20),                              "결재상태 내역
        MITPT(20),                              "집행유형 내역
        CHECK,
      END   OF GT_1020.

DATA: GT_1020N      LIKE GT_1020 OCCURS 0 WITH HEADER LINE,
      GS_1020       LIKE GT_1020.

DATA: GV_REMQTY     LIKE ZNFT1020-EMENG,
      GV_LINE       LIKE SY-TABIX.

DATA: GV_WAERS      LIKE T001-WAERS,    "Currency
      GV_LAND1      LIKE T001-LAND1,    "Country
      GV_BUTXT      LIKE T001-BUTXT,    "Company Name
      GV_KTOPL      LIKE T001-KTOPL,    "Chart of Account
      GV_KOKRS      LIKE TKA02-KOKRS.   "Controlling Area

DATA: GV_CURSOR(30),
      GV_CURLIN     TYPE I,
      GV_LOOPC      LIKE SY-LOOPC,
      GV_CHANGE,
      GV_ANSWER,
      GV_ERROR,
      GV_FLAG.

RANGES: GR_RQTYP    FOR  ZNFT1010-RQTYP.

DATA: OK_CODE       LIKE SY-UCOMM,
      OK_SAVE       LIKE SY-UCOMM.

*___Change Doc.용
DATA: YZNFT1020     LIKE ZNFT1020.

*___F4 Help용 변수
DATA: SELECTFIELD   LIKE  HELP_INFO-FIELDNAME,
      IT_FIELDS     LIKE  HELP_VALUE OCCURS 1 WITH HEADER LINE,
      SELECT_VALUE  LIKE  HELP_INFO-FLDVALUE,
      LD_TABIX      LIKE  SY-TABIX,
      GV_INDEX      LIKE  SY-INDEX.

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

*___FCM
DATA: BEGIN OF GT_FCM OCCURS 0,
        LIFNR       LIKE ZNFT0021-LIFNR,
        NAME1       LIKE LFA1-NAME1,
      END   OF GT_FCM.

*___e-Pro 번호
DATA: BEGIN OF GT_EPRO OCCURS 0,
        ZEPRO       LIKE ZNFT1021-ZEPRO,
        NFKEY       LIKE ZNFT1021-NFKEY,
        FCM         LIKE ZNFT1021-FCM,
        NAME1       LIKE LFA1-NAME1,
        RUDAT       LIKE ZNFT1021-RUDAT,
        BY_SL       LIKE ZNFT1021-BY_SL,
        ENDAT       LIKE ZNFT1021-ENDAT,
        MITYP       LIKE ZNFT1021-MITYP,
        MISPD       LIKE ZNFT1021-MISPD,
        MIMON       LIKE ZNFT1021-MIMON,
        PRICE       LIKE ZNFT1021-PRICE,
        WAERS       LIKE ZNFT1021-WAERS,
        EMENG       LIKE ZNFT1021-EMENG,
        MEINS       LIKE ZNFT1021-MEINS,
        REMQTY      TYPE ZMNG04,
        MISUS       LIKE ZNFT1021-MISUS,
        ZNOTE       LIKE ZNFT1021-ZNOTE,
      END   OF GT_EPRO.

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
