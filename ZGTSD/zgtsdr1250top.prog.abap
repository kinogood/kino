*&---------------------------------------------------------------------*
*&  Include           MZQM0696TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES : ZQMT0011H,
         ZQMT0011M,
         SSCRFIELDS,
         ZMMT0062,
         QALS.


*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS : C_TEMP_CREAT(30) TYPE C VALUE '신규접수'.
CONSTANTS : GC_BUKRS_6000 TYPE BUKRS VALUE '6000'.

CONSTANTS:
           GC_TYPEID_A  TYPE SRGBTBREL-TYPEID_A  VALUE 'ZSD_RECPNO',
           GC_CATID_A   TYPE SRGBTBREL-CATID_A   VALUE 'BO'.

*----------------------------------------------------------------------*
* DATA: Variable
*----------------------------------------------------------------------*
DATA : OK_CODE  LIKE SY-UCOMM,
       SAVE_OK  LIKE SY-UCOMM.

* SUPER USER
DATA: GV_SUSER(1).

*----------------------------------------------------------------------*
* DATA: Internal Table & Structure.
*----------------------------------------------------------------------*

DATA : BEGIN OF GT_DATA OCCURS 0.
        INCLUDE STRUCTURE ZQMT0011H.
DATA : SELX,
       STATUST(14),
       RESPTT(40),
       WERKS_HT   LIKE T001W-NAME1,
       SPGCDT    LIKE TSPAT-VTEXT,
       CONET2T   LIKE QPCT-KURZTEXT,   "원인부문코드내역
       KUNUMT     LIKE KNA1-NAME1,
       PRCTRT     LIKE CEPCT-KTEXT,
       RCLAST(14),
       DSTGRT(20),
       VTWEGT     LIKE TVTWT-VTEXT,
       VKBURT     TYPE ZVKBURT,
       VKGRPT     TYPE ZVKGRPT,
       SUMAMT     LIKE ZQMT0011M-RFAMT,        " 합계
       RKMNG      LIKE ZQMT0011M-RKMNG,
       MGEIN      LIKE ZQMT0011M-MGEIN,
       KWMENG     LIKE ZQMT0011M-KWMENG,
       VRKME      LIKE ZQMT0011M-VRKME,
       RFAMT      LIKE ZQMT0011M-RFAMT,
       RTAMT      LIKE ZQMT0011M-RTAMT,
       RTAMT2     LIKE ZQMT0011M-RTAMT2,
       GBAMT      LIKE ZQMT0011M-GBAMT,
       CLAMT      LIKE ZQMT0011M-CLAMT,
       IPCST      LIKE ZQMT0011M-IPCST,
       MVCST      LIKE ZQMT0011M-MVCST,
       AMT1       LIKE ZQMT0016F-WOGBTR,       "손실보상비
       AMT2       LIKE ZQMT0016F-WOGBTR,       "지체상환금
       AMT3       LIKE ZQMT0016F-WOGBTR,       "A/S지원비
       AMT4       LIKE ZQMT0016F-WOGBTR,       "하자보수비
       AMT5       LIKE ZQMT0016F-WOGBTR,       "분석검사비
       AMT6       LIKE ZQMT0016F-WOGBTR,       "Warranty비
       AMT7       LIKE ZQMT0016F-WOGBTR,       "CS자재등구입비
       AMT8       LIKE ZQMT0016F-WOGBTR,       "고객불만구상권
       AMT9       LIKE ZQMT0016F-WOGBTR,       "협력업체회수금
       AMT10       LIKE ZQMT0016F-WOGBTR,       "공사재작업비 (외부)
       MCNO     LIKE ZQMT0011B-MCNO,              "기계번호

       ATTCH      LIKE ICON-ID,
       END OF GT_DATA.



DATA : BEGIN OF GT_0011M OCCURS 0,
       RCEPNO     LIKE ZQMT0011M-RCEPNO,
       ZMATSEQ    LIKE ZQMT0011M-ZMATSEQ, "기능개선_105144
       RKMNG      LIKE ZQMT0011M-RKMNG,
       MGEIN      LIKE ZQMT0011M-MGEIN,
       KWMENG     LIKE ZQMT0011M-KWMENG,
       VRKME      LIKE ZQMT0011M-VRKME,
       RFAMT      LIKE ZQMT0011M-RFAMT,
       RTAMT      LIKE ZQMT0011M-RTAMT,
       RTAMT2     LIKE ZQMT0011M-RTAMT2,
       GBAMT      LIKE ZQMT0011M-GBAMT,
       CLAMT      LIKE ZQMT0011M-CLAMT,
       IPCST      LIKE ZQMT0011M-IPCST,
       MVCST      LIKE ZQMT0011M-MVCST,
       END OF GT_0011M.

