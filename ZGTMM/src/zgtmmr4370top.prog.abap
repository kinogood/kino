*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR4370TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* TYPE POOLS                                                           *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*  TABLES                                                              *
*----------------------------------------------------------------------*
TABLES :
  T001W, EKPO,
  SSCRFIELDS,
  VBAK,ZGTMMT4402.

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
*=> GTY + _ + XXXXX.XXX
*----------------------------------------------------------------------*
 TYPES :
*   BEGIN OF TY_HEAD,
*     STATUS TYPE ICON_NAME, "상태
*
*     BUKRS  TYPE ZGTMM_CV_GET_OEM_DELIVERY_INFO-BUKRS   ,
*     EBELN  TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-EBELN,
*     EBELP  TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-EBELP,
*     AEDAT  TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-AEDAT,
*     EINDT   TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-EINDT,
*     WERKS TYPE ZGTMM_CV_GET_OEM_DELIVERY_INFO-WERKS   ,
*     LIFNR   TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-LIFNR,
*     LIFNR_N TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-LIFNR_N,
*     VBELN TYPE ZGTMM_CV_GET_OEM_DELIVERY_INFO-VBELN   ,
*     POSNR TYPE ZGTMM_CV_GET_OEM_DELIVERY_INFO-POSNR    ,
*     KUNNR TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-KUNNR   ,
*     KUNNR_N TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-KUNNR_N   ,
*     VKBUR TYPE ZGTMM_CV_GET_OEM_DELIVERY_INFO-VKBUR   ,
*     VKBUR_N TYPE ZGTMM_CV_GET_OEM_DELIVERY_INFO-VKBUR_N ,
*     VKGRP TYPE ZGTMM_CV_GET_OEM_DELIVERY_INFO-VKGRP    ,
*     VKGRP_N TYPE ZGTMM_CV_GET_OEM_DELIVERY_INFO-VKGRP_N   ,
*     MATNR   TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-MATNR,
*     MAKTX TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-MAKTX,
*     COLOR TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-COLOR,
*     MENGE TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-MENGE,
*     MEINS TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-MEINS,
*     LENGTH TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-LENGTH,
*     DRQTY TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-DRQTY,
*     DR_MEINS TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-DR_MEINS,
*     GR_QTY_M TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-GR_QTY_M,
*     GR_MEINS_M TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-GR_MEINS_M,
*     GR_QTY_DR TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-GR_QTY_DR,
*     REQDATE TYPE ZGTMM_CV_GET_OEM_DELIVERY_INFO-REQDATE   ,
*     QI_REQ_QTY TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-QI_REQ_QTY,
*     QI_RESULT_QTY TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-QI_RESULT_QTY,
*     ELIKZ TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-ELIKZ,
*     QI_CLOSE TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-QI_CLOSE,
*     QCREQDATE type ZGTMM_CV_GET_OEM_PO_DATA_INFO-QCREQDATE,
*
*   END OF TY_HEAD,

   BEGIN OF TY_ITEM,
     STATUS TYPE ICON_NAME, "상태

     BUKRS  TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-BUKRS   ,
     EBELN  TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-EBELN,
     EBELP  TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-EBELP,
     AEDAT  TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-AEDAT,
     EINDT   TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-EINDT,
     WERKS TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-WERKS   ,
     LIFNR   TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-LIFNR,
     LIFNR_N TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-LIFNR_N,
     VBELN TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-VBELN   ,
     POSNR TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-POSNR    ,
     KUNNR TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-KUNNR   ,
     KUNNR_N TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-KUNNR_N   ,
     VKBUR TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-VKBUR   ,
     VKBUR_N TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-VKBUR_N ,
     VKGRP TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-VKGRP    ,
     VKGRP_N TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-VKGRP_N   ,
     MATNR   TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-MATNR,
     MAKTX TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-MAKTX,
     COLOR TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-COLOR,
     MENGE TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-MENGE,
     MEINS TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-MEINS,
     LENGTH TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-LENGTH,
     DRQTY TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-DRQTY,
     INSPECTION TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-INSPECTION,
     DR_MEINS TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-DR_MEINS,
     GR_QTY_M TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-GR_QTY_M,
     GR_MEINS_M TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-GR_MEINS_M,
     GR_QTY_DR TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-GR_QTY_DR,
     REQDATE TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-REQDATE   ,
     QI_REQ_QTY TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-QI_REQ_QTY,
     QI_RESULT_QTY TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-QI_RESULT_QTY,
     ELIKZ TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-ELIKZ,
     QI_CLOSE TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-QI_CLOSE,

     ZINSP_NO TYPE ZGTMMT4402-ZINSP_NO,   "검사요청번호
     ZINSP_QTY TYPE ZGTMMT4402-ZINSP_QTY,   "검사요청수량(DR)
     QCMEINS TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-QCMEINS,
     ZINSP_DATE TYPE ZGTMMT4402-ZINSP_DATE,  "검사요청일
     ZINSPTYPE  TYPE ZGTMMT4402-ZINSPTYPE,    "검사방법
     ZINSPTYPE_N(20), "검사방법명
     ZINSPDATE   TYPE SY-DATUM, "ZGTMMT4402-ZINSPDATE  ,    "출장검사예정일
     ZINSP_PERNO TYPE ZGTMMT4402-ZINSP_PERNO, "출장담당자사번
     ZINSP_NAME  TYPE ZGTMMT4402-ZINSP_NAME  , "출장담당자명
     ZINSPRES   TYPE ZGTMMT4402-ZINSPRES,  "검사결과
     ZINSPRES_N(10)  , "검사결과명
     ZINSP_CERTI  TYPE ZGTMMT4402-ZINSP_CERTI  , "성적서경로
     QCREQDATE TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-QCREQDATE,
     QCREQDATELOCAL TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-QCREQDATELOCAL,

     STYLE  TYPE LVC_T_STYL,
   END OF TY_ITEM,

   BEGIN OF TY_LIST,

     DELNO TYPE ZGTMM_CV_GET_MAT_INSPCERT-DELNO,
     DELITEM TYPE ZGTMM_CV_GET_MAT_INSPCERT-DELITEM,
     LIFNR TYPE ZGTMM_CV_GET_MAT_INSPCERT-LIFNR,
     LIFNR_N TYPE ZGTMM_CV_GET_MAT_INSPCERT-LIFNR_N,
     BUKRS  TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-BUKRS,
     WERKS TYPE ZGTMM_CV_GET_MAT_INSPCERT-WERKS,
     EBELN  TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-EBELN,
     EBELP  TYPE ZGTMM_CV_GET_OEM_PO_DATA_INFO-EBELP,
     AEDAT  TYPE ZGTMM_CV_GET_MAT_INSPCERT-AEDAT,
     MATNR TYPE ZGTMM_CV_GET_MAT_INSPCERT-MATNR,
     MAKTX TYPE ZGTMM_CV_GET_MAT_INSPCERT-MAKTX,
     LGORT TYPE ZGTMM_CV_GET_MAT_INSPCERT-LGORT,
     LGORT_N TYPE ZGTMM_CV_GET_MAT_INSPCERT-LGORT_N,
     MENGE TYPE ZGTMM_CV_GET_MAT_INSPCERT-MENGE,
     MEINS TYPE ZGTMM_CV_GET_MAT_INSPCERT-MEINS,
     BUDAT TYPE ZGTMM_CV_GET_MAT_INSPCERT-BUDAT,
     LICHA TYPE ZGTMM_CV_GET_MAT_INSPCERT-LICHA,
     HSDAT TYPE ZGTMM_CV_GET_MAT_INSPCERT-HSDAT,
     DOC_URL TYPE ZGTMM_CV_GET_MAT_INSPCERT-DOC_URL,

   END OF TY_LIST.

