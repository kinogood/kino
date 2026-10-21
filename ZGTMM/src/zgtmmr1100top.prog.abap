*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR1100TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* TYPE POOLS
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*  TABLES
*----------------------------------------------------------------------*
TABLES :
  MARC, EKKO, VBAK,
  SSCRFIELDS.

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
*=> GTY + _ + XXXXX.XXX
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF TY_OPT1_XLS,
    CLOSING          TYPE STRING,
    EKORG            TYPE STRING,
    EKORG_N         TYPE STRING,
    WERKS            TYPE STRING,
    WERKS_N        TYPE STRING,
    INFNR              TYPE STRING,
    LIFNR              TYPE STRING,
    LIFNR_N          TYPE STRING,
    MATNR            TYPE STRING,
    MATNR_N         TYPE STRING,
    PRDNAME        TYPE STRING,  "품명
    PRODSIZE        TYPE STRING, "규격
    SPEC_NO        TYPE STRING,
    COLOR            TYPE STRING,
    ESOKZ            TYPE STRING,
    PERIOD           TYPE STRING,
    TTS                 TYPE STRING,
    CU_PRICE          TYPE STRING,
    CU_LMEPER      TYPE STRING,
    CU_MEINS         TYPE STRING,
    CU_NES          TYPE STRING,
    CU_KGW          TYPE STRING,
    CU_BME           TYPE STRING,
    CU_KGU           TYPE STRING,
    CU_PREMIUM    TYPE STRING,
    CU_PERMIUM_WAERS TYPE STRING,
    CU_CRATE        TYPE STRING,
    CU_MCOST       TYPE STRING,
    CU_PER            TYPE STRING,
    CU_MUNIT         TYPE STRING,
    CU_MWAERS     TYPE STRING,
    CU_KURST         TYPE STRING,

    CU_SLMC          TYPE STRING,
    CU_LMC           TYPE STRING,
    SCR_SC           TYPE STRING,
    KWAERS          TYPE STRING,

    TTM                 TYPE STRING,
    AL_PRICE         TYPE STRING,
    AL_LMEPER      TYPE STRING,
    AL_MEINS         TYPE STRING,
    AL_NES           TYPE STRING,
    AL_KGW          TYPE STRING,
    AL_BME           TYPE STRING,
    AL_KGU           TYPE STRING,
    AL_PREMIUM    TYPE STRING,
    AL_PERMIUM_WAERS TYPE STRING,
    AL_CRATE         TYPE STRING,
    AL_MCOST        TYPE STRING,
    AL_PER           TYPE STRING,
    AL_MUNIT        TYPE STRING,
    AL_MWAERS     TYPE STRING,
    AL_KURST      TYPE STRING,

    AL_SLMC         TYPE STRING,
    CU_C_QTY      TYPE STRING,
    AL_C_SPEC     TYPE STRING,
    AL_C_QTY        TYPE STRING,
    KGMEINS         TYPE STRING,
    AL_C_PRICE      TYPE STRING,
    CU_S_QTY        TYPE STRING,
    AL_S_SPEC       TYPE STRING,
    AL_S_QTY         TYPE STRING,
    AL_S_PRICE       TYPE STRING,
    CU_T_QTY         TYPE STRING,
    CU_PRICE_TOTAL TYPE STRING,
    AL_PRICE_TOTAL  TYPE STRING,
    S_MAT_COST      TYPE STRING,
    MFG_COST         TYPE STRING,
    PKG_COST         TYPE STRING,
    SUB_PRICE_TOTAL  TYPE STRING,
    ETC_COST         TYPE STRING,
    OEM_PRICE        TYPE STRING,
    DIS_PRICE        TYPE STRING,
    DRUM_SPEC        TYPE STRING,
    LAST_PO_DATE    TYPE STRING,
    GR_QTY           TYPE STRING,
    GRMEINS         TYPE STRING,
    AP_PRICE        TYPE STRING,
    MEINS            TYPE STRING,
    FWAERS         TYPE STRING,
    KBETR            TYPE STRING,
    KONWA          TYPE STRING,
    KPEIN            TYPE STRING,
    KMEIN            TYPE STRING,
    QIRATE           TYPE STRING,
    MTYPE            TYPE STRING,
    MESSAGE      TYPE STRING,
    ERDAT           TYPE STRING,
    ERDAT_LOCAL   TYPE STRING,
    ERTIM                TYPE STRING,
    ERTIM_LOCAL    TYPE STRING,
    ERNAM             TYPE STRING,
    AEDAT              TYPE STRING,
    AEDAT_LOCAL  TYPE STRING,
    AETIM               TYPE STRING,
    AETIM_LOCAL   TYPE STRING,
    AENAM             TYPE STRING,
  END OF TY_OPT1_XLS,
  TY_T_OPT1_XLS TYPE STANDARD TABLE OF TY_OPT1_XLS.

