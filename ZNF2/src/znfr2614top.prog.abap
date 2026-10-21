*&---------------------------------------------------------------------*
*&  Include           ZNFR2613TOP
*&---------------------------------------------------------------------*
TYPE-POOLS : SLIS.

TABLES: ZNFT1000, ZNFT1010, ZNFT1011, ZNFT1020, ZNFT1030, ZNFT1051,
        ZNFT1055, LFA1, T001.

************************************************************************
* GLOBAL Structure & Internal Table
************************************************************************
* ALV LIST : OUT 대상(ZNFT1051) 단위 IN전표 대상
DATA: BEGIN OF GS_OUTTAB,
        ICON(4),
        CHECK,
        STATUS    TYPE CHAR20,               " 처리상태
        MSG       TYPE CHAR100,              " 메시지
        BUKRS     LIKE ZNFT1051-BUKRS,
        BUKRS_NM  LIKE T001-BUTXT,           " 회사명
        NFCTR     LIKE ZNFT1000-NFCTR,
        NFCTR_NM  LIKE ZNFT0005-NTEXT,
        PRCTR     LIKE ZNFT1051-PRCTR,
        PRCTR_NM  LIKE ZNFT0004-PTEXT,
        VKGRP     LIKE ZNFT1051-VKGRP,
        VKGRP_NM  LIKE ZNFT0003-VTEXT,
        KUNNR     LIKE ZNFT1051-KUNNR,
        NCUST     LIKE ZNFT1000-NCUST,
        CONNO     LIKE ZNFT1051-CONNO,
        COTXT     LIKE ZNFT1000-COTXT,
        SALER     LIKE ZNFT1000-SALER,
        REQNO     LIKE ZNFT1051-REQNO,
        H_NO1     LIKE ZNFT1051-H_NO1,
        RQTYP     LIKE ZNFT1010-RQTYP,       " 선물요청유형
        RQTYP_NM  TYPE CHAR20,
        NFKEY     LIKE ZNFT1051-NFKEY,
        FCM       LIKE ZNFT1051-FCM,
        FCM_NM    LIKE LFA1-NAME1,
        SUPREME   LIKE ZNFT1051-NFUTN,       " 최상위 집행번호
        SUP_RUDAT LIKE ZNFT1020-RUDAT,       " 최상위 집행일

*       ### OUT 대상 (만기이동 시 자산화) ###
        NFUTN     LIKE ZNFT1051-NFUTN,       " OUT 대상 신규집행번호 (TECH)
        N_RUDAT   LIKE ZNFT1020-RUDAT,       " OUT 대상 신규집행일   (TECH)
        CFUTN     LIKE ZNFT1051-CFUTN,       " OUT 대상 청산집행번호 (TECH)
        C_RUDAT   LIKE ZNFT1030-RUDAT,       " OUT 대상 청산집행일   (TECH)
        NBY_SL    LIKE ZNFT1051-NBY_SL,      " 신규집행 Buy/Sell     (TECH)
        B_NFUTN   LIKE ZNFT1051-NFUTN,       " Buy  집행번호 (ZNFR2612 동일)
        B_RUDAT   LIKE ZNFT1020-RUDAT,       " Buy  집행일
        S_NFUTN   LIKE ZNFT1051-NFUTN,       " Sell 집행번호
        S_RUDAT   LIKE ZNFT1030-RUDAT,       " Sell 집행일
        ENDAT     LIKE ZNFT1051-ENDAT,       " OUT 대상 만기일
        EMENG     LIKE ZNFT1051-EMENG,       " OUT 수량(본 라인)
        N_EMENG   LIKE ZNFT1051-EMENG,       " OUT 대상 수량 합계(동일 신규집행)
        N_SMENG   LIKE ZNFT1051-EMENG,       " OUT 대상 만기이동 수량
        MEINS     LIKE ZNFT1051-MEINS,
        KPRLO     LIKE ZNFT1051-KPRLO,       " 선물손익(원화) = OUT 손익
        KAERS     LIKE ZNFT1051-KAERS,
        UPRLO     LIKE ZNFT1051-UPRLO,       " 선물손익(외화)
        UAERS     LIKE ZNFT1051-UAERS,
        KURSF     LIKE ZNFT1051-KURSF,       " 적용환율
        ZBELNR    LIKE ZNFT1051-ZBELNR,      " MC회계전표 (OUT 전표)
        ZGJAHR    LIKE ZNFT1051-ZGJAHR,      " MC회계년도

