************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-2320                                              *
* T_CODE        : ZNF2R2320                                            *
* Description   : 만기이동                                             *
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/03/07   SDC24     Initial Release                               *
************************************************************************
* Comment :
************************************************************************

REPORT  ZNFR2320  MESSAGE-ID ZNF1.

INCLUDE ZNF2COMM.
INCLUDE ZNFR2320TOP.
INCLUDE ZNFR2320SEL.
INCLUDE ZNFR2320O01.
INCLUDE ZNFR2320I01.
INCLUDE ZNFR2320F01.

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

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_REMON-LOW.
  PERFORM F4HELP_MONTH USING S_REMON-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_REMON-HIGH.
  PERFORM F4HELP_MONTH USING S_REMON-HIGH.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_PRCTR-LOW.
  PERFORM F4HELP_PRCTR USING S_PRCTR-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_PRCTR-HIGH.
  PERFORM F4HELP_PRCTR USING S_PRCTR-HIGH.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKGRP-LOW.
  PERFORM F4HELP_VKGRP USING S_VKGRP-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKGRP-HIGH.
  PERFORM F4HELP_VKGRP USING S_VKGRP-HIGH.

AT SELECTION-SCREEN.
*___회사코드 권한 점검
  PERFORM CHECK_AUTHORIZATION USING P_BUKRS
                                    GV_ERROR.

  IF GV_ERROR IS NOT INITIAL.
    STOP.
  ENDIF.

*___만기이동 권한 점검
*  PERFORM CHECK_AUTHORIZATION_SHIFT USING GV_ERROR.

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

  PERFORM SET_RANGES.

  PERFORM GET_SHIFT_REQ_DATA.

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
