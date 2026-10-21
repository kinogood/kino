*&---------------------------------------------------------------------*
*& Include          ZGTSDR1270SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK BL00 WITH FRAME.
  SELECT-OPTIONS: S_VKORG FOR KNVV-VKORG OBLIGATORY
                                         NO-EXTENSION NO INTERVALS
                                         MODIF ID ZM1,
                  S_VTWEG FOR KNVV-VTWEG OBLIGATORY
                                         NO-EXTENSION NO INTERVALS
                                         MODIF ID ZM1,
                  S_SPART FOR KNVV-SPART NO INTERVALS,
                  S_KUNN2 FOR KNVP-KUNN2 ,
                  S_KUNNR FOR KNVP-KUNNR .

  SELECTION-SCREEN SKIP 1.

  SELECTION-SCREEN BEGIN OF LINE .
    SELECTION-SCREEN POSITION 33.
    PARAMETERS: P_R01 RADIOBUTTON GROUP RG1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 34(10) TEXT-001 FOR FIELD P_R01.

    SELECTION-SCREEN POSITION 53.
    PARAMETERS: P_R02 RADIOBUTTON GROUP RG1.
    SELECTION-SCREEN COMMENT 54(7) TEXT-002 FOR FIELD P_R02.
  SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK BL00.
