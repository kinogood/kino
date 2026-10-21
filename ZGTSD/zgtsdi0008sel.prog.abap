*&---------------------------------------------------------------------*
*& Include          ZGTSDI0001SEL
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Selection-Screen
*----------------------------------------------------------------------*
"법인


SELECTION-SCREEN BEGIN OF BLOCK B03 WITH FRAME TITLE TEXT-S01.
Parameters :  P_TARG LIKE ZGTSDT1003-ZSYSTEM_ID Obligatory Default 'KSCM'.
SELECTION-SCREEN END OF BLOCK B03.


SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-S00.

PARAMETERS : P_MONTH LIKE ZSDT_SNOP_010-ZZMONTH OBLIGATORY.
*                 S_TYPE FOR ZSDT_SNOP_010-CPTYPE,
*                 S_PART FOR ZSDT_SNOP_010-PARTNER,
*                 S_ERDAT FOR ZSDT_SNOP_010-ERDAT.



SELECTION-SCREEN END OF BLOCK B01.


PARAMETERS : p_call(1) NO-DISPLAY.
