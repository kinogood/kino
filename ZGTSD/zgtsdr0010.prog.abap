************************************************************************
* Title:         [GT] S&OP 진행단계별 일정관리
* Creator:
* Created date:  2025.04.23
* Description:   S&OP 진행단계별 일정관리
* Issue :
************************************************************************
* Modification log:
* ---------------------------------------------------------------------*
* <Date>    <Changed by>    <Description>
* ---------------------------------------------------------------------*
* 25.04.23   ZGSIDEV05       최초생성
************************************************************************
REPORT ZGTSDR0010 MESSAGE-ID ZGTSD01 NO STANDARD PAGE HEADING.

INCLUDE ZGTSDR0010TOP. " Global Data
INCLUDE ZGTSDR0010C01. " Class(Event Handler)
INCLUDE ZGTSDR0010SEL. " Selection-Screen
INCLUDE ZGTSDR0010O01. " PBO-Modules
INCLUDE ZGTSDR0010I01. " PAI-Modules
INCLUDE ZGTSDR0010F01. " FORM-Routines

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
  PERFORM CHECK_KUNNR USING    TEXT-S07
                               P_KUNNR
                      CHANGING P_NAME1.
*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*----------------------------------------------------------------------*
  AT SELECTION-SCREEN .
  "레이아웃 Variant 구분자
  IF  P_VARI IS NOT INITIAL.

    MOVE P_VARI   TO GS_VARIANT-VARIANT.
    MOVE SY-CPROG TO GS_VARIANT-REPORT.
    MOVE '1'      TO GS_VARIANT-HANDLE.

    CALL FUNCTION 'LVC_VARIANT_EXISTENCE_CHECK'
      EXPORTING
        I_SAVE        = 'A'
      CHANGING
        CS_VARIANT    = GS_VARIANT
      EXCEPTIONS
        WRONG_INPUT   = 1
        NOT_FOUND     = 2
        PROGRAM_ERROR = 3
        OTHERS        = 4.

    IF  SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM F4HELP_LAYOUT CHANGING P_VARI.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_SPMON-LOW.
  PERFORM GET_YYMM_F4_SEARCH CHANGING S_SPMON-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_SPMON-HIGH.
  PERFORM GET_YYMM_F4_SEARCH CHANGING S_SPMON-HIGH.

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
  PERFORM DATA_QUERY USING ''.

*----------------------------------------------------------------------*
* END-OF-SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.

  CHECK GV_ERROR IS INITIAL.

  IF SY-BATCH IS INITIAL.
    CALL SCREEN 0100.
  ENDIF.
