************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-120                                               *
* T_CODE        : ZNF2R2000                                            *
* Description   : 계약수정
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/03/15   FIN23     Initial Release                               *
************************************************************************
* Comment :
************************************************************************

REPORT  ZNFR2000 MESSAGE-ID ZNF1.

INCLUDE ZNFR2000TOP.

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
PARAMETERS     : P_BUKRS LIKE ZNFT1000-BUKRS OBLIGATORY MEMORY ID BUK.
SELECT-OPTIONS : S_ERDAT FOR  ZNFT1000-ERDAT,  " 생성일
                 S_CONNO FOR  ZNFT1000-CONNO,  " 계약번호
                 S_ZPJNO FOR  ZNFT1000-ZPJNO , " 프로젝트번호
                 S_NFCTR FOR  ZNFT1000-NFCTR,  " 사업부
                 S_PRCTR FOR  ZNFT1000-PRCTR,  " 손익센터
                 S_VKGRP FOR  ZNFT1000-VKGRP NO INTERVALS,  " 영업그룹
                 S_ERNAM FOR  ZNFT1000-ERNAM.  " 생성자
SELECTION-SCREEN END   OF BLOCK BLK1.


*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.


*----------------------------------------------------------------------*
*     START-OF-SELECTION                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.
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

INCLUDE ZNFR2000F01.

INCLUDE ZNFR2000O01.

INCLUDE ZNFR2000I01.
