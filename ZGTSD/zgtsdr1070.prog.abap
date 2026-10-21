************************************************************************
* Title:         [GT] 운송중 재고 현황
* Creator:
* Created date:  2025.04.10
* Description:   [GT] 운송중 재고 현황
* Issue :
************************************************************************
* Modification log:
* ---------------------------------------------------------------------*
* <Date>    <Changed by>    <Description>
* ---------------------------------------------------------------------*
* 25.04.10   ZGSIDEV05       최초생성
************************************************************************
REPORT ZGTSDR1070 MESSAGE-ID ZGTSD01 NO STANDARD PAGE HEADING.

INCLUDE ZGTSDR1070TOP. " Global Data
INCLUDE ZGTSDR1070C01. " Class(Event Handler)
INCLUDE ZGTSDR1070SEL. " Selection-Screen
INCLUDE ZGTSDR1070O01. " PBO-Modules
INCLUDE ZGTSDR1070I01. " PAI-Modules
INCLUDE ZGTSDR1070F01. " FORM-Routines

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
  ENDIF.
