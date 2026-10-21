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
  MARC, EKKO, PGPL, RBKP,
  SSCRFIELDS.

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
*=> GTY + _ + XXXXX.XXX
*----------------------------------------------------------------------*
 TYPES :
    BEGIN OF TY_TAX,
      CHECK,
      ISSUE_DATE TYPE ZGTMM_CV_GET_TAX_INVOICE-ISSUE_DATE,
      ISSUE_DT TYPE ZGTMM_CV_GET_TAX_INVOICE-ISSUE_DT,
      SU_ID TYPE ZGTMM_CV_GET_TAX_INVOICE-SU_ID,
      LIFNR TYPE ZGTMM_CV_GET_TAX_INVOICE-LIFNR,
      NAME1 TYPE ZGTMM_CV_GET_TAX_INVOICE-NAME1,
      INV_SEQ TYPE ZGTMM_CV_GET_TAX_INVOICE-INV_SEQ,
      CHARGETOTAL TYPE ZGTMM_CV_GET_TAX_INVOICE-CHARGETOTAL,
      TAXTOTAL TYPE ZGTMM_CV_GET_TAX_INVOICE-TAXTOTAL,
      GRANDTOTAL TYPE ZGTMM_CV_GET_TAX_INVOICE-GRANDTOTAL,
      WAERS TYPE ZGTMM_CV_GET_TAX_INVOICE-WAERS,

      F_COL TYPE LVC_T_SCOL,
    END OF TY_TAX.


*----------------------------------------------------------------------*
* GLOBAL VARIABLE
*----------------------------------------------------------------------*
* => GV + '_' XX.XXX
*----------------------------------------------------------------------*
DATA :
  GV_OKCODE       TYPE SY-UCOMM,
  GV_OKCODE_SAVE  TYPE SY-UCOMM,
  GV_OKCODE_SAVE2 TYPE SY-UCOMM,
  GV_ANSWER,
  GV_EDIT,
  GV_EXIT,
  GV_NEW,
  GV_ERR,
  GV_MODE.

DATA :
  GV_EKGRP  TYPE EKGRP,
  GV_BUDAT TYPE EKKO-AEDAT, "전기일
  GV_BDATE TYPE EKKO-AEDAT, "지급기산일
  GV_LIFNR    TYPE LIFNR,
  GV_LIFNR_N    TYPE NAME1,
  GV_TARGET_PRICE TYPE ZGTMM_CV_GET_TARGET_IV_H-TARGET_PRICE,
  GV_TPRICE_DISP(32) TYPE C,
  GV_TAXPRICE TYPE  ZGTMM_CV_GET_TARGET_IV_H-TAXPRICE,
  GV_XPRICE_DISP(32) TYPE C,
  GV_WRBTR    TYPE  ZGTMM_CV_GET_TARGET_IV_H2-WRBTR,
  GV_WRBTR_DISP(32) TYPE C,
  GV_RETURN TYPE C,
  GV_WAERS    TYPE WAERS,
  GV_TWAERS  TYPE WAERS,
  GV_XWAERS  TYPE WAERS,
  GV_EXRATE   TYPE  ZGTMM_CV_GET_TARGET_IV_H2-EXRATE,
  GV_QUES(35) TYPE C,
  GV_INFO(35) TYPE C,
  GV_REASON TYPE UF05A-STGRD,
  GV_TEXT      TYPE SO_OBJ_DES,
  GV_XRECH   TYPE RBKP-XRECH,
  GV_ZTERM   TYPE ZTERM, "지급조건

  GV_TOTAL TYPE ZGTMM_CV_GET_AP_CLEARING-RMWWR,
  GV_SPRICE TYPE ZGTMM_CV_GET_AP_CLEARING-SPRICE,
  GV_WMWST TYPE ZGTMM_CV_GET_AP_CLEARING-WMWST1,
  GV_TAXNO TYPE ZGTMM_CV_GET_TAX_INVOICE-INV_SEQ,
  GV_TARGET_PRICE2 TYPE ZGTMM_CV_GET_TARGET_IV_H-TARGET_PRICE,
  GV_TPRICE_DISP2(32) TYPE C,
  GV_TWAERS2 TYPE WAERS,
  GV_TAXPRICE2 TYPE  ZGTMM_CV_GET_TARGET_IV_H-TAXPRICE,
  GV_XPRICE_DISP2(32) TYPE C,
  GV_XWAERS2 TYPE WAERS,
  GV_WRBTR2  TYPE  ZGTMM_CV_GET_TARGET_IV_H2-WRBTR,
  GV_WRBTR_DISP2(32) TYPE C,
  GV_WAERS2 TYPE WAERS,
  GV_DATE TYPE ZGTMM_CV_GET_TAX_INVOICE-ISSUE_DATE,
  GV_PDATE TYPE ZGTMM_CV_GET_TAX_INVOICE-ISSUE_DT.


