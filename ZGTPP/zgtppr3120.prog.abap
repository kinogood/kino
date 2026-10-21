*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR3120
*& 프로그램 명 : [GT] 실시간 예상 재고 모니터링
*& 개요   : 실시간 예상 재고 모니터링 Report로
*&          품목별 예상 재고, 수요, 공급 정보를 확인하고
*&          예상 재고가 부족시에 구매 제안 수량을 확인하여
*&          PR, PO를 생성한다
*& 생성일 : 2025.03.27
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
REPORT ZGTPPR3120  MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR3120TOP.
INCLUDE ZGTPPR3120S01.
INCLUDE ZGTPPR3120C01.
INCLUDE ZGTPPR3120I01.
INCLUDE ZGTPPR3120O01.
INCLUDE ZGTPPR3120F01.

INITIALIZATION.
  PERFORM INITIALIZATION.

AT SELECTION-SCREEN OUTPUT.
  PERFORM GET_PARAMETER_DESCRIPTION.
  PERFORM MODIFY_FIRST_SCREEN.
  PERFORM SET_INIT_DATE.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_MTART-LOW.
*  PERFORM F4_MTART USING 'S_MTART-LOW'.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_WEEK-HIGH.
*  PERFORM F4_WEEK USING S_WEEK-HIGH.

*AT SELECTION-SCREEN ON S_WEEK.
*
*  CHECK P_YEAR IS NOT INITIAL.
*  PERFORM CHECK_AVAILABLE_WEEK USING 'S_WEEK-LOW'.
*
*  IF S_WEEK-HIGH IS NOT INITIAL.
*    PERFORM CHECK_AVAILABLE_WEEK USING 'S_WEEK-HIGH'.
*  ENDIF.

START-OF-SELECTION.
  PERFORM AUTHORITY_CHECKING_PROC.
  PERFORM CHK_DATE.
  PERFORM INIT_DATA.
  PERFORM PROC_GET_DATA.

END-OF-SELECTION.
  PERFORM PROC_DISPLAY.
