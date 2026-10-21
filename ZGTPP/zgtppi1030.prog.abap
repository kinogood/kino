*&---------------------------------------------------------------------*
*& 모듈           : PP
*& 프로그램 ID : ZGTPPI1030
*& 프로그램 명 : [GT] 생산버젼 정보 송신
*& 개요   : 생산버전 정보를 MES 시스템으로 송신하는 기능
*& 생성일 : 2024.10.14
*& 생성자 : ZGSIDEV06
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*  NO     DATE       AUTHORS              DESCRIPTION
*----------------------------------------------------------------------*
* U01  2026.02.27  ZGODEV03    가온전선 추가
*&---------------------------------------------------------------------*
REPORT ZGTPPI1030 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPI1030TOP. "Global 변수, 테이블 및 ALV 변수

INCLUDE ZGTPPI1030S01. " 조회 조건 관련

INCLUDE ZGTPPI1030O01. "PBO

INCLUDE ZGTPPI1030C01. "ALV 관련 로직

INCLUDE ZGTPPI1030F01. "일반 로직 PERFORM 문

INCLUDE ZGTPPI1030F02. "ALV 관련 PERFORM 문

INCLUDE ZGTPPI1030I01. "PAI
*&---------------------------------------------------------------------*
INITIALIZATION.
* 전기일자는 기본적으로 현재일자를 LOW필드에 추가
  S_DATUM2-LOW = S_DATUM-LOW = SY-DATUM.
  APPEND : S_DATUM, S_DATUM2.

AT SELECTION-SCREEN.

AT SELECTION-SCREEN OUTPUT.

  PERFORM SET_SCREEN_ATTRIBUTE.
*&---------------------------------------------------------------------*
START-OF-SELECTION.
*&---------------------------------------------------------------------*
* 조회 조건 중 필수값 체크
  PERFORM CHECK_DISPLAY_CONDITION.

  CHECK GV_ERROR IS INITIAL.
* 조회 조건 기준으로 생산 백로그 정보 발췌함
  PERFORM GET_DATA.

  IF P_R8 = 'X'. "배치 잡 전송

    PERFORM SEND_DATA.

  ELSE.

    IF P_R1 EQ 'X' AND GR_WERKS[] IS NOT INITIAL. "전송

      IF GT_DISP[] IS INITIAL.

        MESSAGE S001.

      ELSE.

        DATA(LV_INDEX) = LINES( GT_DISP ) .
        GV_LINES_C = LV_INDEX.
        CONDENSE GV_LINES_C.

        MESSAGE S002 WITH GV_LINES_C.

        CALL SCREEN 100.

      ENDIF.

    ELSEIF P_R2 EQ 'X'. "로그 조회(재처리)

      IF GT_DISP2[] IS INITIAL.

        MESSAGE S001.

      ELSE.

        CLEAR LV_INDEX.
        LV_INDEX = LINES( GT_DISP2 ) .
        GV_LINES_C = LV_INDEX.
        CONDENSE GV_LINES_C.

        MESSAGE S002 WITH GV_LINES_C.

        CALL SCREEN 100.

      ENDIF.

    ENDIF.

  ENDIF.
*&---------------------------------------------------------------------*
END-OF-SELECTION.
