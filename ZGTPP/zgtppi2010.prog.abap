*&---------------------------------------------------------------------*
*& 모듈           : PP
*& 프로그램 ID : ZGTPPI2010
*& 프로그램 명 : [GT] 생산오더 정보 송신
*& 개요   : 생산오더 정보를 MES 시스템으로 송신하는 기능
*& 생성일 : 2024.11.12
*& 생성자 : ZGODEV06
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 2026.02.11. zlsgpp5. CHM2602-00022.소재 플랜트, 소재 MOM I/F 의 경우
*&                      릴리즈 된 생산오더 만 MOM 전송.
*&---------------------------------------------------------------------*
REPORT zgtppi2010 MESSAGE-ID zgtpp00.

INCLUDE zgtppi2010top. "Global 변수, 테이블 및 ALV 변수

INCLUDE zgtppi2010s01. " 조회 조건 관련

INCLUDE zgtppi2010o01. "PBO

INCLUDE zgtppi2010c01. "ALV 관련 로직

INCLUDE zgtppi2010f01. "일반 로직 PERFORM 문

INCLUDE zgtppi2010f02. "ALV 관련 PERFORM 문

INCLUDE zgtppi2010i01. "PAI
*&---------------------------------------------------------------------*
INITIALIZATION.
* 전기일자는 기본적으로 현재일자를 LOW필드에 추가
  s_ifdat-low = s_erdat-low = sy-datum.
  APPEND : s_erdat, s_ifdat.

AT SELECTION-SCREEN.

AT SELECTION-SCREEN OUTPUT.
  PERFORM set_screen_attribute.

*&---------------------------------------------------------------------*
START-OF-SELECTION.
*&---------------------------------------------------------------------*
  IF p_r8 = 'X'. "배치 잡 전송
    WAIT UP TO 2 SECONDS.
  ENDIF.

* 조회 조건 중 필수값 체크
  PERFORM check_display_condition.
  CHECK gv_error IS INITIAL.

* 조회 조건 기준으로 생산오더 정보 발췌
  PERFORM get_data.

  IF p_r8 = 'X'. "배치 잡 전송
    PERFORM send_data.

  ELSE.
    IF p_r1 EQ 'X' AND gr_werks[] IS NOT INITIAL. "전송
      IF gt_disp_head[] IS INITIAL.
        MESSAGE s001.
      ELSE.
        CALL SCREEN 100.
      ENDIF.

    ELSEIF p_r2 EQ 'X'. "로그 조회
      IF gt_disp_head2[] IS INITIAL.
        MESSAGE s001.
      ELSE.
        CALL SCREEN 100.
      ENDIF.
    ENDIF.

  ENDIF.
*&---------------------------------------------------------------------*
END-OF-SELECTION.
