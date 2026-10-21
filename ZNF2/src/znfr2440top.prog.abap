*&---------------------------------------------------------------------*
*&  Include           ZNFR2440TOP
*&---------------------------------------------------------------------*

INCLUDE ZNFR2440CLS.

DATA: BEGIN OF GT_MAIN OCCURS 0,
        BUKRS       LIKE ZNFT1052-BUKRS,     "회사코드
        ENDAT       LIKE ZNFT1052-ENDAT,     "만기일
        FCM         LIKE ZNFT1052-FCM,       "FCM
        NAME1       LIKE LFA1-NAME1,         "FCM 명
        KURSF       LIKE ZNFT1052-KURSF,     "환율
        WWERT       LIKE ZNFT1052-WWERT,     "환산일
        NCCHK(4),                            "오류확인
        NETIG(4),                            "넷팅생성
        CONFM(4),                            "손익확정
        TRWON(4),                            "원화환산
        CREFI(4),                            "전표생성
        CHECK,
      END   OF GT_MAIN.

DATA: BEGIN OF GT_HEAD OCCURS 0.
        INCLUDE STRUCTURE ZNFT1052.
DATA:   PTEXT       LIKE ZNFT0004-PTEXT,
        VTEXT       LIKE ZNFT0003-VTEXT,
        NAME1       LIKE KNA1-NAME1,
        MESSAGE(100),
        CHECK,
*        UPRLO_B LIKE ZNFT1052-UPRLO, " 정산금 손익(USD)
*        UPRLO_S LIKE ZNFT1052-UPRLO, " 수수료 손익(USD)
*        KPRLO_B LIKE ZNFT1052-KPRLO, " 정산금 손익(KRW)
*        KPRLO_S LIKE ZNFT1052-KPRLO, " 수수료 손익(KRW)
      END   OF GT_HEAD.

DATA: BEGIN OF GT_ITEM OCCURS 0,
        BFUTN       LIKE ZNFT1051-NFUTN,     "매입집행번호
        SFUTN       LIKE ZNFT1051-NFUTN,     "매각집행번호
        NFKEY       LIKE ZNFT1051-NFKEY,     "비철구분
        NBY_SL      LIKE ZNFT1051-NBY_SL,    "신규 Buy/Sell 구분
        ENDAT       LIKE ZNFT1051-ENDAT,     "만기일
        FCM         LIKE ZNFT1051-FCM,       "FCM
        PRCTR       LIKE ZNFT1051-PRCTR,     "손익센터
        VKGRP       LIKE ZNFT1051-VKGRP,     "영업그룹
        KUNNR       LIKE ZNFT1051-KUNNR,     "고객
        EMENG       LIKE ZNFT1051-EMENG,     "집행수량
        MEINS       LIKE ZNFT1051-MEINS,     "단위
        BYPRC       LIKE ZNFT1051-NPRICE,    "Buy 단가
        BYSPD       LIKE ZNFT1051-NMISPD,    "Buy Spread
        BYAMT       LIKE ZNFT1051-NPRICE,    "Buy 총액
        BYFEE       LIKE ZNFT1051-N_FEE,     "Buy 수수료
        SLPRC       LIKE ZNFT1051-NPRICE,    "Sell 단가
        SLSPD       LIKE ZNFT1051-NMISPD,    "Sell Spread
        SLAMT       LIKE ZNFT1051-NPRICE,    "Sell 총액
        SLFEE       LIKE ZNFT1051-N_FEE,     "Sell 수수료
        UPRLO       LIKE ZNFT1051-UPRLO,     "선물손익(USD)
        UAERS       LIKE ZNFT1051-UAERS,     "통화(USD)
        KPRLO       LIKE ZNFT1051-KPRLO,     "선물손익(KRW)
        KAERS       LIKE ZNFT1051-KAERS,     "통화(KRW)
        KURSF       LIKE ZNFT1051-KURSF,     "환율
        WWERT       LIKE ZNFT1051-WWERT,     "환산일
        UPRLO_B     LIKE ZNFT1051-UPRLO,     "정산금손익(USD)
        KPRLO_B     LIKE ZNFT1051-KPRLO,     "정산금손익(KRW)
        UPRLO_S     LIKE ZNFT1051-UPRLO,     "수수료손익(USD)
        KPRLO_S     LIKE ZNFT1051-KPRLO,     "수수료손익(KRW)
      END   OF GT_ITEM.

DATA: GT_1050       LIKE ZNFT1050 OCCURS 0 WITH HEADER LINE,
      GT_1051       LIKE ZNFT1051 OCCURS 0 WITH HEADER LINE,
      GT_1052       LIKE ZNFT1052 OCCURS 0 WITH HEADER LINE.

