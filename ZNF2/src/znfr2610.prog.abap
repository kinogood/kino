************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-2610                                              *
* T_CODE        : ZNF2R2610                                            *
* Description   : FCM 및 사업부별 손익조회                             *
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/04/23   FIC24     Initial Release                               *
* 2013/10/01   C20130911_02959 계약번호 계약명 필드 추가               *
* 2016/08/17   신재호    [기능개선 154373] 영업담당자 필드 추가        *
************************************************************************
* Comment :
************************************************************************

REPORT  ZNFR2610  MESSAGE-ID ZNF1.

INCLUDE ZNFR2610TOP.

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
PARAMETERS     : P_BUKRS LIKE ZNFT1051-BUKRS OBLIGATORY MEMORY ID BUK.
SELECT-OPTIONS : S_ENDAT FOR  ZNFT1051-ENDAT,  " 만기일
                 S_NFKEY FOR  ZNFT1011-NFKEY,  " 비철구분
                 S_PRCTR FOR  ZNFT1000-PRCTR,  " 손익센터
                 S_VKGRP FOR  ZNFT1000-VKGRP,  " 영업그룹
                 S_KUNNR FOR  ZNFT1000-KUNNR,  " 고객
                 S_NFCTR FOR  ZNFT1000-NFCTR,  " 사업부
                 S_RUDAT FOR  ZNFT1020-RUDAT,  " 집행일
                 S_FCM   FOR  ZNFT1020-FCM  .  " FCM
SELECTION-SCREEN END   OF BLOCK BLK1.

*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.



*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN                                              *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_FCM-LOW.
  PERFORM F4HELP_FCM USING S_FCM-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_FCM-HIGH.
  PERFORM F4HELP_FCM USING S_FCM-HIGH.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_PRCTR-LOW.
  PERFORM F4HELP_PRCTR USING S_PRCTR-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_PRCTR-HIGH.
  PERFORM F4HELP_PRCTR USING S_PRCTR-HIGH.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKGRP-LOW.
  PERFORM F4HELP_VKGRP USING S_VKGRP-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKGRP-HIGH.
  PERFORM F4HELP_VKGRP USING S_VKGRP-HIGH.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_NFCTR-LOW.
  PERFORM F4HELP_NFCTR USING S_NFCTR-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_NFCTR-HIGH.
  PERFORM F4HELP_NFCTR USING S_NFCTR-HIGH.

AT SELECTION-SCREEN.
  PERFORM CHECK_AUTHORIZATION USING P_BUKRS
                                    GV_ERROR.

  IF GV_ERROR IS NOT INITIAL.
    STOP.
  ENDIF.


*----------------------------------------------------------------------*
*     START-OF-SELECTION                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.
* 회사코드 기본값
  PERFORM GET_DEFAULT_COMPANY_DATA USING P_BUKRS
                                         GV_WAERS
                                         GV_LAND1
                                         GV_BUTXT
                                         GV_KTOPL
                                         GV_KOKRS.

* GET_DATA
  PERFORM DATA_SELECT.

*----------------------------------------------------------------------*
*     END-OF-SELECTION                                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.
  CHECK GV_ERROR IS INITIAL.

  IF GT_OUTTAB IS NOT INITIAL AND LINES( GT_OUTTAB ) GT 0.
    CALL SCREEN 1100.
  ELSE.
    MESSAGE S383(ME).
  ENDIF.


  INCLUDE ZNF2COMM.
  INCLUDE ZNFR2610O01.
  INCLUDE ZNFR2610I01.
  INCLUDE ZNFR2610F01.
  INCLUDE ZNFR2610P01.