*----------------------------------------------------------------------*
* GLOBAL STRUCTURE
*----------------------------------------------------------------------*
* => GS + '_' XX.XXX
*----------------------------------------------------------------------*
DATA : BEGIN OF GS_LIST,
         CHECK,
         STATUS     TYPE ICON-NAME, "상태(아이콘)

         WERKS      TYPE ZGTMM_CV_GET_TARGET_IV_H-WERKS,
         WERKS_N  TYPE ZGTMM_CV_GET_TARGET_IV_H-WERKS_N,
         LIFNR         TYPE ZGTMM_CV_GET_TARGET_IV_H-LIFNR,
         LIFNR_N    TYPE ZGTMM_CV_GET_TARGET_IV_H-LIFNR_N,
         BUKRS      TYPE ZGTMM_CV_GET_TARGET_IV_H-BUKRS,
         BUKRS_N  TYPE ZGTMM_CV_GET_TARGET_IV_H-BUKRS_N,
         EKORG      TYPE ZGTMM_CV_GET_TARGET_IV_H-EKORG,
         EKORG_N  TYPE ZGTMM_CV_GET_TARGET_IV_H-EKORG_N,
         SPMON     TYPE ZGTMM_CV_GET_TARGET_IV_H-SPMON,
         EKGRP      TYPE ZGTMM_CV_GET_TARGET_IV_H-EKGRP,
         EKGRP_N  TYPE ZGTMM_CV_GET_TARGET_IV_H-EKGRP_N,
         XRECH     TYPE ZGTMM_CV_GET_TARGET_IV_H-XRECH ,
         XRECH_N     TYPE ZGTMM_CV_GET_TARGET_IV_H-XRECH_N ,
         TARGET_PRICE TYPE  ZGTMM_CV_GET_TARGET_IV_H-TARGET_PRICE,
         TAXPRICE TYPE  ZGTMM_CV_GET_TARGET_IV_H-TAXPRICE,
         ETIV_waers TYPE  ZGTMM_CV_GET_TARGET_IV_H-ETIV_waers,
         WRBTR    TYPE  ZGTMM_CV_GET_TARGET_IV_H2-WRBTR,
         EXRATE   TYPE  ZGTMM_CV_GET_TARGET_IV_H2-EXRATE,

         MESSAGE TYPE BAPIRET2-MESSAGE,
         STYLE TYPE LVC_T_STYL,
         F_COL TYPE LVC_T_SCOL,
END OF GS_LIST.

DATA : BEGIN OF GS_ITEM.
DATA : CHECK .
INCLUDE TYPE ZGTMM_CV_GET_TARGET_IV.
DATA : STYLE TYPE LVC_T_STYL,
           F_COL TYPE LVC_T_SCOL,
       END OF GS_ITEM.

