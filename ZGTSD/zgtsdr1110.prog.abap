*&---------------------------------------------------------------------*
*&  모듈       : SD
*&  프로그램 ID : ZGTSDR1110
*&  프로그램 명  : 커미션 정산/미지급/지급 리스트
*&  개요       : 가온전선_커미션 정산/미지급/지급 리스트
*&  생성일      : 2026.01.25
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
REPORT ZGTSDR1110  MESSAGE-ID ZGTSD01.


*-----------------------------------------------------------------------
* INCLUDE
*-----------------------------------------------------------------------
INCLUDE ZGTSDR1110TOP.
INCLUDE ZGTSDR1110C01.
INCLUDE ZGTSDR1110SEL.
INCLUDE ZGTSDR1110O01.
INCLUDE ZGTSDR1110I01.
INCLUDE ZGTSDR1110F01.


*-----------------------------------------------------------------------
* INITIALIZATION
*-----------------------------------------------------------------------
INITIALIZATION.
  PERFORM INITIALIZATION.

*-----------------------------------------------------------------------
* AT SELECTION-SCREEN OUTPUT
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
* AT SELECTION-SCREEN ON VALUE-REQUEST
*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_KNUMA-LOW. "계약No.
  PERFORM F4_KNUMA USING 'SO_KNUMA-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_KNUMA-HIGH. "계약No.
  PERFORM F4_KNUMA USING 'SO_KNUMA-HIGH'.
*  PERFORM F4_FILENAME.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_VTWEG-LOW.
  PERFORM F4_VTWEG USING 'SO_VTWEG-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_VTWEG-HIGH.
  PERFORM F4_VTWEG USING 'SO_VTWEG-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_SPART-LOW.
  PERFORM F4_SPART USING 'SO_SPART-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_SPART-HIGH.
  PERFORM F4_SPART USING 'SO_SPART-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_VKBUR-LOW.
  PERFORM F4_VKBUR USING 'SO_VKBUR-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_VKBUR-HIGH.
  PERFORM F4_VKBUR USING 'SO_VKBUR-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_VKGRP-LOW.
  PERFORM F4_VKGRP USING 'SO_VKGRP-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_VKGRP-HIGH.
  PERFORM F4_VKGRP USING 'SO_VKGRP-HIGH'.

*-----------------------------------------------------------------------
* AT SELECTION-SCREEN
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
* START-OF-SELECTION
*-----------------------------------------------------------------------
START-OF-SELECTION.

** 권한CHECK.
  PERFORM  AUTHORITY_CHECK.

  PERFORM  GET_DATA.


*-----------------------------------------------------------------------
* END-OF-SELECTION
*-----------------------------------------------------------------------
END-OF-SELECTION.

IF GT_ITAB[] IS INITIAL .
  MESSAGE I010."I001 WITH '조회되는 데이터가 없습니다.'.
 ELSE.
  CALL SCREEN 100.
ENDIF.
