*&---------------------------------------------------------------------*
*&  모듈       : SD
*&  프로그램 ID : ZGTLER1110
*&  프로그램 명  : 출하요청 확정
*&  개요       : 가온전선 출하요청 확정
*&              => ZLER0404 COPY 생성
*&  생성일      : 2026.01.12
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
REPORT  ZGTLER1110  MESSAGE-ID ZLE1.


INCLUDE ZGTLER1110C01.
INCLUDE ZGTLER1110TOP.
INCLUDE ZGTLER1110SEL.
INCLUDE ZGTLER1110O01.
INCLUDE ZGTLER1110I01.
INCLUDE ZGTLER1110F01.


*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM SET_INIT_PARAMETER.

*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN.                                             *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM CHECK_AUTHRIZATION.


*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN OUTPUT.                                      *
*----------------------------------------------------------------------*

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKBUR-LOW.
  PERFORM F4_VKBUR USING 'S_VKBUR-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKBUR-HIGH.
  PERFORM F4_VKBUR USING 'S_VKBUR-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VSTEL.
  PERFORM F4_VSTEL USING 'P_VSTEL'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKGRP-LOW.
  PERFORM F4_VKGRP USING 'S_VKGRP-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKGRP-HIGH.
  PERFORM F4_VKGRP USING 'S_VKGRP-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_WERKS-LOW.
  PERFORM F4_WERKS USING 'S_WERKS-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_WERKS-HIGH.
  PERFORM F4_WERKS USING 'S_WERKS-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_SPART-LOW.
  PERFORM F4_SPART USING 'S_SPART-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_SPART-HIGH.
  PERFORM F4_SPART USING 'S_SPART-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_DLVRQ-LOW.
  PERFORM F4_DLVRQ USING 'S_DLVRQ-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_DLVRQ-HIGH.
  PERFORM F4_DLVRQ USING 'S_DLVRQ-HIGH'.



*----------------------------------------------------------------------*
*     START-OF-SELECTION                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM GET_DELIVERY_REQ_DATA.

*  PERFORM GET_DELIVERY_REQ_DATA_NEW.

*----------------------------------------------------------------------*
*     END-OF-SELECTION                                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.
  IF GT_MAIN[] IS NOT INITIAL.
    IF P_SUBMIT IS INITIAL.
      CALL SCREEN 0100.
    ENDIF.
  ELSE.
    MESSAGE S002 DISPLAY LIKE 'E'
       WITH TEXT-003."'선택조건에 해당하는 데이터가 존재하지 않습니다.'.
  ENDIF.
