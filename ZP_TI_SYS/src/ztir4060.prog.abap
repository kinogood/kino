************************************************************************
*  Module/Submodule :   MM(수입)
*  TYPE             :   Report
*  P/G              :   수입통관현황(관세청신고)
*  Author           :   ZLSGMM3
*  RICEF-ID         :
*  Date             :   2021.09.07
************************************************************************
*                        MODIFICATION LOG
*-----------------------------------------------------------------------
* Date.      Author.  CSR #            Description.
*-----------------------------------------------------------------------
* 2021.09.07 송승규  신규개발           Initial release
* 2023.02.24 송승규  CHM2302-00202
*  란번호, 행번호, 란관세율, 통관환율, 원화총과세가격, 원화송장금액 표시
************************************************************************


REPORT ZTIR4060 NO STANDARD PAGE HEADING MESSAGE-ID ZMM1.

**----------------------------------------------------------------------
*
** INCLUDE
**----------------------------------------------------------------------

INCLUDE ZTIR4060_F02.

INCLUDE ZTIR4060_C01.

INCLUDE ZTIR4060_TOP.

INCLUDE ZTIR4060_S01.

INCLUDE ZTIR4060_F01.

INCLUDE ZTIR4060_O01.

INCLUDE ZTIR4060_I01.


*&---------------------------------------------------------------------
*&
*&---------------------------------------------------------------------
INITIALIZATION.
  PERFORM SET_DATE_INIT.


*----------------------------------------------------------------------*
*  AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM ALV_VARIANT_F4 CHANGING P_VARI.


AT SELECTION-SCREEN OUTPUT.
*   PERFORM SET_SCREEN_OUTPUT.

*&---------------------------------------------------------------------
*& START-OF-SELECTION
*&---------------------------------------------------------------------

START-OF-SELECTION.

  "GET DATA
  PERFORM GET_DATA.

  "SET DATA
  PERFORM SET_DATA.

  DESCRIBE TABLE GT_TEMP LINES GV_LINES.
  IF GV_LINES = 0.
    MESSAGE S005 DISPLAY LIKE 'E'.  "자료가 존재하지 않습니다.
    EXIT.
  ELSE.
    MESSAGE S009 WITH GV_LINES. "& 건의 데이터를 찾았습니다.
  ENDIF.

  CALL SCREEN 100.
