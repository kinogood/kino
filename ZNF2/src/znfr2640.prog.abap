************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-2640                                              *
* T_CODE        : ZNF2R2640                                            *
* Description   : Exposure 현황
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/04/27   FIC23     Initial Release                               *
************************************************************************
* Comment : 초기 스펙에 CU에 한해 데이터를 가져오는 것에서 이후에 전체
*           모든 비철구분에 해당하는 전체 데이터를 가져오는것으로
*           변경되어서 일부 필드에 CU라는 필드로 명명됨
************************************************************************

REPORT  ZNFR2640  MESSAGE-ID ZNF1.

INCLUDE ZNFR2640TOP.

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
PARAMETERS     : P_BUKRS LIKE ZNFT1000-BUKRS OBLIGATORY MEMORY ID BUK.
SELECT-OPTIONS : S_NFCTR FOR  ZNFT1000-NFCTR,  " 사업부
                 S_PRCTR FOR  ZNFT1000-PRCTR,  " 손익센터
                 S_VKGRP FOR  ZNFT1000-VKGRP,  " 영업그룹
                 S_NFKEY FOR  ZNFT1001-NFKEY,  " 비철구분
                 S_CONNO FOR  ZNFT1000-CONNO,  " 계약번호
                 S_ERDAT FOR  ZNFT1000-ERDAT,  " 계약생성일
                 S_NFUTN FOR  ZNFT1020-NFUTN,  " 신규선물 집행번호
                 S_RUDAT FOR  ZNFT1020-RUDAT,  " 신규선물 집행일
                 S_VBELN FOR  VBAK-VBELN    ,  " 판매오더
                 S_VBDAT FOR  VBAK-ERDAT    .  " 판매오더 생성일
SELECTION-SCREEN END   OF BLOCK BLK1.

*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM MAKE_SELETCT_OPTION.

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

  IF GT_OUTTAB IS NOT INITIAL AND LINES( GT_OUTTAB ) GT 0.
    CALL SCREEN 1100.
  ELSE.
    MESSAGE S383(ME).
  ENDIF.


INCLUDE ZNF2COMM.
INCLUDE ZNFR2640O01.
INCLUDE ZNFR2640I01.
INCLUDE ZNFR2640F01.
