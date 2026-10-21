*&---------------------------------------------------------------------*
*& Include ZGTMMR6400TOP
*&---------------------------------------------------------------------*

TABLES : ZGTMMT6220.


DATA : BEGIN OF GT_MTG OCCURS 0,
         KEY  LIKE ZGTMMT6100-ZMTGRP,
         TEXT LIKE ZGTMMT6100-ZMTGRPT,
       END   OF GT_MTG.

DATA : BEGIN OF GT_KEY OCCURS 0,
         FNAME LIKE DD03L-FIELDNAME,
       END   OF GT_KEY.

DATA : BEGIN OF GT_LIST OCCURS 0,
         STATUS      LIKE ICON-ID,                "Status
         MSG_TXT(50),                             "Message
         EKORG       LIKE ZGTMMT6220-EKORG,       "구매조직
         WERKS       LIKE ZGTMMT6220-WERKS,       "플랜트
         JOB_NO      LIKE ZGTMMT6220-JOB_NO,      "제조지시번호
         ZMTGRP      LIKE ZGTMMT6220-ZMTGRP,      "발주그룹
         ZMTGRPT     LIKE ZGTMMT6100-ZMTGRPT,     "발주그룹 내역
         LIFNR       LIKE ZGTMMT6220-LIFNR,       "공급업체
         NAME1       LIKE LFA1-NAME1,             "공급업체명
         ZJOB_NAME   LIKE ZGTEDT2121-ZJOB_NAME,   "제조지시명
         LVORM       LIKE ZGTMMT6220-LVORM.       "삭제
         INCLUDE STRUCTURE ZGTMMS0000.
DATA :   TYPE,
         IDX         LIKE SY-INDEX,
         STYLE       TYPE LVC_T_STYL,
         COLOR       TYPE LVC_T_SCOL,
       END   OF GT_LIST.

DATA : GT_SCR LIKE GT_LIST OCCURS 0 WITH HEADER LINE,
       GT_TMP LIKE GT_LIST OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF GS_JOBNX,
         JOB_NO LIKE ZGTEDT2121-ZJOB_NO,
         JOB_NM LIKE ZGTEDT2121-ZJOB_NAME,
       END   OF GS_JOBNX.

DATA : GT_M62 LIKE ZGTMMT6220 OCCURS 0 WITH HEADER LINE,
       GT_D62 LIKE ZGTMMT6220 OCCURS 0 WITH HEADER LINE.

DATA : GT_EXCD TYPE TABLE OF FCODE.


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


CONSTANTS : GC_A(1)             VALUE 'A',
            GC_C(1)             VALUE 'C',
            GC_D(1)             VALUE 'D',
            GC_E(1)             VALUE 'E',
            GC_I(1)             VALUE 'I',
            GC_S(1)             VALUE 'S',
            GC_U(1)             VALUE 'U',
            GC_X(1)             VALUE 'X',
            GC_0(1)             VALUE '0',
            GC_1(1)             VALUE '1',
            GC_6(1)             VALUE '6',
            GC_BT(2)            VALUE 'BT',
            GC_EQ(2)            VALUE 'EQ',
            GC_HGH(3)           VALUE 'HGH',
            GC_VPU(3)           VALUE 'VPU',
            GC_012(3)           VALUE '012',
            GC_SAVE(4)          VALUE 'SAVE',
            GC_COLOR(5)         VALUE 'COLOR',
            GC_STYLE(5)         VALUE 'STYLE',
            GC_LIFNR(5)         VALUE 'LIFNR',
            GC_ZMTGRP(6)        VALUE 'ZMTGRP',
            GC_S_JOB_NO-LOW(12) VALUE 'S_JOB_NO-LOW'.


*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BK1 WITH FRAME TITLE TEXT-S01.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : P_DISP RADIOBUTTON GROUP GR1
                             USER-COMMAND GR1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (15) TEXT-R01 FOR FIELD P_DISP.

    SELECTION-SCREEN POSITION 32.
    PARAMETERS : P_CHNG RADIOBUTTON GROUP GR1.
    SELECTION-SCREEN COMMENT (15) TEXT-R02 FOR FIELD P_CHNG.
  SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BK1.

SELECTION-SCREEN BEGIN OF BLOCK BK2 WITH FRAME TITLE TEXT-S02.
  PARAMETERS     : P_EKORG LIKE ZGTMMT6220-EKORG
                                OBLIGATORY MEMORY ID EKO,
                   P_WERKS LIKE ZGTMMT6220-WERKS
                                OBLIGATORY MEMORY ID WRK.

  SELECT-OPTIONS : S_JOB_NO FOR ZGTMMT6220-JOB_NO.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION  01.
    SELECTION-SCREEN COMMENT (10) TEXT-T01.

    SELECTION-SCREEN POSITION  33.
    PARAMETERS   : P_SMTGRP LIKE ZGTMMT6220-ZMTGRP USER-COMMAND SMT
                                 AS LISTBOX VISIBLE LENGTH 18.
    SELECTION-SCREEN POSITION  58.
    PARAMETERS   : P_EMTGRP LIKE ZGTMMT6220-ZMTGRP USER-COMMAND EMT
                                 AS LISTBOX VISIBLE LENGTH 18.
  SELECTION-SCREEN END   OF LINE.

  SELECT-OPTIONS : S_ZMTGRP FOR ZGTMMT6220-ZMTGRP NO-DISPLAY,
                   S_LIFNR  FOR ZGTMMT6220-LIFNR.
SELECTION-SCREEN END   OF BLOCK BK2.
