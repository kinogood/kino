*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2070
*& 프로그램 명 : [GT] 월간계획(설비능력관리)
*& 개요   : 월간 생산 계획(절연)을 수립하기 위한 절연 설비 월별
*&          가동일수 관리 및 규격별 Capa를 수정하고 관리하는 프로그램
*& 생성일 : 2025.04.22
*& 생성자 : ZGSIDEV06
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
* 2026.02.02  zlsgpp5 CHM2601-00657 절연 반제품 자재코드 미생성 항목에
*                     대해서 완제품 자재코드 존재시
*                     반제품 코드 자동 탐색 및 설정 기능 추가
* 2026.05.26  zlsgpp5 CHM2605-00421.반제품으로 필드 데이터 조회.
*&---------------------------------------------------------------------*
REPORT zgtppr2070 MESSAGE-ID zgtpp00.

INCLUDE zgtppr2070top.
INCLUDE zgtppr2070s01.
INCLUDE zgtppr2070c01.
INCLUDE zgtppr2070i01.
INCLUDE zgtppr2070o01.
INCLUDE zgtppr2070f01.

*-----------------------------------------------------------------------
*-- Initialization.
*-----------------------------------------------------------------------
INITIALIZATION.
  PERFORM set_button.

*-----------------------------------------------------------------------
*-- At Selection-Screen Output
*-----------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
  PERFORM get_parameter_description.
  PERFORM modify_first_screen.

*-----------------------------------------------------------------------
*-- At Selection-Screen
*-----------------------------------------------------------------------
AT SELECTION-SCREEN.
  CASE sy-ucomm.
    WHEN 'FC01'.
      PERFORM call_maintain_view USING 1.
    WHEN 'FC02'.
      PERFORM call_maintain_view USING 2.
  ENDCASE.

*-----------------------------------------------------------------------
*-- START-OF-SELECTION
*-----------------------------------------------------------------------
START-OF-SELECTION.

  PERFORM authority_checking_proc.

  PERFORM get_data.

*-----------------------------------------------------------------------
*-- END-OF-SELECTION
*-----------------------------------------------------------------------
END-OF-SELECTION.

  IF p_call IS NOT INITIAL.
* 설비 Capa. 계산
    IF <gs_main> IS ASSIGNED. UNASSIGN <gs_main>. ENDIF.
    <gt_main_disp_100_2> = <gt_main_disp_100>.
    REFRESH : <gt_main_disp_100>.

    LOOP AT <gt_main_disp_100_2> ASSIGNING <gs_main>.

      gv_tabix = sy-tabix.
      CLEAR gv_icon.
* 외주 프로그램 콜과 설비 Capa. 계산 프로세스에 같이 사용
      PERFORM common_logic_calculate_capa.

      CHECK gv_icon NE icon_led_red.
* 설비 Capa. 저장
      PERFORM save_zgtppt2120.

    ENDLOOP.

  ELSE.

    PERFORM proc_display.

  ENDIF.
