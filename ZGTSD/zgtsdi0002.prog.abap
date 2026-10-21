************************************************************************
* Title:         [GT] 판매오더 송신
* Creator:
* Created date:  2024.12.06
* Description:   [GT] 판매오더 송신
* Issue :
************************************************************************
* Modification log:
* ---------------------------------------------------------------------*
* <Date>    <Changed by>    <Description>
* ---------------------------------------------------------------------*
* 24.11.29   ZGSIDEV05       최초생성
* ---------------------------------------------------------------------*
* 26.01.14   ZGODEV05        가온전선 '가온MES' 로직 추가
* 26.01.14   ZGODEV05        가온MES -> 가온전력 / 가온통신 MES 로 구분.
************************************************************************
REPORT zgtsdi0002 MESSAGE-ID zgtsd01 NO STANDARD PAGE HEADING.

INCLUDE zgtsdi0002top. " Global Data
INCLUDE zgtsdi0002c01. " Class(Event Handler)
INCLUDE zgtsdi0002sel. " Selection-Screen
INCLUDE zgtsdi0002o01. " PBO-Modules
INCLUDE zgtsdi0002i01. " PAI-Modules
INCLUDE zgtsdi0002f01. " FORM-Routines

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
* [GO-SD][26.02.09] 가온전선 로직 분리  - Start.
  IF gv_go = gc_x.
    PERFORM data_query_go.
  ELSE.
* [GO-SD][26.02.09] 가온전선 로직 분리  - End.

    PERFORM data_query.

  ENDIF.


*----------------------------------------------------------------------*
* END-OF-SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.

  CHECK gv_error IS INITIAL.

  IF sy-batch IS INITIAL.
    CALL SCREEN 0100.
  ELSE.
* [GO-SD][26.02.09] 가온전선 로직 분리  - Start.
    IF gv_go = gc_x.
      PERFORM send_if_go.
    ELSE.
* [GO-SD][26.02.09] 가온전선 로직 분리  - End.
      PERFORM send_if_batchjob.

    ENDIF.

    IF p_call = 'X' .
      WRITE :gv_vbeln, gv_result , gv_message .
    ENDIF.
  ENDIF.
