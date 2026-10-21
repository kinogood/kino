************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-2410                                              *
* T_CODE        : ZNF2R2410/ZNF2R2410R                                 *
* Description   : Netting 선물 자동 생성/취소                          *
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/03/15   SDC24     Initial Release                               *
* 2017/04/03   신재호    [기능개선 189023] 신규 비철키 SN 추가         *
* 2021/07/08   이원형    SRM2106-01348 Netting포지션의 수수료 부과 기준 변경 *
************************************************************************
* Comment :
************************************************************************

REPORT  ZNFR2410  MESSAGE-ID ZNF1.

INCLUDE ZNFR2410TOP.

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
*___회사코드 기본값
  PERFORM GET_DEFAULT_COMPANY_DATA USING P_BUKRS
                                         GV_LWAERS
                                         GV_LAND1
                                         GV_BUTXT
                                         GV_KTOPL
                                         GV_KOKRS.

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

INCLUDE ZNFR2410F01.

INCLUDE ZNFR2410O01.

INCLUDE ZNFR2410I01.
