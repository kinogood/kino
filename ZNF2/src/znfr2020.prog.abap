************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-2020                                              *
* T_CODE        : ZNF2R2020                                            *
* Description   : 계약 - S/O List 조회                                 *
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/05/17   SDC24     Initial Release                               *
************************************************************************
* Comment :
************************************************************************

REPORT  ZNFR2020  MESSAGE-ID ZNF1.

INCLUDE ZNFR2020TOP.

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
PARAMETERS     : P_BUKRS LIKE ZNFT1000-BUKRS OBLIGATORY MEMORY ID BUK.
SELECT-OPTIONS : S_ERDAT FOR  ZNFT1000-ERDAT,
                 S_NFKEY FOR  ZNFT1001-NFKEY,
                 S_NFCTR FOR  ZNFT1000-NFCTR,
                 S_PRCTR FOR  ZNFT1000-PRCTR,
                 S_VKGRP FOR  ZNFT1000-VKGRP,
                 S_SPART FOR  VBAK-SPART,
                 S_CONNO FOR  ZNFT1000-CONNO,
                 S_VBELN FOR  VBAK-VBELN,
                 S_SERDT FOR  VBAK-ERDAT,
                 S_ERNAM FOR  ZNFT1000-ERNAM.
SELECTION-SCREEN END   OF BLOCK BLK1.

*___연결/미연결 구분
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

  PERFORM GET_CONTRACT_DATA.

*----------------------------------------------------------------------*
*     END-OF-SELECTION                                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.
  CHECK GV_ERROR IS INITIAL.

  IF GT_MAIN[] IS NOT INITIAL.
    PERFORM DISPLAY_RESULT.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택조건에 해당하는 데이터가 존재하지 않습니다.'.
  ENDIF.

INCLUDE ZNF2COMM.

INCLUDE ZNFR2020F01.
