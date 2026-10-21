*&---------------------------------------------------------------------*
*& Include ZGTMMR1010TOP
*&---------------------------------------------------------------------*

DATA : BEGIN OF GS_MCON,
         BUKRS LIKE T001-BUKRS,
         BUTXT LIKE T001-BUTXT,
         WERKS LIKE T001W-WERKS,
         NAME1 LIKE T001W-NAME1,
       END   OF GS_MCON.

DATA : BEGIN OF GT_KEY OCCURS 0,
         FNAME LIKE DD03L-FIELDNAME,
         POSIT LIKE DD03L-POSITION,
       END   OF GT_KEY.

DATA : GT_KTAB TYPE ABAP_SORTORDER_TAB.

"승인자명      ZGTMM_CV_APPUSER_LIST-APNAME1
"승인자명(대리) ZGTMM_CV_APPUSER_LIST-APNAME2

DATA : BEGIN OF GT_ABL OCCURS 0,
         STATUS      LIKE ICON-ID,              "Status(상태)
         MSG_TXT(50),                           "Message
         BUKRS       LIKE ZGTMMT4113-BUKRS,     "회사코드
         BUTXT       LIKE T001-BUTXT,           "회사명
         WERKS       LIKE ZGTMMT4113-WERKS,     "플랜트
         NAME1       LIKE T001W-NAME1,          "플랜트명
         LGORT       LIKE ZGTMMT4113-LGORT,     "저장위치
         LGOBE       LIKE T001L-LGOBE,          "저장위치명
         APPROVER1   LIKE ZGTMMT4113-APPROVER1, "승인자
         APNAME1     LIKE ZPA0539-FNMHG,        "승인자명
         APPROVER2   LIKE ZGTMMT4113-APPROVER2, "승인자(대리)
         APNAME2     LIKE ZPA0539-FNMHG.        "승인자명(대리)
         INCLUDE STRUCTURE ZGTMMS0000.
DATA :   TYPE,
         STYLE       TYPE LVC_T_STYL,
         COLOR       TYPE LVC_T_SCOL,
       END   OF GT_ABL.

"승인자명 ZGTMM_CV_APPUSER_LIST_SPG-APNAME1

DATA : BEGIN OF GT_ABS OCCURS 0,
         STATUS      LIKE ICON-ID,            "Status(상태)
         MSG_TXT(50),                         "Message
         BUKRS       LIKE ZGTMMT4014-BUKRS,   "회사코드
         BUTXT       LIKE T001-BUTXT,         "회사명
         WERKS       LIKE ZGTMMT4014-WERKS,   "플랜트
         NAME1       LIKE T001W-NAME1,        "플랜트명
         EKGRP       LIKE ZGTMMT4014-EKGRP,   "구매그룹
         EKNAM       LIKE T024-EKNAM,         "구매그룹명
         APPUSER     LIKE ZGTMMT4014-APPUSER, "승인자
         APNAME1     LIKE ZPA0539-FNMHG,      "승인자명
         ZUSE        LIKE ZGTMMT4014-ZUSE.    "사용여부
         INCLUDE STRUCTURE ZGTMMS0000.
DATA :   TYPE,
         STYLE       TYPE LVC_T_STYL,
         COLOR       TYPE LVC_T_SCOL,
       END   OF GT_ABS.

DATA : GT_OBL LIKE GT_ABL OCCURS 0 WITH HEADER LINE,
       GT_SBL LIKE GT_ABL OCCURS 0 WITH HEADER LINE,
       GT_OBS LIKE GT_ABS OCCURS 0 WITH HEADER LINE,
       GT_SBS LIKE GT_ABS OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF GS_COM,
         STATUS      LIKE ICON-ID,              "Status(상태)
         MSG_TXT(50),                           "Message
         BUKRS       LIKE ZGTMMT4113-BUKRS,     "회사코드
         BUTXT       LIKE T001-BUTXT,           "회사명
         WERKS       LIKE ZGTMMT4113-WERKS,     "플랜트
         NAME1       LIKE T001W-NAME1.          "플랜트명
         INCLUDE STRUCTURE ZGTMMS0000.
DATA :   TYPE,
       END   OF GS_COM.

DATA : GT_M13 LIKE ZGTMMT4113 OCCURS 0 WITH HEADER LINE,
       GT_D13 LIKE ZGTMMT4113 OCCURS 0 WITH HEADER LINE,
       GT_M14 LIKE ZGTMMT4014 OCCURS 0 WITH HEADER LINE,
       GT_D14 LIKE ZGTMMT4014 OCCURS 0 WITH HEADER LINE.

