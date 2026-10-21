*&---------------------------------------------------------------------*
*& Include          ZGTSDR2010TOP
*&---------------------------------------------------------------------*
TYPE-POOLS:ESP1,TUMLS,ICON,SLIS.

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES: SSCRFIELDS,
        LIKP,LIPS,VBAK,VBAP,VBPA,
        ZGTSDT9110,
        ZGTSDT9120,
        ZGTSDS0020.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS: GC_VKORG_6000    TYPE VKORG   VALUE '6000',
           GC_VTWEG_10      TYPE VTWEG   VALUE '10',
           GC_VKBUR_6210    TYPE VKBUR   VALUE '6210',
           GC_VKGRP_620     TYPE VKGRP   VALUE '620',
           GC_LFART_LF      TYPE LFART   VALUE 'LF',
           GC_VTWEG_50      TYPE VTWEG   VALUE '50',
           GC_SPART_3C      TYPE SPART   VALUE '3C',
           GC_SPART_4C      TYPE SPART   VALUE '4C',
           GC_WBSTK_C       TYPE WBSTK   VALUE 'C',
           GC_FKSTK_A       TYPE FKSTK   VALUE 'A',
           GC_LIFSK_G3      TYPE LIFSK   VALUE 'G3',
           GC_LFART_ZLF     TYPE LFART   VALUE 'ZLF',
           GC_LFART_ZLF3    TYPE LFART   VALUE 'ZLF3',
           GC_CODE_04       TYPE GM_CODE VALUE '04',
           GC_LGORT_3499    TYPE LGORT_D VALUE '3499',
           GC_BWART_311     TYPE BWART   VALUE '311',
           GC_DOMAIN_STATUS TYPE DD07L-DOMNAME VALUE 'ZGTDJSSTATUS',
           GC_LENGTH_VRKME  TYPE ATNAM VALUE 'SAP_LENGTH_VKRME'.

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* STRUCTURE
*----------------------------------------------------------------------*


*----------------------------------------------------------------------*
* INTERNAL TABLE
*----------------------------------------------------------------------*
* MAIN
DATA: BEGIN OF GT_0100 OCCURS 0,
        STAT           LIKE  ICON-ID,
        SEL(1),
        ST_FINAL       LIKE  ICON-ID,
        BUTN           LIKE  ICON-ID,
        ST_STSH        LIKE  ICON-ID,
        ST_DBS         LIKE  ICON-ID,
        ST_GIC         LIKE  ICON-ID,
        ST_HDB         LIKE  ICON-ID,
        ST_BLD         LIKE  ICON-ID,
        ST_QT0         LIKE  ICON-ID,
        ST_WTU         LIKE  ICON-ID,
        ST_SGI         LIKE  ICON-ID,
        ST_SMV         LIKE  ICON-ID,
        ST_NDC         LIKE  ICON-ID,
        ST_BLC         LIKE  ICON-ID,
        ST_FGI         LIKE  ICON-ID,
        ST_FBL         LIKE  ICON-ID,
        VBELN_VA       LIKE  VBAK-VBELN,
        VBELN_VL       LIKE  LIKP-VBELN,
        KUNWE          LIKE  LIKP-KUNAG,
        KUNWE_NM       LIKE  ADRC-NAME1,
        WADAT          LIKE  LIKP-WADAT,
        WADAT_IST      LIKE  LIKP-WADAT_IST,
        NETWR_INI      LIKE  VBAP-NETWR,
        NETWR_DW       LIKE  VBAP-NETWR,
        NETWR_JS       LIKE  VBAP-NETWR,
        WAERK          LIKE  LIKP-WAERK,
        KUNNR          LIKE  LIKP-KUNNR,
        KUNNR_NM       LIKE  ADRC-NAME1,
        LFART          LIKE  LIKP-LFART,
        AUART          LIKE  VBAK-AUART,
        BSTNK          LIKE  VBAK-BSTNK,
        VSTEL          LIKE  LIKP-VSTEL,
        VSTEL_NM       LIKE  TVSTT-VTEXT,
        VKORG          LIKE  LIKP-VKORG,
        VTWEG          LIKE  LIPS-VTWEG,
        SPART          LIKE  LIPS-SPART,
        VKBUR          LIKE  LIPS-VKBUR,
        VKBUR_NM       LIKE  TVKBT-BEZEI,
        VKGRP          LIKE  LIPS-VKGRP,
        VKGRP_NM       LIKE  TVGRT-BEZEI,
        TKNUM          LIKE  VTTK-TKNUM,
        MESSAGE        LIKE  BAPIRET2-MESSAGE,

        ZZJS_FINAL     TYPE ZGTSDT9110-ZZJS_FINAL,
        ZZJS_ASN_STS_H TYPE ZGTSDT9110-ZZJS_ASN_STS_H,
        ZZJS_STATUS    TYPE ZGTSDT9110-ZZJS_STATUS,

        RUN(1),                                        "적송처리 대상
        RSLT(1),                                       "ERROR
        RSLT_PROC(1),

        CELLTAB        TYPE LVC_T_STYL, "CELL STYLE
      END OF GT_0100.