*       ### 해당월 판매 선물 (만기월 기준) ###
        L_NFUTN   LIKE ZNFT1020-NFUTN,       " 판매 선물집행번호(대표)
        L_CNT     TYPE I,                    " 판매 선물 건수
        L_ENDAT   LIKE ZNFT1020-ENDAT,       " 판매 선물 만기일
        L_YNFIN   LIKE ZNFT1020-YNFIN,       " 정산여부
        L_EMENG   LIKE ZNFT1020-EMENG,       " 만기월 총수량
        L_SMENG   LIKE ZNFT1020-EMENG,       " 만기이동 수량
        S_EMENG   LIKE ZNFT1020-EMENG,       " 판매수량(IN 대상)

*       ### IN전표 금액 ###
        KRATE     LIKE ZNFT1055-KRATE,       " 비율(%)       : 금회
        TKRATE    LIKE ZNFT1055-KRATE,       " 전체비율(%)   : 기존 누적
        T_KRATE   LIKE ZNFT1055-KRATE,       " 반영후 누적비율(%)
        TKPRLO    LIKE ZNFT1055-KPRLO,       " 전체 IN금액   : 기존 IN 누계
        P_KPRLO   LIKE ZNFT1055-KPRLO,       " 귀속 선물손익 : 금회 IN 금액
        R_KPRLO   LIKE ZNFT1055-KPRLO,       " 반영후 잔액
        I_HNO1    LIKE ZNFT1055-H_NO1,       " ZNFT1055 항번
        YBELNR    LIKE ZNFT1055-YBELNR,      " 귀속회계전표 (IN 전표)
        YGJAHR    LIKE ZNFT1055-YGJAHR,      " 귀속회계년도
        BUDAT     LIKE ZNFT1055-BUDAT,
        REMON     LIKE ZNFT1055-REMON,

*       ### Buy / Sell 상세 (ZNFR2612 동일) ###
        NMISPD    LIKE ZNFT1051-NMISPD,      " 신규 Spread
        NPRICE    LIKE ZNFT1051-NPRICE,      " 신규 단가
        N_FEE     LIKE ZNFT1051-N_FEE,       " 신규 수수료
        CMISPD    LIKE ZNFT1051-CMISPD,      " 청산 Spread
        CPRICE    LIKE ZNFT1051-CPRICE,      " 청산 단가
        C_FEE     LIKE ZNFT1051-C_FEE,       " 청산 수수료
        B_MISPD   LIKE ZNFT1051-NMISPD,      " Buy Spread
        B_PRICE   LIKE ZNFT1051-NPRICE,      " Buy 단가
        BUY_AMT   TYPE DMBTR,                " Buy 금액 : EMENG * (PRICE+SPREAD)
        B_FEE     LIKE ZNFT1051-N_FEE,       " Buy 수수료
        S_MISPD   LIKE ZNFT1051-CMISPD,      " Sell Spread
        S_PRICE   LIKE ZNFT1051-CPRICE,      " Sell 단가
        SELL_AMT  TYPE DMBTR,                " Sell 금액 : EMENG * (PRICE+SPREAD)
        S_FEE     LIKE ZNFT1051-C_FEE,       " Sell 수수료
        WAERS     LIKE ZNFT1051-WAERS,

        CELLTAB   TYPE LVC_T_STYL,           " Cell 단위 수정 스타일
        COLINFO   TYPE LVC_T_SCOL.           " CELL 색상 지정
DATA: END OF GS_OUTTAB.
DATA: GT_OUTTAB LIKE TABLE OF GS_OUTTAB.

* 만기월 판매 선물(만기이동 결과 선물)
DATA: BEGIN OF GS_LEAF,
        NFUTN     LIKE ZNFT1020-NFUTN,
        BUKRS     LIKE ZNFT1020-BUKRS,
        REQNO     LIKE ZNFT1020-REQNO,
        H_NO1     LIKE ZNFT1020-H_NO1,
        NFKEY     LIKE ZNFT1020-NFKEY,
        FCM       LIKE ZNFT1020-FCM,
        ENDAT     LIKE ZNFT1020-ENDAT,
        EMENG     LIKE ZNFT1020-EMENG,
        MEINS     LIKE ZNFT1020-MEINS,
        OLDFT     LIKE ZNFT1020-OLDFT,
        MCTYP     LIKE ZNFT1020-MCTYP,
        YNFIN     LIKE ZNFT1020-YNFIN,
        CONNO     LIKE ZNFT1011-CONNO,
        SMENG     LIKE ZNFT1020-EMENG,       " 만기이동 수량
        SOLDQ     LIKE ZNFT1020-EMENG,       " 판매수량
      END OF GS_LEAF.
