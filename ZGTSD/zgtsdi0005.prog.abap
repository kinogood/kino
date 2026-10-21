************************************************************************
* Title:         [GT] 거래명세서  송신
* Creator:
* Created date:  25.10.31
* Description:   [GT] 거래명세서  송신
* Issue :
************************************************************************
* Modification log:
* ---------------------------------------------------------------------*
* <Date>    <Changed by>    <Description>
* ---------------------------------------------------------------------*
* 25.10.31   ZLSGSD2      최초생성
************************************************************************
REPORT ZGTSDI0005 MESSAGE-ID ZGTSD01 NO STANDARD PAGE HEADING.

INCLUDE ZGTSDI0005TOP.
INCLUDE ZGTSDI0005C01.
INCLUDE ZGTSDI0005SEL.
INCLUDE ZGTSDI0005O01.
INCLUDE ZGTSDI0005I01.
INCLUDE ZGTSDI0005F01.

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

  "외부호출시 30초 DELAY
  IF p_call = 'X'.
    WAIT UP TO 30 SECONDS.
  ENDIF.

  "입력값 체크
  PERFORM CHECK_INPUT_DATA.
  CHECK GV_ERROR IS INITIAL.


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
        IF p_call = 'X' .
      WRITE :gv_IVNO, gv_result , gv_message .
    ENDIF.
  ENDIF.
