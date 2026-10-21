*&---------------------------------------------------------------------*
*& Include          ZGTPPI2030TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES                                                               *
*----------------------------------------------------------------------*
TABLES: MARC,
        MARD,
        VBAK,
        VBAP,
        VBEP,
        ZGTPPT2170,
        ZGTPPT2180,
        ZGTPPT2190,
        ZGTPPT2191,
        ZGTPPT2200,
        ZGTPPT2210,
        ZGTPPT2220,
        ZPPT0107,
        ZLET0400,
        SSCRFIELDS. " 선택화면의 필드.

*----------------------------------------------------------------------*
* CONSTANTS                                                            *
*----------------------------------------------------------------------*
CONSTANTS: BEGIN OF GC_FCODE,
             ONLI   TYPE SY-UCOMM VALUE 'ONLI',
             BACK   TYPE SY-UCOMM VALUE 'BACK',
             EXIT   TYPE SY-UCOMM VALUE 'EXIT',
             CANCEL TYPE SY-UCOMM VALUE 'CANCEL',
             SAVE   TYPE SY-UCOMM VALUE 'SAVE',
             TAB1   TYPE SY-UCOMM VALUE 'TAB1',
             TAB2   TYPE SY-UCOMM VALUE 'TAB2',
             SEND   TYPE SY-UCOMM VALUE 'SEND',
             RESEND TYPE SY-UCOMM VALUE 'RESEND',
             DETAIL TYPE SY-UCOMM VALUE 'DETAIL',
           END OF GC_FCODE.

*----------------------------------------------------------------------*
* CONTROLS                                                             *
*----------------------------------------------------------------------*
CONTROLS TABSTRIP TYPE TABSTRIP.

*----------------------------------------------------------------------*
* TYPES                                                                *
*----------------------------------------------------------------------*
TYPES: BEGIN OF TY_S_ITEM,
         ZIFKEY        TYPE ZGTPPT2200-ZIFKEY,
         ZCUT_ORD_NO   TYPE ZGTPPT2190-ZCUT_ORD_NO,
         ZCUT_ORD_ITEM TYPE ZGTPPT2190-ZCUT_ORD_ITEM,
         LOEKZ         TYPE ZGTPPT2210-LOEKZ,
         LGORT         TYPE ZGTPPT2180-LGORT,
         LGOBE         TYPE T001L-LGOBE,
         F_CHARG       TYPE ZGTPPT2180-F_CHARG,
         F_TAGNR       TYPE ZPPT0001-TAGNR,
         ZORD_TYPE     TYPE ZGTPPT2180-ZORD_TYPE,
         ZCUT_LEN      TYPE ZGTPPT2190-ZCUT_LEN,
         ZCUT_CNT      TYPE ZGTPPT2190-ZCUT_CNT,
         ZREW_YN       TYPE ZGTPPT2190-ZREW_YN,
         SOBKZ         TYPE ZGTPPT2190-SOBKZ,
         MULTI_YN      TYPE ZGTPPT2190-MULTI_YN,
         ORG_LENGTH    TYPE ZGTPPT2190-ORG_LENGTH,
         LABST3        TYPE ZGTPPT2190-LABST3,
       END OF TY_S_ITEM.

TYPES: TY_T_ITEM TYPE TABLE OF TY_S_ITEM WITH DEFAULT KEY
                                         WITH NON-UNIQUE SORTED KEY SKEY1 COMPONENTS ZCUT_ORD_NO ZCUT_ORD_ITEM
                                         WITH NON-UNIQUE SORTED KEY SKEY2 COMPONENTS ZIFKEY ZCUT_ORD_NO ZCUT_ORD_ITEM.

TYPES: BEGIN OF TY_S_BOM,
         ZIFKEY        TYPE ZGTPPT2200-ZIFKEY,
         ZCUT_ORD_NO   TYPE ZGTPPT2191-ZCUT_ORD_NO,
         ZCUT_ORD_ITEM TYPE ZGTPPT2191-ZCUT_ORD_ITEM,
         POSNR         TYPE ZGTPPT2191-POSNR,
         MATNR         TYPE ZGTPPT2191-MATNR,
         MAKTX         TYPE MAKT-MAKTX,
         BDMNG         TYPE ZGTPPT2191-BDMNG,
         MEINS         TYPE ZGTPPT2191-MEINS,
         LGORT         TYPE ZGTPPT2191-LGORT,
       END OF TY_S_BOM.

TYPES: TY_T_BOM TYPE TABLE OF TY_S_BOM WITH DEFAULT KEY
                                       WITH NON-UNIQUE SORTED KEY SKEY1 COMPONENTS ZCUT_ORD_NO ZCUT_ORD_ITEM
                                       WITH NON-UNIQUE SORTED KEY SKEY2 COMPONENTS ZIFKEY ZCUT_ORD_NO ZCUT_ORD_ITEM.

