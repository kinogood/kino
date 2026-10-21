************************************************************************
*  Module/Submodule :      SD
*  TYPE             :      매출마감지원(당월출고분 매출처리)
*  P/G              :      Report
*  Author           :      sdc06
*  GAP-ID           :      SD003
*  Date             :      2025.03.24
************************************************************************
*                        MODIFICATION LOG
*-----------------------------------------------------------------------
*  Date.       Author.        description.
* 2025.10.16 ZLSGSD2 CHM2510-00065 빌링분할 추가 및 로직 오류 개선
* 2026.08.14 ZLSGSD6 CHM2608-00034 부스닥트 POD 프로세스 개선 요청
* 2026.09.02 ZLSGS06 CHM2608-00545 부스닥트 대금청구문서 "오류 메세지" 수정 요청
*-----------------------------------------------------------------------
************************************************************************
REPORT ZGTSDR0120 NO STANDARD PAGE HEADING LINE-SIZE 300 MESSAGE-ID ZSD1.
*--------------------------------------------------------------------*
*   INCLUDE (EDIT ALV COMMON MODULE)
*--------------------------------------------------------------------*
INCLUDE Z_COMM_EDIT_ALV.

INCLUDE ZGTSDR0120TOP. " Global Data
INCLUDE ZGTSDR0120C01. " Class(Event Handler)
INCLUDE ZGTSDR0120SEL. " Selection-Screen
INCLUDE ZGTSDR0120F01. " FORM-Routines
INCLUDE ZGTSDR0120O01. " PBO-Modules
INCLUDE ZGTSDR0120I01. " PAI-Modules
*-------------------------------------------------------------------*
*   INITIALIZATION                                                  *
*-------------------------------------------------------------------*
INITIALIZATION.

** Layout관련
  G_REPID = SY-CPROG.
  GV_EDIT = 'X'.
  G_SAVE = 'A'.   "The user may save all types of a layout
**

* 영업조직 필드
  G_DYNPFIELDS_T-FIELDNAME = 'PA_VKORG'.
  APPEND G_DYNPFIELDS_T.
* 유통경로 필드
  G_DYNPFIELDS_T-FIELDNAME = 'PA_VTWEG'.
  APPEND G_DYNPFIELDS_T.
* 제품군 필드
  G_DYNPFIELDS_T-FIELDNAME = 'SO_SPART-LOW'.
  APPEND G_DYNPFIELDS_T.
* 영업팀 필드
*  g_dynpfields_t-fieldname = 'PA_VKBUR'.
  G_DYNPFIELDS_T-FIELDNAME = 'SO_VKBUR-LOW'.
  APPEND G_DYNPFIELDS_T.

*-------------------------------------------------------------------*
*   AT SELECTION SCREEN : Input Check & Message output
*-------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

* Layout관련
  IF  DEFAULT  =  ' '.

    CLEAR DEF_LAYOUT.
    MOVE  G_REPID   TO  DEF_LAYOUT-REPORT.
    MOVE  '1'       TO  DEF_LAYOUT-HANDLE.

    CALL FUNCTION 'LVC_VARIANT_DEFAULT_GET'
      EXPORTING
        I_SAVE     = G_SAVE
      CHANGING
        CS_VARIANT = DEF_LAYOUT
      EXCEPTIONS
        NOT_FOUND  = 2.

    IF  SY-SUBRC  =  2.
      MESSAGE S001 WITH '레이아웃 기본세팅이 없습니다.'.
    ELSE.

      P_VARI = DEF_LAYOUT-VARIANT.
      DEFAULT = 'X'.

    ENDIF.

  ENDIF.

*-------------------------------------------------------------------*
** Select-Option화면에 드롭다운 ListBox 생성하는 방법.
*-------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR PA_FKSTA .
  PERFORM VALUE_REQUEST USING 'FKSTA'.

** 레이아웃관련 F4.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM VALUE_REQUEST_VARI.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_VKBUR-LOW.
  PERFORM F4_FOR_VKBUR.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_VKGRP-LOW.
  PERFORM F4_FOR_VKGRP.

*-------------------------------------------------------------------*
*-------------------------------------------------------------------*
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
  MOVE  '1'      TO  SPEC_LAYOUT-HANDLE.

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

*-------------------------------------------------------------------*
*   START-OF-SELECTION                                              *
*-------------------------------------------------------------------*
START-OF-SELECTION.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      TEXT   = 'Data Loading....'
    EXCEPTIONS
      OTHERS = 1.

  CLEAR GS_VARIANT.
  MOVE-CORRESPONDING SPEC_LAYOUT TO GS_VARIANT.

** 실제자재이동일 Check
  READ TABLE SO_WADAT INDEX 1.

*  IF SY-TCODE = |ZGTSDR0120|.  "해당 티코드 진입시 조회만 가능
  "해당 티코드로도 로직 수행함.
*    P_LOCK = 'X'.
*  ENDIF.

  GV_SPMON = PA_FKDAT.
**********************************************************************
  PERFORM  QUERY_DATA.
**********************************************************************

**********************************************************************
*프로그램 락 생성
**********************************************************************
    IF P_LOCK IS INITIAL AND SY-TCODE = |ZGTSDR0120|.
      PERFORM PROG_LOCK USING P_LOCK 'ZGTSDR1080'.
    ENDIF.
**********************************************************************

*-------------------------------------------------------------------*
*   END-OF-SELECTION                                                *
*-------------------------------------------------------------------*
END-OF-SELECTION.

*> PROGRESS Display.
  G_LINEN    = 90.
  G_OUT_TEXT = '리스트를 구성 중입니다... %99999%%'.
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZSDR0230) USING G_OUT_TEXT G_LINEN.

**********************************************************************
  "데이타 건수 메시지 출력
  IF G_ITAB_T[] IS NOT INITIAL.
    MESSAGE S009(ZGTSD01) WITH |{ LINES( G_ITAB_T ) NUMBER = USER }|. "& 건 검색되었습니다.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE S010(ZGTSD01).                                           "조회할 데이타가 없습니다.
  ENDIF.
