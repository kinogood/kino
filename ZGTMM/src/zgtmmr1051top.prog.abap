*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR3000TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* TYPE POOLS
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*  TABLES
*----------------------------------------------------------------------*
TABLES :
  MARC, EKKO, EINE,
  SSCRFIELDS.

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
*=> GTY + _ + XXXXX.XXX
*----------------------------------------------------------------------*

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
  END OF TY_T024E,
  BEGIN OF TY_T024,
    EKGRP TYPE T024-EKGRP,
    EKNAM TYPE T024-EKNAM,
  END OF TY_T024.

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
  GV_ANSWER,
  GV_EDIT,
  GV_NEW,
  GV_ERR,
  GV_MODE.

DATA :
  GV_EKGRP    TYPE EKGRP,
  GV_LIFNR    TYPE LIFNR,
  GV_INFO(30) TYPE C,
  GV_TEXT     TYPE SO_OBJ_DES,
  GV_DYNNR    TYPE SY-DYNNR.

*----------------------------------------------------------------------*
* GLOBAL STRUCTURE
*----------------------------------------------------------------------*
* => GS + '_' XX.XXX
*----------------------------------------------------------------------*
DATA : BEGIN OF GS_LIST,
         STATUS     TYPE ICON-NAME, "상태(아이콘)

         MATNR      TYPE ZGTMM_CV_GET_INFOPRICE-MATNR,
         MATNR_N    TYPE ZGTMM_CV_GET_INFOPRICE-MATNR_N,
         LIFNR      TYPE EKKO-LIFNR,
         LIFNR_N    TYPE ZGTMM_CV_GET_INFOPRICE-LIFNR_N,
         EKORG      TYPE T024E-EKORG,
         EKORG_N    TYPE T024E-EKOTX,
         WERKS      TYPE T001W-WERKS,
         WERKS_N    TYPE T001W-NAME1,
         ESOKZ      TYPE ZGTMM_CV_GET_INFOPRICE-ESOKZ,
         ESOKZ_N    TYPE ZGTMM_CV_GET_INFOPRICE-ESKOZ_N,"ESOKZ_N,
         EKGRP      TYPE ZGTMM_CV_GET_INFO_APPROVE-EKGRP,
         EKGRP_N    TYPE ZGTMM_CV_GET_INFO_APPROVE-EKGRP_N,
         APLFZ      TYPE ZGTMM_CV_GET_INFOPRICE-APLFZ,  "계획납품시간
         NORBM      TYPE ZGTMM_CV_GET_INFOPRICE-NORBM ,  "표준 PO수량
         MEINS      TYPE ZGTMM_CV_GET_INFOPRICE-MEINS,
         UEBTO      TYPE ZGTMM_CV_GET_INFOPRICE-UEBTO,    "초과허용치(%)
         UNTTO      TYPE ZGTMM_CV_GET_INFOPRICE-UNTTO,     "미달허용치(%)
         UEBTK      TYPE ZGTMM_CV_GET_INFOPRICE-UEBTK,     "무제한납품
         VERID      TYPE ZGTMM_CV_GET_INFOPRICE-VERID,      "임가공버전
         WEBRE      TYPE ZGTMM_CV_GET_INFOPRICE-WEBRE,     "GR 기준IV
         XERSN      TYPE ZGTMM_CV_GET_INFOPRICE-XERSN,      "NO ERS
         BSTAE      TYPE ZGTMM_CV_GET_INFOPRICE-BSTAE,       "확인관리
         DATAB      TYPE ZGTMM_CV_GET_INFOPRICE-DATAB,      "유효시작일
         DATBI      TYPE ZGTMM_CV_GET_INFOPRICE-DATBI,      "유효종료일
         KBETR      TYPE ZGTMM_CV_GET_INFOPRICE-KBETR,      "단가
         KONWA    TYPE ZGTMM_CV_GET_INFOPRICE-KONWA,     "통화
         KPEIN      TYPE ZGTMM_CV_GET_INFOPRICE-KPEIN ,       "PER
         KMEIN      TYPE ZGTMM_CV_GET_INFOPRICE-KMEIN,       "단가단위

         ZFR1     TYPE ZGTMM_CV_GET_INFO_APPROVE-ZFR1,       "단가단위
         ZFR1_UNIT      TYPE ZGTMM_CV_GET_INFOPRICE-ZFR1_UNIT,       "단가단위
         ZFR2      TYPE ZGTMM_CV_GET_INFO_APPROVE-ZFR2,       "단가단위
         ZFR2_UNIT      TYPE ZGTMM_CV_GET_INFOPRICE-ZFR2_UNIT,       "단가단위

         ZFR1_I     TYPE ZGTMM_CV_GET_INFO_APPROVE-ZFR1,       "단가단위
         ZFR1_UNIT_I      TYPE ZGTMM_CV_GET_INFOPRICE-ZFR1_UNIT,       "단가단위
         ZFR2_I      TYPE ZGTMM_CV_GET_INFO_APPROVE-ZFR2,       "단가단위
         ZFR2_UNIT_I      TYPE ZGTMM_CV_GET_INFOPRICE-ZFR2_UNIT,       "단가단위

         MEPRF      TYPE ZGTMM_CV_GET_INFOPRICE-MEPRF,    "가격결정일
         MEPRF_N  TYPE ZGTMM_CV_GET_INFO_APPROVE-MEPRF_N,    "가격결정일
         INCO1       TYPE ZGTMM_CV_GET_INFOPRICE-INCO1 ,    "인코텀스
         INCO1_N    TYPE ZGTMM_CV_GET_INFOPRICE-INCO1_N ,    "인코텀스
         MWSKZ      TYPE ZGTMM_CV_GET_INFOPRICE-MWSKZ,     "세금코드
         MWSKZ_N  TYPE ZGTMM_CV_GET_INFOPRICE-MWSKZ_N,  "세금코드
         ERDAT        TYPE ZGTMM_CV_GET_INFO_APPROVE-ERDAT, "생성일
         ERDAT_LOCAL TYPE ZGTMM_CV_GET_INFO_APPROVE-ERDAT_LOCAL ,
         ERTIM                TYPE ZGTMM_CV_GET_INFO_APPROVE-ERTIM ,
         ERTIM_LOCAL  TYPE ZGTMM_CV_GET_INFO_APPROVE-ERTIM_LOCAL,
         ERNAM           TYPE ZGTMM_CV_GET_INFO_APPROVE-ERNAM,
         AEDAT              TYPE ZGTMM_CV_GET_INFO_APPROVE-ERDAT,
         AEDAT_LOCAL  TYPE ZGTMM_CV_GET_INFO_APPROVE-ERDAT_LOCAL,
         AETIM             TYPE ZGTMM_CV_GET_INFO_APPROVE-ERTIM,
         AETIM_LOCAL TYPE ZGTMM_CV_GET_INFO_APPROVE-ERTIM_LOCAL,
         AENAM            TYPE ZGTMM_CV_GET_INFO_APPROVE-ERNAM,

         MESSAGE    TYPE BAPIRET2-MESSAGE,