TYPES: BEGIN OF TY_S_HEADER,
         ZIFKEY       TYPE ZGTPPT2200-ZIFKEY,
         STATUS       TYPE CHAR10,
         ZSTAT        TYPE ZGTPPT2200-ZSTAT,
         ZMESSAGE     TYPE ZGTPPT2200-ZMESSAGE,
         ZSYSTEM_ID   TYPE ZGTPPT2200-ZSYSTEM_ID,
         SYSTX        TYPE CHAR40,
         ZCUT_ORD_NO  TYPE ZGTPPT2190-ZCUT_ORD_NO,
         CRDAT        TYPE ZGTPPT2190-CRDAT,  "// 절단오더생성일자
         WERKS        TYPE ZGTPPT2170-WERKS,
         LOEKZ        TYPE ZGTPPT2190-LOEKZ,
         ZASSIGN_TYPE TYPE ZGTPPT2170-ZASSIGN_TYPE,
         VBELN        TYPE ZGTPPT2170-VBELN,
         POSNR        TYPE ZGTPPT2170-POSNR,
         ETENR        TYPE ZGTPPT2170-ETENR,
         EDATU        TYPE ZGTPPT2170-EDATU,
         DRDAT        TYPE ZLET0400-DRDAT,    "// 출하요청일자
         WEMENG       TYPE ZGTPPT2170-WEMENG,
         VRKME        TYPE ZGTPPT2170-VRKME,
         WELENG       TYPE ZGTPPT2170-WELENG,
         WECNT        TYPE ZGTPPT2170-WECNT,
         MATNR        TYPE ZGTPPT2170-MATNR,
         MAKTX        TYPE MAKT-MAKTX,
         VKORG        TYPE ZGTPPT2170-VKORG,
         VKGRP        TYPE ZGTPPT2170-VKGRP,
         KDKG4        TYPE VBKD-KDKG4,
         ZZYUSCD      TYPE ZGTSDT1104-ZZYUSCD,
         IFDAT        TYPE ZGTPPT2200-IFDAT,
         IFTIM        TYPE ZGTPPT2200-IFTIM,
         IFNAM        TYPE ZGTPPT2200-IFNAM,
         SEL          TYPE ABAP_BOOL,
         ITEM         TYPE TY_T_ITEM,
         BOM          TYPE TY_T_BOM,
       END OF TY_S_HEADER.

TYPES: TY_T_HEADER TYPE TABLE OF TY_S_HEADER WITH DEFAULT KEY
                                             WITH NON-UNIQUE SORTED KEY SKEY1 COMPONENTS ZCUT_ORD_NO
                                             WITH NON-UNIQUE SORTED KEY SKEY2 COMPONENTS ZIFKEY ZCUT_ORD_NO.

TYPES: BEGIN OF TY_S_RESULT,
         SEL      TYPE SY-TABIX,
         TOTAL    TYPE SY-TABIX,
         SUCCESS  TYPE SY-TABIX,
         ERROR    TYPE SY-TABIX,
         INVALID  TYPE ABAP_BOOL,
         ZSTAT    TYPE ZO_RESULT,
         ZMESSAGE TYPE ZO_MESSAGE,
         SYS_MSG  TYPE CHAR255,
       END OF TY_S_RESULT.

*----------------------------------------------------------------------*
* DATA                                                                 *
*----------------------------------------------------------------------*
DATA GR_HEADER TYPE REF TO ZGTPP_CL_LIST.
DATA GR_ITEM   TYPE REF TO ZGTPP_CL_LIST.
DATA GR_BOM    TYPE REF TO ZGTPP_CL_LIST.

DATA GT_HEADER TYPE TY_T_HEADER.
DATA GT_ITEM   TYPE TY_T_ITEM.
DATA GT_BOM    TYPE TY_T_BOM.

DATA GT_ZGTPPT1010 TYPE TABLE OF ZGTPPT1010.
DATA GT_ZGTPPT2200 TYPE TABLE OF ZGTPPT2200.
DATA GT_ZGTPPT2210 TYPE TABLE OF ZGTPPT2210.
DATA GT_ZGTPPT2220 TYPE TABLE OF ZGTPPT2220.

DATA GT_ORDER_H   TYPE TABLE OF ZGTPPSIF0039.
DATA GT_ORDER_I   TYPE TABLE OF ZGTPPSIF0040.
DATA GT_ORDER_BOM TYPE TABLE OF ZGTPPSIF0041.

DATA GT_WERKS TYPE RANGE OF MARC-WERKS.
DATA GT_ZSTAT TYPE RANGE OF ZGTPPT2200-ZSTAT.

DATA GT_DDLB    TYPE VRM_VALUES.
DATA GV_SYSTX   TYPE CHAR40.

DATA GS_RESULT  TYPE TY_S_RESULT.

DATA GV_MODE    TYPE CHAR10.
DATA GT_EXCLUDE TYPE UI_FUNCTIONS.
DATA GV_DYNNR   TYPE SY-DYNNR.
DATA GV_SAVED   TYPE ABAP_BOOL.
DATA GV_OKCODE  TYPE SY-UCOMM.
DATA GV_TPAR1   TYPE SYST_MSGV.
