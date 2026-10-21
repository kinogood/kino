*&---------------------------------------------------------------------*
*& Include          ZGTSDR9007S01
*&---------------------------------------------------------------------*
  SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-T01. "조회조건
    SELECT-OPTIONS: S_VBELN FOR VBAP-VBELN. "판매문서

    SELECTION-SCREEN SKIP 1.
    PARAMETERS: P_BATCH AS CHECKBOX.
  SELECTION-SCREEN END OF BLOCK B1.
