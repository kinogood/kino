************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-2630                                              *
* T_CODE        : ZNF2R2630                                            *
* Description   : 일별 선물집행내역 Report
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/04/27   FIC23          Initial Release                          *
* 2021/09/14   ZLSGMM     CHM2109-00256  만기이동차수, 기준월 추가     *
* 2025/05/15   ZLSGMM3    CHM2504-00284  계약번호 조회옵션 추가        *
* 2026/09/17   ZLSGMM8    CHM2609-00149  만기이동유형 필드 추가        *
************************************************************************
* Comment :
************************************************************************

REPORT  ZNFR2630  MESSAGE-ID ZNF1.

INCLUDE ZNF2COMM.
INCLUDE ZNFR2630TOP.
INCLUDE ZNFR2630SEL.
INCLUDE ZNFR2630O01.
INCLUDE ZNFR2630I01.
INCLUDE ZNFR2630F01.


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

* BY_SL
  PERFORM CHECK_SELECT_CHKBOX.

* 요청유형 & 넷팅
  PERFORM CHECK_SELECT_RADIO.

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
