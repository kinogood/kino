************************************************************************
* Title:         [GT] 광섬유 출하용 배치관리
* Creator:
* Created date:  2026.04.21
* Description:   [GT] 광섬유 출하용 배치관리
* Issue :
************************************************************************
* Modification log:
* ---------------------------------------------------------------------*
* <Date>    <Changed by>    <Description>
* ---------------------------------------------------------------------*
* 26.04.21   ZGSISD08        최초생성
************************************************************************
REPORT ZGTSDR0012 MESSAGE-ID ZGTSD01 NO STANDARD PAGE HEADING.

INCLUDE ZGTSDR0012TOP. " Global Data
INCLUDE ZGTSDR0012C01. " Class(Event Handler)
INCLUDE ZGTSDR0012SEL. " Selection-Screen
INCLUDE ZGTSDR0012O01. " PBO-Modules
INCLUDE ZGTSDR0012I01. " PAI-Modules
INCLUDE ZGTSDR0012F01. " FORM-Routines

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
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

  "데이터 조회
  PERFORM GET_DATA.

*----------------------------------------------------------------------*
* END-OF-SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.

  "데이터가 존재하면 화면 호출
  IF GT_ALV IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE S000 WITH '조건에 해당하는 데이터가 없습니다.'.
  ENDIF.
