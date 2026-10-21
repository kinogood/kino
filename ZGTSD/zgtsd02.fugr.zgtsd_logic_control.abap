FUNCTION zgtsd_logic_control.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_DATE) TYPE  DATS
*"     VALUE(I_TIME) TYPE  TIMS DEFAULT SY-TIMLO
*"     VALUE(I_VKBUR) TYPE  VKBUR OPTIONAL
*"     VALUE(I_SPART) TYPE  SPART OPTIONAL
*"     VALUE(I_WERKS) TYPE  WERKS_D OPTIONAL
*"  EXPORTING
*"     VALUE(E_ACTIVE) TYPE  CHAR01
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : SD
*& 프로그램 ID : ZGTSD_LOGIC_CONTROL
*& 프로그램 명 : [GT] 신규 로직 적용시점 관리
*& 개요   :
*& 생성일 : 2025.04.21
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
  DATA : lr_vkbur TYPE RANGE OF zgte_fldval,
         lr_spart TYPE RANGE OF zgte_fldval,
         lr_werks TYPE RANGE OF zgte_fldval.

  CLEAR : lr_vkbur, lr_spart, lr_werks,
          e_active.

  CHECK i_date IS NOT INITIAL.

*-----------------------------------------------------------------------
*-- 2. 로직 구성
*-----------------------------------------------------------------------
*-- 조회조건 기준 Range 변수 구성
  IF i_vkbur IS NOT INITIAL.
    APPEND VALUE #(
                    sign   = gc_sign-i
                    option = gc_optn-eq
                    low    = i_vkbur
                  ) TO lr_vkbur.
  ENDIF.

  IF i_spart IS NOT INITIAL.
    APPEND VALUE #(
                    sign   = gc_sign-i
                    option = gc_optn-eq
                    low    = i_spart
                  ) TO lr_spart.
  ENDIF.

  IF i_werks IS NOT INITIAL.
    APPEND VALUE #(
                    sign   = gc_sign-i
                    option = gc_optn-eq
                    low    = i_werks
                  ) TO lr_werks.
  ENDIF.

*-- 입력 정보 기준 신규 로직 적용여부 Select
  WITH +chk_lst AS ( SELECT CAST( a~fld_04 AS DATS ) AS from_dt,
                            CAST( a~fld_06 AS DATS ) AS to_dt,
                            CAST( a~fld_05 AS TIMS ) AS from_time,
                            CAST( a~fld_07 AS TIMS ) AS to_time

                       FROM zgtppt1010 AS a
                      WHERE a~module_kind EQ 'SD'
                        AND a~codegrp     EQ '9998'

                        AND a~fld_01      IN @lr_vkbur
                        AND a~fld_02      IN @lr_spart
                        AND a~fld_03      IN @lr_werks )

    SELECT SINGLE @abap_true
      FROM +chk_lst AS a
     WHERE ( a~from_dt   LE @i_date AND
             a~from_time LE @i_time )
       AND ( a~to_dt     GE @i_date AND
             a~to_time   GE @i_time )

      INTO @DATA(lv_chk).

*-- 적용여부 결과 리턴
  IF sy-subrc EQ 0.
    e_active = 'Y'.
  ELSE.
    e_active = 'N'.
  ENDIF.

ENDFUNCTION.
