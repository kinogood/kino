*&---------------------------------------------------------------------*
*& 모듈        : SD
*& 프로그램 ID : ZGTSDR0061
*& 프로그램 명 : Project 번호 관리
*& 개요   :
*& 생성일 : 2025.03.27
*& 생성자 : ZGSISD04
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
REPORT  zgtsdr0061  MESSAGE-ID zsd1  .

*&---------------------------------------------------------------------*
*  데이타 선언부
*&---------------------------------------------------------------------*
INCLUDE zgtsdr0061top.

*&---------------------------------------------------------------------*
*  FORM 선언부
*&---------------------------------------------------------------------*
INCLUDE zgtsdr0061f01.
INCLUDE zgtsdr0061i01.
INCLUDE zgtsdr0061o01.

*---------------------------------------------------------------------*
*      INITIALIZATION
*---------------------------------------------------------------------*
INITIALIZATION.
  PERFORM intial_data.

*---------------------------------------------------------------------*
*      AT SELECTION-SCREEN
*---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM p0000_choice_tab.


AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    IF  screen-group1 = 'XX'.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_spmon.
  PERFORM p0000_entries_pepst USING p_spmon  'P_SPMON'.

*---------------------------------------------------------------------*
*      START-OF-SELECTION.
*---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM p1000_initial_data.
  PERFORM check_data.
  PERFORM read_main_data.
  PERFORM modify_data.
  PERFORM check_data_200.
  PERFORM read_main_data_200.
  PERFORM modify_data_200.
  PERFORM read_notepad.


  IF gv_flag NE 'X'.
    IF g_activetab = 'PUSH1'.
*      if r01 eq 'X'.
*        call screen 100.
*      else.
      CALL SCREEN 200.
*      endif.
    ELSE.
      CALL SCREEN 300.
    ENDIF.
  ENDIF.

END-OF-SELECTION.
*---------------------------------------------------------------------*
*      END-OF-SELECTION.
*---------------------------------------------------------------------*
