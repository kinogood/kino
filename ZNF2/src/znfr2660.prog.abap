************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-2660                                              *
* T_CODE        : ZNF2R2660                                            *
* Description   : 선물만기현황조회
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE     AUTHORS                 DESCRIPTION                       *
* ---------- ---------- ---------------------------------------------- *
* 2012/05/08 FIC23      Initial Release                                *
* 2012/08/23 MMB04(HDY) C20120823_69368                                *
*                       만기월, 납기월 조건을 만기일, 납기일로 수정    *
* 2012/10/16 EDB03      C20120927_91822(Req. by 이지현)                *
*                       S/O에서 주문 및 기본단위 상이한 CASE 로직 반영 *
* 2012/11/20 EDB03      C20121105_11681(Req. by 구영헌)                *
*                       S/O의 판매처 및 납품처 필드 추가               *
************************************************************************

REPORT  ZNFR2660  MESSAGE-ID ZNF1.

INCLUDE ZNFR2660TOP.

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
PARAMETERS     : P_BUKRS LIKE ZNFT1010-BUKRS OBLIGATORY MEMORY ID BUK.
SELECT-OPTIONS : S_NFCTR FOR  ZNFT1000-NFCTR,  " 사업부
                 S_PRCTR FOR  ZNFT1000-PRCTR,  " 손익센터
                 S_VKGRP FOR  ZNFT1000-VKGRP,  " 영업그룹
                 S_NFKEY FOR  ZNFT1020-NFKEY,  " 비철구분
                 S_NFUTN FOR  ZNFT1020-NFUTN,  " 선물요청번호
                 S_RUDAT FOR  ZNFT1020-RUDAT,  " 선물집행일
**** HDY 20120823 START [C20120823_69368]
**** 만기월 조회를 만기일, 기간으로 변경
*                 S_ENDMM FOR  ZNFT1011-ENDMM NO INTERVALS,  " 만기월
                 S_ENDMM FOR  ZNFT1020-ENDAT,  " 만기일
**** HDY 20120823 END
                 S_CONNO FOR  ZNFT1000-CONNO,  " 계약번호
                 S_KUNNR FOR  ZNFT1000-KUNNR,
                 S_VBELN FOR  VBAK-VBELN    ,  " 판매오더
**** HDY 20120823 START [C20120823_69368]
**** 납기월 조회를 기간으로 변경. 납기일로 텍스트 수정
*                 S_EDATU FOR  VBEP-EDATU     NO INTERVALS.  " 납기월
                 S_EDATU FOR  VBEP-EDATU.  " 납기일
**** HDY 20120823 END
SELECTION-SCREEN END   OF BLOCK BLK1.

*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.

*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN                                              *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_NFCTR-LOW.
  PERFORM F4HELP_NFCTR USING S_NFCTR-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_NFCTR-HIGH.
  PERFORM F4HELP_NFCTR USING S_NFCTR-HIGH.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_PRCTR-LOW.
  PERFORM F4HELP_PRCTR USING S_PRCTR-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_PRCTR-HIGH.
  PERFORM F4HELP_PRCTR USING S_PRCTR-HIGH.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKGRP-LOW.
  PERFORM F4HELP_VKGRP USING S_VKGRP-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKGRP-HIGH.
  PERFORM F4HELP_VKGRP USING S_VKGRP-HIGH.

**** HDY 20120823 START [C20120823_69368]
**** 만기월을 납기월을 만기일과 만기일로 수정하면서
**** POSSIBLE ENTRY 따로 지정 안해도 됨

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ENDMM-LOW.
*  PERFORM F4HELP_MONTH USING S_ENDMM-LOW.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_EDATU-LOW.
*  PERFORM F4HELP_MONTH USING S_EDATU-LOW.

**** HDY 20120823 END

AT SELECTION-SCREEN.
  PERFORM CHECK_AUTHORIZATION USING P_BUKRS
                                    GV_ERROR.
  IF GV_ERROR IS NOT INITIAL.
    STOP.
  ENDIF.
**** HDY 20120823 START [C20120823_69368]
**** 만기월, 납기월을 일자로 수정하면서
**** 월 체크하는 로직 주석처리

*AT SELECTION-SCREEN ON S_ENDMM.
*  PERFORM CHECK_ENDMM.
*
*AT SELECTION-SCREEN ON S_EDATU.
*  PERFORM CHECK_EDATU.

**** HDY 20120823 END

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

  IF GT_OUTTAB IS NOT INITIAL AND LINES( GT_OUTTAB ) GT 0.
    CALL SCREEN 1100.
  ELSE.
    MESSAGE S383(ME).
  ENDIF.


  INCLUDE ZNF2COMM.
  INCLUDE ZNFR2660O01.
  INCLUDE ZNFR2660I01.
  INCLUDE ZNFR2660F01.