TYPES:
  BEGIN OF TY_FNAME,
    COL TYPE ALSMEX_TABLINE-COL,
    VALUE TYPE ALSMEX_TABLINE-VALUE,
    FNAME TYPE LVC_FNAME,
  END OF TY_FNAME,
  TY_T_FNAME TYPE STANDARD TABLE OF TY_FNAME.

TYPES:
  BEGIN OF TY_T001,
    BUKRS TYPE T001-BUKRS,
    BUTXT TYPE T001-BUTXT,
  END OF TY_T001,
  BEGIN OF TY_T001W,
    WERKS TYPE T001W-WERKS,
    NAME1 TYPE T001W-NAME1,
  END OF TY_T001W,
  BEGIN OF TY_T024E,
    EKORG TYPE T024E-EKORG,
    EKOTX TYPE T024E-EKOTX,
  END OF TY_T024E.

TYPES :
  BEGIN OF TY_LIST,
    STATUS           TYPE ICON-NAME,
    CLOSING          TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CLOSING,
    EKORG            TYPE ZGTMM_CV_GET_REQPO_DATA-EKORG,
    EKORG_N          TYPE ZGTMM_CV_GET_REQPO_DATA-EKORG_N,
    WERKS            TYPE ZGTMM_CV_GET_REQPO_DATA-WERKS,
    WERKS_N          TYPE ZGTMM_CV_GET_REQPO_DATA-WERKS_N,
    INFNR            TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-INFNR,
    LIFNR            TYPE ZGTMM_CV_GET_REQPO_DATA-LIFNR,
    LIFNR_N          TYPE ZGTMM_CV_GET_REQPO_DATA-LIFNR_N,
    MATNR            TYPE ZGTMM_CV_GET_REQPO_DATA-MATNR,
    MATNR_N          TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-MATNR_N,
    PRDNAME          TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-PRDNAME,  "품명
    PRODSIZE         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-PRODSIZE, "규격
    SPEC_NO          TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-SPEC_NO,
    COLOR            TYPE ZGTMM_CV_GET_REQPO_DATA-COLOR,
    EINE_LOEKZ    TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-EINE_LOEKZ,
    ESOKZ            TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-ESOKZ,
    PERIOD           TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-PERIOD,
    TTS              TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-TTS,
    TTM              TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-TTM,
    CU_NES           TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_NES,
    CU_KGW           TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_KGW,
    CU_BME           TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_BME,
    CU_KGU           TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_KGU,
    CU_PREMIUM       TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_PREMIUM,
    CU_PERMIUM_WAERS TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_PERMIUM_WAERS,
    CU_CRATE         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_CRATE,
    CU_MCOST         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_MCOST,
    CU_PER           TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_PER,
    CU_MUNIT         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_MUNIT,
    CU_MWAERS        TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_MWAERS,
    CU_KURST         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_KURST,
    CU_PRICE         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_PRICE,
    CU_LMEPER        TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_LMEPER,
    CU_MEINS         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_MEINS,
    CU_SLMC          TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_SLMC,
    CU_LMC           TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_LMC,
    SCR_SC           TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-SCR_SC,
    KWAERS           TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-KWAERS,
    AL_NES           TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_NES,
    AL_KGW           TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_KGW,
    AL_BME           TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_BME,
    AL_KGU           TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_KGU,
    AL_PREMIUM       TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_PREMIUM,
    AL_PERMIUM_WAERS TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_PERMIUM_WAERS,
    AL_CRATE         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_CRATE,
    AL_MCOST         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_MCOST,
    AL_PER           TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_PER,
    AL_MUNIT         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_MUNIT,
    AL_MWAERS        TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_MWAERS,
    AL_KURST         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_KURST,
    AL_PRICE         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_PRICE,
    AL_LMEPER        TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_LMEPER,
    AL_MEINS         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_MEINS,
    AL_SLMC          TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_SLMC,
    CU_C_QTY         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_C_QTY,
    AL_C_SPEC        TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_C_SPEC,
    AL_C_QTY         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_C_QTY,
    KGMEINS          TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-KGMEINS,
    AL_C_PRICE       TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_C_PRICE,
    CU_S_QTY         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_S_QTY,
    AL_S_SPEC        TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_S_SPEC,
    AL_S_QTY         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_S_QTY,
    AL_S_PRICE       TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_S_PRICE,
    CU_T_QTY         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_T_QTY,
    CU_PRICE_TOTAL   TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_PRICE_TOTAL,
    AL_PRICE_TOTAL   TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AL_PRICE_TOTAL,
    S_MAT_COST       TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-S_MAT_COST,
    MFG_COST         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-MFG_COST,
    PKG_COST         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-PKG_COST,
    ADD_COST         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-ADD_COST,
    SUB_PRICE_TOTAL  TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-SUB_PRICE_TOTAL,
    ETC_COST         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-ETC_COST,
    OEM_PRICE        TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-OEM_PRICE,
    DIS_PRICE        TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-DIS_PRICE,
    DRUM_SPEC        TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-DRUM_SPEC,
    LAST_PO_DATE     TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-LAST_PO_DATE,
    GR_QTY           TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-GR_QTY,
    GRMEINS          TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-GRMEINS,
    AP_PRICE         TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AP_PRICE,
    MEINS            TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-MEINS,
    FWAERS           TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-FWAERS,
    KBETR            TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-KBETR,
    KONWA          TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-KONWA,
    KPEIN            TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-KPEIN,
    KMEIN            TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-KMEIN,
    QIRATE          TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-QIRATE,
    MTYPE            TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-MTYPE,
    MESSAGE          TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-MESSAGE,
    ERDAT            TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-ERDAT,
    ERDAT_LOCAL      TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-ERDAT_LOCAL,
    ERTIM            TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-ERTIM,
    ERTIM_LOCAL      TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-ERTIM_LOCAL,
    ERNAM            TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-ERNAM,
    AEDAT            TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AEDAT,
    AEDAT_LOCAL      TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AEDAT_LOCAL,
    AETIM            TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AETIM,
    AETIM_LOCAL      TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AETIM_LOCAL,
    AENAM            TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-AENAM,

    STYLE            TYPE LVC_T_STYL,
  END OF TY_LIST,

  BEGIN OF TY_BOM,
    BOMLEVEL          TYPE ZGTMM_CV_GET_BOM_REC3-BOMLEVEL ,
    COMPONENT       TYPE ZGTMM_CV_GET_BOM_REC3-COMPONENT,
    MAKTX                TYPE ZGTMM_CV_GET_BOM_REC3-MAKTX ,
    BOMItemQty        TYPE ZGTMM_CV_GET_BOM_REC3-BOMItemQty ,
    BOMItemQtyUnit  TYPE ZGTMM_CV_GET_BOM_REC3-BOMItemQtyUnit,
    ComponentScrapInPercent	TYPE ZGTMM_CV_GET_BOM_REC3-ComponentScrapInPercent,
    hrktx             TYPE ZGTMM_CV_GET_BOM_REC3-hrktx  ,
    atwrt             TYPE ZGTMM_CV_GET_BOM_REC3-atwrt  ,
  END OF TY_BOM,

  BEGIN OF TY_ONCE,
    CU_LMC    TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_LMC,"적용동가
    CHK_CU,
    SCR_SC     TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-SCR_SC, "SCR
    CHK_SCR,
    AL1350       TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_LMC, "AL1350단가
    CHK_1350,
    STAL          TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_LMC,
    CHK_STAL,
    HTAL          TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_LMC,
    CHK_HTAL,
    AL8176       TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-CU_LMC,
    CHK_8176,
    DIS_PRICE  TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-DIS_PRICE,
    CHK_DIS,
    WAERS      TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-KWAERS,
  END OF TY_ONCE.

