*&---------------------------------------------------------------------*
*&  Include           ZNFR2420TOP
*&---------------------------------------------------------------------*

INCLUDE ZNFR2420CLS.

CONSTANTS: GC_TCODE1  LIKE SY-TCODE       VALUE 'ZNF2R2420',  "확정
           GC_TCODE2  LIKE SY-TCODE       VALUE 'ZNF2R2420R'. "확정취소

TABLES: ZNFT1020,
        ZNFT1030,
        ZNFT1050,
        ZNFT1040,
        ZNFT1041.

DATA: BEGIN OF GT_MAIN OCCURS 0,
        BUKRS       LIKE ZNFT1020-BUKRS,     "회사코드
        ENDAT       LIKE ZNFT1020-ENDAT,     "만기일
        FCM         LIKE ZNFT1020-FCM,       "FCM
        NAME1       LIKE LFA1-NAME1,         "FCM 명
        NFKEY       LIKE ZNFT1020-NFKEY,     "비철구분
        NFCNT       TYPE I,                  "신규건수
        CFCNT       TYPE I,                  "청산건수
        BMENG       LIKE ZNFT1020-EMENG,     "Buy 수량
        SMENG       LIKE ZNFT1020-EMENG,     "Sell 수량
        MEINS       LIKE ZNFT1020-MEINS,     "단위
        NCCHK(4),                            "오류확인
        NETIG(4),                            "넷팅생성
        CONFM(4),                            "손익확정
        TRWON(4),                            "원화환산
        CREFI(4),                            "전표생성
        CHECK,
        MARK,

        F_COL       TYPE LVC_T_SCOL,
        CELLTAB     TYPE LVC_T_STYL,
      END   OF GT_MAIN.

DATA: GS_MAIN       LIKE GT_MAIN.

DATA: BEGIN OF GT_DETL OCCURS 0,
        ICON(4),                            "상태
        BUY,                                "Buy 수수료
        SELL,                               "Sell 수수료
        ENDAT       LIKE ZNFT1020-ENDAT,    "만기일
        FCM         LIKE ZNFT1020-FCM,      "FCM
        NAMLF       LIKE LFA1-NAME1,        "FCM 명
        NFKEY       LIKE ZNFT1020-NFKEY,    "비철구분
        BY_SL       LIKE ZNFT1020-BY_SL,    "신규Buy/Sell
        ENDAT1      LIKE ZNFT1030-ENDAT,    "만기일
        FCM1        LIKE ZNFT1030-FCM,      "FCM
        NFKEY1      LIKE ZNFT1030-NFKEY,    "비철구분
        BY_SL1      LIKE ZNFT1020-BY_SL,    "청산Buy/Sell
        MEINS       LIKE ZNFT1020-MEINS,    "단위
        MCNT(2),                            "차수
        FUTNO       LIKE ZNFT1020-NFUTN,    "매입집행번호
        TRIND(10),                          "매입구분
        MITYP       LIKE ZNFT1020-MITYP,    "매입유형
        MITPT(20),                          "매입유형내역
        PRICE       LIKE ZNFT1020-PRICE,    "Buy 단가
        MISPD       LIKE ZNFT1020-MISPD,    "Buy Spread
        EMENG       LIKE ZNFT1020-EMENG,    "Buy 수량
        WRBTR       LIKE ZNFT1020-PRICE,    "Buy 총액
        WAERS       LIKE ZNFT1020-WAERS,    "Buy 통화
        N_FEE       LIKE ZNFT1020-PRICE,    "Buy 수수료
        MISUS       LIKE ZNFT1020-MISUS,    "Buy 수수료여부
        NETNG(10),                          "Buy Netting 여부
        MFUTN       LIKE ZNFT1020-NFUTN,    "매각집행번호
        MGIND(10),                          "매각구분
        MITYP1      LIKE ZNFT1030-MITYP,    "매각집행유형
        MITPT1(20),                         "매각유형내역
        PRICE1      LIKE ZNFT1030-PRICE,    "Sell 단가
        MISPD1      LIKE ZNFT1030-MISPD,    "Sell Spread
        EMENG1      LIKE ZNFT1030-EMENG,    "Sell 집행수량
        WRBTR1      LIKE ZNFT1030-PRICE,    "Sell 총액
        WAERS1      LIKE ZNFT1030-WAERS,    "Sell 통화
        C_FEE       LIKE ZNFT1030-PRICE,    "Sell 수수료
        MISUS1      LIKE ZNFT1030-MISUS,    "Sell 수수료여부
        NETNG1(10),                         "Sell Netting 여부
        PRFIT       LIKE ZNFT1030-PRICE,    "선물손익
        MESSAGE(100),                       "오류 Log
        CONNO       LIKE ZNFT1000-CONNO,    "계약번호
        COTXT       LIKE ZNFT1000-COTXT,    "계약명
        KUNNR       LIKE ZNFT1000-KUNNR,    "고객코드
        NAMAG       LIKE KNA1-NAME1,        "고객명
        NFCTR       LIKE ZNFT1000-NFCTR,    "사업부
        NTEXT       LIKE ZNFT0005-NTEXT,    "사업부명
        PRCTR       LIKE ZNFT1000-PRCTR,    "손익센터
        PTEXT       LIKE ZNFT0004-PTEXT,    "손익센터명
        VKGRP       LIKE ZNFT1000-VKGRP,    "영업그룹
        VTEXT       LIKE ZNFT0003-VTEXT,    "영업그룹명
        REQNO       LIKE ZNFT1011-REQNO,    "선물요청번호
        H_NO1       LIKE ZNFT1011-H_NO1,    "선물요청항번
        CONFM       LIKE ZNFT1020-CONFM,    "신규결재상태
        CFMTX(20),
        CONFM1      LIKE ZNFT1030-CONFM,    "청산결재상태
        CFMTX1(20),
        YNCAN       LIKE ZNFT1020-YNCAN,    "신규취소여부
        YNCAN1      LIKE ZNFT1030-YNCAN,    "청산취소여부
        YNFIN       LIKE ZNFT1020-YNFIN,    "신규정산여부
        YNFIN1      LIKE ZNFT1030-YNFIN,    "청산정산여부
        DBCHK,

        F_COL       TYPE LVC_T_SCOL,
        CELLTAB     TYPE LVC_T_STYL,
      END   OF GT_DETL.

