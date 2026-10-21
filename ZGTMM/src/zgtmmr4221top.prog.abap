*&---------------------------------------------------------------------*
*& Include ZGTMMR4221TOP
*&---------------------------------------------------------------------*

DATA : BEGIN OF GT_KEY OCCURS 0,
         FNAME LIKE DD03L-FIELDNAME,
       END   OF GT_KEY.

DATA : BEGIN OF GT_LIST OCCURS 0,
         STATUS      LIKE ICON-ID,           "Status
         MSG_TXT(50),                        "Message
         WERKS       LIKE ZGTMMT4202-WERKS,  "플랜트
         NAME1       LIKE T001W-NAME1,       "플랜트명
         FACTOR      LIKE ZGTMMT4202-FACTOR, "Service Factor
         RATE        LIKE ZGTMMT4202-RATE,   "%
         ZUSE        LIKE ZGTMMT4202-ZUSE.   "적용대상
         INCLUDE STRUCTURE ZGTMMS0000.
DATA :   TYPE,
         IDX         LIKE SY-INDEX,
         STYLE       TYPE LVC_T_STYL,
         COLOR       TYPE LVC_T_SCOL,
       END     OF GT_LIST.

DATA : GT_SCR LIKE GT_LIST OCCURS 0 WITH HEADER LINE,
       GT_TMP LIKE GT_LIST OCCURS 0 WITH HEADER LINE.

DATA : GT_M22 LIKE ZGTMMT4202 OCCURS 0 WITH HEADER LINE,
       GT_D22 LIKE ZGTMMT4202 OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF GS_MCON,
         WERKS LIKE T001W-WERKS,
         NAME1 LIKE T001W-NAME1,
       END   OF GS_MCON.

DATA : GV_CNT TYPE I.

DATA : GV_OKCODE LIKE SY-UCOMM.

DATA : GV_CHG,
       GV_CHK,
       GV_ERR,
       GV_NEW,
       GV_REF,
       GV_ANS,
       GV_MSG(50).

DATA : GV_TBX TYPE LVC_INDEX, "내부 Index
       GV_ROW TYPE LVC_INDEX, "화면 Index
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


FIELD-SYMBOLS : <GFS_COL> TYPE LVC_T_SCOL.

DATA : GR_IDX TYPE RANGE OF LVC_INDEX.

RANGES : GR_DROW FOR LVC_S_MOCE-ROW_ID.


CONSTANTS : GC_A(1)      VALUE 'A',
            GC_C(1)      VALUE 'C',
            GC_D(1)      VALUE 'D',
            GC_E(1)      VALUE 'E',
            GC_I(1)      VALUE 'I',
            GC_S(1)      VALUE 'S',
            GC_U(1)      VALUE 'U',
            GC_X(1)      VALUE 'X',
            GC_0(1)      VALUE '0',
            GC_1(1)      VALUE '1',
            GC_6(1)      VALUE '6',
            GC_EQ(2)     VALUE 'EQ',
            GC_COLOR(5)  VALUE 'COLOR',
            GC_STYLE(5)  VALUE 'STYLE',
            GC_FACTOR(6) VALUE 'FACTOR'.


*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
"향후 권한 연동하여 User별 Defalut 값 관리시 Display 필드로 변경 예정(WERKS)
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-S01.
  PARAMETERS : P_WERKS LIKE T001W-WERKS OBLIGATORY.
SELECTION-SCREEN END   OF BLOCK B01.
