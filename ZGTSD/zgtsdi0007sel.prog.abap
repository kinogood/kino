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

  SELECT-OPTIONS : S_DLVRQ  FOR ZLET0400-DLVRQ,
                   S_VKORG FOR ZLET0400-VKORG,
                   S_VTWEG FOR ZLET0400-VTWEG,
                   S_SPART FOR ZLET0400-SPART,
                   S_VSTEL FOR ZLET0400-VSTEL,
                   S_ERDAT FOR ZLET0400-ERDAT.

SELECTION-SCREEN END OF BLOCK B01.


PARAMETERS : p_call(1) NO-DISPLAY.
