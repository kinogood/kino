*&---------------------------------------------------------------------*
*& 모듈           : PP
*& 프로그램 ID : ZGTPPR3010
*& 프로그램 명 : [GT] 백로그 삭제, 투입 오류 재처리 내역 조회
*& 개요   : 삭제된 생산 백로그의 이력(삭제자, 삭제일시, 삭제사유 등)을 조회하는 기능을 추가 개발
*&           필요 시 삭제된 이력을 참조하여 삭제 취소(백로그를 재생성)하는 기능을 추가 개발
*& 생성일 : 2024.10.14
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
REPORT zgtppr3010 MESSAGE-ID zgtpp00.

INCLUDE zgtppr3010top. "Global 변수, 테이블 및 ALV 변수

INCLUDE zgtppr3010s01. " 조회 조건 관련

INCLUDE zgtppr3010o01. "PBO

INCLUDE zgtppr3010c01. "ALV 관련 로직

INCLUDE zgtppr3010f01. "일반 로직 PERFORM 문

INCLUDE zgtppr3010f02. "ALV 관련 PERFORM 문

INCLUDE zgtppr3010i01. "PAI
*&---------------------------------------------------------------------*
INITIALIZATION.
* 전기일자는 기본적으로 현재일자를 LOW필드에 추가
  s_budat-low = sy-datum.
  APPEND s_budat.
* 조회조건에서 레이아웃이 기본 지정되어 있을 경우 해당 레이아웃 가져옴.
  PERFORM get_default_layout CHANGING p_layo.

AT SELECTION-SCREEN.
  PERFORM authority_checking_proc.

AT SELECTION-SCREEN OUTPUT.
*&---------------------------------------------------------------------*
START-OF-SELECTION.
*&---------------------------------------------------------------------*
* 코드마스터에서 "MRP 관리자(모품목)"기준으로 공정코드 필수 체크 수행
* 해당 값 존재 시 공정 미입력 했을 경우 오류 출력
  SELECT SINGLE fld_03 INTO @DATA(lv_fld_03) FROM zgtppt1010
                                     WHERE module_kind EQ 'PP'
                                          AND codegrp EQ '3002'
                                          AND fld_01 EQ @p_werks
                                          AND fld_02 IN @s_dispo.

  IF lv_fld_03 EQ 'X' AND s_gong[] IS INITIAL AND s_dispo[] is NOT INITIAL.

    MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-e01.

  ELSE.
* 조회 조건 기준으로 생산 백로그 정보를 발췌함
    PERFORM get_data.

    IF gt_disp[] IS INITIAL.

      MESSAGE s001.

    ELSE.

      CALL SCREEN 100.

    ENDIF.

  ENDIF.
*&---------------------------------------------------------------------*
END-OF-SELECTION.
