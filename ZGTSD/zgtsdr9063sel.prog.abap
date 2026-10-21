*&---------------------------------------------------------------------*
*& Include          ZGTSDR9063SEL
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Selection-Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-S00.
  PARAMETERS : P_SYSID  TYPE ZGTETARGET,
               P_VBELN  TYPE VBELN_VA,
               P_WERKS  TYPE WERKS_D,
               P_JOB_NO TYPE CHAR30,
               P_ZATT1  TYPE CHAR100,
               P_ZATT2  TYPE CHAR100,
               P_ZATT3  TYPE CHAR100,
               P_CHG_F  TYPE CHAR01 AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK B01.
