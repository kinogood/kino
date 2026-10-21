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

  SELECT-OPTIONS : S_VKBUR  FOR ZSDT_D365_020-VKBUR Obligatory No-Extension NO Intervals Default 1000,
                   S_PLTYPE FOR ZSDT_D365_020-PLTYPE No-Extension  NO Intervals,
                   S_CTYPE FOR ZSDT_D365_020-CYCLTYPE,
                   S_WEEK FOR ZSDT_D365_020-WEEK,
                   S_ERDAT FOR ZSDT_D365_020-ERDAT.

SELECTION-SCREEN END OF BLOCK B01.


PARAMETERS : p_call(1) NO-DISPLAY.
