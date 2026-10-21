*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR3010TOP
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
  GV_NEW,
  GV_ERR,
  GV_PASS,
  GV_VALID,
  GV_MODE.

DATA :
  GV_TEXT TYPE SO_OBJ_DES.

*----------------------------------------------------------------------*
* GLOBAL STRUCTURE
*----------------------------------------------------------------------*
* => GS + '_' XX.XXX
*----------------------------------------------------------------------*
DATA : BEGIN OF GS_HEAD.
DATA :   STATUS TYPE ICON-NAME,"상태(아이콘)
            STATUSC TYPE ICON_NAME.
          INCLUDE TYPE ZGTMM_CV_GET_PO_DATA_APH.
DATA : MESSAGE TYPE BAPIRET2-MESSAGE,
          END OF GS_HEAD.

DATA : BEGIN OF GS_LIST.
          INCLUDE TYPE ZGTMM_CV_GET_PO_DATA_GRL.
DATA : MESSAGE TYPE BAPIRET2-MESSAGE,
          END OF GS_LIST.

DATA :  GS_RETURN LIKE BAPIRET2,
            GS_FUNCTXT TYPE SMP_DYNTXT.

*----------------------------------------------------------------------*
* GLOBAL INTERNAL TABLE
*----------------------------------------------------------------------*
* => GT_ + XXX...XX
*----------------------------------------------------------------------*
DATA : GT_LIST       LIKE TABLE OF GS_LIST,  "전체 헤더 기준 아이템 데이터용
           GT_ITEM      LIKE TABLE OF GS_LIST, "선택 헤더 기준 아이템 데이터용
           GT_HEAD     LIKE TABLE OF GS_HEAD.
DATA : GT_RETURN LIKE TABLE OF BAPIRET2.

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
     GC_A(1)             VALUE 'A',
     GC_C(1)             VALUE 'C',
     GC_D(1)             VALUE 'D',
     GC_E(1)             VALUE 'E',
     GC_F(1)             VALUE 'F',
     GC_H(1)             VALUE 'H',
     GC_I(1)              VALUE 'I',
     GC_J(1)              VALUE 'J',
     GC_L(1)             VALUE 'L',
     GC_N(1)             VALUE 'N',
     GC_O(1)             VALUE 'O',
     GC_R(1)             VALUE 'R',
     GC_S(1)             VALUE 'S',
     GC_X(1)             VALUE 'X',
     GC_1(1)             VALUE '1',
     GC_BT(2)           VALUE 'BT',
     GC_EQ(2)           VALUE 'EQ',
     GC_MM(2)          VALUE 'MM',
     GC_KSRM(4)       VALUE 'KSRM'.

CONSTANTS :
GC_ZGRSTATUS(9) VALUE 'ZGRSTATUS',
GC_ZIVSTATUS(9) VALUE 'ZIVSTATUS'.

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
SELECTION-SCREEN FUNCTION KEY 1.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.

  PARAMETERS       :  P_BUKRS TYPE T001-BUKRS OBLIGATORY, "회사코드
                                P_EKORG  TYPE T024E-EKORG OBLIGATORY, "구매조직
                                P_WERKS TYPE MARC-WERKS OBLIGATORY.  "플랜트

  SELECT-OPTIONS : S_EKGRP FOR MARC-EKGRP,  "구매그룹
                                S_EBELN FOR EKKO-EBELN, "구매오더
                                S_LIFNR   FOR EKKO-LIFNR,    "공급업체
                                S_ERDAT FOR EKKO-AEDAT. "생성일

SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.

    PARAMETERS P_DPO AS CHECKBOX DEFAULT GC_X. "승인 PO 제외
    SELECTION-SCREEN COMMENT (15) TEXT-C01 FOR FIELD P_DPO.

SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK B2.
