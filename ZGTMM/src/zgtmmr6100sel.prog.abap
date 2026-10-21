*&---------------------------------------------------------------------*
*& Include          ZGTSDI0001SEL
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Selection-Screen
*----------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-S00.

  PARAMETERS : P_WERKS TYPE EORD-WERKS MODIF ID M1.
  SELECT-OPTIONS : S_MATNR  FOR EORD-MATNR,
                   S_LIFNR  FOR EORD-LIFNR.
  PARAMETERS : P_VDATU TYPE EORD-VDATU.

SELECTION-SCREEN END OF BLOCK B01.

PARAMETERS : P_CALLD NO-DISPLAY. "공급업체 복사 기능 추가(PSJ 25.01.17)
