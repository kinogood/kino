FUNCTION-POOL ZGTMM11.                      "MESSAGE-ID ..
* INCLUDE LZGTMM10D...                       " LOCAL CLASS DEFINITION

*GLOBAL DATA_전역변수
DATA :
GT_RETURN   LIKE TABLE OF BAPIRET2.

DATA :
GS_RETURN   LIKE  BAPIRET2,
GS_MSG         LIKE ZGTMMS1002.

DATA :
GV_SYSTEM_ID TYPE ZGTE_IF_TARGET,
GV_BUDAT LIKE MATDOC-BUDAT.

DATA :
GV_TYPE TYPE C,
GV_TIM(6) TYPE C,
GV_DAT(8) TYPE C.

*CONSTANTS_상수
CONSTANTS :
GC_A(1)      VALUE 'A',
GC_B(1)      VALUE 'B',
GC_C(1)      VALUE 'C',
GC_D(1)      VALUE 'D',
GC_E(1)      VALUE 'E',
GC_I(1)        VALUE 'I',
GC_N(1)      VALUE 'N',
GC_S(1)      VALUE 'S',
GC_T(1)      VALUE 'T',
GC_W(1)      VALUE 'W',
GC_X(1)      VALUE 'X',
GC_Y(1)      VALUE 'Y',
GC_1(1)      VALUE '1',
GC_3(1)      VALUE '3',
GC_BT(2)  VALUE 'BT',
GC_EQ(2)  VALUE 'EQ',
GC_AB(2)    VALUE 'AB',
GC_AU(2)    VALUE 'AU',
GC_OK(2)    VALUE 'OK',
GC_00(2)     VALUE '00',
GC_01(2)     VALUE '01',
GC_02(2)     VALUE '02',
GC_000(3)    VALUE '000',
GC_0001(4)  VALUE '0001'.

TYPES :
BEGIN OF TY_4513,
 EBELN TYPE EBELN,
END OF TY_4513,
BEGIN OF TY_4514,
 VBELN TYPE VBELN,
END OF TY_4514,
BEGIN OF TY_4515,
 ZDOC_NO TYPE ZGTMMS4515-ZDOC_NO,
END OF TY_4515.

TYPES :
   TY_T_4513 TYPE STANDARD TABLE OF TY_4513,
   TY_T_4514 TYPE STANDARD TABLE OF TY_4514,
   TY_T_4515 TYPE STANDARD TABLE OF TY_4515.

*MACRO
DEFINE _RANGES.
  DATA LR_RANGE TYPE FC00_S_RANGE.

  LR_RANGE-SIGN      = 'I'.
  LR_RANGE-OPTION  = &1.
  LR_RANGE-LOW      = &2.
  LR_RANGE-HIGH      = &3.
  APPEND LR_RANGE TO &4.

END-OF-DEFINITION.

DEFINE _SET_SPACE.

  CLEAR : GV_TYPE, GV_DAT, GV_TIM.

  DESCRIBE FIELD &1 TYPE GV_TYPE.

  IF GV_TYPE = GC_D.
    IF &1 = '00000000'.
       GV_DAT = SPACE.
       &1 = GV_DAT.
    ENDIF.

  ELSEIF GV_TYPE = GC_T.
    IF &1 = '000000'.
      GV_TIM = SPACE.
      &1 = GV_TIM.
    ENDIF.

  ENDIF.

END-OF-DEFINITION.


*----------------------------------------------------------------------*
* ZGTMM_IF_O_PO_SRM "구매오더 정보 전송(SAP->G-SRM)
*----------------------------------------------------------------------*
DATA :
GS_1003 LIKE ZGTMMS1003.

*----------------------------------------------------------------------*
* ZGTMM_IF_O_DDEV_STAT "직송의뢰진행상태조회(SAP->G-SRM)
*----------------------------------------------------------------------*
RANGES :
GR_EBELN FOR ZGTMMS4513-EBELN,
GR_VBELN FOR ZGTMMS4514-VBELN,
GR_DOC    FOR ZGTMMS4515-ZDOC_NO.
