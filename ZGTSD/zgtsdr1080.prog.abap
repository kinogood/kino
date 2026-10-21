*&---------------------------------------------------------------------*
*  Program ID  : ZGTSDR1080
*  Title       : [GT_SD] 영업부서 마감처리
*  T-code      : ZSD1R1080
*  Creator     :
*  Start Date  : 2025. 03. 19.
*  Finish Date : .
*  Frequency   : HIGH
*  GAP NO      : SD073
*  Description :
*&---------------------------------------------------------------------*
*  Modifier    :
*  Modify date :
*  Description :
*&---------------------------------------------------------------------*
* Technical Description *
* 2026.02.03 CHM2602-00071 ZLSGSD2 출고일자 가져오기 오류 수정
*----------------------------------------------------------------------*
REPORT ZGTSDR1080 LINE-SIZE 154 LINE-COUNT 58 MESSAGE-ID ZSD1
                  NO STANDARD PAGE HEADING.
*----------------------------------------------------------------------*
*   includes
*----------------------------------------------------------------------*
INCLUDE ZGTSDR1080_TOP.
INCLUDE ZGTSDR1080_CLS.
INCLUDE ZGTSDR1080_FRM.
INCLUDE ZGTSDR1080_PAI.
INCLUDE ZGTSDR1080_PBO.
INCLUDE ZGTSDR1080_BDC.
INCLUDE ZGTSDR1080_ALV.

*----------------------------------------------------------------------*
INITIALIZATION.
*----------------------------------------------------------------------*
** Layout관련
  G_REPID = SY-REPID.
  G_SAVE = 'A'.   "The user may save all types of a layout
  DATA GV_DT TYPE SY-DATUM.
  GV_DT = SY-DATLO - 5.
  P_SPMON = GV_DT(6).
*  S_SPMON-SIGN = 'I'.
*  S_SPMON-OPTION = 'EQ'.
*  S_SPMON-LOW = S_SPMON-HIGH = SY-DATUM.
*  APPEND S_SPMON.
**
  IF SY-TCODE NE 'ZGTSDR1085'.
    SET TITLEBAR  'T0100'.
  ELSE.
    SET TITLEBAR  'T0101'.
  ENDIF.


*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_SCREEN.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST                                 *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM F4HELP_LAYOUT CHANGING P_VARI.


AT SELECTION-SCREEN.

** 권한Check.
  PERFORM  AUTHORITY_CHECK.

** 부스닥트 체크 로직
  PERFORM CHECK_BD.

** Layout 입력안했을때 Default(기본) Layout Display.
  CLEAR SPEC_LAYOUT.

  IF  P_VARI IS INITIAL.
    MOVE  DEF_LAYOUT-VARIANT  TO  SPEC_LAYOUT-VARIANT.
  ELSE.
    MOVE  P_VARI  TO  SPEC_LAYOUT-VARIANT.
  ENDIF.

** 기본세팅이 없는 리스트도 있기때문에...
  CHECK SPEC_LAYOUT-VARIANT NE SPACE.

  MOVE  G_REPID  TO  SPEC_LAYOUT-REPORT.

  CALL FUNCTION 'LVC_VARIANT_EXISTENCE_CHECK'
    EXPORTING
      I_SAVE        = G_SAVE
    CHANGING
      CS_VARIANT    = SPEC_LAYOUT
    EXCEPTIONS
      WRONG_INPUT   = 1
      NOT_FOUND     = 2
      PROGRAM_ERROR = 3
      OTHERS        = 4.

  IF  SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
**

*----------------------------------------------------------------------*
START-OF-SELECTION.
*----------------------------------------------------------------------*
  G_IMODE  =  PA_IMODE.

  PERFORM P1000_INITIAL_DATA.
  PERFORM P1000_SELECT_DATA.
  PERFORM P2000_PROCESS_DATA USING ' '.

** Layout관련
  CLEAR GS_VARIANT.
  MOVE-CORRESPONDING SPEC_LAYOUT TO GS_VARIANT.
**

  IF P_CALL IS NOT INITIAL.
    PERFORM EXPORT_DATA. EXIT.
  ELSE.
    IF GV_FLAG NE 'X'.
      MESSAGE S009(ZGTSD01) WITH |{ LINES( GT_DISPLAY ) NUMBER = USER }|. "& 건 검색되었습니다.
      CALL SCREEN 100.
    ENDIF.
  ENDIF.

*----------------------------------------------------------------------*
END-OF-SELECTION.
*----------------------------------------------------------------------*
