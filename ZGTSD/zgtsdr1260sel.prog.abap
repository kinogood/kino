*&---------------------------------------------------------------------*
*& Include          ZGTSDR1260SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN FUNCTION KEY 1.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01. "업로드 파일

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT (31) TEXT-001 FOR FIELD p_file.
    PARAMETERS: p_file  LIKE rlgrap-filename.                 "파일경로
  SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK b1.