DATA : BEGIN OF GS_DISP.
DATA : CHECK,
       STATUS      TYPE ICON-NAME, "상태(아이콘)
       REQ         TYPE ICON-NAME,  "지급요청
       AP_STATUS_N TYPE ZGTMM_CV_GET_AP_CLEARING-AP_STATUS_N,
       TIMESTAMP   TYPE    ZGTMM_CV_GET_AP_CLEARING-TIMESTAMP,
       CLEAR       TYPE ICON-NAME,  "지급
       BUKRS       TYPE    ZGTMM_CV_GET_AP_CLEARING-BUKRS,
       BUTXT       TYPE      ZGTMM_CV_GET_AP_CLEARING-BUTXT,
       BELNR       TYPE      ZGTMM_CV_GET_AP_CLEARING-BELNR,
       BLART       TYPE        ZGTMM_CV_GET_AP_CLEARING-BLART,
       GJAHR       TYPE        ZGTMM_CV_GET_AP_CLEARING-GJAHR,
       BUDAT       TYPE    ZGTMM_CV_GET_AP_CLEARING-BUDAT,
       CPUDT       TYPE    ZGTMM_CV_GET_AP_CLEARING-CPUDT,
       CPUTM       TYPE      ZGTMM_CV_GET_AP_CLEARING-CPUTM,
       USNAM       TYPE    ZGTMM_CV_GET_AP_CLEARING-USNAM,
       VGART       TYPE    ZGTMM_CV_GET_AP_CLEARING-VGART,
       XRECH       TYPE    ZGTMM_CV_GET_AP_CLEARING-XRECH,
       XRECH_N       TYPE    ZGTMM_CV_GET_AP_CLEARING-XRECH_N,
       WERKS       TYPE    ZGTMM_CV_GET_AP_CLEARING-WERKS,
       LIFNR       TYPE  ZGTMM_CV_GET_AP_CLEARING-LIFNR,
       LIFNR_N     TYPE      ZGTMM_CV_GET_AP_CLEARING-LIFNR_N,
       WAERS       TYPE      ZGTMM_CV_GET_AP_CLEARING-WAERS,
       KURSF       TYPE        ZGTMM_CV_GET_AP_CLEARING-KURSF,
       RMWWR       TYPE    ZGTMM_CV_GET_AP_CLEARING-RMWWR,
       SPRICE      TYPE    ZGTMM_CV_GET_AP_CLEARING-SPRICE,
       WMWST1      TYPE    ZGTMM_CV_GET_AP_CLEARING-WMWST1,
       MWSKZ1      TYPE    ZGTMM_CV_GET_AP_CLEARING-MWSKZ1,
       BKTXT       TYPE    ZGTMM_CV_GET_AP_CLEARING-BKTXT,
       SGTXT       TYPE    ZGTMM_CV_GET_AP_CLEARING-SGTXT,
       ZFBDT       TYPE    ZGTMM_CV_GET_AP_CLEARING-ZFBDT,
       ZBD1T       TYPE  ZGTMM_CV_GET_AP_CLEARING-ZBD1T,
       EXPDATE     TYPE  ZGTMM_CV_GET_AP_CLEARING-EXPDATE,
       GJAHR_BKPF  TYPE      ZGTMM_CV_GET_AP_CLEARING-GJAHR_BKPF,
       BELNR_BKPF  TYPE    ZGTMM_CV_GET_AP_CLEARING-BELNR_BKPF,
       ZTERM       TYPE    ZGTMM_CV_GET_AP_CLEARING-ZTERM,
       ZLSPR       TYPE  ZGTMM_CV_GET_AP_CLEARING-ZLSPR,
       AP_BELNR    TYPE        ZGTMM_CV_GET_AP_CLEARING-AP_BELNR,
       APPID       TYPE ZGTMM_CV_GET_AP_CLEARING-APPID,
       LEGACYID    TYPE        ZGTMM_CV_GET_AP_CLEARING-LEGACYID,
       AP_STATUS   TYPE        ZGTMM_CV_GET_AP_CLEARING-AP_STATUS,
       REQPAY      TYPE    ZGTMM_CV_GET_AP_CLEARING-REQPAY,
       CL_BUDAT    TYPE    ZGTMM_CV_GET_AP_CLEARING-CL_BUDAT,
       CL_BLDAT    TYPE        ZGTMM_CV_GET_AP_CLEARING-CL_BLDAT,
       CL_CPUDT    TYPE      ZGTMM_CV_GET_AP_CLEARING-CL_CPUDT,
       CL_AUGDT    TYPE      ZGTMM_CV_GET_AP_CLEARING-CL_AUGDT,
       CL_AUGBL    TYPE    ZGTMM_CV_GET_AP_CLEARING-CL_AUGBL,
       CLEARING    TYPE    ZGTMM_CV_GET_AP_CLEARING-CLEARING,
       MESSAGE     TYPE BAPIRET2-MESSAGE,
       STYLE           TYPE LVC_T_STYL,
       F_COL TYPE LVC_T_SCOL,

       END OF GS_DISP.

DATA : BEGIN OF GS_DISP_IT.
INCLUDE TYPE ZGTMM_CV_GET_AP_RSEG.
DATA : STYLE TYPE LVC_T_STYL,
           F_COL TYPE LVC_T_SCOL,
       END OF GS_DISP_IT.

DATA : "GS_DISP_IT TYPE ZGTMM_CV_GET_AP_RSEG,
           GS_TAX     TYPE TY_TAX.