DATA: GT_LEAF LIKE TABLE OF GS_LEAF.

* 선물집행 이력(OLDFT) Cache
DATA: BEGIN OF GS_OLDFT,
        NFUTN     LIKE ZNFT1020-NFUTN,
        OLDFT     LIKE ZNFT1020-OLDFT,
      END OF GS_OLDFT.
DATA: GT_OLDFT LIKE HASHED TABLE OF GS_OLDFT WITH UNIQUE KEY NFUTN.

* 선물별 만기이동(하위 선물) 수량 Cache
DATA: BEGIN OF GS_SHFQ,
        NFUTN     LIKE ZNFT1020-NFUTN,
        EMENG     LIKE ZNFT1020-EMENG,
      END OF GS_SHFQ.
DATA: GT_SHFQ LIKE HASHED TABLE OF GS_SHFQ WITH UNIQUE KEY NFUTN.

* OUT 대상 신규집행별 OUT전표 수량 Cache
DATA: BEGIN OF GS_OUTN,
        NFUTN     LIKE ZNFT1051-NFUTN,
        EMENG     LIKE ZNFT1051-EMENG,       " OUT전표 수량 합계
        SMENG     LIKE ZNFT1051-EMENG,       " 만기이동 수량
      END OF GS_OUTN.
DATA: GT_OUTN LIKE HASHED TABLE OF GS_OUTN WITH UNIQUE KEY NFUTN.

* OUT전표 생성된 선물손익확정 (ZNFR2611 결과)
DATA: GT_1051O TYPE SORTED TABLE OF ZNFT1051
               WITH UNIQUE KEY NFUTN CFUTN.

* IN전표 대상 집계 (OUT 대상 단위)
DATA: BEGIN OF GS_TARGET,
        NFUTN     LIKE ZNFT1051-NFUTN,
        CFUTN     LIKE ZNFT1051-CFUTN,
        SUPREME   LIKE ZNFT1051-NFUTN,
        L_NFUTN   LIKE ZNFT1020-NFUTN,
        L_CNT     TYPE I,
        L_ENDAT   LIKE ZNFT1020-ENDAT,
        L_YNFIN   LIKE ZNFT1020-YNFIN,
        L_EMENG   LIKE ZNFT1020-EMENG,
        L_SMENG   LIKE ZNFT1020-EMENG,
        SOLDQ     LIKE ZNFT1020-EMENG,
      END OF GS_TARGET.
DATA: GT_TARGET LIKE SORTED TABLE OF GS_TARGET
                WITH UNIQUE KEY NFUTN CFUTN.

* OUT 대상별 판매 선물 목록 (판매선물 건수 더블클릭 팝업)
DATA: BEGIN OF GS_TLEAF,
        NFUTN     LIKE ZNFT1051-NFUTN,       " OUT 대상 신규집행
        CFUTN     LIKE ZNFT1051-CFUTN,       " OUT 대상 청산집행
        L_NFUTN   LIKE ZNFT1020-NFUTN,       " 판매 선물집행번호
        L_ENDAT   LIKE ZNFT1020-ENDAT,       " 판매 만기일
        L_YNFIN   LIKE ZNFT1020-YNFIN,       " 판매선물 정산여부
        L_EMENG   LIKE ZNFT1020-EMENG,       " 만기월 총수량
        L_SMENG   LIKE ZNFT1020-EMENG,       " 만기이동 수량
        SOLDQ     LIKE ZNFT1020-EMENG,       " 판매수량
        MEINS     LIKE ZNFT1020-MEINS,
      END OF GS_TLEAF.
DATA: GT_TLEAF LIKE STANDARD TABLE OF GS_TLEAF.

************************************************************************
* F4 Help용 변수
************************************************************************
DATA: SELECTFIELD   LIKE  HELP_INFO-FIELDNAME,
      IT_FIELDS     LIKE  HELP_VALUE OCCURS 1 WITH HEADER LINE,
      SELECT_VALUE  LIKE  HELP_INFO-FLDVALUE,
      LD_TABIX      LIKE  SY-TABIX,
      GV_INDEX      LIKE  SY-INDEX.

DATA: SCR_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE,
      FELD_TABLE LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

* 사업부
DATA: BEGIN OF GT_NFCTR OCCURS 0,
        NFCTR       LIKE ZNFT0005-NFCTR,
        NTEXT       LIKE ZNFT0005-NTEXT,
      END OF GT_NFCTR.

