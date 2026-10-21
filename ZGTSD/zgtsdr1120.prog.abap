*&---------------------------------------------------------------------*
*&  모듈       : SD
*&  프로그램 ID : ZGTSDR1120
*&  프로그램 명  : 커미션 정산오더 생성
*&  개요       : 가온전선_커미션 정산오더 생성
*&  생성일      : 2025.12.27
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
REPORT ZGTSDR1120       NO STANDARD PAGE HEADING
                        MESSAGE-ID ZGTSD01.


*-----------------------------------------------------------------------
* INCLUDE
*-----------------------------------------------------------------------
INCLUDE ZGTSDR1120TOP.
INCLUDE ZGTSDR1120C01.
INCLUDE ZGTSDR1120SEL.
INCLUDE ZGTSDR1120O01.
INCLUDE ZGTSDR1120I01.
INCLUDE ZGTSDR1120F01.


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

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PA_VTWEG.
  PERFORM F4_VTWEG USING 'PA_VTWEG'.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR PA_SPART.
  PERFORM F4_SPART USING 'PA_SPART'.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR PA_VKBUR.
  PERFORM F4_VKBUR USING 'PA_VKBUR'.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR PA_VKGRP.
  PERFORM F4_VKGRP USING 'PA_VKGRP'.






*-----------------------------------------------------------------------
* AT SELECTION-SCREEN
*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON PA_DATE.
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = PA_DATE
    IMPORTING
      LAST_DAY_OF_MONTH = GV_LAST
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2.

  IF PA_DATE <> GV_LAST.
    MESSAGE E000 WITH TEXT-E01. "'정산일자는 월 마지막 일자로 입력해주세요' TYPE 'E'.
    EXIT.
  ENDIF.

*-----------------------------------------------------------------------
* START-OF-SELECTION
*-----------------------------------------------------------------------
START-OF-SELECTION.

** 권한CHECK.
  PERFORM AUTHORITY_CHECK.

  PERFORM DATA_QUERY.

  PERFORM GET_KNUMA.

  PERFORM DATA_PROCESSING.


*-----------------------------------------------------------------------
* END-OF-SELECTION
*-----------------------------------------------------------------------
END-OF-SELECTION.

  IF GT_ITAB IS INITIAL .
    MESSAGE I018. " WITH '조회되는 데이터가 없습니다.'.
  ELSE.
    CALL SCREEN 100.
  ENDIF.
