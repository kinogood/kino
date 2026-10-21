*&---------------------------------------------------------------------*
*& Include ZGTMMR1000TOP
*&---------------------------------------------------------------------*

DATA : BEGIN OF GT_KEY OCCURS 0,
         FNAME LIKE DD03L-FIELDNAME,
         POSIT LIKE DD03L-POSITION,
       END   OF GT_KEY.

DATA : BEGIN OF GT_DD07V OCCURS 0,
         DOMNAME  LIKE DD07V-DOMNAME,
         DOMVALUE LIKE DD07V-DOMVALUE_L,
         DDTEXT   LIKE DD07V-DDTEXT,
       END   OF GT_DD07V.

DATA : BEGIN OF GT_LIST OCCURS 0,
         STATUS      LIKE ICON-ID,                "Status
         MSG_TXT(50),                             "Message
         BUKRS       LIKE ZGTMMT1000-BUKRS,       "회사코드
         BUTXT       LIKE T001-BUTXT,             "회사명
         WERKS       LIKE ZGTMMT1000-WERKS,       "플랜트
         PLANTNAME   LIKE T001W-NAME1,            "플랜트명
         ZTYPE       LIKE ZGTMMT1000-ZTYPE,       "과제구분
         TYPENAME    LIKE DD07V-DDTEXT,           "과제명
         ZUSE        LIKE ZGTMMT1000-ZUSE,        "적용여부
         ERDAT       LIKE ZGTMMT1000-ERDAT,       "생성일
         ERDAT_LOCAL LIKE ZGTMMT1000-ERDAT_LOCAL, "생성일(Local)
         ERTIM       LIKE ZGTMMT1000-ERTIM,       "생성시간
         ERTIM_LOCAL LIKE ZGTMMT1000-ERTIM_LOCAL, "생성시간(Local)
         ERNAM       LIKE ZGTMMT1000-ERNAM,       "생성자
         AEDAT       LIKE ZGTMMT1000-AEDAT,       "변경일
         AEDAT_LOCAL LIKE ZGTMMT1000-AEDAT_LOCAL, "변경일(Local)
         AETIM       LIKE ZGTMMT1000-AETIM,       "변경시간
         AETIM_LOCAL LIKE ZGTMMT1000-AETIM_LOCAL, "변경시간(Local)
         AENAM       LIKE ZGTMMT1000-AENAM,       "변경자

         TYPE,
         STYLE       TYPE LVC_T_STYL,
         COLOR       TYPE LVC_T_SCOL,
       END     OF GT_LIST.

DATA : GT_SCR LIKE GT_LIST OCCURS 0 WITH HEADER LINE.
*      GT_OLD LIKE GT_LIST OCCURS 0 WITH HEADER LINE,

DATA : GT_M10 LIKE ZGTMMT1000 OCCURS 0 WITH HEADER LINE,
       GT_D10 LIKE ZGTMMT1000 OCCURS 0 WITH HEADER LINE.

DATA : G_BUTXT LIKE T001-BUTXT.

DATA : GV_CNT TYPE I.

DATA : GV_OKCODE LIKE SY-UCOMM.

DATA : GV_CHG,
       GV_ERR,
       GV_REF,
       GV_ANS,
       GV_MSG(50).

DATA : GV_TBX TYPE LVC_INDEX.

DATA : BEGIN OF GS_ERR,
         INDEX   TYPE LVC_INDEX,
         FNAME   TYPE LVC_FNAME,
         TYPE(1),
         MSG(50),
       END   OF GS_ERR.
DATA : GT_ERR LIKE SORTED TABLE OF GS_ERR
              WITH UNIQUE KEY INDEX FNAME TYPE.

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
            GC_MANDT(5)       VALUE 'MANDT',
            GC_BUKRS(5)       VALUE 'BUKRS',
            GC_ZTYPE(5)       VALUE 'ZTYPE',
            GC_ZGTDMMTYPE(10) VALUE 'ZGTDMMTYPE',
            GC_ZGTMMT1000(10) VALUE 'ZGTMMT1000'.


"향후 권한 적용 시 입력 불가한 Display 필드로 변경 예정
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-S01.
  PARAMETERS : P_BUKRS LIKE T001-BUKRS MODIF ID ATH. "OBLIGATORY
SELECTION-SCREEN END   OF BLOCK B01.
