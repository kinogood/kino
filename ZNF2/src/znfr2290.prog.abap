************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-2290                                              *
* T_CODE        : ZNF2R2290                                            *
* Description   : 선물 평균가 입력                                     *
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/03/28   FIN23     Initial Release                               *
************************************************************************
* Comment :
************************************************************************
REPORT ZNFR2290 MESSAGE-ID ZNF1.

INCLUDE ZNFR2290TOP.

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
PARAMETERS     : P_BUKRS LIKE ZNFT1020-BUKRS OBLIGATORY MEMORY ID BUK.
SELECT-OPTIONS : S_ENDAT FOR ZNFT1020-ENDAT,
                 S_RUDAT FOR ZNFT1020-RUDAT,
                 S_FCM   FOR ZNFT1020-FCM,
                 S_MIMON FOR ZNFT1020-MIMON,
                 S_NFKEY FOR ZNFT1020-NFKEY,
                 S_NFUTN FOR ZNFT1020-NFUTN,
                 S_CFUTN FOR ZNFT1030-CFUTN,
                 S_BY_SL FOR ZNFT1020-BY_SL.
SELECTION-SCREEN END   OF BLOCK BLK1.

*___신규/청산 구분
SELECTION-SCREEN BEGIN OF BLOCK BLK2 WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS     : P_CHK01 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) TEXT-011 FOR FIELD P_CHK01.
PARAMETERS     : P_CHK02 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (15) TEXT-012 FOR FIELD P_CHK02.
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

  PERFORM MODIFY_SCREEN_CHECKBOX USING GV_ERROR.

  IF GV_ERROR IS NOT INITIAL.
    STOP.
  ENDIF.

*----------------------------------------------------------------------*
*     START-OF-SELECTION                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM GET_DEFAULT_COMPANY_DATA USING P_BUKRS
                                         GV_WAERS
                                         GV_LAND1
                                         GV_BUTXT
                                         GV_KTOPL
                                         GV_KOKRS.

  PERFORM GET_FUTURES_DATA.

*----------------------------------------------------------------------*
*     END-OF-SELECTION                                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.

  CHECK GV_ERROR IS INITIAL.

  CALL SCREEN 1100.

  INCLUDE ZNF2COMM.

  INCLUDE ZNFR2290F01.

  INCLUDE ZNFR2290O01.

  INCLUDE ZNFR2290I01.
