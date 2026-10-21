*&---------------------------------------------------------------------*
*& 모듈           : PP
*& 프로그램 ID : ZGTPPI1010
*& 프로그램 명 : [GT] 작업장 정보 송신
*& 개요   : 작업장 정보를 MES 시스템으로 송신하는 기능
*& 생성일 : 2024.10.29
*& 생성자 : ZGSIDEV06
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
REPORT ZGTPPI1010 MESSAGE-ID zgtpp00.

INCLUDE zgtppi1010top. "Global 변수, 테이블 및 ALV 변수

INCLUDE zgtppi1010s01. " 조회 조건 관련

INCLUDE zgtppi1010o01. "PBO

INCLUDE zgtppi1010c01. "ALV 관련 로직

INCLUDE zgtppi1010f01. "일반 로직 PERFORM 문

INCLUDE zgtppi1010f02. "ALV 관련 PERFORM 문

INCLUDE zgtppi1010i01. "PAI
*&---------------------------------------------------------------------*
INITIALIZATION.
* 전기일자는 기본적으로 현재일자를 LOW필드에 추가
  s_datum2-low = s_datum-low = sy-datum.
  APPEND : s_datum, s_datum2.

AT SELECTION-SCREEN.

AT SELECTION-SCREEN OUTPUT.

  PERFORM set_screen_attribute.
*&---------------------------------------------------------------------*
START-OF-SELECTION.
*&---------------------------------------------------------------------*
* 조회 조건 중 필수값 체크
  PERFORM check_display_condition.

  CHECK gv_error IS INITIAL.
* 조회 조건 기준으로 생산 백로그 정보를 발췌함
  PERFORM get_data.

  IF p_r8 = 'X'. "배치 잡 전송

    PERFORM send_data.

  ELSE.

    IF p_r1 EQ 'X' AND gr_werks[] IS NOT INITIAL. "전송

      IF gt_disp[] IS INITIAL.

        MESSAGE s001.

      ELSE.

        CALL SCREEN 100.

      ENDIF.

    ELSEIF p_r2 EQ 'X'. "로그 조회(재처리)

      IF gt_disp2[] IS INITIAL.

        MESSAGE s001.

      ELSE.

        CALL SCREEN 100.

      ENDIF.

    ENDIF.

  ENDIF.
*&---------------------------------------------------------------------*
END-OF-SELECTION.
