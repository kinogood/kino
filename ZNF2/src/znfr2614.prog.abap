************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* T_CODE        : ZNF2R2614                                            *
* Description   : 만기이동 선물손익 IN전표 일괄생성                    *
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2026/10/16              Initial Release                              *
************************************************************************
* Comment :
*  - 만기이동 시 ZNFR2611 에서 생성한 OUT전표(ZNFT1051-ZBELNR)를
*    실제 판매 시점에 손익으로 반영(IN전표)한다.
*  - 판매수량 = 만기월 선물 총수량 - 만기이동수량 (ZNFT1020-OLDFT 연결)
*  - 판매된 선물의 상위(OLDFT) 이력을 따라 OUT전표가 있는 모든 층에
*    판매수량 비율만큼 IN전표를 생성한다. (비율 입력 불필요)
*      IN금액 = OUT손익(KPRLO) * 판매수량 / 해당 층 OUT전표 수량
*      누적비율 100% 도달 시 잔액 전액 반영(단수차이 정리)
*  - 생성 결과는 ZNFT1055 에 저장 (ZNFR2612 와 동일 테이블)
************************************************************************

REPORT  ZNFR2614  MESSAGE-ID ZNF1.

INCLUDE ZNF2COMM.
INCLUDE ZNFR2614TOP.
INCLUDE ZNFR2614SEL.
INCLUDE ZNFR2614CLS.
INCLUDE ZNFR2614O01.
INCLUDE ZNFR2614I01.
INCLUDE ZNFR2614F01.
INCLUDE ZNFR2614P01.

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

  IF GT_OUTTAB[] IS NOT INITIAL.
    CALL SCREEN 1100.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택조건에 해당하는 IN전표 대상이 존재하지 않습니다.'.
  ENDIF.