DATA : GV_TNAME TYPE TABNAME,
       GV_COND  TYPE STRING.

DATA : GV_CNT TYPE I.

DATA : GV_OKCODE LIKE SY-UCOMM,
       GV_TITLE  TYPE STRING.

DATA : GT_RTAB LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

DATA : GV_CHG,
       GV_CHK,
       GV_ERR,
       GV_NEW,
       GV_REF,
       GV_ANS,
       GV_MSG(50).

DATA : GV_TBX TYPE LVC_INDEX,
       GV_SEQ TYPE LVC_INDEX,
       GV_FNM TYPE LVC_FNAME.

DATA : BEGIN OF GS_ERR,
         INDEX   TYPE LVC_INDEX,
         F_SEQ   TYPE LVC_INDEX,
         FNAME   TYPE LVC_FNAME,
         TYPE(1),
         MSG(50),
       END   OF GS_ERR.
DATA : GT_ERR LIKE SORTED TABLE OF GS_ERR
              WITH UNIQUE KEY INDEX F_SEQ FNAME TYPE.

DATA : GS_CREA LIKE ZGTMMS0001,
       GS_CHNG LIKE ZGTMMS0002.

DATA : GV_TCNT TYPE I,
       GV_MCNT TYPE I,
       GV_DCNT TYPE I.


FIELD-SYMBOLS : <GFS_STY>    TYPE LVC_T_STYL,
                <GFS_COL>    TYPE LVC_T_SCOL,
                <GFS_STATUS>,
                <GFS_MTXT>,
                <GFS_TYPE>,
                <GFS_KEY>,
                <GFS_VAL>.


DATA : GR_IDX TYPE RANGE OF LVC_INDEX.

RANGES : GR_DROW FOR LVC_S_MOCE-ROW_ID.


CONSTANTS : GC_A(1)           VALUE 'A',
            GC_C(1)           VALUE 'C',
            GC_D(1)           VALUE 'D',
            GC_E(1)           VALUE 'E',
            GC_I(1)           VALUE 'I',
            GC_S(1)           VALUE 'S',
            GC_U(1)           VALUE 'U',
            GC_X(1)           VALUE 'X',
            GC_EM(1)          VALUE '!',
            GC_0(1)           VALUE '0',
            GC_1(1)           VALUE '1',
            GC_6(1)           VALUE '6',
            GC_EQ(2)          VALUE 'EQ',
            GC_C112(4)        VALUE 'C112',
            GC_COLOR(5)       VALUE 'COLOR',
            GC_STYLE(5)       VALUE 'STYLE',
            GC_MANDT(5)       VALUE 'MANDT',
            GC_BUKRS(5)       VALUE 'BUKRS',
            GC_WERKS(5)       VALUE 'WERKS',
            GC_APNAME1(7)     VALUE 'APNAME1',
            GC_APNAME2(7)     VALUE 'APNAME2',
            GC_APPUSER(7)     VALUE 'APPUSER',
            GC_APPROVER1(9)   VALUE 'APPROVER1',
            GC_ZGTMMT4014(10) VALUE 'ZGTMMT4014',
            GC_ZGTMMT4113(10) VALUE 'ZGTMMT4113'.


*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
"향후 권한 연동하여 User별 Defalut 값 관리 시 Display 필드로 변경 예정(BUKRS/WERKS)
SELECTION-SCREEN BEGIN OF BLOCK BK1 WITH FRAME TITLE TEXT-S01.
  PARAMETERS : P_BUKRS LIKE T001-BUKRS,  "OBLIGATORY,
               P_WERKS LIKE T001W-WERKS. "OBLIGATORY.
SELECTION-SCREEN END   OF BLOCK BK1.

SELECTION-SCREEN BEGIN OF BLOCK BK2 WITH FRAME TITLE TEXT-S02.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : P_ABL RADIOBUTTON GROUP GR1
                            USER-COMMAND GR1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (15) TEXT-R01 FOR FIELD P_ABL.

    SELECTION-SCREEN POSITION 32.
    PARAMETERS : P_ABS RADIOBUTTON GROUP GR1.
    SELECTION-SCREEN COMMENT (15) TEXT-R02 FOR FIELD P_ABS.
  SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BK2.
