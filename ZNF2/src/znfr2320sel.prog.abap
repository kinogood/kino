*&---------------------------------------------------------------------*
*& Include          ZNFR2320SEL
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
PARAMETERS     : P_BUKRS LIKE ZNFT1020-BUKRS OBLIGATORY MEMORY ID BUK.
SELECT-OPTIONS : S_FCM   FOR  ZNFT1020-FCM,
                 S_NFKEY FOR  ZNFT1020-NFKEY,
                 S_SHFNO FOR  ZNFT1040-SHFNO,
                 S_ERDAT FOR  ZNFT1040-ERDAT,
                 S_ENDAT FOR  ZNFT1020-ENDAT,
                 S_REMON FOR  ZNFT1041-REMON,
                 S_PRCTR FOR  ZNFT1000-PRCTR,
                 S_VKGRP FOR  ZNFT1000-VKGRP,
                 S_NFUTN FOR  ZNFT1020-NFUTN,
                 S_REQNO FOR  ZNFT1010-REQNO,
                 S_CONNO FOR  ZNFT1011-CONNO.
SELECTION-SCREEN END   OF BLOCK BLK1.

*___Buy/Sell 구분
SELECTION-SCREEN BEGIN OF BLOCK BLK2 WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS     : P_CHK01 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (10) TEXT-011 FOR FIELD P_CHK01.
PARAMETERS     : P_CHK02 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (10) TEXT-012 FOR FIELD P_CHK02.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BLK2.