*----------------------------------------------------------------------*
* GLOBAL VARIABLE
*----------------------------------------------------------------------*
* => GV + '_' XX.XXX
*----------------------------------------------------------------------*
DATA :
  GV_OKCODE          TYPE SY-UCOMM,
  GV_OKCODE_SAVE  TYPE SY-UCOMM,
  GV_OKCODE_SAVE2 TYPE SY-UCOMM,
  GV_UCOMM            TYPE SY-UCOMM,
  GV_BUDAT   TYPE ZGTMMT4402-ZINSPDATE,
  GV_WAY      TYPE ZGTMMT4402-ZINSPTYPE,
  GV_RESULT TYPE ZGTMMT4402-ZINSPRES,
  GV_PERNR   TYPE ZGTMMT4402-ZINSP_PERNO,
  GV_ANSWER,
  GV_BOTTOM,
  GV_NOTOOL,
  GV_EDIT,
  GV_ERR.

*----------------------------------------------------------------------*
* GLOBAL STRUCTURE
*----------------------------------------------------------------------*
* => GS + '_' XX.XXX
*----------------------------------------------------------------------*
DATA :
*           GS_HEAD TYPE TY_HEAD,
           GS_ITEM  TYPE TY_ITEM,
           GS_LIST   TYPE TY_LIST.

