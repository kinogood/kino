************************************************************************
* Title:         [BD] 소스 리스트 관리
* Creator:
* Created date:  2024.12.16
* Description:   [BD] 소스 리스트 관리
* Issue :
************************************************************************
* Modification log:
* ---------------------------------------------------------------------*
* <Date>    <Changed by>    <Description>
* ---------------------------------------------------------------------*
* 24.12.16   ZGSIDEV05       최초생성
************************************************************************
REPORT ZGTMMR6100 MESSAGE-ID ZGTMM01 NO STANDARD PAGE HEADING.

INCLUDE ZGTMMR6100TOP. " Global Data
INCLUDE ZGTMMR6100C01. " Class(Event Handler)
INCLUDE ZGTMMR6100SEL. " Selection-Screen
INCLUDE ZGTMMR6100O01. " PBO-Modules
INCLUDE ZGTMMR6100I01. " PAI-Modules
INCLUDE ZGTMMR6100F01. " FORM-Routines

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
