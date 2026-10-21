*&---------------------------------------------------------------------*
*&  모듈       : SD
*&  프로그램 ID : ZGTLER1100
*&  프로그램 명  : 출하요청 관리
*&  개요       : 가온전선 출하요청 관리
*&  생성일      : 2025.11.13
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

REPORT  ZGTLER1100  MESSAGE-ID ZLE1.

INCLUDE ZGTLER1100C01.
INCLUDE ZGTLER1100TOP.
INCLUDE ZGTLER1100SEL.

INCLUDE ZGTLER1100F01.
INCLUDE ZGTLER1100O01.
INCLUDE ZGTLER1100I01.



*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM SET_INIT_PARAMETER.

*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN.                                             *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
*->>[가온전선]------------------------------------------------------S
* 영업그룹 체크
*  PERFORM CHECK_SALES_GROUP.
*-<<[가온전선]------------------------------------------------------E
  PERFORM CHECK_AUTHRIZATION.

  IF SSCRFIELDS-UCOMM = 'FC01'.
    PERFORM EXCEL_UPLOAD.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  PERFORM SET_SCREEN_ATTRIBUTE_1000.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKBUR-LOW.
  PERFORM F4_VKBUR USING 'S_VKBUR-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKBUR-HIGH.
  PERFORM F4_VKBUR USING 'S_VKBUR-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKBUR1-LOW.
  PERFORM F4_VKBUR USING 'S_VKBUR1-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKBUR1-HIGH.
  PERFORM F4_VKBUR USING 'S_VKBUR1-HIGH'.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKGRP-LOW.
  PERFORM F4_VKGRP USING 'S_VKGRP-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKGRP-HIGH.
  PERFORM F4_VKGRP USING 'S_VKGRP-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VSTEL-LOW.
  PERFORM F4_VSTEL USING 'S_VSTEL-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VSTEL-HIGH.
  PERFORM F4_VSTEL USING 'S_VSTEL-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VSTEL1-LOW.
  PERFORM F4_VSTEL USING 'S_VSTEL1-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VSTEL1-HIGH.
  PERFORM F4_VSTEL USING 'S_VSTEL1-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_WERKS-LOW.
  PERFORM F4_WERKS USING 'S_WERKS-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_WERKS-HIGH.
  PERFORM F4_WERKS USING 'S_WERKS-HIGH'.

*----------------------------------------------------------------------*
*     START-OF-SELECTION                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.
  CASE GV_TRTYP.
    WHEN 'H'.           "생성
      PERFORM GET_ORDER_DATA.

    WHEN OTHERS.       "변경/조회
      PERFORM GET_DELIVERY_REQ_DATA.

  ENDCASE.

*----------------------------------------------------------------------*
*     END-OF-SELECTION                                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.
  IF GT_MAIN[] IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE S002 DISPLAY LIKE 'E'
       WITH '선택조건에 해당하는 데이터가 존재하지 않습니다.'.
  ENDIF.
