*&---------------------------------------------------------------------*
*& Include          ZGTSDR0030SEL
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Selection-Screen
*----------------------------------------------------------------------*
"법인
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-S00.
  SELECT-OPTIONS : S_VBELN FOR VBAK-VBELN NO INTERVALS.
  PARAMETERS : P_VA02 TYPE CHAR1 AS CHECKBOX USER-COMMAND U02.

  PARAMETERS : P_PARA(49) MODIF ID UU1.
*  PARAMETERS : P_CHK TYPE CHAR1 AS CHECKBOX USER-COMMAND U01 MODIF ID UU1.
SELECTION-SCREEN END OF BLOCK B01.
