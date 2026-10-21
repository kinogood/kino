************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-2470                                              *
* T_CODE        : ZNF2R4720                                            *
* Description   : 계약-요청-집행 상태점검                              *
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/06/19   FIC23     Initial Release                               *
************************************************************************
* Comment :
************************************************************************

REPORT  ZNFR2470  MESSAGE-ID ZNF1.

INCLUDE ZNFR2470_TOP.

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
PARAMETERS     : P_BUKRS LIKE ZNFT1040-BUKRS OBLIGATORY MEMORY ID BUK.
SELECT-OPTIONS : S_FCM   FOR  ZNFT1020-FCM  ,  " FCM
                 S_RUDAT FOR  ZNFT1020-RUDAT,  " 선물집행일
                 S_NFKEY FOR  ZNFT1020-NFKEY,  " 비철구분
                 S_PRCTR FOR  ZNFT1000-PRCTR,  " 손익센터
                 S_ENDAT FOR  ZNFT1020-ENDAT.  " 만기일
SELECTION-SCREEN END   OF BLOCK BLK1.

*Buy/Sell 구분
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

* Selected Data Query
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
  INCLUDE ZNFR2470_F01.
  INCLUDE ZNFR2470_O01.
  INCLUDE ZNFR2470_I01.