*----------------------------------------------------------------------*
* GLOBAL VARIABLE
*----------------------------------------------------------------------*
* => GV + '_' XX.XXX
*----------------------------------------------------------------------*
DATA :
  GV_OKCODE       TYPE SY-UCOMM,
  GV_OKCODE_SAVE  TYPE SY-UCOMM,
  GV_OKCODE_SAVE2 TYPE SY-UCOMM,
  GV_UCOMM        TYPE SY-UCOMM,
  GV_SPMON         TYPE SPMON,
  GV_CH_STYLE,
  GV_HOTSPOT,
  GV_ANSWER,
  GV_ERR.

DATA :
  GV_QUES(30) TYPE C,
  GV_INFO(30) TYPE C,
  GV_TEXT      TYPE SO_OBJ_DES,
  GV_DYNNR    TYPE SY-DYNNR.

*----------------------------------------------------------------------*
* GLOBAL STRUCTURE
*----------------------------------------------------------------------*
* => GS + '_' XX.XXX
*----------------------------------------------------------------------*
DATA :
      GS_LIST TYPE TY_LIST,
      GS_BOM TYPE TY_BOM,
      GS_ONCE TYPE TY_ONCE,
      GS_CREATE TYPE TY_LIST.

DATA : GS_RETURN LIKE BAPIRET2.
DATA : GS_VARIANT LIKE DISVARIANT,
           GS_DROP TYPE LVC_S_DRAL.

