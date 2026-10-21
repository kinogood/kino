FUNCTION ZGTSD_DETER_CCA_BY_SALESGRP.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_VKORG) TYPE  VKORG OPTIONAL
*"     VALUE(I_VKGRP) TYPE  VKGRP OPTIONAL
*"  EXPORTING
*"     VALUE(E_KKBER) TYPE  KKBER
*"     VALUE(E_TYPE) TYPE  BAPI_MTYPE
*"     VALUE(E_MSG) TYPE  BAPI_MSG
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&  모듈       : SD
*&  프로그램 ID : ZGTSD_DETER_CCA_BY_SALESGRP
*&  프로그램 명  : 영업그룹별 CCA 결정
*&  개요       : 가온전선_재무에서 수금시 영업조직/영업그룹별로 여신관리영역을 추출할때 사용한다
*&  생성일      : 2026.01.29
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

*-01. CHECK INPUT VALUE
  IF NOT ( I_VKORG IS NOT INITIAL AND
           I_VKGRP IS NOT INITIAL     ).
    E_TYPE = GC_E.
    DATA(LV_MSG) = |{ TEXT-013 }/{ TEXT-014 }|.
    MESSAGE S007 WITH LV_MSG INTO E_MSG.
    EXIT.
  ENDIF.

*-02. 여신관리영역
  SELECT SINGLE KKBER
    FROM ZGTSDT1012
   WHERE VKORG EQ @I_VKORG
     AND VKGRP EQ @I_VKGRP
     AND LOEVM EQ @SPACE
    INTO @DATA(LV_KKBER).
  IF LV_KKBER IS NOT INITIAL.
    E_TYPE = GC_S.
    E_MSG  = TEXT-S01.

    E_KKBER = LV_KKBER.

  ELSE.
    E_TYPE = GC_E.
    E_MSG  = TEXT-M59.
  ENDIF.

ENDFUNCTION.
