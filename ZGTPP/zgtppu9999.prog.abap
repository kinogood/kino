*&---------------------------------------------------------------------*
*& 모듈           : PP
*& 프로그램 ID : ZGTPPU9999
*& 프로그램 명 : [GT] 생산 업데이트 텍스트
*& 개요   :
*& 생성일 : 2024.12.05
*& 생성자 : ZGSIPP03
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
*&
*&---------------------------------------------------------------------*
REPORT ZGTPPU9999.

DATA: BEGIN OF ITAB OCCURS 0,
        LINE(500),
      END OF ITAB.

PARAMETERS: PROGRAM(49) OBLIGATORY.

AT SELECTION-SCREEN.
  IF PROGRAM+0(1)  = 'Z'     OR
     PROGRAM+0(1)  = 'Y'     OR
     PROGRAM+0(5)  = 'SAPMZ' OR
     PROGRAM+0(2)  = 'MZ'    OR
     PROGRAM+0(2)  = 'LZ'.
  ELSE.
    MESSAGE S001(ZSD1) DISPLAY LIKE 'W'
       WITH 'Standard 프로그램 수정은 각별히 주의해 주세요!'.
  ENDIF.

START-OF-SELECTION.
  READ REPORT PROGRAM INTO ITAB.

  EDITOR-CALL FOR ITAB.

*  IF SY-UCOMM = 'WB_SAVE' OR SY-UCOMM = 'YES'.
  IF SY-SUBRC = 0.
    INSERT REPORT PROGRAM FROM ITAB.
  ENDIF.