DATA: GV_UPRLO      LIKE ZNFT1052-UPRLO,     "전체손익(USD)
      GV_UAERS      LIKE ZNFT1052-UAERS,     "통화(USD)
      GV_KPRLO      LIKE ZNFT1052-KPRLO,     "개별손익(KRW)
      GV_KAERS      LIKE ZNFT1052-KAERS,     "통화(KRW)
      GV_LPRLO      LIKE ZNFT1052-KPRLO,     "환산손익(KRW)
      GV_DIFFR      LIKE ZNFT1052-KPRLO.     "차이(KRW)

*--> [CHM2410-00483] 정산금/수수료 분리
" 정산금
DATA: GV_UPRLO_B     LIKE ZNFT1052-UPRLO,     "전체손익(USD)
      GV_UAERS_B     LIKE ZNFT1052-UAERS,     "통화(USD)
      GV_KPRLO_B     LIKE ZNFT1052-KPRLO,     "개별손익(KRW)
      GV_KAERS_B     LIKE ZNFT1052-KAERS,     "통화(KRW)
      GV_LPRLO_B     LIKE ZNFT1052-KPRLO,     "환산손익(KRW)
      GV_DIFFR_B     LIKE ZNFT1052-KPRLO.     "차이(KRW)

" 수수료
DATA: GV_UPRLO_S     LIKE ZNFT1052-UPRLO,     "전체손익(USD)
      GV_UAERS_S     LIKE ZNFT1052-UAERS,     "통화(USD)
      GV_KPRLO_S     LIKE ZNFT1052-KPRLO,     "개별손익(KRW)
      GV_KAERS_S     LIKE ZNFT1052-KAERS,     "통화(KRW)
      GV_LPRLO_S     LIKE ZNFT1052-KPRLO,     "환산손익(KRW)
      GV_DIFFR_S     LIKE ZNFT1052-KPRLO.     "차이(KRW)
*<-- [CHM2410-00483] 정산금/수수료 분리

DATA: GV_FCM        LIKE ZNFT1052-FCM.

DATA: GV_FRDAT      LIKE SY-DATLO,
      GV_TODAT      LIKE SY-DATLO.

DATA: GV_BLDAT      LIKE BKPF-BLDAT,
      GV_BUDAT      LIKE BKPF-BUDAT,
      GV_BELNR      LIKE BKPF-BELNR.

*--> [CHM2410-00483] 정산금/수수료 분리
DATA: GV_BLDAT_BS      LIKE BKPF-BLDAT,
      GV_BUDAT_BS      LIKE BKPF-BUDAT,
      GV_BELNR_B       LIKE BKPF-BELNR,
      GV_BELNR_S       LIKE BKPF-BELNR,
      GV_KUNNR_BS      LIKE ZNFT0021-KUNNR.
*<-- [CHM2410-00483] 정산금/수수료 분리

DATA: GV_WAERS      LIKE T001-WAERS,    "Currency
      GV_LAND1      LIKE T001-LAND1,    "Country
      GV_BUTXT      LIKE T001-BUTXT,    "Company Name
      GV_KTOPL      LIKE T001-KTOPL,    "Chart of Account
      GV_KOKRS      LIKE TKA02-KOKRS.   "Controlling Area

DATA: GV_ERROR,
      GV_ANSWER.

DATA: OK_CODE       LIKE SY-UCOMM,
      OK_SAVE       LIKE SY-UCOMM.

*___BDC용 변수
TABLES : CTU_PARAMS.

DATA : BEGIN OF GT_BDCTAB OCCURS 0.
        INCLUDE STRUCTURE BDCDATA.
DATA : END   OF GT_BDCTAB.

DATA : GT_RETMSG LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.

*___ALV용 변수
DATA: GC_CONTAINER_NAME1    TYPE SCRFNAME VALUE 'CONTAINER1',
      GC_CUSTOM_CONTAINER1  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GC_ALV_GRID1          TYPE REF TO CL_GUI_ALV_GRID,
      GC_EVENT_HANDLER1     TYPE REF TO LCL_EVENT_HANDLER,
      SPLITTER              TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
      GC_CONTAINER_NAME2    TYPE SCRFNAME VALUE 'CONTAINER2',
      GC_CUSTOM_CONTAINER2  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GC_CONTAINER_2        TYPE REF TO CL_GUI_CONTAINER,
      GC_CONTAINER_3        TYPE REF TO CL_GUI_CONTAINER,
      GC_ALV_GRID2          TYPE REF TO CL_GUI_ALV_GRID,
      GC_ALV_GRID3          TYPE REF TO CL_GUI_ALV_GRID,
      GC_EVENT_HANDLER2     TYPE REF TO LCL_EVENT_HANDLER,
      GC_EVENT_HANDLER3     TYPE REF TO LCL_EVENT_HANDLER,
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
