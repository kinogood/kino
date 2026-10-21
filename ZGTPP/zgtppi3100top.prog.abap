*&---------------------------------------------------------------------*
*& Include          ZGTPPI3100TOP
*&---------------------------------------------------------------------*
TABLES: ZGTPPT3500, MATDOC.

INCLUDE <CL_ALV_CONTROL>.

DATA: BEGIN OF GS_DATA,
        ZIFKEY          LIKE ZGTPPT3500-ZIFKEY,     "인터페이스키
        ZSEQNO          LIKE ZGTPPT3500-ZSEQNO,     "순번
        SEND_STAT       LIKE ICON-ID,               "전송상태/결과
        ZMESSAGE        LIKE ZGTPPT3500-ZMESSAGE,   "결과메시지
        ZSYSTEM_ID      LIKE ZGTPPT3500-ZSYSTEM_ID, "수신시스템
        ZSYSTEM_ID_DESC LIKE DD07V-DDTEXT,          "시스템내역
        MBLNR           LIKE ZGTPPT3500-MBLNR,      "자재문서번호
        MJAHR           LIKE ZGTPPT3500-MJAHR,      "자재문서연도
        ZEILE           LIKE ZGTPPT3500-ZEILE,      "자재문서항목
        WERKS           LIKE ZGTPPT3500-WERKS,      "플랜트
*        NAME1           LIKE T001W-NAME1,           "플랜트내역
        BUDAT           LIKE ZGTPPT3500-BUDAT,      "전기일자
        BWART           LIKE ZGTPPT3500-BWART,      "이동유형
        MATNR           LIKE ZGTPPT3500-MATNR,      "자재코드
        MAKTX           LIKE MAKT-MAKTX,            "자재내역
        AUFNR           LIKE ZGTPPT3500-AUFNR,      "생산오더번호
        EBELN           LIKE ZGTPPT3500-EBELN,      "구매오더번호
        EBELP           LIKE ZGTPPT3500-EBELP,      "구매오더항번
        ERFMG           LIKE ZGTPPT3500-ERFMG,      "입고수량
        ERFME           LIKE ZGTPPT3500-ERFME,      "단위
        LGORT           LIKE ZGTPPT3500-LGORT,      "입출고창고
        CHARG           LIKE ZGTPPT3500-CHARG,      "배치번호
        CPUDT           LIKE ZGTPPT3500-CPUDT,      "문서생성일
        CPUTM           LIKE ZGTPPT3500-CPUTM,      "문서생성시간
        IFDAT           LIKE ZGTPPT3500-IFDAT,      "전송일
        IFTIM           LIKE ZGTPPT3500-IFTIM,      "전송시간
        IFNAM           LIKE ZGTPPT3500-IFNAM,      "전송자

        ZSTAT           LIKE ZGTPPT3500-ZSTAT,      "전송상태
      END OF GS_DATA.
DATA: GT_DATA LIKE TABLE OF GS_DATA,
      GT_SEND LIKE TABLE OF GS_DATA.

DATA : BEGIN OF GS_TARGET,
         FLD_01 TYPE ZGTPPT1010-FLD_01,
         FLD_02 TYPE ZGTPPT1010-FLD_02,
         FLD_03 TYPE ZGTPPT1010-FLD_03,
         FLD_04 TYPE ZGTPPT1010-FLD_04,
       END OF GS_TARGET.
DATA : GT_TARGET LIKE TABLE OF GS_TARGET.

DATA: GT_OT_MAT_DOC TYPE TABLE OF ZGTPPSIF0072.

DATA: GO_CONTAIN_0100 TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA: GO_GRID_0100 TYPE REF TO CL_GUI_ALV_GRID.
DATA: GS_VARIANT TYPE DISVARIANT.
DATA: GS_LAYOUT_0100 TYPE LVC_S_LAYO.
DATA: GT_EXCLUDE_0100 TYPE UI_FUNCTIONS.
DATA: GT_FIELDCAT_0100 TYPE LVC_T_FCAT.

DATA: GT_UCOMM TYPE TABLE OF SY-UCOMM.

DATA: GV_OK_CODE TYPE SYUCOMM,
      GV_DBCNT   TYPE CHAR10.

DATA: GV_REPID TYPE SYREPID,
      GV_VALID TYPE CHAR01,
      GV_INDEX TYPE SY-TABIX,
      GV_TEXT  TYPE CHAR255.

DATA : GV_RESULT  TYPE ZO_RESULT,
       GV_MESSAGE TYPE ZO_MESSAGE.

CONSTANTS: GC_C    TYPE CHAR1           VALUE 'C',
           GC_D    TYPE CHAR1           VALUE 'D',
           GC_E    TYPE CHAR1           VALUE 'E',
           GC_F    TYPE CHAR1           VALUE 'F',
           GC_I    TYPE CHAR1           VALUE 'I',
           GC_L    TYPE CHAR1           VALUE 'L',
           GC_N    TYPE CHAR1           VALUE 'N',
           GC_P    TYPE CHAR1           VALUE 'P',
           GC_R    TYPE CHAR1           VALUE 'R',
           GC_S    TYPE CHAR1           VALUE 'S',
           GC_W    TYPE CHAR1           VALUE 'W',
           GC_X    TYPE CHAR1           VALUE 'X',
           GC_Y    TYPE CHAR1           VALUE 'Y',
           GC_ALL  TYPE CHAR1           VALUE '*',
           GC_EQ   TYPE CHAR2           VALUE 'EQ',
           GC_BT   TYPE CHAR2           VALUE 'BT',
           GC_PP   TYPE ZGTEMODULE_KIND VALUE 'PP',
           GC_101  TYPE BWART           VALUE '101',
           GC_0010 TYPE ZGTECODEGRP     VALUE '0010'.
