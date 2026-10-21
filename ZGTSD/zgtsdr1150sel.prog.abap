*&---------------------------------------------------------------------*
*& Include          ZGTSDR1150SEL
*&---------------------------------------------------------------------*
*--------------------------------------------------------------------*
*   SELECTION SCREEN                                                 *
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.

  PARAMETER : PA_VKORG LIKE VBRK-VKORG OBLIGATORY MEMORY ID VKO.

  SELECT-OPTIONS: PA_VTWEG FOR KONA-VTWEG OBLIGATORY MEMORY ID VTW,
                  PA_SPART FOR KONA-SPART OBLIGATORY MEMORY ID SPA,
                  PA_VKBUR FOR KONA-VKBUR OBLIGATORY MEMORY ID VKB,
                  PA_VKGRP FOR KONA-VKGRP OBLIGATORY MEMORY ID VKG.

  SELECT-OPTIONS : SO_BONEM FOR KONA-BONEM,     " Agent 명
                   SO_KNUMA FOR KONA-KNUMA.     " 계약NO

  PARAMETER : PA_SPMON LIKE ZSDS004-FBUDA DEFAULT SY-DATUM
                                          OBLIGATORY.  "기간

  SELECTION-SCREEN SKIP 1.
*-- TEXT: '아카이브 데이터 포함'
  PARAMETER : P_ARCV AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK B1.


SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-003.

  PARAMETERS: P_VARI    LIKE DISVARIANT-VARIANT.

SELECTION-SCREEN END OF BLOCK B2.
