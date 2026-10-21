************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-2400                                              *
* T_CODE        : ZNF2R2400/ZNF2R2400R                                 *
* Description   : 정산대상 점검 및 확정/취소                           *
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/03/13   SDC24     Initial Release                               *
* 2024/07/04   ZLSGMM3   첨부파일 체크로직 보완(ZNFT1002-FIELD6~10)    *
************************************************************************
* Comment :
************************************************************************

REPORT  ZNFR2400  MESSAGE-ID ZNF1.

INCLUDE ZNFR2400TOP.

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
PARAMETERS     : P_BUKRS LIKE ZNFT1020-BUKRS OBLIGATORY MEMORY ID BUK,
                 P_ENDMM LIKE ZNFT1011-ENDMM OBLIGATORY.
SELECTION-SCREEN END   OF BLOCK BLK1.

*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM SET_DEFAULT_PARAMETER.

*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN                                              *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_ENDMM.
  PERFORM F4HELP_MONTH USING P_ENDMM.

AT SELECTION-SCREEN ON P_ENDMM.
  PERFORM CHECK_ENDMM.

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
  PERFORM GET_SETTLEMENT_DATA.

*----------------------------------------------------------------------*
*     END-OF-SELECTION                                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.
  IF GT_MAIN[] IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택조건에 해당하는 데이터가 존재하지 않습니다.'.
  ENDIF.

INCLUDE ZNF2COMM.

INCLUDE ZNFR2400F01.

INCLUDE ZNFR2400O01.

INCLUDE ZNFR2400I01.