*----------------------------------------------------------------------*
* GLOBAL INTERNAL TABLE                                                *
*----------------------------------------------------------------------*
* => GT_ + XXX...XX                                                    *
*----------------------------------------------------------------------*
DATA :
      GT_LIST   TYPE STANDARD TABLE OF TY_LIST,
      GT_BOM   TYPE STANDARD TABLE OF TY_BOM,
      GT_CREATE TYPE STANDARD TABLE OF TY_LIST.

DATA:
  GT_T001  TYPE SORTED TABLE OF TY_T001 WITH UNIQUE KEY BUKRS,
  GT_T001W TYPE SORTED TABLE OF TY_T001W WITH UNIQUE KEY WERKS,
  GT_T024E TYPE SORTED TABLE OF TY_T024E WITH UNIQUE KEY EKORG.

DATA : GT_RETURN LIKE TABLE OF BAPIRET2,
           GT_DROP TYPE LVC_T_DRAL.

DATA : GT_MTXT TYPE BCSY_TEXT,
           GS_MTXT TYPE SOLI.

*----------------------------------------------------------------------*
* GLOBAL RANGE                                                         *
*----------------------------------------------------------------------*
* => GR_ + XXX.XX                                                      *
*----------------------------------------------------------------------*



*----------------------------------------------------------------------*
* GLOBAL FIELD SYMBOLS                                                 *
*----------------------------------------------------------------------*
* => <FS_XXX...XX>, EX)<FS_ITAB>, <FS_WA>, <FS_NN>                     *
*----------------------------------------------------------------------*