DATA : GS_T001       LIKE T001W,
           GS_RETURN LIKE BAPIRET2.

*----------------------------------------------------------------------*
* GLOBAL INTERNAL TABLE                                                *
*----------------------------------------------------------------------*
* => GT_ + XXX...XX                                                    *
*----------------------------------------------------------------------*
DATA : GT_LIST       LIKE TABLE OF GS_LIST,
*           GT_HEAD     LIKE TABLE OF GS_HEAD,
           GT_ITEM      LIKE TABLE OF GS_ITEM.

DATA : GT_RETURN LIKE TABLE OF BAPIRET2,
           GT_RTAB     LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

DATA: GT_ZINSPTYPE TYPE TABLE OF DD07V,
          GT_DD07T  TYPE TABLE OF DD07V.

*"F4 HELP_영업그룹
*DATA : BEGIN OF GT_VKGRP OCCURS 0,
*         VKBUR LIKE TVBVK-VKBUR,
*         VKGRP LIKE TVBVK-VKGRP,
*         BEZEI  LIKE TVGRT-BEZEI,
*       END OF GT_VKGRP.
*
*"사업장 TEXT.
*DATA : BEGIN OF GT_BRANCH OCCURS 0,
*         BUPLA TYPE J_1BBRANCH-BRANCH,
*         NAME  TYPE J_1BBRANCH-NAME,
*       END OF GT_BRANCH.
*
*"계정코드
*DATA : BEGIN OF GT_ACCT OCCURS 0,
*         SAKNR  LIKE ZTRTF271-SAKNR,
*         TXT50  LIKE ZTRTF271-TXT50,
*         SHKZG  LIKE ZTRTF271-SHKZG,
*         LIMIT  LIKE ZTRTF271-LIMIT,
*         LIMIT2 LIKE ZTRTF271-LIMIT2,
*       END OF GT_ACCT.


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
            GC_A   VALUE 'A',
            GC_B   VALUE 'B',
            GC_C   VALUE 'C',
            GC_D   VALUE 'D',
            GC_E   VALUE 'E',
            GC_I     VALUE 'I',
            GC_J     VALUE 'J',
            GC_M    VALUE 'M',
            GC_Q    VALUE 'Q',
            GC_R    VALUE 'R',
            GC_S     VALUE 'S',
            GC_X     VALUE 'X',
            GC_1     VALUE '1',
            GC_2     VALUE '2',
            GC_3     VALUE '3',

            GC_BT(2)   VALUE 'BT',
            GC_EQ(2)   VALUE 'EQ',
            GC_MM(2)  VALUE 'MM',

            GC_100(3) VALUE '100',
            GC_300(3) VALUE '300',
            GC_400(3) VALUE '400',
            GC_0800(4) VALUE '0800',

            GC_WAERS LIKE BKPF-WAERS  VALUE 'KRW'.  "통화키

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
  PARAMETERS :
   P_BUKRS TYPE  BUKRS OBLIGATORY,
   P_WERKS TYPE T001W-WERKS OBLIGATORY. "플랜트

  SELECT-OPTIONS :
   S_ERDAT FOR ZGTMMT4402-ERDAT MODIF ID OEM,
   S_AEDAT FOR VBAK-ERDAT OBLIGATORY,  "구매오더생성일
   S_EINDT  FOR VBAK-ERDAT,                      "납품예정일
   S_LIFNR   FOR T001W-LIFNR,
   S_EBELN FOR EKPO-EBELN,
   S_KUNNR FOR VBAK-KUNNR MODIF ID OEM,
   S_VBELN FOR VBAK-VBELN MODIF ID OEM,
   S_MATNR FOR EKPO-MATNR.  "

SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-003. " 처리Option
  SELECTION-SCREEN BEGIN OF LINE.
*OEM검사관리
    PARAMETERS RB_OEM RADIOBUTTON GROUP GR01  USER-COMMAND UC01 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (15) TEXT-R01 FOR FIELD RB_OEM.
*자재성적서DOWNLOAD
    PARAMETERS RB_DOWN RADIOBUTTON GROUP GR01.
    SELECTION-SCREEN COMMENT (15) TEXT-R02 FOR FIELD RB_DOWN.

  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK B2.

SELECTION-SCREEN BEGIN OF BLOCK B3 WITH FRAME TITLE TEXT-002. "조회Option
  PARAMETERS :
   P_CHK AS CHECKBOX MODIF ID OEM DEFAULT 'X'. "검사완료데이터제외
SELECTION-SCREEN END OF BLOCK B3.

*SELECTION-SCREEN FUNCTION KEY 1.
