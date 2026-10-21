*&---------------------------------------------------------------------*
*& Include          ZGTSDI0001SEL
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Selection-Screen
*----------------------------------------------------------------------*
"법인
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-S00.

  PARAMETERS : P_VKORG       TYPE VKORG OBLIGATORY MEMORY ID VKO DEFAULT '1000'.
  SELECT-OPTIONS : S_VTWEG   FOR VBAK-VTWEG  MEMORY ID VTW DEFAULT '10',
                   S_SPART   FOR VBAK-SPART OBLIGATORY MEMORY ID SPA DEFAULT '60',
                   S_BRANCH  FOR J_1BBRANCH-BRANCH,
                   S_VKBUR   FOR VBAK-VKBUR,
                   S_VKGRP   FOR VBAK-VKGRP,
                   S_VBEVL   FOR LIKP-VBELN,
                   S_WADAT   FOR LIKP-WADAT_IST,
                   S_KDKG4   FOR VBKD-KDKG4,
                   S_KUNNR   FOR VBAK-KUNNR,
                   S_LIFNR   FOR VBPA-LIFNR,
                   S_ERNAM   FOR VBAK-ERNAM,
                   S_ERDAT   FOR VBAK-ERDAT.

SELECTION-SCREEN END OF BLOCK B01.
