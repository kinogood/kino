*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR4390TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*

TYPES:
  BEGIN OF TY_LIST,
    STATUS    TYPE ICON_D,
    SPMON      TYPE  ZGTMM_CV_GET_SO_GR_BYMON-SPMON,                 "기간
    BUKRS      TYPE ZGTMM_CV_GET_SO_GR_BYMON-BUKRS   ,           " 회사코드  HIDDEN
    WERKS      TYPE ZGTMM_CV_GET_SO_GR_BYMON-WERKS ,           " 플랜트
    WERKS_N    TYPE  ZGTMM_CV_GET_SO_GR_BYMON-WERKS_N  ,   " 플랜트명
    LIFNR      TYPE  ZGTMM_CV_GET_SO_GR_BYMON-LIFNR,             "공급업체
    LIFNR_N    TYPE  ZGTMM_CV_GET_SO_GR_BYMON-LIFNR_N,               " 업체명
    ORT01       TYPE LFA1-ORT01, "지역
    EKGRP      TYPE  ZGTMM_CV_GET_SO_GR_BYMON-EKGRP,             "구매그룹
    EBELN      TYPE  ZGTMM_CV_GET_PO_GR_BYMON-EBELN  ,           "구매오더
    EBELP      TYPE  ZGTMM_CV_GET_PO_GR_BYMON-EBELP  ,         " 항번

    VBELN      TYPE  ZGTMM_CV_GET_SO_GR_BYMON-VBELN  ,           "판매오더
    POSNR      TYPE  ZGTMM_CV_GET_SO_GR_BYMON-POSNR  ,         " 항번
    VKBUR      TYPE ZGTMM_CV_GET_OEM_IV_TARGET-VKBUR  , "TTS
    VKBUR_N  TYPE ZGTMM_CV_GET_OEM_IV_TARGET-VKBUR_N  , "TTS
    VKGRP  TYPE ZGTMM_CV_GET_OEM_IV_TARGET-VKGRP  , "TTS
    VKGRP_N TYPE ZGTMM_CV_GET_OEM_IV_TARGET-VKGRP_N  , "TTS

    MATNR      TYPE    ZGTMM_CV_GET_SO_GR_BYMON-MATNR,             "자재코드
    MAKTX      TYPE  ZGTMM_CV_GET_SO_GR_BYMON-MAKTX,           " 자재명
    PRODNAME   TYPE  ZGTMM_CV_GET_SO_GR_BYMON-PRODNAME,             "품명
    SPECNO     TYPE  ZGTMM_CV_GET_SO_GR_BYMON-SPECNO   ,         "SPECNO
    COLOR      TYPE    ZGTMM_CV_GET_SO_GR_BYMON-COLOR  ,         "색상
    PO_QTY     TYPE    ZGTMM_CV_GET_SO_GR_BYMON-PO_QTY ,         " PO 수량
    PO_MEINS   TYPE ZGTMM_CV_GET_SO_GR_BYMON-PO_MEINS ,             " 단위
    LENGTH     TYPE    ZGTMM_CV_GET_SO_GR_BYMON-LENGTH ,           " 조장
    DRQTY      TYPE    ZGTMM_CV_GET_SO_GR_BYMON-DRQTY,             "PO 드럼수
    MATGR      TYPE    ZGTMM_CV_GET_SO_GR_BYMON-MATGR    ,     "입고수량
    MATGR_DR   TYPE  ZGTMM_CV_GET_SO_GR_BYMON-MATGR_DR ,             "입고드럼수
    MATGR_UNIT TYPE  ZGTMM_CV_GET_SO_GR_BYMON-MATGR_UNIT,              "   입고단위
    KBETR      TYPE  ZGTMM_CV_GET_SO_GR_BYMON-KBETR  ,       " 단가
    KONWA      TYPE  ZGTMM_CV_GET_SO_GR_BYMON-KONWA,           " 통화
    KPEIN      TYPE  ZGTMM_CV_GET_SO_GR_BYMON-KPEIN  ,       " PER
    KMEIN      TYPE    ZGTMM_CV_GET_SO_GR_BYMON-KMEIN,         " PER 단위
    TOTALPRICE TYPE  ZGTMM_CV_GET_SO_GR_BYMON-TOTALPRICE , ""          총액
    TAXVALUE TYPE  ZGTMM_CV_GET_OEM_IV_TARGET-TAXVALUE , ""          TAX금액

    EXRATE_TTS  TYPE ZGTMM_CV_GET_OEM_IV_TARGET-EXRATE_TTS  , "TTS
    CU_CASH        TYPE ZGTMM_CV_GET_OEM_IV_TARGET-CU_CASH,     "LME
    CU_WAERS     TYPE ZGTMM_CV_GET_OEM_IV_TARGET-CU_WAERS,  "" 통화
    CU_LMC        TYPE ZGTMM_CV_GET_OEM_IV_TARGET-CU_LMC,      "LMC
    CU_KWAERS   TYPE ZGTMM_CV_GET_OEM_IV_TARGET-CU_KWAERS,      """ 통화

    AL_CASH        TYPE ZGTMM_CV_GET_OEM_IV_TARGET-AL_CASH,     "LME
    AL_WAERS     TYPE ZGTMM_CV_GET_OEM_IV_TARGET-AL_WAERS,  "" 통화
    AL_LMC        TYPE ZGTMM_CV_GET_OEM_IV_TARGET-AL_LMC,      "LMC
    AL_KWAERS   TYPE ZGTMM_CV_GET_OEM_IV_TARGET-AL_KWAERS,      """ 통화

    NES_CU     TYPE    ZGTMM_CV_GET_SO_GR_BYMON-NES_CU , "  CU
    VGW_CU     TYPE  ZGTMM_CV_GET_SO_GR_BYMON-VGW_CU ,       " CU 단위량
    BME_CU     TYPE    ZGTMM_CV_GET_SO_GR_BYMON-BME_CU ,     " 단위
    VGE_CU     TYPE    ZGTMM_CV_GET_SO_GR_BYMON-VGE_CU,    "   PER
    MEINS_B_CU TYPE    ZGTMM_CV_GET_SO_GR_BYMON-MEINS_B_CU ,       "   단위
    VGW_T_CU   TYPE    ZGTMM_CV_GET_SO_GR_BYMON-VGW_T_CU   ,       " CU 총량

    NES_AL     TYPE  ZGTMM_CV_GET_SO_GR_BYMON-NES_AL ,         " AL
    VGW_AL     TYPE  ZGTMM_CV_GET_SO_GR_BYMON-VGW_AL ,           " AL 단위량
    BME_AL     TYPE  ZGTMM_CV_GET_SO_GR_BYMON-BME_AL ,           " 단위
    VGE_AL     TYPE  ZGTMM_CV_GET_SO_GR_BYMON-VGE_AL ,         " PER
    MEINS_B_AL TYPE  ZGTMM_CV_GET_SO_GR_BYMON-MEINS_B_AL     ,       " 단위
    VGW_T_AL   TYPE  ZGTMM_CV_GET_SO_GR_BYMON-VGW_T_AL ,         "   AL 총량

    NES_FI     TYPE  ZGTMM_CV_GET_SO_GR_BYMON-NES_FI   ,           " FI
    VGW_FI     TYPE   ZGTMM_CV_GET_SO_GR_BYMON-VGW_FI ,             " FI 단위량
    BME_FI     TYPE  ZGTMM_CV_GET_SO_GR_BYMON-BME_FI ,             "   단위
    VGE_FI     TYPE  ZGTMM_CV_GET_SO_GR_BYMON-VGE_FI ,           " PER
    MEINS_B_FI TYPE  ZGTMM_CV_GET_SO_GR_BYMON-MEINS_B_FI ,           "   단위
    VGW_T_FI   TYPE  ZGTMM_CV_GET_SO_GR_BYMON-VGW_T_FI   ,           " FI 총량

    MWSKZ_S         TYPE ZGTMM_CV_GET_OEM_IV_TARGET-MWSKZ_S ,     " TAX(SO)
    MSWKZ_S_N      TYPE ZGTMM_CV_GET_OEM_IV_TARGET-MSWKZ_S_N,      " TAX명
    MWSKZ_P           TYPE ZGTMM_CV_GET_OEM_IV_TARGET-MWSKZ_P,      " TAX(PO) "EDIT
    MWSKZ_P_N     TYPE ZGTMM_CV_GET_OEM_IV_TARGET-MWSKZ_P_N   ,    " TAX명

  END OF TY_LIST.


