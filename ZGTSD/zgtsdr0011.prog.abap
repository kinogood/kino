************************************************************************
* Title:         [GT] 광섬유 판매오더 생성
* Creator:
* Created date:  2025.12.08
* Description:   [GT] 광섬유 판매오더 생성
* Issue :
************************************************************************
* Modification log:
* ---------------------------------------------------------------------*
* <Date>    <Changed by>    <Description>
* ---------------------------------------------------------------------*
* 25.12.08   ZGSIDEV05       최초생성
************************************************************************
report zgtsdr0011 message-id zgtsd01 no standard page heading.

include zgtsdr0011top. " Global Data
include zgtsdr0011c01. " Class(Event Handler)
include zgtsdr0011sel. " Selection-Screen
include zgtsdr0011o01. " PBO-Modules
include zgtsdr0011i01. " PAI-Modules
include zgtsdr0011f01. " FORM-Routines

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
initialization.
  perform initialization.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
at selection-screen output.
  perform modify_screen.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*----------------------------------------------------------------------*
at selection-screen on p_vkorg.
  perform check_vkorg.

at selection-screen on p_auart.
  perform check_auart.

at selection-screen on p_vtweg.
  perform check_vtweg.

at selection-screen on p_kunag.
  perform check_kunag.

at selection-screen on p_spart.
  perform check_spart.

at selection-screen on p_kunwe.
  perform check_kunwe.

at selection-screen on p_vkbur.
  perform check_vkbur.

at selection-screen on p_kunrg.
  perform check_kunrg.

at selection-screen on p_vkgrp.
  perform check_vkgrp.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*----------------------------------------------------------------------*
at selection-screen on value-request for p_fname.
  p_fname = zgtsd_cl_common=>file_open_dialog( ).
*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
start-of-selection.

  "입력값 체크
  perform check_input_data.
  check gv_error is initial.

  "권한 체크
  perform authority_check.

  "데이터 업로드
  perform data_upload.

*----------------------------------------------------------------------*
* END-OF-SELECTION
*----------------------------------------------------------------------*
end-of-selection.

  check gv_error is initial.

  if sy-batch is initial.
    call screen 0100.
  endif.