DATA: GT_1020       LIKE ZNFT1020 OCCURS 0 WITH HEADER LINE,
      GT_1030       LIKE ZNFT1030 OCCURS 0 WITH HEADER LINE,
      GT_1050       LIKE ZNFT1050 OCCURS 0 WITH HEADER LINE,
      GT_1051       LIKE ZNFT1051 OCCURS 0 WITH HEADER LINE,
      GT_1051N      LIKE ZNFT1051 OCCURS 0 WITH HEADER LINE.

DATA: GV_FEERT1     LIKE ZNFT0021-FEERT1,   "수수료율-분자
      GV_FEERT2     LIKE ZNFT0021-FEERT2,   "수수료율-분모
      GV_PRFIT      LIKE ZNFT1030-PRICE,    "선물손익
      GV_FEE        LIKE ZNFT1051-N_FEE,    "조정수수료
      GV_BMENG      LIKE ZNFT1020-EMENG,    "Buy 수량  (TON)
      GV_SMENG      LIKE ZNFT1020-EMENG,    "Sell 수량 (TON)
      GV_BMENG_LB   LIKE ZNFT1020-EMENG,    "Buy 수량  (LB)
      GV_SMENG_LB   LIKE ZNFT1020-EMENG,    "Sell 수량 (LB)
      GV_BYAMT      LIKE ZNFT1020-PRICE,    "Buy 총액
      GV_SLAMT      LIKE ZNFT1020-PRICE,    "Sell 총액
      GV_BYAMT1     LIKE ZNFT1020-PRICE,    "Buy 총액(수수료계산용)
      GV_SLAMT1     LIKE ZNFT1020-PRICE,    "Sell 총액(수수료계산용)
      GV_BYFEE      LIKE ZNFT1051-N_FEE,    "Buy 수수료
      GV_SLFEE      LIKE ZNFT1051-N_FEE,    "Sell 수수료
      GV_WAERS      LIKE ZNFT1030-WAERS,    "통화
      GV_MEINS      LIKE ZNFT1030-MEINS,    "단위(TON)
      GV_MEINS_LB   LIKE ZNFT1030-MEINS.    "단위(LB)

DATA: GV_FRDAT      LIKE SY-DATLO,
      GV_TODAT      LIKE SY-DATLO.

DATA: GV_SHFNO      LIKE ZNFT1041-SHFNO,    " 만기이동요청번호
      GV_CNT        TYPE I.

DATA: GV_WAERS1     LIKE T001-WAERS,    "Currency
      GV_LAND1      LIKE T001-LAND1,    "Country
      GV_BUTXT      LIKE T001-BUTXT,    "Company Name
      GV_KTOPL      LIKE T001-KTOPL,    "Chart of Account
      GV_KOKRS      LIKE TKA02-KOKRS.   "Controlling Area

DATA: GV_TRTYP      LIKE T180-TRTYP,
      GV_TITLE(50).

DATA: GV_INT        TYPE I,
      GV_ERROR,
      GV_ANSWER.

DATA: BEGIN OF GT_EXCL OCCURS 0,
        FCODE       LIKE SY-UCOMM,
      END   OF GT_EXCL.

DATA: OK_CODE       LIKE SY-UCOMM,
      OK_SAVE       LIKE SY-UCOMM.

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
