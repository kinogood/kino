*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR4000
*& 프로그램 명 : [BD] 생산오더 현황 및 마감
*& 개요   : 월마감 시 잔량이 존재하는 생산오더들을 마감 처리하고,
*&          잔량만큼 다음달 기준의 생산오더를 후속으로 생성
*&          (처리 결과 조회 및 처리 취소 기능도 포함)
*& 생성일 : 2024.12.27
*& 생성자 : ZGSIDEV08
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 2026.08.11 zlsgpp5   SRM2608-03040.생산일정변경 대량처리 속도개선.
*&---------------------------------------------------------------------*
REPORT zgtppr4000 MESSAGE-ID zgtpp00.

INCLUDE zgtppr4000top.
INCLUDE zgtppr4000s01.
INCLUDE zgtppr4000c01.
INCLUDE zgtppr4000h01.
INCLUDE zgtppr4000i01.
INCLUDE zgtppr4000o01.
INCLUDE zgtppr4000f01.

INITIALIZATION.
  PERFORM set_screen_value.

AT SELECTION-SCREEN.
  PERFORM authority_checking_proc.

AT SELECTION-SCREEN OUTPUT.
  PERFORM modify_first_screen.

*- 레이아웃 탐색도움말
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_layo.
  PERFORM select_alv_variant CHANGING p_layo.

START-OF-SELECTION.
  PERFORM chk_cockpit.
  PERFORM get_data.
  PERFORM modify_data.

  IF p_r1 EQ gc_x.   "오더마감처리
    IF gt_data[] IS INITIAL.
      MESSAGE s001 DISPLAY LIKE gc_w.
      LEAVE TO LIST-PROCESSING.
    ELSE.
      CLEAR: gv_dbcnt.
      gv_dbcnt = lines( gt_data ).
      CONDENSE gv_dbcnt.
      MESSAGE s002 WITH gv_dbcnt.

      CALL SCREEN 0100.
    ENDIF.
  ELSEIF p_r2 EQ gc_x.   "처리결과조회/취소
    IF gt_revdata[] IS INITIAL.
      MESSAGE s001 DISPLAY LIKE gc_w.
      LEAVE TO LIST-PROCESSING.
    ELSE.
      CLEAR: gv_dbcnt.
      gv_dbcnt = lines( gt_revdata ).
      CONDENSE gv_dbcnt.
      MESSAGE s002 WITH gv_dbcnt.

      CALL SCREEN 0100.
    ENDIF.
  ELSEIF p_r3 EQ gc_x.   "생산오더현황
    IF gt_aufnr[] IS INITIAL.
      MESSAGE s001 DISPLAY LIKE gc_w.
      LEAVE TO LIST-PROCESSING.
    ELSE.
      CLEAR: gv_dbcnt.
      gv_dbcnt = lines( gt_aufnr ).
      CONDENSE gv_dbcnt.
      MESSAGE s002 WITH gv_dbcnt.

      CALL SCREEN 0100.
    ENDIF.
  ENDIF.
