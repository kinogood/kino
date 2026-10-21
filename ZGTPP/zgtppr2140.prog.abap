*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2140
*& 프로그램 명 : [GT] 조장 구성표 관리 GAON 2025.12.09 by ZGSIDEV07
*& 개요   : 완제품 설계서를 기준으로 생산 및 외주 가공을 진행해야 하는 공정을 확인하여 공정별 조장 출력
*              공정은 자재별 지정되지 않고 복수의 자재가 하나의 공정에 출력되어 관리
*              하나의 공정에 컬러 등으로 인해 복수 자재 관리 필요"
*& 생성일 : 2025.12.09
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
REPORT ZGTPPR2140 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR2140TOP.
INCLUDE ZGTPPR2140S01.
INCLUDE ZGTPPR2140C01.
INCLUDE ZGTPPR2140F01.
INCLUDE ZGTPPR2140O01.
INCLUDE ZGTPPR2140I01.


INITIALIZATION.
  PERFORM SET_INIT_TITLE.
  PERFORM SET_BUTTON.

AT SELECTION-SCREEN OUTPUT.
  PERFORM GET_PARAMETER_DESCRIPTION.
  PERFORM MODIFY_FIRST_SCREEN.

AT SELECTION-SCREEN.
  CASE SY-UCOMM.
    WHEN 'FC01'.
      PERFORM CALL_MAINTAIN_VIEW.
  ENDCASE.

START-OF-SELECTION.
  PERFORM AUTHORITY_CHECKING_PROC.
  PERFORM GET_PROC.
  CALL SCREEN 0100.
