*&---------------------------------------------------------------------*
*& Include          ZGTSDR9002SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN FUNCTION KEY 1.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-T01. "업로드 파일
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT (31) TEXT-001 FOR FIELD P_FILE.
    PARAMETERS: P_FILE  LIKE RLGRAP-FILENAME.                 "파일경로
  SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK B1.
