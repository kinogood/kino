*&---------------------------------------------------------------------*
*& Include ZGTMMR4000TOP
*&---------------------------------------------------------------------*

TABLES : ZGTMMT4000.


DATA : BEGIN OF GT_KEY OCCURS 0,
         FNAME LIKE DD03L-FIELDNAME,
*        POSIT LIKE DD03L-POSITION,
       END   OF GT_KEY.

DATA : BEGIN OF GT_LIST OCCURS 0,
         STATUS      LIKE ICON-ID,          "Status
         MSG_TXT(50),                       "Message
         BUKRS       LIKE ZGTMMT4000-BUKRS, "회사코드
         BUTXT       LIKE T001-BUTXT,       "회사명
         WERKS       LIKE ZGTMMT4000-WERKS, "플랜트
         PLANTNAME   LIKE T001W-NAME1,      "플랜트명
         MATNR       LIKE ZGTMMT4000-MATNR, "자재코드
         MAKTX       LIKE MAKT-MAKTX,       "자재명
         LIFNR       LIKE ZGTMMT4000-LIFNR, "공급업체
         VENDORNAME  LIKE LFA1-NAME1,       "공급업체명
         ZSEQ        LIKE ZGTMMT4000-ZSEQ,  "SEQ
         EMLIF       LIKE ZGTMMT4000-EMLIF, "직납업체
         DIRECTNAME  LIKE LFA1-NAME1,       "직납업체명
         LBLKZ       LIKE ZGTMMT4000-LBLKZ. "SC

         INCLUDE STRUCTURE ZGTMMS0000.
DATA :   TYPE,
         STYLE       TYPE LVC_T_STYL,
         COLOR       TYPE LVC_T_SCOL,
       END     OF GT_LIST.

DATA : GT_SCR LIKE GT_LIST OCCURS 0 WITH HEADER LINE.
*      GT_OLD LIKE GT_LIST OCCURS 0 WITH HEADER LINE,

DATA : GT_M40 LIKE ZGTMMT4000 OCCURS 0 WITH HEADER LINE,
       GT_D40 LIKE ZGTMMT4000 OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF GS_MCON,
         BUKRS LIKE T001-BUKRS,
         BUTXT LIKE T001-BUTXT,
         WERKS LIKE T001W-WERKS,
         NAME1 LIKE T001W-NAME1,
       END   OF GS_MCON.

DATA : GV_CNT TYPE I.

DATA : GV_OKCODE LIKE SY-UCOMM.

DATA : GT_RTAB LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

DATA : GT_EXCD TYPE TABLE OF FCODE.

DATA : GV_CHG,
       GV_ERR,
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

DATA : BEGIN OF GS_SEQ,
         BUKRS LIKE ZGTMMT4000-BUKRS, "회사코드
         WERKS LIKE ZGTMMT4000-WERKS, "플랜트
         MATNR LIKE ZGTMMT4000-MATNR, "자재코드
         LIFNR LIKE ZGTMMT4000-LIFNR, "공급업체
         ZSEQ  LIKE ZGTMMT4000-ZSEQ,  "SEQ
       END   OF GS_SEQ.
DATA : GT_SEQ LIKE GS_SEQ OCCURS 0 WITH HEADER LINE.
*DATA: GT_SEQ LIKE SORTED TABLE OF GS_SEQ
*             WITH UNIQUE KEY BUKRS WERKS MATNR LIFNR ZSEQ.

DATA : GS_CREA LIKE ZGTMMS0001,
       GS_CHNG LIKE ZGTMMS0002.

DATA : GV_TCNT TYPE I,
       GV_MCNT TYPE I,
       GV_DCNT TYPE I.


FIELD-SYMBOLS : <GFS_COL> TYPE LVC_T_SCOL.

RANGES : GR_DROW FOR LVC_S_MOCE-ROW_ID.


CONSTANTS : GC_A(1)           VALUE 'A',
            GC_C(1)           VALUE 'C',
            GC_D(1)           VALUE 'D',
            GC_E(1)           VALUE 'E',
            GC_I(1)           VALUE 'I',
            GC_S(1)           VALUE 'S',
            GC_U(1)           VALUE 'U',
            GC_X(1)           VALUE 'X',
            GC_0(1)           VALUE '0',
            GC_1(1)           VALUE '1',
            GC_6(1)           VALUE '6',
            GC_EQ(2)          VALUE 'EQ',
            GC_COLOR(5)       VALUE 'COLOR',
            GC_STYLE(5)       VALUE 'STYLE',
            GC_MATNR(5)       VALUE 'MATNR',
            GC_LIFNR(5)       VALUE 'LIFNR',
            GC_EMLIF(5)       VALUE 'EMLIF',
            GC_ZGTMMT4000(10) VALUE 'ZGTMMT4000'.


"향후 권한 연동하여 User 별 Defalut 값 관리 시 Display 필드로 변경 예정(BUKRS/WERKS)
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-S01.
  PARAMETERS     : P_BUKRS LIKE ZGTMMT4000-BUKRS, "OBLIGATORY
                   P_WERKS LIKE ZGTMMT4000-WERKS. "OBLIGATORY
  SELECT-OPTIONS : S_MATNR  FOR ZGTMMT4000-MATNR,
                   S_LIFNR  FOR ZGTMMT4000-LIFNR.
SELECTION-SCREEN END   OF BLOCK B01.

PARAMETERS : P_CALLD NO-DISPLAY. "직납공급처 복사 기능 추가(박상진E 25.01.17)