* 손익센터
DATA: BEGIN OF GT_PRCTR OCCURS 0,
        PRCTR       LIKE ZNFT0003-PRCTR,
        PTEXT       LIKE ZNFT0003-PTEXT,
      END OF GT_PRCTR.

* 영업그룹
DATA: BEGIN OF GT_VKGRP OCCURS 0,
        VKGRP       LIKE ZNFT0003-VKGRP,
        VTEXT       LIKE ZNFT0003-VTEXT,
      END OF GT_VKGRP.

* FCM
DATA: BEGIN OF GT_FCM OCCURS 0,
        LIFNR       LIKE ZNFT0021-LIFNR,
        NAME1       LIKE LFA1-NAME1,
      END   OF GT_FCM.

************************************************************************
* GLOBAL VARIABLE
************************************************************************
DATA: OK_CODE TYPE SY-UCOMM,
      OK_SAVE TYPE SY-UCOMM,
      GV_CODE TYPE SY-UCOMM.

DATA: GV_ANSWER TYPE CHAR01,
      GV_ERROR  TYPE CHAR01,
      GV_REPID  TYPE SY-REPID.

DATA: GV_LINE TYPE SY-TABIX,
      GV_CNT  TYPE I.

DATA: GV_BLDAT      LIKE BKPF-BLDAT,
      GV_BUDAT      LIKE BKPF-BUDAT,
      GV_BELNR      LIKE BKPF-BELNR.

* 전표생성 팝업(0300) 표시용
DATA: GV_POST_CNT(6) TYPE N,              "화면 0300 NUMC 6
      GV_POST_AMT   LIKE ZNFT1055-KPRLO,
      GV_POST_WAERS LIKE ZNFT1051-KAERS.

* 회사코드관련 정보
DATA: GV_WAERS      LIKE T001-WAERS,    "Currency
      GV_LAND1      LIKE T001-LAND1,    "Country
      GV_BUTXT      LIKE T001-BUTXT,    "Company Name
      GV_KTOPL      LIKE T001-KTOPL,    "Chart of Account
      GV_KOKRS      LIKE TKA02-KOKRS.   "Controlling Area

* 만기일 From ~ To
DATA: GV_FRDAT      LIKE SY-DATLO,
      GV_TODAT      LIKE SY-DATLO.

* 상태 ICON
CONSTANTS: GC_ICON_GREEN  TYPE CHAR4 VALUE '@5B@',   "생성완료
           GC_ICON_RED    TYPE CHAR4 VALUE '@5C@',   "오류
           GC_ICON_YELLOW TYPE CHAR4 VALUE '@5D@'.   "생성대상

* 누적비율 100% 판단 허용치
CONSTANTS: GC_FULL_RATE   TYPE P DECIMALS 2 VALUE '99.99'.

*___BDC용 변수
TABLES : CTU_PARAMS.

DATA : BEGIN OF GT_BDCTAB OCCURS 0.
        INCLUDE STRUCTURE BDCDATA.
DATA : END   OF GT_BDCTAB.

DATA : GT_RETMSG LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.

************************************************************************
* ALV GLOBAL VARIABLE
************************************************************************
CLASS : LCL_EVENT_HANDLER DEFINITION DEFERRED.

DATA: GRF_CONTAINER      TYPE REF TO CL_GUI_DOCKING_CONTAINER,
      GRF_GRID           TYPE REF TO CL_GUI_ALV_GRID,
      GRF_EVENT_HANDLER  TYPE REF TO LCL_EVENT_HANDLER.

DATA: GT_EXCLUDE  TYPE UI_FUNCTIONS,
      GT_SORT     TYPE LVC_T_SORT,  GS_SORT     TYPE LVC_S_SORT,
      GT_FIELDCAT TYPE LVC_T_FCAT,  GS_FIELDCAT TYPE LVC_S_FCAT,
      GS_LAYOUT   TYPE LVC_S_LAYO,  GS_VARIANT  TYPE DISVARIANT,
      GT_ROWS     TYPE LVC_T_ROW,   GS_ROWS     TYPE LVC_S_ROW,
      GT_COLS     TYPE LVC_T_COL,   GS_COLS     TYPE LVC_S_COL,
      GT_F4       TYPE LVC_T_F4,    GS_F4       TYPE LVC_S_F4,
      GT_CELLTAB  TYPE LVC_T_STYL,  GS_CELLTAB  TYPE LVC_S_STYL,
      GS_STBL     TYPE LVC_S_STBL,
      GT_FILTER   TYPE LVC_T_FILT.

DATA: BEGIN OF GT_EXCL OCCURS 0,
        FCODE       LIKE SY-UCOMM,
      END   OF GT_EXCL.
