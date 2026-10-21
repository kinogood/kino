FUNCTION ZGTSD_EXIT_CONTROL.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_PROG) TYPE  SY-CPROG OPTIONAL
*"     VALUE(I_PERFORM) TYPE  SY-CPROG OPTIONAL
*"     VALUE(I_VKORG) TYPE  VKORG OPTIONAL
*"     VALUE(I_VTWEG) TYPE  VTWEG OPTIONAL
*"     VALUE(I_SPART) TYPE  SPART OPTIONAL
*"     VALUE(I_VKBUR) TYPE  VKBUR OPTIONAL
*"     VALUE(I_WERKS) TYPE  WERKS_D OPTIONAL
*"     VALUE(I_AUART) TYPE  AUART OPTIONAL
*"     VALUE(I_LFART) TYPE  LFART OPTIONAL
*"     VALUE(I_FKART) TYPE  FKART OPTIONAL
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
  DATA : LR_VKORG TYPE RANGE OF ZGTE_FLDVAL,
         LR_SPART TYPE RANGE OF ZGTE_FLDVAL,
         LR_VKBUR TYPE RANGE OF ZGTE_FLDVAL,
         LR_VTWEG TYPE RANGE OF ZGTE_FLDVAL,
         LR_WERKS TYPE RANGE OF ZGTE_FLDVAL,
         LR_AUART TYPE RANGE OF ZGTE_FLDVAL,
         LR_LFART TYPE RANGE OF ZGTE_FLDVAL,
         LR_PROG   TYPE RANGE OF ZGTE_FLDVAL,
         LR_PERF  TYPE RANGE OF ZGTE_FLDVAL,
         LR_FKART TYPE RANGE OF ZGTE_FLDVAL.

  CLEAR : LR_VKORG, LR_SPART, LR_AUART,
          E_ACTIVE.

*-----------------------------------------------------------------------
*-- 2. 로직 구성
*-----------------------------------------------------------------------
*-- 조회조건 기준 Range 변수 구성

  IF I_PROG IS NOT INITIAL.
    APPEND VALUE #(
                    SIGN   = GC_SIGN-I
                    OPTION = GC_OPTN-EQ
                    LOW    = I_PROG
                  ) TO LR_PROG.
  ENDIF.

  IF I_PERFORM IS NOT INITIAL.
    APPEND VALUE #(
                    SIGN   = GC_SIGN-I
                    OPTION = GC_OPTN-EQ
                    LOW    = I_PERFORM
                  ) TO LR_PERF.
  ENDIF.


  IF I_VKORG IS NOT INITIAL.
    APPEND VALUE #(
                    SIGN   = GC_SIGN-I
                    OPTION = GC_OPTN-EQ
                    LOW    = I_VKORG
                  ) TO LR_VKORG.
  ENDIF.

  IF I_VTWEG IS NOT INITIAL.
    APPEND VALUE #(
                    SIGN   = GC_SIGN-I
                    OPTION = GC_OPTN-EQ
                    LOW    = I_VTWEG
                  ) TO LR_VTWEG.
  ENDIF.

  IF I_SPART IS NOT INITIAL.
    APPEND VALUE #(
                    SIGN   = GC_SIGN-I
                    OPTION = GC_OPTN-EQ
                    LOW    = I_SPART
                  ) TO LR_SPART.
  ENDIF.

  IF I_VKBUR IS NOT INITIAL.
    APPEND VALUE #(
                    SIGN   = GC_SIGN-I
                    OPTION = GC_OPTN-EQ
                    LOW    = I_VKBUR
                  ) TO LR_VKBUR.
  ENDIF.

  IF I_WERKS IS NOT INITIAL.
    APPEND VALUE #(
                    SIGN   = GC_SIGN-I
                    OPTION = GC_OPTN-EQ
                    LOW    = I_WERKS
                  ) TO LR_WERKS.
  ENDIF.

  IF I_AUART IS NOT INITIAL.
    APPEND VALUE #(
                    SIGN   = GC_SIGN-I
                    OPTION = GC_OPTN-EQ
                    LOW    = I_AUART
                  ) TO LR_AUART.
  ENDIF.

  IF I_LFART IS NOT INITIAL.
    APPEND VALUE #(
                    SIGN   = GC_SIGN-I
                    OPTION = GC_OPTN-EQ
                    LOW    = I_LFART
                  ) TO LR_LFART.
  ENDIF.

  IF I_FKART IS NOT INITIAL.
    APPEND VALUE #(
                    SIGN   = GC_SIGN-I
                    OPTION = GC_OPTN-EQ
                    LOW    = I_FKART
                  ) TO LR_FKART.
  ENDIF.

*-- 입력 정보 기준 신규 로직 적용여부 Select
  SELECT SINGLE MANDT INTO @SY-MANDT
    FROM ZGTPPT1010 AS A
   WHERE A~MODULE_KIND EQ 'SD'
     AND A~CODEGRP     EQ '5008'
     AND A~FLD_01      IN @LR_PROG
     AND A~FLD_02      IN @LR_PERF
     AND A~FLD_03      IN @LR_VKORG
     AND A~FLD_04      IN @LR_VTWEG
     AND A~FLD_05      IN @LR_SPART
     AND A~FLD_06      IN @LR_VKBUR
     AND A~FLD_07      IN @LR_WERKS
     AND A~FLD_08      IN @LR_AUART
     AND A~FLD_09      IN @LR_LFART
     AND A~FLD_10      IN @LR_FKART.
*-- 적용여부 결과 리턴
  IF SY-SUBRC EQ 0.
    E_ACTIVE = 'Y'.
  ELSE.
    E_ACTIVE = 'N'.
  ENDIF.

ENDFUNCTION.