*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*

DATA:
  GT_LIST TYPE STANDARD TABLE OF TY_LIST.

DATA:
  GV_ERR,
  GV_ANSWER,
  GV_PERIOD TYPE SPMON,
  GV_EKGRP  TYPE T024-EKGRP,
  GV_EBELN  TYPE EKKO-EBELN,
  GV_LIFNR  TYPE LFA1-LIFNR,
  GV_VBELN  TYPE VBAK-VBELN.

DATA:
  GT_ECOMM  TYPE STANDARD TABLE OF SY-UCOMM,
  GV_OKCODE TYPE SY-UCOMM.

*SMARTFORMS
DATA: FUNC_NAME          LIKE RS38L-NAME.
DATA: PRINTER            LIKE TSP03D-PADEST.
DATA: OTF LIKE ITCOO OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS:
  GC_A     TYPE C LENGTH 1 VALUE 'A',
  GC_C     TYPE C LENGTH 1 VALUE 'C',
  GC_E     TYPE C LENGTH 1 VALUE 'E',
  GC_I     TYPE C LENGTH 1 VALUE 'I',
  GC_S     TYPE C LENGTH 1 VALUE 'S',
  GC_X     TYPE C LENGTH 1 VALUE 'X',
  GC_BT    TYPE C LENGTH 2 VALUE 'BT',
  GC_EQ    TYPE C LENGTH 2 VALUE 'EQ',
  GC_LGORT TYPE C LENGTH 4 VALUE '3497'.

*----------------------------------------------------------------------*
* ALV
*----------------------------------------------------------------------*
DATA:
  GO_GRID  TYPE REF TO CL_GUI_ALV_GRID,
  GO_CONT  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
  GV_ASAVE TYPE CHAR01 VALUE 'A',
  GS_LAYO  TYPE LVC_S_LAYO,
  GS_VARI  TYPE DISVARIANT,
  GT_FCAT  TYPE LVC_T_FCAT,
  GT_FCAT_DELI  TYPE LVC_T_FCAT,
  GT_SORT  TYPE LVC_T_SORT,
  GT_EXCL  TYPE UI_FUNCTIONS.

*----------------------------------------------------------------------*
* SCREEN - 1000
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-S01.

  PARAMETERS :
    P_BUKRS TYPE T001-BUKRS OBLIGATORY MEMORY ID BUK DEFAULT '6000',
    P_WERKS TYPE T001W-WERKS OBLIGATORY ,
    P_EKGRP TYPE T024-EKGRP OBLIGATORY ,
    P_PERIOD TYPE J_7LS990-SPMON OBLIGATORY.

  SELECT-OPTIONS:
    S_LIFNR FOR GV_LIFNR .
SELECTION-SCREEN END   OF BLOCK B01.
