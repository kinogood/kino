*&---------------------------------------------------------------------*
*& Include          ZGTPPI1040TOP
*&---------------------------------------------------------------------*
TABLES : MARA, MAPL, ZGTPPT1070, T001W, DD07T, MAKT.

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
TYPES : BEGIN OF STY_ITAB,
          OBJ_TYPE LIKE ZGTPPT1070-OBJ_TYPE,
          OBJ_DESC LIKE ZGTPPT1070-OBJ_DESC,
          SEQ_NO   LIKE ZGTPPT1070-SEQ_NO,
          WERKS    LIKE ZGTPPT1070-WERKS,
          FLD_01   LIKE ZGTPPT1070-FLD_01,
          FLD_02   LIKE ZGTPPT1070-FLD_02,
          FLD_03   LIKE ZGTPPT1070-FLD_03,
          FLD_04   LIKE ZGTPPT1070-FLD_04,
          FLD_05   LIKE ZGTPPT1070-FLD_05,
          FLD_06   LIKE ZGTPPT1070-FLD_06,
          FLD_07   LIKE ZGTPPT1070-FLD_07,
          FLD_08   LIKE ZGTPPT1070-FLD_08,
          FLD_09   LIKE ZGTPPT1070-FLD_09,
          FLD_10   LIKE ZGTPPT1070-FLD_10,
        END OF STY_ITAB,
        TTY_ITAB TYPE TABLE OF STY_ITAB.
*----------------------------------------------------------------------*
* DATA: Variable
*----------------------------------------------------------------------*
DATA : GV_RESULT  TYPE ZO_RESULT,
       GV_MESSAGE TYPE ZO_MESSAGE.

DATA: GV_OK_CODE LIKE SY-UCOMM.

*----------------------------------------------------------------------*
* DATA: Structure. (Field strings : Working area)
*----------------------------------------------------------------------*
DATA : BEGIN OF GS_MAIN_DISP,
         ZIFKEY     LIKE ZGTPPT1070-ZIFKEY,
         ZSEQNO     LIKE ZGTPPT1070-ZSEQNO,
         STATUS     LIKE ICON-ID,
         ZSTAT      LIKE ZGTPPT1070-ZSTAT,
         ZMESSAGE   LIKE ZGTPPT1070-ZMESSAGE,
         ZSYSTEM_ID LIKE ZGTPPT1070-ZSYSTEM_ID,
         DDTEXT     LIKE DD07T-DDTEXT,
         OBJ_TYPE   LIKE ZGTPPT1070-OBJ_TYPE,
         OBJ_DESC   LIKE ZGTPPT1070-OBJ_DESC,
         SEQ_NO     LIKE ZGTPPT1070-SEQ_NO,
         WERKS      LIKE ZGTPPT1070-WERKS,
         FLD_01     LIKE ZGTPPT1070-FLD_01,
         FLD_02     LIKE ZGTPPT1070-FLD_02,
         FLD_03     LIKE ZGTPPT1070-FLD_03,
         FLD_04     LIKE ZGTPPT1070-FLD_04,
         FLD_05     LIKE ZGTPPT1070-FLD_05,
         FLD_06     LIKE ZGTPPT1070-FLD_06,
         FLD_07     LIKE ZGTPPT1070-FLD_07,
         FLD_08     LIKE ZGTPPT1070-FLD_08,
         FLD_09     LIKE ZGTPPT1070-FLD_09,
         FLD_10     LIKE ZGTPPT1070-FLD_10,
         IFDAT      LIKE ZGTPPT1070-IFDAT,
         IFTIM      LIKE ZGTPPT1070-IFTIM,
         IFNAM      LIKE ZGTPPT1070-IFNAM,
       END OF GS_MAIN_DISP.
DATA : GT_MAIN_DISP LIKE TABLE OF GS_MAIN_DISP.

DATA : BEGIN OF GS_TARGET,
         FLD_01 TYPE ZGTPPT1010-FLD_01,
         FLD_02 TYPE ZGTPPT1010-FLD_02,
         FLD_03 TYPE ZGTPPT1010-FLD_03,
         FLD_04 TYPE ZGTPPT1010-FLD_04,
       END OF GS_TARGET.
DATA : GT_TARGET LIKE TABLE OF GS_TARGET.

DATA : BEGIN OF GS_OBJTY,
         FLD_01 TYPE ZGTPPT1010-FLD_01,
         FLD_02 TYPE ZGTPPT1010-FLD_02,
         FLD_03 TYPE ZGTPPT1010-FLD_03,
         FLD_04 TYPE ZGTPPT1010-FLD_04,
       END OF GS_OBJTY.
DATA : GT_OBJTY LIKE TABLE OF GS_OBJTY.

DATA : GT_WERKS TYPE RANGE OF WERKS_D.

*----------------------------------------------------------------------*
* DATA: Internal Table.
*----------------------------------------------------------------------*
DATA :   GT_ITAB     TYPE TTY_ITAB.
DATA : GT_OT_ITAB  TYPE TABLE OF ZGTPPSIF0037. "MES 전송용 테이블
DATA : GT_SEND TYPE TABLE OF ZGTPPT1070. "ALV 출력용 테이블 (전송 이력 조회)

*ALV GRID 100
DATA : GO_CONTAIN_0100 TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA : GO_GRID_0100 TYPE REF TO CL_GUI_ALV_GRID.
DATA : GS_VARIANT TYPE DISVARIANT.
DATA : GS_LAYOUT_0100 TYPE LVC_S_LAYO.
DATA : GT_EXCLUDE_0100 TYPE UI_FUNCTIONS.
DATA : GT_FIELDCAT_0100 TYPE LVC_T_FCAT.
