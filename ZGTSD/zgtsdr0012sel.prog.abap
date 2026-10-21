*&---------------------------------------------------------------------*
*& Include          ZGTSDR0012SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-T01.
  SELECT-OPTIONS : S_VBELN FOR ZGTSDT0011-VBELN MATCHCODE OBJECT VMVA,
                   S_POSNR FOR ZGTSDT0011-POSNR,
                   S_CHARG FOR ZGTSDT0011-CHARG,
                   S_ERDAT FOR ZGTSDT0011-ERDAT OBLIGATORY.
SELECTION-SCREEN END OF BLOCK B1.
