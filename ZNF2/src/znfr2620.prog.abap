************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-2620                                              *
* T_CODE        : ZNF2R2620                                            *
* Description   : 만기이동 내역조회                                    *
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/04/27   FIC23     Initial Release                               *
************************************************************************
* Comment :
************************************************************************

REPORT  ZNFR2620  MESSAGE-ID ZNF1.

INCLUDE ZNFR2620TOP.

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
PARAMETERS     : P_BUKRS LIKE ZNFT1040-BUKRS OBLIGATORY MEMORY ID BUK.
SELECT-OPTIONS : S_SHFNO FOR  ZNFT1040-SHFNO,  " 만기이동 요청번호
                 S_ERDAT FOR  ZNFT1040-ERDAT,  " 만기이동 요청일
                 S_RUDAT FOR  ZNFT1041-RUDAT,  " 만기이동 집행일
                 S_FCM   FOR  ZNFT1020-FCM  ,  " FCM
                 S_NFKEY FOR  ZNFT1011-NFKEY,  " 비철구분
                 S_PRCTR FOR  ZNFT1000-PRCTR,  " 손익센터
                 S_VKGRP FOR  ZNFT1000-VKGRP,  " 영업그룹
                 S_ENDMM FOR  ZNFT1011-ENDMM NO INTERVALS,  " 만기월(전)
                 S_REMON FOR  ZNFT1041-REMON NO INTERVALS,  " 만기월(후)
                 S_NFDAT FOR  ZNFT1020-RUDAT,  " 선물집행일(이동전)
                 S_OFUTN FOR  ZNFT1040-OFUTN.  " 선물집행번호(이동전)
SELECTION-SCREEN END   OF BLOCK BLK1.

*___Buy/Sell 구분
SELECTION-SCREEN BEGIN OF BLOCK BLK2 WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS     : P_CHK01 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (10) TEXT-011 FOR FIELD P_CHK01.
PARAMETERS     : P_CHK02 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (10) TEXT-012 FOR FIELD P_CHK02.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BLK2.

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

*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN                                              *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ENDMM-LOW.
  PERFORM F4HELP_MONTH USING S_ENDMM-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_REMON-LOW.
  PERFORM F4HELP_MONTH USING S_REMON-LOW.

AT SELECTION-SCREEN.
  PERFORM CHECK_AUTHORIZATION USING P_BUKRS
                                    GV_ERROR.
  IF GV_ERROR IS NOT INITIAL.
    STOP.
  ENDIF.

  PERFORM CHECK_SELECTED_CHECKBOX USING GV_ERROR.
  IF GV_ERROR IS NOT INITIAL.
    STOP.
  ENDIF.

AT SELECTION-SCREEN ON S_ENDMM.
  PERFORM CHECK_ENDMM.

AT SELECTION-SCREEN ON S_REMON.
  PERFORM CHECK_REMON.

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

* Buy-Sell
  PERFORM SET_RANGES.

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
  INCLUDE ZNFR2620O01.
  INCLUDE ZNFR2620I01.
  INCLUDE ZNFR2620F01.