DATA:GS_0100 LIKE GT_0100.

*-SCREEN 200 ITEM
DATA: BEGIN OF GT_0200 OCCURS 0,
        SEL(1),
        ST_STSI          LIKE  ICON-ID,

        POSNR            LIKE  LIPS-POSNR,
        MATNR            LIKE  LIPS-MATNR,
        LFIMG            LIKE  LIPS-LFIMG,
        LENGTH_JS        LIKE  LIPS-LFIMG,                      "조장
        FACTOR_I         LIKE  ZGTSDT9120-MILLCA_FACTOR_M,      "최초조장수
        LFIMG_M          LIKE  LIPS-LFIMG,                      "당월수량
        FACTOR_M         LIKE  ZGTSDT9120-MILLCA_FACTOR_M,      "당월조장수
        LFIMG_JS         LIKE  LIPS-LFIMG,                      "적송수량
        FACTOR_JS        LIKE  ZGTSDT9120-MILLCA_FACTOR_JS,     "적송조장수
        NETWR_INI        LIKE  VBAP-NETWR,                      "최초금액
        NETWR_DW         LIKE  VBAP-NETWR,                      "당월금액
        NETWR_JS         LIKE  VBAP-NETWR,                      "적송금액
        WAERK            LIKE  LIKP-WAERK,
        LGORT            LIKE  LIPS-LGORT,
        LGOBE            LIKE  T001L-LGOBE,
        VGBEL            LIKE  LIPS-VGBEL,
        VGPOS            LIKE  LIPS-VGPOS,

        VBELN            TYPE LIPS-VBELN,
        VRKME            TYPE LIPS-VRKME,
        NETPR            TYPE VBAP-NETPR,

        ZZJS_MVT         TYPE ZGTSDT9120-ZZJS_MVT,
        ZZJS_ASN_STS_I   TYPE ZGTSDT9120-ZZJS_ASN_STS_I,
        MILLCA_FACTOR_M  TYPE ZGTSDT9120-MILLCA_FACTOR_M,
        MILLCA_FACTOR_JS TYPE ZGTSDT9120-MILLCA_FACTOR_JS,

        ZSAV(1),
        CELLTAB          TYPE LVC_T_STYL, "CELL STYLE
      END OF GT_0200.
DATA:GS_0200 LIKE GT_0200.

DATA: BEGIN OF GT_0210 OCCURS 0,
        ST_STSD          LIKE  ICON-ID,
        POSNR            LIKE  LIPS-POSNR,
        POSNR_B          LIKE  LIPS-POSNR,
        MATNR            LIKE  LIPS-MATNR,
        CHARG            LIKE  LIPS-CHARG,
        VRKME            LIKE  LIPS-VRKME,
        LFIMG            LIKE  LIPS-LFIMG,
        LENGTH_JS        LIKE  LIPS-LFIMG,                 "조장
        FACTOR_I         LIKE  ZGTSDT9120-MILLCA_FACTOR_M, "최초조장수
        FACTOR_M         LIKE  ZGTSDT9120-MILLCA_FACTOR_M, "당월조장수
        LFIMG_M          LIKE  LIPS-LFIMG,                 "당월수량
        NETPR            LIKE  VBAP-NETPR,                 "단가
        NETWR_DW         LIKE  VBAP-NETWR,                 "당월금액
        FACTOR_JS        LIKE  ZGTSDT9120-MILLCA_FACTOR_JS, "적송조장수
        LFIMG_JS         LIKE  LIPS-LFIMG,                 "적송수량
        NETWR_JS         LIKE  VBAP-NETWR,                 "적송금액
        MESSAGE          LIKE  BAPIRET2-MESSAGE,

        WAERK            TYPE LIKP-WAERK,

        ZZJS_MVT         TYPE ZGTSDT9120-ZZJS_MVT,
        ZZJS_ASN_STS_I   TYPE ZGTSDT9120-ZZJS_ASN_STS_I,
        MILLCA_FACTOR_M  TYPE ZGTSDT9120-MILLCA_FACTOR_M,
        MILLCA_FACTOR_JS TYPE ZGTSDT9120-MILLCA_FACTOR_JS,

        RSLT(1),                                           "에러상태

        CELLTAB          TYPE LVC_T_STYL, "CELL STYLE
      END OF GT_0210.
DATA: GS_0210 LIKE GT_0210.
DATA: GT_0210_LIST LIKE GT_0210 OCCURS 0 WITH HEADER LINE.
DATA: GT_0210_CLER LIKE GT_0210 OCCURS 0 WITH HEADER LINE.

DATA: GT_LIKP TYPE TABLE OF ZGTSDT9110,
      GT_LIPS TYPE TABLE OF ZGTSDT9120.

