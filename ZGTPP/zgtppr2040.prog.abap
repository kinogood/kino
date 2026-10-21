*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2040
*& 프로그램 명 : [GT] 조장구성표번호 초기화 2025.02.04 by ZGSIDEV07
*& 개요   : 조장구성표 번호 넘버레인지 초기화
*& 생성일 : 2025.02.04
*& 생성자 : ZGSIDEV07
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
REPORT ZGTPPR2040   MESSAGE-ID ZGTPP00.

TABLES ZPPT0107.

INCLUDE ZGTPPR2040S01.
INCLUDE ZGTPPR2040F01.

AT SELECTION-SCREEN OUTPUT.

  PERFORM GET_PARAMETER_DESCRIPTION.
  PERFORM MODIFY_FIRST_SCREEN.

START-OF-SELECTION.


  DATA : LV_NR     LIKE  INRI-NRRANGENR.
  DATA : LS_NRIV  TYPE NRIV.
  DATA : LT_INTERVALS TYPE NRIV_TT.

  IF P_SPGCD IS NOT INITIAL.

    LV_NR = P_SPGCD.

    CALL FUNCTION 'NUMBER_GET_INFO'
      EXPORTING
        NR_RANGE_NR        = LV_NR
        OBJECT             = 'ZSPG'
      IMPORTING
        INTERVAL           = LS_NRIV
      EXCEPTIONS
        INTERVAL_NOT_FOUND = 1
        OBJECT_NOT_FOUND   = 2
        OTHERS             = 3.
    IF SY-SUBRC <> 0.
      MESSAGE E003 WITH '초기화중 오류 발생하였습니다.'(t01).
    ENDIF.

    APPEND LS_NRIV TO LT_INTERVALS.

    CALL FUNCTION 'NUMBER_RANGE_INTERVAL_INIT'
      EXPORTING
        INTERVALS         = LT_INTERVALS
      EXCEPTIONS
        NO_INTERVAL_FOUND = 1
        OBJECT_NOT_FOUND  = 2
        OTHERS            = 3.
    IF SY-SUBRC <> 0.
      MESSAGE E003 WITH '초기화중 오류 발생하였습니다.'(t01).
    ENDIF.
  ELSE.
    CALL FUNCTION 'NUMBER_RANGE_INTERVAL_INIT'
      EXPORTING
        OBJECT            = 'ZSPG'
      EXCEPTIONS
        NO_INTERVAL_FOUND = 1
        OBJECT_NOT_FOUND  = 2
        OTHERS            = 3.
  ENDIF.
  MESSAGE S003 WITH '초기화 완료되었습니다.'(t02).
