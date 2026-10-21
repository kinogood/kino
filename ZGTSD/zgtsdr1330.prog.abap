*&---------------------------------------------------------------------*
*&  모듈       : SD
*&  프로그램 ID : ZGTSDR1330
*&  프로그램 명  : 과거 판매진도 리스트
*&  개요       : 가온전선 판매진도 리스트 - 과거 조회
*&  생성일      : 2026.09.15
*&  생성자      : ZGODEV08
*&---------------------------------------------------------------------*
*& 외부호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*----------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*
report zgtsdr1330  no standard page heading
                              line-size 164
                              message-id zsd1.


include zgtsdr1330top.
include zgtsdr1330c01.
include zgtsdr1330sel.
include zgtsdr1330f01.
include zgtsdr1330o01.
include zgtsdr1330i01.

*-----------------------------------------------------------------------
* INITIALIZATION
*-----------------------------------------------------------------------
initialization.
  perform initialization.

*-----------------------------------------------------------------------
* AT SELECTION-SCREEN OUTPUT
*-----------------------------------------------------------------------
at selection-screen output.
  perform selection_screen_output.

*-----------------------------------------------------------------------
* AT SELECTION-SCREEN ON VALUE-REQUEST
*-----------------------------------------------------------------------
at selection-screen on value-request for p_vari.
  perform value_request_vari changing p_vari.

at selection-screen on value-request for so_auart-low.
  perform value_request_auart using 'SO_AUART-LOW'.

at selection-screen on value-request for so_auart-high.
  perform value_request_auart using 'SO_AUART-HIGH'.

at selection-screen on value-request for so_vkbur-low.
  perform f4_vkbur using 'SO_VKBUR-LOW'.

at selection-screen on value-request for so_vkbur-high.
  perform f4_vkbur using 'SO_VKBUR-HIGH'.

at selection-screen on value-request for so_vkgrp-low.
  perform f4_vkgrp using 'SO_VKGRP-LOW'.

at selection-screen on value-request for so_vkgrp-high.
  perform f4_vkgrp using 'SO_VKGRP-HIGH'.

at selection-screen on value-request for p_spmon.
  perform value_request_spmon changing p_spmon.


*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN.                                             *
*----------------------------------------------------------------------*
at selection-screen.
  perform selection_screen.


*--------------------------------------------------------------------*
*   START OF SELECTION
*--------------------------------------------------------------------*
start-of-selection.

  perform get_data.


*----------------------------------------------------------------------*
*     END-OF-SELECTION                                                 *
*----------------------------------------------------------------------*
end-of-selection.
  if p_call eq 'X'.
    move-corresponding gt_list[] to gt_list_tmp[].
    export pt_list = gt_list_tmp[] to memory id 'GO_1330_LIST'.
  else.
    call screen 0100.
  endif.
