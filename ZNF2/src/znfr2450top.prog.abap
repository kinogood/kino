*&---------------------------------------------------------------------*
*&  Include           ZNFR2450TOP
*&---------------------------------------------------------------------*

INCLUDE ZNFR2450CLS.

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
        BELNR       LIKE ZNFT1052-BELNR,     "회계전표(손익 OR 정산금)
        GJAHR       LIKE ZNFT1052-GJAHR,     "회계년도(손익 OR 정산금)
        BELNR_S     LIKE ZNFT1052-BELNR,     "회계전표(수수료) [CHM2410-00483]
        GJAHR_S     LIKE ZNFT1052-GJAHR,     "회계년도(수수료) [CHM2410-00483]
        CHECK,
      END   OF GT_MAIN.

DATA: BEGIN OF GT_DETL OCCURS 0.
        INCLUDE STRUCTURE ZNFT1052.
DATA:   NAMLF       LIKE LFA1-NAME1,         "FCM 명
        PTEXT       LIKE ZNFT0004-PTEXT,     "손익센터명
        VTEXT       LIKE ZNFT0003-VTEXT,     "영업그룹명
        NAMAG       LIKE KNA1-NAME1,         "고객명
        ZTYPE       TYPE C LENGTH 20,        "정산금/수수료 구분
      END   OF GT_DETL.

DATA: GT_1050       LIKE ZNFT1050 OCCURS 0 WITH HEADER LINE,
      GT_1052       LIKE ZNFT1052 OCCURS 0 WITH HEADER LINE.

DATA: GV_FRDAT      LIKE SY-DATLO,
      GV_TODAT      LIKE SY-DATLO.

DATA: GV_WAERS      LIKE T001-WAERS,    "Currency
      GV_LAND1      LIKE T001-LAND1,    "Country
      GV_BUTXT      LIKE T001-BUTXT,    "Company Name
      GV_KTOPL      LIKE T001-KTOPL,    "Chart of Account
      GV_KOKRS      LIKE TKA02-KOKRS.   "Controlling Area

DATA: GV_BELNR      LIKE BKPF-BELNR. " 손익 OR 정산금
DATA: GV_BELNR_S    LIKE BKPF-BELNR. " 수수료전표

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
      GC_CONTAINER_NAME2    TYPE SCRFNAME VALUE 'CONTAINER2',
      GC_CUSTOM_CONTAINER2  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GC_CONTAINER_2        TYPE REF TO CL_GUI_CONTAINER,
      GC_ALV_GRID2          TYPE REF TO CL_GUI_ALV_GRID,
      GC_EVENT_HANDLER2     TYPE REF TO LCL_EVENT_HANDLER,
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
