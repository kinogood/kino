************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-2100                                              *
* T_CODE        : ZNF2R2100                                            *
* Description   : 선물요청 생성                                        *
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/02/01   SDC24     Initial Release                               *
************************************************************************
* Comment :
************************************************************************

REPORT  ZNFR2100  MESSAGE-ID ZNF1.

INCLUDE ZNFR2100TOP.

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
PARAMETERS     : P_BUKRS LIKE ZNFT1010-BUKRS OBLIGATORY MEMORY ID BUK.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001
                                                NO INTERVALS.
PARAMETERS     : P_R01   RADIOBUTTON GROUP GR1 DEFAULT 'X',
                 P_R02   RADIOBUTTON GROUP GR1,
                 P_R03   RADIOBUTTON GROUP GR1,
                 P_R04   RADIOBUTTON GROUP GR1,
                 P_R05   RADIOBUTTON GROUP GR1.
SELECTION-SCREEN END   OF BLOCK BLK1.

*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.

*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN                                              *
*----------------------------------------------------------------------*
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
*___회사코드 기본값
  PERFORM GET_DEFAULT_COMPANY_DATA USING P_BUKRS
                                         GV_WAERS
                                         GV_LAND1
                                         GV_BUTXT
                                         GV_KTOPL
                                         GV_KOKRS.

  PERFORM INIT_VARIABLE.

*----------------------------------------------------------------------*
*     END-OF-SELECTION                                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.
  CHECK GV_ERROR IS INITIAL.

  CALL SCREEN 0100.

INCLUDE ZNF2COMM.

INCLUDE ZNFR2100F01.

INCLUDE ZNFR2100O01.

INCLUDE ZNFR2100I01.
