************************************************************************
* Module/Sub-Module :
* Type              :
* TRANSACTION CODE  :
* Description       : [GT] 월별 매출 추정 관리
************************************************************************
*                          MODIFICATION LOG                            *
*----------------------------------------------------------------------*
*    DATE    |     AUTHORS     |             DESCRIPTION               *
*----------------------------------------------------------------------*
* 2026/02/05 |     ZGSISD08    |
************************************************************************
************************************************************************
report zgtsdr0070 message-id zsnop line-size 330.

*======================================================================*
* I N C L U D E
*======================================================================*
include zgtsdr0070top.
include zgtsdr0070cls.
include zgtsdr0070f01.
include zgtsdr0070o01.
include zgtsdr0070i01.

*======================================================================*
* INITIALIZATION
*======================================================================*
initialization.
  perform set_init.

*======================================================================*
* F4 help
*======================================================================*
at selection-screen on value-request for p_vkbur.
  perform f4_vkbur_dialog   using 'P_VKBUR'
                            changing p_vkbur.

at selection-screen on value-request for p_pernr.
  perform f4_pernr_dialog   using 'P_PERNR'
                            changing p_pernr.


*AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_ALV.
*  PERFORM F4_ALV_DEF USING P_ALV.   " Layout selection

at selection-screen .
  perform call_pa_report.
  perform alv_check_layout.

*======================================================================*
* AT SELECTION-SCREEN OUTPUT
*======================================================================*
at selection-screen output.
  perform set_selection_screen.

*======================================================================*
* S T A R T - O F - S E L E C T I O N
*======================================================================*

start-of-selection.

  if p_call is initial and p_pernr is initial.
    message s001 with '영업사원은 필수로 입력하십시오.' display like 'E'.
    exit.
  endif.

  if p_call = 'X'.

*    perform set_base_date.

    gv_read_new = 'X'.  "-- 신규로 읽는다.

    "-- 주문생성일
    if s_erdat[] is initial.
      perform set_init_erdat.
    endif.
  endif.

  clear gv_nkey_m0 .  "현재월을 보여주기위한 필드
  perform auth_check.
  perform get_data.


*end-of-selection.

  if p_call = 'X'.
    delete gt_main where bltype = 'A'. "-- 의지치는 제외함
    export gt_main = gt_main[] to memory id 'ZZ_R_PLANNA_01'.
  else.
    if gv_err = ''.
      if s_vbeln[] is not initial.
        message s001 with '주문번호를 입력하면 의지치는 제외됩니다.'.
      endif.
      call screen '0100'.
    endif.
  endif.
