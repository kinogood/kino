*&---------------------------------------------------------------------*
*& Include          ZGTSDR1130SEL
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*                    SELECTION-SCREEN LAY-OUT                          *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1  WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: S_VKORG FOR KONA-VKORG
                      NO-EXTENSION  NO INTERVALS OBLIGATORY MEMORY ID VKO,  "영업조직
                  S_VTWEG FOR KONA-VTWEG
                      NO-EXTENSION NO INTERVALS OBLIGATORY MEMORY ID VTW,
                  S_SPART FOR KONA-SPART
                      NO-EXTENSION NO INTERVALS OBLIGATORY MEMORY ID SPA,

                  S_VKBUR FOR KONA-VKBUR NO-EXTENSION
                              NO INTERVALS OBLIGATORY MEMORY ID VKB,  "사업장
                  S_VKGRP FOR KONA-VKGRP NO-EXTENSION
                              NO INTERVALS OBLIGATORY MEMORY ID VKG,  "영업그룹
                  S_BONEM FOR KONA-BONEM OBLIGATORY,  "Agent 명
                  S_KNUMA FOR KONA-KNUMA
                              NO INTERVALS. "obligatory.  "계약NO

  PARAMETERS:     P_SPMON LIKE ZSDS004-FBUDA "DEFAULT SY-DATUM
                                             OBLIGATORY.  "기간

  SELECT-OPTIONS: S_BOSTA FOR KONA-BOSTA   DEFAULT 'D'
                                           OPTION NE SIGN I.  "계약상태


  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT  (31) TEXT-003.
    PARAMETERS: P_R01    AS CHECKBOX DEFAULT 'X'.
  SELECTION-SCREEN END OF LINE.

*  SELECTION-SCREEN SKIP 1.

  SELECT-OPTIONS: S_FKDAT FOR VBRK-FKDAT  MODIF ID ZX1.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT  (31) TEXT-006 MODIF ID ZX1.
  SELECTION-SCREEN END OF LINE.

*  SELECTION-SCREEN SKIP 1.


*-- TEXT: '아카이브 데이터 포함'
  PARAMETERS: P_ARCV AS CHECKBOX.

  SELECTION-SCREEN SKIP 1.

  PARAMETERS: P_MODE TYPE CTU_MODE DEFAULT 'N'.

SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-002.
  PARAMETERS : P_VARI    LIKE DISVARIANT-VARIANT.
SELECTION-SCREEN END OF BLOCK B2.
