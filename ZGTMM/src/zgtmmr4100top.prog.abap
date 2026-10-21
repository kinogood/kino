*&---------------------------------------------------------------------*
*& Include ZGTMMR4100TOP
*&---------------------------------------------------------------------*

DATA : BEGIN OF GT_KEY OCCURS 0,
         FNAME LIKE DD03L-FIELDNAME,
       END   OF GT_KEY.

DATA : BEGIN OF GT_DD07V OCCURS 0,
         DOMNAME  LIKE DD07V-DOMNAME,
         DOMVALUE LIKE DD07V-DOMVALUE_L,
         DDTEXT   LIKE DD07V-DDTEXT,
       END   OF GT_DD07V.

DATA : BEGIN OF GT_LIST OCCURS 0,
         STATUS      LIKE ICON-ID,          "Status
         MSG_TXT(50),                       "Message
         BUKRS       LIKE ZGTMMT4100-BUKRS, "회사코드
         BUTXT       LIKE T001-BUTXT,       "회사명
         WERKS       LIKE ZGTMMT4100-WERKS, "플랜트
         PLANTNAME   LIKE T001W-NAME1,      "플랜트명
         LGORT       LIKE ZGTMMT4100-LGORT, "저장위치
         LGORTNAME   LIKE T001L-LGOBE,      "저장위치명
         ZMODE       LIKE ZGTMMT4100-ZMODE, "출고방법
         ZMODENAME   LIKE DD07V-DDTEXT.     "출고방법명

         INCLUDE STRUCTURE ZGTMMS0000.
DATA :   TYPE,
         STYLE       TYPE LVC_T_STYL,
         COLOR       TYPE LVC_T_SCOL,
       END     OF GT_LIST.

DATA : GT_SCR LIKE GT_LIST OCCURS 0 WITH HEADER LINE.
*      GT_OLD LIKE GT_LIST OCCURS 0 WITH HEADER LINE,

DATA : GT_M41 LIKE ZGTMMT4100 OCCURS 0 WITH HEADER LINE,
       GT_D41 LIKE ZGTMMT4100 OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF GS_MCON,
         BUKRS LIKE T001-BUKRS,
         BUTXT LIKE T001-BUTXT,
         WERKS LIKE T001W-WERKS,
         NAME1 LIKE T001W-NAME1,
       END   OF GS_MCON.

DATA : GV_CNT TYPE I.

DATA : GV_OKCODE LIKE SY-UCOMM.

DATA : GT_RTAB LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

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
            GC_EM(1)          VALUE '!',
            GC_0(1)           VALUE '0',
            GC_1(1)           VALUE '1',
            GC_6(1)           VALUE '6',
            GC_EQ(2)          VALUE 'EQ',
            GC_COLOR(5)       VALUE 'COLOR',
            GC_STYLE(5)       VALUE 'STYLE',
            GC_LGORT(5)       VALUE 'LGORT',
            GC_ZMODE(5)       VALUE 'ZMODE',
            GC_ZGTDMMMODE(10) VALUE 'ZGTDMMMODE'.


"향후 권한 연동하여 User 별 Defalut 값 관리 시 Display 필드로 변경 예정(BUKRS/WERKS)
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-S01.
  PARAMETERS : P_BUKRS LIKE ZGTMMT4100-BUKRS, "OBLIGATORY
               P_WERKS LIKE ZGTMMT4100-WERKS. "OBLIGATORY
SELECTION-SCREEN END   OF BLOCK B01.
