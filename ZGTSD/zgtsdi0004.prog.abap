************************************************************************
* Title:         [GT] 선적문서 송신
* Creator:
* Created date:  25.10.23
* Description:   [GT] 선적문서 송신
* Issue :
************************************************************************
* Modification log:
* ---------------------------------------------------------------------*
* <Date>    <Changed by>    <Description>
* ---------------------------------------------------------------------*
* 25.10.23   ZLSGSD2      최초생성
************************************************************************
REPORT zgtsdi0004 MESSAGE-ID zgtsd01 NO STANDARD PAGE HEADING.

INCLUDE zgtsdi0004top.
INCLUDE zgtsdi0004c01.
INCLUDE zgtsdi0004sel.
INCLUDE zgtsdi0004o01.
INCLUDE zgtsdi0004i01.
INCLUDE zgtsdi0004f01.

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM initialization.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM modify_screen.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

  "외부호출시 30초 DELAY
  IF p_call = 'X'.
    WAIT UP TO 30 SECONDS.
  ENDIF.

  "입력값 체크
  PERFORM check_input_data.
  CHECK gv_error IS INITIAL.


  "데이터 구성
  PERFORM data_query.

*----------------------------------------------------------------------*
* END-OF-SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.

  CHECK gv_error IS INITIAL.

  IF sy-batch IS INITIAL.
    CALL SCREEN 0100.
  ELSE.
    PERFORM send_if_batchjob.
    IF p_call = 'X' .
      WRITE :gv_TKNUM, gv_result , gv_message .
    ENDIF.
  ENDIF.
