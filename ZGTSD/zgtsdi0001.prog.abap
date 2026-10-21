************************************************************************
* Title:         [GT] 거래처 마스터 송신
* Creator:
* Created date:  2024.11.29
* Description:   [GT] 거래처 마스터 송신
* Issue :
************************************************************************
* Modification log:
* ---------------------------------------------------------------------*
* <Date>    <Changed by>    <Description>
* ---------------------------------------------------------------------*
* 24.11.29   ZGSIDEV05       최초생성
************************************************************************
REPORT ZGTSDI0001 MESSAGE-ID ZGTSD01 NO STANDARD PAGE HEADING.

INCLUDE ZGTSDI0001TOP. " Global Data
INCLUDE ZGTSDI0001C01. " Class(Event Handler)
INCLUDE ZGTSDI0001SEL. " Selection-Screen
INCLUDE ZGTSDI0001O01. " PBO-Modules
INCLUDE ZGTSDI0001I01. " PAI-Modules
INCLUDE ZGTSDI0001F01. " FORM-Routines

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM INITIALIZATION.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_SCREEN.

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

  "입력값 체크
  PERFORM CHECK_INPUT_DATA.
  CHECK GV_ERROR IS INITIAL.

  "권한 체크
  PERFORM AUTHORITY_CHECK.

  "데이터 구성
  PERFORM DATA_QUERY.

*----------------------------------------------------------------------*
* END-OF-SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.

  CHECK GV_ERROR IS INITIAL.

  IF SY-BATCH IS INITIAL.
    CALL SCREEN 0100.
  ELSE.
    PERFORM SEND_IF_BATCHJOB.
  ENDIF.
