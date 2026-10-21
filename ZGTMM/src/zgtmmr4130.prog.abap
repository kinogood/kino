*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMMR4130
*& 프로그램 명 : 외주가공지시
*& 개요   : 외주 가공을 위한 지시, 통문 및 입고 처리(Pgm.ZPPR0032 Copy 후 기능 추가)
*&         현재 일부 SPG에서 사용중인 외주가공 Pgm.처럼, 외주사급 불출시 사급자재의 허용한도
*&         초과 여부를 관리하고 초과시 승인을 통해 불출하게 함
*& 생성일 : 2025.03.18
*& 생성자 : ZGSIDEV03
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*
REPORT ZGTMMR4130 NO STANDARD PAGE HEADING MESSAGE-ID ZPP1.


INCLUDE ZGTMMR4130TOP.
INCLUDE ZGTMMR4130C01.
INCLUDE ZGTMMR4130O01.
INCLUDE ZGTMMR4130I01.
INCLUDE ZGTMMR4130F01.
INCLUDE ZGTMMR4130F02. "추가(SJM 25.03.18)


INITIALIZATION.

START-OF-SELECTION.
  PERFORM CHECK_ZUSE.  "추가(SJM 25.03.18)
  PERFORM INITIAL_PROC.
  PERFORM SELECT_PROC.
  PERFORM ADDITIONAL_INFO_PROC.

  IF GT_EBAN[] IS INITIAL.
    MESSAGE S001 WITH '자료가 존재하지 않습니다.'.
    EXIT.
  ENDIF.

  CALL SCREEN 100.

END-OF-SELECTION.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM F4_FOR_VARIANT USING P_VARI.

AT SELECTION-SCREEN.
  PERFORM CHECK_ACTV. "추가(SJM 25.04.17)
  PERFORM AUTHORITY_CHECKING_PROC.

AT SELECTION-SCREEN ON P_PRBOX.
  IF P_PRBOX = 'X'.
    CLEAR: P_CANCEL, P_CONF.
  ENDIF.

AT SELECTION-SCREEN ON P_POBOX.
  IF P_POBOX = 'X'.
    CLEAR: P_CANCEL, P_CONF.
  ENDIF.

AT SELECTION-SCREEN ON P_CANCEL.
  IF P_CANCEL = 'X'.
    CLEAR: P_PRBOX, P_POBOX, P_CONF.
  ENDIF.

AT SELECTION-SCREEN ON P_CONF.
  IF P_CONF = 'X'.
    CLEAR: P_PRBOX, P_POBOX, P_CANCEL.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_SELECTION_SCREEN.
