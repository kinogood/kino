*&---------------------------------------------------------------------*
*& 모듈           : PP
*& 프로그램 ID : ZGTPPI3090
*& 프로그램 명 : [BD] 외주 전환 결과 송신
*& 개요   : ERP의 외주 전환 처리 결과를 MES로 송신하는 기능임
*& 생성일 : 2025.02.17
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
REPORT zgtppi3090 MESSAGE-ID zgtpp00.

INCLUDE zgtppi3090top. "Global 변수, 테이블 및 ALV 변수

INCLUDE zgtppi3090s01. " 조회 조건 관련

INCLUDE zgtppi3090o01. "PBO

INCLUDE zgtppi3090c01. "ALV 관련 로직

INCLUDE zgtppi3090f01. "일반 로직 PERFORM 문

INCLUDE zgtppi3090f02. "ALV 관련 PERFORM 문

INCLUDE zgtppi3090i01. "PAI
*&---------------------------------------------------------------------*
INITIALIZATION.
* 전기일자는 기본적으로 현재일자를 LOW필드에 추가
  s_ifdat-low = sy-datum.
  APPEND : s_ifdat.

AT SELECTION-SCREEN.

AT SELECTION-SCREEN OUTPUT.

  PERFORM set_screen_attribute.
*&---------------------------------------------------------------------*
START-OF-SELECTION.
*&---------------------------------------------------------------------*
* 현재는 플랜트 '1306' 외 사용 금지
  IF p_werks NE '1306'.

    IF p_werks EQ space.
      MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-e02.
    ELSE.
      MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-e01.
    ENDIF.

  ELSE.

    IF p_r8 = 'X'. "배치 잡 전송
      WAIT UP TO 2 SECONDS.
    ENDIF.
* 조회 조건 중 필수값 체크
    PERFORM check_display_condition.

    CHECK gv_error IS INITIAL.

    PERFORM get_data.

    IF p_r8 = 'X'. "배치 잡 전송

      PERFORM send_data.

    ELSE.

      IF p_r1 = 'X'. "처리모드 선택 : 전송

        IF gt_header[] IS INITIAL.

          MESSAGE s001.

        ELSE.

          CALL SCREEN 100.

        ENDIF.

      ELSE. "처리모드 선택 : 로그 조회

        IF gt_header2[] IS INITIAL.

          MESSAGE s001.

        ELSE.

          CALL SCREEN 100.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDIF.
