*&---------------------------------------------------------------------*
*& Include ZGTMMR4200TOP
*&---------------------------------------------------------------------*

TABLES : EKKO, EKPO.


DATA : GV_CDATE LIKE SY-DATLO.

DATA : GT_RTAB LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

DATA : GV_CNT TYPE I.

DATA : BEGIN OF GT_LIST OCCURS 0,
         EBELN         TYPE ZGTMM_CV_LTTIMECHECK-EBELN,
         EBELP         TYPE ZGTMM_CV_LTTIMECHECK-EBELP,
         BUKRS         TYPE ZGTMM_CV_LTTIMECHECK-BUKRS,
         BUKRS_N       TYPE ZGTMM_CV_LTTIMECHECK-BUKRS_N,
         EKORG         TYPE ZGTMM_CV_LTTIMECHECK-EKORG,
         EKORG_N       TYPE ZGTMM_CV_LTTIMECHECK-EKORG_N,
         WERKS         TYPE ZGTMM_CV_LTTIMECHECK-WERKS,
         WERKS_N       TYPE ZGTMM_CV_LTTIMECHECK-WERKS_N,
         LIFNR         TYPE ZGTMM_CV_LTTIMECHECK-LIFNR,
         LIFNR_N       TYPE ZGTMM_CV_LTTIMECHECK-LIFNR_N,
         MATNR         TYPE ZGTMM_CV_LTTIMECHECK-MATNR,
         TXZ01         TYPE ZGTMM_CV_LTTIMECHECK-TXZ01,
         MENGE         TYPE ZGTMM_CV_LTTIMECHECK-MENGE,
         MEINS         TYPE ZGTMM_CV_LTTIMECHECK-MEINS,
         BANFN         TYPE ZGTMM_CV_LTTIMECHECK-BANFN,
         BNFPO         TYPE ZGTMM_CV_LTTIMECHECK-BNFPO,
         PRDATE_C      TYPE ZGTMM_CV_LTTIMECHECK-PRDATE_C,
         PRDATE_R      TYPE ZGTMM_CV_LTTIMECHECK-PRDATE_R,
         PODATE_C      TYPE ZGTMM_CV_LTTIMECHECK-PODATE_C,
         PODATE_R      TYPE ZGTMM_CV_LTTIMECHECK-PODATE_R,
         INFO_LT       TYPE ZGTMM_CV_LTTIMECHECK-INFO_LT,
         PRDATE_LT     TYPE ZGTMM_CV_LTTIMECHECK-PRDATE_LT,
         PODATE_LT     TYPE ZGTMM_CV_LTTIMECHECK-PODATE_LT,
         POLTCHECK     TYPE ZGTMM_CV_LTTIMECHECK-POLTCHECK,
         GRDATE_F      TYPE ZGTMM_CV_LTTIMECHECK-GRDATE_F,
         LT_F          TYPE ZGTMM_CV_LTTIMECHECK-LT_F,
         FIRSTGR_CHECK TYPE ZGTMM_CV_LTTIMECHECK-FIRSTGR_CHECK,
         GRDATA_L      TYPE ZGTMM_CV_LTTIMECHECK-GRDATA_L,
         LT_L          TYPE ZGTMM_CV_LTTIMECHECK-LT_L,
         LASTGR_CHECK  TYPE ZGTMM_CV_LTTIMECHECK-LASTGR_CHECK,

         COLOR         TYPE LVC_T_SCOL,
       END   OF GT_LIST.

DATA : GV_OKCODE LIKE SY-UCOMM.


CONSTANTS : GC_A(1)     VALUE 'A',
            GC_D(1)     VALUE 'D',
            GC_E(1)     VALUE 'E',
            GC_I(1)     VALUE 'I',
            GC_S(1)     VALUE 'S',
            GC_X(1)     VALUE 'X',
            GC_BT(2)    VALUE 'BT',
            GC_DIFF(4)  VALUE 'DIFF',
            GC_COLOR(5) VALUE 'COLOR'.


DEFINE _CALC_DATE.
  CLEAR : GV_CDATE.
  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      DATE      = &1
      DAYS      = &2
      MONTHS    = &3
      SIGNUM    = &4
      YEARS     = &5
    IMPORTING
      CALC_DATE = GV_CDATE.
END-OF-DEFINITION.


*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
"향후 권한 연동하여 User별 Defalut 값 관리시 Display 필드로 변경(BUKRS/EKORG)
SELECTION-SCREEN BEGIN OF BLOCK BK1 WITH FRAME TITLE TEXT-S01.
  PARAMETERS     : P_BUKRS LIKE EKKO-BUKRS OBLIGATORY, "회사코드
                   P_EKORG LIKE EKKO-EKORG OBLIGATORY. "구매조직
  SELECT-OPTIONS : S_WERKS  FOR EKPO-WERKS,            "플랜트
                   S_LIFNR  FOR EKKO-LIFNR,            "공급업체
                   S_MATNR  FOR EKPO-MATNR,            "자재코드
                   S_AEDAT  FOR EKKO-AEDAT OBLIGATORY  "구매오더생성일
                                         NO-EXTENSION.
SELECTION-SCREEN END   OF BLOCK BK1.