*         STYLE      TYPE LVC_T_STYL,
       END OF GS_LIST.

DATA :  GS_RETURN LIKE BAPIRET2.

*----------------------------------------------------------------------*
* GLOBAL INTERNAL TABLE                                                *
*----------------------------------------------------------------------*
* => GT_ + XXX...XX                                                    *
*----------------------------------------------------------------------*
DATA :
       GT_LIST   LIKE TABLE OF GS_LIST.

DATA:
  GT_T001  TYPE SORTED TABLE OF TY_T001 WITH UNIQUE KEY BUKRS,
  GT_T001W TYPE SORTED TABLE OF TY_T001W WITH UNIQUE KEY WERKS,
  GT_T024E TYPE SORTED TABLE OF TY_T024E WITH UNIQUE KEY EKORG,
  GT_T024  TYPE SORTED TABLE OF TY_T024 WITH UNIQUE KEY EKGRP.

DATA : GT_RETURN LIKE TABLE OF BAPIRET2.

DATA :
       GT_MTXT TYPE BCSY_TEXT,
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
  GC_0(1) VALUE '0',
  GC_1(1)  VALUE '1',
  GC_3(1)  VALUE '3',
  GC_BT(2) VALUE 'BT',
  GC_EQ(2) VALUE 'EQ',
  GC_CL(2) VALUE 'CL',
  GC_PR(2) VALUE 'PR',
  GC_MM(2) VALUE 'MM'.

CONSTANTS :
  GC_KSRM(4)      VALUE 'KSRM',
  GC_TAXKR(5)     VALUE 'TAXKR'.

CONSTANTS:
  GC_ZGTMMR1050 TYPE W3OBJID VALUE 'ZGTMMR1050'.

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

*----------------------------------------------------------------------*
* SELECTION SCREEN
*----------------------------------------------------------------------*
* SELECTION OPTION => SO_XX...X
* PARAMETER        => PA_XX...X
* CHECKBOX         => CB_XX...X
* RADIO BUTTON     => RB_XX...X
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
*MODIF ID->활성화 하는 기준
  PARAMETERS :
               P_EKORG TYPE T024E-EKORG OBLIGATORY, "구매조직
               P_WERKS TYPE MARC-WERKS OBLIGATORY . "플랜트

  SELECT-OPTIONS : "S_WERKS FOR MARC-WERKS  OBLIGATORY, "플랜트
                                S_EKGRP FOR MARC-EKGRP ,  "구매그룹
                                S_LIFNR   FOR EKKO-LIFNR ,    "공급업체
                                S_MATNR FOR MARC-MATNR , "자재코드
                                S_ERDAT  FOR EKKO-AEDAT OBLIGATORY. "생성일

SELECTION-SCREEN END OF BLOCK B1.
