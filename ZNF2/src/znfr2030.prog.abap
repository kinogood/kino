************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-120                                               *
* T_CODE        : ZNF2R2000                                            *
* Description   : 선물대상 계약상태 수정
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/03/15   FIN23     Initial Release                               *
* 2012/08/23   EDB03     계약상태값 변경시 오류 현상 개선(R.by 구영헌) *
************************************************************************
* Comment :
************************************************************************

REPORT  ZNFR2030 MESSAGE-ID ZNF1.

INCLUDE ZNFR2030TOP.

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
PARAMETERS     : P_BUKRS LIKE ZNFT1000-BUKRS OBLIGATORY MEMORY ID BUK.
SELECT-OPTIONS : S_ERDAT FOR  ZNFT1000-ERDAT,  " 생성일
                 S_CONNO FOR  ZNFT1000-CONNO,  " 계약번호
                 S_NFCTR FOR  ZNFT1000-NFCTR,  " 사업부
                 S_PRCTR FOR  ZNFT1000-PRCTR,  " 손익센터
                 S_VKGRP FOR  ZNFT1000-VKGRP,  " 영업그룹
                 S_ERNAM FOR  ZNFT1000-ERNAM.  " 생성자
SELECTION-SCREEN END   OF BLOCK BLK1.

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

*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.

*----------------------------------------------------------------------*
*     START-OF-SELECTION                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM MAKE_RANGES_CSTAT.
  PERFORM DATA_SELECT_ZNFT1000.

*----------------------------------------------------------------------*
*     END-OF-SELECTION                                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.
  IF GT_OUTTAB IS NOT INITIAL AND LINES( GT_OUTTAB ) GT 0.
    CALL SCREEN 1100.
  ELSE.
    MESSAGE S383(ME).
  ENDIF.


*----------------------------------------------------------------------*
*     INCLUDE                                                          *
*----------------------------------------------------------------------*
INCLUDE ZNF2COMM.

INCLUDE ZNFR2030F01.

INCLUDE ZNFR2030O01.

INCLUDE ZNFR2030I01.
