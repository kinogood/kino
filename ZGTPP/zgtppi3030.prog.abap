*&---------------------------------------------------------------------*
*& 모듈           : PP
*& 프로그램 ID : ZGTPPI3030
*& 프로그램 명 : [GT] 자재문서 정보 송신
*& 개요   : 자재문서 정보를 MES 시스템으로 송신하는 기능임
*& 생성일 : 2024.11.20
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
REPORT zgtppi3030 MESSAGE-ID zgtpp00.

INCLUDE zgtppi3030top.  "Global 변수, 테이블 및 ALV 변수
INCLUDE zgtppi3030s01.  " 조회 조건 관련
INCLUDE zgtppi3030o01.  "PBO
INCLUDE zgtppi3030c01.  "ALV 관련 로직
INCLUDE zgtppi3030f01.  "일반 로직 PERFORM 문
INCLUDE zgtppi3030f02.  "ALV 관련 PERFORM 문
INCLUDE zgtppi3030i01.  "PAI

*&---------------------------------------------------------------------*
INITIALIZATION.
* 전기일자는 기본적으로 현재일자를 LOW필드에 추가
  s_ifdat-low = sy-datum.
  s_ifdat-high = sy-datum.
  APPEND : s_ifdat.

AT SELECTION-SCREEN.

AT SELECTION-SCREEN OUTPUT.

  PERFORM set_screen_attribute.
*&---------------------------------------------------------------------*
START-OF-SELECTION.
*&---------------------------------------------------------------------*

* 조회 조건 중 필수값 체크
  PERFORM check_display_condition.

  CHECK gv_error IS INITIAL.

  IF p_r8 = 'X'. "배치모드 선택

    PERFORM get_matdoc.
    PERFORM send_data.

  ELSE.

    IF p_r1 = 'X'. "전송

*     조회 조건 기준으로 생산 백로그 정보 발췌함
      PERFORM get_data.
      PERFORM modify_data.
      IF gt_disp[] IS INITIAL.
        MESSAGE s001.
      ELSE.
        CALL SCREEN 100.
      ENDIF.

    ELSE. "로그 조회(재처리)

      PERFORM get_data.
      PERFORM modify_data.
      IF gt_disp2[] IS INITIAL.
        MESSAGE s001.
      ELSE.
        CALL SCREEN 100.
      ENDIF.

    ENDIF.

  ENDIF.


*&---------------------------------------------------------------------*
END-OF-SELECTION.
