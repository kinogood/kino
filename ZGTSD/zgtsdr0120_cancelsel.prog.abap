*&---------------------------------------------------------------------*
*& Include          ZGTSDR0120_CANCELSEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-S00.

  PARAMETERS : P_VBELN TYPE VBELN OBLIGATORY,
               P_BUDAT TYPE PODAT,
               P_MBLNR TYPE MBLNR,
               P_TCODE TYPE SY-TCODE,
               P_VBTYP TYPE VBTYPL,
               P_MJAHR TYPE MJAHR.


SELECTION-SCREEN END OF BLOCK B01.
