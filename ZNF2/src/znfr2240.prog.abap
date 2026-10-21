************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-2240                                              *
* T_CODE        : ZNF2R2240                                            *
* Description   : 신규/청산 선물집행 변경(승인후)                      *
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/03/22   FIC23     Initial Release                               *
* 2012/09/18   EDB03     만기이동 진행건에 대해 조회되지 않도록 처리   *
************************************************************************
* Comment :
************************************************************************

REPORT  ZNFR2240  MESSAGE-ID ZNF1.

INCLUDE ZNFR2240TOP.

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
PARAMETERS     : P_BUKRS LIKE ZNFT1020-BUKRS OBLIGATORY MEMORY ID BUK.
SELECT-OPTIONS : S_FCM   FOR  ZNFT1020-FCM,
                 S_RUDAT FOR  ZNFT1020-RUDAT,
                 S_BY_SL FOR  ZNFT1020-BY_SL,
                 S_ENDAT FOR  ZNFT1020-ENDAT,
                 S_PRCTR FOR  ZNFT1000-PRCTR,
                 S_NFUTN FOR  ZNFT1020-NFUTN,
                 S_CFUTN FOR  ZNFT1030-CFUTN.
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
*  PERFORM SET_DEFAULT_PARAMETER.

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
*___회사코드 기본값
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

  IF GT_MAIN[] IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택조건에 해당하는 데이터가 존재하지 않습니다.'.
  ENDIF.

  INCLUDE ZNF2COMM.

  INCLUDE ZNFR2240F01.

  INCLUDE ZNFR2240O01.

  INCLUDE ZNFR2240I01.
