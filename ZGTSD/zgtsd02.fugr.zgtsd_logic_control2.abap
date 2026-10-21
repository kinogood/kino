FUNCTION ZGTSD_LOGIC_CONTROL2.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_DATE) TYPE  DATS
*"     VALUE(I_TIME) TYPE  TIMS DEFAULT SY-TIMLO
*"     REFERENCE(I_VKORG) TYPE  VKORG
*"     VALUE(I_VKBUR) TYPE  VKBUR OPTIONAL
*"     VALUE(I_VTWEG) TYPE  VTWEG OPTIONAL
*"     VALUE(I_SPART) TYPE  SPART OPTIONAL
*"     VALUE(I_WERKS) TYPE  WERKS_D OPTIONAL
*"     VALUE(I_CODE) TYPE  ZGTECODEGRP OPTIONAL
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
  DATA : LR_VKBUR TYPE RANGE OF ZGTE_FLDVAL,
         LR_SPART TYPE RANGE OF ZGTE_FLDVAL,
         LR_VTWEG TYPE RANGE OF ZGTE_FLDVAL,
         LR_WERKS TYPE RANGE OF ZGTE_FLDVAL,
         LR_CDGRP TYPE RANGE OF ZGTE_FLDVAL.

  CLEAR : LR_VKBUR, LR_SPART, LR_WERKS, LR_VTWEG,
          E_ACTIVE.

  CHECK I_DATE IS NOT INITIAL.

*-----------------------------------------------------------------------
*-- 2. 로직 구성
*-----------------------------------------------------------------------
*-- 조회조건 기준 Range 변수 구성
  IF I_VKBUR IS NOT INITIAL.
    APPEND VALUE #(
                    SIGN   = GC_SIGN-I
                    OPTION = GC_OPTN-EQ
                    LOW    = I_VKBUR
                  ) TO LR_VKBUR.
  ENDIF.

  IF I_SPART IS NOT INITIAL.
    APPEND VALUE #(
                    SIGN   = GC_SIGN-I
                    OPTION = GC_OPTN-EQ
                    LOW    = I_SPART
                  ) TO LR_SPART.
  ENDIF.

  IF I_VTWEG IS NOT INITIAL.
    APPEND VALUE #(
                    SIGN   = GC_SIGN-I
                    OPTION = GC_OPTN-EQ
                    LOW    = I_VTWEG
                  ) TO LR_VTWEG.
  ENDIF.

  IF I_WERKS IS NOT INITIAL.
    APPEND VALUE #(
                    SIGN   = GC_SIGN-I
                    OPTION = GC_OPTN-EQ
                    LOW    = I_WERKS
                  ) TO LR_WERKS.
  ENDIF.

  IF I_CODE IS NOT INITIAL.
    APPEND VALUE #(
                    SIGN   = GC_SIGN-I
                    OPTION = GC_OPTN-EQ
                    LOW    = I_CODE
                  ) TO LR_CDGRP.
  ELSE.
    APPEND VALUE #(
                    SIGN   = GC_SIGN-I
                    OPTION = GC_OPTN-EQ
                    LOW    = '9997'
                  ) TO LR_CDGRP.
  ENDIF.

*-- 입력 정보 기준 신규 로직 적용여부 Select
  WITH +CHK_LST AS ( SELECT CAST( A~FLD_06 AS DATS ) AS FROM_DT,
                            CAST( A~FLD_08 AS DATS ) AS TO_DT,
                            CAST( A~FLD_07 AS TIMS ) AS FROM_TIME,
                            CAST( A~FLD_09 AS TIMS ) AS TO_TIME

                       FROM ZGTPPT1010 AS A
                      WHERE A~MODULE_KIND EQ 'SD'
                        AND A~CODEGRP     IN @LR_CDGRP
                        AND A~FLD_01      EQ @I_VKORG
                        AND A~FLD_02      IN @LR_VKBUR
                        AND A~FLD_03      IN @LR_VTWEG
                        AND A~FLD_04      IN @LR_SPART
                        AND A~FLD_05      IN @LR_WERKS
                        )

    SELECT SINGLE FROM_DT, A~FROM_TIME
      FROM +CHK_LST AS A
     WHERE ( A~FROM_DT   LE @I_DATE )"AND
*             A~FROM_TIME LE @I_TIME )
       AND ( A~TO_DT     GE @I_DATE AND
             A~TO_TIME   GE @I_TIME )
      INTO @DATA(LS_TIME).

*-- 적용여부 결과 리턴
  IF SY-SUBRC EQ 0.
    IF I_DATE = LS_TIME-FROM_DT AND I_TIME < LS_TIME-FROM_TIME .
      E_ACTIVE = 'N'.
    ELSE.
      E_ACTIVE = 'Y'.
    ENDIF.
  ELSE.
    E_ACTIVE = 'N'.
  ENDIF.

ENDFUNCTION.
