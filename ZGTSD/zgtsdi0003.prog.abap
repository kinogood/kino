************************************************************************
* Title:         [GT] 납품오더 송신
* Creator:
* Created date:  2024.12.09
* Description:   [GT] 납품오더 송신
* Issue :
************************************************************************
* Modification log:
* ---------------------------------------------------------------------*
* <Date>    <Changed by>    <Description>
* ---------------------------------------------------------------------*
* 24.12.09   ZGSIDEV05       최초생성
************************************************************************
REPORT zgtsdi0003 MESSAGE-ID zgtsd01 NO STANDARD PAGE HEADING.

INCLUDE zgtsdi0003top. " Global Data
INCLUDE zgtsdi0003c01. " Class(Event Handler)
INCLUDE zgtsdi0003sel. " Selection-Screen
INCLUDE zgtsdi0003o01. " PBO-Modules
INCLUDE zgtsdi0003i01. " PAI-Modules
INCLUDE zgtsdi0003f01. " FORM-Routines

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

  "권한 체크
  PERFORM authority_check.

  "데이터 구성
* [GO-SD][26.01.28] Add logic for 가온MES  - Start.
  IF rb_10 = 'X'.
    PERFORM data_query2.
  ELSE.
    PERFORM data_query.
  ENDIF.
*  IF rb_t1 = 'X'.
*    PERFORM data_query.
*  ELSE.
*    PERFORM data_query2.
*  ENDIF.
* [GO-SD][26.01.28] Add logic for 가온MES  - End.

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
      WRITE :gv_vbeln, gv_result , gv_message .
    ENDIF.
  ENDIF.
