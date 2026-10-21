*&---------------------------------------------------------------------*
*& Include          ZGTPPR9994S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.

  PARAMETERS : P_WERKS TYPE MARC-WERKS MEMORY ID WRK OBLIGATORY.
  SELECT-OPTIONS : S_MTART FOR MARA-MTART,
                      S_MATKL FOR MARA-MATKL,
                      S_MATNR FOR MARA-MATNR OBLIGATORY,
                      S_STLAN FOR MAST-STLAN,
                      S_STLAL FOR MAST-STLAL,
                      S_ANDAT FOR MAST-ANDAT NO-EXTENSION.

SELECTION-SCREEN END OF BLOCK B1.
