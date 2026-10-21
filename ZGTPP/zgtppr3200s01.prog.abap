*&---------------------------------------------------------------------*
*& Include          ZGTPPR3200S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-000.

  PARAMETERS:       GP_WERKS    TYPE AFRU-WERKS      OBLIGATORY
                                                     MEMORY ID WRK.
  SELECT-OPTIONS:   GS_WKDAT     FOR ZPPT0001-WKDAT NO-EXTENSION OBLIGATORY,
                    GS_TAGNR     FOR ZPPT0001-TAGNR,
                    GS_SPGCD     FOR ZPPT0001-SPGCD,
                    GS_PROCD     FOR ZPPT0001-PROCD,
                    GS_MATNR     FOR ZPPT0001-MATNR,
                    GS_AUFNR     FOR ZPPT0001-AUFNR,
                    GS_CHARG     FOR ZPPT0001-CHARG,
                    GS_KUNN1     FOR VBAK-KUNNR,
                    GS_KUNN2     FOR VBAK-KUNNR,
                    GS_KDAUF     FOR AFPO-KDAUF,
                    GS_KDPOS     FOR AFPO-KDPOS.

  SELECTION-SCREEN SKIP 1.
  PARAMETERS : P_ARCV AS CHECKBOX.

SELECTION-SCREEN: END   OF BLOCK B1.