*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS :
  GC_A(1)  VALUE 'A',
  GC_C(1)  VALUE 'C',
  GC_D(1)  VALUE 'D',
  GC_E(1)  VALUE 'E',
  GC_F(1)  VALUE 'F',
  GC_H(1)  VALUE 'H',
  GC_I(1)  VALUE 'I',
  GC_J(1)  VALUE 'J',
  GC_K(1)  VALUE 'K',
  GC_L(1)  VALUE 'L',
  GC_M(1)  VALUE 'M',
  GC_N(1)  VALUE 'N',
  GC_O(1)  VALUE 'O',
  GC_P(1)  VALUE 'P',
  GC_R(1)  VALUE 'R',
  GC_S(1)  VALUE 'S',
  GC_X(1)  VALUE 'X',
  GC_U(1)  VALUE 'U',
  GC_1(1)  VALUE '1',
  GC_3(1)  VALUE '3',
  GC_BT(2) VALUE 'BT',
  GC_EQ(2) VALUE 'EQ',
  GC_CL(2) VALUE 'CL',
  GC_PR(2) VALUE 'PR',
  GC_MM(2) VALUE 'MM'.

CONSTANTS :
  GC_KSRM(4)      VALUE 'KSRM',
  GC_M102(4)       VALUE 'M102',
  GC_TAXKR(5)     VALUE 'TAXKR',
  GC_ZGRSTATUS(9) VALUE 'ZGRSTATUS',
  GC_ZIVSTATUS(9) VALUE 'ZIVSTATUS'.

CONSTANTS:
  GC_ZGTMMR1100 TYPE W3OBJID VALUE 'ZGTMMR1100'.

*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
DEFINE _SET_RANGES.

  &1-LOW = &2.
  &1-HIGH = &3.
  &1-OPTION = &4.
  &1-SIGN = &5.
  APPEND &1.

END-OF-DEFINITION.

DEFINE _IDOC.
  DATA LV_PRICE(35).
  LV_PRICE = &2.

*  IF &3 = 'D'.
  " 1. SAP 내부(100.00) -> 외부/IDOC(100) 변환
  CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_IDOC'
  EXPORTING
  CURRENCY      = &1
  SAP_AMOUNT  = LV_PRICE
  IMPORTING
  IDOC_AMOUNT = LV_PRICE. " 결과: 100

*  ELSE. "A
*" 2. 화면 입력(100) -> SAP 내부(100.00) 변환
*  CALL FUNCTION 'CURRENCY_AMOUNT_DISPLAY_TO_SAP'
*    EXPORTING
*      CURRENCY               = &1
*      AMOUNT_DISPLAY    = &2
*    IMPORTING
*      AMOUNT_INTERNAL  = &2. " 결과: 100.00

*  ENDIF.

  &3 = LV_PRICE.

END-OF-DEFINITION.




*----------------------------------------------------------------------*
* SELECTION SCREEN
*----------------------------------------------------------------------*
* SELECTION OPTION => SO_XX...X
* PARAMETER        => PA_XX...X
* CHECKBOX         => CB_XX...X
* RADIO BUTTON     => RB_XX...X
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.

  PARAMETERS : P_EKORG TYPE T024E-EKORG OBLIGATORY, "구매조직
                         P_BUDAT  TYPE EKKO-AEDAT OBLIGATORY,  "정산기준일
                         P_WERKS  TYPE MARC-WERKS MODIF ID MOT. "플랜트
  SELECT-OPTIONS :
*  S_WERKS FOR MARC-WERKS MODIF ID MOT, "플랜트
                                S_LIFNR   FOR EKKO-LIFNR MODIF ID MOT,    "공급업체
                                S_MATNR FOR MARC-MATNR MODIF ID CRE, "자재코드
                                S_MAKTX FOR MARC-MATNR MODIF ID CRE. "판매오더

SELECTION-SCREEN END OF BLOCK B1.
