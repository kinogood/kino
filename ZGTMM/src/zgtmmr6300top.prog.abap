*&---------------------------------------------------------------------*
*& Include ZGTMMR6300TOP
*&---------------------------------------------------------------------*

TABLES : EINA, EINE.


DATA : BEGIN OF GT_LIST OCCURS 0,
         STATUS LIKE ICON-ID,     "Msg
         INFNR  LIKE EINA-INFNR,  "정보레코드
         EKORG  LIKE EINE-EKORG,  "구매조직
         ESOKZ  LIKE EINE-ESOKZ,  "범주
         WERKS  LIKE EINE-WERKS,  "플랜트
         MATKL  LIKE EINA-MATKL,  "자재그룹
         IDNLF  LIKE EINA-IDNLF,  "외주공정 자재그룹
         LIFNR  LIKE EINA-LIFNR,  "공급업체
         NAME1  LIKE LFA1-NAME1,  "공급업체명
         DATAB  LIKE A017-DATAB,  "효력 시작일
         DATBI  LIKE A017-DATBI,  "효력 종료일
         KONWA  LIKE KONP-KONWA,  "통화
         KBETR  LIKE KONP-KBETR,  "단가
         PEINH  LIKE KONP-KPEIN,  "/
         BPRME  LIKE KONP-KMEIN,  "단위
         TXZ01  LIKE EINA-TXZ01,  "정보레코드 내역
         WGBEZ  LIKE T023T-WGBEZ, "자재그룹 내역

         MSG    TYPE BAL_T_MSG,
         STYLE  TYPE LVC_T_STYL,
         COLOR  TYPE LVC_T_SCOL,
       END   OF GT_LIST.

DATA : BEGIN OF GT_CCHK OCCURS 0,
         INFNR LIKE EINA-INFNR,  "정보레코드
         IDNLF LIKE EINA-IDNLF,  "외주공정 자재그룹
       END   OF GT_CCHK.

DATA : GV_CNT TYPE I,
       GV_IDX LIKE SY-INDEX,
       GV_FNM TYPE LVC_FNAME.

DATA : GV_CHG,
       GV_CHK,
       GV_ERR,
       GV_REF,
       GV_ANS.

DATA : GV_OKCODE LIKE SY-UCOMM.

DATA : GT_EXCD TYPE TABLE OF FCODE.

DATA : GV_DC.

DATA : GS_EINA  LIKE MEWIEINA,
       GS_EINAX LIKE MEWIEINAX,
       GT_RTN   LIKE BAPIRETURN OCCURS 0 WITH HEADER LINE.

DATA : GV_SUC TYPE I,
       GV_FAL TYPE I,
       GV_TOT TYPE I.

DATA : GS_HND TYPE BALLOGHNDL.


CONSTANTS : GC_A(1)        VALUE 'A',
            GC_C(1)        VALUE 'C',
            GC_D(1)        VALUE 'D',
            GC_E(1)        VALUE 'E',
            GC_M(1)        VALUE 'M',
            GC_S(1)        VALUE 'S',
            GC_X(1)        VALUE 'X',
            GC_1(1)        VALUE '1',
            GC_LOG(3)      VALUE 'LOG',
            GC_1100(4)     VALUE '1100',
            GC_COLOR(5)    VALUE 'COLOR',
            GC_STYLE(5)    VALUE 'STYLE',
            GC_STATUS(6)   VALUE 'STATUS',
            GC_99991231(8) VALUE '99991231'.


*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BK1 WITH FRAME TITLE TEXT-S01.
  PARAMETERS     : P_EKORG LIKE EINE-EKORG OBLIGATORY MEMORY ID EKO,
                   P_WERKS LIKE EINE-WERKS OBLIGATORY MEMORY ID WRK.
  SELECT-OPTIONS : S_LIFNR  FOR EINA-LIFNR,
                   S_MATKL  FOR EINA-MATKL,
                   S_IDNLF  FOR EINA-IDNLF,
                   S_ESOKZ  FOR EINE-ESOKZ,
                   S_INFNR  FOR EINE-INFNR.
SELECTION-SCREEN END   OF BLOCK BK1.

PARAMETERS : P_CALLD NO-DISPLAY. "공급업체 복사 기능 추가(PSJ 25.03.21)
