************************************************************************
* 모듈/서브모듈 : MM / 비철                                            *
* Type          : Report                                               *
* GAP ID        : NF-2310                                              *
* T_CODE        : ZNF2R2310                                            *
* Description   : 만기이동요청 조회 및 변경                            *
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2012/03/05   SDC24     Initial Release                               *
************************************************************************
* Comment :
************************************************************************

REPORT  ZNFR2310  MESSAGE-ID ZNF1.

INCLUDE ZNFR2310TOP.

*----------------------------------------------------------------------*
*   SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
PARAMETERS     : P_BUKRS LIKE ZNFT1020-BUKRS OBLIGATORY MEMORY ID BUK.
SELECT-OPTIONS : S_FCM   FOR  ZNFT1020-FCM,
                 S_NFKEY FOR  ZNFT1020-NFKEY,
                 S_SHFNO FOR  ZNFT1040-SHFNO,
                 S_ERDAT FOR  ZNFT1040-ERDAT,
                 S_ENDMM FOR  ZNFT1011-ENDMM,
                 S_REMON FOR  ZNFT1041-REMON,
                 S_ZPJNO FOR  ZNFT1000-ZPJNO,
                 S_PRCTR FOR  ZNFT1000-PRCTR,
                 S_VKGRP FOR  ZNFT1000-VKGRP,
                 S_NFUTN FOR  ZNFT1020-NFUTN,
                 S_REQNO FOR  ZNFT1010-REQNO,
                 S_CONNO FOR  ZNFT1011-CONNO.
SELECTION-SCREEN END   OF BLOCK BLK1.

*___결재상태
SELECTION-SCREEN BEGIN OF BLOCK BLK2 WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS     : P_CHK01 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (10) TEXT-011 FOR FIELD P_CHK01.
PARAMETERS     : P_CHK02 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (10) TEXT-012 FOR FIELD P_CHK02.
PARAMETERS     : P_CHK03 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (10) TEXT-013 FOR FIELD P_CHK03.
PARAMETERS     : P_CHK04 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (10) TEXT-014 FOR FIELD P_CHK04.
PARAMETERS     : P_CHK05 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (10) TEXT-015 FOR FIELD P_CHK05.
PARAMETERS     : P_CHK06 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (10) TEXT-016 FOR FIELD P_CHK06.
PARAMETERS     : P_CHK07 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (10) TEXT-017 FOR FIELD P_CHK07.
PARAMETERS     : P_CHK08 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT (10) TEXT-018 FOR FIELD P_CHK08.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BLK2.

*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM SET_DEFAULT_PARAMETER.

*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN                                              *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_FCM-LOW.
  PERFORM F4HELP_FCM USING S_FCM-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_FCM-HIGH.
  PERFORM F4HELP_FCM USING S_FCM-HIGH.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ENDMM-LOW.
  PERFORM F4HELP_MONTH USING S_ENDMM-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ENDMM-HIGH.
  PERFORM F4HELP_MONTH USING S_ENDMM-HIGH.

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

  PERFORM SET_RANGES.

  PERFORM GET_SHIFT_REQ_DATA.

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

INCLUDE ZNFR2310F01.
