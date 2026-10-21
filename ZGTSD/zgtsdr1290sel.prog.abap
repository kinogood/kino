*&---------------------------------------------------------------------*
*& Include          ZGTSDR1290SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK BL00 WITH FRAME.
  SELECT-OPTIONS: S_KTOKD FOR KNA1-KTOKD OBLIGATORY NO INTERVALS
                                         MODIF ID ZM1,
                  S_BUKRS FOR KNB1-BUKRS OBLIGATORY NO-EXTENSION NO INTERVALS
                                         MODIF ID ZM1.
SELECTION-SCREEN END OF BLOCK BL00.
