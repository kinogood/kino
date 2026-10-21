*&---------------------------------------------------------------------*
*& Include          ZGTSDR1220TOP
*&---------------------------------------------------------------------*
INCLUDE <ICON>.

TABLES :MARA,
        MARC,
        T134,
        MAKT,
        MVKE,
        VBAK,
        T001W,
        T179,
        T604,
        ZEDT1000,
        ZEDT0060,
*        ZEDT7040,
*        ZEDT7110,
        ZEDT7440,
        ZEDT7120.

**********************************************************************
*              ALV 데이타 선언
**********************************************************************
TYPE-POOLS:SLIS,CNDP,GFW.

CONSTANTS:
  GC_TOP_OF_PAGE   TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE',
  GC_USER_COMMAND  TYPE SLIS_FORMNAME VALUE 'USER_COMMAND',
  GC_PF_STATUS_SET TYPE SLIS_FORMNAME VALUE 'PF_STATUS_SET'.

DATA:G_FIELDCATALOG TYPE LVC_T_FCAT,
     G_FIELDCAT     TYPE LVC_S_FCAT,
     GT_EVENTS      TYPE SLIS_T_EVENT,
     G_STATUS_SET   TYPE SLIS_FORMNAME VALUE 'STATUS1',
     GT_FIELDCAT    TYPE SLIS_T_FIELDCAT_ALV,
     T_SORT         TYPE SLIS_T_SORTINFO_ALV.

DATA:GS_LAYOUT               TYPE SLIS_LAYOUT_ALV,
     G_REPID                 LIKE SY-REPID,
     GS_VARIANT              LIKE DISVARIANT,
     G_SAVE,
     G_EXIT_CAUSED_BY_USER_S TYPE SLIS_EXIT_BY_USER,
     G_EXIT_CAUSED_BY_CALLER.

DATA:GS_KEYINFO  TYPE SLIS_KEYINFO_ALV,
     GT_SP_GROUP TYPE SLIS_T_SP_GROUP_ALV.

DATA:G_BOXNAM         TYPE SLIS_FIELDNAME VALUE  'BOX',
     F2CODE           LIKE SY-UCOMM         VALUE  '&ETA',
     G_TABNAME_HEADER TYPE SLIS_TABNAME,
     G_TABNAME_ITEM   TYPE SLIS_TABNAME,
     G_DEFAULT(1)     TYPE C VALUE 'X',
     G_EXIT(1)        TYPE C,
     G_VARIANT        LIKE DISVARIANT,
     GS_SELFIELD      TYPE SLIS_SELFIELD,
     G_DYNPREAD       LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

DATA: GV_BATCH(1).

CONSTANTS:
  C_ICON_PARK TYPE ICO_AUGP      VALUE ICON_LED_RED,
  C_ICON_SP   TYPE ICO_AUGP      VALUE ICON_LED_YELLOW,
  C_ICON_NOM  TYPE ICO_AUGP      VALUE ICON_LED_GREEN,
  C_FAIL      TYPE CHAR10        VALUE '실 패',
  C_SUCC      TYPE CHAR10        VALUE '성 공',
  C_ZAL(3)    VALUE  'ZAL'.     "AL 포장재 그룹 (AL PJT)


DATA:BEGIN OF GMARC OCCURS 0 ,
       MATNR LIKE MARA-MATNR,
       WERKS LIKE MARC-WERKS,
       MAKTX LIKE MAKT-MAKTX,
       VBELN LIKE ZEDT0060-VBELN, "양산요청번호
       POSNR LIKE ZEDT0060-POSNR, "아이템
       SPART LIKE MARA-SPART,
       MTART LIKE MARA-MTART,
       MEINS LIKE MARA-MEINS,
       PSTAT LIKE MARC-PSTAT,     "유지보수상태
       DISMM LIKE MARC-DISMM,     "mrp 유형

*? Basic view Update시 총중량과 순중량은 동일한 값으로 Update처리

       BRGEW LIKE MARA-BRGEW, "총중량
       GEWEI LIKE MARA-GEWEI, "중량단위

       PRDHA LIKE MARA-PRDHA, "제품계층구조
       STAWN LIKE MARC-STAWN, "HS CODE

       DWERK LIKE MVKE-DWERK, "납품플랜트
       VKORG LIKE MVKE-VKORG, "영업조직
       VTWEG LIKE MVKE-VTWEG, "유통경로
       VRKME LIKE MVKE-VRKME, "판매단위
       AUMNG LIKE MVKE-AUMNG, "최소오더수량
       LFMNG LIKE MVKE-LFMNG, "최소납품수량
       SCMNG LIKE MVKE-SCMNG, "납품단위
       SCHME LIKE MVKE-SCHME, "납품단위의단위
       MVGR1 LIKE MVKE-MVGR1,                               "자재그룹1
       MVGR2 LIKE MVKE-MVGR2,                               "자재그룹1
       MVGR3 LIKE MVKE-MVGR3,                               "자재그룹1
     END OF GMARC.

DATA:BEGIN OF HMARA OCCURS 0 ,
       ICON   LIKE ICON-ID,
       MATNR  LIKE MARA-MATNR,
       WERKS  LIKE MARC-WERKS,
       MAKTX  LIKE MAKT-MAKTX,
       VBELN  LIKE ZEDT0060-VBELN, "양산요청번호
       POSNR  LIKE ZEDT0060-POSNR, "아이템
       SPART  LIKE MARA-SPART,
       MTART  LIKE MARA-MTART,
       MEINS  LIKE MARA-MEINS,
       MESSG  LIKE SY-MSGV1,
       MARK   TYPE CHAR1,
       EXPEND TYPE CHAR1,
     END OF HMARA.

DATA: PER     TYPE F,
      COUNT   TYPE F,
      COUNTER TYPE I.

DATA: LS_SEQNO LIKE ZSD0119T-SEQNO.


DATA: GV_MSGV1      LIKE SY-MSGV1.

"LOG
DATA: GT_ZGTSDT9030 TYPE TABLE OF ZGTSDT9030.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS: GC_VKORG_6000    TYPE VKORG   VALUE '6000',
           GC_SPART_10      TYPE SPART   VALUE '10',
           GC_SPART_23      TYPE SPART   VALUE '23',
           GC_SPART_31      TYPE SPART   VALUE '31',
           GC_SPART_41      TYPE SPART   VALUE '41',
           GC_SPART_43      TYPE SPART   VALUE '43',
           GC_SPART_90      TYPE SPART   VALUE '90',
           GC_WERKS_6500    TYPE WERKS_D VALUE '6500',
           GC_WERKS_6581    TYPE WERKS_D VALUE '6581',
           GC_WERKS_6591    TYPE WERKS_D VALUE '6591',
           GC_WERKS_6600    TYPE WERKS_D VALUE '6600',
           GC_WERKS_6691    TYPE WERKS_D VALUE '6691',
           GC_MTART_FERT    TYPE MTART   VALUE 'FERT',
           GC_MTART_MCHF    TYPE MTART   VALUE 'MCHF',
           GC_MTART_MCFE    TYPE MTART   VALUE 'MCFE',
           GC_MTART_MCHA    TYPE MTART   VALUE 'MCHA',
           GC_MTART_HAWA    TYPE MTART   VALUE 'HAWA',
           GC_MTART_ROH1    TYPE MTART   VALUE 'ROH1',
           GC_MTART_ROH2    TYPE MTART   VALUE 'ROH2',
           GC_MTART_MRM1    TYPE MTART   VALUE 'MRM1',
           GC_MTART_SCRP    TYPE MTART   VALUE 'SCRP'.
