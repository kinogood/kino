************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-120                                               *
* T_CODE        : ZNF2R2010                                            *
* Description   : 계약 - 선물요청 현황조회
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/03/15   FIN23     Initial Release                               *
************************************************************************
* Comment :
************************************************************************

REPORT  ZNFR2010 MESSAGE-ID ZNF1.

INCLUDE ZNFR2010TOP.

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
PARAMETERS     : P_BUKRS LIKE ZNFT1000-BUKRS OBLIGATORY MEMORY ID BUK.
SELECT-OPTIONS : S_ERDAT FOR  ZNFT1000-ERDAT,  " 생성일
                 S_CONNO FOR  ZNFT1000-CONNO,  " 계약번호
                 S_NFCTR FOR  ZNFT1000-NFCTR,  " 사업부
                 S_ZPJNO FOR  ZNFT1000-ZPJNO,  " 사업부
                 S_PRCTR FOR  ZNFT1000-PRCTR,  " 손익센터
                 S_VKGRP FOR  ZNFT1000-VKGRP,  " 영업그룹
                 S_ERNAM FOR  ZNFT1000-ERNAM.  " 생성자
SELECTION-SCREEN END   OF BLOCK BLK1.

*___신규/청산 구분
SELECTION-SCREEN BEGIN OF BLOCK BLK2 WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS     : P_CHK01 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) TEXT-011 FOR FIELD P_CHK01.
PARAMETERS     : P_CHK02 AS CHECKBOX.
SELECTION-SCREEN COMMENT (15) TEXT-012 FOR FIELD P_CHK02.
PARAMETERS     : P_CHK03 AS CHECKBOX.
SELECTION-SCREEN COMMENT (15) TEXT-013 FOR FIELD P_CHK03.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BLK2.

SELECTION-SCREEN BEGIN OF BLOCK BLK3 WITH FRAME TITLE TEXT-003.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS    : P_RA1 RADIOBUTTON GROUP GR1.
SELECTION-SCREEN COMMENT (20) TEXT-021 FOR FIELD P_RA1.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS    : P_RA2 RADIOBUTTON GROUP GR1 DEFAULT 'X'.
SELECTION-SCREEN COMMENT (20) TEXT-022 FOR FIELD P_RA2.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BLK3.
*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.

*----------------------------------------------------------------------*
*     START-OF-SELECTION                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM MAKE_RANGE_CSTAT USING GV_ERROR.
  IF GV_ERROR EQ 'X'.
    STOP.
  ENDIF.
  IF P_RA1 EQ 'X'.
    PERFORM DATA_SELECT_HIERARCHY.
  ELSE.
    PERFORM DATA_SELECT_ZNFT1000.
  ENDIF.

*----------------------------------------------------------------------*
*     END-OF-SELECTION                                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.
  CHECK GV_ERROR IS INITIAL.

  IF P_RA1 EQ 'X'.

  ELSE.
    IF GT_OUTTAB IS NOT INITIAL AND LINES( GT_OUTTAB ) GT 0.
      CALL SCREEN 1100.
    ELSE.
      MESSAGE S383(ME).
    ENDIF.
  ENDIF.

*----------------------------------------------------------------------*
*     INCLUDE                                                          *
*----------------------------------------------------------------------*
  INCLUDE ZNF2COMM.

  INCLUDE ZNFR2010F01.
  INCLUDE ZNFR2010O01.
  INCLUDE ZNFR2010I01.