* 회계전표
DATA : BEGIN OF GT_0016F OCCURS 0,
       RCEPNO    LIKE ZQMT0016F-RCEPNO,
       QCODE1    LIKE ZQMT0016F-QCODE1,
       SHKZG       LIKE ZQMT0016F-SHKZG,
       WOGBTR   LIKE ZQMT0016F-WOGBTR,
       END OF GT_0016F.


DATA : DIADRP     TYPE  DIADRP,
       DIADRC     TYPE  DIADRC,
       DIADR      TYPE  DIADR.

DATA: GS_CS_VARIANT  LIKE DISVARIANT,
      G_EXIT         TYPE C,
      G_CODI_CHK         TYPE C, "같으면 X
      G_SDNAM_CHK         TYPE C, "같으면 X
      G_CODI_CC LIKE USR21-KOSTL,
      G_SDNAM_CC LIKE USR21-KOSTL,
      G_CODI TYPE ZCORDI,
      G_SDNAM TYPE ZSDNAM.

DATA : GD_BUKRS TYPE ZQMT0011H-BUKRS.

*----------------------------------------------------------------------*
* DATA: MACRO
*----------------------------------------------------------------------*
DEFINE %%POPUP_TO_CONFIRM_STEP.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      DEFAULTOPTION = 'N'
      TEXTLINE1     = &1
      TITEL         = &2
      START_COLUMN  = 20
      START_ROW     = 6
    IMPORTING
      ANSWER        = GV_ANSWER.
END-OF-DEFINITION.

DEFINE %%ALPHA_CONV_OUT.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = &1
    IMPORTING
      OUTPUT = &2.
END-OF-DEFINITION.

DEFINE %%CLEAR.
  CLEAR &1. REFRESH &1.
END-OF-DEFINITION.

*----------------------------------------------------------------------*
* RANGES
*----------------------------------------------------------------------*
RANGES : R_CD023 FOR ZQMT0017-QCODE1,
         R_CD019 FOR ZQMT0017-QCODE1,
         R_CD029 FOR ZQMT0017-QCODE1,
         R_CD028 FOR ZQMT0017-QCODE1,
         R_CD017 FOR ZQMT0017-QCODE1,
         R_CD031 FOR ZQMT0017-QCODE1,
         R_CD032 FOR ZQMT0017-QCODE1,
         R_CD033 FOR ZQMT0017-QCODE1,
         R_CD018 FOR ZQMT0017-QCODE1,
         R_CH002 FOR ZQMT0017-QCODE1.

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

*----------------------------------------------------------------------*
* SELECTION-SCREEN                                                     *
*----------------------------------------------------------------------*
SELECTION-SCREEN FUNCTION KEY 1.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS : S_BUKRS   FOR ZQMT0011H-BUKRS "MEMORY ID BUK OBLIGATORY
                                               MODIF ID ZM1
                                               NO-EXTENSION NO INTERVALS,
                 S_RCEPDT  FOR ZQMT0011H-RCEPDT OBLIGATORY,
                 S_RCEPNO  FOR ZQMT0011H-RCEPNO,
                 S_WERKSH  FOR QALS-WERK NO INTERVALS,
                 S_PRCTR   FOR ZQMT0011H-PRCTR,
                 S_SPGCD   FOR ZQMT0011H-SPGCD , "MATCHCODE OBJECT C_SPART,
                 S_MATNR   FOR ZQMT0011M-MATNR,
                 S_WERKSM  FOR QALS-WERK NO INTERVALS,
                 S_KUNUM   FOR ZQMT0011H-KUNUM,
                 S_STATUS  FOR ZQMT0011H-STATUS.
SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-002.
SELECT-OPTIONS : S_RCPER  FOR ZMMT0062-PERNR,
                 S_CORDI  FOR ZMMT0062-PERNR,
                 S_JGNAM  FOR ZMMT0062-PERNR,
                 S_SDNAM  FOR ZMMT0062-PERNR.
SELECTION-SCREEN END OF BLOCK B2.


SELECTION-SCREEN BEGIN OF BLOCK B3 WITH FRAME TITLE TEXT-003.
PARAMETERS:     P_VARI   LIKE DISVARIANT-VARIANT.

SELECTION-SCREEN END OF BLOCK B3.
