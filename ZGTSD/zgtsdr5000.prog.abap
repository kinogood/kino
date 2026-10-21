************************************************************************
* Title:         거래조건 변경 메일링
* Creator:
* Created date:  2024.10.15
* Description:   거래조건 변경 메일링 프로그램
* Issue :
************************************************************************
* Modification log:
* ---------------------------------------------------------------------*
* <Date>    <Changed by>    <Description>
* ---------------------------------------------------------------------*
* 24.10.21   ZGSIDEV05       최초생성
************************************************************************
REPORT ZGTSDR5000 MESSAGE-ID ZGTSD01 NO STANDARD PAGE HEADING.

INCLUDE ZGTSDR5000TOP. " Global Data
INCLUDE ZGTSDR5000C01. " Class(Event Handler)
INCLUDE ZGTSDR5000SEL. " Selection-Screen
INCLUDE ZGTSDR5000O01. " PBO-Modules
INCLUDE ZGTSDR5000I01. " PAI-Modules
INCLUDE ZGTSDR5000F01. " FORM-Routines

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
AT SELECTION-SCREEN ON P_VKORG. "영업조직
  PERFORM CHECK_VKORG USING    P_VKORG
                      CHANGING P_VTEXT.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VKORG. "
  PERFORM SEARCH_HELP_VKORG    USING TEXT-S01
                                     'VKORG'
                                     'P_VTEXT'
                            CHANGING P_VKORG
                                     P_VTEXT.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKBUR-LOW.
  PERFORM SEARCH_HELP_VKBUR    USING TEXT-S02
                                     'VKBUR'
                            CHANGING S_VKBUR-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_AUART-LOW.
  PERFORM SEARCH_HELP_AUART    USING TEXT-S03
                                     'AUART'
                            CHANGING S_AUART-LOW.
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

  IF SY-BATCH  IS INITIAL.
    CALL SCREEN 0100.
  ELSE.
    PERFORM SEND_MAIL USING 'X'.
  ENDIF.
