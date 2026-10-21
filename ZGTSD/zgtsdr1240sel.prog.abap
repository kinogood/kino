*&---------------------------------------------------------------------*
*& Include          ZGTSDR1240SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK BL00 WITH FRAME.
  SELECT-OPTIONS: S_VKORG FOR VBAK-VKORG OBLIGATORY NO-EXTENSION NO INTERVALS
                                         MODIF ID ZM1.
  PARAMETERS    : P_RELTYP LIKE BURS_JOEL_MAIN-DIRECTED_TYPE_C AS LISTBOX
                      VISIBLE LENGTH 30 MODIF ID ZM2.
SELECTION-SCREEN END OF BLOCK BL00.
