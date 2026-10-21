FUNCTION ZGTSD_GET_ZZYUSCD.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_VKORG) TYPE  VKORG DEFAULT '6000'
*"     VALUE(I_VKGRP) TYPE  VKGRP
*"     VALUE(I_KDKG4) TYPE  KDKG4
*"  EXPORTING
*"     VALUE(E_ZZYUSCD) TYPE  ZGTEYUSCD
*"     VALUE(E_TYPE) TYPE  BAPI_MTYPE
*"     VALUE(E_MSG) TYPE  BAPI_MSG
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&  모듈       : SD
*&  프로그램 ID : ZGTSD_GET_ZZYUSCD
*&  프로그램 명  : 영업그룹별 영업소 결정
*&  개요       : 가온전선_영업그룹별 영업소 결정
*&  생성일      : 2026.01.13
*&  생성자      : ZGODEV01
*&---------------------------------------------------------------------*
*& 외부호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*----------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*

*-01. 입력값 체크
  IF I_VKORG IS INITIAL.
    I_VKORG = '6000'.
  ENDIF.

  IF I_VKGRP IS INITIAL.
    E_TYPE = 'E'.
    MESSAGE S007(ZGTSD01) WITH TEXT-001 INTO E_MSG.
    EXIT.
  ENDIF.

  IF I_KDKG4 IS INITIAL.
    E_TYPE = 'E'.
    MESSAGE S007(ZGTSD01) WITH TEXT-002 INTO E_MSG.
    EXIT.
  ENDIF.

*-02. 영업그룸+고객조건그룹4
  SELECT SINGLE ZZYUSCD
    FROM ZGTSDT1103
   WHERE VKORG EQ @I_VKORG
     AND VKGRP EQ @I_VKGRP
     AND KDKG4 EQ @I_KDKG4
     AND LOEVM EQ @SPACE
    INTO @DATA(LV_ZZYUSCD).
  IF LV_ZZYUSCD IS NOT INITIAL.
    E_ZZYUSCD = LV_ZZYUSCD.
    E_TYPE    = 'S'.
    E_MSG     = TEXT-S01.

  ELSE.
    SELECT SINGLE ZZYUSCD
      FROM ZGTSDT1104
     WHERE VKORG EQ @I_VKORG
       AND VKGRP EQ @I_VKGRP
       AND LOEVM EQ @SPACE
      INTO @LV_ZZYUSCD.
    IF LV_ZZYUSCD IS NOT INITIAL.
      E_ZZYUSCD = LV_ZZYUSCD.
      E_TYPE    = 'S'.
      E_MSG     = TEXT-S01.
    ELSE.
      E_TYPE    = 'E'.
      E_MSG     = TEXT-M60.
    ENDIF.
  ENDIF.



ENDFUNCTION.
