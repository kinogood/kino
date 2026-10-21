************************************************************************
* Title:         [GT] 제조지시상태변경 재처리
* Creator:
* Created date:  2025.07.16
* Description:   판매오더 생성 혹은 취소 상태가 MES로 전달되지
*                않았을 경우 이를 재처리하는 프로그램
* Issue :
************************************************************************
* Modification log:
* ---------------------------------------------------------------------*
* <Date>    <Changed by>    <Description>
* ---------------------------------------------------------------------*
* 24.12.09   ZGSIDEV05       최초생성
************************************************************************
REPORT ZGTSDI6010 MESSAGE-ID ZGTSD01 NO STANDARD PAGE HEADING.

INCLUDE ZGTSDI6010TOP. " Global Data
INCLUDE ZGTSDI6010C01. " Class(Event Handler)
INCLUDE ZGTSDI6010SEL. " Selection-Screen
INCLUDE ZGTSDI6010O01. " PBO-Modules
INCLUDE ZGTSDI6010I01. " PAI-Modules
INCLUDE ZGTSDI6010F01. " FORM-Routines


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
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_IF_RFC.
  PERFORM F4_IF_RFC USING 'P_IF_RFC'.
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

**********************************************************************
  "데이타 건수 메시지 출력
  IF GT_S0100 IS NOT INITIAL.
    MESSAGE S009 WITH |{ LINES( GT_S0100 ) NUMBER = USER }|. "& 건 검색되었습니다.
  ELSE.
    MESSAGE S010.                                           "조회할 데이타가 없습니다.
    GV_ERROR = GC_X.                                        "데이타 없으면 출력 X
  ENDIF.

  CHECK GV_ERROR IS INITIAL.

  IF SY-BATCH IS INITIAL.
    CALL SCREEN 0100.
  ELSE.
    PERFORM SEND_IF_BATCHJOB.
  ENDIF.
