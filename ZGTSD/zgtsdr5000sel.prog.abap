*&---------------------------------------------------------------------*
*& Include          ZGTSDR0000SEL
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Selection-Screen
*----------------------------------------------------------------------*
"법인
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-S00.

  "영업조직
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT (10) TEXT-S01 FOR FIELD P_VKORG.
    SELECTION-SCREEN POSITION 33.
    PARAMETERS : P_VKORG TYPE VBAK-VKORG.
    SELECTION-SCREEN POSITION 40.
    PARAMETERS : P_VTEXT TYPE VTXTK.
  SELECTION-SCREEN END OF LINE.

  SELECT-OPTIONS : S_AUART FOR VBAK-AUART,
                   S_VKBUR FOR VBAK-VKBUR NO INTERVALS ,
                   S_VBELN FOR VBAP-VBELN NO INTERVALS NO-EXTENSION,
                   "S_MATNR FOR VBAP-MATNR,
                   S_UDATE FOR CDHDR-UDATE NO-EXTENSION.
*  PARAMETERS : P_UDATE TYPE CDHDR-UDATE.

*  PARAMETERS : P_FLAG TYPE CDPOS-CHNGIND.

SELECTION-SCREEN END OF BLOCK B01.