*-신규 DO 리스트
DATA: BEGIN OF GT_0900 OCCURS 0,
        LFART     LIKE LIKP-LFART,
        LFART_NM  LIKE TVLKT-VTEXT,
        VBELN_VL  LIKE LIKP-VBELN,
        VBELN_VA  LIKE VBAK-VBELN,
        KUNNR     LIKE LIKP-KUNAG,  "판매처
        KUNNR_NM  LIKE ADRC-NAME1,
        WADAT_IST LIKE LIKP-WADAT_IST,
        NETWR     LIKE VBAP-NETWR,
        WAERK     LIKE LIKP-WAERK,
        KUNWE     LIKE LIKP-KUNNR,  "납품처
        KUNWE_NM  LIKE ADRC-NAME1,

        NETPR     TYPE VBAP-NETPR,
        LFIMG     TYPE LIPS-LFIMG,
        VRKME     TYPE LIPS-VRKME,
      END OF GT_0900.

*-상태코드
DATA: BEGIN OF GT_CODE OCCURS 0,
        CODE(1),
        STATUS(20),
        TEXT(50),
      END OF GT_CODE.

*-BAPI 'BAPI_GOODSMVT_CREATE'
DATA:GS_GOODSMVT_HEADER  TYPE  BAPI2017_GM_HEAD_01,
     GS_GOODSMVT_CODE    TYPE  BAPI2017_GM_CODE,
     GS_GOODSMVT_HEADRET TYPE  BAPI2017_GM_HEAD_RET,
     GT_GOODSMVT_ITEM    TYPE TABLE OF  BAPI2017_GM_ITEM_CREATE,
     GS_GOODSMVT_ITEM	   TYPE BAPI2017_GM_ITEM_CREATE,
     GT_RETURN           TYPE TABLE OF BAPIRET2.

*----------------------------------------------------------------------*
* VARIABLES
*----------------------------------------------------------------------*
DATA: OK_CODE TYPE SY-UCOMM,
      SAVE_OK TYPE SY-UCOMM.

DATA: GV_ERROR,
      GV_CHK,
      GV_TYPE,
      GV_EDIT,
      GV_ANSWER.

DATA: GV_TITLE(50),
      GV_TITLE1(50),
      GV_TITLE2(50),
      GV_TITLE3(50).

DATA: GV_TABIX LIKE SY-TABIX,
      GV_INDEX TYPE SY-TABIX.

DATA: GV_VKORG TYPE VKORG.

DATA: GV_STATUS_CUR TYPE ZGTSDT9110-ZZJS_STATUS,
      GV_STATUS_ERR TYPE ZGTSDT9110-ZZJS_STATUS.

DATA: GV_ZLF3_ONLY(1).

DATA: GV_FLAG_FKDAT(1). "당월매출일 입력제어
*----------------------------------------------------------------------*
* FIELD-SYMBOLS
*----------------------------------------------------------------------*
*FIELD-SYMBOLS:


*----------------------------------------------------------------------*
* RANGES
*----------------------------------------------------------------------*
RANGES: GR_LOEVM  FOR ZGTSDT9110-LOEVM.


*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS:
  GC_A TYPE C VALUE 'A',
  GC_B TYPE C VALUE 'B',
  GC_C TYPE C VALUE 'C',
  GC_D TYPE C VALUE 'D',
  GC_E TYPE C VALUE 'E',
  GC_F TYPE C VALUE 'F',
  GC_G TYPE C VALUE 'G',
  GC_H TYPE C VALUE 'H',
  GC_I TYPE C VALUE 'I',
  GC_J TYPE C VALUE 'J',
  GC_K TYPE C VALUE 'K',
  GC_L TYPE C VALUE 'L',
  GC_M TYPE C VALUE 'M',
  GC_N TYPE C VALUE 'N',
  GC_O TYPE C VALUE 'O',
  GC_P TYPE C VALUE 'P',
  GC_Q TYPE C VALUE 'Q',
  GC_R TYPE C VALUE 'R',
  GC_S TYPE C VALUE 'S',
  GC_T TYPE C VALUE 'T',
  GC_U TYPE C VALUE 'U',
  GC_V TYPE C VALUE 'V',
  GC_W TYPE C VALUE 'W',
  GC_X TYPE C VALUE 'X',
  GC_Y TYPE C VALUE 'Y',
  GC_Z TYPE C VALUE 'Z',
  GC_0 TYPE C VALUE '0',
  GC_1 TYPE C VALUE '1',
  GC_2 TYPE C VALUE '2',
  GC_3 TYPE C VALUE '3',
  GC_4 TYPE C VALUE '4',
  GC_5 TYPE C VALUE '5',
  GC_6 TYPE C VALUE '6',
  GC_7 TYPE C VALUE '7',
  GC_8 TYPE C VALUE '8',
  GC_9 TYPE C VALUE '9'.

DEFINE __BAPI_TRANSACTION_COMMIT.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
   EXPORTING
     WAIT          = 'X'.
END-OF-DEFINITION.
DEFINE __BAPI_TRANSACTION_ROLLBACK.
  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
END-OF-DEFINITION.
