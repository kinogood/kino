*&---------------------------------------------------------------------*
*&  모듈       : SD
*&  프로그램 ID : ZGTLER1130
*&  프로그램 명  : 배차요청
*&  개요       : 가온전선_배차요청
*&              => ZLER0101 COPY 생성
*&  생성일      : 2026.02.01
*&  생성자      : ZGODEV01
*&---------------------------------------------------------------------*
*& 외부호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*----------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*
REPORT  ZGTLER1130 NO STANDARD PAGE HEADING  MESSAGE-ID ZLE1.

INCLUDE ZGTLER1130TOP.
INCLUDE ZGTLER1130SEL.
INCLUDE ZGTLER1130C01.
INCLUDE ZGTLER1130O01.
INCLUDE ZGTLER1130I01.
INCLUDE ZGTLER1130F01.
INCLUDE ZGTLER1130F02.

*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.
*  PERFORM ATTACH_FILE.
  PERFORM INIT.
  PERFORM S_ERDAT_SETTING.


*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN OUTPUT.                                      *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM SELECTION_SCREEN_MODIFY.



AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_LIFNR-LOW .
  PERFORM F4_VALUE_LIFNR.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_TYPE-LOW .
  PERFORM F4_IV_TYPE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VSTEL-LOW.
  PERFORM F4_VSTEL USING 'S_VSTEL-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VSTEL-HIGH.
  PERFORM F4_VSTEL USING 'S_VSTEL-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_LGORT-LOW.
  PERFORM F4_LGORT USING 'S_LGORT-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VTWEG-LOW.
  PERFORM F4_VTWEG USING 'S_VTWEG-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VTWEG-HIGH.
  PERFORM F4_VTWEG USING 'S_VTWEG-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKBUR-LOW.
  PERFORM F4_VKBUR USING 'S_VKBUR-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKBUR-HIGH.
  PERFORM F4_VKBUR USING 'S_VKBUR-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKGRP-LOW.
  PERFORM F4_VKGRP USING 'S_VKGRP-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKGRP-HIGH.
  PERFORM F4_VKGRP USING 'S_VKGRP-HIGH'.




*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN.                                             *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM CHECK_INPUT_FIELD.
** 권한CHECK
  PERFORM AUTHORITY_CHECK.



*----------------------------------------------------------------------*
*     START-OF-SELECTION                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM CHECK_INPUT.
  PERFORM DATA_QUERY TABLES GT_ALV1
                            R_VBELN.

  IF GT_ALV1[] IS NOT INITIAL.
    CASE 'X'.
      WHEN R10.
        GV_TITLE10 = TEXT-004.
      WHEN OTHERS.
        GV_TITLE10 = TEXT-003.
    ENDCASE.
    CALL SCREEN 100.
  ELSE.
    MESSAGE S002 DISPLAY LIKE 'E'
       WITH '선택조건에 해당하는 데이터가 존재하지 않습니다.'.
  ENDIF.
