*&---------------------------------------------------------------------*
*&  Include           ZNFR2430TOP
*&---------------------------------------------------------------------*

INCLUDE ZNFR2430CLS.

CONSTANTS: GC_TCODE1  LIKE SY-TCODE       VALUE 'ZNF2R2430',  "원화반영
           GC_TCODE2  LIKE SY-TCODE       VALUE 'ZNF2R2430R'. "취소

DATA: BEGIN OF GT_MAIN OCCURS 0,
        BUKRS       LIKE ZNFT1020-BUKRS,     "회사코드
        ENDAT       LIKE ZNFT1020-ENDAT,     "만기일
        FCM         LIKE ZNFT1020-FCM,       "FCM
        NAME1       LIKE LFA1-NAME1,         "FCM 명
        BYCNT       TYPE I,                  "Buy Position 건수
        SLCNT       TYPE I,                  "Sell Position 건수
        BMENG       LIKE ZNFT1020-EMENG,     "Buy 집행수량
        SMENG       LIKE ZNFT1020-EMENG,     "Sell 집행수량
        MEINS       LIKE ZNFT1020-MEINS,     "단위
        NCCHK(4),                            "오류확인
        NETIG(4),                            "넷팅생성
        CONFM(4),                            "손익확정
        TRWON(4),                            "원화환산
        CREFI(4),                            "전표생성
        CHECK,
      END   OF GT_MAIN.

DATA: GS_MAIN       LIKE GT_MAIN.

DATA: BEGIN OF GT_DETL OCCURS 0,
        ICON(4),                            "상태
        NFKEY       LIKE ZNFT1051-NFKEY,    "비철구분
        EMENG       LIKE ZNFT1051-EMENG,    "집행수량
        MEINS       LIKE ZNFT1051-MEINS,    "단위
        BFUTN       LIKE ZNFT1051-NFUTN,    "매입집행번호
        SFUTN       LIKE ZNFT1051-CFUTN,    "매각집행번호
        NBY_SL      LIKE ZNFT1051-NBY_SL,   "신규 Buy/Sell
        BYPRC       LIKE ZNFT1051-NPRICE,   "Buy 단가
        BYAMT       LIKE ZNFT1051-NPRICE,   "Buy 총액
        BYFEE       LIKE ZNFT1051-N_FEE,    "Buy 수수료
        SLPRC       LIKE ZNFT1051-NPRICE,   "Sell 단가
        SLAMT       LIKE ZNFT1051-NPRICE,   "Sell 총액
        SLFEE       LIKE ZNFT1051-N_FEE,    "Sell 수수료
        UPRLO       LIKE ZNFT1051-UPRLO,    "선물손익(USD)
        UAERS       LIKE ZNFT1051-UAERS,    "통화(USD)
        KPRLO       LIKE ZNFT1051-KPRLO,    "선물손익(KRW)
        KAERS       LIKE ZNFT1051-KAERS,    "통화(KRW)
        KURSF       LIKE ZNFT1051-KURSF,    "환율
        WWERT       LIKE ZNFT1051-WWERT,    "환산일
        MESSAGE(200),                       "오류 Log
        PRCTR       LIKE ZNFT1051-PRCTR,    "손익센터
        PTEXT       LIKE ZNFT0004-PTEXT,    "손익센터명
        VKGRP       LIKE ZNFT1051-VKGRP,    "영업그룹
        VTEXT       LIKE ZNFT0003-VTEXT,    "영업그룹명
        KUNNR       LIKE ZNFT1051-KUNNR,    "고객
        NAME1       LIKE KNA1-NAME1,        "고객명
        CONNO       LIKE ZNFT1051-CONNO,    "계약번호
        COTXT       LIKE ZNFT1000-COTXT,    "계약명
        REQNO       LIKE ZNFT1051-REQNO,    "선물요청번호
        H_NO1       LIKE ZNFT1051-H_NO1,    "선물요청항번
        CONFM       LIKE ZNFT1020-CONFM,    "신규결재상태
        CFMTX(20),
        CONFM1      LIKE ZNFT1030-CONFM,    "청산결재상태
        CFMTX1(20),
        YNCAN       LIKE ZNFT1020-YNCAN,    "신규취소여부
        YNCAN1      LIKE ZNFT1030-YNCAN,    "청산취소여부
        YNFIN       LIKE ZNFT1020-YNFIN,    "신규정산여부
        YNFIN1      LIKE ZNFT1030-YNFIN,    "청산정산여부
      END   OF GT_DETL.

DATA: GT_1020       LIKE ZNFT1020 OCCURS 0 WITH HEADER LINE,
      GT_1030       LIKE ZNFT1030 OCCURS 0 WITH HEADER LINE,
      GT_1050       LIKE ZNFT1050 OCCURS 0 WITH HEADER LINE,
      GT_1051       LIKE ZNFT1051 OCCURS 0 WITH HEADER LINE,
      GT_1052       LIKE ZNFT1052 OCCURS 0 WITH HEADER LINE.

DATA: GV_DATUM      LIKE SY-DATUM,          "환산일
      GV_UKURS      LIKE TCURR-UKURS,       "환율
      GV_UAERS      LIKE T001-WAERS VALUE 'USD'.

DATA: GV_FRDAT      LIKE SY-DATLO,
      GV_TODAT      LIKE SY-DATLO.

DATA: GV_WAERS      LIKE T001-WAERS,    "Currency
      GV_LAND1      LIKE T001-LAND1,    "Country
      GV_BUTXT      LIKE T001-BUTXT,    "Company Name
      GV_KTOPL      LIKE T001-KTOPL,    "Chart of Account
      GV_KOKRS      LIKE TKA02-KOKRS.   "Controlling Area

DATA: GV_TRTYP      LIKE T180-TRTYP,
      GV_TITLE(50).

DATA: GV_ERROR,
      GV_ANSWER.

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
      GV_INDEX      LIKE  SY-INDEX.

DATA: SCR_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE,
      FELD_TABLE LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF GT_EXCH OCCURS 0,
        WWERT       LIKE ZNFT1051-WWERT,
        KURSF       TYPE EDI5402_A,
      END   OF GT_EXCH.

*___ALV용 변수
DATA: GC_CONTAINER_NAME1    TYPE SCRFNAME VALUE 'CONTAINER1',
      GC_CUSTOM_CONTAINER1  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GC_ALV_GRID1          TYPE REF TO CL_GUI_ALV_GRID,
      GC_EVENT_HANDLER1     TYPE REF TO LCL_EVENT_HANDLER,
      GC_CONTAINER_NAME2    TYPE SCRFNAME VALUE 'CONTAINER2',
      GC_CUSTOM_CONTAINER2  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GC_EVENT_HANDLER2     TYPE REF TO LCL_EVENT_HANDLER,
      GC_ALV_GRID2          TYPE REF TO CL_GUI_ALV_GRID,
      GS_LAYOUT             TYPE LVC_S_LAYO,
      GT_SORT               TYPE LVC_T_SORT WITH HEADER LINE,
      GT_FIELDCAT           TYPE LVC_T_FCAT WITH HEADER LINE,
      GT_FIELDCAT2          TYPE LVC_T_FCAT WITH HEADER LINE,
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
