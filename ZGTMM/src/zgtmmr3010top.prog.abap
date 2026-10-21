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
  GV_MODE.

DATA :
  GV_TEXT TYPE SO_OBJ_DES.


**-- 26.09 추가
DATA: GV_VBELN_POSNR TYPE C LENGTH 16.
*----------------------------------------------------------------------*
* GLOBAL STRUCTURE
*----------------------------------------------------------------------*
* => GS + '_' XX.XXX
*----------------------------------------------------------------------*
DATA : BEGIN OF GS_LIST.
DATA :   STATUS TYPE ICON-ID."상태(아이콘)
          INCLUDE TYPE ZGTMM_CV_GET_PO_DATA_GRL.
DATA : REQ_ICON TYPE ICON_NAME,
           REL_STAT_ICON TYPE ICON_NAME,
           MESSAGE TYPE BAPIRET2-MESSAGE,
           COLO TYPE LVC_T_SCOL,
          END OF GS_LIST.

DATA :  GS_RETURN LIKE BAPIRET2.

*----------------------------------------------------------------------*
* GLOBAL INTERNAL TABLE                                                *
*----------------------------------------------------------------------*
* => GT_ + XXX...XX                                                    *
*----------------------------------------------------------------------*
DATA : GT_LIST       LIKE TABLE OF GS_LIST.
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
     GC_PO(2)           VALUE 'PO'.

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
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.

  PARAMETERS       :  P_BUKRS TYPE T001-BUKRS OBLIGATORY, "회사코드
                                P_EKORG  TYPE T024E-EKORG OBLIGATORY. "구매조직

  SELECT-OPTIONS : S_WERKS FOR MARC-WERKS, "플랜트
                                S_EKGRP FOR MARC-EKGRP,  "구매그룹
                                S_ERDAT FOR EKKO-AEDAT, "생성일
                                S_EINDT  FOR EKKO-AEDAT, "납품예정일
                                S_EBELN FOR EKKO-EBELN, "구매오더
                                S_LIFNR   FOR EKKO-LIFNR,    "공급업체
                                S_MATNR FOR MARC-MATNR, "자재코드
                                S_VBELN FOR VBAK-VBELN. "판매오더
**-- 26.09 판매문서&품번 조건 추가
  SELECT-OPTIONS : S_SOPO FOR GV_VBELN_POSNR MODIF ID CRE.
SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-002.
  SELECTION-SCREEN BEGIN OF LINE.

    PARAMETERS P_DPO AS CHECKBOX. "삭제 PO 제외
    SELECTION-SCREEN COMMENT (15) TEXT-C01 FOR FIELD P_DPO.

    PARAMETERS P_FIN AS CHECKBOX. "납품완료  PO 제외
    SELECTION-SCREEN COMMENT (15) TEXT-C02 FOR FIELD P_FIN.

    PARAMETERS P_RPO AS CHECKBOX. "반품  PO 제외
    SELECTION-SCREEN COMMENT (15) TEXT-C03 FOR FIELD P_RPO.

SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK B2.
