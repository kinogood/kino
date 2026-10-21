*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR1020TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* TYPE POOLS                                                           *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*  TABLES                                                              *
*----------------------------------------------------------------------*
TABLES :
  T001W,
  SSCRFIELDS,
  MARA.

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
*=> GTY + _ + XXXXX.XXX
*----------------------------------------------------------------------*
TYPES : BEGIN OF TY_T001L,
                WERKS TYPE T001L-WERKS,
                LGORT TYPE T001L-LGORT,
                LGOBE TYPE T001L-LGOBE,
             END OF TY_T001L.


TYPES : BEGIN OF TY_T024D,
                WERKS TYPE T024D-WERKS,
                DISPO TYPE T024D-DISPO,
                DSNAM TYPE T024D-DSNAM,
             END OF TY_T024D.

*----------------------------------------------------------------------*
* GLOBAL VARIABLE
*----------------------------------------------------------------------*
* => GV + '_' XX.XXX
*----------------------------------------------------------------------*
DATA :
  GV_OKCODE        TYPE SY-UCOMM,
  GV_OKCODE_SAVE   TYPE SY-UCOMM,
  GV_ANSWER,
  GV_EDIT,
  GV_ERR,
  GV_CNT(5).

*----------------------------------------------------------------------*
* GLOBAL STRUCTURE
*----------------------------------------------------------------------*
* => GS + '_' XX.XXX
*----------------------------------------------------------------------*
DATA : BEGIN OF GS_LIST,
         STATUS   TYPE ICON-ID,       "수정 상태 ICON

         WERKS       TYPE ZGTMM_CV_PUR_MARC-WERKS, "플랜트
         NAME1       TYPE ZGTMM_CV_PUR_MARC-NAME1,
         MTART       TYPE ZGTMM_CV_PUR_MARC-MTART,
         MTBEZ      TYPE ZGTMM_CV_PUR_MARC-MTBEZ,
         MATNR    TYPE ZGTMM_CV_PUR_MARC-MATNR,
         MAKTX    TYPE ZGTMM_CV_PUR_MARC-MAKTX,
         EKGRP    TYPE ZGTMM_CV_PUR_MARC-EKGRP,
         EKNAM    TYPE ZGTMM_CV_PUR_MARC-EKNAM,
         EKWSL    TYPE ZGTMM_CV_PUR_MARC-EKWSL,
         WEBAZ    TYPE ZGTMM_CV_PUR_MARC-WEBAZ,      "납품소요일
         KORDB    TYPE ZGTMM_CV_PUR_MARC-KORDB,      "
         INSMK    TYPE ZGTMM_CV_PUR_MARC-INSMK,        "검사재고로 전기_품질
         DISMM    TYPE ZGTMM_CV_PUR_MARC-DISMM,        "MRP 유형_ROP
         DIBEZ     TYPE ZGTMM_CV_PUR_MARC-DIBEZ,          "MRP 유형명_ROP
         LGFSB    TYPE ZGTMM_CV_PUR_MARC-LGFSB,        "입고저장위치_ROP
         LGOBE   TYPE ZGTMM_CV_PUR_MARC-LGOBE,        "입고저장위치명_ROP
         MINBE    TYPE ZGTMM_CV_PUR_MARC-MINBE,         "재발주점_ROP
         DISLS     TYPE ZGTMM_CV_PUR_MARC-DISLS,          "LOT SIZE 전략_ROP
         LOSLT    TYPE ZGTMM_CV_PUR_MARC-LOSLT,         "LOT SIZE 전략명_ROP
         DISPO   TYPE ZGTMM_CV_PUR_MARC-DISPO,           "MRP 관리자
         DSNAM  TYPE ZGTMM_CV_PUR_MARC-DSNAM,           "MRP 관리자명
         BSTFE    TYPE ZGTMM_CV_PUR_MARC-BSTFE,          "고정 LOT SIZE_ROP
         PLIFZ     TYPE ZGTMM_CV_PUR_MARC-PLIFZ,            "계획 납품 소요일_ROP
         EISBE     TYPE ZGTMM_CV_PUR_MARC-EISBE,           "안전재고 수량_ROP
         MEINS    TYPE  ZGTMM_CV_PUR_MARC-MEINS,
         SBDKZ   TYPE  ZGTMM_CV_PUR_MARC-SBDKZ,         "소요량지시자_ROP

         MESSAGE  LIKE BAPIRET2-MESSAGE,
         STYLE       TYPE LVC_T_STYL,
       END OF GS_LIST.

DATA :  GS_T001  LIKE T001W,
            GS_RETURN LIKE BAPIRET2.

*----------------------------------------------------------------------*
* GLOBAL INTERNAL TABLE                                                *
*----------------------------------------------------------------------*
* => GT_ + XXX...XX                                                    *
*----------------------------------------------------------------------*
DATA : GT_LIST       LIKE TABLE OF GS_LIST.
DATA : GT_RETURN LIKE TABLE OF BAPIRET2.
DATA : GT_T001L     TYPE TABLE OF TY_T001L.
DATA : GT_T024D     TYPE TABLE OF TY_T024D.

DATA : BEGIN OF GT_DD07T OCCURS 0,
         DOMNAME    LIKE DD07T-DOMNAME,
         DOMVALUE_L LIKE DD07T-DOMVALUE_L,
         DDTEXT     LIKE DD07T-DDTEXT,
       END OF GT_DD07T.

"세금코드 TEXT.
DATA : BEGIN OF GT_007S OCCURS 0,
         MWSKZ LIKE T007S-MWSKZ,
         TEXT1 LIKE T007S-TEXT1,
       END OF GT_007S.

"사업장 TEXT.
DATA : BEGIN OF GT_BRANCH OCCURS 0,
         BUPLA TYPE J_1BBRANCH-BRANCH,
         NAME  TYPE J_1BBRANCH-NAME,
       END OF GT_BRANCH.

"계정코드
DATA : BEGIN OF GT_ACCT OCCURS 0,
         SAKNR  LIKE ZTRTF271-SAKNR,
         TXT50  LIKE ZTRTF271-TXT50,
         SHKZG  LIKE ZTRTF271-SHKZG,
         LIMIT  LIKE ZTRTF271-LIMIT,
         LIMIT2 LIKE ZTRTF271-LIMIT2,
       END OF GT_ACCT.


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
CONSTANTS : GC_WAERS    LIKE BKPF-WAERS  VALUE 'KRW'.  "통화키

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
  PARAMETERS       :  P_WERKS TYPE T001W-WERKS OBLIGATORY. "플랜트

  SELECT-OPTIONS : S_MTART FOR MARA-MTART,  "자재유형
                                S_MATNR FOR MARA-MATNR. "자재코드


SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-002.
  SELECTION-SCREEN BEGIN OF LINE.
*구매/품질/ROP정보 구분 조회
    PARAMETERS P_PUR RADIOBUTTON GROUP GR01  USER-COMMAND UC01 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (15) TEXT-R01 FOR FIELD P_PUR.

    PARAMETERS P_QUL RADIOBUTTON GROUP GR01.
    SELECTION-SCREEN COMMENT (15) TEXT-R02 FOR FIELD P_QUL.

    PARAMETERS P_ROP RADIOBUTTON GROUP GR01.
    SELECTION-SCREEN COMMENT (15) TEXT-R03 FOR FIELD P_ROP.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK B2.

SELECTION-SCREEN FUNCTION KEY 1.
