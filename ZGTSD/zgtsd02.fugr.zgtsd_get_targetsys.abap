FUNCTION zgtsd_get_targetsys.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_VKORG) TYPE  VKORG OPTIONAL
*"     VALUE(I_VTWEG) TYPE  VTWEG OPTIONAL
*"     VALUE(I_SPART) TYPE  SPART OPTIONAL
*"     REFERENCE(I_VKBUR) TYPE  VKBUR
*"  EXPORTING
*"     VALUE(E_SYSID) TYPE  ZGTETARGET
*"     VALUE(ES_RETURN) TYPE  BAPIRET2
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : SD
*& 프로그램 ID : ZGTSD_GET_TARGETSYS
*& 프로그램 명 : [GT] Interface Target 시스템 구성
*& 개요   :
*& 생성일 : 2025.02.19
*& 생성자 : ZGSIDEV04
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*
*-----------------------------------------------------------------------
*-- 1. 로컬 데이터 선언
*-----------------------------------------------------------------------
  DATA : lv_vkorg TYPE vkorg,
         lv_vtweg TYPE vtweg,
         lv_spart TYPE spart.

  CLEAR : es_return, e_sysid.

*-----------------------------------------------------------------------
*-- 2. 입력값 정합성 체크
*-----------------------------------------------------------------------
  IF i_vkbur IS INITIAL.
*-- 영업팀 정보 없을경우 메세지 처리 & 리턴
    es_return = VALUE #(
                        type        = 'E'
                        id          = 'ZGTSD01'
                        number      = '007'
                        message_v1  = '영업팀'
                       ).

    PERFORM message_text_build      CHANGING es_return.

    RETURN.
  ENDIF.

*-----------------------------------------------------------------------
*-- 3. I/F Target 정보 구성
*-----------------------------------------------------------------------
*-- 3-1. 누락 영업정보 있을경우 영업팀 정보 기준 값 구성
  IF i_vkorg IS INITIAL OR
     i_vtweg IS INITIAL OR
     i_spart IS INITIAL.

    SELECT SINGLE a~vkorg,  a~vtweg,  a~spart
      FROM tvkbz AS a
     WHERE a~vkbur EQ @i_vkbur

      INTO @DATA(ls_sd_info).

  ENDIF.

  lv_vkorg = COND #( WHEN i_vkorg IS NOT INITIAL THEN i_vkorg
                     ELSE ls_sd_info-vkorg ).
  lv_vtweg = COND #( WHEN i_vtweg IS NOT INITIAL THEN i_vtweg
                     ELSE ls_sd_info-vtweg ).
  lv_spart = COND #( WHEN i_spart IS NOT INITIAL THEN i_spart
                     ELSE ls_sd_info-spart ).

*-- 3-2. 공통 코드 관리 정보 기준 I/F Target 시스템 정보 구성
  SELECT SINGLE a~fld_01
    FROM zgtppt1010 AS a
   WHERE a~fld_03      EQ @lv_vkorg
     AND a~fld_04      EQ @lv_vtweg
     AND a~fld_05      EQ @lv_spart
     AND a~module_kind EQ 'SD'
     AND a~codegrp     EQ '1010'

    INTO @e_sysid.

*-----------------------------------------------------------------------
*-- 4. 처리결과 리턴
*-----------------------------------------------------------------------
  IF e_sysid IS NOT INITIAL.
    es_return = VALUE #(
                        type        = 'S'
                        id          = 'ZGTSD01'
                        number      = '000'
                        message_v1  = TEXT-s02
                       ).
  ELSE.
    es_return = VALUE #(
                        type        = 'E'
                        id          = 'ZGTSD01'
                        number      = '010'
                       ).
  ENDIF.

  PERFORM message_text_build        CHANGING es_return.

ENDFUNCTION.