DATA : GS_RETURN LIKE BAPIRET2.
DATA : GS_VARIANT LIKE DISVARIANT.

*----------------------------------------------------------------------*
* GLOBAL INTERNAL TABLE                                                *
*----------------------------------------------------------------------*
* => GT_ + XXX...XX                                                    *
*----------------------------------------------------------------------*
DATA : GT_LIST   LIKE TABLE OF GS_LIST,
           GT_ITEM LIKE TABLE OF GS_ITEM,
           GT_ITEM_BASE LIKE TABLE OF GS_ITEM,
           GT_DISP LIKE TABLE OF GS_DISP,
           GT_DISP_IT LIKE TABLE OF GS_DISP_IT,
           GT_DISP_BASE LIKE TABLE OF GS_DISP_IT,

          GT_INFO   TYPE TABLE OF ZGTMM_CV_GET_INFOPRICE,
          GT_TAX    TYPE TABLE OF TY_TAX.

DATA : GT_RETURN LIKE TABLE OF BAPIRET2.

DATA : GT_MTXT TYPE BCSY_TEXT,
           GS_MTXT TYPE SOLI.

DATA : GT_ECOMM  TYPE STANDARD TABLE OF SY-UCOMM.

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
  GC_Q(1)  VALUE 'Q',
  GC_R(1)  VALUE 'R',
  GC_S(1)  VALUE 'S',
  GC_T(1)  VALUE 'T',
  GC_X(1)  VALUE 'X',
  GC_1(1)  VALUE '1',
  GC_BT(2) VALUE 'BT',
  GC_EQ(2) VALUE 'EQ',
  GC_CL(2) VALUE 'CL',
  GC_PR(2) VALUE 'PR',
  GC_MM(2) VALUE 'MM'.

CONSTANTS :
  GC_KRW(3)       VALUE 'KRW',
  GC_KSRM(4)      VALUE 'KSRM',
  GC_0820(4)        VALUE '0820',
  GC_TAXKR(5)     VALUE 'TAXKR',
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

  PARAMETERS : P_BUKRS TYPE T001-BUKRS OBLIGATORY, "       회사코드
               P_EKORG TYPE T024E-EKORG OBLIGATORY, "구매조직
               P_WERKS TYPE MARC-WERKS OBLIGATORY MODIF ID MD1.  "플랜트

  SELECT-OPTIONS : S_MONTH FOR PGPL-SPMON MODIF ID MOT, "플랜트
                                S_EKGRP FOR MARC-EKGRP MODIF ID MOT,  "구매그룹
                                S_LIFNR   FOR EKKO-LIFNR MODIF ID MOT,    "공급업체
                                S_USNAM FOR RBKP-USNAM MODIF ID CRE. "판매오더

SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-002.
  SELECTION-SCREEN BEGIN OF LINE.
*송장처리
    PARAMETERS P_INV RADIOBUTTON GROUP RB1 DEFAULT 'X' USER-COMMAND UC01.
    SELECTION-SCREEN COMMENT (15) TEXT-C01 FOR FIELD P_INV.
*처리 결과 조회 및 지급 요청
    PARAMETERS P_DIS RADIOBUTTON GROUP RB1.
    SELECTION-SCREEN COMMENT (15) TEXT-C02 FOR FIELD P_DIS.
  SELECTION-SCREEN END OF LINE.
*지급요청 건 제외 (P_DIS = GC_X인 경우에만 노출)
    PARAMETERS P_EXD AS CHECKBOX MODIF ID EXD.
SELECTION-SCREEN END OF BLOCK B2.

  SELECTION-SCREEN BEGIN OF BLOCK B3 WITH FRAME TITLE TEXT-004.
    SELECTION-SCREEN BEGIN OF LINE.
*업체 별 조회
      PARAMETERS  P_LIF RADIOBUTTON GROUP RB2 DEFAULT 'X'
      USER-COMMAND UC02 MODIF ID DIS.
      SELECTION-SCREEN COMMENT (15) TEXT-C03 FOR FIELD P_LIF MODIF ID DIS.
*구매 그룹 레벨 조회
      PARAMETERS  P_EKG RADIOBUTTON GROUP RB2  MODIF ID DIS.
      SELECTION-SCREEN COMMENT (15) TEXT-C04 FOR FIELD P_EKG MODIF ID DIS.
    SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN END OF BLOCK B3.
