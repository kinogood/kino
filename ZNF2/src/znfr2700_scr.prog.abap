*&---------------------------------------------------------------------*
*& Include          ZNFR2700_SCR
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-T01.
  PARAMETERS : P_BUKRS TYPE BUKRS OBLIGATORY MEMORY ID BUK,
               P_GJAHR TYPE GJAHR OBLIGATORY.

  SELECT-OPTIONS: S_ENDAT FOR ZNFT1020-ENDAT OBLIGATORY,  "만기일
                  S_NFKEY FOR ZNFT1051-NFKEY,             "비철구분
                  S_PRCTR FOR ZNFT1000-PRCTR,             "손익센터
                  S_VKGRP FOR ZNFT1000-VKGRP,             "영업그룹
                  S_NFCTR FOR ZNFT1000-NFCTR,             "사업부
                  S_ZPJNO FOR ZNFT1000-ZPJNO,             "Project NO
                  S_VBELN FOR VBAK-VBELN,                 "판매문서
                  S_ERDAT FOR VBAK-ERDAT,                 "오더생성일
                  S_NFUTN FOR ZNFT1020-NFUTN,             "신규선물집행번호
                  S_CFUTN FOR ZNFT1030-CFUTN,             "청산선물집행번호
                  S_CONNO FOR ZNFT1011-CONNO.             "계약번호

SELECTION-SCREEN END OF BLOCK B1.
