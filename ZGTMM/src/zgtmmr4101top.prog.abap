*&---------------------------------------------------------------------*
*& Include ZGTMMR4101TOP
*&---------------------------------------------------------------------*

DATA : BEGIN OF GT_KEY OCCURS 0,
         FNAME LIKE DD03L-FIELDNAME,
       END   OF GT_KEY.

DATA : BEGIN OF GT_LIST OCCURS 0,
         STATUS      LIKE ICON-ID,           "Status
         MSG_TXT(50),                        "Message
         LIFNR       LIKE ZGTMMT4101-LIFNR,  "공급업체
         NAME1       LIKE LFA1-NAME1,        "공급업체명
         ZETC        LIKE ZGTMMT4101-ZETC.   "비고
         INCLUDE STRUCTURE ZGTMMS0000.
DATA :   TYPE,
         STYLE       TYPE LVC_T_STYL,
         COLOR       TYPE LVC_T_SCOL,
       END     OF GT_LIST.

DATA : GT_SCR LIKE GT_LIST OCCURS 0 WITH HEADER LINE,
       GT_TMP LIKE GT_LIST OCCURS 0 WITH HEADER LINE.

DATA : GT_M11 LIKE ZGTMMT4101 OCCURS 0 WITH HEADER LINE,
       GT_D11 LIKE ZGTMMT4101 OCCURS 0 WITH HEADER LINE.


DATA : GV_CNT TYPE I.

DATA : GV_OKCODE LIKE SY-UCOMM.

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


FIELD-SYMBOLS : <GFS_COL> TYPE LVC_T_SCOL.

DATA : GR_IDX TYPE RANGE OF LVC_INDEX.

RANGES : GR_DROW FOR LVC_S_MOCE-ROW_ID.


CONSTANTS : GC_A(1)     VALUE 'A',
            GC_C(1)     VALUE 'C',
            GC_D(1)     VALUE 'D',
            GC_E(1)     VALUE 'E',
            GC_I(1)     VALUE 'I',
            GC_S(1)     VALUE 'S',
            GC_U(1)     VALUE 'U',
            GC_X(1)     VALUE 'X',
            GC_0(1)     VALUE '0',
            GC_1(1)     VALUE '1',
            GC_6(1)     VALUE '6',
            GC_EQ(2)    VALUE 'EQ',
            GC_LIFNR(5) VALUE 'LIFNR',
            GC_COLOR(5) VALUE 'COLOR',
            GC_STYLE(5) VALUE 'STYLE'.
