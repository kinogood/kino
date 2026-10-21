*&---------------------------------------------------------------------*
*& Include          ZGTSDR1120SEL
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*

  SELECTION-SCREEN BEGIN OF BLOCK B1  WITH FRAME TITLE TEXT-001.

    SELECTION-SCREEN SKIP 1.
    PARAMETERS: PA_VKORG LIKE VBAK-VKORG MEMORY ID VKO OBLIGATORY,    " 영업조직
                PA_VTWEG LIKE VBAK-VTWEG MEMORY ID VTW OBLIGATORY,    " 유통경로
                PA_SPART LIKE VBAK-SPART MEMORY ID SPA OBLIGATORY,    " 제품군
                PA_VKBUR LIKE VBAK-VKBUR MEMORY ID VKB OBLIGATORY,    " 사업장
                PA_VKGRP LIKE VBAK-VKGRP MEMORY ID VKG OBLIGATORY,    " 영업그룹
                PA_DATE  LIKE SY-DATUM   OBLIGATORY.                  " 정산일

    SELECT-OPTIONS: SO_BONEM FOR ZKONA-BONEM  NO-EXTENSION NO INTERVALS OBLIGATORY,  "AGENT 명
                    SO_KNUMA FOR ZKONA-KNUMA  NO-EXTENSION NO INTERVALS OBLIGATORY,  "계약NO
                    SO_FKDAT FOR VBRK-FKDAT  OBLIGATORY.                             "매출일자


    SELECTION-SCREEN SKIP 1.

    SELECTION-SCREEN BEGIN OF LINE.
      SELECTION-SCREEN COMMENT  1(31) TEXT-011.
      PARAMETERS: P_R1    RADIOBUTTON GROUP RA03  DEFAULT 'X'.
      SELECTION-SCREEN COMMENT  35(20) TEXT-012.
      PARAMETERS: P_R2    RADIOBUTTON GROUP RA03.
      SELECTION-SCREEN COMMENT  58(20) TEXT-013.
    SELECTION-SCREEN END OF LINE.


  SELECTION-SCREEN END OF BLOCK B1.
