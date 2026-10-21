*&---------------------------------------------------------------------*
*& 모듈           : PP
*& 프로그램 ID : ZGTPPR1040
*& 프로그램 명 : [GT] 생산오더의  소요량 대비 투입량 비교 조회
*& 개요   : 생산오더의  소요량 대비해서 투입량 비교 조회
*& 생성일 : 2024.11.05
*& 생성자 : ZGSIPP04
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
REPORT ZGTPPR1040 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR1040TOP.   "Global 변수, 테이블 및 ALV 변수

INCLUDE ZGTPPR1040S01.   " 조회 조건 관련

INCLUDE ZGTPPR1040O01.   "PBO

INCLUDE ZGTPPR1040C01.   "ALV 관련 로직

INCLUDE ZGTPPR1040F01.   "일반 로직 PERFORM 문

INCLUDE ZGTPPR1040F02.   "ALV 관련 PERFORM 문

INCLUDE ZGTPPR040I01.    "PAI

*&---------------------------------------------------------------------*
INITIALIZATION.
*&---------------------------------------------------------------------*

  PERFORM SET_SCREEN_VALUE.

*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
*&---------------------------------------------------------------------*
* 플랜트 권한 체크
  PERFORM AUTHORITY_CHECKING_PROC.

*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*&---------------------------------------------------------------------*
  PERFORM SET_SCREEN_ATTRIBUTE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_gongcd-low.
  PERFORM F4_GONG_CD USING 'S_GONGCD-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_gongcd-HIGH.
  PERFORM F4_GONG_CD USING 'S_GONGCD-HIGH'.

*&---------------------------------------------------------------------*
START-OF-SELECTION.
*&---------------------------------------------------------------------*
  PERFORM CHK_COCKPIT.
  PERFORM INPUT_VALUE_CHECK.
  CHECK GV_CHECK_ERROR <> 'N'.
* 조회 조건 기준으로 기초 DATA 조회
  PERFORM GET_DATA.
*  기초 data 필드별 생성
  PERFORM MODIFY_DATA.
*  조회 모드별 data sum 변경
  PERFORM MODIFY_DATA_SUM.

  IF GT_DISP[] IS INITIAL.
    MESSAGE S001.
  ELSE.
    IF P_R1 = 'X'. "생산오더별
      IF GT_DISP1[] IS INITIAL.
        MESSAGE S001.
      ELSE.
        CALL SCREEN 100.
      ENDIF.
    ELSEIF P_R2 = 'X'. "모자재별
      IF GT_DISP2[] IS INITIAL.
        MESSAGE S001.
      ELSE.
        CALL SCREEN 100.
      ENDIF.
    ELSEIF P_R3 = 'X'. "저자재별
      IF GT_DISP3[] IS INITIAL.
        MESSAGE S001.
      ELSE.
        CALL SCREEN 100.
      ENDIF.
    ENDIF.

  ENDIF.
*&---------------------------------------------------------------------*
END-OF-SELECTION.
*&---------------------------------------------------------------------*
